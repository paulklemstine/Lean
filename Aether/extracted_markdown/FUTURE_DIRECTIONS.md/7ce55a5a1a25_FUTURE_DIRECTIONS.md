# Future Directions: EML Descriptive Approximation Theory

## Conjecture 1: Depth–Complexity Scaling Law

**Precise Statement:** For the target family $f_n(x) = \exp(p_n(x))$ where $p_n$ is a degree-$n$ polynomial with coefficients bounded by 1, the minimal EML depth for sup-norm $\varepsilon$-approximation on $[0,1]$ satisfies:

$$D_{\min}(f_n, \varepsilon) = \Theta\bigl(n \cdot \log(1/\varepsilon)\bigr)$$

while width-only (fixed-depth) polynomial approximants require degree $\Omega(n / \varepsilon^{1/n})$.

**Why it might be true:** Our formally verified universal approximation theorem shows that polynomial-to-EML conversion via Horner's method produces expressions of depth $2n$ for degree-$n$ polynomials. The exponential wrapper adds only 1 depth level. Standard approximation theory says degree-$k$ polynomials approximate $C^k$ functions with error $O(1/k^r)$ for $r$-smooth functions, so the required degree grows as $O(1/\varepsilon^{1/r})$. For compositions like $\exp(p_n(x))$, EML captures the composition directly.

**Test:** Generate 100 random polynomials $p_n$ for $n \in \{1, 2, 3, 5, 8, 13\}$. For each $f_n = \exp(p_n)$, find the minimum EML depth $D$ achieving $\varepsilon$-approximation for $\varepsilon \in \{10^{-1}, 10^{-2}, \ldots, 10^{-6}\}$ via Chebyshev polynomial fitting and Horner conversion. Fit $D$ against $n \cdot \log(1/\varepsilon)$. If the $R^2$ of a linear fit drops below 0.85, the conjecture is refuted.

**Impact:** Would establish a rigorous theory of "compositional depth advantage" — the formal basis for why deep neural networks outperform shallow ones on compositionally structured targets.

---

## Conjecture 2: EML Description Complexity is Multiplicatively Subadditive

**Precise Statement:** For functions $f, g$ that are $B$-bounded on $[a,b]$ and $\varepsilon \leq 2(B+1)$:

$$K_{\text{EML}}(f \cdot g, \varepsilon) \leq K_{\text{EML}}(f, \varepsilon') + K_{\text{EML}}(g, \varepsilon') + 1$$

where $\varepsilon' = \varepsilon / (2(B+1))$, and moreover, for $k$-fold products:

$$K_{\text{EML}}\Bigl(\prod_{i=1}^k f_i, \varepsilon\Bigr) \leq \sum_{i=1}^k K_{\text{EML}}(f_i, \delta_k) + k - 1$$

where $\delta_k = \varepsilon / (2k B^{k-1})$ (with all $f_i$ bounded by $B$).

**Why it might be true:** We have formally verified the $k=2$ case. The $k$-fold version follows by induction if the accumulated error from repeated product composition remains bounded. The key is that the Lipschitz constant of multiplication on $[-B, B]$ is $B$, leading to the factor $B^{k-1}$ in the tolerance.

**Test:** Compute $K_{\text{EML}}$ numerically for products $f_1 \cdots f_k$ where $f_i(x) = a_i \sin(b_i x) + c_i$ with random parameters. Compare the product complexity against the sum of individual complexities plus $k-1$. If the bound fails for $k \geq 5$ with $B = 2$ in more than 10% of random instances, the conjecture is false.

**Impact:** Would extend our compositional complexity theory to arbitrary products, enabling formal complexity bounds for entire polynomial and rational function families built from simple EML primitives.

---

## Conjecture 3: Log-Multiplicative Approximation Has Exponentially Better Sample Complexity

**Precise Statement:** For positive $C^2$ functions $f: [a,b] \to [\delta, M]$, the sample complexity for learning an $\varepsilon$-approximant (in relative error) scales as:

$$N_{\text{EML-mult}}(\varepsilon) = O\Bigl(\frac{K_{\text{EML}}(\log f, \varepsilon)}{\varepsilon^2} \cdot \log\frac{1}{\varepsilon}\Bigr)$$

while additive polynomial learning requires:

$$N_{\text{poly}}(\varepsilon) = \Omega\Bigl(\frac{1}{\varepsilon^{2 + 2/s}}\Bigr)$$

for $s$-smooth functions, which is strictly worse when $K_{\text{EML}}(\log f, \varepsilon)$ grows slowly.

**Why it might be true:** The multiplicative EML framework approximates $\log f$ by a polynomial $p$, giving $\exp(p(x))$ as the approximant with relative error $|f(x)/\exp(p(x)) - 1| \leq e^\varepsilon - 1 \approx \varepsilon$. This converts the multiplicative learning problem into an additive one in log-space, where the effective smoothness of $\log f$ may be much higher than that of $f$ itself (since exponential growth becomes linear).

**Test:** Generate 1000 random positive functions $f_i$ on $[0,1]$ with varying smoothness. For each, compute: (a) the number of samples needed for a polynomial to achieve 1% relative error, and (b) the number of samples for an EML log-multiplicative approximant. Compare the sample counts. If the EML approach requires more samples in >30% of cases, the conjecture is false.

**Impact:** Would provide formal justification for "learning in log-space" as a strategy in scientific machine learning, with immediate applications to modeling physical quantities that span many orders of magnitude (e.g., reaction rates, decay constants, material properties).

---

## Conjecture 4: EML Description Complexity Predicts Generalization Better Than Parameter Count

**Precise Statement:** For a hypothesis class $\mathcal{H}_s = \{f : K_{\text{EML}}(f, \varepsilon) \leq s\}$ of functions with bounded EML complexity, the Rademacher complexity satisfies:

$$\mathfrak{R}_n(\mathcal{H}_s) = O\Bigl(\sqrt{\frac{s \cdot \log s}{n}}\Bigr)$$

which implies a generalization bound that depends on description complexity $s$ rather than parameter count.

**Why it might be true:** EML expressions of size $s$ form a finite-dimensional family (bounded by the number of expression trees of size $s$). By standard VC-dimension or covering number arguments, the Rademacher complexity should be bounded in terms of the effective dimension of this family. The key insight is that $s$ captures structural complexity (compositional depth + breadth) rather than just the number of free parameters.

**Test:** Train EML symbolic regression models of varying sizes on 50 regression benchmarks (e.g., SRBench). For each, compute (a) test error, (b) EML description complexity $s$, and (c) total parameter count. If the correlation between $s$ and test error is lower than the correlation between parameter count and test error (measured by Spearman's $\rho$) in more than 50% of benchmarks, the conjecture is false.

**Impact:** Would establish EML complexity as a principled model selection criterion — a formal alternative to heuristics like AIC/BIC that accounts for compositional structure. This would directly impact interpretable machine learning and symbolic regression.

---

## Conjecture 5: Strict Depth Separation for Exponential Towers

**Precise Statement:** The $k$-fold iterated exponential $\exp^{(k)}(x) = \exp(\exp(\cdots\exp(x)\cdots))$ has:

$$K_{\text{EML}}(\exp^{(k)}, \varepsilon) = 2k + 1$$

for all sufficiently small $\varepsilon > 0$ (in fact, for all $\varepsilon$ on compact domains where the function is finite). Moreover, any EML expression of depth strictly less than $k$ requires size at least $\Omega(c^k / \varepsilon)$ for some constant $c > 1$ to achieve $\varepsilon$-approximation on $[0, 1]$.

**Why it might be true:** The iterated exponential $\exp^{(k)}(x)$ is exactly represented by a depth-$k$ EML expression of size $2k+1$ (a chain of `exp` nodes). Any representation of lower depth must "flatten" some compositions, which intuitively requires exponentially more terms. This is analogous to circuit complexity lower bounds for iterated multiplication.

**Test:** For $k = 1, 2, 3, 4, 5$, exhaustively enumerate all EML expressions of depth $< k$ and size up to $10k$. Check whether any achieves $\varepsilon = 0.01$ approximation on $[0, 0.5]$ (restricted domain to avoid overflow). If such an expression is found for any $k \leq 5$, the strict separation conjecture is false (though the exponential gap may still hold).

**Impact:** Would be the first formal depth separation result for transcendental expression complexity, directly analogous to the celebrated circuit complexity separations. It would provide mathematical justification for depth as a fundamental resource in scientific computation and neural architecture design.
