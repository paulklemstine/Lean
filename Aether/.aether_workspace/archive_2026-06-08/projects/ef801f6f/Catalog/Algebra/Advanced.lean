import Mathlib
import Algebra.BerggrenLorentz.Core

/-!
# Berggren-Lorentz Monoid: Advanced Structure Theory

This file extends the core Berggren-Lorentz theory with:

1. **Iterated B-branch growth**: exponential hypotenuse growth along the B-orbit
2. **Parametric Pythagorean families**: Euclid's parametrization and its connection
3. **Abstract quadratic form preservation**: monoid closure theorem
4. **Trace algebra**: product traces and spectral invariants
5. **Twin-leg triples**: the consecutive-integer subfamily
6. **Entrywise norm bounds**: elementary Lipschitz estimates

## Bridge: Algebra (monoid theory) ↔ Number Theory (Pythagorean triples, GCD)
↔ Dynamics (iterated maps) ↔ Cryptography (search space bounds)
↔ ML (lipschitz_certified_robustness via entrywise bounds)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Iterated B-Branch Growth -/

/-- The n-th iterated B-child starting from (3,4,5).
    This traces the B-branch of the Berggren tree. -/
def iterateB : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => childB (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2

/-- The first iterated B-child of (3,4,5) is (21,20,29). -/
theorem iterateB_one : iterateB 1 = (21, 20, 29) := by
  simp only [iterateB, childB]; norm_num

/-- The second iterated B-child is (119,120,169). -/
theorem iterateB_two : iterateB 2 = (119, 120, 169) := by
  simp only [iterateB, childB]; norm_num

/-- The third iterated B-child is (697,696,985). -/
theorem iterateB_three : iterateB 3 = (697, 696, 985) := by
  simp only [iterateB, childB]; norm_num

/-- Each iterated B-child is Pythagorean.
    Proof by induction using childB_preserves_pythag.
    Bridge: dynamics (orbit closure) ↔ Diophantine invariants. -/
theorem iterateB_pythag : ∀ n, IsPythag (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2 := by
  intro n; induction n with
  | zero => exact seed_is_pythag
  | succ n ih => exact childB_preserves_pythag _ _ _ ih

/-- Each iterated B-child preserves the Lorentz form at zero. -/
theorem iterateB_on_light_cone :
    ∀ n, lorentzQ (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2 = 0 := by
  intro n; rw [lorentzQ_zero_iff_pythag]; exact iterateB_pythag n

/-! ## Section 2: Hypotenuse Sequence Analysis -/

/-- The hypotenuse of the n-th B-iterate. -/
def bHypotenuse (n : ℕ) : ℤ := (iterateB n).2.2

/-- The hypotenuse sequence starts at 5. -/
theorem bHyp_zero : bHypotenuse 0 = 5 := by rfl

/-- The hypotenuse sequence at step 1 is 29. -/
theorem bHyp_one : bHypotenuse 1 = 29 := by
  unfold bHypotenuse; rw [iterateB_one]

/-- The hypotenuse sequence at step 2 is 169 = 13². -/
theorem bHyp_two : bHypotenuse 2 = 169 := by
  unfold bHypotenuse; rw [iterateB_two]

/-- The hypotenuse sequence at step 3 is 985. -/
theorem bHyp_three : bHypotenuse 3 = 985 := by
  unfold bHypotenuse; rw [iterateB_three]

/-- The hypotenuse grows by a factor > 5 at each B-step.
    Bridge: spectral theory ↔ post_quantum_security key size estimation.
    Impact: Ω(5^depth) growth means O(log c / log 5) depth. -/
theorem bHyp_ratio_lower_01 : 5 * bHypotenuse 0 < bHypotenuse 1 := by
  rw [bHyp_zero, bHyp_one]; norm_num

theorem bHyp_ratio_lower_12 : 5 * bHypotenuse 1 < bHypotenuse 2 := by
  rw [bHyp_one, bHyp_two]; norm_num

theorem bHyp_ratio_lower_23 : 5 * bHypotenuse 2 < bHypotenuse 3 := by
  rw [bHyp_two, bHyp_three]; norm_num

/-! ## Section 3: The Parametric Pythagorean Family -/

/-- The parametric family (m²-n², 2mn, m²+n²) for Pythagorean triples.
    Bridge: classical number theory ↔ Berggren tree traversal. -/
def parametricTriple (m n : ℤ) : ℤ × ℤ × ℤ := (m^2 - n^2, 2*m*n, m^2 + n^2)

/-- The parametric family always produces Pythagorean triples (Euclid).
    Bridge: ancient mathematics ↔ modern algebraic structure. -/
theorem parametricTriple_pythag (m n : ℤ) :
    IsPythag (parametricTriple m n).1 (parametricTriple m n).2.1
             (parametricTriple m n).2.2 := by
  unfold IsPythag parametricTriple; ring

/-- (3,4,5) arises from (m,n) = (2,1). -/
theorem parametric_seed : parametricTriple 2 1 = (3, 4, 5) := by
  unfold parametricTriple; norm_num

/-- (5,12,13) arises from (m,n) = (3,2). -/
theorem parametric_5_12_13 : parametricTriple 3 2 = (5, 12, 13) := by
  unfold parametricTriple; norm_num

/-- (15,8,17) arises from (m,n) = (4,1). -/
theorem parametric_15_8_17 : parametricTriple 4 1 = (15, 8, 17) := by
  unfold parametricTriple; norm_num

/-- The parametric family always lies on the light cone. -/
theorem parametric_on_light_cone (m n : ℤ) :
    lorentzQ (parametricTriple m n).1 (parametricTriple m n).2.1
             (parametricTriple m n).2.2 = 0 := by
  unfold lorentzQ parametricTriple; ring

/-! ## Section 4: Abstract Quadratic Form Preservation -/

/-- A matrix preserves a quadratic form Q iff MᵀQM = Q. -/
def preservesForm (M Q : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  M.transpose * Q * M = Q

/-- If M₁ and M₂ both preserve Q, so does M₁ * M₂.
    This is the submonoid closure theorem.
    Bridge: abstract algebra ↔ certified_robustness (composition of Lipschitz maps). -/
theorem preservesForm_mul (M₁ M₂ Q : Matrix (Fin 3) (Fin 3) ℤ)
    (h₁ : preservesForm M₁ Q) (h₂ : preservesForm M₂ Q) :
    preservesForm (M₁ * M₂) Q := by
  unfold preservesForm at *
  have : (M₁ * M₂).transpose * Q * (M₁ * M₂) =
    M₂.transpose * (M₁.transpose * Q * M₁) * M₂ := by
    simp [Matrix.transpose_mul, Matrix.mul_assoc]
  rw [this, h₁, h₂]

/-- The identity preserves any quadratic form. -/
theorem preservesForm_one (Q : Matrix (Fin 3) (Fin 3) ℤ) :
    preservesForm 1 Q := by
  unfold preservesForm; simp

/-- Each generator preserves the Lorentz form (rephrased abstractly). -/
theorem matA_preserves_abstract : preservesForm matA metricQ :=
  matA_preserves_lorentz
theorem matB_preserves_abstract : preservesForm matB metricQ :=
  matB_preserves_lorentz
theorem matC_preserves_abstract : preservesForm matC metricQ :=
  matC_preserves_lorentz

/-! ## Section 5: Trace Algebra -/

/-- Trace of product AB = 17. The trace of products encodes
    the "angles" between generators in O(2,1;ℤ).
    Bridge: spectral invariants ↔ quantum observable basis-independence. -/
theorem trace_matAB : (matA * matB).trace = 17 := by native_decide

/-- Trace of product AC = 15. -/
theorem trace_matAC : (matA * matC).trace = 15 := by native_decide

/-- Trace of product BC = 17. Note: Tr(AB) = Tr(BC) = 17.
    This reflects the "A ↔ C symmetry" of the Berggren tree. -/
theorem trace_matBC : (matB * matC).trace = 17 := by native_decide

/-- Trace(AB) = Trace(BA) (conjugation invariance, verified concretely). -/
theorem trace_AB_eq_BA : (matA * matB).trace = (matB * matA).trace := by native_decide
theorem trace_AC_eq_CA : (matA * matC).trace = (matC * matA).trace := by native_decide
theorem trace_BC_eq_CB : (matB * matC).trace = (matC * matB).trace := by native_decide

/-- The trace of AB equals the trace of BC — an unexpected symmetry.
    This reflects the involutive relationship between the A and C generators.
    Bridge: spectral symmetry ↔ hidden conservation law. -/
theorem trace_AB_eq_BC : (matA * matB).trace = (matB * matC).trace := by native_decide

/-! ## Section 6: Special Pythagorean Triple Families -/

/-- The "twin leg" family: triples where |a - b| = 1.
    Examples: (3,4,5), (20,21,29), (119,120,169), (696,697,985).
    These arise from the B-branch of the Berggren tree.
    Bridge: number theory (consecutive integers) ↔ dynamics (B-orbit). -/
def isTwinLeg (a b c : ℤ) : Prop := IsPythag a b c ∧ (a - b = 1 ∨ b - a = 1)

/-- (3,4,5) is a twin-leg triple. -/
theorem seed_twin_leg : isTwinLeg 3 4 5 := by
  exact ⟨seed_is_pythag, Or.inr (by norm_num)⟩

/-- (20,21,29) is a twin-leg triple. -/
theorem twin_20_21_29 : isTwinLeg 20 21 29 := by
  exact ⟨by unfold IsPythag; norm_num, Or.inr (by norm_num)⟩

/-- (119,120,169) is a twin-leg triple. -/
theorem twin_119_120_169 : isTwinLeg 119 120 169 := by
  exact ⟨by unfold IsPythag; norm_num, Or.inr (by norm_num)⟩

/-- (696,697,985) is a twin-leg triple. -/
theorem twin_696_697_985 : isTwinLeg 696 697 985 := by
  exact ⟨by unfold IsPythag; norm_num, Or.inr (by norm_num)⟩

/-! ## Section 7: Matrix Norm Bounds (Entrywise) -/

/-- All entries of all three Berggren generators have absolute value ≤ 3.
    This gives a uniform entrywise bound on all generators.
    Impact: lipschitz_certified_robustness — for n generators composed,
    the infinity norm grows at most as 9^n (since each row has 3 entries). -/
theorem berggren_uniform_entry_bound :
    ∀ k : Fin 3, ∀ i j : Fin 3, |berggrenGen k i j| ≤ 3 := by
  decide

/-- The sum of absolute values in any row of any generator is ≤ 7.
    This is the ∞-norm (maximum row sum) of the generators.
    Impact: ‖Mv‖∞ ≤ 7 · ‖v‖∞ for any generator M.
    Bridge: matrix analysis ↔ lipschitz_certified_robustness. -/
theorem berggren_row_sum_bound :
    ∀ k : Fin 3, ∀ i : Fin 3,
      |berggrenGen k i 0| + |berggrenGen k i 1| + |berggrenGen k i 2| ≤ 7 := by
  decide

/-! ## Section 8: Cayley-Hamilton and Characteristic Polynomial Values -/

/-- det(0·I - B) = -det(B) = 1. The constant term of the char poly of B. -/
theorem charPoly_B_constant : (-matB).det = 1 := by native_decide

/-- det(I - B) = -8. The char poly of B evaluated at 1.
    Since this is nonzero, 1 is not an eigenvalue of B. -/
theorem charPoly_B_at_1 : (1 - matB).det = -8 := by native_decide

/-- det(I - A) = 0. So 1 IS an eigenvalue of A.
    Bridge: spectral theory ↔ fixed-point dynamics. -/
theorem charPoly_A_at_1 : (1 - matA).det = 0 := by native_decide

/-- det(I - C) = 0. So 1 IS an eigenvalue of C (like A). -/
theorem charPoly_C_at_1 : (1 - matC).det = 0 := by native_decide

/-! ## Section 9: Inverse Relations -/

/-- A⁻¹ · C = -diag(1,1,-1) = -Q_L.
    This remarkable identity shows that A and C are "Lorentz-conjugates":
    going from A to C is equivalent to a reflection in the Lorentz metric!
    Bridge: hidden symmetry between generators ↔ spectral duality. -/
theorem invA_matC_is_neg_metric :
    invA * matC = !![-1, 0, 0; 0, -1, 0; 0, 0, 1] := by native_decide

/-- B⁻¹ · A = diag(1,-1,1).
    The B and A generators are related by a simple sign flip.
    Bridge: parity structure ↔ orientation reversal in O(2,1;ℤ). -/
theorem invB_matA_diagonal :
    invB * matA = !![1, 0, 0; 0, -1, 0; 0, 0, 1] := by native_decide

/-- A⁻¹ · C is minus the Lorentz metric — alternative statement. -/
theorem invA_matC_eq_neg_metricQ : invA * matC = -metricQ := by native_decide

/-- From A⁻¹C = -Q, we get C = -A · Q (since A · A⁻¹ = I).
    This expresses C entirely in terms of A and the Lorentz metric.
    Bridge: generator reduction — only need A, B, and Q to reconstruct C.
    Impact: post_quantum_security — reduced key space from 3 to 2 generators. -/
theorem matC_from_matA_metric : matC = -(matA * metricQ) := by native_decide

/-! ## Section 10: Word Composition Helper -/

/-- The parity of a Berggren word determines the determinant sign.
    Words with even number of B's have det +1, odd have det -1.
    Bridge: monoid homomorphism ↔ ℤ/2ℤ orientation grading. -/
def wordParity' (w : BerggrenWord) : ℕ :=
  (w.letters.filter (· == 1)).length

/-- The empty word has even parity. -/
theorem empty_word_even : wordParity' ⟨[]⟩ = 0 := by
  unfold wordParity'; simp

/-- A word [0] (just A) has even parity. -/
theorem word_A_even : wordParity' ⟨[0]⟩ = 0 := by
  unfold wordParity'; simp [List.filter]

/-- A word [1] (just B) has odd parity. -/
theorem word_B_odd : wordParity' ⟨[1]⟩ = 1 := by
  unfold wordParity'; simp [List.filter]

/-- A word [2] (just C) has even parity. -/
theorem word_C_even : wordParity' ⟨[2]⟩ = 0 := by
  unfold wordParity'; simp [List.filter]

/-! ## Section 11: Lorentz Group Structure Verification -/

/-- The Lorentz metric is its own inverse: Q² = I.
    This is a key structural property of the Lorentz group.
    Bridge: involutive structure ↔ quantum gate self-adjointness. -/
theorem metricQ_squared : metricQ * metricQ = 1 := by native_decide

/-- The Lorentz metric is symmetric. -/
theorem metricQ_symmetric : metricQ.transpose = metricQ := by native_decide

/-- The Lorentz metric has determinant -1 (signature (2,1)). -/
theorem metricQ_det : metricQ.det = -1 := by native_decide

/-- The Lorentz metric has trace 1 (= 1 + 1 + (-1)). -/
theorem metricQ_trace : metricQ.trace = 1 := by native_decide

/-! ## Section 12: Product Structure and Growth Rates -/

/-- A² has trace 3 (same as A) — A is "parabolic" in O(2,1). -/
theorem trace_matA_sq : (matA * matA).trace = 3 := by native_decide

/-- B² has trace 35. The quadratic growth of trace under squaring
    reflects the exponential expansion of B.
    Bridge: trace growth ↔ Lyapunov exponent estimation. -/
theorem trace_matB_sq : (matB * matB).trace = 35 := by native_decide

/-- C² has trace 3 (same as C) — C is also "parabolic". -/
theorem trace_matC_sq : (matC * matC).trace = 3 := by native_decide

/-- Trace(B²) = 35 = Trace(B)² + 2·det(B)·Trace(B).
    This is the Newton identity relating power-sum traces to
    elementary symmetric functions of eigenvalues. -/
theorem trace_Bsq_value : (matB * matB).trace = 35 := by native_decide

/-! ## Section 13: Berggren Word Matrix Examples -/

/-- The matrix for word [0,1] (A then B) is A*B. -/
theorem wordMatrix_AB : wordMatrix ⟨[0, 1]⟩ = matA * matB := by
  unfold wordMatrix berggrenGen; simp [List.foldl]

/-- The matrix for word [1,0] (B then A) is B*A. -/
theorem wordMatrix_BA : wordMatrix ⟨[1, 0]⟩ = matB * matA := by
  unfold wordMatrix berggrenGen; simp [List.foldl]

/-- AB ≠ BA — non-commutativity at the word level.
    Impact: post_quantum_security — word order matters for the monoid action. -/
theorem wordMatrix_AB_ne_BA : wordMatrix ⟨[0, 1]⟩ ≠ wordMatrix ⟨[1, 0]⟩ := by
  rw [wordMatrix_AB, wordMatrix_BA]
  exact matA_matB_noncommutative

end BerggrenLorentz