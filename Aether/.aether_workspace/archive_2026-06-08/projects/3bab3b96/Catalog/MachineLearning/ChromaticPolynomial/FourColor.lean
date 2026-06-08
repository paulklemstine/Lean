import Mathlib
import Speculative.ChromaticPolynomial.Defs

/-!
# Four-Color Theorem — Formal Equivalences

This file establishes formal equivalence between different formulations
of the four-color theorem, connecting the graph-theoretic statement
(`Colorable 4`) with proper coloring predicates. These equivalences
provide the precise formal interface needed for importing or proving
the four-color theorem.

Note: We do NOT prove the four-color theorem itself, but we show that
the standard formulation is equivalent to several other natural statements.
-/

open Polynomial Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Equivalence between `Colorable` and `IsProperColoring` -/

/-
A graph is `k`-colorable iff there exists a proper coloring with `Fin k` colors.
-/
theorem colorable_iff_exists_properColoring (G : SimpleGraph V) [DecidableRel G.Adj]
    (k : ℕ) :
    G.Colorable k ↔ Nonempty { c : V → Fin k // G.IsProperColoring c } := by
  constructor <;> intro h;
  · -- By definition of `Colorable`, if `G.Colorable k`, then there exists a coloring `c : V → Fin k` such that `c` is proper.
    obtain ⟨c, hc⟩ := h;
    exact ⟨ ⟨ c, fun { u v } huv => by simpa using hc huv ⟩ ⟩;
  · obtain ⟨ c, hc ⟩ := h;
    use c;
    exact?

/-
A graph is `k`-colorable iff it has at least one proper coloring, i.e.,
`numColorings G k > 0`.
-/
theorem colorable_iff_numColorings_pos (G : SimpleGraph V) [DecidableRel G.Adj]
    (k : ℕ) :
    G.Colorable k ↔ 0 < G.numColorings k := by
  convert colorable_iff_exists_properColoring G k using 1;
  rw [ ← Fintype.card_pos_iff ];
  convert Iff.rfl

/-
The four-color theorem can equivalently be stated using `IsProperColoring`.
-/
theorem four_color_iff_properColoring :
    (∀ {W : Type*} [Fintype W] [DecidableEq W] (G : SimpleGraph W)
        [DecidableRel G.Adj],
        G.Colorable 4 →
        Nonempty { c : W → Fin 4 // G.IsProperColoring c }) ∧
    (∀ {W : Type*} [Fintype W] [DecidableEq W] (G : SimpleGraph W)
        [DecidableRel G.Adj],
        Nonempty { c : W → Fin 4 // G.IsProperColoring c } →
        G.Colorable 4) := by
  constructor;
  · intro W _ _ G _ h;
    exact?;
  · grind +suggestions

end SimpleGraph