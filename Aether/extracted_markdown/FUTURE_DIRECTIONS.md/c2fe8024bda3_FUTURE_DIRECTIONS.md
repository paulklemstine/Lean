# Future Directions: Arithmetic Mirror Symmetry

The file `MirrorSymmetry/ArithmeticMirror.lean` formalizes a rigorous,
self-contained skeleton of mirror symmetry: the Hodge-diamond mirror reflection
`p ↦ n - p`, the resulting Euler-characteristic relation `χ(Y) = (-1)^n χ(X)`
(specializing to `χ(Y) = -χ(X)` for threefolds), the combinatorial form of
*"rational curves on `X` ↔ rank of `Pic(Y)`"* via the `h^{1,1} ↔ h^{2,1}` swap,
and — on the arithmetic side — the Weil functional equation for the zeta function
of projective space, proved as a polynomial identity over an arbitrary
commutative ring. The following directions extend this nucleus toward genuine
arithmetic mirror symmetry.

## 1. Hodge symmetry and the full mirror diamond

The current `mirror` only reflects the first index `p ↦ n - p`. A Calabi–Yau
diamond also enjoys complex conjugation `h^{p,q} = h^{q,p}` and Serre duality
`h^{p,q} = h^{n-p,n-q}`. **Conjecture:** under the joint hypotheses of Hodge
symmetry and Serre duality, the mirror map composed with conjugation is an
involution that fixes the Euler characteristic up to the global sign `(-1)^n`,
and the diagonal Hodge numbers `h^{p,p}` of `Y` are a permutation of the
anti-diagonal `h^{p,n-p}` of `X`.

The key insight is that mirror symmetry is the *second* reflection symmetry of an
already doubly-symmetric diamond, so all three reflections (conjugation, Serre,
mirror) generate a finite reflection group acting on the diamond, and the Euler
characteristic is the unique (up to scale) alternating invariant of that group.

Why now? The Euler-characteristic machinery (`eulerChar_mirror`) is already in
place and only manipulates alternating sums under index reflection; adding the
two extra reflections is the same `Finset.sum_range_reflect` argument applied in
the second variable, so the proof obligations are immediate variations of what is
proved.

## 2. Stringy Hodge numbers and the topological mirror test

Batyrev–Dais stringy Hodge numbers `h^{p,q}_{st}` extend ordinary Hodge numbers
to singular and orbifold Calabi–Yau, and the *topological mirror symmetry test*
asserts `h^{p,q}_{st}(X) = h^{n-p,q}_{st}(Y)`. **Conjecture:** for a Hodge
diamond enriched with a `ℚ`-valued correction supported on a finite set of
"singular strata", the stringy Euler characteristic still satisfies
`χ_{st}(Y) = (-1)^n χ_{st}(X)`, and the correction terms cancel pairwise under
the mirror reflection.

The key insight is that the stringy invariant is again an alternating sum over a
reflection-symmetric index set, merely valued in `ℚ` rather than `ℤ`, so the sign
bookkeeping of `eulerChar_mirror` transfers verbatim once the summand type is
generalized from `ℤ` to a `CommRing`.

Why now? `eulerChar` is defined over `ℤ` but its proof uses only ring identities
and `sum_range_reflect`; generalizing the codomain to an arbitrary commutative
ring is a low-risk refactor that immediately unlocks the rational-valued stringy
setting.

## 3. Functional equation for products of projective spaces and hypersurfaces

`projectiveSpace_zeta_functional_equation` proves the Weil functional equation
for `ℙⁿ`. **Conjecture:** the zeta function of a product `ℙ^{n_1} × ⋯ × ℙ^{n_k}`
satisfies the functional equation with reflection exponent
`N = Σ n_i` and sign `(-1)^{Σ(n_i+1)}`, obtained as the product of the individual
functional equations; and for a degree-`d` Calabi–Yau hypersurface in `ℙ^{n+1}`
(`d = n + 2`) the *primitive* part of the zeta numerator is palindromic of even
weight `n`.

The key insight is that the functional equation is multiplicative for the zeta
function of a product (the reciprocal-root multiset is the Minkowski sum of the
factors' multisets), so the global identity factors through the single-factor
identity already proved.

Why now? The proved identity is stated over an arbitrary `CommRing` and is a pure
`Finset.prod` manipulation, so the product case is a `Finset.prod_mul_distrib`
away, and the palindromy of the primitive part reduces to the same
`prod_range_reflect` sign computation used in the base case.

## 4. Mirror congruences for point counts (Wan's theorem, toy form)

Wan's theorem on mirror symmetry for zeta functions predicts congruences between
the number of `𝔽_q`-points of a Calabi–Yau and its mirror. **Conjecture:** for
the combinatorial point-count model `N_m = Σ_{i=0}^n q^{im}` attached to `ℙⁿ` and
the mirror-reflected weights, the difference of point counts of a mirror pair is
divisible by `q - 1` for all `m`, and the quotient is itself a palindromic
polynomial in `q^m`.

The key insight is that `q - 1` divisibility is exactly the geometric-series
identity `(q^m - 1) · Σ_{i<n+1} (q^m)^i = (q^m)^{n+1} - 1`, so congruences between
mirror point counts reduce to congruences between *Hodge numbers* via the
already-proven Euler-characteristic exchange.

Why now? The geometric-series identity is one `Finset.geom_series` lemma away in
Mathlib, and `eulerChar_mirror` already provides the bridge from point-count
differences to Hodge-number differences; the only new ingredient is the explicit
divisibility, which `omega`/`Finset` arithmetic can discharge.

## 5. Modularity of the weight as a categorical shadow

The deepest prediction is that the zeta function of a rigid Calabi–Yau threefold
is modular of weight `4`. A fully rigorous formalization is far off, but a
*falsifiable shadow* is reachable: **Conjecture:** the reflection exponent
`N = n` and weight `w = n` extracted from `projectiveSpace_zeta_functional_equation`
satisfy `w = N`, and for a rigid CY threefold model (`h^{2,1} = 0`, so
`h^{1,1}` determined by `χ`) the functional-equation sign forced by
`eulerChar_mirror_threefold` is exactly the sign `+1` compatible with a weight-`4`
modular form's functional equation.

The key insight is that the *sign* of the Weil functional equation and the
*parity* of the Euler characteristic are the same `(-1)^{n}` datum, so the
"modularity-compatible sign" is not an extra hypothesis but a theorem of the
combinatorial model already built.

Why now? Both the sign of the functional equation
(`projectiveSpace_zeta_functional_equation`) and the threefold Euler sign
(`eulerChar_mirror_threefold`) are now formal theorems; equating them is a finite
sign check, giving the first machine-checked compatibility statement between the
arithmetic and Hodge-theoretic sides of mirror symmetry.
