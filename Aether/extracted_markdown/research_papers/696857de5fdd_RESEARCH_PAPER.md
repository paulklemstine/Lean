# A Formal Framework for r-Uniform Hypergraph Ramsey Theory

## Abstract

We develop a formal framework for r-uniform hypergraph Ramsey theory in Lean 4 with Mathlib, establishing the tower function hierarchy, the Erdős probabilistic lower bound, and key structural properties of hypergraph Ramsey numbers. Our formalization introduces novel definitions for hypergraph colorings and the Ramsey property parameterized by uniformity, vertex count, clique size, and number of colors. We prove 15 theorems without axioms beyond Lean's standard foundations, including the strictly monotone growth of the tower function, the Erdős counting bound for arbitrary uniformity, and the concrete consequence that R(s,s) > s for s ≥ 6. Our framework supports future formalization of the Erdős-Rado stepping-up lemma and tower-type upper bounds.

## 1. Introduction

Ramsey theory, initiated by Frank Ramsey (1930) and developed extensively by Erdős, Rado, and their collaborators, studies the emergence of order in sufficiently large combinatorial structures. The central question asks: given parameters r (uniformity), s (clique size), and k (number of colors), what is the minimum n such that every k-coloring of the r-element subsets of an n-element set contains a monochromatic s-element subset?

For graphs (r = 2), the Ramsey numbers R(s,t) grow exponentially in s and t. The celebrated result of Erdős (1947) showed R(s,s) > 2^{s/2} using the probabilistic method, while Erdős and Szekeres (1935) proved R(s,s) ≤ C(2s-2, s-1) ≈ 4^s/√s. Despite decades of work, the gap between these bounds has resisted closure, with the recent breakthrough of Campos, Griffiths, Morris, and Sahasrabudhe (2023) improving the upper bound to (4-ε)^s.

For r-uniform hypergraphs with r ≥ 3, the situation changes dramatically. The Erdős-Rado stepping-up lemma (1952) shows that the Ramsey numbers R_r(s,s) grow as a tower of exponentials of height r - 2, a phenomenon unique to higher uniformity. This tower growth has deep connections to computational complexity, circuit lower bounds, and the limits of mathematical definability.

This paper presents the first (to our knowledge) formal verification of the foundational results of hypergraph Ramsey theory, including the tower function hierarchy and the Erdős counting bound for arbitrary uniformity.

## 2. Definitions

### 2.1 Tower Function

The tower function captures iterated exponentiation:

**Definition (Tower Function).** For base b ∈ ℕ, define towerExp : ℕ → ℕ → ℕ by:
- towerExp(b, 0) = 1
- towerExp(b, n+1) = b^{towerExp(b, n)}

This yields: tow(2,0) = 1, tow(2,1) = 2, tow(2,2) = 4, tow(2,3) = 16, tow(2,4) = 65536, tow(2,5) = 2^{65536}.

### 2.2 Hypergraph Coloring

**Definition (r-Uniform Hypergraph Coloring).** A k-coloring of r-element subsets of Fin n is a function c : {S : Finset (Fin n) | S.card = r} → Fin k.

**Definition (Monochromaticity).** A subset T ⊆ Fin n is monochromatic under coloring c with color i if for every S ⊆ T with |S| = r, c(S) = i.

### 2.3 Ramsey Property

**Definition (Hypergraph Ramsey Property).** HypergraphRamseyProp(r, n, s, k) holds if every k-coloring of r-element subsets of Fin n contains a monochromatic subset of size at least s.

The Ramsey number R_r(s; k) is the minimum n such that HypergraphRamseyProp(r, n, s, k) holds.

## 3. Tower Function Analysis

### 3.1 Basic Properties

**Theorem 3.1 (Positivity).** For b > 0, towerExp(b, n) > 0 for all n.
*Proof.* Induction on n. Base: towerExp(b,0) = 1 > 0. Step: towerExp(b, n+1) = b^{towerExp(b,n)} > 0 since b > 0. □

**Theorem 3.2 (Lower bound).** For b ≥ 2 and n ≥ 1, towerExp(b, n) ≥ 2.
*Proof.* Induction on n. Base: towerExp(b,1) = b ≥ 2. Step: towerExp(b, n+1) = b^{towerExp(b,n)} ≥ 2^2 = 4 ≥ 2 by the inductive hypothesis. □

### 3.2 Growth Rate

**Theorem 3.3 (Strict Monotonicity).** For b ≥ 2, the function n ↦ towerExp(b, n) is strictly increasing.
*Proof.* It suffices to show towerExp(b, n) < towerExp(b, n+1) for all n. We have towerExp(b, n+1) = b^{towerExp(b,n)} ≥ 2^{towerExp(b,n)} > towerExp(b, n), where the last inequality uses the standard fact that 2^m > m for all m ∈ ℕ. □

**Theorem 3.4 (Super-exponential bound).** For b ≥ 2 and n ≥ 1, b^n ≤ towerExp(b, n).
*Proof.* Induction on n. Base: towerExp(b,1) = b = b^1. Step: towerExp(b, n+1) = b^{towerExp(b,n)} ≥ b^{b^n} ≥ b^{n+1}, where the first inequality uses the inductive hypothesis and the second uses b^n ≥ n+1 (which holds for b ≥ 2 by a standard induction). □

**Theorem 3.5 (Super-exponential growth).** For b ≥ 2, b^{towerExp(b,n)} < towerExp(b, n+2).
*Proof.* towerExp(b, n+2) = b^{towerExp(b, n+1)} and towerExp(b, n+1) > towerExp(b, n) by Theorem 3.3, so b^{towerExp(b, n+1)} > b^{towerExp(b, n)} since b ≥ 2. □

### 3.3 Base Monotonicity

**Theorem 3.6 (Base monotonicity).** For 2 ≤ a < b and n ≥ 1, towerExp(a, n) < towerExp(b, n).
*Proof.* Induction on n. Base: towerExp(a, 1) = a < b = towerExp(b, 1). Step: towerExp(a, n+1) = a^{towerExp(a,n)} < b^{towerExp(a,n)} ≤ b^{towerExp(b,n)} = towerExp(b, n+1), using a < b for the first inequality and the inductive hypothesis with monotonicity of b^{(-)} for the second. □

### 3.4 Tower Nesting

**Theorem 3.7 (Nesting bound).** For b ≥ 2 and m ≥ 1, towerExp(b, m+1) ≤ towerExp(b, towerExp(b, m)).
*Proof.* By strict monotonicity, towerExp(b, m) ≥ m + 1 (since towerExp(b, m) > m). Therefore towerExp(b, towerExp(b, m)) ≥ towerExp(b, m+1) by monotonicity. □

**Theorem 3.8 (Iteration bound).** For b ≥ 2, n ≥ 1, k ≥ 1:
  towerExp(b, n·k) ≤ (x ↦ towerExp(b, x))^{[k]}(towerExp(b, n))
*Proof.* Induction on k, using the nesting bound and monotonicity at each step. □

## 4. Structural Properties of the Ramsey Property

**Theorem 4.1 (Vacuous case).** For k > 0, HypergraphRamseyProp(r, n, 0, k) holds for all r, n.
*Proof.* The empty set is monochromatic with any color, and |∅| = 0 ≥ 0. □

**Theorem 4.2 (Vertex monotonicity).** If HypergraphRamseyProp(r, n, s, k) holds and n ≤ m, then HypergraphRamseyProp(r, m, s, k) holds.
*Proof.* Given a coloring of r-subsets of Fin m, restrict to the embedding Fin n ↪ Fin m and apply the hypothesis. □

**Theorem 4.3 (Clique anti-monotonicity).** If s₁ ≤ s₂ and HypergraphRamseyProp(r, n, s₂, k) holds, then HypergraphRamseyProp(r, n, s₁, k) holds.
*Proof.* Any monochromatic set of size ≥ s₂ also has size ≥ s₁. □

**Theorem 4.4 (Color anti-monotonicity).** If k₂ ≥ 1, k₂ ≤ k₁, and HypergraphRamseyProp(r, n, s, k₁) holds, then HypergraphRamseyProp(r, n, s, k₂) holds.
*Proof.* Embed Fin k₂ ↪ Fin k₁ via Fin.castLE. A k₂-coloring becomes a k₁-coloring; the monochromatic set lifts back by injectivity. □

**Theorem 4.5 (Negation characterization).** ¬HypergraphRamseyProp(r, n, s, k) ↔ ∃ c, ∀ T, ∀ color, |T| ≥ s → T is not monochromatic under c with color.
*Proof.* Pushing negation through quantifiers. □

## 5. The Erdős Counting Bound

**Theorem 5.1 (Erdős counting bound).** Let r ≥ 2, r ≤ s ≤ n. If C(n,s) · 2 < 2^{C(s,r)}, then ¬HypergraphRamseyProp(r, n, s, 2).

*Proof sketch.* Consider the set of all 2-colorings of r-subsets of [n], identified with subsets of the r-subsets (inclusion = color 0, exclusion = color 1). For each s-element set T, the colorings making T monochromatic in a fixed color correspond to those containing (or excluding) all C(s,r) r-subsets of T. There are 2^{C(n,r) - C(s,r)} such colorings per color, so 2 · 2^{C(n,r) - C(s,r)} bad colorings per s-set. By the union bound over all C(n,s) s-sets, the total bad colorings number at most C(n,s) · 2 · 2^{C(n,r) - C(s,r)}. If this is less than 2^{C(n,r)} (i.e., C(n,s) · 2 < 2^{C(s,r)}), some coloring is good.

The formal proof constructs this counting argument over Finsets, using the powerset of the set of r-subsets as the space of colorings. □

**Corollary 5.2.** For s ≥ 6, ¬HypergraphRamseyProp(2, s, s, 2), i.e., R(s,s) > s.
*Proof.* C(s,s) = 1, so the condition becomes 2 < 2^{C(s,2)}. Since C(s,2) ≥ C(6,2) = 15 for s ≥ 6, we have 2 < 2^{15} = 32768. □

## 6. Connection to Tower Bounds

The tower function hierarchy directly governs the growth rate of hypergraph Ramsey numbers:

- For r = 2 (graphs): R(s,s) grows as towerExp(2, 1) · Θ(s) ∈ [2^{s/2}, 4^s]
- For r = 3: R_3(s,s) grows as towerExp(2, Θ(s²)) ∈ [2^{cs²}, tow(2, O(s))]  
- For general r: R_r(s,s) grows as a tower of height r - 2 in s

The stepping-up lemma of Erdős and Rado provides the upper bound: if HypergraphRamseyProp(r, n, s, k) holds, then HypergraphRamseyProp(r+1, 2^n, s+1, k) also holds (roughly). Iterating from the base case r = 2 builds a tower of height r - 2.

Our Theorem 3.8 (iteration bound) captures the key structural feature: applying the tower function k times produces a value that exceeds towerExp(b, n·k), formalizing the depth-to-growth correspondence that underlies the stepping-up construction.

## 7. Algorithms

### 7.1 Tower Function Computation

```
TowerExp(b, n):
  if n = 0: return 1
  return b^TowerExp(b, n-1)
```

### 7.2 Erdős Bound Verification

```
ErdosBoundHolds(r, n, s):
  return C(n,s) * 2 < 2^C(s,r)
```

### 7.3 Ramsey Lower Bound Search

```
FindRamseyLowerBound(r, s):
  n = s
  while ErdosBoundHolds(r, n, s):
    n += 1
  return n - 1  # R_r(s,s) > n-1
```

## 8. Future Work

1. **Stepping-Up Lemma**: Decompose the full Erdős-Rado stepping-up lemma into (a) a binary string assignment lemma, (b) pigeonhole extraction, and (c) clique lifting.

2. **Upper Bounds**: Formalize the Erdős-Szekeres recurrence R(s,t) ≤ R(s-1,t) + R(s,t-1) and its generalization to hypergraphs.

3. **Connections to Circuit Complexity**: The monotone circuit lower bound for the clique function uses Ramsey-theoretic arguments (Razborov, 1985). Formalizing this connection would bridge our framework with the existing circuit complexity formalization.

4. **Tropical Ramsey Theory**: Investigate Ramsey-type phenomena in tropical semirings, where the min-plus structure offers different combinatorial behavior.

## References

1. F.P. Ramsey, "On a Problem of Formal Logic," Proc. London Math. Soc., 1930.
2. P. Erdős, "Some Remarks on the Theory of Graphs," Bull. Amer. Math. Soc., 1947.
3. P. Erdős and R. Rado, "Combinatorial Theorems on Classifications of Subsets of a Given Set," Proc. London Math. Soc., 1952.
4. R. Graham, B. Rothschild, and J. Spencer, *Ramsey Theory*, Wiley, 1990.
5. S. Campos, S. Griffiths, R. Morris, and J. Sahasrabudhe, "An exponential improvement for diagonal Ramsey," 2023.
