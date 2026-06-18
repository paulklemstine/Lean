# Closure–Secret-Sharing Duality via Idempotent Dependency Systems

## Abstract

We establish a formal duality between finite monotone access structures in secret-sharing cryptography and pointed closure geometries. We prove that a set of participants is authorized to reconstruct a secret if and only if the secret lies in the closure (span) of the corresponding participant generators, and that minimal authorized sets are exactly the secret-circuits of the closure geometry. We introduce *pointed dependency systems*—abstract algebraic structures axiomatizing closure with generators and a distinguished secret—and prove a representation theorem: an access structure is closure-exact if and only if it admits a pointed dependency realization. The constructions are shown to be mutually inverse up to authorization equivalence. All results are formalized and machine-verified. We provide algorithms for minimal authorized set enumeration and discuss applications to canonical compression of access policies.

**Keywords:** secret sharing, access structures, closure operators, dependency geometry, circuits, monotone access, representation theorem, canonical compression

---

## 1. Introduction

### 1.1 Background and Motivation

Secret-sharing schemes, introduced independently by Shamir [1] and Blakley [2] in 1979, distribute a secret among a set of participants such that only designated coalitions (*authorized sets*) can reconstruct the secret. The collection of authorized sets—the *access structure*—must be monotone: any superset of an authorized set is authorized.

While the theory of access structures is well-developed from combinatorial and information-theoretic perspectives [3, 4], the geometric and algebraic foundations have received less systematic attention. Brickell and Davenport [5] established connections between ideal secret-sharing schemes and matroids, and subsequent work explored the matroid-theoretic perspective extensively [6, 7]. However, the full scope of the relationship between access structures and closure/dependence theories has remained implicit.

### 1.2 Contributions

This paper makes the following contributions:

1. **Closure-based authorization semantics.** We define authorization via a closure operator on a pointed participant set (§3) and prove that the induced access structure is always monotone (Theorem 1).

2. **Circuit characterization.** We prove that minimal authorized sets are exactly the secret-circuits of the closure geometry (Theorem 2), establishing a precise bijection between the cryptographic and geometric notions.

3. **Pointed dependency systems.** We introduce an abstract algebraic framework (§5) capturing the essential properties of closure-based secret sharing: extensive, monotone, idempotent span with generators and a secret element.

4. **Representation theorem.** We prove a full duality: an access structure is closure-exact if and only if it admits a pointed dependency realization (Theorem 6), with the constructions being mutually inverse on authorization predicates (§9).

5. **Finitary structure.** We prove that every authorized set in a finite closure-exact structure contains a minimal authorized subset (Theorem 7), enabling finite enumeration.

6. **Machine verification.** All definitions and theorems are formalized and verified, ensuring correctness of the mathematical development.

### 1.3 Related Work

The connection between secret sharing and matroids was established by Brickell and Davenport [5] and extended by Seymour [6], Matúš [7], and others. Our framework generalizes this by working with arbitrary closure operators rather than matroid closure specifically. The Moore family perspective on closure systems is classical [8]; we apply it to access structures explicitly. Monotone span programs [9] provide a linear-algebraic realization closely related to our dependency systems; we discuss the connection in §11.

---

## 2. Preliminaries

### 2.1 Notation

Let $X$ be a set of participants. We work with $\mathrm{Option}(X) = X \sqcup \{\bot\}$, where $\bot$ (encoded as `none`) represents the secret, and each participant $x \in X$ is encoded as $\mathrm{some}(x)$.

For $S \subseteq X$, define the *lifted participant set*:
$$\mathrm{lift}(S) = \{\mathrm{some}(x) \mid x \in S\} \subseteq \mathrm{Option}(X)$$

### 2.2 Closure Operators

A *closure operator* on a type $\alpha$ is a function $\mathrm{cl} : \mathcal{P}(\alpha) \to \mathcal{P}(\alpha)$ satisfying:
- **Extensiveness:** $A \subseteq \mathrm{cl}(A)$ for all $A$.
- **Monotonicity:** $A \subseteq B \implies \mathrm{cl}(A) \subseteq \mathrm{cl}(B)$.
- **Idempotence:** $\mathrm{cl}(\mathrm{cl}(A)) = \mathrm{cl}(A)$ for all $A$.

We package these as a structure `IsClosureOperator cl`.

### 2.3 Access Structures

An *access structure* on $X$ is a predicate $A : \mathcal{P}(X) \to \mathrm{Prop}$. It is *monotone* if $A(S) \land S \subseteq T \implies A(T)$. A set $S$ is *minimal authorized* if $A(S)$ and $\neg A(T)$ for all $T \subsetneq S$.

---

## 3. Closure-Based Authorization

### 3.1 Definitions

Given a closure operator $\mathrm{cl}$ on $\mathrm{Option}(X)$, we define:

$$\mathrm{Authorized}(\mathrm{cl}, S) \iff \bot \in \mathrm{cl}(\mathrm{lift}(S))$$
$$\mathrm{Unauthorized}(\mathrm{cl}, S) \iff \bot \notin \mathrm{cl}(\mathrm{lift}(S))$$

The geometric intuition: a coalition $S$ can reconstruct the secret precisely when the secret "depends on" the generators corresponding to $S$.

### 3.2 Monotonicity (Theorem 1)

**Theorem 1** (authorizedFromClosure_mono). *Let $\mathrm{cl}$ be a closure operator on $\mathrm{Option}(X)$. Then $\mathrm{Authorized}(\mathrm{cl}, \cdot)$ is monotone: if $S \subseteq T$ and $S$ is authorized, then $T$ is authorized.*

*Proof.* If $S \subseteq T$, then $\mathrm{lift}(S) \subseteq \mathrm{lift}(T)$ by monotonicity of lifting. By monotonicity of $\mathrm{cl}$, $\mathrm{cl}(\mathrm{lift}(S)) \subseteq \mathrm{cl}(\mathrm{lift}(T))$. If $\bot \in \mathrm{cl}(\mathrm{lift}(S))$, then $\bot \in \mathrm{cl}(\mathrm{lift}(T))$. $\square$

### 3.3 Complement Relation

**Proposition** (unauthorizedFromClosure_compl). *$\mathrm{Unauthorized}(\mathrm{cl}, S) \iff \neg \mathrm{Authorized}(\mathrm{cl}, S)$.*

This is immediate from the definitions.

---

## 4. Secret-Circuits and Minimal Authorization

### 4.1 Definitions

A set $S \subseteq X$ is a *secret-circuit* for closure operator $\mathrm{cl}$ if:
1. $\bot \in \mathrm{cl}(\mathrm{lift}(S))$ (the set is authorized), and
2. For every $x \in S$: $\bot \notin \mathrm{cl}(\mathrm{lift}(S \setminus \{x\}))$ (removing any element destroys authorization).

### 4.2 Circuit Characterization (Theorem 2)

**Theorem 2** (minimalAuthorized_iff_secretCircuit). *Let $\mathrm{cl}$ be a closure operator. A set $S$ is minimal authorized if and only if it is a secret-circuit.*

*Proof.*
($\Rightarrow$) Suppose $S$ is minimal authorized. Then $S$ is authorized. For any $x \in S$, the set $S \setminus \{x\}$ is a proper subset of $S$, hence not authorized. This is exactly the circuit condition.

($\Leftarrow$) Suppose $S$ is a secret-circuit. Then $S$ is authorized. Let $T \subsetneq S$. Then there exists $x \in S \setminus T$. Since $T \subseteq S \setminus \{x\}$, by monotonicity of lifting and closure, $\mathrm{cl}(\mathrm{lift}(T)) \subseteq \mathrm{cl}(\mathrm{lift}(S \setminus \{x\}))$. Since $\bot \notin \mathrm{cl}(\mathrm{lift}(S \setminus \{x\}))$ by the circuit condition, $\bot \notin \mathrm{cl}(\mathrm{lift}(T))$. Hence $T$ is not authorized. $\square$

**Remark.** The backward direction is the non-trivial one: it requires that removing *any single element* kills authorization implies removing *any subset* kills authorization. This follows from monotonicity of closure—a key use of the closure axioms.

---

## 5. Pointed Dependency Systems

### 5.1 Definition

A *pointed dependency system* over $X$ consists of:
- A carrier type $M$,
- A span operation $\mathrm{span} : \mathcal{P}(M) \to \mathcal{P}(M)$ that is a closure operator,
- A generator assignment $g : X \to M$,
- A secret element $s \in M$.

Authorization is defined as: $\mathrm{Auth}_D(S) \iff s \in \mathrm{span}(g(S))$ where $g(S) = \{g(x) \mid x \in S\}$.

### 5.2 Examples

1. **Linear secret sharing (Shamir).** $M = \mathbb{F}^k$ for a finite field $\mathbb{F}$, $\mathrm{span}$ is linear span, $g(x_i) = (1, \alpha_i, \alpha_i^2, \ldots, \alpha_i^{k-1})$ for distinct $\alpha_i$, and $s = e_1$ (the first standard basis vector). Authorization by a set of $k$ or more participants corresponds to the polynomial interpolation threshold.

2. **Matroid-based schemes.** $M$ is the ground set of a matroid, $\mathrm{span}$ is matroid closure, $g$ maps participants to matroid elements, $s$ is a distinguished element. Authorized sets are those whose closure contains $s$.

3. **Trivial closure.** $\mathrm{span}(A) = A$ for all $A$. Then authorization requires $s \in g(S)$, meaning some participant's generator equals the secret. This gives the trivial "one participant knows the secret" scheme.

### 5.3 Monotonicity

**Proposition** (authorizedFromDependency_mono). *Authorization from any pointed dependency system is monotone.*

*Proof.* If $S \subseteq T$, then $g(S) \subseteq g(T)$, so $\mathrm{span}(g(S)) \subseteq \mathrm{span}(g(T))$ by monotonicity of span. $\square$

---

## 6. From Dependency Systems to Closure Operators

### 6.1 Construction

Given a pointed dependency system $D = (M, \mathrm{span}, g, s)$ over $X$, define a closure operator on $\mathrm{Option}(X)$ by:

$$\mathrm{cl}_D(A) = \{y \in \mathrm{Option}(X) \mid \phi(y) \in \mathrm{span}(\phi(A))\}$$

where $\phi : \mathrm{Option}(X) \to M$ maps $\mathrm{some}(x) \mapsto g(x)$ and $\bot \mapsto s$.

### 6.2 Closure Operator Verification (Theorem 3)

**Theorem 3** (closureFromDependency_isClosureOperator). *$\mathrm{cl}_D$ is a closure operator.*

*Proof.*
- *Extensive:* If $y \in A$, then $\phi(y) \in \phi(A) \subseteq \mathrm{span}(\phi(A))$.
- *Monotone:* $A \subseteq B \implies \phi(A) \subseteq \phi(B) \implies \mathrm{span}(\phi(A)) \subseteq \mathrm{span}(\phi(B))$.
- *Idempotent:* $\phi(\mathrm{cl}_D(A)) \subseteq \mathrm{span}(\phi(A))$ by definition, so $\mathrm{span}(\phi(\mathrm{cl}_D(A))) \subseteq \mathrm{span}(\mathrm{span}(\phi(A))) = \mathrm{span}(\phi(A))$ by idempotence of span. Conversely, $A \subseteq \mathrm{cl}_D(A)$ by extensiveness, so $\mathrm{cl}_D(A) \subseteq \mathrm{cl}_D(\mathrm{cl}_D(A))$ by extensiveness. $\square$

### 6.3 Authorization Equivalence (Theorem 4)

**Theorem 4** (dependency_authorization_equiv_closure_authorization). *For any pointed dependency system $D$ and set $S \subseteq X$:*
$$\mathrm{Auth}_D(S) \iff \mathrm{Authorized}(\mathrm{cl}_D, S)$$

*Proof.* Both sides reduce to $s \in \mathrm{span}(g(S))$ after unfolding definitions and observing that $\phi(\mathrm{lift}(S)) = g(S)$. $\square$

---

## 7. From Closure Operators to Dependency Systems

### 7.1 Construction

Given a closure operator $\mathrm{cl}$ on $\mathrm{Option}(X)$, define a pointed dependency system:
- Carrier $M = \mathrm{Option}(X)$,
- $\mathrm{span} = \mathrm{cl}$,
- $g(x) = \mathrm{some}(x)$,
- $s = \bot$.

### 7.2 Authorization Equivalence (Theorem 5)

**Theorem 5** (closure_to_dependency_authorization). *The constructed dependency system recovers the original authorization:*
$$\mathrm{Authorized}(\mathrm{cl}, S) \iff \mathrm{Auth}_{D_\mathrm{cl}}(S)$$

*Proof.* Both sides are $\bot \in \mathrm{cl}(\mathrm{lift}(S))$, noting that $\mathrm{some}(S) = \mathrm{lift}(S)$. $\square$

---

## 8. The Main Duality Theorem

### 8.1 Closure-Exact Access Structures

**Definition.** An access structure $A$ is *closure-exact* if there exists a closure operator $\mathrm{cl}$ on $\mathrm{Option}(X)$ such that $A(S) \iff \bot \in \mathrm{cl}(\mathrm{lift}(S))$ for all $S$.

### 8.2 The Duality (Theorem 6)

**Theorem 6** (closure_dependency_duality). *An access structure $A$ on $X$ is closure-exact if and only if it admits a pointed dependency system representation.*

*Proof.*
($\Rightarrow$) Given $\mathrm{cl}$ with $A(S) \iff \mathrm{Authorized}(\mathrm{cl}, S)$, use the dependency system $D_\mathrm{cl}$ from §7. By Theorem 5, $\mathrm{Auth}_{D_\mathrm{cl}}(S) \iff \mathrm{Authorized}(\mathrm{cl}, S) \iff A(S)$.

($\Leftarrow$) Given $D$ with $A(S) \iff \mathrm{Auth}_D(S)$, use the closure operator $\mathrm{cl}_D$ from §6. By Theorem 3, it is a closure operator, and by Theorem 4, $\mathrm{Authorized}(\mathrm{cl}_D, S) \iff \mathrm{Auth}_D(S) \iff A(S)$.  $\square$

### 8.3 Round-Trip Properties

**Theorem 7** (roundtrip_closure_dependency_closure). *Starting from a closure operator $\mathrm{cl}$, constructing a dependency system, and converting back to a closure operator preserves authorization:*
$$\mathrm{Authorized}(\mathrm{cl}, S) \iff \mathrm{Authorized}(\mathrm{cl}_{D_\mathrm{cl}}, S)$$

**Theorem 8** (roundtrip_dependency_closure_dependency). *Starting from a dependency system $D$, constructing a closure operator, and converting back to a dependency system preserves authorization:*
$$\mathrm{Auth}_D(S) \iff \mathrm{Auth}_{D_{\mathrm{cl}_D}}(S)$$

These round-trip theorems show that the constructions are inverse *on authorization predicates*, establishing the desired duality at the level relevant to cryptography.

---

## 9. Finitary Structure

### 9.1 Existence of Minimal Authorized Subsets (Theorem 9)

**Theorem 9** (exists_minimalAuthorized_subset). *Let $X$ be finite, $\mathrm{cl}$ a closure operator, and $S$ a finite authorized set. Then $S$ contains a minimal authorized subset.*

*Proof.* Consider the set of authorized sub-Finsets of $S$. It is nonempty (contains $S$) and finite. Take an element of minimal cardinality. If any proper subset were authorized, it would have strictly smaller cardinality, contradicting minimality. $\square$

**Corollary.** Combined with Theorem 2, this implies that every finite authorized set contains a secret-circuit.

---

## 10. Algorithms

### 10.1 Minimal Authorized Set Enumeration

**Algorithm 1: Enumerate Minimal Authorized Sets**

```
Input: Finite set X, closure oracle cl
Output: Set of all minimal authorized sets

1. For each subset S ⊆ X (in order of increasing size):
2.   If none ∈ cl(lift(S)):
3.     If no proper subset T ⊂ S has none ∈ cl(lift(T)):
4.       Output S as a minimal authorized set
```

**Complexity:** $O(2^{|X|})$ closure oracle calls in the worst case. For closure operators with bounded circuit size $k$, the complexity reduces to $O(|X|^k)$.

### 10.2 Witness Extraction

Given an authorized set $S$ and a dependency system $D$, a *reconstruction witness* certifies that $s \in \mathrm{span}(g(S))$ by providing the finite subset of generators actually used. This is possible whenever the span has the *finite character property*: membership in the span of a set implies membership in the span of some finite subset.

### 10.3 Canonical Compression

**Algorithm 2: Canonical Compressed Presentation**

```
Input: Set of minimal authorized sets M₁, M₂, ..., Mₖ
Output: Canonical pointed dependency system

1. Define carrier C = Option(X)
2. Define span(A) = {y : if y = none, then ∃ Mᵢ ⊆ {x : some(x) ∈ A}; else y ∈ A}
3. For each Mᵢ, verify cl_span is a closure operator
4. Return (C, span, some, none)
```

This produces the minimal dependency system whose circuits are exactly the given minimal authorized sets.

---

## 11. Discussion

### 11.1 Relationship to Matroids

When the closure operator satisfies the *exchange axiom*—if $y \in \mathrm{cl}(A \cup \{x\}) \setminus \mathrm{cl}(A)$ implies $x \in \mathrm{cl}(A \cup \{y\})$—the resulting structure is a matroid, and our dependency system specializes to a matroid with a distinguished element. The Brickell–Davenport characterization of ideal secret-sharing schemes via matroids is a special case of our duality restricted to matroidal closure.

Our framework is strictly more general: we do not require the exchange property, accommodating access structures arising from non-matroidal dependency geometries.

### 11.2 Relationship to Monotone Span Programs

A monotone span program (MSP) over a field $\mathbb{F}$ for an access structure $A$ on $X$ consists of a matrix $M$ and a target vector $e$ such that $A(S)$ iff $e$ is in the row span of the rows labeled by $S$. This is precisely a pointed dependency system with carrier $\mathbb{F}^k$, span = linear span, generators = rows of $M$ labeled by participants, and secret = $e$.

Our framework thus subsumes MSPs by allowing non-linear span operations.

### 11.3 Canonical Forms and Policy Minimization

The representation theorem implies that every closure-exact access structure has a canonical dependency presentation. This is analogous to the Myhill–Nerode theorem for regular languages: just as every regular language has a unique minimal DFA, every closure-exact access structure has a canonical compressed dependency system determined by its set of minimal authorized sets (circuits).

### 11.4 Limitations

Not every monotone access structure is closure-exact. The closure-exact condition is equivalent to requiring that the unauthorized family forms a Moore family (closed under arbitrary intersection) when lifted to $\mathrm{Option}(X)$. This excludes certain pathological access structures that cannot be represented by any closure operator.

---

## 12. Applications

### 12.1 Threshold Schemes

For $(k, n)$-threshold access on $X = \{1, \ldots, n\}$, the closure operator is polynomial interpolation closure: $\mathrm{cl}(A)$ includes all points determined by degree $\leq k-1$ polynomials passing through the points indexed by $A$. The secret-circuits are all $k$-element subsets—exactly the minimum authorized sets.

### 12.2 Hierarchical Access

Consider a corporate hierarchy with a CEO, VPs, and directors. The access structure "CEO alone, or any 2 VPs, or any 3 directors" is closure-exact: the closure is determined by a weighted matroid where the CEO has rank 3, VPs have rank 2, and directors have rank 1.

### 12.3 Policy Verification

Given a claimed implementation of an access structure, verification reduces to checking circuit agreement: enumerate the minimal authorized sets of the implementation and verify they match the specification. By Theorem 2, this is equivalent to checking that the secret-circuits of the implemented closure match the intended ones.

---

## 13. Future Work

See `FUTURE_DIRECTIONS.md` for detailed research directions including:
1. Monotone span program equivalence from dependency presentations
2. Information-theoretic invariants of closure-exact structures
3. Categorical duality at the level of morphisms
4. Tropical linear secret-sharing semantics
5. Complexity classification of canonical compression

---

## References

[1] A. Shamir, "How to share a secret," *Communications of the ACM*, vol. 22, no. 11, pp. 612–613, 1979.

[2] G. R. Blakley, "Safeguarding cryptographic keys," in *Proceedings of AFIPS National Computer Conference*, 1979, pp. 313–317.

[3] A. Beimel, "Secret-sharing schemes: A survey," in *Coding and Cryptology*, Springer, 2011, pp. 11–46.

[4] J. Martí-Farré and C. Padró, "On secret sharing schemes, matroids and polymatroids," *Journal of Mathematical Cryptology*, vol. 4, no. 2, pp. 95–120, 2010.

[5] E. F. Brickell and D. M. Davenport, "On the classification of ideal secret sharing schemes," *Journal of Cryptology*, vol. 4, pp. 123–134, 1991.

[6] P. D. Seymour, "On secret-sharing matroids," *Journal of Combinatorial Theory, Series B*, vol. 56, no. 1, pp. 69–73, 1992.

[7] F. Matúš, "Matroid representations by partitions," *Discrete Mathematics*, vol. 203, pp. 169–194, 1999.

[8] G. Birkhoff, *Lattice Theory*, 3rd ed., American Mathematical Society, 1967.

[9] M. Karchmer and A. Wigderson, "On span programs," in *Proceedings of the 8th Annual Structure in Complexity Theory Conference*, IEEE, 1993, pp. 102–111.
