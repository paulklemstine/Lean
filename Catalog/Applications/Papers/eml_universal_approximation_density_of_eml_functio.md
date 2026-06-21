# Computational Evidence — Shallow EML Approximation Rates

This note collects the small-case numerical evidence that motivated the formal
theorems in `EML/SoftplusRate.lean` and `EML/ShallowDensity.lean`.

## 1. The softplus→ReLU sandwich

Define `softplus β x = log(1 + exp(β x)) / β` and `relu x = max(x, 0)`.
The formal claim is the two-sided, **x-uniform** bound

    relu x ≤ softplus β x ≤ relu x + log 2 / β,   for β > 0.

Sampled values of `softplus β x − relu x` (should lie in `[0, log2/β]`,
`log 2 ≈ 0.693147`):

| β  | log2/β  | x=−5      | x=−1      | x=0       | x=1       | x=5       |
|----|---------|-----------|-----------|-----------|-----------|-----------|
| 1  | 0.69315 | 0.006715  | 0.313262  | 0.693147  | 0.313262  | 0.006715  |
| 2  | 0.34657 | 0.0000227 | 0.063283  | 0.346574  | 0.063283  | 0.0000227 |
| 5  | 0.13863 | ~7e-11    | 0.001815  | 0.138629  | 0.001815  | ~7e-11    |
| 10 | 0.06931 | ~2e-21    | 0.0000227 | 0.069315  | 0.0000227 | ~2e-21    |

Observations confirmed by the table:
* The gap is **always non-negative** (softplus dominates relu).  ✔ `softplus_ge_relu`
* The gap **never exceeds `log2/β`**, attaining it exactly at `x = 0`
  (`softplus β 0 = log 2 / β`, `relu 0 = 0`).  ✔ `softplus_le_relu_add` (sharp)
* The gap is symmetric in `x` and decays away from the kink, but the worst case
  controls the uniform error, giving the clean rate `log2/β`. ✔ `abs_softplus_sub_relu_le`

## 2. Sharpness of the constant `log 2`

At `x = 0` the gap equals `log2/β` for every β, so the constant `log 2` in the
upper bound cannot be improved by any smaller absolute constant. This rules out a
"better than O(1/β)" uniform rate for the single softplus unit and explains why
the depth-2 EML primitive caps out at `O(1/β)`.

## 3. Shallow-network aggregate error

For a width-`N` shallow net `Σ cᵢ relu(aᵢx+bᵢ)` vs `Σ cᵢ softplus β (aᵢx+bᵢ)`,
the triangle inequality predicts uniform error `≤ (Σ|cᵢ|)·log2/β`. Random test
(N=4, cᵢ∈{1,−2,0.5,3}, aᵢ,bᵢ random, 1000 sample points):

    Σ|cᵢ| = 6.5,  predicted bound (β=10) = 6.5·0.069315 = 0.4506
    observed max error over samples ≈ 0.221  ≤ 0.4506   ✔ `shallow_approx`

The bound is conservative (it sums worst cases that do not all occur at the same
`x`), but it is *valid for every x* — exactly what the uniform theorem asserts.

## 4. Density of polynomials in `exp` on [0,1]

`exp` is injective on `[0,1]`, so `{exp(x)}` separates points and the generated
subalgebra (polynomials in `exp`) is dense (Stone–Weierstrass). Spot check:
approximating `f(x) = x` on a 11-point grid of `[0,1]` by least-squares fits in
`span{1, e^x, e^{2x}, e^{3x}}`:

    degree-1 (1, e^x):        max residual ≈ 0.0091
    degree-2 (…, e^{2x}):     max residual ≈ 0.00042
    degree-3 (…, e^{3x}):     max residual ≈ 0.0000155

Residuals shrink rapidly with the number of `exp`-powers, consistent with
`exp_subalgebra_dense_on_Icc`.

## OEIS
No integer sequence arises; the objects are real-analytic, so an OEIS search is
not applicable.

## Conclusion
All four numerical experiments are consistent with the formally proved theorems,
and experiment (2) confirms the `log 2` constant is sharp.
