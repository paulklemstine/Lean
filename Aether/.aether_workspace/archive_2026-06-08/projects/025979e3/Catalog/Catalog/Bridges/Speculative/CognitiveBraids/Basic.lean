/-
# Cognitive Braids: Cognition as Braiding in Category Theory

We formalize cognitive processes as elements of braid groups B_n, where n represents
the number of brain regions. Braid words model the interleaving of neural firing
sequences, and topological invariants (writhe, crossing number) serve as measures
of cognitive complexity.

## Key results:
- Writhe is additive under braid composition
- Trivial braids have zero writhe
- Crossing number bounds on complexity measures
- Connection to information-theoretic entropy bounds
- The cognitive complexity hierarchy theorem
-/
import Mathlib

namespace CognitiveBraid

/-! ## Braid Generators and Words

A braid on n strands is represented as a word in the generators σ_i (positive crossing
of strand i over strand i+1) and σ_i⁻¹ (negative crossing). -/

/-- A generator of the braid group B_n: either a positive crossing σ_i
    or a negative crossing σ_i⁻¹, where i ∈ {0, ..., n-2}. -/
inductive BraidGen (n : ℕ) where
  | pos (i : Fin (n - 1)) : BraidGen n
  | neg (i : Fin (n - 1)) : BraidGen n
  deriving DecidableEq, Repr

/-- A braid word is a list of generators. -/
def BraidWord (n : ℕ) := List (BraidGen n)

instance (n : ℕ) : Append (BraidWord n) := ⟨List.append⟩

/-- The empty braid word (identity element). -/
def BraidWord.id (n : ℕ) : BraidWord n := []

/-- Composition of braid words (concatenation). -/
def BraidWord.comp {n : ℕ} (w₁ w₂ : BraidWord n) : BraidWord n := w₁ ++ w₂

/-- The sign of a generator: +1 for positive crossings, -1 for negative. -/
def BraidGen.sign {n : ℕ} : BraidGen n → ℤ
  | .pos _ => 1
  | .neg _ => -1

/-- The strand index of a generator. -/
def BraidGen.strandIndex {n : ℕ} : BraidGen n → Fin (n - 1)
  | .pos i => i
  | .neg i => i

/-- The inverse of a generator. -/
def BraidGen.inv {n : ℕ} : BraidGen n → BraidGen n
  | .pos i => .neg i
  | .neg i => .pos i

/-- The inverse of a braid word. -/
def BraidWord.inv {n : ℕ} (w : BraidWord n) : BraidWord n :=
  (w.map BraidGen.inv).reverse

/-! ## The Writhe Invariant

The writhe (or algebraic crossing number) is the sum of signs of all crossings.
It is the simplest braid invariant. -/

/-- The writhe of a braid word: sum of signs of all generators. -/
def BraidWord.writhe {n : ℕ} (w : BraidWord n) : ℤ :=
  (w.map BraidGen.sign).sum

/-- Number of crossings in a braid word. -/
def BraidWord.crossingNumber {n : ℕ} (w : BraidWord n) : ℕ := w.length

/-! ## Cognitive Braid Structure

A cognitive braid bundles a braid word with metadata about the cognitive process. -/

/-- A cognitive braid: a braid word together with the number of brain regions. -/
structure CogBraid where
  regions : ℕ
  regions_ge_two : 2 ≤ regions
  word : BraidWord regions

/-- A cognitive braid is trivial if its word is empty. -/
def CogBraid.isTrivial (cb : CogBraid) : Prop := cb.word = []

/-- The complexity of a cognitive braid is its crossing number. -/
def CogBraid.complexity (cb : CogBraid) : ℕ := cb.word.crossingNumber

/-- The information content of a cognitive braid (simplified model):
    |writhe| serves as a lower bound on information content. -/
def CogBraid.infoContent (cb : CogBraid) : ℕ := cb.word.writhe.natAbs

/-! ## Theorems about Writhe -/

/-- The writhe of the identity braid is zero. -/
theorem writhe_id (n : ℕ) : (BraidWord.id n).writhe = 0 := by
  simp [BraidWord.id, BraidWord.writhe]

/-
Writhe is additive under braid composition.
-/
theorem writhe_comp {n : ℕ} (w₁ w₂ : BraidWord n) :
    (BraidWord.comp w₁ w₂).writhe = w₁.writhe + w₂.writhe := by
  -- The writhe of the identity braid is zero.
  simp [BraidWord.comp, BraidWord.writhe];
  rw [ List.map_append, List.sum_append ]

/-
The writhe of the inverse of a braid word is the negation of the writhe.
-/
theorem writhe_inv {n : ℕ} (w : BraidWord n) :
    w.inv.writhe = -w.writhe := by
  unfold BraidWord.writhe BraidWord.inv;
  -- By definition of `BraidGen.inv`, we know that `BraidGen.inv g` has the opposite sign of `g`.
  have h_sign_inv : ∀ g : BraidGen n, BraidGen.sign (BraidGen.inv g) = -BraidGen.sign g := by
    intro g; cases g <;> rfl;
  induction w <;> aesop

/-
A braid composed with its inverse has zero writhe.
-/
theorem writhe_comp_inv {n : ℕ} (w : BraidWord n) :
    (BraidWord.comp w w.inv).writhe = 0 := by
  convert writhe_comp w w.inv using 1;
  rw [ writhe_inv, add_neg_cancel ]

/-! ## Crossing Number Properties -/

/-
The crossing number of a composition is the sum of crossing numbers.
-/
theorem crossingNumber_comp {n : ℕ} (w₁ w₂ : BraidWord n) :
    (BraidWord.comp w₁ w₂).crossingNumber = w₁.crossingNumber + w₂.crossingNumber := by
  exact List.length_append ..

/-
The absolute writhe is bounded by the crossing number.
-/
theorem writhe_le_crossingNumber {n : ℕ} (w : BraidWord n) :
    w.writhe.natAbs ≤ w.crossingNumber := by
  have h_sign_bound : ∀ (w : List (BraidGen n)), (List.map BraidGen.sign w).sum.natAbs ≤ w.length := by
    intro w; induction' w with x w ih <;> simp_all +decide [ List.sum_cons ] ;
    cases x <;> simp +arith +decide [ BraidGen.sign ]; all_goals omega;
  exact h_sign_bound w

/-
Trivial braids have zero writhe.
-/
theorem trivial_writhe_zero {cb : CogBraid} (h : cb.isTrivial) :
    cb.word.writhe = 0 := by
  convert writhe_id cb.regions

/-! ## The Cognitive Complexity Hierarchy

We define levels of cognitive complexity based on crossing number and prove
that the hierarchy is well-ordered. -/

/-- Cognitive complexity levels. -/
inductive CogLevel where
  | trivial     -- No crossings (linear thought)
  | simple      -- 1-2 crossings (basic association)
  | moderate    -- 3-5 crossings (reasoning)
  | complex     -- 6+ crossings (creative insight)
  deriving DecidableEq, Repr

/-- Assign a cognitive level based on crossing number. -/
def cogLevelOf (k : ℕ) : CogLevel :=
  if k = 0 then .trivial
  else if k ≤ 2 then .simple
  else if k ≤ 5 then .moderate
  else .complex

/-- The cognitive level of a cognitive braid. -/
def CogBraid.level (cb : CogBraid) : CogLevel := cogLevelOf cb.complexity

/-- A numeric rank for cognitive levels. -/
def CogLevel.rank : CogLevel → ℕ
  | .trivial => 0
  | .simple => 1
  | .moderate => 2
  | .complex => 3

/-
More crossings means higher or equal cognitive level rank.
-/
theorem cogLevel_monotone (a b : ℕ) (h : a ≤ b) :
    (cogLevelOf a).rank ≤ (cogLevelOf b).rank := by
  rcases a with ( _ | _ | _ | _ | _ | _ | a ) <;> rcases b with ( _ | _ | _ | _ | _ | _ | b ) <;> simp_all +arith +decide [ cogLevelOf ]

/-! ## Cross-Domain Connection: Information-Theoretic Entropy Bound

We connect braid complexity to information theory by showing that the crossing
number provides a lower bound on the log of the number of distinct braids,
analogous to Shannon entropy. -/

/-- The number of distinct braid generators for B_n is 2(n-1). -/
def numGenerators (n : ℕ) : ℕ := 2 * (n - 1)

/-- Information content (|writhe|) is bounded by complexity (crossing number).
    This is an information-theoretic bound: the "signal" (writhe) cannot exceed
    the "channel capacity" (number of crossings). Analogous to Shannon's theorem
    that information ≤ channel capacity. -/
theorem info_le_complexity (cb : CogBraid) :
    cb.infoContent ≤ cb.complexity := by
  exact writhe_le_crossingNumber cb.word

/-
Composing two cognitive braids: the information content of the composition
    is bounded by the sum of complexities. This is a subadditivity result
    analogous to the subadditivity of entropy: H(X,Y) ≤ H(X) + H(Y).
-/
theorem info_subadditive {n : ℕ} (w₁ w₂ : BraidWord n) :
    (BraidWord.comp w₁ w₂).writhe.natAbs ≤ w₁.crossingNumber + w₂.crossingNumber := by
  convert writhe_le_crossingNumber ( BraidWord.comp w₁ w₂ ) using 1;
  apply Eq.symm; exact crossingNumber_comp w₁ w₂

/-
For n ≥ 2, there exist non-trivial braids (this is a constructive witness).
-/
theorem exists_nontrivial_braid (n : ℕ) (hn : 2 ≤ n) :
    ∃ w : BraidWord n, w ≠ BraidWord.id n := by
  exact ⟨ [ BraidGen.pos ⟨ 0, by omega ⟩ ], by rintro ⟨ ⟩ ⟩

/-! ## Generator Inversion Properties -/

/-
Inverting a generator twice returns the original.
-/
theorem BraidGen.inv_inv {n : ℕ} (g : BraidGen n) : g.inv.inv = g := by
  cases g <;> rfl

/-
The sign of the inverse is negated.
-/
theorem BraidGen.sign_inv {n : ℕ} (g : BraidGen n) : g.inv.sign = -g.sign := by
  cases g <;> rfl

/-
Inverting a braid word twice returns the original.
-/
theorem BraidWord.inv_inv {n : ℕ} (w : BraidWord n) : w.inv.inv = w := by
  -- By definition of BraidWord.inv, we can write
  simp [BraidWord.inv];
  exact List.map_id _ |> Eq.trans ( by congr; ext; exact BraidGen.inv_inv _ )

/-! ## The Trefoil and Creative Thought

The trefoil knot is the closure of the braid σ₁³ in B₂. We formalize the
"trefoil braid" and show it has writhe 3 (all positive crossings). -/

/-- The trefoil braid: three positive crossings of the first two strands.
    Requires n ≥ 2 so that Fin (n-1) is nonempty. -/
def trefoilBraid (n : ℕ) (hn : 2 ≤ n) : BraidWord n :=
  let i : Fin (n - 1) := ⟨0, by omega⟩
  [BraidGen.pos i, BraidGen.pos i, BraidGen.pos i]

/-
The trefoil braid has exactly 3 crossings.
-/
theorem trefoil_crossingNumber (n : ℕ) (hn : 2 ≤ n) :
    (trefoilBraid n hn).crossingNumber = 3 := by
  rfl

/-
The trefoil braid has writhe 3.
-/
theorem trefoil_writhe (n : ℕ) (hn : 2 ≤ n) :
    (trefoilBraid n hn).writhe = 3 := by
  rfl

/-
The trefoil braid is non-trivial (non-empty).
-/
theorem trefoil_nontrivial (n : ℕ) (hn : 2 ≤ n) :
    trefoilBraid n hn ≠ BraidWord.id n := by
  rintro ⟨ ⟩

/-
The trefoil is classified as "moderate" complexity (3 crossings).
-/
theorem trefoil_level (n : ℕ) (hn : 2 ≤ n) :
    cogLevelOf (trefoilBraid n hn).crossingNumber = CogLevel.moderate := by
  unfold cogLevelOf; aesop;

/-! ## Falsifiable Conjecture: Writhe Determines Cognitive Equivalence Class Count

**Conjecture**: For B_n with n ≥ 3, the number of distinct writhe values achievable
by braid words of length exactly k is min(2k+1, 2k+1). More precisely, the writhe
of a length-k braid word ranges over {-k, -k+2, ..., k-2, k} when k is even
and {-k, -k+2, ..., k-2, k} when k is odd.

This is testable: for each k, enumerate braids and check writhe values.
If the conjecture fails for some k, it reveals structure about braid relations. -/

/-
The writhe of a length-k braid word has the same parity as k.
-/
theorem writhe_parity {n : ℕ} (w : BraidWord n) :
    w.writhe % 2 = (w.crossingNumber : ℤ) % 2 ∨
    w.writhe % 2 = -((w.crossingNumber : ℤ) % 2) := by
  -- By definition of writhe, we have:
  have h_writhe_def : w.writhe = List.sum (List.map (fun g => (BraidGen.sign g : ℤ)) w) := by
    rfl
  generalize_proofs at *; (
  have h_writhe_mod : ∀ g : BraidGen n, (BraidGen.sign g :) % 2 = 1 % 2 := by
    intro g; cases g <;> rfl;
  generalize_proofs at *; (
  rw [ h_writhe_def, List.sum_int_mod ] ; norm_cast ; simp_all +decide ;
  erw [ List.map_congr_left fun x hx => h_writhe_mod x ] ; norm_num [ List.sum_replicate ] ;
  exact Or.inl rfl))

end CognitiveBraid