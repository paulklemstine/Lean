import Bridges.NonlinearProbeCeilingD3

/-!
# The ANOVA anatomy of the nonlinear probe ceiling

A second pass over D3.  `NonlinearProbeCeilingD3` measured the ceiling; here it is *decomposed*,
and the two regimes in which it degenerates are characterised exactly.

* `sum_sq_split` — block Pythagoras: squared error about any constant = block dispersion +
  displacement of the block mean.  This upgrades the upstream inequality `sum_sq_mean_le` to an
  identity.
* `ssBetween`, `anova_decomposition` — `SS_tot = SS_within + SS_between`, whence
  `anovaCeiling_eq_between_ratio`: the ceiling is the correlation ratio `η²` of the content map,
  and `anovaCeiling_lt_half_iff_between_lt_within` restates D3 as the comparison of two directly
  measurable sums of squares.
* `ssWithin_eq_zero_iff`, `anovaCeiling_eq_one_iff` — the ceiling is `1` exactly when importance
  is already a function of content; `anovaCeiling_eq_zero_iff` — it is `0` exactly when every
  conditional mean equals the grand mean.  Both endpoints of the `[0,1)` family of
  `exists_pooled_population_with_ceiling` are thereby explained structurally.
* `fiber_dispersion_pair_eq`, `ssWithin_eq_half_sum_pairs`, `ceiling_lt_half_iff_pairs` — in the
  canonical pooling design (each key content seen in exactly two windows: one train, one test)
  the lower bound of `NonlinearProbeCeilingD3` §2 becomes an **equality**.  The ceiling of the
  entire nonlinear class is then literally half the sum of the observed importance gaps, and the
  D3 question is one arithmetic comparison.
* `condMean_add`, `condMean_smul`, `condMean_idempotent`, `condMean_selfAdjoint` — the best
  content head is an orthogonal projection: linear, idempotent and self-adjoint for the
  population inner product.  Idempotence is the precise sense in which stacking depth on top of
  the conditional mean gains nothing, and self-adjointness identifies `1 - SS_within/SS_tot` as
  a squared cosine.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the ceiling should be an angle, not merely a ratio; if the
conditional-mean operator is an orthogonal projection then `SS_between/SS_tot` is the squared
cosine between the centred importances and the space of content-measurable functions, and the
`0.5` threshold is the `45°` line.

Experiment (Experimenter): the identity `SS_tot = SS_within + SS_between` was checked numerically
on the swap witness (`SS_within = SS_tot = 0.36`, `SS_between = 0`, ceiling `0`; see
`ComputationalEvidence.md` §3) before being proved by `sum_sq_split`.

Analysis (Analyst): the exact pair formula is what makes D3 falsifiable in practice.  It also
explains why the certificate of the previous file is only a bound: with three or more windows per
content, one gap cannot see the whole fiber.

Critique (Critic): `anovaCeiling_eq_zero_iff` needs the "nonempty fiber" guard — contents that
never occur carry no information and must be excluded from the quantifier, otherwise the
characterisation is false for any `κ` with unused labels.  The guard is in the statement.
-/

namespace Catalog.Bridges.NonlinearProbeCeilingAnova

open Finset Catalog.Novelty.ProbeRetentionLimits Catalog.Novelty.NET58RelationalImportance
  Catalog.Bridges.NonlinearProbeCeilingD3

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

/-! ### 1. The exact within/between split -/

/-- **Block Pythagoras.**  Squared error about any constant splits into the block dispersion
plus the displacement of the block mean.  This is the identity behind `sum_sq_mean_le`. -/
theorem sum_sq_split {α : Type*} (G : Finset α) (g : α → ℝ) (c : ℝ) :
    ∑ i ∈ G, (g i - c) ^ 2
      = (∑ i ∈ G, (g i - (∑ j ∈ G, g j) / G.card) ^ 2)
        + G.card * ((∑ j ∈ G, g j) / G.card - c) ^ 2 := by
  rcases eq_or_ne G.card 0 with h0 | h0
  · rw [Finset.card_eq_zero.mp h0]; simp
  have hN : ((G.card : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr h0
  set m : ℝ := (∑ j ∈ G, g j) / G.card with hm
  have hsum : ∑ j ∈ G, g j = (G.card : ℝ) * m := by rw [hm]; field_simp
  have key : ∑ i ∈ G, ((g i - c) ^ 2 - (g i - m) ^ 2) = (G.card : ℝ) * (m - c) ^ 2 := by
    have h1 : ∀ i, (g i - c) ^ 2 - (g i - m) ^ 2 = 2 * (m - c) * g i + (c ^ 2 - m ^ 2) := by
      intro i; ring
    simp_rw [h1]
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul, hsum]
    ring
  rw [Finset.sum_sub_distrib] at key
  linarith

/-- The between-content sum of squares: the part of the dispersion that content *does*
explain. -/
noncomputable def ssBetween (key : ι → κ) (a : ι → ℝ) : ℝ :=
  ∑ y, (fiber key y).card * (condMean key a y - mean a) ^ 2

theorem ssBetween_nonneg (key : ι → κ) (a : ι → ℝ) : 0 ≤ ssBetween key a :=
  Finset.sum_nonneg fun _ _ => by positivity

/-- **The ANOVA decomposition.**  Total dispersion = unexplainable (within-content) +
explainable (between-content). -/
theorem anova_decomposition (key : ι → κ) (a : ι → ℝ) :
    sstot a = ssWithin key a + ssBetween key a := by
  have hfib : sstot a = ∑ y : κ, ∑ i ∈ fiber key y, (a i - mean a) ^ 2 := by
    rw [sstot, ← Finset.sum_fiberwise Finset.univ key (fun i => (a i - mean a) ^ 2)]
    rfl
  rw [hfib, ssWithin, ssBetween, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun y _ => ?_
  simpa [condMean] using sum_sq_split (fiber key y) a (mean a)

/-- The ceiling is exactly the explained fraction of the dispersion (the correlation ratio
`η²` of the content map). -/
theorem anovaCeiling_eq_between_ratio (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling key a = ssBetween key a / sstot a := by
  rw [anovaCeiling, eq_div_iff (ne_of_gt h), sub_mul, div_mul_cancel₀ _ (ne_of_gt h), one_mul]
  linarith [anova_decomposition key a]

/-- **The `0.5` question, restated exactly.**  The D3 threshold is the comparison of two
directly measurable sums of squares: explained versus unexplainable. -/
theorem anovaCeiling_lt_half_iff_between_lt_within (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling key a < 1 / 2 ↔ ssBetween key a < ssWithin key a := by
  rw [anovaCeiling_lt_half_iff key a h]
  constructor <;> intro hh <;> linarith [anova_decomposition key a]

/-! ### 2. The two degenerate regimes -/

/-- `SS_within` vanishes exactly when the importances are already a function of the content. -/
theorem ssWithin_eq_zero_iff (key : ι → κ) (a : ι → ℝ) :
    ssWithin key a = 0 ↔ ∃ f : κ → ℝ, ∀ i, a i = f (key i) := by
  constructor
  · intro h
    refine ⟨condMean key a, fun i => ?_⟩
    have hy : ∑ k ∈ fiber key (key i), (a k - condMean key a (key i)) ^ 2 = 0 := by
      have hnn : ∀ y ∈ (Finset.univ : Finset κ),
          0 ≤ ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 :=
        fun y _ => Finset.sum_nonneg fun _ _ => sq_nonneg _
      exact (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h _ (Finset.mem_univ _)
    have hmem : i ∈ fiber key (key i) := by simp [fiber]
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun k _ => sq_nonneg (a k - condMean key a (key i)))).mp
      hy i hmem
    have : a i - condMean key a (key i) = 0 := by nlinarith [this]
    linarith
  · rintro ⟨f, hf⟩
    have h1 : sse a (fun i => f (key i)) = 0 := by
      simp [sse, hf]
    have h2 := ssWithin_le_sse key a f
    have h3 := ssWithin_nonneg key a
    linarith

/-- The ceiling is `1` exactly in the regime where content determines importance. -/
theorem anovaCeiling_eq_one_iff (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling key a = 1 ↔ ∃ f : κ → ℝ, ∀ i, a i = f (key i) := by
  rw [← ssWithin_eq_zero_iff key a, anovaCeiling]
  constructor
  · intro hh
    have : ssWithin key a / sstot a = 0 := by linarith
    exact (div_eq_zero_iff.mp this).resolve_right (ne_of_gt h)
  · intro hh; rw [hh]; simp

/-- The ceiling is `0` exactly when content carries no signal at all: every conditional mean
equals the grand mean. -/
theorem anovaCeiling_eq_zero_iff (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling key a = 0 ↔ ∀ y : κ, (fiber key y).Nonempty → condMean key a y = mean a := by
  rw [anovaCeiling_eq_between_ratio key a h, div_eq_zero_iff]
  constructor
  · rintro (hb | hb)
    · intro y hy
      have hnn : ∀ z ∈ (Finset.univ : Finset κ),
          0 ≤ ((fiber key z).card : ℝ) * (condMean key a z - mean a) ^ 2 :=
        fun z _ => by positivity
      have hz := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hb y (Finset.mem_univ y)
      have hcard : ((fiber key y).card : ℝ) ≠ 0 := by
        simpa using (Finset.card_pos.mpr hy).ne'
      have : (condMean key a y - mean a) ^ 2 = 0 := by
        rcases mul_eq_zero.mp hz with h' | h'
        · exact absurd h' hcard
        · exact h'
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
      linarith
    · exact absurd hb (ne_of_gt h)
  · intro hy
    left
    refine Finset.sum_eq_zero fun y _ => ?_
    rcases (fiber key y).eq_empty_or_nonempty with he | hne
    · simp [he]
    · rw [hy y hne]; simp

/-! ### 3. Exact measurement in the one-train-one-test pooling regime -/

omit [Fintype κ] in
/-- A fiber of exactly two windows contributes exactly half the squared gap. -/
theorem fiber_dispersion_pair_eq [DecidableEq ι] (key : ι → κ) (a : ι → ℝ) {y : κ} {i j : ι}
    (hfib : fiber key y = {i, j}) (hij : i ≠ j) :
    ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 = (a i - a j) ^ 2 / 2 := by
  have hcard : (fiber key y).card = 2 := by rw [hfib, Finset.card_pair hij]
  have hsum : ∑ k ∈ fiber key y, a k = a i + a j := by rw [hfib, Finset.sum_pair hij]
  have hm : condMean key a y = (a i + a j) / 2 := by
    rw [condMean, hsum, hcard]; norm_num
  rw [hfib, Finset.sum_pair hij, hm]
  ring

/-- **The ceiling is measured, not searched for.**  If each key content is seen in exactly two
pooled windows — the canonical train/test pooling — then `SS_within` equals half the sum of the
squared importance gaps of the repeated contents.  No predictor, and no hypothesis class, enters
the computation. -/
theorem ssWithin_eq_half_sum_pairs [DecidableEq ι] (key : ι → κ) (a : ι → ℝ) (p q : κ → ι)
    (hfib : ∀ y, fiber key y = {p y, q y}) (hne : ∀ y, p y ≠ q y) :
    ssWithin key a = (∑ y, (a (p y) - a (q y)) ^ 2) / 2 := by
  rw [ssWithin, Finset.sum_div]
  exact Finset.sum_congr rfl fun y _ => fiber_dispersion_pair_eq key a (hfib y) (hne y)

/-- In that regime the D3 threshold becomes a finite arithmetic test on observable numbers. -/
theorem ceiling_lt_half_iff_pairs [DecidableEq ι] (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a)
    (p q : κ → ι)
    (hfib : ∀ y, fiber key y = {p y, q y}) (hne : ∀ y, p y ≠ q y) :
    anovaCeiling key a < 1 / 2 ↔ sstot a < ∑ y, (a (p y) - a (q y)) ^ 2 := by
  rw [anovaCeiling_lt_half_iff key a h, ssWithin_eq_half_sum_pairs key a p q hfib hne]
  constructor <;> intro hh <;> linarith

/-! ### 4. The conditional mean is an orthogonal projection -/

omit [Fintype κ] in
/-- Every fiber sum is its cardinality times its conditional mean. -/
theorem sum_fiber_eq_card_mul_condMean (key : ι → κ) (a : ι → ℝ) (y : κ) :
    ∑ i ∈ fiber key y, a i = (fiber key y).card * condMean key a y := by
  rcases eq_or_ne (fiber key y).card 0 with h0 | h0
  · rw [Finset.card_eq_zero.mp h0]; simp
  · rw [condMean]
    field_simp

omit [Fintype κ] in
/-- The content projection is additive. -/
theorem condMean_add (key : ι → κ) (a b : ι → ℝ) (y : κ) :
    condMean key (fun i => a i + b i) y = condMean key a y + condMean key b y := by
  rw [condMean, condMean, condMean, Finset.sum_add_distrib, add_div]

omit [Fintype κ] in
/-- The content projection is homogeneous. -/
theorem condMean_smul (key : ι → κ) (a : ι → ℝ) (c : ℝ) (y : κ) :
    condMean key (fun i => c * a i) y = c * condMean key a y := by
  rw [condMean, condMean, ← Finset.mul_sum, mul_div_assoc]

omit [Fintype κ] in
/-- **Idempotence.**  Averaging an already content-measurable function changes nothing: the
best content head is a projection, so a *deeper* head applied on top of it gains exactly
nothing. -/
theorem condMean_idempotent (key : ι → κ) (a : ι → ℝ) (y : κ) :
    condMean key (fun i => condMean key a (key i)) y = condMean key a y := by
  rcases eq_or_ne (fiber key y).card 0 with h0 | h0
  · rw [condMean, condMean, Finset.card_eq_zero.mp h0]
    simp
  · have hc : ∑ i ∈ fiber key y, condMean key a (key i)
        = (fiber key y).card * condMean key a y := by
      rw [Finset.sum_congr rfl (fun i hi => by rw [(Finset.mem_filter.mp hi).2] :
        ∀ i ∈ fiber key y, condMean key a (key i) = condMean key a y)]
      simp [mul_comm]
    rw [condMean, hc]
    field_simp

/-- The bilinear form of the projection, written symmetrically. -/
theorem sum_condMean_mul (key : ι → κ) (a b : ι → ℝ) :
    ∑ i, condMean key a (key i) * b i
      = ∑ y, (fiber key y).card * (condMean key a y * condMean key b y) := by
  have hfib : ∑ i, condMean key a (key i) * b i
      = ∑ y : κ, ∑ i ∈ fiber key y, condMean key a (key i) * b i := by
    rw [← Finset.sum_fiberwise Finset.univ key (fun i => condMean key a (key i) * b i)]
    rfl
  rw [hfib]
  refine Finset.sum_congr rfl fun y _ => ?_
  have hcong : ∑ i ∈ fiber key y, condMean key a (key i) * b i
      = condMean key a y * ∑ i ∈ fiber key y, b i := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i hi => by rw [(Finset.mem_filter.mp hi).2]
  rw [hcong, sum_fiber_eq_card_mul_condMean key b y]
  ring

/-- **Self-adjointness.**  The content projection is symmetric for the population inner
product; together with idempotence this identifies `1 - SS_within/SS_tot` as the squared cosine
of the angle between the centred importances and the space of content-measurable functions. -/
theorem condMean_selfAdjoint (key : ι → κ) (a b : ι → ℝ) :
    ∑ i, condMean key a (key i) * b i = ∑ i, a i * condMean key b (key i) := by
  have h1 := sum_condMean_mul key a b
  have h2 := sum_condMean_mul key b a
  have h3 : ∑ i, a i * condMean key b (key i) = ∑ i, condMean key b (key i) * a i :=
    Finset.sum_congr rfl fun i _ => mul_comm _ _
  rw [h1, h3, h2]
  exact Finset.sum_congr rfl fun y _ => by ring

end Catalog.Bridges.NonlinearProbeCeilingAnova