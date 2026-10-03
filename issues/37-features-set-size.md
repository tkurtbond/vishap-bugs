# Features.md says SET has 64 bits under -OC

*This report was prepared with the help of AI (Claude, by Anthropic).*

`doc/Features.md`'s table of sizes says `SET` has 64 bits under `-OC`. Since
commit 7f4b284a ("Correct set size in component pascal compatability mode",
2019) it has 32 bits under both size models (`OPM.Mod`: `SetSize := 4`);
`SYSTEM.SET64` is the 64-bit set.

## Fix

The fix is `patches/0037-Features.md-SET-has-32-bits-under-OC-too.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
