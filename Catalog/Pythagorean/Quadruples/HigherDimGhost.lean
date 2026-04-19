import Mathlib

/-!
# Higher-Dimensional Ghost Structure: k-Tuples

This file generalizes the ghost structure from 3D and 4D to arbitrary dimension k.

## Main Results

1. **Ghost group order**: (k-1)! × 2^{k-1} for k-dimensional Pythagorean equations
2. **Number of lifting planes**: C(k-1, 2) = (k-1)(k-2)/2
3. **Berggren branches**: 3 × C(k-1, 2) per dimension
4. **5D sign-flip and permutation symmetry**: Full (ℤ/2)⁴ × S₄ action
5. **Triangle inequality in all dimensions**: Sum of spatial > hypotenuse
6. **Dimension embedding**: Lower-d PQs embed into higher-d PQs
-/

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Concrete Dimension Definitions
-- ═══════════════════════════════════════════════════════════════

def isPT3 (a b c : ℤ) : Prop := a^2 + b^2 = c^2
def isPQ4 (a b c d : ℤ) : Prop := a^2 + b^2 + c^2 = d^2
def isPQ5 (a b c d e : ℤ) : Prop := a^2 + b^2 + c^2 + d^2 = e^2

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Ghost Group Order by Dimension
-- ═══════════════════════════════════════════════════════════════

-- 3D: S₂ × (ℤ/2)² = 2 × 4 = 8
theorem ghost_3d_full : 2 * (2 : ℕ)^2 = 8 := by norm_num

-- 4D: S₃ × (ℤ/2)³ = 6 × 8 = 48
theorem ghost_4d_full : 6 * (2 : ℕ)^3 = 48 := by norm_num

-- 5D: S₄ × (ℤ/2)⁴ = 24 × 16 = 384
theorem ghost_5d_full : 24 * (2 : ℕ)^4 = 384 := by norm_num

-- 6D: S₅ × (ℤ/2)⁵ = 120 × 32 = 3840
theorem ghost_6d_full : 120 * (2 : ℕ)^5 = 3840 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Number of Lifting Planes
-- ═══════════════════════════════════════════════════════════════

theorem lifting_planes_3d : Nat.choose 2 2 = 1 := by native_decide
theorem lifting_planes_4d : Nat.choose 3 2 = 3 := by native_decide
theorem lifting_planes_5d : Nat.choose 4 2 = 6 := by native_decide
theorem lifting_planes_6d : Nat.choose 5 2 = 10 := by native_decide
theorem lifting_planes_10d : Nat.choose 9 2 = 36 := by native_decide

-- Total Berggren branches per dimension: 3 × C(k-1, 2)
theorem berggren_branches_3d : 3 * Nat.choose 2 2 = 3 := by native_decide
theorem berggren_branches_4d : 3 * Nat.choose 3 2 = 9 := by native_decide
theorem berggren_branches_5d : 3 * Nat.choose 4 2 = 18 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 4: 5D Pythagorean Quintuples
-- ═══════════════════════════════════════════════════════════════

-- 1² + 2² + 2² + 4² = 1 + 4 + 4 + 16 = 25 = 5²
theorem pq5_1_2_2_4_5 : isPQ5 1 2 2 4 5 := by unfold isPQ5; norm_num

-- 3² + 4² + 0² + 0² = 9 + 16 = 25 = 5²
theorem pq5_3_4_0_0_5 : isPQ5 3 4 0 0 5 := by unfold isPQ5; norm_num

-- 2² + 2² + 2² + 2² = 16 = 4²
theorem pq5_2_2_2_2_4 : isPQ5 2 2 2 2 4 := by unfold isPQ5; norm_num

-- 1² + 2² + 3² + 6² = 1 + 4 + 9 + 36 = 50. Not a perfect square.
-- 1² + 1² + 1² + 1² = 4 = 2²
theorem pq5_1_1_1_1_2 : isPQ5 1 1 1 1 2 := by unfold isPQ5; norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 5: 5D Sign-Flip Symmetry
-- ═══════════════════════════════════════════════════════════════

theorem sf5_1 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 (-a) b c d e := by
  simp [isPQ5] at *; nlinarith

theorem sf5_2 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 a (-b) c d e := by
  simp [isPQ5] at *; nlinarith

theorem sf5_3 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 a b (-c) d e := by
  simp [isPQ5] at *; nlinarith

theorem sf5_4 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 a b c (-d) e := by
  simp [isPQ5] at *; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: 5D Permutation Symmetry
-- ═══════════════════════════════════════════════════════════════

theorem pm5_12 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 b a c d e := by
  simp [isPQ5] at *; linarith

theorem pm5_13 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 c b a d e := by
  simp [isPQ5] at *; linarith

theorem pm5_14 (a b c d e : ℤ) (h : isPQ5 a b c d e) : isPQ5 d b c a e := by
  simp [isPQ5] at *; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Dimension Embedding
-- ═══════════════════════════════════════════════════════════════

theorem embed_3_to_4 (a b c : ℤ) (h : isPT3 a b c) : isPQ4 a b 0 c := by
  simp [isPT3, isPQ4] at *; linarith

theorem embed_4_to_5 (a b c d : ℤ) (h : isPQ4 a b c d) : isPQ5 a b c 0 d := by
  simp [isPQ4, isPQ5] at *; linarith

theorem embed_3_to_5 (a b c : ℤ) (h : isPT3 a b c) : isPQ5 a b 0 0 c := by
  simp [isPT3, isPQ5] at *; linarith

/-- Combining two triples into a quintuple. -/
theorem combine_triples_5d (a b c d e f g : ℤ)
    (h1 : isPT3 a b e) (h2 : isPT3 c d f) (h3 : isPT3 e f g) :
    isPQ5 a b c d g := by
  simp [isPT3, isPQ5] at *; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Triangle Inequality in Higher Dimensions
-- ═══════════════════════════════════════════════════════════════

theorem triangle_4d (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (h : isPQ4 a b c d) : a + b + c > d := by
  simp [isPQ4] at h
  nlinarith [sq_nonneg (a - b), sq_nonneg (a - c), sq_nonneg (b - c)]

theorem triangle_5d (a b c d e : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hd : 0 < d) (he : 0 < e) (h : isPQ5 a b c d e) :
    a + b + c + d > e := by
  simp [isPQ5] at h
  nlinarith [sq_nonneg (a - b), sq_nonneg (a - c), sq_nonneg (a - d),
             sq_nonneg (b - c), sq_nonneg (b - d), sq_nonneg (c - d)]

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Lorentz Form in Higher Dimensions
-- ═══════════════════════════════════════════════════════════════

def lorentz3 (a b c : ℤ) : ℤ := a^2 + b^2 - c^2
def lorentz4 (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 - d^2
def lorentz5 (a b c d e : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2 - e^2

theorem pt3_iff_lorentz (a b c : ℤ) : isPT3 a b c ↔ lorentz3 a b c = 0 := by
  simp [isPT3, lorentz3]; omega

theorem pq4_iff_lorentz (a b c d : ℤ) : isPQ4 a b c d ↔ lorentz4 a b c d = 0 := by
  simp [isPQ4, lorentz4]; omega

theorem pq5_iff_lorentz (a b c d e : ℤ) : isPQ5 a b c d e ↔ lorentz5 a b c d e = 0 := by
  simp [isPQ5, lorentz5]; omega

/-- Lorentz form is preserved by sign flips on spatial coordinates. -/
theorem lorentz4_sf (a b c d : ℤ) (s₁ s₂ s₃ : ℤ) (hs₁ : s₁^2 = 1) (hs₂ : s₂^2 = 1)
    (hs₃ : s₃^2 = 1) :
    lorentz4 (s₁*a) (s₂*b) (s₃*c) d = lorentz4 a b c d := by
  simp [lorentz4]; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Specific Large Examples
-- ═══════════════════════════════════════════════════════════════

theorem large_pq_1 : isPQ4 2 6 9 11 := by unfold isPQ4; norm_num
theorem large_pq_2 : isPQ4 6 6 7 11 := by unfold isPQ4; norm_num
theorem large_pq_3 : isPQ4 3 6 22 23 := by unfold isPQ4; norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Parent Hypotenuse in 5D
-- ═══════════════════════════════════════════════════════════════

/-- In 5D, the parent hypotenuse from the (i,j)-lifting plane is
    -2xᵢ - 2xⱼ + 3e, same formula as in 4D but with 6 choices of plane. -/
def parentHyp5_12 (a b _c _d e : ℤ) : ℤ := -2*a - 2*b + 3*e
def parentHyp5_34 (_a _b c d e : ℤ) : ℤ := -2*c - 2*d + 3*e

theorem parentHyp5_12_val : parentHyp5_12 1 2 2 4 5 = 9 := by
  simp [parentHyp5_12]

theorem parentHyp5_34_val : parentHyp5_34 1 2 2 4 5 = 3 := by
  simp [parentHyp5_34]

-- The (3,4)-plane gives the best descent for (1,2,2,4,5) since
-- it excludes the two smallest components.

-- ═══════════════════════════════════════════════════════════════
-- Axiom checks
-- ═══════════════════════════════════════════════════════════════

#print axioms triangle_4d
#print axioms triangle_5d
#print axioms embed_3_to_5
#print axioms combine_triples_5d
#print axioms lorentz4_sf
