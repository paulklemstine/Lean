# Future Research Directions: Isogeny-Based Cryptography

## Synthesis

This research cycle established a rigorous algebraic foundation for SIDH key exchange and its cryptanalysis, formalizing the shared secret agreement theorem, dual isogeny structure, Euler's four-square identity (as the engine of quaternion norm multiplicativity), and the Castryck-Decru attack structure. The most significant insight is that the commutativity axiom that makes SIDH correct is precisely what the attack exploits — the torsion data reveals the commuting structure in a recoverable form.

The strongest cross-domain connection emerged between the quaternion norm form (Euler's four-square identity) and the degree multiplicativity of isogenies. This bridge between classical number theory (sums of squares) and modern algebraic geometry (isogeny degrees) is the algebraic engine of the Deuring correspondence. Future cycles should exploit this bridge to formalize deeper structural results, particularly the polynomial-time equivalence between isogeny and quaternion path problems.

The direction with highest breakthrough potential is **Direction 1**: formalizing the Deuring correspondence as a constructive algorithm, since this would simultaneously advance both pure mathematics (maximal orders in quaternion algebras) and applied cryptography (SQISign security proofs). The existing `SupersingularGraph` and `DualIsogenyStructure` provide the scaffolding.

---

### Direction 1: Constructive Deuring Correspondence and SQISign Security

**Conjecture**: The Deuring correspondence between supersingular j-invariants and maximal orders in B_{p,∞} can be made constructive in polynomial time: given a supersingular curve E/F_p, one can compute End(E) as a maximal order in B_{p,∞} in time polynomial in log p. Conversely, given a maximal order O, one can find a curve E with End(E) ≅ O.

**Test**: Implement the Kohel-Lauter-Petit-Tignol algorithm for small primes p < 1000 and verify that it produces correct endomorphism rings by checking the norm form matches the curve's Frobenius trace.

**Impact**: A formalized constructive Deuring correspondence would directly yield a formalized security proof for SQISign — the leading isogeny-based signature scheme currently under consideration for standardization. It would also provide the first machine-verified proof of the polynomial-time equivalence between the isogeny path problem and the quaternion path problem.

**Catalog References**: `Cryptography/SIDHFoundations.lean` (SupersingularGraph, DeuringCorrespondence, DualIsogenyStructure), `Algebra/Core/OpenQuestions.lean` (quaternion_two_factorizations)

**Proof Strategy**: (1) Formalize maximal orders in quaternion algebras as ℤ-lattices of rank 4. (2) Define the connecting ideal between two maximal orders. (3) Prove that ideal norm equals isogeny degree using the four-square identity. (4) Construct the explicit map from curves to orders using the Frobenius endomorphism. (5) Prove polynomial-time computability via lattice reduction.

**Domain Bridges**: Number Theory (quaternion algebras, maximal orders) ↔ Algebraic Geometry (supersingular curves, isogenies) ↔ Cryptography (SQISign security)

**Lineage**: Builds on SupersingularGraph, DualIsogenyStructure, and DeuringCorrespondence from this cycle's formalization.

**Ambition**: grand_challenge

---

### Direction 2: Richelot Isogenies and Genus-2 Curve Arithmetic

**Conjecture**: Every (2,2)-isogeny of a principally polarized abelian surface A = Jac(C) for a genus-2 curve C can be computed in O(1) field operations (constant number of polynomial operations) given the Igusa invariants of C, and the resulting (2,2)-isogeny graph on genus-2 Jacobians is connected for p > 3.

**Test**: For p = 101, enumerate all genus-2 curves over F_p, compute all Richelot isogenies, and verify connectivity of the resulting graph. Count connected components.

**Impact**: A formalized theory of Richelot isogenies would provide the computational substrate for formalizing the complete Castryck-Decru attack algorithm (currently modeled abstractly). It would also open the door to formalizing higher-dimensional isogeny-based cryptography.

**Catalog References**: `Cryptography/SIDHFoundations.lean` (KaniDecomposition, coprime_enables_attack)

**Proof Strategy**: (1) Formalize genus-2 curves and their Jacobians. (2) Define Richelot isogenies via symplectic bases of 2-torsion. (3) Prove the Richelot isogeny formula using Mumford representations. (4) Show connectivity via the action of Sp_4(F_2) on 2-torsion bases.

**Domain Bridges**: Algebraic Geometry (genus-2 curves, Jacobians) ↔ Computational Number Theory (Richelot isogeny computation) ↔ Cryptanalysis (Castryck-Decru attack implementation)

**Lineage**: Extends the KaniDecomposition structure and the polynomial-time attack framework from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Isogeny Graphs and Non-Archimedean Cryptography

**Conjecture**: The tropical analogue of the supersingular isogeny graph — the Bruhat-Tits tree for GL₂(Q_p) — admits a group action by the class group of a tropical order that satisfies the axioms of the `SupersingularGraph` structure. Furthermore, this tropical isogeny graph has a well-defined Ramanujan-like spectral bound.

**Test**: For p = 2 and 3, explicitly construct the Bruhat-Tits tree to depth 10, compute the adjacency spectrum, and verify that non-trivial eigenvalues satisfy |λ| ≤ 2√p.

**Impact**: If true, this would establish a deep connection between tropical geometry and isogeny-based cryptography, potentially yielding new hard problems for post-quantum cryptography. If false, the failure would illuminate what specific properties of supersingular curves are needed for cryptographic hardness beyond mere graph expansion.

**Catalog References**: `Tropical/` (tropical algebra framework), `Cryptography/SIDHFoundations.lean` (SupersingularGraph axioms, RamanujanProperty)

**Proof Strategy**: (1) Formalize the Bruhat-Tits tree as a simplicial complex. (2) Define the tropical analogue of the class group action. (3) Verify the free-transitive axioms. (4) Compute the spectral gap using the representation theory of PGL₂(Q_p). (5) Compare with the Ramanujan bound.

**Domain Bridges**: Tropical Geometry ↔ p-adic Analysis (Bruhat-Tits trees) ↔ Cryptography (isogeny graph structure)

**Lineage**: Novel direction bridging the Catalog's tropical framework with the isogeny graph formalization.

**Ambition**: grand_challenge

---

### Direction 4: Class Group Computation and Isogeny Degree Bounds

**Conjecture**: For a supersingular curve E over F_p with p = 2^a · 3^b - 1, the class number h(O_K) of the imaginary quadratic order O_K = Z[π] (where π is the Frobenius) satisfies h(O_K) = p/12 + O(√p log p), and this bound is tight: there exist infinitely many primes p where the error term is Θ(√p log p).

**Test**: For the first 100 primes of the form 2^a · 3^b - 1, compute h(O_K) using the Cornacchia algorithm and verify the bound. Plot the error term (h(O_K) - p/12)/√p as a function of p.

**Impact**: Tight class number bounds directly determine the security margin of CSIDH-style protocols. A formalized proof would provide the first machine-verified security parameter analysis for isogeny-based cryptography.

**Catalog References**: `Cryptography/SIDHFoundations.lean` (classicalSecurityBits, quantumSecurityBits), `Algebra/ArtinConjecture.lean` (primitive root density)

**Proof Strategy**: (1) Formalize the Eichler mass formula for supersingular curves. (2) Prove the class number formula h = (p-1)/12 + correction terms using Deuring's theory. (3) Bound the correction terms using the Brauer-Siegel theorem. (4) Verify computationally for SIDH parameter sizes.

**Domain Bridges**: Analytic Number Theory (class number formulas, L-functions) ↔ Algebraic Geometry (supersingular curve counting) ↔ Cryptography (security parameter estimation)

**Lineage**: Extends the security parameter analysis (classicalSecurityBits, quantumSecurityBits) from this cycle.

**Ambition**: extension

---

### Direction 5: Isogeny-Based Hash Functions and Collision Resistance

**Conjecture**: The Charles-Goren-Lauter hash function — defined by walking on the supersingular 2-isogeny graph according to message bits — is collision-resistant under the assumption that the supersingular isogeny path problem is hard. More precisely, finding a collision is equivalent to solving two instances of the isogeny path problem.

**Test**: Implement the CGL hash for p = 2^127 - 1 and verify that random walks of length 256 produce uniformly distributed outputs (chi-squared test on j-invariants mod small primes).

**Impact**: A formalized collision resistance proof would be the first machine-verified security reduction for an isogeny-based hash function. Unlike SIDH, the CGL hash does not reveal torsion data and thus remains unbroken.

**Catalog References**: `Cryptography/SIDHFoundations.lean` (SupersingularGraph, isogeny_unique, RamanujanProperty, mixingTime)

**Proof Strategy**: (1) Define the CGL hash function as a deterministic walk on SupersingularGraph. (2) Prove that a collision yields two distinct paths between the same endpoints. (3) Apply isogeny_unique to show these paths encode isogeny path problem solutions. (4) Use the Ramanujan expansion property to prove output uniformity.

**Domain Bridges**: Graph Theory (Ramanujan expansion, random walks) ↔ Cryptography (hash function security) ↔ Number Theory (isogeny path hardness)

**Lineage**: Directly extends SupersingularGraph, isogeny_unique, and RamanujanProperty from this cycle.

**Ambition**: extension
