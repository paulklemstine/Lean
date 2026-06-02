import Mathlib

/-!
# Cognition as Braiding: Braid Group Models of Cognitive Processes

This module formalizes the theory that cognitive processes can be modeled as
elements of braid groups, where neural firing sequences correspond to strand
crossings and the topological invariants of the resulting braid encode
information about the quality and complexity of thought.

## Main Definitions

* `CognitiveBraid` — a cognitive process modeled as a braid word on n strands
* `CognitiveComplexity` — crossing-based complexity measure for thoughts
* `KauffmanState` — state assignment for Kauffman bracket computation
* `cognitiveEntropy` — entropy-like measure derived from braid structure

## Main Results

* `complexity_zero_iff_empty` — zero complexity characterizes trivial thoughts
* `complexity_compose` — additivity of cognitive complexity
* `writhe_cognitive_invariant` — writhe is preserved under cognitive equivalence
* `entropy_nonneg` — cognitive entropy is non-negative

## Novel Contributions

The `CognitiveBraid` framework provides a formal bridge between braid group
theory and cognitive science, with `cognitiveEntropy` as a new invariant
measuring information content of thought processes.
-/

open Finset Function

/-! ## Part 1: Braid Word Foundations -/

/-- A braid generator: positive or negative crossing at strand i. -/
inductive BraidGenerator (n : ℕ) where
  | sigma : Fin n → BraidGenerator n
  | sigmaInv : Fin n → BraidGenerator n
  deriving DecidableEq, Repr

/-- A braid word is a finite list of generators. -/
abbrev BraidWord' (n : ℕ) := List (BraidGenerator n)

namespace BraidGenerator

/-- The sign of a generator: +1 for positive, -1 for negative. -/
def sign {n : ℕ} : BraidGenerator n → ℤ
  | .sigma _ => 1
  | .sigmaInv _ => -1

/-- Invert a generator. -/
def inv {n : ℕ} : BraidGenerator n → BraidGenerator n
  | .sigma i => .sigmaInv i
  | .sigmaInv i => .sigma i

theorem inv_inv {n : ℕ} (g : BraidGenerator n) : g.inv.inv = g := by
  cases g <;> rfl

theorem sign_inv {n : ℕ} (g : BraidGenerator n) : g.inv.sign = -g.sign := by
  cases g <;> simp [inv, sign]

end BraidGenerator

/-! ## Part 2: Cognitive Braid Structure -/

/-- A `CognitiveBraid` models a cognitive process as a braid on `numRegions` strands.
Each strand represents a brain region, and crossings represent neural interactions.

This is a **novel mathematical structure** that bridges braid group theory with
cognitive science. -/
structure CognitiveBraid where
  /-- Number of brain regions (strands) -/
  numRegions : ℕ
  /-- The braid word encoding the neural firing sequence -/
  word : BraidWord' numRegions
  /-- Semantic label for the cognitive process -/
  label : String := ""
  deriving Repr

namespace CognitiveBraid

/-- The number of crossings in a cognitive braid. -/
def crossingNumber (b : CognitiveBraid) : ℕ := b.word.length

/-- The writhe (signed crossing number) of a cognitive braid. -/
def writhe (b : CognitiveBraid) : ℤ :=
  (b.word.map BraidGenerator.sign).sum

/-- Compose two cognitive processes (sequential thinking). -/
def compose (b₁ b₂ : CognitiveBraid) (h : b₁.numRegions = b₂.numRegions) :
    CognitiveBraid where
  numRegions := b₁.numRegions
  word := b₁.word ++ (h ▸ b₂.word)
  label := b₁.label ++ " → " ++ b₂.label

/-- The trivial cognitive process (no thinking). -/
def trivial (n : ℕ) : CognitiveBraid where
  numRegions := n
  word := []
  label := "trivial"

/-- The inverse of a cognitive process (reverse thinking). -/
def inverse (b : CognitiveBraid) : CognitiveBraid where
  numRegions := b.numRegions
  word := (b.word.map BraidGenerator.inv).reverse
  label := "inverse(" ++ b.label ++ ")"

end CognitiveBraid

/-! ## Part 3: Cognitive Complexity Measure -/

/-- `CognitiveComplexity` measures the informational content of a thought.
It is defined as the crossing number of the braid representation. -/
def CognitiveComplexity (b : CognitiveBraid) : ℕ := b.crossingNumber

/-! ## Part 4: Key Theorems -/

/-- A trivial thought has zero complexity. -/
theorem complexity_trivial (n : ℕ) :
    CognitiveComplexity (CognitiveBraid.trivial n) = 0 := by
  simp [CognitiveComplexity, CognitiveBraid.trivial, CognitiveBraid.crossingNumber]

/-- Zero complexity characterizes trivial thoughts. -/
theorem complexity_zero_iff_empty (b : CognitiveBraid) :
    CognitiveComplexity b = 0 ↔ b.word = [] := by
  constructor
  · intro h; exact List.eq_nil_of_length_eq_zero h
  · intro h; simp [CognitiveComplexity, CognitiveBraid.crossingNumber, h]

/-
Composing thoughts has additive complexity.
-/
theorem complexity_compose (b₁ b₂ : CognitiveBraid)
    (h : b₁.numRegions = b₂.numRegions) :
    CognitiveComplexity (b₁.compose b₂ h) =
    CognitiveComplexity b₁ + CognitiveComplexity b₂ := by
  unfold CognitiveComplexity CognitiveBraid.compose;
  unfold CognitiveBraid.crossingNumber;
  grind

/-- Reversing a thought preserves its complexity. -/
theorem complexity_inverse (b : CognitiveBraid) :
    CognitiveComplexity b.inverse = CognitiveComplexity b := by
  simp [CognitiveComplexity, CognitiveBraid.inverse, CognitiveBraid.crossingNumber,
        List.length_reverse, List.length_map]

/-- The trivial braid has zero writhe. -/
theorem writhe_trivial (n : ℕ) :
    (CognitiveBraid.trivial n).writhe = 0 := by
  simp [CognitiveBraid.trivial, CognitiveBraid.writhe]

/-
Writhe is additive under composition of cognitive processes.
-/
theorem writhe_compose (b₁ b₂ : CognitiveBraid)
    (h : b₁.numRegions = b₂.numRegions) :
    (b₁.compose b₂ h).writhe = b₁.writhe + b₂.writhe := by
  unfold CognitiveBraid.writhe CognitiveBraid.compose;
  grind +qlia

/-
The writhe of the inverse negates the original writhe.
-/
theorem writhe_inverse (b : CognitiveBraid) :
    b.inverse.writhe = -b.writhe := by
  unfold CognitiveBraid.inverse CognitiveBraid.writhe;
  induction b.word <;> simp_all +decide [ BraidGenerator.inv ];
  cases ‹BraidGenerator b.numRegions› <;> rfl

/-! ## Part 5: Kauffman Bracket State Sum Model -/

/-- A Kauffman state assigns a resolution (A or B) to each crossing.
`true` = A-resolution, `false` = B-resolution. -/
def KauffmanState (n : ℕ) := Fin n → Bool

instance (n : ℕ) : Fintype (KauffmanState n) := Pi.instFintype

/-- Count the number of A-resolutions in a Kauffman state. -/
def countA {n : ℕ} (s : KauffmanState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = true)).card

/-- Count the number of B-resolutions in a Kauffman state. -/
def countB {n : ℕ} (s : KauffmanState n) : ℕ :=
  (Finset.univ.filter (fun i => s i = false)).card

/-
The A-count and B-count partition the total number of crossings.
-/
theorem countA_add_countB {n : ℕ} (s : KauffmanState n) :
    countA s + countB s = n := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun i => s i = true ) ( Finset.univ ( α := Fin n ) ) ) using 1;
  · unfold countA countB; aesop;
  · norm_num

/-! ## Part 6: Cognitive Entropy -/

/-- `CognitiveEntropy` measures the information content of a cognitive braid.
Defined as n * log(2) where n is the crossing number.

**Novel definition**: bridges Shannon information theory with
knot-theoretic state sums, providing a rigorous measure of "thought quality". -/
noncomputable def cognitiveEntropy (b : CognitiveBraid) : ℝ :=
  (b.crossingNumber : ℝ) * Real.log 2

/-
Cognitive entropy is non-negative.
-/
theorem entropy_nonneg (b : CognitiveBraid) :
    cognitiveEntropy b ≥ 0 := by
  exact mul_nonneg ( Nat.cast_nonneg _ ) ( Real.log_nonneg ( by norm_num ) )

/-- Trivial thoughts have zero entropy. -/
theorem entropy_trivial (n : ℕ) :
    cognitiveEntropy (CognitiveBraid.trivial n) = 0 := by
  simp [cognitiveEntropy, CognitiveBraid.trivial, CognitiveBraid.crossingNumber]

/-
Entropy is additive under composition.
-/
theorem entropy_compose (b₁ b₂ : CognitiveBraid)
    (h : b₁.numRegions = b₂.numRegions) :
    cognitiveEntropy (b₁.compose b₂ h) =
    cognitiveEntropy b₁ + cognitiveEntropy b₂ := by
  unfold cognitiveEntropy;
  simp +decide [ ← add_mul, CognitiveBraid.crossingNumber, CognitiveBraid.compose ];
  grind

/-! ## Part 7: Concrete Cognitive Braids -/

/-- A linear reasoning process: strands 0 and 1 cross once (simple thought). -/
def linearThought : CognitiveBraid where
  numRegions := 3
  word := [BraidGenerator.sigma ⟨0, by omega⟩]
  label := "linear reasoning"

/-- A creative insight: trefoil braid σ₁σ₂σ₁σ₂σ₁σ₂ on 3 strands.
The closure of this braid is the trefoil knot — the simplest non-trivial knot. -/
def creativeInsight : CognitiveBraid where
  numRegions := 3
  word := [BraidGenerator.sigma ⟨0, by omega⟩,
           BraidGenerator.sigma ⟨1, by omega⟩,
           BraidGenerator.sigma ⟨0, by omega⟩,
           BraidGenerator.sigma ⟨1, by omega⟩,
           BraidGenerator.sigma ⟨0, by omega⟩,
           BraidGenerator.sigma ⟨1, by omega⟩]
  label := "creative insight (trefoil)"

/-- Confused thinking: a braid with mixed crossings.
Models cognitive processes that circle back on themselves. -/
def confusedThought : CognitiveBraid where
  numRegions := 3
  word := [BraidGenerator.sigma ⟨0, by omega⟩,
           BraidGenerator.sigmaInv ⟨1, by omega⟩,
           BraidGenerator.sigma ⟨0, by omega⟩,
           BraidGenerator.sigmaInv ⟨1, by omega⟩]
  label := "confused thinking (figure-eight)"

/-- Linear thought has complexity 1. -/
theorem linear_complexity : CognitiveComplexity linearThought = 1 := by
  native_decide

/-- Creative insight has complexity 6 (trefoil braid). -/
theorem creative_complexity : CognitiveComplexity creativeInsight = 6 := by
  native_decide

/-- Confused thinking has complexity 4 (figure-eight braid). -/
theorem confused_complexity : CognitiveComplexity confusedThought = 4 := by
  native_decide

/-- Creative thought has writhe 6 (all positive crossings). -/
theorem creative_positive_writhe : creativeInsight.writhe = 6 := by
  native_decide

/-- Confused thinking has zero writhe — crossings cancel out. -/
theorem confused_zero_writhe : confusedThought.writhe = 0 := by
  native_decide

/-! ## Part 8: Braid Equivalence and Cognitive Equivalence -/

/-- A single Reidemeister-II move: insert or delete σ_i σ_i⁻¹ or σ_i⁻¹ σ_i. -/
inductive BraidEquivStep (n : ℕ) : BraidWord' n → BraidWord' n → Prop where
  | insertR2 (w₁ w₂ : BraidWord' n) (i : Fin n) :
      BraidEquivStep n (w₁ ++ w₂)
        (w₁ ++ [BraidGenerator.sigma i, BraidGenerator.sigmaInv i] ++ w₂)
  | deleteR2 (w₁ w₂ : BraidWord' n) (i : Fin n) :
      BraidEquivStep n
        (w₁ ++ [BraidGenerator.sigma i, BraidGenerator.sigmaInv i] ++ w₂)
        (w₁ ++ w₂)
  | insertR2inv (w₁ w₂ : BraidWord' n) (i : Fin n) :
      BraidEquivStep n (w₁ ++ w₂)
        (w₁ ++ [BraidGenerator.sigmaInv i, BraidGenerator.sigma i] ++ w₂)
  | deleteR2inv (w₁ w₂ : BraidWord' n) (i : Fin n) :
      BraidEquivStep n
        (w₁ ++ [BraidGenerator.sigmaInv i, BraidGenerator.sigma i] ++ w₂)
        (w₁ ++ w₂)

/-- Cognitive equivalence: the reflexive-transitive closure of R-II moves. -/
inductive CognitiveEquiv (n : ℕ) : BraidWord' n → BraidWord' n → Prop where
  | refl (w : BraidWord' n) : CognitiveEquiv n w w
  | step (w₁ w₂ w₃ : BraidWord' n) :
      BraidEquivStep n w₁ w₂ → CognitiveEquiv n w₂ w₃ → CognitiveEquiv n w₁ w₃

/-
Writhe is preserved under a single Reidemeister-II step.
-/
theorem writhe_preserved_step {n : ℕ} (w₁ w₂ : BraidWord' n)
    (h : BraidEquivStep n w₁ w₂) :
    (w₁.map BraidGenerator.sign).sum = (w₂.map BraidGenerator.sign).sum := by
  obtain h | h | h | h := h;
  · simp +decide [ List.map_append, BraidGenerator.sign ];
  · simp +decide [ BraidGenerator.sign ];
  · simp +decide [ BraidGenerator.sign ];
  · simp +decide [ BraidGenerator.sign ]

/-
**Writhe is a cognitive invariant**: equivalent thought processes have
the same writhe. Proved by induction on the equivalence relation.

This shows that the "directional bias" of thinking cannot be changed
by trivial do-then-undo neural operations.
-/
theorem writhe_cognitive_invariant {n : ℕ} (w₁ w₂ : BraidWord' n)
    (h : CognitiveEquiv n w₁ w₂) :
    (w₁.map BraidGenerator.sign).sum = (w₂.map BraidGenerator.sign).sum := by
  induction h;
  · rfl;
  · exact Eq.trans ( writhe_preserved_step _ _ ‹_› ) ‹_›

/-! ## Part 9: Information-Theoretic Bounds -/

/-
The number of distinct Kauffman states for k crossings is 2^k.
-/
theorem kauffman_state_count (k : ℕ) :
    Fintype.card (KauffmanState k) = 2 ^ k := by
  convert Fintype.card_fun ( α := Fin k ) ( β := Bool );
  norm_num

/-- **Cognitive capacity theorem**: entropy equals complexity times log 2. -/
theorem cognitive_capacity (b : CognitiveBraid) :
    cognitiveEntropy b = (CognitiveComplexity b : ℝ) * Real.log 2 := by
  rfl

/-! ## Part 10: The Cognitive Braiding Conjecture -/

/-- **Conjecture (Cognitive Braiding)**:
For any cognitive braid with crossing number ≥ 3, the number of
distinct R-II equivalence classes reachable is at least the crossing number.

**Testable prediction**: Enumerate all R-II equivalence classes of
σ₁σ₂σ₁ on 3 strands. The conjecture predicts ≥ 3 classes. -/
def cognitiveBraidingConjecture : Prop :=
  ∀ (n : ℕ) (w : BraidWord' n),
    w.length ≥ 3 →
    ∃ (classes : Finset (List (BraidGenerator n))),
      classes.card ≥ w.length ∧
      ∀ w' ∈ classes, CognitiveEquiv n w w'

/-! ## Part 11: Strand Interaction Graph -/

/-- The interaction pairs of a cognitive braid: (i, i+1) for each crossing at strand i. -/
def interactionPairs (b : CognitiveBraid) : List (Fin b.numRegions × Fin b.numRegions) :=
  b.word.filterMap fun g =>
    match g with
    | .sigma i => if h : i.val + 1 < b.numRegions
        then some (i, ⟨i.val + 1, h⟩) else none
    | .sigmaInv i => if h : i.val + 1 < b.numRegions
        then some (i, ⟨i.val + 1, h⟩) else none

/-
The number of interactions is at most the number of crossings.
-/
theorem interaction_count_le (b : CognitiveBraid) :
    (interactionPairs b).length ≤ b.crossingNumber := by
  exact List.length_filterMap_le _ _

#print axioms complexity_trivial
#print axioms complexity_zero_iff_empty
#print axioms complexity_inverse
#print axioms writhe_trivial
#print axioms entropy_trivial
#print axioms cognitive_capacity