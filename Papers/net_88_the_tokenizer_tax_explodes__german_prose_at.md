# Computational evidence for the NET-88 tokenizer-tax formalisation

All numbers below come from the NET-88 row supplied with the assignment
(German prose, ctx = 4096, gate exact, 3 held-out windows) and from arithmetic on it.
Nothing here is a new measurement; the point is to check that the model class chosen for
the Lean development actually fits the reported data before any theorem is proved about
it.

## 1. The measured row and its deficits

| k        | 24    | 32    | 40    | 48    | 56    |
|----------|-------|-------|-------|-------|-------|
| retained | 0.953 | 0.966 | 0.973 | 0.975 | 0.976 |
| deficit  | 0.047 | 0.034 | 0.027 | 0.025 | 0.024 |

The deficit is what the model must explain: it falls by roughly a factor `1.96` while `k`
grows by a factor `2.33`, i.e. slower than `1/k` — a *sub-linear* recall exponent.

## 2. Log–log fit of `deficit(k) = A · k^(-a)`

Ordinary least squares on `(log k, log deficit)` gives

```
a = 0.8101      A = 0.5825
```

| k  | measured deficit | fitted `A·k^(-a)` | fitted retained | residual |
|----|------------------|-------------------|-----------------|----------|
| 24 | 0.0470           | 0.04438           | 0.95562         | 0.0026   |
| 32 | 0.0340           | 0.03515           | 0.96485         | 0.0012   |
| 40 | 0.0270           | 0.02934           | 0.97066         | 0.0024   |
| 48 | 0.0250           | 0.02531           | 0.97469         | 0.0003   |
| 56 | 0.0240           | 0.02234           | 0.97766         | 0.0017   |

Every residual is below `0.004` in retention units. The power-law deficit family is
therefore an adequate description of the row; it is the family formalised as `deficit`
in `Catalog/Algebra/TokenizerTaxMultiplicative.lean`.

## 3. Required budget at the `0.98` bar

With the fitted parameters, `budget = (A/(1-τ))^(1/a)` gives

| τ     | required keys |
|-------|---------------|
| 0.980 | 64.2          |
| 0.985 | 91.6          |
| 0.990 | 151.1         |

so the bar is not reachable within the measured grid — consistent with "all five points
fail" — and the requirement grows fast as the bar tightens. The Lean file proves the
qualitative half of this without relying on the fit at all
(`net88_all_points_fail`, `net88_budget_gt_56`): the single measured anchor at `k = 56`
plus monotonicity already forces `budget > 56`.

## 4. Counterexample hunt: is the exponent really sub-linear?

`a < 1` is the mechanism behind the explosion (a sub-linear recall exponent makes the
budget respond super-linearly to the amplitude). Trying to break it: any `A, a` with
`deficit 24 = 0.047` and `deficit 56 = 0.024` satisfies `(56/24)^a = 47/24 = 1.958`.
Since `56/24 = 2.333 > 1.958`, `a ≥ 1` is impossible — a two-point argument with no
fitting, formalised as `net88_exponent_lt_one`. No counterexample exists.

## 5. The amplification arithmetic

The theory predicts `tax(C) = (lam^{b/a} - 1) · baseline(C)`, i.e. the tax is a fixed
multiple of the baseline. Checking the headline arithmetic on the witness parameters
`A₀ = b = a = 1`, `τ = 1/2`, `lam = 3`, `C₁ = 1`, `C₂ = 4`:

```
baseline(1) = 2      baseline(4) = 8      (acceleration ×4)
tax(1)      = 4      tax(4)      = 16     (amplification ×4)
```

which matches the reported "`+4` becomes `≥ +16`, a 4× amplification matching the
increment acceleration exactly". This instance is checked in Lean as
`net88_witness_instance`, so the hypotheses of `tax_four_to_sixteen` are demonstrably
non-vacuous.

## 6. Fine-step grid

On the harness grid `g = 4`: `⌈4/4⌉ = 1` step and `⌈16/4⌉ = 4` steps
(`net88_fine_step_jump`), and in general rounding can absorb at most three of the four
steps of a quadrupling (`steps_quadruple_lower`).

## 7. OEIS

No integer sequence arises in this development (all quantities are real-valued budgets
and exponents), so no OEIS lookup applies.
