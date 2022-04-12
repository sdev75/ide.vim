BEGIN {
  ignore_dirs[1] = "/usr/include"
  ignore_dirs[2] = "/usr/lib"
}
{
  if ($1 == "#") {
    skip = 0
    filename = substr($3, 2, length($3)-2);
    
    for (idx in ignore_dirs) {
      if (index(filename, ignore_dirs[idx])){
        skip = 1;
        break;
      }
    }
    next;
  }
  if (skip == 1) next;
  print $0
}
