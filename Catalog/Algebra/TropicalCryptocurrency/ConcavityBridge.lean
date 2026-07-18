import Algebra.TropicalCryptocurrency.Hash
import Bridges.TropicalHecke.MinPlusAlgebra

/-!
# Concavity Bridge for Two-Coordinate Tropical Hashing

The two-coordinate hash is the evaluation of a min-plus expression consisting
of one tropical sum of two variables.  It therefore inherits concavity from the
general expression semantics.  This links the exact collision analysis to the
existing algebraic theory of min-plus expressions.

-- !-- Lab Notes -- !--
Hypothesis: The tropical hash should possess geometric structure beyond its
fiber description, specifically concavity along line segments.
Experiment: The two-coordinate hash was represented by the tropical expression
`x₀ ⊕ x₁` and the general expression concavity theorem was specialized to it.
Analysis: Concavity follows from the minimum of affine coordinate functions;
this geometric regularity coexists with, rather than prevents, the universal
collision phenomenon.
Critique: The present bridge treats two coordinates directly.  Arbitrary finite
coordinate families require an iterated expression or a separate finite-infimum
concavity theorem.
Synthesis: Exact fibers explain inversion and collisions, while expression
concavity identifies the associated optimization geometry.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalCryptocurrency

/-- The minimum of two coordinate values is concave along every real line
segment with parameter in the unit interval. -/
theorem tropical_pair_concave (v w : Fin 2 → ℝ) (t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    min ((1 - t) * v 0 + t * w 0) ((1 - t) * v 1 + t * w 1) ≥
      (1 - t) * min (v 0) (v 1) + t * min (w 0) (w 1) := by
  let e : MinPlusExpr 2 :=
    MinPlusExpr.trop_add (MinPlusExpr.var 0) (MinPlusExpr.var 1)
  exact MinPlusExpr.eval_concave e v w t ht0 ht1

end TropicalCryptocurrency