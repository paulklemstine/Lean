import Cryptography.Transreal.Boundary

/-!
# Poles: exactly which unguarded quotients still transfer

The conjecture behind this development says that unguarded division "generally"
fails to transfer continuously.  *Generally* turns out to be exactly right, and
this file computes the boundary.  At a zero `x₀` of the denominator, with the
denominator nonvanishing on a punctured neighbourhood, there are three regimes:

1. **`0/0`** (the numerator vanishes too).  The value jumps to the isolated
   point `null` while nearby values are finite, so the quotient is discontinuous
   — and this needs no continuity hypothesis whatsoever
   (`Transreal.not_continuousAt_of_common_zero`).
2. **One-signed pole** (numerator positive, denominator of constant sign near
   `x₀`).  The quotient *is* continuous at `x₀`, with value `pinf`
   (`Transreal.continuousAt_div_of_positive_pole`).  So the four-constructor
   carrier really does absorb even-order poles: unguarded division is *not*
   uniformly bad.
3. **Sign-changing pole** (numerator positive, denominator changing sign).  The
   one-sided limits are `pinf` and `ninf`, which are distinct in a Hausdorff
   topology, so the quotient is discontinuous
   (`Transreal.not_continuousAt_of_sign_change`).

The upshot for the transfer principle: the nowhere-vanishing guard is
*sufficient* (`TExpr.continuous_transEval`) and cannot be dropped
(`TExpr.unguarded_fails_of_t1`), but it is not *necessary* — the exact necessary
and sufficient condition at an isolated denominator zero is the trichotomy
above.  Regime 2 is the reason the failure statement must be phrased with
"generally".
-/

namespace Transreal

open Set Filter Topology

/-! ### Limits of transreal quotients -/

/-- If the numerator tends to a positive constant and the denominator tends to
`0` from above, the transreal quotient tends to `pinf` in the natural topology. -/
theorem tendsto_transDiv_pinf {l : Filter ℝ} {f g : ℝ → ℝ} {C : ℝ} (hC : 0 < C)
    (hf : Tendsto f l (𝓝 C)) (hg : Tendsto g l (𝓝[>] 0)) :
    Tendsto (fun x => fin (f x) / fin (g x)) l (𝓝 pinf) := by
  have hgpos : ∀ᶠ x in l, g x ∈ Set.Ioi (0 : ℝ) := hg self_mem_nhdsWithin
  have hinv : Tendsto (fun x => (g x)⁻¹) l atTop := hg.inv_tendsto_nhdsGT_zero
  have hmul : Tendsto (fun x => f x * (g x)⁻¹) l atTop := hf.pos_mul_atTop hC hinv
  have hfin : Tendsto (fun x => fin (f x * (g x)⁻¹)) l (𝓝 pinf) := tendsto_fin_atTop.comp hmul
  refine hfin.congr' ?_
  filter_upwards [hgpos] with x hx
  rw [fin_div_fin_of_ne (ne_of_gt hx), div_eq_mul_inv]

/-- If the numerator tends to a positive constant and the denominator tends to
`0` from below, the transreal quotient tends to `ninf`. -/
theorem tendsto_transDiv_ninf {l : Filter ℝ} {f g : ℝ → ℝ} {C : ℝ} (hC : 0 < C)
    (hf : Tendsto f l (𝓝 C)) (hg : Tendsto g l (𝓝[<] 0)) :
    Tendsto (fun x => fin (f x) / fin (g x)) l (𝓝 ninf) := by
  have hgneg : ∀ᶠ x in l, g x ∈ Set.Iio (0 : ℝ) := hg self_mem_nhdsWithin
  have hinv : Tendsto (fun x => (g x)⁻¹) l atBot := hg.inv_tendsto_nhdsLT_zero
  have hmul : Tendsto (fun x => f x * (g x)⁻¹) l atBot := hf.pos_mul_atBot hC hinv
  have hfin : Tendsto (fun x => fin (f x * (g x)⁻¹)) l (𝓝 ninf) := tendsto_fin_atBot.comp hmul
  refine hfin.congr' ?_
  filter_upwards [hgneg] with x hx
  rw [fin_div_fin_of_ne (ne_of_lt hx), div_eq_mul_inv]

/-! ### Regime 1: `0/0` always breaks continuity -/

/-- **The nullity jump.**  If numerator and denominator vanish simultaneously at
`x₀` while the denominator is nonzero on a punctured neighbourhood, the
transreal quotient is discontinuous at `x₀`.  No continuity or even measurability
of `f` and `g` is needed: the obstruction is purely the isolation of `null`. -/
theorem not_continuousAt_of_common_zero {f g : ℝ → ℝ} {x₀ : ℝ} (hf : f x₀ = 0) (hg : g x₀ = 0)
    (hpunct : ∀ᶠ x in 𝓝[≠] x₀, g x ≠ 0) :
    ¬ ContinuousAt (fun x => fin (f x) / fin (g x)) x₀ := by
  intro hc
  have hval : fin (f x₀) / fin (g x₀) = null := by rw [hf, hg, zero_div_zero]
  have hnhds : (fun x => fin (f x) / fin (g x)) ⁻¹' {null} ∈ 𝓝 x₀ := by
    refine hc.preimage_mem_nhds ?_
    rw [hval]
    exact isOpen_singleton_null.mem_nhds rfl
  have h1 : ∀ᶠ x in 𝓝[≠] x₀, fin (f x) / fin (g x) ∈ ({null} : Set Transreal) :=
    mem_nhdsWithin_of_mem_nhds hnhds
  have h2 : ∀ᶠ _x in 𝓝[≠] x₀, False := by
    filter_upwards [h1, hpunct] with x hx hgx
    rw [fin_div_fin_of_ne hgx] at hx
    exact absurd hx (by simp)
  exact h2.exists.elim fun _ h => h

/-! ### Regime 2: one-signed poles do transfer -/

/-- **Even-order poles transfer.**  A positive numerator over a denominator of
constant sign near an isolated zero gives a map that *is* continuous into the
four-constructor carrier, with value `pinf` at the pole.  This is the precise
reason the failure of the unguarded principle must be stated as a generic, not a
universal, failure. -/
theorem continuousAt_div_of_positive_pole {f g : ℝ → ℝ} {x₀ : ℝ}
    (hf : ContinuousAt f x₀) (hfpos : 0 < f x₀) (hg : ContinuousAt g x₀) (hg0 : g x₀ = 0)
    (hgpos : ∀ᶠ x in 𝓝[≠] x₀, 0 < g x) :
    ContinuousAt (fun x => fin (f x) / fin (g x)) x₀ := by
  have hval : fin (f x₀) / fin (g x₀) = pinf := by
    rw [hg0]
    exact div_fin_zero_of_pos hfpos
  rw [continuousAt_iff_punctured_nhds]
  simp only [hval]
  refine tendsto_transDiv_pinf hfpos (hf.tendsto.mono_left nhdsWithin_le_nhds) ?_
  refine tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ ?_ (hgpos.mono fun x hx => hx)
  have := hg.tendsto.mono_left (nhdsWithin_le_nhds (s := ({x₀}ᶜ : Set ℝ)))
  rwa [hg0] at this

/-- A concrete unguarded expression that nevertheless transfers: `x ↦ 1 / x²` is
continuous from the line into the compact Hausdorff four-constructor carrier,
taking the value `pinf` at the origin. -/
theorem continuous_one_div_sq :
    Continuous (fun x : ℝ => fin 1 / fin (x ^ 2)) := by
  rw [continuous_iff_continuousAt]
  intro x
  by_cases hx : x = 0
  · subst hx
    refine continuousAt_div_of_positive_pole (f := fun _ : ℝ => 1) (g := fun x : ℝ => x ^ 2)
      continuousAt_const one_pos (by fun_prop) (by norm_num) ?_
    filter_upwards [self_mem_nhdsWithin] with y hy
    have hy0 : y ≠ 0 := hy
    positivity
  · have hx2 : x ^ 2 ≠ 0 := pow_ne_zero _ hx
    have heq : (fun y : ℝ => fin 1 / fin (y ^ 2)) =ᶠ[𝓝 x] fun y : ℝ => fin (1 / y ^ 2) := by
      have hne : ∀ᶠ y : ℝ in 𝓝 x, y ^ 2 ≠ 0 :=
        (continuous_pow 2).continuousAt.eventually_ne hx2
      filter_upwards [hne] with y hy
      exact fin_div_fin_of_ne hy
    have hcont : ContinuousAt (fun y : ℝ => fin (1 / y ^ 2)) x := by
      refine continuous_fin.continuousAt.comp ?_
      exact ContinuousAt.div continuousAt_const (by fun_prop) hx2
    exact hcont.congr heq.symm

/-! ### Regime 3: sign-changing poles break continuity -/

/-- **Sign-changing poles do not transfer.**  If the denominator changes sign at
its zero while the numerator stays positive, the one-sided limits of the
transreal quotient are the two different infinities, so — the carrier being
Hausdorff — the quotient is discontinuous. -/
theorem not_continuousAt_of_sign_change {f g : ℝ → ℝ} {x₀ : ℝ}
    (hf : ContinuousAt f x₀) (hfpos : 0 < f x₀) (hg : ContinuousAt g x₀) (hg0 : g x₀ = 0)
    (hpos : ∀ᶠ x in 𝓝[>] x₀, 0 < g x) (hneg : ∀ᶠ x in 𝓝[<] x₀, g x < 0) :
    ¬ ContinuousAt (fun x => fin (f x) / fin (g x)) x₀ := by
  intro hc
  have hgtend : Tendsto g (𝓝 x₀) (𝓝 0) := by
    have := hg.tendsto
    rwa [hg0] at this
  -- the limit from the right is `pinf`
  have hright : Tendsto (fun x => fin (f x) / fin (g x)) (𝓝[>] x₀) (𝓝 pinf) := by
    refine tendsto_transDiv_pinf hfpos (hf.tendsto.mono_left nhdsWithin_le_nhds) ?_
    exact tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _
      (hgtend.mono_left nhdsWithin_le_nhds) (hpos.mono fun x hx => hx)
  -- the limit from the left is `ninf`
  have hleft : Tendsto (fun x => fin (f x) / fin (g x)) (𝓝[<] x₀) (𝓝 ninf) := by
    refine tendsto_transDiv_ninf hfpos (hf.tendsto.mono_left nhdsWithin_le_nhds) ?_
    exact tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _
      (hgtend.mono_left nhdsWithin_le_nhds) (hneg.mono fun x hx => hx)
  -- but continuity forces both to be the value at `x₀`
  have hvR : Tendsto (fun x => fin (f x) / fin (g x)) (𝓝[>] x₀)
      (𝓝 (fin (f x₀) / fin (g x₀))) := hc.tendsto.mono_left nhdsWithin_le_nhds
  have hvL : Tendsto (fun x => fin (f x) / fin (g x)) (𝓝[<] x₀)
      (𝓝 (fin (f x₀) / fin (g x₀))) := hc.tendsto.mono_left nhdsWithin_le_nhds
  have h1 : fin (f x₀) / fin (g x₀) = pinf := tendsto_nhds_unique hvR hright
  have h2 : fin (f x₀) / fin (g x₀) = ninf := tendsto_nhds_unique hvL hleft
  rw [h1] at h2
  exact absurd h2 (by simp)

/-- The classical example of regime 3: the reciprocal.  (Compare
`Transreal.recip_fin_not_continuous`, proved by a different, purely
neighbourhood-theoretic route.) -/
theorem not_continuousAt_recip_zero :
    ¬ ContinuousAt (fun x : ℝ => fin 1 / fin x) 0 := by
  refine not_continuousAt_of_sign_change (f := fun _ : ℝ => 1) (g := fun x : ℝ => x)
    continuousAt_const one_pos continuousAt_id rfl ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with y hy
    exact hy
  · filter_upwards [self_mem_nhdsWithin] with y hy
    exact hy

end Transreal