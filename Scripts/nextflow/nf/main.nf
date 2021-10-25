reads_ch = Channel.fromFilePairs('trimm_reads/*{1,2}.fastq.gz')
params.adapter = 'adapters.fa'
adapter=file(params.adapter)
metadata=file('meta_data.csv')
gens_ch=Channel.fromPath('genomes/*.gz')


csv_ch=channel
    .fromPath('meta_data.csv')
    .splitCsv()
    .map {row ->tuple(row[0],row[2])}
    .view()


process salmon_quant {
   //conda 'bioconda::salmon' 


   publishDir 'salmon', mode: 'copy', overwrite: true, pattern: '*index*'
	      
   input:
   file(genome) from gens_ch

   output:
   tuple val(genome), file("new_${genome}.cds.fa.gz") into salmon

   script:
   """
   #!/bin/bash
   #source activate salmon
   #salmon index -t $genome -i ${genome}_index
   mv $genome new_${genome}
   """	

} 
 

process trim {

    publishDir 'paired', mode: 'copy', overwrite: true, pattern: '*paired*'

    input:
    tuple val(sid), file(reads) from reads_ch

    output:
    tuple val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz") into trimmed1
    tuple val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz") into trimmed2


    script:

    """
    #!/bin/bash
    //source /usr/local/extras/Genomics/.bashrc
    trimmomatic PE -phred33 $reads ${sid}_forward_paired.fastq.gz ${sid}_forward_unpaired.fastq.gz ${sid}_reverse_paired.fastq.gz ${sid}_reverse_unpaired.fastq.gz ILLUMINACLIP:$adapter:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95
    """
}


process renamed {
    
    publishDir 'renamed', mode: 'copy', overwrite: true, pattern: '*paired*'

    input:
    tuple val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz"), val(Sex) from trimmed2.combine(csv_ch, by:0)
 
    output:
    tuple val(sid), val(Sex), file("${Sex}_${sid}_forward_paired.fastq.gz"), file("${Sex}_${sid}_reverse_paired.fastq.gz") into renamed

    script:

    """
    mv ${sid}_forward_paired.fastq.gz ${Sex}_${sid}_forward_paired.fastq.gz    
    mv ${sid}_reverse_paired.fastq.gz ${Sex}_${sid}_reverse_paired.fastq.gz

    """
}


ref_ch=channel
    .fromPath('meta_data.csv')
    .splitCsv()
    .map {row ->tuple(row[0],row[1])}
    .view()

process map {


    publishDir 'renamed', mode: 'copy', overwrite: true, pattern: '*paired*'

    input:
    tuple val(sid), val(Sex), file("${Sex}_${sid}_forward_paired.fastq.gz"), file("${Sex}_${sid}_reverse_paired.fastq.gz"), val(genome) from renamed.combine(ref_ch, by:0)
    tuple val(genome),file("new_${genome}.cds.fa.gz") from salmon
 

    script:

    """
    mv ${Sex}_${sid}_forward_paired.fastq.gz ${genome}_${Sex}_${sid}_forward_paired.fastq.gz
    mv ${Sex}_${sid}_reverse_paired.fastq.gz ${genome}_${Sex}_${sid}_reverse_paired.fastq.gz

    minimap2 -ax sr new_${genome}.cds.fa.gz ${genome}_${Sex}_${sid}_forward_paired.fastq.gz ${genome}_${Sex}_${sid}_reverse_paired.fastq.gz > ${genome}_${Sex}_${sid}.sam 
    """

}

