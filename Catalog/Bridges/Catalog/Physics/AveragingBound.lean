/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# An averaging / double-counting bound for cubic multigraphs

This file develops, from first principles, the double-counting ("averaging") argument that
underlies existence results of the form *"some member of a finite family is good on at least the
average number of vertices"*.

The setting is a **cubic multigraph**: a finite vertex set `Vs`, a finite edge set `Es`, and an
incidence multiplicity `inc v e` (a natural number; a loop at `v` contributes `2`), subject to two
local conditions:

* every vertex is incident to exactly three edge-ends (`degree_three`);
* every edge has exactly two ends (`edge_two`).

From these we prove:

* the **handshake identity** `∑_v deg v = 2 * |Es|` (`CubicMultigraph.handshake`);
* the **cubic identity** `∑_v deg v = 3 * |Vs|` (`CubicMultigraph.sum_degree_eq_three_mul`);
* the **parity result** that `|Vs|` is even (`CubicMultigraph.card_vertices_even`);
* a bound relating the number of *distinct* incident edges to the cubic constant `3`
  (`CubicMultigraph.sum_incidentEdges_card_le`).

For a family `F` of edge-relabelling maps `f : E → E` we define when a vertex is *good* for `f`
(`IsGoodVertex`): its three incident edges are carried by `f` onto the incident edges of some
vertex.  We then prove:

* the **double-counting identity** exchanging the order of summation between family members and
  vertices (`CubicMultigraph.double_count`);
* a **pigeonhole/averaging lemma** that some member of a nonempty family attains at least the
  average value (`CubicMultigraph.exists_ge_average`);
* the **main theorem** `exists_coloring_ge_frac_with_family`, obtained by combining the two:
  some `f ∈ F` is good on at least the family-average number of good vertex-coverages.

No result assumes the conclusion it is establishing; the averaging bound is built purely from the
double-counting identity and the pigeonhole principle.
-/

open Finset

open scoped BigOperators Classical

namespace AveragingBound

/-- A **cubic multigraph**: a finite vertex set `Vs`, a finite edge set `Es`, and an incidence
multiplicity `inc v e`.  Every vertex is incident to exactly three edge-ends and every edge has
exactly two ends. -/
structure CubicMultigraph (V E : Type*) where
  /-- The (finite) set of vertices. -/
  Vs : Finset V
  /-- The (finite) set of edges. -/
  Es : Finset E
  /-- Incidence multiplicity: `inc v e` counts the ends of `e` at `v` (a loop contributes `2`). -/
  inc : V → E → ℕ
  /-- Every vertex is incident to exactly three edge-ends. -/
  degree_three : ∀ v ∈ Vs, ∑ e ∈ Es, inc v e = 3
  /-- Every edge has exactly two ends. -/
  edge_two : ∀ e ∈ Es, ∑ v ∈ Vs, inc v e = 2

namespace CubicMultigraph

variable {V E : Type*}

/-- The degree of a vertex: the total number of edge-ends incident to it. -/
def degree (G : CubicMultigraph V E) (v : V) : ℕ := ∑ e ∈ G.Es, G.inc v e

/-- The set of edges actually incident to `v` (with positive multiplicity). -/
def incidentEdges (G : CubicMultigraph V E) (v : V) : Finset E :=
  G.Es.filter (fun e => G.inc v e ≠ 0)

/-- **Handshake identity**: the sum of all degrees equals twice the number of edges. -/
theorem handshake (G : CubicMultigraph V E) :
    ∑ v ∈ G.Vs, G.degree v = 2 * G.Es.card := by
  convert Finset.sum_comm;
  rw [ Finset.sum_congr rfl fun e he => G.edge_two e he, Finset.sum_const, smul_eq_mul, mul_comm ]

/-- **Cubic identity**: the sum of all degrees equals three times the number of vertices. -/
theorem sum_degree_eq_three_mul (G : CubicMultigraph V E) :
    ∑ v ∈ G.Vs, G.degree v = 3 * G.Vs.card := by
  convert Finset.sum_congr rfl fun v hv => G.degree_three v hv using 1;
  rw [ Finset.sum_const, smul_eq_mul, mul_comm ]

/-- Three times the number of vertices equals twice the number of edges. -/
theorem three_mul_card_vertices (G : CubicMultigraph V E) :
    3 * G.Vs.card = 2 * G.Es.card := by
  rw [ ← G.handshake, ← G.sum_degree_eq_three_mul ]

/-- **Parity result**: a cubic multigraph has an even number of vertices. -/
theorem card_vertices_even (G : CubicMultigraph V E) : Even G.Vs.card := by
  exact even_iff_two_dvd.mpr ( Nat.dvd_of_mod_eq_zero ( by have := G.three_mul_card_vertices; have := congr_arg ( · % 2 ) this; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.mod_mod ] at this; have := Nat.mod_lt ( Finset.card G.Vs ) two_pos; interval_cases Finset.card G.Vs % 2 <;> trivial ) )

/-- The number of *distinct* edges incident to a vertex is at most its degree. -/
theorem incidentEdges_card_le_degree (G : CubicMultigraph V E) (v : V) :
    (G.incidentEdges v).card ≤ G.degree v := by
  rw [ CubicMultigraph.degree, CubicMultigraph.incidentEdges ];
  rw [ Finset.card_filter ];
  exact Finset.sum_le_sum fun e _ => by split_ifs <;> norm_num ; linarith [ Nat.pos_of_ne_zero ‹_› ] ;

/-- The total number of vertex–edge incidences (counting each incident edge once per vertex) is at
most `3 * |Vs|`; this is the origin of the cubic constant `3` in the coverage density. -/
theorem sum_incidentEdges_card_le (G : CubicMultigraph V E) :
    ∑ v ∈ G.Vs, (G.incidentEdges v).card ≤ 3 * G.Vs.card := by
  convert Finset.sum_le_sum fun v hv => G.incidentEdges_card_le_degree v using 1;
  rw [ G.sum_degree_eq_three_mul ]

/-- A vertex `v` is **good** for the edge map `f` when `f` carries the incident edges of `v` exactly
onto the incident edges of some vertex `x`. -/
def IsGoodVertex [DecidableEq E] (G : CubicMultigraph V E) (f : E → E) (v : V) : Prop :=
  ∃ x ∈ G.Vs, (G.incidentEdges v).image f = G.incidentEdges x

/-- **Double-counting identity.**  Summing, over the family `F`, the number of good vertices of each
map equals summing, over the vertices, the number of maps for which the vertex is good. -/
theorem double_count [DecidableEq E] (G : CubicMultigraph V E) (F : Finset (E → E)) :
    ∑ f ∈ F, (G.Vs.filter (fun v => G.IsGoodVertex f v)).card
      = ∑ v ∈ G.Vs, (F.filter (fun f => G.IsGoodVertex f v)).card := by
  simp +decide only [card_filter];
  exact Finset.sum_comm

/-- **Averaging / pigeonhole lemma.**  For a nonempty finite family, some member attains at least
the average value of the nonnegative quantity `w`. -/
theorem exists_ge_average {α : Type*} (F : Finset α) (hF : F.Nonempty) (w : α → ℕ) :
    ∃ f ∈ F, (∑ g ∈ F, w g : ℚ) / F.card ≤ (w f : ℚ) := by
  -- By the pigeonhole principle, there exists an element `f ∈ F` such that `w f` is at least the average value of `w` over `F`.
  have h_pigeonhole : ∃ f ∈ F, ∀ g ∈ F, w g ≤ w f := by
    exact Finset.exists_max_image _ _ hF;
  exact h_pigeonhole.imp fun f hf => ⟨ hf.1, by rw [ div_le_iff₀ ( Nat.cast_pos.mpr <| Finset.card_pos.mpr hF ) ] ; norm_cast; simpa [ mul_comm ] using Finset.sum_le_sum hf.2 ⟩

/-- **Main theorem.**  For a nonempty finite family `F` of edge maps, some `f ∈ F` is good on at
least the family-average number of good vertex-coverages, i.e.
`|{v : v good for f}| ≥ (1/|F|) · ∑_v |{g ∈ F : v good for g}|`.

The right-hand side is `(1/|F|) ∑_v p(v)` where `p(v)` is the number of family members for which `v`
is good; by `double_count` this equals `(1/|F|) ∑_{g∈F} |V(g)|`, the family average of the goodness
counts.  Thus the maximiser exceeds the average — the double-counting averaging bound. -/
theorem exists_coloring_ge_frac_with_family [DecidableEq E]
    (G : CubicMultigraph V E) (F : Finset (E → E)) (hF : F.Nonempty) :
    ∃ f ∈ F,
      (∑ v ∈ G.Vs, (F.filter (fun g => G.IsGoodVertex g v)).card : ℚ) / F.card
        ≤ (G.Vs.filter (fun v => G.IsGoodVertex f v)).card := by
  convert exists_ge_average F hF ( fun f => Finset.card ( Finset.filter ( fun v => CubicMultigraph.IsGoodVertex G f v ) G.Vs ) );
  norm_cast;
  rw [ Finset.sum_congr rfl fun x hx => Finset.card_filter _ _, Finset.sum_congr rfl fun x hx => Finset.card_filter _ _, Finset.sum_comm ]

end CubicMultigraph

end AveragingBound