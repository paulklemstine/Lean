import Mathlib

/-!
# The KL-regularized RLHF objective: exact Gibbs variational principle

We formalize, over a finite response space `Ω`, the standard RLHF (InstructGPT / PPO)
objective with a KL penalty and a pretraining mix-in (PTX):

```
J(q) = 𝔼_{y∼q}[r y]  −  β · KL(q ‖ p)  +  γ · 𝔼_{y∼d}[log q y]
```

where `p` is the SFT reference policy, `r` the (neurosymbolic) reward model, `β > 0`
the KL temperature, `d` the pretraining distribution and `γ ≥ 0` the PTX coefficient.

Main results (all `sorry`-free):

* `RLHF.kl_nonneg` / `RLHF.kl_eq_zero_iff` — Gibbs' inequality with its equality case.
* `RLHF.objective_eq_free_energy_sub_kl` — the *exact* algebraic identity
  `J(q) = β log Z − β KL(q ‖ π_β)`, where `π_β` is the Gibbs (softmax-tilted) policy
  and `Z` the partition function.
* `RLHF.variational_principle` — `J(q) ≤ β log Z` for every policy `q`, with
  `RLHF.objective_gibbs` giving equality at `q = π_β`, and
  `RLHF.variational_strict` the strict inequality off the optimum.
* `RLHF.ptx_upper_bound` and `RLHF.alignment_tax` — the PTX-augmented objective is
  bounded by `β log Z − γ H(d)`, and the bound is *unattainable* (strictly) unless the
  Gibbs policy coincides with the pretraining distribution: a formal "alignment tax".
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Probability distributions on a finite response space -/

/-- `IsDist p`: `p` is a probability distribution on the finite type `Ω`. -/
def IsDist (p : Ω → ℝ) : Prop := (∀ y, 0 ≤ p y) ∧ ∑ y, p y = 1

/-- `IsPosDist p`: `p` is a strictly positive probability distribution. -/
def IsPosDist (p : Ω → ℝ) : Prop := (∀ y, 0 < p y) ∧ ∑ y, p y = 1

theorem IsPosDist.isDist {p : Ω → ℝ} (hp : IsPosDist p) : IsDist p :=
  ⟨fun y => (hp.1 y).le, hp.2⟩

/-! ## 2. Kullback–Leibler divergence and the RLHF objective -/

/-- Kullback–Leibler divergence `KL(q ‖ g) = ∑ q y log (q y / g y)`. -/
noncomputable def klDiv (q g : Ω → ℝ) : ℝ := ∑ y, q y * Real.log (q y / g y)

/-- The partition function `Z = ∑ p y exp (r y / β)` of the KL-regularized problem. -/
noncomputable def partition (β : ℝ) (r p : Ω → ℝ) : ℝ := ∑ y, p y * Real.exp (r y / β)

/-- The Gibbs (softmax-tilted) policy `π_β y = p y exp (r y / β) / Z`. -/
noncomputable def gibbsPolicy (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => p y * Real.exp (r y / β) / partition β r p

/-- The RLHF objective: expected reward minus `β` times the KL penalty against the
reference (SFT) policy `p`. -/
noncomputable def objective (β : ℝ) (r p q : Ω → ℝ) : ℝ :=
  (∑ y, q y * r y) - β * klDiv q p

/-- The PTX-augmented objective: RLHF objective plus `γ 𝔼_{x∼d} log q x`. -/
noncomputable def objectivePTX (β γ : ℝ) (r p d q : Ω → ℝ) : ℝ :=
  objective β r p q + γ * ∑ y, d y * Real.log (q y)

/-- Shannon entropy `H(d) = -∑ d y log (d y)`. -/
noncomputable def entropy (d : Ω → ℝ) : ℝ := -∑ y, d y * Real.log (d y)

/-! ## 3. The pointwise Gibbs inequality -/

/-- Pointwise Gibbs inequality: `t - g ≤ t log (t / g)` for `t ≥ 0 < g`. -/
theorem log_mul_div_ge {t g : ℝ} (ht : 0 ≤ t) (hg : 0 < g) :
    t - g ≤ t * Real.log (t / g) := by
  rcases eq_or_lt_of_le ht with h | h
  · simp [← h]; linarith
  · have hle : Real.log (g / t) ≤ g / t - 1 := Real.log_le_sub_one_of_pos (by positivity)
    have hmul : t * Real.log (g / t) ≤ t * (g / t - 1) := by
      exact mul_le_mul_of_nonneg_left hle ht
    have hgt : t * (g / t - 1) = g - t := by field_simp
    have hsym : Real.log (g / t) = -Real.log (t / g) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hsym, hgt] at hmul
    linarith

/-- Strict pointwise Gibbs inequality when `t ≠ g`. -/
theorem log_mul_div_gt {t g : ℝ} (ht : 0 ≤ t) (hg : 0 < g) (hne : t ≠ g) :
    t - g < t * Real.log (t / g) := by
  rcases eq_or_lt_of_le ht with h | h
  · simp [← h]; linarith
  · have hne' : g / t ≠ 1 := by
      intro hc
      apply hne
      field_simp at hc
      linarith
    have hlt : Real.log (g / t) < g / t - 1 :=
      Real.log_lt_sub_one_of_pos (by positivity) hne'
    have hmul : t * Real.log (g / t) < t * (g / t - 1) := mul_lt_mul_of_pos_left hlt h
    have hgt : t * (g / t - 1) = g - t := by field_simp
    have hsym : Real.log (g / t) = -Real.log (t / g) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hsym, hgt] at hmul
    linarith

/-! ## 4. Gibbs' inequality: `KL ≥ 0`, with equality iff the policies agree -/

theorem kl_nonneg {q g : Ω → ℝ} (hq : IsDist q) (hg : IsPosDist g) : 0 ≤ klDiv q g := by
  have hterm : ∀ y ∈ (univ : Finset Ω), q y - g y ≤ q y * Real.log (q y / g y) :=
    fun y _ => log_mul_div_ge (hq.1 y) (hg.1 y)
  have := Finset.sum_le_sum hterm
  rw [Finset.sum_sub_distrib, hq.2, hg.2] at this
  simpa [klDiv] using this

theorem kl_eq_zero_iff {q g : Ω → ℝ} (hq : IsDist q) (hg : IsPosDist g) :
    klDiv q g = 0 ↔ q = g := by
  constructor
  · intro h0
    by_contra hne
    obtain ⟨y₀, hy₀⟩ : ∃ y, q y ≠ g y := by
      by_contra hc
      exact hne (funext fun y => not_not.mp (fun h => hc ⟨y, h⟩))
    -- the pointwise slack at `y₀` is strictly positive
    have hterm : ∀ y ∈ (univ : Finset Ω), q y - g y ≤ q y * Real.log (q y / g y) :=
      fun y _ => log_mul_div_ge (hq.1 y) (hg.1 y)
    have hstrict : q y₀ - g y₀ < q y₀ * Real.log (q y₀ / g y₀) :=
      log_mul_div_gt (hq.1 y₀) (hg.1 y₀) hy₀
    have hsum : ∑ y, (q y - g y) < ∑ y, q y * Real.log (q y / g y) :=
      Finset.sum_lt_sum hterm ⟨y₀, mem_univ _, hstrict⟩
    rw [Finset.sum_sub_distrib, hq.2, hg.2] at hsum
    simp only [sub_self] at hsum
    rw [klDiv] at h0
    linarith
  · rintro rfl
    have hz : ∀ y ∈ (univ : Finset Ω), q y * Real.log (q y / q y) = 0 := by
      intro y _
      rcases eq_or_lt_of_le (hg.1 y).le with h | h
      · simp [← h]
      · rw [div_self (ne_of_gt h)]; simp
    rw [klDiv, Finset.sum_congr rfl hz, Finset.sum_const_zero]

/-! ## 5. The Gibbs policy is a genuine probability distribution -/

theorem partition_pos {β : ℝ} {r p : Ω → ℝ} [Nonempty Ω] (hp : IsPosDist p) :
    0 < partition β r p := by
  apply Finset.sum_pos
  · intro y _; have := hp.1 y; positivity
  · exact univ_nonempty

theorem gibbsPolicy_isPosDist {β : ℝ} {r p : Ω → ℝ} [Nonempty Ω] (hp : IsPosDist p) :
    IsPosDist (gibbsPolicy β r p) := by
  have hZ := partition_pos (β := β) (r := r) hp
  refine ⟨fun y => ?_, ?_⟩
  · have := hp.1 y
    unfold gibbsPolicy
    positivity
  · unfold gibbsPolicy
    rw [← Finset.sum_div]
    have hnum : ∑ y, p y * Real.exp (r y / β) = partition β r p := rfl
    rw [hnum, div_self (ne_of_gt hZ)]

/-! ## 6. The exact free-energy decomposition -/

/-- The key algebraic identity: the RLHF objective equals the free energy `β log Z`
minus `β` times the KL divergence to the Gibbs policy.  This is an *exact* identity,
not an inequality. -/
theorem objective_eq_free_energy_sub_kl {β : ℝ} {r p q : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hp : IsPosDist p) (hq : IsDist q) :
    objective β r p q
      = β * Real.log (partition β r p) - β * klDiv q (gibbsPolicy β r p) := by
  have hZ := partition_pos (β := β) (r := r) hp
  have key : ∀ y ∈ (univ : Finset Ω),
      q y * Real.log (q y / gibbsPolicy β r p y)
        = q y * Real.log (q y / p y) - q y * (r y / β) + q y * Real.log (partition β r p) := by
    intro y _
    rcases eq_or_lt_of_le (hq.1 y) with h | h
    · simp [← h]
    · have hpy := hp.1 y
      have hgy : gibbsPolicy β r p y = p y * Real.exp (r y / β) / partition β r p := rfl
      rw [hgy]
      rw [Real.log_div (ne_of_gt h) (by positivity)]
      rw [Real.log_div (by positivity) (ne_of_gt hZ)]
      rw [Real.log_mul (ne_of_gt hpy) (Real.exp_ne_zero _), Real.log_exp]
      rw [Real.log_div (ne_of_gt h) (ne_of_gt hpy)]
      ring
  have hsum : klDiv q (gibbsPolicy β r p)
      = klDiv q p - (∑ y, q y * r y) / β + Real.log (partition β r p) := by
    unfold klDiv
    rw [Finset.sum_congr rfl key]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, hq.2, one_mul]
    have : ∑ y, q y * (r y / β) = (∑ y, q y * r y) / β := by
      rw [Finset.sum_div]
      exact Finset.sum_congr rfl (fun y _ => by ring)
    rw [this]
  rw [hsum, objective]
  field_simp
  ring

/-- The optimal value of the KL-regularized RLHF objective is the free energy. -/
theorem objective_gibbs {β : ℝ} {r p : Ω → ℝ} [Nonempty Ω] (hβ : 0 < β) (hp : IsPosDist p) :
    objective β r p (gibbsPolicy β r p) = β * Real.log (partition β r p) := by
  rw [objective_eq_free_energy_sub_kl hβ hp (gibbsPolicy_isPosDist hp).isDist]
  rw [(kl_eq_zero_iff (gibbsPolicy_isPosDist hp).isDist (gibbsPolicy_isPosDist hp)).mpr rfl]
  ring

/-- **Gibbs variational principle for RLHF.**  No policy beats the free energy. -/
theorem variational_principle {β : ℝ} {r p q : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hp : IsPosDist p) (hq : IsDist q) :
    objective β r p q ≤ β * Real.log (partition β r p) := by
  rw [objective_eq_free_energy_sub_kl hβ hp hq]
  have := kl_nonneg hq (gibbsPolicy_isPosDist (β := β) (r := r) hp)
  nlinarith

/-- The Gibbs policy is the *unique* maximizer: any other policy is strictly worse. -/
theorem variational_strict {β : ℝ} {r p q : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hp : IsPosDist p) (hq : IsDist q) (hne : q ≠ gibbsPolicy β r p) :
    objective β r p q < β * Real.log (partition β r p) := by
  rw [objective_eq_free_energy_sub_kl hβ hp hq]
  have hkl : klDiv q (gibbsPolicy β r p) ≠ 0 := by
    intro h
    exact hne ((kl_eq_zero_iff hq (gibbsPolicy_isPosDist hp)).mp h)
  have hge := kl_nonneg hq (gibbsPolicy_isPosDist (β := β) (r := r) hp)
  have : 0 < klDiv q (gibbsPolicy β r p) := lt_of_le_of_ne hge (Ne.symm hkl)
  nlinarith

/-- Any policy is at most as good as the optimum: the optimum dominates the reference. -/
theorem reference_le_free_energy {β : ℝ} {r p : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hp : IsPosDist p) :
    ∑ y, p y * r y ≤ β * Real.log (partition β r p) := by
  have h := variational_principle (β := β) (r := r) hβ hp hp.isDist
  have hkl : klDiv p p = 0 := (kl_eq_zero_iff hp.isDist hp).mpr rfl
  rw [objective, hkl] at h
  simpa using h

/-! ## 7. The PTX mix-in and the alignment tax -/

/-- Splitting of the KL divergence into (negative) entropy and cross entropy. -/
theorem klDiv_eq_neg_entropy_sub_cross {d q : Ω → ℝ} (hd : IsDist d) (hq : IsPosDist q) :
    klDiv d q = -entropy d - ∑ y, d y * Real.log (q y) := by
  have hsplit : klDiv d q = (∑ y, d y * Real.log (d y)) - ∑ y, d y * Real.log (q y) := by
    unfold klDiv
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl (fun y _ => ?_)
    rcases eq_or_lt_of_le (hd.1 y) with h | h
    · simp [← h]
    · rw [Real.log_div (ne_of_gt h) (ne_of_gt (hq.1 y))]; ring
  unfold entropy
  linarith

/-- Cross-entropy bound: `∑ d log q ≤ ∑ d log d` for distributions `d`, `q` with `q > 0`. -/
theorem cross_entropy_le {d q : Ω → ℝ} (hd : IsDist d) (hq : IsPosDist q) :
    ∑ y, d y * Real.log (q y) ≤ ∑ y, d y * Real.log (d y) := by
  have hkl := kl_nonneg hd hq
  have hsplit := klDiv_eq_neg_entropy_sub_cross hd hq
  unfold entropy at hsplit
  linarith

/-- Upper bound for the full RLHF+PTX objective: free energy minus `γ` times the
entropy of the pretraining distribution. -/
theorem ptx_upper_bound {β γ : ℝ} {r p d q : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hγ : 0 ≤ γ) (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q) :
    objectivePTX β γ r p d q ≤ β * Real.log (partition β r p) - γ * entropy d := by
  have h1 := variational_principle (β := β) (r := r) hβ hp hq.isDist
  have h2 := cross_entropy_le hd hq
  have h3 : γ * ∑ y, d y * Real.log (q y) ≤ γ * ∑ y, d y * Real.log (d y) :=
    mul_le_mul_of_nonneg_left h2 hγ
  unfold objectivePTX entropy
  linarith

/-- **Alignment tax.**  If the Gibbs policy differs from the pretraining distribution,
the combined RLHF+PTX bound is *never* attained: the two objectives are in strict
tension, so PTX necessarily costs reward-plus-KL performance (and vice versa). -/
theorem alignment_tax {β γ : ℝ} {r p d q : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hγ : 0 < γ) (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q)
    (hsep : gibbsPolicy β r p ≠ d) :
    objectivePTX β γ r p d q < β * Real.log (partition β r p) - γ * entropy d := by
  by_cases hqg : q = gibbsPolicy β r p
  · -- then `q ≠ d`, so the PTX term is strictly suboptimal
    have hqd : q ≠ d := by rw [hqg]; exact hsep
    have h1 := variational_principle (β := β) (r := r) hβ hp hq.isDist
    have hklpos : 0 < klDiv d q := by
      have hge := kl_nonneg hd hq
      rcases eq_or_lt_of_le hge with h | h
      · exact absurd ((kl_eq_zero_iff hd hq).mp h.symm).symm hqd
      · exact h
    have hsplit := klDiv_eq_neg_entropy_sub_cross hd hq
    unfold entropy at hsplit
    have h3 : γ * ∑ y, d y * Real.log (q y) < γ * ∑ y, d y * Real.log (d y) :=
      mul_lt_mul_of_pos_left (by linarith) hγ
    unfold objectivePTX entropy
    linarith
  · have h1 := variational_strict hβ hp hq.isDist hqg
    have h2 := cross_entropy_le hd hq
    have h3 : γ * ∑ y, d y * Real.log (q y) ≤ γ * ∑ y, d y * Real.log (d y) :=
      mul_le_mul_of_nonneg_left h2 hγ.le
    unfold objectivePTX entropy
    linarith

/-- **Exact size of the alignment tax at the aligned policy.**  Evaluating the RLHF+PTX
objective at the Gibbs policy loses exactly `γ · KL(d ‖ π_β)` relative to the joint
ceiling: the tax is the information distance between the aligned policy and the
pretraining distribution. -/
theorem ptx_value_at_gibbs {β γ : ℝ} {r p d : Ω → ℝ} [Nonempty Ω]
    (hβ : 0 < β) (hp : IsPosDist p) (hd : IsDist d) :
    objectivePTX β γ r p d (gibbsPolicy β r p)
      = β * Real.log (partition β r p) - γ * entropy d
        - γ * klDiv d (gibbsPolicy β r p) := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hsplit := klDiv_eq_neg_entropy_sub_cross hd hg
  have hobj : objective β r p (gibbsPolicy β r p) = β * Real.log (partition β r p) :=
    objective_gibbs hβ hp
  unfold objectivePTX
  rw [hobj, hsplit]
  ring

end RLHF