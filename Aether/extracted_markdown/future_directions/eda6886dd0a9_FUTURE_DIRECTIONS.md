# Future Directions: Extremal KW Witness Geometry

This document identifies five specific, testable scientific hypotheses arising from the formal verification of the threshold classification theorem and witness count factorization for monotone symmetric Boolean functions.

---

## Hypothesis 1: Global Threshold Extremality Beyond Symmetry

**Conjecture:** Among all monotone Boolean functions on $n$ variables with fixed measure $\mu = |\{x : f(x) = 1\}| / 2^n$, the threshold/lex-type monotone sets maximize the KW witness count up to lower-order terms. Specifically, if $T_\mu$ denotes the threshold function with measure closest to $\mu$, then for any monotone $f$ with measure $\mu$:

$$|KW(f)| \leq |KW(T_\mu)| \cdot (1 + o(1))$$

**Test:** Enumerate all monotone Boolean functions for $n \leq 6$ (feasible since there are approximately $10^8$ monotone functions on 6 variables). For each fixed measure $\mu$, compute the KW witness count and compare against the threshold/lex extremizer.

**Refutation criterion:** A monotone function with the same measure as a threshold function but strictly larger witness count by more than a constant factor. Even a single counterexample at moderate $n$ would refute the conjecture.

**Impact:** If true, this would generalize our classification theorem from the symmetric world to all monotone functions, establishing that thresholds are universal witness-maximizers. This would create a new bridge between KW theory and the Kruskal-Katona / Harper isoperimetric theorems.

---

## Hypothesis 2: Sharp Majority Witness Asymptotics with Correction Terms

**Conjecture:** For the majority function on odd $n = 2m+1$ variables:

$|KW(\text{Maj}_n)| = \frac{n \cdot 4^n}{16} \cdot \left(1 + \frac{2}{\sqrt{\pi m}} + \frac{1}{\pi m} + O(m^{-3/2})\right)$

where the correction comes from $(1 + \binom{2m}{m}/4^m)^2$ with $\binom{2m}{m}/4^m \sim 1/\sqrt{\pi m}$.

More generally, for $t = \lfloor \alpha n \rfloor$ with $\alpha \in (0,1)$:
$|KW(\text{Thresh}(n, t))| \sim n \cdot \left(\sum_{j \geq t-1} \binom{n-1}{j}\right) \cdot \left(\sum_{l < t} \binom{n-1}{l}\right)$
and the dominant term depends on whether $\alpha = 1/2$ (balanced) or $\alpha \neq 1/2$ (unbalanced).

**Test:** 
1. Compute $16 W(\text{Maj}_n) / (n \cdot 4^n)$ for $n$ up to 1000 and verify convergence to 1.
2. Compute the next correction term and verify it matches $2/\sqrt{\pi m}$.
3. For off-center $\alpha$, determine whether the growth is $\Theta(n \cdot 4^n)$ or exponentially smaller.

**Refutation criterion:** If the second-order correction differs from $2/\sqrt{\pi m}$, or if the off-center scaling behaves qualitatively differently than predicted.

**Impact:** This would give a complete asymptotic expansion of the majority witness count, connecting the correction terms to central limit theorem phenomena. The leading term $n \cdot 4^n / 16$ shows witnesses are abundant — roughly $n/16$ of all input-pair-coordinate triples are valid witnesses for majority.

---

## Hypothesis 3: KW/W₁ Ratio Growth Rate

**Conjecture:** For fixed $\alpha \in (0,1)$ and $t = \lfloor \alpha n \rfloor$, the ratio

$\frac{KW(n, t)}{W_1(n, t)}$

grows like $\Theta(\sqrt{n})$ as $n \to \infty$, where

$W_1(n,t) = \sum_{k \geq t, l < t} \binom{n}{k}\binom{n}{l}|k - l|$

Computational evidence at $\alpha = 0.5$ shows the ratio grows slowly (approximately as $\sqrt{n}$) rather than converging. This suggests that KW witnesses and W₁ transport cost measure related but distinct quantities: KW uses the kernel $\binom{n-1}{k-1}\binom{n-1}{l}$ while W₁ uses $\binom{n}{k}\binom{n}{l}|k-l|$, and the extra $|k-l|$ factor in W₁ provides more weight to distant layer pairs.

A **renormalized** ratio $KW(n,t) / (\sqrt{n} \cdot W_1(n,t))$ may converge instead. Alternatively, a modified transport cost using the KW kernel $\binom{n-1}{k-1}\binom{n-1}{l}$ instead of $\binom{n}{k}\binom{n}{l}|k-l|$ would give exact agreement.

**Test:**
1. Compute KW/W₁ at $\alpha = 0.5$ for $n = 3, 5, \ldots, 199$ and fit the growth rate.
2. Test whether KW/(√n · W₁) converges.
3. Compare kernel ratios $n \cdot \binom{n-1}{k-1}\binom{n-1}{l} / (\binom{n}{k}\binom{n}{l}|k-l|)$ pointwise.

**Refutation criterion:** If the growth rate is not $\Theta(\sqrt{n})$ (e.g., logarithmic or linear), or if the renormalized ratio fails to converge.

**Impact:** Understanding the precise relationship between KW counting and transport theory would clarify which features of the witness kernel are responsible for the communication complexity of threshold functions.

---

## Hypothesis 4: Majority Uniquely Maximizes Witness Count Among Thresholds

**Conjecture:** Among all threshold functions $\text{Thresh}(n, t)$ with $1 \leq t \leq n$, the majority threshold $t = \lceil n/2 \rceil$ uniquely maximizes the KW witness count:

$$W(n, \lceil n/2 \rceil) > W(n, t) \quad \text{for all } t \neq \lceil n/2 \rceil, 1 \leq t \leq n$$

Moreover, $W(n, t)$ is strictly unimodal as a function of $t$ on $\{1, \ldots, n\}$.

**Test:**
1. Compute $W(n, t)$ for all valid $t$ at each $n$ from 2 to 100.
2. Verify that the maximum is always at $t = \lceil n/2 \rceil$ (or $\lfloor n/2 \rfloor + 1$).
3. Verify strict unimodality: $W(n, t-1) < W(n, t)$ for $t \leq \lceil n/2 \rceil$ and $W(n, t) > W(n, t+1)$ for $t \geq \lceil n/2 \rceil$.

**Refutation criterion:** A value of $n$ where a non-central threshold beats majority, or where the sequence fails to be unimodal.

**Impact:** This would establish majority as the canonical extremizer within the one-parameter threshold family, complementing the classification theorem. Combined with Hypothesis 1, it would say majority is the most witness-rich monotone symmetric function of any type.

---

## Hypothesis 5: Witness Counting Has a Noise-Stability Shadow

**Conjecture:** For monotone symmetric functions, the following monotone relationship holds: among threshold functions on $n$ variables, the ordering by KW witness count is the same as the ordering by total influence. That is, for thresholds $s$ and $t$:

$$W(n, s) \leq W(n, t) \iff I(\text{Thresh}(n, s)) \leq I(\text{Thresh}(n, t))$$

where $I(f) = \sum_i \text{Inf}_i(f)$ is the total influence.

The total influence of $\text{Thresh}(n, t)$ is $n \cdot \binom{n-1}{t-1} / 2^{n-1}$, maximized at the center. If both witness count and influence are maximized at majority and are unimodal, they would have the same ordering.

**Test:**
1. For each $n$ from 2 to 50, compute both $W(n, t)$ and $I(n, t) = n \cdot \binom{n-1}{t-1}/2^{n-1}$ for all $t$.
2. Check that the permutations induced by sorting by $W$ and by $I$ are identical.
3. Check that both are unimodal with the same peak.

**Refutation criterion:** A pair $(n, s, t)$ where $W(n,s) < W(n,t)$ but $I(n,s) > I(n,t)$, or vice versa.

**Impact:** If true, this would create a formal bridge between KW witness counting and the analysis of Boolean functions (influence, noise stability). It would suggest that witness complexity is governed by the same concentration-of-measure phenomena that control noise sensitivity, opening paths to Fourier-analytic techniques in communication complexity.

---

## Summary of Research Program

These five hypotheses form a coherent program:

| Hypothesis | Domain | Status | Difficulty |
|:---:|:---|:---|:---|
| H1 | Extremal combinatorics | Open | Hard (requires non-symmetric theory) |
| H2 | Asymptotic analysis | Computationally supported | Medium (Stirling + CLT) |
| H3 | Optimal transport | Computationally supported | Medium-Hard |
| H4 | Extremal analysis | Computationally supported | Medium (elementary) |
| H5 | Boolean function analysis | Computationally testable | Medium |

The recommended attack order is H4 → H2 → H5 → H3 → H1, moving from concrete to general, with each result building on the previous one.
