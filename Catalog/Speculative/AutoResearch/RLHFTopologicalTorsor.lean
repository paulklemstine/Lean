import Algebra.RLHFTiltTorsorPTX

/-!
# The alignment torsor is a *topological* torsor

`Algebra.RLHFTiltTorsorPTX` shows that, for a fixed SFT reference policy `p`, exponential
tilting is a bijection between reward models modulo the constant gauge group and strictly
positive policies (`RLHF.tiltEquiv`).  Here that algebraic statement is upgraded to a
cross-domain one: choosing the *mean-zero* gauge representative, the bijection

```
{r : Ω → ℝ | ∑ y, r y = 0}  ≃  {q : Ω → ℝ | q strictly positive probability distribution}
```

is a **homeomorphism** (`RLHF.tiltHomeomorph`), with inverse given by the centered DPO implicit
reward `β log (q / p) − mean`.  Consequences:

* `RLHF.continuous_gibbsPolicy_reward` — the aligned policy depends continuously on the reward
  model (stability of alignment under reward-model perturbation);
* `RLHF.continuous_centeredImplicit` — the recovered reward depends continuously on the policy
  (stability of DPO-style reward extraction), *on the strictly positive policies only*: the
  homeomorphism genuinely lives on the interior of the simplex, and degenerates at the
  boundary, which is the precise mathematical content of "policy collapse".

All results are `sorry`-free.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

instance : TopologicalSpace (PosPolicy Ω) :=
  inferInstanceAs (TopologicalSpace {q : Ω → ℝ // IsPosDist q})

/-- Mean-zero reward models: the canonical gauge slice of `constRewards`. -/
def CenteredRewards (Ω : Type*) [Fintype Ω] : Type _ := {r : Ω → ℝ // ∑ y, r y = 0}

instance : TopologicalSpace (CenteredRewards Ω) :=
  inferInstanceAs (TopologicalSpace {r : Ω → ℝ // ∑ y, r y = 0})

/-! ## 1. The centered implicit reward -/

/-- The centered DPO implicit reward: `β log (q / p)` with its mean subtracted. -/
noncomputable def centeredImplicit (β : ℝ) (p q : Ω → ℝ) : Ω → ℝ :=
  fun y => implicitReward β p q y - (∑ z, implicitReward β p q z) / (Fintype.card Ω : ℝ)

theorem sum_centeredImplicit {β : ℝ} {p q : Ω → ℝ} : ∑ y, centeredImplicit β p q y = 0 := by
  have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  unfold centeredImplicit
  rw [Finset.sum_sub_distrib, Finset.sum_const, card_univ, nsmul_eq_mul]
  field_simp
  ring

/-- Tilting by the centered implicit reward recovers the policy. -/
theorem gibbs_centeredImplicit {β : ℝ} {p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsPosDist q) : gibbsPolicy β (centeredImplicit β p q) p = q := by
  have hshift : centeredImplicit β p q
      = fun y => implicitReward β p q y + (-((∑ z, implicitReward β p q z) /
        (Fintype.card Ω : ℝ))) := by
    funext y
    simp [centeredImplicit, sub_eq_add_neg]
  rw [hshift, gibbsPolicy_shift hp]
  exact gibbs_implicitReward hβ hp hq

/-- Conversely, a mean-zero reward is recovered from the policy it induces. -/
theorem centeredImplicit_gibbs {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hr : ∑ y, r y = 0) : centeredImplicit β p (gibbsPolicy β r p) = r := by
  have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hZ : 0 < partition β r p := partition_pos (β := β) (r := r) hp
  have hβ0 : β ≠ 0 := ne_of_gt hβ
  -- the implicit reward of the Gibbs policy is `r` shifted by the free energy
  have himpl : ∀ y, implicitReward β p (gibbsPolicy β r p) y
      = r y - β * Real.log (partition β r p) := by
    intro y
    have hpy := hp.1 y
    unfold implicitReward gibbsPolicy
    rw [show p y * Real.exp (r y / β) / partition β r p / p y
        = Real.exp (r y / β) / partition β r p by field_simp,
      Real.log_div (Real.exp_ne_zero _) (ne_of_gt hZ), Real.log_exp]
    field_simp
  have hsum : ∑ z, implicitReward β p (gibbsPolicy β r p) z
      = -((Fintype.card Ω : ℝ) * (β * Real.log (partition β r p))) := by
    rw [Finset.sum_congr rfl (fun z _ => himpl z), Finset.sum_sub_distrib, hr,
      Finset.sum_const, card_univ, nsmul_eq_mul]
    ring
  funext y
  unfold centeredImplicit
  rw [himpl y, hsum]
  field_simp
  ring

/-! ## 2. Continuity of both directions -/

omit [Nonempty Ω] in
theorem continuous_partition {β : ℝ} {p : Ω → ℝ} :
    Continuous (fun r : Ω → ℝ => partition β r p) := by
  unfold partition
  fun_prop

/-- **Stability of alignment.**  The aligned policy depends continuously on the reward model. -/
theorem continuous_gibbsPolicy_reward {β : ℝ} {p : Ω → ℝ} (hp : IsPosDist p) :
    Continuous (fun r : Ω → ℝ => gibbsPolicy β r p) := by
  refine continuous_pi (fun y => ?_)
  exact Continuous.div (by fun_prop) continuous_partition
    (fun r => ne_of_gt (partition_pos (β := β) (r := r) hp))

omit [Nonempty Ω] in
/-- **Stability of reward extraction.**  On strictly positive policies the centered implicit
reward depends continuously on the policy. -/
theorem continuous_centeredImplicit {β : ℝ} {p : Ω → ℝ} (hp : IsPosDist p) :
    Continuous (fun q : PosPolicy Ω => centeredImplicit β p q.1) := by
  have hlog : ∀ y : Ω, Continuous (fun q : PosPolicy Ω => Real.log (q.1 y / p y)) := by
    intro y
    rw [continuous_iff_continuousAt]
    intro q
    have hbase : ContinuousAt (fun q' : PosPolicy Ω => q'.1 y / p y) q :=
      ((continuous_apply y).comp continuous_subtype_val).continuousAt.div_const _
    exact hbase.log (by
      have := q.2.1 y
      have hpy := hp.1 y
      positivity)
  have hcomp : ∀ y : Ω, Continuous (fun q : PosPolicy Ω => implicitReward β p q.1 y) :=
    fun y => continuous_const.mul (hlog y)
  refine continuous_pi (fun y => ?_)
  unfold centeredImplicit
  exact (hcomp y).sub ((continuous_finset_sum univ fun z _ => hcomp z).div_const _)

/-! ## 3. The topological torsor -/

/-- The tilting bijection in the mean-zero gauge. -/
noncomputable def tiltCenteredEquiv (β : ℝ) (hβ : 0 < β) {p : Ω → ℝ} (hp : IsPosDist p) :
    CenteredRewards Ω ≃ PosPolicy Ω where
  toFun r := ⟨gibbsPolicy β r.1 p, gibbsPolicy_isPosDist hp⟩
  invFun q := ⟨centeredImplicit β p q.1, sum_centeredImplicit⟩
  left_inv r := Subtype.ext (centeredImplicit_gibbs hβ hp r.2)
  right_inv q := Subtype.ext (gibbs_centeredImplicit hβ hp q.2)

/-- **The alignment torsor is a topological torsor.**  Tilting is a homeomorphism between
mean-zero reward models and strictly positive policies; the inverse is the centered DPO
implicit reward.  Reward-modulo-gauge and aligned policy are therefore the same object not only
as sets but as topological spaces. -/
noncomputable def tiltHomeomorph (β : ℝ) (hβ : 0 < β) {p : Ω → ℝ} (hp : IsPosDist p) :
    CenteredRewards Ω ≃ₜ PosPolicy Ω where
  toEquiv := tiltCenteredEquiv β hβ hp
  continuous_toFun := by
    apply Continuous.subtype_mk
    exact (continuous_gibbsPolicy_reward (β := β) hp).comp continuous_subtype_val
  continuous_invFun := by
    apply Continuous.subtype_mk
    exact continuous_centeredImplicit (β := β) hp

/-- The homeomorphism intertwines the tilting action with translation of rewards: acting by a
mean-zero reward `s` translates the centered coordinate by `s`. -/
theorem tiltHomeomorph_vadd {β : ℝ} (hβ : 0 < β) {p : Ω → ℝ} (hp : IsPosDist p)
    (r s : CenteredRewards Ω) :
    tiltAct β s.1 (tiltHomeomorph β hβ hp r)
      = tiltHomeomorph β hβ hp ⟨fun y => r.1 y + s.1 y, by
          rw [Finset.sum_add_distrib, r.2, s.2]; ring⟩ := by
  apply Subtype.ext
  exact gibbs_compose (β := β) (r₁ := r.1) (r₂ := s.1) hp

end RLHF