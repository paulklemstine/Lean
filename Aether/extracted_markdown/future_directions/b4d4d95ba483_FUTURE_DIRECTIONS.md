# Future Directions: Formal Additive Prime Decomposition Theory

This document identifies five falsifiable scientific hypotheses arising from
our formalization of Goldbach-type additive prime decompositions.  Each
conjecture is precise enough to confirm or refute computationally or
proof-theoretically.

---

## Hypothesis 1: Goldbach Count Lower Bound

**Conjecture.** For every even integer $n \geq 8$, the ordered Goldbach
representation count satisfies $r_2(n) \geq 2$.

**Why it matters.** If true, this implies that Goldbach decompositions are
never "barely" achievable for $n \geq 8$—there is always structural
redundancy.  This separates $n = 4$ (which has $r_2(4) = 1$, only $2+2$)
and $n = 6$ ($r_2(6) = 1$, only $3+3$) from the rest.

**How to test.** Compute `goldbachCount n` for all even $n$ in $[8, B]$ for
increasing bounds $B$.  Our infrastructure already supports this via
`goldbachWitnesses`.  Extend native_decide verification to $B = 10\,000$ or
beyond.

**Falsifier.** An even $n \geq 8$ with `goldbachCount n < 2`.

---

## Hypothesis 2: Weak Chen Prevalence

**Conjecture.** Every even integer $n \geq 4$ admits a weak Chen
decomposition: $n = p + s$ where $p$ is prime and $s$ is either prime or
semiprime.

**Why it matters.** Chen's theorem (1966) establishes this for all
sufficiently large even numbers; this hypothesis extends it to *all* even
$n \geq 4$.  A formal proof would close the gap between Chen's asymptotic
result and a universal statement.

**How to test.** Extend the `HasWeakChenDecomposition` decidability
infrastructure (analogous to our `HasGoldbachDecomposition` decidability
instance) and verify computationally up to a large bound.

**Falsifier.** An explicit even $n \geq 4$ with no prime + (prime-or-semiprime)
decomposition.

---

## Hypothesis 3: Parity Regularity of Witnesses

**Conjecture.** For every even $n > 4$ and every Goldbach pair $(p, q)$ with
$p + q = n$, both $p$ and $q$ are odd.

**Why it matters.** We have *proved* this as
`goldbach_pair_even_gt_four_both_odd`.  The hypothesis is already a theorem.
The future direction is to extend this parity analysis to ternary
decompositions: for odd $n > 5$, classify which triples $(a, b, c)$ of
primes summing to $n$ can include the prime $2$, and prove that at most one
of $a, b, c$ can be $2$.

**How to test.** Formalize and prove a ternary parity-forcing theorem
analogous to the binary one.

**Falsifier.** A ternary decomposition of an odd $n > 7$ where two of the
three primes are $2$—this should be impossible since $2 + 2 = 4$ is even,
contradicting the odd residual.

---

## Hypothesis 4: Convolution Growth Heuristic

**Conjecture.** The average Goldbach count over even integers up to $B$,
$$\bar{r}_2(B) = \frac{1}{B/2} \sum_{\substack{n \leq B \\ n \text{ even}}} r_2(n),$$
grows at least as fast as $C \cdot B / (\log B)^2$ for some constant $C > 0$.

**Why it matters.** The Hardy–Littlewood conjecture predicts
$r_2(n) \sim 2 C_2 \cdot n / (\log n)^2 \cdot \prod_{p | n, p > 2} (p-1)/(p-2)$
where $C_2$ is the twin-prime constant.  The averaged version should be
more tractable and formalizable.

**How to test.** Compute $\bar{r}_2(B)$ at dyadic scales
$B = 10^3, 10^4, 10^5, \ldots$ and fit the growth exponent.

**Falsifier.** Sub-threshold growth: $\bar{r}_2(B) = o(B / (\log B)^2)$
across tested scales.

---

## Hypothesis 5: Ternary-from-Binary Transfer Robustness

**Conjecture.** If binary Goldbach is verified on $[4, B]$ (i.e., every even
$n$ in that range has a Goldbach decomposition), then ternary Goldbach holds
on the odd numbers in $[7, B + 3]$.

**Why it matters.** We proved `binary_goldbach_implies_ternary` as a
universal conditional.  This hypothesis asserts that the *finite* verified
range transfers cleanly, with explicit boundary control.  Formally verifying
the transfer on finite intervals creates a certified pipeline: verify binary
Goldbach by computation → automatically certify ternary Goldbach on a
corresponding range.

**How to test.** Formalize a bounded version of the transfer theorem:
```
theorem binary_implies_ternary_bounded (B : ℕ) :
  (∀ n ∈ Finset.Icc 4 B, Even n → HasGoldbachDecomposition n) →
  ∀ n ∈ Finset.Icc 7 (B + 3), Odd n → HasOddVinogradovDecomposition n
```
Then verify computationally for $B = 1000, 10000, \ldots$

**Falsifier.** A boundary case where the transfer fails—an odd $n$ in
$[7, B+3]$ that requires a binary decomposition outside $[4, B]$.  This
should not happen by the proof structure, but the formal verification
confirms it.

---

## Summary of Research Priorities

| Priority | Hypothesis | Effort | Impact |
|----------|-----------|--------|--------|
| 1 | Ternary transfer (H5) | Low | Certified pipeline |
| 2 | Weak Chen prevalence (H2) | Medium | Universal Chen |
| 3 | Count lower bound (H1) | Medium | Structural redundancy |
| 4 | Convolution growth (H4) | High | Hardy–Littlewood bridge |
| 5 | Ternary parity (H3) | Low | Complete parity theory |

The most impactful next step is to extend the decidability infrastructure to
Chen-type and ternary decompositions, then computationally verify the
prevalence hypotheses on large intervals.
