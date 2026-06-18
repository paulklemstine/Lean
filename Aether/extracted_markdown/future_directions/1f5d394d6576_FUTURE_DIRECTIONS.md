# Future Directions: Falsifiable Hypotheses in Quantitative Jacobian Reduction Theory

This document presents five falsifiable hypotheses emerging from the formal results on triangular chain automorphisms and chain nilpotence. Each hypothesis includes a precise statement, a proposed formalization target, an explicit test, and a clear refutation criterion.

---

## Hypothesis 1: Dependency-Path Nilpotence Law

**Conjecture.** Let $H$ be a polynomial map over a field of characteristic zero, and let $\Gamma(H)$ be the *dependency digraph* whose vertices are $\{1, \dots, n\}$ and where there is an edge $i \to j$ if $x_j$ appears in $H_i - x_i$. Let $L$ be the length of the longest directed path in $\Gamma(H)$. Then the Jacobian perturbation matrix $J(H - \mathrm{Id})$ satisfies:
$$
(J(H - \mathrm{Id}))^{L+1} = 0.
$$

**Test.** Formalize the dependency graph extraction and verify the conjecture on:
- Chain maps ($L = n-1$, already proved: $(JP)^n = 0$).
- Star maps (coordinate 1 depends on all others, $L = 1$): verify $(JP)^2 = 0$.
- Binary tree dependency patterns ($L = \lfloor \log_2 n \rfloor$): verify $(JP)^{\lfloor \log_2 n \rfloor + 1} = 0$.

**Refutation criterion.** Produce a polynomial map $H$ whose dependency graph has longest path $L$ but $(J(H - \mathrm{Id}))^{L+1} \neq 0$. Note: This is possible since the entries of the Jacobian are polynomials, and matrix multiplication involves products of polynomials whose supports may overlap in unexpected ways. The conjecture may require additional conditions (e.g., that the dependency graph is a DAG, or that the map is homogeneous).

**Impact.** If true, this would give a graph-theoretic characterization of nilpotence index, reducing algebraic nilpotence questions to combinatorial path problems. This could provide a new tool for attacking the Jacobian Conjecture by controlling nilpotence through graph structure.

**Proposed Lean formalization:**
```lean
theorem nilpotence_index_le_longest_path
    {k : Type*} [Field k] [CharZero k] {n : ℕ}
    (H : PolyMap k n) (L : ℕ)
    (hDAG : DependencyGraph.IsDAG H)
    (hL : DependencyGraph.longestPath H = L) :
    (jacobianMatrix (perturbation H)) ^ (L + 1) = 0
```

---

## Hypothesis 2: Newton-Polytope Inversion Law

**Conjecture.** For triangular tame automorphisms $F$, the degree of $F^{-1}$ equals the maximal weight propagated through the substitution DAG under tropical (max-plus) arithmetic:
$$
\deg(F^{-1}) = \max_{\text{sink-to-source paths}} \prod_{\text{edges } (i,j) \text{ on path}} \deg_{x_j}(F_i).
$$

For the chain family $F_{n,d}$, each edge contributes degree $d$, and the longest path has $n-1$ edges, giving $d^{n-1}$.

**Test.** Compute the tropical weight propagation for:
- Chain maps (should give $d^{n-1}$ ✓).
- Mixed-degree triangular maps $F_i = x_i + x_{i+1}^{d_i}$ with varying $d_i$.
- Triangular maps with non-pure-power perturbations.

**Refutation criterion.** Exhibit a triangular automorphism where the tropical propagation strictly overestimates the true inverse degree (due to monomial cancellation in the inverse).

**Impact.** If true, this would connect polynomial inversion to tropical geometry, enabling fast computation of inverse degrees via max-plus linear algebra.

**Proposed Lean formalization:**
```lean
theorem tropical_inverse_degree_eq
    {k : Type*} [Field k] [CharZero k] {n : ℕ}
    (F : PolyMap k n)
    (hTriangular : IsTriangularAutomorphism F) :
    polyMapDegree (inverseMap F) = tropicalWeight (substitutionDAG F)
```

---

## Hypothesis 3: Arithmetic-Complexity Lower Bound

**Conjecture.** Any straight-line program (arithmetic circuit) computing the first coordinate $(G_{n,d})_1$ of the inverse of the triangular chain map $F_{n,d}$ requires multiplicative depth at least $n-1$.

**Test.**
- Verify that the recursive construction achieves depth exactly $n-1$.
- For small cases ($n = 3, 4$), exhaustively search for lower-depth circuits.
- Compare with known circuit lower bounds for iterated composition.

**Refutation criterion.** Exhibit an explicit arithmetic circuit computing $(G_{n,d})_1$ with multiplicative depth strictly less than $n-1$. This would require a non-obvious algebraic identity that shortcuts the nested power structure.

**Impact.** A formal lower bound would establish the triangular chain family as a canonical hard instance for arithmetic circuit complexity, connecting polynomial automorphism theory to Valiant's algebraic complexity theory.

**Proposed formalization:** This is primarily a computer science formalization challenge. A useful intermediate step would be:
```lean
theorem inverse_first_coord_depth_ge
    {k : Type*} [Field k] [CharZero k]
    (n d : ℕ) (hn : 2 ≤ n) (hd : 2 ≤ d)
    (C : ArithCircuit k n)
    (hC : C.computes (triangularChainInv k n d ⟨0, by omega⟩)) :
    C.multiplicativeDepth ≥ n - 1
```

---

## Hypothesis 4: Rigidity of Extremizers

**Conjecture.** Let $F$ be a tame polynomial automorphism of degree $d$ in $n$ variables over a field of characteristic zero. If $\deg(F^{-1}) = d^{n-1}$ (the maximum possible), then $F$ is equivalent to the triangular chain map $F_{n,d}$ up to affine coordinate changes and permutations. That is, there exist invertible affine maps $A, B$ such that $A \circ F \circ B = F_{n,d}$.

**Test.**
- Classify extremizers for $n = 2$: verify that $F(x,y) = (ax + by + cy^d, ex + fy)$ with $\deg(F^{-1}) = d$ must be affinely equivalent to $(x + y^d, y)$.
- Classify extremizers for $n = 3, d = 2$: verify all tame quadratic automorphisms achieving inverse degree 4.
- Search for non-triangular extremizers using parametric families.

**Refutation criterion.** Exhibit a tame automorphism $F$ with $\deg(F) = d$ and $\deg(F^{-1}) = d^{n-1}$ that is NOT affinely equivalent to the triangular chain map. Possible candidates: maps with non-triangular elementary decompositions, or maps where multiple coordinates contribute to the maximum inverse degree.

**Impact.** If true, this would establish a uniqueness theorem for extremizers, analogous to rigidity theorems in analysis (e.g., the Brunn-Minkowski equality case). This would imply that the triangular chain family is not just *an* extremizer but *the* extremizer.

**Proposed Lean formalization:**
```lean
theorem extremizer_rigidity
    {k : Type*} [Field k] [CharZero k]
    (n d : ℕ) (hn : 2 ≤ n) (hd : 2 ≤ d)
    (F : PolyMap k n) (hTame : IsTameAutomorphism F)
    (hDeg : polyMapDegree F = d)
    (hInvDeg : polyMapDegree (inverseMap F) = d ^ (n - 1)) :
    ∃ (A B : AffineEquiv k n), polyMapComp A (polyMapComp F B) = triangularChainMap k n d
```

---

## Hypothesis 5: Quadratic Keller Compression in Sparse Support Classes

**Conjecture.** Let $H = (H_1, \dots, H_n)$ be a homogeneous cubic polynomial map over a field of characteristic zero satisfying the Keller condition ($\det(I + JH) = 1$). If the dependency graph $\Gamma(H)$ has maximum out-degree 1 (each perturbation coordinate depends on at most one variable), then $(JH)^2 = 0$.

**Note.** The general claim "$(JH)^2 = 0$ for all chain cubic maps" is FALSE (verified computationally: for $H = (x_2^3, x_3^3, 0)$, $(JH)^2 \neq 0$ even though $\det(I + tJH) = 1$ for all $t$). The refinement here restricts to out-degree-1 dependency with the Keller condition.

**Test.**
- Check the $n = 3$ case: $H = (c_1 x_2^3, c_2 x_3^3, 0)$. The Keller condition is automatic (upper triangular Jacobian with 1s on diagonal). Compute $(JH)^2$: entry $(1,3) = 9c_1 c_2 x_2^2 x_3^2 \neq 0$ if $c_1, c_2 \neq 0$.
- This DISPROVES the conjecture as stated! Refine to: does the Keller condition plus out-degree 1 force $(JH)^{\lceil n/2 \rceil + 1} = 0$?
- Test refined versions with explicit coefficient computations.

**Refutation criterion.** The conjecture as stated is already refuted by the $n = 3$ example above. The interest lies in finding the *correct* compression bound for sparse Keller maps.

**Impact.** Identifying the correct nilpotence compression for sparse Keller maps would provide the first non-trivial subclass where nilpotence index is provably smaller than $n$, opening a path toward understanding the general cubic Jacobian Conjecture.

**Proposed Lean formalization (corrected conjecture):**
```lean
-- The correct bound for chain cubic Keller maps with out-degree 1
-- is conjectured to be (JH)^n = 0 (same as general strictly upper triangular).
-- The compression conjecture needs refinement.
theorem keller_sparse_nilpotence_bound
    {k : Type*} [Field k] [CharZero k] {n : ℕ}
    (H : PolyMap k n)
    (hHom : IsHomogeneous H 3)
    (hKeller : ∀ t : k, jacobianDet (fun i => X i + t • H i) = 1)
    (hSparse : DependencyGraph.maxOutDegree H ≤ 1) :
    (jacobianMatrix H) ^ n = 0
```

---

## Priority Ranking

1. **Hypothesis 1 (Dependency-path nilpotence)** — Most immediately testable. Already proved for chains; extending to DAGs would be a clean induction argument.

2. **Hypothesis 4 (Rigidity of extremizers)** — High mathematical value. The $n = 2$ case should be tractable and would validate the approach.

3. **Hypothesis 2 (Newton-polytope inversion)** — Connects to tropical geometry. Verifiable computationally for all triangular maps.

4. **Hypothesis 5 (Keller compression)** — Already partially refuted; the corrected version is the real target.

5. **Hypothesis 3 (Circuit lower bounds)** — Requires new infrastructure (arithmetic circuit formalization) but has strong connections to complexity theory.

---

## Methodology Note

Each hypothesis is designed to be attackable in a single research cycle:
- Hypotheses 1 and 4 are provable using the existing infrastructure (chain map definitions, nilpotence machinery).
- Hypothesis 2 requires defining tropical weights but reduces to existing degree theory.
- Hypothesis 5 requires careful coefficient analysis but no new infrastructure.
- Hypothesis 3 requires defining arithmetic circuits, which is a standalone project.

The refutation criteria are explicit and computational: in each case, a counterexample can be verified by finite computation. This ensures that negative results are as valuable as positive ones.
