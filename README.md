FluffyDisplay: Manage virtual displays on your Mac
==================================================

Typical use case
----------------

You have a "leftover" old Mac that you want to use as an additional
display for your current main Mac.

It is an oldish iMac that as such still has a very nice display but it
is underpowered for your actual work, and you have a newer iMac, or
MacBook, that you do your work on. You want to use the old iMac as a
display for your main Mac. You can use FluffyDisplay for that.

You set up the old iMac so that it is right on either side of your
main Mac's display.

You start FluffyDisplay. It appears as an icon in the menu bar. You
use it to create a "virtual" monitor on your main Mac.

In System Preferences -> Displays, arrange the displays so that the
virtual one is on the side of the built-in display where you put your
old iMac.

You then use Screen Sharing app on the other Mac to connect to your
main Mac, and specifically select to in the View menu to view the
"virtual" monitor. You switch Screen Sharing to observation mode and
to full-screen. You then don't need to touch the mouse, trackpad or
keyboard on the other Mac until you want to close the connection.

Not useful use case
-------------------

The performance of Screen Sharing is probably not good enough to let
you view videos in high quality, sorry. If that is what you want to
do, just view them on the other Mac locally.

Problems and future work
------------------------

Even if you move the cursor of the main Mac off the virtual display
(that is showing in Screen Sharing on the other Mac), there is still a
"ghost" cursor moving in the Screen Sharing window. That is highly
irritating and misleading.

The use is a bit too complicated. It needs to be made much simpler
before actual end-users will be able to use it. One way that I have
already started on is to require running FluffyDisplay on both the
Macs. There already is code that advertises (in DNS-SD TXT records) to
FluffyDisplay apps running on other Macs in the local net what
displays are available on their Mac, and that is used by FluffyDisplay
apps running on other Macs to generate a menu of suitable resolutions.

But what is missing is code to tell FluffyDisplay on the other Mac to
start Screen Sharing. Passing the right display to use can be handled
by writing a .vncloc file and opening that using NSWorkSpace's
open(_:configuration:completionHandler:) method but I don't know how
to force Screen Sharing into full-screen mode.

Will there be binaries?
-----------------------

Sure, once my dog-fooding is complete.


If you find this useful
-----------------------

If you find FluffyDisplay useful, and want to thank me in some way,
feel free to contact me and I can send an invoice. Or point you to a
charity of my choice.
