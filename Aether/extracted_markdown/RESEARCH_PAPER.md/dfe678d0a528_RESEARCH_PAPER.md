# Sperner's Lemma Implies Nash Equilibria: Combinatorial Fixed Points in Game Theory

## Abstract

We develop the formal bridge between Sperner's lemma — a foundational result of combinatorial topology — and Nash's equilibrium theorem in finite game theory. We formalize the theory of two-player finite games, mixed strategies, and approximate Nash equilibria, proving several structural theorems: (1) the fundamental decomposition of expected payoff as a convex combination of deviation payoffs, (2) the equivalence between Nash equilibria and 0-approximate Nash equilibria, (3) the Nash gap characterization of approximate equilibria, (4) the support lemma (positive-probability strategies achieve maximal payoff in equilibrium), (5) zero-sum payoff cancellation, and (6) linearity of deviation payoffs. We state the Sperner-Nash bridge theorem — that Sperner's lemma implies the existence of approximate Nash equilibria of arbitrary quality — and provide its constructive proof strategy via triangulation-based Sperner coloring. All results except the bridge theorem are fully machine-verified.

**Keywords**: Sperner's lemma, Nash equilibrium, approximate equilibrium, combinatorial fixed points, game theory, zero-sum games, support lemma

---

## 1. Introduction

John Nash's 1950 theorem [Nash50] that every finite game has a mixed strategy Nash equilibrium is one of the most celebrated results in mathematics and economics. The original proof uses Kakutani's fixed point theorem (a generalization of Brouwer's fixed point theorem), which is inherently topological. This raises a natural question: can Nash's theorem be proved using purely combinatorial methods?

Sperner's lemma (1928) provides a combinatorial analog of Brouwer's fixed point theorem. For any proper coloring of a triangulated n-simplex, at least one sub-simplex is fully colored (contains all n+1 colors). Since Sperner's lemma and Brouwer's theorem are equivalent, and Brouwer's theorem implies Kakutani's (in finite dimensions), Sperner's lemma must also imply Nash's theorem.

In this paper, we make this implication explicit by:
1. Developing a clean formalization of two-player finite games and approximate Nash equilibria
2. Proving structural theorems about the relationship between exact and approximate equilibria
3. Constructing the Sperner coloring from a game's best-response structure
4. Showing that fully-colored sub-simplices correspond to approximate Nash equilibria

The Sperner approach has several advantages over the topological proof:
- It is constructive, yielding the Scarf-Lemke algorithm for computing equilibria
- The approximation quality is controlled by the mesh size of the triangulation
- It connects Nash's theorem to the complexity class PPAD, explaining *why* finding equilibria is hard

### 1.1. Related Work

The connection between Sperner's lemma and fixed point theorems is classical (Knaster-Kuratowski-Mazurkiewicz, 1929). The computational implications were developed by Scarf (1967) and Lemke-Howson (1964). The PPAD complexity connection was established by Papadimitriou (1994). Our contribution is the formal verification of the game-theoretic machinery and the explicit construction of the bridge.

---

## 2. Definitions

### 2.1. Finite Games

**Definition 2.1** (Bimatrix Game). A *two-player finite game* `BimatrixGame m n` consists of:
- A payoff function `payoff₁ : Fin m → Fin n → ℝ` for Player 1
- A payoff function `payoff₂ : Fin m → Fin n → ℝ` for Player 2

where Player 1 has `m` pure strategies and Player 2 has `n` pure strategies.

### 2.2. Mixed Strategies

**Definition 2.2** (Mixed Strategy). A *mixed strategy* `MixedStrategy k` is a probability distribution over `Fin k`:
- `prob : Fin k → ℝ` with `∀ i, 0 ≤ prob i` and `∑ prob i = 1`

**Definition 2.3** (Mixed Strategy Profile). A profile `MixedStrategyProfile m n` pairs strategies `p : MixedStrategy m` and `q : MixedStrategy n`.

### 2.3. Payoffs and Equilibria

**Definition 2.4** (Expected Payoff). For Player 1:
$$E_1(p, q) = \sum_{i,j} p_i \cdot q_j \cdot A_{ij}$$

**Definition 2.5** (Deviation Payoff). The payoff to Player 1 from deviating to pure strategy `i`:
$$D_1(q, i) = \sum_j q_j \cdot A_{ij}$$

**Definition 2.6** (Nash Equilibrium). A profile `σ` is a Nash equilibrium if:
$$\forall i,\ D_1(q, i) \leq E_1(\sigma) \quad\text{and}\quad \forall j,\ D_2(p, j) \leq E_2(\sigma)$$

**Definition 2.7** (Approximate Nash Equilibrium). A profile `σ` is an *ε-approximate Nash equilibrium* if:
$$\forall i,\ D_1(q, i) \leq E_1(\sigma) + \varepsilon \quad\text{and}\quad \forall j,\ D_2(p, j) \leq E_2(\sigma) + \varepsilon$$

### 2.4. Nash Gap

**Definition 2.8** (Nash Gap). The Nash gap for Player 1:
$$\text{gap}_1(\sigma) = \max_i D_1(q, i) - E_1(\sigma) = \text{BR}_1(q) - E_1(\sigma)$$

The total Nash gap: $\text{gap}(\sigma) = \max(\text{gap}_1(\sigma), \text{gap}_2(\sigma))$.

### 2.5. Sperner Coloring (Novel Definition)

**Definition 2.9** (Sperner Instance). A `SpernerInstance m n` specifies a triangulation mesh size `δ > 0` for the product simplex `Δ(m) × Δ(n)`.

**Definition 2.10** (Labeled Simplex). A `LabeledSimplex m n` is a fully-labeled sub-simplex: a collection of `m + n` vertices with `m + n` distinct labels, where each label appears exactly once.

---

## 3. Main Results

### 3.1. Fundamental Decomposition Theorem

**Theorem 3.1** (Expected Payoff Decomposition).
$$E_1(p, q) = \sum_i p_i \cdot D_1(q, i)$$

*Proof sketch.* Expand the double sum and factor out `p_i`:
$$\sum_{i,j} p_i q_j A_{ij} = \sum_i p_i \left(\sum_j q_j A_{ij}\right) = \sum_i p_i \cdot D_1(q, i)$$

This identity is the cornerstone of equilibrium analysis: it shows that the expected payoff under a mixed strategy is a convex combination of the deviation payoffs. ∎

### 3.2. Nash Equilibrium Characterizations

**Theorem 3.2** (Nash ↔ 0-Approximate Nash).
$$\sigma \text{ is Nash} \iff \sigma \text{ is 0-Nash}$$

**Theorem 3.3** (Monotonicity). If `σ` is ε-Nash and `ε ≤ ε'`, then `σ` is ε'-Nash.

**Theorem 3.4** (Gap Characterization). For `ε ≥ 0`:
$$\sigma \text{ is ε-Nash} \iff \text{gap}(\sigma) \leq \varepsilon$$

### 3.3. Nash Gap Nonnegativity

**Theorem 3.5** (Nash Gap ≥ 0).
$$\text{gap}_k(\sigma) \geq 0 \quad \text{for } k = 1, 2$$

*Proof sketch.* By Theorem 3.1, `E₁ = ∑ pᵢ · D₁(q, i)`. Since `pᵢ ≥ 0` and `∑pᵢ = 1`, this is a convex combination. The maximum of the `D₁(q, i)` values is at least as large as any convex combination. Hence `BR₁(q) ≥ E₁(σ)`, giving `gap₁ ≥ 0`. ∎

### 3.4. Support Lemma

**Theorem 3.6** (Support Lemma). If `σ` is a Nash equilibrium and `p_i > 0`, then:
$$D_1(q, i) = E_1(\sigma)$$

*Proof sketch.* By Nash, `D₁(q, i) ≤ E₁` for all `i`. Suppose `D₁(q, i₀) < E₁` for some `i₀` with `p_{i₀} > 0`. Then by the decomposition theorem:
$$E_1 = \sum_k p_k D_1(q, k) < \sum_k p_k E_1 = E_1$$
a contradiction. The strict inequality follows because `p_{i₀} > 0` and `D_1(q, i_0) < E_1`, while all other terms satisfy `p_k D_1(q, k) ≤ p_k E_1`. ∎

*Significance.* This is the mathematical content of the "indifference principle": in equilibrium, all strategies used with positive probability yield identical expected payoffs. This is why mixed strategy equilibria involve players being genuinely indifferent between their pure strategies.

### 3.5. Zero-Sum Theory

**Theorem 3.7** (Zero-Sum Cancellation). If `∀ i j, B_{ij} = -A_{ij}`, then:
$$E_1(\sigma) + E_2(\sigma) = 0$$

**Theorem 3.8** (Approximate Minimax). In a zero-sum game, if `σ` is ε-Nash, then:
$$\forall i,\ D_1(q, i) \leq E_1(\sigma) + \varepsilon$$

### 3.6. Linearity of Deviation Payoffs

**Theorem 3.9** (Convex Combination of Deviation Payoffs). For mixed strategies `q₁, q₂` and `q_{\text{mix}} = t q_1 + (1-t) q_2`:
$$D_1(q_{\text{mix}}, i) = t \cdot D_1(q_1, i) + (1-t) \cdot D_1(q_2, i)$$

*Significance.* This linearity is what makes the Sperner coloring well-defined: the best-response structure varies continuously (indeed linearly) with the strategy profile, ensuring that the coloring of nearby vertices is consistent.

---

## 4. The Sperner-Nash Bridge Construction

### 4.1. Construction

Given a game `G` with `m` and `n` strategies:

1. **Triangulate**: Divide the product simplex `Δ(m) × Δ(n)` into sub-simplices of mesh size `δ = 1/K` for integer `K`.

2. **Color**: Assign each vertex `v = (p, q)` a color in `{1, ..., m+n}`:
   - Color `v` with `i ∈ {1,...,m}` if `D₁(q, i) - E₁(v)` is maximized at `i` (Player 1's most profitable deviation is to strategy `i`)
   - Color `v` with `m+j` for `j ∈ {1,...,n}` if `D₂(p, j) - E₂(v)` is maximized at `j` (Player 2 benefits most from deviating to `j`)

3. **Boundary condition**: On the face where `p_i = 0` (Player 1 assigns zero probability to strategy `i`), there's no incentive specific to strategy `i`, so the coloring avoids color `i`. Similarly for Player 2. This satisfies Sperner's boundary condition.

4. **Apply Sperner**: By Sperner's lemma, there exists a fully-colored sub-simplex with all `m+n` colors.

5. **Extract**: The barycenter of this sub-simplex is approximately Nash. By the linearity theorem (Theorem 3.9), the deviation payoffs at the barycenter are close to those at the vertices. Since all colors appear, the incentive to deviate is spread across all strategies, keeping any single deviation small.

### 4.2. Error Bound

**Theorem 4.1** (Regret Bound). The approximation quality is:
$$\varepsilon \leq R(G) \cdot \delta$$
where `R(G)` is the payoff range of the game and `δ` is the mesh size.

### 4.3. Convergence

Taking `K → ∞` (mesh `δ = 1/K → 0`), we obtain a sequence of `ε_K`-Nash equilibria with `ε_K → 0`. By compactness of the product simplex (it is a closed, bounded subset of `ℝ^{m+n}`), a convergent subsequence exists. The limit is a Nash equilibrium.

---

## 5. Algorithm

### 5.1. Sperner-Based Nash Equilibrium Algorithm

```
Algorithm: SpernerNash(G, K)
Input: BimatrixGame G, triangulation parameter K
Output: ε-approximate Nash equilibrium with ε = O(1/K)

1. Triangulate Δ(m) × Δ(n) with mesh 1/K
2. For each vertex v in triangulation:
     Compute deviation payoffs D₁(q, i), D₂(p, j)
     Color v = argmax over {1,...,m+n} of gains
3. Walk the triangulation (complementary pivoting):
     Start from a boundary simplex
     Follow the path of almost-completely-labeled simplices
4. Return barycenter of the fully-labeled simplex
```

**Complexity**: O(N^{m+n-1}/ε^{m+n-1}) where N = m + n is the total number of strategies.

### 5.2. Relation to Lemke-Howson

For 2-player games, this reduces to the Lemke-Howson algorithm (1964), which follows complementary pivoting paths in the best-response polytope. The Sperner perspective explains *why* Lemke-Howson terminates: the path must reach a fully-labeled simplex because Sperner's lemma guarantees its existence.

---

## 6. Discussion

### 6.1. PPAD Completeness

The Sperner-Nash bridge is not merely an alternative proof — it *defines* the complexity class PPAD (Polynomial Parity Arguments on Directed graphs). Finding a Sperner fully-colored simplex is PPAD-complete, and finding a Nash equilibrium is PPAD-complete. The bridge theorem shows these are the *same problem* in different guises.

### 6.2. Beyond Two Players

The construction generalizes to n-player games by considering the product simplex Δ(S₁) × ... × Δ(Sₙ) with dimension |S₁| + ... + |Sₙ| - n. The coloring uses |S₁| + ... + |Sₙ| colors, one per pure strategy of each player.

### 6.3. Limitations

The Sperner-based algorithm has exponential worst-case complexity in the number of players. For two-player games, the Lemke-Howson specialization is practical but can require exponentially many pivoting steps. The PPAD-completeness of the problem means no polynomial-time algorithm is expected unless PPAD = FP.

---

## 7. Future Work

1. **Formalization of Sperner's lemma** in Lean 4/Mathlib (currently absent from the library)
2. **Extension to extensive-form games** via the Sperner approach
3. **Tropical game theory**: replacing ℝ with the tropical semiring and studying tropical Nash equilibria
4. **Approximate equilibria complexity**: using Sperner mesh refinement to study the ε-dependence of PPAD
5. **Evolutionary dynamics**: connecting Sperner coloring to replicator dynamics and evolutionary stable strategies

---

## 8. Formal Verification Summary

| Theorem | Status | Key Insight |
|---------|--------|-------------|
| Expected Payoff Decomposition | ✓ Verified | Mixed payoff = convex combination of deviations |
| Nash ↔ 0-Approximate Nash | ✓ Verified | Exact and approximate concepts align at ε=0 |
| Approximation Monotonicity | ✓ Verified | Weaker equilibrium concepts are inclusive |
| Nash Gap ≥ 0 | ✓ Verified | Best response ≥ expected payoff (convexity) |
| Gap Characterization | ✓ Verified | ε-Nash ↔ gap ≤ ε (quantitative criterion) |
| Support Lemma | ✓ Verified | Positive-probability strategies are equally good |
| Zero-Sum Cancellation | ✓ Verified | Competition is perfectly balanced |
| Approximate Minimax | ✓ Verified | ε-Nash → ε-minimax in zero-sum games |
| Deviation Linearity | ✓ Verified | Sperner coloring is well-defined |
| Nash from Existence | ✓ Verified | Existence → approximate sequence |
| Sperner-Nash Bridge | ○ Stated | Requires Brouwer FPT (not in Mathlib) |

---

## References

- [Nash50] J. Nash, "Equilibrium points in n-person games," *Proceedings of the National Academy of Sciences*, 1950.
- [Sperner28] E. Sperner, "Neuer Beweis für die Invarianz der Dimensionszahl und des Gebietes," *Abhandlungen aus dem Mathematischen Seminar der Universität Hamburg*, 1928.
- [Scarf67] H. Scarf, "The approximation of fixed points of a continuous mapping," *SIAM Journal on Applied Mathematics*, 1967.
- [LH64] C.E. Lemke and J.T. Howson, "Equilibrium points of bimatrix games," *SIAM Journal on Applied Mathematics*, 1964.
- [Papa94] C.H. Papadimitriou, "On the complexity of the parity argument and other inefficient proofs of existence," *Journal of Computer and System Sciences*, 1994.
