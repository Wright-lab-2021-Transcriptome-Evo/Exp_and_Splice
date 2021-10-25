reads_ch = Channel.fromFilePairs('trimm_reads/*{1,2}.fastq.gz')
params.adapter = 'adapters.fa'
adapter=file(params.adapter)

process trim {

    publishDir 'paired', mode: 'copy', overwrite: true, pattern: '*paired*'

    input:
    tuple val(sid), file(reads) from reads_ch

    output:
    file '*paired*' into trimmed

    script:

    """
    #!/bin/bash
    //source /usr/local/extras/Genomics/.bashrc
    trimmomatic PE -phred33 $reads ${sid}_forward_paired.fastq.gz ${sid}_forward_unpaired.fastq.gz ${sid}_reverse_paired.fastq.gz ${sid}_reverse_unpaired.fastq.gz ILLUMINACLIP:$adapter:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95
    """
}
