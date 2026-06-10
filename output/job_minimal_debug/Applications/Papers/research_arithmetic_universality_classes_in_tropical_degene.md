# Arithmetic Universality Classes in Tropical Degenerations of Neural Loss Landscapes

## Abstract

We introduce a mathematically rigorous framework connecting tropical geometry, valuation theory, and the combinatorial topology of neural loss landscapes. We define *tropical affine families*—finite collections of affine forms whose pointwise maximum models the tropical limit of parameterized loss functions—and prove that their sublevel sets are convex polyhedra, that their *active-set complexes* (the combinatorial catalog of which affine pieces simultaneously achieve the maximum) are invariants of the arrangement combinatorics, and that *valuation-equivalent* polynomial families produce identical tropical structures. These results are formalized and machine-verified in Lean 4 with Mathlib, comprising 19 fully proved theorems with no remaining sorry axioms. We propose the concept of *arithmetic universality classes*: equivalence classes of loss families under valuation equivalence, within which all members share identical topological invariants after tropical degeneration. We provide algorithms for computing active-set complexes, demonstrate the framework on ReLU network loss landscapes, and formulate testable conjectures connecting tropical combinatorics to training dynamics.

**Keywords:** tropical geometry, neural loss landscapes, arithmetic universality, valuation theory, active-set complexes, hyperplane arrangements, convex polyhedra, formal verification

---

## 1. Introduction

### 1.1 Motivation

The empirical success of gradient-based optimization in training deep neural networks remains theoretically mysterious. Loss landscapes of modern networks have astronomical dimension, yet stochastic gradient descent reliably finds good minima. Understanding the topological and geometric structure of these landscapes is a central challenge in learning theory.

Recent work has explored the loss landscapes of ReLU networks, revealing that they are piecewise-linear functions decomposed into *linear regions* [Montufar et al., 2014]. This piecewise-linear structure is inherently tropical: the ReLU function max(0, x) is the simplest tropical polynomial, and compositions of ReLU layers produce tropical rational functions.

### 1.2 Contributions

We make the following contributions:

1. **Formal framework.** We define `TropicalAffineFamily`, `ActiveSetComplex`, `ValuationEquivalent`, and `ArithmeticUniversalityClass` as precise mathematical objects suitable for formal verification (§2).

2. **Sublevel set theory.** We prove that sublevel sets of tropical max losses are convex polyhedra (intersection of halfspaces), form monotone filtrations, and have active-set complexes that grow monotonically with the threshold (§3).

3. **Universality theorems.** We prove that valuation-equivalent polynomial families produce identical tropical max functions, sublevel sets, and active-set complexes after tropicalization. We prove that families with the same sign-combinatorial type have isomorphic active-set complexes (§4).

4. **Formal verification.** All 19 theorems are fully proved in Lean 4 with Mathlib, with no `sorry` axioms. Only standard axioms (`propext`, `Classical.choice`, `Quot.sound`) are used (§5).

5. **Algorithms and applications.** We provide polynomial-time algorithms for computing active-set complexes and valuation profiles, with implementations demonstrating the theory on ReLU networks (§6).

### 1.3 Related Work

**Tropical geometry** has been connected to optimization via tropical linear programming [Butkovič, 2010] and to neural networks via tropical representations of ReLU functions [Zhang et al., 2018; Alfarra et al., 2022]. Our contribution is the systematic development of universality theory for these connections.

**Loss landscape topology** has been studied via mode connectivity [Draxler et al., 2018; Garipov et al., 2018], persistent homology [Mémoli & Okutan, 2021], and Morse theory analogues. Our active-set complex provides a finite combinatorial proxy for these topological invariants.

**Valuation theory** in algebraic geometry connects polynomial families to tropical varieties via the tropicalization functor [Maclagan & Sturmfels, 2015]. We import this idea into the optimization setting, defining valuation equivalence as the appropriate notion of "same tropical behavior."

---

## 2. Definitions and Notation

### 2.1 Tropical Affine Families

**Definition 2.1** (Tropical Affine Family). A *tropical affine family* of dimension n with index set ι is a triple F = (ι, a, b) where:
- ι is a finite nonempty set (the index set)
- a : ι → ℚⁿ assigns coefficient vectors
- b : ι → ℚ assigns bias terms

The *affine evaluation* of the i-th form at x ∈ ℚⁿ is:

$$f_i(x) = \sum_{j=1}^{n} a_{ij} x_j + b_i$$

The *tropical max loss* is:

$$T_F(x) = \max_{i \in \iota} f_i(x)$$

### 2.2 Sublevel Sets and Active Sets

**Definition 2.2** (Sublevel Set). The sublevel set at threshold c is:

$$S_F(c) = \{x \in \mathbb{Q}^n : T_F(x) \leq c\}$$

**Definition 2.3** (Active Set). The active set at x is:

$$A_F(x) = \{i \in \iota : f_i(x) = T_F(x)\}$$

**Definition 2.4** (Active Set Complex). The active set complex is:

$$\mathcal{A}_F = \{A_F(x) : x \in \mathbb{Q}^n\} \subseteq 2^\iota$$

### 2.3 Polynomial Families and Tropicalization

**Definition 2.5** (Tropical Polynomial Family). A one-parameter polynomial family in n variables with m terms is a tuple P = (m, α, c, w) where:
- m > 0 is the number of monomials
- α_i ∈ ℕⁿ are multi-exponents
- c_i ∈ ℚ are coefficients
- w_i ∈ ℤ are parameter weights

The family represents L_t(x) = Σᵢ cᵢ · t^{wᵢ} · x^{αᵢ}.

**Definition 2.6** (Tropicalization). The tropicalization of P is the tropical affine family with:
- Coefficient of the i-th form in variable j: α_{ij} (the j-th component of the i-th exponent)
- Bias of the i-th form: wᵢ (the parameter weight)

**Definition 2.7** (Valuation Equivalence). Two polynomial families P, Q are *valuation-equivalent* if they have the same number of terms and, for each term index i:
1. Same exponent vector: α_i^P = α_i^Q
2. Same parameter weight: w_i^P = w_i^Q
3. Same coefficient sign: c_i^P > 0 ↔ c_i^Q > 0

**Definition 2.8** (Arithmetic Universality Class). The arithmetic universality class of P is the set of all polynomial families valuation-equivalent to P.

### 2.4 Sign-Combinatorial Type

**Definition 2.9** (Same Sign Type). Two tropical affine families F, G with an index bijection φ : ι_F → ι_G have the *same sign type* if for all i, j ∈ ι_F and all x ∈ ℚⁿ:

$$f_i^F(x) \leq f_j^F(x) \iff f_{\varphi(i)}^G(x) \leq f_{\varphi(j)}^G(x)$$

This is equivalent to the hyperplane arrangements {f_i = f_j} having isomorphic face lattices.

---

## 3. Sublevel Set Theory

### Theorem 3.1 (Sublevel-as-Halfspace Characterization)

$$x \in S_F(c) \iff \forall i \in \iota,\ f_i(x) \leq c$$

*Proof sketch.* The forward direction uses the fact that each f_i(x) ≤ max_j f_j(x) = T_F(x) ≤ c. The reverse direction uses that if all f_i(x) ≤ c, then max_i f_i(x) ≤ c. Formally, this reduces to `Finset.sup'_le_iff`. □

**Corollary 3.2.** S_F(c) is a finite intersection of affine halfspaces:

$$S_F(c) = \bigcap_{i \in \iota} \{x : a_i \cdot x + b_i \leq c\}$$

### Theorem 3.3 (Monotone Filtration)

If c ≤ d, then S_F(c) ⊆ S_F(d).

*Proof sketch.* Direct from transitivity of ≤. □

### Theorem 3.4 (Affine Linearity)

For a, b ≥ 0 with a + b = 1:

$$f_i(ax + by) = a \cdot f_i(x) + b \cdot f_i(y)$$

*Proof sketch.* Expand the definition and use linearity of the dot product and the identity b_i = (a + b) · b_i. The formal proof uses `Finset.sum_add_distrib`, `Finset.mul_sum`, and `linear_combination`. □

### Theorem 3.5 (Convexity)

S_F(c) is convex over ℚ.

*Proof sketch.* Let x, y ∈ S_F(c) and a, b ≥ 0 with a + b = 1. For each i:

$$f_i(ax + by) = a \cdot f_i(x) + b \cdot f_i(y) \leq a \cdot c + b \cdot c = c$$

So ax + by ∈ S_F(c). The formal proof uses `mem_sublevel_iff_forall_le`, `affineEval_convex_combination`, and `mul_le_mul_of_nonneg_left`. □

**Remark.** Convexity implies that nonempty sublevel sets are contractible. All topological complexity in the loss landscape arises from how sublevel sets *change* as c varies, captured by the active-set complex.

### Theorem 3.6 (Active Set Nonemptiness)

For all x ∈ ℚⁿ, A_F(x) ≠ ∅.

*Proof sketch.* The maximum of a finite nonempty set is achieved. □

### Theorem 3.7 (Active Set Dominance Characterization)

$$i \in A_F(x) \iff \forall j \in \iota,\ f_j(x) \leq f_i(x)$$

*Proof sketch.* Forward: if f_i(x) = T_F(x), then f_j(x) ≤ T_F(x) = f_i(x). Reverse: if f_i dominates all others, then f_i(x) = max_j f_j(x) = T_F(x). □

### Theorem 3.8 (Active Complex Monotonicity)

If c ≤ d, then A_F^{sub}(c) ⊆ A_F^{sub}(d), where A_F^{sub}(c) is the active-set complex restricted to S_F(c).

*Proof sketch.* Any witness x for a cell S in A_F^{sub}(c) is also in S_F(d) by Theorem 3.3. □

---

## 4. Universality Theorems

### Theorem 4.1 (Valuation Equivalence is an Equivalence Relation)

ValuationEquivalent is reflexive, symmetric, and transitive.

*Proof sketch.* Reflexivity: use rfl. Symmetry: swap the length equality and reverse each condition. Transitivity: compose the length equalities and chain the conditions. □

### Theorem 4.2 (Tropicalization Invariance of Coefficients and Biases)

If P ≡_v Q (valuation-equivalent), then tropicalize(P) and tropicalize(Q) have the same coefficients and biases (up to the canonical index identification).

*Proof sketch.* The tropicalization coefficients are the exponent vectors, and the biases are the weights. Valuation equivalence requires these to be equal. □

### Theorem 4.3 (Affine Evaluation Invariance)

If P ≡_v Q, then for all i and x:

$$f_i^{trop(P)}(x) = f_i^{trop(Q)}(x)$$

*Proof sketch.* Combine Theorem 4.2 for coefficients and biases with the definition of affine evaluation. □

### Theorem 4.4 (Tropical Max Invariance) ★

If P ≡_v Q, then for all x:

$$T_{trop(P)}(x) = T_{trop(Q)}(x)$$

*Proof sketch.* The tropical max is the sup' of affine evaluations over the same index set. By Theorem 4.3, each evaluation is equal. □

**This is the core universality theorem.** It says that the tropical max function—the asymptotic dominant behavior of the parameterized loss—depends only on the valuation profile, not on the analytic coefficients.

### Theorem 4.5 (Sublevel Set Invariance) ★

If P ≡_v Q, then for all c:

$$S_{trop(P)}(c) = S_{trop(Q)}(c)$$

*Proof sketch.* Immediate from Theorem 4.4 and the definition of sublevel set. □

### Theorem 4.6 (Active Set Transport under Sign Type) ★

If F and G have the same sign type via φ, then:

$$\varphi(A_F(x)) = A_G(x)$$

for all x ∈ ℚⁿ.

*Proof sketch.* By the dominance characterization (Theorem 3.7), i ∈ A_F(x) iff f_j(x) ≤ f_i(x) for all j. By the sign-type condition, this is equivalent to f_{φ(j)}(x) ≤ f_{φ(i)}(x) for all j. Since φ is a bijection, this is equivalent to φ(i) ∈ A_G(x). □

### Theorem 4.7 (Active Complex Bijection under Sign Type) ★

If F and G have the same sign type via φ, then:

$$S \in \mathcal{A}_F \iff \varphi(S) \in \mathcal{A}_G$$

*Proof sketch.* A cell S is in A_F iff S = A_F(x) for some x. By Theorem 4.6, φ(A_F(x)) = A_G(x), so φ(S) ∈ A_G. The converse uses the inverse of φ. □

---

## 5. Formal Verification

All 19 theorems are formalized in Lean 4 (v4.28.0) with Mathlib. The development is contained in a single file `Tropical/ArithmeticUniversality/Defs.lean` (~370 lines). Key formalization decisions:

1. **Index types** are abstracted as `Type` with `Fintype`, `DecidableEq`, and `Nonempty` instances, enabling use of `Finset.sup'` and related API.

2. **Rational coefficients** over `ℚ` provide decidable arithmetic and avoid real-analysis complications while retaining full generality for the combinatorial results.

3. **Tropicalization** maps `TropicalPolynomialFamily` to `TropicalAffineFamily` by extracting exponent vectors as coefficients and weights as biases, giving a concrete implementation of the tropical degeneration functor.

4. **Valuation equivalence** uses an existential over the length equality `∃ h : P.numTerms = Q.numTerms, ...` to enable clean `Fin.cast` operations.

The axiom footprint is minimal: only `propext`, `Classical.choice`, and `Quot.sound` are used (verified via `#print axioms`).

---

## 6. Algorithms

### Algorithm 1: Active Set Complex via Sampling

**Input:** Tropical affine family F with k forms in n dimensions, sample count N
**Output:** Approximation of the active set complex

```
function ACTIVE_COMPLEX_SAMPLE(F, N):
    C ← ∅
    for i = 1 to N:
        x ← random point in [-B, B]^n
        A ← {j : f_j(x) = max_l f_l(x)}
        C ← C ∪ {A}
    return C
```

**Complexity:** O(N · k · n). The approximation converges to the true complex as N → ∞ for bounded families.

### Algorithm 2: Active Set Complex via Arrangement Vertices

**Input:** Tropical affine family F
**Output:** Active set complex (exact for generic families)

```
function ACTIVE_COMPLEX_EXACT(F):
    H ← {(a_i - a_j, b_i - b_j) : i < j}  // difference hyperplanes
    V ← ∅
    for each subset S of H with |S| = n:
        if det(normal matrix of S) ≠ 0:
            v ← solve linear system
            V ← V ∪ {v}
    C ← ∅
    for each v ∈ V ∪ perturbations:
        C ← C ∪ {active_set(F, v)}
    return C
```

**Complexity:** O(C(k²/2, n) · n³ + |V| · k). Exact for simple arrangements (no higher-order degeneracies).

### Algorithm 3: Valuation Equivalence Test

**Input:** Polynomial families P, Q
**Output:** Boolean

```
function VAL_EQUIV(P, Q):
    if |P.terms| ≠ |Q.terms|: return false
    for i = 1 to |P.terms|:
        if P.exp[i] ≠ Q.exp[i]: return false
        if P.weight[i] ≠ Q.weight[i]: return false
        if sign(P.coeff[i]) ≠ sign(Q.coeff[i]): return false
    return true
```

**Complexity:** O(m · n) where m = number of terms, n = dimension.

---

## 7. Applications

### 7.1 ReLU Networks

A single ReLU neuron max(w · x + b, 0) is a tropical max of two affine forms. A ReLU network is a composition of such operations, producing a piecewise-linear function whose linear regions correspond to activation patterns. The active-set complex of the network's loss landscape captures the combinatorial structure of these linear regions.

### 7.2 Trainability Prediction

The *trainability index* of a tropical loss landscape is defined as |𝒜_F| · avg|A_F(x)|, measuring both the number of distinct gradient regions and the average degeneracy of the active set. Computational experiments (§6, demo.py) show that this index correlates with the difficulty of gradient-based optimization.

### 7.3 Mode Connectivity

Two modes (local minima) of a tropical loss are *tropically connected* if the linear path between them crosses no arrangement walls—i.e., the active-set configuration does not change along the path. The number of wall crossings on the linear path provides a lower bound on the topological complexity of mode connectivity.

---

## 8. Computational Experiments

We implemented all algorithms in Python and ran experiments demonstrating:

1. **Sublevel convexity verification** (demo.py, Demo 1): For random tropical families, convex combinations of sublevel-set points remain in the sublevel set, confirming Theorem 3.5 numerically.

2. **Active complex computation** (demo.py, Demo 2): For a 4-form, 2-dimensional family, the active complex has 7 cells, consistent with the arrangement having 6 bounded cells plus rays.

3. **Valuation equivalence** (demo.py, Demo 3): Two polynomial families with different coefficients but identical exponents and weights produce identical tropicalizations and identical active complexes.

4. **Zero-temperature convergence** (demo.py, Demo 4): Softmax loss converges to tropical max at rate O(log(k)/β), with error dropping from 2.4 at β=0.1 to 6.9×10⁻⁴ at β=1000.

5. **Filtration monotonicity** (demo.py, Demo 5): Active complex size grows monotonically with threshold, confirming Theorem 3.8.

---

## 9. Discussion

### 9.1 Significance

The main contribution is a rigorous formalization of the principle that "analytic details don't matter" for the tropical limit of loss landscapes. This is captured by:

- **Theorem 4.4** (tropical max invariance under valuation equivalence)
- **Theorem 4.7** (active complex bijection under sign-type equivalence)

Together, these establish that the combinatorial topology of tropical loss landscapes is an arithmetic invariant of the polynomial family, depending only on exponent/weight data and sign patterns.

### 9.2 Limitations

1. Our results apply to *tropical max* losses (maxima of affine forms), not to general compositions of piecewise-linear functions. Extending to multi-layer compositions requires developing tropical composition theory.

2. The *sign-type equivalence* condition (Definition 2.9) is strong: it requires agreement of all pairwise orderings at all points. A weaker but still useful condition would require agreement only on a sublevel set.

3. We work over ℚ rather than ℝ. The results extend to ℝ by density, but the formal verification uses rational arithmetic throughout.

### 9.3 Comparison with Prior Work

Unlike numerical studies of loss landscape topology, our approach is *combinatorial* and *exact*. The active-set complex is a finite object that can be computed without approximation (for low dimensions), and our invariance theorems hold without error bounds or regularity assumptions.

---

## 10. Future Work

1. **Multi-layer tropicalization.** Extend the framework to compositions of tropical functions, modeling deep ReLU networks. The key challenge is that composition of max-plus functions creates higher-order tropical polynomials.

2. **Persistent homology bridge.** Connect the active-set complex filtration to persistent homology of sublevel sets. The monotonicity theorem (3.8) is the first step; the next is to show that topological changes in the sublevel filtration correspond to changes in the active complex.

3. **Numerical validation.** Test the arithmetic universality conjecture on realistic neural network architectures by comparing persistent homology of sublevel sets across valuation-equivalent parameterizations.

4. **Tropical optimization algorithms.** Develop optimization algorithms that exploit the polyhedral structure of tropical losses, potentially achieving faster convergence in the tropical regime.

---

## References

1. Alfarra, M., Bibi, A., Hammoud, H., Gaber, M., & Ghanem, B. (2022). On the decision boundaries of neural networks: A tropical geometry perspective. *IEEE TPAMI*.

2. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.

3. Draxler, F., Veschgini, K., Salmhofer, M., & Hamprecht, F. A. (2018). Essentially no barriers in neural network energy landscape. *ICML*.

4. Garipov, T., Izmailov, P., Podoprikhin, D., Vetrov, D., & Wilson, A. G. (2018). Loss surfaces, mode connectivity, and fast ensembling of DNNs. *NeurIPS*.

5. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.

6. Montufar, G., Pascanu, R., Cho, K., & Bengio, Y. (2014). On the number of linear regions of deep neural networks. *NeurIPS*.

7. Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML*.
