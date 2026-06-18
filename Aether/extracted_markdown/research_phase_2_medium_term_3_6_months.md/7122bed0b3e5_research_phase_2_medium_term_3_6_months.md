# Tropical Boundary Rigidity, Gromov Hyperbolicity, and Certified Min-Plus Linear Algebra: A Unified Framework

## Abstract

We establish a formally verified framework connecting three mathematical domains through tropical (min-plus) algebra: (1) boundary rigidity for series-parallel networks, (2) Gromov δ-hyperbolicity of tropical path metrics, and (3) certified tropical matrix algebra. We prove that the boundary distance of a two-terminal series-parallel network equals the evaluation of a canonical tropical expression, providing a complete invariant for SP-equivalence. We prove that ultrametric spaces are 0-hyperbolic, establish the equivalence between four-point hyperbolicity and Gromov product conditions, and show that two-terminal SP boundary metrics are 0-hyperbolic. We develop a certified tropical matrix library with proofs of associativity, monotonicity, and finite infimum manipulation lemmas. All results are machine-verified in Lean 4 with Mathlib, with zero `sorry` statements.

**Keywords**: tropical geometry, boundary rigidity, Gromov hyperbolicity, min-plus algebra, series-parallel networks, formal verification

## 1. Introduction

### 1.1 Motivation

The interplay between metric geometry, network combinatorics, and algebraic structure has deep roots in mathematics and computer science. Three classical threads are:

1. **Boundary rigidity / inverse problems**: Given boundary measurements of a network (distances, resistances, or responses), can one reconstruct the internal structure? This is the discrete analogue of the Calderón inverse problem and the boundary rigidity conjecture in Riemannian geometry.

2. **Gromov hyperbolicity**: Gromov's four-point definition of δ-hyperbolicity [Gromov 1987] provides a coarse notion of negative curvature applicable to metric spaces without smooth structure. Tree metrics are 0-hyperbolic, and many real-world networks (internet topology, social networks) exhibit low hyperbolicity.

3. **Tropical (min-plus) linear algebra**: The min-plus semiring (ℝ ∪ {+∞}, min, +) provides the algebraic foundation for shortest-path problems, scheduling, and dynamic programming. Tropical matrix multiplication computes minimum-weight walks.

### 1.2 Contributions

Our main contributions are:

1. **Boundary rigidity for two-terminal SP networks** (Theorem 4.5): We prove that the boundary distance is a complete invariant for SP-equivalence, and that every SP network canonically reduces to a single edge.

2. **Hyperbolicity results** (Section 5): We prove that ultrametric spaces are 0-hyperbolic (Theorem 5.2), establish the four-point/Gromov product equivalence (Theorem 5.5), and show SP boundary metrics are 0-hyperbolic.

3. **Certified tropical matrix algebra** (Section 3): We prove associativity (Theorem 3.3) and monotonicity (Theorem 3.4) of tropical matrix multiplication over `Matrix (Fin n) (Fin n) ℝ`.

4. **The three-way bridge** (Theorem 6.1): We unify these results, showing that SP networks are tropical expressions, their boundary metrics are 0-hyperbolic, and the algebraic structure is certified by tropical matrix operations.

5. **Full formal verification**: All 35+ theorems are machine-verified in Lean 4 with zero `sorry` statements.

### 1.3 Related Work

**Boundary rigidity**: Curtis, Ingerman, and Morrow [1998] proved boundary rigidity for planar networks using Dirichlet-to-Neumann maps. De Verdière, Gitler, and Vertigan [1996] established connections between electrical networks and graph theory. Our work differs in using tropical (shortest-path) rather than electrical (resistance) response.

**Tropical geometry**: Mikhalkin [2006], Itenberg, Mikhalkin, and Shustin [2009] developed tropical algebraic geometry. Joswig [2021] provided computational perspectives. Our contribution is the connection to boundary rigidity and formal verification.

**Gromov hyperbolicity**: Gromov [1987] introduced the concept. Chepoi et al. [2008] studied hyperbolicity of graphs. Bermudo et al. [2013] analyzed hyperbolicity of graph operations. Our contribution is the formal proof connecting hyperbolicity to tropical structure.

**Formal verification of mathematics**: Mathlib [2020+] provides the largest library of formalized mathematics. Our work contributes new tropical geometry and coarse geometry results to the formally verified corpus.

## 2. Preliminaries

### 2.1 Tropical Semiring

The **min-plus tropical semiring** is (ℝ, ⊕, ⊙) where:
- a ⊕ b := min(a, b) (tropical addition)
- a ⊙ b := a + b (tropical multiplication)

Key properties (all formally verified):
- ⊕ is commutative, associative, idempotent
- ⊙ is commutative, associative, with identity 0
- ⊙ distributes over ⊕: a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)
- Both operations are monotone

### 2.2 Series-Parallel Networks

**Definition 2.1.** A *two-terminal series-parallel (SP) network* is defined inductively:
- `edge(w)` for w > 0: a single weighted edge
- `series(N₁, N₂)`: series composition (end-to-end connection)
- `parallel(N₁, N₂)`: parallel composition (same-terminal connection)

**Definition 2.2.** The *boundary distance* of an SP network is:
- spDist(edge(w)) = w
- spDist(series(N₁, N₂)) = spDist(N₁) + spDist(N₂)
- spDist(parallel(N₁, N₂)) = min(spDist(N₁), spDist(N₂))

### 2.3 Gromov Hyperbolicity

**Definition 2.3.** A pseudo-metric space (X, d) is *δ-hyperbolic in the four-point sense* if for all w, x, y, z ∈ X:

d(w,x) + d(y,z) ≤ max(d(w,y) + d(x,z), d(w,z) + d(x,y)) + 2δ

**Definition 2.4.** The *Gromov product* of x, y with basepoint w is:
(x|y)_w = (d(w,x) + d(w,y) - d(x,y)) / 2

## 3. Tropical Matrix Algebra

### 3.1 Definitions

**Definition 3.1.** The *tropical matrix product* of A, B ∈ M_n(ℝ) is:
(A ⊗ B)_{ij} = ⨅_{k} (A_{ik} + B_{kj})

where the infimum is over Fin n (equivalently, the minimum over a finite set).

**Definition 3.2.** The *tropical matrix power* A^k is defined inductively:
- A^0 = I (tropical identity)
- A^{k+1} = A^k ⊗ A

### 3.2 Associativity

**Theorem 3.3** (Tropical matrix multiplication is associative).
*For all A, B, C ∈ M_n(ℝ), (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C).*

**Proof sketch.** By extensionality at indices (i, j). The key steps are:
1. Distribute the infimum past addition: ⨅_k (f(k) + c) = (⨅_k f(k)) + c (using `ciInf_add`)
2. Pull constants out: c + ⨅_k f(k) = ⨅_k (c + f(k)) (using `add_ciInf`)
3. Commute infima: ⨅_i ⨅_j f(i,j) = ⨅_j ⨅_i f(i,j) (using `Finset.inf'_comm`)

When n = 0, both sides are vacuously equal (Fin 0 is empty). When n > 0:

((A ⊗ B) ⊗ C)_{ij} = ⨅_k (⨅_l (A_{il} + B_{lk})) + C_{kj}
= ⨅_k ⨅_l (A_{il} + B_{lk} + C_{kj})     [distribute + C_{kj}]
= ⨅_k ⨅_l (A_{il} + (B_{lk} + C_{kj}))   [associativity of +]
= ⨅_l ⨅_k (A_{il} + (B_{lk} + C_{kj}))   [commute infima]
= ⨅_l (A_{il} + ⨅_k (B_{lk} + C_{kj}))   [factor out A_{il}]
= (A ⊗ (B ⊗ C))_{ij}                       □

### 3.3 Monotonicity

**Theorem 3.4** (Tropical matrix multiplication is monotone).
*If A ≤ A' and B ≤ B' (entrywise), then A ⊗ B ≤ A' ⊗ B'.*

**Proof.** For each (i,j), use `ciInf_mono` with the fact that A_{ik} + B_{kj} ≤ A'_{ik} + B'_{kj} for all k. □

### 3.4 Helper Lemmas

Three key lemmas enable the associativity proof:

1. **ciInf_add_fin**: ⨅_{k : Fin n} (f(k) + c) = (⨅_k f(k)) + c
2. **add_ciInf_fin**: c + ⨅_{k : Fin n} f(k) = ⨅_k (c + f(k))
3. **ciInf_comm_fin**: ⨅_{i : Fin n} ⨅_{j : Fin m} f(i,j) = ⨅_{j} ⨅_{i} f(i,j)

These leverage Mathlib's `ciInf_add`, `add_ciInf`, and `Finset.inf'_comm` respectively.

## 4. Series-Parallel Networks and Boundary Rigidity

### 4.1 Algebraic Properties of SP Composition

**Theorem 4.1** (Series is associative up to SP-equivalence).
series(series(N₁, N₂), N₃) ≡ series(N₁, series(N₂, N₃))

**Theorem 4.2** (Parallel is commutative, associative, and idempotent).
- parallel(N₁, N₂) ≡ parallel(N₂, N₁)
- parallel(parallel(N₁, N₂), N₃) ≡ parallel(N₁, parallel(N₂, N₃))
- parallel(N, N) ≡ N

**Theorem 4.3** (Distributivity).
spDist(series(N₁, parallel(N₂, N₃))) = min(spDist(series(N₁, N₂)), spDist(series(N₁, N₃)))

All follow directly from properties of + and min on ℝ.

### 4.2 Canonical Form

**Theorem 4.4** (Canonical reduction).
*Every SP network N reduces to edge(spDist(N)). That is, there exists w > 0 and a proof hw : 0 < w such that N ≡ edge(w, hw).*

**Proof.** Take w = spDist(N). By Theorem 4.6, spDist(N) > 0. Then SPEquiv(N, edge(w, hw)) holds by definition (both have boundary distance w). □

**Theorem 4.5** (Boundary rigidity).
*Two SP networks N₁, N₂ satisfy SPEquiv(N₁, N₂) if and only if spDist(N₁) = spDist(N₂).*

**Proof.** By definition of SPEquiv. □

**Theorem 4.6** (Positivity).
*spDist(N) > 0 for every SP network N.*

**Proof.** By induction on N. For edge(w, hw), spDist = w > 0. For series, spDist = d₁ + d₂ > 0 since d₁, d₂ > 0. For parallel, spDist = min(d₁, d₂) > 0 since d₁, d₂ > 0. □

### 4.3 Tropical Interpretation

**Theorem 4.7** (SP distance is tropical evaluation).
*The function spDist : SPNet → ℝ is the unique homomorphism from the free SP algebra to the tropical semiring (ℝ, min, +) that sends edge(w) to w.*

This is made precise via the `TropExpr` inductive type and the `sp_eval_eq_dist` theorem.

### 4.4 Monotonicity and Lipschitz Properties

**Theorem 4.8** (Series is monotone).
If spDist(N₁) ≤ spDist(N₁') and spDist(N₂) ≤ spDist(N₂'), then
spDist(series(N₁, N₂)) ≤ spDist(series(N₁', N₂')).

**Theorem 4.9** (Parallel is monotone). Same statement with parallel.

**Theorem 4.10** (Series is 1-Lipschitz).
|spDist(series(N₁, N₂)) - spDist(series(N₁', N₂))| = |spDist(N₁) - spDist(N₁')|

## 5. Gromov Hyperbolicity

### 5.1 Basic Properties

**Theorem 5.1** (Monotonicity of hyperbolicity).
*If X is δ-hyperbolic and δ ≤ δ', then X is δ'-hyperbolic.*

**Proof.** Direct from the definition: if d(w,x) + d(y,z) ≤ max(...) + 2δ, then also ≤ max(...) + 2δ'. □

### 5.2 Ultrametric Spaces

**Theorem 5.2** (Ultrametric spaces are 0-hyperbolic).
*If (X, d) is an ultrametric space (d(x,z) ≤ max(d(x,y), d(y,z)) for all x,y,z), then X is 0-hyperbolic.*

**Proof sketch.** Given w, x, y, z, apply the ultrametric inequality to bound d(w,x) ≤ max(d(w,y), d(y,x)) and d(y,z) ≤ max(d(y,w), d(w,z)). Case analysis on which terms dominate gives d(w,x) + d(y,z) ≤ max(d(w,y) + d(x,z), d(w,z) + d(x,y)). □

### 5.3 Finite Metric Spaces

**Theorem 5.3** (Finite spaces are hyperbolic).
*Every finite metric space is δ-hyperbolic for some δ ≥ 0.*

**Proof.** Since X is finite, D = max_{x,y} d(x,y) exists. Then X is D-hyperbolic by Theorem 5.4. □

**Theorem 5.4** (Diameter bound).
*If d(x,y) ≤ D for all x, y, then X is D-hyperbolic.*

**Proof.** d(w,x) + d(y,z) ≤ 2D ≤ 0 + 2D ≤ max(...) + 2D since max(...) ≥ 0. □

### 5.4 Gromov Product Characterization

**Theorem 5.5** (Four-point ↔ Gromov product).
*For δ ≥ 0, X is δ-hyperbolic in the four-point sense if and only if for all w, x, y, z:
(x|y)_w ≥ min((x|z)_w, (z|y)_w) - δ.*

**Proof.** Both directions proceed by algebraic manipulation of the Gromov product definition (x|y)_w = (d(w,x) + d(w,y) - d(x,y))/2 and case analysis on which maximum/minimum is achieved. □

**Theorem 5.6** (Gromov product is nonneg).
*(x|y)_w ≥ 0 for all x, y, w.*

**Proof.** By the triangle inequality, d(x,y) ≤ d(x,w) + d(w,y) = d(w,x) + d(w,y). □

### 5.5 SP Network Hyperbolicity

**Theorem 5.7** (Two-terminal SP metrics are 0-hyperbolic).
*The boundary metric on {source, sink} induced by any SP network N is 0-hyperbolic.*

**Proof.** The metric space has only two points. Any two-point metric space is trivially 0-hyperbolic: in the four-point condition, at least two of the four points must coincide, reducing the inequality to a trivial identity or a consequence of nonnegativity of distances. □

## 6. The Three-Way Bridge

### 6.1 Summary Theorem

**Theorem 6.1** (Three-way bridge).
*For every SP network N:*
1. *(Tropical algebra)* The boundary distance equals the tropical expression evaluation: `(spToExpr N).eval = spDist N`.
2. *(Boundary rigidity)* SP-equivalence is exactly equality of boundary distance: `SPEquiv N N' ↔ spDist N = spDist N'`.
3. *(Positivity)* `spDist N > 0`.
4. *(Matrix encoding)* The 2×2 tropical matrix encoding preserves distance: `spToMatrix N 0 1 = spDist N`.

### 6.2 Matrix Product Connection

**Theorem 6.2** (Tropical matrix product = parallel composition).
*For SP networks N₁, N₂ with 2×2 matrix encodings, (M₁ ⊗ M₂)₀₁ = spDist(parallel(N₁, N₂)).*

This reveals that tropical matrix multiplication on 2×2 distance matrices computes the parallel composition distance, not the series composition distance—a natural consequence of the minimization in the matrix product.

## 7. Computational Experiments

### 7.1 SP Network Enumeration

We enumerate SP networks with edge weights in {1, 2, 3} up to depth 1, producing 21 networks grouped into 6 SP-equivalence classes by boundary distance. This confirms the rigidity theorem computationally.

| Distance | Networks | Examples |
|----------|----------|----------|
| 1 | 6 | Edge(1), Parallel(Edge(1), Edge(1)), ... |
| 2 | 5 | Edge(2), Series(Edge(1), Edge(1)), ... |
| 3 | 4 | Edge(3), Series(Edge(1), Edge(2)), ... |
| 4 | 3 | Series(Edge(1), Edge(3)), Series(Edge(2), Edge(2)), ... |
| 5 | 2 | Series(Edge(2), Edge(3)), Series(Edge(3), Edge(2)) |
| 6 | 1 | Series(Edge(3), Edge(3)) |

### 7.2 Hyperbolicity Computation

We compute optimal δ for various metric spaces:

| Space | Points | δ | 0-Hyperbolic? |
|-------|--------|---|---------------|
| Path tree | 3 | 0 | ✓ |
| Star tree | 4 | 0 | ✓ |
| 4-cycle | 4 | 1.0 | ✗ |
| Two-point | 2 | 0 | ✓ |
| Ultrametric | 4 | 0 | ✓ |

### 7.3 Tropical Matrix Closure

We verify that the tropical matrix closure (Kleene star) via Floyd-Warshall matches the infimum of tropical matrix powers, confirming the path semantics interpretation.

## 8. Discussion

### 8.1 Limitations

Our boundary rigidity result for two-terminal SP networks is, in a sense, tautological: the boundary is a single distance value, and SP-equivalence is defined as equality of this value. The non-trivial content lies in:
- The tropical expression interpretation (boundary distance = tropical polynomial evaluation)
- The canonical reduction theorem (every SP network reduces to a single edge)
- The algebraic laws (associativity, commutativity, distributivity, idempotency)

For genuine boundary rigidity with richer invariants, one needs multi-terminal networks where the boundary data is a distance matrix, not a single number.

### 8.2 Significance of Formal Verification

All 35+ theorems are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound). This provides the highest level of confidence in correctness and establishes a certified foundation for future development.

### 8.3 The Tropical Unification Principle

The common thread is that tropical operations (min and +) simultaneously:
- Compute shortest paths (optimization)
- Evaluate network invariants (rigidity)
- Control metric curvature (hyperbolicity)

This suggests a general principle: **boundary data determines internal geometry precisely in classes where tropical convexity is tame**, i.e., where the min-plus structure imposes enough rigidity on the solution space.

## 9. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps, including:
1. Multi-terminal SP boundary rigidity with distance matrix invariants
2. Sharp hyperbolicity bounds for bounded-treewidth networks
3. Tropical Perron-Frobenius theory for strongly connected digraphs
4. Tropical Schur complement for elimination-based network reduction

## References

1. Bermudo, S., Rodríguez, J.M., Sigarreta, J.M., Vilaire, J.-M. (2013). Gromov hyperbolic graphs. *Discrete Mathematics*, 313(15), 1575-1585.

2. Chepoi, V., Dragan, F.F., Estellon, B., Habib, M., Vaxès, Y. (2008). Diameters, centers, and approximating trees of δ-hyperbolic geodesic spaces. *J. Comput. Geom.*, 1(1), 59-84.

3. Curtis, E.B., Ingerman, D., Morrow, J.A. (1998). Circular planar graphs and resistor networks. *Linear Algebra Appl.*, 283, 115-150.

4. de Verdière, Y.C., Gitler, I., Vertigan, D. (1996). Réseaux électriques planaires II. *Comment. Math. Helv.*, 71(1), 144-167.

5. Gromov, M. (1987). Hyperbolic groups. In *Essays in Group Theory*, MSRI Publ. 8, 75-263.

6. Itenberg, I., Mikhalkin, G., Shustin, E. (2009). *Tropical Algebraic Geometry*. Birkhäuser.

7. Joswig, M. (2021). *Essentials of Tropical Combinatorics*. AMS.

8. Mikhalkin, G. (2006). Tropical geometry and its applications. In *Proc. ICM Madrid*, Vol. II, 827-852.

9. The Mathlib Community (2020+). *Mathlib: A Unified Library of Mathematics Formalized*. https://leanprover-community.github.io/mathlib4_docs/
