# Future Directions: Theory Genome Research Program

## Synthesis

This cycle established the *Theory Genome* framework: the axiom–model correspondence is a Galois connection yielding closure operators, a pseudometric on the space of theories, and a precise characterization of how theory mutations affect model sets. The key structural insight is that the pair (theoryOf, models) satisfies full Galois connection properties including idempotence of both closures, and that the symmetric difference of axiom closures is a pseudometric.

The most promising cross-domain connection is to **Lawvere's functorial semantics** and the existing `derivability_closed_iff_theory_of_observable` theorem in the catalog. Our axiom–model Galois connection is a concrete instance of the same abstract pattern that connects thermodynamic observables to derivable quantities. Upgrading our framework from set-theoretic inclusions to categorical adjunctions would unify these results and connect to the `sequence_preserves_theory` result in Knuth-Bendix completion.

The highest breakthrough potential lies in **Direction 1** (Categorical Genome), which would replace set-theoretic inclusions with genuine functors and natural transformations, yielding a 2-category of theories where the genome distance becomes a categorical invariant. This would make the metaphor of "mathematical DNA" into a precise categorical statement and connect to ongoing work in homotopy type theory on the univalence of theory presentations.

---

### Direction 1: Categorical Theory Genome — From Sets to 2-Categories

**Conjecture**: The Theory Genome framework lifts to a 2-category where:
- 0-cells are theory genomes (axiom sets over a type)
- 1-cells are theory morphisms (axiom-preserving functors)
- 2-cells are natural transformations between induced model functors

Moreover, the genome distance (symmetric difference of axiom closures) is invariant under 2-isomorphism: if two theory morphisms are connected by an invertible 2-cell, they induce the same genome distance.

**Test**: Define the 2-category structure in Lean 4 using Mathlib's `CategoryTheory.Bicategory`. Verify the composition laws and check whether the genome distance descends to the homotopy category (quotient by 2-isomorphisms). A specific test: take the theories of groups, abelian groups, and rings, define morphisms between them, and verify that the triangle inequality for genome distance is sharp (i.e., there exist theories where equality holds).

**Impact**: If true, this would establish that the space of mathematical theories is not just a metric space but a *higher category*, where the morphisms between theories carry non-trivial structure. This would connect the genome framework to homotopy type theory and provide a rigorous foundation for "theory evolution" as a categorical process.

**Catalog References**: `Bridges/LawvereThermodynamicGalois.lean` (derivability_closed_iff_theory_of_observable), `Bridges/KnuthBendixCompletion.lean` (sequence_preserves_theory)

**Proof Strategy**:
1. Define `TheoryGenome.Functor` as a structure-preserving map between theory genomes that includes a map on the underlying types.
2. Define 2-cells as families of model-preserving maps.
3. Prove composition associativity using the existing `morphism_comp` theorem.
4. Prove genome distance invariance using `same_models_same_closure`.

**Domain Bridges**: Category Theory <-> Model Theory <-> Metric Geometry

**Lineage**: Builds on `genome_galois_connection`, `genomeDiff_triangle`, `closed_eq_of_same_models` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative Genome Distance over Finite Theories

**Conjecture**: For theories over a finite type α with |α| = n, the genome distance (measured as cardinality of the symmetric difference of axiom closures) satisfies:
$$d(T_1, T_2) \leq 2^n - |\text{models}(T_1) \cap \text{models}(T_2)|$$
Moreover, this bound is tight: for every n and every value k ≤ 2^n, there exist theories T₁, T₂ over Fin n achieving d(T₁, T₂) = k.

**Test**: Implement the genome distance computation for all theories over Fin 3 (8 elements, 2^8 = 256 possible predicates, but much fewer relevant ones). Enumerate all pairs of theories and compute their genome distances. Verify the bound and check tightness. A computational search in Python/Lean can check this for n ≤ 4.

**Impact**: If true, this provides the first quantitative bounds on theory distance, enabling algorithmic theory comparison. If the bound is not tight, characterizing the gap would reveal structural constraints on how theories can differ. This connects to computational learning theory (concept learning = theory discovery) and information theory (the entropy of the axiom closure).

**Catalog References**: `Speculative/TheoryGenome.lean` (genomeDiff_triangle, extend_models_eq)

**Proof Strategy**:
1. Formalize `Fintype` instances for theory genomes over `Fin n`.
2. Define `genomeDist : TheoryGenome (Fin n) → TheoryGenome (Fin n) → ℕ` as the cardinality of genomeDiff.
3. Prove the upper bound using the fact that axiom closures are subsets of `Set (Fin n → Prop)`.
4. Construct witnessing theories for tightness using characteristic predicates.

**Domain Bridges**: Combinatorics <-> Information Theory <-> Computational Learning Theory

**Lineage**: Builds on `genomeDiff_triangle`, `genomeDiff_self`, `genomeDiff_comm` from this cycle.

**Ambition**: extension

---

### Direction 3: Theory Phylogenetics — Evolutionary Trees of Mathematical Theories

**Conjecture**: The genome distance on the space of finitely axiomatized theories satisfies the *four-point condition* for tree metrics:
$$d(T_1, T_3) + d(T_2, T_4) \leq \max(d(T_1, T_2) + d(T_3, T_4),\; d(T_1, T_4) + d(T_2, T_3))$$
If true, this means the space of theories embeds isometrically into a real tree, and we can construct *phylogenetic trees of mathematical theories* — evolutionary histories showing how theories branched from common ancestors.

**Test**: Check the four-point condition computationally for all quadruples of theories over Fin 3. If it holds for small cases, attempt a general proof. If it fails, characterize the obstruction (which quadruples violate it?).

**Impact**: If true, this would provide a canonical "tree of mathematical life" — an evolutionary history of mathematics derivable from first principles. If false, the failure tells us that mathematical evolution is not tree-like (perhaps reticulate, like horizontal gene transfer in biology), which is equally informative.

**Catalog References**: `Speculative/TheoryGenome.lean` (genomeDiff_triangle)

**Proof Strategy**:
1. Formalize the four-point condition as a Lean theorem.
2. For the proof attempt, use the fact that axiom closures live in a Boolean algebra, and symmetric differences in Boolean algebras are known to satisfy additional metric constraints.
3. If the general statement is false, find a counterexample and characterize when it holds.

**Domain Bridges**: Phylogenetics <-> Metric Geometry <-> Boolean Algebras

**Lineage**: Builds on `genomeDiff_triangle` and the pseudometric structure.

**Ambition**: grand_challenge

---

### Direction 4: Mutation Fibers and Adjunction Decomposition

**Conjecture**: Every theory fiber (extending T₁ to T₂ by adding axioms) induces a reflective subcategory structure on the model sets, where the "reflection" is the canonical projection from T₁-models to T₂-models. Moreover, every chain of theory extensions T₁ ⊂ T₂ ⊂ ... ⊂ Tₙ corresponds to a chain of adjunctions between model categories, and the composite adjunction equals the adjunction induced by the direct extension T₁ ⊂ Tₙ.

**Test**: Formalize the category of models of a theory genome using Mathlib's `CategoryTheory.Category`. Define the forgetful functor from models(T₂) to models(T₁) when T₁ ⊆ T₂. Construct the left adjoint (free construction) and verify that it is a reflection. Check composition for a chain of length 3.

**Impact**: This directly addresses the original research question: "mutation of a theory corresponds to an adjunction between model categories." A formal proof would establish the precise sense in which theory mutation is a categorical operation, not just a set-theoretic one.

**Catalog References**: `Speculative/TheoryGenome.lean` (fiber_lost_models_char, extend_models_eq, extend_extend)

**Proof Strategy**:
1. Define `ModelCategory T` as the full subcategory of `α` consisting of models.
2. For T₁ ⊆ T₂, define the inclusion functor `ι : ModelCategory T₂ ⥤ ModelCategory T₁`.
3. Construct the left adjoint using the axiom closure restricted to T₂.
4. Verify the adjunction unit/counit using `axioms_subset_axiomClosure` and `models_closure_idempotent`.

**Domain Bridges**: Category Theory <-> Universal Algebra <-> Model Theory

**Lineage**: Builds on `fiber_lost_models_char`, `extend_models_eq`, `models_antitone` from this cycle.

**Ambition**: extension

---

### Direction 5: Genome Spectrum as a Topological Space

**Conjecture**: The spectrum of a theory T (the set of all closed sub-theories of T) carries a natural topology — the *Zariski-like topology* where closed sets are of the form {sub-theories whose models contain a given set S}. This topology is:
1. T₀ (distinguishes closed sub-theories)
2. Compact (by a Stone-like duality argument)
3. Sober (every irreducible closed set has a unique generic point)

Moreover, the spectrum of the theory of groups is homeomorphic to the lattice of varieties of groups (as studied by Hanna Neumann), providing a concrete bridge between universal algebra and algebraic geometry.

**Test**: Formalize the spectrum topology for finite theories and verify the separation axioms. For the theory of groups over a finite universe, compute the spectrum explicitly and check sobriety.

**Impact**: This would establish a rigorous "algebraic geometry of theories" where theories play the role of rings and closed sub-theories play the role of prime ideals. It connects the genome framework to scheme theory and could provide new tools for studying the structure of mathematical theories.

**Catalog References**: `Speculative/TheoryGenome.lean` (axiomClosure_isClosed, closed_eq_of_same_models)

**Proof Strategy**:
1. Define the spectrum topology using `TopologicalSpace.IsOpen`.
2. Prove T₀ using `closed_eq_of_same_models`.
3. Prove compactness using the finite intersection property and `axiomClosure_idempotent`.
4. For sobriety, relate irreducible closed sets to "prime theories" (theories T where models(T) cannot be written as a non-trivial union).

**Domain Bridges**: Algebraic Geometry <-> Universal Algebra <-> Point-Set Topology

**Lineage**: Builds on `axiomClosure_isClosed`, `closed_eq_of_same_models`, and the complete lattice structure.

**Ambition**: grand_challenge
