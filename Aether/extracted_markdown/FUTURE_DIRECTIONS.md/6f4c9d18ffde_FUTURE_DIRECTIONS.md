# FUTURE_DIRECTIONS — Tropicalization of Arithmetic Height on Projective Pairs

Cycle artifacts:
- `Catalog/Bridges/TropicalProjectiveHeight.lean` (core, `import Mathlib` only)
- `Catalog/Bridges/TropicalProjectiveHeightBridge.lean` (fusion with the catalog:
  `ArithmeticVCDim.ratArithHeight` and `CategoricalTropicalUltrametric.UltraNormObj`)

## Synthesis

This cycle asked a single falsifiable question: can the height on projective
rational points `[a:b] ∈ ℙ¹(ℚ)` be tropicalized into *exact* max-plus
(ultrametric) inequalities, with no archimedean error term, in the integer-pair
model? The answer is a sharp dichotomy. On the **multiplicative** side the answer
is YES and unconditional: the (un-normalized) height `pairHeight a b = max(|a|,|b|)`
is exactly submultiplicative under the coordinatewise projective product
(`pairHeight_mul_le`), which in logarithms is precisely the tropical law
`Htrop(xy) ≤ Htrop x + Htrop y` with zero defect. On the **additive** side the
answer is NO: projective (fraction) addition obeys only a quasi-ultrametric bound
with an explicit archimedean defect `C = 2` (`pairHeight_add_le`), and that defect
is genuinely necessary — the all-ones witness `1/1 + 1/1 = 2/1` already violates
the defect-free bound (`pairHeight_add_defect_necessary`, an axiom-free disproof).

The structural insight that emerged is that the obstruction is exactly the
archimedean triangle inequality `|x+y| ≤ |x|+|y|` and nothing else. So the
defect-free ultrametric object the concept hoped for *does* exist — but only on
the **nonarchimedean** side. We realized it concretely as the tropical degree
valuation on the projective line over a function field: `tropDegNorm p = 2^{deg p}`
is exactly multiplicative (`tropDegNorm_mul`, using `deg(pq)=deg p+deg q` over a
field) and exactly ultrametric (`tropDegNorm_add_le`, using
`deg(p+q) ≤ max(deg p, deg q)`), and these four lemmas assemble into a genuine
catalog `UltraNormObj` (`projectiveTropicalUltra`). The catalog connection is made
in both directions: the arithmetic side via `projHeight_le_ratArithHeight`
(the projective max-height refines the catalog additive `ratArithHeight` for free),
and the tropical/ultrametric side via the `UltraNormObj` construction.

What this teaches the next team: "tropicalizing a height" is not a single move but
a choice of *place*. At the archimedean place exactness fails by a bounded,
explicit, tight defect; at every nonarchimedean place exactness is automatic. The
defect is therefore a measurable invariant, not a nuisance — and quantifying how
it accumulates (and whether a single combined object can carry both behaviours) is
the natural next program.

## Results Summary

- `projHeight_scale_invariant`: proved — the gcd-normalized height is invariant
  under common scaling, so it is well-defined on `ℙ¹(ℚ)`.
- `projHeight_pos`: proved — genuine projective points have height ≥ 1.
- `projHeight_le_height_sum`: proved — projective height ≤ `|num| + den` for a
  reduced fraction (catalog-bridge precursor).
- `pairHeight_mul_le`: proved — exact tropical submultiplicativity
  `Htrop(xy) ≤ Htrop x + Htrop y` (zero defect).
- `pairHeight_add_le`: proved — quasi-ultrametric addition with explicit
  archimedean defect `C = 2`.
- `pairHeight_add_defect_necessary`: proved (disproof of exactness) — the
  defect-free archimedean ultrametric law is FALSE; defect 2 is tight.
- `tropDegNorm_zero`, `tropDegNorm_neg`, `tropDegNorm_mul`, `tropDegNorm_add_le`:
  proved — the tropical degree valuation is an exact ultrametric multiplicative
  norm into ℕ.
- `projHeight_le_ratArithHeight` (bridge): proved — projective height is dominated
  by the catalog `ArithmeticVCDim.ratArithHeight`.
- `projectiveTropicalUltra` (bridge): constructed — a genuine catalog
  `CategoricalTropicalUltrametric.UltraNormObj` from tropical degree data.
- `pairHeight_nsum_le_conjecture`: conjecture (`sorry`) — the n-fold projective
  sum has height ≤ `n · ∏ heights`; generalizes the `n = 2` defect.

## Research Directions

### Direction 1: The n-fold defect is exactly n
**Hypothesis**: For `n` integer pairs `(aᵢ,bᵢ)` with `bᵢ ≠ 0`, the common-denominator
projective sum satisfies `pairHeight(∑ᵢ aᵢ·∏_{j≠i} bⱼ, ∏ᵢ bᵢ) ≤ n · ∏ᵢ pairHeight(aᵢ,bᵢ)`,
and the constant `n` is best possible (witnessed by all `aᵢ = bᵢ = 1`).
**Test**: Prove `pairHeight_nsum_le_conjecture` by `Finset` induction iterating
`pairHeight_add_le` and `pairHeight_mul_le`; for sharpness, evaluate the all-ones
family and show the ratio `pairHeight(sum)/∏ heights → n`.
**Why now**: The `n = 2` case is fully proved (`pairHeight_add_le` +
`pairHeight_add_defect_necessary`); only the inductive bookkeeping over `Finset.univ.erase i`
remains, which this cycle already set up in the statement.
**If true**: The archimedean defect becomes a clean linear functional of the number
of summands — a Mahler-style measure on max-plus arithmetic.
**If false**: The true growth rate of the defect (e.g. `⌈log₂ n⌉` from balanced
pairing) is itself a new and sharper invariant.

### Direction 2: Balanced summation lowers the defect to logarithmic
**Hypothesis**: Summing `n` projective points by a balanced binary tree instead of
left-to-right reduces the height defect from `Θ(n)` to `2^{⌈log₂ n⌉}`, i.e.
`pairHeight(tree-sum) ≤ 2^{⌈log₂ n⌉} · ∏ heights`.
**Test**: Define a binary-tree fold of fraction addition and prove the bound by
induction on tree depth, reusing `pairHeight_add_le` at each node; compare against
the linear bound of Direction 1 on explicit families.
**Why now**: `pairHeight_add_le` is associative-friendly (it bounds a single
`a/b + c/d` step), so the defect provably composes multiplicatively along any
parenthesization — the depth, not the count, is what matters.
**If true**: Order of summation is an *arithmetic-complexity* resource for height
control, linking max-plus height to circuit-depth lower bounds in the catalog.
**If false**: There is a parenthesization-independent lower bound on the defect,
revealing an intrinsic archimedean cost of addition.

### Direction 3: A two-place hybrid object carrying both defects
**Hypothesis**: There is a single `UltraNormObj`-like structure on `ℙ¹(ℚ)` whose
norm is `max` over the archimedean place (with its tight defect 2) and all
`p`-adic places, and for which a *quantitative* (defect-carrying) version of
`UltraNormObj.norm_add` holds with the constant equal to the product formula's
archimedean contribution.
**Test**: Generalize `CategoricalTropicalUltrametric.UltraNormObj` to a
`QuasiUltraNormObj` with `norm_add x y ≤ C · max (norm x) (norm y)` and instantiate
it once with `tropDegNorm` (`C = 1`) and once with `pairHeight` (`C = 2`); prove a
functor from the exact objects to the quasi objects.
**Why now**: This cycle produced *both* an exact object (`projectiveTropicalUltra`,
`C = 1`) and a proven-tight quasi object (`pairHeight`, `C = 2`), so the common
generalization is forced and immediately populated with two instances.
**If true**: The catalog gains a defect-graded category interpolating tropical and
archimedean heights — a home for the product formula.
**If false**: The archimedean defect cannot be encoded by a single multiplicative
constant, indicating the need for an additive (rather than scaling) correction term.

### Direction 4: Northcott finiteness for the projective height
**Hypothesis**: For every bound `B`, the set `{[a:b] ∈ ℙ¹(ℚ) : projHeight a b ≤ B}`
is finite, with cardinality `Θ(B²)`.
**Test**: Inject the bounded set into `{(a,b) : |a|,|b| ≤ B}` via the reduced
representative (using `projHeight_scale_invariant` for well-definedness) and count;
prove finiteness in Lean via `Set.Finite` of the integer box, then refine to the
asymptotic via coprimality density.
**Why now**: `projHeight_scale_invariant` gives canonical reduced representatives
and `projHeight_pos` bounds them away from 0, so the bounded set embeds into a
finite box with no further theory required.
**If true**: Connects the projective height directly to the catalog's Northcott /
trace-counting machinery in `ArithmeticVCDimension.lean`, enabling height-stratified
VC bounds for `ℙ¹`-valued parameters.
**If false** (only possible if the embedding is mis-stated): pinpoints the exact
normalization needed for Northcott to hold, sharpening the definition.

### Direction 5: Tropical cross-ratio as an ultrametric distance on ℙ¹
**Hypothesis**: The cross-difference `d([a:b],[c:d]) := tropDegNorm`-image of the
determinant `ad - bc` (over the function-field model) defines an actual ultrametric
on `ℙ¹(F(X))`, i.e. `d(x,z) ≤ max(d(x,y), d(y,z))`, descending to the quotient by
scaling.
**Test**: Express `ad-bc` under scaling and prove the strong triangle inequality
from `tropDegNorm_add_le` and `tropDegNorm_mul`; check the quotient is well-defined
using a degree analogue of `projHeight_scale_invariant`.
**Why now**: The exact ultrametric norm `tropDegNorm` is now available with both
`mul` and `add` laws proved, which are exactly the two ingredients a determinant
cross-ratio distance needs.
**If true**: Produces a concrete `UltraNormObj`-valued metric on projective space —
a tropical Berkovich-style distance, seeding moduli/automorphic follow-ups.
**If false**: The determinant must be normalized (e.g. by `gcd`/content) before it
is ultrametric, identifying the correct projective invariant.
