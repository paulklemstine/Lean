import NumberTheory.RLHFZetaEulerPolicy

/-!
# Reward identifiability, DPO reparametrization, and the semigroup of RLHF steps

Three structural theorems about the KL-regularized RLHF map `r ↦ π_β = gibbsPolicy β r p`:

* `RLHF.gibbsPolicy_shift` / `RLHF.gibbs_eq_iff_shift` — the aligned policy determines the
  reward model **exactly up to an additive constant**: reward models are identifiable only
  modulo `ℝ`.
* `RLHF.gibbs_implicitReward` — every positive policy is the RLHF optimum of the *implicit*
  reward `β log (q/p)` (the DPO reparametrization); combined with the previous item this
  makes `r ↦ π_β` a bijection between rewards-modulo-constants and positive policies.
* `RLHF.gibbs_compose` — iterating RLHF adds rewards:
  `gibbsPolicy β r₂ (gibbsPolicy β r₁ p) = gibbsPolicy β (r₁ + r₂) p`.
  Thus RLHF steps carry an action of the additive group of reward models.

Arithmetic payoff (`RLHF.zeta_policy_compose`): for Dirichlet rewards on a smooth-number
response space, composing two RLHF steps at sharpness `s₁` and `s₂` produces exactly the
zeta policy at sharpness `s₁ + s₂`.  The alignment semigroup acts on Dirichlet exponents by
addition, i.e. by multiplication of the corresponding Dirichlet series weights.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Shift invariance and identifiability -/

omit [Nonempty Ω] in
theorem partition_shift {β c : ℝ} {r p : Ω → ℝ} :
    partition β (fun y => r y + c) p = Real.exp (c / β) * partition β r p := by
  unfold partition
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun y _ => ?_)
  rw [show (r y + c) / β = r y / β + c / β by ring, Real.exp_add]
  ring

/-- Adding a constant to the reward model does not change the aligned policy. -/
theorem gibbsPolicy_shift {β c : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) :
    gibbsPolicy β (fun y => r y + c) p = gibbsPolicy β r p := by
  have hZ := partition_pos (β := β) (r := r) hp
  funext y
  unfold gibbsPolicy
  rw [partition_shift (r := r) (c := c),
    show (r y + c) / β = r y / β + c / β by ring, Real.exp_add]
  have hc : Real.exp (c / β) ≠ 0 := Real.exp_ne_zero _
  field_simp

/-- **Reward identifiability.**  Two reward models induce the same aligned policy exactly
when they differ by an additive constant. -/
theorem gibbs_eq_iff_shift {β : ℝ} {r₁ r₂ p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    gibbsPolicy β r₁ p = gibbsPolicy β r₂ p ↔ ∃ c : ℝ, ∀ y, r₁ y = r₂ y + c := by
  constructor
  · intro hEq
    have hZ₁ := partition_pos (β := β) (r := r₁) hp
    have hZ₂ := partition_pos (β := β) (r := r₂) hp
    refine ⟨β * Real.log (partition β r₁ p / partition β r₂ p), fun y => ?_⟩
    have hy : p y * Real.exp (r₁ y / β) / partition β r₁ p
        = p y * Real.exp (r₂ y / β) / partition β r₂ p := congrFun hEq y
    have hpy := hp.1 y
    rw [div_eq_div_iff (ne_of_gt hZ₁) (ne_of_gt hZ₂)] at hy
    have key : p y * (Real.exp (r₁ y / β) * partition β r₂ p)
        = p y * (Real.exp (r₂ y / β) * partition β r₁ p) := by
      rw [← mul_assoc, ← mul_assoc]; exact hy
    have hexp : Real.exp (r₁ y / β) * partition β r₂ p
        = Real.exp (r₂ y / β) * partition β r₁ p := mul_left_cancel₀ (ne_of_gt hpy) key
    have hratio : Real.exp (r₁ y / β - r₂ y / β) = partition β r₁ p / partition β r₂ p := by
      rw [Real.exp_sub, div_eq_div_iff (ne_of_gt (Real.exp_pos _)) (ne_of_gt hZ₂)]
      linarith [hexp]
    have hlog : r₁ y / β - r₂ y / β = Real.log (partition β r₁ p / partition β r₂ p) := by
      rw [← hratio, Real.log_exp]
    field_simp at hlog ⊢
    linarith [hlog]
  · rintro ⟨c, hc⟩
    have : r₁ = fun y => r₂ y + c := funext hc
    rw [this]
    exact gibbsPolicy_shift hp

/-! ## 2. The DPO reparametrization -/

/-- The implicit reward of a policy `q` relative to the reference `p`. -/
noncomputable def implicitReward (β : ℝ) (p q : Ω → ℝ) : Ω → ℝ :=
  fun y => β * Real.log (q y / p y)

omit [Nonempty Ω] in
/-- **DPO reparametrization.**  Every strictly positive policy is the exact RLHF optimum
for its own implicit reward. -/
theorem gibbs_implicitReward {β : ℝ} {p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsPosDist q) : gibbsPolicy β (implicitReward β p q) p = q := by
  have hβ0 : β ≠ 0 := ne_of_gt hβ
  have hexp : ∀ y, p y * Real.exp (implicitReward β p q y / β) = q y := by
    intro y
    have hpy := hp.1 y
    have hqy := hq.1 y
    unfold implicitReward
    rw [show β * Real.log (q y / p y) / β = Real.log (q y / p y) by field_simp [hβ0],
      Real.exp_log (by positivity)]
    field_simp
  have hZ : partition β (implicitReward β p q) p = 1 := by
    unfold partition
    rw [Finset.sum_congr rfl (fun y _ => hexp y), hq.2]
  funext y
  unfold gibbsPolicy
  rw [hZ, div_one, hexp y]

/-! ## 3. Composition of RLHF steps -/

/-- **Iterated RLHF adds rewards.**  Running a second alignment step against the first
aligned policy is the same as a single step with the summed reward model. -/
theorem gibbs_compose {β : ℝ} {r₁ r₂ p : Ω → ℝ} (hp : IsPosDist p) :
    gibbsPolicy β r₂ (gibbsPolicy β r₁ p) = gibbsPolicy β (fun y => r₁ y + r₂ y) p := by
  have hZ₁ := partition_pos (β := β) (r := r₁) hp
  have hZ₁₂ := partition_pos (β := β) (r := fun y => r₁ y + r₂ y) hp
  set Z₁ := partition β r₁ p with hZ₁def
  set Z₁₂ := partition β (fun y => r₁ y + r₂ y) p with hZ₁₂def
  have hnum : ∀ y, gibbsPolicy β r₁ p y * Real.exp (r₂ y / β)
      = (p y * Real.exp ((r₁ y + r₂ y) / β)) / Z₁ := by
    intro y
    unfold gibbsPolicy
    rw [show (r₁ y + r₂ y) / β = r₁ y / β + r₂ y / β by ring, Real.exp_add]
    rw [← hZ₁def]
    field_simp
  have hstep : partition β r₂ (gibbsPolicy β r₁ p) = Z₁₂ / Z₁ := by
    unfold partition
    rw [Finset.sum_congr rfl (fun y _ => hnum y), ← Finset.sum_div]
    rfl
  funext y
  show gibbsPolicy β r₁ p y * Real.exp (r₂ y / β) / partition β r₂ (gibbsPolicy β r₁ p)
      = p y * Real.exp ((r₁ y + r₂ y) / β) / Z₁₂
  rw [hnum y, hstep]
  field_simp

/-! ## 4. Arithmetic corollary: Dirichlet exponents add -/

variable {A B : ℕ}

/-- The Dirichlet rewards add in the sharpness parameter. -/
theorem zetaReward_add {β s₁ s₂ : ℝ} {p q : ℕ} :
    (fun ab : Smooth A B => zetaReward β s₁ p q ab + zetaReward β s₂ p q ab)
      = zetaReward β (s₁ + s₂) p q := by
  funext ab
  unfold zetaReward
  ring

/-- **Composition of aligned zeta policies.**  Two successive RLHF steps with Dirichlet
rewards of sharpness `s₁` and `s₂` produce the truncated zeta policy of sharpness
`s₁ + s₂`. -/
theorem zeta_policy_compose {β s₁ s₂ : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q)
    (ab : Smooth A B) :
    gibbsPolicy β (zetaReward β s₂ p q)
        (gibbsPolicy β (zetaReward β s₁ p q) (uniformDist (Smooth A B))) ab
      = zetaWeight (s₁ + s₂) (smoothVal p q ab) / zetaSum (s₁ + s₂) p q A B := by
  rw [gibbs_compose (uniformDist_isPosDist (Smooth A B)), zetaReward_add,
    gibbs_zeta_policy hβ hp hq]

end RLHF