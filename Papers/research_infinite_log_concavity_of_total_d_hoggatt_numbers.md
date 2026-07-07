# A Log-Concavity Dichotomy for the Total $d$-Hoggatt Numbers

## Abstract

The *total $d$-Hoggatt numbers* are the row sums $H_d(n) = \sum_{k=0}^{n} H_d(n,k)$ of the $d$-Hoggatt triangle. For the smallest parameters they specialize to fundamental combinatorial sequences: $H_1(n) = 2^n$ (the row sums of Pascal's triangle), $H_2(n) = C_n$ (the Catalan numbers), and $H_3(n)$ (the Baxter numbers). We study the **infinite log-concavity** of these totals — the property that the log-concavity operator $\mathcal{L}$, defined by $(\mathcal{L}a)(n) = a_{n+1}^2 - a_n a_{n+2}$, produces a nonnegative sequence under arbitrarily many iterations. We prove a sharp dichotomy between the two smallest rungs of the hierarchy: the $d=1$ totals $2^n$ are infinitely log-concave (indeed *log-linear*, annihilated by $\mathcal{L}$), while the $d=2$ totals — the Catalan numbers — are **strictly log-convex**, failing log-concavity at every index. The Catalan result rests on a single exact polynomial identity, $(2n+3)(n+2) - (2n+1)(n+3) = 3$, whose stubborn positive residue forces the discriminant negative for all $n$. These results overturn the natural conjecture that the totals inherit log-concavity from the individual rows and reframe the problem: for $d \ge 2$ the totals appear to be universally log-convex, a "summation amplification" phenomenon. We discuss the extension to Baxter numbers, the conjectural universal log-convexity of the totals, and a renormalization program under which infinite log-concavity may be recovered.

**Keywords:** log-concavity, log-convexity, infinite log-concavity, Hoggatt triangle, Catalan numbers, Baxter numbers, binomial coefficients, unimodality.

---

## 1. Introduction

### 1.1 Motivation

Log-concavity is one of the organizing principles of enumerative combinatorics. A sequence $(a_n)_{n\ge0}$ of positive reals is **log-concave** if $a_{n+1}^2 \ge a_n a_{n+2}$ for all $n$, equivalently if its consecutive ratios $a_{n+1}/a_n$ are nonincreasing. Log-concave sequences are unimodal, they arise as coefficient sequences of real-rooted polynomials, and their ubiquity — from the binomial coefficients to the coefficients of chromatic and characteristic polynomials — has made log-concavity conjectures a recurring theme, several of which were resolved only recently through substantial machinery.

A far more delicate notion is **infinite log-concavity**. Introduced through the *log-concavity operator*
$$
(\mathcal{L}a)(n) = a_{n+1}^2 - a_n a_{n+2},
$$
a sequence is infinitely log-concave if $\mathcal{L}^k a \ge 0$ (pointwise) for every $k \ge 0$. Because $\mathcal{L}a$ is again a sequence, this is a demanding closure requirement across a bottomless hierarchy of derived sequences. The infinite log-concavity of the binomial coefficients $\binom{n}{k}$ (rows of Pascal's triangle) is a well-known hard problem, resolved through careful analysis of the operator's action.

### 1.2 The $d$-Hoggatt hierarchy

The $d$-Hoggatt triangles $H_d(n,k)$ form a one-parameter family generalizing Pascal's triangle. Their **totals** (row sums)
$$
H_d(n) = \sum_{k=0}^{n} H_d(n,k)
$$
interpolate across some of the most studied sequences in combinatorics:

| $d$ | Total sequence $H_d(n)$ | First terms |
|-----|-------------------------|-------------|
| $1$ | Powers of two $2^n$ | $1, 2, 4, 8, 16, 32, \dots$ |
| $2$ | Catalan numbers $C_n$ | $1, 1, 2, 5, 14, 42, 132, \dots$ |
| $3$ | Baxter numbers $B_n$ | $1, 1, 2, 6, 22, 92, 422, \dots$ |

The single parameter $d$ tunes the totals from the arithmetically trivial ($2^n$) to sequences whose finer analytic properties remain the subject of active research. It is natural to ask whether infinite log-concavity — established (with effort) for the *rows* of such triangles in prior work — carries over to the *totals*.

### 1.3 Contributions

We settle the question at the two smallest rungs and expose the mechanism governing the rest.

1. **(Log-linear totals, $d=1$).** Every geometric sequence $a_n = r^n$ satisfies $\mathcal{L}a = 0$ identically, hence is infinitely log-concave. In particular $H_1(n) = 2^n$ is infinitely log-concave.

2. **(Catalan log-convexity, $d=2$).** The Catalan numbers are *strictly log-convex*: $C_{n+1}^2 < C_n C_{n+2}$ for all $n$. Hence they are not log-concave, and a fortiori not infinitely log-concave. The proof reduces to the exact identity $(2n+3)(n+2) - (2n+1)(n+3) = 3$.

3. **(Dichotomy).** Combining the two, infinite log-concavity of the total $d$-Hoggatt numbers holds at $d=1$ and fails already at $d=2$. This refutes the naive conjecture suggested by the phenomenon's name.

4. **(Structural reframing).** We explain the dichotomy as a summation-amplification effect and formulate conjectures extending strict log-convexity to all $d \ge 2$ (including the Baxter numbers), together with a renormalization program under which infinite log-concavity is recovered.

---

## 2. Definitions

Throughout, sequences are real-valued functions $a : \mathbb{N} \to \mathbb{R}$.

**Definition 2.1 (Log-concavity operator).** The *log-concavity operator* $\mathcal{L}$ sends a sequence $a$ to the sequence
$$
(\mathcal{L}a)(n) = a_{n+1}^2 - a_n\, a_{n+2}, \qquad n \ge 0.
$$
The value $(\mathcal{L}a)(n)$ is the *discriminant* of $a$ at index $n$.

**Definition 2.2 (Log-concave / log-convex).** A sequence $a$ is **log-concave** if $(\mathcal{L}a)(n) \ge 0$ for all $n$, and **log-convex** if $(\mathcal{L}a)(n) \le 0$ for all $n$. It is **strictly log-convex** if $(\mathcal{L}a)(n) < 0$ for all $n$.

**Definition 2.3 (Infinite log-concavity).** A sequence $a$ is **infinitely log-concave** if the $k$-fold iterate $\mathcal{L}^k a$ is log-concave for every $k \ge 0$; that is, $(\mathcal{L}^k a)(n) \ge 0$ for all $k, n \ge 0$. (Here $\mathcal{L}^0 a = a$.)

**Definition 2.4 (Real Catalan numbers).** The Catalan numbers are defined by the ratio recurrence
$$
C_0 = 1, \qquad C_{n+1} = \frac{2(2n+1)}{n+2}\, C_n \quad (n \ge 0).
$$
This is equivalent to the closed form $C_n = \frac{1}{n+1}\binom{2n}{n}$ and generates $1, 1, 2, 5, 14, 42, 132, 429, \dots$

**Definition 2.5 (Total $d$-Hoggatt numbers).** For the $d$-Hoggatt triangle $H_d(n,k)$, the *total* is $H_d(n) = \sum_{k=0}^{n} H_d(n,k)$. We use the specializations $H_1(n) = 2^n$, $H_2(n) = C_n$, and $H_3(n) = B_n$ (Baxter numbers).

---

## 3. The $d=1$ case: log-linear totals

The key observation is that geometric sequences lie exactly on the boundary between log-concave and log-convex: the operator $\mathcal{L}$ annihilates them.

**Lemma 3.1 (Annihilation of geometric sequences).** For every $r \in \mathbb{R}$, the sequence $a_n = r^n$ satisfies $(\mathcal{L}a)(n) = 0$ for all $n$.

*Proof.* Directly,
$$
(\mathcal{L}a)(n) = (r^{n+1})^2 - r^n\cdot r^{n+2} = r^{2n+2} - r^{2n+2} = 0. \qquad\blacksquare
$$

**Lemma 3.2 (Persistence of the zero sequence).** If $\mathbf{0}$ denotes the identically-zero sequence, then $\mathcal{L}\mathbf{0} = \mathbf{0}$, and hence $\mathcal{L}^k \mathbf{0} = \mathbf{0}$ for all $k$. The zero sequence is log-concave (with equality), so it is infinitely log-concave.

*Proof.* $(\mathcal{L}\mathbf{0})(n) = 0^2 - 0\cdot 0 = 0$. Induction on $k$ gives $\mathcal{L}^k\mathbf{0} = \mathbf{0}$, and $0 \ge 0$ establishes log-concavity of every iterate. $\blacksquare$

**Theorem 3.3 (Infinite log-concavity of geometric sequences).** For every $r \in \mathbb{R}$, the sequence $a_n = r^n$ is infinitely log-concave. In particular, the total $1$-Hoggatt numbers $H_1(n) = 2^n$ are infinitely log-concave.

*Proof.* By Lemma 3.1, $\mathcal{L}a = \mathbf{0}$. Thus $\mathcal{L}^0 a = a$ is log-concave (its discriminant is identically $0$), and for $k \ge 1$ we have $\mathcal{L}^k a = \mathcal{L}^{k-1}(\mathcal{L}a) = \mathcal{L}^{k-1}\mathbf{0} = \mathbf{0}$, which is log-concave by Lemma 3.2. Taking $r = 2$ gives the claim for $2^n$. $\blacksquare$

The content of Theorem 3.3 is that the $d=1$ totals are *log-linear*: perfectly straight on a logarithmic scale, with a single constant growth ratio $r$. They sit precisely on the knife-edge where $\mathcal{L}$ vanishes, which is exactly why infinite log-concavity holds so effortlessly.

---

## 4. The $d=2$ case: strict log-convexity of the Catalan numbers

We now show the second rung of the hierarchy departs sharply from the first.

**Lemma 4.1 (Positivity).** $C_n > 0$ for all $n$.

*Proof.* Induction. $C_0 = 1 > 0$, and if $C_n > 0$ then $C_{n+1} = \frac{2(2n+1)}{n+2}C_n$ is a product of positive factors, since $2(2n+1) > 0$ and $n+2 > 0$. $\blacksquare$

**Lemma 4.2 (The key identity).** For all real $n$,
$$
(2n+3)(n+2) - (2n+1)(n+3) = 3.
$$

*Proof.* Expand: $(2n+3)(n+2) = 2n^2 + 7n + 6$ and $(2n+1)(n+3) = 2n^2 + 7n + 3$; subtract. $\blacksquare$

This unassuming constant $3$ is the crux: it is the exact amount by which the "forward" cross term exceeds the "backward" one, and it never cancels.

**Lemma 4.3 (Negative discriminant).** For all $n \ge 0$, $(\mathcal{L}C)(n) < 0$.

*Proof.* Apply the ratio recurrence twice:
$$
C_{n+1} = \frac{2(2n+1)}{n+2}\,C_n, \qquad C_{n+2} = \frac{2(2n+3)}{n+3}\,C_{n+1} = \frac{4(2n+1)(2n+3)}{(n+2)(n+3)}\,C_n.
$$
Therefore
$$
(\mathcal{L}C)(n) = C_{n+1}^2 - C_n C_{n+2}
= \frac{4(2n+1)^2}{(n+2)^2}C_n^2 - \frac{4(2n+1)(2n+3)}{(n+2)(n+3)}C_n^2.
$$
Factoring out the positive quantity $\dfrac{4(2n+1)}{(n+2)}C_n^2 > 0$ (positive by Lemma 4.1 and $n \ge 0$),
$$
(\mathcal{L}C)(n) = \frac{4(2n+1)}{n+2}C_n^2\left[\frac{2n+1}{n+2} - \frac{2n+3}{n+3}\right].
$$
The bracket equals
$$
\frac{(2n+1)(n+3) - (2n+3)(n+2)}{(n+2)(n+3)} = \frac{-3}{(n+2)(n+3)} < 0,
$$
using Lemma 4.2. Hence $(\mathcal{L}C)(n) = -\dfrac{12(2n+1)}{(n+2)^2(n+3)}\,C_n^2 < 0$. $\blacksquare$

**Theorem 4.4 (Catalan log-convexity).** The Catalan numbers are strictly log-convex: $C_{n+1}^2 < C_n C_{n+2}$ for all $n \ge 0$. Consequently they are **not** log-concave, and therefore **not** infinitely log-concave.

*Proof.* Strict log-convexity is exactly $(\mathcal{L}C)(n) < 0$ for all $n$, established in Lemma 4.3. If the sequence were log-concave we would need $(\mathcal{L}C)(0) \ge 0$, contradicting $(\mathcal{L}C)(0) < 0$; a concrete witness is $C_1^2 = 1 < 2 = C_0 C_2$. Failing log-concavity, it cannot be infinitely log-concave (which requires the $k=0$ iterate to be log-concave). $\blacksquare$

---

## 5. Main result: the dichotomy

Combining the two analyses yields the headline statement.

**Theorem 5.1 (Log-concavity dichotomy at the base of the Hoggatt hierarchy).**
The total $1$-Hoggatt numbers $H_1(n) = 2^n$ are infinitely log-concave, while the total $2$-Hoggatt numbers $H_2(n) = C_n$ (the Catalan numbers) are not even log-concave. Infinite log-concavity holds at $d=1$ and fails at $d=2$.

*Proof.* The first clause is Theorem 3.3 (with $r=2$); the second is Theorem 4.4. $\blacksquare$

The dichotomy is instructive precisely because it refutes the guess embedded in the name of the phenomenon. Log-concavity of the totals is *not* a family-wide property inherited from the (log-concave) rows; it is an exceptional feature of the single geometric member $d=1$.

---

## 6. The $d=3$ case and the general mechanism

### 6.1 Baxter numbers

The Baxter numbers admit the summation formula
$$
B_n = \sum_{k=1}^{n} \frac{\binom{n+1}{k-1}\binom{n+1}{k}\binom{n+1}{k+1}}{\binom{n+1}{1}\binom{n+1}{2}},
$$
generating $1, 1, 2, 6, 22, 92, 422, 2074, \dots$ Direct computation of the discriminant $(\mathcal{L}B)(n) = B_{n+1}^2 - B_n B_{n+2}$ yields negative values at every computed index (e.g. $B_1^2 - B_0 B_2 = 1 - 2 = -1$; $B_2^2 - B_1 B_3 = 4 - 6 = -2$; $B_3^2 - B_2 B_4 = 36 - 44 = -8$). Thus the Baxter totals are empirically strictly log-convex, mirroring the Catalan case exactly.

### 6.2 Why summation amplifies growth

The unifying intuition is an *amplification* effect. Each total $H_d(n)$ is a positively weighted sum of products of binomial coefficients. The dominant contribution grows like $\rho_d^{\,n}\, n^{-\alpha_d}$ for a base $\rho_d > 1$ and an exponent $\alpha_d > 0$ (for the Catalan numbers $\rho_2 = 4$, $\alpha_2 = 3/2$; for Baxter $\rho_3 = 8$, $\alpha_3 = 4$). For any sequence of the form $a_n \sim \rho^n n^{-\alpha}$ with $\alpha > 0$, the ratios $a_{n+1}/a_n = \rho\,(1 - \alpha/n + O(n^{-2}))$ are *increasing* in $n$, which is precisely the signature of log-convexity. Summation collapses a log-concave row into a single number, but in doing so it superimposes terms of differing growth rates; the fastest-growing term dominates increasingly, and its increasing ratio drags the total into log-convexity.

The $d=1$ case escapes because $H_1(n) = 2^n$ has $\alpha_1 = 0$: there is no polynomial correction, no competing growth rates, nothing to amplify. It is the unique log-linear boundary case.

---

## 7. Algorithms

We record the computational procedures used to certify these results numerically; they are exact when carried out over the rationals or integers.

**Algorithm 7.1 (Discriminant of a sequence).** Given the first $N+2$ terms of $a$, output $(\mathcal{L}a)(n)$ for $0 \le n \le N-1$ via $a_{n+1}^2 - a_n a_{n+2}$. Complexity $O(N)$ arithmetic operations.

**Algorithm 7.2 (Iterated log-concavity test).** To test infinite log-concavity up to depth $K$ over indices $0 \le n \le N$: compute $a$, then repeatedly apply Algorithm 7.1, each pass shrinking the window by two. Report the first $(k,n)$ with $(\mathcal{L}^k a)(n) < 0$, or "no violation up to depth $K$." Complexity $O(KN)$.

**Algorithm 7.3 (Exact totals).** Generate Catalan numbers by the ratio recurrence (Definition 2.4) and Baxter numbers by the triple-binomial summation (§6.1) using exact rational arithmetic, so that sign tests on the discriminant are rigorous.

---

## 8. Applications and Discussion

**Shape of counting sequences.** Log-concavity versus log-convexity dictates the qualitative shape of a sequence: log-concave sequences are unimodal with a single peak; log-convex sequences accelerate without interior maxima. Knowing that the Hoggatt totals for $d \ge 2$ are log-convex tells us their ratios climb monotonically — useful for asymptotics and for bounding tail behavior.

**A cautionary tale about inheritance.** It is tempting to assume that a "nice" property of the rows of a triangle passes to the row sums. The dichotomy shows this can fail dramatically: log-concave rows can produce strictly log-convex totals. Summation is not a neutral operation with respect to log-behavior.

**Sharpening open problems.** The infinite log-concavity of the Catalan and Baxter numbers has been floated as open. For the *totals* the honest answer is negative and strong: they are strictly log-convex from index $0$. This closes off a fruitless search direction and redirects attention to the rows and to renormalized totals.

---

## 9. Future Directions

**Conjecture 9.1 (Universal log-convexity of the totals for $d \ge 2$).** For every $d \ge 2$, the total $d$-Hoggatt numbers are strictly log-convex: $H_d(n+1)^2 < H_d(n)H_d(n+2)$ for all $n \ge 0$. The Catalan case ($d=2$) is proved here from the two-term ratio recurrence; the Baxter case ($d=3$) matches term-by-term in computation, suggesting a single recurrence-driven argument covers the whole family.

**Conjecture 9.2 (Log-convexity as a summation phenomenon).** If $T(n,k)$ is any triangle whose rows are log-concave and whose row-ratio $T(n+1,k)/T(n,k)$ is nondecreasing in $n$, then the row sums $S(n) = \sum_k T(n,k)$ are log-convex. This would establish log-convexity of the totals as a structural (Chebyshev-sum / rearrangement) effect rather than a Hoggatt-specific coincidence.

**Conjecture 9.3 (Infinite log-concavity of the rows).** For every $d \ge 1$, each fixed row $k \mapsto H_d(n,k)$ of the $d$-Hoggatt triangle is infinitely log-concave. A candidate mechanism is a closure lemma: a finite positive log-concave row satisfying the golden-ratio-squared safety margin $a_k^2 \ge \frac{3+\sqrt5}{2}\,a_{k-1}a_{k+1}$ reproduces the same margin under $\mathcal{L}$, and $\frac{3+\sqrt5}{2}$ is exactly the fixed point of the operator's worst-case ratio.

**Conjecture 9.4 (Log-concave renormalization of the totals).** For every $d \ge 2$ there is an explicit positive normalizing sequence $w_d(n)$ (e.g. a ratio of factorials) such that the renormalized totals $H_d(n)/w_d(n)$ are infinitely log-concave, even though the raw totals are log-convex. The idea is that log-convexity of the totals is caused by a smooth, predictable growth factor that can be divided out, leaving a residual sequence governed by the same infinite-log-concavity mechanism seen in the rows.

---

## 10. Conclusion

We have proved a clean dichotomy at the base of the $d$-Hoggatt hierarchy: the $d=1$ totals $2^n$ are infinitely log-concave because the log-concavity operator annihilates every geometric sequence, whereas the $d=2$ totals — the Catalan numbers — are strictly log-convex, the failure driven by the exact identity $(2n+3)(n+2)-(2n+1)(n+3)=3$. Numerical evidence extends strict log-convexity to the Baxter ($d=3$) totals and points to a universal summation-amplification mechanism for all $d \ge 2$. The main lesson is a reframing: for the totals, the natural object of study is log-*convexity*, with infinite log-concavity surviving (conjecturally) only for the rows or for a suitable renormalization.

---

## References

The notions of log-concavity, unimodality, and their pervasive role in combinatorics are classical; the log-concavity operator and the study of infinite log-concavity for the binomial coefficients belong to a well-developed line of research on iterated log-concavity. The Catalan and Baxter numbers are among the most studied integer sequences in enumerative combinatorics.
