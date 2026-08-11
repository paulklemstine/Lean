import Physics.AdjacencyDegree.Moments

/-!
# Sharpness: adjacency-degree moments cannot separate regular graphs

McKay's theorem (and its principal form) is a statement about *trees*.  Here we prove the
complementary negative result, which shows that the moment invariant is genuinely weak outside
the forest world:

* `AdjDeg.wordMoment_of_regular` : for a `k`-regular graph on `n` vertices **every** word moment
  equals `k^{|w|} · n`, independently of the graph;
* `AdjDeg.wordMoment_eq_of_regular` : hence any two `k`-regular graphs of the same order are
  moment-indistinguishable;
* `AdjDeg.moments_do_not_determine_graphs` : an explicit six-vertex witness — the hexagon `C₆`
  and the disjoint union of two triangles have identical adjacency-degree moments but are
  non-isomorphic (`C₆` is triangle-free).

This pins down the boundary of the determination statement: the tree hypothesis is not a
technical artefact.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- On a regular graph, every word matrix acts on `𝟏` by the scalar `k^{|w|}`. -/
theorem wordMatrix_mulVec_ones_of_regular {k : ℕ} (hk : G.IsRegularOfDegree k)
    (w : List Letter) :
    wordMatrix G w *ᵥ (1 : V → ℝ) = ((k : ℝ) ^ w.length) • (1 : V → ℝ) := by
  induction w with
  | nil => simp [Matrix.one_mulVec]
  | cons l w ih =>
      rw [wordMatrix_cons, ← Matrix.mulVec_mulVec, ih, Matrix.mulVec_smul]
      have hl : letterMatrix G l *ᵥ (1 : V → ℝ) = (k : ℝ) • (1 : V → ℝ) := by
        cases l with
        | adj =>
            ext v
            rw [letterMatrix, SimpleGraph.adjMatrix_mulVec_apply]
            simp [hk v, SimpleGraph.card_neighborFinset_eq_degree]
        | deg =>
            ext v
            simp [letterMatrix, degMatrix_mulVec, hk v]
      rw [hl]
      ext v
      simp [pow_succ, mul_comm]

/-- The moments of a `k`-regular graph on `n` vertices are `k^{|w|} n`. -/
theorem wordMoment_of_regular {k : ℕ} (hk : G.IsRegularOfDegree k) (w : List Letter) :
    wordMoment G w = (k : ℝ) ^ w.length * (Fintype.card V : ℝ) := by
  rw [wordMoment, moment_eq_sum_mulVec, wordMatrix_mulVec_ones_of_regular G hk w]
  simp [Finset.card_univ, mul_comm]

/-- **Regular graphs of equal order and degree are moment-indistinguishable.** -/
theorem wordMoment_eq_of_regular {W : Type*} [Fintype W] [DecidableEq W]
    (G' : SimpleGraph W) [DecidableRel G'.Adj] {k : ℕ}
    (hk : G.IsRegularOfDegree k) (hk' : G'.IsRegularOfDegree k)
    (hcard : Fintype.card V = Fintype.card W) (w : List Letter) :
    wordMoment G w = wordMoment G' w := by
  rw [wordMoment_of_regular G hk, wordMoment_of_regular G' hk', hcard]

/-! ## An explicit six-vertex witness -/

/-- The hexagon `C₆`. -/
def cyc6 : SimpleGraph (Fin 6) where
  Adj i j := (i.val + 1) % 6 = j.val ∨ (j.val + 1) % 6 = i.val
  symm := by
    intro i j h
    exact h.symm
  loopless := ⟨fun i h => by rcases h with h | h <;> omega⟩

instance : DecidableRel cyc6.Adj := fun i j =>
  inferInstanceAs (Decidable ((i.val + 1) % 6 = j.val ∨ (j.val + 1) % 6 = i.val))

/-- Two disjoint triangles. -/
def twoK3 : SimpleGraph (Fin 6) where
  Adj i j := i.val ≠ j.val ∧ i.val / 3 = j.val / 3
  symm := by
    intro i j h
    exact ⟨h.1.symm, h.2.symm⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

instance : DecidableRel twoK3.Adj := fun i j =>
  inferInstanceAs (Decidable (i.val ≠ j.val ∧ i.val / 3 = j.val / 3))

lemma cyc6_regular : cyc6.IsRegularOfDegree 2 := by
  intro v
  fin_cases v <;> decide

lemma twoK3_regular : twoK3.IsRegularOfDegree 2 := by
  intro v
  fin_cases v <;> decide

lemma cyc6_triangle_free : ¬ ∃ a b c : Fin 6, cyc6.Adj a b ∧ cyc6.Adj b c ∧ cyc6.Adj a c := by
  decide

lemma twoK3_has_triangle : twoK3.Adj 0 1 ∧ twoK3.Adj 1 2 ∧ twoK3.Adj 0 2 := by decide

/-- `C₆` and two triangles are not isomorphic. -/
theorem cyc6_not_iso_twoK3 : IsEmpty (cyc6 ≃g twoK3) := by
  refine ⟨fun f => cyc6_triangle_free ⟨f.symm 0, f.symm 1, f.symm 2, ?_, ?_, ?_⟩⟩
  · exact f.symm.map_adj_iff.mpr twoK3_has_triangle.1
  · exact f.symm.map_adj_iff.mpr twoK3_has_triangle.2.1
  · exact f.symm.map_adj_iff.mpr twoK3_has_triangle.2.2

/-- **The adjacency-degree moments do not determine a general graph.** -/
theorem moments_do_not_determine_graphs :
    (∀ w : List Letter, wordMoment cyc6 w = wordMoment twoK3 w) ∧ IsEmpty (cyc6 ≃g twoK3) :=
  ⟨fun w => wordMoment_eq_of_regular cyc6 twoK3 cyc6_regular twoK3_regular rfl w,
    cyc6_not_iso_twoK3⟩

end AdjDeg