# Future Directions: Tropical Phase Transitions in Learning

## 1. Multi-dimensional tropical bifurcation and ReLU network expressivity

The current work formalizes phase transitions for one-dimensional tropical polynomials (max of affine functions in one variable). The natural extension is to ℝⁿ: a tropical polynomial in n variables is `max_i(⟨aᵢ, x⟩ + bᵢ)` where `aᵢ ∈ ℝⁿ`. The tropical hypersurface (set where the max is achieved by ≥2 monomials) is a polyhedral complex whose combinatorial structure determines the decision boundaries of a ReLU network layer.

**Conjecture**: For a tropical polynomial with m monomials in ℝⁿ, the tropical hypersurface has at most `m choose 2` facets of codimension 1, and this bound is tight. The key insight is that each facet corresponds to a pair of monomials achieving co-dominance, and the arrangement of these hyperplanes `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ` is governed by the same linear algebra that controls ReLU network decision boundaries.

**Why now?** The one-dimensional crossover theory is fully formalized. Extending to ℝⁿ requires formalizing tropical hypersurfaces as polyhedral complexes, which is tractable given Mathlib's growing polyhedral geometry infrastructure.

## 2. Tropical gradient flow and delayed generalization dynamics

The bifurcation theorem shows that parameter changes cause monomial dominance switches. A deeper question: what is the dynamics of these switches under gradient descent? In the tropical limit, gradient descent on a loss landscape `L(θ) = max_i fᵢ(θ)` becomes a piecewise-linear dynamical system whose trajectories follow the 1-skeleton of a polyhedral complex.

**Conjecture**: For a tropical loss landscape with k monomials, the gradient flow trajectory crosses at most `k - 1` phase boundaries before converging, and the time spent in each region is bounded below by `Ω(1/gap)` where gap is the minimum spectral gap between co-dominant monomials at a boundary. The key insight is that the "delayed generalization" phenomenon (grokking) corresponds to the trajectory spending exponential time near a phase boundary where the gap is exponentially small — a tropical analogue of the classical saddle-point slowdown.

**Why now?** The crossover monotonicity theorem (`crossover_monotone_in_gap`) provides the foundation: it shows that the phase boundary position depends continuously and monotonically on parameters, which is the first step toward analyzing gradient flow near boundaries.

## 3. Tropical Legendre duality and implicit regularization

The Legendre-Fenchel transform has a natural tropical analogue: for `f(x) = max_i(aᵢx + bᵢ)`, the tropical Legendre dual is `f*(y) = -min_i(bᵢ : aᵢ = y)` (the negative of the intercept of the monomial with slope y). This duality exchanges the "weight space" and "feature space" views of a ReLU network.

**Conjecture**: Implicit regularization in neural network training (the tendency of gradient descent to find minimum-norm solutions) corresponds to selecting the tropical polynomial whose Legendre dual has minimum total variation. The key insight is that minimum total variation of `f*` is equivalent to the Newton polygon of the tropical polynomial having minimum perimeter, which selects the "simplest" piecewise-linear function consistent with the training data.

**Why now?** The convexity theorem (`tropical_poly_convexOn`) establishes that tropical polynomials are convex, which is the essential prerequisite for Legendre duality to be well-defined and involutive.

## 4. Tropical composition and depth separation

A two-layer ReLU network computes `max_j(∑ₖ w₂ⱼₖ · max_i(w₁ₖᵢ · x + b₁ₖᵢ) + b₂ⱼ)`, which is the tropical composition of two tropical polynomials. The composition operation is not a tropical polynomial in general — it produces a "tropical rational function" (difference of two tropical polynomials).

**Conjecture**: The set of functions computable by depth-d tropical circuits with width w is strictly contained in the set computable by depth-(d+1) circuits with width w, for all d ≥ 1 and w ≥ 2. Moreover, the separation is witnessed by a function whose tropical hypersurface has a topological invariant (Betti number) that requires depth d+1 to realize. The key insight is that tropical composition can increase the number of "bends" multiplicatively, and the Betti numbers of the resulting polyhedral complex serve as a depth-lower-bound certificate.

**Why now?** The `tropical_sum_two_convexOn` and `tropical_poly_convexOn` results formalize how tropical addition (max) preserves convexity. Extending to tropical composition requires tracking how convexity interacts with the nested max-plus structure, which is the next natural step.

## 5. Quantitative grokking bounds via tropical spectral theory

The eigenvalues of tropical (max-plus) matrices control the long-term behavior of iterated tropical matrix-vector multiplication. If training dynamics can be approximated as iterated tropical linear maps `x ↦ A ⊗ x` (where ⊗ is tropical matrix multiplication), then the tropical spectral radius determines the convergence rate.

**Conjecture**: For a training process on a dataset of size n with a two-layer ReLU network of width w, the grokking time (number of epochs before generalization) is Θ(exp(n/w) · 1/λ₂) where λ₂ is the second-largest tropical eigenvalue of the weight matrix. The key insight is that the tropical eigenvalue gap λ₁ - λ₂ controls how quickly the dominant monomial separates from competitors, and the exponential factor captures the time spent in the "memorization" phase where all monomials are nearly co-dominant.

**Why now?** The bifurcation threshold theorem provides the static characterization of when dominance switches occur. The spectral theory would provide the dynamic characterization of how fast the system moves toward or away from these switch points, completing the picture.
