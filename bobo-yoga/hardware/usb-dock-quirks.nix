# USB quirks for the Lenovo ThinkPad Thunderbolt 3 Dock chain, plus a log of
# a second, unrelated dock/hub with a similar-looking symptom.
#
# STATUS: INCIDENT 1's kernel quirk is an unverified working hypothesis (see
# "Open questions" at the bottom of that section). INCIDENT 2 is log-only so
# far - no fix applied, see reasoning at the end of that section for why.
#
# ---------------------------------------------------------------------------
# INCIDENT 1 - Lenovo TBT3 dock: Realtek RTS5411 hub / Logitech receiver
# ---------------------------------------------------------------------------
# Written 2026-08-08 from /home/bobo/nixos/overlays/usb.log (journal dump of a
# suspend -> resume -> dock connect -> disconnect -> reconnect cycle).
#
# ---------------------------------------------------------------------------
# SYMPTOM
# ---------------------------------------------------------------------------
# On the FIRST dock connect after resume, the Logitech Unifying receiver
# (046d:c52b, MX Vertical mouse) enumerates but no input device appears.
# Unplugging and replugging the dock makes it work.
#
# ---------------------------------------------------------------------------
# TOPOLOGY
# ---------------------------------------------------------------------------
#   pcieport 0000:00:07.0
#     -> PCIe switch 8086:15ef
#       -> xhci_hcd 0000:03:00.0        (usb5 = HS, usb6 = SS)
#         -> 5-2      17ef:3080         Lenovo TBT3 dock hub (USB2 side)
#           -> 5-2.2    0bda:5411       Realtek RTS5411 "Generic USB2.1 Hub", 6 ports
#             -> 5-2.2.1  413c:1010     Dell USB 2.0 Hub [MTT]
#               -> 5-2.2.1.4 413c:2110  Dell Wired Multimedia Keyboard
#             -> 5-2.2.2  20b1:30a0     EDIFIER AIRPULSE A80
#             -> 5-2.2.3  046d:c52b     Logitech Unifying receiver   <-- the victim
#             -> 5-2.2.6  0bda:1100     Realtek
#
# ---------------------------------------------------------------------------
# EVIDENCE 1 - truncated config descriptor on the receiver (the failure)
# ---------------------------------------------------------------------------
# usb.log, first dock connect, 11:34:16:
#
#   usb 5-2.2.3: new full-speed USB device number 11 using xhci_hcd
#   usb 5-2.2.3: config index 0 descriptor too short (expected 84, got 63)
#   usb 5-2.2.3: config 1 contains an unexpected descriptor of type 0x1, skipping
#   usb 5-2.2.3: config 1 contains an unexpected descriptor of type 0x1, skipping
#   usb 5-2.2.3: config 1 has an invalid descriptor of length 0, skipping remainder of the config
#   usb 5-2.2.3: config 1 has 1 interface, different from the descriptor's value: 3
#   usb 5-2.2.3: config 1 interface 0 altsetting 0 endpoint 0x81 has invalid maxpacket 2056, setting to 64
#   usb 5-2.2.3: New USB device found, idVendor=046d, idProduct=c52b, bcdDevice=24.11
#   usb 5-2.2.3: Product: USB Receiver
#   usb 5-2.2.3: Manufacturer: Logitech
#   <-- and then NOTHING. No logitech-djreceiver bind, no input node.
#
# The GET_DESCRIPTOR(CONFIG) returned 63 of the expected 84 bytes. USB core
# parsed 1 of the 3 interfaces, so interface :1.2 (the HID/DJ interface) never
# existed, so logitech-djreceiver never bound, so there was no mouse.
#
# For contrast, the successful re-enumeration at 11:34:54 has no descriptor
# errors and immediately produces:
#
#   logitech-djreceiver 0003:046D:C52B.006E: hiddev99,hidraw10 ... on usb-0000:03:00.0-2.2.3/input2
#   input: Logitech MX Vertical as .../0003:046D:407B.006F/input/input116
#   logitech-hidpp-device 0003:046D:407B.006F: HID++ 4.5 device connected.
#
# Ruled out: usbguard (module is commented out in configuration.nix), keyd
# (it logs "ignoring" lines for the devices it skips - there is no such line
# for the receiver), udev. There is simply no bind event to reject.
#
# ---------------------------------------------------------------------------
# EVIDENCE 2 - the parent hub's OWN descriptor is also corrupt
# ---------------------------------------------------------------------------
# Same hub, two enumerations, two different vendor IDs:
#
#   11:34:16 (failing run):    usb 5-2.2: New USB device found, idVendor=0bda, idProduct=5411, bcdDevice= 1.40
#   11:34:52 (succeeding run): usb 5-2.2: New USB device found, idVendor=0b00, idProduct=5411, bcdDevice= 1.40
#
# Both report Product "USB2.1 Hub", Manufacturer "Generic", 6 ports, same
# bcdDevice. 0x0b00 is not a registered vendor ID - byte 8 of the 18-byte
# device descriptor came back as 0x00 instead of 0xda.
#
# This matters: usb_get_device_descriptor() only accepts a full 18 bytes
# (otherwise -EMSGSIZE), so this was NOT a short read - it was corrupt payload.
# So the problem is not purely "the receiver is a slow full-speed device".
# Descriptor traffic through this dock chain is unreliable for more than one
# device. That is why the hub gets a quirk too, not just the receiver.
#
# ---------------------------------------------------------------------------
# WHY THE KERNEL DOES NOT JUST RETRY
# ---------------------------------------------------------------------------
# drivers/usb/core/message.c, usb_get_descriptor():
#
#   for (i = 0; i < 3; ++i) {
#           /* retry on length 0 or error; some devices are flakey */
#           result = usb_control_msg(...);
#           if (result <= 0 && result != -ETIMEDOUT)
#                   continue;
#           ...
#           break;
#   }
#
# 63 is not <= 0, so it breaks out on the first attempt and the truncated
# buffer is parsed as-is.
#
# ---------------------------------------------------------------------------
# WHAT THE CHOSEN FLAGS ACTUALLY DO  (kernel 6.x/7.x, verified in-tree)
# ---------------------------------------------------------------------------
# Letter mapping is defined in drivers/usb/core/quirks.c, quirks_param_set()
# and documented in Documentation/admin-guide/kernel-parameters.txt under
# "usbcore.quirks=" (format VendorID:ProductID:Flags, entries comma separated).
#
#  g = USB_QUIRK_DELAY_INIT       - PER-DEVICE. drivers/usb/core/config.c:
#        if (dev->quirks & USB_QUIRK_DELAY_INIT)
#                msleep(200);
#        result = usb_get_descriptor(dev, USB_DT_CONFIG, cfgno, bigbuffer, length);
#      i.e. a 200 ms pause immediately before the exact fetch that came back
#      short above. Also drivers/usb/core/hub.c hub_port_connect():
#        if (udev->quirks & USB_QUIRK_DELAY_INIT) msleep(2000);
#
#  n = USB_QUIRK_DELAY_CTRL_MSG   - PER-DEVICE. drivers/usb/core/message.c,
#      end of usb_control_msg():
#        /* Linger a bit, prior to the next control message. */
#        if (dev->quirks & USB_QUIRK_DELAY_CTRL_MSG) msleep(200);
#
#  o = USB_QUIRK_HUB_SLOW_RESET   - the ONLY quirk keyed on the PARENT hub,
#      i.e. the only one that changes behaviour for devices *below* it.
#      drivers/usb/core/hub.c, hub_port_reset():
#        /* Hub needs extra delay after resetting its port. */
#        if (hub->hdev->quirks & USB_QUIRK_HUB_SLOW_RESET)
#                reset_recovery_time += 100;
#
# CONSEQUENCE: putting g/n on the hub would be useless - it would only pad the
# hub's own enumeration. The receiver must be targeted directly for g/n; the
# hub can only be helped with o.
#
# ---------------------------------------------------------------------------
# UPSTREAM PRECEDENT (drivers/usb/core/quirks.c, usb_quirk_list[])
# ---------------------------------------------------------------------------
#   Corsair K70 RGB / Strafe / Strafe RGB / K70 RGB RAPIDFIRE:
#     { 0x1b1c, 0x1b13/0x1b15/0x1b20/0x1b38 } -> DELAY_INIT | DELAY_CTRL_MSG
#   Logitech webcams + Harmony 700:
#     { 0x046d, 0x082d/0x0841/0x0843/0x085b/0x085c/0x0847/0x0848/0x0853/0xc122 } -> DELAY_INIT
#   Terminus Technology hub:
#     { 0x1a40, 0x0101 } -> HUB_SLOW_RESET
#   Lenovo dock hardware already carries quirks upstream:
#     { 0x17ef, 0x1018/0x1019 } -> RESET_RESUME   (ThinkPad OneLink+ dock hubs)
#     { 0x17ef, 0xa387/0xa391/0xa392 } -> NO_LPM  (ThinkPad USB-C Dock Gen2)
#   Realtek hub in a Dell dock:
#     { 0x0bda, 0x0487 } -> NO_LPM                (Dell WD19 Type-C)
#
# NOTE: neither 046d:c52b nor 0bda:5411 is in the upstream list. Both entries
# below are inferences by analogy from the code paths above, NOT upstream
# blessed fixes.
#
# ---------------------------------------------------------------------------
# HOW TO TEST WITHOUT REBOOTING
# ---------------------------------------------------------------------------
# The module param is mode 0644 (device_param_cb(quirks, ..., 0644)) and quirks
# are evaluated at enumeration time, so:
#
#   echo '046d:c52b:gn,0bda:5411:o' | sudo tee /sys/module/usbcore/parameters/quirks
#   # then suspend, resume, and plug the dock in
#   cat /sys/module/usbcore/parameters/quirks   # confirm it stuck
#   dmesg -w | grep -E '5-2\.2|046d|c52b|descriptor'
#
# To clear: echo '' | sudo tee /sys/module/usbcore/parameters/quirks
#
# Beware: dynamic quirks are applied with XOR against the built-in table
#   udev->quirks ^= usb_detect_dynamic_quirks(udev);
# i.e. each letter TOGGLES. Harmless here (neither ID has built-in quirks),
# but do not blindly append letters to a device that already has some.
#
# ---------------------------------------------------------------------------
# OPEN QUESTIONS / TODO
# ---------------------------------------------------------------------------
# - Does this actually fix it? Needs several suspend/resume + dock cycles.
#   If the truncated-descriptor line still appears, the timing theory is wrong
#   and the corruption is physical (cable / TBT link / dock PSU) - try a
#   different dock port for the receiver, or a different TBT cable, first.
# - 0bda:5411 is a generic Realtek RTS5411 and will match ANY RTS5411 on this
#   machine, not only the one inside the dock. The effect is only +100 ms after
#   port reset, so low risk, but it is not surgical. Narrow it if it bites.
# - Fallback if quirks do not help: a udev rule that unbinds/rebinds 5-2.2.3
#   when the parsed interface count is wrong. Uglier; only if needed.
# - Consider whether the dock hubs want NO_LPM (letter k) like the upstream
#   17ef:a387/a391/a392 entries, if link-power-management turns out to be
#   involved rather than raw timing.
#
# ---------------------------------------------------------------------------
# INCIDENT 2 - a DIFFERENT dock/hub: GenesysLogic hub pair, keyboard missing
# ---------------------------------------------------------------------------
# Logged 2026-08-12 from /home/bobo/nixos/overlays/recent.log (s2idle
# suspend/resume). CONFIRMED with the user this is a different physical dock
# and different peripherals than Incident 1 above - different vendor IDs
# (GenesysLogic 05e3:xxxx, not Realtek 0bda:5411), different xhci bus numbers
# (usb2/usb3, not usb5/usb6), no PCIe-switch/TBT3 hop in the topology seen.
# Do not merge these two incidents or assume one fix covers both.
#
# ---------------------------------------------------------------------------
# SYMPTOM
# ---------------------------------------------------------------------------
# After s2idle resume, the USB keyboard (and mouse) behind this dock is not
# recognized. Unplugging and replugging the keyboard/dock fixes it.
#
# ---------------------------------------------------------------------------
# TOPOLOGY (as seen this boot - port numbers may differ next time)
# ---------------------------------------------------------------------------
#   xhci_hcd (bus 2, SS)
#     -> 2-1        05e3:0625   GenesysLogic "USB3.2 Hub", 5 ports
#       -> 2-1.5    0bda:8153   Realtek USB 10/100/1000 LAN (dock Ethernet)
#   xhci_hcd (bus 3, HS)
#     -> 3-3        05e3:0610   GenesysLogic "USB2.1 Hub", 6 ports
#       -> 3-3.1    04d9:a09e   E-Signal/A-One USB Gaming Mouse (+ kbd iface)
#       -> 3-3.2    045e:0750   Microsoft Wired Keyboard 600        <-- victim
#
# ---------------------------------------------------------------------------
# EVIDENCE - hub-level enumeration failure, not descriptor corruption
# ---------------------------------------------------------------------------
# recent.log, from "PM: suspend exit" at 07:41:39:
#
#   07:41:40  usb 2-1: Device not responding to setup address.  (x2)
#   07:41:40  usb 2-1: device not accepting address 2, error -71
#   07:41:41  usb 2-1: new SuperSpeed Plus Gen 2x1 USB device number 3 ...  <- recovered
#   07:41:40  usb 3-3: new high-speed USB device number 4 using xhci_hcd
#             <-- and then NOTHING for device 4. No children, no error either.
#   07:42:01  usb 2-1: USB disconnect, device number 3
#             r8152-cfgselector 2-1.5: USB disconnect, device number 4
#   07:42:05  usb 3-3: new high-speed USB device number 5 using xhci_hcd
#   07:42:05  usb 2-1: Device not responding to setup address.  (x2)
#   07:42:05  usb 2-1: device not accepting address 5, error -71
#   07:42:06  usb 3-3: new high-speed USB device number 6 using xhci_hcd
#   07:42:06  usb 2-1: new SuperSpeed Plus Gen 2x1 USB device number 6 ...
#   07:42:06  hub 3-3:1.0: USB hub found, 6 ports detected            <- recovered
#   07:42:08  usb 3-3.1: new full-speed USB device number 7 (mouse+kbd combo)
#   07:42:08  usb 3-3.2: new low-speed USB device number 8 (Wired Keyboard 600)
#   07:42:09  input: Microsoft Wired Keyboard 600 ... (clean, both interfaces)
#
# Unlike Incident 1, neither downstream device (3-3.1, 3-3.2) ever showed a
# short/corrupt config descriptor once the parent hub (3-3) was up - both
# enumerated cleanly on their first attempt. The failure here is entirely at
# the HUB's own address-setup stage (error -71 = EPROTO on SET_ADDRESS/
# GET_DESCRIPTOR), ~29s of retries between resume and the keyboard working.
#
# The full disconnect of hub 2-1 at 07:42:01 (all descendants gone, not just
# a reset) is consistent with a physical unplug, matching what the user
# reported ("plug out/plug in again solved it") rather than a pure in-kernel
# retry loop.
#
# ---------------------------------------------------------------------------
# WHY NO KERNEL QUIRK WAS ADDED (yet)
# ---------------------------------------------------------------------------
# The Incident 1 quirk letters target specific in-tree code paths:
#   g (DELAY_INIT)      - pads the CONFIG descriptor fetch and port_connect
#   n (DELAY_CTRL_MSG)  - pads between control messages
#   o (HUB_SLOW_RESET)  - pads hub_port_reset() recovery time for children
#
# None of these visibly execute during plain SET_ADDRESS/GET_DESCRIPTOR
# failures at initial enumeration (error -71 before a config is even read) -
# that path is usb_new_device() -> hub_port_init(), which already retries
# internally (SET_ADDRESS retried up to 4 times, see hub_port_init() in
# drivers/usb/core/hub.c). Adding g/n/o here would be guessing at a mechanism
# that doesn't match this failure signature. Needs a repro with
# `dmesg -w | grep -E '2-1|3-3|error -71'` across a few more suspend/resume
# cycles (ideally without a manual replug) before picking a quirk, per the
# "don't add quirks without confirming the mechanism" rule from Incident 1.
#
# ---------------------------------------------------------------------------
# HEALTHY BASELINE (lsusb -t / lsusb, captured 2026-08-12 post-recovery)
# ---------------------------------------------------------------------------
#   Bus 002 Dev 001 root_hub xhci_hcd/3p, 20000M/x2
#     |__ Port 001 Dev 006  05e3:0625  GenesysLogic USB3.2 Hub, 5 ports, 10000M
#         |__ Port 005 Dev 007  0bda:8153  Realtek RTL8153 GbE (r8152), 5000M
#   Bus 003 Dev 001 root_hub xhci_hcd/8p, 480M
#     |__ Port 003 Dev 006  05e3:0610  GenesysLogic Hub, 6 ports, 480M
#         |__ Port 001 Dev 007  04d9:a09e  Holtek "USB Gaming Mouse" (usbhid x2)
#         |__ Port 002 Dev 008  045e:0750  Microsoft Wired Keyboard 600 (usbhid x2)
#
# Confirms 05e3:0625 (bus 2, SuperSpeed) and 05e3:0610 (bus 3, high-speed) are
# genuinely separate hub instances/PIDs, not two faces of one chip reporting
# differently - typical of a combo SS+HS dock hub design, each with its own
# downstream ports. Also: the 3-3.1 device's vendor string is "Holtek
# Semiconductor" here, not "E-Signal/A-One" as logged during the incident -
# same 04d9:a09e mouse, just an inconsistent iManufacturer string across
# enumerations (seen before with cheap Holtek-based peripherals, harmless).
#
# ---------------------------------------------------------------------------
# OPEN QUESTIONS / TODO
# ---------------------------------------------------------------------------
# - Does this reproduce WITHOUT a manual unplug (i.e. does the kernel's own
#   hub_port_init() retry eventually win on its own if left alone longer)?
#   If yes, this may just be a slow-to-power-up dock after s2idle and not
#   need a quirk at all - only patience.
# - If it keeps happening, capture whether error -71 always lands on 2-1
#   (the SS hub) specifically, or moves around - that decides whether a
#   HUB_SLOW_RESET-style quirk on 05e3:0625 would even be structurally
#   plausible (it only helps children, not the hub's own enumeration).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelParams = [
    # See "INCIDENT 1" in the long comment above before changing this.
    # Only covers the TBT3 dock's RTS5411 hub / Logitech receiver - Incident 2
    # (GenesysLogic 05e3:0625/0610 dock, Microsoft keyboard) has no quirk yet.
    #   046d:c52b -> g = DELAY_INIT, n = DELAY_CTRL_MSG   (Logitech Unifying receiver)
    #   0bda:5411 -> o = HUB_SLOW_RESET                   (its parent RTS5411 hub)
    "usbcore.quirks=046d:c52b:gn,0bda:5411:o"
  ];
}
