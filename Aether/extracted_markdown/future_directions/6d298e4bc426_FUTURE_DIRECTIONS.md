# Future Directions — The Berggren-Word Ultrametric on Primitive Pythagorean Triples

## Synthesis

The Berggren ternary tree assigns to every primitive Pythagorean triple (PPT) a unique
finite *address* — a descent word over the three generators `{A, B, C}` from the root
`(3,4,5)`. The catalog already contains the algebraic backbone of this picture: the
Lorentz-group structure of the generators (`Catalog/Algebra/BerggrenLorentz/Core.lean`:
`matA_preserves_lorentz`, `det_matB`), the tree infrastructure
(`Catalog/Pythagorean/BerggrenTree.lean`: `addrTriple`, `commonPrefixLen`, `treeDist`,
`aRay_injective`), and the completeness/uniqueness of addresses
(`Catalog/Pythagorean/BerggrenCompleteness.lean`: `IsPrimitivePythagorean`, the unique
descent path). What was missing was the **metric geometry of the address space**.

This cycle supplies it. In `Catalog/Pythagorean/BerggrenUltrametric.lean` we prove that
the *longest-common-prefix* of two addresses is a genuine **non-archimedean valuation**:
the inequality `min (cpl u v) (cpl v w) ≤ cpl u w` (`commonPrefixLen_ultrametric`) is the
exact discrete shadow of the `p`-adic estimate `v_p(x−z) ≥ min(v_p(x−y), v_p(y−z))`. From
it the distance `pvDist u v = (1/2)^(cpl u v)` is shown to satisfy the **strong triangle
inequality** (`pvDist_ultrametric`), together with the remaining ultrametric axioms. We
further prove the new distance is *strictly stronger* than the catalog graph metric:
`treeDist` is **not** an ultrametric (`treeDist_not_ultrametric`, explicit 3-point failure),
and we identify the ultrametric balls with rooted subtrees (`pvDist_ball_eq_subtree`):
two PPTs lie within distance `(1/2)^k` exactly when they share their depth-`k` ancestor
triple. This is the first piece of *non-archimedean analysis* attached to the catalog's
Pythagorean tree, and it bridges three previously separate catalog clusters: the
Berggren–Lorentz algebra, the Berggren tree combinatorics, and the `p`-adic valuation
work in `Catalog/Pythagorean/PadicOrbitalValuation.lean`.

## Results Summary

All results are proved with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`), building directly on `Pythagorean.BerggrenTree`:

- `commonPrefixLen_take_eq`, `take_eq_of_le_commonPrefixLen` — `cpl` is the *true* common
  prefix length (truncation to it/below it agrees on both words).
- `commonPrefixLen_ultrametric` — the non-archimedean inequality (combinatorial heart).
- `pvDist_self`, `pvDist_nonneg`, `pvDist_eq_zero_iff`, `pvDist_comm` — metric axioms.
- `pvDist_ultrametric` — the strong triangle inequality (**main theorem**).
- `pvDist_triangle` — ordinary triangle inequality (corollary).
- `treeDist_not_ultrametric` — the catalog graph distance fails the strong inequality.
- `pvDist_ball_eq_subtree` — ultrametric balls = Berggren subtrees (balls ↔ ancestors).
- `cpl_AA_AB`, `ancestor_AA_AB` — concrete sanity witnesses.

## Bold, Falsifiable Research Directions

### 1. Completeness ⇒ a true ultrametric *on triples themselves*, not just addresses
Right now `pvDist` lives on addresses (`OrbitAddr`). Combining it with
`BerggrenCompleteness`'s uniqueness of descent should descend it to a function on
`{ (a,b,c) : IsPrimitivePythagorean a b c }` via the (provably injective) `addrTriple`
restricted to canonical addresses. The conjecture: **`addrTriple` is injective on the set
of reachable addresses, so `pvDistTriple t₁ t₂ := pvDist (addr t₁) (addr t₂)` is a
well-defined ultrametric making the PPTs a discrete subset of a Cantor-like space.**
The key insight is that `BerggrenCompleteness` already proves each PPT has a *unique*
parent and hence a unique address, so the address map is a bijection onto its image and
transports the ultrametric verbatim. Why now? The ultrametric axioms are already proven on
addresses this cycle; only the injectivity transport lemma is missing, and the descent
machinery to prove it is fully present in the catalog. Falsifiable: exhibit two distinct
PPTs with the same canonical address (would refute it).

### 2. The boundary at infinity is a compact `p`-adic-like Cantor space
Extend `OrbitAddr` to infinite words `ℕ → BDir` (descent rays). The conjecture:
**the metric completion of `(PPTs, pvDist)` is the full ternary Cantor space
`ℕ → BDir`, which is compact and totally disconnected, and the `aRay` of
`BerggrenTree` embeds `ℕ` as a single convergent ray landing on one boundary point.**
The key insight is that `commonPrefixLen_ultrametric` already gives the ultrametric on
finite words and extends continuously to infinite words, so the boundary inherits a
canonical ultrametric of diameter `1`. Why now? `aRay_injective` and the prefix valuation
are in hand; the only new ingredient is the standard inverse-limit/Cauchy-sequence
completion, which Mathlib supports (`UniformSpace.Completion`, `CompactSpace`).
Falsifiable: if some boundary point were isolated, compactness/perfectness would fail.

### 3. Hausdorff dimension of the PPT boundary is exactly `log 3 / log 2`
With the `(1/2)^(cpl)` metric, each node has 3 children whose balls have half the radius
of the parent. The conjecture: **the boundary carries a natural self-similar measure of
Hausdorff dimension `log 3 / log 2`, and the counting function `#{PPT : hypotenuse ≤ N}`
grows like `N^{α}` with `α` tied to this dimension via the hypotenuse bounds
`hyp_exp_upper_bound`/`hyp_lower_bound` of `BerggrenTree`.** The key insight is that the
exponential hypotenuse bounds (`7^|w|·5` above, `5+|w|` below) convert *combinatorial*
ball-radius `(1/2)^k` into *arithmetic* hypotenuse-size, turning a metric-dimension
statement into a Diophantine counting law. Why now? Both the metric (this cycle) and the
two-sided growth bounds (catalog) are formalized, so the dimension computation is a
self-contained `Real.log` estimate. Falsifiable: a counting experiment giving a different
exponent would refute the dimension claim.

### 4. The det-grading is a continuous `ℤ/2`-character on the ultrametric space
`BerggrenLorentz` shows `det A = det C = +1`, `det B = −1`, so `wordParity` (count of
`B`'s mod 2) determines orientation. The conjecture: **`wordParity` is *locally constant*
hence continuous for `pvDist`, giving a clopen partition of every ball into an even and an
odd half, and the orientation character `(−1)^{wordParity}` is a continuous group
homomorphism from the descent monoid to `{±1}` that survives to the boundary.**
The key insight is that any two addresses within distance `< (1/2)^k` agree on their
first `k` letters (`pvDist_ball_eq_subtree`), so parity is determined by an arbitrarily small ball —
exactly local constancy. Why now? The grading exists in `BerggrenLorentz`
(`single_B_parity`, `det_matB`) and the ball-subtree identification is proved this cycle;
joining them is immediate. Falsifiable: find two addresses in the same radius-`(1/2)^k`
ball (k ≥ 1) with different first-letter parity.

### 5. A collision-resistant arithmetic hash with provable ultrametric separation
`BerggrenCompleteness` advertises a `PrimTriple → List (Fin 3)` hash. The conjecture:
**the ultrametric lower-bounds the hash's separation — distinct PPTs with hypotenuses
≤ N differ in their first `O(log N)` address letters, so `pvDist` between distinct triples
is bounded below by `(1/2)^{O(log N)} = N^{-O(1)}`, giving a *quantitative*
collision-resistance certificate.** The key insight is that `hyp_lower_bound` forces long
shared prefixes to imply large hypotenuses, so two small-hypotenuse triples cannot share a
long prefix, which is precisely a metric separation bound. Why now? The ultrametric and the
hypotenuse bounds are now both formal, making the separation estimate a direct corollary
rather than a heuristic. Falsifiable: two distinct PPTs with small hypotenuse and a long
common address prefix would break the bound.
