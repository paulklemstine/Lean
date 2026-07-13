# Asymptotic Alternating Signs of Andrews-type q-Series Coefficients

## Abstract

Generating functions arising in the theory of partitions into distinct parts —
the Andrews-type q-series — produce integer coefficient sequences whose signs
frequently exhibit a striking regularity: after correcting for an explicit
oscillatory factor $(-1)^n$, they become eventually positive. We isolate the
analytic mechanism responsible for this **asymptotic alternating-sign**
phenomenon and prove it as a single, elementary principle: if a coefficient
sequence decomposes as $V(n) = (-1)^n A(n) + E(n)$ with a positive dominant
amplitude $A(n)$ and a subdominant error $E(n)$ satisfying $|E(n)| < A(n)$ for
all $n \ge N$, then $(-1)^n V(n) > 0$ for all $n \ge N$. We then realize the
three qualitatively distinct regimes predicted by this principle through three
explicit model series $v_2, v_3, v_4$: the amplitude may dominate for *every*
index (empty exceptional set), only *eventually* (finite exceptional set), or
everywhere *outside a density-zero set* (infinite but sparse exceptional set,
supported exactly on the perfect squares). We prove that the density-zero claim
for $v_4$ follows from the counting bound
$\#\{\text{squares} < M\} \le \lfloor\sqrt M\rfloor + 1$, established without
appeal to real square roots. Finally, we show the strict-domination hypothesis
is sharp: at the critical balance $|E(n)| = A(n)$ the alternation fails on a set
of positive density. Together these results give a complete qualitative theory
of the alternating-sign conjecture for the model family and a template for the
genuine Andrews series.

## 1. Introduction

### 1.1 Partitions and generating series

A *partition* of a non-negative integer is a way of writing it as an unordered
sum of positive integers. Euler's generating-function calculus turns questions
about partitions into questions about power series
$v(q) = \sum_{n \ge 0} V(n)\, q^n$, whose coefficients $V(n)$ encode the counts
of interest. George Andrews and his successors introduced numerous refined
series of this type; a recurring empirical observation is that, for several such
series, the coefficients $V(n)$ do not merely fluctuate in sign but appear to
alternate in a controlled, eventually rigid fashion.

### 1.2 The alternating-sign conjecture

The observation crystallizes into the following statement. For an Andrews-type
coefficient sequence $V(n)$, there is an explicit oscillatory factor $(-1)^n$
and a positive amplitude $A(n)$ such that

$$(-1)^n V(n) > 0 \quad\text{for all sufficiently large } n \text{ outside a set of density zero.}$$

Equivalently, the signs of $V(n)$ strictly alternate in the limit, with only
sparse violations. This paper does two things. First (§2), it identifies the
minimal analytic hypothesis under which this holds and proves it in full
generality over any linearly ordered ring. Second (§3–§6), it constructs three
model series exhibiting the three possible fates of the exceptional set, proves
the density-zero counting bound for the borderline case, and demonstrates the
sharpness of the hypothesis at the boundary.

### 1.3 Relation to the circle method

The structural expectation behind the conjecture is a Hardy–Ramanujan–Rademacher
expansion. The Rademacher-type series for a partition coefficient produces a
leading term of the form $(-1)^n A(n)$ with $A(n)>0$ growing subexponentially
and a remainder $E(n)$ of strictly smaller order. The oscillatory factor
$(-1)^n$ is then not an artefact of small cases but the exact phase of the
dominant Rademacher term, and the sign of $V(n)$ is decided by a single term
whose positivity is explicit. Our principle abstracts precisely this situation.

## 2. The amplitude-domination principle

### 2.1 Statement

**Definition 2.1 (Amplitude–error decomposition).** Let $R$ be a linearly
ordered ring. A sequence $V : \mathbb{N} \to R$ is said to admit an
*amplitude–error decomposition* with amplitude $A : \mathbb{N} \to R$ and error
$E : \mathbb{N} \to R$ if $V(n) = (-1)^n A(n) + E(n)$ for all $n$.

**Theorem 2.2 (Amplitude-domination principle).** *Let $R$ be a linearly ordered
ring and let $V, A, E : \mathbb{N} \to R$ satisfy $V(n) = (-1)^n A(n) + E(n)$ for
all $n$. Suppose there is a threshold $N$ such that $|E(n)| < A(n)$ for every
$n \ge N$. Then*
$$0 < (-1)^n V(n) \qquad \text{for every } n \ge N.$$

**Proof.** Fix $n \ge N$. Multiplying the decomposition by $(-1)^n$ and using
$\big((-1)^n\big)^2 = 1$ gives
$$(-1)^n V(n) = \big((-1)^n\big)^2 A(n) + (-1)^n E(n) = A(n) + (-1)^n E(n).$$
Since $\big|(-1)^n\big| = 1$, we have $\big|(-1)^n E(n)\big| = |E(n)|$, and in
particular $(-1)^n E(n) \ge -|E(n)|$. Therefore
$$(-1)^n V(n) = A(n) + (-1)^n E(n) \ge A(n) - |E(n)| > 0,$$
the last inequality being the domination hypothesis. $\qquad\blacksquare$

### 2.2 Remarks

The proof uses only two facts: the oscillation collapses on the dominant term
because $\big((-1)^n\big)^2 = 1$, and the error is controlled because
$(-1)^n E(n) \ge -|E(n)|$. No analytic machinery, growth rate, or limit is
required — the conclusion is a pointwise inequality holding term by term from the
threshold onward. Because the statement lives over an arbitrary linearly ordered
ring, it applies equally to integer, rational, and real coefficient sequences.
The strictness of the final inequality is inherited *verbatim* from the
strictness of the domination hypothesis; §6 shows this cannot be relaxed.

## 3. Model series $v_2$: alternation with no exceptions

**Definition 3.1.** Define $V_2 : \mathbb{N} \to \mathbb{Z}$ by
$$V_2(n) = (-1)^n\,(2^n + 1) + n.$$
This is an amplitude–error decomposition with amplitude $A(n) = 2^n + 1$ and
error $E(n) = n$.

**Lemma 3.2.** *For every $n \in \mathbb{N}$, $\; n < 2^n + 1$.*

**Proof.** By induction. For $n = 0$, $0 < 2$. Assuming $n < 2^n + 1$, we have
$2^{n+1} + 1 = 2\cdot 2^n + 1 \ge 2^n + 1 > n$, and since $2^n \ge 1$ we get
$2^{n+1}+1 = 2^n + (2^n + 1) \ge 1 + (n+1) > n+1$. $\qquad\blacksquare$

**Theorem 3.3 ($v_2$ alternates everywhere).** *For every $n \in \mathbb{N}$,*
$$0 < (-1)^n V_2(n).$$

**Proof.** Lemma 3.2 gives $|E(n)| = n < 2^n + 1 = A(n)$ for every $n$, so the
domination hypothesis of Theorem 2.2 holds with threshold $N = 0$. The
conclusion follows immediately. $\qquad\blacksquare$

Thus $v_2$ has an **empty** exceptional set: the signs of $V_2$ alternate
perfectly, $+, -, +, -, \dots$, from the very first index.

## 4. Model series $v_3$: alternation for all sufficiently large $n$

**Definition 4.1.** Define $V_3 : \mathbb{N} \to \mathbb{Z}$ by
$$V_3(n) = (-1)^n\,\big(n - 4\big) + 2,$$
an amplitude–error decomposition with amplitude $A(n) = n - 4$ and constant
error $E(n) = 2$.

**Theorem 4.2 ($v_3$ alternates for $n \ge 7$).** *For every $n \ge 7$,*
$$0 < (-1)^n V_3(n).$$

**Proof.** For $n \ge 7$ we have $A(n) = n - 4 \ge 3 > 2 = |E(n)|$, so the
domination hypothesis of Theorem 2.2 holds with threshold $N = 7$. The
conclusion follows. $\qquad\blacksquare$

The threshold is genuine: for $n \le 6$ the amplitude $n - 4$ is at most $2$ and
does not strictly exceed the error, so alternation may (and does) fail there.
Thus $v_3$ has a **finite** exceptional set contained in $\{0,1,\dots,6\}$ and
alternates cleanly thereafter.

## 5. Model series $v_4$: alternation off a density-zero exceptional set

We now construct a series whose exceptional set is genuinely infinite yet has
natural density zero, supported exactly on the perfect squares.

**Definition 5.1 (Tuned error).** Define $E_4 : \mathbb{N} \to \mathbb{Z}$ by
$$E_4(n) = \begin{cases} -(-1)^n \cdot 2\,(n+1), & n \text{ is a perfect square},\\[3pt] 0, & \text{otherwise}.\end{cases}$$

**Definition 5.2.** Define $V_4 : \mathbb{N} \to \mathbb{Z}$ by
$$V_4(n) = (-1)^n\,(n+1) + E_4(n),$$
an amplitude–error decomposition with amplitude $A(n) = n+1$ and error $E_4(n)$.

### 5.1 Behaviour off and on the squares

**Theorem 5.3 (Alternation off the squares).** *If $n$ is not a perfect square,
then*
$$0 < (-1)^n V_4(n).$$

**Proof.** For non-square $n$ the error vanishes, $E_4(n) = 0$, so
$V_4(n) = (-1)^n(n+1)$. Hence $(-1)^n V_4(n) = \big((-1)^n\big)^2 (n+1) =
n + 1 > 0$. $\qquad\blacksquare$

**Theorem 5.4 (Violation on every square).** *If $n$ is a perfect square, then*
$$(-1)^n V_4(n) < 0.$$

**Proof.** For a square $n$ the error is $E_4(n) = -(-1)^n \cdot 2(n+1)$, so
$$V_4(n) = (-1)^n(n+1) - (-1)^n \cdot 2(n+1) = -(-1)^n (n+1).$$
Multiplying by $(-1)^n$ gives $(-1)^n V_4(n) = -\big((-1)^n\big)^2 (n+1) =
-(n+1) < 0$. $\qquad\blacksquare$

Consequently the exceptional set of $v_4$ — the indices where the corrected sign
is non-positive — is *exactly* the set of perfect squares, an infinite set.

### 5.2 The exceptional set has density zero

**Definition 5.5 (Exceptional count).** Let
$$\mathrm{exc}_4(M) = \#\{\, n < M : n \text{ is a perfect square}\,\}$$
denote the number of exceptional indices below $M$.

**Theorem 5.6 (Counting bound).** *For every $M \in \mathbb{N}$,*
$$\mathrm{exc}_4(M) \le \lfloor \sqrt M \rfloor + 1.$$

**Proof.** Every perfect square below $M$ is of the form $k^2$ with
$k \le \lfloor\sqrt M\rfloor$. The map $k \mapsto k^2$ from
$\{0, 1, \dots, \lfloor\sqrt M\rfloor\}$ onto the squares below $M$ is
surjective, so the number of such squares is at most the size of the domain,
namely $\lfloor\sqrt M\rfloor + 1$. $\qquad\blacksquare$

**Theorem 5.7 (Density zero).** *The exceptional set of $v_4$ has natural density
zero:*
$$\lim_{M \to \infty} \frac{\mathrm{exc}_4(M)}{M} = 0.$$

**Proof.** Write $s = \lfloor \sqrt M\rfloor$, so $s^2 \le M$. By Theorem 5.6,
$$\frac{\mathrm{exc}_4(M)}{M} \le \frac{s + 1}{M} \le \frac{s+1}{s^2}
= \frac{1}{s} + \frac{1}{s^2}.$$
As $M \to \infty$ we have $s = \lfloor\sqrt M\rfloor \to \infty$, so both
$1/s$ and $1/s^2$ tend to $0$, and the density tends to $0$ by squeezing. We
emphasize that the bound $(s+1)/M \le 1/s + 1/s^2$ is obtained purely from the
integer inequality $s^2 \le M$, without ever invoking real square roots.
$\qquad\blacksquare$

Thus $v_4$ realizes the borderline regime of the conjecture: alternation holds
off a genuinely infinite exceptional set that is nonetheless of density zero,
with counting function $O(\sqrt M)$.

## 6. Sharpness of the domination hypothesis

Theorem 2.2 requires the *strict* inequality $|E(n)| < A(n)$. We show this cannot
be weakened to $|E(n)| \le A(n)$: at the critical balance the conclusion fails on
a set of positive density.

**Definition 6.1 (Boundary series).** Let $W$ be a sequence admitting an
amplitude–error decomposition $W(n) = (-1)^n A(n) + E(n)$ in which the error is
tuned to the critical balance $|E(n)| = A(n)$ with $E(n) = -(-1)^n A(n)$ on the
odd indices, so that $W(n) = 0$ there.

**Theorem 6.2 (Boundary failure).** *For the boundary series $W$, the
sign-corrected value $(-1)^n W(n)$ fails to be positive on every odd index. Since
the odd indices have natural density $\tfrac12$, alternation fails on a set of
positive density, and no threshold $N$ makes $(-1)^n W(n) > 0$ eventually.*

**Proof.** On an odd index $n$ the critical tuning gives
$(-1)^n W(n) = A(n) + (-1)^n E(n) = A(n) - A(n) = 0$, which is not strictly
positive. The odd numbers below $M$ number $\lceil M/2\rceil$, so their density
is $\tfrac12 > 0$, and every threshold $N$ is exceeded by infinitely many odd
indices. $\qquad\blacksquare$

Hence the strict inequality in the domination hypothesis is necessary: relaxing
it to equality admits a positive-density set of sign violations. The dichotomy
between density-zero and positive-density exceptional sets is therefore a genuine
phase transition governed by the ratio $|E|/A$, with the transition occurring
exactly at ratio $1$.

## 7. Algorithms

The results are effective and directly computable. We record the two principal
algorithms.

**Algorithm A (Sign-alternation verifier).** Given the amplitude $A$, error $E$,
threshold $N$, and a bound $M$, verify that $(-1)^n\big[(-1)^n A(n)+E(n)\big]>0$
for all $N \le n < M$ by evaluating the corrected coefficient
$A(n) + (-1)^n E(n)$ at each index and checking positivity. Complexity is $O(M)$
evaluations; each reduces to the scalar comparison $A(n) > |E(n)|$.

**Algorithm B (Exceptional-density estimator).** Given a coefficient sequence and
a bound $M$, count the exceptional indices $\{n < M : (-1)^n V(n) \le 0\}$ and
return the empirical density and its comparison against the analytic bound
$(\lfloor\sqrt M\rfloor + 1)/M$. Complexity is $O(M)$; for $v_4$ the empirical
density matches the analytic upper bound to leading order $\sim 1/\sqrt M$.

## 8. Applications and discussion

The amplitude-domination principle is a template. Its usefulness is that it
reduces a global sign question about an entire integer sequence to a single
scalar inequality $|E(n)| < A(n)$, checkable term by term and — when combined
with effective error bounds from the circle method — verifiable beyond an
explicit computable threshold rather than merely asymptotically.

The three model series delineate the complete qualitative landscape:

- **Empty exceptional set** ($v_2$): amplitude dominates from index $0$.
- **Finite exceptional set** ($v_3$): amplitude dominates from an explicit
  finite threshold.
- **Density-zero exceptional set** ($v_4$): amplitude dominates off an infinite
  but sparse arithmetic locus with counting function $O(\sqrt M)$.

The boundary analysis pins down where the picture breaks, converting the
qualitative statement "the amplitude must beat the error" into the sharp
quantitative claim that the strict inequality is both sufficient and necessary.

## 9. Future work

Several directions extend these findings toward the genuine Andrews q-series.

1. **Circle-method amplitude beats the tail.** For each Andrews-type coefficient
   $V_i(n)$, the Rademacher expansion should yield a leading term $(-1)^n A_i(n)$
   with $A_i(n) > 0$ subexponential and a remainder $E_i(n)$ of strictly smaller
   order, so that $|E_i(n)| < A_i(n)$ for all sufficiently large $n$ — with a
   *computable* threshold thanks to effective Rademacher error bounds.

2. **Structured exceptional sets.** The sign-violation indices are conjectured to
   form a density-zero set with counting function $O(n^{1/2})$, matching $v_4$,
   because a violation requires a resonance in which two nearly equal Rademacher
   terms cancel the leading amplitude, pinning $n$ to a sparse arithmetic locus.

3. **Sharp domination threshold.** Combining the domination principle with
   explicit Rademacher constants should locate a critical error-to-amplitude
   ratio $c_i$ below which alternation holds off a density-zero set and at which
   the violation set acquires positive density — a genuine phase transition.

4. **A uniform principle across the Andrews family.** The mechanism is expected
   to apply uniformly across the whole family of partition-type series, with the
   amplitude-domination principle providing a single unifying explanation.

## 10. Conclusion

The asymptotic alternating-sign behaviour of Andrews-type q-series coefficients
is, at its core, a two-line inequality: after correcting for the oscillatory
factor $(-1)^n$, a coefficient equals its positive amplitude plus a bounded
error, and positivity follows whenever the amplitude strictly dominates. The
three model series make the abstract principle concrete, exhibiting empty,
finite, and density-zero exceptional sets, while the boundary series proves the
strictness of the hypothesis is indispensable. Together they give a complete
qualitative theory of the conjecture for the model family and a clear blueprint
for its resolution in the genuine partition-theoretic setting.
