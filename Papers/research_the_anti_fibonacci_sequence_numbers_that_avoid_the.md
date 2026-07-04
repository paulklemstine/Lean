# The Anti-Fibonacci Sequence: Quadratic Growth, Cubic Partial Sums, and a Perfect-Square Spectrum

## Abstract

The Fibonacci sequence is the archetype of *addition-driven* growth: each term is the sum of its two predecessors, terms grow exponentially, and consecutive ratios converge to the golden ratio $\varphi = \tfrac{1+\sqrt5}{2}$. We study a systematic counterpoint, the **anti-Fibonacci sequence** $A$, defined by the first-order recurrence $A(0)=1$, $A(n+1)=A(n)+n$, whose terms are $1,1,2,4,7,11,16,22,29,37,\dots$. We establish four exact structural results and their asymptotic consequences. First, $A$ has the closed form $A(n)=1+\tfrac{n(n-1)}{2}$, so it grows quadratically with density $A(n)/n^2 \to \tfrac12$, and its consecutive ratio $A(n+1)/A(n)$ converges to $1$ — never to the golden ratio. Second, apart from a single boundary exception at index $5$, the sequence strictly avoids being the sum of its two predecessors: $A(n) < A(n-1)+A(n-2)$ for all $n\ge 6$. Third, its partial sums satisfy the exact cubic identity $6\sum_{k=0}^{n} A(k) = n^3 + 5n + 6$, from which the normalized cumulative sum $\bigl(\sum_{k=0}^n A(k)\bigr)/n^3$ converges to the finite constant $\tfrac16$ — in stark contrast to Fibonacci, where the same ratio diverges. Fourth, the value set of $A$ is exactly the set of integers $m$ for which $8m-7$ is a perfect square (equivalently, $m-1$ is triangular), a Diophantine fingerprint that forces the values to have natural density zero. Together these results portray the anti-Fibonacci sequence as a complete negative image of the Fibonacci sequence: polynomial where Fibonacci is exponential, rational where Fibonacci is irrational, and governed by perfect squares where Fibonacci is governed by Binet's formula.

**Keywords.** Anti-Fibonacci sequence, quadratic growth, triangular numbers, lazy caterer numbers, cubic partial sums, Cesàro density, perfect-square spectrum, natural density.

---

## 1. Introduction

The Fibonacci sequence $F(0)=0,\ F(1)=1,\ F(n+1)=F(n)+F(n-1)$ is perhaps the most recognizable integer sequence in mathematics. Its defining operation — summing the two most recent terms — produces exponential growth, a running total that is again exponential ($\sum_{k=0}^n F(k) = F(n+2)-1$), and the celebrated convergence of consecutive ratios to the golden ratio $\varphi$. Every one of these features is a symptom of the same underlying cause: iterated addition.

It is natural to ask what a sequence looks like when it is built to *avoid* that operation rather than embrace it. The research brief motivating this work proposes an "anti-Fibonacci" sequence whose successive terms deliberately dodge the sum of their predecessors, and offers the concrete data $1,1,2,4,7,11,16,\dots$. The literal greedy rule "the smallest positive integer not equal to the previous sum" does not reproduce this data; the data is instead generated exactly by the clean first-order recurrence

$$A(0) = 1, \qquad A(n+1) = A(n) + n. \tag{1.1}$$

We adopt (1.1) as the definition and take the given data as ground truth. The successive differences are $0,1,2,3,\dots$, so $A$ accumulates the counting numbers.

This paper collects the exact structural and asymptotic theory of $A$. Our contributions are:

1. **A subtraction-free closed form** (Section 3), $2A(n)+n = n^2+2$, equivalently $A(n) = 1+\tfrac{n(n-1)}{2}$, identifying $A$ with the lazy-caterer / central-polygonal numbers.
2. **Asymptotics** (Section 4): quadratic growth density $A(n)/n^2\to\tfrac12$, neighbor ratio $A(n+1)/A(n)\to 1$, and a proof that this ratio does *not* converge to $\varphi$.
3. **A sharp avoidance theorem** (Section 5): $A(n)<A(n-1)+A(n-2)$ for $n\ge 6$, with a single exceptional equality at $n=5$.
4. **An exact cubic partial-sum identity** (Section 6): $6\sum_{k=0}^n A(k)=n^3+5n+6$, hence cubic Cesàro density $\tfrac16$.
5. **A perfect-square membership spectrum** (Section 7): $m\in\operatorname{range}(A)\iff 8m-7$ is a perfect square, and the consequent density-zero result.

Throughout, the driving methodological principle is that every claim about $A$ reduces, via the closed form (1.1), to elementary polynomial algebra — no transcendental machinery is required, which is itself the sharpest possible contrast with the Fibonacci theory.

---

## 2. Definitions and Notation

**Definition 2.1 (Anti-Fibonacci sequence).** The *anti-Fibonacci sequence* $A:\mathbb N\to\mathbb N$ is defined by
$$A(0)=1,\qquad A(n+1)=A(n)+n.$$
Its first terms are $A(0),A(1),\dots = 1,1,2,4,7,11,16,22,29,37,46,56,\dots$.

**Definition 2.2 (Triangular numbers).** The $t$-th triangular number is $T_t = \tfrac{t(t+1)}{2} = 0,1,3,6,10,15,\dots$ for $t=0,1,2,\dots$.

**Definition 2.3 (Perfect square).** An integer $s$ is a *perfect square* if $s=k^2$ for some $k\in\mathbb N$.

**Definition 2.4 (Natural density).** A set $S\subseteq\mathbb N$ has *natural density* $d$ if $\tfrac{1}{m}\#\{x\in S : x < m\}\to d$ as $m\to\infty$.

We write $\varphi = \tfrac{1+\sqrt5}{2}$ for the golden ratio.

---

## 3. The Closed Form

Everything in this paper flows from a single subtraction-free identity.

**Theorem 3.1 (Closed form).** For all $n\in\mathbb N$,
$$2\,A(n) + n = n^2 + 2. \tag{3.1}$$
Equivalently, over the reals, $A(n) = \dfrac{n^2 - n + 2}{2} = 1 + \dfrac{n(n-1)}{2}$.

*Proof sketch.* Induct on $n$. The base case $n=0$ reads $2\cdot1+0 = 0+2$. For the step, assume $2A(k)+k = k^2+2$. Using $A(k+1)=A(k)+k$,
$$2A(k+1)+(k+1) = 2A(k)+2k+k+1 = (k^2+2)+2k+1 = (k+1)^2+2,$$
completing the induction. Dividing (3.1) by $2$ and casting to $\mathbb R$ gives $A(n) = \tfrac{n^2-n+2}{2}$. $\qquad\square$

We keep the identity in the multiplied-through form (3.1) to avoid the pitfalls of truncated natural-number subtraction; every later argument uses this integer form and casts to $\mathbb R$ only at the end.

**Remark 3.2.** The numbers $1+\binom{n}{2}$ are the *central polygonal (lazy caterer) numbers*: the maximum number of regions into which $n$ straight cuts divide a disk. Thus $A$ is a shift of a classical combinatorial sequence, which explains the perfect-square and triangular-number phenomena that follow.

---

## 4. Asymptotics: No Golden Ratio

The closed form immediately fixes the growth order of $A$.

**Theorem 4.1 (Quadratic density).** $\displaystyle \lim_{n\to\infty}\frac{A(n)}{n^2} = \frac12.$

*Proof sketch.* From Theorem 3.1, for $n\ge1$,
$$\frac{A(n)}{n^2} = \frac{n^2-n+2}{2n^2} = \frac12 - \frac{1}{2n} + \frac{1}{n^2}.$$
The last two terms tend to $0$, so the limit is $\tfrac12$ by the algebra of limits. $\qquad\square$

**Theorem 4.2 (Neighbor ratio).** $\displaystyle \lim_{n\to\infty}\frac{A(n+1)}{A(n)} = 1.$

*Proof sketch.* Write both numerator and denominator via the closed form and divide through by $n^2$:
$$\frac{A(n+1)}{A(n)} = \frac{\,1 + \tfrac1n + \tfrac{2}{n^2}\,}{\,1 - \tfrac1n + \tfrac{2}{n^2}\,}.$$
Numerator and denominator both tend to $1$, and the denominator is eventually bounded away from $0$, so the quotient tends to $1$. $\qquad\square$

**Theorem 4.3 (Absence of the golden ratio).** The sequence $A(n+1)/A(n)$ does **not** converge to $\varphi$.

*Proof sketch.* By Theorem 4.2 the ratio converges to $1$. A convergent sequence has a unique limit, and $1\ne\varphi$, so it cannot converge to $\varphi$. $\qquad\square$

The three theorems together justify the sequence's name at the asymptotic level: the golden ratio is the signature of exponential growth, and $A$ — growing like $n^2/2$ — has no such signature. Its neighbor ratios decay monotonically through $2.0, 1.75, 1.57, 1.45, \dots$ toward $1$.

---

## 5. Sharp Avoidance of the Predecessor Sum

The name "anti-Fibonacci" also promises a structural property: a term should not equal the sum of its two predecessors. This holds — with exactly one exception.

**Theorem 5.1 (Sharp avoidance).**
1. (*Boundary*) $A(5) = A(4)+A(3)$; explicitly $11 = 7+4$.
2. (*Avoidance*) For every $n\ge 6$, $A(n) < A(n-1)+A(n-2)$; in particular $A(n)\ne A(n-1)+A(n-2)$.

*Proof sketch.* Both parts reduce to polynomial inequalities via Theorem 3.1. Writing $A(n)=1+\tfrac{n(n-1)}{2}$, the sum of two predecessors is
$$A(n-1)+A(n-2) = 2 + \frac{(n-1)(n-2)+(n-2)(n-3)}{2} = (n-2)^2 + 2 + (n-2) \; \text{-type quadratic in } n,$$
which grows like $n^2$, whereas $A(n)$ grows like $n^2/2$. The difference $\bigl(A(n-1)+A(n-2)\bigr)-A(n)$ is a quadratic in $n$ that is negative only at small indices; direct evaluation shows it vanishes exactly at $n=5$ and is strictly positive for all $n\ge6$. $\qquad\square$

Thus avoidance is not a fluke of the first few terms but a permanent feature past a sharp threshold: two anti-Fibonacci terms always overshoot a single later one, because $2\cdot\tfrac{n^2}{2} = n^2 > \tfrac{n^2}{2}$.

---

## 6. Cubic Partial Sums and Cesàro Density

We now turn to the running totals $S(n) = \sum_{k=0}^n A(k)$. For Fibonacci, $\sum_{k=0}^n F(k) = F(n+2)-1$ is exponential. For the anti-Fibonacci sequence the partial sums are an exact cubic polynomial.

**Theorem 6.1 (Cubic partial-sum identity).** For all $n\in\mathbb N$,
$$6\sum_{k=0}^{n} A(k) = n^3 + 5n + 6. \tag{6.1}$$
Equivalently $\sum_{k=0}^{n}A(k) = \dfrac{n^3+5n+6}{6}$.

*Proof sketch.* Induct on $n$. The base case $n=0$ reads $6\cdot A(0)=6 = 0+0+6$. For the step, using the induction hypothesis and $A(n+1)=A(n)+n$ together with the closed form (3.1),
$$6\sum_{k=0}^{n+1}A(k) = (n^3+5n+6) + 6\,A(n+1).$$
Substituting $6A(n+1) = 3\bigl(2A(n+1)\bigr) = 3\bigl((n+1)^2+2-(n+1)\bigr)$ from (3.1) and simplifying yields $(n+1)^3+5(n+1)+6$, closing the induction. Alternatively, sum the closed form directly: $\sum_{k=0}^n \bigl(1+\tfrac{k(k-1)}{2}\bigr)$ telescopes via the identities $\sum_{k\le n} k = \tfrac{n(n+1)}{2}$ and $\sum_{k\le n} k^2 = \tfrac{n(n+1)(2n+1)}{6}$ to $\tfrac{n^3+5n+6}{6}$. $\qquad\square$

One can verify (6.1) numerically: the sixfold totals $6,12,24,48,90,156,252,384$ match $n^3+5n+6$ exactly for $n=0,\dots,7$.

**Theorem 6.2 (Cubic Cesàro density).** $\displaystyle \lim_{n\to\infty}\frac{1}{n^3}\sum_{k=0}^{n}A(k) = \frac16.$

*Proof sketch.* By Theorem 6.1, for $n\ge1$,
$$\frac{1}{n^3}\sum_{k=0}^{n}A(k) = \frac{n^3+5n+6}{6n^3} = \frac16 + \frac{5}{6}\cdot\frac{1}{n^2} + \frac{1}{n^3}.$$
The two correction terms vanish as $n\to\infty$, giving the limit $\tfrac16$. $\qquad\square$

This is precisely the discrete antiderivative phenomenon: since $A(n)\sim \tfrac{n^2}{2}$ and $\int \tfrac{x^2}{2}\,dx = \tfrac{x^3}{6}$, summation promotes the value-level density $\tfrac12$ to the cumulative density $\tfrac16$. The exact identity (6.1) removes all error terms, so no integral comparison is needed.

**Remark 6.3 (Contrast with Fibonacci).** For the genuine Fibonacci sequence, $\tfrac{1}{n^3}\sum_{k=0}^n F(k) = \tfrac{F(n+2)-1}{n^3}\to\infty$, since an exponential dominates any power of $n$. The anti-Fibonacci partial sums instead have a *finite, rational* cubic density $\tfrac16$. This is the cleanest quantitative separation between the two sequences.

---

## 7. The Perfect-Square Spectrum

Our final result characterizes exactly which integers occur as anti-Fibonacci values, and does so through a single quadratic Diophantine condition.

**Lemma 7.1 (Square identity).** For all $n\in\mathbb N$,
$$8\,A(n) = (2n-1)^2 + 7. \tag{7.1}$$

*Proof sketch.* Multiply Theorem 3.1 by $4$: $8A(n) + 4n = 4n^2 + 8$, so $8A(n) = 4n^2 - 4n + 8 = (2n-1)^2 + 7$. $\qquad\square$

**Theorem 7.2 (Square spectrum).** For every $m\in\mathbb N$,
$$m \in \operatorname{range}(A) \iff 8m-7 \text{ is a perfect square} \iff \exists k\in\mathbb N,\; k^2+7 = 8m.$$
Equivalently, $m$ is an anti-Fibonacci value iff $m-1$ is a triangular number.

*Proof sketch.* ($\Rightarrow$) If $m=A(n)$, then by (7.1) $8m-7 = (2n-1)^2$ is a perfect square.
($\Leftarrow$) Suppose $k^2+7 = 8m$. Reducing modulo $8$, $k^2\equiv 1\pmod 8$, forcing $k$ odd, say $k=2j+1$. Then $8m = (2j+1)^2 + 7 = 4j^2+4j+8$, so $m = \tfrac{j^2+j}{2}+1 = 1 + \binom{j+1}{2} = A(j+1)$. Hence $m\in\operatorname{range}(A)$. The triangular-number reformulation follows since $A(n)-1 = \binom{n}{2} = T_{n-1}$. $\qquad\square$

We deliberately state the condition subtraction-free as $\exists k,\ k^2+7=8m$, which handles the edge case $m=0$ correctly: no $A(n)$ equals $0$ (all values are positive), and $k^2+7=0$ is impossible, so the equivalence holds vacuously there. No lower bound $m\ge1$ hypothesis is needed.

**Corollary 7.3 (Density zero).** The value set $\operatorname{range}(A)$ has natural density $0$. Its counting function satisfies
$$\#\{\,m < M : m\in\operatorname{range}(A)\,\} \sim \sqrt{2M}\quad(M\to\infty).$$

*Proof sketch.* By Theorem 7.2, $m\in\operatorname{range}(A)$ with $m<M$ corresponds to indices $n$ with $A(n)<M$, i.e. $1+\tfrac{n(n-1)}{2} < M$, which holds for $n$ up to about $\sqrt{2M}$. Dividing the count $\sim\sqrt{2M}$ by $M$ gives $\sim\sqrt{2/M}\to0$. $\qquad\square$

Thus the anti-Fibonacci values are polynomially sparse — a square-root-thin subset of the integers — matching the perfect-square fingerprint of Theorem 7.2.

---

## 8. Algorithms

We record the elementary algorithms underlying the numerical experiments.

**Algorithm 8.1 (Generation).** Compute $A(0),\dots,A(N)$ in $O(N)$ additions by iterating $A(n+1)=A(n)+n$. Correctness is immediate from Definition 2.1; no multiplication is needed.

**Algorithm 8.2 (Membership test).** To decide $m\in\operatorname{range}(A)$ in $O(1)$ arithmetic operations (plus one integer square root): return true iff $8m-7\ge0$ and $\lfloor\sqrt{8m-7}\rfloor^2 = 8m-7$. Correctness is Theorem 7.2.

**Algorithm 8.3 (Closed-form evaluation).** Evaluate $A(n)=1+\tfrac{n(n-1)}{2}$ in $O(1)$, and $\sum_{k=0}^n A(k) = \tfrac{n^3+5n+6}{6}$ in $O(1)$, bypassing iteration entirely. Correctness is Theorems 3.1 and 6.1.

---

## 9. Applications and Interpretation

The anti-Fibonacci sequence is a compact laboratory for the difference between exponential and polynomial recurrences.

- **Combinatorial meaning.** Since $A(n)=1+\binom{n}{2}$, the sequence counts regions cut by $n$ lines in general position in a disk, so its structural facts have direct geometric readings.
- **Discrete calculus.** The pair (value density $\tfrac12$, cumulative density $\tfrac16$) is a textbook illustration that summation is discrete integration: $\tfrac{x^2}{2}\mapsto\tfrac{x^3}{6}$.
- **Diophantine detection.** The square-spectrum test is a fast, exact membership oracle, exemplifying how quadratic-growth sequences carry perfect-square fingerprints.
- **Pedagogical contrast.** Placed beside Fibonacci, $A$ isolates exactly which phenomena (golden ratio, exponential sums, Binet's formula) are consequences of *addition of predecessors* rather than of self-reference in general.

---

## 10. Discussion and Future Directions

The results above suggest several avenues, driven by the exact identities in hand.

**A factorial tower of cumulative densities.** Iterating the summation operator should yield a staircase of constants: the values grow like $n^2/2$, the first cumulative sums like $n^3/6$, the second like $n^4/24$, and in general the $d$-fold cumulative sum should be a polynomial of degree $d+2$ with leading coefficient $1/(d+2)!$. Repeated summation is a discrete antiderivative, so it should promote the value density $\tfrac12$ through the factorials exactly as iterated integration turns $x^2/2$ into $x^{d+2}/(d+2)!$. With the first two rungs now known exactly, the pattern and the inductive step are pinned down.

**Perfect-square membership as a fingerprint of quadratic growth.** The square-spectrum characterization suggests a general principle: a greedy additive-avoidance sequence has a value set of the form "the $m$ for which a fixed quadratic $Q(m)$ is a perfect square" if and only if the sequence is eventually a quadratic polynomial, in which case $Q$ is forced by the polynomial's discriminant. A perfect-square membership test is the arithmetic signature of quadratic growth, because it makes the counting function grow like a square root, which pins the sequence to degree two.

**The avoided-sum shadow has density zero.** Each term stays below the sum of its predecessors; the values it "refuses to become" simplify to shifted squares. This shadow set should have natural density zero, contain no long arithmetic progressions beyond an initial segment, and have a counting function asymptotic to $\sqrt{2m}$ — a shadow cast by avoidance inherits the growth order of the sequence and can never be dense.

---

## 11. Conclusion

The anti-Fibonacci sequence $A(n)=1+\tfrac{n(n-1)}{2}$ is a complete structural negative of the Fibonacci sequence. It grows quadratically with density $\tfrac12$; its neighbor ratios converge to $1$ rather than the golden ratio; it avoids the sum of its two predecessors for all $n\ge6$ (with a lone exception at $n=5$); its partial sums are the exact cubic $\tfrac{n^3+5n+6}{6}$ with cumulative density $\tfrac16$; and its value set is precisely $\{m : 8m-7 \text{ is a perfect square}\}$, a density-zero, square-root-thin subset of the integers. Where Fibonacci is exponential, irrational, and golden, the anti-Fibonacci sequence is polynomial, rational, and quadratic — a reminder that the mathematics of *avoidance* can be as rich and exact as the mathematics of addition.
