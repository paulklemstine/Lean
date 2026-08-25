# Computational evidence — POSITIONAL-RATE-LINK (exp 580 / paper 230)

All numbers below were produced with Lean `#eval` (Float arithmetic) in this
toolchain; the qualitative claims they support are the ones that are *proved*
in `Catalog/Probability/PositionalRateLink*.lean`.  Nothing here is used as a
step of any proof.

## 1. The harmonic decile profile (window ratio `r = 2`)

`hc r u = log(1 + (r−1)u) / log r` is the CDF proved in
`PositionalRateLinkHarmonic.lean` (`harmCDF`).  Its ten decile masses for
`r = 2`:

| decile | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| mass | 0.13750 | 0.12553 | 0.11548 | 0.10692 | 0.09954 | 0.09311 | 0.08746 | 0.08246 | 0.07800 | 0.07400 |

Sum = 1.000000 (matches `decileMass_sum`), the profile is monotonically
declining, and the leading decile 0.1375 > 0.1 (matches `edge_decile_excess`).

## 2. The discrete `1/j` carrier converges to it

Normalised discrete weight of the leading decile of the doubling window
`(10L, 20L]`, i.e. `(H(11L) − H(10L)) / (H(20L) − H(10L))`:

| L | 1 | 10 | 100 | 1000 | limit |
|---|---|---|---|---|---|
| value | 0.135934 | 0.137344 | 0.137488 | 0.137502 | 0.1375035 = log(1.1)/log 2 |

This is exactly the content of `tendsto_discrete_decile_harmCDF`
(`Catalog/Probability/PositionalRateLinkDiscrete.lean`): convergence is fast and
monotone from below, and the limit exceeds the uniform value `1/10`.

## 3. Consistency of the three tercile edge-decile masses

Exp 580 reports edge-decile masses 0.229 / 0.245 / 0.230 in the
hit-poor / mid / hit-rich terciles.  Inverting `hc r 0.1 = mass` for the window
ratio `r` (bisection, 200 steps):

| tercile | edge-decile mass | implied window ratio `r` |
|---|---|---|
| poor | 0.229 | 6.17 |
| mid  | 0.245 | 7.24 |
| rich | 0.230 | 6.23 |

The hit-poor and hit-rich terciles imply window ratios agreeing to about 1%,
which is the descriptive counterpart of the failed interaction test: a *single*
harmonic law with one window ratio reproduces both extreme terciles.  (The
observed masses are far above the `r = 2` value 0.1375 because the scanned
window is much wider than a doubling; the *shape* law, not the ratio, is what
`edge_decile_excess_replicates` asserts to be tercile-independent.)

## 4. Sanity check of the layer-independence constructions

`overdispersion_without_profile_heterogeneity C` builds the model with weights
`(1/2, 1/2)`, rates `(1, 1+s)` and `s = 4|C| + 4`, all profiles equal to
`(1/2, 1/2)`.  Its dispersion excess is `Var − Mean = s²/4` against
`Mean = 1 + s/2`; e.g. for `C = 10`, `s = 44`, excess `= 484`, mean `= 23`, so
`excess / mean = 21 ≥ C`.  The companion construction has constant rates
(`Var = Mean = 1`) and profiles `(1,0)`, `(0,1)` at total-variation distance 1.
Both directions are verified as theorems, not just numerically.

## 5. Counterexample hunt

* Searched for a way to make the pooled between-strata contrast exceed the
  pairwise profile heterogeneity: impossible, and the impossibility is now the
  theorem `strata_TV_le_heterogeneity` (the pooled profile is a convex
  combination, so the contrast is a double convex combination of pairwise
  differences).
* Searched for a separated logistic design whose likelihood attains its
  supremum: impossible, and this is `logistic_no_maximizer`.  This confirms the
  ledger flag that the control-arm family-B fit was a quasi-separation artefact
  rather than a signal.
* No counterexample was found to `harmCDF r u > u` for `0 < u < 1 < r`; it is
  now proved from strict Bernoulli for real exponents.

## 6. OEIS

The decile masses are transcendental logarithms rather than an integer
sequence, so no OEIS entry applies.  The underlying discrete weights are partial
sums of the harmonic series (A001008 / A002805 for numerators/denominators of
`H_n`), which is the sequence already used by the arithmetic-side file
`Catalog/NumberTheory/FermatPositionDensity.lean`.

## 7. The inversion used in §3 is now a theorem

The bisection inversion of `hc r 0.1 = mass` performed in §3 is well posed:
`Catalog/Probability/PositionalRateLinkIdentifiability.lean` proves that
`r ↦ harmCDF r u` is a strictly increasing bijection from `(1, ∞)` onto `(u, 1)`
for every `u ∈ (0,1)` (`harmCDF_ratio_bijOn`), so each of the three tercile
masses 0.229 / 0.245 / 0.230 — all of which lie in `(1/10, 1)` — has exactly one
preimage (`edge_decile_identifies_ratio`), and equality of two tercile masses is
equivalent to equality of the two window ratios (`edge_decile_eq_iff_ratio_eq`).
The bracketing used in the proof is explicit: `u·r` bounds the mass from above and
`1 + log u / log r` from below, which is also what makes the numerical bisection
converge from the two sides observed in §3.

## 8. The clipped control-arm odds ratios, quantitatively

The ledger reported family-B control odds ratios clipped at `e^{±30}`, i.e. a
coefficient norm pinned at the optimiser's bound rather than determined by the
data.  `Catalog/Probability/PositionalRateLinkEscape.lean` turns that observation
into two explicit inequalities.  Writing `δ = −ℓ(β)` for the likelihood
deficiency of a fit:

* a fit that classifies one observation almost perfectly must pay
  `‖β‖·‖xᵢ‖ ≥ log(1/δ) − δ` (`log_deficiency_lower_bound`), so a clip at
  `|coefficient| = 30` corresponds to a deficiency no smaller than roughly
  `e^{-30 ‖xᵢ‖}` — the optimiser stopped, the data did not;
* under a ridge penalty the same fit is bounded, `λ‖β‖² ≤ n log 2`
  (`penalized_max_sqNorm_le`), so with `n ≈ 10³` a penalty `λ = 10⁻³` caps the
  norm near `√(n log 2 / λ) ≈ 8·10²` and a penalty `λ = 1` caps it near `26`;
* and yet for every bound `M` some penalty is small enough that the estimate
  exceeds it (`ridge_escape`), which is why the reported magnitudes on a
  separated design carry no inferential content unless the penalty is fixed and
  reported alongside them.
