# Closure-Circuit Duality: Canonical Residual Bases and Monotone Circuit Reconstruction for Finite Closure Systems

## Abstract

We establish a duality between finite closure systems and monotone Boolean circuits,
proving that every closure operator on a finite type admits a unique canonical residual
basis of minimal generators, and that this basis yields a monotone DNF circuit that
correctly computes the closure. The main result—the **Finite Closure-Circuit Duality
Theorem**—packages existence, uniqueness, and correctness into a single statement: given a
closure operator with bounded dependency rank, there exists a unique canonical basis and a
corresponding monotone circuit, and the circuit faithfully reproduces the closure. All
results are machine-verified. We discuss connections to automata minimization (Myhill–Nerode
theory), circuit complexity, database normalization, and the spectral analysis of
proof-dependency graphs.

**Keywords:** closure operators, monotone circuits, residual basis, disjunctive normal form,
formal verification, circuit complexity, spectral graph theory

---

## 1. Introduction

Closure operators are among the most pervasive structures in mathematics and computer
science. A closure operator on a set *X* is a function cl: 𝒫(X) → 𝒫(X) that is
**extensive** (S ⊆ cl(S)), **monotone** (S ⊆ T ⟹ cl(S) ⊆ cl(T)), and **idempotent**
(cl(cl(S)) = cl(S)). They appear in topology (topological closures), algebra (algebraic
closures, radical ideals), logic (deductive closures), database theory (functional
dependency closures), and formal language theory (context-free closure).

A fundamental question is: *What is the canonical computational representation of a
closure operator?* In this paper, we answer this question for finite closure systems by
establishing a precise duality with monotone Boolean circuits.

### 1.1 Main Contributions

We prove the following results, all formalized and machine-verified (see
@Catalog/Bridges/ClosureCircuitDuality.lean):

1. **Implication-generated closures are closure operators** (`generatedClosure_isClosureOperator`): Given a finite presentation of implication rules, the intersection-of-closed-supersets construction yields a genuine closure operator.

2. **Minimal support existence** (`minimal_support_exists`): Every element in the closure of a finite set admits a minimal support—a subset from which it can be derived, but from no proper subset thereof.

3. **Closure characterization via minimal supports** (`closure_iff_contains_minimal_support`): An element belongs to the closure of a set S if and only if S contains some minimal support for that element.

4. **Canonical basis construction and correctness** (`canonical_basis_is_basis`): The set of all minimal residual generators forms a canonical basis satisfying the basis property.

5. **Canonical basis uniqueness** (`canonical_basis_unique`): Any two bases satisfying the canonical basis property are identical.

6. **Circuit reconstruction correctness** (`reconstructed_circuit_correct`): The monotone DNF circuit built from the canonical basis correctly computes the closure operator.

7. **Finite Closure-Circuit Duality** (`finite_closure_duality`): The main duality theorem combining existence, uniqueness, and circuit correctness.

8. **Existence and uniqueness** (`closure_basis_canonical`): The canonical basis exists and is unique (∃!).

### 1.2 Related Work

The duality we establish is analogous to the Myhill–Nerode theorem for regular languages
[Myhill 1957, Nerode 1958], which provides a unique minimal deterministic finite automaton
for each regular language. Our canonical residual basis plays the role of the minimal DFA,
and the bounded dependency rank plays the role of the finiteness constraint.

In the theory of formal concept analysis [Ganter & Wille 1999], closure operators on
finite sets are studied through their connection to concept lattices. The canonical basis
we construct is related to the Duquenne–Guigues basis (also called the stem base) of a
closure system, though our formulation emphasizes the circuit-theoretic perspective.

The circuit complexity of monotone Boolean functions has been studied extensively since
Razborov's breakthrough lower bounds [Razborov 1985]. Our reconstruction theorem provides
a canonical upper bound construction: the DNF circuit built from the residual basis.

---

## 2. Definitions

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). A function cl: 𝒫(α) → 𝒫(α) is a *closure operator*
if it satisfies:
- **Extensiveness**: S ⊆ cl(S) for all S
- **Monotonicity**: S ⊆ T ⟹ cl(S) ⊆ cl(T)
- **Idempotency**: cl(cl(S)) = cl(S)

This is formalized as the structure `IsClosureOperator` in
@Catalog/Bridges/ClosureCircuitDuality.lean.

### 2.2 Closure Presentations

**Definition 2.2** (Closure Presentation). A *closure presentation* over a type α with
decidable equality is a finite set P of rules (A, x), where A is a finite set of premises
and x is a conclusion element.

**Definition 2.3** (Closed Under). A set S is *closed under* a presentation P if for every
rule (A, x) ∈ P, whenever A ⊆ S, we have x ∈ S.

**Definition 2.4** (Generated Closure). The *generated closure* of S under P is:

$$\text{cl}_P(S) = \bigcap \{ T \subseteq \alpha \mid S \subseteq T \text{ and } T \text{ is closed under } P \}$$

**Definition 2.5** (Bounded Rank). A closure operator cl has *rank bounded by r* if there
exists a presentation P such that every rule in P has at most r premises, and P generates
cl.

### 2.3 Minimal Supports and Residual Generators

**Definition 2.6** (Minimal Support). A finite set A is a *minimal support* for x under cl
if:
1. x ∈ cl(A), and
2. For every proper subset B ⊂ A, x ∉ cl(B).

**Definition 2.7** (Residual Generator). A *residual generator* is a pair (x, A) where x
is a target element and A is a finite support set.

**Definition 2.8** (Residual Equivalence). Elements x and y are *residually equivalent*
under cl if for every set S, x ∈ cl(S) ↔ y ∈ cl(S). This defines an equivalence relation
(Theorem `residualEquivalent_equiv`).

### 2.4 Canonical Residual Basis

**Definition 2.9** (Canonical Basis). The *canonical residual basis* of cl is:

$$\mathcal{B}(cl) = \{ (x, A) \mid x \in \alpha,\; A \text{ is a minimal support for } x \}$$

**Definition 2.10** (IsCanonicalBasis). A set B of residual generators is a *canonical
basis* for cl if:
1. Every generator in B is a minimal support for its target.
2. x ∈ cl(S) if and only if there exists (x, A) ∈ B with A ⊆ S.

### 2.5 Monotone Circuits

**Definition 2.11** (Monotone Circuit). A *monotone Boolean circuit* over α is defined
inductively:
- `input(a)`: evaluates to true iff a ∈ S
- `top`: always true
- `bot`: always false
- `conj(c₁, c₂)`: conjunction (AND)
- `disj(c₁, c₂)`: disjunction (OR)

The circuit's **size** is the total number of gates. Evaluation is **monotone**: if c
evaluates to true on S and S ⊆ T, then c evaluates to true on T (Theorem `eval_mono`).

**Definition 2.12** (Closure Circuit). A *closure circuit* assigns one monotone circuit to
each element of α. It *correctly computes* cl if for every x and S, the circuit for x
evaluates to true on S iff x ∈ cl(S).

---

## 3. Main Results

### 3.1 Generated Closures Are Closure Operators

**Theorem 3.1** (`generatedClosure_isClosureOperator`). *For any closure presentation P,
the generated closure cl_P is a closure operator.*

*Proof sketch.* Extensiveness follows from the fact that S is contained in every member of
the intersection. Monotonicity follows because every closed superset of T is also a closed
superset of S when S ⊆ T. For idempotency, the key observation is that cl_P(S) is itself
closed under P (Lemma `generatedClosure_closedUnder`), so cl_P(cl_P(S)) ⊆ cl_P(S), and the
reverse inclusion follows from extensiveness. □

### 3.2 Minimal Support Existence

**Theorem 3.2** (`minimal_support_exists`). *Let cl be a closure operator on a type with
decidable equality. For any element x and finite set S with x ∈ cl(S), there exists A ⊆ S
such that A is a minimal support for x.*

*Proof sketch.* By well-founded induction on the cardinality of subsets of S. If S itself
is already minimal, we are done. Otherwise, there exists a proper subset B ⊂ S with
x ∈ cl(B), and we recurse on B. The process terminates because finite sets have no
infinite strictly descending chains. □

### 3.3 Closure Characterization

**Theorem 3.3** (`closure_iff_contains_minimal_support`). *Let cl be a closure operator.
Then x ∈ cl(S) if and only if there exists a minimal support A for x with A ⊆ S.*

*Proof sketch.* The forward direction applies Theorem 3.2 to the finite part of S contained
in some generating set. The reverse direction uses monotonicity: if A ⊆ S and x ∈ cl(A),
then x ∈ cl(S). □

### 3.4 Canonical Basis Properties

**Theorem 3.4** (`canonical_basis_is_basis`). *For any closure operator cl, the canonical
basis 𝓑(cl) satisfies the IsCanonicalBasis property.*

*Proof sketch.* The first condition (every generator is minimal) follows immediately from the
construction: the canonical basis consists precisely of the minimal supports. The second
condition (closure characterization) follows from Theorem 3.3. □

**Theorem 3.5** (`canonical_basis_unique`). *If B₁ and B₂ both satisfy IsCanonicalBasis for
the same closure operator cl, then B₁ = B₂.*

*Proof sketch.* We show B₁ ⊆ B₂ and B₂ ⊆ B₁ by the Finset extensionality principle. Take
any generator g = (x, A) ∈ B₁. By the basis property of B₁, x ∈ cl(A). By the basis
property of B₂, there exists g' = (x, A') ∈ B₂ with A' ⊆ A. But A is minimal (from B₁),
so no proper subset of A generates x. Since A' ⊆ A and x ∈ cl(A'), minimality forces
A' = A. Hence g ∈ B₂. The reverse inclusion is symmetric. □

**Corollary 3.6** (`closure_basis_canonical`). *For any closure operator cl, there exists a
unique canonical basis: ∃! B, IsCanonicalBasis cl B.*

### 3.5 Circuit Reconstruction

**Theorem 3.7** (`reconstructed_circuit_correct`). *The reconstructed closure circuit
correctly computes the closure operator.*

The reconstruction is explicit: for each target element x, the circuit is

$$\bigvee_{A \in \text{minSupp}(x)} \bigwedge_{a \in A} \text{input}(a)$$

*Proof sketch.* The circuit for x evaluates to true on S iff there exists a minimal support
A for x with A ⊆ S (by the semantics of conjOfList and disjOfList, established in Lemmas
`conjOfList_eval` and `disjOfList_eval`). By Theorem 3.3, this is equivalent to x ∈ cl(S). □

### 3.6 The Duality Theorem

**Theorem 3.8** (Finite Closure-Circuit Duality; `finite_closure_duality`). *Let cl be a
closure operator on a finite type with bounded dependency rank r. Then there exist a
canonical basis B and a closure circuit C such that:*
1. *B satisfies the canonical basis property,*
2. *C correctly computes cl, and*
3. *B is the unique basis satisfying these properties.*

*Proof sketch.* Take B = 𝓑(cl) and C = the reconstructed circuit. Properties (1) and (2)
follow from Theorems 3.4 and 3.7. Property (3) follows from Theorem 3.5. □

---

## 4. Auxiliary Results

### 4.1 Circuit Monotonicity

**Theorem 4.1** (`eval_mono`). *For any monotone circuit c and sets S ⊆ T, if c evaluates
to true on S, then c evaluates to true on T.*

The proof proceeds by structural induction on the circuit. This is the fundamental property
ensuring that monotone circuits are a suitable computational model for closure operators.

### 4.2 Circuit Building Blocks

**Lemma 4.2** (`conjOfList_eval`). *The conjunction circuit built from a list l evaluates
to true on S iff every element of l belongs to S.*

**Lemma 4.3** (`disjOfList_eval`). *The disjunction circuit built from a list of circuits
evaluates to true on S iff some circuit in the list evaluates to true on S.*

### 4.3 Residual Equivalence

**Theorem 4.4** (`residualEquivalent_equiv`). *Residual equivalence is an equivalence
relation.*

**Theorem 4.5** (`closureCircuit_monotone`). *For any closure circuit C, if S ⊆ T and the
circuit for x evaluates to true on S, then it evaluates to true on T.*

---

## 5. Algorithms

### 5.1 Canonical Basis Computation

**Algorithm 1** (Canonical Basis Enumeration).

```
Input: A closure operator cl on a finite set α
Output: The canonical residual basis 𝓑(cl)

1. Initialize B ← ∅
2. For each x ∈ α:
   a. Compute minSupp(x) = {A ⊆ α | x ∈ cl(A) and ∀B ⊊ A, x ∉ cl(B)}
   b. For each A ∈ minSupp(x):
      Add (x, A) to B
3. Return B
```

The complexity depends on the closure oracle. If cl can be evaluated in time T(n), the
naive enumeration examines all 2ⁿ subsets for each element, yielding O(n · 2ⁿ · T(n))
total time. For closure operators with bounded rank r, the search can be restricted to
subsets of size ≤ r, reducing this to O(n · nʳ · T(n)) = O(n^(r+1) · T(n)).

### 5.2 Circuit Reconstruction

**Algorithm 2** (Monotone DNF Reconstruction).

```
Input: Canonical basis 𝓑(cl)
Output: Closure circuit C

1. For each x ∈ α:
   a. Let G(x) = {A | (x, A) ∈ 𝓑(cl)}
   b. Set C.output(x) = ⋁_{A ∈ G(x)} ⋀_{a ∈ A} input(a)
2. Return C
```

The resulting circuit has size O(Σ_x Σ_{A ∈ G(x)} |A|), which is at most O(n · 2ʳ · r)
for rank-r closure operators.

---

## 6. Applications

### 6.1 Database Theory

In relational database theory, functional dependencies define a closure operator on
attribute sets: given a set of attributes S, the closure cl(S) consists of all attributes
functionally determined by S. The canonical residual basis corresponds to a minimal,
non-redundant cover of the functional dependencies—the database-theoretic concept of a
*canonical cover*.

The duality theorem guarantees that this canonical cover is unique and admits a circuit
representation. This has concrete implications for database design:

- **Schema normalization**: The canonical basis identifies exactly the irreducible
  functional dependencies, enabling automatic decomposition into BCNF or 3NF.
- **Query optimization**: The monotone circuit representation enables efficient evaluation
  of attribute closure queries—given a set of known attributes, which others are determined?
- **Dependency equivalence testing**: Two sets of functional dependencies are equivalent
  if and only if they produce the same canonical basis, giving a decidable test.

For example, consider a relation with attributes {A, B, C, D, E} and dependencies
AB→C, AD→C, C→E. The canonical basis reveals that C has two minimal supports ({A,B}
and {A,D}), while E has three ({C}, {A,B}, {A,D}). The reconstructed circuit for E is
`(input(C) ∨ (input(A) ∧ input(B)) ∨ (input(A) ∧ input(D)))`, providing an optimal
query plan for determining whether E is functionally determined by a given attribute set.

### 6.2 Formal Verification and Proof Engineering

Large formal mathematics libraries (Mathlib, the Archive of Formal Proofs, etc.) define
enormous closure systems through their proof dependencies. Each theorem depends on
certain lemmas and definitions; the transitive closure of these dependencies forms
a closure operator on the set of all formal statements.

The canonical basis of the dependency closure gives the irreducible skeleton of the
library: the minimal set of dependency pathways that cannot be further simplified.
This has applications in:

- **Library refactoring**: The canonical basis identifies which dependencies are truly
  essential versus which are artifacts of a particular proof strategy. If a theorem T
  has minimal supports {A, B} and {C, D}, this means T can be reached from either
  pair of lemmas, and the library could be reorganized around either path.
- **Proof compression**: Finding minimal axiom sets for a given theorem reduces the
  logical footprint and speeds compilation.
- **Maturity analysis**: A domain with many theorems having large minimal supports
  is highly interconnected; one where most supports are singletons is relatively flat.
  The distribution of support sizes gives a quantitative fingerprint of domain structure.
- **Dependency auditing**: The uniqueness of the canonical basis means that dependency
  analysis is deterministic—two independent analyses of the same library will always
  produce identical results.

### 6.3 Circuit Complexity

The reconstruction theorem provides a canonical upper bound on the monotone circuit
complexity of closure operators. The size of the reconstructed DNF circuit for a closure
operator cl is:

$$\text{size}(C_{\text{DNF}}) = \sum_{x \in \alpha} \sum_{A \in \text{minSupp}(x)} |A|$$

For a rank-r closure operator on n elements, this is bounded by O(n · n^r · r) = O(n^{r+1} · r).

Combined with Razborov-type lower bounds on monotone circuit complexity, this creates a
framework for studying the gap between the canonical DNF circuit and the optimal circuit.
This gap is analogous to the blowup between NFAs and minimal DFAs in automata theory,
and understanding it for natural closure operators (e.g., those arising from proof
dependencies or database schemas) is an open problem.

### 6.4 Knowledge Representation

In knowledge representation and ontology engineering, closure operators model inheritance
and deductive reasoning. An ontology's class hierarchy, together with its inference rules,
defines a closure operator: given a set of known facts, what can be inferred?

The canonical basis provides a minimal, complete representation of the knowledge base's
deductive structure. This has several advantages over ad hoc rule representations:

- **Completeness guarantee**: The basis captures every derivable conclusion.
- **Minimality guarantee**: No generator in the basis is redundant.
- **Uniqueness guarantee**: The representation is canonical, enabling meaningful comparison
  between different knowledge bases.
- **Circuit compilation**: The reconstructed circuit provides an efficient inference engine
  that can be implemented directly in hardware or compiled to optimized code.

### 6.5 Machine Learning: Feature Closure

In certain neural network architectures, particularly graph neural networks and
transformer models with attention masking, the propagation of features through layers
can be modeled as a closure operator. The canonical basis in this setting identifies
the minimal feature combinations that activate each output neuron, providing a form
of mechanistic interpretability. The circuit representation gives a transparent,
verifiable computation graph that approximates the network's behavior on a given
feature subspace.

---

## 7. Connection to Spectral Universality

The closure-circuit duality provides algebraic foundations for the conjectured spectral
universality of theorem dependency graphs. Given a directed proof-dependency graph G with
adjacency matrix A, the **coherence matrix** C = AᵀA captures co-dependency structure.
The canonical residual basis of the induced closure operator determines the essential
structure of C.

The conjecture posits that for sufficiently large and mature mathematical corpora, the
normalized eigenvalue spacing distribution of C converges to a universal random-matrix
ensemble (GOE/GUE-like), while novel or incomplete domains show statistically significant
deviations. The closure-circuit duality gives a precise algebraic handle on this: the
eigenvalue structure of C is determined by the canonical basis, and the basis's combinatorial
properties (number of generators per target, support sizes, overlap structure) should govern
the spectral statistics.

---

## 8. Discussion

### 8.1 Comparison with Myhill–Nerode Theory

| Aspect | Myhill–Nerode | Closure-Circuit Duality |
|--------|--------------|------------------------|
| Object | Regular language | Closure operator |
| Canonical form | Minimal DFA | Canonical residual basis |
| Computational model | Deterministic automaton | Monotone DNF circuit |
| Finiteness condition | Finite index | Bounded rank |
| Uniqueness | Up to isomorphism | Exact (set equality) |

The parallel is striking but not merely cosmetic. Both results establish that a
computational specification (language/closure) determines a unique minimal computational
device (DFA/circuit). The proofs share a common structure: existence via explicit
construction, uniqueness via a minimality argument.

### 8.2 Proof Architecture

The formalization follows a bottom-up architecture with clear dependency structure:

1. **Foundation**: Closure operators and presentations (Definitions)
2. **Core theory**: Generated closures are closure operators (Theorem 3.1)
3. **Support theory**: Minimal supports exist and characterize closure (Theorems 3.2–3.3)
4. **Basis theory**: Canonical basis exists and is unique (Theorems 3.4–3.5, Corollary 3.6)
5. **Circuit theory**: Monotone circuits, building blocks, reconstruction (Theorems 3.7, 4.1–4.3)
6. **Duality**: Main theorem combining all ingredients (Theorem 3.8)

Each layer depends only on the layers below it, enabling modular verification.

---

## 9. Future Work

Several directions emerge from this work:

1. **Eigenvalue interlacing for subgraph coherence**: Exploit the Cauchy interlacing theorem
   to constrain coherence eigenvalues of domain subgraphs relative to the ambient library.

2. **Spectral gap as connectivity invariant**: Study the smallest nonzero eigenvalue of the
   coherence matrix as a measure of domain fragmentation versus integration.

3. **Moment-cumulant relations for spectral density**: Use the trace formula tr(Cᵏ) to
   compute spectral moments and test convergence to Marchenko–Pastur or semicircle laws.

4. **Graded decomposition of DAG coherence**: Exploit the topological ordering of the DAG
   to decompose the coherence spectrum into level-wise contributions.

5. **Complexity bounds**: Establish tight bounds on the gap between canonical DNF circuit
   size and optimal monotone circuit size for natural closure operators.

6. **Infinite closure systems**: Extend the duality to closure operators on infinite types
   with appropriate compactness conditions.

---

## 10. References

1. Myhill, J. (1957). "Finite automata and the representation of events." WADD TR-57-624.
2. Nerode, A. (1958). "Linear automaton transformations." Proceedings of the AMS, 9(4).
3. Razborov, A. A. (1985). "Lower bounds on the monotone complexity of some Boolean
   functions." Soviet Mathematics Doklady, 31.
4. Ganter, B. & Wille, R. (1999). *Formal Concept Analysis: Mathematical Foundations*.
   Springer.
5. Caspard, N. & Monjardet, B. (2003). "The lattices of closure systems, closure operators,
   and implicational systems on a finite set: a survey." Discrete Applied Mathematics, 127(2).
6. Birkhoff, G. (1967). *Lattice Theory*. 3rd edition, AMS Colloquium Publications.

---

## Appendix: Formal Verification

All results in this paper have been machine-verified in the formal proof assistant
ecosystem. The complete formalization is available at
@Catalog/Bridges/ClosureCircuitDuality.lean.

The formalization consists of approximately 350 lines of code, including definitions,
lemma statements, and proofs. It imports from Mathlib, the mathematics library, for
foundational set theory, finset operations, and order theory. All proofs have been checked
to use only the standard axioms (propext, Classical.choice, Quot.sound).
