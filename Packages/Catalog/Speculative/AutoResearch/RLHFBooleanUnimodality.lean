import Combinatorics.RLHFBooleanLattice

/-!
# Log-concavity, entropy and temperature monotonicity of the aligned policy

Second research cycle on the RLHF/InstructGPT objective over the Boolean lattice
`Finset (Fin n)` (see `Combinatorics.RLHFBooleanLattice`).  The guiding question is
structural: *what shape does KL-regularized alignment impose on the distribution of the
reward statistic?*

Main results (all `sorry`-free):

* `choose_log_concave` — log-concavity of the binomial coefficients,
  `C(n,k)·C(n,k+2) ≤ C(n,k+1)²`, proved from the absorption identity
  `C(n,k+1)(k+1) = C(n,k)(n−k)`.
* `binomialLevel_log_concave` and `binomialLevel_decreasing_persists` — the reward-level
  masses of the aligned policy are log-concave, hence **unimodal**: a KL-regularized
  policy with a counting reward can never be bimodal in the reward statistic, so
  "two-mode reward hacking" is impossible for linear neurosymbolic rewards.
* `entropy_bernoulliSubsets` — the aligned policy has entropy exactly `n · H(θ)` with
  `θ = σ(a/β)`, the binary entropy of the per-feature acceptance probability.
* `klDiv_uniformSubsets_eq` — the information drift from the uniform SFT policy is
  `n log 2 − H(policy)`, giving an entropy/free-energy consistency identity
  `logistic_free_energy_identity` that cross-validates the two independent computations
  of the drift (`klDiv_gibbs_uniform` versus the entropy route).
* `logistic_strictMono`, `expected_reward_strictAnti_temperature`,
  `top_mass_strictAnti_temperature` — raising the KL temperature `β` strictly lowers both
  the achieved reward and the mass on the reward-maximizing response: the alignment /
  reward-hacking trade-off is strictly monotone in `β`.
-/

namespace RLHFCombinatorics

open Finset RLHF

section Unimodality

/-- **Log-concavity of binomial coefficients**: `C(n,k)·C(n,k+2) ≤ C(n,k+1)²`. -/
theorem choose_log_concave (n k : ℕ) :
    n.choose k * n.choose (k + 2) ≤ n.choose (k + 1) * n.choose (k + 1) := by
  rcases le_or_gt n k with h | h
  · have hz : n.choose (k + 2) = 0 := Nat.choose_eq_zero_of_lt (by omega)
    simp [hz]
  · have h1 : n.choose (k + 1) * (k + 1) = n.choose k * (n - k) := Nat.choose_succ_right_eq n k
    have h2 : n.choose (k + 2) * (k + 2) = n.choose (k + 1) * (n - (k + 1)) :=
      Nat.choose_succ_right_eq n (k + 1)
    have hpos : 0 < (n - k) * (k + 2) := by
      have : 0 < n - k := by omega
      positivity
    refine Nat.le_of_mul_le_mul_left ?_ hpos
    calc (n - k) * (k + 2) * (n.choose k * n.choose (k + 2))
        = (n.choose k * (n - k)) * (n.choose (k + 2) * (k + 2)) := by ring
      _ = (n.choose (k + 1) * (k + 1)) * (n.choose (k + 1) * (n - (k + 1))) := by
          rw [← h1, h2]
      _ = n.choose (k + 1) * n.choose (k + 1) * ((k + 1) * (n - (k + 1))) := by ring
      _ ≤ n.choose (k + 1) * n.choose (k + 1) * ((n - k) * (k + 2)) := by
          refine Nat.mul_le_mul_left _ ?_
          calc (k + 1) * (n - (k + 1)) ≤ (k + 2) * (n - k) :=
                Nat.mul_le_mul (by omega) (by omega)
            _ = (n - k) * (k + 2) := by ring
      _ = (n - k) * (k + 2) * (n.choose (k + 1) * n.choose (k + 1)) := by ring

/-- The mass the aligned policy assigns to the reward level `{S : |S| = k}`. -/
noncomputable def binomialLevel (n k : ℕ) (θ : ℝ) : ℝ :=
  (n.choose k : ℝ) * θ ^ k * (1 - θ) ^ (n - k)

theorem binomialLevel_nonneg {n k : ℕ} {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    0 ≤ binomialLevel n k θ := by
  have : 0 ≤ 1 - θ := by linarith
  unfold binomialLevel
  positivity

/-- The reward statistic of the aligned policy follows the binomial law
`Binomial(n, σ(a/β))`, restated in terms of `binomialLevel`. -/
theorem gibbs_level_mass_eq (n k : ℕ) (a β : ℝ) :
    ∑ S ∈ (univ : Finset (Finset (Fin n))).filter (fun S => S.card = k),
        gibbsPolicy β (sizeReward n a) (uniformSubsets n) S
      = binomialLevel n k (logistic (a / β)) := by
  rw [gibbs_level_mass, binomialLevel, mul_assoc]

/-- **Log-concavity of the aligned reward law.**  The level masses satisfy
`m_k · m_{k+2} ≤ m_{k+1}²`. -/
theorem binomialLevel_log_concave (n k : ℕ) {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    binomialLevel n k θ * binomialLevel n (k + 2) θ
      ≤ binomialLevel n (k + 1) θ * binomialLevel n (k + 1) θ := by
  have hw : 0 ≤ 1 - θ := by linarith
  rcases le_or_gt (k + 2) n with hk | hk
  · have hexp : (n - k) + (n - (k + 2)) = (n - (k + 1)) + (n - (k + 1)) := by omega
    have hchoose : ((n.choose k : ℝ)) * (n.choose (k + 2) : ℝ)
        ≤ (n.choose (k + 1) : ℝ) * (n.choose (k + 1) : ℝ) := by
      exact_mod_cast choose_log_concave n k
    have hfac : (0:ℝ) ≤ θ ^ (2 * k + 2) * (1 - θ) ^ ((n - (k + 1)) + (n - (k + 1))) := by
      positivity
    calc binomialLevel n k θ * binomialLevel n (k + 2) θ
        = ((n.choose k : ℝ) * (n.choose (k + 2) : ℝ))
            * (θ ^ (2 * k + 2) * (1 - θ) ^ ((n - k) + (n - (k + 2)))) := by
          unfold binomialLevel
          rw [pow_add, pow_add]
          ring
      _ = ((n.choose k : ℝ) * (n.choose (k + 2) : ℝ))
            * (θ ^ (2 * k + 2) * (1 - θ) ^ ((n - (k + 1)) + (n - (k + 1)))) := by rw [hexp]
      _ ≤ ((n.choose (k + 1) : ℝ) * (n.choose (k + 1) : ℝ))
            * (θ ^ (2 * k + 2) * (1 - θ) ^ ((n - (k + 1)) + (n - (k + 1)))) :=
          mul_le_mul_of_nonneg_right hchoose hfac
      _ = binomialLevel n (k + 1) θ * binomialLevel n (k + 1) θ := by
          unfold binomialLevel
          rw [pow_add, pow_add]
          ring
  · have hz : n.choose (k + 2) = 0 := Nat.choose_eq_zero_of_lt (by omega)
    have : binomialLevel n (k + 2) θ = 0 := by simp [binomialLevel, hz]
    rw [this, mul_zero]
    have := binomialLevel_nonneg (n := n) (k := k + 1) h0 h1
    nlinarith

/-- **Unimodality.**  Once the reward-level masses start to decrease they keep decreasing:
the aligned policy has a single mode in the reward statistic. -/
theorem binomialLevel_decreasing_persists (n k : ℕ) {θ : ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1)
    (hpos : 0 < binomialLevel n (k + 1) θ)
    (hdec : binomialLevel n (k + 1) θ ≤ binomialLevel n k θ) :
    binomialLevel n (k + 2) θ ≤ binomialLevel n (k + 1) θ := by
  have hlc := binomialLevel_log_concave n k h0 h1
  have hnn := binomialLevel_nonneg (n := n) (k := k + 2) h0 h1
  have hmul : binomialLevel n (k + 1) θ * binomialLevel n (k + 2) θ
      ≤ binomialLevel n k θ * binomialLevel n (k + 2) θ :=
    mul_le_mul_of_nonneg_right hdec hnn
  have : binomialLevel n (k + 1) θ * binomialLevel n (k + 2) θ
      ≤ binomialLevel n (k + 1) θ * binomialLevel n (k + 1) θ := le_trans hmul hlc
  exact le_of_mul_le_mul_left this hpos

end Unimodality

section Entropy

variable {n : ℕ}

/-- Binary entropy `H(θ) = −θ log θ − (1−θ) log(1−θ)`. -/
noncomputable def binEntropy (θ : ℝ) : ℝ := -(θ * Real.log θ + (1 - θ) * Real.log (1 - θ))

/-- The Bernoulli feature policy is a probability distribution (binomial theorem). -/
theorem bernoulliSubsets_isPosDist (n : ℕ) {θ : ℝ} (h0 : 0 < θ) (h1 : θ < 1) :
    IsPosDist (bernoulliSubsets n θ) := by
  have hw : 0 < 1 - θ := by linarith
  refine ⟨fun S => by unfold bernoulliSubsets; positivity, ?_⟩
  have hsum : ∑ S : Finset (Fin n), bernoulliSubsets n θ S
      = ∑ S : Finset (Fin n), (fun k : ℕ => θ ^ k * (1 - θ) ^ (n - k)) S.card := rfl
  rw [hsum, sum_subsets_eq_sum_choose n (fun k : ℕ => θ ^ k * (1 - θ) ^ (n - k))]
  have hbin : ∑ k ∈ range (n + 1), (n.choose k : ℝ) * (θ ^ k * (1 - θ) ^ (n - k))
      = (θ + (1 - θ)) ^ n := by
    rw [add_pow]
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [hbin]
  simp

/-- **Entropy of the aligned policy.**  It is exactly `n` times the binary entropy of the
per-feature acceptance probability. -/
theorem entropy_bernoulliSubsets (n : ℕ) {θ : ℝ} (h0 : 0 < θ) (h1 : θ < 1) :
    entropy (bernoulliSubsets n θ) = n * binEntropy θ := by
  have hw : 0 < 1 - θ := by linarith
  have hdist := bernoulliSubsets_isPosDist n h0 h1
  have hlog : ∀ S : Finset (Fin n),
      bernoulliSubsets n θ S * Real.log (bernoulliSubsets n θ S)
        = Real.log θ * (bernoulliSubsets n θ S * S.card)
          + Real.log (1 - θ) * (bernoulliSubsets n θ S * ((n : ℝ) - S.card)) := by
    intro S
    have hcard : S.card ≤ n := by simpa using Finset.card_le_univ S
    have hcast : ((n - S.card : ℕ) : ℝ) = (n : ℝ) - S.card := by
      have := Nat.cast_sub (R := ℝ) hcard
      simpa using this
    have : Real.log (bernoulliSubsets n θ S)
        = (S.card : ℝ) * Real.log θ + ((n : ℝ) - S.card) * Real.log (1 - θ) := by
      unfold bernoulliSubsets
      rw [Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow, hcast]
    rw [this]
    ring
  have hsum1 : ∑ S : Finset (Fin n), bernoulliSubsets n θ S * ((n : ℝ) - S.card)
      = n - n * θ := by
    have hsplit : ∀ S : Finset (Fin n), bernoulliSubsets n θ S * ((n : ℝ) - S.card)
        = (n : ℝ) * bernoulliSubsets n θ S - bernoulliSubsets n θ S * S.card := by
      intro S; ring
    rw [Finset.sum_congr rfl fun S _ => hsplit S, Finset.sum_sub_distrib, ← Finset.mul_sum,
      hdist.2, expected_size_bernoulli n θ]
    ring
  unfold entropy binEntropy
  rw [Finset.sum_congr rfl fun S _ => hlog S, Finset.sum_add_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum, expected_size_bernoulli n θ, hsum1]
  ring

/-- The information drift from the uniform reference equals `n log 2` minus the entropy of
the policy: over the Boolean lattice, KL against the SFT policy *is* an entropy deficit. -/
theorem klDiv_uniformSubsets_eq (n : ℕ) {q : Finset (Fin n) → ℝ} (hq : IsPosDist q) :
    klDiv q (uniformSubsets n) = n * Real.log 2 - entropy q := by
  have hterm : ∀ S : Finset (Fin n),
      q S * Real.log (q S / uniformSubsets n S)
        = q S * ((n : ℝ) * Real.log 2) + q S * Real.log (q S) := by
    intro S
    have hu : uniformSubsets n S = (1 : ℝ) / 2 ^ n := rfl
    rw [hu, Real.log_div (hq.1 S).ne' (by positivity)]
    rw [Real.log_div one_ne_zero (by positivity), Real.log_one, Real.log_pow]
    ring
  unfold klDiv entropy
  rw [Finset.sum_congr rfl fun S _ => hterm S, Finset.sum_add_distrib, ← Finset.sum_mul, hq.2]
  ring

/-- **Consistency identity** (adversarial cross-check).  The information drift of the
aligned policy computed from the free energy agrees with the drift computed from the
entropy, yielding the analytic identity
`t σ(t) − log((1+eᵗ)/2) = log 2 − H(σ(t))` for `t = a/β`. -/
theorem logistic_free_energy_identity (a β : ℝ) (hβ : 0 < β) :
    a / β * logistic (a / β) - Real.log ((1 + Real.exp (a / β)) / 2)
      = Real.log 2 - binEntropy (logistic (a / β)) := by
  set θ := logistic (a / β) with hθ
  have h0 : 0 < θ := logistic_pos _
  have h1 : θ < 1 := logistic_lt_one _
  have hgib : gibbsPolicy β (sizeReward 1 a) (uniformSubsets 1) = bernoulliSubsets 1 θ :=
    gibbsPolicy_sizeReward 1 a β
  have hleft := klDiv_gibbs_uniform 1 a β hβ
  have hright := klDiv_uniformSubsets_eq 1 (bernoulliSubsets_isPosDist 1 h0 h1)
  rw [hgib] at hleft
  rw [hleft, entropy_bernoulliSubsets 1 h0 h1] at hright
  simpa using hright

end Entropy

section Temperature

theorem logistic_strictMono {s t : ℝ} (h : s < t) : logistic s < logistic t := by
  have hs : (0:ℝ) < 1 + Real.exp s := by positivity
  have ht : (0:ℝ) < 1 + Real.exp t := by positivity
  have hexp : Real.exp s < Real.exp t := Real.exp_lt_exp.mpr h
  rw [logistic, logistic, div_lt_div_iff₀ hs ht]
  nlinarith [Real.exp_pos s, Real.exp_pos t]

/-- **Reward is strictly antitone in the KL temperature.**  A stronger KL penalty (larger
`β`) strictly lowers the reward achieved by the aligned policy: the alignment/regularity
trade-off has no free lunch. -/
theorem expected_reward_strictAnti_temperature (n : ℕ) (hn : 0 < n) {a β₁ β₂ : ℝ}
    (ha : 0 < a) (h1 : 0 < β₁) (h12 : β₁ < β₂) :
    a * n * logistic (a / β₂) < a * n * logistic (a / β₁) := by
  have hlt : a / β₂ < a / β₁ := by
    have h2 : 0 < β₂ := lt_trans h1 h12
    exact div_lt_div_of_pos_left ha h1 h12
  have := logistic_strictMono hlt
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hpos : 0 < a * n := mul_pos ha hn'
  exact mul_lt_mul_of_pos_left this hpos

/-- **Mode collapse is strictly antitone in the KL temperature.**  The mass on the unique
reward-maximizing response strictly decreases as the KL penalty grows. -/
theorem top_mass_strictAnti_temperature (n : ℕ) (hn : 0 < n) {a β₁ β₂ : ℝ}
    (ha : 0 < a) (h1 : 0 < β₁) (h12 : β₁ < β₂) :
    gibbsPolicy β₂ (sizeReward n a) (uniformSubsets n) (univ : Finset (Fin n))
      < gibbsPolicy β₁ (sizeReward n a) (uniformSubsets n) (univ : Finset (Fin n)) := by
  have hlt : a / β₂ < a / β₁ := div_lt_div_of_pos_left ha h1 h12
  have hmono := logistic_strictMono hlt
  have hpos : 0 < logistic (a / β₂) := logistic_pos _
  rw [gibbsPolicy_sizeReward, gibbsPolicy_sizeReward, bernoulliSubsets_univ,
    bernoulliSubsets_univ]
  exact pow_lt_pow_left₀ hmono hpos.le hn.ne'

end Temperature

end RLHFCombinatorics