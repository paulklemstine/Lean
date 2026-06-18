# Future Directions: Certified Prime Gap Theory

## 1. Cramér-Model Occupancy Threshold

**Conjecture**: For every real $A > 1$, there exists $N_0$ such that for all $N \geq N_0$, the Cramér model (independent Bernoulli trials with probability $1/\log m$ at each integer $m$) assigns probability at least $1 - e^{-A+\varepsilon}$ to the event that the interval $[N, N + \lceil A (\log N)^2 \rceil]$ contains at least one model-prime.

**Test**: Formalize a finite Bernoulli product measure on intervals $\{N, \ldots, N+H\}$ where each element is independently selected with probability $\text{cramerWeight}(m)$. Using the certified expectation lower bound `expectedPrimeLikes_interval_lower`, show that the sum of selection probabilities $S \geq (H+1)/\log(N+H)$. When $H = \lceil A(\log N)^2 \rceil$, this sum grows like $A \log N$, which diverges. Then apply the inequality $\Pr(\text{none selected}) = \prod(1-p_m) \leq e^{-S}$ to derive a lower bound on occupancy that tends to 1.

**Refutation criterion**: Failure to derive a uniform positive lower bound for the occupancy probability from the certified expectation estimates alone — e.g., if the product inequality requires additional independence structure beyond what is formalizable in the current Mathlib probability framework.

**Impact**: A positive result would give the first machine-checked probabilistic prediction of Cramér-scale prime gaps, creating a formal bridge between deterministic number theory and probabilistic heuristics.

---

## 2. Prime/Model Discrepancy Functional

**Conjecture**: There exists a formally definable discrepancy statistic $D(N, H)$ comparing the true prime count $\pi(N+H) - \pi(N)$ and the Cramér model expectation $\sum_{m=N}^{N+H} 1/\log m$ on intervals $[N, N+H]$, such that $D(N, \lceil (\log N)^2 \rceil)$ is unbounded as $N \to \infty$.

**Test**: Define $D(N,H) = |\pi(N+H) - \pi(N) - \sum_{m=N}^{N+H} 1/\log m|$ in the formal framework. Compute $D$ for explicit ranges $N \leq 10^6$ using certified decidable prime-testing. Investigate whether the discrepancy grows logarithmically, like $\sqrt{\log N}$, or remains bounded.

**Refutation criterion**: Certified numerical evidence that the discrepancy $D(N, \lceil (\log N)^2 \rceil)$ remains uniformly bounded across all tested ranges up to $N = 10^8$, suggesting the Cramér model may be more accurate than expected at this scale.

**Impact**: A growing discrepancy would quantify exactly where the Cramér heuristic fails, pointing toward Granville-type corrections ($\sim 2e^{-\gamma}(\log p)^2$ instead of $(\log p)^2$). A bounded discrepancy would be surprising evidence for the model's accuracy.

---

## 3. Spectral Spacing Analogy for Prime Gaps

**Conjecture**: Normalized prime gaps $g_n / (\log p_n)^2$ exhibit finite-sample spacing statistics closer to a Poisson (exponential) distribution than to Wigner-Dyson (GUE/GOE) statistics, as measured by the nearest-neighbor spacing distribution.

**Test**: Define a finite histogram pipeline in the formal framework: compute consecutive prime gaps for $p_n \leq 10^7$, normalize by $(\log p_n)^2$, bin the results, and compare the empirical CDF to the Poisson spacing CDF $P(s) = 1 - e^{-s}$ and the Wigner surmise $P_W(s) = 1 - e^{-\pi s^2/4}$ using Kolmogorov–Smirnov statistics.

**Refutation criterion**: Certified numerical evidence that the K-S statistic for the Wigner surmise is systematically smaller than for the Poisson distribution across multiple dyadic ranges $[2^k, 2^{k+1}]$ for $k = 10, \ldots, 23$. This would suggest primes exhibit spectral rigidity analogous to eigenvalues of random matrices — a profound structural claim.

**Impact**: Confirmation of Poisson statistics validates the independence assumption in Cramér's model. Deviation toward Wigner-Dyson would connect prime gaps to random matrix theory and suggest deep correlations in the prime sequence beyond what current heuristics capture.

---

## 4. Log-Compressed Prime Gap Stability

**Conjecture**: The normalized observable $g_n / (\log p_n)^2$ is more stable under dyadic rescaling than the raw gap $g_n$ itself, in the sense of smaller certified oscillation (max minus min) on intervals $[2^k, 2^{k+1}]$.

**Test**: For each dyadic interval $[2^k, 2^{k+1}]$ with $k = 5, \ldots, 20$:
1. Compute the oscillation $\text{osc}_k = \max g_n - \min g_n$ for primes $p_n \in [2^k, 2^{k+1}]$.
2. Compute the normalized oscillation $\text{osc}^*_k = \max(g_n/(\log p_n)^2) - \min(g_n/(\log p_n)^2)$.
3. Compare the growth rates: $\text{osc}_k$ should grow roughly like $(\log 2^k)^2 = k^2 \log^2 2$, while $\text{osc}^*_k$ should remain bounded or grow much more slowly.

**Refutation criterion**: Certified computations showing $\text{osc}^*_k$ grows at the same rate as $\text{osc}_k / (\log 2^k)^2$, with no reduction in oscillation after normalization. This would mean the normalization does not stabilize gap fluctuations, challenging the Cramér prediction.

**Impact**: Stability of the normalized observable would provide empirical support for Cramér's conjecture at finite scales and justify using $(\log n)^2$ as the correct normalization scale. Instability would suggest that prime gaps have richer multi-scale structure than the simple Cramér model predicts.

---

## 5. Bertrand-to-Cramér Formal Bridge (Transfer Principle)

**Conjecture**: Every future strengthening of interval-prime existence theorems in the formal framework can be *functorially* converted into a prime gap upper bound via the certified transfer principle `gap_from_interval_bound`.

**Test**: The theorem `gap_from_interval_bound` takes as input any function $F : \mathbb{N} \to \mathbb{N}$ and a proof that $\forall n \geq N_0, \exists p \text{ prime}, n < p \leq n + F(n)$, and outputs $\forall n \geq N_0, \text{primeGapAfter}(n) \leq F(n)$. Test this principle with:
- $F(n) = n$ (Bertrand — already proven)
- $F(n) = n^{0.525}$ (Baker–Harman–Pintz, 2001 — requires formalizing their result)
- $F(n) = n^{1/2 + \varepsilon}$ (conditional on RH)
- $F(n) = C (\log n)^2$ (Cramér's conjecture)

For each, verify that `gap_from_interval_bound` correctly produces the corresponding gap bound.

**Refutation criterion**: Discovery of an interval-prime theorem whose formal statement is not compatible with the input signature of `gap_from_interval_bound` — e.g., theorems stated in terms of $\pi(x)$ asymptotics rather than explicit interval existence, requiring a nontrivial conversion step that the current transfer principle cannot automate.

**Impact**: A positive result means the formal prime gap framework is *future-proof*: any advance in explicit prime-in-interval results immediately yields a certified gap bound, making the framework a permanent piece of mathematical infrastructure.
