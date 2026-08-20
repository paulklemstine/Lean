import Speculative.AutoResearch.RLHFGibbsVariational

/-!
# The alignment torsor, Gibbs–Bogoliubov–Feynman convexity, and uniqueness of the PTX optimum

This file continues the catalog development of the InstructGPT / PPO-ptx objective

```
Objective(φ) = 𝔼[RM_NS(x,y)] − β_NS · KL(LLM_φ ‖ LLM_SFT) + γ_NS · 𝔼_{x∼D_pre}[log LLM_φ(x)]
```

whose Gibbs core (`IsPosDist`, `klDiv`, `partition`, `gibbsPolicy`, `objective`,
`objectivePTX`, `variational_principle`, `variational_strict`, `alignment_tax`) is formalized in
`Speculative.AutoResearch.RLHFGibbsVariational`, on which this file builds.  Section 0 collects
the gauge/DPO/composition lemmas for the tilting map; sections 1–3 are new.

## 1. The alignment torsor (algebra)

The composition law `gibbs_compose` and the identifiability theorem `gibbs_eq_iff_shift`
combine into an honest group-theoretic statement: the additive group of reward models
`Ω → ℝ` acts on the set of strictly positive policies by exponential tilting, the action is
*transitive*, and its stabilizer is exactly the subgroup `constRewards` of constant rewards.
Hence the quotient group `(Ω → ℝ) ⧸ constRewards` acts **simply transitively**: the space of
aligned policies is a torsor over rewards-modulo-constants.  This is packaged as a genuine
bijection `RLHF.tiltEquiv` and as an `AddAction` (`RLHF.instAddActionPosPolicy`) which is
proved free and transitive.

## 2. Gibbs–Bogoliubov–Feynman: convexity of the free energy in the *reward*

`freeEnergy_add_inner_le` is the supporting-hyperplane (GBF) inequality
`F(s) ≥ F(r) + 𝔼_{π_r}[s − r]`, with the strict form `freeEnergy_gbf_strict`.
From it we derive, with no differential calculus at all:

* `freeEnergy_convex_reward` — convexity of `r ↦ F(r)` along segments;
* `freeEnergy_mono` — monotonicity in the reward;
* `freeEnergy_shift` and `freeEnergy_lipschitz` — the alignment value is `1`-Lipschitz in the
  sup-norm of the reward model: a *reward-hacking budget*, bounding how much a corrupted
  neurosymbolic reward can move the achievable objective.

## 3. The PTX optimum: strict concavity and uniqueness

Unlike the pure RLHF objective, the PTX-augmented objective has **no closed-form Gibbs
maximizer** (the stationarity condition is transcendental).  We prove instead the structural
statement: `objectivePTX` is strictly concave along midpoints of distinct positive policies
(`objectivePTX_midpoint_gt`), hence its maximizer, if one exists, is unique
(`ptx_maximizer_unique`).  This is the PTX analogue of `variational_strict`.

All results are `sorry`-free.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 0. Prerequisites on the tilting map

The gauge lemmas (`partition_shift`, `gibbsPolicy_shift`, `gibbs_eq_iff_shift`), the DPO
reparametrization and the composition law are re-derived here from the Gibbs core
(`Speculative.AutoResearch.RLHFGibbsVariational`), together with the free energy `freeEnergy`.
-/

/-- The free energy `F(r) = β log Z(β, r, p)`: the optimal value of the RLHF objective. -/
noncomputable def freeEnergy (β : ℝ) (r p : Ω → ℝ) : ℝ := β * Real.log (partition β r p)

/-- Adding a constant to the reward rescales the partition function. -/
theorem partition_shift {β c : ℝ} {r p : Ω → ℝ} :
    partition β (fun y => r y + c) p = Real.exp (c / β) * partition β r p := by
  unfold partition
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun y _ => ?_)
  rw [show (r y + c) / β = r y / β + c / β by ring, Real.exp_add]
  ring

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

variable [Nonempty Ω]

/-- **Gauge invariance.**  Adding a constant to the reward does not change the aligned policy. -/
theorem gibbsPolicy_shift {β c : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) :
    gibbsPolicy β (fun y => r y + c) p = gibbsPolicy β r p := by
  have hZ := partition_pos (β := β) (r := r) hp
  funext y
  unfold gibbsPolicy
  rw [partition_shift (r := r) (c := c),
    show (r y + c) / β = r y / β + c / β by ring, Real.exp_add]
  have hc : Real.exp (c / β) ≠ 0 := Real.exp_ne_zero _
  field_simp

/-- **Reward identifiability.**  Two reward models induce the same aligned policy exactly when
they differ by an additive constant. -/
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

/-- The implicit (DPO) reward of a policy `q` relative to the reference `p`. -/
noncomputable def implicitReward (β : ℝ) (p q : Ω → ℝ) : Ω → ℝ :=
  fun y => β * Real.log (q y / p y)

omit [Nonempty Ω] in
/-- **DPO reparametrization.**  Every strictly positive policy is the exact RLHF optimum for
its own implicit reward. -/
theorem gibbs_implicitReward {β : ℝ} {p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsPosDist q) : gibbsPolicy β (implicitReward β p q) p = q := by
  have hβ0 : β ≠ 0 := ne_of_gt hβ
  have hexp : ∀ y, p y * Real.exp (implicitReward β p q y / β) = q y := by
    intro y
    have hpy := hp.1 y
    have hqy := hq.1 y
    unfold implicitReward
    rw [show β * Real.log (q y / p y) / β = Real.log (q y / p y) by field_simp,
      Real.exp_log (by positivity)]
    field_simp
  have hZ : partition β (implicitReward β p q) p = 1 := by
    unfold partition
    rw [Finset.sum_congr rfl (fun y _ => hexp y), hq.2]
  funext y
  unfold gibbsPolicy
  rw [hZ, div_one, hexp y]

/-- **Iterated RLHF adds rewards.** -/
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

/-! ## 1. The alignment torsor -/

/-- The subgroup of *constant* reward models: the exact gauge freedom of RLHF. -/
def constRewards (Ω : Type*) [Fintype Ω] : AddSubgroup (Ω → ℝ) where
  carrier := {f | ∃ c : ℝ, ∀ y, f y = c}
  add_mem' := by
    rintro f g ⟨c, hc⟩ ⟨e, he⟩
    exact ⟨c + e, fun y => by simp [hc y, he y]⟩
  zero_mem' := ⟨0, fun _ => rfl⟩
  neg_mem' := by
    rintro f ⟨c, hc⟩
    exact ⟨-c, fun y => by simp [hc y]⟩

omit [Nonempty Ω] in
theorem mem_constRewards {f : Ω → ℝ} : f ∈ constRewards Ω ↔ ∃ c : ℝ, ∀ y, f y = c := Iff.rfl

/-- Strictly positive policies on the response space. -/
def PosPolicy (Ω : Type*) [Fintype Ω] : Type _ := {q : Ω → ℝ // IsPosDist q}

/-- The tilting action of a reward model on a positive policy. -/
noncomputable def tiltAct (β : ℝ) (r : Ω → ℝ) (q : PosPolicy Ω) : PosPolicy Ω :=
  ⟨gibbsPolicy β r q.1, gibbsPolicy_isPosDist q.2⟩

theorem tiltAct_zero {β : ℝ} (q : PosPolicy Ω) : tiltAct β 0 q = q := by
  apply Subtype.ext
  simpa [tiltAct] using gibbsPolicy_zero (β := β) q.2

theorem tiltAct_add {β : ℝ} (r s : Ω → ℝ) (q : PosPolicy Ω) :
    tiltAct β (r + s) q = tiltAct β r (tiltAct β s q) := by
  apply Subtype.ext
  have h := (gibbs_compose (β := β) (r₁ := s) (r₂ := r) q.2).symm
  show gibbsPolicy β (r + s) q.1 = gibbsPolicy β r (gibbsPolicy β s q.1)
  have hrs : (r + s) = fun y => s y + r y := funext (fun y => by simp [add_comm])
  rw [hrs, h]

/-- The additive group of reward models acts on positive policies by exponential tilting. -/
noncomputable instance instAddActionPosPolicy (β : ℝ) : AddAction (Ω → ℝ) (PosPolicy Ω) where
  vadd r q := tiltAct β r q
  zero_vadd q := tiltAct_zero q
  add_vadd r s q := tiltAct_add r s q

/-- **Transitivity of the alignment action.**  Every positive policy is reachable from every
other one by a single RLHF step, namely with the DPO implicit reward. -/
theorem tiltAct_surjective {β : ℝ} (hβ : 0 < β) (p q : PosPolicy Ω) :
    ∃ r : Ω → ℝ, tiltAct β r p = q := by
  refine ⟨implicitReward β p.1 q.1, Subtype.ext ?_⟩
  simpa [tiltAct] using gibbs_implicitReward hβ p.2 q.2

/-- **The stabilizer is exactly the constant rewards.**  This is the gauge group of RLHF. -/
theorem tiltAct_eq_self_iff {β : ℝ} (hβ : 0 < β) (r : Ω → ℝ) (p : PosPolicy Ω) :
    tiltAct β r p = p ↔ r ∈ constRewards Ω := by
  constructor
  · intro h
    have h0 : gibbsPolicy β r p.1 = gibbsPolicy β (fun _ => (0 : ℝ)) p.1 := by
      rw [gibbsPolicy_zero p.2]
      exact congrArg Subtype.val h
    obtain ⟨c, hc⟩ := (gibbs_eq_iff_shift (r₁ := r) (r₂ := fun _ => (0:ℝ)) hβ p.2).mp h0
    exact ⟨c, fun y => by simpa using hc y⟩
  · rintro ⟨c, hc⟩
    apply Subtype.ext
    have : gibbsPolicy β r p.1 = gibbsPolicy β (fun y => (0 : ℝ) + c) p.1 := by
      congr 1
      funext y
      simp [hc y]
    simpa [tiltAct, this] using gibbsPolicy_shift (β := β) (c := c) (r := fun _ => (0:ℝ)) p.2
      |>.trans (gibbsPolicy_zero p.2)

/-- **Freeness modulo constants.**  Two rewards act identically iff they differ by a constant. -/
theorem tiltAct_eq_iff {β : ℝ} (hβ : 0 < β) (r s : Ω → ℝ) (p : PosPolicy Ω) :
    tiltAct β r p = tiltAct β s p ↔ r - s ∈ constRewards Ω := by
  constructor
  · intro h
    obtain ⟨c, hc⟩ := (gibbs_eq_iff_shift (r₁ := r) (r₂ := s) hβ p.2).mp (congrArg Subtype.val h)
    exact ⟨c, fun y => by simp [hc y]⟩
  · rintro ⟨c, hc⟩
    apply Subtype.ext
    have hrs : r = fun y => s y + c := by
      funext y
      have := hc y
      simp only [Pi.sub_apply] at this
      linarith
    show gibbsPolicy β r p.1 = gibbsPolicy β s p.1
    rw [hrs]
    exact gibbsPolicy_shift p.2

/-- The tilting map descends to the quotient by the gauge group. -/
noncomputable def tiltQuotMap (β : ℝ) (hβ : 0 < β) (p : PosPolicy Ω) :
    ((Ω → ℝ) ⧸ constRewards Ω) → PosPolicy Ω := fun x =>
  Quotient.liftOn' x (fun r => tiltAct β r p) (by
    intro r s h
    have hmem : -r + s ∈ constRewards Ω := QuotientAddGroup.leftRel_apply.mp h
    obtain ⟨c, hc⟩ := hmem
    refine ((tiltAct_eq_iff hβ r s p).mpr ⟨-c, fun y => ?_⟩)
    have := hc y
    simp only [Pi.add_apply, Pi.neg_apply] at this
    simp only [Pi.sub_apply]
    linarith)

theorem tiltQuotMap_mk (β : ℝ) (hβ : 0 < β) (p : PosPolicy Ω) (r : Ω → ℝ) :
    tiltQuotMap β hβ p (QuotientAddGroup.mk r) = tiltAct β r p := rfl

/-- **The alignment torsor.**  For a fixed SFT reference policy `p`, exponential tilting is a
*bijection* between reward models modulo the constant gauge group and strictly positive
aligned policies.  Equivalently: `PosPolicy Ω` is a torsor over `(Ω → ℝ) ⧸ constRewards Ω`. -/
noncomputable def tiltEquiv (β : ℝ) (hβ : 0 < β) (p : PosPolicy Ω) :
    ((Ω → ℝ) ⧸ constRewards Ω) ≃ PosPolicy Ω := by
  refine Equiv.ofBijective (tiltQuotMap β hβ p) ⟨?_, ?_⟩
  · refine fun x y => Quotient.inductionOn₂' x y (fun r s h => ?_)
    have h' : tiltAct β r p = tiltAct β s p := h
    obtain ⟨c, hc⟩ := (tiltAct_eq_iff hβ r s p).mp h'
    refine Quotient.sound' (QuotientAddGroup.leftRel_apply.mpr ⟨-c, fun y => ?_⟩)
    have := hc y
    simp only [Pi.sub_apply] at this
    simp only [Pi.add_apply, Pi.neg_apply]
    linarith
  · intro q
    obtain ⟨r, hr⟩ := tiltAct_surjective hβ p q
    exact ⟨QuotientAddGroup.mk r, hr⟩

/-! ## 2. Gibbs–Bogoliubov–Feynman inequality and convexity in the reward -/

/-- **Gibbs–Bogoliubov–Feynman.**  The free energy admits a supporting hyperplane at every
reward model, the slope being the aligned policy itself:
`F(s) ≥ F(r) + 𝔼_{π_r}[s − r]`. -/
theorem freeEnergy_add_inner_le {β : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β r p + ∑ y, gibbsPolicy β r p y * (s y - r y) ≤ freeEnergy β s p := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have h1 : objective β s p (gibbsPolicy β r p) ≤ freeEnergy β s p :=
    variational_principle hβ hp hg.isDist
  have h2 : objective β r p (gibbsPolicy β r p) = freeEnergy β r p := objective_gibbs hβ hp
  have hsplit : ∑ y, gibbsPolicy β r p y * (s y - r y)
      = (∑ y, gibbsPolicy β r p y * s y) - ∑ y, gibbsPolicy β r p y * r y := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun y _ => by ring)
  rw [objective] at h1 h2
  rw [hsplit]
  linarith

/-- **Bregman identity for the alignment value.**  The Bregman divergence of the free energy
between two reward models is *exactly* `β` times the KL divergence between the two aligned
policies.  This upgrades Gibbs–Bogoliubov–Feynman from an inequality to an identity and makes
the reward-to-policy map the gradient map of the convex potential `F`. -/
theorem freeEnergy_bregman_eq_kl {β : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β s p - freeEnergy β r p - ∑ y, gibbsPolicy β r p y * (s y - r y)
      = β * klDiv (gibbsPolicy β r p) (gibbsPolicy β s p) := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have h1 : objective β s p (gibbsPolicy β r p)
      = β * Real.log (partition β s p) - β * klDiv (gibbsPolicy β r p) (gibbsPolicy β s p) :=
    objective_eq_free_energy_sub_kl hβ hp hg.isDist
  have h2 : objective β r p (gibbsPolicy β r p) = β * Real.log (partition β r p) :=
    objective_gibbs hβ hp
  have hsplit : ∑ y, gibbsPolicy β r p y * (s y - r y)
      = (∑ y, gibbsPolicy β r p y * s y) - ∑ y, gibbsPolicy β r p y * r y := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun y _ => by ring)
  rw [objective] at h1 h2
  unfold freeEnergy
  rw [hsplit]
  linarith

/-- The Bregman divergence of the alignment value vanishes exactly on the gauge orbit: the
free energy is strictly convex on rewards *modulo constants*. -/
theorem freeEnergy_bregman_eq_zero_iff {β : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β s p - freeEnergy β r p - ∑ y, gibbsPolicy β r p y * (s y - r y) = 0
      ↔ ∃ c : ℝ, ∀ y, r y = s y + c := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hs : IsPosDist (gibbsPolicy β s p) := gibbsPolicy_isPosDist hp
  rw [freeEnergy_bregman_eq_kl hβ hp]
  constructor
  · intro h
    have hkl : klDiv (gibbsPolicy β r p) (gibbsPolicy β s p) = 0 := by
      rcases mul_eq_zero.mp h with h' | h'
      · exact absurd h' (ne_of_gt hβ)
      · exact h'
    exact (gibbs_eq_iff_shift hβ hp).mp ((kl_eq_zero_iff hg.isDist hs).mp hkl)
  · intro h
    have hEq : gibbsPolicy β r p = gibbsPolicy β s p := (gibbs_eq_iff_shift hβ hp).mpr h
    rw [hEq, (kl_eq_zero_iff hs.isDist hs).mpr rfl, mul_zero]

/-- Strict GBF: the supporting hyperplane touches only when the aligned policies agree. -/
theorem freeEnergy_gbf_strict {β : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hne : gibbsPolicy β r p ≠ gibbsPolicy β s p) :
    freeEnergy β r p + ∑ y, gibbsPolicy β r p y * (s y - r y) < freeEnergy β s p := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have h1 : objective β s p (gibbsPolicy β r p) < freeEnergy β s p :=
    variational_strict hβ hp hg.isDist hne
  have h2 : objective β r p (gibbsPolicy β r p) = freeEnergy β r p := objective_gibbs hβ hp
  have hsplit : ∑ y, gibbsPolicy β r p y * (s y - r y)
      = (∑ y, gibbsPolicy β r p y * s y) - ∑ y, gibbsPolicy β r p y * r y := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun y _ => by ring)
  rw [objective] at h1 h2
  rw [hsplit]
  linarith

/-- The free energy is monotone in the reward model. -/
theorem freeEnergy_mono {β : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hrs : ∀ y, r y ≤ s y) : freeEnergy β r p ≤ freeEnergy β s p := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hpos : 0 ≤ ∑ y, gibbsPolicy β r p y * (s y - r y) :=
    Finset.sum_nonneg fun y _ => mul_nonneg (hg.1 y).le (by linarith [hrs y])
  have := freeEnergy_add_inner_le (β := β) (r := r) (s := s) (p := p) hβ hp
  linarith

/-- **Convexity of the alignment value in the reward model**, derived from GBF alone. -/
theorem freeEnergy_convex_reward {β θ : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    freeEnergy β (fun y => θ * r y + (1 - θ) * s y) p
      ≤ θ * freeEnergy β r p + (1 - θ) * freeEnergy β s p := by
  set m : Ω → ℝ := fun y => θ * r y + (1 - θ) * s y with hm
  have hr := freeEnergy_add_inner_le (β := β) (r := m) (s := r) hβ hp
  have hs := freeEnergy_add_inner_le (β := β) (r := m) (s := s) hβ hp
  have hzero : θ * (∑ y, gibbsPolicy β m p y * (r y - m y))
      + (1 - θ) * (∑ y, gibbsPolicy β m p y * (s y - m y)) = 0 := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    refine Finset.sum_eq_zero (fun y _ => ?_)
    simp only [hm]
    ring
  nlinarith [hr, hs, hzero, mul_le_mul_of_nonneg_left hr h0,
    mul_le_mul_of_nonneg_left hs (by linarith : (0:ℝ) ≤ 1 - θ)]

/-- Adding a constant `c` to the reward shifts the alignment value by exactly `c`. -/
theorem freeEnergy_shift {β c : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β (fun y => r y + c) p = freeEnergy β r p + c := by
  have hZ : 0 < partition β r p := partition_pos (β := β) (r := r) hp
  unfold freeEnergy
  rw [partition_shift (β := β) (c := c) (r := r) (p := p),
    Real.log_mul (Real.exp_ne_zero _) (ne_of_gt hZ), Real.log_exp]
  field_simp
  ring

/-- **Reward-hacking budget.**  The optimal alignment value is `1`-Lipschitz in the sup-norm of
the reward model: a corrupted reward that differs from the true one by at most `K` pointwise
can move the achievable objective by at most `K`. -/
theorem freeEnergy_lipschitz {β K : ℝ} {r s p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hK : ∀ y, |r y - s y| ≤ K) :
    |freeEnergy β r p - freeEnergy β s p| ≤ K := by
  have h1 : freeEnergy β r p ≤ freeEnergy β s p + K := by
    have hle : freeEnergy β r p ≤ freeEnergy β (fun y => s y + K) p := by
      refine freeEnergy_mono hβ hp (fun y => ?_)
      have := abs_le.mp (hK y)
      linarith [this.2]
    rwa [freeEnergy_shift hβ hp] at hle
  have h2 : freeEnergy β s p ≤ freeEnergy β r p + K := by
    have hle : freeEnergy β s p ≤ freeEnergy β (fun y => r y + K) p := by
      refine freeEnergy_mono hβ hp (fun y => ?_)
      have := abs_le.mp (hK y)
      linarith [this.1]
    rwa [freeEnergy_shift hβ hp] at hle
  rw [abs_le]
  constructor <;> linarith

/-! ## 3. Strict concavity and uniqueness of the PTX optimum -/

/-- Strict midpoint convexity of `t ↦ t log (t / c)`, the pointwise KL integrand. -/
theorem mul_log_div_midpoint_lt {a b c : ℝ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hab : a ≠ b) :
    ((a + b) / 2) * Real.log (((a + b) / 2) / c)
      < (a * Real.log (a / c) + b * Real.log (b / c)) / 2 := by
  have hmid : (0:ℝ) < (a + b) / 2 := by linarith
  have hconv := Real.strictConvexOn_mul_log.2 (Set.mem_Ici.mpr ha.le) (Set.mem_Ici.mpr hb.le) hab
    (show (0:ℝ) < 1/2 by norm_num) (show (0:ℝ) < 1/2 by norm_num)
    (show (1:ℝ)/2 + 1/2 = 1 by norm_num)
  simp only [smul_eq_mul] at hconv
  have hkey : ((a + b) / 2) * Real.log ((a + b) / 2)
      < (a * Real.log a + b * Real.log b) / 2 := by
    have : (1:ℝ)/2 * a + 1/2 * b = (a + b) / 2 := by ring
    rw [this] at hconv
    linarith
  rw [Real.log_div (ne_of_gt hmid) (ne_of_gt hc), Real.log_div (ne_of_gt ha) (ne_of_gt hc),
    Real.log_div (ne_of_gt hb) (ne_of_gt hc)]
  nlinarith [hkey]

/-- Midpoint concavity of `log`, the pointwise PTX integrand. -/
theorem log_midpoint_ge {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (Real.log a + Real.log b) / 2 ≤ Real.log ((a + b) / 2) := by
  have hmid : (0:ℝ) < (a + b) / 2 := by linarith
  have hprod : a * b ≤ ((a + b) / 2) ^ 2 := by nlinarith [sq_nonneg (a - b)]
  have hlog : Real.log (a * b) ≤ Real.log (((a + b) / 2) ^ 2) :=
    Real.log_le_log (by positivity) hprod
  rw [Real.log_mul (ne_of_gt ha) (ne_of_gt hb), Real.log_pow] at hlog
  push_cast at hlog
  linarith

omit [Nonempty Ω] in
/-- The midpoint of two positive policies is a positive policy. -/
theorem isPosDist_midpoint {q₁ q₂ : Ω → ℝ} (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂) :
    IsPosDist (fun y => (q₁ y + q₂ y) / 2) := by
  refine ⟨fun y => by have := h₁.1 y; have := h₂.1 y; linarith, ?_⟩
  have : ∑ y, (q₁ y + q₂ y) / 2 = (∑ y, q₁ y + ∑ y, q₂ y) / 2 := by
    rw [← Finset.sum_add_distrib, Finset.sum_div]
  rw [this, h₁.2, h₂.2]
  norm_num

omit [Nonempty Ω] in
/-- Pointwise decomposition of the PTX objective into a sum over the response space. -/
theorem objectivePTX_eq_sum {β γ : ℝ} {r p d q : Ω → ℝ} :
    objectivePTX β γ r p d q
      = ∑ y, (q y * r y - β * (q y * Real.log (q y / p y)) + γ * (d y * Real.log (q y))) := by
  unfold objectivePTX objective klDiv
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]

omit [Nonempty Ω] in
/-- **Strict concavity of the PTX objective.**  The RLHF+PTX objective is strictly concave
along midpoints of distinct positive policies, even though (unlike the pure RLHF objective)
it has no closed-form Gibbs maximizer. -/
theorem objectivePTX_midpoint_gt {β γ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂)
    (hne : q₁ ≠ q₂) :
    (objectivePTX β γ r p d q₁ + objectivePTX β γ r p d q₂) / 2
      < objectivePTX β γ r p d (fun y => (q₁ y + q₂ y) / 2) := by
  obtain ⟨y₀, hy₀⟩ : ∃ y, q₁ y ≠ q₂ y := by
    by_contra hc
    exact hne (funext fun y => not_not.mp fun h => hc ⟨y, h⟩)
  set f : (Ω → ℝ) → Ω → ℝ := fun q y =>
    q y * r y - β * (q y * Real.log (q y / p y)) + γ * (d y * Real.log (q y)) with hf
  set m : Ω → ℝ := fun y => (q₁ y + q₂ y) / 2 with hm
  have hpoint : ∀ y ∈ (univ : Finset Ω), (f q₁ y + f q₂ y) / 2 ≤ f m y := by
    intro y _
    have ha := h₁.1 y
    have hb := h₂.1 y
    have hklle : m y * Real.log (m y / p y)
        ≤ (q₁ y * Real.log (q₁ y / p y) + q₂ y * Real.log (q₂ y / p y)) / 2 := by
      rcases eq_or_ne (q₁ y) (q₂ y) with h | h
      · simp only [hm, h]
        have : (q₂ y + q₂ y) / 2 = q₂ y := by ring
        rw [this]
        linarith
      · exact (mul_log_div_midpoint_lt ha hb (hp.1 y) h).le
    have hlogge : (Real.log (q₁ y) + Real.log (q₂ y)) / 2 ≤ Real.log (m y) :=
      log_midpoint_ge ha hb
    have hd' : γ * (d y * ((Real.log (q₁ y) + Real.log (q₂ y)) / 2))
        ≤ γ * (d y * Real.log (m y)) := by
      have := mul_le_mul_of_nonneg_left hlogge (hd y)
      exact mul_le_mul_of_nonneg_left this hγ
    have hklmul : β * (m y * Real.log (m y / p y))
        ≤ β * ((q₁ y * Real.log (q₁ y / p y) + q₂ y * Real.log (q₂ y / p y)) / 2) :=
      mul_le_mul_of_nonneg_left hklle hβ.le
    simp only [hf, hm]
    simp only [hm] at hklmul hd'
    nlinarith [hklmul, hd']
  have hstrict : (f q₁ y₀ + f q₂ y₀) / 2 < f m y₀ := by
    have ha := h₁.1 y₀
    have hb := h₂.1 y₀
    have hkllt : m y₀ * Real.log (m y₀ / p y₀)
        < (q₁ y₀ * Real.log (q₁ y₀ / p y₀) + q₂ y₀ * Real.log (q₂ y₀ / p y₀)) / 2 :=
      mul_log_div_midpoint_lt ha hb (hp.1 y₀) hy₀
    have hlogge : (Real.log (q₁ y₀) + Real.log (q₂ y₀)) / 2 ≤ Real.log (m y₀) :=
      log_midpoint_ge ha hb
    have hd' : γ * (d y₀ * ((Real.log (q₁ y₀) + Real.log (q₂ y₀)) / 2))
        ≤ γ * (d y₀ * Real.log (m y₀)) := by
      have := mul_le_mul_of_nonneg_left hlogge (hd y₀)
      exact mul_le_mul_of_nonneg_left this hγ
    have hklmul : β * (m y₀ * Real.log (m y₀ / p y₀))
        < β * ((q₁ y₀ * Real.log (q₁ y₀ / p y₀) + q₂ y₀ * Real.log (q₂ y₀ / p y₀)) / 2) :=
      mul_lt_mul_of_pos_left hkllt hβ
    simp only [hf, hm]
    simp only [hm] at hklmul hd'
    nlinarith [hklmul, hd']
  have hsum : ∑ y, (f q₁ y + f q₂ y) / 2 < ∑ y, f m y :=
    Finset.sum_lt_sum hpoint ⟨y₀, mem_univ _, hstrict⟩
  have hleft : ∑ y, (f q₁ y + f q₂ y) / 2
      = (objectivePTX β γ r p d q₁ + objectivePTX β γ r p d q₂) / 2 := by
    rw [objectivePTX_eq_sum (q := q₁), objectivePTX_eq_sum (q := q₂), ← Finset.sum_add_distrib,
      ← Finset.sum_div]
  have hright : ∑ y, f m y = objectivePTX β γ r p d m := (objectivePTX_eq_sum (q := m)).symm
  rw [hleft, hright] at hsum
  exact hsum

omit [Nonempty Ω] in
/-- **Uniqueness of the PTX-aligned policy.**  Any two positive maximizers of the RLHF+PTX
objective coincide.  Together with `alignment_tax` this pins down the geometry of PPO-ptx:
the optimum is unique but never attains the decoupled ceiling. -/
theorem ptx_maximizer_unique {β γ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂)
    (hmax₁ : ∀ q, IsPosDist q → objectivePTX β γ r p d q ≤ objectivePTX β γ r p d q₁)
    (hmax₂ : ∀ q, IsPosDist q → objectivePTX β γ r p d q ≤ objectivePTX β γ r p d q₂) :
    q₁ = q₂ := by
  by_contra hne
  have hmid := objectivePTX_midpoint_gt (β := β) (γ := γ) (r := r) (p := p) (d := d)
    hβ hγ hp hd h₁ h₂ hne
  have hle := hmax₁ _ (isPosDist_midpoint h₁ h₂)
  have h12 : objectivePTX β γ r p d q₂ ≤ objectivePTX β γ r p d q₁ := hmax₁ _ h₂
  have h21 : objectivePTX β γ r p d q₁ ≤ objectivePTX β γ r p d q₂ := hmax₂ _ h₁
  linarith

/-- The pure RLHF optimum (`γ = 0`) is the Gibbs policy, recovered as the unique maximizer
through the concavity route: a consistency check tying §3 back to `variational_strict`. -/
theorem gibbs_is_unique_maximizer {β : ℝ} {r p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsPosDist q)
    (hmax : ∀ q', IsDist q' → objective β r p q' ≤ objective β r p q) :
    q = gibbsPolicy β r p := by
  by_contra hne
  have hlt : objective β r p q < freeEnergy β r p := variational_strict hβ hp hq.isDist hne
  have hge : freeEnergy β r p ≤ objective β r p q := by
    have := hmax _ (gibbsPolicy_isPosDist (β := β) (r := r) hp).isDist
    rwa [objective_gibbs hβ hp] at this
  linarith

end RLHF