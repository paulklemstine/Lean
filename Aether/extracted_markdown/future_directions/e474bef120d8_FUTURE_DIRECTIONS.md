# Future Directions: Exceptional Expander Engineering

## Synthesis

The character-ratio certificate framework established here creates a modular interface between representation theory and combinatorial expansion. The five directions below form a coherent research program: Direction 1 extends the G₂ result to all exceptional types via the same bounded-toral-complexity mechanism. Direction 2 deepens the formal foundations by constructing Deligne–Lusztig theory in Lean. Direction 3 exploits the unique spectral properties of exceptional Cayley graphs for coding theory. Direction 4 bridges to mathematical physics through symmetry-driven equilibration. Direction 5 pursues the grand challenge of a unified certificate calculus for all reductive groups.

Together, these directions define the nascent field of **exceptional expander engineering**: the systematic construction, certification, and application of expander families from exceptional algebraic groups.

---

## Direction 1: The Full Exceptional Ladder — F₄, E₆, E₇, E₈ Certificates

**Conjecture.** For each exceptional group type X ∈ {F₄, E₆, E₇, E₈}, there exists a constant C_X > 0 such that for every good prime power q:
  max_{χ≠1, s regular toral} |χ(s)/χ(1)| ≤ C_X / q

**Test.** Compute character ratios for F₄(𝔽_q) at q = 2, 3, 4, 5 using the character tables of Lübeck and Malle. Verify that M(q) = q · max ratio remains bounded. The toral complexity constants are: F₄: 25 types, E₆: 25 types, E₇: 60 types, E₈: 112 types.

**Impact.** This would produce 5 new families of explicit expanders with potentially extremal spectral properties. The E₈ family, with |E₈(𝔽_q)| = q^{120} · ∏(q^i - 1), would give expanders on astronomically large groups with just 112 torus types controlling the entire spectrum.

**Catalog References.** `Pythagorean/G2CharacterSheafCertificate.lean` (bounded_toral_complexity, uniform_expansion_of_certified_family)

**Proof Strategy.** Apply the same certificate architecture with larger T. The key lemma `bounded_toral_complexity` already handles arbitrary finite T. The challenge is computing per-torus-type constants from Deligne–Lusztig theory for each exceptional type. For F₄, use the character tables of Shinoda (1975) and Lübeck (2008).

**Domain Bridges.** Spectral graph theory (new expander families), coding theory (new graph codes with E₈ symmetry), computational group theory (character table verification)

**Lineage.** Direct extension of the G₂ certificate framework

**Ambition.** Solid extension — the framework is in place, the data exists, the formalization is routine

**The key insight is** that all exceptional groups share bounded toral complexity, so the certificate mechanism transfers without architectural changes — only the constants change.

**Why now?** The Lübeck character tables for all exceptional groups are now computationally accessible, and our certificate framework provides the first systematic way to consume this data for expansion proofs.

---

## Direction 2: Formal Deligne–Lusztig Theory in Lean 4

**Conjecture.** The core constructions of Deligne–Lusztig theory — ℓ-adic cohomology of Deligne–Lusztig varieties, the character formula R_T^G(θ), and Green function evaluations — can be formalized sufficiently to produce computable character values for G₂(𝔽_q) within Lean 4 + Mathlib.

**Test.** Formalize the Deligne–Lusztig character formula for G₂ restricted to regular semisimple elements, where the formula simplifies dramatically: R_T^G(θ)(s) = Σ_{g: g⁻¹sg ∈ T} θ(g⁻¹sg) for regular s. Verify that this yields the correct character ratios at q = 3.

**Impact.** This would be the first formal verification of Deligne–Lusztig character values, closing the gap between the abstract certificate framework and concrete group-theoretic input. It would make the expansion results fully self-contained.

**Catalog References.** `Pythagorean/G2CharacterSheafCertificate.lean` (mkCertificateFromData, computeCertificateBound_correct)

**Proof Strategy.** Start with the simplified formula for regular elements, avoiding the full generality of ℓ-adic cohomology. Define G₂(𝔽_q) as 7×7 matrices preserving a trilinear form (the octonion structure constants). Enumerate maximal tori via the classification. Compute R_T^G(θ) by direct summation.

**Domain Bridges.** Algebraic geometry (ℓ-adic cohomology), number theory (Weil conjectures for DL varieties), computer algebra (verified computation)

**Lineage.** Fills the input side of the certificate pipeline

**Ambition.** Grand challenge — formalizing even the simplified DL formula requires substantial algebraic geometry infrastructure

**The key insight is** that for regular semisimple elements, the Deligne–Lusztig character formula reduces to a combinatorial sum over cosets, avoiding the full cohomological machinery.

**Why now?** Mathlib's algebraic geometry library has matured to the point where finite field algebraic varieties are representable, and the group-theoretic prerequisites (reductive groups, maximal tori, Weyl groups) are increasingly available.

---

## Direction 3: Exceptional Expander Codes with Provable Distance

**Conjecture.** Graph codes constructed from Cayley graphs of G₂(𝔽_q) achieve a distance-rate tradeoff qualitatively distinct from codes based on classical group expanders, due to the specific spectral gap profile of G₂.

**Test.** Construct the bipartite double cover of Cay(G₂(𝔽_7), S) for an explicit conjugacy-stable S, define the associated Tanner code, and compute its minimum distance lower bound from the certified Cheeger constant. Compare with Sp₄(𝔽_7) codes of comparable size.

**Impact.** New families of LDPC codes with guaranteed minimum distance, constructible from character tables. The G₂ root system's hexagonal structure may induce favorable cycle structures in the Tanner graph, improving iterative decoding performance.

**Catalog References.** `Pythagorean/G2CharacterSheafCertificate.lean` (certificate_to_code_distance, certificate_cheeger_pos)

**Proof Strategy.** Use the Sipser–Spielman bound: distance ≥ δ₀ · (Cheeger / 2d) · n where δ₀ is the inner code distance, d is the graph degree, and n is the block length. Instantiate with certified Cheeger bounds from our pipeline.

**Domain Bridges.** Coding theory (LDPC, Tanner codes), information theory (channel capacity), telecommunications (5G/6G code design)

**Lineage.** Extends certificate_to_code_distance to concrete code constructions

**Ambition.** Solid extension — the mathematical framework is complete, implementation requires engineering

**The key insight is** that the specific structure of exceptional root systems (short and long roots, non-simply-laced Dynkin diagrams) may produce Cayley graphs with unusual girth and cycle structure, giving coding-theoretic advantages not available from classical groups.

**Why now?** The demand for new LDPC code families is driven by 5G/6G standards, and our certified pipeline provides the first rigorous distance guarantees for exceptional-group-based codes.

---

## Direction 4: Symmetry-Driven Equilibration and Exceptional Statistical Mechanics

**Conjecture.** The spectral gap of the random walk on Cay(G₂(𝔽_q), S) controls not only L² mixing but also the rate of entropy production, KL divergence decay, and log-Sobolev constants, giving a complete quantitative picture of equilibration.

**Test.** Prove that the certified spectral gap implies a modified log-Sobolev inequality with constant proportional to 1/log(1/(1-gap)). Compute the resulting entropy contraction rate for G₂(𝔽_7) and compare with the L² mixing time.

**Impact.** This would connect exceptional group expansion to statistical mechanics and quantum information theory. The finite-group setting provides exact, non-asymptotic bounds, making it a testing ground for general equilibration conjectures.

**Catalog References.** `Pythagorean/G2CharacterSheafCertificate.lean` (l2_mixing_time_bound, walk_error_geometric_bound, ds_majorant_monotone)

**Proof Strategy.** Use the Diaconis–Saloff-Coste comparison technique: for reversible Markov chains on groups, the spectral gap controls the log-Sobolev constant up to logarithmic factors. Formalize the comparison inequality and instantiate with certificate bounds. The key lemma is: if the spectral gap is 1 - α, then the modified log-Sobolev constant is ≥ (1-α)/(2 log(1/α)).

**Domain Bridges.** Mathematical physics (equilibration, thermalization), quantum information (quantum expanders, mixing of quantum channels), probability theory (functional inequalities)

**Lineage.** Extends the mixing bridge from L² to entropy-theoretic quantities

**Ambition.** Grand challenge — the log-Sobolev formalization requires substantial probability theory infrastructure

**The key insight is** that exceptional group symmetry provides the strongest possible symmetry-driven equilibration, where the representation-theoretic spectral gap directly controls all measures of convergence to equilibrium.

**Why now?** The recent formalization of basic probability theory in Mathlib, combined with growing interest in quantum expanders (where finite-group Cayley graphs serve as classical models), makes this the right moment to bridge representation theory and statistical mechanics.

---

## Direction 5: Universal Certificate Calculus for Reductive Groups

**Conjecture.** There exists a compositional certificate calculus — with operations for parabolic induction, restriction, tensor product, and Harish-Chandra induction — that can systematically produce certificates for any reductive group over a finite field from certificates for its Levi factors.

**Test.** Formalize parabolic induction of certificates: given a certificate for a Levi factor L ⊂ P ⊂ G, produce a certificate for G. Test on G = GL₃(𝔽_q) with L = GL₁ × GL₂.

**Impact.** This would transform the certificate framework from a tool for individual groups into a compositional algebra. Certificates for small groups would automatically yield certificates for large groups, creating an inductive proof of expansion for all split reductive groups.

**Catalog References.** `Pythagorean/G2CharacterSheafCertificate.lean` (CharacterRatioCertificate.compose, CharacterRatioCertificate.refine, bounded_toral_complexity)

**Proof Strategy.** The key is the Mackey formula for character values of parabolically induced representations. If χ = Ind_P^G(σ), then χ(s)/χ(1) can be bounded in terms of σ-ratios and the geometry of the flag variety G/P. Formalize this bound and show it preserves the C/q form with a controlled increase in C.

**Domain Bridges.** Automorphic forms (Langlands functoriality), algebraic K-theory (higher algebraic K-groups of finite fields), computational algebra (algorithmic representation theory)

**Lineage.** The culmination of the certificate program — from individual groups to a universal framework

**Ambition.** Grand challenge — this is a multi-year research program requiring deep representation theory

**The key insight is** that the certificate structure (q, C, α) is stable under the natural operations of representation theory (induction, restriction, tensor), so certificates compose algebraically — they form a semiring-like structure.

**Why now?** The certificate framework provides the first formal interface that can absorb the output of representation-theoretic operations. The compositional structure of certificates mirrors the compositional structure of reductive groups, suggesting that the right algebraic framework exists.
