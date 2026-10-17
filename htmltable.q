/ Lightweight HTML table output for JupyterQ.
/ Loading this file installs a reversible .qpk.mime wrapper so that a table
/ used as the final expression in a cell is rendered automatically.

if[not `mime in key `.qpk;'"htmltable.q requires JupyterQ (.qpk.mime not found)"];

/ Preserve configuration and the true JupyterQ formatter across script reloads.
/ A negative maxRows follows the current first value of \c; zero is unlimited.
if[not `cfg in key `.jqtbl;
  .jqtbl.cfg:`maxRows`maxCols`maxHeight!(-1;0;420)];
/ Migrate a running session back to following its current q console row limit.
if[not `cfgVersion in key `.jqtbl;.jqtbl.cfgVersion:0];
if[3>.jqtbl.cfgVersion;
  .jqtbl.cfg:`maxRows`maxCols`maxHeight!(-1;0;420);
  .jqtbl.cfgVersion:3];
if[not `originalMime in key `.jqtbl;
  .jqtbl.originalMime:.qpk.mime];

.jqtbl.css:"\n" sv (
  ".jqtbl-wrap{--jqtbl-bg:#ffffff;--jqtbl-border:#9ca3af;--jqtbl-grid:#d1d5db;--jqtbl-head-bg:#0068a8;--jqtbl-head-fg:#ffffff;--jqtbl-key-head:#004b7a;--jqtbl-odd:#111827;--jqtbl-even:#6b7280;--jqtbl-alt:#f3f4f6;--jqtbl-key-bg:#dbeafe;--jqtbl-key-fg:#075985;position:relative;max-width:100%;overflow-x:auto!important;overflow-y:auto!important;border:1px solid var(--jqtbl-border);border-radius:4px;background:var(--jqtbl-bg);isolation:isolate;color-scheme:light dark;}";
  "@media (prefers-color-scheme:dark){.jqtbl-wrap{--jqtbl-bg:#050505;--jqtbl-border:#454545;--jqtbl-grid:#2b2b2b;--jqtbl-head-bg:#064b76;--jqtbl-head-fg:#ff9f1c;--jqtbl-key-head:#0877a8;--jqtbl-odd:#f8fafc;--jqtbl-even:#ff9f1c;--jqtbl-alt:#111111;--jqtbl-key-bg:#082f49;--jqtbl-key-fg:#38bdf8;}}";
  ".vscode-dark .jqtbl-wrap,.jp-mod-theme-dark .jqtbl-wrap{--jqtbl-bg:#050505;--jqtbl-border:#454545;--jqtbl-grid:#2b2b2b;--jqtbl-head-bg:#064b76;--jqtbl-head-fg:#ff9f1c;--jqtbl-key-head:#0877a8;--jqtbl-odd:#f8fafc;--jqtbl-even:#ff9f1c;--jqtbl-alt:#111111;--jqtbl-key-bg:#082f49;--jqtbl-key-fg:#38bdf8;}";
  ".jqtbl-table{position:relative;overflow:visible!important;border-collapse:separate!important;border-spacing:0;max-width:none!important;table-layout:fixed!important;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:12px;background:var(--jqtbl-bg);}";
  ".jqtbl-table th,.jqtbl-table td{box-sizing:border-box;padding:5px 8px;border-right:1px solid var(--jqtbl-grid);border-bottom:1px solid var(--jqtbl-grid);text-align:left;white-space:nowrap;vertical-align:top;overflow:visible;}";
  ".jqtbl-table thead{position:sticky!important;top:0!important;z-index:20!important;background:var(--jqtbl-head-bg);}";
  ".jqtbl-table thead th{position:sticky!important;top:0!important;z-index:21!important;background:var(--jqtbl-head-bg)!important;color:var(--jqtbl-head-fg)!important;background-clip:padding-box;font-weight:600;border-top:0;}";
  ".jqtbl-table thead th.jqtbl_key{background:var(--jqtbl-key-head)!important;}";
  ".jqtbl-table tbody td:nth-child(odd){color:var(--jqtbl-odd);}";
  ".jqtbl-table tbody td:nth-child(even){color:var(--jqtbl-even);}";
  ".jqtbl-table td.jqtbl_key{background:var(--jqtbl-key-bg)!important;color:var(--jqtbl-key-fg)!important;}";
  ".jqtbl-table tbody tr:nth-child(even) td:not(.jqtbl_key){background:var(--jqtbl-alt);}";
  ".jqtbl-table th:last-child,.jqtbl-table td:last-child{border-right:0;}"
  );

.jqtbl.attrs:{[className](enlist `class)!enlist className};

/ Escape text after q has formatted a value. This keeps table contents data,
/ rather than allowing symbols, strings, or general-list values to inject HTML.
.jqtbl.escape:{[s]
  s:ssr[s;"&";"&amp;"];
  s:ssr[s;"<";"&lt;"];
  s:ssr[s;">";"&gt;"];
  s:ssr[s;"\"";"&quot;"];
  ssr[s;"'";"&#39;"]
  };

.jqtbl.text:{[x]
  s:.Q.s x;
  $[10h=type s;s;" " sv s]
  };

.jqtbl.isKeyedTable:{[x]
  $[99h<>type x;0b;
    98h<>type key x;0b;
    98h=type value x]
  };

.jqtbl.isTable:{[x]
  $[98h=type x;1b;.jqtbl.isKeyedTable x]
  };

.jqtbl.headerCell:{[className;column]
  attrs:`class`style!(className;"position:sticky;top:0;z-index:21;background-clip:padding-box");
  .qpk.hg.th[attrs;.jqtbl.escape string column]
  };

.jqtbl.dataCell:{[className;cell]
  .qpk.hg.td[.jqtbl.attrs className;.jqtbl.escape .jqtbl.text cell]
  };

.jqtbl.row:{[classes;row]
  .qpk.hg.tr raze .jqtbl.dataCell'[classes;value row]
  };

/ Width in monospace character cells, including horizontal padding.
.jqtbl.columnWidth:{[columnName;columnValues]
  4+max count each (enlist string columnName),.jqtbl.text each columnValues
  };

.jqtbl.colTag:{[width]
  style:"width:",string[width],"ch;min-width:",string[width],"ch";
  .qpk.hg.col[(enlist `style)!enlist style]
  };

.jqtbl.buildTable:{[classes;columns;table]
  widths:.jqtbl.columnWidth'[columns;value flip table];
  totalWidth:$[count widths;sum widths;0];
  colgroup:.qpk.hg.colgroup $[count widths;raze .jqtbl.colTag each widths;""];
  headAttrs:(enlist `style)!enlist "position:sticky;top:0;z-index:20";
  header:.qpk.hg.thead[headAttrs;.qpk.hg.tr raze .jqtbl.headerCell'[classes;columns]];
  body:.qpk.hg.tbody $[count table;raze .jqtbl.row[classes;]each table;""];
  tableStyle:"position:relative;overflow:visible;border-collapse:separate;border-spacing:0;width:",
    string[totalWidth],"ch;max-width:none;table-layout:fixed";
  tableAttrs:`class`style!("jqtbl-table";tableStyle);
  .qpk.hg.table[tableAttrs;colgroup,header,body]
  };

.jqtbl.render:{[mrows;mcols;height;table]
  if[not .jqtbl.isTable table;'"type: only displays tables"];

  keyed:.jqtbl.isKeyedTable table;
  keyCount:$[keyed;count cols key table;0];
  unkeyed:0!table;
  sourceColumns:cols unkeyed;
  totalRows:count unkeyed;
  totalColumns:count sourceColumns;

  shownRows:$[mrows<=0;totalRows;mrows&totalRows];
  shownColumns:$[(mcols<=0)|mcols>=totalColumns;totalColumns;mcols];
  visibleColumns:shownColumns#sourceColumns;
  visibleKeyColumns:keyCount&shownColumns;
  classes:(visibleKeyColumns#enlist `jqtbl_key),(shownColumns-visibleKeyColumns)#enlist `jqtbl_value;
  visibleTable:shownRows sublist visibleColumns#unkeyed;

  tableHtml:.jqtbl.buildTable[classes;visibleColumns;visibleTable];
  wrapAttrs:`class`style!("jqtbl-wrap";"position:relative;max-width:100%;max-height:",string[height],"px;overflow-x:auto;overflow-y:auto;isolation:isolate");
  wrapped:.qpk.hg.div[wrapAttrs;tableHtml];

  (`..mime;
    (1#`$"text/html")!enlist .qpk.hg.style[.jqtbl.css],wrapped;
    ::)
  };

/ Backward-compatible explicit renderer. Height comes from the shared config.
.jqtbl.display:{[mrows;mcols;table]
  .jqtbl.render[mrows;mcols;.jqtbl.cfg`maxHeight;table]
  };
displayhtmltab:.jqtbl.display;

.jqtbl.configure:{[mrows;mcols;height]
  `.jqtbl.cfg set `maxRows`maxCols`maxHeight!(mrows;mcols;height);
  .jqtbl.cfg
  };

.jqtbl.consoleSize:{[]
  @[system;"c";{[e]25 80}]
  };

.jqtbl.renderConfigured:{[table]
  mrows:$[0>.jqtbl.cfg`maxRows;first .jqtbl.consoleSize[];.jqtbl.cfg`maxRows];
  .jqtbl.render[
    mrows;
    .jqtbl.cfg`maxCols;
    .jqtbl.cfg`maxHeight;
    table]
  };

/ Preserve explicit MIME bundles and delegate all non-tables unchanged.
/ Rendering is protected: an unexpected cell value falls back to text/plain.
.jqtbl.mime:{[x]
  if[`..mime~first x;:.jqtbl.originalMime x];
  if[not .jqtbl.isTable x;:.jqtbl.originalMime x];
  rendered:@[.jqtbl.renderConfigured;x;{[e]::}];
  $[rendered~(::);.jqtbl.originalMime x;.jqtbl.originalMime rendered]
  };

.jqtbl.install:{[]
  `.qpk.mime set .jqtbl.mime;
  1b
  };

.jqtbl.uninstall:{[]
  `.qpk.mime set .jqtbl.originalMime;
  0b
  };

.jqtbl.enabled:{[].qpk.mime~.jqtbl.mime};

/ Automatic table rendering is enabled when this script is loaded.
.jqtbl.install[];
