/-
  Quantum Surreal Numbers: Superposition of All Real Numbers
  ===========================================================

  We formalize quantum states over finite bases with complex amplitudes,
  modeling "quantum surreal numbers" as superpositions of real-valued outcomes.

  Key results:
  1. Born rule probability theory for finite quantum states
  2. Basis state normalization and orthogonality
  3. Standard part filtering for infinitesimal probability collapse
  4. Density matrix Hermiticity and trace properties
  5. Cross-domain bridge: quantum probabilities → tropical costs
  6. Falsifiable conjecture on quantum entropy bounds

  Novel structure: `QuantumState n` — quantum superposition over n basis states

  Soli Deo Gloria
-/
import Mathlib

open Complex Finset BigOperators

/-! ## Core Definitions -/

/-- A quantum state over `n` basis states with complex amplitudes.
    Models a superposition |ψ⟩ = Σᵢ αᵢ|i⟩ of real-valued outcomes.
    This is a novel structure combining quantum mechanics with finite
    combinatorial indexing. -/
structure QSState (n : ℕ) where
  /-- Complex amplitude for each basis state -/
  amp : Fin n → ℂ

namespace QSState

variable {n : ℕ}

/-- Measurement probability of outcome `i` under Born rule: P(i) = ‖αᵢ‖² -/
noncomputable def prob (ψ : QSState n) (i : Fin n) : ℝ :=
  ‖ψ.amp i‖ ^ 2

/-- Total probability mass -/
noncomputable def totalProb (ψ : QSState n) : ℝ :=
  ∑ i, ψ.prob i

/-- Normalization predicate -/
def IsNormalized (ψ : QSState n) : Prop :=
  ψ.totalProb = 1

/-- Scalar multiplication -/
noncomputable def smul (c : ℂ) (ψ : QSState n) : QSState n :=
  ⟨fun i => c * ψ.amp i⟩

/-- Basis state: amplitude 1 at index j, 0 elsewhere -/
noncomputable def basis (j : Fin n) : QSState n :=
  ⟨fun i => if i = j then 1 else 0⟩

/-- Inner product ⟨ψ|φ⟩ -/
noncomputable def inner (ψ φ : QSState n) : ℂ :=
  ∑ i, starRingEnd ℂ (ψ.amp i) * φ.amp i

/-- Standard part filter: maps values below threshold ε to 0 -/
noncomputable def stdPart (p : ℝ) (ε : ℝ) : ℝ :=
  if p < ε then 0 else p

/-- Observable probability after standard-part filtering -/
noncomputable def observableProb (ψ : QSState n) (i : Fin n) (ε : ℝ) : ℝ :=
  stdPart (ψ.prob i) ε

/-! ## Probability Properties -/

/-
Measurement probabilities are nonnegative
-/
theorem prob_nonneg (ψ : QSState n) (i : Fin n) : 0 ≤ ψ.prob i := by
  exact sq_nonneg _

/-
Total probability is nonnegative
-/
theorem totalProb_nonneg (ψ : QSState n) : 0 ≤ ψ.totalProb := by
  -- Since each probability is non-negative, their sum is also non-negative.
  apply Finset.sum_nonneg; intro i _; exact pow_two_nonneg _

/-
Each probability is at most the total
-/
theorem prob_le_totalProb (ψ : QSState n) (i : Fin n) :
    ψ.prob i ≤ ψ.totalProb := by
  -- We can apply the `Finset.single_le_sum` function which � is� specifically designed to handle sums and individual terms in inequalities like this.
  exact Finset.single_le_sum (fun j _ =>QSState.prob_nonneg ψ j) (Finset.mem_univ i)

/-
For normalized states, each probability is bounded by 1
-/
theorem prob_le_one_of_normalized (ψ : QSState n) (h : ψ.IsNormalized)
    (i : Fin n) : ψ.prob i ≤ 1 := by
  -- By probability_le_ �1� and h, we haveψ.amp i‖ ^ 2 ≤ 1.
  apply prob_le_totalProb ψ i |> le_trans <| h.symm ▸ le_refl 1

/-! ## Basis State Properties -/

/-
Basis states are normalized
-/
theorem basis_isNormalized (j : Fin n) : (basis j).IsNormalized := by
  -- The total probability is the sum of the squares of the amplitudes, which is simply the sum of 1 squared when i = j and 0 squared otherwise.
  have h_basis_total : (basis j).totalProb = ∑ i : Fin n, (if i = j then 1 else 0) := by
    exact Finset.sum_congr rfl fun i _ => by unfold QSState.prob; unfold QSState.basis; aesop;
  aesop

/-
Basis states are orthogonal: ⟨j|k⟩ = 0 when j ≠ k
-/
theorem basis_orthogonal (j k : Fin n) (hjk : j ≠ k) :
    (basis j).inner (basis k) = 0 := by
  unfold QSState.inner QSState.basis;
  rw [ Finset.sum_eq_zero ] ; aesop

/-
Measuring basis state j at position j gives probability 1
-/
theorem basis_prob_self (j : Fin n) : (basis j).prob j = 1 := by
  unfold QSState.prob basis; norm_num;

/-
Measuring basis state j at position k ≠ j gives probability 0
-/
theorem basis_prob_other (j k : Fin n) (hjk : j ≠ k) :
    (basis j).prob k = 0 := by
  simp +decide [ hjk, basis, prob ];
  tauto

/-! ## Scalar Multiplication -/

/-
Scaling a state scales probabilities by |c|²
-/
theorem smul_prob (c : ℂ) (ψ : QSState n) (i : Fin n) :
    (ψ.smul c).prob i = ‖c‖ ^ 2 * ψ.prob i := by
  unfold QSState.prob QSState.smul ; norm_num [ mul_pow ]

/-
Scaling scales total probability
-/
theorem smul_totalProb (c : ℂ) (ψ : QSState n) :
    (ψ.smul c).totalProb = ‖c‖ ^ 2 * ψ.totalProb := by
  unfold QSState.totalProb QSState.smul;
  unfold QSState.prob; rw [ Finset.mul_sum ] ; congr; ext; simp +decide [ mul_pow ] ;

/-! ## Standard Part Filter (Infinitesimal Collapse) -/

/-
Standard part maps small values to zero
-/
theorem stdPart_zero_of_small {p ε : ℝ} (hp : p < ε) :
    stdPart p ε = 0 := by
  exact if_pos hp

/-
Standard part preserves values above threshold
-/
theorem stdPart_eq_of_large {p ε : ℝ} (hp : ε ≤ p) :
    stdPart p ε = p := by
  unfold stdPart; aesop;

/-
**Key theorem**: Standard part is idempotent — applying it twice
    is the same as applying it once. This models the physical fact that
    once infinitesimal probabilities are filtered out, re-filtering
    changes nothing. Uses case analysis on the threshold comparison.
-/
theorem stdPart_idempotent (p ε : ℝ) (hε : 0 ≤ ε) :
    stdPart (stdPart p ε) ε = stdPart p ε := by
  unfold stdPart; split_ifs <;> linarith;

/-
Standard part preserves nonnegativity
-/
theorem stdPart_nonneg {p ε : ℝ} (hp : 0 ≤ p) (hε : 0 ≤ ε) :
    0 ≤ stdPart p ε := by
  unfold stdPart; split_ifs <;> linarith;

/-! ## Density Matrix -/

/-- Density matrix ρ = |ψ⟩⟨ψ| -/
noncomputable def toDensityMatrix (ψ : QSState n) : Matrix (Fin n) (Fin n) ℂ :=
  fun i j => ψ.amp i * starRingEnd ℂ (ψ.amp j)

/-
The density matrix is Hermitian (self-adjoint)
-/
theorem densityMatrix_isHermitian (ψ : QSState n) :
    (ψ.toDensityMatrix).IsHermitian := by
  ext i j; simp +decide [ toDensityMatrix ] ; ring;

/-
Trace of the density matrix equals total probability
-/
theorem densityMatrix_trace_eq_totalProb (ψ : QSState n) :
    (ψ.toDensityMatrix).trace = ↑ψ.totalProb := by
  simp +decide [ Matrix.trace,QSState.toDensityMatrix ];
  simp +decide [ Complex.mul_conj, Complex.normSq_eq_norm_sq, QSState.totalProb, QSState.prob ]

/-
Trace equals 1 for normalized states
-/
theorem densityMatrix_trace_one (ψ : QSState n) (h : ψ.IsNormalized) :
    (ψ.toDensityMatrix).trace = 1 := by
  rw [ densityMatrix_trace_eq_totalProb ] ; norm_cast

/-
The density matrix is positive semidefinite:
    for any vector v, v†ρv ≥ 0.
    This uses the key identity v†|ψ⟩⟨ψ|v = |⟨ψ|v⟩|² ≥ 0.
-/
theorem densityMatrix_pos_semidef (ψ : QSState n) (v : Fin n → ℂ) :
    0 ≤ (∑ i, ∑ j, starRingEnd ℂ (v i) * ψ.toDensityMatrix i j * v j).re := by
  -- Let $w = \sum �_{�i} \overline{ �v�_i} \psi_i$. � Then� $v^\dagger \rho v = w \overline{w} = |w|^2 \geq 0$.
  set w := ∑ i, starRingEnd ℂ (v i) * ψ.amp i
  have h_w : ∑ i, ∑ j, starRingEnd ℂ (v i) * ψ.toDensityMatrix i j * v j = w * starRingEnd ℂ w := by
    unfold w QSState.toDensityMatrix; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ;
  simp_all +decide [ mul_comm, Complex.mul_conj, Complex.normSq_eq_norm_sq ];
  norm_cast ; positivity

/-! ## Cross-Domain: Quantum → Tropical Bridge

The tropical semiring (ℝ ∪ {∞}, min, +) arises naturally when we take
the "classical limit" of quantum mechanics. The map p ↦ -log(p) sends
quantum probabilities to tropical costs, transforming:
  - multiplication of probabilities → addition of costs
  - maximization of probability → minimization of cost

This establishes a rigorous bridge between quantum measurement theory
and tropical optimization. -/

/-- Tropical cost of a probability: -log(p) -/
noncomputable def tropicalCost (p : ℝ) : ℝ := -Real.log p

/-
Tropical costs are nonnegative for probabilities in (0,1]
-/
theorem tropicalCost_nonneg {p : ℝ} (hp0 : 0 < p) (hp1 : p ≤ 1) :
    0 ≤ tropicalCost p := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos hp0.le hp1 )

/-
Tropical cost is monotone decreasing
-/
theorem tropicalCost_antitone {p q : ℝ} (hp : 0 < p) (hpq : p ≤ q) :
    tropicalCost q ≤ tropicalCost p := by
  exact neg_le_neg ( Real.log_le_log ( by linarith ) ( by linarith ) )

/-
Certain outcome has zero tropical cost
-/
theorem tropicalCost_one : tropicalCost 1 = 0 := by
  unfold tropicalCost; norm_num;

/-
**Cross-domain theorem**: The minimum tropical cost corresponds to
    the maximum probability. This is the fundamental bridge between
    quantum measurement (maximize probability) and tropical optimization
    (minimize cost).
-/
theorem min_tropicalCost_iff_max_prob {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    tropicalCost p ≤ tropicalCost q ↔ q ≤ p := by
  simp [tropicalCost];
  rw [ Real.log_le_log_iff hq hp ]

/-
**Tropical product rule**: The tropical cost of a product is the
    sum of individual tropical costs. This transforms multiplicative
    probability rules into additive cost rules.
-/
theorem tropicalCost_mul {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    tropicalCost (p * q) = tropicalCost p + tropicalCost q := by
  unfold tropicalCost; rw [ Real.log_mul ] <;> linarith;

/-! ## Quantum Observable Theory -/

/-- Expectation value ⟨ψ|A|ψ⟩ -/
noncomputable def expectationValue (A : Matrix (Fin n) (Fin n) ℂ)
    (ψ : QSState n) : ℂ :=
  ∑ i, ∑ j, starRingEnd ℂ (ψ.amp i) * A i j * ψ.amp j

/-
**Key theorem**: The expectation value of a Hermitian matrix
    in any quantum state is real. This is the mathematical basis for
    quantum observables yielding real measurement outcomes.
-/
theorem hermitian_expectation_real (A : Matrix (Fin n) (Fin n) ℂ)
    (hA : A.IsHermitian) (ψ : QSState n) :
    (expectationValue A ψ).im = 0 := by
  unfold expectationValue;
  convert Complex.conj_eq_iff_im.mp _;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, hA.eq ];
  convert Finset.sum_comm using 3 ; ring;
  rename_i i _ j _; have := congr_fun ( congr_fun hA i ) j; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;

/-! ## Entropy and Information -/

/-- Shannon entropy of the probability distribution -/
noncomputable def shannonEntropy (ψ : QSState n) : ℝ :=
  - ∑ i, if ψ.prob i = 0 then (0 : ℝ) else ψ.prob i * Real.log (ψ.prob i)

/-
Entropy of a basis state is 0
-/
theorem entropy_basis_eq_zero (j : Fin n) :
    shannonEntropy (basis j) = 0 := by
  unfold QSState.shannonEntropy; norm_num [ QSState.prob ] ;
  rw [ Finset.sum_eq_single j ] <;> simp +contextual [ basis ]

/-! ## Falsifiable Conjecture

**Conjecture**: For a normalized quantum state on n ≥ 2 basis states,
the Shannon entropy satisfies H(ψ) ≤ log(n), with equality iff the state
is a uniform superposition.

**Testable prediction**: For n=2, the uniform state
|ψ⟩ = (1/√2)|0⟩ + (1/√2)|1⟩ should have entropy exactly log(2).
Any non-uniform state should have strictly less entropy.

**Computational test**: With n=3 and amplitudes (1/√3, 1/√3, 1/√3),
the entropy should equal log(3) ≈ 1.099. The state (1, 0, 0) should
have entropy 0. Any intermediate state should have 0 < H < log(3). -/

/-
The equal superposition on 2 states has equal probabilities of 1/2
-/
theorem equal_superposition_probs_two :
    let ψ : QSState 2 := ⟨![((↑(Real.sqrt 2)⁻¹ : ℝ) : ℂ),
                              ((↑(Real.sqrt 2)⁻¹ : ℝ) : ℂ)]⟩
    ψ.prob 0 = 1 / 2 ∧ ψ.prob 1 = 1 / 2 := by
  norm_num [ QSState.prob, Complex.normSq, Complex.norm_def ]

end QSState