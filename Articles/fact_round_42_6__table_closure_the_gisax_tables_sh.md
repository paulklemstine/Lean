# One Curve to Rule Them All: What a Fork of Random Bits Can Tell You

## A very small mystery

Imagine a machine with $n+1$ switches. Each switch is flipped independently by an
unreliable operator who says "on" with probability $p$ and "off" with probability
$1-p$. You are not allowed to see the switches. You are allowed to see exactly one
number: the output of a single dial on the front of the machine.

The dial can be wired in different ways. Maybe it lights up when *all* the switches
are on — an AND. Maybe it lights up when *at least one* is on — an OR. Maybe it
reports the parity of the switches, flickering on and off as each switch changes — a
XOR. Or maybe it is an honest counter, showing how many switches are on — a split
count.

Now the question: **how much does the dial tell you about switch number zero?**

This is the "fork" problem. A single hidden source fans out into many bits; a single
scalar readout collapses them back into one number; and we want to know how much of
one particular bit survives the round trip. The question is not exotic. It is the
question behind side-channel leakage in cryptographic hardware, behind feature
attribution in a network whose neurons pool many inputs, behind identifiability in
any measurement that aggregates. Every time an engineer asks "can I recover this
one variable from that one summary statistic?", they are asking a fork question.

For years the four wirings above — call them $A$ (AND), $g$ (OR), $X$ (XOR) and
$\mathrm{Is}$ (split count) — were studied by *measuring* them. One tabulates the
correlation between the hidden bit and the readout, at fork size $2$, at size $3$,
… out to whatever size the arithmetic survives, and one reads patterns off the
table. The tables were suggestive. They also, as it turns out, contained two
mirages.

This article is about what happens when you stop measuring the table and compute it.

## The right way to ask "how much?"

Fix the number of switches at $n+1$, index them $x_0, x_1, \dots, x_n$, and let each
be $1$ with probability $p$ and $0$ with probability $1-p$, independently. A
**readout** is any real-valued function $F$ of the whole switch pattern. The natural
scalar measure of how much $F$ reveals about the designated bit $x_0$ is the squared
Pearson correlation, which we call the **leakage**:

$$
\mathcal{L}(F) \;=\; \frac{\operatorname{Cov}(x_0, F)^2}{\operatorname{Var}(x_0)\,\operatorname{Var}(F)} .
$$

It sits between $0$ and $1$. It is $1$ when $F$ is an invertible affine function of
$x_0$ alone, and $0$ when the readout's fluctuations are uncorrelated with the bit.
Crucially, it is blind to relabelling: multiplying the dial's scale by $7$ and adding
$3$ does not change what the dial tells you, and it does not change $\mathcal{L}$
either.

With that convention, the four channels are

- $A(p,n) = \mathcal{L}(\text{AND of all } n+1 \text{ bits})$,
- $g(p,n) = \mathcal{L}(\text{OR of all } n+1 \text{ bits})$,
- $X(p,n) = \mathcal{L}(\text{parity of all } n+1 \text{ bits})$,
- $\mathrm{Is}(p,n) = \mathcal{L}(x_0 + x_1 + \cdots + x_n)$.

Four different-looking questions. Four different-looking answers, if you compute
them one at a time — each one an unlovely ratio of powers of $p$ and $1-p$.

## The collapse

Here is the discovery that closes the subject. Define, for a real parameter $t \ge 0$
and an integer $n \ge 0$, the **fork profile**

$$
\Phi(t,n) \;=\; \frac{t^n}{1 + t + t^2 + \cdots + t^n}.
$$

It is one of the simplest rational functions imaginable: the last term of a geometric
sum divided by the whole sum. When $t < 1$ it can also be written
$\Phi(t,n) = t^n(1-t)/(1-t^{n+1})$, and at $t=1$ every term is equal so
$\Phi(1,n) = 1/(n+1)$.

**Theorem (Channel Collapse).** *For every bias $0 < p < 1$ and every fork size,*

$$
A = \Phi(p, n), \qquad
g = \Phi(1-p, n), \qquad
X = \Phi\big((1-2p)^2, n\big), \qquad
\mathrm{Is} = \Phi(1, n).
$$

The four channels are not four functions. They are **one function evaluated at four
places**. AND reads the profile at $p$. OR reads it at the complementary bias $1-p$.
XOR reads it at the squared bias gap $(1-2p)^2$. The split count reads it at $1$.

That is the whole story, and everything else in this subject is a corollary of it —
because the profile has one further property that turns comparison into arithmetic.

**Theorem (Strict Monotonicity).** *For every $n \ge 1$, the map $t \mapsto \Phi(t,n)$
is strictly increasing on $[0,\infty)$. Consequently $\Phi(s,n) \le \Phi(t,n)$ if and
only if $s \le t$, for every $n \ge 1$.*

The proof is a two-line comparison: cross-multiplying $\Phi(s,n) \le \Phi(t,n)$ turns
the inequality into $\sum_k s^n t^k \le \sum_k t^n s^k$, and term by term
$s^n t^k \le t^n s^k$ whenever $k \le n$ and $0 \le s \le t$, because the two sides
differ by the factor $(t/s)^{n-k} \ge 1$.

And now the punchline: **the ordering of the channels never depends on the size of
the fork.** Whether you have three switches or three thousand, the ranking of $A$,
$g$, $X$, $\mathrm{Is}$ is the ranking of the four numbers $p$, $1-p$, $(1-2p)^2$,
$1$. Since $(1-2p)^2 < 1$ and $p<1$ and $1-p<1$ for every honest bias, the split
count always wins:

$$
\mathrm{Is} \;=\; \frac{1}{n+1} \;\ge\; \max(A, g, X),
$$

and since the other three parameters are strictly below $1$, all three Boolean
channels decay geometrically to zero as the fork grows, while the split count decays
only like $1/(n+1)$.

## Two mirages, dispelled

The measured tables suggested two things. The exact profile kills both.

**Mirage one: "AND overtakes XOR at $n = 8$."** Tables produced at increasing fork
sizes appeared to show $A$ passing $X$ at a specific size. But the sign of $A - X$ is
the sign of $p - (1-2p)^2$, which contains no $n$ at all. There is no crossover size,
and there cannot be one: if $A \le X$ at one fork size, then $A \le X$ at *every*
fork size. Whatever the table showed at $n=8$ was a numerical artifact, not a
transition. What is true is a *bias* threshold, not a *size* threshold:

$$
A \ge X \iff p \ge \tfrac14, \qquad A \ge g \iff p \ge \tfrac12 .
$$

**Mirage two: "$X/g \to 2$."** The ratio of the XOR channel to the OR channel was
conjectured to settle at $2$ for large forks. It never does, for any bias. Since
$X/g = \Phi((1-2p)^2,n)/\Phi(1-p,n)$ and $(1-2p)^2 < 1-p$ exactly when $p < 3/4$, the
behaviour is a clean trichotomy:

- if $p < 3/4$: $X/g \to 0$, geometrically — XOR is exponentially weaker than OR;
- if $p = 3/4$: $X = g$ *identically*, at every size, so $X/g \equiv 1$;
- if $p > 3/4$: $g/X \to 0$, so $X/g$ blows up.

The value $2$ is not attained even in the limit. The "rising ratio" seen in the
tables — creeping from about $5.9$ toward $6.4$ — was the beginning of a divergence
being mistaken for a convergence.

## The phase diagram

Because everything is decided by the ordering of $p$, $1-p$, $(1-2p)^2$, the bias
line $(0,1)$ splits into exactly four open regimes separated by three critical
biases, and the picture is the same at every fork size $n \ge 1$:

- $0 < p < 1/4$: $\;A < X < g < \mathrm{Is}$ — the AND is the weakest channel;
- $1/4 < p < 1/2$: $\;X < A < g < \mathrm{Is}$ — the XOR becomes the weakest;
- $1/2 < p < 3/4$: $\;X < g < A < \mathrm{Is}$ — the AND overtakes the OR;
- $3/4 < p < 1$: $\;g < X < A < \mathrm{Is}$ — the OR is now the weakest.

The three walls are exact coincidences that hold at *every* size: at $p = 1/4$ the
AND and XOR channels merge; at $p = 1/2$ the AND and OR channels merge; at $p = 3/4$
the XOR and OR channels merge. The three Boolean channels are never all equal at once
— there is no triple point. And at the unbiased point $p = 1/2$ the XOR channel is
exactly zero: the parity of an even coin's bits is statistically independent of any
single one of them, the classic reason parity is beloved by cryptographers.

At $p = 1/3$ with $25$ switches, the exact table reads

$$
X = \frac{1}{89737248461481573596281}, \quad
A = \frac{1}{423644304721}, \quad
g = \frac{16777216}{847255055011}, \quad
\mathrm{Is} = \frac{1}{25},
$$

that is, roughly $1.1 \times 10^{-23} < 2.4 \times 10^{-12} < 2.0 \times 10^{-5} <
4.0 \times 10^{-2}$. Twenty-one orders of magnitude separate the weakest channel from
the strongest. Reading such a table off floating-point simulation is exactly how
mirages are born.

## Why one curve? Because products are all alike

The collapse is not a coincidence of three lucky Boolean gates. It is a theorem about
the entire class of readouts that multiply across coordinates.

**Theorem (Product Universality).** *Let $c$ be any non-constant real function of a
single bit, and let $F(x) = \prod_{i} c(x_i)$. Write $m = \mathbb{E}\,c(x_i)$ and
$s = \mathbb{E}\,c(x_i)^2$ for its first two moments. Then*

$$
\mathcal{L}(F) \;=\; \Phi\!\left(\frac{m^2}{s},\, n\right).
$$

AND is the case $c(1)=1, c(0)=0$, giving $m = s = p$ and parameter $p$. NOR is
$c(1)=0, c(0)=1$, giving parameter $1-p$; and since leakage is unchanged by affine
rescaling, OR — which is $1$ minus NOR — inherits it. Parity in $\pm 1$ form is
$c(1)=-1, c(0)=1$, giving $m = 1-2p$, $s = 1$, parameter $(1-2p)^2$. Three gates,
one formula.

The theorem also explains why the split count is out of reach for this whole family.
By the variance identity
$s - m^2 = p(1-p)\,\big(c(1)-c(0)\big)^2 > 0$,
every non-constant product readout has parameter $m^2/s$ **strictly** below $1$.
Since $\Phi$ is strictly increasing, every product readout leaks strictly less than
$1/(n+1)$, decays to zero, and — the rigidity again — can never swap order with
another product readout as the fork grows.

## Why the counter wins: symmetry alone

There is a deeper reason the split count sits on top, and it has nothing to do with
AND, OR or XOR. Call a readout **symmetric** if permuting the switches does not
change it: it depends on *how many* are on, not on *which*.

**Theorem (Symmetric Optimality).** *Every symmetric readout of an $(n+1)$-bit fork
satisfies $\mathcal{L}(F) \le 1/(n+1)$, and the Hamming weight attains the bound.*

The proof is one of those arguments that feels like a magic trick until you see the
gears. Because the bits are exchangeable and $F$ is symmetric, $F$ must be correlated
with each bit exactly the same amount; summing over all $n+1$ bits,
$\operatorname{Cov}(w, F) = (n+1)\operatorname{Cov}(x_0, F)$ where $w$ is the Hamming
weight. Now apply Cauchy–Schwarz, $\operatorname{Cov}(w,F)^2 \le \operatorname{Var}(w)\operatorname{Var}(F)$,
and use $\operatorname{Var}(w) = (n+1)p(1-p)$. The factors of $(n+1)$ do not cancel —
one survives on the wrong side — and out drops the bound.

Even better, the *equality* case is completely determined.

**Theorem (Uniqueness of the Optimum).** *A symmetric readout attains
$\mathcal{L}(F) = 1/(n+1)$ if and only if $F = \alpha w + \beta$ for some
$\alpha \neq 0$: an honest, non-degenerate affine function of the count.*

So the counter is not merely one good design among many. Up to changing the units on
the dial, **it is the unique optimal symmetric readout**. Any symmetric wiring that
throws away part of the count — AND, OR, XOR, thresholds, medians, majorities — pays
for it in leakage.

## A conservation law for leakage

One last structural fact, and it applies to *every* readout whatsoever, symmetric or
not, Boolean or continuous.

**Theorem (Total-Leakage Sum Rule).** *For any readout $F$ of an $N$-bit fork,*

$$
\sum_{i=1}^{N} \frac{\operatorname{Cov}(x_i,F)^2}{\operatorname{Var}(x_i)\operatorname{Var}(F)} \;\le\; 1,
$$

*with equality precisely when $F$ is an affine function of the bit indicators. The
slack is exactly the normalised mean square of $F$'s nonlinear part.*

This is Bessel's inequality in disguise: the $N$ centred bit indicators are an
orthogonal system in the space of readouts under the fork's own inner product, and
the sum of squared normalised projections of $F$ onto them cannot exceed $\|F\|^2$.
Leakage is a conserved budget of total size one, to be shared among $N$ bits.

Two immediate consequences deserve their own names. First, a **pigeonhole**: for any
threshold $\tau > 0$, the number of bits that a single readout leaks at level $\tau$
or above is at most $1/\tau$. Second, its sharpest instance: **at most one bit of a
fork can be more than half-leaked by any single readout**. You cannot build a dial
that half-reveals two different switches. And the split count sits exactly at the
saturation boundary: its $n+1$ leakages are each $1/(n+1)$, summing to exactly $1$.
It is not merely the best symmetric readout — it is the *maximally efficient*
allocator, spending the entire leakage budget and spreading it perfectly evenly.

## What it means

Strip away the machinery and three sentences remain.

*Aggregation is lossy in a very precise way.* A readout built by multiplying across
coordinates loses information about any one coordinate geometrically fast, at a rate
set by a single number — the ratio of the squared mean to the mean square of its
per-bit factor.

*Rankings are structural, not empirical.* Which of two product readouts leaks more is
a property of their parameters, fixed once and for all. Any table that shows two such
channels trading places as the fork grows is showing you the limits of your
arithmetic, not a feature of the world.

*Leakage is conserved.* Every measurement device that summarises $N$ independent
sources into one number has exactly one unit of correlation to distribute, and only
linear devices spend all of it. The counter spends it perfectly evenly; a gate spends
almost none of it at all.

For hardware designers, the moral is bracing: if you want a summary statistic that
hides its inputs, do not use a linear one, and beware of counters. If you want one
that reveals them, do not use a deep product. And if you want to know which, do not
build a table — read the parameter.
