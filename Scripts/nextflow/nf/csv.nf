csv_ch=channel
    .fromPath('meta_data.csv')
    .splitCsv()


process test{
   tag {del}
   
   input:
   file(csv) from csv_ch

   script:
   """
   cat $csv
   """
}
