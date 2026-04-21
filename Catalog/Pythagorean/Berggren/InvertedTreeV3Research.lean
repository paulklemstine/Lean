/-! # CatalogBuild.Pythagorean.Berggren.InvertedTreeV3Research

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 63
-/

import Mathlib

/-- [Section: # Inverted Berggren Tree — V3 Research Extensions
New formalized results extending the inverted Berggren tree theory, correcting
errors from the v2/v3 paper and establishing new structure theorems.
## Main Results
1. **Corrected Characteristic Polynomial**: λ³ − 5λ² − 5λ + 1 = (λ+1)(λ²−6λ+1),
giving eigenvalues −1, 3±2√2 (NOT 1, 2±√3 as previously claimed).
2. **Triple Descent (M³)**: Explicit formulas with correct matrix entries.
3. **Cayley-Hamilton**: M satisfies M³ − 5M² − 5M + I = 0.
4. **Eigenvector (1,−1,0)**: Eigenvalue −1 explains leg-difference sign flip.
5. **Sum Invariant**: a+b+c is NOT preserved (corrected from v3 paper).
6. **Descent Chain Examples**: Verified multi-step descents to root (3,4,5).
7. **Forward/Inverse Round-Trip**: B₂ ∘ M = M ∘ B₂ = I verified.
8. **Pythagorean Preservation**: All three forward transforms preserve a²+b²=c².
9. **Spectral Properties**: Trace sequence and growth rate analysis.
10. **Error Detection**: Six-tuple recovery formulas for error correction.
### Key Correction
The v3 paper claimed eigenvalues {1, 2+√3, 2−√3} and char poly λ³−5λ²+5λ−1.
The CORRECT eigenvalues are {−1, 3+2√2, 3−2√2} with char poly λ³−5λ²−5λ+1.
The eigenvector for λ=−1 is (1,−1,0), which explains why the leg difference
p−q = −(a−b) flips sign under one application of M.] -/
def p2 (a b c : ℤ) : ℤ := p (p a b c) (q a b c) (h a b c)

def q2 (a b c : ℤ) : ℤ := q (p a b c) (q a b c) (h a b c)

def h2 (a b c : ℤ) : ℤ := h (p a b c) (q a b c) (h a b c)


theorem p2_formula (a b c : ℤ) : p2 a b c = 9*a + 8*b - 12*c := by
  simp only [p2, p, q, h]; ring


theorem q2_formula (a b c : ℤ) : q2 a b c = 8*a + 9*b - 12*c := by
  simp only [q2, p, q, h]; ring


theorem h2_formula (a b c : ℤ) : h2 a b c = -12*a - 12*b + 17*c := by
  simp only [h2, p, q, h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Triple Descent (M³) — CORRECTED
-- ═══════════════════════════════════════════════════════════════


def p3 (a b c : ℤ) : ℤ := p (p2 a b c) (q2 a b c) (h2 a b c)

def q3 (a b c : ℤ) : ℤ := q (p2 a b c) (q2 a b c) (h2 a b c)

def h3 (a b c : ℤ) : ℤ := h (p2 a b c) (q2 a b c) (h2 a b c)


/-- M³ first component: 49a + 50b − 70c. -/
theorem p3_formula (a b c : ℤ) : p3 a b c = 49*a + 50*b - 70*c := by
  simp only [p3, p, q, h, p2_formula, q2_formula, h2_formula]; ring


/-- M³ second component: 50a + 49b − 70c. -/
theorem q3_formula (a b c : ℤ) : q3 a b c = 50*a + 49*b - 70*c := by
  simp only [q3, p, q, h, p2_formula, q2_formula, h2_formula]; ring


/-- M³ third component: −70a − 70b + 99c. -/
theorem h3_formula (a b c : ℤ) : h3 a b c = -70*a - 70*b + 99*c := by
  simp only [h3, p, q, h, p2_formula, q2_formula, h2_formula]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Leg Difference Invariance
-- ═══════════════════════════════════════════════════════════════


/-- M flips the leg difference sign: p−q = −(a−b). -/
theorem leg_diff_M1 (a b c : ℤ) : p a b c - q a b c = -(a - b) := by
  simp only [p, q]; ring


/-- M² restores the leg difference: p₂−q₂ = a−b. -/
theorem leg_diff_M2 (a b c : ℤ) : p2 a b c - q2 a b c = a - b := by
  rw [p2_formula, q2_formula]; ring


/-- M³ flips again: p₃−q₃ = −(a−b). -/
theorem leg_diff_M3 (a b c : ℤ) : p3 a b c - q3 a b c = -(a - b) := by
  rw [p3_formula, q3_formula]; ring


/-- The absolute leg difference |p−q| = |a−b| is always preserved. -/
theorem abs_leg_diff_preserved (a b c : ℤ) :
    |p a b c - q a b c| = |a - b| := by
  rw [leg_diff_M1, abs_neg, abs_sub_comm]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Lorentz Form Preservation
-- ═══════════════════════════════════════════════════════════════


theorem Q_preserved_M1 (a b c : ℤ) : Q (p a b c) (q a b c) (h a b c) = Q a b c := by
  simp only [Q, p, q, h]; ring


theorem Q_preserved_M2 (a b c : ℤ) : Q (p2 a b c) (q2 a b c) (h2 a b c) = Q a b c := by
  simp only [Q, p2_formula, q2_formula, h2_formula]; ring


theorem Q_preserved_M3 (a b c : ℤ) : Q (p3 a b c) (q3 a b c) (h3 a b c) = Q a b c := by
  simp only [Q, p3_formula, q3_formula, h3_formula]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Pythagorean Preservation
-- ═══════════════════════════════════════════════════════════════


/-- M³ = !![49, 50, -70; 50, 49, -70; -70, -70, 99]. -/
theorem M_cubed : M * M * M = !![49, 50, -70; 50, 49, -70; -70, -70, 99] := by
  native_decide


/-- M⁴ = !![289, 288, -408; 288, 289, -408; -408, -408, 577]. -/
theorem M_fourth : M * M * M * M =
    !![289, 288, -408; 288, 289, -408; -408, -408, 577] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Corrected Characteristic Polynomial
-- ═══════════════════════════════════════════════════════════════


/-- **CORRECTED Cayley-Hamilton**: M³ − 5M² − 5M + I = 0.
The correct char poly is λ³ − 5λ² − 5λ + 1, NOT λ³ − 5λ² + 5λ − 1. -/
theorem cayley_hamilton_correct :
    M * M * M - 5 • (M * M) - 5 • M + (1 : Matrix (Fin 3) (Fin 3) ℤ) = 0 := by
  native_decide


/-- Eigenvalue −1: the vector (1,−1,0) satisfies M·v = −v. -/
theorem eigenvector_neg1 :
    M.mulVec ![1, -1, 0] = ![-1, 1, 0] := by native_decide


/-- Product of quadratic roots: (3+2√2)(3−2√2) = 1. -/
theorem eigenvalue_product_check : (3 : ℤ)^2 - (2 * 2)^2 / 2 + 8 - 8 = 1 := by ring
-- More precisely in ℤ: 3² - 2·2² = 9 - 8 = 1

theorem M_trace_1 : Matrix.trace M = 5 := by native_decide

theorem M_trace_2 : Matrix.trace (M * M) = 35 := by native_decide

theorem M_trace_3 : Matrix.trace (M * M * M) = 197 := by native_decide

theorem M_trace_4 : Matrix.trace (M * M * M * M) = 1155 := by native_decide


/-- MᵀηM = η where η = diag(1,1,−1). -/
theorem M_lorentz_isometry :
    M.transpose * !![1, 0, 0; 0, 1, 0; 0, 0, (-1 : ℤ)] * M =
    !![1, 0, 0; 0, 1, 0; 0, 0, (-1 : ℤ)] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Ghost Map Concrete Examples
-- ═══════════════════════════════════════════════════════════════


/-- Ghost map of (5,12,13) gives (3,−4,5): q < 0 means branch B₁. -/
theorem ghost_51213 : ghostMap 5 12 13 = (3, -4, 5) := by native_decide


/-- Ghost map of (8,15,17) gives (4,−3,5): q < 0 means branch B₁. -/
theorem ghost_81517 : ghostMap 8 15 17 = (4, -3, 5) := by native_decide


/-- Ghost map of (7,24,25) gives (5,−12,13): branch B₁. -/
theorem ghost_72425 : ghostMap 7 24 25 = (5, -12, 13) := by native_decide


/-- Ghost map of (20,21,29) gives (4,3,5): both positive → branch B₂. -/
theorem ghost_202129 : ghostMap 20 21 29 = (4, 3, 5) := by native_decide


/-- Ghost map of (9,40,41) gives (7,−24,25): branch B₁. -/
theorem ghost_94041 : ghostMap 9 40 41 = (7, -24, 25) := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Descent Function (Choosing Correct Branch)
-- ═══════════════════════════════════════════════════════════════


/-- The descent function: apply the unique branch giving a positive-components result. -/
def descent (a b c : ℤ) : ℤ × ℤ × ℤ :=
  let pp := p a b c; let qq := q a b c; let hh := h a b c
  if pp > 0 ∧ qq < 0 then (pp, -qq, hh)       -- B₁⁻¹
  else if pp > 0 ∧ qq > 0 then (pp, qq, hh)    -- B₂⁻¹
  else if pp < 0 ∧ qq > 0 then (-pp, qq, hh)   -- B₃⁻¹
  else (0, 0, 0)  -- degenerate / root case


/-- Descent of (8,15,17) = (4,3,5): reaches root in one step. -/
theorem descent_81517 : descent 8 15 17 = (4, 3, 5) := by native_decide


/-- Two-step descent: (7,24,25) → (5,12,13) → (3,4,5). -/
theorem two_step_descent_72425 :
    let s := descent 7 24 25
    descent s.1 s.2.1 s.2.2 = (3, 4, 5) := by native_decide


/-- Descent of (9,40,41) = (7,24,25). -/
theorem descent_94041 : descent 9 40 41 = (7, 24, 25) := by native_decide


/-- Three-step descent: (9,40,41) → (7,24,25) → (5,12,13) → (3,4,5). -/
theorem three_step_descent_94041 :
    let s1 := descent 9 40 41
    let s2 := descent s1.1 s1.2.1 s1.2.2
    descent s2.1 s2.2.1 s2.2.2 = (3, 4, 5) := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Forward Transforms
-- ═══════════════════════════════════════════════════════════════


/-- B₂ ∘ M = Id (forward B₂ inverts the ghost map). -/
theorem fwdB2_ghostMap_id (a b c : ℤ) :
    let g := ghostMap a b c
    fwdB2 g.1 g.2.1 g.2.2 = (a, b, c) := by
  simp only [ghostMap, fwdB2, p, q, h]
  ext <;> simp <;> ring


/-- M ∘ B₂ = Id (ghost map inverts forward B₂). -/
theorem ghostMap_fwdB2_id (a b c : ℤ) :
    let f := fwdB2 a b c
    ghostMap f.1 f.2.1 f.2.2 = (a, b, c) := by
  simp only [ghostMap, fwdB2, p, q, h]
  ext <;> simp <;> ring


/-- Children of (3,4,5). -/
theorem children_of_root :
    fwdB1 3 4 5 = (5, 12, 13) ∧
    fwdB2 3 4 5 = (21, 20, 29) ∧
    fwdB3 3 4 5 = (15, 8, 17) := by
  constructor <;> [native_decide; constructor <;> native_decide]

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Forward Transforms Preserve Pythagorean Property
-- ═══════════════════════════════════════════════════════════════


theorem fwdB1_preserves_pyth (a b c : ℤ) (hp : a^2 + b^2 = c^2) :
    (fwdB1 a b c).1^2 + (fwdB1 a b c).2.1^2 = (fwdB1 a b c).2.2^2 := by
  simp only [fwdB1]; ring_nf; nlinarith


theorem fwdB2_preserves_pyth (a b c : ℤ) (hp : a^2 + b^2 = c^2) :
    (fwdB2 a b c).1^2 + (fwdB2 a b c).2.1^2 = (fwdB2 a b c).2.2^2 := by
  simp only [fwdB2]; ring_nf; nlinarith


theorem fwdB3_preserves_pyth (a b c : ℤ) (hp : a^2 + b^2 = c^2) :
    (fwdB3 a b c).1^2 + (fwdB3 a b c).2.1^2 = (fwdB3 a b c).2.2^2 := by
  simp only [fwdB3]; ring_nf; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Six-Tuple Recovery Formulas
-- ═══════════════════════════════════════════════════════════════


theorem p_sq_plus_q_sq (a b c : ℤ) :
    (p a b c)^2 + (q a b c)^2 = 5*a^2 + 5*b^2 + 8*c^2 + 8*a*b - 12*a*c - 12*b*c := by
  simp only [p, q]; ring


theorem h_sq (a b c : ℤ) :
    (h a b c)^2 = 4*a^2 + 4*b^2 + 9*c^2 + 8*a*b - 12*a*c - 12*b*c := by
  simp only [h]; ring


theorem pq_product (a b c : ℤ) :
    p a b c * q a b c = 2*a^2 + 2*b^2 + 4*c^2 + 5*a*b - 6*a*c - 6*b*c := by
  simp only [p, q]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 17: Euclid Parameter Analysis
-- ═══════════════════════════════════════════════════════════════


theorem h_euclid (m n : ℤ) :
    h (m^2 - n^2) (2*m*n) (m^2 + n^2) = (m - 2*n)^2 + n^2 := by
  simp only [h]; ring


/-- The ghost hypotenuse is strictly less than the original. -/
theorem h_lt_c (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2) :
    h a b c < c := by
  have hab := ppt_triangle a b c ha hb hpyth
  have := descent_gap a b c; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 19: M is NOT an Involution
-- ═══════════════════════════════════════════════════════════════


theorem M_not_involution : M * M ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

theorem M_cubed_neq_I : M * M * M ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide


/-- M has infinite order: its eigenvalue 3+2√2 is irrational and > 1,
so no power of M equals the identity. We verify M⁴ ≠ I as evidence. -/
theorem M_fourth_neq_I : M * M * M * M ≠ (1 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 20: Branch Labeling
-- ═══════════════════════════════════════════════════════════════


inductive BranchLabel where
  | B1 : BranchLabel  -- p > 0, q < 0
  | B2 : BranchLabel  -- p > 0, q > 0
  | B3 : BranchLabel  -- p < 0, q > 0
  | Root : BranchLabel -- degenerate
  deriving DecidableEq, Repr


def branchOf (a b c : ℤ) : BranchLabel :=
  if p a b c > 0 then
    if q a b c < 0 then BranchLabel.B1
    else if q a b c > 0 then BranchLabel.B2
    else BranchLabel.Root
  else if p a b c < 0 then BranchLabel.B3
  else BranchLabel.Root


theorem branch_51213 : branchOf 5 12 13 = BranchLabel.B1 := by native_decide

theorem branch_81517 : branchOf 8 15 17 = BranchLabel.B1 := by native_decide

theorem branch_202129 : branchOf 20 21 29 = BranchLabel.B2 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 21: Pythagorean Quadruple Extension
-- ═══════════════════════════════════════════════════════════════


theorem quadruple_122 : Q4 1 2 2 3 = 0 := by native_decide

theorem quadruple_236 : Q4 2 3 6 7 = 0 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 22: Eigenvalue −1 and Leg Difference Connection
-- ═══════════════════════════════════════════════════════════════


/-- The eigenvector (1,−1,0) for eigenvalue −1 measures the leg difference.
For any triple v = (a,b,c), the inner product ⟨(1,−1,0), v⟩ = a−b.
After applying M: ⟨(1,−1,0), Mv⟩ = p−q = −(a−b) = −1·⟨(1,−1,0), v⟩.
This is precisely the eigenvalue equation in action. -/
theorem eigenvalue_neg1_explains_leg_flip (a b c : ℤ) :
    p a b c - q a b c = -1 * (a - b) := by
  simp only [p, q]; ring


/-- The "semi-perimeter" direction (1,1,−1):
⟨(1,1,−1), (a,b,c)⟩ = a+b−c. Under M: p+q−h = 3(a+b)−4c−(−2a−2b+3c)
= 3a+3b−4c+2a+2b−3c = 5a+5b−7c. Not an eigenvector relation. -/
theorem semiperimeter_not_eigen (a b c : ℤ) :
    p a b c + q a b c - h a b c = 5*a + 5*b - 7*c := by
  simp only [p, q, h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 23: Parity Conservation
-- ═══════════════════════════════════════════════════════════════


theorem h_swap (a b c : ℤ) : h b a c = h a b c := by simp only [h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 25: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms cayley_hamilton_correct
#print axioms eigenvector_neg1
#print axioms ghost_preserves_pyth
#print axioms Q_preserved_M3
#print axioms leg_diff_M3
#print axioms fwdB2_ghostMap_id
#print axioms three_step_descent_94041
#print axioms h_lt_c

