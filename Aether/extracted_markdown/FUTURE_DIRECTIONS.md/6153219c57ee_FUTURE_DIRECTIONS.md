# Future Directions: Tropical Factor Rank

This document outlines five concrete research directions opened by the formalization of tropical factor rank as a certified complexity invariant. Each direction includes a precise theorem statement, a proof strategy sketch, and cross-domain connections.

---

## 1. Rank Comparison Theorem: Tropical Rank vs. Factor Rank

### Conjecture

For any tropical matrix $M$ over $\text{WithTop}\ \mathbb{Z}$, the classical tropical rank (Barvinok rank, defined as the minimum number of terms in a tropical linear combination of rows needed to span all rows) satisfies:

$$\text{tropRank}(M) \leq \text{tropFactorRank}(M)$$

The converse does **not** hold in general: there exist matrices where the tropical rank is strictly smaller than the factor rank.

### Proposed Lean Statement

```lean
theorem tropRank_le_tropFactorRank {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropRank M ≤ tropFactorRank M
```

### Proof Strategy

1. **Define tropical rank** as the minimum number of tropical rank-1 matrices whose tropical row span contains all rows of M. This is a weaker condition than decomposition (it only requires row containment, not entrywise equality).
2. **Show that any factor rank decomposition induces a row span.** If $M_{ij} = \min_k (U_k(i) + V_k(j))$, then each row of M is tropically dominated by the rank-1 rows $\{V_k\}$, shifted by $\{U_k(i)\}$.
3. **Construct a counterexample** for the reverse inequality: the identity-like matrix $M_{ij} = 0$ if $i=j$, $\infty$ otherwise has tropical rank 1 (it's already in echelon form) but factor rank $n$.

### Cross-Domain Connections

- **Communication complexity**: tropical rank is analogous to the log of the communication complexity of a Boolean matrix; factor rank bounds the extension complexity. The gap between them mirrors the gap between nondeterministic and deterministic communication.
- **Optimization**: In linear programming over the tropical semiring, the rank controls the dimension of the feasible region, while factor rank controls the size of an extended formulation.

---

## 2. Subadditivity and Composition Under Tropical Matrix Product

### Conjecture

For tropical matrix multiplication $C = A \otimes B$ (where $(A \otimes B)_{ij} = \min_k (A_{ik} + B_{kj})$):

$$\text{tropFactorRank}(A \otimes B) \leq \text{tropFactorRank}(A) \cdot \text{tropFactorRank}(B)$$

### Proposed Lean Statement

```lean
theorem tropFactorRank_submultiplicative {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℤ))
    (B : Matrix (Fin n) (Fin p) (WithTop ℤ)) :
    tropFactorRank (tropMatMul A B) ≤ tropFactorRank A * tropFactorRank B
```

### Proof Strategy

1. If $A = \min_s (U^A_s \otimes V^{A\top}_s)$ with $r_A$ summands, and similarly for $B$ with $r_B$ summands, then:

$$C_{ij} = \min_k \min_s \min_t (U^A_s(i) + V^A_s(k) + U^B_t(k) + V^B_t(j))$$

2. For each pair $(s,t)$, the inner minimization over $k$ produces a quantity $W_{st}(i) + Z_{st}(j)$ where $W_{st}(i) = U^A_s(i)$ and $Z_{st}(j) = \min_k(V^A_s(k) + U^B_t(k)) + V^B_t(j)$.

3. The key lemma: $\min_k(V^A_s(k) + U^B_t(k))$ is a scalar for fixed $(s,t)$, absorbing into $Z_{st}$.

4. This yields $r_A \cdot r_B$ rank-1 summands.

### Cross-Domain Connections

- **Deep network expressivity**: In a depth-$L$ tropical network, each layer performs a tropical matrix-vector product. Submultiplicativity implies the factor rank of the composed map grows at most exponentially in depth: $\text{tropFactorRank}(A_L \otimes \cdots \otimes A_1) \leq \prod_{l=1}^L \text{tropFactorRank}(A_l)$.
- **Circuit complexity**: This mirrors the multiplicative depth-width tradeoff in Boolean circuits.

---

## 3. Tropical CP-Rank for 3-Tensors

### Definition and Conjecture

Extend tropical factor rank to 3-tensors: a tensor $T : \text{Fin}\ l \times \text{Fin}\ m \times \text{Fin}\ n \to \text{WithTop}\ \mathbb{Z}$ has **tropical CP-rank** $r$ if:

$$T(i, j, k) = \min_{t=1}^{r} (u_t(i) + v_t(j) + w_t(k))$$

**Conjecture**: $\text{tropCPRank}(T) \leq l \cdot m$ (or $\min(lm, ln, mn)$).

### Proposed Lean Statement

```lean
def TropCPDecomp {l m n : ℕ} (r : ℕ) (T : Fin l → Fin m → Fin n → WithTop ℤ) : Prop :=
  ∃ U : Fin r → Fin l → WithTop ℤ,
    ∃ V : Fin r → Fin m → WithTop ℤ,
      ∃ W : Fin r → Fin n → WithTop ℤ,
        ∀ i j k, T i j k = ⨅ t : Fin r, (U t i + V t j + W t k)

theorem tropCPRank_le {l m n : ℕ}
    (T : Fin l → Fin m → Fin n → WithTop ℤ) :
    ∃ r, r ≤ l * m ∧ TropCPDecomp r T
```

### Proof Strategy

1. Flatten the first two indices: view T as an $(l \cdot m) \times n$ matrix.
2. Apply the column decomposition to get factor rank $\leq n$.
3. Each summand has the form $U_k(i,j) + V_k(\ell)$. Factor $U_k(i,j)$ further if possible.
4. The naive bound is $\min(lm, ln, mn)$; sharper bounds require structural assumptions.

### Cross-Domain Connections

- **Tensor compilation**: The `tensor_rank_bound` in the catalog gives $d^L$ for classical tensor rank. Tropical CP-rank provides the min-plus analogue, directly measuring the number of separable min-plus templates in a compiled tensor network.
- **Quantum information**: Tropical tensor rank appears in the study of entanglement witnesses and max-entropy optimization.

---

## 4. Attention Expressivity: Factor Rank Bounds for Tropicalized Transformers

### Conjecture

For a tropicalized multi-head attention mechanism with $h$ heads, each of key dimension $d_k$, the tropical attention matrix $A$ satisfies:

$$\text{tropFactorRank}(A) \leq h \cdot d_k$$

For a single head: $\text{tropFactorRank}(A_{\text{head}}) \leq d_k$.

### Proposed Lean Statement

```lean
theorem single_head_attention_factor_rank {n dk : ℕ}
    (Q K : Matrix (Fin n) (Fin dk) (WithTop ℤ)) :
    tropFactorRank (fun i j => ⨅ l : Fin dk, (Q i l + K j l)) ≤ dk

theorem multi_head_attention_factor_rank {n dk h : ℕ}
    (heads : Fin h → Matrix (Fin n) (Fin n) (WithTop ℤ))
    (h_head_bound : ∀ k, tropFactorRank (heads k) ≤ dk) :
    tropFactorRank (fun i j => ⨅ k : Fin h, heads k i j) ≤ h * dk
```

### Proof Strategy

1. **Single head**: The attention matrix $A_{ij} = \min_l (Q_{il} + K_{jl})$ is already a tropical rank-$d_k$ decomposition with $U_l(i) = Q_{il}$ and $V_l(j) = K_{jl}$.
2. **Multi-head**: By subadditivity, the tropical sum (min) of $h$ heads each of factor rank $\leq d_k$ has factor rank $\leq h \cdot d_k$.
3. **Tightness**: Construct examples achieving the bound using random queries/keys.

### Cross-Domain Connections

- **Low-rank transformers**: Factor rank provides a formal measure of attention "compression" — low factor rank means the attention pattern is representable with few separable templates, justifying low-rank approximation methods like Linformer and Performer.
- **Interpretability**: Each rank-1 summand $u(i) + v(j)$ in the decomposition represents a "pure attention template" that independently ranks tokens. Factor rank counts the minimum number of such templates.

---

## 5. Extension Complexity and Communication Complexity

### Conjecture

The tropical factor rank of a distance/cost matrix provides lower bounds on the extension complexity of the corresponding tropical polytope:

$$\text{ext}(P_M) \geq \text{tropFactorRank}(M)$$

where $P_M$ is the tropical polytope generated by the columns of $M$.

### Proposed Lean Statement

```lean
-- This requires defining tropical polytopes and extension complexity
-- Preliminary formalization target:

theorem tropFactorRank_lower_bound_comm_complexity {n : ℕ}
    (M : Matrix (Fin n) (Fin n) (WithTop ℤ))
    (h : ∀ r, TropDecompOfRank r M → r ≥ k) :
    tropFactorRank M ≥ k
```

### Proof Strategy

1. **Define tropical polytopes** as the tropical convex hull of a set of points in $(\text{WithTop}\ \mathbb{Z})^n$.
2. **Show that a factor rank-$r$ decomposition induces an extended formulation** of the tropical polytope with $r$ facets.
3. **Prove Yannakakis-type theorems**: the minimum number of facets in an extended formulation equals the nonneg rank, which for tropical polytopes equals the factor rank.

### Cross-Domain Connections

- **Optimization**: Lower bounds on tropical factor rank imply lower bounds on the size of min-plus linear programs, ruling out efficient formulations for certain combinatorial optimization problems.
- **Communication complexity**: In the min-plus communication model, the factor rank of the communication matrix characterizes the deterministic communication complexity of evaluating the matrix.
- **Cryptography**: Hard instances of tropical factor rank computation could provide the basis for cryptographic constructions, connecting to the tropical trapdoor and hardness results already in the catalog.

---

## Implementation Priority

| Direction | Difficulty | Impact | Recommended Order |
|-----------|-----------|--------|-------------------|
| 1. Rank comparison | Medium | High | First — validates the invariant |
| 4. Attention expressivity | Medium | Very High | Second — immediate ML application |
| 2. Submultiplicativity | Hard | High | Third — enables depth analysis |
| 3. Tensor CP-rank | Medium | High | Fourth — natural generalization |
| 5. Extension complexity | Very Hard | Revolutionary | Fifth — requires substantial infrastructure |

Each direction is designed to be independently pursuable, with clear hypotheses and falsifiable predictions. The team should begin with Direction 1 to validate the rank comparison, then move to Direction 4 for the highest-impact application connection.
