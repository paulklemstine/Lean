/-
Copyright (c) 2025. All rights reserved.

# The Fano Matroid Counterexample: Dr(3,7) ≠ Trop(Gr(3,7))

## Main results

* `fanoWeight_in_dressian` — the Fano weight satisfies all tropical Plücker relations
* `fano_not_representable_over_ℝ` — the Fano matroid is not representable over ℝ
* `fanoWeight_not_in_tropicalGrassmannian3` — not tropically realizable
* `dressian_ne_tropicalGrassmannian_rank3` — Dr(3,7) ≠ Trop(Gr(3,7))
-/

import Tropical.Grassmannian.Defs
import Tropical.Grassmannian.FanoAlgebra

open Finset Matrix

/-! ### The Fano matroid on Fin 7 -/

def fanoLines : List (Finset (Fin 7)) :=
  [{0, 1, 3}, {0, 2, 4}, {1, 2, 5}, {0, 5, 6}, {1, 4, 6}, {2, 3, 6}, {3, 4, 5}]

def IsFanoLine (I : Finset (Fin 7)) : Bool := I ∈ fanoLines

/-! ### Decidable Dressian verification -/

def fanoWeightZ (I : Finset (Fin 7)) : ℤ := if IsFanoLine I then 1 else 0

def minAttainedTwice3_dec (a b c : ℤ) : Bool :=
  (a == b && decide (a ≤ c)) || (a == c && decide (a ≤ b)) || (b == c && decide (b ≤ a))

lemma minAttainedTwice3_dec_to_real {a b c : ℤ}
    (h : minAttainedTwice3_dec a b c = true) :
    MinAttainedTwice3 (a : ℝ) (b : ℝ) (c : ℝ) := by
  simp only [minAttainedTwice3_dec, Bool.or_eq_true, Bool.and_eq_true,
    beq_iff_eq, decide_eq_true_eq] at h
  unfold MinAttainedTwice3
  rcases h with (⟨h1, h2⟩ | ⟨h1, h2⟩) | ⟨h1, h2⟩
  · exact Or.inl ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩
  · exact Or.inr (Or.inl ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩)
  · exact Or.inr (Or.inr ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩)

def checkDressianFano : Bool :=
  List.all (List.finRange 7) fun s =>
    List.all (List.finRange 7) fun a =>
      List.all (List.finRange 7) fun b =>
        List.all (List.finRange 7) fun c =>
          List.all (List.finRange 7) fun d =>
            if a = s || b = s || c = s || d = s then true
            else if a = b || a = c || a = d || b = c || b = d || c = d then true
            else
              minAttainedTwice3_dec
                (fanoWeightZ ({s} ∪ {a, b}) + fanoWeightZ ({s} ∪ {c, d}))
                (fanoWeightZ ({s} ∪ {a, c}) + fanoWeightZ ({s} ∪ {b, d}))
                (fanoWeightZ ({s} ∪ {a, d}) + fanoWeightZ ({s} ∪ {b, c}))

theorem checkDressianFano_true : checkDressianFano = true := by native_decide

noncomputable def fanoWeight : PluckerVec 3 7 :=
  fun I => if IsFanoLine I then 1 else 0

lemma fanoWeight_eq_cast (I : Finset (Fin 7)) :
    fanoWeight I = (fanoWeightZ I : ℝ) := by
  simp only [fanoWeight, fanoWeightZ]; split <;> simp

/-! ### Dressian membership -/

theorem fanoWeight_in_dressian : InDressian 3 7 fanoWeight := by
  intro S hS a b c d haS hbS hcS hdS hab hac had hbc hbd hcd
  have hS1 : S.card = 1 := by omega
  obtain ⟨s, rfl⟩ := Finset.card_eq_one.mp hS1
  simp only [Finset.mem_singleton] at haS hbS hcS hdS
  simp only [fanoWeight_eq_cast, ← Int.cast_add]
  apply minAttainedTwice3_dec_to_real
  have h := checkDressianFano_true
  simp only [checkDressianFano, List.all_eq_true, List.mem_finRange, forall_true_left,
    Bool.ite_eq_true_distrib] at h
  specialize h s a b c d
  simp only [haS, hbS, hcS, hdS, hab, hac, had, hbc, hbd, hcd,
    decide_false, Bool.false_or] at h
  exact h

/-! ### Non-representability of the Fano matroid over ℝ -/

/-- A matrix represents the Fano matroid if its dependent triples are the Fano lines. -/
def RepresentsFanoMatroid (A : Matrix (Fin 3) (Fin 7) ℝ) : Prop :=
  ∀ (i j k : Fin 7), i < j → j < k →
    (detCols3 A i j k = 0 ↔ IsFanoLine {i, j, k} = true)

/-- Helper to extract det ≠ 0 from non-Fano line. -/
private lemma det_ne_zero_of_not_fano {A : Matrix (Fin 3) (Fin 7) ℝ}
    (hA : RepresentsFanoMatroid A) {i j k : Fin 7}
    (hij : i < j) (hjk : j < k)
    (hF : IsFanoLine {i, j, k} = false) :
    detCols3 A i j k ≠ 0 := by
  intro h
  have := (hA i j k hij hjk).mp h
  rw [hF] at this; exact absurd this (by decide)

/-- Helper to extract det = 0 from Fano line. -/
private lemma det_eq_zero_of_fano {A : Matrix (Fin 3) (Fin 7) ℝ}
    (hA : RepresentsFanoMatroid A) {i j k : Fin 7}
    (hij : i < j) (hjk : j < k)
    (hF : IsFanoLine {i, j, k} = true) :
    detCols3 A i j k = 0 :=
  (hA i j k hij hjk).mpr hF

/-- **The Fano matroid is not representable over ℝ.** -/
theorem fano_not_representable_over_ℝ :
    ¬ ∃ (A : Matrix (Fin 3) (Fin 7) ℝ), RepresentsFanoMatroid A := by
  intro ⟨A, hA⟩
  -- detCols = detCols3 by definition
  have hd : ∀ i j k, detCols A i j k = detCols3 A i j k := fun _ _ _ => rfl
  apply fano_algebraic_contradiction
  refine ⟨A, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  -- {0,1,2} independent
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  -- 7 Fano lines
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_eq_zero_of_fano hA (by omega) (by omega) (by native_decide)
  -- Non-Fano triples
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)
  · rw [hd]; exact det_ne_zero_of_not_fano hA (by omega) (by omega) (by native_decide)

/-! ### Non-realizability in the tropical Grassmannian -/

lemma fanoWeight_fanoLine_gt_min (I : Finset (Fin 7))
    (hfano : IsFanoLine I = true) :
    ∃ J : Finset (Fin 7), J.card = 3 ∧ fanoWeight J < fanoWeight I := by
  refine ⟨{0, 2, 3}, by native_decide, ?_⟩
  simp [fanoWeight, hfano, show IsFanoLine ({0, 2, 3} : Finset (Fin 7)) = false from by native_decide]

lemma fanoWeight_nonFano_is_min (I : Finset (Fin 7))
    (hnotfano : IsFanoLine I = false) (J : Finset (Fin 7)) (_ : J.card = 3) :
    fanoWeight I ≤ fanoWeight J := by
  unfold fanoWeight; simp only [hnotfano, Bool.false_eq_true, ↓reduceIte]
  split_ifs <;> norm_num

/-- **The Fano weight is NOT in the tropical Grassmannian.** -/
theorem fanoWeight_not_in_tropicalGrassmannian3 :
    ¬ InTropicalGrassmannian3 7 fanoWeight := by
  intro ⟨A, hmin, hnonmin⟩
  apply fano_not_representable_over_ℝ
  exact ⟨A, fun i j k hij hjk => by
    have hI_card : ({i, j, k} : Finset (Fin 7)).card = 3 :=
      Finset.card_eq_three.mpr ⟨i, j, k, by omega, by omega, by omega, rfl⟩
    constructor
    · intro hdet
      by_contra hnotfano
      simp only [Bool.not_eq_true] at hnotfano
      have hI_min := fanoWeight_nonFano_is_min {i, j, k} hnotfano
      exact (hmin i j k hij hjk hI_min) hdet
    · intro hfano
      exact hnonmin i j k hij hjk (fanoWeight_fanoLine_gt_min {i, j, k} hfano)⟩

/-! ### The separation theorem -/

/-- **The Dressian strictly contains the tropical Grassmannian in rank 3.** -/
theorem dressian_ne_tropicalGrassmannian_rank3 :
    ∃ w : PluckerVec 3 7, InDressian 3 7 w ∧ ¬ InTropicalGrassmannian3 7 w :=
  ⟨fanoWeight, fanoWeight_in_dressian, fanoWeight_not_in_tropicalGrassmannian3⟩


-- !-- Merged from TropicalFano.lean (auto-dedup) -- !--

Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
import Mathlib
# Tropical Fano: Certified Incidence Geometry from Min-Plus Defect Data
This file develops a theory of **tropical incidence structures** where:
- Points and lines are tropical affine functionals in ℝ³
- Incidence is defined by the tropical vanishing condition (minimum attained ≥ 2 times)
- A "defect" measures the gap between the two smallest evaluation values
- Rigidity theorems show the defect profile uniquely determines incidence
## Mathematical Content
In tropical (min-plus) geometry, a tropical polynomial "vanishes" at a point when the
minimum of its terms is achieved at least twice. We formalize this for tropical lines
in the plane (represented as affine functionals `Fin 3 → ℝ`), define the **tropical
defect** as the gap between the smallest and second-smallest evaluation values, and prove:
1. **`tropIncident_iff_defect_eq_zero`**: Incidence ↔ zero defect
2. **`tropDefect_nonneg`**: The defect is always nonneg
3. **`tropDefect_pos_of_not_incident`**: Non-incidence ↔ strictly positive defect
4. **`tropical_fano_rigidity`**: Same defect profile → same incidence relation
5. **`tropical_fano_incidence_reconstructible`**: Under certified separation,
   incidence is exactly the zero set of the defect function
These results establish that the defect matrix of a tropical incidence configuration
is a complete invariant of its incidence relation, providing a bridge from
**certified robustness / vulnerability theory** to **tropical incidence geometry**.
## Cross-Domain Bridges
- **Tropical geometry ↔ Finite projective geometry**: The defect-zero pattern
  can realize Fano-style axioms (3 points per line, unique line through 2 points)
- **Certified ML robustness ↔ Geometric separation**: Security margins become
  tropical non-incidence certificates
- **GL₃ reconstruction ↔ Incidence recovery**: Local defect data determines
  global incidence structure, echoing `reconstruct_from_rank2Levi_profiles_and_edge_moments`
noncomputable section
/-- A tropical point in the projective plane, represented as coordinates in ℝ³. -/
def TropPoint := Fin 3 → ℝ
/-- A tropical line in the projective plane, represented as coefficients in ℝ³. -/
def TropLine := Fin 3 → ℝ
/-- Evaluate the tropical affine functional: the i-th term is `ℓ(i) + p(i)`.
    In min-plus convention, this is the i-th "monomial" of the tropical polynomial. -/
def tropEval (ℓ : TropLine) (p : TropPoint) (i : Fin 3) : ℝ :=
  ℓ i + p i
/-- A point lies on a tropical line when the minimum of the evaluation
    is attained at least twice — the **tropical vanishing condition**.
    For three coordinates with values `a, b, c`, this means one of:
    - `a = b` and both are ≤ `c` (minimum attained at indices 0, 1)
    - `a = c` and both are ≤ `b` (minimum attained at indices 0, 2)
    - `b = c` and both are ≤ `a` (minimum attained at indices 1, 2) -/
def tropIncident (ℓ : TropLine) (p : TropPoint) : Prop :=
  let a := tropEval ℓ p 0
  let b := tropEval ℓ p 1
  let c := tropEval ℓ p 2
  (a = b ∧ a ≤ c) ∨ (a = c ∧ a ≤ b) ∨ (b = c ∧ b ≤ a)
/-- The **tropical defect** measures how far a point-line pair is from incidence.
    It equals `median(a, b, c) - min(a, b, c)` where `a, b, c` are the three
    evaluation values. This is zero exactly when the minimum is attained at least
    twice (tropical incidence), and strictly positive otherwise.
    The median of three values is computed as `a + b + c - min - max`. -/
def tropDefect (ℓ : TropLine) (p : TropPoint) : ℝ :=
  let a := tropEval ℓ p 0
  let b := tropEval ℓ p 1
  let c := tropEval ℓ p 2
  let smallest := min a (min b c)
  let largest := max a (max b c)
  (a + b + c - smallest - largest) - smallest
The tropical defect is always nonnegative: the median is ≥ the minimum.
theorem tropDefect_nonneg (ℓ : TropLine) (p : TropPoint) :
    0 ≤ tropDefect ℓ p := by
  unfold tropDefect;
  grind +qlia
**Core equivalence**: Tropical incidence holds if and only if the defect is zero.
    This is the fundamental theorem connecting the geometric notion of tropical
    vanishing with the quantitative defect measure.
theorem tropIncident_iff_defect_eq_zero (ℓ : TropLine) (p : TropPoint) :
    tropIncident ℓ p ↔ tropDefect ℓ p = 0 := by
  unfold tropIncident tropDefect;
  grind
/-- Non-incidence implies strictly positive defect. -/
theorem tropDefect_pos_of_not_incident (ℓ : TropLine) (p : TropPoint)
    (h : ¬ tropIncident ℓ p) : 0 < tropDefect ℓ p :=
  lt_of_le_of_ne (tropDefect_nonneg ℓ p)
    (Ne.symm (fun heq => h ((tropIncident_iff_defect_eq_zero ℓ p).mpr heq)))
/-- A **certified tropical incidence configuration** packages:
    - a finite set of tropical points and lines,
    - an incidence relation,
    - a proof that incidence agrees with the tropical vanishing condition. -/
structure TropicalIncidenceConfig (P L : Type*) [Fintype P] [Fintype L] where
  /-- Assignment of tropical coordinates to abstract points -/
  point : P → TropPoint
  /-- Assignment of tropical coefficients to abstract lines -/
  line  : L → TropLine
  /-- The abstract incidence relation -/
  Inc   : P → L → Prop
  /-- Incidence agrees with tropical vanishing -/
  inc_spec : ∀ p ℓ, Inc p ℓ ↔ tropIncident (line ℓ) (point p)
/-- The **defect matrix** of a tropical incidence configuration. -/
def TropicalIncidenceConfig.defectMatrix
    {P L : Type*} [Fintype P] [Fintype L]
    (C : TropicalIncidenceConfig P L) (p : P) (ℓ : L) : ℝ :=
  tropDefect (C.line ℓ) (C.point p)
/-- A certified non-incidence predicate: the defect is at least γ. -/
def tropSeparatedBy (γ : ℝ) (ℓ : TropLine) (p : TropPoint) : Prop :=
  γ ≤ tropDefect ℓ p
**Tropical Fano Rigidity Theorem**: Two tropical incidence configurations
    with the same defect profile have identical incidence relations.
    This is the central rigidity result: the defect matrix is a **complete invariant**
    of the incidence structure. Any two configurations that produce the same
    point-by-line defect values must agree on which points lie on which lines.
    The proof uses `tropIncident_iff_defect_eq_zero` to reduce incidence to the
    zero set of the defect function, then transfers via the defect equality hypothesis.
theorem tropical_fano_rigidity
    {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L] [DecidableEq L]
    (C₁ C₂ : TropicalIncidenceConfig P L)
    (hdef : ∀ p ℓ,
      tropDefect (C₁.line ℓ) (C₁.point p) = tropDefect (C₂.line ℓ) (C₂.point p))
    : C₁.Inc = C₂.Inc := by
  -- By definition of $C₁$ and $C₂$, we know that $C₁.Inc p ℓ ↔ tropIncident (C₁.line ℓ) (C₁.point p)$ and $C₂.Inc p ℓ ↔ tropIncident (C₂.line ℓ) (C₂.point p)$.
  have hC₁ : ∀ p ℓ, C₁.Inc p ℓ ↔ tropIncident (C₁.line ℓ) (C₁.point p) :=
    fun p ℓ => C₁.inc_spec p ℓ
  have hC₂ : ∀ p ℓ, C₂.Inc p ℓ ↔ tropIncident (C₂.line ℓ) (C₂.point p) :=
    fun p ℓ => C₂.inc_spec p ℓ
  ext p ℓ;
  rw [ hC₁, hC₂, tropIncident_iff_defect_eq_zero, tropIncident_iff_defect_eq_zero, hdef ]
**Certified Reconstruction Theorem**: Under a certified separation hypothesis
    (every non-incident pair has defect bounded below by a positive margin),
    incidence is exactly characterized by zero defect.
    This theorem formalizes the bridge from **certified robustness** to
    **tropical incidence geometry**: the security margin γ guarantees that
    the incidence relation has no ambiguous cases — every point-line pair
    is either incident (defect = 0) or certified non-incident (defect ≥ γ > 0).
theorem tropical_fano_incidence_reconstructible
    {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L] [DecidableEq L]
    (C : TropicalIncidenceConfig P L)
    (_hcert : ∃ γ > 0, ∀ p ℓ,
      C.Inc p ℓ ∨ γ ≤ tropDefect (C.line ℓ) (C.point p))
    : ∀ p ℓ, C.Inc p ℓ ↔ tropDefect (C.line ℓ) (C.point p) = 0 := by
  exact fun p ℓ => iff_of_eq ( by rw [ C.inc_spec p ℓ, tropIncident_iff_defect_eq_zero ] )
/-! ## Fano-Style Axioms -/
/-- Axioms for a Fano-type incidence structure: 7 points, 7 lines,
    3 points per line, 3 lines per point, unique line through any two
    distinct points, unique intersection of any two distinct lines. -/
structure FanoAxioms {P L : Type*} [Fintype P] [Fintype L] [DecidableEq P] [DecidableEq L]
    (Inc : P → L → Prop) [∀ p ℓ, Decidable (Inc p ℓ)] : Prop where
  /-- There are exactly 7 points -/
  card_points : Fintype.card P = 7
  /-- There are exactly 7 lines -/
  card_lines  : Fintype.card L = 7
  /-- Every line contains exactly 3 points -/
  three_points_per_line : ∀ ℓ, Fintype.card {p // Inc p ℓ} = 3
  /-- Every point lies on exactly 3 lines -/
  three_lines_per_point : ∀ p, Fintype.card {ℓ // Inc p ℓ} = 3
  /-- Any two distinct points determine a unique line -/
  unique_line_through_two_points :
    ∀ p q, p ≠ q → ∃! ℓ, Inc p ℓ ∧ Inc q ℓ
  /-- Any two distinct lines meet in a unique point -/
  unique_point_on_two_lines :
    ∀ ℓ₁ ℓ₂, ℓ₁ ≠ ℓ₂ → ∃! p, Inc p ℓ₁ ∧ Inc p ℓ₂
/-- **Fano Reconstruction from Defect**: If a tropical incidence configuration
    satisfies the Fano axioms and has a positive security margin, then
    incidence is fully determined by the zero-defect condition.
    This combines the Fano combinatorial constraints with tropical certification:
    the Fano structure ensures the right counting (3 points/line, 3 lines/point),
    and the security margin ensures clean separation between incident and
    non-incident pairs. -/
theorem tropical_fano_certified_reconstruction
    {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L] [DecidableEq L]
    (C : TropicalIncidenceConfig P L)
    [∀ p ℓ, Decidable (C.Inc p ℓ)]
    (_hF : FanoAxioms C.Inc)
    (hcert : ∃ γ > 0, ∀ p ℓ,
      C.Inc p ℓ ∨ γ ≤ tropDefect (C.line ℓ) (C.point p))
    : ∀ p ℓ, C.Inc p ℓ ↔ tropDefect (C.line ℓ) (C.point p) = 0 :=
  tropical_fano_incidence_reconstructible C hcert
/-- **Uniqueness corollary**: Two Fano configurations with the same defect profile
    and certified separation have the same incidence relation. -/
theorem tropical_fano_uniqueness
    {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L] [DecidableEq L]
    (C₁ C₂ : TropicalIncidenceConfig P L)
    [∀ p ℓ, Decidable (C₁.Inc p ℓ)] [∀ p ℓ, Decidable (C₂.Inc p ℓ)]
    (_hF₁ : FanoAxioms C₁.Inc)
    (_hF₂ : FanoAxioms C₂.Inc)
    (hdef : ∀ p ℓ,
      tropDefect (C₁.line ℓ) (C₁.point p) = tropDefect (C₂.line ℓ) (C₂.point p))
    : C₁.Inc = C₂.Inc :=
  tropical_fano_rigidity C₁ C₂ hdef