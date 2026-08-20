import Combinatorics.RLHFTensorization

/-!
# RLHF alignment over the Boolean lattice: binomial laws, monotone policies, reward hacking

We instantiate the KL-regularized RLHF/InstructGPT objective
`J(q) = 𝔼_q[r] − β KL(q ‖ p)` (formalized in `Speculative.AutoResearch.RLHFGibbsVariational`)
on the **Boolean lattice** `Finset (Fin n)`: a response is a set of "features"
(rule firings of a neurosymbolic verifier, retrieved facts, checked constraints, …),
the reference policy is uniform on the `2ⁿ` responses, and the neurosymbolic reward
counts satisfied features, `r S = a · |S|`.

Main results (all `sorry`-free):

* `sum_subsets_eq_sum_choose` — the combinatorial transfer principle: any statistic of a
  subset that depends only on its cardinality can be summed over the lattice by
  binomial coefficients.
* `partition_sizeReward` — the RLHF partition function *is* a binomial-theorem evaluation:
  `Z = ((1 + e^{a/β})/2)ⁿ`.
* `gibbsPolicy_sizeReward` — the aligned policy is exactly a product of i.i.d. Bernoulli
  features with parameter `σ(a/β)` (the logistic/softmax link).
* `gibbs_level_mass` — the induced law of the *reward statistic* `|S|` is
  `Binomial(n, σ(a/β))`: alignment turns a counting reward into a binomial concentration.
* `expected_size_bernoulli`, `expected_reward_gibbs` — exact mean of the aligned policy,
  via a purely combinatorial identity `k·C(n,k) = n·C(n-1,k-1)`.
* `klDiv_gibbs_uniform` — the exact information drift, read off the free-energy identity.
* `bernoulliSubsets_monotone` — for `a ≥ 0` the aligned policy is a **monotone (increasing)
  measure on the Boolean lattice**: alignment is order-preserving on features.
* `gibbs_top_mass_ge` — a quantitative **reward-hacking bound**: the aligned policy puts
  mass at least `1 − n e^{−a/β}` on the single maximal response, so as the KL penalty
  `β → 0` the policy collapses onto the argmax at an exponential rate in `a/β`.
-/

namespace RLHFCombinatorics

open Finset RLHF

section BooleanLattice

variable {n : ℕ}

/-! ## 1. The combinatorial transfer principle -/

/-- **Transfer principle.**  A statistic of a subset of `Fin n` depending only on its
cardinality is summed over the whole Boolean lattice by binomial coefficients. -/
theorem sum_subsets_eq_sum_choose (n : ℕ) (f : ℕ → ℝ) :
    ∑ S : Finset (Fin n), f S.card = ∑ k ∈ range (n + 1), (n.choose k : ℝ) * f k := by
  rw [← Finset.powerset_univ, Finset.sum_powerset]
  simp only [Finset.card_univ, Fintype.card_fin]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [Finset.sum_congr rfl (fun t ht => by rw [(Finset.mem_powersetCard.mp ht).2] :
    ∀ t ∈ powersetCard k (univ : Finset (Fin n)), f t.card = f k)]
  rw [Finset.sum_const, Finset.card_powersetCard]
  simp [Finset.card_univ, mul_comm]

/-- The generating function of the Boolean lattice: `∑_{S ⊆ [n]} x^{|S|} = (1+x)^n`. -/
theorem sum_pow_card (n : ℕ) (x : ℝ) : ∑ S : Finset (Fin n), x ^ S.card = (1 + x) ^ n := by
  rw [sum_subsets_eq_sum_choose, show (1 + x) = (x + 1) from add_comm 1 x, add_pow]
  exact Finset.sum_congr rfl fun k _ => by simp [mul_comm]

/-! ## 2. The counting reward on the Boolean lattice -/

/-- The uniform reference (SFT) policy on the `2ⁿ` subsets of `Fin n`. -/
noncomputable def uniformSubsets (n : ℕ) : Finset (Fin n) → ℝ := fun _ => (1 : ℝ) / 2 ^ n

/-- The neurosymbolic counting reward `r S = a · |S|`: `a` reward per satisfied feature. -/
def sizeReward (n : ℕ) (a : ℝ) : Finset (Fin n) → ℝ := fun S => a * S.card

/-- The logistic (sigmoid) link `σ t = eᵗ / (1 + eᵗ)`. -/
noncomputable def logistic (t : ℝ) : ℝ := Real.exp t / (1 + Real.exp t)

/-- The i.i.d. Bernoulli(`θ`) feature policy on subsets: `π S = θ^{|S|} (1-θ)^{n-|S|}`. -/
noncomputable def bernoulliSubsets (n : ℕ) (θ : ℝ) : Finset (Fin n) → ℝ :=
  fun S => θ ^ S.card * (1 - θ) ^ (n - S.card)

theorem logistic_pos (t : ℝ) : 0 < logistic t := by
  have h : (0:ℝ) < 1 + Real.exp t := by positivity
  exact div_pos (Real.exp_pos t) h

theorem one_sub_logistic (t : ℝ) : 1 - logistic t = 1 / (1 + Real.exp t) := by
  have h : (0:ℝ) < 1 + Real.exp t := by positivity
  rw [logistic]
  field_simp
  ring

theorem logistic_lt_one (t : ℝ) : logistic t < 1 := by
  have h : (0:ℝ) < 1 + Real.exp t := by positivity
  have := one_sub_logistic t
  have hpos : 0 < 1 / (1 + Real.exp t) := by positivity
  linarith

theorem uniformSubsets_isPosDist (n : ℕ) : IsPosDist (uniformSubsets n) := by
  refine ⟨fun _ => by simp only [uniformSubsets]; positivity, ?_⟩
  simp [uniformSubsets, Finset.sum_const, Fintype.card_finset]

/-- **The RLHF partition function on the Boolean lattice is a binomial evaluation.** -/
theorem partition_sizeReward (n : ℕ) (a β : ℝ) :
    partition β (sizeReward n a) (uniformSubsets n)
      = ((1 + Real.exp (a / β)) / 2) ^ n := by
  have hterm : ∀ S : Finset (Fin n),
      uniformSubsets n S * Real.exp (sizeReward n a S / β)
        = (1 / 2 ^ n) * (Real.exp (a / β)) ^ S.card := by
    intro S
    have : sizeReward n a S / β = (S.card : ℝ) * (a / β) := by
      simp [sizeReward]; ring
    rw [this, Real.exp_nat_mul]
    simp [uniformSubsets]
  rw [partition, Finset.sum_congr rfl fun S _ => hterm S, ← Finset.mul_sum,
    sum_pow_card n (Real.exp (a / β))]
  rw [div_pow]
  ring

/-- **Alignment on the Boolean lattice = i.i.d. Bernoulli features.**  The KL-regularized
optimal policy for a counting reward is the product of `n` independent Bernoulli features
with success probability `σ(a/β)`. -/
theorem gibbsPolicy_sizeReward (n : ℕ) (a β : ℝ) :
    gibbsPolicy β (sizeReward n a) (uniformSubsets n)
      = bernoulliSubsets n (logistic (a / β)) := by
  set E := Real.exp (a / β) with hE
  have hEpos : 0 < E := Real.exp_pos _
  have h1E : (0:ℝ) < 1 + E := by positivity
  funext S
  have hcard : S.card ≤ n := by
    simpa using (Finset.card_le_univ S)
  have hsplit : (S.card) + (n - S.card) = n := Nat.add_sub_cancel' hcard
  have hnum : uniformSubsets n S * Real.exp (sizeReward n a S / β)
      = (1 / 2 ^ n) * E ^ S.card := by
    have : sizeReward n a S / β = (S.card : ℝ) * (a / β) := by
      simp [sizeReward]; ring
    rw [this, Real.exp_nat_mul]
    simp [uniformSubsets, hE]
  have hbern : bernoulliSubsets n (logistic (a / β)) S = E ^ S.card / (1 + E) ^ n := by
    have hpow : (1 + E) ^ n = (1 + E) ^ S.card * (1 + E) ^ (n - S.card) := by
      rw [← pow_add, hsplit]
    rw [bernoulliSubsets, one_sub_logistic, logistic, div_pow, div_pow, one_pow, hpow]
    field_simp
    rw [← hE]
    ring
  rw [gibbsPolicy, hnum, partition_sizeReward, hbern, div_pow]
  field_simp
  ring

theorem bernoulliSubsets_eq_gibbs (n : ℕ) (a β : ℝ) :
    IsPosDist (bernoulliSubsets n (logistic (a / β))) := by
  rw [← gibbsPolicy_sizeReward]
  exact gibbsPolicy_isPosDist (uniformSubsets_isPosDist n)

/-! ## 3. The induced law of the reward statistic is binomial -/

/-- The level set `{S : |S| = k}` of the Boolean lattice. -/
theorem level_eq_powersetCard (n k : ℕ) :
    (univ : Finset (Finset (Fin n))).filter (fun S => S.card = k)
      = powersetCard k (univ : Finset (Fin n)) := by
  ext S
  simp [Finset.mem_powersetCard, Finset.subset_univ]

/-- **Binomial law of the aligned policy.**  Under the RLHF-optimal policy the reward
statistic `|S|` is distributed as `Binomial(n, σ(a/β))`. -/
theorem gibbs_level_mass (n k : ℕ) (a β : ℝ) :
    ∑ S ∈ (univ : Finset (Finset (Fin n))).filter (fun S => S.card = k),
        gibbsPolicy β (sizeReward n a) (uniformSubsets n) S
      = (n.choose k : ℝ) * (logistic (a / β)) ^ k * (1 - logistic (a / β)) ^ (n - k) := by
  rw [gibbsPolicy_sizeReward, level_eq_powersetCard]
  have hconst : ∀ S ∈ powersetCard k (univ : Finset (Fin n)),
      bernoulliSubsets n (logistic (a / β)) S
        = (logistic (a / β)) ^ k * (1 - logistic (a / β)) ^ (n - k) := by
    intro S hS
    rw [bernoulliSubsets, (Finset.mem_powersetCard.mp hS).2]
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, Finset.card_powersetCard]
  simp [Finset.card_univ, mul_assoc]

/-! ## 4. The mean of the aligned policy -/

/-- **Combinatorial mean identity.**  `∑ₖ k C(n,k) xᵏ y^{n-k} = n x (x+y)^{n-1}`,
proved from the absorption identity `k·C(n,k) = n·C(n-1,k-1)`. -/
theorem binomial_mean (n : ℕ) (x y : ℝ) :
    ∑ k ∈ range (n + 1), (k : ℝ) * (n.choose k : ℝ) * x ^ k * y ^ (n - k)
      = n * x * (x + y) ^ (n - 1) := by
  cases n with
  | zero => simp
  | succ m =>
      have hshift : ∀ k ∈ range (m + 1),
          ((k + 1 : ℕ) : ℝ) * (((m + 1).choose (k + 1) : ℕ) : ℝ) * x ^ (k + 1)
              * y ^ (m + 1 - (k + 1))
            = ((m : ℝ) + 1) * x * ((m.choose k : ℝ) * x ^ k * y ^ (m - k)) := by
        intro k _
        have hnat : ((m + 1) * m.choose k : ℕ) = ((m + 1).choose (k + 1) * (k + 1) : ℕ) :=
          Nat.add_one_mul_choose_eq m k
        have hcast : ((m : ℝ) + 1) * (m.choose k : ℝ)
            = (((m + 1).choose (k + 1) : ℕ) : ℝ) * ((k : ℝ) + 1) := by
          exact_mod_cast hnat
        have hpow : m + 1 - (k + 1) = m - k := by omega
        rw [hpow]
        push_cast
        linear_combination (-(x ^ (k + 1) * y ^ (m - k))) * hcast
      have hbin : ∑ k ∈ range (m + 1), (m.choose k : ℝ) * x ^ k * y ^ (m - k)
          = (x + y) ^ m := by
        rw [add_pow]
        exact Finset.sum_congr rfl fun k _ => by ring
      rw [Finset.sum_range_succ' (fun k => (k : ℝ) * ((m + 1).choose k : ℝ) * x ^ k
        * y ^ (m + 1 - k)) (m + 1)]
      rw [Finset.sum_congr rfl hshift, ← Finset.mul_sum, hbin]
      push_cast
      ring

/-- **Exact mean of the Bernoulli feature policy**: `𝔼|S| = n θ`. -/
theorem expected_size_bernoulli (n : ℕ) (θ : ℝ) :
    ∑ S : Finset (Fin n), bernoulliSubsets n θ S * S.card = n * θ := by
  have h1 : ∑ S : Finset (Fin n), bernoulliSubsets n θ S * S.card
      = ∑ S : Finset (Fin n), (fun k : ℕ => θ ^ k * (1 - θ) ^ (n - k) * (k : ℝ)) S.card := rfl
  rw [h1, sum_subsets_eq_sum_choose n (fun k : ℕ => θ ^ k * (1 - θ) ^ (n - k) * (k : ℝ))]
  rw [Finset.sum_congr rfl (fun k _ => by ring :
    ∀ k ∈ range (n + 1), (n.choose k : ℝ) * (θ ^ k * (1 - θ) ^ (n - k) * (k : ℝ))
      = (k : ℝ) * (n.choose k : ℝ) * θ ^ k * (1 - θ) ^ (n - k))]
  rw [binomial_mean n θ (1 - θ)]
  simp

/-- **Exact expected reward of the aligned policy**: `𝔼[r] = a n σ(a/β)`. -/
theorem expected_reward_gibbs (n : ℕ) (a β : ℝ) :
    ∑ S : Finset (Fin n), gibbsPolicy β (sizeReward n a) (uniformSubsets n) S
        * sizeReward n a S
      = a * n * logistic (a / β) := by
  rw [gibbsPolicy_sizeReward]
  have hterm : ∀ S : Finset (Fin n),
      bernoulliSubsets n (logistic (a / β)) S * sizeReward n a S
        = a * (bernoulliSubsets n (logistic (a / β)) S * S.card) := by
    intro S; simp [sizeReward]; ring
  rw [Finset.sum_congr rfl fun S _ => hterm S, ← Finset.mul_sum,
    expected_size_bernoulli n (logistic (a / β))]
  ring

/-! ## 5. Free energy and information drift -/

/-- The optimal RLHF value on the Boolean lattice: `n β log((1 + e^{a/β})/2)`. -/
theorem freeEnergy_sizeReward (n : ℕ) (a β : ℝ) :
    freeEnergy β (sizeReward n a) (uniformSubsets n)
      = n * (β * Real.log ((1 + Real.exp (a / β)) / 2)) := by
  have hpos : (0:ℝ) < (1 + Real.exp (a / β)) / 2 := by positivity
  rw [freeEnergy, partition_sizeReward, Real.log_pow]
  ring

/-- **Exact information drift.**  The KL divergence of the aligned policy from the uniform
reference is `n (a σ(a/β)/β − log((1+e^{a/β})/2))`; it is extensive in the number of
features, matching `klDiv_gibbs_piDist`. -/
theorem klDiv_gibbs_uniform (n : ℕ) (a β : ℝ) (hβ : 0 < β) :
    klDiv (gibbsPolicy β (sizeReward n a) (uniformSubsets n)) (uniformSubsets n)
      = n * (a / β * logistic (a / β) - Real.log ((1 + Real.exp (a / β)) / 2)) := by
  have hobj := objective_gibbs (β := β) (r := sizeReward n a) (p := uniformSubsets n)
    hβ (uniformSubsets_isPosDist n)
  rw [objective, expected_reward_gibbs, partition_sizeReward, Real.log_pow] at hobj
  have hkey : β * klDiv (gibbsPolicy β (sizeReward n a) (uniformSubsets n)) (uniformSubsets n)
      = β * (n * (a / β * logistic (a / β) - Real.log ((1 + Real.exp (a / β)) / 2))) := by
    field_simp
    field_simp at hobj
    linarith
  exact mul_left_cancel₀ hβ.ne' hkey

/-! ## 6. Order structure: the aligned policy is monotone on the lattice -/

theorem logistic_ge_half {t : ℝ} (ht : 0 ≤ t) : 1 / 2 ≤ logistic t := by
  have h1 : (1:ℝ) ≤ Real.exp t := Real.one_le_exp ht
  have h2 : (0:ℝ) < 1 + Real.exp t := by positivity
  rw [logistic, le_div_iff₀ h2]
  linarith

/-- **Alignment is order-preserving.**  For a nonnegative counting reward the aligned
policy is a monotone measure on the Boolean lattice: adding a satisfied feature never
decreases the probability of a response. -/
theorem bernoulliSubsets_monotone {θ : ℝ} (hθ : 1 / 2 ≤ θ) (hθ1 : θ ≤ 1) {S T : Finset (Fin n)}
    (hST : S ⊆ T) : bernoulliSubsets n θ S ≤ bernoulliSubsets n θ T := by
  have hw0 : 0 ≤ 1 - θ := by linarith
  have hwθ : 1 - θ ≤ θ := by linarith
  have hθ0 : 0 ≤ θ := by linarith
  have hst : S.card ≤ T.card := Finset.card_le_card hST
  have htn : T.card ≤ n := by simpa using Finset.card_le_univ T
  have hd : n - S.card = (n - T.card) + (T.card - S.card) := by omega
  have hcard : T.card = S.card + (T.card - S.card) := by omega
  have hpow : (1 - θ) ^ (T.card - S.card) ≤ θ ^ (T.card - S.card) :=
    pow_le_pow_left₀ hw0 hwθ _
  calc bernoulliSubsets n θ S
      = θ ^ S.card * (1 - θ) ^ (n - T.card) * (1 - θ) ^ (T.card - S.card) := by
        rw [bernoulliSubsets, hd, pow_add]; ring
    _ ≤ θ ^ S.card * (1 - θ) ^ (n - T.card) * θ ^ (T.card - S.card) := by
        have : (0:ℝ) ≤ θ ^ S.card * (1 - θ) ^ (n - T.card) := by positivity
        exact mul_le_mul_of_nonneg_left hpow this
    _ = bernoulliSubsets n θ T := by
        rw [bernoulliSubsets,
          show θ ^ T.card = θ ^ S.card * θ ^ (T.card - S.card) by
            rw [← pow_add, Nat.add_sub_cancel' hst]]
        ring

/-! ## 7. Reward hacking: exponential collapse onto the maximizer -/

theorem one_sub_logistic_le_exp_neg (t : ℝ) : 1 - logistic t ≤ Real.exp (-t) := by
  have hE : (0:ℝ) < Real.exp t := Real.exp_pos t
  have h : Real.exp t ≤ 1 + Real.exp t := by linarith
  rw [one_sub_logistic, Real.exp_neg, one_div]
  exact inv_anti₀ hE h

theorem bernoulliSubsets_univ (n : ℕ) (θ : ℝ) :
    bernoulliSubsets n θ (univ : Finset (Fin n)) = θ ^ n := by
  simp [bernoulliSubsets, Finset.card_univ]

/-- **Quantitative reward hacking / mode collapse.**  With reward `a|S|`, `a ≥ 0`, the
aligned policy places mass at least `1 − n e^{−a/β}` on the *single* maximal response
`{1,…,n}`.  As the KL penalty `β → 0⁺` the policy therefore collapses onto the reward
argmax at an exponential rate in `a/β`, even though it started uniform on `2ⁿ`
responses. -/
theorem gibbs_top_mass_ge (n : ℕ) {a β : ℝ} (ha : 0 ≤ a) (hβ : 0 < β) :
    1 - n * Real.exp (-(a / β))
      ≤ gibbsPolicy β (sizeReward n a) (uniformSubsets n) (univ : Finset (Fin n)) := by
  have ht : 0 ≤ a / β := div_nonneg ha hβ.le
  set θ := logistic (a / β) with hθdef
  have hθ1 : θ ≤ 1 := (logistic_lt_one _).le
  have hθ0 : 0 ≤ θ := (logistic_pos _).le
  have hbern : 1 + (n : ℝ) * (θ - 1) ≤ (1 + (θ - 1)) ^ n :=
    one_add_mul_le_pow (by linarith) n
  have hexp : 1 - θ ≤ Real.exp (-(a / β)) := one_sub_logistic_le_exp_neg (a / β)
  have hmul : (n : ℝ) * (1 - θ) ≤ n * Real.exp (-(a / β)) :=
    mul_le_mul_of_nonneg_left hexp (by positivity)
  rw [gibbsPolicy_sizeReward, bernoulliSubsets_univ]
  have : (1 + (θ - 1)) ^ n = θ ^ n := by rw [show 1 + (θ - 1) = θ by ring]
  linarith [this ▸ hbern]

end BooleanLattice

end RLHFCombinatorics