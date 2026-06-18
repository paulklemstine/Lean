# Future Directions: Certified Generation Probability and Dixon's Theorem

## Hypothesis A: Tight Intransitive Obstruction Bound

**Conjecture:** For all $n \geq 6$,
$$\sum_{k=1}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}} \leq \frac{1}{n} + \frac{3}{n^2}.$$

**Test:** Verify numerically for $6 \leq n \leq 200$ using exact rational arithmetic. Then formalize the analytic proof by bounding $\sum_{k=2}^{\lfloor n/2\rfloor} 1/\binom{n}{k}$ using the geometric-series domination of binomial coefficients: for $2 \leq k \leq n/2$, successive ratios satisfy $\binom{n}{k+1}/\binom{n}{k} = (n-k)/(k+1) \geq 2$ when $k \leq (n-1)/3$, giving exponential decay.

**Impact:** This would provide the tightest elementary upper bound on the intransitive obstruction and immediately imply that the failure probability for $S_n$-generation is $1/n + O(1/n^2)$, making the Dixon bound explicit with concrete constants. The proof infrastructure would also cover $A_n$ after a parity adjustment.

**Refutation criterion:** Find $n \geq 6$ where the sum exceeds $1/n + 3/n^2$, or prove a lower bound showing the constant 3 is insufficient.

---

## Hypothesis B: Transitive Non-Alternating Obstruction is $O(1/n^2)$

**Conjecture:** The probability that two random permutations in $S_n$ generate a transitive subgroup that is neither $A_n$ nor $S_n$ is $O(1/n^2)$ for $n \geq 5$.

More precisely, the non-generation probability decomposes as:
$$P(\text{fail}) = P(\text{intransitive}) + P(\text{transitive, imprimitive}) + P(\text{primitive, not } A_n \text{ or } S_n).$$

The transitive contributions should be:
- Imprimitive: $O(1/n^2)$ from wreath product subgroups
- Primitive, not $A_n/S_n$: exponentially small by the O'Nan-Scott theorem

**Test:** For $n = 5, 6, 7$ (where exhaustive computation is feasible), compute the exact contribution of each obstruction class. Verify that the transitive-but-not-$A_n/S_n$ contribution is at most $C/n^2$ for some explicit constant $C$.

**Impact:** This would isolate the three structural sources of non-generation and show that only point stabilizers and the alternating group matter asymptotically. Combined with Hypothesis A, it would yield a complete formal Dixon-style bound.

**Refutation criterion:** Find a family of transitive maximal subgroups contributing $\Omega(1/n)$ to the failure probability.

---

## Hypothesis C: Multi-Generator Point-Stabilizer Formula

**Conjecture:** For fixed $r \geq 2$, the probability that $r$ random permutations in $S_n$ all fix a common point is exactly
$$\frac{1}{n} \cdot \left(\frac{(n-1)!}{n!}\right)^{r-1} \cdot (\text{inclusion-exclusion correction}) = \sum_{j=1}^{n} (-1)^{j+1} \binom{n}{j} \left(\frac{(n-j)!}{n!}\right)^r.$$

For $r = 2$: this equals $\frac{1}{n} \cdot \left(1 - \frac{1}{(n-1)^2} + \cdots\right) \approx \frac{1}{n}$.

For $r = 3$: the failure probability from point stabilizers drops to $O(1/n^2)$.

**Test:** Formalize the exact inclusion-exclusion formula for $r$-tuples sharing a fixed point. Verify computationally for $n \leq 10$ and $r = 2, 3, 4$. Then prove the asymptotic $1/n^{r-1}$ scaling.

**Impact:** Establishes the multi-generator generalization of Dixon's theorem: $r$ random permutations generate $S_n$ with probability $1 - O(1/n^{r-1})$. For $r = 3$, this gives probability $\geq 1 - O(1/n^2)$, which is much stronger than the 2-generator case.

**Refutation criterion:** Find that the inclusion-exclusion does not simplify to $O(1/n^{r-1})$, or that imprimitive obstructions dominate for some $r$.

---

## Hypothesis D: Computational Reach to $S_7$

**Conjecture:** Exact generation probabilities for $S_n$ with $n \leq 7$ can be certified using optimized finite computation inside a proof assistant, using the `native_decide` approach demonstrated for $S_4$ and $S_5$.

Known values:
| $n$ | $\|S_n\|$ | $\|S_n \times S_n\|$ | Generating pairs | Probability |
|-----|-----------|---------------------|------------------|-------------|
| 2   | 2         | 4                   | 3                | 3/4         |
| 3   | 6         | 36                  | 18               | 1/2         |
| 4   | 24        | 576                 | 216              | 3/8         |
| 5   | 120       | 14,400              | 6,840            | 19/40       |
| 6   | 720       | 518,400             | ?                | ?           |
| 7   | 5,040     | 25,401,600          | ?                | ?           |

**Test:** Benchmark the current BFS-based `genFullBool` approach for $n = 6$ (518,400 pairs). If too slow, implement:
1. Orbit-based early rejection (if $\langle \sigma, \tau \rangle$ acts intransitively, reject immediately)
2. Schreier-Sims based subgroup order computation
3. Conjugacy-class pruning (count per conjugacy class pair, multiply by class sizes)

**Impact:** Extending the computational frontier validates the obstruction theory numerically and provides regression tests for abstract bounds. The $n = 6$ case involves the exceptional transitive subgroup $\text{PGL}(2,5) \cong S_5$ acting on cosets, making it a test of whether "exceptional" obstructions matter.

**Refutation criterion:** If $n = 6$ requires more than 1 hour of `native_decide` computation, the approach needs algorithmic improvement rather than raw computation.

---

## Hypothesis E: Alternating Group Generation with Parity Correction

**Conjecture:** The subgroup-obstruction formalism extends to $A_n$ with the following modification: for two random *even* permutations, the probability of generating $A_n$ satisfies
$$P(\langle \sigma, \tau \rangle = A_n) = 1 - \frac{1}{n} - O(1/n^2) \quad \text{as } n \to \infty.$$

The leading obstruction is again point stabilizers: the stabilizer of a point in $A_n$ is $A_{n-1}$, contributing $n \cdot ((n-1)!/2)/(n!/2))^2 = 1/n$ to the failure probability.

**Test:**
1. Define `countGenPairs_Alt n` analogous to our symmetric group version, counting pairs of even permutations generating $A_n$.
2. Compute for $n = 4, 5$ and verify:
   - $A_4$: $|A_4| = 12$, $|A_4 \times A_4| = 144$
   - $A_5$: $|A_5| = 60$, $|A_5 \times A_5| = 3600$
3. Prove the point-stabilizer contribution formula for $A_n$.

**Impact:** Extends the entire framework to alternating groups, which are the other main family in the classification of finite simple groups. Since every finite simple group is generated by 2 elements (by Steinberg's theorem), the generation probability question is universal for simple groups.

**Refutation criterion:** If the $O(1/n^2)$ error term is actually $O(1/n)$ due to additional obstructions specific to $A_n$ (e.g., from imprimitive subgroups of $A_n$ that are not restrictions of imprimitive subgroups of $S_n$).
