# Future Directions: Prime-Modular Morse Stability

## Overview

The theorems proved in this cycle establish the first formal bridge between finite-field critical loci and real Morse-theoretic complexity for polynomial loss functions. The following conjectures and hypotheses chart the path toward a complete arithmetic theory of optimization landscapes.

---

## Hypothesis 1: Profile Rigidity Hypothesis

**Conjecture.** For generic separable polynomial losses $L(\theta) = \sum_{i=1}^n f_i(\theta_i)$ with integer coefficients, simple integral critical points, and pairwise distinct critical values, there exists a finite exceptional set $S$ of primes such that the family of finite-field critical-value profiles
$$\{ \operatorname{critProfile}_p(L, \cdot) \}_{p \notin S}$$
determines the real Morse index histogram of $L$ up to finitely many ambiguities.

**Test.** Enumerate all separable losses of degree $\leq 6$ with coefficients in $\{-3, \ldots, 3\}$ and $n \leq 3$ variables. For each pair $(L_1, L_2)$:
1. Compute exact real critical points and Morse indices.
2. Compute mod-$p$ critical profiles for all primes $p \leq 200$ not in the exceptional set.
3. Check: if $L_1$ and $L_2$ have different Morse histograms, do their profiles eventually disagree?

**Refutation criterion.** The hypothesis is refuted if a pair exists with different Morse histograms but identical critical profiles for all primes $p > 50$.

**Impact.** If true, this would establish that finite-field computation can serve as a certified diagnostic for real optimization complexity, enabling fast symbolic hardness classification of loss landscapes.

---

## Hypothesis 2: Quadratic Parity Hypothesis

**Conjecture.** For diagonal quadratic losses $Q(\theta) = \sum_{i=1}^n \varepsilon_i \theta_i^2 + c_i \theta_i + d$ with $\varepsilon_i \in \{\pm 1\}$, the quadratic character signature
$$\operatorname{quadSignature}_p(Q) = \chi_p(\det \operatorname{Hess}(Q))$$
satisfies
$$\operatorname{quadSignature}_p(Q) = \chi_p(2)^n \cdot \chi_p((-1)^{\operatorname{index}(Q)})$$
for all odd primes $p$ not dividing any coefficient. Furthermore, for primes in the residue class $p \equiv 1 \pmod{8}$ (where $\chi_p(2) = 1$), the signature directly reads off $(-1)^{\operatorname{index}}$.

**Test.** 
1. Enumerate all $\pm 1$ sign patterns $\varepsilon$ for $n \leq 10$.
2. For each pattern and each odd prime $p \leq 1000$, compute $\chi_p(\det \operatorname{Hess})$ and compare with $\chi_p(2)^n \cdot \chi_p((-1)^k)$ where $k$ is the Morse index.
3. Verify that for $p \equiv 1 \pmod{8}$, the signature equals $\chi_p((-1)^k)$ exactly.

**Refutation criterion.** Any prime $p > 2$ not dividing any Hessian entry where the formula fails.

**Impact.** This provides a concrete, computable algorithm for reading Morse index parity from purely arithmetic data. The Lean formalization already proves the structural ingredients; the full formula is the natural next target.

---

## Hypothesis 3: Convolution Universality Hypothesis

**Conjecture.** In high dimension, normalized modular critical profiles of random separable losses converge to a universal distribution under additive convolution. Specifically, for $n \to \infty$ with each $f_i$ drawn from a fixed ensemble of degree-$d$ polynomials with random integer coefficients:
$$\frac{1}{\sqrt{n}} \left( \operatorname{critProfile}_p(L, t) - \mathbb{E}[\operatorname{critProfile}_p(L, t)] \right) \xrightarrow{d} \mathcal{N}(0, \sigma^2_{d,p})$$
for a variance $\sigma^2_{d,p}$ depending only on the degree and the prime.

**Test.**
1. Fix degree $d = 4$ and coefficient range $\{-5, \ldots, 5\}$.
2. For $n \in \{10, 50, 100, 500\}$ and primes $p \in \{5, 7, 11, 13\}$:
   - Sample 1000 random separable losses.
   - Compute critical profiles via convolution.
   - Test normality using Kolmogorov-Smirnov and Shapiro-Wilk tests.
3. Track how the $p$-value evolves with $n$.

**Refutation criterion.** If the KS test $p$-value does not converge toward 1 as $n$ increases, or if the distribution remains non-Gaussian for all tested $n$.

**Impact.** Universality would mean that landscape ruggedness statistics become predictable from dimension and degree alone, enabling architecture-independent complexity estimates.

---

## Hypothesis 4: Near-Separable Robustness Hypothesis

**Conjecture.** Small coupling perturbations of separable losses preserve modular profile stability for a positive density of primes. Precisely, if $L_0 = \sum f_i(\theta_i)$ is separable and $L_\varepsilon = L_0 + \varepsilon \cdot g(\theta)$ is a small perturbation by a polynomial $g$ of bounded degree, then for all but finitely many primes $p$:
$$| \#\operatorname{Crit}(L_\varepsilon; \mathbb{F}_p) - \#\operatorname{Crit}(L_0; \mathbb{F}_p) | \leq C \cdot \deg(g)$$
where $C$ is a constant depending on $L_0$ and $\varepsilon$ but not on $p$.

**Test.**
1. Start with $L_0 = (x^4 - 2x^2) + (y^4 - 2y^2)$.
2. Add perturbations $g = xy$, $g = x^2 y$, $g = xy^2$, scaled by $\varepsilon \in \{0.1, 0.5, 1\}$.
3. For each perturbed loss (with rounded integer coefficients), compute mod-$p$ critical counts for primes up to 200.
4. Measure deviation from the separable count (9).

**Refutation criterion.** If deviations grow without bound as $p$ increases, or if no finite exceptional set suffices.

**Impact.** Robustness would extend the arithmetic Morse dictionary from exactly separable losses to the far more common "nearly separable" regime encountered in practical neural network training.

---

## Hypothesis 5: Hardness Proxy Hypothesis

**Conjecture.** The variance of modular critical counts across primes correlates with numerical optimization difficulty over $\mathbb{R}$. Specifically, define the *arithmetic ruggedness* of a loss $L$ as:
$$\operatorname{Rug}(L) = \operatorname{Var}_{p \leq P} \left[ \#\operatorname{Crit}(L; \mathbb{F}_p) \right]$$
for a fixed prime bound $P$. Then for separable polynomial losses of bounded degree, $\operatorname{Rug}(L)$ correlates positively with the number of gradient descent iterations required to reach a local minimum from a random initialization.

**Test.**
1. Generate 100 random separable losses of degree 4-6 in 5-10 variables.
2. Compute $\operatorname{Rug}(L)$ using primes up to $P = 100$.
3. Run gradient descent from 50 random initializations per loss, recording iterations to convergence.
4. Compute Spearman rank correlation between $\operatorname{Rug}(L)$ and median convergence time.

**Refutation criterion.** Spearman correlation $< 0.3$ with $p$-value $> 0.05$.

**Impact.** If confirmed, this would provide a purely algebraic, pre-training diagnostic for optimization difficulty—a "hardness oracle" computable from the loss function's coefficients alone, without running any optimization.

---

## Asymptotic Modular Determination Conjecture (Grand Conjecture)

**Conjecture.** For generic separable polynomial losses with integer coefficients and simple integral critical points, there exists a finite exceptional set of primes $S$ such that the family of finite-field critical-value profiles $\{\operatorname{critProfile}_p(L, \cdot)\}_{p \notin S}$ determines the real Morse index histogram up to finitely many ambiguities.

**Computational Refutation Test.** Search over two distinct separable losses $L_1, L_2$ of bounded degree and coefficient size. Compute:
- Exact real critical points and Morse indices.
- Mod-$p$ critical profiles for many increasing good primes.

The conjecture is **refuted** if:
1. $L_1$ and $L_2$ have different real Morse histograms, but
2. Their mod-$p$ critical profiles agree for all tested good primes beyond some threshold.

---

## Implementation Roadmap

### Short term (1-2 cycles)
- Prove the full quadratic parity formula (Hypothesis 2) in Lean.
- Extend prime stability from individual critical points to families (Theorem 3 from the proposal).
- Implement efficient convolution-based profile computation for large primes.

### Medium term (3-5 cycles)
- Formalize the theory for non-separable perturbations using resultant/discriminant machinery.
- Connect to étale cohomology via Grothendieck-Lefschetz trace formulas.
- Build a computational library for automated hardness classification.

### Long term (6+ cycles)
- Develop a full arithmetic Morse theory incorporating Betti number data.
- Connect to random matrix theory for universal statistics of critical profiles.
- Apply to real neural network architectures with polynomial activation functions.
