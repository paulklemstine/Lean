/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Turán graph is optimal among all `r`-colourable graphs — sharply, and by hand

`Catalog/Bridges/TuranSharpNonDivisible.lean` computes the exact number of edges of the Turán
graph for every `n` and every `r ≥ 1`.  This file proves, from scratch and with no appeal to
Mathlib's structural Turán theorem, that **no** `r`-colourable graph on `n` vertices can beat it.

The argument has two independent halves.

* An *integer* convexity step (`sum_sq_ge_balanced`): among all ways of writing `n` as a sum of
  `r` natural numbers, the sum of squares is minimized by the balanced split.  The proof is the
  tangent-line trick over `ℤ`: `(c − q)(c − q − 1) ≥ 0` for every integer `c`, i.e.
  `c² ≥ (2q+1)c − q(q+1)`, summed over the parts.  This is *sharp for integers*, unlike
  Cauchy–Schwarz, which would only give `n²/r`.
* A *counting* step (`two_mul_card_edgeFinset_add_sum_sq_le`): for a proper `r`-colouring the
  degree of a vertex misses its whole colour class, so `2·#edges + ∑_i c_i² ≤ n²`.

Main results:

* `sum_sq_ge_balanced` — `r·(n/r)² + (n % r)·(2·(n/r) + 1) ≤ ∑_i c_i²` for all `c` with
  `∑_i c_i = n`.
* `two_mul_card_edgeFinset_add_sum_sq_le` — the colour-class degree count.
* `turan_bound_of_colourable` — every `r`-colourable graph on `n` vertices satisfies
  `2·r·#edges + (n % r)·(r − n % r) ≤ (r − 1)·n²`, the sharp integer form of
  `#edges ≤ (1 − 1/r)n²/2`.
* `card_edgeFinset_le_turanGraph_of_colourable` — every `r`-colourable graph on `Fin n` has at
  most as many edges as `turanGraph n r`, with equality for the Turán graph itself
  (`card_edgeFinset_turanGraph_isGreatest_colourable`).
-/

import Mathlib
import Bridges.TuranExplicitCount
import Bridges.TuranSharpNonDivisible

open Finset SimpleGraph
open scoped BigOperators

namespace TuranPartiteSharp

open TuranExplicitCount TuranSharpNonDivisible

/-! ## The integer convexity step -/

/-- Tangent-line trick for integers: `c² + q(q+1) ≥ (2q+1)·c` for all naturals `c, q`, because
`(c − q)(c − q − 1) ≥ 0` — a product of two consecutive integers. -/
lemma sq_add_le (c q : ℕ) : (2 * q + 1) * c ≤ c ^ 2 + q * (q + 1) := by
  by_cases h : c ≤ q
  · have h' : (c : ℤ) ≤ q := by exact_mod_cast h
    have hprod : (0 : ℤ) ≤ ((q : ℤ) - c) * ((q : ℤ) + 1 - c) := by
      apply mul_nonneg <;> linarith
    have : ((2 * q + 1) * c : ℤ) ≤ (c : ℤ) ^ 2 + (q : ℤ) * (q + 1) := by nlinarith [hprod]
    exact_mod_cast this
  · have h' : (q : ℤ) + 1 ≤ c := by
      have : q < c := by omega
      exact_mod_cast this
    have hprod : (0 : ℤ) ≤ ((c : ℤ) - q) * ((c : ℤ) - q - 1) := by
      apply mul_nonneg <;> linarith
    have : ((2 * q + 1) * c : ℤ) ≤ (c : ℤ) ^ 2 + (q : ℤ) * (q + 1) := by nlinarith [hprod]
    exact_mod_cast this

/-- **Integer convexity.**  Among all decompositions `n = c_0 + … + c_{r-1}` into `r` natural
numbers, the sum of squares is smallest for the balanced decomposition, whose value is
`r·(n/r)² + (n % r)·(2·(n/r) + 1)`.  Sharp, unlike the Cauchy–Schwarz bound `n²/r`. -/
theorem sum_sq_ge_balanced {r : ℕ} (n : ℕ) (c : Fin r → ℕ) (hsum : ∑ i, c i = n) :
    r * (n / r) ^ 2 + (n % r) * (2 * (n / r) + 1) ≤ ∑ i, (c i) ^ 2 := by
  set q := n / r with hq
  set s := n % r with hs
  have hpointwise : ∀ i : Fin r, (2 * q + 1) * c i ≤ (c i) ^ 2 + q * (q + 1) :=
    fun i => sq_add_le (c i) q
  have hsum' : (2 * q + 1) * n ≤ (∑ i, (c i) ^ 2) + r * (q * (q + 1)) := by
    calc (2 * q + 1) * n = ∑ i, (2 * q + 1) * c i := by
          rw [← Finset.mul_sum, hsum]
      _ ≤ ∑ i : Fin r, ((c i) ^ 2 + q * (q + 1)) := Finset.sum_le_sum (fun i _ => hpointwise i)
      _ = (∑ i, (c i) ^ 2) + r * (q * (q + 1)) := by
          rw [Finset.sum_add_distrib, Finset.sum_const, card_univ, Fintype.card_fin, smul_eq_mul]
  have hn : n = r * q + s := by rw [hq, hs]; exact (Nat.div_add_mod n r).symm
  have hexp : r * q ^ 2 + s * (2 * q + 1) + r * (q * (q + 1)) = (2 * q + 1) * n := by
    rw [hn]; ring
  linarith

/-! ## The counting step -/

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The size of the colour class `i` of the colouring `f`. -/
def colourClassCard {r : ℕ} (f : V → Fin r) (i : Fin r) : ℕ :=
  #((univ : Finset V).filter (fun v => f v = i))

omit [DecidableEq V] in
/-- The colour classes partition the vertex set. -/
lemma sum_colourClassCard {r : ℕ} (f : V → Fin r) :
    ∑ i, colourClassCard (V := V) f i = Fintype.card V := by
  classical
  rw [← card_univ]
  exact (Finset.card_eq_sum_card_fiberwise (fun v _ => mem_univ (f v))).symm

/-- In a properly `r`-coloured graph the neighbours of `v` avoid the whole colour class of `v`. -/
lemma degree_add_colourClassCard_le {r : ℕ} (f : V → Fin r)
    (hf : ∀ u v, G.Adj u v → f u ≠ f v) (v : V) :
    G.degree v + colourClassCard (V := V) f (f v) ≤ Fintype.card V := by
  classical
  have hsub : G.neighborFinset v ⊆ (univ : Finset V) \
      ((univ : Finset V).filter (fun w => f w = f v)) := by
    intro w hw
    rw [mem_neighborFinset] at hw
    simp only [mem_sdiff, mem_univ, mem_filter, true_and]
    exact fun hcon => hf v w hw hcon.symm
  have hcard := Finset.card_le_card hsub
  rw [card_neighborFinset_eq_degree] at hcard
  have hdiff : #((univ : Finset V) \ ((univ : Finset V).filter (fun w => f w = f v)))
      = Fintype.card V - colourClassCard (V := V) f (f v) := by
    rw [Finset.card_univ_diff]
    rfl
  rw [hdiff] at hcard
  have hle : colourClassCard (V := V) f (f v) ≤ Fintype.card V := by
    simpa [colourClassCard, card_univ] using
      Finset.card_le_card (Finset.subset_univ ((univ : Finset V).filter (fun w => f w = f v)))
  omega

omit [DecidableEq V] in
/-- Grouping the vertices by colour turns `∑_v |class of v|` into `∑_i |class i|²`. -/
lemma sum_colourClassCard_sq {r : ℕ} (f : V → Fin r) :
    ∑ v : V, colourClassCard (V := V) f (f v) = ∑ i, (colourClassCard (V := V) f i) ^ 2 := by
  classical
  rw [← Finset.sum_fiberwise_of_maps_to (fun v _ => mem_univ (f v))
    (fun v : V => colourClassCard (V := V) f (f v))]
  refine Finset.sum_congr rfl ?_
  intro i _
  have hconst : ∑ v ∈ (univ : Finset V).filter (fun v => f v = i),
      colourClassCard (V := V) f (f v)
      = ∑ _v ∈ (univ : Finset V).filter (fun v => f v = i), colourClassCard (V := V) f i :=
    Finset.sum_congr rfl (fun v hv => by rw [(mem_filter.1 hv).2])
  rw [hconst, sum_const, smul_eq_mul]
  simp [colourClassCard, sq]

/-- **The counting step.**  For a proper `r`-colouring, `2·#edges + ∑_i c_i² ≤ n²`. -/
theorem two_mul_card_edgeFinset_add_sum_sq_le {r : ℕ} (f : V → Fin r)
    (hf : ∀ u v, G.Adj u v → f u ≠ f v) :
    2 * #G.edgeFinset + ∑ i, (colourClassCard (V := V) f i) ^ 2 ≤ (Fintype.card V) ^ 2 := by
  classical
  have hsum : ∑ v : V, (G.degree v + colourClassCard (V := V) f (f v))
      ≤ ∑ _v : V, Fintype.card V :=
    Finset.sum_le_sum (fun v _ => degree_add_colourClassCard_le G f hf v)
  rw [Finset.sum_add_distrib, G.sum_degrees_eq_twice_card_edges,
    sum_colourClassCard_sq (V := V) f] at hsum
  simpa [sum_const, card_univ, sq] using hsum

/-! ## The sharp bound for `r`-colourable graphs -/

/-- **Turán's bound for `r`-colourable graphs, sharply and in integers.**  If `G` admits a proper
colouring with `r` colours, then `2·r·#edges + (n % r)·(r − n % r) ≤ (r − 1)·n²`, the exact
integer form of `#edges ≤ (1 − 1/r)·n²/2`. -/
theorem turan_bound_of_colourable {r : ℕ} (hr : 0 < r) (f : V → Fin r)
    (hf : ∀ u v, G.Adj u v → f u ≠ f v) :
    2 * r * #G.edgeFinset + (Fintype.card V % r) * (r - Fintype.card V % r)
      ≤ (r - 1) * (Fintype.card V) ^ 2 := by
  classical
  set n := Fintype.card V with hn
  have hcount := two_mul_card_edgeFinset_add_sum_sq_le G f hf
  have hconv := sum_sq_ge_balanced (r := r) n (colourClassCard (V := V) f)
    (by rw [hn]; exact sum_colourClassCard (V := V) f)
  rw [← hn] at hcount
  have hbal : 2 * #G.edgeFinset + (r * (n / r) ^ 2 + (n % r) * (2 * (n / r) + 1)) ≤ n ^ 2 := by
    omega
  -- the Turán graph attains the balanced value, so compare with the exact identity
  have hturan : 2 * #(turanGraph n r).edgeFinset
      + (r * (n / r) ^ 2 + (n % r) * (2 * (n / r) + 1)) = n ^ 2 := by
    rw [← sum_classSize_sq_closed (n := n) (r := r) hr]
    exact two_mul_card_edgeFinset_turanGraph_general hr
  have hle : #G.edgeFinset ≤ #(turanGraph n r).edgeFinset := by omega
  have hid := turan_edge_identity (n := n) (r := r) hr
  have : 2 * r * #G.edgeFinset ≤ 2 * r * #(turanGraph n r).edgeFinset :=
    Nat.mul_le_mul_left _ hle
  omega

/-- Every `r`-colourable graph on `Fin n` has at most as many edges as the Turán graph. -/
theorem card_edgeFinset_le_turanGraph_of_colourable {n r : ℕ} (hr : 0 < r)
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (f : Fin n → Fin r)
    (hf : ∀ u v, G.Adj u v → f u ≠ f v) :
    #G.edgeFinset ≤ #(turanGraph n r).edgeFinset := by
  classical
  have hcount := two_mul_card_edgeFinset_add_sum_sq_le G f hf
  have hconv := sum_sq_ge_balanced (r := r) (Fintype.card (Fin n))
    (colourClassCard (V := Fin n) f) (sum_colourClassCard (V := Fin n) f)
  rw [Fintype.card_fin] at hcount hconv
  have hturan : 2 * #(turanGraph n r).edgeFinset
      + (r * (n / r) ^ 2 + (n % r) * (2 * (n / r) + 1)) = n ^ 2 := by
    rw [← sum_classSize_sq_closed (n := n) (r := r) hr]
    exact two_mul_card_edgeFinset_turanGraph_general hr
  omega

/-- The Turán graph is the *greatest* `r`-colourable graph on `Fin n`, in edge count: it is
`r`-colourable (colour by residue) and no `r`-colourable graph has more edges. -/
theorem card_edgeFinset_turanGraph_isGreatest_colourable {n r : ℕ} (hr : 0 < r) :
    IsGreatest {m : ℕ | ∃ (G : SimpleGraph (Fin n)) (_ : DecidableRel G.Adj) (f : Fin n → Fin r),
      (∀ u v, G.Adj u v → f u ≠ f v) ∧ #G.edgeFinset = m}
      (#(turanGraph n r).edgeFinset) := by
  classical
  refine ⟨⟨turanGraph n r, inferInstance, fun v => ⟨(v : ℕ) % r, Nat.mod_lt _ hr⟩, ?_, rfl⟩, ?_⟩
  · intro u v huv hcon
    rw [turanGraph_adj] at huv
    exact huv (congrArg Fin.val hcon)
  · rintro m ⟨G, hGdec, f, hf, rfl⟩
    exact card_edgeFinset_le_turanGraph_of_colourable hr G f hf

end TuranPartiteSharp