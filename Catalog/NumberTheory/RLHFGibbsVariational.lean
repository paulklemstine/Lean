import Mathlib

/-!
# The Gibbs variational principle for KL-regularized RLHF

This module is the root of the RLHF thread of the catalog.  It sets up the finite
KL-regularized alignment problem and proves the Gibbs variational principle that all the
downstream files use.

For a finite response space `Ω`, a reward model `r : Ω → ℝ`, a strictly positive reference
(SFT) policy `p : Ω → ℝ` and a KL coefficient `β > 0`, the RLHF objective at a policy `q` is

```
objective β r p q = 𝔼_q[r] − β · KL(q ‖ p).
```

Main results.

* `RLHF.kl_nonneg` — Gibbs' inequality: `KL(q ‖ p) ≥ 0` for a distribution `q` and a
  positive distribution `p`.
* `RLHF.kl_eq_zero_iff` — the equality case: `KL(q ‖ p) = 0 ↔ q = p`.
* `RLHF.objective_eq_sub_kl_gibbs` — the *pivot identity*
  `objective β r p q = β log Z(β) − β · KL(q ‖ π_β)`, where `π_β` is the Gibbs (tilted)
  policy and `Z(β) = ∑_y p y · exp(r y / β)` the partition function.
* `RLHF.variational_principle` and `RLHF.variational_strict` — consequently `β log Z` is the
  optimal value of the RLHF objective, attained *only* at the Gibbs policy
  (`RLHF.objective_gibbs`).
* `RLHF.reference_le_free_energy` — RLHF never hurts: the optimal value dominates the value
  of the reference policy.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Policies -/

/-- A probability distribution on the finite response space. -/
def IsDist (q : Ω → ℝ) : Prop := (∀ y, 0 ≤ q y) ∧ ∑ y, q y = 1

/-- A strictly positive probability distribution (an admissible SFT reference policy). -/
def IsPosDist (p : Ω → ℝ) : Prop := (∀ y, 0 < p y) ∧ ∑ y, p y = 1

theorem IsPosDist.isDist {p : Ω → ℝ} (hp : IsPosDist p) : IsDist p :=
  ⟨fun y => (hp.1 y).le, hp.2⟩

/-! ## 2. Kullback–Leibler divergence -/

/-- The Kullback–Leibler divergence of `q` from `p`. -/
noncomputable def klDiv (q p : Ω → ℝ) : ℝ := ∑ y, q y * Real.log (q y / p y)

/-- The termwise Gibbs bound: `a log (a / b) ≥ a − b` for `a ≥ 0 < b`. -/
theorem kl_term_le {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) : a - b ≤ a * Real.log (a / b) := by
  rcases eq_or_lt_of_le ha with rfl | hapos
  · simp
    linarith
  · have h1 : Real.log (b / a) ≤ b / a - 1 := Real.log_le_sub_one_of_pos (by positivity)
    have h2 : Real.log (b / a) = -Real.log (a / b) := by
      rw [← Real.log_inv]
      congr 1
      field_simp
    have h3 : a * (1 - b / a) = a - b := by field_simp
    have h4 : a * (1 - b / a) ≤ a * Real.log (a / b) := by
      refine mul_le_mul_of_nonneg_left ?_ ha
      linarith
    linarith

/-- **Gibbs' inequality.**  The KL divergence of a distribution from a positive distribution
is nonnegative. -/
theorem kl_nonneg {q p : Ω → ℝ} (hq : IsDist q) (hp : IsPosDist p) : 0 ≤ klDiv q p := by
  have hterm : ∀ y ∈ (univ : Finset Ω), q y - p y ≤ q y * Real.log (q y / p y) :=
    fun y _ => kl_term_le (hq.1 y) (hp.1 y)
  have hsum := Finset.sum_le_sum hterm
  rw [Finset.sum_sub_distrib, hq.2, hp.2] at hsum
  simpa [klDiv] using hsum

/-- **The equality case of Gibbs' inequality.** -/
theorem kl_eq_zero_iff {q p : Ω → ℝ} (hq : IsDist q) (hp : IsPosDist p) :
    klDiv q p = 0 ↔ q = p := by
  constructor
  · intro h0
    have hterm : ∀ y ∈ (univ : Finset Ω), q y - p y ≤ q y * Real.log (q y / p y) :=
      fun y _ => kl_term_le (hq.1 y) (hp.1 y)
    have hsum : ∑ y, (q y - p y) = ∑ y, q y * Real.log (q y / p y) := by
      rw [Finset.sum_sub_distrib, hq.2, hp.2]
      simpa [klDiv] using h0.symm
    have heq := (Finset.sum_eq_sum_iff_of_le hterm).1 hsum
    funext y
    have hy := heq y (Finset.mem_univ y)
    rcases eq_or_lt_of_le (hq.1 y) with hq0 | hqpos
    · exfalso
      rw [← hq0] at hy
      simp at hy
      linarith [hp.1 y]
    · by_contra hne
      have hratio : p y / q y ≠ 1 := by
        intro h
        exact hne (by field_simp at h; linarith)
      have hlt : Real.log (p y / q y) < p y / q y - 1 :=
        Real.log_lt_sub_one_of_pos (div_pos (hp.1 y) hqpos) hratio
      have h2 : Real.log (p y / q y) = -Real.log (q y / p y) := by
        rw [← Real.log_inv]
        congr 1
        field_simp
      have h3 : q y * (1 - p y / q y) < q y * Real.log (q y / p y) := by
        have : 1 - p y / q y < Real.log (q y / p y) := by linarith
        exact mul_lt_mul_of_pos_left this hqpos
      have h4 : q y * (1 - p y / q y) = q y - p y := by field_simp
      linarith
  · rintro rfl
    have : ∀ y, q y * Real.log (q y / q y) = 0 := by
      intro y
      rw [div_self (ne_of_gt (hp.1 y))]
      simp
    simp [klDiv]

/-! ## 3. Partition function, Gibbs policy and the RLHF objective -/

/-- The partition function `Z(β) = ∑_y p y · exp (r y / β)`. -/
noncomputable def partition (β : ℝ) (r p : Ω → ℝ) : ℝ := ∑ y, p y * Real.exp (r y / β)

/-- The tilted (Gibbs) policy `π_β(y) ∝ p y · exp (r y / β)`. -/
noncomputable def gibbsPolicy (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => p y * Real.exp (r y / β) / partition β r p

/-- The KL-regularized RLHF objective. -/
noncomputable def objective (β : ℝ) (r p q : Ω → ℝ) : ℝ :=
  (∑ y, q y * r y) - β * klDiv q p

variable [Nonempty Ω]

theorem partition_pos {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) : 0 < partition β r p :=
  Finset.sum_pos (fun y _ => by have := hp.1 y; positivity) univ_nonempty

theorem gibbsPolicy_pos {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) (y : Ω) :
    0 < gibbsPolicy β r p y := by
  have hZ := partition_pos (β := β) (r := r) hp
  have := hp.1 y
  unfold gibbsPolicy
  positivity

theorem gibbsPolicy_isPosDist {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) :
    IsPosDist (gibbsPolicy β r p) := by
  refine ⟨gibbsPolicy_pos hp, ?_⟩
  have hZ := partition_pos (β := β) (r := r) hp
  unfold gibbsPolicy
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt hZ)

/-- **The pivot identity.**  The RLHF objective is the free energy minus the KL distance to
the Gibbs policy. -/
theorem objective_eq_sub_kl_gibbs {β : ℝ} {r p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsDist q) :
    objective β r p q = β * Real.log (partition β r p) - β * klDiv q (gibbsPolicy β r p) := by
  have hZ := partition_pos (β := β) (r := r) hp
  have hterm : ∀ y, q y * Real.log (q y / gibbsPolicy β r p y)
      = q y * Real.log (q y / p y) - q y * (r y / β) + q y * Real.log (partition β r p) := by
    intro y
    rcases eq_or_lt_of_le (hq.1 y) with hq0 | hqpos
    · rw [← hq0]; ring
    · have hpy := hp.1 y
      have hpi : gibbsPolicy β r p y = p y * Real.exp (r y / β) / partition β r p := rfl
      have hpipos : 0 < gibbsPolicy β r p y := gibbsPolicy_pos hp y
      rw [Real.log_div (ne_of_gt hqpos) (ne_of_gt hpipos),
        Real.log_div (ne_of_gt hqpos) (ne_of_gt hpy), hpi,
        Real.log_div (by positivity) (ne_of_gt hZ), Real.log_mul (ne_of_gt hpy) (by positivity),
        Real.log_exp]
      ring
  have hsum : klDiv q (gibbsPolicy β r p)
      = klDiv q p - (∑ y, q y * r y) / β + Real.log (partition β r p) := by
    unfold klDiv
    rw [Finset.sum_congr rfl (fun y _ => hterm y)]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, hq.2, one_mul]
    congr 1
    congr 1
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun y _ => by ring)
  rw [hsum, objective]
  field_simp
  ring

/-- **The Gibbs variational principle.**  No policy beats the free energy. -/
theorem variational_principle {β : ℝ} {r p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsDist q) : objective β r p q ≤ β * Real.log (partition β r p) := by
  have hkl : 0 ≤ klDiv q (gibbsPolicy β r p) :=
    kl_nonneg hq (gibbsPolicy_isPosDist hp)
  rw [objective_eq_sub_kl_gibbs hβ hp hq]
  nlinarith

/-- The Gibbs policy attains the free energy. -/
theorem objective_gibbs {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    objective β r p (gibbsPolicy β r p) = β * Real.log (partition β r p) := by
  have hgd := (gibbsPolicy_isPosDist (β := β) (r := r) hp)
  rw [objective_eq_sub_kl_gibbs hβ hp hgd.isDist,
    (kl_eq_zero_iff hgd.isDist hgd).2 rfl]
  ring

/-- **Uniqueness of the optimum.**  Every policy other than the Gibbs policy is strictly
suboptimal. -/
theorem variational_strict {β : ℝ} {r p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsDist q) (hne : q ≠ gibbsPolicy β r p) :
    objective β r p q < β * Real.log (partition β r p) := by
  have hgd := (gibbsPolicy_isPosDist (β := β) (r := r) hp)
  have hkl : 0 ≤ klDiv q (gibbsPolicy β r p) := kl_nonneg hq hgd
  have hne0 : klDiv q (gibbsPolicy β r p) ≠ 0 := fun h => hne ((kl_eq_zero_iff hq hgd).1 h)
  have hpos : 0 < klDiv q (gibbsPolicy β r p) := lt_of_le_of_ne hkl (Ne.symm hne0)
  rw [objective_eq_sub_kl_gibbs hβ hp hq]
  nlinarith

/-- **RLHF never hurts.**  The free energy dominates the value of the reference policy. -/
theorem reference_le_free_energy {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    ∑ y, p y * r y ≤ β * Real.log (partition β r p) := by
  have h := variational_principle (β := β) (r := r) hβ hp hp.isDist
  rw [objective, (kl_eq_zero_iff hp.isDist hp).2 rfl] at h
  simpa using h

end RLHF