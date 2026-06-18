# Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the foundational framework for a "periodic table" classification of finite groups, proving twelve core theorems that formalize structural invariants based on the derived series. The key results are: (1) the derived series decomposes over direct products, enabling compositional analysis; (2) derived length is monotone under surjective homomorphisms (quotients), establishing that "chemical complexity" can only decrease under projection; and (3) the product lower bound theorem shows that combining groups preserves the complexity of the least "stable" factor.

The most promising cross-domain connection is the **Euler-Group Bridge**, which establishes an exact identity between Euler's totient function φ(n) and the order of the unit group (ℤ/nℤ)ˣ. This bridge has immediate applications to cryptography (RSA key generation), coding theory (cyclic code existence), and algorithmic number theory (primality testing via group-theoretic methods). The bridge extends naturally to the multiplicative structure: φ(mn) = φ(m)φ(n) for coprime m,n corresponds to the Chinese Remainder Theorem decomposition of unit groups.

The highest breakthrough potential lies in **Direction 1** (formalizing Burnside's p^a q^b theorem), which would close the most significant gap in our formal development and demonstrate that deep character-theoretic results can be machine-verified. **Direction 3** (the representation-solvability bridge) has the highest impact for cross-domain applications, connecting group-theoretic invariants to concrete computational predictions about representation complexity.

---

### Direction 1: Formalizing Burnside's p^a q^b Theorem

**Conjecture**: Every finite group whose order has the form p^a · q^b, where p and q are primes, is solvable.

**Test**: Attempt to formalize the character-theoretic proof of Burnside's theorem in Lean 4. The key steps are:
1. Define class functions and characters of finite groups.
2. Prove that the number of elements in a conjugacy class divides the group order.
3. Prove Burnside's lemma: if a conjugacy class has p^a elements for a prime p, then the class is represented in any nontrivial irreducible representation by a scalar or zero matrix.
4. Derive solvability from the character-theoretic structure.

A successful formalization would be verified by `lake build` with no sorry statements. Failure to formalize within the available Mathlib infrastructure would identify specific gaps in the character theory library.

**Impact**: This would be the first formal verification of Burnside's theorem in any proof assistant, demonstrating that deep finite group theory can be machine-checked. It would also establish infrastructure (character theory, class functions) reusable for many other results.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (pGroup_is_nilpotent_is_solvable, derivedLength_quotient_le), `Algebra/GroupSolvability.lean` (solvable_iff_derivedSeries_eq_bot)

**Proof Strategy**: The classical proof uses character theory. An alternative approach via transfer theory (Bender-Glauberman) avoids characters but requires the transfer homomorphism and the focal subgroup theorem. A third approach: prove it first for groups of order pq (Sylow + semidirect classification), then p^2·q (Sylow counting), building incrementally. The general case requires one of the deep approaches.

**Domain Bridges**: Algebra <-> Representation Theory, GroupTheory <-> NumberTheory

**Lineage**: Builds on pGroup_is_nilpotent_is_solvable (this cycle) and the existing Mathlib API for Sylow subgroups. Extends the solvability classification from p-groups to two-prime groups.

**Ambition**: grand_challenge

---

### Direction 2: Derived Length Equals Max for Products

**Conjecture**: For finite solvable groups G and H, the derived length of G × H equals exactly max(dL(G), dL(H)).

**Test**: 
1. Formally prove the upper bound: dL(G × H) ≤ max(dL(G), dL(H)), using the product decomposition theorem (derivedSeries_prod').
2. Combine with the lower bound (derived_length_product_lower_bound, proved this cycle) to get equality.
3. Verify computationally using GAP for all pairs of groups with |G|, |H| ≤ 60.

The upper bound proof requires showing: if both G^(n) = {e} and H^(n) = {e}, then (G×H)^(n) = G^(n) × H^(n) = {e} × {e} = {e}. This should follow directly from derivedSeries_prod'.

**Impact**: This would establish derived length as a "stable" invariant under products — it behaves like a lattice supremum, not a sum. This is a key structural property for the periodic table: the "period" of a compound is determined by the most complex component, not by accumulation.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (derivedSeries_prod', derived_length_product_lower_bound)

**Proof Strategy**: The upper bound is straightforward from derivedSeries_prod'. Let n = max(dL(G), dL(H)). Then G^(n) = ⊥ (since n ≥ dL(G)) and H^(n) = ⊥ (since n ≥ dL(H)), so (G×H)^(n) = G^(n) × H^(n) = ⊥. Hence dL(G×H) ≤ n. Combined with the lower bound, we get equality. The formal proof needs careful handling of Nat.find and the product decomposition.

**Domain Bridges**: Algebra <-> Combinatorics (lattice theory)

**Lineage**: Direct extension of derivedSeries_prod' and derived_length_product_lower_bound from this cycle.

**Ambition**: extension

---

### Direction 3: Representation-Solvability Bridge

**Conjecture**: For a finite solvable group G of derived length d, any faithful representation of G over an algebraically closed field of characteristic 0 decomposes into at most 2^d irreducible components.

**Test**:
1. Compute character tables for all solvable groups of order ≤ 100 using GAP.
2. For each group, find the minimum number of irreducible components in a faithful representation.
3. Check whether this number is bounded by 2^(derived length).
4. If the bound holds, attempt to prove it using Clifford theory and the derived series structure.

**Impact**: If true, this would provide a quantitative bridge between group-theoretic invariants (derived length) and representation-theoretic complexity (decomposition width). This has applications to:
- **Molecular spectroscopy**: The number of selection rules for a molecule with symmetry group G
- **Coding theory**: The number of distinct cyclic codes over a field with automorphism group G
- **Quantum computing**: The decomposition complexity of group-theoretic quantum algorithms

If false, the failure mode would reveal which groups violate the bound, potentially identifying a new structural invariant that refines derived length.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (SolvabilitySpectrum, comm_group_derived_series_stable), `Algebra/FutureExploration.lean` (symmetric_group_order)

**Proof Strategy**: Use Clifford theory, which relates representations of G to representations of a normal subgroup N and the quotient G/N. Apply this inductively along the derived series: at each step, the number of components can at most double (since the quotient is abelian and abelian groups have one-dimensional irreducibles). This gives the 2^d bound.

**Domain Bridges**: Algebra <-> Physics (spectroscopy), GroupTheory <-> RepresentationTheory

**Lineage**: Builds on the solvability spectrum framework from this cycle. Extends the chemical analogy by connecting "derived length" (the period number) to observable physical quantities (spectral complexity).

**Ambition**: grand_challenge

---

### Direction 4: Computational Periodic Table Database

**Conjecture**: A complete classification of all groups of order ≤ 500 by their solvability spectrum (derived length, nilpotency class, group valence) can be computed and organized into an interactive periodic table, with each "element" annotated by its applications in cryptography, coding theory, and molecular symmetry.

**Test**:
1. Use GAP's SmallGroup library to enumerate all groups of order ≤ 500.
2. Compute derived length, nilpotency class, and number of maximal normal subgroups for each group.
3. Organize into a table with rows indexed by derived length and columns by order.
4. Identify patterns: Do groups with the same solvability spectrum share representation-theoretic properties? Do they have similar automorphism groups?

**Impact**: This database would serve as a reference for researchers selecting groups for applications. For example, a cryptographer designing a protocol needs a group with specific structural properties (cyclic unit group of large prime order); the periodic table would allow them to search by chemical series and structural invariants.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (SolvabilitySpectrum, groupValence), `Algebra/Core/OpenQuestions.lean` (dlp_order_connection)

**Proof Strategy**: Primarily computational. Use GAP for group enumeration and structure computation. Formalize selected entries in Lean 4 to verify key classification results. Focus on identifying "Mendeleev-style" gaps: orders where no group exists with a particular solvability spectrum, suggesting structural constraints.

**Domain Bridges**: Algebra <-> Computer Science (database design), GroupTheory <-> Cryptography

**Lineage**: Extends the classification framework established this cycle. Uses groupValence and SolvabilitySpectrum definitions directly.

**Ambition**: extension

---

### Direction 5: Solvability Obstruction via Commutator Width

**Conjecture**: For a finite group G, define the **commutator width** cw(G) as the minimum number of commutators needed to express every element of [G, G] as a product of commutators. Then: G is solvable if and only if the sequence cw(G^(0)), cw(G^(1)), cw(G^(2)), ... is eventually zero.

Furthermore, for solvable groups: cw(G^(k)) ≤ cw(G^(k-1)) for all k (the commutator width is non-increasing along the derived series).

**Test**:
1. Compute commutator widths for all groups of order ≤ 100 using exhaustive search.
2. Verify the non-increasing property for solvable groups.
3. Check whether the commutator width sequence provides finer discrimination than derived length alone.
4. For non-solvable groups, verify that the commutator width sequence stabilizes at a positive value.

**Impact**: Commutator width is a quantitative measure of "how non-abelian" a group is at each level of the derived series. If the non-increasing property holds, it provides a new structural invariant for the periodic table that captures information about the "rate of abelianization" — how quickly a group becomes commutative as you descend the derived series.

If the conjecture is false, the counterexample would identify groups where the commutator structure becomes more complex at deeper levels of the derived series, a phenomenon not captured by current invariants.

**Catalog References**: `Algebra/PeriodicTable/DeepStructure.lean` (derivedSeries_prod', comm_group_derived_series_stable), `Algebra/GroupSolvability.lean` (derivedSeries_succ_eq_commutator)

**Proof Strategy**: For the forward direction (solvable ⟹ eventually zero), this is immediate from the definition. For the non-increasing property, use the fact that G^(k+1) = [G^(k), G^(k)] is generated by commutators of G^(k), and the commutator map from G^(k) × G^(k) to G^(k+1) is surjective. The key technical challenge is showing that if every element of G^(k) is a product of m commutators, then every element of G^(k+1) can be expressed as a product of at most m commutators in the ambient group.

**Domain Bridges**: Algebra <-> Combinatorics (word length in groups), GroupTheory <-> GeometricGroupTheory

**Lineage**: New direction building on the derived series framework. Introduces a quantitative refinement (commutator width) to the qualitative classification (solvable/non-solvable).

**Ambition**: extension
