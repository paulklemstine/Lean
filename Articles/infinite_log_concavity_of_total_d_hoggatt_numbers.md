# When Doubling Beats Counting: The Hidden Rhythm of Hoggatt's Numbers

## A tale of two triangles

Every schoolchild who has ever drawn Pascal's triangle has, without knowing it, brushed up against one of the deepest and most stubborn questions in modern combinatorics. Write down the rows:

$$
1,\quad 1\ 1,\quad 1\ 2\ 1,\quad 1\ 3\ 3\ 1,\quad 1\ 4\ 6\ 4\ 1,\ \dots
$$

Now add up each row. You get $1, 2, 4, 8, 16, \dots$ — the powers of two. This is the simplest member of a whole *family* of triangles studied by the mathematician Verner Hoggatt, and its row sums are as tame as arithmetic gets. But climb one rung up the family ladder and the row sums explode into the famous **Catalan numbers** $1, 1, 2, 5, 14, 42, \dots$, the counting sequence that appears everywhere from balanced parentheses to triangulations of polygons. Climb one more rung and you meet the **Baxter numbers** $1, 1, 2, 6, 22, 92, \dots$, which count certain permutations that refuse to be sorted by a pair of stacks.

These are the *total $d$-Hoggatt numbers*: for each parameter $d \ge 1$, the $d$-Hoggatt triangle $H_d(n,k)$ has row sums

$$
H_d(n) = \sum_{k=0}^{n} H_d(n,k).
$$

For $d=1$ the totals are the powers of two; for $d=2$ they are the Catalan numbers; for $d=3$ they are the Baxter numbers. A single knob, $d$, tunes us from the trivially simple to the notoriously hard.

This article is about one property these sequences might or might not have — a property with the imposing name **infinite log-concavity** — and a clean result that settles the question for the first two rungs of the ladder while revealing exactly *why* the higher rungs resist.

## What is log-concavity, and why care?

A sequence of positive numbers $a_0, a_1, a_2, \dots$ is called **log-concave** if each term is at least the geometric mean of its neighbors:

$$
a_{n+1}^2 \ge a_n \, a_{n+2} \quad\text{for all } n.
$$

Equivalently, the ratios $a_{n+1}/a_n$ never increase. Log-concave sequences are the "well-behaved" sequences of combinatorics: their generating polynomials tend to have only real roots, their peaks are single and unimodal, and they show up as the answer to an astonishing range of counting problems. A sequence that fails this test — where $a_{n+1}^2 < a_n a_{n+2}$ — is instead **log-convex**: it curves the other way, accelerating as it grows.

It is convenient to package this into a single operator. Define the **log-concavity operator** $\mathcal{L}$ acting on a sequence $a$ by

$$
(\mathcal{L}a)(n) = a_{n+1}^2 - a_n\, a_{n+2}.
$$

Then "log-concave" simply means $\mathcal{L}a \ge 0$ everywhere, and "log-convex" means $\mathcal{L}a \le 0$ everywhere. The quantity $(\mathcal{L}a)(n)$ measures, term by term, how much the sequence bulges up or sags down.

Here is where the story gets interesting. Since $\mathcal{L}a$ is *itself* a new sequence, we can feed it back into $\mathcal{L}$ and ask whether *that* is log-concave too. A sequence is called **infinitely log-concave** if it survives this test forever: $a$ is log-concave, and $\mathcal{L}a$ is log-concave, and $\mathcal{L}(\mathcal{L}a)$ is log-concave, and so on through every iterate. This is a demanding, almost fractal notion of smoothness — a sequence must be well-behaved at every level of a bottomless hierarchy.

Infinite log-concavity is genuinely hard to establish. The most celebrated open case is the **binomial coefficients themselves**: whether the rows of Pascal's triangle are infinitely log-concave was a conjecture that stood for years and required delicate analysis to crack. So when we ask whether the *row sums* of the Hoggatt triangles are infinitely log-concave, we are wading into deep water.

## The clean answer at the bottom of the ladder

The first result is a small miracle of simplicity. Consider the $d=1$ totals, the powers of two — or more generally any **geometric sequence** $a_n = r^n$. What does the log-concavity operator do to it?

$$
(\mathcal{L}a)(n) = (r^{n+1})^2 - r^n \cdot r^{n+2} = r^{2n+2} - r^{2n+2} = 0.
$$

It annihilates it completely. A geometric sequence sits *exactly* on the boundary between log-concave and log-convex — it is "log-linear," perfectly straight on a logarithmic scale. And because $\mathcal{L}$ turns it into the all-zeros sequence, every subsequent iterate is also zero, and zero is (weakly) nonnegative forever.

> **Theorem (Log-linear totals).** Every geometric sequence $a_n = r^n$ is infinitely log-concave. In particular, the total $1$-Hoggatt numbers $2^n$ — the row sums of Pascal's triangle — are infinitely log-concave.

The proof is almost a one-liner, but it is worth savoring what it says: at the very bottom of the Hoggatt hierarchy, the totals are as perfectly balanced as a sequence can be. Doubling is the great equalizer.

## The surprise one rung up

Now the twist. Naively, one might hope that if the simplest totals are infinitely log-concave, the pattern continues. The name of the concept — "log-concavity of the total $d$-Hoggatt numbers" — practically invites the guess that the whole family is log-concave. It is not. And the failure is not marginal; it is emphatic.

Take the Catalan numbers, the $d=2$ totals. They satisfy the clean ratio recurrence

$$
C_0 = 1, \qquad C_{n+1} = \frac{2(2n+1)}{n+2}\, C_n,
$$

which quickly generates $1, 1, 2, 5, 14, 42, 132, \dots$. Are they log-concave? Compute the operator at the very first step. Using the recurrence twice, one finds after a short algebraic simplification that

$$
(\mathcal{L}C)(n) = C_{n+1}^2 - C_n C_{n+2} = -\,\frac{3\,(2n+1)}{(n+2)^2(n+3)}\cdot 2\,(2n+1)\,C_n^2 \cdot(\text{positive factor}) < 0
$$

for **every** $n \ge 0$. The heart of the computation is a tiny, exact identity,

$$
(2n+3)(n+2) - (2n+1)(n+3) = 3,
$$

a stubborn positive constant that never cancels. That leftover $3$ is the entire story: it forces the discriminant to be strictly negative at every index.

> **Theorem (Catalan log-convexity).** The Catalan numbers are strictly log-convex: $C_{n+1}^2 < C_n C_{n+2}$ for all $n \ge 0$. Consequently they are **not** log-concave, and therefore not infinitely log-concave.

So the very first nontrivial rung of the Hoggatt ladder falls off the log-concave side entirely and lands on the log-convex side. Checking the smallest case makes it concrete: $C_1^2 = 1$ but $C_0 C_2 = 2$, so already $1 < 2$. The totals curve *upward*, accelerating, exactly opposite to the smooth downward bulge of a log-concave sequence.

## A sharp dichotomy

Putting the two results side by side gives a crisp picture of the bottom of the hierarchy:

> **Main result.** The total $1$-Hoggatt numbers $2^n$ are infinitely log-concave, while the total $2$-Hoggatt numbers (the Catalan numbers) are not even log-concave. Infinite log-concavity holds at $d=1$ and fails at $d=2$.

This is a genuine dichotomy, and it is instructive precisely because it overturns the tempting guess. The name of a phenomenon is not a proof of it. The powers of two are special: they are the *only* geometric member of the family, sitting exactly on the knife's edge where the log-concavity operator vanishes. The moment we introduce real counting — the Catalan numbers, which grow like $4^n/n^{3/2}$ rather than a clean $r^n$ — that polynomial correction $n^{-3/2}$ tips the balance toward log-convexity.

And the pattern continues. The Baxter numbers ($d=3$) grow like $8^n/n^4$, and numerically they too are log-convex at every step we can compute. The same negative "discriminant" that sinks the Catalan numbers reappears for the Baxter numbers. What looked like it might be a story about log-*concavity* turns out to be a story about log-*convexity*: for $d \ge 2$, the totals accelerate.

## Why the totals behave this way

There is a satisfying intuition behind the dichotomy. Each total $H_d(n)$ is a positively weighted sum of products of binomial coefficients, and the dominant term's growth ratio *increases* with $n$. When a sequence's growth ratio increases, it is log-convex by definition. Summation acts as an amplifier: even if each individual row of the Hoggatt triangle is log-concave (a smooth, well-behaved hump), the act of collapsing the whole row into a single number blends together terms of different growth rates, and the fastest-growing term wins out more and more decisively as $n$ increases. The result is a total sequence whose ratios climb — the signature of log-convexity.

The $d=1$ case escapes this fate for the simplest possible reason: there is nothing to amplify. The row sums are a pure geometric progression, with a single constant growth ratio of $2$. No polynomial correction, no competing growth rates, no acceleration. It is the one place in the family where amplification has no raw material to work with.

## The bigger picture

Why does any of this matter beyond the pleasure of a clean argument? Log-concavity and log-convexity are not idle curiosities. They control the *shape* of counting sequences, and shape is destiny in combinatorics: it determines whether a sequence has a single peak, how sharply it concentrates, and whether its generating function factors nicely. These questions connect to statistical mechanics (where log-concave partition functions signal well-behaved thermodynamics), to the geometry of polynomials, and to the theory of matroids, where log-concavity conjectures were resolved only recently using tools from algebraic geometry.

The Hoggatt totals sharpen a specific and famous frontier. The infinite log-concavity of the Catalan numbers and the Baxter numbers had been floated as open problems — plausible-sounding conjectures waiting to be settled. The clean lesson here is that for the *totals*, the honest answer runs the other way: rather than being infinitely log-concave, they are strictly log-convex from the very first step, and the powers of two are the lone, boundary exception.

That reframing is valuable. It tells future researchers where *not* to look — no amount of clever iteration will rescue infinite log-concavity for the Catalan totals — and it points toward the right questions. Perhaps the totals become infinitely log-concave after being divided by a smooth normalizing factor that soaks up the excess growth. Perhaps the log-convexity is a universal "summation phenomenon" that holds for *any* triangle whose rows are log-concave with an increasing row-ratio. And the original hope — infinite log-concavity — may well survive for the individual *rows* of the Hoggatt triangles, even as it dies for their sums.

Sometimes the most illuminating result is the one that says: you were looking for concavity, but the truth is convexity, and here is exactly why. In a single leap from doubling to counting, a family of triangles flips its character — and the boundary between the two worlds is drawn with the sharpness of a single, stubborn $3$.
