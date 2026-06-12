/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Novelty.CertifiedNovelty

/-!
# Adaptive, Compositional, and Multi-Scale Novelty Certification

This file extends the metric novelty-certification framework of
`Novelty.CertifiedNovelty` along three of the research directions raised there.
Throughout, `noveltyScore S x = Metric.infDist x S` is the continuous novelty score
and `IsNovel ε S x` is the predicate "`x` is `ε`-separated from the corpus `S`".

## Themes

* **Knowledge saturation (ε-nets).** When the corpus becomes an `ε`-net of the ambient
  space — every point is within `ε` of something already known — *all* novelty scores
  collapse below `ε`, and no threshold above `ε` can ever be certified. We also prove a
  quantitative approximate converse: a uniform score bound forces the corpus to be an
  (arbitrarily tight) approximate `ε`-net.

* **Adaptive thresholds from corpus geometry.** Taking the threshold to be the corpus's
  own separation `σ` makes the certificate *exactly* discriminating: each known theorem
  is `σ`-novel against its peers `S \ {x}` yet is correctly *rejected* against the full
  corpus `S`. Positive-threshold novelty always implies the point is outside the corpus.

* **Compositional novelty (products).** For a structured object `(x, y)` with independent
  corpora `S`, `T`, the compositional score `min (noveltyScore S x) (noveltyScore T y)`
  is `1`-Lipschitz in the `ℓ^∞` product metric, enabling modular certification.

* **Multi-scale filtrations.** The novelty sets `{x | IsNovel δ S x}` form a chain that
  is antitone in the threshold `δ` and antitone in the corpus `S`: a two-parameter
  filtration, the metric analogue of a persistence module.

## Main results

* `noveltyScore_le_of_isEpsNet` / `not_isNovel_of_isEpsNet` — knowledge saturation.
* `isEpsNet_approx_of_noveltyScore_le` — approximate converse to saturation.
* `adaptive_threshold_separates` — adaptive threshold = corpus separation discriminates.
* `compNovelty_lipschitz` — compositional novelty is `1`-Lipschitz on products.
* `noveltySet_antitone_threshold` / `noveltySet_antitone_corpus` — the novelty filtration.
-/

namespace CertifiedNovelty

open Metric

variable {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]

/- !-- Lab Notebook -- !--
Hypothesis: The fixed-threshold novelty framework of `CertifiedNovelty` admits three
orthogonal upgrades — corpus-adaptive thresholds, compositional (product) scores, and
multi-scale filtrations — all derivable from the regularity already proved there
(`noveltyScore_lipschitz`, `noveltyScore_antitone`, `isNovel_iff_le_noveltyScore`).

Result: All three upgrades go through. Saturation (`noveltyScore_le_of_isEpsNet`) and
its approximate converse pin novelty to covering geometry; `adaptive_threshold_separates`
shows the separation-scaled threshold is *exactly* discriminating; `compNovelty_lipschitz`
lifts Lipschitz regularity to products; the filtration lemmas package anti-monotonicity
in both parameters.

Insight: `Metric.infDist` is the right abstraction — every theorem here reduces to a
one-line `infDist` fact plus the triangle inequality, so the framework scales without new
analytic input. The "adaptive threshold" intuition is captured cleanly by the fact that
`dist x x = 0`: any positive threshold automatically rejects corpus members.

Failure analysis: An exact converse to saturation ("score ≤ ε ⇒ ε-net") is false in
general metric spaces because `infDist` need not be attained; we therefore state the
honest approximate converse `isEpsNet_approx_of_noveltyScore_le` with a slack `η > 0`.
-/

/-! ## Knowledge saturation via ε-nets -/

/-- A corpus `S` is an **`ε`-net** of the ambient space if every point lies within `ε`
of something already known. As corpora grow, becoming an `ε`-net is the precise sense in
which "all the easy novelty has been used up". -/
def IsEpsNet (ε : ℝ) (S : Set α) : Prop := ∀ x, ∃ s ∈ S, dist x s ≤ ε

-- !-- `infDist x S ≤ dist x s ≤ ε` for the net witness `s`. -- !--
/-- **Knowledge saturation (forward).** If the corpus is an `ε`-net, then *every* novelty
score is at most `ε`: nothing can be more than `ε`-novel once the space is `ε`-covered. -/
theorem noveltyScore_le_of_isEpsNet {ε : ℝ} {S : Set α} (h : IsEpsNet ε S) (x : α) :
    noveltyScore S x ≤ ε := by
  obtain ⟨s, hs, hsd⟩ := h x
  exact le_trans (Metric.infDist_le_dist_of_mem hs) hsd

-- !-- A net witness `s` has `dist x s ≤ ε < δ`, contradicting `δ ≤ dist x s`. -- !--
/-- **Saturation kills high thresholds.** If the corpus is an `ε`-net then no point is
`δ`-novel for any threshold `δ > ε`: the certificate collapses above the covering scale. -/
theorem not_isNovel_of_isEpsNet {ε δ : ℝ} {S : Set α} (h : IsEpsNet ε S) (hδ : ε < δ)
    (x : α) : ¬ IsNovel δ S x := by
  obtain ⟨s, hs, hsd⟩ := h x
  intro hnov
  have := hnov s hs
  linarith

-- !-- `infDist x S ≤ ε < ε + η`, so `Metric.infDist_lt_iff` produces a close witness. -- !--
/-- **Approximate converse to saturation.** If every novelty score is at most `ε` (and the
corpus is nonempty), then the corpus is an *approximate* `ε`-net: for every point and
every slack `η > 0` there is a known point within `ε + η`. (An exact `ε`-net need not
exist because `infDist` may not be attained.) -/
theorem isEpsNet_approx_of_noveltyScore_le {ε : ℝ} {S : Set α} (hS : S.Nonempty)
    (h : ∀ x, noveltyScore S x ≤ ε) (x : α) {η : ℝ} (hη : 0 < η) :
    ∃ s ∈ S, dist x s < ε + η := by
  have hlt : noveltyScore S x < ε + η := lt_of_le_of_lt (h x) (by linarith)
  exact (Metric.infDist_lt_iff hS).1 hlt

/-! ## Adaptive thresholds from corpus geometry -/

-- !-- `IsNovel σ S x` would force `σ ≤ dist x x = 0`, impossible for `σ > 0`. -- !--
/-- **Positive novelty excludes corpus members.** With any strictly positive threshold,
a certified-novel point cannot already be in the corpus. This is the soundness half of
"the certificate rejects exactly the known theorems". -/
theorem isNovel_pos_notMem {σ : ℝ} {S : Set α} (hσ : 0 < σ) {x : α}
    (h : IsNovel σ S x) : x ∉ S := by
  intro hx
  have := h x hx
  rw [dist_self] at this
  linarith

-- !-- Direct restatement of `isNovel_pos_notMem` as a rejection. -- !--
/-- **Corpus members are rejected.** At a positive threshold, every element of the corpus
fails the novelty certificate against the full corpus. -/
theorem corpus_elem_not_isNovel {σ : ℝ} {S : Set α} (hσ : 0 < σ) {x : α} (hx : x ∈ S) :
    ¬ IsNovel σ S x := fun h => isNovel_pos_notMem hσ h hx

-- !-- Combine `isNovel_of_mutuallySeparated` (peers) with `corpus_elem_not_isNovel`
-- (full corpus). -- !--
/-- **The adaptive threshold is exactly discriminating.** If the corpus is mutually
`σ`-separated with `σ > 0`, then taking the threshold equal to the corpus separation `σ`
makes each known theorem `x`:

* `σ`-novel with respect to its **peers** `S \ {x}` (it genuinely sits at the corpus's
  own resolution), yet
* **not** `σ`-novel with respect to the **full corpus** `S` (it is, after all, known).

Thus the separation-scaled threshold neither over- nor under-certifies the corpus. -/
theorem adaptive_threshold_separates {σ : ℝ} {S : Set α} (hS : MutuallySeparated σ S)
    (hσ : 0 < σ) {x : α} (hx : x ∈ S) :
    IsNovel σ (S \ {x}) x ∧ ¬ IsNovel σ S x :=
  ⟨isNovel_of_mutuallySeparated hS hx, corpus_elem_not_isNovel hσ hx⟩

/-! ## Compositional novelty on products -/

/-- **Compositional novelty score.** For a structured object `(x, y)` whose two parts are
judged against independent corpora `S ⊆ α` and `T ⊆ β`, its novelty is the *weakest link*:
the minimum of the component novelty scores. (The `ℓ^∞`/product metric on `α × β` is the
ambient metric `Prod.pseudoMetricSpace`.) -/
noncomputable def compNovelty (S : Set α) (T : Set β) (p : α × β) : ℝ :=
  min (noveltyScore S p.1) (noveltyScore T p.2)

-- !-- Each component is `noveltyScore ∘ projection`, a composition of `1`-Lipschitz maps;
-- the minimum of `1`-Lipschitz maps is `1`-Lipschitz (`LipschitzWith.min`). -- !--
/-- **Compositional novelty is `1`-Lipschitz.** The compositional score is `1`-Lipschitz
in the product (`ℓ^∞`) metric, so modular certification is robust: perturbing any part of
a structured object by `δ` changes its compositional novelty by at most `δ`. -/
theorem compNovelty_lipschitz (S : Set α) (T : Set β) :
    LipschitzWith 1 (compNovelty S T) := by
  have h1 : LipschitzWith 1 (fun p : α × β => noveltyScore S p.1) := by
    simpa using (noveltyScore_lipschitz S).comp (LipschitzWith.prod_fst (α := α) (β := β))
  have h2 : LipschitzWith 1 (fun p : α × β => noveltyScore T p.2) := by
    simpa using (noveltyScore_lipschitz T).comp (LipschitzWith.prod_snd (α := α) (β := β))
  simpa [compNovelty] using h1.min h2

/-- The compositional novelty never exceeds the novelty of the first component. -/
theorem compNovelty_le_left (S : Set α) (T : Set β) (p : α × β) :
    compNovelty S T p ≤ noveltyScore S p.1 := min_le_left _ _

/-- The compositional novelty never exceeds the novelty of the second component. -/
theorem compNovelty_le_right (S : Set α) (T : Set β) (p : α × β) :
    compNovelty S T p ≤ noveltyScore T p.2 := min_le_right _ _

/-! ## Multi-scale novelty filtrations -/

/-- The **novelty set** at threshold `δ`: all points certified `δ`-novel against `S`. -/
def noveltySet (δ : ℝ) (S : Set α) : Set α := {x | IsNovel δ S x}

-- !-- `δ₁ ≤ δ₂ ≤ dist x s` for every `s ∈ S`. -- !--
/-- **Filtration in the threshold.** Higher novelty demands are harder to meet, so the
novelty sets form a decreasing chain in `δ`: `noveltySet δ₂ S ⊆ noveltySet δ₁ S` whenever
`δ₁ ≤ δ₂`. This is the scale axis of the novelty filtration. -/
theorem noveltySet_antitone_threshold {δ₁ δ₂ : ℝ} {S : Set α} (h : δ₁ ≤ δ₂) :
    noveltySet δ₂ S ⊆ noveltySet δ₁ S := by
  intro x hx s hs
  exact le_trans h (hx s hs)

-- !-- Novelty against a larger corpus implies novelty against any subcorpus
-- (`isNovel_antitone_set`). -- !--
/-- **Filtration in the corpus.** Enlarging the corpus shrinks the novelty set:
`T ⊆ S` gives `noveltySet δ S ⊆ noveltySet δ T`. Together with
`noveltySet_antitone_threshold` this exhibits novelty as a two-parameter filtration
(a bifiltration) over `(threshold, corpus)`. -/
theorem noveltySet_antitone_corpus {δ : ℝ} {S T : Set α} (hTS : T ⊆ S) :
    noveltySet δ S ⊆ noveltySet δ T :=
  fun _ hx => isNovel_antitone_set hTS hx

-- !-- Chain both monotonicities: shrink the threshold, then shrink the corpus. -- !--
/-- **Bifiltration monotonicity.** Relaxing the threshold (`δ₁ ≤ δ₂`) *and* shrinking the
corpus (`T ⊆ S`) can only enlarge the set of certified-novel points. -/
theorem noveltySet_mono {δ₁ δ₂ : ℝ} {S T : Set α} (hδ : δ₁ ≤ δ₂) (hTS : T ⊆ S) :
    noveltySet δ₂ S ⊆ noveltySet δ₁ T :=
  fun _ hx => noveltySet_antitone_corpus hTS (noveltySet_antitone_threshold hδ hx)

end CertifiedNovelty