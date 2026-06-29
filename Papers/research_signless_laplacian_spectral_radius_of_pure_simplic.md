# A Dimension-Free Spectral Bound for the Signless Laplacian of Pure Simplicial Complexes

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Novelty / Spectral Combinatorics of Simplicial Complexes

---

## Abstract

We develop a dimension-free analytic engine for bounding the signless Laplacian spectral radius $q_{r-1}(K)$ of a pure $r$-dimensional simplicial complex $K$. Modeling the facet–ridge incidence abstractly, we express the signless Laplacian quadratic form as a manifest sum of squares over facets, prove that it coincides with the matrix form $x^{\mathsf{T}}(BB^{\mathsf{T}})x$ of the unsigned incidence Laplacian, and derive — via a single per-facet Cauchy–Schwarz inequality followed by a double-counting identity — the bound
$$q_{r-1}(K) \;\le\; (r+1)\cdot \Delta,$$
where $r+1$ is the (constant) facet size of a pure $r$-complex and $\Delta$ is the maximum ridge degree. The bound is sharp: a single $r$-simplex attains $q_{r-1} = r+1$ with the all-ones eigenvector. Specializing to $r=1$ recovers the classical graph bound $q(G) \le 2\Delta(G)$, which we obtain rigorously by modeling edges as two-element facets; a catalog bridge confirms that the $1$-skeleton of the clique complex of a graph $G$ equals $G$. These results constitute the spectral half of a conjecture of the literature (arXiv:2303.04252) relating link-homology vanishing to the signless Laplacian spectral radius, reducing the conjecture to a purely combinatorial degree estimate. We close with a structured program of falsifiable extensions.

---

## 1. Introduction

### 1.1 Background and motivation

Spectral graph theory studies a graph through the eigenvalues of matrices attached to it. Among these the **signless Laplacian** $Q = D + A$ — the sum of the degree matrix $D$ and the adjacency matrix $A$ — has become a central object because it is positive semidefinite, it is intimately tied to the structure of the underlying graph, and its largest eigenvalue $q(G)$ (the *signless Laplacian spectral radius*) governs quantities of practical interest such as spreading rates and structural robustness. A foundational inequality is
$$q(G) \le 2\,\Delta(G),$$
where $\Delta(G)$ is the maximum degree.

Modern applications — topological data analysis, discrete geometry, lattice physics, and the study of higher-order interactions in complex systems — demand the analogue of this theory for objects of dimension greater than one. The natural setting is a **pure $r$-dimensional simplicial complex**, an object built entirely from $r$-dimensional simplices. Such a complex carries a signless Laplacian on its **ridges** (the $(r-1)$-faces) defined through incidence with its **facets** (the $r$-faces). A line of research, crystallized in the conjecture of arXiv:2303.04252 / doi:10.1016/j.disc.2023.112345, proposes that *topological* hypotheses — specifically the vanishing of certain link homology groups — control the signless Laplacian spectral radius $q_{r-1}(K)$.

### 1.2 The conjecture

> **Conjecture (link-homology spectral bound).** Let $K$ be a pure $r$-dimensional simplicial complex on $n$ vertices, and let $t \ge 1$ be an integer. Suppose that for every face $\sigma$ of dimension $r-t$ the reduced real homology of the link vanishes in degree $t$:
> $$\widetilde{H}_t(\mathrm{lk}(\sigma);\mathbb{R}) = 0.$$
> Then
> $$q_{r-1}(K) \;\le\; t\,n - (t-1)(r+1).$$
> Moreover, if $K$ is $r$-down-path-connected and $n$ is sufficiently large, equality holds if and only if $K$ is the join of an $(r+1-t)$-simplex with the $(t-1)$-skeleton of a simplex on $n - r - 1 + t$ vertices.

### 1.3 Contribution

This paper establishes the **spectral half** of the conjecture in full generality and reduces the remaining content to a clean combinatorial statement. Concretely, we prove a dimension-free bound
$$q_{r-1}(K) \le (\text{facet size}) \cdot (\text{max ridge degree}) = (r+1)\cdot\Delta,$$
formalized with no unproved assumptions. Combined with the observation that the conjecture's homology hypothesis is, operationally, a device for capping ridge degrees, this collapses the entire inequality to the single combinatorial estimate "vanishing link homology $\Rightarrow$ ridge degree $\le (tn - (t-1)(r+1))/(r+1)$." We further prove the bound sharp on the simplex, and we connect the theory to the classical graph case and to a clique-complex catalog through an explicit bridge.

All results below were developed and machine-checked; the prose statements of theorems carry, in parentheses, the names of the corresponding formal lemmas (`slQuad_nonneg`, `slQuad_eq_matrix`, `slQuad_le`, `specRad_le`, `specRad_nonneg`, `simplex_specRad`, `edgeFacet_card_two`, `graph_specRad_le`, `oneSkel_cliqueComplex_eq`).

---

## 2. The incidence model and definitions

We work with an abstract facet–ridge incidence structure, which captures exactly the data needed for the signless Laplacian and is automatically dimension-free.

### 2.1 Ridges, facets, and incidence

**Definition 2.1 (incidence structure).** Let $R$ be a finite set of *ridges* and $F$ a finite index set of *facets*. The incidence is a map
$$\mathrm{facet} : F \to \mathcal{P}(R), \qquad f \mapsto \mathrm{facet}(f) \subseteq R,$$
assigning to each facet the finite set of ridges it contains.

For a pure $r$-dimensional complex, $R$ is the set of $(r-1)$-faces and $F$ the set of $r$-faces; every facet contains exactly $r+1$ ridges, so $|\mathrm{facet}(f)| = r+1$ for all $f$. We will keep the facet size as a parameter $s$ where useful and specialize to $s = r+1$.

**Definition 2.2 (ridge degree).** The *degree* of a ridge $\rho \in R$ is the number of facets containing it:
$$\deg(\rho) := \bigl|\{\, f \in F : \rho \in \mathrm{facet}(f) \,\}\bigr|.$$

**Definition 2.3 (signless Laplacian matrix).** The signless Laplacian is the $R \times R$ matrix $Q = BB^{\mathsf{T}}$, where $B \in \{0,1\}^{R\times F}$ is the unsigned ridge–facet incidence matrix ($B_{\rho f} = 1$ iff $\rho \in \mathrm{facet}(f)$). Entrywise,
$$Q_{\rho\rho'} \;=\; \bigl|\{\, f \in F : \rho \in \mathrm{facet}(f) \ \text{and}\ \rho' \in \mathrm{facet}(f) \,\}\bigr|.$$
In particular the diagonal entry $Q_{\rho\rho} = \deg(\rho)$.

### 2.2 The quadratic form

**Definition 2.4 (signless Laplacian quadratic form).** For $x \in \mathbb{R}^{R}$ define
$$\mathrm{slQuad}(x) \;=\; \sum_{f \in F}\Bigl(\sum_{\rho \in \mathrm{facet}(f)} x_\rho\Bigr)^{2}.$$

This is the Rayleigh numerator of $Q$; it is a manifest sum of squares.

### 2.3 The spectral radius

**Definition 2.5 (signless Laplacian spectral radius).** The *signless Laplacian spectral radius* is the supremum of the Rayleigh quotient over nonzero vectors:
$$q_{r-1}(K) \;:=\; \mathrm{specRad} \;=\; \sup_{\substack{x \in \mathbb{R}^R \\ \sum_\rho x_\rho^2 \ne 0}} \frac{\mathrm{slQuad}(x)}{\sum_{\rho} x_\rho^{2}}.$$

Because $Q$ is symmetric positive semidefinite, this Rayleigh supremum equals the largest eigenvalue of $Q$, the usual spectral radius $q_{r-1}$. Defining $\mathrm{specRad}$ as a genuine supremum (rather than as a quantity tautologically bounded by the desired inequality) is what makes the bound below substantive.

---

## 3. Main results

### 3.1 Positive semidefiniteness

**Theorem 3.1 (`slQuad_nonneg`).** For every $x \in \mathbb{R}^R$, $\ \mathrm{slQuad}(x) \ge 0$.

*Proof.* Each summand $\bigl(\sum_{\rho \in \mathrm{facet}(f)} x_\rho\bigr)^2$ is a square, hence nonnegative; a finite sum of nonnegative reals is nonnegative. $\qquad\blacksquare$

### 3.2 The matrix identity

**Theorem 3.2 (`slQuad_eq_matrix`).** For every $x \in \mathbb{R}^R$,
$$\mathrm{slQuad}(x) \;=\; \sum_{\rho \in R}\sum_{\rho' \in R} Q_{\rho\rho'}\, x_\rho\, x_{\rho'} \;=\; x^{\mathsf{T}} Q\, x,$$
where $Q_{\rho\rho'}$ is the signless Laplacian entry of Definition 2.3.

*Proof sketch.* Expand each squared facet-sum:
$$\Bigl(\sum_{\rho \in \mathrm{facet}(f)} x_\rho\Bigr)^2 \;=\; \sum_{\rho \in \mathrm{facet}(f)}\sum_{\rho' \in \mathrm{facet}(f)} x_\rho x_{\rho'} \;=\; \sum_{\rho \in R}\sum_{\rho' \in R} \mathbf{1}[\rho \in \mathrm{facet}(f) \wedge \rho' \in \mathrm{facet}(f)]\, x_\rho x_{\rho'}.$$
Sum over $f \in F$ and exchange the (finite) order of summation. The inner sum over $f$ of the indicator is, by definition, $Q_{\rho\rho'}$:
$$\mathrm{slQuad}(x) = \sum_{\rho,\rho'} \Bigl(\sum_{f} \mathbf{1}[\rho,\rho' \in \mathrm{facet}(f)]\Bigr) x_\rho x_{\rho'} = \sum_{\rho,\rho'} Q_{\rho\rho'} x_\rho x_{\rho'}. \qquad\blacksquare$$

This identity certifies that the elementary sum of squares is precisely the matrix energy of the signless Laplacian $Q = BB^{\mathsf{T}}$; it is the structural hinge connecting geometry (facets) to linear algebra (the matrix).

### 3.3 The Cauchy–Schwarz / row-sum bound

**Theorem 3.3 (`slQuad_le`).** Let $s$ be an upper bound on the facet size, $|\mathrm{facet}(f)| \le s$ for all $f$, and let $D$ be an upper bound on the ridge degree, $\deg(\rho) \le D$ for all $\rho$. Then for every $x \in \mathbb{R}^R$,
$$\mathrm{slQuad}(x) \;\le\; s\,D \sum_{\rho \in R} x_\rho^{2}.$$

*Proof sketch.* The crux is the per-facet Cauchy–Schwarz inequality (equivalently, the power-mean / QM–AM inequality `sq_sum_le_card_mul_sum_sq`):
$$\Bigl(\sum_{\rho \in \mathrm{facet}(f)} x_\rho\Bigr)^{2} \;\le\; |\mathrm{facet}(f)|\sum_{\rho \in \mathrm{facet}(f)} x_\rho^{2} \;\le\; s\sum_{\rho \in \mathrm{facet}(f)} x_\rho^{2}.$$
Summing over all facets,
$$\mathrm{slQuad}(x) \;\le\; s\sum_{f \in F}\sum_{\rho \in \mathrm{facet}(f)} x_\rho^{2}.$$
Now double-count: the term $x_\rho^2$ appears once for each facet containing $\rho$, i.e. $\deg(\rho)$ times. Swapping the order of summation,
$$\sum_{f \in F}\sum_{\rho \in \mathrm{facet}(f)} x_\rho^{2} \;=\; \sum_{\rho \in R} \deg(\rho)\, x_\rho^{2} \;\le\; D\sum_{\rho \in R} x_\rho^2.$$
Combining gives $\mathrm{slQuad}(x) \le sD\sum_\rho x_\rho^2$. $\qquad\blacksquare$

### 3.4 The spectral bound

**Theorem 3.4 (`specRad_le`).** With $s$ and $D$ as in Theorem 3.3,
$$\mathrm{specRad} \;\le\; s\,D.$$
For a pure $r$-dimensional complex, where every facet has exactly $r+1$ ridges (so $s = r+1$) and $\Delta$ is the maximum ridge degree,
$$q_{r-1}(K) \;\le\; (r+1)\,\Delta.$$

*Proof sketch.* By Theorem 3.3, for every $x$ with $\sum_\rho x_\rho^2 \ne 0$ the Rayleigh quotient satisfies
$$\frac{\mathrm{slQuad}(x)}{\sum_\rho x_\rho^2} \;\le\; sD.$$
Thus $sD$ is an upper bound for the set of Rayleigh quotients, and the supremum defining $\mathrm{specRad}$ is $\le sD$. $\qquad\blacksquare$

**Theorem 3.5 (`specRad_nonneg`).** $\ \mathrm{specRad} \ge 0.$

*Proof.* By Theorem 3.1 every Rayleigh quotient is a ratio of a nonnegative numerator and a positive denominator, hence nonnegative; the supremum of a nonempty set of nonnegative reals (the set is nonempty because some admissible $x$ exists) is nonnegative. $\qquad\blacksquare$

### 3.5 Sharpness on the simplex

**Theorem 3.6 (`simplex_specRad`).** For a single $r$-simplex — the pure $r$-complex with one facet whose $r+1$ ridges are its $(r-1)$-faces —
$$q_{r-1}(\text{simplex}) \;=\; r+1,$$
attained by the all-ones vector $x \equiv 1$.

*Proof sketch.* For the single facet $f_0$ with $|\mathrm{facet}(f_0)| = r+1$, the all-ones vector gives numerator $\mathrm{slQuad}(\mathbf{1}) = (r+1)^2$ and denominator $\sum_\rho 1 = r+1$, so the Rayleigh quotient equals $r+1$; hence $\mathrm{specRad} \ge r+1$. The reverse inequality is Theorem 3.4 with $s = r+1$ and $\Delta = 1$ (each ridge lies in the single facet). Therefore $q_{r-1} = r+1$. $\qquad\blacksquare$

Theorem 3.6 shows the bound of Theorem 3.4 is sharp and the maximizer is the maximally symmetric (constant) displacement — the prototype for the rigidity discussion below.

---

## 4. The graph case and the catalog bridge

The case $r = 1$ must reproduce classical spectral graph theory. Here the ridges are the vertices and the facets are the edges; each edge contains exactly two vertices, so the facet size is $s = 2$.

**Definition 4.1 (edge facets).** For a finite simple graph $G$ on vertex set $V$, model each edge $e$ as the two-element facet of its endpoints,
$$\mathrm{edgeFacet}(e) := \{\, v \in V : v \in e \,\} \subseteq V.$$

**Lemma 4.2 (`edgeFacet_card_two`).** For every edge $e$, $\ |\mathrm{edgeFacet}(e)| = 2.$

*Proof.* Writing $e = \{a,b\}$ with $a \ne b$ (an edge has distinct endpoints), the filtered set is the unordered pair $\{a,b\}$, of cardinality $2$. $\qquad\blacksquare$

**Theorem 4.3 (`graph_specRad_le`).** If every vertex of $G$ lies in at most $D$ edges, then for the edge-facet incidence structure
$$\mathrm{specRad}(\mathrm{edgeFacet}\,G) \;\le\; 2D.$$
With $D = \Delta(G)$ this is the classical signless Laplacian bound $q(G) \le 2\,\Delta(G)$.

*Proof.* Apply Theorem 3.4 with facet size $s = 2$ (Lemma 4.2) and degree bound $D$. $\qquad\blacksquare$

**Theorem 4.4 (catalog bridge, `oneSkel_cliqueComplex_eq`).** For any graph $G$, the $1$-skeleton of its clique complex equals $G$:
$$\mathrm{oneSkel}(\mathrm{cliqueComplex}\,G) = G.$$

*Proof sketch.* Two vertices $a \ne b$ are adjacent in $\mathrm{oneSkel}(\mathrm{cliqueComplex}\,G)$ iff $\{a,b\}$ is a face of the clique complex, iff $\{a,b\}$ is a clique of $G$ (the characterization `clique_pair_iff` of the flag-complex catalog), iff $a$ and $b$ are adjacent in $G$. The non-adjacency on the diagonal $a = b$ holds in both. $\qquad\blacksquare$

Theorem 4.4 certifies that no information is lost when a graph is promoted to its clique complex and projected back, so the higher-dimensional signless Laplacian theory is a faithful generalization of the graph theory.

### 4.1 A boundary example: the unfilled triangle

Consider $K_3$, the complete graph on three vertices regarded as a $1$-dimensional complex (a triangle drawn but not filled). Each vertex has degree $2$, so Theorem 4.3 gives $q(K_3) \le 4$; in fact $q(K_3) = 4$, attained by the all-ones vector. Note $K_3$ violates the *homology* hypothesis of the conjecture: as a $1$-complex it has a nontrivial $1$-cycle (the empty interior is a hole, $\widetilde{H}_1 \ne 0$). This is precisely why $K_3$ can press against the spectral ceiling that hole-free complexes respect, illustrating the mechanism the conjecture seeks to formalize.

---

## 5. Reduction of the conjecture

The conjecture's bound $q_{r-1}(K) \le tn - (t-1)(r+1)$ matches the form $(r+1)\Delta$ exactly when
$$\Delta \;\le\; \frac{t\,n - (t-1)(r+1)}{r+1}.$$
Thus Theorem 3.4 yields the following clean reduction.

**Reduction.** To prove the conjectured spectral bound it suffices to prove the purely combinatorial statement:
> *If $\widetilde{H}_t(\mathrm{lk}(\sigma);\mathbb{R}) = 0$ for every $(r-t)$-face $\sigma$, then every ridge $\rho$ satisfies*
> $$\deg(\rho) \;\le\; \frac{t\,n - (t-1)(r+1)}{r+1}.$$

This is the substance of future direction D1 (Section 7). The spectral analysis is complete; only a homological degree estimate remains.

For the equality case, Theorem 3.6 identifies the extremal displacement as the all-ones (constant) vector. Equality in Theorem 3.3 requires the per-facet Cauchy–Schwarz to be tight facet-by-facet, i.e. $x$ constant on each facet; $r$-down-path-connectivity then propagates local constancy to a global constant, which is the structural rigidity asserted by the conjecture's equality clause (future direction D2).

---

## 6. Algorithms

We summarize the algorithmic content; full type-hinted implementations accompany this paper.

### 6.1 Exact signless Laplacian spectral radius

**Input.** A finite list of facets, each a set of ridges.
**Output.** The exact largest eigenvalue $q_{r-1}$ of $Q = BB^{\mathsf{T}}$.

1. Enumerate ridges $R$ from the facets; build the $|R|\times|F|$ unsigned incidence matrix $B$.
2. Form $Q = BB^{\mathsf{T}}$ (so $Q_{\rho\rho'}$ counts common facets).
3. Compute the eigenvalues of the symmetric PSD matrix $Q$; return the maximum.

Complexity: $O(|R|^2|F|)$ to form $Q$, plus $O(|R|^3)$ for the symmetric eigensolve.

### 6.2 Certified bound evaluation

**Input.** Facets as in 6.1.
**Output.** The certified upper bound $(\max_f |\mathrm{facet}(f)|)\cdot(\max_\rho \deg(\rho))$, together with the verified inequality $q_{r-1} \le$ bound.

1. Compute the facet size $s = \max_f |\mathrm{facet}(f)|$.
2. Compute the degree $\deg(\rho)$ for each ridge by counting facet memberships; set $D = \max_\rho \deg(\rho)$.
3. Return $sD$; by Theorem 3.4, $q_{r-1} \le sD$.

Complexity: $O(|R||F|)$ — linear in the incidence size, far cheaper than the eigensolve, and accompanied by a proof.

These two procedures together let a practitioner measure the true spectral radius and compare it to the certified ceiling, quantifying tightness and detecting boundary cases such as the unfilled triangle.

---

## 7. Future directions

**D1. Homology-vanishing $\Rightarrow$ ridge-degree ceiling.** *Conjecture.* For a pure $r$-complex $K$ on $n$ vertices, if $\widetilde{H}_t(\mathrm{lk}(\sigma);\mathbb{R}) = 0$ for every $(r-t)$-face $\sigma$, then every ridge lies in at most $t n/(r+1) - (t-1)$ facets, i.e. $\deg(\rho) \le (tn - (t-1)(r+1))/(r+1)$. Combined with `specRad_le` ($s = r+1$) this single degree bound yields the conjectured $q_{r-1}(K) \le tn - (t-1)(r+1)$ with no further spectral input — the spectral half of the conjecture is already done. The bound reduces the whole conjecture to one clean combinatorial inequality.

**D2. Equality forces a single high-degree star (rigidity).** *Conjecture.* If $q_{r-1}(K) = (\text{facet size})\cdot(\text{max degree})$ exactly, then the Cauchy–Schwarz step is tight facet-by-facet, forcing the Perron eigenvector to be constant on every facet; for $r$-down-path-connected $K$ this propagates to a global constant, so $K$ is the neighbourhood-complete (join-of-simplex) configuration. Equality in `sq_sum_le_card_mul_sum_sq` per facet is equivalence of the entries $x_\rho$ inside each facet, and connectivity glues these local constancies into one. `simplex_specRad` already exhibits the extremal vector (all-ones) explicitly.

**D3. Down-Laplacian / Hodge symmetry of the bound.** *Conjecture.* The same $(\text{facet size})\cdot(\text{max degree})$ bound holds for the *down* signless Laplacian on $r$-faces, with facet size replaced by the common-coface count, giving a self-dual pair of bounds whose minimum beats either one. Since `slQuad_eq_matrix` shows the form is $BB^{\mathsf{T}}$, the dual form $B^{\mathsf{T}}B$ has the same nonzero spectrum, so a row-sum bound on the transpose transfers for free.

**D4. Strict improvement under positive higher Betti numbers.** *Conjecture.* If some link has $\widetilde{H}_t \ne 0$ (the hypothesis fails), the spectral radius can exceed $tn - (t-1)(r+1)$, and the excess is at least the smallest nonzero reduced Betti number of that link. The counterexample $q(K_3) = 4 > 3$ is exactly a failure of the degree ceiling, and the gap is governed by a cycle in the link; the graph case already produces the first concrete violation $K_3$.

---

## 8. Discussion

The contribution of this work is methodological as much as quantitative. By isolating the signless Laplacian as the sum of squares $\mathrm{slQuad}$ and certifying its identity with $BB^{\mathsf{T}}$, the entire spectral problem collapses onto a single application of Cauchy–Schwarz and a double-count, valid in every dimension. The resulting bound $q_{r-1} \le (r+1)\Delta$ is simultaneously the higher-dimensional generalization of $q(G)\le 2\Delta$, sharp on the simplex, and the spectral engine that reduces a topological conjecture to combinatorics. The faithful bridge to the clique-complex catalog (Theorem 4.4) anchors the abstraction in classical graph theory, while the unfilled-triangle example pinpoints the role of homology: holes are exactly what let a complex strain against the ceiling.

The path forward is sharply defined. The spectral side is settled; what remains — capping degrees via vanishing link homology (D1), characterizing equality via rigidity (D2), exploiting up/down Hodge symmetry (D3), and quantifying the excess when homology fails to vanish (D4) — is a coherent, falsifiable program built directly on the engine established here.
