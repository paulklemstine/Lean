# Future Directions — Chromatic Polynomial Synthesis Cycle

## Synthesis

This cycle closed the central open `sorry` of the catalog's chromatic-polynomial
package: the **fundamental evaluation theorem**
`SimpleGraph.eval_chromaticPolynomial` in
`Catalog/Speculative/ChromaticPolynomial/Defs.lean`. The proof is a self-contained
inclusion–exclusion over edge subsets (the Whitney rank formula): for each edge
subset `A`, the value `k^{c(A)}` counts functions constant on the connected
components of the spanning subgraph `(V, A)`; swapping the order of summation and
collapsing the alternating sum over the powerset of the edge set with
`Finset.prod_add` sifts out exactly the proper colourings.

On top of that single theorem we built a coherent, `sorry`-free corollary layer
in `Catalog/Speculative/ChromaticPolynomial/Corollaries.lean`:

* `numColorings_eq_eval` — the colour count *is* the polynomial evaluation;
* `chromaticPolynomial_eval_nonneg` — evaluations at naturals are `≥ 0`;
* `exists_polynomial_numColorings` — `k ↦ numColorings k` is the restriction of a
  single integer polynomial (polynomiality of the count);
* `colorable_iff_eval_pos` — graph colourability is equivalent to `χ_G(k) > 0`,
  turning a *search* problem into an *evaluation* problem;
* `numColorings_eq_of_chromaticPolynomial_eq` — chromatically equivalent graphs
  agree on colour counts at every `k`.

All five depend only on `propext`, `Classical.choice`, and `Quot.sound`.

## Results Summary

| Theorem | File | Status |
|---|---|---|
| `eval_chromaticPolynomial` | `ChromaticPolynomial/Defs.lean` | proved (was `sorry`) |
| `numColorings_eq_eval` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `chromaticPolynomial_eval_nonneg` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `exists_polynomial_numColorings` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `colorable_iff_eval_pos` | `ChromaticPolynomial/Corollaries.lean` | proved |
| `numColorings_eq_of_chromaticPolynomial_eq` | `ChromaticPolynomial/Corollaries.lean` | proved |

Infrastructure fix: the package `srcDir` was set to `Catalog` in `lakefile.toml`
so the library globs resolve to the actual source tree.

## Research Directions

### 1. Deletion–contraction recurrence for `chromaticPolynomial`

The next structural theorem the package needs is the deletion–contraction law:
for an edge `e = s(u,v)` of `G`,
`χ_G = χ_{G \ e} - χ_{G / e}` as integer polynomials. This is the recurrence that
makes chromatic polynomials *computable* and that powers most downstream theory
(Tutte polynomial specialisations, broken-circuit theorems).
**The key insight is** that deletion–contraction is the polynomial shadow of a
bijective partition of proper colourings of `G \ e` into those that already
properly colour `G` and those that identify `u` with `v` (hence colour `G / e`);
combined with `eval_chromaticPolynomial` it reduces to a *finite identity at every
`k`*, and two integer polynomials agreeing on all of `ℕ` are equal. This is
falsifiable: it predicts an exact coefficientwise identity that a single
`decide`/`native_decide` check on a small graph (e.g. `P_3`) can refute.
**Why now?** With `eval_chromaticPolynomial` proven, the recurrence no longer needs
any combinatorial re-derivation — it becomes "prove it for all `k`, then lift to
polynomials," a route that is now fully unlocked.

### 2. Closed form on complete graphs: `χ_{K_n}(X) = X^{\underline n}` (falling factorial)

Conjecture: the chromatic polynomial of the complete graph `K_n` is the falling
factorial `∏_{i=0}^{n-1} (X - i)`, and consequently `numColorings (K_n) k =
k·(k-1)···(k-n+1)`.
**The key insight is** that a proper colouring of `K_n` is precisely an *injection*
`V ↪ Fin k`, so `colorable_iff_eval_pos` already forces `χ_{K_n}(k) = 0` for `k < n`
and `> 0` for `k ≥ n`; pinning the exact value is then a counting-of-injections
fact (`Fintype.card_embedding`) lifted through `exists_polynomial_numColorings`.
This is sharply falsifiable: any `k` for which the falling-factorial value differs
from `numColorings (K_n) k` would break it, and these are `native_decide`-checkable.
**Why now?** `colorable_iff_eval_pos` and `numColorings_eq_eval` give both the
sign data and the counting identity in one package, so only the injection count
remains.

### 3. Chromatic polynomials separate forests from graphs with cycles via the
linear coefficient

Conjecture: for a connected graph on `n` vertices with `m` edges, the chromatic
polynomial has degree `n`, leading coefficient `1`, and the coefficient of
`X^{n-1}` equals `-m`; in particular a connected graph is a tree iff its chromatic
polynomial equals `X(X-1)^{n-1}`.
**The key insight is** that the Whitney rank formula already exposes these
coefficients term-by-term — the `X^{n}` term comes only from `A = ∅`, and the
`X^{n-1}` term collects exactly the singleton edge subsets — so the claim is a
*direct read-off* of `chromaticPolynomial`'s definition rather than new theory.
Falsifiable by exhibiting any connected graph whose `X^{n-1}` coefficient is not
`-m`. **Why now?** The definition of `chromaticPolynomial` is fixed and the
evaluation theorem certifies it is the "right" object, so coefficient extraction is
the natural, low-risk next layer.

### 4. Spectral colourability bridge to the catalog's DPP package

The file `Catalog/Speculative/AutoResearch/DPPFluctuationDissipation.lean` builds a
weighted graph Laplacian (`dppLaplacian`) with conductances `K_ij²` from a
determinantal point process. Conjecture: the *number of spanning forests* counted
by that Laplacian's principal minors matches the top non-trivial coefficient data
of `chromaticPolynomial` for the underlying simple graph (a chromatic/Tutte–matrix
bridge).
**The key insight is** that both objects are governed by the same edge-subset sum
— inclusion–exclusion over `edgeFinset.powerset` for the chromatic side and the
matrix-tree expansion for the Laplacian side — so a single combinatorial
identity should unify them. Falsifiable on any small graph by comparing the
matrix-tree count against the chromatic coefficient. **Why now?** The DPP package
already proves the Dirichlet-form representation `dppLaplacian_quadForm_eq_dirichlet`,
giving a ready algebraic handle on the Laplacian side to meet the chromatic side.

### 5. Resolve the DPP contraction inequality to certify covariance ≽ resistance

The remaining `sorry` `marginal_kernel_contraction_diagonal` (DPP file) asserts
`∑_{k≠i} K_{ik}² ≤ K_{ii}(1 - K_{ii})`. Conjecture: it holds for every symmetric
PSD `L` with `β ≥ 0`, and is the *only* matrix-analytic input needed for the
already-stated `effectiveResistance_le_susceptibilityDistance`.
**The key insight is** that `K - K² = K(I-K) = βL(I+βL)^{-2}` is a *congruence*
`((I+βL)^{-1})ᵀ (βL) (I+βL)^{-1}` of `βL`, hence PSD when `β ≥ 0`, so its diagonal
entries `K_{ii} - ∑_k K_{ik}²` are nonnegative — exactly the inequality. This is
falsifiable: a symmetric PSD `L` with `β ≥ 0` violating the diagonal bound would
refute it (none should exist), and a counterexample search over `2×2` rational
kernels is cheap. **Why now?** The required PSD-congruence lemma
(`Matrix.PosSemidef.conjTranspose_mul_mul_same`) and the commuting identity
`(I+βL)L = L(I+βL)` are both already available; isolating `β ≥ 0` as a hypothesis
removes the obstruction that stalled the unconditional attempt this cycle.
