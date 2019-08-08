CLargs<-commandArgs(TRUE);
input<-CLargs[1];
output<-CLargs[2];



#input = c("/fs/project/PCON0009/Au/dingjie-project/install/IDP_0.1.9/data/cell-0/F1_trim.sam");
#output = c("/fs/project/PCON0009/Au/dingjie-project/install/IDP_0.1.9/data/cell-0/F1_splicemap.sam");

con <- file(input,'r');
line=readLines(con,n=1);

line_s = strsplit(line,split="\t");
if(length(line)>0){
  if(length(line_s[[1]])<=6){
       sink(file=output,append=T);
       cat(line,seq='\n');
       sink();
  }else {
     #x <- grepl('S',line_s[[1]][6]);
     if(!grepl('S',line_s[[1]][6])){
            sink(file=output,append=T);
            cat(line,seq='\n');
            sink();
     }

  }
}


k=1;
while(length(line)!=0){

    print(k);
    line=readLines(con,n=1);

    line_s = strsplit(line,split="\t");
    if(length(line)>0){
       if(length(line_s[[1]])<=6){
          sink(file=output,append=T);
          cat(line,seq='\n');
          sink();
       }else {
          line_s = strsplit(line,split="\t");
          #x <- grepl('S',line_s[[1]][6]);
          if(!grepl('S',line_s[[1]][6])){
              sink(file=output,append=T);
              cat(line,seq='\n');
              sink();
         }

      }
    }

    k = k + 1;
}

close(con)
