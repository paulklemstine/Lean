# Future Directions: Tropical Automorphic Forms on the Berggren Tree

This cycle established the basic dictionary

> Berggren tree (primitive Pythagorean triples)  ⟷  tropical (max-plus) Hecke
> eigenforms  ⟷  ultrametric valuation depth,

formalized in `Catalog/Bridges/TropicalBerggrenAutomorphic.lean`. The main proven
facts are:

* the Berggren monoid action is a cocycle (`applyWord_append`, `treeTriple_append`);
* the light-cone / positivity invariant `Good` propagates to **every** tree vertex
  (`treeTriple_good`, `treeTriple_on_cone`);
* the **depth** function is an *exact tropical harmonic eigenform of weight 1*, and
  the whole affine-in-depth family `m·|w|+c` is harmonic
  (`depth_isMaxTropForm`, `depth_isMinTropForm`, `affine_isMaxTropForm`,
  `affine_isMinTropForm`);
* the **hypotenuse** form is only a *quasi*-eigenform: the max-plus Hecke operator
  always selects the B-branch (`heckeMax_treeHyp`) and its multiplicative growth is
  pinned in `(5, 7]` (`heckeMax_treeHyp_lower/upper`), with strict growth on every
  branch (`treeHyp_strict_mono_step`) and two-sided exponential control
  (`treeHyp_upper`, `treeHyp_Bspine_lower`).

The conjectures below are concrete, falsifiable, and each comes with a suggested
Lean target shape.

---

## Conjecture 1 (Tropical spectral gap of the hypotenuse form)

The hypotenuse quasi-eigenvalue lives in `(5, 7]` after one Hecke step, but the
*long-run* tropical Lyapunov exponent should be sharper. Define the depth-`n`
max-spine value `M(n) := max over |w|=n of treeHyp w`. 

**Conjecture.** `M(n) = treeHyp (List.replicate n 1)` for all `n` (the all-B spine
is globally maximal, not just locally), and `M(n+1) / M(n) → ` a single limit
`ρ ∈ (5,7)`. Equivalently the *additive* sequence `log₅ M(n) − (n+1)` converges.

* Testable Lean milestone: `treeHyp w ≤ treeHyp (List.replicate w.length 1)` for
  all `w` (global B-spine dominance), provable by snoc induction + monotonicity of
  `step` in each coordinate.
* Falsifiable: exhibit a word `w` with `treeHyp w > treeHyp (replicate |w| 1)`.

## Conjecture 2 (The hypotenuse form is a *strict* tropical co-cycle: injectivity)

**Conjecture.** `treeTriple` is injective on `List (Fin 3)` — distinct words give
distinct triples — and hence the Berggren monoid is free on `{A,B,C}` modulo the
single det-grading relation. A tropical corollary: `treeHyp` together with the
"shape" (signs of `a−b`) separates vertices.

* Testable Lean milestone: `treeTriple v = treeTriple w → v = w`, attackable via
  the inverse matrices `invA/invB/invC` of Core (unique-parent / unique-path).
* This upgrades `treeHyp_strict_mono_step` (no fixed points) to global rigidity.

## Conjecture 3 (Ultrametric realization of the tropical depth)

The depth eigenform should reconstruct an honest ultrametric on the boundary of
the tree, linking to `Bridges/CategoricalTropicalUltrametric.lean` and
`Computation/PadicValuationDepth.lean`.

**Conjecture.** For words `v, w`, `d(v,w) := |v| + |w| − 2·(longest common prefix
length)` is an integer ultrametric (strong triangle inequality
`d(u,w) ≤ max(d(u,v), d(v,w))`), and the map `w ↦ treeHyp w` is `1`-Lipschitz from
`(vertices, d)` into the tropical line, with valuation depth `Θ(log treeHyp)`.

* Testable Lean milestone: prove the strong triangle inequality for `d`, then
  `|treeHyp v − treeHyp w| ≤ 7 ^ (max |v| |w|) · d(v,w)`-type bound.

## Conjecture 4 (Tropical eigenvalue rigidity / classification of forms)

We proved the affine family `m·|w|+c` is simultaneously max- and min-harmonic.

**Conjecture.** These are the *only* simultaneous (max ∧ min) tropical eigenforms:
if `f` satisfies both `heckeMax f = f + λ` and `heckeMin f = f + λ` for a constant
`λ`, then `f w` depends only on `|w|` and is affine, i.e. `f = affine λ (f [])`.

* Testable Lean milestone: from the two equations deduce `f (w++[i]) = f (w++[j])`
  for all children, hence `f` factors through `length`; then solve the recurrence.
* Falsifiable: a non-affine `f` that is both max- and min-harmonic.

## Conjecture 5 (Det-grading is a ℤ/2 tropical character)

Core records the determinant signature `(+1,−1,+1)` and the B-parity grading.

**Conjecture.** The parity form `p(w) := (number of B's in w) mod 2`, valued in the
*Boolean* tropical semiring `({0,1}, max, +mod2)`, is a tropical character: it is an
eigenform of weight `0` for `heckeMax`/`heckeMin` restricted to each parity coset,
and `det (wordMatrix w) = (−1) ^ p(w)`. This grades the entire automorphic-form
module into a `±1` orientation bundle over the tree.

* Testable Lean milestone: `det (BerggrenLorentz.wordMatrix w) = (-1) ^ (B-count w)`
  by `List.foldl` induction using `det_matA = 1`, `det_matB = -1`, `det_matC = 1`.
