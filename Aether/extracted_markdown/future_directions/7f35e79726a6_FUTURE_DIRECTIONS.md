# Future Directions: Benford Base-Invariance for Prime-Indexed Dynamical Sequences

## Conjecture 1: Full Base-Invariant Benford Transfer for Quadratic Orbits

**Conjecture.** For each fixed integer parameter $c$ and iterate depth $n \geq 1$, if there exists one base $b_0 \geq 2$ with $\log b_0 / \log 2 \notin \mathbb{Q}$ such that the sequence $\{|T_c^{(n)}(p)|\}_{p \text{ prime}}$ is asymptotically Benford in base $b_0$, then for every base $b \geq 2$ with $\log b / \log 2 \notin \mathbb{Q}$, the same sequence is asymptotically Benford in base $b$.

**Test.** For each $c \in \{-10, \dots, 10\}$ and $n \in \{1, 3, 5, 10, 15\}$, compute KL divergence of leading-digit distributions against Benford's law in bases $b \in \{3, 5, 6, 7, 10, 11, 12, 15\}$ using primes $p \leq 10^5$. Plot KL divergence profiles across bases. Search for a triple $(c, b_1, b_2)$ where both $b_1, b_2$ are admissible but one has persistently low KL divergence ($< 0.005$) and the other has persistently high KL divergence ($> 0.05$).

**Refutation criterion.** A single triple $(c, b_1, b_2)$ with statistically significant KL discrepancy (confirmed by chi-squared test at $p < 0.001$) across at least three prime cutoffs ($10^3, 10^4, 10^5$) refutes the conjecture.

**Impact.** If true, this would establish that Benford behavior for polynomial dynamical orbits is a *topological* property of the underlying equidistribution, not an artifact of base choice. This would formalize "Benford rigidity" for a concrete class of arithmetic dynamical systems.

---

## Conjecture 2: Equidistribution of Log-Phases for Quadratic Iterates

**Conjecture.** For every integer $c$ with $|c| \leq 10$ and every $n \geq 2$, the sequence
$$\left\{ \frac{\log |T_c^{(n)}(p)|}{\log b} \right\}_{p \text{ prime}}$$
is equidistributed modulo 1 for every base $b \geq 2$ with $\log b / \log 2 \notin \mathbb{Q}$.

**Test.** Compute the discrepancy $D_N$ (Kolmogorov–Smirnov statistic against uniform on $[0,1)$) of the sequence of fractional parts $\{ \log_b |T_c^{(n)}(p)| \}$ for primes $p \leq N$, with $N \in \{10^3, 10^4, 10^5\}$. If equidistributed, $D_N$ should decay as $O(N^{-1/2})$ up to logarithmic factors.

**Refutation criterion.** If for some $(c, n, b)$, the discrepancy $D_N$ does not decrease as $N$ grows (i.e., $D_{10^5} > D_{10^3}$), or if $D_{10^5} > 0.1$, the conjecture is refuted for those parameters.

**Impact.** This is the analytic input to our formal base-transfer theorem. Proving it for even one family of parameters would complete the formal chain: equidistribution → Benford → base-invariance.

---

## Conjecture 3: Multiplicative Independence Suffices for Pairwise Base Transfer

**Conjecture.** Let $u : \mathbb{N} \to \mathbb{R}_{>0}$ be a sequence such that $n \mapsto \log u_n$ has "generic" growth (e.g., $\log u_n$ is not eventually contained in a discrete subgroup of $\mathbb{R}$). If $u$ is Benford in base $a \geq 2$ and $a, b$ are multiplicatively independent, then $u$ is Benford in base $b$.

**Test.** Construct explicit sequences where equidistribution can be verified analytically (e.g., $u_n = 2^{n\alpha}$ for $\alpha$ irrational). Test whether Benford in base 10 implies Benford in base 3 (which are multiplicatively independent). Construct a counterexample attempt using $u_n = 10^{n/\log_{10}(3)}$ which is designed to have non-generic log growth.

**Refutation criterion.** Exhibit a specific sequence $u$ that is Benford in base $a$ but not in base $b$ where $a, b$ are multiplicatively independent, without violating the genericity condition.

**Impact.** This would strengthen our base-transfer theorem from requiring equidistribution in *all* admissible bases to requiring it in just *one*, under a natural genericity hypothesis. This is the strongest form of Benford rigidity.

---

## Conjecture 4: KL Divergence Decay Rate Universality

**Conjecture.** For prime-indexed quadratic iterates $|T_c^{(n)}(p)|$ with $c$ fixed and $n$ sufficiently large, the KL divergence to Benford's law satisfies
$$D_{\text{KL}}(\text{observed}_N \| \text{Benford}) = O(1/\sqrt{N})$$
uniformly across all admissible bases $b$, where $N$ is the number of primes used.

**Test.** For $c \in \{0, 1, -1\}$, $n \in \{3, 5, 10\}$, and $b \in \{3, 7, 10\}$, compute KL divergence using $N \in \{100, 500, 1000, 5000, 10000\}$ primes. Fit the decay rate $D_{\text{KL}} \sim C \cdot N^{-\gamma}$ and estimate $\gamma$. The conjecture predicts $\gamma \approx 0.5$.

**Refutation criterion.** If $\gamma < 0.3$ for some parameter choice, or if $\gamma$ varies by more than a factor of 2 across admissible bases for the same $(c, n)$, the conjecture is refuted.

**Impact.** A universal decay rate would connect Benford convergence to the central limit theorem for equidistribution, suggesting that the *rate* of Benford convergence is also base-invariant — a quantitative strengthening of the qualitative base-transfer theorem.

---

## Conjecture 5: Non-Admissible Bases Exhibit Structural Deviation

**Conjecture.** For bases $b$ that are powers of 2 (i.e., $\log b / \log 2 \in \mathbb{Q}$), the sequence $|T_c^{(n)}(p)|$ does *not* satisfy Benford's law in base $b$, even when it is Benford in all admissible bases. Specifically, the digit distribution in base $b = 2^k$ carries a detectable signature of the binary structure of the iterates.

**Test.** Compare KL divergences for $b \in \{2, 4, 8, 16\}$ (non-admissible) versus $b \in \{3, 5, 7, 10\}$ (admissible) for $c = 0, n = 3$, primes $p \leq 10^4$. The conjecture predicts a systematic gap: KL for non-admissible bases should be $\geq 5\times$ larger than for admissible bases.

**Refutation criterion.** If KL divergence for some non-admissible base is comparable to (within 2×) the KL for admissible bases, the conjecture is refuted.

**Impact.** This would complete the picture: base-invariance holds exactly within the admissible class, while non-admissible bases carry arithmetic obstructions. It would give Benford's law a sharp boundary determined by the number-theoretic structure of the base.
