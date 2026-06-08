/-
# Cognitive Braids: Braid Group Invariants for Cognitive Process Modeling

This module formalizes braid groups via generator-relation presentations and
develops invariant measures that model cognitive process complexity.

## Mathematical Framework

A braid on n strands is represented as a word in generators σ_i (crossing strand i
over strand i+1) and their inverses σ_i⁻¹. The braid group B_n is the quotient of
the free group on these generators by two families of relations:

1. **Yang-Baxter (far commutativity)**: σ_i σ_j = σ_j σ_i when |i - j| ≥ 2
2. **Braid relation**: σ_i σ_{i+1} σ_i = σ_{i+1} σ_i σ_{i+1}

We define the **exponent sum** (total writhe) as a homomorphism B_n → ℤ and prove
it is invariant under all braid relations. We then build cognitive complexity
measures on top of this invariant.
-/

import Mathlib

/-! ## Braid Word Representation -/

/-- A braid generator: crossing at position `idx` with sign `sign` (true = positive). -/
structure BraidGen where
  idx : ℕ
  sign : Bool
  deriving Repr, DecidableEq

/-- A braid word is a sequence of braid generators. -/
abbrev BraidWord := List BraidGen

/-- The sign of a generator as an integer: +1 for positive, -1 for negative. -/
def BraidGen.signInt (g : BraidGen) : ℤ :=
  if g.sign then 1 else -1

/-- The exponent sum of a braid word: the total algebraic crossing number. -/
def exponentSum' (w : BraidWord) : ℤ :=
  (w.map BraidGen.signInt).sum

/-! ## Braid Relations -/

/-- A single braid relation step. Two braid words are related by one step if
    one can be obtained from the other by applying a braid relation at some position. -/
inductive BraidRelStep : BraidWord → BraidWord → Prop where
  /-- Free cancellation: σ_i σ_i⁻¹ = ε -/
  | cancel (pre suf : BraidWord) (i : ℕ) :
      BraidRelStep (pre ++ [⟨i, true⟩, ⟨i, false⟩] ++ suf) (pre ++ suf)
  /-- Free insertion: ε = σ_i σ_i⁻¹ -/
  | insert (pre suf : BraidWord) (i : ℕ) :
      BraidRelStep (pre ++ suf) (pre ++ [⟨i, true⟩, ⟨i, false⟩] ++ suf)
  /-- Inverse cancellation: σ_i⁻¹ σ_i = ε -/
  | cancel_inv (pre suf : BraidWord) (i : ℕ) :
      BraidRelStep (pre ++ [⟨i, false⟩, ⟨i, true⟩] ++ suf) (pre ++ suf)
  /-- Inverse insertion: ε = σ_i⁻¹ σ_i -/
  | insert_inv (pre suf : BraidWord) (i : ℕ) :
      BraidRelStep (pre ++ suf) (pre ++ [⟨i, false⟩, ⟨i, true⟩] ++ suf)
  /-- Far commutativity: σ_i σ_j = σ_j σ_i when |i - j| ≥ 2 -/
  | far_comm (pre suf : BraidWord) (i j : ℕ) (h : i + 2 ≤ j ∨ j + 2 ≤ i)
      (si sj : Bool) :
      BraidRelStep (pre ++ [⟨i, si⟩, ⟨j, sj⟩] ++ suf)
                   (pre ++ [⟨j, sj⟩, ⟨i, si⟩] ++ suf)
  /-- Braid relation: σ_i σ_{i+1} σ_i = σ_{i+1} σ_i σ_{i+1} -/
  | braid_rel (pre suf : BraidWord) (i : ℕ) (s : Bool) :
      BraidRelStep (pre ++ [⟨i, s⟩, ⟨i+1, s⟩, ⟨i, s⟩] ++ suf)
                   (pre ++ [⟨i+1, s⟩, ⟨i, s⟩, ⟨i+1, s⟩] ++ suf)

/-- Braid equivalence: the reflexive-transitive-symmetric closure of BraidRelStep. -/
inductive BraidEquiv : BraidWord → BraidWord → Prop where
  | refl (w : BraidWord) : BraidEquiv w w
  | step (w₁ w₂ : BraidWord) : BraidRelStep w₁ w₂ → BraidEquiv w₁ w₂
  | symm (w₁ w₂ : BraidWord) : BraidEquiv w₁ w₂ → BraidEquiv w₂ w₁
  | trans (w₁ w₂ w₃ : BraidWord) : BraidEquiv w₁ w₂ → BraidEquiv w₂ w₃ → BraidEquiv w₁ w₃

/-! ## Exponent Sum Properties -/

theorem exponentSum'_append (w₁ w₂ : BraidWord) :
    exponentSum' (w₁ ++ w₂) = exponentSum' w₁ + exponentSum' w₂ := by
  unfold exponentSum'
  simp [List.map_append, List.sum_append]

/-
The exponent sum is preserved by a single braid relation step.
    This is the key technical lemma: each relation preserves the algebraic crossing number.
-/
theorem exponentSum'_braidRelStep_invariant (w₁ w₂ : BraidWord)
    (h : BraidRelStep w₁ w₂) : exponentSum' w₁ = exponentSum' w₂ := by
  rcases h with ( _ | _ | _ | _ | _ | _ );
  all_goals unfold exponentSum'; simp +decide [ List.sum_append ] ;
  all_goals unfold BraidGen.signInt; simp +decide [ add_comm, add_left_comm, add_assoc ] ;

/-
**Main Theorem**: The exponent sum is invariant under braid equivalence.
    This establishes the exponent sum as a well-defined function on the braid group.
-/
theorem exponentSum'_braidEquiv_invariant (w₁ w₂ : BraidWord)
    (h : BraidEquiv w₁ w₂) : exponentSum' w₁ = exponentSum' w₂ := by
  induction h;
  · grind;
  · exact exponentSum'_braidRelStep_invariant _ _ ‹_›;
  · lia;
  · grind

/-! ## Crossing Number and Writhe Bound -/

/-- The crossing number of a braid word. -/
def crossingNumber (w : BraidWord) : ℕ := w.length

/-- The absolute writhe of a braid word. -/
def absWrithe (w : BraidWord) : ℕ := (exponentSum' w).natAbs

/-
The absolute writhe is a lower bound on the crossing number.
    This is a fundamental inequality: you need at least |exponent sum| crossings.
-/
theorem absWrithe_le_crossingNumber (w : BraidWord) :
    absWrithe w ≤ crossingNumber w := by
  -- By definition of `absWrithe`, we have `absWrithe w = (exponentSum' w).natAbs`.
  unfold absWrithe;
  induction w <;> simp_all +decide [ exponentSum', crossingNumber ];
  rename_i k hk ih; cases h : k.sign <;> simp_all +decide [ BraidGen.signInt ] ; omega;
  omega

/-! ## Cognitive Braid Framework -/

/-- A cognitive braid: a braid word annotated with the number of cognitive "strands". -/
structure CognitiveBraid where
  numRegions : ℕ
  word : BraidWord
  valid : ∀ g ∈ word, g.idx + 1 < numRegions

/-- The cognitive complexity of a cognitive braid. -/
noncomputable def cognitiveComplexity (cb : CognitiveBraid) : ℕ :=
  crossingNumber cb.word

/-- The cognitive writhe: the net directionality of information flow. -/
def cognitiveWrithe (cb : CognitiveBraid) : ℤ :=
  exponentSum' cb.word

/-- Two cognitive braids represent equivalent thoughts. -/
def cognitiveEquiv (cb₁ cb₂ : CognitiveBraid) : Prop :=
  cb₁.numRegions = cb₂.numRegions ∧ BraidEquiv cb₁.word cb₂.word

/-- **Theorem**: Cognitive writhe is invariant under cognitive equivalence. -/
theorem cognitiveWrithe_invariant (cb₁ cb₂ : CognitiveBraid)
    (h : cognitiveEquiv cb₁ cb₂) :
    cognitiveWrithe cb₁ = cognitiveWrithe cb₂ := by
  exact exponentSum'_braidEquiv_invariant _ _ h.2

/-! ## Generator Diversity -/

/-- The set of distinct generator indices used in a braid word. -/
def usedGenerators (w : BraidWord) : Finset ℕ :=
  (w.map BraidGen.idx).toFinset

/-- The generator span: number of distinct crossings used. -/
def generatorSpan (w : BraidWord) : ℕ :=
  (usedGenerators w).card

/-
The generator span is bounded by the crossing number.
-/
theorem generatorSpan_le_crossingNumber (w : BraidWord) :
    generatorSpan w ≤ crossingNumber w := by
  exact le_trans ( List.toFinset_card_le _ ) ( by simp +decide [ crossingNumber ] )

/-! ## Canonical Examples -/

/-- The trivial braid: identity element. Represents "no thinking". -/
def trivialBraid (n : ℕ) (_hn : 2 ≤ n) : CognitiveBraid where
  numRegions := n
  word := []
  valid := by simp

/-- The trivial braid has zero writhe. -/
theorem trivialBraid_writhe (n : ℕ) (hn : 2 ≤ n) :
    cognitiveWrithe (trivialBraid n hn) = 0 := by
  simp [cognitiveWrithe, trivialBraid, exponentSum']

/-- The trefoil braid: σ₀ σ₁ σ₀ in B₃. -/
def trefoilBraid : CognitiveBraid where
  numRegions := 3
  word := [⟨0, true⟩, ⟨1, true⟩, ⟨0, true⟩]
  valid := by decide

/-- The trefoil braid has writhe 3. -/
theorem trefoilBraid_writhe :
    cognitiveWrithe trefoilBraid = 3 := by
  native_decide

/-- The figure-eight braid: σ₀ σ₁⁻¹ σ₀ σ₁⁻¹ in B₃. -/
def figureEightBraid : CognitiveBraid where
  numRegions := 3
  word := [⟨0, true⟩, ⟨1, false⟩, ⟨0, true⟩, ⟨1, false⟩]
  valid := by decide

/-- The figure-eight braid has writhe 0 (balanced). -/
theorem figureEightBraid_writhe :
    cognitiveWrithe figureEightBraid = 0 := by
  native_decide

/-! ## Braid Composition -/

/-- Compose two cognitive braids (sequential thought processes). -/
def CognitiveBraid.compose (cb₁ cb₂ : CognitiveBraid)
    (h : cb₁.numRegions = cb₂.numRegions) : CognitiveBraid where
  numRegions := cb₁.numRegions
  word := cb₁.word ++ cb₂.word
  valid := by
    intro g hg
    rw [List.mem_append] at hg
    rcases hg with h₁ | h₂
    · exact cb₁.valid g h₁
    · have := cb₂.valid g h₂; omega

/-- Writhe is additive under composition. -/
theorem writhe_additive (cb₁ cb₂ : CognitiveBraid)
    (h : cb₁.numRegions = cb₂.numRegions) :
    cognitiveWrithe (cb₁.compose cb₂ h) =
      cognitiveWrithe cb₁ + cognitiveWrithe cb₂ := by
  simp [cognitiveWrithe, CognitiveBraid.compose, exponentSum'_append]

/-- Complexity is additive under composition. -/
theorem complexity_additive (cb₁ cb₂ : CognitiveBraid)
    (h : cb₁.numRegions = cb₂.numRegions) :
    cognitiveComplexity (cb₁.compose cb₂ h) =
      cognitiveComplexity cb₁ + cognitiveComplexity cb₂ := by
  simp [cognitiveComplexity, crossingNumber, CognitiveBraid.compose, List.length_append]

/-! ## Braid Inversion and Cognitive Reflection -/

/-- The inverse of a braid generator. -/
def BraidGen.inv (g : BraidGen) : BraidGen :=
  ⟨g.idx, !g.sign⟩

/-- The inverse of a braid word. -/
def BraidWord.inv (w : BraidWord) : BraidWord :=
  (w.map BraidGen.inv).reverse

/-- The sign of an inverse generator is the negation. -/
theorem BraidGen.signInt_inv (g : BraidGen) :
    g.inv.signInt = -g.signInt := by
  simp [BraidGen.inv, BraidGen.signInt]
  cases g.sign <;> simp

/-
The exponent sum of an inverse word is the negation.
    Reversing and inverting a thought negates its information flow.
-/
theorem exponentSum'_inv (w : BraidWord) :
    exponentSum' w.inv = -exponentSum' w := by
  convert congr_arg Neg.neg ?_ using 1;
  rotate_left;
  exact -exponentSum' w.inv;
  · unfold BraidWord.inv exponentSum';
    induction w <;> simp_all +decide [ BraidGen.signInt_inv ];
  · ring

/-- A thought composed with its reflection has zero net information flow. -/
theorem writhe_self_inv (w : BraidWord) :
    exponentSum' (w ++ w.inv) = 0 := by
  rw [exponentSum'_append, exponentSum'_inv]
  omega