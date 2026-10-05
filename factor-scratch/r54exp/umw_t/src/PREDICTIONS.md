# PREDICTIONS — written BEFORE running anything (discipline requirement)

Regime for all measurements: classical factoring, moduli generated locally, n = L^3 with
L = 2^k, so L = n^{1/3} EXACTLY (the (1/3,1/3) target shape). Band P0 = {p prime :
(2/3)sqrt(n) < p <= sqrt(n)}, a = 2/3, b = 1 (He-Sahai's own optimal band, Thm 1.1).

## P1 — exact t for random gaps, and its scaling

For a gap with random (a1,a2) of magnitude <= exp(n^{1/3}) = exp(L), the number of band primes
dividing a *random* difference D = a1*di + a2*dj is ~Poisson(mean lambda) with
lambda = sum_{p in P} 1/p ~ log(b/a)/log n = 2*log(1.5)/log n.

n = 2^24 (L=2^8): lambda ~ 0.0485, |Delta box| ~ 4L^2 = 2.6e5
n = 2^30 (L=2^10): lambda ~ 0.0390, |Delta box| ~ 4.2e6
n = 2^36 (L=2^12): lambda ~ 0.0326, |Delta box| ~ 6.7e7

Predicted max t over the Delta box, solving  |DeltaBox| * lambda^t / t!  ~ 1  i.e.
t_max ~ log|DeltaBox| / log(1/lambda):

  n=2^24: t_max ~ 4-5
  n=2^30: t_max ~ 5-6
  n=2^36: t_max ~ 6-7

i.e. **t_max grows like (2/3)*log(n)/log(log n) — extremely slowly.** PREDICTION: the three
predicted maxima differ by at most 1-2 across a 4096-fold range of n. Falsified if the maxima
track n^{1/3} (they must not, at these sizes).

## P2 — VACUITY CHECK (mandatory, from the task's methodology warning)

Predicted: the detector "D has >= 1 band prime divisor" fires on a MINORITY of differences.
Predicted fired fraction ~ lambda ~ 0.03-0.05. So PREDICT:
  fraction of Delta with t=0 is > 0.90   (NOT saturated)
  fraction with t>=1 is < 0.10
  fraction with t>=2 is < 0.005
If t=0 fires everywhere (or >=1 fires everywhere) the measurement is VACUOUS and must be
reported as such.

## P3 — lower-bound construction (positive control for the t detector)

Set a1 = 1, a2 = M-1 with M = prod of t chosen band primes. Then D(1,1) = 1 + (M-1) = M, so
all t primes divide it. Also a1*a2 = M-1 is coprime to M, so NO band prime is excluded from P.
PREDICTION: measured t is EXACTLY t (the requested count), for every t tested. This is the
POSITIVE CONTROL: the detector must fire at exactly the advertised strength.
NEGATIVE CONTROL: with a2 replaced by a value coprime to M, measured t must be <= 3.

## P4 — degree |B_p| vs the He-Sahai threshold sqrt(v)  (the H3 obstruction)

|B_p| = #{(i,j) in [0,L)^2 : p | b0 + a1*i + a2*j}. He-Sahai needs Delta >= sqrt(v/t).
  n=2^30: v ~ 1050 band primes, sqrt(v) ~ 32.  Typical |B_p| ~ L^2/p ~ 1.05e6/24000 ~ 44.
  Adversarial max |B_p| ~ L^2/p + L ~ 44 + 1024 ~ 1070.
PREDICTION (random gaps): max_p |B_p| ~ 60-90, i.e. **the L-edge term (order L) is NOT realised
randomly**; max|B_p| stays within a factor ~3 of the typical L^2/p value. This is the NEGATIVE
CONTROL for the "adversarial degree" obstruction: if max|B_p| were order L, that obstruction
would be live.
PREDICTION: at n=2^30 max|B_p| > sqrt(v) (~32), so the degree bound gives NO contradiction at
this size; and the asymptotic crossover sqrt(v) ~ n^{1/4}/sqrt(log n) vs max|B_p| ~ n^{1/6}
happens near n ~ 2^65.

## P5 — does t=0 ever happen for the ADVERSARIAL construction?
i.e. sanity: t should be a free parameter we can dial, not a saturated constant.