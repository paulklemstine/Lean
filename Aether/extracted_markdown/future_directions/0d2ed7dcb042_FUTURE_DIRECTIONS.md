# Future Directions: EML Kolmogorov–Arnold Representation Theory

## Conjecture 1: EML Universality on Compact Positive Boxes

**Conjecture:** For any continuous function $f : [a,b]^2 \to \mathbb{R}$ with $0 < a < b$, and any $\epsilon > 0$, there exists a finite EML superposition $S(x,y) = \sum_{i=1}^m \Phi_i(\psi_i^{(1)}(x) + \psi_i^{(2)}(y))$ with $\Phi_i, \psi_i^{(j)}$ chosen from $\{\exp, \log, \text{affine maps}\}$ and their compositions, such that $\sup_{(x,y) \in [a,b]^2} |f(x,y) - S(x,y)| < \epsilon$.

**Test:** Take $f(x,y) = \sin(xy)$ on $[1,2]^2$. Fit EML superpositions with $m = 1, 2, 5, 10, 20$ terms using gradient-based optimization on a $100 \times 100$ grid. Plot the maximum residual as a function of $m$. If residuals decrease to $< 10^{-6}$ for some finite $m$, this provides evidence for the conjecture. If residuals plateau above some threshold regardless of $m$, the conjecture is falsified for this target.

**Impact:** If true, this would establish EML as a constructive skeleton for the Kolmogorov–Arnold theorem on positive domains — a major theoretical advance connecting constructive approximation theory to neural network expressivity.

---

## Conjecture 2: Optimal Term Bounds for Positive-Coefficient Polynomials

**Conjecture:** Every degree-$d$ positive-coefficient polynomial in two variables can be exactly represented by an EML superposition with at most $\binom{d+2}{2}$ terms (the number of monomials up to degree $d$). Moreover, this bound is tight: there exist degree-$d$ polynomials requiring exactly $\binom{d+2}{2}$ terms.

**Test:** For $d = 2$, the bound predicts at most 6 terms. Take $p(x,y) = x^2 + xy + y^2 + x + y + 1$ (6 monomials). Verify it requires exactly 6 EML superposition terms. Then test whether $p(x,y) = x^2 + 3xy + 2y^2$ (3 monomials) can be represented with fewer than 3 terms. If any 3-monomial polynomial can be represented with 2 EML terms, the tightness claim is falsified.

**Impact:** Tight term bounds would provide complexity measures for EML representations, directly applicable to neural network width requirements for positive-domain computations.

---

## Conjecture 3: EML Superposition Depth-Width Tradeoff

**Conjecture:** There exist functions on $(0,\infty)^2$ that require $\Omega(n)$ terms in a depth-2 EML superposition (one layer of inner functions, one outer function) but only $O(\log n)$ terms in a depth-3 EML superposition (inner, middle, outer layers). Specifically, $f(x,y) = \sum_{k=1}^n x^{a_k} y^{b_k}$ with generic exponents requires $n$ terms at depth 2 but $O(\sqrt{n})$ at depth 3 using shared intermediate computations.

**Test:** For $n = 16$ and random exponents $a_k, b_k \in [0.5, 2.5]$, attempt depth-3 EML decompositions with $m = 4, 6, 8$ intermediate nodes. Measure approximation quality on $[1,2]^2$. If depth-3 with $m = 8$ achieves $< 10^{-6}$ residual while depth-2 requires all 16 terms, this supports the conjecture.

**Impact:** A depth-width tradeoff theorem would provide theoretical foundations for deep EML network architectures and inform the design of Kolmogorov–Arnold Networks.

---

## Conjecture 4: Log-Linearization Characterizes Multiplicative Interactions

**Conjecture:** A continuous function $f : (0,\infty)^2 \to (0,\infty)$ satisfies $\log f(x,y) = g(\log x, \log y)$ for some *additively separable* function $g(s,t) = u(s) + v(t)$ if and only if $f(x,y) = \phi(x) \cdot \psi(y)$ for some continuous $\phi, \psi : (0,\infty) \to (0,\infty)$.

**Test:** (Forward direction) Take $f(x,y) = x^2 y^3$. Then $\log f = 2\log x + 3\log y$ is additively separable. Verify $f = \phi \cdot \psi$ with $\phi(x) = x^2$, $\psi(y) = y^3$. (Reverse direction) Take $f(x,y) = (x+y)^2$ on $(0,\infty)^2$. This is *not* multiplicatively separable. Verify that $\log f(x,y) = 2\log(x+y)$ is *not* additively separable in $\log x, \log y$. Test with numerical fitting: attempt to fit $\log(e^s + e^t)$ as $u(s) + v(t)$ and show residuals remain large.

**Impact:** This would establish a precise mathematical dictionary between multiplicative separability and additive separability in log-coordinates, unifying ideas from information geometry, independent component analysis, and tensor decomposition.

---

## Conjecture 5: EML Superposition Gap for Non-Polynomial Functions

**Conjecture:** The function $f(x,y) = \sqrt{x^2 + y^2}$ (Euclidean norm) on $[1,2]^2$ requires $\Omega(1/\epsilon)$ EML superposition terms to achieve uniform $\epsilon$-approximation. In contrast, $f(x,y) = x \cdot y$ requires exactly 1 term (zero approximation error). This establishes a complexity separation between "EML-native" functions (expressible with $O(1)$ terms) and "EML-hard" functions (requiring many terms).

**Test:** Fit EML superpositions to $\sqrt{x^2 + y^2}$ on $[1,2]^2$ with $m = 1, 2, 5, 10, 20, 50$ terms. Measure maximum residual. If residuals scale as $\Theta(1/m)$, the conjecture is supported. If residuals decrease exponentially (as $e^{-cm}$), the conjecture is falsified and the function is "EML-easy."

**Impact:** Identifying the complexity landscape of EML representations would guide the selection of network architectures: functions in the "EML-easy" class should be computed by log-exp networks, while "EML-hard" functions may benefit from alternative architectures. This has direct implications for symbolic regression and automated model selection.
