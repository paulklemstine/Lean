# Future Directions: Discrete Kakeya Theory and Additive Combinatorics

## Conjecture 1: Extremizers Minimize Overlaps, Not Maximize Concurrency

**Conjecture.** For line families in $\mathbb{F}_p^2$ consisting of one affine line per slope (slopes $0, 1, \ldots, p-1$), the minimum carrier size is exactly $p(p+1)/2$, achieved by configurations where pairwise intersection points are all distinct — *not* by star-like (maximal concurrency) configurations.

**Test.** Exhaustive enumeration for primes $p = 3, 5, 7, 11, 13$:
1. Enumerate all $p^p$ intercept choices.
2. Compute carrier size.
3. Verify that the minimum equals $p(p+1)/2$.
4. Verify that all minimizers have the property that every pair of lines intersects in a *distinct* point (i.e., the $\binom{p}{2}$ pairwise intersection points are all distinct).

**Refutation criterion.** A single prime $p$ where the minimum carrier size differs from $p(p+1)/2$, or where a minimizer has two pairs of lines sharing the same intersection point.

**Impact.** This would resolve the finite-field analogue of the extremizer problem and give a sharp characterization of optimal Kakeya compression. Our exhaustive computations for $p = 3, 5, 7$ confirm $p(p+1)/2$ with all pairwise intersections distinct.

**Status.** Computationally verified for $p = 3, 5, 7$. The star-configuration conjecture (maximum concurrency) was **refuted** by our computations: star configurations give carrier size $p^2 - p + 1 > p(p+1)/2$ for $p \geq 3$.

---

## Conjecture 2: Energy–Carrier Duality and Tight Cauchy–Schwarz

**Conjecture.** For any discrete Kakeya configuration with $|D|$ directions and constant line size $L$, the Cauchy–Schwarz bound
$$|D| \cdot L \leq \sqrt{|\text{carrier}| \cdot E}$$
is tight (equality holds) if and only if the multiplicity function is constant on the carrier.

**Test.** For each prime $p \leq 11$:
1. Generate all one-line-per-slope families.
2. Compute carrier size, energy, and the Cauchy–Schwarz ratio $\frac{(|D| \cdot L)^2}{|\text{carrier}| \cdot E}$.
3. For configurations achieving ratio $= 1$, verify that point multiplicity is constant.
4. For configurations with ratio $< 1$, verify that multiplicity is non-constant.

**Refutation criterion.** A configuration where the ratio equals 1 but the multiplicity function is non-constant, or vice versa.

**Impact.** Would characterize "structurally optimal" Kakeya configurations as those with perfectly uniform overlap, connecting to equidistribution phenomena in additive combinatorics. This is the discrete analogue of the principle that Kakeya sets of minimum dimension should have "uniformly distributed" tube overlaps.

---

## Conjecture 3: Additive Energy Controls Kakeya Compression

**Conjecture.** Let $A \subseteq \mathbb{Z}/N\mathbb{Z}$ contain arithmetic progressions of length $m$ in each of $D$ directions. Then
$$|A| \geq \frac{D \cdot m}{\sqrt{E_+(A) / |A|}}$$
where $E_+(A) = |\{(a_1, a_2, a_3, a_4) \in A^4 : a_1 + a_2 = a_3 + a_4\}|$ is the additive energy.

More precisely, the Cauchy–Schwarz energy inequality applied to the AP configuration gives
$$(D \cdot m)^2 \leq |A| \cdot E_{\text{Kakeya}}$$
where $E_{\text{Kakeya}} \leq E_+(A)$ under suitable distinctness conditions.

**Test.** For $N = p$ prime, $p \leq 23$:
1. For random direction sets $V \subseteq \mathbb{F}_p^*$ of size $D = \lfloor p/2 \rfloor$, find optimal base points minimizing $|A|$.
2. Compute $E_+(A)$ and the Kakeya energy $E_{\text{Kakeya}}$.
3. Verify that $E_{\text{Kakeya}} \leq E_+(A)$ and test tightness.

**Refutation criterion.** An example where $E_{\text{Kakeya}} > E_+(A)$ for a valid AP configuration.

**Impact.** Would establish a formal dictionary between Kakeya-type compression and Balog–Szemerédi–Gowers-type additive structure, opening the path to applying the full sum-product machinery to Kakeya lower bounds.

---

## Conjecture 4: Polynomial Method Gives Sharp Bounds in $\mathbb{F}_q^n$

**Conjecture.** For the Dvir-style finite-field Kakeya problem: a subset of $\mathbb{F}_q^n$ containing a line in every direction has size at least $\binom{q + n - 1}{n}$. Moreover, for $n = 2$, the extremizers are precisely the complements of degree-$(q-1)$ algebraic curves (i.e., sets defined by $\{x : f(x) \neq 0\}$ for a homogeneous polynomial of degree $q - 1$).

**Test.** For small $(q, n)$ pairs with $q$ prime, $q \leq 7$, $n = 2$:
1. Enumerate all subsets containing a line in every direction.
2. Verify the lower bound $\binom{q+1}{2} = q(q+1)/2$.
3. Check whether minimizers correspond to curve complements.

**Refutation criterion.** A minimizer that is not the complement of a degree-$(q-1)$ curve.

**Impact.** Would give a complete algebraic characterization of finite-field Kakeya extremizers, going beyond Dvir's existential lower bound to a structural classification. This connects to algebraic geometry over finite fields and the polynomial method in combinatorics.

---

## Conjecture 5: Pairwise Intersection Bounds Bootstrap to Hausdorff Dimension

**Conjecture.** Let $E \subseteq \mathbb{R}^n$ be a Besicovitch set. Define the discretized Kakeya configuration at scale $\delta$ by covering $E$ with $\delta$-cubes and taking lines to be $\delta$-tubes in each direction. If the pairwise intersection parameter $T(\delta)$ satisfies $T(\delta) \leq C \delta^{-\alpha}$ for all $\delta > 0$, then $\dim_H(E) \geq n - \alpha$.

In particular, if tubes in distinct directions have intersection of measure at most $\delta^{n-1}$ (the generic bound), then $T(\delta) \leq C \delta^{-1}$ and we recover $\dim_H(E) \geq n - 1$.

**Test.**
1. Formalize the discretization procedure in Lean, defining $\delta$-cubes and $\delta$-tubes.
2. For known Besicovitch set constructions (e.g., Perron trees), compute $T(\delta)$ numerically.
3. Verify that the predicted dimension lower bound matches known results.
4. For $n = 2$, verify that the bound gives $\dim_H(E) \geq 1$, which is the trivial bound — the conjecture predicts that improving $T(\delta)$ to $\delta^{-(1-\varepsilon)}$ would give $\dim_H(E) \geq 1 + \varepsilon$.

**Refutation criterion.** A construction where $T(\delta) \leq C \delta^{-\alpha}$ but $\dim_H(E) < n - \alpha$.

**Impact.** Would bridge the gap between discrete incidence bounds (which we have formally verified) and continuous Hausdorff dimension estimates. This is the missing link in the Kakeya program: the "discretization step" that converts finite combinatorial bounds into geometric measure-theoretic conclusions. If the conjecture holds, our verified Cauchy–Schwarz and pairwise bounds would immediately imply dimension lower bounds for Euclidean Besicovitch sets.
