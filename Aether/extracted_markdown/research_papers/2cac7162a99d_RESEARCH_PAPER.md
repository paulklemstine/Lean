# Closure-Circuit Duality: Canonical Residual Bases and Monotone Circuit Reconstruction for Finite Closure Operators

## Abstract

We establish a duality between finite closure systems and monotone Boolean circuits. Every closure operator on a finite type admits a unique canonical residual basis of minimal generators, and this basis yields a monotone DNF (disjunctive normal form) circuit that correctly computes the closure. The key results are: (1) implication-generated closures are closure operators; (2) every element in a closure has a minimal support set; (3) closure membership is equivalent to the existence of a minimal support; (4) the canonical residual basis exists and is unique; and (5) the DNF circuit reconstructed from the basis correctly computes the closure. The main duality theorem packages these results: any closure operator with bounded dependency rank admits a canonical basis and a corresponding monotone circuit, with the basis being an intrinsic invariant. All results have been machine-verified. The formalization is available in `Catalog/Bridges/ClosureCircuitDuality.lean`.

**Keywords**: closure operator, monotone circuit, residual basis, canonical form, DNF, circuit complexity, formal verification

---

## 1. Introduction

Closure operators are among the most ubiquitous structures in mathematics. They appear in topology (topological closure), algebra (span, generated subgroup), logic (deductive closure), database theory (functional dependencies), and formal concept analysis. Despite this ubiquity, the computational content of closure operators — particularly the question of canonical circuit representations — has received less systematic attention than their algebraic properties.

This paper establishes a tight correspondence between two ostensibly different objects:

1. **Closure operators** on finite sets, characterized by extensiveness, monotonicity, and idempotence.
2. **Monotone Boolean circuits** in disjunctive normal form, built from AND and OR gates without negation.

The central result is a **Finite Closure-Circuit Duality Theorem**: every closure operator on a finite type admits a unique canonical residual basis — the collection of all minimal support sets for each element — and the DNF circuit constructed from this basis correctly and completely computes the closure. Moreover, this basis is unique, making it an intrinsic invariant of the closure operator.

The analogy with the Myhill–Nerode theorem is deliberate. Just as the Myhill–Nerode theorem provides a canonical minimal automaton for every regular language via equivalence classes of right-congruences, our result provides a canonical minimal circuit for every finite closure operator via minimal support sets. The "residual" terminology reflects this connection: residual equivalence classes partition elements by their closure profile, and the canonical basis is determined by the structure of these classes.

### 1.1 Related Work

Closure operators and their axiomatizations are classical; see Birkhoff's lattice theory and the extensive literature on Galois connections. The connection to implication systems (also called Horn clauses or functional dependencies) is well-studied in database theory, particularly in the context of Armstrong's axioms and canonical covers.

Monotone circuit complexity has been studied extensively since Razborov's celebrated lower bounds for the clique function. The connection between closure systems and monotone circuits appears implicitly in several works on circuit complexity and knowledge compilation, but a systematic duality theorem with a uniqueness guarantee appears to be new.

The notion of a canonical basis for closure systems is related to the Duquenne–Guigues basis (also called the stem basis) in formal concept analysis. Our canonical residual basis differs in that it collects *all* minimal supports rather than a minimal generating set of implications, providing a direct circuit interpretation.

---

## 2. Definitions

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). Let α be a type. A function cl : 𝒫(α) → 𝒫(α) is a *closure operator* if it satisfies:
- **Extensiveness**: S ⊆ cl(S) for all S.
- **Monotonicity**: S ⊆ T implies cl(S) ⊆ cl(T).
- **Idempotence**: cl(cl(S)) = cl(S) for all S.

This is formalized as the structure `IsClosureOperator` in `Catalog/Bridges/ClosureCircuitDuality.lean`.

### 2.2 Closure Presentations

**Definition 2.2** (Closure Presentation). A *closure presentation* over a type α with decidable equality is a finite set P of rules (A, b), where A ⊆ α is a finite set of premises and b ∈ α is a conclusion.

**Definition 2.3** (Closed Under). A set S is *closed under* a presentation P if for every rule (A, b) ∈ P, whenever A ⊆ S, we have b ∈ S.

**Definition 2.4** (Generated Closure). The *closure of S under P* is the intersection of all sets T satisfying S ⊆ T and T closed under P:

$$\text{cl}_P(S) = \bigcap \{ T \mid S \subseteq T \text{ and } T \text{ closed under } P \}$$

**Definition 2.5** (Bounded Rank). A closure operator cl has *rank bounded by r* if there exists a presentation P such that every rule in P has at most r premises, and cl_P = cl.

### 2.3 Minimal Supports and the Canonical Basis

**Definition 2.6** (Minimal Support). A finite set A is a *minimal support* for element x under closure operator cl if:
1. x ∈ cl(A), and
2. For every proper subset B ⊂ A, x ∉ cl(B).

**Definition 2.7** (Canonical Residual Basis). The *canonical residual basis* of a closure operator cl on a finite type α is the set of all residual generators (x, A) where A is a minimal support for x:

$$\mathcal{B}(cl) = \{ (x, A) \mid A \text{ is a minimal support for } x \text{ under } cl \}$$

**Definition 2.8** (Canonical Basis Property). A set B of residual generators satisfies the *canonical basis property* for cl if:
1. Every generator (x, A) ∈ B has A as a minimal support for x.
2. For every element x and set S: x ∈ cl(S) if and only if there exists (x, A) ∈ B with A ⊆ S.

### 2.4 Monotone Circuits

**Definition 2.9** (Monotone Circuit). A *monotone Boolean circuit* over inputs from α is defined inductively:
- `input(a)`: an input gate for element a ∈ α.
- `top`: the constant-true gate.
- `bot`: the constant-false gate.
- `conj(c₁, c₂)`: the AND of two sub-circuits.
- `disj(c₁, c₂)`: the OR of two sub-circuits.

**Definition 2.10** (Circuit Evaluation). The evaluation of a circuit c on a set S is defined recursively:
- eval(input(a), S) = (a ∈ S)
- eval(top, S) = True
- eval(bot, S) = False
- eval(conj(c₁, c₂), S) = eval(c₁, S) ∧ eval(c₂, S)
- eval(disj(c₁, c₂), S) = eval(c₁, S) ∨ eval(c₂, S)

**Definition 2.11** (Closure Circuit). A *closure circuit* is a family of monotone circuits indexed by α: one circuit C(x) for each potential output element x. It *correctly computes* a closure operator cl if for all x and S: eval(C(x), S) ↔ x ∈ cl(S).

### 2.5 Residual Equivalence

**Definition 2.12** (Residual Equivalence). Two elements x, y ∈ α are *residually equivalent* under cl if they have identical closure profiles: for all S, x ∈ cl(S) ↔ y ∈ cl(S).

---

## 3. Main Results

### 3.1 Implication-Generated Closures Are Closure Operators

**Theorem 3.1** (`generatedClosure_isClosureOperator`). *For any closure presentation P, the function cl_P = GeneratedClosure P is a closure operator.*

*Proof sketch.* Extensiveness follows immediately: if x ∈ S, then x belongs to every superset of S, hence to their intersection. Monotonicity: if S ⊆ T, then every closed superset of T is also a closed superset of S, so the intersection for T is taken over a subset of the sets for S. Idempotence: cl_P(S) is itself closed under P (since the intersection of closed sets is closed), so it belongs to the family defining cl_P(cl_P(S)), forcing cl_P(cl_P(S)) ⊆ cl_P(S); the reverse inclusion follows from extensiveness.

The formal proof decomposes into four lemmas: `generatedClosure_extensive`, `generatedClosure_monotone`, `generatedClosure_closedUnder`, and `generatedClosure_idempotent`, found in Part 7 of `Catalog/Bridges/ClosureCircuitDuality.lean`.

### 3.2 Existence of Minimal Supports

**Theorem 3.2** (`minimal_support_exists`). *Let cl be a closure operator and let x ∈ cl(S) for a finite set S. Then there exists A ⊆ S such that A is a minimal support for x.*

*Proof sketch.* By well-founded induction on the strict subset ordering of finite sets. If S itself is already minimal (no proper subset generates x), we are done. Otherwise, there exists a proper subset S' ⊂ S with x ∈ cl(S'). Since S' ⊊ S and finite sets are well-founded under ⊂, the inductive hypothesis applies, yielding a minimal support A ⊆ S' ⊆ S.

This is formalized as `minimal_support_exists` in Part 8 of `Catalog/Bridges/ClosureCircuitDuality.lean`.

### 3.3 Closure Characterization via Minimal Supports

**Theorem 3.3** (`closure_iff_contains_minimal_support`). *Let cl be a closure operator on a finite type. For any element x and set S:*
$$x \in cl(S) \iff \exists A \in \text{minSupp}(cl, x),\; A \subseteq S$$

*Proof sketch.* (⇐) If A is a minimal support for x with A ⊆ S, then x ∈ cl(A) and by monotonicity x ∈ cl(S). (⇒) If x ∈ cl(S), restrict to the finite subset S (using finiteness of the type), apply Theorem 3.2 to obtain a minimal support A ⊆ S, and observe that A belongs to minSupp(cl, x).

This theorem is the key bridge between the algebraic (closure) and computational (circuit) perspectives.

### 3.4 The Canonical Basis Is a Basis

**Theorem 3.4** (`canonical_basis_is_basis`). *For any closure operator cl on a finite type, the canonical residual basis canonicalBasis(cl) satisfies the canonical basis property.*

*Proof sketch.* The first condition (minimality of each generator) follows directly from the construction: canonicalBasis(cl) contains exactly the pairs (x, A) where A ∈ minSupp(cl, x). The second condition (closure characterization) reduces to Theorem 3.3, with a straightforward set-theoretic translation between the two formulations.

### 3.5 Uniqueness of the Canonical Basis

**Theorem 3.5** (`canonical_basis_unique`). *If B₁ and B₂ both satisfy the canonical basis property for cl, then B₁ = B₂.*

*Proof sketch.* We show mutual containment. Suppose (x, A) ∈ B₁. Since A is a minimal support for x, we have x ∈ cl(A). By the characterization property of B₂, there exists (x, A') ∈ B₂ with A' ⊆ A. But (x, A') is also a minimal support (by B₂'s minimality condition), so A' cannot be a proper subset of A (by A's minimality in B₁). Hence A' = A and (x, A) ∈ B₂. The reverse containment is symmetric.

This is the most delicate argument in the development, relying on the interplay of minimality conditions in both bases.

**Corollary 3.6** (`closure_basis_canonical`). *For any closure operator cl on a finite type, there exists a unique canonical residual basis: ∃! B, IsCanonicalBasis cl B.*

### 3.6 Circuit Correctness

**Theorem 3.7** (`reconstructed_circuit_correct`). *The DNF circuit reconstructed from the canonical basis correctly computes the closure operator.*

*Proof sketch.* The reconstructed circuit for element x is:
$$C(x) = \bigvee_{A \in \text{minSupp}(cl, x)} \bigwedge_{a \in A} \text{input}(a)$$

By `conjOfList_eval`, each AND-clause evaluates to true on S iff A ⊆ S. By `disjOfList_eval`, the entire circuit evaluates to true iff some minimal support A is contained in S. By Theorem 3.3, this is equivalent to x ∈ cl(S).

### 3.7 The Main Duality Theorem

**Theorem 3.8** (`finite_closure_duality`). *Let cl be a closure operator on a finite type satisfying extensiveness, monotonicity, and idempotence, with bounded dependency rank r. Then there exist:*
1. *A canonical residual basis B satisfying the basis property,*
2. *A monotone closure circuit C that correctly computes cl,*
3. *such that B is unique: any B' satisfying the basis property equals B.*

This theorem packages all preceding results into a single statement that captures the full duality. The bounded rank hypothesis ensures the closure is finitely presentable; the conclusion provides both the algebraic invariant (the basis) and its computational manifestation (the circuit).

### 3.8 Auxiliary Results

**Theorem 3.9** (`MonotoneCircuit.eval_mono`). *Circuit evaluation is monotone: if S ⊆ T and c evaluates to true on S, then c evaluates to true on T.*

This is proved by structural induction on circuits and is essential for ensuring that the circuit representation respects the monotonicity of the closure operator.

**Theorem 3.10** (`residualEquivalent_equiv`). *Residual equivalence is an equivalence relation.*

This follows directly from the definition: reflexivity, symmetry, and transitivity of biconditionals.

---

## 4. The Reconstruction Algorithm

The circuit reconstruction procedure is constructive and yields an explicit algorithm:

**Algorithm: CanonicalCircuitReconstruction**

**Input**: A closure operator cl on a finite type α (given by oracle access or an implication presentation).

**Output**: A monotone DNF closure circuit computing cl.

1. For each element x ∈ α:
   a. Enumerate all subsets A of α (in increasing cardinality order).
   b. For each A with x ∈ cl(A), check minimality: verify x ∉ cl(B) for all B ⊂ A.
   c. Collect all minimal supports into minSupp(cl, x).
2. For each x, construct the DNF circuit:
   C(x) = ⋁_{A ∈ minSupp(cl, x)} ⋀_{a ∈ A} input(a)
3. Return the closure circuit C = {C(x)}_{x ∈ α}.

**Complexity**: The algorithm examines O(2^|α|) subsets for each of |α| elements, giving a worst-case running time of O(|α| · 2^|α| · T_cl), where T_cl is the time to evaluate the closure oracle. The output circuit has size bounded by |α| · 2^|α| in the worst case, though for closure operators with bounded rank r, the number of minimal supports for each element is at most C(|α|, r), yielding a circuit of size O(|α|² · C(|α|, r)).

---

## 5. Applications

### 5.1 Database Theory

Functional dependencies in relational databases define closure operators on attribute sets. The canonical residual basis corresponds to the set of all minimal keys (candidate keys) for each attribute. Armstrong's axioms provide the closure computation, and our duality theorem guarantees that the minimal key structure is an intrinsic invariant of the dependency set — independent of the particular representation chosen for the functional dependencies.

### 5.2 Formal Concept Analysis

In formal concept analysis (FCA), a formal context (G, M, I) — with objects G, attributes M, and incidence I — induces a closure operator on subsets of M via the derivation operators (·)′ and (·)″. The canonical residual basis provides a complete and irredundant description of the concept lattice. Each minimal support for an attribute m corresponds to a minimal "reason" why m is entailed by a set of other attributes, and the DNF circuit provides a direct computational procedure for concept closure.

### 5.3 Knowledge Compilation

In AI and knowledge representation, the problem of compiling a knowledge base into a form that supports efficient inference is central. Our result shows that any finite closure-based knowledge base can be compiled into a monotone DNF circuit. While DNF is not always the most compact representation, the canonicity guarantee ensures that the compiled form is unique and minimal in a well-defined sense.

### 5.4 Circuit Complexity Lower Bounds

The canonical basis provides a new tool for analyzing monotone circuit complexity. The number and size of minimal supports for a closure operator provide lower bounds on the size of any monotone circuit computing it, since the DNF representation is canonical and any other circuit must encode the same information (possibly more compactly using shared sub-circuits, but never with fewer distinct "reasons" for each output).

---

## 6. Discussion

### 6.1 The Myhill–Nerode Analogy

The analogy between our canonical residual basis and the Myhill–Nerode theorem deserves emphasis. In automata theory, the Myhill–Nerode theorem states that a language L is regular if and only if its syntactic congruence ~_L has finitely many classes, and the minimal DFA for L has exactly one state per class. The canonical DFA is unique up to isomorphism.

In our setting, the residual equivalence relation on elements plays the role of the syntactic congruence, and the canonical basis plays the role of the minimal DFA. Just as the Myhill–Nerode theorem provides a canonical computational device (the minimal automaton) from an algebraic invariant (the congruence), our duality provides a canonical computational device (the DNF circuit) from an algebraic invariant (the minimal support structure).

### 6.2 Constructivity and Computability

The proof is constructive in a strong sense: given an oracle for the closure operator, the canonical basis and circuit can be explicitly computed. The formalization in dependent type theory makes this constructivity manifest — the reconstruction function `reconstructClosureCircuit` is a genuine program that takes a closure operator and produces a circuit.

### 6.3 Uniqueness as a Design Principle

The uniqueness of the canonical basis has practical implications for system design. When multiple teams independently analyze the same dependency structure (e.g., functional dependencies in a database schema), they are guaranteed to arrive at the same canonical basis, regardless of their analysis methodology. This eliminates the need for arbitrary choices and ensures consistency across implementations.

---

## 7. Future Work

Several natural extensions present themselves:

1. **Complexity analysis**: What is the relationship between the rank of a closure operator and the size of its canonical circuit? For rank-r operators, the circuit size is at most O(|α|^{r+1}), but can this be improved?

2. **Infinite closure systems**: The current results assume finite types. Extending to infinite types (with appropriate computability or continuity assumptions) would connect to topological closure operators and domain theory.

3. **Approximate closure**: In applications where exact closure computation is expensive, can the canonical basis be approximated efficiently? What guarantees can be provided for partial bases?

4. **Circuit optimization**: The canonical DNF circuit may not be the smallest monotone circuit computing the closure (shared sub-circuits could yield savings). Studying the gap between the canonical circuit size and the optimal monotone circuit size is a natural complexity-theoretic question.

5. **Connections to tropical and lattice-theoretic methods**: The closure lattice of a finite closure operator is a complete lattice, and the canonical basis provides a particular generating set. Understanding this basis in terms of lattice-theoretic invariants (e.g., the Möbius function, the join-irreducibles) could yield structural insights.

---

## 8. Catalog of Formal Results

All results are formalized in `Catalog/Bridges/ClosureCircuitDuality.lean`. Below is a summary with theorem names:

| # | Result | Formal Name |
|---|--------|-------------|
| 1 | Generated closures are closure operators | `generatedClosure_isClosureOperator` |
| 2 | Minimal supports exist | `minimal_support_exists` |
| 3 | Closure ↔ minimal support containment | `closure_iff_contains_minimal_support` |
| 4 | Canonical basis is a basis | `canonical_basis_is_basis` |
| 5 | Canonical basis is unique | `canonical_basis_unique` |
| 6 | Existence and uniqueness (∃!) | `closure_basis_canonical` |
| 7 | Reconstructed circuit is correct | `reconstructed_circuit_correct` |
| 8 | Main duality theorem | `finite_closure_duality` |
| 9 | Circuit evaluation is monotone | `MonotoneCircuit.eval_mono` |
| 10 | Residual equivalence is an equivalence | `residualEquivalent_equiv` |

---

## References

1. Birkhoff, G. *Lattice Theory*. American Mathematical Society, 3rd edition, 1967.
2. Ganter, B. and Wille, R. *Formal Concept Analysis: Mathematical Foundations*. Springer, 1999.
3. Armstrong, W. W. "Dependency structures of data base relationships." *IFIP Congress*, 1974.
4. Razborov, A. A. "Lower bounds on monotone complexity of the logical permanent." *Mathematical Notes*, 37(6):485–493, 1985.
5. Myhill, J. "Finite automata and the representation of events." WADD TR-57-624, 1957.
6. Nerode, A. "Linear automaton transformations." *Proceedings of the AMS*, 9(4):541–544, 1958.
7. Guigues, J.-L. and Duquenne, V. "Familles minimales d'implications informatives résultant d'un tableau de données binaires." *Mathématiques et Sciences Humaines*, 95:5–18, 1986.
