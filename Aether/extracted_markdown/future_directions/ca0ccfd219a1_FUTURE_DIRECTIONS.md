# Future Directions: Charge-Reversal Symmetry in Tropical Geometry

## Direction 1: Charge-Reversal Spectral Theorem for Tropical Eigencones

### Statement
Prove that the tropical eigencones of `chargedWeight(W, A, q)` and `chargedWeight(W, A, -q)` correspond under transpose, when W is symmetric.

### Lean Type Signature
```lean
theorem tropicalEigencone_charge_reversal
    {n : ℕ} (W A : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (q λ : ℝ)
    (hW : W.IsSymm) (v : Fin (n+1) → ℝ)
    (hv : ∀ i, Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩
      (fun j => chargedWeight W A q i j + v j) = λ + v i) :
    ∀ i, Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩
      (fun j => chargedWeight W A (-q) j i + v i) = λ + v i
```

### Proof Strategy
1. Use `chargedWeight_symm_neg_eq_transpose` to rewrite the negated-charge eigenvector equation.
2. Show that if v is a tropical eigenvector of M, then the same v (or a permuted version) is related to a tropical eigenvector of Mᵀ.
3. The eigenvalue λ is preserved because it depends only on critical cycle means, which involve diagonal entries (charge-independent by `chargedWeight_diag`).

### Cross-Domain Significance
- **Spectral theory**: Tropical eigenvalues govern asymptotic growth of iterated matrix products (max-plus dynamics).
- **Dynamical systems**: Charge-reversal spectral invariance implies time-reversal symmetry of tropical dynamical systems.
- **Optimization**: Tropical eigenvectors solve steady-state equations in scheduling and resource allocation.

---

## Direction 2: Charge-Reversal Geodesic Theorem

### Statement
In a charged tropical graph, shortest paths (geodesics) at charge q correspond to reversed shortest paths at charge -q. Formally, if π = (i₀, i₁, ..., iₖ) is a geodesic in the charged weight at charge q, then the reversed path π̄ = (iₖ, ..., i₁, i₀) is a geodesic in the charged weight at charge -q.

### Lean Type Signature
```lean
def tropPathWeight {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ)
    (path : List (Fin n)) : ℝ := sorry -- sum of edge weights along path

theorem geodesic_charge_reversal
    {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ)
    (hW : W.IsSymm) (path : List (Fin n)) :
    tropPathWeight (chargedWeight W A q) path =
    tropPathWeight (chargedWeight W A (-q)) path.reverse
```

### Proof Strategy
1. Define path weight as the sum of edge weights along consecutive pairs.
2. Use `chargedWeight_reverse_edges` to show each edge weight reverses under charge negation + index swap.
3. The reverse path traverses the same edges in opposite order, picking up the charge-reversed weights.

### Cross-Domain Significance
- **Routing algorithms**: Bidirectional Dijkstra can exploit charge duality—search forward at charge q and backward at charge -q.
- **Network flow**: Max-flow/min-cut duality in directed networks may connect to charge-reversal.
- **Statistical mechanics**: Path integrals in tropical statistical mechanics would inherit time-reversal symmetry.

---

## Direction 3: Categorified Charge-Reversal Functor

### Statement
Define a category **ChTropMat** of charged tropical matrices (objects: triples (W, A, q); morphisms: structure-preserving maps) and prove that the operation (W, A, q) ↦ (W, A, -q) with transpose on morphisms defines a contravariant involutive endofunctor.

### Lean Type Signature
```lean
structure ChargedTropicalMatrix (n : ℕ) where
  W : Matrix (Fin n) (Fin n) ℝ
  A : Matrix (Fin n) (Fin n) ℝ
  q : ℝ
  hW : W.IsSymm

def chargeReversalFunctor {n : ℕ} (M : ChargedTropicalMatrix n) :
    ChargedTropicalMatrix n where
  W := M.W
  A := M.A
  q := -M.q
  hW := M.hW

theorem chargeReversal_involutive {n : ℕ} (M : ChargedTropicalMatrix n) :
    chargeReversalFunctor (chargeReversalFunctor M) = M
```

### Proof Strategy
1. Define the category using Mathlib's category theory library.
2. The functor sends objects to their charge-reversal and morphisms to their transpose.
3. Involutivity follows from `chargedWeight_neg_neg`.
4. Contravariance follows from the transpose reversing composition order.

### Cross-Domain Significance
- **Category theory**: First example of a charge-conjugation functor in tropical algebraic geometry.
- **Homological algebra**: Could lead to tropical analogues of duality in derived categories.
- **Theoretical physics**: Mirrors the CPT functor in axiomatic quantum field theory.

---

## Direction 4: Tropical Noether Conservation Principle

### Statement
The charge-reversal symmetry implies the existence of a conserved "tropical Noether charge"—a functional on charged tropical matrices that is invariant under the charge-reversal involution. Candidates include:

1. The tropical trace: `Σᵢ M(i,i)` (already proven invariant)
2. The tropical permanent: `max_σ Σᵢ M(i, σ(i))`
3. Tropical cycle means weighted by charge

### Lean Type Signature
```lean
def tropicalTrace {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.sum Finset.univ (fun i => M i i)

theorem tropicalTrace_charge_invariant
    {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) :
    tropicalTrace (chargedWeight W A q) = tropicalTrace W

theorem tropicalPermanent_charge_reversal
    {n : ℕ} (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) (hW : W.IsSymm) :
    tropicalPermanent (chargedWeight W A q) =
    tropicalPermanent (chargedWeight W A (-q))
```

### Proof Strategy
1. The trace result follows immediately from `chargedWeight_diag`.
2. For the permanent, use the fact that the permanent of Mᵀ equals the permanent of M, combined with `chargedWeight_symm_neg_eq_transpose`.
3. Explore whether the tropical determinant (max over even permutations minus max over odd permutations) has similar invariance.

### Cross-Domain Significance
- **Physics**: Noether's theorem is the cornerstone of conservation laws. A tropical analogue would establish a new bridge between combinatorial optimization and physical symmetry principles.
- **Combinatorics**: Conservation of the tropical permanent under charge reversal would yield new results on optimal assignments in asymmetric bipartite graphs.
- **Information theory**: Conserved quantities may relate to capacity of asymmetric communication channels.

---

## Direction 5: Optimization Duality via Charge Reversal

### Statement
In tropical linear programming, the primal problem `min_x max_j (A·x)_j` and dual problem `max_y min_i (yᵀ·A)_i` are connected by transpose. Charge reversal provides a continuous deformation between primal and dual, potentially yielding interior-point-like algorithms for tropical optimization.

### Lean Type Signature
```lean
def tropicalPrimalValue {n : ℕ}
    (M : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ univ_nonempty
    (fun i => Finset.sup' Finset.univ univ_nonempty (fun j => M i j + x j))

theorem primal_dual_charge_reversal
    {n : ℕ} (W A : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (q : ℝ)
    (hW : W.IsSymm) (x : Fin (n+1) → ℝ) :
    tropicalPrimalValue (chargedWeight W A q) x =
    tropicalDualValue (chargedWeight W A (-q)) x
```

### Proof Strategy
1. Define primal and dual tropical optimization values.
2. Show that the dual value of M equals the primal value of Mᵀ (by definition, swapping max-over-rows and max-over-columns).
3. Apply `chargedWeight_symm_neg_eq_transpose` to connect the charge-reversed matrix to the transpose.

### Cross-Domain Significance
- **Operations research**: New algorithms for tropical assignment, scheduling, and shortest path problems via charge-parameterized duality.
- **Machine learning**: Tropical optimization appears in training piecewise-linear neural networks; charge duality could provide new training algorithms.
- **Economics**: Tropical geometry models auction mechanisms and matching markets; charge reversal corresponds to buyer-seller duality.

---

## Implementation Roadmap

| Priority | Direction | Estimated Effort | Dependencies |
|----------|-----------|-----------------|--------------|
| High | Direction 4 (Noether) | 2-3 days | Current results |
| High | Direction 2 (Geodesics) | 3-5 days | Path weight definition |
| Medium | Direction 5 (Optimization) | 3-5 days | Tropical LP definitions |
| Medium | Direction 1 (Eigencones) | 5-7 days | Tropical eigenvalue theory |
| Low | Direction 3 (Category) | 5-10 days | Mathlib CategoryTheory |

## Team Directive

Each direction should be pursued by defining the necessary infrastructure (definitions, helper lemmas) first, verifying them computationally, then invoking automated proof search. The charge-reversal results proven here provide the algebraic foundation; the challenge is connecting them to combinatorial and geometric structures.

**Hypothesis testing protocol:**
1. State the conjecture as a precise Lean theorem.
2. Test with numerical examples (n = 2, 3, 4) using Python.
3. Check edge cases (q = 0, symmetric A, diagonal matrices).
4. Decompose into helper lemmas and prove bottom-up.
5. If stuck, try the contrapositive or a weaker version.
