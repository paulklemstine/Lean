# Future Directions: Lorentzian Proof Complexity

## Synthesis

The establishment of a formal, size-preserving bridge between resolution derivations and Lorentzian certificate trees opens a two-way highway between proof complexity and algebraic positivity. The five directions below exploit this bridge in complementary ways: Direction 1 deepens the semantic content of the bridge; Direction 2 extends it to stronger proof systems; Direction 3 imports the width method — the most powerful tool in resolution lower bounds — into the geometric setting; Direction 4 connects certificate complexity to matroid Hodge theory; and Direction 5 poses the grand challenge of proving entirely new lower bounds using geometric techniques. Together, they constitute a research program that could transform both proof complexity and the complexity theory of algebraic positivity.

---

## Direction 1: Semantic Simulation and Satisfiability Preservation

**Conjecture:** The resolution-to-certificate translation preserves logical content: if the resolution derivation is a valid refutation (derives the empty clause), then the certificate tree's leaf multiindices encode a set of derivative evaluations whose joint failure certifies non-Lorentzianity.

**Test:** Formalize the notion of "valid Lorentzian non-certification" for a certificate tree and prove that `resolutionToCertificate` maps valid refutations to valid non-certifications. Test computationally on PHP(n+1,n) for n ≤ 8 by checking that translated certificate trees have leaves with genuinely forbidden Hessian signatures.

**Impact:** Upgrades the correspondence from a syntactic (structural) equivalence to a semantic one. This would establish that Lorentzian certificate trees are not just combinatorially similar to resolution proofs — they ARE resolution proofs in algebraic disguise.

**Catalog References:**
- `Catalog/Bridges/LorentzianRecognition.lean` — `IsRecursivelyLorentzian`, `HasAtMostOnePositiveEigenvalue`
- `Catalog/Pythagorean/LorentzianHardness.lean` — `boolean_assignment_multiindex_lower_bound`
- `Catalog/Pythagorean/LorentzianProofComplexity.lean` — `complementary_multiindex_inconsistent`

**Proof Strategy:** Define a "validity predicate" for certificate trees by requiring that each leaf multiindex corresponds to a partial derivative with a forbidden Hessian signature. Prove by induction on the resolution derivation that each resolution step preserves the validity predicate under translation.

**Domain Bridges:** Algebraic geometry ↔ propositional logic; spectral theory ↔ satisfiability

**Lineage:** Extends `simulation_size_exact` and `complementary_multiindex_inconsistent` from syntactic to semantic content.

**Ambition:** Solid extension — foundational but achievable with current infrastructure.

---

## Direction 2: Extension to Dag-Like Resolution and Shared Certificates

**Conjecture:** The bridge extends to dag-like resolution (where sub-derivations may be reused) and shared certificate trees (where sub-trees may be referenced multiple times). The translation preserves dag-size up to a polynomial factor.

**Test:** Define `SharedCertificateDAG` as a structure with explicit node sharing. Implement the translation and verify on random instances that dag-size is preserved within a quadratic factor. Check whether known dag-vs-tree separations for resolution (e.g., the formulas of Bonet and Galesi) correspond to separations in certificate structure.

**Impact:** Dag-like resolution is exponentially more powerful than tree-like resolution. Extending the bridge to the dag setting would make the transfer theorem applicable to all known resolution lower bounds, including the optimal 2^(Ω(n)) bounds of Ben-Sasson and Wigderson.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianProofComplexity.lean` — `ResolutionStep`, `CertificateTree`
- `Catalog/Pythagorean/LorentzianHardness.lean` — `multiindex_count_exponential_lower`

**Proof Strategy:** Define dag-like structures using hash-consing or explicit sharing annotations. Prove that the translation maps shared derivations to shared certificates by tracking reference counts through the induction.

**Domain Bridges:** Proof complexity ↔ algebraic combinatorics; space complexity ↔ certificate memory

**Lineage:** Extends `resolution_lower_bound_transfers` to a strictly more powerful proof system.

**Ambition:** Solid extension — technically demanding but follows established patterns.

---

## Direction 3: Width Transfer and the Ben-Sasson–Wigderson Method

**Conjecture:** There exists a geometric invariant W(C) of certificate trees — the "algebraic width" — such that W(resolutionToCertificate(R)) is polynomially related to the resolution width of R, and such that a width-size relationship analogous to the Ben-Sasson–Wigderson theorem holds for certificate trees.

**The key insight is** that resolution width controls proof size through the BSW theorem (size ≥ 2^(width − clause_width)), and if this relationship transfers to the geometric setting, it would yield a purely algebraic proof of the BSW theorem.

**Why now?** The structural theorem `certificate_leaves_le_pow_depth` already establishes an exponential relationship between a structural parameter (depth) and a combinatorial measure (leaf count). Width may be the right refinement of depth that yields tight bounds.

**Test:** Define candidate width measures (maximum clause size in `certificateToResolution`, branching number, effective dimension of leaf multiindices). Compute for PHP(n+1,n) refutations and check whether the width-size relationship log(size) ≥ width − O(1) holds.

**Impact:** Would establish the first intrinsic width-size theorem for algebraic certificate systems, potentially yielding new proofs of known lower bounds and new bounds for previously intractable instances.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianProofComplexity.lean` — `resolutionWidth`, `certificateDepth`, `certificate_leaves_le_pow_depth`
- `Catalog/Bridges/LorentzianRecognition.lean` — `numberOfQuadraticLeaves`, `quadratic_leaf_count_le`

**Proof Strategy:** Define algebraic width as the maximum, over all nodes in the certificate tree, of the number of distinct variables appearing in leaf multiindices in the sub-tree. Prove by induction that this is ≤ resolution width + 1. Then prove the width-size theorem by adapting the BSW adversary argument to the certificate setting.

**Domain Bridges:** Proof complexity ↔ information theory; resolution width ↔ algebraic dimension

**Lineage:** Builds on `certificate_depth_controls_size` and `certificate_size_eq_two_leaves_minus_one`.

**Ambition:** Grand challenge — would open a new chapter in proof complexity.

---

## Direction 4: Matroid Hodge Theory and Certificate Bases

**Conjecture:** For the characteristic polynomial of a matroid, the certificate tree structure reflects the matroid's lattice of flats. Specifically, the minimum certificate tree size for the characteristic polynomial of a matroid M is polynomially related to the number of flats of M.

**The key insight is** that Adiprasito–Huh–Katz proved Lorentzianity of matroid characteristic polynomials using Hodge theory, and their proof implicitly constructs a certificate whose combinatorial structure should encode the matroid's flat lattice.

**Why now?** The certificate tree formalism provides the first rigorous framework for measuring the complexity of Hodge-theoretic certificates. The AHK proof, when unwound, should yield explicit certificate trees whose analysis could reveal new combinatorial properties of matroids.

**Test:** For small matroids (uniform matroids U_{2,n}, graphic matroids of small graphs), construct the characteristic polynomial, build explicit certificate trees, and compare their sizes with the number of flats. Check whether the ratio stabilizes.

**Impact:** Would connect proof complexity to one of the most celebrated results in recent combinatorics (the Rota–Heron–Welsh conjecture), potentially revealing new structural properties of matroid invariants through the lens of certificate complexity.

**Catalog References:**
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean`
- `Catalog/Bridges/LorentzianRecognition.lean` — `RecursiveLorentzianCertificate`
- `Catalog/Pythagorean/LorentzianProofComplexity.lean` — `certificateSize`, `certificateLeafCount`

**Proof Strategy:** Construct explicit certificate trees for uniform matroid characteristic polynomials using the known formula. Count nodes and compare with the binomial coefficient formula for the number of flats. Prove the polynomial relationship by analyzing the recursive structure of both objects.

**Domain Bridges:** Matroid theory ↔ proof complexity; Hodge theory ↔ certificate combinatorics

**Lineage:** Extends `certificate_size_eq_two_leaves_minus_one` to a specific polynomial family with deep mathematical significance.

**Ambition:** Grand challenge — paradigm-shifting if the flat lattice correspondence holds.

---

## Direction 5: New Lower Bounds via Spectral Obstructions

**Conjecture:** There exists a polynomial family whose certificate complexity can be bounded below using spectral properties of the Hessian matrices (eigenvalue gaps, condition numbers) rather than purely combinatorial arguments. Specifically, for the polynomial encoding of random 3-SAT instances near the satisfiability threshold, the minimum certificate tree size is 2^(Ω(n)).

**The key insight is** that spectral arguments — bounding eigenvalue gaps, analyzing the condition number of Hessian restrictions — may provide genuinely new proof complexity lower bound techniques that have no purely combinatorial analogue.

**Why now?** The bridge theorems provide the formal infrastructure to translate spectral bounds into proof complexity statements. Random 3-SAT near threshold is the frontier of proof complexity (no exponential lower bounds are known for general resolution), and the algebraic structure of the corresponding polynomial encodings may be amenable to spectral analysis.

**Test:** For random 3-SAT instances at clause density 4.267 (near threshold), compute the Hessian spectrum at random certificate tree leaves. Check whether the spectral gap correlates with certificate tree size. If so, the spectral gap may provide a new measure that controls certificate complexity.

**Impact:** Would constitute the first proof complexity lower bound proved using spectral/Hodge-theoretic methods — a genuine paradigm shift that would validate the entire Lorentzian proof complexity program.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianSpectralGap.lean`
- `Catalog/Bridges/LorentzianRecognition.lean` — `HasAtMostOnePositiveEigenvalue`, `lorentzian_signature_tangent_neg_semidef`
- `Catalog/Pythagorean/LorentzianProofComplexity.lean` — `resolution_lower_bound_transfers`

**Proof Strategy:** Define a spectral complexity measure on certificate trees: the sum over all leaves of the reciprocal of the smallest negative eigenvalue of the Hessian. Prove a monotonicity lemma: this measure increases by at least 1 at each branching node. Combined with a bound on the initial spectral measure, this would yield a lower bound on tree size.

**Domain Bridges:** Spectral theory ↔ proof complexity; random matrix theory ↔ phase transitions in satisfiability

**Lineage:** Extends `resolution_lower_bound_transfers` using spectral techniques from `lorentzian_signature_tangent_neg_semidef`.

**Ambition:** Grand challenge — the "moonshot" of the research program.
