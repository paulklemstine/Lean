import Mathlib
import Tropical.ECMPlaneCompletion

/-!
# One population, one functional: the Newton polygon of the five-method table

`Catalog/Tropical/ECMPlaneCompletion.lean` puts the five factoring arms of experiment 490
into one min-plus plane.  This file develops the tropical geometry of a *whole family* of
arms: the lower envelope `env F k = min_i (c_i + α_i k)` is a tropical polynomial in one
variable, and the question "which arms are ever the fastest?" is exactly the question
"which points `(α_i, c_i)` are vertices of the lower convex hull?" — the Newton-polygon
duality, here proved in the form the experiment needs.

## Main results

* `exists_leader`, `env_le`, `env_eq_of_leader` — the envelope is attained: at every
  target size some arm leads.
* `env_concave` — the envelope of any finite family is concave (a tropical polynomial in
  one variable is a concave piecewise-affine function).
* `leader_slope_antitone` — **the leaderboard is sorted by exponent**: if arm `i` leads at
  `k₁` and arm `j` leads at a larger `k₂`, then `α_j ≤ α_i`.  Exponents can only decrease
  as targets grow.
* `leader_icept_monotone` — dually, intercepts can only increase along the leaderboard.
* `never_leader_of_above_hull` — **the Newton-polygon criterion**: an arm whose point
  `(α_i, c_i)` lies strictly above the segment joining two other arms never leads, at any
  target size.  Its exponent may be interior to the plane while it is operationally
  irrelevant.
* `both_lead_of_slope_ne` — conversely, two arms with distinct exponents each lead on
  their own side of the corner: a two-element family has no dead arm.
* `leads_of_below_hull` — the **converse** of the Newton-polygon criterion for a triple:
  a middle arm on or below the segment leads exactly at the crossing point of the two
  outer arms.  Hull membership is therefore the precise criterion for relevance.
* `ecm250_leads_iff_overhead_le` — the two directions combined give a sharp iff for the
  measured plane; `ecm250_never_leads_on_physical_range` records the caveat that on
  `k ≥ 0` any positive overhead already kills that column.
* `ecm50_never_leads` — with the measured `+3.04`-bit overhead the `B₁ = 50` ECM column
  is a dead arm of the plane on the whole physical range `k ≥ 0`.
* `ecm250_never_leads_of_overhead` — a **falsifiable prediction** extracted from the
  measured exponents alone: since `0.718 = (43·0.512 + 206·0.761)/249` exactly, the
  `B₁ = 250` column is a vertex of the hull only if its common-currency overhead over
  rho is smaller than `3.04 · 206/249 ≈ 2.515` bits; above that it can never lead, at any
  target size, however favourable its exponent looks.
-/

namespace ECMHull

open ECMPlane

variable {ι : Type*}

/-- The lower envelope of a finite family of arms: the tropical polynomial
`⊕_i c_i ⊙ k^{⊙α_i}`, i.e. the cost of always running the currently best arm. -/
noncomputable def env [Fintype ι] [Nonempty ι] (F : ι → Profile) (k : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty fun i => work (F i) k

/-- Arm `i` leads at target size `k` if no arm is cheaper there. -/
def Leads (F : ι → Profile) (i : ι) (k : ℝ) : Prop := ∀ j, work (F i) k ≤ work (F j) k

theorem env_le [Fintype ι] [Nonempty ι] (F : ι → Profile) (k : ℝ) (i : ι) : env F k ≤ work (F i) k :=
  Finset.inf'_le _ (Finset.mem_univ i)

/-- At every target size some arm leads. -/
theorem exists_leader [Fintype ι] [Nonempty ι] (F : ι → Profile) (k : ℝ) : ∃ i, Leads F i k := by
  obtain ⟨i, -, hi⟩ :=
    Finset.exists_mem_eq_inf' (Finset.univ_nonempty (α := ι)) fun i => work (F i) k
  exact ⟨i, fun j => by rw [← hi]; exact env_le F k j⟩

theorem env_eq_of_leader [Fintype ι] [Nonempty ι] {F : ι → Profile} {i : ι} {k : ℝ} (h : Leads F i k) :
    env F k = work (F i) k :=
  le_antisymm (env_le F k i) (Finset.le_inf' _ _ fun j _ => h j)

/-- **A tropical polynomial in one variable is concave.** -/
theorem env_concave [Fintype ι] [Nonempty ι] (F : ι → Profile) {x y t s : ℝ} (ht : 0 ≤ t) (hs : 0 ≤ s)
    (hts : t + s = 1) : t * env F x + s * env F y ≤ env F (t * x + s * y) := by
  obtain ⟨i, hi⟩ := exists_leader F (t * x + s * y)
  rw [env_eq_of_leader hi]
  have hx : env F x ≤ work (F i) x := env_le F x i
  have hy : env F y ≤ work (F i) y := env_le F y i
  have haff : t * work (F i) x + s * work (F i) y = work (F i) (t * x + s * y) := by
    simp only [work]
    linear_combination (F i).icept * hts
  calc t * env F x + s * env F y
      ≤ t * work (F i) x + s * work (F i) y :=
        add_le_add (mul_le_mul_of_nonneg_left hx ht) (mul_le_mul_of_nonneg_left hy hs)
    _ = work (F i) (t * x + s * y) := haff

/-- **The leaderboard is sorted by exponent.**  A later leader never has a larger
exponent: the tropical envelope selects arms in decreasing order of `α`. -/
theorem leader_slope_antitone {F : ι → Profile} {i j : ι} {k₁ k₂ : ℝ} (hk : k₁ < k₂)
    (hi : Leads F i k₁) (hj : Leads F j k₂) : (F j).slope ≤ (F i).slope := by
  have h1 := hi j
  have h2 := hj i
  simp only [work] at h1 h2
  nlinarith [h1, h2, sub_pos.mpr hk]

/-- Dually, intercepts increase along the leaderboard (on the physical range `k ≥ 0`). -/
theorem leader_icept_monotone {F : ι → Profile} {i j : ι} {k₁ k₂ : ℝ} (hk0 : 0 ≤ k₁)
    (hk : k₁ < k₂) (hi : Leads F i k₁) (hj : Leads F j k₂) : (F i).icept ≤ (F j).icept := by
  have hslope : (F j).slope ≤ (F i).slope := leader_slope_antitone hk hi hj
  have h1 := hi j
  simp only [work] at h1
  nlinarith [h1, hslope, hk0]

/-- **Newton-polygon criterion: an arm above the hull is dead.**  If `(α_i, c_i)` lies
strictly above the segment joining `(α_j, c_j)` and `(α_l, c_l)` — same exponent as the
convex combination, larger intercept — then arm `i` never leads, at any target size. -/
theorem never_leader_of_above_hull {F : ι → Profile} {i j l : ι} {t s : ℝ}
    (ht : 0 ≤ t) (hs : 0 ≤ s) (hts : t + s = 1)
    (hslope : (F i).slope = t * (F j).slope + s * (F l).slope)
    (hicept : t * (F j).icept + s * (F l).icept < (F i).icept) (k : ℝ) :
    ¬ Leads F i k := by
  intro hlead
  have h1 := hlead j
  have h2 := hlead l
  simp only [work, hslope] at h1 h2
  have e1 := mul_le_mul_of_nonneg_left h1 ht
  have e2 := mul_le_mul_of_nonneg_left h2 hs
  have hcollapse :
      t * ((F i).icept + (t * (F j).slope + s * (F l).slope) * k)
        + s * ((F i).icept + (t * (F j).slope + s * (F l).slope) * k)
        = (F i).icept + (t * (F j).slope + s * (F l).slope) * k := by
    linear_combination ((F i).icept + (t * (F j).slope + s * (F l).slope) * k) * hts
  have hsum : (F i).icept + (t * (F j).slope + s * (F l).slope) * k
      ≤ t * ((F j).icept + (F j).slope * k) + s * ((F l).icept + (F l).slope * k) := by
    linarith
  nlinarith [hsum, hicept]

/-- Conversely, in a two-element family with distinct exponents **both** arms lead
somewhere: each is a vertex of its own hull. -/
theorem both_lead_of_slope_ne (M N : Profile) (h : M.slope < N.slope) :
    ∃ k₁ k₂ : ℝ, Leads ![M, N] 1 k₁ ∧ Leads ![M, N] 0 k₂ ∧ k₁ < k₂ := by
  obtain ⟨kstar, hstar, -⟩ := crossover_point h
  simp only [work] at hstar
  refine ⟨kstar - 1, kstar + 1, ?_, ?_, by linarith⟩
  · intro j
    fin_cases j
    · simp only [work, Matrix.cons_val_zero, Matrix.cons_val_one, Fin.zero_eta]
      nlinarith
    · simp
  · intro j
    fin_cases j
    · simp
    · simp only [work, Matrix.cons_val_zero, Matrix.cons_val_one, Fin.mk_one]
      nlinarith

/-- **Converse of the Newton-polygon criterion, for a triple.**  If the middle arm `N`
sits *on or below* the segment joining the two outer arms `M` and `P` (whose exponents
differ), then it does lead — precisely at the crossing point of the two outer arms.  With
`never_leader_of_above_hull` this makes hull membership the exact criterion for being
operationally relevant.  (Convexity of the weights is not needed: only `t + s = 1`.) -/
theorem leads_of_below_hull (M N P : Profile) (hMP : M.slope ≠ P.slope) {t s : ℝ}
    (hts : t + s = 1)
    (hslope : N.slope = t * M.slope + s * P.slope)
    (hicept : N.icept ≤ t * M.icept + s * P.icept) :
    ∃ k : ℝ, Leads ![M, N, P] 1 k := by
  have hd0 : M.slope - P.slope ≠ 0 := sub_ne_zero.mpr hMP
  obtain ⟨kstar, hmul⟩ : ∃ k : ℝ, (M.slope - P.slope) * k = P.icept - M.icept :=
    ⟨(P.icept - M.icept) / (M.slope - P.slope), by field_simp⟩
  have hcross : work M kstar = work P kstar := by
    simp only [work]; linarith
  -- the middle arm is below the convex combination, which equals the common value
  have hcomb : work N kstar ≤ t * work M kstar + s * work P kstar := by
    simp only [work, hslope]
    nlinarith [hicept, hmul]
  have hval : t * work M kstar + s * work P kstar = work M kstar := by
    rw [hcross]
    simp only [work]
    linear_combination (P.icept + P.slope * kstar) * hts
  have hNM : work N kstar ≤ work M kstar := by linarith [hcomb, hval]
  have hNP : work N kstar ≤ work P kstar := by rw [← hcross]; exact hNM
  refine ⟨kstar, ?_⟩
  intro j
  fin_cases j
  · simpa using hNM
  · simp
  · simpa using hNP

/-! ### The measured plane: dead arms and a falsifiable prediction -/

/-- **The `B₁ = 50` ECM column is a dead arm.**  On the physical range `k ≥ 0` it is
never a leader of the family `{rho, ECM(50)}` — hence of any family containing rho —
because it pays `+3.04` bits on top of a larger exponent. -/
theorem ecm50_never_leads (c : ℝ) {k : ℝ} (hk : 0 ≤ k) :
    ¬ Leads ![rhoArm c, ecm50Arm c] 1 k := by
  intro hlead
  have h := hlead 0
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one] at h
  exact absurd h (not_le.mpr (rho_dominates_ecm c hk))

/-- The measured exponents are *exactly* collinear with weights `43/249` and `206/249`:
`0.718 = (43·0.512 + 206·0.761)/249`.  The `B₁ = 250` column therefore sits on the line
through the rho and `B₁ = 50` columns in exponent coordinates, and only its intercept
decides whether it is a hull vertex. -/
theorem ecm250_slope_on_segment (c d : ℝ) :
    (ecm250Arm c d).slope
      = (43 / 249 : ℝ) * (rhoArm c).slope + (206 / 249 : ℝ) * (ecm50Arm c).slope := by
  simp only [rhoArm, ecm50Arm, ecm250Arm]
  norm_num

/-- **A falsifiable prediction.**  If the common-currency overhead `d` of the `B₁ = 250`
column over rho exceeds `3.04 · 206/249 ≈ 2.515` bits, then that column lies strictly
above the hull segment and can never lead — at *any* target size, in the family
`{rho, ECM(250), ECM(50)}`.  Measuring `d` below that threshold would instead make it a
genuine vertex; this is the sharp experimental test the next cycle should run. -/
theorem ecm250_never_leads_of_overhead (c d : ℝ) (hd : (3.04 : ℝ) * (206 / 249) < d)
    (k : ℝ) : ¬ Leads ![rhoArm c, ecm250Arm c d, ecm50Arm c] 1 k := by
  refine never_leader_of_above_hull (i := 1) (j := 0) (l := 2) (t := 43 / 249) (s := 206 / 249)
    (by norm_num) (by norm_num) (by norm_num) ?_ ?_ k
  · simp [rhoArm, ecm50Arm, ecm250Arm]
    norm_num
  · simp [rhoArm, ecm50Arm, ecm250Arm]
    nlinarith [hd]

/-- **The sharp form of the prediction.**  Combining the two directions of the
Newton-polygon criterion: the `B₁ = 250` column leads at *some* target size (over the
whole real line of sizes) **iff** its common-currency overhead over rho is at most
`3.04 · 206/249 ≈ 2.515` bits. -/
theorem ecm250_leads_iff_overhead_le (c d : ℝ) :
    (∃ k : ℝ, Leads ![rhoArm c, ecm250Arm c d, ecm50Arm c] 1 k)
      ↔ d ≤ (3.04 : ℝ) * (206 / 249) := by
  constructor
  · rintro ⟨k, hk⟩
    by_contra hcon
    push_neg at hcon
    exact ecm250_never_leads_of_overhead c d hcon k hk
  · intro hd
    refine leads_of_below_hull (rhoArm c) (ecm250Arm c d) (ecm50Arm c) ?_
      (t := 43 / 249) (s := 206 / 249) (by norm_num) ?_ ?_
    · simp only [rhoArm, ecm50Arm]; norm_num
    · simp only [rhoArm, ecm50Arm, ecm250Arm]; norm_num
    · simp only [rhoArm, ecm50Arm, ecm250Arm]; nlinarith [hd]

/-- On the *physical* half-line `k ≥ 0` the hull criterion is not the operative one: any
positive overhead already makes rho strictly cheaper than the `B₁ = 250` column at
every accessible target size, so the witness produced by `leads_of_below_hull` necessarily
sits at a negative (unphysical) size. -/
theorem ecm250_never_leads_on_physical_range (c d : ℝ) (hd : 0 < d) {k : ℝ} (hk : 0 ≤ k) :
    ¬ Leads ![rhoArm c, ecm250Arm c d, ecm50Arm c] 1 k := by
  intro hlead
  have h := hlead 0
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one] at h
  have hstrict : work (rhoArm c) k < work (ecm250Arm c d) k := by
    refine dominates_strict ?_ ?_ hk
    · simp only [rhoArm, ecm250Arm]; norm_num
    · simp only [rhoArm, ecm250Arm]; linarith
  exact absurd h (not_le.mpr hstrict)


end ECMHull