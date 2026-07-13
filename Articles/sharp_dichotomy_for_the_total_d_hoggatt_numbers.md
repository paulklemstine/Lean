# The Great Divide: How Counting Sequences Bend

Some of the most familiar sequences in mathematics carry a hidden signature in the way they curve. Line up the numbers, compare each one to its neighbors, and a subtle rule emerges — the sequence either bows gently downward, stretches out in a perfectly straight line, or bows upward with quiet insistence. This article is about a razor-sharp boundary between two of these behaviors, discovered in a family of counting numbers that includes two of the most beloved sequences in all of combinatorics: the powers of two and the Catalan numbers.

## A tale of three triangles

Many of the sequences that show up when we count things — arrangements, paths, tilings, trees — are best organized into triangular tables. The most famous is Pascal's triangle, where each entry is the sum of the two above it. Its rows sum to the powers of two: $1, 2, 4, 8, 16, \dots$

There is a whole hierarchy of such triangles, indexed by a parameter $d = 1, 2, 3, \dots$. We call the entries the **d-Hoggatt numbers** $H_d(n,k)$, and what interests us here is the *total* of each row,
$$H_d(n) = \sum_k H_d(n,k).$$
As $d$ climbs, these totals run through a roll-call of combinatorial celebrities:

- **$d = 1$:** the row sums are the powers of two, $H_1(n) = 2^n$;
- **$d = 2$:** the row sums are the **Catalan numbers**, $H_2(n) = C_n = 1, 1, 2, 5, 14, 42, 132, \dots$;
- **$d = 3$:** the row sums are the **Baxter numbers**, $H_3(n) = 1, 1, 2, 6, 22, 92, \dots$

The Catalan numbers alone count more than two hundred different kinds of objects: the ways to correctly match parentheses, the triangulations of a polygon, the paths that stay above a diagonal, the shapes of binary trees. So this is not an exotic family — it is a family everyone in combinatorics already knows and loves.

## What does it mean for a sequence to "curve"?

To talk about curvature we need one clean idea. Take three consecutive terms of a positive sequence: $a_n$, $a_{n+1}$, $a_{n+2}$. Compare the **square of the middle term** to the **product of its two neighbors**. Three things can happen:

- **Log-concave:** $a_n \cdot a_{n+2} \le a_{n+1}^2$. The middle term is *bigger* than the "average" of its neighbors — the sequence bulges outward, like a hill.
- **Log-linear:** $a_{n+1}^2 = a_n \cdot a_{n+2}$. Perfect balance — the sequence grows by a constant ratio, a pure exponential.
- **Log-convex:** $a_{n+1}^2 < a_n \cdot a_{n+2}$. The middle term *sags* below its neighbors — the sequence curves upward, accelerating.

Why the word "log"? Because taking logarithms turns each of these into an ordinary statement about the sequence $\log a_n$: log-concave means $\log a_n$ is concave (bends down), log-linear means $\log a_n$ is a straight line, and log-convex means $\log a_n$ is convex (bends up). Multiplication becomes addition; the exponential nature of these sequences becomes visible as plain geometry.

Log-concavity is prized because it signals a kind of internal harmony — sequences with it tend to be unimodal (they rise then fall) and behave well under all sorts of operations. Log-convexity is its mirror image, the mark of runaway, accelerating growth.

## The dichotomy

Here is the punchline. The transition from $d = 1$ to $d = 2$ flips the curvature completely, and it does so as sharply as possible.

**The powers of two are perfectly straight.** For $H_1(n) = 2^n$ we have, exactly,
$$\left(2^{n+1}\right)^2 = 2^{n+2} = 2^n \cdot 2^{n+2}.$$
So the sequence $2^n$ is *log-linear*: it sits precisely on the boundary. It is log-concave and log-convex simultaneously, with equality — and, crucially, it is **never strictly log-convex**. It is the exponential that neither bulges nor sags.

**The Catalan numbers bend upward — strictly.** For $H_2(n) = C_n$ we have, for every $n \ge 0$,
$$C_{n+1}^2 < C_n \cdot C_{n+2}.$$
The Catalan totals are *strictly log-convex*, and as a consequence they are **not log-concave at all**. Where the powers of two lie flat, the Catalan numbers curve up.

That is the sharp dichotomy: one step up the hierarchy, from $d=1$ to $d=2$, and a perfectly balanced exponential becomes a strictly accelerating sequence. There is no middle ground, no borderline case — the equality of the powers of two becomes a strict inequality for the Catalans.

## The engine: a discriminant with a gap of three

Why are the Catalan numbers strictly log-convex? The proof turns on a single, beautiful exact identity. Recall the classical growth rule for Catalan numbers,
$$(n+2)\,C_{n+1} = 2(2n+1)\,C_n,$$
which lets each term be computed from the one before. Chaining this rule with itself and simplifying yields a clean cross-multiplied relation between $C_n$, $C_{n+1}$, and $C_{n+2}$:
$$(2n+1)(n+3)\,\big(C_n\,C_{n+2}\big) = (n+2)(2n+3)\,C_{n+1}^2.$$
Now look at the two polynomial coefficients. On the right,
$$(n+2)(2n+3) = 2n^2 + 7n + 6,$$
and on the left,
$$(2n+1)(n+3) = 2n^2 + 7n + 3.$$
They are *almost identical* — they differ by exactly $3$. That tiny, constant, strictly positive gap is the whole story. Because the coefficient multiplying $C_{n+1}^2$ is larger than the one multiplying $C_n C_{n+2}$, we can conclude $C_{n+1}^2 < C_n C_{n+2}$. The strictness of the log-convexity is quite literally the number $3$.

Contrast this with the powers of two, where the analogous coefficients would match exactly — a gap of zero — giving equality instead of strict inequality. The dichotomy lives in the difference between a gap of $0$ and a gap of $3$.

## The deeper mechanism: ratios that keep climbing

Behind the specific identity lies a general principle that explains *why* the totals accelerate. Consider the consecutive ratios of a positive sequence, $r_n = a_{n+1}/a_n$. If these ratios are **strictly increasing** — each step grows a little faster than the last — then the sequence is automatically strictly log-convex. Indeed the condition $r_n < r_{n+1}$ is, after clearing denominators, exactly $a_{n+1}^2 < a_n a_{n+2}$.

For the Catalan numbers this is transparent: the ratio $C_{n+1}/C_n = 2(2n+1)/(n+2)$ climbs steadily toward $4$, and one checks that
$$\frac{C_{n+1}}{C_n} < \frac{C_{n+2}}{C_{n+1}}$$
for every $n$. The individual rows of these triangles are log-concave, but summing them up amplifies a common growth factor across the whole row, and that amplification tips the totals into log-convexity. Log-convexity of the totals, in this view, is not an accident of the Catalan numbers — it is a *summation phenomenon*, a rearrangement effect that should recur throughout the hierarchy.

## Dequantizing: a tropical view

There is one more way to see the dichotomy, and it connects this combinatorial fact to a fashionable corner of modern geometry. Pass to logarithms and set the *valuation* $v_n = -\log a_n$. Then:

- log-linearity of $a$ becomes **affinity** of $v$ (a straight line);
- strict log-convexity of $a$ becomes **strict concavity** of $v$ (a curve bending down).

Precisely, $a_{n+1}^2 < a_n a_{n+2}$ is equivalent to
$$2\log a_{n+1} < \log a_n + \log a_{n+2}.$$
In this "tropical" or min-plus picture — where multiplication becomes addition and the fine multiplicative structure is stripped away to its skeleton — the dichotomy reads with startling simplicity: **for $d=1$ the valuation is a straight line; for $d=2$ it strictly bends.** The whole subtle business of squares and products collapses into a single statement about the sign of a second difference, the natural object of tropical, piecewise-linear geometry.

## Why it matters, and where it goes

Log-concavity and log-convexity are more than curiosities. They govern the unimodality of coefficient sequences across combinatorics, algebra, and probability; they underlie inequalities used in statistical physics and information theory; and they signal deep structural properties (real-rootedness, positivity, matroid structure) that mathematicians spend careers unraveling. Knowing *exactly where* a natural family switches from one behavior to the other is the kind of clean structural fact that anchors a whole research program.

The dichotomy proved here is the first rung of a ladder. The evidence — and a chain of natural conjectures — points to a universal pattern: for **every** $d \ge 2$, the totals should be strictly log-convex, with the Baxter numbers ($d=3$) already matching the Catalan case term by term in computation. Deeper still, one expects the individual rows of every d-Hoggatt triangle to be not merely log-concave but *infinitely* log-concave — remaining log-concave even after the log-concavity test is applied again and again — governed by a magical threshold constant, the golden ratio squared, $(3+\sqrt5)/2$. And one expects that dividing the runaway totals by the right smooth growth factor should *renormalize* them back into infinite log-concavity, taming the acceleration.

For now, one thing is certain and exact. Climb from the powers of two to the Catalan numbers, and a perfectly straight exponential begins, unmistakably, to bend — by exactly three.
