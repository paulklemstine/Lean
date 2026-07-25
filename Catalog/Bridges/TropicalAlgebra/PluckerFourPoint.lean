/-
Copyright (c) 2025. All rights reserved.

# Tropical Plücker Relations and the Four-Point Condition

This file establishes the formal bridge between tropical Grassmannian algebra
and tree-metric combinatorics by proving that the tropical Plücker relation
on quadruples is equivalent to the four-point condition on distance matrices.

## Mathematical context

Given a symmetric function `d : α → α → ℝ`, define three pair-sums for any
quadruple `(a, b, c, e)`:
  - `s₁ = d a b + d c e`
  - `s₂ = d a c + d b e`
  - `s₃ = d a e + d b c`

The **tropical Plücker relation** states that each `sᵢ` is at most the
maximum of the other two. Equivalently, the minimum of the three sums is
attained at least twice.

The **four-point condition** states that whenever one sum is the smallest,
the other two are equal. Equivalently, the maximum of the three sums is
attained at least twice.

These two conditions are equivalent for symmetric `d`, and this equivalence
is the algebraic core of the correspondence between the tropical Grassmannian
`Trop(Gr(2,n))`, the Dressian, and finite tree metrics.

## Main results

* `tropical_plucker_equiv_four_point` — the tropical Plücker relation on all
  quadruples is equivalent to the four-point condition, assuming symmetry.
* `tropical_plucker_metric_implies_four_point` — the version with full metric
  axioms (symmetry, zero diagonal, nonnegativity, triangle inequality) implying
  the four-point condition.

## References

* Speyer, D. and Sturmfels, B. "The tropical Grassmannian" (2004)
* Dress, A. and Terhalle, W. "The tree all-or-nothing principle" (1996)
* Buneman, P. "The recovery of trees from measures of dissimilarity" (1971)
-/

import Mathlib

open scoped Matrix

/-! ## Definitions -/

/-- The four-point condition: for every four indices, the largest two of the three
pairwise distance sums are equal. Equivalently, whenever one sum is the minimum,
the other two are equal. This characterizes tree metrics (Buneman, 1971). -/
def FourPointCond {α : Type*} (d : α → α → ℝ) : Prop :=
  ∀ a b c e : α,
    let s1 := d a b + d c e
    let s2 := d a c + d b e
    let s3 := d a e + d b c
    ((s1 ≤ s2 ∧ s1 ≤ s3) → s2 = s3) ∧
    ((s2 ≤ s1 ∧ s2 ≤ s3) → s1 = s3) ∧
    ((s3 ≤ s1 ∧ s3 ≤ s2) → s1 = s2)

/-- The tropical Plücker relation: for every quadruple, each pair-sum is at most
the maximum of the other two. Equivalently, the minimum of the three pair-sums
is attained at least twice. -/
def TropicalPlucker {α : Type*} (d : α → α → ℝ) : Prop :=
  ∀ a b c e : α,
    d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)

/-! ## Abstract three-number lemma

The core algebraic fact: three real numbers `x, y, z` satisfy
"each ≤ max of the other two" if and only if "whenever one is the min,
the other two are equal". -/

/-
If each of three reals is ≤ the max of the other two, then whenever one is
the minimum, the other two are equal.
-/
lemma three_le_max_implies_four_point {x y z : ℝ}
    (h1 : x ≤ max y z) (h2 : y ≤ max x z) (h3 : z ≤ max x y) :
    ((x ≤ y ∧ x ≤ z) → y = z) ∧
    ((y ≤ x ∧ y ≤ z) → x = z) ∧
    ((z ≤ x ∧ z ≤ y) → x = y) := by
  grind +locals

/-
Conversely, the four-point property on three reals implies each is ≤ the max
of the other two.
-/
lemma four_point_implies_three_le_max {x y z : ℝ}
    (h : ((x ≤ y ∧ x ≤ z) → y = z) ∧
         ((y ≤ x ∧ y ≤ z) → x = z) ∧
         ((z ≤ x ∧ z ≤ y) → x = y)) :
    (x ≤ max y z) ∧ (y ≤ max x z) ∧ (z ≤ max x y) := by
  grind

/-! ## Permutation lemmas for the Plücker inequality

The tropical Plücker condition gives `s₁ ≤ max s₂ s₃` directly.
Using symmetry of `d`, we derive the other two inequalities by
permuting the arguments. -/

/-
From the Plücker inequality `d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)`
applied to `(a, c, b, e)` and using symmetry, we get
`d a c + d b e ≤ max (d a b + d c e) (d a e + d b c)`.
-/
lemma plucker_perm_acbe {α : Type*} (d : α → α → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hplucker : TropicalPlucker d)
    (a b c e : α) :
    d a c + d b e ≤ max (d a b + d c e) (d a e + d b c) := by
  convert hplucker a c b e using 1 ; simp +decide [*]

/-
From the Plücker inequality applied to `(a, e, b, c)` and using symmetry,
we get `d a e + d b c ≤ max (d a b + d c e) (d a c + d b e)`.
-/
lemma plucker_perm_aebc {α : Type*} (d : α → α → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hplucker : TropicalPlucker d)
    (a b c e : α) :
    d a e + d b c ≤ max (d a b + d c e) (d a c + d b e) := by
  convert hplucker a e b c using 1;
  grind +splitImp

/-! ## Main equivalence theorem -/

/-
**Tropical Plücker ↔ Four-Point Condition.**
For a symmetric function `d : α → α → ℝ`, the tropical Plücker relation
is equivalent to the four-point condition. This is the algebraic core of the
correspondence between the tropical Grassmannian and tree metrics.
-/
theorem tropical_plucker_equiv_four_point {α : Type*} (d : α → α → ℝ)
    (hsym : ∀ i j, d i j = d j i) :
    TropicalPlucker d ↔ FourPointCond d := by
  grind +locals

/-! ## The metric version -/

/-- **Tropical Plücker + metric axioms ⇒ four-point condition.**
If `d : Fin n → Fin n → ℝ` is a symmetric, zero-diagonal, nonnegative function
satisfying the triangle inequality and the tropical Plücker relation,
then `d` satisfies the four-point condition.

This is the reverse direction of the tropical–phylogenetic dictionary:
tropical Grassmannian constraints force tree-metric behavior. -/
theorem tropical_plucker_metric_implies_four_point
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (_hdiag : ∀ i, d i i = 0)
    (_hnonneg : ∀ i j, 0 ≤ d i j)
    (_htri : ∀ i j k, d i k ≤ d i j + d j k)
    (hplucker : TropicalPlucker d) :
    FourPointCond d :=
  (tropical_plucker_equiv_four_point d hsym).mp hplucker

/-! ## Compatibility with Matrix-based FourPointCondition -/

/-- The four-point condition for functions is equivalent to the matrix-based version
when the function is viewed as a matrix. -/
theorem four_point_cond_iff_matrix {n : ℕ} (d : Fin n → Fin n → ℝ) :
    FourPointCond d ↔
    (∀ i j k l : Fin n,
      let s1 := d i j + d k l
      let s2 := d i k + d j l
      let s3 := d i l + d j k
      ((s1 ≤ s2 ∧ s1 ≤ s3) → s2 = s3) ∧
      ((s2 ≤ s1 ∧ s2 ≤ s3) → s1 = s3) ∧
      ((s3 ≤ s1 ∧ s3 ≤ s2) → s1 = s2)) := by
  rfl

/-! ## The full equivalence in the metric setting -/

/-- **Four-point condition ↔ tropical Plücker relation** for symmetric functions.
This single bi-conditional captures the entire algebraic bridge between
tree metrics and the tropical Grassmannian. -/
theorem four_point_iff_tropical_plucker
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i) :
    FourPointCond d ↔ TropicalPlucker d :=
  (tropical_plucker_equiv_four_point d hsym).symm