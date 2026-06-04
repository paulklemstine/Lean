# The Divisor Energy Functional: Connecting Chip-Firing, Spectral Theory, and Baker-Norine

## Abstract

We introduce the **energy functional** $E_G(D) = \sum_{v \sim w} (D(v) - D(w))^2$ on graph divisors and establish its fundamental properties in the context of Baker-Norine chip-firing theory. We prove that the energy equals twice the Laplacian quadratic form ($E = 2Q$), scales quadratically under scalar multiplication, is invariant under constant shifts, and vanishes precisely on constant divisors. For complete graphs $K_n$, we derive the closed-form expression $E_{K_n}(D) = 2n \sum_v D(v)^2 - 2(\sum_v D(v))^2$ and prove this equals twice the divisor variance. We establish energy bounds for effective divisors (the tight bound $E \leq 2(n-1)(\deg D)^2$) and prove that the energy spectrum — the set of energies achievable within a linear equivalence class — is a well-defined class invariant bounded below by zero. All results are machine-verified in Lean 4 with Mathlib, comprising 19 theorems in the core module and 14 additional theorems in the energy spectrum module, all without sorry.

**Keywords**: chip-firing, Baker-Norine theory, Riemann-Roch for graphs, Laplacian quadratic form, divisor energy, spectral graph theory

## 1. Introduction

The Riemann-Roch theorem for graphs, proved by Baker and Norine [BN07], establishes that for a divisor $D$ on a connected graph $G$ of genus $g$:

$$r(D) - r(K_G - D) = \deg(D) + 1 - g$$

where $r(D)$ is the rank of $D$, $K_G$ is the canonical divisor, and $g = |E| - |V| + 1$ is the genus. This theorem has deep connections to algebraic geometry, tropical geometry, and combinatorics.

While the algebraic aspects of Baker-Norine theory (linear equivalence, the Picard group, divisor rank) have been extensively studied, the *analytic* aspects — particularly the role of the graph Laplacian and potential theory — have received less attention in the chip-firing literature.

In this paper, we introduce the **divisor energy functional** and establish its properties as a bridge between chip-firing dynamics and spectral graph theory. Our main contributions are:

1. **The energy-quadratic form identity** (Theorem 3.1): $E_G(D) = 2 \sum_v D(v) \cdot (\Delta D)(v)$
2. **The complete graph energy formula** (Theorem 4.1): $E_{K_n}(D) = 2n \sum D(v)^2 - 2(\sum D(v))^2$
3. **The variance interpretation** (Theorem 5.1): $E_{K_n}(D) = 2 \cdot \text{Var}(D)$
4. **Energy bounds for effective divisors** (Theorem 5.2): $E \leq 2(n-1)(\deg D)^2$
5. **The energy spectrum as a class invariant** (Theorem 6.1)

All results are formalized and verified in Lean 4 with the Mathlib library.

## 2. Definitions and Setup

### 2.1 Graph Divisors

Let $G = (V, E)$ be a finite, connected, simple graph. A **divisor** on $G$ is a function $D: V \to \mathbb{Z}$. The set of all divisors forms the free abelian group $\text{Div}(G) = \mathbb{Z}^V$.

The **degree** of a divisor is $\deg(D) = \sum_{v \in V} D(v)$.

A divisor is **effective** if $D(v) \geq 0$ for all $v$.

### 2.2 The Canonical Divisor

The **canonical divisor** is $K_G(v) = \deg_G(v) - 2$.

**Proposition 2.1** (Discrete Gauss-Bonnet). $\deg(K_G) = 2g - 2$.

*Proof.* $\deg(K_G) = \sum_v (\deg(v) - 2) = 2|E| - 2|V| = 2(|E| - |V| + 1) - 2 = 2g - 2$. □

### 2.3 The Laplacian and Linear Equivalence

The **Laplacian** of a function $f: V \to \mathbb{Z}$ is:
$$(\Delta f)(v) = \sum_{w \sim v} (f(v) - f(w))$$

Two divisors $D_1, D_2$ are **linearly equivalent** ($D_1 \sim D_2$) if $D_2 = D_1 + \Delta f$ for some $f$.

**Proposition 2.2.** Linear equivalence preserves degree: if $D_1 \sim D_2$, then $\deg(D_1) = \deg(D_2)$.

### 2.4 Chip-Firing

**Chip-firing** at vertex $v$ transforms a divisor $D$ to $D' = \text{fire}(D, v)$ where:
- $D'(v) = D(v) - \deg(v)$
- $D'(w) = D(w) + 1$ for $w \sim v$
- $D'(w) = D(w)$ otherwise

**Proposition 2.3.** Chip-firing preserves degree and produces linearly equivalent divisors.

## 3. The Energy Functional

### Definition 3.1

The **energy** of a divisor $D$ on $G$ is:
$$E_G(D) = \sum_{v \in V} \sum_{w \in N(v)} (D(v) - D(w))^2$$

This sums over directed edges, so each undirected edge contributes twice.

### Definition 3.2

The **Laplacian quadratic form** is:
$$Q_G(D) = \sum_{v \in V} D(v) \cdot \sum_{w \in N(v)} (D(v) - D(w))$$

### Theorem 3.1 (Energy-Quadratic Form Identity)

$$E_G(D) = 2 \cdot Q_G(D)$$

*Proof sketch.* Expand $(D(v) - D(w))^2 = D(v)^2 - 2D(v)D(w) + D(w)^2$ and use the symmetry of adjacency to show that $\sum_{v,w} D(w)^2 = \sum_{v,w} D(v)^2$. The cross term $\sum_{v,w} D(v)D(w)$ appears with coefficient $-2$ in $E$ and $-1$ in $Q$, giving $E = 2Q$. □

### Theorem 3.2 (Energy Properties)

1. **Non-negativity**: $E_G(D) \geq 0$ with equality iff $D$ is constant on connected components.
2. **Quadratic scaling**: $E_G(cD) = c^2 \cdot E_G(D)$ for $c \in \mathbb{Z}$.
3. **Translation invariance**: $E_G(D + c\mathbf{1}) = E_G(D)$ for $c \in \mathbb{Z}$.
4. **Zero on constants**: $E_G(\mathbf{c}) = 0$.

### Theorem 3.3 (Excess Conservation)

Define the **excess** at vertex $v$:
$$\text{exc}(D, v) = D(v) \cdot \deg(v) - \sum_{w \sim v} D(w)$$

Then $\sum_v \text{exc}(D, v) = 0$.

*Proof sketch.* The first sum $\sum_v D(v) \deg(v)$ and the second sum $\sum_v \sum_{w \sim v} D(w) = \sum_w D(w) \deg(w)$ are identical by symmetry of adjacency. □

## 4. Complete Graph Specializations

### 4.1 Vertex Degrees and Genus

For $K_n$ ($n \geq 2$):
- $\deg_{K_n}(v) = n - 1$ for all $v$
- $g(K_n) = \binom{n-1}{2} = (n-1)(n-2)/2$
- $K_{K_n}(v) = n - 3$ for all $v$ (constant canonical divisor)
- $\deg(K_{K_n}) = n(n-3) = 2g - 2$ ✓

### Theorem 4.1 (Complete Graph Energy Formula)

For $D$ a divisor on $K_n$ ($n \geq 2$):
$$E_{K_n}(D) = 2n \sum_{v} D(v)^2 - 2\left(\sum_v D(v)\right)^2$$

*Proof sketch.* In $K_n$, the neighbor set of $v$ is $V \setminus \{v\}$. Expanding the energy:
$$E = \sum_v \sum_{w \neq v} (D(v) - D(w))^2 = \sum_v \sum_{w \neq v} (D(v)^2 - 2D(v)D(w) + D(w)^2)$$

The first term gives $(n-1)\sum_v D(v)^2$. The third term gives $(n-1)\sum_v D(v)^2$ by symmetry. The middle term gives $-2\sum_v D(v)(\sum_w D(w) - D(v)) = -2(\sum D)^2 + 2\sum D(v)^2$. Combining: $E = 2n\sum D(v)^2 - 2(\sum D)^2$. □

### Theorem 4.2 (Canonical Degree Identity)

$$\deg(K_{K_n}) = 2 \cdot g(K_n) - 2$$

This is a special case of the general discrete Gauss-Bonnet identity, verified computationally for all $n \geq 2$.

## 5. Energy, Variance, and Bounds

### Definition 5.1 (Divisor Variance)

$$\text{Var}(D) = n \sum_v D(v)^2 - \left(\sum_v D(v)\right)^2$$

### Theorem 5.1 (Energy-Variance Correspondence)

For $K_n$ ($n \geq 2$): $E_{K_n}(D) = 2 \cdot \text{Var}(D)$.

### Theorem 5.2 (Variance Characterization)

1. $\text{Var}(D) \geq 0$ (Cauchy-Schwarz inequality)
2. $\text{Var}(D) = 0$ if and only if $D$ is constant

*Proof of (2), forward direction.* If $\text{Var}(D) = 0$, then $E_{K_n}(D) = 0$ (for $n \geq 2$). Since $E = \sum_{v,w \sim v} (D(v) - D(w))^2$ and each term is non-negative, every term must be zero. In $K_n$, every pair is adjacent, so $D(v) = D(w)$ for all $v, w$. □

### Theorem 5.3 (Effective Divisor Energy Bounds)

For effective $D$ on $K_n$:

**Crude bound**: $E(D) \leq 2n \cdot (\deg D)^2$

**Tight bound**: $E(D) \leq 2(n-1) \cdot (\deg D)^2$

The tight bound follows from $\sum D(v)^2 \leq (\sum D(v))^2$ for non-negative integers (since cross terms are non-negative). The bound is achieved when all chips are on one vertex: $D = d \cdot \delta_v$ gives $E = 2(n-1)d^2$.

## 6. The Energy Spectrum

### Definition 6.1

The **energy spectrum** of a divisor $D$ on $G$ is:
$$\sigma(D) = \{E_G(D') : D' \sim D\}$$

### Theorem 6.1 (Energy Spectrum is a Class Invariant)

If $D_1 \sim D_2$, then $\sigma(D_1) = \sigma(D_2)$.

*Proof.* Linear equivalence is an equivalence relation. If $e \in \sigma(D_1)$, witnessed by $D_1 \sim D'$, and $D_1 \sim D_2$, then $D_2 \sim D_1 \sim D'$ by symmetry and transitivity, so $e \in \sigma(D_2)$. □

### Theorem 6.2 (Energy Spectrum Bounded Below)

$\forall e \in \sigma(D), \ e \geq 0$.

### Theorem 6.3 (Chip-Fire Energy Membership)

$E_G(\text{fire}(D, v)) \in \sigma(D)$ for all $v$.

## 7. The Picard Group

### Definition 7.1

A divisor $D$ is **principal** if $D = \Delta f$ for some $f: V \to \mathbb{Z}$.

### Theorem 7.1 (Principal Divisors Form a Subgroup)

1. The zero divisor is principal.
2. The sum of principal divisors is principal.
3. The negation of a principal divisor is principal.
4. Principal divisors have degree zero.

The **Picard group** (or **Jacobian**) of $G$ is $\text{Pic}^0(G) = \text{Div}^0(G) / \text{Prin}(G)$.

For $K_n$: $|\text{Pic}^0(K_n)| = n^{n-2}$ (Kirchhoff's matrix-tree theorem / Cayley's formula).

## 8. Algorithms

### 8.1 Energy Computation

**Input**: Graph $G$, divisor $D$
**Output**: $E_G(D)$
**Complexity**: $O(|E|)$

### 8.2 Greedy Energy Descent

**Input**: Graph $G$, divisor $D$
**Output**: A linearly equivalent divisor $D'$ with locally minimal energy
**Algorithm**: Repeatedly fire the vertex with maximum excess until no vertex has positive excess.
**Complexity**: Each firing changes the energy; convergence is guaranteed for connected graphs by the theory of q-reduced divisors.

## 9. Computational Verification

All theorems are verified in Lean 4 with Mathlib. The formalization comprises:

**Core module** (`Algebra/ChipFiring/Core.lean`): 19 theorems including:
- `energy_nonneg`, `energy_zero`, `energy_const`
- `energy_eq_twice_laplacianQuadForm`
- `energy_complete_graph` (closed-form for $K_n$)
- `energy_smul`, `energy_add_const`
- `canonical_degree`, `genus_complete`, `canonical_complete`
- `laplacian_degree_zero`, `chipFire_preserves_degree`
- `linEquiv_refl`, `linEquiv_symm`, `linEquiv_trans`
- `total_excess_zero`

**Energy spectrum module** (`Algebra/ChipFiring/EnergySpectrum.lean`): 14 theorems including:
- `energy_mem_spectrum`, `energySpectrum_bdd_below`
- `linEquiv_energySpectrum`
- `chipFire_energy_in_spectrum`
- `principal_degree_zero`, `principal_add`, `principal_neg`, `principal_zero`
- `sum_sq_le_degree_sq`
- `energy_effective_upper_bound`, `energy_effective_tight_bound`
- `energy_complete_eq_variance`
- `divisorVariance_nonneg`, `divisorVariance_eq_zero_iff`

## 10. Future Directions

1. **Energy spectrum and graph distinguishability**: Can $\sigma(D)$ distinguish non-isomorphic graphs?
2. **Rank-energy inequality**: Prove $r(D) \leq \sqrt{E_{\min}(D)/(2g)}$ or find a counterexample.
3. **Tropical curve limits**: Extend the energy functional to metric graphs and tropical curves.
4. **Algorithmic applications**: Use energy minimization for efficient divisor rank computation.

## References

[BN07] M. Baker, S. Norine. "Riemann-Roch and Abel-Jacobi theory on a finite graph." *Advances in Mathematics* 215 (2007), 766–788.

[Big99] N. Biggs. "Chip-firing and the critical group of a graph." *Journal of Algebraic Combinatorics* 9 (1999), 25–45.

[BJ15] M. Baker, D. Jensen. "Degeneration of linear series from the tropical point of view and applications." *Nonarchimedean and tropical geometry*, Simons Symposia, 2016.

[Lor89] D. Lorenzini. "Arithmetical graphs." *Mathematische Annalen* 285 (1989), 481–501.
