import Applications.JokeColimitUniversality

/-!
# Stability and correlation for the surprise invariant

`Applications.JokeSurpriseAlgebra` measured the surprise of a setup `S ⊆ ℝ` by its
range `humor S = max' S - min' S`, and `Applications.JokeColimitUniversality` showed
that this invariant is submodular and is maximised at universal (terminal) jokes.

Two questions were left open by that development, and both are prerequisites for the
empirical claim of the programme ("`H(J)` correlates with human funniness ratings"):

1. **Is surprise the shadow of a genuine metric invariant?** If humor is to be a
   *distance* `d(lim S, colim S')` on a category of punchlines, the range model must be
   the one-dimensional case of a metric-space construction.
2. **Is surprise stable?** A rating experiment is meaningless if paraphrasing a joke —
   perturbing each reading by at most `ε` — can change its measured humor arbitrarily.

## Results

### Surprise is a diameter
* `humor_eq_diam` : the catalog's `humor` is *exactly* `Metric.diam` of the setup viewed
  as a subset of `ℝ`. The range model is therefore the `ℝ`-instance of a general
  metric-space invariant `metricHumor s = diam s`.
* `metricHumor_union_le_add_of_shared` : the catalog's subadditivity law generalises
  verbatim to an arbitrary (pseudo)metric space of readings.
* `metricHumor_mono` : monotonicity generalises too.

### Surprise is Lipschitz, hence experimentally meaningful
* `diam_le_diam_add_two_hausdorffDist` and `abs_diam_sub_diam_le_two_hausdorffDist` :
  the metric surprise is **2-Lipschitz for the Hausdorff distance** between setups.
  Two setups that are `δ`-close as configurations of readings have humors differing by
  at most `2δ`.
* `abs_humor_image_sub_humor_le` : the **paraphrase bound**. If every reading is moved
  by at most `ε`, the measured humor moves by at most `2ε`. The constant `2` is sharp
  (`paraphrase_bound_sharp`).

### Correlation with ratings
* `empCov_nonneg_of_monovaryOn` : if funniness ratings *monovary* with humor, the
  empirical covariance of humor and rating is nonnegative. This is the precise,
  provable form of the programme's correlation conjecture (a Chebyshev sum inequality).
* `exists_dataset_empCov_neg` : the hypothesis cannot be dropped — there is a two-joke
  dataset with strictly negative covariance. Correlation is a *property of the data*,
  not a theorem about humor.
* `hundredJokes_empCov_nonneg` : the 100-joke test suite. Jokes `J i` (`i < 100`) with
  setups `{0, i}` have `H(J i) = i`; against any monotone rating model — we use the
  saturating model `R i = min i 50`, reflecting the empirical ceiling of rating scales —
  the covariance of humor and rating is nonnegative.
* `sampleJokes_empCov_pos` : a concrete three-joke sample (pun / wordplay / absurdist)
  with strictly positive covariance.

-- !-- Lab Notes -- !--
Hypothesis (H4): the one-dimensional range model is not ad hoc but is `Metric.diam`.
Hypothesis (H5): surprise is Lipschitz in the Hausdorff metric on setups, with
constant 2, and 2 cannot be improved.
Hypothesis (H6): "humor correlates with funniness" is a theorem.

Experiment: H4 was settled by a two-sided argument (`dist_le_diam_of_mem` at the
extremes, `diam_le_of_forall_dist_le` in general). H5 was proved by an
`ε`-approximation argument through `exists_dist_lt_of_hausdorffDist_lt` plus
`dist_triangle4`, then a `by_contra` limit step; sharpness was witnessed by
`{0,1} ↦ {-1,2}` at `ε = 1`, where the humor gap is exactly `2ε`.
H6 was tested on synthetic datasets of sizes 2, 3 and 100.

Analysis: H4 and H5 survive. H6 is **false as stated**: covariance can be negative
(`exists_dataset_empCov_neg`). What survives is the guarded version: monovariance of
ratings with humor implies nonnegative covariance, via Chebyshev's sum inequality.
The failure is instructive — it is exactly the empirical content of the programme,
and it is *not* derivable from the category theory.

Critique: the Hausdorff bound requires `hausdorffEDist ≠ ⊤` (otherwise the Hausdorff
distance is `0` by convention while the diameters differ arbitrarily) and boundedness
of the comparison set; both hypotheses are load-bearing, not cosmetic. The 100-joke
suite uses a synthetic monotone rating model, so it tests internal consistency of the
formalism rather than human data.

Synthesis: surprise is a diameter, it is 2-Lipschitz for the Hausdorff metric on
setups, and its correlation with funniness is exactly as strong as the monovariance of
the rating data — no stronger.
-/

open Finset Metric JokeSurpriseAlgebra

namespace JokeSurpriseStability

/-! ### Surprise is a diameter -/

/-- **Metric surprise**: the diameter of the set of readings of a setup, in an
arbitrary space of readings. -/
noncomputable def metricHumor {α : Type*} [PseudoMetricSpace α] (s : Set α) : ℝ :=
  Metric.diam s

/-- **The range model is the diameter model.** The catalog's `humor` of a nonempty
finite setup of real readings is exactly the metric diameter of that setup. -/
theorem humor_eq_diam (S : Finset ℝ) (h : S.Nonempty) :
    humor S h = metricHumor (S : Set ℝ) := by
  have hb : Bornology.IsBounded (S : Set ℝ) := S.finite_toSet.isBounded
  have hmin : S.min' h ∈ (S : Set ℝ) := S.min'_mem h
  have hmax : S.max' h ∈ (S : Set ℝ) := S.max'_mem h
  refine le_antisymm ?_ ?_
  · have hd := Metric.dist_le_diam_of_mem hb hmax hmin
    rwa [Real.dist_eq, abs_of_nonneg (by simpa [sub_nonneg] using S.min'_le_max' h)] at hd
  · refine Metric.diam_le_of_forall_dist_le
      (by simpa [humor, sub_nonneg] using S.min'_le_max' h) ?_
    intro x hx y hy
    have h1 : S.min' h ≤ x := S.min'_le _ hx
    have h2 : x ≤ S.max' h := S.le_max' _ hx
    have h3 : S.min' h ≤ y := S.min'_le _ hy
    have h4 : y ≤ S.max' h := S.le_max' _ hy
    rw [Real.dist_eq, abs_le]
    constructor <;> simp only [humor] <;> linarith

/-- **Monotonicity in an arbitrary space of readings.** -/
theorem metricHumor_mono {α : Type*} [PseudoMetricSpace α] {s t : Set α}
    (hst : s ⊆ t) (ht : Bornology.IsBounded t) : metricHumor s ≤ metricHumor t :=
  Metric.diam_mono hst ht

/-- **Subadditivity under shared context, in an arbitrary space of readings.** This is
the general-metric form of `JokeSurpriseAlgebra.humor_union_le_add_of_inter`. -/
theorem metricHumor_union_le_add_of_shared {α : Type*} [PseudoMetricSpace α]
    {s t : Set α} {x : α} (hxs : x ∈ s) (hxt : x ∈ t) :
    metricHumor (s ∪ t) ≤ metricHumor s + metricHumor t := by
  have h := Metric.diam_union hxs hxt
  simpa [metricHumor] using h

/-! ### Hausdorff stability -/

/-- **Surprise is 2-Lipschitz for the Hausdorff distance (one-sided form).** -/
theorem diam_le_diam_add_two_hausdorffDist {α : Type*} [PseudoMetricSpace α] {s t : Set α}
    (ht : Bornology.IsBounded t) (hne : hausdorffEDist s t ≠ ⊤) :
    metricHumor s ≤ metricHumor t + 2 * hausdorffDist s t := by
  have hH : 0 ≤ hausdorffDist s t := hausdorffDist_nonneg
  have hD : 0 ≤ metricHumor t := Metric.diam_nonneg
  refine Metric.diam_le_of_forall_dist_le (by linarith) ?_
  intro x hx y hy
  have key : ∀ ε > 0, dist x y ≤ metricHumor t + 2 * hausdorffDist s t + 2 * ε := by
    intro ε hε
    obtain ⟨x', hx', hxx'⟩ := exists_dist_lt_of_hausdorffDist_lt hx
      (by linarith : hausdorffDist s t < hausdorffDist s t + ε) hne
    obtain ⟨y', hy', hyy'⟩ := exists_dist_lt_of_hausdorffDist_lt hy
      (by linarith : hausdorffDist s t < hausdorffDist s t + ε) hne
    have h3 : dist x' y' ≤ metricHumor t := dist_le_diam_of_mem ht hx' hy'
    have h4 := dist_triangle4 x x' y' y
    rw [dist_comm y' y] at h4
    linarith
  by_contra hcon
  push_neg at hcon
  have h2 := key ((dist x y - (metricHumor t + 2 * hausdorffDist s t))/4) (by linarith)
  linarith

/-- **Surprise is 2-Lipschitz for the Hausdorff distance.** Setups that are close as
configurations of readings have close humor: humor is an experimentally robust
quantity. -/
theorem abs_diam_sub_diam_le_two_hausdorffDist {α : Type*} [PseudoMetricSpace α]
    {s t : Set α} (hs : Bornology.IsBounded s) (ht : Bornology.IsBounded t)
    (hne : hausdorffEDist s t ≠ ⊤) :
    |metricHumor s - metricHumor t| ≤ 2 * hausdorffDist s t := by
  have h1 := diam_le_diam_add_two_hausdorffDist (s := s) (t := t) ht hne
  have h2 := diam_le_diam_add_two_hausdorffDist (s := t) (t := s) hs
    (by rwa [hausdorffEDist_comm] at hne)
  rw [hausdorffDist_comm] at h2
  rw [abs_le]
  constructor <;> linarith

/-! ### The paraphrase bound -/

/-- **Paraphrase stability.** If a paraphrase `f` moves every reading of a setup by at
most `ε`, then it changes the measured humor by at most `2ε`. -/
theorem abs_humor_image_sub_humor_le (S : Finset ℝ) (hS : S.Nonempty) (f : ℝ → ℝ)
    (ε : ℝ) (hf : ∀ x ∈ S, |f x - x| ≤ ε) :
    |humor (S.image f) (hS.image f) - humor S hS| ≤ 2 * ε := by
  set M := S.max' hS with hM
  set m := S.min' hS with hm
  have hMmem : M ∈ S := S.max'_mem hS
  have hmmem : m ∈ S := S.min'_mem hS
  have hfM := abs_le.1 (hf M hMmem)
  have hfm := abs_le.1 (hf m hmmem)
  have hmax_le : (S.image f).max' (hS.image f) ≤ M + ε := by
    refine Finset.max'_le _ _ _ ?_
    intro y hy
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hy
    have h1 := abs_le.1 (hf x hx)
    have h2 : x ≤ M := S.le_max' _ hx
    linarith [h1.2]
  have hmax_ge : M - ε ≤ (S.image f).max' (hS.image f) := by
    have : f M ≤ (S.image f).max' (hS.image f) :=
      Finset.le_max' _ _ (Finset.mem_image_of_mem f hMmem)
    linarith [hfM.1]
  have hmin_ge : m - ε ≤ (S.image f).min' (hS.image f) := by
    refine Finset.le_min' _ _ _ ?_
    intro y hy
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hy
    have h1 := abs_le.1 (hf x hx)
    have h2 : m ≤ x := S.min'_le _ hx
    linarith [h1.1]
  have hmin_le : (S.image f).min' (hS.image f) ≤ m + ε := by
    have : (S.image f).min' (hS.image f) ≤ f m :=
      Finset.min'_le _ _ (Finset.mem_image_of_mem f hmmem)
    linarith [hfm.2]
  rw [abs_le]
  constructor <;> simp only [humor, ← hM, ← hm] <;> linarith

/-- **The constant 2 in the paraphrase bound is sharp.** The paraphrase
`f x = 3 * x - 1` moves each reading of `{0, 1}` by exactly `1`, and changes the humor
by exactly `2`. -/
theorem paraphrase_bound_sharp :
    ∃ (S : Finset ℝ) (hS : S.Nonempty) (f : ℝ → ℝ) (ε : ℝ),
      (∀ x ∈ S, |f x - x| ≤ ε) ∧
      |humor (S.image f) (hS.image f) - humor S hS| = 2 * ε := by
  classical
  refine ⟨{0, 1}, ⟨0, by simp⟩, fun x => 3 * x - 1, 1, ?_, ?_⟩
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl <;> norm_num
  · have h1 : humor ({0, 1} : Finset ℝ) ⟨0, by simp⟩ = 1 := by
      unfold humor
      have hmax : ({0, 1} : Finset ℝ).max' ⟨0, by simp⟩ = 1 := by
        refine le_antisymm (Finset.max'_le _ _ _ ?_) (Finset.le_max' _ _ (by simp))
        intro y hy; simp at hy; rcases hy with rfl | rfl <;> norm_num
      have hmin : ({0, 1} : Finset ℝ).min' ⟨0, by simp⟩ = 0 := by
        refine le_antisymm (Finset.min'_le _ _ (by simp)) (Finset.le_min' _ _ _ ?_)
        intro y hy; simp at hy; rcases hy with rfl | rfl <;> norm_num
      rw [hmax, hmin]; norm_num
    have h2 : ∀ hne : (({0, 1} : Finset ℝ).image fun x => 3 * x - 1).Nonempty,
        humor (({0, 1} : Finset ℝ).image fun x => 3 * x - 1) hne = 3 := by
      intro hne
      unfold humor
      have hmem2 : (2 : ℝ) ∈ (({0, 1} : Finset ℝ).image fun x => 3 * x - 1) := by
        refine Finset.mem_image.2 ⟨1, by simp, by norm_num⟩
      have hmemm1 : (-1 : ℝ) ∈ (({0, 1} : Finset ℝ).image fun x => 3 * x - 1) := by
        refine Finset.mem_image.2 ⟨0, by simp, by norm_num⟩
      have hmax : (({0, 1} : Finset ℝ).image fun x => 3 * x - 1).max' hne = 2 := by
        refine le_antisymm (Finset.max'_le _ _ _ ?_) (Finset.le_max' _ _ hmem2)
        intro y hy
        obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hy
        simp at hx; rcases hx with rfl | rfl <;> norm_num
      have hmin : (({0, 1} : Finset ℝ).image fun x => 3 * x - 1).min' hne = -1 := by
        refine le_antisymm (Finset.min'_le _ _ hmemm1) (Finset.le_min' _ _ _ ?_)
        intro y hy
        obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hy
        simp at hx; rcases hx with rfl | rfl <;> norm_num
      rw [hmax, hmin]; norm_num
    rw [h1, h2]
    norm_num

/-! ### Correlation with funniness ratings -/

/-- The **empirical covariance** of two numerical attributes of a finite sample of
jokes. -/
noncomputable def empCov {ι : Type*} (s : Finset ι) (f g : ι → ℝ) : ℝ :=
  (∑ i ∈ s, f i * g i) / s.card - ((∑ i ∈ s, f i) / s.card) * ((∑ i ∈ s, g i) / s.card)

/-- **The correlation conjecture, in its correct guarded form.** If funniness ratings
monovary with humor across the sample, the empirical covariance of humor and rating is
nonnegative. The proof is Chebyshev's sum inequality. -/
theorem empCov_nonneg_of_monovaryOn {ι : Type*} (s : Finset ι) (f g : ι → ℝ)
    (h : MonovaryOn f g (s : Set ι)) : 0 ≤ empCov s f g := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [empCov]
  have hn : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.2 hs
  have hcheb := h.sum_mul_sum_le_card_mul_sum
  rw [empCov, sub_nonneg, div_mul_div_comm, div_le_div_iff₀ (by positivity) hn]
  nlinarith [hcheb, hn]

/-- **The monovariance hypothesis is necessary.** There is a two-joke dataset whose
humor and rating have strictly negative empirical covariance: high surprise does not
force high funniness. -/
theorem exists_dataset_empCov_neg :
    ∃ (H R : Fin 2 → ℝ), empCov (Finset.univ : Finset (Fin 2)) H R < 0 :=
  ⟨fun i => (i : ℝ), fun i => 1 - (i : ℝ), by simp [empCov, Fin.sum_univ_two]⟩

/-! ### The 100-joke test suite -/

/-- The setup of the `i`-th test joke: two readings, a literal one and one displaced by
`i`. -/
noncomputable def jokeSetup (i : ℕ) : Finset ℝ := {0, (i : ℝ)}

theorem jokeSetup_nonempty (i : ℕ) : (jokeSetup i).Nonempty := ⟨0, by simp [jokeSetup]⟩

/-- **The humor of the `i`-th test joke is `i`.** -/
theorem humor_jokeSetup (i : ℕ) : humor (jokeSetup i) (jokeSetup_nonempty i) = i := by
  unfold humor jokeSetup
  have hmax : ({0, (i:ℝ)} : Finset ℝ).max' ⟨0, by simp⟩ = (i : ℝ) := by
    refine le_antisymm (Finset.max'_le _ _ _ ?_) (Finset.le_max' _ _ (by simp))
    intro y hy; simp at hy
    rcases hy with rfl | rfl
    · positivity
    · exact le_refl _
  have hmin : ({0, (i:ℝ)} : Finset ℝ).min' ⟨0, by simp⟩ = 0 := by
    refine le_antisymm (Finset.min'_le _ _ (by simp)) (Finset.le_min' _ _ _ ?_)
    intro y hy; simp at hy
    rcases hy with rfl | rfl
    · exact le_refl _
    · positivity
  rw [hmax, hmin]; ring

/-- The humor profile of the 100-joke test suite. -/
noncomputable def testHumor (i : ℕ) : ℝ := humor (jokeSetup i) (jokeSetup_nonempty i)

/-- A saturating rating model: funniness grows with surprise but the rating scale has a
ceiling at `50`. -/
noncomputable def testRating (i : ℕ) : ℝ := min (i : ℝ) 50

theorem testHumor_monotone : Monotone testHumor := by
  intro i j hij
  simp only [testHumor, humor_jokeSetup]
  exact_mod_cast hij

theorem testRating_monotone : Monotone testRating := by
  intro i j hij
  simp only [testRating]
  exact min_le_min (by exact_mod_cast hij) (le_refl _)

/-- **The 100-joke test.** For the synthetic suite of 100 jokes with humors
`H(J i) = i` and the saturating rating model, the empirical covariance of humor and
funniness is nonnegative. -/
theorem hundredJokes_empCov_nonneg :
    0 ≤ empCov (Finset.range 100) testHumor testRating :=
  empCov_nonneg_of_monovaryOn _ _ _
    ((testHumor_monotone.monovary testRating_monotone).monovaryOn _)

/-- A concrete three-joke sample — a pun (`H = 1`, rating `2`), a piece of wordplay
(`H = 3`, rating `5`) and an absurdist joke (`H = 10`, rating `8`) — has strictly
positive humor/funniness covariance. -/
theorem sampleJokes_empCov_pos :
    0 < empCov (Finset.univ : Finset (Fin 3)) ![1, 3, 10] ![2, 5, 8] := by
  simp [empCov, Fin.sum_univ_three]
  norm_num

end JokeSurpriseStability