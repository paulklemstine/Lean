# Algebraic Foundations of Baker-Norine Theory: A Formal Development

## Abstract

We present a formal development of the algebraic foundations of Baker-Norine theory on finite graphs. Our formalization establishes the core definitions (divisors, chip-firing, the Laplacian, linear equivalence, the canonical divisor, the genus, q-reduced divisors, and divisor rank) and proves fifteen theorems, including: (1) the conservation of degree under chip-firing and linear equivalence, (2) the Riemann-Roch degree identity deg(K_G) = 2g − 2, (3) the genus formula g(K_n) = (n−1)(n−2)/2 for complete graphs, (4) the uniqueness of q-reduced representatives in each linear equivalence class, and (5) the non-negativity of rank for effective divisors. The full Baker-Norine Riemann-Roch theorem r(D) − r(K_G − D) = deg(D) − g + 1 is stated as a formalized conjecture.

**Keywords:** chip-firing, graph divisors, Baker-Norine theory, Riemann-Roch, Laplacian, canonical divisor, q-reduced divisors, tropical geometry

---

## 1. Introduction

Baker and Norine [1] proved in 2007 that finite graphs satisfy a discrete analogue of the Riemann-Roch theorem for algebraic curves. This result established an unexpected bridge between combinatorics and algebraic geometry, with applications to tropical geometry [2], coding theory [3], and the theory of abelian sandpiles [4].

The Baker-Norine theorem states that for any divisor D on a connected graph G of genus g:

$$r(D) - r(K_G - D) = \deg(D) - g + 1$$

where r(D) is the rank of D and K_G is the canonical divisor. This formula is identical in structure to the classical Riemann-Roch theorem for algebraic curves.

In this paper, we present a formal development of the algebraic foundations needed for Baker-Norine theory. Our contributions include:

1. A complete formalization of divisors, chip-firing, the Laplacian, and linear equivalence on finite graphs.
2. Machine-verified proofs of the key structural identities connecting these concepts.
3. The definition and uniqueness proof for q-reduced divisors.
4. Specialized results for complete graphs.
5. A formal statement of the full Riemann-Roch theorem as a target for future formalization.

## 2. Definitions

### 2.1 Divisors and Degree

Let G = (V, E) be a finite simple graph. A **divisor** on G is a function D : V → ℤ. The **degree** of D is:

$$\deg(D) = \sum_{v \in V} D(v)$$

A divisor D is **effective** if D(v) ≥ 0 for all v ∈ V.

### 2.2 The Graph Laplacian and Principal Divisors

Given a function f : V → ℤ, the **Laplacian** (or principal divisor) of f is:

$$(\Delta f)(v) = \sum_{w \sim v} (f(v) - f(w))$$

where the sum is over neighbors of v. The key property is:

**Theorem 2.1 (Laplacian degree zero).** For any f : V → ℤ, deg(Δf) = 0.

*Proof sketch.* Expand the double sum ∑_v ∑_{w~v} (f(v) − f(w)) and use the symmetry of adjacency to show that the positive and negative contributions cancel. □

### 2.3 Linear Equivalence

Two divisors D₁, D₂ are **linearly equivalent**, written D₁ ~ D₂, if there exists f : V → ℤ such that D₁ − D₂ = Δf.

**Theorem 2.2.** Linear equivalence is an equivalence relation.

*Proof.* Reflexivity uses f = 0; symmetry uses −f; transitivity uses f₁ + f₂. □

**Corollary 2.3.** Linearly equivalent divisors have the same degree.

### 2.4 Chip-Firing

**Chip-firing at vertex q** transforms D to D' where:
- D'(q) = D(q) − deg(q)
- D'(v) = D(v) + 1 if v ~ q
- D'(v) = D(v) otherwise

**Theorem 2.4 (Chip-firing conservation).** Chip-firing preserves divisor degree: deg(D') = deg(D).

**Theorem 2.5.** Chip-firing produces linearly equivalent divisors: D ~ D'.

### 2.5 The Canonical Divisor and Genus

The **canonical divisor** K_G is defined by K_G(v) = deg(v) − 2.

The **genus** of G is g(G) = |E| − |V| + 1.

**Theorem 2.6 (Riemann-Roch degree identity).** deg(K_G) = 2g − 2.

*Proof.* By the handshaking lemma, ∑_v deg(v) = 2|E|. Then deg(K_G) = ∑_v (deg(v) − 2) = 2|E| − 2|V| = 2(|E| − |V| + 1) − 2 = 2g − 2. □

### 2.6 Q-Reduced Divisors

Fix a vertex q ∈ V. A divisor D is **q-reduced** if:
1. D(v) ≥ 0 for all v ≠ q.
2. For every nonempty subset S ⊆ V \ {q}, there exists v ∈ S with D(v) < |N(v) ∩ S|.

The second condition means that no subset can "fire simultaneously" — some vertex in any candidate firing set lacks sufficient chips.

**Theorem 2.7 (Uniqueness of q-reduced divisors).** If D₁ and D₂ are both q-reduced and D₁ ~ D₂, then D₁ = D₂.

*Proof sketch.* Suppose D₁ − D₂ = Δf. Consider S = {v ≠ q : f(v) > f(q)}. If S is nonempty, choose v ∈ S maximizing f. The q-reduced condition for D₂ gives a contradiction, since the Laplacian at v involves only non-negative terms from the perspective of the maximum. Similarly for {v : f(v) < f(q)}. Hence f is constant and D₁ = D₂. □

### 2.7 Divisor Rank

The **rank** of D is:
- r(D) = −1 if D is not linearly equivalent to any effective divisor.
- Otherwise, r(D) = sup{k ≥ 0 : for all effective E with deg(E) = k, D − E ~ E' for some effective E'}.

**Theorem 2.8.** If D is effective, then r(D) ≥ 0.

## 3. Complete Graph Specialization

The complete graph K_n provides explicit computations.

**Theorem 3.1.** Every vertex of K_n has degree n − 1.

**Theorem 3.2 (Genus of K_n).** g(K_n) = (n−1)(n−2)/2.

*Proof.* K_n has n(n−1)/2 edges and n vertices. Thus g = n(n−1)/2 − n + 1 = (n² − 3n + 2)/2 = (n−1)(n−2)/2. □

**Theorem 3.3 (Canonical uniformity).** K_{K_n}(v) = n − 3 for all v.

*Proof.* Since deg(v) = n − 1 for all v in K_n, K_{K_n}(v) = (n−1) − 2 = n − 3. □

## 4. The Laplacian Lattice

The **Laplacian lattice** of G is Im(Δ) = {Δf : f ∈ ℤ^V} ⊆ ℤ^V.

**Theorem 4.1.** The Laplacian lattice is a subgroup of (ℤ^V, +):
- (a) It contains the zero divisor (use f = 0).
- (b) It is closed under addition (use f₁ + f₂).
- (c) It is closed under negation (use −f).

The Jacobian group Jac(G) = ℤ^V₀ / Im(Δ|_{V₀}) (where V₀ = V \ {q}) is a finite abelian group whose order equals the number of spanning trees of G (by the matrix-tree theorem/Kirchhoff's theorem).

## 5. The Baker-Norine Riemann-Roch Theorem

**Theorem 5.1 (Baker-Norine, 2007).** For any divisor D on a connected graph G of genus g:

$$r(D) - r(K_G - D) = \deg(D) - g + 1$$

This theorem is stated in our formalization but its proof is left as an open target. The proof requires:
1. Existence and uniqueness of q-reduced representatives (Theorem 2.7 provides uniqueness).
2. Dhar's burning algorithm for constructing q-reduced representatives.
3. A careful analysis of the relationship between the rank and the q-reduced form.

The theorem has several important consequences:
- **Riemann's inequality:** r(D) ≥ deg(D) − g + 1 when deg(D) ≥ g.
- **Clifford's theorem (graph version):** r(D) ≤ deg(D)/2 for special divisors.
- When deg(D) ≥ 2g − 1, r(D) = deg(D) − g + 1 (every divisor of sufficiently large degree has maximal rank).

## 6. Algorithms

### 6.1 Dhar's Burning Algorithm

Given a divisor D and a vertex q, Dhar's algorithm determines whether D is equivalent to an effective divisor:
1. Start with all vertices unmarked.
2. Mark q as "burning."
3. Repeat: if any unmarked vertex v has at least as many marked neighbors as D(v), mark v.
4. If all vertices are marked, D is not equivalent to any effective divisor with D(q) ≥ 0.
5. Otherwise, fire the set of unmarked vertices and repeat.

This algorithm terminates in O(|V|²) steps and correctly computes the q-reduced representative.

### 6.2 Rank Computation

To compute r(D):
1. Find the q-reduced representative D₀ ~ D.
2. If D₀(q) < 0, then r(D) = −1.
3. Otherwise, set D ← D − δ_q and repeat, counting iterations until D₀(q) < 0.
4. The rank is the number of successful iterations minus 1.

## 7. Applications and Connections

### 7.1 Tropical Geometry
The divisor theory on graphs is the combinatorial backbone of tropical curve theory. The tropical Jacobian of a metric graph is a real torus whose integer lattice is governed by the graph Laplacian.

### 7.2 Sandpile Groups
The chip-firing game is equivalent to the abelian sandpile model. The Jacobian group equals the sandpile group, and its order equals the number of spanning trees (by the matrix-tree theorem).

### 7.3 Coding Theory
Divisors of high rank on a graph G define error-correcting codes. The Baker-Norine theorem provides bounds on code parameters analogous to the Goppa bounds for algebraic geometry codes.

## 8. Future Work

The most important open formalization target is the full proof of the Baker-Norine Riemann-Roch theorem. This requires:
1. Formalizing Dhar's burning algorithm and proving its correctness.
2. Establishing the existence of q-reduced representatives.
3. Proving the key duality lemma relating r(D) to the q-reduced form of K_G − D.

Beyond Riemann-Roch, promising directions include:
- Formalizing the matrix-tree theorem and its connection to the Jacobian.
- Extending to metric graphs and tropical curves.
- Formalizing the Brill-Noether theorem for graphs (Cools-Draisma-Payne-Robeva).

## 9. Summary of Formal Results

| Theorem | Statement | Status |
|---------|-----------|--------|
| Laplacian degree zero | deg(Δf) = 0 | ✓ Proved |
| Chip-firing conservation | deg(fire(q,D)) = deg(D) | ✓ Proved |
| LinEquiv preserves degree | D₁ ~ D₂ ⟹ deg(D₁) = deg(D₂) | ✓ Proved |
| LinEquiv reflexivity | D ~ D | ✓ Proved |
| LinEquiv symmetry | D₁ ~ D₂ ⟹ D₂ ~ D₁ | ✓ Proved |
| LinEquiv transitivity | D₁ ~ D₂ ∧ D₂ ~ D₃ ⟹ D₁ ~ D₃ | ✓ Proved |
| Chip-fire is LinEquiv | D ~ fire(q,D) | ✓ Proved |
| Handshaking lemma | ∑ deg(v) = 2|E| | ✓ Proved |
| RR degree identity | deg(K_G) = 2g−2 | ✓ Proved |
| Complete graph degree | deg_{K_n}(v) = n−1 | ✓ Proved |
| Complete graph genus | g(K_n) = (n−1)(n−2)/2 | ✓ Proved |
| Canonical uniformity | K_{K_n}(v) = n−3 | ✓ Proved |
| Lattice zero | 0 ∈ Im(Δ) | ✓ Proved |
| Lattice addition | Im(Δ) closed under + | ✓ Proved |
| Lattice negation | Im(Δ) closed under − | ✓ Proved |
| Q-reduced uniqueness | Unique q-reduced per class | ✓ Proved |
| Effective rank ≥ 0 | D effective ⟹ r(D) ≥ 0 | ✓ Proved |
| Baker-Norine RR | r(D)−r(K−D)=deg(D)−g+1 | ◇ Stated |

## References

1. Baker, M., Norine, S. "Riemann-Roch and Abel-Jacobi theory on a finite graph." *Advances in Mathematics* 215.2 (2007): 766-788.
2. Mikhalkin, G., Zharkov, I. "Tropical curves, their Jacobians and theta functions." *Curves and Abelian Varieties* (2008): 203-230.
3. Baker, M. "Specialization of linear systems from curves to graphs." *Algebra & Number Theory* 2.6 (2008): 613-653.
4. Dhar, D. "Self-organized critical state of sandpile automaton models." *Physical Review Letters* 64.14 (1990): 1613.
5. Corry, S., Perkinson, D. *Divisors and Sandpiles*. American Mathematical Society, 2018.
6. Cools, F., Draisma, J., Payne, S., Robeva, E. "A tropical proof of the Brill-Noether theorem." *Advances in Mathematics* 230.2 (2012): 759-776.
