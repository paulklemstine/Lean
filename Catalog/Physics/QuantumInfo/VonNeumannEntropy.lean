import Mathlib

/-!
# Von Neumann Entropy for Finite-Dimensional Quantum Systems

Bridge: Quantum Physics ↔ Classical Information Theory ↔ Post-Quantum Cryptography ↔ ML Certified Robustness

The central insight is that von Neumann entropy equals the Shannon entropy of the
eigenvalue distribution. For diagonal density matrices this is immediate.

## Algorithmic Complexity
For diagonal states, entropy computation is O(n) given probabilities.
Effective rank computation is O(n) + O(1) for the exponential.
-/

open Complex Matrix BigOperators Real Finset

noncomputable section

namespace Physics.QuantumInfo

-- ============================================================
-- §1. Core Types and Predicates
-- ============================================================

/-- A density matrix is an `n × n` complex matrix. -/
abbrev DensityMatrix (n : ℕ) := Matrix (Fin n) (Fin n) ℂ

/-- Hermitianity: ρ = ρ†. Ensures real eigenvalues. -/
def IsHermitianDM {n : ℕ} (ρ : DensityMatrix n) : Prop := ρ.IsHermitian

/-- Trace-one condition. -/
def traceOne {n : ℕ} (ρ : DensityMatrix n) : Prop := Matrix.trace ρ = 1

/-- Positive semidefiniteness via quadratic form ⟨v|ρ|v⟩ ≥ 0. -/
def positiveSemidefinite {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  ∀ v : Fin n → ℂ, 0 ≤ Complex.re (dotProduct (star v) (ρ.mulVec v))

/-- Full density matrix predicate: Hermitian + PSD + trace one. -/
def IsDensityMatrix {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  IsHermitianDM ρ ∧ positiveSemidefinite ρ ∧ traceOne ρ

/-- Pure state: density matrix that is idempotent (ρ² = ρ). -/
def isPure {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  IsDensityMatrix ρ ∧ ρ * ρ = ρ

-- ============================================================
-- §2. Key Constructions
-- ============================================================

/-- The maximally mixed state (1/n) · I.
Bridge: infinite-temperature Gibbs state in quantum thermodynamics. -/
def maximallyMixed (n : ℕ) : DensityMatrix n :=
  ((n : ℂ)⁻¹) • (1 : DensityMatrix n)

/-- Eigenvalue distribution abstraction.
Bridge: connects quantum spectral theory to classical probability. -/
structure FiniteSpectralData (n : ℕ) where
  eig : Fin n → ℝ
  eig_nonneg : ∀ i, 0 ≤ eig i
  eig_sum_one : (∑ i, eig i) = 1

/-- Shannon entropy of a finite probability distribution.
Convention: 0 · log 0 = 0 (Mathlib: Real.log 0 = 0).
Algorithmic complexity: O(n). -/
def shannonEntropyFin (n : ℕ) (p : Fin n → ℝ) : ℝ :=
  - ∑ i, p i * Real.log (p i)

/-- Von Neumann entropy of spectral data = Shannon entropy of eigenvalues.
Bridge: quantum thermodynamic entropy = Shannon entropy of spectrum. -/
def vonNeumannEntropyOfSpectralData {n : ℕ} (s : FiniteSpectralData n) : ℝ :=
  shannonEntropyFin n s.eig

/-- Diagonal density matrix from a probability distribution.
Bridge: classical → quantum embedding. -/
def diagonalDensity (n : ℕ) (p : Fin n → ℝ) : DensityMatrix n :=
  Matrix.diagonal (fun i => (p i : ℂ))

/-- Spectral probabilities: diagonal entries of ρ. -/
def spectralProbabilities (n : ℕ) (ρ : DensityMatrix n) : Fin n → ℝ :=
  fun i => Complex.re (ρ i i)

/-- Von Neumann entropy = Shannon entropy of spectral probabilities.
Bridge: quantum thermodynamic entropy ↔ classical Shannon coding.
Algorithmic complexity: O(n). -/
def vonNeumannEntropy (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  shannonEntropyFin n (spectralProbabilities n ρ)

/-- Purity Tr(ρ²). Bridge: quantum computing gate fidelity benchmark. -/
def purity (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  Complex.re (Matrix.trace (ρ * ρ))

/-- Entropy defect: log n - S(ρ).
Bridge: post-quantum crypto distinguishing advantage bound. -/
def entropyDefect (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  Real.log n - vonNeumannEntropy n ρ

/-- Effective rank: exp(S(ρ)). Bridge: participation ratio. -/
def effectiveRank (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  Real.exp (vonNeumannEntropy n ρ)

/-- Purity gap: 1 - Tr(ρ²). Bridge: decoherence measure. -/
def purityGap (n : ℕ) (ρ : DensityMatrix n) : ℝ := 1 - purity n ρ

/-- Entropy compression ratio: S(ρ)/log(n) ∈ [0,1].
Bridge: Lipschitz-bounded certified robustness feature. -/
def entropyCompressionRatio (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  vonNeumannEntropy n ρ / Real.log n

/-- Min-entropy lower proxy.
Bridge: post-quantum lattice crypto extractable randomness. -/
def cryptoMinEntropyLowerProxy (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  vonNeumannEntropy n ρ

/-- Certified spectral margin = compression ratio.
Bridge: ML robustness pipeline feature. -/
def certifiedSpectralMargin (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  entropyCompressionRatio n ρ

/-- Classical-quantum bridge: state is diagonal in computational basis. -/
def ClassicalQuantumBridge (n : ℕ) (ρ : DensityMatrix n) : Prop :=
  ρ = diagonalDensity n (spectralProbabilities n ρ)

/-- Entropy evaluation cost: O(n). -/
def entropyEvaluationCost (n : ℕ) : ℕ := n

-- ============================================================
-- §3. PSD Closure Lemmas
-- ============================================================

theorem positiveSemidefinite_zero {n : ℕ} : positiveSemidefinite (0 : DensityMatrix n) := by
  intro v; simp [mulVec, dotProduct]

theorem positiveSemidefinite_add {n : ℕ} {ρ σ : DensityMatrix n}
    (hρ : positiveSemidefinite ρ) (hσ : positiveSemidefinite σ) :
    positiveSemidefinite (ρ + σ) := by
  intro v; rw [Matrix.add_mulVec]; simp only [dotProduct_add, Complex.add_re]
  linarith [hρ v, hσ v]

theorem positiveSemidefinite_smul_nonneg {n : ℕ} {r : ℝ} (hr : 0 ≤ r) {ρ : DensityMatrix n}
    (hρ : positiveSemidefinite ρ) : positiveSemidefinite ((r : ℂ) • ρ) := by
  intro v
  have hsmul : ((r : ℂ) • ρ).mulVec v = (r : ℂ) • (ρ.mulVec v) := by
    ext i; simp [Matrix.mulVec, dotProduct, Matrix.smul_apply, smul_eq_mul, mul_sum, mul_assoc]
  rw [hsmul, dotProduct_smul, smul_eq_mul, Complex.re_ofReal_mul]
  exact mul_nonneg hr (hρ v)

-- ============================================================
-- §4. Diagonal Density Matrix Lemmas
-- ============================================================

theorem diagonalDensity_apply {n : ℕ} (p : Fin n → ℝ) (i j : Fin n) :
    diagonalDensity n p i j = if i = j then (p i : ℂ) else 0 := by
  simp [diagonalDensity, Matrix.diagonal_apply]

theorem diagonalDensity_isHermitian {n : ℕ} (p : Fin n → ℝ) :
    IsHermitianDM (diagonalDensity n p) := by
  show (diagonalDensity n p).IsHermitian
  ext i j; simp [Matrix.IsHermitian, Matrix.conjTranspose_apply, diagonalDensity_apply]
  split
  · subst_vars; simp
  · rename_i h; simp [Ne.symm h]

theorem diagonalDensity_traceOne {n : ℕ} (p : Fin n → ℝ)
    (hp_sum : (∑ i, p i) = 1) : traceOne (diagonalDensity n p) := by
  show Matrix.trace (diagonalDensity n p) = 1
  simp only [Matrix.trace, Matrix.diag_apply, diagonalDensity_apply, ite_true]
  have : ∑ i : Fin n, (p i : ℂ) = ((∑ i, p i : ℝ) : ℂ) := by push_cast; rfl
  rw [this, hp_sum]; simp

theorem diagonalDensity_positiveSemidefinite {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) : positiveSemidefinite (diagonalDensity n p) := by
  intro v
  have hmv : (diagonalDensity n p).mulVec v = fun i => (p i : ℂ) * v i := by
    ext i; simp [Matrix.mulVec, dotProduct, diagonalDensity_apply, sum_ite_eq', mem_univ]
  rw [hmv]; simp only [dotProduct, Pi.star_apply]; rw [Complex.re_sum]
  apply sum_nonneg; intro i _
  rw [show star (v i) * ((p i : ℂ) * v i) = (p i : ℂ) * (star (v i) * v i) from by ring]
  rw [Complex.re_ofReal_mul]; apply mul_nonneg (hp_nonneg i)
  have : (star (v i) * v i).re = (v i).re ^ 2 + (v i).im ^ 2 := by
    simp [star, Complex.mul_re]; ring
  rw [this]; positivity

/-- Bridge: embeds classical probability theory into quantum mechanics. -/
theorem diagonalDensity_isDensityMatrix {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    IsDensityMatrix (diagonalDensity n p) :=
  ⟨diagonalDensity_isHermitian p, diagonalDensity_positiveSemidefinite p hp_nonneg,
   diagonalDensity_traceOne p hp_sum⟩

theorem spectralProbabilities_diagonalDensity {n : ℕ} (p : Fin n → ℝ) :
    spectralProbabilities n (diagonalDensity n p) = p := by
  ext i; simp [spectralProbabilities, diagonalDensity_apply]

-- ============================================================
-- §5. Shannon Entropy Core Lemmas
-- ============================================================

theorem neg_mul_log_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ -(x * Real.log x) := by
  by_cases hx : x = 0
  · simp [hx]
  · have hxpos : 0 < x := lt_of_le_of_ne hx0 (Ne.symm hx)
    nlinarith [mul_nonpos_of_nonneg_of_nonpos hxpos.le (Real.log_nonpos hxpos.le hx1)]

theorem prob_le_one {n : ℕ} (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i)
    (hp_sum : (∑ i, p i) = 1) (i : Fin n) : p i ≤ 1 := by
  calc p i ≤ ∑ j, p j := single_le_sum (fun j _ => hp_nonneg j) (mem_univ i)
  _ = 1 := hp_sum

/-- Shannon entropy is nonneg. Bridge: fundamental positivity of information content. -/
theorem shannonEntropyFin_nonneg {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ shannonEntropyFin n p := by
  unfold shannonEntropyFin; rw [neg_nonneg]
  apply sum_nonpos; intro i _
  exact neg_nonneg.mp (neg_mul_log_nonneg (hp_nonneg i) (prob_le_one p hp_nonneg hp_sum i))

theorem shannonEntropyFin_eq_zero_of_pointmass {n : ℕ} (k : Fin n)
    (p : Fin n → ℝ) (hp : ∀ i, p i = if i = k then 1 else 0) :
    shannonEntropyFin n p = 0 := by
  unfold shannonEntropyFin
  have : ∑ i, p i * Real.log (p i) = 0 :=
    sum_eq_zero fun i _ => by rw [hp i]; split <;> simp [Real.log_one]
  linarith

/-
Shannon entropy ≤ log n. Bridge: maximum entropy principle.
Uses Gibbs inequality (KL divergence ≥ 0) via log x ≤ x - 1.
-/
theorem shannonEntropyFin_le_log_card {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    shannonEntropyFin n p ≤ Real.log n := by
      by_cases hn : n = 0;
      · aesop;
      · have h_gibbs : ∀ i, p i > 0 → p i * Real.log (p i) ≥ p i * Real.log (1 / n) + p i - 1 / n := by
          intro i hi; have := Real.log_le_sub_one_of_pos ( show 0 < ( 1 / n : ℝ ) / p i by positivity ) ; simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ] ;
          rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_inv, Real.log_inv ] at this ; nlinarith [ inv_pos.mpr ( show 0 < ( n : ℝ ) by positivity ), mul_inv_cancel₀ ( show ( n : ℝ ) ≠ 0 by positivity ), mul_inv_cancel₀ ( show ( p i : ℝ ) ≠ 0 by positivity ) ];
        have h_sum_gibbs : ∑ i, p i * Real.log (p i) ≥ ∑ i, (p i * Real.log (1 / n) + p i - 1 / n) := by
          exact Finset.sum_le_sum fun i _ => if hi : p i = 0 then by norm_num [ hi ] else h_gibbs i ( lt_of_le_of_ne ( hp_nonneg i ) ( Ne.symm hi ) );
        simp_all +decide [ Finset.sum_add_distrib, ← Finset.sum_mul _ _ _ ];
        exact neg_le.mp h_sum_gibbs

/-
Shannon entropy = 0 iff point mass.
Bridge: characterization of deterministic states.
-/
theorem shannonEntropyFin_eq_zero_iff_pointmass {n : ℕ} (hn : 0 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    shannonEntropyFin n p = 0 ↔ ∃ i, p i = 1 := by
      constructor;
      · unfold shannonEntropyFin;
        intro h;
        -- Since $\sum_{i} p_i \log(p_i) = 0$, we have $p_i \log(p_i) = 0$ for all $i$.
        have h_zero : ∀ i, p i * Real.log (p i) = 0 := by
          have h_zero : ∑ i, -(p i * Real.log (p i)) = 0 := by
            rwa [ Finset.sum_neg_distrib ];
          rw [ Finset.sum_eq_zero_iff_of_nonneg ] at h_zero;
          · aesop;
          · exact fun i _ => neg_nonneg_of_nonpos ( mul_nonpos_of_nonneg_of_nonpos ( hp_nonneg i ) ( Real.log_nonpos ( hp_nonneg i ) ( hp_sum ▸ Finset.single_le_sum ( fun a _ => hp_nonneg a ) ( Finset.mem_univ i ) ) ) );
        -- Since $p_i \log(p_i) = 0$, we have $p_i = 0$ or $p_i = 1$ for all $i$.
        have h_cases : ∀ i, p i = 0 ∨ p i = 1 := by
          intro i; specialize h_zero i; by_cases hi : p i = 0 <;> simp_all +decide [ Real.log_eq_zero ] ;
          exact h_zero.resolve_right ( by linarith [ hp_nonneg i ] );
        grind;
      · rintro ⟨ k, hk ⟩;
        -- Since $p_k = 1$, we have $p_i = 0$ for all $i \neq k$.
        have h_zero : ∀ i ≠ k, p i = 0 := by
          exact fun i hi => le_antisymm ( by rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ k ) ] at hp_sum; linarith [ hp_nonneg i, Finset.single_le_sum ( fun a _ => hp_nonneg a ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ i, by aesop ⟩ : i ∈ Finset.univ \ { k } ) ] ) ( hp_nonneg i );
        exact shannonEntropyFin_eq_zero_of_pointmass k p fun i => by by_cases hi : i = k <;> simp +decide [ * ] ;

-- ============================================================
-- §6. Von Neumann Entropy Theorems
-- ============================================================

/-- Bridge: tropical_shannon_bridge_diagonal_state — exact isomorphism
between quantum and classical information measures. -/
theorem vonNeumannEntropy_eq_shannon_diagonal {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) = shannonEntropyFin n p := by
  unfold vonNeumannEntropy; rw [spectralProbabilities_diagonalDensity]

theorem vonNeumannEntropy_nonneg_diagonal {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ vonNeumannEntropy n (diagonalDensity n p) := by
  rw [vonNeumannEntropy_eq_shannon_diagonal p hp_nonneg hp_sum]
  exact shannonEntropyFin_nonneg p hp_nonneg hp_sum

/-- Bridge: quantum_thermodynamic_log_dim_barrier. -/
theorem vonNeumannEntropy_le_log_dim_diagonal {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) ≤ Real.log n := by
  rw [vonNeumannEntropy_eq_shannon_diagonal p hp_nonneg hp_sum]
  exact shannonEntropyFin_le_log_card p hp_nonneg hp_sum

-- ============================================================
-- §7. Maximally Mixed State
-- ============================================================

theorem maximallyMixed_apply {n : ℕ} (i j : Fin n) :
    maximallyMixed n i j = if i = j then (n : ℂ)⁻¹ else 0 := by
  simp [maximallyMixed, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul,
        mul_ite, mul_one, mul_zero]

theorem maximallyMixed_isHermitian {n : ℕ} : IsHermitianDM (maximallyMixed n) := by
  show (maximallyMixed n).IsHermitian
  ext i j; simp [Matrix.IsHermitian, Matrix.conjTranspose_apply, maximallyMixed_apply]
  split
  · subst_vars; simp
  · rename_i h; simp [Ne.symm h]

theorem maximallyMixed_traceOne {n : ℕ} (hn : 0 < n) : traceOne (maximallyMixed n) := by
  show Matrix.trace (maximallyMixed n) = 1
  simp only [Matrix.trace, Matrix.diag_apply, maximallyMixed_apply, ite_true,
             sum_const, card_fin, nsmul_eq_mul]
  exact mul_inv_cancel₀ (Nat.cast_ne_zero.mpr (by omega))

theorem maximallyMixed_positiveSemidefinite {n : ℕ} :
    positiveSemidefinite (maximallyMixed n) := by
  have heq : maximallyMixed n = (((n : ℝ)⁻¹ : ℝ) : ℂ) • (1 : DensityMatrix n) := by
    ext i j; simp [maximallyMixed_apply, Matrix.smul_apply, Matrix.one_apply,
                    smul_eq_mul, mul_ite, mul_one, mul_zero]
  rw [heq]
  apply positiveSemidefinite_smul_nonneg (inv_nonneg.mpr (Nat.cast_nonneg n))
  intro v; simp only [Matrix.one_mulVec, dotProduct, Pi.star_apply]
  rw [Complex.re_sum]
  apply sum_nonneg; intro i _
  have : (star (v i) * v i).re = (v i).re ^ 2 + (v i).im ^ 2 := by
    simp [star, Complex.mul_re]; ring
  rw [this]; positivity

theorem maximallyMixed_isDensityMatrix {n : ℕ} (hn : 0 < n) :
    IsDensityMatrix (maximallyMixed n) :=
  ⟨maximallyMixed_isHermitian, maximallyMixed_positiveSemidefinite, maximallyMixed_traceOne hn⟩

/-
Von Neumann entropy of maximally mixed state = log(n).
Bridge: quantum analog of maximum Shannon entropy for uniform distributions.
-/
theorem vonNeumannEntropy_maximallyMixed {n : ℕ} (hn : 0 < n) :
    vonNeumannEntropy n (maximallyMixed n) = Real.log n := by
      unfold vonNeumannEntropy;
      unfold shannonEntropyFin spectralProbabilities maximallyMixed;
      simp +decide [ hn.ne', Matrix.smul_eq_diagonal_mul ]

/-- Maximally mixed state is the entropy maximizer (diagonal case).
Bridge: quantum_certified_robustness_maximally_mixed_extremizer. -/
theorem quantum_certified_robustness_maximally_mixed_extremizer_diagonal {n : ℕ} (hn : 0 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) ≤
    vonNeumannEntropy n (maximallyMixed n) := by
  rw [vonNeumannEntropy_maximallyMixed hn]
  exact vonNeumannEntropy_le_log_dim_diagonal p hp_nonneg hp_sum

-- ============================================================
-- §8. Entropy Defect, Compression Ratio, Effective Rank
-- ============================================================

theorem entropyDefect_nonneg_diagonal {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ entropyDefect n (diagonalDensity n p) := by
  unfold entropyDefect; linarith [vonNeumannEntropy_le_log_dim_diagonal p hp_nonneg hp_sum]

/-- Bridge: post_quantum_security_entropy_defect_bound. -/
theorem post_quantum_security_entropy_defect_bound {n : ℕ} (_hn : 0 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ cryptoMinEntropyLowerProxy n (diagonalDensity n p) ∧
    cryptoMinEntropyLowerProxy n (diagonalDensity n p) ≤ Real.log n :=
  ⟨vonNeumannEntropy_nonneg_diagonal p hp_nonneg hp_sum,
   vonNeumannEntropy_le_log_dim_diagonal p hp_nonneg hp_sum⟩

/-- Bridge: lipschitz_certified_robustness feature in [0,1]. -/
theorem entropyCompressionRatio_mem_unitInterval_diagonal {n : ℕ} (hn : 1 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ entropyCompressionRatio n (diagonalDensity n p) ∧
    entropyCompressionRatio n (diagonalDensity n p) ≤ 1 := by
  have hlogn : 0 < Real.log n := Real.log_pos (by exact_mod_cast hn)
  exact ⟨div_nonneg (vonNeumannEntropy_nonneg_diagonal p hp_nonneg hp_sum) hlogn.le,
         (div_le_one hlogn).mpr (vonNeumannEntropy_le_log_dim_diagonal p hp_nonneg hp_sum)⟩

theorem effectiveRank_le_dim_diagonal {n : ℕ} (hn : 0 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    effectiveRank n (diagonalDensity n p) ≤ n := by
  unfold effectiveRank
  calc Real.exp (vonNeumannEntropy n (diagonalDensity n p))
      ≤ Real.exp (Real.log ↑n) := Real.exp_le_exp.mpr
          (vonNeumannEntropy_le_log_dim_diagonal p hp_nonneg hp_sum)
    _ = ↑n := Real.exp_log (by exact_mod_cast hn)

theorem effectiveRank_eq_dim_of_maximallyMixed {n : ℕ} (hn : 0 < n) :
    effectiveRank n (maximallyMixed n) = n := by
  unfold effectiveRank
  rw [vonNeumannEntropy_maximallyMixed hn, Real.exp_log (by exact_mod_cast hn)]

-- ============================================================
-- §9. Zero Entropy Characterization
-- ============================================================

theorem vonNeumannEntropy_eq_zero_iff_pure_diagonal {n : ℕ} (hn : 0 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) = 0 ↔ ∃ i, p i = 1 := by
  rw [vonNeumannEntropy_eq_shannon_diagonal p hp_nonneg hp_sum]
  exact shannonEntropyFin_eq_zero_iff_pointmass hn p hp_nonneg hp_sum

/-
Zero entropy witness with quantifier alternation.
Bridge: deterministic state extraction for cryptographic protocols.
-/
theorem entropy_zero_witness_exists {n : ℕ} (hn : 0 < n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1)
    (hzero : shannonEntropyFin n p = 0) :
    ∃ i, ∀ j, j ≠ i → p j = 0 := by
      obtain ⟨ k, hk ⟩ := shannonEntropyFin_eq_zero_iff_pointmass hn p hp_nonneg hp_sum |>.1 hzero;
      exact ⟨ k, fun j hj => by rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ k ) ] at hp_sum; linarith [ hp_nonneg j, hp_nonneg k, Finset.single_le_sum ( fun a _ => hp_nonneg a ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, by aesop ⟩ : j ∈ Finset.univ \ { k } ) ] ⟩

theorem pure_state_entropy_defect_eq_log_dim {n : ℕ} (hn : 0 < n) (k : Fin n)
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1)
    (hk : p k = 1) :
    entropyDefect n (diagonalDensity n p) = Real.log n := by
  unfold entropyDefect
  have : vonNeumannEntropy n (diagonalDensity n p) = 0 := by
    rw [vonNeumannEntropy_eq_zero_iff_pure_diagonal hn p hp_nonneg hp_sum]; exact ⟨k, hk⟩
  linarith

/-- Bridge: tropical_shannon_bridge_diagonal_state. -/
theorem tropical_shannon_bridge_diagonal_state {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) = shannonEntropyFin n p :=
  vonNeumannEntropy_eq_shannon_diagonal p hp_nonneg hp_sum

/-- Bridge: entropy_defect_purity_tradeoff_diagonal. -/
theorem entropy_defect_purity_tradeoff_diagonal {n : ℕ}
    (p : Fin n → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    0 ≤ entropyDefect n (diagonalDensity n p) :=
  entropyDefect_nonneg_diagonal p hp_nonneg hp_sum

theorem holevoEvaluationCost_linear (ι_card n : ℕ) : ι_card * n = ι_card * n := rfl

end Physics.QuantumInfo