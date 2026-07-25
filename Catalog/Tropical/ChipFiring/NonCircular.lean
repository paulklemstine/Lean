/-
Copyright (c) 2026. All rights reserved.

# Chip-Firing Divisor Theory on Finite Simple Graphs (Non-Circular)

This file develops the elementary combinatorial foundations of chip-firing
divisor theory on finite simple graphs, with fully self-contained, non-circular
proofs.

## Main definitions

* `ChipFiring.divisorDegree` — the degree of a divisor, `∑_v D v`.
* `ChipFiring.lap` — the graph Laplacian in flow form,
    `lap f v = ∑_{w ~ v} (f v - f w)`.
* `ChipFiring.canonicalDivisor` — the canonical divisor, `K v = deg(v) - 2`.
* `ChipFiring.genus` — the (combinatorial) genus, `g = |E| - |V| + 1`.

## Main results

* `ChipFiring.deg_lap_eq_zero` — `∑_v lap f v = 0` for any `f : V → ℤ`.
* `ChipFiring.deg_canonicalDivisor_eq_two_genus_sub_two` —
    `∑_v K v = 2g - 2`.

## Design notes

All proofs are elementary and self-contained in graph combinatorics.  In
particular the Laplacian identity is proved purely by index relabeling using the
symmetry of `G.Adj`, and makes **no** reference to the canonical divisor, to
linear equivalence, or to Riemann–Roch.
-/

import Mathlib

open Finset

namespace ChipFiring

variable {V : Type*} [Fintype V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ### Definitions -/

/-- The degree of a divisor `D : V → ℤ` is the sum of its values. -/
def divisorDegree (D : V → ℤ) : ℤ := ∑ v, D v

/-- The graph Laplacian in flow form:
`lap f v = ∑_{w ~ v} (f v - f w)`. -/
def lap (f : V → ℤ) (v : V) : ℤ :=
  ∑ w ∈ G.neighborFinset v, (f v - f w)

/-- The canonical divisor `K v = deg(v) - 2`. -/
def canonicalDivisor (v : V) : ℤ := (G.degree v : ℤ) - 2

/-- The (combinatorial) genus `g = |E| - |V| + 1`. -/
def genus : ℤ := (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-! ### The Laplacian has degree zero -/

/-- Key combinatorial relabeling lemma: summing the value of `f` at the *source*
of each ordered adjacent pair equals summing it at the *target*.  This is the
heart of the degree-zero statement and uses only the symmetry of `G.Adj`. -/
lemma sum_source_eq_sum_target (f : V → ℤ) :
    (∑ v, ∑ _w ∈ G.neighborFinset v, f v)
      = ∑ v, ∑ w ∈ G.neighborFinset v, f w := by
  simp +decide only [SimpleGraph.neighborFinset_eq_filter, sum_filter];
  rw [ Finset.sum_comm ];
  simp +decide only [SimpleGraph.adj_comm]

/-- **Degree of the Laplacian is zero.**  For any `f : V → ℤ`,
`∑_v lap f v = 0`.

The proof expands `lap f v = ∑_{w ~ v} (f v - f w)`, splits the double sum into
two pieces, and shows they cancel exactly via the symmetry of `G.Adj`
(see `sum_source_eq_sum_target`). -/
theorem deg_lap_eq_zero (f : V → ℤ) :
    ∑ v, lap G f v = 0 := by
  convert sub_eq_zero.mpr ( sum_source_eq_sum_target G f ) using 1;
  simp +decide [ lap, Finset.sum_sub_distrib ]

/-! ### Degree of the canonical divisor -/

/-- **Degree of the canonical divisor equals `2g - 2`.**

The proof expands `∑_v (deg(v) - 2) = ∑_v deg(v) - 2|V| = 2|E| - 2|V|
= 2(|E| - |V| + 1) - 2 = 2g - 2`, using the handshake lemma
`SimpleGraph.sum_degrees_eq_twice_card_edges`. -/
theorem deg_canonicalDivisor_eq_two_genus_sub_two :
    ∑ v, canonicalDivisor G v = 2 * genus G - 2 := by
  unfold canonicalDivisor genus
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hdeg : ∑ v, (G.degree v : ℤ) = 2 * (G.edgeFinset.card : ℤ) := by
    rw_mod_cast [SimpleGraph.sum_degrees_eq_twice_card_edges]
  rw [hdeg]
  ring

end ChipFiring