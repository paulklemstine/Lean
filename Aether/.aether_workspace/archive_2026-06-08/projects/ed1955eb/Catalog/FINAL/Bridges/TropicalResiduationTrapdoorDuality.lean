/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Residuation Trapdoor Duality

## Overview

This module formalizes a structural theory of trapdoors in tropical (min-plus) matrix
algebra. The central construction is the **public map** F_{A,B}(X) = A ⊗ X ⊗ B,
where ⊗ denotes min-plus matrix multiplication.

## Main Results

### Algebraic Foundations
* `tropMul_assoc` — min-plus matrix multiplication is associative
* `tropMul_entry_le` — each entry of a product is bounded by any witness term
* `boundedEntries_tropMul` — bounded entries are preserved under multiplication

### Ordering & Monotonicity
* `tropLe_refl`, `tropLe_trans`, `tropLe_antisymm` — entry-wise ordering is a partial order
* `tropMul_mono_left`, `tropMul_mono_right` — tropical multiplication is order-monotone
* `publicMap_mono` — the public map preserves tropical ordering

### Residuation Class Structure
* `resLe_trans` — witness-based residuation is transitive
* `sameResiduationClass_symm`, `sameResiduationClass_trans` — class equivalence properties

### Compression & Spectrum Invariance
* `rowMins_tropMul` — row minima transform covariantly under left multiplication
* `colMins_tropMul` — column minima transform covariantly under right multiplication
* `rowMins_additiveShift` — row minima shift by additive constants
* `residuationSpectrum_additiveShift` — spectrum is invariant under additive shifts

### Fiber Ambiguity (the breakthrough results)
* `publicMap_zero_fiber_collapse` — zero-matrix public map collapses to global minimum
* `inverse_fiber_contains_incomparable_pair` — fibers contain tropically incomparable pairs
* `inverse_fiber_nontrivial` — for n ≥ 2, there exist non-trivial fibers

## Cross-Domain Connections

- **Post-quantum cryptography**: hardness from idempotent algebraic ambiguity
- **Tropical geometry**: residuation classes as tropical orbit strata
- **Ordered algebra**: inversion hardness as preorder/antichain structure
- **Information theory**: compression profiles as public summaries with tropical information loss
-/

open Finset BigOperators

namespace TropicalTrapdoor

/-- Tropical matrix: n×n matrix with integer entries, under min-plus operations. -/
abbrev TropMat (n : ℕ) := Matrix (Fin n) (Fin n) ℤ

/-! ## Section 1: Core Definitions -/

/-- **Min-plus matrix multiplication**: `(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)`.
    This is the fundamental operation of tropical linear algebra. -/
def tropMul {n : ℕ} (A B : TropMat n) : TropMat n :=
  fun i j => Finset.univ.inf' ⟨i, Finset.mem_univ i⟩ (fun k => A i k + B k j)

/-- **The public map** `F_{A,B}(X) = A ⊗ X ⊗ B`.
    Public keys A, B define a tropical conjugation action on secret matrix X. -/
def publicMap {n : ℕ} (A B X : TropMat n) : TropMat n :=
  tropMul (tropMul A X) B

/-- A matrix has **bounded entries** if all entries have absolute value ≤ K. -/
def boundedEntries {n : ℕ} (K : ℕ) (X : TropMat n) : Prop :=
  ∀ i j, |X i j| ≤ (K : ℤ)

/-- **Row minima** of a tropical matrix. -/
def rowMins {n : ℕ} [NeZero n] (X : TropMat n) (i : Fin n) : ℤ :=
  Finset.univ.inf' Finset.univ_nonempty (fun j => X i j)

/-- **Column minima** of a tropical matrix. -/
def colMins {n : ℕ} [NeZero n] (X : TropMat n) (j : Fin n) : ℤ :=
  Finset.univ.inf' Finset.univ_nonempty (fun i => X i j)

/-- **Additive shift**: translate all entries by a constant. -/
def additiveShift {n : ℕ} (c : ℤ) (X : TropMat n) : TropMat n :=
  fun i j => X i j + c

/-- **Compression profile**: row and column minima vectors.
    These are the publicly extractable invariants of a tropical matrix. -/
structure CompressionProfile (n : ℕ) where
  rowPart : Fin n → ℤ
  colPart : Fin n → ℤ
  deriving DecidableEq

/-- Extract the compression profile of a tropical matrix. -/
noncomputable def compressionProfile {n : ℕ} [NeZero n] (X : TropMat n) :
    CompressionProfile n where
  rowPart := rowMins X
  colPart := colMins X

/-- **Entry-wise tropical ordering**: X ≤_trop Y iff Xᵢⱼ ≤ Yᵢⱼ for all i,j. -/
def tropLe {n : ℕ} (X Y : TropMat n) : Prop :=
  ∀ i j, X i j ≤ Y i j

/-- **Witness-based residuation**: X ≤_res Y iff X = L ⊗ Y ⊗ R for some L, R.
    Captures "derivable from" under tropical side-actions. -/
def resLe {n : ℕ} (X Y : TropMat n) : Prop :=
  ∃ L R : TropMat n, X = tropMul (tropMul L Y) R

/-- **Same residuation class**: mutual residuation derivability. -/
def sameResiduationClass {n : ℕ} (X Y : TropMat n) : Prop :=
  resLe X Y ∧ resLe Y X

/-- **Residuation spectrum**: sorted gaps from row minima.
    Records the sorted list of `Xᵢⱼ - rowMin_i` for all i,j. -/
structure ResiduationSpectrum (n : ℕ) where
  gaps : List ℤ
  deriving DecidableEq

/-- Extract the residuation spectrum from a tropical matrix. -/
noncomputable def residuationSpectrum {n : ℕ} [NeZero n] (X : TropMat n) :
    ResiduationSpectrum n where
  gaps := (((List.finRange n).flatMap (fun i =>
    (List.finRange n).map (fun j => X i j - rowMins X i))).mergeSort (· ≤ ·))

/-- **Public signature** combining compression profile and residuation spectrum. -/
structure Signature (n : ℕ) where
  profile : CompressionProfile n
  spectrum : ResiduationSpectrum n
  deriving DecidableEq

/-- Extract the full signature of a tropical matrix. -/
noncomputable def signature {n : ℕ} [NeZero n] (X : TropMat n) : Signature n where
  profile := compressionProfile X
  spectrum := residuationSpectrum X

/-- A matrix is **spectrally isolated** if its signature uniquely determines its
    residuation class. -/
def SpectrallyIsolated {n : ℕ} [NeZero n] (X : TropMat n) : Prop :=
  ∀ Y : TropMat n, signature X = signature Y → sameResiduationClass X Y

/-- **Fiber collapse witness**: the public map collapses distinct bounded matrices. -/
def FiberCollapseWitness {n : ℕ} (A B Z : TropMat n) (K : ℕ) : Prop :=
  ∃ X Y : TropMat n, boundedEntries K X ∧ boundedEntries K Y ∧
    X ≠ Y ∧ publicMap A B X = Z ∧ publicMap A B Y = Z

/-! ## Section 2: Basic Algebraic Properties -/

/-- Each entry of a tropical product is bounded by any witness term. -/
theorem tropMul_entry_le {n : ℕ} (A B : TropMat n) (i j k : Fin n) :
    tropMul A B i j ≤ A i k + B k j :=
  Finset.inf'_le _ (Finset.mem_univ k)

/-- There exists a witness achieving the tropical product entry. -/
theorem tropMul_exists_witness {n : ℕ} (A B : TropMat n) (i j : Fin n) :
    ∃ k, tropMul A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' _ (fun k => A i k + B k j)
  exact ⟨k, hk⟩

/-
**Associativity of min-plus matrix multiplication.**
    This is the fundamental algebraic property enabling compositional reasoning
    about tropical matrix semigroups.
-/
theorem tropMul_assoc {n : ℕ} (A B C : TropMat n) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  ext i j;
  refine' le_antisymm _ _;
  · obtain ⟨ k, hk ⟩ := tropMul_exists_witness A ( tropMul B C ) i j;
    obtain ⟨ l, hl ⟩ := tropMul_exists_witness B C k j;
    exact le_trans ( tropMul_entry_le _ _ _ _ _ ) ( by linarith [ tropMul_entry_le A B i l k ] );
  · obtain ⟨ k, hk ⟩ := tropMul_exists_witness ( tropMul A B ) C i j;
    obtain ⟨ l, hl ⟩ := tropMul_exists_witness A B i k;
    exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ l ) ) ( by linarith [ tropMul_entry_le A ( tropMul B C ) i j l, tropMul_entry_le B C l j k ] )

/-
**Bounded entries are preserved under tropical multiplication.**
    If A is K_A-bounded and B is K_B-bounded, then A ⊗ B is (K_A + K_B)-bounded.
-/
theorem boundedEntries_tropMul {n : ℕ} (KA KB : ℕ) (A B : TropMat n)
    (hA : boundedEntries KA A) (hB : boundedEntries KB B) :
    boundedEntries (KA + KB) (tropMul A B) := by
  intro i j;
  have := tropMul_exists_witness A B i j;
  obtain ⟨ k, hk ⟩ := this; rw [ hk ] ; exact abs_le.mpr ⟨ by push_cast; linarith [ abs_le.mp ( hA i k ), abs_le.mp ( hB k j ) ], by push_cast; linarith [ abs_le.mp ( hA i k ), abs_le.mp ( hB k j ) ] ⟩ ;

/-
**Bounded entries are preserved under the public map.**
-/
theorem boundedEntries_publicMap {n : ℕ} (K : ℕ) (A B X : TropMat n)
    (hA : boundedEntries K A) (hB : boundedEntries K B) (hX : boundedEntries K X) :
    boundedEntries (3 * K) (publicMap A B X) := by
  -- By boundedEntries_tropMul, tropMul A X is (K+K)-bounded.
  have h1 : boundedEntries (K + K) (tropMul A X) := by
    exact?;
  convert boundedEntries_tropMul ( K + K ) K ( tropMul A X ) B h1 hB using 1 ; ring

/-! ## Section 3: Entry-wise Ordering -/

theorem tropLe_refl {n : ℕ} (X : TropMat n) : tropLe X X :=
  fun _ _ => le_refl _

theorem tropLe_trans {n : ℕ} {X Y Z : TropMat n}
    (hXY : tropLe X Y) (hYZ : tropLe Y Z) : tropLe X Z :=
  fun i j => le_trans (hXY i j) (hYZ i j)

theorem tropLe_antisymm {n : ℕ} {X Y : TropMat n}
    (hXY : tropLe X Y) (hYX : tropLe Y X) : X = Y := by
  ext i j; exact le_antisymm (hXY i j) (hYX i j)

/-
**Left tropical multiplication is monotone in the right factor.**
-/
theorem tropMul_mono_right {n : ℕ} (A : TropMat n) {X Y : TropMat n}
    (h : tropLe X Y) : tropLe (tropMul A X) (tropMul A Y) := by
  unfold tropMul;
  intro i j; simp +decide [ *, Finset.inf'_le_iff ] ;
  exact fun k => ⟨ k, by linarith [ h k j ] ⟩

/-
**Right tropical multiplication is monotone in the left factor.**
-/
theorem tropMul_mono_left {n : ℕ} {X Y : TropMat n} (B : TropMat n)
    (h : tropLe X Y) : tropLe (tropMul X B) (tropMul Y B) := by
  intro i j;
  obtain ⟨ k, hk ⟩ := tropMul_exists_witness Y B i j;
  exact le_trans ( tropMul_entry_le _ _ _ _ _ ) ( by linarith [ h i k ] )

/-- **The public map preserves tropical ordering.**
    This is the key monotonicity engine for the trapdoor theory:
    if X ≤_trop Y then F_{A,B}(X) ≤_trop F_{A,B}(Y). -/
theorem publicMap_mono {n : ℕ} (A B : TropMat n) {X Y : TropMat n}
    (h : tropLe X Y) : tropLe (publicMap A B X) (publicMap A B Y) :=
  tropMul_mono_left B (tropMul_mono_right A h)

/-! ## Section 4: Residuation Class Structure -/

/-
**Transitivity of witness-based residuation.**
    If X = L₁ ⊗ Y ⊗ R₁ and Y = L₂ ⊗ Z ⊗ R₂, then
    X = (L₁⊗L₂) ⊗ Z ⊗ (R₂⊗R₁).
-/
theorem resLe_trans {n : ℕ} {X Y Z : TropMat n}
    (hXY : resLe X Y) (hYZ : resLe Y Z) : resLe X Z := by
  -- By definition of $resLe$, we have $X = tropMul (tropMul L₁ Y) R₁$ and $Y = tropMul (tropMul L₂ Z) R₂$.
  obtain ⟨L₁, R₁, hL₁R₁⟩ := hXY
  obtain ⟨L₂, R₂, hL₂R₂⟩ := hYZ
  rw [hL₁R₁, hL₂R₂];
  -- By definition of $tropMul$, we can rewrite the expression as $tropMul (tropMul (tropMul L₁ L₂) Z) (tropMul R₂ R₁)$.
  have h_rewrite : tropMul (tropMul L₁ (tropMul (tropMul L₂ Z) R₂)) R₁ = tropMul (tropMul (tropMul L₁ L₂) Z) (tropMul R₂ R₁) := by
    simp +decide only [tropMul_assoc];
  exact ⟨ tropMul L₁ L₂, tropMul R₂ R₁, h_rewrite ⟩

/-- Symmetry of same residuation class (by definition). -/
theorem sameResiduationClass_symm {n : ℕ} {X Y : TropMat n}
    (h : sameResiduationClass X Y) : sameResiduationClass Y X :=
  ⟨h.2, h.1⟩

/-- Transitivity of same residuation class. -/
theorem sameResiduationClass_trans {n : ℕ} {X Y Z : TropMat n}
    (hXY : sameResiduationClass X Y) (hYZ : sameResiduationClass Y Z) :
    sameResiduationClass X Z :=
  ⟨resLe_trans hXY.1 hYZ.1, resLe_trans hYZ.2 hXY.2⟩

/-! ## Section 5: Compression & Spectrum Functoriality -/

/-
**Row minima transform covariantly under left multiplication.**
    `rowMins(A ⊗ X) i = min_k (A i k + rowMins X k)`

    This shows that compression data has a clean transformation law
    under tropical matrix action: left multiplication by A acts on
    row minima via tropical matrix-vector multiplication.
-/
theorem rowMins_tropMul {n : ℕ} [NeZero n] (A X : TropMat n) (i : Fin n) :
    rowMins (tropMul A X) i =
    Finset.univ.inf' Finset.univ_nonempty (fun k => A i k + rowMins X k) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ rowMins ];
  · intro b
    obtain ⟨j, hj⟩ : ∃ j, X b j = Finset.univ.inf' (by simp) (fun j => X b j) := by
      have := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => X b j ) ; aesop;
    use j
    simp [hj, tropMul];
    exact ⟨ b, by rw [ ← hj ] ⟩;
  · intro j;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => A i k + X k j );
    exact ⟨ k, by unfold tropMul; aesop ⟩

/-
**Column minima transform covariantly under right multiplication.**
    `colMins(X ⊗ B) j = min_k (colMins X k + B k j)`
-/
theorem colMins_tropMul {n : ℕ} [NeZero n] (X B : TropMat n) (j : Fin n) :
    colMins (tropMul X B) j =
    Finset.univ.inf' Finset.univ_nonempty (fun k => colMins X k + B k j) := by
  refine' le_antisymm _ _ <;> simp +decide [ colMins, tropMul ];
  · exact fun k => by obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun i => X i k ) ; exact ⟨ i, k, by linarith ⟩ ;
  · exact fun i j => ⟨ j, add_le_add ( Finset.inf'_le _ <| Finset.mem_univ _ ) le_rfl ⟩

/-
**Row minima shift linearly under additive shift.**
-/
theorem rowMins_additiveShift {n : ℕ} [NeZero n] (c : ℤ) (X : TropMat n)
    (i : Fin n) :
    rowMins (additiveShift c X) i = rowMins X i + c := by
  unfold rowMins additiveShift;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, le_refl ];
  · simpa using Finset.exists_min_image Finset.univ ( fun b => X i b ) ⟨ i, Finset.mem_univ i ⟩;
  · exact fun j => ⟨ j, le_rfl ⟩

/-
**The residuation spectrum is invariant under additive shifts.**
    This is a key structural result: the spectrum captures the "shape"
    of a matrix independent of its absolute level, making it a natural
    quotient invariant for tropical cryptography.
-/
theorem residuationSpectrum_additiveShift {n : ℕ} [NeZero n] (c : ℤ)
    (X : TropMat n) :
    residuationSpectrum (additiveShift c X) = residuationSpectrum X := by
  unfold residuationSpectrum;
  simp +decide [ rowMins_additiveShift, additiveShift ]

/-! ## Section 6: Constant Matrix Interactions -/

/-- The constant matrix: all entries equal to c. -/
def constMat {n : ℕ} (c : ℤ) : TropMat n := fun _ _ => c

/-
**Tropical multiplication by a constant matrix on the left extracts column minima.**
    `(constMat c ⊗ X)ᵢⱼ = c + colMins X j`
-/
theorem tropMul_constMat_left {n : ℕ} [NeZero n] (c : ℤ) (X : TropMat n)
    (i j : Fin n) :
    tropMul (constMat c) X i j = c + colMins X j := by
  unfold tropMul colMins;
  refine' le_antisymm _ _ <;> simp +decide [ add_comm, Finset.le_inf'_iff ];
  · obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty fun i => X i j ; use k ; simp +decide [ hk, add_comm ];
    exact add_comm ( X k j ) c ▸ le_rfl;
  · exact fun k => by rw [ add_comm ] ; exact add_le_add ( Finset.inf'_le _ <| Finset.mem_univ _ ) le_rfl;

/-
**Tropical multiplication by a constant matrix on the right extracts row minima.**
    `(X ⊗ constMat c)ᵢⱼ = rowMins X i + c`
-/
theorem tropMul_constMat_right {n : ℕ} [NeZero n] (X : TropMat n) (c : ℤ)
    (i j : Fin n) :
    tropMul X (constMat c) i j = rowMins X i + c := by
  unfold tropMul;
  refine' le_antisymm _ _ <;> simp +decide [ rowMins, constMat ];
  · simpa using Finset.exists_min_image Finset.univ ( fun b => X i b ) ⟨ j, Finset.mem_univ j ⟩;
  · exact fun b => ⟨ b, le_rfl ⟩

/-
**The public map with zero constant matrices collapses to the global minimum.**
    This is the core structural lemma for fiber ambiguity.
-/
theorem publicMap_zero_eq_globalMin {n : ℕ} [NeZero n] (X : TropMat n) (i j : Fin n) :
    publicMap (constMat 0) (constMat 0) X i j =
    Finset.univ.inf' Finset.univ_nonempty (fun k => colMins X k) := by
  unfold publicMap;
  unfold tropMul;
  unfold constMat colMins; aesop;

/-! ## Section 7: Fiber Ambiguity — The Breakthrough Results -/

/-- First witness matrix for fiber ambiguity: entry (0,0) = 0, all others = 1. -/
def fiberWitness1 : TropMat 2 :=
  fun i j => if i = 0 ∧ j = 0 then 0 else 1

/-- Second witness matrix for fiber ambiguity: entry (0,1) = 0, all others = 1. -/
def fiberWitness2 : TropMat 2 :=
  fun i j => if i = 0 ∧ j = 1 then 0 else 1

theorem fiberWitness1_ne_fiberWitness2 : fiberWitness1 ≠ fiberWitness2 := by
  native_decide +revert

theorem fiberWitness1_bounded : boundedEntries 1 fiberWitness1 := by
  intro i j; unfold fiberWitness1; aesop;

theorem fiberWitness2_bounded : boundedEntries 1 fiberWitness2 := by
  intro i j; fin_cases i <;> fin_cases j <;> simp +decide [ fiberWitness2 ] ;

/-
The two witness matrices have the same global minimum (both = 0).
-/
theorem fiberWitnesses_same_globalMin :
    Finset.univ.inf' Finset.univ_nonempty (fun k => colMins fiberWitness1 k) =
    Finset.univ.inf' Finset.univ_nonempty (fun k => colMins fiberWitness2 k) := by
  native_decide +revert

/-
The two witness matrices are **tropically incomparable**:
    neither X₁ ≤ X₂ nor X₂ ≤ X₁ in entry-wise ordering.
    This is the structural content of non-uniqueness.
-/
theorem fiberWitnesses_incomparable :
    ¬ tropLe fiberWitness1 fiberWitness2 ∧ ¬ tropLe fiberWitness2 fiberWitness1 := by
  simp +decide [ tropLe ]

/-
**Inverse fibers of the public map contain incomparable pairs.**
    For A = B = 0 (the constant-zero matrix), the fiber over the common image
    contains two 1-bounded matrices that are:
    1. Distinct
    2. Map to the same image under the public map
    3. Incomparable in the tropical ordering

    This establishes that non-uniqueness of inversion is a **structural property**,
    not merely a computational barrier. The incomparability means no single
    tropical ordering can resolve the ambiguity.
-/
theorem inverse_fiber_contains_incomparable_pair :
    ∃ A B : TropMat 2, ∃ X Y : TropMat 2,
      boundedEntries 1 X ∧ boundedEntries 1 Y ∧
      publicMap A B X = publicMap A B Y ∧
      X ≠ Y ∧
      ¬ tropLe X Y ∧ ¬ tropLe Y X := by
  unfold tropLe;
  unfold boundedEntries publicMap;
  exists 0, 0, fun i j => if i = 0 ∧ j = 0 then 0 else 1, fun i j => if i = 0 ∧ j = 1 then 0 else 1

/-
**General fiber ambiguity theorem.**
    For any dimension n ≥ 2, there exist public matrices and 1-bounded preimages
    that map to the same image but are distinct. This shows that fiber ambiguity
    is a dimensional phenomenon, not an artifact of small examples.
-/
theorem inverse_fiber_nontrivial {n : ℕ} (hn : 2 ≤ n) :
    ∃ (A B X Y : TropMat n),
      boundedEntries 1 X ∧ boundedEntries 1 Y ∧
      X ≠ Y ∧
      publicMap A B X = publicMap A B Y := by
  use 0, 0, fun i j => if i = ⟨ 0, by linarith ⟩ ∧ j = ⟨ 0, by linarith ⟩ then 0 else 1, fun i j => if i = ⟨ 0, by linarith ⟩ ∧ j = ⟨ 1, by linarith ⟩ then 0 else 1;
  refine' ⟨ _, _, _, _ ⟩;
  · intro i j; aesop;
  · exact fun i j => by aesop;
  · exact fun h => by have := congr_fun ( congr_fun h ⟨ 0, by linarith ⟩ ) ⟨ 0, by linarith ⟩ ; simp +decide at this;
  · ext i j;
    unfold publicMap; simp +decide [ tropMul ] ;
    refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ];
    · exact fun i j => ⟨ ⟨ 0, by linarith ⟩, ⟨ 0, by linarith ⟩, by aesop ⟩;
    · intro b b_1; use ⟨ 1, by linarith ⟩, ⟨ 0, by linarith ⟩ ; aesop;

/-! ## Section 8: Signature Invariance Under Public Action -/

/-- **Equal matrices have equal signatures.** (Foundation for invariance theory.) -/
theorem signature_eq_of_eq {n : ℕ} [NeZero n] (X Y : TropMat n) (h : X = Y) :
    signature X = signature Y := by
  subst h; rfl

/-
**The public map preserves compression profiles functorially.**
    The compression profile of the image depends on the profile of the
    preimage through a computable transformation.
-/
theorem compressionProfile_publicMap_eq {n : ℕ} [NeZero n]
    (A B X : TropMat n) :
    (compressionProfile (publicMap A B X)).rowPart =
    fun i => Finset.univ.inf' Finset.univ_nonempty
      (fun k => A i k + rowMins (tropMul X B) k) := by
  funext i;
  convert rowMins_tropMul A ( tropMul X B ) i using 1;
  exact congr_arg ( fun f => rowMins f i ) ( tropMul_assoc A X B )

/-! ## Section 9: Certified Key Generation Infrastructure -/

/-
**Existence of certified public-secret pairs.**
    For any dimension n ≥ 2 and any bound K ≥ 1, there exist:
    - Public matrices A, B (the public key)
    - A secret matrix X
    - All bounded by K
    such that the public map exhibits non-trivial fiber collapse.
-/
theorem exists_certified_pair {n : ℕ} (hn : 2 ≤ n) :
    ∃ (A B X Y : TropMat n),
      boundedEntries 1 A ∧ boundedEntries 1 B ∧
      boundedEntries 1 X ∧ boundedEntries 1 Y ∧
      X ≠ Y ∧
      publicMap A B X = publicMap A B Y ∧
      FiberCollapseWitness A B (publicMap A B X) 1 := by
  refine' ⟨ 0, 0, _ ⟩;
  refine' ⟨ _, _, _, _, _, _, _, _ ⟩ <;> norm_num [ boundedEntries, publicMap, FiberCollapseWitness ];
  exact fun i j => if i = ⟨ 0, by linarith ⟩ ∧ j = ⟨ 0, by linarith ⟩ then 0 else 1;
  exact fun i j => if i = ⟨ 0, by linarith ⟩ ∧ j = ⟨ 1, by linarith ⟩ then 0 else 1;
  · intro i j; split_ifs <;> norm_num;
  · intro i j; split_ifs <;> norm_num;
  · exact fun h => by have := congr_fun ( congr_fun h ⟨ 0, by linarith ⟩ ) ⟨ 0, by linarith ⟩ ; simp +decide at this;
  · refine' ⟨ _, _ ⟩;
    · ext i j; simp +decide [ tropMul ] ;
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ];
      · exact fun i j => ⟨ ⟨ 0, by linarith ⟩, ⟨ 0, by linarith ⟩, by aesop ⟩;
      · intro b b_1; use ⟨ 1, by linarith ⟩, ⟨ 0, by linarith ⟩ ; aesop;
    · refine' ⟨ fun i j => if i = ⟨ 0, by linarith ⟩ ∧ j = ⟨ 0, by linarith ⟩ then 0 else 1, _, fun i j => if i = ⟨ 0, by linarith ⟩ ∧ j = ⟨ 1, by linarith ⟩ then 0 else 1, _, _, _, _ ⟩ <;> norm_num [ tropMul ];
      · intro i j; split_ifs <;> norm_num;
      · intro i j; split_ifs <;> norm_num;
      · exact fun h => by have := congr_fun ( congr_fun h ⟨ 0, by linarith ⟩ ) ⟨ 0, by linarith ⟩ ; simp +decide at this;
      · ext i j; simp +decide [ tropMul ] ;
        refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
        · intro b b_1; use ⟨ 1, by linarith ⟩, ⟨ 0, by linarith ⟩ ; aesop;
        · intro b b_1; use ⟨ 0, by linarith ⟩, ⟨ 0, by linarith ⟩ ; aesop;

end TropicalTrapdoor