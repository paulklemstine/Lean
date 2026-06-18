# Future Directions: Version Space Entropy Theory

## Conjecture 1: Tightness for Threshold Concepts

**Conjecture.** For threshold functions on a linearly ordered finite domain of size $n$ with binary labels, there exist query sequences achieving entropy drop exactly 1 bit per sample until the version space becomes a singleton. More precisely, for any $n$, binary search achieves $\lceil \log_2(n+1) \rceil$ queries with average per-query entropy drop converging to 1 bit as $n \to \infty$.

**Test.** Enumerate thresholds on $\{0, \ldots, n-1\}$ for $n = 2^k - 1$. Use the binary search (median) query strategy. Verify that each query reduces $\log_2 |V|$ by exactly 1 bit when $|V|$ is even (the median splits the version space exactly in half). Compute the deviation from 1 bit/query for non-power-of-two domain sizes.

**Impact.** If true, this establishes threshold functions as the canonical tight example for the entropy bound: binary labels + binary search = perfect information extraction. This would make threshold functions the "matched filter" of version-space learning, analogous to Gaussian channels achieving Shannon capacity.

## Conjecture 2: Sub-Capacity Compression for Decision Lists

**Conjecture.** For decision lists over $n$ Boolean variables with binary labels, the average semantic compression rate under uniformly random examples is strictly less than 1 bit per sample, and the gap from capacity grows as $\Omega(1/n)$.

**Test.** Enumerate all decision lists for $n \in \{2, 3, 4, 5\}$. For each target decision list, sample random instances uniformly, compute version-space entropy after each observation, and measure the average compression rate. Plot the average rate versus $n$ and fit the sub-linearity.

**Impact.** If true, this proves a structural complexity hierarchy among concept classes based on compression efficiency: threshold functions are maximally compressible, while decision lists waste channel capacity due to their more complex partition structure. This would give a new characterization of concept class complexity beyond VC dimension.

## Conjecture 3: Thermodynamic Phase Transition in Learning

**Conjecture.** For conjunction functions over $n$ Boolean variables, the curve $m \mapsto \log_2 |V_m|$ (version-space entropy vs. number of random labeled examples) exhibits a sharp second-derivative discontinuity at a critical sample size $m^* \approx n$, analogous to a thermodynamic phase transition. Below $m^*$, the entropy decreases slowly (liquid phase); above $m^*$, most hypotheses are eliminated rapidly (crystallization).

**Test.** For $n \in \{3, 4, 5, 6\}$, generate 1000 random sample streams from a random target conjunction. Compute the average entropy trajectory and its numerical second derivative. Look for a peak in $|d^2 \log_2|V_m| / dm^2|$ and test whether the peak location scales linearly with $n$.

**Impact.** If confirmed, this would establish a rigorous connection between learning theory and statistical physics: the version space undergoes a phase transition from "under-determined" to "over-determined" at a critical sample size. This could import the powerful machinery of phase transitions (critical exponents, universality classes) into learning theory.

## Conjecture 4: Counterexample to the $\log_2|X|$ Bound

**Conjecture.** For any $\varepsilon > 0$ and sufficiently large multiclass concept classes with $|Y| > |X|$, there exist version spaces and observations where the per-sample entropy drop exceeds $\log_2 |X|$ by a factor of $\log_2 |Y| / \log_2 |X| - \varepsilon$. That is, the worst-case per-sample entropy drop is essentially $\log_2 |Y|$, not $\log_2 |X|$, and the original $\log_2 |X|$ conjecture fails maximally when labels carry more information than instances.

**Test.** For $|X| = 2, |Y| = k$ with $k \in \{3, 4, \ldots, 16\}$, construct the full function class $Y^X$. Find version spaces $V$ and observations $(x, y)$ that maximize the entropy drop. Verify that the maximum approaches $\log_2 |Y|$ as $k$ grows, far exceeding $\log_2 |X| = 1$.

**Impact.** This settles the question of whether the correct per-sample information bound depends on the instance space or the label space. The answer ($\log_2 |Y|$) has immediate consequences for multiclass learning theory: the sample complexity lower bound depends on label complexity, not instance complexity. This corrects a common misconception in the learning theory literature.

## Conjecture 5: Pattern Complexity Gap for Structured Classes

**Conjecture.** For size-$s$ DNF formulas over $n$ Boolean variables, the number of distinct $k$-sample label patterns on any structured query set (e.g., a Hamming ball of radius $r$) is at most $O(s^k \cdot \text{poly}(n))$, which is exponentially smaller than the universal bound $2^k$ for $s \ll 2^n / k$.

**Test.** For $n = 5, s \in \{1, 2, 3\}$, enumerate all size-$s$ DNF formulas. For each $k \in \{1, \ldots, 8\}$, compute the number of distinct patterns on: (a) all possible $k$-subsets of the domain, (b) $k$-subsets within Hamming balls of radius 2 around a fixed point. Compare the pattern counts to $2^k$ and to $s^k$.

**Impact.** If true, this shows that structured concept classes exhibit pattern compression far beyond the universal $|Y|^k$ bound. This would yield tighter sample complexity lower bounds for specific learning problems and connect version-space entropy to circuit complexity.
