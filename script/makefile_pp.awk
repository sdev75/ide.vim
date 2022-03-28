{
  if ($1 == "#") {
      filename = substr($3, 2, length($3)-2);
      if (index(filename,"/usr/")){
        skip=1;
      }else {
        skip=0;
      }
    next;
  }

  if (skip == 1) next;
  print $0
}
