import Novelty.NET58DeficitDispersion

/-!
# D3: the nonlinear probe ceiling on the pooled window population

The D3 conjecture of the NET-58 thread reads: *for the pooled train/test window population of a
fixed model the ANOVA ceiling `1 - SS_within/SS_tot` lies below `0.5`, hence no content head,
however deep, exceeds `R² = 0.5`, and the measured linear `0.329` already captures more than two
thirds of what any content function can achieve.*

`Novelty.NET58RelationalImportance` supplies the ceiling itself (`Rsq_le_intrinsic_ceiling`,
`intrinsic_ceiling_attained`, `ssWithin_eq_zero_of_injective`).  This file turns the conjecture
into mathematics.  Its verdict, in one line:

> the `0.5` claim is **not a theorem** — the ceiling can be any number in `[0,1)` — but it *is* a
> **measurement**, and the measurement is certified by an inequality between observables that
> mentions no predictor at all; the "two thirds" clause of the conjecture is **false at its own
> boundary**.

## 1.  The ceiling as an object

`anovaCeiling key a = 1 - SS_within/SS_tot`, together with `ssWithin_le_sstot`,
`anovaCeiling_nonneg`, `anovaCeiling_le_one`, and — the reason the object deserves a name —
`anovaCeiling_isGreatest`: it is the *greatest* element of the set of `R²` values realised by
content functions, not merely an upper bound.  `anovaCeiling_lt_half_iff` restates D3 as
`SS_tot < 2·SS_within`.

## 2.  Measuring the ceiling without a predictor

`fiber_dispersion_ge` shows that two windows sharing a key content force a within-fiber
dispersion of at least half their squared importance gap.  Summing one such pair per content
gives `ssWithin_ge_half_sum_pairs`, and hence the operational theorem
`content_Rsq_lt_half_of_pair_certificate`: *if the observed repeated-content gaps already
outweigh the total dispersion, then every content function — linear, deep, or tabulated — has
`R² < 1/2`.*  Every quantity in the hypothesis is read off the data.

## 3.  Depth cannot help

`ssWithin_mono_of_factors` / `anovaCeiling_mono_of_factors`: post-processing the content by any
map `g` can only raise `SS_within`.  A deeper head that reads a *coarser* feature of the key is
strictly worse off; the ceiling of the raw content map dominates the entire tower.

## 4.  The pooled window population

`pooled_ssWithin_eq_dispersion` identifies the ANOVA `SS_within` of the pooled population
`(content, window)` with the context dispersion `∑ᵢ ∑_w (a w i - ā i)²` of
`Novelty.NET58DeficitDispersion`.  From this, `deficit_small_of_ceiling_ge_half` runs the
roadmap's own dichotomy in reverse: **if D3 fails** (`ceiling ≥ 1/2`), then the relational
deficit is at most `√(B·SS_tot/(2|W|))`, i.e. the D1 ceiling is *not* free to become the binding
constraint — the two arms trade off against each other.

## 5.  The ceiling is not bounded a priori

`quadKey`/`quadImp` is a four-observation pooled population — two key contents, each seen in two
windows — with a content-informative amplitude `c` and a context-swap amplitude `d`; its ceiling
is exactly `c²/(c²+d²)` (`quad_ceiling`).  Hence `exists_pooled_population_with_ceiling`: every
value in `[0,1)` is realised, `ceiling_can_exceed_half` exhibits `0.9`, and `swap_ceiling_zero`
recovers the pure-swap regime where content explains nothing.  No structural argument can prove
D3; only a measurement can settle it, which is exactly the point of §2.

## 6.  The measured numbers

`measured_Rsq_le_ceiling` records that the observed linear `0.329` is a lower bound for the
ceiling.  `two_thirds_clause_false_at_half` refutes the conjecture's corollary: at the extreme
allowed ceiling `0.5` the linear probe captures `0.658`, which is *below* `2/3`.
`two_thirds_threshold` gives the exact repair — the two-thirds claim holds iff the ceiling is
below `0.4935` — and `measured_capture_gt_65` is the salvaged statement.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if `SS_within` is measurable from repeated contents alone, then the
`0.5` question is decidable from data; and if the ceiling is a free parameter of the population,
no amount of theory can decide it, so the useful theorem is a *certificate*, not a bound.

Experiment (Experimenter): `ComputationalEvidence.md` tabulates `c²/(c²+d²)` for six amplitude
pairs (`(1,0) ↦ 1`, `(2,1) ↦ 0.8`, `(1,1) ↦ 0.5`, `(1,2) ↦ 0.2`, `(0.7,1) ↦ 0.32886`,
`(0,1) ↦ 0`) — note that the measured `0.329` is itself realised as a *full* ceiling at
`c/d = 0.7` — and `0.329/c` for `c ∈ {0.35,…,0.6}`, locating the two-thirds crossing at
`c = 0.4935`.

Analysis (Analyst): the conjecture splits cleanly.  "No content head exceeds `R² = 1/2`" is
*true but conditional* — it follows from a measurable certificate, and the certificate is what
should be reported.  "The ceiling is below `0.5`" is *not a theorem*: `quad_ceiling` realises
every value.  "The measured `0.329` captures more than two thirds" is *false* in the worst
allowed case (`0.658 < 0.6667`).

Critique (Critic): the certificate of §2 is one-sided; `NonlinearProbeCeilingDesign` exhibits a
population with ceiling `0` on which every single-pair certificate fails, so soundness must not
be mistaken for completeness.  `ssWithin_eq_zero_of_injective` (upstream) remains the honest
caveat at the other end: with no repeated contents the ceiling is `1` and says nothing.
-/

namespace Catalog.Bridges.NonlinearProbeCeilingD3

open Finset Catalog.Novelty.ProbeRetentionLimits Catalog.Novelty.NET58RelationalImportance
  Catalog.Novelty.NET58DeficitDispersion

/-! ### 1. The ANOVA ceiling as an object -/

section Ceiling

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- The ANOVA ceiling `1 - SS_within / SS_tot` of a content map. -/
noncomputable def anovaCeiling (key : ι → κ) (a : ι → ℝ) : ℝ :=
  1 - ssWithin key a / sstot a

theorem ssWithin_le_sstot (key : ι → κ) (a : ι → ℝ) : ssWithin key a ≤ sstot a := by
  have h := ssWithin_le_sse key a (fun _ => mean a)
  simpa [sse, sstot] using h

theorem anovaCeiling_nonneg (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    0 ≤ anovaCeiling key a := by
  have h1 : ssWithin key a / sstot a ≤ 1 :=
    (div_le_one h).mpr (ssWithin_le_sstot key a)
  simp only [anovaCeiling]; linarith

theorem anovaCeiling_le_one (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling key a ≤ 1 := by
  have := ssWithin_nonneg key a
  have : 0 ≤ ssWithin key a / sstot a := by positivity
  simp only [anovaCeiling]; linarith

/-- The ceiling is the exact maximum of `R²` over all content functions. -/
theorem anovaCeiling_isGreatest (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    IsGreatest {r : ℝ | ∃ f : κ → ℝ, r = Rsq a (fun i => f (key i))} (anovaCeiling key a) := by
  constructor
  · exact ⟨condMean key a, (intrinsic_ceiling_attained key a).symm⟩
  · rintro r ⟨f, rfl⟩
    exact Rsq_le_intrinsic_ceiling key a f h

theorem anovaCeiling_lt_half_iff (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling key a < 1 / 2 ↔ sstot a < 2 * ssWithin key a := by
  simp only [anovaCeiling]
  constructor
  · intro hh
    have hd : 1 / 2 < ssWithin key a / sstot a := by linarith
    rw [lt_div_iff₀ h] at hd
    linarith
  · intro hh
    have hd : 1 / 2 < ssWithin key a / sstot a := by rw [lt_div_iff₀ h]; linarith
    linarith

end Ceiling

/-! ### 2. Measuring `SS_within` from repeated contents -/

section Measure

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

omit [Fintype κ] in
/-- Two keys with the same content already force a within-fiber dispersion of half their
squared gap. -/
theorem fiber_dispersion_ge (key : ι → κ) (a : ι → ℝ) {y : κ} {i j : ι}
    (hi : key i = y) (hj : key j = y) (hij : i ≠ j) :
    (a i - a j) ^ 2 / 2 ≤ ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 := by
  classical
  have hsub : ({i, j} : Finset ι) ⊆ fiber key y := by
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl <;> simp [fiber, hi, hj]
  have hle : ∑ k ∈ ({i, j} : Finset ι), (a k - condMean key a y) ^ 2
      ≤ ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun _ _ _ => sq_nonneg _)
  rw [Finset.sum_pair hij] at hle
  nlinarith [sq_nonneg (a i + a j - 2 * condMean key a y)]

/-- **One repeated content is a certificate.**  No model of the predictor is needed. -/
theorem ssWithin_ge_half_sq_diff (key : ι → κ) (a : ι → ℝ) {i j : ι}
    (hkey : key i = key j) (hij : i ≠ j) :
    (a i - a j) ^ 2 / 2 ≤ ssWithin key a := by
  have hterm := fiber_dispersion_ge key a (y := key i) rfl hkey.symm hij
  have hsingle : (∑ k ∈ fiber key (key i), (a k - condMean key a (key i)) ^ 2)
      ≤ ssWithin key a :=
    Finset.single_le_sum (f := fun y => ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2)
      (fun y _ => Finset.sum_nonneg fun _ _ => sq_nonneg _) (Finset.mem_univ (key i))
  linarith

/-- **The measurement theorem.**  A family of repeated-content pairs, one per content value,
lower-bounds `SS_within` by half the sum of the squared gaps.  Every ingredient is observable:
the contents, and the importances of the two windows that share them. -/
theorem ssWithin_ge_half_sum_pairs (key : ι → κ) (a : ι → ℝ) (Y : Finset κ) (p q : κ → ι)
    (hp : ∀ y ∈ Y, key (p y) = y) (hq : ∀ y ∈ Y, key (q y) = y)
    (hne : ∀ y ∈ Y, p y ≠ q y) :
    (∑ y ∈ Y, (a (p y) - a (q y)) ^ 2) / 2 ≤ ssWithin key a := by
  have hstep : ∀ y ∈ Y, (a (p y) - a (q y)) ^ 2 / 2
      ≤ ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 :=
    fun y hy => fiber_dispersion_ge key a (hp y hy) (hq y hy) (hne y hy)
  have h1 : (∑ y ∈ Y, (a (p y) - a (q y)) ^ 2 / 2)
      ≤ ∑ y ∈ Y, ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 :=
    Finset.sum_le_sum hstep
  have h2 : (∑ y ∈ Y, ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2) ≤ ssWithin key a :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ Y)
      (fun y _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _)
  rw [Finset.sum_div]
  linarith

/-- **The nonlinear ceiling, measured.**  If the observed repeated-content gaps already exceed
the total dispersion, then *no* content function — of any depth — reaches `R² = 1/2`. -/
theorem content_Rsq_lt_half_of_pair_certificate (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a)
    (Y : Finset κ) (p q : κ → ι)
    (hp : ∀ y ∈ Y, key (p y) = y) (hq : ∀ y ∈ Y, key (q y) = y)
    (hne : ∀ y ∈ Y, p y ≠ q y)
    (hcert : sstot a < ∑ y ∈ Y, (a (p y) - a (q y)) ^ 2) :
    anovaCeiling key a < 1 / 2 ∧ ∀ f : κ → ℝ, Rsq a (fun i => f (key i)) < 1 / 2 := by
  have hw := ssWithin_ge_half_sum_pairs key a Y p q hp hq hne
  have hlt : anovaCeiling key a < 1 / 2 := by
    rw [anovaCeiling_lt_half_iff key a h]
    linarith
  refine ⟨hlt, fun f => ?_⟩
  exact lt_of_le_of_lt (Rsq_le_intrinsic_ceiling key a f h) hlt

end Measure

/-! ### 3. Depth cannot help: monotonicity under refinement of the content map -/

section Depth

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]
  {κ' : Type*} [Fintype κ'] [DecidableEq κ']

/-- Post-processing the content by any map `g` (a deeper head reading a coarser feature) can
only increase the unexplainable dispersion. -/
theorem ssWithin_mono_of_factors (key : ι → κ) (g : κ → κ') (a : ι → ℝ) :
    ssWithin key a ≤ ssWithin (fun i => g (key i)) a := by
  have h := ssWithin_le_sse key a (fun y => condMean (fun i => g (key i)) a (g y))
  have h2 : sse a (fun i => condMean (fun i' => g (key i')) a (g (key i)))
      = ssWithin (fun i => g (key i)) a := sse_condMean (fun i => g (key i)) a
  linarith [h, h2.le, h2.ge]

/-- Hence the ceiling of a coarser content map is below the ceiling of the raw content. -/
theorem anovaCeiling_mono_of_factors (key : ι → κ) (g : κ → κ') (a : ι → ℝ) (h : 0 < sstot a) :
    anovaCeiling (fun i => g (key i)) a ≤ anovaCeiling key a := by
  have hm := ssWithin_mono_of_factors key g a
  have : ssWithin key a / sstot a ≤ ssWithin (fun i => g (key i)) a / sstot a :=
    (div_le_div_iff_of_pos_right h).mpr hm
  simp only [anovaCeiling]; linarith

end Depth

/-! ### 4. The pooled window population -/

section Pooled

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {W : Type*} [Fintype W]

/-- The pooled population: one observation per (key content, window) pair. -/
def pooledImp (a : W → ι → ℝ) : ι × W → ℝ := fun p => a p.2 p.1

lemma fiber_fst (i : ι) :
    fiber (Prod.fst : ι × W → ι) i = ({i} : Finset ι) ×ˢ (Finset.univ : Finset W) := by
  ext p
  simp only [fiber, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_product,
    Finset.mem_singleton]
  exact ⟨fun h => ⟨h, trivial⟩, fun h => h.1⟩

lemma condMean_fst (a : W → ι → ℝ) (i : ι) :
    condMean (Prod.fst : ι × W → ι) (pooledImp a) i = avgImportance a i := by
  simp [condMean, fiber_fst, avgImportance, pooledImp, Finset.card_univ]

/-- **Identification.**  On the pooled window population the ANOVA `SS_within` *is* the
context dispersion of `NET58DeficitDispersion`. -/
theorem pooled_ssWithin_eq_dispersion (a : W → ι → ℝ) :
    ssWithin (Prod.fst : ι × W → ι) (pooledImp a)
      = ∑ i, ∑ w, (a w i - avgImportance a i) ^ 2 := by
  simp [ssWithin, fiber_fst, condMean_fst, pooledImp]

/-- **The trade-off, against the roadmap.**  If the nonlinear ceiling is *not* below `1/2`
(the D3 conjecture fails on the measured population), then the relational deficit — the D1
ceiling — is automatically small: at most `√(B · SS_tot / (2|W|))`.  The two arms cannot both
be binding. -/
theorem deficit_small_of_ceiling_ge_half [Nonempty W] (a : W → ι → ℝ) {B : ℕ} {T : Finset ι}
    (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w))
    (hpos : 0 < sstot (pooledImp a))
    (hc : 1 / 2 ≤ anovaCeiling (Prod.fst : ι × W → ι) (pooledImp a)) :
    relationalDeficit a O T
      ≤ Real.sqrt ((B : ℝ) * sstot (pooledImp a) / (2 * Fintype.card W)) := by
  have hW : (0 : ℝ) < Fintype.card W := by
    exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty W›
  have hdisp : ∑ w, sse (a w) (avgImportance a) = ssWithin (Prod.fst : ι × W → ι) (pooledImp a) := by
    rw [pooled_dispersion_eq, pooled_ssWithin_eq_dispersion]
  have hhalf : ssWithin (Prod.fst : ι × W → ι) (pooledImp a) ≤ sstot (pooledImp a) / 2 := by
    rw [anovaCeiling] at hc
    have : ssWithin (Prod.fst : ι × W → ι) (pooledImp a) / sstot (pooledImp a) ≤ 1 / 2 := by
      linarith
    rw [div_le_div_iff₀ hpos (by norm_num : (0:ℝ) < 2)] at this
    linarith
  have hmain := deficit_le_sqrt_dispersion a hT hO
  refine hmain.trans (Real.sqrt_le_sqrt ?_)
  rw [hdisp]
  calc (B : ℝ) * (ssWithin (Prod.fst : ι × W → ι) (pooledImp a) / Fintype.card W)
      ≤ (B : ℝ) * ((sstot (pooledImp a) / 2) / Fintype.card W) := by gcongr
    _ = (B : ℝ) * sstot (pooledImp a) / (2 * Fintype.card W) := by ring

end Pooled

/-! ### 5. The ceiling is not bounded a priori: a tunable family -/

section Tunable

/-- Four pooled observations, two key contents, each seen in two windows. -/
def quadKey : Fin 4 → Fin 2 := ![0, 0, 1, 1]

/-- A content-informative part `c` and a context-swap part `d`. -/
noncomputable def quadImp (c d : ℝ) : Fin 4 → ℝ := ![c + d, c - d, -c - d, -c + d]

lemma quad_sstot (c d : ℝ) : sstot (quadImp c d) = 4 * c ^ 2 + 4 * d ^ 2 := by
  simp [sstot, mean, quadImp, Fin.sum_univ_four]
  ring

lemma quad_fiber0 : fiber quadKey 0 = {0, 1} := by decide
lemma quad_fiber1 : fiber quadKey 1 = {2, 3} := by decide

lemma quad_ssWithin (c d : ℝ) : ssWithin quadKey (quadImp c d) = 4 * d ^ 2 := by
  simp [ssWithin, Fin.sum_univ_two, quad_fiber0, quad_fiber1, condMean, quadImp]
  ring

theorem quad_ceiling (c d : ℝ) (h : 0 < c ^ 2 + d ^ 2) :
    anovaCeiling quadKey (quadImp c d) = c ^ 2 / (c ^ 2 + d ^ 2) := by
  rw [anovaCeiling, quad_ssWithin, quad_sstot]
  field_simp
  ring

/-- **Every ceiling in `[0,1)` occurs.**  The D3 conjecture is therefore not a theorem about
pooled populations: it is a measurement, and the certificate of §2 is what makes it one. -/
theorem exists_pooled_population_with_ceiling (ρ : ℝ) (h0 : 0 ≤ ρ) (h1 : ρ < 1) :
    ∃ a : Fin 4 → ℝ, 0 < sstot a ∧ anovaCeiling quadKey a = ρ := by
  refine ⟨quadImp (Real.sqrt ρ) (Real.sqrt (1 - ρ)), ?_, ?_⟩
  · rw [quad_sstot, Real.sq_sqrt h0, Real.sq_sqrt (by linarith : (0:ℝ) ≤ 1 - ρ)]
    linarith
  · rw [quad_ceiling _ _ (by
      rw [Real.sq_sqrt h0, Real.sq_sqrt (by linarith : (0:ℝ) ≤ 1 - ρ)]; linarith),
      Real.sq_sqrt h0, Real.sq_sqrt (by linarith : (0:ℝ) ≤ 1 - ρ)]
    norm_num

/-- Concretely: a pooled population with repeated contents whose nonlinear ceiling is `0.9`. -/
theorem ceiling_can_exceed_half :
    ∃ a : Fin 4 → ℝ, 0 < sstot a ∧ 1 / 2 < anovaCeiling quadKey a := by
  obtain ⟨a, hpos, hc⟩ := exists_pooled_population_with_ceiling (9/10) (by norm_num) (by norm_num)
  exact ⟨a, hpos, by rw [hc]; norm_num⟩

/-- The exact-swap population (`c = 0`): content explains nothing at all. -/
theorem swap_ceiling_zero (d : ℝ) (hd : d ≠ 0) :
    anovaCeiling quadKey (quadImp 0 d) = 0 := by
  rw [quad_ceiling 0 d (by positivity)]
  simp

end Tunable

/-! ### 6. The measured numbers -/

section Measured

/-- The measured linear `R² = 0.329` is a lower bound for the ceiling. -/
theorem measured_Rsq_le_ceiling {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]
    (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a) (f : κ → ℝ)
    (hmeas : Rsq a (fun i => f (key i)) = 0.329) :
    0.329 ≤ anovaCeiling key a := by
  rw [← hmeas]
  exact Rsq_le_intrinsic_ceiling key a f h

/-- **Critic's refutation of the corollary.**  Even at the extreme ceiling `0.5` the measured
`0.329` captures `65.8 %`, which is *less* than two thirds: the "more than two thirds" clause of
the conjecture is false at its own boundary. -/
theorem two_thirds_clause_false_at_half : (0.329 : ℝ) / (1 / 2) < 2 / 3 := by norm_num

/-- The exact threshold: the measured linear probe captures more than two thirds of the ceiling
precisely when the ceiling is below `0.4935`. -/
theorem two_thirds_threshold (c : ℝ) (hc : 0 < c) :
    2 / 3 < (0.329 : ℝ) / c ↔ c < 0.4935 := by
  rw [lt_div_iff₀ hc]
  constructor <;> intro h <;> linarith

/-- The salvaged corollary: below the ceiling `0.5` the measured probe captures more than
`65 %` of everything a content function can achieve. -/
theorem measured_capture_gt_65 (c : ℝ) (hc : 0 < c) (hle : c ≤ 1 / 2) :
    0.65 < (0.329 : ℝ) / c := by
  rw [lt_div_iff₀ hc]
  nlinarith

end Measured

end Catalog.Bridges.NonlinearProbeCeilingD3