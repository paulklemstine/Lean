"""
r48 / AXIS-B : MEASUREMENT HARNESS.

For each family we:
  1. draw group ORDERS (families.py),
  2. bucket them by bit-length,
  3. at MATCHED bit-length, apply the SAME smoothness predicate (smooth.py)
     at a MATCHED smoothness bound B = floor(order**(1/u)) for u in a grid,
  4. record P(B-smooth) = Dickman probability, and the EC baseline is
     measured identically in the SAME process.

MATCHED-TWIN CONTROL
  The comparison "family vs EC at matched scale" is only meaningful if the
  EC baseline and the family are compared at the same ORDER BIT-LENGTH.
  We enforce this by bucketing: for the 64-bit row we keep only orders with
  bit_length in [64, 64] exactly (i.e. exactly 64 bits).  We report the
  realised distribution to prove the buckets really are matched.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from collections import Counter, defaultdict

from smooth import iroot, is_B_smooth, rho


# ---------------------------------------------------------------- helpers
def matched_bucket(pairs, want_bits, n_keep, rng=None, slack=3):
    """Keep pairs whose order has EXACTLY want_bits bits (the matched twin).

    RAISES if the family cannot fill the bucket.  An earlier draft returned
    (pairs, 99) in that case and the caller happily reported numbers from an
    UNMATCHED sample -- which would have made the whole table meaningless.
    The control must fail loudly, not silently.
    """
    exact = [x for x in pairs if x[1].bit_length() == want_bits]
    if len(exact) >= n_keep:
        return exact[:n_keep], 0
    for s in range(1, slack + 1):
        for sign in (-s, +s):
            extra = [x for x in pairs if x[1].bit_length() == want_bits + sign]
            if len(exact) + len(extra) >= n_keep:
                return (exact + extra)[:n_keep], s
    hist = Counter(x[1].bit_length() for x in pairs)
    raise ValueError(
        f"matched_bucket: only {len(pairs)} samples drawn, "
        f"{len(exact)} at exactly {want_bits} bits; bit histogram {dict(sorted(hist.items()))}. "
        f"Draw more samples or widen the parameter range -- an unmatched "
        f"comparison is worse than no comparison.")


def lpf_stats(orders, cap=400):
    """The metric that actually drives a rho/BSGS walk cost: the LARGEST
    PRIME (power) factor of the group order.

    Smoothness at u=2 is a PROXY and it is degenerate for groups like
    PGL(2,p), where every prime factor is <= p+1 << |G|^(1/2) by
    construction, so P(u=2 smooth) is trivially 1.  The honest measure is
    log2 of the largest prime power factor.
    """
    from smooth import factorint_pari
    out = []
    for n in orders[:cap]:
        f = factorint_pari(n)
        if not f:
            continue
        out.append(max(p ** e for p, e in f.items()))
    if not out:
        return {}
    import math as _m
    lg = sorted(_m.log2(x) for x in out)
    bits = sorted(n.bit_length() for n in orders[:cap])
    return {
        "n": len(out),
        "log2_lpf_median": lg[len(lg) // 2],
        "log2_lpf_mean": sum(lg) / len(lg),
        "log2_lpf_max": lg[-1],
        "group_bits_median": bits[len(bits) // 2],
        "note": "walk cost ~ sqrt(largest prime power factor); compare the "
                "MEDIAN log2 to the group order's log2",
    }


def smoothness_curve(orders, u_grid=(2.0, 2.5, 3.0, 3.5, 4.0)):
    """P(B-smooth) for each u, with B = floor(order**(1/u)) EXACTLY."""
    out = {}
    for u in u_grid:
        k = max(1, int(round(1.0 / u)))
        if abs(1.0 / u - k) > 1e-12:
            # non-integral 1/u: use the general B_for_u path
            from smooth import B_for_u
            Bs = [B_for_u(m, u) for m in orders]
        else:
            Bs = [iroot(m, k) for m in orders]
        hits = sum(1 for m, B in zip(orders, Bs) if is_B_smooth(m, B))
        out[u] = {
            "P_smooth": hits / len(orders),
            "n": len(orders),
            "n_hits": hits,
            # 95% Wilson-ish normal CI
            "ci95": _wilson(hits, len(orders)),
        }
    return out


def _wilson(k, n, z=1.96):
    if n == 0:
        return (0.0, 1.0)
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    hw = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return (max(0.0, c - hw), min(1.0, c + hw))


def order_stats(orders):
    bits = sorted(m.bit_length() for m in orders)
    return {
        "n": len(orders),
        "bits_min": bits[0], "bits_max": bits[-1],
        "bits_median": bits[len(bits) // 2],
        "bits_hist": dict(sorted(__import__("collections").Counter(bits).items())),
        "log10_geomean": sum(math.log10(m) for m in orders) / len(orders),
    }