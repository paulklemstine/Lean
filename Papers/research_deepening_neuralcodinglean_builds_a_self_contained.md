# Energy Concentration in Dense Neural Codes: Exact Moments and a Metabolic Law of Large Numbers

**Author:** Aristotle
**Date:** 2026-07-12
**Domain:** Applications (Mathematical Neuroscience / Combinatorial Coding Theory)

## Abstract

We study the metabolic energy of dense binary neural codes on $N$ neurons, modeled as the number of active neurons (the *weight*) of a binary pattern, under the uniform distribution over all $2^N$ patterns. Building on classical first-moment facts — a repertoire capacity of $2^N$, a per-neuron doubling law, and an average energy of $N/2$ — we compute the exact second-order statistics of the weight and derive a sharp concentration statement. Our central combinatorial input is a *second-order symmetry*: a fixed pair of distinct neurons is jointly active in exactly $2^{N-2}$ codes. From this we obtain the exact second moment $\sum_c (\mathrm{weight}\,c)^2 = 2^N \cdot N(N+1)/4$, the exact total squared deviation $\sum_c (\mathrm{weight}\,c - N/2)^2 = N\cdot 2^N/4$, and hence a variance of exactly $N/4$ — the binomial variance $Np(1-p)$ at $p=\tfrac12$. Chebyshev's inequality then yields that the fraction of codes deviating from the mean $N/2$ by at least $t$ is at most $N/(4t^2)$, and in particular that at least three quarters of all $2^N$ codes lie within $\sqrt N$ of $N/2$. Dense neural coding thus obeys a *metabolic law of large numbers*: the population energy concentrates around $N/2$ with a relative fluctuation of order $1/\sqrt N$. All results are exact for every $N \ge 0$, with no boundary defects. We close with numerical illustrations and a program of conjectures pushing the moment$\to$concentration$\to$geometry pipeline toward sub-Gaussian tails and coding-theoretic trade-offs.

## 1. Introduction

Neural computation is metabolically expensive. Each action potential ("spike") consumes energy, and the brain devotes a disproportionate share of the body's metabolic budget to sustaining and signaling with its neurons. A population of $N$ neurons, each momentarily active or silent, represents information through the *pattern* of who is firing. The number of active neurons in such a pattern is a direct proxy for its energetic cost. Understanding the distribution of this cost across the space of possible patterns is therefore both a mathematical and a biophysical question.

Classical, first-moment neural-coding facts are well known: a population of $N$ binary neurons has a repertoire of $2^N$ distinguishable patterns (capacity), each additional neuron doubles the repertoire (the per-neuron doubling law), the average number of active neurons over all patterns is $N/2$ (average dense energy), the number of patterns with exactly $k$ active neurons is $\binom{N}{k}$ (sparse counts), and populations achieve estimation precision scaling as $1/\sqrt N$ (population coding). These are statements about *means* and *counts*.

This paper goes one order deeper. We compute the exact *second-order* statistics of the weight and convert them into a rigorous concentration statement. The upshot is that the average energy $N/2$ is not merely a central tendency around which patterns are broadly scattered; it is a sharp attractor. Almost all patterns cost almost exactly $N/2$ spikes, with fluctuations confined to a window of width $\sqrt N$ — vanishingly narrow relative to the range $[0,N]$ as the population grows. This is the metabolic analogue of the law of large numbers.

## 2. Model and Definitions

**Definition 2.1 (Neural code).** A *neural code on $N$ neurons* is a function
$$c : \{0, 1, \dots, N-1\} \to \{\text{true}, \text{false}\},$$
assigning to each neuron a binary state (active = true, silent = false). We write $\mathrm{NeuralCode}(N)$ for the set of all such codes. There are exactly $2^N$ of them.

**Definition 2.2 (Weight / metabolic energy).** The *weight* of a code $c$, written $\mathrm{weight}(c)$, is the number of active neurons:
$$\mathrm{weight}(c) = \#\{\,i : c(i) = \text{true}\,\} = \sum_{i=0}^{N-1} \mathbf{1}[c(i) = \text{true}],$$
where $\mathbf{1}[\cdot]$ is the $0/1$ indicator. The weight is the metabolic energy: the number of spikes required to realize the pattern.

**Probabilistic viewpoint.** We regard all $2^N$ codes as equally likely. Under this uniform measure, $\mathrm{weight}$ is a random variable, and expectations, moments, variances, and tail probabilities are all averages over the $2^N$ codes:
$$\mathbb{E}[f] = \frac{1}{2^N} \sum_{c \in \mathrm{NeuralCode}(N)} f(c).$$

**Foundational first-moment facts (assumed / classical).** We take as given the following elementary counting results, which anchor the theory:

- **(Capacity)** $\#\,\mathrm{NeuralCode}(N) = 2^N$.
- **(First-order symmetry)** For any single neuron $i$ and any $N \ge 1$, the number of codes with $c(i) = \text{true}$ is $2^{N-1}$; fixing one coordinate leaves the other $N-1$ free.
- **(Total weight / average energy)** $\sum_{c} \mathrm{weight}(c) = N \cdot 2^{N-1}$, hence $\mathbb{E}[\mathrm{weight}] = N/2$.

Our contribution begins with the second-order refinement of the first-order symmetry.

**The binomial profile.** It is worth recording the exact distribution of the weight, which underlies both our proofs and the numerical illustrations. The number of codes with exactly $k$ active neurons is the binomial coefficient $\binom{N}{k}$, since a code of weight $k$ is precisely a choice of the $k$-element subset of active neurons. Consequently, under the uniform measure,
$$\Pr[\mathrm{weight} = k] = \frac{\binom{N}{k}}{2^N}, \qquad k = 0, 1, \dots, N,$$
which is exactly the probability mass function of a Binomial$(N, \tfrac12)$ random variable. This is no accident: the $N$ coordinates $c(0), \dots, c(N-1)$ are independent under the uniform measure, each an unbiased fair coin, and the weight is their sum. Every moment we compute below can therefore be cross-checked against the binomial formula $\sum_c \mathrm{weight}(c)^m = \sum_{k=0}^N \binom{N}{k} k^m$. The value of the results that follow is that they establish these facts *directly and exactly*, purely by counting patterns, without invoking any probabilistic apparatus, and with manifest boundary-robustness for the degenerate cases $N = 0$ and $N = 1$.

## 3. Second-Order Symmetry: Joint Activity of a Pair

**Theorem 3.1 (Pairwise joint activity).** *For any two distinct neurons $i \ne j$, the number of codes in which both are simultaneously active is exactly*
$$\#\{\,c : c(i) = \text{true} \text{ and } c(j) = \text{true}\,\} = 2^{N-2}.$$

*Proof sketch.* Fixing both coordinates $i$ and $j$ to "true" leaves the remaining $N-2$ coordinates entirely free, each with two choices; there are $2^{N-2}$ such assignments. A tidy way to see this without loss of boundary robustness is to partition the codes with $c(i)=\text{true}$ according to the value of $c(j)$: those with $c(j)=\text{true}$ and those with $c(j)=\text{false}$ are in bijection (flip coordinate $j$), so each class holds half of the $2^{N-1}$ codes with $c(i)=\text{true}$, namely $2^{N-2}$. The requirement $i \ne j$ is essential: for a single neuron the corresponding count is $2^{N-1}$, not $2^{N-2}$. $\square$

This is the *second-order symmetry*, the natural sequel to the first-order fact that a single neuron is active in $2^{N-1}$ codes. It is the sole new combinatorial ingredient needed for everything that follows.

## 4. The Exact Second Moment

**Theorem 4.1 (Second moment).** *For every $N \ge 0$,*
$$\sum_{c \in \mathrm{NeuralCode}(N)} \big(\mathrm{weight}(c)\big)^2 = 2^N \cdot \frac{N(N+1)}{4},$$
*equivalently $\mathbb{E}[\mathrm{weight}^2] = \dfrac{N(N+1)}{4}$.*

*Proof sketch.* Write the weight as a sum of indicators, $\mathrm{weight}(c) = \sum_i \mathbf{1}[c(i)]$. Squaring and expanding gives a double sum over ordered pairs of neurons:
$$\mathrm{weight}(c)^2 = \sum_{i}\sum_{j} \mathbf{1}[c(i)]\,\mathbf{1}[c(j)].$$
Summing over all codes and exchanging the order of summation turns each pair $(i,j)$ into a *joint activity count*:
$$\sum_c \mathrm{weight}(c)^2 = \sum_i \sum_j \Big( \sum_c \mathbf{1}[c(i)]\,\mathbf{1}[c(j)] \Big).$$
The inner sum is a count of codes:
$$\sum_c \mathbf{1}[c(i)]\,\mathbf{1}[c(j)] = \begin{cases} 2^{N-1}, & i = j \quad (\text{first-order symmetry}), \\[2pt] 2^{N-2}, & i \ne j \quad (\text{Theorem 3.1}). \end{cases}$$
There are $N$ diagonal terms and $N(N-1)$ off-diagonal terms, so
$$\sum_c \mathrm{weight}(c)^2 = N\cdot 2^{N-1} + N(N-1)\cdot 2^{N-2} = 2^{N-2}\big(2N + N(N-1)\big) = 2^{N-2}\,N(N+1) = 2^N\cdot \frac{N(N+1)}{4}.$$
The closed form is exact for every $N$, including the degenerate $N=0$ and $N=1$: the $N(N-1)$ prefactor annihilates the pair contribution precisely when no pair exists, so there is no boundary defect. $\square$

## 5. Total Squared Deviation and the Variance

**Theorem 5.1 (Total squared deviation).** *For every $N \ge 0$,*
$$\sum_{c \in \mathrm{NeuralCode}(N)} \Big(\mathrm{weight}(c) - \frac{N}{2}\Big)^2 = \frac{N \cdot 2^N}{4}.$$

*Proof sketch.* Expand the square and use linearity:
$$\sum_c \Big(\mathrm{weight}(c) - \tfrac N2\Big)^2 = \sum_c \mathrm{weight}(c)^2 - N\sum_c \mathrm{weight}(c) + \frac{N^2}{4}\sum_c 1.$$
Substitute the three exact totals: $\sum_c \mathrm{weight}(c)^2 = 2^N N(N+1)/4$ (Theorem 4.1), $\sum_c \mathrm{weight}(c) = N\cdot 2^{N-1}$ (total weight), and $\sum_c 1 = 2^N$ (capacity). This gives
$$\frac{2^N N(N+1)}{4} - N\cdot N\cdot 2^{N-1} + \frac{N^2}{4}\cdot 2^N = \frac{2^N}{4}\Big(N(N+1) - 2N^2 + N^2\Big) = \frac{2^N}{4}\cdot N = \frac{N\cdot 2^N}{4}.\ \square$$

**Theorem 5.2 (Variance is $N/4$).** *For every $N \ge 0$, the variance of the weight under the uniform measure is*
$$\mathrm{Var}[\mathrm{weight}] = \frac{1}{2^N}\sum_{c} \Big(\mathrm{weight}(c) - \frac N2\Big)^2 = \frac{N}{4}.$$

*Proof.* Divide Theorem 5.1 by $2^N$. $\square$

**Remark (Binomial identity).** The pair $(\text{mean}, \text{variance}) = (N/2,\ N/4)$ is exactly $(Np,\ Np(1-p))$ for a Binomial$(N,p)$ at $p = \tfrac12$. Indeed the weight *is* a Binomial$(N,\tfrac12)$ variable: it is the sum of $N$ independent fair Bernoulli coordinates. The value $N/4$ is the algebraic fingerprint of the independence of the $N$ neurons, and the standard deviation is $\sqrt N / 2$.

## 6. Concentration

**Theorem 6.1 (Chebyshev concentration).** *For every $N \ge 0$ and every threshold $t > 0$, the number of codes whose weight deviates from the mean by at least $t$ satisfies*
$$\#\Big\{\,c : \big|\mathrm{weight}(c) - \tfrac N2\big| \ge t \,\Big\} \;\le\; \frac{N\cdot 2^N}{4\,t^2},$$
*equivalently, the fraction of such codes is at most $\dfrac{N}{4\,t^2}$.*

*Proof sketch.* Let $A = \{c : |\mathrm{weight}(c) - N/2| \ge t\}$ be the deviating set. Every code $c \in A$ contributes at least $t^2$ to the total squared deviation, so
$$|A|\cdot t^2 \;\le\; \sum_{c \in A}\Big(\mathrm{weight}(c) - \tfrac N2\Big)^2 \;\le\; \sum_{c}\Big(\mathrm{weight}(c) - \tfrac N2\Big)^2 = \frac{N\cdot 2^N}{4},$$
using Theorem 5.1 for the last equality. Dividing by $t^2 > 0$ gives the claim. The hypothesis $t > 0$ is load-bearing (division by $t^2$). $\square$

**Theorem 6.2 (Most codes are near half-active).** *For every $N \ge 1$, at least three quarters of all $2^N$ codes have weight within $\sqrt N$ of the mean $N/2$:*
$$\#\Big\{\,c : \big|\mathrm{weight}(c) - \tfrac N2\big| < \sqrt N \,\Big\} \;\ge\; \frac{3}{4}\cdot 2^N.$$

*Proof.* Apply Theorem 6.1 with threshold $t = \sqrt N > 0$ (positive since $N \ge 1$). The deviating set $A = \{c : |\mathrm{weight}(c) - N/2| \ge \sqrt N\}$ has
$$|A| \le \frac{N\cdot 2^N}{4\,(\sqrt N)^2} = \frac{N\cdot 2^N}{4N} = \frac{2^N}{4}.$$
The complementary set $B = \{c : |\mathrm{weight}(c) - N/2| < \sqrt N\}$ satisfies $|A| + |B| = 2^N$ (the predicates are exact negations of each other and every code is counted once), so
$$|B| = 2^N - |A| \ge 2^N - \frac{2^N}{4} = \frac{3}{4}\cdot 2^N.\ \square$$

**Interpretation.** As $N \to \infty$, the window $\sqrt N$ becomes vanishingly narrow relative to the range $[0,N]$: it is a razor-thin equatorial band around the half-active state. Yet at least three quarters of all patterns fall within it. The *relative* fluctuation of the metabolic cost is
$$\frac{\text{standard deviation}}{\text{mean}} = \frac{\sqrt N/2}{N/2} = \frac{1}{\sqrt N} \to 0.$$
This is the metabolic law of large numbers: dense coding spends $N/2$ spikes on average and, with overwhelming probability, spends essentially that same amount on any given pattern.

## 7. Worked Examples

To make the identities concrete, we tabulate the exact weight distribution and its moments for small $N$. Recall $\Pr[\mathrm{weight}=k] = \binom{N}{k}/2^N$.

**Case $N = 0$.** There is one code (the empty pattern) of weight $0$. The mean is $0/2 = 0$, the second moment is $0$, the centered second moment is $0$, and the variance is $0/4 = 0$. Every closed form ($2^N N(N+1)/4 = 0$, $N\cdot 2^N/4 = 0$) evaluates correctly despite there being no pair of neurons; the $N(N-1)$ prefactor vanishes.

**Case $N = 1$.** There are two codes, of weights $0$ and $1$. Sum of weights $= 1 = 1\cdot 2^0$; sum of squared weights $= 1 = 2^1 \cdot 1 \cdot 2/4$; centered second moment $= (0 - \tfrac12)^2 + (1 - \tfrac12)^2 = \tfrac12 = 1\cdot 2^1/4$; variance $= \tfrac12/2 = \tfrac14 = 1/4$. Again there are no pairs, and every closed form holds exactly.

**Case $N = 4$.** The weight profile is $(\binom40,\dots,\binom44) = (1,4,6,4,1)$, summing to $2^4 = 16$. Sum of weights $= 0\cdot1 + 1\cdot4 + 2\cdot6 + 3\cdot4 + 4\cdot1 = 32 = 4\cdot 2^3$, mean $= 2 = N/2$. Sum of squared weights $= 0 + 4 + 24 + 36 + 16 = 80 = 2^4\cdot 4\cdot 5/4$. Centered second moment $= \sum_k \binom4k (k-2)^2 = 1\cdot4 + 4\cdot1 + 6\cdot0 + 4\cdot1 + 1\cdot4 = 16 = 4\cdot 2^4/4$, so variance $= 16/16 = 1 = N/4$. A fixed pair of distinct neurons is jointly active in $2^{4-2} = 4$ codes, as one checks directly by fixing two coordinates to true and letting the other two range.

**Case $N = 100$.** The mean is $50$, the variance is $25$, and the standard deviation is $5$. The $\sqrt N = 10$ window $[40, 60]$ captures well over $95\%$ of all $2^{100}$ codes, comfortably exceeding the guaranteed $75\%$; the Chebyshev bound (which guarantees the $75\%$) is loose because the true tails decay exponentially, as the sub-Gaussian conjecture predicts.

These examples exhibit the exactness of the identities across the full range from degenerate ($N=0,1$) to large ($N=100$) populations.

## 8. Algorithms

The exact combinatorial identities above admit direct, efficient computation, which we use both to verify the closed forms and to visualize the concentration phenomenon.

**Algorithm 7.1 (Exact moment computation via the binomial profile).** Because the number of codes of weight $k$ is $\binom{N}{k}$, all moments can be computed in $O(N)$ arithmetic operations from the binomial coefficients, without enumerating the $2^N$ codes:
$$\sum_c \mathrm{weight}(c)^m = \sum_{k=0}^{N} \binom{N}{k}\, k^m.$$
For $m = 1$ this returns $N\cdot 2^{N-1}$; for $m = 2$ it returns $2^N N(N+1)/4$; the centered second moment returns $N\cdot 2^N/4$. This provides an independent check of Theorems 4.1 and 5.1.

**Algorithm 7.2 (Chebyshev tail evaluation).** For a threshold $t$, the exact deviating fraction $\frac{1}{2^N}\sum_{k : |k - N/2| \ge t} \binom{N}{k}$ is computed directly from the binomial profile and compared with the Chebyshev ceiling $N/(4t^2)$ and with the tighter sub-Gaussian estimate $2\exp(-2t^2/N)$ — illustrating how loose Chebyshev is and motivating the sub-Gaussian conjecture below.

**Algorithm 7.3 (Brute-force enumeration for small $N$).** For $N$ up to about $20$, enumerating all $2^N$ codes and directly tabulating weights confirms the closed-form moments and the $\tfrac34$-window bound exactly, serving as ground truth for the analytic formulas.

## 9. Applications and Discussion

**Energy budgeting.** The variance $N/4$ and the $\sqrt N$-window bound mean that the metabolic demand of a dense representation is sharply forecastable. A downstream mechanism that must provision energy for a dense code can plan for $N/2$ spikes and be correct to within $\sqrt N$ almost always.

**Coding-theoretic trade-offs.** Because the overwhelming majority of patterns are locked into a thin equatorial shell near half-activity, any code that seeks to be *sparse* (few active neurons, low energy) or to spread its codewords far apart in Hamming distance (noise tolerance) must contend with the statistical gravity of that shell. The concentration result quantifies the tension between low energy, noise tolerance, and full use of the $2^N$ capacity.

**Unity with population precision.** The $\sqrt N$ scale here and the $1/\sqrt N$ precision of population coding are two shadows of one principle: independent contributions from $N$ units fluctuate on the scale $\sqrt N$, so their averages sharpen at the rate $1/\sqrt N$. Metabolic concentration and estimation precision are the same phenomenon viewed from two angles.

**A note on tightness and looseness.** The concentration statement of Theorem 6.2 is genuinely non-vacuous: it exhibits an explicit constant fraction ($3/4$) captured by a concrete window ($\sqrt N$), so the tail bound is not hollow. At the same time, Chebyshev's inequality is deliberately weak: it uses only the second moment, and the true tails of a Binomial$(N,\tfrac12)$ decay exponentially rather than polynomially. The exact deviating fraction at $t = \sqrt N$ hovers around $5$–$8\%$ for moderate $N$, far below the $25\%$ Chebyshev ceiling. This gap is not a defect of our argument but a signpost: the second moment is the sharp instrument for a *polynomial* tail, whereas capturing the *exponential* tail requires the exponential (moment-generating) function of a single neuron. That is precisely the content of the sub-Gaussian conjecture in Section 10, for which the exact second moment computed here is the first, foundational term of the cumulant expansion.

**Robustness of the model.** The uniform measure over all $2^N$ codes corresponds to independent, unbiased neurons. The same algebra generalizes: for independent neurons with heterogeneous activation probabilities $p_i$, the mean becomes $\sum_i p_i$ and the variance $\sum_i p_i(1-p_i)$, and an analogous pairwise-count argument yields the second moment. The compact identities of this paper are the symmetric special case $p_i = \tfrac12$, which maximizes both the entropy of the code and the per-neuron variance $p(1-p) = \tfrac14$. Thus the half-active regime studied here is simultaneously the most expressive and the most metabolically variable per neuron, yet, remarkably, still concentrates sharply in relative terms.

## 10. Future Directions

**10.1 Sub-Gaussian (exponential) energy concentration.** *Conjecture.* The fraction of codes whose weight deviates from $N/2$ by at least $t$ decays like $\exp(-2t^2/N)$, not merely $N/(4t^2)$; consequently, for any fixed $\varepsilon > 0$, all but an exponentially small fraction of codes have weight in $[(\tfrac12 - \varepsilon)N,\ (\tfrac12 + \varepsilon)N]$. The coordinates of a binary code are independent bounded contributions, so the weight is a genuine sum of independent $\pm$ increments and the exponential moment — not the second moment — is the sharp instrument. The exact second moment established here is the first term of the cumulant expansion; controlling the whole cumulant sequence would upgrade the polynomial tail to an exponential one.

**10.2 Energy–distance trade-off for noise-tolerant codebooks.** *Conjecture.* Any codebook with minimum Hamming distance $d$ whose codewords all have weight near $N/2$ (within $o(\sqrt N)$) satisfies a strictly stronger size bound than the generic Singleton ceiling $2^{N+1-d}$; concentrating the energy budget forces the codewords into a thin equatorial shell whose limited volume caps the codebook. With both a Singleton-type ceiling and the exact weight concentration in hand, the two constraints can be imposed simultaneously to turn a qualitative tension into a quantitative shell-volume bound.

**10.3 Concentration of the population-coding error.** *Conjecture.* When $N$ neurons independently estimate a stimulus, not only does the mean squared error scale like $1/N$, but the *realized* error concentrates around its mean: the probability that the population estimate is off by more than $c/\sqrt N$ decays polynomially in $N$ for every constant $c$, so the $1/\sqrt N$ precision law holds pattern-by-pattern, not only on average.

## 11. Conclusion

We have upgraded the neural-coding chain from first-moment facts to a full concentration statement. The metabolic weight of a dense code is a Binomial$(N,\tfrac12)$ in disguise: its mean is $N/2$, its variance is exactly $N/4$, and at least three quarters of all $2^N$ codes lie within $\sqrt N$ of the mean. All identities are exact for every $N \ge 0$, with no boundary defects. Dense neural coding therefore obeys a metabolic law of large numbers, spending $N/2$ spikes on average with a relative fluctuation vanishing at rate $1/\sqrt N$.
