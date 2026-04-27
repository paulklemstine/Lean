# Backpropagation as the Cotangent Lift: A Categorical Formalization

## 1. ABSTRACT

We formalize the classical observation that the backpropagation algorithm in neural networks is precisely the cotangent lift of the forward map in the category of smooth manifolds. Given a smooth map $f: M \to N$ between parameter/activation manifolds, the cotangent lift $f^*: T^*N \to T^*M$ pulls back covectors contravariantly. For a composite network $f = f_n \circ \cdots \circ f_1$, the chain rule gives $(f_n \circ \cdots \circ f_1)^* = f_1^* \circ \cdots \circ f_n^*$, which is exactly the reverse-mode traversal of backpropagation. This contravariant functoriality — the cotangent functor $T^*: \mathbf{Man}^{\mathrm{op}} \to \mathbf{VectBun}$ — is the deep mathematical reason why gradients must be propagated backwards. We provide a machine-verified Lean 4 proof of this structural theorem using Mathlib's category theory and differential geometry libraries.

## 2. MOTIVATION

Backpropagation is the computational engine of modern deep learning, yet its mathematical essence is often obscured by implementation details. Understanding backpropagation as a cotangent lift has several consequences:

- **Correctness guarantees**: The categorical formulation makes the chain rule's correctness self-evident from functoriality.
- **Generalization**: The framework extends immediately to Riemannian manifolds, Lie groups, and other non-Euclidean parameter spaces relevant to geometric deep learning.
- **Automatic differentiation**: The cotangent viewpoint clarifies the duality between forward-mode (tangent lift) and reverse-mode (cotangent lift) AD.
- **Optimization geometry**: Natural gradient methods, information geometry, and second-order methods all arise naturally from the cotangent bundle structure.
- **Physics connections**: The cotangent bundle is the phase space of Hamiltonian mechanics, linking neural network training to symplectic geometry and optimal transport.

## 3. MATHEMATICAL FRAMEWORK

### Definitions and Notation

Let $\mathbf{Man}$ denote the category of smooth manifolds and smooth maps.

**Definition (Cotangent Bundle).** For a smooth manifold $M$, the cotangent bundle $T^*M = \bigsqcup_{p \in M} T_p^*M$ is the disjoint union of all cotangent spaces, with its natural smooth structure.

**Definition (Cotangent Lift).** For a smooth map $f: M \to N$, the cotangent lift (or pullback) is:
$$f^*: T^*N \to T^*M, \quad (q, \alpha) \mapsto (p, \alpha \circ df_p)$$
where $p$ is the preimage point and $df_p: T_pM \to T_{f(p)}N$ is the differential.

**Definition (Cotangent Functor).** $T^*: \mathbf{Man}^{\mathrm{op}} \to \mathbf{VectBun}$ is the contravariant functor sending:
- Objects: $M \mapsto T^*M$
- Morphisms: $f \mapsto f^*$

### Key Properties
- **Functoriality**: $(g \circ f)^* = f^* \circ g^*$ (reversal of composition order)
- **Identity**: $(\mathrm{id}_M)^* = \mathrm{id}_{T^*M}$

### Neural Network as Composition

A feedforward neural network with $n$ layers is a composition:
$$F = f_n \circ f_{n-1} \circ \cdots \circ f_1$$
where $f_i: \mathbb{R}^{d_{i-1}} \to \mathbb{R}^{d_i}$ is the $i$-th layer map (affine transformation followed by activation).

**Theorem (Backpropagation = Cotangent Lift).** The backpropagation algorithm computes:
$$F^* = f_1^* \circ f_2^* \circ \cdots \circ f_n^*$$
which is the cotangent lift of the forward map $F$, traversing layers in reverse order.

## 4. PROOF OVERVIEW

The proof proceeds by establishing the contravariant functoriality of the cotangent construction:

1. **Chain rule as functoriality**: The multivariate chain rule $d(g \circ f)_p = dg_{f(p)} \circ df_p$ directly implies $(g \circ f)^* = f^* \circ g^*$ by dualizing.

2. **Induction on network depth**: For a network $F = f_n \circ \cdots \circ f_1$, repeated application of the chain rule gives:
   $$F^* = (f_n \circ \cdots \circ f_1)^* = f_1^* \circ \cdots \circ f_n^*$$

3. **Identification with backprop**: Each $f_i^*$ corresponds to one step of backward propagation — multiplying by the transpose Jacobian $(\partial f_i / \partial x)^\top$ — which is precisely what the backpropagation algorithm computes at layer $i$.

4. **Formal verification**: In Lean 4, the structural theorem is captured as a type-theoretic statement and verified by the kernel.

### Key Lemmas
- Contravariance of pullback: `(g ∘ f)* = f* ∘ g*`
- Tangent-cotangent duality: `T*M ≅ (TM)*` as vector bundles
- Chain rule for smooth maps: `d(g ∘ f) = dg ∘ df`

## 5. NOVELTY ANALYSIS

While the observation that backpropagation is a cotangent lift is known in the differential geometry and automatic differentiation communities (cf. work by Fong, Spivak, and Tuyéras on backprop as a functor), our contribution is:

1. **Machine verification**: This is (to our knowledge) the first formally verified statement of this correspondence in a proof assistant.
2. **Categorical framing**: We explicitly use the language of contravariant functors rather than ad-hoc matrix transposition arguments.
3. **Generality**: The formulation works for arbitrary smooth manifolds, not just Euclidean spaces — enabling future formalization of geometric deep learning.
4. **Connection to tropical geometry**: The ReLU activation function's piecewise-linear structure connects to tropical algebraic geometry, where the max-plus semiring plays the role of the underlying algebra.

## 6. OPEN PROBLEMS

1. **Riemannian backpropagation**: Can the cotangent lift formulation be extended to include the Levi-Civita connection, giving a coordinate-free formulation of natural gradient descent on Riemannian parameter manifolds?

2. **Higher-order cotangent lifts**: Backpropagation computes first derivatives. Can the jet bundle functor $J^k: \mathbf{Man}^{\mathrm{op}} \to \mathbf{Bun}$ be used to formalize higher-order automatic differentiation (e.g., Hessian-vector products) with the same functorial elegance?

3. **Tropical backpropagation**: Since ReLU networks are piecewise-linear, their "derivatives" live in tropical geometry. Can the cotangent lift be defined over the tropical semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$, and does it yield a well-defined notion of tropical backpropagation with combinatorial (rather than analytic) structure?

## 7. REFERENCES

1. Fong, B., Spivak, D. I., and Tuyéras, R. "Backprop as Functor: A compositional perspective on supervised learning." *Proceedings of the 34th Annual ACM/IEEE Symposium on Logic in Computer Science (LICS)*, 2019.

2. Abraham, R. and Marsden, J. E. *Foundations of Mechanics*, 2nd edition. Benjamin/Cummings, 1978.

3. Spivak, M. *A Comprehensive Introduction to Differential Geometry*, Vol. 1, 3rd edition. Publish or Perish, 1999.

4. Griewank, A. and Walther, A. *Evaluating Derivatives: Principles and Techniques of Algorithmic Differentiation*, 2nd edition. SIAM, 2008.

5. Elliott, C. "The simple essence of automatic differentiation." *Proceedings of the ACM on Programming Languages*, 2(ICFP), 2018.

6. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, Vol. 161. AMS, 2015.
