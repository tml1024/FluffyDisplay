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
main Mac, and specifically select in Screen Sharing's View menu to
view the "virtual" monitor. You switch Screen Sharing to observation
mode and to full-screen. You then don't need to touch the mouse,
trackpad or keyboard on the other Mac until you want to close the
connection. (Or until the other Mac starts its screen saver.)

You can also run FluffyDisplay also on the other Mac. In that case the
main Mac notices that and automatically adds a menu "New on peer"
(suggestions for better but still short name welcome) under which will
appear the displays of other Macs running FluffyDisplay. When you
choose one of those, FluffyDisplay on that other Mac will
automatically start ScreenSharing to connect to your main Mac.

You will still have to switch to observation mode and to full-screen,
etc, this is not (and can not be) fully automated. It would be lovely
if Screen Sharing could be passed query parameters in the vnc: URL
that would tell it which display to show, to switch to observation
mode, and to full-screen. But apparently no. Having those settings in
a .vncloc file doesn't seem to work either.


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
more automated while still being able to run FluffyDisplay as a
sandboxed app.

Sandboxing and notarization is something I definitely want to keep.
End-users should not run random non-sandboxed apps downloaded from the
Internet, period. I don't trust such apps, and correspondingly, it
would be rude to expect people who download a ready-built
FluffyDisplay app to trust it.

As this is open source, I can't prevent a third party from taking this
code and producing something similar. That might then be distributed
as a non-sandboxed app that works in a much more automated fashion.
But end-users should then be aware that such an app could potentially
be a very large security risk. The FluffyDisplay.app released here
(inside the .zip archive(s) is digitally signed, securely timestamped,
notarized, and runs sandboxed.

Will this work on macOS 11?
---------------------------

I don't know. Quite possibly not, in which case this has been just an
interesting experiment with little permanent usefulness.


What if Apple at some stage starts providing the same functionality
-------------------------------------------------------------------

(In the same way as macOS has Sidecar, for using an iPad as a
secondary display.) I would welcome that very much. They would be able
to make the user experience much smoother than what this tool offers.

Will this be in the Mac App Store?
----------------------------------

No way. It uses undocumented CoreGraphics APIs and requires the
com.apple.security.temporary-exception.mach-lookup.global-name
entitlement.

If you find this useful
-----------------------

If you find FluffyDisplay useful, and want to thank me in some way,
feel free to contact me and I can send an invoice. Or point you to a
charity of my choice.
