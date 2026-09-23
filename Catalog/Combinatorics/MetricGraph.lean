/-
# Tropical curves as metric graphs

A *tropical curve* is a metric graph: a finite connected graph `G` together with an
assignment of positive real lengths to its edges.  The genus of the tropical curve is the
first Betti number `g = |E| - |V| + 1` of the underlying graph — a purely topological
quantity, independent of the metric — and the divisor theory (Riemann–Roch, Clifford, …)
developed for `G` is exactly the divisor theory of the tropical curve on the vertex set.

Main results:
* `TropicalRR.genus_nonneg` : a connected graph has nonnegative genus;
* `TropicalRR.genus_eq_zero_iff_isTree` : genus `0` characterises trees;
* `TropicalRR.EdgeLengths.totalLength_unit` : the total length of a unit-length tropical
  curve is `g + |V| - 1`;
* `TropicalRR.tropical_riemann_roch` : Riemann–Roch for a tropical curve;
* `TropicalRR.rank_eq_degD_of_isTree` and `TropicalRR.rank_eq_degD_sub_one_of_genus_one`:
  the rank function in genus `0` and genus `1`.
-/
import Combinatorics.TropicalRiemannRoch.Clifford

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ### The genus is a nonnegative topological invariant -/

omit [DecidableEq V] in
/-- A connected graph has nonnegative genus. -/
theorem genus_nonneg (hc : G.Connected) : 0 ≤ genus G := by
  have h := hc.card_vert_le_card_edgeSet_add_one
  rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card] at h
  have h1 : Fintype.card G.edgeSet = G.edgeFinset.card := SimpleGraph.edgeFinset_card.symm
  rw [h1] at h
  simp only [genus]
  omega

omit [DecidableEq V] in
/-- A connected graph has genus zero exactly when it is a tree. -/
theorem genus_eq_zero_iff_isTree (hc : G.Connected) : genus G = 0 ↔ G.IsTree := by
  rw [SimpleGraph.isTree_iff_connected_and_card]
  have h1 : Fintype.card G.edgeSet = G.edgeFinset.card := SimpleGraph.edgeFinset_card.symm
  constructor
  · intro h
    refine ⟨hc, ?_⟩
    rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card, h1]
    simp only [genus] at h
    omega
  · rintro ⟨-, h⟩
    rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card, h1] at h
    simp only [genus]
    omega

/-! ### Metric structures -/

/-- A metric structure (tropical curve structure) on `G`: positive lengths on the edges. -/
structure EdgeLengths where
  /-- The length assigned to each edge. -/
  length : Sym2 V → ℝ
  /-- Edge lengths are positive. -/
  pos : ∀ e ∈ G.edgeFinset, 0 < length e

namespace EdgeLengths

variable {G}

/-- The total length of a tropical curve. -/
def totalLength (l : EdgeLengths G) : ℝ := ∑ e ∈ G.edgeFinset, l.length e

omit [DecidableEq V] in
/-- A tropical curve with at least one edge has positive total length. -/
theorem totalLength_pos (l : EdgeLengths G) (h : G.edgeFinset.Nonempty) : 0 < l.totalLength :=
  Finset.sum_pos (fun e he => l.pos e he) h

omit [DecidableEq V] in
/-- For a unit-length tropical curve the total length is `g + |V| - 1`, so the genus is
recovered metrically from the total length and the number of vertices. -/
theorem totalLength_unit (l : EdgeLengths G) (h : ∀ e ∈ G.edgeFinset, l.length e = 1) :
    l.totalLength = genus G + (Fintype.card V : ℝ) - 1 := by
  have : l.totalLength = (G.edgeFinset.card : ℝ) := by
    rw [totalLength, Finset.sum_congr rfl h, Finset.sum_const, nsmul_eq_mul, mul_one]
  rw [this, genus]
  push_cast
  ring

end EdgeLengths

/-! ### Riemann–Roch for tropical curves -/

variable [Nonempty V]

/-- **Riemann–Roch for a tropical curve.**  For any metric structure `l` on the connected
graph `G`, the divisor theory of the tropical curve `(G, l)` satisfies
`r(D) - r(K - D) = deg D - g + 1`.  (The genus and the formula do not depend on the metric:
they are invariants of the underlying graph.) -/
theorem tropical_riemann_roch (hc : G.Connected) (_l : EdgeLengths G) (D : Divisor V) :
    rank G D - rank G (canonical G - D) = degD D - genus G + 1 :=
  riemann_roch G hc D

/-- On a tropical curve of genus `0` (a tree) the rank of a divisor of nonnegative degree is
its degree. -/
theorem rank_eq_degD_of_isTree (hc : G.Connected) (hT : G.IsTree) {D : Divisor V}
    (hD : 0 ≤ degD D) : rank G D = degD D := by
  have hg : genus G = 0 := (genus_eq_zero_iff_isTree G hc).2 hT
  have := rank_eq_of_degD_large G hc (D := D) (by omega)
  omega

/-- On a tropical curve of genus `1` the rank of a divisor of positive degree is
`deg D - 1`. -/
theorem rank_eq_degD_sub_one_of_genus_one (hc : G.Connected) (hg : genus G = 1)
    {D : Divisor V} (hD : 1 ≤ degD D) : rank G D = degD D - 1 := by
  have := rank_eq_of_degD_large G hc (D := D) (by omega)
  omega

/-- **Clifford's theorem for tropical curves.** -/
theorem tropical_clifford (hc : G.Connected) (_l : EdgeLengths G) {D : Divisor V}
    (h1 : 0 ≤ rank G D) (h2 : 0 ≤ rank G (canonical G - D)) : 2 * rank G D ≤ degD D :=
  clifford G hc h1 h2

end TropicalRR