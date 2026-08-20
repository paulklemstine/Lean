import Geometry.CorpusBettiExtremal

/-!
# The conformality obstruction is a hierarchy, not a single exception

`Shared.TheoremNetworkTopology` established the *conformality criterion*: the higher-order
co-citation complex of a corpus equals the flag (clique) complex of its pairwise
co-citation graph exactly when every clique of that graph has one common witnessing
document.  The smallest failure exhibited there was the three-theorem corpus
`{{0,1}, {0,2}, {1,2}}`: three pairwise co-citations without a triple co-citation.

The research programme reads that example as *the* exact obstruction.  This file shows
that reading is too optimistic: the obstruction is **stratified**.  For every level `m`
there is a corpus in which *every* clique of at most `m` theorems has a common document,
and yet conformality fails — the failure has simply been pushed up one dimension.  Hence
no bounded amount of local checking can certify conformality, and any probabilistic
"conformality threshold" must be indexed by the level at which witnesses are demanded.

## Contents

* `LocallyConformal C m` — every clique with at most `m` theorems has a common document.
* `conformal_iff_locallyConformal_card` — conformality is local conformality at level `n`.
* `coCitationGraph_skeletonCorpus` — the two-section of the `d`-uniform design is the
  complete graph as soon as `2 ≤ d ≤ n`: pairwise data sees nothing at all.
* `locallyConformal_skeletonCorpus` / `not_locallyConformal_skeletonCorpus_succ` —
  the design is locally conformal at level `d` and *not* at level `d + 1`.
* `strict_hierarchy_of_local_conformality` — **the hierarchy theorem**: for every `m ≥ 2`
  there is a corpus that is locally conformal at level `m` but not at level `m + 1`, hence
  not conformal.  The three-theorem example is the case `m = 2`.
* `conformal_skeletonCorpus_iff` — **sharp document-size threshold**: for `2 ≤ d ≤ n` the
  design corpus is conformal if and only if `d = n`.  Conformality of the maximally
  symmetric corpus is an all-or-nothing event at document size `n`.
* `conformal_iff_of_bounded` — for a `d`-bounded corpus, conformality splits exactly into
  a clique-number condition (`ω ≤ d`) and local conformality at level `d`.
* `skeletonCorpus_strict_loss` — the flag complex strictly overshoots the true complex for
  every `2 ≤ d < n`, generalising `triangleBoundary_strict_loss`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) local conformality at any fixed level is strictly weaker
than conformality; (2) the design corpus of document size `d` is exactly the extremal
witness, being locally conformal precisely up to level `d`; (3) for a `d`-bounded corpus
conformality is equivalent to the clique number of the two-section being at most `d`
together with local conformality at level `d`; (4) the pairwise graph of a `d`-uniform
design with `d ≥ 2` carries no information whatsoever.

Experiment (Experimenter): the corpora `skeletonCorpus (Fin (m+1)) m` were examined for
`m = 2, 3, 4`.  For `m = 2` this is exactly the catalogued three-theorem boundary corpus
`{{0,1},{0,2},{1,2}}`.  In each case the two-section is complete, every clique of at most
`m` theorems is covered by a document, and the full vertex set is a clique with no
witness.  The number of cliques lacking a witness is `1` in each case, so these are
minimal obstructions at their level.

Analysis (Analyst): hypotheses (1)-(4) all survive as theorems.  The failure mode is
uniform: the design corpus of document size `d` realises the complete graph as its
two-section while its complex is only the `(d-1)`-skeleton, so the discrepancy is exactly
the set of faces of more than `d` vertices.  This also explains why the Betti profile of
the previous file is extremal for exactly these corpora — maximal non-conformality and
maximal homology are two views of the same object.

Critique (Critic): "the smallest obstruction" is a correct description of the three-theorem
example only within level `2`; the theorems below show the phrase cannot be promoted to a
global statement.  The threshold `conformal_skeletonCorpus_iff` is proved only for the
symmetric design; general corpora may become conformal for many reasons, so this is a
statement about the extremal family and not about arbitrary random corpora.  The hypothesis
`2 ≤ d` is necessary: for `d ≤ 1` the two-section has no edges and conformality holds
trivially.

Synthesis (Principal Investigator): conformality is not a single event but a filtration of
events indexed by witness level, and document size is the parameter that decides where the
filtration stops.  A probabilistic conformality threshold must therefore be stated for a
level, or equivalently for the clique number of the two-section relative to the maximal
document size.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open Classical Finset
open TheoremNetworkTopology CorpusBettiExtremal

namespace CorpusConformalityHierarchy

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Local conformality -/

/-- `LocallyConformal C m`: every clique of at most `m` theorems in the pairwise
co-citation graph is covered by a single document. -/
def LocallyConformal (C : Corpus V) (m : ℕ) : Prop :=
  ∀ S : Finset V, S.card ≤ m → (coCitationGraph C).IsClique (↑S : Set V) → ∃ W ∈ C, S ⊆ W

omit [Fintype V] [DecidableEq V] in
theorem locallyConformal_of_conformal {C : Corpus V} (h : Conformal C) (m : ℕ) :
    LocallyConformal C m := fun S _ hS => h S hS

omit [Fintype V] [DecidableEq V] in
theorem locallyConformal_mono {C : Corpus V} {m m' : ℕ} (hmm : m ≤ m')
    (h : LocallyConformal C m') : LocallyConformal C m :=
  fun S hS hclique => h S (hS.trans hmm) hclique

omit [DecidableEq V] in
/-- Conformality is exactly local conformality at the level of the whole theorem set. -/
theorem conformal_iff_locallyConformal_card (C : Corpus V) :
    Conformal C ↔ LocallyConformal C (Fintype.card V) := by
  refine ⟨fun h => locallyConformal_of_conformal h _, fun h S hS => ?_⟩
  exact h S (by simpa using Finset.card_le_univ S) hS

/-! ## The design corpus is maximally non-conformal -/

/-- With documents of size at least two, the pairwise co-citation graph of the design is
complete: the two-section retains no information about the design. -/
theorem coCitationGraph_skeletonCorpus {d : ℕ} (hd : 2 ≤ d) (hdn : d ≤ Fintype.card V) :
    coCitationGraph (skeletonCorpus V d) = ⊤ := by
  ext x y
  simp only [coCitationGraph, SimpleGraph.top_adj]
  refine ⟨fun h => h.1, fun hxy => ⟨hxy, ?_⟩⟩
  have hcard : ({x, y} : Finset V).card ≤ d := by
    rw [Finset.card_insert_of_notMem (by simpa using hxy), Finset.card_singleton]
    omega
  obtain ⟨W, hsub, hWcard⟩ := Finset.exists_superset_card_eq hcard hdn
  exact ⟨W, Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, hWcard⟩,
    hsub (by simp), hsub (by simp)⟩

/-- The design corpus is locally conformal at its own document size: every set of at most
`d` theorems — clique or not — is covered by a document. -/
theorem locallyConformal_skeletonCorpus {d : ℕ} (hdn : d ≤ Fintype.card V) :
    LocallyConformal (skeletonCorpus V d) d := by
  intro S hS _
  obtain ⟨W, hsub, hWcard⟩ := Finset.exists_superset_card_eq hS hdn
  exact ⟨W, Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, hWcard⟩, hsub⟩

/-- ... and it fails to be locally conformal one level higher. -/
theorem not_locallyConformal_skeletonCorpus_succ {d : ℕ} (hd : 2 ≤ d)
    (hdn : d + 1 ≤ Fintype.card V) :
    ¬ LocallyConformal (skeletonCorpus V d) (d + 1) := by
  intro hloc
  obtain ⟨S, -, hScard⟩ :=
    Finset.exists_superset_card_eq (s := (∅ : Finset V)) (by simp) hdn
  have hclique : (coCitationGraph (skeletonCorpus V d)).IsClique (↑S : Set V) := by
    rw [coCitationGraph_skeletonCorpus hd (by omega)]
    intro a _ b _ hab
    simpa using hab
  obtain ⟨W, hW, hSW⟩ := hloc S (le_of_eq hScard) hclique
  have := Finset.card_le_card hSW
  rw [hScard, (Finset.mem_powersetCard.mp hW).2] at this
  omega

/-- **Hierarchy theorem.** For every level `m ≥ 2` there is a theorem corpus in which every
clique of at most `m` theorems has a common witnessing document, while some clique of
`m + 1` theorems has none.  Consequently no fixed level of local witness checking implies
conformality, and the catalogued three-theorem boundary corpus is only the case `m = 2` of
an infinite strictly increasing family of obstructions. -/
theorem strict_hierarchy_of_local_conformality (m : ℕ) (hm : 2 ≤ m) :
    ∃ C : Corpus (Fin (m + 1)),
      LocallyConformal C m ∧ ¬ LocallyConformal C (m + 1) ∧ ¬ Conformal C := by
  have hcard : Fintype.card (Fin (m + 1)) = m + 1 := Fintype.card_fin _
  refine ⟨skeletonCorpus (Fin (m + 1)) m, ?_, ?_, ?_⟩
  · exact locallyConformal_skeletonCorpus (by omega)
  · exact not_locallyConformal_skeletonCorpus_succ hm (by omega)
  · intro hconf
    exact not_locallyConformal_skeletonCorpus_succ hm (by omega)
      (locallyConformal_of_conformal hconf (m + 1))

/-! ## The sharp document-size threshold for the design -/

/-- **Sharp threshold.** For `2 ≤ d ≤ n` the complete `d`-uniform design is conformal if and
only if its documents already cover the whole theorem set, i.e. `d = n`.  Conformality of
the extremal corpus is an all-or-nothing event located exactly at document size `n`. -/
theorem conformal_skeletonCorpus_iff {d : ℕ} (hd : 2 ≤ d) (hdn : d ≤ Fintype.card V) :
    Conformal (skeletonCorpus V d) ↔ Fintype.card V ≤ d := by
  constructor
  · intro hconf
    by_contra hlt
    push_neg at hlt
    exact not_locallyConformal_skeletonCorpus_succ hd (by omega)
      (locallyConformal_of_conformal hconf (d + 1))
  · intro hn S _
    have hdeq : d = Fintype.card V := le_antisymm hdn hn
    refine ⟨Finset.univ, ?_, Finset.subset_univ _⟩
    exact Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, by
      simpa [Finset.card_univ] using hdeq.symm⟩

omit [Fintype V] [DecidableEq V] in
/-- **Structure of conformality for bounded corpora.**  If every document cites at most `d`
theorems, conformality is equivalent to the conjunction of a clique-number condition and
local conformality at level `d`.  The clique-number condition is the genuinely global part:
local checking alone can never supply it, by the hierarchy theorem. -/
theorem conformal_iff_of_bounded {C : Corpus V} {d : ℕ} (hC : BoundedCorpus C d) :
    Conformal C ↔
      ((∀ S : Finset V, (coCitationGraph C).IsClique (↑S : Set V) → S.card ≤ d)
        ∧ LocallyConformal C d) := by
  constructor
  · intro hconf
    refine ⟨fun S hS => ?_, locallyConformal_of_conformal hconf d⟩
    obtain ⟨W, hW, hSW⟩ := hconf S hS
    exact (Finset.card_le_card hSW).trans (hC W hW)
  · rintro ⟨homega, hloc⟩ S hS
    exact hloc S (homega S hS) hS

/-! ## Strict loss of information in the pairwise projection -/

/-- **Generalised strict loss.**  Whenever documents have size `2 ≤ d < n`, the flag complex
of the pairwise co-citation graph strictly contains the true co-citation complex of the
design.  For `(d, n) = (2, 3)` this is the catalogued three-theorem boundary example. -/
theorem skeletonCorpus_strict_loss {d : ℕ} (hd : 2 ≤ d) (hdn : d < Fintype.card V) :
    coCitationComplex (skeletonCorpus V d) ⊂
      VRCliqueExtremalDeepening.cliqueFamily (coCitationGraph (skeletonCorpus V d)) := by
  refine Finset.ssubset_iff_subset_ne.mpr
    ⟨coCitationComplex_subset_cliqueFamily _, ?_⟩
  intro heq
  have hconf : Conformal (skeletonCorpus V d) :=
    (coCitationComplex_eq_cliqueFamily_iff (skeletonCorpus V d)).mp heq
  rw [conformal_skeletonCorpus_iff hd (le_of_lt hdn)] at hconf
  omega

/-- Quantitative form of the loss: the flag complex has `2^n` faces while the true complex
has only `∑_{q ≤ d} C(n, q)` of them, so the pairwise projection invents
`2^n - ∑_{q ≤ d} C(n, q)` faces. -/
theorem card_cliqueFamily_skeletonCorpus {d : ℕ} (hd : 2 ≤ d) (hdn : d ≤ Fintype.card V) :
    (VRCliqueExtremalDeepening.cliqueFamily
      (coCitationGraph (skeletonCorpus V d))).card = 2 ^ Fintype.card V := by
  rw [coCitationGraph_skeletonCorpus hd hdn, VRCliqueExtremalDeepening.cliqueFamily_top,
    Finset.card_powerset, Finset.card_univ]

/-- The base case of the hierarchy really is the catalogued three-theorem boundary corpus:
the `2`-uniform design on three theorems is `{{0,1}, {0,2}, {1,2}}`. -/
theorem skeletonCorpus_two_eq_triangleBoundary :
    skeletonCorpus (Fin 3) 2 = triangleBoundaryCorpus := by
  decide

end CorpusConformalityHierarchy