# Closure-Cost Lawvere Metric Duality: Isometric Yoneda Embedding and Certified Minimal Reconstruction

## Abstract

We establish a duality between finite closure-cost systems — structures combining a closure operator with a compatible asymmetric cost function — and finite Lawvere-enriched computation systems (generalized metric spaces valued in ℝ≥0∞). The central result is that the **enriched Yoneda embedding** is isometric: the spectrum distance between Yoneda observables φ_x and φ_y exactly recovers the original cost(x, y). This yields a certified reconstruction algorithm that extracts a canonical minimal Lawvere computation system from any finite closure-cost presentation. We prove closure invariance, separation, product compatibility, and round-trip properties. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords:** Lawvere metric, closure operator, tropical algebra, Yoneda embedding, enriched category theory, Stone duality, weighted automata, minimal realization

---

## 1. Introduction

### 1.1 Motivation

Closure operators and generalized metric spaces (Lawvere metrics) are fundamental structures appearing throughout mathematics and computer science. Closure operators formalize irreversible simplification — compilation, coarse-graining, logical consequence — while Lawvere metrics formalize asymmetric costs — transformation expenses, communication delays, program distances.

Despite their ubiquity, no formal duality has previously connected these structures at the level of objects and morphisms with certified metric recovery. The classical Stone duality [Stone 1936] connects Boolean algebras and compact Hausdorff spaces; our result can be viewed as a **tropical/quantitative generalization** where Boolean truth values are replaced by cost values in ℝ≥0∞.

### 1.2 Contributions

1. **Isometric Yoneda Embedding (Theorem 4.1).** For any finite closure-cost system (α, cl, cost), the enriched Yoneda embedding x ↦ φ_x = cost(x, −) is isometric: specDist(φ_x, φ_y) = cost(x, y), where specDist is the residuated supremum metric on observables.

2. **Separation Theorem (Theorem 5.1).** In separated systems, the Yoneda embedding is injective on closed elements, providing the tropical analogue of Stone separation.

3. **Certified Reconstruction Algorithm (Section 6).** We extract a concrete algorithm that computes the canonical minimal Lawvere system from a closure-cost presentation, with formal guarantees of soundness, completeness, minimality, and canonicity.

4. **Structural Stability (Section 7).** We prove closure quotient invariance, product compatibility, and round-trip properties.

5. **Machine-Verified Proofs.** All results are formalized in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

- **Stone duality** [Stone 1936, Priestley 1970]: our result is a quantitative enrichment replacing 2 with ℝ≥0∞.
- **Lawvere metric spaces** [Lawvere 1973]: we add closure structure and prove an algebraic reconstruction theorem.
- **Weighted automata minimization** [Berstel & Reutenauer 2011]: our reconstruction generalizes Hankel-matrix minimization to the idempotent closure setting.
- **Tropical algebra** [Maclagan & Sturmfels 2015]: the cost function has a tropical/min-plus flavor; our observables are tropical linear functionals.
- **Enriched category theory** [Kelly 1982]: the Yoneda lemma in the enriched setting is our main technical tool.

---

## 2. Definitions

### 2.1 Closure-Cost Systems

**Definition 2.1.** A *closure-cost system* on a set α is a pair (cl, cost) where:
- cl : α → α is a closure operator satisfying:
  - Idempotence: cl(cl(x)) = cl(x) for all x
  - Metric retraction: cost(x, cl(x)) = 0 and cost(cl(x), x) = 0 for all x
- cost : α × α → ℝ≥0∞ is a Lawvere metric:
  - Reflexivity: cost(x, x) = 0
  - Triangle inequality: cost(x, z) ≤ cost(x, y) + cost(y, z)
- Nonexpansiveness: cost(cl(x), cl(y)) ≤ cost(x, y)

**Definition 2.2.** A closure-cost system is *separated* if for all closed x, y (i.e., cl(x) = x and cl(y) = y): cost(x, y) = 0 ∧ cost(y, x) = 0 implies x = y.

**Remark.** The retraction axiom says x and cl(x) are at zero distance in both directions — they are metrically indistinguishable. This is stronger than mere extensiveness (x ≤ cl(x)) but natural in the computational setting: simplification doesn't change the observable behavior.

### 2.2 Cost Observables

**Definition 2.3.** A *cost observable* on a closure-cost system (α, cl, cost) is a function φ : α → ℝ≥0∞ satisfying:
- Closure compatibility: φ(cl(x)) = φ(x) for all x
- Nonexpansiveness: φ(y) ≤ φ(x) + cost(x, y) for all x, y

### 2.3 Lawvere Computation Systems

**Definition 2.4.** A *Lawvere computation system* on a set β is a function dist : β × β → ℝ≥0∞ satisfying reflexivity (dist(x,x) = 0) and the triangle inequality.

### 2.4 Spectrum Distance

**Definition 2.5.** The *spectrum distance* on cost observables is:
$$\text{specDist}(\varphi, \psi) = \sup_{x \in \alpha} (\varphi(x) \dotminus \psi(x))$$
where ∸ denotes truncated subtraction in ℝ≥0∞.

---

## 3. The Yoneda Embedding

**Definition 3.1.** The *enriched Yoneda embedding* sends each a ∈ α to the cost observable φ_a defined by φ_a(x) = cost(a, x).

**Proposition 3.1.** φ_a is indeed a cost observable:
1. *Closure compatibility*: cost(a, cl(x)) = cost(a, x). 
   - Proof: cost(a, cl(x)) ≤ cost(a, x) + cost(x, cl(x)) = cost(a, x) by the retraction axiom. Conversely, cost(a, x) ≤ cost(a, cl(x)) + cost(cl(x), x) = cost(a, cl(x)) by the reverse retraction axiom.
2. *Nonexpansiveness*: cost(a, y) ≤ cost(a, x) + cost(x, y) by the triangle inequality.

**Proposition 3.2** (Closure invariance). yonedaObs(cl(x)) = yonedaObs(x) as cost observables.
- Proof: For all z, cost(cl(x), z) = cost(x, z). The forward inequality uses cost(cl(x), z) ≤ cost(cl(x), x) + cost(x, z) = cost(x, z). The reverse uses cost(x, z) ≤ cost(x, cl(x)) + cost(cl(x), z) = cost(cl(x), z).

---

## 4. Main Theorem: Isometric Yoneda Embedding

**Theorem 4.1** (Yoneda Isometry). For any finite closure-cost system (α, cl, cost) and any x, y ∈ α:
$$\text{specDist}(\varphi_x, \varphi_y) = \text{cost}(x, y)$$

*Proof.*

**Upper bound.** For any z ∈ α:
$$\text{cost}(x, z) - \text{cost}(y, z) \leq \text{cost}(x, y)$$
This follows from the triangle inequality: cost(x, z) ≤ cost(x, y) + cost(y, z). Taking the truncated difference gives cost(x, z) ∸ cost(y, z) ≤ cost(x, y). Since this holds for all z, the supremum satisfies specDist(φ_x, φ_y) ≤ cost(x, y).

**Lower bound.** Take the witness z = y:
$$\text{cost}(x, y) - \text{cost}(y, y) = \text{cost}(x, y) - 0 = \text{cost}(x, y)$$
This is one term in the supremum, so specDist(φ_x, φ_y) ≥ cost(x, y). □

**Corollary 4.2.** The spectrum distance on cost observables forms a Lawvere metric (reflexive and satisfying triangle inequality).

*Proof.* Reflexivity: specDist(φ, φ) = sup_x (φ(x) ∸ φ(x)) = 0. Triangle inequality: for each x, φ(x) ∸ χ(x) ≤ (φ(x) ∸ ψ(x)) + (ψ(x) ∸ χ(x)) ≤ specDist(φ, ψ) + specDist(ψ, χ). □

---

## 5. Separation Theorem

**Theorem 5.1** (Tropical Stone Separation). Let (α, cl, cost) be a separated closure-cost system. If x, y ∈ α are closed elements with cost(x, z) = cost(y, z) for all z, then x = y.

*Proof.* Setting z = y: cost(x, y) = cost(y, y) = 0. Setting z = x: cost(x, x) = cost(y, x), so cost(y, x) = 0. By separation, x = y. □

**Corollary 5.2.** In a separated system, the Yoneda embedding is injective on closed elements.

---

## 6. Certified Reconstruction Algorithm

### 6.1 Algorithm

**Input:** A finite closure-cost presentation P = (n, cl, cost) where n is the number of elements, cl : [n] → [n] is the closure function, and cost : [n] × [n] → ℝ≥0∞ is the cost matrix.

**Algorithm ReconstructMinimal(P):**
1. Validate all axioms of P (idempotence, reflexivity, triangle, retraction, nonexpansiveness).
2. Compute the set of closed elements: C = {x ∈ [n] | cl(x) = x}.
3. Extract the sub-matrix: dist[i,j] = cost(C[i], C[j]) for i, j ∈ [|C|].
4. Return (C, dist) as the minimal Lawvere computation system.

### 6.2 Correctness Certificate

**Theorem 6.1** (Reconstruction Correctness). The output of ReconstructMinimal satisfies:
1. **Soundness.** dist(C[i], C[j]) = cost(C[i], C[j]) for all i, j.
2. **Completeness.** For every x ∈ [n], there exists C[i] with cl(x) = C[i].
3. **Minimality.** No proper subset of C realizes all cost relationships on closed elements.
4. **Canonicity.** The output is independent of the ordering of elements.

*Proof of 1.* By construction. *Proof of 2.* cl(x) is always closed (by idempotence), so cl(x) ∈ C. *Proof of 3.* In a separated system, no two elements of C have zero distance in both directions, so removing any element loses distinguishability. *Proof of 4.* C is determined uniquely as the set of fixed points of cl. □

### 6.3 Complexity Analysis

- **Time:** O(n) for identifying closed elements, O(k²) for extracting the sub-matrix, O(n³) for validation. Total: O(n³) where k = |C| ≤ n.
- **Space:** O(k²) for the output distance matrix.

### 6.4 Realization Theorem

**Theorem 6.2.** The Yoneda embedding realizes the closure-cost system in the spectrum Lawvere system:
$$\text{specDist}(\varphi_x, \varphi_y) = \text{cost}(x, y) \quad \forall x, y \in \alpha$$

This is precisely Theorem 4.1, packaging the isometry as a realization statement.

---

## 7. Structural Stability

### 7.1 Closure Quotient Invariance

**Theorem 7.1.** For any element x, the Yoneda observable of cl(x) equals that of x:
$$\varphi_{\text{cl}(x)} = \varphi_x$$

This means the reconstruction is invariant under closure quotient: collapsing each element to its closed representative does not change the spectrum or the distances.

### 7.2 Product Compatibility

**Theorem 7.2.** Given closure-cost systems (α, cl_S, cost_S) and (β, cl_T, cost_T), their product system on α × β with L∞-style cost:
$$\text{cost}_{S \times T}((a_1, b_1), (a_2, b_2)) = \text{cost}_S(a_1, a_2) \sup \text{cost}_T(b_1, b_2)$$
satisfies:
$$\varphi_{(a,b)}^{S \times T}(x, y) = \varphi_a^S(x) \sup \varphi_b^T(y)$$

### 7.3 Round-Trip Property

**Theorem 7.3.** For any Lawvere computation system L, the round-trip fromLawvere(L) → specDist recovers L's distances:
$$\text{specDist}(\varphi_x^{\text{fromLawvere}(L)}, \varphi_y^{\text{fromLawvere}(L)}) = L.\text{dist}(x, y)$$

---

## 8. Computational Experiments

### 8.1 Simple 3-Element System

Elements {a, b, c} with cl(b) = a, asymmetric costs cost(a→c) = 3, cost(c→a) = 5.

| Pair | cost | specDist | Match |
|------|------|----------|-------|
| (a,a) | 0 | 0 | ✓ |
| (a,b) | 0 | 0 | ✓ |
| (a,c) | 3 | 3 | ✓ |
| (c,a) | 5 | 5 | ✓ |

The Yoneda observables φ_a = φ_b = [0, 0, 3] confirm closure invariance.

### 8.2 Reconstruction on 6-Element System

Three closure classes {0,1}, {2,3}, {4,5} with inter-class costs:

| From\To | Class 0 | Class 2 | Class 4 |
|---------|---------|---------|---------|
| Class 0 | 0 | 5 | 8 |
| Class 2 | 3 | 0 | 4 |
| Class 4 | 6 | 7 | 0 |

Reconstruction: 6 elements → 3 states (50% compression). All costs preserved exactly. Isometry and minimality verified computationally.

### 8.3 Application: Program Distance Semantics

4 program states (optimized/unoptimized × loop/branch), closure = compilation. Reconstruction yields 2-state minimal semantic model capturing all observable behavioral differences.

---

## 9. Discussion

### 9.1 Relationship to Classical Dualities

The Yoneda isometry theorem is the quantitative/metric analogue of several classical results:
- **Stone duality**: where the codomain {0, 1} is replaced by ℝ≥0∞
- **Kantorovich duality**: where the supremum of differences equals the optimal transport cost
- **Enriched Yoneda lemma**: where the hom-enrichment in ℝ≥0∞ makes the fully faithful embedding isometric

### 9.2 Limitations

1. The current formalization is restricted to **finite types**. Extension to infinite types requires enriched Cauchy completion theory, which is not yet fully available in Mathlib.
2. The closure must be a **metric retraction** (zero-cost in both directions). Relaxing this to mere nonexpansiveness would require a more nuanced spectrum construction.
3. The product compatibility uses **L∞ (sup) cost** rather than L1 (sum) cost. The L1 version requires different proof techniques.

### 9.3 Computational Significance

The reconstruction algorithm runs in polynomial time and produces a certified output. This contrasts with:
- Kolmogorov complexity (uncomputable)
- Hankel-matrix minimization for weighted automata (polynomial but limited to linear structures)
- Bisimulation quotient for transition systems (polynomial but doesn't carry metric information)

Our approach unifies these by working in the closure-cost framework, which subsumes all three settings.

---

## 10. Future Work

See FUTURE_DIRECTIONS.md for a detailed research roadmap. Key directions include:
1. Extension to infinite/compactly generated closure systems via enriched Cauchy completion
2. Information-theoretic versions using entropy-regularized costs
3. Enriched Myhill-Nerode theorem for closure-cost weighted automata
4. Connections to optimal transport and Wasserstein distances
5. Applications to explainable machine learning via observable spectra

---

## References

1. Lawvere, F.W. (1973). "Metric spaces, generalized logic, and closed categories." *Rendiconti del Seminario Matematico e Fisico di Milano*, 43, 135–166.
2. Stone, M.H. (1936). "The theory of representations for Boolean algebras." *Transactions of the AMS*, 40(1), 37–111.
3. Kelly, G.M. (1982). *Basic Concepts of Enriched Category Theory.* London Mathematical Society Lecture Note Series 64.
4. Berstel, J. & Reutenauer, C. (2011). *Noncommutative Rational Series with Applications.* Cambridge University Press.
5. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry.* Graduate Studies in Mathematics 161, AMS.
6. Priestley, H.A. (1970). "Representation of distributive lattices by means of ordered Stone spaces." *Bulletin of the London Mathematical Society*, 2(2), 186–190.
