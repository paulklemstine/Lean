# Future Directions: Tropical Monotone Circuits

This document outlines five breakthrough research directions opened by the formalization of tropical monotone circuits, their monotonicity, Boolean embedding, normal-form decomposition, and min-max duality.

---

## Direction 1: DAG Semantics Equivalence for Acyclic Tropical Circuits

### Theorem Statement
Define a DAG-backed representation `TropDAG n` with explicit acyclicity certification (via topological ordering). Prove that for every formula-like `TropCircuit n`, there exists an equivalent `TropDAG n` with evaluation agreement, and conversely that every `TropDAG n` can be unfolded into a `TropCircuit n` preserving semantics.

```
theorem dag_circuit_equiv (D : TropDAG n) (x : Fin n → ℝ) :
    TropDAG.eval D x = TropCircuit.eval (unfold D) x
```

### Why It Matters
DAG representations capture sharing — subcircuits reused multiple times — which is the key to separating formula size from circuit size. This distinction is central to complexity theory: monotone circuit lower bounds (Razborov, Alon–Boppana) fundamentally depend on DAG structure. Formalizing DAG semantics would open the path to formal circuit complexity results.

### Proof Strategy
Define `TropDAG n` as a finite array of nodes with labeled gates and parent pointers, plus a proof of acyclicity (e.g., a valid topological ordering). Define evaluation by iterating in topological order. The equivalence proof proceeds by structural induction on the DAG layers.

### Cross-Domain Connection
DAG circuits correspond directly to dynamic programming tables: each node computes a subproblem, `+` concatenates costs, and `min` selects optimal branches. This connection would formalize the equivalence between circuit evaluation and Bellman-equation solving.

---

## Direction 2: Tropical Circuit Normal-Form Complexity Bounds

### Theorem Statement
Prove that the number of affine forms in `normalForms C` is bounded by `2^(size C)` and that this bound is tight. More precisely:

```
theorem normalForms_card_le_exp_size (C : TropCircuit n) :
    Multiset.card (normalForms C) ≤ 2 ^ C.size

theorem normalForms_card_tight :
    ∃ (n : ℕ) (C : TropCircuit n), Multiset.card (normalForms C) = 2 ^ C.size
```

### Why It Matters
The number of affine pieces in a piecewise-linear function is a fundamental complexity measure in tropical geometry. Bounding it by circuit size creates a formal link between combinatorial circuit complexity and geometric complexity (number of faces of tropical hypersurfaces). This could yield formal lower bounds: if a function requires at least `k` affine pieces, then any circuit computing it must have size at least `log₂ k`.

### Proof Strategy
The upper bound follows by induction: `var` and `const` produce 1 piece, `min` produces at most the sum, and `add` produces at most the product. The lower bound is witnessed by a balanced binary tree of `min` gates over distinct variables.

### Cross-Domain Connection
In tropical geometry, the number of affine pieces corresponds to the number of vertices of the Newton polytope. This connects circuit size to polyhedral complexity, opening a path toward tropical analogues of algebraic complexity lower bounds.

---

## Direction 3: Shortest-Path Completeness for Series-Parallel Circuits

### Theorem Statement
Define a series-parallel tropical circuit (built by serial composition via `+` and parallel composition via `min` from leaves). Prove that evaluation equals the minimum-weight source-to-sink path in an associated series-parallel network.

```
theorem series_parallel_shortest_path (C : SPTropCircuit n) (x : Fin n → ℝ) :
    C.eval x = Finset.inf' (paths C) (paths_nonempty C)
      (fun p => pathWeight p x)
```

### Why It Matters
This is the first true "DP completeness" theorem: it shows that tropical circuits don't just look like dynamic programs — they *are* dynamic programs, in the precise sense that evaluation equals optimization over a combinatorial family of solutions (paths). This creates a certified compilation pathway from optimization problems to circuit representations.

### Proof Strategy
Define `SPTropCircuit` as a restricted inductive type (no nested patterns). Associate a series-parallel graph to each circuit: `var i` creates an edge with weight `x i`, `const c` creates an edge with weight `c`, `+` composes in series, `min` composes in parallel. Prove evaluation = minimum path weight by induction.

### Cross-Domain Connection
Series-parallel networks arise in reliability theory, project scheduling (PERT/CPM), and network flow. This theorem would create a formal bridge between tropical circuits and certified network optimization, enabling verified shortest-path algorithms via circuit evaluation.

---

## Direction 4: Min/Max Duality Transfer and Game-Theoretic Semantics

### Theorem Statement
Extend the proven `eval_duality` theorem to show that properties of min-plus circuits transfer to max-plus circuits and vice versa. In particular, prove that monotonicity, normal-form decomposition, and Boolean embedding all have dual versions.

```
theorem dual_monotone (C : TropCircuit n) :
    Antitone (fun x => MaxTropCircuit.eval (C.dual) x)

theorem dual_normalForms (C : TropCircuit n) (x : Fin n → ℝ) :
    MaxTropCircuit.eval (C.dual) x =
      Finset.sup' (dualNormalForms C) ... (fun a => TropAffine.eval a x)
```

### Why It Matters
Max-plus algebra is the algebra of optimal control and game theory. The dual semantics transforms minimization circuits into maximization circuits, connecting to:
- Two-player zero-sum games (min-max = saddle points)
- Bellman equations for optimal control
- Maslov's idempotent analysis framework

A formal duality transfer would mean every theorem about min-plus circuits immediately yields a dual theorem about max-plus circuits, doubling the yield of every proof.

### Proof Strategy
The `eval_duality` theorem already provides the semantic bridge. The transfer theorems follow by composing duality with the original results: e.g., dual monotonicity follows from `eval_duality` + `eval_mono_pointwise` + properties of negation.

### Cross-Domain Connection
In game theory, min-max circuits represent strategies in extensive-form games. The duality theorem would formalize the equivalence between "Player 1 minimizes" and "Player 2 maximizes after negation," connecting tropical circuits to the minimax theorem.

---

## Direction 5: Tropical Lower Bounds via Affine-Piece Counting

### Theorem Statement
Prove a formal lower bound: there exist explicit Boolean functions whose tropical circuit complexity is exponential.

```
theorem tropical_lower_bound :
    ∃ (f : (Fin n → ℝ) → ℝ), IsTropicalPoly f ∧
      ∀ C : TropCircuit n, (∀ x, C.eval x = f x) → C.size ≥ 2^(n/2)
```

### Why It Matters
This would be the first formally verified circuit lower bound in the tropical setting. While monotone circuit lower bounds have been known since Razborov (1985) in the Boolean world, the tropical setting offers a different lens: lower bounds via the number of affine pieces needed to represent a function. This geometric perspective could yield new techniques transferable back to Boolean complexity.

### Proof Strategy
The candidate hard function is the tropical permanent (minimum-weight perfect matching), which requires exponentially many affine pieces. The proof would proceed by:
1. Showing the tropical permanent has `n!` affine pieces (one per permutation).
2. Proving that any circuit of size `s` produces at most `2^s` affine pieces (from Direction 2).
3. Combining to get `s ≥ log₂(n!) ≥ n log₂(n) / 2`.

### Cross-Domain Connection
This connects to:
- The permanent vs. determinant problem in algebraic complexity
- Valiant's theory of algebraic computation
- Tropical intersection theory (Newton polytopes of the permanent)
- Optimization hardness (minimum-weight matching)

A formal tropical lower bound would be a stepping stone toward formal algebraic complexity theory in a proof assistant.

---

## Summary Table

| Direction | Key Theorem | Difficulty | Impact |
|-----------|------------|------------|--------|
| 1. DAG Equivalence | Formula ↔ DAG semantics | Medium | Enables circuit complexity |
| 2. Normal-Form Bounds | `|NF(C)| ≤ 2^size(C)` | Easy-Medium | Links circuit and geometric complexity |
| 3. Shortest-Path Completeness | Eval = min-weight path | Medium-Hard | Certified DP compilation |
| 4. Duality Transfer | Automatic dual theorems | Easy | Doubles theorem yield |
| 5. Tropical Lower Bounds | Exponential size lower bound | Hard | First formal tropical lower bound |

Each direction is self-contained but synergistic: Direction 2 feeds into Direction 5, Direction 1 enables richer versions of Direction 3, and Direction 4 doubles the value of every other result. Together, they constitute a research program for formal tropical circuit complexity theory.
