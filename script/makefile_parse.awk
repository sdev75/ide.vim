BEGIN { ORS="\n"; }
{
  for (i=0; i<NF,i++) {
    if ($i ~/^\-I/) print substr($i,3)
  }
}
