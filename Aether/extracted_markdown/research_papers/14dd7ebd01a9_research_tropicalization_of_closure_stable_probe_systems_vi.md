# Tropicalization of Closure-Stable Probe Systems via Valuation Certificates

## Abstract

We establish a formal bridge between filtered closure systems equipped with semiring-valued probes and tropical (min-plus) algebra via valuation certificates. Our central result is the **tropical reconstruction formula**: for a filtered closure system with scale-indexed closures, the tropical (infimum) profile of a probe at a coarse scale decomposes as the infimum of the profile at a finer scale and the tropical defect value. This formula, together with the **tropical defect decomposition** and **tropical telescope** theorems, provides an algorithmic pipeline for reducing set-theoretic closure reconstruction to min-plus arithmetic. We prove that closure stability descends through valuation certificates, that tropical profiles are antitone in scale, and that strict defect bounds imply strict profile drops. All results are machine-verified in Lean 4 with Mathlib, with zero remaining proof obligations.

**Keywords:** tropical algebra, min-plus semiring, filtered closure systems, scale defects, valuation certificates, reconstruction algorithms, closure-stable probes, formal verification

## 1. Introduction

### 1.1 Motivation

Filtered closure systems arise naturally in renormalization group theory, hierarchical clustering, coarse-graining, and the study of emergent phenomena. A *closure operator* at each scale expands a seed set to include all elements that are "reachable" or "entailed" at that resolution. The *defect* between two scales — the new elements appearing at the coarser scale — captures the incremental information gained.

The reconstruction theorem [FilteredClosureReconstruction] shows that the closure at any scale can be recovered from the closure at a finer scale plus the defect. This is a set-theoretic identity:

$$\mathrm{cl}_s(A) = \mathrm{cl}_r(A) \cup D(r,s)$$

where $D(r,s) = \mathrm{cl}_s(A) \setminus \mathrm{cl}_r(A)$.

Our contribution is to show that this reconstruction has a natural *tropical shadow*: when the elements are measured by a probe function $p : \alpha \to T$ into a linearly ordered type, the infimum of $p$ over the closure decomposes as:

$$\inf_{\mathrm{cl}_s(A)} p = \inf_{\mathrm{cl}_r(A)} p \wedge \inf_{D(r,s)} p$$

This is the **tropical reconstruction formula**, and it reduces set-theoretic reconstruction to min-plus arithmetic.

### 1.2 Related Work

The connection between valuations and tropical geometry is classical, dating to the work of Kapranov, Mikhalkin, and Sturmfels on tropical algebraic geometry. The use of valuations as functors from multiplicative to additive structure appears in p-adic analysis and Berkovich spaces. Our work differs in applying tropical methods specifically to the *probe/reconstruction* setting of closure systems, rather than to polynomial ideals or varieties.

The filtered closure reconstruction framework builds on prior work formalizing scale-indexed closure operators with extensivity, monotonicity, idempotency, scale-monotonicity, and absorption axioms.

### 1.3 Contributions

1. **TropicalProbeCertificate**: A minimal certificate structure ensuring that valuation maps preserve probe equality, enabling systematic tropicalization.

2. **Tropical Reconstruction Formula** (Theorem 3): The central identity connecting set-theoretic closure decomposition to min-plus profile decomposition.

3. **Tropical Defect Decomposition** (Theorem 4): The defect value across three scales decomposes via infimum, enabling telescopic reconstruction.

4. **Strict Drop Criterion** (Theorem 5): A tight characterization of when tropical profiles strictly decrease across scale transitions.

5. **Iterated Reconstruction and Telescope** (Theorems 7, 12): Multi-scale reconstruction via chains of infima.

6. **Complete machine verification**: All 13 theorems verified in Lean 4 with zero sorry obligations.

## 2. Definitions

### 2.1 Filtered Closure Systems

**Definition 2.1** (Filtered Closure System). Let $\alpha$ be a finite type (elements) and $\sigma$ a linearly ordered finite type (scales). A *filtered closure system* is a family of operators $\mathrm{cl}_r : \mathcal{P}(\alpha) \to \mathcal{P}(\alpha)$ for $r \in \sigma$ satisfying:

1. **Extensivity**: $A \subseteq \mathrm{cl}_r(A)$
2. **Set-monotonicity**: $A \subseteq B \implies \mathrm{cl}_r(A) \subseteq \mathrm{cl}_r(B)$
3. **Idempotency**: $\mathrm{cl}_r(\mathrm{cl}_r(A)) = \mathrm{cl}_r(A)$
4. **Scale-monotonicity**: $r \le s \implies \mathrm{cl}_r(A) \subseteq \mathrm{cl}_s(A)$
5. **Absorption**: $r \le s \implies \mathrm{cl}_s(\mathrm{cl}_r(A)) = \mathrm{cl}_s(A)$

**Definition 2.2** (Scale Defect). The *defect* between scales $r$ and $s$ for seed $A$ is:
$$D(r,s; A) = \mathrm{cl}_s(A) \setminus \mathrm{cl}_r(A)$$

### 2.2 Closure-Stable Probes

**Definition 2.3** (Closure-Stable Probe). A function $p : \alpha \to T$ is *closure-stable* for a filtered closure system if for every scale $r$, seed $A$, and element $x \in \mathrm{cl}_r(A)$, there exists $y \in A$ with $p(x) = p(y)$.

Closure stability means the probe cannot distinguish elements in the closure from elements in the seed — it is a form of observational invariance.

### 2.3 Tropical Probe Certificate

**Definition 2.4** (Tropical Probe Certificate). A *tropical probe certificate* for a map $v : K \to T$ consists of:
- The valuation map $v$
- A proof that $v$ respects equality: $a = b \implies v(a) = v(b)$

This minimal certificate is sufficient for all our tropicalization results. It is a restricted version of a full tropical valuation functor, specialized to the probe setting.

### 2.4 Tropical Probe Profile and Defect Value

**Definition 2.5** (Tropical Probe Profile). For a filtered closure system $F$, probe $p : \alpha \to T$, seed $A$, and scale $r$:
$$\mathrm{prof}(r) = \inf_{x \in \mathrm{cl}_r(A)} p(x) \in T \cup \{+\infty\}$$

**Definition 2.6** (Tropical Defect Value). The *tropical defect value* between scales $r$ and $s$:
$$\mathrm{dv}(r,s) = \inf_{x \in D(r,s; A)} p(x) \in T \cup \{+\infty\}$$

## 3. Main Results

### 3.1 Valued Probe Closure Stability (Theorem 1)

**Theorem 3.1.** If $p : \alpha \to K$ is closure-stable and $v : K \to T$ is a tropical probe certificate, then $v \circ p : \alpha \to T$ is closure-stable.

*Proof.* Let $x \in \mathrm{cl}_r(A)$. By closure stability of $p$, there exists $y \in A$ with $p(x) = p(y)$. By the certificate property, $v(p(x)) = v(p(y))$, so $(v \circ p)(x) = (v \circ p)(y)$. □

This theorem is the functorial foundation: it ensures that tropicalization preserves the observational invariance that makes probes useful.

### 3.2 Tropical Profile Antitonicity (Theorem 2)

**Theorem 3.2.** The tropical profile $r \mapsto \mathrm{prof}(r)$ is antitone: if $r \le s$ then $\mathrm{prof}(s) \le \mathrm{prof}(r)$.

*Proof.* By scale-monotonicity, $\mathrm{cl}_r(A) \subseteq \mathrm{cl}_s(A)$. Taking the infimum over a larger set can only decrease the value. □

### 3.3 Tropical Reconstruction Formula (Theorem 3)

**Theorem 3.3.** For $r \le s$:
$$\mathrm{prof}(s) = \mathrm{prof}(r) \wedge \mathrm{dv}(r,s)$$

*Proof.* By the closure decomposition $\mathrm{cl}_s(A) = \mathrm{cl}_r(A) \cup D(r,s)$, and the identity $\inf_{X \cup Y} f = (\inf_X f) \wedge (\inf_Y f)$ for finsets. □

This is the central result: it translates set-theoretic union into lattice infimum, connecting closure reconstruction to min-plus arithmetic.

### 3.4 Tropical Defect Decomposition (Theorem 4)

**Theorem 3.4.** For $r \le s \le t$:
$$\mathrm{dv}(r,t) = \mathrm{dv}(r,s) \wedge \mathrm{dv}(s,t)$$

*Proof.* By the set-theoretic defect decomposition $D(r,t) = D(r,s) \cup D(s,t)$ and the infimum-over-union identity. □

### 3.5 Strict Drop Criterion (Theorem 5)

**Theorem 3.5.** If $\mathrm{dv}(r,s) < \mathrm{prof}(r)$ and $r \le s$, then $\mathrm{prof}(s) < \mathrm{prof}(r)$.

*Proof.* By the reconstruction formula, $\mathrm{prof}(s) = \mathrm{prof}(r) \wedge \mathrm{dv}(r,s) \le \mathrm{dv}(r,s) < \mathrm{prof}(r)$. □

This gives a precise computational criterion for detecting non-trivial scale transitions.

### 3.6 Tropical Absorption (Theorem 6)

**Theorem 3.6.** For $r \le s$:
$$\inf_{\mathrm{cl}_s(\mathrm{cl}_r(A))} p = \mathrm{prof}(s)$$

*Proof.* By the absorption axiom, $\mathrm{cl}_s(\mathrm{cl}_r(A)) = \mathrm{cl}_s(A)$. □

### 3.7 Iterated Reconstruction and Telescope (Theorems 7, 12)

**Theorem 3.7.** For $r \le s \le t$:
$$\mathrm{prof}(t) = \mathrm{prof}(r) \wedge \mathrm{dv}(r,s) \wedge \mathrm{dv}(s,t)$$

*Proof.* Apply the reconstruction formula twice and use defect decomposition. □

**Theorem 3.8** (Telescope). For $r \le s \le t$:
$$\mathrm{prof}(t) = (\mathrm{prof}(r) \wedge \mathrm{dv}(r,s)) \wedge \mathrm{dv}(s,t)$$

The parenthesization matters: the inner expression is $\mathrm{prof}(s)$ by the reconstruction formula, and the outer application gives $\mathrm{prof}(t)$.

### 3.8 Additional Results

- **Theorem 8** (Family Closure Stability): All probes in a closure-stable family have closure-stable tropical images.
- **Theorem 9** (Defect Antitonicity): The tropical defect value is antitone in the upper scale and monotone in the lower scale.
- **Theorem 10** (Tropical Idempotency): Double closure produces the same tropical profile.
- **Theorem 11** (Consistency): The tropical reconstruction is consistent with set-theoretic reconstruction.
- **Theorem 13** (Seed Monotonicity): Enlarging the seed can only decrease the tropical profile.

## 4. Algorithms

### 4.1 Telescopic Tropical Reconstruction

**Input:** Filtered closure system $F$, probe $p$, seed $A$, sorted scales $r_0 < r_1 < \cdots < r_n$.

**Output:** Tropical profile at each scale.

```
prof[0] ← inf_{cl_{r_0}(A)} p
for i = 1 to n:
    dv ← inf_{D(r_{i-1}, r_i; A)} p
    prof[i] ← min(prof[i-1], dv)
return prof
```

**Complexity:** $O(n \cdot d_{\max})$ where $d_{\max}$ is the maximum defect size, versus $O(n \cdot c_{\max})$ for naive profile computation where $c_{\max}$ is the maximum closure size. When defects are sparse (as in most physical systems), this is a significant improvement.

### 4.2 Strict Drop Detection

**Input:** Tropical profiles and defect values.

**Output:** All scale transitions with strict drops.

```
drops ← ∅
for i = 1 to n:
    if dv(r_{i-1}, r_i) < prof[i-1]:
        drops ← drops ∪ {(r_{i-1}, r_i, prof[i-1] - prof[i])}
return drops
```

## 5. Applications

### 5.1 Renormalization Group Flow

In statistical physics, the filtered closure system models the renormalization group: at each energy scale, the closure includes all effective interactions visible at that resolution. The tropical profile of a coupling constant probe gives the minimum effective coupling at each scale. The reconstruction formula shows that this minimum evolves by taking minimums with the defect contributions — precisely the structure of the Kadanoff-Wilson renormalization group in the tropical limit.

### 5.2 Feature Hierarchy in Neural Networks

In deep learning, each layer defines a closure of "reachable" features. The tropical profile of a margin probe (measuring classification confidence) gives the worst-case margin at each depth. The strict drop criterion identifies the critical layers where new features materially affect classification.

### 5.3 Phylogenetic Reconstruction

In phylogenetics, filtered closures model clades at different taxonomic ranks. The tropical profile of a genetic distance probe gives the minimum divergence within each clade. The defect decomposition enables efficient bottom-up reconstruction of divergence profiles.

## 6. Discussion

### 6.1 Relationship to Tropical Valuation Functors

Our tropical probe certificate is deliberately more restrictive than a full tropical valuation functor. A full functor would require $v(a \cdot b) = v(a) + v(b)$ and $v(a + b) \ge \min(v(a), v(b))$ — the classical properties of a non-Archimedean valuation. Our certificate only requires $v$ to respect equality, which is sufficient for all probe-based tropicalization results. This minimality is a feature: it means the theory applies even when the probe values don't form a semiring.

### 6.2 The Role of Absorption

The absorption axiom is crucial for the tropical framework. Without it, the tropical telescope would not hold: intermediate-scale closures would leave artifacts in the tropical profile. Absorption ensures that the tropical reconstruction pipeline is memoryless — only the current scale and the defect matter, not the history of intermediate closures.

### 6.3 Computational Complexity

The tropical reconstruction reduces the computation of n scale profiles from $O(n \cdot |\alpha|)$ (computing each closure from scratch) to $O(n \cdot d_{\max})$ (incremental defect computation). For systems where defects are logarithmically sized (as in many physics applications), this is an exponential improvement.

## 7. Conjecture

**Conjecture** (Tropical Probe Separation). For any filtered closure system $F$ on a finite type $\alpha$ with at least two elements, there exists a probe $p : \alpha \to \mathbb{Z}$ such that the tropical profile function $r \mapsto \mathrm{prof}(r)$ is injective on the set of scales where the closure strictly grows.

**Test:** Enumerate all probes on small types ($|\alpha| \le 6$, $|\sigma| \le 4$) and check whether an injective-on-strict-growth probe always exists. A counterexample would be a system where every probe has the same tropical profile drop at two different scale transitions.

## 8. Formal Verification

All 13 theorems and their supporting lemmas have been formally verified in Lean 4 using the Mathlib library. The verification uses only standard axioms (propext, Classical.choice, Quot.sound) and contains zero sorry obligations. The key definitions and theorems are in `Bridges/TropicalProbeValuation.lean`.

## References

1. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
2. Mikhalkin, G. "Enumerative tropical algebraic geometry in ℝ²." *J. Amer. Math. Soc.*, 2005.
3. Simon, I. "Recognizable sets with multiplicities in the tropical semiring." *MFCS*, 1988.
4. Viro, O. "Dequantization of real algebraic geometry on logarithmic paper." *European Congress of Mathematics*, 2001.
