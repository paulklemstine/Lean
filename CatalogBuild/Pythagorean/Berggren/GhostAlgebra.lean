/-! # CatalogBuild.Pythagorean.Berggren.GhostAlgebra

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 65
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Berggren.GhostAlgebra
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 65] -/
def hParam (a b c : ℤ) : ℤ := 3*c - 2*(a + b)


def fourthGhost (a b c : ℤ) : ℤ × ℤ × ℤ := (-p a b c, -q a b c, hParam a b c)


def invB₁ (a b c : ℤ) : ℤ × ℤ × ℤ := (p a b c, -q a b c, hParam a b c)


def invB₂ (a b c : ℤ) : ℤ × ℤ × ℤ := (p a b c, q a b c, hParam a b c)


def invB₃ (a b c : ℤ) : ℤ × ℤ × ℤ := (-p a b c, q a b c, hParam a b c)


theorem hParam_alt (a b c : ℤ) : hParam a b c = -2*a - 2*b + 3*c := by
  simp only [hParam]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Fourth Ghost Pythagorean Theorem
-- ═══════════════════════════════════════════════════════════════


/-- The (p, q, h) triple is Pythagorean when (a, b, c) is. -/
theorem pqh_pythagorean (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    (p a b c)^2 + (q a b c)^2 = (hParam a b c)^2 := by
  simp only [p, q, hParam]; nlinarith


/-- The fourth ghost (−p, −q, h) is Pythagorean when (a,b,c) is. -/
theorem fourthGhost_pythagorean (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    (fourthGhost a b c).1^2 + (fourthGhost a b c).2.1^2 =
    (fourthGhost a b c).2.2^2 := by
  show (-p a b c)^2 + (-q a b c)^2 = (hParam a b c)^2
  simp only [p, q, hParam]; nlinarith


/-- All four ghost triples share the same hypotenuse. -/
theorem all_ghosts_same_hyp (a b c : ℤ) :
    (invB₁ a b c).2.2 = hParam a b c ∧
    (invB₂ a b c).2.2 = hParam a b c ∧
    (invB₃ a b c).2.2 = hParam a b c ∧
    (fourthGhost a b c).2.2 = hParam a b c :=
  ⟨rfl, rfl, rfl, rfl⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Klein Four-Group Component Extraction
-- ═══════════════════════════════════════════════════════════════

-- B₂⁻¹ = (p, q, h): identity element of Klein group
-- B₁⁻¹ = (p, −q, h): flip q sign
-- B₃⁻¹ = (−p, q, h): flip p sign
-- Fourth = (−p, −q, h): flip both signs


theorem invB₂_fst (a b c : ℤ) : (invB₂ a b c).1 = p a b c := rfl


theorem invB₂_snd (a b c : ℤ) : (invB₂ a b c).2.1 = q a b c := rfl


theorem invB₁_fst (a b c : ℤ) : (invB₁ a b c).1 = p a b c := rfl


theorem invB₁_snd (a b c : ℤ) : (invB₁ a b c).2.1 = -q a b c := rfl


theorem invB₃_fst (a b c : ℤ) : (invB₃ a b c).1 = -p a b c := rfl


theorem invB₃_snd (a b c : ℤ) : (invB₃ a b c).2.1 = q a b c := rfl


theorem fourthGhost_fst (a b c : ℤ) : (fourthGhost a b c).1 = -p a b c := rfl


theorem fourthGhost_snd (a b c : ℤ) : (fourthGhost a b c).2.1 = -q a b c := rfl

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Branch Determination by Signs
-- ═══════════════════════════════════════════════════════════════


theorem branch1_from_signs (a b c : ℤ) (hp : 0 < p a b c) (hq : q a b c < 0)
    (hh : 0 < hParam a b c) :
    0 < (invB₁ a b c).1 ∧ 0 < (invB₁ a b c).2.1 ∧ 0 < (invB₁ a b c).2.2 := by
  refine ⟨hp, ?_, hh⟩; show 0 < -q a b c; linarith


theorem branch2_from_signs (a b c : ℤ) (hp : 0 < p a b c) (hq : 0 < q a b c)
    (hh : 0 < hParam a b c) :
    0 < (invB₂ a b c).1 ∧ 0 < (invB₂ a b c).2.1 ∧ 0 < (invB₂ a b c).2.2 :=
  ⟨hp, hq, hh⟩


theorem branch3_from_signs (a b c : ℤ) (hp : p a b c < 0) (hq : 0 < q a b c)
    (hh : 0 < hParam a b c) :
    0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2 := by
  refine ⟨?_, hq, hh⟩; show 0 < -p a b c; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Product Sign Determines Branch
-- ═══════════════════════════════════════════════════════════════


theorem pq_product_pos_branch2 (a b c : ℤ) (hp : 0 < p a b c) (hq : 0 < q a b c) :
    0 < p a b c * q a b c := mul_pos hp hq


theorem pq_product_neg_branch1 (a b c : ℤ) (hp : 0 < p a b c) (hq : q a b c < 0) :
    p a b c * q a b c < 0 := mul_neg_of_pos_of_neg hp hq


theorem pq_product_neg_branch3 (a b c : ℤ) (hp : p a b c < 0) (hq : 0 < q a b c) :
    p a b c * q a b c < 0 := mul_neg_of_neg_of_pos hp hq

-- ═══════════════════════════════════════════════════════════════
-- Section 6: p-q Algebraic Identities
-- ═══════════════════════════════════════════════════════════════


theorem pq_sum (a b c : ℤ) : p a b c + q a b c = 3*(a + b) - 4*c := by
  simp only [p, q]; ring


theorem pq_diff (a b c : ℤ) : p a b c - q a b c = b - a := by
  simp only [p, q]; ring


theorem p_mod2 (a b c : ℤ) : p a b c % 2 = a % 2 := by unfold p; omega


theorem q_mod2 (a b c : ℤ) : q a b c % 2 = b % 2 := by unfold q; omega


theorem hParam_mod2 (a b c : ℤ) : hParam a b c % 2 = c % 2 := by unfold hParam; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Contraction Property
-- ═══════════════════════════════════════════════════════════════


theorem descent_gap (a b c : ℤ) : c - hParam a b c = 2*(a + b - c) := by
  simp only [hParam]; ring


theorem ppt_triangle (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2) :
    c < a + b := by
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_abs (a + b)]


theorem hParam_lt_c (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2) :
    hParam a b c < c := by
  have := ppt_triangle a b c ha hb hpyth; have := descent_gap a b c; linarith


theorem descent_gap_ge_two (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) : 2 ≤ c - hParam a b c := by
  have := ppt_triangle a b c ha hb hpyth; rw [descent_gap]; linarith


theorem hParam_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2)
    (hc : 5 ≤ c) : 0 < hParam a b c := by
  rw [hParam_alt]; nlinarith only [ha, hb, hpyth, hc, sq_nonneg (a - b)]

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Euclid Parameter Identities
-- ═══════════════════════════════════════════════════════════════


theorem p_euclid (m n : ℤ) :
    p (m^2 - n^2) (2*m*n) (m^2 + n^2) = -(m - n) * (m - 3*n) := by
  simp only [p]; ring


theorem q_euclid (m n : ℤ) :
    q (m^2 - n^2) (2*m*n) (m^2 + n^2) = 2*n*(m - 2*n) := by
  simp only [q]; ring


theorem hParam_euclid (m n : ℤ) :
    hParam (m^2 - n^2) (2*m*n) (m^2 + n^2) = (m - 2*n)^2 + n^2 := by
  simp only [hParam]; ring


theorem hParam_sum_of_squares (m n : ℤ) :
    ∃ u v : ℤ, hParam (m^2 - n^2) (2*m*n) (m^2 + n^2) = u^2 + v^2 :=
  ⟨m - 2*n, n, hParam_euclid m n⟩


theorem pq_product_euclid (m n : ℤ) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) * q (m^2-n^2) (2*m*n) (m^2+n^2) =
    -2*n*(m - n)*(m - 2*n)*(m - 3*n) := by rw [p_euclid, q_euclid]; ring


theorem descent_gap_euclid (m n : ℤ) :
    (m^2 + n^2) - hParam (m^2-n^2) (2*m*n) (m^2+n^2) = 4*n*(m - n) := by
  rw [hParam_euclid]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Syndrome / Error Detection
-- ═══════════════════════════════════════════════════════════════


/-- **Syndrome = Lorentz Form**: The ghost map preserves the Lorentz quadratic form.
This means p² + q² − h² = a² + b² − c². -/
theorem syndrome_eq_Q (a b c : ℤ) :
    syndrome a b c = a^2 + b^2 - c^2 := by
  simp only [syndrome, p, q, hParam]; ring


/-- A Pythagorean triple has zero syndrome. -/
theorem syndrome_zero_of_pyth (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    syndrome a b c = 0 := by
  rw [syndrome_eq_Q]; linarith


/-- If the syndrome is nonzero, the triple is NOT Pythagorean.
This gives single-query error detection for corrupted triples. -/
theorem not_pyth_of_syndrome_ne (a b c : ℤ) (hs : syndrome a b c ≠ 0) :
    a^2 + b^2 ≠ c^2 := fun hp => hs (syndrome_zero_of_pyth a b c hp)

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Double Descent (M² Formulas)
-- ═══════════════════════════════════════════════════════════════


/-- Double descent p: applying p to (p,q,h) gives 9a + 8b − 12c. -/
theorem double_descent_p (a b c : ℤ) :
    p (p a b c) (q a b c) (hParam a b c) = 9*a + 8*b - 12*c := by
  simp only [p, q, hParam]; ring


/-- Double descent q: applying q to (p,q,h) gives 8a + 9b − 12c. -/
theorem double_descent_q (a b c : ℤ) :
    q (p a b c) (q a b c) (hParam a b c) = 8*a + 9*b - 12*c := by
  simp only [p, q, hParam]; ring


/-- Double descent h: applying h to (p,q,h) gives −12a − 12b + 17c. -/
theorem double_descent_hParam (a b c : ℤ) :
    hParam (p a b c) (q a b c) (hParam a b c) = -12*a - 12*b + 17*c := by
  simp only [p, q, hParam]; ring


/-- The double-descent p and q differ by b − a (same as single descent). -/
theorem double_descent_pq_diff (a b c : ℤ) :
    p (p a b c) (q a b c) (hParam a b c) -
    q (p a b c) (q a b c) (hParam a b c) = a - b := by
  rw [double_descent_p, double_descent_q]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Leg Swap
-- ═══════════════════════════════════════════════════════════════


theorem p_swap (a b c : ℤ) : p b a c = q a b c := by simp only [p, q]; ring


theorem q_swap (a b c : ℤ) : q b a c = p a b c := by simp only [p, q]; ring


theorem hParam_swap (a b c : ℤ) : hParam b a c = hParam a b c := by
  simp only [hParam]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Concrete Fourth Ghost Examples
-- ═══════════════════════════════════════════════════════════════


/-- Fourth ghost of (3,4,5) is (−1, 0, 1). -/
theorem fourthGhost_345 : fourthGhost 3 4 5 = (-1, 0, 1) := by decide


/-- Fourth ghost of (5,12,13) is (−3, 4, 5). -/
theorem fourthGhost_51213 : fourthGhost 5 12 13 = (-3, 4, 5) := by decide


/-- Fourth ghost of (8,15,17) is (−4, 3, 5). -/
theorem fourthGhost_81517 : fourthGhost 8 15 17 = (-4, 3, 5) := by decide

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Ghost Map = B₂⁻¹ (Matrix Form)
-- ═══════════════════════════════════════════════════════════════


/-- The ghost map (a,b,c) ↦ (p,q,h) is exactly B₂⁻¹. -/
theorem ghost_map_is_B₂_inv (a b c : ℤ) :
    (p a b c, q a b c, hParam a b c) = invB₂ a b c := rfl


/-- M² = !![9, 8, -12; 8, 9, -12; -12, -12, 17]. -/
theorem ghostMatrix_sq :
    ghostMatrix * ghostMatrix = !![9, 8, -12; 8, 9, -12; -12, -12, 17] := by native_decide


/-- Trace of M² is 35. -/
theorem ghostMatrix_sq_trace : Matrix.trace (ghostMatrix * ghostMatrix) = 35 := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Quadratic Form Boundaries
-- ═══════════════════════════════════════════════════════════════


/-- At the boundary m = 2n: q = 0 (root case). -/
theorem boundary_m_eq_2n (n : ℤ) :
    q ((2*n)^2 - n^2) (2*(2*n)*n) ((2*n)^2 + n^2) = 0 := by simp only [q]; ring


/-- At the boundary m = 3n: p = 0. -/
theorem boundary_m_eq_3n (n : ℤ) :
    p ((3*n)^2 - n^2) (2*(3*n)*n) ((3*n)^2 + n^2) = 0 := by simp only [p]; ring


theorem root_is_boundary : (2:ℤ)^2 - 1^2 = 3 ∧ 2*(2:ℤ)*1 = 4 ∧ (2:ℤ)^2 + 1^2 = 5 := by
  norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Branch Uniqueness
-- ═══════════════════════════════════════════════════════════════


/-- If p > 0 and q > 0, then B₁⁻¹ and B₃⁻¹ fail to produce all-positive. -/
theorem branch2_unique (a b c : ℤ) (hp : 0 < p a b c) (hq : 0 < q a b c) :
    ¬(0 < (invB₁ a b c).2.1) ∧ ¬(0 < (invB₃ a b c).1) := by
  constructor
  · show ¬(0 < -q a b c); linarith
  · show ¬(0 < -p a b c); linarith


/-- If p > 0 and q < 0, then B₂⁻¹ and B₃⁻¹ fail. -/
theorem branch1_unique (a b c : ℤ) (hp : 0 < p a b c) (hq : q a b c < 0) :
    ¬(0 < (invB₂ a b c).2.1) ∧ ¬(0 < (invB₃ a b c).1) := by
  constructor
  · show ¬(0 < q a b c); linarith
  · show ¬(0 < -p a b c); linarith


/-- If p < 0 and q > 0, then B₁⁻¹ and B₂⁻¹ fail. -/
theorem branch3_unique (a b c : ℤ) (hp : p a b c < 0) (_hq : 0 < q a b c) :
    ¬(0 < (invB₁ a b c).1) ∧ ¬(0 < (invB₂ a b c).1) := by
  constructor
  · show ¬(0 < p a b c); linarith
  · show ¬(0 < p a b c); linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 16: p·q Root Structure
-- ═══════════════════════════════════════════════════════════════


/-- p·q vanishes at exactly the branch boundaries m = n, m = 2n, m = 3n
(given n ≠ 0). -/
theorem pq_zero_iff_boundary (m n : ℤ) (hn : n ≠ 0) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) * q (m^2-n^2) (2*m*n) (m^2+n^2) = 0 ↔
    m = n ∨ m = 2*n ∨ m = 3*n := by
  rw [pq_product_euclid]
  constructor
  · intro hprod
    have : n * ((m - n) * ((m - 2*n) * (m - 3*n))) = 0 := by nlinarith
    rcases mul_eq_zero.mp this with h1 | h1
    · exact absurd h1 hn
    · rcases mul_eq_zero.mp h1 with h2 | h2
      · left; linarith
      · rcases mul_eq_zero.mp h2 with h3 | h3
        · right; left; linarith
        · right; right; linarith
  · rintro (rfl | rfl | rfl) <;> ring

-- ═══════════════════════════════════════════════════════════════
-- Section 17: Euclid Branch Conditions
-- ═══════════════════════════════════════════════════════════════


theorem euclid_branch1_signs (m n : ℤ) (hn : 0 < n) (h1 : n < m) (h2 : m < 2*n) :
    0 < p (m^2-n^2) (2*m*n) (m^2+n^2) ∧
    q (m^2-n^2) (2*m*n) (m^2+n^2) < 0 := by
  rw [p_euclid, q_euclid]; constructor <;> nlinarith


theorem euclid_branch2_signs (m n : ℤ) (hn : 0 < n) (h1 : 2*n < m) (h2 : m < 3*n) :
    0 < p (m^2-n^2) (2*m*n) (m^2+n^2) ∧
    0 < q (m^2-n^2) (2*m*n) (m^2+n^2) := by
  rw [p_euclid, q_euclid]; constructor <;> nlinarith


theorem euclid_branch3_signs (m n : ℤ) (hn : 0 < n) (h1 : 3*n < m) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) < 0 ∧
    0 < q (m^2-n^2) (2*m*n) (m^2+n^2) := by
  rw [p_euclid, q_euclid]; constructor <;> nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 18: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms fourthGhost_pythagorean
#print axioms syndrome_eq_Q
#print axioms double_descent_p
#print axioms ghostMatrix_lorentz
#print axioms pq_zero_iff_boundary


