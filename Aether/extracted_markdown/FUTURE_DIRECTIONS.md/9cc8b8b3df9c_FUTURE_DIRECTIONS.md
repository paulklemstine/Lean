# Future Directions: Obstruction Calculus for Random Group Generation

## Overview

The theorems proved here — certified upper bounds on reciprocal binomial coefficient sums and the obstruction decomposition framework — establish the foundation for a formal probabilistic theory of random generation in finite groups. The following hypotheses identify precise next steps, each falsifiable and each opening new territory.

---

## Hypothesis 1: Constant Sharpening for the Intransitive Bound

**Conjecture:** For all `n ≥ 8`, the tail sum satisfies
$$\sum_{k=2}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}} \leq \frac{9}{2n^2}.$$

More ambitiously, the optimal constant is `C_opt = 152/35 ≈ 4.343` (achieved at `n = 8`), and for all `n ≥ 10`:
$$\sum_{k=2}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}} \leq \frac{4}{n^2}.$$

**Test:** Compute `n² · ∑_{k=2}^{⌊n/2⌋} 1/C(n,k)` for `6 ≤ n ≤ 1000` to verify the constant. For the asymptotic version, compute to `n = 10000` and check monotone decrease toward `2`.

**Refutation criterion:** Find `n ≥ 10` where `n² · tail > 4`. Computational evidence strongly suggests this cannot happen (the supremum over `n ≥ 10` is approximately `3.93` at `n = 10`).

**Impact:** This would provide the tightest possible elementary bound with a single universal constant, reducing the gap between the proved constant `5` and the asymptotic constant `2`. It would make the certified generation probability bound quantitatively competitive with the best known asymptotic results.

---

## Hypothesis 2: Imprimitive Obstruction is O(1/n²) with Explicit Constant

**Conjecture:** For all `n ≥ 6`, the probability that two random permutations in `S_n` generate a transitive imprimitive subgroup is at most `C_imp / n²`, where `C_imp ≤ 10`.

More precisely, the imprimitive contribution decomposes over divisors of `n`:
$$P_{\text{imprim}}(n) \leq \sum_{\substack{d \mid n \\ 1 < d < n}} \frac{1}{[S_n : S_d \wr S_{n/d}]},$$
and this sum is bounded by `C_imp / n²`.

**Test:** For each `n` up to 100, compute the sum of `1/[S_n : H]` over all transitive imprimitive maximal subgroups `H` (wreath products `S_d ≀ S_{n/d}` for proper divisors `d` of `n`). The index `[S_n : S_d ≀ S_{n/d}] = n! / ((d!)^{n/d} · (n/d)!)`. Verify that the sum is at most `10/n²`.

**Refutation criterion:** Find `n` where the imprimitive index sum exceeds `10/n²`. Highly composite numbers `n` are the most dangerous cases since they have the most divisors.

**Impact:** Combined with the proved intransitive bound, this would give a fully explicit generation probability:
$$P(\langle \sigma, \tau \rangle \supseteq A_n) \geq 1 - \frac{1}{n} - \frac{15}{n^2} - \varepsilon_n$$
with `ε_n` exponentially small. This would be the first machine-verifiable version of Dixon's theorem with explicit constants.

---

## Hypothesis 3: Multi-Generator Phase Transition at Order n^{-(r-1)}

**Conjecture:** For fixed `r ≥ 2` and all `n ≥ 2r`, the probability that `r` independent uniform permutations in `S_n` have a common fixed point satisfies:
$$\frac{1}{n^{r-1}} - \frac{r}{n^r} \leq P(\text{common fixed point}) \leq \frac{1}{n^{r-1}} + \frac{r}{n^r}.$$

Equivalently, `n^{r-1} · P(common fixed point) → 1` as `n → ∞`, with the convergence rate being `O(1/n)`.

**Test:** Compute the exact inclusion-exclusion formula
$$P = \sum_{j=1}^{n} (-1)^{j+1} \binom{n}{j} \left(\frac{(n-j)!}{n!}\right)^r$$
for `r = 2, 3, 4, 5` and `n = 5, 10, 20, 50, 100`, and verify the sandwiching.

**Refutation criterion:** Find `n ≥ 2r` where `|n^{r-1} · P - 1| > r/n`.

**Impact:** This would establish a formal multi-generator random generation theory with exact leading terms for each generator count. It would precisely quantify the diminishing returns of adding generators, enabling optimal algorithm design for certified random group generation.

---

## Hypothesis 4: Alternating Group Parity Correction

**Conjecture:** The probability that two random permutations generate exactly `A_n` (not `S_n`) satisfies:
$$P(\langle \sigma, \tau \rangle = A_n) = \frac{1}{4} + O(1/n),$$
while
$$P(\langle \sigma, \tau \rangle = S_n) = \frac{3}{4} - \frac{3}{4n} + O(1/n^2).$$

The correction `3/(4n)` comes from the probability that both permutations are even: `P(\sigma, \tau \in A_n) = 1/4`, and conditioned on having the same parity, generation of `A_n` vs. a proper subgroup follows the same obstruction spectrum.

**Test:** For `n = 5, 6, ..., 12`, enumerate all pairs `(σ, τ) ∈ S_n × S_n` and count those generating `S_n` vs. `A_n` vs. proper subgroups. Compare empirical probabilities with the predicted formulas.

**Refutation criterion:** Empirical `P(⟨σ,τ⟩ = S_n)` deviates from `3/4 - 3/(4n)` by more than `C/n²` for a constant `C`. The constant in the `O(1/n²)` term should be determinable.

**Impact:** This would extend the obstruction calculus to distinguish between `S_n` and `A_n` generation, providing parity-aware certified bounds. It connects to the deep fact that sign is the only abelianization of `S_n`, making the parity obstruction the unique linear character obstruction.

---

## Hypothesis 5: Transfer to Finite Classical Groups via Parabolic Subgroups

**Conjecture:** The obstruction calculus architecture transfers from `S_n` to `GL(n, q)` by replacing subset stabilizers with parabolic subgroups. Specifically, the probability that two random elements of `GL(n, q)` generate a subgroup not containing `SL(n, q)` is bounded by:
$$P_{\text{fail}} \leq \sum_{k=1}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}_q} + O(q^{-n}),$$
where `C(n,k)_q` is the Gaussian binomial coefficient.

For the dominant term:
$$\sum_{k=1}^{\lfloor n/2 \rfloor} \frac{1}{\binom{n}{k}_q} \leq \frac{1}{q^{n-1} - 1} + \frac{C}{q^{2(n-2)}}$$
for an explicit constant `C`.

**Test:** Compute exact generation probabilities in `GL(n, q)` for small cases (`n = 2, 3, 4` and `q = 2, 3, 4, 5`) using the known maximal subgroup structure. Compare with the Gaussian binomial sum bound.

**Refutation criterion:** The Gaussian binomial sum bound fails to capture the correct leading term for `GL(n, q)` generation. This would indicate that the parabolic decomposition is not the right analogue of the subset stabilizer decomposition.

**Impact:** This would open a formal obstruction calculus for the infinite families of finite classical groups, connecting to the Kantor–Lubotzky theorem and providing certified random generation bounds for matrix groups. The practical applications to computational algebra (random element generation in Magma/GAP) would be immediate.

---

## Summary of Priorities

| Priority | Hypothesis | Difficulty | Payoff |
|----------|-----------|------------|--------|
| 1 | Constant sharpening (H1) | Low | Medium — improves existing bound |
| 2 | Imprimitive obstruction (H2) | Medium | High — completes Dixon's theorem |
| 3 | Multi-generator (H3) | Medium | High — new theory |
| 4 | Parity correction (H4) | Medium | Medium — refines existing theory |
| 5 | Classical groups (H5) | High | Very high — new paradigm |

The recommended order of attack is H1 → H3 → H2 → H4 → H5, balancing tractability with impact.
