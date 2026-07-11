/-
# Chromatic Sum of stars — the forest side of the dichotomy

Building on `Defs.lean`, this file carries out step 1 of the future-directions
plan: an *exact* closed form for the chromatic sum of a **star** `K₁,ₙ`, the
simplest non-trivial family of trees (forests).

The star `Star n` has vertex set `Fin (n+1)`, a distinguished centre `0`, and
`n` leaves `1, …, n` each adjacent only to the centre.  Being a tree it is a
forest, so it lies squarely on the conjectured *polynomial* (tractable) side of
the Chromatic Sum dichotomy.

## Main results

* `ChromaticSum.chromaticSum_star` — `Σ(K₁,ₙ) = n + 2` for every `n ≥ 1`.
  The optimum colours the centre `2` and every leaf `1` (sum `2 + n`), which
  strictly beats the naive "centre `1`, leaves `2`" colouring of sum `1 + 2n`.

This subsumes `chromaticSum_P3` from `Dichotomy.lean` (`P₃ = K₁,₂`, so
`Σ = 4`) and further exhibits the `χ`/`Σ` subtlety: even though every star is
bipartite (`χ = 2`), the *sum*-optimal colouring depends delicately on where the
cheap colour is spent.
-/

import Mathlib
import Catalog.Applications.ChromaticSum.Defs

open Finset

namespace ChromaticSum

/-- The **star graph** `K₁,ₙ`: centre `0` adjacent to each of the `n` leaves
`1, …, n`, with no edges among the leaves. -/
def Star (n : ℕ) : SimpleGraph (Fin (n + 1)) where
  Adj i j := (i = 0 ∧ j ≠ 0) ∨ (j = 0 ∧ i ≠ 0)
  symm := by
    intro i j h
    rcases h with ⟨a, b⟩ | ⟨a, b⟩
    · exact Or.inr ⟨a, b⟩
    · exact Or.inl ⟨a, b⟩
  loopless := ⟨by
    intro i h
    rcases h with ⟨a, b⟩ | ⟨a, b⟩ <;> exact b a⟩

/-- The centre is adjacent to every leaf. -/
theorem Star_adj_center {n : ℕ} {j : Fin (n + 1)} (hj : j ≠ 0) :
    (Star n).Adj 0 j := Or.inl ⟨rfl, hj⟩

/-- **The chromatic sum of the star `K₁,ₙ` is `n + 2`** for `n ≥ 1`.

Upper bound: colour the centre `2` and every leaf `1`, giving sum `n + 2`.
Lower bound: fix any proper colouring `c`.  If the centre colour `c 0 = 1`, each
of the `n` leaves must avoid `1` and so is `≥ 2`, giving sum `≥ 1 + 2n ≥ n + 2`.
If `c 0 ≥ 2`, each leaf is `≥ 1`, giving sum `≥ 2 + n`.  Either way `n + 2 ≤`
the colour sum. -/
theorem chromaticSum_star (n : ℕ) (hn : 1 ≤ n) :
    chromaticSum (Star n) = n + 2 := by
  refine' le_antisymm ( _ : _ ≤ _ ) ( _ : _ ≥ _ );
  · refine' le_trans ( chromaticSum_le_colorSum _ ) _;
    exact fun i => if i = 0 then 2 else 1;
    · constructor <;> norm_num;
      · exact fun v => by split_ifs <;> norm_num;
      · grind +locals;
    · unfold colorSum; simp +decide [ Fin.sum_univ_succ ] ; linarith;
  · refine' le_chromaticSum _;
    intro c hc
    have h_sum : colorSum c = (∑ i ∈ Finset.univ.erase 0, c i) + c 0 := by
      unfold colorSum; rw [ Finset.sum_erase_add _ _ ( Finset.mem_univ _ ) ] ;
    by_cases h : c 0 = 1 <;> simp_all +decide [ IsProperColoring ];
    · exact lt_of_le_of_lt ( by norm_num ) ( Finset.sum_lt_sum_of_nonempty ( Finset.card_pos.mp ( by simpa [ Finset.card_erase_of_mem ( Finset.mem_univ ( 0 : Fin ( n + 1 ) ) ) ] using by linarith ) ) fun i hi => show c i > 1 from lt_of_le_of_ne ( hc.1 i ) ( Ne.symm <| by intro t; have := hc.2 ( show ( Star n ).Adj 0 i from Star_adj_center <| Finset.ne_of_mem_erase hi ) ; aesop ) );
    · exact Nat.add_le_add ( le_trans ( by norm_num ) ( Finset.sum_le_sum fun i hi => hc.1 i ) ) ( Nat.lt_of_le_of_ne ( hc.1 0 ) ( Ne.symm h ) )

end ChromaticSum