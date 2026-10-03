# PREREGISTRATION (written BEFORE any measurement)

## H (the hypothesis under test)
F(N) := box_relation_rate(N) / scan_relation_rate(N) grows as a power law F = N^alpha.

## PREDICTION, sign and rough size, reasoned from the arithmetic BEFORE measuring

l(m,c,u,v) = 4u^4 + 8 m u^3 v - 4 c u v^3 + c v^4 m = L*m + K,
   L = 8 u^3 v + c v^4,   K = 4 u^4 - 4 c u v^3.

* BOX: c in CPOOL, |c| <= 31 (O(1)).  m ~ N^(1/3).  So |l| ~ m*H^4 ~ N^(1/3) H^4,
  sqrt|l| ~ N^(1/6) H^2.  Square density ~ l^(-1/2) -> rate ~ N^(-1/6).
* SCAN: c := m^3 mod N, |c| ~ N/3.  Dominant term c*v^4*m ~ N^(4/3) H^4,
  sqrt|l| ~ N^(2/3) H^2.  rate ~ N^(-2/3).

=> F ~ N^(-1/6) / N^(-2/3) = **N^(+1/2)** under the naive 1/(2 sqrt l) density.

The file itself says the naive density is wrong (l is not a random integer; 99-157x, all
2-adic; T(M) from M^0.50 to M^0.70, i.e. effective density ~ l^(-0.35)).  Re-deriving with
density ~ l^(-beta):
  rate_box  ~ (N^(1/3) H^4)^(-beta) = N^(-beta/3)
  rate_scan ~ (N^(4/3) H^4)^(-beta) = N^(-4 beta/3)
  F ~ N^(beta)
beta=0.5 -> alpha=0.5 ; beta=0.35 -> alpha=0.35.

**PREDICTION: alpha is POSITIVE and in the range 0.3 to 0.6.** Not zero.

## The mechanism I predict, stated in advance so it can be refuted
A hand-picked pool of fixed size 16 is a CONSTANT factor and CANNOT produce growth in N.
The growth must come from |c|: the box has |c| = O(1), the scan has |c| ~ N/3.  So the
size-dependent part is the *magnitude* of c, and the pool contributes only a constant.
I predict: F(N) tracks the scan's |c| ~ N, i.e. F ~ (N/3 / 31)^beta up to a constant,
and replacing CPOOL by ALL integers in [1,31] changes F by a CONSTANT (pool composition),
NOT by a growth.

## What I will NOT assume
I will not assume the reported 47x and 326x.  I recompute both arms myself.

## Falsifiers
* If F is flat in N within CI -> alpha ~ 0, the exponent survives, "supply dead at 128
  bits" is unaffected by this.
* If alpha > 0 with alpha ~ 0.35-0.5 -> true supply exponent -(1/6 + alpha) ~ -0.5 to -0.67,
  and the record's -(1/6) is wrong by a power of N.

## CONTROL (mandatory, gates everything)
My scan sampler must reproduce the scan's own reported chi_P = -1 fraction ~ 23%
before any box/scan comparison is trusted.
