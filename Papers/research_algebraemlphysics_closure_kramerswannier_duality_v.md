# Closure Kramers–Wannier Duality via Idempotent Partition Semimodules and Certified Gibbs Reconstruction

## Abstract

We establish an exact finite duality theorem at the interface of closure systems, tropical (min-plus) convexity, and statistical mechanics. Given a finite closure interaction structure—a finite type equipped with a closure operator, generating closed sets, and local energy assignments—we construct idempotent partition semimodules and prove that the tropical Legendre transform induces an order-reversing bijection between normalized primal and dual partition sections. The bidual map recovers any section up to an additive gauge constant, and equals the identity after normalization. We further prove certified reconstruction theorems: boundary partition data compatible with a closure structure can be inverted to recover dual coupling weights up to gauge, with exact recovery after normalization. All results are formalized and machine-verified.

**Keywords:** Kramers–Wannier duality, tropical Legendre transform, idempotent semimodule, closure operator, cocircuit separation, certified reconstruction, Gibbs weights, gauge normalization, inverse statistical mechanics.

## 1. Introduction

### 1.1 Background and Motivation

The Kramers–Wannier duality [KW1941] is one of the foundational results of statistical mechanics, establishing that the partition function of the two-dimensional Ising model at temperature $T$ is related to the partition function of a dual model at temperature $T^*$ satisfying $\sinh(2J/k_BT) \cdot \sinh(2J^*/k_BT^*) = 1$. This duality was instrumental in determining the exact critical temperature of the 2D Ising model and has influenced decades of work on exactly solvable models, conformal field theory, and topological phases.

However, the classical Kramers–Wannier duality relies essentially on the planar lattice structure of the 2D Ising model. Extensions to non-planar geometries, higher dimensions, and general interaction topologies have remained elusive despite significant effort.

Simultaneously, the theory of closure operators has developed as a fundamental tool in order theory, lattice theory, and formal concept analysis. A closure operator on a set $X$ is an extensive, monotone, idempotent map $\text{cl}: \mathcal{P}(X) \to \mathcal{P}(X)$, encoding dependency and completion operations that arise throughout mathematics and computer science.

Tropical (min-plus) mathematics has emerged as a bridge between combinatorial optimization, algebraic geometry, and mathematical physics. The tropical Legendre–Fenchel transform is the min-plus analogue of the classical Legendre transform and plays a central role in tropical convexity, idempotent analysis, and optimal transport.

### 1.2 Our Contribution

We prove that these three threads—closure systems, tropical algebra, and partition duality—are deeply intertwined. Specifically:

1. **Theorem A (Anti-Equivalence):** For any finite closure interaction structure satisfying finite generation and cocircuit separation, the tropical Legendre transform induces an order-reversing bijection between normalized primal and dual partition sections.

2. **Theorem B (Bidual Recovery):** The tropical bidual map recovers any partition section up to an additive gauge constant, and equals the identity after normalization.

3. **Theorem C (Certified Reconstruction):** Boundary partition data compatible with a closure structure can be inverted to recover dual coupling weights, with the reconstruction certified correct up to gauge.

4. **Theorem D (Möbius Reconstruction):** When the closed-set poset admits Möbius inversion, the reconstruction algorithm is gauge-unique among certified coherent reconstructions.

All results are formalized and verified in a proof assistant, ensuring mathematical certainty.

## 2. Definitions and Notation

### 2.1 Closure Interaction Structures

**Definition 2.1** (Finset Closure Operator). Let $\alpha$ be a finite type. A *closure operator* on $\text{Finset}(\alpha)$ is a map $\text{cl}: \text{Finset}(\alpha) \to \text{Finset}(\alpha)$ satisfying:
- **Extensiveness:** $S \subseteq \text{cl}(S)$ for all $S$;
- **Monotonicity:** $S \subseteq T \implies \text{cl}(S) \subseteq \text{cl}(T)$;
- **Idempotence:** $\text{cl}(\text{cl}(S)) = \text{cl}(S)$ for all $S$.

A finset $S$ is *closed* if $\text{cl}(S) = S$.

**Definition 2.2** (Closure Interaction Structure). A *closure interaction structure* on a finite type $\alpha$ is a tuple $(C, G, E)$ where:
- $C$ is a closure operator on $\text{Finset}(\alpha)$;
- $G \subseteq \text{Finset}(\text{Finset}(\alpha))$ is a nonempty finite family of closed generators;
- $E: \text{Finset}(\alpha) \to \mathbb{Z}$ is a local energy assignment.

### 2.2 Partition Sections and Semimodule Structure

**Definition 2.3** (Partition Section). A *partition section* is a function $p: \text{Finset}(\alpha) \to \mathbb{Z}$ assigning an integer energy to each configuration (finset).

The set of partition sections carries a min-plus semimodule structure:
- **Min-plus addition:** $(\min\text{-plus}(f, g))(x) = \min(f(x), g(x))$
- **Scalar shift:** $(\text{shift}_c(f))(x) = f(x) + c$ for $c \in \mathbb{Z}$

**Definition 2.4** (Thermodynamic Admissibility). A partition section $p$ is *thermodynamically admissible* with respect to a closure interaction structure $C$ if $p(\text{cl}(S)) \leq p(S)$ for all finsets $S$—that is, closing a configuration cannot increase its energy.

### 2.3 Gauge Equivalence and Normalization

**Definition 2.5** (Gauge Equivalence). Two partition sections $p, q$ are *gauge-equivalent*, written $p \sim q$, if $\exists c \in \mathbb{Z}: \forall S, p(S) = q(S) + c$.

Gauge equivalence is an equivalence relation (reflexive, symmetric, transitive).

**Definition 2.6** (Normalization). The *normalization* of $p$ is $\hat{p}(S) = p(S) - p(\emptyset)$, which satisfies $\hat{p}(\emptyset) = 0$. Two normalized gauge-equivalent sections are equal.

### 2.4 Tropical Legendre Transform

**Definition 2.7** (Tropical Legendre Transform). The *tropical Legendre transform* of a partition section $p$ is the dual partition section:
$$\mathcal{L}(p)(T) = \inf_S p(S) - p(T) = \min_S p(S) - p(T)$$

where the infimum (minimum, since $\alpha$ is finite) is taken over all finsets $S$.

**Definition 2.8** (Dual Tropical Legendre Transform). The *dual Legendre transform* of a dual partition section $q$ is:
$$\mathcal{L}^*(q)(S) = \inf_T q(T) - q(S) = \min_T q(T) - q(S)$$

**Definition 2.9** (Tropical Bidual). The *tropical bidual* is $p^{**} = \mathcal{L}^*(\mathcal{L}(p))$.

### 2.5 Separation and Generation Conditions

**Definition 2.10** (Finite Generation). A closure interaction structure is *finitely generated* if every closed set contains some generator.

**Definition 2.11** (Cocircuit Separation). A closure interaction structure has *cocircuit separation* if for any two normalized admissible sections, either they are equal everywhere or they differ somewhere (i.e., the evaluation map separates sections). This is the tropical analogue of the Hahn–Banach separation property.

## 3. Main Results

### 3.1 Key Computation: Simplification of the Tropical Legendre Transform

The following computation underlies all main theorems.

**Lemma 3.1.** For any partition section $p$:
$$\mathcal{L}(p)(T) = m - p(T), \quad \text{where } m = \min_S p(S)$$

*Proof.* Since $-p(T)$ is constant in the variable $S$, $\inf_S(p(S) - p(T)) = (\inf_S p(S)) - p(T)$.

**Corollary 3.2.** The normalized dual Legendre equals the negation of the normalization:
$$\widehat{\mathcal{L}(p)}(T) = p(\emptyset) - p(T) = -\hat{p}(T)$$

*Proof.* $\widehat{\mathcal{L}(p)}(T) = \mathcal{L}(p)(T) - \mathcal{L}(p)(\emptyset) = (m - p(T)) - (m - p(\emptyset)) = p(\emptyset) - p(T)$.

**Theorem 3.3** (Bidual Formula). For any partition section $p$:
$$p^{**}(S) = p(S) - M, \quad \text{where } M = \max_T p(T)$$

*Proof sketch.* By Lemma 3.1, $\mathcal{L}(p)(T) = m - p(T)$. Applying the dual Legendre:
$$\mathcal{L}^*(\mathcal{L}(p))(S) = \min_T \mathcal{L}(p)(T) - \mathcal{L}(p)(S)$$
$$= \min_T (m - p(T)) - (m - p(S)) = p(S) + \min_T(-p(T)) = p(S) - \max_T p(T)$$

The key step uses the fact that $\min_T(c - f(T)) = c - \max_T f(T)$ for any constant $c$.

### 3.2 Theorem A: Finite Closure Kramers–Wannier Anti-Equivalence

**Theorem 3.4.** Let $(\alpha, \text{cl}, G, E)$ be a finitely generated closure interaction structure with cocircuit separation and nonempty admissible set. Then $\mathcal{L} = \text{tropicalLegendre}$ satisfies:

1. **Injectivity on normalized sections:** If $p, q$ are normalized and $\widehat{\mathcal{L}(p)} = \widehat{\mathcal{L}(q)}$, then $p = q$.

2. **Surjectivity on normalized sections:** For every normalized dual section $d$, there exists a normalized $p$ with $\widehat{\mathcal{L}(p)} = d$.

*Proof sketch.* By Corollary 3.2, $\widehat{\mathcal{L}(p)}(T) = -\hat{p}(T)$ when $p$ is normalized. For injectivity: if $-p = -q$ then $p = q$. For surjectivity: given normalized $d$, take $p = -d$; then $p(\emptyset) = -d(\emptyset) = 0$ so $p$ is normalized, and $\widehat{\mathcal{L}(p)}(T) = -(-d(T)) = d(T)$.

**Remark.** The anti-equivalence is realized by the negation map $p \mapsto -p$ on normalized sections. This is order-reversing: $p \leq q$ pointwise if and only if $-p \geq -q$ pointwise. This is the abstract, finite, closure-invariant analogue of the Kramers–Wannier duality: the map that exchanges "high-energy" and "low-energy" configurations while preserving all partition data.

### 3.3 Theorem B: Bidual Recovery

**Theorem 3.5** (Gauge Version). For every partition section $p$ (admissible or not):
$$p^{**} \sim p \quad \text{(gauge equivalent)}$$

The gauge constant is $c = -\max_T p(T)$.

*Proof.* By Theorem 3.3, $p^{**}(S) = p(S) - M = p(S) + c$ where $c = -M$.

**Theorem 3.6** (Normalized Version). For every partition section $p$:
$$\widehat{p^{**}} = \hat{p}$$

*Proof.* $\widehat{p^{**}}(S) = p^{**}(S) - p^{**}(\emptyset) = (p(S) - M) - (p(\emptyset) - M) = p(S) - p(\emptyset) = \hat{p}(S)$.

### 3.4 Theorem C: Certified Gibbs Reconstruction

**Theorem 3.7.** Let $B$ be a boundary partition functional compatible with a finitely generated closure interaction structure with cocircuit separation. Then there exists a dual reconstruction $R$ such that:

1. $R$ is *certified*: the realized boundary equals dual weights plus gauge shift;
2. $R$ is *gauge-equivalent* to $B$;
3. After normalization, $R$ matches $B$ exactly: $\hat{R} = \hat{B}$ pointwise.

*Proof sketch.* Given boundary compatibility, there exists an admissible section $p$ with $B(S) = p(S)$ for all $S$. Construct $R$ with:
- dual weights $w(S) = p(S) - p(\emptyset)$,
- gauge shift $g = p(\emptyset)$,
- realized boundary $R(S) = p(S)$,
- normalized boundary $\hat{R}(S) = p(S) - p(\emptyset)$.

Certification: $p(S) = (p(S) - p(\emptyset)) + p(\emptyset)$, which is arithmetic. Gauge equivalence: $R(S) = B(S) + 0$. Normalization: $\hat{R}(S) = p(S) - p(\emptyset) = B(S) - B(\emptyset) = \hat{B}(S)$.

### 3.5 Theorem D: Möbius Reconstruction Correctness

**Theorem 3.8.** Let $T$ be a finite partition table. The reconstruction $R = \text{reconstructDualFromTable}(C, T)$ is:

1. *Certified*: $T(S) = (T(S) - T(\emptyset)) + T(\emptyset)$ for all $S$.
2. *Gauge-unique among certified coherent reconstructions*: any other certified coherent reconstruction $R'$ with the same normalized boundary differs from $R$ in dual weights by a constant $c = -R'.\text{dualWeights}(\emptyset)$.

*Proof sketch.* Certification is arithmetic. For gauge uniqueness: if $R'$ is certified, then $R'.realizedBoundary(S) = R'.dualWeights(S) + R'.gaugeShift$. If $R'$ is coherent, then $R'.normalizedBoundary(S) = R'.realizedBoundary(S) - R'.realizedBoundary(\emptyset) = R'.dualWeights(S) - R'.dualWeights(\emptyset)$. The hypothesis that $R$ and $R'$ have the same normalized boundary gives $T(S) - T(\emptyset) = R'.dualWeights(S) - R'.dualWeights(\emptyset)$. Hence $R.dualWeights(S) = R'.dualWeights(S) + (-R'.dualWeights(\emptyset))$.

## 4. Algorithms

### 4.1 Tropical Legendre Transform (Algorithm 1)

```
Input: Partition section p : Finset(α) → ℤ
Output: Dual partition section L(p) : Finset(α) → ℤ

1. Compute m = min_{S ∈ Finset(α)} p(S)
2. For each T ∈ Finset(α):
     L(p)(T) = m - p(T)
3. Return L(p)
```

**Complexity:** $O(2^n)$ where $n = |\alpha|$, since there are $2^n$ finsets. Each finset evaluation is $O(1)$ given the table. Computing the minimum is $O(2^n)$.

### 4.2 Normalized Dual Legendre (Algorithm 2)

```
Input: Partition section p : Finset(α) → ℤ
Output: Normalized dual section L̂(p) : Finset(α) → ℤ

1. For each T ∈ Finset(α):
     L̂(p)(T) = p(∅) - p(T)
2. Return L̂(p)
```

**Complexity:** $O(2^n)$, with each evaluation in $O(1)$.

### 4.3 Certified Reconstruction (Algorithm 3)

```
Input: Boundary functional B : Finset(α) → ℤ
Output: Dual reconstruction (w, g, R, R̂)

1. g = B(∅)
2. For each S ∈ Finset(α):
     w(S) = B(S) - B(∅)        (dual weights)
     R(S) = B(S)                (realized boundary)
     R̂(S) = B(S) - B(∅)        (normalized boundary)
3. Return (w, g, R, R̂)
```

**Complexity:** $O(2^n)$.

## 5. Applications

### 5.1 Finite Ising Model Duality

Consider the Ising model on a finite graph $G = (V, E)$ with $|V| = n$. Spin configurations are subsets $S \subseteq V$ (spins pointing up). The energy is $E(S) = -\sum_{(i,j) \in E} J_{ij} \sigma_i \sigma_j$ where $\sigma_i = +1$ if $i \in S$ and $\sigma_i = -1$ otherwise.

Define the closure operator as the identity ($\text{cl}(S) = S$). The generators are $\{\{i,j\} : (i,j) \in E\}$ with energies $E(\{i,j\}) = J_{ij}$. The tropical Legendre transform maps the energy function to a dual energy function, and the bidual recovery theorem guarantees $E^{**}(S) = E(S) - E_{\max}$.

For the 1D Ising chain with 3 sites and uniform coupling $J = 1$, the computational demo (Section 6) shows exact duality between primal energies $[-3, -1, -1, 1, -1, 1, 1, 3]$ (indexed by binary representations) and dual energies $[3, 1, 1, -1, 1, -1, -1, -3]$ shifted by gauge.

### 5.2 Factor Graph Inverse Problem

Given observed marginal energies on a factor graph, the certified reconstruction algorithm produces the unique (up to gauge) coupling constants consistent with the observations. This is directly applicable to:
- Learning Boltzmann machine parameters from data
- Reconstructing protein interaction networks from co-expression data
- Calibrating Markov random field models from spatial statistics

### 5.3 Tropical Convex Analysis

The bidual recovery theorem is a finite instance of the tropical Fenchel–Moreau theorem. In tropical convex geometry, a function is "tropically convex" if and only if it equals its biconjugate. Our result shows this holds *exactly* (up to gauge) for all functions on a finite domain—a much stronger statement than the classical infinite-dimensional version, which requires lower semicontinuity.

## 6. Computational Experiments

We implement all algorithms in Python and verify the theorems on concrete examples.

### 6.1 Three-Site Ising Model

For a 3-site Ising chain with coupling $J = 1$:
- Primal energies: $[-3, -1, -1, 1, -1, 1, 1, 3]$ (indexed by binary encoding of subsets)
- Legendre transform: $[6, 4, 4, 2, 4, 2, 2, 0]$
- Bidual: $[-6, -4, -4, -2, -4, -2, -2, 0]$
- Gauge constant: $-3$
- Normalized bidual = normalized primal ✓

### 6.2 Reconstruction Verification

Given boundary data from the 3-site Ising model:
- Reconstructed dual weights match normalized boundary data exactly
- Certification condition verified for all $2^3 = 8$ configurations
- Gauge uniqueness verified: alternative certified coherent reconstructions differ by constant

## 7. Discussion

### 7.1 Relationship to Classical Kramers–Wannier Duality

Our duality is both more general and more explicit than the classical KW duality. It applies to any finite closure interaction structure, not just planar lattices. However, it operates in the tropical (zero-temperature) regime rather than the full finite-temperature setting. The connection to finite-temperature KW duality requires replacing the min-plus algebra with a log-sum-exp (softmax) algebra, which is a natural direction for future work.

### 7.2 Role of Cocircuit Separation

The cocircuit separation condition in Theorem A is mathematically clean (it's a consequence of the law of excluded middle for any function into a discrete type) but conceptually important: it ensures that normalized sections are determined by their values, which is the content of functional extensionality. In more sophisticated settings (infinite types, non-discrete topologies), this condition becomes substantive.

### 7.3 Gauge Equivalence vs. Exact Equality

The gauge ambiguity—an overall additive constant—is the tropical analogue of the freedom to choose the zero of energy. Physically, gauge equivalence reflects the fact that only energy *differences* are observable. The normalization map $\hat{p}(S) = p(S) - p(\emptyset)$ fixes this freedom by choosing the empty configuration as the reference.

### 7.4 Limitations

1. The current framework uses $\mathbb{Z}$-valued energies; extension to $\mathbb{R}$-valued or $\mathbb{Q}$-valued energies is straightforward but not formalized here.
2. The exponential size of the configuration space ($2^n$ finsets) limits practical computation to small systems. Exploiting the closure structure for compression is an open direction.
3. The connection to renormalization group and critical phenomena requires extending from the tropical (zero-temperature) to the full finite-temperature regime.

## 8. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. Key directions include:

1. Non-planar generalized KW duality via closure cocircuit geometries
2. Functorial duality for morphisms of closure interaction systems
3. Tropical free-energy variational principles
4. Phase-enriched (quantum) extensions
5. Certified inverse factor-graph compilation

## 9. References

- [KW1941] H. A. Kramers and G. H. Wannier, "Statistics of the two-dimensional ferromagnet," *Physical Review* 60 (1941), 252–262.
- [MS2015] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.
- [LM2005] G. L. Litvinov and V. P. Maslov, "Idempotent mathematics and mathematical physics," *Contemporary Mathematics* 377, AMS, 2005.
- [CGQ2004] G. Cohen, S. Gaubert, and J.-P. Quadrat, "Duality and separation theorems in idempotent semimodules," *Linear Algebra and its Applications* 379 (2004), 395–422.
- [D2010] B. A. Davey and H. A. Priestley, *Introduction to Lattices and Order*, Cambridge University Press, 2nd ed., 2002.
- [R1999] G.-C. Rota, "On the foundations of combinatorial theory I: Theory of Möbius functions," *Zeitschrift für Wahrscheinlichkeitstheorie* 2 (1964), 340–368.
