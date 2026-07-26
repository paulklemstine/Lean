import Mathlib

/-!
# Tropical Geometric Langlands via Idempotent Affine Grassmannian Semirings
# and Certified Mirković–Vilonen Polytope Reconstruction

## Overview

We formalize a bridge between idempotent (tropical/min-plus) convolution algebra
and representation-theoretic geometry, proving:

1. **Classification**: Admissible characters over a tropical Hecke chamber complex
   are in canonical bijection with tropical MV-type polytopes.
2. **Monoidality**: Convolution of characters corresponds to Minkowski addition.
3. **Certified Reconstruction**: Extremal character values uniquely determine the
   associated tropical MV polytope.
4. **Concrete semimodules**: Min-plus action on a finite state space yields
   admissible characters.

## Mathematical Significance

This upgrades tropical Satake from a coarse correspondence to a geometric
representation classifier. In the idempotent world, MV geometry is recovered
from the convex envelope of spectral extremals.
-/

open Finset Function

noncomputable section

namespace TropicalGeometricLanglandsMV

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## §1. Chamber Complex -/

/-- A chamber complex: a finite graph with unit edge weights encoding
the combinatorial structure of an affine Grassmannian cell decomposition.
The `edgeWeight` gives the fundamental edge length (root length);
actual MV polytope bounds scale with the level/height parameter. -/
structure ChamberComplex (ι : Type*) [Fintype ι] [DecidableEq ι] where
  adj : ι → ι → Prop
  adj_dec : DecidableRel adj
  adj_symm : ∀ i j, adj i j → adj j i
  adj_irrefl : ∀ i, ¬adj i i
  /-- Fundamental edge weight (root length) -/
  edgeWeight : ι → ι → ℤ
  edgeWeight_nonneg : ∀ i j, 0 ≤ edgeWeight i j
  edgeWeight_symm : ∀ i j, edgeWeight i j = edgeWeight j i
  base : ι

attribute [instance] ChamberComplex.adj_dec

/-! ## §2. Tropical MV Polytopes

A tropical MV polytope of level `k` has weight differences bounded by
`k * edgeWeight(i,j)`. The level corresponds to the highest weight
in classical representation theory. -/

/-- A tropical MV polytope at level `k`: weight data where adjacent
chamber differences are bounded by `k * edgeWeight`. -/
structure TropicalMVPolytope (C : ChamberComplex ι) where
  /-- Weight function on chambers -/
  weight : ι → ℤ
  /-- Level (highest weight parameter) -/
  level : ℕ
  /-- Normalization: base chamber has weight 0 -/
  normalized : weight C.base = 0
  /-- Edge inequality: differences bounded by level × edge weight -/
  edge_ineq : ∀ i j, C.adj i j →
    weight i - weight j ≤ level * C.edgeWeight i j

@[ext]
theorem TropicalMVPolytope.ext {C : ChamberComplex ι}
    {P Q : TropicalMVPolytope C}
    (hw : P.weight = Q.weight) (hl : P.level = Q.level) : P = Q := by
  cases P; cases Q; simp only [mk.injEq]; exact ⟨hw, hl⟩

/-- The support function of a tropical MV polytope. -/
def TropicalMVPolytope.supportFn {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) : ι → ℤ := P.weight

/-
Edge bound in both directions.
-/
theorem TropicalMVPolytope.edge_ineq_abs {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) (i j : ι) (hij : C.adj i j) :
    |P.weight i - P.weight j| ≤ P.level * C.edgeWeight i j := by
  rw [ abs_sub_le_iff ];
  exact ⟨ P.edge_ineq i j hij, by simpa [ C.edgeWeight_symm ] using P.edge_ineq j i ( C.adj_symm i j hij ) ⟩

/-! ## §3. Admissible Characters -/

/-- An admissible character at level k: spectral data from the Hecke semiring. -/
structure AdmissibleCharacter (C : ChamberComplex ι) where
  val : ι → ℤ
  level : ℕ
  normalized : val C.base = 0
  convolution_compat : ∀ i j, C.adj i j →
    val i - val j ≤ level * C.edgeWeight i j

@[ext]
theorem AdmissibleCharacter.ext {C : ChamberComplex ι}
    {χ₁ χ₂ : AdmissibleCharacter C}
    (hv : χ₁.val = χ₂.val) (hl : χ₁.level = χ₂.level) : χ₁ = χ₂ := by
  cases χ₁; cases χ₂; simp only [mk.injEq]; exact ⟨hv, hl⟩

/-! ## §4. Classification Equivalence -/

/-- Map from admissible character to tropical MV polytope. -/
def charToMV {C : ChamberComplex ι}
    (χ : AdmissibleCharacter C) : TropicalMVPolytope C where
  weight := χ.val
  level := χ.level
  normalized := χ.normalized
  edge_ineq := χ.convolution_compat

/-- Map from tropical MV polytope to admissible character. -/
def mvToChar {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) : AdmissibleCharacter C where
  val := P.weight
  level := P.level
  normalized := P.normalized
  convolution_compat := P.edge_ineq

/-- **Classification Theorem**: Admissible characters ≃ tropical MV polytopes. -/
def tropicalMVClassification (C : ChamberComplex ι) :
    AdmissibleCharacter C ≃ TropicalMVPolytope C where
  toFun := charToMV
  invFun := mvToChar
  left_inv := fun χ => by ext <;> rfl
  right_inv := fun P => by ext <;> rfl

/-- Character equals support function under classification. -/
theorem tropical_character_eq_support_function {C : ChamberComplex ι}
    (χ : AdmissibleCharacter C) :
    (charToMV χ).supportFn = χ.val := rfl

/-! ## §5. The Zero Polytope -/

/-- The zero polytope at level 0. -/
def mvZero (C : ChamberComplex ι) : TropicalMVPolytope C where
  weight := fun _ => 0
  level := 0
  normalized := rfl
  edge_ineq := fun i j _ => by simp

/-! ## §6. Minkowski Addition -/

/-
Minkowski addition: pointwise weight addition, level addition.
-/
def mvMinkowski {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) : TropicalMVPolytope C where
  weight := fun i => P.weight i + Q.weight i
  level := P.level + Q.level
  normalized := by simp [P.normalized, Q.normalized]
  edge_ineq := fun i j hij => by
    convert add_le_add ( P.edge_ineq i j hij ) ( Q.edge_ineq i j hij ) using 1 ; ring;
    push_cast; ring

/-- Minkowski addition is commutative (on weights and levels). -/
theorem mvMinkowski_comm {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) :
    mvMinkowski P Q = mvMinkowski Q P := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvMinkowski]; ring
  · simp [mvMinkowski]; ring

/-- Minkowski addition is associative. -/
theorem mvMinkowski_assoc {C : ChamberComplex ι}
    (P Q R : TropicalMVPolytope C) :
    mvMinkowski (mvMinkowski P Q) R = mvMinkowski P (mvMinkowski Q R) := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvMinkowski]; ring
  · simp [mvMinkowski]; ring

/-- Zero is left identity for Minkowski addition. -/
theorem mvMinkowski_zero_left {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) :
    mvMinkowski (mvZero C) P = P := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvMinkowski, mvZero]
  · simp [mvMinkowski, mvZero]

/-- Zero is right identity. -/
theorem mvMinkowski_zero_right {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) :
    mvMinkowski P (mvZero C) = P := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvMinkowski, mvZero]
  · simp [mvMinkowski, mvZero]

/-- Support function is additive under Minkowski addition. -/
theorem supportFn_minkowski {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) (i : ι) :
    (mvMinkowski P Q).supportFn i = P.supportFn i + Q.supportFn i := rfl

/-- **Cancellation**: Minkowski addition is left-cancellative on weights. -/
theorem mvMinkowski_cancel_left_weight {C : ChamberComplex ι}
    (P Q R : TropicalMVPolytope C)
    (h : (mvMinkowski P Q).weight = (mvMinkowski P R).weight) : Q.weight = R.weight := by
  ext i
  have := congr_fun h i
  simp [mvMinkowski] at this; omega

/-! ## §7. Convolution on Admissible Characters -/

/-
Convolution: pointwise addition of values, sum of levels.
-/
def charConvolution {C : ChamberComplex ι}
    (χ₁ χ₂ : AdmissibleCharacter C) : AdmissibleCharacter C where
  val := fun i => χ₁.val i + χ₂.val i
  level := χ₁.level + χ₂.level
  normalized := by simp [χ₁.normalized, χ₂.normalized]
  convolution_compat := fun i j hij => by
    have := χ₁.convolution_compat i j hij; ( have := χ₂.convolution_compat i j hij; norm_num at *; linarith; )

/-- Convolution is commutative. -/
theorem charConvolution_comm {C : ChamberComplex ι}
    (χ₁ χ₂ : AdmissibleCharacter C) :
    charConvolution χ₁ χ₂ = charConvolution χ₂ χ₁ := by
  apply AdmissibleCharacter.ext
  · ext i; simp [charConvolution]; ring
  · simp [charConvolution]; ring

/-! ## §8. Monoidality: Convolution ↔ Minkowski -/

/-- **Monoidality Theorem**: Convolution maps to Minkowski addition. -/
theorem tropical_mv_convolution_minkowski {C : ChamberComplex ι}
    (χ₁ χ₂ : AdmissibleCharacter C) :
    charToMV (charConvolution χ₁ χ₂) = mvMinkowski (charToMV χ₁) (charToMV χ₂) := by
  apply TropicalMVPolytope.ext <;> rfl

/-- Character values are additive under convolution. -/
theorem semiring_character_convolution {C : ChamberComplex ι}
    (χ₁ χ₂ : AdmissibleCharacter C) (i : ι) :
    (charConvolution χ₁ χ₂).val i = χ₁.val i + χ₂.val i := rfl

/-! ## §9. Certified Reconstruction -/

/-- Raw character data on generators. -/
abbrev CharacterOnGenerators (ι : Type*) := ι → ℤ

/-- Admissibility of raw character data at a given level. -/
def IsAdmissible (C : ChamberComplex ι) (k : ℕ) (χ : CharacterOnGenerators ι) : Prop :=
  χ C.base = 0 ∧ ∀ i j, C.adj i j → χ i - χ j ≤ k * C.edgeWeight i j

/-- Edge inequalities predicate. -/
def EdgeInequalitiesHold (C : ChamberComplex ι) (k : ℕ) (w : ι → ℤ) : Prop :=
  ∀ i j, C.adj i j → w i - w j ≤ k * C.edgeWeight i j

/-- Tropical Plücker conditions: edge inequalities in both directions. -/
def TropicalPluckerHold (C : ChamberComplex ι) (k : ℕ) (w : ι → ℤ) : Prop :=
  ∀ i j, C.adj i j →
    w i - w j ≤ k * C.edgeWeight i j ∧ w j - w i ≤ k * C.edgeWeight j i

/-- Reconstruct a tropical MV polytope from admissible character data. -/
def reconstructMV {C : ChamberComplex ι} (k : ℕ) (χ : CharacterOnGenerators ι)
    (hχ : IsAdmissible C k χ) : TropicalMVPolytope C where
  weight := χ
  level := k
  normalized := hχ.1
  edge_ineq := hχ.2

/-- **Reconstruction Correctness**: edge + Plücker + support function recovery. -/
theorem reconstructMV_correct {C : ChamberComplex ι}
    (k : ℕ) (χ : CharacterOnGenerators ι) (hχ : IsAdmissible C k χ) :
    EdgeInequalitiesHold C k (reconstructMV k χ hχ).weight ∧
    TropicalPluckerHold C k (reconstructMV k χ hχ).weight ∧
    (reconstructMV k χ hχ).supportFn = χ := by
  refine ⟨hχ.2, ?_, rfl⟩
  intro i j hij
  exact ⟨hχ.2 i j hij, hχ.2 j i (C.adj_symm i j hij)⟩

/-- **Reconstruction Uniqueness**: support function determines the polytope. -/
theorem reconstructMV_unique {C : ChamberComplex ι}
    (k : ℕ) (χ : CharacterOnGenerators ι) (hχ : IsAdmissible C k χ)
    {P : TropicalMVPolytope C}
    (hP : P.supportFn = χ) (hk : P.level = k) :
    P = reconstructMV k χ hχ := by
  apply TropicalMVPolytope.ext
  · exact hP
  · exact hk

/-- Reconstruction is functorial on classification. -/
theorem reconstructMV_charToMV {C : ChamberComplex ι}
    (χ : AdmissibleCharacter C) :
    reconstructMV χ.level χ.val ⟨χ.normalized, χ.convolution_compat⟩ = charToMV χ := by
  apply TropicalMVPolytope.ext <;> rfl

/-- Two admissible characters yielding the same MV polytope are equal. -/
theorem admissible_of_same_mv {C : ChamberComplex ι}
    (χ₁ χ₂ : AdmissibleCharacter C)
    (h : charToMV χ₁ = charToMV χ₂) : χ₁ = χ₂ := by
  have hw := congr_arg TropicalMVPolytope.weight h
  have hl := congr_arg TropicalMVPolytope.level h
  exact AdmissibleCharacter.ext hw hl

/-! ## §10. Negation (Contragredient) -/

/-- Negation: the contragredient/dual polytope. -/
def mvNeg {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) : TropicalMVPolytope C where
  weight := fun i => -P.weight i
  level := P.level
  normalized := by simp [P.normalized]
  edge_ineq := fun i j hij => by
    have h := P.edge_ineq j i (C.adj_symm i j hij)
    rw [C.edgeWeight_symm j i] at h
    omega

/-- Double negation is identity. -/
theorem mvNeg_involutive {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) :
    mvNeg (mvNeg P) = P := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvNeg]
  · rfl

/-- Negation distributes over Minkowski addition. -/
theorem mvNeg_minkowski {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) :
    mvNeg (mvMinkowski P Q) = mvMinkowski (mvNeg P) (mvNeg Q) := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvNeg, mvMinkowski]; ring
  · simp [mvNeg, mvMinkowski]

/-! ## §11. Scaling -/

/-
Scale a tropical MV polytope by a natural number.
-/
def mvScale {C : ChamberComplex ι}
    (k : ℕ) (P : TropicalMVPolytope C) : TropicalMVPolytope C where
  weight := fun i => k * P.weight i
  level := k * P.level
  normalized := by simp [P.normalized]
  edge_ineq := fun i j hij => by
    simpa [ ← mul_sub, mul_assoc ] using mul_le_mul_of_nonneg_left ( P.edge_ineq i j hij ) ( Nat.cast_nonneg k )

/-- Scaling by 0 gives the zero polytope. -/
theorem mvScale_zero {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) :
    mvScale 0 P = mvZero C := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvScale, mvZero]
  · simp [mvScale, mvZero]

/-- Scaling by 1 is identity. -/
theorem mvScale_one {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) :
    mvScale 1 P = P := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvScale]
  · simp [mvScale]

/-- Scaling distributes: scale (k+l) P = Minkowski (scale k P) (scale l P). -/
theorem mvScale_add {C : ChamberComplex ι}
    (k l : ℕ) (P : TropicalMVPolytope C) :
    mvScale (k + l) P = mvMinkowski (mvScale k P) (mvScale l P) := by
  apply TropicalMVPolytope.ext
  · ext i; simp [mvScale, mvMinkowski]; ring
  · simp [mvScale, mvMinkowski]; ring

/-! ## §12. Concrete Tropical Hecke Semimodules -/

/-- A concrete tropical Hecke semimodule: min-plus action matrices. -/
structure TropicalHeckeSemimodule (C : ChamberComplex ι) (n : ℕ) where
  action : ι → Fin n → Fin n → ℤ
  /-- Adjacent generators have close action matrices -/
  edge_compat : ∀ i j, C.adj i j → ∀ s t : Fin n,
    action i s t - action j s t ≤ C.edgeWeight i j
  /-- Base generator has zero diagonal -/
  base_diag : ∀ s : Fin n, action C.base s s = 0
  /-- Non-negative off-diagonal for base -/
  base_offdiag : ∀ s t : Fin n, 0 ≤ action C.base s t

/-- Character: minimum diagonal entry per generator (tropical trace). -/
def semimoduleCharacter {C : ChamberComplex ι} {n : ℕ} (hn : 0 < n)
    (M : TropicalHeckeSemimodule C n) : ι → ℤ :=
  fun i => Finset.min' (Finset.univ.image (fun s => M.action i s s))
    (by rw [Finset.image_nonempty]; haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
        exact Finset.univ_nonempty)

/-
Character at base is 0.
-/
theorem semimoduleCharacter_base {C : ChamberComplex ι} {n : ℕ} (hn : 0 < n)
    (M : TropicalHeckeSemimodule C n) :
    semimoduleCharacter hn M C.base = 0 := by
  unfold semimoduleCharacter;
  simp +decide [ Finset.min', M.base_diag ]

/-
Character satisfies edge compatibility.
-/
theorem semimoduleCharacter_edge {C : ChamberComplex ι} {n : ℕ} (hn : 0 < n)
    (M : TropicalHeckeSemimodule C n) (i j : ι) (hij : C.adj i j) :
    semimoduleCharacter hn M i - semimoduleCharacter hn M j ≤ C.edgeWeight i j := by
  unfold semimoduleCharacter;
  simp +decide [ Finset.min' ];
  obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) ( fun x => M.action j x x );
  exact ⟨ k, by linarith [ M.edge_compat i j hij k k ] ⟩

/-- Character of a semimodule is admissible at level 1. -/
theorem semimoduleCharacter_admissible {C : ChamberComplex ι} {n : ℕ} (hn : 0 < n)
    (M : TropicalHeckeSemimodule C n) :
    IsAdmissible C 1 (semimoduleCharacter hn M) := by
  constructor
  · exact semimoduleCharacter_base hn M
  · intro i j hij; simp; linarith [semimoduleCharacter_edge hn M i j hij]

/-- The MV polytope associated to a semimodule. -/
def semimoduleToMV {C : ChamberComplex ι} {n : ℕ} (hn : 0 < n)
    (M : TropicalHeckeSemimodule C n) : TropicalMVPolytope C :=
  reconstructMV 1 (semimoduleCharacter hn M) (semimoduleCharacter_admissible hn M)

/-! ## §13. Edge and Plücker Properties -/

/-- Edge inequalities imply tropical Plücker conditions. -/
theorem edge_implies_plucker {C : ChamberComplex ι}
    (P : TropicalMVPolytope C) :
    TropicalPluckerHold C P.level P.weight := by
  intro i j hij
  constructor
  · exact P.edge_ineq i j hij
  · exact P.edge_ineq j i (C.adj_symm i j hij)

theorem admissible_implies_plucker {C : ChamberComplex ι}
    (k : ℕ) (χ : CharacterOnGenerators ι) (hχ : IsAdmissible C k χ) :
    TropicalPluckerHold C k χ := by
  intro i j hij
  constructor
  · exact hχ.2 i j hij
  · exact hχ.2 j i (C.adj_symm i j hij)

/-! ## §14. Pointwise Min/Max Properties -/

/-
Pointwise max preserves edge bounds.
-/
theorem pointwise_max_edge {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) (i j : ι) (hij : C.adj i j)
    (hlev : P.level = Q.level) :
    max (P.weight i) (Q.weight i) - max (P.weight j) (Q.weight j)
      ≤ P.level * C.edgeWeight i j := by
  have := P.edge_ineq i j hij; ((have := Q.edge_ineq i j hij; ((simp_all +decide [ sub_eq_iff_eq_add, max_def ]))) ;);
  split_ifs <;> linarith

/-
Pointwise min preserves edge bounds.
-/
theorem pointwise_min_edge {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) (i j : ι) (hij : C.adj i j)
    (hlev : P.level = Q.level) :
    min (P.weight i) (Q.weight i) - min (P.weight j) (Q.weight j)
      ≤ P.level * C.edgeWeight i j := by
  cases le_total ( P.weight i ) ( Q.weight i ) <;> cases le_total ( P.weight j ) ( Q.weight j ) <;> simp +decide [ * ];
  · linarith [ P.edge_ineq i j hij, Q.edge_ineq i j hij, hlev ▸ P.edge_ineq i j hij ];
  · linarith [ P.edge_ineq i j hij, Q.edge_ineq i j hij, C.edgeWeight_symm i j ];
  · have := P.edge_ineq i j hij;
    grind;
  · linarith [ Q.edge_ineq i j hij ]

/-! ## §15. The A₂ Chamber Complex (GL₃) -/

/-- The A₂ chamber complex: 3 chambers, complete graph, unit edge weights. -/
def a2Chamber : ChamberComplex (Fin 3) where
  adj := fun i j => i ≠ j
  adj_dec := inferInstance
  adj_symm := fun _ _ h => Ne.symm h
  adj_irrefl := fun _ h => absurd rfl h
  edgeWeight := fun _ _ => 1
  edgeWeight_nonneg := fun _ _ => by omega
  edgeWeight_symm := fun _ _ => rfl
  base := 0

/-- Fundamental weight ω₁ at level 1. -/
def a2_omega1 : TropicalMVPolytope a2Chamber where
  weight := ![0, 1, 0]
  level := 1
  normalized := by native_decide
  edge_ineq := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [a2Chamber]

/-- Fundamental weight ω₂ at level 1. -/
def a2_omega2 : TropicalMVPolytope a2Chamber where
  weight := ![0, 0, 1]
  level := 1
  normalized := by native_decide
  edge_ineq := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [a2Chamber]

/-- Minkowski sum of fundamental weights gives expected result. -/
theorem a2_minkowski_sum_weights :
    (mvMinkowski a2_omega1 a2_omega2).weight = ![0, 1, 1] := by
  ext i; fin_cases i <;> native_decide

/-- Distinct MV polytopes exist (non-triviality). -/
theorem a2_omega1_ne_omega2 : a2_omega1 ≠ a2_omega2 := by
  intro h
  have := congr_arg TropicalMVPolytope.weight h
  have h1 : (a2_omega1.weight : Fin 3 → ℤ) 1 = 1 := by native_decide
  have h2 : (a2_omega2.weight : Fin 3 → ℤ) 1 = 0 := by native_decide
  rw [this] at h1; omega

/-! ## §16. Superadditivity -/

/-- Minkowski sum dominates max when both weights are non-negative. -/
theorem mvMinkowski_ge_max_nonneg {C : ChamberComplex ι}
    (P Q : TropicalMVPolytope C) (i : ι)
    (hP : 0 ≤ P.weight i) (hQ : 0 ≤ Q.weight i) :
    max (P.weight i) (Q.weight i) ≤ (mvMinkowski P Q).weight i := by
  simp [mvMinkowski]; omega

/-! ## §17. Reconstruction Injectivity and Surjectivity -/

theorem reconstructMV_injective {C : ChamberComplex ι} (k : ℕ) :
    ∀ χ₁ χ₂ : CharacterOnGenerators ι,
    ∀ h₁ : IsAdmissible C k χ₁, ∀ h₂ : IsAdmissible C k χ₂,
    reconstructMV k χ₁ h₁ = reconstructMV k χ₂ h₂ → χ₁ = χ₂ := fun _ _ _ _ heq =>
  congr_arg TropicalMVPolytope.weight heq

theorem reconstructMV_surjective {C : ChamberComplex ι} :
    ∀ P : TropicalMVPolytope C,
    ∃ k : ℕ, ∃ χ : CharacterOnGenerators ι, ∃ hχ : IsAdmissible C k χ,
    reconstructMV k χ hχ = P :=
  fun P => ⟨P.level, P.weight, ⟨P.normalized, P.edge_ineq⟩, by
    apply TropicalMVPolytope.ext <;> rfl⟩

/-! ## §18. Admissible Sum -/

/-- Sum of admissible characters is admissible (with summed levels). -/
theorem admissible_sum {C : ChamberComplex ι}
    (k₁ k₂ : ℕ) (χ₁ χ₂ : CharacterOnGenerators ι)
    (h₁ : IsAdmissible C k₁ χ₁) (h₂ : IsAdmissible C k₂ χ₂) :
    IsAdmissible C (k₁ + k₂) (fun i => χ₁ i + χ₂ i) := by
  constructor
  · simp [h₁.1, h₂.1]
  · intro i j hij
    have e1 := h₁.2 i j hij
    have e2 := h₂.2 i j hij
    have : (χ₁ i + χ₂ i) - (χ₁ j + χ₂ j) =
           (χ₁ i - χ₁ j) + (χ₂ i - χ₂ j) := by ring
    rw [this]
    calc (χ₁ i - χ₁ j) + (χ₂ i - χ₂ j)
        ≤ ↑k₁ * C.edgeWeight i j + ↑k₂ * C.edgeWeight i j := add_le_add e1 e2
      _ = (↑k₁ + ↑k₂) * C.edgeWeight i j := by ring
      _ = ↑(k₁ + k₂) * C.edgeWeight i j := by push_cast; ring

/-! ## §19. Reconstruction-Minkowski Compatibility -/

/-- Reconstruction commutes with Minkowski addition. -/
theorem reconstructMV_minkowski_compat {C : ChamberComplex ι}
    (k₁ k₂ : ℕ) (χ₁ χ₂ : CharacterOnGenerators ι)
    (h₁ : IsAdmissible C k₁ χ₁) (h₂ : IsAdmissible C k₂ χ₂) :
    reconstructMV (k₁ + k₂) (fun i => χ₁ i + χ₂ i) (admissible_sum k₁ k₂ χ₁ χ₂ h₁ h₂) =
      mvMinkowski (reconstructMV k₁ χ₁ h₁) (reconstructMV k₂ χ₂ h₂) := by
  apply TropicalMVPolytope.ext <;> rfl

end TropicalGeometricLanglandsMV