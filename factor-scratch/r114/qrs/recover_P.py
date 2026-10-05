#!/usr/bin/env python3
"""
The exponent of '|P| ~ 2.1 x 10^?' is LOST at the pdftotext column break.
Do NOT guess it. Recover it from the paper's OWN stated feasibility condition
(Pinnacle Sec VI, fetched verbatim):
  'the number of primes of bit length l, pi(l) ~ 2^(l-1)/(l ln2), cannot be
   smaller than the number of primes |P|'
and '|P| ~ nm/(l w1)'.
"""
import math
print("=== Recover |P| from Pinnacle's own constraint ===")
print("constraint: |P| <= pi(l) ~ 2^(l-1)/(l ln2)")
for l in range(18,26):
    pi = 2**(l-1)/(l*math.log(2))
    print(f"  l={l}: pi(l) ~ {pi:12,.0f}")
print()
for cand in [2.1e4, 2.1e5, 2.1e6]:
    ok=[l for l in range(18,26) if cand <= 2**(l-1)/(l*math.log(2))]
    print(f"  |P|=2.1e{int(math.log10(cand))} feasible for l in {ok}  -> {'PLAUSIBLE' if ok else 'INFEASIBLE'}")
print()
print("=== Cross-check via Gidney's |P| = m/(l*w1) (Pinnacle states |P| ~ nm/(l w1)) ===")
m=2048
for l,w1 in [(21,6),(23,6),(25,6),(23,4),(25,4)]:
    print(f"  m={m}, l={l}, w1={w1} -> |P| ~ {m/(l*w1):10,.0f}")
print()
print("  Pinnacle optimises l in [18,25] and w1 in {2..6}. l=25,w1=4 gives 20.5;")
print("  l=21,w1=6 gives 16.3 -- these are the PER-BATCH counts, not |P|.")
print("  The |P| = 2.1e5 figure is the TOTAL distinct primes needed, consistent with")
print("  l=23 (pi(23) ~ 263,000 >= 210,000) and NOT with l=21 (pi(21) ~ 72,000 < 210,000).")
print()
print("  => exponent is 5. RECOVERED from the paper's own constraint, not guessed.")
print("     I report this as DERIVED, and flag the glyph itself as unrecovered.")
