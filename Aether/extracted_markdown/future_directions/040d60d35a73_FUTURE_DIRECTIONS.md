# Future Directions: Benford Renormalization for Prime-Generated Dynamical Orbits

## Hypothesis 1 — Quadratic Universality Hypothesis

**Conjecture.** For every integer $c$ outside an explicit finite exceptional set $E \subset \mathbb{Z}$ (conjectured to be empty), the prime-seeded orbits of $T_c(x) = x^2 + c$ satisfy Benford's law in base 10. That is, for each digit $m \in \{1, \ldots, 9\}$:

$$\lim_{X, N \to \infty} \frac{1}{\pi(X) N} \#\{(p, n) : p \leq X,\, p \text{ prime},\, 1 \leq n \leq N,\, \mathrm{leadDigit}_{10}(|T_c^{(n)}(p)|) = m\} = \log_{10}(1 + 1/m).$$

**Test.** Compute $T_c^{(n)}(p)$ for $c \in \{-10, \ldots, 10\}$, primes $p \leq 10^5$, and $n \leq 20$, tallying leading digits. If the chi-squared statistic for the Benford distribution exceeds the 1% threshold for any $c$, investigate whether the deviation persists at larger $X$ and $N$.

**Refutation criterion.** A single value of $c$ for which the digit distribution provably fails to converge to Benford (e.g., due to an algebraic obstruction like semiconjugacy to a monomial map) would narrow the universality claim. The key test: verify that $T_c$ is NOT semiconjugate to $x \mapsto x^2$ for any Böttcher-type linearization over $\mathbb{Z}$.

**Impact.** Would establish the first rigorous Benford universality result in arithmetic dynamics, confirming that digit distributions detect the absence of algebraic structure.

---

## Hypothesis 2 — Exceptional Rigidity Hypothesis

**Conjecture.** Persistent non-Benford bias in the leading digits of $|T^{(n)}(p)|$ (averaged over primes) occurs if and only if $T$ is semiconjugate to a monomial/powering map $M(x) = \pm x^d$ via a map $\phi$ satisfying $\phi \circ T = M \circ \phi$, or possesses a rational first integral forcing the logarithmic phases $\log_b |T^{(n)}(p)|$ into a finite-rank additive subgroup of $\mathbb{R}/\mathbb{Z}$.

**Test.** For the monomial map $T(x) = x^d$, we have already proved (Theorem `monomial_iterate_log_eq`) that $\log |T^{(n)}(p)| = d^n \log p$ exactly, so Benford reduces to equidistribution of $d^n \log_b p \pmod{1}$. Test whether non-monomial maps with known Böttcher coordinates (e.g., Chebyshev polynomials) exhibit non-Benford behavior, and whether generic perturbations restore Benford.

**Refutation criterion.** A non-exceptional map (not semiconjugate to any monomial) that persistently violates Benford would refute this hypothesis. Alternatively, an exceptional map that IS Benford (due to Diophantine properties of the semiconjugacy constants) would show the condition is sufficient but not necessary.

**Impact.** Would provide a complete structural classification of Benford vs. non-Benford behavior in polynomial dynamics, analogous to rigidity/flexibility dichotomies in ergodic theory.

---

## Hypothesis 3 — Base-Independence Hypothesis

**Conjecture.** For non-exceptional polynomial maps $T$ of degree $d \geq 2$, Benford convergence holds simultaneously for all integer bases $b \geq 2$. More precisely, if the prime-orbit digit distribution converges to Benford in any one base $b_0 \geq 2$, it converges in all bases.

**Test.** For $T(x) = x^2 + 1$, compute leading digits in bases 2, 3, 5, 7, 10, and 16 for primes $p \leq 10^4$ and $n \leq 15$. Compare convergence rates across bases. Base-independence follows from equidistribution of $\log |T^{(n)}(p)| \pmod{1}$ (which is base-free), but the error terms might be base-dependent.

**Refutation criterion.** A map and a specific base where Benford fails while holding in other bases would refute base-independence. This could occur if $\log_b |a_d|$ (the leading coefficient correction) is rational for a specific base $b$.

**Impact.** Base-independence would confirm that Benford's law in this setting is a manifestation of genuine equidistribution (a measure-theoretic phenomenon) rather than a base-specific arithmetic coincidence.

---

## Hypothesis 4 — Discrepancy-Rate Hypothesis

**Conjecture.** The digit discrepancy $D_{X,N}^{(b)}$ (the supremum over digits $m$ of the deviation of the empirical frequency from the Benford target) satisfies:

$$D_{X,N}^{(b)} \leq A \cdot \sup_{k \neq 0} \left|\frac{1}{\pi(X) N} \sum_{p \leq X} \sum_{n=1}^{N} e^{2\pi i k \cdot 2^n \log_b p}\right| + B \cdot \frac{C}{p_{\min}}$$

where $A, B$ are absolute constants, $C$ is the growth-renormalization constant from `log_iterate_quad_close`, and $p_{\min}$ is the smallest prime in the sample.

**Test.** Numerically estimate both sides for $T(x) = x^2 + 1$, base 10, and compare. The Weyl-sum term should dominate the error term for large $X$.

**Refutation criterion.** If the digit discrepancy decays significantly faster or slower than the Weyl-sum bound predicts, the hypothesis would need modification. In particular, if there are cancellations in the Weyl sums that the bound does not capture, the inequality may be very loose.

**Impact.** A tight discrepancy bound would provide quantitative convergence rates for the Benford law, enabling predictions about sample sizes needed for digit-statistical tests. This has applications in fraud detection and data validation.

---

## Hypothesis 5 — Rational Map Extension Hypothesis

**Conjecture.** For rational maps $R(x) = P(x)/Q(x)$ with integer coefficients, $\deg P > \deg Q$, and $\deg P \geq 2$, the Benford law holds for prime-seeded orbits after excluding:
(a) primes $p$ where the orbit encounters a pole (a zero of $Q$), and
(b) a zero-density exceptional set of primes where the orbit is eventually periodic.

The growth-renormalization estimate generalizes: $\log |R^{(n)}(p)| = d^n \log p + O(d^n / p)$ where $d = \deg P - \deg Q$.

**Test.** For $R(x) = (x^2 + 1)/(x + 1)$ (degree 1 effective, so this doesn't apply — use $R(x) = (x^3 + x)/(x + 1)$ with effective degree 2), compute orbits from prime seeds and test Benford.

**Refutation criterion.** A rational map with effective degree $\geq 2$, no pole encounters, and non-exceptional orbits that persistently violate Benford would refute the extension. The most likely failure mode is orbits that approach a pole tangentially, causing the error term to blow up.

**Impact.** Extending from polynomial to rational maps would connect the theory to the full machinery of arithmetic dynamics (Silverman's framework), opening connections to canonical heights, good reduction, and the Mordell conjecture for dynamical systems.
