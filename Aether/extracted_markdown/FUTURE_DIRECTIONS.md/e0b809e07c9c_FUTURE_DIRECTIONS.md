# Future Directions: Composable Proof Schemata

## Overview

This document outlines five breakthrough-level research directions opened by the formalization of composable proof schemata. Each direction specifies concrete target theorems, required definitions, and explains why pursuing it opens a new field rather than extending a corner.

---

## Direction 1: A Category of Proof Architectures with Functorial Semantics

### Vision
Upgrade the monoid of proof schemata into a full **category** whose objects are *theorem families* — predicates indexed by a parameter space — and whose morphisms are certified proof schemata. Define functors from this category into the category of types or the category of proofs, giving a categorical semantics for proof transfer.

### Target Definitions
```
structure TheoremFamily (I : Type*) where
  carrier : I → Type*
  predicate : ∀ i, carrier i → Prop

structure ProofMorphism (F G : TheoremFamily I) where
  map : ∀ i, F.carrier i → G.carrier i
  transfer : ∀ i x, G.predicate i (map i x) → F.predicate i x

def ProofCategory (I : Type*) : Category (TheoremFamily I) where
  Hom := ProofMorphism
  id := ...
  comp := ...
```

### Target Theorems
1. `ProofCategory` satisfies the category axioms (associativity, identity laws).
2. The forgetful functor from `ProofCategory` to `Type` preserves composition.
3. Natural transformations between proof morphisms correspond to proof equivalences.

### Why This Opens a Field
A categorical framework for proof transfer would enable:
- **Formal proof reuse**: Morphisms between theorem families give certified methods for transferring proofs between domains.
- **Adjunctions as duality**: Left/right adjoints between proof categories would formalize the duality between "more assumptions" and "stronger conclusions."
- **Sheaf-theoretic proof gluing**: Local proofs on an open cover of a parameter space could be glued into global proofs, formalizing the local-to-global principle categorically.

### Cross-Domain Connections
- Topos theory: Theorem families as sheaves on a site of mathematical structures.
- Homotopy type theory: Proof morphisms as transport along paths in a universe.
- Software engineering: Functorial proof transfer as a foundation for verified code reuse.

---

## Direction 2: Finite Obstruction Theory for Graph Minors and Matroids

### Vision
Instantiate the proof schema framework on **finite combinatorial structures** — graphs and matroids — where the Robertson-Seymour theorem and matroid minor theory provide rich examples of finite obstruction sets. Prove that the "finite core" schema, when instantiated with minor-closed properties, yields the correct obstruction characterization.

### Target Definitions
```
structure MinorClosedProperty (V : Type*) [Fintype V] where
  property : SimpleGraph V → Prop
  minor_closed : ∀ G H, IsMinor H G → property G → property H

structure ObstructionSet (V : Type*) [Fintype V] where
  obstructions : Finset (SimpleGraph V)
  characterizes : ∀ G, property G ↔ ∀ H ∈ obstructions, ¬ IsMinor H G
```

### Target Theorems
1. Every minor-closed property has a finite obstruction set (finitary Robertson-Seymour, for bounded vertex count).
2. The finite core schema instantiated on graph properties recovers the obstruction characterization.
3. Composition of minor-closed properties corresponds to union of obstruction sets (with appropriate closure).

### Why This Opens a Field
The Robertson-Seymour theorem is one of the deepest results in combinatorics, yet its proof-theoretic structure has never been formalized as a schema. Connecting it to the proof architecture framework would:
- Give a formal account of *why* graph minor theory works (it's a finite core extraction on a well-quasi-ordered domain).
- Enable automated generation of obstruction sets for new minor-closed properties.
- Bridge discrete mathematics with the continuous/algebraic methods captured by other schemata.

### Cross-Domain Connections
- Parameterized complexity: Obstruction sets as kernelization certificates.
- Topological graph theory: Minor-closed properties as topological invariants.
- Matroid theory: Extending the framework to matroid minors and Rota's conjecture.

---

## Direction 3: Certified Extraction of ATP Search Strategies from Schema Composition

### Vision
Use proved schema composition theorems to **generate search strategies** for automated theorem provers. The key insight: a composed proof schema S ∘ T tells the prover to first look for a T-reduction, then an S-reduction. This turns informal "proof engineering" into certified search heuristics.

### Target Definitions
```
structure SearchStrategy (α : Type*) where
  priority : (α → Prop) → ℕ  -- which goals to try first
  tactic : (α → Prop) → Option (α → Prop)  -- reduce the goal
  sound : ∀ P Q, tactic P = some Q → ∀ x, Q x → P x

def SchemaToStrategy (S : ProofSchema α) : SearchStrategy α where
  priority P := ...  -- heuristic scoring
  tactic P := ...    -- attempt reduction via S.ReducesTo
  sound := S.sound
```

### Target Theorems
1. `SchemaToStrategy` preserves soundness: strategies derived from sound schemata are sound.
2. Composition of strategies mirrors composition of schemata: `SchemaToStrategy (S.comp T) ≈ compose_strategies (SchemaToStrategy S) (SchemaToStrategy T)`.
3. On a benchmark of Mathlib lemmas, schema-guided search outperforms unguided search (empirical, with formal soundness guarantee).

### Why This Opens a Field
Current automated theorem provers (e.g., `aesop`, `omega`, `grind`) use fixed tactic sets. Schema-derived strategies would give:
- **Adaptive search**: The prover selects strategies based on the goal's structural properties.
- **Certifiable heuristics**: Unlike neural-network-guided provers, schema-derived strategies come with formal soundness guarantees.
- **Compositional proof planning**: Long proofs are planned as schema compositions before individual steps are filled in.

### Cross-Domain Connections
- AI for mathematics: Schema-guided search as a structured alternative to language-model-based proof generation.
- Program synthesis: Strategies as certified program transformations.
- Formal methods: Integration with SMT solvers and model checkers.

---

## Direction 4: Arithmetic-Geometric Bridge via Descent and Rigidity on Elliptic Curves

### Vision
Instantiate the descent + rigidity framework on **elliptic curves over finite fields**, where:
- Descent corresponds to the theory of isogenies (reducing curve complexity by quotienting by torsion subgroups).
- Rigidity corresponds to the j-invariant (classifying curves up to isomorphism).
- Finite core corresponds to the finite set of supersingular j-invariants.

### Target Definitions
```
structure EllipticDescentSchema (p : ℕ) [Fact (Nat.Prime p)] where
  curve : Type*
  j_invariant : curve → ZMod p
  isogeny_step : curve → curve
  measure : curve → ℕ
  descent : ∀ E, measure (isogeny_step E) < measure E
  j_preserved : ∀ E, j_invariant (isogeny_step E) = j_invariant E
```

### Target Theorems
1. The j-invariant classifies elliptic curves over finite fields up to isomorphism (standard, but formalized as an invariant rigidity theorem).
2. The supersingular locus is a finite core controlling arithmetic properties of all curves.
3. Isogeny descent + j-invariant rigidity compose to give a classification schema for elliptic curves.

### Why This Opens a Field
Elliptic curves are the crossroads of number theory, algebraic geometry, and cryptography. Formalizing their classification as an instance of the proof schema framework would:
- Connect abstract proof architecture to concrete arithmetic geometry.
- Provide formal foundations for isogeny-based cryptography (SIKE, CSIDH).
- Give a template for extending the framework to higher-dimensional abelian varieties.

### Cross-Domain Connections
- Cryptography: Security of isogeny-based schemes as schema composition.
- Langlands program: Modularity as a proof schema transferring properties between automorphic forms and Galois representations.
- Computational number theory: Point-counting algorithms as instantiations of finite core extraction.

---

## Direction 5: Proof Schemata as Renormalization: A Formal Theory of Scale-Bridging Arguments

### Vision
Formalize the deep analogy between proof schemata and **renormalization** in physics. In renormalization, local interactions at small scales are compressed into effective parameters at large scales. In proof schemata, local properties at the level of individual elements are compressed into global properties via descent, finite core extraction, and invariant transfer. Make this analogy precise and prove formal renormalization-group-like fixed-point theorems for proof schemata.

### Target Definitions
```
structure RenormalizationSchema (α : Type*) where
  scale : α → ℕ  -- "scale" of an element
  coarsen : (α → Prop) → (α → Prop)  -- coarse-graining operator
  sound : ∀ P x, coarsen P x → P x
  fixed_point : (α → Prop) → Prop  -- identifies RG fixed points
  convergence : ∀ P, ∃ n, iterate coarsen n P = iterate coarsen (n+1) P

structure MultiscaleSchema (α : Type*) where
  levels : ℕ → ProofSchema α  -- one schema per scale
  consistency : ∀ n, (levels n).comp (levels (n+1)) = levels n
```

### Target Theorems
1. Iterated application of a contractive constructive schema converges to a fixed predicate.
2. The fixed predicate of a renormalization schema satisfies invariant rigidity.
3. Multiscale schema composition telescopes: composing all levels yields a single certified reduction from the finest to the coarsest scale.

### Why This Opens a Field
Renormalization is arguably the most powerful idea in 20th-century physics, yet its mathematical foundations remain incomplete. Formalizing renormalization as proof schema composition would:
- Give rigorous meaning to "universality" in mathematics (RG fixed points as canonical proof architectures).
- Connect the formalization of mathematical proof to the formalization of physical theories.
- Enable formal reasoning about scale-dependent properties in combinatorics (e.g., graph limits, regularity lemmas).

### Cross-Domain Connections
- Physics: Formal renormalization group as a proof schema in quantum field theory.
- Probability: Regularity structures and rough paths as multi-scale proof architectures.
- Machine learning: Deep neural networks as multi-scale function approximators, with each layer corresponding to a proof schema level.

---

## Implementation Priorities

| Direction | Difficulty | Impact | Dependencies | Recommended Order |
|-----------|-----------|--------|-------------|-------------------|
| 1. Category of Proof Architectures | Medium | Very High | Current work | 1st |
| 3. ATP Search Strategies | Medium | High | Direction 1 | 2nd |
| 2. Graph Minor Obstruction Theory | High | Very High | Mathlib graph theory | 3rd |
| 4. Elliptic Curve Bridge | Very High | Very High | Mathlib EC theory | 4th |
| 5. Renormalization Formalization | Very High | Revolutionary | Directions 1, 3 | 5th |

## Team Structure Recommendation

- **Core Theory Team** (Directions 1, 5): Formal proof theorists with categorical expertise.
- **Combinatorics Team** (Direction 2): Graph theorists with formalization experience.
- **ATP Integration Team** (Direction 3): Proof automation researchers.
- **Arithmetic Geometry Team** (Direction 4): Number theorists with Mathlib experience.

Each team should maintain a shared lemma library built on the `ProofSchema` / `DescentSchema` / `ConstructiveSchema` framework, ensuring interoperability across directions.
