# Computational evidence

This note records the numerical exploration that guided the formal proof of
Talagrand's convex-distance inequality in `Catalog/Probability/`.  Everything
in Sections 1–3 is *exploratory*: the numbers were produced with floating point
arithmetic and are **not** machine-verified.  The general inequalities of which
those tables are instances *are* machine-verified, in
`Catalog/Probability/TalagrandAnalytic.lean` and
`Catalog/Probability/TalagrandProduct.lean`.  Section 4 records a check that is
verified inside Lean.

## 1. The interpolation step and the constant in the exponent

The inductive proof of `E[exp(c · d_T(·,A)²)] · P(A) ≤ 1` needs, for every
`r ∈ [0,1]`, a mixing parameter `lam ∈ [0,1]` with

    exp(c (1-lam)²) · r^(-lam) ≤ 2 - r.                      (★)

A grid search over `lam ∈ {0, 0.0005, …, 1}` gives, for the slack
`(2 - r) - min_lam(...)` on `r ∈ [0.8, 1)`:

| c    | worst r on [0.8,1) | slack there |
|------|--------------------|-------------|
| 0.25 | 0.999              | +1.0e-09    |
| 0.26 | 0.974              | −9.2e-06    |
| 0.30 | 0.874              | −1.0e-03    |

So `c = 1/4` is exactly the threshold: (★) holds for `c = 1/4` (with slack that
vanishes to third order as `r → 1`) and *fails* for every larger constant
tested.  The formalisation therefore targets `c = 1/4`, the classical optimal
constant; the proof is `Talagrand.exists_lambda_bound`.

For orientation, the minimum of the left-hand side of (★) at the two candidate
constants:

| r      | c = 1/8 : min value | c = 1/4 : min value | 2 - r  |
|--------|---------------------|---------------------|--------|
| 0.05   | 1.133148            | 1.284025            | 1.95   |
| 0.60   | 1.133148            | 1.284025            | 1.40   |
| 0.90   | 1.086714            | 1.098845            | 1.10   |
| 0.99   | 1.009897            | 1.009999            | 1.01   |
| 1.00   | 1.000000            | 1.000000            | 1.00   |

## 2. The scalar inequality behind (★)

With the optimal choice `lam = 1 + 2 log r` and `u = -log r ∈ [0,1/2]`,
inequality (★) becomes `exp(u - u²) ≤ 2 - exp(-u)`:

| u     | exp(u-u²) | 2 - exp(-u) | difference |
|-------|-----------|-------------|------------|
| 0.00  | 1.000000  | 1.000000    | 0.0000000  |
| 0.05  | 1.048646  | 1.048771    | 0.0001244  |
| 0.10  | 1.094174  | 1.095163    | 0.0009883  |
| 0.20  | 1.173511  | 1.181269    | 0.0077584  |
| 0.30  | 1.233678  | 1.259182    | 0.0255037  |
| 0.40  | 1.271249  | 1.329680    | 0.0584308  |
| 0.50  | 1.284025  | 1.393469    | 0.1094439  |

The difference is `u³/1 + O(u⁴)` near `0` — the inequality is *third-order
tight*, which is why the Lean proof needs quartic Taylor bounds on `exp`
(`Talagrand.exp_le_quartic`, `Talagrand.exp_neg_le_quartic`, both instances of
`Real.exp_bound`) rather than the quadratic ones.  No counterexample was found
on a `10^4`-point grid of `[0, 1/2]`.  The inequality is proved in Lean as
`Talagrand.exp_sub_sq_le`.

## 3. Counterexample hunt on the geometric step

The geometric heart of the induction is

    d_T(A, cons a y)² ≤ (1-lam)² + lam · d_T(A_a, y)² + (1-lam) · d_T(B, y)²,

where `A_a` is the section and `B` the projection of `A`.  A randomised search
(300 random configurations with alphabets of size 2 or 3, at most 4
coordinates, random subsets `A` of size at most 4, and `lam` on the grid
`{0, 0.1, …, 1}`, giving 2440 individual checks; the convex distances were
approximated by a grid search over the simplex with mesh `0.1`) reported
**0 violations**.  The inequality is now proved in Lean as
`Talagrand.dTsq_cons_le`.

Building the project did reveal that the earlier statement of `dTsq_mono` in
`TalagrandDefs.lean` was **false** without a nonemptiness hypothesis: for
`A = ∅` the defining set of the infimum is empty, so `dTsq ∅ x = 0` by the
junk-value convention, whereas `dTsq B x` can be positive.  The corrected
statement now carries `hA : A.Nonempty`.

## 4. Machine-verified spot check

One numerical instance is verified inside Lean rather than in floating point:
in the three-dimensional cube, the convex distance from the all-`true` point to
`{all false}` is exactly `3` (see the `example` following
`Talagrand.dTsq_singleton_eq_card` in
`Catalog/Probability/TalagrandHypercube.lean`).  This certifies that `dTsq` is
not identically zero and that the main inequality is not vacuous.
