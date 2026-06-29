# Maslov Dequantization of the Finite-Lattice SPB Propagator: A Formally Verified Tropical Collapse

## Abstract

We give a machine-verified proof (in Lean 4 with Mathlib) that the Maslov dequantization of a finite-sum quantum propagator converges to the tropical (min-plus) minimum of the classical action. Specifically, for a finite nonempty family of piecewise-linear paths $\Gamma$ in SPB 3-space with Lohmiller–Slotine action $S_\gamma$, we prove

$$\lim_{h \to 0^+} \bigl(-h \cdot \log \sum_{\gamma \in \Gamma} e^{-S_\gamma / h}\bigr) = \min_{\gamma \in \Gamma} S_\gamma.$$

This establishes the rigorous tropical collapse of the quantum sum-over-histories to a single extremal path in the min-plus semiring.

## 1. Introduction

### 1.1 The Laplace Principle and Tropical Geometry

The connection between classical mechanics and quantum mechanics is one of the deepest themes in mathematical physics. Feynman's path integral formulation expresses quantum amplitudes as sums over all possible paths, weighted by $e^{iS/\hbar}$. In the semiclassical limit $\hbar \to 0$, the dominant contribution comes from paths that extremize the action — recovering classical mechanics via the principle of stationary phase.

There is an elegant algebraic reformulation of this limit through **tropical geometry**. The tropical (min-plus) semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$ replaces ordinary addition with minimum and ordinary multiplication with addition. Maslov observed that the map $a \mapsto -h \log(e^{-a/h})$ provides a deformation from the ordinary semiring $(\mathbb{R}_{>0}, +, \cdot)$ to the tropical semiring as $h \to 0^+$. Under this **Maslov dequantization**:

- Sums $\sum e^{-S_\gamma/h}$ become tropical sums $\min_\gamma S_\gamma$
- Products become tropical products (ordinary sums)
- The quantum propagator collapses to a tropical propagator

### 1.2 Our Contribution

We provide a complete, machine-verified proof of the Maslov dequantization theorem for finite path lattices. The proof is formalized in Lean 4 using the Mathlib library and verified by the Lean kernel — no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound) are used.

The key result is the **Laplace principle for finite sums**:

**Theorem** (laplace_principle_finset). *Let $\Gamma$ be a finite nonempty set and $f: \Gamma \to \mathbb{R}$. Then*
$$\lim_{h \to 0^+} \bigl(-h \cdot \log \sum_{\gamma \in \Gamma} e^{-f(\gamma)/h}\bigr) = \min_{\gamma \in \Gamma} f(\gamma).$$

This is then specialized to the SPB (Stereographic Pythagorean Bridge) setting with the Lohmiller–Slotine discretized action.

## 2. Mathematical Framework

### 2.1 Piecewise-Linear Paths

We work with piecewise-linear paths in $\mathbb{R}^3$ connecting fixed endpoints $x, y$ with $n$ segments:

$$\text{PLPath}(x, y, n) = \{\gamma : \{0, 1, \ldots, n\} \to \mathbb{R}^3 \mid \gamma(0) = x,\; \gamma(n) = y\}$$

### 2.2 The Discretized Action

The Lohmiller–Slotine action for a PL path over elapsed time $T > 0$ is:

$$S[\gamma] = \sum_{i=0}^{n-1} \frac{|\gamma(i+1) - \gamma(i)|^2}{T/(n+1)}$$

This discretizes the classical Lagrangian action $\int_0^T |\dot\gamma(t)|^2\, dt$.

### 2.3 The Maslov Dequantization Map

For a deformation parameter $h > 0$, the **Maslov dequantization** of the finite-lattice propagator is:

$$\mathcal{D}_h[\Gamma] = -h \cdot \log \sum_{\gamma \in \Gamma} e^{-S[\gamma]/h}$$

## 3. Proof of the Main Theorem

### 3.1 Proof Strategy: The Sandwich Lemma

The proof proceeds by squeezing $\mathcal{D}_h[\Gamma]$ between two functions that both converge to $S^* = \min_\gamma S[\gamma]$.

**Lemma (Upper Bound).** *For $h > 0$:* $\mathcal{D}_h[\Gamma] \leq S^*$.

*Proof.* Let $\gamma_0 \in \Gamma$ attain the minimum $S^* = S[\gamma_0]$. Then:
$$\sum_{\gamma \in \Gamma} e^{-S[\gamma]/h} \geq e^{-S[\gamma_0]/h} = e^{-S^*/h}$$
Taking $\log$ (which is monotone) and multiplying by $-h < 0$ (which reverses the inequality):
$$-h \cdot \log \sum_\gamma e^{-S[\gamma]/h} \leq -h \cdot \log e^{-S^*/h} = -h \cdot (-S^*/h) = S^*.$$

**Lemma (Lower Bound).** *For $h > 0$:* $S^* - h \cdot \log|\Gamma| \leq \mathcal{D}_h[\Gamma]$.

*Proof.* For every $\gamma \in \Gamma$, $S^* \leq S[\gamma]$, so $-S[\gamma]/h \leq -S^*/h$, hence $e^{-S[\gamma]/h} \leq e^{-S^*/h}$. Summing:
$$\sum_\gamma e^{-S[\gamma]/h} \leq |\Gamma| \cdot e^{-S^*/h}$$
Taking $\log$ and multiplying by $-h$:
$$\mathcal{D}_h[\Gamma] \geq -h \bigl(\log|\Gamma| + (-S^*/h)\bigr) = S^* - h \cdot \log|\Gamma|.$$

### 3.2 The Squeeze

Combining the bounds: for all $h > 0$,

$$S^* - h \cdot \log|\Gamma| \leq \mathcal{D}_h[\Gamma] \leq S^*.$$

Since $h \cdot \log|\Gamma| \to 0$ as $h \to 0^+$ (it is a constant times $h$), both bounds converge to $S^*$. By the squeeze theorem, $\mathcal{D}_h[\Gamma] \to S^*$.

## 4. Formalization Details

### 4.1 Lean 4 Statement

The core theorem in Lean 4:

```lean
theorem laplace_principle_finset
    (Γ : Finset α) (hΓ : Γ.Nonempty) (f : α → ℝ) :
    Tendsto
      (fun (h : ℝ) ↦ -h * log (∑ γ ∈ Γ, exp (-f γ / h)))
      (𝓝[>] 0)
      (𝓝 (Γ.inf' hΓ f))
```

### 4.2 Proof Architecture

The proof is decomposed into four helper lemmas:

1. **sum_exp_pos**: Positivity of the sum of exponentials (needed for `log`)
2. **laplace_upper_bound**: The upper sandwich bound
3. **laplace_lower_bound**: The lower sandwich bound
4. **correction_tendsto_zero**: The correction term $h \log|\Gamma| \to 0$

The main theorem applies a squeeze argument (`squeeze_zero_norm`) to combine these pieces.

### 4.3 Axioms

The proof uses only standard Lean 4 axioms: `propext`, `Classical.choice`, and `Quot.sound`. No `sorry` or custom axioms appear anywhere in the proof or its dependencies.

## 5. Discussion: What Does This Mean?

### 5.1 A Scientific American Perspective

Imagine you're planning a road trip from New York to Los Angeles. There are infinitely many routes you could take, but you want the fastest one. A quantum computer, in some sense, would try *all* routes simultaneously — each weighted by how good it is. Our theorem says that as you "turn down the quantum noise" (the parameter $h$), the quantum computer's answer converges to the single best route.

More precisely, the quantum world uses a peculiar arithmetic where you add probabilities by multiplying their exponentials. The tropical world uses an even simpler arithmetic: "addition" means "take the minimum." Our theorem builds a bridge between these two worlds: the quantum arithmetic becomes tropical arithmetic in the classical limit.

This is like watching a blurry photograph come into focus. When $h$ is large, many paths contribute significantly — the image is blurry. As $h \to 0$, only the optimal path survives — the image snaps into sharp focus on the single best route.

### 5.2 Connection to the Semiclassical Limit

The Maslov dequantization is the Wick-rotated (imaginary time) analog of the stationary phase approximation in quantum mechanics. In the standard path integral:

$$K(x, y; T) = \int \mathcal{D}\gamma\; e^{iS[\gamma]/\hbar}$$

the $\hbar \to 0$ limit is dominated by paths satisfying the Euler–Lagrange equations. Our theorem proves the analogous statement for the Euclidean (Wick-rotated) path integral on a finite lattice, where the oscillatory integral becomes a genuine sum of decaying exponentials.

### 5.3 Tropical Semirings and Optimization

The tropical min-plus semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$ is the natural algebraic structure for optimization problems. Dynamic programming, shortest paths, and optimal control all have elegant tropical formulations. Our theorem says that these tropical optimization problems arise naturally as limits of "soft" optimization (log-sum-exp), which is the standard tool in machine learning (softmax, log-partition functions).

## 6. Applications

### 6.1 Neural Network Robustness via Tropical Geometry

Tropical geometry has been applied to the analysis of ReLU neural networks, where the decision boundaries are piecewise-linear. The Maslov dequantization connects the "soft" neural network (with smooth activations like softmax) to the "hard" tropical network (with ReLU/min/max activations). Our theorem makes this connection rigorous for finite-lattice approximations.

### 6.2 Log-Sum-Exp and the Softmax Function

The log-sum-exp function $\text{LSE}(x_1, \ldots, x_n) = \log(e^{x_1} + \cdots + e^{x_n})$ is ubiquitous in machine learning as a smooth approximation to the maximum. Our theorem, applied with $f(\gamma) = -x_\gamma$ and the substitution $h \to t$, gives:

$$\lim_{t \to 0^+} t \cdot \text{LSE}(x_1/t, \ldots, x_n/t) = \max(x_1, \ldots, x_n)$$

This is the precise sense in which softmax converges to hardmax, and log-sum-exp converges to max.

### 6.3 Lattice-Based Cryptography

In lattice-based cryptography (e.g., CRYSTALS-Dilithium), one needs bounds on sums of the form $\sum e^{-\|v\|^2/\sigma^2}$ over lattice vectors. The Maslov dequantization principle shows that such sums are dominated by the shortest vector as $\sigma \to 0$, connecting Gaussian smoothing to the shortest vector problem — a foundational hardness assumption.

## 7. Future Directions

1. **Infinite-dimensional extension**: Extend the Laplace principle from finite sums to measures on path spaces (the Varadhan–Laplace principle in large deviations theory).
2. **Rate of convergence**: Our proof shows the error is $O(h \log|\Gamma|)$. Sharper asymptotics (full asymptotic expansion in $h$) would connect to semiclassical trace formulas.
3. **Tropical spectral theory**: Combine with idempotent spectral theory to study tropical eigenvalues of quantum Hamiltonians.
4. **Computational applications**: Implement tropical propagator algorithms for shortest-path problems on SPB-like geometries.

## References

- G.L. Litvinov, "The Maslov dequantization, idempotent and tropical mathematics: a brief introduction," *J. Math. Sci.* 140(3), 2007.
- M. Akian, S. Gaubert, A. Guterman, "Tropical polyhedra are equivalent to mean payoff games," *Int. J. Algebra Comput.* 22(1), 2012.
- D. Maclagan, B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.
- A. Dembo, O. Zeitouni, *Large Deviations Techniques and Applications*, Springer, 2010 (for the Varadhan–Laplace principle).
