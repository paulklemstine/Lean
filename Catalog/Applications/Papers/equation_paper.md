# Backpropagation as the Cotangent Lift of the Forward Map

## 1. ABSTRACT

We formalize and verify the observation that the backpropagation algorithm, ubiquitous in training neural networks, is precisely the *cotangent lift* (pullback on cotangent bundles) of the forward evaluation map in the category of smooth manifolds. Given a composition of smooth parameterized maps $f = f_L \circ \cdots \circ f_1$ representing a neural network's forward pass, the chain rule of differential calculus produces the transpose (adjoint) of the total derivative. This transpose, computed layer by layer in reverse order, is exactly the backpropagation algorithm. Our Lean 4 formalization captures this correspondence at the type level, establishing that backprop is not an ad-hoc algorithm but a canonical construction in differential geometry: the contravariant functorial action of the cotangent bundle functor $T^*$ applied to the forward map.

## 2. MOTIVATION

Understanding backpropagation geometrically has profound implications:

- **Correctness guarantees**: By identifying backprop with a canonical geometric construction, we obtain correctness "for free" from the functoriality of the cotangent bundle.
- **Generalizations**: The cotangent perspective immediately suggests extensions to Riemannian manifolds, Lie groups, and other non-Euclidean parameter spaces — crucial for geometric deep learning.
- **Automatic differentiation**: Modern AD systems (JAX, PyTorch) implement reverse-mode AD, which is exactly the cotangent lift. Formalizing this connection grounds AD correctness in differential geometry.
- **Scientific computing**: Adjoint methods in PDE-constrained optimization, optimal control, and meteorological data assimilation are all instances of the same cotangent lift principle.

## 3. MATHEMATICAL FRAMEWORK

### Definitions and Notation

**Smooth manifold.** A topological space $M$ equipped with a maximal smooth atlas. In the neural network context, parameter spaces and activation spaces are open subsets of $\mathbb{R}^n$, hence trivially smooth manifolds.

**Cotangent bundle.** For a smooth manifold $M$, the cotangent bundle $T^*M = \coprod_{p \in M} T^*_p M$ is the disjoint union of all cotangent spaces. A covector $\xi \in T^*_p M$ is a linear functional on the tangent space $T_p M$.

**Cotangent lift (pullback).** Given a smooth map $f : M \to N$, the cotangent lift is:
$$f^* : T^*N \to T^*M, \quad (q, \eta) \mapsto (p, (Df_p)^T \eta)$$
where $q = f(p)$ and $(Df_p)^T$ is the transpose of the derivative.

**Forward map.** A neural network with $L$ layers defines a composition:
$$F = f_L \circ f_{L-1} \circ \cdots \circ f_1 : \mathbb{R}^{n_0} \to \mathbb{R}^{n_L}$$

**Backpropagation.** Starting from an output gradient $\delta_L \in T^*_{F(x)} \mathbb{R}^{n_L}$, backprop computes:
$$\delta_\ell = (Df_{\ell+1})^T \cdot \delta_{\ell+1}, \quad \ell = L-1, \ldots, 0$$

### Key Identity

By the chain rule and the contravariant functoriality of $T^*$:
$$F^* = f_1^* \circ f_2^* \circ \cdots \circ f_L^*$$

This is precisely the backpropagation recursion, read from the output layer backward.

## 4. PROOF OVERVIEW

### High-Level Strategy

1. **Functoriality of T\*.** The cotangent bundle assignment $M \mapsto T^*M$, $f \mapsto f^*$ defines a contravariant functor from the category of smooth manifolds to itself. The key property is $(g \circ f)^* = f^* \circ g^*$.

2. **Chain rule.** For smooth $f : M \to N$ and $g : N \to P$, we have $D(g \circ f)_p = Dg_{f(p)} \circ Df_p$. Transposing: $(D(g \circ f)_p)^T = (Df_p)^T \circ (Dg_{f(p)})^T$.

3. **Identification.** The backprop recursion $\delta_\ell = (Df_{\ell+1})^T \delta_{\ell+1}$ is exactly the pointwise evaluation of $f_1^* \circ \cdots \circ f_L^*$ at a given covector—i.e., the cotangent lift of the composite forward map.

### Key Lemma

The chain rule for cotangent lifts: for $f : M \to N$, $g : N \to P$ smooth,
$$(g \circ f)^* = f^* \circ g^*$$

This is the fundamental identity that makes backpropagation correct.

### Lean Formalization

In our Lean 4 formalization, the theorem `backprop_cotangent_lift` encodes the validated mathematical correspondence. The proof leverages Mathlib's differential geometry and category theory libraries to establish the result at the appropriate level of generality.

## 5. NOVELTY ANALYSIS

- **Conceptual clarity.** While the connection between backprop and adjoints of linear maps has been folklore since the 1970s (Linnainmaa, Werbos), the *precise* identification with the cotangent lift functor is relatively recent in the formal mathematics literature.
- **Formal verification.** To our knowledge, this is among the first machine-verified formalizations of the backprop-as-cotangent-lift correspondence.
- **Categorical perspective.** Framing backprop as a natural transformation in a functor category opens the door to higher categorical generalizations (e.g., ∞-categorical AD, optic-based lenses).
- **Unification.** The cotangent lift viewpoint unifies backprop with adjoint methods in PDE theory, symplectic mechanics, and information geometry under a single geometric umbrella.

## 6. OPEN PROBLEMS

1. **Higher-order backpropagation as jet bundle lifts.** Can higher-order reverse-mode AD (computing Hessians, etc.) be formalized as the lift to the $k$-th order jet bundle $J^k(M, N)$? What is the correct categorical framework for iterated cotangent constructions?

2. **Backprop on singular spaces.** Real neural networks use non-smooth activations (ReLU, max-pooling). Can the cotangent lift be extended to stratified spaces or o-minimal structures to cover these cases? The tropical geometry of ReLU networks (viewing ReLU as the tropical addition $\max(0, x)$) suggests a connection to tropical cotangent complexes.

3. **Synthetic differential geometry for AD.** Can backpropagation be formalized in synthetic differential geometry (SDG), where infinitesimals are first-class objects? SDG's internal language might yield a more natural type-theoretic formulation of reverse-mode AD, potentially leading to new compiler optimizations.

## 7. REFERENCES

1. S. Linnainmaa, "The representation of the cumulative rounding error of an algorithm as a Taylor expansion of the local rounding errors," *Master's thesis*, University of Helsinki, 1970.

2. P. Werbos, "Beyond Regression: New Tools for Prediction and Analysis in the Behavioral Sciences," *PhD thesis*, Harvard University, 1974.

3. D. E. Rumelhart, G. E. Hinton, and R. J. Williams, "Learning representations by back-propagating errors," *Nature*, vol. 323, pp. 533–536, 1986.

4. B. Fong, D. Spivak, and R. Tuyéras, "Backprop as Functor: A compositional perspective on supervised learning," *Proceedings of the 34th Annual ACM/IEEE Symposium on Logic in Computer Science (LICS)*, 2019.

5. C. Cruttwell, B. Gavranović, N. Ghani, P. Wilson, and F. Zanasi, "Categorical Foundations of Gradient-Based Learning," *ESOP 2022*, Lecture Notes in Computer Science, vol. 13240, Springer, 2022.

6. M. Elliott, "A simple and compositional framework for automatic differentiation," *arXiv:1804.00746*, 2018.

7. R. Abraham and J. E. Marsden, *Foundations of Mechanics*, 2nd edition, AMS Chelsea Publishing, 2008.

8. J. Lee, *Introduction to Smooth Manifolds*, 2nd edition, Graduate Texts in Mathematics 218, Springer, 2012.
