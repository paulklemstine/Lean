import Mathlib

/-!
# Turán's theorem: the classical real-analytic edge bound

Turán's theorem states that a graph on `n` vertices that contains no clique of size
`r + 1` (i.e. is `K_{r+1}`-free) has at most `(1 - 1/r) * n^2 / 2` edges, and the extremal
graph is the *Turán graph* (the complete `r`-partite graph with parts as equal as possible).

`Mathlib` proves the exact combinatorial optimum (`SimpleGraph.CliqueFree.card_edgeFinset_le`
and the maximality of `turanGraph`). Here we package this into the standard textbook form:

* `SimpleGraph.CliqueFree.two_mul_card_edgeFinset_le`: the clean `ℕ`-level inequality
  `2 * r * |E(G)| ≤ (r - 1) * n^2` for any `K_{r+1}`-free graph `G` on `n` vertices.
* `SimpleGraph.CliqueFree.card_edgeFinset_le_turan_real`: the real-analytic form
  `|E(G)| ≤ (1 - 1/r) * n^2 / 2`, exactly the constant appearing in Turán's theorem.

This is the extremal bound underlying the "Turán graph" side of the probabilistic method:
it is achieved by an *explicit* construction (the Turán graph), so the extremal existence
statement is fully constructive.
-/

open SimpleGraph Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj] {r : ℕ}

/-
**Turán's theorem** (combinatorial form). If `G` is `K_{r+1}`-free on `n` vertices, then
`2 * r * |E(G)| ≤ (r - 1) * n^2`. This is obtained by comparing `G` with the extremal
Turán graph.
-/
theorem CliqueFree.two_mul_card_edgeFinset_le
    (cf : G.CliqueFree (r + 1)) (hr : 0 < r) :
    2 * r * #G.edgeFinset ≤ (r - 1) * (Fintype.card V) ^ 2 := by
  have := @exists_isTuranMaximal;
  obtain ⟨ H, x, hH ⟩ := @this V _ r hr;
  have := @isTuranMaximal_iff_nonempty_iso_turanGraph;
  obtain ⟨ f ⟩ := this hr |>.1 hH;
  have := @Iso.card_edgeFinset_eq;
  exact le_trans ( Nat.mul_le_mul_left _ ( hH.2 cf ) ) ( by rw [ this f ] ; exact mul_card_edgeFinset_turanGraph_le )

/-
**Turán's theorem** (real-analytic form). A `K_{r+1}`-free graph on `n` vertices has at
most `(1 - 1/r) * n^2 / 2` edges — the classical Turán bound.
-/
theorem CliqueFree.card_edgeFinset_le_turan_real
    (cf : G.CliqueFree (r + 1)) (hr : 0 < r) :
    (#G.edgeFinset : ℝ) ≤ (1 - 1 / r) * (Fintype.card V) ^ 2 / 2 := by
  -- By dividing both sides of the inequality $2 * r * #G.edgeFinset ≤ (r - 1) * (Fintype.card V) ^ 2$ by $2 * r$, we obtain the desired result.
  have h_div : (2 * r : ℝ) * #G.edgeFinset ≤ (r - 1) * (Fintype.card V) ^ 2 := by
    norm_cast;
    rw [ Int.subNatNat_of_le hr.nat_succ_le ] ; norm_cast ; exact CliqueFree.two_mul_card_edgeFinset_le cf hr;
  rw [ one_sub_div, div_mul_eq_mul_div, div_div, le_div_iff₀ ] <;> first | positivity | linarith;

end SimpleGraph