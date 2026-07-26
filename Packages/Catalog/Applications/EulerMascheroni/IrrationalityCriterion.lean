/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# An Irrationality Criterion via Integer Linear Forms, and its application to `γ`

Whether the Euler–Mascheroni constant `γ` is irrational is a famous *open
problem*.  Every known irrationality proof (e.g. Apéry's for `ζ(3)`) ultimately
exhibits a sequence of **integer linear forms** `aₙ + bₙ·x` in the constant `x`
that are nonzero but tend to `0`.  This file isolates that mechanism as a
reusable theorem and shows it is in fact a *characterization* of irrationality.

## Main results

- `EMR.irrational_of_int_linear_combo_tendsto_zero` : **(sufficiency)** if there
  exist integer sequences `a, b` with `aₙ + bₙ·x ≠ 0` for all `n` and
  `aₙ + bₙ·x → 0`, then `x` is irrational.
- `EMR.irrational_iff_exists_int_linear_combo_tendsto_zero` : **(characterization)**
  `x` is irrational *iff* such integer linear forms exist.  The converse uses
  Dirichlet's theorem on Diophantine approximation
  (`Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational`).
- `EMR.eulerMascheroniConstant_irrational_iff` : the open problem "is `γ`
  irrational?" is *equivalent* to the concrete constructive task of producing
  integer linear forms `aₙ + bₙ·γ → 0` (nonzero).  This reframes the irrationality
  question as an explicit Diophantine construction problem.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Irrationality of a real `x` should be *equivalent* to
the existence of nonzero integer linear forms `aₙ + bₙ x` tending to `0`; the
"hard" direction (sufficiency) is the engine of all irrationality proofs, and the
converse should follow from Dirichlet's approximation theorem.

Experiment (Experimenter): Proved sufficiency by contradiction: if `x = p/q` then
`aₙ + bₙ x = (aₙ q + bₙ p)/q` has nonzero *integer* numerator, hence absolute
value `≥ 1/q`, contradicting convergence to `0` (key step: `Int.one_le_abs`).
For the converse, fed the infinite set of good rational approximations from
Dirichlet's theorem into a denominator-unbounded extraction
(`exists_rat_mem_den_ge`), then took `aₙ = -num`, `bₙ = den`, giving
`|aₙ + bₙ x| = den·|x - q| < 1/den ≤ 1/(n+1) → 0` (squeeze).

Analysis (Analyst): The structural insight is that the *integrality* of the
numerator gives a hard lower bound `1/q` that no convergent-to-`0` sequence can
respect — the same "no integer in `(0,1)`" rigidity behind irrationality of `e`
and `ζ(3)`.  The converse shows the criterion loses nothing.

Critique (Critic): Sufficiency is genuinely non-vacuous (it characterizes, so it
applies to *every* irrational).  Neither direction is `native_decide`/`rfl`.  The
`γ` corollary is an honest *reduction* of the open problem, not a claim that `γ`
is (ir)rational — the existence of the forms for `γ` remains unknown.

Synthesis (PI): The irrationality of `γ` is now equivalent, inside Lean, to a
concrete Diophantine construction; this is the precise target a future
Apéry-style attack must hit.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Real Filter Topology

namespace EMR

/-- **Integer-linear-form irrationality criterion (sufficiency).**
If there exist integer sequences `a, b` such that `aₙ + bₙ·x` is never zero but
tends to `0`, then `x` is irrational. -/
theorem irrational_of_int_linear_combo_tendsto_zero {x : ℝ}
    (a b : ℕ → ℤ)
    (hne : ∀ n, (a n : ℝ) + b n * x ≠ 0)
    (h : Tendsto (fun n => (a n : ℝ) + b n * x) atTop (𝓝 0)) :
    Irrational x := by
  rintro ⟨q, hq⟩
  have hxq : x = (q.num : ℝ) / (q.den : ℝ) := by rw [← hq, Rat.cast_def]
  have hden : (0:ℝ) < (q.den : ℝ) := by exact_mod_cast q.pos
  set g : ℕ → ℝ := fun n => (a n : ℝ) + b n * x with hg
  have hform : ∀ n, g n = ((a n * (q.den : ℤ) + b n * q.num : ℤ) : ℝ) / (q.den : ℝ) := by
    intro n; rw [hg]; simp only; rw [hxq]; push_cast; field_simp
  have hmne : ∀ n, (a n * (q.den : ℤ) + b n * q.num) ≠ 0 := by
    intro n hm; apply hne n
    have := hform n; rw [hm] at this; simpa using this
  have hge : ∀ n, 1 / (q.den : ℝ) ≤ |g n| := by
    intro n
    rw [hform n, abs_div, abs_of_pos hden, div_le_div_iff_of_pos_right hden]
    have hz : (1:ℤ) ≤ |a n * (q.den : ℤ) + b n * q.num| := Int.one_le_abs (hmne n)
    calc (1:ℝ) = ((1:ℤ):ℝ) := by norm_num
      _ ≤ ((|a n * (q.den : ℤ) + b n * q.num| : ℤ) : ℝ) := by exact_mod_cast hz
      _ = |((a n * (q.den : ℤ) + b n * q.num : ℤ) : ℝ)| := by rw [Int.cast_abs]
  have habs : Tendsto (fun n => |g n|) atTop (𝓝 0) := by simpa using h.abs
  have hpos : (0:ℝ) < 1/(q.den:ℝ) := by positivity
  obtain ⟨n, hn⟩ := (habs.eventually (gt_mem_nhds hpos)).exists
  exact absurd (hge n) (not_le.mpr hn)

/-- For an irrational `x`, the good rational approximations from Dirichlet's
theorem have *unbounded denominators*: for every `N` there is a rational `q`
with `|x - q| < 1/q.den²` and `q.den ≥ N`. -/
theorem exists_rat_mem_den_ge {x : ℝ} (hx : Irrational x) :
    ∀ N : ℕ, ∃ q : ℚ, |x - (q : ℝ)| < 1 / (q.den : ℝ) ^ 2 ∧ N ≤ q.den := by
  intro N
  by_contra h_contra
  push_neg at h_contra
  have h_bounded : ∀ q : ℚ, |x - q| < 1 / (q.den : ℝ) ^ 2 → q.den ≤ N := by
    exact fun q hq => le_of_lt ( h_contra q hq )
  have h_finite : Set.Finite {q : ℚ | |x - q| < 1 / (q.den : ℝ) ^ 2} := by
    -- For each fixed denominator $d$, there are only finitely many numerators $n$ such that $|x - n/d| < 1/d^2$.
    have h_finite_num : ∀ d ∈ Finset.Icc 1 N, Set.Finite {n : ℤ | |x - n / d| < 1 / (d : ℝ) ^ 2} := by
      intro d hd; refine Set.Finite.subset ( Set.toFinite ( Set.Icc ( ⌊x * d - 1 / ( d : ℝ ) ⌋ ) ( ⌈x * d + 1 / ( d : ℝ ) ⌉ ) ) ) ?_ ; intro n hn; simp_all +decide [ abs_lt ] ;
      field_simp at hn ⊢;
      exact ⟨ Int.le_of_lt_add_one <| Int.floor_lt.2 <| by rw [ div_lt_iff₀ <| by norm_cast; linarith ] ; norm_num; nlinarith [ show ( d : ℝ ) ≥ 1 by norm_cast; linarith, mul_div_cancel₀ ( 1 : ℝ ) ( by norm_cast; nlinarith : ( d : ℝ ) ^ 2 ≠ 0 ), mul_div_cancel₀ ( ( n : ℝ ) : ℝ ) ( by norm_cast; linarith : ( d : ℝ ) ≠ 0 ) ], Int.le_of_lt_add_one <| by rw [ ← @Int.cast_lt ℝ ] ; push_cast; nlinarith [ show ( d : ℝ ) ≥ 1 by norm_cast; linarith, mul_div_cancel₀ ( 1 : ℝ ) ( by norm_cast; nlinarith : ( d : ℝ ) ^ 2 ≠ 0 ), mul_div_cancel₀ ( ( n : ℝ ) : ℝ ) ( by norm_cast; linarith : ( d : ℝ ) ≠ 0 ), Int.le_ceil ( ( d ^ 2 * x + 1 ) / d ), mul_div_cancel₀ ( ( d ^ 2 * x + 1 ) : ℝ ) ( by norm_cast; linarith : ( d : ℝ ) ≠ 0 ) ] ⟩
    generalize_proofs at *; (
    refine Set.Finite.subset ( Set.Finite.biUnion ( Finset.finite_toSet ( Finset.Icc 1 N ) ) fun d hd => Set.Finite.image ( fun n : ℤ => ( n : ℚ ) / d ) ( h_finite_num d hd ) ) ?_;
    intro q hq; specialize h_bounded q hq; specialize h_contra q hq; simp_all +decide ;
    exact ⟨ q.den, ⟨ q.pos, h_bounded ⟩, q.num, by simpa [ Rat.cast_def ] using hq, by simp +decide [ Rat.num_div_den ] ⟩)
  exact (by
  exact h_finite.not_infinite <| by simpa using Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational hx;)

/-- **Characterization of irrationality by integer linear forms.**
`x` is irrational iff there exist integer sequences `a, b` with `aₙ + bₙ·x ≠ 0`
for all `n` and `aₙ + bₙ·x → 0`. -/
theorem irrational_iff_exists_int_linear_combo_tendsto_zero (x : ℝ) :
    Irrational x ↔ ∃ a b : ℕ → ℤ, (∀ n, (a n : ℝ) + b n * x ≠ 0) ∧
      Tendsto (fun n => (a n : ℝ) + b n * x) atTop (𝓝 0) := by
  constructor
  · intro hirr
    choose q hq hqden using exists_rat_mem_den_ge hirr
    refine ⟨fun n => -(q (n+1)).num, fun n => ((q (n+1)).den : ℤ), ?_, ?_⟩
    · intro n hcontra
      have hd : (0:ℝ) < ((q (n+1)).den : ℝ) := by exact_mod_cast (q (n+1)).pos
      apply hirr
      refine ⟨q (n+1), ?_⟩
      have hh : ((q (n+1)).den : ℝ) * x = ((q (n+1)).num : ℝ) := by
        push_cast at hcontra ⊢; linarith
      rw [Rat.cast_def]; field_simp; linarith [hh]
    · have hbound : ∀ n, |(((-(q (n+1)).num : ℤ)) : ℝ) + ((q (n+1)).den : ℤ) * x|
          ≤ 1 / ((n:ℝ)+1) := by
        intro n
        have hdpos : (0:ℝ) < ((q (n+1)).den : ℝ) := by exact_mod_cast (q (n+1)).pos
        have hden_ge : (n:ℝ) + 1 ≤ ((q (n+1)).den : ℝ) := by
          have := hqden (n+1); exact_mod_cast this
        have heq : (((-(q (n+1)).num : ℤ)) : ℝ) + ((q (n+1)).den : ℤ) * x
            = ((q (n+1)).den : ℝ) * (x - (q (n+1) : ℝ)) := by
          rw [Rat.cast_def]; push_cast; field_simp; ring
        rw [heq, abs_mul, abs_of_pos hdpos]
        have h1 := hq (n+1)
        calc ((q (n+1)).den : ℝ) * |x - (q (n+1) : ℝ)|
            ≤ ((q (n+1)).den : ℝ) * (1 / ((q (n+1)).den : ℝ)^2) :=
              mul_le_mul_of_nonneg_left h1.le hdpos.le
          _ = 1 / ((q (n+1)).den : ℝ) := by field_simp
          _ ≤ 1 / ((n:ℝ)+1) := one_div_le_one_div_of_le (by positivity) hden_ge
      apply squeeze_zero_norm (a := fun n : ℕ => 1/((n:ℝ)+1))
      · intro n; rw [Real.norm_eq_abs]; exact hbound n
      · exact tendsto_one_div_add_atTop_nhds_zero_nat
  · rintro ⟨a, b, hne, h⟩
    exact irrational_of_int_linear_combo_tendsto_zero a b hne h

/-- **Reduction of the open problem.** The Euler–Mascheroni constant `γ` is
irrational *iff* there exist integer sequences `a, b` with `aₙ + bₙ·γ ≠ 0` for
all `n` and `aₙ + bₙ·γ → 0`.  Thus the (open) irrationality of `γ` is equivalent
to an explicit Diophantine construction. -/
theorem eulerMascheroniConstant_irrational_iff :
    Irrational eulerMascheroniConstant ↔
      ∃ a b : ℕ → ℤ, (∀ n, (a n : ℝ) + b n * eulerMascheroniConstant ≠ 0) ∧
        Tendsto (fun n => (a n : ℝ) + b n * eulerMascheroniConstant) atTop (𝓝 0) :=
  irrational_iff_exists_int_linear_combo_tendsto_zero eulerMascheroniConstant

end EMR