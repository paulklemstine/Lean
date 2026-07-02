/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Downward closure of the generalized Turán cubic upper bound

This file establishes that the cubic upper bound for `ex(n, K_{a,b}, K_{3,t})` is *downward
closed* under the subgraph order: if `G ≤ G'` and `G'` is `K_{3,t}`-free, then `G` inherits the
same cubic upper bound on its number of `K_{a,b}`-copies.

All proofs are elementary consequences of subgraph monotonicity; the heavy double-counting work
is reused as a black box via `GenTuranK3t.KabCopies_cubic_of_K3tFree`.
-/
import Mathlib
import Catalog.Novelty.GenTuranK3tUpperBound

open Finset

namespace GenTuranK3t

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Common neighborhoods grow when edges are added: if `G ≤ G'`, then the common neighborhood
of any set `S` in `G` is contained in that in `G'`. -/
lemma cnbhd_mono (G G' : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel G'.Adj]
    (h : G ≤ G') (S : Finset V) : cnbhd G S ⊆ cnbhd G' S := by
  intro w hw
  simp only [mem_cnbhd] at *
  exact fun u hu => h (hw u hu)

omit [Fintype V] [DecidableEq V] in
/-- `K_{3,t}`-freeness is antitone in the subgraph order: a subgraph of a `K_{3,t}`-free graph
is `K_{3,t}`-free. -/
lemma K3tFree_anti (G G' : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel G'.Adj]
    (h : G ≤ G') {t : ℕ} (hfree : K3tFree G' t) : K3tFree G t := by
  contrapose! hfree
  unfold K3tFree at *
  aesop

/-- Common neighborhood sizes are monotone in the subgraph order. -/
lemma CNbound_anti (G G' : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel G'.Adj]
    (h : G ≤ G') (S : Finset V) : (cnbhd G S).card ≤ (cnbhd G' S).card :=
  Finset.card_le_card (cnbhd_mono G G' h S)

/-- **Downward closure of the cubic upper bound.** If `G ≤ G'` and `G'` is `K_{3,t}`-free at the
necessary threshold `t ≥ b + 1`, then the number of copies of `K_{a,b}` in `G` is at most
`C · n^3`, with `C = C(t-1,b) · C(t-1,a-3)` the same constant as for `G'`. -/
theorem KabCopies_cubic_of_subgraph (G G' : SimpleGraph V)
    [DecidableRel G.Adj] [DecidableRel G'.Adj] {a b t : ℕ}
    (ha : 3 ≤ a) (hb : 3 ≤ b) (hbt : b + 1 ≤ t) (h : G ≤ G') (hfree : K3tFree G' t) :
    (KabCopies G a b).card
      ≤ ((t - 1).choose b * (t - 1).choose (a - 3)) * (Fintype.card V) ^ 3 :=
  KabCopies_cubic_of_K3tFree G ha hb hbt (K3tFree_anti G G' h hfree)

end GenTuranK3t