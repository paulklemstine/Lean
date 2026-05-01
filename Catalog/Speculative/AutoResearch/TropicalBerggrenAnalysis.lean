import Mathlib

/-!
# Tropical Berggren Rank Factorization: Analysis and Counterexamples

## Summary

This file formalizes the Berggren tree infrastructure and provides a rigorous analysis
of the conjecture that the tropical rank of p-adic valuation matrices derived from
Berggren tree paths equals the number of distinct prime factors of the hypotenuse.

## Conclusion: The Conjecture Is False

The central claim — that `tropicalRank(T_p(N)) = ω(N)` — is **false**, for multiple
independent reasons:

### 1. Dimensional Obstruction (Fatal)
The "path matrix" B(N) has dimensions (path_length × 3), since each Pythagorean triple
is a vector in ℤ³. Therefore its tropical rank is at most min(path_length, 3) ≤ 3.
But ω(N) can be arbitrarily large, so the equality fails for any N with ω(N) > 3.

### 2. Concrete Counterexample: N = 169 = 13²
- Path: (3,4,5) → (21,20,29) → (119,120,169), using B₂ twice.
- For p = 13: T₁₃(169) = [[0,0,0],[0,0,0],[0,0,2]]
- Tropical rank of this matrix is ≥ 2 (proof below: it cannot be written as an
  outer sum a[i] + b[j], since all entries are 0 except the (2,2) entry which is 2).
- But ω(169) = ω(13²) = 1.
- So tropical rank ≥ 2 > 1 = ω(N). **Equality fails.**

### 3. Concrete Counterexample: N = 25 = 5²
- Path: (3,4,5) → (5,12,13) → (7,24,25), using B₁ twice.
- For p = 5: T₅(25) = [[0,0,1],[1,0,0],[0,0,2]]
- Tropical rank ≥ 2 (the Monge condition fails: T[0,0]+T[1,1]=0 ≠ 1=T[0,1]+T[1,0]),
  so the matrix cannot be tropically rank 1.
- But ω(25) = 1. **Equality fails again.**

### 4. Domain Restriction (Fundamental)
Not every N > 1 appears as a hypotenuse of a primitive Pythagorean triple.
For a primitive triple (a,b,c), every prime factor of c must be ≡ 1 (mod 4).
So N = 6, 10, 14, 15, 21, ... have no Berggren path at all, making B(N) undefined.

### 5. Non-Uniqueness
When N is the hypotenuse of multiple primitive triples (e.g., N = 65 = 5 × 13
is the hypotenuse of both (33,56,65) and (63,16,65)), the "path matrix" B(N)
is ambiguous without choosing a specific triple.

### 6. Newton Polygon Claim Is Ill-Formed
The tropical determinant of T_p(N) is a single element of ℝ ∪ {∞} (a scalar in the
min-plus semiring), not a polynomial. A single scalar does not have a Newton polygon.
The claim that "Newton polygon breakpoints occur at the exponents eᵢ" is therefore
mathematically meaningless as stated.

## What IS True

We formalize and prove genuine properties of the Berggren matrices:
- B₁ and B₃ have determinant 1, B₂ has determinant -1
- All three preserve the Pythagorean property: if a²+b²=c², then the transformed
  triple also satisfies this equation
- The Berggren tree path computation is well-defined for any tree path
- Verified counterexamples with machine-checked p-adic valuations
-/

section BerggrenInfrastructure

/-! ## Berggren Matrices (3×3 integer matrices) -/

/-- Berggren matrix B₁ (the "left" branch). -/
def berggrenMat₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B₂ (the "middle" branch). -/
def berggrenMat₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix B₃ (the "right" branch). -/
def berggrenMat₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-! ## Determinants -/

/-- B₁ has determinant 1 (it is in SL(3,ℤ)). -/
theorem det_berggrenMat₁ : Matrix.det berggrenMat₁ = 1 := by native_decide

/-- B₂ has determinant -1. -/
theorem det_berggrenMat₂ : Matrix.det berggrenMat₂ = -1 := by native_decide

/-- B₃ has determinant 1 (it is in SL(3,ℤ)). -/
theorem det_berggrenMat₃ : Matrix.det berggrenMat₃ = 1 := by native_decide

/-! ## Tree Paths and Triple Computation -/

/-- A path in the Berggren ternary tree. -/
inductive BerggrenPath' : Type
  | root : BerggrenPath'
  | left : BerggrenPath' → BerggrenPath'
  | mid : BerggrenPath' → BerggrenPath'
  | right : BerggrenPath' → BerggrenPath'
  deriving Repr

/-- The depth of a Berggren path. -/
def BerggrenPath'.depth : BerggrenPath' → ℕ
  | .root => 0
  | .left p => p.depth + 1
  | .mid p => p.depth + 1
  | .right p => p.depth + 1

/-- The Pythagorean triple (a, b, c) at a given path in the Berggren tree.
    Each branch applies one of the three Berggren transformations. -/
def berggrenTriple' : BerggrenPath' → ℤ × ℤ × ℤ
  | .root => (3, 4, 5)
  | .left p =>
    let (a, b, c) := berggrenTriple' p
    (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid p =>
    let (a, b, c) := berggrenTriple' p
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right p =>
    let (a, b, c) := berggrenTriple' p
    (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-! ## Pythagorean Preservation -/

/-- B₁ preserves the Pythagorean property. -/
theorem berggren_left_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- B₂ preserves the Pythagorean property. -/
theorem berggren_mid_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- B₃ preserves the Pythagorean property. -/
theorem berggren_right_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- Every triple generated by the Berggren tree is Pythagorean. -/
theorem berggren_pythagorean' (p : BerggrenPath') :
    let (a, b, c) := berggrenTriple' p; a ^ 2 + b ^ 2 = c ^ 2 := by
  induction p with
  | root => norm_num [berggrenTriple']
  | left p ih => simp only [berggrenTriple']; exact berggren_left_preserves _ _ _ ih
  | mid p ih => simp only [berggrenTriple']; exact berggren_mid_preserves _ _ _ ih
  | right p ih => simp only [berggrenTriple']; exact berggren_right_preserves _ _ _ ih

end BerggrenInfrastructure

/-! ## Verified Counterexamples -/

section Counterexamples

/-- The path to (119, 120, 169) via B₂ ∘ B₂. -/
def path169 : BerggrenPath' := .mid (.mid .root)

/-- The path to (7, 24, 25) via B₁ ∘ B₁. -/
def path25 : BerggrenPath' := .left (.left .root)

/-- The path to (33, 56, 65) via B₁ ∘ B₃. -/
def path65 : BerggrenPath' := .left (.right .root)

/-- Verified: path169 produces (119, 120, 169). -/
theorem triple_at_path169 : berggrenTriple' path169 = (119, 120, 169) := by
  native_decide

/-- Verified: path25 produces (7, 24, 25). -/
theorem triple_at_path25 : berggrenTriple' path25 = (7, 24, 25) := by
  native_decide

/-- Verified: path65 produces (33, 56, 65). -/
theorem triple_at_path65 : berggrenTriple' path65 = (33, 56, 65) := by
  native_decide

/-- 169 = 13² has exactly 1 distinct prime factor. -/
theorem omega_169 : (169 : ℕ).primeFactors.card = 1 := by native_decide

/-- 25 = 5² has exactly 1 distinct prime factor. -/
theorem omega_25 : (25 : ℕ).primeFactors.card = 1 := by native_decide

/-- 65 = 5 × 13 has exactly 2 distinct prime factors. -/
theorem omega_65 : (65 : ℕ).primeFactors.card = 2 := by native_decide

/-! ### Counterexample 1: N = 169 = 13²

The 13-adic valuation matrix T₁₃(169) for the path (3,4,5)→(21,20,29)→(119,120,169):

    T₁₃ = [[0, 0, 0],
            [0, 0, 0],
            [0, 0, 2]]

A matrix has tropical rank 1 iff it satisfies the Monge condition:
  T[i,j] + T[i',j'] = T[i,j'] + T[i',j]  for all i,i',j,j'.

Here: T[0,0] + T[2,2] = 0 + 2 = 2, but T[0,2] + T[2,0] = 0 + 0 = 0.
Since 2 ≠ 0, the Monge condition fails, so tropical rank ≥ 2.
But ω(169) = 1, so tropical_rank ≠ ω(N).
-/

/-- 13-adic valuations along the path to 169, row 0: (3, 4, 5) -/
theorem T13_169_row0 :
    (padicValNat 13 3, padicValNat 13 4, padicValNat 13 5) = (0, 0, 0) := by native_decide

/-- 13-adic valuations along the path to 169, row 1: (21, 20, 29) -/
theorem T13_169_row1 :
    (padicValNat 13 21, padicValNat 13 20, padicValNat 13 29) = (0, 0, 0) := by native_decide

/-- 13-adic valuations along the path to 169, row 2: (119, 120, 169) -/
theorem T13_169_row2 :
    (padicValNat 13 119, padicValNat 13 120, padicValNat 13 169) = (0, 0, 2) := by native_decide

/-- **Counterexample 1**: The Monge condition fails for T₁₃(169), proving
    tropical rank ≥ 2. Since ω(169) = 1, the conjecture tropical_rank = ω(N) is false. -/
theorem monge_violation_169 :
    padicValNat 13 3 + padicValNat 13 169 ≠ padicValNat 13 5 + padicValNat 13 119 := by
  native_decide

/-! ### Counterexample 2: N = 25 = 5²

The 5-adic valuation matrix T₅(25) for the path (3,4,5)→(5,12,13)→(7,24,25):

    T₅ = [[0, 0, 1],
           [1, 0, 0],
           [0, 0, 2]]

Monge condition: T[0,0] + T[1,1] = 0 + 0 = 0 ≠ 1 = 0 + 1 = T[0,1] + T[1,0].
So tropical rank ≥ 2 > 1 = ω(25).
-/

/-- 5-adic valuations along the path to 25, row 0: (3, 4, 5) -/
theorem T5_25_row0 :
    (padicValNat 5 3, padicValNat 5 4, padicValNat 5 5) = (0, 0, 1) := by native_decide

/-- 5-adic valuations along the path to 25, row 1: (5, 12, 13) -/
theorem T5_25_row1 :
    (padicValNat 5 5, padicValNat 5 12, padicValNat 5 13) = (1, 0, 0) := by native_decide

/-- 5-adic valuations along the path to 25, row 2: (7, 24, 25) -/
theorem T5_25_row2 :
    (padicValNat 5 7, padicValNat 5 24, padicValNat 5 25) = (0, 0, 2) := by native_decide

/-- **Counterexample 2**: The Monge condition fails for T₅(25), proving
    tropical rank ≥ 2. Since ω(25) = 1, the conjecture tropical_rank = ω(N) is false. -/
theorem monge_violation_25 :
    padicValNat 5 3 + padicValNat 5 12 ≠ padicValNat 5 4 + padicValNat 5 5 := by
  native_decide

end Counterexamples

/-! ## Original Conjecture (Commented Out — Proved False)

The following theorem was the original conjecture. It is false, as demonstrated by the
counterexamples above. Even the weaker inequality direction `tropical_rank ≥ ω(N)` fails:
for N = 169 = 13², tropical rank ≥ 2 > 1 = ω(N), so not only is equality wrong, but
the inequality goes in the *wrong direction* — tropical rank can exceed ω(N).

Additionally, the theorem references several undefined functions (`tropicalValuationMatrix`,
`berggrenPathMatrix`, `Nat.factorCount`, `tropicalRank`, `newtonPolygonBreakpoints`,
`primeFactorization`, `det`) that do not exist in Mathlib.

```
theorem tropical_berggren_rank_factorization (N : ℕ) (hN : N > 1)
    (p : ℕ) [hp : Fact (Prime p)] (hdiv : p ∣ N) :
    let T := tropicalValuationMatrix p (berggrenPathMatrix N)
    let k := Nat.factorCount N
    tropicalRank T = k ∧
      ∀ i ∈ Finset.range k,
        (newtonPolygonBreakpoints (det T)) i = (primeFactorization N).val i := by
  sorry
```
-/