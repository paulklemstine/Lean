import Catalog.NumberTheory.RLHFGibbsVariational

/-!
# The RLHF free-energy spectrum and a von Mangoldt reward model

Building on `NumberTheory.RLHFGibbsVariational`, we study the *free energy*
`V(β) = β log Z(β)`, which by the Gibbs variational principle is the optimal value of
the KL-regularized RLHF objective at temperature `β`.

Main results:

* `RLHF.freeEnergy_antitone` — `V` is antitone in the KL coefficient `β`:
  stronger regularization can only lower the achievable value.
* `RLHF.freeEnergy_le_of_le` — `V(β) ≤ sup r` (no reward hacking beyond the reward ceiling).
* `RLHF.freeEnergy_ge_reference` — `V(β) ≥ 𝔼_p[r]` (RLHF never hurts).
* `RLHF.gibbs_ne_reference_of_nonconstant` and `RLHF.strict_improvement` — RLHF strictly
  improves on the SFT reference exactly when the reward model is non-constant.
* Number-theoretic instantiation: reward `r(n) = Λ(n)` (von Mangoldt) on the response
  space `{1, …, N}` with the uniform SFT reference.  Then the free energy is squeezed,
  `ψ(N)/N ≤ V(β) ≤ log N` (`RLHF.vonMangoldt_freeEnergy_ge_chebyshev`,
  `RLHF.vonMangoldt_freeEnergy_le_log`), and for `N ≥ 2` the lower bound is *strict*
  (`RLHF.vonMangoldt_strict_improvement`): the alignment gain is powered exactly by the
  irregularity of the primes.
-/

namespace RLHF

open Finset ArithmeticFunction

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- The free energy `V(β) = β log Z(β)`, i.e. the optimal value of the RLHF objective. -/
noncomputable def freeEnergy (β : ℝ) (r p : Ω → ℝ) : ℝ := β * Real.log (partition β r p)

theorem freeEnergy_eq_objective_gibbs {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β r p = objective β r p (gibbsPolicy β r p) :=
  (objective_gibbs hβ hp).symm

/-- **Monotonicity in the KL temperature.**  A larger KL coefficient can only decrease the
optimal value of the RLHF objective. -/
theorem freeEnergy_antitone {β₁ β₂ : ℝ} {r p : Ω → ℝ}
    (hβ₁ : 0 < β₁) (hβ₂ : 0 < β₂) (hle : β₁ ≤ β₂) (hp : IsPosDist p) :
    freeEnergy β₂ r p ≤ freeEnergy β₁ r p := by
  set q := gibbsPolicy β₂ r p with hq_def
  have hqd : IsDist q := (gibbsPolicy_isPosDist hp).isDist
  have h2 : freeEnergy β₂ r p = (∑ y, q y * r y) - β₂ * klDiv q p := by
    rw [freeEnergy_eq_objective_gibbs hβ₂ hp, objective]
  have hkl : 0 ≤ klDiv q p := kl_nonneg hqd hp
  have hmono : (∑ y, q y * r y) - β₂ * klDiv q p ≤ (∑ y, q y * r y) - β₁ * klDiv q p := by
    have : β₁ * klDiv q p ≤ β₂ * klDiv q p := mul_le_mul_of_nonneg_right hle hkl
    linarith
  have h1 : (∑ y, q y * r y) - β₁ * klDiv q p ≤ freeEnergy β₁ r p := by
    have := variational_principle (β := β₁) (r := r) hβ₁ hp hqd
    rw [objective] at this
    exact this
  linarith [h2 ▸ hmono]

/-- The optimal value never exceeds the ceiling of the reward model. -/
theorem freeEnergy_le_of_le {β M : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hM : ∀ y, r y ≤ M) : freeEnergy β r p ≤ M := by
  set q := gibbsPolicy β r p with hq_def
  have hqd : IsDist q := (gibbsPolicy_isPosDist hp).isDist
  have hrew : ∑ y, q y * r y ≤ M := by
    have hterm : ∀ y ∈ (univ : Finset Ω), q y * r y ≤ q y * M :=
      fun y _ => mul_le_mul_of_nonneg_left (hM y) (hqd.1 y)
    have := Finset.sum_le_sum hterm
    rwa [← Finset.sum_mul, hqd.2, one_mul] at this
  have hkl : 0 ≤ klDiv q p := kl_nonneg hqd hp
  have := freeEnergy_eq_objective_gibbs (β := β) (r := r) hβ hp
  rw [this, objective]
  nlinarith

/-- RLHF never hurts: the optimal value dominates the value of the SFT reference policy. -/
theorem freeEnergy_ge_reference {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    ∑ y, p y * r y ≤ freeEnergy β r p :=
  reference_le_free_energy hβ hp

/-- If the reward model is non-constant, the Gibbs policy genuinely moves away from the
reference policy. -/
theorem gibbs_ne_reference_of_nonconstant {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) {y z : Ω} (hyz : r y ≠ r z) : gibbsPolicy β r p ≠ p := by
  intro hEq
  have hZ := partition_pos (β := β) (r := r) hp
  have key : ∀ w, Real.exp (r w / β) = partition β r p := by
    intro w
    have hw : p w * Real.exp (r w / β) / partition β r p = p w := congrFun hEq w
    have hpw := hp.1 w
    rw [div_eq_iff (ne_of_gt hZ)] at hw
    exact mul_left_cancel₀ (ne_of_gt hpw) (by linarith [hw] : p w * Real.exp (r w / β) = p w * partition β r p)
  have h1 := key y
  have h2 := key z
  have hdiv : r y / β = r z / β := Real.exp_injective (h1.trans h2.symm)
  have hβ0 : β ≠ 0 := ne_of_gt hβ
  apply hyz
  field_simp at hdiv
  linarith

/-- **Strict improvement.**  Whenever the reward model is non-constant, KL-regularized
RLHF strictly beats the SFT reference, at every finite temperature. -/
theorem strict_improvement {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    {y z : Ω} (hyz : r y ≠ r z) : ∑ w, p w * r w < freeEnergy β r p := by
  have hne : p ≠ gibbsPolicy β r p :=
    fun h => gibbs_ne_reference_of_nonconstant hβ hp hyz h.symm
  have := variational_strict hβ hp hp.isDist hne
  rw [objective, (kl_eq_zero_iff hp.isDist hp).mpr rfl] at this
  simpa [freeEnergy] using this

/-! ## The von Mangoldt reward model on `{1, …, N}` -/

/-- The uniform SFT reference policy on `Fin N`. -/
noncomputable def unifRef (N : ℕ) : Fin N → ℝ := fun _ => 1 / (N : ℝ)

/-- The von Mangoldt reward: response `i` (representing the integer `i + 1`) is scored by
`Λ (i+1)`, i.e. `log p` if `i + 1` is a power of the prime `p` and `0` otherwise. -/
noncomputable def vonMangoldtReward (N : ℕ) : Fin N → ℝ := fun i => Λ ((i : ℕ) + 1)

/-- The Chebyshev `ψ`-function restricted to the response space, `ψ(N) = ∑_{n ≤ N} Λ n`. -/
noncomputable def chebyshevPsiFin (N : ℕ) : ℝ := ∑ i : Fin N, Λ ((i : ℕ) + 1)

theorem unifRef_isPosDist {N : ℕ} (hN : 0 < N) : IsPosDist (unifRef N) := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  refine ⟨fun _ => by unfold unifRef; positivity, ?_⟩
  unfold unifRef
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- The average reward of the uniform reference is exactly `ψ(N)/N`. -/
theorem unif_reward_eq_psi {N : ℕ} :
    ∑ i : Fin N, unifRef N i * vonMangoldtReward N i = chebyshevPsiFin N / (N : ℝ) := by
  unfold unifRef vonMangoldtReward chebyshevPsiFin
  rw [Finset.sum_div]
  exact Finset.sum_congr rfl (fun i _ => by ring)

/-- **Chebyshev lower bound for the RLHF free energy.**  With the von Mangoldt reward and a
uniform SFT reference, the optimal RLHF value is at least the prime-counting average
`ψ(N)/N`. -/
theorem vonMangoldt_freeEnergy_ge_chebyshev {β : ℝ} {N : ℕ} (hβ : 0 < β) (hN : 0 < N) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
    chebyshevPsiFin N / (N : ℝ) ≤ freeEnergy β (vonMangoldtReward N) (unifRef N) := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  have := freeEnergy_ge_reference (β := β) (r := vonMangoldtReward N) hβ (unifRef_isPosDist hN)
  rwa [unif_reward_eq_psi] at this

/-- **Logarithmic ceiling.**  The von Mangoldt reward is bounded by `log N` on the response
space, hence so is the optimal RLHF value: the reward model cannot be hacked past `log N`. -/
theorem vonMangoldt_freeEnergy_le_log {β : ℝ} {N : ℕ} (hβ : 0 < β) (hN : 0 < N) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
    freeEnergy β (vonMangoldtReward N) (unifRef N) ≤ Real.log N := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  refine freeEnergy_le_of_le hβ (unifRef_isPosDist hN) (fun i => ?_)
  have h1 : Λ ((i : ℕ) + 1) ≤ Real.log (((i : ℕ) + 1 : ℕ) : ℝ) := vonMangoldt_le_log
  have h2 : (((i : ℕ) + 1 : ℕ) : ℝ) ≤ (N : ℝ) := by
    have : (i : ℕ) + 1 ≤ N := i.isLt
    exact_mod_cast this
  have h3 : Real.log (((i : ℕ) + 1 : ℕ) : ℝ) ≤ Real.log N :=
    Real.log_le_log (by positivity) h2
  exact le_trans h1 h3

/-- **The primes power the alignment gain.**  For `N ≥ 2` the von Mangoldt reward is
non-constant on `{1, …, N}` (since `Λ 1 = 0 < log 2 = Λ 2`), so KL-regularized RLHF
*strictly* improves upon the uniform SFT reference at every temperature. -/
theorem vonMangoldt_strict_improvement {β : ℝ} {N : ℕ} (hβ : 0 < β) (hN : 2 ≤ N) :
    haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega)
    chebyshevPsiFin N / (N : ℝ) < freeEnergy β (vonMangoldtReward N) (unifRef N) := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp (by omega : 0 < N)
  have hN0 : 0 < N := by omega
  have hy : vonMangoldtReward N ⟨0, by omega⟩ = 0 := by
    simp [vonMangoldtReward, vonMangoldt_apply_one]
  have hz : vonMangoldtReward N ⟨1, by omega⟩ = Real.log 2 := by
    have h2 : Λ 2 = Real.log 2 := by
      simpa using vonMangoldt_apply_prime Nat.prime_two
    simpa [vonMangoldtReward] using h2
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hne : vonMangoldtReward N ⟨0, by omega⟩ ≠ vonMangoldtReward N ⟨1, by omega⟩ := by
    rw [hy, hz]; exact ne_of_lt hlog2
  have := strict_improvement (β := β) (r := vonMangoldtReward N) hβ (unifRef_isPosDist hN0) hne
  rwa [unif_reward_eq_psi] at this

end RLHF