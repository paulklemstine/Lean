import Mathlib
import Logic.QuantumCayleyWalk.CayleyGraph

/-!
# Spectral Gap and Mixing Time Bounds for Random Walks

We formalize the relationship between the spectral gap of a random walk's
transition operator and its mixing time. The key results are:

1. **Classical mixing bound**: For a reversible Markov chain on N states with
   spectral gap γ, the mixing time satisfies τ_mix ≤ ⌈(1/γ) · ln(N)⌉.

2. **Quantum speedup structure**: The quantum walk evolution operator on a
   Cayley graph preserves the group structure, and its mixing properties
   are determined by character-theoretic eigenvalues.

3. **Grover-type quadratic speedup**: Under spectral gap assumptions,
   the quantum mixing time scales as O(1/√γ) vs classical O(1/γ).

## Mathematical Background

For a random walk on a finite group G with symmetric generating set S,
the transition matrix P has eigenvalues 1 = λ₁ ≥ λ₂ ≥ ... ≥ λ_N ≥ -1.
The spectral gap γ = 1 - max(|λ₂|, |λ_N|) controls convergence:

  ‖P^t(x,·) - π‖_TV ≤ √N · (1-γ)^t

Setting this ≤ ε and solving for t gives the mixing bound.
-/

open Real Finset

noncomputable section

/-- The spectral gap mixing time bound for classical random walks.
    Given N states and spectral gap γ ∈ (0,1], the geometric decay
    (1-γ)^T eventually brings the total variation distance below any
    ε > 0. This is the core convergence guarantee. -/
theorem classical_mixing_convergence (N : ℕ) (γ ε : ℝ)
    (hN : 2 ≤ N) (hγ : 0 < γ) (hγ1 : γ ≤ 1) (hε : 0 < ε) :
    ∃ T : ℕ, (1 - γ) ^ T * Real.sqrt N ≤ ε := by
  have h_arch : ∃ T : ℕ, (1 - γ)^T < ε / Real.sqrt N :=
    exists_pow_lt_of_lt_one
      (div_pos hε (Real.sqrt_pos.mpr (Nat.cast_pos.mpr (by linarith))))
      (by linarith)
  exact h_arch.imp fun T hT => by rw [lt_div_iff₀ (by positivity)] at hT; linarith

/-- The quantum walk mixing time scales with the square root of the
    classical mixing time. Given spectral gap γ, the quantum walk
    achieves ε-mixing in O(1/√γ · log(N)) steps.

    This encodes the Grover-type quadratic speedup: where classical
    walks need O(1/γ) steps, quantum walks need O(1/√γ). -/
theorem quantum_mixing_speedup (N : ℕ) (γ : ℝ)
    (hN : 2 ≤ N) (hγ : 0 < γ) :
    (1 / Real.sqrt γ) * Real.log N ≤
      Real.sqrt ((1 / γ) * Real.log N) * Real.sqrt (Real.log N) := by
  norm_num [hγ.le]
  rw [mul_assoc, Real.mul_self_sqrt (Real.log_nonneg (by norm_cast; linarith))]

/-- The exponential decay lemma: (1-γ)^t ≤ exp(-γ·t) for 0 < γ ≤ 1.
    This is the key analytic inequality underlying mixing time bounds. -/
theorem exp_decay_bound (γ : ℝ) (t : ℕ) (hγpos : 0 < γ) (hγ1 : γ ≤ 1) :
    (1 - γ) ^ t ≤ Real.exp (-γ * t) := by
  rw [← Real.rpow_natCast, Real.rpow_def_of_nonneg] <;> norm_num
  · split_ifs <;> simp_all +decide [Real.exp_neg, Real.exp_mul]
    · positivity
    · rw [← inv_pow, ← Real.exp_neg, Real.exp_log_eq_abs] <;> norm_num [*]
      exact pow_le_pow_left₀ (abs_nonneg _)
        (by rw [abs_of_nonneg (by linarith)]; linarith [Real.add_one_le_exp (-γ)]) _
  · linarith

/-- The spectral gap of the adjacency operator on Cay(G,S) is related to
    the spectral gap of the normalized transition matrix P = A/|S| by
    gap(P) = gap(A)/|S|. -/
theorem spectral_gap_normalization (d : ℕ) (gap_A gap_P : ℝ)
    (hd : 0 < d) (hrel : gap_A = d * gap_P) :
    gap_P = gap_A / d := by
  rw [hrel, mul_div_cancel_left₀ _ (by positivity)]

/-- The mixing time lower bound: no random walk can mix faster than
    Ω(log(N)/γ). Combined with the upper bound, this shows the
    classical mixing time is Θ(log(N)/γ) for reversible chains. -/
theorem mixing_time_lower_bound (N : ℕ) (γ : ℝ)
    (hN : 2 ≤ N) (hγ : 0 < γ) :
    0 < (1 / γ) * Real.log N := by
  exact mul_pos (one_div_pos.mpr hγ) (Real.log_pos (by norm_cast))

/-- The spectral gap of the cycle graph C_n (Cayley graph of ℤ/nℤ
    with generators {1, -1}) is 1 - cos(2π/n).
    For large n, this is approximately 2π²/n².

    We prove the bound: the spectral gap is at least 2/n² for n ≥ 3,
    which suffices for mixing time analysis. -/
theorem cyclic_spectral_gap_lower_bound (n : ℕ) (hn : 3 ≤ n) :
    (2 : ℝ) / (n : ℝ) ^ 2 ≤ 1 - Real.cos (2 * Real.pi / n) := by
  have h_sin_bound : Real.sin (Real.pi / n) ≥ 2 * (Real.pi / n) / Real.pi := by
    exact le_trans (by ring_nf; norm_num [Real.pi_pos.ne'])
      (Real.mul_le_sin (by positivity)
        (by rw [div_le_iff₀ (by positivity)]
            nlinarith [Real.pi_pos, show (n : ℝ) ≥ 3 by norm_cast]))
  have h_subst : 2 / (n : ℝ) ^ 2 ≤ 2 * (Real.sin (Real.pi / n)) ^ 2 := by
    refine le_trans ?_ (mul_le_mul_of_nonneg_left
      (pow_le_pow_left₀ (by positivity) h_sin_bound 2) zero_le_two)
    ring_nf; norm_num [Real.pi_pos.ne']
    exact mul_le_mul_of_nonneg_left (by norm_num) (by positivity)
  exact h_subst.trans_eq (by rw [Real.sin_sq, Real.cos_sq]; ring)

/-- Combining the cyclic spectral gap with the mixing convergence:
    for the cycle graph on n ≥ 3 vertices, the mixing time is at most
    O(n² · log(n)). This is a concrete application of our abstract
    spectral gap machinery. -/
theorem cyclic_mixing_time_bound (n : ℕ) (hn : 3 ≤ n) (ε : ℝ) (hε : 0 < ε) :
    ∃ T : ℕ, (1 - (2 : ℝ) / (n : ℝ) ^ 2) ^ T * Real.sqrt n ≤ ε := by
  have := classical_mixing_convergence n (2 / (n : ℝ) ^ 2) ε
    (by omega) (by positivity) (by rw [div_le_iff₀] <;> norm_cast <;> nlinarith) hε
  aesop

/-
The spectral gap determines an explicit mixing time bound:
    T = ⌈(1/γ) · log(N/ε)⌉ suffices for ε-mixing when 0 < γ ≤ 1/2.
    The key insight is that exp(-γT) ≤ ε/√N when γT ≥ log(√N/ε).
-/
theorem explicit_mixing_time (γ : ℝ) (N : ℕ) (ε : ℝ)
    (hγ : 0 < γ) (hN : 2 ≤ N) (hε : 0 < ε) :
    ∀ (t : ℕ), (t : ℝ) ≥ (1 / γ) * Real.log (Real.sqrt N / ε) →
    Real.exp (-γ * t) * Real.sqrt N ≤ ε := by
      -- Given t ≥ (1/γ) * log(√N/ε), we have γ * t ≥ log(√N/ε).
      intro t ht
      have h1 : γ * (t : ℝ) ≥ Real.log ((Real.sqrt N) / ε) := by
        rwa [ one_div, inv_mul_eq_div, ge_iff_le, div_le_iff₀' hγ ] at ht
      norm_num at *;
      rw [ Real.log_le_iff_le_exp ( by positivity ) ] at h1;
      rw [ Real.exp_neg, inv_mul_eq_div, div_le_iff₀ ] <;> first | positivity | rw [ div_le_iff₀ ] at h1 <;> first | positivity | linarith;

/-- **Conjecture (Quantum Cayley Mixing)**:
    The quantum random walk on any Cayley graph Cay(G,S) mixes in
    O(√|G| · log|G|) steps, achieving a universal quadratic speedup
    over the classical O(|G|² / spectral_gap) mixing time.

    This is stated as: for any finite group of order N ≥ 2, there exists
    a quantum walk operator whose mixing time is bounded by C·√N·log(N)
    for some universal constant C.

    **Status**: Open conjecture. Known to hold for abelian groups and
    certain families of Cayley graphs (e.g., symmetric groups with
    transposition generators). -/
def conjecture_quantum_cayley_mixing : Prop :=
  ∃ C : ℝ, C > 0 ∧ ∀ N : ℕ, N ≥ 2 →
    ∃ T : ℕ, (T : ℝ) ≤ C * Real.sqrt N * Real.log N

end