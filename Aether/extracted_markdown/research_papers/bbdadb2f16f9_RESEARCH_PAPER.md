# Tropical Type Theory: Dependent Types in the Min-Plus Semiring

## Abstract

We present a formally verified semantic kernel of *tropical dependent type theory*, an interpretation of dependent types in which types are cost functions valued in the natural numbers, terms are cost-nonincreasing maps, identity is characterized by idempotent min-equality, and inductive types arise as initial algebras of polynomial functors equipped with rank structure. Working entirely within Lean 4 with Mathlib, we establish four groups of results: (1) decidability of tropical type checking on finite contexts, reducing typing judgments to finite constraint satisfaction; (2) an algebraic characterization of tropical identity through the idempotent meet, with extensionality under injective cost functions; (3) initiality of the natural numbers for the Option functor, with a rank-preserving refinement providing a tropical recursion principle; and (4) well-foundedness of a tropical universe hierarchy with idempotent code normalization. We further develop a semantic calculus including composition of cost-bounded morphisms, weakening, cut/substitution, dependent products, subtyping lattice structure, and congruence laws. All results are machine-verified with no axioms beyond the standard Lean kernel axioms (`propext`, `Quot.sound`).

**Keywords:** tropical semiring, min-plus algebra, dependent types, decidable type checking, initial algebras, well-founded ordering, idempotent normalization, cost semantics, formal verification

---

## 1. Introduction

### 1.1 Motivation

Dependent type theory provides a foundational framework for mathematics and certified programming, where types can depend on terms and proofs are first-class objects. The standard semantic models — sets, groupoids, cubical sets — interpret types as *static classifiers*: a type tells you *what* an object is, not *what it costs*.

Tropical mathematics, rooted in the min-plus semiring (ℕ, min, +), provides a fundamentally different perspective. In tropical algebra, the basic operations are minimum (playing the role of addition) and ordinary addition (playing the role of multiplication). This structure is the native algebra of shortest-path problems, dynamic programming, scheduling, and network optimization [1, 2].

We propose and formalize a semantic interpretation of dependent types in which:
- **Types** are tropical sets: functions α → ℕ assigning costs/ranks to elements.
- **Terms** are cost-nonincreasing maps satisfying ∀ x, B(f(x)) ≤ A(x).
- **Identity** is cost coincidence under the idempotent meet: u =_trop v iff ∀ x, min(u(x), v(x)) = u(x) = v(x).
- **Inductive types** are characterized by tropical initiality of algebras for polynomial functors.
- **Universes** are stratified by rank with idempotent normalization.

### 1.2 Contributions

1. **Decidable tropical type checking** (Theorem 1): On finite base types, the typing judgment TropHom A B f is decidable, reducing to pointwise inequality verification.

2. **Tropical identity characterization** (Theorem 2): Pointwise equality of cost functions is equivalent to the idempotent meet condition, with extensionality under injective cost functions.

3. **Initial algebra semantics** (Theorem 3): ℕ is the initial algebra for the Option functor in the category of tropical algebras, with a rank-preserving refinement.

4. **Well-founded universe hierarchy** (Theorem 4): Tropical universe codes admit an idempotent normalization that is rank-nonincreasing, and the resulting hierarchy is well-founded.

5. **Semantic calculus**: Composition, weakening, cut/substitution, dependent products, subtyping, and congruence laws forming a coherent semantic type theory.

### 1.3 Related Work

**Tropical geometry and algebra.** The min-plus semiring has been extensively studied in combinatorial optimization [1], algebraic geometry [3], and automata theory [4]. Litvinov's survey of idempotent analysis [5] provides the algebraic foundations we build upon.

**Cost-aware type systems.** Resource-aware type systems have been explored in the context of linear logic [6], bounded linear logic [7], and amortized complexity analysis [8]. Our approach differs in using tropical algebra as the semantic foundation rather than linear logic.

**Categorical semantics of type theory.** The interpretation of dependent types via categories with families [9], locally cartesian closed categories [10], and comprehension categories [11] informs our semantic approach. Our tropical algebras can be viewed as objects in an idempotent-enriched category.

**Formal verification.** All results are formalized in Lean 4 [12] using the Mathlib library [13], ensuring correctness beyond human review.

---

## 2. Definitions and Notation

### 2.1 Tropical Sets and Terms

**Definition 2.1** (Tropical Set). A *tropical set* over a type α is a function A : α → ℕ, assigning to each element its cost (or rank, or energy).

**Definition 2.2** (Tropical Term). A *tropical term* over α is a function u : α → ℕ, interpreted as a cost-valued observable.

### 2.2 Tropical Homomorphisms

**Definition 2.3** (Tropical Homomorphism). Given tropical sets A : α → ℕ and B : β → ℕ, a function f : α → β is a *tropical homomorphism* (written f : A →_trop B) if:

    ∀ x, B(f(x)) ≤ A(x)

This is the typing judgment: f is well-typed from A to B if it never increases cost.

**Definition 2.4** (Cost-Bounded Homomorphism). A function f : α → β is a *cost-c tropical homomorphism* (written f : A →_c B) if:

    ∀ x, B(f(x)) ≤ A(x) + c

### 2.3 Tropical Identity

**Definition 2.5** (Tropical Identity). Two functions f, g : α → β are *tropically identical* under B : β → ℕ if:

    TropId B f g := ∀ x, B(f(x)) = B(g(x))

**Definition 2.6** (Tropical Equality). Two tropical terms u, v : α → ℕ are *tropically equal* if:

    TropEq u v := ∀ x, u(x) = v(x)

### 2.4 Tropical Algebras

**Definition 2.7** (Tropical Algebra). A *tropical algebra* is a pair (A, str) where A is a type and str : Option A → A is a structure map for the polynomial functor F(X) = 1 ⊕ X.

**Definition 2.8** (Ranked Tropical Algebra). A *ranked tropical algebra* extends a tropical algebra with a rank function rank : A → ℕ satisfying:
- rank(str(none)) = 0
- ∀ a, rank(str(some a)) = rank(a) + 1

**Definition 2.9** (Algebra Homomorphism). A function f : X.A → Y.A is an *algebra homomorphism* if:

    ∀ z : Option X.A, f(X.str(z)) = Y.str(Option.map f z)

---

## 3. Main Results

### 3.1 Theorem 1: Decidability of Tropical Type Checking

**Theorem 3.1.** *For finite types α with decidable equality, the typing judgment TropHom A B f is decidable for any tropical sets A : α → ℕ, B : β → ℕ, and function f : α → β.*

*Proof sketch.* The judgment TropHom A B f unfolds to ∀ x : α, B(f(x)) ≤ A(x). Since α is a Fintype, this is a decidable universally quantified proposition over a finite domain. The Lean instance resolution system synthesizes the Decidable instance automatically via Fintype.decidableForallFintype. □

**Theorem 3.2** (Finite Verification Principle). *TropHom A B f ↔ ∀ x ∈ Finset.univ, B(f(x)) ≤ A(x).*

This reduces tropical type checking to evaluation of finitely many inequalities — a constraint satisfaction problem solvable in O(|α|) time.

**Theorem 3.3.** *Cost-bounded type checking TropHomC c A B f is also decidable on finite types.*

**Complexity analysis.** For |α| = n, tropical type checking requires n evaluations of A, n evaluations of B ∘ f, and n comparisons. Total time: O(n · (T_A + T_B + T_f)) where T_A, T_B, T_f are the evaluation costs of A, B, f respectively.

### 3.2 Theorem 2: Tropical Identity via Min-Plus Equality

**Theorem 3.4** (Min-Plus Characterization of Identity). *For tropical terms u, v : α → ℕ:*

    TropEq u v ↔ ∀ x, min(u(x), v(x)) = u(x) ∧ min(u(x), v(x)) = v(x)

*Proof sketch.* (→) If u(x) = v(x) for all x, then min(u(x), v(x)) = min(u(x), u(x)) = u(x) by idempotence of min (Nat.min_self), and similarly equals v(x).

(←) If min(u(x), v(x)) = u(x) and min(u(x), v(x)) = v(x), then u(x) = min(u(x), v(x)) = v(x). □

This characterization is significant because it expresses equality purely in terms of the idempotent meet operation, the fundamental operation of tropical algebra.

**Theorem 3.5** (Tropical Extensionality). *If B : β → ℕ is injective and TropId B f g holds, then f = g.*

*Proof sketch.* By definition, TropId B f g gives B(f(x)) = B(g(x)) for all x. Injectivity of B yields f(x) = g(x), hence f = g by function extensionality. □

**Theorem 3.6** (Equivalence Relation). *TropId B is an equivalence relation:*
- Reflexivity: TropId B f f
- Symmetry: TropId B f g → TropId B g f
- Transitivity: TropId B f g → TropId B g h → TropId B f h

### 3.3 Theorem 3: Initial Algebra Semantics

**Theorem 3.7** (Initiality of ℕ). *For any tropical algebra (X, str), there exists a unique function f : ℕ → X.A satisfying the algebra homomorphism property:*

    ∀ z : Option ℕ, f(NatTropAlg.str(z)) = X.str(Option.map f z)

*Proof.* **Existence.** Define f by primitive recursion:
- f(0) = X.str(none)
- f(n + 1) = X.str(some(f(n)))

Verification: For z = none, f(NatTropAlg.str(none)) = f(0) = X.str(none) = X.str(Option.map f none). For z = some(n), f(NatTropAlg.str(some(n))) = f(n+1) = X.str(some(f(n))) = X.str(Option.map f (some(n))).

**Uniqueness.** Let g : ℕ → X.A be any algebra homomorphism. Then:
- g(0) = g(NatTropAlg.str(none)) = X.str(Option.map g none) = X.str(none) = f(0)
- g(n+1) = g(NatTropAlg.str(some(n))) = X.str(Option.map g (some(n))) = X.str(some(g(n)))

By induction, g(n) = f(n) for all n, hence g = f. □

**Theorem 3.8** (Rank-Preserving Initiality). *For any ranked tropical algebra X, the unique algebra homomorphism f : ℕ → X.A additionally satisfies X.rank(f(n)) = n for all n.*

*Proof sketch.* By induction using rank_zero and rank_succ:
- X.rank(f(0)) = X.rank(X.str(none)) = 0 (by rank_zero)
- X.rank(f(n+1)) = X.rank(X.str(some(f(n)))) = X.rank(f(n)) + 1 = n + 1 (by rank_succ and IH)

Uniqueness follows from the conjunction of the homomorphism and rank conditions. □

**Interpretation.** This theorem establishes that tropical inductive types satisfy the same universal property as their classical counterparts, but with the additional structure of rank preservation. In terms of dynamic programming, this says: the Bellman recursion has a unique solution, and that solution faithfully tracks computational depth.

### 3.4 Theorem 4: Well-Founded Universe Hierarchy

**Theorem 3.9** (Well-Foundedness). *The relation TropCodeLT(u, v) := codeRank(u) < codeRank(v) on TropCode = ℕ is well-founded.*

*Proof.* Direct from the well-foundedness of < on ℕ via InvImage.wf. □

**Theorem 3.10** (Idempotent Normalization). *The normalization function normalizeCode(K, u) = min(u, K) is idempotent:*

    normalizeCode(K, normalizeCode(K, u)) = normalizeCode(K, u)

*Proof.* normalizeCode(K, normalizeCode(K, u)) = min(min(u, K), K) = min(u, K) by associativity and idempotence of min. □

**Theorem 3.11** (Rank Non-Increase). *Normalization never increases rank:*

    codeRank(normalizeCode(K, u)) ≤ codeRank(u)

*Proof.* codeRank(normalizeCode(K, u)) = min(u, K) ≤ u = codeRank(u) by Nat.min_le_left. □

**Theorem 3.12** (Normalized Well-Foundedness). *The rank ordering restricted to normalized codes (those u with normalizeCode(K, u) = u, equivalently u ≤ K) is well-founded.*

*Proof.* By strong induction on the natural number value of the code. □

### 3.5 Semantic Calculus

**Theorem 3.13** (Composition). *If f : A →_trop B and g : B →_trop C, then g ∘ f : A →_trop C.*

**Theorem 3.14** (Cost Composition). *If f : A →_{c₁} B and g : B →_{c₂} C, then g ∘ f : A →_{c₁+c₂} C.*

*Proof.* C(g(f(x))) ≤ B(f(x)) + c₂ ≤ (A(x) + c₁) + c₂ = A(x) + (c₁ + c₂). □

**Theorem 3.15** (Identity). *id : A →_trop A for any tropical set A.*

**Theorem 3.16** (Weakening). *If Γ' assigns higher costs than Γ (TropSub Γ' Γ) and Γ ⊢ t : A, then Γ' ⊢ t : A.*

**Theorem 3.17** (Cut/Substitution). *If Γ ⊢ s : A and A ⊢ t : B, then Γ ⊢ t ∘ s : B.*

**Theorem 3.18** (Congruence). *Tropical equality is a congruence under min:*
    TropEq u v → TropEq (λ x, min(u(x), w(x))) (λ x, min(v(x), w(x)))

**Theorem 3.19** (Distributivity). *a + min(b, c) = min(a + b, a + c) for all a, b, c : ℕ.*

**Theorem 3.20** (Meet Structure). *Tropical sets form a meet-semilattice under pointwise min:*
- TropMeet A B ≤ A (via min_le_left)
- TropMeet A B ≤ B (via min_le_right)
- If C ≤ A and C ≤ B, then C ≤ TropMeet A B (greatest lower bound)

---

## 4. Algorithms

### 4.1 Tropical Type Checking Algorithm

```
Algorithm: TropicalTypeCheck(domain, A, B, f, c)
Input: finite domain, cost functions A, B, function f, bound c
Output: (valid, violations, min_slack)

1. violations ← ∅
2. max_slack ← 0
3. for each x ∈ domain:
4.     slack ← B(f(x)) - A(x)
5.     max_slack ← max(max_slack, slack)
6.     if slack > c:
7.         violations ← violations ∪ {x}
8. return (|violations| = 0, violations, max(0, max_slack))
```

**Complexity:** O(|domain|) time, O(|violations|) space.

### 4.2 Initial Algebra Recursion

```
Algorithm: InitialAlgebraHom(zero_val, succ_fn, n)
Input: base value zero_val, successor succ_fn, target n
Output: f(n) in target algebra

1. result ← zero_val
2. for i = 1 to n:
3.     result ← succ_fn(result)
4. return result
```

**Complexity:** O(n) applications of succ_fn.

### 4.3 Universe Normalization

```
Algorithm: NormalizeCode(u, K)
Input: code u, bound K
Output: normalized code

1. return min(u, K)
```

**Complexity:** O(1). Idempotent: NormalizeCode(NormalizeCode(u, K), K) = NormalizeCode(u, K).

---

## 5. Applications

### 5.1 Network Routing Verification

Model a network with nodes α, latency budgets A(x), actual minimum latencies B(x), and routing function f(x) = next hop. The routing policy is valid iff f : A →_trop B. Verification is O(|nodes|).

### 5.2 Program Cost Analysis

Model program states as the base type, resource budgets as A, actual consumption as B, and program transitions as f. Cost-bounded typing f : A →_c B certifies that each step uses at most c additional resources. The composition theorem guarantees n steps use at most n·c resources.

### 5.3 Dynamic Programming via Initiality

The Bellman equation for optimal substructure problems is an instance of initial algebra recursion. The initiality theorem guarantees existence and uniqueness of the solution, while rank preservation tracks the recursion depth.

### 5.4 Supply Chain Optimization

Model a supply chain as a composition of cost-bounded morphisms. Each stage (supplier → manufacturer → distributor → retailer) is a morphism with cost bound c_i. The composition theorem yields the end-to-end cost bound Σ c_i.

---

## 6. Computational Experiments

### 6.1 Type Checking Performance

For domains of size n ∈ {10, 100, 1000, 10000}:
- Type checking time scales linearly in n
- Cost-bounded checking has identical complexity
- Violation detection is immediate upon first failure (short-circuit possible)

### 6.2 Initial Algebra Examples

| Target Algebra | zero_val | succ_fn | f(5) | f(10) |
|---|---|---|---|---|
| Powers of 2 | 1 | ×2 | 32 | 1024 |
| Triangular numbers | 0 | +n | 15 | 55 |
| Strings | "" | +"•" | "•••••" | "••••••••••" |
| Fibonacci | (0,1) | (b,a+b) | (5,8) | (55,89) |

### 6.3 Universe Normalization

For K = 5, the normalization maps codes {0,...,10} to {0,...,5,5,5,5,5,5}. The fixed points form the set {0,1,2,3,4,5}, which is well-ordered. All codes ≥ K collapse to K.

---

## 7. Discussion

### 7.1 Comparison with Classical Semantics

Traditional dependent type theories interpret types in categories of sets, groupoids, or cubical objects. Our tropical interpretation is fundamentally different: types carry *quantitative* information (costs), and morphisms are *resource-bounded*. This makes the semantics inherently computational and optimization-aware.

### 7.2 Relationship to Quantale-Valued Semantics

Our tropical sets can be viewed as presheaves valued in the quantale (ℕ, ≤, min, +). This connects to Lawvere's generalized metric spaces [14] and enriched category theory [15]. The tropical type theory can be seen as a fragment of quantale-valued type theory.

### 7.3 Limitations

The current formalization is semantic rather than syntactic: we define and verify the semantic objects directly rather than giving a formal syntax with judgmental rules. A full syntactic type theory with decidable type checking would require:
- Context formation rules
- Type formation rules with cost annotations
- Term introduction and elimination rules
- A conversion relation respecting tropical equality

### 7.4 The Idempotent Meet and Homotopy

The characterization of identity via the idempotent meet (Theorem 3.4) suggests connections to homotopy type theory. In HoTT, identity types carry higher structure (paths, paths between paths, etc.). In the tropical setting, the idempotent meet provides a "flat" notion of identity — there is no nontrivial higher structure because min(a, a) = a eliminates all discrepancies at once. This suggests a truncated tropical path space.

---

## 8. Future Work

1. **Tropical Π-types as min-plus right Kan extensions**: Define dependent function spaces where the cost of a section is computed as a min-plus integral.

2. **Tropical W-types via least fixed points**: Generalize from Option to arbitrary polynomial endofunctors, establishing initial algebra semantics for tropical trees and other inductive types.

3. **Syntactic type theory**: Define a formal syntax with de Bruijn indices, contexts, and judgmental rules; prove soundness and completeness with respect to the semantic model.

4. **Continuous tropical types**: Extend from ℕ-valued costs to ℝ≥0 or ℝ∪{∞}-valued costs, connecting to tropical geometry and idempotent analysis.

5. **Resource-aware programming language**: Design a programming language with tropical types as resource bounds, with the type checker simultaneously verifying correctness and resource usage.

---

## References

[1] B. Heidergott, G.J. Olsder, J. van der Woude. *Max Plus at Work*. Princeton University Press, 2006.

[2] M. Akian, S. Gaubert, A. Guterman. "Tropical polyhedra are equivalent to mean payoff games." *International Journal of Algebra and Computation*, 22(1), 2012.

[3] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry*. American Mathematical Society, 2015.

[4] S. Gaubert, M. Plus. "Methods and applications of (max,+) linear algebra." *STACS 97*, Lecture Notes in Computer Science 1200, 1997.

[5] G.L. Litvinov. "Maslov dequantization, idempotent and tropical mathematics." *Journal of Mathematical Sciences*, 140(3), 2007.

[6] J.-Y. Girard. "Linear logic." *Theoretical Computer Science*, 50(1):1-101, 1987.

[7] M. Gaboardi, A. Haeberlen, J. Hsu, A. Narayan, B.C. Pierce. "Linear dependent types for differential privacy." *POPL 2013*.

[8] M. Hoffmann, J. Hoffmann. "Amortized resource analysis with polynomial potential." *ESOP 2010*.

[9] P. Dybjer. "Internal type theory." *TYPES 1995*, Lecture Notes in Computer Science 1158, 1996.

[10] R.A.G. Seely. "Locally cartesian closed categories and type theory." *Mathematical Proceedings of the Cambridge Philosophical Society*, 95(1):33-48, 1984.

[11] B. Jacobs. *Categorical Logic and Type Theory*. Elsevier, 1999.

[12] L. de Moura, S. Ullrich. "The Lean 4 theorem prover and programming language." *CADE 2021*.

[13] The mathlib Community. "The Lean mathematical library." *CPP 2020*.

[14] F.W. Lawvere. "Metric spaces, generalized logic, and closed categories." *Rendiconti del Seminario Matematico e Fisico di Milano*, 43:135-166, 1973.

[15] G.M. Kelly. *Basic Concepts of Enriched Category Theory*. Cambridge University Press, 1982.
