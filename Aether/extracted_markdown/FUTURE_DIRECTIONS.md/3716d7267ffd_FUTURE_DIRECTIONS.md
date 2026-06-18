# Future Directions: Tropical Universality Theory for Computation DAGs

## Conjecture 1: Universality Class Hypothesis

**Precise statement.** Two neural network architectures whose computation DAGs are tropically equivalent (same set of source-to-sink affine path cost functions) exhibit asymptotically identical empirical scaling exponents when trained on the same data distribution.

**Test.** Select 3–5 pairs of architecturally distinct networks (e.g., a chain vs. a diamond topology) whose tropical profiles are formally verified to be identical. Train each pair on a common benchmark (e.g., language modeling on C4) across 5 orders of magnitude in parameter count. Fit power-law exponents $\alpha$ to the loss-vs-parameter curves and compare.

**Refutation criterion.** If any pair with certified tropical equivalence exhibits exponents differing by more than 10% relative error (after controlling for finite-size effects and training noise), the hypothesis is falsified.

**Impact if true.** Establishes tropical equivalence as a *predictive* scientific invariant, not merely a mathematical abstraction. Would enable algebraic pre-screening of architectures before expensive training.

---

## Conjecture 2: Multiplicity–Log-Correction Hypothesis

**Precise statement.** Let $P$ be a tropical profile with scaling exponent $\alpha$, and let $m$ denote the number of forms in $P$ achieving slope $\alpha$ (the *dominant multiplicity*). Then the loss function satisfies:
$$L(N) = \Theta\left(N^{-\alpha} (\log N)^{m-1}\right)$$
That is, the degree of the logarithmic correction equals one less than the dominant multiplicity.

**Test.** Construct computation DAGs with controlled dominant multiplicities $m = 1, 2, 3$. For each, generate synthetic scaling data from the tropical envelope evaluated at integer points. Fit the data to the model $c \cdot N^{-\alpha} (\log N)^{\beta}$ and check whether $\beta = m - 1$.

**Refutation criterion.** If the best-fit $\beta$ deviates from $m - 1$ by more than 0.5 for any multiplicity value in controlled experiments, the hypothesis is falsified.

**Impact if true.** Extends the tropical classification theory from leading exponents to sub-leading corrections, establishing a "second-order" universality principle analogous to correction-to-scaling exponents in statistical mechanics.

---

## Conjecture 3: Residual Dominance Theorem

**Precise statement.** For any residual architecture constructed as the parallel composition of a serial backbone (with scaling exponent $\alpha_{\text{backbone}}$) and skip connections (with scaling exponents $\alpha_{S_1}, \ldots, \alpha_{S_k}$), the composite scaling exponent satisfies:
$$\alpha_{\text{residual}} = \min(\alpha_{\text{backbone}}, \alpha_{S_1}, \ldots, \alpha_{S_k})$$
Moreover, for networks of depth $L \geq 3$ with per-layer exponents $\alpha_i > 0$, the skip connections dominate: $\alpha_{\text{residual}} = \min_j \alpha_{S_j} < \alpha_{\text{backbone}}$.

**Test.** This is already a formal theorem (the parallel composition law). The empirical test is whether real ResNets, DenseNets, and U-Nets empirically exhibit scaling exponents matching the skip-dominant prediction. Train ResNet variants with controlled skip connections on ImageNet-scale tasks and measure exponents.

**Refutation criterion.** If measured exponents are closer to $\alpha_{\text{backbone}}$ than to $\min_j \alpha_{S_j}$ for architectures where the tropical model predicts skip dominance, the hypothesis is falsified.

**Impact if true.** Provides the first rigorous structural explanation for why residual connections improve scaling, and enables targeted architecture optimization by tuning skip connection profiles.

---

## Conjecture 4: Architecture Quotient Efficiency

**Precise statement.** Let $\mathcal{A}$ be a family of $n$ candidate architectures for a learning task, and let $\mathcal{A} / {\sim_T}$ denote the set of tropical equivalence classes. Then the architecture achieving the best scaling exponent in $\mathcal{A}$ has the same exponent as the best representative in $\mathcal{A} / {\sim_T}$. Moreover, $|\mathcal{A} / {\sim_T}| = O(n^{1-\epsilon})$ for some $\epsilon > 0$ depending on the combinatorial diversity of the architecture family.

**Test.** Generate 100+ architectures by combining 5 component types with varying depths and widths. Compute all tropical profiles (polynomial time). Measure the compression ratio $|\mathcal{A}|/|\mathcal{A}/{\sim_T}|$. Train one representative per class and verify that no untrained architecture in the same class achieves a better empirical exponent.

**Refutation criterion.** If an architecture in the same tropical equivalence class as a trained representative achieves a significantly different (>15% relative) empirical exponent, or if the quotient provides no compression ($|\mathcal{A}/{\sim_T}| = |\mathcal{A}|$), the hypothesis is falsified.

**Impact if true.** Reduces the cost of neural architecture search by a provable factor, with formal guarantees on the optimality of the quotient search.

---

## Conjecture 5: Tropical Phase Transitions

**Precise statement.** As a continuous parameter $t$ (representing data distribution shift, learning rate schedule, or architectural interpolation) varies, the dominant face of the tropical profile — the set of forms achieving the minimum slope — undergoes discrete transitions at critical values $t_c$. These transitions correspond to observable regime changes in the empirical scaling law (changes in the measured exponent $\alpha(t)$).

**Test.** Design a parameterized architecture family where the tropical profile's dominant form changes at a calculable $t_c$ (e.g., by linearly interpolating between two profiles with different minimum-slope forms). Train the architecture at values of $t$ near $t_c$ and measure whether the empirical scaling exponent exhibits a discontinuous jump at the predicted critical point.

**Refutation criterion.** If the empirical exponent varies smoothly through $t_c$ without a detectable transition, or if the transition occurs at a value significantly different from the tropical prediction, the hypothesis is falsified.

**Impact if true.** Connects tropical geometry to the theory of phase transitions in learning systems, establishing tropical face changes as the structural mechanism behind scaling-law regime shifts. Would open a pathway to predicting and controlling phase transitions in AI training.
