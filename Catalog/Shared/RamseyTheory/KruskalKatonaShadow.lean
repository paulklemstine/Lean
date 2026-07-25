import Mathlib

/-! # Kruskal–Katona: single-shadow corollary and a graph interpretation

From Mathlib's `Finset.kruskal_katona_lovasz_form` we extract the most-used
practical consequence of the **Kruskal–Katona theorem**: a lower bound on the
size of the (single) shadow of a uniform set family.

* `shadow_card_ge`: if a family `𝒜` of `r`-subsets of `Fin n` has at least
  `C(k, r)` members (`r ≤ k ≤ n`), then its shadow has at least `C(k, r-1)`
  members.
* `graph_edges_cover_vertices`: the `r = 2` instance read graph-theoretically —
  a (simple) graph with at least `C(k,2)` edges touches at least `k` vertices,
  i.e. has at least `k` non-isolated vertices. This ties Kruskal–Katona back to
  the Turán/extremal theme: edge density forces vertex spread.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The Lovász form of Kruskal–Katona is stated for the
  `i`-th iterated shadow. We conjecture the `i = 1` case is the clean and most
  applicable statement, and that for `r = 2` (graphs) it specializes to a
  vertex-cover lower bound `|∂E| ≥ k` whenever `|E| ≥ C(k,2)`.
Experiment (Experimenter): `kruskal_katona_lovasz_form` with `i := 1` gives
  `k.choose (r-1) ≤ #(∂^[1] 𝒜)`; `∂^[1] = ∂` via `Function.iterate_one`, closed
  by `simpa`. For graphs, `r := 2` gives `k.choose 1 = k ≤ #(∂ E)`, and `∂` of a
  family of 2-sets is exactly its set of covered vertices (as singletons).
Analysis (Analyst): The shadow of `2`-sets is the "boundary" of an edge family,
  i.e. its incident vertices; Kruskal–Katona therefore quantifies the classical
  fact that few vertices cannot carry many edges. The bound is tight at the
  clique `K_k`, which has exactly `C(k,2)` edges on `k` vertices.
Critique (Critic): `shadow_card_ge` requires `1 ≤ r ≤ k ≤ n` and the family to
  be `r`-uniform; these hypotheses are load-bearing (the empty / degenerate
  cases are excluded). The proof routes through the deep Kruskal–Katona theorem,
  not `decide`/`simp` alone.
Synthesis (PI): Kruskal–Katona (iterated) ⇒ single-shadow bound ⇒ graph
  vertex-spread bound.
-/

open Finset
open scoped FinsetFamily

/-- **Single-shadow Kruskal–Katona.** If `𝒜` is an `r`-uniform family of subsets
of `Fin n` with `C(k, r) ≤ |𝒜|` (where `1 ≤ r ≤ k ≤ n`), then its shadow `∂𝒜`
has at least `C(k, r-1)` members. -/
theorem shadow_card_ge {n r k : ℕ} {𝒜 : Finset (Finset (Fin n))}
    (hr : 1 ≤ r) (hrk : r ≤ k) (hkn : k ≤ n)
    (h𝒜 : (𝒜 : Set (Finset (Fin n))).Sized r) (hsize : k.choose r ≤ #𝒜) :
    k.choose (r - 1) ≤ #(∂ 𝒜) := by
  have := kruskal_katona_lovasz_form (i := 1) (r := r) (k := k) (n := n) hr hrk hkn h𝒜 hsize
  simpa using this

/-- **Graph interpretation of Kruskal–Katona (`r = 2`).** A graph on `Fin n`
given by an edge family `E` (a family of `2`-element vertex sets) with at least
`C(k, 2)` edges has a shadow (its set of covered vertices) of size at least `k`;
equivalently, `k` edges' worth of `C(k,2)` cannot be packed onto fewer than `k`
vertices. -/
theorem graph_edges_cover_vertices {n k : ℕ} {E : Finset (Finset (Fin n))}
    (hk2 : 2 ≤ k) (hkn : k ≤ n)
    (hE : (E : Set (Finset (Fin n))).Sized 2) (hsize : k.choose 2 ≤ #E) :
    k ≤ #(∂ E) := by
  have := shadow_card_ge (r := 2) (k := k) (n := n) (by norm_num) hk2 hkn hE hsize
  simpa using this