import NumberTheory.RLHFRewardIdentifiability

/-!
# Temperature schedules collapse: iterated RLHF is single-step RLHF

This file settles Conjecture 4 of `FUTURE_DIRECTIONS.md`.  `RLHF.gibbs_compose` shows that
two alignment steps *at the same temperature* add their reward models.  A real training
pipeline, however, runs a **schedule**: step `i` uses its own KL coefficient `β i` and its
own reward `r i`.  We show that the whole schedule collapses:

* `RLHF.gibbsPolicy_rescale` — only the ratio `r / β` matters, so a step at temperature `β'`
  is a step at temperature `β` with the rescaled reward `(β/β') r`.
* `RLHF.gibbs_schedule_two` — a two-step schedule equals one step with reward
  `(β/β₁) r₁ + (β/β₂) r₂`.
* `RLHF.runSchedule` and `RLHF.schedule_collapse` — an arbitrary finite schedule, folded left
  over a list of (temperature, reward) pairs, equals a single RLHF step at any chosen
  temperature `β` with reward `∑ᵢ (β/βᵢ) rᵢ`.
* `RLHF.schedule_reachable_in_one_step` — consequently no multi-step schedule can reach a
  policy that is unreachable in one step: the reachable set is exactly the orbit of the
  one-step map, so iterated RLHF adds no expressive power (only optimization dynamics).
* `RLHF.zeta_schedule_collapse` — arithmetic payoff: for Dirichlet rewards on a smooth-number
  response space, a schedule with sharpnesses `s₁, s₂` at *arbitrary* temperatures produces
  the truncated zeta policy of exponent `s₁ + s₂`, independently of the schedule.  The
  alignment schedule acts on Dirichlet exponents by addition, i.e. by multiplication of the
  associated Dirichlet series.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Only the ratio reward/temperature matters -/

omit [Nonempty Ω] in
/-- **Temperature–reward rescaling.**  A step at temperature `β'` with reward `r` is exactly
a step at temperature `β` with the rescaled reward `(β/β') r`. -/
theorem gibbsPolicy_rescale {β β' : ℝ} (hβ : β ≠ 0) (hβ' : β' ≠ 0) (r p : Ω → ℝ) :
    gibbsPolicy β (fun y => (β / β') * r y) p = gibbsPolicy β' r p := by
  have hexp : ∀ y, ((β / β') * r y) / β = r y / β' := by
    intro y; field_simp
  unfold gibbsPolicy partition
  simp only [hexp]

omit [Nonempty Ω] in
/-- A zero reward model leaves the reference policy unchanged. -/
theorem gibbsPolicy_zero {β : ℝ} {p : Ω → ℝ} (hp : IsPosDist p) :
    gibbsPolicy β (fun _ => (0 : ℝ)) p = p := by
  have hZ : partition β (fun _ => (0 : ℝ)) p = 1 := by
    unfold partition
    simpa using hp.2
  funext y
  unfold gibbsPolicy
  rw [hZ]
  simp

/-- **Two-step schedule collapse.**  Running RLHF at temperature `β₁` with reward `r₁` and
then at temperature `β₂` with reward `r₂` is a single step at any temperature `β`. -/
theorem gibbs_schedule_two {β β₁ β₂ : ℝ} (hβ : β ≠ 0) (hβ₁ : β₁ ≠ 0) (hβ₂ : β₂ ≠ 0)
    {r₁ r₂ p : Ω → ℝ} (hp : IsPosDist p) :
    gibbsPolicy β₂ r₂ (gibbsPolicy β₁ r₁ p)
      = gibbsPolicy β (fun y => (β / β₁) * r₁ y + (β / β₂) * r₂ y) p := by
  rw [← gibbsPolicy_rescale hβ hβ₁ r₁ p, ← gibbsPolicy_rescale hβ hβ₂ r₂
    (gibbsPolicy β (fun y => (β / β₁) * r₁ y) p),
    gibbs_compose (r₁ := fun y => (β / β₁) * r₁ y) (r₂ := fun y => (β / β₂) * r₂ y) hp]

/-! ## 2. Arbitrary finite schedules -/

/-- Run a finite RLHF schedule: a list of (KL coefficient, reward model) pairs applied in
order, starting from the SFT reference `p`. -/
noncomputable def runSchedule (p : Ω → ℝ) : List (ℝ × (Ω → ℝ)) → (Ω → ℝ) :=
  List.foldl (fun q br => gibbsPolicy br.1 br.2 q) p

omit [Nonempty Ω] in
@[simp] theorem runSchedule_nil (p : Ω → ℝ) : runSchedule p [] = p := rfl

omit [Nonempty Ω] in
@[simp] theorem runSchedule_cons (p : Ω → ℝ) (br : ℝ × (Ω → ℝ)) (L : List (ℝ × (Ω → ℝ))) :
    runSchedule p (br :: L) = runSchedule (gibbsPolicy br.1 br.2 p) L := rfl

/-- **Schedule collapse.**  Any finite temperature schedule is equivalent to a single RLHF
step, at an arbitrary temperature `β`, with the reward model `∑ᵢ (β/βᵢ) rᵢ`. -/
theorem schedule_collapse {β : ℝ} (hβ : β ≠ 0) :
    ∀ (L : List (ℝ × (Ω → ℝ))) (p : Ω → ℝ), IsPosDist p → (∀ br ∈ L, br.1 ≠ 0) →
      runSchedule p L
        = gibbsPolicy β (fun y => (L.map (fun br => (β / br.1) * br.2 y)).sum) p := by
  intro L
  induction L with
  | nil =>
    intro p hp _
    simpa using (gibbsPolicy_zero (β := β) hp).symm
  | cons br L ih =>
    intro p hp hne
    have hbr : br.1 ≠ 0 := hne br (List.mem_cons_self ..)
    have hpq : IsPosDist (gibbsPolicy β (fun y => (β / br.1) * br.2 y) p) :=
      gibbsPolicy_isPosDist hp
    rw [runSchedule_cons, ← gibbsPolicy_rescale hβ hbr br.2 p,
      ih _ hpq (fun c hc => hne c (List.mem_cons_of_mem _ hc)),
      gibbs_compose (r₁ := fun y => (β / br.1) * br.2 y)
        (r₂ := fun y => (L.map (fun c => (β / c.1) * c.2 y)).sum) hp]
    simp

/-- **No expressive gain from iteration.**  Every policy reachable by a multi-step RLHF
schedule is already reachable by a single step at a fixed temperature `β`. -/
theorem schedule_reachable_in_one_step {β : ℝ} (hβ : β ≠ 0) (L : List (ℝ × (Ω → ℝ)))
    (p : Ω → ℝ) (hp : IsPosDist p) (hne : ∀ br ∈ L, br.1 ≠ 0) :
    ∃ r : Ω → ℝ, runSchedule p L = gibbsPolicy β r p :=
  ⟨_, schedule_collapse hβ L p hp hne⟩

/-! ## 3. Arithmetic corollary: Dirichlet exponents add along any schedule -/

variable {A B : ℕ}

/-- Rescaling a Dirichlet reward from temperature `β'` to `β` reproduces the Dirichlet
reward of the *same* sharpness at `β`: the exponent is a schedule invariant. -/
theorem zetaReward_rescale {β β' s : ℝ} (hβ' : β' ≠ 0) {p q : ℕ} (ab : Smooth A B) :
    (β / β') * zetaReward β' s p q ab = zetaReward β s p q ab := by
  unfold zetaReward
  field_simp

/-- **Schedule invariance of the zeta exponent.**  Two RLHF steps with Dirichlet rewards of
sharpness `s₁` and `s₂`, run at *arbitrary* (nonzero) KL coefficients `β₁, β₂`, produce
exactly the truncated zeta policy of exponent `s₁ + s₂`. -/
theorem zeta_schedule_collapse {β₁ β₂ s₁ s₂ : ℝ} (hβ₁ : 0 < β₁) (hβ₂ : 0 < β₂) {p q : ℕ}
    (hp : 0 < p) (hq : 0 < q) (ab : Smooth A B) :
    gibbsPolicy β₂ (zetaReward β₂ s₂ p q)
        (gibbsPolicy β₁ (zetaReward β₁ s₁ p q) (uniformDist (Smooth A B))) ab
      = zetaWeight (s₁ + s₂) (smoothVal p q ab) / zetaSum (s₁ + s₂) p q A B := by
  have hcollapse := gibbs_schedule_two (β := β₁) (β₁ := β₁) (β₂ := β₂) (ne_of_gt hβ₁)
    (ne_of_gt hβ₁) (ne_of_gt hβ₂) (r₁ := zetaReward β₁ s₁ p q) (r₂ := zetaReward β₂ s₂ p q)
    (uniformDist_isPosDist (Smooth A B))
  have hrw : (fun ab : Smooth A B => (β₁ / β₁) * zetaReward β₁ s₁ p q ab
      + (β₁ / β₂) * zetaReward β₂ s₂ p q ab) = zetaReward β₁ (s₁ + s₂) p q := by
    funext ab
    rw [zetaReward_rescale (ne_of_gt hβ₁) ab, zetaReward_rescale (ne_of_gt hβ₂) ab]
    unfold zetaReward
    ring
  rw [hcollapse, hrw, gibbs_zeta_policy hβ₁ hp hq]

end RLHF