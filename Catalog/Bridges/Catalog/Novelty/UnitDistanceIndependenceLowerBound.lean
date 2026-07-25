import Mathlib
import Catalog.Novelty.UnitDistanceGraph
import Catalog.Novelty.IndependenceRatioLowerBound
import Catalog.Novelty.GreedyDegreeColoring
import Catalog.Novelty.UnitDistanceChromaticBridge

/-!
# The Minimum Independence Ratio Constraint for unit-distance graphs

This file assembles the geometric conclusion of the project: concrete *lower bounds* on the
independence ratio of finite planar unit-distance graphs, i.e. cases in which the ratio
provably **cannot fall below** a threshold — the positive side of the Erdős /
Matolcsi–Ruzsa–Varga–Zsámboki circle.

Building on

* `Catalog.Novelty.UnitDistanceGraph` (the graph `unitDistanceGraph p` of a point set),
* `Catalog.Novelty.IndependenceRatioLowerBound` (`i(G) ≥ 1/χ(G)`, `Colorable 4 ⇒ i ≥ 1/4`), and
* `Catalog.Novelty.GreedyDegreeColoring` (`χ(G) ≤ Δ(G) + 1`),

we prove:

* `unitDistanceGraph_indepRatio_ge_inv_chromaticNumber` — **every** finite unit-distance graph
  satisfies `i(G) ≥ 1/χ(G)` (no geometric hypothesis at all).
* `unitDistanceGraph_indepRatio_ge_inv_maxDegree_succ` — the constructive floor
  `i(G) ≥ 1/(Δ(G)+1)` from greedy colouring.
* `unitDistanceGraph_indepRatio_ge_quarter_of_maxDegree_le_three` — the headline **geometric
  criterion**: any finite planar unit-distance graph in which no point has more than `3` other
  points at unit distance has independence ratio at least `1/4`.  This is an unconditional,
  checkable class for which the Minimum Independence Ratio Constraint provably holds.

Together with the equilateral-triangle anchor (`i = 1/3 > 1/4`) this exhibits an *infinite*
family of planar unit-distance graphs meeting the `1/4` floor, and pins the search for a
hypothetical counterexample to graphs of maximum degree `≥ 4`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the grand claim "`i(G) ≥ 1/4` for all planar unit-distance graphs"
is equivalent to fractional `4`-colourability; a *checkable geometric sufficient condition*
should follow from bounding the local degree, since maximum degree `Δ` gives `χ ≤ Δ+1`.
Experiment (Experimenter): compose the constructive greedy bound `colorable_maxDegree_succ`
(`Colorable (Δ+1)`) with `Colorable.mono` to reach `Colorable 4` when `Δ ≤ 3`, then feed it to
`indepRatio_ge_quarter_of_colorable_four`.  For the unconditional bound, use the
chromatic-number reciprocal `indepRatio_ge_inv_chromaticNumber`.
Analysis (Analyst): "true but sharp only up to the colouring bound" — the degree criterion is
loose for lattice-like graphs (triangular lattice has `Δ = 6` yet `i = 1/3`), but it is exactly
tight against the `1/(Δ+1)` engine.  A counterexample to the grand conjecture, if any, must have
`Δ ≥ 4`; the low-degree regime is settled here.
Critique (Critic): the hypotheses are honest — `hpos` excludes the empty configuration (ratio
`0/0`), and `DecidableRel`/`DecidableEq` are only bookkeeping for `maxDegree` and colourings,
not mathematical content.  None of the theorems is vacuous: the triangle and every degree-`≤3`
unit-distance graph realise them.
Synthesis (PI): the pipeline geometry → degree bound → greedy colouring → independence ratio
delivers the *Minimum Independence Ratio Constraint* unconditionally for maximum degree `≤ 3`,
and reduces the general planar conjecture to the high-degree regime.
-- !-- end Lab Notes -- !--
-/

open scoped Classical
open UnitDistance

namespace UnitDistance

variable {V : Type*} [Fintype V] [DecidableEq V]

omit [DecidableEq V] in
/-- **Unconditional reciprocal bound.**  Every finite planar unit-distance graph has
independence ratio at least `1/χ(G)`. -/
theorem unitDistanceGraph_indepRatio_ge_inv_chromaticNumber
    (p : V → EuclideanSpace ℝ (Fin 2)) (hpos : 0 < Fintype.card V) :
    (1 : ℚ) / ((unitDistanceGraph p).chromaticNumber.toNat : ℚ)
      ≤ (unitDistanceGraph p).indepRatio :=
  SimpleGraph.indepRatio_ge_inv_chromaticNumber _ hpos

/-- **Constructive degree floor.**  Every finite planar unit-distance graph has independence
ratio at least `1/(Δ+1)`, where `Δ` is the maximum number of unit-distance neighbours of any
point. -/
theorem unitDistanceGraph_indepRatio_ge_inv_maxDegree_succ
    (p : V → EuclideanSpace ℝ (Fin 2)) [DecidableRel (unitDistanceGraph p).Adj]
    (hpos : 0 < Fintype.card V) :
    (1 : ℚ) / ((unitDistanceGraph p).maxDegree + 1 : ℕ)
      ≤ (unitDistanceGraph p).indepRatio :=
  SimpleGraph.indepRatio_ge_inv_of_colorable _ hpos
    (unitDistanceGraph p).colorable_maxDegree_succ

/-- **Headline geometric criterion.**  If in a finite planar point configuration no point has
more than `3` other points at unit distance (maximum degree `≤ 3`), then the induced
unit-distance graph has independence ratio at least `1/4`: the Minimum Independence Ratio
Constraint holds unconditionally on this class. -/
theorem unitDistanceGraph_indepRatio_ge_quarter_of_maxDegree_le_three
    (p : V → EuclideanSpace ℝ (Fin 2)) [DecidableRel (unitDistanceGraph p).Adj]
    (hpos : 0 < Fintype.card V)
    (hΔ : (unitDistanceGraph p).maxDegree ≤ 3) :
    (1 : ℚ) / 4 ≤ (unitDistanceGraph p).indepRatio := by
  have hcol : (unitDistanceGraph p).Colorable 4 :=
    (unitDistanceGraph p).colorable_maxDegree_succ.mono (by omega)
  exact SimpleGraph.indepRatio_ge_quarter_of_colorable_four _ hpos hcol

/-- The equilateral triangle satisfies the constraint with room to spare: `1/4 ≤ 1/3`. -/
theorem tri_indepRatio_ge_quarter :
    (1 : ℚ) / 4 ≤ (unitDistanceGraph triPoints).indepRatio := by
  rw [tri_indepRatio_eq]; norm_num

end UnitDistance