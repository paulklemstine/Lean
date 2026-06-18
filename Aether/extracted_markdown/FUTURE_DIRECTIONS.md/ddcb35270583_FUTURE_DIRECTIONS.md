# Future Directions: From the Fundamental Theorem of Tropical Algebra to Compactification

## Synthesis

This cycle closed the first concrete gap left open by the catalog's tropical
infrastructure. The convexity backbone in
`Catalog/Tropical/Core/TropicalConvexity.lean` (`tropPoly_convexOn`,
`tropPoly_monotone_of_slopes_nonneg`) established that a tropical polynomial is a
convex, piecewise-linear function, and the semiring file
`Catalog/Tropical/Core/TropicalSemiringProperties.lean` fixed the max-plus
algebra. What was missing was the *root theory*: a precise account of where the
breakpoints go and how their multiplicities add up.

`Catalog/Tropical/Core/TropicalFundamentalTheorem.lean` supplies exactly this.
We define `tropPoly`, the tropical degree `tropDegree`, and the tropical
multiplicity `tropMult`, and we prove the **Fundamental Theorem of Tropical
Algebra** in two complementary forms:

* an *analytic* form — the Newton-polygon picture: a strictly-increasing-slope
  tropical polynomial eventually coincides with its top monomial as `x → +∞`
  (`tropPoly_eventually_top`) and with its bottom monomial as `x → -∞`
  (`tropPoly_eventually_bot`); and
* a *combinatorial* form — the multiplicities telescope to the degree
  (`tropical_FTA_telescope`, `tropical_FTA_degree`), with every multiplicity
  strictly positive (`tropMult_pos`) and the degree strictly positive in degree
  `≥ 1` (`tropDegree_pos`).

The unifying observation is that the slope sequence of the convex function *is*
the Newton polygon, and "counting roots with multiplicity" is literally
summing first differences of that slope sequence — a telescoping identity.

## Results Summary

| Theorem | Statement |
|---|---|
| `tropPoly_eval_le` | every monomial is dominated by the polynomial |
| `tropPoly_eventually_top` | top slope wins for large `x` (leading term) |
| `tropPoly_eventually_bot` | bottom slope wins for small `x` (constant term) |
| `tropMult_pos` | strictly increasing slopes ⇒ positive multiplicities |
| `tropical_FTA_telescope` | Σ multiplicities `= slopes n − slopes 0` |
| `tropical_FTA_degree` | Σ multiplicities `= tropDegree` |
| `tropDegree_pos` | degree `≥ 1` ⇒ positive tropical degree |

All proofs are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. The breakpoint count bound as a corollary of the asymptotics

The catalog conjectured `breakpoint_count_le`: a tropical polynomial with `n+1`
terms and distinct slopes has at most `n` breakpoints. We can now make this
precise and provable: define a breakpoint of `tropPoly` as a point where the
realizing index (`argmax` over `Fin (n+1)`) changes, and show the realizing
index is a monotone step function of `x` that starts at `0`
(`tropPoly_eventually_bot`) and ends at `Fin.last n`
(`tropPoly_eventually_top`). **The key insight is** that a monotone integer-valued
step function from `0` to `n` can jump at most `n` times, so the breakpoint count
is bounded by the number of slope changes — turning a geometric count into a
counting argument about monotone maps. **Why now?** Both asymptotic endpoints are
now theorems, and `tropPoly_convexOn` guarantees the realizing index is monotone;
the only remaining ingredient is the elementary "monotone surjection onto
`Fin (n+1)` has `≤ n` jumps" lemma, which is within reach of the current toolkit.

### 2. Tropical Vieta: degree, root sum, and the lowest/highest coefficients

Classically, the coefficients of a polynomial are symmetric functions of its
roots. Tropically, the analogue should read off the *corner locations* of the
Newton polygon from consecutive coefficient differences. The conjecture: for a
strictly-increasing-slope tropical polynomial the `i`-th breakpoint location is
exactly `(coeffs i − coeffs (i+1)) / (slopes (i+1) − slopes i)`, and these
locations are increasing. **The key insight is** that the crossover thresholds we
already constructed inside `tropPoly_eventually_top`/`_bot` (the `sup'`/`inf'` of
the ratios `(coeffs i − coeffs j)/(slopes j − slopes i)`) are not merely bounds
but the genuine root coordinates once slopes are consecutive. **Why now?** The
crossover ratios are already in the proofs; promoting them from existence
witnesses to exact root formulas only requires the convexity-driven monotonicity
of the realizing index, which `tropPoly_convexOn` supplies.

### 3. Tropical matrix Kleene star and the Floyd–Warshall correspondence

Extend the catalog's min-plus matrix algebra by defining the Kleene star
`A* = I ⊕ A ⊕ A² ⊕ ⋯` and proving that, absent negative cycles, it stabilizes
at `A^(n-1)` and computes all-pairs shortest paths. **The key insight is** that
the same telescoping/stabilization phenomenon proved here for slope sequences
recurs for the entrywise-decreasing sequence `A^k_{ij}`: a monotone sequence in a
finite index range must stabilize, and the pigeonhole bound `n-1` is the matrix
analogue of the `n` breakpoint bound. **Why now?** The idempotent semiring laws
are catalog theorems and the finiteness/stabilization argument is structurally
identical to `tropical_FTA_telescope`; this is the natural cross-pollination of
the root theory into linear algebra.

### 4. Tropical determinant equals tropical permanent

Over the min-plus semiring the signed determinant and the unsigned permanent both
collapse to the minimum-weight perfect matching, because idempotent addition
(`min(a,a) = a`) annihilates sign cancellation. Formalize
`tropDet A = tropPerm A` as a `Finset.inf'` over `Equiv.Perm (Fin n)`.
**The key insight is** that the permutation sign is a unit that acts trivially
under tropicalization, so the two optimization problems are *definitionally* the
same `inf'` once signs are discarded. **Why now?** Mathlib's `Equiv.Perm` and
`Finset.univ` over permutations are mature, and the proof reduces to the
sign-irrelevance lemma plus the `inf'` manipulation idioms already exercised in
`tropPoly_eventually_bot`.

### 5. Legendre–Fenchel involutivity and the Newton-polygon bijection

The asymptotic theorems say the `+∞` and `−∞` slopes of `tropPoly` are exactly
the extreme slopes of the coefficient data — the first instance of a full
Legendre–Fenchel duality. The conjecture: the tropical polynomial is the convex
conjugate of the discrete measure on its `(slope, coeff)` points, and the
transform is an involution, yielding a bijection between tropical polynomials and
their Newton polygons. **The key insight is** that `tropPoly` is already written
as a finite `sup'` of affine functions — the defining form of a support function —
so conjugating twice must return the convex hull of the data points, i.e. the
Newton polygon. **Why now?** `tropPoly_convexOn` certifies convexity, Mathlib has
`ConvexOn` and conjugate machinery, and the extreme-slope endpoints proved here
are the boundary data the involution must reproduce.
