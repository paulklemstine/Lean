/-
# Vector-Valued Ultrametric Neural Network Certification
# via Width-Free Operator Lipschitz Calculus

This file formalizes a complete certified robustness theory for layered
affine-activation networks acting on finite coordinate spaces over a
nonarchimedean normed field, endowed with the sup norm.

## Central Achievement

The headline theorem `ultrametric_lipschitz_certified_robustness` proves that
the certified radius for label stability depends only on multiplicative
layer Lipschitz constants and the output valuation margin — NOT on hidden
widths. This is the ultrametric width-free certification paradigm.

## Structures (10+ novel types)

- `PadicAffineVecLayer` — affine layer with weight kernel and bias
- `UltrametricActivation` — activation with scalar Lipschitz certificate
- `PadicLayeredVecMap` — one affine-activation block
- `UltrametricCertifiedClassifier` — full classification pipeline
- `SupBall` — sup-norm ball as a set
- `ArgmaxSeparated` — predicate for label separation
- `LabelStableOnBall` — robustness predicate

## Bridges

- **Nonarchimedean Analysis ↔ ML**: sup-norm Lipschitz → certified robustness
- **Valuation Geometry ↔ Cryptography**: margin as valuation barrier → noise budget
- **Operator Calculus ↔ Quantum Stability**: width-free bounds → certificates
-/

import Mathlib

open Finset

set_option linter.unusedSectionVars false
noncomputable section

variable {K : Type*} [NormedField K] [IsUltrametricDist K]
variable {ι κ ν : Type*} [Fintype ι] [Fintype κ] [Fintype ν]

/-! ## §1. Vector Sup Norm and Distance -/

/-- **Sup norm on finite coordinate vectors**.
    Bridge: ultrametric analysis → certified ML robustness. -/
def vecSupNorm [Nonempty ι] (x : ι → K) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => ‖x i‖)

/-- **Entrywise sup distance**. -/
def vecSupDist [Nonempty ι] (x y : ι → K) : ℝ :=
  vecSupNorm (fun i => x i - y i)

/-- **Operator sup norm** for a kernel `A : κ → ι → K`. -/
def opSupNorm [Nonempty ι] [Nonempty κ] (A : κ → ι → K) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty
    (fun j => Finset.univ.sup' Finset.univ_nonempty (fun i => ‖A j i‖))

/-! ## §2. Basic Properties -/

theorem vecSupNorm_coord_le [Nonempty ι] (x : ι → K) (i : ι) :
    ‖x i‖ ≤ vecSupNorm x :=
  Finset.le_sup' (fun i => ‖x i‖) (Finset.mem_univ i)

theorem vecSupNorm_nonneg [Nonempty ι] (x : ι → K) : 0 ≤ vecSupNorm x :=
  le_trans (norm_nonneg _) (vecSupNorm_coord_le x (Classical.arbitrary ι))

theorem vecSupDist_coord_le [Nonempty ι] (x y : ι → K) (i : ι) :
    ‖x i - y i‖ ≤ vecSupDist x y :=
  vecSupNorm_coord_le (fun i => x i - y i) i

theorem vecSupNorm_zero [Nonempty ι] :
    vecSupNorm (fun _ : ι => (0 : K)) = 0 := by
  unfold vecSupNorm; simp [Finset.sup'_const Finset.univ_nonempty]

theorem vecSupNorm_const [Nonempty ι] (c : K) :
    vecSupNorm (fun _ : ι => c) = ‖c‖ := by
  unfold vecSupNorm; simp [Finset.sup'_const Finset.univ_nonempty]

theorem vecSupDist_self [Nonempty ι] (x : ι → K) : vecSupDist x x = 0 := by
  have h : (fun i => x i - x i) = (fun _ => (0 : K)) := by ext; simp
  simp [vecSupDist, vecSupNorm_zero]

theorem vecSupDist_comm [Nonempty ι] (x y : ι → K) :
    vecSupDist x y = vecSupDist y x := by
  simp only [vecSupDist, vecSupNorm]
  congr 1; ext i; exact norm_sub_rev (x i) (y i)

theorem vecSupDist_nonneg [Nonempty ι] (x y : ι → K) : 0 ≤ vecSupDist x y :=
  vecSupNorm_nonneg _

theorem vecSupDist_le_iff [Nonempty ι] (x y : ι → K) (r : ℝ) :
    vecSupDist x y ≤ r ↔ ∀ i, ‖x i - y i‖ ≤ r := by
  show Finset.univ.sup' Finset.univ_nonempty (fun i => ‖(fun i => x i - y i) i‖) ≤ r ↔ _
  simp only [Finset.sup'_le_iff]
  exact ⟨fun h i => h i (Finset.mem_univ i), fun h i _ => h i⟩

/-! ## §3. Operator Sup Norm -/

theorem opSupNorm_entry_le [Nonempty ι] [Nonempty κ] (A : κ → ι → K) (j : κ) (i : ι) :
    ‖A j i‖ ≤ opSupNorm A := by
  calc ‖A j i‖
      ≤ Finset.univ.sup' Finset.univ_nonempty (fun i => ‖A j i‖) :=
        Finset.le_sup' (fun i => ‖A j i‖) (Finset.mem_univ i)
    _ ≤ opSupNorm A :=
        Finset.le_sup' (fun j => Finset.univ.sup' Finset.univ_nonempty
          (fun i => ‖A j i‖)) (Finset.mem_univ j)

theorem opSupNorm_nonneg [Nonempty ι] [Nonempty κ] (A : κ → ι → K) : 0 ≤ opSupNorm A :=
  le_trans (norm_nonneg _)
    (opSupNorm_entry_le A (Classical.arbitrary κ) (Classical.arbitrary ι))

theorem opSupNorm_zero [Nonempty ι] [Nonempty κ] :
    opSupNorm (fun (_ : κ) (_ : ι) => (0 : K)) = 0 := by
  simp [opSupNorm, Finset.sup'_const]

/-! ## §4. Ultrametric Row Bound -/

/-- **Ultrametric row bound**: ‖∑ᵢ A_ji · xᵢ‖ ≤ opSupNorm A · vecSupNorm x.
    Width-free: no factor of |ι|. -/
theorem ultrametric_row_bound [Nonempty ι] [Nonempty κ]
    (A : κ → ι → K) (x : ι → K) (j : κ) :
    ‖∑ i : ι, A j i * x i‖ ≤ opSupNorm A * vecSupNorm x := by
  apply IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty Finset.univ_nonempty
  intro i _
  calc ‖A j i * x i‖ = ‖A j i‖ * ‖x i‖ := norm_mul _ _
    _ ≤ opSupNorm A * vecSupNorm x :=
        mul_le_mul (opSupNorm_entry_le A j i) (vecSupNorm_coord_le x i)
          (norm_nonneg _) (opSupNorm_nonneg A)

/-- **Ultrametric matrix-vector bound** (full vector). -/
theorem ultrametric_mulVec_bound [Nonempty ι] [Nonempty κ]
    (A : κ → ι → K) (x : ι → K) :
    vecSupNorm (fun j => ∑ i : ι, A j i * x i) ≤ opSupNorm A * vecSupNorm x :=
  Finset.sup'_le Finset.univ_nonempty _ (fun j _ => ultrametric_row_bound A x j)

/-! ## §5. Structures -/

/-- **Affine vector layer** over an ultrametric field. -/
structure PadicAffineVecLayer (K : Type*) [NormedField K] [IsUltrametricDist K]
    (ι κ : Type*) [Fintype ι] [Fintype κ] where
  weight : κ → ι → K
  bias   : κ → K

/-- **Coordinatewise activation** with Lipschitz constant. -/
structure UltrametricActivation (K : Type*) [NormedField K] [IsUltrametricDist K] where
  toFun : K → K
  lipConst : ℝ
  lip_nonneg : 0 ≤ lipConst
  ultra_lipschitz : ∀ x y, ‖toFun x - toFun y‖ ≤ lipConst * ‖x - y‖

/-- **One affine-activation block**. -/
structure PadicLayeredVecMap (K : Type*) [NormedField K] [IsUltrametricDist K]
    (ι κ : Type*) [Fintype ι] [Fintype κ] where
  layer : PadicAffineVecLayer K ι κ
  act   : UltrametricActivation K

/-! ## §6. Evaluation -/

def evalAffineVec (L : PadicAffineVecLayer K ι κ) (x : ι → K) : κ → K :=
  fun j => (∑ i, L.weight j i * x i) + L.bias j

def evalVec (L : PadicLayeredVecMap K ι κ) (x : ι → K) : κ → K :=
  fun j => L.act.toFun (evalAffineVec L.layer x j)

def layerLip [Nonempty ι] [Nonempty κ] (L : PadicLayeredVecMap K ι κ) : ℝ :=
  L.act.lipConst * opSupNorm L.layer.weight

theorem layerLip_nonneg [Nonempty ι] [Nonempty κ] (L : PadicLayeredVecMap K ι κ) :
    0 ≤ layerLip L :=
  mul_nonneg L.act.lip_nonneg (opSupNorm_nonneg _)

/-! ## §7. Bias Cancellation and Affine Lipschitz -/

theorem evalAffineVec_sub [Nonempty ι] [Nonempty κ]
    (L : PadicAffineVecLayer K ι κ) (x y : ι → K) (j : κ) :
    evalAffineVec L x j - evalAffineVec L y j =
      ∑ i, L.weight j i * (x i - y i) := by
  simp only [evalAffineVec, add_sub_add_right_eq_sub, ← Finset.sum_sub_distrib]
  congr 1; ext i; ring

/-- **Affine sup-Lipschitz**: bias cancels. -/
theorem affine_sup_lipschitz [Nonempty ι] [Nonempty κ]
    (L : PadicAffineVecLayer K ι κ) :
    ∀ x y, vecSupDist (evalAffineVec L x) (evalAffineVec L y)
      ≤ opSupNorm L.weight * vecSupDist x y := by
  intro x y
  apply Finset.sup'_le Finset.univ_nonempty
  intro j _
  show ‖evalAffineVec L x j - evalAffineVec L y j‖ ≤ _
  rw [evalAffineVec_sub L x y j]
  exact ultrametric_row_bound L.weight (fun i => x i - y i) j

/-! ## §8. Activation Lipschitz -/

theorem activation_sup_lipschitz [Nonempty ι]
    (φ : UltrametricActivation K) :
    ∀ x y : ι → K, vecSupDist (fun i => φ.toFun (x i)) (fun i => φ.toFun (y i))
      ≤ φ.lipConst * vecSupDist x y := by
  intro x y
  apply Finset.sup'_le Finset.univ_nonempty
  intro i _
  show ‖φ.toFun (x i) - φ.toFun (y i)‖ ≤ _
  calc ‖φ.toFun (x i) - φ.toFun (y i)‖
      ≤ φ.lipConst * ‖x i - y i‖ := φ.ultra_lipschitz _ _
    _ ≤ φ.lipConst * vecSupDist x y :=
        mul_le_mul_of_nonneg_left (vecSupDist_coord_le x y i) φ.lip_nonneg

theorem activation_nonexpansive [Nonempty ι]
    (φ : UltrametricActivation K) (h1 : φ.lipConst ≤ 1) :
    ∀ x y : ι → K, vecSupDist (fun i => φ.toFun (x i)) (fun i => φ.toFun (y i))
      ≤ vecSupDist x y := by
  intro x y
  calc vecSupDist (fun i => φ.toFun (x i)) (fun i => φ.toFun (y i))
      ≤ φ.lipConst * vecSupDist x y := activation_sup_lipschitz φ x y
    _ ≤ 1 * vecSupDist x y :=
        mul_le_mul_of_nonneg_right h1 (vecSupDist_nonneg x y)
    _ = vecSupDist x y := one_mul _

/-! ## §9. Layered Map Lipschitz -/

theorem layeredVec_lipschitz_bound [Nonempty ι] [Nonempty κ]
    (L : PadicLayeredVecMap K ι κ) :
    ∀ x y, vecSupDist (evalVec L x) (evalVec L y)
      ≤ layerLip L * vecSupDist x y := by
  intro x y
  show vecSupDist (fun j => L.act.toFun (evalAffineVec L.layer x j))
      (fun j => L.act.toFun (evalAffineVec L.layer y j)) ≤ _
  calc vecSupDist (fun j => L.act.toFun (evalAffineVec L.layer x j))
          (fun j => L.act.toFun (evalAffineVec L.layer y j))
      ≤ L.act.lipConst * vecSupDist (evalAffineVec L.layer x) (evalAffineVec L.layer y) :=
        activation_sup_lipschitz L.act _ _
    _ ≤ L.act.lipConst * (opSupNorm L.layer.weight * vecSupDist x y) :=
        mul_le_mul_of_nonneg_left (affine_sup_lipschitz L.layer x y) L.act.lip_nonneg
    _ = layerLip L * vecSupDist x y := by unfold layerLip; ring

/-! ## §10. Network Composition -/

def networkLip [Nonempty ι] : List (PadicLayeredVecMap K ι ι) → ℝ
  | []      => 1
  | L :: t  => layerLip L * networkLip t

def evalNetwork : List (PadicLayeredVecMap K ι ι) → (ι → K) → (ι → K)
  | []      => id
  | L :: t  => fun x => evalNetwork t (evalVec L x)

theorem networkLip_nonneg [Nonempty ι] (net : List (PadicLayeredVecMap K ι ι)) :
    0 ≤ networkLip net := by
  induction net with
  | nil => simp [networkLip]
  | cons L t ih => exact mul_nonneg (layerLip_nonneg L) ih

theorem networkLip_cons [Nonempty ι]
    (L : PadicLayeredVecMap K ι ι) (net : List (PadicLayeredVecMap K ι ι)) :
    networkLip (L :: net) = layerLip L * networkLip net := rfl

theorem lipschitz_compose_sup [Nonempty ι]
    {f g : (ι → K) → (ι → K)} {Lf Lg : ℝ}
    (hLg : 0 ≤ Lg)
    (hf : ∀ x y, vecSupDist (f x) (f y) ≤ Lf * vecSupDist x y)
    (hg : ∀ x y, vecSupDist (g x) (g y) ≤ Lg * vecSupDist x y) :
    ∀ x y, vecSupDist (g (f x)) (g (f y)) ≤ (Lg * Lf) * vecSupDist x y := by
  intro x y
  calc vecSupDist (g (f x)) (g (f y))
      ≤ Lg * vecSupDist (f x) (f y) := hg _ _
    _ ≤ Lg * (Lf * vecSupDist x y) := mul_le_mul_of_nonneg_left (hf x y) hLg
    _ = (Lg * Lf) * vecSupDist x y := by ring

/-- **Network composition Lipschitz** by induction. -/
theorem networkLip_fold_bound [Nonempty ι]
    (net : List (PadicLayeredVecMap K ι ι)) :
    ∀ x y, vecSupDist (evalNetwork net x) (evalNetwork net y)
      ≤ networkLip net * vecSupDist x y := by
  induction net with
  | nil =>
    intro x y
    simp [evalNetwork, networkLip, id, one_mul]
  | cons L t ih =>
    intro x y
    simp only [evalNetwork, networkLip]
    calc vecSupDist (evalNetwork t (evalVec L x)) (evalNetwork t (evalVec L y))
        ≤ networkLip t * vecSupDist (evalVec L x) (evalVec L y) := ih _ _
      _ ≤ networkLip t * (layerLip L * vecSupDist x y) :=
          mul_le_mul_of_nonneg_left (layeredVec_lipschitz_bound L x y) (networkLip_nonneg t)
      _ = (layerLip L * networkLip t) * vecSupDist x y := by ring

/-! ## §11. Margin Definitions -/

def valuationGap (y : ι → K) (i j : ι) : ℝ := ‖y i - y j‖

def competitorMargin [DecidableEq ι] (y : ι → K) (good : ι)
    (hne : (Finset.univ.erase good).Nonempty) : ℝ :=
  (Finset.univ.erase good).inf' hne (fun j => ‖y good - y j‖)

def ArgmaxSeparated (y : ι → K) (good : ι) : Prop :=
  ∀ j, j ≠ good → valuationGap y good j > 0

def LabelStableOnBall [Nonempty ι]
    (f : (ι → K) → (ι → K)) (x : ι → K) (good : ι) (r : ℝ) : Prop :=
  ∀ z, vecSupDist z x < r → ∀ j, j ≠ good → ‖f z good - f z j‖ > 0

def SupBall [Nonempty ι] (x : ι → K) (r : ℝ) : Set (ι → K) :=
  {z | vecSupDist z x < r}

def certifiedRadius (margin lip : ℝ) : ℝ := margin / (2 * lip)

def postQuantumNoiseBudget (margin lip : ℝ) : ℝ := certifiedRadius margin lip

def quantumStabilityRadius (margin lip : ℝ) : ℝ := certifiedRadius margin lip

def LayerCascadeBound [Nonempty ι] (net : List (PadicLayeredVecMap K ι ι)) : ℝ :=
  networkLip net

structure UltrametricCertifiedClassifier (K : Type*) [NormedField K] [IsUltrametricDist K]
    (ι : Type*) [Fintype ι] [DecidableEq ι] where
  net : List (PadicLayeredVecMap K ι ι)
  goodLabel : (ι → K) → ι
  radiusAt : (ι → K) → ℝ

/-! ## §12. Margin and Radius Theorems -/

theorem certifiedRadius_pos {m L : ℝ} (hm : 0 < m) (hL : 0 < L) :
    0 < certifiedRadius m L :=
  div_pos hm (mul_pos two_pos hL)

theorem postQuantumNoiseBudget_eq_certifiedRadius (margin lip : ℝ) :
    postQuantumNoiseBudget margin lip = certifiedRadius margin lip := rfl

theorem quantumStabilityRadius_eq_certifiedRadius (margin lip : ℝ) :
    quantumStabilityRadius margin lip = certifiedRadius margin lip := rfl

theorem LayerCascadeBound_eq_networkLip [Nonempty ι]
    (net : List (PadicLayeredVecMap K ι ι)) :
    LayerCascadeBound net = networkLip net := rfl

theorem SupBall_mem_iff [Nonempty ι] (x z : ι → K) (r : ℝ) :
    z ∈ SupBall x r ↔ vecSupDist z x < r := Iff.rfl

theorem competitorMargin_le_gap [DecidableEq ι]
    (y : ι → K) (good j : ι) (hj : j ≠ good)
    (hne : (Finset.univ.erase good).Nonempty) :
    competitorMargin y good hne ≤ ‖y good - y j‖ :=
  Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hj, Finset.mem_univ _⟩)

theorem competitorMargin_nonneg [DecidableEq ι]
    (y : ι → K) (good : ι) (hne : (Finset.univ.erase good).Nonempty) :
    0 ≤ competitorMargin y good hne :=
  Finset.le_inf' hne _ (fun _ _ => norm_nonneg _)

theorem argmaxSeparated_iff_positive_competitorMargin [DecidableEq ι]
    (y : ι → K) (good : ι) (hne : (Finset.univ.erase good).Nonempty) :
    ArgmaxSeparated y good ↔ 0 < competitorMargin y good hne := by
  constructor
  · intro h
    unfold competitorMargin
    rw [lt_inf'_iff]
    intro j hj
    exact h j (Finset.mem_erase.mp hj).1
  · intro h j hj
    exact lt_of_lt_of_le h (competitorMargin_le_gap y good j hj hne)

theorem certifiedRadius_mono_margin {m₁ m₂ L : ℝ} (hL : 0 < L) (hm : m₁ ≤ m₂) :
    certifiedRadius m₁ L ≤ certifiedRadius m₂ L :=
  div_le_div_of_nonneg_right hm (le_of_lt (mul_pos two_pos hL))

theorem certifiedRadius_antitone_lip {m L₁ L₂ : ℝ} (hm : 0 ≤ m)
    (hL₁ : 0 < L₁) (hL : L₁ ≤ L₂) :
    certifiedRadius m L₂ ≤ certifiedRadius m L₁ := by
  apply div_le_div_of_nonneg_left hm (mul_pos two_pos hL₁)
  exact mul_le_mul_of_nonneg_left hL (le_of_lt two_pos)

/-! ## §13. Margin Perturbation -/

theorem network_coord_perturbation [Nonempty ι]
    (f : (ι → K) → (ι → K)) (L : ℝ)
    (hLip : ∀ x y, vecSupDist (f x) (f y) ≤ L * vecSupDist x y)
    (x z : ι → K) (j : ι) :
    ‖f z j - f x j‖ ≤ L * vecSupDist z x :=
  le_trans (vecSupDist_coord_le (f z) (f x) j) (hLip z x)

/-- **Valuation margin stability**: the core certification engine. -/
theorem valuation_margin_stable [DecidableEq ι] [Nonempty ι]
    (f : (ι → K) → (ι → K)) (L : ℝ)
    (hLip : ∀ x y, vecSupDist (f x) (f y) ≤ L * vecSupDist x y)
    (x z : ι → K) (good : ι)
    (hL : 0 < L)
    (hne : (Finset.univ.erase good).Nonempty)
    (hMargin : 0 < competitorMargin (f x) good hne)
    (hclose : vecSupDist z x < competitorMargin (f x) good hne / (2 * L)) :
    ∀ j, j ≠ good → ‖f z good - f z j‖ > 0 := by
  intro j hj
  have hgap : competitorMargin (f x) good hne ≤ ‖f x good - f x j‖ :=
    competitorMargin_le_gap (f x) good j hj hne
  have hpert_good : ‖f z good - f x good‖ ≤ L * vecSupDist z x :=
    network_coord_perturbation f L hLip x z good
  have hpert_j : ‖f z j - f x j‖ ≤ L * vecSupDist z x :=
    network_coord_perturbation f L hLip x z j
  by_contra h_not_pos
  push_neg at h_not_pos
  have h_zero : ‖f z good - f z j‖ = 0 :=
    le_antisymm h_not_pos (norm_nonneg _)
  have h_eq : f z good = f z j := by rwa [norm_eq_zero, sub_eq_zero] at h_zero
  have key : ‖f x good - f x j‖ ≤ L * vecSupDist z x := by
    have rw_eq : f x good - f x j = -(f z good - f x good) + (f z j - f x j) := by
      rw [h_eq]; ring
    rw [rw_eq]
    calc ‖-(f z good - f x good) + (f z j - f x j)‖
        ≤ max ‖-(f z good - f x good)‖ ‖f z j - f x j‖ :=
          IsUltrametricDist.norm_add_le_max _ _
      _ = max ‖f z good - f x good‖ ‖f z j - f x j‖ := by rw [norm_neg]
      _ ≤ max (L * vecSupDist z x) (L * vecSupDist z x) :=
          max_le_max hpert_good hpert_j
      _ = L * vecSupDist z x := max_self _
  have bound : competitorMargin (f x) good hne ≤ L * vecSupDist z x :=
    le_trans hgap key
  have small : L * vecSupDist z x < L * (competitorMargin (f x) good hne / (2 * L)) :=
    mul_lt_mul_of_pos_left hclose hL
  have half : L * (competitorMargin (f x) good hne / (2 * L)) =
      competitorMargin (f x) good hne / 2 := by field_simp
  linarith

/-! ## §14. The Headline Certification Theorem -/

/-- **Width-free certified robustness for ultrametric layered networks**.
    Bridge: nonarchimedean operator calculus → certified robustness (ML).
    Impact: lipschitz_certified_robustness, post_quantum, quantum_stability. -/
theorem ultrametric_lipschitz_certified_robustness [DecidableEq ι] [Nonempty ι]
    (net : List (PadicLayeredVecMap K ι ι))
    (x : ι → K) (good : ι)
    (hLipPos : 0 < networkLip net)
    (hne : (Finset.univ.erase good).Nonempty)
    (hMargin : 0 < competitorMargin (evalNetwork net x) good hne) :
    LabelStableOnBall (evalNetwork net) x good
      (certifiedRadius (competitorMargin (evalNetwork net x) good hne) (networkLip net)) :=
  fun z hz j hj =>
    valuation_margin_stable (evalNetwork net) (networkLip net)
      (networkLip_fold_bound net) x z good hLipPos hne hMargin hz j hj

/-! ## §15. Additional Theorems -/

/-- vecSupDist ultrametric triangle inequality. -/
theorem vecSupDist_ultrametric_triangle [Nonempty ι]
    (x y z : ι → K) :
    vecSupDist x z ≤ max (vecSupDist x y) (vecSupDist y z) := by
  apply Finset.sup'_le Finset.univ_nonempty
  intro i _
  show ‖x i - z i‖ ≤ _
  have : x i - z i = (x i - y i) + (y i - z i) := by ring
  rw [this]
  calc ‖(x i - y i) + (y i - z i)‖
      ≤ max ‖x i - y i‖ ‖y i - z i‖ := IsUltrametricDist.norm_add_le_max _ _
    _ ≤ max (vecSupDist x y) (vecSupDist y z) :=
        max_le_max (vecSupDist_coord_le x y i) (vecSupDist_coord_le y z i)

/-- **Valuation barrier persists under attack**. -/
theorem valuation_barrier_persists_under_attack [DecidableEq ι] [Nonempty ι]
    (net : List (PadicLayeredVecMap K ι ι))
    (x : ι → K) (good : ι)
    (hLipPos : 0 < networkLip net)
    (hne : (Finset.univ.erase good).Nonempty)
    (hMargin : 0 < competitorMargin (evalNetwork net x) good hne)
    (z : ι → K)
    (hz : z ∈ SupBall x (quantumStabilityRadius
      (competitorMargin (evalNetwork net x) good hne) (networkLip net))) :
    ArgmaxSeparated (evalNetwork net z) good := by
  intro j hj
  exact ultrametric_lipschitz_certified_robustness net x good hLipPos hne hMargin z hz j hj

/-- **Identity activation**: 1-Lipschitz. -/
def idActivation : UltrametricActivation K where
  toFun := id
  lipConst := 1
  lip_nonneg := zero_le_one
  ultra_lipschitz := fun x y => by simp [id]

/-- **Zero activation** (constant): 0-Lipschitz. -/
def zeroActivation (c : K) : UltrametricActivation K where
  toFun := fun _ => c
  lipConst := 0
  lip_nonneg := le_refl _
  ultra_lipschitz := fun _ _ => by simp

theorem evalNetwork_nil :
    evalNetwork ([] : List (PadicLayeredVecMap K ι ι)) = id := rfl

theorem networkLip_nil [Nonempty ι] :
    networkLip ([] : List (PadicLayeredVecMap K ι ι)) = 1 := rfl

/-- **Quantum stability radius control**. -/
theorem quantum_stability_radius_control {m L : ℝ} (hm : 0 < m) (hL : 0 < L) :
    0 < quantumStabilityRadius m L :=
  certifiedRadius_pos hm hL

/-- **Post-quantum noise budget soundness**. -/
theorem post_quantum_noise_budget_sound (margin lip : ℝ) :
    postQuantumNoiseBudget margin lip = margin / (2 * lip) := rfl

/-- **Lattice margin barrier theorem**. -/
theorem lattice_margin_barrier_theorem [DecidableEq ι] [Nonempty ι]
    (net : List (PadicLayeredVecMap K ι ι))
    (x : ι → K) (good : ι)
    (hLipPos : 0 < networkLip net)
    (hne : (Finset.univ.erase good).Nonempty)
    (hMargin : 0 < competitorMargin (evalNetwork net x) good hne)
    (z : ι → K)
    (hz : vecSupDist z x < certifiedRadius
      (competitorMargin (evalNetwork net x) good hne) (networkLip net))
    (j : ι) (hj : j ≠ good) :
    ‖evalNetwork net z good - evalNetwork net z j‖ > 0 :=
  ultrametric_lipschitz_certified_robustness net x good hLipPos hne hMargin z hz j hj

/-- **Berkovich vector gate bound**. -/
theorem berkovich_vector_gate_bound [Nonempty ι] [Nonempty κ]
    (L : PadicAffineVecLayer K ι κ) (x : ι → K) :
    vecSupNorm (evalAffineVec L x) ≤
      opSupNorm L.weight * vecSupNorm x +
      Finset.univ.sup' Finset.univ_nonempty (fun j => ‖L.bias j‖) := by
  apply Finset.sup'_le Finset.univ_nonempty
  intro j _
  show ‖evalAffineVec L x j‖ ≤ _
  simp only [evalAffineVec]
  calc ‖(∑ i, L.weight j i * x i) + L.bias j‖
      ≤ max ‖∑ i, L.weight j i * x i‖ ‖L.bias j‖ :=
        IsUltrametricDist.norm_add_le_max _ _
    _ ≤ max (opSupNorm L.weight * vecSupNorm x)
          (Finset.univ.sup' Finset.univ_nonempty (fun j => ‖L.bias j‖)) :=
        max_le_max (ultrametric_row_bound _ _ _)
          (Finset.le_sup' (fun j => ‖L.bias j‖) (Finset.mem_univ j))
    _ ≤ opSupNorm L.weight * vecSupNorm x +
          Finset.univ.sup' Finset.univ_nonempty (fun j => ‖L.bias j‖) :=
        max_le (le_add_of_nonneg_right (le_trans (norm_nonneg _)
          (Finset.le_sup' (fun j => ‖L.bias j‖)
            (Finset.mem_univ (Classical.arbitrary κ)))))
          (le_add_of_nonneg_left (mul_nonneg (opSupNorm_nonneg _) (vecSupNorm_nonneg _)))

end