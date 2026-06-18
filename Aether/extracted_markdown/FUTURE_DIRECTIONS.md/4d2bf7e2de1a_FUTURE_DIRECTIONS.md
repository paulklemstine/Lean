# Future Directions

## Synthesis

This research cycle established the **Group Family Classification** — a four-tier structural invariant (Noble Gas / Alkali Metal / Transition Metal / Halogen) for finite groups, with 24 machine-verified theorems including the Periodic Law (isomorphism invariance), the Depth-Order Bound (d(G) ≤ Ω(|G|)), the Depth-Nilpotency Bound (d(G) ≤ class(G) + 1), and the Center-Stability Duality (nontrivial center + non-prime order → not simple). The novel **Reactivity Index** R(G) = Ω(|G|) − d(G) provides a quantitative measure of structural complexity, and we proved that abelian groups maximize it (R = Ω − 1).

The most promising cross-domain connection is between the Group Family Classification and the existing Catalog's solvability results (`not_solvable_perm_fin_five` in `Algebra`) and Galois theory (`Bridges/GaloisDeepLearning.lean`). The derived series that defines our classification is exactly the derived series used in Galois theory to determine solvability by radicals. This suggests a bridge between our periodic table and the Abel-Ruffini theorem: groups appearing as Galois groups of polynomials solvable by radicals are precisely the non-halogen groups. Formalizing this connection would link finite group classification directly to polynomial algebra.

The highest-breakthrough-potential direction is Direction 1 (Refined Periodic Table): refining from 4 families to 18+ sub-families using finer invariants (nilpotency class, Frattini quotient structure) could yield a genuinely predictive classification system for the ~50 billion groups of order 1024.

---

### Direction 1: The 18-Column Periodic Table of Groups

**Conjecture**: The four-family classification can be refined to at least 18 sub-families by combining (a) the nilpotency class (for nilpotent groups), (b) the derived length (for solvable groups), and (c) the structure of the socle (for non-solvable groups), such that groups in the same sub-family share at least 5 structural invariants: derived length, nilpotency class or ∞, number of conjugacy classes modulo order, Frattini quotient isomorphism type, and automorphism group order modulo a bounded function of the group order.

**Test**: Enumerate all groups of order ≤ 100 (there are 1048 of them) using GAP or Magma. Compute all 5 invariants. Verify that the proposed sub-family classification correctly predicts at least 4 of the 5 invariants from the sub-family label alone. If the prediction rate is below 80%, the classification needs refinement.

**Impact**: A refined classification would be the first genuinely predictive organizational scheme for finite groups. It would enable "periodic table lookup" — given a group's order and sub-family, predict its structural properties without computing them. This has applications in computational algebra, cryptography (group-based cryptosystems), and physics (symmetry classification in particle physics).

**Catalog References**: `Algebra/GroupSolvability.lean` (solvability results), `Bridges/GaloisDeepLearning.lean` (derived series formalization)

**Proof Strategy**: Define the sub-family classification as a function from GroupFamily × ℕ × ℕ → SubFamily. Prove that each sub-family is an isomorphism invariant (extending the Periodic Law). Then prove that sub-family membership constrains each of the 5 invariants. The key lemmas needed: (1) nilpotency class is an isomorphism invariant, (2) Frattini quotient structure is determined by the group's conjugacy class structure, (3) automorphism group order is bounded by a function of the sub-family parameters.

**Domain Bridges**: Algebra (group classification) <-> Cryptography (group-based key exchange security depends on structural complexity) <-> Computation (algorithmic group theory relies on structural classification for efficiency)

**Lineage**: Extends this cycle's Group Family Classification (family_isomorphism_invariant, nilpotent_family_classification, pGroup_family_classification)

**Ambition**: grand_challenge

---

### Direction 2: The Abel-Ruffini Bridge — Periodic Table Meets Galois Theory

**Conjecture**: For a polynomial f of degree n over ℚ, f is solvable by radicals if and only if its Galois group Gal(f) is a non-halogen group (Noble Gas, Alkali Metal, or Transition Metal in our classification). Moreover, the solvability depth d(Gal(f)) equals the minimum number of nested radical extractions needed to express the roots.

**Test**: Compute the Galois group and solvability depth for all irreducible polynomials of degree ≤ 5 over ℚ with integer coefficients in [-3, 3]. Verify that the second claim (depth = nesting level) holds. A single counterexample disproves the conjecture.

**Impact**: If true, this provides a constructive link between the abstract periodic table and concrete polynomial algebra. The solvability depth becomes a measure of "algebraic complexity" of polynomial roots. This would mean our classification is not just organizational but *computational* — it tells you how hard it is to solve a polynomial.

**Catalog References**: `Bridges/GaloisDeepLearning.lean` (derived series and Galois connections), `not_solvable_perm_fin_five` in `Algebra` (S₅ non-solvability, which is the group-theoretic core of Abel-Ruffini)

**Proof Strategy**: The forward direction (non-halogen ↔ solvable by radicals) is essentially the Abel-Ruffini theorem, which is deep but well-understood. The key new content is the claim about depth = nesting level. This requires showing that each step in the derived series corresponds to exactly one radical extraction in the tower of splitting fields. Formalize using Mathlib's Galois theory library (`Mathlib.FieldTheory.AbelRuffini`).

**Domain Bridges**: Algebra (group theory, periodic table) <-> Algebra (field theory, Galois theory) <-> Computation (algorithmic aspects of solving polynomials by radicals)

**Lineage**: Extends this cycle's solvabilityDepth and halogen_iff_not_solvable theorems

**Ambition**: grand_challenge

---

### Direction 3: Reactivity Index and Representation Theory

**Conjecture**: For a finite solvable group G, the reactivity index R(G) = Ω(|G|) − d(G) equals the minimum dimension of a faithful complex representation minus the number of conjugacy classes of maximal subgroups, plus a correction term bounded by log₂(|G|).

**Test**: Compute R(G), the minimum faithful representation dimension, and the number of conjugacy classes of maximal subgroups for all solvable groups of order ≤ 60. Check whether the claimed relationship holds with correction term ≤ log₂(|G|).

**Impact**: This would give the reactivity index a representation-theoretic interpretation, connecting the "chemistry" of the periodic table to the "physics" of group representations. It would also provide a new lower bound on faithful representation dimensions.

**Catalog References**: `Applications/PeriodicTableCore.lean` (reactivityIndex definition and abelian_maximal_reactivity theorem)

**Proof Strategy**: For abelian groups, the minimum faithful representation dimension equals the number of invariant factors, and the number of maximal subgroups can be computed from the prime factorization. Verify the formula for abelian groups first, then extend to nilpotent groups using Clifford theory.

**Domain Bridges**: Algebra (group classification, periodic table) <-> Physics (representation theory of symmetry groups) <-> EML (ensemble complexity connects to representation dimensions)

**Lineage**: Extends this cycle's reactivityIndex and abelian_maximal_reactivity

**Ambition**: extension

---

### Direction 4: Computational Enumeration — The Group Census

**Conjecture**: Among all groups of order n, the fraction belonging to the Noble Gas family approaches 0 as n → ∞ through highly composite numbers (numbers with many small prime factors), while the fraction of Alkali Metals approaches 1. Specifically, for n = 2^k, at least (1 − 1/k) of all groups of order n are Alkali Metals (nilpotent non-abelian).

**Test**: Use the known enumeration of groups of order 2^k for k ≤ 9 (order 512, where there are 10,494,213 groups). Compute the fraction in each family. If the Alkali Metal fraction is not monotonically increasing with k, the conjecture is false.

**Impact**: This would quantify the "abundance" of each family, showing that the universe of finite groups is overwhelmingly dominated by nilpotent groups — a striking structural result analogous to the abundance of hydrogen in the real universe.

**Catalog References**: `Applications/PeriodicTableCore.lean` (pGroup_family_classification: p-groups are Noble Gas or Alkali Metal)

**Proof Strategy**: For 2-groups, all groups are nilpotent (by p-group nilpotency theorem, already formalized as pGroup_is_nilpotent'). The fraction that are abelian can be estimated using the theory of abelian p-groups: there are p(k) abelian groups of order p^k (where p(k) is the partition function), but the total number of groups grows much faster (as p^{(2/27)k³ + O(k^{8/3})} by Higman-Sims). Thus the Noble Gas fraction → 0.

**Domain Bridges**: Algebra (group classification) <-> Computation (algorithmic enumeration) <-> EML (ensemble complexity of group families)

**Lineage**: Extends this cycle's pGroup_family_classification and nilpotent_family_classification

**Ambition**: extension

---

### Direction 5: The Frattini Quotient as Electron Configuration

**Conjecture**: The Frattini quotient G/Φ(G) (where Φ(G) is the intersection of all maximal subgroups) determines the family classification: G is a Noble Gas iff G/Φ(G) is elementary abelian, an Alkali Metal iff G/Φ(G) is non-abelian but nilpotent of class ≤ 2, and the Frattini quotient structure provides finer sub-family information analogous to electron shell configuration.

**Test**: Compute Φ(G) and G/Φ(G) for all groups of order ≤ 100. Verify that the claimed correspondence between Frattini quotient structure and family holds. A single counterexample (e.g., a non-abelian group with elementary abelian Frattini quotient that is NOT a Noble Gas) would disprove the "Noble Gas" part.

**Impact**: The Frattini quotient is computable and well-studied. If it determines the family, it provides an efficient "fingerprint" for classification — compute the Frattini quotient (polynomial time) rather than the full derived/lower central series.

**Catalog References**: `Applications/PeriodicTableCore.lean` (classifyFamily), `Applications/PeriodicTableAdvanced.lean` (hierarchy_nobleGas_implies_nilpotent)

**Proof Strategy**: The key fact is Burnside's basis theorem: for p-groups, G/Φ(G) is an elementary abelian p-group whose rank equals the minimum number of generators of G. For general nilpotent groups, use the decomposition into Sylow subgroups. For solvable non-nilpotent groups, the Frattini quotient structure is more complex and may require case analysis.

**Domain Bridges**: Algebra (group theory, Frattini subgroup) <-> Cryptography (the Frattini quotient structure affects the hardness of the discrete log problem in group-based cryptosystems)

**Lineage**: Extends this cycle's family classification and center_eq_top_iff_nobleGas

**Ambition**: extension
