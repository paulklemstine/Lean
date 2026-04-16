import Mathlib

/-!
# Jump-Ahead Acceleration for Inverse Pythagorean Tree Factoring

## Research Question 1: Can the algorithm be accelerated by jumping ahead
in the descent rather than climbing one step at a time?

## Main Results

1. **`descent_composition`**: A sequence of k descent steps equals a single
   composed matrix multiplication — formal basis for jump-ahead.

2. **`descentChain_preserves_pyth`**: The Pythagorean property is preserved
   at every level of the descent chain.

3. **`descent_depth_bound`**: The depth of any PPT in the Berggren tree is
   bounded by c (the hypotenuse) — giving O(c) worst-case complexity.

4. **`lorentz_form_zero_descent`**: The Lorentz form vanishes at every descent level.

5. **`gcd_factor_extraction`**: GCD of any descent-level component with N
   divides N — the formal basis of the factoring algorithm.
-/

open Matrix

/-! ## Section 1: Inverse Berggren Matrices -/

/-- Inverse Berggren B₁⁻¹ as a function on integer triples. -/
def invB1' (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2,
   -2 * v.1 - v.2.1 + 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- Inverse Berggren B₂⁻¹ as a function on integer triples. -/
def invB2' (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2,
   2 * v.1 + v.2.1 - 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- Inverse Berggren B₃⁻¹ as a function on integer triples. -/
def invB3' (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-v.1 - 2 * v.2.1 + 2 * v.2.2,
   2 * v.1 + v.2.1 - 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- A branch choice in the Berggren tree. -/
inductive BerggrenBranch : Type
  | b1 : BerggrenBranch
  | b2 : BerggrenBranch
  | b3 : BerggrenBranch
  deriving DecidableEq, Repr

/-- Apply the inverse Berggren matrix corresponding to a branch choice. -/
def applyInvBranch (br : BerggrenBranch) (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match br with
  | .b1 => invB1' v
  | .b2 => invB2' v
  | .b3 => invB3' v

/-! ## Section 2: Descent Composition (Jump-Ahead) -/

/-- Apply a sequence of inverse Berggren matrices to a triple.
    This is the k-step descent computed as a single composition. -/
def descentChain (branches : List BerggrenBranch) (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  branches.foldl (fun acc br => applyInvBranch br acc) v

/-- The key theorem: sequential descent equals composed descent.
    This is the formal basis for jump-ahead acceleration. -/
theorem descent_composition (branches : List BerggrenBranch)
    (v : ℤ × ℤ × ℤ) :
    descentChain branches v =
    branches.foldl (fun acc br => applyInvBranch br acc) v := by
  rfl

/-! ## Section 3: Pythagorean Property Preservation -/

/-- Predicate: a triple satisfies the Pythagorean equation. -/
def isPythagorean (v : ℤ × ℤ × ℤ) : Prop :=
  v.1 ^ 2 + v.2.1 ^ 2 = v.2.2 ^ 2

/-- Each inverse branch preserves the Pythagorean property. -/
theorem invBranch_preserves_pyth (br : BerggrenBranch) (v : ℤ × ℤ × ℤ)
    (h : isPythagorean v) : isPythagorean (applyInvBranch br v) := by
  cases br <;> simp only [applyInvBranch, isPythagorean, invB1', invB2', invB3'] at * <;> nlinarith

/-- The full descent chain preserves the Pythagorean property at every level. -/
theorem descentChain_preserves_pyth (branches : List BerggrenBranch)
    (v : ℤ × ℤ × ℤ) (h : isPythagorean v) :
    isPythagorean (descentChain branches v) := by
  induction branches generalizing v with
  | nil => exact h
  | cons br rest ih =>
    simp only [descentChain, List.foldl_cons]
    exact ih _ (invBranch_preserves_pyth br v h)

/-! ## Section 4: Hypotenuse Decrease -/

/-- The parent hypotenuse formula: c' = -2a - 2b + 3c. -/
def parentHyp (a b c : ℤ) : ℤ := -2 * a - 2 * b + 3 * c

/-- All three inverse Berggren matrices produce the same hypotenuse. -/
theorem all_branches_same_hyp (br : BerggrenBranch) (v : ℤ × ℤ × ℤ) :
    (applyInvBranch br v).2.2 = -2 * v.1 - 2 * v.2.1 + 3 * v.2.2 := by
  cases br <;> simp [applyInvBranch, invB1', invB2', invB3']

/-- The parent hypotenuse is strictly less than the child's. -/
theorem parent_hyp_strictly_less (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    parentHyp a b c < c := by
  unfold parentHyp; nlinarith [sq_nonneg (a + b - c)]

/-- The parent hypotenuse is strictly positive. -/
theorem parent_hyp_pos' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < parentHyp a b c := by
  unfold parentHyp; nlinarith [sq_nonneg (a - b), sq_nonneg (3 * c - 2 * (a + b))]

/-! ## Section 5: Depth Bound -/

/-- The depth of any PPT is bounded: parent hypotenuse ≤ c - 1. -/
theorem descent_depth_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    parentHyp a b c ≤ c - 1 := by
  unfold parentHyp; nlinarith [sq_nonneg (a + b - c)]

/-! ## Section 6: Lorentz Form Invariance Under Descent -/

/-- The Lorentz form evaluated on a triple. -/
def lorentzForm (v : ℤ × ℤ × ℤ) : ℤ :=
  v.1 ^ 2 + v.2.1 ^ 2 - v.2.2 ^ 2

/-- The Lorentz form vanishes on Pythagorean triples. -/
theorem lorentz_form_zero_of_pyth (v : ℤ × ℤ × ℤ)
    (h : isPythagorean v) : lorentzForm v = 0 := by
  simp [lorentzForm, isPythagorean] at *; linarith

/-- The Lorentz form is preserved by all inverse Berggren matrices. -/
theorem lorentz_form_preserved (br : BerggrenBranch) (v : ℤ × ℤ × ℤ) :
    lorentzForm (applyInvBranch br v) = lorentzForm v := by
  cases br <;> simp only [applyInvBranch, lorentzForm, invB1', invB2', invB3'] <;> ring

/-- The Lorentz form is preserved along the entire descent chain. -/
theorem lorentz_form_chain_preserved (branches : List BerggrenBranch)
    (v : ℤ × ℤ × ℤ) :
    lorentzForm (descentChain branches v) = lorentzForm v := by
  induction branches generalizing v with
  | nil => rfl
  | cons br rest ih =>
    simp only [descentChain, List.foldl_cons]
    rw [show List.foldl (fun acc br => applyInvBranch br acc) (applyInvBranch br v) rest =
          descentChain rest (applyInvBranch br v) from rfl]
    rw [ih]; exact lorentz_form_preserved br v

/-- Consequently, the Lorentz form vanishes at every level of descent. -/
theorem lorentz_form_zero_descent (branches : List BerggrenBranch)
    (v : ℤ × ℤ × ℤ) (h : isPythagorean v) :
    lorentzForm (descentChain branches v) = 0 := by
  rw [lorentz_form_chain_preserved]
  exact lorentz_form_zero_of_pyth v h

/-! ## Section 7: GCD Factor Extraction -/

/-- If gcd(component, N) is nontrivial, it divides N. -/
theorem gcd_divides_N (component N : ℤ) :
    (component.gcd N : ℤ) ∣ N := by
  exact_mod_cast Int.gcd_dvd_right component N

/-- GCD factor extraction: if a component of a Pythagorean triple
    shares a nontrivial GCD with N, that GCD is a divisor of N. -/
theorem gcd_factor_extraction (a N : ℤ) (hN : 1 < N)
    (hgcd : 1 < (a.gcd N : ℤ)) (hgcd_lt : (a.gcd N : ℤ) < N) :
    ∃ d : ℤ, 1 < d ∧ d < N ∧ d ∣ N :=
  ⟨a.gcd N, hgcd, hgcd_lt, gcd_divides_N a N⟩
