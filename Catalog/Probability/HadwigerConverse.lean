/-
  The Converse of Hadwiger's Conjecture is False
  ==============================================

  Hadwiger's conjecture says `χ(G) ≥ k+1 ⟹ K_{k+1} ≼ G`.  A natural — and
  frequently conjectured — strengthening is that the two conditions are
  *equivalent*, i.e. that the chromatic number is **minor-monotone**:
  `H ≼ G ⟹ χ(H) ≤ χ(G)`.  This file refutes that with an explicit
  counterexample: the `6`-cycle is bipartite yet contracts onto a triangle.

  Main results:

  * `Hadwiger.C6_colorable_two`            : `C₆` is `2`-colourable.
  * `Hadwiger.completeMinor_three_C6`      : `K₃` is a minor of `C₆`
                                             (branch sets `{0,1}, {2,3}, {4,5}`).
  * `Hadwiger.chromaticNumber_not_minorMonotone` : the chromatic number is **not**
                                             minor-monotone.
  * `Hadwiger.converse_hadwiger_false`     : consequently the converse of
                                             Hadwiger's implication fails for
                                             `k = 2` (and hence the conjecture
                                             cannot be upgraded to an
                                             equivalence).

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): contraction can *raise* the chromatic number, so
    the Hadwiger implication is strictly one-directional.
  Experiment (Experimenter): the smallest witness is the `6`-cycle: pairing up
    consecutive vertices `{0,1}, {2,3}, {4,5}` gives three connected, pairwise
    disjoint sets joined by the edges `1–2`, `3–4`, `5–0`, hence a `K₃` model,
    while the parity colouring shows `χ(C₆) = 2`.
  Analysis (Analyst): the phenomenon is exactly the failure of *odd* structure to
    be preserved under contraction — a bipartite graph can contract onto an odd
    cycle whenever it contains a cycle of length `≥ 4`.
  Critique (Critic): the witness must be checked to really be `C₆`
    (`SimpleGraph.cycleGraph 6`) and the colouring must be verified on all `36`
    ordered pairs; both are done by `decide` inside the proofs, but the
    surrounding statements are non-trivial mathematical claims.
  Synthesis (PI): Hadwiger's conjecture is an implication, never an equivalence;
    minor-closed classes therefore give upper bounds on `χ` only through the
    *excluded* minor, never through a contracted witness.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerK3

namespace Hadwiger

open SimpleGraph

/-- The `6`-cycle. -/
abbrev C6 : SimpleGraph (Fin 6) := cycleGraph 6

/-- The parity colouring shows `C₆` is bipartite. -/
theorem C6_colorable_two : C6.Colorable 2 := by
  refine ⟨Coloring.mk (fun i => if i.val % 2 = 0 then 0 else 1) ?_⟩
  intro x y hxy
  revert hxy
  fin_cases x <;> fin_cases y <;> decide

/-- Contracting the three pairs `{0,1}`, `{2,3}`, `{4,5}` turns `C₆` into a
triangle: `K₃` is a minor of `C₆`. -/
theorem completeMinor_three_C6 : CompleteMinor 3 C6 := by
  have a01 : C6.Adj 0 1 := by decide
  have a23 : C6.Adj 2 3 := by decide
  have a45 : C6.Adj 4 5 := by decide
  have a12 : C6.Adj 1 2 := by decide
  have a34 : C6.Adj 3 4 := by decide
  have a50 : C6.Adj 5 0 := by decide
  refine completeMinor_three_of_triple (S0 := {0, 1}) (S1 := {2, 3}) (S2 := {4, 5})
    ⟨0, by simp⟩ ⟨2, by simp⟩ ⟨4, by simp⟩ ?_ ?_ ?_
    (setConnected_pair a01) (setConnected_pair a23) (setConnected_pair a45)
    ⟨1, by simp, 2, by simp, a12⟩ ⟨0, by simp, 5, by simp, a50.symm⟩
    ⟨3, by simp, 4, by simp, a34⟩ <;>
  · rw [Set.disjoint_left]
    rintro a (rfl | rfl) <;> simp

/-- **The chromatic number is not minor-monotone.**  There are graphs `H ≼ G`
with `χ(H) > χ(G)`: contraction of a bipartite graph can create a triangle. -/
theorem chromaticNumber_not_minorMonotone :
    ∃ (V W : Type) (G : SimpleGraph V) (H : SimpleGraph W),
      MinorTheory.MinorModel.IsMinor H G ∧ G.Colorable 2 ∧ ¬ H.Colorable 2 := by
  refine ⟨Fin 6, Fin 3, C6, ⊤, completeMinor_three_C6, C6_colorable_two, ?_⟩
  intro hcol
  have h := chromaticNumber_le_iff_colorable.mpr hcol
  rw [chromaticNumber_top] at h
  have h3 : (3 : ℕ) ≤ 2 := by exact_mod_cast h
  omega

/-- **The converse of Hadwiger's implication is false.**  Having `K₃` as a minor
does not force the chromatic number up to `3`. -/
theorem converse_hadwiger_false :
    ∃ (V : Type) (G : SimpleGraph V), CompleteMinor 3 G ∧ G.Colorable 2 :=
  ⟨Fin 6, C6, completeMinor_three_C6, C6_colorable_two⟩

end Hadwiger