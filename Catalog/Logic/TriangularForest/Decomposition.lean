import Logic.TriangularForest.Sparsity

/-!
# Edge decompositions into triangular forests

The paper *Edge-decomposition into Two Triangular Forests is NP-complete* studies the decision
problem: given `G`, can `E(G)` be partitioned into two triangular forests?  This file develops
the *extremal* side of that problem, which is what constrains any such decomposition:

* `TriangularForest.DecomposesIntoTwo` — the decision predicate (an edge-disjoint cover by two
  triangular forests);
* `TriangularForest.card_edgeFinset_add_six_le_of_decomposesIntoTwo` — a decomposable graph on
  `n ≥ 2` vertices has at most `4n - 6` edges;
* `TriangularForest.completeGraph_not_decomposesIntoTwo` — consequently `Kₙ` is **not**
  decomposable into two triangular forests for `n ≥ 8`;
* `TriangularForest.completeGraph_decomposesIntoTwo_five` — by contrast `K₅` *is* decomposable,
  an explicit certificate (a triangle with two pendant edges, twice);
* `TriangularForest.card_choose_two_le_of_cover` and
  `TriangularForest.triangularThickness_lower_bound` — the `k`-fold generalisation: covering
  `Kₙ` by `k` triangular forests forces `k ≥ (n-1)/4`, so the "triangular thickness" of `Kₙ`
  grows linearly in `n`.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V : Type*}

/-- `G` **decomposes into two triangular forests** when its edges can be split into two
edge-disjoint triangular forests. -/
def DecomposesIntoTwo (G : SimpleGraph V) : Prop :=
  ∃ G₁ G₂ : SimpleGraph V, IsTriangularForest G₁ ∧ IsTriangularForest G₂ ∧
    Disjoint G₁ G₂ ∧ G₁ ⊔ G₂ = G

section Counting

variable [Fintype V] [DecidableEq V]

/-- The edges of a graph covered by two graphs are covered by their edges. -/
theorem card_edgeFinset_le_of_le_sup {G G₁ G₂ : SimpleGraph V} [DecidableRel G.Adj]
    [DecidableRel G₁.Adj] [DecidableRel G₂.Adj] (h : G ≤ G₁ ⊔ G₂) :
    #G.edgeFinset ≤ #G₁.edgeFinset + #G₂.edgeFinset := by
  classical
  have hsub : G.edgeFinset ⊆ G₁.edgeFinset ∪ G₂.edgeFinset := by
    intro e he
    induction e with
    | _ x y =>
      simp only [mem_edgeFinset, mem_edgeSet] at he
      rcases h he with hh | hh <;> simp [hh]
  exact le_trans (card_le_card hsub) (card_union_le _ _)

/-- **Extremal bound for two triangular forests.** A graph on `n ≥ 2` vertices that decomposes
into two triangular forests has at most `4n - 6` edges. -/
theorem card_edgeFinset_add_six_le_of_decomposesIntoTwo (G : SimpleGraph V) [DecidableRel G.Adj]
    (hG : DecomposesIntoTwo G) (hcard : 2 ≤ Fintype.card V) :
    #G.edgeFinset + 6 ≤ 4 * Fintype.card V := by
  classical
  obtain ⟨G₁, G₂, h₁, h₂, -, hsup⟩ := hG
  have hb₁ := card_edgeFinset_add_three_le G₁ h₁ hcard
  have hb₂ := card_edgeFinset_add_three_le G₂ h₂ hcard
  have hle : #G.edgeFinset ≤ #G₁.edgeFinset + #G₂.edgeFinset :=
    card_edgeFinset_le_of_le_sup (le_of_eq hsup.symm)
  omega

end Counting

section CompleteGraphs

/-- Arithmetic core of the obstruction: for `n ≥ 8` the complete graph has more than `4n - 6`
edges. -/
theorem four_mul_lt_choose_two_add_six {n : ℕ} (hn : 8 ≤ n) : 4 * n < n.choose 2 + 6 := by
  induction n with
  | zero => omega
  | succ m ih =>
    rcases Nat.lt_or_ge m 8 with hm | hm
    · have hm7 : m = 7 := by omega
      subst hm7
      decide
    · have hstep : (m + 1).choose 2 = m.choose 2 + m := by
        rw [Nat.choose_succ_succ m 1]
        simp [Nat.choose_one_right, Nat.add_comm]
      have := ih (by omega)
      omega

/-- **`Kₙ` is not decomposable into two triangular forests for `n ≥ 8`.** -/
theorem completeGraph_not_decomposesIntoTwo {n : ℕ} (hn : 8 ≤ n) :
    ¬ DecomposesIntoTwo (⊤ : SimpleGraph (Fin n)) := by
  intro hdec
  have hcard : 2 ≤ Fintype.card (Fin n) := by simp; omega
  have hbound := card_edgeFinset_add_six_le_of_decomposesIntoTwo
    (⊤ : SimpleGraph (Fin n)) hdec hcard
  have htop : #(⊤ : SimpleGraph (Fin n)).edgeFinset = n.choose 2 := by
    rw [SimpleGraph.card_edgeFinset_top_eq_card_choose_two]
    simp
  rw [htop, Fintype.card_fin] at hbound
  have := four_mul_lt_choose_two_add_six hn
  omega

end CompleteGraphs

section Thickness

variable [Fintype V] [DecidableEq V]

/-- If the edges of `G` are covered by a family of `k` graphs, its edge count is at most the sum
of theirs. -/
theorem card_edgeFinset_le_sum_of_cover {k : ℕ} (G : SimpleGraph V) [DecidableRel G.Adj]
    (H : Fin k → SimpleGraph V) [∀ i, DecidableRel (H i).Adj]
    (hcov : ∀ x y : V, G.Adj x y → ∃ i, (H i).Adj x y) :
    #G.edgeFinset ≤ ∑ i, #(H i).edgeFinset := by
  classical
  have hsub : G.edgeFinset ⊆ Finset.univ.biUnion fun i => (H i).edgeFinset := by
    intro e he
    induction e with
    | _ x y =>
      simp only [mem_edgeFinset, mem_edgeSet] at he
      obtain ⟨i, hi⟩ := hcov x y he
      simp only [Finset.mem_biUnion, Finset.mem_univ, true_and]
      exact ⟨i, by simpa using hi⟩
  exact le_trans (card_le_card hsub) (Finset.card_biUnion_le)

/-- **Linear lower bound on the triangular thickness of `Kₙ`.** If the complete graph on `n ≥ 2`
vertices is covered by `k` triangular forests, then `k * (2n - 3) ≥ n(n-1)/2`. -/
theorem card_choose_two_le_of_cover {n k : ℕ} (hn : 2 ≤ n)
    (H : Fin k → SimpleGraph (Fin n)) [∀ i, DecidableRel (H i).Adj]
    (hTF : ∀ i, IsTriangularForest (H i))
    (hcov : ∀ x y : Fin n, x ≠ y → ∃ i, (H i).Adj x y) :
    n.choose 2 + 3 * k ≤ k * (2 * n) := by
  classical
  have hcard : 2 ≤ Fintype.card (Fin n) := by simpa using hn
  have hsum : #(⊤ : SimpleGraph (Fin n)).edgeFinset ≤ ∑ i, #(H i).edgeFinset :=
    card_edgeFinset_le_sum_of_cover _ H (fun x y hxy => hcov x y (by simpa using hxy))
  have hbound : ∀ i, #(H i).edgeFinset + 3 ≤ 2 * n := fun i => by
    have := card_edgeFinset_add_three_le (H i) (hTF i) hcard
    simpa using this
  have hsum' : ∑ i, (#(H i).edgeFinset + 3) ≤ ∑ _i : Fin k, (2 * n) :=
    Finset.sum_le_sum fun i _ => hbound i
  rw [Finset.sum_add_distrib] at hsum'
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul] at hsum'
  have htop : #(⊤ : SimpleGraph (Fin n)).edgeFinset = n.choose 2 := by
    rw [SimpleGraph.card_edgeFinset_top_eq_card_choose_two]
    simp
  rw [htop] at hsum
  omega

/-- Covering `Kₙ` by triangular forests requires at least `(n-1)/4` of them. -/
theorem triangularThickness_lower_bound {n k : ℕ} (hn : 2 ≤ n)
    (H : Fin k → SimpleGraph (Fin n)) [∀ i, DecidableRel (H i).Adj]
    (hTF : ∀ i, IsTriangularForest (H i))
    (hcov : ∀ x y : Fin n, x ≠ y → ∃ i, (H i).Adj x y) :
    n - 1 ≤ 4 * k := by
  by_contra hcon
  push_neg at hcon
  have hmain := card_choose_two_le_of_cover hn H hTF hcov
  have hchoose : 2 * n.choose 2 = n * (n - 1) := by
    obtain ⟨r, hr⟩ := Nat.even_mul_pred_self n
    rw [Nat.choose_two_right, hr]
    omega
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at hchoose hcon
  nlinarith [hmain, hchoose, hcon]

end Thickness

section Example

/-- The first half of an explicit decomposition of `K₅`: the triangle `0-1-2` with the pendant
edges `0-4` and `1-3`. -/
def K5part1 : SimpleGraph (Fin 5) :=
  SimpleGraph.fromRel fun a b => (a, b) ∈ [((0 : Fin 5), (1 : Fin 5)), (0, 2), (0, 4), (1, 2), (1, 3)]

/-- The second half of an explicit decomposition of `K₅`: the triangle `2-3-4` with the pendant
edges `0-3` and `1-4`. -/
def K5part2 : SimpleGraph (Fin 5) :=
  SimpleGraph.fromRel fun a b => (a, b) ∈ [((0 : Fin 5), (3 : Fin 5)), (1, 4), (2, 3), (2, 4), (3, 4)]

instance : DecidableRel K5part1.Adj :=
  inferInstanceAs (DecidableRel fun a b : Fin 5 => a ≠ b ∧
    ((a, b) ∈ [((0 : Fin 5), (1 : Fin 5)), (0, 2), (0, 4), (1, 2), (1, 3)] ∨
     (b, a) ∈ [((0 : Fin 5), (1 : Fin 5)), (0, 2), (0, 4), (1, 2), (1, 3)]))

instance : DecidableRel K5part2.Adj :=
  inferInstanceAs (DecidableRel fun a b : Fin 5 => a ≠ b ∧
    ((a, b) ∈ [((0 : Fin 5), (3 : Fin 5)), (1, 4), (2, 3), (2, 4), (3, 4)] ∨
     (b, a) ∈ [((0 : Fin 5), (3 : Fin 5)), (1, 4), (2, 3), (2, 4), (3, 4)]))

theorem K5part1_isTriangularForest : IsTriangularForest K5part1 :=
  isTriangularForest_of_card_two_le_degree_le_three (by decide)

theorem K5part2_isTriangularForest : IsTriangularForest K5part2 :=
  isTriangularForest_of_card_two_le_degree_le_three (by decide)

/-- **`K₅` does decompose into two triangular forests.** -/
theorem completeGraph_decomposesIntoTwo_five :
    DecomposesIntoTwo (⊤ : SimpleGraph (Fin 5)) := by
  refine ⟨K5part1, K5part2, K5part1_isTriangularForest, K5part2_isTriangularForest, ?_, ?_⟩
  · rw [disjoint_iff]
    ext a b
    revert a b
    decide
  · ext a b
    revert a b
    decide

end Example

end TriangularForest