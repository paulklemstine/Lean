"""
Binary quadratic form (BQF) library for the class-group descent route.

Three independent implementations of "enumerate all reduced forms of
discriminant D", so that no single bug can produce a false positive:

  L1  brute_a       -- O(|D|) reference loop over a and b. Ground truth, small D only.
  L2  chain         -- Gauss division-chain successor rule. Fast, any D.
  L3  cypari2       -- qfbclassno(D), returns a COUNT only.

Validation chain (run by validate_pari.py):
  L1 == L3 on small D   -> validates PARI in the regime of use
  L2 == L3 on large D   -> validates the fast enumerator

THE HAZARD THIS REPLICATES: the programme has a recorded incident where
PARI's ellcard silently returns N+1 on composite N (memory
pari-ellcard-wrong-on-composite).  We therefore NEVER trust a single PARI
number; it is always checked against an independent computation.

SEED: none needed -- every function here is deterministic.  Randomness
enters only in instance generation (gen.py) which is explicitly seeded and
run twice.
"""

from math import isqrt
from functools import lru_cache


# --------------------------------------------------------------------------
# Reduction predicate
# --------------------------------------------------------------------------
def is_reduced(a, b, c, D):
    """Gauss reduced: a>0, c>0, -a < b <= a <= c, and b >= 0 if a == c."""
    if a <= 0 or c <= 0:
        return False
    if not (-a < b <= a <= c):
        return False
    if a == c and b < 0:
        return False
    return b * b - 4 * a * c == D


# --------------------------------------------------------------------------
# L1: brute force over (a, b).  O(sum_a a) = O(|D|).  Small D only.
# --------------------------------------------------------------------------
def brute_forms(D):
    """All reduced forms of discriminant D < -4, by exhaustive search."""
    assert D < 0 and D % 4 in (0, 1), "D must be a discriminant"
    out = []
    amax = isqrt((-D) // 3) + 2
    for a in range(1, amax + 1):
        for b in range(-a + 1, a + 1):
            if (b - D) % 2 != 0:          # b == D (mod 2)
                continue
            bb = b * b
            if (bb - D) % (4 * a) != 0:
                continue
            c = (bb - D) // (4 * a)
            # PRIMITIVE only: imprimitive forms are not classes of the
            # order of disc D, and including them inflates the count by
            # exactly 2x on D = -4pq (measured against qfbclassno).
            if a <= c and (a != c or b >= 0) and _gcd(_gcd(a, b), c) == 1:
                out.append((a, b, c))
    return out


# --------------------------------------------------------------------------
# L2: Gauss division chain.
# --------------------------------------------------------------------------
def _succ(a, b, c, D):
    """
    Successor of a reduced form (a,b,c) in the Gauss ordering.

    Derived, not recalled: apply S = [[0,-1],[1,0]], which maps
    (a,b,c) -> (c, -b, a).  Then shift b2 by multiples of 2c to bring it
    into the fundamental strip (-c, c].  Since a <= c this makes the
    result reduced without further work.
    """
    if a > c:
        return None
    if a == c:
        # (a,a,c) has b >= 0 by convention, so the next one is (a,-a,c).
        return (a, -b, c) if b > 0 else None
    # one S-step, then centre b2 into (-c, c]
    b2 = -b
    b2 -= 2 * c * ((b2 + c) // (2 * c))
    a2 = c
    c2 = (b2 * b2 - D) // (4 * c)
    if c2 < a2:
        return None
    return (a2, b2, c2)


def first_form(D):
    """Principal form, put into the first position of the Gauss ordering."""
    b0 = 0 if D % 2 == 0 else 1
    while (b0 * b0 - D) % 4 != 0:
        b0 += 1
    a = 1
    c = (b0 * b0 - D) // 4
    # reduce (1, b0, c0) -- a=1 is minimal so a single shift suffices
    if c < a:
        return None
    return (a, b0, c)


def chain_forms(D, cap=None):
    """
    Enumerate reduced forms of discriminant D < -4 in Gauss ordering
    (increasing leading coefficient).  Deterministic.

    `cap` limits the number of forms yielded (safety valve); if the chain
    is truncated, `truncated` is True -- a vacuous enumeration is worse
    than none, so the caller must check it.
    """
    out = []
    f = first_form(D)
    truncated = False
    if f is None:
        return out, truncated
    while f is not None:
        out.append(f)
        if cap is not None and len(out) >= cap:
            truncated = True
            break
        f = _succ(*f, D)
    return out, truncated


def chain_count(D, cap=5_000_000):
    """Count reduced forms of disc D via the chain, without storing them."""
    n = 0
    f = first_form(D)
    while f is not None:
        n += 1
        if n >= cap:
            return n, True
        f = _succ(*f, D)
    return n, False


# --------------------------------------------------------------------------
# The detector under test.
# --------------------------------------------------------------------------
def a_divides_D_hits(D, forms, trivial=(1, 4)):
    """
    A reduced form (a,b,c) of disc D with a | D and a not in {1,4} reveals a
    factor of D -- and for D = -4N that factor is a factor of N.

    Returns list of (index_in_enumeration, a, b, c).
    """
    out = []
    m = abs(D)
    for i, (a, b, c) in enumerate(forms):
        if a > 1 and a not in trivial and m % a == 0:
            out.append((i, a, b, c))
    return out


# --------------------------------------------------------------------------
# Pollard rho, with a step counter (the paired control).
# --------------------------------------------------------------------------
def pollard_rho_steps(n, seed):
    """
    Brent's rho with explicit iteration count.  Returns
    (factor or None, steps, start_seed, f_eval_calls).

    Seeded: same seed -> same trajectory -> same step count.
    """
    if n % 2 == 0:
        return 2, 0, seed, 0
    s = seed | 1
    y, c, m = s % n, (s * 3 + 1) % n, 128
    g = r = q = 1
    steps = 0
    evals = 0
    while g == 1:
        x = y
        for _ in range(r):
            y = (y * y + c) % n
            evals += 1
        k = 0
        while k < r and g == 1:
            ys = y
            for _ in range(min(m, r - k)):
                y = (y * y + c) % n
                evals += 1
                q = q * abs(x - y) % n
            g = _gcd(q, n)
            k += m
        steps += r
        r *= 2
        if r > 1 << 22:      # ~4e6 f-evals: rho's birthday scale
            break
    if g == n:
        # back off one step at a time
        g = 1
        while g == 1:
            ys = (ys * ys + c) % n
            evals += 1
            g = _gcd(abs(x - ys), n)
            steps += 1
    if g == n:
        return None, steps, seed, evals
    return g, steps, seed, evals


def _gcd(a, b):
    while b:
        a, b = b, a % b
    return a
