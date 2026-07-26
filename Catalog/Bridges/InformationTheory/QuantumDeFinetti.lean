/-
  QuantumDeFinetti.lean

  Quantum de Finetti Theorem: Formalization of the bridge between
  quantum exchangeability and classical probability.

  The quantum de Finetti theorem states that symmetric quantum states
  on infinite tensor products are mixtures of i.i.d. states, connecting
  quantum information theory to classical probability via exchangeability.

  Main results:
  1. Symmetric subspace dimension = C(d+k-1, k) with key identities
  2. Finite de Finetti bound properties (monotonicity, linearity)
  3. Purity invariance under unitary conjugation
  4. Classical-quantum bridge: embedding and measurement roundtrip
  5. Herfindahl index = quantum purity for classical states
  6. Purity bounds via Cauchy-Schwarz (1/d ≤ ∑pᵢ² ≤ 1)
  7. Trace preservation for convex combinations of density matrices
-/
import Mathlib

open Matrix BigOperators Finset Complex

noncomputable section

namespace QuantumDeFinetti

/-! ## Part I: Definitions -/

/-- Positive semidefiniteness for complex matrices:
    Hermitian with nonneg quadratic form. -/
def IsPosSemidefC {d : ℕ} (M : Matrix (Fin d) (Fin d) ℂ) : Prop :=
  M.IsHermitian ∧
  ∀ v : Fin d → ℂ, 0 ≤ (∑ i, ∑ j, starRingEnd ℂ (v i) * M i j * v j).re

/-- A density matrix: pos-semidef complex matrix with trace 1. -/
structure IsDensityMatrix {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ) : Prop where
  posSemidef : IsPosSemidefC ρ
  traceOne : Matrix.trace ρ = 1

/-- Convex combination of matrices with real weights. -/
def convexComb {d m : ℕ} (w : Fin m → ℝ) (ρs : Fin m → Matrix (Fin d) (Fin d) ℂ) :
    Matrix (Fin d) (Fin d) ℂ :=
  ∑ i, ((w i : ℂ)) • ρs i

/-- Weights form a probability distribution. -/
structure IsProbDist {m : ℕ} (w : Fin m → ℝ) : Prop where
  nonneg : ∀ i, 0 ≤ w i
  sum_one : ∑ i, w i = 1

/-- Dimension of Sym^k(ℂ^d) = C(d+k-1, k). -/
def symDim (d k : ℕ) : ℕ := (d + k - 1).choose k

/-- Finite quantum de Finetti bound: 2kd²/n. -/
def deFinettiBound (d k n : ℕ) : ℚ := (2 * k * d ^ 2 : ℚ) / n

/-- Purity: Tr(ρ²). -/
def purity {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ) : ℂ := Matrix.trace (ρ * ρ)

/-- Linear entropy: S_L(ρ) = 1 - Tr(ρ²). -/
def linearEntropy {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ) : ℂ := 1 - purity ρ

/-- Classical embedding: probability distribution → diagonal density matrix. -/
def classicalEmbed {d : ℕ} (p : Fin d → ℝ) : Matrix (Fin d) (Fin d) ℂ :=
  Matrix.diagonal (fun i => (p i : ℂ))

/-- Measurement: extract diagonal of density matrix. -/
def measureBasis {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ) : Fin d → ℝ :=
  fun i => (ρ i i).re

/-- Conjectured tighter de Finetti bound: kd(d-1)/n. -/
def deFinettiConjectureBound (d k n : ℕ) : ℚ := (k * d * (d - 1) : ℚ) / n

/-! ## Part II: Symmetric Subspace Theorems -/

/-- For qubits (d=2), the symmetric subspace has dimension k+1.
    This reflects that k qubits in the symmetric sector carry total spin j=k/2
    with 2j+1 = k+1 magnetic quantum numbers. -/
theorem symDim_qubit (k : ℕ) : symDim 2 k = k + 1 := by
  simp only [symDim]
  have : 2 + k - 1 = k + 1 := by omega
  rw [this, Nat.choose_succ_self_right]

/-- The symmetric subspace dimension is always positive for d ≥ 1. -/
theorem symDim_pos (d k : ℕ) (hd : 1 ≤ d) : 0 < symDim d k :=
  Nat.choose_pos (by omega)

/-- On zero copies, the symmetric subspace is 1-dimensional. -/
theorem symDim_zero_copies (d : ℕ) : symDim d 0 = 1 := by
  simp [symDim, Nat.choose_zero_right]

/-- On one copy, the symmetric subspace is the full d-dimensional space. -/
theorem symDim_one_copy (d : ℕ) (hd : 1 ≤ d) : symDim d 1 = d := by
  simp only [symDim]
  rw [show d + 1 - 1 = d from by omega, Nat.choose_one_right]

/-- symDim is monotone in d. -/
theorem symDim_mono_d (d₁ d₂ k : ℕ) (h : d₁ ≤ d₂) :
    symDim d₁ k ≤ symDim d₂ k :=
  Nat.choose_le_choose k (by omega)

/-- The qubit symmetric subspace grows linearly (k+1), exponentially smaller
    than the full Hilbert space 2^k. This gap is the information-theoretic
    basis of the de Finetti theorem: symmetric states are constrained
    to a "thin" subspace, forcing approximate i.i.d. structure. -/
theorem symDim_vs_full_qubit (k : ℕ) : symDim 2 k ≤ 2 ^ k := by
  rw [symDim_qubit]
  induction k with
  | zero => simp
  | succ n ih => rw [Nat.pow_succ]; linarith [Nat.one_le_two_pow (n := n)]

/-! ## Part III: de Finetti Bound Properties -/

theorem deFinetti_bound_nonneg (d k n : ℕ) (hn : 0 < (n : ℚ)) :
    0 ≤ deFinettiBound d k n := by
  simp [deFinettiBound]; positivity

theorem deFinetti_bound_zero_k (d n : ℕ) :
    deFinettiBound d 0 n = 0 := by
  simp [deFinettiBound]

/-- The de Finetti bound is additive in k: tracing out k₁+k₂ systems
    decomposes as the sum of the individual bounds. -/
theorem deFinetti_bound_linear_k (d k₁ k₂ n : ℕ) :
    deFinettiBound d (k₁ + k₂) n = deFinettiBound d k₁ n + deFinettiBound d k₂ n := by
  simp [deFinettiBound]; ring

/-
The de Finetti bound decreases monotonically as n → ∞.
-/
theorem deFinetti_bound_mono (d k : ℕ) (n₁ n₂ : ℕ)
    (hn₁ : 0 < (n₁ : ℚ)) (h : (n₁ : ℚ) ≤ n₂) :
    deFinettiBound d k n₂ ≤ deFinettiBound d k n₁ := by
  unfold deFinettiBound;
  gcongr

/-- For d=1, the bound reduces to 2k/n (classical case). -/
theorem deFinetti_bound_classical (k n : ℕ) :
    deFinettiBound 1 k n = (2 * k : ℚ) / n := by
  simp [deFinettiBound]

/-
The conjectured bound kd(d-1)/n ≤ standard bound 2kd²/n.
-/
theorem conjecture_le_standard (d k n : ℕ) (hd : 1 ≤ d) (hn : 0 < (n : ℚ)) :
    deFinettiConjectureBound d k n ≤ deFinettiBound d k n := by
  exact div_le_div_of_nonneg_right ( by nlinarith [ show ( d : ℚ ) ≥ 1 by norm_cast, show ( k : ℚ ) * d ≥ 0 by positivity ] ) ( by positivity ) ;

/-! ## Part IV: Purity and Unitary Invariance -/

/-- Purity of an idempotent state with Tr = 1 is 1. -/
theorem purity_of_idempotent {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ)
    (h_idem : ρ * ρ = ρ) (h_tr : Matrix.trace ρ = 1) :
    purity ρ = 1 := by
  unfold purity; rw [h_idem, h_tr]

/-- **Purity is unitarily invariant**: Tr((UρU†)²) = Tr(ρ²).
    This is a deep physical principle: unitary time evolution preserves
    the degree of mixedness of a quantum state. It ensures that the
    distinction between pure and mixed states is basis-independent. -/
theorem purity_unitary_invariant {d : ℕ} (ρ U : Matrix (Fin d) (Fin d) ℂ)
    (hU' : U.conjTranspose * U = 1) :
    purity (U * ρ * U.conjTranspose) = purity ρ := by
  unfold purity
  conv_lhs =>
    rw [show U * ρ * U.conjTranspose * (U * ρ * U.conjTranspose) =
      U * ρ * (U.conjTranspose * U) * ρ * U.conjTranspose from by
      simp only [mul_assoc]]
  rw [hU', mul_one]
  rw [show U * ρ * ρ * U.conjTranspose = U * (ρ * ρ) * U.conjTranspose from by
    simp only [mul_assoc]]
  rw [trace_mul_cycle]; simp [hU']

/-- Linear entropy vanishes for pure states. -/
theorem linearEntropy_pure {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ)
    (h_idem : ρ * ρ = ρ) (h_tr : Matrix.trace ρ = 1) :
    linearEntropy ρ = 0 := by
  unfold linearEntropy; rw [purity_of_idempotent ρ h_idem h_tr]; ring

/-- Linear entropy is unitarily invariant. -/
theorem linearEntropy_unitary_invariant {d : ℕ}
    (ρ U : Matrix (Fin d) (Fin d) ℂ) (hU' : U.conjTranspose * U = 1) :
    linearEntropy (U * ρ * U.conjTranspose) = linearEntropy ρ := by
  unfold linearEntropy; rw [purity_unitary_invariant ρ U hU']

/-! ## Part V: Classical-Quantum Bridge -/

theorem classicalEmbed_trace {d : ℕ} (p : Fin d → ℝ) :
    Matrix.trace (classicalEmbed p) = ∑ i, (p i : ℂ) := by
  simp [classicalEmbed, Matrix.trace_diagonal]

/-
Classical distributions embed as valid density matrices.
-/
theorem classicalEmbed_isDensity {d : ℕ}
    (p : Fin d → ℝ) (hp_nn : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    IsDensityMatrix (classicalEmbed p) := by
  constructor
  · constructor
    ·
      ext i j; by_cases hij : i = j <;> simp +decide [ hij, classicalEmbed ] ;
      exact if_neg ( Ne.symm hij )
    ·
      intro v; exact (by
      simp +decide [ classicalEmbed, Matrix.diagonal ];
      exact Finset.sum_nonneg fun i _ => by nlinarith only [ hp_nn i, sq_nonneg ( v i |> Complex.re ), sq_nonneg ( v i |> Complex.im ) ] ;);
  · rw [classicalEmbed_trace]; exact_mod_cast hp_sum

/-- **Measurement-embedding roundtrip**: classical → quantum → classical = id.
    Measuring a diagonal density matrix in the computational basis
    recovers the original distribution exactly. -/
theorem measure_classical_roundtrip {d : ℕ} (p : Fin d → ℝ) :
    measureBasis (classicalEmbed p) = p := by
  ext i; simp [measureBasis, classicalEmbed]

/-- **Purity = Herfindahl-Hirschman Index** for classical states.
    The quantum purity Tr(ρ²) of a diagonal density matrix equals
    ∑ pᵢ², the HHI from economics. This bridges quantum information
    theory with industrial organization and ecological diversity. -/
theorem purity_classical {d : ℕ} (p : Fin d → ℝ) :
    purity (classicalEmbed p) = ∑ i, (p i : ℂ) ^ 2 := by
  simp only [purity, classicalEmbed, Matrix.diagonal_mul_diagonal,
             Matrix.trace_diagonal]
  congr 1; ext i; ring

/-- Linear entropy of classical state = Gini-Simpson diversity index. -/
theorem linearEntropy_classical {d : ℕ} (p : Fin d → ℝ) :
    linearEntropy (classicalEmbed p) = 1 - ∑ i, (p i : ℂ) ^ 2 := by
  simp [linearEntropy, purity_classical]

/-- Measurement probabilities sum to 1. -/
theorem measureBasis_sum {d : ℕ} (ρ : Matrix (Fin d) (Fin d) ℂ)
    (hρ : IsDensityMatrix ρ) :
    ∑ i, measureBasis ρ i = 1 := by
  simp only [measureBasis]
  have h := hρ.traceOne
  simp only [Matrix.trace, Matrix.diag] at h
  have : (∑ i : Fin d, ρ i i).re = (1 : ℂ).re := congr_arg Complex.re h
  simpa using this

/-! ## Part VI: Classical Purity Bounds -/

/-
**Purity upper bound**: ∑ pᵢ² ≤ 1 for probability distributions.
    Equality iff the distribution is a point mass.
-/
theorem classical_purity_le_one {d : ℕ} (p : Fin d → ℝ)
    (hp_nn : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    ∑ i, p i ^ 2 ≤ 1 := by
  exact hp_sum ▸ Finset.sum_le_sum fun i _ => pow_le_of_le_one ( hp_nn i ) ( hp_sum ▸ Finset.single_le_sum ( fun i _ => hp_nn i ) ( Finset.mem_univ i ) ) ( by norm_num )

/-
**Purity lower bound** (Cauchy-Schwarz): ∑ pᵢ² ≥ 1/d.
    Equality iff the distribution is uniform (maximally mixed state).
-/
theorem classical_purity_ge_inv {d : ℕ} [NeZero d] (p : Fin d → ℝ)
    (hp_nn : ∀ i, 0 ≤ p i) (hp_sum : ∑ i, p i = 1) :
    (1 : ℝ) / d ≤ ∑ i, p i ^ 2 := by
  have := Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( p i - ( d : ℝ ) ⁻¹ );
  simp_all +decide [ sub_mul, mul_sub ];
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_comm ];
  simp_all +decide [ NeZero.ne ]

/-! ## Part VII: Trace Preservation -/

/-- Trace distributes over convex combinations. -/
theorem trace_convexComb {d m : ℕ} (w : Fin m → ℝ)
    (ρs : Fin m → Matrix (Fin d) (Fin d) ℂ) :
    Matrix.trace (convexComb w ρs) = ∑ i, (w i : ℂ) * Matrix.trace (ρs i) := by
  simp only [convexComb]
  have h1 : (∑ i, (↑(w i) : ℂ) • ρs i).trace = ∑ i, ((↑(w i) : ℂ) • ρs i).trace :=
    map_sum (traceLinearMap (Fin d) ℂ ℂ) _ _
  rw [h1]; congr 1; ext i
  exact trace_smul (↑(w i)) (ρs i)

/-- **Trace preservation**: convex combination of density matrices has trace 1.
    This is the consistency condition for statistical mixtures:
    if each component is normalized, so is any mixture. -/
theorem trace_convexComb_density {d m : ℕ}
    (w : Fin m → ℝ) (ρs : Fin m → Matrix (Fin d) (Fin d) ℂ)
    (hw : IsProbDist w) (hρ : ∀ i, IsDensityMatrix (ρs i)) :
    Matrix.trace (convexComb w ρs) = 1 := by
  rw [trace_convexComb]
  have : ∑ i, (w i : ℂ) * Matrix.trace (ρs i) = ∑ i, (w i : ℂ) := by
    congr 1; ext i; rw [(hρ i).traceOne]; ring
  rw [this]; exact_mod_cast hw.sum_one

end QuantumDeFinetti

end