\c 1000 1000

.ut._is_bool: {any x ~/:y}

.ut.inferType:{
 c: x where {count[x] > 0} each x;
 if[count[c]=0; :`symbol];
 if[all not null "I"$'c; :`int];
 if[all not null "F"$'c; :`float];
 if[all not null "D"$'c; :`date];
 if[all not null "T"$'c; :`time];
 if[all not null "P"$'c; :`timestamp];
 if[all c .ut._is_bool\: ("1";"0"); `boolean];
 :`symbol
 };

.qt.read_csv: {
 [fname; delim; types_arg]
 TYPE_TO_STR_DICT: `boolean`int`float`date`time`timestamp`symbol!("BIFDTPS");
 contents: read0 fname;
 columns: `$delim vs contents[0];
 type_cols: {[x;delim;idx] .ut.inferType 1_(vs[delim;] each x)[::;idx]}[contents;delim;] each til count[columns];
 type_cols: ((columns!type_cols) ^ types_arg)columns;
 t: (TYPE_TO_STR_DICT[type_cols]; enlist(",")) 0: fname;
 :t
 }

// USAGE
// fname: `:univ.csv;
// delim: ","
// type_or: `local_time`exchange_time!`symbol`symbol;
// t: .qt.read_csv [`:univ.csv; ","; type_or]

\c 30 200
tidy:{ssr/[;("\"~~";"~~\"");("";"")] $[","=first x;1_x;x]}
strBrk:{y,(";" sv x),z}

//replace k representation with equivalent q keyword
kreplace:{[x] $[`=qval:.q?x;x;"~~",string[qval],"~~"]}
funcK:{$[0=t:type x;.z.s each x;t<100h;x;kreplace x]}

//replace eg ,`FD`ABC`DEF with "enlist`FD`ABC`DEF"
ereplace:{"~~enlist",(.Q.s1 first x),"~~"}
ereptest:{(1=count x) and ((0=type x) and 11=type first x) or 11=type x}
funcEn:{$[ereptest x;ereplace x;0=type x;.z.s each x;x]}

basic:{tidy .Q.s1 funcK funcEn x}

addbraks:{"(",x,")"}

//Where clause needs to be a list of Where clauses,
//so if only one Where clause, need to enlist.
stringify:{$[(0=type x) and 1=count x;"enlist ";""],basic x}

//if a dictionary, apply to both keys and values
ab:{
  $[(0=count x) or -1=type x; .Q.s1 x;
    99=type x; (addbraks stringify key x ),"!",stringify value x;
    stringify x] }

inner:{[x]
  idxs:2 3 4 5 6 inter ainds:til count x;
  x:@[x;idxs;'[ab;eval]];
  if[6 in idxs;x[6]:ssr/[;("hopen";"hclose");("iasc";"idesc")] x[6]];
  //for select statements within select statements
  x[1]:$[-11=type x 1;x 1;[idxs,:1;.z.s x 1]];
  x:@[x;ainds except idxs;string];
  x[0],strBrk[1_x;"[";"]"] }

buildQuery:{inner parse x}