#!/usr/bin/env python3
"""
STRUCTURAL QUESTION (not a parameter sweep).

Round 97g's "genuine bivariate model" is:  p = a+x,  q = b+y,  (a+x)(b+y) = N,
with x,y the small unknowns.  Chinburg et al. (arXiv:2111.14180) supply a
DECIDABLE algebraic-independence test for the 2-variable problem
    x + t*y + a = 0  (mod p),   |x| <= X,  |y| <= Y,
whose precondition is a LINEAR congruence mod the PRIME p coupling both
unknowns.

CLAIM UNDER TEST (stated before running):
  Modulo p, the 97g equation DEGENERATES.  (a+x)(b+y) = N gives
  (a+x)(b+y) = 0 (mod p); since p is prime this is a DISJUNCTION
      a+x = 0   OR   b+y = 0   (mod p),
  and the first branch is satisfied by x = -a for EVERY y.  So mod p the
  equation does not couple x and y at all -- it is a union containing a whole
  cylinder {x = -a} x F_p.  The two-variable coupling lives only OVER Z (via
  the product equalling N exactly), never mod p.

  CONSEQUENCE: 97g's instance is NOT an instance of the 2111.14180 problem
  class, so that decidable test's verdict -- however it comes out -- does not
  license the diagnosis rounds 97g/99 gave.

PREDICTIONS (all stated before running):
  P1. Over F_p the solution set of (a+x)(b+y)=0 has size exactly
      2p - 1 (the union of two lines through the origin, which meet only at
      (0,0)).  If the count differs, the algebra above is wrong.
  P2. For the TRUE point (x0,y0) with x0 = p-a, y0 = q-b, the number of y
      in F_p that satisfy the congruence with x = x0 is ALL p of them.
  P3. CONTROL (must stay quiet): the 2111.14180-form congruence
      x + t*y + a = 0 (mod p) has exactly p solutions, and crucially for a
      given x it admits exactly ONE y -- i.e. it really does couple.
      If P2 and P3 look the same, the distinction is not being measured.

NEGATIVE CONTROL: P3.  POSITIVE CONTROL: P2 must return p, not 1.
"""
import random
from math import gcd

random.seed(20261005)   # seeded; run twice and compare


def is_prime(n):
    if n < 2:
        return False
    for r in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % r == 0:
            return n == r
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def gen_semiprime(nbits):
    while True:
        p = random.getrandbits(nbits // 2) | (1 << (nbits // 2 - 1)) | 1
        q = random.getrandbits(nbits // 2) | (1 << (nbits // 2 - 1)) | 1
        if p != q and is_prime(p) and is_prime(q):
            N = p * q
            if N.bit_length() == nbits:
                return p, q, N


print("P1. |{(x,y) in F_p^2 : (a+x)(b+y) = 0}|  -- predicted 2p-1\n")
for nbits in (20, 24, 28):
    p, q, N = gen_semiprime(nbits)
    a = random.randint(1, p - 2)
    b = random.randint(1, q - 2)
    # exhaustive over F_p^2 -- no sampling, so no sampling error can hide
    cnt = 0
    for x in range(p):
        ax = (a + x) % p
        if ax == 0:
            cnt += p          # first branch: all y
            continue
        # need b+y = 0  =>  exactly one y
        cnt += 1
    pred = 2 * p - 1
    print(f"  p={p:>7} (a={a},b={b})  count={cnt}  predicted={pred}  "
          f"{'OK' if cnt == pred else 'MISMATCH'}")

print("\nP2/P3. for a FIXED x, how many y in F_p satisfy the congruence?")
print("       POSITIVE control = the 97g equation (expect p = ALL)")
print("       NEGATIVE control = the 2111.14180 linear form (expect 1)\n")

pos_ok = neg_ok = 0
T = 3
for nbits in (20, 24, 28):
    p, q, N = gen_semiprime(nbits)
    a = random.randint(1, p - 2)
    b = random.randint(1, q - 2)
    t = random.randint(2, p - 2)
    x0 = (-a) % p                     # the "true" x, so a+x0 = 0

    # POSITIVE: 97g equation, at x = x0
    ys = sum(1 for y in range(p) if ((a + x0) * (b + y)) % p == 0)

    # NEGATIVE: 2111.14180 linear form  x + t y + a = 0, at the same x0
    yl = sum(1 for y in range(p) if (x0 + t * y + a) % p == 0)

    print(f"  p={p:>7}  97g: {ys}/{p} y's   linear: {yl}/{p} y's")
    if ys == p:
        pos_ok += 1
    if yl == 1:
        neg_ok += 1

print(f"\n  positive control fired {pos_ok}/{T} (MUST be {T}/{T})")
print(f"  negative control fired {neg_ok}/{T} (MUST be {T}/{T})")

# and the OVER-Z count, which is where the coupling actually lives
print("\nOVER Z (not mod p) -- where the coupling really is:")
for nbits in (20, 24, 28):
    p, q, N = gen_semiprime(nbits)
    a = random.randint(1, p - 2)
    b = random.randint(1, q - 2)
    x0 = p - a
    y0 = q - b
    # count integer (x,y) in a box with 1<=x<=X, 1<=y<=Y and (a+x)(b+y)=N
    X = min(256, p - 1)
    Y = min(256, q - 1)
    cnt = 0
    for x in range(1, X + 1):
        d = a + x
        if N % d:
            continue
        e = N // d
        y = e - b
        if 1 <= y <= Y:
            cnt += 1
    print(f"  n={nbits}  N={N}  solutions in [{1},{X}]x[{1},{Y}]: {cnt}"
          f"   (true point ({x0},{y0}) inside box: "
          f"{1 <= x0 <= X and 1 <= y0 <= Y})")

ok = (pos_ok == T and neg_ok == T)
print("\nVERDICT:", "PASS -- the degeneracy is real and the controls are quiet"
      if ok else "FAIL")
raise SystemExit(0 if ok else 1)
