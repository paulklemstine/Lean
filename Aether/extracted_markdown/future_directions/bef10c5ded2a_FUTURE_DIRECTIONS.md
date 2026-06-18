# Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established a rigorous foundation for classifying finite groups using a chemical analogy, proving sixteen theorems that formalize the "periodic table" framework. The most significant results are the **Quantitative Periodic Law** (d(G) ≤ log₂|G|), which provides a universal complexity bound for solvable groups, and the **Solvable Extension Theorem**, which shows that solvability is closed under group extensions — the algebraic analogue of chemical synthesis.

The strongest cross-domain connection emerged between the **derived–central series inequality** and **number-theoretic bounds on Euler's totient**. Both results express the same meta-principle: structural complexity is bounded by size. In number theory, φ(n) ≤ n − 1 bounds the "reactive units"; in group theory, d(G) ≤ log₂|G| bounds the "decomposition depth." The bridge through (ℤ/nℤ)× — where the unit group order equals the totient — makes this connection concrete.

The highest breakthrough potential lies in **Direction 1** (Hall's Exponential Refinement), which would strengthen the derived–central inequality from D_n ≤ γ_n to D_n ≤ γ_{2^n - 1}, yielding d(G) ≤ ⌈log₂(c(G) + 1)⌉ — an exponential improvement. This requires formalizing the Three Subgroups Lemma, which would also unlock numerous other group-theoretic results in Mathlib.

---

### Direction 1: Hall's Exponential Refinement of the Derived–Central Inequality

**Conjecture**: For any group G and natural number n, D_n(G) ≤ γ_{2^n - 1}(G), where D_n denotes the n-th derived subgroup and γ_k the k-th term of the lower central series (0-indexed, with γ_0 = G).

**Test**: Prove the Three Subgroups Lemma first: if N ◁ G and [[A,B],C] ≤ N and [[B,C],A] ≤ N, then [[C,A],B] ≤ N. Then derive Hall's commutator identity [γ_i, γ_j] ≤ γ_{i+j+1}. Finally, prove D_n ≤ γ_{2^n-1} by induction: D_{n+1} = [D_n, D_n] ≤ [γ_{2^n-1}, γ_{2^n-1}] ≤ γ_{2(2^n-1)+1} = γ_{2^{n+1}-1}.

**Impact**: If true, this yields d(G) ≤ ⌈log₂(c(G) + 1)⌉ for nilpotent groups — an exponential improvement over the current d(G) ≤ c(G). This would precisely quantify the "efficiency gap" between the derived and central series. If false (the Three Subgroups Lemma fails in some generalized setting), it would reveal fundamental limitations of commutator identities.

**Catalog References**: `derivedSeries_le_lowerCentralSeries` (Catalog/EML/PeriodicTableGroups.lean), `derivedDepth_le_nilpotencyClass` (Catalog/EML/PeriodicTableGroups.lean), `derivedSeries_le_lowerCentral` (Applications/PeriodicTable/Core.lean)

**Proof Strategy**:
1. Formalize the Three Subgroups Lemma (P. Hall, 1935) in Lean 4
2. Derive [γ_i, γ_j] ≤ γ_{i+j+1} by induction on i using the Three Subgroups Lemma
3. Prove D_n ≤ γ_{2^n-1} by induction on n
4. Derive the logarithmic bound d(G) ≤ ⌈log₂(c(G)+1)⌉

**Domain Bridges**: Group Theory ↔ Combinatorics (the bound 2^n - 1 connects to binary tree depth, suggesting a combinatorial interpretation of derived series)

**Lineage**: Extends `derivedSeries_le_lowerCentral` from this cycle and `derivedDepth_le_nilpotencyClass` from the catalog.

**Ambition**: grand_challenge

---

### Direction 2: Burnside's p^a q^b Theorem — Formalizing Character Theory

**Conjecture**: Every finite group whose order has at most two distinct prime factors is solvable. Formally: if |G| = p^a · q^b for primes p, q, then G is solvable.

**Test**: Formalize enough character theory (irreducible representations, orthogonality relations, Burnside's transfer theorem) to prove this. The key lemma is: if a conjugacy class has p^k elements (prime power size), then every irreducible character either vanishes on this class or the class is in the kernel of the representation.

**Impact**: This would be a landmark formalization — Burnside's theorem is one of the deep results in finite group theory (1904), and its proof was the first major application of character theory to pure group theory. A formal proof would demonstrate that character-theoretic methods are now within reach of proof assistants. If character theory proves too difficult to formalize, an alternative approach via the Feit-Thompson theorem (groups of odd order are solvable) could be attempted for the special case q = 2.

**Catalog References**: `fitting_nontrivial_of_solvable` (Applications/PeriodicTable/Core.lean), `solvable_of_extension` (Applications/PeriodicTable/Core.lean)

**Proof Strategy**:
1. Define group representations and characters in Lean 4
2. Prove Schur's lemma and character orthogonality
3. Prove Burnside's key lemma about prime power conjugacy classes
4. Derive the p^a q^b theorem

**Domain Bridges**: Group Theory ↔ Representation Theory ↔ Linear Algebra (characters are traces of matrix representations)

**Lineage**: Extends `fitting_nontrivial_of_solvable` and the solvability framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Socle Structure Theorem — Decomposing the Nuclear Core

**Conjecture**: The socle of a finite group (the subgroup generated by all minimal normal subgroups) decomposes as a direct product of simple groups. Moreover, if G is a finite group with socle S, then S = S₁ × S₂ × ... × S_k where each S_i is simple, and k = v(G) (the group valence).

**Test**: Prove that (1) every minimal normal subgroup of a finite group is a direct product of isomorphic simple groups, (2) distinct minimal normal subgroups commute elementwise, and (3) their join is their direct product.

**Impact**: This would formalize the structure theory of the socle, which is fundamental to the study of primitive permutation groups and the O'Nan-Scott theorem. It would validate the "valence = number of simple direct factors in the socle" interpretation of our chemical analogy. If the decomposition fails in some infinite group setting, it would delineate where the analogy breaks.

**Catalog References**: `simple_group_valence` (Applications/PeriodicTable/Core.lean), `simple_group_valence_eq_one` (EML/PeriodicTableGroups.lean)

**Proof Strategy**:
1. Show minimal normal subgroups are characteristically simple
2. Prove that characteristically simple groups are direct products of isomorphic simple groups
3. Show distinct minimal normal subgroups centralize each other
4. Conclude the direct product decomposition of the socle

**Domain Bridges**: Group Theory ↔ Lattice Theory (the normal subgroup lattice determines the socle structure)

**Lineage**: Extends `simple_group_valence` from this cycle.

**Ambition**: extension

---

### Direction 4: The Supersolvability Gap — A New Chemical Family

**Conjecture**: There exists a natural strict hierarchy: Nilpotent ⊂ Supersolvable ⊂ Solvable, where supersolvable means having a normal series with cyclic quotients. The group A₄ (alternating group on 4 elements) is solvable but not supersolvable, providing the witness for strict inclusion at the upper end.

**Test**: Define supersolvability in Lean 4, prove that nilpotent groups are supersolvable, that supersolvable groups are solvable, and exhibit A₄ as a solvable non-supersolvable group. Then prove: the derived depth of a supersolvable group equals its number of distinct prime factors (a sharper bound than log₂|G|).

**Impact**: This would add a new "chemical family" — a "metalloid" between lanthanides and compounds — giving finer resolution to the periodic table. The sharper derived depth bound for supersolvable groups would be a genuine novelty, not currently in the literature in this form.

**Catalog References**: `quantitative_periodic_law` (Applications/PeriodicTable/Core.lean), `derivedDepth_prod_eq_max` (Applications/PeriodicTable/Core.lean)

**Proof Strategy**:
1. Define `IsSuperSolvable G` in Lean 4
2. Prove nilpotent → supersolvable using the upper central series
3. Prove supersolvable → solvable (by definition)
4. Show A₄ is not supersolvable (V₄ is its only normal subgroup of order 4, and V₄ is not cyclic)
5. Prove the refined derived depth bound for supersolvable groups

**Domain Bridges**: Group Theory ↔ Number Theory (the bound involves counting distinct prime factors ω(n), connecting to the Erdős-Kac theorem on the normal distribution of ω)

**Lineage**: Extends the stability hierarchy from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Group Theory — Min-Plus Solvability

**Conjecture**: The concept of "solvability" for groups has a natural analogue in tropical algebra. Define a "tropical group" as a set with a min-plus structure, and define "tropical solvability" via iterated tropical commutators. Then: every finite tropical group (in a suitable sense) is tropically solvable, providing a tropical analogue of the Feit-Thompson theorem.

**Test**: Formalize tropical groups (sets with min and addition satisfying group-like axioms), define tropical commutators [a,b]_trop = min(a+b, b+a) - min(a,b), and prove that the tropical derived series always terminates for finite structures.

**Impact**: This would establish the first connection between tropical mathematics and group solvability theory, opening a new domain of "tropical group theory." If tropical solvability is trivially true (all finite structures are solvable), the interesting question becomes: what is the tropical analogue of derived depth, and how does it relate to tropical geometry?

**Catalog References**: `TropicalSatakeTop2Margin` (Bridges/TropicalSatakeTop2Margin.lean), `finite_test_family_zero_GL3` (Tropical/GL3FiniteTestFamily.lean)

**Proof Strategy**:
1. Define tropical group structures compatible with Mathlib's tropical semiring
2. Define tropical commutators and derived series
3. Prove termination for finite tropical groups
4. Connect to the existing tropical Satake isomorphism framework

**Domain Bridges**: Group Theory ↔ Tropical Geometry ↔ Optimization (tropical solvability connects to min-plus linear algebra and shortest path algorithms)

**Lineage**: Bridges the periodic table framework with the Tropical Satake thread from the catalog.

**Ambition**: extension
