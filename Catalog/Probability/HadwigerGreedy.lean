/-
  Greedy Colouring and Degeneracy
  ===============================

  The colouring half of every Hadwiger-type argument is a greedy bound: if every
  non-empty vertex subset carries a vertex with at most `d` neighbours inside
  that subset (`d`-degeneracy), then the graph is `(d+1)`-colourable.  This file
  proves that from scratch — Mathlib has the notion of chromatic number and of
  degree, but not this bridge — together with the maximum-degree corollary.

  Main results:

  * `Hadwiger.colorable_of_degenerate` : `d`-degenerate ⇒ `(d+1)`-colourable.
  * `Hadwiger.colorable_of_maxDegree_le` : maximum degree `≤ d` ⇒
    `(d+1)`-colourable (the greedy/Brooks-type bound).
  * `Hadwiger.colorable_two_of_degenerate_one` : the `d = 1` instance, an
    independent route to the colouring half of Hadwiger's case `k = 2`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): every case of Hadwiger's conjecture that is known
    splits into a contraction half and a colouring half, and the colouring half
    is always degeneracy plus greedy; formalising greedy colouring once should
    therefore serve all cases `k ≥ 3` as well.
  Experiment (Experimenter): the induction is on the cardinality of the vertex
    subset being coloured, not on the graph, so that the induction hypothesis
    can be applied to `S.erase v` for the low-degree vertex `v` supplied by the
    degeneracy hypothesis; the colour at `v` is chosen outside the image of the
    at most `d` already-coloured neighbours, which exists because
    `d < d + 1 = |Fin (d+1)|`.
  Analysis (Analyst): stating degeneracy over `Finset V` (rather than over
    induced subgraphs) avoids all subtype gymnastics — the neighbourhood inside
    `S` is literally `S.filter (G.Adj v ·)`.
  Critique (Critic): the hypothesis is exactly hereditary min-degree, so the
    theorem is not vacuous — the maximum-degree corollary instantiates it, and
    the `d = 1` case reproves that forests are 2-colourable by a route
    independent of `IsAcyclic.isBipartite`.
  Synthesis (PI): the greedy machine is now available in the catalog; the
    missing ingredient for Dirac's case `k = 3` is the *structural* statement
    that `K₄`-minor-free graphs are 2-degenerate, not the colouring step.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerSmallCases

namespace Hadwiger

open SimpleGraph Finset

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-- Auxiliary induction: a proper colouring of any vertex subset, built greedily
from the degeneracy hypothesis. -/
private theorem exists_coloring_on {d : ℕ}
    (h : ∀ S : Finset V, S.Nonempty → ∃ v ∈ S, (S.filter (fun w => G.Adj v w)).card ≤ d) :
    ∀ (n : ℕ) (S : Finset V), S.card = n →
      ∃ c : V → Fin (d + 1), ∀ x ∈ S, ∀ y ∈ S, G.Adj x y → c x ≠ c y := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro S hS
    rcases S.eq_empty_or_nonempty with rfl | hne
    · exact ⟨fun _ => 0, by simp⟩
    · obtain ⟨v, hv, hdeg⟩ := h S hne
      have hcard : (S.erase v).card < n := by
        rw [Finset.card_erase_of_mem hv, ← hS]
        exact Nat.sub_lt (Finset.card_pos.mpr ⟨v, hv⟩) one_pos
      obtain ⟨c', hc'⟩ := ih (S.erase v).card hcard (S.erase v) rfl
      -- a colour not used by the (at most `d`) already-coloured neighbours of `v`
      set F : Finset (Fin (d + 1)) := (S.filter (fun w => G.Adj v w)).image c' with hF
      have hlt : F.card < Fintype.card (Fin (d + 1)) := by
        refine lt_of_le_of_lt (le_trans (Finset.card_image_le) hdeg) ?_
        simp
      have hss : F ⊂ Finset.univ := by
        refine Finset.ssubset_univ_iff.mpr fun hcon => ?_
        rw [hcon] at hlt
        simp at hlt
      obtain ⟨col, -, hcol⟩ := Finset.exists_of_ssubset hss
      refine ⟨Function.update c' v col, ?_⟩
      intro x hx y hy hxy
      have hxy' : x ≠ y := hxy.ne
      by_cases hxv : x = v
      · subst hxv
        have hyv : y ≠ x := hxy'.symm
        rw [Function.update_self, Function.update_of_ne hyv]
        intro hcon
        exact hcol (by
          rw [hF, hcon]
          exact Finset.mem_image_of_mem c' (Finset.mem_filter.mpr ⟨hy, hxy⟩))
      · by_cases hyv : y = v
        · subst hyv
          rw [Function.update_self, Function.update_of_ne hxv]
          intro hcon
          exact hcol (by
            rw [hF, ← hcon]
            exact Finset.mem_image_of_mem c' (Finset.mem_filter.mpr ⟨hx, hxy.symm⟩))
        · rw [Function.update_of_ne hxv, Function.update_of_ne hyv]
          exact hc' x (Finset.mem_erase.mpr ⟨hxv, hx⟩) y (Finset.mem_erase.mpr ⟨hyv, hy⟩) hxy

/-- **Greedy colouring of a degenerate graph.**  If every non-empty set of
vertices contains a vertex with at most `d` neighbours inside the set, then the
graph is `(d+1)`-colourable. -/
theorem colorable_of_degenerate {d : ℕ}
    (h : ∀ S : Finset V, S.Nonempty → ∃ v ∈ S, (S.filter (fun w => G.Adj v w)).card ≤ d) :
    G.Colorable (d + 1) := by
  obtain ⟨c, hc⟩ := exists_coloring_on h (Finset.univ : Finset V).card Finset.univ rfl
  exact ⟨Coloring.mk c fun {x y} hxy => hc x (Finset.mem_univ x) y (Finset.mem_univ y) hxy⟩

/-- **Greedy bound from the maximum degree.**  A graph all of whose degrees are
at most `d` is `(d+1)`-colourable. -/
theorem colorable_of_maxDegree_le {d : ℕ} (h : ∀ v : V, G.degree v ≤ d) :
    G.Colorable (d + 1) := by
  refine colorable_of_degenerate fun S hS => ?_
  obtain ⟨v, hv⟩ := hS
  refine ⟨v, hv, le_trans (Finset.card_le_card ?_) (h v)⟩
  intro w hw
  rw [Finset.mem_filter] at hw
  exact (SimpleGraph.mem_neighborFinset G v w).mpr hw.2

/-- The `d = 1` instance: a graph in which every non-empty vertex set has a
vertex of degree at most one inside it is 2-colourable.  Applied to forests this
is an independent proof of the colouring half of Hadwiger's case `k = 2`. -/
theorem colorable_two_of_degenerate_one
    (h : ∀ S : Finset V, S.Nonempty → ∃ v ∈ S, (S.filter (fun w => G.Adj v w)).card ≤ 1) :
    G.Colorable 2 :=
  colorable_of_degenerate h

end Hadwiger