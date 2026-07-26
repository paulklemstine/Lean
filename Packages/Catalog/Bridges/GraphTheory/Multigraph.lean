/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Finite Multigraphs

We define finite multigraphs with vertex set `Fin nV` and edge set `Fin nE`,
together with the notion of degree and the **Handshaking Lemma**.

## Main Definitions

* `Multigraph nV nE` : A multigraph with `nV` vertices and `nE` edges.
* `Multigraph.degree` : The degree of a vertex (counting each edge-endpoint incidence).

## Main Results

* `Multigraph.handshaking` : The sum of all vertex degrees equals `2 * nE`.
* `Multigraph.even_sum_degrees` : The sum of all vertex degrees is even.
-/

namespace Bridges

/-- A finite multigraph with vertex set `Fin nV` and edge set `Fin nE`.
Each edge has two endpoints (not necessarily distinct, allowing loops). -/
structure Multigraph (nV nE : ℕ) where
  /-- The first endpoint of each edge -/
  endpt₁ : Fin nE → Fin nV
  /-- The second endpoint of each edge -/
  endpt₂ : Fin nE → Fin nV

namespace Multigraph

variable {nV nE : ℕ} (G : Multigraph nV nE)

/-- The degree of a vertex `v`, defined as the total number of edge-endpoint
incidences at `v`. Each non-loop edge incident to `v` contributes 1; each
loop at `v` contributes 2. This is the standard multigraph degree. -/
def degree (v : Fin nV) : ℕ :=
  (Finset.univ.filter (fun e => G.endpt₁ e = v)).card +
  (Finset.univ.filter (fun e => G.endpt₂ e = v)).card

/-
**Handshaking Lemma**: The sum of all vertex degrees equals twice the number of edges.

This is one of the most fundamental results in graph theory. Each edge contributes
exactly 2 to the total degree sum (one for each endpoint).
-/
theorem handshaking : ∑ v : Fin nV, G.degree v = 2 * nE := by
  unfold Multigraph.degree;
  simp +decide only [Finset.card_filter, Finset.sum_add_distrib];
  convert congr_arg₂ ( · + · ) ( Finset.sum_comm ) ( Finset.sum_comm ) using 1;
  simp +decide [ Finset.sum_ite_eq ];
  grind +splitImp

/-
The sum of all vertex degrees is even. An immediate corollary of the Handshaking Lemma.
-/
theorem even_sum_degrees : Even (∑ v : Fin nV, G.degree v) := by
  exact G.handshaking ▸ even_two_mul _

end Multigraph
end Bridges