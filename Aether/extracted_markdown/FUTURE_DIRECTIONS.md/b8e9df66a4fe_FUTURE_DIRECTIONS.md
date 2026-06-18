# Future Directions: Exceptional Set Finiteness

## Conjecture 1: The Benford Criterion (Local-to-Global Principle)

**Conjecture.** For the quadratic map $T_c(x) = x^2 + c$, if the orbit of $T_c$ starting at any seed is non-degenerate modulo every prime $p$ (i.e., the orbit mod $p$ visits all residues with sufficient complexity), then the leading-digit distribution of the orbit converges to Benford's law.

**Test.** For parameters $c \in [-10^4, 10^4]$ with escaping orbits, compute modular complexity (number of distinct residues visited mod $p$ for primes $p \leq 100$) and KL divergence from Benford (using orbits of length $N = 50$ in logarithmic coordinates). Plot modular complexity against KL divergence. The conjecture predicts a monotone relationship: high modular complexity implies low KL divergence.

**Refutation criterion.** Exhibit a parameter $c$ with maximal modular complexity at all tested primes (orbit visits all residue classes) but persistent KL divergence $> 0.05$ from Benford's law at all tested orbit depths.

**Impact.** If true, this would complete the finiteness pipeline: Theorems 3 and 4 in our framework would immediately yield that the exceptional set is finite (assuming finitely many obstruction primes). This is the single most important open ingredient.

## Conjecture 2: Empty Exceptional Set

**Conjecture.** $E = \varnothing$: every integer parameter $c$ for which the orbit of $T_c$ escapes to infinity produces Benford-distributed leading digits.

**Test.** Run the certified obstruction search to radius $C = 10^6$, primes $P \leq 10^4$, iterate depth $N = 100$ (using modular arithmetic to avoid overflow). For every escaping parameter, compute KL divergence from Benford using logarithmic orbit tracking. The conjecture predicts all escaping orbits have KL divergence converging to 0.

**Refutation criterion.** Find a parameter $c$ with escaping orbit and rigorously certifiable KL divergence bounded away from 0 (e.g., $D_{KL} > 0.01$ for all $N \leq 10^4$). This would require showing that the log-mantissa distribution fails to equidistribute, possibly via a semiconjugacy to a monomial map.

**Impact.** If $E = \varnothing$, Benford universality for quadratic dynamics would be unconditional — a clean, striking theorem. If $E \neq \varnothing$, the specific exceptional parameters would become objects of intense study as "integrable" points in the quadratic family.

## Conjecture 3: Prime Support Rigidity

**Conjecture.** There exists a finite set of primes $S$ (possibly $S = \{2, 3\}$) such that every exceptional parameter, if any exists, has a local obstruction at some $p \in S$. In other words, obstruction witnesses are concentrated at the smallest primes.

**Test.** For parameters $c \in [-10^5, 10^5]$, record the smallest witness prime for each parameter's modular degeneracy. Track whether witness primes remain bounded as the search radius grows. Specifically, compute $P_{\max}(C) = \max\{\text{smallest witness prime for } c \in [-C, C]\}$ for $C = 10, 10^2, 10^3, 10^4, 10^5$.

**Refutation criterion.** $P_{\max}(C) \to \infty$ as $C \to \infty$: there exist parameters requiring arbitrarily large witness primes. This would mean the obstruction support is infinite, requiring a different finiteness mechanism.

**Impact.** If true, the finiteness conjecture reduces to checking finitely many primes at each parameter — a dramatically simpler problem. The finite set $S$ would be a canonical invariant of the quadratic family.

## Conjecture 4: Density-Zero Anomaly Law

**Conjecture.** Among escaping parameters, the number of candidate exceptional parameters in $[-X, X]$ is $O(\log X)$, and possibly bounded by an absolute constant.

**Test.** For increasing $X$ values ($10, 10^2, \ldots, 10^6$), count the number of escaping parameters whose KL divergence from Benford exceeds $0.05$ at iterate depth $N = 50$. Fit the count against models: constant, $\log X$, $X^{\alpha}$, and $X$.

**Refutation criterion.** Count grows as $X^{\alpha}$ for $\alpha > 0$, i.e., a positive fraction of escaping parameters are persistently non-Benford. This would invalidate the finiteness conjecture entirely.

**Impact.** Sub-logarithmic growth would strongly support finiteness and suggest that exceptional parameters, if they exist, are extremely sparse — analogous to Siegel zeros in analytic number theory.

## Conjecture 5: Higher-Degree Universality

**Conjecture.** The entire obstruction-theoretic framework generalizes to the degree-$d$ polynomial family $T_{c,d}(x) = x^d + c$ for $d \geq 3$: eventually periodic orbits are non-Benford, local obstructions control exceptions, and finite obstruction support implies finite exceptional sets.

**Test.** Implement the certified search for $d = 3, 4, 5$ with $C = 10^3$, $P \leq 100$, $N = 30$. Compare the structure of obstruction witnesses across degrees. The conjecture predicts that the framework transfers with the same theorems (replacing the quadratic step with $x^d + c$), though the specific obstruction patterns may differ.

**Refutation criterion.** For some $d \geq 3$, exhibit a qualitatively different failure mode: a parameter $c$ that is non-Benford but has no modular obstruction at any prime $p \leq 10^4$. This would indicate that the local-to-global principle breaks down for higher degrees.

**Impact.** A positive result would establish the obstruction framework as a general theory of digital universality in polynomial dynamics, opening a systematic study of digit laws across all polynomial families. This would be a major contribution to arithmetic dynamics.
