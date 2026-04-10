/-
# Complexity Theory Foundations

Formal foundations for complexity-theoretic structures including:
- Boolean functions and circuit complexity
- Sensitivity and influence measures
- Certificate complexity
- Monotone function theory

These definitions support the research program connecting algebraic structures
(tropical semirings, defect algebras, coherence tiers) to computational complexity.
-/
import Mathlib

namespace ComplexityTheory

/-! ## Boolean Functions and Basic Combinatorics -/

/-- A Boolean function on n variables -/
abbrev BoolFn (n : ℕ) := Fin n → Bool

/-- The Hamming weight of a Boolean assignment -/
def hammingWeight {n : ℕ} (x : BoolFn n) : ℕ :=
  (Finset.univ.filter (fun i => x i = true)).card

/-
Hamming weight is bounded by n
-/
theorem hammingWeight_le {n : ℕ} (x : BoolFn n) : hammingWeight x ≤ n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-- Hamming distance between two Boolean strings -/
def hammingDist {n : ℕ} (x y : BoolFn n) : ℕ :=
  (Finset.univ.filter (fun i => x i ≠ y i)).card

/-
Hamming distance is symmetric
-/
theorem hammingDist_comm {n : ℕ} (x y : BoolFn n) :
    hammingDist x y = hammingDist y x := by
      exact congr_arg Finset.card ( by ext; aesop )

/-
Hamming distance satisfies triangle inequality
-/
theorem hammingDist_triangle {n : ℕ} (x y z : BoolFn n) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z := by
      -- If x_i ≠ z_i, then either x_i ≠ y_i or y_i ≠ z_i. So the filter set for x,z is contained in the union of filter sets for x,y and y,z. Then use card_union_le.
      have h_filter : Finset.univ.filter (fun i => x i ≠ z i) ⊆ Finset.univ.filter (fun i => x i ≠ y i) ∪ Finset.univ.filter (fun i => y i ≠ z i) := by
        grind;
      exact le_trans ( Finset.card_le_card h_filter ) ( Finset.card_union_le _ _ )

/-
Hamming distance is zero iff equal
-/
theorem hammingDist_eq_zero_iff {n : ℕ} (x y : BoolFn n) :
    hammingDist x y = 0 ↔ x = y := by
      simp +decide [ hammingDist, funext_iff ]

/-! ## Sensitivity -/

/-- Flip the i-th bit of a Boolean string -/
def flipBit {n : ℕ} (x : BoolFn n) (i : Fin n) : BoolFn n :=
  Function.update x i (!x i)

/-- Sensitivity of a Boolean function f at input x:
    the number of coordinates where flipping changes the output -/
def sensitivity {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => f x ≠ f (flipBit x i))).card

/-
Sensitivity is bounded by n
-/
theorem sensitivity_le {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n) :
    sensitivity f x ≤ n := by
      exact le_trans ( Finset.card_le_univ _ ) ( by simpa )

/-! ## Certificate Complexity -/

/-- A certificate for f at x is a subset S of coordinates such that
    any y agreeing with x on S satisfies f(y) = f(x) -/
def IsCertificate {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n)
    (S : Finset (Fin n)) : Prop :=
  ∀ y : BoolFn n, (∀ i ∈ S, y i = x i) → f y = f x

/-
The empty set is a certificate for constant functions
-/
theorem empty_certificate_of_const {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n)
    (hconst : ∀ y, f y = f x) : IsCertificate f x ∅ := by
      exact fun y hy => hconst y

/-
The full set is always a certificate
-/
theorem full_certificate {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n) :
    IsCertificate f x Finset.univ := by
      exact fun y _ => by simp +decide [ show y = x from funext fun i => by simpa using ‹∀ i ∈ Finset.univ, y i = x i› i ( Finset.mem_univ i ) ] ;

/-! ## Monotone Boolean Functions -/

/-- Pointwise ordering on Boolean strings -/
def boolLE {n : ℕ} (x y : BoolFn n) : Prop :=
  ∀ i : Fin n, x i = true → y i = true

/-- A function on Boolean strings is monotone -/
def IsMonotone {n : ℕ} (f : BoolFn n → Bool) : Prop :=
  ∀ x y : BoolFn n, boolLE x y → f x = true → f y = true

/-
boolLE is reflexive
-/
theorem boolLE_refl {n : ℕ} (x : BoolFn n) : boolLE x x := by
  exact fun i hi => hi

/-
boolLE is transitive
-/
theorem boolLE_trans {n : ℕ} (x y z : BoolFn n) :
    boolLE x y → boolLE y z → boolLE x z := by
      exact fun hxy hyz i hi => hyz i ( hxy i hi )

/-
boolLE is antisymmetric
-/
theorem boolLE_antisymm {n : ℕ} (x y : BoolFn n) :
    boolLE x y → boolLE y x → x = y := by
      intros hxy hyx
      funext i
      by_cases hxi : x i = true;
      · have := hxy i; have := hyx i; aesop;
      · cases h : x i <;> cases h' : y i <;> simp_all +decide [ boolLE ]

/-
The constant true function is monotone
-/
theorem isMonotone_const_true {n : ℕ} :
    IsMonotone (fun _ : BoolFn n => true) := by
      exact?

/-
The constant false function is monotone
-/
theorem isMonotone_const_false {n : ℕ} :
    IsMonotone (fun _ : BoolFn n => false) := by
      tauto

/-! ## Influence of Variables -/

/-- The influence of variable i on Boolean function f:
    the number of inputs where flipping i changes f -/
def influence {n : ℕ} (f : BoolFn n → Bool) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun x : BoolFn n =>
    f x ≠ f (flipBit x i))).card

/-- Total influence is the sum of individual influences -/
def totalInfluence {n : ℕ} (f : BoolFn n → Bool) : ℕ :=
  Finset.sum Finset.univ (fun i => influence f i)

/-
For constant functions, every variable has zero influence
-/
theorem influence_const {n : ℕ} (b : Bool) (i : Fin n) :
    influence (fun _ : BoolFn n => b) i = 0 := by
      unfold influence; aesop;

/-
Total influence of constant function is zero
-/
theorem totalInfluence_const {n : ℕ} (b : Bool) :
    totalInfluence (fun _ : BoolFn n => b) = 0 := by
      -- The sum of zeros is zero.
      simp [totalInfluence, influence_const]

end ComplexityTheory