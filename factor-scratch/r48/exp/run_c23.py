"""
C2 (filtering) and C3 (polynomial choice), measured.

C3: for a FIXED N, vary m (hence the polynomial f) and measure
      - coefficient mass of f
      - how many smooth relations the sieve actually yields at fixed (y, box)
      - wall-clock
    Suboptimal f does not cost a constant -- it can cost EVERYTHING.

C2: decompose the filtering cost actually paid on this host:
      - sieve throughput (pairs/second, primes passed, cells touched)
      - the survival rate (fraction of pairs that are y-smooth)
      - the cost of the final linear algebra (matrix size) vs the sieve
"""
import time
import numpy as np

import nfs_lattice as NL
import run_c1_old as R


# ------------------------------------------------------------------ C3

def c3(Nbits=40, ymax=1000, box=600, need=10**9):
    print("=" * 78)
    print("C3  POLYNOMIAL CHOICE: is the achievable f optimal, and what does the")
    print("     suboptimality cost?   (fixed N, fixed sieve, only m varies)")
    print("=" * 78)
    N, p, q, m0, P0, fc0, _ = R.build(Nbits, 3)
    print(f"N = {N} ({N.bit_length()} bits)\n")
    print(f"{'m':>9}{'mass':>10}{'f (x^2,x,1)':>26}{'rels':>7}{'rate':>12}{'sec':>8}")
    centre = N ** (1.0 / 3)
    rows = []
    for frac in (0.90, 0.95, 0.98, 0.995, 1.0, 1.005, 1.01, 1.02, 1.05, 1.10):
        m = int(centre * frac)
        if m < 2:
            continue
        digs = NL.base_m_digits(N, m, 3)
        if digs[3] != 1:
            continue
        mass = sum(abs(x) for x in digs[:3])
        P = NL.make_poly(N, 3, m)
        if not NL.poly_is_irreducible_over_Z(P):
            continue
        fc = R.f_coeffs_of(P)
        t = time.time()
        rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=ymax,
                                          Amax=box, Bmax=box, need=need)
        dt = time.time() - t
        rate = len(rels) / (4 * box * box)
        print(f"{m:>9}{mass:>10}{(fc[1], fc[2], fc[3])!s:>26}{len(rels):>7}"
              f"{rate:>12.3e}{dt:>8.2f}")
        rows.append((mass, len(rels)))
    if rows:
        best = max(rows, key=lambda r: r[1])
        worst = min(rows, key=lambda r: r[1])
        print(f"\nbest  polynomial: mass {best[0]}, {best[1]} relations")
        print(f"worst polynomial: mass {worst[0]}, {worst[1]} relations")
        print("A polynomial that yields ZERO relations has infinite cost: the")
        print("factorisation does not proceed at any constant-factor saving.")
    print("=" * 78)
    return rows


# ------------------------------------------------------------------ C2

def c2(Nbits=40, box=600):
    print("=" * 78)
    print("C2  THE FILTERING STEP: what does it actually cost, measured here?")
    print("=" * 78)
    N, p, q, m, P, fc, cost = R.build(Nbits, 3)
    print(f"N = {N} ({N.bit_length()} bits), m = {m}, f mass = {cost}\n")
    print(f"{'y':>8}{'split primes':>14}{'cells':>12}{'survivors':>11}"
          f"{'smooth rate':>14}{'sec':>8}{'M pairs/s':>11}")
    for ymax in (200, 500, 1000, 2000, 5000):
        t = time.time()
        rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=ymax,
                                          Amax=box, Bmax=box, need=10 ** 9)
        dt = time.time() - t
        npairs = 4 * box * box
        rate = len(rels) / npairs
        print(f"{ymax:>8}{npr:>14}{npairs:>12}{len(rels):>11}"
              f"{rate:>14.3e}{dt:>8.2f}{npairs / dt / 1e6:>11.2f}")

    # how many relations does the linear algebra actually need?
    print("\nlinear-algebra side of the trade-off:")
    for nrel in (8, 16, 32, 64, 128):
        t = time.time()
        rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=1000,
                                          Amax=box, Bmax=box, need=nrel)
        dt = time.time() - t
        print(f"  {nrel:>4} relations -> sieve {dt:>6.2f}s, "
              f"matrix {nrel} x {2 * 3 + 1}")
    print("=" * 78)


if __name__ == "__main__":
    c3()
    c2()
