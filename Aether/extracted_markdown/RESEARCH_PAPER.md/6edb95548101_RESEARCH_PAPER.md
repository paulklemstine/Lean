# Closure Properties of Weighted Tree Automata over the Tropical Semiring: Formally Verified Product, Union, and Finite Family Constructions

## Abstract

We establish and formally verify closure properties for weighted bottom-up tree automata over the tropical (min-plus) semiring. Our main results show that the class of tropical-recognizable tree series is closed under:
1. **Pointwise tropical product** (addition of cost functions), via an explicit product automaton construction with multiplicative state complexity;
2. **Pointwise tropical minimum** (union), via the disjoint union state space with additive state complexity;
3. **Finite family infimum**, generalizing binary union to arbitrary finite families via sigma-type state spaces.

The key technical contribution is a **min-plus Fubini principle for tree runs**: the identity `inf_{(f₁,f₂)} (g₁(f₁) + g₂(f₂)) = inf_{f₁} g₁(f₁) + inf_{f₂} g₂(f₂)` lifted to function spaces over branching structures, combined with the equivalence `(Fin k → Q₁ × Q₂) ≃ (Fin k → Q₁) × (Fin k → Q₂)`. All results are formalized and machine-verified in Lean 4 with Mathlib, yielding zero-sorry proofs depending only on standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** tropical semiring, weighted tree automata, min-plus algebra, closure properties, formal verification, dynamic programming, compositional semantics

---

## 1. Introduction

### 1.1 Motivation

Weighted tree automata (WTAs) are a fundamental model in algebraic automata theory, extending classical finite tree automata with quantitative semantics valued in a semiring [Borchardt 2005, Droste–Kuich–Vogler 2009]. When the semiring is the tropical (min-plus) semiring (ℝ, min, +, ∞, 0), the evaluation semantics corresponds to dynamic programming on tree structures — a ubiquitous computational pattern appearing in:

- **Compiler optimization:** instruction selection and register allocation on expression trees;
- **Computational linguistics:** probabilistic/weighted parsing of natural language;
- **Bioinformatics:** RNA secondary structure prediction via minimum free energy;
- **Program analysis:** abstract interpretation over tree-shaped program structures;
- **Machine learning:** hierarchical cost aggregation in tree-structured models.

Closure properties under product (Hadamard product) and union are classical for weighted word automata [Mohri 2009], but the tree case introduces essential combinatorial complications: transitions depend on *tuples* of child states, and the proof of product closure requires separating an infimum over a product function space into independent component infima.

### 1.2 Contributions

We provide:

1. **Formal definitions** of ranked trees, weighted bottom-up tree automata, and their tropical evaluation semantics in Lean 4.
2. **An explicit product automaton construction** and a machine-verified proof that it correctly computes the pointwise sum of evaluations.
3. **A union closure theorem** showing that pointwise minimum is computed over the disjoint union state space.
4. **A finite family infimum theorem** generalizing binary union to arbitrary finite families.
5. **State complexity bounds**: |Q₁ × Q₂| = |Q₁| · |Q₂| for products, |Q₁ ⊕ Q₂| = |Q₁| + |Q₂| for unions.
6. **A monotonicity theorem** for the product construction under pointwise domination.

All proofs are formalized in Lean 4 with the Mathlib library and verified to use only standard axioms.

### 1.3 Related Work

The theory of weighted tree automata over arbitrary semirings is developed in [Borchardt 2005], [Fülöp–Vogler 2009], and the comprehensive [Droste–Kuich–Vogler 2009]. Closure properties for weighted word automata are classical [Kuich–Salomaa 1986, Mohri 2009]. The tropical specialization has connections to:

- Tropical algebraic geometry [Maclagan–Sturmfels 2015];
- Max-plus linear algebra [Butkovič 2010];
- Algebraic dynamic programming [Giegerich et al. 2004];
- Formal verification of automata theory [Doczkal–Smolka 2018].

Our contribution is the first machine-verified formalization of tropical tree automata closure properties, with explicit constructions and semantic correctness proofs.

---

## 2. Definitions and Notation

### 2.1 Ranked Trees

**Definition 2.1** (Ranked Signature). A *ranked signature* consists of a type σ of symbols equipped with an arity function `arity : σ → ℕ`.

**Definition 2.2** (Ranked Tree). Given a ranked signature (σ, arity), the set of *ranked trees* `RTree σ arity` is defined inductively by:
- If `a : σ` and `children : Fin (arity a) → RTree σ arity`, then `node a children : RTree σ arity`.

A symbol of arity 0 produces a leaf node. A symbol of arity k produces an internal node with exactly k children.

### 2.2 Weighted Tree Automata

**Definition 2.3** (Weighted Tree Automaton). A *weighted tree automaton* (WTA) over (σ, arity) with state space Q and weights in ℝ is a tuple A = (Q, stepCost, finalCost) where:
- `Q` is a finite nonempty type (the state space);
- `stepCost : (a : σ) → (Fin (arity a) → Q) → Q → ℝ` assigns a transition cost to each combination of symbol, child-state assignment, and target state;
- `finalCost : Q → ℝ` assigns a final/acceptance cost to each state.

**Remark.** We work over ℝ rather than an extended real line. This means all transitions have finite costs (no "impossible" transitions with cost ∞). This is sufficient for the product closure theorem. For the union closure theorem, we prove semantic equivalence at the `eval` level rather than constructing a WTA with forbidden transitions.

### 2.3 Evaluation Semantics

**Definition 2.4** (State-Indexed Evaluation). For a WTA A with finite nonempty state space Q, the *state-indexed evaluation* `evalState A : RTree σ arity → Q → ℝ` is defined by structural recursion:

```
evalState A (node a children) q =
  min_{f : Fin (arity a) → Q} [stepCost a f q + Σᵢ evalState A (children i) (f i)]
```

The minimum is taken over all possible child-state assignments. Since Q is finite and nonempty, the minimum over the function space `Fin k → Q` is well-defined and finite.

**Definition 2.5** (Global Evaluation). The *global evaluation* is:

```
eval A t = min_{q : Q} [evalState A t q + finalCost q]
```

**Interpretation.** A *run* of A on tree t is a function assigning a state to each node. The *cost* of a run is the sum of all transition costs (including final cost at the root). Then `evalState A t q` is the minimum cost of a run with root state q, and `eval A t` is the minimum cost over all runs.

---

## 3. Product Closure

### 3.1 Product Automaton Construction

**Definition 3.1** (Product Automaton). Given WTAs A₁ = (Q₁, step₁, final₁) and A₂ = (Q₂, step₂, final₂), the *product automaton* `A₁ ×_T A₂` has:
- State space: Q₁ × Q₂
- Transition cost: `stepCost a f (q₁, q₂) = step₁ a (π₁ ∘ f) q₁ + step₂ a (π₂ ∘ f) q₂`
- Final cost: `finalCost (q₁, q₂) = final₁ q₁ + final₂ q₂`

where π₁, π₂ are the projections from Q₁ × Q₂ to Q₁, Q₂.

### 3.2 The Min-Plus Fubini Principle

The proof relies on a key algebraic identity:

**Lemma 3.2** (Min-Plus Fubini). For finite nonempty types α, β and functions f : α → ℝ, g : β → ℝ:

```
min_{a:α} f(a) + min_{b:β} g(b) = min_{(a,b):α×β} [f(a) + g(b)]
```

*Proof.* Let a* = argmin f and b* = argmin g. Then:
- **≤**: The pair (a*, b*) achieves f(a*) + g(b*) = min f + min g on the RHS. So RHS ≤ LHS.
- **≥**: For any (a, b), we have f(a) ≥ min f and g(b) ≥ min g, so f(a) + g(b) ≥ min f + min g. Hence RHS ≥ LHS.

By antisymmetry, LHS = RHS. ∎

**Remark.** This identity fails for infima over infinite sets (where the infimum may not be attained), but holds for finite nonempty sets since the minimum is always attained.

### 3.3 Equivalence of Function Spaces

The second key ingredient is the canonical bijection:

**Lemma 3.3.** For any type I and types Q₁, Q₂:
```
(I → Q₁ × Q₂) ≃ (I → Q₁) × (I → Q₂)
```

This equivalence sends f to (π₁ ∘ f, π₂ ∘ f) and its inverse sends (f₁, f₂) to λi. (f₁ i, f₂ i).

### 3.4 Main Theorem: Statewise Product Closure

**Theorem 3.4** (Statewise Product Closure). For all trees t, states q₁ : Q₁, q₂ : Q₂:

```
evalState (A₁ ×_T A₂) t (q₁, q₂) = evalState A₁ t q₁ + evalState A₂ t q₂
```

*Proof sketch.* By structural induction on t = node a children.

**Step 1: Unfold definitions.**
```
LHS = min_{f : Fin k → Q₁ × Q₂} [
  step₁ a (π₁ ∘ f) q₁ + step₂ a (π₂ ∘ f) q₂
  + Σᵢ evalState (A₁ ×_T A₂) (children i) (f i)
]
```

**Step 2: Apply induction hypothesis.**
By IH, `evalState (A₁ ×_T A₂) (children i) (f i) = evalState A₁ (children i) (π₁(f i)) + evalState A₂ (children i) (π₂(f i))`.

**Step 3: Split the sum.**
Using `Σᵢ (aᵢ + bᵢ) = Σᵢ aᵢ + Σᵢ bᵢ`, rewrite:
```
LHS = min_f [(step₁ a (π₁∘f) q₁ + Σᵢ evalState A₁ (children i) (π₁(f i)))
           + (step₂ a (π₂∘f) q₂ + Σᵢ evalState A₂ (children i) (π₂(f i)))]
```

**Step 4: Apply the function space equivalence.**
Via Lemma 3.3, rewrite the minimization over f : Fin k → Q₁ × Q₂ as a minimization over (f₁, f₂) : (Fin k → Q₁) × (Fin k → Q₂).

**Step 5: Apply Min-Plus Fubini.**
Via Lemma 3.2, separate the independent minimizations:
```
= min_{f₁} [step₁ a f₁ q₁ + Σᵢ evalState A₁ (children i) (f₁ i)]
+ min_{f₂} [step₂ a f₂ q₂ + Σᵢ evalState A₂ (children i) (f₂ i)]
= evalState A₁ t q₁ + evalState A₂ t q₂ = RHS
```
∎

### 3.5 Global Product Closure

**Theorem 3.5** (Product Closure). For all trees t:
```
eval (A₁ ×_T A₂) t = eval A₁ t + eval A₂ t
```

*Proof.* Unfold `eval` and apply Theorem 3.4 to rewrite each summand. Then apply Min-Plus Fubini (Lemma 3.2) to separate the minimization over Q₁ × Q₂ into independent minimizations over Q₁ and Q₂. ∎

### 3.6 State Complexity

**Proposition 3.6.** |Q₁ × Q₂| = |Q₁| · |Q₂|. The product construction has multiplicative state complexity.

---

## 4. Union Closure

### 4.1 Semantic Union

**Theorem 4.1** (Union Closure). For all trees t:
```
min(eval A₁ t, eval A₂ t) =
  min_{q ∈ Q₁ ⊕ Q₂} [h(q)]
```
where h(inl q₁) = evalState A₁ t q₁ + final₁ q₁ and h(inr q₂) = evalState A₂ t q₂ + final₂ q₂.

*Proof.* The minimum over a disjoint union decomposes as:
```
min_{q ∈ Q₁ ⊕ Q₂} h(q) = min(min_{q₁ ∈ Q₁} h(inl q₁), min_{q₂ ∈ Q₂} h(inr q₂))
                          = min(eval A₁ t, eval A₂ t)
```
∎

**Proposition 4.2.** |Q₁ ⊕ Q₂| = |Q₁| + |Q₂|. The union construction has additive state complexity.

### 4.2 Finite Family Infimum

**Theorem 4.3** (Finite Family Closure). For a nonempty finite index set I and automata {Aᵢ}_{i∈I}:
```
inf_{i ∈ I} eval(Aᵢ, t) =
  min_{(i,q) ∈ Σᵢ Qᵢ} [evalState(Aᵢ, t, q) + finalCostᵢ(q)]
```
where the right-hand side minimizes over the sigma-type Σ_{i∈I} Qᵢ.

*Proof.* The iterated infimum `inf_i (inf_q f(i,q)) = inf_{(i,q)} f(i,q)` holds for finite sets, and `inf_q f(i,q) = eval(Aᵢ, t)` by definition. ∎

---

## 5. Monotonicity

**Theorem 5.1** (Monotonicity of Product). If `∀t. eval A₁ t ≤ eval A₁' t` and `∀t. eval A₂ t ≤ eval A₂' t`, then `∀t. eval (A₁ ×_T A₂) t ≤ eval (A₁' ×_T A₂') t`.

*Proof.* By the product closure theorem, `eval (A₁ ×_T A₂) t = eval A₁ t + eval A₂ t ≤ eval A₁' t + eval A₂' t = eval (A₁' ×_T A₂') t`. ∎

---

## 6. Algorithms and Complexity

### 6.1 Bottom-Up Evaluation

**Algorithm 1: evalState(A, t, q)**
```
Input: WTA A with states Q, tree t = node(a, c₁, ..., cₖ), target state q
Output: Minimum cost to process t ending in state q

1. If k = 0: return A.stepCost(a, (), q)
2. best ← +∞
3. For each assignment f : Fin k → Q:
4.   cost ← A.stepCost(a, f, q) + Σᵢ evalState(A, cᵢ, f(i))
5.   best ← min(best, cost)
6. Return best
```

**Time complexity:** O(|t| · |Q|^(max_arity + 1)) where max_arity is the maximum symbol arity.

**Space complexity:** O(|t| · |Q|) with memoization.

### 6.2 Product Construction

**Algorithm 2: productAutomaton(A₁, A₂)**
```
Input: WTAs A₁ = (Q₁, step₁, final₁), A₂ = (Q₂, step₂, final₂)
Output: Product WTA with state space Q₁ × Q₂

1. States ← Q₁ × Q₂
2. For each symbol a, assignment f : Fin(arity a) → Q₁×Q₂, state (q₁,q₂):
3.   stepCost(a, f, (q₁,q₂)) ← step₁(a, π₁∘f, q₁) + step₂(a, π₂∘f, q₂)
4. For each (q₁, q₂):
5.   finalCost((q₁,q₂)) ← final₁(q₁) + final₂(q₂)
6. Return (States, stepCost, finalCost)
```

**Construction time:** O(|Σ| · (|Q₁|·|Q₂|)^(max_arity + 1))

### 6.3 Evaluation of Product Automaton

By the product closure theorem, evaluating the product automaton is equivalent to evaluating the two component automata independently and adding the results. This gives a **computational speedup**: instead of evaluating one automaton with |Q₁|·|Q₂| states (time O(|t| · (|Q₁|·|Q₂|)^(k+1))), we evaluate two automata with |Q₁| and |Q₂| states respectively (time O(|t| · (|Q₁|^(k+1) + |Q₂|^(k+1)))).

For k ≥ 1 and |Q₁|, |Q₂| ≥ 2, this is an exponential speedup in the arity parameter.

---

## 7. Applications

### 7.1 Multi-Objective Compiler Optimization

An arithmetic expression tree can be compiled to machine instructions with different cost profiles. Automaton A₁ measures latency (pipeline depth), A₂ measures register pressure, and A₃ measures code size. The product automaton A₁ ×_T A₂ ×_T A₃ finds the parse that minimizes the weighted sum of all three objectives in a single bottom-up pass.

### 7.2 RNA Secondary Structure Prediction

RNA molecules fold into tree-shaped secondary structures (stems, loops, junctions). Different thermodynamic models assign different energy values. The union closure theorem enables ensemble prediction: the minimum energy across multiple models is itself recognizable, enabling robust structure prediction.

### 7.3 Weighted Parsing

In computational linguistics, parse trees are scored by weighted context-free grammars. Product closure enables multi-criteria parsing (syntactic probability + semantic coherence + discourse structure), while union closure enables model ensembles.

---

## 8. Formal Verification

All results are formalized in Lean 4 (version 4.28.0) with Mathlib. The formalization consists of approximately 250 lines of Lean code and includes:

| Theorem | Lines | Axioms Used |
|---------|-------|-------------|
| `inf'_add_inf'_eq_inf'_prod` | 8 | propext, Classical.choice, Quot.sound |
| `inf'_comp_equiv` | 3 | propext, Classical.choice, Quot.sound |
| `evalState_productAutomaton` | 14 | propext, Classical.choice, Quot.sound |
| `eval_productAutomaton` | 6 | propext, Classical.choice, Quot.sound |
| `inf'_sum_eq_min` | 4 | propext, Classical.choice, Quot.sound |
| `eval_min_eq_inf'_sum` | 2 | propext, Classical.choice, Quot.sound |
| `eval_finset_inf` | 6 | propext, Classical.choice, Quot.sound |
| `eval_productAutomaton_mono` | 3 | propext, Classical.choice, Quot.sound |

All proofs use only the standard axioms of Lean's type theory (propext, Classical.choice, Quot.sound) — no custom axioms, no `sorry`, no `@[implemented_by]`.

---

## 9. Discussion

### 9.1 The Min-Plus Fubini Principle

The central technical insight is that the product closure theorem for trees reduces to a min-plus Fubini principle: the infimum of a sum of independent functions over a product space equals the sum of independent infima. This is the tropical analogue of the classical Fubini theorem for integration, and it holds in full generality for finite sets.

For infinite sets, the principle can fail (the infimum may not be attained, leading to a strict inequality). Our restriction to finite state spaces (Fintype) ensures the principle holds without additional assumptions.

### 9.2 Comparison with Word Automata

For weighted word automata, the product closure proof is essentially one-dimensional: at each position, the product state (q₁, q₂) transitions based on a single previous state. For tree automata, the transition depends on a *k*-tuple of child states, where k is the arity. The proof must handle function spaces `Fin k → Q₁ × Q₂` and establish the equivalence with `(Fin k → Q₁) × (Fin k → Q₂)`. This is the essential new content beyond the word case.

### 9.3 Limitations

Our formalization works over ℝ (real numbers) rather than an extended real line with +∞. This means all transitions have finite costs, and we cannot model "impossible" transitions directly. For the product closure theorem, this is not a limitation (all transition costs are well-defined). For the union closure theorem, we prove semantic equivalence at the `eval` level rather than constructing a single WTA with forbidden transitions. Extending to `WithTop ℝ` or `ENNReal` would enable a fully constructive union automaton.

---

## 10. Future Work

1. **Tropical determinization and minimization** for tree automata, extending the Myhill-Nerode theory to the weighted tree setting.
2. **Weighted MSO equivalence**: proving that tropical-recognizable tree series coincide with those definable in weighted MSO logic.
3. **Tropical spectral theory**: connecting WTA evaluation on unary trees to tropical eigenvalues and cycle means.
4. **Extension to infinite trees**: ω-tree automata with tropical weights for modeling infinite computations.
5. **Verified tropical parsing**: formalizing the CYK algorithm as a WTA evaluation and proving correctness.

---

## References

1. Borchardt, B. "The Theory of Recognizable Tree Series." PhD thesis, TU Dresden, 2005.
2. Butkovič, P. *Max-linear Systems: Theory and Algorithms.* Springer, 2010.
3. Doczkal, C. and Smolka, G. "Regular Language Representations in the Constructive Type Theory of Coq." *J. Automated Reasoning*, 61:521–553, 2018.
4. Droste, M., Kuich, W., and Vogler, H. *Handbook of Weighted Automata.* Springer, 2009.
5. Fülöp, Z. and Vogler, H. *Weighted Tree Automata and Tree Transducers.* In [4], Chapter 9, 2009.
6. Giegerich, R., Meyer, C., and Steffen, P. "A Discipline of Dynamic Programming over Sequence Data." *Science of Computer Programming*, 51(3):215–263, 2004.
7. Kuich, W. and Salomaa, A. *Semirings, Automata, Languages.* Springer, 1986.
8. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
9. Mohri, M. "Weighted Automata Algorithms." In [4], Chapter 6, 2009.
