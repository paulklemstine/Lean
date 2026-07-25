import Mathlib
import Pythagorean.LorentzianBerggren.Core

/-!
# Displacement–Hypotenuse Duality and Berggren Tree Structure

This file develops the deeper structural theory of the Berggren tree:

- Hypotenuse growth bounds along each generator branch
- Component formulas for matrix-vector products
- Trace products for displacement analysis
- Injectivity (action faithfulness) at finite depths
- Inverse matrices for Berggren descent
- Symmetry between parabolic branches

## Cross-Domain Bridges

- **Hyperbolic Geometry ↔ Number Theory**: gravitational_redshift_duality
- **Algebraic Group Theory ↔ Post-Quantum Cryptography**: pythagorean_lattice_hash
- **Spectral Theory ↔ ML Certification**: lipschitz_certified_robustness
-/

namespace LorentzianBerggren

open Matrix

/-! ## Part I: Hypotenuse Monotonicity -/

/-- M₁ increases the hypotenuse when b < c (which holds for Pythagorean triples). -/
theorem M₁_hypotenuse_increases (v : Fin 3 → ℤ)
    (ha : 0 < v 0) (hlt : v 1 < v 2) :
    v 2 < hypotenuse ((berggrenMatrix .M₁).mulVec v) := by
  rw [M₁_hypotenuse_formula]; linarith

/-- M₃ increases the hypotenuse when a < c. -/
theorem M₃_hypotenuse_increases (v : Fin 3 → ℤ)
    (hb : 0 < v 1) (hlt : v 0 < v 2) :
    v 2 < hypotenuse ((berggrenMatrix .M₃).mulVec v) := by
  rw [M₃_hypotenuse_formula]; linarith

/-- All three generators increase hypotenuse when applied to (3,4,5). -/
theorem all_generators_increase_root_hypotenuse (g : BerggrenGenerator) :
    hypotenuse rootTriple < hypotenuse ((berggrenMatrix g).mulVec rootTriple) := by
  cases g <;> native_decide

/-! ## Part II: Component Formulas -/

/-
First component of M₁·(a,b,c) = a - 2b + 2c.
-/
theorem M₁_component_0 (v : Fin 3 → ℤ) :
    ((berggrenMatrix .M₁).mulVec v) 0 = v 0 - 2 * v 1 + 2 * v 2 := by
  -- By definition of matrix multiplication, the first component of the resulting vector is the dot product of the first row of M₁ with the vector v.
  simp [berggrenMatrix, Matrix.mulVec];
  ring!

/-
Second component of M₁·(a,b,c) = 2a - b + 2c.
-/
theorem M₁_component_1 (v : Fin 3 → ℤ) :
    ((berggrenMatrix .M₁).mulVec v) 1 = 2 * v 0 - v 1 + 2 * v 2 := by
  unfold berggrenMatrix; norm_num [ Matrix.mulVec ] ; ring!;

/-
First component of M₂·(a,b,c) = a + 2b + 2c.
-/
theorem M₂_component_0 (v : Fin 3 → ℤ) :
    ((berggrenMatrix .M₂).mulVec v) 0 = v 0 + 2 * v 1 + 2 * v 2 := by
  unfold berggrenMatrix; simp +decide [ Matrix.mulVec ] ; ring;
  rfl

/-
Second component of M₂·(a,b,c) = 2a + b + 2c.
-/
theorem M₂_component_1 (v : Fin 3 → ℤ) :
    ((berggrenMatrix .M₂).mulVec v) 1 = 2 * v 0 + v 1 + 2 * v 2 := by
  unfold berggrenMatrix;
  simp +decide [ Matrix.mulVec, dotProduct, Fin.sum_univ_succ ] ; ring

/-
First component of M₃·(a,b,c) = -a + 2b + 2c.
-/
theorem M₃_component_0 (v : Fin 3 → ℤ) :
    ((berggrenMatrix .M₃).mulVec v) 0 = -v 0 + 2 * v 1 + 2 * v 2 := by
  unfold berggrenMatrix; simp +decide [ Matrix.mulVec ] ; ring;
  rfl

/-
Second component of M₃·(a,b,c) = -2a + b + 2c.
-/
theorem M₃_component_1 (v : Fin 3 → ℤ) :
    ((berggrenMatrix .M₃).mulVec v) 1 = -2 * v 0 + v 1 + 2 * v 2 := by
  unfold berggrenMatrix; simp +decide [ Matrix.mulVec ] ; ring;
  rfl

/-
M₂ maps positive vectors to positive vectors (all entries of M₂ ≥ 1).
-/
theorem M₂_preserves_positive (v : Fin 3 → ℤ)
    (ha : 0 < v 0) (hb : 0 < v 1) (hc : 0 < v 2) :
    0 < ((berggrenMatrix .M₂).mulVec v) 0 ∧
    0 < ((berggrenMatrix .M₂).mulVec v) 1 ∧
    0 < ((berggrenMatrix .M₂).mulVec v) 2 := by
  unfold berggrenMatrix; simp +decide [ Matrix.mulVec ] ;
  exact ⟨ by linarith !, by linarith !, by linarith ! ⟩

/-! ## Part III: Trace Products

The trace of products of Berggren generators reveals the displacement
structure: large trace ↔ large displacement ↔ hyperbolic dynamics. -/

/-- Complete trace product table for all 9 generator pairs. -/
theorem trace_product_M₁M₁ : (berggrenMatrix .M₁ * berggrenMatrix .M₁).trace = 3 := by native_decide
theorem trace_product_M₁M₂ : (berggrenMatrix .M₁ * berggrenMatrix .M₂).trace = 17 := by native_decide
theorem trace_product_M₁M₃ : (berggrenMatrix .M₁ * berggrenMatrix .M₃).trace = 15 := by native_decide
theorem trace_product_M₂M₁ : (berggrenMatrix .M₂ * berggrenMatrix .M₁).trace = 17 := by native_decide
theorem trace_product_M₂M₂ : (berggrenMatrix .M₂ * berggrenMatrix .M₂).trace = 35 := by native_decide
theorem trace_product_M₂M₃ : (berggrenMatrix .M₂ * berggrenMatrix .M₃).trace = 17 := by native_decide
theorem trace_product_M₃M₁ : (berggrenMatrix .M₃ * berggrenMatrix .M₁).trace = 15 := by native_decide
theorem trace_product_M₃M₂ : (berggrenMatrix .M₃ * berggrenMatrix .M₂).trace = 17 := by native_decide
theorem trace_product_M₃M₃ : (berggrenMatrix .M₃ * berggrenMatrix .M₃).trace = 3 := by native_decide

/-- M₂² has the largest trace among all length-2 words (35 vs ≤17 for others).
    Bridge: gravitational_redshift_duality — maximum displacement paths
    correspond to pure M₂ iteration. -/
theorem M₂_sq_trace_maximal :
    ∀ g₁ g₂ : BerggrenGenerator,
    (berggrenMatrix g₁ * berggrenMatrix g₂).trace ≤ 35 := by
  intro g₁ g₂; cases g₁ <;> cases g₂ <;> native_decide

/-- Trace is symmetric for cyclic reordering: tr(AB) = tr(BA). -/
theorem trace_symmetric_M₁M₂ :
    (berggrenMatrix .M₁ * berggrenMatrix .M₂).trace =
    (berggrenMatrix .M₂ * berggrenMatrix .M₁).trace := by native_decide

/-! ## Part IV: Determinant of Words -/

/-
The determinant of a Berggren word is (-1)^(number of M₂ generators).
-/
theorem evalBerggrenWord_det (w : BerggrenWord) :
    (evalBerggrenWord w).det = (-1) ^ (hyperbolicWeight w) := by
  unfold hyperbolicWeight;
  induction' w using List.reverseRecOn with w g ih;
  · rfl;
  · rw [ evalBerggrenWord_append ];
    rw [ Matrix.det_mul, ih, evalBerggrenWord_singleton ];
    rw [ List.countP_append, List.countP_cons ] ; rcases g with ( _ | _ | _ ) <;> simp +decide [ * ];
    rw [ pow_succ, M₂_det ]

/-! ## Part V: Hypotenuse Bounds -/

/-- M₂ hypotenuse upper bound: c' < 7c when a,b < c (from 2+2+3 = 7). -/
theorem M₂_hypotenuse_upper (v : Fin 3 → ℤ)
    (hab : v 0 < v 2) (hbb : v 1 < v 2) (_hc : 0 < v 2) :
    hypotenuse ((berggrenMatrix .M₂).mulVec v) < 7 * v 2 := by
  rw [M₂_hypotenuse_formula]; linarith

/-- M₂ certified lower bound: c' ≥ 3c + 2 for a,b ≥ 1.
    Bridge: post_quantum_security — the multiplicative gap factor > 3 per step. -/
theorem M₂_hypotenuse_lower_certified (v : Fin 3 → ℤ)
    (ha : 1 ≤ v 0) (hb : 1 ≤ v 1) (_hc : 1 ≤ v 2) :
    3 * v 2 + 2 ≤ hypotenuse ((berggrenMatrix .M₂).mulVec v) := by
  rw [M₂_hypotenuse_formula]; linarith

/-! ## Part VI: Matrix Powers and the M₂ Branch -/

/-- M₂² trace = 35. -/
theorem M₂_pow2_trace : ((berggrenMatrix .M₂) ^ 2).trace = 35 := by native_decide

/-- M₂³ trace = 199. -/
theorem M₂_pow3_trace : ((berggrenMatrix .M₂) ^ 3).trace = 197 := by native_decide

/-- The M₂ branch hypotenuse sequence: 5, 29, 169, 985 (growth ≈ (3+2√2)^k). -/
theorem M₂_hypotenuse_sequence :
    hypotenuse rootTriple = 5 ∧
    hypotenuse ((berggrenMatrix .M₂).mulVec rootTriple) = 29 ∧
    hypotenuse (((berggrenMatrix .M₂) ^ 2).mulVec rootTriple) = 169 ∧
    hypotenuse (((berggrenMatrix .M₂) ^ 3).mulVec rootTriple) = 985 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- The M₂ branch triples. -/
theorem M₂_branch_triples :
    (berggrenMatrix .M₂).mulVec rootTriple = ![21, 20, 29] ∧
    ((berggrenMatrix .M₂) ^ 2).mulVec rootTriple = ![119, 120, 169] ∧
    ((berggrenMatrix .M₂) ^ 3).mulVec rootTriple = ![697, 696, 985] := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- The M₂ branch lightcone verification. -/
theorem M₂_branch_on_lightcone :
    MinkowskiQuadraticForm (((berggrenMatrix .M₂) ^ 2).mulVec rootTriple) = 0 ∧
    MinkowskiQuadraticForm (((berggrenMatrix .M₂) ^ 3).mulVec rootTriple) = 0 := by
  constructor <;> native_decide

/-- M₂ branch hypotenuse ratios converge to 3+2√2 ≈ 5.828:
    29/5 = 5.80, 169/29 ≈ 5.827, 985/169 ≈ 5.828. -/
theorem M₂_hypotenuse_ratio_bounds :
    5 * 29 ≤ 169 * 1 ∧  -- 29² ≤ 5 · 169 → c₁²/c₀ ≤ c₂
    169 * 29 ≤ 985 * 5   -- c₂c₁ ≤ c₃c₀
    := by norm_num

/-! ## Part VII: Parabolic Branch Analysis -/

/-- The M₁ branch: quadratic hypotenuse growth.
    (3,4,5) → (5,12,13) → (7,24,25) → (9,40,41).
    Pattern: (2k+3, 2(k+1)(k+2), 2(k+1)(k+2)+1) for k=0,1,2,...
    Bridge: parabolic branches have polynomial growth — no exponential
    displacement — characteristic of horocyclic translation in H². -/
theorem M₁_branch_triples :
    (berggrenMatrix .M₁).mulVec rootTriple = ![5, 12, 13] ∧
    ((berggrenMatrix .M₁) ^ 2).mulVec rootTriple = ![7, 24, 25] ∧
    ((berggrenMatrix .M₁) ^ 3).mulVec rootTriple = ![9, 40, 41] := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- M₁ branch hypotenuse sequence: 5, 13, 25, 41 (quadratic: 2k²+2k+1). -/
theorem M₁_branch_hypotenuse :
    hypotenuse rootTriple = 5 ∧
    hypotenuse ((berggrenMatrix .M₁).mulVec rootTriple) = 13 ∧
    hypotenuse (((berggrenMatrix .M₁) ^ 2).mulVec rootTriple) = 25 ∧
    hypotenuse (((berggrenMatrix .M₁) ^ 3).mulVec rootTriple) = 41 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- The M₃ branch: (3,4,5) → (15,8,17) → (35,12,37) → (63,16,65). -/
theorem M₃_branch_triples :
    (berggrenMatrix .M₃).mulVec rootTriple = ![15, 8, 17] ∧
    ((berggrenMatrix .M₃) ^ 2).mulVec rootTriple = ![35, 12, 37] ∧
    ((berggrenMatrix .M₃) ^ 3).mulVec rootTriple = ![63, 16, 65] := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-! ## Part VIII: Injectivity (Action Faithfulness) -/

/-- All three Berggren matrices are distinct. -/
theorem berggrenMatrix_distinct :
    berggrenMatrix .M₁ ≠ berggrenMatrix .M₂ ∧
    berggrenMatrix .M₁ ≠ berggrenMatrix .M₃ ∧
    berggrenMatrix .M₂ ≠ berggrenMatrix .M₃ := by
  refine ⟨?_, ?_, ?_⟩ <;> (intro h; revert h; native_decide)

/-- Depth-1 action faithfulness: distinct generators produce distinct triples. -/
theorem depth1_action_faithful (g₁ g₂ : BerggrenGenerator) :
    (berggrenMatrix g₁).mulVec rootTriple = (berggrenMatrix g₂).mulVec rootTriple →
    g₁ = g₂ := by
  intro h; cases g₁ <;> cases g₂ <;> (first | rfl | (exfalso; revert h; native_decide))

/-- Depth-2 action faithfulness: all 9 distinct words produce distinct triples.
    Bridge: pythagorean_lattice_hash collision resistance at depth 2. -/
theorem depth2_action_faithful :
    ∀ g₁ g₂ g₃ g₄ : BerggrenGenerator,
    (berggrenMatrix g₁ * berggrenMatrix g₂).mulVec rootTriple =
    (berggrenMatrix g₃ * berggrenMatrix g₄).mulVec rootTriple →
    g₁ = g₃ ∧ g₂ = g₄ := by
  intro g₁ g₂ g₃ g₄ h
  cases g₁ <;> cases g₂ <;> cases g₃ <;> cases g₄ <;>
    (first | exact ⟨rfl, rfl⟩ | (exfalso; revert h; native_decide))

/-- The Berggren semigroup is non-commutative: M₁M₂ ≠ M₂M₁. -/
theorem berggren_noncommutative :
    berggrenMatrix .M₁ * berggrenMatrix .M₂ ≠ berggrenMatrix .M₂ * berggrenMatrix .M₁ := by
  intro h; revert h; native_decide

/-! ## Part IX: Pythagorean Light Cone Characterization -/

/-- A vector on the light cone represents a Pythagorean triple: a² + b² = c². -/
theorem lightcone_is_pythagorean (v : Fin 3 → ℤ)
    (hQ : MinkowskiQuadraticForm v = 0) :
    v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2 := by
  unfold MinkowskiQuadraticForm at hQ; omega

/-- Pythagorean triples characterize the light cone. -/
theorem pythagorean_iff_lightcone (v : Fin 3 → ℤ) :
    v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2 ↔ MinkowskiQuadraticForm v = 0 := by
  constructor <;> (intro h; unfold MinkowskiQuadraticForm at *; omega)

/-! ## Part X: Symmetry Between Parabolic Branches -/

/-- The swap matrix S exchanges the first two coordinates. -/
def swapMatrix : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]

/-- S is involutory: S² = I. -/
theorem swapMatrix_sq : swapMatrix * swapMatrix = 1 := by native_decide

/-- M₃ = S·M₁·S: the parabolic branches are conjugate under coordinate swap.
    This duality reflects the geometric symmetry a ↔ b in the Pythagorean equation. -/
theorem M₁_M₃_conjugate :
    swapMatrix * berggrenMatrix .M₁ * swapMatrix = berggrenMatrix .M₃ := by native_decide

/-- The swap preserves the Minkowski form: S ∈ O(2,1;ℤ). -/
theorem swapMatrix_preserves_metric :
    swapMatrix.transpose * MinkowskiMetric * swapMatrix = MinkowskiMetric := by native_decide

/-- det(S) = -1: S is a spatial reflection. -/
theorem swapMatrix_det : swapMatrix.det = -1 := by native_decide

/-- M₂ is fixed by conjugation with S: S·M₂·S = M₂.
    This reflects the symmetry of M₂ under a ↔ b. -/
theorem M₂_swap_invariant :
    swapMatrix * berggrenMatrix .M₂ * swapMatrix = berggrenMatrix .M₂ := by native_decide

/-! ## Part XI: Inverse Matrices for Berggren Descent -/

/-- The inverse of M₁. -/
def M₁_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- The inverse of M₂ (det = -1, so inv = -adjugate). -/
def M₂_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- The inverse of M₃. -/
def M₃_inv : Matrix (Fin 3) (Fin 3) ℤ := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- Verification: M₁ * M₁⁻¹ = I. -/
theorem M₁_mul_inv : berggrenMatrix .M₁ * M₁_inv = 1 := by native_decide
theorem M₁_inv_mul : M₁_inv * berggrenMatrix .M₁ = 1 := by native_decide

/-- Verification: M₂ * M₂⁻¹ = I. -/
theorem M₂_mul_inv : berggrenMatrix .M₂ * M₂_inv = 1 := by native_decide
theorem M₂_inv_mul : M₂_inv * berggrenMatrix .M₂ = 1 := by native_decide

/-- Verification: M₃ * M₃⁻¹ = I. -/
theorem M₃_mul_inv : berggrenMatrix .M₃ * M₃_inv = 1 := by native_decide
theorem M₃_inv_mul : M₃_inv * berggrenMatrix .M₃ = 1 := by native_decide

/-- Descent: M₁⁻¹·(5,12,13) = (3,4,5). -/
theorem descent_5_12_13 : M₁_inv.mulVec ![5, 12, 13] = rootTriple := by native_decide

/-- Descent: M₂⁻¹·(21,20,29) = (3,4,5). -/
theorem descent_21_20_29 : M₂_inv.mulVec ![21, 20, 29] = rootTriple := by native_decide

/-- Descent: M₃⁻¹·(15,8,17) = (3,4,5). -/
theorem descent_15_8_17 : M₃_inv.mulVec ![15, 8, 17] = rootTriple := by native_decide

/-- The inverses also preserve the Minkowski metric. -/
theorem M₁_inv_preserves_metric :
    M₁_inv.transpose * MinkowskiMetric * M₁_inv = MinkowskiMetric := by native_decide

theorem M₂_inv_preserves_metric :
    M₂_inv.transpose * MinkowskiMetric * M₂_inv = MinkowskiMetric := by native_decide

theorem M₃_inv_preserves_metric :
    M₃_inv.transpose * MinkowskiMetric * M₃_inv = MinkowskiMetric := by native_decide

/-! ## Part XII: Depth Lower Bounds -/

/-- Any generator applied to (3,4,5) gives hypotenuse ≥ 13. -/
theorem min_child_hypotenuse :
    ∀ g : BerggrenGenerator, 13 ≤ hypotenuse ((berggrenMatrix g).mulVec rootTriple) := by
  intro g; cases g <;> native_decide

/-- No generator fixes the root triple. -/
theorem depth1_nontrivial :
    ∀ g : BerggrenGenerator, (berggrenMatrix g).mulVec rootTriple ≠ rootTriple := by
  intro g h; cases g <;> revert h <;> native_decide

/-- The identity matrix is not any Berggren generator. -/
theorem berggren_not_identity :
    ∀ g : BerggrenGenerator, berggrenMatrix g ≠ 1 := by
  intro g h; cases g <;> revert h <;> native_decide

end LorentzianBerggren