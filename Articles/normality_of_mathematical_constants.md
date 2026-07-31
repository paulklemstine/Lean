# When Randomness Hides Inside a Number

## A bridge from moving points to digit statistics

The decimal expansion of a familiar constant can look like rainfall: irregular, patternless, and apparently impartial. In the opening digits of $\pi$, no digit seems privileged for long. The same impression comes from $e$ and $\sqrt 2$. But an impression of randomness is not a theorem. To say precisely what “every finite pattern occurs as often as it should” means, and then to prove it, requires a bridge between two different views of a number.

One view is combinatorial. It reads an expansion as a stream of symbols and counts blocks such as $00$, $17$, or $314159$. The other is dynamical. It repeatedly magnifies the number by the base, discards the integer part, and watches the resulting point move around the unit interval. The central result developed here is that a sufficiently uniform orbit in this dynamical picture forces perfectly balanced finite-block statistics in the digit picture.

That result does **not** settle the famous open questions for $\pi$, $e$, or $\sqrt 2$. No proof is currently known that any of these constants is normal in a familiar base. What it does provide is an exact reduction: if one can establish interval equidistribution for the appropriate multiplicative orbit, normality follows.

## What normality says

Fix an integer base $b\ge 2$. A real number has a base-$b$ expansion whose fractional digits are drawn from

$$
0,1,\ldots,b-1.
$$

A length-$k$ block is a string of $k$ such digits. There are exactly $b^k$ possible blocks, so an ideally balanced expansion should give each one limiting frequency $b^{-k}$.

A real number $x$ is called **normal in base $b$** when this balance holds for every block length $k\ge 1$ and every one of the $b^k$ blocks. More explicitly, if one examines the first $N$ starting positions in the fractional expansion of $x$, counts how often a chosen length-$k$ block appears, and divides by $N$, the ratio must tend to

$$
\frac{1}{b^k}
$$

as $N\to\infty$.

In base ten, normality says that each digit occurs $10\%$ of the time in the limit, each two-digit word occurs $1\%$ of the time, and each six-digit word occurs one time in a million positions. It is much stronger than merely asking for equal frequencies of single digits. A sequence could contain every digit equally often while arranging pairs or triples in a highly biased way.

Normality is therefore an infinite hierarchy of fairness tests. It demands balance at every finite resolution.

## Turn the expansion into motion

For a real number $y$, write its fractional part as

$$
\{y\}=y-\lfloor y\rfloor,
$$

which always lies in $[0,1)$. Now fix $x$ and repeatedly multiply by $b$:

$$
u_n=\{b^n x\},\qquad n=0,1,2,\ldots.
$$

This sequence is an orbit of the map

$$
T_b(t)=\{bt\}.
$$

Multiplication by $b$ shifts the base-$b$ radix point one place to the right. Discarding the integer part throws away the digit that has just crossed the point. Thus $u_n$ stores the tail of the expansion beginning at position $n+1$.

This turns digit reading into geometry. Split $[0,1)$ into $b$ equal pieces. The interval containing $u_n$ identifies the next digit. Split the interval into $b^2$ equal pieces, and the interval containing $u_n$ identifies the next two digits. In general, the next $k$ digits are encoded by one of the intervals

$$
I_{A,k}=\left[\frac{A}{b^k},\frac{A+1}{b^k}\right),
\qquad 0\le A<b^k.
$$

Here $A$ is the integer represented by the block. The left-closed, right-open convention matters: it assigns every point to exactly one cell and removes ambiguity at boundaries.

## The floor–interval dictionary

There is a compact numerical way to extract the block. Define

$$
D_{b,k}(x,n)=\left\lfloor b^k\{b^n x\}\right\rfloor.
$$

Because $0\le \{b^n x\}<1$, the value lies among $0,1,\ldots,b^k-1$. It is exactly the integer code of the length-$k$ block beginning at the corresponding position.

The key dictionary is the following elementary equivalence:

$$
D_{b,k}(x,n)=A
\quad\Longleftrightarrow\quad
\{b^n x\}\in
\left[\frac{A}{b^k},\frac{A+1}{b^k}\right).
$$

Why? The equation $\lfloor z\rfloor=A$ means precisely $A\le z<A+1$. Taking $z=b^k\{b^n x\}$ and dividing by the positive number $b^k$ gives the interval condition. This small observation is the hinge on which the whole argument turns: a symbolic event becomes a visit to a geometric region.

## What it means for the orbit to spread evenly

A sequence $(u_n)$ in $[0,1)$ is **interval-equidistributed** if, for every half-open interval $[a,c)\subseteq[0,1)$, the proportion of the first $N$ terms that land in that interval tends to its length:

$$
\lim_{N\to\infty}
\frac{1}{N}\#\{0\le n<N:u_n\in[a,c)\}=c-a.
$$

This condition says much more than that the orbit is dense. A dense sequence eventually visits every open region, but it may spend nearly all its time in one part of the interval. Equidistribution controls frequency, not merely reach.

Imagine dropping pins at the successive locations $u_0,u_1,\ldots$. Equidistribution says that any interval eventually receives its fair share of pins, proportional to its length. A region occupying one thousandth of the unit interval receives asymptotically one thousandth of the visits.

## The connector theorem

**Normality–Equidistribution Theorem.** Let $b\ge 2$ be an integer and $x$ a real number. If the orbit

$$
\{x\},\{bx\},\{b^2x\},\ldots
$$

is interval-equidistributed in $[0,1)$, then $x$ is normal in base $b$.

The proof is short because the definitions have been aligned carefully. Choose any length $k\ge 1$ and any block code $A$ with $0\le A<b^k$. By the floor–interval dictionary, the block appears at position $n$ exactly when the orbit point $u_n$ enters $I_{A,k}$. Equidistribution says that the limiting frequency of these visits equals the interval’s length. But

$$
\left|I_{A,k}\right|
=
\frac{A+1}{b^k}-\frac{A}{b^k}
=
\frac{1}{b^k}.
$$

Therefore the chosen block has limiting frequency $b^{-k}$. Since $k$ and $A$ were arbitrary, every finite block has its expected frequency. That is base-$b$ normality.

The argument is a model of mathematical translation. It does not estimate digit frequencies directly. Instead it identifies every digit event with a geometric interval, then imports the orbit’s uniformity.

## A numerical window, not a proof

A computer can illustrate the bridge. Choose a real number represented to high precision, compute many values of $\{b^n x\}$, and count visits to the equal cells of width $b^{-k}$. The same counts can be described either as interval visits or as extracted digit blocks; the dictionary guarantees exact agreement when arithmetic is exact.

For $N$ samples, one expects counts near $N/b^k$. A useful summary is the largest discrepancy

$$
\max_{0\le A<b^k}
\left|
\frac{C_A(N)}{N}-\frac{1}{b^k}
\right|,
$$

where $C_A(N)$ counts occurrences of block $A$. Small discrepancy is evidence of balance at the tested scale. It is never a proof of normality, because normality concerns an infinite limit, every block length, and arbitrarily late positions. Finite data can support intuition but cannot close the infinite gap.

## Why famous constants remain difficult

The connector theorem makes the missing ingredient unmistakable. To prove that $\pi$ is normal in base ten, for example, it would suffice to prove that $\{10^n\pi\}$ is interval-equidistributed. Yet no known description of $\pi$ provides the necessary control over this lacunary orbit.

Nor do familiar algebraic labels solve the problem. Rational numbers have eventually periodic expansions and are not normal in any base. But irrationality alone is far too weak: irrational numbers can have deliberately biased digits. Algebraicity also does not determine digit statistics; even $\sqrt2$ is not known to be normal in base ten or base two. Transcendence does not settle the matter either, so the transcendence of $\pi$ and $e$ supplies no shortcut. Algebraic independence results concern polynomial relations, whereas normality concerns the long-term distribution of an exponential sequence modulo one. These are profoundly different kinds of information.

One promising analytic reformulation is Weyl’s criterion. It replaces interval counts by cancellation in exponential sums of the form

$$
\frac{1}{N}\sum_{n=0}^{N-1}
\exp(2\pi i m b^n x),
$$

for each nonzero integer $m$. Showing that every such average tends to zero would establish equidistribution and hence normality. For specific constants, obtaining that cancellation is the formidable step.

## Typical numbers and exceptional names

There is a striking contrast between existence and identification. In a measure-theoretic sense, almost every real number is normal in every fixed base, and indeed almost every real is normal in all integer bases simultaneously. Normality is typical.

Yet the constants people can name most easily are not typical inputs to current methods. Their special formulas and algebraic properties do not readily reveal their digit dynamics. This is a recurring theme in mathematics: a property may hold almost everywhere while resisting proof at every celebrated example.

The bridge from orbit uniformity to block frequency clarifies that mystery rather than dissolving it. Digits are not being treated as mystical artifacts of notation. They are observations of a dynamical system through a finite partition. Every block corresponds to a cell; every occurrence is a visit; every expected frequency is a cell length.

That perspective also points forward. One can seek a converse by approximating arbitrary intervals with base-$b$ cells. One can connect orbit uniformity to exponential sums. One can use ergodic theory to explain why almost every starting point behaves normally. And one can ask what genuinely new number theory would be needed to control the named constants.

The lesson is both precise and humbling. To prove that a constant’s digits are perfectly balanced, it is enough to prove that repeated magnification spreads its fractional parts evenly. The translation is complete. The uniformity of $\pi$, $e$, and $\sqrt2$ remains an open frontier.