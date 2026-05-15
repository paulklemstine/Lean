# A Machine-Verified Tropical Collatz–Wielandt Theorem

## Abstract

We present a complete formal proof of the tropical Collatz–Wielandt variational principle: for any real matrix $W$ of size $n \times n$, the tropical spectral radius $\rho(W)$ (maximum cycle mean) characterizes subeigenvalue feasibility via the equivalence $\exists x,\, \forall i,\, \max_j(W_{ij} + x_j) \leq x_i + \lambda \iff \rho(W) \leq \lambda$. The proof is formalized in approximately 420 lines of Lean 4 with the Mathlib library, uses only standard axioms (propext, Classical.choice, Quot.sound), and requires no sorry placeholders. We develop reusable infrastructure including walk weight decomposition, a cyclic telescoping identity, and a pigeonhole-based walk shortening lemma. We also provide Python implementations of Karp's algorithm and the Bellman–Ford potential construction, with applications to scheduling, circuit timing, and manufacturing throughput analysis.

## 1. Introduction

The tropical (max-plus) semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$ provides a natural framework for optimization problems involving bottlenecks, synchronization, and worst-case analysis. In this setting, the analogue of matrix-vector multiplication is

$$(W \otimes x)_i = \max_j(W_{ij} + x_j)$$

and the spectral theory of such operations governs the asymptotic behavior of discrete-event systems, mean-payoff games, and difference constraint systems.

The classical Collatz–Wielandt theorem characterizes the Perron–Frobenius eigenvalue of a non-negative matrix through a variational principle. Its tropical analogue states that the tropical spectral radius—the maximum cycle mean—equals the infimum of values $\lambda$ for which a "subeigenvector" exists. This result is fundamental to tropical linear algebra but has not previously been formalized in a proof assistant.

### 1.1 Contributions

1. **Complete formal proof** of the tropical Collatz–Wielandt equivalence in Lean 4/Mathlib.
2. **Reusable walk decomposition infrastructure** including `walkWt_split`, `walkVert_shift`, and `walkWt_concat`.
3. **Constructive potential construction** via Bellman–Ford-style iteration with formal correctness guarantee.
4. **Python implementations** with O(n³) algorithms and real-world applications.

## 2. Definitions and Notation

### 2.1 Tropical Matrix-Vector Product

For $W : \text{Matrix}(\text{Fin}\, n)(\text{Fin}\, n)\, \mathbb{R}$ and $x : \text{Fin}\, n \to \mathbb{R}$:

$$(\text{tropMul}\, W\, x)_i = \sup'\{\, W_{ij} + x_j \mid j \in \text{Fin}\, n\,\}$$

### 2.2 Subeigenvectors

A vector $x$ is a **subeigenvector** of $W$ with value $\lambda$ if $\forall i,\, (\text{tropMul}\, W\, x)_i \leq x_i + \lambda$.

**Edgewise characterization** (Theorem `isSubeig_iff`): This is equivalent to $\forall i\, j,\, W_{ij} + x_j \leq x_i + \lambda$.

### 2.3 Cycles and Cycle Mean

A cycle of length $k \geq 1$ is a function $c : \text{Fin}\, k \to \text{Fin}\, n$. Its weight is

$$\text{cycleWt}(W, c) = \sum_{t=0}^{k-1} W_{c(t),\, c((t+1) \bmod k)}$$

and its mean is $\text{cycleWt} / k$.

### 2.4 Tropical Spectral Radius

$$\rho(W) = \max_{k=1}^{n}\, \max_{c : \text{Fin}\, k \to \text{Fin}\, n}\, \frac{\text{cycleWt}(W, c)}{k}$$

## 3. Main Results

### 3.1 Easy Direction: HasSubeig → ρ ≤ λ

**Theorem** (`easy_direction`). If there exists $x$ with $\forall i\, j,\, W_{ij} + x_j \leq x_i + \lambda$, then $\rho(W) \leq \lambda$.

*Proof sketch.* For any cycle $c$ of length $k$, sum the edge inequalities:
$$\sum_{t} W_{c(t), c(t+1)} \leq \sum_{t} (x_{c(t)} + \lambda - x_{c(t+1)}) = k\lambda$$
where the telescoping identity $\sum_t (x_{c(t)} - x_{c(t+1 \bmod k)}) = 0$ eliminates the $x$-terms. Divide by $k$.

**Key lemma** (`cycleSucc_sum_zero`): The cyclic successor map $t \mapsto (t+1) \bmod k$ is a permutation of $\text{Fin}\, k$, so $\sum f(t) = \sum f(t+1 \bmod k)$.

### 3.2 Hard Direction: ρ ≤ λ → HasSubeig

**Theorem** (`hard_direction`). If $\rho(W) \leq \lambda$, there exists $x$ with $\forall i\, j,\, W_{ij} + x_j \leq x_i + \lambda$.

*Proof sketch.* Define $A_{ij} = W_{ij} - \lambda$. Then all cycles in $A$ have non-positive total weight. The construction proceeds in three stages:

**Stage 1: Walk weight infrastructure.** Define `walkWt A i m f` as the weight of a walk of length $m$ from vertex $i$ following steps $f : \text{Fin}\, m \to \text{Fin}\, n$. Prove additivity under splitting (`walkWt_split`) and concatenation (`walkWt_concat`).

**Stage 2: Walk shortening (pigeonhole).** For any walk of length $n$ from $i$, the $n+1$ vertices visited lie in $\text{Fin}\, n$, so by the pigeonhole principle, two positions $a < b$ share the same vertex. The segment from $a$ to $b$ forms a cycle with non-positive weight. Removing it yields a walk of length $n - (b-a) < n$ with weight at least as large. (Theorem `walk_shorten`.)

**Stage 3: Potential construction.** Define $x_i = \max_{m=0}^{n-1} \text{bestWalk}(A, i, m)$. By walk shortening, $\text{bestWalk}(A, i, n) \leq x_i$. For any edge $(i,j)$:

$$A_{ij} + x_j = A_{ij} + \max_{m<n} \text{bestWalk}(A, j, m)$$

For $m < n-1$: $A_{ij} + \text{bestWalk}(A,j,m) \leq \text{bestWalk}(A,i,m+1) \leq x_i$.
For $m = n-1$: $A_{ij} + \text{bestWalk}(A,j,n-1) \leq \text{bestWalk}(A,i,n) \leq x_i$.

### 3.3 Main Theorem

**Theorem** (`tropical_collatz_wielandt`).
$$\text{HasSubeig}(W, \lambda) \iff \rho(W) \leq \lambda$$

**Corollary** (`tropSpec_eq_sInf`).
$$\rho(W) = \inf\{\lambda \mid \text{HasSubeig}(W, \lambda)\}$$

## 4. Algorithms

### 4.1 Karp's Algorithm

Compute $\rho(W)$ in $O(n^3)$ time via the formula:

$$\rho(W) = \max_i \min_{0 \leq k < n} \frac{D_n(i) - D_k(i)}{n - k}$$

where $D_m(i) = \max$ walk weight of length $m$ from $i$.

```
function Karp(W, n):
    D[0][i] = 0 for all i
    for k = 1 to n:
        for i = 0 to n-1:
            D[k][i] = max_j (W[i][j] + D[k-1][j])
    rho = max_i min_{k<n} (D[n][i] - D[k][i]) / (n - k)
    return rho
```

**Complexity:** Time $O(n^3)$, Space $O(n^2)$.

### 4.2 Bellman–Ford Potential Construction

Given $\lambda \geq \rho(W)$, construct $x$ with $(W \otimes x)_i \leq x_i + \lambda$:

```
function BellmanPotential(W, lambda, n):
    A = W - lambda
    best = [0, ..., 0]
    potential = [0, ..., 0]
    for m = 1 to n-1:
        new_best[i] = max_j (A[i][j] + best[j])
        potential = max(potential, new_best)
        best = new_best
    return potential
```

**Complexity:** Time $O(n^3)$, Space $O(n)$.

## 5. Applications

### 5.1 Train Scheduling

A circular train network with transition times $W_{ij}$ has minimum cycle time $\rho(W)$. The potential vector gives optimal departure offsets. For a 4-station network with times ranging from 6 to 30 minutes, we compute $\rho = 14.5$ minutes/train and provide the optimal schedule.

### 5.2 Digital Circuit Timing

Static timing analysis reduces to the subeigenvector problem: clock period $\geq \rho(W)$ where $W_{ij}$ are propagation delays. For a 3-flip-flop circuit, we compute the minimum clock period and verify that faster clocks violate timing constraints.

### 5.3 Manufacturing Throughput

A flexible manufacturing cell with processing times modeled by $W$ has maximum throughput $60/\rho(W)$ parts/hour. Sensitivity analysis identifies bottleneck operations.

## 6. Formalization Details

### 6.1 Proof Structure

| Component | Lines | Key Technique |
|-----------|-------|---------------|
| Definitions | ~60 | Finset.sup', Sigma types |
| Edgewise characterization | ~10 | simp with sup'_le_iff |
| Telescoping sum | ~5 | Equiv.sum_comp |
| Easy direction | ~20 | Finset.sum_le_sum |
| Walk infrastructure | ~80 | Induction on walk length |
| Walk shortening | ~50 | Pigeonhole + walkWt_split |
| Potential construction | ~30 | Finset.sup', bestWalk |
| Hard direction | ~20 | cycleWt_sub, potential_isSubeig |
| Main theorem | ~5 | Direct combination |

### 6.2 Axioms Used

Only standard CIC axioms: `propext`, `Classical.choice`, `Quot.sound`. No `sorry`, `axiom`, or `@[implemented_by]`.

### 6.3 Key Design Decisions

- **Cycles encoded as `Fin k → Fin n`** with modular successor, avoiding dependent list types.
- **Walks encoded as `Fin m → Fin n`** (step function), with recursive weight definition.
- **Spectral radius as Sigma-type maximum**, avoiding universe issues with dependent types.
- **Potential defined via `Finset.sup'`** over walk lengths 0 to n-1.

## 7. Discussion

### 7.1 Comparison with Classical Proofs

The classical proof of the tropical Collatz–Wielandt theorem typically uses shortest-path constructions on general weighted digraphs. Our formalization works with complete graphs (all-pairs weights), which simplifies the graph-theoretic infrastructure but requires the same core argument: pigeonhole-based walk shortening.

### 7.2 Limitations

- The current formalization works with finite-dimensional real matrices. Extension to $\mathbb{R} \cup \{-\infty\}$ (the full tropical semiring) would require `EReal` or `WithBot ℝ`.
- Irreducibility and eigenvector existence are not yet formalized.
- The walk shortening argument, while complete, could be streamlined with better Fin arithmetic automation.

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps including Karp's formula, eigenvector existence, mean-payoff games, and tropical neural operators.

## References

1. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.P. (1992). *Synchronization and Linearity*. Wiley.
2. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
3. Gaubert, S. (1992). *Théorie des systèmes linéaires dans les dioïdes*. PhD thesis, École des Mines de Paris.
4. Karp, R.M. (1978). A characterization of the minimum cycle mean in a digraph. *Discrete Mathematics*, 23(3), 309-311.
5. Cuninghame-Green, R.A. (1979). *Minimax Algebra*. Springer Lecture Notes in Economics and Mathematical Systems.
