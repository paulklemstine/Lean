# Future Directions: Arithmetic Phase Classification

## Synthesis

The arithmetic phase classification framework established here demonstrates that prime-local torsion detection provides a sound, complete, and computationally efficient classifier for finite cyclic gauge models. The five directions below extend this foundation along complementary axes: deeper mathematical theory (Directions 1–2), broader physical applicability (Directions 3–4), and computational scalability (Direction 5). Together, they form a research program that could establish arithmetic torsion as a standard tool in both mathematical physics and computational materials science. Each direction builds explicitly on the formally verified theorems in `Pythagorean/ArithmeticPhaseClassification.lean` and the catalog results in `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`.

---

## Direction 1: Non-Abelian Arithmetic Phase Classification

**Ambition:** grand_challenge

**Conjecture:** For a non-abelian finite gauge group $G$, the torsion profile of its abelianization $G^{\text{ab}}$ captures all prime-level phase information detectable by homological probes. Formally: if $G_1^{\text{ab}} \cong G_2^{\text{ab}}$ as abelian groups, then the arithmetic torsion profiles of $G_1$-gauge theories and $G_2$-gauge theories agree at all primes.

**Test:** Compute torsion profiles for $S_3$ (abelianization $\mathbb{Z}/2\mathbb{Z}$), $A_4$ (abelianization $\mathbb{Z}/3\mathbb{Z}$), and $Q_8$ (abelianization $\mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$). If any pair with isomorphic abelianizations has different arithmetic behavior in a derived-functor sense, the conjecture is falsified.

**Impact:** Would extend the arithmetic classifier from abelian to all finite gauge groups, covering physically relevant theories like $S_3$ gauge models in lattice gauge theory.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean`: `HasPTorsion_ZMod_iff_dvd`, `torsionProfileUpTo_prod`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsion_invisible_wrong_characteristic`

**Proof Strategy:** Define `HasPTorsion` for group algebras $\mathbb{Z}[G]$ via the abelianization map $G \to G^{\text{ab}}$. Prove that the induced map on $\text{Tor}_1$ is an isomorphism for torsion detection purposes, using the universal property of abelianization and the fact that $\text{Tor}_1$ is a derived functor of an additive functor.

**Domain Bridges:** Algebraic topology ↔ representation theory ↔ lattice gauge theory

**Lineage:** Extends `HasPTorsion_prod_iff` from products of cyclic groups to products of arbitrary finite group algebras.

---

## Direction 2: Adelic Persistent Homology

**Ambition:** grand_challenge

**Conjecture:** The torsion barcode of a filtered finite abelian group, viewed as a function $p \mapsto \text{torsionSupport}_p(\text{filtration})$ from primes to subsets of filtration indices, is equivalent to the data of an adelic persistence module — a persistence module over the ring of finite adeles $\mathbb{A}_f$ restricted to the torsion part.

**Test:** Construct the adelic persistence module explicitly for $\mathbb{Z}/6\mathbb{Z}$ with a 3-level filtration. Verify that the 2-adic and 3-adic components reproduce the individual prime barcodes, and that the adelic product reconstructs the full torsion barcode. If the reconstruction fails for any filtration with $\geq 4$ levels, the conjecture is falsified.

**Impact:** Would establish arithmetic persistent homology as a branch of adelic geometry, connecting topological data analysis to the Langlands program and related number-theoretic structures.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean`: `persistentPrimeSupportUpTo`, `torsionProfileUpTo_complete_for_bounded_support`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsionSupport`, `pTorPersistence_vanishes_of_free`

**Proof Strategy:** Use the Chinese Remainder Theorem to decompose the torsion part of each filtration level into $p$-primary components. Show that the persistence structure maps respect this decomposition, producing a persistence module over each $\mathbb{Z}_p$. The adelic product assembles these into a single object.

**Domain Bridges:** Number theory ↔ persistent homology ↔ algebraic geometry

**Lineage:** Extends `torsionProfileUpTo_complete_for_bounded_support` from finite sets to adelic objects.

---

## Direction 3: Arithmetic Phase Transitions in Frustrated Magnets

**Ambition:** solid_extension

**Conjecture:** For a triangular lattice antiferromagnet with $\mathbb{Z}/n\mathbb{Z}$ spin symmetry, the torsion profile of the ground state manifold's homology detects frustration-induced phase transitions. Specifically: the profile changes precisely at the critical coupling values where the ground state degeneracy pattern changes.

**Test:** Compute the first homology group $H_1$ of the ground state configuration space for $n = 2, 3, 4, 6$ on finite triangular lattices of increasing size ($L = 3, 4, 5, 6$). Track the torsion profile as a function of the nearest-neighbor coupling constant. If the profile is constant across a known phase transition, the conjecture is falsified.

**Impact:** Would provide the first experimental/computational validation of arithmetic phase classification in a realistic condensed matter system.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean`: `HasPTorsion_ZMod_iff_dvd`, `persistentPrimeSupportUpTo`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsionBirth`, `torsionDeath`

**Proof Strategy:** Use simplicial homology of the configuration space (a subcomplex of the product $(S^1)^{|V|}$) to compute $H_1$ with integer coefficients. Apply the Smith normal form algorithm to extract torsion. Track prime support as a function of coupling.

**Domain Bridges:** Condensed matter physics ↔ computational topology ↔ combinatorics

**Lineage:** Applies `HasPTorsion_ZMod_iff_dvd` to homology groups computed from physical models.

---

## Direction 4: Quantum Error Correction via Prime-Sensitive Torsion Codes

**Ambition:** solid_extension

**Conjecture:** For a topological quantum code based on a $\mathbb{Z}/n\mathbb{Z}$ gauge theory on a surface of genus $g$, the code distance against $p$-type errors (errors acting on the $p$-primary component of the logical space) is determined by the $p$-component of the torsion profile of the surface's homology. In particular: if $p \nmid n$, then $p$-type errors have no effect on the code space, providing automatic protection against an entire class of errors.

**Test:** Implement the $\mathbb{Z}/6\mathbb{Z}$ toric code on a torus and compute code distances against 2-errors and 3-errors separately. If the distances are not independent (i.e., if a 2-error can create a 3-type logical error), the conjecture is falsified.

**Impact:** Would define a new family of quantum error-correcting codes with prime-structured error models, potentially offering more efficient encoding for multi-level quantum systems.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean`: `zmod_prime_power_detected_exactly_at_prime`, `torsionProfileUpTo_prod`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `prime_selectivity`

**Proof Strategy:** Decompose the code space $H_1(\text{surface}; \mathbb{Z}/n\mathbb{Z})$ into $p$-primary components using the Chinese Remainder Theorem. Show that logical operators in the $p$-component are homologically independent from those in the $q$-component for $p \neq q$. The code distance in each component is then the minimum weight of a non-trivial $p$-cycle.

**Domain Bridges:** Quantum information ↔ algebraic topology ↔ coding theory

**Lineage:** Extends `zmod_prime_power_detected_exactly_at_prime` from algebraic modules to physical code spaces.

---

## Direction 5: Scalable Arithmetic TDA Pipeline

**Ambition:** solid_extension

**Conjecture:** For a simplicial complex $K$ with $N$ simplices, the full torsion profile of $H_k(K; \mathbb{Z})$ for all $k$ can be computed in time $O(N^\omega \log N)$ where $\omega$ is the matrix multiplication exponent, by combining the Smith normal form computation with sieved prime checks. This is asymptotically no slower than computing ordinary Betti numbers.

**Test:** Implement the algorithm on random Rips complexes of increasing size ($N = 100, 1000, 10000$) and measure wall-clock time against the standard Betti number computation. If the torsion profile computation is more than $O(\log N)$ times slower than Betti numbers for any test case, the conjecture is falsified (modulo constant factors).

**Impact:** Would demonstrate that arithmetic phase classification is computationally viable for real-world topological data analysis, not just small toy models.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean`: `computeTorsionProfile`, `computeTorsionProfile_correct`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `tor1_vanishes_iff_no_n_torsion`

**Proof Strategy:** The Smith normal form of the boundary matrix gives the torsion subgroup as a product of cyclic groups $\mathbb{Z}/d_i\mathbb{Z}$. The torsion profile is then the union of prime factors of the $d_i$, computable in $O(\sum \log d_i)$ additional time. The bottleneck is the Smith normal form, which has the same complexity as matrix multiplication.

**Domain Bridges:** Computational topology ↔ algorithmic algebra ↔ data science

**Lineage:** Extends `computeTorsionProfile_correct` from explicit moduli lists to Smith-normal-form outputs.
