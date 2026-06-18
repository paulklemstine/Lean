# Future Research Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the foundational mathematical framework for a "periodic table" of finite groups, drawing rigorous parallels between chemical properties and group-theoretic invariants. The core achievement is the **Derived–Central Series Inequality** — the fact that the derived series decays at least as fast as the lower central series — which provides the fundamental structural bound governing the relationship between nilpotency class and derived depth. This, combined with the **Product Decomposition Theorem** for derived series and the characterization of simple group valence, gives us a working chemical-algebraic dictionary backed by machine-verified proofs.

The most promising cross-domain connection identified is between **group valence** (minimal normal subgroup count) and **representation theory**. The socle of a finite group — the join of its minimal normal subgroups — is closely related to the socle in module theory, and its structure constrains the character table. A fruitful direction would connect group valence to the number of irreducible representations or to the structure of the Burnside ring. Additionally, the **Refined Periodic Law Conjecture** (derivedDepth ≤ Ω(|G|)) remains open and is testable via computational group theory libraries.

The direction with highest breakthrough potential is **Direction 1** (Quantitative Periodic Law), because it combines a precise falsifiable conjecture with connections to deep results about p-group structure and iterated wreath products. A proof would yield a fundamental constraint on solvable group complexity; a counterexample would reveal new phenomena in how derived series can concentrate depth.

---

### Direction 1: Quantitative Periodic Law for Solvable Groups

**Conjecture**: For every nontrivial finite solvable group G, the derived depth (smallest n with G^(n) = 1) satisfies derivedDepth(G) ≤ Ω(|G|), where Ω(n) is the number of prime factors of n counted with multiplicity.

**Test**: Verify computationally for all solvable groups of order ≤ 500 using GAP or Magma. The critical test cases are iterated wreath products C_p ≀ C_p ≀ ... ≀ C_p, which maximize derived depth for their order. For k-fold wreath product of C_p, the order is p^{p^{k-1} + p^{k-2} + ... + 1} and derived depth is k. Check that k ≤ Ω(order) = p^{k-1} + ... + 1.

**Impact**: If true, this establishes that the prime factorization of group order is a hard ceiling on structural complexity for solvable groups, analogous to how atomic number constrains chemical behavior. If false, the counterexample reveals a new class of "hyperreactive" solvable groups whose complexity exceeds their prime budget.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (derivedDepth, bigOmega, periodic_law_conjecture), `Catalog/Algebra/GroupSolvability.lean` (solvable_iff_derivedSeries_eq_bot)

**Proof Strategy**: For p-groups, use induction on the order: if G is a p-group of order p^k, then G/Z(G) has order p^{k-c} where c ≥ 1 (by the p-group center theorem), so by induction on k, derivedDepth(G/Z(G)) ≤ k - c ≤ k - 1. The derived depth of G is at most 1 + derivedDepth(G/Z(G)), but this only gives k, and we need k = Ω(p^k). For general solvable groups, use the composition series and the fact that each composition factor contributes one prime to Ω.

**Domain Bridges**: Group theory (derived series) <-> Number theory (prime factorization) <-> Combinatorics (wreath product enumeration)

**Lineage**: Builds on the Derived–Central Series Inequality and p-Group Center Theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Socle Structure and Valence Classification

**Conjecture**: For any finite group G, the socle Soc(G) (join of all minimal normal subgroups) decomposes as a direct product of minimal normal subgroups. Furthermore, each minimal normal subgroup is either elementary abelian or a direct product of isomorphic non-abelian simple groups.

**Test**: Formalize the proof that minimal normal subgroups of a finite group with trivial pairwise intersection have independent join (direct product). Verify the structure theorem for minimal normal subgroups (each is a characteristically simple group, hence a direct power of a simple group).

**Impact**: This would complete the valence theory by showing that the socle has a canonical product decomposition. It would allow defining a "valence electron configuration" for finite groups analogous to the electron configuration of atoms: each minimal normal factor contributes a specific type of "valence electron" (abelian or simple).

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (IsMinimalNormal, GroupValence, groupSocle, simple_group_valence_one)

**Proof Strategy**: First prove that if N₁, N₂ are distinct minimal normal subgroups then N₁ ∩ N₂ = 1 (because N₁ ∩ N₂ is normal and contained in both, hence trivial by minimality). Then prove that the join of normal subgroups with pairwise trivial intersection is their internal direct product. Finally, prove that a characteristically simple group (no proper characteristic subgroups) is a direct product of isomorphic simple groups.

**Domain Bridges**: Group theory (socle) <-> Module theory (socle of a module) <-> Representation theory (semisimple modules)

**Lineage**: Extends simple_group_valence_one and the IsMinimalNormal definition from this cycle.

**Ambition**: extension

---

### Direction 3: Commutator Width as Chemical Activation Energy

**Conjecture**: For a finite perfect group G (one where G = [G,G]), the commutator width cw(G) — the smallest k such that every element of G is a product of k commutators — is bounded by log₂(|G|).

**Test**: Compute commutator width for known perfect groups: A₅ (cw = 1, |A₅| = 60), SL(2,5) (cw = 1, |SL(2,5)| = 120), A₆ (cw = 1, |A₆| = 360). The conjecture predicts cw ≤ 5 for |G| ≤ 32. Test computationally for perfect groups of order ≤ 1000.

**Impact**: Commutator width is the "activation energy" of a group — the minimum number of elementary reactions (commutations) needed to produce any group element. Bounding it by log₂(|G|) would mean that the activation energy grows at most logarithmically with the group size, a strong uniformity result.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (commutator subgroup theory, derivedSeries_prod_eq)

**Proof Strategy**: For simple groups, Ore's conjecture (now a theorem, proved by Liebeck-O'Brien-Shalev-Tiep 2010) states that cw = 1 for all finite non-abelian simple groups. For general perfect groups, use the composition series: if G has a normal subgroup N with G/N simple and N perfect, then cw(G) ≤ cw(G/N) + cw(N) ≤ 1 + cw(N), giving an induction. The length of the composition series is at most log₂(|G|).

**Domain Bridges**: Group theory (commutator width) <-> Chemistry (activation energy) <-> Complexity theory (circuit depth)

**Lineage**: Extends the reactivity framework from this cycle into quantitative territory.

**Ambition**: grand_challenge

---

### Direction 4: Automorphism Group as Chemical Reactivity Coefficient

**Conjecture**: For a finite group G with |G| ≥ 3, the ratio |Aut(G)|/|G| is maximized (among groups of a given order n) by the elementary abelian p-group (Z/pZ)^k when n = p^k is a prime power, with |Aut(G)|/|G| = (p^k - 1)(p^k - p)···(p^k - p^{k-1})/p^k.

**Test**: For order 8: Z/2Z × Z/2Z × Z/2Z has |Aut| = GL(3,2) = 168, ratio 21. D₄ has |Aut| = 8, ratio 1. Q₈ has |Aut| = 24, ratio 3. Z₈ has |Aut| = 4, ratio 0.5. The elementary abelian group wins. Verify for orders 4, 8, 9, 16, 25, 27.

**Impact**: This would identify elementary abelian groups as the "most reactive" groups of prime-power order in the chemical analogy — they have the most automorphisms (symmetries of their internal structure), making them the most "chemically versatile."

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (ChemicalSeries, GroupValence)

**Proof Strategy**: The key insight is that Aut((Z/pZ)^k) = GL(k, F_p), whose order is Π_{i=0}^{k-1}(p^k - p^i). For non-elementary abelian groups of the same order, the automorphism group is smaller because the invariant factor decomposition constrains the automorphisms. For non-abelian groups, the outer automorphism group is typically much smaller. Formal proof would use the structure theorem for automorphism groups of abelian groups.

**Domain Bridges**: Group theory (automorphism groups) <-> Linear algebra (GL(k, F_p)) <-> Chemistry (reactivity coefficients)

**Lineage**: Extends the ChemicalSeries classification by adding a quantitative reactivity measure.

**Ambition**: extension

---

### Direction 5: Tropical Sylow Theory — Optimization on the Group Lattice

**Conjecture**: The subgroup lattice of a finite group G, equipped with the order function (mapping each subgroup H to |H|), admits a tropical (min-plus) semiring structure where the "tropical Sylow subgroups" (subgroups maximizing |H| subject to |H| being a prime power) satisfy a tropical analog of the Sylow theorems.

**Test**: For G = S₄ (order 24), the subgroup lattice has subgroups of orders 1, 2, 3, 4, 6, 8, 12, 24. The tropical 2-Sylow maximum is 8, the tropical 3-Sylow maximum is 3. Check that the tropical Sylow counts (number of subgroups of each maximal prime-power order) satisfy modular constraints analogous to the classical Sylow count theorem.

**Impact**: This would create a bridge between tropical geometry and finite group theory, potentially yielding new computational tools for group classification. Tropical methods have proven powerful in algebraic geometry and combinatorial optimization; applying them to the subgroup lattice could reveal hidden structure.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (cyclic_sylow_unique, sylow_periodicity), `Tropical/` directory in the Catalog

**Proof Strategy**: Define the tropical subgroup lattice as the poset of subgroups with tropical arithmetic (max replaces addition, addition replaces multiplication). The Sylow theorems translate to statements about the maximum element in each "tropical prime component." The key lemma would be that the number of maximal p-subgroups satisfies a modular condition inherited from the classical Sylow count.

**Domain Bridges**: Group theory (Sylow) <-> Tropical geometry (valuations) <-> Optimization (lattice optimization)

**Lineage**: Connects the Sylow theory from this cycle to the Catalog's existing Tropical geometry work.

**Ambition**: extension
