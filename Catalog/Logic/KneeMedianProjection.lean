/-
# Cycle 3: the median is a metric projection — firm nonexpansiveness and its characterisation

`Logic.KneeMedianLaw` introduced the three-seed median `med3` / `med3L` of a knee ensemble
and `Logic.KneeQuotaScaling` proved its *qualitative* robustness: one corrupted seed can
never push the median outside the bracket `[min, max]` of the two clean seeds
(`three_seed_median_breakdown`).  That statement says nothing about *how far* the median
moves when a seed moves a little.  This file supplies the quantitative theory, and it does
so by identifying the object the median really is:

> **`med3L x a b` is the metric projection of the perturbed seed `x` onto the interval
> `[min a b, max a b]` spanned by the clean seeds** (`med3L_eq_proj`).

Once that is seen, the whole convex-analytic toolbox applies, and the sharp robustness
constant is not `1` (nonexpansiveness) but the *firm* inequality

  `(T x - T y)² + ((x - T x) - (y - T y))² ≤ (x - y)²`,

which says that the movement of the median and the movement of the *residual* (the part of
the corruption the median absorbs) obey a Pythagorean budget.  Nonexpansiveness is the
corollary obtained by discarding the residual term.

**What this file proves.**

*§1 The median is a clamp.*  `proj_eq_med3L`, `med3L_eq_proj`, `proj_mono`, `proj_mem`.

*§2 Firm nonexpansiveness (the headline).*  `proj_variational` is the classical variational
inequality `⟨x - Px, y - Px⟩ ≤ 0` for `y` in the interval; `proj_firmly_nonexpansive`
derives firmness from it by the Hilbert-space argument (add the two variational
inequalities), and `proj_nearest`, `proj_pythagoras`, `proj_unique_argmin` show `Px` is the
*unique* nearest point, i.e. the median is the proximal map of the interval's indicator.

*§3 The characterisation (the open question of cycle 2, now closed).*  On `ℝ`, firm
nonexpansiveness is *exactly* the conjunction of monotonicity and `1`-Lipschitzness
(`firm_iff_monoLip`), equivalently the nonexpansiveness of the reflection `2T - I`
(`firm_iff_reflection_nonexpansive`).  Consequently a map is *the* median projection iff it
is firmly nonexpansive, fixes the two endpoints, and has range in the interval
(`proj_characterisation`).  Firmness cannot be weakened to nonexpansiveness:
`firmness_necessary` exhibits a nonexpansive map with the same fixed-point set and the same
range which is *not* the projection.  The fixed-point set of any firmly nonexpansive map on
`ℝ` is order-convex (`firm_fix_ordConnected`), which is the order-theoretic shadow of
"the fixed set of a firmly nonexpansive map is convex".

*§4 Dimension is essential.*  On `ℝ` firm nonexpansiveness is closed under composition
(`firm_comp`) — a purely one-dimensional phenomenon.  In `ℝ²` it fails: `P₁` (projection
onto the horizontal axis) and `P₂` (projection onto the diagonal) are firmly nonexpansive
(`firm₂_P₁`, `firm₂_P₂`) but `P₁ ∘ P₂` is not (`firm₂_comp_fails`).  So the composition
theorem of §4 is not a formal consequence of firmness; it is a theorem about the line.

*§5 Averaged iteration.*  The relaxed median update `x ↦ (1-λ)x + λ·med` contracts the
residual by exactly `(1-λ)` per step (`averaged_iterate`) and converges to the median
(`averaged_tendsto`) — a Krasnoselskii–Mann statement with an exact, not asymptotic, rate.

*§6 Back to the seed ensemble.*  `med3_cast_proj` transports the ℕ-valued catalogue median
onto the real projection, giving `med3_nonexpansive` and `med3_firm`: a seed corrupted by
`δ` moves the three-seed knee median by at most `δ`, and the two displacements obey the
Pythagorean budget.  `net48_median_firm` instantiates this at the recorded NET-48 knee set
`{256, 224, 160}`.
-/

import Mathlib
import Logic.KneeQuotaScaling

namespace KneeProj

open KneeMedian KneeQuota

/-! ## 1.  The median of three reals is the clamp of one onto the span of the other two -/

/-- The metric projection of `x` onto the interval `[a, b]` (the "clamp"). -/
def proj (a b x : ℝ) : ℝ := max a (min x b)

/-- For an ordered pair of endpoints the clamp is the median. -/
theorem proj_eq_med3L {a b : ℝ} (hab : a ≤ b) (x : ℝ) : proj a b x = med3L x a b := by
  unfold proj med3L
  rcases le_total x a with h | h <;> rcases le_total x b with h' | h' <;>
    simp only [max_def, min_def] <;> split_ifs <;> linarith

/-- **The median is a projection.**  The median of `x, a, b` is the projection of `x` onto
the interval spanned by `a` and `b`. -/
theorem med3L_eq_proj (a b x : ℝ) : med3L x a b = proj (min a b) (max a b) x := by
  rw [proj_eq_med3L (min_le_max)]
  unfold med3L
  rcases le_total a b with h | h <;> rcases le_total x a with h1 | h1 <;>
    rcases le_total x b with h2 | h2 <;> simp only [max_def, min_def] <;>
    split_ifs <;> linarith

theorem proj_mono (a b : ℝ) : Monotone (proj a b) := fun _ _ h => by
  unfold proj; exact max_le_max le_rfl (min_le_min h le_rfl)

theorem proj_mem {a b : ℝ} (hab : a ≤ b) (x : ℝ) : proj a b x ∈ Set.Icc a b :=
  ⟨le_max_left _ _, max_le hab (min_le_right _ _)⟩

theorem proj_eq_self_of_mem {a b x : ℝ} (hx : x ∈ Set.Icc a b) : proj a b x = x := by
  unfold proj; rw [min_eq_left hx.2, max_eq_right hx.1]

theorem proj_of_le {a b x : ℝ} (hab : a ≤ b) (hx : x ≤ a) : proj a b x = a := by
  unfold proj; rw [min_eq_left (hx.trans hab), max_eq_left hx]

theorem proj_of_ge {a b x : ℝ} (hab : a ≤ b) (hb : b ≤ x) : proj a b x = b := by
  unfold proj; rw [min_eq_right hb, max_eq_right hab]

/-! ## 2.  Firm nonexpansiveness -/

/-- A self-map of the line is **firmly nonexpansive** when the displacement of the map and
the displacement of the residual `I - T` obey a Pythagorean budget. -/
def FirmNE (T : ℝ → ℝ) : Prop :=
  ∀ x y : ℝ, (T x - T y) ^ 2 + ((x - T x) - (y - T y)) ^ 2 ≤ (x - y) ^ 2

/-- Nonexpansiveness on the line. -/
def NonexpansiveR (T : ℝ → ℝ) : Prop := ∀ x y : ℝ, |T x - T y| ≤ |x - y|

/-- The algebraic normal form of firmness: `⟨Tx - Ty, x - y⟩ ≥ ‖Tx - Ty‖²`. -/
theorem firm_iff_inner (T : ℝ → ℝ) :
    FirmNE T ↔ ∀ x y : ℝ, (T x - T y) ^ 2 ≤ (T x - T y) * (x - y) := by
  constructor
  · intro h x y; have := h x y; nlinarith [this]
  · intro h x y; have := h x y; nlinarith [this]

/-- **Variational inequality.**  The projection is characterised by the obtuse-angle
condition: from the projected point, every point of the interval lies on the far side of
the residual. -/
theorem proj_variational {a b : ℝ} (hab : a ≤ b) (x : ℝ) {y : ℝ} (hy : y ∈ Set.Icc a b) :
    (x - proj a b x) * (y - proj a b x) ≤ 0 := by
  rcases le_total x a with h | h
  · rw [proj_of_le hab h]
    have : 0 ≤ y - a := by linarith [hy.1]
    nlinarith
  · rcases le_total x b with h' | h'
    · rw [proj_eq_self_of_mem ⟨h, h'⟩]; simp
    · rw [proj_of_ge hab h']
      have : y - b ≤ 0 := by linarith [hy.2]
      nlinarith

/-- **Headline theorem (`proj_firmly_nonexpansive`).**  The median-as-projection is firmly
nonexpansive.  The proof is the Hilbert-space one: add the two variational inequalities. -/
theorem proj_firmly_nonexpansive {a b : ℝ} (hab : a ≤ b) : FirmNE (proj a b) := by
  rw [firm_iff_inner]
  intro x y
  have h1 := proj_variational hab x (proj_mem hab y)
  have h2 := proj_variational hab y (proj_mem hab x)
  nlinarith [h1, h2]

/-- The projection realises the distance to the interval. -/
theorem proj_nearest {a b : ℝ} (hab : a ≤ b) (x : ℝ) {y : ℝ} (hy : y ∈ Set.Icc a b) :
    |x - proj a b x| ≤ |x - y| := by
  have h := proj_variational hab x hy
  have : (x - proj a b x) ^ 2 ≤ (x - y) ^ 2 := by nlinarith
  exact sq_le_sq.1 this

/-- **Pythagorean inequality for the projection.**  The interval, the projected point and
any point of the interval form a right-angled configuration: the residual is orthogonal to
the interval.  This refines `proj_nearest`. -/
theorem proj_pythagoras {a b : ℝ} (hab : a ≤ b) (x : ℝ) {y : ℝ} (hy : y ∈ Set.Icc a b) :
    (x - proj a b x) ^ 2 + (proj a b x - y) ^ 2 ≤ (x - y) ^ 2 := by
  have h := proj_variational hab x hy
  nlinarith [h]

/-- **The median is the unique minimiser.**  `proj a b x` is the one point of `[a,b]`
closest to `x`; every other point of the interval is strictly further away.  Equivalently,
the median is the proximal map of the indicator function of the interval. -/
theorem proj_unique_argmin {a b : ℝ} (hab : a ≤ b) (x : ℝ) {y : ℝ} (hy : y ∈ Set.Icc a b)
    (hle : (x - y) ^ 2 ≤ (x - proj a b x) ^ 2) : y = proj a b x := by
  have h := proj_pythagoras hab x hy
  have : (proj a b x - y) ^ 2 ≤ 0 := by linarith
  have h0 : proj a b x - y = 0 := by nlinarith [sq_nonneg (proj a b x - y)]
  linarith

/-- Firmness implies nonexpansiveness (discard the residual term). -/
theorem FirmNE.nonexpansive {T : ℝ → ℝ} (h : FirmNE T) : NonexpansiveR T := by
  intro x y
  have := h x y
  have hsq : (T x - T y) ^ 2 ≤ (x - y) ^ 2 := by nlinarith [sq_nonneg ((x - T x) - (y - T y))]
  exact sq_le_sq.1 hsq

/-! ## 3.  The characterisation -/

/-- Monotone and `1`-Lipschitz, in increment form. -/
def MonoLip (T : ℝ → ℝ) : Prop := ∀ x y : ℝ, x ≤ y → T x ≤ T y ∧ T y - T x ≤ y - x

/-- **Characterisation of firm nonexpansiveness on the line.**  A self-map of `ℝ` is firmly
nonexpansive exactly when it is monotone and `1`-Lipschitz.  (In a general Hilbert space
only "⟸ fails / ⟹ holds" fragments of this survive; the line collapses the two notions.) -/
theorem firm_iff_monoLip (T : ℝ → ℝ) : FirmNE T ↔ MonoLip T := by
  rw [firm_iff_inner]
  constructor
  · intro h x y hxy
    have h1 := h y x
    have hxy' : 0 ≤ y - x := by linarith
    have hmono : T x ≤ T y := by nlinarith [h1, sq_nonneg (T y - T x)]
    exact ⟨hmono, by nlinarith [h1]⟩
  · intro h x y
    rcases le_total x y with hxy | hxy
    · obtain ⟨h1, h2⟩ := h x y hxy; nlinarith
    · obtain ⟨h1, h2⟩ := h y x hxy; nlinarith

/-- **Reflection form.**  `T` is firmly nonexpansive iff its reflection `2T - I` is
nonexpansive, i.e. iff `T` is the midpoint average of the identity and a nonexpansive map.
This is the resolvent/averaged-operator picture of firmness. -/
theorem firm_iff_reflection_nonexpansive (T : ℝ → ℝ) :
    FirmNE T ↔ NonexpansiveR (fun x => 2 * T x - x) := by
  constructor
  · intro h x y
    have hxy := h x y
    have : (2 * T x - x - (2 * T y - y)) ^ 2 ≤ (x - y) ^ 2 := by nlinarith [hxy]
    exact sq_le_sq.1 this
  · intro h x y
    have hxy := h x y
    have h2 : (2 * T x - x - (2 * T y - y)) ^ 2 ≤ (x - y) ^ 2 := sq_le_sq.2 hxy
    nlinarith [h2]

/-- The fixed-point set of a firmly nonexpansive map on the line is order-convex: this is
the one-dimensional form of "the fixed set of a firmly nonexpansive operator is convex". -/
theorem firm_fix_ordConnected {T : ℝ → ℝ} (h : FirmNE T) {u v w : ℝ}
    (hu : T u = u) (hv : T v = v) (huw : u ≤ w) (hwv : w ≤ v) : T w = w := by
  rw [firm_iff_monoLip] at h
  obtain ⟨_, h2⟩ := h u w huw
  obtain ⟨_, h4⟩ := h w v hwv
  rw [hu] at h2; rw [hv] at h4
  linarith

/-- **The characterisation of the median-as-projection.**  Among all self-maps of the line,
`proj a b` is singled out by three properties: firm nonexpansiveness, fixing the two
endpoints, and mapping into the interval. -/
theorem proj_characterisation {a b : ℝ} (hab : a ≤ b) (T : ℝ → ℝ) :
    T = proj a b ↔
      (FirmNE T ∧ T a = a ∧ T b = b ∧ ∀ x, T x ∈ Set.Icc a b) := by
  constructor
  · rintro rfl
    exact ⟨proj_firmly_nonexpansive hab, proj_eq_self_of_mem ⟨le_rfl, hab⟩,
      proj_eq_self_of_mem ⟨hab, le_rfl⟩, proj_mem hab⟩
  · rintro ⟨hfirm, ha, hb, hrange⟩
    funext x
    rw [firm_iff_monoLip] at hfirm
    rcases le_total x a with h | h
    · obtain ⟨hmono, _⟩ := hfirm x a h
      rw [ha] at hmono
      rw [proj_of_le hab h]
      exact le_antisymm hmono (hrange x).1
    · rcases le_total x b with h' | h'
      · obtain ⟨_, h2⟩ := hfirm a x h
        obtain ⟨_, h4⟩ := hfirm x b h'
        rw [ha] at h2; rw [hb] at h4
        rw [proj_eq_self_of_mem ⟨h, h'⟩]
        linarith
      · obtain ⟨hmono, _⟩ := hfirm b x h'
        rw [hb] at hmono
        rw [proj_of_ge hab h']
        exact le_antisymm (hrange x).2 hmono

/-- **Sharpness: firmness cannot be weakened to nonexpansiveness.**  The map
`x ↦ min |x| 1` is nonexpansive, has range `[0,1]`, and fixes exactly `[0,1]`, yet it is
not the projection onto `[0,1]`.  Hence the characterisation above genuinely needs the
Pythagorean (firm) inequality, not merely the Lipschitz bound. -/
theorem firmness_necessary :
    ∃ T : ℝ → ℝ, NonexpansiveR T ∧ (∀ x, T x ∈ Set.Icc (0:ℝ) 1) ∧
      (∀ x, T x = x ↔ x ∈ Set.Icc (0:ℝ) 1) ∧ T ≠ proj 0 1 := by
  refine ⟨fun x => min |x| 1, ?_, ?_, ?_, ?_⟩
  · intro x y
    have key : ∀ u v : ℝ, |min u 1 - min v 1| ≤ |u - v| := by
      intro u v
      have h1 := le_abs_self (u - v)
      have h2 := neg_abs_le (u - v)
      rcases le_total u 1 with hu | hu <;> rcases le_total v 1 with hv | hv <;>
        simp only [min_def] <;> split_ifs <;> rw [abs_le] <;>
        exact ⟨by linarith, by linarith⟩
    exact (key |x| |y|).trans (abs_abs_sub_abs_le_abs_sub x y)
  · intro x
    exact ⟨le_min (abs_nonneg x) zero_le_one, min_le_right _ _⟩
  · intro x
    constructor
    · intro hx
      refine ⟨?_, ?_⟩
      · rw [← hx]; exact le_min (abs_nonneg x) zero_le_one
      · rw [← hx]; exact min_le_right _ _
    · rintro ⟨h0, h1⟩
      show min |x| 1 = x
      rw [abs_of_nonneg h0, min_eq_left h1]
  · intro hcon
    have h1 : (fun x : ℝ => min |x| 1) (-2) = proj 0 1 (-2) := by rw [hcon]
    rw [proj_of_le zero_le_one (by norm_num : (-2:ℝ) ≤ 0)] at h1
    norm_num at h1

/-! ## 4.  Composition: a one-dimensional miracle -/

/-- **On the line, firm nonexpansiveness is closed under composition.**  (Monotone and
`1`-Lipschitz are both closed under composition; firmness is their conjunction.) -/
theorem firm_comp {S T : ℝ → ℝ} (hS : FirmNE S) (hT : FirmNE T) : FirmNE (S ∘ T) := by
  rw [firm_iff_monoLip] at hS hT ⊢
  intro x y hxy
  obtain ⟨h1, h2⟩ := hT x y hxy
  obtain ⟨h3, h4⟩ := hS (T x) (T y) h1
  exact ⟨h3, by simp only [Function.comp_apply]; linarith⟩

/-- Squared Euclidean norm on the plane. -/
def sq2 (p : ℝ × ℝ) : ℝ := p.1 ^ 2 + p.2 ^ 2

/-- Firm nonexpansiveness in the Euclidean plane. -/
def FirmNE₂ (T : ℝ × ℝ → ℝ × ℝ) : Prop :=
  ∀ x y : ℝ × ℝ, sq2 (T x - T y) + sq2 ((x - T x) - (y - T y)) ≤ sq2 (x - y)

/-- Orthogonal projection onto the horizontal axis. -/
def P₁ : ℝ × ℝ → ℝ × ℝ := fun p => (p.1, 0)

/-- Orthogonal projection onto the diagonal. -/
noncomputable def P₂ : ℝ × ℝ → ℝ × ℝ := fun p => ((p.1 + p.2) / 2, (p.1 + p.2) / 2)

theorem firm₂_P₁ : FirmNE₂ P₁ := by
  rintro ⟨x1, x2⟩ ⟨y1, y2⟩
  simp only [sq2, P₁, Prod.fst_sub, Prod.snd_sub]
  ring_nf
  nlinarith [sq_nonneg (x1 - y1), sq_nonneg (x2 - y2)]

theorem firm₂_P₂ : FirmNE₂ P₂ := by
  rintro ⟨x1, x2⟩ ⟨y1, y2⟩
  simp only [sq2, P₂, Prod.fst_sub, Prod.snd_sub]
  ring_nf
  nlinarith [sq_nonneg (x1 - y1 - (x2 - y2))]

/-- **Dimension is essential.**  The composition of two orthogonal projections in the plane
need not be firmly nonexpansive, so `firm_comp` is a genuinely one-dimensional theorem and
not an instance of an abstract Hilbert-space fact. -/
theorem firm₂_comp_fails : ¬ FirmNE₂ (P₁ ∘ P₂) := by
  intro h
  have := h (0, 1) (0, 0)
  simp only [sq2, P₁, P₂, Function.comp_apply, Prod.fst_sub, Prod.snd_sub] at this
  norm_num at this

/-! ## 5.  Relaxed (averaged) median updates -/

/-- The `λ`-relaxed median update. -/
noncomputable def averaged (lam a b : ℝ) : ℝ → ℝ := fun x => (1 - lam) * x + lam * proj a b x

theorem averaged_sub (lam a b x : ℝ) :
    averaged lam a b x - proj a b x = (1 - lam) * (x - proj a b x) := by
  unfold averaged; ring

/-- A relaxed update never leaves the "side" of the interval it started on: its projection
is unchanged. -/
theorem proj_averaged {a b : ℝ} (hab : a ≤ b) {lam : ℝ} (hl0 : 0 ≤ lam) (hl1 : lam ≤ 1)
    (x : ℝ) : proj a b (averaged lam a b x) = proj a b x := by
  have hp : proj a b (proj a b x) = proj a b x := proj_eq_self_of_mem (proj_mem hab x)
  rcases le_total x (proj a b x) with h | h
  · have h1 : x ≤ averaged lam a b x := by
      have : 0 ≤ (1 - lam) * 0 + lam * (proj a b x - x) := by nlinarith
      unfold averaged; nlinarith
    have h2 : averaged lam a b x ≤ proj a b x := by unfold averaged; nlinarith
    have m1 := proj_mono a b h1
    have m2 := proj_mono a b h2
    rw [hp] at m2
    linarith
  · have h1 : proj a b x ≤ averaged lam a b x := by unfold averaged; nlinarith
    have h2 : averaged lam a b x ≤ x := by unfold averaged; nlinarith
    have m1 := proj_mono a b h1
    have m2 := proj_mono a b h2
    rw [hp] at m1
    linarith

theorem proj_averaged_iterate {a b : ℝ} (hab : a ≤ b) {lam : ℝ} (hl0 : 0 ≤ lam) (hl1 : lam ≤ 1)
    (x : ℝ) (n : ℕ) : proj a b ((averaged lam a b)^[n] x) = proj a b x := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', proj_averaged hab hl0 hl1, ih]

/-- **Exact geometric decay of the residual.**  Relaxed median updates contract the distance
to the median by exactly the factor `1 - λ` at every step — an exact rate, not a bound. -/
theorem averaged_iterate {a b : ℝ} (hab : a ≤ b) {lam : ℝ} (hl0 : 0 ≤ lam) (hl1 : lam ≤ 1)
    (x : ℝ) (n : ℕ) :
    (averaged lam a b)^[n] x - proj a b x = (1 - lam) ^ n * (x - proj a b x) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      have hfix := proj_averaged_iterate hab hl0 hl1 x n
      have := averaged_sub lam a b ((averaged lam a b)^[n] x)
      rw [hfix] at this
      rw [this, ih]
      ring

/-- Krasnoselskii–Mann convergence for the relaxed median update, with the exact rate. -/
theorem averaged_tendsto {a b : ℝ} (hab : a ≤ b) {lam : ℝ} (hl0 : 0 < lam) (hl1 : lam ≤ 1)
    (x : ℝ) :
    Filter.Tendsto (fun n => (averaged lam a b)^[n] x) Filter.atTop
      (nhds (proj a b x)) := by
  have key : ∀ n : ℕ, (averaged lam a b)^[n] x
      = proj a b x + (1 - lam) ^ n * (x - proj a b x) := by
    intro n; have := averaged_iterate hab hl0.le hl1 x n; linarith
  simp only [key]
  have habs : |1 - lam| < 1 := by rw [abs_lt]; constructor <;> linarith
  have h0 : Filter.Tendsto (fun n : ℕ => (1 - lam) ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one habs
  have := (h0.mul_const (x - proj a b x)).const_add (proj a b x)
  simpa using this

/-! ## 6.  Back to the seed ensemble: quantitative median robustness -/

/-- The ℕ-valued catalogue median is the real projection of the (cast) perturbed seed onto
the interval spanned by the two clean seeds. -/
theorem med3_cast_proj (x a b : ℕ) :
    ((med3 x a b : ℕ) : ℝ) = proj (min (a : ℝ) b) (max (a : ℝ) b) x := by
  have hmono : Monotone (fun n : ℕ => (n : ℝ)) := Nat.mono_cast
  rw [← med3L_eq_proj, ← med3L_nat]
  exact (med3L_map hmono x a b).symm

/-- **Quantitative breakdown.**  Corrupting one seed by `δ` moves the three-seed median by
at most `δ`.  This sharpens the qualitative bracket `min ≤ med ≤ max` of
`KneeQuota.three_seed_median_breakdown` into a Lipschitz estimate. -/
theorem med3_nonexpansive (x y a b : ℕ) :
    |((med3 x a b : ℕ) : ℝ) - ((med3 y a b : ℕ) : ℝ)| ≤ |(x : ℝ) - (y : ℝ)| := by
  rw [med3_cast_proj, med3_cast_proj]
  exact (proj_firmly_nonexpansive (min_le_max (a := (a:ℝ)) (b := (b:ℝ)))).nonexpansive _ _

/-- **The Pythagorean robustness budget.**  Not only does the median move by at most the
corruption: the median's displacement and the *absorbed* part of the corruption satisfy the
firm inequality, so any median motion is paid for by a quadratic loss of absorption. -/
theorem med3_firm (x y a b : ℕ) :
    (((med3 x a b : ℕ) : ℝ) - ((med3 y a b : ℕ) : ℝ)) ^ 2
      + (((x : ℝ) - ((med3 x a b : ℕ) : ℝ)) - ((y : ℝ) - ((med3 y a b : ℕ) : ℝ))) ^ 2
      ≤ ((x : ℝ) - (y : ℝ)) ^ 2 := by
  rw [med3_cast_proj, med3_cast_proj]
  exact proj_firmly_nonexpansive (min_le_max (a := (a:ℝ)) (b := (b:ℝ))) _ _

/-- The recorded NET-48 three-seed knee set is `{256, 224, 160}`; with the clean seeds
`160` and `256` the median `224` is the projection of the third seed onto `[160, 256]`, and
it is firmly nonexpansive in that seed. -/
theorem net48_median_firm (x : ℕ) :
    ((med3 x 160 256 : ℕ) : ℝ) = proj 160 256 x ∧
      ∀ y : ℕ, |((med3 x 160 256 : ℕ) : ℝ) - ((med3 y 160 256 : ℕ) : ℝ)| ≤ |(x : ℝ) - y| := by
  refine ⟨?_, fun y => med3_nonexpansive x y 160 256⟩
  rw [med3_cast_proj]
  norm_num

/-- Sanity check that the NET-48 median really is `224` when the third seed is `224`. -/
theorem net48_median_value : med3 224 160 256 = 224 := by unfold med3; omega

end KneeProj