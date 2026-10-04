# PREREGISTRATION -- committed BEFORE any R1-R4 number was measured.

Written after `selftest.py` reached 44/44 PASS (exit 0), before `r1_r4.py` was run.
Sign AND rough size are committed for each hypothesis.  Anything measured that
contradicts this file is a REFUTATION of the prediction, and is reported as such
rather than re-tuned until it agreed.

## The accounting law (*), derived exactly in `relcond_core.py`

    GAIN = (s_C/s_0) * q / (1 + q * c_cond/c_gen)

`q = P(C)` = fraction of candidates the condition admits.  **A condition that
rejects candidates can never beat the factor q it costs.**  For a balanced
character (q = 1/2) the ceiling is 1/2 -- a guaranteed >= 2x LOSS no matter how
strongly the smoothness rate is enriched.  This is algebra, checked in T3.

## R1 -- character conditioning

| # | condition | family | preregistered prediction |
|---|---|---|---|
| R1a | Jacobi `(g^x/n)` = +1 vs -1 | Stange | **ratio 1.00 +/- 0.15.** Mechanism: `(g^x/n) = (g/n)^x` is a function of `x mod 2` ONLY (T5, 3000 samples, 0 violations), so it carries zero information about the candidate's factorisation. |
| R1b | Jacobi `(a/n)`, `(b/n)` on `a^2-b^3` | NFS | **ratio 1.00 +/- 0.20.** Same reason: the Jacobi symbol of a random candidate is independent of its prime factorisation, because `V = prod p^f` and `(V/n) = prod (p/n)^f` mixes over independently-uniform `(p/n)`. |
| R1c | v2 of the candidate | both | **ratio 1.00 +/- 0.20.** 2-adic structure is where this programme's rates move (+-0.25), so this is the arm most likely to move -- but v2(V) is a *divisibility* statistic that the sieve already exploits. Prediction: no gain in cost per relation. |
| R1d | parity of `x` (the q=1 BYPASS of the q-cap) | Stange | **ratio 1.00 +/- 0.15, gain 1.00.** This is the ONE arm where conditioning is free, so it is the only arm where a real win is possible at all. Preregistered null. If this fires, it is the finding. |

**R1 overall preregistered verdict: NO GAIN. Expected gain 1.00 (range 0.85-1.15).**

## R2 -- the `2 - 1/p` excess, revisited

The programme established `P(p^k | a^2-b^3)/p^k = 2 - 1/p` for odd p, k >= 2, and
round 52 showed the excess lives entirely in the `p|b` corner and the sieve's mark
rate is exactly `r_p/p`.

**Preregistered prediction: conditioning the SEARCH on the `p|a, p|b` corner buys
nothing the sieve does not already take.** Reasons, stated before measuring:
1. The corner is a property of the `(a,b)` residue class, which the sieve reads
   off directly at no extra cost -- a search-time condition is strictly weaker.
2. Reaching the corner costs `q = 1/p^2` in rejections, so by (*) the gain is
   capped at `(s_C/s_0)/p^2`. Even a PERFECT enrichment cannot pay: `s_C/s_0`
   would have to exceed `p^2`.
3. Measured `s_C/s_0` is preregistered at **<= 2 - 1/p < 2**, i.e. below the bar
   `p^2 >= 9` by a factor of >= 4.5.

**R2 overall: gain <= 2/9 = 0.22, i.e. a >= 4.5x LOSS. This is a near-certain
negative and I predict it before running.**

## R3 -- structural striding

Structured generation: `(a,b) -> (a+t,b)`, fixed `a/b`, sublattice walks.

**Preregistered prediction: NO scheme beats uniform.** Round 48 already measured
the Stange analogue (stride at `x0 = n/4` gives 0.75-1.20x, consistent with noise)
and found the only real effect is the SMALL-VALUE degeneracy: `g^x mod n` is small
for small `x`, so `seq`/`stride` harvest trivially-smooth candidates and
manufacture a spurious kernel (84%/55% of `alpha_t` exactly zero).

Preregistered: any stride whose hit rate exceeds uniform by > 1.3x will be shown
to be the small-value degeneracy, by the `|V|` distribution and by the distinct-
value fraction. Expected cost per relation ratio: **1.00 (range 0.8-1.2).**

## R4 -- the decisive test: COST PER COLLECTED RELATION

Not the smooth-hit rate. Any scheme that finds smoother candidates at higher cost
per candidate is a LOSS.

Preregistered: **the winning gain is 1.00, and every conditioning arm except R1d
is bounded above by `q <= 1/2`, i.e. <= 0.50, before `c_cond` is counted.**
Held-out check: the R1d parity result is re-measured on FRESH moduli (different
seed, never used for tuning) and on a FRESH base `g`. Preregistered held-out gain:
**1.00 +/- 0.15.** A held-out gain above 1.15 would be the first evidence of a
real effect in this round.

## Regime limitation, stated up front

The real NFS regime has `pi(B*) ~ 10^15` - `10^33` (round 52). **It is not
instantiable on this host.** Everything below is measured at the REACHABLE
regime (36-56 bit semiprimes, `B <= 2^15`), where `u = ln N/ln B` is small enough
that smoothness rates are measurable. I claim nothing about `B*`.