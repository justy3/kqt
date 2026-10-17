unixDate:{[dts] (prd 60 60 24)*dts-1970.01.01};

getHist:{[ticker; sdt; edt]
  tmpl:"https://query1.finance.yahoo.com/v8/finance/chart/",
    "%tick?period1=%sdt&period2=%edt&interval=1d";
  args:enlist[ticker],string unixDate sdt,edt;
  url:ssr/[tmpl; ("%tick";"%sdt";"%edt"); args];
  / raw:system "wget -q -O - ",url;
  raw:system "curl -s '",url,"' -H 'User-Agent: Mozilla/5.0'";
  .g.raw: raw;
  show raw;
  t:("DFFFFJF"; enlist ",") 0: raw;
  `Date xasc `Date`Open`High`Low`Close`Volume`AdjClose xcol t}

getData:{[ticker; sdt] select Date,Close from getHist[ticker;"D"$sdt;.z.D]}
getData2: {[ticker; sdt] t: ("DFFFFFJ"; enlist ",") 0: `:AAPL.csv; :t}
.z.ws:{
	show ".z.ws called";
  args:(-9!x) `payload;
  neg[.z.w] -8!(enlist `hist)!enlist .[getData2; args; `err]}