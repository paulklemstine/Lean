# CORRECTED decisive test. one_trial() draws its own g internally, so my earlier
# version compared two DIFFERENT g values -- invalid.
#
# The right test of the subagent's load-bearing claim is not "does the kernel beat
# a trivial multiple" but the v2-LAW: success is EXACTLY predicted by
# v2(ord_p g) != v2(ord_q g), and is independent of everything the kernel does.
# If that law holds on every trial, no information in the linear algebra matters.
import sys, random
sys.path.insert(0, '.')
import core
from math import lcm

agree = 0; tot = 0; kern_ok = 0; law_hits = 0; rows = []
for i in range(50):
    rng = random.Random(70000 + i)
    bits = rng.choice([22, 24, 26])
    N, p, q = core.gen_rsa(bits, rng)
    r = core.one_trial(N, p, q, 8, 5, rng)
    # Recompute the v2-law INDEPENDENTLY from the reported 2-adic valuations,
    # rather than trusting the harness's own v2_differ flag.
    v2p = r["v2_op"]; v2q = r["v2_oq"]
    pred = (v2p != v2q)
    act = bool(r.get("verified"))
    tot += 1
    kern_ok += act
    agree += (pred == act)
    if pred: law_hits += 1
    if i < 8:
        rows.append((bits, pred, act, r.get("h"), r.get("v2_op"), r.get("v2_oq")))

print("trials:", tot)
print("kernel-path verified:            %d/%d" % (kern_ok, tot))
print("v2-law predicted success:        %d/%d" % (law_hits, tot))
print("v2-law AGREES with outcome:      %d/%d" % (agree, tot))
print()
print("sample (bits, v2-law says, actually factored, h):")
for r_ in rows:
    print("   ", r_)
print()
print("=> v2-law perfectly predicts the kernel path" if agree == tot
      else "=> v2-law MISSES %d trials" % (tot - agree))
