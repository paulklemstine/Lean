import NumberTheory.RLHFPrimeDiscovery

/-!
# Monotonicity of aligned mass: colder alignment means more prime powers

`RLHF.prime_discovery` shows that below the KL threshold `β log N ≤ log 2` the aligned
policy of the von Mangoldt reward puts at least half of its mass on prime powers.  That is a
one-sided statement at a specific temperature.  Here we prove the *structural* fact behind a
genuine phase-transition picture: the aligned mass of any **upper level set of the reward**
is antitone in the KL coefficient `β`.

The proof is a rearrangement (Chebyshev/FKG-type) argument at the level of the unnormalized
Gibbs weights: for `y` in the level set, `z` outside it, and `β₁ ≤ β₂`,

`w_{β₂}(y) w_{β₁}(z) ≤ w_{β₁}(y) w_{β₂}(z)`,

because `(r y − r z)(1/β₂ − 1/β₁) ≤ 0`.  Summing the pairwise inequality over `A × Aᶜ`
gives `S(β₂) R(β₁) ≤ S(β₁) R(β₂)`, which is exactly the claimed monotonicity of
`S / (S + R)`.

Main results (all `sorry`-free):

* `RLHF.gibbs_upperSet_antitone` — for every threshold `c`, the aligned probability of
  `{y : c ≤ r y}` is antitone in `β`.
* `RLHF.vonMangoldt_primePower_mass_antitone` — the prime-power mass of the von Mangoldt
  aligned policy on `{1, …, N}` only increases as the KL leash is shortened.
* `RLHF.prime_discovery_downward_closed` — combined with `RLHF.prime_discovery`: the set of
  KL coefficients at which the aligned policy is at least half supported on prime powers is
  downward closed and contains the whole interval `(0, log 2 / log N]`.
-/

namespace RLHF

open Finset ArithmeticFunction

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. The rearrangement inequality for Gibbs weights -/

/-- The unnormalized Gibbs weight. -/
noncomputable def gibbsWeight (β : ℝ) (r p : Ω → ℝ) (y : Ω) : ℝ := p y * Real.exp (r y / β)

omit [Nonempty Ω] in
theorem gibbsWeight_pos {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) (y : Ω) :
    0 < gibbsWeight β r p y := by
  have := hp.1 y
  unfold gibbsWeight
  positivity

omit [Nonempty Ω] in
theorem partition_eq_sum_gibbsWeight {β : ℝ} {r p : Ω → ℝ} :
    partition β r p = ∑ y, gibbsWeight β r p y := rfl

omit [Nonempty Ω] in
/-- The pairwise rearrangement inequality: raising the temperature transfers weight from the
high-reward response `y` to the low-reward response `z`. -/
theorem gibbsWeight_cross_le {β₁ β₂ : ℝ} {r p : Ω → ℝ} (hβ₁ : 0 < β₁) (h12 : β₁ ≤ β₂)
    (hp : IsPosDist p) {y z : Ω} (hyz : r z ≤ r y) :
    gibbsWeight β₂ r p y * gibbsWeight β₁ r p z
      ≤ gibbsWeight β₁ r p y * gibbsWeight β₂ r p z := by
  have hβ₂ : 0 < β₂ := lt_of_lt_of_le hβ₁ h12
  have hinv : β₂⁻¹ ≤ β₁⁻¹ := inv_anti₀ hβ₁ h12
  have hexp : r y / β₂ + r z / β₁ ≤ r y / β₁ + r z / β₂ := by
    have hkey : (r y - r z) * (β₂⁻¹ - β₁⁻¹) ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos (by linarith) (by linarith)
    rw [div_eq_mul_inv, div_eq_mul_inv, div_eq_mul_inv, div_eq_mul_inv]
    nlinarith [hkey]
  have hpy := (hp.1 y).le
  have hpz := (hp.1 z).le
  unfold gibbsWeight
  have hle : Real.exp (r y / β₂) * Real.exp (r z / β₁)
      ≤ Real.exp (r y / β₁) * Real.exp (r z / β₂) := by
    rw [← Real.exp_add, ← Real.exp_add]
    exact Real.exp_le_exp.mpr hexp
  calc p y * Real.exp (r y / β₂) * (p z * Real.exp (r z / β₁))
      = (p y * p z) * (Real.exp (r y / β₂) * Real.exp (r z / β₁)) := by ring
    _ ≤ (p y * p z) * (Real.exp (r y / β₁) * Real.exp (r z / β₂)) := by
        exact mul_le_mul_of_nonneg_left hle (by positivity)
    _ = p y * Real.exp (r y / β₁) * (p z * Real.exp (r z / β₂)) := by ring

/-! ## 2. Antitonicity of the aligned mass of an upper level set -/

/-- **Colder alignment concentrates on high reward.**  For every threshold `c`, the aligned
probability of the upper level set `{y : c ≤ r y}` is antitone in the KL coefficient. -/
theorem gibbs_upperSet_antitone {β₁ β₂ c : ℝ} {r p : Ω → ℝ} (hβ₁ : 0 < β₁) (h12 : β₁ ≤ β₂)
    (hp : IsPosDist p) :
    ∑ y ∈ univ.filter (fun y => c ≤ r y), gibbsPolicy β₂ r p y
      ≤ ∑ y ∈ univ.filter (fun y => c ≤ r y), gibbsPolicy β₁ r p y := by
  have hβ₂ : 0 < β₂ := lt_of_lt_of_le hβ₁ h12
  set A := univ.filter (fun y => c ≤ r y) with hA
  set Ac := univ.filter (fun y => ¬ c ≤ r y) with hAc
  set S : ℝ → ℝ := fun β => ∑ y ∈ A, gibbsWeight β r p y with hS
  set R : ℝ → ℝ := fun β => ∑ y ∈ Ac, gibbsWeight β r p y with hR
  have hZ : ∀ β : ℝ, partition β r p = S β + R β := by
    intro β
    rw [partition_eq_sum_gibbsWeight, hS, hR, hA, hAc]
    exact (Finset.sum_filter_add_sum_filter_not univ (fun y => c ≤ r y)
      (fun y => gibbsWeight β r p y)).symm
  have hSnonneg : ∀ β : ℝ, 0 ≤ S β :=
    fun β => Finset.sum_nonneg (fun y _ => (gibbsWeight_pos hp y).le)
  have hRnonneg : ∀ β : ℝ, 0 ≤ R β :=
    fun β => Finset.sum_nonneg (fun y _ => (gibbsWeight_pos hp y).le)
  have hZ₁ : 0 < partition β₁ r p := partition_pos hp
  have hZ₂ : 0 < partition β₂ r p := partition_pos hp
  have hmass : ∀ β : ℝ, ∑ y ∈ A, gibbsPolicy β r p y = S β / partition β r p := by
    intro β
    rw [hS, Finset.sum_div]
    exact Finset.sum_congr rfl (fun y _ => rfl)
  -- the rearrangement inequality, summed over `A × Aᶜ`
  have hcross : S β₂ * R β₁ ≤ S β₁ * R β₂ := by
    rw [hS, hR, Finset.sum_mul_sum, Finset.sum_mul_sum]
    refine Finset.sum_le_sum (fun y hy => Finset.sum_le_sum (fun z hz => ?_))
    have hyc : c ≤ r y := (Finset.mem_filter.1 hy).2
    have hzc : ¬ c ≤ r z := (Finset.mem_filter.1 hz).2
    exact gibbsWeight_cross_le hβ₁ h12 hp (by linarith [not_le.1 hzc])
  rw [hmass, hmass, div_le_div_iff₀ hZ₂ hZ₁, hZ β₁, hZ β₂]
  nlinarith [hcross, hSnonneg β₁, hSnonneg β₂, hRnonneg β₁, hRnonneg β₂]

/-! ## 3. The von Mangoldt instantiation -/

/-- The prime-power responses are exactly the responses of von Mangoldt reward at least
`log 2`. -/
theorem primePowerResponses_eq_upperSet {N : ℕ} :
    primePowerResponses N
      = univ.filter (fun i : Fin N => Real.log 2 ≤ vonMangoldtReward N i) := by
  ext i
  simp only [primePowerResponses, Finset.mem_filter, Finset.mem_univ, true_and,
    vonMangoldtReward]
  constructor
  · intro hpp
    rw [vonMangoldt_apply, if_pos hpp]
    have h2 : 2 ≤ ((i : ℕ) + 1).minFac :=
      (Nat.minFac_prime (by rintro h1; rw [h1] at hpp; exact not_isPrimePow_one hpp)).two_le
    exact Real.log_le_log (by norm_num) (by exact_mod_cast h2)
  · intro hle
    by_contra hnp
    rw [vonMangoldt_eq_zero_iff.mpr hnp] at hle
    exact absurd hle (not_le.2 (Real.log_pos (by norm_num)))

/-- **The prime-power mass is antitone in the KL coefficient.**  Shortening the KL leash can
only increase the probability that the aligned model emits a prime power. -/
theorem vonMangoldt_primePower_mass_antitone {β₁ β₂ : ℝ} {N : ℕ} (hN : 0 < N) (hβ₁ : 0 < β₁)
    (h12 : β₁ ≤ β₂) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
    ∑ i ∈ primePowerResponses N, gibbsPolicy β₂ (vonMangoldtReward N) (unifRef N) i
      ≤ ∑ i ∈ primePowerResponses N, gibbsPolicy β₁ (vonMangoldtReward N) (unifRef N) i := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  rw [primePowerResponses_eq_upperSet]
  exact gibbs_upperSet_antitone hβ₁ h12 (unifRef_isPosDist hN)

/-- **The discovery region is downward closed.**  If at some KL coefficient `β₂` the aligned
policy already emits prime powers with probability at least `1/2`, then so does every colder
alignment `β₁ ≤ β₂`; by `RLHF.prime_discovery` this region contains `(0, log 2 / log N]`. -/
theorem prime_discovery_downward_closed {β₁ β₂ : ℝ} {N : ℕ} (hN : 0 < N) (hβ₁ : 0 < β₁)
    (h12 : β₁ ≤ β₂)
    (hhalf : haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
      (1 : ℝ) / 2 ≤ ∑ i ∈ primePowerResponses N,
        gibbsPolicy β₂ (vonMangoldtReward N) (unifRef N) i) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
    (1 : ℝ) / 2 ≤ ∑ i ∈ primePowerResponses N,
      gibbsPolicy β₁ (vonMangoldtReward N) (unifRef N) i :=
  le_trans hhalf (vonMangoldt_primePower_mass_antitone hN hβ₁ h12)

/-! ## 4. The high-temperature side: the discovery region is bounded -/

/-- **Weak alignment cannot discover the primes.**  Once the KL coefficient reaches `log N`,
the prime-power mass of the aligned policy is at most `e` times the density of prime powers
in `{1, …, N}`.  Together with `RLHF.vonMangoldt_primePower_mass_antitone` and
`RLHF.prime_discovery` this brackets the discovery threshold `β⋆(N)` from both sides. -/
theorem vonMangoldt_primePower_mass_high_temperature {β : ℝ} {N : ℕ} (hN : 2 ≤ N)
    (hβ : Real.log N ≤ β) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
    ∑ i ∈ primePowerResponses N, gibbsPolicy β (vonMangoldtReward N) (unifRef N) i
      ≤ Real.exp 1 * ((primePowerResponses N).card : ℝ) / N := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
  have hN0 : 0 < N := by omega
  have hNR : (1 : ℝ) < (N : ℝ) := by exact_mod_cast (by omega : 1 < N)
  have hlogN : 0 < Real.log N := Real.log_pos hNR
  have hβpos : 0 < β := lt_of_lt_of_le hlogN hβ
  set T := ∑ j : Fin N, vmWeight β N j with hT_def
  set S := ∑ i ∈ primePowerResponses N, vmWeight β N i with hS_def
  have hT : 0 < T := sum_vmWeight_pos hN0
  have hprob : ∑ i ∈ primePowerResponses N, gibbsPolicy β (vonMangoldtReward N) (unifRef N) i
      = S / T := by
    rw [hS_def, Finset.sum_div]
    exact Finset.sum_congr rfl (fun i _ => gibbs_vonMangoldt_apply hN0 i)
  -- every response has von Mangoldt reward in `[0, log N]`, hence weight in `[1, e]`
  have hupper : ∀ i : Fin N, vmWeight β N i ≤ Real.exp 1 := by
    intro i
    have h1 : Λ ((i : ℕ) + 1) ≤ Real.log (((i : ℕ) + 1 : ℕ) : ℝ) := vonMangoldt_le_log
    have h2 : (((i : ℕ) + 1 : ℕ) : ℝ) ≤ (N : ℝ) := by
      have : (i : ℕ) + 1 ≤ N := i.isLt
      exact_mod_cast this
    have h3 : Λ ((i : ℕ) + 1) ≤ Real.log N :=
      le_trans h1 (Real.log_le_log (by positivity) h2)
    have h4 : Λ ((i : ℕ) + 1) / β ≤ 1 := by
      rw [div_le_one hβpos]
      linarith
    exact Real.exp_le_exp.mpr h4
  have hlower : ∀ i : Fin N, (1 : ℝ) ≤ vmWeight β N i := by
    intro i
    have h0 : 0 ≤ Λ ((i : ℕ) + 1) := vonMangoldt_nonneg
    have : (0 : ℝ) ≤ Λ ((i : ℕ) + 1) / β := by positivity
    simpa [vmWeight] using Real.exp_le_exp.mpr this
  have hSle : S ≤ ((primePowerResponses N).card : ℝ) * Real.exp 1 := by
    have := Finset.sum_le_sum (f := fun i => vmWeight β N i)
      (g := fun _ : Fin N => Real.exp 1) (s := primePowerResponses N)
      (fun i _ => hupper i)
    rwa [Finset.sum_const, nsmul_eq_mul] at this
  have hTge : (N : ℝ) ≤ T := by
    have := Finset.sum_le_sum (f := fun _ : Fin N => (1 : ℝ))
      (g := fun i => vmWeight β N i) (s := (univ : Finset (Fin N))) (fun i _ => hlower i)
    simpa [hT_def, Finset.card_univ] using this
  rw [hprob, div_le_div_iff₀ hT (by positivity : (0 : ℝ) < (N : ℝ))]
  have hSnonneg : 0 ≤ S := Finset.sum_nonneg (fun i _ => (vmWeight_pos i).le)
  have hcard : (0 : ℝ) ≤ ((primePowerResponses N).card : ℝ) := by positivity
  nlinarith [hSle, hTge, Real.exp_pos (1 : ℝ), hSnonneg, hcard]

end RLHF