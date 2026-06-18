# Future Directions

## 1. Tropical Bernstein Theorem in Lean

**Hypothesis:** The planar tropical Bézout formalization can be extended to a certified tropical Bernstein theorem where stable intersection multiplicity equals mixed area of Newton polygons for all generic bivariate tropical polynomials, including sparse systems.

**Test:** Formalize a computable 2D lattice convex hull algorithm and mixed area computation for arbitrary lattice polygons. Verify the mixed area equals the mixed lattice index on at least five non-simplex Newton polygon pairs (e.g., rectangles, trapezoids, L-shapes). Prove the equality MixedArea(ConvHull(A), ConvHull(B)) = MixedLatticeIndex(ConvHull(A), ConvHull(B)) for arbitrary convex lattice polygons using a formal Pick's theorem.

**Potential falsifier:** A formal obstruction in the lattice-point encoding of convex hulls prevents efficient computation of mixed areas for non-convex support sets, or the mixed lattice index formula fails to equal the geometric mixed area for degenerate polygon pairs where boundary lattice points have non-trivial gcd structure.

---

## 2. Valuated Matroid Intersection Shadow

**Hypothesis:** Tropical stable intersection data of hypersurfaces can be recast via valuated matroid intersection in a way that simplifies multiplicity proofs and enables a more algebraic formalization path.

**Test:** Define a finite valuated matroid model for tropical lines (rank 2) and tropical conics (rank 3) over a finite ground set. Compute the valuated matroid intersection product and compare multiplicity outputs against the determinant-based local intersection formula on explicit examples with d₁ = d₂ = 2. Verify agreement on at least three generic coefficient choices.

**Potential falsifier:** The valuated matroid model fails to recover local multiplicities even in generic transverse rank-2 cases, because the matroid intersection product captures only the combinatorial type of the intersection, not the metric data encoded in edge weights.

---

## 3. Certified Root Counting via Tropicalization

**Hypothesis:** A restricted tropicalization-preserves-intersection theorem can be used to certify algebraic root-counting bounds for sparse bivariate systems over valued fields, at least for polynomials over ℚ with the p-adic valuation.

**Test:** Implement tropicalization for bivariate polynomials over ℚ_p (or a formal approximation thereof) for primes p = 2, 3, 5. For at least five sparse polynomial systems with known root counts (computable via resultants), verify that the tropical intersection count matches the algebraic root count. Formalize the comparison for at least one explicit system in Lean 4.

**Potential falsifier:** The tropical count systematically overcounts due to missing genericity hypotheses not capturable in the formal model — specifically, if the coefficients lie on a tropical discriminant locus where the tropicalization map has non-trivial fiber structure, the tropical count exceeds the algebraic count even for "generic-looking" inputs.

---

## 4. Tropical Hodge–Intersection Bridge

**Hypothesis:** The mixed lattice index formalization can be extended to define a tropical intersection pairing on finite-dimensional tropical cycle spaces, yielding a verified positivity statement (nonnegativity of self-intersection for effective cycles) that mirrors the Hodge index theorem.

**Test:** Define a tropical cycle space for balanced weighted graphs in ℝ² with at most N vertices (for small N ≤ 10). Define the intersection pairing via the mixed lattice index of dual Newton subdivisions. Prove nonnegativity of the pairing for effective tropical divisors on at least three explicit tropical curves of genus ≤ 2.

**Potential falsifier:** The intersection pairing defined via mixed lattice index fails to be well-defined on tropical cycle equivalence classes because the mixed lattice index is not invariant under tropical rational equivalence of divisors. This would manifest as two rationally equivalent divisors having different self-intersection numbers.

---

## 5. Mixed Volume Monotonicity via Lattice Compression

**Hypothesis:** The inequality MixedLatticeIndex(A, B) ≤ d₁ · d₂ for A ⊆ Δ_{d₁}, B ⊆ Δ_{d₂} (where A, B are the complete lattice point sets of convex subpolygons) can be proved by a combinatorial compression argument that reduces arbitrary convex subsets to degree simplices while monotonically increasing the mixed lattice index.

**Test:** Define a "lattice compression" operation that, given a convex lattice polygon P ⊊ Δ_d, produces a strictly larger convex lattice polygon P' with P ⊊ P' ⊆ Δ_d such that MixedLatticeIndex(P, Q) ≤ MixedLatticeIndex(P', Q) for all convex Q. Verify computationally for all convex sublattice polygons of Δ_d with d ≤ 5 that repeated compression converges to Δ_d.

**Potential falsifier:** No single-step compression operation exists that simultaneously increases the mixed lattice index with respect to ALL possible second arguments Q. This would mean monotonicity requires a global argument (such as Aleksandrov-Fenchel) rather than a local compression step, making the combinatorial approach infeasible.
