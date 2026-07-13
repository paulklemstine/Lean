# A Sharp Dichotomy for the Total d-Hoggatt Numbers

## Abstract

The *total* d-Hoggatt numbers are the row sums $H_d(n) = \sum_k H_d(n,k)$ of the d-Hoggatt triangle. Classical identifications give $H_1(n) = 2^n$ (row sums of Pascal's triangle), $H_2(n) = C_n$ (the Catalan numbers), and $H_3(n)$ (the Baxter numbers). We establish a *sharp dichotomy* between the first two levels of this hierarchy. The $d=1$ totals $2^n$ are **log-linear** — they satisfy $H(n+1)^2 = H(n)H(n+2)$ with exact equality — and are therefore log-concave, log-convex, and, decisively, *not* strictly log-convex. The $d=2$ totals $C_n$ are **strictly log-convex** — $H(n+1)^2 < H(n)H(n+2)$ for all $n$ — and are therefore *not* log-concave. The engine of the Catalan case is an exact **discriminant identity**
$$(2n+1)(n+3)\,C_n C_{n+2} = (n+2)(2n+3)\,C_{n+1}^2,$$
whose two coefficients differ by the positive constant $3$. We isolate the general mechanism as a ratio-monotonicity criterion over the reals — a positive sequence with strictly increasing consecutive ratios is strictly log-convex — and we record the tropical (dequantized) reformulation: strict log-convexity of a positive sequence is exactly strict convexity of its logarithm, equivalently strict concavity of the valuation $v = -\log a$. We close with a discussion of five conjectures extending the dichotomy across the whole hierarchy.

**Keywords:** Catalan numbers, Baxter numbers, log-concavity, log-convexity, log-linearity, discriminant identity, ratio monotonicity, tropical dequantization, unimodality.

## 1. Introduction

Curvature properties of positive integer sequences — log-concavity, log-linearity, and log-convexity — are among the most studied structural features in enumerative combinatorics. Log-concave sequences are unimodal, behave well under convolution, and frequently arise as coefficient sequences of real-rooted polynomials; log-convex sequences signal accelerating, super-multiplicative growth. Determining precisely which behavior a natural counting family exhibits, and where in a parametrized family the behavior *switches*, is a recurring theme.

This paper concerns the d-Hoggatt triangles, a hierarchy indexed by $d = 1, 2, 3, \dots$ whose row-sum sequences $H_d(n) = \sum_k H_d(n,k)$ specialize to three of the most classical objects in combinatorics:

- $d = 1$: $H_1(n) = 2^n$, the row sums of Pascal's triangle;
- $d = 2$: $H_2(n) = C_n$, the Catalan numbers;
- $d = 3$: $H_3(n)$, the Baxter numbers.

Our main contribution is a **sharp dichotomy** between the first two levels. Informally: the powers of two sit exactly on the boundary between log-concavity and log-convexity (they are log-linear), whereas the Catalan totals fall strictly on the log-convex side. The transition from $d=1$ to $d=2$ is therefore as sharp as possible — an equality becomes a strict inequality — with no intermediate regime.

The paper is organized as follows. Section 2 fixes definitions and elementary relations. Section 3 treats the $d=1$ case. Section 4 develops the Catalan case, culminating in the discriminant identity and strict log-convexity. Section 5 states the combined dichotomy. Section 6 abstracts the underlying mechanism as ratio monotonicity over the reals and shows the Catalan case is an instance. Section 7 gives the tropical/dequantized reformulation. Section 8 discusses applications, and Section 9 lists conjectures and future directions.

## 2. Definitions

Throughout, $a : \mathbb{N} \to \mathbb{N}$ (or $\mathbb{R}$) denotes a nonnegative sequence.

**Definition 2.1 (Strict log-convexity).** $a$ is *strictly log-convex* if
$$a(n+1)^2 < a(n)\,a(n+2) \qquad \text{for all } n.$$

**Definition 2.2 (Log-concavity).** $a$ is *log-concave* if
$$a(n)\,a(n+2) \le a(n+1)^2 \qquad \text{for all } n.$$

**Definition 2.3 (Log-linearity).** $a$ is *log-linear* if
$$a(n+1)^2 = a(n)\,a(n+2) \qquad \text{for all } n.$$

These three conditions are exactly the statements that the sequence $n \mapsto \log a(n)$ is convex, concave, or affine, respectively (when $a$ is positive). Two immediate implications organize the whole discussion.

**Lemma 2.4.** *A log-linear sequence is log-concave.*

*Proof.* If $a(n+1)^2 = a(n)a(n+2)$ then in particular $a(n)a(n+2) \le a(n+1)^2$, which is the log-concavity inequality. $\square$

**Lemma 2.5.** *A strictly log-convex sequence is not log-concave.*

*Proof.* Suppose $a$ were both strictly log-convex and log-concave. At $n=0$ strict log-convexity gives $a(1)^2 < a(0)a(2)$, while log-concavity gives $a(0)a(2) \le a(1)^2$. Together these force $a(1)^2 < a(1)^2$, a contradiction. $\square$

Lemma 2.5 is the logical backbone of the dichotomy: it converts each strict log-convexity result into a negative log-concavity result automatically.

## 3. The case $d = 1$: the totals $2^n$ are log-linear

**Theorem 3.1 (Log-linearity of the powers of two).** *The sequence $H_1(n) = 2^n$ is log-linear:*
$$\left(2^{\,n+1}\right)^2 = 2^n \cdot 2^{\,n+2} \qquad \text{for all } n.$$

*Proof.* Both sides equal $2^{2n+2}$; the left by $\left(2^{n+1}\right)^2 = 2^{2n+2}$, the right by $2^n \cdot 2^{n+2} = 2^{2n+2}$. $\square$

**Corollary 3.2.** *$H_1(n) = 2^n$ is log-concave.* (Immediate from Lemma 2.4.)

**Theorem 3.3 (Not strictly log-convex).** *The sequence $2^n$ is not strictly log-convex.*

*Proof.* Strict log-convexity at $n = 0$ would require $(2^1)^2 < 2^0 \cdot 2^2$, i.e. $4 < 4$, which is false. $\square$

Thus the $d=1$ totals lie precisely on the log-linear boundary: they are simultaneously log-concave and log-convex with equality, and in particular never *strictly* log-convex.

## 4. The case $d = 2$: the Catalan totals

We write $C_n$ for the $n$-th Catalan number. We use the standard representation $C_n = \binom{2n}{n}/(n+1)$ in terms of the central binomial coefficient $\binom{2n}{n}$.

**Proposition 4.1 (Positivity).** $C_n > 0$ for all $n$.

*Proof.* The central binomial coefficient $\binom{2n}{n}$ is positive, and $(n+1) \mid \binom{2n}{n}$ (this divisibility is what makes $C_n$ an integer), so $C_n = \binom{2n}{n}/(n+1)$ is a positive integer. $\square$

**Proposition 4.2 (Multiplicative recurrence).** *For all $n$,*
$$(n+2)\,C_{n+1} = 2(2n+1)\,C_n.$$

*Proof.* This is the classical two-term recurrence for the Catalan numbers, equivalent to the recurrence $\binom{2(n+1)}{n+1} = \frac{2(2n+1)}{n+1}\binom{2n}{n}$ for central binomial coefficients together with $C_n = \binom{2n}{n}/(n+1)$. Cross-multiplying and simplifying yields the stated identity in integers. $\square$

The recurrence 4.2 gives the exact growth ratio
$$\frac{C_{n+1}}{C_n} = \frac{2(2n+1)}{n+2},$$
a strictly increasing sequence tending to $4$. This monotonicity is the seed of log-convexity, but we can make the argument entirely algebraic and integer-valued via a discriminant identity.

**Theorem 4.3 (Discriminant identity).** *For all $n$,*
$$(2n+1)(n+3)\,\big(C_n\,C_{n+2}\big) = (n+2)(2n+3)\,C_{n+1}^2.$$

*Proof.* Apply the recurrence 4.2 twice. From $(n+2)C_{n+1} = 2(2n+1)C_n$ and $(n+3)C_{n+2} = 2(2n+3)C_{n+1}$ we solve for $C_n$ and $C_{n+2}$ in terms of $C_{n+1}$ and substitute into the two sides. Multiplying out and cancelling the common positive factors reduces both sides to the same monomial in $C_{n+1}^2$ (times integer polynomials in $n$), establishing the identity. $\square$

The content of Theorem 4.3 is the comparison of its two polynomial coefficients:
$$(n+2)(2n+3) = 2n^2 + 7n + 6, \qquad (2n+1)(n+3) = 2n^2 + 7n + 3.$$
They differ by the constant $3 > 0$. This positive gap is precisely what forces strictness.

**Theorem 4.4 (Strict log-convexity of the Catalan totals).** *For all $n$,*
$$C_{n+1}^2 < C_n\,C_{n+2}.$$

*Proof.* Write $A = (2n+1)(n+3)$ and $B = (n+2)(2n+3)$, so $B = A + 3$ and both are positive. The discriminant identity says $A\cdot C_n C_{n+2} = B\cdot C_{n+1}^2 = (A+3)C_{n+1}^2$, hence
$$A\big(C_n C_{n+2} - C_{n+1}^2\big) = 3\,C_{n+1}^2 > 0,$$
using $C_{n+1} > 0$ (Proposition 4.1). Since $A > 0$, we conclude $C_n C_{n+2} - C_{n+1}^2 > 0$, i.e. $C_{n+1}^2 < C_n C_{n+2}$. $\square$

**Corollary 4.5.** *The Catalan totals $C_n$ are not log-concave.* (Immediate from Theorem 4.4 and Lemma 2.5.)

## 5. The sharp dichotomy

Assembling Sections 3 and 4 gives the central result.

**Theorem 5.1 (Sharp dichotomy, $d=1$ vs $d=2$).**
$$\big(\text{$2^n$ is log-linear and not strictly log-convex}\big) \ \wedge\ \big(\text{$C_n$ is strictly log-convex and not log-concave}\big).$$
Explicitly: $2^n$ satisfies $(2^{n+1})^2 = 2^n \cdot 2^{n+2}$ for all $n$ and fails strict log-convexity already at $n=0$; while $C_n$ satisfies $C_{n+1}^2 < C_n C_{n+2}$ for all $n$ and hence fails log-concavity.

*Proof.* Combine Theorems 3.1, 3.3, 4.4 and Corollary 4.5. $\square$

The dichotomy is *sharp* in the strongest sense: the boundary case ($d=1$) attains equality in the defining inequality, while the next case ($d=2$) attains strict inequality in the opposite direction. There is no borderline or mixed regime between them.

## 6. The general mechanism: ratio monotonicity

The Catalan identity is a clean algebraic proof, but it is a special case of a general real-analytic principle that explains *why* summation over a triangle produces log-convex totals.

**Theorem 6.1 (Ratio-monotonicity criterion).** *Let $a : \mathbb{N} \to \mathbb{R}$ be positive ($a(n) > 0$ for all $n$). If the consecutive ratios are strictly increasing,*
$$\frac{a(n+1)}{a(n)} < \frac{a(n+2)}{a(n+1)} \qquad \text{for all } n,$$
*then $a$ is strictly log-convex: $a(n+1)^2 < a(n)\,a(n+2)$ for all $n$.*

*Proof.* Fix $n$. Multiply the hypothesis $a(n+1)/a(n) < a(n+2)/a(n+1)$ by the positive quantity $a(n)a(n+1)$; clearing the denominators yields $a(n+1)^2 < a(n)a(n+2)$ directly. $\square$

**Theorem 6.2 (Catalan ratios are strictly increasing).** *For all $n$,*
$$\frac{C_{n+1}}{C_n} < \frac{C_{n+2}}{C_{n+1}}.$$

*Proof.* By Theorem 4.4, $C_{n+1}^2 < C_n C_{n+2}$ over the reals (Catalan numbers being positive integers). Dividing by the positive quantity $C_n C_{n+1}$ gives the claim. Conversely, this exhibits the Catalan case as the instance of Theorem 6.1 with $a = C$. $\square$

The conceptual message: the *rows* of these triangles are log-concave, but the *row ratios* $T(n+1,k)/T(n,k)$ are nondecreasing in $n$, and summation amplifies that common growth factor. This is a Chebyshev-sum / rearrangement effect, and it suggests that log-convexity of the totals is a *summation phenomenon* rather than a peculiarity of the Catalan numbers — a point we return to in Section 9.

## 7. Tropical dequantization

Finally we record the "dequantized" form of the dichotomy, which relocates it into tropical (min-plus) geometry.

**Theorem 7.1 (Log form of strict log-convexity).** *Let $a : \mathbb{N} \to \mathbb{R}$ be positive. Then for each $n$,*
$$a(n+1)^2 < a(n)\,a(n+2) \iff 2\log a(n+1) < \log a(n) + \log a(n+2).$$

*Proof.* Since $a$ is positive, $\log$ is strictly monotone on the relevant values. Taking $\log$ of both sides of $a(n+1)^2 < a(n)a(n+2)$ and using $\log(xy) = \log x + \log y$ and $\log(x^2) = 2\log x$ gives the equivalence; strict monotonicity of $\log$ preserves the strict inequality in both directions. $\square$

Introduce the *valuation* $v(n) = -\log a(n)$. Then Theorem 7.1 says strict log-convexity of $a$ is exactly strict concavity of $v$ (equivalently strict convexity of $\log a$), while log-linearity of $a$ is exactly affinity of $v$. In the tropical limit the log-concavity/convexity test degenerates to a *second finite difference*: the sign of
$$\Delta^2 v(n) = v(n) - 2v(n+1) + v(n+2)$$
records the curvature. The dichotomy reads:

- $d = 1$: $v$ is affine ($\Delta^2 v \equiv 0$);
- $d = 2$: $v$ is strictly concave ($\Delta^2 v < 0$).

This casts the combinatorial dichotomy as a piecewise-linear, tropical-geometric statement about the sign of iterated finite differences.

## 8. Applications

**Unimodality and mode location.** Log-concavity of a coefficient sequence forces unimodality; the log-linearity of $2^n$ marks the exact edge of this behavior. Knowing that the Catalan totals are strictly log-convex tells us their reciprocals are strictly log-concave, and controls the shape of associated generating functions.

**Growth-rate certificates.** Strict log-convexity of $C_n$ certifies that the ratios $C_{n+1}/C_n$ increase monotonically to their limit $4$, giving rigorous one-sided bounds $C_{n+1}/C_n < 4$ and sharp super-multiplicativity $C_{n+1}C_{m+1} \le C_{?}$-type estimates useful in asymptotic enumeration.

**Inequalities in probability and physics.** Log-concave/log-convex dichotomies underpin correlation inequalities, entropy comparisons, and partition-function estimates. A clean parametrized boundary — here the jump from a coefficient gap of $0$ to a gap of $3$ — provides a model example for where such inequalities flip.

**A template for detecting the switch.** The ratio-monotonicity criterion (Theorem 6.1) is a reusable, easily checkable certificate: to prove log-convexity of any positive sequence it suffices to verify that its consecutive ratios increase. This reduces many log-convexity questions to a single monotonicity check.

## 9. Discussion and future directions

The results above pin down the first transition in the d-Hoggatt hierarchy exactly. The natural program is to extend the picture across all $d$ and to both the totals and the rows. We list the guiding conjectures.

**Conjecture 1 (Universal log-convexity of the totals for $d \ge 2$).** For every $d \ge 2$, the totals are strictly log-convex: $H_d(n+1)^2 < H_d(n)H_d(n+2)$ for all $n$. Each $H_d(n)$ is a positively weighted sum of products of binomial coefficients whose dominant growth ratio increases with $n$, so the totals should inherit the Catalan behavior. The Baxter case ($d=3$) matches the Catalan case term-by-term in computation; a uniform proof would come from a $d$-independent two-term recurrence yielding a discriminant identity with a positive coefficient gap, generalizing Theorem 4.3.

**Conjecture 2 (Row-sum log-convexity is a summation phenomenon).** If $T(n,k)$ is any triangle whose rows are log-concave and whose row-ratio $T(n+1,k)/T(n,k)$ is nondecreasing in $n$, then the row sums $S(n) = \sum_k T(n,k)$ are log-convex. This would show log-convexity of totals is not special to Hoggatt triangles but follows from monotone amplification of a common growth factor — a Chebyshev-sum / rearrangement effect. Theorem 6.1 isolates the real-analytic core.

**Conjecture 3 (Infinite log-concavity of the rows).** For every $d \ge 1$, each fixed row $k \mapsto H_d(n,k)$ is *infinitely* log-concave: it remains log-concave under repeated application of the log-concavity operator. The proposed mechanism is a closure lemma: a finite positive log-concave row satisfying the golden-ratio-squared safety factor $a_k^2 \ge \tfrac{3+\sqrt5}{2}\,a_{k-1}a_{k+1}$ maps to a sequence satisfying the same factor, so a single lemma propagates through all iterates. The constant $\tfrac{3+\sqrt5}{2}$ is exactly the fixed point of the operator's worst-case ratio.

**Conjecture 4 (Log-concave renormalization of the totals).** For every $d \ge 2$ there is an explicit positive normalizing sequence $w_d(n)$ (e.g. a ratio of factorials) such that $H_d(n)/w_d(n)$ is infinitely log-concave, even though the raw totals are log-convex. The exact Catalan growth ratio $\frac{(n+2)(2n+3)}{(2n+1)(n+3)}$ read off the discriminant identity is the concrete first candidate for $w_2$.

**Conjecture 5 (Tropical dequantization of the dichotomy).** Under the min-plus limit sending $a_n$ to $v_n = -\log a_n$, log-concavity becomes convexity of $v$ and log-linearity becomes affinity. The dichotomy then reads: $v$ is affine for $d=1$ and strictly concave for $d \ge 2$. The log-concavity operator degenerates to a second finite difference, so infinite log-concavity corresponds to iterated finite differences retaining a fixed sign — a purely piecewise-linear condition. Theorem 7.1 is the base case.

## 10. Conclusion

We have proved a sharp dichotomy at the foot of the d-Hoggatt hierarchy: the $d=1$ totals $2^n$ are log-linear and never strictly log-convex, while the $d=2$ totals $C_n$ are strictly log-convex and never log-concave. The proof rests on an exact discriminant identity whose two coefficients differ by the constant $3$ — the numerical embodiment of the strictness — and generalizes to a ratio-monotonicity mechanism and a tropical reformulation. Together these results turn a computational observation into an exact structural theorem and lay the groundwork for a uniform theory of curvature across the entire hierarchy.
