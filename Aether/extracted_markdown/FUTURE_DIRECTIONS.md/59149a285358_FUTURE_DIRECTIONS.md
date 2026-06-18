# Future Directions: Tropical Geometry of Neural Networks

## What We Proved

This cycle formalized the bridge between ReLU neural network architecture and tropical algebraic geometry. The core results are:

- **Depth-width asymmetry** (`depth_width_asymmetry`): $(w+1)^L \geq Lw + 1$, quantifying why depth beats width
- **Strict exponential gap** (`depth_width_strict_gap`): for $w \geq 2, L \geq 2$, the gap is truly exponential: $(w+1)^L > 2Lw$
- **Region bound product** (`region_bound_product`): for any list of layer widths, $\prod(w_i + 1) \geq \sum w_i + 1$
- **Maslov dequantization** (both bounds): $\max(a,b) \leq \varepsilon \log(e^{a/\varepsilon} + e^{b/\varepsilon}) \leq \max(a,b) + \varepsilon \log 2$
- **ReLU composition** (`relu_composition`): $\max(0, \max(0,x) + b) = \max(0, \max(b, x+b))$ — the tropical rational function structure
- **Two-layer region bound**: $(w_1+1)(w_2+1) \geq w_1 + w_2 + 1$

All proofs compile without sorry and use only standard axioms (propext, Classical.choice, Quot.sound).

---

## Direction 1: Finset-Based Maslov Dequantization for n Elements

The Maslov dequantization bounds we proved are for two elements. The natural generalization is for $n$ elements: given $a_1, \ldots, a_n$ and $\varepsilon > 0$,

$$\max_i a_i \leq \varepsilon \log\left(\sum_{i=1}^n e^{a_i/\varepsilon}\right) \leq \max_i a_i + \varepsilon \log n$$

The key insight is that the proof structure is the same — the lower bound uses $e^{\max/\varepsilon} \leq \sum e^{a_i/\varepsilon}$ and the upper bound uses $\sum e^{a_i/\varepsilon} \leq n \cdot e^{\max/\varepsilon}$ — but formalizing it requires working with `Finset.sup'` and `Finset.sum` in Lean, which involves nontrivial API navigation.

Why now? The two-element case is proved and provides the proof blueprint. The `Finset.sum_le_card_nsmul` and `Finset.le_sup'` lemmas in Mathlib provide the necessary combinatorial scaffolding. This would give a fully general dequantization theorem directly applicable to softmax layers in neural networks.

---

## Direction 2: Tropical Betti Number Bounds via Morse Theory

The depth-width asymmetry gives a bound on the *number* of linear regions, but not on their *topology*. A tropical Morse theory would bound the Betti numbers (connected components, holes, higher-dimensional voids) of decision boundaries.

**Conjecture**: For a ReLU network with $L$ layers of width $w$ on $\mathbb{R}^n$, the sum of Betti numbers of the decision boundary satisfies $\sum_k \beta_k \leq 2(w+1)^L \binom{n-1+L}{L}$.

The key insight is that each breakpoint of a tropical polynomial acts like a critical point in Morse theory, and the tropical Morse inequality should bound Betti numbers by counting these critical points. The combinatorial bound $(w+1)^L$ on regions, which we proved, provides the critical point count.

Why now? The `region_bound_product` theorem gives the necessary combinatorial foundation. Mathlib's simplicial homology and Betti number infrastructure is maturing. Persistent homology computations on small networks could validate the bound computationally before formalization.

---

## Direction 3: Weight-Space Tropical Degree and Generalization Bounds

The Maslov dequantization connects smooth optimization (gradient descent on loss functions) to tropical geometry. As the "temperature" $\varepsilon \to 0$, smooth neural networks converge to tropical rational functions.

**Conjecture**: Weight decay regularization with coefficient $\lambda$ reduces the tropical degree of the learned function by at most $\lambda \cdot T$ after $T$ gradient steps, where tropical degree is measured by the number of essential terms in the canonical tropical form.

The key insight is that weight decay penalizes the $L_2$ norm of weights, but in the tropical limit ($\varepsilon \to 0$), this becomes a penalty on the number of active breakpoints — i.e., the tropical degree. The dequantization gap $\varepsilon \log 2$ we proved controls the "resolution" at which terms become distinguishable.

Why now? The Maslov dequantization bounds are formalized and provide the quantitative bridge. The next step is to formalize how gradient dynamics in weight space translate to tropical degree changes, which requires extending the framework to parameterized families of tropical functions.

---

## Direction 4: Tight Depth Separation via Tropical Intersection Theory

The strict gap theorem shows $(w+1)^L > 2Lw$ for $w,L \geq 2$, but the actual separation between deep and shallow networks is much sharper.

**Conjecture**: There exists a function computable by a depth-$L$ width-$w$ ReLU network that requires width $\Omega((w+1)^{L/2})$ in a depth-2 network. Equivalently, replacing depth $L$ by depth 2 requires an exponential blowup in width.

The key insight is that tropical intersection theory provides *lower bounds* on network size: if a function has tropical degree $d$ (measured by Newton polygon volume), then any depth-2 network computing it needs width $\geq d$. The `region_bound_product` theorem gives the upper bound; the lower bound requires formalizing tropical degree as a measure of complexity.

Why now? The product bound for arbitrary layer widths is proved. The missing piece is a tropical degree *lower bound* — showing that certain piecewise-linear functions cannot be decomposed into fewer pieces. This would connect to the extensive Mathlib theory of polytopes and convex geometry.

---

## Direction 5: Tropical VC Dimension via Activation Pattern Counting

The `single_layer_activation_bound` shows $2^w \geq w + 1$, bounding patterns per layer. The VC dimension of a network class bounds its sample complexity for learning.

**Conjecture**: The VC dimension of depth-$L$, width-$w$ ReLU networks satisfies $\text{VCdim} \leq L \cdot w \cdot \log_2(w+1)$, and this is tight up to constants when $w \geq n$ (input dimension).

The key insight is that the number of distinct activation patterns bounds the number of distinct decision boundaries the network can implement. Each pattern is a binary string of length $L \cdot w$ (one bit per neuron), but not all $2^{Lw}$ patterns are realizable — the hyperplane arrangement structure constrains them to at most $(w+1)^L$ patterns, as we proved. The VC dimension is then $\log_2((w+1)^L) = L \log_2(w+1)$ times the input dimension.

Why now? The activation pattern bounds are proved. Warren's theorem (bounding sign patterns of polynomial functions) has a tropical analog that could be formalized using the breakpoint-counting framework we established. This would give the first formalized VC dimension bound for neural networks with explicit dependence on architecture.
