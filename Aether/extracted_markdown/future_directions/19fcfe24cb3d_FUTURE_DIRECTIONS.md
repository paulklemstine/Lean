# Future Directions: Weighted-to-Unweighted Descent for Lorentzian Shadows

## Synthesis

The descent pipeline established in this work — weighted log-concavity + weight-ratio log-convexity ⟹ unweighted log-concavity — creates a modular framework for transferring algebraic properties from "easy" weighted counts to "hard" unweighted counts. The computational experiments reveal that the naive weight ratio fails to be log-convex for matroid basis polynomials, pointing toward a **normalized descent conjecture** as the key open problem. The descending factorial log-concavity theorem provides the algebraic foundation for such normalization. Five concrete research directions emerge, ranging from immediate extensions (Direction 1) to paradigm-shifting conjectures (Direction 5), all testable and falsifiable.

---

## Direction 1: Normalized Descent for Lorentzian Polynomials

**Conjecture:** For a homogeneous Lorentzian polynomial $f$ of degree $d$ in $n$ variables, the normalized weight ratio
$$\tilde{r}_k = \frac{W_k(f)}{\binom{n}{k} \cdot d^{\underline{k}}}$$
is log-convex in $k$ for $1 \leq k \leq d-1$.

**Test:** Compute $\tilde{r}_k$ for the basis polynomial of the uniform matroid $U_{3,7}$ and the Fano matroid $F_7$. Verify $\tilde{r}_k^2 \leq \tilde{r}_{k-1} \cdot \tilde{r}_{k+1}$ for $k = 1, \ldots, d-2$. A single matroid failure disproves the conjecture.

**Impact:** Would complete the descent pipeline for Lorentzian polynomials, giving a new proof of the Mason conjecture and extending it to all Lorentzian polynomial shadows.

**Catalog References:**
- `Pythagorean/WeightedDescentLorentzian.lean`: `descFactorial_sq_ge`, `descent_inequality`
- `Pythagorean/IteratedShadowGeometry.lean`: `coeff_iteratedPDeriv`, `descFactorial_prod_pos`

**Proof Strategy:** Express $\tilde{r}_k$ as a ratio of integrals over the Lorentzian cone. Use the Hodge-Riemann bilinear relations to show the integrand satisfies a Cauchy-Schwarz inequality, which translates to log-convexity of $\tilde{r}_k$.

**Domain Bridges:** Algebraic geometry (Hodge theory), convex geometry (mixed volumes), probability (moment problems).

**Lineage:** Extends `descFactorial_sq_ge` and `descent_inequality` by providing the missing ingredient (normalized ratio log-convexity).

**Ambition:** ★★★★ — Would resolve a key gap in Lorentzian polynomial theory.

---

## Direction 2: Iterated Descent and Fixed-Point Sequences

**Conjecture:** Define the "descent operator" $\mathcal{D}$ that maps a log-concave sequence $(a_k)$ to the sequence of ratios $a_k / a_{k-1}$. For Lorentzian polynomial shadow sequences, the iterated descent $\mathcal{D}^m(\text{Sh}_k)$ converges to a geometric sequence as $m \to \infty$.

**Test:** For the uniform matroid $U_{4,8}$, compute $\text{Sh}_k$, then $\mathcal{D}(\text{Sh}_k) = \text{Sh}_k/\text{Sh}_{k-1}$, then $\mathcal{D}^2(\text{Sh}_k)$, etc. Check if the sequence stabilizes (ratios become constant).

**Impact:** Would establish a new invariant of Lorentzian polynomials — the "descent fixed point" — potentially classifying them by their asymptotic ratio.

**Catalog References:**
- `Pythagorean/WeightedDescentLorentzian.lean`: `DescentData`, `log_concave_of_descent_data`

**Proof Strategy:** Model the descent operator as a contraction mapping on the space of log-concave sequences. Use the Banach fixed-point theorem to prove convergence. The key estimate is that $\mathcal{D}$ reduces the "log-concavity gap" by a factor related to the descending factorial ratio $(x-k+1)/(x-k)$.

**Domain Bridges:** Dynamical systems (contraction mappings), functional analysis (operator theory).

**Lineage:** Natural iteration of the descent pipeline from `log_concave_of_descent_data`.

**Ambition:** ★★★ — Accessible and testable, with potentially deep connections.

---

## Direction 3: Tropical Brunn-Minkowski via Shadow Sequences

**Conjecture (Grand Challenge):** The shadow sequence $(\text{Sh}_0, \text{Sh}_1, \ldots, \text{Sh}_d)$ of a Lorentzian polynomial satisfies a **tropical Brunn-Minkowski inequality**: for the support $A = \text{Supp}(f)$,
$$|\text{Sh}_k(A)|^{1/k} \geq |\text{Sh}_1(A)|/|A|$$
This is a tropical analog of the classical Brunn-Minkowski inequality $|A+B|^{1/n} \geq |A|^{1/n} + |B|^{1/n}$, where the "addition" is replaced by shadow projection.

**Test:** Compute $|\text{Sh}_k|^{1/k}$ for various matroid support sets. Verify the inequality against $|\text{Sh}_1|/|A|$. Test on random Lorentzian polynomial supports with $n \leq 8$.

**Impact:** Would establish a fundamental inequality in tropical geometry with applications to discrete optimization and lattice point counting.

**Catalog References:**
- `Pythagorean/IteratedShadowGeometry.lean`: `kthShadow`, `kthShadow_add`

**Proof Strategy:** Use the semigroup law `kthShadow_add` to decompose $\text{Sh}_k$ as iterated 1-shadows. Apply the submodularity of the shadow operator (if provable) to establish the inequality via an inductive argument.

**Domain Bridges:** Convex geometry (Brunn-Minkowski), tropical geometry, discrete optimization.

**Lineage:** Builds on `kthShadow_add` and the shadow profile theory from IteratedShadowGeometry.

**Ambition:** ★★★★★ — Paradigm-shifting if true. Would unify tropical and classical convex geometry.

---

## Direction 4: Rényi Entropy Descent and Information-Theoretic Log-Concavity

**Conjecture:** The weight ratio $r_k = W_k/\text{Sh}_k$ is related to the exponential of the Rényi entropy of order $\alpha = 1$ of the "derivative distribution" $p_\gamma = |\text{supp}(\partial^\gamma f)| / W_k$. Specifically:
$$r_k = \exp(H_1(\{p_\gamma\}_\gamma))$$
where $H_1$ is the Shannon entropy. The log-convexity (or concavity) of $r_k$ then translates to a monotonicity property of the entropy, analogous to the data processing inequality.

**Test:** For each matroid, compute the distribution $p_\gamma$ and its Shannon entropy at each level $k$. Check if the entropy sequence $H_k$ is concave (which would imply $r_k$ is log-concave, consistent with our computational findings).

**Impact:** Would bridge combinatorial log-concavity theory with information theory, potentially providing new proofs via entropy methods.

**Catalog References:**
- `Pythagorean/WeightedDescentLorentzian.lean`: `descent_inequality`, weight ratio analysis

**Proof Strategy:** Express $r_k$ as an exponential of the Shannon entropy of the derivative distribution. Use the data processing inequality to bound how entropy changes under the derivative operation. The Lorentzian condition translates to a "negative curvature" condition on the entropy landscape.

**Domain Bridges:** Information theory (Rényi entropy, data processing), probability (log-concave distributions), statistical mechanics.

**Lineage:** Extends the weight ratio analysis from `descent_inequality` to an information-theoretic setting.

**Ambition:** ★★★★ — Cross-domain bridge between two major theories.

---

## Direction 5: Universal Log-Concavity Classifier via Descent Data

**Conjecture (Grand Challenge):** Every log-concave sequence arising from a "natural" combinatorial source (matroid invariants, graph polynomials, symmetric function coefficients) admits a `DescentData` decomposition with a suitable normalization. More precisely, there exists a universal normalization function $N(k, \text{parameters})$ such that:
1. The weighted sequence $W_k = N(k) \cdot a_k$ is always log-concave.
2. The normalization $N(k)$ is always log-convex.
3. Hence $a_k$ is log-concave by the descent pipeline.

**Test:** For each of the following sequences, attempt to find $N(k)$: (a) independent set counts of a matroid, (b) face numbers of a simplicial complex, (c) coefficients of the chromatic polynomial, (d) Kazhdan-Lusztig coefficients. If any natural log-concave sequence resists all normalizations, the conjecture is false.

**Impact:** Would provide a "master theorem" explaining all combinatorial log-concavity as instances of the descent pipeline, analogous to how the transfer matrix method unifies many sequence enumeration problems.

**Catalog References:**
- `Pythagorean/WeightedDescentLorentzian.lean`: `DescentData`, `log_concave_of_descent_data`

**Proof Strategy:** Start with the simplest case (matroid independent sets) where the normalization should involve descending factorials and binomial coefficients. Extend to simplicial complexes using the algebraic shifting technique. For Kazhdan-Lusztig coefficients, the normalization likely involves $q$-analogs of descending factorials.

**Domain Bridges:** Representation theory (Kazhdan-Lusztig), algebraic topology (simplicial complexes), algebraic combinatorics (symmetric functions).

**Lineage:** Ultimate generalization of the `DescentData` structure.

**Ambition:** ★★★★★ — Would be a fundamental contribution to algebraic combinatorics.

---

## Summary of Priorities

| Priority | Direction | Testability | Ambition |
|----------|-----------|-------------|----------|
| 1 | Normalized descent conjecture | Immediate | ★★★★ |
| 2 | Iterated descent fixed points | Immediate | ★★★ |
| 3 | Tropical Brunn-Minkowski | Medium-term | ★★★★★ |
| 4 | Rényi entropy descent | Medium-term | ★★★★ |
| 5 | Universal log-concavity classifier | Long-term | ★★★★★ |

The key insight tying all directions together is that **log-concavity is not a single phenomenon but a family of related phenomena**, connected by the descent pipeline. Each direction explores a different facet of this family, and progress on any one direction is likely to inform the others.

Why now? The formal verification of the descent inequality and descending factorial log-concavity provides a solid foundation. The computational experiments have identified the exact boundary where the naive pipeline fails, giving precise targets for the normalized conjecture. And the `DescentData` structure provides the right abstraction for exploring generalizations.
