# Computational Evidence

All numbers below were produced with `#eval` inside the project's Lean toolchain
(`Float` arithmetic, `lake env lean`), before the corresponding statements were
formalized.  They are *exploratory* — the authoritative statements are the
`sorry`-free theorems in `Catalog/Computation/InformationGeometry/`.

## 1. Cauchy–Schwarz bound `‖p − q‖₁² ≤ χ²(p ‖ q)`

For each sample pair `(p, q)` of strictly positive probability vectors we
computed `L₁² = (∑ |pᵢ − qᵢ|)²`, `χ² = ∑ (pᵢ − qᵢ)²/qᵢ`, `KL = ∑ pᵢ log(pᵢ/qᵢ)`
and `2·KL`.

| `p` | `q` | `L₁²` | `χ²` | `KL` | `2·KL` | `L₁²/χ²` |
|---|---|---|---|---|---|---|
| (.5,.3,.2) | (.2,.5,.3) | 0.36000 | 0.56333 | 0.22381 | 0.44761 | 0.6391 |
| (.9,.05,.05) | (⅓,⅓,⅓) | 1.28444 | 1.44500 | 0.70422 | 1.40843 | 0.8889 |
| (.25,.25,.25,.25) | (.1,.2,.3,.4) | 0.16000 | 0.30208 | 0.12178 | 0.24356 | 0.5297 |
| (.6,.4) | (.5,.5) | 0.04000 | 0.04000 | 0.02014 | 0.04027 | **1.0000** |
| (.99,.01) | (.5,.5) | 0.96040 | 0.96040 | 0.63715 | 1.27429 | **1.0000** |
| (.4,.35,.25) | (.34,.33,.33) | 0.02560 | 0.03119 | 0.01619 | 0.03239 | 0.8207 |

*Counterexample hunt*: no sample violated `L₁² ≤ χ²`; the ratio never exceeded
`1`.  This is now proved (`InformationGeometry.l1_sq_le_chiSquared`).

*Sharpness*: the ratio is exactly `1` for the symmetric two-point family
`p = (½+e, ½−e)`, `q = (½, ½)`.  Checked for `e ∈ {0.05, 0.1, 0.2, 0.4}`:

| `e` | `L₁²` | `χ²` |
|---|---|---|
| 0.05 | 0.0100 | 0.0100 |
| 0.10 | 0.0400 | 0.0400 |
| 0.20 | 0.1600 | 0.1600 |
| 0.40 | 0.6400 | 0.6400 |

This is now proved (`InformationGeometry.l1_sq_eq_chiSquared_two_point`), so the
constant `1` cannot be improved.  Note that chaining Pinsker (`L₁² ≤ 2·KL`) with
`KL ≤ χ²` only yields `L₁² ≤ 2χ²`; the table shows `2·KL` is indeed sometimes
larger than `χ²` is (e.g. row 5: `2·KL = 1.274 > χ² = 0.960`), so the
Cauchy–Schwarz route is a genuine factor-2 improvement, not a reformulation.

## 2. The Fisher form as the Hessian of KL divergence

Central second difference of `s ↦ KL(p + s·v ‖ p)` at `s = 0` with step
`h = 10⁻³`, against `fisherForm p v v = ∑ vᵢ²/pᵢ`:

| `p` | `v` (zero-sum) | second difference | `fisherForm p v v` |
|---|---|---|---|
| (.5,.3,.2) | (.1,−.06,−.04) | 0.040000 | 0.040000 |
| (.25,.25,.25,.25) | (.3,−.1,−.15,−.05) | 0.500000 | 0.500000 |

Agreement to all displayed digits.  This is now proved exactly
(`InformationGeometry.klDiv_hessian_diagonal`).

## 3. Zero-mass conventions

`klDiv ![1,0] ![1/2,1/2]` evaluates to `log 2 ≈ 0.6931`, because the Lean
convention `0 * Real.log (0 / q) = 0` reproduces the measure-theoretic
convention `0 log 0 = 0`.  The corresponding Pinsker left-hand side is
`(1/2)·1² = 0.5 < 0.6931`.  Both facts are formalized
(`klDiv_deterministic_vs_uniform`, `pinsker_strict_deterministic_vs_uniform`).

The convention only breaks down when `q i = 0 < p i`, where Lean's
`Real.log (p / 0) = 0` silently replaces `+∞`.  This is exactly the case
excluded by the hypothesis `AbsCont p q`, which is therefore load-bearing rather
than cosmetic.

## 4. OEIS

No integer sequence arises in this development, so no OEIS search applies.

## 5. Cramér–Rao and the equality cases (this cycle)

All numbers below were produced with `#eval` (`Float` arithmetic) before the
corresponding statements were formalized in
`Catalog/Computation/InformationGeometry/CramerRao.lean`.

**Cramér–Rao.** With `p = (.5,.3,.2)`, `T = (1,2,5)` and the zero-sum score
direction `v = (.1,−.06,−.04)`:

| quantity | value |
|---|---|
| `E_p T` | 2.1000 |
| `Var_p T` | 2.2900 |
| `fisherForm p v v` | 0.0400 |
| `(∑ Tᵢ vᵢ)²` | 0.0484 |
| `Var · I` | 0.0916 |
| ratio | 0.5284 |

so the bound holds strictly here.  Taking instead the score direction supplied
by the estimator itself, `wᵢ = pᵢ (Tᵢ − E_p T)`, gives
`(∑ Tᵢ wᵢ)² = Var · fisherForm p w w = 5.2441`, ratio `1.0000` — the bound is
attained.  Both facts are now proved (`cramer_rao`, `cramer_rao_attained`), and
the exact equality criterion is `cramer_rao_eq_iff`.

**Equality case of the `L¹` bound.**  With `p = (.5,.3,.2)`:

| `v` | `|vᵢ|/pᵢ` | `(∑ |vᵢ|)²` | `fisherForm p v v` |
|---|---|---|---|
| (.1,−.06,−.04) | (0.2, 0.2, 0.2) | 0.0400 | 0.0400 |
| (.2,−.15,−.05) | (0.4, 0.5, 0.25) | 0.1600 | 0.1675 |

Equality exactly in the constant-ratio row, matching the proved criterion
`l1_sq_eq_fisherForm_iff`.

## 5. Monotonicity under stochastic maps (Chentsov / data processing)

Before formalizing `Catalog/Computation/InformationGeometry/FisherMonotonicity.lean`
we tested the three monotonicity claims on the row stochastic matrix

`K = [[0.8, 0.2], [0.3, 0.7], [0.5, 0.5]]  :  Fin 3 → Fin 2`

with `p = (.5,.3,.2)`, `q = (.2,.5,.3)` and the zero-sum tangent vector
`v = (.1,−.06,−.04)`.  Push-forward is `K∗u j = ∑ᵢ uᵢ Kᵢⱼ`.

| quantity | pushed forward (`Fin 2`) | original (`Fin 3`) |
|---|---|---|
| `fisherForm p v v` | 0.007292 | 0.040000 |
| `klDiv p q` | 0.033930 | 0.223805 |
| `chiSquared p q` | 0.068035 | 0.563333 |

Every pushed-forward value is smaller, as predicted.  *Counterexample hunt*:
five further `3 × 2` channels applied to the same `p, q, v` (original values
`0.040000`, `0.223805`, `0.563333`):

| `K` (rows) | `fisherForm` | `klDiv` | `chiSquared` |
|---|---|---|---|
| (.8,.2),(.3,.7),(.5,.5) | 0.007292 | 0.033930 | 0.068035 |
| (1,0),(0,1),(1,0) — deterministic merge | 0.017143 | 0.082283 | 0.160000 |
| (.5,.5),(.5,.5),(.5,.5) — uninformative | 0.000000 | 0.000000 | 0.000000 |
| (.99,.01),(.02,.98),(.6,.4) | 0.023141 | 0.110457 | 0.228628 |
| (.1,.9),(.9,.1),(.25,.75) | 0.012510 | 0.061721 | 0.123500 |

No sample produced a larger pushed-forward value.  The three inequalities are
now proved as `fisherForm_pushforward_le`, `klDiv_pushforward_le` and
`chiSquared_pushforward_le`.

Two extreme cases were also checked and are now theorems: a *lossless*
(injective deterministic) channel leaves the Fisher form unchanged
(`fisherForm_pushforward_of_injective`), while the channel merging two symbols
of the uniform distribution on `Fin 2` sends the direction `v = (1,−1)` to `0`,
collapsing `fisherForm = 4` to `0` (`fisherForm_pushforward_lt_merge`).

Both extremes are instances of the general equality criterion proved in the same
file (`fisherForm_pushforward_eq_iff_exists_score`): the Fisher form is
preserved exactly when a posterior score `c : κ → ℝ` exists with `v i = c j · p i`
for all `i, j` with `K i j > 0`.  For the merging channel above this would force
`1 = c₀/2` and `−1 = c₀/2` simultaneously, which is why the drop is strict.
