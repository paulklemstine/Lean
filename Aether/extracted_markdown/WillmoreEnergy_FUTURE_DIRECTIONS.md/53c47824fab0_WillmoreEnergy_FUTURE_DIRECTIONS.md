# Future Directions: Willmore Energy Lower Bounds by Genus

The file `WillmoreEnergy.lean` establishes the elementary half of the Willmore
story in a clean measure-theoretic abstraction: the pointwise square identity
`H² - K = ((κ₁-κ₂)/2)²`, its integral consequence `∫ K ≤ W`, the Gauss–Bonnet
bound `2π·χ ≤ W`, the sharp `4π` bound for genus `0`, the universal `4π` bound
from a Gauss-map degree input, and a precise statement of *why* the elementary
argument degenerates for higher genus. Below are five concrete, falsifiable
directions that build directly on these results and connect to the catalog files
`DiscreteGaussBonnet.lean` (`total_curvature_eq_genus`,
`eulerChar_eq_two_sub_two_mul_genus`) and `GenusFormula.lean`.

## 1. A quantitative umbilic-defect lower bound

The identity `willmoreDensity_sub_gaussCurv` says `W - ∫K = ∫((κ₁-κ₂)/2)²`, the
total *umbilic defect*. Conjecture: for any closed surface,
`W ≥ 2π·χ + c · diam(spec(II))²` for an explicit constant, where the second term
measures how far the surface is from being totally umbilic in an averaged sense.
**The key insight is** that the slack in `gauss_le_willmore` is *itself* a
geometrically meaningful energy (the traceless second fundamental form), so the
inequality can be upgraded to an identity-with-remainder rather than a bare
bound. **Why now?** The remainder is already available in Lean as
`∫ x, ((k1 x - k2 x)/2)^2 ∂μ`; one only needs `integral_eq_integral_add` style
splitting, which is fully supported in current Mathlib measure theory.

## 2. Rigidity: characterizing equality `W = ∫K`

`willmoreDensity_eq_gaussCurv_iff` proves the pointwise rigidity `H² = K ↔ κ₁=κ₂`.
The integral upgrade — `W = ∫K` (with both integrable and the defect `≥ 0`) forces
`κ₁ = κ₂` μ-almost everywhere (total umbilicity) — should follow from
`MeasureTheory.integral_eq_zero_iff_of_nonneg`. **The key insight is** that the
nonnegative defect integrand vanishes in integral iff it vanishes a.e., turning a
pointwise iff into an a.e. rigidity theorem with no new geometry. **Why now?** The
nonnegativity lemma `willmoreDensity_nonneg` plus the square identity are already
proved, so the only missing ingredient is a single standard Mathlib lemma about
a.e.-vanishing of nonnegative integrands.

## 3. Genus-monotonicity of the elementary obstruction

`gaussBonnet_bound_vacuous_high_genus` shows `4π(1-g) ≤ 0` for `g ≥ 1`.
Strengthen this to a *monotone family*: the elementary lower bound
`b(g) = 4π(1-g)` is strictly decreasing in `g`, and the gap between `b(g)` and the
true sharp bound `β(g)` (e.g. `β(1) = 2π²`) is strictly increasing. **The key
insight is** that the elementary Gauss–Bonnet method loses exactly `2π` of
detectable energy per unit genus, which can be stated and proved as a clean real
inequality `b(g+1) = b(g) - 4π`. **Why now?** This is a finite real-arithmetic
statement reachable by `linarith`/`nlinarith` on top of the existing genus
machinery in `DiscreteGaussBonnet.lean`, requiring no analysis at all.

## 4. The Li–Yau multiplicity bound via the set-integral method

`willmore_ge_fourPi_of_setGauss` already isolates the degree mechanism: a region
contributing `≥ 4π` of positive Gauss curvature forces `W ≥ 4π`. Generalize to
the Li–Yau inequality: a surface with a point of multiplicity `k` satisfies
`W ≥ 4πk`. **The key insight is** that `k` disjoint sheets each contribute an
independent `4π` of Gauss-map degree, so the single-set bound becomes a finite
sum over `k` disjoint measurable regions via additivity of the set integral.
**Why now?** `setIntegral_le_integral` and finite additivity of restricted
integrals are present in Mathlib, so the `k = 1` proof here extends to general
`k` by induction with no new analytic input.

## 5. The Marques–Neves bound `2π² ≤ W` for tori (the open target)

`willmore_torus_conjecture` records the genus-1 sharp bound as a `sorry`. A
tractable intermediate target is the *conformal/min-max width* reformulation:
define an abstract "width" functional on the abstract surface model and prove
that (i) the Willmore energy dominates the width and (ii) the width of any
genus-1 configuration is `≥ 2π²`. **The key insight is** that the full
Almgren–Pitts machinery can be *axiomatized* at the level of a width functional
satisfying a small list of monotonicity/normalization properties, reducing the
deep theorem to a finite combinatorial-analytic core that Lean can verify.
**Why now?** The abstract measure-space surface model in this file is exactly the
right setting to host such a width functional without committing to a smooth
manifold structure, so the reformulation can be prototyped immediately on top of
`willmoreEnergy`.
