import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.SpectralTheory

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 66
-/

/-! ## Reconstructed definitions

The catalogue file carrying the ghost-triple maps used below is missing from this
repository, so they are reconstructed here from the statements proved in this file:
`p`, `q`, `h` are the three components of the Barning–Hall parent map, and
`fwdB1`/`invB1`, `fwdB3`/`invB3` are the branch-1 and branch-3 Berggren child maps
together with their inverses. -/

/-- First component of the ghost/parent map. -/
def p (a b c : ℤ) : ℤ := a + 2*b - 2*c

/-- Second component of the ghost/parent map. -/
def q (a b c : ℤ) : ℤ := 2*a + b - 2*c

/-- Third component of the ghost/parent map. -/
def h (a b c : ℤ) : ℤ := -2*a - 2*b + 3*c

/-- Berggren branch-1 child map (the matrix `[[1,2,2],[2,1,2],[2,2,3]]`). -/
def fwdB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Inverse of `fwdB1`, given by the ghost map `(p, q, h)`. -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (p a b c, q a b c, h a b c)

/-- Berggren branch-3 child map (the matrix `[[-1,2,2],[-2,1,2],[-2,2,3]]`). -/
def fwdB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Inverse of `fwdB3`; its last component is again `h`. -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, h a b c)

/-- The Barning–Hall parent matrix, whose rows are `p`, `q`, `h`. -/
def M : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- The ghost map `(a,b,c) ↦ (p,q,h)`, i.e. multiplication by `M`. -/
def ghostMap (a b c : ℤ) : ℤ × ℤ × ℤ := (p a b c, q a b c, h a b c)

/-- The Lorentz form of signature (2,1). -/
def eta : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The second Berggren child matrix; it is the inverse of `M`. -/
def B2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- **Key correction**: p + q + h = a + b − c, NOT a + b + c. -/
theorem sum_correction (a b c : ℤ) : p a b c + q a b c + h a b c = a + b - c := by
  simp only [p, q, h]; ring

theorem sum_not_preserved_example :
    (p 3 4 5) + (q 3 4 5) + (h 3 4 5) ≠ 3 + 4 + 5 := by native_decide

theorem sum_345 : p 3 4 5 + q 3 4 5 + h 3 4 5 = 2 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Forward-Inverse Round Trips (ALL branches)
-- ═══════════════════════════════════════════════════════════════

theorem fwdB1_invB1_id (a b c : ℤ) :
    let inv := invB1 a b c
    fwdB1 inv.1 inv.2.1 inv.2.2 = (a, b, c) := by
  simp only [invB1, fwdB1, p, q, h]; ext <;> simp <;> ring

theorem invB1_fwdB1_id (a b c : ℤ) :
    let fwd := fwdB1 a b c
    invB1 fwd.1 fwd.2.1 fwd.2.2 = (a, b, c) := by
  simp only [invB1, fwdB1, p, q, h]; ext <;> simp <;> ring

theorem fwdB3_invB3_id (a b c : ℤ) :
    let inv := invB3 a b c
    fwdB3 inv.1 inv.2.1 inv.2.2 = (a, b, c) := by
  simp only [invB3, fwdB3, p, q, h]; ext <;> simp <;> ring

theorem invB3_fwdB3_id (a b c : ℤ) :
    let fwd := fwdB3 a b c
    invB3 fwd.1 fwd.2.1 fwd.2.2 = (a, b, c) := by
  simp only [invB3, fwdB3, p, q, h]; ext <;> simp <;> ring

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Higher Matrix Powers
-- ═══════════════════════════════════════════════════════════════

theorem M5_eq : M ^ 5 = !![1681, 1682, -2378;
                            1682, 1681, -2378;
                            -2378, -2378, 3363] := by native_decide

theorem M6_eq : M ^ 6 = !![9801, 9800, -13860;
                            9800, 9801, -13860;
                            -13860, -13860, 19601] := by native_decide

theorem M7_eq : M ^ 7 = !![57121, 57122, -80782;
                            57122, 57121, -80782;
                            -80782, -80782, 114243] := by native_decide

theorem M8_eq : M ^ 8 = !![332929, 332928, -470832;
                            332928, 332929, -470832;
                            -470832, -470832, 665857] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Trace Sequence
-- ═══════════════════════════════════════════════════════════════

theorem trace_M6 : Matrix.trace (M ^ 6) = 39203 := by native_decide

theorem trace_M7 : Matrix.trace (M ^ 7) = 228485 := by native_decide

theorem trace_M8 : Matrix.trace (M ^ 8) = 1331715 := by native_decide

theorem trace_recurrence_6 :
    Matrix.trace (M ^ 6) =
    5 * Matrix.trace (M ^ 5) + 5 * Matrix.trace (M ^ 4) - Matrix.trace (M ^ 3) := by
  native_decide

theorem trace_recurrence_7 :
    Matrix.trace (M ^ 7) =
    5 * Matrix.trace (M ^ 6) + 5 * Matrix.trace (M ^ 5) - Matrix.trace (M ^ 4) := by
  native_decide

theorem trace_recurrence_8 :
    Matrix.trace (M ^ 8) =
    5 * Matrix.trace (M ^ 7) + 5 * Matrix.trace (M ^ 6) - Matrix.trace (M ^ 5) := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Cayley-Hamilton Powers Recurrence
-- ═══════════════════════════════════════════════════════════════

theorem cayley_hamilton_pow :
    M ^ 3 = 5 • (M ^ 2) + 5 • M - (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

theorem power_recurrence_4 :
    M ^ 4 = 5 • (M ^ 3) + 5 • (M ^ 2) - M := by native_decide

theorem power_recurrence_5 :
    M ^ 5 = 5 • (M ^ 4) + 5 • (M ^ 3) - M ^ 2 := by native_decide

theorem power_recurrence_6 :
    M ^ 6 = 5 • (M ^ 5) + 5 • (M ^ 4) - M ^ 3 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Degenerate Orbit
-- ═══════════════════════════════════════════════════════════════

/-- (3,4,5) → (1,0,1) under ghost map. -/
theorem orbit_step1 : ghostMap 3 4 5 = (1, 0, 1) := by native_decide

/-- (1,0,1) → (−1,0,1). -/
theorem orbit_step2 : ghostMap 1 0 1 = (-1, 0, 1) := by native_decide

/-- (−1,0,1) → (−3,−4,5). -/
theorem orbit_step3 : ghostMap (-1) 0 1 = (-3, -4, 5) := by native_decide

/-- (−3,−4,5) → (−21,−20,29): the orbit does NOT cycle back. -/
theorem orbit_step4 : ghostMap (-3) (-4) 5 = (-21, -20, 29) := by native_decide

/-- (1,0,1) satisfies the Pythagorean equation trivially. -/
theorem degenerate_pyth : (1 : ℤ)^2 + 0^2 = 1^2 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Matrix Structural Properties
-- ═══════════════════════════════════════════════════════════════

theorem M2_sym : (M ^ 2) 0 0 = (M ^ 2) 1 1 ∧ (M ^ 2) 0 2 = (M ^ 2) 1 2 := by
  constructor <;> native_decide

theorem M3_sym : (M ^ 3) 0 0 = (M ^ 3) 1 1 ∧ (M ^ 3) 0 2 = (M ^ 3) 1 2 := by
  constructor <;> native_decide

theorem M5_sym : (M ^ 5) 0 0 = (M ^ 5) 1 1 ∧ (M ^ 5) 0 2 = (M ^ 5) 1 2 := by
  constructor <;> native_decide

/-- M^n[0,1] − M^n[0,0] alternates: +1 for odd n, −1 for even n. -/
theorem M1_offdiag : M 0 1 - M 0 0 = 1 := by native_decide

theorem M2_offdiag : (M ^ 2) 0 1 - (M ^ 2) 0 0 = -1 := by native_decide

theorem M3_offdiag : (M ^ 3) 0 1 - (M ^ 3) 0 0 = 1 := by native_decide

theorem M4_offdiag : (M ^ 4) 0 1 - (M ^ 4) 0 0 = -1 := by native_decide

theorem M5_offdiag : (M ^ 5) 0 1 - (M ^ 5) 0 0 = 1 := by native_decide

theorem M6_offdiag : (M ^ 6) 0 1 - (M ^ 6) 0 0 = -1 := by native_decide

theorem M7_offdiag : (M ^ 7) 0 1 - (M ^ 7) 0 0 = 1 := by native_decide

theorem M8_offdiag : (M ^ 8) 0 1 - (M ^ 8) 0 0 = -1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Pell Number Connection
-- ═══════════════════════════════════════════════════════════════

/-- M[0,0] entries: 1, 9, 49, 289, 1681, 9801 — squares of companion Pell numbers. -/
theorem M00_are_squares :
    M 0 0 = 1^2 ∧ (M ^ 2) 0 0 = 3^2 ∧ (M ^ 3) 0 0 = 7^2 ∧
    (M ^ 4) 0 0 = 17^2 ∧ (M ^ 5) 0 0 = 41^2 ∧ (M ^ 6) 0 0 = 99^2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

theorem companion_pell_recurrence :
    (3 : ℤ) = 2 * 1 + 1 ∧ (7 : ℤ) = 2 * 3 + 1 ∧ (17 : ℤ) = 2 * 7 + 3 ∧
    (41 : ℤ) = 2 * 17 + 7 ∧ (99 : ℤ) = 2 * 41 + 17 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num

/-- M[2,2] entries: NSW numbers 3, 17, 99, 577, 3363, 19601. -/
theorem nsw_values :
    M 2 2 = 3 ∧ (M ^ 2) 2 2 = 17 ∧ (M ^ 3) 2 2 = 99 ∧
    (M ^ 4) 2 2 = 577 ∧ (M ^ 5) 2 2 = 3363 ∧ (M ^ 6) 2 2 = 19601 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

theorem nsw_recurrence :
    (M ^ 3) 2 2 = 6 * (M ^ 2) 2 2 - M 2 2 ∧
    (M ^ 4) 2 2 = 6 * (M ^ 3) 2 2 - (M ^ 2) 2 2 ∧
    (M ^ 5) 2 2 = 6 * (M ^ 4) 2 2 - (M ^ 3) 2 2 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- M[0,2] entries: −2, −12, −70, −408, −2378, −13860. -/
theorem M02_values :
    M 0 2 = -2 ∧ (M ^ 2) 0 2 = -12 ∧ (M ^ 3) 0 2 = -70 ∧
    (M ^ 4) 0 2 = -408 ∧ (M ^ 5) 0 2 = -2378 ∧ (M ^ 6) 0 2 = -13860 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Error Detection
-- ═══════════════════════════════════════════════════════════════

/-- Error in a by ε: recovery equation detects it. -/
theorem error_detection_a (a b c ε : ℤ) (hε : ε ≠ 0) :
    p (a + ε) b c + 2 * q (a + ε) b c + 2 * h (a + ε) b c ≠ a := by
  simp only [p, q, h]; omega

/-- Error in b by ε: detected. -/
theorem error_detection_b (a b c ε : ℤ) (hε : ε ≠ 0) :
    2 * p a (b + ε) c + q a (b + ε) c + 2 * h a (b + ε) c ≠ b := by
  simp only [p, q, h]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Determinant of Powers
-- ═══════════════════════════════════════════════════════════════

theorem det_M1 : M.det = -1 := by native_decide

theorem det_M2 : (M ^ 2).det = 1 := by native_decide

theorem det_M3 : (M ^ 3).det = -1 := by native_decide

theorem det_M4 : (M ^ 4).det = 1 := by native_decide

theorem det_M5 : (M ^ 5).det = -1 := by native_decide

theorem det_M6 : (M ^ 6).det = 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Lorentz Form Preservation
-- ═══════════════════════════════════════════════════════════════

theorem M_lorentz : M.transpose * eta * M = eta := by native_decide

theorem M2_lorentz : (M ^ 2).transpose * eta * (M ^ 2) = eta := by native_decide

theorem M3_lorentz : (M ^ 3).transpose * eta * (M ^ 3) = eta := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Berggren Matrices
-- ═══════════════════════════════════════════════════════════════

/-- M = B₂⁻¹: B₂ · M = I. -/
theorem B2_M_eq_I : B2 * M = 1 := by native_decide

theorem M_B2_eq_I : M * B2 = 1 := by native_decide

theorem pq_zero_m_eq_n (n : ℤ) : p (n^2 - n^2) (2*n*n) (n^2 + n^2) = 0 := by
  simp only [p]; ring

theorem pq_zero_m_eq_2n (n : ℤ) : q ((2*n)^2 - n^2) (2*(2*n)*n) ((2*n)^2 + n^2) = 0 := by
  simp only [q]; ring

theorem pq_zero_m_eq_3n (n : ℤ) : p ((3*n)^2 - n^2) (2*(3*n)*n) ((3*n)^2 + n^2) = 0 := by
  simp only [p]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Ghost Map Relations
-- ═══════════════════════════════════════════════════════════════

theorem h_alt (a b c : ℤ) : h a b c = 3*c - 2*(a + b) := by
  simp only [h]; ring

theorem syndrome_identity (a b c : ℤ) :
    (p a b c)^2 + (q a b c)^2 - (h a b c)^2 = a^2 + b^2 - c^2 := by
  simp only [p, q, h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 16: Infinite Order of M
-- ═══════════════════════════════════════════════════════════════

theorem M_inf_order :
    M ≠ 1 ∧ M ^ 2 ≠ 1 ∧ M ^ 3 ≠ 1 ∧ M ^ 4 ≠ 1 ∧
    M ^ 5 ≠ 1 ∧ M ^ 6 ≠ 1 ∧ M ^ 7 ≠ 1 ∧ M ^ 8 ≠ 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 17: Euclid Parameter Ghost Map
-- ═══════════════════════════════════════════════════════════════

theorem euclid_21 : ghostMap (2^2 - 1^2) (2*2*1) (2^2 + 1^2) = (1, 0, 1) := by native_decide

theorem euclid_32 : ghostMap (3^2 - 2^2) (2*3*2) (3^2 + 2^2) = (3, -4, 5) := by native_decide

theorem euclid_41 : ghostMap (4^2 - 1^2) (2*4*1) (4^2 + 1^2) = (-3, 4, 5) := by native_decide

theorem euclid_43 : ghostMap (4^2 - 3^2) (2*4*3) (4^2 + 3^2) = (5, -12, 13) := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 18: Euclid Parameterization
-- ═══════════════════════════════════════════════════════════════

/-- Euclid parameterisation of `p`. -/
theorem p_euclid (m n : ℤ) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) = -((m - n) * (m - 3*n)) := by
  simp only [p]; ring

/-- Euclid parameterisation of `q`. -/
theorem q_euclid (m n : ℤ) :
    q (m^2-n^2) (2*m*n) (m^2+n^2) = 2*n*(m - 2*n) := by
  simp only [q]; ring

theorem pq_euclid (m n : ℤ) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) * q (m^2-n^2) (2*m*n) (m^2+n^2) =
    -2*n*(m - n)*(m - 2*n)*(m - 3*n) := by rw [p_euclid, q_euclid]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 19: M Symmetric
-- ═══════════════════════════════════════════════════════════════

theorem M_det_sq : M.det ^ 2 = 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 20: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms sum_correction
#print axioms M5_eq
#print axioms trace_M8
#print axioms B2_M_eq_I
#print axioms det_M6
#print axioms M_lorentz
#print axioms syndrome_identity
-- (`#print axioms pq_diff` removed: no theorem `pq_diff` is declared in this file.)
#print axioms error_detection_a
#print axioms M00_are_squares
#print axioms nsw_values
#print axioms M_inf_order