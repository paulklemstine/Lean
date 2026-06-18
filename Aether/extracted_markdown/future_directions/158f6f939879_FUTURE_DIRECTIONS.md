# Future Directions: Conserved Quantities along Reduction Paths

## Synthesis

This cycle fused two strands of the catalog that had been developed
independently: the **conserved-quantity view of cryptographic reductions**
(`Catalog/Cryptography/AdvantageMetric.lean`, where *advantage* behaves like a
pseudo-metric coordinate and the hybrid argument is sub-additivity) and the
**Fibonacci / Carmichael primitive-divisor** work
(`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/FibApparitionExistence.lean`).

The unifying observation is that *both* theories are about a **length/valuation
functional on a discrete path** and the morphisms that conserve it. A sequence
of cryptographic games is a discrete path in a pseudometric space; the advantage
is its length; a reduction is a Lipschitz morphism of path spaces; and the
"advantage-loss factor" is nothing but a Lipschitz constant. Dually, in number
theory the Fibonacci map is a *gcd-conserving morphism of the divisor lattice*
(`gcd (fib m) (fib n) = fib (gcd m n)`), and this conserved quantity is the
homotopy-invariant heart of the primitive-divisor (Carmichael) argument.

New file: `Catalog/Cryptography/ConservedPathReductions.lean`.

## Results Summary

All six theorems are proved with `sorry = 0` and depend only on the standard
axioms (`propext`, `Classical.choice`, `Quot.sound`).

- `gameDist_path_le` — endpoint distance ≤ path length: the metric-space
  generalization of `AdvantageMetric.hybrid_argument`, now valid in *any*
  pseudometric space rather than over a real coordinate.
- `pathLength_concat` — the path-length functional is additive under
  concatenation at any intermediate game `k ≤ n`: the structural form of the
  triangle conservation law `AdvantageMetric.advantage_triangle`.
- `lipschitz_reduction_contracts_path` — a `K`-Lipschitz reduction multiplies
  the path length by at most `K`. This single inequality subsumes both the
  multiplicative law `AdvantageMetric.reduction_composition` and the additive
  hybrid bound.
- `reduction_end_to_end_bound` — chaining the previous two into the headline
  quantitative reduction estimate `dist (φ(f 0)) (φ(f n)) ≤ K · pathLength f n`.
- `fib_gcd_conservation` — the gcd-conserved quantity on Fibonacci, read as a
  conservation law (catalog synthesis with the Carmichael work).
- `fib_primitivity_bridge` — a clean, self-contained restatement and proof of
  the conserved-quantity heart of `CarmichaelProof.bridge_lemma`: local
  non-divisibility on *proper divisors* collapses to global non-divisibility on
  *all smaller indices*, purely via gcd conservation.

## Research Directions

### 1. Metric path spaces with a genuine fundamental-groupoid structure for games

Replace the index set `ℕ` by an arbitrary directed graph of games and define the
length functional over walks, then quotient by the relation "same endpoints,
equal length" to obtain a fundamental-groupoid-like object whose morphisms are
exactly the admissible hybrid rewrites. **The key insight is** that the hybrid
argument is path-length sub-additivity, so the *only* homotopy-invariant of a
game walk that survives is its endpoint distance — every legitimate hybrid proof
is a homotopy of walks with non-increasing length. **Why now?** With
`pathLength_concat` and `gameDist_path_le` already proved, the concatenation and
endpoint-bound axioms of a length-graded groupoid are in hand; only the quotient
construction remains, and it is falsifiable by exhibiting two equal-endpoint
walks whose minimal lengths differ in a way the groupoid laws forbid.

### 2. Sharpness of the Lipschitz reduction bound

Conjecture: `lipschitz_reduction_contracts_path` is tight — for every `K` and
`n` there is a pseudometric pair and a `K`-Lipschitz `φ` and a path `f` with
`pathLength (φ ∘ f) n = K · pathLength f n`. **The key insight is** that
equality forces `φ` to be a *dilation* on every consecutive pair `(f i, f(i+1))`,
so tightness is equivalent to the existence of a geodesic path on which `φ`
achieves its Lipschitz constant at every step. **Why now?** The inequality is
formalized; the matching lower bound is a finite construction (take `α = β = ℝ`,
`φ x = K x`, `f i = i`) that can be checked mechanically, turning a qualitative
"the constant is best possible" remark into a theorem.

### 3. A multiplicative Lipschitz constant for the Fibonacci valuation

The `p`-adic valuation of `fib n` along the divisor lattice should obey a
Lipschitz-type law analogous to `lipschitz_reduction_contracts_path`, with the
gcd playing the role of the metric meet. Conjecture: `v_p(fib n)` is a monotone,
sub-additive functional on the divisor lattice whose "steps" are controlled by
the rank of apparition. **The key insight is** that `fib_gcd_conservation` makes
the Fibonacci map a lattice morphism, so divisibility distances contract exactly
as metric distances do under a Lipschitz reduction. **Why now?**
`fib_primitivity_bridge` already exposes the conserved quantity; quantifying *how
much* valuation is gained per divisor step would upgrade the primitive-divisor
existence statement to a primitive-divisor *counting* statement.

### 4. Closing the Carmichael infinite tail via the conserved quantity

`Catalog/Shared/CarmichaelProof.lean` discharges every composite `n ≤ 10000` by
`native_decide` but leaves the tail `n > 10000` as a `sorry`. Conjecture: the
tail is provable by combining `fib_primitivity_bridge` (this file) with a
Zsygmondy/Carmichael lower bound `fib n > ∏_{d | n, d < n} (fib d)^{...}`, so the
primitive part `primPart n` is forced to exceed `1` for all large `n`. **The key
insight is** that the bridge lemma already reduces primitivity to a *single*
inequality about the size of the primitive part, eliminating the per-`n` search.
**Why now?** The bridge is formalized axiom-clean and independent of the finite
verification, so the tail reduces to an analytic growth estimate on Fibonacci
products rather than an infinite case analysis.

### 5. An ∞-categorical localization inverting "negligible" reductions

Define the class of reductions with Lipschitz constant `K = 1` (advantage
preserving) and localize the category of game path spaces at the morphisms whose
constant is "negligible" in the security parameter. Conjecture: the localization
identifies exactly the games that are computationally indistinguishable, so
"indistinguishability" *is* isomorphism in the localized ∞-category. **The key
insight is** that `reduction_end_to_end_bound` makes the advantage a functorial
length that the localization must send to zero, so negligibility becomes a
formal weak-equivalence condition. **Why now?** With the Lipschitz-morphism
layer proved, the weak equivalences form a well-defined class (closed under
composition by `reduction_composition`), which is the precondition for a calculus
of fractions and hence a falsifiable model-categorical presentation.
