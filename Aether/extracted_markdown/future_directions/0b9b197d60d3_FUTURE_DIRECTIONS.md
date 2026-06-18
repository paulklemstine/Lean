# Future Directions: Tropical Compression Dominance

## Hypothesis 1: Multiplicative Quotient Complexity Under Composition

**Conjecture:** For layered architectures where each layer has an independent symmetry group $G_i$ acting on its parameters, the total quotient complexity satisfies
$$
C_q(\text{network}) \leq \prod_{i=1}^{L} \frac{d_i}{|G_i|}
$$
where $d_i$ is the parameter count of layer $i$. If the symmetry groups compose coherently (e.g., translation symmetry propagating through layers in a CNN), the bound tightens to the quotient of the total parameter count by the product of group orders.

**Test:** Implement a multi-layer architecture descriptor in Python. Compute layerwise quotient complexities for: (a) a 3-layer CNN with same-sized kernels, (b) a 2-layer equivariant MLP, (c) a hybrid CNN-attention model. Compare the product-of-quotients formula against direct orbit-counting on the full parameter space. If the product formula overestimates by more than a constant factor for any tested architecture, the multiplicative hypothesis fails and must be replaced by a subadditive model.

**Impact:** If true, this would enable closed-form sample complexity predictions for arbitrary deep networks from their architecture specifications alone, without training.

---

## Hypothesis 2: Quotient Complexity Predicts Test Error Rank Order

**Conjecture:** Among architectures with the same total parameter count $d$ trained on the same dataset, the architecture with the smallest quotient complexity $d/|G|$ achieves the lowest test error, up to logarithmic corrections. Formally: for any pair of architectures $A_1, A_2$ with $d_1 = d_2$ but $|G_1| > |G_2|$, the test error of $A_1$ on sufficiently large datasets is at most that of $A_2$ with probability at least $1 - \delta$.

**Test:** Train pairs of networks with matched parameter counts but different symmetry structures on CIFAR-10 and ImageNet-1k. Compare: (a) standard CNN vs. locally-connected network (CNN has translational symmetry, locally-connected does not), (b) permutation-equivariant MLP vs. standard MLP on set-structured tasks, (c) multi-head attention with head-permutation symmetry vs. ordered attention. Record test error at convergence for 10 random seeds. If the lower-quotient-complexity architecture fails to beat the higher one in >30% of trials, the conjecture is refuted.

**Impact:** This would establish quotient complexity as a practical model selection criterion, replacing or supplementing cross-validation.

---

## Hypothesis 3: Continuous Symmetry Groups Yield Logarithmic Quotient Complexity

**Conjecture:** For architectures with continuous symmetry groups (e.g., rotational equivariance with $G = SO(2)$ or $SO(3)$), the effective quotient complexity scales as $O(d / \dim(G))$ where $\dim(G)$ is the Lie algebra dimension, not merely $d / |G|$ (which is undefined for infinite groups). For $SO(3)$-equivariant networks with $d$ parameters, the quotient complexity should be approximately $d/3$.

**Test:** Implement $SO(3)$-equivariant architectures (e.g., Tensor Field Networks, SE(3)-Transformers) and count the number of independent parameters after accounting for rotational invariance. Compare the predicted quotient complexity $d/3$ against the empirical number of free parameters. If the actual orbit-space dimension differs from $d/\dim(G)$ by more than a factor of 2 for standard architectures, the continuous extension of the hypothesis needs revision.

**Impact:** Extending quotient complexity to continuous groups would unify the treatment of finite symmetries (CNNs, permutation equivariance) and continuous symmetries (rotational equivariance, gauge equivariance in physics), creating a complete symmetry-aware learning theory.

---

## Hypothesis 4: Tropical Compression Dominance Ratio Exceeds $|G|/\log d$

**Conjecture:** For the algebraic sample complexity bound $\text{SC}(d, \varepsilon, \delta) = d \cdot \log(1/\varepsilon) + \log(1/\delta)$, the ratio
$$
\frac{\text{SC}(d, \varepsilon, \delta)}{\text{SC}(d/|G|, \varepsilon, \delta)}
$$
eventually exceeds $|G| / \log d$ as $d \to \infty$ with $|G|$ fixed or growing polynomially. Under the stronger hypothesis $|G| = \Theta(d^\alpha)$ for some $\alpha > 0$, the ratio grows polynomially.

**Test:** Fix $\varepsilon = 0.01$, $\delta = 0.05$. For architecture families indexed by input size $n$:
- CNN: $d = n^2 k^2$, $|G| = n^2$, compute ratio for $n = 10, 50, 100, 500, 1000$.
- Permutation-equivariant MLP: $d = n^2$, $|G| = n!$, compute for $n = 3, 5, 7, 10$.
- Attention: $d = h \cdot d_k^2$, $|G| = h!$ where $h$ is number of heads, compute for $h = 2, 4, 8, 16$.
If the ratio falls below $|G| / \log d$ for any architecture family at any tested size, the conjecture is falsified in its current form.

**Impact:** This would quantify the asymptotic advantage of symmetric architectures, providing theoretical justification for the empirical dominance of CNNs and equivariant networks.

---

## Hypothesis 5: Operadic Composition Laws for Quotient Complexity

**Conjecture:** There exists an operad $\mathcal{O}$ whose algebras are symmetry-constrained architecture specifications, such that the quotient complexity is a morphism from $\mathcal{O}$-algebras to $(\mathbb{N}, +)$ or $(\mathbb{N}, \times)$. In particular, sequential composition of layers should be additive in quotient complexity, while parallel composition (e.g., multi-head attention) should be multiplicative.

**Test:** 
1. Define the composition operations formally: sequential composition = function composition of layers, parallel composition = direct sum of parameter spaces with independent symmetries.
2. Compute quotient complexities for: (a) ResNet blocks (sequential + skip), (b) Inception modules (parallel branches), (c) multi-head attention (parallel heads + sequential projection).
3. Check whether $C_q(\text{sequential}(A, B)) = C_q(A) + C_q(B)$ and $C_q(\text{parallel}(A, B)) = C_q(A) \cdot C_q(B)$ hold exactly or approximately.
4. If the operadic structure fails for ResNet skip connections (where the symmetry of the skip path interacts nontrivially with the main path), the clean operad hypothesis is refuted, but a weaker "operad up to bounded error" version might survive.

**Impact:** An operadic framework for architecture complexity would enable automated architecture search guided by algebraic invariants, and would connect neural architecture theory to the rich mathematics of operads and higher category theory.
