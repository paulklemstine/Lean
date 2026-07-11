# Deepening: The Fractal Dimension of Mathematical Truth

## How much truth is there?

Ask a strange question: *how much* mathematical truth is there? Not which
statements are true — that is the ordinary business of mathematics — but how the
true statements are distributed among all possible statements. Are they
scattered like a fine dust, so rare that they are almost invisible? Or are they
thick, crowding out the false ones? And is there a single number that measures
their abundance?

It turns out there is. And the answer is not a whole number. To measure the
density of truth we need the same idea that measures coastlines and snowflakes:
**fractal dimension**.

## Statements as strings, theories as filters

Begin with a concrete picture. Fix a way of writing mathematical statements as
finite strings of bits — zeros and ones. This is not exotic: every theorem you
have ever read is, after encoding, a finite binary string. A statement of length
$n$ is simply one of the $2^n$ possible bit-strings of that length.

Now, most bit-strings are not *accepted* by any given standard of truth. A
**theory** is a rule that, for each length $n$, selects the finite set of
length-$n$ strings it accepts. Write $T(n)$ for that set and
$$\mathrm{count}(T, n) = |T(n)|$$
for how many statements of length $n$ the theory accepts. The theory of *all*
strings accepts everything, so its count is the full $2^n$. A theory that
accepts almost nothing has a tiny count. Between these extremes lies everything
interesting.

## Counting like a fractal

How fast does $\mathrm{count}(T,n)$ grow? If it grows like $2^{dn}$ for some
exponent $d$ between $0$ and $1$, then the accepted set behaves like a fractal of
dimension $d$ sitting inside the space of all strings. To extract that exponent,
take a logarithm and normalize by the length:
$$\dim(T) \;=\; \limsup_{n \to \infty} \frac{\log_2 \mathrm{count}(T, n)}{n}.$$
This is the **box-counting dimension** of the theory — the same recipe used to
say the Cantor set has dimension $\log_2/\log_3 \approx 0.63$, or that a coastline
has dimension around $1.25$. Here it measures the density of truth on a
logarithmic scale.

Two facts are immediate and reassuring. Because a theory can accept at most all
$2^n$ strings, we have $\mathrm{count}(T,n) \le 2^n$, so
$$0 \le \dim(T) \le 1$$
for **every** theory. Dimension zero means truth is vanishingly sparse (the
count grows slower than any exponential); dimension one means truth is as
abundant as it could be. And dimension is **monotone**: if one theory accepts
everything another accepts, its dimension is at least as large. More truth never
lowers the dimension.

## The first surprise: one-half

In the original study of this idea, a specific, natural theory — one that leaves
*half* of the coordinates of a statement free to be true or false and pins the
other half down — was found to have fractal dimension exactly
$$\dim = \tfrac12.$$
Truth, in that model, is sparse but not negligible: it fills a fractal of
dimension one-half, like a shape that is more than a scatter of points but less
than a solid line. It was tempting to read something cosmic into the number
one-half. Is $\tfrac12$ the intrinsic dimension of truth?

## The deepening: every rational is a dimension

The main result of this work says **no** — and does so in the most complete way
possible. The value $\tfrac12$ is not special at all. It is one point of a full
spectrum.

Here is the construction. Fix a period $m \ge 1$ and choose a set $R$ of
*admissible residues* among $\{0, 1, \dots, m-1\}$. Build the **periodic density
theory** $D_{m,R}$ by the following rule: coordinate $i$ of a statement is *free*
— allowed to be either true or false — exactly when $i \bmod m$ lies in $R$;
otherwise the coordinate is forced to be false. Intuitively, the theory sprinkles
its "information-bearing" coordinates periodically, with $|R|$ of them in every
block of $m$.

Counting is now exact. If $\mathrm{free}(n)$ denotes the number of free
coordinates below position $n$, then the number of accepted strings is precisely
$$\mathrm{count}(D_{m,R}, n) = 2^{\,\mathrm{free}(n)}.$$
Every free coordinate doubles the possibilities; forced coordinates contribute
nothing. And the free coordinates arrive with clockwork regularity: each block of
$m$ consecutive positions contributes exactly $|R|$ of them, so
$$|R|\cdot\big\lfloor n/m \big\rfloor \;\le\; \mathrm{free}(n) \;\le\;
|R|\cdot\big\lfloor n/m \big\rfloor + |R|.$$
Dividing $\log_2 \mathrm{count} = \mathrm{free}(n)$ by $n$ and squeezing between
these two bounds, the ratio is trapped and converges to a single clean value:
$$\boxed{\;\dim(D_{m,R}) = \frac{|R|}{m}.\;}$$
The dimension is exactly the **asymptotic density of free coordinates** — the
fraction of positions that carry information.

## Truth fills the rational line

The consequence is striking. By choosing $m$ and $R$, the ratio $|R|/m$ can be
made equal to *any* fraction between $0$ and $1$. Want a theory of dimension
$\tfrac{3}{7}$? Take $m = 7$ and any three admissible residues. Want $\tfrac{2}{5}$?
Take $m = 5$ and two residues. Therefore:

> **Every rational number in $[0,1]$ is the fractal dimension of some theory of
> truth.**

The dimension spectrum of truth is not the lonely point $\tfrac12$; it is the
entire rational unit interval. And the proof is not an abstract existence
argument — it hands you an explicit theory for each target dimension, built by
setting the density of its information-bearing coordinates to exactly the value
you want.

A subtle point makes the whole picture robust: the argument never cares *which*
residues are admissible, only *how many*. Shuffling the free coordinates around
within each period changes nothing. The dimension is a property of density
alone. This is precisely why the entire rational interval, and not some sparse
subset of it, gets covered.

## Why the "limsup" — and when it disappears

The definition uses a $\limsup$ rather than an ordinary limit, and for good
reason: a wildly irregular theory can make the ratio
$\log_2 \mathrm{count}(T,n)/n$ oscillate forever, never settling down. The
$\limsup$ captures the largest scale at which truth is thick, which is the honest
notion of dimension. For the periodic density theories, though, the regularity of
the construction tames the oscillation completely: the ratio converges to a
genuine limit, and $\limsup$ and $\lim$ agree. Regularity buys you a limit;
irregularity genuinely needs the $\limsup$.

## Where this points

Once you see that dimension equals density, natural questions open up. The
periodic construction only realizes *rational* dimensions, because periodic
patterns have rational densities. But the squeeze argument that drives the proof
never used the arithmetic of the period — only that the free-coordinate count
grows like $d\cdot n$ plus a lower-order error. Any coordinate set whose density
is an irrational number $d$ should therefore produce a theory of dimension
exactly $d$, filling the gaps between the rationals and realizing the **entire
real interval** $[0,1]$.

There is more structure waiting. Dimension appears to behave like a well-mannered
algebraic operation: the dimension of a union of theories should equal the
*larger* of the two dimensions (a factor-of-two overlap costs only $1/n$ in the
logarithm and vanishes), while combining two independent theories should *add*
their dimensions, capped at one. And viewed in the space of *infinite*
statements, a density-$d$ theory should carve out a genuine self-similar fractal
— a Cantor-like set of Hausdorff dimension $d$ but Lebesgue measure zero. Truth,
on this reading, is not merely sparse. It is genuinely fractal.

## The picture that emerges

Strip away the machinery and a clean image remains. Encode statements as strings.
Measure how the accepted ones proliferate as statements grow longer. That growth
rate, on a logarithmic scale, is a dimension between $0$ and $1$ — and it equals
the density of coordinates that actually carry information. By dialing that
density, you can build a theory of any rational dimension you like. Truth is not a
solid block, nor a vanishing dust. It is a fractal, and we can now name its
dimension exactly.
