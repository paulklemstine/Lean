import Mathlib

/-!
# The Aleph-One Surface II: a metric surface of transfinite Hausdorff dimension

This file is the metric-geometric continuation of `Novelty/AlephOneSurface.lean`.
That file worked purely topologically inside the product Hilbert cube
`ℕ → [0,1]`; the price was that the phrase *"Hausdorff dimension"* never occurred,
because the product cube carries no canonical metric.

Here we build an honest **metric** object and prove metric theorems about it.

## The construction

Work inside the separable Hilbert space `ℓ² = lp (fun _ : ℕ => ℝ) 2`.  For every
`n` let

* `finBox n = ∏_{i<n} [0, 2^{-i}] ⊆ ℝⁿ` (sup-normed `Fin n → ℝ`),
* `slab n : ℝⁿ → ℓ²` extension of a vector by zeros,
* `cell n = slab n '' finBox n ⊆ ℓ²`, a flat `n`-dimensional box, and
* `alephSurface = ⋃ n, cell n`.

The surface sits inside the **`ℓ²`-Hilbert box** `hilbertBox = {x | ∀ i, x i ∈ [0,2^{-i}]}`.

## Main results

* `AlephOneHausdorff.dimH_cell` — `dimH (cell n) = n`: the surface realises
  *every* finite Hausdorff dimension.
* `AlephOneHausdorff.dimH_alephSurface` — `dimH alephSurface = ⊤`: the surface has
  transfinite Hausdorff dimension.
* `AlephOneHausdorff.TransfiniteDimensional` — the abstract notion, together with
  the two structural obstructions proved for it:
  * `TransfiniteDimensional.not_antilipschitz_to_finiteDim` — such a set admits no
    bi-Lipschitz (indeed no antilipschitz) map into a finite-dimensional normed
    space; in particular the surface embeds in no `ℝᵐ`;
  * `TransfiniteDimensional.no_lipschitzTriangulation` — such a set admits no
    finite (indeed no countable) triangulation by Lipschitz `d`-cells, for any `d`;
  * `TransfiniteDimensional.no_contDiff_atlas` — and no countable `C¹` atlas
    modelled on a finite-dimensional space.
* `AlephOneHausdorff.card_alephSurface` — the surface has exactly `𝔠` points, hence
  exactly `ℵ₁` points under the Continuum Hypothesis
  (`AlephOneHausdorff.card_alephSurface_of_CH`).
* `AlephOneHausdorff.cell_isEmbedding_hilbertCube` — every cell embeds
  topologically into the product Hilbert cube `ℕ → [0,1]`, and
  `AlephOneHausdorff.alephSurface_continuous_injection_hilbertCube` — the whole
  surface injects continuously into it.
* `AlephOneHausdorff.isCompact_hilbertBox` and
  `AlephOneHausdorff.hilbertBoxHomeoCube` — the `ℓ²`-Hilbert box is compact and
  *homeomorphic* to the product Hilbert cube; consequently
  `AlephOneHausdorff.alephSurface_isEmbedding_hilbertCube` — the surface embeds
  topologically in the Hilbert cube.

* `AlephOneHausdorff.closure_alephSurface` — the closure of the surface is exactly
  the Hilbert box: the σ-finite-dimensional skeleton is dense in the cube, is
  σ-compact, but is itself neither closed nor compact
  (`AlephOneHausdorff.alephSurface_not_isCompact`).
* `AlephOneHausdorff.dimH_surfaceOf`, `AlephOneHausdorff.triangulable_surfaceOf_iff`
  — the arithmetic dimension spectrum: restricting the cell dimensions to `S ⊆ ℕ`
  makes triangulability equivalent to finiteness of `S`, whence
  `AlephOneHausdorff.primeSurface_transfiniteDimensional` (Euclid) and
  `AlephOneHausdorff.twinPrimeSurface_transfiniteDimensional_iff` (twin primes).
* `AlephOneHausdorff.TransfiniteManifold` — transfinite-dimensional manifolds,
  with `AlephOneHausdorff.TransfiniteManifold.no_triangulation` and the witness
  `AlephOneHausdorff.hilbertBoxManifold`.

The moral: *"Hausdorff dimension `ℵ₁`" is a category error* — `dimH` takes values
in `ℝ≥0∞` — but the intended object exists: a surface with `ℵ₁` points (under CH)
whose Hausdorff dimension is the top element `⊤`, which lives in the Hilbert cube
and in no finite-dimensional Euclidean space.
-/

open Set Cardinal Topology
open scoped NNReal ENNReal

namespace AlephOneHausdorff

/-! ## The ambient Hilbert space and the coordinate maps -/

/-- The separable Hilbert space `ℓ²(ℕ)`. -/
abbrev Elltwo : Type := lp (fun _ : ℕ => ℝ) 2

/-- Side length of the `i`-th edge of the ambient Hilbert box. -/
noncomputable def boxSide (i : ℕ) : ℝ := (1 / 2) ^ i

theorem boxSide_pos (i : ℕ) : 0 < boxSide i := by
  unfold boxSide; positivity

theorem boxSide_le_one (i : ℕ) : boxSide i ≤ 1 := by
  simpa [boxSide] using pow_le_one₀ (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (1:ℝ)/2 ≤ 1)

/-- Extension by zero of a finite vector to a point of `ℓ²`. -/
noncomputable def slab (n : ℕ) (y : Fin n → ℝ) : Elltwo :=
  ⟨fun i => if h : i < n then y ⟨i, h⟩ else 0, by
    apply memℓp_gen
    apply summable_of_ne_finset_zero (s := Finset.range n)
    intro b hb
    simp only [Finset.mem_range, not_lt] at hb
    simp [Nat.not_lt.mpr hb]⟩

@[simp] theorem slab_apply (n : ℕ) (y : Fin n → ℝ) (i : ℕ) :
    (slab n y : ℕ → ℝ) i = if h : i < n then y ⟨i, h⟩ else 0 := rfl

/-- The first `n` coordinates of a point of `ℓ²`. -/
def coord (n : ℕ) (x : Elltwo) : Fin n → ℝ := fun i => x i

theorem coord_slab (n : ℕ) (y : Fin n → ℝ) : coord n (slab n y) = y := by
  funext i; simp [coord, i.2]

theorem slab_injective (n : ℕ) : Function.Injective (slab n) :=
  Function.LeftInverse.injective (coord_slab n)

/-- Reading off finitely many coordinates is `1`-Lipschitz from `ℓ²` to the
sup-normed space `Fin n → ℝ`. -/
theorem coord_lipschitz (n : ℕ) : LipschitzWith 1 (coord n) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  simp only [NNReal.coe_one, one_mul]
  rw [dist_pi_le_iff dist_nonneg]
  intro i
  rw [Real.dist_eq, dist_eq_norm]
  simp only [coord]
  have h : (x : ℕ → ℝ) i - (y : ℕ → ℝ) i = ((x - y : Elltwo) : ℕ → ℝ) i := by simp
  rw [h]
  simpa using lp.norm_apply_le_norm (by norm_num) (x - y) (i : ℕ)

theorem coord_continuous (n : ℕ) : Continuous (coord n) := (coord_lipschitz n).continuous

/-- Each coordinate functional on `ℓ²` is `1`-Lipschitz, hence continuous. -/
theorem elltwo_coord_lipschitz (i : ℕ) : LipschitzWith 1 fun x : Elltwo => (x : ℕ → ℝ) i := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  simp only [NNReal.coe_one, one_mul, dist_eq_norm]
  have h : (x : ℕ → ℝ) i - (y : ℕ → ℝ) i = ((x - y : Elltwo) : ℕ → ℝ) i := by simp
  rw [h]
  simpa using lp.norm_apply_le_norm (by norm_num) (x - y) i

theorem elltwo_coord_continuous (i : ℕ) : Continuous fun x : Elltwo => (x : ℕ → ℝ) i :=
  (elltwo_coord_lipschitz i).continuous

theorem slab_sub (n : ℕ) (y z : Fin n → ℝ) : slab n y - slab n z = slab n (y - z) := by
  apply Subtype.ext; funext i
  simp only [lp.coeFn_sub, Pi.sub_apply, slab_apply]
  by_cases h : i < n <;> simp [h]

/-- Extension by zero increases the norm by at most `√n` (sup norm on the source). -/
theorem norm_slab_le (n : ℕ) (y : Fin n → ℝ) : ‖slab n y‖ ≤ Real.sqrt n * ‖y‖ := by
  have hy : 0 ≤ ‖y‖ := norm_nonneg _
  apply lp.norm_le_of_forall_sum_le (by norm_num) (by positivity)
  intro s
  have hp : (2 : ENNReal).toReal = 2 := by norm_num
  rw [hp]
  have key : ∀ i ∈ s, ‖(slab n y : ℕ → ℝ) i‖ ^ (2:ℝ) ≤ (if i < n then ‖y‖ ^ 2 else 0) := by
    intro i _
    by_cases h : i < n
    · simp only [slab_apply, dif_pos h, if_pos h]
      rw [Real.rpow_two]
      have h1 : ‖y ⟨i, h⟩‖ ≤ ‖y‖ := norm_le_pi_norm y _
      have h0 : (0:ℝ) ≤ ‖y ⟨i, h⟩‖ := norm_nonneg _
      nlinarith
    · simp [h]
  calc ∑ i ∈ s, ‖(slab n y : ℕ → ℝ) i‖ ^ (2:ℝ)
      ≤ ∑ i ∈ s, (if i < n then ‖y‖ ^ 2 else 0) := Finset.sum_le_sum key
    _ ≤ ∑ _i ∈ Finset.range n, ‖y‖ ^ 2 := by
        rw [← Finset.sum_filter, Finset.sum_const, Finset.sum_const]
        have hcard : (s.filter (fun i => i < n)).card ≤ n := by
          have hsub : s.filter (fun i => i < n) ⊆ Finset.range n := by
            intro i hi; simp only [Finset.mem_filter, Finset.mem_range] at hi ⊢; exact hi.2
          simpa using Finset.card_le_card hsub
        simp only [Finset.card_range, nsmul_eq_mul]
        exact mul_le_mul_of_nonneg_right (by exact_mod_cast hcard) (by positivity)
    _ = n * ‖y‖ ^ 2 := by simp
    _ = (Real.sqrt n * ‖y‖) ^ (2:ℝ) := by
        rw [Real.rpow_two, mul_pow, Real.sq_sqrt (by positivity)]

theorem slab_lipschitz (n : ℕ) : LipschitzWith (NNReal.sqrt n) (slab n) := by
  apply LipschitzWith.of_dist_le_mul
  intro y z
  rw [dist_eq_norm, dist_eq_norm, slab_sub]
  simpa using norm_slab_le n (y - z)

theorem slab_continuous (n : ℕ) : Continuous (slab n) := (slab_lipschitz n).continuous

/-! ## The surface -/

/-- The `n`-dimensional coordinate box `∏_{i<n} [0, 2^{-i}]` in the sup-normed
space `Fin n → ℝ`. -/
noncomputable def finBox (n : ℕ) : Set (Fin n → ℝ) := univ.pi fun i : Fin n => Icc 0 (boxSide i)

theorem isCompact_finBox (n : ℕ) : IsCompact (finBox n) :=
  isCompact_univ_pi fun _ => isCompact_Icc

theorem finBox_nonempty (n : ℕ) : (finBox n).Nonempty :=
  ⟨fun _ => 0, fun i _ => ⟨le_rfl, (boxSide_pos i).le⟩⟩

/-- The box has nonempty interior, hence full Hausdorff dimension `n`. -/
theorem dimH_finBox (n : ℕ) : dimH (finBox n) = n := by
  have h : (interior (finBox n)).Nonempty := by
    rw [finBox, interior_pi_set Set.finite_univ]
    refine ⟨fun i => boxSide i / 2, fun i _ => ?_⟩
    simp only [interior_Icc, mem_Ioo]
    have := boxSide_pos i
    constructor <;> linarith
  rw [Real.dimH_of_nonempty_interior h]
  simp

/-- The `n`-th **cell** of the aleph-one surface: a flat `n`-dimensional box in `ℓ²`. -/
noncomputable def cell (n : ℕ) : Set Elltwo := slab n '' finBox n

/-- **The aleph-one surface**: the union of all its finite-dimensional cells. -/
noncomputable def alephSurface : Set Elltwo := ⋃ n, cell n

theorem cell_subset_alephSurface (n : ℕ) : cell n ⊆ alephSurface := subset_iUnion cell n

theorem isCompact_cell (n : ℕ) : IsCompact (cell n) :=
  (isCompact_finBox n).image (slab_continuous n)

theorem coord_image_cell (n : ℕ) : coord n '' cell n = finBox n := by
  rw [cell, ← image_comp]
  refine Set.image_congr' (fun y => ?_) |>.trans (image_id _)
  simp [Function.comp, coord_slab]

/-- **Each cell has Hausdorff dimension exactly `n`.**  The lower bound comes from
the `1`-Lipschitz coordinate projection, the upper bound from the `√n`-Lipschitz
extension-by-zero map. -/
theorem dimH_cell (n : ℕ) : dimH (cell n) = n := by
  refine le_antisymm ?_ ?_
  · calc dimH (cell n) = dimH (slab n '' finBox n) := rfl
      _ ≤ dimH (finBox n) := (slab_lipschitz n).dimH_image_le _
      _ = n := dimH_finBox n
  · calc (n : ℝ≥0∞) = dimH (finBox n) := (dimH_finBox n).symm
      _ = dimH (coord n '' cell n) := by rw [coord_image_cell]
      _ ≤ dimH (cell n) := (coord_lipschitz n).dimH_image_le _

/-- **The aleph-one surface has transfinite Hausdorff dimension.** -/
theorem dimH_alephSurface : dimH alephSurface = ⊤ := by
  rw [alephSurface, dimH_iUnion]
  simp only [dimH_cell]
  exact ENNReal.iSup_natCast

/-! ## Transfinite-dimensional sets: the abstract theory

We isolate the property that drives every obstruction below. -/

/-- Hausdorff dimension of a set equals that of the corresponding subtype. -/
theorem dimH_univ_subtype {X : Type*} [EMetricSpace X] (A : Set X) :
    dimH (univ : Set A) = dimH A := by
  have h := (isometry_subtype_coe (s := A)).dimH_image (univ : Set A)
  rw [Subtype.coe_image_univ] at h
  exact h.symm

/-- A subset of a metric space is **transfinite-dimensional** if its Hausdorff
dimension is the top element of `ℝ≥0∞`, i.e. it exceeds every real number. -/
def TransfiniteDimensional {X : Type*} [EMetricSpace X] (A : Set X) : Prop := dimH A = ⊤

theorem alephSurface_transfiniteDimensional : TransfiniteDimensional alephSurface :=
  dimH_alephSurface

/-- Transfinite dimensionality is inherited by supersets. -/
theorem TransfiniteDimensional.mono {X : Type*} [EMetricSpace X] {A B : Set X}
    (hA : TransfiniteDimensional A) (hAB : A ⊆ B) : TransfiniteDimensional B :=
  top_le_iff.1 (hA ▸ dimH_mono hAB)

/-- A transfinite-dimensional set is uncountable. -/
theorem TransfiniteDimensional.not_countable {X : Type*} [EMetricSpace X] {A : Set X}
    (hA : TransfiniteDimensional A) : ¬ A.Countable := by
  intro h
  rw [TransfiniteDimensional, dimH_countable h] at hA
  exact ENNReal.zero_ne_top hA

/-- **No bi-Lipschitz picture in finite dimensions.**  If `A` is
transfinite-dimensional then no map from `A` to a finite-dimensional normed space
is antilipschitz; in particular `A` has no bi-Lipschitz embedding into any `ℝᵐ`. -/
theorem TransfiniteDimensional.not_antilipschitz_to_finiteDim {X : Type*} [EMetricSpace X]
    {A : Set X} (hA : TransfiniteDimensional A)
    {F : Type*} [NormedAddCommGroup F] [NormedSpace ℝ F] [FiniteDimensional ℝ F]
    {K : ℝ≥0} {f : A → F} (hf : AntilipschitzWith K f) : False := by
  have h1 : dimH (univ : Set A) ≤ dimH (f '' univ) := hf.le_dimH_image _
  rw [dimH_univ_subtype, hA] at h1
  exact absurd (top_le_iff.1 h1) (Real.dimH_ne_top _)

/-- The surface does not embed bi-Lipschitzly into Euclidean space of any dimension. -/
theorem alephSurface_no_euclidean_embedding (m : ℕ) {K : ℝ≥0}
    (f : alephSurface → EuclideanSpace ℝ (Fin m)) (hf : AntilipschitzWith K f) : False :=
  alephSurface_transfiniteDimensional.not_antilipschitz_to_finiteDim hf

/-! ### Triangulations

A *Lipschitz `d`-triangulation* of a set `A` is a countable family of Lipschitz
maps from subsets of `ℝᵈ` whose images cover `A`.  This is far weaker than a
simplicial triangulation (cells may overlap, be curved, or be arbitrary Lipschitz
images), so the nonexistence theorem below is correspondingly strong. -/

/-- A countable covering of `A` by Lipschitz images of subsets of `ℝᵈ`. -/
structure LipschitzTriangulation {X : Type*} [EMetricSpace X] (A : Set X) (d : ℕ) where
  /-- Index type of the cells. -/
  ι : Type
  /-- The indexing type is countable (finite triangulations are the special case). -/
  countable : Countable ι
  /-- Parameter domain of each cell inside the model space `ℝᵈ`. -/
  domain : ι → Set (Fin d → ℝ)
  /-- The characteristic map of each cell. -/
  chart : ι → (Fin d → ℝ) → X
  /-- Lipschitz constants. -/
  const : ι → ℝ≥0
  /-- Each characteristic map is Lipschitz on its domain. -/
  lipschitz : ∀ j, LipschitzOnWith (const j) (chart j) (domain j)
  /-- The cells cover `A`. -/
  covers : A ⊆ ⋃ j, chart j '' domain j

/-- A set carrying a Lipschitz `d`-triangulation has Hausdorff dimension at most `d`. -/
theorem LipschitzTriangulation.dimH_le {X : Type*} [EMetricSpace X] {A : Set X} {d : ℕ}
    (T : LipschitzTriangulation A d) : dimH A ≤ d := by
  haveI := T.countable
  calc dimH A ≤ dimH (⋃ j, T.chart j '' T.domain j) := dimH_mono T.covers
    _ = ⨆ j, dimH (T.chart j '' T.domain j) := dimH_iUnion _
    _ ≤ d := by
        refine iSup_le fun j => ?_
        calc dimH (T.chart j '' T.domain j) ≤ dimH (T.domain j) := (T.lipschitz j).dimH_image_le
          _ ≤ dimH (univ : Set (Fin d → ℝ)) := dimH_mono (subset_univ _)
          _ = d := Real.dimH_univ_pi_fin d

/-- **A transfinite-dimensional set has no triangulation of any finite dimension**,
not even a countable one with curved Lipschitz cells. -/
theorem TransfiniteDimensional.no_lipschitzTriangulation {X : Type*} [EMetricSpace X]
    {A : Set X} (hA : TransfiniteDimensional A) (d : ℕ) :
    IsEmpty (LipschitzTriangulation A d) := by
  refine ⟨fun T => ?_⟩
  have := T.dimH_le
  rw [hA] at this
  exact absurd (top_le_iff.1 this) (by simp)

/-- **The aleph-one surface has no finite triangulation** — indeed no countable
Lipschitz triangulation — in any finite dimension `d`. -/
theorem alephSurface_no_triangulation (d : ℕ) :
    IsEmpty (LipschitzTriangulation alephSurface d) :=
  alephSurface_transfiniteDimensional.no_lipschitzTriangulation d

/-- **No countable `C¹` atlas either.**  If a transfinite-dimensional set is
covered by countably many `C¹` images of a finite-dimensional space, we get a
contradiction. -/
theorem TransfiniteDimensional.no_contDiff_atlas
    {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    {A : Set F} (hA : TransfiniteDimensional A)
    {ι : Type} [Countable ι] (φ : ι → E → F) (U : ι → Set E)
    (hU : ∀ j, Convex ℝ (U j)) (hφ : ∀ j, ContDiffOn ℝ 1 (φ j) (U j))
    (hcov : A ⊆ ⋃ j, φ j '' U j) : False := by
  have hle : dimH A ≤ (Module.finrank ℝ E : ℝ≥0∞) := by
    calc dimH A ≤ dimH (⋃ j, φ j '' U j) := dimH_mono hcov
      _ = ⨆ j, dimH (φ j '' U j) := dimH_iUnion _
      _ ≤ (Module.finrank ℝ E : ℝ≥0∞) := by
          refine iSup_le fun j => ?_
          calc dimH (φ j '' U j) ≤ dimH (U j) := (hφ j).dimH_image_le (hU j) subset_rfl
            _ ≤ dimH (univ : Set E) := dimH_mono (subset_univ _)
            _ = (Module.finrank ℝ E : ℝ≥0∞) := Real.dimH_univ_eq_finrank E
  rw [hA] at hle
  exact absurd (top_le_iff.1 hle) (by simp)

/-! ## Cardinality: the surface has `ℵ₁` points under CH -/

theorem card_elltwo_le : #Elltwo ≤ 𝔠 := by
  have h1 : #Elltwo ≤ #(ℕ → ℝ) := Cardinal.mk_le_of_injective (Subtype.val_injective)
  have h2 : #(ℕ → ℝ) = 𝔠 := by
    rw [Cardinal.mk_arrow, Cardinal.mk_real, Cardinal.mk_denumerable]
    simp [Cardinal.continuum_power_aleph0]
  exact h1.trans_eq h2

theorem continuum_le_card_cell_one : 𝔠 ≤ #(cell 1) := by
  have hsub : (fun t : ℝ => slab 1 (fun _ => t)) '' (Icc 0 1) ⊆ cell 1 := by
    rintro _ ⟨t, ht, rfl⟩
    refine ⟨fun _ => t, ?_, rfl⟩
    intro i _
    simpa [boxSide, Fin.fin_one_eq_zero i] using ht
  have hinj : Set.InjOn (fun t : ℝ => slab 1 (fun _ => t)) (Icc 0 1) := by
    intro a _ b _ hab
    have := congrArg (coord 1) hab
    simpa [coord_slab, funext_iff] using this
  calc 𝔠 = #(Icc (0:ℝ) 1) := (Cardinal.mk_Icc_real (by norm_num)).symm
    _ = #((fun t : ℝ => slab 1 (fun _ => t)) '' (Icc 0 1)) := (Cardinal.mk_image_eq_of_injOn _ _ hinj).symm
    _ ≤ #(cell 1) := Cardinal.mk_le_mk_of_subset hsub

/-- **The surface has exactly continuum many points.** -/
theorem card_alephSurface : #alephSurface = 𝔠 := by
  refine le_antisymm ?_ ?_
  · exact (Cardinal.mk_set_le _).trans card_elltwo_le
  · exact continuum_le_card_cell_one.trans
      (Cardinal.mk_le_mk_of_subset (cell_subset_alephSurface 1))

/-- **Under the Continuum Hypothesis the surface has exactly `ℵ₁` points.**
Together with `dimH_alephSurface` this is the precise, provable form of the slogan
"a surface of dimension `ℵ₁`": `ℵ₁` points, and Hausdorff dimension above every
real number. -/
theorem card_alephSurface_of_CH (hCH : (aleph 1 : Cardinal.{0}) = 𝔠) :
    #alephSurface = aleph 1 := by
  rw [card_alephSurface, hCH]

/-! ## The surface lives inside the Hilbert cube -/

/-- The `ℓ²`-Hilbert box `∏ᵢ [0, 2^{-i}]`. -/
def hilbertBox : Set Elltwo := {x | ∀ i, (x : ℕ → ℝ) i ∈ Icc 0 (boxSide i)}

theorem cell_subset_hilbertBox (n : ℕ) : cell n ⊆ hilbertBox := by
  rintro _ ⟨y, hy, rfl⟩ i
  by_cases h : i < n
  · simpa [h] using hy ⟨i, h⟩ (mem_univ _)
  · simp only [slab_apply, dif_neg h]
    exact ⟨le_rfl, (boxSide_pos i).le⟩

theorem alephSurface_subset_hilbertBox : alephSurface ⊆ hilbertBox := by
  rw [alephSurface, iUnion_subset_iff]
  exact cell_subset_hilbertBox

/-- The coordinate map from the Hilbert box into the product Hilbert cube. -/
noncomputable def toHilbertCube (x : Elltwo) : ℕ → unitInterval := fun i =>
  ⟨max 0 (min 1 ((x : ℕ → ℝ) i)), by
    constructor
    · exact le_max_left _ _
    · exact max_le zero_le_one (min_le_left _ _)⟩

theorem toHilbertCube_continuous : Continuous toHilbertCube := by
  apply continuous_pi
  intro i
  apply Continuous.subtype_mk
  exact continuous_const.max (continuous_const.min (elltwo_coord_continuous i))

theorem toHilbertCube_apply_of_mem {x : Elltwo} (hx : x ∈ hilbertBox) (i : ℕ) :
    ((toHilbertCube x i : ℝ)) = (x : ℕ → ℝ) i := by
  obtain ⟨h0, h1⟩ := hx i
  have : (x : ℕ → ℝ) i ≤ 1 := h1.trans (boxSide_le_one i)
  simp [toHilbertCube, min_eq_right this, max_eq_right h0]

theorem toHilbertCube_injOn : Set.InjOn toHilbertCube hilbertBox := by
  intro x hx y hy hxy
  apply Subtype.ext
  funext i
  have h := congrArg (fun f : ℕ → unitInterval => (f i : ℝ)) hxy
  simp only [toHilbertCube_apply_of_mem hx, toHilbertCube_apply_of_mem hy] at h
  exact h

/-- **Every cell of the surface embeds topologically into the Hilbert cube.**
(Compactness of the cell upgrades the continuous injection to an embedding.) -/
theorem cell_isEmbedding_hilbertCube (n : ℕ) :
    Topology.IsEmbedding (fun x : cell n => toHilbertCube (x : Elltwo)) := by
  haveI : CompactSpace (cell n) := isCompact_iff_compactSpace.1 (isCompact_cell n)
  refine (Continuous.isClosedEmbedding
    (toHilbertCube_continuous.comp continuous_subtype_val) ?_).isEmbedding
  intro a b hab
  exact Subtype.ext (toHilbertCube_injOn (cell_subset_hilbertBox n a.2)
    (cell_subset_hilbertBox n b.2) hab)

/-- The whole surface injects continuously into the Hilbert cube. -/
theorem alephSurface_continuous_injection_hilbertCube :
    Continuous (fun x : alephSurface => toHilbertCube (x : Elltwo)) ∧
      Function.Injective (fun x : alephSurface => toHilbertCube (x : Elltwo)) := by
  refine ⟨toHilbertCube_continuous.comp continuous_subtype_val, fun a b hab => ?_⟩
  exact Subtype.ext (toHilbertCube_injOn (alephSurface_subset_hilbertBox a.2)
    (alephSurface_subset_hilbertBox b.2) hab)

/-! ## The `ℓ²`-Hilbert box *is* the Hilbert cube

The results above show the surface injects continuously into `ℕ → [0,1]`.  We now
prove the sharp statement: the ambient `ℓ²`-box `hilbertBox` is **homeomorphic**
to the product Hilbert cube, hence compact, and therefore *every* subset of it —
the aleph-one surface in particular — embeds topologically into the Hilbert cube.

The analytic heart is that the tautological map from the product box to `ℓ²` is
continuous: it is the uniform limit of its coordinate truncations, with tail
error `√(2·2^{-N})`. -/

/-- The product box `∏ᵢ [0, 2^{-i}] ⊆ (ℕ → ℝ)` with the product topology. -/
noncomputable def boxSet : Set (ℕ → ℝ) := univ.pi fun i => Icc 0 (boxSide i)

theorem isCompact_boxSet : IsCompact boxSet := isCompact_univ_pi fun _ => isCompact_Icc

theorem boxSide_sq (i : ℕ) : boxSide i ^ 2 = ((1:ℝ) / 4) ^ i := by
  unfold boxSide
  rw [← pow_mul, mul_comm, pow_mul]
  norm_num

/-- Every point of the product box is square-summable. -/
theorem memlp_of_boxSet {y : ℕ → ℝ} (hy : y ∈ boxSet) : Memℓp y 2 := by
  apply memℓp_gen
  have hsum : Summable fun i : ℕ => ((1:ℝ) / 4) ^ i :=
    summable_geometric_of_lt_one (by norm_num) (by norm_num)
  apply hsum.of_nonneg_of_le (fun i => by positivity)
  intro i
  obtain ⟨h0, h1⟩ := hy i (mem_univ _)
  have h2 : ‖y i‖ = y i := by rw [Real.norm_eq_abs, abs_of_nonneg h0]
  have hp : ((2:ENNReal).toReal) = 2 := by norm_num
  rw [h2, hp, Real.rpow_two, ← boxSide_sq]
  nlinarith

/-- The tautological map from the product box into `ℓ²`. -/
noncomputable def boxToElltwo (y : boxSet) : Elltwo := ⟨y.1, memlp_of_boxSet y.2⟩

/-- Its `N`-th coordinate truncation, which manifestly depends on finitely many
coordinates and is therefore continuous. -/
noncomputable def boxTrunc (N : ℕ) (y : boxSet) : Elltwo := slab N fun i : Fin N => y.1 i

theorem boxTrunc_continuous (N : ℕ) : Continuous (boxTrunc N) :=
  (slab_continuous N).comp
    (continuous_pi fun i => (continuous_apply (i : ℕ)).comp continuous_subtype_val)

/-- **Uniform tail estimate.**  The truncations converge to the tautological map
uniformly on the whole box, with explicit error `√(2·2^{-N})`. -/
theorem boxTrunc_tail_estimate (N : ℕ) (y : boxSet) :
    ‖boxToElltwo y - boxTrunc N y‖ ≤ Real.sqrt (2 * (1 / 2) ^ N) := by
  set d : Elltwo := boxToElltwo y - boxTrunc N y with hd
  have hcoord : ∀ i, (d : ℕ → ℝ) i = if i < N then 0 else y.1 i := by
    intro i
    by_cases h : i < N <;> simp [hd, boxToElltwo, boxTrunc, h]
  have hp : ((2:ENNReal).toReal) = 2 := by norm_num
  apply lp.norm_le_of_tsum_le (by norm_num) (Real.sqrt_nonneg _)
  rw [hp]
  have hbound : ∀ i, ‖(d : ℕ → ℝ) i‖ ^ (2:ℝ) ≤ ((1:ℝ) / 2) ^ N * ((1:ℝ) / 2) ^ i := by
    intro i
    rw [Real.rpow_two]
    by_cases h : i < N
    · rw [hcoord i, if_pos h]
      simp only [norm_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow]
      positivity
    · rw [hcoord i, if_neg h]
      obtain ⟨h0, h1⟩ := y.2 i (mem_univ _)
      have hy2 : ‖y.1 i‖ ^ 2 ≤ boxSide i ^ 2 := by
        rw [Real.norm_eq_abs, abs_of_nonneg h0]; nlinarith
      have hgeo : ((1:ℝ) / 4) ^ i ≤ ((1:ℝ) / 2) ^ N * ((1:ℝ) / 2) ^ i := by
        rw [← pow_add]
        have h4 : ((1:ℝ) / 4) ^ i = ((1:ℝ) / 2) ^ (2 * i) := by
          rw [two_mul, pow_add, ← mul_pow]; norm_num
        rw [h4]
        exact pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
      calc ‖y.1 i‖ ^ 2 ≤ boxSide i ^ 2 := hy2
        _ = ((1:ℝ) / 4) ^ i := boxSide_sq i
        _ ≤ _ := hgeo
  have hsummable_lhs : Summable fun i => ‖(d : ℕ → ℝ) i‖ ^ (2:ℝ) := by
    have h := (lp.memℓp d).summable (p := 2) (by norm_num)
    simpa [hp] using h
  have hsummable_rhs : Summable fun i : ℕ => ((1:ℝ) / 2) ^ N * ((1:ℝ) / 2) ^ i :=
    (summable_geometric_of_lt_one (by norm_num) (by norm_num)).mul_left _
  calc ∑' i, ‖(d : ℕ → ℝ) i‖ ^ (2:ℝ) ≤ ∑' _i : ℕ, ((1:ℝ) / 2) ^ N * ((1:ℝ) / 2) ^ _i :=
        hsummable_lhs.tsum_le_tsum hbound hsummable_rhs
    _ = 2 * (1 / 2) ^ N := by
        rw [tsum_mul_left, tsum_geometric_of_lt_one (by norm_num) (by norm_num)]
        ring_nf
    _ = (Real.sqrt (2 * (1 / 2) ^ N)) ^ (2:ℝ) := by
        rw [Real.rpow_two, Real.sq_sqrt (by positivity)]

/-- **The product box maps continuously into `ℓ²`.**  Product convergence of
coordinates upgrades to norm convergence because the tails are uniformly small. -/
theorem boxToElltwo_continuous : Continuous boxToElltwo := by
  have huniform : TendstoUniformly (fun N => boxTrunc N) boxToElltwo Filter.atTop := by
    rw [Metric.tendstoUniformly_iff]
    intro ε hε
    have h0 : Filter.Tendsto (fun N : ℕ => Real.sqrt (2 * (1 / 2 : ℝ) ^ N))
        Filter.atTop (nhds 0) := by
      have h : Filter.Tendsto (fun N : ℕ => 2 * (1 / 2 : ℝ) ^ N) Filter.atTop (nhds 0) := by
        simpa using (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num)
          (by norm_num : (1 / 2 : ℝ) < 1)).const_mul 2
      simpa using h.sqrt
    filter_upwards [h0.eventually (eventually_lt_nhds hε)] with N hN y
    calc dist (boxToElltwo y) (boxTrunc N y) = ‖boxToElltwo y - boxTrunc N y‖ := dist_eq_norm _ _
      _ ≤ Real.sqrt (2 * (1 / 2) ^ N) := boxTrunc_tail_estimate N y
      _ < ε := by simpa using hN
  exact huniform.continuous (Filter.Eventually.frequently
    (Filter.Eventually.of_forall fun N => boxTrunc_continuous N))

theorem boxToElltwo_injective : Function.Injective boxToElltwo := by
  intro a b hab
  have h : ((boxToElltwo a : Elltwo) : ℕ → ℝ) = ((boxToElltwo b : Elltwo) : ℕ → ℝ) :=
    congrArg (fun x : Elltwo => (x : ℕ → ℝ)) hab
  exact Subtype.ext h

theorem range_boxToElltwo : range boxToElltwo = hilbertBox := by
  ext x
  constructor
  · rintro ⟨y, rfl⟩ i
    exact y.2 i (mem_univ _)
  · intro hx
    exact ⟨⟨(x : ℕ → ℝ), fun i _ => hx i⟩, rfl⟩

/-- **The `ℓ²`-Hilbert box is compact.** -/
theorem isCompact_hilbertBox : IsCompact hilbertBox := by
  rw [← range_boxToElltwo, ← image_univ]
  haveI : CompactSpace boxSet := isCompact_iff_compactSpace.1 isCompact_boxSet
  exact isCompact_univ.image boxToElltwo_continuous

/-- The tautological map is a topological embedding of the product box into `ℓ²`. -/
theorem boxToElltwo_isEmbedding : IsEmbedding boxToElltwo := by
  haveI : CompactSpace boxSet := isCompact_iff_compactSpace.1 isCompact_boxSet
  exact (boxToElltwo_continuous.isClosedEmbedding boxToElltwo_injective).isEmbedding

/-- A subtype of a product of sets is homeomorphic to the product of the subtypes. -/
noncomputable def piBoxHomeo :
    (univ.pi fun i : ℕ => Icc (0:ℝ) (boxSide i)) ≃ₜ (∀ i : ℕ, Icc (0:ℝ) (boxSide i)) where
  toFun := fun x i => ⟨x.1 i, x.2 i (mem_univ i)⟩
  invFun := fun x => ⟨fun i => (x i).1, fun i _ => (x i).2⟩
  left_inv := by intro x; ext i; rfl
  right_inv := by intro x; funext i; ext; rfl
  continuous_toFun := by
    apply continuous_pi
    intro i
    exact Continuous.subtype_mk ((continuous_apply i).comp continuous_subtype_val) _
  continuous_invFun :=
    Continuous.subtype_mk (continuous_pi fun i => continuous_subtype_val.comp (continuous_apply i)) _

/-- **The `ℓ²`-Hilbert box is homeomorphic to the product Hilbert cube `ℕ → [0,1]`.**
This is the precise sense in which the aleph-one surface "lives in the Hilbert
cube": it is a subset of a homeomorphic copy of `Q`. -/
noncomputable def hilbertBoxHomeoCube : hilbertBox ≃ₜ (ℕ → unitInterval) :=
  ((Homeomorph.setCongr range_boxToElltwo).symm.trans
      boxToElltwo_isEmbedding.toHomeomorph.symm).trans
    (piBoxHomeo.trans (Homeomorph.piCongrRight fun i => iccHomeoI 0 (boxSide i) (boxSide_pos i)))

/-- **Every subset of the Hilbert box embeds in the Hilbert cube.** -/
theorem isEmbedding_of_subset_hilbertBox {A : Set Elltwo} (hA : A ⊆ hilbertBox) :
    ∃ e : A → (ℕ → unitInterval), IsEmbedding e :=
  ⟨fun a => hilbertBoxHomeoCube (Set.inclusion hA a),
    hilbertBoxHomeoCube.isEmbedding.comp (IsEmbedding.inclusion hA)⟩

/-- **The aleph-one surface embeds topologically in the Hilbert cube** — while, by
`alephSurface_no_euclidean_embedding`, it embeds bi-Lipschitzly in no `ℝᵐ`. -/
theorem alephSurface_isEmbedding_hilbertCube :
    ∃ e : alephSurface → (ℕ → unitInterval), IsEmbedding e :=
  isEmbedding_of_subset_hilbertBox alephSurface_subset_hilbertBox

/-! ## An arithmetic dimension spectrum

Cycle 2 of the research loop.  Restricting the family of cells to an arbitrary set
`S ⊆ ℕ` of "admissible dimensions" produces a whole family of surfaces
`surfaceOf S`, and the Hausdorff dimension of `surfaceOf S` reads off the
*supremum of `S`*.  Consequently a purely geometric property of the surface —
being triangulable, or having transfinite dimension — is *equivalent* to an
arithmetic property of `S`: its finiteness.  Feeding classical number-theoretic
sets into this dictionary turns statements about primes into statements about the
geometry of surfaces. -/

/-- The surface built from the cells whose dimension lies in `S`. -/
noncomputable def surfaceOf (S : Set ℕ) : Set Elltwo := ⋃ n ∈ S, cell n

theorem surfaceOf_univ : surfaceOf univ = alephSurface := by
  simp [surfaceOf, alephSurface]

theorem surfaceOf_subset_hilbertBox (S : Set ℕ) : surfaceOf S ⊆ hilbertBox := by
  rw [surfaceOf, iUnion₂_subset_iff]
  exact fun n _ => cell_subset_hilbertBox n

/-- **The dimension spectrum of an arithmetic surface**: its Hausdorff dimension is
the supremum of the admissible dimensions. -/
theorem dimH_surfaceOf (S : Set ℕ) : dimH (surfaceOf S) = ⨆ n ∈ S, (n : ℝ≥0∞) := by
  rw [surfaceOf, dimH_bUnion S.to_countable]
  exact iSup_congr fun n => iSup_congr fun _ => dimH_cell n

theorem le_dimH_surfaceOf {S : Set ℕ} {n : ℕ} (hn : n ∈ S) : (n : ℝ≥0∞) ≤ dimH (surfaceOf S) :=
  dimH_cell n ▸ dimH_mono (subset_biUnion_of_mem (u := fun n => cell n) hn)

/-- **Arithmetic ↔ geometry.**  The surface of `S` is transfinite-dimensional
exactly when `S` is infinite. -/
theorem transfiniteDimensional_surfaceOf_iff (S : Set ℕ) :
    TransfiniteDimensional (surfaceOf S) ↔ S.Infinite := by
  constructor
  · intro hS
    by_contra hfin
    obtain ⟨M, hM⟩ := (Set.not_infinite.mp hfin).bddAbove
    have hle : dimH (surfaceOf S) ≤ (M : ℝ≥0∞) := by
      rw [dimH_surfaceOf]
      exact iSup₂_le fun n hn => by exact_mod_cast hM hn
    rw [hS] at hle
    exact absurd (top_le_iff.1 hle) (by simp)
  · intro hS
    refine le_antisymm le_top ?_
    calc (⊤ : ℝ≥0∞) = ⨆ M : ℕ, (M : ℝ≥0∞) := ENNReal.iSup_natCast.symm
      _ ≤ dimH (surfaceOf S) := by
          refine iSup_le fun M => ?_
          obtain ⟨n, hnS, hMn⟩ := hS.exists_gt M
          exact le_trans (by exact_mod_cast hMn.le) (le_dimH_surfaceOf hnS)

/-- Restriction to the first `n` of `d` coordinates followed by extension by zero
is Lipschitz. -/
theorem restrictSlab_lipschitz {n d : ℕ} (h : n ≤ d) :
    LipschitzWith (NNReal.sqrt n)
      (fun y : Fin d → ℝ => slab n fun i : Fin n => y ⟨i, lt_of_lt_of_le i.2 h⟩) := by
  have hres : LipschitzWith 1
      (fun y : Fin d → ℝ => (fun i : Fin n => y ⟨i, lt_of_lt_of_le i.2 h⟩)) := by
    apply LipschitzWith.of_dist_le_mul
    intro y z
    simp only [NNReal.coe_one, one_mul]
    rw [dist_pi_le_iff dist_nonneg]
    intro i
    exact dist_le_pi_dist y z _
  simpa using (slab_lipschitz n).comp hres

/-- If `S` is bounded by `d`, the surface of `S` really is triangulated by
`|S|`-many Lipschitz `d`-cells: restrict the first `d` coordinates and extend by
zero. -/
noncomputable def triangulationOfBdd {S : Set ℕ} {d : ℕ} (hd : ∀ n ∈ S, n ≤ d) :
    LipschitzTriangulation (surfaceOf S) d where
  ι := S
  countable := inferInstance
  domain := fun _ => univ
  chart := fun j y => slab (j : ℕ) fun i : Fin (j : ℕ) => y ⟨i, lt_of_lt_of_le i.2 (hd j j.2)⟩
  const := fun j => NNReal.sqrt (j : ℕ)
  lipschitz := fun j => (restrictSlab_lipschitz (hd j j.2)).lipschitzOnWith
  covers := by
    rw [surfaceOf, iUnion₂_subset_iff]
    rintro n hn _ ⟨y, _, rfl⟩
    refine mem_iUnion.2
      ⟨⟨n, hn⟩, ⟨fun i : Fin d => if h : (i : ℕ) < n then y ⟨i, h⟩ else 0, mem_univ _, ?_⟩⟩
    show slab n (fun i : Fin n => (if h : (i : ℕ) < n then y ⟨i, h⟩ else 0 : ℝ)) = slab n y
    congr 1
    funext i
    simp [i.2]

/-- **Triangulability is finiteness.**  The surface of `S` admits a Lipschitz
triangulation of some finite dimension if and only if `S` is finite.  Combined
with `transfiniteDimensional_surfaceOf_iff`, the geometry of `surfaceOf S`
completely determines the arithmetic dichotomy for `S`. -/
theorem triangulable_surfaceOf_iff (S : Set ℕ) :
    (∃ d : ℕ, Nonempty (LipschitzTriangulation (surfaceOf S) d)) ↔ S.Finite := by
  constructor
  · rintro ⟨d, ⟨T⟩⟩
    by_contra hfin
    have hinf : S.Infinite := Set.not_finite.mp hfin
    have htop : dimH (surfaceOf S) = ⊤ := (transfiniteDimensional_surfaceOf_iff S).2 hinf
    have := T.dimH_le
    rw [htop] at this
    exact absurd (top_le_iff.1 this) (by simp)
  · intro hfin
    obtain ⟨d, hd⟩ := hfin.bddAbove
    exact ⟨d, ⟨triangulationOfBdd fun n hn => hd hn⟩⟩

/-- **Euclid, geometrically.**  The surface whose cell dimensions are the primes is
transfinite-dimensional — a restatement of the infinitude of primes as a statement
about Hausdorff dimension. -/
theorem primeSurface_transfiniteDimensional :
    TransfiniteDimensional (surfaceOf {p : ℕ | p.Prime}) :=
  (transfiniteDimensional_surfaceOf_iff _).2 Nat.infinite_setOf_prime

/-- Equivalently: the prime surface admits no finite triangulation. -/
theorem primeSurface_no_triangulation (d : ℕ) :
    IsEmpty (LipschitzTriangulation (surfaceOf {p : ℕ | p.Prime}) d) :=
  primeSurface_transfiniteDimensional.no_lipschitzTriangulation d

/-- **The twin prime conjecture as a dimension statement.**  The twin-prime surface
has transfinite Hausdorff dimension if and only if there are infinitely many twin
primes; equivalently (by `triangulable_surfaceOf_iff`) the twin prime conjecture
holds iff that surface is not triangulable in any finite dimension. -/
theorem twinPrimeSurface_transfiniteDimensional_iff :
    TransfiniteDimensional (surfaceOf {p : ℕ | p.Prime ∧ (p + 2).Prime}) ↔
      {p : ℕ | p.Prime ∧ (p + 2).Prime}.Infinite :=
  transfiniteDimensional_surfaceOf_iff _

/-- Every arithmetic surface still embeds in the Hilbert cube: the arithmetic
input changes the dimension, never the ambient home. -/
theorem surfaceOf_isEmbedding_hilbertCube (S : Set ℕ) :
    ∃ e : surfaceOf S → (ℕ → unitInterval), IsEmbedding e :=
  isEmbedding_of_subset_hilbertBox (surfaceOf_subset_hilbertBox S)

/-! ## Cycle 3: transfinite-dimensional manifolds

We now formalise the notion the mission asks for.  A **transfinite-dimensional
manifold** is a metric space that is locally at least as rich as the Hilbert box:
around each point sits a bi-Lipschitzly embedded copy of the box (only the
antilipschitz half of "bi-Lipschitz" is needed).  Every such space inherits
`dimH = ⊤`, hence — by the results above — admits no finite triangulation and no
bi-Lipschitz chart in any finite-dimensional space.  The Hilbert box itself is an
example, so the notion is not vacuous. -/

/-- **The `ℓ²`-Hilbert box has transfinite Hausdorff dimension.**  It is compact,
homeomorphic to the Hilbert cube, and yet no finite dimension bounds it. -/
theorem dimH_hilbertBox : dimH hilbertBox = ⊤ :=
  top_le_iff.1 (dimH_alephSurface ▸ dimH_mono alephSurface_subset_hilbertBox)

theorem hilbertBox_transfiniteDimensional : TransfiniteDimensional hilbertBox := dimH_hilbertBox

/-- **A transfinite-dimensional manifold**: a metric space in which every point has
a neighbourhood containing an antilipschitz (in particular, a bi-Lipschitz) copy of
the Hilbert box. -/
structure TransfiniteManifold (X : Type*) [EMetricSpace X] where
  /-- The chart at each point, an antilipschitz copy of the Hilbert box. -/
  chart : X → hilbertBox → X
  /-- Antilipschitz constants of the charts. -/
  const : X → ℝ≥0
  /-- Each chart is antilipschitz, hence distorts distances boundedly. -/
  antilipschitz : ∀ x, AntilipschitzWith (const x) (chart x)
  /-- Each chart covers a neighbourhood of its centre. -/
  chart_mem_nhds : ∀ x, range (chart x) ∈ nhds x

namespace TransfiniteManifold

variable {X : Type*} [EMetricSpace X]

/-- Each chart image already has transfinite Hausdorff dimension. -/
theorem dimH_chart_range (M : TransfiniteManifold X) (x : X) :
    dimH (range (M.chart x)) = ⊤ := by
  have h1 : dimH (univ : Set hilbertBox) ≤ dimH (M.chart x '' univ) :=
    (M.antilipschitz x).le_dimH_image _
  rw [dimH_univ_subtype, dimH_hilbertBox, image_univ] at h1
  exact top_le_iff.1 h1

/-- **Transfinite dimension is a local phenomenon on such manifolds**: the whole
space has Hausdorff dimension `⊤` as soon as it has a point. -/
theorem transfiniteDimensional (M : TransfiniteManifold X) (x : X) :
    TransfiniteDimensional (univ : Set X) :=
  top_le_iff.1 (M.dimH_chart_range x ▸ dimH_mono (subset_univ (range (M.chart x))))

/-- **A transfinite-dimensional manifold has no finite triangulation.** -/
theorem no_triangulation (M : TransfiniteManifold X) (x : X) (d : ℕ) :
    IsEmpty (LipschitzTriangulation (univ : Set X) d) :=
  (M.transfiniteDimensional x).no_lipschitzTriangulation d

/-- **A transfinite-dimensional manifold has no finite-dimensional bi-Lipschitz
chart**: no antilipschitz map from it to a finite-dimensional normed space. -/
theorem no_finiteDim_chart (M : TransfiniteManifold X) (x : X)
    {F : Type*} [NormedAddCommGroup F] [NormedSpace ℝ F] [FiniteDimensional ℝ F]
    {K : ℝ≥0} {f : ↥(univ : Set X) → F} (hf : AntilipschitzWith K f) : False :=
  (M.transfiniteDimensional x).not_antilipschitz_to_finiteDim hf

/-- Such a manifold is uncountable. -/
theorem uncountable (M : TransfiniteManifold X) (x : X) : ¬ (univ : Set X).Countable :=
  (M.transfiniteDimensional x).not_countable

end TransfiniteManifold

/-- **The Hilbert box is a transfinite-dimensional manifold**, so the notion is not
vacuous: it is a compact, metrizable, transfinite-dimensional manifold without any
finite triangulation. -/
def hilbertBoxManifold : TransfiniteManifold hilbertBox where
  chart := fun _ => id
  const := fun _ => 1
  antilipschitz := fun _ => AntilipschitzWith.id
  chart_mem_nhds := fun _ => by simp

/-- The Hilbert cube (in its `ℓ²` incarnation) admits no finite triangulation. -/
theorem hilbertBox_no_triangulation (d : ℕ) :
    IsEmpty (LipschitzTriangulation hilbertBox d) :=
  hilbertBox_transfiniteDimensional.no_lipschitzTriangulation d

/-! ## Cycle 4: the surface is a non-compact σ-finite-dimensional skeleton

The surface is exhausted by finite-dimensional cells, so it is *countably
finite-dimensional* even though its dimension is `⊤`.  It is a proper subset of
the Hilbert box, and — unlike the box — it is neither closed nor compact: the
"diagonal" point all of whose coordinates are maximal is a limit of cells but lies
in none of them.  This isolates exactly which properties of the box the skeleton
keeps (transfinite dimension, Hilbert-cube ambient) and which it loses
(compactness). -/

/-- Cells are nested: padding with one more zero coordinate. -/
theorem cell_subset_cell_succ (n : ℕ) : cell n ⊆ cell (n + 1) := by
  rintro _ ⟨y, hy, rfl⟩
  refine ⟨fun i : Fin (n + 1) => if h : (i : ℕ) < n then y ⟨i, h⟩ else 0, ?_, ?_⟩
  · intro i _
    by_cases h : (i : ℕ) < n
    · simpa [h] using hy ⟨i, h⟩ (mem_univ _)
    · simp only [dif_neg h]
      exact ⟨le_rfl, (boxSide_pos i).le⟩
  · apply Subtype.ext
    funext i
    by_cases h : i < n
    · simp [h, Nat.lt_succ_of_lt h]
    · simp [h]

/-- **σ-finite-dimensionality.**  The surface is a countable union of sets of
*finite* Hausdorff dimension, even though its own dimension is `⊤`. -/
theorem alephSurface_sigma_finite_dimensional :
    ∃ A : ℕ → Set Elltwo, alephSurface = ⋃ n, A n ∧ ∀ n, dimH (A n) < ⊤ :=
  ⟨cell, rfl, fun n => by rw [dimH_cell]; exact ENNReal.natCast_lt_top n⟩

/-- The "diagonal" point of the Hilbert box: every coordinate maximal. -/
noncomputable def diagPoint : Elltwo :=
  boxToElltwo ⟨fun i => boxSide i, fun i _ => ⟨(boxSide_pos i).le, le_rfl⟩⟩

theorem diagPoint_mem_hilbertBox : diagPoint ∈ hilbertBox := fun i =>
  ⟨(boxSide_pos i).le, le_rfl⟩

theorem diagPoint_notMem_alephSurface : diagPoint ∉ alephSurface := by
  rintro hmem
  obtain ⟨n, ⟨y, _, hxy⟩⟩ := mem_iUnion.1 hmem
  have hcoord : (diagPoint : ℕ → ℝ) n = boxSide n := rfl
  rw [← hxy] at hcoord
  simp only [slab_apply, lt_irrefl] at hcoord
  exact absurd hcoord.symm (boxSide_pos n).ne'

/-- **Every point of the Hilbert box is a limit of cells**: the coordinate
truncations of a box point lie in the cells and converge to it in `ℓ²`. -/
theorem boxToElltwo_mem_closure (y : boxSet) : boxToElltwo y ∈ closure alephSurface := by
  rw [Metric.mem_closure_iff]
  intro ε hε
  have h0 : Filter.Tendsto (fun N : ℕ => Real.sqrt (2 * (1 / 2 : ℝ) ^ N))
      Filter.atTop (nhds 0) := by
    have h : Filter.Tendsto (fun N : ℕ => 2 * (1 / 2 : ℝ) ^ N) Filter.atTop (nhds 0) := by
      simpa using (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num)
        (by norm_num : (1 / 2 : ℝ) < 1)).const_mul 2
    simpa using h.sqrt
  obtain ⟨N, hN⟩ := (h0.eventually (eventually_lt_nhds hε)).exists
  refine ⟨boxTrunc N y, ?_, ?_⟩
  · exact cell_subset_alephSurface N
      ⟨fun i : Fin N => y.1 i, fun i _ => y.2 i (mem_univ _), rfl⟩
  · calc dist (boxToElltwo y) (boxTrunc N y) = ‖boxToElltwo y - boxTrunc N y‖ := dist_eq_norm _ _
      _ ≤ Real.sqrt (2 * (1 / 2) ^ N) := boxTrunc_tail_estimate N y
      _ < ε := by simpa using hN

theorem diagPoint_mem_closure : diagPoint ∈ closure alephSurface :=
  boxToElltwo_mem_closure _

/-- **The surface is dense in the Hilbert box.** -/
theorem hilbertBox_subset_closure_alephSurface : hilbertBox ⊆ closure alephSurface := by
  intro x hx
  have hx' : x = boxToElltwo ⟨(x : ℕ → ℝ), fun i _ => hx i⟩ := rfl
  rw [hx']
  exact boxToElltwo_mem_closure _

/-- **The closure of the aleph-one surface is exactly the Hilbert cube.**  The
σ-finite-dimensional skeleton is dense in the compact transfinite-dimensional cube
that contains it. -/
theorem closure_alephSurface : closure alephSurface = hilbertBox :=
  Subset.antisymm
    (closure_minimal alephSurface_subset_hilbertBox isCompact_hilbertBox.isClosed)
    hilbertBox_subset_closure_alephSurface

/-- The surface is σ-compact: a countable union of compact cells. -/
theorem isSigmaCompact_alephSurface : IsSigmaCompact alephSurface :=
  ⟨cell, fun n => isCompact_cell n, rfl⟩

/-- **Every Hausdorff measure of the surface is infinite.**  Transfinite dimension
is witnessed measure-theoretically: for every exponent `d`, `μH[d]` of the surface
is `∞`. -/
theorem hausdorffMeasure_alephSurface [MeasurableSpace Elltwo] [BorelSpace Elltwo] (d : ℝ≥0) :
    MeasureTheory.Measure.hausdorffMeasure (d : ℝ) alephSurface = ⊤ :=
  hausdorffMeasure_of_lt_dimH (by rw [dimH_alephSurface]; exact ENNReal.coe_lt_top)

/-- **The surface is not closed** in `ℓ²`: the diagonal point of the Hilbert box is
a limit of cells but belongs to no cell. -/
theorem alephSurface_not_isClosed : ¬ IsClosed alephSurface := by
  intro hclosed
  exact diagPoint_notMem_alephSurface (hclosed.closure_eq ▸ diagPoint_mem_closure)

/-- **The surface is not compact**, in contrast with the Hilbert box that contains
it: transfinite Hausdorff dimension is compatible with, but does not require,
compactness. -/
theorem alephSurface_not_isCompact : ¬ IsCompact alephSurface := fun h =>
  alephSurface_not_isClosed h.isClosed

/-- The surface is a *proper* subset of the Hilbert box, yet already carries all of
its Hausdorff dimension. -/
theorem alephSurface_ssubset_hilbertBox : alephSurface ⊂ hilbertBox :=
  ⟨alephSurface_subset_hilbertBox,
    fun h => diagPoint_notMem_alephSurface (h diagPoint_mem_hilbertBox)⟩

/-!
-- !-- Lab Notes -- !--

**Thread continuation.**  This cycle continues `Novelty/AlephOneSurface.lean`,
which developed the *topological* Hilbert cube `ℕ → [0,1]` and explicitly flagged
two open ends: (i) "Hausdorff dimension" could not even be mentioned, since the
product cube carries no canonical metric, and (ii) non-embeddability into `ℝⁿ` was
left unproved.  Both are closed here, in the metric category.

**Hypotheses (Hypothesizer).**
H1  There is a bounded subset of a separable Hilbert space with `dimH = ⊤` whose
    every "cell" has finite dimension.
H2  Such a set cannot be mapped antilipschitzly into any finite-dimensional normed
    space, and cannot be triangulated by finitely many Lipschitz `d`-cells.
H3  It nevertheless embeds topologically in the Hilbert cube — indeed the ambient
    `ℓ²`-box *is* a Hilbert cube.
H4  Its cardinality is `𝔠`, hence `ℵ₁` under CH.
H5  (bold) The dimension of such surfaces is an *arithmetic* invariant: restricting
    the admissible cell dimensions to `S ⊆ ℕ` makes triangulability equivalent to
    finiteness of `S`, so classical prime conjectures become geometry.
H6  (bold) "Dimension `ℵ₁`" is not merely unavailable, it is *structurally*
    forbidden: no uncountable well-ordered chain of dimensions exists at all.

**Experiments (Experimenter).**  Ambient space `ℓ² = lp (fun _ : ℕ => ℝ) 2`.
Cells `cell n = slab n '' ∏_{i<n}[0,2^{-i}]`.  Lower dimension bounds come from
the `1`-Lipschitz coordinate projection `ℓ² → (Fin n → ℝ)` (sup norm), upper bounds
from the `√n`-Lipschitz extension-by-zero; hence `dimH (cell n) = n` exactly and
`dimH (⋃ n, cell n) = ⊤`.

Numerical calibration of the tail estimate (Float `#eval`, see
`ComputationalEvidence.md`): with `T(N) = Σ_{i≥N} 4^{-i} = (4/3)4^{-N}` and the
coarser provable bound `B(N) = 2·2^{-N}` one gets

    N       : 0        1        2        3        4        5        8
    T(N)    : 1.333333 0.333333 0.083333 0.020833 0.005208 0.001302 0.000020
    B(N)    : 2.000000 1.000000 0.500000 0.250000 0.125000 0.062500 0.007812
    √B(N)   : 1.414214 1.000000 0.707107 0.500000 0.353553 0.250000 0.088388

`T ≤ B` at every tested `N`, and `√B(N) → 0` geometrically with ratio `1/√2`,
which is exactly what the uniform-convergence proof of `boxToElltwo_continuous`
consumes.  Also `Σ_{i<30} 4^{-i} = 1.333333`, so every box point has norm
`≤ √(4/3) ≈ 1.1547` — the box is bounded and square-summable.

**Analysis (Analyst).**  Survived: H1–H6, all with `0` sorries.  Needed a different
definition: H2's "no embedding in `ℝⁿ`" is *false* as stated in the topological
category for a general transfinite-dimensional set unless one develops covering
dimension — Mathlib has no topological dimension theory — so the honest theorem is
the metric one (`not_antilipschitz_to_finiteDim`), which is strictly sharper than
what cardinality could ever give (`#alephSurface = #ℝⁿ`, so counting is blind).
Failed as originally phrased: "dimension `ℵ₁`" — a category error, now replaced by
the ceiling theorem of `TransfiniteDimensionCeiling`, which explains *why* no
reformulation can rescue it.  Structural pattern extracted: every obstruction in
this file is one inequality, `dimH (Lipschitz image) ≤ dimH (source)`, applied to a
different diagram; that single monotonicity yields non-embeddability,
non-triangulability, and the `C¹`-atlas obstruction alike.

**Critique (Critic).**  (a) No result is definitional: each uses an insight-bearing
step (`nlinarith` for the coordinate bound, uniform convergence for continuity,
well-founded minima for the ceiling theorem).  (b) Non-vacuity is witnessed:
`triangulationOfBdd` *constructs* triangulations when `S` is finite, and
`hilbertBoxManifold` *constructs* a transfinite-dimensional manifold, so the
impossibility theorems are not empty.  (c) Hidden assumption made explicit: the
`ℓ²` metric.  Hausdorff dimension is not a topological invariant, so
"the Hilbert cube has `dimH = ⊤`" is a statement about the `ℓ²`-box; the
homeomorphism `hilbertBoxHomeoCube` is what licenses calling it a Hilbert cube.
(d) CH appears only as an explicit hypothesis, never smuggled in.

**Synthesis (Principal Investigator).**  The aleph-one surface is: a bounded,
non-compact, σ-finite-dimensional subset of a compact Hilbert cube, with `𝔠` points
(`ℵ₁` under CH), Hausdorff dimension `⊤`, no bi-Lipschitz chart in any `ℝᵐ`, and no
finite triangulation.  Its arithmetic refinements convert the finiteness of a set of
integers into the triangulability of a surface.
-/

end AlephOneHausdorff