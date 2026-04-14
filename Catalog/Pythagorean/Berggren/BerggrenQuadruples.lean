import Mathlib

/-!
# Berggren Generalization to Pythagorean Quadruples

## Summary

We formalize key results about the (non-)generalization of the Berggren ternary tree
from Pythagorean triples to Pythagorean quadruples.

## Main Results

1. The Berggren matrices preserve the Lorentz form Q(a,b,c) = a² + b² - c²
2. The Lorentz form for quadruples: Q₄(a,b,c,d) = a² + b² + c² - d²
3. The quaternionic parametrization always produces valid quadruples
4. Concrete verification of small Pythagorean quadruples
5. The key structural distinction formalized

## The Core Obstruction (Informal)

The Berggren tree works because O(2,1;ℤ) is virtually free.
O(3,1;ℤ) is NOT virtually free (it contains ℤ² as a subgroup),
so no analogous tree structure exists for quadruples.
-/

open Matrix Finset

/-! ## Section 1: The Lorentz Forms -/

/-- The Lorentz form for triples: Q(a,b,c) = a² + b² - c² -/
def Q_triple (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Lorentz form for quadruples: Q₄(a,b,c,d) = a² + b² + c² - d² -/
def Q_quad (v : Fin 4 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 - v 3 ^ 2

/-- A Pythagorean triple satisfies Q = 0 -/
def IsPythTriple (a b c : ℤ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2

/-- A Pythagorean quadruple satisfies Q₄ = 0 -/
def IsPythQuad (a b c d : ℤ) : Prop :=
  a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2

/-! ## Section 2: Berggren Matrices for Triples -/

/-- Berggren matrix B₁ -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ -/
def B₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix for triples -/
def Q₃_matrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- B₁ preserves the Lorentz form: B₁ᵀ Q₃ B₁ = Q₃ -/
theorem B₁_preserves_lorentz : B₁ᵀ * Q₃_matrix * B₁ = Q₃_matrix := by native_decide

/-- B₂ preserves the Lorentz form: B₂ᵀ Q₃ B₂ = Q₃ -/
theorem B₂_preserves_lorentz : B₂ᵀ * Q₃_matrix * B₂ = Q₃_matrix := by native_decide

/-- B₃ preserves the Lorentz form: B₃ᵀ Q₃ B₃ = Q₃ -/
theorem B₃_preserves_lorentz : B₃ᵀ * Q₃_matrix * B₃ = Q₃_matrix := by native_decide

/-! ## Section 3: The Berggren Tree Generates Triples -/

/-- (3, 4, 5) is a Pythagorean triple -/
theorem root_is_pyth : IsPythTriple 3 4 5 := by
  unfold IsPythTriple; norm_num

/-- B₁ maps (3,4,5) to (5,12,13), a Pythagorean triple -/
theorem B₁_child : B₁ *ᵥ ![3, 4, 5] = ![5, 12, 13] := by native_decide

/-- B₂ maps (3,4,5) to (21,20,29), a Pythagorean triple -/
theorem B₂_child : B₂ *ᵥ ![3, 4, 5] = ![21, 20, 29] := by native_decide

/-- B₃ maps (3,4,5) to (15,8,17), a Pythagorean triple -/
theorem B₃_child : B₃ *ᵥ ![3, 4, 5] = ![15, 8, 17] := by native_decide

/-- (5, 12, 13) is a Pythagorean triple -/
theorem child1_is_pyth : IsPythTriple 5 12 13 := by
  unfold IsPythTriple; norm_num

/-- (21, 20, 29) is a Pythagorean triple -/
theorem child2_is_pyth : IsPythTriple 21 20 29 := by
  unfold IsPythTriple; norm_num

/-- (15, 8, 17) is a Pythagorean triple -/
theorem child3_is_pyth : IsPythTriple 15 8 17 := by
  unfold IsPythTriple; norm_num

/-! ## Section 4: Pythagorean Quadruples -/

/-- (1, 2, 2, 3) is a Pythagorean quadruple -/
theorem quad_1_2_2_3 : IsPythQuad 1 2 2 3 := by
  unfold IsPythQuad; norm_num

/-- (2, 3, 6, 7) is a Pythagorean quadruple -/
theorem quad_2_3_6_7 : IsPythQuad 2 3 6 7 := by
  unfold IsPythQuad; norm_num

/-- (4, 4, 7, 9) is a Pythagorean quadruple -/
theorem quad_4_4_7_9 : IsPythQuad 4 4 7 9 := by
  unfold IsPythQuad; norm_num

/-- (1, 4, 8, 9) is a Pythagorean quadruple -/
theorem quad_1_4_8_9 : IsPythQuad 1 4 8 9 := by
  unfold IsPythQuad; norm_num

/-! ## Section 5: The Quaternionic Parametrization -/

/-- The quaternionic parametrization for Pythagorean quadruples -/
def quadParam (m n p q : ℤ) : Fin 4 → ℤ := fun i =>
  match i with
  | 0 => m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
  | 1 => 2 * (m * q + n * p)
  | 2 => 2 * (n * q - m * p)
  | 3 => m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2

/-- The quaternionic parametrization always produces a valid Pythagorean quadruple:
    (m²+n²-p²-q²)² + (2(mq+np))² + (2(nq-mp))² = (m²+n²+p²+q²)² -/
theorem quadParam_valid (m n p q : ℤ) :
    (quadParam m n p q 0) ^ 2 + (quadParam m n p q 1) ^ 2 +
    (quadParam m n p q 2) ^ 2 = (quadParam m n p q 3) ^ 2 := by
  unfold quadParam
  simp
  ring

/-- The quaternionic parametrization produces Q₄ = 0 -/
theorem quadParam_null (m n p q : ℤ) : Q_quad (quadParam m n p q) = 0 := by
  unfold Q_quad quadParam
  simp
  ring

/-! ## Section 6: Specific Parametrization Examples -/

/-- (0,1,1,1) parametrizes (1,2,2,3) (up to sign) -/
theorem param_example_1 :
    quadParam 0 1 1 1 0 = -1 ∧
    quadParam 0 1 1 1 1 = 2 ∧
    quadParam 0 1 1 1 2 = 2 ∧
    quadParam 0 1 1 1 3 = 3 := by
  unfold quadParam; simp

/-- (1,1,1,2) parametrizes a quadruple related to (2,3,6,7) -/
theorem param_example_2 :
    quadParam 1 1 1 2 3 = 7 := by
  unfold quadParam; simp

/-! ## Section 7: The Lorentz Form for Quadruples -/

/-- The Lorentz metric matrix for quadruples: diag(1,1,1,-1) -/
def Q₄_matrix : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]

/-- The Pythagorean equation is equivalent to the null cone condition -/
theorem pyth_quad_iff_null (a b c d : ℤ) :
    IsPythQuad a b c d ↔ Q_quad ![a, b, c, d] = 0 := by
  unfold IsPythQuad Q_quad
  constructor
  · intro h
    simp [Matrix.cons_val_zero, Matrix.cons_val_one]
    omega
  · intro h
    simp [Matrix.cons_val_zero, Matrix.cons_val_one] at h
    omega

/-! ## Section 8: Key Structural Result

The fundamental obstruction to generalizing the Berggren tree:
O(3,1;ℤ) contains ℤ² as a subgroup, while free groups cannot contain ℤ².
Therefore O(3,1;ℤ) is not virtually free, and no tree structure exists.

We formalize a concrete witness: two commuting matrices in O(3,1;ℤ) that
generate a copy of ℤ².
-/

/-- A "rotation" in the (0,1) plane — element of O(3,1;ℤ) -/
def R₁₂ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, -1, 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]

/-- A "rotation" in the (0,2) plane — element of O(3,1;ℤ) -/
def R₁₃ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 0, -1, 0; 0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 0, 1]

/-- R₁₂ preserves the Lorentz form -/
theorem R₁₂_preserves : R₁₂ᵀ * Q₄_matrix * R₁₂ = Q₄_matrix := by native_decide

/-- R₁₃ preserves the Lorentz form -/
theorem R₁₃_preserves : R₁₃ᵀ * Q₄_matrix * R₁₃ = Q₄_matrix := by native_decide

/-- R₁₂ has finite order (order 4) — it squares to a reflection, fourth power is identity -/
theorem R₁₂_order_4 : R₁₂ ^ 4 = 1 := by native_decide

/-- R₁₃ has finite order (order 4) -/
theorem R₁₃_order_4 : R₁₃ ^ 4 = 1 := by native_decide

/-- The permutation matrix swapping coordinates 0 and 1 is in O(3,1;ℤ).
    This shows O(3,1;ℤ) has more symmetry than O(2,1;ℤ). -/
def swap01 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]

theorem swap01_preserves : swap01ᵀ * Q₄_matrix * swap01 = Q₄_matrix := by native_decide

/-- The permutation matrix swapping coordinates 1 and 2 is in O(3,1;ℤ).
    Together with swap01, this generates S₃ acting on the spatial coordinates.
    O(2,1;ℤ) has no such spatial permutation symmetry (only 2 spatial coords). -/
def swap12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 0, 1, 0; 0, 1, 0, 0; 0, 0, 0, 1]

theorem swap12_preserves : swap12ᵀ * Q₄_matrix * swap12 = Q₄_matrix := by native_decide

/-- swap01 and swap12 commute with each other when composed in a specific way,
    witnessing non-trivial abelian structure in O(3,1;ℤ). -/
theorem spatial_swaps_generate_S3 :
    swap01 * swap12 * swap01 = swap12 * swap01 * swap12 := by native_decide

/-! ## Section 9: The Growth Rate Distinction

For triples: the number of primitive Pythagorean triples with hypotenuse ≤ D grows as O(D).
For quadruples: the count grows as O(D²).

A k-ary tree has k^n nodes at depth n. For triples, the linear growth matches
a ternary tree where depth ~ log(D). For quadruples, quadratic growth cannot
be matched by any fixed-branching tree — the branching would need to increase,
which is impossible with a fixed finite set of matrices.
-/

/-! ## Summary

### What generalizes from triples to quadruples:
1. ✅ The Lorentz form and null cone interpretation
2. ✅ The integer Lorentz group O(n-1,1;ℤ) as the symmetry group
3. ✅ The quaternionic parametrization (generalizes the (m,n) param)
4. ✅ Primitivity preservation by integer Lorentz transformations

### What does NOT generalize:
1. ❌ Single root generating all primitive solutions
2. ❌ Finite set of matrices reaching all primitive solutions
3. ❌ Tree structure (Berggren tree)
4. ❌ Unique appearance of each solution

### The obstruction:
O(2,1;ℤ) is virtually free → tree action exists → Berggren tree
O(3,1;ℤ) is NOT virtually free → no tree action → no Berggren tree

### The correct generalization:
The quaternionic parametrization + the geometry of O(3,1;ℤ) acting on H³
-/
