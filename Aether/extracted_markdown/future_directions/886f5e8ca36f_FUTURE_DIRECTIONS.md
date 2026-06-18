# Future Directions: Depth Separation for Iterated Exponentials

## Conjecture 1: Full Depth Hierarchy for Exponential Towers

**Conjecture.** For every $k \ge 2$ and every EML expression $E$ of depth strictly less than $k$, there exist constants $c, C > 0$ (depending on $k$) such that for all $\varepsilon \in (0,1)$:

$$\sup_{x \in [0,1]} |E(x) - \operatorname{iterExp}(k, x)| \le \varepsilon \implies \operatorname{size}(E) \ge C \cdot c^k \cdot \varepsilon^{-1}.$$

**Test.** Enumerate all depth-$(k-1)$ EML expressions with size up to $S_{\max}$ (using a recursive expression generator). For each, compute the uniform error against $\operatorname{iterExp}(k)$ on a fine grid of $[0,1]$. Plot $\log(\varepsilon)$ vs $\log(S)$ and check whether the empirical slope matches $-1$ (consistent with $\varepsilon^{-1}$ scaling). Run for $k = 2, 3, 4$.

**Refutation.** If for some $k$, a depth-$(k-1)$ expression of size $o(c^k / \varepsilon)$ achieves $\varepsilon$-approximation, the conjecture is false. Concretely, if a depth-1 expression of size 10 achieves error $< 0.01$ for $\operatorname{iterExp}(3)$, the conjecture requires $C \cdot c^3 \le 10 \cdot 0.01 = 0.1$, constraining the constants severely.

**Impact.** If true, this would be the first fully formal depth hierarchy theorem for continuous-function expression systems, establishing that EML depth is a genuine semantic complexity measure.

---

## Conjecture 2: Derivative Growth as a Semantic Depth Invariant

**Conjecture.** For any EML expression $E$ of depth $d$, the maximum derivative on $[0,1]$ satisfies:

$$\sup_{x \in [0,1]} |E'(x)| \le \operatorname{iterExp}(d, M)$$

where $M = \max(\sup |E(x)|, \sup |\text{leaf constants}|)$ is a bound on intermediate values. In contrast, $\operatorname{iterExp}(k)'$ on $[0,1]$ grows as $\operatorname{iterExp}(k+1, 1)$ — a tower of height $k+1$.

**Test.** For random depth-$d$ EML expressions with bounded coefficients, compute the maximum derivative numerically on $[0,1]$. Verify that it is bounded by $\operatorname{iterExp}(d, M)$ for appropriate $M$. Then compare with $\operatorname{iterExp}(k)'$ for $k > d$.

**Refutation.** Find a depth-$d$ EML expression whose derivative exceeds $\operatorname{iterExp}(d+1, M)$ on $[0,1]$. This would show that depth does not control derivative growth in the conjectured way.

**Impact.** This would give a polynomial-time computable semantic invariant that separates EML depth levels, analogous to how circuit complexity uses gate count to separate depth classes.

---

## Conjecture 3: Curvature Cascade for Bounded-Depth Approximants

**Conjecture.** For $k \ge 3$, the $k$-th derivative of $\operatorname{iterExp}(k)$ at $x = 0$ satisfies:

$$\operatorname{iterExp}(k)^{(k)}(0) \ge \operatorname{iterExp}(k-1, 1)^2$$

and any depth-$(k-1)$ EML expression $E$ satisfying $\|E - \operatorname{iterExp}(k)\|_\infty \le \varepsilon$ on $[0,1]$ must have $|E^{(k)}(0)| \ge \operatorname{iterExp}(k-1, 1)^2 - O(\varepsilon)$.

**Test.** Compute higher derivatives of $\operatorname{iterExp}(k)$ symbolically (using automatic differentiation) and verify the lower bound. For shallow approximants, check whether they match the higher derivative growth.

**Refutation.** If a smooth depth-$(k-1)$ approximant achieves small uniform error without large higher derivatives, the curvature cascade may not be the right invariant.

**Impact.** Higher-derivative obstructions would extend the Lipschitz separation to a full Taylor-coefficient separation, giving a much stronger impossibility result.

---

## Conjecture 4: Mixed Tower Hierarchy (Log-Exp Towers)

**Conjecture.** Define mixed towers:
$$T_k^{\text{mix}}(x) = \underbrace{\exp(\log(\exp(\log(\cdots x \cdots))))}_{k \text{ alternations}}$$

These simplify to polynomials or the identity on appropriate domains. In contrast, towers with repeated $\exp$ (no $\log$ cancellation) create genuine depth. The depth separation for $\operatorname{iterExp}(k)$ persists even when the EML language is extended with $\log$ nodes, because $\log \circ \exp = \text{id}$ only reduces effective depth — it cannot create the multiplicative derivative cascade of iterated exponentials.

**Test.** Extend the EML syntax with $\log$ nodes. Search for depth-$(k-1)$ expressions (with $\log$) that approximate $\operatorname{iterExp}(k)$. Verify that $\log$ nodes do not help.

**Refutation.** If adding $\log$ allows a depth-$(k-1)$ expression of reasonable size to approximate $\operatorname{iterExp}(k)$ better than without $\log$, then the depth hierarchy partially collapses with this extension.

**Impact.** Extending to log-exp towers would connect the theory to practical symbolic regression, where both $\exp$ and $\log$ are available operations.

---

## Conjecture 5: Depth Separation Transfers to Neural Network Width

**Conjecture.** A ReLU network of depth $d$ and width $W$ that $\varepsilon$-approximates $\operatorname{iterExp}(k)$ on $[0,1]$ must satisfy $W \ge C \cdot \text{gap}(k) / \varepsilon$ where $\text{gap}(k) = \operatorname{iterExp}(k, 1) - \operatorname{iterExp}(k, 0)$.

**Test.** Train shallow ReLU networks of varying width on $\operatorname{iterExp}(k)$ targets. Plot the achieved $L^\infty$ error vs width. Verify the scaling matches $\varepsilon \sim \text{gap}(k) / W$.

**Refutation.** If ReLU networks achieve better-than-predicted approximation (e.g., $\varepsilon \sim 1/W^2$), the linear width-error tradeoff is wrong, though some polynomial relationship should persist.

**Impact.** This would directly connect EML depth separation to practical neural network architecture theory, showing that depth-width tradeoffs in neural nets have provable lower bounds for compositional functions.
