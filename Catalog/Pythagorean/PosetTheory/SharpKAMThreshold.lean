/-
  # Sharp Instability Threshold for Finite-Scale Tropical KAM

  This file establishes a **sharp phase-transition theorem** for finite-scale
  Diophantine resonance avoidance under adversarial perturbations.

  The existing catalog results (`total_perturbation_budget_bound`,
  `certifyMultiScaleKAM_sound`) show that perturbation budget `< C/K` is
  *sufficient* for stability. We prove the matching *instability* direction:
  budget `> C/K` is *universally insufficient*.

  ## Main Results

  1. `dot_le_l1_mul_sup2` — ℓ¹/ℓ∞ duality: |k·x| ≤ ‖k‖₁ · supNorm2(x)
  2. `safety_below_critical_budget_fin2` — Perturbations with supNorm2(δ) < C/K
     preserve (K,C)-Diophantine condition
  3. `exists_resonant_perturbation_above_critical` — For any budget B > C/K,
     there exist ω, δ with ω (K,C)-Diophantine, supNorm2(δ) ≤ B, and k·(ω+δ) = 0
  4. `exact_resonance_at_critical_budget_fin2` — When a mode attains the margin,
     a perturbation of supNorm2(δ) ≤ C/K exactly produces resonance
  5. `perturbation_below_mode_margin_safe_fin2` — Per-mode safety theorem

  ## Cross-Domain Connections

  - **Convex geometry**: The threshold C/K arises from ℓ¹/ℓ∞ norm duality
  - **Adversarial robustness**: The resonance margin is an exact adversarial radius
  - **Critical phenomena**: The budget C/K is a sharp phase transition parameter
-/
import Mathlib

open Finset BigOperators

noncomputable section

namespace SharpKAMThreshold

/-! ## Core Definitions -/

/-- L1 norm of an integer vector: ∑ |k_i|. -/
def l1NormZ {d : ℕ} (k : Fin d → ℤ) : ℕ :=
  ∑ i : Fin d, (k i).natAbs

/-- Lattice inner product: k · ω = ∑ k_i · ω_i. -/
def dot {d : ℕ} (k : Fin d → ℤ) (ω : Fin d → ℝ) : ℝ :=
  ∑ i : Fin d, (k i : ℝ) * ω i

/-- Sup norm for Fin 2 → ℝ. -/
def supNorm2 (x : Fin 2 → ℝ) : ℝ :=
  max (|x 0|) (|x 1|)

/-- Finite-scale Diophantine predicate: every nonzero integer mode k with
    ‖k‖₁ ≤ K satisfies |k·ω| ≥ C. -/
def IsKDiophantine {d : ℕ} (K : ℕ) (C : ℝ) (ω : Fin d → ℝ) : Prop :=
  ∀ k : Fin d → ℤ, k ≠ 0 → l1NormZ k ≤ K →
    C ≤ |dot k ω|

/-- Finite resonance set: frequencies where some nonzero mode with ‖k‖₁ ≤ K
    has k·ω = 0. -/
def finiteResonanceSet {d : ℕ} (K : ℕ) : Set (Fin d → ℝ) :=
  {ω | ∃ k : Fin d → ℤ, k ≠ 0 ∧ l1NormZ k ≤ K ∧ dot k ω = 0}

/-- Critical budget: C / K, the exact universal threshold. -/
def criticalBudget (K : ℕ) (C : ℝ) : ℝ := C / K

/-- A mode attains the Diophantine margin: ‖k₀‖₁ = K and |k₀·ω| = C. -/
def AttainsMargin {d : ℕ} (K : ℕ) (C : ℝ) (ω : Fin d → ℝ) : Prop :=
  ∃ k : Fin d → ℤ, k ≠ 0 ∧ l1NormZ k = K ∧ |dot k ω| = C

/-! ## Computational Lemmas for Fin 2 -/

/-- L1 norm of a Fin 2 → ℤ vector, unfolded. -/
lemma l1NormZ_fin2 (k : Fin 2 → ℤ) :
    l1NormZ k = (k 0).natAbs + (k 1).natAbs := by
  simp [l1NormZ, Fin.sum_univ_two]

/-- Dot product for Fin 2, unfolded. -/
lemma dot_fin2 (k : Fin 2 → ℤ) (ω : Fin 2 → ℝ) :
    dot k ω = (k 0 : ℝ) * ω 0 + (k 1 : ℝ) * ω 1 := by
  simp [dot, Fin.sum_univ_two]

/-- Linearity of dot in the frequency. -/
lemma dot_add {d : ℕ} (k : Fin d → ℤ) (ω δ : Fin d → ℝ) :
    dot k (fun i => ω i + δ i) = dot k ω + dot k δ := by
  simp [dot, mul_add, Finset.sum_add_distrib]

/-! ## ℓ¹/ℓ∞ Duality -/

/-
The fundamental ℓ¹/ℓ∞ duality inequality for Fin 2:
    |k·x| ≤ ‖k‖₁ · supNorm2(x).
-/
theorem dot_le_l1_mul_sup2
    (k : Fin 2 → ℤ) (x : Fin 2 → ℝ) :
    |dot k x| ≤ (l1NormZ k : ℝ) * supNorm2 x := by
  convert abs_add_le ( k 0 * x 0 ) ( k 1 * x 1 ) |> le_trans <| ?_ using 1 ; ring_nf ;
  · exact congr_arg _ ( dot_fin2 k x );
  · norm_num [ abs_mul, l1NormZ_fin2, supNorm2 ];
    nlinarith [ abs_nonneg ( k 0 : ℝ ), abs_nonneg ( k 1 : ℝ ), le_max_left |x 0| |x 1|, le_max_right |x 0| |x 1| ]

/-! ## Per-Mode Safety -/

/-
**Per-mode safety**: If ‖k‖₁ · supNorm2(δ) < |k·ω|,
    then k·(ω+δ) ≠ 0.
-/
theorem perturbation_below_mode_margin_safe_fin2
    {k : Fin 2 → ℤ} (hk : k ≠ 0)
    {ω δ : Fin 2 → ℝ}
    (hbound : (l1NormZ k : ℝ) * supNorm2 δ < |dot k ω|) :
    dot k (fun i => ω i + δ i) ≠ 0 := by
  -- By the triangle inequality and the given bound, we have |dot k δ| < |dot k ω|.
  have h_triangle : |dot k δ| < |dot k ω| := by
    exact lt_of_le_of_lt ( dot_le_l1_mul_sup2 k δ ) hbound;
  rw [ dot_add ];
  cases abs_cases ( dot k ω ) <;> cases abs_cases ( dot k δ ) <;> linarith

/-! ## Safety Below Critical Budget -/

/-
**Safety theorem**: If ω is (K,C)-Diophantine and supNorm2 δ < C/K, then
    ω + δ avoids all resonances up to scale K.
-/
theorem safety_below_critical_budget_fin2
    {K : ℕ} (hK : 0 < K) {C : ℝ} (hC : 0 < C)
    {ω δ : Fin 2 → ℝ}
    (hω : IsKDiophantine (d := 2) K C ω)
    (hδ : supNorm2 δ < C / K) :
    ∀ k : Fin 2 → ℤ, k ≠ 0 → l1NormZ k ≤ K →
      dot k (fun i => ω i + δ i) ≠ 0 := by
  intros k hk_ne_zero hk_le_K;
  -- By the properties of the dot product and the definition of $supNorm2$, we have:
  have h_bound : (l1NormZ k : ℝ) * supNorm2 δ < C := by
    exact lt_of_le_of_lt ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr hk_le_K ) ( by exact le_max_of_le_left ( abs_nonneg _ ) ) ) ( by rwa [ lt_div_iff₀' ( by positivity ) ] at hδ );
  exact perturbation_below_mode_margin_safe_fin2 hk_ne_zero ( lt_of_lt_of_le h_bound ( hω k hk_ne_zero hk_le_K ) )

/-! ## Diophantine Witness Construction -/

/-
The frequency ω = (K·C, -C) is (K,C)-Diophantine in dimension 2.
-/
theorem diophantine_witness (K : ℕ) (hK : 0 < K) (C : ℝ) (hC : 0 < C) :
    IsKDiophantine (d := 2) K C ![↑K * C, -C] := by
  intro k hk_ne_zero hk_le_K
  have h_ineq : |(k 0 : ℝ) * K - (k 1 : ℝ)| ≥ 1 := by
    by_cases h_eq : k 0 * K = k 1;
    · unfold l1NormZ at hk_le_K; contrapose! hk_ne_zero; ext i; fin_cases i <;> simp_all +decide [ sub_eq_iff_eq_add ] ;
      · cases abs_cases ( k 0 ) <;> cases abs_cases ( k 1 ) <;> nlinarith;
      · cases abs_cases ( k 0 ) <;> cases abs_cases ( k 1 ) <;> nlinarith [ show ( k 0 : ℤ ) = 0 by nlinarith ];
    · exact mod_cast abs_pos.mpr ( sub_ne_zero.mpr h_eq );
  convert mul_le_mul_of_nonneg_left h_ineq hC.le using 1 ; norm_num [ dot ] ; ring_nf;
  unfold dot; norm_num [ Fin.sum_univ_two ] ; ring;
  rw [ show ( k 0 : ℝ ) * K * C - C * k 1 = C * ( ( k 0 : ℝ ) * K - k 1 ) by ring, abs_mul, abs_of_pos hC ]

/-
The mode k₀ = (1, K-1) attains the margin for ω = (K·C, -C).
-/
theorem witness_attains_margin (K : ℕ) (hK : 0 < K) (C : ℝ) (hC : 0 < C) :
    AttainsMargin (d := 2) K C ![↑K * C, -C] := by
  use ![1, (K : ℤ) - 1];
  rcases K with ( _ | _ | K ) <;> norm_num [ dot, l1NormZ ] at *;
  · positivity;
  · exact ⟨ by norm_cast; ring, by rw [ abs_of_nonneg ] <;> linarith ⟩

/-! ## Hyperplane Distance — Sign Perturbation Lemma -/

/-
Core construction: for any nonzero k in Fin 2 → ℤ with positive l1 norm,
    there exists δ with supNorm2 ≤ |dot k ω| / ‖k‖₁ achieving dot k (ω + δ) = 0.
    Uses the sign-perturbation: δ_i = -(dot k ω / ‖k‖₁) · sign(k_i).
-/
theorem hyperplane_linfty_distance_achieved_fin2
    {k : Fin 2 → ℤ} (hk : k ≠ 0) (hkl : 0 < l1NormZ k)
    (ω : Fin 2 → ℝ) :
    ∃ δ : Fin 2 → ℝ,
      supNorm2 δ ≤ |dot k ω| / (l1NormZ k : ℝ) ∧
      dot k (fun i => ω i + δ i) = 0 := by
  refine' ⟨ fun i => - ( dot k ω / ( l1NormZ k : ℝ ) ) * ( ( k i : ℝ ) / ( |( k i : ℝ )| ) ), _, _ ⟩;
  · refine' max_le_iff.mpr ⟨ _, _ ⟩ <;> norm_num;
    · by_cases h : k 0 = 0 <;> simp_all +decide [ abs_div, abs_mul, div_le_iff₀ ];
      positivity;
    · norm_num [ abs_div, abs_mul, abs_of_nonneg, hkl.le ];
      by_cases h : k 1 = 0 <;> simp_all +decide;
      positivity;
  · -- We'll use the fact that $\sum_{i=0}^{1} k_i \cdot \frac{k_i}{|k_i|} = \sum_{i=0}^{1} |k_i| = l1NormZ k$.
    have h_sum : ∑ i : Fin 2, (k i : ℝ) * (k i / |(k i : ℝ)|) = (l1NormZ k : ℝ) := by
      simp +decide [ l1NormZ, Finset.sum_div _ _ _, mul_div ];
      grind;
    simp_all +decide [ dot, mul_add, Finset.sum_add_distrib, mul_assoc, mul_left_comm ];
    grind

/-! ## Universal Sharpness of C/K -/

/-
**Flagship sharpness theorem**: For any budget B > C/K, there exist
    a (K,C)-Diophantine frequency ω and a perturbation δ with supNorm2(δ) ≤ B
    that creates a resonance.
-/
theorem exists_resonant_perturbation_above_critical
    {K : ℕ} (hK : 0 < K) {C B : ℝ}
    (hC : 0 < C) (hB : C / K < B) :
    ∃ ω δ : Fin 2 → ℝ,
      IsKDiophantine (d := 2) K C ω ∧
      supNorm2 δ ≤ B ∧
      ∃ k : Fin 2 → ℤ,
        k ≠ 0 ∧ l1NormZ k ≤ K ∧
        dot k (fun i => ω i + δ i) = 0 := by
  obtain ⟨ω, hω⟩ : ∃ ω : Fin 2 → ℝ, IsKDiophantine K C ω ∧ ∃ k : Fin 2 → ℤ, k ≠ 0 ∧ l1NormZ k = K ∧ |dot k ω| = C := by
    exact ⟨ _, diophantine_witness K hK C hC, _, witness_attains_margin K hK C hC |> Classical.choose_spec |> And.left, witness_attains_margin K hK C hC |> Classical.choose_spec |> And.right |> And.left, witness_attains_margin K hK C hC |> Classical.choose_spec |> And.right |> And.right ⟩;
  obtain ⟨ k, hk₁, hk₂, hk₃ ⟩ := hω.2;
  obtain ⟨δ, hδ₁, hδ₂⟩ : ∃ δ : Fin 2 → ℝ, supNorm2 δ ≤ C / K ∧ dot k (fun i => ω i + δ i) = 0 := by
    have := hyperplane_linfty_distance_achieved_fin2 hk₁ (by
    linarith) ω;
    aesop;
  exact ⟨ ω, δ, hω.1, le_trans hδ₁ hB.le, k, hk₁, hk₂.le, hδ₂ ⟩

/-! ## Exact Attainment at Threshold -/

/-
**Exact attainment theorem**: If a mode k₀ with ‖k₀‖₁ = K attains
    the Diophantine margin, then there exists a perturbation δ with
    supNorm2 δ ≤ C/K that forces exact resonance.
-/
theorem exact_resonance_at_critical_budget_fin2
    {K : ℕ} (hK : 0 < K) {C : ℝ} (hC : 0 ≤ C)
    {ω : Fin 2 → ℝ}
    (hattain : AttainsMargin (d := 2) K C ω) :
    ∃ δ : Fin 2 → ℝ,
      supNorm2 δ ≤ C / K ∧
      ∃ k : Fin 2 → ℤ,
        k ≠ 0 ∧ l1NormZ k = K ∧
        dot k (fun i => ω i + δ i) = 0 := by
  rcases hattain with ⟨ k, hk₁, hk₂, hk₃ ⟩;
  -- Use the hyperplane_linfty_distance_achieved_fin2 lemma to get the δ.
  obtain ⟨δ, hδ_norm, hδ_res⟩ : ∃ δ : Fin 2 → ℝ, supNorm2 δ ≤ |dot k ω| / (l1NormZ k : ℝ) ∧ dot k (fun i => ω i + δ i) = 0 := by
    convert hyperplane_linfty_distance_achieved_fin2 _ _ _ using 1;
    · assumption;
    · linarith;
  exact ⟨ δ, by aesop, k, hk₁, hk₂, hδ_res ⟩

end SharpKAMThreshold

end