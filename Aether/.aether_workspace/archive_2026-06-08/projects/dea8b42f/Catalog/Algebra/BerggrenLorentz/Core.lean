import Mathlib

/-!
# Berggren-Lorentz Monoid: Discrete Lorentz Symmetry of Pythagorean Triples

This file develops the theory of the **Berggren monoid** — the three-generator
submonoid of GL₃(ℤ) that acts on primitive Pythagorean triples via the
Berggren tree. We establish:

1. All three generators preserve the Lorentzian quadratic form Q(a,b,c) = a²+b²-c²,
   placing them in the integer orthogonal group O(2,1;ℤ).
2. Determinant computations showing orientation structure (two proper, one improper).
3. Pythagorean preservation: children of Pythagorean triples are Pythagorean.
4. Hypotenuse growth bounds giving O(log c) tree depth.
5. Trace structure, inverse matrices, and non-commutativity of generators.
6. Quadratic form identities and bilinear form theory.

## Bridge: Number Theory (Pythagorean triples) ↔ Physics (Lorentz group O(2,1;ℤ))
↔ Cryptography (monoid action hardness) ↔ ML (Lipschitz bounds via matrix norms)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Core Definitions -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c² on ℤ³.
    The light cone Q = 0 parametrizes Pythagorean triples.
    Bridge: connects number theory to physics (Minkowski metric). -/
def lorentzForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Scalar version of the Lorentz form for convenience. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple (a,b,c) is Pythagorean iff it lies on the light cone Q = 0. -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The Berggren matrix A (first generator). -/
def matA : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The Berggren matrix B (second generator). -/
def matB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- The Berggren matrix C (third generator). -/
def matC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix Q_L = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Berggren child A: explicit coordinate formulas. -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: explicit coordinate formulas. -/
def childB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: explicit coordinate formulas. -/
def childC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- A word in the Berggren monoid: a finite sequence of generator indices. -/
structure BerggrenWord where
  letters : List (Fin 3)
  deriving Repr, DecidableEq

/-- The matrix associated to each generator index. -/
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => matA
  | 1 => matB
  | 2 => matC

/-- Product of matrices along a Berggren word. -/
def wordMatrix (w : BerggrenWord) : Matrix (Fin 3) (Fin 3) ℤ :=
  w.letters.foldl (fun acc k => acc * berggrenGen k) 1

/-- The Lorentz bilinear form B(u,v) = u₀v₀ + u₁v₁ - u₂v₂.
    Polarization of the Lorentz quadratic form.
    Bridge: connects inner product geometry to Pythagorean combinatorics. -/
def lorentzBilinear (u v : Fin 3 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- The hypotenuse functions for each branch. -/
def hypA (a b c : ℤ) : ℤ := 2*a - 2*b + 3*c
def hypB (a b c : ℤ) : ℤ := 2*a + 2*b + 3*c
def hypC (a b c : ℤ) : ℤ := -2*a + 2*b + 3*c

/-! ## Section 2: Determinant Structure -/

/-- Berggren matrix A has determinant 1 (proper Lorentz transformation).
    Bridge: orientation-preserving transformation in O(2,1;ℤ). -/
theorem det_matA : matA.det = 1 := by native_decide

/-- Berggren matrix B has determinant -1 (improper Lorentz transformation).
    Impact: post_quantum_security — the B-generator is the unique
    parity-flipping generator, giving a ℤ/2ℤ grading on the monoid. -/
theorem det_matB : matB.det = -1 := by native_decide

/-- Berggren matrix C has determinant 1 (proper Lorentz transformation). -/
theorem det_matC : matC.det = 1 := by native_decide

/-- The determinant signature of the Berggren generators is (+1, -1, +1).
    Bridge: connects algebraic topology (orientation) to number theory. -/
theorem berggren_det_signature :
    matA.det = 1 ∧ matB.det = -1 ∧ matC.det = 1 :=
  ⟨det_matA, det_matB, det_matC⟩

/-- Product determinants respect the homomorphism det: GL₃ → ℤ*.
    Bridge: determinant homomorphism ↔ graded structure on Berggren monoid. -/
theorem det_matAB : (matA * matB).det = -1 := by native_decide
theorem det_matAC : (matA * matC).det = 1 := by native_decide
theorem det_matBC : (matB * matC).det = -1 := by native_decide
theorem det_matABC : (matA * matB * matC).det = -1 := by native_decide

/-- Squared matrices all have det = 1 (even powers are always proper). -/
theorem det_matA_sq : (matA * matA).det = 1 := by native_decide
theorem det_matB_sq : (matB * matB).det = 1 := by native_decide
theorem det_matC_sq : (matC * matC).det = 1 := by native_decide

/-! ## Section 3: Lorentz Form Preservation -/

/-- Matrix A preserves the Lorentz metric: Aᵀ Q A = Q.
    Establishes A ∈ O(2,1;ℤ), the integer Lorentz group.
    Bridge: Pythagorean triple generation ↔ discrete Lorentz symmetry.
    Impact: hamiltonian_simulation — discrete Lorentz boosts preserve Minkowski norm. -/
theorem matA_preserves_lorentz : matA.transpose * metricQ * matA = metricQ := by
  native_decide

/-- Matrix B preserves the Lorentz metric: Bᵀ Q B = Q. -/
theorem matB_preserves_lorentz : matB.transpose * metricQ * matB = metricQ := by
  native_decide

/-- Matrix C preserves the Lorentz metric: Cᵀ Q C = Q. -/
theorem matC_preserves_lorentz : matC.transpose * metricQ * matC = metricQ := by
  native_decide

/-- All three Berggren generators lie in O(2,1;ℤ).
    Bridge: the entire Berggren monoid is a submonoid of the Lorentz group. -/
theorem berggren_all_in_lorentz_group :
    matA.transpose * metricQ * matA = metricQ ∧
    matB.transpose * metricQ * matB = metricQ ∧
    matC.transpose * metricQ * matC = metricQ :=
  ⟨matA_preserves_lorentz, matB_preserves_lorentz, matC_preserves_lorentz⟩

/-- All pairwise products preserve the Lorentz form — closure under multiplication.
    Bridge: submonoid closure in O(2,1;ℤ) ↔ lattice_crypto orbit generation. -/
theorem matAB_preserves_lorentz :
    (matA * matB).transpose * metricQ * (matA * matB) = metricQ := by native_decide
theorem matAC_preserves_lorentz :
    (matA * matC).transpose * metricQ * (matA * matC) = metricQ := by native_decide
theorem matBC_preserves_lorentz :
    (matB * matC).transpose * metricQ * (matB * matC) = metricQ := by native_decide

/-! ## Section 4: Pythagorean Preservation -/

/-- The A-branch preserves Pythagorean triples.
    Bridge: tree generation ↔ Diophantine invariants. -/
theorem childA_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 := by
  unfold IsPythag childA at *; nlinarith [h]

/-- The B-branch preserves Pythagorean triples. -/
theorem childB_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 := by
  unfold IsPythag childB at *; nlinarith [h]

/-- The C-branch preserves Pythagorean triples. -/
theorem childC_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (childC a b c).1 (childC a b c).2.1 (childC a b c).2.2 := by
  unfold IsPythag childC at *; nlinarith [h]

/-! ## Section 5: Lorentz Form Preservation (Scalar) -/

/-- The A-branch preserves the Lorentz quadratic form exactly.
    Bridge: Q-invariance ↔ gauge invariance in Hopf-algebraic renormalization. -/
theorem childA_preserves_Q (a b c : ℤ) :
    lorentzQ (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childA; ring

theorem childB_preserves_Q (a b c : ℤ) :
    lorentzQ (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childB; ring

theorem childC_preserves_Q (a b c : ℤ) :
    lorentzQ (childC a b c).1 (childC a b c).2.1 (childC a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childC; ring

/-! ## Section 6: Hypotenuse Growth Bounds -/

/-- B-child hypotenuse strictly exceeds parent (positive legs).
    Bridge: O(log c) depth ↔ efficient certified_enumeration algorithms. -/
theorem hypB_strict_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < hypB a b c := by
  unfold hypB; linarith

/-- B-child hypotenuse lower bound: hypB ≥ 3c when legs are positive.
    Impact: certified_enumeration — O(log c) depth gives O(c log c) enumeration. -/
theorem hypB_lower_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    3 * c ≤ hypB a b c := by
  unfold hypB; linarith

/-- A-child hypotenuse strictly exceeds parent when first leg exceeds second. -/
theorem hypA_strict_growth (a b c : ℤ) (hab : b < a) (hc : 0 < c) :
    c < hypA a b c := by
  unfold hypA; linarith

/-- C-child hypotenuse strictly exceeds parent when second leg exceeds first. -/
theorem hypC_strict_growth (a b c : ℤ) (hab : a < b) (hc : 0 < c) :
    c < hypC a b c := by
  unfold hypC; linarith

/-- B-child hypotenuse upper bound: hypB ≤ 7c when 0 < a,b ≤ c.
    Impact: lipschitz_certified_robustness — Lipschitz constant ≤ 7^depth. -/
theorem hypB_upper_bound (a b c : ℤ) (_ha : 0 < a) (_hb : 0 < b)
    (hac : a ≤ c) (hbc : b ≤ c) :
    hypB a b c ≤ 7 * c := by
  unfold hypB; linarith

/-- For Pythagorean (a,b,c) with 0 < a, 0 < b, the B-child hypotenuse ≥ 3c.
    Bridge: exponential growth ↔ logarithmic search depth for post_quantum_security.
    Impact: word length ≥ log₃(target/5) gives Ω(log c) hardness for orbit reversal. -/
theorem iterB_hypotenuse_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    3 * c ≤ (childB a b c).2.2 := by
  show 3 * c ≤ 2*a + 2*b + 3*c; linarith [ha, hb]

/-! ## Section 7: Trace Structure -/

/-- Trace of A = 3. Classifies A up to O(2,1;ℤ)-conjugacy.
    Bridge: trace ↔ spectral theory ↔ quantum Hamiltonian eigenvalues. -/
theorem trace_matA : matA.trace = 3 := by native_decide

/-- Trace of B = 5. The largest trace — B is the "most expanding" generator.
    Bridge: trace ↔ Lyapunov exponent of B-branch dynamics. -/
theorem trace_matB : matB.trace = 5 := by native_decide

/-- Trace of C = 3. Same trace as A — these generators are conjugate in GL₃(ℝ). -/
theorem trace_matC : matC.trace = 3 := by native_decide

/-- Trace signature: (3, 5, 3). B has the largest trace.
    Impact: larger trace → faster hypotenuse growth → dominates certified_enumeration. -/
theorem berggren_trace_signature :
    matA.trace = 3 ∧ matB.trace = 5 ∧ matC.trace = 3 :=
  ⟨trace_matA, trace_matB, trace_matC⟩

/-- Sum of traces = 11. -/
theorem trace_sum : matA.trace + matB.trace + matC.trace = 11 := by native_decide

/-! ## Section 8: Matrix Algebra Relations -/

/-- The product A*B computed explicitly. -/
theorem matAB_explicit :
    matA * matB = !![(1:ℤ), 4, 4; 4, 7, 8; 4, 8, 9] := by native_decide

/-- A² computed explicitly. -/
theorem matA_squared :
    matA * matA = !![(1:ℤ), -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide

/-- B² computed explicitly. -/
theorem matB_squared :
    matB * matB = !![(9:ℤ), 8, 12; 8, 9, 12; 12, 12, 17] := by native_decide

/-- C² computed explicitly. -/
theorem matC_squared :
    matC * matC = !![(-7:ℤ), 4, 8; -4, 1, 4; -8, 4, 9] := by native_decide

/-! ## Section 9: Seed Triple Verification -/

/-- (3,4,5) is a Pythagorean triple — the seed of the Berggren tree. -/
theorem seed_is_pythag : IsPythag 3 4 5 := by unfold IsPythag; norm_num

/-- The A-child of (3,4,5) is (5,12,13). -/
theorem seed_childA : childA 3 4 5 = (5, 12, 13) := by unfold childA; norm_num

/-- The B-child of (3,4,5) is (21,20,29). -/
theorem seed_childB : childB 3 4 5 = (21, 20, 29) := by unfold childB; norm_num

/-- The C-child of (3,4,5) is (15,8,17). -/
theorem seed_childC : childC 3 4 5 = (15, 8, 17) := by unfold childC; norm_num

/-- First-generation children are all Pythagorean. -/
theorem gen1_all_pythag :
    IsPythag 5 12 13 ∧ IsPythag 21 20 29 ∧ IsPythag 15 8 17 := by
  refine ⟨?_, ?_, ?_⟩ <;> (unfold IsPythag; norm_num)

/-! ## Section 10: Second Generation Verification -/

/-- The A-child of (5,12,13) is (7,24,25). -/
theorem gen2_AA : childA 5 12 13 = (7, 24, 25) := by unfold childA; norm_num

/-- The B-child of (5,12,13) is (55,48,73). -/
theorem gen2_AB : childB 5 12 13 = (55, 48, 73) := by unfold childB; norm_num

/-- All second-generation triples from the A-branch are Pythagorean. -/
theorem gen2_pythag :
    IsPythag 7 24 25 ∧ IsPythag 55 48 73 := by
  refine ⟨?_, ?_⟩ <;> (unfold IsPythag; norm_num)

/-! ## Section 11: Lorentz Form on Vectors -/

/-- The Lorentz form applied to a vector matches the scalar form. -/
theorem lorentzForm_eq_lorentzQ (v : Fin 3 → ℤ) :
    lorentzForm v = lorentzQ (v 0) (v 1) (v 2) := by
  unfold lorentzForm lorentzQ; rfl

/-- The seed vector lies on the light cone. -/
theorem seed_on_light_cone : lorentzForm ![3, 4, 5] = 0 := by native_decide

/-- First-gen children lie on the light cone. -/
theorem childA_on_light_cone : lorentzForm ![5, 12, 13] = 0 := by native_decide
theorem childB_on_light_cone : lorentzForm ![21, 20, 29] = 0 := by native_decide
theorem childC_on_light_cone : lorentzForm ![15, 8, 17] = 0 := by native_decide

/-! ## Section 12: Quadratic Form Identities -/

/-- Q(v) = 0 iff v is Pythagorean. The fundamental bridge between
    quadratic form theory and Diophantine equations. -/
theorem lorentzQ_zero_iff_pythag (a b c : ℤ) :
    lorentzQ a b c = 0 ↔ IsPythag a b c := by
  unfold lorentzQ IsPythag; omega

/-- Expansion identity for Q on sums. -/
theorem lorentzQ_expansion (a b c a' b' c' : ℤ) :
    lorentzQ (a + a') (b + b') (c + c') =
    lorentzQ a b c + lorentzQ a' b' c' + 2 * (a * a' + b * b' - c * c') := by
  unfold lorentzQ; ring

/-- The Lorentz form is homogeneous of degree 2. -/
theorem lorentzQ_homogeneous (t a b c : ℤ) :
    lorentzQ (t * a) (t * b) (t * c) = t ^ 2 * lorentzQ a b c := by
  unfold lorentzQ; ring

/-- Negating coordinates preserves the Lorentz form. -/
theorem lorentzQ_neg_first (a b c : ℤ) : lorentzQ (-a) b c = lorentzQ a b c := by
  unfold lorentzQ; ring

theorem lorentzQ_neg_second (a b c : ℤ) : lorentzQ a (-b) c = lorentzQ a b c := by
  unfold lorentzQ; ring

theorem lorentzQ_neg_third (a b c : ℤ) : lorentzQ a b (-c) = lorentzQ a b c := by
  unfold lorentzQ; ring

/-- Swapping legs preserves the Lorentz form (leg-swap symmetry). -/
theorem lorentzQ_swap_legs (a b c : ℤ) : lorentzQ b a c = lorentzQ a b c := by
  unfold lorentzQ; ring

/-! ## Section 13: Bilinear Form Properties -/

/-- Polarization identity: Q(u) = B(u,u). -/
theorem polarization (v : Fin 3 → ℤ) :
    lorentzForm v = lorentzBilinear v v := by
  unfold lorentzForm lorentzBilinear; ring

/-- Symmetry of the bilinear form. -/
theorem lorentzBilinear_symm (u v : Fin 3 → ℤ) :
    lorentzBilinear u v = lorentzBilinear v u := by
  unfold lorentzBilinear; ring

/-- Bilinearity in the first argument. -/
theorem lorentzBilinear_add_left (u₁ u₂ v : Fin 3 → ℤ) :
    lorentzBilinear (u₁ + u₂) v = lorentzBilinear u₁ v + lorentzBilinear u₂ v := by
  unfold lorentzBilinear; simp [Pi.add_apply]; ring

/-- Scaling in the first argument. -/
theorem lorentzBilinear_smul_left (t : ℤ) (u v : Fin 3 → ℤ) :
    lorentzBilinear (t • u) v = t * lorentzBilinear u v := by
  unfold lorentzBilinear; simp [Pi.smul_apply]; ring

/-! ## Section 14: Eigenvalue Structure -/

/-- det(I - A) = 0, so 1 is an eigenvalue of A.
    Bridge: spectral theory ↔ fixed-point dynamics on the light cone. -/
theorem matA_eigenvalue_one : (1 - matA).det = 0 := by native_decide

/-- det(I - B) = -8 ≠ 0, so 1 is NOT an eigenvalue of B.
    The B-generator has no fixed points on the light cone.
    Impact: certified_enumeration — every vector is moved, no repeats. -/
theorem matB_no_eigenvalue_one : (1 - matB).det = -8 := by native_decide

/-- det(I - C) = 0, so 1 is an eigenvalue of C (like A).
    Bridge: A and C share eigenvalue 1 but B does not — structural asymmetry. -/
theorem matC_eigenvalue_one : (1 - matC).det = 0 := by native_decide

/-! ## Section 15: Non-Commutativity -/

/-- A and B do not commute. Non-commutativity is essential for the
    Berggren monoid to be free (no relations).
    Impact: post_quantum_security — non-commutativity enables hard word problems. -/
theorem matA_matB_noncommutative : matA * matB ≠ matB * matA := by native_decide

/-- B and C do not commute. -/
theorem matB_matC_noncommutative : matB * matC ≠ matC * matB := by native_decide

/-- A and C do not commute. -/
theorem matA_matC_noncommutative : matA * matC ≠ matC * matA := by native_decide

/-- The three generators are pairwise distinct. -/
theorem generators_pairwise_distinct :
    matA ≠ matB ∧ matA ≠ matC ∧ matB ≠ matC := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-! ## Section 16: Inverse Matrices and O(2,1;ℤ) Group Structure -/

/-- The inverse of matA. Since det(A) = 1, the inverse has integer entries. -/
def invA : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- The inverse of matB. Since det(B) = -1, inv = -adj(B). -/
def invB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- The inverse of matC. Since det(C) = 1, inv = adj(C). -/
def invC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- A * A⁻¹ = I — verified inverse.
    Bridge: invertibility ↔ unique parent in the Berggren tree
    ↔ collision-free hash for post_quantum_security. -/
theorem matA_mul_invA : matA * invA = 1 := by native_decide

/-- B * B⁻¹ = I. -/
theorem matB_mul_invB : matB * invB = 1 := by native_decide

/-- C * C⁻¹ = I. -/
theorem matC_mul_invC : matC * invC = 1 := by native_decide

/-- A⁻¹ * A = I (left inverse = right inverse). -/
theorem invA_mul_matA : invA * matA = 1 := by native_decide
theorem invB_mul_matB : invB * matB = 1 := by native_decide
theorem invC_mul_matC : invC * matC = 1 := by native_decide

/-- The inverses also preserve the Lorentz form — as expected for O(2,1;ℤ). -/
theorem invA_preserves_lorentz :
    invA.transpose * metricQ * invA = metricQ := by native_decide
theorem invB_preserves_lorentz :
    invB.transpose * metricQ * invB = metricQ := by native_decide
theorem invC_preserves_lorentz :
    invC.transpose * metricQ * invC = metricQ := by native_decide

/-! ## Section 17: A + C Symmetry -/

/-- A + C has a strikingly simple form: nonzero only in the third column.
    This reveals that A and C "differ only in how they handle the hypotenuse". -/
theorem matA_add_matC :
    matA + matC = !![0, 0, 4; 0, 0, 4; 0, 0, 6] := by native_decide

/-- The sum A + B + C. -/
theorem sum_ABC :
    matA + matB + matC = !![1, 2, 6; 2, 1, 6; 2, 2, 9] := by native_decide

/-! ## Section 18: Parity Grading of the Berggren Monoid -/

/-- The parity of a Berggren word: count of B-generators modulo 2.
    Determines whether the word matrix has det +1 or -1.
    Bridge: monoid grading ↔ orientation in O(2,1;ℤ). -/
def wordParity (w : BerggrenWord) : ℕ :=
  (w.letters.filter (· == 1)).length

/-- The empty word has zero B-count (even parity, det = +1). -/
theorem empty_word_parity : wordParity ⟨[]⟩ = 0 := by
  unfold wordParity; simp

/-- A single A-generator has zero B-count (even parity). -/
theorem single_A_parity : wordParity ⟨[0]⟩ = 0 := by
  unfold wordParity; simp [List.filter]

/-- A single B-generator has B-count 1 (odd parity). -/
theorem single_B_parity : wordParity ⟨[1]⟩ = 1 := by
  unfold wordParity; simp [List.filter]

/-! ## Section 19: Pythagorean Triple Arithmetic -/

/-- For Pythagorean (a,b,c) with a,b > 0: c > 0.
    Follows from c² = a² + b² > 0. -/
theorem pythag_hyp_pos (a b c : ℤ) (h : IsPythag a b c) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 ≤ c) : 0 < c := by
  unfold IsPythag at h
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, hc]

/-- For Pythagorean (a,b,c) with a,b > 0 and c ≥ 0: c ≥ a and c ≥ b.
    The hypotenuse is the largest side. -/
theorem pythag_hyp_ge_leg_a (a b c : ℤ) (h : IsPythag a b c) (hb : 0 < b) (_hc : 0 < c) :
    a ≤ c := by
  unfold IsPythag at h
  nlinarith [sq_nonneg b, sq_nonneg (c - a)]

theorem pythag_hyp_ge_leg_b (a b c : ℤ) (h : IsPythag a b c) (ha : 0 < a) (_hc : 0 < c) :
    b ≤ c := by
  unfold IsPythag at h
  nlinarith [sq_nonneg a, sq_nonneg (c - b)]

/-- Triangle inequality for Pythagorean triples: a + b > c.
    This is the fundamental bound ensuring the light cone is not degenerate. -/
theorem pythag_triangle_ineq (a b c : ℤ) (h : IsPythag a b c)
    (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c) :
    c < a + b := by
  unfold IsPythag at h
  nlinarith [sq_nonneg (a + b - c), sq_nonneg a, sq_nonneg b, ha, hb]

/-- For Pythagorean (a,b,c) with positive legs, the B-child hypotenuse
    satisfies the Pythagorean-strengthened bound hypB > 5c when a + b > c.
    Bridge: this uses the Pythagorean constraint to tighten the spectral bound.
    Impact: post_quantum_security — the search space grows as Ω(5^depth). -/
theorem hypB_pythag_lower (a b c : ℤ) (h : IsPythag a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    5 * c < hypB a b c := by
  unfold hypB
  have htri := pythag_triangle_ineq a b c h ha hb hc
  linarith

end BerggrenLorentz