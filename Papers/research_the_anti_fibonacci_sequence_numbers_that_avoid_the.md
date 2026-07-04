# The Anti-Fibonacci Sequence: Quadratic Growth and Provable Avoidance of the Golden Ratio

## Abstract

The Fibonacci sequence $F(k+1) = F(k) + F(k-1)$ is celebrated for a single
asymptotic fact: the ratio of consecutive terms converges to the golden ratio
$\varphi = \tfrac{1+\sqrt5}{2}$. We study a natural counterpoint, the
*anti-Fibonacci sequence* $A$, defined by the first-order recurrence
$A(0) = 1$ and $A(k+1) = A(k) + k$, whose first terms are
$1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, \dots$. We establish three main
results. First, an exact closed form, $2A(k) + k = k^2 + 2$, equivalently
$A(k) = 1 + \tfrac{k(k-1)}{2}$, proved by induction. Second, quadratic growth
with an exact leading constant: $A(k)/k^2 \to \tfrac12$. Third, and centrally,
that the anti-Fibonacci sequence *provably avoids the golden ratio*: the
consecutive ratio $A(k+1)/A(k)$ converges to $1$, and hence, by uniqueness of
limits together with $1 < \varphi$, does not converge to $\varphi$. This gives a
precise, theorem-level sense in which the anti-Fibonacci sequence is the opposite
of the Fibonacci sequence — quadratic rather than exponential, ratio-limit $1$
rather than $\varphi$. We also record that the value set has natural density
zero. Along the way we correct a folklore mis-estimate: the leading constant is
$\tfrac12$, not $\tfrac14$, and the consecutive ratio converges monotonically to
$1$ rather than oscillating between $1$ and $2$.

**Keywords.** Anti-Fibonacci sequence, golden ratio, quadratic growth,
consecutive-ratio limit, triangular numbers, lazy caterer sequence, natural
density.

## 1. Introduction

The Fibonacci sequence is the archetype of an additive recurrence. Its
defining rule, "each term is the sum of the two before it," produces
exponential growth governed by the golden ratio $\varphi = \tfrac{1+\sqrt5}{2}
\approx 1.618$; concretely, $F(k+1)/F(k) \to \varphi$. This limit is the
sequence's signature.

It is natural to seek a *complementary* object: a sequence built to avoid, rather
than to embrace, being a sum. Consider the greedy rule "the next term should not
be the plain sum of the two previous terms, and among the admissible values we
take the least consistent choice." Carried out from the seed values, this
avoidance discipline produces successive first differences $0, 1, 2, 3, 4, \dots$
and hence the sequence

$$1,\ 1,\ 2,\ 4,\ 7,\ 11,\ 16,\ 22,\ 29,\ 37,\ 46,\ 56,\ \dots \tag{1}$$

The differences being exactly the natural numbers is the concrete, checkable
content of the construction, and we take it as our working definition:

$$A(0) = 1, \qquad A(k+1) = A(k) + k. \tag{2}$$

Where the Fibonacci recurrence is second-order and homogeneous, (2) is
first-order and inhomogeneous, adding the *index* $k$ rather than a previous
term. This one structural change transforms the asymptotics completely.

The remainder of the paper is organized as follows. Section 2 fixes definitions
and elementary facts. Section 3 proves the exact closed form. Section 4
establishes quadratic growth with leading constant $\tfrac12$. Section 5 proves
the flagship result — provable avoidance of the golden ratio — and places it in
the general context of ratio limits as growth classifiers. Section 6 records the
density-zero property. Section 7 discusses a correction to folklore estimates.
Section 8 gives applications and interpretation, and Section 9 lists future
directions.

## 2. Definitions and elementary facts

**Definition 2.1 (Anti-Fibonacci sequence).** The *anti-Fibonacci sequence* is
the function $A : \mathbb{N} \to \mathbb{N}$ defined by $A(0) = 1$ and, for all
$k \ge 0$, $A(k+1) = A(k) + k$.

The first values are, as in (1), $A(0)=1,\ A(1)=1,\ A(2)=2,\ A(3)=4,\ A(4)=7,\
A(5)=11,\ A(6)=16,\ \dots$; note $A(1) = A(0) + 0 = 1$, which explains the
repeated initial $1$.

**Lemma 2.2 (Positivity).** For all $k$, $A(k) \ge 1 > 0$.

*Proof.* Induction. $A(0) = 1 > 0$. If $A(k) \ge 1$ then $A(k+1) = A(k) + k \ge
A(k) \ge 1$. $\qquad\blacksquare$

Positivity guarantees that every consecutive ratio $A(k+1)/A(k)$ is well defined
(no division by zero), a point that matters for the ratio analysis in Section 5.

## 3. The exact closed form

**Theorem 3.1 (Closed form).** For all $k \in \mathbb{N}$,

$$2\,A(k) + k = k^2 + 2, \qquad\text{equivalently}\qquad A(k) = 1 + \frac{k(k-1)}{2}. \tag{3}$$

*Proof.* We prove the identity $2A(k) + k = k^2 + 2$ by induction on $k$.

*Base case.* $2A(0) + 0 = 2 = 0^2 + 2$.

*Inductive step.* Assume $2A(k) + k = k^2 + 2$. Using the recurrence
$A(k+1) = A(k) + k$,
$$2A(k+1) + (k+1) = 2\big(A(k) + k\big) + (k+1) = \big(2A(k) + k\big) + 2k + 1.$$
By the inductive hypothesis the bracket equals $k^2 + 2$, so
$$2A(k+1) + (k+1) = k^2 + 2 + 2k + 1 = (k+1)^2 + 2,$$
which is the claim for $k+1$. Solving $2A(k) + k = k^2 + 2$ for $A(k)$ gives
$A(k) = \tfrac{k^2 - k + 2}{2} = 1 + \tfrac{k(k-1)}{2}$. $\qquad\blacksquare$

**Remark 3.2.** The quantity $1 + \tfrac{k(k-1)}{2}$ is the $k$-th *central
polygonal ("lazy caterer") number*: the maximal number of regions into which
$k$ straight cuts can divide a disk. Thus the anti-Fibonacci sequence coincides
with this classical combinatorial sequence, shifted to start at $A(0)=1$. The
closed form is exact — it holds with equality for every $k$, with no error term
— which is what enables the sharp asymptotic statements below.

**Corollary 3.3 (Real closed form).** As real numbers,
$$A(k) = \frac{k^2 - k + 2}{2}. \tag{4}$$

## 4. Quadratic growth with exact leading constant

**Theorem 4.1 (Quadratic growth).**
$$\lim_{k\to\infty} \frac{A(k)}{k^2} = \frac{1}{2}. \tag{5}$$

*Proof.* By (4), for $k \ge 1$,
$$\frac{A(k)}{k^2} = \frac{k^2 - k + 2}{2k^2}
= \frac{1}{2} - \frac{1}{2k} + \frac{1}{k^2}.$$
As $k \to \infty$, the terms $\tfrac{1}{2k}$ and $\tfrac{1}{k^2}$ tend to $0$,
so the expression tends to $\tfrac12$. $\qquad\blacksquare$

**Corollary 4.2 (Sublinear index-to-value ratio).**
$$\lim_{k\to\infty} \frac{k}{A(k)} = 0. \tag{6}$$

*Proof.* By (4), $\dfrac{k}{A(k)} = \dfrac{2k}{k^2 - k + 2}$. For large $k$ the
denominator grows quadratically while the numerator grows linearly, so the ratio
tends to $0$. Formally, $\dfrac{2k}{k^2 - k + 2} \le \dfrac{2k}{k^2 - k} =
\dfrac{2}{k-1} \to 0$ for $k \ge 2$. $\qquad\blacksquare$

Equation (5) fixes the leading constant *exactly* at $\tfrac12$. This is the
honest asymptotic content of the sequence: $A(k) \sim \tfrac{k^2}{2}$, so that
$A(k) = \tfrac{k^2}{2} + O(k)$.

## 5. Provable avoidance of the golden ratio

We now come to the central phenomenon. Recall $\varphi = \tfrac{1+\sqrt5}{2}
\approx 1.618$, the unique positive root of $x^2 = x + 1$, and that for the
Fibonacci sequence $F(k+1)/F(k) \to \varphi$.

**Theorem 5.1 (Consecutive ratio).**
$$\lim_{k\to\infty} \frac{A(k+1)}{A(k)} = 1. \tag{7}$$

*Proof.* Using the recurrence and Lemma 2.2 (so the division is valid),
$$\frac{A(k+1)}{A(k)} = \frac{A(k) + k}{A(k)} = 1 + \frac{k}{A(k)}.$$
By Corollary 4.2, $\tfrac{k}{A(k)} \to 0$, hence the right-hand side tends to
$1 + 0 = 1$. $\qquad\blacksquare$

**Theorem 5.2 (Avoidance of the golden ratio).** The consecutive-ratio sequence
$A(k+1)/A(k)$ does *not* converge to the golden ratio:
$$\frac{A(k+1)}{A(k)} \not\to \varphi. \tag{8}$$

*Proof.* Suppose, for contradiction, that $A(k+1)/A(k) \to \varphi$. By
Theorem 5.1 the same sequence also converges to $1$. Limits of a convergent
real sequence are unique, so this would force $1 = \varphi$. But $\varphi =
\tfrac{1+\sqrt5}{2} > \tfrac{1+2}{2} = \tfrac32 > 1$, a contradiction. Hence the
sequence does not converge to $\varphi$. $\qquad\blacksquare$

Theorem 5.2 is the precise, theorem-level meaning of "the anti-Fibonacci
sequence avoids the golden ratio at all costs." Whereas the Fibonacci
consecutive ratio is *attracted* to $\varphi$, the anti-Fibonacci consecutive
ratio is *pinned* to $1$ and is therefore forbidden from approaching $\varphi$.
The two sequences are genuine opposites at the level of their defining
asymptotic.

**Interpretation: the ratio limit as a growth classifier.** Theorems 5.1 and 5.2
illustrate a general principle. For a positive sequence $a_k$:

- If $a_k$ grows *exponentially* with base $r > 1$ (more precisely, if
  $a_{k+1}/a_k \to r$), the consecutive ratio detects the base $r$. The
  Fibonacci sequence, a homogeneous linear recurrence with dominant
  characteristic root $\varphi$, realizes $r = \varphi$.
- If $a_k$ grows *polynomially*, say $a_k \sim c\,k^d$ with $d \ge 1$, then
  $$\frac{a_{k+1}}{a_k} \sim \frac{c(k+1)^d}{c\,k^d} = \left(1 + \frac1k\right)^d \to 1.$$

Thus consecutive-ratio limit $1$ is the *universal signature of polynomial
growth*, and the golden ratio is nothing more exotic than the dominant root of
one particular linear recurrence. The anti-Fibonacci sequence, with $d = 2$ and
$c = \tfrac12$, sits squarely in the polynomial regime, and Theorem 5.1 is the
specific instance of this general dichotomy. The value $1$ cleanly separates
polynomial sequences from exponential ones.

## 6. Density of the value set

**Proposition 6.1 (Density zero).** The set of values $V = \{A(k) : k \in
\mathbb{N}\}$ has natural density $0$ in $\mathbb{N}$; that is,
$$\lim_{N\to\infty} \frac{\#\{v \in V : v \le N\}}{N} = 0.$$

*Sketch.* By (4), $A(k) \le N$ is equivalent (for the increasing part $k \ge 1$)
to $k^2 - k + 2 \le 2N$, i.e. $k \lesssim \sqrt{2N}$. Hence the number of terms
not exceeding $N$ is $O(\sqrt{N})$, and
$\#\{v \in V : v \le N\}/N = O(N^{-1/2}) \to 0$. $\qquad\blacksquare$

The complement of $V$ — those integers that *are* expressible via the additive
structure the greedy rule avoids — therefore has density $1$: the anti-Fibonacci
values are a vanishingly thin subset of the integers, exactly as one expects of a
quadratically growing sequence (compare the perfect squares, which thin out for
the same reason).

## 7. A correction to folklore estimates

Casual inspection of the early terms invites two natural but incorrect guesses,
which we record and refute here because they circulate as folklore.

**(a) Leading constant $\tfrac14$ vs. $\tfrac12$.** One might guess $A(k) \sim
\tfrac{k^2}{4}$ and $A(k)/k^2 \to \tfrac14$. This is false. From the exact form
(4), $A(k)/k^2 \to \tfrac12$ (Theorem 4.1). Numerically, for $k$ near $50$ the
ratio $A(k)/k^2$ is already $\approx 0.49$, converging to $0.5$, not $0.25$. The
correct statement is $A(k) = \lfloor k^2/2\rfloor + O(1)$, not
$\lfloor k^2/4\rfloor + O(1)$.

**(b) Oscillation of the consecutive ratio.** One might guess the consecutive
ratio $A(k+1)/A(k)$ oscillates between $1$ and $2$ and fails to converge. This
too is false: by Theorem 5.1 the ratio converges to $1$, and it does so
*monotonically* from above, since $A(k+1)/A(k) = 1 + \tfrac{k}{A(k)}$ with
$\tfrac{k}{A(k)}$ eventually decreasing to $0$. Numerically, near $k = 50$ the
ratio is $\approx 1.04$ and shrinking toward $1$.

Both corrections follow immediately and rigorously from the exact closed form of
Theorem 3.1, underscoring the value of establishing that identity first.

## 8. Applications and interpretation

**A clean pedagogical contrast.** The Fibonacci/anti-Fibonacci pair is an ideal
teaching example for the difference between exponential and polynomial growth,
and for the meaning of consecutive-ratio limits. The two sequences differ by a
single, easily explained change to the recurrence (add two previous terms vs.
add the index), yet exhibit qualitatively opposite asymptotics.

**Demystifying "magic constants."** The golden ratio is often presented as a
mysterious constant woven into nature. Theorem 5.2 reframes it: $\varphi$ is the
growth factor of a *specific* exponential recurrence, and swapping the recurrence
for a polynomial one replaces $\varphi$ with the plain constant $1$. Constants
are consequences of rules.

**Summable structure.** Because the first differences are exactly $0, 1, 2,
\dots$, partial sums, generating functions, and asymptotic expansions of the
anti-Fibonacci sequence are all available in closed form, making it a convenient
test bed for asymptotic methods where the Fibonacci sequence's transcendental
growth is less transparent.

**Summary comparison.**

| Property | Fibonacci $F$ | Anti-Fibonacci $A$ |
|---|---|---|
| Recurrence | $F(k+1) = F(k) + F(k-1)$ | $A(k+1) = A(k) + k$ |
| Order | second, homogeneous | first, inhomogeneous |
| Growth | exponential, $\sim \varphi^k/\sqrt5$ | quadratic, $\sim k^2/2$ |
| Closed form | Binet (irrational base) | $1 + \tfrac{k(k-1)}{2}$ (exact, integer) |
| Consecutive ratio | $\to \varphi \approx 1.618$ | $\to 1$ |
| Density in $\mathbb{N}$ | $0$ | $0$ |

## 9. Future directions

**A universal error law for greedy sum-avoiding sequences.** For each fixed
window width $w$, the greedy sequence forbidding every new term from equalling
the sum of its $w$ predecessors is conjectured to grow as $A(n) = c_w n^2 + O(n)$
with an explicit rational $c_w$, and with eventually periodic rounded residual.
The mechanism: bounded-window greedy avoidance makes the first differences a
finite-state process, hence ultimately arithmetic and summable in closed form,
pinning the quadratic constant exactly. The two-back case resolved here (with
$c = \tfrac12$) is the base of an induction on $w$ via the same
difference-telescoping method.

**Additive rigidity of quadratic avoidance sets.** The value set
$\{1 + \tfrac{k(k-1)}{2}\}$ is conjectured to be additively rigid: its
representation function (the number of ways to write $n$ as a sum of two members)
is bounded, and it contains no nontrivial additive quadruples. The closed form
turns each additive coincidence into a Pell-type quadratic Diophantine equation,
whose solution count is governed by the classical theory of binary quadratic
forms.

**The ratio limit as a dividing line between growth regimes.** A sequence is
conjectured to have consecutive ratio tending to $1$ exactly when it has
polynomial growth, while a homogeneous linear recurrence with dominant root
$r>1$ always has consecutive ratio tending to $r$. The value $1$ then cleanly
separates polynomial from genuinely exponential sequences, with Fibonacci
($\varphi$) and anti-Fibonacci ($1$) supplying the two endpoints of the
dichotomy.

**A genuinely oscillating anti-Fibonacci.** There is conjectured to be a
naturally defined greedy variant whose consecutive ratio has limit inferior $1$
and limit superior $2$ and never converges, with the ratios equidistributing over
$[1,2]$ against an explicit measure — realizing the oscillation that the present
sequence, contrary to folklore, does not exhibit.

## 10. Conclusion

The anti-Fibonacci sequence $A(0)=1,\ A(k+1) = A(k)+k$ is a quadratic-growth
counterpoint to the Fibonacci sequence. It admits the exact closed form
$A(k) = 1 + \tfrac{k(k-1)}{2}$, grows like $\tfrac{k^2}{2}$ (so $A(k)/k^2 \to
\tfrac12$), has value set of density zero, and — most strikingly — provably
avoids the golden ratio: its consecutive ratio converges to $1$, and by
uniqueness of limits cannot converge to $\varphi$. Where Fibonacci is the
paradigm of exponential growth and its golden ratio, the anti-Fibonacci sequence
is the paradigm of polynomial growth and its ratio limit $1$ — a precise,
provable opposite.
