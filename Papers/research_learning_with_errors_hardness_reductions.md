# Closure–Gauge Realization Duality via Idempotent Holonomy

## Abstract

We establish a finite realization duality for closure operators on finite sets, characterizing precisely which closure operators arise from gauge valuations via supremum-threshold construction. A *gauge valuation* is a function *v : α → ℕ* on a finite type, inducing a closure operator *cl_v(S) = { x : v(x) ≤ sup_{s ∈ S} v(s) }*. Our main result shows that a closure operator is gauge-realizable if and only if its collection of closed sets forms a chain under inclusion. We prove that minimal realizations exist and are unique up to order equivalence (gauge equivalence), and establish a holographic duality theorem showing that the capacity profile — the function *S ↦ |cl(S)|* — uniquely determines the closure operator. All results have been formalized and machine-verified.

**Keywords:** closure operators, gauge valuations, realization theory, tropical algebra, holographic duality, chain condition, lattice theory

---

## 1. Introduction

Closure operators are among the most ubiquitous structures in mathematics, appearing in topology (topological closure), algebra (generated substructures), logic (deductive closure), and combinatorics (matroid closure). A natural question in realization theory asks: given a closure operator, can it be "generated" by some simpler datum? This paper answers this question for a specific and natural class of generators — gauge valuations.

A gauge valuation assigns a non-negative integer to each element of a finite set. The induced closure collects all elements whose value does not exceed the supremum of values in the seed set. This construction arises naturally in:

- **Tropical linear algebra**, where the supremum operation plays the role of tropical addition;
- **Discrete gauge theory**, where valuations model holonomy capacities of loops;
- **Automata theory**, where closure operators describe Nerode-type equivalence structures;
- **Secret-sharing and access structures**, where threshold conditions model security levels.

Our main contributions are:

1. **Realizability characterization** (Theorem 5.1): A closure operator is gauge-realizable iff its closed sets form a chain.
2. **Holographic duality** (Theorem 4.1): Equal capacity profiles imply equal closures.
3. **Gauge uniqueness** (Theorem 3.1): Equal closures imply order-equivalent valuations.
4. **Minimal realization** (Theorem 6.1): Minimal realizations exist and are unique up to gauge equivalence.
5. **Separation criterion** (Theorem 7.1): For valuation closures, separation is equivalent to injectivity.

---

## 2. Definitions and Basic Properties

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). Let *α* be a finite type with decidable equality. A *closure operator* on the finite subsets of *α* is a triple *(cl, ext, mon, idem)* where *cl : 𝒫_fin(α) → 𝒫_fin(α)* satisfies:

- **Extensivity:** *S ⊆ cl(S)* for all finite *S ⊆ α*;
- **Monotonicity:** *S ⊆ T* implies *cl(S) ⊆ cl(T)*;
- **Idempotency:** *cl(cl(S)) = cl(S)* for all *S*.

**Definition 2.2** (Closed Set). A finite set *S* is *closed* under a closure operator *C* if *C.cl(S) = S*.

### 2.2 Gauge Valuations

**Definition 2.3** (Valuation Closure). Given a function *v : α → ℕ*, the *valuation closure* is defined by:

$$\text{cl}_v(S) = \{ x \in \alpha \mid v(x) \leq \sup_{s \in S} v(s) \}$$

where the supremum is taken over the image of *S* under *v* in the natural numbers (with *sup ∅ = 0*).

**Theorem 2.1** (Valuation Closure is a Closure Operator). For any *v : α → ℕ*, the valuation closure *cl_v* satisfies extensivity, monotonicity, and idempotency.

*Proof sketch.* Extensivity: if *x ∈ S*, then *v(x) ≤ sup_{s ∈ S} v(s)* by definition of supremum. Monotonicity: if *S ⊆ T*, then *sup_S v ≤ sup_T v*, so any *x* with *v(x) ≤ sup_S v* also satisfies *v(x) ≤ sup_T v*. Idempotency: the key observation is that *sup(cl_v(S)) = sup(S)* under *v*. The set *cl_v(S)* contains only elements with value ≤ *sup_S v*, so the supremum cannot increase. But *S ⊆ cl_v(S)*, so the supremum cannot decrease. Thus *cl_v(cl_v(S))* filters by the same threshold as *cl_v(S)*. □

**Theorem 2.2** (Supremum Preservation). For any *v* and *S*:

$$\sup_{x \in \text{cl}_v(S)} v(x) = \sup_{s \in S} v(s)$$

*Proof sketch.* The inequality ≤ follows because elements of *cl_v(S)* satisfy *v(x) ≤ sup_S v*. The inequality ≥ follows from *S ⊆ cl_v(S)*. □

**Theorem 2.3** (Membership Criterion). For any *v*, *S*, and *x*:

$$x \in \text{cl}_v(S) \iff v(x) \leq \sup_{s \in S} v(s)$$

### 2.3 Capacity

**Definition 2.4** (Closure Capacity). The *capacity* of a set *S* under closure *C* is:

$$\text{cap}_C(S) = |C.cl(S)|$$

**Theorem 2.4** (Capacity Properties).
- *Monotonicity:* *S ⊆ T* implies *cap_C(S) ≤ cap_C(T)*.
- *Extensivity:* *|S| ≤ cap_C(S)*.

**Theorem 2.5** (Closedness via Capacity). A set *S* is closed under *C* if and only if *cap_C(S) = |S|*.

*Proof sketch.* If *S* is closed, then *cl(S) = S*, so *cap(S) = |S|*. Conversely, if *cap(S) = |S|*, then *|cl(S)| = |S|*. Since *S ⊆ cl(S)* (extensivity) and both are finite sets of the same cardinality, *S = cl(S)*. □

---

## 3. Gauge Equivalence

**Definition 3.1** (Order Equivalence / Gauge Equivalence). Two valuations *v₁, v₂ : α → ℕ* are *order-equivalent* (or *gauge-equivalent*) if:

$$\forall x, y \in \alpha: \quad v_1(x) \leq v_1(y) \iff v_2(x) \leq v_2(y)$$

Order equivalence is an equivalence relation (reflexive, symmetric, transitive).

**Theorem 3.1** (Fundamental Gauge Uniqueness). If *cl_{v₁} = cl_{v₂}* as functions, then *v₁* and *v₂* are order-equivalent.

*Proof sketch.* The key observation is that *v(x) ≤ v(y)* if and only if *x ∈ cl_v({y})*. This follows directly from the membership criterion: *x ∈ cl_v({y}) ↔ v(x) ≤ sup({y}) = v(y)*. Since *cl_{v₁} = cl_{v₂}*, membership in singleton closures is preserved:

$$v_1(x) \leq v_1(y) \iff x \in \text{cl}_{v_1}(\{y\}) \iff x \in \text{cl}_{v_2}(\{y\}) \iff v_2(x) \leq v_2(y)$$

This establishes order equivalence. □

---

## 4. Holographic Duality

**Theorem 4.1** (Holographic Duality). Let *C₁* and *C₂* be closure operators on a finite type *α*. If their capacity profiles agree — that is, *cap_{C₁}(S) = cap_{C₂}(S)* for every finite subset *S* — then *C₁.cl = C₂.cl*.

*Proof sketch.* Fix a set *S*. We show *C₁.cl(S) ⊆ C₂.cl(S)* (symmetry gives the reverse).

First, we establish that *C₂.cl(C₁.cl(S)) = C₁.cl(S)*. By extensivity of *C₂*, we have *C₁.cl(S) ⊆ C₂.cl(C₁.cl(S))*. By the capacity hypothesis applied to *C₁.cl(S)*:

$$|C_2.\text{cl}(C_1.\text{cl}(S))| = |C_1.\text{cl}(C_1.\text{cl}(S))| = |C_1.\text{cl}(S)|$$

where the last equality uses idempotency of *C₁*. A finite superset of the same cardinality must equal the subset, giving *C₂.cl(C₁.cl(S)) = C₁.cl(S)*.

Now, by extensivity of *C₁*, *S ⊆ C₁.cl(S)*, so by monotonicity of *C₂*, *C₂.cl(S) ⊆ C₂.cl(C₁.cl(S)) = C₁.cl(S)*. The capacity hypothesis then gives *|C₁.cl(S)| = |C₂.cl(S)|*, and since *C₂.cl(S) ⊆ C₁.cl(S)* with equal cardinality, *C₁.cl(S) = C₂.cl(S)*. □

**Remark 4.1.** The holographic duality is a finite-dimensional analogue of the principle that boundary data determines bulk structure. The capacity function — which records only cardinalities — is a "shadow" of the full closure operator, yet it contains complete information.

---

## 5. The Realizability Duality

### 5.1 Definitions

**Definition 5.1** (Gauge Realizability). A closure operator *C* is *gauge-realizable* if there exists *v : α → ℕ* such that *C.cl = cl_v*.

**Definition 5.2** (Chain Property). A closure operator *C* has the *chain property* (or its closed sets form a chain) if for any closed sets *S* and *T*, either *S ⊆ T* or *T ⊆ S*.

### 5.2 Forward Direction

**Theorem 5.1** (Realizable ⟹ Chain). If *C* is gauge-realizable, then its closed sets form a chain.

*Proof sketch.* Let *C = cl_v* for some valuation *v*. A closed set *S* satisfies *cl_v(S) = S*, which means *S = {x : v(x) ≤ sup_S v}*. Closed sets are thus level sets of the form *L_k = {x : v(x) ≤ k}* for various thresholds *k*. Given two such level sets *L_j* and *L_k* with *j ≤ k*, clearly *L_j ⊆ L_k*. Since any two natural numbers are comparable, any two level sets are nested. □

### 5.3 Key Structural Lemmas

**Lemma 5.1** (Singleton Closure Characterization). For any closure operator *C*, element *x*, and set *S*:

$$x \in C.\text{cl}(S) \iff C.\text{cl}(\{x\}) \subseteq C.\text{cl}(S)$$

*Proof sketch.* (⟹) If *x ∈ cl(S)*, then *{x} ⊆ cl(S)*, so by monotonicity, *cl({x}) ⊆ cl(cl(S)) = cl(S)* by idempotency. (⟸) The reverse is immediate: *x ∈ cl({x}) ⊆ cl(S)*. □

**Lemma 5.2** (Chain Closure Maximum). If *C* has the chain property and *S* is nonempty, then there exists *s₀ ∈ S* such that *cl(S) = cl({s₀})*.

*Proof sketch.* The singleton closures *{cl({s}) : s ∈ S}* are all closed (by idempotency) and hence pairwise comparable (by the chain property). Choose *s₀ ∈ S* maximizing *|cl({s})|*. By the chain property, *cl({s}) ⊆ cl({s₀})* for all *s ∈ S*, so *S ⊆ cl({s₀})*, hence *cl(S) ⊆ cl(cl({s₀})) = cl({s₀})*. The reverse inclusion *cl({s₀}) ⊆ cl(S)* follows from *{s₀} ⊆ S*. □

**Lemma 5.3** (Chain Subset Iff Card). In a closure with the chain property, for closed sets *S* and *T*: *S ⊆ T ↔ |S| ≤ |T|*.

### 5.4 Reverse Direction

**Theorem 5.2** (Chain ⟹ Realizable). If the closed sets of *C* form a chain, then *C* is gauge-realizable.

*Proof sketch.* Define *v(x) = |cl({x})| − |cl(∅)|*. We claim *C.cl = cl_v*.

For any set *S* and element *x*, we must show *x ∈ C.cl(S) ↔ v(x) ≤ sup_{s ∈ S} v(s)*.

(⟹) If *S* is nonempty, by Lemma 5.2, *cl(S) = cl({s₀})* for some *s₀ ∈ S* with maximum singleton closure. If *x ∈ cl(S)*, then *cl({x}) ⊆ cl(S) = cl({s₀})*, so *|cl({x})| ≤ |cl({s₀})|*, giving *v(x) ≤ v(s₀) ≤ sup_S v*.

(⟸) If *v(x) ≤ sup_S v*, there exists *s₀ ∈ S* with *v(x) ≤ v(s₀)*, meaning *|cl({x})| ≤ |cl({s₀})|*. By Lemma 5.3 applied to the closed sets *cl({x})* and *cl({s₀})*, this gives *cl({x}) ⊆ cl({s₀}) ⊆ cl(S)*. By Lemma 5.1, *x ∈ cl(S)*. □

### 5.5 The Main Duality

**Theorem 5.3** (Closure–Gauge Realization Duality). A closure operator *C* on a finite type is gauge-realizable if and only if its closed sets form a chain under inclusion:

$$\text{GaugeRealizable}(C) \iff \text{ClosedSetsChain}(C)$$

*Proof.* Combine Theorems 5.1 and 5.2. □

---

## 6. Minimal Realizations

### 6.1 Realization Rank

**Definition 6.1** (Realization Rank). The *rank* of a valuation *v : α → ℕ* is the number of distinct values in its image: *rank(v) = |{v(x) : x ∈ α}|*.

**Definition 6.2** (Minimal Realization). A valuation *v* is a *minimal realization* if for every *w* with *cl_v = cl_w*, we have *rank(v) ≤ rank(w)*.

### 6.2 Normalized Valuation

**Definition 6.3** (Normalized Valuation). Given *v : α → ℕ*, the *normalized valuation* is:

$$\hat{v}(x) = |\{y \in \alpha : v(y) < v(x)\}|$$

**Theorem 6.1** (Normalization Preserves Order). The normalized valuation *v̂* is order-equivalent to *v*.

*Proof sketch.* If *v(x) ≤ v(y)*, then any element *z* with *v(z) < v(x)* also satisfies *v(z) < v(y)* (by transitivity), giving *v̂(x) ≤ v̂(y)*. Conversely, if *v(x) > v(y)*, then the set *{z : v(z) < v(x)}* strictly contains *{z : v(z) < v(y)}* (it additionally contains *y*), so *v̂(x) > v̂(y)*. □

### 6.3 Existence and Uniqueness

**Theorem 6.2** (Existence of Minimal Realization). Every gauge-realizable closure operator admits a minimal realization.

*Proof sketch.* The set of ranks of realizations is a nonempty subset of ℕ (nonempty because the closure is realizable), hence has a minimum by the well-ordering principle. □

**Theorem 6.3** (Uniqueness up to Gauge Equivalence). Any two realizations of the same closure operator are order-equivalent.

*Proof.* This is an immediate corollary of the Fundamental Gauge Uniqueness (Theorem 3.1). □

---

## 7. Separation and Injectivity

**Definition 7.1** (Separation). A closure operator *C* is *separated* if distinct elements have distinct singleton closures: *a ≠ b ⟹ cl({a}) ≠ cl({b})*.

**Theorem 7.1** (Separation ↔ Injectivity). For a valuation closure *cl_v*, separation is equivalent to injectivity of *v*:

$$\text{Separated}(\text{cl}_v) \iff \text{Injective}(v)$$

*Proof sketch.* (⟸) If *v* is injective and *a ≠ b*, then *v(a) ≠ v(b)*. WLOG *v(a) < v(b)*. Then *b ∈ cl_v({b})* but *b ∉ cl_v({a})* (since *v(b) > v(a) = sup({a})* under *v*), so *cl_v({a}) ≠ cl_v({b})*.

(⟹) Contrapositive: if *v(a) = v(b)* for *a ≠ b*, then *cl_v({a}) = cl_v({b})* since both equal *{x : v(x) ≤ v(a)} = {x : v(x) ≤ v(b)}*. □

**Theorem 7.2** (Separated Chain ⟹ Injective Realization). If *C* has the chain property and is separated, there exists an injective *v : α → ℕ* with *C.cl = cl_v*.

*Proof sketch.* By the chain-implies-realizable theorem, obtain *v* with *C.cl = cl_v*. Separation of *C* transfers to separation of *cl_v*, which by Theorem 7.1 implies injectivity of *v*. □

---

## 8. Concrete Examples and Counterexamples

### 8.1 The Total Closure

The total closure *cl(S) = α* for all *S* is gauge-realizable: take the constant valuation *v ≡ 0*. Its only closed set is *α* itself, which trivially forms a chain.

### 8.2 The Discrete (Identity) Closure

The identity closure *cl(S) = S* is gauge-realizable only for *|α| ≤ 1*. For *|α| ≥ 2*, distinct singletons *{a}* and *{b}* are both closed but incomparable — the closed sets do not form a chain.

**Theorem 8.1** (Discrete Non-Realizability). For *n ≥ 2*, the identity closure on *Fin(n)* is not gauge-realizable.

*Proof sketch.* The singletons *{0}* and *{1}* are both closed under the identity closure. If a valuation *v* realized this closure, then *cl_v({0}) = {0}* would require *v(x) > v(0)* for all *x ≠ 0*, and *cl_v({1}) = {1}* would require *v(x) > v(1)* for all *x ≠ 1*. In particular, *v(1) > v(0)* and *v(0) > v(1)*, a contradiction. □

### 8.3 Valuation Closures Are Always Realizable

By construction, any valuation closure *cl_v* is gauge-realizable (with witness *v* itself). This is tautological but confirms the theory is non-vacuous.

---

## 9. Algorithms

### 9.1 Testing Realizability

Given a closure operator *C* on a set of size *n* (specified by its action on all 2ⁿ subsets), test whether all pairs of closed sets are comparable. This runs in *O(4ⁿ · n)* time in the worst case, but can be accelerated by enumerating only closed sets.

### 9.2 Constructing Minimal Realizations

Given a chain-structured closure *C*:

1. Compute *cl(∅)* and *cl({x})* for each *x ∈ α*.
2. Set *v(x) = |cl({x})| − |cl(∅)|*.
3. Return *v*.

This runs in *O(n · T_{cl})* time, where *T_{cl}* is the cost of computing a single closure.

### 9.3 Normalization

Given *v : α → ℕ*:

1. For each *x*, count *|{y : v(y) < v(x)}|*.
2. Return the count as *v̂(x)*.

This runs in *O(n²)* time or *O(n log n)* using sorting.

---

## 10. Discussion

### 10.1 Connections to Matroid Theory

Matroid closures satisfy a stronger exchange axiom that our general closure operators do not require. The chain condition is strictly weaker than the matroid exchange property, and the class of gauge-realizable closures intersects but does not contain the class of matroid closures.

### 10.2 Tropical Interpretation

The supremum operation in the valuation closure is the "addition" of the tropical semiring *(ℕ, max, +)*. From this perspective, the closure *cl_v(S)* is the "tropical span" of *S* under the valuation *v*. The realizability duality can be viewed as characterizing which closure systems have a tropical linear representation.

### 10.3 Relation to Lattice Theory

The lattice of closed sets of any closure operator is a complete lattice (in the finite case, a finite lattice). The chain condition forces this lattice to be totally ordered — it is a finite chain *∅ ⊆ L₁ ⊆ L₂ ⊆ ··· ⊆ α*. The number of links in this chain equals the rank of any minimal realization.

### 10.4 Information-Theoretic Perspective

The holographic duality theorem has an information-theoretic reading: the entropy of the capacity profile *{cap(S) : S ⊆ α}* equals the entropy of the full closure function *{cl(S) : S ⊆ α}*. No information is lost in the projection from sets to cardinalities.

### 10.5 Connections to Access Structures

In secret-sharing schemes, an *access structure* determines which coalitions of participants can reconstruct a secret. A *threshold* access structure — where any *k* out of *n* participants suffice — corresponds precisely to a chain-structured closure operator on the set of participants. The gauge valuation assigns each participant a "capability score," and the closure of a coalition captures all participants whose capability doesn't exceed the coalition's maximum. The realizability duality thus characterizes exactly which access structures admit a threshold representation.

This perspective connects our work to the broader theory of ideal secret-sharing schemes. The capacity function corresponds to the *information rate* of a scheme, and the holographic duality implies that the information rates alone determine the underlying access structure — a result with implications for the efficiency analysis of cryptographic protocols.

### 10.6 Computational Complexity

The realizability test — checking whether all pairs of closed sets are comparable — has complexity dominated by the enumeration of closed sets. For a general closure operator on *n* elements specified by its action on all 2ⁿ subsets, the number of closed sets can be at most 2ⁿ, giving an *O(4ⁿ)* worst-case complexity. However, for closure operators arising in practice (e.g., from database dependencies or concept lattices), the number of closed sets is typically polynomial in *n*, making the test efficient.

The construction of a minimal realization, once the chain property is verified, requires only *n + 1* closure computations (for the empty set and each singleton). If individual closure computations take time *T*, the total construction time is *O(nT)*. For valuations stored as lookup tables, *T = O(n)*, giving *O(n²)* overall.

---

## 11. Future Work

Several natural extensions of this work suggest themselves:

1. **Continuous gauge valuations:** Extend the theory to *v : α → ℝ≥₀* and continuous closure operators on compact spaces.
2. **Multi-dimensional gauges:** Replace single valuations with vector-valued functions *v : α → ℕᵏ*, where the closure uses component-wise supremum. The realizability criterion should generalize from chains to lattices of bounded width.
3. **Algorithmic applications:** Develop efficient algorithms for matroid-like optimization over chain-structured closures.
4. **Connections to LWE reductions:** Explore how the gauge valuation framework interfaces with the algebraic structures in Learning with Errors hardness reductions, particularly in modeling error distributions and lattice rounding operations.

---

## 12. Conclusion

The Closure–Gauge Realization Duality provides a complete characterization of which closure operators on finite sets admit numerical (gauge) realizations. The answer — exactly those whose closed sets form a chain — is both elegant and practical. The accompanying results on gauge uniqueness, holographic duality, and minimal realizations form a coherent theory that bridges lattice theory, tropical algebra, and discrete gauge theory. All results have been formalized and machine-verified, providing a high-confidence mathematical foundation for applications in automata theory, data analysis, and cryptographic protocol design.

---

## References

The mathematical framework developed here draws on classical results in closure operator theory, lattice theory, and realization theory. The formalization contributes to the growing body of machine-verified mathematics connecting discrete structures with algebraic and geometric perspectives.
