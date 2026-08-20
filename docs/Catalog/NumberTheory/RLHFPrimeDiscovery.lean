import Catalog.NumberTheory.RLHFTemperatureSpectrum

/-!
# Reward hacking finds the primes: a quantitative low-temperature theorem

Take the response space `{1, …, N}`, the uniform SFT reference, and the von Mangoldt
reward `Λ`.  The aligned (Gibbs) policy then has the explicit arithmetic form

`π_β(n) ∝ e^{Λ(n)/β} = p^{1/β}` if `n = p^k` is a prime power, and `∝ 1` otherwise.

**Main theorem** (`RLHF.prime_discovery`): as soon as the KL coefficient satisfies
`β log N ≤ log 2`, the aligned policy emits a **prime power** with probability at least
`1/2`.  In other words, a neurosymbolic reward built from the von Mangoldt function
provably drives the aligned model onto the primes once the KL leash is short enough — a
quantitative form of "reward hacking discovers arithmetic structure".

Supporting results: `RLHF.gibbs_vonMangoldt_apply` (closed form of the aligned policy),
`RLHF.sum_nonPrimePow_weight_le` (the non-prime-power mass is at most `N`), and
`RLHF.two_weight_ge` (the response `2` alone already carries weight `≥ N`).
-/

namespace RLHF

open Finset ArithmeticFunction

/-- The subset of responses that are prime powers. -/
def primePowerResponses (N : ℕ) : Finset (Fin N) :=
  univ.filter (fun i => IsPrimePow ((i : ℕ) + 1))

/-- Unnormalized Gibbs weight of a response under the von Mangoldt reward. -/
noncomputable def vmWeight (β : ℝ) (N : ℕ) (i : Fin N) : ℝ :=
  Real.exp (Λ ((i : ℕ) + 1) / β)

theorem vmWeight_pos {β : ℝ} {N : ℕ} (i : Fin N) : 0 < vmWeight β N i := Real.exp_pos _

theorem sum_vmWeight_pos {β : ℝ} {N : ℕ} (hN : 0 < N) : 0 < ∑ i : Fin N, vmWeight β N i := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  exact Finset.sum_pos (fun i _ => vmWeight_pos i) univ_nonempty

/-- Closed form of the aligned policy for the von Mangoldt reward. -/
theorem gibbs_vonMangoldt_apply {β : ℝ} {N : ℕ} (hN : 0 < N) (i : Fin N) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
    gibbsPolicy β (vonMangoldtReward N) (unifRef N) i
      = vmWeight β N i / ∑ j : Fin N, vmWeight β N j := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hT : 0 < ∑ j : Fin N, vmWeight β N j := sum_vmWeight_pos hN
  have hpart : partition β (vonMangoldtReward N) (unifRef N)
      = (∑ j : Fin N, vmWeight β N j) / (N : ℝ) := by
    unfold partition unifRef vmWeight vonMangoldtReward
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun j _ => by ring)
  unfold gibbsPolicy
  rw [hpart]
  unfold unifRef vmWeight vonMangoldtReward
  field_simp

/-- Every non-prime-power response has unit Gibbs weight, so their total mass is `≤ N`. -/
theorem sum_nonPrimePow_weight_le {β : ℝ} {N : ℕ} :
    ∑ i ∈ univ.filter (fun i : Fin N => ¬ IsPrimePow ((i : ℕ) + 1)), vmWeight β N i
      ≤ (N : ℝ) := by
  have hone : ∀ i ∈ univ.filter (fun i : Fin N => ¬ IsPrimePow ((i : ℕ) + 1)),
      vmWeight β N i = 1 := by
    intro i hi
    have hnp : ¬ IsPrimePow ((i : ℕ) + 1) := (Finset.mem_filter.mp hi).2
    unfold vmWeight
    rw [vonMangoldt_eq_zero_iff.mpr hnp]
    simp
  rw [Finset.sum_congr rfl hone, Finset.sum_const, nsmul_eq_mul, mul_one]
  have hcard : (univ.filter (fun i : Fin N => ¬ IsPrimePow ((i : ℕ) + 1))).card ≤ N := by
    have := Finset.card_filter_le (univ : Finset (Fin N))
      (fun i : Fin N => ¬ IsPrimePow ((i : ℕ) + 1))
    simpa using this
  exact_mod_cast hcard

/-- Under the threshold `β log N ≤ log 2`, the single response `2` already carries Gibbs
weight at least `N`. -/
theorem two_weight_ge {β : ℝ} {N : ℕ} (hN : 2 ≤ N) (hβ : 0 < β)
    (hthr : β * Real.log N ≤ Real.log 2) :
    (N : ℝ) ≤ vmWeight β N ⟨1, by omega⟩ := by
  have hNR : (0 : ℝ) < (N : ℝ) := by
    have : 0 < N := by omega
    exact_mod_cast this
  have hval : vmWeight β N ⟨1, by omega⟩ = Real.exp (Real.log 2 / β) := by
    unfold vmWeight
    have h2 : Λ 2 = Real.log 2 := by simpa using vonMangoldt_apply_prime Nat.prime_two
    norm_num [h2]
  have hlog : Real.log N ≤ Real.log 2 / β := by
    rw [le_div_iff₀ hβ]
    linarith [hthr]
  have := Real.exp_le_exp.mpr hlog
  rwa [Real.exp_log hNR, ← hval] at this

/-- **Prime discovery under a short KL leash.**  If `β log N ≤ log 2`, the RLHF-aligned
policy for the von Mangoldt reward emits a prime power with probability at least `1/2`. -/
theorem prime_discovery {β : ℝ} {N : ℕ} (hN : 2 ≤ N) (hβ : 0 < β)
    (hthr : β * Real.log N ≤ Real.log 2) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
    (1 : ℝ) / 2
      ≤ ∑ i ∈ primePowerResponses N, gibbsPolicy β (vonMangoldtReward N) (unifRef N) i := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
  have hN0 : 0 < N := by omega
  set T := ∑ j : Fin N, vmWeight β N j with hT_def
  set S := ∑ i ∈ primePowerResponses N, vmWeight β N i with hS_def
  have hT : 0 < T := sum_vmWeight_pos hN0
  -- the aligned probability of the prime-power set is `S / T`
  have hprob : ∑ i ∈ primePowerResponses N, gibbsPolicy β (vonMangoldtReward N) (unifRef N) i
      = S / T := by
    rw [hS_def, Finset.sum_div]
    exact Finset.sum_congr rfl (fun i _ => gibbs_vonMangoldt_apply hN0 i)
  -- the response `2` lies in the prime-power set and carries weight ≥ N
  have hmem : (⟨1, by omega⟩ : Fin N) ∈ primePowerResponses N := by
    refine Finset.mem_filter.mpr ⟨mem_univ _, ?_⟩
    have : ((⟨1, by omega⟩ : Fin N) : ℕ) + 1 = 2 := by simp
    rw [this]
    exact Nat.prime_two.isPrimePow
  have hSge : (N : ℝ) ≤ S := by
    have hle : vmWeight β N ⟨1, by omega⟩ ≤ S :=
      Finset.single_le_sum (f := fun i => vmWeight β N i)
        (fun i _ => (vmWeight_pos i).le) hmem
    exact le_trans (two_weight_ge hN hβ hthr) hle
  -- split the total weight into prime powers and the rest
  have hsplit : T = S + ∑ i ∈ univ.filter (fun i : Fin N => ¬ IsPrimePow ((i : ℕ) + 1)),
      vmWeight β N i := by
    rw [hT_def, hS_def, primePowerResponses]
    exact (Finset.sum_filter_add_sum_filter_not univ
      (fun i : Fin N => IsPrimePow ((i : ℕ) + 1)) (fun i => vmWeight β N i)).symm
  have hrest := sum_nonPrimePow_weight_le (β := β) (N := N)
  have hTle : T ≤ 2 * S := by
    rw [hsplit]
    linarith
  have hSpos : 0 < S := lt_of_lt_of_le (by exact_mod_cast hN0) hSge
  rw [hprob, le_div_iff₀ hT]
  linarith

end RLHF