# Future Directions: Prime Gaps Around Square Intervals

## Hypothesis 1: Gap-Threshold Conjecture

**Conjecture.** There exists an explicit constant $N_0$ such that for all $m \geq N_0$, there exists a prime $p$ with $m < p \leq m + 2\lfloor\sqrt{m}\rfloor + 1$.

**Precision.** This is equivalent to asserting that Legendre's conjecture holds for all $n \geq \lceil\sqrt{N_0}\rceil$. Our formal reduction theorem (`legendre_of_prime_in_short_intervals`) proves this implication rigorously. The conjecture is strictly stronger than Legendre because it asserts short-interval prime existence for *all* starting points $m$, not just perfect squares.

**Test.** Compute the maximal prime gap $g(m) = p_{k+1} - p_k$ for primes $p_k \leq M$ and check whether $g(m) < 2\sqrt{p_k} + 1$ for all $p_k$ in the range. Known tables of maximal prime gaps (Oliveira e Silva, Nicely) can be queried up to $4 \times 10^{18}$. Any violation would refute the conjecture; sustained verification would increase confidence.

**Impact.** If true, this would resolve Legendre's conjecture via the finite verification architecture (`legendre_of_eventually_verified`), reducing the problem to checking finitely many $n < \sqrt{N_0}$.

---

## Hypothesis 2: Square-Interval Double Occupancy

**Conjecture.** For all $n \geq 27$, the interval $(n^2, (n+1)^2)$ contains at least two primes: $\text{squarePrimeCount}(n) \geq 2$.

**Precision.** Computational evidence shows $\text{squarePrimeCount}(n) \geq 2$ for all $n \geq 27$. Below this, the singleton cases are $n = 1$ (only prime: 3) and a few other small values. The Cramér model predicts the expected count $E_n \sim n / \log n$, which grows without bound, making zero-prime or single-prime intervals increasingly improbable.

**Test.** Enumerate $\text{squarePrimeCount}(n)$ for $n$ up to $10^8$ and verify the minimum is at least 2 for $n \geq 27$. Search for the minimum-count $n$ values and track whether the minimum grows with the range.

**Impact.** If true, this is substantially stronger than Legendre's conjecture. It would imply Legendre and additionally provide a *density floor* for primes between squares, with implications for the Riemann Hypothesis via explicit zero-free regions.

---

## Hypothesis 3: Cramér Calibration Hypothesis

**Conjecture.** The ratio $\text{squarePrimeCount}(n) / \text{cramerSquareExpectation}(n)$ has limsup equal to $2e^{-\gamma}$ and liminf equal to $1$ (where $\gamma$ is the Euler-Mascheroni constant), matching the behavior predicted by the Hardy-Littlewood refinement of the Cramér model.

**Precision.** The pure Cramér model predicts the ratio tends to 1, but the Hardy-Littlewood correction (accounting for small prime divisibility patterns) predicts fluctuations between 1 and $2e^{-\gamma} \approx 1.1229$. The lower bound should approach 1 from above due to twin-prime-like correlations.

**Test.** Compute the ratio for $n$ up to $10^7$ at regularly spaced intervals. Track the running minimum and maximum of the ratio over windows of width $\sqrt{n}$. Compare against the predicted bounds $[1, 2e^{-\gamma}]$.

**Impact.** This would provide the first formal connection between the Cramér model and actual prime distribution in square intervals. If confirmed, it would support formalizing Hardy-Littlewood-type corrections in the Lean framework, significantly strengthening the heuristic bridge.

---

## Hypothesis 4: Brocard-Strengthened Conjecture

**Conjecture.** For all $k \geq 4$, the interval $(p_k^2, p_{k+1}^2)$ contains at least 4 primes, where $p_k$ denotes the $k$-th prime.

**Precision.** Brocard's conjecture asserts at least 4 primes between consecutive prime squares. This is much stronger than Legendre because the gap $p_{k+1}^2 - p_k^2 = (p_{k+1} - p_k)(p_{k+1} + p_k)$ can be large. Our formal framework can be adapted to Brocard by defining `brocardInterval k` analogously to `squareInterval n` and proving reduction theorems.

**Test.** For primes $p_k$ up to $10^9$, compute the prime count in $(p_k^2, p_{k+1}^2)$ and verify it is at least 4 for $k \geq 4$. Track the minimum count and the $k$ values that achieve it.

**Impact.** Formal verification of Brocard for a large range would open a new class of structured interval conjectures to the Lean framework. The reduction architecture (`legendre_of_eventually_verified`) generalizes directly to Brocard-type statements.

---

## Hypothesis 5: Polylogarithmic Witness Complexity

**Conjecture.** For all $n \geq 2$, the smallest prime in $(n^2, (n+1)^2)$ satisfies $p - n^2 \leq C(\log n)^2$ for an absolute constant $C > 0$.

**Precision.** The Cramér conjecture predicts maximal prime gaps of order $(\log p)^2$. Applied to $p \approx n^2$, this gives gaps of order $(\log n)^2$. If true, a deterministic search starting at $n^2 + 1$ would find a prime in $O((\log n)^2)$ steps, making Legendre witnesses *efficiently certifiable*.

**Test.** For $n$ up to $10^8$, compute $\delta(n) = \min\{p - n^2 : p \text{ prime}, p > n^2\}$ and plot $\delta(n) / (\log n)^2$. If the ratio is bounded, estimate the constant $C$. If $\delta(n)$ grows faster, the hypothesis is refuted.

**Impact.** A positive result would connect Legendre's conjecture to computational complexity theory: prime witnesses near squares would be polynomial-time certifiable. This has direct applications to deterministic primality testing and cryptographic parameter generation. In the Lean framework, it would justify adding a computational verification oracle that checks Legendre by bounded search rather than exhaustive enumeration.
