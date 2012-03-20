$NetBSD$

--- lib/dtrace/examples/dist.d.orig	2012-01-18 20:28:57.122586165 +0000
+++ lib/dtrace/examples/dist.d
@@ -0,0 +1,63 @@
+/* example usage: dtrace -q -s /path/to/dist.d */
+/*
+ * %CopyrightBegin%
+ * 
+ * Copyright Scott Lystig Fritchie 2011. All Rights Reserved.
+ * 
+ * The contents of this file are subject to the Erlang Public License,
+ * Version 1.1, (the "License"); you may not use this file except in
+ * compliance with the License. You should have received a copy of the
+ * Erlang Public License along with this software. If not, it can be
+ * retrieved online at http://www.erlang.org/.
+ * 
+ * Software distributed under the License is distributed on an "AS IS"
+ * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
+ * the License for the specific language governing rights and limitations
+ * under the License.
+ * 
+ * %CopyrightEnd%
+ */
+
+erlang*:::dist-monitor
+{
+    printf("monitor: pid %d, who %s, what %s, node %s, type %s, reason %s\n",
+           pid,
+           copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), copyinstr(arg3),
+           copyinstr(arg4));
+}
+
+erlang*:::dist-port_busy
+{
+    printf("dist port_busy: node %s, port %s, remote_node %s, blocked pid %s\n",
+           copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), copyinstr(arg3));
+    /*
+     * For variable use advice, see:
+     *    http://dtrace.org/blogs/brendan/2011/11/25/dtrace-variable-types/
+     *
+     * Howevever, it's quite possible for the blocked events to span
+     * threads, so we'll use globals.
+     */
+    blocked_procs[copyinstr(arg3)] = timestamp;
+}
+
+erlang*:::dist-output
+{
+    printf("dist output: node %s, port %s, remote_node %s bytes %d\n",
+           copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), arg3);
+}
+
+erlang*:::dist-outputv
+{
+    printf("port outputv: node %s, port %s, remote_node %s bytes %d\n",
+           copyinstr(arg0), copyinstr(arg1), copyinstr(arg2), arg3);
+}
+
+erlang*:::process-scheduled
+/blocked_procs[copyinstr(arg0)]/
+{
+    pidstr = copyinstr(arg0);
+    printf("blocked pid %s scheduled now, waited %d microseconds\n",
+           pidstr, (timestamp - blocked_procs[pidstr]) / 1000);
+    blocked_procs[pidstr] = 0;
+}
+
