# Future Directions: Low-Dimensional Homotopy Theory via Formal Methods

## Synthesis

This work establishes the first formally verified computation of an unstable homotopy group of spheres (π₃(S²) ≅ ℤ) through the Hopf fibration. The development creates three reusable pieces: (1) an algebraic exactness engine that extracts isomorphisms from exact sequences with vanishing ends, (2) a low-dimensional fibration data structure that axiomatizes the minimal LES fragment needed for computation, and (3) coordinate-verified models connecting the Hopf map to SU(2) quotients. These pieces form a platform for extending formal unstable homotopy theory in several directions: completing the fully formal proof by formalizing the LES of fibrations and degree theory, extending to higher Hopf fibrations (quaternionic, octonionic), computing more homotopy groups via Postnikov tower techniques, and bridging to formal gauge theory and topological quantum computation. The directions below are ordered from most immediately achievable to most ambitious, and each builds on the specific infrastructure established here.

---

## Direction 1: Formalize the Long Exact Sequence of a Serre Fibration

**Conjecture:** The long exact sequence of a Serre fibration p: E → B with fiber F can be formally constructed in Lean 4 using Mathlib's existing homotopy group infrastructure (`HomotopyGroup`, `GenLoop`), yielding connecting homomorphisms and exactness proofs at each term through dimension n for any finite n.

**Test:** Construct the connecting homomorphism ∂: π_{n+1}(B) → πₙ(F) for n = 2, instantiate for the Hopf fibration, and verify that composing with the formalized algebraic engine (`equiv_int_from_exact_sequence`) produces π₃(S²) ≅ ℤ with zero axiomatic inputs beyond Mathlib. Success = all `sorry` eliminated; failure = identification of specific Mathlib gaps that block the construction.

**Impact:** This would complete the fully formal proof and create infrastructure for *any* fibration computation. It would be the single most impactful extension of this work.

**Catalog References:** `Geometry/HopfFibration/Algebra.lean` (the algebraic engine that consumes LES data), `Geometry/HopfFibration/HopfMap.lean` (the `LowDimFibrationData` structure to be instantiated).

**Proof Strategy:** Define the connecting homomorphism using the lifting property of Serre fibrations. The key technical challenge is constructing the boundary map ∂ on the quotient `HomotopyGroup` from a representative `GenLoop`. Use Mathlib's `ContinuousMap.HomotopyWith` for relative homotopy lifting. Prove exactness at each term by constructing explicit homotopies.

**Domain Bridges:** Algebraic topology ↔ formal methods. Would connect to formal homological algebra developments in Lean/Mathlib.

**Lineage:** Direct successor to this project's `LowDimFibrationData` and `equiv_int_from_exact_sequence`.

**Ambition:** High — requires significant new infrastructure but follows a well-understood mathematical blueprint.

---

## Direction 2: Quaternionic Hopf Fibration and π₇(S⁴)

**Conjecture:** The `LowDimFibrationData` structure, with appropriate dimensional generalization to a `FibrationLESSegment n` structure, can compute π₇(S⁴) ≅ ℤ ⊕ ℤ/12ℤ from the quaternionic Hopf fibration S³ → S⁷ → S⁴ combined with known values π₇(S³) ≅ ℤ/2ℤ, π₆(S³) ≅ ℤ/12ℤ, etc.

**Test:** Define the quaternionic Hopf map in coordinates (ℝ⁸ → ℝ⁵), verify it preserves the sphere (analogous to `hopfMapCoords_preserves_sphere`), prove S³-equivariance (analogous to S¹-equivariance). Then generalize `LowDimFibrationData` to handle the longer exact sequence segment needed, instantiate it, and derive π₇(S⁴). Success = formally verified computation; failure = identification of which additional input homotopy groups are needed.

**Impact:** Would demonstrate that the framework scales beyond the simplest case and can handle torsion phenomena (ℤ/12ℤ), not just free abelian groups.

**Catalog References:** `Geometry/HopfFibration/HopfMap.lean` (the pattern for sphere-preservation proofs and fibration data structures), `Geometry/HopfFibration/Algebra.lean` (the exact sequence machinery to be generalized for non-trivial kernel/cokernel computations).

**Proof Strategy:** The quaternionic Hopf map sends (q₁, q₂) ∈ S⁷ ⊂ ℍ² to [q₁ : q₂] ∈ ℍP¹ ≅ S⁴. In coordinates, this is a polynomial map ℝ⁸ → ℝ⁵. The algebraic engine needs extension to handle exact sequences with non-trivial terms, computing the middle group via short exact sequence splitting or extension classification.

**Domain Bridges:** Quaternion algebra ↔ topology ↔ 4-manifold theory (S⁴ is key in 4-dimensional topology).

**Lineage:** Direct generalization of the Hopf map construction and fibration data approach from this project.

**Ambition:** Medium-high — the map construction is straightforward, but the exact sequence analysis requires handling group extensions.

---

## Direction 3: Formal Degree Theory and πₙ(Sⁿ) ≅ ℤ

**Conjecture:** The degree of a continuous map f: Sⁿ → Sⁿ can be formally defined in Lean 4 (via homology or via the Brouwer fixed-point theorem machinery that exists in Mathlib), and the resulting map deg: [Sⁿ, Sⁿ] → ℤ can be proved to be an isomorphism, establishing πₙ(Sⁿ) ≅ ℤ for all n ≥ 1.

**Test:** Define `degree n : HomotopyGroup (Fin n) (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n+1))) 1) pt → ℤ` using singular homology or a combinatorial model. Prove it is a group isomorphism for n = 1 (winding number), n = 2 (degree of a map S² → S²), and n = 3 (the input to the Hopf computation). Success = `#print axioms degree_iso` shows only standard axioms.

**Impact:** Would eliminate the most significant remaining axiomatic input to the π₃(S²) computation, specifically the hypothesis π₃(S³) ≅ ℤ.

**Catalog References:** `Geometry/HopfFibration/HopfMap.lean` (needs π₃(S³) ≅ ℤ as input), Mathlib's `Brouwer.*` modules.

**Proof Strategy:** Use the Hurewicz theorem (πₙ(Sⁿ) ≅ Hₙ(Sⁿ)) combined with the computation Hₙ(Sⁿ) ≅ ℤ via CW homology or singular homology. Alternatively, define degree directly via local degree at regular values and prove it classifies maps up to homotopy.

**Domain Bridges:** Homotopy theory ↔ homology theory ↔ differential topology.

**Lineage:** This would close the logical gap in the current development and provide the missing input.

**Ambition:** High — requires substantial homological machinery, though the mathematical path is well-established.

---

## Direction 4 (Grand Challenge): Formal Computation of π₄(S³) ≅ ℤ/2ℤ

**Conjecture:** The EHP (James) exact sequence, formalized in Lean 4 using our fibration data approach, combined with the Freudenthal suspension theorem and the known value π₃(S²) ≅ ℤ (established in this project), can derive π₄(S³) ≅ ℤ/2ℤ.

**Test:** Define a `SuspensionFibrationData` structure encoding the James fibration ΩSⁿ⁺¹ → ΩJSⁿ → Sⁿ (or a simplified low-dimensional analogue). Instantiate for n = 2 to obtain a sequence involving π₄(S³), π₃(S²), and π₃(S³). Derive π₄(S³) ≅ ℤ/2ℤ using the algebraic engine. Success = fully formal proof; failure = identification of which part of the EHP sequence cannot be axiomatized cleanly.

**Impact:** This would be the first formal computation of a *torsion* homotopy group of a sphere, demonstrating that the framework handles the full complexity of unstable homotopy theory. It would be a landmark result in formal algebraic topology.

**Catalog References:** `Geometry/HopfFibration/Algebra.lean` (the exactness engine needs extension to handle ℤ/2ℤ), `Geometry/HopfFibration/HopfMap.lean` (π₃(S²) ≅ ℤ is a key input).

**Proof Strategy:** The EHP sequence gives:
  π₄(S³) → π₃(S²) →[E] π₄(S³) → π₃(S²) →[H] π₃(S¹)
The Freudenthal suspension theorem gives that E: π₃(S²) → π₄(S³) is surjective (since 3 < 2·2 - 1). The Hopf invariant map H sends the generator of π₃(S²) to a generator of ℤ, and the EHP sequence shows ker(H) = im(E), so im(E) = 2ℤ... Actually, the correct computation uses the fact that the suspension of the Hopf map has order 2 in π₄(S³).

**Domain Bridges:** Unstable homotopy theory ↔ stable homotopy theory (via suspension) ↔ K-theory (via Adams' work on Hopf invariant one).

**Lineage:** Builds directly on π₃(S²) ≅ ℤ and the fibration data approach.

**Ambition:** Very high — this would match Brunerie's HoTT result but in classical Lean 4.

---

## Direction 5 (Grand Challenge): Cohomological Hopf Invariant and Cup Products

**Conjecture:** The Hopf invariant can be formally defined via the cup product structure on H*(Cη; ℤ) where Cη is the mapping cone of η: S³ → S², and this definition can be proved equivalent to the linking number definition, establishing a formal bridge between homotopy theory and cohomology operations.

**Test:** Define the mapping cone Cη in Lean, compute its cohomology ring H*(Cη; ℤ), define the Hopf invariant as the coefficient in α² = H(η)·β where α ∈ H²(Cη) and β ∈ H⁴(Cη) are generators, and prove H(η) = 1 for the standard Hopf map. Then prove equivalence with the linking number definition. Success = formal proof that both definitions agree; failure = identification of missing cohomology infrastructure.

**Impact:** Would establish the first formal bridge between homotopy operations and cohomology operations in Lean, opening the door to Steenrod operations, Adams spectral sequence computations, and formal stable homotopy theory.

**Catalog References:** `Geometry/HopfFibration/HopfMap.lean` (the `HopfInvariantData` structure to be connected to cohomology).

**Proof Strategy:** Use singular cohomology with ℤ coefficients. The mapping cone Cη has the CW structure of S² ∪η e⁴. Compute H²(Cη) ≅ ℤ ≅ H⁴(Cη) and H^k(Cη) = 0 otherwise. The cup product α ∪ α ∈ H⁴ is determined by H(η) ∈ ℤ. Use the Thom isomorphism or direct CW computation.

**Domain Bridges:** Homotopy theory ↔ cohomology theory ↔ stable homotopy ↔ K-theory.

**Lineage:** Connects the geometric (linking) and algebraic (cup product) perspectives on the Hopf invariant.

**Ambition:** Paradigm-shifting — would open formal access to the entire machinery of cohomology operations.
