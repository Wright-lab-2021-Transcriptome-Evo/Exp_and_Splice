reads_ch = Channel.fromFilePairs(params.reads + '/*{1,2}.fastq.gz')
adapter=file(params.adapter)
metadata=file(params.metadata)
cdna_ch=Channel.fromPath(params.cdna + '/*.gz')
cds_ch=Channel.fromPath(params.cds + '/*.gz')



process salmon_index {
   //conda 'bioconda::salmon' 


   publishDir 'salmon_index', mode: 'copy', overwrite: true, pattern: '*index*'
	      
   input:
   file(cdna) from cdna_ch

   output:
   tuple val(species), file("${species}_index") into salmon_indexed

   script:
   species=cdna.baseName.replace(".gz","").replace(".fa","").replace(".cdna","")
   """
   #!/bin/bash
   source /usr/local/extras/Genomics/.bashrc
   source activate salmon
   salmon index -t $cdna -i ${species}_index
   """	

} 
 
ref_ch=channel
    .fromPath(metadata)
    .splitCsv()
    .map {row ->tuple(row[0],row[1])}
    .view()


process trim {

    publishDir 'paired', mode: 'copy', overwrite: true, pattern: '*paired*'

    input:
    tuple val(sid), file(reads), val(species) from reads_ch.combine(ref_ch, by:0)

    output:
    tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz") into trimmed1
    tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz") into trimmed2


    script:

    """
    #!/bin/bash
    source /usr/local/extras/Genomics/.bashrc
    trimmomatic PE -phred33 $reads ${species}_${sid}_forward_paired.fastq.gz ${sid}_forward_unpaired.fastq.gz ${species}_${sid}_reverse_paired.fastq.gz ${sid}_reverse_unpaired.fastq.gz ILLUMINACLIP:$adapter:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95
    """
}



process salmon_quant {
    //conda 'bioconda::salmon' 

    publishDir 'salmon_quant', mode: 'copy', overwrite: true, pattern: '*salmon_out'

    input:
    //tuple val(species), file("${species}_index") from salmon_indexed 
    //tuple val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz") from trimmed1.combine(ref_ch, by:0).combine(salmon_indexed, by:0)
    //tuple val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz"), val(species) from trimmed1.combine(ref_ch, by:0)
    tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz"), file("${species}_index") from trimmed1.combine(salmon_indexed, by:0).view()
    //trimmed1.combine(salmon_indexed, by:0).view()

    output:
    file("${species}_${sid}_salmon_out") into salmon_quant1

    script:

    """
    #!/bin/bash
    source /usr/local/extras/Genomics/.bashrc
    source activate salmon
    salmon quant -i ${species}_index -l A -1 ${species}_${sid}_forward_paired.fastq.gz -2 ${species}_${sid}_reverse_paired.fastq.gz --validateMappings -o ${species}_${sid}_salmon_out --gcBias --seqBias
    """

}


ortho_cds = Channel.fromPath(params.cds)
	
process ortho_finder {
  
   publishDir 'OrthoFinder', mode: 'copy', overwrite: true, pattern: 'OrthoFinder'

   input:
   file(cds) from ortho_cds

   output:
   file("OrthoFinder") into ortho

   script:
   """
   #!/bin/bash
   source /usr/local/extras/Genomics/.bashrc
   
   mkdir cds_new
   cp ${cds}/* cds_new
   gunzip cds_new/*
   #~/software/OrthoFinder/orthofinder -f cds_new -d 
   source activate orthofinder
   orthofinder -f cds_new -d
   mv cds_new/OrthoFinder . 
   """

}


