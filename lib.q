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
 delim: ",";
 columns: `$delim vs contents[0];
 type_cols: {[x;delim;idx] .ut.inferType 1_(vs[delim;] each x)[::;idx]}[contents;delim;] each til count[columns];
 type_cols: value (columns!type_cols) ^ types_arg;
 t: (TYPE_TO_STR_DICT[type_cols]; enlist(",")) 0: fname;
 :t
 }

// USAGE
// fname: `:univ.csv;
// delim: ","
// type_or: `local_time`exchange_time!`symbol`symbol;
// t: .qt.read_csv [`:univ.csv; ","; type_or]

