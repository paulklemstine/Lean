import Mathlib

/-!
# The Brualdi–Quinn–Massey strong chromatic index conjecture for bipartite graphs

For a bipartite graph `G` with partite sets `A` and `B`, the **strong chromatic
index** `χ'_s(G)` is the least number of colours in a *strong edge colouring*: a
proper edge colouring in which every colour class is an *induced matching*
(equivalently, two edges receive the same colour only if they are at distance at
least two — they are non-adjacent and no edge joins their endpoints).

The Brualdi–Quinn–Massey (BQM) conjecture states
`χ'_s(G) ≤ Δ_A · Δ_B`,
where `Δ_A` (resp. `Δ_B`) is the maximum degree of a vertex in `A` (resp. `B`).
It is open in general; the current best general bound is `1.676 · Δ_A · Δ_B`.

This file develops a self-contained formalisation:

* `conflictGraph` — the conflict graph on the edge set: two distinct edges are
  adjacent iff they cannot share a colour in a strong edge colouring.
* `strongChromaticIndex` — `χ'_s(G)`, defined as the chromatic number of the
  conflict graph.
* `degA_le_strongChromaticIndex` / `maxDegA_le_strongChromaticIndex` — the
  *general* lower bound `χ'_s(G) ≥ Δ_A` (and symmetrically `≥ Δ_B`): the edges at
  a single vertex form a clique in the conflict graph.
* `completeBipartite_strongChromaticIndex` — for the complete bipartite graph
  `K_{m,n}` we have `χ'_s = Δ_A · Δ_B` **exactly**, so the BQM bound is attained
  with equality and is best possible.
* `BQMConjecture` — the formal statement of the open conjecture, together with
  `completeBipartite_satisfies_BQM`, proving it for the extremal complete
  bipartite family.

-- !-- Lab Notes -- !--
-- !-- Hypothesis (Hypothesizer): The BQM product bound `Δ_A · Δ_B`, conjectured
--     for all bipartite graphs, is *tight*: the complete bipartite graph
--     `K_{m,n}` attains it with equality, `χ'_s(K_{m,n}) = m·n = Δ_A·Δ_B`.
--     A surprising secondary hypothesis: the lower bound `χ'_s ≥ Δ_A` already
--     holds for *every* bipartite graph (not just complete), because the edges
--     at one vertex are pairwise conflicting. -- !--
-- !-- Experiment (Experimenter): Formalised the conflict graph as a SimpleGraph
--     on the edge subtype, defined `χ'_s` via Mathlib's `chromaticNumber`, and
--     proved (a) the star-clique lower bound via `IsClique.card_le_chromaticNumber`
--     and (b) `conflictGraph (K_{m,n}) = ⊤`, whence `chromaticNumber_top` gives
--     `χ'_s = card(edges) = card A * card B`. -- !--
-- !-- Analysis (Analyst): The complete bipartite case SURVIVED with equality.
--     The general upper bound `χ'_s ≤ Δ_A·Δ_B` is genuinely open and was NOT
--     attempted as a theorem (it would be false to claim). The lower bound is
--     "true and easy"; the equality for `K_{m,n}` is "true and is the extremal
--     witness that the conjecture cannot be improved below `Δ_A·Δ_B`". -- !--
-- !-- Critique (Critic): Guarded the degree computation by `[Nonempty A]`,
--     `[Nonempty B]` (otherwise `Δ_A` collapses to `0` over an empty `sup`).
--     Verified the main equality is not vacuous: it equates two genuinely
--     computed quantities and uses `chromaticNumber_top` (not `rfl`/`decide`). -- !--
-- !-- Synthesis (PI): The deliverable is a tightness theorem for BQM plus a
--     universal lower bound, framing exactly where the open difficulty lives:
--     the gap between `Δ_A·Δ_B` (lower-bound-matching only at the extreme) and
--     a general upper bound. -- !--
-/

namespace StrongChromaticBipartite

open Finset SimpleGraph

variable {A B : Type*} [Fintype A] [Fintype B]

/-- The edges of the bipartite graph with adjacency `adj : A → B → Bool`:
those pairs `(a, b)` with `adj a b = true`. -/
abbrev Edge (adj : A → B → Bool) := {p : A × B // adj p.1 p.2 = true}

/-- Two distinct edges *conflict* (cannot share a colour in a strong edge
colouring) iff they share an endpoint, or an edge of `G` joins their endpoints. -/
def Conflict (adj : A → B → Bool) (e f : Edge adj) : Prop :=
  e ≠ f ∧
    (e.val.1 = f.val.1 ∨ e.val.2 = f.val.2 ∨
      adj e.val.1 f.val.2 = true ∨ adj f.val.1 e.val.2 = true)

/-- The conflict graph: vertices are edges of `G`, adjacency is `Conflict`. -/
def conflictGraph (adj : A → B → Bool) : SimpleGraph (Edge adj) where
  Adj := Conflict adj
  symm := by
    rintro e f ⟨hne, h⟩
    refine ⟨hne.symm, ?_⟩
    rcases h with h | h | h | h
    · exact Or.inl h.symm
    · exact Or.inr (Or.inl h.symm)
    · exact Or.inr (Or.inr (Or.inr h))
    · exact Or.inr (Or.inr (Or.inl h))
  loopless := ⟨fun _ h => h.1 rfl⟩

/-- The **strong chromatic index** `χ'_s(G)`: the chromatic number of the
conflict graph. -/
noncomputable def strongChromaticIndex (adj : A → B → Bool) : ℕ∞ :=
  (conflictGraph adj).chromaticNumber

/-- The degree of `a ∈ A`: the number of `b` with `adj a b`. -/
def degA (adj : A → B → Bool) (a : A) : ℕ :=
  (univ.filter (fun b => adj a b = true)).card

/-- The degree of `b ∈ B`. -/
def degB (adj : A → B → Bool) (b : B) : ℕ :=
  (univ.filter (fun a => adj a b = true)).card

/-- `Δ_A`, the maximum degree among vertices of `A`. -/
def maxDegA (adj : A → B → Bool) : ℕ := univ.sup (degA adj)

/-- `Δ_B`, the maximum degree among vertices of `B`. -/
def maxDegB (adj : A → B → Bool) : ℕ := univ.sup (degB adj)

/-- The star at `a ∈ A`: the finset of edges whose `A`-endpoint is `a`. -/
def starA [DecidableEq A] (adj : A → B → Bool) (a : A) : Finset (Edge adj) :=
  univ.filter (fun e => e.val.1 = a)

/-- The star at `a` is a clique in the conflict graph (all such edges share `a`). -/
theorem starA_isClique [DecidableEq A] (adj : A → B → Bool) (a : A) :
    (conflictGraph adj).IsClique (starA adj a) := by
  intro e he f hf hne
  exact ⟨hne, Or.inl <| by unfold starA at he hf; aesop⟩

/-- The star at `a` has cardinality `degA adj a`. -/
theorem starA_card [DecidableEq A] (adj : A → B → Bool) (a : A) :
    (starA adj a).card = degA adj a := by
  refine Finset.card_bij (fun e _ => e.val.2) ?_ ?_ ?_
  · unfold starA; grind
  · unfold starA at *; aesop
  · simp +decide [starA]

/-- **General lower bound (per vertex):** for every `a ∈ A`,
`degA adj a ≤ χ'_s(G)`. -/
theorem degA_le_strongChromaticIndex [DecidableEq A] (adj : A → B → Bool) (a : A) :
    (degA adj a : ℕ∞) ≤ strongChromaticIndex adj := by
  convert (starA_isClique adj a).card_le_chromaticNumber using 1
  rw [starA_card]

/-- **General lower bound:** `χ'_s(G) ≥ Δ_A`. Holds for *every* bipartite graph. -/
theorem maxDegA_le_strongChromaticIndex [DecidableEq A] (adj : A → B → Bool) :
    (maxDegA adj : ℕ∞) ≤ strongChromaticIndex adj := by
  by_contra! h_contra
  -- Let `a` be a vertex in `A` with degree `maxDegA adj`.
  obtain ⟨a, ha⟩ : ∃ a : A, degA adj a = maxDegA adj := by
    by_cases hA : Nonempty A
    · exact Finset.exists_max_image Finset.univ (fun a => degA adj a)
        ⟨hA.some, Finset.mem_univ _⟩ |> fun ⟨a, ha⟩ =>
          ⟨a, le_antisymm (Finset.le_sup (f := degA adj) (Finset.mem_univ a))
            (Finset.sup_le fun x _ => ha.2 x (Finset.mem_univ x))⟩
    · simp_all +decide [maxDegA]
  exact h_contra.not_ge (ha ▸ degA_le_strongChromaticIndex adj a)

/-! ### The complete bipartite graph `K_{m,n}` -/

/-- The adjacency of the complete bipartite graph. -/
def completeAdj (A B : Type*) : A → B → Bool := fun _ _ => true

omit [Fintype A] [Fintype B] in
/-- In the complete bipartite graph any two distinct edges conflict, so the
conflict graph is the complete graph on the edge set. -/
theorem conflictGraph_complete :
    conflictGraph (completeAdj A B) = (⊤ : SimpleGraph (Edge (completeAdj A B))) := by
  ext e f
  simp +decide [conflictGraph, Conflict, completeAdj]

/-- The edge set of `K_{m,n}` is in bijection with `A × B`, so it has
`card A * card B` elements. -/
theorem card_edge_complete :
    Fintype.card (Edge (completeAdj A B)) = Fintype.card A * Fintype.card B := by
  simp [Edge, completeAdj]

/-- In `K_{m,n}` every vertex of `A` has degree `card B`, so `Δ_A = card B`. -/
theorem maxDegA_complete [Nonempty A] :
    maxDegA (completeAdj A B) = Fintype.card B := by
  refine le_antisymm ?_ ?_
  · exact Finset.sup_le fun x _ => Finset.card_le_univ _
  · refine le_trans ?_ (Finset.le_sup <| Finset.mem_univ <| Classical.arbitrary A)
    unfold degA completeAdj; simp +decide

/-- In `K_{m,n}` every vertex of `B` has degree `card A`, so `Δ_B = card A`. -/
theorem maxDegB_complete [Nonempty B] :
    maxDegB (completeAdj A B) = Fintype.card A := by
  refine le_antisymm (Finset.sup_le fun b _ => ?_) ?_
  · exact Finset.card_le_univ _
  · refine le_trans ?_ (Finset.le_sup (f := degB (completeAdj A B))
      (Finset.mem_univ (Classical.arbitrary B)))
    unfold degB; simp +decide [completeAdj]

/-- **Main theorem (BQM tightness).** For the complete bipartite graph `K_{m,n}`,
`χ'_s = Δ_A · Δ_B`, with both sides equal to `m · n`. Hence the BQM bound is
attained with equality and cannot be improved. -/
theorem completeBipartite_strongChromaticIndex [Nonempty A] [Nonempty B] :
    strongChromaticIndex (completeAdj A B)
      = ((maxDegA (completeAdj A B) * maxDegB (completeAdj A B) : ℕ) : ℕ∞) := by
  unfold strongChromaticIndex
  rw [conflictGraph_complete, SimpleGraph.chromaticNumber_top]
  rw [maxDegA_complete, maxDegB_complete]
  rw [mul_comm, card_edge_complete]

/-! ### The conjecture -/

/-- The **Brualdi–Quinn–Massey conjecture** (open in general): for every finite
bipartite graph, `χ'_s(G) ≤ Δ_A · Δ_B`. -/
def BQMConjecture : Prop :=
  ∀ {A B : Type*} [Fintype A] [Fintype B] (adj : A → B → Bool),
    strongChromaticIndex adj ≤ ((maxDegA adj * maxDegB adj : ℕ) : ℕ∞)

/-- The complete bipartite family satisfies the BQM bound (with equality). -/
theorem completeBipartite_satisfies_BQM [Nonempty A] [Nonempty B] :
    strongChromaticIndex (completeAdj A B)
      ≤ ((maxDegA (completeAdj A B) * maxDegB (completeAdj A B) : ℕ) : ℕ∞) :=
  le_of_eq completeBipartite_strongChromaticIndex

end StrongChromaticBipartite