import Novelty.AttentionPhaseTransition

/-!
# The feasibility band: which continuations of the NET-78 chain can exist at all

`Novelty.AttentionPhaseTransition` (cycle 1 of the NET-78 audit) proved that the
four measured knees `16, 20, 24, 40` do **not** determine the budget law past
`ctx = 4096`: the ramp fit, the cubic interpolant and the geometric fit all pass
through the data and predict `56`, `80`, `92` keys at `ctx = 8192`.  This file
is cycle 2, and it closes part of that gap *without new measurements*, by adding
the one constraint the experiment cannot violate:

> a key cache can never hold more keys than the context has tokens,
> `f j ≤ 512 · 2^j` (`Feasible`).

**Main results.**

* `kneeQuad_infeasible` — the geometric continuation (the increment itself
  multiplying by `4` per doubling) demands **more keys than the context has
  tokens** from `ctx = 2^21` onwards, and `kneeQuad_infeasible_at` gives the
  explicit crossing.  It is therefore refuted on structural grounds, not by
  data.  Two of the three cycle-1 continuations survive
  (`kneeRamp_feasible`, `kneeCubic_feasible`), and `feasibility_selects`
  records the resulting discriminating experiment: `56` versus `80` at `8192`.
* `ratio_vanishes_of_poly` — for any law growing at most polynomially in the
  number of doublings, the retained *fraction* of the context tends to `0`.
  Hence `kneeRamp_ratio_tendsto_zero` and `kneeCubic_ratio_tendsto_zero`: even
  with the phase transition, both surviving laws keep the cache asymptotically
  negligible.  The transition changes the constant, not the compressibility.
* `convex_tropical_envelope` — a *discrete Legendre biconjugation*: every
  monotone convex budget law is the max-plus (tropical) polynomial of its own
  tangents, `f J = ⨆_{i ≤ J} (f i + (J - i)·Δf i)`.  The two-term tropical
  representation of the ramp fit found in cycle 1
  (`Novelty.AttentionPhaseTransition.kneeRamp_eq_max`) is the special case where
  all but two tangents are redundant (`kneeRamp_two_monomials`), and the corner
  between those two monomials is the measured phase transition at `ctx = 2048`.
* `band_nonempty` — combining cycle 1's convexity lower bound with the
  feasibility ceiling, every convex feasible fit is trapped in the band
  `40 + 16m ≤ f (m+3) ≤ 512·2^(m+3)`, and the band is inhabited by the ramp fit.
-/

namespace Catalog.Novelty.AttentionFeasibilityBand

open Filter Topology Catalog.Novelty.AttentionPhaseTransition

/-! ### 1. The feasibility ceiling -/

/-- A budget law is *feasible* if it never asks for more keys than the context
has tokens: at `j` doublings above the base context the context is `512 · 2^j`
tokens long. -/
def Feasible (f : ℕ → ℕ) : Prop := ∀ j, f j ≤ 512 * 2 ^ j

/-- The ramp fit is feasible: it is linear in `j`, the ceiling is exponential. -/
theorem kneeRamp_feasible : Feasible kneeRamp := by
  intro j
  have h : j + 1 ≤ 2 ^ j := Nat.lt_two_pow_self
  have h2 : 16 * (j + 1) ≤ 16 * 2 ^ j := Nat.mul_le_mul_left 16 h
  have h3 : (16 : ℕ) * 2 ^ j ≤ 512 * 2 ^ j := Nat.mul_le_mul_right _ (by norm_num)
  simp only [kneeRamp]
  omega

/-- `6·C(j,3) ≤ j³`: the cubic interpolant really is cubic. -/
theorem six_choose_three_le (j : ℕ) : 6 * j.choose 3 ≤ j ^ 3 := by
  have h := Nat.descFactorial_le_pow j 3
  rw [Nat.descFactorial_eq_factorial_mul_choose] at h
  norm_num [Nat.factorial] at h
  omega

/-- The cubic interpolant is feasible as well. -/
theorem kneeCubic_feasible : Feasible kneeCubic := by
  intro j
  have hc : j.choose 3 ≤ 2 ^ j := Nat.choose_le_two_pow j 3
  have hj : j + 1 ≤ 2 ^ j := Nat.lt_two_pow_self
  simp only [kneeCubic]
  omega

/-- **The geometric continuation is infeasible.**  Twelve doublings above the
base context it already demands more keys than the context has tokens. -/
theorem kneeQuad_infeasible_at (m : ℕ) : 512 * 2 ^ (m + 12) < kneeQuad (m + 12) := by
  have h1 : m + 12 - 2 = m + 10 := by omega
  simp only [kneeQuad, h1]
  have hp : 1 ≤ (4 : ℕ) ^ (m + 10) := Nat.one_le_pow _ _ (by norm_num)
  have e4 : (4 : ℕ) ^ (m + 10) = 4 ^ m * 4 ^ 10 := pow_add 4 m 10
  have e2 : (2 : ℕ) ^ (m + 12) = 2 ^ m * 2 ^ 12 := pow_add 2 m 12
  have hle : (2 : ℕ) ^ m ≤ 4 ^ m := Nat.pow_le_pow_left (by norm_num) m
  rw [e4, e2]
  norm_num
  omega

/-- Hence the geometric continuation is not a budget law at all. -/
theorem kneeQuad_infeasible : ¬ Feasible kneeQuad := by
  intro h
  have := h 12
  have := kneeQuad_infeasible_at 0
  norm_num at this ⊢
  omega

/-- **Feasibility halves the cycle-1 ambiguity.**  Of the three continuations
fitting the measured chain, exactly one is impossible; the two survivors are
separated by a single further measurement at `ctx = 8192` (`56` versus `80`). -/
theorem feasibility_selects :
    Feasible kneeRamp ∧ Feasible kneeCubic ∧ ¬ Feasible kneeQuad ∧
      kneeRamp 4 = 56 ∧ kneeCubic 4 = 80 :=
  ⟨kneeRamp_feasible, kneeCubic_feasible, kneeQuad_infeasible, rfl, by decide⟩

/-! ### 2. The band -/

/-- **The feasibility band.**  Every convex fit of the measured chain that is
physically possible is trapped between the convexity lower bound of cycle 1 and
the context ceiling — and the band is inhabited by the ramp fit. -/
theorem band_nonempty {f : ℕ → ℕ} (hc : ConvexLaw f) (hf : Fits f) (hfe : Feasible f) (m : ℕ) :
    40 + 16 * m ≤ f (m + 3) ∧ f (m + 3) ≤ 512 * 2 ^ (m + 3) ∧
      40 + 16 * m ≤ kneeRamp (m + 3) ∧ kneeRamp (m + 3) ≤ 512 * 2 ^ (m + 3) := by
  refine ⟨convex_growth hc hf m, hfe (m + 3), ?_, kneeRamp_feasible (m + 3)⟩
  simp only [kneeRamp]
  omega

/-! ### 3. Compression: the retained fraction still vanishes -/

/-- The fraction of the context that a budget law keeps. -/
noncomputable def keepFraction (f : ℕ → ℕ) (j : ℕ) : ℝ := (f j : ℝ) / (512 * 2 ^ j)

/-- **Polynomial laws are asymptotically free.**  If a budget law grows at most
polynomially in the number of context doublings, the fraction of the context it
retains tends to `0`. -/
theorem ratio_vanishes_of_poly {f : ℕ → ℕ} {C k : ℕ} (h : ∀ j, f j ≤ C * (j + 1) ^ k) :
    Tendsto (keepFraction f) atTop (𝓝 0) := by
  have hbase : Tendsto (fun n : ℕ => (n : ℝ) ^ k * (1 / 2 : ℝ) ^ n) atTop (𝓝 0) :=
    tendsto_pow_const_mul_const_pow_of_lt_one k (by norm_num) (by norm_num)
  have hshift : Tendsto (fun j : ℕ => ((j : ℝ) + 1) ^ k * (1 / 2 : ℝ) ^ (j + 1)) atTop (𝓝 0) := by
    have := (tendsto_add_atTop_iff_nat (f := fun n : ℕ => (n : ℝ) ^ k * (1 / 2 : ℝ) ^ n)
      (l := 𝓝 0) 1).2 hbase
    simpa using this
  have hmaj : Tendsto (fun j : ℕ => (C : ℝ) / 256 * (((j : ℝ) + 1) ^ k * (1 / 2 : ℝ) ^ (j + 1)))
      atTop (𝓝 0) := by
    simpa using hshift.const_mul ((C : ℝ) / 256)
  refine squeeze_zero (fun j => ?_) (fun j => ?_) hmaj
  · exact div_nonneg (Nat.cast_nonneg _) (by positivity)
  · have hnum : (f j : ℝ) ≤ (C : ℝ) * ((j : ℝ) + 1) ^ k := by
      have := h j
      have : ((f j : ℕ) : ℝ) ≤ ((C * (j + 1) ^ k : ℕ) : ℝ) := Nat.cast_le.2 this
      push_cast at this
      linarith
    have hden : (0 : ℝ) < 512 * 2 ^ j := by positivity
    rw [keepFraction, div_le_iff₀ hden]
    have hhalf : (1 / 2 : ℝ) ^ (j + 1) * (2 : ℝ) ^ j = 1 / 2 := by
      rw [div_pow, one_pow, pow_succ]
      field_simp
    have hCnn : (0 : ℝ) ≤ (C : ℝ) := Nat.cast_nonneg C
    calc (f j : ℝ) ≤ (C : ℝ) * ((j : ℝ) + 1) ^ k := hnum
      _ = (C : ℝ) / 256 * (((j : ℝ) + 1) ^ k * (1 / 2 : ℝ) ^ (j + 1)) * (512 * 2 ^ j) := by
          have e : (C : ℝ) / 256 * (((j : ℝ) + 1) ^ k * (1 / 2 : ℝ) ^ (j + 1)) * (512 * 2 ^ j)
              = (C : ℝ) * ((j : ℝ) + 1) ^ k * (2 * ((1 / 2 : ℝ) ^ (j + 1) * 2 ^ j)) := by ring
          rw [e, hhalf]
          ring
  
/-- The ramp fit keeps a vanishing fraction of the context. -/
theorem kneeRamp_ratio_tendsto_zero : Tendsto (keepFraction kneeRamp) atTop (𝓝 0) := by
  refine ratio_vanishes_of_poly (C := 16) (k := 1) (fun j => ?_)
  simp only [kneeRamp, pow_one]
  omega

/-- So does the cubic interpolant: the phase transition changes the constant in
the budget table, not the asymptotic compressibility of the cache. -/
theorem kneeCubic_ratio_tendsto_zero : Tendsto (keepFraction kneeCubic) atTop (𝓝 0) := by
  refine ratio_vanishes_of_poly (C := 22) (k := 3) (fun j => ?_)
  have hc : 6 * j.choose 3 ≤ j ^ 3 := six_choose_three_le j
  have hj3 : j ^ 3 ≤ (j + 1) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hj1 : j ≤ (j + 1) ^ 3 := by nlinarith [Nat.zero_le j]
  have hj0 : 1 ≤ (j + 1) ^ 3 := Nat.one_le_pow _ _ (by omega)
  simp only [kneeCubic]
  omega

/-! ### 4. Discrete Legendre duality: a convex law is its own tropical envelope -/

/-- The tangent line of `f` at `i`, evaluated at `j`: the affine (max-plus
monomial) law that agrees with `f` at `i` and carries the increment of `f` at
`i`. -/
def tangent (f : ℕ → ℕ) (i j : ℕ) : ℕ := f i + (j - i) * (f (i + 1) - f i)

/-- A convex law never loses an increment, at any later index. -/
theorem convex_increment_iter {f : ℕ → ℕ} (hc : ConvexLaw f) {i c : ℕ}
    (h : f i + c ≤ f (i + 1)) : ∀ m, f (i + m) + c ≤ f (i + m + 1) := by
  intro m
  induction m with
  | zero => simp only [Nat.add_zero]; exact h
  | succ n ih =>
      have hstep := convex_increment_persists (j := i + n) hc ih
      have e1 : i + n + 2 = i + (n + 1) + 1 := by omega
      have e2 : i + n + 1 = i + (n + 1) := by omega
      rwa [e1, e2] at hstep

/-- **Tangent lower bound.**  For a monotone convex law every tangent lies below
the law itself, from its point of contact onwards. -/
theorem tangent_le {f : ℕ → ℕ} (hc : ConvexLaw f) (hmono : Monotone f) {i j : ℕ}
    (hij : i ≤ j) : tangent f i j ≤ f j := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hij
  clear hij
  have hbase : f i + (f (i + 1) - f i) ≤ f (i + 1) := by
    have h := hmono (Nat.le_succ i)
    simp only [Nat.succ_eq_add_one] at h
    omega
  induction m with
  | zero => simp [tangent]
  | succ n ih =>
      have hstep := convex_increment_iter hc hbase n
      have e1 : i + (n + 1) - i = n + 1 := by omega
      have e2 : i + n - i = n := by omega
      have e3 : i + n + 1 = i + (n + 1) := by omega
      simp only [tangent, e1, e2] at ih ⊢
      rw [e3] at hstep
      calc f i + (n + 1) * (f (i + 1) - f i)
          = f i + n * (f (i + 1) - f i) + (f (i + 1) - f i) := by ring
        _ ≤ f (i + n) + (f (i + 1) - f i) := Nat.add_le_add_right ih _
        _ ≤ f (i + (n + 1)) := hstep

/-- **Discrete Legendre biconjugation.**  A monotone convex budget law is
exactly the max-plus (tropical) polynomial whose monomials are its own tangents:
`f J = ⨆_{i ≤ J} tangent f i J`.  Budget laws of this kind are therefore
tropical objects, and their kinks — the phase transitions — are the corners of
a tropical hypersurface. -/
theorem convex_tropical_envelope {f : ℕ → ℕ} (hc : ConvexLaw f) (hmono : Monotone f) (J : ℕ) :
    f J = (Finset.range (J + 1)).sup (fun i => tangent f i J) := by
  apply le_antisymm
  · have hJ : J ∈ Finset.range (J + 1) := Finset.mem_range.2 (Nat.lt_succ_self J)
    have h := Finset.le_sup (f := fun i => tangent f i J) hJ
    simpa [tangent] using h
  · refine Finset.sup_le fun i hi => tangent_le hc hmono ?_
    exact Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)

theorem kneeRamp_monotone : Monotone kneeRamp := by
  intro a b hab
  simp only [kneeRamp]
  omega

/-- **The ramp fit is a two-term tropical polynomial.**  Past the corner its
envelope collapses onto the tangents at `j = 0` (the pre-transition regime,
`+4` keys per doubling) and at `j = 2` (the post-transition regime, `+16`);
all other tangents are redundant. -/
theorem kneeRamp_two_monomials {j : ℕ} (hj : 2 ≤ j) :
    kneeRamp j = max (tangent kneeRamp 0 j) (tangent kneeRamp 2 j) := by
  simp only [tangent, kneeRamp, Nat.sub_zero]
  omega

/-- The corner of that two-term tropical polynomial is exactly the measured
transition: the two monomials agree at `j = 2` (`ctx = 2048`), the first one
carries the law before the corner and the second one after it.  (Before its
point of contact the second tangent is not a lower bound — that is precisely
why the envelope in `convex_tropical_envelope` is indexed by `i ≤ J`.) -/
theorem kneeRamp_corner :
    tangent kneeRamp 0 2 = tangent kneeRamp 2 2 ∧
      (∀ j, j ≤ 2 → kneeRamp j = tangent kneeRamp 0 j) ∧
      (∀ j, 2 ≤ j → kneeRamp j = tangent kneeRamp 2 j) ∧
      (∀ j, 2 ≤ j → tangent kneeRamp 0 j ≤ tangent kneeRamp 2 j) := by
  refine ⟨by decide, fun j hj => ?_, fun j hj => ?_, fun j hj => ?_⟩ <;>
    simp only [tangent, kneeRamp, Nat.sub_zero] <;> omega

end Catalog.Novelty.AttentionFeasibilityBand