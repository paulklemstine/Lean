# Future Directions: Quantum Tropical Dynamics

## Overview

The formalization of quantum tropical operators—soft min-plus maps with entropy regularization—and their eigenvector theory opens several concrete research frontiers. Each direction below includes a precise mathematical statement, proof strategy, and cross-domain significance.

---

## 1. Quantum Tropical Collatz–Wielandt Theorem

### Statement
For the quantum tropical operator $T_{\beta,A}$ with eigenvalue $\lambda(\beta)$, prove the variational characterization:
$$
\lambda(\beta) = \max_{x:\, x_0=0} \min_i \left[ T_{\beta,A}(x)_i - x_i \right] = \min_{x:\, x_0=0} \max_i \left[ T_{\beta,A}(x)_i - x_i \right].
$$

### Proof Strategy
1. Prove the "max-min ≤ eigenvalue" direction using monotonicity: for any $x$ with $T(x) \geq x + c$, additive homogeneity implies $T^k(x) \geq x + kc$, contradicting boundedness of the normalized iterates unless $c \leq \lambda$.
2. Prove the reverse using the eigenvector: at $x^*$ with $T(x^*) = x^* + \lambda$, both max and min equal $\lambda$.
3. Formalize the duality $\max\min = \min\max$ using the fact that the "excess function" $\phi_c(x) = \max_i [T(x)_i - x_i - c]$ is continuous and monotone in $c$.

### Key Lemmas
- `qtrop_eigenvalue_le_max_min`: $\lambda \leq \max_{x} \min_i [T(x)_i - x_i]$
- `min_max_le_qtrop_eigenvalue`: $\min_{x} \max_i [T(x)_i - x_i] \leq \lambda$
- `collatz_wielandt_equality`: The max-min equals the min-max equals $\lambda$.

### Significance
This is the nonlinear spectral theory analogue of the classical Collatz–Wielandt formula for nonneg matrices. It gives a computable characterization of the eigenvalue and connects to game-theoretic interpretations (player 1 chooses $x$, player 2 chooses $i$).

---

## 2. Decoherence Stability Theorem

### Statement
Quantify how the normalized eigenvector $x^*(\beta)$ and eigenvalue $\lambda(\beta)$ depend on $\beta$:
$$
|\lambda(\beta) - \lambda_{\mathrm{trop}}| \leq \frac{\log n}{\beta}, \qquad \|x^*(\beta) - x^*_{\mathrm{trop}}\|_\infty \leq C(A) \cdot \frac{\log n}{\beta},
$$
where $\lambda_{\mathrm{trop}}$ and $x^*_{\mathrm{trop}}$ are the classical tropical (min-plus) eigenvalue and eigenvector.

### Proof Strategy
1. Use the coordinatewise sandwich bounds $m_i - \log(n)/\beta \leq T_{\beta,A}(x)_i \leq m_i$ (already proved) to bound $|T_{\beta,A}(x) - T^{\min}_A(x)|_\infty \leq \log(n)/\beta$.
2. Apply a perturbation argument: if two additively homogeneous maps are $\epsilon$-close pointwise, their eigenvalues differ by at most $\epsilon$ and their normalized eigenvectors differ by at most $C \cdot \epsilon$ (where $C$ depends on the contraction coefficient of the tropical map).
3. The contraction coefficient is $\tanh(\Delta_A/4)$ where $\Delta_A$ is the diameter of the matrix entries (Birkhoff's theorem).

### Key Lemmas
- `qtrop_eigenvalue_approx`: $|\lambda(\beta) - \lambda_{\mathrm{trop}}| \leq \log(n)/\beta$
- `qtrop_eigenvector_approx`: Lipschitz bound on eigenvector perturbation
- `birkhoff_contraction_coefficient`: The contraction constant for the normalized map

### Significance
This is the precise version of "decoherence does not destroy fixed-point structure beyond $O(\log n / \beta)$." It gives an explicit error budget for using quantum tropical operators as surrogates for hard tropical (zero-temperature) computations.

---

## 3. Soft Logical Semantics and Graded Fixed Points

### Statement
Replace Boolean conjunction by $\mathrm{qmin}_\beta$ in a propositional valuation framework. Define a graded truth-value operator $\Phi_\beta : [0,1]^n \to [0,1]^n$ where each variable's "truth" is the soft minimum of its defining clauses (evaluated under the current assignment). Prove:
$$
\exists v \in [0,1]^n,\; \Phi_\beta(v) = v,
$$
and show this fixed point converges to a Boolean satisfying assignment (if one exists) as $\beta \to \infty$.

### Proof Strategy
1. Define $\Phi_\beta$ using normalized log-sum-exp applied to clause evaluation functions.
2. Show $\Phi_\beta$ maps $[0,1]^n$ to itself (bounded, continuous).
3. Apply Brouwer's fixed-point theorem (or the quantum tropical eigenvector machinery) to obtain $v$.
4. Prove convergence of $v(\beta)$ to a Boolean vector using the tropical approximation bounds.

### Key Lemmas
- `soft_clause_eval`: Log-sum-exp evaluation of a clause
- `soft_valuation_fixed_point`: Fixed point of the graded truth-value operator
- `graded_to_boolean_limit`: Convergence as $\beta \to \infty$

### Significance
This creates a bridge between tropical dynamics and automated reasoning. The graded fixed point provides a continuous relaxation of SAT that is both theoretically principled (eigenvector of a soft logical operator) and practically useful (differentiable, amenable to gradient-based search).

---

## 4. Entropy-Regularized Shortest Paths and Soft Value Functions

### Statement
For a weighted directed graph with adjacency matrix $A$ and discount factor $\gamma \in (0,1)$, show that the discounted soft Bellman equation
$$
V(i) = \gamma \cdot T_{\beta,A}(V)(i) = -\frac{\gamma}{\beta} \log\left(\sum_j e^{-\beta(A_{ij} + V_j)}\right)
$$
has a unique fixed point $V^*_\beta$, and $V^*_\beta \to V^*_{\mathrm{trop}}$ as $\beta \to \infty$ where $V^*_{\mathrm{trop}}$ is the hard shortest-path value function.

### Proof Strategy
1. Show $\gamma \cdot T_{\beta,A}$ is a contraction in $\|\cdot\|_\infty$ with constant $\gamma < 1$ (follows from nonexpansiveness of $T_{\beta,A}$ in the sup-norm, which is a consequence of additive homogeneity plus monotonicity).
2. Apply Banach fixed-point theorem to obtain $V^*_\beta$.
3. Use the tropical approximation bounds to show $\|V^*_\beta - V^*_{\mathrm{trop}}\|_\infty \leq \frac{\gamma \log n}{(1-\gamma)\beta}$.

### Key Lemmas
- `qtrop_nonexpansive`: $\|T_{\beta,A}(x) - T_{\beta,A}(y)\|_\infty \leq \|x - y\|_\infty$
- `discounted_bellman_contraction`: $\gamma \cdot T_{\beta,A}$ is a contraction
- `soft_value_function_existence`: Unique fixed point of discounted soft Bellman
- `soft_to_hard_value_convergence`: Convergence bound

### Significance
This connects quantum tropical dynamics directly to reinforcement learning and dynamic programming. The soft value function is the mathematical core of entropy-regularized MDPs (e.g., soft actor-critic algorithms). Having a formal proof of existence, uniqueness, and convergence bounds would be the first machine-verified foundation for this widely-used algorithmic framework.

---

## 5. Quantum Tropical Renormalization Flow

### Statement
Define the renormalization map $R : (\mathrm{Fin}\,n \to \mathbb{R}) \to (\mathrm{Fin}\,n \to \mathbb{R})$ by
$$
R(x) = \mathrm{normalize}_0(T_{\beta,A}(x)).
$$
Prove:
1. The orbit $\{R^k(x_0)\}_{k \geq 0}$ is bounded for any initial $x_0$.
2. The $\omega$-limit set $\omega(x_0) = \bigcap_N \overline{\{R^k(x_0) : k \geq N\}}$ is nonempty, compact, and $R$-invariant.
3. Every point in $\omega(x_0)$ is a fixed point of $R$ (i.e., a normalized eigenvector of $T_{\beta,A}$).

### Proof Strategy
1. Boundedness: already proved via `normalize_qTropMap_bounded`.
2. $\omega$-limit set: standard topological dynamics (Bolzano-Weierstrass in finite dimensions).
3. Fixed-point property: use the fact that $R$ is a strict contraction in the Hilbert projective metric (Birkhoff's theorem), so the $\omega$-limit set must be a single point.

### Key Lemmas
- `renormalization_orbit_bounded`: Orbit stays in a compact set
- `omega_limit_nonempty`: The $\omega$-limit set is nonempty
- `omega_limit_fixed`: Every point in the $\omega$-limit set is a fixed point
- `hilbert_projective_contraction`: $R$ is a contraction in the Hilbert metric

### Significance
This frames the eigenvector computation as a renormalization group flow, connecting to conformal field theory and statistical mechanics. The "attractor" of the renormalization is the eigenvector, and the "flow" is the normalized power iteration. Classifying the attractors and their basins of attraction would give a complete topological picture of quantum tropical dynamics.

---

## Dependencies and Suggested Order

1. **Direction 4** (Soft Bellman) is the most immediately achievable: it only requires proving nonexpansiveness (which follows from the existing additive homogeneity) and applying the already-available Banach fixed-point theorem.

2. **Direction 2** (Decoherence Stability) is next: it builds directly on the existing sandwich bounds and requires only a perturbation analysis.

3. **Direction 1** (Collatz-Wielandt) builds on both the eigenvector theorem and the variational structure.

4. **Directions 3 and 5** are more speculative but would open entirely new research areas.

## Infrastructure Needed

- **Brouwer's fixed-point theorem**: Currently the sole unproved assumption (used via Perron-Frobenius). Adding Brouwer to Mathlib would close this gap and enable Directions 3 and 5.
- **Hilbert projective metric**: Needed for Direction 5 and for proving uniqueness of the eigenvector.
- **Birkhoff's contraction theorem**: Needed for Directions 2 and 5.
