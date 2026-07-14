# Computational Evidence — sharp/flat λ-difference as a μ-proportional term

All invariants are computed in the polynomial model on `ℤ[X]`:

* `μ(f) = v_p(content f)` — the p-adic valuation of the gcd of the coefficients;
* `λ(f) = natTrailingDegree` of the mod-p reduction of the primitive part of `f`.

The sharp/flat twist factors share a common μ-depth `k`:

* `sharpTwist cs k = p^k · X^(cs·k)`  →  `(μ, λ) = (k, cs·k)`;
* `flatTwist  cf k = p^k · X^(cf·k)`  →  `(μ, λ) = (k, cf·k)`.

## 1. Single twist factor: (λ, μ) is free

Prime `p = 2`. The generalised factor `gTwist a k = 2^k · X^a` gives `(λ, μ) = (a, k)`:

| a | k | μ = k | λ = a | λ/μ |
|---|---|-------|-------|-----|
| 7 | 3 | 3     | 7     | 7/3 |
| 4 | 2 | 2     | 4     | 2   |
| 5 | 5 | 5     | 5     | 1   |
| 6 | 3 | 3     | 6     | 2   |

The ratio λ/μ takes distinct values (7/3, 2, 1, 2), confirming that the model is
**not** pinned to a fixed proportionality constant.

## 2. μ-symmetry of the twist

Take any `f ≠ 0`, prime `p = 2`, sharp `cs = 5`, flat `cf = 2`, depth `k = 3`.

* `μ(f · sharpTwist) = μ(f) + 3`;
* `μ(f · flatTwist)  = μ(f) + 3`.

Both twisted μ-invariants coincide for every `f`, independent of `cs, cf`.

## 3. λ-difference is exactly (cs − cf)·μ

Same data (`cs = 5, cf = 2, k = 3`, so μ of the twist = 3):

* `λ(f · sharpTwist) = λ(f) + 15`;
* `λ(f · flatTwist)  = λ(f) + 6`;
* difference `= 15 − 6 = 9 = (5 − 2)·3 = (cs − cf)·μ`.

A sweep over small parameters (all with `p = 2`):

| cs | cf | k | (cs−cf)·k | λ♯−λ♭ |
|----|----|---|-----------|-------|
| 5  | 2  | 3 | 9         | 9     |
| 4  | 4  | 3 | 0         | 0     |
| 2  | 5  | 3 | −9        | −9    |
| 7  | 1  | 1 | 6         | 6     |
| 3  | 0  | 0 | 0         | 0     |

Every row satisfies `λ♯ − λ♭ = (cs − cf)·k` (computed in `ℤ`, so the `cs < cf`
row gives the honest negative value `−9`).

## 4. Non-vanishing boundary

The difference is zero exactly when `k = 0` (μ = 0) or `cs = cf`:

* `k = 0`: rows with depth 0 give difference 0 regardless of `cs, cf`;
* `cs = cf`: difference 0 regardless of `k`;
* `k ≥ 1` and `cs ≠ cf`: difference strictly non-zero.

This matches the proved statements `sharpFlat_diff_nonvanishing` and
`sharpFlat_diff_vanishes_of_mu_zero`.

## OEIS note

No new integer sequence is introduced by this cycle; the data are linear forms
`(cs − cf)·k` in the twist parameters, so an OEIS search is not applicable here.
