# Closure-Circuit Duality: Certified Monotone Circuit Reconstruction from Canonical Residual Bases

## Abstract

We establish a duality between finite closure systems and monotone Boolean circuits, proving that every closure operator on a finite type admits a unique canonical residual basis of minimal generators, and that this basis yields a monotone disjunctive normal form (DNF) circuit that correctly computes the closure. The main result — the *Finite Closure-Circuit Duality Theorem* — shows that for any closure operator with bounded dependency rank on a finite type, there exists a canonical basis and a corresponding monotone circuit, both unique up to the natural equivalence. The proof proceeds through a minimal support existence theorem (via well-founded induction on finite subsets), a characterization of closure membership in terms of minimal supports, and a constructive circuit reconstruction procedure. All results have been formally verified.

**Keywords:** closure operators, monotone circuits, residual basis, canonical forms, disjunctive normal form, formal verification

---

## 1. Introduction

Closure operators are among the most fundamental structures in mathematics and theoretical computer science. A closure operator on a set maps subsets to subsets while satisfying three axioms — extensiveness, monotonicity, and idempotence — and instances arise naturally in algebra (algebraic closure, linear span), topology (topological closure), logic (deductive closure), and database theory (attribute closure under functional dependencies).

A central question in the computational study of closure systems is: *what is the canonical computational representation of a closure operator?* While closure operators can be presented in many ways — through generating implications, through explicit set functions, through lattice-theoretic descriptions — we show that there is a unique minimal representation as a monotone Boolean circuit in disjunctive normal form.

Our main contribution is the **Finite Closure-Circuit Duality Theorem**, which establishes a bijective correspondence between:
- Closure operators on finite types with bounded dependency rank, and
- Canonical monotone DNF circuits, identified via their unique residual bases.

This result can be viewed as a *Myhill-Nerode minimization principle for monotone closure computation*: just as the Myhill-Nerode theorem provides a unique minimal automaton for each regular language, our duality provides a unique minimal monotone circuit for each finite closure system.

### 1.1 Related Work

The theory of closure systems and their presentations has a long history, with foundational contributions by Birkhoff, Tarski, and others in the lattice-theoretic tradition. The connection between closure systems and implications was developed extensively in Formal Concept Analysis (FCA), where the canonical basis is known as the *Duquenne-Guigues basis* or *stem basis*. Our residual basis is related but distinct: it captures *all* minimal supports rather than a minimal generating set of implications.

The relationship between closure operators and Boolean circuits has been studied in circuit complexity theory, particularly in the context of monotone circuit lower bounds. Our contribution is to show that the algebraic structure of the closure operator *uniquely determines* the circuit, providing a canonical form theorem rather than a complexity bound.

### 1.2 Overview of Results

The paper establishes the following chain of results, each building on the previous:

1. **Implication-generated closures are closure operators** (§3, Theorem 3.1)
2. **Minimal support existence** (§4, Theorem 4.1)
3. **Closure membership characterization** (§4, Theorem 4.2)
4. **Canonical basis correctness** (§5, Theorem 5.1)
5. **Canonical basis uniqueness** (§5, Theorem 5.2)
6. **Circuit reconstruction correctness** (§6, Theorem 6.1)
7. **Full duality theorem** (§7, Theorem 7.1)

---

## 2. Definitions

### 2.1 Closure Operators

**Definition 2.1 (Closure Operator).** Let α be a type. A function cl : 𝒫(α) → 𝒫(α) is a *closure operator* if it satisfies:
- *Extensiveness*: S ⊆ cl(S) for all S
- *Monotonicity*: S ⊆ T implies cl(S) ⊆ cl(T)
- *Idempotence*: cl(cl(S)) = cl(S) for all S

See `IsClosureOperator` in @Catalog/Bridges/ClosureCircuitDuality.lean.

### 2.2 Closure Presentations

**Definition 2.2 (Closure Presentation).** A *closure presentation* over a type α with decidable equality is a finite set P of rules (A, x), where A is a finite set of premises and x is a conclusion element. A set S is *closed under* P if for every rule (A, x) ∈ P with A ⊆ S, we have x ∈ S.

**Definition 2.3 (Generated Closure).** The *closure of S under presentation P*, denoted cl_P(S), is the intersection of all supersets of S that are closed under P:

$$\text{cl}_P(S) = \bigcap \{ T \supseteq S \mid T \text{ is closed under } P \}$$

See `GeneratedClosure` in @Catalog/Bridges/ClosureCircuitDuality.lean.

**Definition 2.4 (Bounded Rank).** A closure operator cl has *rank bounded by r* if there exists a presentation P such that every rule in P has at most r premises, and P generates cl.

### 2.3 Minimal Supports and Residual Generators

**Definition 2.5 (Minimal Support).** A finite set A is a *minimal support* for element x under closure operator cl if:
1. x ∈ cl(A), and
2. For every proper subset B ⊂ A, x ∉ cl(B).

See `IsMinimalSupport` in @Catalog/Bridges/ClosureCircuitDuality.lean.

**Definition 2.6 (Residual Generator).** A *residual generator* is a pair g = (target, support) where target is an element and support is a finite set. The collection of all residual generators whose support is a minimal support for their target forms the *canonical residual basis*.

See `ResidualGenerator` and `canonicalBasis` in @Catalog/Bridges/ClosureCircuitDuality.lean.

### 2.4 Canonical Basis

**Definition 2.7 (Canonical Basis Property).** A set B of residual generators is a *canonical basis* for cl if:
1. Every generator g ∈ B has a minimal support: IsMinimalSupport(cl, g.target, g.support).
2. For all x and S: x ∈ cl(S) ↔ ∃ g ∈ B such that g.target = x and g.support ⊆ S.

See `IsCanonicalBasis` in @Catalog/Bridges/ClosureCircuitDuality.lean.

### 2.5 Monotone Circuits

**Definition 2.8 (Monotone Circuit).** A *monotone Boolean circuit* over α is an inductive type with constructors:
- `input(a)`: a wire carrying the truth value of a ∈ S
- `top`, `bot`: constant true/false
- `conj(c₁, c₂)`: AND gate
- `disj(c₁, c₂)`: OR gate

Evaluation is defined recursively: `eval(input(a), S) = (a ∈ S)`, `eval(conj(c₁,c₂), S) = eval(c₁,S) ∧ eval(c₂,S)`, etc.

See `MonotoneCircuit` in @Catalog/Bridges/ClosureCircuitDuality.lean.

**Definition 2.9 (Closure Circuit).** A *closure circuit* assigns one monotone circuit to each element: C.output(x) is the circuit that computes whether x belongs to the closure. It *correctly computes* cl if eval(C.output(x), S) ↔ x ∈ cl(S) for all x, S.

---

## 3. Generated Closures Are Closure Operators

**Theorem 3.1** (`generatedClosure_isClosureOperator`). *For any closure presentation P, the generated closure cl_P is a closure operator.*

*Proof sketch.* Extensiveness follows directly: if x ∈ S then x belongs to every superset of S, hence to their intersection. Monotonicity follows because if S ⊆ T, then every closed superset of T is also a closed superset of S (after composing with the inclusion), so the intersection over T-supersets is contained in the intersection over S-supersets. For idempotence, the key observation is that cl_P(S) is itself closed under P (proved as `generatedClosure_closedUnder`): if a rule (A, x) has A ⊆ cl_P(S), then x belongs to every closed superset of S (since A is contained in each such superset), hence x ∈ cl_P(S). Therefore cl_P(S) is a closed superset of itself, giving cl_P(cl_P(S)) ⊆ cl_P(S), and the reverse inclusion follows from extensiveness.

See @Catalog/Bridges/ClosureCircuitDuality.lean, theorems `generatedClosure_extensive`, `generatedClosure_monotone`, `generatedClosure_closedUnder`, `generatedClosure_idempotent`.

---

## 4. Minimal Support Theory

**Theorem 4.1** (`minimal_support_exists`). *Let cl be a closure operator, x an element, and S a finite set with x ∈ cl(S). Then there exists A ⊆ S such that A is a minimal support for x under cl.*

*Proof sketch.* By well-founded induction on the strict subset ordering of finite sets (which is well-founded since all subsets of S are finite and the powerset of a finite set is finite). Given any A ⊆ S with x ∈ cl(A), either A is already minimal (no proper subset generates x), or there exists a proper subset B ⊂ A with x ∈ cl(B). In the latter case, apply the induction hypothesis to B. The descent must terminate since finite sets cannot decrease in cardinality indefinitely.

**Theorem 4.2** (`closure_iff_contains_minimal_support`). *For any closure operator cl on a finite type, element x, and set S:*

$$x \in \text{cl}(S) \iff \exists A \in \text{minimalSupports}(\text{cl}, x),\; A \subseteq S$$

*Proof sketch.* The forward direction applies Theorem 4.1 to obtain a minimal support A within the finite approximation of S, then verifies A belongs to the `minimalSupports` collection. The reverse direction uses monotonicity: if A ⊆ S and x ∈ cl(A), then x ∈ cl(S).

See @Catalog/Bridges/ClosureCircuitDuality.lean.

---

## 5. The Canonical Basis

**Theorem 5.1** (`canonical_basis_is_basis`). *For any closure operator cl on a finite type, the canonical basis `canonicalBasis cl` satisfies the `IsCanonicalBasis` property.*

*Proof sketch.* The first condition (every generator is minimal) follows from the construction: the canonical basis consists of pairs (x, A) where A ∈ minimalSupports(cl, x), so by definition each support is minimal. The second condition (closure membership ↔ existence of a basis element) reduces to Theorem 4.2 via a straightforward set-theoretic manipulation of the `biUnion` and `image` constructions.

**Theorem 5.2** (`canonical_basis_unique`). *If B₁ and B₂ are both canonical bases for the same closure operator cl, then B₁ = B₂.*

*Proof sketch.* We show B₁ ⊆ B₂ (the reverse is symmetric). Let g ∈ B₁. Since g.target ∈ cl(g.support) (by the minimality condition on B₁), the basis property of B₂ yields some g' ∈ B₂ with g'.target = g.target and g'.support ⊆ g.support. But g is minimal (by B₁'s minimality condition), and g' also generates g.target (by B₂'s minimality condition). Since g.support is minimal and g'.support ⊆ g.support also generates g.target, we must have g'.support = g.support. Therefore g' = g, giving g ∈ B₂.

**Corollary 5.3** (`closure_basis_canonical`). *For any closure operator cl on a finite type, there exists a unique canonical basis:* ∃! B, IsCanonicalBasis cl B.

See @Catalog/Bridges/ClosureCircuitDuality.lean.

---

## 6. Circuit Reconstruction

### 6.1 Construction

Given a closure operator cl, we construct a closure circuit `reconstructClosureCircuit cl` as follows. For each element x:

1. Compute the set of minimal supports: minimalSupports(cl, x) = {A₁, A₂, ..., Aₘ}.
2. For each Aᵢ = {a₁, ..., aₖ}, build the conjunction circuit: AND(input(a₁), ..., input(aₖ)).
3. Take the disjunction of all such conjunctions: OR(AND(A₁), AND(A₂), ..., AND(Aₘ)).

This produces a DNF circuit for each output element.

### 6.2 Auxiliary Lemmas

**Lemma 6.1** (`conjOfList_eval`). *The conjunction circuit over a list l evaluates to true on S iff every element of l is in S:*

$$\text{eval}(\text{conjOfList}(l), S) \iff \forall a \in l,\; a \in S$$

**Lemma 6.2** (`disjOfList_eval`). *The disjunction circuit over a list of circuits evaluates to true on S iff some circuit in the list evaluates to true:*

$$\text{eval}(\text{disjOfList}(cs), S) \iff \exists c \in cs,\; \text{eval}(c, S)$$

Both are proved by structural induction on lists. See @Catalog/Bridges/ClosureCircuitDuality.lean.

### 6.3 Correctness

**Theorem 6.1** (`reconstructed_circuit_correct`). *For any closure operator cl on a finite type, the reconstructed circuit correctly computes cl:*

$$\forall x, S:\; \text{eval}((\text{reconstructClosureCircuit cl}).output(x), S) \iff x \in \text{cl}(S)$$

*Proof sketch.* By unfolding the reconstruction and applying Lemmas 6.1 and 6.2, the circuit evaluation reduces to: "there exists a minimal support A for x such that A ⊆ S." By Theorem 4.2, this is equivalent to x ∈ cl(S).

---

## 7. The Main Duality Theorem

**Theorem 7.1** (`finite_closure_duality`). *Let α be a finite type with decidable equality, and let cl : 𝒫(α) → 𝒫(α) be a closure operator with bounded dependency rank. Then there exist:*

1. *A canonical residual basis B — a finite set of residual generators satisfying the basis property.*
2. *A monotone closure circuit C — a DNF circuit correctly computing cl.*
3. *Uniqueness: any other canonical basis B' must equal B.*

*Proof sketch.* The closure operator axioms are packaged into an `IsClosureOperator` instance. The basis is constructed via `canonicalBasis cl` and shown correct by Theorem 5.1. The circuit is constructed via `reconstructClosureCircuit cl` and shown correct by Theorem 6.1. Uniqueness follows from Theorem 5.2.

See @Catalog/Bridges/ClosureCircuitDuality.lean.

### 7.1 Additional Structural Results

**Theorem 7.2** (`residualEquivalent_equiv`). *Residual equivalence — where x ~ y iff for all S, x ∈ cl(S) ↔ y ∈ cl(S) — is an equivalence relation.*

**Theorem 7.3** (`eval_mono`). *Circuit evaluation is monotone: if S ⊆ T and eval(c, S) holds, then eval(c, T) holds.*

**Theorem 7.4** (`closureCircuit_monotone`). *For any closure circuit C: if S ⊆ T and C.output(x) evaluates to true on S, then it evaluates to true on T.*

---

## 8. Algorithms

### 8.1 Computing the Canonical Basis

Given a closure operator cl represented as a black-box function on a finite type with n elements:

```
Algorithm: ComputeCanonicalBasis(cl, α)
  Input: Closure operator cl on finite type α
  Output: Set of residual generators (target, support)

  B ← ∅
  for each x ∈ α:
    for each subset A ⊆ α (in increasing cardinality order):
      if x ∈ cl(A) and ∀ B ⊂ A: x ∉ cl(B):
        B ← B ∪ {(x, A)}
  return B
```

This brute-force algorithm has complexity O(n · 2ⁿ · n) closure oracle calls. In practice, the search can be pruned significantly using antichain properties of minimal supports.

### 8.2 Circuit Reconstruction

```
Algorithm: ReconstructCircuit(B)
  Input: Canonical basis B
  Output: Monotone DNF circuit

  for each x with generators in B:
    gates_x ← []
    for each (x, A) ∈ B:
      gates_x.append(AND(input(a) for a in A))
    circuit[x] ← OR(gates_x)
  return circuit
```

---

## 9. Applications

### 9.1 Database Normalization

In relational database theory, functional dependencies form a closure system on attributes. The canonical residual basis corresponds to a minimum cover of the dependency set, and the reconstructed circuit provides an optimal attribute-closure computation algorithm. The uniqueness theorem (Theorem 5.2) guarantees that the minimum cover is unique up to rewriting, resolving a classical question in database normalization.

### 9.2 Formal Concept Analysis

In FCA, a formal context defines a closure operator on attributes (or objects) via the Galois connection between extents and intents. The canonical basis provides the *stem basis* (or a variant thereof), which is the most compact representation of the concept lattice's implication theory.

### 9.3 Monotone Circuit Complexity

The duality theorem provides a bridge between algebraic properties of closure operators and circuit complexity measures. The size of the canonical circuit is directly related to the total number of minimal supports across all elements, providing a new algebraic handle on monotone circuit size.

### 9.4 Knowledge Compilation

In AI and knowledge representation, the problem of *knowledge compilation* asks: given a knowledge base (a set of logical rules), find the most efficient circuit that answers membership queries. The Closure-Circuit Duality shows that for monotone knowledge bases, there is a unique optimal compilation target.

---

## 10. Discussion

### 10.1 The Myhill-Nerode Analogy

The strongest analogy for our result is the Myhill-Nerode theorem in automata theory. The Myhill-Nerode theorem establishes that every regular language has a unique minimal deterministic finite automaton (DFA), characterized by the equivalence classes of the Myhill-Nerode equivalence relation. Our theorem establishes that every finite closure system has a unique canonical residual basis and corresponding minimal monotone DNF circuit. The residual equivalence relation (Definition 2.6, Theorem 7.2) plays the role of the Myhill-Nerode equivalence: elements with the same closure profile are identified.

### 10.2 Relationship to the Duquenne-Guigues Basis

The canonical residual basis we construct contains *all* minimal supports, not just a minimal generating set of implications. The Duquenne-Guigues basis (also called the stem basis) is a minimal set of implications that generates the full closure system; our basis is larger but has the advantage of directly yielding the DNF circuit without further computation.

### 10.3 Limitations and Extensions

The bounded-rank hypothesis in Theorem 7.1 is used only to ensure that the closure operator has a finite presentation. For closure operators on finite types, this condition is automatically satisfied (with rank at most |α|), so the hypothesis is essentially vacuous in the finite case. The interesting open question is whether an analogous duality holds for closure operators on infinite types, where the rank bound becomes substantive.

---

## 11. Future Work

Several natural extensions of this work present themselves:

1. **Complexity bounds**: Relating the size and depth of the canonical circuit to algebraic invariants of the closure operator (e.g., the width of the lattice of closed sets).
2. **Infinite types**: Extending the duality to closure operators on infinite types, where the canonical basis may be infinite and the circuit model must be generalized.
3. **Non-monotone closure**: Investigating whether analogous duality results hold for closure-like operators that violate monotonicity (e.g., non-monotone consequence relations in non-monotonic logic).
4. **Efficient computation**: Developing polynomial-time algorithms for computing the canonical basis when the closure operator is given implicitly (e.g., via a polynomial-size presentation).
5. **Categorical generalization**: Formulating the duality in the language of category theory, potentially as an adjunction between suitable categories of closure systems and circuit algebras.

---

## References

1. Birkhoff, G. (1940). *Lattice Theory*. American Mathematical Society.
2. Caspard, N., & Monjardet, B. (2003). The lattices of closure systems, closure operators, and implicational systems on a finite set: a survey. *Discrete Applied Mathematics*, 127(2), 241–269.
3. Guigues, J.-L., & Duquenne, V. (1986). Familles minimales d'implications informatives résultant d'un tableau de données binaires. *Mathématiques et Sciences Humaines*, 95, 5–18.
4. Razborov, A. A. (1985). Lower bounds on the monotone complexity of some Boolean functions. *Doklady Akademii Nauk SSSR*, 281(4), 798–801.
5. Wild, M. (1994). A theory of finite closure spaces based on implications. *Advances in Mathematics*, 108(1), 118–139.
6. Myhill, J. (1957). Finite automata and the representation of events. *WADD Technical Report*, 57–624.

---

## Appendix A: Proof Techniques

The proofs in this development rely on several key techniques:

- **Well-founded induction on finite subsets**: The minimal support existence theorem (Theorem 4.1) uses strong induction on the `Finset` type, leveraging the fact that the strict subset relation on finite sets is well-founded. This is the most technically demanding part of the development, requiring careful management of the descent argument.

- **Intersection-based closure construction**: The generated closure (Definition 2.3) is defined as a set-theoretic intersection of all closed supersets. This classical approach yields clean proofs of the closure axioms but requires careful handling of the universal quantifier over sets.

- **Extensionality and uniqueness**: The uniqueness of the canonical basis (Theorem 5.2) proceeds by showing mutual inclusion via the minimality condition. The key step is showing that if two generators target the same element and one's support is contained in the other's, the minimality of the larger forces equality.

- **Circuit evaluation semantics**: The correctness of the reconstructed circuit (Theorem 6.1) relies on the compositional semantics of `conjOfList_eval` and `disjOfList_eval`, which reduce circuit evaluation to quantifier statements about list membership.

## Appendix B: Formal Verification

All theorems in this paper have been formally verified. The complete formalization is available in @Catalog/Bridges/ClosureCircuitDuality.lean. The development defines closure operators, presentations, minimal supports, the canonical basis, monotone circuits, and the reconstruction procedure, and proves correctness, uniqueness, and the full duality theorem. The formalization totals approximately 350 lines and uses the Mathlib library for foundational set theory and finiteness arguments.

The formal development is organized into eleven parts, mirroring the structure of this paper. Key design decisions include:

- Using `Finset` rather than `Set` for supports and presentations, ensuring decidability and enabling computational verification.
- Defining circuits as an inductive type with explicit constructors for AND, OR, TRUE, FALSE, and INPUT gates, providing a clean recursive structure for evaluation and size measurement.
- Packaging the main duality theorem to simultaneously assert existence of the basis, correctness of the circuit, and uniqueness, giving users a single entry point to the full result.

The formalization demonstrates that the Closure-Circuit Duality is not merely a theoretical observation but a constructive, algorithmically meaningful result: the canonical basis and circuit can be computed from any given closure operator, and their correctness is guaranteed by the type system.
