/-
# Persistent Stable Homotopy Detection via Framed Flow Categories

This module defines the core structures for persistent homology detection
of stable homotopy information through finite combinatorial flow models.

## Main Definitions
- `FinFilteredChainComplex`: finite filtered 2-term chain complex over ℤ
- `PersistenceFaithfulFlowModel`: combinatorial surrogate for a framed flow category
- `restrictedDiff`: differential restricted to a filtration sublevel
- `numGen0AtFilt`: generator count at filtration sublevel
- `flowToComplex`: functorial construction from flow model to filtered complex

## Main Results
- `sameRanks_imp_sameEuler`: same graded ranks imply same Euler characteristic
- `examples_sameGradedRanks`: the separation examples have same graded ranks
- `examples_same_gen0_profile`: same generator counts at every filtration level
- `restrictedDiff_C_ne_D_at_2`: the restricted differentials differ at filtration 2
- `numGen0AtFilt_mono`: generator counts are monotone in filtration
-/

import Mathlib

/-! ## Filtered Chain Complexes -/

/-- A finite filtered 2-term chain complex over ℤ: C₁ →d→ C₀.
Generators are indexed by `Fin gen0` (degree 0) and `Fin gen1` (degree 1),
each equipped with a filtration level in `ℕ`. The differential respects filtration:
if `diff i j ≠ 0` then the target generator `i` has filtration ≤ that of source `j`. -/
structure FinFilteredChainComplex where
  /-- Number of degree-0 generators -/
  gen0 : ℕ
  /-- Number of degree-1 generators -/
  gen1 : ℕ
  /-- Filtration level of each degree-0 generator -/
  filt0 : Fin gen0 → ℕ
  /-- Filtration level of each degree-1 generator -/
  filt1 : Fin gen1 → ℕ
  /-- Differential matrix: d(j) = Σᵢ diff(i,j) · eᵢ -/
  diff : Fin gen0 → Fin gen1 → ℤ
  /-- Filtration compatibility of the differential -/
  diff_filt : ∀ i j, diff i j ≠ 0 → filt0 i ≤ filt1 j

/-! ## Coarse Invariants -/

/-- Two complexes have the same graded ranks. -/
def SameGradedRanks (C D : FinFilteredChainComplex) : Prop :=
  C.gen0 = D.gen0 ∧ C.gen1 = D.gen1

/-- Euler characteristic of a 2-term chain complex. -/
def eulerChar (C : FinFilteredChainComplex) : ℤ :=
  (C.gen0 : ℤ) - (C.gen1 : ℤ)

/-- Two complexes have the same Euler characteristic. -/
def SameEulerCharacteristic (C D : FinFilteredChainComplex) : Prop :=
  eulerChar C = eulerChar D

/-
Same graded ranks imply same Euler characteristic.
-/
theorem sameRanks_imp_sameEuler {C D : FinFilteredChainComplex}
    (h : SameGradedRanks C D) : SameEulerCharacteristic C D := by
  obtain ⟨h_gen0, h_gen1⟩ := h; unfold SameEulerCharacteristic eulerChar; aesop;

/-! ## Restricted Differential -/

/-- The differential matrix restricted to generators at filtration ≤ f,
with entries zeroed out when either the row or column generator exceeds filtration f.
This is the differential of the subcomplex F_f C. -/
def restrictedDiff (C : FinFilteredChainComplex) (f : ℕ) :
    Matrix (Fin C.gen0) (Fin C.gen1) ℤ :=
  Matrix.of fun i j =>
    if C.filt0 i ≤ f ∧ C.filt1 j ≤ f then C.diff i j else 0

/-
Nonzero entries of the restricted differential imply filtration bounds.
-/
theorem restrictedDiff_entries (C : FinFilteredChainComplex) (f : ℕ)
    (i : Fin C.gen0) (j : Fin C.gen1) :
    restrictedDiff C f i j ≠ 0 → C.filt0 i ≤ f ∧ C.filt1 j ≤ f := by
  unfold restrictedDiff; aesop;

/-
Monotonicity: nonzero entries at filtration f persist at filtration g ≥ f
with the same value.
-/
theorem restrictedDiff_mono (C : FinFilteredChainComplex) {f g : ℕ} (hfg : f ≤ g)
    (i : Fin C.gen0) (j : Fin C.gen1) :
    restrictedDiff C f i j ≠ 0 → restrictedDiff C f i j = restrictedDiff C g i j := by
  simp [restrictedDiff];
  grind

/-! ## Generator Counts -/

/-- Count of degree-0 generators at filtration ≤ f. -/
def numGen0AtFilt (C : FinFilteredChainComplex) (f : ℕ) : ℕ :=
  (Finset.univ.filter fun i : Fin C.gen0 => C.filt0 i ≤ f).card

/-
Generator count is monotone in filtration level.
-/
theorem numGen0AtFilt_mono (C : FinFilteredChainComplex) {f g : ℕ} (hfg : f ≤ g) :
    numGen0AtFilt C f ≤ numGen0AtFilt C g := by
  exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) hfg ⟩

/-! ## Persistence-Faithful Flow Models -/

/-- A persistence-faithful flow model: a finite graded set with filtration
and signed incidence data. Combinatorial surrogate for a framed flow category. -/
structure PersistenceFaithfulFlowModel where
  /-- Number of objects at grade 0 -/
  numGrade0 : ℕ
  /-- Number of objects at grade 1 -/
  numGrade1 : ℕ
  /-- Filtration weight on grade-0 objects -/
  weight0 : Fin numGrade0 → ℕ
  /-- Filtration weight on grade-1 objects -/
  weight1 : Fin numGrade1 → ℕ
  /-- Signed incidence count: from grade 1 to grade 0 -/
  incidence : Fin numGrade0 → Fin numGrade1 → ℤ
  /-- Filtration monotonicity -/
  incidence_filt : ∀ i j, incidence i j ≠ 0 → weight0 i ≤ weight1 j

/-- Construct a filtered chain complex from a flow model.
This is the functorial assignment FlowModel ↦ FilteredChainComplex. -/
def flowToComplex (X : PersistenceFaithfulFlowModel) : FinFilteredChainComplex where
  gen0 := X.numGrade0
  gen1 := X.numGrade1
  filt0 := X.weight0
  filt1 := X.weight1
  diff := X.incidence
  diff_filt := X.incidence_filt

/-- The flowToComplex construction preserves graded ranks. -/
theorem flowToComplex_gen0 (X : PersistenceFaithfulFlowModel) :
    (flowToComplex X).gen0 = X.numGrade0 := rfl

theorem flowToComplex_gen1 (X : PersistenceFaithfulFlowModel) :
    (flowToComplex X).gen1 = X.numGrade1 := rfl

/-! ## The Separation Example

We construct two explicit filtered chain complexes C and D that have
identical coarse invariants but different persistent structure.

### Construction

Both complexes have:
- 3 generators in degree 0: a (filt 0), b (filt 1), c (filt 2)
- 1 generator in degree 1: e (filt 2)

Complex C: d(e) = b - a  (kills the class born at filtration 1)
Complex D: d(e) = c - a  (kills the class born at filtration 2)

Both have the same graded ranks (3, 1), Euler characteristic (2),
and total homology (H₀ ≅ ℤ², H₁ = 0).

### Persistent distinction

For C: at filtration 1, H₀(F₁) = ℤ{a,b} ≅ ℤ². The differential
d(e) = b - a arrives at filtration 2, killing one class. So the
image of H₀(F₁) → H₀(F₂) has rank 1: the class [b] = [a] collapses.

For D: at filtration 1, H₀(F₁) = ℤ{a,b} ≅ ℤ². The differential
d(e) = c - a identifies c with a but leaves b independent. The
image of H₀(F₁) → H₀(F₂) has rank 2: both [a] and [b] survive.

This is the persistence separation: β₀^{1,2}(C) = 1 ≠ 2 = β₀^{1,2}(D).
-/

/-- Example complex C: d(e) = b - a. The 1-cycle kills the filtration-1 class. -/
def exampleC : FinFilteredChainComplex where
  gen0 := 3
  gen1 := 1
  filt0 := ![0, 1, 2]
  filt1 := ![2]
  diff := !![(-1); (1); (0)]
  diff_filt := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons]

/-- Example complex D: d(e) = c - a. The 1-cycle kills the filtration-2 class. -/
def exampleD : FinFilteredChainComplex where
  gen0 := 3
  gen1 := 1
  filt0 := ![0, 1, 2]
  filt1 := ![2]
  diff := !![(-1); (0); (1)]
  diff_filt := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons]

/-
The two example complexes have the same graded ranks.
-/
theorem examples_sameGradedRanks : SameGradedRanks exampleC exampleD := by
  exact ⟨ rfl, rfl ⟩

/-
The two example complexes have the same Euler characteristic.
-/
theorem examples_sameEulerChar : SameEulerCharacteristic exampleC exampleD := by
  exact sub_eq_sub_iff_add_eq_add.mpr ( by norm_cast )

/-
Generator profile agreement: for every filtration level f, the two complexes
have the same number of degree-0 generators at filtration ≤ f.
-/
theorem examples_same_gen0_profile :
    ∀ f, numGen0AtFilt exampleC f = numGen0AtFilt exampleD f := by
  intro f; unfold numGen0AtFilt; simp +decide [ exampleC, exampleD ] ;

/-
At filtration 1, both restricted differentials are zero
(the degree-1 generator has filtration 2 > 1).
-/
theorem restrictedDiff_C_at_1 :
    restrictedDiff exampleC 1 = 0 := by
  native_decide +revert

theorem restrictedDiff_D_at_1 :
    restrictedDiff exampleD 1 = 0 := by
  native_decide +revert

/-
At filtration 2, the restricted differentials differ. This is the key
computation witnessing the persistence separation.
-/
theorem restrictedDiff_C_at_2 :
    restrictedDiff exampleC 2 = !![(-1); (1); (0)] := by
  native_decide

theorem restrictedDiff_D_at_2 :
    restrictedDiff exampleD 2 = !![(-1); (0); (1)] := by
  simp_all +decide [ restrictedDiff, Matrix ]

/-
**Main Separation Theorem (Differential Level)**:
The restricted differentials at filtration 2 distinguish the two complexes,
despite identical graded ranks and generator profiles.
-/
theorem restrictedDiff_C_ne_D_at_2 :
    restrictedDiff exampleC 2 ≠ restrictedDiff exampleD 2 := by
  native_decide +revert

/-! ## Ladder Flow Model Family

The "ladder" family parameterized by k creates a series of delayed cancellation
patterns, making the persistent profile progressively richer.

For each k, the ladder model has:
- Grade 0: k+1 generators with filtrations 0, 1, 2, ..., k
- Grade 1: k generators with filtrations 1, 2, ..., k
- d(eⱼ) = gⱼ₊₁ - g₀ for j = 0, ..., k-1

Each differential connects the base generator g₀ (filt 0) to a new generator
gⱼ₊₁ at a higher filtration level, creating k independent cancellation events
at different filtration times. -/

/-- The ladder flow model of depth k. -/
def ladderFlowModel (k : ℕ) : PersistenceFaithfulFlowModel where
  numGrade0 := k + 1
  numGrade1 := k
  weight0 := fun i => i.val
  weight1 := fun j => j.val + 1
  incidence := fun i j =>
    if i.val = 0 then -1
    else if i.val = j.val + 1 then 1
    else 0
  incidence_filt := by
    intro i j hij
    split_ifs at hij with h1 h2
    · omega
    · omega
    · contradiction

/-- The ladder flow model at depth k produces a valid filtered chain complex. -/
def ladderComplex (k : ℕ) : FinFilteredChainComplex :=
  flowToComplex (ladderFlowModel k)

/-- The ladder complex at depth k has k+1 degree-0 generators. -/
theorem ladderComplex_gen0 (k : ℕ) : (ladderComplex k).gen0 = k + 1 := rfl

/-- The ladder complex at depth k has k degree-1 generators. -/
theorem ladderComplex_gen1 (k : ℕ) : (ladderComplex k).gen1 = k := rfl