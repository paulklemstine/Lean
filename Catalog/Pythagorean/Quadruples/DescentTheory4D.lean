import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.DescentTheory4D

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 35
-/

/-- ═══════════════════════════════════════════════════════════════ Section 1: Basic Definitions ═══════════════════════════════════════════════════════════════ -/
def IsPQ4 (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2

/-- When a ≤ b ≤ c, the (2,3)-lift (excluding a) gives the smallest parent hypotenuse. -/
theorem best_plane_ordered (a b c d : ℤ) (hab : a ≤ b) (hbc : b ≤ c) :
    parentHyp23 a b c d ≤ parentHyp13 a b c d ∧
    parentHyp23 a b c d ≤ parentHyp12 a b c d := by
  simp only [parentHyp12, parentHyp13, parentHyp23]
  constructor <;> linarith

/-- The plane excluding the smallest component gives the smallest parent hypotenuse. -/
theorem exclude_smallest_is_best (a b c d : ℤ)
    (ha_min : a ≤ b) (ha_min' : a ≤ c) :
    parentHyp23 a b c d ≤ parentHyp12 a b c d ∧
    parentHyp23 a b c d ≤ parentHyp13 a b c d := by
  simp only [parentHyp12, parentHyp13, parentHyp23]
  constructor <;> linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Descent Rate Bounds
-- ═══════════════════════════════════════════════════════════════

theorem parentHyp23_alt (a b c d : ℤ) :
    parentHyp23 a b c d = 3 * d - 2 * (b + c) := by
  simp [parentHyp23]; ring

/-- When b + c > d, the parent hypotenuse from the (2,3)-plane is < d. -/
theorem descent_when_sum_exceeds (a b c d : ℤ) (h : b + c > d) :
    parentHyp23 a b c d < d := by
  simp [parentHyp23]; linarith

/-- For any positive ordered PQ, the two largest components sum to more than d. -/
theorem two_largest_sum_exceeds_d (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (hpq : IsPQ4 a b c d) (hab : a ≤ b) (hbc : b ≤ c) :
    b + c > d := by
  simp [IsPQ4] at hpq
  nlinarith [sq_nonneg (b - a), sq_nonneg (c - a), sq_nonneg a]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Specific Descent Examples
-- ═══════════════════════════════════════════════════════════════

theorem pq_1223 : IsPQ4 1 2 2 3 := by unfold IsPQ4; norm_num

theorem descent_2367_via_23 : parentHyp23 2 3 6 7 = 3 := by simp [parentHyp23]

theorem descent_1489_via_23 : parentHyp23 1 4 8 9 = 3 := by simp [parentHyp23]

theorem descent_26911_via_23 : parentHyp23 2 6 9 11 = 3 := by simp [parentHyp23]

theorem pq_3_6_22_23 : IsPQ4 3 6 22 23 := by unfold IsPQ4; norm_num

theorem descent_3_6_22_23 : parentHyp23 3 6 22 23 = 13 := by simp [parentHyp23]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Matrix Properties
-- ═══════════════════════════════════════════════════════════════

def M12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 2, 0, (-2); 2, 1, 0, (-2); 0, 0, 1, 0; (-2), (-2), 0, 3]

def M13 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 2, (-2); 0, 1, 0, 0; 2, 0, 1, (-2); (-2), 0, (-2), 3]

def M23 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 2, (-2); 0, 2, 1, (-2); 0, (-2), (-2), 3]

/-- All three lifted matrices have determinant -1 (orientation-reversing). -/
theorem det_M12 : M12.det = -1 := by native_decide

theorem det_M13 : M13.det = -1 := by native_decide

theorem det_M23 : M23.det = -1 := by native_decide

/-- All three lifted matrices have trace 6. -/
theorem trace_M12 : M12.trace = 6 := by native_decide

theorem trace_M13 : M13.trace = 6 := by native_decide

theorem trace_M23 : M23.trace = 6 := by native_decide

/-- The lifted transforms don't commute (non-abelian structure). -/
theorem M12_M23_noncomm : M12 * M23 ≠ M23 * M12 := by native_decide

theorem M12_M13_noncomm : M12 * M13 ≠ M13 * M12 := by native_decide

theorem M13_M23_noncomm : M13 * M23 ≠ M23 * M13 := by native_decide

/-- Composed descent M₁₂·M₂₃ has order > 2. -/
theorem M12_M23_order_gt2 : (M12 * M23) ^ 2 ≠ 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Primitivity
-- ═══════════════════════════════════════════════════════════════

def isPrimPQ4 (a b c d : ℤ) : Prop :=
  IsPQ4 a b c d ∧ Int.gcd (Int.gcd a b) (Int.gcd c d) = 1

theorem prim_1223 : isPrimPQ4 1 2 2 3 := by
  constructor
  · exact pq_1223
  · native_decide

theorem prim_2367 : isPrimPQ4 2 3 6 7 := by
  constructor
  · unfold IsPQ4; norm_num
  · native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Component Bounds
-- ═══════════════════════════════════════════════════════════════

/-- Each spatial component is strictly less than d (when all positive). -/
theorem spatial_lt_hyp (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (h : IsPQ4 a b c d) : a < d ∧ b < d ∧ c < d := by
  simp [IsPQ4] at h
  refine ⟨?_, ?_, ?_⟩ <;> nlinarith [sq_nonneg b, sq_nonneg c, sq_nonneg a]

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Sums of Three Squares Connection
-- ═══════════════════════════════════════════════════════════════

theorem pq_iff_sum3sq (d : ℤ) :
    (∃ a b c, IsPQ4 a b c d) ↔ (∃ a b c : ℤ, a^2 + b^2 + c^2 = d^2) := by
  simp [IsPQ4]

theorem pq_trivial (d : ℤ) : IsPQ4 0 0 d d := by unfold IsPQ4; ring

theorem pq_trivial2 (d : ℤ) : IsPQ4 d 0 0 d := by unfold IsPQ4; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Scaling
-- ═══════════════════════════════════════════════════════════════

/-- Scaling a PQ by k gives another PQ. -/
theorem pq_scaling (a b c d k : ℤ) (h : IsPQ4 a b c d) :
    IsPQ4 (k*a) (k*b) (k*c) (k*d) := by
  simp only [IsPQ4] at *; ring_nf; nlinarith [sq_nonneg k]

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Triangle Inequality
-- ═══════════════════════════════════════════════════════════════

/-- Triangle inequality for positive Pythagorean quadruples. -/
theorem pq_triangle (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpq : IsPQ4 a b c d) (hd : 0 < d) :
    a + b + c > d := by
  simp [IsPQ4] at hpq
  nlinarith [sq_nonneg (a - b), sq_nonneg (a - c), sq_nonneg (b - c)]

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Descent Guarantees
-- ═══════════════════════════════════════════════════════════════

/-- For any positive ordered PQ, the (2,3)-plane always gives descent. -/
theorem guaranteed_descent_ordered (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (hpq : IsPQ4 a b c d) (hab : a ≤ b) (hbc : b ≤ c) :
    parentHyp23 a b c d < d := by
  have hbc_gt := two_largest_sum_exceeds_d a b c d ha hb hc hd hpq hab hbc
  exact descent_when_sum_exceeds a b c d hbc_gt

-- ═══════════════════════════════════════════════════════════════
-- Axiom checks
-- ═══════════════════════════════════════════════════════════════

#print axioms best_plane_ordered
#print axioms two_largest_sum_exceeds_d
#print axioms det_M12
#print axioms pq_triangle
#print axioms guaranteed_descent_ordered

