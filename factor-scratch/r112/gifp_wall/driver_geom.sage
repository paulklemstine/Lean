load('instrument.sage')

n = 200
b1, b2 = 0.1, 0.15
m = 4
TRIALS = 4

# NEGATIVE CONTROL FIRST (FANOUT_BRIEF 1.2): a harness never shown to fire has
# measured nothing. alpha=0.10, gamma=0.50 is a point where r110/r111 report 8/8
# and 10/10. If this comes back 0/4 the instrument is broken, not the attack.
print("=== NEGATIVE CONTROL: alpha=0.10 gamma=0.50 m=4 (r110: 10/10) ===")
ok = 0; tot = 0
for k in range(4):
    seed = 7000000 + 15485863*k + 100*100 + 500
    r = instrument(n, RR(0.10), RR(0.50), RR(b1), RR(b2), m, seed)
    if r["status"].startswith("skip"):
        print("  skip", r["status"]); continue
    tot += 1; ok += 1 if r["fact"] else 0
    print("  seed=%d status=%s fact=%s nz=%s/%s slackHG=%s meas=%s margin=%.1f root_ok=%s" % (
        seed, r["status"], r["fact"], r["nz"], r.get("npolys"),
        round(r["slackHG"], 2), round(r.get("slackHG_measured", -999), 2),
        r["margin"], r["root_ok"]))
print("  CONTROL VERIFIED %d/%d\n" % (ok, tot))