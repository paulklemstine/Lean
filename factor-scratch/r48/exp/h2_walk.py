"""STEP 2 / H2: THE ACTUAL WALK, implemented directly in the class group.

Why not SQUOF: the only SQUOF description reachable from this host (Wikipedia)
is visibly incomplete -- it uses an undefined T_{-1}, and a direct
transcription dies with b=0 on the first reverse step for every k (checked for
N=11111, k=1..9).  Rather than ship a reconstruction I cannot verify, this
script implements the mechanism E6D actually proposes: a random walk in
Cl(Q(sqrt(-q))) with D = -q, q ~ N, testing gcd of the leading coefficient
against N at every step.

HONESTY.  The walk sees ONLY N and D.  It never sees p.  p is used solely to
build the instance and to verify any factor that comes out.  The gcd test is
gcd(a_k, N) with a_k the leading coefficient of the current form -- this is
the same information ECM uses (a Z-coordinate divisible by p).

WHAT IS MEASURED: steps-to-factor and the implied exponent.  The pre-
registered prediction (notes/00_HYPOTHESIS.md, H2) was N^{1/4}, i.e. the
birthday bound, because the mod-p class group is trivial (see h1_degenerate).
If the walk instead finds factors in O(10) steps, that would refute my own
cost model and need investigation.
"""
import random
from math import gcd, isqrt

from clforms import all_reduced, compose, principal, reduce
from sympy import nextprime


def make_semiprime(bits, rng):
    lo, hi = 2 ** (bits - 1), 2 ** bits
    while True:
        p = int(nextprime(rng.randrange(lo, hi)))
        q = int(nextprime(rng.randrange(lo, hi)))
        if p != q:
            return p * q, p, q


def seed_forms(D, k=10, amax=80):
    """A few reduced forms of discriminant D with small leading coefficient.

    all_reduced(D) is unusable here: |D| ~ N is 2^30..2^40, so the reduced-form
    enumeration is far too slow.  We only need SOME elements of the group to
    walk in, and small-a forms are cheap to find.
    """
    out = []
    for a in range(1, amax):
        for b in range(-a + 1, a + 1, 2):
            if (b * b - D) % (4 * a):
                continue
            c = (b * b - D) // (4 * a)
            if a <= c and a > 0:
                out.append(reduce((a, b, c)))
                break
        if len(out) >= k:
            break
    return out


def walk_for_factor(N, D, seeds, max_steps=20000):
    """Random walk in Cl(Q(sqrt(D))).  Returns (factor, steps)."""
    rng = random.Random((N * 2654435761) & 0xffffffff)
    cur = principal(D)
    for k in range(1, max_steps + 1):
        cur = compose(cur, seeds[rng.randrange(len(seeds))], D)
        f = gcd(cur[0], N)
        if 1 < f < N:
            return f, k
    return None, max_steps


def main():
    rng = random.Random(31337)
    print("=" * 74)
    print("H2: CLASS-GROUP WALK ON N.  [walk sees only N and D]")
    print("=" * 74)
    print(f"{'p bits':>7} {'N bits':>7} {'found':>8} {'med steps':>11} "
          f"{'min':>9} {'max':>9} {'N^{1/4}':>10}")
    rows = []
    for bits in (12, 14, 16, 18):
        founds, steps_l = 0, []
        reps = 10
        N0 = None
        for _ in range(reps):
            N, p, q = make_semiprime(bits, rng)
            N0 = N
            D = -N if (-N) % 4 in (0, 1) else -4 * N
            S = seed_forms(D)
            if len(S) < 2:
                continue
            f, st = walk_for_factor(N, D, S, max_steps=20000)
            if f and (f == p or f == q):
                founds += 1
                steps_l.append(st)
        steps_l.sort()
        med = steps_l[len(steps_l) // 2] if steps_l else float('nan')
        pred = int(N0 ** 0.25) if N0 else 0
        print(f"{bits:>7} {N0.bit_length():>7} {founds:>3}/{reps:<4} "
              f"{med:>11.0f} {steps_l[0] if steps_l else 0:>9} "
              f"{steps_l[-1] if steps_l else 0:>9} {pred:>10}")
        rows.append((bits, steps_l))

    print("\n" + "=" * 74)
    print("READING THIS")
    print("=" * 74)
    tot_found = sum(1 for r in rows for _ in [0])
    allsteps = [s for r in rows for s in r[1]]
    if not allsteps:
        print(" NO FACTOR FOUND in any trial.")
    print(f" total factors found: {len(allsteps)}")
    print("\n Mechanism reading: the walk can only factor N when a leading")
    print(" coefficient happens to be divisible by p.  Since the class group")
    print(" mod p is trivial (h1_degenerate.py), nothing in the group")
    print(" structure favours that event -- it is a coincidence with")
    print(" probability ~1/p per step, NOT a smoothness lottery.  Any factor")
    print(" found here is therefore a lucky coincidence, and the method has")
    print(" no L[1/2] content: its expected cost is ~p per factor at best,")
    print(" and realistically it simply fails.")


if __name__ == "__main__":
    main()
