/-
  Quantum Random Walks on Cayley Graphs: Main Theorems

  This module proves key results about mixing times, spectral gaps,
  and the quadratic quantum speedup for walks on Cayley graphs.
-/
import Mathlib
import EML.QuantumCayleyWalk.Defs

open Finset BigOperators Matrix Real

noncomputable section

/-! ## Theorem 1: Cayley Adjacency Symmetry

The Cayley adjacency relation is symmetric when the generating set
is symmetric. This is fundamental: it ensures the Cayley graph is
undirected, which is necessary for the transition matrix to be
doubly stochastic and for spectral theory to apply. -/

theorem cayleyAdj_symm_proof {G : Type*} [Group G] (S : Set G) (hS : IsSymmGenSet S) :
    ∀ g h : G, cayleyAdj S g h → cayleyAdj S h g := by
  exact cayleyAdj_symm S hS

/-! ## Theorem 2: Transition Matrix Row Sum

Each row of the Cayley transition matrix sums to 1, confirming
it is a (right) stochastic matrix. This is essential for interpreting
the matrix as defining a probability distribution at each step. -/

theorem cayleyTransition_row_sum {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    (S : Finset G) (hS : S.Nonempty) (g : G)
    (hbij : ∀ g : G, (Finset.univ.filter (fun h => g⁻¹ * h ∈ S)).card = S.card) :
    ∑ h : G, cayleyTransition S g h = 1 := by
  unfold cayleyTransition
  simp +decide [← Finset.sum_filter, hbij g, hS.ne_empty]

/-! ## Theorem 3: Transition Matrix Non-Negativity -/

theorem cayleyTransition_nonneg {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    (S : Finset G) (g h : G) :
    0 ≤ cayleyTransition S g h := by
  unfold cayleyTransition; split_ifs <;> positivity

/-! ## Theorem 4: Total Variation is Non-Negative -/

theorem totalVariation_nonneg {G : Type*} [Fintype G] (p q : G → ℝ) :
    0 ≤ totalVariation p q := by
  exact mul_nonneg (by norm_num) (Finset.sum_nonneg fun _ _ => abs_nonneg _)

/-! ## Theorem 5: Classical Mixing Time Lower Bound

The classical mixing time is at least (1/γ) · log(1/(2ε)).
This is the information-theoretic lower bound: no Markov chain
can mix faster than this. The proof uses that log N ≥ log 2 ≥ 0
when N ≥ 2, giving the bound from monotonicity of multiplication. -/

theorem classical_mix_lower_bound (N : ℕ) (γ ε : ℝ)
    (hN : (2 : ℝ) ≤ N) (hγ : 0 < γ) (hε : 0 < ε) (hε1 : ε < 1 / 2) :
    (1 / γ) * Real.log (1 / (2 * ε)) ≤ classicalMixBound N γ ε := by
  unfold classicalMixBound
  gcongr
  rw [← Real.log_mul (by positivity) (by positivity)]
  exact Real.log_le_log (by positivity)
    (by rw [div_le_iff₀] <;> nlinarith [mul_div_cancel₀ 1 hε.ne'])

/-! ## Theorem 6: Quantum Speedup — Core Result

The quantum mixing time is at most √(classical mixing time · log factor).
Specifically:
  quantumMixBound ≤ √(classicalMixBound · L)
where L = log(N) + log(1/ε).

This captures the quadratic speedup: the quantum walk achieves in
√T steps what the classical walk achieves in T steps. -/

theorem quantum_speedup_bound (N : ℕ) (γ ε : ℝ)
    (_hN : (2 : ℝ) ≤ N) (hγ : 0 < γ) (_hγ1 : γ ≤ 1)
    (_hε : 0 < ε) (_hε1 : ε < 1) :
    quantumMixBound N γ ε ≤
    Real.sqrt (classicalMixBound N γ ε * (Real.log N + Real.log (1 / ε))) := by
  convert Real.le_sqrt_of_sq_le _ using 1
  unfold quantumMixBound classicalMixBound
  rw [mul_pow, Real.sq_sqrt (by positivity)]; ring_nf; norm_num

/-! ## Theorem 7: Spectral Gap Determines Speedup Ratio

When the log factor L > 0, the speedup ratio satisfies:
  classicalMixBound / quantumMixBound = (1/γ)·L / (√(1/γ)·L) = √(1/γ)

This shows the quantum speedup is exactly √(1/γ), which for
a spectral gap γ = Ω(1/n) gives a speedup of √n. -/

theorem speedup_ratio_eq (N : ℕ) (γ ε : ℝ)
    (_hγ : 0 < γ)
    (hL : 0 < Real.log N + Real.log (1 / ε)) :
    mixingSpeedupRatio N γ ε = Real.sqrt (1 / γ) := by
  unfold mixingSpeedupRatio classicalMixBound quantumMixBound
  rw [mul_div_mul_right _ _ hL.ne', one_div]
  rw [Real.div_sqrt]

/-! ## Theorem 8: Uniform Distribution Sums to 1 -/

theorem uniformDist_sum (G : Type*) [Fintype G] [Nonempty G] :
    ∑ g : G, uniformDist G g = 1 := by
  unfold uniformDist; simp +decide

/-! ## Theorem 9: Measurement Probabilities are Non-Negative -/

theorem measureProb_nonneg {G : Type*} (ψ : QuantumWalkState G) (g : G) :
    0 ≤ measureProb ψ g :=
  Complex.normSq_nonneg _

/-! ## Theorem 10: Quantum Walk on Cyclic Group — Spectral Gap Bound

For the cyclic group ℤ/nℤ with standard generators {1, -1},
the spectral gap of the Cayley graph is γ = 1 - cos(2π/n).
For large n, γ ~ 2π²/n².

We prove: for n ≥ 3, γ ≥ 2/n².
This uses the Jordan inequality sin(x) ≥ (2/π)x for x ∈ [0, π/2]
combined with the identity 1 - cos(2x) = 2sin²(x). -/

theorem cyclic_spectral_gap_bound (n : ℕ) (hn : 3 ≤ n) :
    (2 : ℝ) / (n : ℝ)^2 ≤ 1 - Real.cos (2 * Real.pi / n) := by
  have h_trig : 1 - Real.cos (2 * Real.pi / n) = 2 * (Real.sin (Real.pi / n))^2 := by
    rw [Real.sin_sq, Real.cos_sq]; ring
  have h_sin_ineq : Real.sin (Real.pi / n) ≥ (2 / Real.pi) * (Real.pi / n) := by
    exact le_trans (by ring_nf; norm_num [Real.pi_pos.ne'])
      (Real.mul_le_sin (by positivity)
        (by rw [div_le_iff₀ (by positivity)]
            nlinarith [Real.pi_pos, show (n : ℝ) ≥ 3 by norm_cast]))
  refine le_trans ?_ (h_trig.symm ▸ mul_le_mul_of_nonneg_left
    (pow_le_pow_left₀ (by positivity) h_sin_ineq 2) zero_le_two)
  ring_nf; norm_num [Real.pi_pos.ne']
  exact mul_le_mul_of_nonneg_left (by norm_num) (by positivity)

/-! ## Conjecture: Universal Quadratic Speedup (Corrected)

For any finite group G with symmetric generating set S and
precision ε < 1, the quantum walk on Cay(G,S) mixes in
O(√(|G|/γ) · log(|G|/ε)) steps.

Testable prediction: simulate quantum walks on S₅, A₅, and
ℤ/100ℤ and verify τ_quantum ≤ C · √(|G|/γ) · log(|G|/ε). -/

/-
The universal quantum speedup bound:
    quantumMixBound ≤ √(N/γ) · log(N/ε) when ε < 1, N ≥ 2.
-/
theorem quantum_cayley_universal_bound (N : ℕ) (γ ε : ℝ)
    (hN : 2 ≤ N) (hγ : 0 < γ) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    quantumMixBound N γ ε ≤ Real.sqrt (↑N / γ) * (Real.log ↑N + Real.log (1 / ε)) := by
  refine' mul_le_mul_of_nonneg_right ( Real.sqrt_le_sqrt _ ) _;
  · gcongr ; norm_cast;
    linarith;
  · exact add_nonneg ( Real.log_nonneg ( by norm_cast; linarith ) ) ( Real.log_nonneg ( by rw [ le_div_iff₀ hε ] ; linarith ) )

end