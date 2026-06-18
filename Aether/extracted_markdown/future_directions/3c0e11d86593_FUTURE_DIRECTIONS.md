# Future Directions: Discriminant Uniformity and Stochastic Galois Theory

## Synthesis

This research cycle established three tightly connected results about monic quadratic polynomials over 𝔽_p. The **Discriminant Fiber Uniformity Theorem** proves that the map (b,c) ↦ b² − 4c has perfectly uniform fibers of size p for any odd prime p, reducing polynomial counting to discriminant-value counting. Using this engine together with classical quadratic residue counts ((p−1)/2 nonzero squares, (p−1)/2 non-squares, and 1 zero), we derived the **Splitting Type Partition** (p(p−1)/2 split + p ramified + p(p−1)/2 inert = p²) and the **Split–Inert Symmetry** (equal counts of split and inert quadratics). We also connected the degree-2 splitting types to Frobenius permutation cycle types via the **Fixed-Point Dichotomy** for permutations of Fin 2.

The most promising cross-domain connection is between the *fiber uniformity framework* introduced here and *algebraic geometry's flatness theory*. Our `FiberUniformMap` structure — a function with constant fiber cardinality — is the finite combinatorial analogue of a flat finite morphism of schemes. Extending this to higher-degree polynomial maps could yield new computational and theoretical tools at the intersection of algebraic geometry, combinatorics, and number theory. The existing Catalog entries in `Algebra/StochasticGalois.lean` (quadratic formula, Schwartz-Zippel, root fiber counting) provide immediate foundations, while the `Bridges/` domain offers potential for connecting these algebraic results to computational and physical applications.

The highest breakthrough potential lies in Direction 1 (Cubic Splitting), because formalizing the cubic case would be the first machine-verified instance of the polynomial-to-permutation dictionary beyond degree 2, and our cubic fiber uniformity conjecture provides a precise, falsifiable target. Direction 3 (Fiber Uniformity for Polynomial Maps) has the greatest foundational value, as it would establish a general-purpose counting tool applicable across multiple research domains.

---

### Direction 1: Cubic Splitting Types via Fiber Uniformity

**Conjecture**: For an odd prime p ≡ 2 (mod 3), the cubic discriminant map Δ(b,c,d) = 18bcd − 4b³d + b²c² − 4c³ − 27d² from 𝔽_p³ to 𝔽_p has uniform fibers of size p². For p ≡ 1 (mod 3), the fibers are non-uniform.

**Test**: Enumerate all p³ triples (b,c,d) for p = 5, 7, 11, 13. Compute Δ and record fiber sizes. For p = 5 and p = 11, all fiber sizes should equal p². For p = 7 and p = 13, at least two distinct fiber sizes should appear. This is fully computational and can be done in < 1 second per prime.

**Impact**: If true, this would extend the fiber uniformity framework to degree 3 and enable exact formulas for cubic splitting type counts. The splitting types of a cubic correspond to partitions of 3 — there are three types (3, 2+1, 1+1+1) — and their counts would follow from counting discriminant values by cubic residue class. This would be the first formalized cubic splitting census.

**Catalog References**: `Catalog/Algebra/StochasticGalois.lean` (SplittingProfile, quadratic_has_root_iff_disc_square), `Algebra/DiscriminantUniformity.lean` (disc_fiber_card, FiberUniformMap)

**Proof Strategy**: 
1. Prove that when p ≡ 2 (mod 3), the Tschirnhaus substitution x ↦ x − b/3 is equivalent to the identity on discriminant fibers (since 3 is invertible).
2. For the depressed cubic x³ + px + q, prove that Δ = −4p³ − 27q² has uniform fibers by showing that for each p-value, q is uniquely determined (analogous to the quadratic argument).
3. Establish the cubic residue counting: #{nonzero cubes} = (p−1)/gcd(3, p−1), which simplifies to (p−1) when p ≡ 2 (mod 3).

**Domain Bridges**: Algebra (quadratic residues) ↔ Computation (polynomial classification algorithms) ↔ Cryptography (irreducibility testing for field extensions)

**Lineage**: Builds on disc_fiber_card and the FiberUniformMap framework from this cycle. Extends the SplittingProfile structure from StochasticGalois.lean to degree 3.

**Ambition**: grand_challenge

---

### Direction 2: Chebotarev Density for Degree 2 (Full Formalization)

**Conjecture**: For any odd prime p, the fraction of monic quadratics over 𝔽_p whose splitting type corresponds to a given cycle type λ ∈ S₂ equals |C_λ|/2! + O(1/p), where C_λ is the conjugacy class of λ. Specifically: P(split) = P(inert) = 1/2 − 1/(2p) and P(ramified) = 1/p.

**Test**: Compute the exact fractions for p = 3, 5, 7, ..., 97 and verify they match (p−1)/(2p) for split/inert and 1/p for ramified. Then formalize the limit statement in Lean using Filter.Tendsto.

**Impact**: This would be the first machine-verified instance of the Chebotarev density theorem, albeit in the simplest function-field case. The formalization would establish the template for proving density results for higher-degree polynomials.

**Catalog References**: `Catalog/Algebra/StochasticGalois.lean` (irreducible_quadratic_density_limit), `Algebra/DiscriminantUniformity.lean` (split_card_eq_inert_card, splitting_partition)

**Proof Strategy**:
1. Use split_card_eq_inert_card to get the exact count p(p−1)/2.
2. Express the fraction as p(p−1)/2 / p² = (p−1)/(2p).
3. Prove (p−1)/(2p) → 1/2 using Filter.Tendsto (already done for ℚ in StochasticGalois.lean; extend to ℝ).

**Domain Bridges**: Algebra (splitting types) ↔ Analysis (asymptotic density) ↔ Probability (random permutation statistics)

**Lineage**: Directly extends splitting_partition and split_card_eq_inert_card. Connects to irreducible_quadratic_density_limit in StochasticGalois.lean.

**Ambition**: extension

---

### Direction 3: General Fiber Uniformity for Polynomial Maps

**Conjecture**: A polynomial map F : 𝔽_q^n → 𝔽_q^m (with n > m) has uniform fibers of size q^(n−m) if and only if for every affine subspace L of dimension m in 𝔽_q^n, the restriction F|_L is a bijection onto 𝔽_q^m. (This generalizes the quadratic case where F(b,c) = b² − 4c and the "affine subspace" is the line {(b, c₀ + tb) : t ∈ 𝔽_q} for fixed c₀.)

**Test**: For the discriminant map Δ(b,c) = b² − 4c, verify the affine-subspace characterization for p = 3, 5, 7. For each affine line in 𝔽_p², check that the restriction of Δ is a bijection onto 𝔽_p. Then test whether the same characterization holds for the cubic discriminant map.

**Impact**: A general criterion for fiber uniformity would be a powerful tool for counting arguments across algebra, combinatorics, and coding theory. It would subsume our discriminant result as a special case and potentially explain *why* certain polynomial maps have uniform fibers while others don't.

**Catalog References**: `Algebra/DiscriminantUniformity.lean` (FiberUniformMap, card_domain, card_preimage)

**Proof Strategy**:
1. Formalize affine subspaces of 𝔽_q^n as `AffineSubspace (ZMod q) (Fin n → ZMod q)`.
2. Prove one direction: if F has uniform fibers, then the restriction to any m-dimensional affine subspace transversal to the fibers is a bijection.
3. Investigate the converse: does bijectivity on all transversal affine subspaces imply fiber uniformity?

**Domain Bridges**: Algebra (polynomial maps) ↔ Geometry (affine subspaces, algebraic varieties) ↔ Computation (coding theory, hash functions)

**Lineage**: Generalizes FiberUniformMap from this cycle. Would provide a general-purpose tool for the entire Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Quadratic Splitting over Number Fields

**Conjecture**: For a number field K of degree n over ℚ and a prime p that splits completely in K, the splitting type distribution of monic quadratics over the residue field 𝔽_p matches the degree-2 case: p(p−1)/2 split, p ramified, p(p−1)/2 inert.

**Test**: For K = ℚ(√5) and primes p that split completely (p ≡ ±1 mod 5), verify that the splitting statistics over 𝔽_p match our formulas. Compare with primes that are inert in K.

**Impact**: This would connect the finite-field splitting statistics to arithmetic geometry over number fields, bridging the function-field and number-field sides of the Langlands program.

**Catalog References**: `Algebra/DiscriminantUniformity.lean` (disc_fiber_card, splitting_partition), `Catalog/Algebra/CyclotomicGaloisGroup.lean` (prime_cyclotomic_galois_group_cyclic)

**Proof Strategy**:
1. For a prime p splitting completely in K, the residue field is 𝔽_p, and our existing results apply directly.
2. For primes inert in K, the residue field is 𝔽_{p²}, requiring a generalization of disc_fiber_card to general finite fields.
3. State and prove the generalized version: for any finite field 𝔽_q with q odd, the discriminant fiber has size q.

**Domain Bridges**: Algebra (finite fields) ↔ Number Theory (splitting of primes) ↔ Algebraic Geometry (residue fields)

**Lineage**: Extends disc_fiber_card from ZMod p to general finite fields. Connects to CyclotomicGaloisGroup.lean via Galois theory.

**Ambition**: extension

---

### Direction 5: Computational Verification of Cubic Conjecture

**Conjecture**: For p = 5 (≡ 2 mod 3), all 5 fibers of the cubic discriminant map Δ : 𝔽_5³ → 𝔽_5 have exactly 25 elements. For p = 7 (≡ 1 mod 3), the fiber sizes are non-uniform.

**Test**: Complete enumeration: for each of the 125 triples (b,c,d) ∈ 𝔽_5³, compute Δ(b,c,d) = 18bcd − 4b³d + b²c² − 4c³ − 27d² mod 5 and record fiber sizes. Similarly for the 343 triples over 𝔽_7.

**Impact**: A positive result for p = 5 and negative for p = 7 would provide strong evidence for the cubic fiber uniformity conjecture (Direction 1). A negative result for p = 5 would refute the conjecture and require rethinking the mod-3 obstruction theory.

**Catalog References**: `Algebra/DiscriminantUniformity.lean` (disc_fiber_card as the degree-2 template)

**Proof Strategy**: Pure computation. Implement the cubic discriminant in Python (or Lean via `#eval`) and enumerate. This is the experimental validation step before attempting a formal proof.

**Domain Bridges**: Algebra (discriminants) ↔ Computation (exhaustive enumeration) ↔ Number Theory (cubic residues)

**Lineage**: Provides experimental data for Direction 1. Validates or refutes the cubic fiber uniformity conjecture.

**Ambition**: extension
