import Mathlib

/-!
# Formal Meta-Complexity: Core Definitions

Definitions for Hamming weight, symmetric Boolean functions, KW witnesses,
threshold functions, and majority functions on the Boolean cube `Fin n → Bool`.
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

/-- A Boolean function is symmetric if its output depends only on the Hamming weight. -/
def IsSymmetric {n : ℕ} (f : BoolVec n → Bool) : Prop :=
  ∀ x y : BoolVec n, hammingWeight x = hammingWeight y → f x = f y

/-! ## Layers -/

/-- The Hamming layer of weight `k`: all Boolean vectors with exactly `k` ones. -/
def layer (n k : ℕ) : Finset (BoolVec n) :=
  Finset.univ.filter (fun x => hammingWeight x = k)

/-! ## Threshold and majority functions -/

/-- The threshold function: `thresholdFn n t x = true` iff `hammingWeight x ≥ t`. -/
def thresholdFn (n t : ℕ) : BoolVec n → Bool :=
  fun x => decide (t ≤ hammingWeight x)

/-- The majority function. -/
def majorityFn (n : ℕ) : BoolVec n → Bool :=
  thresholdFn n ((n + 1) / 2)

theorem thresholdFn_symmetric (n t : ℕ) : IsSymmetric (thresholdFn n t) := by
  intro x y hxy; simp [thresholdFn, hxy]

/-! ## Number of differing coordinates -/

/-- The set of coordinates where `x` and `y` differ. -/
def differSet {n : ℕ} (x y : BoolVec n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i ≠ y i)

/-- Coordinates where x is true and y is false. -/
def trueToFalse {n : ℕ} (x y : BoolVec n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i = true ∧ y i = false)

/-- Coordinates where x is false and y is true. -/
def falseToTrue {n : ℕ} (x y : BoolVec n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i = false ∧ y i = true)

/-- The number of differing coordinates equals the sum of one-sided disagreements. -/
theorem differSet_card_eq {n : ℕ} (x y : BoolVec n) :
    (differSet x y).card = (trueToFalse x y).card + (falseToTrue x y).card := by
  unfold differSet trueToFalse falseToTrue
  rw [show (Finset.univ.filter (fun i => x i ≠ y i)) =
    (Finset.univ.filter (fun i => x i = true ∧ y i = false)) ∪
    (Finset.univ.filter (fun i => x i = false ∧ y i = true)) from by
    ext i; simp; cases x i <;> cases y i <;> simp]
  rw [Finset.card_union_of_disjoint]
  exact Finset.disjoint_filter.mpr (by intro i _ ⟨h1, _⟩ ⟨h3, _⟩; simp_all)

/-- The number of `true→false` minus `false→true` disagreements equals
    the weight difference. -/
theorem trueToFalse_sub_falseToTrue {n : ℕ} (x y : BoolVec n) :
    (trueToFalse x y).card = hammingWeight x - (Finset.univ.filter fun i => x i = true ∧ y i = true).card := by
  unfold trueToFalse hammingWeight
  have : (Finset.univ.filter fun i => x i = true) =
    (Finset.univ.filter fun i => x i = true ∧ y i = true) ∪
    (Finset.univ.filter fun i => x i = true ∧ y i = false) := by
    ext i; simp; cases y i <;> simp
  rw [this, Finset.card_union_of_disjoint (by
    exact Finset.disjoint_filter.mpr (by intro i _ ⟨_, h1⟩ ⟨_, h2⟩; simp_all))]
  omega

/-! ## Fiber counting definitions -/

/-- The per-fiber witness count from the "true→false" orientation.
    For a fixed coordinate, there are `C(n-1,k-1)` vectors of weight k with that
    coordinate true, and `C(n-1,l)` vectors of weight l with it false. -/
def fiberTF (n k l : ℕ) : ℕ :=
  if k = 0 then 0 else n * Nat.choose (n - 1) (k - 1) * Nat.choose (n - 1) l

/-- The per-fiber witness count from the "false→true" orientation. -/
def fiberFT (n k l : ℕ) : ℕ :=
  if l = 0 then 0 else n * Nat.choose (n - 1) k * Nat.choose (n - 1) (l - 1)

/-- The total per-fiber witness count: the number of triples (x,y,i) with
    |x|=k, |y|=l, x_i≠y_i. -/
def fiberTotal (n k l : ℕ) : ℕ := fiberTF n k l + fiberFT n k l

end MetaComplexity

end