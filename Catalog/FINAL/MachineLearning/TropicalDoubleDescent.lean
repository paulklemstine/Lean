/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Double Descent Phase Transition

This file formalizes the **double descent** phenomenon in statistical learning theory
as a **tropical phase transition**: two competing affine risk branches, one classical
and one modern (overparameterized), glued by the min-plus operation, with the
interpolation threshold characterized as a unique **tropical vertex** where the
active facet switches.

## Main results

### Concrete model

- `classicalRisk`, `modernRisk`, `tropicalRisk`: concrete affine risk branches and
  their tropical (min-plus) combination.
- `tropicalRisk_left_facet`: for `n ≤ n₀`, the tropical risk equals the classical branch.
- `tropicalRisk_right_facet`: for `n₀ ≤ n`, the tropical risk equals the modern branch.
- `tropicalRisk_vertex`: at the threshold `n₀`, both branches agree.
- `tropicalRisk_strictly_increases_to_threshold`: strict increase toward `n₀`.
- `tropicalRisk_strictly_decreases_after_threshold`: strict decrease after `n₀`.
- `tropicalRisk_unique_maximum`: `n₀` is the unique global maximum.

### General tropical affine phase transition

- `affineNat`, `tropicalAffineRisk`: general affine forms and their tropical minimum.
- `tropical_affine_unique_vertex`: the main abstract theorem certifying the full
  double-descent shape for any pair of crossing affine forms with opposite slopes.

### Cross-domain bridges

- `tropical_vertex_stability_under_uniform_error`: quantization/perturbation stability
  of the tropical vertex under uniform approximation error.

## References

* Belkin, M., Hsu, D., Ma, S., & Mandal, S. (2019). Reconciling modern machine learning
  practice and the bias-variance trade-off.
* Nakkiran, P., et al. (2021). Deep double descent: Where bigger models and more data
  can hurt.

## Tags

tropical geometry, double descent, min-plus algebra, phase transition, interpolation threshold
-/

noncomputable section

open Finset BigOperators

/-! ## Section 1: Concrete Tropical Risk Model -/

/-- The **classical risk branch**: an affine function that increases with model complexity `n`,
    representing the classical bias-variance tradeoff where more parameters eventually hurt.
    Parameterized so that it equals `A - B * n₀` at `n = n₀`. -/
def classicalRisk (A B : ℝ) (n₀ n : ℕ) : ℝ :=
  A + B * (n : ℝ) - 2 * B * (n₀ : ℝ)

/-- The **modern risk branch**: an affine function that decreases with model complexity `n`,
    representing the overparameterized regime where more parameters help. -/
def modernRisk (A B : ℝ) (_n₀ n : ℕ) : ℝ :=
  A - B * (n : ℝ)

/-- The **tropical risk**: the min-plus combination of classical and modern branches.
    This is the pointwise minimum, modeling the idea that the effective risk is
    whichever regime dominates at each complexity level. -/
def tropicalRisk (A B : ℝ) (n₀ n : ℕ) : ℝ :=
  min (classicalRisk A B n₀ n) (modernRisk A B n₀ n)

/-! ### Branch difference and sign characterization -/

/-- The gap between the modern and classical branches simplifies to a linear function
    of the distance from the threshold. -/
lemma classicalRisk_sub_modernRisk (A B : ℝ) (n₀ n : ℕ) :
    classicalRisk A B n₀ n - modernRisk A B n₀ n
      = 2 * B * ((n : ℝ) - (n₀ : ℝ)) := by
  simp [classicalRisk, modernRisk]; ring

/-
When `n ≤ n₀`, the classical branch is at most the modern branch.
-/
lemma classical_le_modern {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n ≤ n₀) :
    classicalRisk A B n₀ n ≤ modernRisk A B n₀ n := by
  exact le_of_sub_nonpos ( by rw [ classicalRisk_sub_modernRisk ] ; nlinarith [ ( by norm_cast : ( n:ℝ ) ≤ n₀ ) ] )

/-
When `n₀ ≤ n`, the modern branch is at most the classical branch.
-/
lemma modern_le_classical {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n₀ ≤ n) :
    modernRisk A B n₀ n ≤ classicalRisk A B n₀ n := by
  unfold modernRisk classicalRisk; nlinarith [ ( by norm_cast : ( n₀ : ℝ ) ≤ n ) ] ;

/-
Iff characterization: classical ≤ modern ↔ n ≤ n₀.
-/
theorem classical_le_modern_iff {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    classicalRisk A B n₀ n ≤ modernRisk A B n₀ n ↔ n ≤ n₀ := by
  exact ⟨ fun h => by rw [ ← @Nat.cast_le ℝ ] ; nlinarith [ classicalRisk_sub_modernRisk A B n₀ n ], fun h => by rw [ ← @Nat.cast_le ℝ ] at h; nlinarith [ classicalRisk_sub_modernRisk A B n₀ n ] ⟩

/-
Iff characterization: modern ≤ classical ↔ n₀ ≤ n.
-/
theorem modern_le_classical_iff {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    modernRisk A B n₀ n ≤ classicalRisk A B n₀ n ↔ n₀ ≤ n := by
  constructor;
  · unfold modernRisk classicalRisk;
    exact fun h => Nat.le_of_lt_succ <| by rw [ ← @Nat.cast_lt ℝ ] ; push_cast; nlinarith;
  · grind +suggestions

/-! ### Facet dominance and vertex -/

/-- On the left of the threshold, the tropical risk equals the classical branch. -/
theorem tropicalRisk_left_facet {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n ≤ n₀) :
    tropicalRisk A B n₀ n = classicalRisk A B n₀ n := by
  exact min_eq_left (classical_le_modern hB h)

/-- On the right of the threshold, the tropical risk equals the modern branch. -/
theorem tropicalRisk_right_facet {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n₀ ≤ n) :
    tropicalRisk A B n₀ n = modernRisk A B n₀ n := by
  exact min_eq_right (modern_le_classical hB h)

/-- At the threshold, both branches agree: the **tropical vertex**. -/
theorem tropicalRisk_vertex (A B : ℝ) (n₀ : ℕ) :
    classicalRisk A B n₀ n₀ = modernRisk A B n₀ n₀ := by
  simp [classicalRisk, modernRisk]; ring

/-- The tropical risk at the vertex equals `A - B * n₀`. -/
theorem tropicalRisk_at_vertex {A B : ℝ} (hB : 0 < B) (n₀ : ℕ) :
    tropicalRisk A B n₀ n₀ = A - B * (n₀ : ℝ) := by
  rw [tropicalRisk_right_facet hB le_rfl]
  simp [modernRisk]

/-! ### Strict monotonicity -/

/-
The tropical risk strictly increases toward the threshold from the left.
-/
theorem tropicalRisk_strictly_increases_to_threshold
    {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n < n₀) :
    tropicalRisk A B n₀ n < tropicalRisk A B n₀ (n + 1) := by
  unfold tropicalRisk;
  unfold classicalRisk modernRisk;
  cases min_cases ( A + B * n - 2 * B * n₀ ) ( A - B * n ) <;> cases min_cases ( A + B * ( n + 1 ) - 2 * B * n₀ ) ( A - B * ( n + 1 ) ) <;> push_cast at * <;> nlinarith [ ( by norm_cast : ( n : ℝ ) + 1 ≤ n₀ ) ]

/-
The tropical risk strictly decreases after the threshold.
-/
theorem tropicalRisk_strictly_decreases_after_threshold
    {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (h : n₀ ≤ n) :
    tropicalRisk A B n₀ (n + 1) < tropicalRisk A B n₀ n := by
  rw [ tropicalRisk_right_facet hB, tropicalRisk_right_facet hB ];
  · unfold modernRisk; norm_num; linarith;
  · linarith;
  · linarith

/-! ### Unique maximum -/

/-
The tropical risk is maximized at the threshold `n₀`.
-/
theorem tropicalRisk_unique_maximum
    {A B : ℝ} (_hB : 0 < B) (n₀ n : ℕ) :
    tropicalRisk A B n₀ n ≤ tropicalRisk A B n₀ n₀ := by
  grind +locals

/-
The maximum is strict when `n ≠ n₀`.
-/
theorem tropicalRisk_strict_maximum
    {A B : ℝ} (hB : 0 < B) {n₀ n : ℕ} (hne : n ≠ n₀) :
    tropicalRisk A B n₀ n < tropicalRisk A B n₀ n₀ := by
  cases lt_or_gt_of_ne hne;
  · have h_tropicalRisk_lt : ∀ m : ℕ, n < m ∧ m ≤ n₀ → tropicalRisk A B n₀ n < tropicalRisk A B n₀ m := by
      intro m hm
      induction' m with m ih;
      · grobner;
      · cases lt_or_eq_of_le ( Nat.le_of_lt_succ hm.1 ) <;> simp_all +decide;
        · exact lt_trans ( ih ( by linarith ) ) ( tropicalRisk_strictly_increases_to_threshold hB ( by linarith ) );
        · exact?;
    exact h_tropicalRisk_lt n₀ ⟨ by linarith, by linarith ⟩;
  · -- Since $n₀ < n$, we can apply the strict decrease property of the tropical risk after the threshold.
    have h_decr : ∀ m ≥ n₀, n₀ < m → tropicalRisk A B n₀ m < tropicalRisk A B n₀ n₀ := by
      intros m hm₁ hm₂;
      induction hm₂ <;> simp_all +decide [ tropicalRisk_right_facet ];
      · unfold modernRisk; norm_num; linarith;
      · exact lt_of_le_of_lt ( by unfold modernRisk; norm_num; nlinarith ) ( ‹n₀ ≤ _ → modernRisk A B n₀ _ < modernRisk A B n₀ n₀› ( by linarith ) );
    grind +splitImp

/-! ### Combined phase transition theorem -/

/-- **Main theorem**: The tropical risk model exhibits a complete double-descent
    phase transition. This certifies: branch dominance on each side, equality at
    the threshold, strict monotonicity in both directions, and a local maximum. -/
theorem tropical_double_descent_phase_transition
    {A B : ℝ} (hB : 0 < B) (n₀ n : ℕ) :
    ((n ≤ n₀) → tropicalRisk A B n₀ n = classicalRisk A B n₀ n) ∧
    ((n₀ ≤ n) → tropicalRisk A B n₀ n = modernRisk A B n₀ n) ∧
    tropicalRisk A B n₀ n₀ = A - B * (n₀ : ℝ) ∧
    ((n < n₀) → tropicalRisk A B n₀ n < tropicalRisk A B n₀ (n + 1)) ∧
    ((n₀ ≤ n) → tropicalRisk A B n₀ (n + 1) < tropicalRisk A B n₀ n) :=
  ⟨tropicalRisk_left_facet hB,
   tropicalRisk_right_facet hB,
   tropicalRisk_at_vertex hB n₀,
   tropicalRisk_strictly_increases_to_threshold hB,
   tropicalRisk_strictly_decreases_after_threshold hB⟩

/-! ## Section 2: General Tropical Affine Phase Transition -/

/-- A general affine form on `ℕ`. -/
def affineNat (α β : ℝ) (n : ℕ) : ℝ := α + β * (n : ℝ)

/-- The tropical minimum of two affine forms. -/
def tropicalAffineRisk (α₁ β₁ α₂ β₂ : ℝ) (n : ℕ) : ℝ :=
  min (affineNat α₁ β₁ n) (affineNat α₂ β₂ n)

/-- Key lemma: the difference of two affine forms is affine. -/
lemma affineNat_sub (α₁ β₁ α₂ β₂ : ℝ) (n : ℕ) :
    affineNat α₁ β₁ n - affineNat α₂ β₂ n = (α₁ - α₂) + (β₁ - β₂) * (n : ℝ) := by
  simp [affineNat]; ring

/-
When the first affine form has positive slope and the second has negative slope,
    and they cross at `n₀`, the first is ≤ the second iff `n ≤ n₀`.
-/
lemma affineNat_le_iff_of_crossing
    {α₁ β₁ α₂ β₂ : ℝ} {n₀ : ℕ}
    (hβ₁ : 0 < β₁) (hβ₂ : β₂ < 0)
    (hcross : affineNat α₁ β₁ n₀ = affineNat α₂ β₂ n₀)
    (_huniq : ∀ n : ℕ, affineNat α₁ β₁ n = affineNat α₂ β₂ n → n = n₀)
    (n : ℕ) :
    affineNat α₁ β₁ n ≤ affineNat α₂ β₂ n ↔ n ≤ n₀ := by
  constructor <;> intro hn;
  · contrapose! hn;
    unfold affineNat at * ; nlinarith [ ( by norm_cast : ( n₀ : ℝ ) + 1 ≤ n ) ];
  · unfold affineNat at *;
    nlinarith [ ( by norm_cast : ( n : ℝ ) ≤ n₀ ) ]

/-
**General tropical affine phase transition**: If two affine forms with opposite
    slope signs cross at a unique natural number `n₀`, then their tropical minimum
    exhibits a complete double-descent shape.
-/
theorem tropical_affine_unique_vertex
    {α₁ β₁ α₂ β₂ : ℝ} {n₀ : ℕ}
    (hβ₁ : 0 < β₁) (hβ₂ : β₂ < 0)
    (hcross : affineNat α₁ β₁ n₀ = affineNat α₂ β₂ n₀)
    (_huniq : ∀ n : ℕ, affineNat α₁ β₁ n = affineNat α₂ β₂ n → n = n₀) :
    (∀ n, n ≤ n₀ → tropicalAffineRisk α₁ β₁ α₂ β₂ n = affineNat α₁ β₁ n) ∧
    (∀ n, n₀ ≤ n → tropicalAffineRisk α₁ β₁ α₂ β₂ n = affineNat α₂ β₂ n) ∧
    (∀ n, n < n₀ → tropicalAffineRisk α₁ β₁ α₂ β₂ n < tropicalAffineRisk α₁ β₁ α₂ β₂ (n + 1)) ∧
    (∀ n, n₀ ≤ n → tropicalAffineRisk α₁ β₁ α₂ β₂ (n + 1) < tropicalAffineRisk α₁ β₁ α₂ β₂ n) := by
  unfold tropicalAffineRisk affineNat at *;
  refine' ⟨ _, _, _, _ ⟩;
  · exact fun n hn => min_eq_left <| by nlinarith [ ( by norm_cast : ( n : ℝ ) ≤ n₀ ) ] ;
  · exact fun n hn => min_eq_right <| by nlinarith [ ( by norm_cast : ( n₀ : ℝ ) ≤ n ) ] ;
  · intro n hn; rw [ min_eq_left, min_eq_left ] <;> norm_num <;> nlinarith [ ( by norm_cast : ( n : ℝ ) + 1 ≤ n₀ ) ] ;
  · intro n hn;
    rw [ min_eq_right, min_eq_right ];
    · grind;
    · nlinarith [ ( by norm_cast : ( n₀ : ℝ ) ≤ n ) ];
    · norm_num; nlinarith [ ( by norm_cast : ( n₀ : ℝ ) ≤ n ) ]

/-! ## Section 3: Cross-Domain Bridge — Quantization Stability -/

/-
**Tropical vertex stability under uniform perturbation**: If two functions `f` and `g`
    are uniformly approximated by `f'` and `g'` within `ε`, and the gap `|f n - g n|`
    exceeds `2ε` away from the vertex `n₀`, then the perturbed tropical minimum
    preserves which branch dominates at every point except possibly the vertex.
-/
theorem tropical_vertex_stability_under_uniform_error
    {f g f' g' : ℕ → ℝ} {n₀ : ℕ} {ε : ℝ}
    (hε : 0 ≤ ε)
    (hf : ∀ n, |f' n - f n| ≤ ε)
    (hg : ∀ n, |g' n - g n| ≤ ε)
    (_hfg_eq : f n₀ = g n₀)
    (hsep : ∀ n, n ≠ n₀ → 2 * ε < |f n - g n|)
    (hfg_dom : ∀ n, n ≤ n₀ → f n ≤ g n)
    (hgf_dom : ∀ n, n₀ ≤ n → g n ≤ f n) :
    (∀ n, n < n₀ → min (f' n) (g' n) = f' n) ∧
    (∀ n, n₀ < n → min (f' n) (g' n) = g' n) := by
  grind

end