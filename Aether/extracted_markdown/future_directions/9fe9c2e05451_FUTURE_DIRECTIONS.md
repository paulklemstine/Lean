# Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established a rigorous chemical classification framework for finite groups, proving foundational results about center-valence multiplicativity, derived series strict descent, nilpotency class bounds, and solvability extension theory. The most significant cross-domain connection is the **center-quotient recursion**: for nilpotent groups, the nilpotency class equals 1 plus the class of the quotient by the center. This recursive "shell-peeling" structure connects algebraic classification to computational hierarchy theory (each shell removal is a coset-reduction step) and to spectral theory (each shell contributes a "spectral line" to the group's fingerprint).

The cycle's results connect to the broader Catalog through the Galois solvability theory in `Algebra/GroupSolvability.lean` (non-solvability of S₅ as the Abel-Ruffini obstruction) and the existing periodic table framework in `Catalog/Algebra/PeriodicTable/Theorems.lean`. The **solvability extension theorem** — that N ◁ G with both N and G/N solvable implies G solvable — is the most structurally important result, as it governs how the periodic table builds row by row.

The highest breakthrough potential lies in **Direction 1**: formalizing Burnside's p^a q^b theorem via character theory. This would require building character theory infrastructure in Mathlib, which would unlock a vast range of representation-theoretic results. The secondary prize lies in **Direction 3**: connecting the center-valence distribution to number-theoretic functions, which bridges algebra and analytic number theory in a novel way.

---

### Direction 1: Burnside's p^a q^b Theorem via Character Theory

**Conjecture**: Every group whose order has at most two distinct prime divisors is solvable. Formally: if |G| = p^a · q^b for primes p, q and non-negative integers a, b, then G is solvable.

**Test**: The conjecture is already a known theorem (Burnside 1904). The test is whether it can be *formalized* in Lean 4 using Mathlib. Specifically: can we build enough character theory (characters of representations, orthogonality relations, Burnside's transfer theorem) to prove this within Lean 4? A computational test: verify for all groups in GAP's SmallGroups library of order p^a q^b ≤ 1000 that they are solvable.

**Impact**: If formalized, this would be the first machine-verified proof of Burnside's theorem, and would require building character theory infrastructure (irreducible characters, character tables, orthogonality relations) that would unlock dozens of other results: Frobenius's theorem on Frobenius groups, the Feit-Thompson odd-order theorem strategy, and the foundations of the CFSG.

**Catalog References**: `Algebra/PeriodicTable/Theorems.lean` (burnside_pq_conjecture statement), `Catalog/Algebra/GroupSolvability.lean` (solvability infrastructure)

**Proof Strategy**: 
1. Define group representations over ℂ and their characters
2. Prove Schur's lemma and Maschke's theorem (semisimplicity)
3. Establish character orthogonality relations
4. Prove Burnside's lemma on fixed points (already partially in Mathlib)
5. Prove Burnside's p^a q^b theorem using the character-theoretic argument: a non-trivial element in the center of a Sylow subgroup has a character value divisible by q^b/|C_G(g)|, leading to a normal complement

**Domain Bridges**: Algebra (group representations) ↔ Number Theory (character sums) ↔ Computation (character table algorithms)

**Lineage**: Builds on burnside_pq_conjecture from Algebra/PeriodicTable/Theorems.lean and solvability infrastructure from Catalog/Algebra/GroupSolvability.lean

**Ambition**: grand_challenge

---

### Direction 2: Nilpotent Group Decomposition and p-Group Classification

**Conjecture**: For a finite nilpotent group G of order p₁^{a₁} · p₂^{a₂} · ... · pₖ^{aₖ}, the nilpotency class satisfies:
$$\text{class}(G) = \max_i \text{class}(P_i)$$
where Pᵢ are the Sylow pᵢ-subgroups. Moreover, G ≅ P₁ × P₂ × ... × Pₖ (direct product of Sylow subgroups).

**Test**: Formalize the equivalence: a finite group is nilpotent iff it is a direct product of its Sylow subgroups. Then verify that nilpotencyClass_prod (already proved for binary products) extends to arbitrary finite products. Computational test: for all nilpotent groups of order ≤ 100, verify that the nilpotency class equals the max over Sylow subgroups.

**Impact**: This would provide the complete "noble gas + alkali metal" classification: every nilpotent group decomposes uniquely into p-group components, and the p-group structure determines the chemical properties. This reduces the nilpotent classification problem to the p-group classification problem.

**Catalog References**: `Algebra/PeriodicTable/Theorems.lean` (nilpotent_implies_solvable), `Algebra/PeriodicTable/Advanced.lean` (nilpotency_class_lt_card)

**Proof Strategy**:
1. Formalize Sylow's theorems (existence, conjugacy, counting) — partially in Mathlib
2. Prove that in a nilpotent group, all Sylow subgroups are normal (key characterization)
3. Prove that a group with all Sylow subgroups normal decomposes as their direct product
4. Show the nilpotency class of the product equals the max of components (extend our binary result)

**Domain Bridges**: Algebra (Sylow theory) ↔ Combinatorics (orbit counting) ↔ Computation (p-group enumeration algorithms)

**Lineage**: Builds on nilpotent_product, reactivity_product_max, nilpotency_class_lt_card from this cycle

**Ambition**: extension

---

### Direction 3: Center-Valence Distribution and Arithmetic Functions

**Conjecture**: Let f(n) = (1/g(n)) · Σ_{G : |G|=n} |Z(G)| be the average center-valence over all groups of order n, where g(n) is the number of groups of order n. Then:
1. f(p) = p for primes p (only one group, which is abelian)
2. f(p²) = p² (both groups of order p² are abelian)
3. f(p³) < p³ for p ≥ 3 (non-abelian groups of order p³ exist)
4. f(n) / n → 0 as n → ∞ through "generic" orders (most groups have small centers)

**Test**: Compute f(n) for n ≤ 100 using the GAP SmallGroups library. Plot f(n)/n as a function of n. Determine whether the sequence f(n)/n has a limit along primes, prime powers, and general integers.

**Impact**: This would connect the algebraic theory of group centers to analytic number theory. If f(n)/n has an asymptotic distribution, it would provide a quantitative version of the folklore that "most groups are p-groups with small centers." This connects the center-valence invariant from our periodic table to number-theoretic density results.

**Catalog References**: `Algebra/PeriodicTable/Defs.lean` (centerValence definition), `Algebra/PeriodicTable/Advanced.lean` (abelian_maximal_stability)

**Proof Strategy**:
1. For n = p: unique group Z/pZ, center = whole group, so f(p) = p (trivial)
2. For n = p²: two groups (Z/p²Z and Z/pZ × Z/pZ), both abelian, so f(p²) = p²
3. For n = p³: 5 groups (3 abelian, 2 non-abelian with center of order p), so f(p³) = (3p³ + 2p)/5
4. General analysis requires bounds on the number of abelian vs. non-abelian groups of order n

**Domain Bridges**: Algebra (center theory) ↔ Number Theory (arithmetic functions, group counting) ↔ Statistics (distribution of invariants)

**Lineage**: Builds on center_valence_product, abelian_iff_center_is_full, abelian_maximal_stability from this cycle

**Ambition**: extension

---

### Direction 4: Solvable Radical and Chemical Decomposition

**Conjecture**: Every finite group G has a unique maximal solvable normal subgroup R(G) (the *solvable radical*), and the quotient G/R(G) has trivial solvable radical. The chemical decomposition of G is:
$$G = R(G) \rtimes_\varphi Q$$
where Q ≅ G/R(G) is "purely radioactive" (trivial solvable radical) and R(G) is the "solvable part."

**Test**: The existence and uniqueness of R(G) should be provable in Lean 4 using Mathlib's subgroup lattice theory. The semidirect product decomposition is generally false (G need not split), but the exact sequence 1 → R(G) → G → G/R(G) → 1 always exists. Formalize this exact sequence and show that G/R(G) is "semisimple" in the appropriate sense.

**Impact**: This would provide the ultimate chemical decomposition: every group separates into a solvable part (which can be further decomposed via the derived series) and a non-solvable quotient (which is built from simple groups via the CFSG). This is the group-theoretic analogue of separating a chemical sample into organic (solvable) and inorganic (simple) components.

**Catalog References**: `Algebra/PeriodicTable/Theorems.lean` (solvable_of_normal_solvable_quotient), `Catalog/Algebra/GroupSolvability.lean`

**Proof Strategy**:
1. Show that the product of two solvable normal subgroups is solvable and normal
2. Define R(G) as the join (product) of all solvable normal subgroups
3. Prove R(G) is the unique maximal solvable normal subgroup
4. Show R(G/R(G)) = {e} — the quotient has trivial solvable radical
5. Connect to the Schreier refinement theorem and Jordan-Hölder

**Domain Bridges**: Algebra (radical theory) ↔ Ring Theory (Jacobson radical analogy) ↔ Cryptography (hardness from non-solvable quotients)

**Lineage**: Builds on solvable_of_normal_solvable_quotient, solvable_quotient, solvable_subgroup from this cycle

**Ambition**: grand_challenge

---

### Direction 5: Computational Complexity of Chemical Classification

**Conjecture**: Given a finite group G of order n by its multiplication table, the chemical series can be determined in O(n² log n) time, and the full solvability spectrum in O(n³) time. However, determining the exact isomorphism class within a chemical series is at least as hard as graph isomorphism.

**Test**: Implement the classification algorithms and benchmark them on groups of order up to 10,000 (using Cayley table representation). Compare with GAP's group identification algorithm. Formally verify the correctness of the classification algorithm (that it matches the mathematical definitions).

**Impact**: This connects the algebraic classification to computational complexity theory. If the chemical series classification is polynomial but isomorphism testing is GI-hard, this validates the periodic table approach: we can efficiently determine the "column" (chemical series) without solving the harder problem of determining the exact "isotope."

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (algorithmic efficiency framework), `Algebra/PeriodicTable/Defs.lean`

**Proof Strategy**:
1. Prove correctness of the center computation algorithm (O(n²))
2. Prove correctness of the derived series computation (O(n³ per step))
3. Bound the number of steps in the derived series by log₂(n)
4. Establish GI-hardness of isomorphism within a chemical series via reduction

**Domain Bridges**: Algebra (group classification) ↔ Computation (complexity theory, GI-hardness) ↔ Cryptography (group-based cryptosystems)

**Lineage**: Builds on chemical series classification and algorithmic implementations from this cycle

**Ambition**: extension
