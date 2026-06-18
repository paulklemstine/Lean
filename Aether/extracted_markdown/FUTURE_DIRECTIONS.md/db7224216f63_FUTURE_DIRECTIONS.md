# Future Directions: Formal Percolation Threshold Theory

## 1. Finite-Size Convergence of Square Site Crossing Thresholds

- **Conjecture:** The finite-volume threshold $p_n$, defined by $\text{boxCrossingProbSite}(n, p_n) = 1/2$, converges as $n \to \infty$, and the convergence is eventually monotone (i.e., $p_n$ is monotonically decreasing for $n \geq n_0$ for some explicit $n_0$).

- **Why it matters:** This would give the first formally rigorous route toward defining the infinite-volume critical parameter for square site percolation — the most important open problem in planar percolation. The eventual monotonicity would allow certified interval bounds on $p_c$ from finite computations.

- **Test:** Compute $p_n$ for $n \leq 8$ by exact enumeration (feasible for $n \leq 5$, Monte Carlo with certified confidence intervals for $n \leq 8$). Check whether the sequence is monotonically decreasing after $n = 2$. Cross-reference against the numerical estimate $p_c \approx 0.592746$.

- **Minimal Lean target:** Extend `boxCrossingProb` to arbitrary $n$, prove `exists_finite_volume_threshold` using `increasing_event_prob_monotone`, and formalize the statement `∃ L : ℝ, Filter.Tendsto (fun n => p_n) Filter.atTop (nhds L)` as a conjecture.

---

## 2. Dual Crossing Dichotomy on Planar Rectangular Grids

- **Conjecture:** For every bond configuration on a rectangular grid $\{0, \ldots, n-1\} \times \{0, \ldots, m-1\}$, exactly one of the following holds: (a) there exists a horizontal open crossing of the primal graph, or (b) there exists a vertical open crossing of the dual graph. That is, for all $\omega$: `horizontalOpenCrossing ω ↔ ¬ verticalDualCrossing ω`.

- **Why it matters:** This is the combinatorial core of every self-dual threshold proof. It connects primal and dual lattices and is the key ingredient in proving $p_c(\text{bond}, \mathbb{Z}^2) = 1/2$. Formalizing this in Lean would be a major milestone toward a complete proof of the Kesten threshold theorem.

- **Test:** Exhaustive verification on all bond configurations for small grids ($n, m \leq 4$). Then formalize the graph-theoretic proof using planarity and the Jordan curve theorem for grid graphs.

- **Minimal Lean target:** Define the dual grid graph, formalize `dualBondConfig`, and prove the dichotomy theorem `planar_rect_dual_crossing_complement` on $n \times m$ grids.

---

## 3. Russo-Type Derivative Formula for Finite Increasing Events

- **Conjecture:** For any increasing event $A$ on a finite product Bernoulli space $\{0,1\}^\alpha$ with $|\alpha| = n$, the derivative of the Bernoulli probability satisfies:
$$\frac{d}{dp} \mathbb{P}_p(A) = \sum_{i=1}^{n} \text{Inf}_i(A; p)$$
where $\text{Inf}_i(A; p) = \mathbb{P}_p[A \text{ is pivotal at } i]$ is the influence of coordinate $i$.

- **Why it matters:** Russo's formula is the gateway to sharp-threshold theory, the KKL theorem, and Boolean function analysis. With this formalized, one can derive quantitative bounds on the width of the percolation phase transition. It would also connect percolation theory to discrete Fourier analysis and computational complexity.

- **Test:** Verify the formula computationally for all increasing events on $\{0,1\}^n$ for $n \leq 5$. Compute influences explicitly and compare $d/dp \, \mathbb{P}_p(A)$ (obtained by polynomial differentiation of `bernoulliProb`) against the sum of influences.

- **Minimal Lean target:** Define `pivotalSite`, `influence`, and prove the Russo formula as an identity of polynomials in $p$. This decomposes into: (1) a product-rule lemma for Bernoulli weights, (2) a telescoping identity, and (3) the summation over pivotal coordinates.

---

## 4. Algebraic Certification of the Triangular Threshold via Minimal Polynomial

- **Conjecture:** The critical threshold $2\sin(\pi/18)$ is an algebraic number of degree exactly 3 over $\mathbb{Q}$, with minimal polynomial $p^3 - 3p + 1$. Moreover, the other two roots of this polynomial lie outside $(0,1)$: one is negative and one exceeds 1.

- **Why it matters:** This strengthens our formal result from "there exists a unique root in $(0,1)$" to a complete algebraic characterization. It connects percolation thresholds to algebraic number theory and could guide the search for exact thresholds on other lattices via Galois theory and resultant computations.

- **Test:** Factor the polynomial over $\mathbb{Q}$ (it's irreducible by the rational root theorem — possible rational roots $\pm 1$ are not roots). Compute the other two roots numerically: $2\cos(2\pi/9) \approx 1.532$ and $-2\cos(\pi/9) \approx -1.879$. Verify these are roots and lie outside $(0,1)$.

- **Minimal Lean target:** Prove irreducibility of $X^3 - 3X + 1$ over $\mathbb{Q}$ (by rational root theorem), identify all three roots as $2\sin(\pi/18)$, $2\cos(2\pi/9)$, $-2\cos(\pi/9)$, and prove they partition $\mathbb{R}$ around $(0,1)$.

---

## 5. Site–Bond Comparison Inequality on Square Finite Boxes

- **Conjecture:** There exists a universal monotone function $f : [0,1] \to [0,1]$ (independent of $n$) such that for all $n$ and all $p \in [0,1]$:
$$\text{boxCrossingProbSite}(n, p) \leq \text{boxCrossingProbBond}(n, f(p))$$
The optimal such $f$ satisfies $f(p) \leq p$ for all $p$, reflecting that site percolation is "harder" than bond percolation (requires a higher threshold). A candidate is $f(p) = 1 - (1-p)^2$ (based on the observation that an open site enables all its incident bonds).

- **Why it matters:** This would create a formal reduction from the open square-site threshold problem to the solved square-bond threshold problem. Combined with the bond threshold $p_c(\text{bond}) = 1/2$, it would yield a rigorous lower bound on $p_c(\text{site})$. More broadly, it establishes a comparison framework applicable to any lattice.

- **Test:** For $n = 2, 3, 4$, compute both crossing probabilities exactly and numerically search for the tightest monotone $f$. Check whether $f(p) = 1 - (1-p)^2$ works. Plot the crossing curves to visualize the comparison.

- **Minimal Lean target:** Define a concrete coupling from site configurations to bond configurations, prove it is monotone, and derive `square_site_to_bond_crossing_lower_bound` with an explicit $f$.
