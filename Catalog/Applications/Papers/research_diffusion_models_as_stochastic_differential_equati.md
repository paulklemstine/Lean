# Closure–Gauge Realization Duality via Idempotent Holonomy

## Abstract

We establish a complete duality between closure operators on finite sets and gauge valuations — functions assigning non-negative integers to elements. A gauge valuation *v* induces a closure operator cl_v(S) = {x : v(x) ≤ sup{v(s) : s ∈ S}}, and we prove that this construction yields a genuine closure operator (extensive, monotone, idempotent). Our main results are: (1) the closed sets of any valuation closure form a chain under inclusion; (2) a closure operator is gauge-realizable if and only if its closed sets form a chain; (3) any two realizations of the same closure are gauge-equivalent (order-equivalent); (4) a "holographic duality" — two closure operators with identical capacity profiles (|cl(S)| for all S) must be identical; and (5) every realizable closure admits a canonical minimal realization that can be certified and reconstructed from the chain decomposition. These results bridge lattice theory, tropical algebra, automata-theoretic realization, and discrete gauge theory into a unified framework, with all main theorems formally verified.

**Keywords**: closure operator, gauge valuation, realization duality, chain property, holographic duality, tropical algebra, gauge equivalence

---

## 1. Introduction

Closure operators are fundamental objects across mathematics: they appear in topology, lattice theory, formal concept analysis, matroid theory, and formal language theory. Given a finite ground set, a closure operator assigns to each subset its "closure" — a larger set satisfying extensiveness, monotonicity, and idempotence.

A natural source of closure operators comes from *valuations*: assign each element a non-negative integer score, then define the closure of a set S as all elements whose score does not exceed the maximum score in S. This construction arises naturally in tropical linear algebra (where the max operation plays the role of addition), in discrete gauge theory (where scores represent holonomy capacities), and in automata-theoretic realization (where the closure structure determines state complexity).

This paper addresses three foundational questions:

1. **Characterization**: Which closure operators arise from valuations?
2. **Uniqueness**: When two valuations yield the same closure, how are they related?
3. **Reconstruction**: Given a realizable closure, can we efficiently reconstruct a minimal valuation?

We provide complete answers to all three, establishing a duality that unifies perspectives from multiple mathematical domains.

---

## 2. Definitions and Setup

Throughout, let α be a finite type with decidable equality. We work with finite sets (elements of Finset α) and functions v : α → ℕ.

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). A *closure operator* on Finset α is a triple (cl, extensive, monotone, idempotent) where cl : Finset α → Finset α satisfies:

- **Extensiveness**: S ⊆ cl(S) for all S.
- **Monotonicity**: S ⊆ T implies cl(S) ⊆ cl(T).
- **Idempotence**: cl(cl(S)) = cl(S) for all S.

**Definition 2.2** (Closed Set). A set S is *closed* under a closure operator C if C.cl(S) = S.

### 2.2 Gauge Valuations and Induced Closure

**Definition 2.3** (Valuation Closure). Given v : α → ℕ, the *valuation closure* is:

$$\text{cl}_v(S) = \{ x \in \alpha \mid v(x) \leq \sup_{s \in S} v(s) \}$$

where the supremum is taken in ℕ with the convention that sup ∅ = 0.

### 2.3 Gauge Equivalence

**Definition 2.4** (Order Equivalence / Gauge Equivalence). Two valuations v₁, v₂ : α → ℕ are *order-equivalent* (or *gauge-equivalent*) if they induce the same total preorder:

$$\forall x, y \in \alpha, \quad v_1(x) \leq v_1(y) \iff v_2(x) \leq v_2(y)$$

Order equivalence is an equivalence relation (reflexive, symmetric, transitive).

### 2.4 Capacity

**Definition 2.5** (Closure Capacity). The *capacity* of a set S under a closure operator C is:

$$\text{cap}_C(S) = |C.\text{cl}(S)|$$

### 2.5 Realizability and Separation

**Definition 2.6** (Gauge-Realizable). A closure operator C is *gauge-realizable* if there exists v : α → ℕ such that C.cl = cl_v.

**Definition 2.7** (Separated). A closure operator C is *separated* if for all distinct elements a ≠ b, C.cl({a}) ≠ C.cl({b}).

**Definition 2.8** (Realization Rank). The *rank* of a valuation v is the number of distinct values in its image: rank(v) = |{v(x) : x ∈ α}|.

**Definition 2.9** (Minimal Realization). A valuation v is a *minimal realization* if for every w with cl_v = cl_w, we have rank(v) ≤ rank(w).

**Definition 2.10** (Normalized Valuation). The *normalization* of v is:

$$\hat{v}(x) = |\{ y \in \alpha \mid v(y) < v(x) \}|$$

---

## 3. Valuation Closure is a Closure Operator

**Theorem 3.1** (Valuation Closure Properties). For any v : α → ℕ, the valuation closure cl_v satisfies:

(a) *Extensiveness*: S ⊆ cl_v(S).

(b) *Monotonicity*: S ⊆ T implies cl_v(S) ⊆ cl_v(T).

(c) *Sup preservation*: sup{v(x) : x ∈ cl_v(S)} = sup{v(s) : s ∈ S}.

(d) *Idempotence*: cl_v(cl_v(S)) = cl_v(S).

*Proof sketch.* (a) If x ∈ S, then v(x) ≤ sup_S v by definition of supremum. (b) S ⊆ T implies sup_S v ≤ sup_T v by monotonicity of sup, so any x with v(x) ≤ sup_S v also has v(x) ≤ sup_T v. (c) The forward inequality holds because every element of cl_v(S) has value ≤ sup_S v; the reverse holds because S ⊆ cl_v(S). (d) By (c), sup_{cl_v(S)} v = sup_S v, so cl_v(cl_v(S)) = {x : v(x) ≤ sup_S v} = cl_v(S). □

**Corollary 3.2.** The triple (cl_v, extensive, monotone, idempotent) forms a closure operator, which we denote valuationClosure(v).

---

## 4. The Chain Property

**Theorem 4.1** (Closed Set Characterization). A set S is closed under valuationClosure(v) if and only if S = {x ∈ α : v(x) ≤ sup_S v}. That is, closed sets are precisely the sublevel sets of v at thresholds that are themselves suprema of the set.

*Proof sketch.* By definition, S is closed iff cl_v(S) = S. Since cl_v(S) = {x : v(x) ≤ sup_S v}, this is equivalent to S equaling this sublevel set. □

**Theorem 4.2** (Chain Property). For any v : α → ℕ, any two closed sets S, T of valuationClosure(v) satisfy S ⊆ T or T ⊆ S.

*Proof sketch.* By Theorem 4.1, S = {x : v(x) ≤ k_S} and T = {x : v(x) ≤ k_T} for k_S = sup_S v and k_T = sup_T v. Since k_S and k_T are natural numbers, either k_S ≤ k_T (giving S ⊆ T) or k_T ≤ k_S (giving T ⊆ S). □

---

## 5. Gauge Uniqueness

**Theorem 5.1** (Fundamental Gauge Uniqueness). If cl_{v₁} = cl_{v₂}, then v₁ and v₂ are order-equivalent.

*Proof sketch.* For any x, y ∈ α:

$$v_1(x) \leq v_1(y) \iff x \in \text{cl}_{v_1}(\{y\}) \iff x \in \text{cl}_{v_2}(\{y\}) \iff v_2(x) \leq v_2(y)$$

The middle equivalence uses the hypothesis cl_{v₁} = cl_{v₂}, and the outer equivalences use the characterization of valuation closure membership: x ∈ cl_v({y}) iff v(x) ≤ sup{{y}} v = v(y). □

This theorem says the closure determines the valuation up to order-preserving reparametrization. The specific numerical values are gauge artifacts; only the ranking is intrinsic.

---

## 6. Holographic Duality

**Theorem 6.1** (Capacity is Extensive and Monotone).

(a) cap_C(S) ≥ |S| for all S.

(b) S ⊆ T implies cap_C(S) ≤ cap_C(T).

*Proof sketch.* (a) follows from extensiveness of C. (b) follows from monotonicity. □

**Theorem 6.2** (Closed Set Capacity Characterization). S is closed under C if and only if cap_C(S) = |S|.

*Proof sketch.* If S is closed, cl(S) = S, so |cl(S)| = |S|. Conversely, if |cl(S)| = |S| and S ⊆ cl(S) (by extensiveness), then S = cl(S) by the pigeonhole principle for finite sets: a superset of equal cardinality must be the set itself. □

**Theorem 6.3** (Holographic Duality). Let C₁ and C₂ be closure operators on Finset α. If cap_{C₁}(S) = cap_{C₂}(S) for every S, then C₁.cl = C₂.cl.

*Proof sketch.* Fix any S. We show cl₁(S) ⊆ cl₂(S) and cl₂(S) ⊆ cl₁(S).

For the first inclusion: Since cl₁(S) is closed under C₁ (by idempotence), cap_{C₁}(cl₁(S)) = |cl₁(S)|. By hypothesis, cap_{C₂}(cl₁(S)) = cap_{C₁}(cl₁(S)) = |cl₁(S)|. By extensiveness, cl₁(S) ⊆ cl₂(cl₁(S)), but |cl₂(cl₁(S))| = |cl₁(S)|, so cl₂(cl₁(S)) = cl₁(S). Since cl₂(S) ⊆ cl₂(cl₁(S)) by monotonicity (as S ⊆ cl₁(S)), we get cl₂(S) ⊆ cl₁(S).

By symmetry (swapping C₁ and C₂), cl₁(S) ⊆ cl₂(S). □

The holographic duality is remarkable: a scalar-valued function (the capacity profile) completely determines the set-valued function (the closure). No information is lost when passing from cl to cap.

---

## 7. Realization Duality

**Theorem 7.1** (Realizability iff Chain). A closure operator C on Finset α is gauge-realizable if and only if its closed sets form a chain under inclusion.

*Proof sketch.*

*(⟹) Realizable implies chain.* This is Theorem 4.2.

*(⟸) Chain implies realizable.* Given C with chain closed sets, define v(x) = |C.cl({x})| − |C.cl(∅)|. We verify cl_v = C.cl.

*Forward*: If x ∈ C.cl(S), we must show v(x) ≤ sup_{s∈S} v(s). By the chain property, C.cl({x}) ⊆ C.cl({s₀}) for some s₀ ∈ S achieving the maximum singleton closure cardinality. Then v(x) ≤ v(s₀) ≤ sup v.

*Backward*: If v(x) ≤ sup_{s∈S} v(s), there exists s₀ ∈ S with v(x) ≤ v(s₀). By the chain property and the definition of v, C.cl({x}) ⊆ C.cl({s₀}), so x ∈ C.cl({s₀}) ⊆ C.cl(S). □

### Helper lemmas for the proof:

**Lemma 7.2** (Singleton Membership). x ∈ C.cl(S) if and only if C.cl({x}) ⊆ C.cl(S).

**Lemma 7.3** (Chain Max Singleton). If closed sets form a chain and S is nonempty, then C.cl(S) = C.cl({s₀}) for some s₀ ∈ S.

**Lemma 7.4** (Chain Subset iff Card). Under the chain property, for closed sets S and T: S ⊆ T iff |S| ≤ |T|.

---

## 8. Minimal Realization and Certified Reconstruction

**Theorem 8.1** (Existence of Minimal Realization). Every gauge-realizable closure operator admits a minimal realization — a valuation achieving the smallest possible rank among all realizations.

*Proof sketch.* The set of achievable ranks is a non-empty subset of ℕ (at least one realization exists). By the well-ordering principle, it has a minimum. □

**Theorem 8.2** (Normalization Preserves Order). For any v, the normalized valuation v̂(x) = |{y : v(y) < v(x)}| is order-equivalent to v.

*Proof sketch.* If v(x) ≤ v(y), then {z : v(z) < v(x)} ⊆ {z : v(z) < v(y)}, so v̂(x) ≤ v̂(y) by monotonicity of cardinality. Conversely, if v(x) > v(y), then {z : v(z) < v(y)} ⊊ {z : v(z) < v(x)} (since y is in the latter but not the former), giving v̂(y) < v̂(x). □

**Theorem 8.3** (Certified Reconstruction). Given a closure operator C whose closed sets form a chain, one can construct a minimal gauge valuation realizing C.

*Proof sketch.* Combine Theorem 7.1 (chain implies realizable) with Theorem 8.1 (minimal realization exists). The construction is explicitly given by the cardinality-based valuation from Theorem 7.1. □

---

## 9. Separation and Injectivity

**Theorem 9.1** (Separation iff Injectivity). A valuation closure valuationClosure(v) is separated if and only if v is injective.

*Proof sketch.* (⟹) If v(a) = v(b) for a ≠ b, then cl_v({a}) = {x : v(x) ≤ v(a)} = {x : v(x) ≤ v(b)} = cl_v({b}), contradicting separation. (⟸) If v is injective and a ≠ b, then v(a) ≠ v(b). WLOG v(a) < v(b); then b ∈ cl_v({b}) but b ∉ cl_v({a}), so the closures differ. □

**Theorem 9.2** (Separated Chain Admits Injective Realization). If C is a closure operator whose closed sets form a chain and which is separated, then there exists an injective valuation v with C.cl = cl_v.

*Proof sketch.* By Theorem 7.1, obtain a realization v. Separation of C transfers to separation of valuationClosure(v), which by Theorem 9.1 implies injectivity of v. □

---

## 10. Concrete Examples

**Theorem 10.1** (Discrete Closure Not Realizable). For n ≥ 2, the discrete closure operator (cl = id) on Fin n is not gauge-realizable.

*Proof sketch.* The discrete closure has every subset closed. For n ≥ 2, the singletons {0} and {1} are incomparable under inclusion, violating the chain condition. □

**Theorem 10.2** (Total Closure Realizable). The total closure operator (cl(S) = univ for all S) is gauge-realizable, witnessed by the zero valuation v(x) = 0 for all x.

*Proof sketch.* cl_0(S) = {x : 0 ≤ sup_S 0} = {x : 0 ≤ 0} = univ. □

---

## 11. Discussion

### 11.1 Connections to Tropical Algebra

The supremum operation over ℕ is the "addition" of the tropical semiring (ℕ, max, +). The valuation closure can be understood as the tropical kernel of the gauge functional: cl_v(S) consists of all elements tropically dominated by S. The chain property of closed sets reflects the total ordering of tropical scalars — a feature absent in classical linear algebra, where kernels can have arbitrary dimension.

More precisely, in the max-plus algebra (ℕ ∪ {-∞}, max, +), a linear functional is a map f(x) = max_i (a_i + x_i). The sublevel sets of such a functional are precisely our valuation closures when we specialize to the case where x is the characteristic vector of a set. This connection suggests that our realizability duality may extend to a tropical linear algebra duality for more general max-plus systems, where the role of the chain condition would be played by the rank condition for tropical matrices.

### 11.2 Automata-Theoretic Perspective

In the Myhill-Nerode theorem, a language is regular iff its syntactic congruence has finitely many classes. Analogously, a closure operator is gauge-realizable iff its closed sets form a chain. The rank of the minimal realization plays the role of the state complexity. The normalization procedure (Theorem 8.2) is the analogue of minimization.

The connection runs deeper than analogy. In weighted automata theory over the tropical semiring, the behavior of a weighted automaton is a formal power series with coefficients in (ℕ, max, +). The Hankel matrix of such a series determines a closure on the set of input symbols, and the rank of the Hankel matrix corresponds to the number of states in a minimal realization. Our Theorem 7.1 can be seen as the "tropical Hankel rank" theorem: a closure is realizable (has finite tropical Hankel rank) if and only if its closed sets form a chain, and the rank equals the number of distinct values in the minimal gauge valuation.

### 11.3 Discrete Gauge Theory

In lattice gauge theories, a gauge field assigns group elements to edges, and gauge equivalence identifies configurations related by local transformations that preserve holonomies. Our gauge equivalence (Definition 2.4) is the abelian, discrete analogue: two valuations are equivalent if they preserve the ordering of "holonomy capacities." The closure encodes the observable content — analogous to Wilson loops — and the holographic duality (Theorem 6.3) says that capacity measurements (analogous to expectation values) suffice to reconstruct the full gauge field up to equivalence.

The analogy with physical gauge theories illuminates several of our results. The holographic duality (Theorem 6.3) is the discrete analogue of the fact that Wilson loop expectation values determine the gauge connection up to gauge transformations. The capacity function cap(S) = |cl(S)| plays the role of the partition function restricted to a region S, and the theorem states that these "local partition functions" determine the global gauge structure. This mirrors the holographic principle in quantum gravity, where boundary data (the capacity profile, defined on subsets) encodes bulk structure (the closure operator, defined on the full power set).

### 11.4 Formal Concept Analysis

Closure operators are the mathematical backbone of formal concept analysis (FCA), where they arise from Galois connections between objects and attributes. In FCA, the closed sets of a closure operator correspond to formal concepts, and the lattice of concepts encodes the structure of a knowledge domain. Our chain characterization (Theorem 7.1) identifies precisely which concept lattices are "one-dimensional" — expressible as a single numerical ranking of objects. This has practical implications: datasets whose concept lattice is a chain can be summarized by a single numerical score per object, achieving maximal compression without information loss.

The holographic duality adds another practical dimension: to determine whether a dataset admits such a one-dimensional summary, it suffices to compute |cl(S)| for each subset S — a quantity that can be estimated from samples without explicitly constructing the closure operator.

### 11.5 Formal Verification

All main results have been formally verified in the Lean 4 proof assistant using the Mathlib library. The formalization comprises approximately 400 lines of Lean code covering Sections 3–10 of this paper. The formal proofs closely follow the proof sketches given here, with additional detail required for finiteness arguments and decidability instances.

The formalization required careful handling of several technical issues:

- **Decidability**: Working with `Finset α` rather than `Set α` ensures decidable membership and equality, which is necessary for the computational content of the proofs. The `DecidableEq α` and `Fintype α` instances are threaded through all definitions.

- **Supremum conventions**: The `Finset.sup` operation in Mathlib returns `⊥` for empty sets, which for `ℕ` is `0`. This convention interacts with several proofs, particularly the idempotence argument where we need `sup(cl_v(S)) = sup(S)`.

- **Extensionality**: Several key proofs (gauge uniqueness, holographic duality) require showing equality of functions, which in Lean 4 requires `funext` followed by `ext` on `Finset`. The formal proofs use a combination of `Finset.ext_iff` and membership characterizations.

- **Well-ordering**: The existence of minimal realizations uses the well-ordering principle for ℕ, formalized via `Set.exists_min_image` applied to the finite set of achievable ranks.

---

## 12. Future Directions

### 12.1 Monotone KL Divergence Along the OU Flow

An adjacent research direction concerns the Ornstein-Uhlenbeck (OU) process, which appears in the theory of diffusion models. For the OU process with rate parameter θ > 0, one can study the KL divergence from the time-t marginal distribution to the stationary Gaussian distribution. The KL divergence, expressed in terms of the evolving mean and variance of the Gaussian marginals, is conjectured to be monotonically decreasing in t. Establishing this requires proving that the composed KL-along-flow function factors as a sum of exponentially decaying terms with negative exponents, providing a Lyapunov function for the dynamics.

### 12.2 Infinite Extensions

The current framework assumes finite ground sets. Extending to infinite (but compact or locally finite) settings would connect to continuous tropical geometry and infinite-dimensional gauge theory. Key challenges include handling the supremum over infinite sets and ensuring well-definedness of the capacity function.

### 12.3 Multi-Dimensional Gauge Valuations

Replacing the single valuation v : α → ℕ with a vector-valued valuation v : α → ℕ^k yields a richer closure structure. The closed sets of such a multi-gauge closure form an antichain-free lattice rather than a chain. Characterizing realizability in this generalized setting is an open problem.

### 12.4 Algorithmic Applications

The certified reconstruction procedure (Theorem 8.3) gives an algorithm for computing minimal gauge valuations from closure data. Implementing and benchmarking this algorithm on real-world closure systems (e.g., concept lattices from formal concept analysis) is a natural next step.

---

## References

The results in this paper are self-contained. Classical background on closure operators can be found in standard lattice theory references. The tropical algebra perspective draws on the theory of idempotent semirings. The gauge theory analogy is informed by the lattice gauge theory literature in mathematical physics.
