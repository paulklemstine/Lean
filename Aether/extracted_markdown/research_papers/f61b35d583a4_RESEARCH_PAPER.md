# Theory Genome: A Galois-Theoretic Framework for the Categorical DNA of Mathematics

## Abstract

We introduce the **Theory Genome** framework, a novel mathematical structure that formalizes the analogy between biological genetics and mathematical theory construction. An *axiom system* consists of a type of axioms, a type of structures, and a satisfaction relation. A *theory genome* is a set of axioms — the "DNA" of a mathematical theory. We prove that the maps sending axiom sets to their model classes and model classes to their shared axioms form an *antitone Galois connection*, establishing a rigorous "Central Dogma" of mathematical genetics. This Galois connection induces closure operators on both theories and models, yielding a complete lattice of closed theories (analogous to varieties in universal algebra). We define *genomic distance* as the cardinality of the symmetric difference of axiom sets and prove it satisfies the triangle inequality, giving the space of theories a pseudometric structure. We establish a *Morita equivalence criterion*: two genomes determine the same model class if and only if they have the same closure. We prove a *mutation characterization theorem* showing that single-axiom extensions correspond to intersections of model classes. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: Galois connection, model theory, axiom systems, theory lattice, genomic distance, Morita equivalence, formal verification

---

## 1. Introduction

Every mathematical theory is defined by its axioms, and every axiom constrains the universe of possible models. This interplay between syntax (axioms) and semantics (models) is the central theme of model theory. We propose viewing this interplay through a biological lens: axioms are *genes*, theories are *genomes*, models are *phenotypes*, and the satisfaction relation is the *expression mechanism*.

This analogy is not merely poetic. We show that the mathematical structure of this correspondence is precisely a **Galois connection** — the same structure that connects subgroups to fixed fields in Galois theory, ideals to varieties in algebraic geometry, and open sets to continuous functions in topology. The Galois connection is, in a precise sense, the universal structure of duality in mathematics.

### 1.1 Contributions

1. **Novel structure**: The `AxiomSystem` framework, parameterized by axiom type, structure type, and satisfaction relation, with derived notions of theory genomes, model classes, closures, and mutations.

2. **Central Dogma theorem**: The maps `modelClass` and `theoryOf` form an antitone Galois connection (Theorem 3.1).

3. **Closure operator theory**: Both theory closure and model closure are idempotent, and their fixed points form the closed theories and definable classes respectively (Theorems 3.2-3.5).

4. **Pseudometric on theories**: Genomic distance satisfies d(T,T)=0, d(T₁,T₂)=d(T₂,T₁), and the triangle inequality for finite genomes (Theorems 4.1-4.3).

5. **Morita equivalence criterion**: Two genomes have the same models iff they have the same closure (Theorem 4.4).

6. **Mutation characterization**: Single-axiom additions correspond to model class intersections; redundant axioms leave models unchanged (Theorems 3.6-3.8).

7. **Set algebra of theories**: Model classes convert unions to intersections and vice versa, with precise containment results (Theorems 4.5-4.9).

---

## 2. Definitions

### 2.1 Axiom Systems

**Definition 2.1** (Axiom System). An *axiom system* is a triple S = (Ax, Str, sat) where:
- Ax is a type (the *axioms*)
- Str is a type (the *structures* or *models*)
- sat : Str → Ax → Prop is the *satisfaction relation*

This is deliberately abstract — it captures first-order theories, equational theories, higher-order theories, and even non-classical logics as special cases.

### 2.2 Theory Genomes and Model Classes

**Definition 2.2** (Theory Genome). A *theory genome* over S is a set T ⊆ Ax.

**Definition 2.3** (Model Class). The *model class* of T is:
$$\text{Mod}(T) = \{M \in \text{Str} \mid \forall a \in T,\ \text{sat}(M, a)\}$$

**Definition 2.4** (Theory of a Class). The *theory* of a class C ⊆ Str is:
$$\text{Th}(C) = \{a \in \text{Ax} \mid \forall M \in C,\ \text{sat}(M, a)\}$$

### 2.3 Closure Operators

**Definition 2.5** (Theory Closure). The *theory closure* of T is Th(Mod(T)).

**Definition 2.6** (Model Closure). The *model closure* of C is Mod(Th(C)).

**Definition 2.7** (Closed Theory). A genome T is *closed* if T = Th(Mod(T)).

**Definition 2.8** (Definable Class). A class C is *definable* if C = Mod(Th(C)).

### 2.4 Genomic Distance

**Definition 2.9** (Genomic Distance). The *genomic distance* between T₁ and T₂ is:
$$d(T_1, T_2) = |T_1 \triangle T_2|$$
where △ denotes symmetric difference and |·| denotes cardinality (as `Set.ncard`).

---

## 3. The Galois Connection

### 3.1 Antitonicity

**Theorem 3.1** (Antitonicity). Both `modelClass` and `theoryOf` are antitone:
- If T₁ ⊆ T₂ then Mod(T₂) ⊆ Mod(T₁)
- If C₁ ⊆ C₂ then Th(C₂) ⊆ Th(C₁)

*Proof sketch*. More axioms means more constraints, hence fewer models. More models means fewer axioms that all of them share. □

### 3.2 The Central Dogma

**Theorem 3.2** (Central Dogma / Galois Connection). For any theory T and class C:
$$T \subseteq \text{Th}(C) \iff C \subseteq \text{Mod}(T)$$

*Proof sketch*. Both sides unpack to: for all a ∈ T and M ∈ C, sat(M, a). The logical quantifier structure is identical. □

This is the precise mathematical content of the biological "Central Dogma" analogy: knowing the genotype (axioms) determines the phenotype (models), and observing the phenotype constrains the genotype.

### 3.3 Closure Operators

**Theorem 3.3** (Extensiveness). T ⊆ Th(Mod(T)) and C ⊆ Mod(Th(C)).

**Theorem 3.4** (Idempotency). Th(Mod(Th(Mod(T)))) = Th(Mod(T)) and Mod(Th(Mod(Th(C)))) = Mod(Th(C)).

**Theorem 3.5** (Fixed Points). The closure of any theory is closed; the closure of any class is definable.

*Proof of idempotency*. By extensiveness, Mod(T) ⊆ Mod(Th(Mod(T))). By antitonicity, Th(Mod(Th(Mod(T)))) ⊆ Th(Mod(T)). Combined with extensiveness of the closure, we get equality. □

### 3.4 Mutation Characterization

**Theorem 3.6** (Mutation as Intersection). Mod(T ∪ {a}) = Mod(T) ∩ {M | sat(M, a)}.

**Theorem 3.7** (Redundant Axioms). If a ∈ Th(Mod(T)), then Mod(T ∪ {a}) = Mod(T).

**Theorem 3.8** (Monotonicity). Adding axioms shrinks models; removing axioms expands models.

The Mutation Characterization theorem is the formal version of the biological principle that adding a gene constrains the possible phenotypes. Theorem 3.7 captures the notion of *genetic redundancy*: if an axiom is already implied by the theory, adding it explicitly changes nothing.

---

## 4. Genomic Distance and Morita Equivalence

### 4.1 Pseudometric Structure

**Theorem 4.1** (Self-distance). d(T, T) = 0.

**Theorem 4.2** (Symmetry). d(T₁, T₂) = d(T₂, T₁).

**Theorem 4.3** (Triangle Inequality). If T₁ △ T₂ and T₂ △ T₃ are finite, then:
$$d(T_1, T_3) \leq d(T_1, T_2) + d(T_2, T_3)$$

*Proof sketch*. The symmetric difference satisfies T₁ △ T₃ ⊆ (T₁ △ T₂) ∪ (T₂ △ T₃). Then ncard of a subset ≤ ncard of the superset, and ncard of a union ≤ sum of ncards. □

Note: genomic distance is a *pseudo*metric, not a metric — d(T₁, T₂) = 0 does not imply T₁ = T₂ for infinite genomes (where ncard returns 0 for infinite sets).

### 4.2 Morita Equivalence

**Theorem 4.4** (Morita Equivalence Criterion). Mod(T₁) = Mod(T₂) if and only if Th(Mod(T₁)) = Th(Mod(T₂)).

*Proof sketch*. Forward: Mod(T₁) = Mod(T₂) implies Th(Mod(T₁)) = Th(Mod(T₂)) by applying Th to both sides. Backward: if closures are equal, then Mod(closure(T₁)) = Mod(closure(T₂)). But Mod(Th(Mod(T))) = Mod(T) (from the Galois connection: T ⊆ Th(Mod(T)) gives Mod(Th(Mod(T))) ⊆ Mod(T) by antitonicity, and Mod(T) ⊆ Mod(Th(Mod(T))) by extensiveness of model closure). □

This theorem is the genome-level analogue of Morita equivalence in ring theory: two rings are Morita equivalent iff their module categories are equivalent. Here, two genomes are "Morita equivalent" iff their model classes are equal, and this is characterized by equality of their deductive closures.

### 4.3 Set Algebra of Theories

**Theorem 4.5** (Union-Intersection Duality). Mod(T₁ ∪ T₂) = Mod(T₁) ∩ Mod(T₂).

**Theorem 4.6** (Intersection Containment). Mod(T₁) ∪ Mod(T₂) ⊆ Mod(T₁ ∩ T₂).

Note the asymmetry: unions of theories correspond precisely to intersections of model classes, but the converse is only a containment, not an equality. This asymmetry is fundamental — it reflects the fact that the join in the lattice of *closed* theories is not simply the intersection of axiom sets.

**Theorem 4.7** (Theory of Union). Th(C₁ ∪ C₂) = Th(C₁) ∩ Th(C₂).

**Theorem 4.8**. Mod(∅) = Str (everything is a model of the empty theory).

**Theorem 4.9**. Th(∅) = Ax (every axiom is vacuously satisfied by no structures).

---

## 5. Connections to Existing Mathematics

### 5.1 Galois Theory

The Theory Genome Galois connection is a direct generalization of the classical Galois correspondence. In Galois theory, the axiom system has Ax = {field automorphisms}, Str = {intermediate fields}, and sat(K, σ) iff σ fixes K. The closed theories are subgroups; the definable classes are intermediate fields fixed by a subgroup.

### 5.2 Algebraic Geometry

In algebraic geometry (the Nullstellensatz), Ax = {polynomials}, Str = {points in affine space}, and sat(p, f) iff f(p) = 0. Theory closure is the radical ideal; model closure is the Zariski closure. The Morita equivalence criterion becomes: two ideals have the same variety iff they have the same radical.

### 5.3 Universal Algebra (Birkhoff's Theorem)

In universal algebra, closed theory genomes correspond to equational theories, and definable model classes correspond to varieties (classes closed under homomorphic images, subalgebras, and products). Birkhoff's HSP theorem characterizes definable classes in this setting.

### 5.4 Connection to Catalog

The `derivability_closed_iff_theory_of_observable` theorem in `Bridges/LawvereThermodynamicGalois.lean` establishes a similar Galois connection between derivability and observability in a thermodynamic context. Our framework generalizes this: any axiom system induces a Galois connection, and the Lawvere thermodynamic setting is a specific instance.

---

## 6. Falsifiable Conjecture

**Conjecture 6.1** (Finite Spectrum Rigidity). For any axiom system S with finitely many axioms and finitely many structures, the number of closed theories equals the number of definable model classes, and this number is bounded above by min(2^|Ax|, 2^|Str|).

**Computational Test**: For all axiom systems with |Ax| ≤ 6 and |Str| ≤ 6, enumerate all subsets, compute closures, count fixed points, and verify the bound.

**Status**: The equality part follows from the Galois connection (it's a bijection between closed theories and definable classes). The bound part is testable but may be tightened.

---

## 7. Algorithms

### 7.1 Theory Closure Algorithm

```
Input: Axiom system S, theory genome T
Output: Closure of T

1. Compute Mod(T) = {M ∈ Str | ∀a ∈ T, sat(M,a)}
2. Compute Th(Mod(T)) = {a ∈ Ax | ∀M ∈ Mod(T), sat(M,a)}
3. Return Th(Mod(T))
```

Complexity: O(|Str| · |Ax|) for finite systems.

### 7.2 Genomic Distance Algorithm

```
Input: Theory genomes T₁, T₂
Output: d(T₁, T₂)

1. Compute T₁ △ T₂ = (T₁ \ T₂) ∪ (T₂ \ T₁)
2. Return |T₁ △ T₂|
```

---

## 8. Discussion

The Theory Genome framework reveals that the relationship between axioms and models has the same mathematical structure across all of mathematics — a Galois connection. This is not a metaphor but a theorem. The closure operators, the lattice structure, the duality between syntax and semantics — all emerge from a single, universal construction.

The genomic distance pseudometric adds a quantitative dimension: we can measure how "far apart" two theories are, in terms of the minimum number of axiom changes needed to transform one into the other. This opens the door to a topology of mathematical theories, where continuity means "small changes in axioms produce small changes in model classes."

The Morita equivalence criterion is perhaps the deepest result: two genomes are interchangeable (have the same models) iff they are deductively equivalent (have the same closure). This is the precise sense in which mathematical DNA determines mathematical phenotype.

---

## 9. Future Work

1. **Categorical enrichment**: Upgrade from the set-level Galois connection to a categorical adjunction between categories of theories and categories of model classes, with morphisms being theory interpretations and functors between model categories.

2. **Topological structure**: Give the space of theories a topology (e.g., the Zariski topology from the Galois connection) and study its properties.

3. **Quantitative bounds**: For finite axiom systems, establish tight bounds on the number of closed theories and definable classes.

4. **Evolutionary dynamics**: Define "fitness functions" on theory genomes and study the dynamics of theory evolution under mutation and selection.

---

## References

1. Birkhoff, G. (1935). On the structure of abstract algebras. *Proc. Cambridge Phil. Soc.* 31, 433-454.
2. Davey, B.A. and Priestley, H.A. (2002). *Introduction to Lattices and Order*. Cambridge University Press.
3. Hodges, W. (1993). *Model Theory*. Cambridge University Press.
4. Mac Lane, S. (1971). *Categories for the Working Mathematician*. Springer.
