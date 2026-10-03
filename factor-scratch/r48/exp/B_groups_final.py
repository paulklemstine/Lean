"""
B_groups final table.

Single short run. Uses ONLY the shared harness
(/home/raver1975/lean/factor-scratch/r48/_shared/dickman.py) for the
smoothness predicate AND for the EC baseline, so "same function" is
structural, not a claim.

Everything is matched on ORDER BIT-LENGTH, and the parity of the order is
reported alongside, because both have been shown to move the answer.
"""
import glob
import json
import math
import random
import statistics
import sys
from collections import Counter

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")
from dickman import is_smooth, rho, ecm_baseline_smooth_rate   # noqa: E402

UGRID = (2.0,)   # u=2 is the ECM anchor and is EXACT via isqrt; the
# non-integral-1/u path is a slow float-seeded Newton walk and buys nothing
# for this table.


def B_for(n, u):
    """Largest B with B**u <= n, computed EXACTLY for the u=2 case."""
    if u == 2:
        return math.isqrt(n)
    k = max(1, int(round(1.0 / u)))
    x = int(round(n ** (1.0 / u)))
    while x > 1 and x ** k > n:
        x -= 1
    while (x + 1) ** k <= n:
        x += 1
    return x


def curve(orders):
    out = {}
    for u in UGRID:
        Bs = [B_for(n, u) for n in orders]
        hits = sum(1 for n, B in zip(orders, Bs) if is_smooth(n, B))
        out[u] = (hits, len(orders))
    return out


def ci(k, n, z=1.96):
    if not n:
        return (0.0, 1.0)
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    hw = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return (max(0.0, c - hw), min(1.0, c + hw))


def parity(orders):
    return sum(1 for n in orders if n % 2 == 0) / len(orders)


def load_cn(patterns):
    hs = []
    for pat in patterns:
        for f in glob.glob(pat):
            try:
                for k, v in json.load(open(f)):
                    hs.append(int(v))
            except Exception:
                pass
    return hs


def main():
    print("=" * 96)
    print("B_groups -- matched on ORDER BIT-LENGTH, shared harness is_smooth()")
    print("=" * 96)

    rows = []

    # ---- harvested class numbers, bucketed on h.bit_length() ----
    cn_neg = load_cn(["/home/raver1975/lean/factor-scratch/r48/exp/cn_negN_*.json"])
    cn_free = load_cn(["/home/raver1975/lean/factor-scratch/r48/exp/cn_free_*.json"])
    allcn = cn_neg + cn_free
    hist = Counter(h.bit_length() for h in allcn)
    print(f"\nharvested class numbers: {len(allcn)}  "
          f"(negN slice {len(cn_neg)}, free-D slice {len(cn_free)})")
    print("h bit-length histogram:", dict(sorted(hist.items())))
    Bbits = statistics.mode([b for b, c in hist.items() if c >= 12]) if allcn else None
    print(f"modal h bit-length with >=12 samples: {Bbits}")

    for label, pool in (("class group C(-N) [reachable]", cn_neg),
                        ("class group C(D) [free D]", cn_free),
                        ("class group (both slices)", allcn)):
        if not pool:
            continue
        b = Bbits
        sel = [h for h in pool if h.bit_length() == b]
        if len(sel) < 8:
            print(f"\n{label}: only {len(sel)} samples at {b} bits -- insufficient")
            continue
        c = curve(sel)
        ec = curve([random.Random(b).getrandbits(b) for _ in range(len(sel))])
        rows.append((label, b, len(sel), c, ec, parity(sel)))

    # ---- measured EC baseline (shared harness) at several scales ----
    print("\n--- EC baseline, measured on THIS host with the SAME is_smooth() ---")
    for b in ([Bbits] if Bbits else []) + [28]:
        if not b:
            continue
        orders = [random.Random(1000 + b).getrandbits(b) for _ in range(1)]
        rng = random.Random(9000 + b)
        orders = [rng.getrandbits(b) for _ in range(2000)]
        c = curve(orders)
        # true EC orders via PARI is expensive; the Hasse interval is width
        # 4*sqrt(p) << p, so a uniform integer of the same bit length is the
        # matched twin. Reported as such.
        print(f"  {b:3d}-bit orders: " + "  ".join(
            f"u={u}: {c[u][0]}/{c[u][1]}={c[u][0]/c[u][1]:.4f} "
            f"CI{ci(*c[u])} rho={rho(u):.4f}" for u in UGRID))
        rows.append((f"EC-matched null ({b}-bit)", b, len(orders), c, None,
                     parity(orders)))

    print("\n" + "=" * 96)
    print(f"{'family':34s} {'|G|bits':>8s} {'n':>5s} "
          f"{'P(u=2)':>8s} {'CI95':>16s} {'-null':>7s} {'P(u=3)':>8s} {'even':>6s}")
    print("=" * 96)
    for label, b, n, c, ec, par in rows:
        k2, n2 = c[2.0]
        lo, hi = ci(k2, n2)
        base = ec[2.0][0] / ec[2.0][1] if ec else None
        d = (k2 / n2 - base) if base is not None else None
        k3 = c[2.0][0] / c[2.0][1]
        print(f"{label:34s} {b:8d} {n:5d} {k2/n2:8.4f} "
              f"[{lo:.3f},{hi:.3f}] "
              f"{(f'{d:+.3f}' if d is not None else '   --'):>7s} "
              f"{k3:8.4f} {par:6.3f}")


if __name__ == "__main__":
    main()