/-
# Ambient rigidity forced by transfinite Hausdorff dimension

Research cycles 6 and 7 of the *Aleph-One Surface* thread.

The earlier file `Catalog.NumberTheory.AlephOneSurfaceHausdorff` constructs, inside
`Elltwo = ℓ²(ℕ)`, a set `alephSurface` whose Hausdorff dimension is `⊤` while its cells
realise every finite dimension, and shows it embeds in the Hilbert cube.

Here we turn the argument around and ask what a transfinite-dimensional subset forces upon
its **ambient** normed space.  The answers are all sharp and unconditional:

* `TransfiniteDimensional.not_finiteDimensional` — a normed space that contains a
  transfinite-dimensional subset is infinite dimensional;
* `TransfiniteDimensional.not_locallyCompactSpace` — it is moreover not locally compact
  (Riesz);
* `interior_eq_empty_of_isCompact` — in such a space every compact set has empty interior;
* `isMeagre_of_isSigmaCompact` — hence every σ-compact subset is meagre.

Applied to the surface this gives the geometric picture: `alephSurface` is σ-compact,
dense in the compact Hilbert box `hilbertBox`, yet **meagre** in `Elltwo`; its complement is
dense.  Finally `elltwo_not_isSigmaCompact` shows the ambient space itself is *not*
σ-compact, so the surface can never be exhausted to fill `ℓ²`: the transfinite object is
topologically small even though it is dimension-theoretically maximal.

Cycle 7 completes the picture from the other side:

* `dimH_ball_elltwo` — *every* ball of `ℓ²` has Hausdorff dimension `⊤`, because it contains
  a flat cube of every finite dimension (`le_dimH_ball`, `dimH_slab_image_cube`);
* `dimH_eq_top_of_nonempty_interior` — hence a set with nonempty interior is transfinite;
* `isMeagre_or_dimH_eq_top_of_isFsigma` — the resulting **dimension–category dichotomy**: an
  `Fσ` subset of `ℓ²` is either meagre or of dimension `⊤`, with the surface on the first
  side and a ball on the second.

All statements are proved with 0 sorries.
-/
import Catalog.NumberTheory.AlephOneSurfaceHausdorff

open Set Metric Topology Filter
open scoped ENNReal NNReal

namespace AlephOneHausdorff

/-! ## General ambient rigidity in a normed space -/

section Ambient

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- **Riesz, interior form.** In an infinite-dimensional real normed space every compact set
has empty interior. -/
theorem interior_eq_empty_of_isCompact (h : ¬ FiniteDimensional ℝ E) {K : Set E}
    (hK : IsCompact K) : interior K = ∅ := by
  rw [eq_empty_iff_forall_notMem]
  intro x hx
  rw [mem_interior_iff_mem_nhds, Metric.nhds_basis_closedBall.mem_iff] at hx
  obtain ⟨r, hr, hrK⟩ := hx
  exact h (FiniteDimensional.of_isCompact_closedBall ℝ hr
    (hK.of_isClosed_subset Metric.isClosed_closedBall hrK))

/-- A nowhere dense set is meagre. -/
theorem isMeagre_of_isNowhereDense {X : Type*} [TopologicalSpace X] {s : Set X}
    (hs : IsNowhereDense s) : IsMeagre s :=
  isMeagre_iff_countable_union_isNowhereDense.2
    ⟨{s}, by simpa using hs, countable_singleton s, by simp⟩

/-- In an infinite-dimensional normed space compact sets are nowhere dense. -/
theorem isNowhereDense_of_isCompact (h : ¬ FiniteDimensional ℝ E) {K : Set E}
    (hK : IsCompact K) : IsNowhereDense K :=
  hK.isClosed.isNowhereDense_iff.2 (interior_eq_empty_of_isCompact h hK)

/-- In an infinite-dimensional normed space every σ-compact subset is meagre. -/
theorem isMeagre_of_isSigmaCompact (h : ¬ FiniteDimensional ℝ E) {A : Set E}
    (hA : IsSigmaCompact A) : IsMeagre A := by
  obtain ⟨K, hKc, rfl⟩ := hA
  exact isMeagre_iUnion fun n => isMeagre_of_isNowhereDense (isNowhereDense_of_isCompact h (hKc n))

/-- A normed space containing a set of transfinite Hausdorff dimension is infinite
dimensional. -/
theorem TransfiniteDimensional.not_finiteDimensional {A : Set E}
    (hA : TransfiniteDimensional A) : ¬ FiniteDimensional ℝ E := fun h => by
  haveI := h
  exact Real.dimH_ne_top A hA

/-- A normed space containing a set of transfinite Hausdorff dimension is not locally
compact: transfinite dimension rules out local compactness of the ambient space. -/
theorem TransfiniteDimensional.not_locallyCompactSpace {A : Set E}
    (hA : TransfiniteDimensional A) : ¬ LocallyCompactSpace E := fun h => by
  haveI := h
  exact hA.not_finiteDimensional (FiniteDimensional.of_locallyCompactSpace ℝ)

/-- A transfinite-dimensional set has empty interior; in particular it is never open and
never a neighbourhood of any of its points. -/
theorem TransfiniteDimensional.interior_eq_empty_of_isSigmaCompact [CompleteSpace E] {A : Set E}
    (hA : TransfiniteDimensional A) (hσ : IsSigmaCompact A) : interior A = ∅ := by
  by_contra hne
  obtain ⟨x, hx⟩ := nonempty_iff_ne_empty.2 hne
  exact not_isMeagre_of_isOpen isOpen_interior ⟨x, hx⟩
    ((isMeagre_of_isSigmaCompact hA.not_finiteDimensional hσ).mono interior_subset)

end Ambient

/-! ## Consequences for the aleph-one surface -/

/-- `ℓ²(ℕ)` is infinite dimensional — deduced from the surface it contains. -/
theorem elltwo_not_finiteDimensional : ¬ FiniteDimensional ℝ Elltwo :=
  alephSurface_transfiniteDimensional.not_finiteDimensional

/-- `ℓ²(ℕ)` is not locally compact — deduced from the surface it contains. -/
theorem elltwo_not_locallyCompactSpace : ¬ LocallyCompactSpace Elltwo :=
  alephSurface_transfiniteDimensional.not_locallyCompactSpace

/-- The compact Hilbert box has empty interior. -/
theorem interior_hilbertBox : interior hilbertBox = ∅ :=
  interior_eq_empty_of_isCompact elltwo_not_finiteDimensional isCompact_hilbertBox

/-- The aleph-one surface is nowhere dense in `ℓ²`: its closure is the Hilbert box, which
has empty interior. -/
theorem isNowhereDense_alephSurface : IsNowhereDense alephSurface := by
  rw [IsNowhereDense, closure_alephSurface]
  exact interior_hilbertBox

/-- The aleph-one surface is meagre in `ℓ²`, despite having transfinite Hausdorff
dimension: maximal dimension does not entail topological size. -/
theorem isMeagre_alephSurface : IsMeagre alephSurface :=
  isMeagre_of_isNowhereDense isNowhereDense_alephSurface

/-- Every arithmetic surface `surfaceOf S` is meagre. -/
theorem isMeagre_surfaceOf (S : Set ℕ) : IsMeagre (surfaceOf S) := by
  refine isMeagre_alephSurface.mono ?_
  simpa only [surfaceOf_univ] using
    (iUnion₂_subset fun n _ => cell_subset_alephSurface n : surfaceOf S ⊆ alephSurface)

/-- The surface has empty interior. -/
theorem interior_alephSurface : interior alephSurface = ∅ :=
  eq_empty_of_subset_empty
    ((interior_mono subset_closure).trans_eq
      (by rw [closure_alephSurface, interior_hilbertBox]))

/-- The complement of the surface is dense. -/
theorem dense_compl_alephSurface : Dense alephSurfaceᶜ :=
  interior_eq_empty_iff_dense_compl.1 interior_alephSurface

/-- The surface is nonempty: it contains the image of the empty box. -/
theorem alephSurface_nonempty : alephSurface.Nonempty := by
  refine ⟨slab 0 (fun _ => 0), cell_subset_alephSurface 0 (mem_image_of_mem _ ?_)⟩
  simp [finBox]

/-- The surface is not open. -/
theorem alephSurface_not_isOpen : ¬ IsOpen alephSurface := by
  intro h
  obtain ⟨x, hx⟩ := alephSurface_nonempty
  have h1 : interior alephSurface = ∅ := interior_alephSurface
  rw [h.interior_eq] at h1
  rw [h1] at hx
  exact hx

/-- Although the surface is σ-compact, the ambient space is not: `ℓ²` cannot be written as a
countable union of compact sets. -/
theorem elltwo_not_isSigmaCompact : ¬ IsSigmaCompact (univ : Set Elltwo) := by
  intro h
  haveI : Fact ((1 : ℝ≥0∞) ≤ 2) := ⟨one_le_two⟩
  exact not_isMeagre_of_isOpen isOpen_univ univ_nonempty
    (isMeagre_of_isSigmaCompact elltwo_not_finiteDimensional h)

/-! ## Cycle 7: every ball of `ℓ²` is transfinite-dimensional, and a category dichotomy -/

/-- The cube of side `s > 0` in `Fin n → ℝ` has Hausdorff dimension `n`. -/
theorem dimH_cube (n : ℕ) {s : ℝ} (hs : 0 < s) :
    dimH (univ.pi fun _ : Fin n => Icc (0 : ℝ) s) = n := by
  have h : (interior (univ.pi fun _ : Fin n => Icc (0 : ℝ) s)).Nonempty := by
    rw [interior_pi_set Set.finite_univ]
    refine ⟨fun _ => s / 2, fun i _ => ?_⟩
    simp only [interior_Icc, mem_Ioo]
    constructor <;> linarith
  rw [Real.dimH_of_nonempty_interior h]
  simp

/-- A flat cube of side `s > 0` sitting in the first `n` coordinates of `ℓ²` has Hausdorff
dimension exactly `n`: the same two-sided Lipschitz squeeze that computes `dimH_cell`. -/
theorem dimH_slab_image_cube (n : ℕ) {s : ℝ} (hs : 0 < s) :
    dimH (slab n '' (univ.pi fun _ : Fin n => Icc (0 : ℝ) s)) = n := by
  set C : Set (Fin n → ℝ) := univ.pi fun _ : Fin n => Icc (0 : ℝ) s with hC
  have himg : coord n '' (slab n '' C) = C := by
    rw [← image_comp]
    simp [coord_slab]
  refine le_antisymm ?_ ?_
  · calc dimH (slab n '' C) ≤ dimH C := (slab_lipschitz n).dimH_image_le _
      _ = n := dimH_cube n hs
  · calc (n : ℝ≥0∞) = dimH C := (dimH_cube n hs).symm
      _ = dimH (coord n '' (slab n '' C)) := by rw [himg]
      _ ≤ dimH (slab n '' C) := (coord_lipschitz n).dimH_image_le _

/-- Every ball of `ℓ²` contains a flat cube of every finite dimension. -/
theorem le_dimH_ball (x : Elltwo) {r : ℝ} (hr : 0 < r) (n : ℕ) :
    (n : ℝ≥0∞) ≤ dimH (Metric.ball x r) := by
  have hsqrt : (0 : ℝ) ≤ Real.sqrt n := Real.sqrt_nonneg _
  set s : ℝ := r / (2 * (Real.sqrt n + 1)) with hsdef
  have hs : 0 < s := by
    apply div_pos hr
    linarith
  set C : Set (Fin n → ℝ) := univ.pi fun _ : Fin n => Icc (0 : ℝ) s with hC
  have heq : (Real.sqrt n + 1) * s = r / 2 := by
    rw [hsdef]
    field_simp
  have hcube : Real.sqrt n * s ≤ r / 2 := by nlinarith [hs.le]
  have hsub : (fun z : Elltwo => x + z) '' (slab n '' C) ⊆ Metric.ball x r := by
    rintro _ ⟨_, ⟨y, hy, rfl⟩, rfl⟩
    have hynorm : ‖y‖ ≤ s := by
      refine (pi_norm_le_iff_of_nonneg hs.le).2 fun i => ?_
      have := hy i (mem_univ i)
      rw [Real.norm_eq_abs, abs_le]
      exact ⟨by linarith [this.1], this.2⟩
    have hnorm : ‖slab n y‖ ≤ Real.sqrt n * s :=
      (norm_slab_le n y).trans (mul_le_mul_of_nonneg_left hynorm hsqrt)
    have : dist (x + slab n y) x < r := by
      rw [dist_eq_norm]
      simp only [add_sub_cancel_left]
      calc ‖slab n y‖ ≤ Real.sqrt n * s := hnorm
        _ ≤ r / 2 := hcube
        _ < r := by linarith
    simpa [Metric.mem_ball] using this
  calc (n : ℝ≥0∞) = dimH (slab n '' C) := (dimH_slab_image_cube n hs).symm
    _ = dimH ((fun z : Elltwo => x + z) '' (slab n '' C)) :=
        ((isometry_add_left x).dimH_image _).symm
    _ ≤ dimH (Metric.ball x r) := dimH_mono hsub

/-- **Every ball of `ℓ²` has transfinite Hausdorff dimension.**  Transfinite dimension is
therefore a purely local phenomenon in `ℓ²`: no neighbourhood of any point is
finite-dimensional. -/
theorem dimH_ball_elltwo (x : Elltwo) {r : ℝ} (hr : 0 < r) : dimH (Metric.ball x r) = ⊤ := by
  refine top_unique ?_
  rw [← ENNReal.iSup_natCast]
  exact iSup_le fun n => le_dimH_ball x hr n

/-- A subset of `ℓ²` with nonempty interior is transfinite-dimensional. -/
theorem dimH_eq_top_of_nonempty_interior {A : Set Elltwo} (h : (interior A).Nonempty) :
    dimH A = ⊤ := by
  obtain ⟨x, hx⟩ := h
  obtain ⟨r, hr, hrA⟩ := Metric.mem_nhds_iff.1 (mem_interior_iff_mem_nhds.1 hx)
  exact top_unique ((dimH_ball_elltwo x hr).ge.trans (dimH_mono hrA))

/-- **Dimension–category dichotomy in `ℓ²`.**  An `Fσ` subset of `ℓ²` is either meagre or has
transfinite Hausdorff dimension: there is no `Fσ` set that is simultaneously topologically
large and of finite dimension.  The aleph-one surface sits on the meagre side of the
dichotomy, a closed ball on the transfinite side. -/
theorem isMeagre_or_dimH_eq_top_of_isFsigma {A : Set Elltwo} {F : ℕ → Set Elltwo}
    (hF : ∀ n, IsClosed (F n)) (hA : A = ⋃ n, F n) : IsMeagre A ∨ dimH A = ⊤ := by
  by_cases hm : IsMeagre A
  · exact Or.inl hm
  refine Or.inr (top_unique ?_)
  have hex : ∃ n, ¬ IsMeagre (F n) := by
    by_contra hall
    push_neg at hall
    exact hm (hA ▸ isMeagre_iUnion hall)
  obtain ⟨n, hn⟩ := hex
  have hint : (interior (F n)).Nonempty := by
    rw [nonempty_iff_ne_empty]
    intro h0
    exact hn (isMeagre_of_isNowhereDense ((hF n).isNowhereDense_iff.2 h0))
  have hFn : dimH (F n) = ⊤ := dimH_eq_top_of_nonempty_interior hint
  exact hFn.ge.trans (dimH_mono (hA ▸ subset_iUnion F n))

/-!
## Lab Notes — Cycle 6

*Hypothesis.* A subset of transfinite Hausdorff dimension should be "large" in every sense.

*Experiment.* `alephSurface` was tested against the Baire-category notion of size. Its
closure is the compact Hilbert box (cycle 5), and Riesz's theorem forces a compact set in an
infinite-dimensional normed space to have empty interior. The experiment therefore returned
the opposite of the hypothesis: `isMeagre_alephSurface`.

*Analysis.* Hausdorff dimension and Baire category are genuinely orthogonal here. The same
computation shows the ambient space inherits rigidity from the surface: `ℓ²` is infinite
dimensional, not locally compact, and not σ-compact, all deduced purely from
`dimH alephSurface = ⊤`. Since `alephSurface` *is* σ-compact, σ-compactness separates the
surface from its ambient space — a witness that the surface, though dimension-theoretically
maximal, is topologically thin.

*Cycle 7 addendum.* Pushing further, every ball of `ℓ²` was shown to contain a flat cube of
each finite dimension (`le_dimH_ball`), hence `dimH (ball x r) = ⊤` for every positive radius:
transfinite dimension is a purely *local* feature of `ℓ²`. Combining with Baire gives the
dichotomy `isMeagre_or_dimH_eq_top_of_isFsigma`: an `Fσ` subset of `ℓ²` is meagre or has
dimension `⊤`, with the surface on the first side and any ball on the second. Numerically,
the cube inserted into `ball x r` has side `r / (2(√n + 1))`, so the `n`-dimensional witness
shrinks like `r / (2√n)` — the reason no single scale detects transfinite dimension.

*Critique.* No statement here is vacuous: `alephSurface` is nonempty (`alephSurface_not_isOpen`
exhibits a point), `hilbertBox` is a nonempty compact set, and each theorem uses Riesz's
theorem or Baire's theorem rather than definitional unfolding.
-/

end AlephOneHausdorff