/-
# Extremal Graph Theory V: the triangle removal lemma, packaged and dichotomised

The **triangle removal lemma** is the graph-theoretic engine behind Roth's theorem on
3-term arithmetic progressions (the `k = 3` case of the Erdős–Turán conjecture on arithmetic
progressions, whose *quantitative* form remains a major open problem).  Mathlib proves the raw
statement `SimpleGraph.triangle_removal`.  The catalog file
`Catalog/Applications/ExtremalGraph/Roth.lean` already consumes the downstream `o(N)` Roth bound;
this file isolates the removal lemma itself in two reusable forms:

* `triangle_removal_lemma` — the textbook `∀ ε > 0, ∃ δ > 0, …` statement: a graph with fewer than
  `δ · n³` triangles can be made triangle-free by deleting fewer than `ε · n²` edges.
* `not_farFromTriangleFree_of_few_triangles` — its **contrapositive**: a graph that is `ε`-far from
  triangle-free necessarily contains `≥ triangleRemovalBound ε · n³` triangles, i.e. *cubically
  many* triangles.  Equivalently, a triangle-sparse graph is *not* far from triangle-free.

Combined with `FarFromTriangleFree.le_card_cliqueFinset` we obtain a clean **dichotomy**
(`triangle_count_dichotomy`): either a graph has cubically many triangles, or it is edge-close to
triangle-free.

CATEGORY (Menu Balance, v19a): **subtask of a famous open problem** — the triangle removal lemma
is the combinatorial core of Roth's theorem (the `3`-AP case of the Erdős–Turán conjecture on
arithmetic progressions).
-/
import Mathlib

open Finset SimpleGraph

namespace ExtremalTriangleRemoval

variable {α : Type*} [Fintype α] [DecidableEq α] {G : SimpleGraph α} [DecidableRel G.Adj] {ε : ℝ}

/-! ## The contrapositive (counting) form -/

/-- **Triangle removal, contrapositive form.** If a graph has fewer than
`triangleRemovalBound ε · n³` triangles, then it is *not* `ε`-far from triangle-free: it can be made
triangle-free by deleting fewer than `ε · n²` edges.

This is the form most directly used in density-increment arguments: a triangle-sparse graph is
edge-close to triangle-free. -/
theorem not_farFromTriangleFree_of_few_triangles
    (hG : (#(G.cliqueFinset 3) : ℝ) < triangleRemovalBound ε * (Fintype.card α : ℝ) ^ 3) :
    ¬ G.FarFromTriangleFree ε := by
  intro hfar
  obtain ⟨G', hle, _, hcard, hcf⟩ := triangle_removal hG
  have hge := hfar.le_card_sub_card hle hcf
  push_cast at hge hcard
  linarith

/-! ## The textbook `∀ ε ∃ δ` packaging -/

/-- **The triangle removal lemma.** For every `ε > 0` there is a `δ > 0` (namely
`triangleRemovalBound ε`) such that *every* finite graph `H` with fewer than `δ · n³` triangles
admits a triangle-free subgraph `H' ≤ H` obtained by deleting fewer than `ε · n²` edges. -/
theorem triangle_removal_lemma (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ {β : Type} [Fintype β] [DecidableEq β] (H : SimpleGraph β)
      [DecidableRel H.Adj],
      (#(H.cliqueFinset 3) : ℝ) < δ * (Fintype.card β : ℝ) ^ 3 →
        ∃ H' ≤ H, ∃ _ : DecidableRel H'.Adj,
          (#H.edgeFinset - #H'.edgeFinset : ℝ) < ε * (Fintype.card β : ℝ) ^ 2 ∧
            H'.CliqueFree 3 := by
  refine ⟨triangleRemovalBound ε, triangleRemovalBound_pos hε, ?_⟩
  intro β _ _ H _ h
  have := triangle_removal h
  push_cast at this ⊢
  exact this

/-! ## The dichotomy -/

/-- **Triangle-count dichotomy.** For any `ε`, a finite graph either contains at least
`triangleRemovalBound ε · n³` triangles, or it is edge-close to triangle-free (it can be made
triangle-free by deleting fewer than `ε · n²` edges).

The first branch is the quantitative supersaturation `FarFromTriangleFree.le_card_cliqueFinset`;
the second is `not_farFromTriangleFree_of_few_triangles`. There is no middle ground. -/
theorem triangle_count_dichotomy :
    (triangleRemovalBound ε * (Fintype.card α : ℝ) ^ 3 ≤ #(G.cliqueFinset 3)) ∨
      ∃ G' ≤ G, ∃ _ : DecidableRel G'.Adj,
        (#G.edgeFinset - #G'.edgeFinset : ℝ) < ε * (Fintype.card α : ℝ) ^ 2 ∧
          G'.CliqueFree 3 := by
  by_cases h : (#(G.cliqueFinset 3) : ℝ) < triangleRemovalBound ε * (Fintype.card α : ℝ) ^ 3
  · right
    have := triangle_removal h
    push_cast at this ⊢
    exact this
  · left
    push_neg at h
    exact h

end ExtremalTriangleRemoval

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  H1: `triangle_removal` (raw Mathlib form) repackages into the textbook `∀ ε > 0 ∃ δ > 0` removal
     lemma with the explicit constant `δ = triangleRemovalBound ε`.
  H2 (bold): The contrapositive — "few triangles ⇒ not ε-far from triangle-free" — is the genuinely
     useful statement and follows by contradiction against `FarFromTriangleFree.le_card_sub_card`.
  H3: Combining supersaturation (`le_card_cliqueFinset`) with H2 yields a clean dichotomy with no
     intermediate regime.

EXPERIMENT (Experimenter).
  * `not_farFromTriangleFree_of_few_triangles`: assume `FarFromTriangleFree ε`; `triangle_removal`
    produces `G' ≤ G`, triangle-free, with `#edge(G) − #edge(G') < ε·n²`, while
    `le_card_sub_card` forces `ε·n² ≤ #edge(G) − #edge(G')`.  `push_cast` aligns the ℕ/ℝ casts and
    `linarith` closes the contradiction.
  * `triangle_removal_lemma`: witness `δ = triangleRemovalBound ε > 0`; the body is `triangle_removal`
    after `push_cast` aligns `card β ^ k` casts.
  * `triangle_count_dichotomy`: `by_cases` on the triangle count threshold; one branch is removal,
    the other is `push_neg`.

ANALYSIS (Analyst).
  * KEY INSIGHT: the only friction is the ℕ-vs-ℝ casts `↑(card α ^ k)` vs `(↑(card α))^k`; a single
    `push_cast` reconciles `triangle_removal`'s statement with `FarFromTriangleFree`'s definition.
  * FAILURE NOTE: a direct `exact triangle_removal h` fails because of those cast mismatches; the
    fix is to `push_cast at` both the hypothesis and the goal first.
  * STRUCTURAL PATTERN: "asymptotic upper bound ⇒ concrete witness" via contradiction is the same
    pattern used in `Roth.lean` (`Frequently.and_eventually`); here it is `by_contra` against the
    deletion lower bound.

CRITIQUE (Critic).
  * Not trivial: `not_farFromTriangleFree_of_few_triangles` uses `by_contra`/`linarith` and a genuine
    Mathlib removal theorem; `triangle_count_dichotomy` uses `by_cases`/`push_neg`.
  * No vacuity: `triangleRemovalBound ε > 0` for `ε > 0`, so the hypotheses are satisfiable and the
    conclusions non-empty.
  * Boundary: the `∀`-form is stated at `Type` (Type 0), matching how `triangle_removal` is consumed;
    the per-graph forms work at any universe.

SYNTHESIS (Principal Investigator).
  The triangle removal lemma — the engine of Roth's theorem — is now available in textbook,
  contrapositive, and dichotomy forms, complementing the downstream Roth `o(N)` results already in
  the catalog.
-/