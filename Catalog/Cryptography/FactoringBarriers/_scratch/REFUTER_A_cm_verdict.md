# REFUTER A verdict — CM "non-search locator" (discriminant inversion)

**KILLED.** The hypothesis's positive, "I believe NEW" quantitative correction is an
**instrument artifact**. The measurement code `hcp.py` computes WRONG class polynomials,
and with the correct polynomials the claim is not merely wrong but **reversed**.

## 1. The instrument fails its own integrality test

A Hilbert class polynomial is monic in Z[X], so every elementary symmetric function of
the j-values must be an exact integer. `hcp.py` violates this for 14 of 22 tested D
(deviations up to 0.49, i.e. ~half an integer — not rounding):

    D=-23 h=3  max|e_k - round(e_k)| = 1.8e-01   NOT a class polynomial
    D=-47 h=5  ...                     = 4.7e-01   NOT a class polynomial
    D=-71 h=7  ...                     = 4.7e-01   NOT a class polynomial
    (D=-15,-20,-24,-35,-40,-51,-84,-88,-120 pass — these are the h=2 / a=c cases)

**Root cause:** `hcp.jinv` returns `mp.re(...)` of j. For a reduced form `(a,b,c)` with
`a<c`, j(tau) is COMPLEX (e.g. D=-23, form (2,1,3): j = 737.85 + 1764.02i). The inverse
form `(a,-b,c)` gives the conjugate 737.85 - 1764.02i. Taking Re() assigns the SAME
number to both, producing a spurious near-double root:

    D=-23: (2,1,3) and (2,-1,3) -> Re(j) = 737.84998496668410275  (bitwise identical)

Note D=-15 PASSES only because its forms are (1,1,4),(2,1,2) with a=c — no complex j.
So the instrument is right exactly where the hypothesis did not test it hardest.

## 2. Ground truth (PARI/GP `polclass`) contradicts it

    PARI  H_-23 = x^3 + 3491750x^2 - 5151296875x + 12771880859375
    hcp.py H_-23 = x^3 + 3491750x^2 - 5154408638x + 1901791019066
    PARI  H_-47 = x^5 + 2257834125x^4 - 9987963828125x^3 + ... (x-coeff -9987963828125)
    hcp.py H_-47 = [1, 2257834125, -9990222264392, 15984014811287500, ...]

The "bit-for-bit match" cross-validation on D=-15 was a false reassurance: it is the one
family (a=c) where the Re() bug cannot fire. The x^2 coefficient of H_-23 (3491750) agrees
only because it is the trace, which is a real number and survives; the x and constant
coefficients — which are NOT integers under the bug — are wrong.

## 3. The central claim is not just unsupported but REVERSED

Hypothesis: "the relevant group is the Galois group of the SPLITTING FIELD of H_D (S_h,
density 1/h! for complete splitting)."

That is a **category error**. The splitting field of H_D is the RING CLASS FIELD, whose
Galois group is Cl(D) ⋊ C2 of order **2h**, not S_h of order h!. Measured on the TRUE
polynomials, 1437 primes < 12000:

    D      h   true P(r_p=h)   1/(2h)    1/h!      off by
   -23     3      0.16075     0.16667  0.16667      1x     <- coincidence: 3! = 2*3
   -47     5      0.09464     0.10000  0.00833     11x
   -71     7      0.06402     0.07143  0.00020    323x
  -191    13      0.03410     0.03846  ~0      2.1e8x

The 1/h! prediction is off by a factor ~h!/2h, which **explodes with h**. The hypothesis
read its own 1/h!-vs-1/h test as PASSING at h=3 — where 3! = 6 = 2*3 makes the two
hypotheses numerically identical. The discriminating cases (h=5,7) were the broken ones.

## 4. Most importantly: the FILE IS RIGHT and the hypothesis is WRONG

On the r_p = h branch, S = r_p(q - r_q) + (p - r_p)r_q = h*q, so trials = N/S = pq/(hq) = p/h,
and work = degH * trials = h * (p/h) = **p**. **The class number cancels EXACTLY.**

Measured directly on true polynomials, E[h/r_p | method works]:
    D=-23 h=3  -> 2.508 (vs h=3)
    D=-47 h=5  -> 4.335 (vs h=5)
    D=-71 h=7  -> 6.280 (vs h=7)
    D=-191 h=13-> 11.905 (vs h=13)
— i.e. ~0.9*h, converging to h, exactly the cancellation `Capstone.lean` states, not the
"linear PENALTY of ~0.75h" the hypothesis claimed. The hypothesis's claim that "the file's
sharpness statement is quantitatively WRONG in the average case" is FALSE. The
`E[r_p] = 1` observation survives, but it is the mean of a `Cl(D)⋊C2` fixed-point
distribution, and it does NOT imply a penalty.

Also note the "bonus cross-validation" of the repo (H15 = X^2 + 191025X - 121287375) is
correct — but it validated the one D where the bug is silent.

## 5. The locator part (part 1 of the KILL) is sound but is a RE-STATEMENT

`finite_family_table_fails` in `/home/raver1975/lean/Catalog/Cryptography/SingularModuli/Capstone.lean`
already kills the fixed-j0 discriminant search. The hypothesis's measurement (2.4 primes
per j0, all <= |H_D(j0)|) is a correct restatement of "a fixed integer has finitely many
prime divisors". This is honest and correctly labelled a KILL, but it is not new, and
NegativeResults.lean row 21 already covers "read the factorization off a fixed arithmetic
structure / fixed reduced form of fixed discriminant".

## 6. Citation check (Rule 5)

- arXiv:2601.11131 EXISTS and is correctly titled. Opened the abs page via WebFetch:
  "Deterministic methods for finding elements of large multiplicative order",
  David Harvey and Markus Hittmeir, math.NT, 13pp, submitted 16 Jan 2026, rev 5 Jun 2026.
  NOTE: the hypothesis only opened the ABSTRACT, and the abstract actually says later work
  relaxed the size condition to N^(1/6) and THIS paper removes the condition entirely —
  which sits awkwardly with the campaign's "deterministic order-finding FELL" framing. Not
  load-bearing for the kill, but the hypothesis's own caveat is accurate.
- `Capstone.lean` line 32 quote is VERBATIM ACCURATE (checked).
- `RootCount.lean` docstring quotes are VERBATIM ACCURATE (checked).
- No phantom citations found. The failure here was not attention to sources — it was a
  broken instrument that was never falsified against an independent oracle.

## What survives / what to salvage

The genuinely reusable lesson (and it is a RETROSPECTIVE correction, not a new method):
**the Re() bug means any singular-moduli measurement in this campaign using `hcp.py` is
invalid for every D with a<c reduced forms — i.e. every h>=3 discriminant.** Any prior
result computed that way must be recomputed with PARI `polclass` or Sage `hilbert_class_polynomial`.
The E[r_p] ~ 1 fact should be re-derived from Cl(D)⋊C2, and the class-number cancellation
should be recorded as CONFIRMED, not as a linear penalty.
