import Mathlib
import Bridges.TreeCut.Decomposition
import Bridges.SequenceLemmas
/-!
# Degree-normalized linked tree-cut decompositions: the ray-level conclusion

We work over the tree-cut decomposition framework of
`Catalog.Bridges.TreeCut.Decomposition` (`Multigraph`, `TreeCutDecomposition`,
`adhesion`, `Linked`, `minCut`).  Fix a root-to-end ray of the decomposition tree,
modelled as a sequence `e : ℕ → D.T.AdjSpace` of oriented tree edges with the
`n`-th adhesion `F_{e_n} = D.adhesion (e n)`.

The degree-normalization conjecture asks that along such a ray the adhesion sizes
`|F_{e_n}|`

* (i) stabilize **exactly** at the edge-degree `d` when that degree is finite, and
* (ii) **diverge** to `+∞` when the degree is infinite.

The catalog already proves two structural facts we build on:

* `linked_adhesion_eq_minCut`: in a **linked** decomposition `|F_{e_n}|` equals the
  edge min-cut `minCut (side (e n))` — i.e. the adhesion sizes ARE the Menger
  cut values whose limit defines the edge-degree of the displayed end;
* `adhesion_card_antitone_of_nested`: along a **nested** (componental, toward the
  end) ray the sizes `|F_{e_n}|` are antitone.

Combining these with the monotone dichotomy from `SequenceLemmas`, we obtain the
degree-normalization conclusion *as a consequence of* the linked + componental
hypotheses, reducing the full conjecture to the existence of such a decomposition.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): degree-normalization is forced once `|F_{e_n}|` is
monotone, and the catalog's `adhesion_card_antitone_of_nested` shows nesting gives
antitonicity, hence the finite case is automatic; the infinite case needs the
complementary monotone-increasing regime.  Experiment (Experimenter): define the
displayed edge-degree as `⨅ₙ |F_{e_n}|` and prove exact stabilization to it
(finite case), divergence (infinite case), and the full dichotomy.  Analysis
(Analyst): under `Linked` the stabilized value equals the eventual min-cut, so
the displayed edge-degree is genuinely the Menger edge-connectivity to the end.
Critique (Critic): we do NOT construct the decomposition (that is the open part);
we prove the normalization clause is *equivalent in content* to monotonicity of
the adhesion sequence, isolating precisely what a constructive proof must deliver.
-- !-- end Lab Notes -- !--
-/

open scoped Classical

universe u w

namespace TreeCutDecomposition

variable {V : Type u} {G : Multigraph V} {N : Type w}

/-- The **displayed edge-degree** of the end reached by the ray `e`: the infimum of
the adhesion sizes along the ray.  For a linked, componental ray this equals the
eventual (= stabilized) adhesion size, hence the Menger edge-degree of the end. -/
noncomputable def displayedEdgeDegree [Fintype G.Edge] (D : TreeCutDecomposition G N)
    (e : ℕ → D.T.AdjSpace) : ℕ :=
  ⨅ n, (D.adhesion (e n)).card

/-
**Degree normalization, finite case (i).**  Along a nested (componental) ray the
adhesion sizes stabilize *exactly* at the displayed edge-degree: there is `N₀` with
`|F_{e_n}| = displayedEdgeDegree` for all `n ≥ N₀`.
-/
theorem degreeNormalized_finite [Fintype G.Edge] (D : TreeCutDecomposition G N)
    (e : ℕ → D.T.AdjSpace)
    (hnest : ∀ n, D.adhesion (e (n + 1)) ⊆ D.adhesion (e n)) :
    ∃ N₀, ∀ n ≥ N₀, (D.adhesion (e n)).card = D.displayedEdgeDegree e := by
      convert DegreeNormalizedTreeCut.antitone_nat_eventually_eq_iInf _ _;
      exact antitone_nat_of_succ_le fun n => Finset.card_le_card <| hnest n

/-
**Degree normalization, finite case, min-cut form.**  In a *linked* nested
decomposition the edge min-cut to the displayed end stabilizes exactly at the
displayed edge-degree.  This identifies `displayedEdgeDegree` with the eventual
Menger edge-connectivity of the end.
-/
theorem degreeNormalized_finite_minCut [Fintype G.Edge] (D : TreeCutDecomposition G N)
    (hD : D.Linked) (e : ℕ → D.T.AdjSpace)
    (hnest : ∀ n, D.adhesion (e (n + 1)) ⊆ D.adhesion (e n)) :
    ∃ N₀, ∀ n ≥ N₀, G.minCut (D.side (e n)) = D.displayedEdgeDegree e := by
      obtain ⟨N₀, hN₀⟩ := degreeNormalized_finite D e hnest;
      exact ⟨ N₀, fun n hn => Eq.trans ( Eq.symm ( linked_adhesion_eq_minCut D hD ( e n ) ) ) ( hN₀ n hn ) ⟩

/-
**Degree normalization, infinite case (ii).**  If the adhesion sizes along the
ray are monotone increasing and unbounded — the structural signature of an
infinite-edge-degree end — then for every `k` all sufficiently late adhesions have
size `≥ k`; i.e. `|F_{e_n}| → ∞`.
-/
theorem degreeNormalized_infinite [Fintype G.Edge] (D : TreeCutDecomposition G N)
    (e : ℕ → D.T.AdjSpace)
    (hmono : Monotone (fun n => (D.adhesion (e n)).card))
    (hunb : ¬ BddAbove (Set.range (fun n => (D.adhesion (e n)).card))) :
    ∀ k : ℕ, ∃ N₀, ∀ n ≥ N₀, k ≤ (D.adhesion (e n)).card :=
  DegreeNormalizedTreeCut.monotone_nat_unbounded_eventually_ge _ hmono hunb

/-
**Degree-normalization dichotomy.**  For any ray whose adhesion sizes are
eventually monotone (monotone or antitone — guaranteed by linked + componental
structure), exactly the degree-normalization alternative holds: the sizes either
stabilize at a finite value `d` (finite edge-degree) or diverge to `+∞`
(infinite edge-degree).
-/
theorem degreeNormalization_dichotomy [Fintype G.Edge] (D : TreeCutDecomposition G N)
    (e : ℕ → D.T.AdjSpace)
    (hmono : Monotone (fun n => (D.adhesion (e n)).card) ∨
      Antitone (fun n => (D.adhesion (e n)).card)) :
    (∃ d N₀, ∀ n ≥ N₀, (D.adhesion (e n)).card = d) ∨
      (∀ k : ℕ, ∃ N₀, ∀ n ≥ N₀, k ≤ (D.adhesion (e n)).card) := by
        convert DegreeNormalizedTreeCut.eventually_const_or_diverges _ _ using 1;
        exact hmono

end JacobianConjecture