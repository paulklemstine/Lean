/-
# Finite two‑colour Ramsey theory

This file develops the elementary theory of finite two‑colour Ramsey numbers,
culminating in the exact value `R(3,3) = 6` and the Erdős–Szekeres binomial
upper bound `R(s+1, t+1) ≤ C(s+t, s)`.

A *two‑colouring* of a complete graph is encoded by a single `SimpleGraph G`:
the edges of `G` are the **red** edges and the edges of its complement `Gᶜ`
are the **blue** edges.  A red clique is then a clique of `G` and a blue clique
is a clique of `Gᶜ`.

The central relation is the *arrow* relation `Arrows n s t`
(classically written `n → (s, t)`): every red/blue colouring of any vertex set
of size at least `n` contains a red `s`‑clique or a blue `t`‑clique.
-/

import Mathlib

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/-! ## Core combinatorial objects -/

/-- The type of red/blue colourings of the complete graph on `s + t` vertices,
represented by the *red* subgraph (the blue subgraph being its complement).
This is the natural ambient type for the arrow relation `Arrows (s+t) s t`. -/
abbrev ArrowsType (s t : ℕ) : Type := SimpleGraph (Fin (s + t))

/-- `Arrows n s t` is the *arrow* relation `n → (s, t)`:
for every red/blue colouring `G` of a complete graph on a vertex set `W`
of size at least `n`, there is a **red** `s`‑clique (a clique of `G`) contained
in `W`, or a **blue** `t`‑clique (a clique of `Gᶜ`) contained in `W`.

Quantifying over an arbitrary vertex type together with a `Finset W` of vertices
bakes in monotonicity in the number of vertices and makes the Erdős–Szekeres
recursion easy to state, since the two recursive calls live on subsets of the
same vertex set. -/
def Arrows (n s t : ℕ) : Prop :=
  ∀ {V : Type} [DecidableEq V] (G : SimpleGraph V) (W : Finset V), n ≤ W.card →
    (∃ S : Finset V, S ⊆ W ∧ G.IsNClique s S) ∨
    (∃ S : Finset V, S ⊆ W ∧ Gᶜ.IsNClique t S)

/-! ## Monotonicity -/

/-- The arrow relation is monotone in the number of vertices: increasing the
threshold makes the statement weaker. -/
theorem Arrows.mono {n n' s t : ℕ} (h : Arrows n s t) (hn : n ≤ n') :
    Arrows n' s t := by
  intro V _ G W hW
  exact h G W (le_trans hn hW)

/-! ## The Erdős–Szekeres recursion -/

/--
**Erdős–Szekeres inductive step.**
If `m → (s, t+1)` and `n → (s+1, t)` then `(m + n) → (s+1, t+1)`.

Proof: in a colouring of `W` with `|W| ≥ m + n`, pick a vertex `v`.  Split the
remaining vertices according to the colour of their edge to `v`: the red
neighbours `R` and the blue neighbours `B` satisfy `|R| + |B| ≥ m + n - 1`, so
`|R| ≥ m` or `|B| ≥ n`.  In the first case `R → (s, t+1)` gives a blue
`(t+1)`‑clique (done) or a red `s`‑clique, which together with `v` yields a red
`(s+1)`‑clique.  The second case is symmetric.
-/
theorem arrows_step {m n s t : ℕ} (hmpos : 0 < m) (hnpos : 0 < n)
    (hm : Arrows m s (t + 1)) (hn : Arrows n (s + 1) t) :
    Arrows (m + n) (s + 1) (t + 1) := by
  intro V hdec G W hcard
  obtain ⟨v, hv⟩ : ∃ v ∈ W, True := by
    exact Exists.elim ( Finset.card_pos.mp ( by linarith ) ) fun x hx => ⟨ x, hx, trivial ⟩;
  set R := (W.erase v).filter (fun x => G.Adj v x) with hR
  set B := (W.erase v).filter (fun x => ¬ G.Adj v x) with hB
  have hRcard : R.card + B.card = W.card - 1 := by
    rw [ Finset.card_filter_add_card_filter_not, Finset.card_erase_of_mem hv.1 ]
  have hRorB : m ≤ R.card ∨ n ≤ B.card := by
    omega;
  cases' hRorB with hRorB hRorB <;> [ have := hm G R hRorB; have := hn G B hRorB ] <;> simp_all +decide [ SimpleGraph.isNClique_iff ];
  · obtain this | this := this;
    · obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := this; use Or.inl ⟨ Insert.insert v S, ?_, ?_, ?_ ⟩ <;> simp_all +decide [ Finset.subset_iff, SimpleGraph.isClique_iff ] ;
      rw [ Finset.card_insert_of_notMem ( fun h => by simpa [ h ] using hS₁ h ), hS₃ ];
    · exact Or.inr <| by obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := this; exact ⟨ S, Finset.Subset.trans hS₁ <| Finset.filter_subset _ _ |> Finset.Subset.trans <| Finset.erase_subset _ _, hS₂, hS₃ ⟩ ;
  · rcases this with ( ⟨ S, hS₁, hS₂, hS₃ ⟩ | ⟨ S, hS₁, hS₂, hS₃ ⟩ ) <;> simp_all +decide [ Finset.subset_iff ];
    · exact Or.inl ⟨ S, fun x hx => hS₁ hx |>.1 |>.2, hS₂, hS₃ ⟩;
    · refine Or.inr ⟨ Insert.insert v S, ?_, ?_, ?_ ⟩ <;> simp_all +decide [ SimpleGraph.isIndepSet_iff ];
      · simp_all +decide [ Set.Pairwise, SimpleGraph.adj_comm ];
      · rw [ Finset.card_insert_of_notMem ( fun h => by simpa [ h ] using hS₁ h ), hS₃ ]

/-- A single vertex is a red `1`-clique, so `1 → (1, b)` for every `b`. -/
theorem arrows_one_red (b : ℕ) : Arrows 1 1 b := by
  intro V _ G W hW
  obtain ⟨v, hv⟩ := Finset.card_pos.mp (by omega : 0 < W.card)
  exact Or.inl ⟨{v}, by simpa using hv, ⟨by simp [SimpleGraph.isClique_iff], by simp⟩⟩

/-- A single vertex is a blue `1`-clique, so `1 → (a, 1)` for every `a`. -/
theorem arrows_one_blue (a : ℕ) : Arrows 1 a 1 := by
  intro V _ G W hW
  obtain ⟨v, hv⟩ := Finset.card_pos.mp (by omega : 0 < W.card)
  exact Or.inr ⟨{v}, by simpa using hv, ⟨by simp [SimpleGraph.isClique_iff], by simp⟩⟩

/--
**Erdős–Szekeres / binomial upper bound.**
For all `s t`, `C(s+t, s) → (s+1, t+1)`, i.e. `R(s+1, t+1) ≤ C(s+t, s)`.

The proof is a double induction on `s` and `t`.  The base cases use that a single
vertex is both a red and a blue `1`‑clique; the inductive step combines the two
smaller instances via `arrows_step`, the cardinalities adding up by Pascal's
rule `C(s+t, s) = C(s-1+t, s-1) + C(s+t-1, s)`.
-/
theorem arrows_recursion (s t : ℕ) : Arrows ((s + t).choose s) (s + 1) (t + 1) := by
  by_contra h_contra;
  revert s t;
  intro s;
  induction' s with s ih <;> simp_all +decide;
  · exact fun t => arrows_one_red _;
  · have arrows_inductive_step : ∀ t, Arrows ((s + 1 + t).choose (s + 1)) (s + 2) (t + 1) := by
      intro t
      induction' t with t ih
      ·
        norm_num +zetaDelta at *;
        exact arrows_one_blue _
      ·
        -- Apply the arrows_step lemma with the induction hypotheses.
        have h_step : Arrows ((s + (t + 1)).choose s + (s + 1 + t).choose (s + 1)) (s + 2) (t + 2) := by
          apply arrows_step;
          · exact Nat.choose_pos ( by linarith );
          · exact Nat.choose_pos ( by linarith );
          · solve_by_elim;
          · assumption;
        grind +suggestions;
    grind +revert

/-- Restatement of `arrows_recursion` as the binomial upper bound on Ramsey
numbers `R(s+1, t+1) ≤ C(s+t, s)`. -/
theorem arrows_binomial_bound (s t : ℕ) :
    Arrows ((s + t).choose s) (s + 1) (t + 1) :=
  arrows_recursion s t

/-! ## The value `R(3,3) = 6` -/

/-- **Upper bound for `R(3,3)`.** Every red/blue colouring of `K₆` contains a
monochromatic triangle.  This is the instance `s = t = 2` of the binomial
bound, since `C(4, 2) = 6`. -/
theorem arrows_three_three : Arrows 6 3 3 := by
  intro V _ G W hW
  -- `(2 + 2).choose 2 = 6`, so this is the `s = t = 2` instance of the bound.
  exact arrows_recursion 2 2 G W (by simpa using hW)

/-- The pentagon (`5`‑cycle) `C₅`, used as the extremal colouring witnessing
`R(3,3) > 5`.  Adjacency is `a + 1 = b` or `b + 1 = a` (indices mod `5`). -/
def pentagon : SimpleGraph (Fin 5) := SimpleGraph.fromRel (fun a b => a + 1 = b)

instance : DecidableRel pentagon.Adj := by unfold pentagon; infer_instance

/-- In the pentagon `C₅` there is no red triangle. -/
theorem pentagon_no_triangle : ¬ ∃ S : Finset (Fin 5), pentagon.IsNClique 3 S := by
  decide

/-- In the complement of the pentagon (also a `5`‑cycle) there is no blue
triangle. -/
theorem pentagon_compl_no_triangle : ¬ ∃ S : Finset (Fin 5), pentagonᶜ.IsNClique 3 S := by
  decide

/-- **Lower bound for `R(3,3)`.** The pentagon colouring of `K₅` has neither a
red nor a blue triangle, so `¬ Arrows 5 3 3`, i.e. `R(3,3) > 5`. -/
theorem not_arrows_five_three_three : ¬ Arrows 5 3 3 := by
  intro h
  have := h pentagon (Finset.univ) (by simp)
  rcases this with ⟨S, _, hS⟩ | ⟨S, _, hS⟩
  · exact pentagon_no_triangle ⟨S, hS⟩
  · exact pentagon_compl_no_triangle ⟨S, hS⟩

/-- **The exact value `R(3,3) = 6`**: every colouring of `K₆` has a monochromatic
triangle, but some colouring of `K₅` (the pentagon) does not. -/
theorem ramsey_three_three : Arrows 6 3 3 ∧ ¬ Arrows 5 3 3 :=
  ⟨arrows_three_three, not_arrows_five_three_three⟩

end RamseyTheory