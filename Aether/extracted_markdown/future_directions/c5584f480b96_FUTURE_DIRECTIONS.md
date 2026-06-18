# Future Directions: Non-Abelian Arithmetic Phase Classification

## Synthesis

The arithmetic phase classification theorem establishes that first-order prime torsion visibility through abelian quotients is entirely controlled by the abelianization G^ab. This opens a systematic program to:

1. **Climb the homological ladder**: The abelianization is H₁(G, ℤ). What arithmetic information is captured by H₂(G, ℤ) (the Schur multiplier), H₃, etc.? Each level may reveal genuinely new non-abelian arithmetic structure.

2. **Refine the invariant**: The phase profile captures only *which primes* appear, not *how much* torsion exists at each prime. A refined "phase spectrum" (counting torsion elements or using invariant factors) would be strictly finer.

3. **Bridge to physics**: The product theorem (Künneth for phases) suggests a compositional framework for lattice gauge theories. Extending to continuous/profinite groups would connect to physical gauge theories.

4. **Computational applications**: The O(|G|³) algorithm for phase profiles, combined with the product theorem's avoidance of constructing G×H, suggests efficient group fingerprinting and isomorphism pre-testing.

All directions below build directly on the catalog results in `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` and the newly proved theorems in `Pythagorean/NonAbelianPhaseClassification.lean`.

---

## Direction 1: Schur Multiplier Phase Classification (Grand Challenge)

**Conjecture:** For finite groups G₁, G₂ with H₁(G₁, ℤ) ≅ H₁(G₂, ℤ) and H₂(G₁, ℤ) ≅ H₂(G₂, ℤ), the "second-order arithmetic phase profiles" (defined via central extensions) are identical. That is, the first two homology groups together provide a complete degree-2 phase classification.

**Test:** Compute H₂(G, ℤ) for all groups of order ≤ 32. Find groups with isomorphic H₁ and H₂ but different behavior under central extension probes. If none exist, formalize the degree-2 classification theorem. If counterexamples exist, they isolate the first H₃-level obstruction.

**Impact:** Would establish a systematic hierarchy of arithmetic phase invariants indexed by homological degree, creating a new "arithmetic spectral sequence" for group classification.

**Catalog References:**
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` (torsion detection via Tor₁)
- `Pythagorean/NonAbelianPhaseClassification.lean` (degree-1 classification)
- `Catalog/Pythagorean/AbelianizationTorsion.lean` (abelianization torsion transfer)

**Proof Strategy:** Define "degree-2 phase visibility" as the existence of a central extension 1 → A → E → G → 1 with A abelian, where E has specific torsion properties. Show this is controlled by H₂(G, ℤ) using the universal coefficient theorem for group cohomology. The key difficulty is formalizing group cohomology in Lean.

**Domain Bridges:** Topological phases of matter, where H₂(G, U(1)) classifies symmetry-protected topological (SPT) phases. This conjecture would connect arithmetic phase detection to SPT classification.

**Lineage:** Direct extension of Theorem A (degree-1 classification) to degree 2.

**Ambition:** Grand challenge — would open a new program in computational group homology with physical applications.

---

## Direction 2: Torsion Spectrum Refinement

**Conjecture:** Define the *torsion spectrum* of G at prime p as the multiset of invariant factors of the p-primary part of G^ab. Then: (a) groups with the same torsion spectrum have the same representation-theoretic p-local properties at the abelianized level, and (b) the torsion spectrum is strictly finer than the phase profile — there exist groups with the same phase profile but different torsion spectra.

**Test:** 
- (a) Prove in Lean that torsion spectra are preserved under abelianization isomorphisms (straightforward from the structure theorem for finite abelian groups).
- (b) Verify computationally: ℤ/4ℤ has torsion spectrum [4] at prime 2 while (ℤ/2ℤ)² has spectrum [2,2]. Both have phase profile {2} but different spectra.
- (c) Find non-abelian G₁, G₂ with same phase profile but different torsion spectra (e.g., Q₈ vs S₃ × ℤ/2ℤ).

**Impact:** Creates a more sensitive invariant for group classification, useful for cryptographic group selection and computational group theory.

**Catalog References:**
- `Pythagorean/NonAbelianPhaseClassification.lean` (groupHasPTorsion_multiplicative_zmod)

**Proof Strategy:** Use the structure theorem for finite abelian groups: G^ab ≅ ⊕ ℤ/n_i. The torsion spectrum at p is the multiset {v_p(n_i) : v_p(n_i) > 0}. Preservation under isomorphism is immediate.

**Domain Bridges:** Coding theory (where the invariant factor decomposition of abelian groups determines error-correcting properties), number theory (where torsion in class groups determines arithmetic).

**Lineage:** Refinement of the phase profile from a set to a multiset.

**Ambition:** Solid extension — directly builds on established catalog results.

---

## Direction 3: Profinite Phase Classification

**Conjecture:** The arithmetic phase classification theorem extends to profinite groups: for a profinite group G and prime p, PrimePhaseVisible(G, p) ↔ the profinite abelianization G^ab has p-torsion. This would apply to absolute Galois groups, p-adic groups, and étale fundamental groups.

**Test:** 
- Formalize the profinite abelianization in Lean (as the inverse limit of finite abelianizations).
- Prove the classification theorem for profinite groups using the finite case as a building block.
- Test on Ẑ = lim ℤ/nℤ (which has p-torsion for all primes p) and ℤ_p (which has p-torsion only for the prime p).

**Impact:** Would connect arithmetic phase classification to Iwasawa theory and the Langlands program, where profinite groups play a central role.

**Catalog References:**
- `Pythagorean/NonAbelianPhaseClassification.lean` (primePhaseVisible_iff_abelianization — finite case)

**Proof Strategy:** Express the profinite phase profile as the union of finite phase profiles over all finite quotients. Use the fact that torsion in a profinite group is detected by torsion in some finite quotient.

**Domain Bridges:** Number theory (Galois groups), algebraic geometry (étale fundamental groups), condensed mathematics.

**Lineage:** Generalization from finite to profinite groups.

**Ambition:** Grand challenge — would require substantial new infrastructure in Lean.

---

## Direction 4: Representation-Theoretic Phase Detection

**Conjecture:** Define a *representation phase profile* Rep-Profile(G) = {p prime : G has an irreducible representation over 𝔽_p of dimension > 1}. Then Rep-Profile(G) is NOT determined by G^ab — it captures genuinely non-abelian information. Specifically, there exist groups G₁, G₂ with G₁^ab ≅ G₂^ab but Rep-Profile(G₁) ≠ Rep-Profile(G₂).

**Test:**
- Q₈ and D₄: both have G^ab ≅ (ℤ/2ℤ)², so same arithmetic phase profile. But Q₈ has a 2-dimensional irreducible representation over ℚ (the standard representation via quaternions) while D₄ has one of different character. Check whether their 𝔽_p representations differ.
- Compute Rep-Profile for all groups of order ≤ 16 and compare with arithmetic phase profiles.

**Impact:** Would identify the first "non-abelianization" arithmetic invariant accessible through representation theory, opening a dual approach to phase classification.

**Catalog References:**
- `Pythagorean/NonAbelianPhaseClassification.lean` (primePhaseVisible_iff_abelianization — shows abelianization *does* suffice for additive probes)

**Proof Strategy:** Use character theory over finite fields. An irreducible 𝔽_p-representation of dimension > 1 cannot factor through G^ab (since abelian groups have only 1-dimensional irreps). Therefore, Rep-Profile detects non-abelian structure. The challenge is making this constructive.

**Domain Bridges:** Quantum computing (where representations of symmetry groups govern quantum error correction), condensed matter physics (representation theory of point groups).

**Lineage:** Parallel to arithmetic phase classification but using multiplicative rather than additive probes.

**Ambition:** Solid extension with potential for surprising discoveries.

---

## Direction 5: Computational Complexity of Phase Profiles

**Conjecture:** Computing the arithmetic phase profile from a group's Cayley table has complexity Θ(|G|³) (i.e., the commutator subgroup computation dominates and cannot be improved below cubic). However, for groups given by generators and relations, the problem is in P but the exact complexity depends on the presentation.

**Test:**
- Prove the Ω(|G|²) lower bound: any algorithm must examine at least |G|² entries of the Cayley table to determine the commutator subgroup.
- Implement and benchmark the O(|G|³) algorithm on random groups of increasing size.
- For presentation-based input: implement Todd-Coxeter coset enumeration and measure empirical complexity.

**Impact:** Would establish the computational tractability of phase classification, important for applications in computational group theory and automated theorem proving.

**Catalog References:**
- `Pythagorean/NonAbelianPhaseClassification.lean` (the algorithmic content — phase profile computation via abelianization)

**Proof Strategy:** Lower bound: construct an adversarial family of groups where any sublinear algorithm can be fooled. Upper bound: the current algorithm achieves O(|G|³). Potential improvement: use Schreier-Sims or other group-theoretic algorithms.

**Domain Bridges:** Computational complexity theory, automated reasoning, group isomorphism testing.

**Lineage:** Algorithmic consequence of the classification theorem.

**Ambition:** Solid extension — primarily computational rather than mathematical.
