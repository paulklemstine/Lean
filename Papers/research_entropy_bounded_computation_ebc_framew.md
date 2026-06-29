# Closure-Circuit Duality: Canonical Residual Bases and Monotone Circuit Reconstruction

## Abstract

We establish a duality between finite closure systems and monotone Boolean circuits. Given a closure operator on a finite type—an extensive, monotone, idempotent function on sets—we prove the existence of a unique *canonical residual basis* consisting of minimal support generators, and construct an explicit monotone disjunctive normal form (DNF) circuit that correctly computes the closure. The main theorem asserts that the algebraic structure (closure operator), the combinatorial invariant (canonical basis), and the computational model (monotone circuit) mutually determine one another. All results have been formally verified. The framework unifies ideas from lattice theory, circuit complexity, database theory, and formal concept analysis under a single structural theorem.

**Keywords**: closure operator, monotone circuit, canonical basis, DNF circuit, residual generator, Myhill-Nerode, formal concept analysis

---

## 1. Introduction

Closure operators are among the most pervasive structures in mathematics and computer science. They appear as deductive closure in logic, transitive closure in graph theory, algebraic closure in field theory, topological closure in point-set topology, and attribute closure in relational databases. Despite this ubiquity, the precise computational content of a closure operator—what circuits are needed to compute it, and whether there is a canonical choice—has not been systematically formalized.

This paper addresses the following question: **Given a finite closure system, what is the minimal computational representation that exactly captures it, and is that representation unique?**

Our answer proceeds in three stages:

1. **Minimal Support Theory** (§3): We prove that every element in a closure has a minimal support—an irreducible generating set—and that closure membership is completely characterized by the existence of such supports.

2. **Canonical Residual Basis** (§4): We collect all minimal supports into a canonical basis and prove it is unique: any two bases satisfying the characterization property must be identical.

3. **Circuit Reconstruction** (§5): We construct a monotone DNF circuit from the canonical basis and prove it correctly computes the closure operator.

The main duality theorem (§6) packages these results: every closure operator on a finite type with bounded dependency rank admits a unique canonical basis and a corresponding monotone circuit, and these three objects mutually determine each other.

### 1.1 Related Work

The canonical basis of a closure system is closely related to the *Duquenne-Guigues basis* (also called the *stem basis*) in formal concept analysis [Ganter & Wille, 1999]. Our formulation via minimal supports differs from the implicational presentation used in FCA, but the uniqueness result is analogous.

The connection between closure operators and monotone circuits has been explored in circuit complexity, where Razborov's method of approximations uses closure properties to establish monotone circuit lower bounds. Our work goes in the opposite direction: we construct circuits *from* closures rather than analyzing closures of circuits.

The Myhill-Nerode theorem for regular languages provides a structural parallel: both results establish that an algebraic invariant (residual equivalence classes / congruence classes) uniquely determines a minimal computational representation (canonical basis / minimal DFA).

---

## 2. Preliminaries

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). Let α be a finite type. A function cl : 𝒫(α) → 𝒫(α) is a *closure operator* if it satisfies:

- **Extensiveness**: S ⊆ cl(S) for all S ⊆ α
- **Monotonicity**: S ⊆ T implies cl(S) ⊆ cl(T) for all S, T ⊆ α
- **Idempotency**: cl(cl(S)) = cl(S) for all S ⊆ α

(See `IsClosureOperator` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 2.2 Closure Presentations

**Definition 2.2** (Closure Presentation). A *closure presentation* over α is a finite set P of rules (A, x) where A ⊆ α is a finite premise set and x ∈ α is a conclusion. A set S is *closed under P* if for every rule (A, x) ∈ P, A ⊆ S implies x ∈ S.

(See `ClosurePresentation` and `ClosedUnder` in @Catalog/Bridges/ClosureCircuitDuality.lean)

**Definition 2.3** (Generated Closure). The closure of S under presentation P is the intersection of all closed supersets of S:

$$\text{cl}_P(S) = \bigcap \{ T \supseteq S \mid T \text{ is closed under } P \}$$

(See `GeneratedClosure` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 2.3 Bounded Rank

**Definition 2.4** (Rank-Bounded Closure). A closure operator cl has *rank bounded by r* if there exists a presentation P such that every rule in P has at most r premises, and P generates cl.

(See `ClosureRankBounded` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 2.4 Monotone Circuits

**Definition 2.5** (Monotone Circuit). A monotone Boolean circuit over inputs α is an inductively defined tree with:
- Input gates (reading membership of a single element)
- Constant gates (⊤ and ⊥)
- Conjunction gates (AND of two subcircuits)
- Disjunction gates (OR of two subcircuits)

No negation gates are permitted.

(See `MonotoneCircuit` in @Catalog/Bridges/ClosureCircuitDuality.lean)

A circuit is evaluated against a set S, where input gates test membership in S, and gates compose in the obvious Boolean manner.

---

## 3. Minimal Support Theory

### 3.1 Minimal Supports

**Definition 3.1** (Minimal Support). A finite set A ⊆ α is a *minimal support* for element x under closure operator cl if:
1. x ∈ cl(A), and
2. For every proper subset B ⊊ A, x ∉ cl(B).

(See `IsMinimalSupport` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 3.2 Existence of Minimal Supports

**Theorem 3.2** (Minimal Support Existence). Let cl be a closure operator on a finite type α. For any finite set S and any element x ∈ cl(S), there exists a subset A ⊆ S that is a minimal support for x.

*Proof sketch.* By well-founded induction on the size of the support set. Given x ∈ cl(S), if S is already minimal, we are done. Otherwise, there exists a proper subset S' ⊊ S with x ∈ cl(S'). Since S is finite and S' is strictly smaller, the descent terminates. □

(See `minimal_support_exists` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 3.3 Characterization of Closure Membership

**Theorem 3.3** (Closure Characterization). For a closure operator cl on a finite type α, an element x belongs to cl(S) if and only if there exists a minimal support A for x such that A ⊆ S.

*Proof sketch.* The forward direction follows from Theorem 3.2: if x ∈ cl(S), extract a minimal support from S. The reverse direction follows from monotonicity: if A is a minimal support with A ⊆ S, then x ∈ cl(A) ⊆ cl(S). □

(See `closure_iff_contains_minimal_support` in @Catalog/Bridges/ClosureCircuitDuality.lean)

This characterization is the algebraic engine of the duality: it reduces closure membership—an intensional property defined by fixed-point iteration—to an extensional property about subset containment.

---

## 4. The Canonical Residual Basis

### 4.1 Residual Equivalence

**Definition 4.1** (Residual Equivalence). Two elements x, y ∈ α are *residually equivalent* under cl if they have identical closure profiles: for every set S, x ∈ cl(S) ↔ y ∈ cl(S).

(See `ResidualEquivalent` in @Catalog/Bridges/ClosureCircuitDuality.lean)

**Proposition 4.2.** Residual equivalence is an equivalence relation.

(See `residualEquivalent_equiv` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 4.2 Residual Generators

**Definition 4.3** (Residual Generator). A *residual generator* is a pair (x, A) where x ∈ α is a target element and A ⊆ α is a finite support set.

(See `ResidualGenerator` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 4.3 The Canonical Basis

**Definition 4.4** (Canonical Basis). The *canonical residual basis* of a closure operator cl is the set of all residual generators (x, A) where A is a minimal support for x:

$$\mathcal{B}(cl) = \{ (x, A) \mid A \text{ is a minimal support for } x \text{ under } cl \}$$

(See `canonicalBasis` in @Catalog/Bridges/ClosureCircuitDuality.lean)

**Definition 4.5** (Basis Property). A set B of residual generators is a *canonical basis* for cl if:
1. Every generator (x, A) ∈ B is a minimal support for x.
2. For every element x and set S: x ∈ cl(S) ↔ ∃(x, A) ∈ B with A ⊆ S.

(See `IsCanonicalBasis` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 4.4 Basis Theorem

**Theorem 4.6** (Basis Correctness). The canonical basis of any closure operator cl satisfies the basis property.

*Proof sketch.* Minimality of each generator follows by construction. The characterization property follows directly from Theorem 3.3. □

(See `canonical_basis_is_basis` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 4.5 Uniqueness

**Theorem 4.7** (Basis Uniqueness). If B₁ and B₂ both satisfy the canonical basis property for the same closure operator cl, then B₁ = B₂.

*Proof sketch.* Let (x, A) ∈ B₁. Since A is a minimal support for x, we have x ∈ cl(A). By the characterization property of B₂, there exists (x, A') ∈ B₂ with A' ⊆ A. But (x, A') is also a minimal support for x (by property 1 of B₂), and A' ⊆ A with A minimal forces A' = A. Hence (x, A) ∈ B₂. The symmetric argument gives B₂ ⊆ B₁. □

(See `canonical_basis_unique` in @Catalog/Bridges/ClosureCircuitDuality.lean)

**Corollary 4.8** (Existence and Uniqueness). For every closure operator cl on a finite type, there exists a unique canonical residual basis.

(See `closure_basis_canonical` in @Catalog/Bridges/ClosureCircuitDuality.lean)

---

## 5. Circuit Reconstruction

### 5.1 Monotone Circuit Evaluation

The evaluation function for monotone circuits is defined recursively:
- eval(input(a), S) = (a ∈ S)
- eval(⊤, S) = True
- eval(⊥, S) = False
- eval(c₁ ∧ c₂, S) = eval(c₁, S) ∧ eval(c₂, S)
- eval(c₁ ∨ c₂, S) = eval(c₁, S) ∨ eval(c₂, S)

**Theorem 5.1** (Circuit Monotonicity). For any monotone circuit c, if S ⊆ T and eval(c, S) holds, then eval(c, T) holds.

*Proof sketch.* Structural induction on the circuit. □

(See `MonotoneCircuit.eval_mono` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 5.2 DNF Construction

**Algorithm 5.2** (Circuit Reconstruction). Given a closure operator cl on a finite type α, construct a closure circuit C where, for each element x:

$$C(x) = \bigvee_{A \in \text{minSupp}(x)} \bigwedge_{a \in A} \text{input}(a)$$

This is a disjunction of conjunctions—a DNF formula where each conjunction corresponds to one minimal support.

(See `reconstructClosureCircuit` in @Catalog/Bridges/ClosureCircuitDuality.lean)

The construction uses two helper functions:
- `conjOfList` builds a conjunction circuit from a list of inputs
- `disjOfList` builds a disjunction from a list of subcircuits

**Lemma 5.3.** conjOfList(l) evaluates to true on S iff every element of l belongs to S.

(See `conjOfList_eval` in @Catalog/Bridges/ClosureCircuitDuality.lean)

**Lemma 5.4.** disjOfList(cs) evaluates to true on S iff some circuit in cs evaluates to true on S.

(See `disjOfList_eval` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 5.3 Correctness

**Theorem 5.5** (Circuit Correctness). The reconstructed DNF circuit correctly computes the closure operator: for every element x and set S,

$$\text{eval}(C(x), S) \iff x \in cl(S)$$

*Proof sketch.* The evaluation of the DNF circuit reduces, via Lemmas 5.3 and 5.4, to: "there exists a minimal support A for x such that A ⊆ S." By Theorem 3.3, this is equivalent to x ∈ cl(S). □

(See `reconstructed_circuit_correct` in @Catalog/Bridges/ClosureCircuitDuality.lean)

---

## 6. The Main Duality Theorem

**Theorem 6.1** (Finite Closure-Circuit Duality). Let cl be a closure operator on a finite type α with bounded dependency rank r. Then there exist:
1. A canonical residual basis B characterizing cl,
2. A monotone DNF closure circuit C computing cl,

such that:
- C correctly computes cl: for all x and S, eval(C(x), S) ↔ x ∈ cl(S),
- B is unique: any basis B' satisfying the basis property equals B.

(See `finite_closure_duality` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 6.1 The Duality Correspondence

The theorem establishes a three-way correspondence:

| Algebraic (cl) | Combinatorial (B) | Computational (C) |
|---|---|---|
| Closure operator | Canonical basis | Monotone DNF circuit |
| cl(S) = fixed point | (x, A) ∈ B iff A minimal for x | C(x) = ⋁ᴬ ⋀ₐ input(a) |
| Extensiveness | Every element has a self-support | Circuit includes trivial gates |
| Monotonicity | A ⊆ S → support contained | eval_mono |
| Idempotency | Supports of supports reduce | Circuit stable under iteration |

Each column determines the other two: from cl, extract B and construct C; from B, define cl and build C; from C, recover cl and extract B.

---

## 7. Supporting Results

### 7.1 Generated Closures

**Theorem 7.1.** The closure generated by any presentation P is a closure operator.

*Proof sketch.* Extensiveness: S is contained in every superset, hence in their intersection. Monotonicity: if S ⊆ T, every closed superset of T is also a closed superset of S, so the intersection for T is at least as small. Idempotency: cl(cl(S)) ⊆ cl(S) because cl(S) is itself a closed superset of cl(S); the reverse inclusion follows from extensiveness. □

(See `generatedClosure_isClosureOperator` in @Catalog/Bridges/ClosureCircuitDuality.lean)

### 7.2 Closure Circuit Monotonicity

**Theorem 7.2.** For any closure circuit C, if S ⊆ T and eval(C(x), S) holds, then eval(C(x), T) holds.

(See `closureCircuit_monotone` in @Catalog/Bridges/ClosureCircuitDuality.lean)

---

## 8. Applications

### 8.1 Database Schema Optimization

In relational database theory, functional dependencies {A₁, ..., Aₖ} → B form a closure system on attributes. The canonical residual basis gives the minimal, non-redundant set of functional dependencies—Armstrong's axioms generate all others from this basis. The reconstructed circuit provides an efficient attribute closure algorithm.

### 8.2 Formal Concept Analysis

In formal concept analysis, the intent operator on a formal context is a closure operator on attributes. The canonical basis corresponds to the stem basis (Duquenne-Guigues basis), which is known to be the unique minimum-cardinality basis of implications. Our uniqueness theorem provides a new proof of this classical result.

### 8.3 Monotone Circuit Complexity

The duality theorem establishes that monotone DNF is a natural circuit model for closure operators. For a closure operator with N minimal supports of maximum size k, the reconstructed circuit has size O(N · k). This connects the combinatorial complexity of the closure system (number and size of minimal supports) to the circuit complexity of computing it.

### 8.4 Knowledge Compilation

In AI and knowledge representation, the problem of compiling a knowledge base into an efficient query-answering structure is precisely the problem of moving from a closure presentation to a circuit. The duality theorem guarantees that this compilation always succeeds for finite closure systems, and the result is canonical.

---

## 9. Discussion

### 9.1 Comparison with Myhill-Nerode

The structural parallel with the Myhill-Nerode theorem for regular languages is striking:

| Myhill-Nerode | Closure-Circuit Duality |
|---|---|
| Regular language L | Closure operator cl |
| Right congruence ≡_L | Residual equivalence |
| Equivalence classes | Minimal support sets |
| Minimal DFA | Canonical DNF circuit |
| Uniqueness of minimal DFA | Uniqueness of canonical basis |

Both results establish that an algebraic invariant (equivalence relation on inputs / collection of minimal supports) uniquely determines a minimal computational model. The key difference is that Myhill-Nerode produces a sequential machine (DFA), while our result produces a parallel circuit (DNF).

### 9.2 Rank Dependence

The bounded rank condition in the main duality theorem ensures that the closure presentation has bounded rule size. This is always satisfied for finite types (where the rank is at most |α|), but the bound affects the circuit complexity: rank-r closure operators yield DNF circuits where each conjunction has at most r inputs.

### 9.3 The Role of Bounded Rank

The bounded rank hypothesis in the main duality theorem deserves careful attention. While every closure operator on a finite type trivially has rank at most |α|, the rank parameter affects both the canonical basis size and the circuit complexity. A rank-1 closure operator (where every rule has a single premise) corresponds to a directed graph's reachability relation, and the canonical basis reduces to the edge set. Rank-2 closures already capture interesting phenomena like the database dependencies in our examples. Higher ranks correspond to increasingly complex multi-premise inference.

The rank also provides a bridge to parameterized complexity: for fixed rank r, the canonical basis has polynomial size in |α|, with degree at most r. This means the reconstructed circuit is polynomial for bounded-rank closures but may be exponential for unbounded rank.

### 9.4 Constructivity and Computability

The canonical basis construction is effective: given an oracle for the closure operator, the basis can be computed by exhaustive enumeration of all subsets. For a type of size n, this requires checking O(2ⁿ) subsets per element, giving an overall complexity of O(n · 2ⁿ). For bounded-rank closures, this can be improved to O(nʳ⁺¹) by only checking subsets of size at most r.

The circuit reconstruction is equally constructive: once the basis is known, the circuit is built deterministically by the DNF construction. No search or optimization is needed.

### 9.5 Limitations

The current framework is restricted to finite types. Extending to infinite domains (e.g., topological closures on ℝⁿ) would require a different approach, likely involving infinite circuits or approximation schemes. The finiteness assumption is essential for the well-founded descent in the minimal support existence proof.

Another limitation is the restriction to monotone circuits. Non-monotone closure-like operators (e.g., stable model semantics in logic programming) do not admit a direct DNF representation. Extending the duality to non-monotone settings would require incorporating negation gates, fundamentally changing the circuit model.

---

## 10. Future Work

Several directions emerge from this work:

1. **Quantum extensions**: The entropy-bounded computation framework suggests connections between closure systems and quantum measurement. Unitary gates are reversible (zero entropy cost), while measurements produce entropy—the canonical basis may have a quantum analog where "minimal supports" correspond to minimal measurement sets.

2. **Entropy complexity hierarchy**: Defining complexity classes by Landauer entropy budget and establishing strictness via diagonalization, connecting closure rank to thermodynamic cost.

3. **Algorithmic Landauer costs**: Computing the exact Landauer cost of comparison-based sorting as ⌈log₂(n!)⌉ · kT · ln(2), connecting information-theoretic lower bounds to thermodynamic principles via the closure framework.

4. **Reversible computation**: Formalizing Bennett's pebble game as a reversible closure computation with zero entropy cost but polynomial time overhead.

5. **Physical speed limits**: Connecting the Margolus-Levitin bound to closure computation throughput.

---

## 11. Conclusion

The Closure-Circuit Duality theorem establishes that finite closure systems possess a rigid internal structure: a unique canonical residual basis that serves as both an algebraic invariant and a computational blueprint. The reconstructed monotone DNF circuit is not merely one possible implementation of the closure—it is the canonical one, determined by the operator's intrinsic mathematical structure.

This result provides a new bridge between algebra and computation, extending the Myhill-Nerode paradigm from sequential machines to parallel circuits. The formal verification of all results provides the highest level of mathematical certainty for these claims.

---

## References

1. Ganter, B. & Wille, R. (1999). *Formal Concept Analysis: Mathematical Foundations*. Springer.
2. Caspard, N. & Monjardet, B. (2003). The lattices of closure systems, closure operators, and implicational systems on a finite set: a survey. *Discrete Applied Mathematics*, 127(2), 241-269.
3. Wild, M. (1994). A theory of finite closure spaces based on implications. *Advances in Mathematics*, 108(1), 118-139.
4. Razborov, A.A. (1985). Lower bounds on monotone complexity of some Boolean functions. *Doklady Akademii Nauk SSSR*, 281(4), 798-801.

---

## Appendix: Formal Verification

All theorems in this paper have been formally verified. The complete formalization is available at @Catalog/Bridges/ClosureCircuitDuality.lean. The formalization consists of approximately 350 lines covering:

- 5 core structures/definitions (IsClosureOperator, ClosurePresentation, ResidualGenerator, MonotoneCircuit, ClosureCircuit)
- 8 main theorems (generatedClosure_isClosureOperator, minimal_support_exists, closure_iff_contains_minimal_support, canonical_basis_is_basis, canonical_basis_unique, closure_basis_canonical, reconstructed_circuit_correct, finite_closure_duality)
- 4 supporting lemmas (eval_mono, conjOfList_eval, disjOfList_eval, closureCircuit_monotone)
- 1 equivalence relation (residualEquivalent_equiv)

No axioms beyond the standard foundations (propext, Classical.choice, Quot.sound) are used.
