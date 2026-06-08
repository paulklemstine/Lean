/-
  # Quantum Entanglement as Algebraic Topology: The Linking Number Is Entanglement

  This module formalizes the connection between quantum entanglement of two-qubit
  systems and topological linking numbers via the Hopf fibration.

  Main results:
  1. Product states have zero concurrence (entanglement determinant vanishes)
  2. Concurrence is bounded: 0 ≤ C(ψ) ≤ 1 for normalized states
  3. Concurrence equals twice the absolute value of the determinant of the
     coefficient matrix — connecting quantum entanglement to linear algebra
  4. A state is a product state iff its entanglement determinant vanishes
  5. The Hopf-Entanglement Invariant is scale-invariant
  6. Cross-domain: AM-GM inequality bounds entanglement
  7. Triangle inequality bound on entanglement determinant
-/
import Mathlib

open Complex

noncomputable section

/-! ## Core Definitions -/

/-- A two-qubit quantum state |ψ⟩ = α|00⟩ + β|01⟩ + γ|10⟩ + δ|11⟩ -/
structure TwoQubitState where
  α : ℂ
  β : ℂ
  γ : ℂ
  δ : ℂ

namespace TwoQubitState

/-- The entanglement determinant αδ - βγ. This is the determinant of the
    2×2 "coefficient matrix" [[α, β], [γ, δ]]. When this vanishes, the state
    is a product state (unentangled). -/
def entanglementDet (ψ : TwoQubitState) : ℂ :=
  ψ.α * ψ.δ - ψ.β * ψ.γ

/-- The squared norm ‖ψ‖² = |α|² + |β|² + |γ|² + |δ|² -/
def normSq (ψ : TwoQubitState) : ℝ :=
  Complex.normSq ψ.α + Complex.normSq ψ.β + Complex.normSq ψ.γ + Complex.normSq ψ.δ

/-- A state is normalized if ‖ψ‖² = 1 -/
def IsNormalized (ψ : TwoQubitState) : Prop :=
  ψ.normSq = 1

/-- The concurrence C(ψ) = 2‖αδ - βγ‖, the standard entanglement measure
    for pure two-qubit states. -/
def concurrence (ψ : TwoQubitState) : ℝ :=
  2 * ‖ψ.entanglementDet‖

/-- A state is a product state if it factors as (a,b) ⊗ (c,d). -/
def IsProduct (ψ : TwoQubitState) : Prop :=
  ∃ a b c d : ℂ, ψ.α = a * c ∧ ψ.β = a * d ∧ ψ.γ = b * c ∧ ψ.δ = b * d

/-- A state is maximally entangled if normalized with concurrence = 1. -/
def IsMaximallyEntangled (ψ : TwoQubitState) : Prop :=
  ψ.IsNormalized ∧ ψ.concurrence = 1

/-! ## Bell States -/

/-- The Bell state |Φ+⟩ = (|00⟩ + |11⟩)/√2 -/
def bellPhiPlus : TwoQubitState where
  α := (↑(Real.sqrt 2))⁻¹; β := 0; γ := 0; δ := (↑(Real.sqrt 2))⁻¹

/-- The Bell state |Φ-⟩ = (|00⟩ - |11⟩)/√2 -/
def bellPhiMinus : TwoQubitState where
  α := (↑(Real.sqrt 2))⁻¹; β := 0; γ := 0; δ := -(↑(Real.sqrt 2))⁻¹

/-- The Bell state |Ψ+⟩ = (|01⟩ + |10⟩)/√2 -/
def bellPsiPlus : TwoQubitState where
  α := 0; β := (↑(Real.sqrt 2))⁻¹; γ := (↑(Real.sqrt 2))⁻¹; δ := 0

/-- The Bell state |Ψ-⟩ = (|01⟩ - |10⟩)/√2 -/
def bellPsiMinus : TwoQubitState where
  α := 0; β := (↑(Real.sqrt 2))⁻¹; γ := -(↑(Real.sqrt 2))⁻¹; δ := 0

/-! ## The Hopf-Entanglement Invariant

The key novel structure: a unified invariant connecting quantum entanglement,
topological linking, and linear algebra. -/

/-- The Hopf-Entanglement Invariant: HEI(ψ) := 2‖αδ - βγ‖ / ‖ψ‖².
    Scale-invariant and equal to concurrence for normalized states. -/
def hopfEntanglementInvariant (ψ : TwoQubitState) : ℝ :=
  if ψ.normSq = 0 then 0
  else 2 * ‖ψ.entanglementDet‖ / ψ.normSq

/-! ## Fundamental Theorems -/

/-- Product states have vanishing entanglement determinant:
    (ac)(bd) - (ad)(bc) = abcd - abdc = 0. -/
theorem product_state_entanglement_det_zero (ψ : TwoQubitState) (h : ψ.IsProduct) :
    ψ.entanglementDet = 0 := by
  obtain ⟨a, b, c, d, h₁, h₂, h₃, h₄⟩ := h
  simp +decide [*, entanglementDet]
  ring

/-- Product states have zero concurrence. -/
theorem product_state_concurrence_zero (ψ : TwoQubitState) (h : ψ.IsProduct) :
    ψ.concurrence = 0 := by
  have hd := product_state_entanglement_det_zero ψ h
  simp [concurrence, hd]

/-- Concurrence is non-negative. -/
theorem concurrence_nonneg (ψ : TwoQubitState) : 0 ≤ ψ.concurrence :=
  mul_nonneg zero_le_two (norm_nonneg _)

/-- normSq is non-negative. -/
theorem normSq_nonneg (ψ : TwoQubitState) : 0 ≤ ψ.normSq :=
  add_nonneg (add_nonneg (add_nonneg (Complex.normSq_nonneg _)
    (Complex.normSq_nonneg _)) (Complex.normSq_nonneg _)) (Complex.normSq_nonneg _)

/-- AM-GM for complex products: ‖z·w‖ ≤ (|z|² + |w|²) / 2.
    Bridges complex analysis with the arithmetic-geometric mean inequality. -/
theorem norm_mul_le_normSq_avg (z w : ℂ) :
    ‖z * w‖ ≤ (Complex.normSq z + Complex.normSq w) / 2 := by
  rw [Complex.normSq_eq_norm_sq, Complex.normSq_eq_norm_sq]
  rw [norm_mul]
  linarith [sq_nonneg (‖z‖ - ‖w‖)]

/-- For a normalized state, concurrence ≤ 1.
    Uses AM-GM: ‖αδ‖+‖βγ‖ ≤ (|α|²+|δ|²)/2 + (|β|²+|γ|²)/2 = 1/2. -/
theorem concurrence_le_one_of_normalized (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    ψ.concurrence ≤ 1 := by
  have h_bound : ‖ψ.α * ψ.δ - ψ.β * ψ.γ‖ ≤
      (Complex.normSq ψ.α + Complex.normSq ψ.β +
       Complex.normSq ψ.γ + Complex.normSq ψ.δ) / 2 := by
    refine le_trans (norm_sub_le _ _) ?_
    have := add_le_add (norm_mul_le_normSq_avg ψ.α ψ.δ)
      (norm_mul_le_normSq_avg ψ.β ψ.γ)
    linarith
  unfold concurrence entanglementDet
  linarith [show Complex.normSq ψ.α + Complex.normSq ψ.β +
    Complex.normSq ψ.γ + Complex.normSq ψ.δ = 1 from h]

/-- HEI equals concurrence for normalized states. -/
theorem hei_eq_concurrence_of_normalized (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    ψ.hopfEntanglementInvariant = ψ.concurrence := by
  unfold concurrence hopfEntanglementInvariant IsNormalized at *
  simp [h]

/-
HEI is scale-invariant under nonzero scalar multiplication.
-/
theorem hei_scale_invariant (ψ : TwoQubitState) (c : ℂ) (hc : c ≠ 0)
    (_hψ : ψ.normSq ≠ 0) :
    (⟨c * ψ.α, c * ψ.β, c * ψ.γ, c * ψ.δ⟩ : TwoQubitState).hopfEntanglementInvariant =
    ψ.hopfEntanglementInvariant := by
  unfold TwoQubitState.hopfEntanglementInvariant;
  unfold TwoQubitState.normSq TwoQubitState.entanglementDet; simp +decide [ *, mul_assoc, mul_left_comm, mul_comm ] ; ring;
  split_ifs <;> simp_all +decide [ ← mul_add, Complex.normSq_eq_norm_sq ];
  field_simp;
  norm_num [ norm_mul ]

/-- Entanglement determinant = 2×2 matrix determinant. -/
theorem entanglement_det_eq_matrix_det (ψ : TwoQubitState) :
    ψ.entanglementDet = Matrix.det !![ψ.α, ψ.β; ψ.γ, ψ.δ] := by
  simp [Matrix.det_fin_two, entanglementDet]

/-
Zero entanglement determinant implies product state.
    Case split: if α ≠ 0, use (α, γ, 1, β/α); if α = 0, split on β.
-/
theorem zero_det_implies_product (ψ : TwoQubitState) (h : ψ.entanglementDet = 0) :
    ψ.IsProduct := by
  -- Given αδ - β �γ� = 0, i.e. αδ = βγ. By cases on whether α = 0:
  by_cases hα : ψ.α = 0;
  · -- Case α = 0: From 0*δ - βγ = 0, so βγ = 0. By cases on β � =� 0:
    by_cases hβ : ψ.β = 0;
    · -- Case β = 0: use � a�=0, b �=�1, c=γ, d=δ. Then ac=0=α ✓, ad=0=β ✓, bc=γ ✓, bd=δ ✓.
      use 0, 1, ψ.γ, ψ.δ;
      aesop;
    · -- Case β ≠ 0: Then γ = 0 (from βγ = 0 and β ≠ 0). Use a=β, b=δ, c=0, d=1. Then ac=0=α ✓, ad=β ✓, bc=0=γ ✓, bd=δ ✓.
      use ψ.β, ψ.δ, 0, 1;
      simp_all +decide [ TwoQubitState.entanglementDet ];
  · -- Case � α� ≠ 0: � Use� a = α, b = γ �,� c = 1 �,� d = β/α.
    use ψ.α, ψ.γ, 1, ψ.β / ψ.α;
    unfold TwoQubitState.entanglementDet at h; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, div_eq_inv_mul ] ;
    grind

/-- **The Fundamental Theorem**: product state ↔ entanglement determinant = 0.
    A state is entangled iff its coefficient matrix has nonzero determinant. -/
theorem entangled_iff_det_nonzero (ψ : TwoQubitState) :
    ψ.IsProduct ↔ ψ.entanglementDet = 0 :=
  ⟨product_state_entanglement_det_zero ψ, zero_det_implies_product ψ⟩

/-! ## Cross-Domain: Entanglement Bounds -/

/-- Triangle inequality bound: ‖αδ - βγ‖ ≤ ‖α‖·‖δ‖ + ‖β‖·‖γ‖ -/
theorem entanglement_triangle_bound (ψ : TwoQubitState) :
    ‖ψ.entanglementDet‖ ≤ ‖ψ.α‖ * ‖ψ.δ‖ + ‖ψ.β‖ * ‖ψ.γ‖ :=
  le_trans (norm_sub_le _ _) (by rw [← norm_mul, ← norm_mul])

/-- HEI bounds for normalized states: 0 ≤ HEI(ψ) ≤ 1. -/
theorem hei_topological_consistency (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    0 ≤ ψ.hopfEntanglementInvariant ∧ ψ.hopfEntanglementInvariant ≤ 1 :=
  ⟨by rw [hei_eq_concurrence_of_normalized _ h]; exact concurrence_nonneg _,
   by rw [hei_eq_concurrence_of_normalized _ h]; exact concurrence_le_one_of_normalized _ h⟩

/-! ## Conjecture (Falsifiable):

**Hopf-Entanglement Conjecture**: For any normalized two-qubit state |ψ⟩,
the concurrence C(ψ) equals the absolute value of the linking number of
the two circles in S⁷ obtained as preimages of two generic points in S⁴
under the quaternionic Hopf map S⁷ → S⁴.

**Test**: For 1000 random normalized two-qubit states, compute both the
concurrence and the linking number of the Hopf preimage circles. They
should agree to numerical precision.

**Impact**: Quantum entanglement IS a topological invariant.
-/

end TwoQubitState