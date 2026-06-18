# Future Directions: Path Groupoid and Kan Composition

## Synthesis

The machine-verified path groupoid developed here — with explicit `EndpointFixedHomotopy` witnesses for all five groupoid laws, cubical path algebra with connections, and computational verification — establishes a foundation that can be extended in two orthogonal directions: *vertically* toward higher coherences (pentagon identity, Kan filling, ∞-groupoid structure) and *horizontally* toward applications (fundamental groupoid computation, parallel transport formalization, motion planning verification). The cubical bridge between abstract interval types and topological paths provides a flexible interface for both directions. Each hypothesis below either extends the tower upward or bridges it outward to a new domain, and all are testable with the existing infrastructure.

---

## Direction 1: Pentagon Identity for Four-Fold Composition

**Conjecture:** For four composable paths `p, q, r, s` in any topological space, the five distinct associators connecting the five bracketings of `p · q · r · s` compose to form a commutative pentagon — i.e., there exists a 3-path (homotopy between homotopies) filling the pentagon diagram.

**Test:** Formalize the five associator homotopies in Lean 4 using `EndpointFixedHomotopy`, then construct the pentagon filler as a continuous map from the 3-cube `[0,1]³ → X` with prescribed boundary on all six faces. Computationally, verify that the pentagon closes to within floating-point precision for 50 random path quadruples in ℝ.

**Impact:** This would be the first machine-verified instance of a *3-dimensional* coherence condition for path spaces, moving beyond the 2-dimensional associator to genuine higher-categorical structure.

**Catalog References:** `Pythagorean/KanComposition/PathGroupoid.lean` (comp_assoc_homotopy, EndpointFixedHomotopy), `Pythagorean/KanComposition/CubicalBridge.lean` (CubicalHigherPath).

**Proof Strategy:** Define `CubicalThirdPath` as a function `I → I → I → A` with 6-face boundary conditions. Use Mathlib's `Path.Homotopy.transAssoc` iteratively and `Path.Homotopy.hcomp` to compose the five associators. The key difficulty is constructing the continuous 3-cube filler; the piecewise-linear approach from the associator should extend.

**Domain Bridges:** Category theory (Mac Lane coherence theorem), physics (Berry phase for sequential adiabatic transport), computer science (coherence of equality reasoning in cubical type theories).

**Lineage:** Extends `comp_assoc_homotopy` from 2-paths to 3-paths.

**Ambition:** Grand challenge — this has never been machine-verified in Lean for topological paths.

---

## Direction 2: Piecewise-Affine Homotopy Complexity Bound

**Conjecture:** Every unit and associativity witness for piecewise-linear concatenation on ℝⁿ can be represented by a piecewise-affine endpoint-fixed homotopy with at most 4 breakpoints in each variable. Specifically, the homotopy map `H : [0,1]² → ℝⁿ` can be decomposed into at most 16 affine regions.

**Test:** For each of the 5 groupoid laws, construct the explicit piecewise-affine homotopy formula and verify that it matches the homotopy from `Path.Homotopy.transAssoc` etc. pointwise on a 100×100 grid. Count the number of affine regions and verify the bound of 16.

**Impact:** If true, this gives a *finiteness theorem* for coherence complexity: all groupoid witnesses at the first level are finitely representable with a universal bound, independent of the paths themselves.

**Catalog References:** `Pythagorean/KanComposition/PathGroupoid.lean` (PathReparam, comp_assoc_homotopy).

**Proof Strategy:** Analyze the formulas in `Path.Homotopy.transAssoc` (which uses `Set.IccExtend` and piecewise definitions). Express each piece as an affine function of `(t, s)` and count regions.

**Domain Bridges:** Computational geometry (piecewise-linear topology), optimization (complexity of feasible region decomposition), robotics (efficient trajectory interpolation).

**Lineage:** Extends `PathReparam` and `reparamPath` to 2-dimensional reparametrization.

**Ambition:** Solid extension — likely true and provable with moderate effort.

---

## Direction 3: Cubical Connections Reduce Coherence Lemma Count

**Conjecture:** In the presence of min/max connections on the interval (as in `CubicalIntervalWithConnections`), the number of separate boundary-condition lemmas needed to verify associativity is reduced by at least 40% compared to raw piecewise proofs.

**Test:** Implement associativity for cubical paths using connections (Kan composition via `meet`/`join`) and compare the lemma count and total proof term size with the piecewise-linear approach. Use `#print` to measure proof term sizes.

**Impact:** This would provide quantitative evidence that cubical connections are not just conceptually elegant but *practically efficient* for formal verification.

**Catalog References:** `Pythagorean/KanComposition/CubicalBridge.lean` (CubicalIntervalWithConnections, meet, join), `Catalog/Logic/CubicalSemantics/Basic.lean`.

**Proof Strategy:** Define cubical path concatenation using `join` (De Morgan dual of `meet`), following Cohen-Coquand-Huber-Mörtberg. The key insight is that `join(i, rev(i))` degenerates to `i1`, which automatically handles one endpoint condition.

**Domain Bridges:** Proof engineering (metrics for proof complexity), type theory (cubical vs. simplicial approaches), automated reasoning (search space reduction).

**Lineage:** Builds directly on `CubicalIntervalWithConnections` instances.

**Ambition:** Solid extension — testable by direct comparison of two formalizations.

---

## Direction 4: Fundamental Groupoid of the Circle

**Conjecture:** The quotient of the path groupoid of S¹ (formalized as `Metric.sphere (0 : ℝ²) 1`) by endpoint-fixed homotopy has morphism sets isomorphic to ℤ — i.e., the fundamental groupoid of the circle has the expected structure.

**Test:** Formalize `Path.Homotopic.Quotient` for S¹ using Mathlib's existing `FundamentalGroupoid`. Show that the automorphism group at any basepoint is isomorphic to ℤ by constructing explicit winding-number homomorphisms in both directions.

**Impact:** This would connect our path groupoid infrastructure to a concrete topological invariant, demonstrating that the formal machinery recovers classical algebraic topology.

**Catalog References:** `Pythagorean/KanComposition/PathGroupoid.lean` (WeakPathGroupoid, EndpointFixedHomotopy).

**Proof Strategy:** Use Mathlib's `FundamentalGroupoid` and its `CategoryTheory.Groupoid` instance. The key is to construct the winding number as a groupoid functor to the groupoid of ℤ (with one object), which requires showing that the winding number is additive under path composition and invariant under homotopy.

**Domain Bridges:** Algebraic topology (π₁(S¹) ≅ ℤ), physics (Aharonov-Bohm effect, magnetic flux quantization), robotics (winding number for planar path classification).

**Lineage:** Extends `WeakPathGroupoid.canonical` to a quotient construction.

**Ambition:** Grand challenge — requires significant development of winding number theory.

---

## Direction 5: Verified Parallel Transport for Vector Bundles

**Conjecture:** For a trivial vector bundle `E = X × ℝⁿ → X` with a connection given by a continuous family of linear maps, parallel transport along a composed path `p · q` equals the composition of transports along `p` and `q`, formalized as a strict equality of linear maps.

**Test:** Formalize trivial vector bundles and connections in Lean 4. Define parallel transport as the solution of the transport equation (for piecewise-constant connections, this is a finite product of matrices). Prove that `transport(p · q) = transport(q) ∘ transport(p)` using the piecewise structure of concatenation.

**Impact:** This bridges the formal path groupoid to differential geometry and gauge theory, providing machine-verified parallel transport composition.

**Catalog References:** `Pythagorean/KanComposition/PathGroupoid.lean` (map_comp_eq, transport_comp_eq).

**Proof Strategy:** For piecewise-constant connections, transport is a product of exponentials of connection matrices. Path concatenation doubles the number of matrix factors but preserves their product. The proof reduces to associativity of matrix multiplication.

**Domain Bridges:** Differential geometry (parallel transport, holonomy), physics (gauge theory, Berry phase), numerical analysis (geometric integrators).

**Lineage:** Extends `transport_comp_eq` from propositional equality transport to geometric transport.

**Ambition:** Solid extension — feasible with Mathlib's linear algebra and matrix library.
