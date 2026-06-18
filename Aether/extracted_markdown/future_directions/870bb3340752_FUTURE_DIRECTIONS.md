# Future Directions: Tropical Finite Optimization Bridge Program

This document specifies five concrete next theorems, each opening a new cross-domain bridge from the tropical finite optimization layer established in `Bridges/TropicalFiniteOptimization.lean`.

---

## 1. Tropical Matrix Multiplication and Shortest-Path Duality

**Theorem Statement**: The tropical matrix product `(A ⊕ B)_{ij} = min_k (A_{ik} + B_{kj})` satisfies associativity and admits a certified shortest-path interpretation over `Fin n`.

**Lean Type Signature**:
```lean
noncomputable def tropicalMatMul (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.inf' Finset.univ ⟨0, Fin.pos⟩ (fun k => A i k + B k j)

theorem tropicalMatMul_assoc (n : ℕ) (hn : 0 < n)
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropicalMatMul n (tropicalMatMul n A B) C =
    tropicalMatMul n A (tropicalMatMul n B C) := by ...
```

**Proof Strategy**: Reduce associativity to the interchange of two finite infima (`inf'` over `Fin n`), using the additive structure of `ℝ` and commutativity of the inf-plus operation. The key lemma is that `min_k (min_j (a_j + b_{jk}) + c_{ki}) = min_j (a_j + min_k (b_{jk} + c_{ki}))`, which follows from distributivity of `+` over `min` in the tropical semiring.

**Cross-Domain Bridge**: This opens the route to tropical dynamic programming for proof search (Viterbi-style algorithms), shortest-path verification in cryptographic protocols, and operator-algebraic proof complexity where matrix powers track multi-step reachability costs.

---

## 2. Subadditivity of Tropical Aggregation under Composition

**Theorem Statement**: For composable cost functions (e.g., proof steps), the infimum of a composed cost is at most the sum of the component infima.

**Lean Type Signature**:
```lean
theorem tropical_subadditivity
    {α β : Type} [DecidableEq α] [DecidableEq β]
    (s : Finset α) (t : Finset β)
    (hs : s.Nonempty) (ht : t.Nonempty)
    (f : α → ℝ) (g : β → ℝ) :
    (s ×ˢ t).inf' (hs.product ht) (fun p => f p.1 + g p.2) ≤
    s.inf' hs f + t.inf' ht g := by ...
```

**Proof Strategy**: Choose the pair `(a*, b*)` realizing `inf' s f` and `inf' t g` respectively. Then `f a* + g b*` is an element of the product sum, so the product infimum is at most `f a* + g b* = inf' s f + inf' t g`.

**Cross-Domain Bridge**: This is the composition law for enriched categories with tropical hom-objects. It formalizes the principle that composing two optimally-chosen proof steps costs at most the sum of optimal individual costs—the semantic backbone of cut-elimination cost analysis and Lawvere metric composition.

---

## 3. Entropy-Free Information Measure via Tropical Rank

**Theorem Statement**: Define the tropical rank of a finite cost function as the cardinality of its level set at the minimum. Prove that this rank is monotone under restriction and multiplicative under products.

**Lean Type Signature**:
```lean
noncomputable def tropicalRank {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → ℝ) : ℕ :=
  Finset.card (Finset.univ.filter (fun a => f a = Finset.univ.inf' Finset.univ_nonempty f))

theorem tropicalRank_le_card {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → ℝ) : tropicalRank f ≤ Fintype.card α := by ...

theorem tropicalRank_pos {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → ℝ) : 0 < tropicalRank f := by ...
```

**Proof Strategy**: The rank is the cardinality of a filter of the universe, so it is at most `Fintype.card α`. Positivity follows from existence of a minimizer (`exists_minimizer_fintype`), which guarantees the filter is nonempty.

**Cross-Domain Bridge**: Tropical rank is an entropy-free information measure—it counts the "effective dimensionality" of the optimal set without logarithms or probability distributions. This connects to coding theory (number of optimal codewords), cryptography (size of the optimal witness set), and proof complexity (number of shortest proofs).

---

## 4. Certified Argmin Extraction with Decidable Computation

**Theorem Statement**: On `Fin n` with `n > 0`, construct a computable argmin function and prove it returns the global minimizer.

**Lean Type Signature**:
```lean
def argmin_fin (n : ℕ) (h : 0 < n) (f : Fin n → ℝ) [DecidableLinearOrder ℝ] : Fin n :=
  Finset.univ.argmin f (by exact Finset.univ_nonempty)

theorem argmin_fin_spec (n : ℕ) (h : 0 < n) (f : Fin n → ℝ) :
    ∀ b : Fin n, f (argmin_fin n h f) ≤ f b := by ...
```

**Proof Strategy**: Use `Finset.argmin` from Mathlib, which returns the element with the minimum value. The specification follows from `Finset.argmin_le`.

**Cross-Domain Bridge**: This is the computational bridge—extracting actual witnesses from existence proofs. It enables certified proof search (return the actual shortest proof), verified cryptographic optimization (return the actual best key), and executable tropical dynamic programming with correctness guarantees.

---

## 5. Tropical Bellman Equation for Proof-Search DAGs

**Theorem Statement**: On a directed acyclic graph with `Fin n` vertices and real-valued edge costs, the optimal path cost satisfies the Bellman equation: `opt(v) = min_{u→v} (opt(u) + cost(u,v))` for non-source vertices.

**Lean Type Signature**:
```lean
structure CostDAG (n : ℕ) where
  adj : Fin n → Fin n → Prop
  cost : (i j : Fin n) → adj i j → ℝ
  acyclic : ∀ (path : List (Fin n)), path.Chain' (fun i j => adj i j) →
    path.Nodup

noncomputable def optCost (n : ℕ) (G : CostDAG n) (source target : Fin n) : WithTop ℝ :=
  sorry -- infimum over all source-to-target paths

theorem bellman_equation (n : ℕ) (hn : 0 < n) (G : CostDAG n)
    (source v : Fin n) (hv : v ≠ source)
    (h_reachable : optCost n G source v ≠ ⊤) :
    optCost n G source v =
    Finset.inf' (Finset.univ.filter (fun u => G.adj u v))
      (by sorry) -- nonemptiness of predecessors
      (fun u => optCost n G source u + G.cost u v (by sorry)) := by ...
```

**Proof Strategy**: By induction on the topological order of the DAG. At each non-source vertex, the optimal path must pass through some predecessor, reducing to the Bellman recursion. The tropical infimum over predecessors selects the best incoming edge.

**Cross-Domain Bridge**: This is the master theorem for tropical dynamic programming applied to proof search. Interpreting vertices as partial proof states and edges as inference steps, the Bellman equation becomes the optimality principle for proof construction. In cryptography, it models optimal multi-step verification strategies. This theorem would unify the entire tropical optimization layer with graph-based computation models.

---

## Research Program Summary

These five directions form a coherent research program:

1. **Matrix multiplication** → algebraic infrastructure for multi-step costs
2. **Subadditivity** → composition law for enriched categories
3. **Tropical rank** → entropy-free information measure
4. **Certified argmin** → computational extraction of witnesses
5. **Bellman equation** → dynamic programming for proof/crypto search

Together, they would establish a complete certified toolkit for tropical optimization over finite structures, with applications spanning proof theory, coding theory, cryptography, and operator algebra. Each theorem is independently valuable and machine-verifiable, creating a growing library of cross-domain bridge infrastructure.
