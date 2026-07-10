import Mathlib

/-!
# The Metric Geometry of Surprise

We develop a quantitative theory of *surprise* in which a "setup" is modelled by a
finite nonempty configuration of resolutions `S ⊆ ℝ`, laid out along a single
interpretive axis. Two canonical resolutions bound the configuration:

* the **expected resolution** `min' S`, the least (most conservative) reading of the
  setup — the analogue of a *limit* of the setup diagram;
* the **subverting resolution** `max' S`, the greatest (most divergent) reading — the
  analogue of a *colimit*.

The **surprise** of the configuration is the gap between these two extremes,
`humor S = max' S - min' S`. This is the well-known *range* of a finite set, here
recast as a numerical invariant of surprise. The results below establish that this
invariant behaves like a genuine geometric quantity:

* `humor_nonneg` : surprise is never negative.
* `humor_eq_zero_iff` : surprise vanishes exactly when every resolution coincides —
  the degenerate "no subversion" case.
* `humor_singleton` : a one-point setup has zero surprise.
* `humor_mono` : enriching a setup can only increase its surprise.
* `humor_is_diameter` : surprise is *exactly* the largest distance between any two
  resolutions, i.e. the diameter of the configuration.
* `humor_dist_le` and `humor_attained` : the diameter bound is uniform and attained.
* `subverting_isGreatest` / `expected_isLeast` : the two canonical resolutions are
  characterised by universal (extremal) properties.

-- !-- Lab Notes -- !--
Hypothesis: surprise is a metric-geometric quantity — the spread between the most
conservative and most divergent resolution of a setup — and it satisfies the
axioms one expects of a "diameter": nonnegativity, a vanishing characterisation,
monotonicity under refinement, and attainment.

Experiment: model a setup as a finite nonempty `Finset ℝ` and define
`humor := max' - min'`. Each claimed property was reduced to the order structure of
the extremes via `Finset.le_max'`, `Finset.min'_le`, `Finset.min'_le_max'` and
discharged with `linarith` after unfolding.

Analysis: the identity `humor = diameter` (`humor_is_diameter`) is the load-bearing
structural fact: it certifies that the one-dimensional range coincides with the
supremum of pairwise distances, so surprise is coordinate-free. The vanishing
characterisation isolates the "pun" regime (surprise `0`) from the "absurdist"
regime (large surprise).

Critique: the model is one-dimensional, so `min'`/`max'` genuinely bracket the set;
in higher dimensions the analogous statement requires the convex hull and is left
to future work. No theorem here is vacuous: each has explicit witnesses
(`max'_mem`, `min'_mem`) and the diameter identity is attained.

Synthesis: surprise is the diameter of the resolution configuration; the funnier
the setup, the wider the gap between its limiting and colimiting resolutions.
-/

open Finset

namespace JokeHumor

/-- The **surprise** of a setup: the gap between its most divergent resolution
(`max'`, the colimiting reading) and its most conservative resolution (`min'`, the
limiting reading). -/
noncomputable def humor (S : Finset ℝ) (h : S.Nonempty) : ℝ := S.max' h - S.min' h

/-- Surprise is never negative. -/
theorem humor_nonneg (S : Finset ℝ) (h : S.Nonempty) : 0 ≤ humor S h := by
  unfold humor
  rw [sub_nonneg]
  exact S.min'_le_max' h

/-- **Pun characterisation.** Surprise vanishes exactly when the setup admits a
single resolution: there is nothing to subvert. -/
theorem humor_eq_zero_iff (S : Finset ℝ) (h : S.Nonempty) :
    humor S h = 0 ↔ ∀ x ∈ S, ∀ y ∈ S, x = y := by
  unfold humor
  rw [sub_eq_zero]
  constructor
  · intro hmm x hx y hy
    have h1 : x ≤ S.max' h := S.le_max' x hx
    have h2 : S.min' h ≤ x := S.min'_le x hx
    have h3 : y ≤ S.max' h := S.le_max' y hy
    have h4 : S.min' h ≤ y := S.min'_le y hy
    linarith [hmm]
  · intro hc
    exact hc _ (S.max'_mem h) _ (S.min'_mem h)

/-- A one-resolution setup is a pun: zero surprise. -/
theorem humor_singleton (a : ℝ) : humor {a} (singleton_nonempty a) = 0 := by
  unfold humor; simp

/-- **Monotonicity.** Enlarging a setup can only widen its surprise. -/
theorem humor_mono (S T : Finset ℝ) (hS : S.Nonempty) (hT : T.Nonempty)
    (hsub : S ⊆ T) : humor S hS ≤ humor T hT := by
  unfold humor
  have hmax : S.max' hS ≤ T.max' hT := T.le_max' _ (hsub (S.max'_mem hS))
  have hmin : T.min' hT ≤ S.min' hS := T.min'_le _ (hsub (S.min'_mem hS))
  linarith

/-- The distance between any two resolutions of a setup is bounded by its surprise. -/
theorem humor_dist_le (S : Finset ℝ) (h : S.Nonempty) {x y : ℝ}
    (hx : x ∈ S) (hy : y ∈ S) : |x - y| ≤ humor S h := by
  unfold humor
  rw [abs_sub_le_iff]
  refine ⟨?_, ?_⟩
  · have := S.le_max' x hx; have := S.min'_le y hy; linarith
  · have := S.le_max' y hy; have := S.min'_le x hx; linarith

/-- The surprise bound is attained by the extremal resolutions. -/
theorem humor_attained (S : Finset ℝ) (h : S.Nonempty) :
    ∃ x ∈ S, ∃ y ∈ S, |x - y| = humor S h := by
  refine ⟨S.max' h, S.max'_mem h, S.min' h, S.min'_mem h, ?_⟩
  unfold humor
  rw [abs_of_nonneg (by rw [sub_nonneg]; exact S.min'_le_max' h)]

/-- **Surprise is the diameter.** The surprise of a setup is precisely the greatest
distance between any two of its resolutions — a coordinate-free description that does
not privilege the two extremes. -/
theorem humor_is_diameter (S : Finset ℝ) (h : S.Nonempty) :
    IsGreatest {d : ℝ | ∃ x ∈ S, ∃ y ∈ S, d = |x - y|} (humor S h) := by
  constructor
  · refine ⟨S.max' h, S.max'_mem h, S.min' h, S.min'_mem h, ?_⟩
    unfold humor
    rw [abs_of_nonneg (by rw [sub_nonneg]; exact S.min'_le_max' h)]
  · rintro d ⟨x, hx, y, hy, rfl⟩
    exact humor_dist_le S h hx hy

/-- **Universal property of the colimiting resolution.** The subverting resolution is
the least reading that dominates every reading in the setup. -/
theorem subverting_isGreatest (S : Finset ℝ) (h : S.Nonempty) :
    IsGreatest (↑S : Set ℝ) (S.max' h) :=
  ⟨S.max'_mem h, fun x hx => S.le_max' x hx⟩

/-- **Universal property of the limiting resolution.** The expected resolution is the
greatest reading dominated by every reading in the setup. -/
theorem expected_isLeast (S : Finset ℝ) (h : S.Nonempty) :
    IsLeast (↑S : Set ℝ) (S.min' h) :=
  ⟨S.min'_mem h, fun x hx => S.min'_le x hx⟩

/-
**Stability of surprise.** If every resolution of a setup is perturbed by at most
`ε` (via a reinterpretation `f`), then the surprise of the perturbed setup differs from
the original by at most `2ε`. Surprise is a stable invariant of a setup: small changes
in how each resolution is read cannot produce large changes in humor.
-/
theorem humor_lipschitz (S : Finset ℝ) (h : S.Nonempty) (f : ℝ → ℝ) (ε : ℝ)
    (hf : ∀ x ∈ S, |f x - x| ≤ ε) :
    |humor (S.image f) (h.image f) - humor S h| ≤ 2 * ε := by
  generalize_proofs at *;
  -- Apply the bounds for max' and min' to the perturbed setup.
  have h_max : (S.image f).max' (by
  assumption) ≤ S.max' h + ε := by
    simp +zetaDelta at *;
    exact fun x hx => by linarith [ abs_le.mp ( hf x hx ), Finset.le_max' _ _ hx ] ;
  have h_min : (S.image f).min' (by
  assumption) ≥ S.min' h - ε := by
    simp_all +decide [ Finset.min', Finset.max' ];
    exact fun x hx => ⟨ x, hx, by linarith [ abs_le.mp ( hf x hx ) ] ⟩
  generalize_proofs at *;
  have h_max' : (S.image f).max' ‹_› ≥ S.max' h - ε := by
    exact le_trans ( by linarith [ abs_le.mp ( hf ( S.max' h ) ( Finset.max'_mem _ h ) ) ] ) ( Finset.le_max' _ _ ( Finset.mem_image_of_mem _ ( Finset.max'_mem _ h ) ) )
  have h_min' : (S.image f).min' ‹_› ≤ S.min' h + ε := by
    exact le_trans ( Finset.min'_le _ _ <| Finset.mem_image_of_mem _ <| Finset.min'_mem _ h ) <| by linarith [ abs_le.mp <| hf _ <| Finset.min'_mem _ h ] ;
  exact abs_le.mpr ⟨ by unfold humor; linarith, by unfold humor; linarith ⟩

end JokeHumor