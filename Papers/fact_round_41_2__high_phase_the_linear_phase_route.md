# Computational Evidence — phase encodings vs. alignment targets

All numbers below were produced by direct enumeration of the *full population
grid* (no sampling), in double precision, before the Lean formalisation.  They
are exploratory: the authoritative statements are the machine-checked theorems
in `Catalog/Logic/PhaseRoute*.lean`, which prove the exact-zero versions
symbolically for **every** prime modulus and **every** singleton encoding.

## 1. Two-way alignment on `ZMod p × ZMod p`, target `y(a,b) = [a = b]`

Empirical covariance of the target with three different *singleton* (degree-1)
phase encodings — a one-hot residue dummy, a cosine phase `cos(2πa/p)`, and a
linear phase `a + 2b` — and the best single-feature `R²` among them:

| p  | cov(one-hot) | cov(cos phase) | cov(linear) | var(y) | best singleton `R²` | interaction `R²` |
|----|--------------|----------------|-------------|--------|---------------------|------------------|
| 3  | 0.000e+00    | 1.6e-17        | 0.000e+00   | 0.222222 | 2.4e-33           | 1.0 |
| 5  | -6.9e-18     | 3.6e-18        | -2.2e-16    | 0.160000 | 3.1e-32           | 1.0 |
| 17 | 0.000e+00    | -2.4e-17       | 2.2e-16     | 0.055363 | 2.0e-32           | 1.0 |
| 53 | 5.4e-20      | -9.2e-17       | 0.000e+00   | 0.018512 | 9.1e-31           | 1.0 |
| 97 | 1.4e-20      | -2.3e-17       | 0.000e+00   | 0.010203 | 1.1e-31           | 1.0 |

Every entry is zero to floating-point round-off, across the whole scanned range
`3 ≤ p ≤ 97`, and `var(y) = 1/p - 1/p²` matches the closed form to all printed
digits.  Formalised (exactly, for all `p ≥ 2`) as
`cov_graphInd_additive_eq_zero`, `varr_graphInd`, `phase_route_closed_all_windows`
and `Rsq_interaction_eq_one`.

## 2. Contrast: a target that *does* have a degree-1 component

For a synthetic target `f(a,b) = N(0,1) + 0.7·cos(2πa/p)` (seed 20260902) the
two-way ANOVA split is nontrivial and the degree-1 ceiling is far from `0`:

| p  | var total | var additive | var interaction | degree-1 ceiling `R²` |
|----|-----------|--------------|-----------------|------------------------|
| 5  | 1.9247    | 0.8518       | 1.0729          | 0.4426 |
| 17 | 1.1036    | 0.3682       | 0.7354          | 0.3336 |

`var total = var additive + var interaction` holds to round-off in both rows;
this is the exact identity `varr_split`, and the ceiling is
`Rsq_addPart_eq_ceiling`.  So the calculus is not vacuous: it separates targets
with a real phase signal from alignment targets, which sit at ceiling `0`.

## 3. Three-way alignment on `(ZMod p)³`, target `y = [a + b + c = 0]`

Covariance with a random *pairwise* (degree-`≤2`) predictor
`F(a,b) + G(b,c) + H(a,c)` with i.i.d. standard-normal tables (seed 20260902):

| p | cov | best pairwise `R²` | var(y) | `1/p - 1/p²` |
|---|-----|--------------------|--------|--------------|
| 2 | 1.1e-16  | 1.3e-32 | 0.250000 | 0.250000 |
| 3 | -1.4e-17 | 2.6e-34 | 0.222222 | 0.222222 |
| 5 | -2.1e-17 | 1.6e-33 | 0.160000 | 0.160000 |
| 7 | -6.9e-18 | 1.7e-34 | 0.122449 | 0.122449 |

Again exactly zero to round-off — the prediction that the degree hierarchy does
not stop at `2`.  Formalised as `cov_triAlign_pairwise_eq_zero`,
`varr_triAlign` and `triple_degree_separation`.

## 4. Counterexample hunt

We searched for a singleton encoding with nonzero gain by (i) all one-hot
dummies on either coordinate, (ii) all Fourier phases `cos(2πta/p)`,
`sin(2πta/p)` for `1 ≤ t < p`, and (iii) random additive tables — for
`p ∈ {3,5,17,53,97}`.  No candidate produced `|cov| > 1e-15`.  The Lean proof
explains why the hunt had to fail: the covariance is identically `0` for the
whole `(2p-1)`-dimensional additive space, so no search over that space can
succeed.

## 5. OEIS

The variance sequence `p² · var(y) = p - 1` for `p = 2,3,5,7,11,…` is just
`prime - 1` (A006093); nothing deeper is claimed for it.
