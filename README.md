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
main Mac, and specifically select in the View menu to view the
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

The use is a bit too complicated, but see the next section.

Security aspects
----------------

I suspect that the use of FluffyDisplay can't be made much simpler or
automated while still being able to run FluffyDisplay as a sandboxed
app. (With automating, I mean that you wouldn't need to start Screen
Sharing manually and select the right display to view in Screen
Sharing, but that it would happen automatically.)

Sandboxing and notarization is something I definitely want to keep.
End-users should not run random non-sandboxed apps downloaded from the
Internet, period. I don't trust such apps, and it would be rude to
expect people who download an ready-built FluffyDisplay app in the
future to trust it.

As this is open source, I can't prevent a third party from taking this
code (or just taking inspiration) and producing something similar.
After all, I wrote this in a weekend, somebody else can do it too.
That might then be distributed as a non-sandboxed app that works in a
much more automated fashion. But end-users should then be aware that
such an app could potentially be a very large security risk. When I
start distributing a ready-built app, it will be digitally signed,
securely timestamped, notarized, and run sandboxed.

Will it work on macOS 11?
-------------------------

I don't know. Quite possibly not, in which case this has been just an
interesting experiment with little permanent usefulness.


What if Apple at some stage starts providing the same functionality
-------------------------------------------------------------------

(In the same way as Sidecar works for an iPad.) I would welcome that
very much.

Will there be binaries?
-----------------------

Sure, once my dog-fooding is complete. Also, see the security points
above.


In the Mac App Store?
---------------------

No way. It uses undocumented CoreGraphics APIs and requires the
com.apple.security.temporary-exception.mach-lookup.global-name
entitlement.

If you find this useful
-----------------------

If you find FluffyDisplay useful, and want to thank me in some way,
feel free to contact me and I can send an invoice. Or point you to a
charity of my choice.
