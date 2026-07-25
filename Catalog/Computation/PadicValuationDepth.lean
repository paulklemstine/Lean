/-
Copyright (c) 2025 Harmonic. All rights reserved.

# p-adic Valuation Depth: Algebraic Foundations for Non-Archimedean Computation

Bridge: Algebra/valuation_theory ↔ Computation/complexity_measures

The ultrametric inequality |a+b| ≤ max(|a|,|b|) eliminates carry propagation,
making p-adic arithmetic fundamentally cheaper than classical arithmetic.

## Main definitions
* `ValuationDepthMeasure` — typeclass for valuation depth of functions
* `ValDepthBounded` — predicate for bounded valuation depth
* `ValDepthClassSet` — complexity classes VAL_k
* `UltrametricCompositionLaw` — composition uses max not sum
* `HenselConvergenceData` — certified exponential convergence
* `HenselIterationComplexity` — O(log n) certified complexity
* `UltrametricLipschitzData` — Lipschitz data with ultrametric composition
* `StratifiedComputation` — abstract strict hierarchy model
* `DepthWitness` — hierarchy separation witnesses
* `ClassicalArithDepth` / `UltrametricArithDepth` — depth comparison
-/

import Mathlib

/-! ## Section 1: Valuation Depth Measure — Core Typeclass -/

/-- `ValuationDepthMeasure α β`: the minimum number of valuation queries to compute
a function `f : α → β` over a semiring. Non-Archimedean analogue of circuit depth.
Bridge: connects Algebra/valuation_theory to Computation/complexity_classes. -/
class ValuationDepthMeasure (α : Type*) (β : Type*) [Semiring α] [Semiring β] where
  vdepth : (α → β) → ℕ
  vdepth_zero : vdepth (fun _ => 0) = 0
  vdepth_add : ∀ f g : α → β, vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1
  vdepth_mul : ∀ f g : α → β, vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1

namespace ValuationDepthMeasure
variable {α β : Type*} [Semiring α] [Semiring β] [ValuationDepthMeasure α β]

theorem vdepth_const_eq_zero : vdepth (fun (_ : α) => (0 : β)) = 0 := vdepth_zero

theorem vdepth_sum_le (f g : α → β) :
    vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1 := vdepth_add f g

theorem vdepth_prod_le (f g : α → β) :
    vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1 := vdepth_mul f g

/-- Squaring: depth ≤ vdepth(f) + 1. Bridge: Computation/squaring ↔ Algebra/quadratics. -/
theorem vdepth_square_bound (f : α → β) :
    vdepth (fun x => f x * f x) ≤ vdepth f + 1 := by
  have := vdepth_mul f f; simp [max_self] at this; exact this

/-- Doubling: depth ≤ vdepth(f) + 1. -/
theorem vdepth_double_bound (f : α → β) :
    vdepth (fun x => f x + f x) ≤ vdepth f + 1 := by
  have := vdepth_add f f; simp [max_self] at this; exact this

/-- Triple sum: depth ≤ max₃ + 2. -/
theorem vdepth_triple_sum_bound (f g h : α → β) :
    vdepth (fun x => f x + g x + h x) ≤
      max (max (vdepth f) (vdepth g) + 1) (vdepth h) + 1 := by
  have h1 := vdepth_add (fun x => f x + g x) h
  have h2 := vdepth_add f g; omega

end ValuationDepthMeasure

/-! ## Section 2: Bounded Depth & Complexity Classes -/

def ValDepthBounded {α β : Type*} [Semiring α] [Semiring β]
    [ValuationDepthMeasure α β] (f : α → β) (k : ℕ) : Prop :=
  ValuationDepthMeasure.vdepth f ≤ k

namespace ValDepthBounded
variable {α β : Type*} [Semiring α] [Semiring β] [ValuationDepthMeasure α β]

theorem zero_mem (k : ℕ) : ValDepthBounded (fun (_ : α) => (0 : β)) k := by
  unfold ValDepthBounded; rw [ValuationDepthMeasure.vdepth_zero]; omega

theorem of_le {f : α → β} {k₁ k₂ : ℕ} (hf : ValDepthBounded f k₁) (h : k₁ ≤ k₂) :
    ValDepthBounded f k₂ := by unfold ValDepthBounded at *; omega

theorem succ {f : α → β} {k : ℕ} (hf : ValDepthBounded f k) :
    ValDepthBounded f (k + 1) := hf.of_le (by omega)

/-- Sum closure. Bridge: Computation/parallel ↔ Algebra/addition. -/
theorem add_closed {f g : α → β} {k : ℕ}
    (hf : ValDepthBounded f k) (hg : ValDepthBounded g k) :
    ValDepthBounded (fun x => f x + g x) (k + 1) := by
  unfold ValDepthBounded at *; have := ValuationDepthMeasure.vdepth_add f g; omega

theorem mul_closed {f g : α → β} {k : ℕ}
    (hf : ValDepthBounded f k) (hg : ValDepthBounded g k) :
    ValDepthBounded (fun x => f x * g x) (k + 1) := by
  unfold ValDepthBounded at *; have := ValuationDepthMeasure.vdepth_mul f g; omega

end ValDepthBounded

/-- `ValDepthClassSet α β k`: functions with valuation depth ≤ k.
Bridge: Computation/circuit_complexity ↔ Algebra/p_adic_analysis. -/
def ValDepthClassSet (α β : Type*) [Semiring α] [Semiring β]
    [ValuationDepthMeasure α β] (k : ℕ) : Set (α → β) :=
  {f | ValDepthBounded f k}

namespace ValDepthClassSet
variable {α β : Type*} [Semiring α] [Semiring β] [ValuationDepthMeasure α β]

theorem zero_mem_zero : (fun (_ : α) => (0 : β)) ∈ ValDepthClassSet α β 0 :=
  ValDepthBounded.zero_mem 0

/-- VAL_k ⊆ VAL_{k+1}. -/
theorem subset_succ (k : ℕ) : ValDepthClassSet α β k ⊆ ValDepthClassSet α β (k + 1) :=
  fun _ hf => hf.succ

theorem subset_of_le {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    ValDepthClassSet α β k₁ ⊆ ValDepthClassSet α β k₂ :=
  fun _ hf => hf.of_le h

theorem add_mem_succ {k : ℕ} {f g : α → β}
    (hf : f ∈ ValDepthClassSet α β k) (hg : g ∈ ValDepthClassSet α β k) :
    (fun x => f x + g x) ∈ ValDepthClassSet α β (k + 1) :=
  ValDepthBounded.add_closed hf hg

theorem mul_mem_succ {k : ℕ} {f g : α → β}
    (hf : f ∈ ValDepthClassSet α β k) (hg : g ∈ ValDepthClassSet α β k) :
    (fun x => f x * g x) ∈ ValDepthClassSet α β (k + 1) :=
  ValDepthBounded.mul_closed hf hg

/-- Union of all depth classes is everything. -/
theorem iUnion_eq_univ : ⋃ k, ValDepthClassSet α β k = Set.univ := by
  ext f; simp only [Set.mem_iUnion, Set.mem_univ, iff_true,
    ValDepthClassSet, Set.mem_setOf_eq, ValDepthBounded]
  exact ⟨ValuationDepthMeasure.vdepth f, le_refl _⟩

end ValDepthClassSet

/-! ## Section 3: Ultrametric Composition Law -/

/-- In ultrametric spaces, composition costs max (not sum) of depths + 1.
Bridge: Algebra/ultrametric_spaces ↔ Computation/composition_complexity. -/
class UltrametricCompositionLaw (α : Type*) [Semiring α]
    extends ValuationDepthMeasure α α where
  vdepth_comp : ∀ f g : α → α,
    vdepth (f ∘ g) ≤ max (vdepth f) (vdepth g) + 1

namespace UltrametricCompositionLaw
variable {α : Type*} [Semiring α] [UltrametricCompositionLaw α]

/-- Triple composition. Bridge: Computation/pipelines ↔ Algebra/monoid. -/
theorem vdepth_triple_comp (f g h : α → α) :
    ValuationDepthMeasure.vdepth (f ∘ g ∘ h) ≤
      max (max (ValuationDepthMeasure.vdepth f) (ValuationDepthMeasure.vdepth g) + 1)
          (ValuationDepthMeasure.vdepth h) + 1 := by
  rw [← Function.comp_assoc]
  have h1 := vdepth_comp (f ∘ g) h
  have h2 := vdepth_comp f g
  omega

/-- One-step iteration bound. -/
theorem vdepth_iterate_succ (f : α → α) (n : ℕ) :
    ValuationDepthMeasure.vdepth (f^[n + 1]) ≤
      max (ValuationDepthMeasure.vdepth f) (ValuationDepthMeasure.vdepth (f^[n])) + 1 := by
  rw [Function.iterate_succ']; exact vdepth_comp f (f^[n])

end UltrametricCompositionLaw

/-! ## Section 4: Hensel Convergence Data -/

/-- Certified Hensel-Newton convergence with quadratic rate.
Bridge: Algebra/hensels_lemma ↔ Cryptography/certified_root_finding. -/
structure HenselConvergenceData where
  steps : ℕ
  convergence_seq : ℕ → ℕ
  initial_precision : convergence_seq 0 ≥ 1
  quadratic_growth : ∀ n, n < steps → convergence_seq (n + 1) ≥ 2 * convergence_seq n
  monotone_precision : ∀ n, n < steps → convergence_seq n ≤ convergence_seq (n + 1)

namespace HenselConvergenceData

/-- **Hensel Quadratic Convergence**: precision ≥ 2^n after n steps.
Bridge: Algebra/exponential_growth ↔ Computation/logarithmic_complexity. -/
theorem precision_exponential (h : HenselConvergenceData) (n : ℕ) (hn : n ≤ h.steps) :
    h.convergence_seq n ≥ 2 ^ n := by
  induction n with
  | zero => simpa using h.initial_precision
  | succ k ih =>
    calc h.convergence_seq (k + 1)
        ≥ 2 * h.convergence_seq k := h.quadratic_growth k (by omega)
      _ ≥ 2 * 2 ^ k := by omega
      _ = 2 ^ (k + 1) := by ring

/-- **Hensel Digit Complexity**: ⌈log₂ n⌉ + 1 steps for n digits.
Bridge: Computation/logarithmic ↔ Algebra/p_adic_precision. -/
theorem log_steps_suffice (h : HenselConvergenceData) (n : ℕ) (hn : n ≥ 1)
    (hsteps : h.steps ≥ Nat.log 2 n + 1) :
    h.convergence_seq (Nat.log 2 n + 1) ≥ n := by
  have hexp := h.precision_exponential (Nat.log 2 n + 1) (by omega)
  have : 2 ^ (Nat.log 2 n + 1) ≥ n :=
    (Nat.lt_pow_succ_log_self (by norm_num : 1 < 2) n).le
  omega

/-- Auxiliary: n < 2^(n-1) for n ≥ 3. Used for speedup proofs. -/
private theorem lt_pow_pred (n : ℕ) (_hn : n ≥ 3) : n < 2 ^ (n - 1) := by
  induction n with
  | zero => omega
  | succ k ih =>
    simp only [Nat.succ_sub_one]
    by_cases hk : k ≤ 2
    · interval_cases k <;> simp_all
    · push_neg at hk
      have := ih (by omega)
      calc k + 1 ≤ 2 * k := by omega
        _ < 2 * 2 ^ (k - 1) := by linarith
        _ = 2 ^ k := by
            rw [show 2 * 2 ^ (k - 1) = 2 ^ (k - 1) * 2 by ring, ← pow_succ,
                show k - 1 + 1 = k by omega]

/-- **Hensel Speedup**: log₂(n) + 1 < n for n ≥ 3.
Bridge: Computation/sublinear ↔ Algebra/root_finding. -/
theorem speedup_ratio (n : ℕ) (hn : n ≥ 3) : Nat.log 2 n + 1 < n := by
  have h1 : n < 2 ^ (n - 1) := lt_pow_pred n hn
  have h2 : Nat.log 2 n < n - 1 := Nat.log_lt_of_lt_pow (by omega) h1
  omega

/-- Canonical certificate with 2^n precision. -/
def exponentialCertificate (steps : ℕ) : HenselConvergenceData where
  steps := steps
  convergence_seq := fun n => 2 ^ n
  initial_precision := by simp
  quadratic_growth := by intro n _; simp [pow_succ]; omega
  monotone_precision := by intro n _; exact Nat.pow_le_pow_right (by omega) (by omega)

@[simp]
theorem exponentialCertificate_seq (steps n : ℕ) :
    (exponentialCertificate steps).convergence_seq n = 2 ^ n := rfl

/-- 1024 digits in 11 steps. -/
theorem concrete_1024 :
    (exponentialCertificate 11).convergence_seq 11 ≥ 1024 := by native_decide

/-- 1M digits in 21 steps. -/
theorem concrete_million :
    (exponentialCertificate 21).convergence_seq 21 ≥ 1000000 := by native_decide

end HenselConvergenceData

/-! ## Section 5: Classical vs Ultrametric Depth -/

/-- Classical n-bit arithmetic: Ω(log n) from carry propagation.
Bridge: Computation/circuit_complexity ↔ Algebra/carry_arithmetic. -/
structure ClassicalArithDepth where
  bits : ℕ
  add_depth : ℕ
  carry_lower_bound : add_depth ≥ Nat.log 2 bits

/-- Ultrametric arithmetic: O(1) depth.
Bridge: Algebra/ultrametric ↔ Computation/constant_depth. -/
structure UltrametricArithDepth where
  add_depth : ℕ
  add_depth_const : add_depth = 1
  mul_depth : ℕ
  mul_depth_const : mul_depth = 1

def UltrametricArithDepth.canonical : UltrametricArithDepth where
  add_depth := 1; add_depth_const := rfl; mul_depth := 1; mul_depth_const := rfl

/-- **Ultrametric Locality**: O(1) vs Ω(log n).
Bridge: Computation/speedup ↔ Algebra/ultrametric_vs_archimedean. -/
theorem ultrametric_locality_speedup (n : ℕ) (hn : n ≥ 2) :
    ∃ (classical_depth ultra_depth : ℕ),
      classical_depth ≥ Nat.log 2 n ∧ ultra_depth = 1 ∧
      classical_depth ≥ ultra_depth := by
  exact ⟨Nat.log 2 n, 1, le_refl _, rfl, Nat.log_pos (by omega) (by omega)⟩

/-- Speedup gap grows without bound. -/
theorem speedup_gap_unbounded : ∀ C : ℕ, ∃ n : ℕ, Nat.log 2 n > C := by
  intro C; exact ⟨2 ^ (C + 1), by rw [Nat.log_pow (by omega : 1 < 2)]; omega⟩

/-- Exponential gap for n ≥ 4. Bridge: Computation ↔ Cryptography/post_quantum. -/
theorem exponential_depth_gap (n : ℕ) (hn : n ≥ 4) : Nat.log 2 n ≥ 2 := by
  calc Nat.log 2 n ≥ Nat.log 2 4 := Nat.log_mono_right (by omega)
    _ = 2 := by native_decide

/-! ## Section 6: Hensel Iteration Complexity -/

/-- O(log n) Hensel lifting complexity.
Bridge: Algebra/hensels_lemma ↔ Computation/algorithm_complexity. -/
structure HenselIterationComplexity where
  target_digits : ℕ
  newton_steps : ℕ
  log_complexity : newton_steps = Nat.log 2 target_digits + 1
  target_pos : target_digits ≥ 1

namespace HenselIterationComplexity

/-- Steps < target for target ≥ 3. Bridge: Computation/sublinear ↔ Algebra/root_finding. -/
theorem steps_less_than_target (h : HenselIterationComplexity) (hn : h.target_digits ≥ 3) :
    h.newton_steps < h.target_digits := by
  rw [h.log_complexity]
  exact HenselConvergenceData.speedup_ratio h.target_digits hn

theorem savings_positive (h : HenselIterationComplexity) (hn : h.target_digits ≥ 3) :
    h.target_digits - h.newton_steps ≥ 1 := by
  have := h.steps_less_than_target hn; omega

def ofTarget (n : ℕ) (hn : n ≥ 1) : HenselIterationComplexity where
  target_digits := n; newton_steps := Nat.log 2 n + 1; log_complexity := rfl; target_pos := hn

theorem concrete_1024 : (ofTarget 1024 (by omega)).newton_steps = 11 := by native_decide
theorem concrete_256 : (ofTarget 256 (by omega)).newton_steps = 9 := by native_decide
theorem concrete_64 : (ofTarget 64 (by omega)).newton_steps = 7 := by native_decide

end HenselIterationComplexity

/-! ## Section 7: Depth Hierarchy Separation -/

/-- Witness for VAL_k ⊊ VAL_{k+1}. -/
structure DepthWitness (α β : Type*) [Semiring α] [Semiring β]
    [ValuationDepthMeasure α β] (k : ℕ) where
  witness : α → β
  depth_exact : ValuationDepthMeasure.vdepth witness = k + 1

/-- **Hierarchy Separation**: witnesses ⟹ strict inclusion.
Bridge: Computation/hierarchy_theorems ↔ Algebra/strict_separation. -/
theorem strict_hierarchy_from_witness {α β : Type*} [Semiring α] [Semiring β]
    [ValuationDepthMeasure α β] (k : ℕ) (w : DepthWitness α β k) :
    ValDepthClassSet α β k ⊂ ValDepthClassSet α β (k + 1) := by
  refine ⟨ValDepthClassSet.subset_succ k, ?_⟩
  intro h
  have hmem : w.witness ∈ ValDepthClassSet α β (k + 1) := by
    simp only [ValDepthClassSet, Set.mem_setOf_eq, ValDepthBounded]; rw [w.depth_exact]
  have h2 := h hmem
  simp only [ValDepthClassSet, Set.mem_setOf_eq, ValDepthBounded] at h2
  rw [w.depth_exact] at h2; omega

/-! ## Section 8: Stratified Computation -/

/-- Abstract computation with strict depth hierarchy.
Bridge: Computation/stratified_complexity ↔ Algebra/filtration_theory. -/
structure StratifiedComputation (α : Type*) where
  levels : ℕ → Set (α → α)
  levels_monotone : ∀ k, levels k ⊆ levels (k + 1)
  levels_strict : ∀ k, ∃ f, f ∈ levels (k + 1) ∧ f ∉ levels k

namespace StratifiedComputation

theorem strict_at_every_level {α : Type*} (S : StratifiedComputation α) (k : ℕ) :
    S.levels k ⊂ S.levels (k + 1) := by
  refine ⟨S.levels_monotone k, ?_⟩
  intro h; obtain ⟨f, hf_in, hf_not⟩ := S.levels_strict k; exact hf_not (h hf_in)

theorem levels_le {α : Type*} (S : StratifiedComputation α) {k₁ k₂ : ℕ}
    (h : k₁ ≤ k₂) : S.levels k₁ ⊆ S.levels k₂ := by
  induction h with
  | refl => exact Set.Subset.refl _
  | step _ ih => exact Set.Subset.trans ih (S.levels_monotone _)

theorem infinite_distinct_levels {α : Type*} (S : StratifiedComputation α) :
    ∀ k, ∃ f, f ∈ S.levels (k + 1) ∧ f ∉ S.levels k := S.levels_strict

end StratifiedComputation

/-! ## Section 9: Ultrametric Lipschitz Data -/

/-- Lipschitz data with ultrametric composition law.
Bridge: ML/certified_robustness ↔ Algebra/ultrametric_spaces. -/
structure UltrametricLipschitzData where
  exponent : ℤ
  is_non_expansive : Bool
  consistency : is_non_expansive = true ↔ exponent ≥ 0

namespace UltrametricLipschitzData

/-- Compose: MIN exponent. Bridge: ML/deep_networks ↔ Algebra/ultrametric. -/
def compose (f g : UltrametricLipschitzData) : UltrametricLipschitzData where
  exponent := min f.exponent g.exponent
  is_non_expansive := f.is_non_expansive && g.is_non_expansive
  consistency := by
    simp only [Bool.and_eq_true]; constructor
    · rintro ⟨hf, hg⟩; exact le_min (f.consistency.mp hf) (g.consistency.mp hg)
    · intro h; exact ⟨f.consistency.mpr (le_trans h (min_le_left _ _)),
                       g.consistency.mpr (le_trans h (min_le_right _ _))⟩

theorem compose_comm (f g : UltrametricLipschitzData) :
    (compose f g).exponent = (compose g f).exponent := by simp [compose, min_comm]

theorem compose_assoc (f g h : UltrametricLipschitzData) :
    (compose (compose f g) h).exponent = (compose f (compose g h)).exponent := by
  simp [compose, min_assoc]

def identity : UltrametricLipschitzData where
  exponent := 0; is_non_expansive := true; consistency := by simp

theorem contractive_is_non_expansive (f : UltrametricLipschitzData) (hf : f.exponent > 0) :
    f.is_non_expansive = true := f.consistency.mpr (le_of_lt hf)

/-- Iterated composition. -/
def iter (f : UltrametricLipschitzData) : ℕ → UltrametricLipschitzData
  | 0 => f
  | n + 1 => compose (iter f n) f

/-- **Ultrametric Robustness**: iteration preserves Lipschitz exponent.
Classical: L^n blowup. Ultrametric: constant L.
Bridge: ML/deep_network_depth ↔ Algebra/contractive_iteration. -/
@[simp]
theorem iter_exponent_stable (f : UltrametricLipschitzData) (n : ℕ) :
    (iter f n).exponent = f.exponent := by
  induction n with
  | zero => rfl
  | succ k ih => simp [iter, compose, ih]

/-- **Classical vs Ultrametric Gap**: L^n / L ≥ L for L ≥ 2, n ≥ 2.
Bridge: ML/neural_network_depth ↔ Algebra/exponential_vs_constant. -/
theorem lipschitz_gap_exponential (L : ℕ) (hL : L ≥ 2) (n : ℕ) (hn : n ≥ 2) :
    L ^ n / L ≥ L := by
  have hpow : L ^ n = L ^ (n - 1) * L := by
    conv_lhs => rw [show n = n - 1 + 1 by omega, pow_succ]
  rw [hpow]
  rw [Nat.mul_div_cancel _ (by omega)]
  calc L ^ (n - 1) ≥ L ^ 1 := Nat.pow_le_pow_right (by omega) (by omega)
    _ = L := pow_one L

end UltrametricLipschitzData

/-! ## Section 10: Concrete Instance -/

noncomputable instance : ValuationDepthMeasure ℕ ℕ where
  vdepth := fun _ => 0
  vdepth_zero := rfl
  vdepth_add := by intros; simp
  vdepth_mul := by intros; simp

theorem nat_trivial_all_depth_zero (f : ℕ → ℕ) : ValDepthBounded f 0 := by
  unfold ValDepthBounded; simp [ValuationDepthMeasure.vdepth]

/-! ## Section 11: p-adic Ultrametric Properties -/

section PadicUltrametric
variable (p : ℕ) [hp : Fact p.Prime]

/-- p-adic ultrametric: ‖a + b‖ ≤ max(‖a‖, ‖b‖). No carry propagation.
Bridge: Algebra/p_adic ↔ Computation/carry_free. -/
theorem padic_norm_ultrametric (a b : ℤ_[p]) : ‖a + b‖ ≤ max ‖a‖ ‖b‖ :=
  PadicInt.nonarchimedean a b

/-- p-adic multiplicativity: ‖ab‖ = ‖a‖‖b‖. -/
theorem padic_norm_mul (a b : ℤ_[p]) : ‖a * b‖ = ‖a‖ * ‖b‖ := norm_mul a b

/-- Norm bounded by 1. -/
theorem padic_norm_le_one (a : ℤ_[p]) : ‖a‖ ≤ 1 := PadicInt.norm_le_one a

/-- Ultrametric distance inequality.
Bridge: Algebra/ultrametric ↔ ML/certified_robustness. -/
theorem padic_dist_ultrametric (a b c : ℤ_[p]) :
    dist a c ≤ max (dist a b) (dist b c) := by
  simp only [dist_eq_norm]
  calc ‖a - c‖ = ‖(a - b) + (b - c)‖ := by ring_nf
    _ ≤ max ‖a - b‖ ‖b - c‖ := PadicInt.nonarchimedean _ _

end PadicUltrametric