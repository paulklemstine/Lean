import NumberTheory.RLHFZetaEulerPolicy

/-!
# Divisibility statistics of the aligned (zeta) policy

For the Dirichlet reward on the `{p,q}`-smooth response space, the optimal RLHF policy is
the truncated zeta distribution (`RLHF.gibbs_zeta_policy`).  Here we compute the
*arithmetic* statistics of the responses it emits.

* `RLHF.gibbs_exponent_zero_marginal` — the probability that the sampled response is
  **not divisible** by `p` equals `1 / localZeta s p A`.
* `RLHF.prob_dvd_lt_zetaWeight` — hence the probability that `p` divides the sampled
  response is strictly below `p^{-s}`, the classical Dirichlet density.
* `RLHF.tendsto_localZeta_euler_factor`, `RLHF.tendsto_prob_not_dvd` — as the exponent
  cutoff is lifted, these statistics converge exactly to the Golomb–Dirichlet values
  `1 - p^{-s}`: alignment reproduces the density of `p`-indivisible integers.
-/

namespace RLHF

open Finset Filter Topology

variable {A B : ℕ}

/-- The exponent-zero (i.e. `p ∤ n`) marginal probability of the aligned policy. -/
theorem gibbs_exponent_zero_marginal {β s : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p)
    (hq : 0 < q) :
    ∑ b : Fin (B + 1),
        gibbsPolicy β (zetaReward (A := A) (B := B) β s p q) (uniformDist (Smooth A B))
          (⟨0, Nat.succ_pos A⟩, b)
      = 1 / localZeta s p A := by
  have h1 : (0 : ℝ) < localZeta s p A := localZeta_pos hp
  have h2 : (0 : ℝ) < localZeta s q B := localZeta_pos hq
  have hw0 : zetaWeight s (p ^ (0 : ℕ)) = 1 := by
    simp [zetaWeight]
  have hterm : ∀ b : Fin (B + 1),
      gibbsPolicy β (zetaReward (A := A) (B := B) β s p q) (uniformDist (Smooth A B))
          (⟨0, Nat.succ_pos A⟩, b)
        = (1 / localZeta s p A) * (zetaWeight s (q ^ (b : ℕ)) / localZeta s q B) := by
    intro b
    rw [gibbs_zeta_independent hβ hp hq]
    simp only [hw0]
  rw [Finset.sum_congr rfl (fun b _ => hterm b), ← Finset.mul_sum, ← Finset.sum_div]
  have hsum : ∑ b : Fin (B + 1), zetaWeight s (q ^ (b : ℕ)) = localZeta s q B := rfl
  rw [hsum, div_self (ne_of_gt h2), mul_one]

/-- **Sub-Dirichlet divisibility.**  Under the aligned policy the prime `p` divides the
sampled response with probability strictly less than `p^{-s}`. -/
theorem prob_dvd_lt_zetaWeight {s : ℝ} {p : ℕ} (hp : 2 ≤ p) (hs : 0 < s) :
    1 - 1 / localZeta s p A < zetaWeight s p := by
  have hp0 : 0 < p := by omega
  have hlt : zetaWeight s p < 1 := zetaWeight_lt_one hp hs
  have hpos : (0 : ℝ) < 1 - zetaWeight s p := by linarith
  have hL : (0 : ℝ) < localZeta s p A := localZeta_pos hp0
  have hbound : localZeta s p A < (1 - zetaWeight s p)⁻¹ := localZeta_lt_euler_factor hp hs
  have key : 1 / ((1 - zetaWeight s p)⁻¹) < 1 / localZeta s p A :=
    one_div_lt_one_div_of_lt hL hbound
  have hsimp : 1 / ((1 - zetaWeight s p)⁻¹) = 1 - zetaWeight s p := by
    field_simp
  linarith [hsimp ▸ key]

/-- As the exponent cutoff grows, the local partition function converges to the Euler
factor. -/
theorem tendsto_localZeta_euler_factor {s : ℝ} {p : ℕ} (hp : 2 ≤ p) (hs : 0 < s) :
    Tendsto (fun A : ℕ => localZeta s p A) atTop (𝓝 (1 - zetaWeight s p)⁻¹) := by
  have hp0 : 0 < p := by omega
  have hlt : zetaWeight s p < 1 := zetaWeight_lt_one hp hs
  have hnn : 0 ≤ zetaWeight s p := (zetaWeight_pos hp0).le
  have hne : zetaWeight s p ≠ 1 := ne_of_lt hlt
  have hpow : Tendsto (fun A : ℕ => zetaWeight s p ^ (A + 1)) atTop (𝓝 0) := by
    have h := tendsto_pow_atTop_nhds_zero_of_lt_one hnn hlt
    exact h.comp (tendsto_add_atTop_nat 1)
  have hform : ∀ A : ℕ, localZeta s p A
      = (zetaWeight s p ^ (A + 1) - 1) / (zetaWeight s p - 1) :=
    fun A => localZeta_geom hp0 hne
  have hlim : Tendsto (fun A : ℕ => (zetaWeight s p ^ (A + 1) - 1) / (zetaWeight s p - 1))
      atTop (𝓝 ((0 - 1) / (zetaWeight s p - 1))) :=
    ((hpow.sub tendsto_const_nhds).div_const _)
  have heq : (0 - 1) / (zetaWeight s p - 1) = (1 - zetaWeight s p)⁻¹ := by
    rw [eq_comm, inv_eq_iff_eq_inv]
    field_simp
    ring
  rw [heq] at hlim
  simpa [hform] using hlim

/-- **Golomb–Dirichlet limit.**  Lifting the exponent cutoff, the probability that the
aligned policy emits a response *not* divisible by `p` converges to `1 - p^{-s}`. -/
theorem tendsto_prob_not_dvd {s : ℝ} {p : ℕ} (hp : 2 ≤ p) (hs : 0 < s) :
    Tendsto (fun A : ℕ => 1 / localZeta s p A) atTop (𝓝 (1 - zetaWeight s p)) := by
  have hlt : zetaWeight s p < 1 := zetaWeight_lt_one hp hs
  have hpos : (0 : ℝ) < 1 - zetaWeight s p := by linarith
  have h := (tendsto_localZeta_euler_factor hp hs).inv₀ (by positivity)
  simpa [one_div, inv_inv] using h

end RLHF