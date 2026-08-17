import Mathlib
import Geometry.SublevelDuality.Homogeneous
import output-final_aristotle.output-final_aristotle.Incomplete.Pythagorean.Duality

/-
# A concrete, non-vacuous instance of the RC sublevel duality

To certify that the abstract duality of `Duality.lean` is *not vacuous*, we work
out an explicit pair of RC functions on the plane `ℝ × ℝ` whose polarity map is the
coordinate swap `L(x, y) = (y, x)` (a genuine, non-identity continuous linear
equivalence, `ContinuousLinearEquiv.prodComm`).

* `p(x,y) = |x|`,  `q(x,y) = |x| + |y|`   so   `f = p/q = |x| / (|x|+|y|)`.
* `p°(x,y) = |y|`, `q°(x,y) = |x| + |y|`  so   `f° = |y| / (|x|+|y|)`.

These are non-negative, positively homogeneous (degree 1) functions, and the swap
`L` intertwines the two RC functions exactly: `f° ∘ L = f`.  Therefore every
sublevel set of `f` is homeomorphic — via the linear map `L` — to the corresponding
sublevel set of `f°`, and their homology groups agree in all degrees.  This is the
duality of `Duality.lean` instantiated on concrete, visibly distinct subsets of the
plane (two "wedges" pointing along different axes).

## Catalog connections
Instantiates `Geometry.SublevelDuality.sublevelHomeo`, `coneSubHomeo`,
`sublevel_homotopyEquiv` (from `Duality.lean`) on `ratio`/`coneSub` and `IsHomog`
(from `Homogeneous.lean`).
-/

namespace Geometry.SublevelDuality.Examples

open Set Geometry.SublevelDuality

/-- The numerator gauge `p(x,y) = |x|`. -/
noncomputable def pEx : ℝ × ℝ → ℝ := fun v => |v.1|
/-- The denominator gauge `q(x,y) = |x| + |y|`. -/
noncomputable def qEx : ℝ × ℝ → ℝ := fun v => |v.1| + |v.2|
/-- The dual numerator gauge `p°(x,y) = |y|`. -/
noncomputable def pEx' : ℝ × ℝ → ℝ := fun v => |v.2|
/-- The dual denominator gauge `q°(x,y) = |x| + |y|`. -/
noncomputable def qEx' : ℝ × ℝ → ℝ := fun v => |v.1| + |v.2|

/-- The polarity map for this example: the coordinate swap, a linear homeomorphism. -/
noncomputable def swap : (ℝ × ℝ) ≃L[ℝ] (ℝ × ℝ) := ContinuousLinearEquiv.prodComm ℝ ℝ ℝ

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the abstract polarity duality must be realisable on
--   an honest, computable pair of RC functions with a non-identity linear map.
-- Experiment (Experimenter): take the axis-wedge ratios `|x|/(|x|+|y|)` and
--   `|y|/(|x|+|y|)` and the coordinate swap; verify homogeneity, non-negativity,
--   and the intertwining identity `f° ∘ swap = f` by `abs_mul` + `add_comm`.
-- Analysis (Analyst): the intertwining is a one-line `add_comm` once the gauges
--   are written out — confirming that *all* the topological force lives in the
--   linearity of the polarity map, exactly as the abstract proof predicts.
-- Critique (Critic): the two sublevel sets are genuinely different subsets of the
--   plane (wedges around the x- vs y-axis), so the homeomorphism is non-trivial;
--   the example rules out the "vacuously equal sets" failure mode.

theorem pEx_homog : IsHomog pEx := by
  intro t ht v
  simp only [pEx, Prod.smul_fst, smul_eq_mul, abs_mul, abs_of_nonneg ht]

theorem qEx_homog : IsHomog qEx := by
  intro t ht v
  simp only [qEx, Prod.smul_fst, Prod.smul_snd, smul_eq_mul, abs_mul, abs_of_nonneg ht]
  ring

theorem pEx'_homog : IsHomog pEx' := by
  intro t ht v
  simp only [pEx', Prod.smul_snd, smul_eq_mul, abs_mul, abs_of_nonneg ht]

theorem qEx'_homog : IsHomog qEx' := by
  intro t ht v
  simp only [qEx', Prod.smul_fst, Prod.smul_snd, smul_eq_mul, abs_mul, abs_of_nonneg ht]
  ring

theorem pEx_nonneg (v : ℝ × ℝ) : 0 ≤ pEx v := abs_nonneg _
theorem qEx_nonneg (v : ℝ × ℝ) : 0 ≤ qEx v := by simp only [qEx]; positivity

/-- **The polarity intertwining identity** `f° ∘ swap = f` holds on the nose. -/
theorem ratio_intertwine (v : ℝ × ℝ) :
    ratio pEx' qEx' (swap v) = ratio pEx qEx v := by
  simp only [ratio, swap, pEx', qEx', pEx, qEx]
  show |v.1| / (|v.2| + |v.1|) = |v.1| / (|v.1| + |v.2|)
  rw [add_comm]

/-- The swap carries each sublevel cone of `f` onto the corresponding cone of `f°`. -/
theorem cone_intertwine (c : ℝ) (v : ℝ × ℝ) :
    v ∈ coneSub pEx qEx c ↔ swap v ∈ coneSub pEx' qEx' c := by
  simp only [coneSub, swap, mem_setOf_eq, pEx, qEx, pEx', qEx']
  show (0 < |v.1| + |v.2| ∧ |v.1| ≤ c * (|v.1| + |v.2|)) ↔
       (0 < |v.2| + |v.1| ∧ |v.1| ≤ c * (|v.2| + |v.1|))
  rw [add_comm (|v.1|) (|v.2|)]

/-- **Concrete duality homeomorphism** of the RC sublevel sets via the swap. -/
noncomputable def exampleHomeo (c : ℝ) :
    {v // ratio pEx qEx v ≤ c} ≃ₜ {w // ratio pEx' qEx' w ≤ c} :=
  sublevelHomeo swap (ratio pEx qEx) (ratio pEx' qEx') ratio_intertwine c

/-- **Concrete duality homeomorphism** of the division-free sublevel cones. -/
noncomputable def exampleConeHomeo (c : ℝ) :
    {v // v ∈ coneSub pEx qEx c} ≃ₜ {w // w ∈ coneSub pEx' qEx' c} :=
  coneSubHomeo swap pEx qEx pEx' qEx' c (cone_intertwine c)

/-- The two concrete sublevel sets have the same homotopy type. -/
theorem example_homotopyEquiv (c : ℝ) :
    Nonempty (ContinuousMap.HomotopyEquiv
      {v // ratio pEx qEx v ≤ c} {w // ratio pEx' qEx' w ≤ c}) :=
  sublevel_homotopyEquiv swap (ratio pEx qEx) (ratio pEx' qEx') ratio_intertwine c

end Geometry.SublevelDuality.Examples