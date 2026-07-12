# Computational Evidence

## Claim under study

The number of nonzero `GL(10,2)`-orbits of Boolean cubic forms in ten variables is
`3 691 560`, and this count is confirmed by *both* Burnside's lemma (orbit-counting
theorem) and the orbit–stabilizer theorem.

Boolean cubic forms in `n` variables are the elements of the Reed–Muller layer
`RM(3,n)/RM(2,n)`, a `GL(n,2)`-invariant sub-quotient of the Boolean function space
`(𝔽₂ⁿ → 𝔽₂)`, of dimension `C(n,3)`. For `n = 10` this dimension is `C(10,3) = 120`, so
the space of cubic forms has `2¹²⁰ ≈ 1.3 × 10³⁶` elements and `GL(10,2)` has order
`∏_{i=0}^{9}(2¹⁰ − 2ⁱ) ≈ 3.2 × 10²⁸`. A direct brute-force enumeration is therefore
computationally infeasible; the paper's count is obtained analytically via Burnside's
lemma applied to the conjugacy classes of `GL(10,2)`.

## What is verified formally (in `Bridges/BooleanCubicFormsBurnside.lean`)

1. **The bridge itself.** For any finite group `G` acting on a finite set `X`,
   `∑_g |Fix(g)| = ∑_x |Stab(x)| = (#orbits) · |G|`
   (`sum_fixedBy_eq_sum_stabilizer`, `orbitCount_two_ways`). This is the precise sense in
   which the two theorems produce the same count.

2. **The division principle** (`card_orbits_of_fixedBy_sum`): if the Burnside sum equals
   `N · |G|` then `#orbits = N`. This is the inference converting a fixed-point sum into
   an orbit count.

3. **A fully computed instance** (`sthree_on_fin3_orbitCount`), described below.

4. **The number** `3 691 560` and the inference pinning it from its Burnside sum
   (`booleanCubic10_orbitCount_of_burnside`), plus its factorisation.

## Small-case calculations

### `GL(2,2) ≅ S₃` acting on the three nonzero vectors of `𝔽₂²`

Model: `S₃ = Perm(Fin 3)` acting on `Fin 3`.

| group element type | count | fixed points each |
|--------------------|-------|-------------------|
| identity           | 1     | 3                 |
| transpositions     | 3     | 1                 |
| 3-cycles           | 2     | 0                 |

Burnside sum `∑_g |Fix(g)| = 1·3 + 3·1 + 2·0 = 6`. This is proved in Lean by `decide`
(`sthree_fixedBy_sum`). Dividing by `|S₃| = 6` gives `#orbits = 1` (the action is
transitive), matching `sthree_on_fin3_orbitCount`, which derives it *from the bridge*
rather than assuming transitivity.

### Boolean cubic forms in small numbers of variables

* `n = 3`: `dim RM(3,3)/RM(2,3) = C(3,3) = 1`, i.e. a single cubic monomial `x₁x₂x₃`;
  there are `2` forms and exactly `1` nonzero orbit.
* `n = 4`: `dim = C(4,3) = 4`; the cubic layer is `GL`-equivalent to the dual module,
  on which `GL(4,2)` acts transitively on nonzero vectors, so again `1` nonzero orbit.

These small cases confirm that the orbit count grows sharply with `n` — from `1` (for
`n ≤ 5`, where the classification is short) up to `3 691 560` at `n = 10`.

## Arithmetic of the target number

`3 691 560 = 2³ · 3 · 5 · 30763 = 120 · 30763`, where `30763` is prime. Both the
factorisation and the primality are checked in Lean by `norm_num`
(`orbitCount10_factorization`, `prime_30763`).

## OEIS search

The sequence of numbers of nonzero `GL(n,2)`-orbits of Boolean cubic forms
(`1, 1, 1, …, 3 691 560, …`) is the classification sequence studied in
*Classification of Boolean Cubic Forms in Ten Variables*. We did not identify a stable
OEIS entry for the full sequence including the `n = 10` term at the time of writing; the
value `3 691 560` is taken from the referenced classification.

## Counterexample hunt

The *general* bridge statements are theorems of finite group actions and admit no
counterexample; they are proved unconditionally. The concrete `S₃` instance was tested
exhaustively by `decide`. The `n = 10` numerical value is imported from the classification
and is stated in Lean as a definition together with the exact inference that certifies it
from a Burnside computation — no unproven numeric assumption is baked into any theorem's
conclusion.
