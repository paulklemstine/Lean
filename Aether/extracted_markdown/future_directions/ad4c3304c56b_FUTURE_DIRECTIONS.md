# Future Directions: Tropical Orbit-Prefix Fiber Theory

This document outlines concrete next steps for extending the fiber bounds for orbit-prefix maps of tropical matrix actions, as formalized in `Catalog/Tropical/OrbitPrefixFiber.lean`.

---

## 1. k-Step Simplex Fiber Formula

### Theorem Statement

For `k ≥ 1`, define the `k`-step domain as the `k`-fold product of `splitDomain e`, and the `k`-step prefix sum as the sum of all first components. Then:

```
((kStepDomain k e).filter (fun x => kPrefixSum x = s)).card =
  ∑ j in Finset.range (⌊s/e⌋ + 1), (-1)^j * C(k, j) * C(s - j*e + k - 1, k - 1)
```

when `0 ≤ s ≤ k*e`, and `0` otherwise. This is the inclusion-exclusion formula for the number of solutions to `a₁ + ... + aₖ = s` with `0 ≤ aᵢ ≤ e`.

### Why It Matters

This generalizes the triangular law (`k = 2`) to arbitrary composition depth. It connects tropical orbit-prefix theory to Ehrhart polynomial theory and discrete simplex counting. For `k`-step matrix products, this gives the exact multiplicity of each prefix valuation pattern.

### Proof Strategy

1. Define `kStepDomain k e` as the `k`-fold product of `splitDomain e` (using `Fin k → ℕ × ℕ` or a list-based encoding).
2. Reduce fiber counting to the classical "stars and bars with upper bounds" problem.
3. Use inclusion-exclusion over the constraints `aᵢ ≤ e`.
4. The base cases `k = 1` (trivial) and `k = 2` (triangular law) are already proven.

### Cross-Domain Connection

**Additive combinatorics ↔ Tropical convolution.** The `k`-step fiber formula is a baby case of sumset counting in bounded intervals. It is the discrete tropical analogue of the probability density of a sum of `k` uniform random variables — a B-spline. This bridges tropical matrix iteration to classical probability and approximation theory.

---

## 2. Entropy Lower Bound from Fiber Upper Bound

### Theorem Statement

For uniform sampling on `twoStepDomain e`, the collision probability of `prefixSum` satisfies:

```
∑ s in Finset.range (2*e + 1),
  ((twoStepDomain e).filter (fun x => prefixSum x = s)).card ^ 2
  ≤ (e + 1)^2 * (2*e + 1) / 3
```

Equivalently, the Rényi entropy H₂(prefixSum) ≥ 2 * log(e + 1) - log((2*e + 1)/3).

### Why It Matters

This is a quantitative anti-concentration result: the prefix sum statistic of two-step tropical codes cannot be too concentrated. It implies that tropical matrix composition produces "spread out" prefix distributions, formalizing the intuition that tropical dynamics generates entropy.

### Proof Strategy

1. Use `prefixSum_fiber_card_exact` to compute exact fiber sizes.
2. Sum the squares: ∑_{s=0}^{2e} f(s)² where f(s) is the triangular law.
3. This reduces to ∑_{s=0}^{e} (s+1)² + ∑_{s=e+1}^{2e} (2e-s+1)² = 2 * ∑_{j=1}^{e+1} j² - (e+1)² = (e+1)(2e+1)(2e+3)/3 - (e+1)² ... (exact computation).
4. Compare with the trivial bound (e+1)^4 to extract the entropy gap.

### Cross-Domain Connection

**Information theory ↔ Tropical dynamics.** This is the non-archimedean analogue of entropy production in random matrix products. The fact that fiber sizes are triangular (not flat) implies strict entropy increase at each composition step — a discrete version of the Furstenberg–Kesten theorem.

---

## 3. Matrix Realization Theorem

### Theorem Statement

Define a family of 2×2 tropical matrices over ℕ:

```
M(a, b) = !![a, b; 0, 0]   (min-plus convention)
```

where `a + b = e`. The "valuation prefix" of a matrix product `M(a₁,b₁) ⊗ M(a₂,b₂)` extracts the top-left entry of the product. Then the fiber distribution of this valuation prefix over all pairs matches the triangular law from `prefixSum_fiber_card_exact`.

### Why It Matters

This would bridge the abstract split-domain counting to actual tropical matrix multiplication. It shows that the triangular law is not an artifact of the combinatorial encoding but genuinely reflects the multiplicity structure of tropical matrix products.

### Proof Strategy

1. Define min-plus matrix multiplication for 2×2 matrices over `ℕ ∪ {∞}`.
2. Compute the product `M(a₁,b₁) ⊗ M(a₂,b₂)` explicitly.
3. Show the top-left entry equals `min(a₁ + a₂, a₁ + b₂, b₁ + a₂, b₁ + b₂)` = `a₁ + a₂` (under suitable monotonicity conditions on the split).
4. Invoke `prefixSum_fiber_card_exact` to conclude.

### Cross-Domain Connection

**Tropical geometry ↔ Random matrix products.** This realizes the abstract counting theory within the concrete world of tropical linear algebra. It opens the door to generalizing from rank-one matrices to generic tropical matrices, connecting to the Litvinov–Maslov dequantization program.

---

## 4. Ultrametric Orbit Bridge

### Theorem Statement

Combine finite prefix multiplicity bounds with dynamical contraction:

```
theorem orbit_rigidity (e N : ℕ) (f : ℕ → ℕ) (hf : ∀ n, f n ≤ e)
    (hcontr : ∀ n, dist (f (n+1)) (f n) ≤ dist (f n) (f (n-1)) / 2) :
    ∃ L, ∀ n ≥ N, f n = L
```

That is: if an orbit in a bounded space contracts ultrametrically, it must eventually stabilize. The prefix multiplicity theory provides the finite-time bounds; the contraction hypothesis forces eventual rigidity.

### Why It Matters

This bridges the finite combinatorial theory (prefix fiber bounds) with asymptotic dynamical theory (orbit stabilization). It shows that controlled fiber multiplicity at finite time implies strong rigidity at infinite time, completing the "finite-to-asymptotic" picture.

### Proof Strategy

1. Use the fiber bound to show that at each step, the orbit can visit at most `e + 1` distinct states.
2. Use the contraction hypothesis to show that the set of visited states shrinks geometrically.
3. By a counting argument, after `O(log e)` steps the orbit must be constant.
4. Reference the existing `contraction_orbit_bound` and `ultrametric_orbit_tail_bound` theorems as precedent.

### Cross-Domain Connection

**Ultrametric dynamics ↔ Proof learning.** In the context of proof-state search, orbits represent sequences of proof attempts. Ultrametric contraction models the convergence of proof strategies. The fiber bound ensures that the "entropy" of proof-state prefixes is controlled, enabling efficient search termination.

---

## 5. Algorithmic Counting via Convolution

### Theorem Statement

There exists an algorithm that, given `(k, e, s)`, computes the `k`-step fiber cardinality in `O(k * min(s, k*e - s, e))` arithmetic operations. Moreover, this algorithm is certified correct by the `k`-step simplex fiber formula.

### Why It Matters

Efficient computation of fiber sizes enables practical applications:
- Monte Carlo sampling from tropical matrix products with controlled rejection rates.
- Exact counting of orbit prefixes for symbolic dynamics applications.
- Certified enumeration for proof search space estimation.

### Proof Strategy

1. Implement the inclusion-exclusion formula as a loop over `j = 0, ..., min(k, ⌊s/e⌋)`.
2. Use the recurrence relation: the `k`-step fiber count satisfies a discrete convolution identity from the `(k-1)`-step counts.
3. Prove correctness by induction on `k`, using `prefixSum_fiber_card_exact` as the base case.
4. The complexity bound follows from the bounded number of terms in the inclusion-exclusion sum.

### Cross-Domain Connection

**Algorithmic complexity ↔ Tropical sort complexity.** The `tropical_sort_complexity_bound` theorem establishes that tropical sorting is algorithmically tame. The counting algorithm here extends this: not only is prefix extraction efficient, but the multiplicity statistics of prefixes are also efficiently computable. This supports the thesis that tropical combinatorics admits a complete "certified algorithmic theory."
