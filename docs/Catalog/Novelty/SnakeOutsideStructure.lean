/-
# Local structure of the boundary of a snake

The counting chain of `Computation.SnakeInTheBox` bounds the edge boundary of a
snake from above by `n · |Sᶜ|`: it treats every vertex outside the snake as if
it could absorb `n` boundary edges independently.  The research thread flags the
first genuine saving as coming from the vertices *outside* the snake with
several snake neighbours, whose index sets are strongly constrained.  This file
proves those constraints.

Let `y ∉ S` be adjacent to the snake vertices `v i` and `v j`, `i < j`.  Then

* `Snake.outside_index_gap`    : `i + 2 ≤ j` (the hypercube has no triangles, so
  the two indices cannot be consecutive);
* `Snake.outside_same_parity`  : `i ≡ j (mod 2)` (parity alternates along a
  snake, and both vertices are neighbours of the same `y`);
* `Snake.outside_dist_two`     : `hammingDist (v i) (v j) = 2` exactly.

Conversely such configurations always exist:

* `Snake.exists_companion` : for every `i` with `i + 2 ≤ L` there is a vertex
  `y ∉ S` adjacent to both `v i` and `v (i+2)` — the "companion" of the corner
  at `v (i+1)`;
* `Snake.exists_outside_indeg_two` : consequently, as soon as `L ≥ 2` the outer
  boundary of a snake carries a vertex of induced degree at least two, so the
  boundary estimate `∂S ≤ n |Sᶜ|` is never attained "uniformly".

These are exactly the hypotheses a weighted version of `Snake.boundary_upper`
would need; the weighted count itself is left open (see `FUTURE_DIRECTIONS.md`).
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.HypercubeInducedDegree
import Novelty.HypercubeCoil

namespace SnakeInTheBox

open Finset

variable {n L : ℕ}

/-! ## Two auxiliary cube lemmas -/

/-- Flips at different coordinates commute. -/
theorem flipAt_comm (x : Cube n) (c d : Fin n) :
    flipAt (flipAt x c) d = flipAt (flipAt x d) c := by
  by_cases hcd : c = d
  · rw [hcd]
  funext j
  by_cases hc : j = c <;> by_cases hd : j = d <;>
    simp [flipAt, hc, hd, hcd, Ne.symm hcd]

/-- The hypercube is triangle free: no vertex is adjacent to both ends of an edge. -/
theorem cube_triangle_free {x y z : Cube n} (hxy : Adj x y) (hzx : Adj z x) (hzy : Adj z y) :
    False := by
  have h1 : par x = par z + 1 := par_of_adj hzx
  have h2 : par y = par z + 1 := par_of_adj hzy
  have h3 : par y = par x + 1 := par_of_adj hxy
  have h4 : (0 : ZMod 2) = 1 := by
    have : par z + 1 = par z + 1 + 1 := by rw [← h1, ← h2] at *; linear_combination h3 - h2 + h1
    linear_combination this
  exact absurd h4 (by decide)

/-! ## The index set of an outside vertex -/

/-- Two snake neighbours of the same outside vertex have non-consecutive indices. -/
theorem Snake.outside_index_gap (s : Snake n L) {y : Cube n} {i j : ℕ} (hj : j ≤ L)
    (hij : i < j) (h1 : Adj y (s.v i)) (h2 : Adj y (s.v j)) : i + 2 ≤ j := by
  by_contra h
  have hji : j = i + 1 := by omega
  subst hji
  exact cube_triangle_free (s.step i (by omega)) h1 h2

/-- Two snake neighbours of the same outside vertex have indices of equal parity. -/
theorem Snake.outside_same_parity (s : Snake n L) {y : Cube n} {i j : ℕ} (hi : i ≤ L)
    (hj : j ≤ L) (h1 : Adj y (s.v i)) (h2 : Adj y (s.v j)) : i % 2 = j % 2 := by
  have e1 : par (s.v i) = par y + 1 := par_of_adj h1
  have e2 : par (s.v j) = par y + 1 := par_of_adj h2
  have p1 : par (s.v i) = par (s.v 0) + (i : ZMod 2) := s.par_v hi
  have p2 : par (s.v j) = par (s.v 0) + (j : ZMod 2) := s.par_v hj
  have hcast : ((i : ℕ) : ZMod 2) = ((j : ℕ) : ZMod 2) := by
    linear_combination e1 - e2 - p1 + p2
  have := (ZMod.natCast_eq_natCast_iff i j 2).mp hcast
  simpa [Nat.ModEq] using this

/-- Two snake neighbours of the same outside vertex are at Hamming distance exactly two. -/
theorem Snake.outside_dist_two (s : Snake n L) {y : Cube n} {i j : ℕ} (hj : j ≤ L)
    (hij : i + 2 ≤ j) (h1 : Adj y (s.v i)) (h2 : Adj y (s.v j)) :
    hammingDist (s.v i) (s.v j) = 2 := by
  have hlow := s.chord i j hj hij
  have d1 : hammingDist (s.v i) y = 1 := hammingDist_of_adj (adj_symm h1)
  have d2 : hammingDist y (s.v j) = 1 := hammingDist_of_adj h2
  have htri := hammingDist_triangle (s.v i) y (s.v j)
  omega

/-! ## Existence of companions -/

/-- **Companions.**  For every corner `v i, v (i+1), v (i+2)` of a snake there is a vertex
`y` *outside* the snake adjacent to both `v i` and `v (i+2)`: the fourth vertex of the
square spanned by the corner. -/
theorem Snake.exists_companion (s : Snake n L) {i : ℕ} (hi : i + 2 ≤ L) :
    ∃ y, y ∉ s.vset ∧ Adj y (s.v i) ∧ Adj y (s.v (i + 2)) := by
  obtain ⟨c, hc⟩ := s.step i (by omega)
  obtain ⟨d, hd⟩ := s.step (i + 1) (by omega)
  have hi2 : i + 1 + 1 = i + 2 := by omega
  rw [hi2] at hd
  have hcd : c ≠ d := by
    intro h
    subst h
    have hsame : s.v (i + 2) = s.v i := by rw [hd, hc, flipAt_flipAt]
    have hch := s.chord i (i + 2) hi (by omega)
    rw [hsame, hammingDist_self] at hch
    omega
  refine ⟨flipAt (s.v i) d, ?_, ⟨d, (flipAt_flipAt _ _).symm⟩, ?_⟩
  · -- the companion is not on the snake
    intro hmem
    rw [Snake.vset] at hmem
    obtain ⟨k, hk_mem, hk⟩ := Finset.mem_image.mp hmem
    rw [Finset.mem_range] at hk_mem
    have hkL : k ≤ L := by omega
    have hadj1 : Adj (s.v k) (s.v i) := by
      rw [hk]; exact ⟨d, (flipAt_flipAt _ _).symm⟩
    have hadj2 : Adj (s.v k) (s.v (i + 2)) := by
      rw [hk, hd, hc]
      exact ⟨c, flipAt_comm _ _ _⟩
    have h1 := s.index_adj hkL (by omega) hadj1
    have h2 := s.index_adj hkL hi hadj2
    have hk1 : k = i + 1 := by omega
    -- then the companion would be `s.v (i+1) = flipAt (s.v i) c`
    rw [hk1, hc] at hk
    have hval : flipAt (s.v i) c d = flipAt (s.v i) d d := by rw [hk]
    rw [flipAt_apply_of_ne _ (Ne.symm hcd), flipAt_apply_self] at hval
    simp at hval
  · -- adjacency with `s.v (i+2)`
    rw [hd, hc]
    exact ⟨c, flipAt_comm _ _ _⟩

/-- **The outer boundary of a snake is never uniform.**  As soon as a snake has two edges,
some vertex outside it has at least two snake neighbours; equivalently the trivial bound
"every outside vertex absorbs at most `n` boundary edges" is applied to a boundary which
is genuinely concentrated. -/
theorem Snake.exists_outside_indeg_two (s : Snake n L) (hL : 2 ≤ L) :
    ∃ y, y ∉ s.vset ∧ 2 ≤ indeg s.vset y := by
  obtain ⟨y, hy, h1, h2⟩ := s.exists_companion (i := 0) (by omega)
  refine ⟨y, hy, ?_⟩
  have hne : s.v 0 ≠ s.v 2 := by
    have := s.chord 0 2 hL (by omega)
    intro he
    rw [he, hammingDist_self] at this
    omega
  have hsub : ({s.v 0, s.v 2} : Finset (Cube n)) ⊆ s.vset.filter fun z => Adj y z := by
    intro z hz
    simp only [Finset.mem_insert, Finset.mem_singleton] at hz
    rcases hz with rfl | rfl
    · exact Finset.mem_filter.mpr ⟨s.mem_vset (by omega), h1⟩
    · exact Finset.mem_filter.mpr ⟨s.mem_vset hL, h2⟩
  have hcard : ({s.v 0, s.v 2} : Finset (Cube n)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
  have := Finset.card_le_card hsub
  rw [hcard] at this
  exact this

/-- The index parity constraint in packaged form: the set of indices of the snake
neighbours of an outside vertex is a set of pairwise non-adjacent indices of one parity,
whose vertices are pairwise at Hamming distance exactly two. -/
theorem Snake.outside_nbr_structure (s : Snake n L) {y : Cube n} {i j : ℕ} (hi : i ≤ L)
    (hj : j ≤ L) (hij : i < j) (h1 : Adj y (s.v i)) (h2 : Adj y (s.v j)) :
    i + 2 ≤ j ∧ i % 2 = j % 2 ∧ hammingDist (s.v i) (s.v j) = 2 :=
  ⟨s.outside_index_gap hj hij h1 h2, s.outside_same_parity hi hj h1 h2,
    s.outside_dist_two hj (s.outside_index_gap hj hij h1 h2) h1 h2⟩

end SnakeInTheBox