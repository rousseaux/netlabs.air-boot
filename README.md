# [AirBoot](http://rousseaux.github.io/netlabs.air-boot)<br>
## Martin Kiewitz Boot Manager with on-the-fly partition detection<br>

AirBoot is currently in the <b>v1.1.1-testing</b> traject.<br>
During this traject the following things will get attention:<br>

o Fixing issues reported at [Netlabs Trac](http://trac.netlabs.org/air-boot/report/1)<br>
&nbsp;&nbsp;Especially issues involving removable media.<br>

o Replacing Open Watcom WMake with GNU Make<br>
&nbsp;&nbsp;Future AirBoot development will make use of [software-modeling](http://rdpe.github.io/ohm).<br>
&nbsp;&nbsp;Besides [Apache Ant](http://ant.apache.org), this software-modeling makes use of [GNU Make](http://www.gnu.org/software/make).<br>
&nbsp;&nbsp;Switching to GNU Make allows to adjust the build-system to prepare for the above.<br>

o Cleaning up documentation files<br>
&nbsp;&nbsp;Many text documents contain duplicate, incorrect or obsolete information.<br>
&nbsp;&nbsp;A cleanup will ensure a more up-to-date understanding of the current AirBoot<br>
&nbsp;&nbsp;and its development direction.<br>

o Removing obsolete source files<br>
&nbsp;&nbsp;There are sill some source files present which are not in use anymore.<br>
&nbsp;&nbsp;This can be confusing to developers browsing them without finding any usage<br>
&nbsp;&nbsp;or references to these source files.<br>

o Removing the FX bling-bling from the build<br>
&nbsp;&nbsp;The FX bling-bling refers to the sliding window animations that can be enabled<br>
&nbsp;&nbsp;in the AirBoot Setup. While these animations are very cool to see, they eat up<br>
&nbsp;&nbsp;precious code space that is needed to enhance the handling of removable media.<br>
&nbsp;&nbsp;Note that the animations will only be removed from the builds; their sources<br>
&nbsp;&nbsp;will remain available.<br>

The main repository for AirBoot development is at GitHub:<br>

project portal&nbsp;: [http://rousseaux.github.io/netlabs.air-boot](http://rousseaux.github.io/netlabs.air-boot)<br>
repository&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: [http://github.com/rousseaux/netlabs.air-boot](http://github.com/rousseaux/netlabs.air-boot)<br>
releases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: [http://github.com/rousseaux/netlabs.air-boot/releases](http://github.com/rousseaux/netlabs.air-boot/releases)<br>

Periodically, the above AirBoot GitHub repos will be synced to: [AirBoot at Netlabs](http://trac.netlabs.org/air-boot).<br>

After the v1.1.1-testing traject, <b>AirBoot v1.1.2</b> will be released.<br>
