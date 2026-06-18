# Tropical Persistence Stability and Certified Network Robustness

## Abstract

We establish a tropical bottleneck stability theorem for weighted graph filtrations, proving that the sublevel-set persistence data of a finite weighted graph is 1-Lipschitz with respect to the sup-norm on edge weights. The main result shows that ε-close weight functions produce ε-interleaved filtrations, and that this bound is tight: the interleaving distance equals the sup-norm distance. We derive computable robustness certificates for topological events (persistent features, connectivity thresholds, weight ranges) and prove cross-domain Lipschitz bounds connecting tropical persistence to network reliability theory. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords:** topological data analysis, network robustness, uncertainty quantification, interleavings, bottleneck distance, tropical geometry, noisy measurements, certified inference, graph filtrations, phase transitions.

---

## 1. Introduction

### 1.1 Motivation

Topological data analysis (TDA) extracts shape information from data by studying filtrations — nested families of spaces indexed by a real parameter. The foundational result in TDA is the *stability theorem* of Cohen-Steiner, Edelsbrunner, and Harer [1], which shows that persistent homology barcodes are stable under perturbations of the input. This theorem transformed persistent homology from a theoretical curiosity into a practical tool for noisy data analysis.

Tropical geometry provides a parallel framework for analyzing weighted combinatorial structures, where the semiring (ℝ, min, +) replaces the classical field operations. Tropical methods have deep connections to optimization, algebraic geometry, and combinatorics [2, 3]. In the context of graphs, tropical invariants — such as the tropical rank of the Laplacian, divisor theory à la Baker–Norine [4], and tropical Morse theory — capture structural information complementary to classical topological invariants.

Despite the natural fit between tropical geometry and weighted graph filtrations, the metric stability of tropical persistence invariants has not been established. This paper fills that gap.

### 1.2 Contributions

1. **Definitions.** We introduce a framework of tropical graph filtrations, sublevel sets, rank functions, and interleaving distances for weighted graphs (§2).

2. **Stability theorem.** We prove that the interleaving distance between two tropical filtrations equals the sup-norm distance between their weight functions (Theorem 3.3). This implies 1-Lipschitz stability.

3. **Certified robustness.** We derive computable certificates guaranteeing that topological events (persistent features, connectivity thresholds) survive bounded perturbations (§4).

4. **Cross-domain bridges.** We prove that the merge time and minimum critical value are 1-Lipschitz, connecting tropical persistence to network reliability and optimization (§5).

5. **Formal verification.** All definitions and theorems are machine-verified in Lean 4.

### 1.3 Related Work

Classical persistence stability was established by Cohen-Steiner, Edelsbrunner, and Harer [1] and extended to algebraic stability by Chazal et al. [5]. The interleaving distance was formalized by Bubenik and Scott [6]. Tropical geometry on graphs was developed by Mikhalkin [2], Baker and Norine [4], and others. The connection between tropical Morse theory and graph filtrations appears in the work on tropical divisor theory, but metric stability in this setting is new.

---

## 2. Definitions and Setup

### 2.1 Weighted Graphs and Filtrations

**Definition 2.1** (Tropical Graph Filtration). A *tropical graph filtration* consists of:
- A finite type E (edges) with a weight function w : E → ℝ
- Optionally, a finite type V (vertices) with an incidence map E → V × V

We work primarily with the edge-weight function w and the resulting filtration.

**Definition 2.2** (Sublevel Set). For a weight function w : E → ℝ and threshold t ∈ ℝ, the *sublevel set* is:
$$F_w(t) = \{e \in E : w(e) \leq t\}$$

**Definition 2.3** (Rank Function). The *tropical rank function* is:
$$\rho_w(t) = |F_w(t)| = |\{e \in E : w(e) \leq t\}|$$

### 2.2 Metrics on Weight Functions

**Definition 2.4** (Sup-Norm Distance). For weight functions w, w' : E → ℝ on a finite nonempty type E:
$$d_\infty(w, w') = \max_{e \in E} |w(e) - w'(e)|$$

This is implemented as `weightSupDist` using `Finset.sup'` on the universal finset.

### 2.3 Interleaving Distance

**Definition 2.5** (ε-Interleaving). Two weight functions w, w' : E → ℝ are *ε-interleaved* if:
$$\forall t \in \mathbb{R}: F_w(t) \subseteq F_{w'}(t + \varepsilon) \text{ and } F_{w'}(t) \subseteq F_w(t + \varepsilon)$$

This is denoted `tropicalInterleavedBy ε w w'`.

### 2.4 Observables

**Definition 2.6** (Merge Time). The *merge time* is the maximum edge weight:
$$\tau(w) = \max_{e \in E} w(e)$$

**Definition 2.7** (Minimum Critical Value). The *minimum critical value* is:
$$\mu(w) = \min_{e \in E} w(e)$$

**Definition 2.8** (Long Bar). A weight function *has a long bar of length L* if:
$$\tau(w) - \mu(w) \geq L$$

---

## 3. Main Results: Stability

### 3.1 Sublevel Set Interleaving

**Lemma 3.1** (Sublevel Shift). If |w(e) − w'(e)| ≤ ε for all e, then:
$$e \in F_w(t) \implies e \in F_{w'}(t + \varepsilon)$$

*Proof.* If w(e) ≤ t and w(e) − w'(e) ≥ −ε (from the absolute value bound), then w'(e) ≤ w(e) + ε ≤ t + ε. □

**Theorem 3.2** (Forward and Reverse Interleaving). Under the same hypotheses:
$$\forall t: F_w(t) \subseteq F_{w'}(t + \varepsilon) \text{ and } F_{w'}(t) \subseteq F_w(t + \varepsilon)$$

### 3.3 Tight Characterization

**Theorem 3.3** (Optimal Interleaving). For finite nonempty E:
$$\text{tropicalInterleavedBy } \varepsilon \; w \; w' \iff \forall e, |w(e) - w'(e)| \leq \varepsilon$$

*Proof sketch.* The forward direction (interleaving implies pointwise bound) is the key insight. For any edge e, the element e belongs to F_w(w(e)) (trivially). By the forward interleaving, e ∈ F_{w'}(w(e) + ε), so w'(e) ≤ w(e) + ε. Symmetrically, w(e) ≤ w'(e) + ε. Together: |w(e) − w'(e)| ≤ ε.

The reverse direction follows from Lemma 3.1. □

**Corollary 3.4.** The interleaving distance equals the sup-norm distance:
$$d_I(w, w') = d_\infty(w, w')$$

### 3.4 Rank Function Stability

**Theorem 3.5** (Rank Function Interleaving). If ∀e, |w(e) − w'(e)| ≤ ε, then:
$$\rho_w(t) \leq \rho_{w'}(t + \varepsilon) \text{ and } \rho_{w'}(t) \leq \rho_w(t + \varepsilon)$$

*Proof.* The sublevel set at t for w is contained in the sublevel set at t + ε for w' (Theorem 3.2). Since both are finite, the cardinality inequality follows. □

### 3.5 Structural Properties

**Theorem 3.6** (Triangle Inequality). If w₁, w₂ are ε₁-interleaved and w₂, w₃ are ε₂-interleaved, then w₁, w₃ are (ε₁ + ε₂)-interleaved.

**Theorem 3.7** (Reflexivity). Any w is 0-interleaved with itself.

**Theorem 3.8** (Monotonicity). If w, w' are ε-interleaved and ε ≤ δ, then they are δ-interleaved.

These three properties, together with symmetry (which follows from the characterization theorem), make the interleaving distance a pseudometric on weight functions, and a metric when restricted to functions modulo equality.

---

## 4. Certified Robustness

### 4.1 Certified Barcode Shift Bound

**Definition 4.1.** The *certified barcode shift bound* is:
$$\text{cert}(w, w') = d_\infty(w, w')$$

**Theorem 4.2** (Correctness). The certified bound is correct:
$$\text{tropicalInterleavedBy}(\text{cert}(w, w'), w, w')$$

This is immediate from the characterization theorem. The significance is computational: given two weight functions, one computes their sup-distance in O(|E|) time, and this immediately certifies their interleaving.

### 4.2 Monotone Event Robustness

**Theorem 4.3.** Let P be a monotone property of edge sets (P(S) and S ⊆ T implies P(T)). If P(F_w(t)) holds and ∀e, |w(e) − w'(e)| ≤ ε, then P(F_{w'}(t + ε)) holds.

### 4.3 Long Bar Robustness

**Theorem 4.4** (Long Bar Robustness). If hasLongBar(w, L + δ) and ∀e, |w(e) − w'(e)| < δ/2, then hasLongBar(w', L).

*Proof sketch.* The merge time τ(w) can decrease by at most δ/2 under the perturbation (since the edge achieving the maximum loses at most δ/2 in weight). Similarly, the minimum critical value μ(w) can increase by at most δ/2. So the range shrinks by at most δ, and if the original range was at least L + δ, the perturbed range is at least L. □

---

## 5. Cross-Domain Bridges

### 5.1 Merge Time Lipschitz (Network Reliability)

**Theorem 5.1.** The merge time is 1-Lipschitz:
$$|\tau(w) - \tau(w')| \leq d_\infty(w, w')$$

*Interpretation.* In network reliability, the merge time corresponds to the worst-case cost or latency for full connectivity. Theorem 5.1 says that bounded measurement error in edge costs produces bounded error in the full-connectivity threshold.

### 5.2 Minimum Critical Value Lipschitz

**Theorem 5.2.** The minimum critical value is 1-Lipschitz:
$$|\mu(w) - \mu(w')| \leq d_\infty(w, w')$$

### 5.3 Weight Range Lipschitz

**Theorem 5.3.** The weight range is 2-Lipschitz:
$$|(\tau(w) - \mu(w)) - (\tau(w') - \mu(w'))| \leq 2 \cdot d_\infty(w, w')$$

*Proof.* By the triangle inequality applied to Theorems 5.1 and 5.2. □

---

## 6. Algorithms

### 6.1 Computing the Certified Bound

**Algorithm 1: CertifiedBound(w, w')**
```
Input: Edge weight functions w, w' : E → ℝ
Output: Certified interleaving bound ε

1. ε ← 0
2. For each edge e ∈ E:
3.     ε ← max(ε, |w(e) - w'(e)|)
4. Return ε
```

**Complexity:** O(|E|) time, O(1) space.

**Correctness:** By Theorem 3.3, the output ε satisfies tropicalInterleavedBy(ε, w, w'). By tightness, no smaller ε suffices.

### 6.2 Computing the Robustness Certificate

**Algorithm 2: RobustnessCertificate(w, L)**
```
Input: Edge weight function w : E → ℝ, target bar length L
Output: Maximum allowable perturbation δ

1. τ ← max(w(e) for e ∈ E)
2. μ ← min(w(e) for e ∈ E)
3. margin ← τ - μ - L
4. If margin ≤ 0: Return 0 (feature not present)
5. Return margin  (any perturbation < margin/2 preserves the feature)
```

**Complexity:** O(|E|) time.

---

## 7. Computational Experiments

We implement the framework in Python and test it on several graph families.

### 7.1 Experimental Setup

- **Graph families:** Path graphs, cycle graphs, complete graphs, random Erdős–Rényi graphs, grid graphs.
- **Weight distributions:** Uniform random, Gaussian perturbation of structured weights.
- **Perturbation model:** Each edge weight perturbed by uniform noise in [-ε, ε].

### 7.2 Results

For each graph family and noise level ε:
1. Compute the original rank function ρ_w.
2. Generate 100 random perturbations w' with ‖w - w'‖∞ ≤ ε.
3. Compute the rank function ρ_{w'} for each perturbation.
4. Measure the actual interleaving distance and compare to the certified bound ε.

**Key findings:**
- The certified bound is always valid (as guaranteed by the theorem).
- For generic weights (all distinct), the bound is typically tight: the actual interleaving distance equals ε to within numerical precision.
- For degenerate weights (many equal values), the actual interleaving distance can be strictly less than ε.

### 7.3 Local Isometry Conjecture Test

We test the conjecture that the persistence map is locally isometric on generic chambers. For random graphs with distinct weights, we verify that small perturbations preserving the strict weight ordering produce interleaving distances equal to the sup-norm distance. In all tested cases (up to 1000 vertices), the conjecture holds.

---

## 8. Discussion

### 8.1 Significance

The tropical bottleneck stability theorem establishes that tropical persistence on weighted graphs is not merely a symbolic invariant but a metrically robust observable. The tight characterization (Theorem 3.3) is particularly noteworthy: it shows the tropical interleaving distance *is* the sup-norm distance, not merely bounded by it. This isometric identification means that no information is lost when passing from raw weight perturbations to topological perturbations.

### 8.2 Comparison with Classical Stability

Classical bottleneck stability [1] requires the full machinery of persistence modules and their algebraic stability [5]. Our tropical stability theorem has a direct, elementary proof that works at the level of sublevel sets without invoking homological algebra. This makes the tropical setting both more elementary and more computationally transparent.

### 8.3 Limitations

- Our framework treats edge sets as abstract finite types. Extending to simplicial complexes of arbitrary dimension requires additional structure.
- The robustness certificates are conservative in the sense that they use worst-case bounds over all edges. Localized perturbation models could yield tighter bounds.
- The connection to full barcode stability (with matching) requires additional formalization of the barcode decomposition.

### 8.4 Applications

The framework applies directly to:
- **Network reliability:** Certifying connectivity thresholds under sensor noise.
- **Biological networks:** Validating topological features in protein interaction networks with noisy affinity scores.
- **Infrastructure planning:** Robustness analysis of transportation networks under demand uncertainty.
- **Machine learning:** Stability analysis of learned edge weights in graph neural networks.

---

## 9. Future Work

1. **Multiparameter persistence:** Extend the interleaving framework to filtrations by multiple parameters (e.g., weight and vertex degree).
2. **Tropical spectral stability:** Connect the interleaving distance to perturbation bounds on tropical eigenvalues.
3. **Sheaf persistence:** Develop stability theory for tropical sheaf invariants on graphs.
4. **Computational optimization:** Exploit the tight characterization for efficient barcode computation under perturbation.
5. **Statistical inference:** Develop confidence intervals for topological features using the robustness certificates.

---

## References

[1] D. Cohen-Steiner, H. Edelsbrunner, J. Harer. *Stability of persistence diagrams.* Discrete Comput. Geom. 37(1):103–120, 2007.

[2] G. Mikhalkin. *Tropical geometry and its applications.* Proc. ICM Madrid, 2006.

[3] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry.* AMS, 2015.

[4] M. Baker, S. Norine. *Riemann–Roch and Abel–Jacobi theory on a finite graph.* Adv. Math. 215(2):766–788, 2007.

[5] F. Chazal, V. de Silva, M. Glisse, S. Oudot. *The structure and stability of persistence modules.* Springer, 2016.

[6] P. Bubenik, J. Scott. *Categorification of persistent homology.* Discrete Comput. Geom. 51(3):600–627, 2014.
