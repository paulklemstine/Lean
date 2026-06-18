# Future Directions: Tropical Surgery Calculus for Shortest Paths

This document outlines concrete next steps building on the formalized **tropical Sherman–Morrison theorem** (`kleene_star_single_edge_update`), which gives an exact rank-one update formula for all-pairs shortest path (APSP) closures under single-edge insertion in the min-plus semiring.

---

## 1. Rank-One Tropical Woodbury Theorem

**Statement.** Let `A` be a weighted adjacency matrix over `ENNReal`, with APSP closure `S`. Let `p, q : Fin n → ENNReal` define a rank-one tropical perturbation:

```
A'(i,j) = min( A(i,j),  p(i) + q(j) )
```

Then the new APSP closure is:

```
S'(i,j) = min( S(i,j),  (⨅ₖ S(i,k) + p(k)) + (⨅ₖ q(k) + S(k,j)) )
```

**Strategy.** The single-edge theorem is the special case where `p` and `q` are indicator functions. The general proof follows the same four-condition structure:
1. *Adjacency bound*: by construction.
2. *Diagonal*: trivial from `S(i,i) = 0`.
3. *Triangle inequality*: use the same `min_le_min_add_min` technique; the key new ingredient is `iInf_le_iInf` for the tropical matrix-vector products.
4. *Minimality*: by the same argument—any closure for `A'` is also a closure for `A`, so `S ≤ T` by minimality, hence `min(S, ...) ≤ T`.

**Cross-domain impact.** This generalizes from single-edge surgery to arbitrary rank-one tropical perturbations, enabling certified analysis of batch edge insertions, hub additions, and tropical control updates.

---

## 2. Vertex Surgery / Tropical Schur Complement

**Statement.** Consider an `(n+1)`-vertex graph with adjacency matrix partitioned as:

```
        ┌       ┐
  B  =  │ A   p │
        │ qᵀ  0 │
        └       ┘
```

where `A` is the `n×n` submatrix, `p : Fin n → ENNReal` are edge weights from the new vertex to existing ones, and `q` from existing to new. Then the `n×n` block of the APSP closure of `B` satisfies:

```
S_B(i,j) = min( S_A(i,j),  (S_A · p)(i) + (q · S_A)(j) )
```

where `(S_A · p)(i) = ⨅ₖ S_A(i,k) + p(k)` is the tropical matrix-vector product.

**Strategy.** Reduce to the rank-one update theorem by showing that the `n×n` block of the closure of `B` equals the closure of `rankOneUpdate A p q`. This requires formalizing the block structure of tropical matrix closure.

**Impact.** Enables certified incremental graph algorithms where vertices (not just edges) are added dynamically—essential for network growth models and online routing.

---

## 3. Order-Independence of Disjoint Edge Surgeries

**Statement.** Let edges `(u₁, v₁, w₁)` and `(u₂, v₂, w₂)` be "independent" in the sense that neither creates a shortcut through the other's endpoints. Formally, if:

```
S(v₁, u₂) + w₂ + S(v₂, u₁) + w₁ ≥ 0    (automatic in ENNReal)
```

then the closure after both insertions is independent of insertion order:

```
APSP(edgeUpdate (edgeUpdate A u₁ v₁ w₁) u₂ v₂ w₂)
  = APSP(edgeUpdate (edgeUpdate A u₂ v₂ w₂) u₁ v₁ w₁)
```

**Strategy.** Apply the single-edge formula twice in each order and show equality. In `ENNReal`, this becomes a min-of-mins identity that should follow from associativity, commutativity, and the triangle inequality of `S`.

**Impact.** Enables parallelization of edge insertions in certified dynamic graph algorithms—multiple independent updates can be applied in any order.

---

## 4. Boolean Transitive Closure as Tropical Specialization

**Statement.** Encode boolean reachability in `ENNReal` via `0 = reachable, ⊤ = unreachable`. Then the APSP closure specializes to transitive closure, and the edge update theorem yields:

```
TC(R ∪ {(u,v)})(i,j) = TC(R)(i,j) ∨ (TC(R)(i,u) ∧ TC(R)(v,j))
```

**Strategy.** Define a coercion `Bool → ENNReal` with `true ↦ 0, false ↦ ⊤`, show it preserves the closure structure, and derive the boolean formula as a corollary of `kleene_star_single_edge_update`.

**Impact.** Connects the weighted theory to classical graph reachability and automata theory. The boolean specialization is the standard formula for incremental transitive closure maintenance.

---

## 5. Certified Dynamic APSP Algorithm with O(n²) Updates

**Statement.** Extract from `kleene_star_single_edge_update` an executable algorithm:

```python
def update_apsp(S, u, v, w):
    for i in range(n):
        for j in range(n):
            S[i][j] = min(S[i][j], S[i][u] + w + S[v][j])
    return S
```

Prove that this algorithm correctly computes the new APSP closure in `O(n²)` time, compared to `O(n³)` for full recomputation.

**Strategy.**
1. Define the algorithm as a `Fin n × Fin n → ENNReal` function in Lean.
2. Show equivalence with the mathematical formula `fun i j ↦ min (S i j) (S i u + w + S v j)`.
3. Derive correctness from `kleene_star_single_edge_update`.
4. Use `@[csimp]` for kernel-verified efficient implementation.

**Impact.** Produces a formally verified dynamic APSP update routine that could be extracted to executable code—a first for proof assistants in the dynamic algorithms space.

---

## 6. Parametric Sensitivity / Lipschitz Monotonicity

**Statement.** If the weight of the new edge changes from `w₁` to `w₂` with `w₁ ≤ w₂`, then the APSP closures satisfy:

```
∀ i j, S'_{w₁}(i,j) ≤ S'_{w₂}(i,j)
```

and the entrywise difference is bounded:

```
S'_{w₂}(i,j) - S'_{w₁}(i,j) ≤ w₂ - w₁    (when both are finite)
```

**Strategy.** Direct from the explicit formula: `min(S i j, S i u + w + S v j)` is monotone in `w` and 1-Lipschitz in `w` for each entry.

**Impact.** Certified sensitivity analysis for network perturbations—how much can shortest paths change when an edge weight is modified?

---

## 7. Multi-Edge Batch Surgery via Iterated Updates

**Statement.** Given a batch of `m` edge insertions `{(uₖ, vₖ, wₖ)}`, the APSP closure after all insertions can be computed by iterating the single-edge formula:

```
S⁽⁰⁾ = S,   S⁽ᵏ⁺¹⁾(i,j) = min( S⁽ᵏ⁾(i,j),  S⁽ᵏ⁾(i,uₖ) + wₖ + S⁽ᵏ⁾(vₖ,j) )
```

with total cost `O(mn²)` instead of `O(n³)` when `m ≪ n`.

**Strategy.** Induction on `m`, using `kleene_star_single_edge_update` at each step with the intermediate closure as the base.

**Impact.** Extends the single-edge result to sparse batch updates, the most common scenario in dynamic graph algorithms.

---

## Summary Table

| # | Direction | Difficulty | Key New Ingredient | Impact |
|---|-----------|------------|-------------------|--------|
| 1 | Rank-one Woodbury | Medium | `iInf` manipulation | General tropical perturbation |
| 2 | Vertex surgery | Medium-Hard | Block matrix closure | Dynamic vertex insertion |
| 3 | Order independence | Easy-Medium | Min-of-mins identity | Parallel updates |
| 4 | Boolean bridge | Easy | Type coercion | Automata connection |
| 5 | Certified algorithm | Medium | Code extraction | Verified software |
| 6 | Sensitivity | Easy | Monotonicity of min | Network analysis |
| 7 | Batch surgery | Easy | Induction | Practical algorithms |

Each direction builds directly on the infrastructure in `KleeneStarUpdate.lean` and requires no fundamentally new mathematical machinery—only compositional extension of the established proof patterns.
