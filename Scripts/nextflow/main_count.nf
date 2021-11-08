reads_ch = Channel.fromFilePairs(params.reads + '/**/*{1,2}.fastq.gz')
reads_ch2 = Channel.fromPath(params.reads + '/**/*.fastq.gz')
meta_path = Channel.fromPath(params.metadata)
adapter=file(params.adapter)
metadata=file(params.metadata)


cdna_ch=Channel.fromPath(params.cdna + '/*.gz')
cds_ch=Channel.fromPath(params.cds + '/*.gz')



process salmon_index {
   //conda 'bioconda::salmon' 

   tag {'salmon_index_' + species }

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
 

process trim {

    cpus = 4
    memory = '8 GB'
    time = '2h'
    
    tag {'trim_' + species + '_' + sid }


    //publishDir 'paired', mode: 'copy', overwrite: true, pattern: '*paired*'

    input:
    tuple val(sid), file(reads), val(species) from reads_ch.combine(ref_ch, by:0)

    output:
    tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz") into trimmed1
    tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz") into trimmed2
    file("${species}_${sid}_counts.txt") into merge

    script:

    """
    #!/bin/bash
    source /usr/local/extras/Genomics/.bashrc
    trimmomatic PE -phred33 $reads ${species}_${sid}_forward_paired.fastq.gz ${sid}_forward_unpaired.fastq.gz ${species}_${sid}_reverse_paired.fastq.gz ${sid}_reverse_unpaired.fastq.gz ILLUMINACLIP:$adapter:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95
    echo \$(echo \$(zcat ${species}_${sid}_forward_paired.fastq.gz|wc -l)/4|bc) ${species} ${sid} >> ${species}_${sid}_counts.txt
    """
}


process merge {
    input:
    file(counts) from merge.collect()

    output:
    file('transform_data.csv') into transform_level

    script:
    """
    #!/bin/bash
    source /usr/local/extras/Genomics/.bashrc
    cat *.txt >> comp_read_counts.csv
    transform.R comp_read_counts.csv  
    """
}


process seqtk {
       
    tag {'seqtk_' + species + '_' + sid }
    
    cpus = 2
    memory = '4 GB'
    time = '2h'
   
    input:
    tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz") from trimmed2
    file('transform_data.csv') from transform_level

    output: 
    tuple val(species), val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz") into post_seqtk


    script:
    """
    #!/bin/bash
    source /usr/local/extras/Genomics/.bashrc
    source activate seqtk     

    q=\$(to_seqtk_or_not.R transform_data.csv $sid)
    if [ \$q -gt 0 ]; then
	echo 'running seqtk'
	ss=\$(subsamp.R transform_data.csv $sid)
	cp ${species}_${sid}_forward_paired.fastq.gz ./sf.fastq.gz
	cp ${species}_${sid}_reverse_paired.fastq.gz ./sr.fastq.gz
	seqtk sample -s100 sf.fastq.gz \$ss > ${sid}_forward_paired.fastq
	seqtk sample -s100 sr.fastq.gz \$ss > ${sid}_reverse_paired.fastq
	echo 'zipping'
	gzip ${sid}_forward_paired.fastq
	gzip ${sid}_reverse_paired.fastq
    else
	mv ${species}_${sid}_forward_paired.fastq.gz ${sid}_forward_paired.fastq.gz
	mv ${species}_${sid}_reverse_paired.fastq.gz ${sid}_reverse_paired.fastq.gz
	echo 'no need to run seqtk just renaming'
    fi
    """

}

/*
process salmon_quant {
    //conda 'bioconda::salmon' 

    tag {'salmon_quant_' + species + '_' + sid }

    publishDir 'salmon_quant', mode: 'copy', overwrite: true, pattern: '*salmon_out'

    input:
    //tuple val(species), val(sid), file("${species}_${sid}_forward_paired.fastq.gz"), file("${species}_${sid}_reverse_paired.fastq.gz"), file("${species}_index") from trimmed1.combine(salmon_indexed, by:0).view()
    tuple val(species), val(sid), file("${sid}_forward_paired.fastq.gz"), file("${sid}_reverse_paired.fastq.gz"), file("${species}_index") from post_seqtk.combine(salmon_indexed, by:0)   

    output:
    file("${species}_${sid}_salmon_out") into salmon_quant1

    script:

    """
    #!/bin/bash
    source /usr/local/extras/Genomics/.bashrc
    source activate salmon
    salmon quant -i ${species}_index -l A -1 ${sid}_forward_paired.fastq.gz -2 ${sid}_reverse_paired.fastq.gz --validateMappings -o ${species}_${sid}_salmon_out --gcBias --seqBias
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
   orthofinder -f cds_new -d -og
   mv cds_new/OrthoFinder . 
   """

}



*/
