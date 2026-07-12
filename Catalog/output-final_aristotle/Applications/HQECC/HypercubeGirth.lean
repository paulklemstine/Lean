import Mathlib

/-!
# The girth of the hypercube graph is `4` (Conjecture 1)

This file settles the graph-theoretic heart of Conjecture 1 of the
"logical qubits = middle homology" research thread: the minimum distance of the
homological code of a graph complex is the length of a shortest nontrivial cycle,
which for a one-dimensional complex is exactly the **girth** of the underlying
graph.  We prove that the hypercube graph `Qₙ` (`n ≥ 2`) has girth exactly `4`,
independent of `n`, and we record the elementary arithmetic gap to the quantum
Singleton bound (`4 < 2^{n/2}` for `n ≥ 5`).

## Main definitions

* `HomQECC.hypercube n` : the hypercube graph `Qₙ` on vertex set `Fin n → ZMod 2`,
  two vertices adjacent iff they differ in exactly one coordinate.
* `HomQECC.parity` : the coordinate-sum parity `Fin n → ZMod 2 → ZMod 2`, the
  bipartition class of a vertex.

## Main results

* `HomQECC.hypercube_walk_length_parity` : along any walk the endpoint parity is
  the start parity plus the walk length — the hypercube is bipartite.
* `HomQECC.hypercube_triangle_free` : `Qₙ` has no `3`-cycle (girth `≥ 4`).
* `HomQECC.hypercube_has_four_cycle` : `Qₙ` (`n ≥ 2`) has a `4`-cycle
  (girth `≤ 4`).
* `HomQECC.hypercube_girth` : `(hypercube n).girth = 4` for `n ≥ 2`.
* `HomQECC.singleton_gap` : `4 < 2 ^ ((n : ℝ) / 2)` for `n ≥ 5`; the girth
  distance `4` is strictly below the quantum Singleton value `2^{n/2}`.
-/

open Finset

namespace HomQECC

variable {n : ℕ}

/-- The hypercube graph `Qₙ`: vertices are bit-vectors `Fin n → ZMod 2`, and two
vertices are adjacent iff they differ in exactly one coordinate. -/
def hypercube (n : ℕ) : SimpleGraph (Fin n → ZMod 2) where
  Adj x y := ∃ i, (∀ j, j ≠ i → x j = y j) ∧ x i ≠ y i
  symm := by
    rintro x y ⟨i, hji, hi⟩
    exact ⟨i, fun j hj => (hji j hj).symm, fun h => hi h.symm⟩
  loopless := ⟨fun x => by
    rintro ⟨i, -, hi⟩
    exact hi rfl⟩

/-- The parity (coordinate sum) of a vertex; the bipartition class of `Qₙ`. -/
def parity (x : Fin n → ZMod 2) : ZMod 2 := ∑ i, x i

/-
Adjacent vertices differ in parity: `parity y = parity x + 1`.
-/
lemma parity_adj {x y : Fin n → ZMod 2} (h : (hypercube n).Adj x y) :
    parity y = parity x + 1 := by
  -- Adjacency gives an index `i` where `x` and `y` differ, agreeing elsewhere.
  obtain ⟨i, hji, hi⟩ := h
  -- In `ZMod 2`, `x i ≠ y i` forces `y i = x i + 1`.
  have h_yi : y i = x i + 1 := by
    have := hi; revert this; generalize x i = a; generalize y i = b; revert a b; decide
  unfold parity
  rw [← Finset.sum_erase_add _ _ (Finset.mem_univ i),
      ← Finset.sum_erase_add _ _ (Finset.mem_univ i)]
  rw [Finset.sum_congr rfl (fun j hj => (hji j (Finset.ne_of_mem_erase hj)))]
  rw [h_yi]; ring

/-
**Bipartiteness.** Along any walk the endpoint parity equals the start parity
plus the (cast) walk length.
-/
lemma hypercube_walk_length_parity {x y : Fin n → ZMod 2}
    (w : (hypercube n).Walk x y) :
    parity y = parity x + (w.length : ZMod 2) := by
  induction' w with x y w ih;
  · norm_num;
  · simp_all +decide [ SimpleGraph.Walk.length_cons ];
    rw [ parity_adj ‹_› ] ; ring;

/-
Any closed walk in the hypercube has even length.
-/
lemma hypercube_closed_walk_even {x : Fin n → ZMod 2}
    (w : (hypercube n).Walk x x) : Even w.length := by
  have := hypercube_walk_length_parity w; simp_all +decide [ parity ] ;
  rw [ ZMod.natCast_eq_zero_iff ] at this ; exact even_iff_two_dvd.mpr this

/-
**Triangle-freeness (girth `≥ 4`).** No closed walk in the hypercube has length
`3`; in particular there is no `3`-cycle (triangle), so the girth is at least `4`.
-/
lemma hypercube_triangle_free {x : Fin n → ZMod 2}
    (w : (hypercube n).Walk x x) : w.length ≠ 3 := by
  exact fun h => by have := hypercube_closed_walk_even w; simp_all +decide ;

/-- The `i`-th standard basis bit-vector: `1` in coordinate `i`, `0` elsewhere. -/
def e (i : Fin n) : Fin n → ZMod 2 := fun j => if j = i then 1 else 0

/-
**A `4`-cycle exists (girth `≤ 4`).** For `n ≥ 2` the hypercube has a cycle
of length `4`.
-/
lemma hypercube_has_four_cycle (hn : 2 ≤ n) :
    ∃ (x : Fin n → ZMod 2) (w : (hypercube n).Walk x x), w.IsCycle ∧ w.length = 4 := by
  obtain ⟨i0, i1, hi0i1⟩ : ∃ i0 i1 : Fin n, i0 ≠ i1 := by
    exact ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, by norm_num ⟩;
  refine' ⟨ 0, _, _, _ ⟩;
  exact SimpleGraph.Walk.cons ( show ( hypercube n ).Adj 0 ( e i0 ) from ⟨ i0, by simp +decide [ e ] ⟩ ) ( SimpleGraph.Walk.cons ( show ( hypercube n ).Adj ( e i0 ) ( e i0 + e i1 ) from ⟨ i1, by
                                                                                                                                    simp +decide [ e ] ⟩ ) ( SimpleGraph.Walk.cons ( show ( hypercube n ).Adj ( e i0 + e i1 ) ( e i1 ) from ⟨ i0, by
                                                                                                                                                                                                                                        unfold e; aesop; ⟩ ) ( SimpleGraph.Walk.cons ( show ( hypercube n ).Adj ( e i1 ) 0 from ⟨ i1, by
                                                                                                                                                                                                                                                                                                                                            unfold e; aesop; ⟩ ) SimpleGraph.Walk.nil ) ) );
  · simp +decide [ SimpleGraph.Walk.isCycle_def ];
    simp +decide [ funext_iff, e ] at *;
    exact ⟨ ⟨ ⟨ ⟨ i0, by aesop ⟩, ⟨ i0, by aesop ⟩, fun h => ⟨ i0, by aesop ⟩ ⟩, ⟨ ⟨ i0, by aesop ⟩, fun h => ⟨ i0, by aesop ⟩, ⟨ i0, by aesop ⟩ ⟩ ⟩, ⟨ ⟨ i0, by aesop ⟩, ⟨ i0, by aesop ⟩ ⟩ ⟩;
  · rfl

/-
The hypercube is not acyclic for `n ≥ 2`.
-/
lemma hypercube_not_acyclic (hn : 2 ≤ n) : ¬ (hypercube n).IsAcyclic := by
  exact fun h => by obtain ⟨ x, w, hcycle, hlen ⟩ := hypercube_has_four_cycle hn; exact h w hcycle;

/-
**Conjecture 1 (core).** The girth of the hypercube graph `Qₙ` is `4` for all
`n ≥ 2`, independent of `n`.
-/
theorem hypercube_girth (hn : 2 ≤ n) : (hypercube n).girth = 4 := by
  refine' le_antisymm _ _;
  · obtain ⟨ x, w, hcycle, hlen ⟩ := hypercube_has_four_cycle hn; exact SimpleGraph.girth_le_length hcycle |> le_trans <| by norm_num [ hlen ] ; ;
  · -- By definition of girth, we need to show that the length of the shortest cycle in the hypercube is at least 4.
    have h_girth_ge_4 : ∀ (x : Fin n → ZMod 2) (w : (hypercube n).Walk x x), w.IsCycle → 4 ≤ w.length := by
      intros x w hw_cycle
      have h_parity : ∀ (i : ℕ), i ≤ w.length → parity (w.getVert i) = parity x + i := by
        intro i hi; have := hypercube_walk_length_parity ( w.take i ) ; aesop;
      have := h_parity w.length le_rfl; simp_all +decide ;
      contrapose! this; interval_cases _ : w.length <;> simp_all +decide ;
      rcases w with ( _ | ⟨ _, _, w ⟩ ) <;> simp_all +decide [ SimpleGraph.Walk.cons_isCycle_iff ];
      cases ‹SimpleGraph.Walk _ _ _› <;> aesop;
    grind +suggestions

/-
**Singleton-bound gap.** For `n ≥ 5` the constant girth distance `4` is
strictly below the quantum Singleton value `2^{n/2}`, so the hypercube homological
code does not achieve the quantum Singleton bound.
-/
theorem singleton_gap {m : ℕ} (hm : 5 ≤ m) : (4 : ℝ) < 2 ^ ((m : ℝ) / 2) := by
  exact lt_of_le_of_lt ( by norm_num ) ( Real.rpow_lt_rpow_of_exponent_lt ( by norm_num ) ( show ( m : ℝ ) / 2 > 2 by linarith [ show ( m : ℝ ) ≥ 5 by norm_cast ] ) )

end HomQECC