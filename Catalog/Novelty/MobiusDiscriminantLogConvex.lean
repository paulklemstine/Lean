import Mathlib
import Novelty.MobiusDiscriminantQuantitative

/-!
# Global log-convexity from the Möbius discriminant: monotone ratios,
  all-order Turán inequalities, and the telescoping product

The development `MobiusDiscriminantQuantitative.lean` proved that a sequence
obeying the first-order multiplicative recurrence
`(α n + β)·a(n+1) = (γ n + δ)·a(n)` has consecutive-ratio forward difference with
constant numerator equal to the Möbius discriminant `Δ = γβ − αδ`:

  `a(n+2)/a(n+1) − a(n+1)/a(n) = Δ / ((α n + β)·(α (n+1) + β))`
  (`MobiusDiscriminant.ratio_forward_difference`).

That is a *local* statement (a single forward difference).  This file upgrades it
to *global* structure by promoting the sign of `Δ` to monotonicity of the entire
ratio sequence, and then to **all-order Turán inequalities** — genuine
log-convexity/concavity across arbitrary index gaps, not just consecutive
triples.  We also record the exact **telescoping product** solution.

## Results
* `mobius_ratio_strictMono` / `mobius_ratio_strictAnti`: when `Δ > 0` (resp.
  `Δ < 0`) the consecutive ratio `n ↦ a(n+1)/a(n)` is strictly increasing (resp.
  decreasing) on all of `ℕ`.
* `mobius_turan` / `mobius_turan_concave`: for all `i < j`,
  `a(i+1)·a(j) < a(i)·a(j+1)` when `Δ > 0` (reversed when `Δ < 0`).  Taking
  `j = i + 1` recovers the pointwise discriminant law; general `j` is strictly
  stronger and expresses global log-convexity.
* `mobius_product_formula`: the exact solution
  `a(n) = a(0)·∏_{k<n} (γ k + δ)/(α k + β)`.

## Lab Notes
-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  If the sign of `Δ` controls each consecutive
  forward difference of the ratio, it should control the ratio *globally*, giving
  Turán inequalities of every order (log-convexity across all gaps), not merely
  the nearest-neighbour discriminant.
* **Experiment (Experimenter).**  For the Catalan recurrence (`Δ = 6 > 0`) the
  ratios `2(2n+1)/(n+2) = 1, 2, 2.5, 2.8, …` are strictly increasing, matching
  `mobius_ratio_strictMono`.  The proof lifts the single-step forward difference
  to `StrictMono` via `strictMono_nat_of_lt_succ`, then to cross-index Turán
  inequalities by clearing denominators.
* **Analysis (Analyst).**  The single scalar `Δ` upgrades from a pointwise sign
  law to a total order statement on ratios and to log-convexity of all orders.
  The telescoping product shows the ratios *are* the Möbius data, so monotone
  Möbius numerator `Δ` ⇒ monotone ratios ⇒ log-convex totals — one invariant,
  three layers of structure.
* **Critique (Critic).**  Are the Turán inequalities strict and nonvacuous?  Yes:
  strictness comes from `Δ ≠ 0` and the positivity of the denominators; the
  Catalan and Möbius-ratio instances witness satisfiable hypotheses.  Every proof
  cites only `MobiusDiscriminant.*` lemmas or lemmas above it — no self-reference.
* **Synthesis (PI).**  `Δ`'s sign is equivalent to global log-convexity of the
  sequence, and the telescoping product turns the qualitative law into an exact
  closed form.
-/

namespace MobiusDiscriminantLogConvex

open MobiusDiscriminant

/-- **Monotone ratios (log-convex regime).**  When `Δ = γβ − αδ > 0`, the
consecutive ratio `n ↦ a(n+1)/a(n)` is strictly increasing on all of `ℕ`. -/
theorem mobius_ratio_strictMono {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : 0 < γ * β - α * δ) :
    StrictMono (fun n => a (n + 1) / a n) := by
  apply strictMono_nat_of_lt_succ
  intro n
  have hfd := ratio_forward_difference hpos hden hrec n
  have hden2 : 0 < (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β) := by
    have := hden n; have := hden (n + 1); push_cast at *; positivity
  have hpr : 0 < (γ * β - α * δ) / ((α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β)) :=
    div_pos hΔ hden2
  show a (n + 1) / a n < a (n + 2) / a (n + 1)
  push_cast at hfd
  linarith [hfd, hpr]

/-- **Monotone ratios (log-concave regime).**  When `Δ = γβ − αδ < 0`, the
consecutive ratio `n ↦ a(n+1)/a(n)` is strictly decreasing on all of `ℕ`. -/
theorem mobius_ratio_strictAnti {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : γ * β - α * δ < 0) :
    StrictAnti (fun n => a (n + 1) / a n) := by
  apply strictAnti_nat_of_succ_lt
  intro n
  have hfd := ratio_forward_difference hpos hden hrec n
  have hden2 : 0 < (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β) := by
    have := hden n; have := hden (n + 1); push_cast at *; positivity
  have hpr : (γ * β - α * δ) / ((α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β)) < 0 :=
    div_neg_of_neg_of_pos hΔ hden2
  show a (n + 2) / a (n + 1) < a (n + 1) / a n
  push_cast at hfd
  linarith [hfd, hpr]

/-- **All-order Turán inequality (global log-convexity).**  When `Δ > 0`, for all
`i < j` we have `a(i+1)·a(j) < a(i)·a(j+1)`.  Specializing to `j = i + 1` recovers
the pointwise discriminant law; general `j` is strictly stronger. -/
theorem mobius_turan {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : 0 < γ * β - α * δ) {i j : ℕ} (hij : i < j) :
    a (i + 1) * a j < a i * a (j + 1) := by
  have hmono := mobius_ratio_strictMono hpos hden hrec hΔ hij
  simp only at hmono
  rw [div_lt_div_iff₀ (hpos i) (hpos j)] at hmono
  rw [mul_comm (a i)]
  exact hmono

/-- **All-order Turán inequality (global log-concavity).**  When `Δ < 0`, for all
`i < j` we have `a(i)·a(j+1) < a(i+1)·a(j)` (the reversed inequality). -/
theorem mobius_turan_concave {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : γ * β - α * δ < 0) {i j : ℕ} (hij : i < j) :
    a i * a (j + 1) < a (i + 1) * a j := by
  have hanti := mobius_ratio_strictAnti hpos hden hrec hΔ hij
  simp only at hanti
  rw [div_lt_div_iff₀ (hpos j) (hpos i)] at hanti
  rw [mul_comm (a i)]
  exact hanti

/-- **Telescoping product formula.**  The unique solution of the recurrence with
positive denominators is the Möbius telescoping product
`a(n) = a(0)·∏_{k<n} (γ k + δ)/(α k + β)`. -/
theorem mobius_product_formula {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) (n : ℕ) :
    a n = a 0 * ∏ k ∈ Finset.range n, (γ * (k : ℝ) + δ) / (α * (k : ℝ) + β) := by
  induction n with
  | zero => simp
  | succ m ih =>
    have hr := ratio_eq_mobius hpos hden hrec m
    have step : a (m + 1) = a m * ((γ * (m : ℝ) + δ) / (α * (m : ℝ) + β)) := by
      rw [← hr, mul_comm]
      exact (div_mul_cancel₀ (a (m + 1)) (hpos m).ne').symm
    rw [Finset.prod_range_succ, ← mul_assoc, ← ih, step]

end MobiusDiscriminantLogConvex