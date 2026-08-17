# The Files That Are Already Compressed — And the Ones That Only Look It

## A hard drive full of dice

Somewhere on your computer, right now, there is a file that contains no
information at all.

Not an empty file — a *big* one. A megabyte of terrain data for a procedurally
generated game world. A folder of Monte Carlo simulation traces. A synthetic
test corpus someone generated to benchmark a database. Open any of them in a
hex editor and you will see what looks like pure noise: no repeated words, no
runs of zeros, nothing a standard compressor can grab hold of. Feed it to a
zip utility and it will come back roughly the same size, sometimes slightly
larger. By every statistical measure, the file is incompressible.

And yet the whole megabyte was conjured out of a single 32-bit number — the
seed of a pseudo-random number generator — plus a few lines of arithmetic. The
information content of the file is not one megabyte. It is four bytes. Somebody
just threw away the four bytes and kept the megabyte.

This article is about the mathematics of getting those four bytes back: how to
recognize that a stream of data was produced by a deterministic generator, how
many observations you need before that recognition is *provably* correct, how
to invert the generator and recover the seed exactly, and — the sobering part —
exactly how rare such files are, so that nobody mistakes this trick for a
general-purpose compressor.

## The universal shape of a cheap generator

Almost every fast pseudo-random generator in practical use is, underneath a
thin cosmetic layer, a **linear recurrence**. A stream of symbols
$x_0, x_1, x_2, \dots$ drawn from a field $F$ obeys an order-$L$ linear
recurrence with **tap vector** $c = (c_0, \dots, c_{L-1})$ if

$$x_{n+L} \;=\; \sum_{i=0}^{L-1} c_i\, x_{n+i} \qquad \text{for every } n \ge 0 .$$

Each new symbol is a fixed linear combination of the previous $L$. Hardware
engineers call this a *linear feedback shift register*: you keep $L$ symbols in
a row of cells, tap some of them, combine them, and shift the result in at one
end. It is the cheapest interesting generator that exists — a handful of gates,
one clock cycle per symbol — and it is everywhere: in stream ciphers, in test
pattern generators, in scrambler circuits for Ethernet and satellite links.

The first thing to notice is that such a stream is completely determined by
$2L$ numbers: the $L$ taps and the $L$ symbols of the seed. Everything after
that is forced. This is the **exact-replay theorem**, and it is the foundation
of everything below.

> **Theorem (Exact replay).** Suppose a stream $x$ obeys the order-$L$ recurrence
> with tap vector $c$. Then $x$ is bit-for-bit identical to the stream produced
> by running the register with taps $c$ from the seed consisting of $x$'s own
> first $L$ symbols. In particular, storing $(c, x_0, \dots, x_{L-1})$ loses
> nothing whatsoever.

The proof is a two-line induction, but it is worth spelling out because the
same idea recurs throughout: if two streams obey the *same* recurrence and agree
on any window of $L$ consecutive symbols, then they agree on the next symbol
(both are the same linear combination of the window), hence on the window
shifted by one, hence — by induction — forever. Rigidity is the whole story.
A linear recurrence has no memory beyond its window, so agreeing on one full
window is agreeing on everything.

This is what makes the compression claim *falsifiable* in the strictest sense.
We are not claiming statistical similarity. We are not claiming that a model
predicts the file well. We are claiming that a specific $2L$-symbol program,
fed to a fixed decoder that just runs the register, reproduces the file
**exactly**, and you can check it by running it.

## The catch: nobody hands you the taps

Exact replay assumes you already know the recurrence. In the real problem you
have a file and no idea what made it. You must recover the taps from the data
itself. And here a genuine difficulty appears: many different registers can be
consistent with a finite chunk of data, and the more symbols you look at, the
fewer survive. How many do you need before the answer is unambiguous?

The classical answer, engineered into the Berlekamp–Massey algorithm in the
1960s, is **$2L$**. Twice the register length. Not $L$, not $L+1$, not
$L\log L$ — exactly $2L$, and it is sharp. The reason is one of those arguments
where a change of language does all the work.

**Streams as polynomials.** Let $S$ be the *shift operator* that takes the
stream $(x_0, x_1, x_2, \dots)$ to $(x_1, x_2, x_3, \dots)$. Shifting is
linear, so any polynomial in $S$ acts on streams: $S^k$ shifts by $k$ places,
sums and scalar multiples act coefficientwise. This turns the space of all
streams into a module over the polynomial ring $F[X]$, with $X$ acting as $S$.

Now attach to the recurrence its **characteristic polynomial**

$$\chi(X) \;=\; X^{L} - \sum_{i=0}^{L-1} c_i X^{i}.$$

Apply $\chi(S)$ to a stream and read off the value at position $n$: you get
exactly $x_{n+L} - \sum_i c_i x_{n+i}$ — the recurrence's residual. So:

> **Theorem (Annihilation).** A stream obeys a linear recurrence if and only if
> the characteristic polynomial of that recurrence, acting through the shift
> operator, annihilates the stream.

"Obeys a recurrence" and "is killed by a polynomial" are the same statement.
And that dictionary is a two-way street: given *any* monic polynomial $r$ of
degree $m$, one can write down the order-$m$ recurrence whose characteristic
polynomial is precisely $r$ — read the taps off the coefficients of $r$, with a
sign flip. Monic polynomials of degree $m$ and order-$m$ registers are the same
objects wearing different clothes.

**Why $2L$.** Say the *linear complexity* of a stream is the smallest $L$ for
which some order-$L$ register generates it. Take two streams $x$ and $y$, both
of complexity at most $L$, annihilated by monic polynomials $p$ and $q$ of
degree $L$. Then the product $pq$ — monic, degree $2L$ — annihilates both, and
therefore annihilates the difference $x - y$. Translating back through the
dictionary: $x - y$ obeys some order-$2L$ recurrence. In other words:

> **Theorem (Subadditivity).** Linear complexity is subadditive: if $x$ has
> complexity at most $L$ and $y$ has complexity at most $M$, then $x \pm y$ has
> complexity at most $L + M$.

But a stream of complexity at most $2L$ whose first $2L$ symbols all vanish is
the zero stream — that is exact replay again, applied to the all-zero seed. So
if $x$ and $y$ agree on the first $2L$ symbols, their difference starts with
$2L$ zeros, is annihilated by a degree-$2L$ polynomial, and must be zero
everywhere. Hence:

> **Theorem ($2L$ samples suffice).** Two streams of linear complexity at most
> $L$ that agree on their first $2L$ symbols agree forever.

This is the correctness guarantee that lets a detection pipeline *commit*. See
$2L$ symbols, fit any order-$L$ register that matches them, and you have not
merely fitted the window — you have fitted the entire infinite stream. Every
remaining symbol of the file is then predicted, and the prediction is exact.
Flip it around and it also says the window cannot be shortened: two order-$L$
registers with different outputs must already differ somewhere in the first
$2L$ symbols, or they would be the same stream.

And $2L$ is genuinely necessary. Over the binary field with $L = 3$, the
streams $001\,000\,000\dots$ and $001\,001\,001\dots$ both have complexity at
most $3$; they agree on the first five symbols and part company at the sixth,
which is symbol number $2L - 1$. Shave one symbol off the window and
identification becomes ambiguous.

## When is the answer unique?

Suppose your detector finds *a* tap vector consistent with the data. Is it *the*
tap vector? Not always — and the counterexample is embarrassingly simple. The
all-zero stream is generated by every register in existence, whatever its taps.
Any statement of the form "the taps of a linear stream are determined by the
stream" is simply false as it stands.

The fix is not a cleverer proof, but a better question. Look at the
**state windows** of the stream: the vectors
$w_n = (x_n, x_{n+1}, \dots, x_{n+L-1})$ obtained by sliding a length-$L$ frame
along the data. Stack them and you get a Hankel matrix. The right question is
whether those windows *span* the whole space $F^{L}$.

> **Theorem (Uniqueness criterion).** For a stream obeying an order-$L$ linear
> recurrence with taps $c$, the following are equivalent:
> (i) $c$ is the only tap vector generating the stream;
> (ii) the state windows of the stream span $F^{L}$.

The forward direction is linear algebra: if two tap vectors $c$ and $d$ both
work, their difference $e = c - d$ is orthogonal to every state window; if the
windows span everything, $e$ is orthogonal to everything and hence zero. The
converse is the interesting one: if the windows fail to span, there is a nonzero
linear functional vanishing on all of them, and adding its coefficient vector to
$c$ produces a genuinely *different* register generating the very same stream.
Degeneracy is not a proof artifact — it is real ambiguity in the data, and no
algorithm can resolve it.

The all-zero stream is the extreme case: its windows span nothing, and all
$2^L$ tap vectors are consistent. A run over binary registers of order $4$
makes the pattern vivid: whenever the window rank is $r$, exactly $2^{L-r}$
tap vectors fit the data. Spanning is therefore the precise boundary between
well-posed and ill-posed recovery.

## The other big family, for free

Shift registers are one clan of generators. The other workhorse of the last
half-century is the **linear congruential generator**: pick a modulus $m$, a
multiplier $a$ and an increment $b$, and iterate

$$x_{n+1} \;=\; a\,x_n + b \pmod m .$$

This is the generator behind countless `rand()` implementations. It looks
different from a shift register — it has that pesky additive constant $b$, which
is not linear. But differencing kills it. Subtract consecutive terms:
$x_{n+2} - x_{n+1} = a(x_{n+1} - x_n)$, and rearranging gives

$$x_{n+2} \;=\; (1+a)\,x_{n+1} - a\,x_n .$$

> **Theorem (One detector, two families).** Every linear congruential stream
> satisfies the order-$2$ linear recurrence with tap vector $(-a,\, 1+a)$.

So the whole apparatus above — the $2L$ window, the uniqueness criterion, the
exact-replay guarantee — applies verbatim to congruential generators, with
$L = 2$. You do not need a second detector; you need four observations. From
those four numbers the multiplier and increment fall out, and then the seed.

Recovering the seed from a state observed at time $n$ can be done in two ways,
and both are exact. **Backwards**, if the multiplier $a$ is invertible modulo
$m$: the inverse step is $y \mapsto a^{-1}(y - b)$, and applying it $n$ times to
the state at time $n$ returns the seed on the nose. **Forwards**, which is
stranger and rather beautiful: on a finite state space an invertible multiplier
makes the update map a *bijection*, so every orbit is **purely periodic** — no
transient tail, every state eventually returns to itself. Consequently the seed
is reachable from any observed state simply by *running the generator forward*
long enough. An attacker with no modular-inverse routine, or a compressor that
only knows how to call the generator, can still get the seed. Rewinding is a
special case of running ahead.

The counting side is equally blunt. A congruential generator over the integers
modulo $m$ has three parameters — multiplier, increment, seed — so at most
$m^3$ distinct streams of any length can be congruential. Once a file has more
than three symbols, most files are not congruential output, and a detector that
claims otherwise has a false-positive rate you can bound on the back of an
envelope: $m^{3-N}$ for length-$N$ files.

## The census: how much data is really seed-compressible?

Now for the reckoning. Call an $N$-bit file **$L$-seed compressible** if some
binary shift register of order $L$ emits it verbatim. The detector's promise is
that such a file has a description of length $2L$ bits — the taps and the seed —
*no matter how long the file is*. A megabyte of terrain from a 32-bit register
compresses to 64 bits. That is a compression ratio of about $10^{-5}$, and it is
lossless in the strongest possible sense: the decoder reruns the register and
gets the file back bit for bit.

The catch is arithmetic, and it is fatal to any hope of generality.

> **Theorem (Rarity).** At most $4^{L}$ files of any length are $L$-seed
> compressible: $2^L$ tap vectors times $2^L$ seeds. Out of the $2^N$ files of
> length $N$, at most a fraction $2^{2L-N}$ are seed compressible.

If $L = 32$ and $N$ is a megabyte, that fraction is $2^{64 - 8388608}$. Vanishing
does not begin to describe it. And the bound is never even tight, because the
parameter count over-counts:

> **Theorem (The naive count is never tight).** All $2^L$ registers launched
> from the all-zero seed emit the same all-zero file, so at most
> $4^L - 2^L + 1$ files are $L$-seed compressible.

Even that is an over-estimate. A stream is determined not by the register that
happens to generate it but by its *minimal* connection polynomial, and many
different registers share one. Counting the distinct infinite streams of
complexity at most $L$ over the binary field for $L = 1, \dots, 8$ gives

$$3,\; 11,\; 43,\; 171,\; 683,\; 2731,\; 10923,\; 43691,$$

against the parameter counts $4, 16, 64, 256, \dots$ At $L = 3$: forty-three
distinct streams from sixty-four parameter pairs, comfortably below the proved
ceiling of fifty-seven. These numbers match $\tfrac{1}{3}(2\cdot 4^{L} + 1)$
exactly in every case computed — a striking regularity suggesting that the true
density of realizable streams inside the parameter space converges to $2/3$.
That formula is, at present, an observed pattern rather than a proved theorem,
and closing that gap is one of the natural next steps.

There is one large and genuinely common family that the detector *does* catch:
periodic data. A file whose bits depend only on the index modulo $p$ is exactly
the output of the order-$p$ register with taps $(1, 0, \dots, 0)$ — the register
that simply recirculates its seed. So every periodic file has a $2p$-bit
description, and periodic or run-structured regions are real: padding, fill
patterns, repeated headers, texture tiles. The detector is not useless. It is
narrow.

## The two boxes do not cover the room

The practical proposal that motivates all this is a **router**: examine each
file, and send it either to the "seed-compressible" branch (recover the seed,
store $2L$ bits) or to the "model-compressible" branch (hand it to whatever
general-purpose compressor you like). Two boxes, everything sorted.

It does not work, and the reason is the oldest argument in information theory,
which no amount of clever detection can dodge.

> **Theorem (Router dichotomy).** Fix any decompressor $D$ whatsoever for the
> model branch, and any budgets $L$ (seed order) and $d$ (bits of modelling
> gain demanded). Whenever the budgets are small compared with the file length
> $N$ — precisely, whenever $2^{d}\,2^{2L} + 2^{N+1} < 2^{d}\,2^{N}$ — there
> exists an $N$-bit file that is *neither* $L$-seed compressible *nor*
> compressible by $d$ bits under $D$.

Both boxes are small for the same reason. Descriptions of length below $N - d$
number fewer than $2^{N-d+1}$, so at most a $2^{-d}$-ish fraction of files can
gain $d$ bits under any fixed decompressor. Seed-compressible files number at
most $2^{2L}$. Add the two and, as long as the budgets are modest, the sum is
smaller than $2^N$; there is a file in neither pile. Concretely: among $64$-bit
files, whatever compressor you install on the model branch, some file is neither
the output of an order-$8$ register nor compressible by even four bits.

That is not a defect of this approach; it is the pigeonhole principle, and it
survives the addition of pseudo-random detection intact. What detection changes
is not *whether* the bound applies but *which* files land on the good side of
it. Standard compressors are built around statistical structure — repeated
substrings, skewed symbol frequencies, local correlations. Register output has
none of that, and yet it has almost no information content. Adding a seed
detector to a compression pipeline moves an entire class of files, invisible to
every statistical method, from the incompressible pile to the four-bytes pile.
It does not shrink the incompressible pile as a whole. Nothing can.

## What this is really about

There is a philosophical point buried in the engineering here, and it is worth
saying plainly. "Random-looking" and "information-rich" are not the same
property, and the gap between them is precisely the gap between statistics and
computation.

The output of a good shift register passes essentially every statistical test
you can name — balanced frequencies, flat autocorrelation, uniform block
statistics — and its Kolmogorov-style description complexity is a few dozen
bits. Its apparent randomness is a *statistical* illusion sustained by a
*computational* secret. The detector described above cracks that illusion, not
by finding statistical structure (there is none to find) but by hypothesizing
the mechanism and testing it exactly: fit a register to $2L$ symbols, replay,
and compare bit for bit. Pass, and you have replaced the file by its cause.
Fail, and you have learned something definite.

The mathematics tells you the exact price of that test. You need $2L$
observations, no fewer and no more. The answer is unique exactly when the
sliding windows of the data span the state space. The families collapse: shift
registers and congruential generators are the same kind of object, one at order
$L$ and one at order $2$. Recovery is exact, in both directions, and verifiable
by replay. And the whole enterprise buys you a set of files of density
$2^{2L-N}$ — enormous compression on a vanishing sliver of the universe. Which
is, when you think about it, a fair description of every good compression idea
ever invented. The art is picking the right sliver.
