/-
# Cycle 5: iteration — one-dimensional Krasnoselskii–Mann without averaging, and alternating
# median filters

`Logic.KneeMedianProjection` proved the *relaxed* median update `x ↦ (1-λ)x + λ·med`
converges to the median with exact rate `(1-λ)ⁿ` (`averaged_iterate`, `averaged_tendsto`).
Relaxation was used there only to make the residual contract.  The bold question this cycle
asks is whether relaxation is needed at all:

> **Does the *unrelaxed* iteration `x, Tx, T²x, …` of an arbitrary firmly nonexpansive map
> converge, as soon as it has one fixed point?**

In a general Hilbert space the answer for merely *nonexpansive* maps is no (rotations), and
even for firmly nonexpansive maps one only gets *weak* convergence.  On the line the answer
is an unqualified **yes**, and the proof is order-theoretic rather than metric:
`firm_iterate_tendsto`.  The mechanism is that a fixed point splits the line into two
invariant half-lines on which the orbit is monotone and bounded, so the order completeness
of `ℝ` — not any contraction estimate — supplies the limit.  No rate is available (and none
can be: `T = id` is firmly nonexpansive), which is exactly why the averaged theorem of the
previous cycle is not subsumed.

The consequence for the seed-ensemble theory is §3.  Two independent ensembles certify two
budget brackets `[a,b]` and `[c,d]`.  Alternately re-projecting a candidate budget onto the
two brackets — a two-ensemble median filter — converges, and its limit is a budget
consistent with **both** ensembles (`alternating_proj_tendsto`), provided the brackets
overlap.  The key structural fact is `firm_fix_comp`: for firmly nonexpansive maps with a
common fixed point, the fixed points of the composition are exactly the *common* fixed
points, so the alternating filter cannot converge to a spurious compromise.
-/

import Mathlib
import Logic.KneeMedianProjection

namespace KneeProj

open Filter Topology

/-! ## 1.  Orbits of a firmly nonexpansive map on the line -/

theorem firm_lipschitz {T : ℝ → ℝ} (h : FirmNE T) : LipschitzWith 1 T := by
  rw [lipschitzWith_iff_dist_le_mul]
  intro x y
  simpa [Real.dist_eq] using h.nonexpansive x y

theorem firm_continuous {T : ℝ → ℝ} (h : FirmNE T) : Continuous T :=
  (firm_lipschitz h).continuous

/-- The limit of a convergent orbit of a continuous map is a fixed point. -/
theorem fix_of_tendsto {T : ℝ → ℝ} (hcont : Continuous T) {u : ℕ → ℝ} {q : ℝ}
    (hstep : ∀ n, u (n + 1) = T (u n)) (hlim : Tendsto u atTop (𝓝 q)) : T q = q := by
  have h1 : Tendsto (fun n => T (u n)) atTop (𝓝 (T q)) := (hcont.tendsto q).comp hlim
  have h2 : Tendsto (fun n => u (n + 1)) atTop (𝓝 q) := hlim.comp (tendsto_add_atTop_nat 1)
  simp only [hstep] at h2
  exact tendsto_nhds_unique h1 h2

/-- **One-dimensional Krasnoselskii–Mann, unrelaxed.**  If a firmly nonexpansive self-map of
the line has a fixed point, then *every* orbit converges to a fixed point.  The proof uses
the order completeness of `ℝ`: a fixed point cuts the line into two invariant half-lines on
which the orbit is monotone and bounded. -/
theorem firm_iterate_tendsto {T : ℝ → ℝ} (h : FirmNE T) {p : ℝ} (hp : T p = p) (x : ℝ) :
    ∃ q, T q = q ∧ Tendsto (fun n => T^[n] x) atTop (𝓝 q) := by
  have hml := (firm_iff_monoLip T).1 h
  have hcont := firm_continuous h
  set u : ℕ → ℝ := fun n => T^[n] x with hudef
  have hstep : ∀ n, u (n + 1) = T (u n) := fun n => Function.iterate_succ_apply' T n x
  rcases le_total p x with hpx | hxp
  · have hbound : ∀ n, p ≤ u n := by
      intro n
      induction n with
      | zero => simpa [hudef] using hpx
      | succ n ih =>
          rw [hstep]
          have := (hml p (u n) ih).1
          rwa [hp] at this
    have hanti : Antitone u := by
      refine antitone_nat_of_succ_le fun n => ?_
      rw [hstep]
      have := (hml p (u n) (hbound n)).2
      rw [hp] at this
      linarith
    have hbdd : BddBelow (Set.range u) := ⟨p, by rintro _ ⟨n, rfl⟩; exact hbound n⟩
    have hlim := tendsto_atTop_ciInf hanti hbdd
    exact ⟨⨅ n, u n, fix_of_tendsto hcont hstep hlim, hlim⟩
  · have hbound : ∀ n, u n ≤ p := by
      intro n
      induction n with
      | zero => simpa [hudef] using hxp
      | succ n ih =>
          rw [hstep]
          have := (hml (u n) p ih).1
          rwa [hp] at this
    have hmono : Monotone u := by
      refine monotone_nat_of_le_succ fun n => ?_
      rw [hstep]
      have := (hml (u n) p (hbound n)).2
      rw [hp] at this
      linarith
    have hbdd : BddAbove (Set.range u) := ⟨p, by rintro _ ⟨n, rfl⟩; exact hbound n⟩
    have hlim := tendsto_atTop_ciSup hmono hbdd
    exact ⟨⨆ n, u n, fix_of_tendsto hcont hstep hlim, hlim⟩

/-! ## 2.  Common fixed points of compositions -/

/-- **No spurious compromises.**  If two firmly nonexpansive maps of the line share a fixed
point, then every fixed point of their composition is a fixed point of *both*.  (In a
Hilbert space this is the classical `Fix (S ∘ T) = Fix S ∩ Fix T` for firmly nonexpansive
`S`, `T` with `Fix S ∩ Fix T ≠ ∅`.) -/
theorem firm_fix_comp {S T : ℝ → ℝ} (hS : FirmNE S) (hT : FirmNE T) {p : ℝ}
    (hSp : S p = p) (hTp : T p = p) {q : ℝ} (hq : S (T q) = q) : T q = q ∧ S q = q := by
  have hmS := (firm_iff_monoLip S).1 hS
  have hmT := (firm_iff_monoLip T).1 hT
  have hTq : T q = q := by
    rcases le_total p q with hpq | hqp
    · have h1 : T q ≤ q := by
        have := (hmT p q hpq).2; rw [hTp] at this; linarith
      have hpT : p ≤ T q := by
        have := (hmT p q hpq).1; rwa [hTp] at this
      have h2 : q ≤ T q := by
        have := (hmS p (T q) hpT).2
        rw [hSp, hq] at this
        linarith
      linarith
    · have h1 : q ≤ T q := by
        have := (hmT q p hqp).2; rw [hTp] at this; linarith
      have hTp' : T q ≤ p := by
        have := (hmT q p hqp).1; rwa [hTp] at this
      have h2 : T q ≤ q := by
        have := (hmS (T q) p hTp').2
        rw [hSp, hq] at this
        linarith
      linarith
  exact ⟨hTq, by rw [hTq] at hq; exact hq⟩

/-! ## 3.  Alternating median filters over two seed ensembles -/

theorem proj_fix_iff {a b x : ℝ} (hab : a ≤ b) : proj a b x = x ↔ x ∈ Set.Icc a b := by
  constructor
  · intro hx; rw [← hx]; exact proj_mem hab x
  · exact proj_eq_self_of_mem

/-- **Alternating projections converge to a consensus budget.**  If two ensembles certify
overlapping brackets `[a,b]` and `[c,d]`, alternately re-projecting any candidate budget
onto the two brackets converges, and the limit lies in *both* brackets. -/
theorem alternating_proj_tendsto {a b c d : ℝ} (hab : a ≤ b) (hcd : c ≤ d) {p : ℝ}
    (hp : p ∈ Set.Icc a b ∩ Set.Icc c d) (x : ℝ) :
    ∃ q, q ∈ Set.Icc a b ∩ Set.Icc c d ∧
      Tendsto (fun n => (proj a b ∘ proj c d)^[n] x) atTop (𝓝 q) := by
  have hS := proj_firmly_nonexpansive hab
  have hT := proj_firmly_nonexpansive hcd
  have hSp : proj a b p = p := proj_eq_self_of_mem hp.1
  have hTp : proj c d p = p := proj_eq_self_of_mem hp.2
  have hcomp : FirmNE (proj a b ∘ proj c d) := firm_comp hS hT
  have hcompp : (proj a b ∘ proj c d) p = p := by
    simp only [Function.comp_apply, hTp, hSp]
  obtain ⟨q, hqfix, hqlim⟩ := firm_iterate_tendsto hcomp hcompp x
  obtain ⟨h1, h2⟩ := firm_fix_comp hS hT hSp hTp (q := q) hqfix
  exact ⟨q, ⟨(proj_fix_iff hab).1 h2, (proj_fix_iff hcd).1 h1⟩, hqlim⟩

/-- The unrelaxed median filter of a single ensemble stabilises immediately: iterating the
projection is the projection.  (So `firm_iterate_tendsto` is not vacuous for the median —
it is the *composition* of filters, `alternating_proj_tendsto`, where genuinely infinite
iteration occurs.) -/
theorem proj_iterate_succ {a b : ℝ} (hab : a ≤ b) (x : ℝ) (n : ℕ) :
    (proj a b)^[n + 1] x = proj a b x := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      exact proj_eq_self_of_mem (proj_mem hab x)

/-- At the NET-48 bracket `[160, 256]` and a hypothetical second-ensemble bracket
`[224, 384]`, the alternating filter converges into the overlap `[224, 256]`. -/
theorem net48_alternating_consensus (x : ℝ) :
    ∃ q, q ∈ Set.Icc (160:ℝ) 256 ∩ Set.Icc (224:ℝ) 384 ∧
      Tendsto (fun n => (proj 160 256 ∘ proj 224 384)^[n] x) atTop (𝓝 q) :=
  alternating_proj_tendsto (by norm_num) (by norm_num)
    (p := 224) ⟨by constructor <;> norm_num, by constructor <;> norm_num⟩ x

end KneeProj