#!/usr/bin/env python3
"""
r114 lead-check: locate the shared-window collision threshold EMPIRICALLY.

Question: for two INDEPENDENTLY generated (1-alpha)n-bit integers p1, p2, how many
consecutive bits can they be expected to share, at any alignment?

Prediction (union bound): with W = k - w + 1 windows in each number,
    P(p1 and p2 share SOME window of length w)  ~  W^2 * 2^(-w)
so the expected count crosses 1 near w ~ 2*log2(W) ~ 2*log2(k).

This is the quantity that decides whether GIFP's requirement -- a shared block of
4*alpha*(1-sqrt(alpha))*n bits, a fixed FRACTION of n -- is reachable by independent
key generation. It is not.

Run: python3 collision_threshold.py
Writes nothing outside this directory. Does not commit.
"""
import math
import random
import sys
from collections import defaultdict

ALPHA = 0.10


def rand_bits_int(k: int, rng: random.Random) -> int:
    """A uniformly random k-bit integer (top bit forced to 1 so nbits() == k)."""
    return rng.getrandbits(k) | (1 << (k - 1))


def windows(x: int, k: int, w: int):
    """All w-bit windows of a k-bit integer, MSB-first, as ints."""
    mask = (1 << w) - 1
    out = []
    for i in range(0, k - w + 1):
        out.append((x >> (k - w - i)) & mask)
    return out


def trial_shared(k: int, w: int, rng: random.Random) -> int:
    """Count of distinct window positions in p1 whose window appears somewhere in p2."""
    p1 = rand_bits_int(k, rng)
    p2 = rand_bits_int(k, rng)
    s2 = set(windows(p2, k, w))
    return sum(1 for v in windows(p1, k, w) if v in s2)


def main() -> None:
    rng = random.Random(20261005)
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 400

    # Positive control: does the detector fire when we PLANT a shared block?
    # (This campaign has had three probes that reported "absent" everywhere,
    #  including where the phenomenon was known present.)
    k, w = 2048, 32
    block = rng.getrandbits(w)
    p2 = rand_bits_int(k, rng)
    # plant `block` into p2 at a random offset, then make p1 from p2's high region
    shift = 700
    p2_planted = (p2 & ~(((1 << w) - 1) << shift)) | (block << shift)
    p1_planted = (p2_planted >> (shift + w - 64)) & ((1 << k) - 1)
    planted_hits = trial_shared(k, w, rng)  # control: unplanted baseline below
    s2 = set(windows(p2_planted, k, w))
    control_fired = any(v in s2 for v in windows(p1_planted, k, w))
    print("POSITIVE CONTROL -- detector must fire on a planted block")
    print(f"  k={k} w={w}  fired={control_fired}")
    if not control_fired:
        print("  !! CONTROL FAILED -- the measurement below would be meaningless.")
        return
    print()

    print(f"Threshold scan: k = (1-alpha)*n bits, alpha={ALPHA}, {trials} trials each")
    print()
    hdr = f"{'k':>6} {'w':>4} {'W^2*2^-w':>10} {'observed mean':>14} {'frac>0':>8}"
    print(hdr)
    print("-" * len(hdr))

    for k in (512, 1024, 2048, 4096):
        for w in (8, 12, 16, 20, 24, 28):
            W = k - w + 1
            pred = (W * W) * (2.0 ** -w)
            if pred < 1e-4:
                continue
            hits = [trial_shared(k, w, rng) for _ in range(trials)]
            mean = sum(hits) / len(hits)
            frac = sum(1 for h in hits if h > 0) / len(hits)
            print(f"{k:>6} {w:>4} {pred:>10.3f} {mean:>14.4f} {frac:>8.3f}")
        # where does the prediction cross 1?
        print(f"       predicted break-even w (W^2*2^-w = 1): "
              f"{math.ceil(2*math.log2(k))}")
        print()

    print("THE HEADLINE NUMBER")
    print("=" * 70)
    print("GIFP's attack requires a shared block of 4*alpha*(1-sqrt(alpha))*n bits,")
    print("i.e. a fixed FRACTION of n. Independent generation caps shared bits at")
    print("roughly 2*log2(n). Compute the gap:")
    print()
    print(f"{'n':>6} {'required bits':>15} {'collision cap':>14} {'ratio':>8}")
    for n in (512, 1024, 2048, 3072, 4096):
        k = int(n * (1 - ALPHA))
        req = 4 * ALPHA * (1 - math.sqrt(ALPHA)) * n
        cap = 2 * math.log2(k)
        print(f"{n:>6} {req:>15.1f} {cap:>14.1f} {req/cap:>7.1f}x")
    print()
    print("The required shared block is a fraction of n; the collision cap is")
    print("logarithmic in n. The gap WIDENS with n. It is never closable by")
    print("independent key generation -- only by correlated entropy.")


if __name__ == "__main__":
    main()