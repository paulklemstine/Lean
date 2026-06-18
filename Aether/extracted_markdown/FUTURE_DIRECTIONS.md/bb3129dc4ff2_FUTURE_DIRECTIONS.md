# Future Directions: From Shannon Entropy to Lattice-Theoretic Integration

## Synthesis

This cycle delivered a clean, first-principles formalization of **Shannon entropy on
finite probability distributions** in `Algebra/ShannonEntropy.lean`, built entirely on
Mathlib's `Real.negMulLog` (the function `x ↦ -x·log x`). Four cornerstone theorems are
proved with `sorry = 0`:

- `entropy_nonneg` — non-negativity of entropy on sub-distributions;
- `entropy_prod` — **additivity** `H(p⊗q) = H(p) + H(q)` over independent distributions,
  flowing algebraically from `Real.negMulLog_mul`;
- `entropy_uniform` — the uniform distribution has entropy `log n`;
- `entropy_le_log_card` — the **maximum entropy theorem** `H(p) ≤ log n`, obtained by
  feeding `Real.concaveOn_negMulLog` into concave Jensen (`ConcaveOn.le_map_sum`) with
  uniform weights `1/n`.

The pairing of `entropy_uniform` and `entropy_le_log_card` makes precise the slogan
"uniform = maximal uncertainty": the uniform distribution attains the global maximum
`log n`. The structural lesson is that the `0·log 0 = 0` convention — historically the
single most error-prone point of entropy formalizations — disappears entirely once every
term is routed through `negMulLog`, whose value at `0` is definitionally `0`.

These results are the computational substrate the broader research program needs: mutual
information, conditional entropy, KL divergence, and IIT's Φ measure are all assembled from
`entropy` plus product/marginal bookkeeping. The directions below are ordered so that each
builds directly on the lemmas now available.

## Results Summary

| Theorem | Statement | Engine |
|---|---|---|
| `entropy_nonneg` | `0 ≤ H(p)` for `p : α → [0,1]` | `Finset.sum_nonneg` + `negMulLog_nonneg` |
| `entropy_prod` | `H(p⊗q) = H(p) + H(q)` | `negMulLog_mul` + double-sum factoring |
| `entropy_uniform` | `H(uniform) = log n` | `negMulLog` + `log_inv` |
| `entropy_le_log_card` | `H(p) ≤ log n` | concave Jensen on `negMulLog` |

## Research Directions

### 1. Conditional entropy and the chain rule `H(X,Y) = H(X) + H(Y|X)`

Define the joint entropy of an arbitrary distribution `r : α × β → ℝ` (not necessarily a
product), the marginal `p(x) = ∑_y r(x,y)`, and the conditional entropy
`H(Y|X) = ∑_x p(x) · H(r(x,·)/p(x))`. Prove the **chain rule** `H(X,Y) = H(X) + H(Y|X)`,
recovering `entropy_prod` as the special case where `r` factors.

**The key insight is** that the chain rule is `negMulLog_mul` applied pointwise *before*
marginalization: writing `r(x,y) = p(x)·(r(x,y)/p(x))` turns each joint term into a
marginal term plus a conditional term, exactly mirroring the algebra already used in
`entropy_prod`. **Why now?** `entropy_prod` is literally the degenerate, fully-factored
instance of this identity, so the proof skeleton is in hand; the only new ingredient is
careful handling of the support where `p(x) = 0`, again neutralized by `negMulLog_zero`.

### 2. Gibbs' inequality and non-negativity of KL divergence

Define `KL(p‖q) = ∑_x p(x)·log(p(x)/q(x))` and prove `0 ≤ KL(p‖q)` for probability
distributions with `q` everywhere positive, with equality iff `p = q`. Then derive
`entropy_le_log_card` a second time as the special case `q = uniform`.

**The key insight is** that Gibbs' inequality is convex Jensen applied to `x ↦ x log x`
(equivalently concave Jensen to `negMulLog`), the *same* concavity engine that powers
`entropy_le_log_card`; the maximum-entropy theorem is just `KL(p‖uniform) ≥ 0` rearranged.
**Why now?** Having proved the uniform-weight Jensen instance, the general
positive-weight instance is a direct generalization, and unifies two of this cycle's
theorems under one inequality.

### 3. Subadditivity and mutual information `I(X;Y) = H(X) + H(Y) − H(X,Y) ≥ 0`

Define mutual information and prove it is non-negative, with `I(X;Y) = 0` iff `X` and `Y`
are independent (i.e. `r` factors as a product). This is the quantitative refinement of the
Boolean `integrationDeficiency` from the program's earlier cycle.

**The key insight is** that `I(X;Y) = KL(r ‖ p⊗q)`, so non-negativity is an *immediate*
corollary of Direction 2, and the independence characterization is exactly the equality
case of Gibbs combined with `entropy_prod`. **Why now?** `entropy_prod` already pins down
the `H(X)+H(Y)` side and the product distribution `p⊗q`; mutual information needs only the
divergence-from-product reading, turning the Boolean integration measure into a real-valued
one.

### 4. The minimum information partition exists (IIT's Φ, lattice version)

For a finite system on `Fin n`, define Φ as the minimum of mutual information across all
bipartitions, and prove the minimizing ("minimum information") partition exists and that
Φ = 0 iff the system decomposes into independent parts.

**The key insight is** that the set of bipartitions of a finite set is itself finite, so
existence of the minimizer is `Finset.exists_min_image` applied to the real-valued map
`cut ↦ I(cut)`, and the `Φ = 0` characterization is precisely Direction 3's
independence-iff-zero result quantified over cuts. **Why now?** Direction 3 supplies the
per-cut mutual information and its zero-set characterization; the lattice layer is pure
finite-`Finset` minimization, fully within current Mathlib.

### 5. Continuity and concavity of the entropy functional

Prove that `entropy : (α → ℝ) → ℝ` is continuous on the probability simplex and that it is
a *concave* functional of `p` (so the maximizer found in `entropy_le_log_card` is the
unique global maximum). This upgrades the maximum-entropy *bound* to a maximum-entropy
*principle*.

**The key insight is** that `entropy` is a finite sum of the continuous, concave maps
`p ↦ negMulLog (p x)`, so continuity is `continuous_negMulLog` summed and concavity is a
finite sum of concave functions (`ConcaveOn.sum`); strict concavity of `negMulLog`
upgrades uniqueness for free. **Why now?** `Real.concaveOn_negMulLog` and
`Real.continuous_negMulLog` are already the load-bearing lemmas of this cycle, so the
functional-level statements are one `Finset.sum` away.
