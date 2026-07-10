# Real-Rootedness of the Square of the Eulerian Triangle

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

The Eulerian numbers $A(n,k)$ count the permutations of $\{1,\ldots,n\}$
with exactly $k$ descents, and they arrange into the lower-triangular
**Eulerian triangle**. Regarding this triangle as an infinite
lower-triangular matrix and squaring it produces a new triangle with
entries $C(n,k) = \sum_j A(n,j)\,A(j,k)$ and row generating polynomials
$B_n(x) = \sum_k C(n,k)\, x^k$. We study whether squaring preserves
**real-rootedness** — the property that every root of $B_n$ is a real
number, equivalently that $B_n$ factors completely into real linear
factors. We prove that $B_n$ is real-rooted for every $n \le 7$. The
argument reduces real-rootedness to a finite root-separation problem via a
*saturation principle*: a polynomial of degree $m$ possessing $m$ distinct
real roots has exhausted its root budget and therefore splits. Roots are
located by the Intermediate Value Theorem at explicit integer brackets,
with a discriminant argument handling the quadratic row. Each $B_n$ is monic
of degree $n-2$ (for $n \ge 2$) with constant term $n!$, and its roots are
real, negative, and simple. We show that the elementary separation method
reaches its natural boundary at $n = 8$, where two roots share the interval
$(-1,0)$, and we formulate conjectures — full real-rootedness, interlacing
of consecutive rows, a general squaring-preservation closure property, and
root asymptotics — that would settle the phenomenon for all $n$. This places
the Eulerian triangle alongside the Pascal, Stirling, and Narayana
triangles, whose squares are already known to be real-rooted.

## 1. Introduction

A polynomial with real coefficients is **real-rooted** if all of its complex
roots are in fact real. For a polynomial with nonnegative coefficients this
is a strong structural property: by Newton's inequalities it forces the
coefficient sequence to be **log-concave** and **unimodal**. Real-rootedness
of combinatorial generating polynomials is therefore a central theme in
enumerative combinatorics, both as an end in itself and as a route to
inequalities among counting numbers.

Four triangles occupy a classical place in the subject: the **Pascal**
triangle (binomial coefficients), the **Stirling** triangle (Stirling
numbers of the second kind), the **Narayana** triangle (Narayana numbers),
and the **Eulerian** triangle (Eulerian numbers). Each has real-rooted row
polynomials. A finer question asks whether real-rootedness survives natural
*matrix* operations on these triangles. Viewing a triangle as an infinite
lower-triangular matrix $T = (T(n,k))$, its **square** $T^2$ has entries
$(T^2)(n,k) = \sum_j T(n,j)\,T(j,k)$. For the Pascal, Stirling, and Narayana
triangles the square is known to have real-rooted rows. The Eulerian case is
more delicate, because the squared row polynomial is a *nonnegative
combination of Eulerian polynomials* rather than a single Eulerian
polynomial, and nonnegative combinations of real-rooted polynomials are
real-rooted only under compatibility (interlacing) conditions.

This paper establishes the Eulerian case for all rows up to $n = 7$, isolates
the structural principle that drives the proof, and delineates precisely
where the elementary method stops.

## 2. Definitions

**Definition 2.1 (Eulerian numbers).**
The *Eulerian number* $A(n,k)$ is the number of permutations of
$\{1,\ldots,n\}$ having exactly $k$ descents, where a descent of a
permutation $\pi$ is an index $i$ with $\pi(i) > \pi(i+1)$. They satisfy
$A(0,0)=1$ and the recurrence
$$
A(n,k) = (k+1)\,A(n-1,k) + (n-k)\,A(n-1,k-1),
$$
with $A(n,k)=0$ for $k<0$ or $k>n-1$ when $n\ge 1$. Each row satisfies the
symmetry $A(n,k)=A(n,n-1-k)$ and the total $\sum_k A(n,k) = n!$.

The first rows are:

| $n$ | $A(n,0),\,A(n,1),\ldots$ |
|----|--------------------------|
| 0  | 1 |
| 1  | 1 |
| 2  | 1, 1 |
| 3  | 1, 4, 1 |
| 4  | 1, 11, 11, 1 |
| 5  | 1, 26, 66, 26, 1 |
| 6  | 1, 57, 302, 302, 57, 1 |
| 7  | 1, 120, 1191, 2416, 1191, 120, 1 |

**Definition 2.2 (Square of the Eulerian triangle).**
The $(n,k)$ entry of the square of the Eulerian triangle is
$$
C(n,k) = \sum_{j=0}^{n} A(n,j)\, A(j,k).
$$

**Definition 2.3 (Squared row polynomial).**
The $n$-th row generating polynomial of the squared Eulerian triangle is
$$
B_n(x) = \sum_{k} C(n,k)\, x^k \;=\; \sum_{j} A(n,j)\, A_j(x),
$$
where $A_j(x) = \sum_k A(j,k)\, x^k$ is the $j$-th Eulerian polynomial. The
second form exhibits $B_n$ as a nonnegative integer combination of Eulerian
polynomials.

**Definition 2.4 (Real-rootedness).**
A polynomial $p \in \mathbb{R}[x]$ is *real-rooted* if it splits into linear
factors over $\mathbb{R}$; equivalently, all of its roots in $\mathbb{C}$ are
real. We write this predicate as $\mathrm{RealRooted}(p)$.

## 3. Basic structure of the squared rows

**Proposition 3.1 (Shape of $B_n$).**
For $n \ge 2$, the polynomial $B_n$ is monic of degree $n-2$ with constant
term $n!$; all lower coefficients are positive integers.

*Proof sketch.* The constant term is $C(n,0) = \sum_j A(n,j)\,A(j,0) =
\sum_j A(n,j) \cdot 1 = n!$, using $A(j,0)=1$ and the row-sum identity. For
the degree, $A(j,k) \ne 0$ requires $k \le j-1$, and $A(n,j)\ne 0$ requires
$j \le n-1$; the largest $k$ with $C(n,k)\ne 0$ is therefore $k = n-2$,
attained only through $j = n-1$, giving leading coefficient
$A(n,n-1)\,A(n-1,n-2) = 1\cdot 1 = 1$. Positivity of the intermediate
coefficients follows because all $A(n,j),A(j,k)\ge 0$ and each relevant sum
contains a positive term. $\square$

The explicit rows are
$$
\begin{aligned}
B_0 &= 1, \quad B_1 = 1, \quad B_2 = 2, \quad B_3 = x + 6, \\
B_4 &= x^2 + 15x + 24, \\
B_5 &= x^3 + 37x^2 + 181x + 120, \\
B_6 &= x^4 + 83x^3 + 995x^2 + 2163x + 720, \\
B_7 &= x^5 + 177x^4 + 4613x^3 + 23739x^2 + 27133x + 5040.
\end{aligned}
$$

## 4. General real-rootedness engines

Our proof relies on two reusable lemmas of independent interest.

**Lemma 4.1 (Quadratic splitting).**
For real numbers $b, c$ with $b^2 - 4c \ge 0$, the monic quadratic
$x^2 + bx + c$ is real-rooted; explicitly,
$$
x^2 + bx + c = \Bigl(x - \tfrac{-b+s}{2}\Bigr)\Bigl(x - \tfrac{-b-s}{2}\Bigr),
\qquad s = \sqrt{b^2 - 4c}.
$$

*Proof sketch.* With $s = \sqrt{b^2-4c}$ we have $s^2 = b^2-4c \ge 0$. The
two proposed roots $r_\pm = (-b \pm s)/2$ satisfy $r_+ + r_- = -b$ and
$r_+ r_- = (b^2 - s^2)/4 = c$. Expanding $(x-r_+)(x-r_-) = x^2 - (r_++r_-)x
+ r_+r_- = x^2 + bx + c$ gives the factorization, and each linear factor
splits. $\square$

**Lemma 4.2 (Saturation principle: distinct roots force a split).**
Let $p \in \mathbb{R}[x]$ be nonzero of degree $m = \deg p$, and suppose
there is a finite set $S \subseteq \mathbb{R}$ with $|S| = m$ such that
$p(x) = 0$ for every $x \in S$. Then $p$ is real-rooted.

*Proof sketch.* Every element of $S$ is a root of $p$, so $S$ embeds in the
set of distinct real roots of $p$; hence the number of distinct real roots is
at least $|S| = m$. Counted with multiplicity, the number of real roots is at
least the number of distinct ones, and is at most $\deg p = m$. Therefore $p$
has exactly $m$ real roots counted with multiplicity, which equals its
degree, so $p$ splits completely over $\mathbb{R}$. $\square$

Lemma 4.2 is the conceptual heart of the paper: it converts the global
assertion "*all* roots (including complex ones) are real" into the concrete,
finite task of *exhibiting enough distinct real roots*. Those roots are
produced without solving the equation, using the following standard tool.

**Lemma 4.3 (Intermediate Value Theorem, bracketing form).**
Let $g : \mathbb{R} \to \mathbb{R}$ be continuous and $a \le b$.
If $g(a) < 0 < g(b)$ (ascending) or $g(a) > 0 > g(b)$ (descending), then
there exists $x$ with $a < x < b$ and $g(x) = 0$.

*Proof sketch.* Immediate from the Intermediate Value Theorem applied on the
open interval $(a,b)$; the sign change forces the continuous function to
attain the value $0$ strictly between the endpoints. $\square$

## 5. Main theorem

**Theorem 5.1 (Real-rootedness of the squared Eulerian triangle up to $n=7$).**
For every $n \le 7$, the row polynomial $B_n$ of the square of the Eulerian
triangle is real-rooted.

*Proof sketch.* We treat the rows according to degree.

- **Degrees $0$ (rows $n = 0,1,2$).** $B_0 = 1$, $B_1 = 1$, $B_2 = 2$ are
  nonzero constants and split vacuously.

- **Degree $1$ (row $n = 3$).** $B_3 = x + 6$ is linear, hence splits with
  the single root $-6$.

- **Degree $2$ (row $n = 4$).** $B_4 = x^2 + 15x + 24$ has discriminant
  $15^2 - 4\cdot 24 = 129 \ge 0$, so it splits by Lemma 4.1; its roots are
  $(-15 \pm \sqrt{129})/2 \approx -1.82,\, -13.18$.

- **Degrees $3$–$5$ (rows $n = 5,6,7$).** Here we apply the saturation
  principle (Lemma 4.2). Each $B_n$ is a polynomial function of $x$, hence
  continuous. Evaluating at consecutive integers reveals sign changes that
  bracket $\deg B_n = n-2$ distinct real roots via Lemma 4.3; producing
  $\deg B_n$ distinct roots saturates the root budget and forces the split.

  The bracketing integers are, concretely:

  - $B_5 = x^3 + 37x^2 + 181x + 120$: roots in $(-1,0)$, $(-5,-4)$,
    $(-32,-31)$ — approximately $-0.79,\,-4.86,\,-31.35$.
  - $B_6 = x^4 + 83x^3 + 995x^2 + 2163x + 720$: roots in $(-1,0)$,
    $(-3,-2)$, $(-12,-11)$, $(-70,-69)$ — approximately
    $-0.41,\,-2.28,\,-11.28,\,-69.04$.
  - $B_7 = x^5 + 177x^4 + 4613x^3 + 23739x^2 + 27133x + 5040$: roots in
    $(-1,0)$, $(-2,-1)$, $(-5,-4)$, $(-24,-23)$, $(-147,-146)$ —
    approximately $-0.23,\,-1.28,\,-4.87,\,-23.98,\,-146.64$.

  In each case the number of sign changes equals the degree, so all roots are
  real, negative, and simple. $\square$

**Remark 5.2 (Non-vacuity).** The result is not an artifact of trivial or
rational factorizations. For $n \ge 4$ the roots of $B_n$ are irrational (for
$n=4$ they are $(-15\pm\sqrt{129})/2$), so the discriminant and
Intermediate-Value arguments are doing genuine work; the split is not
witnessed by rational linear factors.

## 6. The boundary at $n = 8$

**Proposition 6.1 (Failure of integer separation at $n=8$).**
The polynomial
$$
B_8 = x^6 + 367x^5 + 19563x^4 + 204247x^3 + 546551x^2 + 364395x + 40320
$$
has six real, negative, simple roots, approximately
$$
-0.14,\; -0.79,\; -2.72,\; -9.12,\; -49.19,\; -305.04,
$$
but two of them lie in the single interval $(-1,0)$.

*Consequence.* The consecutive-integer bracketing used in Theorem 5.1 can
detect at most one sign change across $(-1,0)$ and therefore cannot separate
the two roots crowded there. Extending the elementary argument requires finer
(rational) brackets whose existence must be controlled *uniformly in $n$* —
exactly the obstruction that keeps the general statement open. This makes
$n=8$ the precise boundary of the method rather than of the phenomenon: the
roots remain real, but the proof technique changes character.

## 7. Algorithms

We record the computational pipeline underlying the results. All quantities
are exact integers until the final root-location step.

**Algorithm A (Eulerian triangle by recurrence).** Compute $A(n,k)$ for all
$k$ by the recurrence $A(n,k) = (k+1)A(n-1,k) + (n-k)A(n-1,k-1)$, seeded with
$A(0,0)=1$. Complexity: $O(n^2)$ integer operations for all rows up to $n$.

**Algorithm B (Squared entries).** For each $n,k$ form $C(n,k) = \sum_{j}
A(n,j)\,A(j,k)$ by a single pass over the intermediate index $j$. Complexity:
$O(n)$ multiply-adds per entry, $O(n^3)$ for the full triangle up to $n$.

**Algorithm C (Row polynomial and verified separation).** Assemble the
coefficient vector $[C(n,0),\ldots,C(n,n-2)]$ of $B_n$; evaluate $B_n$ at a
descending ladder of integers; record every sign change; and certify
real-rootedness when the number of sign changes equals $\deg B_n$. This is a
*proof-producing* procedure for the rows it succeeds on: each sign change is a
rigorous bracket via Lemma 4.3, and reaching $\deg B_n$ brackets invokes
Lemma 4.2.

## 8. Applications and context

Real-rootedness of $B_n$ immediately yields, by Newton's inequalities, that
the coefficient sequence $C(n,\cdot)$ is log-concave and unimodal — smoothness
statements about the squared-triangle counts that are not evident from their
combinatorial definition. More broadly, the result contributes a data point
toward a *closure principle* for combinatorial triangles under matrix
multiplication:

> Among the four classical triangles (Pascal, Stirling, Narayana, Eulerian),
> the squares of the first three are known to be real-rooted; the present work
> supplies the Eulerian square for all tested rows.

The mechanism most likely to unify these cases is **interlacing**: the roots
of consecutive rows alternate. Interlacing is the algebraic scaffolding that
turns "each summand is real-rooted" into "the nonnegative combination is
real-rooted", and it would allow real-rootedness to propagate by induction.

## 9. Discussion and future work

The proof strategy cleanly separates two concerns: a *soft* structural
reduction (the saturation principle, which is uniform and elementary) and a
*hard* analytic input (locating enough real roots, which currently depends on
row-by-row bracketing). The value of the reduction is that any uniform source
of root separation — an interlacing theorem, a Sturm-sequence bound, or a
recurrence-based argument — would immediately upgrade the finite verification
to a general theorem. The boundary at $n = 8$ identifies exactly what such a
source must overcome: root clusters that escape integer resolution.

We highlight the following directions.

**Conjecture 9.1 (Full real-rootedness).** For every $n$, the squared row
polynomial $B_n$ is real-rooted. Real-rootedness of $B_n$ need not follow from
that of the individual Eulerian polynomials, since $B_n = \sum_j A(n,j)\,A_j$
is a nonnegative combination and such combinations are real-rooted only when
the summands interlace compatibly; the data suggest the Eulerian rows supply
exactly this compatibility. The rows are monic with all roots negative and
simple through degree six, and the only obstruction to a uniform elementary
separation first appears at $n=8$.

**Conjecture 9.2 (Interlacing of consecutive rows).** The roots of $B_n$ and
$B_{n+1}$ interlace: between any two consecutive roots of $B_{n+1}$ lies
exactly one root of $B_n$. A squared triangle inherits a three-term recurrence
in disguise, and interlacing is the structural engine that would propagate
real-rootedness inductively rather than verifying it row by row. The computed
root vectors already exhibit strict interlacing for all tested $n$.

**Conjecture 9.3 (General squaring preservation).** If a lower-triangular
array has real-rooted, interlacing row polynomials with nonnegative entries,
then so does its matrix square. The Pascal, Stirling, and Narayana triangles
already have real-rooted squares, and the Eulerian evidence suggests this is a
closure property of totally-nonnegative, interlacing triangles under
multiplication.

**Conjecture 9.4 (Root asymptotics).** The largest (closest to zero) root of
$B_n$ tends to $0$ and the smallest root grows like $-c\,n^2$ for an explicit
constant $c$, while $\prod(-\text{root}) = n!$. The constant term $n!$ forces
the product of the negated roots to equal $n!$, constraining the geometry of
the root spread across its dynamic range.

## 10. Conclusion

We proved that the row polynomials of the square of the Eulerian triangle are
real-rooted for every $n \le 7$, using a saturation principle that reduces
real-rootedness to explicit real root separation, together with a
discriminant argument for the quadratic row and Intermediate-Value brackets
for the cubic through quintic rows. Each row is monic of degree $n-2$ with
constant term $n!$ and roots that are real, negative, and simple. The
elementary method reaches its natural boundary at $n=8$, where two roots share
the interval $(-1,0)$. The general statement — that squaring the Eulerian
triangle always preserves real-rootedness — remains a compelling conjecture,
best approached through interlacing of consecutive rows and, ultimately, a
unifying closure theorem for multiplication of well-structured combinatorial
triangles.
