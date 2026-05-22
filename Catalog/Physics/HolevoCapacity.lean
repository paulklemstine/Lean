import Mathlib
import Physics.QuantumInfo.VonNeumannEntropy

/-!
# Holevo Capacity for Finite Quantum Channels

Bridge: Quantum Information Theory ↔ Post-Quantum Cryptographic Security ↔ Classical Communication

This module defines quantum ensembles, quantum channels, and the Holevo quantity χ,
then proves the fundamental capacity upper bound χ ≤ log(dim).

## Algorithmic Complexity
Holevo bound verification for diagonal ensembles: O(|ι| * n).
-/

open Complex Matrix BigOperators Real Finset

noncomputable section

namespace Physics.QuantumInfo

-- ============================================================
-- §1. Quantum Ensembles
-- ============================================================

/-- A quantum ensemble: finite collection of quantum states with probabilities.
Bridge: fundamental data structure for quantum communication and QKD. -/
structure QuantumEnsemble (ι : Type*) (n : ℕ) [Fintype ι] where
  prob : ι → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum_one : (∑ i, prob i) = 1
  state : ι → DensityMatrix n
  state_isDensity : ∀ i, IsDensityMatrix (state i)

/-- Average state ρ_avg = ∑ p_i ρ_i. -/
def averageState {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : DensityMatrix n :=
  ∑ i, (E.prob i : ℂ) • E.state i

-- ============================================================
-- §2. Quantum Channels
-- ============================================================

/-- A quantum channel preserving Hermitianity, PSD, and trace.
Note: isCPTP is True — complete positivity is not encoded.
All theorems only use the structure fields. -/
structure QuantumChannel (n m : ℕ) where
  toLinear : DensityMatrix n → DensityMatrix m
  preservesHermitian : ∀ ρ, IsHermitianDM ρ → IsHermitianDM (toLinear ρ)
  preservesTraceOne : ∀ ρ, traceOne ρ → traceOne (toLinear ρ)
  preservesPSD : ∀ ρ, positiveSemidefinite ρ → positiveSemidefinite (toLinear ρ)

def QuantumChannel.isCPTP {n m : ℕ} (_Φ : QuantumChannel n m) : Prop := True

-- ============================================================
-- §3. Holevo Quantity and Capacity
-- ============================================================

/-- Holevo quantity χ = S(ρ_avg) - ∑ p_i S(ρ_i).
Bridge: bounds accessible classical information. -/
def holevoQuantity {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : ℝ :=
  vonNeumannEntropy n (averageState E) -
  ∑ i, E.prob i * vonNeumannEntropy n (E.state i)

/-- Output ensemble after channel. -/
def outputEnsemble {ι : Type*} [Fintype ι] {n m : ℕ}
    (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) : QuantumEnsemble ι m where
  prob := E.prob
  prob_nonneg := E.prob_nonneg
  prob_sum_one := E.prob_sum_one
  state := fun i => Φ.toLinear (E.state i)
  state_isDensity := fun i => by
    obtain ⟨hH, hP, hT⟩ := E.state_isDensity i
    exact ⟨Φ.preservesHermitian _ hH, Φ.preservesPSD _ hP, Φ.preservesTraceOne _ hT⟩

/-- Holevo quantity after channel. -/
def holevoQuantityAfterChannel {ι : Type*} [Fintype ι] {n m : ℕ}
    (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) : ℝ :=
  holevoQuantity (outputEnsemble Φ E)

/-- Holevo capacity upper bound. -/
def holevoCapacityUpper (m : ℕ) : ℝ := Real.log m

/-- Commuting ensemble: all states commute. -/
def commutingEnsemble {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : Prop :=
  ∀ i j, E.state i * E.state j = E.state j * E.state i

/-- Channel entropy gain. -/
def channelEntropyGain (n m : ℕ) (Φ : QuantumChannel n m) (ρ : DensityMatrix n) : ℝ :=
  vonNeumannEntropy m (Φ.toLinear ρ) - vonNeumannEntropy n ρ

/-- Post-quantum key leakage proxy = Holevo quantity. -/
def postQuantumKeyLeakageProxy {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : ℝ := holevoQuantity E

/-- Certified capacity gap. -/
def certifiedCapacityGap {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : ℝ := Real.log n - holevoQuantity E

/-- Holevo evaluation cost: O(|ι| * n). -/
def holevoEvaluationCost (ι_card n : ℕ) : ℕ := ι_card * n

/-
============================================================
§4. Average State Lemmas
============================================================

Average state is Hermitian.
-/
theorem averageState_isHermitian {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : IsHermitianDM (averageState E) := by
      unfold IsHermitianDM;
      unfold averageState; simp +decide [ Matrix.IsHermitian, Matrix.transpose_sum, Matrix.transpose_smul ] ;
      norm_num [ Matrix.IsHermitian, Matrix.conjTranspose_sum, Matrix.conjTranspose_smul ] at *;
      exact Finset.sum_congr rfl fun i _ => congr_arg _ ( E.state_isDensity i |>.1 )

/-
Average state has trace one.
-/
theorem averageState_traceOne {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : traceOne (averageState E) := by
      unfold traceOne;
      unfold averageState; simp +decide [ Matrix.trace_sum, Matrix.trace_smul ] ;
      have h_trace : ∀ i, trace (E.state i) = 1 := by
        exact fun i => E.state_isDensity i |>.2.2;
      simp +decide [ h_trace, E.prob_sum_one ];
      exact_mod_cast E.prob_sum_one

/-
Average state is PSD.
-/
theorem averageState_positiveSemidefinite {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : positiveSemidefinite (averageState E) := by
      -- We will show the average state is positive semidefinite by using the provided `positiveSemidefinite_add` lemma,
      -- which states that the sum of two positive semidefinite matrices is positive semidefinite.
      have h_above_sum (s : Finset ι) : positiveSemidefinite (∑ i ∈ s, ((E.prob i) : ℂ) • E.state i) := by
        -- By definition of positive semidefinite, we need to show that for any vector $v$, $v^* (\sum_{i \in s} (E.prob i : ℂ) • E.state i) v \geq 0$.
        unfold positiveSemidefinite;
        intro v
        -- By linearity of the inner product and the fact that each $E.state i$ is positive semidefinite, we have:
        have h_inner_product : (star v ⬝ᵥ (∑ i ∈ s, ((E.prob i) : ℂ) • E.state i) *ᵥ v) = ∑ i ∈ s, (E.prob i : ℝ) * (star v ⬝ᵥ (E.state i) *ᵥ v) := by
          simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _ ];
          simp +decide only [starRingEnd_apply, Finset.sum_apply, Matrix.sum_apply, Finset.smul_sum,
                    Matrix.smul_apply, Finset.sum_mul, smul_eq_mul, Finset.mul_sum _ _ _];
          exact Eq.symm ( by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ) );
        simp_all +decide [ Complex.ext_iff ];
        exact Finset.sum_nonneg fun i _ => mul_nonneg ( E.prob_nonneg i ) ( E.state_isDensity i |>.2.1 v );
      exact h_above_sum Finset.univ

/-- Average state is a density matrix. -/
theorem averageState_isDensityMatrix {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : IsDensityMatrix (averageState E) :=
  ⟨averageState_isHermitian E, averageState_positiveSemidefinite E, averageState_traceOne E⟩

/-
============================================================
§5. Holevo Quantity Bounds
============================================================

Holevo quantity ≤ log(dim). Bridge: holevo_post_quantum_key_capacity_ceiling.
Proof: S(ρ_avg) ≤ log n, and ∑ p_i S(ρ_i) ≥ 0, so χ ≤ log n.
-/
theorem holevoQuantity_le_log_dim {ι : Type*} [Fintype ι]
    {n : ℕ} (hn : 0 < n) (E : QuantumEnsemble ι n) :
    holevoQuantity E ≤ Real.log n := by
      refine' le_trans ( sub_le_self _ _ ) _;
      · refine' Finset.sum_nonneg fun i _ => mul_nonneg ( E.prob_nonneg i ) _;
        convert shannonEntropyFin_nonneg ( E.state i |> fun ρ => fun j => Complex.re ( ρ j j ) ) ?_ ?_ using 1;
        · have := E.state_isDensity i;
          exact fun j => this.2.1 ( Pi.single j 1 ) |> fun h => by simpa using h;
        · convert congr_arg Complex.re ( E.state_isDensity i |>.2.2 ) using 1;
          simp +decide [ Matrix.trace ];
      · convert shannonEntropyFin_le_log_card _ _ _ using 1;
        · intro i;
          have := averageState_isDensityMatrix E;
          exact this.2.1 ( Pi.single i 1 ) |> fun h => by simpa [ mul_comm ] using h;
        · have := averageState_isDensityMatrix E;
          obtain ⟨ h₁, h₂, h₃ ⟩ := this;
          convert congr_arg Complex.re h₃ using 1;
          unfold spectralProbabilities; simp +decide [ Matrix.trace ] ;

/-- Channelized Holevo bound. -/
theorem holevoQuantityAfterChannel_le_output_log_dim
    {ι : Type*} [Fintype ι]
    {n m : ℕ} (hm : 0 < m) (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) :
    holevoQuantityAfterChannel Φ E ≤ Real.log m :=
  holevoQuantity_le_log_dim hm (outputEnsemble Φ E)

/-- Certified capacity gap is nonneg. -/
theorem certifiedCapacityGap_nonneg {ι : Type*} [Fintype ι]
    {n : ℕ} (hn : 0 < n) (E : QuantumEnsemble ι n) :
    0 ≤ certifiedCapacityGap E := by
  unfold certifiedCapacityGap; linarith [holevoQuantity_le_log_dim hn E]

-- ============================================================
-- §6. Output Ensemble and Bridge Lemmas
-- ============================================================

theorem outputEnsemble_prob_invariant {ι : Type*} [Fintype ι]
    {n m : ℕ} (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) (i : ι) :
    (outputEnsemble Φ E).prob i = E.prob i := rfl

/-- Bridge: holevo_crypto_leakage_bridge. -/
theorem holevo_crypto_leakage_bridge {ι : Type*} [Fintype ι]
    {n : ℕ} (E : QuantumEnsemble ι n) :
    postQuantumKeyLeakageProxy E = holevoQuantity E := rfl

theorem postQuantumKeyLeakageProxy_le_log_dim {ι : Type*} [Fintype ι]
    {n : ℕ} (hn : 0 < n) (E : QuantumEnsemble ι n) :
    postQuantumKeyLeakageProxy E ≤ Real.log n :=
  holevoQuantity_le_log_dim hn E

theorem channelEntropyGain_upper_by_log_dim {n m : ℕ} (hm : 0 < m)
    (Φ : QuantumChannel n m) (ρ : DensityMatrix n) (hρ : IsDensityMatrix ρ) :
    channelEntropyGain n m Φ ρ ≤ Real.log m := by
      refine' sub_le_iff_le_add'.mpr _;
      refine' le_trans _ ( le_add_of_nonneg_left _ );
      · convert shannonEntropyFin_le_log_card _ _ _ using 1;
        · intro i
          have := Φ.preservesPSD ρ hρ.right.left
          have := this (Pi.single i 1)
          simp_all +decide [ Matrix.mulVec, dotProduct ];
          simp_all +decide [ Finset.sum_eq_single i, Pi.single_apply ];
          exact this;
        · have := Φ.preservesTraceOne ρ hρ.2.2;
          convert congr_arg Complex.re this using 1;
          unfold spectralProbabilities; simp +decide [ Matrix.trace ] ;
      · -- Apply the lemma that states the von Neumann entropy of a density matrix is non-negative.
        apply shannonEntropyFin_nonneg;
        · intro i
          have := hρ.2.1 (Pi.single i 1)
          simp at this;
          exact this;
        · have := hρ.2.2;
          convert congr_arg Complex.re this using 1;
          unfold spectralProbabilities; simp +decide [ Matrix.trace ] ;

-- ============================================================
-- §7. Identity Channel and Singletons
-- ============================================================

/-- Identity channel. -/
def identityChannel (n : ℕ) : QuantumChannel n n where
  toLinear := id
  preservesHermitian := fun _ h => h
  preservesTraceOne := fun _ h => h
  preservesPSD := fun _ h => h

/-- Identity channel preserves Holevo quantity. -/
theorem identityChannel_holevo {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) :
    holevoQuantityAfterChannel (identityChannel n) E = holevoQuantity E := by
  unfold holevoQuantityAfterChannel outputEnsemble holevoQuantity identityChannel; simp

-- ============================================================
-- §8. Spectral Data Theorems
-- ============================================================

theorem finiteSpectralData_isDensityMatrix {n : ℕ} (s : FiniteSpectralData n) :
    IsDensityMatrix (diagonalDensity n s.eig) :=
  diagonalDensity_isDensityMatrix s.eig s.eig_nonneg s.eig_sum_one

theorem vonNeumannEntropyOfSpectralData_eq_shannon {n : ℕ} (s : FiniteSpectralData n) :
    vonNeumannEntropyOfSpectralData s = shannonEntropyFin n s.eig := rfl

theorem vonNeumannEntropyOfSpectralData_nonneg {n : ℕ} (s : FiniteSpectralData n) :
    0 ≤ vonNeumannEntropyOfSpectralData s :=
  shannonEntropyFin_nonneg s.eig s.eig_nonneg s.eig_sum_one

theorem vonNeumannEntropyOfSpectralData_le_log {n : ℕ} (s : FiniteSpectralData n) :
    vonNeumannEntropyOfSpectralData s ≤ Real.log n :=
  shannonEntropyFin_le_log_card s.eig s.eig_nonneg s.eig_sum_one

/-- Uniform spectral data (maximally mixed eigenvalues). -/
def uniformSpectralData (n : ℕ) (hn : 0 < n) : FiniteSpectralData n where
  eig := fun _ => (n : ℝ)⁻¹
  eig_nonneg := fun _ => inv_nonneg.mpr (Nat.cast_nonneg n)
  eig_sum_one := by
    simp [sum_const, nsmul_eq_mul]
    exact mul_inv_cancel₀ (by exact_mod_cast hn.ne' : (n : ℝ) ≠ 0)

/-- Point mass spectral data (pure state eigenvalues). -/
def pointMassSpectralData (n : ℕ) (_hn : 0 < n) (k : Fin n) :
    FiniteSpectralData n where
  eig := fun i => if i = k then 1 else 0
  eig_nonneg := fun i => by split <;> norm_num
  eig_sum_one := by simp [sum_ite_eq', mem_univ]

/-
Uniform spectral data has entropy log n.
-/
theorem uniformSpectralData_entropy {n : ℕ} (hn : 0 < n) :
    vonNeumannEntropyOfSpectralData (uniformSpectralData n hn) = Real.log n := by
      convert vonNeumannEntropy_maximallyMixed hn using 1;
      unfold vonNeumannEntropyOfSpectralData vonNeumannEntropy;
      unfold spectralProbabilities maximallyMixed uniformSpectralData; norm_num [ hn.ne' ] ;

/-- Point mass spectral data has entropy 0. -/
theorem pointMassSpectralData_entropy {n : ℕ} (hn : 0 < n) (k : Fin n) :
    vonNeumannEntropyOfSpectralData (pointMassSpectralData n hn k) = 0 :=
  shannonEntropyFin_eq_zero_of_pointmass k _ (fun i => by simp [pointMassSpectralData])

-- ============================================================
-- §9. Certified Robustness Bridge Theorems
-- ============================================================

/-- Bridge: quantum_certified_robustness_entropy_margin. -/
theorem quantum_certified_robustness_entropy_margin {n : ℕ} (hn : 1 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ certifiedSpectralMargin n (diagonalDensity n p) ∧
    certifiedSpectralMargin n (diagonalDensity n p) ≤ 1 :=
  entropyCompressionRatio_mem_unitInterval_diagonal hn p hp_nonneg hp_sum

/-- Bridge: holevo_post_quantum_key_capacity_ceiling. -/
theorem holevo_post_quantum_key_capacity_ceiling {ι : Type*} [Fintype ι]
    {n : ℕ} (hn : 0 < n) (E : QuantumEnsemble ι n) :
    postQuantumKeyLeakageProxy E ≤ holevoCapacityUpper n :=
  holevoQuantity_le_log_dim hn E

theorem holevoEvaluationCost_eq (ι_card n : ℕ) :
    holevoEvaluationCost ι_card n = ι_card * n := rfl

end Physics.QuantumInfo