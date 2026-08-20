import Catalog.NumberTheory.RLHFVarianceCurvature
import Catalog.NumberTheory.RLHFZetaEulerPolicy

/-!
# Sharpness of the alignment speed limit, and curvature of the Euler factors

This file closes two of the three next-cycle sub-conjectures recorded in
`FUTURE_DIRECTIONS.md` after the curvature identity
`RLHF.deriv2_logExpMoment_eq_tiltVar` was proved.

**Sub-conjecture 1 (sharpness of the speed limit).**  `RLHF.tiltVar_le_range_sq` caps the
reward variance of a model confined to `[m, M]` by `(M − m)²/4`, and
`RLHF.tiltMean_drift_le` turns that into a temperature-uniform speed limit for alignment.
Here we show that the constant `1/4` cannot be improved and describe exactly when it is
attained:

* `RLHF.tiltVar_shift` — the variance of the tilted policy computed around an arbitrary
  centre.
* `RLHF.tiltVar_eq_range_sq_iff` — **the equality analysis**: the Popoviciu ceiling is
  attained at a temperature `t` if and only if the reward model is two-valued, taking only
  the extreme values `m` and `M`, *and* the tilted policy splits its mass evenly between the
  two levels (equivalently `𝔼_{π_t}[r] = (m+M)/2`).
* `RLHF.twoAtom_tiltVar`, `RLHF.twoAtom_tiltVar_zero` — the extremal model: the two-atom
  reward `r ∈ {0,1}` with balanced reference has `Var_{π_t}(r) = e^t/(1+e^t)²`, equal to
  `1/4` at `t = 0`.
* `RLHF.popoviciu_constant_sharp` and `RLHF.tiltMean_drift_constant_sharp` — consequently no
  constant below `1/4` can appear either in the variance ceiling or in the drift bound; the
  second statement is a genuine derivative argument (the slope of the logistic alignment
  curve at the origin).

**Sub-conjecture 2 (curvature of the Euler factors).**  The local zeta factor
`localZeta s p A = ∑_{k ≤ A} p^{-ks}` is the RLHF partition function of the reward
`k ↦ −k log p` on the exponent space `{0, …, A}` with uniform reference:

* `RLHF.expMoment_zero_geomReward` — the identification.
* `RLHF.convexOn_logLocalZeta`, `RLHF.strictConvexOn_logLocalZeta` — each Euler factor is
  log-convex in the exponent, strictly so for `p ≥ 2` and `A ≥ 1`.
* `RLHF.localZeta_curvature_eq_variance` — `d²/ds² log localZeta = Var(k log p)` under the
  truncated geometric law on exponents.
* `RLHF.zetaSum_curvature_additive` — **additive curvature decomposition**: the curvature of
  the truncated Euler product is the sum of the per-prime curvatures.  Alignment "difficulty"
  is a sum of independent local contributions.
-/

namespace RLHF

open Finset Filter Topology

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Variance around an arbitrary centre -/

/-- The variance of the reward under the tilted policy, computed around an arbitrary centre
`a`: `Var = 𝔼(r − a)² − (𝔼r − a)²`. -/
theorem tiltVar_shift {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) (a t : ℝ) :
    tiltVar r p t
      = (∑ y, tiltWeight r p t y * (r y - a) ^ 2) - (tiltMean r p t - a) ^ 2 := by
  have h1 : ∀ y, tiltWeight r p t y * (r y - a) ^ 2
      = tiltWeight r p t y * r y ^ 2 - 2 * a * (tiltWeight r p t y * r y ^ 1)
        + a ^ 2 * tiltWeight r p t y := by
    intro y; ring
  rw [Finset.sum_congr rfl (fun y _ => h1 y), Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, tiltWeight_moment 2 r p t, tiltWeight_moment 1 r p t,
    tiltWeight_sum hp t]
  have hmm : tiltMean r p t = expMoment 1 r p t / expMoment 0 r p t := rfl
  unfold tiltVar
  rw [hmm]
  ring

/-! ## 2. Equality analysis for the Popoviciu ceiling -/

/-- **Equality in the Popoviciu ceiling.**  For a reward model confined to `[m, M]` the
variance under the tilted policy equals `(M − m)²/4` exactly when the model is two-valued
with values the endpoints and the tilted mean sits at the midpoint. -/
theorem tiltVar_eq_range_sq_iff {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {m M : ℝ}
    (hm : ∀ y, m ≤ r y) (hM : ∀ y, r y ≤ M) (t : ℝ) :
    tiltVar r p t = (M - m) ^ 2 / 4 ↔
      ((∀ y, r y = m ∨ r y = M) ∧ tiltMean r p t = (m + M) / 2) := by
  set a := (m + M) / 2 with ha
  have hkey := tiltVar_shift (r := r) hp a t
  have hw := tiltWeight_pos (r := r) hp t
  have hsum := tiltWeight_sum (r := r) hp t
  constructor
  · intro heq
    have hterm : ∀ y ∈ (univ : Finset Ω),
        tiltWeight r p t y * (r y - a) ^ 2 ≤ tiltWeight r p t y * ((M - m) ^ 2 / 4) := by
      intro y _
      have h1 := hm y
      have h2 := hM y
      have hsq : (r y - a) ^ 2 ≤ (M - m) ^ 2 / 4 := by
        rw [ha]; nlinarith [sq_nonneg (r y - a)]
      exact mul_le_mul_of_nonneg_left hsq (hw y).le
    have hle : ∑ y, tiltWeight r p t y * (r y - a) ^ 2 ≤ (M - m) ^ 2 / 4 := by
      have := Finset.sum_le_sum hterm
      rwa [← Finset.sum_mul, hsum, one_mul] at this
    have hmid : tiltMean r p t = a := by
      have hsq : (tiltMean r p t - a) ^ 2 ≤ 0 := by
        rw [heq] at hkey; linarith
      have := sq_nonneg (tiltMean r p t - a)
      have hz : tiltMean r p t - a = 0 := by
        have : (tiltMean r p t - a) ^ 2 = 0 := le_antisymm hsq this
        exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
      linarith
    have hSeq : ∑ y, tiltWeight r p t y * (r y - a) ^ 2
        = ∑ y, tiltWeight r p t y * ((M - m) ^ 2 / 4) := by
      rw [← Finset.sum_mul, hsum, one_mul]
      rw [heq, hmid] at hkey
      simpa using hkey.symm
    have hall := (Finset.sum_eq_sum_iff_of_le hterm).mp hSeq
    refine ⟨fun y => ?_, by rw [hmid, ha]⟩
    have hy := hall y (Finset.mem_univ y)
    have hcancel : (r y - a) ^ 2 = (M - m) ^ 2 / 4 :=
      mul_left_cancel₀ (ne_of_gt (hw y)) hy
    have hfac : (r y - M) * (r y - m) = 0 := by
      rw [ha] at hcancel; nlinarith [hcancel]
    rcases mul_eq_zero.mp hfac with h | h
    · exact Or.inr (by linarith)
    · exact Or.inl (by linarith)
  · rintro ⟨hvals, hmean⟩
    have hterm : ∀ y ∈ (univ : Finset Ω),
        tiltWeight r p t y * (r y - a) ^ 2 = tiltWeight r p t y * ((M - m) ^ 2 / 4) := by
      intro y _
      rcases hvals y with h | h <;> rw [h, ha] <;> ring
    have hS : ∑ y, tiltWeight r p t y * (r y - a) ^ 2 = (M - m) ^ 2 / 4 := by
      rw [Finset.sum_congr rfl hterm, ← Finset.sum_mul, hsum, one_mul]
    have hz : tiltMean r p t - a = 0 := by rw [hmean, ha]; ring
    rw [hkey, hS, hz]
    ring

/-! ## 3. The extremal two-atom model -/

/-- The extremal reward model: two responses, rewards `0` and `1`. -/
def twoReward : Bool → ℝ := fun b => if b then 1 else 0

/-- The balanced reference policy on two responses. -/
noncomputable def twoRef : Bool → ℝ := fun _ => 1 / 2

theorem twoRef_pos : ∀ b : Bool, 0 < twoRef b := by
  intro b; unfold twoRef; norm_num

theorem twoReward_lower : ∀ b : Bool, (0 : ℝ) ≤ twoReward b := by
  intro b; cases b <;> simp [twoReward]

theorem twoReward_upper : ∀ b : Bool, twoReward b ≤ 1 := by
  intro b; cases b <;> simp [twoReward]

theorem twoAtom_expMoment_zero (t : ℝ) :
    expMoment 0 twoReward twoRef t = (Real.exp t + 1) / 2 := by
  simp [expMoment, twoReward, twoRef]
  ring

theorem twoAtom_expMoment_one (t : ℝ) :
    expMoment 1 twoReward twoRef t = Real.exp t / 2 := by
  simp [expMoment, twoReward, twoRef]
  ring

theorem twoAtom_expMoment_two (t : ℝ) :
    expMoment 2 twoReward twoRef t = Real.exp t / 2 := by
  simp [expMoment, twoReward, twoRef]
  ring

/-- The aligned expected reward of the two-atom model is the logistic curve. -/
theorem twoAtom_tiltMean (t : ℝ) :
    tiltMean twoReward twoRef t = Real.exp t / (Real.exp t + 1) := by
  have hpos : (0 : ℝ) < Real.exp t + 1 := by positivity
  unfold tiltMean
  rw [twoAtom_expMoment_one, twoAtom_expMoment_zero]
  field_simp

/-- The reward variance of the two-atom model, `e^t/(1+e^t)²`. -/
theorem twoAtom_tiltVar (t : ℝ) :
    tiltVar twoReward twoRef t = Real.exp t / (Real.exp t + 1) ^ 2 := by
  have hpos : (0 : ℝ) < Real.exp t + 1 := by positivity
  unfold tiltVar
  rw [twoAtom_expMoment_two, twoAtom_expMoment_zero, twoAtom_tiltMean]
  field_simp
  ring

/-- At the balanced temperature the two-atom model attains the Popoviciu ceiling. -/
theorem twoAtom_tiltVar_zero : tiltVar twoReward twoRef 0 = 1 / 4 := by
  rw [twoAtom_tiltVar]
  norm_num

/-- **The constant `1/4` in `RLHF.tiltVar_le_range_sq` is optimal.**  Any constant valid as a
temperature-uniform variance ceiling for reward models with range `1` is at least `1/4`. -/
theorem popoviciu_constant_sharp {C : ℝ} (h : ∀ t : ℝ, tiltVar twoReward twoRef t ≤ C) :
    1 / 4 ≤ C := by
  have := h 0
  rwa [twoAtom_tiltVar_zero] at this

theorem twoAtom_hasDerivAt_zero : HasDerivAt (tiltMean twoReward twoRef) (1 / 4) 0 := by
  have h := hasDerivAt_tiltMean (r := twoReward) twoRef_pos 0
  rwa [twoAtom_tiltVar_zero] at h

/-- **The constant `1/4` in the alignment speed limit `RLHF.tiltMean_drift_le` is optimal.**
If the aligned reward of the two-atom model drifts at most at rate `C`, then `1/4 ≤ C`. -/
theorem tiltMean_drift_constant_sharp {C : ℝ}
    (h : ∀ t : ℝ, 0 ≤ t → tiltMean twoReward twoRef t - tiltMean twoReward twoRef 0 ≤ t * C) :
    1 / 4 ≤ C := by
  have hd := twoAtom_hasDerivAt_zero
  rw [hasDerivAt_iff_tendsto_slope] at hd
  have hsub : 𝓝[>] (0 : ℝ) ≤ 𝓝[≠] (0 : ℝ) :=
    nhdsWithin_mono _ (fun x hx => ne_of_gt hx)
  have h2 : Tendsto (slope (tiltMean twoReward twoRef) 0) (𝓝[>] (0 : ℝ)) (𝓝 (1 / 4)) :=
    hd.mono_left hsub
  refine le_of_tendsto h2 ?_
  filter_upwards [self_mem_nhdsWithin] with t ht
  have htpos : (0 : ℝ) < t := ht
  have hbound := h t htpos.le
  rw [slope_def_field, sub_zero, div_le_iff₀ htpos]
  linarith [hbound]

/-! ## 4. Curvature of the Euler factors -/

/-- The reward model on the exponent space `{0, …, A}` of a single prime: `k ↦ −k log p`. -/
noncomputable def geomReward (p A : ℕ) : Fin (A + 1) → ℝ :=
  fun a => -((a : ℕ) : ℝ) * Real.log p

/-- The local Euler factor is (up to the uniform normalization) the RLHF partition function
of the reward `k ↦ −k log p`. -/
theorem expMoment_zero_geomReward {p A : ℕ} (hp : 0 < p) (s : ℝ) :
    expMoment 0 (geomReward p A) (unifWeight (A + 1)) s
      = ((A : ℝ) + 1)⁻¹ * localZeta s p A := by
  have hp' : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  unfold expMoment geomReward unifWeight localZeta zetaWeight
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  have hcast : (((p ^ (a : ℕ) : ℕ)) : ℝ) = (p : ℝ) ^ (a : ℕ) := by push_cast; ring
  have hval : Real.exp (-((a : ℕ) : ℝ) * Real.log p * s)
      = (((p ^ (a : ℕ) : ℕ)) : ℝ) ^ (-s) := by
    rw [hcast, ← Real.rpow_natCast (p : ℝ) (a : ℕ), ← Real.rpow_mul hp'.le,
      Real.rpow_def_of_pos hp']
    congr 1
    ring
  rw [pow_zero, mul_one, hval]
  push_cast
  ring

theorem logExpMoment_geomReward {p A : ℕ} (hp : 0 < p) :
    (fun s => Real.log (expMoment 0 (geomReward p A) (unifWeight (A + 1)) s))
      = fun s => Real.log (localZeta s p A) + (-Real.log ((A : ℝ) + 1)) := by
  funext s
  have hA : (0 : ℝ) < (A : ℝ) + 1 := by positivity
  have hL : (0 : ℝ) < localZeta s p A := localZeta_pos hp
  rw [expMoment_zero_geomReward hp, Real.log_mul (by positivity) (ne_of_gt hL), Real.log_inv]
  ring

private theorem shift_back_localZeta (p A : ℕ) :
    ((fun s => Real.log (localZeta s p A) + (-Real.log ((A : ℝ) + 1)))
        + fun _ => Real.log ((A : ℝ) + 1))
      = fun s => Real.log (localZeta s p A) := by
  funext s
  simp

theorem hasDerivAt_logLocalZeta {p A : ℕ} (hp : 0 < p) (s : ℝ) :
    HasDerivAt (fun s => Real.log (localZeta s p A))
      (tiltMean (geomReward p A) (unifWeight (A + 1)) s) s := by
  have h := hasDerivAt_logExpMoment (r := geomReward p A)
    (unifWeight_pos (Nat.succ_pos A)) s
  rw [logExpMoment_geomReward hp] at h
  simpa using h.sub_const (-Real.log ((A : ℝ) + 1))

/-- **Each Euler factor is log-convex in the exponent.** -/
theorem convexOn_logLocalZeta {p A : ℕ} (hp : 0 < p) :
    ConvexOn ℝ Set.univ (fun s => Real.log (localZeta s p A)) := by
  have hconv := convexOn_logExpMoment (r := geomReward p A) (unifWeight_pos (Nat.succ_pos A))
  rw [logExpMoment_geomReward hp] at hconv
  rw [← shift_back_localZeta p A]
  exact hconv.add_const _

/-- **Strict log-convexity of the Euler factors** for a genuine prime bound `p ≥ 2` and a
non-trivial exponent range `A ≥ 1`. -/
theorem strictConvexOn_logLocalZeta {p A : ℕ} (hp : 2 ≤ p) (hA : 1 ≤ A) :
    StrictConvexOn ℝ Set.univ (fun s => Real.log (localZeta s p A)) := by
  have hp0 : 0 < p := by omega
  have hlogp : 0 < Real.log p := Real.log_pos (by exact_mod_cast hp)
  have hne : geomReward p A ⟨0, by omega⟩ ≠ geomReward p A ⟨1, by omega⟩ := by
    unfold geomReward
    simp only [Nat.cast_zero, Nat.cast_one, neg_zero, zero_mul, neg_mul, one_mul]
    intro h
    linarith [h.symm.trans_gt (neg_neg_iff_pos.mpr hlogp)]
  have hconv := strictConvexOn_logExpMoment (r := geomReward p A)
    (unifWeight_pos (Nat.succ_pos A)) hne
  rw [logExpMoment_geomReward hp0] at hconv
  rw [← shift_back_localZeta p A]
  exact hconv.add_const _

/-- **The curvature of an Euler factor is a variance**: `d²/ds² log localZeta` is the
variance of `k log p` under the truncated geometric law on exponents `k ≤ A`. -/
theorem localZeta_curvature_eq_variance {p A : ℕ} (hp : 0 < p) :
    deriv^[2] (fun s => Real.log (localZeta s p A))
      = tiltVar (geomReward p A) (unifWeight (A + 1)) := by
  have hderiv1 : deriv (fun s => Real.log (localZeta s p A))
      = tiltMean (geomReward p A) (unifWeight (A + 1)) := by
    funext s
    exact (hasDerivAt_logLocalZeta hp s).deriv
  have hderiv2 : deriv (tiltMean (geomReward p A) (unifWeight (A + 1)))
      = tiltVar (geomReward p A) (unifWeight (A + 1)) :=
    deriv_tiltMean (unifWeight_pos (Nat.succ_pos A))
  have h2 : deriv^[2] (fun s => Real.log (localZeta s p A))
      = deriv (deriv (fun s => Real.log (localZeta s p A))) := by
    simp [Function.iterate_succ]
  rw [h2, hderiv1, hderiv2]

/-- **Additive curvature decomposition of the truncated Euler product.**  The curvature of
the log-partition function of the two-prime smooth-number model is the sum of the two local
curvatures: alignment difficulty is additive over primes. -/
theorem zetaSum_curvature_additive {p q A B : ℕ} (hp : 0 < p) (hq : 0 < q) :
    deriv^[2] (fun s => Real.log (zetaSum s p q A B))
      = tiltVar (geomReward p A) (unifWeight (A + 1))
        + tiltVar (geomReward q B) (unifWeight (B + 1)) := by
  have hlog : (fun s => Real.log (zetaSum s p q A B))
      = fun s => Real.log (localZeta s p A) + Real.log (localZeta s q B) := by
    funext s
    rw [zeta_partition_factorizes hp hq,
      Real.log_mul (ne_of_gt (localZeta_pos hp)) (ne_of_gt (localZeta_pos hq))]
  have hderiv1 : deriv (fun s => Real.log (localZeta s p A) + Real.log (localZeta s q B))
      = fun s => tiltMean (geomReward p A) (unifWeight (A + 1)) s
          + tiltMean (geomReward q B) (unifWeight (B + 1)) s := by
    funext s
    exact ((hasDerivAt_logLocalZeta hp s).add (hasDerivAt_logLocalZeta hq s)).deriv
  have hderiv2 : (deriv fun s => tiltMean (geomReward p A) (unifWeight (A + 1)) s
        + tiltMean (geomReward q B) (unifWeight (B + 1)) s)
      = fun s => tiltVar (geomReward p A) (unifWeight (A + 1)) s
          + tiltVar (geomReward q B) (unifWeight (B + 1)) s := by
    funext s
    exact ((hasDerivAt_tiltMean (unifWeight_pos (Nat.succ_pos A)) s).add
      (hasDerivAt_tiltMean (unifWeight_pos (Nat.succ_pos B)) s)).deriv
  have h2 : deriv^[2] (fun s => Real.log (zetaSum s p q A B))
      = deriv (deriv (fun s => Real.log (zetaSum s p q A B))) := by
    simp [Function.iterate_succ]
  rw [h2, hlog, hderiv1, hderiv2]
  rfl

end RLHF