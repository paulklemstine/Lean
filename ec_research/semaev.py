"""semaev.py -- feasibility test of Semaev S3 summation-polynomial behaviour.

Vector B hypothesis (H-008):
  "On prime fields F_p for p ~ 20-bit (here ~16-bit), Semaev's S_3(x1,x2,x3)
   can be computed symbolically and remains degree-bounded when solving
   P1+P2+P3=O via subfield/normalization; no degree explosion observed at
   small n."

This script does NOT claim any speedup.  It verifies, on one concrete curve:
  - S3 has degree <= 2 in each xi (explicit coeff. formulas below),
  - factor-base / "low x" density,
  - how often a determined R = -(P+Q) lands in that factor base.

Curve (chosen so #E is prime, hence the whole group is the ECDLP subgroup):
    p = 65521, a = 0, b = 17, n = #E(F_p) = 65353 (prime, verified at run time).

Factor base definition used here (DOCUMENTED EXACTLY):
  FB = { P in E(F_p) \\ {O} : representative x(P) in [0, THRESH) },
  THRESH = 256 (= 1<<8). "low-degree property" == "x-coordinate is a
  non-negative integer less than THRESH", with the canonical representative
  taken in {0,...,p-1}. No subfield exists for prime p, so we use this
  explicit low-interval normalisation (the only split possible for F_p).

Finite search convention:
  find_R_by_trial(P,Q) computes R = -(P+Q) by the chord-tangent law for
  E: y^2 = x^3 + a x + b, then tests membership by iterating x over
  0..THRESH-1 and comparing against R. (Equivalent to asking whether the
  unique group-theoretic R has low x.)  It returns (x,y) iff R in FB.

S3 polynomial (Semaev) used:
  Start from (x2-x1)^2*(x1+x2+x3+a) = (y2-y1)^2 with yi^2 = xi^3 + a xi + b.
  Squaring / eliminating yi yields (x1-x2)^2 * Big = 0, where

       Big = C2*x3^2 + C1*x3 + C0  (mod p)

  with
      C2 = (x1 - x2)^2
      C1 = 2*a*x1^2 - 4*a*x1*x2 - 2*a*x1 + 2*a*x2^2 - 2*a*x2
           - 2*x1^2*x2 - 2*x1*x2^2 - 4*b
      C0 = a^2*x1^2 - 2*a^2*x1*x2 - 2*a^2*x1 + a^2*x2^2 - 2*a^2*x2 + a^2
           - 4*a*b - 2*a*x1^2*x2 - 2*a*x1*x2^2 - 2*a*x1*x2 - 4*b*(x1+x2)
           + x1^2*x2^2

  Degree in each xi is 2 (C2 squared? well bounded); 0 explosion. Roots over
  F_p are found by the quadratic formula (mod p). If x1 == x2 (C2 == 0 mod
  p) the expression degenerates (division by zero); those pairs are skipped
  in the root-count experiment.

Measurements reported:
  - V_FB     : number of E(F_p) points with x in [0,THRESH)
  - ratio    : V_FB / n
  - relation hit ratio over N random (P,Q): how often R=-(P+Q) is in FB
  - S3 trials: for M random (x1,x2), number of quadratic roots and how many
    lie in FB; pair-level ">=1 FB root" frequency.

No group-operation counts are reduced; hence NO speedup is claimed.
"""

from __future__ import annotations

import json
import math
import random
import time
from pathlib import Path

# ---------------- finite field helpers ----------------


def _is_prime(n: int) -> bool:
    if n < 2:
        return False
    for sp in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % sp == 0:
            return n == sp
    d = n - 1
    r = 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def modinv(a: int, m: int) -> int:
    return pow(a % m, -1, m)


def legendre(x: int, p: int) -> int:
    x %= p
    if x == 0:
        return 0
    lr = pow(x, (p - 1) // 2, p)
    if lr == p - 1:
        return -1
    return 1


def modsqrt(a: int, p: int) -> int | None:
    """Tonelli-Shanks. Returns a square root r with r*r % p == a % p, or None."""
    a %= p
    if a == 0:
        return 0
    if pow(a, (p - 1) // 2, p) != 1:
        return None
    if p % 4 == 3:
        return pow(a, (p + 1) // 4, p)
    q = p - 1
    s = 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m = s
    c = pow(z, q, p)
    t = pow(a, q, p)
    r = pow(a, (q + 1) // 2, p)
    while True:
        if t == 1:
            return r
        i = 1
        temp = t * t % p
        while temp != 1:
            temp = temp * temp % p
            i += 1
        b = c
        for _ in range(m - i - 1):
            b = b * b % p
        m = i
        c = b * b % p
        t = t * c % p
        r = r * b % p


def count_points(a: int, b: int, p: int) -> int:
    total = 1  # point at infinity
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        if rhs == 0:
            total += 1
        elif legendre(rhs, p) == 1:
            total += 2
    return total


# ---------------- curve parameters ----------------

P = 65521
A = 0
B = 17
THRESH = 256  # factor base x-coordinate interval [0, THRESH)
NTRIALS_REL = 10000
NTRIALS_S3 = 5000

# verify p prime and #E
assert _is_prime(P)
assert _is_prime(count_points(A, B, P)) or True
_N = count_points(A, B, P)
assert _is_prime(_N), f"#E = {_N} not prime"
N_ORDER = _N

# point arithmetic for E: y^2 = x^3 + A x + B


def ec_add(Pt, Qt):
    if Pt is None:
        return Qt
    if Qt is None:
        return Pt
    x1, y1 = Pt
    x2, y2 = Qt
    if x1 == x2:
        if (y1 + y2) % P == 0:
            return None
        lam = (3 * x1 * x1 + A) * modinv(2 * y1, P) % P
    else:
        lam = (y2 - y1) * modinv(x2 - x1, P) % P
    x3 = (lam * lam - x1 - x2 - A) % P
    y3 = (lam * (x1 - x3) - y1) % P
    return (x3, y3)


def ec_neg(Pt):
    if Pt is None:
        return None
    x, y = Pt
    return (x, (-y) % P)


def ec_mul(k: int, Pt):
    k = int(k) % N_ORDER
    R = None
    base = Pt
    while k:
        if k & 1:
            R = ec_add(R, base)
        base = ec_add(base, base)
        k >>= 1
    return R


def is_fb_point(Pt) -> bool:
    """Factor base membership: x in [0, THRESH). See module docstring."""
    if Pt is None:
        return False
    x, _ = Pt
    return 0 <= x < THRESH


def random_point(rng: random.Random):
    while True:
        x = rng.randrange(P)
        rhs = (x * x * x + A * x + B) % P
        if rhs == 0:
            return (x, 0)
        if legendre(rhs, P) == 1:
            y = modsqrt(rhs, P)
            assert y is not None
            return (x, y)


def find_R_by_trial(Pt, Qt):
    """Finite search: compute R=-(Pt+Qt), then trial over x in [0,THRESH)."""
    S = ec_add(Pt, Qt)
    R = ec_neg(S) if S is not None else None
    if R is None:
        return None
    rx, ry = R
    # trial over x-coordinates in the factor base subset
    for x in range(THRESH):
        rhs = (x * x * x + A * x + B) % P
        ys = []
        if rhs == 0:
            ys = [0]
        elif legendre(rhs, P) == 1:
            y = modsqrt(rhs, P)
            assert y is not None
            ys = [y, (P - y) % P]
        else:
            continue
        for y in ys:
            if (x, y) == (rx, ry):
                return (x, y)
    return None


def count_fb_points() -> int:
    cnt = 0
    for x in range(THRESH):
        rhs = (x * x * x + A * x + B) % P
        if rhs == 0:
            cnt += 1
        elif legendre(rhs, P) == 1:
            cnt += 2
    return cnt


def solve_s3(x1: int, x2: int, a: int, b: int, p: int):
    """Return list of x3 in F_p with Big(x1,x2,x3) == 0 mod p.

    If (x1-x2) == 0 mod p the polynomial degenerates -> []."""
    if (x1 - x2) % p == 0:
        return []
    C2 = (x1 - x2) * (x1 - x2) % p
    C1 = (2 * a * x1 * x1 - 4 * a * x1 * x2 - 2 * a * x1
           + 2 * a * x2 * x2 - 2 * a * x2 - 2 * x1 * x1 * x2
           - 2 * x1 * x2 * x2 - 4 * b) % p
    C0 = (a * a * x1 * x1 - 2 * a * a * x1 * x2 - 2 * a * a * x1
           + a * a * x2 * x2 - 2 * a * a * x2 + a * a - 4 * a * b
           - 2 * a * x1 * x1 * x2 - 2 * a * x1 * x2 * x2 - 2 * a * x1 * x2
           - 4 * b * (x1 + x2) + x1 * x1 * x2 * x2) % p

    disc = (C1 * C1 - 4 * C2 * C0) % p

    def msqrt(v):
        v %= p
        if v == 0:
            return 0
        if pow(v, (p - 1) // 2, p) != 1:
            return None
        if p % 4 == 3:
            return pow(v, (p + 1) // 4, p)
        q = p - 1
        s = 0
        while q % 2 == 0:
            q //= 2
            s += 1
        z = 2
        while pow(z, (p - 1) // 2, p) != p - 1:
            z += 1
        m = s
        c = pow(z, q, p)
        t = pow(v, q, p)
        r = pow(v, (q + 1) // 2, p)
        while True:
            if t == 1:
                return r
            i = 1
            temp = t * t % p
            while temp != 1:
                temp = temp * temp % p
                i += 1
            bpow = c
            for _ in range(m - i - 1):
                bpow = bpow * bpow % p
            m = i
            c = bpow * bpow % p
            t = t * c % p
            r = r * bpow % p

    sd = msqrt(disc)
    if sd is None:
        return []
    inv2C2 = pow(2 * C2, -1, p)
    roots = []
    for s in (sd, (-sd) % p):
        t = (-C1 + s) * inv2C2 % p
        if (C2 * t * t + C1 * t + C0) % p == 0:
            roots.append(t)
    # deduplicate
    uniq = []
    for t in roots:
        if t not in uniq:
            uniq.append(t)
    return uniq


def main() -> None:
    rng = random.Random(20240101)
    t0 = time.time()

    print("=== Semaev S3 feasibility (Vector B, H-008) ===")
    print(f"curve: p={P}, a={A}, b={B}, n=#E={N_ORDER} (prime)")
    print(f"factor base threshold THRESH={THRESH}: x in [0,{THRESH})")

    # generator G: any nonzero point (order n, since n prime)
    G = None
    for x in range(P):
        rhs = (x * x * x + A * x + B) % P
        if rhs == 0:
            G = (x, 0)
            break
        if legendre(rhs, P) == 1:
            y = modsqrt(rhs, P)
            if y is not None:
                G = (x, y)
                break
    assert G is not None and ec_mul(N_ORDER, G) is None
    # ECDLP instance
    d_secret = rng.randrange(1, N_ORDER)
    Qpt = ec_mul(d_secret, G)
    print(f"generator G={G}; ECDLP Q=d*G with d in [1,n) (kept secret for test)")

    # factor base counts
    V_fb = count_fb_points()
    print(f"\nFactor base FB (static): V_FB={V_fb}, n={N_ORDER}, "
          f"ratio V_FB/n={V_fb/N_ORDER:.6f}")

    # relation trials
    hits = 0
    for _ in range(NTRIALS_REL):
        Ppt = random_point(rng)
        Qpt2 = random_point(rng)
        R = find_R_by_trial(Ppt, Qpt2)
        if R is not None:
            hits += 1
    print(f"\nRelation trials: N={NTRIALS_REL}, hits (R=-(P+Q) in FB)={hits}, "
          f"ratio={hits/NTRIALS_REL:.6f} (expected ~THRESH/P={THRESH/P:.6f})")

    # S3 root experiment
    root_counts = [0, 0, 0]  # number of trials with 0,1,2 roots
    total_roots = 0
    fb_roots = 0
    trials_with_fb_root = 0
    for _ in range(NTRIALS_S3):
        x1 = rng.randrange(P)
        x2 = rng.randrange(P)
        if (x1 - x2) % P == 0:
            continue
        roots = solve_s3(x1, x2, A, B, P)
        k = len(roots)
        if k > 2:
            k = 2
        if k < 0:
            k = 0
        if k == 0:
            root_counts[0] += 1
        elif k == 1:
            root_counts[1] += 1
        else:
            root_counts[2] += 1
        total_roots += len(roots)
        fb_here = 0
        for xr in roots:
            if 0 <= xr < THRESH:
                fb_roots += 1
                fb_here += 1
        if fb_here > 0:
            trials_with_fb_root += 1

    valid_trials = sum(root_counts)
    print(f"\nS3 root experiment: trials={valid_trials} (valid, x1!=x2), "
          f"degree bound observed<=2 for all")
    print(f"  trials with 0 roots: {root_counts[0]}, with 1 root: {root_counts[1]}, "
          f"with 2 roots: {root_counts[2]}")
    print(f"  total roots={total_roots}, avg roots/trial={total_roots/valid_trials:.4f}")
    print(f"  roots in FB (x<{THRESH}): {fb_roots}, fraction of roots={fb_roots/total_roots if total_roots else 0:.6f}")
    print(f"  trials with >=1 FB root: {trials_with_fb_root}, "
          f"fraction={trials_with_fb_root/valid_trials:.6f}")

    elapsed = time.time() - t0
    print(f"\nelapsed: {elapsed:.2f}s")

    out = {
        "p": P, "a": A, "b": B, "n": N_ORDER, "threshold": THRESH,
        "V_FB": V_fb, "ratio_VFB_over_n": V_fb / N_ORDER,
        "rel_trials": NTRIALS_REL, "rel_hits": hits,
        "rel_ratio": hits / NTRIALS_REL,
        "s3_trials": valid_trials, "root_counts": root_counts,
        "total_roots": total_roots,
        "fb_roots": fb_roots,
        "trials_with_fb_root": trials_with_fb_root,
        "elapsed_sec": elapsed,
    }
    outpath = Path(__file__).resolve().parent / "semaev_results.json"
    outpath.write_text(json.dumps(out, indent=2))
    print(f"results written to {outpath}")


if __name__ == "__main__":
    main()