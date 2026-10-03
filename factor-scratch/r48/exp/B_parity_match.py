"""
PARITY-MATCHED control for B_groups.

The matched-on-order-bits comparison showed class numbers at
P(u=2 smooth) = 0.352..0.393 vs an EC-matched null of 0.2645 -- but class
numbers are 94-100% even and EC orders only ~48% even.  Since 2 is the
cheapest prime there is, parity alone can manufacture a gap.

This splits BOTH samples by parity and compares like with like.  If the gap
survives, it is a real family advantage; if it vanishes, it was parity.
"""
import glob
import json
import math
import random
import statistics
import sys
from collections import Counter

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")
from dickman import is_smooth  # noqa: E402

E = "/home/raver1975/lean/factor-scratch/r48/exp"


def load(patterns):
    hs = []
    for pat in patterns:
        for f in glob.glob(pat):
            try:
                for _k, v in json.load(open(f)):
                    hs.append(int(v))
            except Exception:
                pass
    return hs


def rate(orders, label):
    if len(orders) < 20:
        return None, len(orders)
    hits = sum(1 for n in orders if is_smooth(n, math.isqrt(n)))
    return hits / len(orders), len(orders)


def ci(k, n, z=1.96):
    if not n:
        return (0.0, 0.0)
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    hw = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return (max(0.0, c - hw), min(1.0, c + hw))


def main():
    cn = load([f"{E}/cn_negN_*.json"]) + load([f"{E}/cn_free_*.json"])
    hist = Counter(h.bit_length() for h in cn)
    B = statistics.mode([b for b, c in hist.items() if c >= 12])
    sel = [h for h in cn if h.bit_length() == B]
    print(f"scale: {B}-bit orders, {len(sel)} class numbers")
    print(f"class-number parity: {sum(1 for h in sel if h%2==0)/len(sel):.3f} even")

    # uniform matched null, same bit length, split by parity
    rng = random.Random(31337)
    null = []
    while len(null) < 40000:
        m = rng.getrandbits(B) | (1 << (B - 1))
        null.append(m)

    print()
    hdr = f"{'arm':34s} {'n':>6s} {'P(u=2)':>8s} {'CI95':>16s} {'even%':>7s}"
    print(hdr)
    print("-" * len(hdr))
    rows = {}
    for par, nm in ((0, "ODD"), (1, "EVEN")):
        csel = [h for h in sel if h % 2 == par]
        nsel = [m for m in null if m % 2 == par]
        rc, nc = rate(csel, "cn")
        rn, nn = rate(nsel, "null")
        if rc is None or rn is None:
            print(f"{nm:34s} {nc:6d} insufficient (cn {nc}, null {nn})")
            continue
        rows[nm] = (rc, rn, nc, nn)
        print(f"{'class numbers, '+nm:34s} {nc:6d} {rc:8.4f} "
              f"[{ci(round(rc*nc),nc)[0]:.3f},{ci(round(rc*nc),nc)[1]:.3f}] "
              f"{100*par:6.1f}%")
        print(f"{'uniform null,   '+nm:34s} {nn:6d} {rn:8.4f} "
              f"[{ci(round(rn*nn),nn)[0]:.3f},{ci(round(rn*nn),nn)[1]:.3f}] "
              f"{100*par:6.1f}%")
        d = rc - rn
        se = math.sqrt(rc * (1 - rc) / nc + rn * (1 - rn) / nn)
        print(f"{'  -> parity-matched delta':34s} {d:+8.4f}  "
              f"({d/se if se else float('nan'):+.1f} sigma)")
        print()

    print()
    rc, rn, nc, nn = rate(sel, "all")[0], rate(null, "all")[0], len(sel), len(null)
    d = rc - rn
    se = math.sqrt(rc * (1 - rc) / nc + rn * (1 - rn) / nn)
    print(f"UNMATCHED-FOR-PARITY delta {d:+.4f} ({d/se:+.1f} sigma) "
          f"-- this is the number the parity confound explains.")


if __name__ == "__main__":
    main()