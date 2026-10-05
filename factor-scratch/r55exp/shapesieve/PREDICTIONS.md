# Predictions, written BEFORE any measurement

All moduli generated locally, n < 2^40. Nothing of cryptographic interest is factored.

## P1 (screening / equidistribution) — exp1
Let B = 50, P_B = prod of primes <= B. Families of n of size ~2^40:
- S  ("shaped, invisible"):  n = a^2 b, a,b primes, a > B  (so no factor in the factor base)
- R  ("random"):            n = p q, p,q primes both > B
- R1,R2 (negative ctrl):    R split into two halves, tested against each other
- D1 (positive ctrl):       n = c d, c prime <= B, d prime  -- a factor IS in the base
- D2 (positive ctrl):       n = a^2, a prime -- maximally visible shape

PREDICTION P1a: the vector (chi_q(n))_{q <= B} is equidistributed on {+1,-1}^pi(B) for
  family S, i.e. chi_2 test on 2^k samples is consistent with the null.
PREDICTION P1b: D1 must fire (chi_c(n) = 0 because c | n). If D1 does NOT fire, the
  detector is broken and P1a is uninterpretable.
PREDICTION P1c: D2 must fire violently (x^2 - a^2 = (x-a)(x+a): the marks are maximally
  non-generic). If D2 does not fire, the detector is vacuous and P1a is uninterpretable.
PREDICTION P1d: R1 vs R2 must NOT fire. This calibrates the false-positive rate; without
  it, "S does not fire" is uninterpretable.
PREDICTION P1e: S vs R must NOT fire on the Legendre vector, on the mean of V(n) =
  #{x in [0,X) : gcd(x^2-n, P_B) = 1}, and on the variance of V(n).

## P2 (sieve cost is shape-blind) — exp1
PREDICTION P2: optimal sieving cost per surviving relation, measured as
  c(B) = X * sum_{q<=B} 1/q  operations  and  survivors = V(n),
is identical across shapes a^2 b / a^3 b / p q / p^2 q at fixed n and fixed B, to within
Poisson error. In particular the per-cell ratio (cost/relation)/(cost/relation) for shape
vs pq is 1.000 +- Poisson error, NOT 0.634 or whatever the crossover table implies.

## P3 (shape readability window) — exp2
For n = a^k b with a <= b, a is readable by a bounded window of trial divisions around
n^{1/(k+1)} only when b/a is in a narrow band; specifically a = floor(n^{1/(k+1)} * (b/a)^{-k/(k+1)})
so the window has width ~ (b/a)^{k/(k+1)}.
PREDICTION P3: the "free shape" window has multiplicative width W = (b/a)^{k/(k+1)}, and
  rho needs sqrt(a) trial steps. The corpus's claim "the shape is free to read off n" is
  true only when W = O(1), and then reading it HAS ALREADY FACTORED n. Where W > 1, the
  shape is not free and rho is cheaper by sqrt(a)/W. There is no window where the shape
  is free AND a sieve is still needed.

## P4 (regime disjointness) — exp3
PREDICTION P4: for every shape and size, min(rho, index-calculus) is attained by exactly
  one method, and the two regimes do not overlap:
  (A) minFac n <= L_n[2/3, 2c]  => rho cost <= L_n[1/3, c] = index-calculus cost
  (B) minFac n >  L_n[2/3, 2c]  => shape descriptor confined to [n^{o(1)}, n^{1/2}],
      and the sieve is shape-blind, so the shape buys nothing over the sieve it must beat.
Per-cell reporting. Cells with < 20 expected events labelled UNDERPOWERED.

## P5 (decomposition gain) — exp3
If the shape of n = a^k b were free, the best shape-aware method is "divide out a, sieve
the cofactor b", whose L[1/3] leading constant is c * (1/(k+1))^{1/3}, a factor
(k+1)^{-1/3} = 0.693 for k=2.
PREDICTION P5: this gain is VOID, because reading the shape for free (P3) means a is
  already a factor, so there is nothing left to sieve. The gain and the freeness are
  mutually exclusive. Verify by checking that in every regime where the L[1/3] gain is
  real, the shape is NOT free.
