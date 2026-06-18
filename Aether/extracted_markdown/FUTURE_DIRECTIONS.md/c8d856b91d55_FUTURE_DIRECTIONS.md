# Future Directions: Quantum EML Activation Geometry

## Conjecture 1: Bi-Lipschitz Chart Away from the Antipodal Point

**Precise Statement.** Let $B_R = \{H \in \mathfrak{su}(2) : \|H\| \leq R\}$ for any $R > 0$. The map $\Phi_R: B_R \to \mathrm{SU}(2)$ defined by $\Phi_R(H) = \mathrm{qEMLnorm}(H)$ is bi-Lipschitz: there exist constants $0 < c_R \leq C_R$ such that
$$c_R \|H - K\| \leq \|\Phi_R(H) - \Phi_R(K)\| \leq C_R \|H - K\|$$
for all $H, K \in B_R$, where norms are the operator norm on $2 \times 2$ matrices.

**Test.** Monte Carlo sampling of $10^6$ pairs $(H, K)$ with $\|H\|, \|K\| \leq R$ for $R \in \{1, 5, 10, 50\}$. Compute the ratio $\|\Phi_R(H) - \Phi_R(K)\| / \|H - K\|$ and check whether it stays bounded above and below. Plot histograms of the ratio for each $R$.

**Impact.** If true, this establishes that the qEML chart is a **bi-Lipschitz embedding** of the Lie algebra into the group, which is the strongest possible form of numerical stability for gradient-based optimization. It would guarantee that gradient descent in parameter space faithfully reflects movement on SU(2), with no vanishing or exploding gradients from the parameterization itself.

---

## Conjecture 2: Two-Factor qEML Universality for SU(4)

**Precise Statement.** Every $U \in \mathrm{SU}(4)$ can be written as
$$U = (V_1 \otimes W_1) \cdot \exp(i \sum_{j} \alpha_j \sigma_j \otimes \sigma_j) \cdot (V_2 \otimes W_2)$$
where each of $V_1, W_1, V_2, W_2$ is in the image of the qEML chart (i.e., expressible as $\mathrm{qEMLnorm}(H, c)$ for traceless Hermitian $H$), and the interaction term uses at most 3 real parameters $\alpha_j$.

**Test.** Numerical optimization: for 1000 random Haar-distributed SU(4) matrices, optimize over the 15 real parameters $(x_i, y_i, z_i)_{i=1}^4 \cup (\alpha_1, \alpha_2, \alpha_3)$ to minimize $\|U - U_{\text{synth}}\|$. Check whether the minimum achievable error is $< 10^{-10}$ in all cases.

**Impact.** This would extend the single-qubit qEML universality to **two-qubit gates**, establishing qEML as a practical parameterization for variational quantum circuits. The KAK decomposition guarantees that such a factorization exists in principle; the conjecture asserts it works with qEML local factors rather than arbitrary SU(2) elements.

---

## Conjecture 3: Depth-Efficiency of qEML Networks

**Precise Statement.** For any continuous function $f: \mathrm{SU}(2) \to \mathbb{R}$ and $\varepsilon > 0$, there exists a composition of $O(\varepsilon^{-1/2})$ qEML activations (with trainable Hermitian parameters) that approximates $f$ to within $\varepsilon$ in the $L^2(\mathrm{SU}(2))$ norm with respect to Haar measure. Moreover, this depth bound is tight: some smooth functions require $\Omega(\varepsilon^{-1/2})$ layers.

**Test.** Train qEML networks of varying depth to approximate known spherical harmonics (restricted to SU(2) via the double cover $\mathrm{SU}(2) \to \mathrm{SO}(3)$). Plot the approximation error versus depth and compare against the conjectured $O(d^{-2})$ convergence rate.

**Impact.** This would establish a **universal approximation theorem** for qEML networks on compact Lie groups, directly analogous to the classical universal approximation results for ReLU networks. It would provide theoretical justification for using qEML layers in quantum neural networks.

---

## Conjecture 4: Riemannian Gradient Flow Convergence

**Precise Statement.** Consider the optimization problem: given target $U_* \in \mathrm{SU}(2)$ with $\mathrm{tr}(U_*) > 0$, minimize $L(H) = \|\mathrm{qEMLnorm}(H) - U_*\|_F^2$ over traceless Hermitian $H$. The gradient flow $\dot{H}(t) = -\nabla L(H(t))$ converges to the global minimum $H_*$ (with $\mathrm{qEMLnorm}(H_*) = U_*$) from any initialization $H(0)$, and the convergence is exponential: $\|H(t) - H_*\| \leq C e^{-\lambda t}$ for some $C, \lambda > 0$ depending on $\mathrm{tr}(U_*)$.

**Test.** Run gradient descent with various step sizes and initializations for 100 random targets $U_*$. Verify exponential convergence by plotting $\log \|H(t) - H_*\|$ vs $t$ and checking linearity. Measure how the convergence rate $\lambda$ depends on $\mathrm{tr}(U_*)$.

**Impact.** This would prove that qEML parameterization has **no spurious local minima** for single-gate optimization, a property that distinguishes it from many neural network loss landscapes. This has immediate practical implications for quantum circuit training.

---

## Conjecture 5: Quantum EML on Higher-Rank Groups via Cartan Decomposition

**Precise Statement.** For any compact semisimple Lie group $G$ with Lie algebra $\mathfrak{g}$, define the generalized qEML chart:
$$\Phi(H) = (I + iH)(I + H^2)^{-1/2}, \quad H \in \mathfrak{g}$$
(where $(I + H^2)^{-1/2}$ is defined via functional calculus on the positive-definite matrix $I + H^2$). Then $\Phi$ maps $\mathfrak{g}$ into $G$ and covers the connected component of the identity containing all elements with $\mathrm{Re}(\mathrm{tr}(\rho(g))) > 0$ for the adjoint representation $\rho$.

For $G = \mathrm{SU}(n)$, the image of $\Phi$ contains all elements $U$ with $\mathrm{Re}(\mathrm{tr}(U)) > 0$.

**Test.** For $G = \mathrm{SU}(3)$ and $\mathrm{SU}(4)$: (a) verify that $\Phi(H)$ is always unitary with determinant 1 for random traceless Hermitian $H$; (b) sample random unitaries with positive trace and attempt to invert the map numerically using Newton's method.

**Impact.** This would generalize the entire qEML framework from SU(2) to arbitrary compact Lie groups, opening applications to multi-qubit quantum computing, gauge theories in physics, and representation-theoretic machine learning. The $H^2 = c \cdot I$ simplification is specific to SU(2); for higher-rank groups, $H^2$ is not scalar, so the square root requires genuine matrix functional calculus — making this conjecture substantially harder and more mathematically interesting.
