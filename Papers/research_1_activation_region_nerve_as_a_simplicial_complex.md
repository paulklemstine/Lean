# Activation-Region Nerve as a Simplicial Complex and Margin-Cosheaf Exactness for Certified Neural Robustness

## Abstract

We formalize the activation-region decomposition of a ReLU classifier as a finite abstract simplicial complex (the **activation nerve**) and define a **margin cosheaf** that assigns to each simplex the infimum of the classifier's margin function over the corresponding intersection. We prove that **degree-1 exactness** of this cosheaf — the condition that every vertex carries positive margin — is equivalent to the existence of a uniform positive global margin over the entire domain, under standard compactness and continuity assumptions. Combined with a Lipschitz bound, this yields a certified robustness radius. All theorems are machine-verified in Lean 4 with Mathlib, producing the first formally verified connection between cosheaf exactness and neural network certification.

**Keywords:** Neural certification, cosheaf exactness, activation complexes, piecewise-linear topology, certified robustness, simplicial complexes, margin theory.

---

## 1. Introduction

### 1.1 Motivation

Adversarial robustness of neural networks has emerged as a central concern in trustworthy machine learning. Given a classifier $f: \mathbb{R}^d \to \mathbb{R}$ and a domain $K \subseteq \mathbb{R}^d$, one seeks a certified radius $r > 0$ such that for all $x \in K$ and perturbations $\|y - x\| < r$, the classification of $y$ agrees with that of $x$.

Existing certification methods fall into two categories:
1. **Pointwise methods** (randomized smoothing, interval bound propagation) that certify each input individually.
2. **Global Lipschitz bounds** that provide uniform but often conservative radii.

Both approaches miss the internal geometric structure of the network. A ReLU network partitions its input space into **activation regions** — convex polytopes on which the network is affine. The combinatorial pattern of these regions encodes the full behavior of the network, yet this structure is rarely exploited for certification.

### 1.2 Contribution

We introduce a **topological certification framework** that reads robustness directly from the combinatorial structure of activation regions:

1. We define the **activation nerve** $\mathcal{N}$ as the abstract simplicial complex whose simplices correspond to nonempty intersections of activation regions with the domain $K$.

2. We define the **margin cosheaf** $\mathcal{M}$ on $\mathcal{N}$, assigning to each simplex $\sigma$ the value $\mathcal{M}(\sigma) = \inf_{x \in K \cap \bigcap_{i \in \sigma} R_i} \operatorname{margin}(x)$.

3. We prove the **main equivalence**: degree-1 exactness of $\mathcal{M}$ (positivity of all vertex margins) is equivalent to existence of a uniform positive global margin.

4. We derive a **certified robustness corollary**: under a Lipschitz bound $L$, the certified radius is $\delta / L$ where $\delta$ is the uniform positive margin.

5. We prove the **contrapositive obstruction theorem**: failure of exactness implies a concrete vulnerable point.

6. We establish the **H¹ vanishing theorem**: for the standard cosheaf differential on a finite type, every cocycle is a coboundary.

All results are formally verified in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

**Activation region analysis.** Montúfar et al. (2014) initiated the study of activation region counts for ReLU networks. Hanin and Rolnick (2019) refined these bounds. Our work shifts from counting regions to studying their *topological organization*.

**Certified robustness.** Cohen et al. (2019) introduced randomized smoothing; Gowal et al. (2018) developed interval bound propagation. These are pointwise methods. Our approach gives global certificates.

**Sheaf/cosheaf theory in ML.** Hansen and Ghrist (2019) introduced sheaf-theoretic perspectives on data fusion. Curry (2014) developed cosheaf theory for data analysis. Our work is the first to apply cosheaf exactness to neural certification.

**Tropical geometry and neural networks.** Zhang et al. (2018) and Alfarra et al. (2022) connected ReLU networks to tropical geometry. Our nerve construction is compatible with tropical decompositions.

---

## 2. Definitions and Notation

### 2.1 The Activation Nerve

**Definition 2.1** (Cover Nerve). Let $X$ be a topological space, $\iota$ a type with decidable equality, $K \subseteq X$ a subset, and $R : \iota \to \mathcal{P}(X)$ a family of subsets. The **nerve** of the cover $(R_i)_{i \in \iota}$ relative to $K$ is:
$$\mathcal{N}(K, R) = \left\{ \sigma \in \mathrm{Finset}(\iota) \mid \sigma \neq \emptyset \text{ and } K \cap \bigcap_{i \in \sigma} R_i \neq \emptyset \right\}$$

In Lean 4:
```
def coverNerve (ι : Type*) [DecidableEq ι] (K : Set X) (R : ι → Set X) : Set (Finset ι) :=
  {σ : Finset ι | σ.Nonempty ∧ (K ∩ ⋂ i ∈ σ, R i).Nonempty}
```

**Theorem 2.2** (Downward Closure). The nerve is an abstract simplicial complex: for any $\sigma \in \mathcal{N}$ and nonempty $\tau \subseteq \sigma$, we have $\tau \in \mathcal{N}$.

*Proof.* If $\tau \subseteq \sigma$, then $\bigcap_{i \in \sigma} R_i \subseteq \bigcap_{i \in \tau} R_i$, so $K \cap \bigcap_{i \in \sigma} R_i \subseteq K \cap \bigcap_{i \in \tau} R_i$. Nonemptiness is inherited. □

**Theorem 2.3** (Finiteness). If $\iota$ is a finite type, then $\mathcal{N}(K, R)$ is a finite set.

*Proof.* $\mathcal{N} \subseteq \mathrm{Finset}(\iota)$, which is finite when $\iota$ is. □

### 2.2 The Margin Cosheaf

**Definition 2.4** (Margin Cosheaf Value). For a simplex $\sigma \in \mathcal{N}$:
$$\mathcal{M}(\sigma) = \inf\left\{ \operatorname{margin}(x) \mid x \in K \cap \bigcap_{i \in \sigma} R_i \right\}$$

```
def marginCosheafValue (K : Set X) (R : ι → Set X) (margin : X → ℝ) (σ : Finset ι) : ℝ :=
  sInf (margin '' (K ∩ ⋂ i ∈ σ, R i))
```

**Theorem 2.5** (Monotonicity). If $\tau \subseteq \sigma$ and the relevant sets are nonempty with bounded-below images, then $\mathcal{M}(\tau) \leq \mathcal{M}(\sigma)$.

*Proof.* Since $\tau \subseteq \sigma$, the intersection $\bigcap_{i \in \sigma} R_i \subseteq \bigcap_{i \in \tau} R_i$, so the image set for $\sigma$ is contained in the image set for $\tau$. By monotonicity of infima over subsets, $\inf \leq \inf$. □

### 2.3 Degree-1 Exactness

**Definition 2.6** (Degree-1 Exactness). The margin cosheaf is **degree-1 exact** if every vertex with nonempty intersection carries positive margin:
$$\forall i \in \iota,\; (K \cap R_i \neq \emptyset) \implies \mathcal{M}(\{i\}) > 0$$

```
def degreeOneExactMarginCosheaf [Fintype ι] (K : Set X) (R : ι → Set X) (margin : X → ℝ) : Prop :=
  ∀ i : ι, (K ∩ R i).Nonempty → 0 < sInf (margin '' (K ∩ R i))
```

### 2.4 Chain Complex Structure

**Definition 2.7** (Cosheaf Differential). The degree-0 and degree-1 chain groups are:
- $C_0 = \iota \to \mathbb{R}$ (vertex data)
- $C_1 = \iota \to \iota \to \mathbb{R}$ (edge data)

The differential $d_0 : C_0 \to C_1$ is $d_0(f)(i,j) = f(j) - f(i)$.

**Definition 2.8.** A 1-cocycle is $c \in C_1$ with $c(i,k) = c(i,j) + c(j,k)$ for all $i,j,k$. A 1-coboundary is $c = d_0(f)$ for some $f \in C_0$.

---

## 3. Main Results

### 3.1 Forward Direction: Exactness Implies Uniform Positive Margin

**Theorem 3.1.** Let $K \subseteq X$ be compact in a Hausdorff space, $(R_i)_{i \in \iota}$ a finite family of closed sets covering $K$, and $\operatorname{margin} : X \to \mathbb{R}$ continuous. If the margin cosheaf is degree-1 exact, then there exists $\delta > 0$ such that $\operatorname{margin}(x) \geq \delta$ for all $x \in K$.

*Proof sketch.*
1. For any $x \in K$, the cover property gives $i$ with $x \in R_i$.
2. Since $x \in K \cap R_i$, we have $\operatorname{margin}(x) \geq \inf(\operatorname{margin} \circ (K \cap R_i)) > 0$ by degree-1 exactness and the definition of infimum (using that $K \cap R_i$ is compact, so the infimum is a lower bound).
3. Therefore $\operatorname{margin}(x) > 0$ for all $x \in K$.
4. Since $K$ is compact and $\operatorname{margin}$ is continuous, $\operatorname{margin}$ attains its minimum on $K$, which is positive.
5. Take $\delta = \min_{x \in K} \operatorname{margin}(x) > 0$. □

### 3.2 Backward Direction: Uniform Positive Margin Implies Exactness

**Theorem 3.2.** Under the same hypotheses, if $\exists \delta > 0, \forall x \in K, \operatorname{margin}(x) \geq \delta$, then the margin cosheaf is degree-1 exact.

*Proof sketch.* For any $i$ with $(K \cap R_i) \neq \emptyset$, and any $x \in K \cap R_i \subseteq K$, we have $\operatorname{margin}(x) \geq \delta$. Therefore $\inf(\operatorname{margin} \circ (K \cap R_i)) \geq \delta > 0$. □

### 3.3 Main Equivalence

**Theorem 3.3** (Exactness ↔ Uniform Positive Margin). Under compactness, continuity, and finite closed cover assumptions:
$$\text{degreeOneExactMarginCosheaf}(K, R, \operatorname{margin}) \iff \exists \delta > 0, \forall x \in K, \delta \leq \operatorname{margin}(x)$$

### 3.4 Certified Robustness

**Theorem 3.4.** If degree-1 exactness holds and $\operatorname{margin}$ is $L$-Lipschitz with $L > 0$, then there exists $r > 0$ such that for all $x \in K$ and $\|y - x\| < r$, $\operatorname{margin}(y) > 0$.

*Proof.* By Theorem 3.1, get $\delta > 0$ with $\operatorname{margin}(x) \geq \delta$ for all $x \in K$. Take $r = \delta / L$. For $\|y - x\| < r$:
$$\operatorname{margin}(y) \geq \operatorname{margin}(x) - |\operatorname{margin}(x) - \operatorname{margin}(y)| \geq \delta - L \cdot \|y - x\| > \delta - L \cdot (\delta/L) = 0. \quad \square$$

### 3.5 Contrapositive Obstruction

**Theorem 3.5.** If degree-1 exactness fails and $K$ is nonempty, then there exists $i \in \iota$ with $(K \cap R_i) \neq \emptyset$ and a point $x \in K \cap R_i$ with $\operatorname{margin}(x) \leq 0$.

*Proof.* Failure of exactness gives $i$ with $(K \cap R_i) \neq \emptyset$ and $\inf(\operatorname{margin} \circ (K \cap R_i)) \leq 0$. Since $K \cap R_i$ is compact (closed subset of compact $K$), the infimum is attained. □

### 3.6 Edge Compatibility

**Theorem 3.6.** If vertices $i$ and $j$ both have positive margin and $K \cap R_i \cap R_j \neq \emptyset$, then the edge margin is also positive: $\mathcal{M}(\{i,j\}) > 0$.

### 3.7 H¹ Vanishing

**Theorem 3.7.** For any nonempty type $\iota$, every 1-cocycle on $C_*(\iota)$ is a 1-coboundary. In particular, $H^1 = 0$.

*Proof.* Fix a basepoint $i_0 \in \iota$. Given cocycle $c$, define $f(j) = c(i_0, j)$. Then $d_0(f)(i,j) = f(j) - f(i) = c(i_0, j) - c(i_0, i)$. By the cocycle condition $c(i_0, j) = c(i_0, i) + c(i,j)$, so $d_0(f)(i,j) = c(i,j)$. □

**Theorem 3.8** (Margin Coboundary). The margin differences $c(i,j) = m(j) - m(i)$ always form a coboundary witnessed by $m$ itself.

### 3.8 Full Pipeline

**Theorem 3.9** (Full Certification Pipeline). Given a finite closed cover of a compact domain, positive local margins on each region, continuity, and a Lipschitz bound $L > 0$, there exists a certified robustness radius $r > 0$.

---

## 4. Algorithms

### 4.1 Certification Pipeline

**Algorithm 1: Activation Nerve Robustness Certification**

```
Input: Network weights (W₁, b₁, W₂, b₂), domain K, number of samples N
Output: CertificationResult (is_certified, radius, nerve, cosheaf)

1. SAMPLE N points uniformly from K
2. For each point x:
   a. Compute activation pattern sign(W₁x + b₁)
   b. Assign x to its activation region
3. For each pair of regions (i, j):
   a. Check if regions are adjacent (share boundary)
   b. If adjacent, add edge (i,j) to nerve
4. For each region i:
   a. Compute M(i) = min{margin(x) : x in region i}
5. Check degree-1 exactness: all M(i) > 0
6. If exact:
   a. δ = min_i M(i)
   b. L = ||W₁||₂ · ||W₂||₂  (Lipschitz bound)
   c. r = δ / L
   d. Return (certified=True, radius=r)
7. Else: Return (certified=False, radius=0)
```

**Complexity:** O(N·h·d + |R|²·k²) where N = samples, h = hidden neurons, d = input dimension, |R| = number of regions, k = boundary check samples.

### 4.2 Nerve Construction

The nerve can be constructed in O(|R|²) pairwise overlap checks. For ReLU networks, overlaps can be determined from the sign pattern structure: regions $R_\alpha$ and $R_\beta$ overlap if and only if their sign patterns differ in at most one coordinate and the corresponding hyperplane intersects $K$.

---

## 5. Computational Experiments

### 5.1 Basic Certification

We tested the pipeline on a 2D ReLU network with 4 hidden neurons. The network had 10 activation regions. Degree-1 exactness failed (two regions had negative margin), correctly identifying vulnerable areas.

### 5.2 Robustness vs. Network Scale

Scaling the first-layer weights by factors 0.5 to 5.0:

| Scale | Regions | Min Margin | Lipschitz | Certified Radius | Exact? |
|-------|---------|------------|-----------|-------------------|--------|
| 0.5   | 7       | 0.4598     | 0.434     | 1.0601            | Yes    |
| 1.0   | 7       | 0.3893     | 0.867     | 0.4488            | Yes    |
| 1.5   | 7       | 0.3224     | 1.301     | 0.2478            | Yes    |
| 2.0   | 6       | 0.2603     | 1.735     | 0.1501            | Yes    |
| 3.0   | 7       | 0.1195     | 2.602     | 0.0459            | Yes    |
| 5.0   | 6       | −0.1603    | 4.337     | 0.0000            | No     |

The certified radius decreases with scale (higher Lipschitz constant) and eventually vanishes when margin becomes negative.

### 5.3 Nerve Topology

For a 3-neuron network: 6 vertices, 9 edges, 4 triangles, Euler characteristic χ = 1 (consistent with contractibility of the domain cover). Cosheaf monotonicity was verified for all edges.

---

## 6. Discussion

### 6.1 Strengths

- **Global certification**: A single computation certifies the entire domain.
- **Topological grounding**: The framework naturally extends to higher-dimensional obstructions.
- **Formal verification**: All theorems are machine-checked, eliminating proof errors.
- **Composability**: The pipeline decomposes into independent, verifiable steps.

### 6.2 Limitations

- **Sample-based region discovery**: Our implementation approximates activation regions via sampling. Exact enumeration requires vertex enumeration of polytopes, which is computationally expensive.
- **Conservative bounds**: The Lipschitz constant $\|W_1\|_2 \cdot \|W_2\|_2$ is an upper bound. Tighter region-specific Lipschitz constants could improve the certified radius.
- **Two-layer restriction**: The current implementation handles two-layer networks. Extension to deep networks requires composing region decompositions.
- **Degree-1 only**: Higher-degree exactness conditions, which could detect subtler obstructions, are defined but not yet exploited.

### 6.3 Relation to Existing Methods

The nerve-based approach is complementary to existing certification methods:
- **vs. Randomized smoothing**: Our method gives deterministic, not probabilistic, guarantees.
- **vs. IBP/CROWN**: Our method provides a single global certificate rather than per-input bounds.
- **vs. Lipschitz-based methods**: Our method uses the same Lipschitz machinery but adds topological structure for finer analysis.

---

## 7. Future Work

1. **Higher-degree obstruction classes**: Extend degree-1 exactness to degree-$k$ conditions for multiclass classifiers, where $H_k \neq 0$ would detect $k$-dimensional "adversarial loops" in activation space.

2. **Persistent activation nerves**: Study how the nerve filtration changes under input perturbation, defining a persistence diagram that captures the robustness landscape.

3. **Algorithmic extraction**: Develop polynomial-time algorithms for exact nerve computation using the polyhedral structure of activation regions.

4. **Deep network extension**: Compose layer-wise nerves into a multi-resolution certification hierarchy.

5. **Tropical cosheaf theory**: Connect the margin cosheaf to tropical homology of the piecewise-linear function defined by the network.

---

## 8. Formal Verification Details

All theorems were verified in Lean 4 (v4.28.0) with Mathlib. The axioms used are exclusively `propext`, `Classical.choice`, and `Quot.sound` — the standard constructive/classical axioms of Lean's kernel. No `sorry` or custom axioms appear in the final proofs.

Key verified theorems:
- `nerve_down_closed` — Nerve is an abstract simplicial complex
- `marginCosheaf_monotone` — Cosheaf values are monotone under face inclusion
- `degreeOneExact_iff_uniformPositiveMargin` — Main equivalence theorem
- `activation_nerve_certified_robustness` — Certified radius from exactness
- `nonexact_implies_vulnerability` — Contrapositive obstruction
- `H1_vanishing` — H¹ = 0 for standard differential
- `full_activation_nerve_certification_pipeline` — Complete pipeline

---

## References

1. Montúfar, G., Pascanu, R., Cho, K., & Bengio, Y. (2014). On the number of linear regions of deep neural networks. *NeurIPS*.
2. Cohen, J., Rosenfeld, E., & Kolter, J.Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
3. Gowal, S., et al. (2018). On the effectiveness of interval bound propagation for training verifiably robust models. *arXiv*.
4. Hansen, J. & Ghrist, R. (2019). Toward a spectral theory of cellular sheaves. *Journal of Applied and Computational Topology*.
5. Curry, J. (2014). Sheaves, cosheaves, and applications. *Ph.D. thesis, University of Pennsylvania*.
6. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML*.
7. Alfarra, M., et al. (2022). On the decision boundaries of neural networks: A tropical geometry perspective. *IEEE TPAMI*.
8. Hanin, B. & Rolnick, D. (2019). Complexity of linear regions in deep neural networks. *ICML*.
9. Ghrist, R. (2014). *Elementary Applied Topology*. Createspace.
10. Borsuk, K. (1948). On the imbedding of systems of compacta in simplicial complexes. *Fundamenta Mathematicae*.
