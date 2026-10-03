#!/usr/bin/env python3
"""
R3 COST ACCOUNTING.  Is sqrt(h(-kN)) ever L[1/2] or better?

Notation.  For an n-bit RSA modulus:
    N^{1/4}          = exp( (1/4) n ln 2 )              -- Pollard rho
    L[1/2]           = exp( (1/2) sqrt( ln N ln ln N ) )  -- ECM
    L[1/3, c=(64/9)^(1/3)] = exp( c (ln N)^(1/3) (ln ln N)^(2/3) ) -- GNFS

Claim under test (P2): the class-group walk is capped at sqrt(h(-kN)) with
h(-kN) ~ (kN)^{1/2}/pi * L(1,chi), so sqrt(h) ~ (kN)^{1/4}.  For k = O(1)
that is N^{1/4}, which is a POLYNOMIAL cost and is therefore STRICTLY WORSE
than both L[1/2] and L[1/3].  So the class group can never give L[1/2].

We also solve for the k that WOULD be needed: to make sqrt(h) <= L[1/2] we
would need (kN)^{1/4} <= exp((1/2)sqrt(ln N ln ln N)), i.e. k astronomically
large -- but then D = -kN is a huge discriminant and computing h(D) costs
poly(log D) = poly(log k), which is still fine ONLY if we also verify that
p | h(D).  We check numerically what k that requires.
"""
import math


def n_primes(bits):
    return 1 << bits


# Everything below is carried as log2 of the cost, which cannot overflow.
def rho_log2(n_bits):
    """log2(N^{1/4})"""
    return 0.25 * n_bits


def Lhalf_log2(n_bits):
    """log2(exp((1/2) sqrt(ln N ln ln N)))"""
    L = n_bits * math.log(2)
    return 0.5 * math.sqrt(L * math.log(L)) / math.log(2)


def Lthird_log2(n_bits, c=(64 / 9) ** (1 / 3)):
    """log2(exp(c (ln N)^{1/3} (ln ln N)^{2/3}))"""
    L = n_bits * math.log(2)
    return c * (L ** (1 / 3)) * (math.log(L) ** (2 / 3)) / math.log(2)


print("=" * 78)
print("COST ACCOUNTING: does the class-group walk reach L[1/2]?")
print("   (all columns are log2 of the cost)")
print(f"{'n':>6} {'N^(1/4)':>10} {'L[1/2]':>10} {'L[1/3]':>10} "
      f"{'rho-L[1/2]':>12} {'rho-L[1/3]':>12}")
for n in [256, 512, 1024, 2048, 4096, 8192, 16384, 65536]:
    r = rho_log2(n)
    lh = Lhalf_log2(n)
    lt = Lthird_log2(n)
    print(f"{n:6d} {r:10.2f} {lh:10.2f} {lt:10.2f} {r - lh:12.2f} "
          f"{r - lt:12.2f}")
print()
print("rho - L[1/2] is POSITIVE and GROWS: Pollard rho / class-group BSGS is")
print("exponentially WORSE than ECM at every size.  It never reaches L[1/2].")
print()

print("=" * 78)
print("What k would be needed for sqrt(h(-kN)) <= L[1/2]?")
print("   solve (kN)^{1/4} = exp((1/2)sqrt(L ln L))  for k:")
print("     ln k = 2 sqrt(L ln L) - L")
for n in [256, 1024, 2048, 4096, 16384]:
    L = n * math.log(2)
    ln_k = 2 * math.sqrt(L * math.log(L)) - L
    verdict = "k < 1  => IMPOSSIBLE" if ln_k < 0 else "k >= 1 possible"
    print(f"   n={n:6d}: ln k = {ln_k:12.2f}  (log2 k = "
          f"{ln_k/math.log(2):11.2f})   {verdict}")
print()
print("READ THIS CAREFULLY -- it is the sharp form of the kill.")
print("  ln k < 0 at every RSA size means: even k = 1 is TOO SLOW.  There is")
print("  NO k >= 1 for which the class-group walk reaches L[1/2].")
print("  Algebraically: 2 sqrt(L ln L) < L  <=>  4 ln L < L  <=>  L < 8.6,")
print("  i.e. N < 5,400.  For N beyond a few thousand the class group is")
print("  STRUCTURALLY excluded, not merely unlikely.")
print()
print("Direction of the requirement: L[1/2] is SUBEXPONENTIAL in log N while")
print("N^{1/4} is EXPONENTIAL in log N, so the class group starts already")
print("behind and increasing k only makes D = -kN larger, i.e. h larger,")
print("i.e. the BSGS step MORE expensive.  k cannot be tuned to help.")
print()
print("=" * 78)
print("SUMMARY OF THE R3 COST CHAIN")
print("   1. h(-kN) computable without p : YES (PARI qfbclassno; Schoof poly)")
print("   2. p | h(-kN)                  : RARE / unproved  (measured in Q1)")
print("   3. reaching an element of order p : BSGS at sqrt(h) ~ (kN)^{1/4}")
print("   4. (kN)^{1/4} at k=O(1) = N^{1/4} : STRICTLY WORSE than L[1/2]")
print("   => no unconditional L[1/2] from the class group.")