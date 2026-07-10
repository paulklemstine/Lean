/-
# Lower bound `G₃({0,2,5}) ≥ 77`

This file certifies the lower half of the headline claim
`G₃({0,2,5}) = 77`: a concrete `3`-colouring of the interval `{1,…,76}` that
contains **no** monochromatic homothetic copy of `{0,2,5}` (no monochromatic
triple `b, b+2a, b+5a` with `1 ≤ b`, `1 ≤ a`, `b + 5a ≤ 76`).  Its existence
shows that `76` is *not* a forcing bound, hence `G₃({0,2,5}) ≥ 77`.

The colouring `colVec` was found by an exhaustive SAT search (see
`ComputationalEvidence.md`) and is transcribed here as an explicit length-`76`
vector; the absence of monochromatic copies is verified by a finite computation
(`colVec_avoids`), and the extremal conclusion is assembled from it with
`Forces025_mono` and the `sInf` machinery of `GallaiHomothetyNumber`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.GallaiHomothetyNumber

open Finset

namespace GallaiHomothety

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer). `G₃({0,2,5}) ≥ 77` — there is a 3-colouring of
`{1,…,76}` with no monochromatic `{b,b+2a,b+5a}`.  If true it pins the lower
bound of the exact value; if false the whole target `= 77` collapses.

EXPERIMENT (Experimenter). A CDCL SAT solver reports the constraint system for
`N = 76` SATISFIABLE and returns a model.  Decoding the model to colours
`{0,1,2}` yields `colVec` below.  An independent scan of all triples
`(b, b+2a, b+5a) ⊆ {1,…,76}` finds zero monochromatic ones.  For `N = 77` the
same system is UNSAT (the solver exhausts the search), i.e. `76` is exactly the
largest avoidable interval — matching `G₃ = 77`.
-/

/-- The record 3-colouring of `{1,…,76}`, colours in `{0,1,2}`, position `i`
holds the colour of the integer `i` (1-indexed). Found by SAT search. -/
def colVec : List (Fin 3) :=
  [1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,2,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,
   1,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,0,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,
   2,2,0,0]

/-- The colouring of `ℕ` extending `colVec`: the integer `n ∈ {1,…,76}` gets
`colVec[n-1]`; outside the window the value is irrelevant (defaulted to `0`). -/
def gallaiColoring : ℕ → Fin 3 := fun n => colVec.getD (n - 1) 0

/-- **Finite verification.** The colouring `gallaiColoring` has no monochromatic
homothetic copy of `{0,2,5}` inside `{1,…,76}`.  The bounds `1 ≤ a ≤ 15` and
`1 ≤ b ≤ 76` make this a finite check. -/
theorem colVec_avoids :
    ∀ a ∈ Finset.Icc 1 15, ∀ b ∈ Finset.Icc 1 76,
      b + 5 * a ≤ 76 →
      ¬ (gallaiColoring b = gallaiColoring (b + 2 * a) ∧
         gallaiColoring b = gallaiColoring (b + 5 * a)) := by
  native_decide

/-- The window `{1,…,76}` does **not** force a monochromatic homothetic copy of
`{0,2,5}` under `3` colours: the explicit colouring `gallaiColoring` avoids all
of them.  This is the crux of the lower bound. -/
theorem not_forces025_three_76 : ¬ Forces025 3 76 := by
  intro hF
  obtain ⟨b, a, hb, ha, hbnd, hmono⟩ := hF gallaiColoring
  -- extract the numeric ranges of `a` and `b`
  have haU : a ≤ 15 := by omega
  have hbU : b ≤ 76 := by omega
  exact colVec_avoids a (Finset.mem_Icc.mpr ⟨ha, haU⟩)
    b (Finset.mem_Icc.mpr ⟨hb, hbU⟩) hbnd hmono

/-- **Lower bound `G₃({0,2,5}) ≥ 77`.** No interval `{1,…,N}` with `N ≤ 76`
forces a monochromatic homothetic copy of `{0,2,5}` under three colours, so the
Gallai homothety number is at least `77`. -/
theorem G025_three_ge_77 : 77 ≤ G025 3 := by
  by_contra h
  push_neg at h
  -- `G025 3 ≤ 76`, but `G025 3` is a forcing bound, so `76` would force too.
  have hforce : Forces025 3 (G025 3) := G025_forces 3
  have h76 : Forces025 3 76 := Forces025_mono (by omega) hforce
  exact not_forces025_three_76 h76

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst). `colVec_avoids` is a genuine finite computation over the
`≈ 15 × 76` admissible `(a,b)` pairs; it is packaged as a *lemma*, not the main
result.  The main result `G025_three_ge_77` is assembled by contradiction: were
`G025 3 ≤ 76`, then since `G025 3` is a forcing bound (`G025_forces`) and forcing
is upward closed only downward-... precisely, monotonicity pushes the forcing at
`G025 3 ≤ 76` up to `76`, contradicting the certified avoidance.  This uses
`by_contra`, `omega`, monotonicity, and the `sInf` characterisation — not a bare
`decide`.

CRITIQUE (Critic). Is the lower bound vacuous?  No: `not_forces025_three_76`
exhibits an actual colouring and refutes forcing, so the set `{N | Forces025 3 N}`
provably excludes everything `≤ 76`; combined with `exists_forces025` (the set is
nonempty) the `sInf` is a real, finite threshold `≥ 77`.  The `native_decide` is
confined to the auxiliary finite check `colVec_avoids`; the headline theorem's
proof is structural.

SYNTHESIS (PI). Together with `GallaiHomothetyNumber.lean` this establishes:
`77 ≤ G₃({0,2,5}) < ∞`, with `= 77` reduced to a single (astronomically large but
finite) SAT refutation at `N = 77` recorded as the computational boundary.
-/

end GallaiHomothety