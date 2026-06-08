import Mathlib

/-!
# Formal Meta-Complexity: Core Definitions

Definitions for Hamming weight, symmetric Boolean functions, KW witnesses,
threshold functions, and majority functions.
-/

noncomputable section
open Classical Finset Fintype

namespace MetaComplexity

/-! ## Boolean vectors and Hamming weight -/

abbrev BoolVec (n : ℕ) := Fin n → Bool

/-- Hamming weight of a Boolean vector: the number of `true` coordinates. -/
def hammingWeight {n : ℕ} (x : BoolVec n) : ℕ :=
  (Finset.univ.filter fun i => x i = true).card

theorem hammingWeight_le {n : ℕ} (x : BoolVec n) : hammingWeight x ≤ n := by
  unfold hammingWeight
  exact le_trans (Finset.card_filter_le _ _) (by simp [Finset.card_univ])

/-! ## KW Witness -/

/-- A KW witness for `f` is a triple `(x, y, i)` where `f(x) = true`, `f(y) = false`,
and `x(i) ≠ y(i)`. -/
def KWWitness {n : ℕ} (f : BoolVec n → Bool) :=
  { w : BoolVec n × BoolVec n × Fin n //
    f w.1 = true ∧ f w.2.1 = false ∧ w.1 w.2.2 ≠ w.2.1 w.2.2 }

instance {n : ℕ} (f : BoolVec n → Bool) : Fintype (KWWitness f) :=
  Subtype.fintype _

/-! ## Symmetric Boolean functions -/

/-- A Boolean function is symmetric if its output depends only on the Hamming weight
of the input. -/
def IsSymmetric {n : ℕ} (f : BoolVec n → Bool) : Prop :=
  ∀ x y : BoolVec n, hammingWeight x = hammingWeight y → f x = f y

/-- A symmetric Boolean function on `n` variables, bundled with the symmetry proof. -/
def SymmetricBoolFn (n : ℕ) := { f : BoolVec n → Bool // IsSymmetric f }

/-! ## Layers -/

/-- The Hamming layer of weight `k`: all Boolean vectors with exactly `k` ones. -/
def layer (n k : ℕ) : Finset (BoolVec n) :=
  Finset.univ.filter (fun x => hammingWeight x = k)

/-- The true layer: vectors in the Hamming layer of weight `k` where `f` is true. -/
def trueLayer {n : ℕ} (f : BoolVec n → Bool) (k : ℕ) : Finset (BoolVec n) :=
  (layer n k).filter (fun x => f x = true)

/-- The false layer: vectors in the Hamming layer of weight `k` where `f` is false. -/
def falseLayer {n : ℕ} (f : BoolVec n → Bool) (k : ℕ) : Finset (BoolVec n) :=
  (layer n k).filter (fun x => f x = false)

/-! ## Threshold and majority functions -/

/-- The threshold function: `thresholdFn n t x = true` iff the Hamming weight of `x`
is at least `t`. -/
def thresholdFn (n t : ℕ) : BoolVec n → Bool :=
  fun x => decide (t ≤ hammingWeight x)

/-- The majority function: `majorityFn n x = true` iff at least `⌈n/2⌉` coordinates
are true. -/
def majorityFn (n : ℕ) : BoolVec n → Bool :=
  thresholdFn n ((n + 1) / 2)

theorem thresholdFn_symmetric (n t : ℕ) : IsSymmetric (thresholdFn n t) := by
  intro x y hxy
  simp [thresholdFn, hxy]

theorem majorityFn_symmetric (n : ℕ) : IsSymmetric (majorityFn n) :=
  thresholdFn_symmetric n _

/-! ## Number of differing coordinates -/

/-- The set of coordinates where `x` and `y` differ. -/
def differSet {n : ℕ} (x y : BoolVec n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i ≠ y i)

theorem differSet_card_eq_dist {n : ℕ} (x y : BoolVec n) :
    (differSet x y).card =
      (Finset.univ.filter (fun i => x i = true ∧ y i = false)).card +
      (Finset.univ.filter (fun i => x i = false ∧ y i = true)).card := by
  unfold differSet
  rw [show (Finset.univ.filter (fun i => x i ≠ y i)) =
    (Finset.univ.filter (fun i => x i = true ∧ y i = false)) ∪
    (Finset.univ.filter (fun i => x i = false ∧ y i = true)) from by
    ext i; simp; cases x i <;> cases y i <;> simp]
  rw [Finset.card_union_of_disjoint]
  exact Finset.disjoint_filter.mpr (by intro i _ ⟨h1, h2⟩ ⟨h3, _⟩; simp_all)

/-! ## Universal upper bound -/

/-- Each true/false pair contributes at most `n` witness coordinates. -/
theorem card_differSet_le {n : ℕ} (x y : BoolVec n) :
    (differSet x y).card ≤ n := by
  exact le_trans (Finset.card_filter_le _ _) (by simp)

end MetaComplexity

end