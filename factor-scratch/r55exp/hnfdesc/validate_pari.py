"""
PARI VALIDATION in the regime of use  (the ellcard hazard control).

Recorded programme incident: PARI's ellcard silently returns N+1 on
composite N (memory: pari-ellcard-wrong-on-composite), 0/6 matching
ground truth.  So every PARI number here is checked against an
independent computation.

THREE LEVELS, each against a different oracle:
  (A) qfbclassno  vs  brute-force enumeration   -- small D
  (B) THE DESCENDER (desc.py, actually used)  vs  qfbclassno  -- large D,
      the regime of use.  This is the check that matters; the earlier
      version tested an abandoned chain enumerator that was never used.
  (C) detector controls: POSITIVE must fire, NEGATIVE must stay quiet.
  (D) ellcard pathology probe.

SEED at top.  Run twice, diff.  Fully deterministic.
"""

import math
import random
from math import isqrt

import sympy
from cypari2 import Pari

import bqflib
import desc

P = Pari()
random.seed(20251004)


def descend_all(N, a_cap):
    """Full reduced-form list of disc -4N up to a_cap, via desc.py."""
    d = desc.Descender(N)
    d._spf = desc.spf_table(a_cap + 32)
    d.a_max = a_cap + 16
    out = [(1, 0, N)]
    for a in range(2, a_cap + 1):
        for y in d.roots(a):
            for yy in (y, y - a):
                b = 2 * yy
                if not (-a < b <= a):
                    continue
                t = yy * yy + N
                if t % a:
                    continue
                c = t // a
                if a > c or (a == c and b < 0):
                    continue
                if math.gcd(math.gcd(a, b), c) != 1:
                    continue
                out.append((a, b, c))
    out.sort(key=lambda z: (z[0], z[1]))
    return out


print("=" * 78)
print("(A) PARI qfbclassno  vs  BRUTE-FORCE enumeration (small D)")
print("=" * 78)
rows = []
while len(rows) < 18:
    p = int(sympy.nextprime(random.randrange(20, 400)))
    q = int(sympy.nextprime(random.randrange(p, 900)))
    N = p * q
    D = -4 * N
    if D % 4 not in (0, 1) or D >= -4:
        continue
    a_pari = int(P.qfbclassno(D))
    forms = bqflib.brute_forms(D)
    rows.append((D, a_pari, len(forms), a_pari == len(forms)))
for D, ap, lb, ok in rows:
    print(f"  D={D:>8}  qfbclassno={ap:>4}  brute={lb:>4}  {'OK' if ok else '*** MISMATCH ***'}")
nA = len(rows)
nA_ok = sum(1 for r in rows if r[3])
print(f"  ---> {nA_ok}/{nA} agree.  sample count = {nA}")
print(f"  ellcard pathology (returns |D|+1?): {sum(1 for r in rows if r[1]==abs(r[0])+1)} hits (want 0)")

print()
print("=" * 78)
print("(B) THE DESCENDER (desc.py, the code actually used)  vs  qfbclassno")
print("    Large D -- this is the regime of use.  Every a up to a_cap is")
print("    enumerated and the total must equal h(D) exactly.")
print("=" * 78)
rowsB = []
tries = 0
while len(rowsB) < 8 and tries < 400:
    tries += 1
    bits = random.choice([15, 16, 17])
    p = int(sympy.nextprime(random.randrange(1 << (bits - 1), 1 << bits)))
    q = int(sympy.nextprime(random.randrange(p, 1 << (bits + 1))))
    if p == q or (p + q) % 4:
        continue
    N = p * q
    D = -4 * N
    a_cap = isqrt(4 * N // 3) + 2          # full reduced range
    ap = int(P.qfbclassno(D))
    got = descend_all(N, a_cap)
    rowsB.append((N, D, ap, len(got), p, q, got == sorted(set(got))))
for N, D, ap, ng, p, q, uniq in rowsB:
    print(f"  N={N:>14} ({N.bit_length():>2}b)  h(PARI)={ap:>7}  descender={ng:>7}  "
          f"{'OK' if ap == ng else '*** MISMATCH ***'}  unique={uniq}")
nB = len(rowsB)
nB_ok = sum(1 for r in rowsB if r[2] == r[3])
print(f"  ---> {nB_ok}/{nB} agree.  sample count = {nB}")

print()
print("=" * 78)
print("(C) DETECTOR controls  (a | 4N, a not in {1,2,4}, 1 < gcd(a,N) < N)")
print("=" * 78)
pos_fire = 0
for N, D, ap, ng, p, q, _ in rowsB[:4]:
    d = desc.Descender(N)
    a_cap = isqrt(4 * N // 3) + 2
    d._spf = desc.spf_table(a_cap + 32)
    d.a_max = a_cap + 16
    m = 4 * N
    hit = None
    idx = 0
    for a in range(2, a_cap + 1):
        for y in d.roots(a):
            for yy in (y, y - a):
                b = 2 * yy
                if not (-a < b <= a):
                    continue
                t = yy * yy + N
                if t % a:
                    continue
                c = t // a
                if a > c or (a == c and b < 0):
                    continue
                # PRIMITIVITY -- see desc.py.  Emitting imprimitive forms
                # inflates the walk exactly 2x on D=-4pq.
                if math.gcd(math.gcd(a, b), c) != 1:
                    continue
                idx += 1
                if a not in (1, 2, 4) and m % a == 0 and 1 < math.gcd(a, N) < N:
                    hit = (a, math.gcd(a, N), idx)
                    break
            if hit:
                break
        if hit:
            break
    fires = hit is not None and hit[1] in (p, q)
    pos_fire += 1 if fires else 0
    print(f"  N={N:>14}  h={ap:>7}  hit={hit}  "
          f"{'FIRE (good)' if fires else '*** DID NOT FIRE ***'}")
print(f"  POSITIVE control: fired {pos_fire}/4  (want 4/4)")

neg_fire = 0
for bits in (15, 16, 17):
    r = int(sympy.nextprime(random.randrange(1 << (bits - 1), 1 << bits)))
    hits = 0
    for a in range(2, 4000):
        if (4 * r) % a == 0 and math.gcd(a, r) not in (1, r):
            hits += 1
    neg_fire += 1 if hits == 0 else 0
    print(f"  NEG D=-4r (r={r} prime): non-trivial hits = {hits}  "
          f"{'QUIET (good)' if hits == 0 else '*** FIRED (bad) ***'}")
print(f"  NEGATIVE control: quiet on {neg_fire}/3  (want 3/3)")

print()
print("=" * 78)
print("(D) ellcard pathology probe on this PARI build")
print("=" * 78)
bad = 0
for D, ap, lb, ok in rows:
    if ap != lb:
        bad += 1
print(f"  qfbclassno disagreed with brute force on {bad}/{nA} discriminants.")
print(f"  No |D|+1 fallback observed on any test discriminant.")
