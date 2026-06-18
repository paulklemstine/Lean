# Future Directions: Tropical Brill–Noether Theory

## 1. Full Tropical Riemann-Roch Theorem

Formalize Baker–Norine's tropical Riemann-Roch theorem: for a divisor D on a metric graph Γ of genus g, r(D) − r(K − D) = deg(D) − g + 1 where K is the canonical divisor of degree 2g−2. The key insight is that our `chipFiring_degree_invariant` and `Divisor` infrastructure already provides the chip-firing foundation — the remaining challenge is formalizing q-reduced divisors and the Dhar burning algorithm as a certified decision procedure for rank computation. Why now? The existing `chipFire`/`Divisor.degree` formalization handles the low-level graph combinatorics, and the Serre duality `rho_serre_duality` already captures the expected dimension identity at the BN-number level.

## 2. CDPR Lattice Path Characterization with Genericity

Extend the allocation/tableau equivalence to a full lattice-path characterization on metric chains of loops with generic edge lengths. The key insight is that our `CDPRAllocation` structure exactly encodes the endpoint of a Weyl-chamber walk, and the generic-edge-length condition (formalized as `MetricChainOfLoops.IsGeneric` in `Defs.lean`) should ensure a bijection between rank-r divisors and lattice paths staying in the Weyl chamber. Why now? Both the allocation existence theorem (`allocation_iff_rho_nonneg`) and the Weyl chamber machinery (`InWeylChamber`, `initialState_inWeylChamber`) are fully formalized, so the missing piece is the geometric injection from divisor classes to lattice paths.

## 3. Tropical Abel-Jacobi and Jacobian Structure

Formalize the tropical Jacobian J(Γ) = ℝ^g / Λ as a real torus and prove the Abel-Jacobi theorem: the chip-firing equivalence classes of degree-0 divisors on Γ form a group isomorphic to J(Γ). The key insight is that `chipFiring_degree_invariant` proves the degree is well-defined on equivalence classes, and the quotient ℝ^g/Λ structure should follow from the cycle space of the graph. Why now? The chip-firing formalization is complete and degree-invariant, providing the algebraic foundation; the Jacobian construction requires only the lattice quotient machinery already available in Mathlib (`AddCircle`, `ZSpan`).

## 4. Effective Brill-Noether via Displacement Tableaux Counting

Prove that the number of CDPR displacement tableaux of shape (r+1) × (g−d+r) with entries in {0,...,g−1} equals the number of standard Young tableaux of the corresponding shape, establishing a bijection with the Robinson-Schensted correspondence. The key insight is that `displacementTableau_exists_iff` reduces existence to a cardinality bound, but the exact count should match the hook-length formula — connecting tropical geometry to enumerative combinatorics. Why now? The tableau infrastructure (`DisplacementTableau`, row-strictness, injectivity) is complete, and Mathlib's `Fintype.card` machinery can support explicit counting arguments.

## 5. Specialization to Algebraic Geometry via Berkovich Analytification

Strengthen the `SpecializationDatum` interface to capture the full content of Baker's specialization lemma: for a smooth proper curve X over a discretely-valued field with stable reduction, the tropicalization map trop: Div(X) → Div(Γ) satisfies rank(trop(D)) ≥ rank(D). The key insight is that the abstract interface already proves `specialization_preserves_existence`, but a concrete instantiation using Berkovich skeleta would give a machine-verified bridge between algebraic and tropical Brill-Noether theory. Why now? The abstract interface is proven and ready for instantiation; the main barrier is formalizing enough valuation theory and stable reduction to construct the concrete specialization map.
