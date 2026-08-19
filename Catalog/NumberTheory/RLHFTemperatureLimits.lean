import NumberTheory.RLHFTemperatureSpectrum

/-!
# Zero- and infinite-temperature limits of the RLHF free energy

Continuing `NumberTheory.RLHFTemperatureSpectrum`, we quantify the two endpoints of the
free-energy spectrum `V(β) = β log Z(β)`:

* `RLHF.kl_budget` — the aligned policy cannot collapse: `β · KL(π_β ‖ p) ≤ max r − min r`.
* `RLHF.freeEnergy_ge_point` — `V(β) ≥ r y + β log p y` for every response `y`.
* `RLHF.tendsto_freeEnergy_zero_temperature` — as `β → 0⁺`, `V(β) → max r`
  (greedy reward maximization).
* `RLHF.freeEnergy_le_high_temperature` and `RLHF.tendsto_freeEnergy_high_temperature`
  — as `β → ∞`, `V(β) → 𝔼_p[r]` (the SFT reference), with the explicit rate
  `V(β) ≤ min r + e^{(max r − min r)/β} (𝔼_p[r] − min r)`.

Arithmetic payoff (`RLHF.vonMangoldt_zero_temperature_limit`): for the von Mangoldt reward
on `{1, …, N}` the zero-temperature limit of the RLHF free energy equals `log P` where `P`
is the **largest prime ≤ N**, while the infinite-temperature limit is the Chebyshev average
`ψ(N)/N`.  The whole alignment spectrum of this reward model is thus pinned between two
classical prime-counting quantities.
-/

namespace RLHF

open Finset ArithmeticFunction Filter Topology

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Pointwise lower bounds and the KL budget -/

omit [Nonempty Ω] in
/-- Keeping only one response in the partition function gives a lower bound on the
free energy. -/
theorem freeEnergy_ge_point {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) (y : Ω) :
    r y + β * Real.log (p y) ≤ freeEnergy β r p := by
  have hterm : p y * Real.exp (r y / β) ≤ partition β r p := by
    refine Finset.single_le_sum (f := fun w => p w * Real.exp (r w / β)) ?_ (mem_univ y)
    intro w _
    have := (hp.1 w).le
    positivity
  have hpos : 0 < p y * Real.exp (r y / β) := by
    have := hp.1 y; positivity
  have hlog : Real.log (p y * Real.exp (r y / β)) ≤ Real.log (partition β r p) :=
    Real.log_le_log hpos hterm
  rw [Real.log_mul (ne_of_gt (hp.1 y)) (Real.exp_ne_zero _), Real.log_exp] at hlog
  have hmul := mul_le_mul_of_nonneg_left hlog hβ.le
  have hexpand : β * (Real.log (p y) + r y / β) = β * Real.log (p y) + r y := by
    field_simp
  unfold freeEnergy
  linarith [hexpand ▸ hmul]

/-- **No policy collapse.**  The KL divergence of the aligned policy from the reference
obeys the budget `β · KL ≤ max r − min r`. -/
theorem kl_budget {β m M : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hm : ∀ y, m ≤ r y) (hM : ∀ y, r y ≤ M) :
    β * klDiv (gibbsPolicy β r p) p ≤ M - m := by
  set q := gibbsPolicy β r p with hq_def
  have hqd : IsDist q := (gibbsPolicy_isPosDist hp).isDist
  have hval : objective β r p q = freeEnergy β r p := (freeEnergy_eq_objective_gibbs hβ hp).symm
  have href : ∑ y, p y * r y ≤ freeEnergy β r p := freeEnergy_ge_reference hβ hp
  have hup : ∑ y, q y * r y ≤ M := by
    have hterm : ∀ y ∈ (univ : Finset Ω), q y * r y ≤ q y * M :=
      fun y _ => mul_le_mul_of_nonneg_left (hM y) (hqd.1 y)
    have := Finset.sum_le_sum hterm
    rwa [← Finset.sum_mul, hqd.2, one_mul] at this
  have hlow : m ≤ ∑ y, p y * r y := by
    have hterm : ∀ y ∈ (univ : Finset Ω), p y * m ≤ p y * r y :=
      fun y _ => mul_le_mul_of_nonneg_left (hm y) (hp.1 y).le
    have := Finset.sum_le_sum hterm
    rwa [← Finset.sum_mul, hp.2, one_mul] at this
  rw [objective] at hval
  linarith

/-! ## 2. The zero-temperature (greedy) limit -/

/-- The maximal reward over the response space. -/
noncomputable def rewardMax (r : Ω → ℝ) : ℝ := univ.sup' univ_nonempty r

theorem le_rewardMax (r : Ω → ℝ) (y : Ω) : r y ≤ rewardMax r :=
  Finset.le_sup' r (mem_univ y)

theorem exists_rewardMax (r : Ω → ℝ) : ∃ y, r y = rewardMax r := by
  obtain ⟨y, _, hy⟩ := Finset.exists_mem_eq_sup' (univ_nonempty (α := Ω)) r
  exact ⟨y, hy.symm⟩

theorem freeEnergy_le_rewardMax {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β r p ≤ rewardMax r :=
  freeEnergy_le_of_le hβ hp (le_rewardMax r)

/-- Quantitative greedy bound: at low temperature the free energy is within
`β log (1 / p y⋆)` of the maximal reward. -/
theorem rewardMax_sub_le_freeEnergy {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    {y : Ω} (hy : r y = rewardMax r) :
    rewardMax r + β * Real.log (p y) ≤ freeEnergy β r p := by
  have h := freeEnergy_ge_point (r := r) hβ hp y
  rwa [hy] at h

/-- **Zero-temperature limit.**  As the KL coefficient vanishes, the optimal RLHF value
converges to the maximal reward: alignment degenerates into greedy reward maximization. -/
theorem tendsto_freeEnergy_zero_temperature {r p : Ω → ℝ} (hp : IsPosDist p) :
    Tendsto (fun β => freeEnergy β r p) (𝓝[>] (0 : ℝ)) (𝓝 (rewardMax r)) := by
  obtain ⟨y, hy⟩ := exists_rewardMax r
  have hlow : Tendsto (fun β : ℝ => rewardMax r + β * Real.log (p y)) (𝓝[>] (0 : ℝ))
      (𝓝 (rewardMax r)) := by
    have hc : Tendsto (fun β : ℝ => rewardMax r + β * Real.log (p y)) (𝓝 (0 : ℝ))
        (𝓝 (rewardMax r + 0 * Real.log (p y))) :=
      tendsto_const_nhds.add (tendsto_id.mul tendsto_const_nhds)
    simp only [zero_mul, add_zero] at hc
    exact hc.mono_left nhdsWithin_le_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact rewardMax_sub_le_freeEnergy hβ hp hy
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_le_rewardMax hβ hp

/-! ## 3. The high-temperature (reference) limit -/

/-- Quantitative high-temperature bound. -/
theorem freeEnergy_le_high_temperature {β m M : ℝ} {r p : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) (hm : ∀ y, m ≤ r y) (hM : ∀ y, r y ≤ M) :
    freeEnergy β r p ≤ m + Real.exp ((M - m) / β) * ((∑ y, p y * r y) - m) := by
  set C := Real.exp ((M - m) / β) with hC
  set E := ∑ y, p y * r y with hE
  have hCpos : 0 < C := Real.exp_pos _
  have hEm : m ≤ E := by
    have hterm : ∀ y ∈ (univ : Finset Ω), p y * m ≤ p y * r y :=
      fun y _ => mul_le_mul_of_nonneg_left (hm y) (hp.1 y).le
    have := Finset.sum_le_sum hterm
    rwa [← Finset.sum_mul, hp.2, one_mul] at this
  -- pointwise bound `exp (r y / β) ≤ exp (m/β) (1 + ((r y - m)/β) C)`
  have hpt : ∀ y, Real.exp (r y / β)
      ≤ Real.exp (m / β) * (1 + ((r y - m) / β) * C) := by
    intro y
    have hu0 : 0 ≤ (r y - m) / β := div_nonneg (by linarith [hm y]) hβ.le
    have huM : (r y - m) / β ≤ (M - m) / β := by
      have h1 : r y - m ≤ M - m := by linarith [hM y]
      gcongr
    have hkey : Real.exp ((r y - m) / β) ≤ 1 + ((r y - m) / β) * Real.exp ((r y - m) / β) := by
      have h := Real.add_one_le_exp (-((r y - m) / β))
      rw [Real.exp_neg] at h
      have hpos : 0 < Real.exp ((r y - m) / β) := Real.exp_pos _
      have h2 := mul_le_mul_of_nonneg_left h hpos.le
      rw [mul_inv_cancel₀ (ne_of_gt hpos)] at h2
      nlinarith
    have hmono : Real.exp ((r y - m) / β) ≤ C := Real.exp_le_exp.mpr huM
    have h1 : Real.exp ((r y - m) / β) ≤ 1 + ((r y - m) / β) * C := by
      nlinarith
    have hexpand : Real.exp (r y / β) = Real.exp (m / β) * Real.exp ((r y - m) / β) := by
      rw [← Real.exp_add]
      congr 1
      field_simp
      ring
    rw [hexpand]
    exact mul_le_mul_of_nonneg_left h1 (Real.exp_pos _).le
  have hZ : partition β r p ≤ Real.exp (m / β) * (1 + ((E - m) / β) * C) := by
    have hsum : partition β r p
        ≤ ∑ y, p y * (Real.exp (m / β) * (1 + ((r y - m) / β) * C)) := by
      unfold partition
      exact Finset.sum_le_sum (fun y _ => mul_le_mul_of_nonneg_left (hpt y) (hp.1 y).le)
    refine le_trans hsum (le_of_eq ?_)
    have hsplit : ∀ y ∈ (univ : Finset Ω),
        p y * (Real.exp (m / β) * (1 + ((r y - m) / β) * C))
          = Real.exp (m / β) * p y
            + (Real.exp (m / β) * C / β) * (p y * r y)
            - (Real.exp (m / β) * C * m / β) * p y := by
      intro y _
      field_simp
      ring
    rw [Finset.sum_congr rfl hsplit, Finset.sum_sub_distrib, Finset.sum_add_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, hp.2, ← hE]
    field_simp
    ring
  have hW : 0 < 1 + ((E - m) / β) * C := by
    have : 0 ≤ ((E - m) / β) * C := mul_nonneg (div_nonneg (by linarith) hβ.le) hCpos.le
    linarith
  have hlogZ : Real.log (partition β r p) ≤ m / β + ((E - m) / β) * C := by
    have h1 : Real.log (partition β r p)
        ≤ Real.log (Real.exp (m / β) * (1 + ((E - m) / β) * C)) :=
      Real.log_le_log (partition_pos hp) hZ
    rw [Real.log_mul (Real.exp_ne_zero _) (ne_of_gt hW), Real.log_exp] at h1
    have h2 : Real.log (1 + ((E - m) / β) * C) ≤ ((E - m) / β) * C := by
      have := Real.log_le_sub_one_of_pos hW
      linarith
    linarith
  have hfin := mul_le_mul_of_nonneg_left hlogZ hβ.le
  have hcalc : β * (m / β + ((E - m) / β) * C) = m + C * (E - m) := by
    field_simp
  unfold freeEnergy
  linarith [hcalc ▸ hfin]

/-- **High-temperature limit.**  As the KL coefficient grows, the optimal RLHF value
converges back to the value of the SFT reference policy. -/
theorem tendsto_freeEnergy_high_temperature {m M : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p)
    (hm : ∀ y, m ≤ r y) (hM : ∀ y, r y ≤ M) :
    Tendsto (fun β => freeEnergy β r p) atTop (𝓝 (∑ y, p y * r y)) := by
  set E := ∑ y, p y * r y with hE
  have hdiv : Tendsto (fun β : ℝ => (M - m) / β) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop tendsto_id
  have hexp : Tendsto (fun β : ℝ => Real.exp ((M - m) / β)) atTop (𝓝 1) := by
    have := (Real.continuous_exp.tendsto 0).comp hdiv
    simpa using this
  have hup : Tendsto (fun β : ℝ => m + Real.exp ((M - m) / β) * (E - m)) atTop (𝓝 E) := by
    have h : Tendsto (fun β : ℝ => m + Real.exp ((M - m) / β) * (E - m)) atTop
        (𝓝 (m + 1 * (E - m))) :=
      Filter.Tendsto.add tendsto_const_nhds (hexp.mul tendsto_const_nhds)
    have heq : m + 1 * (E - m) = E := by ring
    rwa [heq] at h
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hup ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with β hβ
    exact freeEnergy_ge_reference hβ hp
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with β hβ
    exact freeEnergy_le_high_temperature hβ hp hm hM

/-! ## 4. Arithmetic endpoint: the largest prime below `N` -/

/-- For `N ≥ 2` the maximum of the von Mangoldt reward on `{1, …, N}` is `log P`, where `P`
is the largest prime `≤ N`. -/
theorem vonMangoldt_rewardMax {N : ℕ} (hN : 2 ≤ N) :
    ∃ P : ℕ, P.Prime ∧ P ≤ N ∧ (∀ q : ℕ, q.Prime → q ≤ N → q ≤ P) ∧
      haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
      rewardMax (vonMangoldtReward N) = Real.log P := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
  classical
  set S : Finset ℕ := (Finset.range (N + 1)).filter Nat.Prime with hS
  have h2S : 2 ∈ S := by
    simp [hS, Nat.prime_two]
    omega
  have hSne : S.Nonempty := ⟨2, h2S⟩
  set P := S.max' hSne with hP
  have hPmem : P ∈ S := S.max'_mem hSne
  have hPprime : P.Prime := by
    have := Finset.mem_filter.mp hPmem
    exact this.2
  have hPle : P ≤ N := by
    have := Finset.mem_filter.mp hPmem
    have := Finset.mem_range.mp this.1
    omega
  have hPmax : ∀ q : ℕ, q.Prime → q ≤ N → q ≤ P := by
    intro q hq hqN
    refine Finset.le_max' S q (Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), hq⟩)
  have hP2 : 2 ≤ P := hPprime.two_le
  have hlogP : 0 < Real.log P := Real.log_pos (by exact_mod_cast hP2)
  refine ⟨P, hPprime, hPle, hPmax, le_antisymm ?_ ?_⟩
  · -- every reward value is at most `log P`
    refine Finset.sup'_le _ _ (fun i _ => ?_)
    unfold vonMangoldtReward
    by_cases hpp : IsPrimePow ((i : ℕ) + 1)
    · have hval : Λ ((i : ℕ) + 1) = Real.log (Nat.minFac ((i : ℕ) + 1)) := by
        rw [vonMangoldt_apply, if_pos hpp]
      have hge2 : 2 ≤ (i : ℕ) + 1 := hpp.two_le
      have hne1 : ((i : ℕ) + 1) ≠ 1 := by omega
      have hmf : (Nat.minFac ((i : ℕ) + 1)).Prime := Nat.minFac_prime hne1
      have hmfle : Nat.minFac ((i : ℕ) + 1) ≤ N := by
        have h1 : Nat.minFac ((i : ℕ) + 1) ≤ (i : ℕ) + 1 := Nat.minFac_le (by omega)
        have h2 : (i : ℕ) + 1 ≤ N := i.isLt
        omega
      have := hPmax _ hmf hmfle
      rw [hval]
      apply Real.log_le_log (by exact_mod_cast hmf.pos)
      exact_mod_cast this
    · rw [vonMangoldt_apply, if_neg hpp]
      exact hlogP.le
  · -- the value `log P` is attained at the response `P`
    have hlt : P - 1 < N := by omega
    have hidx : ((⟨P - 1, hlt⟩ : Fin N) : ℕ) + 1 = P := by simp; omega
    have hval : vonMangoldtReward N ⟨P - 1, hlt⟩ = Real.log P := by
      unfold vonMangoldtReward
      rw [hidx, vonMangoldt_apply_prime hPprime]
    rw [← hval]
    exact le_rewardMax _ _

/-- **The alignment spectrum of the von Mangoldt reward is pinned by the primes.**
As `β → 0⁺` the optimal RLHF value converges to `log P`, `P` the largest prime `≤ N`. -/
theorem vonMangoldt_zero_temperature_limit {N : ℕ} (hN : 2 ≤ N) :
    ∃ P : ℕ, P.Prime ∧ P ≤ N ∧ (∀ q : ℕ, q.Prime → q ≤ N → q ≤ P) ∧
      haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
      Tendsto (fun β => freeEnergy β (vonMangoldtReward N) (unifRef N)) (𝓝[>] (0 : ℝ))
        (𝓝 (Real.log P)) := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
  obtain ⟨P, hP, hPle, hPmax, hsup⟩ := vonMangoldt_rewardMax hN
  refine ⟨P, hP, hPle, hPmax, ?_⟩
  have := tendsto_freeEnergy_zero_temperature (r := vonMangoldtReward N)
    (unifRef_isPosDist (by omega : 0 < N))
  rwa [hsup] at this

/-- As `β → ∞` the optimal value returns to the Chebyshev average `ψ(N)/N`. -/
theorem vonMangoldt_high_temperature_limit {N : ℕ} (hN : 0 < N) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
    Tendsto (fun β => freeEnergy β (vonMangoldtReward N) (unifRef N)) atTop
      (𝓝 (chebyshevPsiFin N / (N : ℝ))) := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  have hm : ∀ i : Fin N, (0 : ℝ) ≤ vonMangoldtReward N i := fun i => vonMangoldt_nonneg
  have hM : ∀ i : Fin N, vonMangoldtReward N i ≤ Real.log N := by
    intro i
    have h1 : Λ ((i : ℕ) + 1) ≤ Real.log (((i : ℕ) + 1 : ℕ) : ℝ) := vonMangoldt_le_log
    have h2 : (((i : ℕ) + 1 : ℕ) : ℝ) ≤ (N : ℝ) := by
      have : (i : ℕ) + 1 ≤ N := i.isLt
      exact_mod_cast this
    exact le_trans h1 (Real.log_le_log (by positivity) h2)
  have := tendsto_freeEnergy_high_temperature (m := 0) (M := Real.log N)
    (unifRef_isPosDist hN) hm hM
  rwa [unif_reward_eq_psi] at this

end RLHF