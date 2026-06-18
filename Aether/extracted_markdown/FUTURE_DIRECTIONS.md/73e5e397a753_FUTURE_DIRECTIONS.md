# Future Directions: Tropical Kernel Dynamics

## Overview

The tropical NTK framework established in this work opens a new field at the intersection of tropical geometry, kernel methods, and neural network theory. Below are five concrete breakthrough directions, each with specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Formal Soft-Min to Tropical NTK Convergence

### Hypothesis
For the soft-min network $f_\tau(x) = -\tau \log \sum_{i \in S} \exp(-z_i(x)/\tau)$, the classical NTK $K_\tau(x, y) = \langle \nabla_\theta f_\tau(x), \nabla_\theta f_\tau(y) \rangle$ converges to the tropical NTK $K_{\mathrm{trop}}(x, y)$ on strict argmin cells as $\tau \to 0^+$.

### Proof Strategy
1. Compute the soft-min gradient explicitly: $\partial f_\tau / \partial W_{ik} = p_i^\tau(x) \cdot x_k$ where $p_i^\tau(x) = \exp(-z_i(x)/\tau) / \sum_j \exp(-z_j(x)/\tau)$.
2. Show that on a strict cell for $i_0$, $p_{i_0}^\tau(x) \to 1$ and $p_j^\tau(x) \to 0$ for $j \neq i_0$.
3. The NTK $K_\tau(x,y) = \sum_{i,k} p_i^\tau(x) p_i^\tau(y) x_k y_k + \sum_i p_i^\tau(x) p_i^\tau(y) \to \langle x, y \rangle + 1$.

### Key Lemmas Needed
- Pointwise convergence of softmax to argmax on strict cells
- Dominated convergence for the NTK sum
- Rate of convergence: $|K_\tau - K_{\mathrm{trop}}| = O(\tau)$ on compact subsets of strict cells

### Lean Formalization Target
```
theorem soft_min_ntk_converges_to_tropical :
  ∀ x y ∈ C(i₀), Filter.Tendsto (fun τ => K_τ(x, y)) (nhdsWithin 0 (Set.Ioi 0)) (nhds (K_trop(x, y)))
```

### Cross-Domain Connections
- **Maslov dequantization**: The soft-min → min limit is exactly Maslov's idempotent correspondence
- **Large deviations**: The convergence rate connects to Varadhan's lemma

---

## Direction 2: Tropical Gradient Flow as Differential Inclusion

### Hypothesis
Training a tropical network with squared loss on a finite dataset produces a piecewise-linear trajectory in parameter space. Within each chamber of the parameter-space cell decomposition, the dynamics are linear ODEs; at chamber walls, the dynamics undergo discontinuous transitions described by a differential inclusion.

### Proof Strategy
1. Define the squared loss $L(\theta) = \frac{1}{2} \sum_{n=1}^N (f_\theta(x_n) - y_n)^2$ for a tropical network.
2. Show that $L$ is piecewise quadratic in $\theta$ (since $f$ is piecewise linear in both $x$ and $\theta$).
3. On each parameter chamber, $\nabla_\theta L$ is affine in $\theta$, giving linear ODE dynamics.
4. At chamber boundaries, characterize the set of possible gradient directions as a differential inclusion.

### Key Lemmas
- Parameter-space cell decomposition: for each training point, the active branch depends on $\theta$
- Product cell structure: the combined cell for $N$ training points is an intersection of $N$ cells
- Piecewise-linearity of the loss gradient

### Applications
- **Exact training dynamics**: Solve training analytically within each parameter chamber
- **Wall-crossing algebra**: Develop a combinatorial algebra of parameter transitions
- **Convergence guarantees**: Prove convergence of tropical gradient descent to global optima on convex loss surfaces

---

## Direction 3: Sheaf Obstruction to Global Kernel Constancy

### Hypothesis
The tropical NTK defines a presheaf on the open cover of input space by strict argmin cells. The obstruction to extending this to a sheaf (i.e., the failure of kernel sections to glue across walls) is a cohomological invariant that measures the "depth of feature learning" needed by the network.

### Proof Strategy
1. Define the cover $\mathcal{U} = \{C(i_0)\}_{i_0 \in S}$ of the input space (up to walls).
2. On each $C(i_0)$, the kernel is $K_{i_0}(x, y) = \langle x, y \rangle + 1$ — a global section of the constant kernel.
3. On overlaps $C(i_0) \cap C(j_0)$ (which are empty for strict cells), trivially compatible.
4. The interesting structure arises at walls: define a Čech complex on a refined cover that includes wall neighborhoods.
5. Compute $H^1$ of this complex: nonzero classes correspond to kernel transitions that cannot be smoothly interpolated.

### Cross-Domain Connections
- **Čech cohomology**: Connect to existing formalized Čech complexes in the catalog
- **Sheaf theory for ML**: This would be the first example of sheaf cohomology measuring learning complexity
- **Characteristic classes**: Wall-crossing data defines a tropical characteristic class of the network

### Lean Formalization Target
Build on `zero_cochain_constant_iff_kernel` from the catalog to formalize the sheaf condition.

---

## Direction 4: Nonarchimedean Kernel Degeneration

### Hypothesis
The tropical NTK is the valuation shadow of an analytic NTK over a nonarchimedean field. Specifically, there exists a valued field extension $K$ of $\mathbb{R}$ and an analytic NTK $\hat{K}(x, y)$ over $K$ such that $\mathrm{val}(\hat{K}(x, y)) = K_{\mathrm{trop}}(x, y)$.

### Proof Strategy
1. Consider the Puiseux series field $K = \mathbb{R}\{\{t\}\}$ with valuation $\mathrm{val}(\sum a_n t^n) = \min\{n : a_n \neq 0\}$.
2. Define a neural network over $K$ with weights $\hat{W}_{ik} = t^{W_{ik}}$.
3. Show that $\mathrm{val}(f_K(x)) = \min_i z_i(x) = f_{\mathrm{trop}}(x)$.
4. Compute the NTK over $K$ and show its valuation equals the tropical NTK.

### Applications
- **Kernel degeneration theory**: Classify learning regimes by valuations
- **p-adic machine learning**: Extend to p-adic fields for number-theoretic applications
- **Motivic integration**: Connect to motivic measures on the parameter space

### Key Technical Challenge
The NTK involves derivatives, so we need a theory of differentiation over nonarchimedean fields (rigid analytic geometry or Berkovich spaces).

---

## Direction 5: Certified Robustness of Training Trajectories

### Hypothesis
If a training trajectory stays within a fixed parameter-space chamber, then the entire trajectory — not just individual predictions — is certifiably robust: small perturbations to the training data, learning rate, or initialization produce trajectories that remain in the same chamber and converge to the same fixed point.

### Proof Strategy
1. Within a parameter chamber, the loss is quadratic and the gradient is affine.
2. Gradient descent on a quadratic with affine gradient is a linear dynamical system.
3. The convergence basin of this linear system is computable.
4. Perturbations to training data shift the quadratic coefficients; compute the sensitivity.
5. The robustness radius is the minimum perturbation that causes the trajectory to exit the chamber.

### Key Lemmas
- Linear stability analysis of piecewise-linear gradient descent
- Sensitivity of affine gradient dynamics to coefficient perturbations
- Chamber-exit time estimation

### Applications
- **Reproducibility guarantees**: Certify that training produces the same model under small data perturbations
- **Privacy**: Chamber-preserving perturbations cannot reveal individual training points
- **Hardware robustness**: Floating-point errors that stay within a chamber don't affect the learning outcome

---

## Implementation Roadmap

### Phase 1 (Immediate, 1–3 months)
- Direction 1: Soft-min convergence (builds directly on current formalization)
- Extend current theorems to multi-class tropical networks

### Phase 2 (Medium-term, 3–6 months)
- Direction 2: Tropical gradient flow (requires parameter-space cell decomposition)
- Direction 5: Certified training robustness (builds on Direction 2)

### Phase 3 (Long-term, 6–12 months)
- Direction 3: Sheaf obstruction (requires Čech cohomology formalization)
- Direction 4: Nonarchimedean degeneration (requires rigid analytic geometry)

### Cross-Cutting Themes
- All directions benefit from formalizing multi-layer tropical networks
- The sheaf and nonarchimedean perspectives may unify into a single framework
- Computational experiments should guide formalization priorities
