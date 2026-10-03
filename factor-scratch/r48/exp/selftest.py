"""SELF-TEST: every instrument must be checked before any threshold it
measures can be believed.  Run this FIRST.  Exit 0 = all pass.
"""
import random
import sys
import itertools

import sympy
from sympy import Symbol, Poly

from lll import _det_int, lll as hand_lll, verify as hand_verify
from reduce import reduce_fpylll, HAVE_FPYLLL
from coppersmith import (polymul, polypow, poly_eval, poly_trim,
                         integer_roots, univariate_lattice)

fails = []


def check(name, cond, extra=""):
    print("  [%s] %s%s" % ("PASS" if cond else "FAIL", name,
                           "" if cond else "   " + str(extra)))
    if not cond:
        fails.append(name)


print("=" * 74)
print("SELF-TEST -- the instruments, before they are used")
print("=" * 74)

# 1. exact integer determinant (Bareiss) against permutation expansion
print("\n1. exact determinant")
bad = 0
rng = random.Random(5)
for _ in range(200):
    n = rng.randint(2, 6)
    M = [[rng.randint(-40, 40) for _ in range(n)] for _ in range(n)]
    tot = 0
    for perm in itertools.permutations(range(n)):
        s = 1
        for i, j in enumerate(perm):
            s *= M[i][j]
        inv = sum(1 for i in range(n) for j in range(i + 1, n) if perm[i] > perm[j])
        tot += (-1) ** inv * s
    if _det_int(M) != tot:
        bad += 1
check("Bareiss determinant == permutation expansion (200 random)", bad == 0, bad)

# 2. LLL preserves the determinant and satisfies Lovasz
print("\n2. lattice reduction")
check("fpylll available", HAVE_FPYLLL)
bad = 0
for _ in range(20):
    d = rng.choice([5, 8, 12, 16])
    B = [[rng.getrandbits(600) for _ in range(d)] for _ in range(d)]
    din = _det_int(B)
    R = reduce_fpylll(B)
    if abs(din) != abs(_det_int(R)):
        bad += 1
    probs = hand_verify(B, R)
    if probs:
        bad += 1
check("reduction preserves det and meets Lovasz (20 lattices)", bad == 0, bad)

# 3. polynomial arithmetic
print("\n3. polynomial arithmetic")
x = Symbol("x")
check("polymul", polymul([1, 1], [1, 1]) == [1, 2, 1])
check("polypow", polypow([1, 1], 3) == [1, 3, 3, 1])
check("poly_eval", poly_eval([1, 2, 1], 3) == 16)
check("poly_trim keeps a nonzero leading coeff",
      poly_trim([0, 0, 5]) == [0, 0, 5])
check("poly_trim drops trailing zeros (ascending order)",
      poly_trim([1, 0, 0]) == [1] and poly_trim([0, 0, 0]) == [0])

# 4. exact integer root finding -- this failed three ways before it worked
print("\n4. exact integer roots (the component that broke three times)")
cases = [((x - 2) * (x - 3), [2, 3]),
         ((x - 3) ** 2, [3]),
         ((x + 2) * (x + 5), [-5, -2]),
         ((x - 2) * (x - 3) * (x - 7), [2, 3, 7]),
         (x * (x - 1) * (x - 4), [0, 1, 4]),
         (x ** 2 + 1, [])]
for f, expect in cases:
    asc = [int(co) for co in Poly(f, x).all_coeffs()][::-1]
    got = integer_roots(asc)
    check("roots of %-24s" % str(f).replace(" ", ""), got == expect,
          "got %s expected %s" % (got, expect))
# a large-coefficient polynomial with a big integer root
big = (x - 12345678901234567890) * (x + 98765432109876543210)
asc = [int(co) for co in Poly(big, x).all_coeffs()][::-1]
got = integer_roots(asc)
check("roots of a 64-bit-coefficient quadratic",
      got == [-98765432109876543210, 12345678901234567890], got)

# 5. the Coppersmith lattice really vanishes mod p^m at the true root
print("\n5. Coppersmith lattice is well formed")
from control import make_instance
p, q, N = make_instance(128, 1)
unk = 24
a = (p >> unk) << unk
X = 1 << unk
x0 = p - a
rows, scale = univariate_lattice([a, 1], N, X, 10, 10)
ok = True
for r in rows:
    rec = [r[c] // scale[c] for c in range(len(r))]
    if poly_eval(rec, x0) % (p ** 10) != 0:
        ok = False
        break
check("every basis row vanishes mod p^m at the true x0", ok)
check("lattice is square", len(rows) == 20 and all(len(r) == 20 for r in rows))

# 6. the attack actually recovers p at a known-good point
print("\n6. end-to-end attack at a known-good point")
from coppersmith import univariate_small_roots
found = False
for (m, t) in ((10, 10), (14, 14), (18, 18), (20, 20)):
    roots, diag = univariate_small_roots([a, 1], N, X, m=m, t=t,
                                         mod_is_factor=True, cross_check=False)
    if roots and (a + roots[0]) == p:
        found = True
        break
check("recovers p at X=2^%d (inside the N^{1/4} regime)" % unk, found)

print("\n" + "=" * 74)
if fails:
    print("SELF-TEST FAILED: %d check(s) -- %s" % (len(fails), fails))
    sys.exit(1)
print("SELF-TEST PASSED -- every instrument checks out.")
sys.exit(0)
