import Mathlib
import Bridges.NormInequalityBridge.NormInequalityBridge

/-!
# Concurrence and an obstruction to integer-valued linking models

For a two-qubit amplitude vector `(α, β, γ, δ)`, concurrence is
`2 ‖αδ - βγ‖`.  This chapter establishes its sharp range on normalized states,
its determinant criterion for separability, and its values on the four Bell
states.  It also isolates a basic obstruction to identifying concurrence with
an ordinary linking number: linking numbers are integers, whereas normalized
states can have concurrence `1/2`.

The topological conclusion does not rule out geometric quantities associated
with a Hopf fibration, nor a real-valued average or secondary invariant.  It
shows that an ordinary integer-valued linking number cannot equal concurrence
on all pure two-qubit states.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer; cross-domain bridge category), ranked by impact:
(1) concurrence of every pure two-qubit state is an ordinary linking number;
(2) a real-valued Hopf-geometric functional extends concurrence continuously;
(3) concurrence is exactly the norm of the exterior-product (Plücker) coordinate;
(4) the zero locus of concurrence is the Segre variety of product states;
(5) local unitary transformations preserve concurrence;
(6) Bell states are precisely the normalized determinant maximizers up to local
unitaries.  The first, second, fourth, and sixth are topology/algebra/quantum
bridges; the remaining targets provide their algebraic core.

Experiment (Experimenter): Product states give concurrence `0`, Bell states give
`1`, and the normalized state `(1/2, 1/√2, 0, 1/2)` gives `1/2`.  The last value
is already incompatible with every integer-valued linking number.

Analysis (Analyst): The determinant `αδ-βγ` is the decisive coordinate.  The
triangle inequality followed by two instances of Young's inequality bounds
its doubled norm by the total squared norm.  Thus normalization gives the sharp
interval `[0,1]`; vanishing is exactly the rank-one determinant equation.

Critique (Critic): Fibres of the quaternionic Hopf map `S⁷ → S⁴` are `S³`, not
circles.  Moreover, an ordinary linking number is discrete and integer-valued,
while concurrence varies continuously.  Consequently the proposed universal
equality needs a different topological definition.  No claim is made here that
all determinant maximizers have been classified up to local unitaries.

Synthesis (Principal Investigator): The surviving bridge is exterior algebra,
not literal integer linking: concurrence is a norm of a determinant coordinate.
Any future Hopf interpretation must use a real-valued geometric functional whose
Bell value is one and whose product-state value is zero.
-- !-- Lab Notes -- !--
-/

noncomputable section

namespace ConcurrenceTopology

/-- A two-qubit pure state in the computational basis. -/
structure TwoQubitState where
  alpha : ℂ
  beta : ℂ
  gamma : ℂ
  delta : ℂ

/-- Squared norm of the amplitude vector. -/
def normSquared (ψ : TwoQubitState) : ℝ :=
  Complex.normSq ψ.alpha + Complex.normSq ψ.beta +
    Complex.normSq ψ.gamma + Complex.normSq ψ.delta

/-- The determinant (exterior-product coordinate) of a two-qubit state. -/
def determinant (ψ : TwoQubitState) : ℂ :=
  ψ.alpha * ψ.delta - ψ.beta * ψ.gamma

/-- Pure-state concurrence. -/
def concurrence (ψ : TwoQubitState) : ℝ := 2 * ‖determinant ψ‖

/-- Unit normalization of a pure state. -/
def Normalized (ψ : TwoQubitState) : Prop := normSquared ψ = 1

/-
Concurrence is nonnegative.
-/
theorem concurrence_nonneg (ψ : TwoQubitState) : 0 ≤ concurrence ψ := by
  exact mul_nonneg zero_le_two ( norm_nonneg _ )

/-
The determinant criterion: concurrence vanishes exactly on rank-one
coefficient matrices.
-/
theorem concurrence_eq_zero_iff (ψ : TwoQubitState) :
    concurrence ψ = 0 ↔ ψ.alpha * ψ.delta = ψ.beta * ψ.gamma := by
  unfold concurrence;
  simp +decide [ determinant, sub_eq_zero ]

/-
The catalog's two-variable norm inequality controls the two products that
occur in the determinant coordinate.
-/
theorem two_product_young_bound (a b c d : ℝ) :
    2 * (a * d + b * c) ≤ a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 := by
  have had := NormInequalityBridge.sq_sum_ge_twice_product a d
  have hbc := NormInequalityBridge.sq_sum_ge_twice_product b c
  linarith

/-
The doubled determinant norm is bounded by the total squared norm.  This is
Young's inequality applied to the two products after the triangle inequality.
-/
theorem concurrence_le_normSquared (ψ : TwoQubitState) :
    concurrence ψ ≤ normSquared ψ := by
  unfold concurrence normSquared determinant;
  refine le_trans (mul_le_mul_of_nonneg_left (norm_sub_le _ _) zero_le_two) ?_
  simpa [Complex.normSq_eq_norm_sq, norm_mul] using
    two_product_young_bound ‖ψ.alpha‖ ‖ψ.beta‖ ‖ψ.gamma‖ ‖ψ.delta‖

/-
Every normalized two-qubit pure state has concurrence in `[0,1]`.
-/
theorem normalized_concurrence_mem_unitInterval (ψ : TwoQubitState)
    (hψ : Normalized ψ) : concurrence ψ ∈ Set.Icc (0 : ℝ) 1 := by
  exact ⟨ concurrence_nonneg ψ, by linarith [ concurrence_le_normSquared ψ, hψ.symm ] ⟩

/-
Multiplying all amplitudes by a unit complex phase does not change
concurrence.
-/
theorem concurrence_global_phase (u : ℂ) (hu : ‖u‖ = 1)
    (ψ : TwoQubitState) :
    concurrence ⟨u * ψ.alpha, u * ψ.beta, u * ψ.gamma, u * ψ.delta⟩ =
      concurrence ψ := by
  convert congr_arg ( fun x : ℝ => 2 * x ) ( congr_arg ( fun x : ℂ => ‖x‖ ) ( show u ^ 2 * ( ψ.alpha * ψ.delta - ψ.beta * ψ.gamma ) = u ^ 2 * ( ψ.alpha * ψ.delta - ψ.beta * ψ.gamma ) by ring ) ) using 1;
  · unfold concurrence determinant; ring;
  · unfold concurrence determinant; norm_num [ hu ] ;

/-- The Bell states, with independent signs in their nonzero amplitudes. -/
def bellPhi (s : ℝ) : TwoQubitState :=
  ⟨(Real.sqrt 2 / 2 : ℝ), 0, 0, (s * Real.sqrt 2 / 2 : ℝ)⟩

/-- The other Bell pair, with independent signs in its nonzero amplitudes. -/
def bellPsi (s : ℝ) : TwoQubitState :=
  ⟨0, (Real.sqrt 2 / 2 : ℝ), (s * Real.sqrt 2 / 2 : ℝ), 0⟩

/-
Both choices of sign give normalized `Φ` Bell states.
-/
theorem bellPhi_normalized {s : ℝ} (hs : s ^ 2 = 1) :
    Normalized (bellPhi s) := by
  unfold Normalized bellPhi; norm_num [ Complex.normSq, hs ] ; ring; norm_num;
  norm_num [ normSquared, Complex.normSq ] ; ring ; norm_num [ hs ]

/-
Both choices of sign give normalized `Ψ` Bell states.
-/
theorem bellPsi_normalized {s : ℝ} (hs : s ^ 2 = 1) :
    Normalized (bellPsi s) := by
  unfold Normalized; unfold bellPsi; norm_num [ Complex.normSq, hs ] ;
  norm_num [ normSquared, Complex.normSq ] ; ring_nf ; norm_num [ hs ]

/-
Every `Φ` Bell state has maximal concurrence.
-/
theorem bellPhi_concurrence {s : ℝ} (hs : |s| = 1) :
    concurrence (bellPhi s) = 1 := by
  unfold concurrence; unfold bellPhi; norm_num [ Real.sqrt_div_self ] ; ring;
  unfold determinant; norm_num [ Complex.normSq, Complex.norm_def ] ; ring_nf ; norm_num [ hs ] ;

/-
Every `Ψ` Bell state has maximal concurrence.
-/
theorem bellPsi_concurrence {s : ℝ} (hs : |s| = 1) :
    concurrence (bellPsi s) = 1 := by
  convert bellPhi_concurrence hs using 1;
  unfold concurrence; unfold bellPsi bellPhi; norm_num [ Complex.normSq, Complex.norm_def ] ; ring;
  unfold determinant; norm_num [ Complex.normSq, Complex.norm_def ] ;

/-- A normalized witness whose concurrence is strictly between the integer
values zero and one. -/
def halfConcurrenceState : TwoQubitState :=
  ⟨(1 / 2 : ℝ), (Real.sqrt 2 / 2 : ℝ), 0, (1 / 2 : ℝ)⟩

/-
The obstruction witness is normalized.
-/
theorem halfConcurrenceState_normalized : Normalized halfConcurrenceState := by
  unfold Normalized; unfold halfConcurrenceState; norm_num;
  unfold normSquared; norm_num [ Complex.normSq ] ;

/-
The obstruction witness has concurrence exactly one half.
-/
theorem halfConcurrenceState_concurrence :
    concurrence halfConcurrenceState = 1 / 2 := by
  -- Calculate the determinant of the halfConcurrenceState.
  have h_det : determinant halfConcurrenceState = 1 / 4 := by
    norm_num [ determinant, halfConcurrenceState ];
  unfold concurrence; norm_num [ h_det ] ;

/-
No integer-valued invariant can agree with concurrence on every normalized
pure state.  In particular, an ordinary integer linking number cannot do so.
-/
theorem no_integer_valued_universal_linking
    (linking : TwoQubitState → ℤ) :
    ¬ ∀ ψ, Normalized ψ → concurrence ψ = |(linking ψ : ℝ)| := by
  by_contra h_contra
  have h_half : concurrence halfConcurrenceState = |(linking halfConcurrenceState : ℝ)| := by
    exact h_contra _ halfConcurrenceState_normalized
  have h_abs : |(linking halfConcurrenceState : ℝ)| = 1 / 2 := by
    exact h_half ▸ halfConcurrenceState_concurrence ▸ rfl
  norm_num at h_abs;
  rw [ eq_div_iff ] at h_abs <;> norm_cast at * ; cases abs_cases ( linking halfConcurrenceState ) <;> omega;

end ConcurrenceTopology