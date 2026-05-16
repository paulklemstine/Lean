# Closure Properties of Weighted Tree Automata over the Tropical Semiring: Formally Verified Product and Union Constructions

## Abstract

We establish formally verified closure properties for weighted bottom-up tree automata over the tropical (min-plus) semiring. We define a notion of weighted tree automaton (WTA) with real-valued transition and acceptance costs over ranked alphabets, and prove three main theorems: (1) **Product closure**: for any two WTAs A₁, A₂ with state spaces Q₁, Q₂, the product automaton with state space Q₁ × Q₂ satisfies eval(A₁ ⊗ A₂, t) = eval(A₁, t) + eval(A₂, t) for all trees t; (2) **Union semantic decomposition**: the pointwise minimum min(eval(A₁, t), eval(A₂, t)) decomposes as an infimum over the disjoint sum Q₁ ⊕ Q₂; (3) **Finite family closure**: the infimum over any finite nonempty family of WTA evaluations equals the infimum over the sigma-type state space. All proofs are machine-verified in Lean 4 with Mathlib, using no axioms beyond the standard ones (propext, Classical.choice, Quot.sound). We provide executable Python implementations with numerical verification across multiple application domains.

**Keywords**: weighted tree automata, tropical semiring, min-plus algebra, closure properties, formal verification, dynamic programming, compositional optimization

---

## 1. Introduction

### 1.1 Background

Weighted tree automata (WTAs) generalize classical finite tree automata by associating costs from a semiring to transitions, enabling quantitative analysis of tree-structured data. When the semiring is the tropical (min-plus) semiring — where addition corresponds to minimum and multiplication corresponds to ordinary addition — WTAs naturally model dynamic programming on trees, optimization over parse forests, cost analysis of hierarchical circuits, and tree-structured machine learning models.

The closure properties of weighted word automata (over strings rather than trees) are classical results in automata theory. For arbitrary semirings, the class of recognizable formal power series over words is closed under sum, Hadamard product (pointwise product), and scalar multiplication. For the tropical semiring specifically, these operations correspond to pointwise minimum, pointwise addition of costs, and addition of a constant.

For weighted tree automata, analogous closure results have been stated in the literature (see Borchardt 2005, Droste–Kuich–Vogler 2009), but complete formal proofs with machine verification have been lacking. The tree case is more complex than the word case because transitions depend on tuples of child states, requiring careful treatment of product state-space decompositions and higher-arity tropical distributivity.

### 1.2 Contributions

This paper makes the following contributions:

1. **Formal definitions** of ranked trees, weighted tree automata, and tropical evaluation semantics in Lean 4, using `Finset.inf'` for computable finite minima over real-valued costs.

2. **Product closure theorem** (Theorem A): a constructive proof that the product automaton with state space Q₁ × Q₂ computes the pointwise sum of two WTA evaluations, including the stronger state-indexed version.

3. **Union semantic decomposition** (Theorem B): a proof that the pointwise minimum of two WTA evaluations decomposes over the disjoint sum state space Q₁ ⊕ Q₂, with an embedding inequality for the constructed union automaton.

4. **Finite family closure** (Theorem C): a generalization to arbitrary finite nonempty families of WTAs, showing the ensemble minimum decomposes over the sigma-type state space.

5. **State complexity bounds**: verified cardinality identities |Q₁ × Q₂| = |Q₁| · |Q₂| and |Q₁ ⊕ Q₂| = |Q₁| + |Q₂|.

6. **Monotonicity**: if each component evaluation is dominated pointwise, the product evaluation is also dominated.

7. **Executable implementations** in Python with numerical verification.

### 1.3 Related Work

**Weighted tree automata theory.** The standard reference is Droste, Kuich, and Vogler (2009), which develops the theory of weighted tree automata over arbitrary semirings. Our work focuses specifically on the tropical semiring and provides machine-verified proofs.

**Tropical geometry.** Mikhalkin (2004), Itenberg, Mikhalkin, and Shustin (2009) established tropical algebraic geometry. Our work connects tree automata closure to tropical algebraic structures.

**Formal verification of automata.** The Myhill–Nerode theorem for tropical word automata has been formalized in related work. Our contribution extends this to trees.

---

## 2. Definitions and Notation

### 2.1 Ranked Trees

**Definition 2.1** (Ranked Alphabet). A *ranked alphabet* is a pair (σ, ar) where σ is a type of symbols and ar : σ → ℕ assigns an arity to each symbol.

**Definition 2.2** (Ranked Tree). Given a ranked alphabet (σ, ar), the set of *ranked trees* T(σ, ar) is defined inductively:
- If a ∈ σ with ar(a) = k, and t₁, ..., tₖ ∈ T(σ, ar), then node(a, t₁, ..., tₖ) ∈ T(σ, ar).

In Lean 4:
```
inductive RankedTree (σ : Type*) (ar : σ → ℕ) where
  | node (a : σ) (children : Fin (ar a) → RankedTree σ ar)
```

### 2.2 Weighted Tree Automata

**Definition 2.3** (Weighted Tree Automaton). A *weighted tree automaton* (WTA) over (σ, ar) with state space Q is a triple A = (Q, δ, f) where:
- Q is a finite nonempty set of states,
- δ : Π (a : σ), (Fin(ar(a)) → Q) → Q → ℝ is the transition cost function,
- f : Q → ℝ is the final-state cost function.

### 2.3 Tropical Evaluation Semantics

**Definition 2.4** (State-Indexed Evaluation). For a WTA A = (Q, δ, f) and a tree t, the *state-indexed evaluation* evalState(A, t, q) gives the minimum cost of processing t bottom-up and arriving at state q:

evalState(A, node(a, c₁, ..., cₖ), q) = min_{qs : Fin(k) → Q} [∑ᵢ evalState(A, cᵢ, qsᵢ) + δ(a, qs, q)]

**Definition 2.5** (Global Evaluation). The *global evaluation* is:

eval(A, t) = min_{q ∈ Q} [evalState(A, t, q) + f(q)]

The minimum operations are realized as `Finset.univ.inf'` over the finite nonempty state space, ensuring computability and well-definedness.

---

## 3. Main Results

### 3.1 Theorem A: Tropical Product Closure

**Definition 3.1** (Product Automaton). Given WTAs A₁ = (Q₁, δ₁, f₁) and A₂ = (Q₂, δ₂, f₂), the *product automaton* A₁ ⊗ A₂ = (Q₁ × Q₂, δ_prod, f_prod) is defined by:
- δ_prod(a, qs, (q₁, q₂)) = δ₁(a, π₁ ∘ qs, q₁) + δ₂(a, π₂ ∘ qs, q₂)
- f_prod((q₁, q₂)) = f₁(q₁) + f₂(q₂)

**Theorem 3.2** (State-Indexed Product Identity). For all trees t, states q₁ ∈ Q₁, q₂ ∈ Q₂:

evalState(A₁ ⊗ A₂, t, (q₁, q₂)) = evalState(A₁, t, q₁) + evalState(A₂, t, q₂)

*Proof sketch.* By structural induction on t. At a node t = node(a, c₁, ..., cₖ), unfold both sides and apply three key steps:

1. **Induction hypothesis**: for each child cᵢ and each pair of states, evalState of the product equals the sum of individual evalStates.

2. **Function splitting**: decompose Fin(k) → Q₁ × Q₂ as (Fin(k) → Q₁) × (Fin(k) → Q₂) via the bijection qs ↦ (π₁ ∘ qs, π₂ ∘ qs). This is the `inf'_piProd_eq` lemma.

3. **Min-plus Fubini**: use the identity min_{(x,y)} [f(x) + g(y)] = min_x f(x) + min_y g(y). This is the `inf'_product_add_real` lemma, proved via `le_antisymm` using the existence of minimizers (by finiteness) in one direction and pointwise bounds in the other. □

**Theorem 3.3** (Global Product Identity). For all trees t:

eval(A₁ ⊗ A₂, t) = eval(A₁, t) + eval(A₂, t)

*Proof.* Unfold eval, apply Theorem 3.2, and use `inf'_product_add_real` on the final-state minimization. □

### 3.2 Theorem B: Tropical Union Semantic Decomposition

**Theorem 3.4** (Union Decomposition). For all trees t:

min(eval(A₁, t), eval(A₂, t)) = inf_{q ∈ Q₁ ⊕ Q₂} cost(q, t)

where cost(inl(q₁), t) = evalState(A₁, t, q₁) + f₁(q₁) and cost(inr(q₂), t) = evalState(A₂, t, q₂) + f₂(q₂).

*Proof.* Apply `Finset.inf'_sum` to decompose the infimum over Q₁ ⊕ Q₂ into the infimum of the two component infima. Each component infimum is exactly the corresponding eval. □

**Definition 3.5** (Union Automaton). The *union automaton* unionWTA(A₁, A₂, M) has state space Q₁ ⊕ Q₂ with:
- Transitions within the left component use δ₁ (when all children are in the left component)
- Transitions within the right component use δ₂ (when all children are in the right component)
- Cross-component transitions receive penalty M
- f(inl(q₁)) = f₁(q₁), f(inr(q₂)) = f₂(q₂)

**Theorem 3.6** (Embedding Inequality). For all trees t and any penalty M:

eval(unionWTA(A₁, A₂, M), t) ≤ min(eval(A₁, t), eval(A₂, t))

*Proof.* By induction on t, show that evalState of the union at inl(q₁) ≤ evalState of A₁ at q₁ (and similarly for inr). The key observation: for any child-state assignment qs₁ : Fin(k) → Q₁ in A₁, the assignment Sum.inl ∘ qs₁ is a valid all-left assignment for the union automaton with the same cost. Since the union's evalState minimizes over a larger set of assignments, it can only be smaller. □

**Remark.** Over ℝ (as opposed to ℝ ∪ {+∞}), the reverse inequality requires M to be sufficiently large relative to the specific tree. This is a fundamental limitation of working without an absorbing element. The semantic decomposition theorem (Theorem 3.4) provides the exact equality without this limitation.

### 3.3 Theorem C: Finite Family Closure

**Theorem 3.7** (Finite Family Closure). Let I be a nonempty finite set and {Aᵢ}_{i∈I} a family of WTAs with state spaces {Qᵢ}_{i∈I}. Then:

inf_{i ∈ I} eval(Aᵢ, t) = inf_{⟨i,q⟩ ∈ Σ_{i∈I} Qᵢ} [evalState(Aᵢ, t, q) + fᵢ(q)]

*Proof.* By `le_antisymm`:
- (≤) For each ⟨i, q⟩ in the sigma-type, evalState(Aᵢ, t, q) + fᵢ(q) ≥ eval(Aᵢ, t) ≥ inf_I eval. So the sigma infimum ≥ the I-indexed infimum.
- (≥) For each i ∈ I and each q ∈ Qᵢ, ⟨i, q⟩ is in the sigma-type, so the sigma infimum ≤ evalState(Aᵢ, t, q) + fᵢ(q). Taking the infimum over q: sigma infimum ≤ eval(Aᵢ, t). Since this holds for all i, sigma infimum ≤ inf_I eval. □

### 3.4 State Complexity and Monotonicity

**Theorem 3.8** (State Complexity).
- |Q₁ × Q₂| = |Q₁| · |Q₂| (product automaton)
- |Q₁ ⊕ Q₂| = |Q₁| + |Q₂| (union automaton)

**Theorem 3.9** (Monotonicity). If eval(A₁, t) ≤ eval(A₁', t) and eval(A₂, t) ≤ eval(A₂', t) for all t, then eval(A₁ ⊗ A₂, t) ≤ eval(A₁' ⊗ A₂', t) for all t.

---

## 4. Key Algebraic Lemmas

### 4.1 Tropical Distributivity

**Lemma 4.1** (inf' + constant). For a nonempty finite set S and function g : S → ℝ:

(inf'_S g) + c = inf'_S (λ s, g(s) + c)

This expresses that addition distributes over minimum in a linearly ordered group.

### 4.2 Min-Plus Fubini

**Lemma 4.2** (Product Separability). For nonempty finite sets A, B and functions u : A → ℝ, v : B → ℝ:

inf'_{(a,b) ∈ A×B} [u(a) + v(b)] = inf'_A u + inf'_B v

*Proof.* The (≤) direction picks optimal a*, b* from Finset.exists_min_image. The (≥) direction uses pointwise bounds. □

### 4.3 Product Function Splitting

**Lemma 4.3** (Pi-Product Equivalence). For g : (Fin(n) → Q₁ × Q₂) → ℝ satisfying the projection condition:

inf'_{qs} g(qs) = inf'_{qs₁} inf'_{qs₂} g(λ i, (qs₁(i), qs₂(i)))

This lemma encodes the combinatorial bijection between product-valued functions and pairs of functions, which is the tree-specific heart of the product theorem.

---

## 5. Algorithms and Complexity

### 5.1 Bottom-Up Evaluation

**Algorithm 1: eval_state_dp(A, t)**
```
Input: WTA A = (Q, δ, f), tree t = node(a, c₁, ..., cₖ)
Output: Dictionary {q ↦ evalState(A, t, q) for q ∈ Q}

1. For each child cᵢ, recursively compute eval_state_dp(A, cᵢ)
2. For each q ∈ Q:
   2a. Initialize best ← +∞
   2b. For each qs ∈ Q^k:
       cost ← Σᵢ eval_state_dp(A, cᵢ)[qsᵢ] + δ(a, qs, q)
       best ← min(best, cost)
   2c. result[q] ← best
3. Return result
```

**Complexity**: O(|t| · |Q|^(k_max + 1)) time, O(|t| · |Q|) space, where k_max is the maximum arity.

### 5.2 Product Evaluation

The product automaton has |Q₁| · |Q₂| states, so evaluation has complexity O(|t| · (|Q₁| · |Q₂|)^(k_max + 1)). This is exponentially worse than separate evaluation O(|t| · (|Q₁|^(k_max+1) + |Q₂|^(k_max+1))).

However, the product automaton is a *single* automaton that can be composed further with additional constructions, enabling optimization pipelines that would require re-derivation if done component-wise.

### 5.3 Viterbi Decoding

A Viterbi-style algorithm extracts the optimal state assignment (run) achieving the minimum cost. This extends the tree evaluation with backtracking pointers, producing the optimal labeling in O(|t| · |Q|^(k_max + 1)) time.

---

## 6. Applications

### 6.1 Compositional Parsing

In natural language processing, a parser assigns costs to parse trees. Different cost models (syntactic plausibility, semantic coherence, statistical frequency) can be represented as separate WTAs. The product theorem enables joint optimization: a single product parser computes the combined cost without running separate parsers.

### 6.2 Circuit Cost Analysis

Boolean circuits have tree-structured components. Energy, delay, and area costs can each be modeled by a WTA. The product automaton computes the total cost metric, while the union identifies the tightest single-objective bound. This supports Pareto-optimal design exploration.

### 6.3 Decision Tree Ensembles

Random forests and gradient-boosted trees aggregate predictions from multiple models. The finite family theorem provides a mathematical framework for ensemble aggregation: the minimum-cost automaton across the ensemble is itself recognizable over the combined state space.

### 6.4 Dynamic Programming Certification

Tree-structured dynamic programming algorithms (RNA folding, instruction scheduling, network routing) can be certified by showing the cost function is tropically recognizable. The closure theorems then guarantee that compositions of certified algorithms remain certifiable.

---

## 7. Discussion

### 7.1 The ℝ vs ℝ∞ Issue

Our product theorem works cleanly over ℝ: the identity eval(A₁ ⊗ A₂, t) = eval(A₁, t) + eval(A₂, t) holds for all trees with no additional hypotheses. The union theorem is more subtle: over ℝ (without +∞), the penalty-based union automaton cannot guarantee exact equality for all trees with a single finite penalty. This is why we provide both:
- The semantic decomposition theorem (exact equality, using the abstract decomposition over Q₁ ⊕ Q₂)
- The embedding inequality (one-sided bound for the concrete union automaton)

Working over WithTop ℝ or EReal would resolve this, at the cost of more complex algebraic manipulation.

### 7.2 Comparison with Word Automata

For word automata (trees of arity ≤ 1), the product theorem is classical. The tree case is genuinely harder because:
1. The state assignment at a node involves a *tuple* of child states (not just one predecessor state)
2. The product decomposition requires splitting Fin(k) → Q₁ × Q₂ into pairs of functions
3. The min-plus Fubini principle must be applied at each tree node, not just along a linear chain

### 7.3 Limitations

- Our formalization works over ℝ, not an arbitrary semiring. Generalization to abstract semirings would require additional algebraic infrastructure.
- The evaluation complexity of the product automaton grows multiplicatively in state count. For applications requiring many compositions, minimization techniques would be needed.
- We do not treat weighted tree transducers, which would extend the theory to tree-to-tree transformations.

---

## 8. Future Work

1. **Minimization**: Prove that the product and union automata can be minimized, with tight bounds on the minimal state count.
2. **Transducers**: Extend closure to weighted tree transducers for cost-preserving tree transformations.
3. **Tropical neural networks**: Connect WTA closure to tropical geometry of ReLU networks.
4. **Probabilistic extensions**: Study how the closure theorems deform under the log-sum-exp semiring (finite-temperature tropical).
5. **Lower bounds**: Use the state complexity of product automata to derive lower bounds on tropical tree computation.

---

## 9. Formal Verification Details

All definitions and theorems are formalized in Lean 4 (version 4.28.0) with Mathlib. The formalization consists of three files:

- `Tropical/TreeAutomata/Basic.lean` (82 lines): Core definitions
- `Tropical/TreeAutomata/Product.lean` (178 lines): Product closure with all helper lemmas
- `Tropical/TreeAutomata/Union.lean` (157 lines): Union decomposition and embedding
- `Tropical/TreeAutomata/FiniteFamily.lean` (74 lines): Finite family closure

All proofs use only standard axioms (propext, Classical.choice, Quot.sound). No sorry statements remain in the final code.

---

## References

1. B. Borchardt. The Theory of Recognizable Tree Series. PhD thesis, TU Dresden, 2005.
2. M. Droste, W. Kuich, H. Vogler. Handbook of Weighted Automata. Springer, 2009.
3. I. Simon. Recognizable sets with multiplicities in the tropical semiring. MFCS, 1988.
4. G. Mikhalkin. Enumerative tropical algebraic geometry in ℝ². J. Amer. Math. Soc., 2005.
5. F. Baccelli, G. Cohen, G.J. Olsder, J.-P. Quadrat. Synchronization and Linearity: An Algebra for Discrete Event Systems. Wiley, 1992.
6. J. Engelfriet. Bottom-up and top-down tree transformations — a comparison. Math. Systems Theory, 1975.
7. Z. Fülöp, H. Vogler. Weighted tree automata and tree transducers. In Handbook of Weighted Automata, 2009.
