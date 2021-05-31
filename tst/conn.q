\q -p 5000
\sleep 1
\curl --location --remote-name https://github.com/dflynch/kdb-log/archive/refs/tags/v1.0.0.zip && unzip v1.0.0.zip && rm v1.0.0.zip && mv kdb-log-1.0.0 tst
\curl --location --remote-name https://github.com/dflynch/kdb-cron/archive/refs/tags/v1.0.0.zip && unzip v1.0.0.zip && rm v1.0.0.zip && mv kdb-cron-1.0.0 tst
\l tst/kdb-log-1.0.0/src/log.q 
\l tst/kdb-cron-1.0.0/src/cron.q 
\l src/conn.q
.z.ts:.cron.ts
.z.pc:.conn.pc
ccb:{x"c+::1"}  / connect call-back
dcb:{c+::1}     / disconnect call-back

assert:{if[not x~y;'`$"expecting '",(-3!x),"' but found '",(-3!y),"'"]}

.conn.open[5000;`h;::;::]               / port no. without call-back
.conn.open[`::5000;`i;ccb;dcb]          / file handle with call-back passed by value
.conn.open[(`::5000;2000);`j;`ccb;`dcb] / file handle with timout and call-back passed by name
.z.ts 0Wp-1;                            / force connection attempts

assert[4]count .conn.tab  / entries for three connections (plus guard row)
assert[2]h"c"             / 'h' is a viable handle and the connect call-back counter is two
assert[2]i"c"             / 'i' is a viable handle
assert[2]j"c"             / 'j' is a viable handle
.z.pc each(h;i;j);        / simulate port close events (hclose run locally does not trigger .z.pc)
assert[2]c                / disconnect call-back counter is two
.z.ts 0Wp-1;              / force reconnection attempts
assert[4]h"c"             / 'h' is re-established and the connect call-back counter if four
assert[4]i"c"             / 'i' is re-established
assert[4]j"c"             / 'j' is re-established

neg[h]"exit 0";neg[h][]
\rm -r tst/kdb-log-1.0.0
\rm -r tst/kdb-cron-1.0.0
\\
