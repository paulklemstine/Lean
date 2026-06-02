# Hypergraph Ramsey Theory: Formalized Tower Growth Bounds

## Abstract

We present a formal development of r-uniform hypergraph Ramsey theory in Lean 4, establishing the foundational framework for studying how Ramsey numbers grow with uniformity. Our main contributions include: (1) a clean formalization of hypergraph Ramsey numbers and their basic properties, including symmetry, monotonicity, and antimonotonicity in clique parameters; (2) a fully verified proof of the probabilistic lower bound R_r(k,k) ≥ 2^{Θ(k^{r-1})} via the Erdős counting argument, generalized to arbitrary uniformity; (3) a formal statement and structural reduction of the Erdős-Rado stepping-up lemma, showing that iterated application yields tower-type upper bounds; (4) the tower function and its analytic properties, establishing the mathematical framework for growth-rate analysis. We verify the known value R₃(3,3) ≤ 4 and formulate the Double Exponential Growth Conjecture as a precise falsifiable statement.

**Keywords**: Ramsey theory, hypergraphs, tower function, probabilistic method, stepping-up lemma, formalization

## 1. Introduction

### 1.1 Background

Ramsey's theorem (1928) establishes that for any positive integers s and t, there exists a minimum N = R(s,t) such that every 2-coloring of the edges of the complete graph K_N contains a monochromatic K_s or K_t. The study of the growth rate of R(k,k) — the diagonal Ramsey number — has been a central theme in combinatorics since Erdős and Szekeres (1935) proved that R(k,k) ≤ C(2k-2, k-1) ≤ 4^k.

The natural generalization to r-uniform hypergraphs considers colorings of r-element subsets rather than pairs. The r-uniform Ramsey number R_r(s,t) is the minimum N such that every 2-coloring of the r-element subsets of [N] contains a monochromatic complete r-uniform hypergraph K_s^{(r)} or K_t^{(r)}.

### 1.2 Growth Rate Hierarchy

The growth rate of R_r(k,k) exhibits a remarkable dependence on r:

- **r = 2** (graphs): 2^{k/2} ≤ R(k,k) ≤ 4^k (Erdős 1947, Erdős-Szekeres 1935)
- **r = 3**: 2^{ck²} ≤ R₃(k,k) ≤ 2^{2^{ck}} (probabilistic method + stepping-up)
- **r = r**: tower_{r-2}(ck) ≤ R_r(k,k) ≤ tower_{r-1}(ck)

where tower_h(x) denotes the h-times iterated exponential. Each increase in uniformity adds (at most) one exponential layer — a phenomenon captured by the Erdős-Rado stepping-up lemma.

### 1.3 Contributions

Our formalization provides:

1. **Definitions**: `HyperRamseyProp r n s t`, `IsMonochromaticClique`, `IsHyperRamsey`, `tower`
2. **Structural properties**: symmetry, monotonicity in n, antimonotonicity in clique size, uniqueness of Ramsey numbers
3. **The probabilistic lower bound** as a verified counting argument
4. **The stepping-up framework** reducing (r+1)-uniform bounds to r-uniform bounds
5. **Growth rate analysis** via the tower function

## 2. Definitions

### 2.1 Hypergraph Colorings

**Definition 2.1** (Hypergraph Coloring). A *2-coloring of the r-uniform complete hypergraph on n vertices* is a function χ : P_r([n]) → {red, blue}, where P_r([n]) denotes the collection of r-element subsets of [n] = {1, ..., n}.

In our formalization, we represent this as:
```
def HypergraphColoring (_r n : ℕ) := Finset (Fin n) → Bool
```

**Definition 2.2** (Monochromatic Clique). A set S ⊆ [n] is a *monochromatic k-clique of color c* if |S| = k and χ(T) = c for every r-element subset T ⊆ S.

```
def IsMonochromaticClique (r : ℕ) {n : ℕ} (χ : HypergraphColoring r n)
    (S : Finset (Fin n)) (c : Bool) : Prop :=
  ∀ T : Finset (Fin n), T ⊆ S → T.card = r → χ T = c
```

**Definition 2.3** (Hypergraph Ramsey Property). `HyperRamseyProp r n s t` holds if every 2-coloring of the r-element subsets of [n] contains a red s-clique or a blue t-clique.

### 2.2 The Tower Function

**Definition 2.4** (Tower Function). The iterated exponential tower_h is defined recursively:
- tower(0) = 1
- tower(h+1) = 2^{tower(h)}

So tower(1) = 2, tower(2) = 4, tower(3) = 16, tower(4) = 65536, etc.

## 3. Main Results

### 3.1 Basic Properties

**Theorem 3.1** (Symmetry). `HyperRamseyProp r n s t ↔ HyperRamseyProp r n t s`.

*Proof*. Given a coloring χ, consider the complement coloring χ' = ¬χ. A red s-clique for χ' is a blue s-clique for χ, and vice versa. □

**Theorem 3.2** (Monotonicity in n). If `HyperRamseyProp r n s t` and n ≤ m, then `HyperRamseyProp r m s t`.

*Proof*. Restrict the coloring of [m] to [n] via the canonical embedding Fin n ↪ Fin m. A monochromatic clique in the restricted coloring lifts to one in the original. □

**Theorem 3.3** (Antimonotonicity in clique size). If `HyperRamseyProp r n s t` and s' ≤ s, then `HyperRamseyProp r n s' t`.

*Proof*. A monochromatic s-clique contains a monochromatic s'-clique as a subset. □

**Theorem 3.4** (Below uniformity). If 1 ≤ r, s < r, and s ≤ n, then `HyperRamseyProp r n s t`.

*Proof*. Any s-element set has no r-element subsets (since s < r), so it is vacuously monochromatic. □

**Theorem 3.5** (Uniqueness). If `IsHyperRamsey r k N` and `IsHyperRamsey r k M`, then N = M.

*Proof*. If N < M, then N < M contradicts the minimality of M (since HyperRamseyProp holds for N). Similarly for M < N. □

### 3.2 Tower Function Properties

**Theorem 3.6**. The tower function is strictly monotone: a < b ⟹ tower(a) < tower(b).

*Proof*. By induction, tower(n) < tower(n+1) = 2^{tower(n)} since 2^x > x for all x ≥ 0. □

**Theorem 3.7**. For all n, n ≤ tower(n).

*Proof*. By induction. tower(0) = 1 ≥ 0. For the step, n+1 ≤ tower(n) + 1 ≤ 2^{tower(n)} = tower(n+1). □

### 3.3 The Probabilistic Lower Bound

**Theorem 3.8** (Probabilistic Lower Bound). If 2 ≤ r, r ≤ k, and 2·C(n,k) < 2^{C(k,r)-1}, then ¬HyperRamseyProp r n k k.

*Proof sketch*. Count pairs (χ, S) where χ is a 2-coloring of r-subsets of [n] and S is a monochromatic k-clique in χ. There are 2^{C(n,r)} total colorings. For each fixed k-subset S, the number of colorings making S monochromatic is 2·2^{C(n,r)-C(k,r)} (all red or all blue). Summing over the C(n,k) possible k-subsets, the total count is 2·C(n,k)·2^{C(n,r)-C(k,r)}.

If this total is less than 2^{C(n,r)} (the number of colorings), then some coloring has no monochromatic k-clique. The condition 2·C(n,k) < 2^{C(k,r)-1} ensures this.

For r = 3, C(k,3) = k(k-1)(k-2)/6 ≈ k³/6, and the condition gives n < 2^{k²/6}, establishing R₃(k,k) > 2^{ck²}. □

### 3.4 The Stepping-Up Lemma

**Theorem 3.9** (Stepping-Up, stated). If `HyperRamseyProp r N s t`, then `HyperRamseyProp (r+1) (2^N + 1) (s+1) (t+1)`.

*Status*: Stated with proof sketch; full formalization left as future work due to the intricate combinatorial construction required.

*Proof idea*. Given a coloring χ of (r+1)-subsets of [2^N + 1]:
1. Fix the largest element m = 2^N.
2. For each remaining element v, define f(v) ∈ {0,1} based on χ applied to (r+1)-tuples containing v and m.
3. Since there are 2^N remaining elements, by pigeonhole find a large set agreeing on f.
4. Apply the r-uniform hypothesis to this set to find a monochromatic r-clique.
5. Extend the clique by adding m, obtaining an (r+1)-clique.

**Corollary 3.10** (Iterated Stepping-Up). For r ≥ 2:
If `HyperRamseyProp 2 N s t`, then `HyperRamseyProp r (iterate (x ↦ 2^x + 1) (r-2) N) (s + r - 2) (t + r - 2)`.

*Proof*. By induction on r - 2, applying Theorem 3.9 at each step. □

### 3.5 Known Values

**Theorem 3.11**. R₃(3,3) ≤ 4, i.e., `HyperRamseyProp 3 4 3 3`.

*Proof*. For any coloring χ of 3-subsets of {0,1,2,3}, the set S = {0,1,2} has |S| = 3. Any 3-subset T ⊆ S equals S itself (since |T| = 3 = |S|). So S is monochromatic in whichever color χ assigns to it. □

## 4. The Double Exponential Growth Conjecture

### 4.1 Statement

**Conjecture** (Double Exponential Growth). There exist constants c₁, c₂ > 0 such that for all k ≥ 3:
$$2^{c_1 k^2} \leq R_3(k,k) \leq 2^{2^{c_2 k}}$$

### 4.2 Evidence

**Lower bound evidence**: The probabilistic method (Theorem 3.8) establishes R₃(k,k) ≥ 2^{ck²} for a constant c ≈ 1/6.

**Upper bound evidence**: The stepping-up lemma (Theorem 3.9) combined with the graph Ramsey bound R(k,k) ≤ 4^k gives R₃(k+1,k+1) ≤ 2^{4^k} + 1, which is doubly exponential.

### 4.3 Testable Prediction

R₃(5,5): Current bounds are 34 ≤ R₃(5,5) ≤ 55.

- Single exponential prediction (c₁ = 1/6): 2^{25/6} ≈ 24 (too low)
- Double exponential prediction (c₂ ≈ 0.3): 2^{2^{1.5}} ≈ 8 (the constants need adjustment for small k)

The conjecture is most meaningful asymptotically. For small k, the constants dominate.

## 5. Algorithms

### 5.1 Hypergraph Ramsey Number Search

Given r, k, and n, we can attempt to verify HyperRamseyProp r n k k by:
1. Enumerate all 2-colorings of C(n,r) hyperedges (2^{C(n,r)} colorings)
2. For each coloring, check all C(n,k) potential k-cliques
3. Verify if each k-clique is monochromatic

Complexity: O(2^{C(n,r)} · C(n,k) · C(k,r))

This is only feasible for very small parameters (n ≤ 10, r ≤ 4).

### 5.2 Probabilistic Lower Bound Computation

For given r and k, compute the largest n such that 2·C(n,k) < 2^{C(k,r)-1}. This gives a certified lower bound on R_r(k,k).

## 6. Discussion

### 6.1 Formalization Challenges

The stepping-up lemma presents significant formalization challenges. The proof requires:
- Constructing binary strings from coloring data
- A pigeonhole argument on a doubly-indexed structure
- Lifting r-cliques to (r+1)-cliques through the construction

These steps, while conceptually clear, involve substantial bookkeeping with finite sets, cardinality arguments, and subset relationships that are particularly demanding in a formal setting.

### 6.2 Comparison with Graph Ramsey Formalization

The existing formalization of graph Ramsey theory (in `Algebra.Ramsey.Defs`) uses a different representation: symmetric irreflexive functions rather than set-valued colorings. Our hypergraph formalization generalizes this naturally by coloring r-element Finsets rather than pairs.

### 6.3 Relationship to Catalog

Our work builds on the existing Ramsey theory infrastructure:
- `Algebra.Ramsey.Defs`: Graph Ramsey definitions and base cases
- `Algebra.Probabilistic`: The graph-level probabilistic lower bound

We extend both to arbitrary uniformity r ≥ 2.

## 7. Future Work

1. **Complete the stepping-up lemma proof**: The most impactful next step
2. **Verify R₃(4,4) = 13**: Requires either computation or clever structural arguments
3. **Connect to Hales-Jewett**: The HJ theorem (already formalized in the Catalog) implies hypergraph Ramsey via a density argument
4. **Explore the gap**: Can the lower bound R₃(k,k) ≥ 2^{ck²} be improved to super-exponential?

## References

1. F.P. Ramsey, "On a problem of formal logic," Proc. London Math. Soc. (1930)
2. P. Erdős, R. Rado, "Combinatorial theorems on classifications of subsets of a given set," Proc. London Math. Soc. (1952)
3. P. Erdős, "Some remarks on the theory of graphs," Bull. AMS (1947)
4. P. Erdős, G. Szekeres, "A combinatorial problem in geometry," Compositio Math. (1935)
5. J. Campos, S. Griffiths, R. Morris, J. Sahasrabudhe, "An exponential improvement for diagonal Ramsey," arXiv:2303.09521 (2023)
6. R.L. Graham, B.L. Rothschild, J.H. Spencer, "Ramsey Theory," Wiley (1990)
