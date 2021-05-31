\d .conn

tab:1!enlist`h`addr`name`open`close!(0Ni;();`;();())    / accept port no. or file handle, symbolic name or value, guard against type matching

open:{[a;n;o;c]                                         / (a)ddr, (n)ame, (o)pen, (c)lose
  if[n in exec name from tab;'`name];                   / ensure uniqueness
  .cron.add[(`.conn.ts;(a;n;o;c);.z.P);.z.P+00:00:01];  / schedule connection
  }

ts:{if[10h=type e:try x;.log.warn(.Q.s1 x 1)," ",e;:z-y]}         / attempt connection, backoff and retry if unsuccessful
try:{$[-6h=type h:@[hopen;x 0;::];.[init;(h;x);{hclose x;y}h];h]} / open and initialize, use prot. evaluation to ensure tidy-up and retry
init:{eval(y 2),x;(y 1)set x;tab[x]:y}                            / evaluate call-back, assign symbolic name and store connection details

pc:{
  if[x in key tab;          / if a managed connection disconnects...
    d:tab x;                  / grab connection details
    .[`.;();_;d`name];        / unset symbolic name
    .[`.conn.tab;();_;x];     / remove connection
    @[eval;(d`close),x;0N!];  / evaluate call-back
    open . value d];          / schedule reconnection
  }

\
Usage:

  Lightweight connection manager featuring reconnect logic with expontential backoff 
  and connect call-back functionality.

  Assign .conn.pc to .z.pc and initalize cron.

  q)ccb:{x(`.u.sub;`trade;`AAPL`MSFT)}  / connect call-back: subscribe to feed
  q)dcb:{-25!(clients;(.u.down;.z.P)}   / disconnect call-back: inform clients of downtime
  q).conn.open[5000;`h;`ccb;`dcc]       / open managed connection 
  q)h"2+2"                              / communicate using symbolic name
  4

Require:

  log.q
  cron.q
