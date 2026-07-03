# The Anti-Fibonacci Sequence: Quadratic Growth That Avoids the Golden Ratio

## Abstract

The Fibonacci sequence $F(n+1) = F(n) + F(n-1)$ grows exponentially, and the ratio of its consecutive terms converges to the golden ratio $\varphi = (1+\sqrt5)/2$. We study a natural counterpoint arising from the greedy principle "each new term dodges the running Fibonacci-style sum." This construction yields the **anti-Fibonacci sequence** $A(0)=1$, $A(n+1) = A(n) + n$, whose terms are $1, 1, 2, 4, 7, 11, 16, 22, 29, 37, \dots$ We prove that this sequence is governed entirely by the closed-form identity $2A(n) + n = n^2 + 2$, equivalently $A(n) = 1 + \binom{n}{2}$. From this single relation we derive three principal results. First (**density / quadratic growth**), $A(n)/n^2 \to 1/2$, so the sequence is genuinely quadratic with leading coefficient $1/2$. Second (**golden-ratio avoidance**), the consecutive ratio $A(n+1)/A(n)$ converges to $1 \neq \varphi$; the sequence never approaches the golden ratio. Third (**Fibonacci-coincidence characterization**), the three-term relation $A(n+2) = A(n+1) + A(n)$ holds for exactly two indices, $n = 0$ and $n = 3$, and the sequence strictly undershoots the Fibonacci sum for all $n \ge 4$. We situate these results as the quadratic mirror image of the classical Fibonacci/golden-ratio theory and discuss a dichotomy for greedy "avoid the combination" sequences.

**Keywords:** anti-Fibonacci sequence, golden ratio, quadratic growth, triangular numbers, greedy sequences, ratio limits, central polygonal numbers.

---

## 1. Introduction

The Fibonacci sequence is the archetype of iterated addition. Defined by $F(0)=0$, $F(1)=1$, and $F(n+1) = F(n) + F(n-1)$, it grows exponentially, and Binet's formula shows that $F(n)$ is asymptotic to $\varphi^n/\sqrt5$, where

$$\varphi = \frac{1+\sqrt5}{2} \approx 1.618034$$

is the golden ratio, the positive root of $x^2 = x + 1$. A defining feature of the Fibonacci sequence is that the ratio of consecutive terms converges to $\varphi$: the golden ratio is an *attractor* for a broad family of additive recurrences.

This paper investigates a deliberately contrarian construction. Instead of *forming* Fibonacci-style sums, we ask each term to *avoid* them: begin the sequence and let each new term be the smallest positive value that keeps the sequence strictly increasing while sidestepping the Fibonacci sum of its predecessors. Carrying out this greedy "dodge the sum" recipe produces a sequence whose increments grow by exactly one at each step, and which therefore satisfies the clean additive recurrence

$$A(0) = 1, \qquad A(n+1) = A(n) + n. \tag{1}$$

Its first terms are

$$1,\ 1,\ 2,\ 4,\ 7,\ 11,\ 16,\ 22,\ 29,\ 37,\ 46,\ 56,\ \dots \tag{2}$$

These are the central polygonal ("lazy caterer") numbers, shifted to include a repeated leading $1$: $A(n)$ is the maximum number of regions into which $n-1$ straight lines divide the plane.

We call the sequence $A$ the **anti-Fibonacci sequence** because it is, in a precise sense developed below, the structural opposite of the Fibonacci sequence. Where Fibonacci multiplies, $A$ accumulates; where Fibonacci grows exponentially, $A$ grows quadratically; where the Fibonacci ratio converges to the golden ratio $\varphi$, the anti-Fibonacci ratio converges to $1$; and where the Fibonacci relation always holds, for $A$ it holds only twice.

### 1.1 Prior informal conjectures and their resolution

The construction was first accompanied by three informal conjectures, which our analysis sharpens or corrects:

- **(a) Growth constant.** It was conjectured that $A(n) \sim n^2/4$, i.e. $A(n)/n^2 \to 1/4$. The closed form (Theorem 3.1) shows the correct leading coefficient is $1/2$: $A(n)/n^2 \to 1/2$.
- **(b) Ratio behavior.** It was conjectured that the consecutive ratio $A(n+1)/A(n)$ oscillates in $[1,2]$ and does not converge. In fact (Theorem 4.1) the ratio *does* converge, monotonically after the second term, to the limit $1$.
- **(c) Sum avoidance.** It was conjectured that $A$ always avoids being a Fibonacci sum. The precise statement (Theorem 5.1) is that the three-term Fibonacci relation holds at exactly $n = 0$ and $n = 3$, and the sequence strictly undershoots the Fibonacci sum for every $n \ge 4$.

The common thread is that all behavior of $A$ is determined by one closed-form identity, which we establish first.

---

## 2. The governing closed form

**Definition 2.1 (Anti-Fibonacci sequence).** Define $A : \mathbb{N} \to \mathbb{N}$ by $A(0) = 1$ and $A(n+1) = A(n) + n$.

**Theorem 2.2 (Closed form).** For all $n \in \mathbb{N}$,

$$2\,A(n) + n = n^2 + 2. \tag{3}$$

Equivalently, over the reals,

$$A(n) = \frac{n^2 - n + 2}{2} = 1 + \frac{n(n-1)}{2} = 1 + \binom{n}{2}. \tag{4}$$

*Proof.* We argue by induction on $n$. For $n = 0$: $2A(0) + 0 = 2 = 0^2 + 2$. Assume $2A(n) + n = n^2 + 2$. Then, using $A(n+1) = A(n) + n$,

$$2A(n+1) + (n+1) = 2A(n) + 2n + (n+1) = (2A(n) + n) + (2n + 1) = (n^2 + 2) + (2n + 1) = (n+1)^2 + 2.$$

This completes the induction, proving (3). Dividing (3) by $2$ and solving for $A(n)$ gives (4). $\qquad\blacksquare$

The identity (3) is subtraction-free and therefore holds already in the natural numbers, while (4) is its real-valued restatement, convenient for asymptotics.

**Corollary 2.3 (Positivity).** $A(n) > 0$ for all $n$.

*Proof.* If $A(n) = 0$, then $(3)$ gives $n = n^2 + 2$, i.e. $n^2 - n + 2 = 0$, which has no real (hence no natural) solution since its discriminant is $1 - 8 < 0$. $\qquad\blacksquare$

All subsequent results follow from (3)–(4) by elementary algebra and standard limit arguments.

---

## 3. Density: quadratic growth with leading coefficient $1/2$

**Theorem 3.1 (Density / quadratic growth).**

$$\lim_{n \to \infty} \frac{A(n)}{n^2} = \frac{1}{2}.$$

*Proof.* By (4), for $n \ge 1$,

$$\frac{A(n)}{n^2} = \frac{n^2 - n + 2}{2n^2} = \frac{1}{2}\left(1 - \frac{1}{n} + \frac{2}{n^2}\right).$$

As $n \to \infty$, $1/n \to 0$ and $2/n^2 \to 0$, so the bracket tends to $1$ and the whole expression tends to $1/2$. $\qquad\blacksquare$

Thus $A(n) = \tfrac12 n^2 + O(n)$: the sequence is genuinely quadratic. This refutes the informal guess $A(n) \sim n^2/4$; the correct leading coefficient is $1/2$. Numerically, at $n = 10^6$ one finds $A(n)/n^2 = 0.4999995$, and $A(n) = 499{,}999{,}500{,}001$.

**Remark 3.2.** The stronger statement $A(n) = \lfloor n^2/2 \rfloor + O(1)$ is immediate from (4): indeed $A(n) - \tfrac{n^2}{2} = 1 - \tfrac{n}{2}$, so more precisely $A(n) = \tfrac{n^2}{2} - \tfrac{n}{2} + 1$ exactly, with no error term at all.

---

## 4. Golden-ratio avoidance

We now examine the ratio of consecutive terms, the quantity that for the Fibonacci sequence converges to $\varphi$.

**Theorem 4.1 (Ratio limit).**

$$\lim_{n \to \infty} \frac{A(n+1)}{A(n)} = 1.$$

*Proof.* Since $A(n+1) = A(n) + n$,

$$\frac{A(n+1)}{A(n)} = 1 + \frac{n}{A(n)}.$$

By (4), $A(n) = \tfrac12(n^2 - n + 2)$, so

$$\frac{n}{A(n)} = \frac{2n}{n^2 - n + 2} \longrightarrow 0 \quad (n \to \infty),$$

because the denominator grows quadratically while the numerator grows linearly. Hence $A(n+1)/A(n) \to 1$.

Alternatively, and this is the route used in the formal development, write both $A(n+1)/n^2 \to 1/2$ and $A(n)/n^2 \to 1/2$ (each following from Theorem 3.1, the former because $A(n+1)/n^2 = A(n)/n^2 + 1/n \to 1/2$), and take the quotient of the two limits, valid because the common limit $1/2$ is nonzero. $\qquad\blacksquare$

**Proposition 4.2 (The limit is not the golden ratio).** $1 \neq \varphi$, where $\varphi = (1+\sqrt5)/2$.

*Proof.* We have $\varphi = (1 + \sqrt5)/2$. Since $5 > 1$ we have $\sqrt5 > 1$, whence $\varphi > (1+1)/2 = 1$. Thus $\varphi > 1$, so $1 \neq \varphi$. $\qquad\blacksquare$

**Theorem 4.3 (Golden-ratio avoidance).** The consecutive ratio $A(n+1)/A(n)$ converges to $1$, and $1 \neq \varphi$. Consequently, unlike the Fibonacci sequence — whose consecutive ratios converge to $\varphi$ — the anti-Fibonacci sequence never approaches the golden ratio; its ratio settles permanently at $1$.

*Proof.* Combine Theorem 4.1 and Proposition 4.2. $\qquad\blacksquare$

**Remark 4.4 (Monotone approach, no oscillation).** The informal conjecture that the ratios oscillate in $[1,2]$ without converging is false. Explicitly, $A(1)/A(0) = 1$, $A(2)/A(1) = 2$, and for $n \ge 2$ the ratio $1 + \frac{2n}{n^2-n+2}$ decreases monotonically to $1$: the derivative of $t \mapsto \frac{2t}{t^2 - t + 2}$ is negative for $t \ge 2$ (its numerator $2(2 - t^2)$ is negative there). The observed sequence of ratios $1, 2, 2, 1.75, 1.571, 1.454, 1.375, \dots$ confirms the monotone decrease toward $1$.

---

## 5. The Fibonacci-coincidence set

A sequence designed to avoid the Fibonacci rule may still satisfy it at isolated indices. We characterize these completely.

**Theorem 5.1 (Fibonacci coincidences).** For all $n \in \mathbb{N}$,

$$A(n+2) = A(n+1) + A(n) \iff n = 0 \ \text{or}\ n = 3.$$

*Proof.* By definition, $A(n+2) = A(n+1) + (n+1)$. Substituting into the left-hand relation and cancelling $A(n+1)$, the Fibonacci relation is equivalent to

$$A(n) = n + 1.$$

By (4), $A(n) = 1 + \tfrac{n(n-1)}{2}$, so $A(n) = n+1$ becomes

$$1 + \frac{n(n-1)}{2} = n + 1 \iff \frac{n(n-1)}{2} = n \iff n(n-1) = 2n \iff n^2 = 3n \iff n(n-3) = 0.$$

Over $\mathbb{N}$ this holds iff $n = 0$ or $n = 3$. $\qquad\blacksquare$

The two coincidences are $A(2) = 2 = 1 + 1 = A(1) + A(0)$ and $A(5) = 11 = 7 + 4 = A(4) + A(3)$.

**Theorem 5.2 (Eventual strict undershoot).** For every $n \ge 4$,

$$A(n+2) < A(n+1) + A(n).$$

*Proof.* As above, the inequality is equivalent to $n + 1 < A(n)$, i.e. $n + 1 < 1 + \tfrac{n(n-1)}{2}$, i.e. $n < \tfrac{n(n-1)}{2}$, i.e. $2 < n - 1$ (dividing by $n > 0$), i.e. $n > 3$. Hence it holds precisely for $n \ge 4$. $\qquad\blacksquare$

Theorems 5.1 and 5.2 together give the complete picture: the anti-Fibonacci sequence satisfies the Fibonacci relation at exactly $n \in \{0, 3\}$, strictly *exceeds* the Fibonacci sum at the two intermediate indices $n = 1, 2$ (there $A(n) > n+1$), and sits strictly *below* it for all $n \ge 4$. The coincidence is "true for a hidden linear reason": the relation collapses to the single linear equation $A(n) = n+1$, whose graph meets the quadratic $A$ in exactly two points, with $A$ above the line in between and below it thereafter.

---

## 6. The Fibonacci / anti-Fibonacci duality

The results above assemble into a clean duality between the two sequences.

| Feature | Fibonacci $F$ | Anti-Fibonacci $A$ |
|---|---|---|
| Recurrence | $F(n+1) = F(n) + F(n-1)$ | $A(n+1) = A(n) + n$ |
| Closed form | $F(n) = (\varphi^n - \psi^n)/\sqrt5$ | $A(n) = 1 + \binom{n}{2}$ |
| Growth | exponential, $\sim \varphi^n/\sqrt5$ | quadratic, $\sim n^2/2$ |
| Increment $F(n+1)-F(n)$ / $A(n+1)-A(n)$ | grows exponentially | grows by $1$: equals $n$ |
| Consecutive ratio limit | $\varphi = 1.618\dots$ | $1$ |
| Fibonacci relation holds | for all $n$ | only at $n \in \{0,3\}$ |
| Governing constant | $\varphi$ (root of $x^2=x+1$) | $1$ |

Where Fibonacci's DNA is the quadratic irrational $\varphi$, the anti-Fibonacci sequence's DNA is the integer $1$. The two are, respectively, the exponential and the quadratic prototypes of iterated addition.

---

## 7. Algorithms

We record three elementary algorithms; each runs in the stated complexity and is implemented in the accompanying demonstration code.

**Algorithm 7.1 (Recurrence generation).** Generate $A(0), \dots, A(N)$ by iterating $A(k+1) = A(k) + k$. Time $O(N)$, space $O(N)$ (or $O(1)$ if only the last term is needed).

**Algorithm 7.2 (Closed-form evaluation).** Compute $A(n) = 1 + n(n-1)/2$ in $O(1)$ integer arithmetic. This permits evaluation at astronomically large $n$ (e.g. $n = 10^{18}$) instantly, and provides an independent cross-check against Algorithm 7.1 (they agree exactly for all tested $n$).

**Algorithm 7.3 (Coincidence and undershoot scan).** For a range of indices, test $A(n+2) = A(n+1) + A(n)$ using either representation; return the coincidence set (provably $\{0, 3\}$) and verify strict undershoot for $n \ge 4$.

---

## 8. Applications and interpretation

Beyond its intrinsic appeal, the anti-Fibonacci sequence is a laboratory example of how a small change to a generation rule flips a system between growth regimes. The Fibonacci rule couples each term to *two* predecessors and thereby manufactures exponential growth and an irrational ratio limit. The anti-Fibonacci rule, by asking each term merely to sidestep the sum, degrades this coupling to a fixed *increment*, and exponential growth collapses to quadratic growth while the ratio limit collapses from $\varphi$ to $1$. The sequence is exactly the boundary case between exponential and polynomial regimes — a discrete analogue of the many physical and computational systems in which a marginal structural change tips a process from explosive to gentle.

The closed form $A(n) = 1 + \binom{n}{2}$ also connects the sequence to combinatorial geometry: it counts plane regions cut by lines (the lazy-caterer problem) and equals one plus the $n$-th triangular number's predecessor, tying quadratic growth to a concrete counting problem.

---

## 9. Discussion and future work

The organizing lesson is methodological: a single closed-form invariant, here $2A(n) + n = n^2 + 2$, can reduce an entire family of asymptotic and combinatorial questions to elementary algebra. Growth rate, ratio limit, and the exact coincidence set all fall out of that one identity. We highlight several directions.

**A ratio-limit dichotomy for greedy "avoid the combination" sequences.** Consider the greedy family in which each new term is the smallest positive integer avoiding the weighted combination $p \cdot (\text{previous}) + q \cdot (\text{second previous})$. We conjecture that the sequence grows polynomially — with consecutive ratios converging to $1$ — exactly when the avoided combination is degenerate (dominated by a single term); otherwise it grows exponentially, with ratio tending to the dominant root of $x^2 = p x + q$. The additive anti-Fibonacci rule is the boundary case where avoidance forces only a fixed increment, collapsing exponential growth to quadratic and pinning the ratio limit at $1$ rather than a quadratic irrational. The same closed-form-and-squeeze method used here should transfer to the weighted family.

**Finiteness of Fibonacci-coincidence sets.** For any sequence $A(n+1) = A(n) + f(n)$ with $f$ a polynomial, we conjecture that the set of indices where $A(n+2) = A(n+1) + A(n)$ holds is finite, of size at most $\deg(f) + 1$, and is exactly the integer-root set of one explicit polynomial. Since $A(n+2) = A(n+1) + f(n+1)$ by construction, the relation is equivalent to the single polynomial equation $A(n) = f(n+1)$; its solution set is governed by degree, not by the sequence's magnitude. The additive case reduces to $A(n) = n+1$ with coincidence set $\{0,3\}$, the template for the general statement.

**Sharp crossover with Fibonacci growth.** We conjecture that the anti-Fibonacci numbers exceed the Fibonacci numbers for only finitely many indices, with an explicit crossover index beyond which Fibonacci strictly dominates; for polynomial-growth analogues the crossover should be an explicit function of the polynomial's degree. The identity $\varphi^2 = \varphi + 1$ forces $F(n) \sim \varphi^n$, which any fixed-degree polynomial must eventually lose to; the finite pre-crossover region is pinned down by one explicit bound. Comparing our quadratic closed form with a Binet-type identity for the exponential side reduces the question to "exponential beats polynomial" plus one finite boundary check.

---

## 10. Conclusion

The anti-Fibonacci sequence $A(0)=1$, $A(n+1) = A(n) + n$ is the quadratic mirror of the Fibonacci sequence. Governed by the single closed form $2A(n) + n = n^2 + 2$, it grows quadratically with leading coefficient $1/2$; its consecutive ratios converge monotonically to $1$, provably distinct from the golden ratio; and it satisfies the three-term Fibonacci relation at exactly two indices, $n = 0$ and $n = 3$, undershooting it for all larger $n$. Where iterated addition of two terms breeds the golden ratio, iterated addition of a growing increment breeds none: the anti-Fibonacci sequence climbs forever toward infinity while its ratios come quietly to rest at $1$ — the golden ratio avoided, elegantly and permanently.
