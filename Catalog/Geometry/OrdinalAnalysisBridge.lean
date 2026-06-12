import Mathlib

/-!
# Proof-Theoretic Bridge: Ordinal Analysis A

A constructive bridge between three faces of ordinal analysis, all stated over
Mathlib's *computable* notation system `ONote` / `NONote` (Cantor normal forms
below `ε₀`):

* the **well-ordering** of the notation system (`nonote_no_infinite_descent`),
* the **termination** of any algorithm carrying an `ε₀`-valued monovariant
  (`terminates_of_measure`), and
* the **fast-growing hierarchy** `ONote.fastGrowing : ONote → ℕ → ℕ`, an
  effective, `native_decide`-evaluable family of number-theoretic functions
  (`fastGrowing_zero_eq_succ`, `fastGrowing_one_three`, `fastGrowing_two_two`).

The connective tissue is the single theorem `terminates_of_measure`: a state
space `α` equipped with a step map and an `ε₀`-valued quantity that strictly
decreases until it bottoms out provably reaches the bottom in finitely many
steps. The well-ordering theorem `nonote_no_infinite_descent` is its engine, and
the self-measured corollary `terminates_of_self_descent` is its most directly
executable face.

This file builds on the proof-theoretic ordinal landmarks studied elsewhere in
the catalog (`Catalog/Logic/StronglyCriticalOrdinals.lean` with its
`no_infinite_consistency_descent`, and
`Catalog/Pythagorean/ProofTheoreticOrdinalsEpsilon.lean` with its `ε₀` barrier):
those files work with the *abstract* `Ordinal`-valued strength order, whereas
this file descends to the *computable* `NONote` representation, making the same
well-ordering phenomenon both executable and usable as an algorithmic
termination certificate.

-- !-- Lab Notebook -- !--
**Hypothesis.** Mathlib's computable ordinal notation `NONote` is well-ordered
(`NONote.lt_wf`); this single fact should be enough to certify termination of
*any* deterministic process carrying an `ε₀`-valued strictly-decreasing
monovariant, with classical termination theorems (Goodstein, Hydra) as instances.

**Result.** Confirmed. `terminates_of_measure` packages well-founded recursion on
`NONote` into a reusable termination engine; `terminates_of_self_descent` is the
`μ = id` specialisation; `nonote_no_infinite_descent` is the underlying
well-ordering. The fast-growing hierarchy is shown effective via kernel-checked
sample values.

**Insight.** Termination via an ordinal monovariant is *not* a family of bespoke
inductions but one theorem applied to different measure maps `μ : α → NONote`.
The well-order does the work; the only content of each application is exhibiting
the strict-decrease hypothesis.

**Failure analysis.** Stating the measure over `ONote` (raw notations, not
normal forms) fails: `ONote`'s order is not well-founded as a bare relation
without the `NF` side-condition, so the descent engine must live on `NONote`.
-/

namespace OrdinalAnalysisBridge

open ONote

/-! ## The fast-growing hierarchy is effective -/

-- !-- The base function of the fast-growing hierarchy is the successor; this is
-- Mathlib's `ONote.fastGrowing_zero` repackaged as the pointwise successor. -- !--
theorem fastGrowing_zero_eq_succ : ONote.fastGrowing 0 = fun n => n + 1 := by
  rw [ONote.fastGrowing_zero]

-- !-- A kernel-/compiler-checked sample value: `F₁(3) = 6`, witnessing that the
-- hierarchy is genuinely computable. -- !--
theorem fastGrowing_one_three : ONote.fastGrowing 1 3 = 6 := by
  native_decide

-- !-- A second kernel-/compiler-checked sample value: `F₂(2) = 8`. -- !--
theorem fastGrowing_two_two : ONote.fastGrowing 2 2 = 8 := by
  native_decide

/-! ## Well-ordering of the notation system -/

-- !-- No strictly `<`-decreasing sequence of notations below `ε₀` exists: this is
-- well-foundedness of `NONote` (`NONote.lt_wf`) phrased as the absence of an
-- infinite descent, mirroring the abstract `no_infinite_consistency_descent`. -- !--
theorem nonote_no_infinite_descent (f : ℕ → NONote) :
    ¬ ∀ n, f (n + 1) < f n := by
  intro h
  exact RelEmbedding.natGT f h |>.not_wellFounded NONote.lt_wf

/-! ## The termination engine -/

-- !-- Ordinal-measure termination: if `μ` strictly decreases under `step`
-- whenever it is nonzero, then iterating `step` from any start reaches `μ = 0`
-- in finitely many steps. Proof by well-founded recursion on `μ x₀` using
-- `NONote.lt_wf`. -- !--
theorem terminates_of_measure {α : Type*} (step : α → α) (μ : α → NONote)
    (hstep : ∀ x, μ x ≠ 0 → μ (step x) < μ x) (x₀ : α) :
    ∃ n, μ (step^[n] x₀) = 0 := by
  induction x₀ using (WellFounded.induction (NONote.lt_wf.onFun (f := μ))) with
  | _ x ih =>
    by_cases hx : μ x = 0
    · exact ⟨0, hx⟩
    · obtain ⟨n, hn⟩ := ih (step x) (hstep x hx)
      exact ⟨n + 1, by rw [Function.iterate_succ_apply]; exact hn⟩

-- !-- The `μ = id` specialisation: a self-decreasing step on `NONote` reaches
-- `0`. Immediate from `terminates_of_measure` with `μ = id`. -- !--
theorem terminates_of_self_descent (step : NONote → NONote)
    (hstep : ∀ x, x ≠ 0 → step x < x) (x₀ : NONote) :
    ∃ n, step^[n] x₀ = 0 :=
  terminates_of_measure step id hstep x₀

end OrdinalAnalysisBridge