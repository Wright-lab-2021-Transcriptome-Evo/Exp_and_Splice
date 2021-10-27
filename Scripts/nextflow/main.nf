reads_ch = Channel.fromFilePairs('reads/*{1,2}.fastq.gz')
params.adapter = 'adapters.fa'
adapter=file(params.adapter)
metadata=file('meta_data.csv')
gens_ch=Channel.fromPath('genomes/*.gz')


csv_ch=channel
    .fromPath('meta_data.csv')
    .splitCsv()
    .map {row ->tuple(row[0],row[2])}
    .view()


process salmon_index {
   //conda 'bioconda::salmon' 


   publishDir 'salmon_index', mode: 'copy', overwrite: true, pattern: '*index*'
	      
   input:
   file(cds) from gens_ch

   output:
   tuple val(species), file("${species}_index") into salmon_indexed

   script:
   species=cds.baseName.replace(".gz","").replace(".fa","").replace(".cds","")
   species
   """
   #!/bin/bash
   source /usr/local/extras/Genomics/.bashrc
   source activate salmon
   salmon index -t $cds -i ${species}_index
   """	

} 
 
ref_ch=channel
    .fromPath('meta_data.csv')
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



