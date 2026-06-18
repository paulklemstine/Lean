# Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established a chemical classification framework for finite groups, organizing them into six "chemical families" (Noble Gas, Alkali Metal, Alkaline Earth, Transition Metal, Halogen, Radioactive) based on their structural properties (cyclicity, nilpotency, solvability, simplicity). We proved nine theorems formalizing the analogy: the derived series is antitone, products decompose predictably, minimal normal subgroups of abelian groups are simple, and the "isotope conjecture" (same order → same derived length) is false.

The most promising cross-domain connection is between **group valence** (number of minimal normal subgroups) and **extension theory** (the study of how groups are built from composition factors). The valence measures "bonding capacity" — how many independent ways a group can be extended. This connects to group cohomology (H²(Q, N) classifies extensions), to the lattice structure of normal subgroups (explored in Catalog `Bridges/AlgebraEMLClosureComputation.lean`), and to computational complexity (counting extensions is at least as hard as counting groups of a given order).

The highest breakthrough potential lies in Direction 1: formalizing the relationship between valence and cohomological dimension. If the valence can be shown to bound or determine the second cohomology group, it would provide a concrete, computable invariant for predicting the number of extensions — the group-theoretic equivalent of predicting chemical reactions from valence electrons.

---

### Direction 1: Valence-Cohomology Bridge

**Conjecture**: For a finite group G with valence v(G) (number of minimal normal subgroups), the rank of H²(G, ℤ) (second integral cohomology) satisfies rank(H²(G, ℤ)) ≥ v(G) - 1. In particular, groups with high valence have rich extension structure.

**Test**: Compute v(G) and H²(G, ℤ) for all groups of order ≤ 30 using GAP or Magma. Check if the inequality holds. A single counterexample disproves it.

**Impact**: If true, this provides a computable lower bound on cohomological complexity from a purely combinatorial invariant. This would make the "bonding capacity" analogy precise: valence would predict not just how many bonds are possible, but how many distinct bond types exist. If false, the failure reveals which structural features of minimal normal subgroups are invisible to cohomology.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (closure systems and lattice structure), `Bridges/ClosureCapacitySecretSharingDuality.lean` (capacity realization theorems)

**Proof Strategy**: First, establish that each minimal normal subgroup N_i defines an independent class in H²(G/N_i, N_i) via the extension it represents. Second, show these classes are linearly independent in H²(G, ℤ) via the universal coefficient theorem. The key lemma is that minimal normal subgroups have trivial pairwise intersection (need to prove: if N₁ ∩ N₂ ≠ {1} with both minimal normal, then N₁ = N₂).

**Domain Bridges**: Group cohomology <-> Lattice theory of normal subgroups <-> Closure capacity (Bridges catalog)

**Lineage**: Builds on this cycle's definition of `Subgroup.IsMinNormal` and `groupValence`, and on the theorem `minNormal_of_comm_is_simple`.

**Ambition**: grand_challenge

---

### Direction 2: Derived Length Bounds from Composition Factor Multiplicity

**Conjecture**: For a solvable finite group G of order p₁^{a₁} · p₂^{a₂} · ... · pₖ^{aₖ}, the derived length d(G) satisfies d(G) ≤ a₁ + a₂ + ... + aₖ (the total number of composition factors). Furthermore, this bound is tight: for each signature (a₁, ..., aₖ), there exists a group achieving d(G) = a₁ + ... + aₖ.

**Test**: For orders n ≤ 100, compute the derived length of all solvable groups (using GAP) and compare with Ω(n) = sum of prime factor multiplicities. Check if d(G) ≤ Ω(n) always holds and if equality is achieved.

**Impact**: If true, this gives a sharp universal bound on derived length in terms of order alone — a "spectroscopic" prediction from "atomic mass." The tightness claim is harder and would require constructing explicit groups with maximal derived length. If the bound holds but is not tight, the gap reveals structural constraints on solvable group extensions.

**Catalog References**: `Algebra/FutureExploration.lean` (symmetric_group_order), `Novelty/CollatzSpectral/Theorems.lean` (spectral bounds)

**Proof Strategy**: The upper bound d(G) ≤ Ω(|G|) follows from the fact that each step of the derived series reduces the composition length by at least one factor (since the quotient G⁽ⁿ⁾/G⁽ⁿ⁺¹⁾ is abelian and its composition factors are a subset of G's). For tightness, construct iterated wreath products: Cₚ₁ ≀ Cₚ₂ ≀ ... ≀ Cₚₖ has derived length exactly k = Ω(n).

**Domain Bridges**: Derived series bounds <-> Composition factor theory <-> Spectral analysis (CollatzSpectral)

**Lineage**: Builds on this cycle's `derivedSeries_antitone'`, `derivedSeries_prod`, and `commutator_mem_derivedSeries_succ`.

**Ambition**: extension

---

### Direction 3: The Periodic Law for Nilpotency Class

**Conjecture**: Two finite p-groups of the same order p^n and the same nilpotency class c have isomorphic lower central series quotients γᵢ(G)/γᵢ₊₁(G) (as abelian groups) if and only if they have the same "Lazard signature" — the sequence of ranks (dim over 𝔽ₚ) of these quotients.

**Test**: Enumerate all groups of order p^n for p = 2, n ≤ 6 (there are 267 groups of order 64). Compute the Lazard signature for each and check if it determines the lower central series quotients up to isomorphism.

**Impact**: If true, this gives a computable invariant that captures the "periodic law" for nilpotent groups: groups with the same Lazard signature are in the same "column" of the nilpotent sub-table. This would extend our periodic table from solvability (binary) to nilpotency class (integer-valued) to Lazard signature (sequence-valued), providing increasingly fine chemical classification. If false, it reveals that the "bonding structure" of p-groups is richer than can be captured by any sequence of ranks.

**Catalog References**: `Algebra/Advanced.lean` (iterative algebraic structures)

**Proof Strategy**: Work in the category of graded Lie algebras over 𝔽ₚ. The lower central series quotients form a graded Lie algebra L(G). The conjecture asserts that dim(Lᵢ(G)) determines Lᵢ(G) as an abelian group. This is true for free nilpotent groups (by the Witt formula) but may fail for quotients. Key test: compare the two groups of order 8 (D₄ and Q₈) which both have class 2 — do they have the same Lazard signature?

**Domain Bridges**: Nilpotent groups <-> Graded Lie algebras <-> Combinatorics of partitions

**Lineage**: Builds on this cycle's chemical family classification (AlkaliMetal = nilpotent) and derived series analysis.

**Ambition**: grand_challenge

---

### Direction 4: Computational Complexity of Chemical Classification

**Conjecture**: Determining the GroupChemicalFamily of a finite group given by its Cayley table can be done in polynomial time (in the group order n), but determining the exact valence is #P-hard.

**Test**: Implement the classification algorithm and measure runtime scaling for groups of order n = 2, 4, 8, 16, ..., 256. For valence computation, attempt to reduce the problem of counting maximal independent sets in a graph (known #P-complete) to counting minimal normal subgroups.

**Impact**: If true, this establishes a computational complexity hierarchy within the periodic table: "reading the row and column" is easy, but "counting bonds" is hard. This would explain why group enumeration is so difficult — it's not just that there are many groups, but that their most interesting structural invariants are computationally intractable. If the valence turns out to be polynomial-time computable, it would provide a practical tool for group classification.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (algorithmic complexity in algebraic settings), `Computation/GravityOracle.lean` (oracle complexity)

**Proof Strategy**: For the polynomial-time classification: cyclicity is checkable in O(n) by testing if any element generates G; nilpotency by computing the center in O(n²) and iterating; solvability by computing the derived series in O(n³ log n). For #P-hardness of valence: reduce from the problem of counting minimal transversals of a hypergraph (known #P-complete) by encoding the hypergraph as a group's normal subgroup lattice.

**Domain Bridges**: Group classification <-> Computational complexity <-> Oracle computation (Computation catalog)

**Lineage**: Builds on this cycle's algorithms (classification, derived series, valence computation) and the GroupChemicalFamily definition.

**Ambition**: extension

---

### Direction 5: Extension Prediction — The "Bonding" Problem

**Conjecture**: For two finite groups N and Q with gcd(|N|, |Q|) = 1 (coprime orders), the number of non-isomorphic groups G with a normal subgroup isomorphic to N and quotient G/N ≅ Q is determined by |Aut(N)| and the action of Q on N. Specifically, this count equals the number of orbits of Hom(Q, Aut(N)) under conjugation by Aut(N), which gives exactly the number of non-isomorphic semidirect products N ⋊ Q.

**Test**: For N = ℤ/7ℤ and Q = ℤ/3ℤ, compute |Aut(ℤ/7ℤ)| = 6, and the homomorphisms ℤ/3ℤ → Aut(ℤ/7ℤ) ≅ ℤ/6ℤ. There should be exactly 2 orbits (trivial and non-trivial action), giving exactly 2 groups of order 21 (ℤ/21ℤ and the non-abelian group). Verify with GAP.

**Impact**: If true (which it is, by the Schur-Zassenhaus theorem for the coprime case), this provides a concrete "bonding rule": the number of ways two "atoms" (simple groups) can combine is determined by their symmetries. This is the closest group-theoretic analogue to chemical bonding rules. The real challenge is extending this to the non-coprime case, where extensions are classified by H²(Q, N) and the problem becomes cohomological.

**Catalog References**: `Cryptography/BerggrenGroupoidOrbit.lean` (orbit-based classification), `Algebra/Basic.lean`

**Proof Strategy**: The coprime case follows from Schur-Zassenhaus (all extensions split) plus the classification of semidirect products by orbits of Hom(Q, Aut(N)). Formalize the bijection between isomorphism classes of split extensions and conjugacy classes of homomorphisms Q → Aut(N). The key Mathlib ingredients are `MulSemidirectProduct`, `MulAut`, and `Fintype.card_quotient_right_action`.

**Domain Bridges**: Extension theory <-> Group cohomology <-> Orbit counting (Burnside's lemma) <-> Cryptographic group actions

**Lineage**: Builds on this cycle's `derivedSeries_prod`, `solvable_prod_of_solvable`, and the chemical bonding analogy.

**Ambition**: extension
