/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import ValuatedMatroidDepth.Defs

/-!
# Valuated Matroid Depth: Main Theorems

This file proves the main theorems of the directional depth filtration theory,
establishing the algebraic, tropical, and combinatorial properties of the
depth invariant.

## Main Results

* `directionalDepthAtLeast_mul` — multiplicative depth stability (Theorem 1)
* `negLog_supermodular_of_mixedLC` — tropical bridge via mixed log-concavity (Theorem 2)
* `not_depth_two_of_ratio_failure` — depth obstruction criterion (Theorem 3)
* `ratio_energy_supermodular` — statistical physics bridge (Theorem 4)
* `exists_depth_one_not_depth_two` — depth hierarchy strictness (Theorem 5)

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

noncomputable section

open Finset BigOperators Function

namespace ValuatedMatroidDepth

variable {α : Type*}

section structural
variable [Fintype α] [DecidableEq α]

/-- Depth ≥ k+1 implies depth ≥ k. -/
theorem DirectionalDepthAtLeast_of_succ
    (k : ℕ) (f : (α → ℕ) → ℝ)
    (hf : DirectionalDepthAtLeast (k + 1) f) :
    DirectionalDepthAtLeast k f := by
  induction k generalizing f with
  | zero => exact trivial
  | succ k ih =>
    exact ⟨hf.1, fun i => ih _ (hf.2 i)⟩

/-- Depth is monotone: depth ≥ k and j ≤ k implies depth ≥ j. -/
theorem DirectionalDepthAtLeast_mono
    {j k : ℕ} {f : (α → ℕ) → ℝ}
    (hf : DirectionalDepthAtLeast k f)
    (hjk : j ≤ k) :
    DirectionalDepthAtLeast j f := by
  induction k generalizing j f with
  | zero => simp at hjk; subst hjk; exact hf
  | succ k ih =>
    rcases Nat.eq_or_lt_of_le hjk with rfl | hjk'
    · exact hf
    · exact ih (DirectionalDepthAtLeast_of_succ k f hf) (Nat.lt_succ_iff.mp hjk')

end structural

section basic
variable [DecidableEq α]

/-- Depth ≥ 1 implies multivariate directional log-concavity. -/
theorem DirectionalDepthAtLeast.logConcave
    {f : (α → ℕ) → ℝ}
    (hf : DirectionalDepthAtLeast 1 f) :
    MultiDirLogConcave f :=
  hf.1

/-- The ratio transform distributes over pointwise products. -/
theorem ratioTransform_mul (i : α) (f g : (α → ℕ) → ℝ) :
    ratioTransform i (fun m => f m * g m) =
    fun m => ratioTransform i f m * ratioTransform i g m := by
  ext m
  simp only [ratioTransform]
  rw [mul_div_mul_comm]

/-- Ratio transform positivity. -/
theorem ratioTransform_pos (i : α) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m) :
    ∀ m, 0 < ratioTransform i f m := fun m =>
  div_pos (hf_pos _) (hf_pos _)

/-- Infinite depth is equivalent to depth ≥ k for all k. -/
theorem hasInfiniteDepth_iff (f : (α → ℕ) → ℝ) :
    HasInfiniteDepth f ↔ ∀ k, DirectionalDepthAtLeast k f := by
  rfl

end basic

section main_theorems
variable [Fintype α] [DecidableEq α]

/-! ## Theorem 1: Multiplicative Depth Stability -/

/-- **Log-concavity of products**: if `f` and `g` are both directionally
    log-concave and everywhere nonneg, then `f · g` is directionally log-concave. -/
theorem multiDirLogConcave_mul
    (f g : (α → ℕ) → ℝ)
    (hf_nn : ∀ m, 0 ≤ f m)
    (hg_nn : ∀ m, 0 ≤ g m)
    (hf : MultiDirLogConcave f)
    (hg : MultiDirLogConcave g) :
    MultiDirLogConcave (fun m => f m * g m) := by
  intro i m
  have := hf i m
  have := hg i m
  simp_all +decide [MultiDirLogConcave]
  convert mul_le_mul (hf i m) (hg i m) (mul_nonneg (hg_nn _) (hg_nn _)) (sq_nonneg _) using 1
    <;> ring

/-- **Theorem 1 (Multiplicative Depth Stability)**:
    If `f` and `g` each have directional depth at least `k`, and both are everywhere
    positive, then their pointwise product also has depth at least `k`.

    This upgrades first-order log-concavity closure to an entire depth filtration,
    making the depth classes into multiplicative monoids. -/
theorem directionalDepthAtLeast_mul
    (k : ℕ) (f g : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hg_pos : ∀ m, 0 < g m)
    (hf : DirectionalDepthAtLeast k f)
    (hg : DirectionalDepthAtLeast k g) :
    DirectionalDepthAtLeast k (fun m => f m * g m) := by
  induction k generalizing f g with
  | zero => exact trivial
  | succ k ih =>
    constructor
    · exact multiDirLogConcave_mul f g (fun m => le_of_lt (hf_pos m))
        (fun m => le_of_lt (hg_pos m)) hf.1 hg.1
    · intro i
      have hrw : ratioTransform i (fun m => f m * g m) =
          fun m => ratioTransform i f m * ratioTransform i g m :=
        ratioTransform_mul i f g
      rw [hrw]
      exact ih _ _ (ratioTransform_pos i f hf_pos) (ratioTransform_pos i g hg_pos)
        (hf.2 i) (hg.2 i)

/-! ## Mixed Log-Concavity Multiplicative Stability -/

/-
**Mixed log-concavity of products**: if `f` and `g` are both mixed
    log-concave and everywhere nonneg, then `f · g` is mixed log-concave.
-/
theorem mixedLogConcave_mul
    (f g : (α → ℕ) → ℝ)
    (hf_nn : ∀ m, 0 ≤ f m)
    (hg_nn : ∀ m, 0 ≤ g m)
    (hf : MixedLogConcave f)
    (hg : MixedLogConcave g) :
    MixedLogConcave (fun m => f m * g m) := by
  intro i j m;
  have := hf i j m; have := hg i j m; have := hf j i m; have := hg j i m; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  convert mul_le_mul ‹f m * f ( m + Pi.single i 1 + Pi.single j 1 ) ≤ f ( m + Pi.single i 1 ) * f ( m + Pi.single j 1 ) › ‹g m * g ( m + Pi.single i 1 + Pi.single j 1 ) ≤ g ( m + Pi.single i 1 ) * g ( m + Pi.single j 1 ) › ( by apply_rules [ mul_nonneg, hf_nn, hg_nn ] ) ( by apply_rules [ mul_nonneg, hf_nn, hg_nn ] ) using 1 <;> ring

/-! ## Theorem 2: Tropical Bridge -/

/-
**Theorem 2 (Tropical Bridge)**:
    If `f` is mixed log-concave and everywhere positive, then `-log f` is
    supermodular. This is the fundamental connection between log-concavity
    hierarchies and tropical convexity.

    The supermodularity condition `-log f(m+eᵢ+eⱼ) + (-log f(m)) ≥
    (-log f(m+eᵢ)) + (-log f(m+eⱼ))` is equivalent to
    `f(m+eᵢ)·f(m+eⱼ) ≥ f(m)·f(m+eᵢ+eⱼ)`, which is exactly
    mixed log-concavity.
-/
theorem negLog_supermodular_of_mixedLC
    (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (hf : MixedLogConcave f) :
    IsSupermodular (fun m => - Real.log (f m)) := by
  intro i j m hij;
  have := hf i j m;
  have := Real.log_le_log ( mul_pos ( hf_pos _ ) ( hf_pos _ ) ) this; simp_all +decide [ Real.log_mul, ne_of_gt ] ;
  linarith

/-! ## Theorem 3: Depth Obstruction -/

/-- **Theorem 3 (Depth Obstruction)**:
    If some ratio transform `Rᵢf` fails directional log-concavity,
    then `f` does not have depth ≥ 2. This provides a computational
    criterion for bounding depth from above. -/
theorem not_depth_two_of_ratio_failure
    (f : (α → ℕ) → ℝ)
    (i : α)
    (hfail : ¬ MultiDirLogConcave (ratioTransform i f)) :
    ¬ DirectionalDepthAtLeast 2 f := by
  contrapose! hfail
  exact (hfail.2 i).1

/-! ## Theorem 4: Cross-Domain (Statistical Physics / Energy Landscape) -/

/-- **Ratio energy supermodularity**: if `f` has depth ≥ 2 and satisfies a
    mixed log-concavity condition at the ratio level, then the local free energy
    increment `-log(Rᵢf)` is supermodular.

    In statistical mechanics, `-log f` is an energy landscape and `Rᵢf` represents
    a local chemical potential / free-energy increment. This theorem says
    depth ≥ 2 with mixed conditions ensures the response function is convex
    in the tropical sense. -/
theorem ratio_energy_supermodular
    (i : α) (f : (α → ℕ) → ℝ)
    (hf_pos : ∀ m, 0 < f m)
    (_hf_depth : DirectionalDepthAtLeast 2 f)
    (hf_mixed_ratio : MixedLogConcave (ratioTransform i f)) :
    IsSupermodular (fun m => - Real.log (ratioTransform i f m)) :=
  negLog_supermodular_of_mixedLC _ (ratioTransform_pos i f hf_pos) hf_mixed_ratio

/-! ## Theorem 5: Hierarchy Strictness -/

/-
There exists a function with depth ≥ 1 but not depth ≥ 2.
    We construct an explicit witness on `Fin 2` (two-variable setting).
-/
theorem exists_depth_one_not_depth_two :
    ∃ (α : Type) (_ : Fintype α) (_ : DecidableEq α) (f : (α → ℕ) → ℝ),
      DirectionalDepthAtLeast 1 f ∧ ¬ DirectionalDepthAtLeast 2 f := by
  refine' ⟨ _, _, _ ⟩;
  exact Fin 1;
  · infer_instance;
  · refine' ⟨ _, _, _, _ ⟩;
    all_goals try infer_instance;
    exact fun m => if m 0 = 0 then 1 else if m 0 = 1 then 3 else if m 0 = 2 then 2 else if m 0 = 3 then 1 else 0;
    · constructor;
      · intro i m; rcases m0 : m 0 with ( _ | _ | _ | _ | m0 ) <;> simp +decide [ m0 ] ;
        · fin_cases i ; norm_num;
        · fin_cases i ; norm_num;
        · fin_cases i ; norm_num;
        · fin_cases i ; norm_num;
        · split_ifs <;> norm_num;
      · exact fun _ => trivial;
    · rintro ⟨ h₁, h₂ ⟩;
      obtain ⟨ h₃, h₄ ⟩ := h₂ 0;
      specialize h₃ 0 ( fun _ => 0 ) ; norm_num [ shiftUp, shiftUp2, ratioTransform ] at h₃

end main_theorems

end ValuatedMatroidDepth

end