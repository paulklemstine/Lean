/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Novelty.CertifiedNovelty
import Applications.MachineLearning.NoveltyRegions

/-!
# Set-Level Novelty and Hausdorff Stability of the Birth Time

This file extends the catalog novelty framework along the **point → set** axis, using
the Hausdorff metric as the dictionary: a *set* of the base space becomes a *point* of
the space of nonempty compact sets `TopologicalSpace.NonemptyCompacts α`, whose `dist`
is precisely the Hausdorff distance. Every pointwise theorem of the catalog therefore
casts a set-level shadow.

* **Set-level novelty.** `IsNovelSet ε Fam A` is the catalog predicate `IsNovel`
  evaluated in the Hausdorff metric space: the compact set `A` is `ε`-far (in Hausdorff
  distance) from a whole *family* `Fam` of reference sets. Robustness and antitonicity
  transport verbatim (`novelSet_triangle_transfer`, `isNovelSet_antitone_family`).

* **Future Direction 5: stability of the barcode.** The birth time `birthTime S x`
  (= `infDist x S`) is `1`-Lipschitz *in the reference set* with respect to the
  Hausdorff distance: `|birthTime S x − birthTime T x| ≤ hausdorffDist S T`. Together
  with the point-variable regularity from the catalog (`noveltyScore_lipschitz`), this
  shows the whole persistence diagram is stable: a small Hausdorff perturbation of the
  knowledge base moves every barcode endpoint by at most the perturbation.

## Main results

* `birthTime_lipschitz_reference` — birth time is `1`-Lipschitz in the reference set.
* `IsNovelSet` — set-level novelty predicate via the Hausdorff metric.
* `novelSet_triangle_transfer` — set-level robustness via the Hausdorff triangle.
* `isNovelSet_antitone_family` — set-level novelty is antitone in the family.
-/

namespace CertifiedNovelty

open Metric TopologicalSpace

-- !-- Lab Notebook --------------------------------------------------------------- !--
-- Hypothesis: regularity proven for the *query point* should have a mirror image for
--   the *reference set*, with the Hausdorff distance playing the role of the metric,
--   yielding two-sided stability of the persistence barcode.
-- Result: `birthTime · x` is 1-Lipschitz in the reference set under Hausdorff distance;
--   and the entire catalog `IsNovel` calculus reappears for compact sets viewed as
--   points of `NonemptyCompacts α` (where `dist` *is* the Hausdorff distance).
-- Insight: `birthTime = infDist x ·`, and `infDist` is itself 1-Lipschitz in the set
--   argument — the second-variable dual of `noveltyScore_lipschitz`.
-- Failure analysis: the bound needs `hausdorffEDist S T ≠ ⊤` (finite Hausdorff
--   distance, e.g. both sets nonempty and bounded); otherwise the inequality is empty.
-- ------------------------------------------------------------------------------- !--

variable {α : Type*} [PseudoMetricSpace α]

/-! ## Future Direction 5: Hausdorff stability of the birth time -/

-- !-- Apply `infDist_le_infDist_add_hausdorffDist` both ways (using
-- `hausdorffEDist_comm` and `hausdorffDist_comm`) and combine via `abs_sub_le_iff`. -- !--
/-- **Stability of the persistence barcode.** The birth time of a fixed query point is
`1`-Lipschitz in the reference set with respect to the Hausdorff distance:
`|birthTime S x − birthTime T x| ≤ hausdorffDist S T`, provided the Hausdorff distance
between `S` and `T` is finite. Small Hausdorff perturbations of the knowledge base move
every barcode endpoint by at most the size of the perturbation. -/
theorem birthTime_lipschitz_reference {S T : Set α} (x : α)
    (h : hausdorffEDist S T ≠ ⊤) :
    |birthTime S x - birthTime T x| ≤ hausdorffDist S T := by
  have hsym : hausdorffEDist T S ≠ ⊤ := by rwa [hausdorffEDist_comm]
  have h1 := Metric.infDist_le_infDist_add_hausdorffDist (x := x) h
  have h2 := Metric.infDist_le_infDist_add_hausdorffDist (x := x) hsym
  rw [hausdorffDist_comm] at h2
  unfold birthTime noveltyScore
  rw [abs_sub_le_iff]
  constructor <;> linarith

/-! ## Set-level novelty via the Hausdorff metric -/

variable {β : Type*} [MetricSpace β]

/-- **Set-level novelty.** Viewing each nonempty compact subset of `β` as a point of
the Hausdorff metric space `NonemptyCompacts β`, a set `A` is **`ε`-novel** relative to
a family `Fam` of reference sets if it is `ε`-far (in Hausdorff distance) from every
member of `Fam`. This is literally the catalog predicate `IsNovel` in the Hausdorff
metric space. -/
def IsNovelSet (ε : ℝ) (Fam : Set (NonemptyCompacts β)) (A : NonemptyCompacts β) : Prop :=
  IsNovel ε Fam A

-- !-- Direct instance of `novel_triangle_transfer` in the metric space
-- `NonemptyCompacts β`, where `dist` is the Hausdorff distance. -- !--
/-- **Set-level robustness (Hausdorff triangle transfer).** If a compact set `A` is
`ε`-novel and `B` is within Hausdorff distance `δ` of `A`, then `B` is `(ε − δ)`-novel.
The set-level shadow of `novel_triangle_transfer`. -/
theorem novelSet_triangle_transfer {ε δ : ℝ} {Fam : Set (NonemptyCompacts β)}
    {A B : NonemptyCompacts β} (hAB : dist A B ≤ δ) (hA : IsNovelSet ε Fam A) :
    IsNovelSet (ε - δ) Fam B :=
  novel_triangle_transfer hAB hA

-- !-- Direct instance of `isNovel_antitone_set` in `NonemptyCompacts β`. -- !--
/-- **Antitonicity in the family.** Set-level novelty against a larger reference family
implies novelty against any subfamily; the shadow of `isNovel_antitone_set`. -/
theorem isNovelSet_antitone_family {ε : ℝ} {Fam Sub : Set (NonemptyCompacts β)}
    (hsub : Sub ⊆ Fam) {A : NonemptyCompacts β} (h : IsNovelSet ε Fam A) :
    IsNovelSet ε Sub A :=
  isNovel_antitone_set hsub h

end CertifiedNovelty