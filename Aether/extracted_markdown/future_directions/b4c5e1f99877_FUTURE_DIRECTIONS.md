# Future Directions — The Mertens Function Skeleton of the Riemann Hypothesis

## Synthesis

This cycle established, with fully `sorry`-free Lean 4 proofs, the *elementary
combinatorial skeleton* underneath the Mertens-function reformulation of the
Riemann Hypothesis. The analytic statement "all non-trivial zeros of `ζ` lie on
`Re(s) = 1/2`" is equivalent to the bound `M(x) = O(x^{1/2+ε})` on the Mertens
function `M(x) = ∑_{k≤x} μ(k)`. We did not attempt the analytic equivalence (it
requires complex analysis well beyond a clean elementary core). Instead, we
isolated and proved the *arithmetic engine* that makes `M` what it is:

- `moebius_sum_divisors`: the Dirichlet convolution `μ * 1 = δ`, i.e.
  `∑_{d∣n} μ(d) = [n=1]`.
- `mertens_hyperbola`: the finite hyperbola identity `∑_{n≤N} M(⌊N/n⌋) = 1`.
- `mertens_recurrence`: the self-similar recurrence
  `M(N) = 1 − ∑_{2≤n≤N} M(⌊N/n⌋)`.
- `mertens_succ`, `mertens_one`, `mertens_zero`: the telescoping base layer.

## Results Summary

All theorems live in `Catalog/Applications/RiemannMertens.lean`, depend only on
`propext`, `Classical.choice`, `Quot.sound`, and are anchored on Mathlib's
`ArithmeticFunction.moebius` and `moebius_mul_coe_zeta`. The centerpiece
(`mertens_hyperbola`) is proved by counting lattice points `(n,k)` on the
hyperbola `nk ≤ N`, grouping them by their product `m = nk`, and collapsing the
inner sum via `μ * 1 = δ`. The recurrence is the hyperbola identity solved for
its top term `M(N) = M(⌊N/1⌋)`.

## Research Directions

### 1. A computable Mertens oracle with a verified recurrence
The key insight is that `mertens_recurrence` expresses `M(N)` purely through its
values at the *strictly smaller* floors `⌊N/n⌋`, and the set of distinct floor
values `{⌊N/n⌋ : 1 ≤ n ≤ N}` has size `O(√N)`. This means `M(N)` is computable
in sub-linear arithmetic operations by memoizing over the `O(√N)` distinct
floors — the classic "Mertens via Dirichlet hyperbola" algorithm. **Falsifiable
conjecture:** one can define a Lean function `mertensFast : ℕ → ℤ` that recurses
only over distinct floor values and prove `mertensFast N = mertens N` for all
`N`, using `mertens_recurrence` plus a verified deduplication of `⌊N/n⌋`. Why
now? The recurrence is already proven `sorry`-free, so the only remaining work is
the floor-deduplication bijection, which is pure `Nat` combinatorics with no
analysis.

### 2. The general Dirichlet-hyperbola summation lemma
The key insight is that nothing in `mertens_hyperbola` used `μ` specifically: the
same lattice-point reindexing proves `∑_{n≤N} F(⌊N/n⌋) = ∑_{m≤N} (f * 1)(m)` for
*any* arithmetic function `f` with partial-sum function `F(x) = ∑_{k≤x} f(k)`.
**Falsifiable conjecture:** a single general lemma `hyperbola_partial_sum`
(parametrised over `f : ℕ → ℤ`) subsumes `mertens_hyperbola` as the case
`f = μ`, and instantiating it at `f = 1` yields the divisor-summatory identity
`∑_{n≤N} ⌊N/n⌋ = ∑_{m≤N} d(m)` (Dirichlet's divisor problem in exact form). Why
now? Our proof is already written generically in spirit — abstracting the
`moebius`-specific steps is mechanical and immediately produces a reusable
catalog primitive bridging number theory and combinatorics.

### 3. Liouville-function analogue and the squarefree connection
The key insight is that the convolution identity `λ * 1 = [·is a square]` (for the
Liouville function `λ`) has the same shape as `μ * 1 = δ`, so the identical
hyperbola argument gives `∑_{n≤N} L(⌊N/n⌋) = ⌊√N⌋`, where `L(x) = ∑_{k≤x} λ(k)`
is the summatory Liouville function whose sign behaviour is itself RH-adjacent
(the disproved Pólya conjecture). **Falsifiable conjecture:** `∑_{n≤N}
L(⌊N/n⌋) = #{ squares ≤ N } = ⌊√N⌋` is provable by reusing the lattice-point
bijection verbatim with `λ` in place of `μ`. Why now? Mathlib has
`ArithmeticFunction` infrastructure for `λ` and the squareness indicator, and our
reindexing proof transfers with only the final collapse lemma changed.

### 4. Möbius partial sums and the `∑ μ(n)/n` reformulation
The key insight is that the elementary identity `∑_{n≤N} M(⌊N/n⌋) = 1` can be
weighted: combining it with Abel summation against `1/n` connects `M(N)` to the
truncated series `∑_{n≤N} μ(n)/n`, whose convergence to `0` is equivalent to the
Prime Number Theorem. **Falsifiable conjecture:** a `sorry`-free Lean lemma can
exhibit `∑_{n≤N} μ(n)/n = ∑_{n≤N} M(⌊N/n⌋)/(n(n+1)) + (boundary)` purely
algebraically (no limits), giving a finite identity that is the exact PNT
precursor. Why now? Both ingredients (`mertens_hyperbola` and Mathlib's
`Finset.sum_range_succ`-style Abel summation) are available; the step is finite
algebra, deferring all analysis to a later cycle.

### 5. Redheffer matrix determinant identity
The key insight is that `M(N) = det(R_N)` where `R_N` is the `N×N` Redheffer
matrix `(R_N)_{ij} = 1` if `j = 1` or `i ∣ j`, else `0` — a striking bridge
between the Mertens function (number theory) and linear algebra. **Falsifiable
conjecture:** `det (Redheffer N) = mertens N` is provable in Lean by cofactor
expansion driven by the *same* `μ * 1 = δ` convolution already proven here, with
the divisor lattice structure of `R_N` mirroring the hyperbola bijection. Why
now? `moebius_sum_divisors` is exactly the algebraic fact the determinant
expansion needs, and Mathlib's `Matrix.det` API makes the cofactor recursion
tractable; this would be a genuinely cross-domain catalog theorem (linear
algebra × analytic number theory).
