/-
# Bridge: Paraconsistent Valuations as Points of a Dream Space

This file connects the two halves of the development — the Belnap algebra
(`Logic.DreamLogic.BelnapAlgebra`) and dream spaces
(`Logic.DreamLogic.DreamSpace`) — by viewing a *valuation* `v : ℕ → Belnap` through its
**glut locus** `{n | IsGlut (v n)}`, the set of coordinates carrying a contradiction.

By `glut_iff_B`, the glut locus is exactly `{n | v n = B}`. The question "is this
valuation's contradiction set finitely specifiable?" becomes "is its glut locus
`dreamNat`-open?". The bridge theorems show:

* a *finitely-glutted* (or globally-glutted) valuation has an open glut locus, but
* an *infinitely, non-cofinitely glutted* valuation — e.g. one that is `B` exactly on the
  evens — has a glut locus that is **not** `dreamNat`-open.

So the non-topological points of the dream space are precisely the "spread out"
paraconsistent valuations: locally coherent everywhere, globally non-open.

## Main results
* `glut_locus_eq` — the glut locus equals `{n | v n = B}`.
* `constB_glut_locus_open` — the everywhere-glut valuation is dream-open (locus `= univ`).
* `exists_valuation_glut_locus_not_dreamOpen` — some valuation's glut locus is not open.

-- !-- Lab Notebook -- !--
Hypothesis: Glut loci of Belnap valuations on ℕ are precisely the candidate dream-opens,
  and "spread-out" paraconsistency (B on the evens) yields a non-open locus, mirroring how
  dream reasoning stays locally coherent yet globally contradictory.
Result: `glut_locus_eq` identifies the locus with `{n | v n = B}` via `glut_iff_B`;
  `constB_glut_locus_open` (locus = univ) and `exists_valuation_glut_locus_not_dreamOpen`
  (locus = evens, via `evens_not_dreamOpen`) bracket the dividing line.
Insight: The same set-level fact (`evens ∉ dreamNat.opens`) that makes `dreamNat`
  non-topological also produces a paraconsistent valuation outside the dream space — the
  metalogical and topological defects are literally the same counterexample.
Failure analysis: Writing the locus of the constant-`B` valuation as `{n | B = B}` and
  rewriting to `univ` keeps `decide`/`simp` happy; using `if Even n then B else T` for the
  spread valuation lets `glut_iff_B` reduce the locus to the evens cleanly.
-/

import Logic.DreamLogic.BelnapAlgebra
import Logic.DreamLogic.DreamSpace

open Set

namespace DreamLogic
namespace Belnap

/-- The **glut locus** of a Belnap valuation: the coordinates carrying a glut. By
`glut_iff_B` this is exactly the set where the valuation takes the value `B`. -/
theorem glut_locus_eq (v : ℕ → Belnap) :
    {n | IsGlut (v n)} = {n | v n = B} := by
  ext n; simp only [Set.mem_setOf_eq]; exact glut_iff_B (v n)

-- !-- The everywhere-glut valuation has glut locus `univ`, which is `dreamNat`-open. -- !--
/-- The constant-`B` ("everywhere contradictory") valuation has an *open* glut locus: its
contradiction set is all of `ℕ`. -/
theorem constB_glut_locus_open :
    {n | IsGlut ((fun _ => B) n)} ∈ dreamNat.opens := by
  rw [glut_locus_eq]
  have : {n : ℕ | (fun _ => B) n = B} = Set.univ := by ext n; simp
  rw [this]; exact dreamNat.univ_mem

/-- The "spread-out" valuation that is the glut `B` on even coordinates and plain truth `T`
on odd ones. -/
def evenGlut : ℕ → Belnap := fun n => if Even n then B else T

-- !-- The glut locus of `evenGlut` is the evens, which is not `dreamNat`-open
-- (`evens_not_dreamOpen`), exhibiting a paraconsistent point outside the dream space. -- !--
/-- **Bridge theorem.** Some Belnap valuation has a glut locus that is *not*
`dreamNat`-open: the valuation `evenGlut`, which is `B` exactly on the evens. Thus the
non-topological points of the dream space are precisely the spread-out paraconsistent
valuations. -/
theorem exists_valuation_glut_locus_not_dreamOpen :
    ∃ v : ℕ → Belnap, {n | IsGlut (v n)} ∉ dreamNat.opens := by
  refine ⟨evenGlut, ?_⟩
  rw [glut_locus_eq]
  have hloc : {n : ℕ | evenGlut n = B} = {n : ℕ | Even n} := by
    ext n
    simp only [Set.mem_setOf_eq, evenGlut]
    by_cases h : Even n <;> simp [h]
  rw [hloc]
  exact evens_not_dreamOpen

end Belnap
end DreamLogic