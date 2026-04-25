/-! # CatalogBuild.Pythagorean.TreeFactoring.InversePythagoreanTree

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44
-/

import Mathlib

/-- Inverse of Branch A. -/
def invBerggrenA (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)


/-- Inverse of Branch B. -/
def invBerggrenB (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


/-- Inverse of Branch C. -/
def invBerggrenC (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


/-- Branch A preserves the Pythagorean property. -/
theorem berggrenA'_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenA' a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [berggrenA']; nlinarith [h]


/-- Branch B preserves the Pythagorean property. -/
theorem berggrenB'_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenB' a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [berggrenB']; nlinarith [h]


/-- Branch C preserves the Pythagorean property. -/
theorem berggrenC'_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenC' a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [berggrenC']; nlinarith [h]


/-- The fundamental triple (3, 4, 5) is Pythagorean. -/
theorem fundamental_triple' : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num


/-- A is invertible: applying A then A⁻¹ returns to the original triple. -/
theorem invA_after_A (a b c : ℤ) :
    let t := berggrenA' a b c
    invBerggrenA t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [berggrenA', invBerggrenA]
  ext <;> ring


/-- B is invertible: applying B then B⁻¹ returns to the original triple. -/
theorem invB_after_B (a b c : ℤ) :
    let t := berggrenB' a b c
    invBerggrenB t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [berggrenB', invBerggrenB]
  ext <;> ring


/-- C is invertible: applying C then C⁻¹ returns to the original triple. -/
theorem invC_after_C (a b c : ℤ) :
    let t := berggrenC' a b c
    invBerggrenC t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [berggrenC', invBerggrenC]
  ext <;> ring


/-- The other direction: A⁻¹ then A also returns to the original. -/
theorem A_after_invA (a b c : ℤ) :
    let t := invBerggrenA a b c
    berggrenA' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggrenA, berggrenA']
  ext <;> ring


/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.InversePythagoreanTree
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44] -/
theorem B_after_invB (a b c : ℤ) :
    let t := invBerggrenB a b c
    berggrenB' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggrenB, berggrenB']
  ext <;> ring


/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.InversePythagoreanTree
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44] -/
theorem C_after_invC (a b c : ℤ) :
    let t := invBerggrenC a b c
    berggrenC' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggrenC, berggrenC']
  ext <;> ring


/-- The hypotenuse strictly increases when going from parent to child
in the Berggren tree. Equivalently, going backward (inverse tree)
strictly decreases the hypotenuse — guaranteeing termination. -/
theorem berggren_hypotenuse_increases (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (_h : a ^ 2 + b ^ 2 = c ^ 2) :
    (berggrenA' a b c).2.2 > c ∧
    (berggrenB' a b c).2.2 > c ∧
    (berggrenC' a b c).2.2 > c := by
  constructor
  · simp only [berggrenA']; nlinarith [sq_nonneg (a - b)]
  constructor
  · simp only [berggrenB']; nlinarith
  · simp only [berggrenC']; nlinarith [sq_nonneg (a - b)]


/-- A Minkowski null vector in (3+1)D spacetime with integer coordinates. -/
structure MinkowskiNullVector' where
  x : ℤ
  y : ℤ
  z : ℤ
  t : ℤ
  null_condition : x ^ 2 + y ^ 2 + z ^ 2 = t ^ 2


/-- Every 2D Pythagorean triple (a,b,c) embeds into a 3+1D null vector (a,b,0,c). -/
def embedTripleToNull' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    MinkowskiNullVector' where
  x := a
  y := b
  z := 0
  t := c
  null_condition := by simp [h]


/-- A Pythagorean quadruple: a²+b²+c²=d². -/
def IsPythQuadruple' (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2


/-- (1, 2, 2, 3) is a Pythagorean quadruple. -/
theorem quadruple_1_2_2_3' : IsPythQuadruple' 1 2 2 3 := by
  simp [IsPythQuadruple']


/-- (2, 3, 6, 7) is a Pythagorean quadruple. -/
theorem quadruple_2_3_6_7' : IsPythQuadruple' 2 3 6 7 := by
  simp [IsPythQuadruple']


/-- Every Pythagorean triple gives a quadruple with z=0. -/
theorem triple_to_quadruple' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    IsPythQuadruple' a b 0 c := by
  simp [IsPythQuadruple', h]


/-- Every Pythagorean quadruple defines a Minkowski null vector. -/
def quadrupleToNull' (a b c d : ℤ) (h : IsPythQuadruple' a b c d) :
    MinkowskiNullVector' where
  x := a; y := b; z := c; t := d
  null_condition := h


/-- The Minkowski inner product in 3+1 dimensions. -/
def minkowski4' (v w : ℤ × ℤ × ℤ × ℤ) : ℤ :=
  v.1 * w.1 + v.2.1 * w.2.1 + v.2.2.1 * w.2.2.1 - v.2.2.2 * w.2.2.2


/-- A 4-vector is null iff its Minkowski norm is zero. -/
def isNull4' (v : ℤ × ℤ × ℤ × ℤ) : Prop := minkowski4' v v = 0


/-- Null condition in coordinates. -/
theorem null4_iff' (x y z t : ℤ) :
    isNull4' (x, y, z, t) ↔ x ^ 2 + y ^ 2 + z ^ 2 = t ^ 2 := by
  simp [isNull4', minkowski4']
  ring_nf
  constructor <;> intro h <;> linarith


/-- A Pythagorean triple defines a null 4-vector. -/
theorem pyth_triple_is_null' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    isNull4' (a, b, 0, c) := by
  rw [null4_iff']; simpa using h


/-- The sum of two null vectors need not be null. -/
theorem null_sum_not_null' :
    ∃ v w : ℤ × ℤ × ℤ × ℤ,
      isNull4' v ∧ isNull4' w ∧
      ¬isNull4' (v.1 + w.1, v.2.1 + w.2.1, v.2.2.1 + w.2.2.1, v.2.2.2 + w.2.2.2) := by
  use (3, 4, 0, 5), (5, 12, 0, 13)
  simp [isNull4', minkowski4']


/-- The Berggren A matrix has determinant 1. -/
theorem berggrenA_det' :
    let M := !![( 1 : ℤ), -2, 2; 2, -1, 2; 2, -2, 3]
    M.det = 1 := by native_decide


/-- The Berggren B matrix has determinant -1. -/
theorem berggrenB_det' :
    let M := !![( 1 : ℤ), 2, 2; 2, 1, 2; 2, 2, 3]
    M.det = -1 := by native_decide


/-- The Berggren C matrix has determinant 1. -/
theorem berggrenC_det' :
    let M := !![( -1 : ℤ), 2, 2; -2, 1, 2; -2, 2, 3]
    M.det = 1 := by native_decide


/-- The four children of a node in the forward tree:
3 spatial (Berggren) + 1 temporal (null vector embedding). -/
def fourBranchChildren' (a b c : ℤ) :
    (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) :=
  ( berggrenA' a b c,
    berggrenB' a b c,
    berggrenC' a b c,
    (a, b, c) )


/-- The four parents of a node in the inverse tree:
3 spatial (inverse Berggren) + 1 temporal. -/
def fourParents' (a b c : ℤ) :
    (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) × (ℤ × ℤ × ℤ) :=
  ( invBerggrenA a b c,
    invBerggrenB a b c,
    invBerggrenC a b c,
    (a, b, c) )


/-- Verify: the children of (3,4,5) in the 3-branch tree. -/
theorem children_of_345' :
    berggrenA' 3 4 5 = (5, 12, 13) ∧
    berggrenB' 3 4 5 = (21, 20, 29) ∧
    berggrenC' 3 4 5 = (15, 8, 17) := by
  simp [berggrenA', berggrenB', berggrenC']


/-- All three children of (3,4,5) are Pythagorean. -/
theorem children_of_345_pyth' :
    (5:ℤ)^2 + 12^2 = 13^2 ∧
    (21:ℤ)^2 + 20^2 = 29^2 ∧
    (15:ℤ)^2 + 8^2 = 17^2 := by norm_num


/-- The sum a+b+c is invariant mod 2 under all Berggren transformations.
This is a "photon parity" invariant. -/
theorem berggren_sum_mod2_A' (a b c : ℤ) :
    ((berggrenA' a b c).1 + (berggrenA' a b c).2.1 + (berggrenA' a b c).2.2) % 2 =
    (a + b + c) % 2 := by
  simp only [berggrenA']; omega


/-- [Section: # CatalogBuild.Pythagorean.TreeFactoring.InversePythagoreanTree
Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 44] -/
theorem berggren_sum_mod2_B' (a b c : ℤ) :
    ((berggrenB' a b c).1 + (berggrenB' a b c).2.1 + (berggrenB' a b c).2.2) % 2 =
    (a + b + c) % 2 := by
  simp only [berggrenB']; omega


theorem berggren_sum_mod2_C' (a b c : ℤ) :
    ((berggrenC' a b c).1 + (berggrenC' a b c).2.1 + (berggrenC' a b c).2.2) % 2 =
    (a + b + c) % 2 := by
  simp only [berggrenC']; omega


/-- The time-reversed branch: negate the time component. -/
def timeReverseBranch' (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ := (a, b, c, -d)


/-- Time reversal preserves the null condition. -/
theorem timeReverse_preserves' (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    let q := timeReverseBranch' a b c d
    q.1^2 + q.2.1^2 + q.2.2.1^2 = q.2.2.2^2 := by
  simp only [timeReverseBranch']; nlinarith [h]


/-- Time reversal is an involution. -/
theorem timeReverse_involution (a b c d : ℤ) :
    let r := timeReverseBranch' a b c d
    timeReverseBranch' r.1 r.2.1 r.2.2.1 r.2.2.2 = (a, b, c, d) := by
  simp [timeReverseBranch']


/-- **The Photon Round-Trip Theorem**: Every photon that is emitted (forward branch)
and then absorbed (inverse branch) returns to its original state. -/
theorem photon_round_trip_A' (a b c : ℤ) :
    let emitted := berggrenA' a b c
    let absorbed := invBerggrenA emitted.1 emitted.2.1 emitted.2.2
    absorbed = (a, b, c) := invA_after_A a b c


theorem photon_round_trip_B' (a b c : ℤ) :
    let emitted := berggrenB' a b c
    let absorbed := invBerggrenB emitted.1 emitted.2.1 emitted.2.2
    absorbed = (a, b, c) := invB_after_B a b c


theorem photon_round_trip_C' (a b c : ℤ) :
    let emitted := berggrenC' a b c
    let absorbed := invBerggrenC emitted.1 emitted.2.1 emitted.2.2
    absorbed = (a, b, c) := invC_after_C a b c


theorem photon_round_trip_time' (a b c d : ℤ) :
    let reversed := timeReverseBranch' a b c d
    timeReverseBranch' reversed.1 reversed.2.1 reversed.2.2.1 reversed.2.2.2 = (a, b, c, d) :=
  timeReverse_involution a b c d


/-- Generate the Berggren tree to a given depth. -/
def berggrenTree' (depth : ℕ) : List (ℤ × ℤ × ℤ) :=
  go [(3, 4, 5)] depth
where
  go (current : List (ℤ × ℤ × ℤ)) : ℕ → List (ℤ × ℤ × ℤ)
  | 0 => current
  | n + 1 =>
    let children := current.flatMap fun ⟨a, b, c⟩ =>
      [berggrenA' a b c, berggrenB' a b c, berggrenC' a b c]
    go (current ++ children) n

#eval berggrenTree' 0
#eval berggrenTree' 1

-- Verify some Pythagorean quadruples (3+1D null vectors)
#eval (1^2 + 2^2 + 2^2 : ℤ) == 3^2   -- true: (1,2,2,3)
#eval (2^2 + 3^2 + 6^2 : ℤ) == 7^2   -- true: (2,3,6,7)


