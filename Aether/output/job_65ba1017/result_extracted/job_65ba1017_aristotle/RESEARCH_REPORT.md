# Backpropagation as the Cotangent Lift: A Categorical Perspective

## 1. ABSTRACT

We formalize and prove that the backpropagation algorithm used in neural network training corresponds precisely to the cotangent lift (pullback on cotangent bundles) of the forward map in the category of smooth manifolds. Given a composition of smooth layer maps $f = f_n \circ \cdots \circ f_1$, the induced cotangent map $f^* = f_1^* \circ \cdots \circ f_n^*$ reverses the order of composition—exactly mirroring backpropagation's reverse-mode traversal. This contravariant functoriality of the cotangent bundle functor $T^*: \mathbf{Man}^{op} \to \mathbf{VectBun}$ provides the categorical foundation explaining *why* backpropagation computes gradients in reverse order. Our Lean 4 formalization establishes this correspondence rigorously using Mathlib's category theory and differential geometry libraries.

## 2. MOTIVATION

Backpropagation is the computational backbone of modern deep learning, yet its mathematical foundations are often presented as mere chain-rule bookkeeping. Recognizing backpropagation as a cotangent lift has profound implications:

- **Correctness guarantees**: The functorial perspective ensures that gradient computations compose correctly across arbitrary network architectures.
- **Generalization**: The framework extends naturally to networks on manifolds (e.g., equivariant networks, geometric deep learning) where Euclidean chain rules don't directly apply.
- **Automatic differentiation**: The cotangent functor perspective unifies reverse-mode AD with the broader mathematical theory of jet bundles and differential operators.
- **Hardware design**: Understanding backprop categorically informs the design of specialized hardware that respects the contravariant data flow.

## 3. MATHEMATICAL FRAMEWORK

### Definitions and Notation

**Smooth manifolds and maps.** Let $\mathbf{Man}$ denote the category of smooth (finite-dimensional) manifolds with smooth maps as morphisms. For a smooth map $f: M \to N$, the tangent map (pushforward) is $Tf: TM \to TN$.

**Cotangent bundle.** The cotangent bundle $T^*M$ at a point $x \in M$ consists of all linear functionals on the tangent space $T_xM$. The cotangent lift of $f: M \to N$ is the pullback:

$$f^*: T^*N \to T^*M, \quad (f^*\alpha)(v) = \alpha(Tf \cdot v)$$

for $\alpha \in T^*_{f(x)}N$ and $v \in T_xM$.

**Contravariant functoriality.** The assignment $M \mapsto T^*M$, $f \mapsto f^*$ defines a contravariant functor $T^*: \mathbf{Man}^{op} \to \mathbf{VectBun}$, satisfying:

1. $(id_M)^* = id_{T^*M}$
2. $(g \circ f)^* = f^* \circ g^*$

**Neural network as composition.** A feedforward neural network with $n$ layers defines a composite smooth map $\Phi = f_n \circ f_{n-1} \circ \cdots \circ f_1$ where each $f_i: \mathbb{R}^{d_{i-1}} \to \mathbb{R}^{d_i}$ is a smooth layer map (affine transformation followed by smooth activation).

### Key Identity

Backpropagation computes:
$$\Phi^* = f_1^* \circ f_2^* \circ \cdots \circ f_n^*$$

This is precisely the cotangent lift of $\Phi$, with the reversed composition order arising from contravariance.

## 4. PROOF OVERVIEW

### High-Level Strategy

The proof proceeds by establishing that the cotangent bundle construction is a contravariant functor and then identifying the backpropagation algorithm with its action on morphisms.

**Step 1: Functoriality of $T^*$.** We verify that $T^*$ preserves identities and reverses compositions. The identity preservation is immediate from the definition. For compositions, given $f: M \to N$ and $g: N \to P$:

$$(g \circ f)^*(\alpha)(v) = \alpha(T(g \circ f) \cdot v) = \alpha(Tg \cdot Tf \cdot v) = (g^*\alpha)(Tf \cdot v) = f^*(g^*\alpha)(v)$$

Hence $(g \circ f)^* = f^* \circ g^*$.

**Step 2: Identification with backprop.** Each layer's cotangent lift $f_i^*$ corresponds to multiplying by the transpose Jacobian $J_{f_i}^T$. The backward pass multiplies gradient vectors by $J_{f_n}^T, J_{f_{n-1}}^T, \ldots, J_{f_1}^T$ in sequence—exactly $f_1^* \circ \cdots \circ f_n^*$.

**Step 3: Formalization.** The Lean proof establishes the theorem using Mathlib's categorical and differential geometry infrastructure.

### Key Lemmas

- **Chain rule for tangent maps**: $T(g \circ f) = Tg \circ Tf$
- **Contravariant functoriality**: $(g \circ f)^* = f^* \circ g^*$
- **Jacobian transpose identification**: $f_i^*$ acts as multiplication by $J_{f_i}^T$

## 5. NOVELTY ANALYSIS

This result, while mathematically "folklore" among differential geometers and automatic differentiation researchers, has several novel aspects in our treatment:

1. **First Lean 4 formalization**: To our knowledge, this is the first machine-verified proof connecting backpropagation to cotangent functoriality.
2. **Categorical clarity**: By framing the result in terms of functors rather than matrix calculus, we obtain a version that generalizes immediately to non-Euclidean settings (Riemannian manifolds, Lie groups, fiber bundles).
3. **Unification**: The same framework explains why forward-mode AD corresponds to the *tangent* functor (covariant), while reverse-mode (backprop) corresponds to the *cotangent* functor (contravariant).

## 6. OPEN PROBLEMS

1. **Higher-order backpropagation as jet bundle functors**: Can the higher-order generalization of backpropagation (computing Hessians, third derivatives, etc.) be characterized as the action of a jet bundle functor $J^k: \mathbf{Man}^{op} \to \mathbf{VectBun}$? What is the precise categorical structure?

2. **Tropical backpropagation**: ReLU networks are piecewise linear and can be studied via tropical geometry. Is there a "tropical cotangent functor" on the category of tropical varieties that recovers subgradient computation for non-smooth activations?

3. **Stochastic cotangent lifts**: For stochastic neural networks (dropout, noise injection), does the cotangent lift extend to a functor on a category of stochastic smooth maps? What is the correct notion of "stochastic cotangent bundle"?

## 7. REFERENCES

1. Fong, B., Spivak, D., & Tuyéras, R. (2019). "Backprop as functor: A compositional perspective on supervised learning." *Proceedings of the 34th Annual ACM/IEEE Symposium on Logic in Computer Science (LICS)*.

2. Elliott, C. (2018). "The simple essence of automatic differentiation." *Proceedings of the ACM on Programming Languages, 2*(ICFP), Article 70.

3. Cruttwell, G.S.H., Gavranović, B., Ghani, N., Wilson, P., & Zanasi, F. (2022). "Categorical foundations of gradient-based learning." *ESOP 2022, Lecture Notes in Computer Science*, vol. 13240.

4. Blute, R., Cockett, J.R.B., & Seely, R.A.G. (2009). "Cartesian differential categories." *Theory and Applications of Categories*, 22(23), 622–672.

5. Abadi, M. & Plotkin, G.D. (2020). "A simple differentiable programming language." *Proceedings of the ACM on Programming Languages, 4*(POPL), Article 38.

6. Spivak, M. (1999). *A Comprehensive Introduction to Differential Geometry*, Vol. 1, 3rd edition. Publish or Perish.
