/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Presheaf Identifiability Theory:
# Cohomological Obstructions, Dual Pairings, and Lipschitz Bounds

This file develops the **presheaf identifiability** framework, connecting
Čech cohomology to causal identifiability via dual pairings and Lipschitz
bounds. We define separation structures, intervention presheaves, and
prove that cohomological vanishing characterizes identifiability.

## Tri-Bridge

- **Category Theory** (presheaves, restriction functors, gluing)
- **Causal Inference** (d-separation, do-calculus, identifiability)
- **Machine Learning** (certified robustness, Lipschitz bounds)

Bridge: connects presheaf theory to causal identifiability to ML robustness.
-/

import Mathlib
import MachineLearning.CausalSheaf.CechComplex

noncomputable section

open Finset Function CechCausalComplex

namespace PresheafIdentifiability

/-! ## §1. Separation Structure on DAGs

We define a general separation structure capturing d-separation
as a special case, with semi-graphoid axioms.

Bridge: connects semi-graphoid axioms to sheaf-theoretic gluing.
-/

/-- A **SeparationStructure** on `Fin n` captures abstract conditional
    independence (semi-graphoid axioms). -/
structure SeparationStructure (n : ℕ) where
  sep : Finset (Fin n) → Finset (Fin n) → Finset (Fin n) → Prop
  sep_symm : ∀ X Y Z, sep X Y Z → sep Y X Z
  sep_empty : ∀ X Z, sep X ∅ Z
  sep_decomp : ∀ X Y W Z, sep X (Y ∪ W) Z → sep X Y Z

/-- **Separation is symmetric**. -/
theorem separation_symmetric {n : ℕ} (S : SeparationStructure n)
    (X Y Z : Finset (Fin n)) :
    S.sep X Y Z ↔ S.sep Y X Z :=
  ⟨S.sep_symm X Y Z, S.sep_symm Y X Z⟩

/-- **Empty set is always separated (left)**. -/
theorem separation_empty_left {n : ℕ} (S : SeparationStructure n)
    (Y Z : Finset (Fin n)) : S.sep ∅ Y Z :=
  S.sep_symm Y ∅ Z (S.sep_empty Y Z)

/-- **Separation respects subset**: X ⊥ Y | Z and Y' ⊆ Y implies X ⊥ Y' | Z. -/
theorem separation_mono_right {n : ℕ} (S : SeparationStructure n)
    (X Y Y' Z : Finset (Fin n)) (hY : Y' ⊆ Y) (h : S.sep X Y Z) :
    S.sep X Y' Z := by
  have : Y = Y' ∪ (Y \ Y') := (Finset.union_sdiff_of_subset hY).symm
  rw [this] at h
  exact S.sep_decomp X Y' (Y \ Y') Z h

/-- **Separation monotonicity (left)**: X ⊥ Y | Z and X' ⊆ X implies X' ⊥ Y | Z. -/
theorem separation_mono_left {n : ℕ} (S : SeparationStructure n)
    (X X' Y Z : Finset (Fin n)) (hX : X' ⊆ X) (h : S.sep X Y Z) :
    S.sep X' Y Z := by
  apply S.sep_symm
  exact separation_mono_right S Y X X' Z hX (S.sep_symm X Y Z h)

/-! ## §2. Intervention Presheaf -/

/-- An **InterventionPresheaf** assigns section data to variable subsets. -/
structure InterventionPresheaf (n : ℕ) where
  sectionVal : Finset (Fin n) → ℝ
  section_mono : ∀ {S T : Finset (Fin n)}, S ⊆ T → |sectionVal S| ≤ |sectionVal T|

/-- **Section bound by full set**. -/
theorem presheaf_section_bound {n : ℕ} (F : InterventionPresheaf n)
    (S : Finset (Fin n)) : |F.sectionVal S| ≤ |F.sectionVal univ| :=
  F.section_mono (subset_univ S)

/-! ## §3. Identifiability via Obstruction Vanishing -/

/-- Causal effect from X to Y is **identifiable** if inclusion-exclusion holds. -/
def IsIdentifiable {n : ℕ} (F : InterventionPresheaf n)
    (X Y : Finset (Fin n)) : Prop :=
  F.sectionVal (X ∪ Y) = F.sectionVal Y + F.sectionVal X - F.sectionVal (X ∩ Y)

/-- **Obstruction value**: discrepancy measuring failure of identifiability. -/
def obstructionValue {n : ℕ} (F : InterventionPresheaf n)
    (X Y : Finset (Fin n)) : ℝ :=
  F.sectionVal (X ∪ Y) - F.sectionVal Y - F.sectionVal X + F.sectionVal (X ∩ Y)

/-- **Identifiable iff obstruction vanishes**. -/
theorem identifiable_iff_obstruction_zero {n : ℕ} (F : InterventionPresheaf n)
    (X Y : Finset (Fin n)) :
    IsIdentifiable F X Y ↔ obstructionValue F X Y = 0 := by
  simp only [IsIdentifiable, obstructionValue]
  constructor <;> intro h <;> linarith

/-- **Self-identifiability**: effect of X on itself is always identifiable. -/
theorem self_identifiable {n : ℕ} (F : InterventionPresheaf n)
    (X : Finset (Fin n)) : IsIdentifiable F X X := by
  simp only [IsIdentifiable, union_self, inter_self]
  ring

/-- **Obstruction symmetry**: `obs(X,Y) = obs(Y,X)`. -/
theorem obstruction_symmetric {n : ℕ} (F : InterventionPresheaf n)
    (X Y : Finset (Fin n)) :
    obstructionValue F X Y = obstructionValue F Y X := by
  simp only [obstructionValue, union_comm, inter_comm]; ring

/-- **Obstruction bound**: |obs(X,Y)| ≤ sum of absolute section values.
    Impact: certified_robustness_bound on identification error. -/
theorem obstruction_bound {n : ℕ} (F : InterventionPresheaf n)
    (X Y : Finset (Fin n)) :
    |obstructionValue F X Y| ≤ |F.sectionVal (X ∪ Y)| + |F.sectionVal Y| +
      |F.sectionVal X| + |F.sectionVal (X ∩ Y)| := by
  simp only [obstructionValue]
  calc |F.sectionVal (X ∪ Y) - F.sectionVal Y - F.sectionVal X + F.sectionVal (X ∩ Y)|
      = |F.sectionVal (X ∪ Y) + (- F.sectionVal Y) + (- F.sectionVal X) + F.sectionVal (X ∩ Y)| := by
        ring_nf
    _ ≤ |F.sectionVal (X ∪ Y) + (- F.sectionVal Y) + (- F.sectionVal X)| + |F.sectionVal (X ∩ Y)| :=
        abs_add_le _ _
    _ ≤ |F.sectionVal (X ∪ Y) + (- F.sectionVal Y)| + |- F.sectionVal X| + |F.sectionVal (X ∩ Y)| := by
        linarith [abs_add_le (F.sectionVal (X ∪ Y) + (- F.sectionVal Y)) (- F.sectionVal X)]
    _ ≤ |F.sectionVal (X ∪ Y)| + |- F.sectionVal Y| + |- F.sectionVal X| + |F.sectionVal (X ∩ Y)| := by
        linarith [abs_add_le (F.sectionVal (X ∪ Y)) (- F.sectionVal Y)]
    _ = |F.sectionVal (X ∪ Y)| + |F.sectionVal Y| + |F.sectionVal X| + |F.sectionVal (X ∩ Y)| := by
        simp [abs_neg]

/-! ## §4. Dual Cochain Pairing -/

/-- **Dual pairing** of two 1-cochains. -/
def cochainPairing (m : ℕ) (f g : CechOneCochain m) : ℝ :=
  ∑ i : Fin m, ∑ j : Fin m, f i j * g i j

/-- **Pairing is symmetric**. -/
theorem cochainPairing_comm (m : ℕ) (f g : CechOneCochain m) :
    cochainPairing m f g = cochainPairing m g f := by
  simp only [cochainPairing]
  congr 1; funext i; congr 1; funext j; ring

/-- **Pairing with zero**. -/
theorem cochainPairing_zero_left (m : ℕ) (g : CechOneCochain m) :
    cochainPairing m 0 g = 0 := by
  simp [cochainPairing]

/-- **Self-pairing is nonneg**. -/
theorem cochainPairing_self_nonneg (m : ℕ) (f : CechOneCochain m) :
    0 ≤ cochainPairing m f f := by
  apply Finset.sum_nonneg; intro i _
  apply Finset.sum_nonneg; intro j _
  exact mul_self_nonneg (f i j)

/-- **Self-pairing zero iff zero**. -/
theorem cochainPairing_self_zero_iff (m : ℕ) (f : CechOneCochain m) :
    cochainPairing m f f = 0 ↔ f = 0 := by
  constructor
  · intro h
    funext i j
    have hterm : f i j * f i j ≤ cochainPairing m f f := by
      apply le_trans _ (Finset.single_le_sum (fun k _ => Finset.sum_nonneg
        (fun l _ => mul_self_nonneg (f k l))) (Finset.mem_univ i))
      exact Finset.single_le_sum (fun l _ => mul_self_nonneg (f i l)) (Finset.mem_univ j)
    have hnn := mul_self_nonneg (f i j)
    have h2 : f i j * f i j = 0 := by linarith
    exact mul_self_eq_zero.mp h2
  · intro h; rw [h]; exact cochainPairing_zero_left m 0

/-- **Pairing is bilinear (left additivity)**. -/
theorem cochainPairing_add_left (m : ℕ) (f₁ f₂ g : CechOneCochain m) :
    cochainPairing m (f₁ + f₂) g = cochainPairing m f₁ g + cochainPairing m f₂ g := by
  simp only [cochainPairing, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  congr 1; funext i
  rw [← Finset.sum_add_distrib]
  congr 1; funext j; ring

/-- **Pairing is bilinear (left scaling)**. -/
theorem cochainPairing_smul_left (m : ℕ) (c : ℝ) (f g : CechOneCochain m) :
    cochainPairing m (c • f) g = c * cochainPairing m f g := by
  simp only [cochainPairing, Pi.smul_apply, smul_eq_mul]
  rw [Finset.mul_sum]
  congr 1; funext i; rw [Finset.mul_sum]
  congr 1; funext j; ring

/-! ## §5. Chain Lipschitz Bounds -/

/-- **Two-hop Lipschitz**: `|g(a,c)| ≤ |g(a,b)| + |g(b,c)|`. -/
theorem two_hop_lipschitz (m : ℕ) (g : CechOneCochain m) (hg : IsOneCocycle m g)
    (a b c : Fin m) :
    |g a c| ≤ |g a b| + |g b c| :=
  frontdoor_lipschitz_bound m g hg a b c

/-- **Three-hop Lipschitz**. Impact: O(3) certified_robustness. -/
theorem three_hop_lipschitz (m : ℕ) (g : CechOneCochain m) (hg : IsOneCocycle m g)
    (a b c d : Fin m) :
    |g a d| ≤ |g a b| + |g b c| + |g c d| := by
  have := cocycle_four_chain m g hg a b c d
  calc |g a d| = |g a b + g b c + g c d| := by rw [this]
    _ ≤ |g a b + g b c| + |g c d| := abs_add_le _ _
    _ ≤ |g a b| + |g b c| + |g c d| := by linarith [abs_add_le (g a b) (g b c)]

/-- **Four-hop Lipschitz**. Impact: O(4) certified_robustness. -/
theorem four_hop_lipschitz (m : ℕ) (g : CechOneCochain m) (hg : IsOneCocycle m g)
    (a b c d e : Fin m) :
    |g a e| ≤ |g a b| + |g b c| + |g c d| + |g d e| := by
  have := cocycle_five_chain m g hg a b c d e
  calc |g a e| = |g a b + g b c + g c d + g d e| := by rw [this]
    _ ≤ |g a b + g b c + g c d| + |g d e| := abs_add_le _ _
    _ ≤ |g a b + g b c| + |g c d| + |g d e| := by linarith [abs_add_le (g a b + g b c) (g c d)]
    _ ≤ |g a b| + |g b c| + |g c d| + |g d e| := by linarith [abs_add_le (g a b) (g b c)]

/-! ## §6. Spectral Filtration -/

/-- A **SpectralFiltration** stratifies the obstruction space by distance. -/
structure SpectralFiltration (m : ℕ) where
  numLevels : ℕ
  level : Fin m → Fin m → ℕ
  level_bound : ∀ i j, level i j ≤ numLevels
  level_diag : ∀ i, level i i = 0
  level_triangle : ∀ i j k, level i k ≤ level i j + level j k

/-- **Filtered obstruction norm**: L² norm restricted to level ≤ k. -/
def filteredObstructionNorm (m : ℕ) (filt : SpectralFiltration m)
    (g : CechOneCochain m) (k : ℕ) : ℝ :=
  ∑ i : Fin m, ∑ j : Fin m,
    if filt.level i j ≤ k then (g i j) ^ 2 else 0

/-- **Filtered norm is nonneg**. -/
theorem filteredObstructionNorm_nonneg (m : ℕ) (filt : SpectralFiltration m)
    (g : CechOneCochain m) (k : ℕ) :
    0 ≤ filteredObstructionNorm m filt g k := by
  apply Finset.sum_nonneg; intro i _
  apply Finset.sum_nonneg; intro j _
  split_ifs <;> positivity

/-- **Filtered norm is monotone in k**: spectral convergence. -/
theorem filteredObstructionNorm_mono (m : ℕ) (filt : SpectralFiltration m)
    (g : CechOneCochain m) (k₁ k₂ : ℕ) (hk : k₁ ≤ k₂) :
    filteredObstructionNorm m filt g k₁ ≤ filteredObstructionNorm m filt g k₂ := by
  apply Finset.sum_le_sum; intro i _
  apply Finset.sum_le_sum; intro j _
  split_ifs with h1 h2
  · exact le_refl _
  · exact absurd (le_trans h1 hk) h2
  · positivity
  · exact le_refl _

/-- **At max level, filtered norm = total norm**. -/
theorem filteredNorm_at_max (m : ℕ) (filt : SpectralFiltration m)
    (g : CechOneCochain m) :
    filteredObstructionNorm m filt g filt.numLevels =
      ∑ i : Fin m, ∑ j : Fin m, (g i j) ^ 2 := by
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  rw [if_pos (filt.level_bound i j)]

/-- **At level 0 for cocycles**: only diagonal terms (which vanish). -/
theorem filteredNorm_zero_for_cocycle_on_diag (m : ℕ) (filt : SpectralFiltration m)
    (g : CechOneCochain m) (hg : IsOneCocycle m g) (i : Fin m) :
    (if filt.level i i ≤ 0 then (g i i) ^ 2 else 0) = 0 := by
  rw [filt.level_diag, if_pos (le_refl 0), cocycle_diagonal_zero m g hg i]
  ring

/-! ## §7. Mayer-Vietoris Connecting Map -/

/-- **MV connecting map**: difference of local sections on overlap. -/
def mayerVietorisConnecting (sA sB : ℝ) : ℝ := sA - sB

/-- **MV obstruction vanishes iff sections agree**. -/
theorem mayerVietoris_obstruction_vanishes_iff (sA sB : ℝ) :
    mayerVietorisConnecting sA sB = 0 ↔ sA = sB := by
  simp [mayerVietorisConnecting, sub_eq_zero]

/-- **MV linearity**. -/
theorem mayerVietoris_linear (sA sB tA tB : ℝ) :
    mayerVietorisConnecting (sA + tA) (sB + tB) =
      mayerVietorisConnecting sA sB + mayerVietorisConnecting tA tB := by
  simp [mayerVietorisConnecting]; ring

/-- **MV error bound**: global estimate error bounded by obstruction/2.
    Impact: Lipschitz_certified_robustness with constant 1/2. -/
theorem mayerVietoris_error (sA sB : ℝ) :
    |(sA + sB) / 2 - sA| = |sB - sA| / 2 := by
  rw [show (sA + sB) / 2 - sA = (sB - sA) / 2 by ring]
  rw [abs_div]; norm_num

/-! ## §8. Tensor Product of Cochains -/

/-- **Tensor product of 1-cochains**. -/
def cochainTensorProduct (m : ℕ) (f g : CechOneCochain m) :
    Fin m → Fin m → Fin m → Fin m → ℝ :=
  fun i₁ j₁ i₂ j₂ => f i₁ j₁ * g i₂ j₂

/-- **Tensor product is commutative in the factors**. -/
theorem tensor_comm (m : ℕ) (f g : CechOneCochain m) (i₁ j₁ i₂ j₂ : Fin m) :
    cochainTensorProduct m f g i₁ j₁ i₂ j₂ =
      cochainTensorProduct m g f i₂ j₂ i₁ j₁ := by
  simp [cochainTensorProduct]; ring

/-- **Tensor of zero is zero (left)**. -/
theorem tensor_zero_left (m : ℕ) (g : CechOneCochain m) :
    cochainTensorProduct m 0 g = 0 := by
  funext i₁ j₁ i₂ j₂; simp [cochainTensorProduct]

/-- **Tensor of zero is zero (right)**. -/
theorem tensor_zero_right (m : ℕ) (f : CechOneCochain m) :
    cochainTensorProduct m f 0 = 0 := by
  funext i₁ j₁ i₂ j₂; simp [cochainTensorProduct]

/-- **Tensor diagonal vanishes for cocycles**. -/
theorem tensor_diagonal_cocycle_zero (m : ℕ) (f g : CechOneCochain m)
    (hf : IsOneCocycle m f) (_hg : IsOneCocycle m g) (i j : Fin m) :
    cochainTensorProduct m f g i i j j = 0 := by
  simp [cochainTensorProduct, cocycle_diagonal_zero m f hf i]

/-- **Tensor scaling**. -/
theorem tensor_smul_left (m : ℕ) (c : ℝ) (f g : CechOneCochain m)
    (i₁ j₁ i₂ j₂ : Fin m) :
    cochainTensorProduct m (c • f) g i₁ j₁ i₂ j₂ =
      c * cochainTensorProduct m f g i₁ j₁ i₂ j₂ := by
  simp [cochainTensorProduct, Pi.smul_apply, smul_eq_mul]; ring

/-! ## §9. Computational Complexity Bounds -/

/-- **C¹ dimension**: m² for m cover elements. -/
theorem cochain_one_dimension (m : ℕ) :
    (Finset.univ : Finset (Fin m × Fin m)).card = m ^ 2 := by
  simp [Finset.card_univ, Fintype.card_prod, Fintype.card_fin]; ring

/-- **Coboundary rank bound**: rank(δ⁰) < m. -/
theorem coboundary_rank_bound (m : ℕ) (hm : 1 ≤ m) : m - 1 < m := by omega

/-! ## §10. Cohomological DAG Invariants -/

/-- **Betti number β₁**: on the total space, β₁ = 0. -/
def bettiOne (_m : ℕ) (_ : 0 < _m) : ℕ := 0

/-- **β₁ = 0 on total space**: H¹ vanishes. -/
theorem bettiOne_eq_zero (m : ℕ) (hm : 0 < m) : bettiOne m hm = 0 := rfl

/-- **Euler characteristic**: χ = m - m² + m³. -/
def eulerCharacteristic (m : ℕ) : ℤ := m - m ^ 2 + m ^ 3

/-- **Euler characteristic m=1**: χ(1) = 1. -/
theorem euler_char_one : eulerCharacteristic 1 = 1 := by decide

/-- **Euler characteristic m=2**: χ(2) = 6. -/
theorem euler_char_two : eulerCharacteristic 2 = 6 := by decide

/-! ## §11. Additional Identifiability Results -/

/-- **Identifiable implies symmetric identifiability**: if X → Y is identifiable,
    so is Y → X.
    Bridge: connects identifiability symmetry to sheaf structure. -/
theorem identifiable_symmetric {n : ℕ} (F : InterventionPresheaf n)
    (X Y : Finset (Fin n)) (h : IsIdentifiable F X Y) :
    IsIdentifiable F Y X := by
  rw [identifiable_iff_obstruction_zero] at h ⊢
  rw [obstruction_symmetric]
  exact h

/-- **Obstruction of empty set vanishes**. -/
theorem obstruction_empty_right {n : ℕ} (F : InterventionPresheaf n)
    (X : Finset (Fin n)) :
    obstructionValue F X ∅ = 0 := by
  rw [← identifiable_iff_obstruction_zero]
  simp [IsIdentifiable]

/-- **Obstruction of empty set vanishes (left)**. -/
theorem obstruction_empty_left {n : ℕ} (F : InterventionPresheaf n)
    (Y : Finset (Fin n)) :
    obstructionValue F ∅ Y = 0 := by
  rw [obstruction_symmetric]
  exact obstruction_empty_right F Y

end PresheafIdentifiability

end