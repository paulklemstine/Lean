# The Hidden Rhythm of the Coefficients

## A drumbeat inside a power series

Some of the most stubborn objects in mathematics are simply lists of numbers.
Take a function built as an infinite sum,
$$F(q) = a_0 + a_1 q + a_2 q^2 + a_3 q^3 + \cdots,$$
and stare at the sequence of coefficients $a_0, a_1, a_2, \ldots$. These lists
appear everywhere: they count the ways of breaking an integer into parts, they
encode the arithmetic of modular forms, and they carry the fingerprints of deep
symmetries in number theory. Yet the sequences themselves often look like noise.
Their sizes swing wildly, their signs seem to flip at random, and no simple
formula predicts the next entry.

And then, sometimes, a rhythm emerges. Look closely at certain families of these
sequences and you notice something almost musical: the signs march in a perfect
beat, **plus, minus, plus, minus**, on and on, as if the coefficients were
keeping time. This is not a coincidence. It is the audible trace of a hidden
oscillation buried in the analytic structure of $F$, an oscillation attached to
a special point on the unit circle called a *root of unity*. This article is
about that rhythm: where it comes from, why it is so robust, and exactly how — and
how rarely — it can be broken.

## Why signs should alternate

To hear the drumbeat, we need to know what controls the coefficients when $n$ is
large. For a wide class of series, the large-$n$ behavior of $a_n$ is governed by
what happens as $q$ approaches a single point $\omega$ on the boundary circle
$|q| = 1$. When $\omega$ is a root of unity — a number satisfying $\omega^m = 1$
— that boundary behavior stamps a repeating pattern onto the coefficients.

The simplest and most important case is $\omega = -1$, the second root of unity.
Here the analysis predicts that, for large $n$, the coefficient looks like
$$a_n = (-1)^n A_n + E_n,$$
where $A_n \ge 0$ is a slowly varying **amplitude** and $E_n$ is a smaller
**error term**. The factor $(-1)^n$ is the oscillation coming from $\omega = -1$;
it wants to make the signs alternate. The amplitude $A_n$ sets the loudness of
the beat, and the error $E_n$ is the background hiss that might occasionally
drown it out.

The logic is then irresistibly simple. Suppose that from some point onward the
amplitude genuinely dominates the noise, meaning
$$A_n > |E_n| \quad \text{for all large } n.$$
Then the sign of $a_n$ is forced to equal the sign of $(-1)^n A_n$, which is just
$(-1)^n$. Consecutive coefficients therefore have opposite signs, and their
product is negative:
$$a_n \, a_{n+1} < 0.$$
That single inequality *is* the alternation. The signs read $+,-,+,-,\ldots$
forever, with no exceptions.

This is more than a toy observation. It is exactly what happens for a function
that arose recently in the study of so-called *false theta functions* — a
partner, in a precise sense, to the celebrated mock theta functions of
Ramanujan. That function, which we will call $v_1(q)$, has coefficients that are
**eventually strictly alternating**: past a certain index the plus–minus rhythm
never once stumbles. In our language, its exceptional set — the collection of
indices where alternation fails — is *finite*.

## What happens when the amplitude falters

The clean result above rests on a strong assumption: that the amplitude $A_n$
*uniformly* beats the error, everywhere, from some point on. But amplitudes are
not always so cooperative. In richer situations, a *second* oscillation — coming
from another root of unity — rides alongside the first. Most of the time the
primary beat dominates. But every so often the two waves interfere destructively,
and the effective amplitude momentarily collapses to nearly nothing. At those
instants the background noise is no longer beaten, and the rhythm can skip.

So we are led to a sharp question. When the amplitude is allowed to degenerate on
a sparse set of indices, how badly can alternation fail? Can the exceptional set
grow from finite to *infinite*? And if it does, is it still negligible in the
sense that matters?

To make "negligible" precise, we use the notion of **natural density**. A set $S$
of natural numbers has *density zero* if the fraction of its members among the
first $N$ integers shrinks to nothing as $N$ grows:
$$\frac{\#\{n < N : n \in S\}}{N} \longrightarrow 0 \quad \text{as } N \to \infty.$$
A density-zero set can still be infinite — it is just vanishingly thin. The even
numbers have density $\tfrac12$; the perfect squares, as we will see, have density
zero.

## An amplitude that vanishes on the squares

Here is a construction, stripped to its bare essentials, that answers the
question completely. Let the amplitude be
$$A_n = \begin{cases} 0 & \text{if } n \text{ is a perfect square},\\ 1 & \text{otherwise},\end{cases}$$
and set the coefficients to
$$a_n = (-1)^n A_n.$$
This is a perfectly legitimate instance of the oscillatory model: the amplitude
$A_n$ is nonnegative and it dominates the (here vanishing) error everywhere
except precisely on the perfect squares, where it degenerates to zero.

Now watch what the signs do. Consider a product of neighbors,
$$a_n \, a_{n+1} = (-1)^n (-1)^{n+1} A_n A_{n+1} = -\,A_n A_{n+1}.$$
If neither $n$ nor $n+1$ is a perfect square, then $A_n = A_{n+1} = 1$ and the
product equals $-1$: alternation holds. But if either $n$ or $n+1$ *is* a perfect
square, one amplitude is zero, the product is $0$, and the strict alternation
$a_n a_{n+1} < 0$ fails. So the exceptional set is exactly
$$\mathcal{E} = \{\, n : n \text{ or } n+1 \text{ is a perfect square}\,\}.$$

This set is clearly **infinite** — it contains every perfect square. The finite
exceptional set enjoyed by $v_1(q)$ is gone. And yet, remarkably, the rhythm is
barely disturbed.

## Counting the stumbles

How thin is $\mathcal{E}$? The perfect squares below $N$ are $0, 1, 4, 9, \ldots$,
and the largest one under $N$ is about $(\sqrt{N})^2$. A quick count shows there
are at most $\sqrt{N} + 1$ of them:
$$\#\{\, k^2 < N \,\} \le \sqrt{N} + 1.$$
Dividing by $N$ and letting $N \to \infty$,
$$\frac{\sqrt{N} + 1}{N} = \frac{1}{\sqrt{N}} + \frac{1}{N} \longrightarrow 0.$$
So the perfect squares have density zero. The exceptional set $\mathcal{E}$ is a
union of the squares and their immediate predecessors, and taking the neighbor
shift into account merely *doubles* the count — at most $2\sqrt{N} + 2$ bad
indices below $N$. Doubling a quantity that already tends to zero changes nothing:
$\mathcal{E}$ also has density zero.

We have therefore produced an explicit sequence for which the sign-alternation
exceptional set is **infinite but density zero**. Put beside the finite
exceptional set of $v_1(q)$, this delivers the punchline:

> **The density-zero conclusion is sharp.** In general one cannot upgrade
> "alternation fails on a density-zero set" to "alternation fails only finitely
> often." The best universal statement is precisely density zero, and the perfect
> squares show it cannot be improved.

The contrast is the whole story. Uniform dominance of the amplitude buys you a
*finite* set of exceptions and a rhythm that is eventually flawless. Merely
*generic* dominance — dominance that is allowed to lapse on a thin set — buys you
only a *density-zero* set of exceptions. Both statements are true, and neither can
be pushed further.

## The general principle behind the count

The perfect squares are just one illustration of a more flexible tool. The
reason the argument works is a simple, reusable **counting criterion**: to show a
set $S$ has density zero, it suffices to find any comparison function $b(N)$ that
bounds the number of elements of $S$ below $N$,
$$\#\{\, n < N : n \in S\,\} \le b(N),$$
and whose growth is *sublinear*, meaning $b(N)/N \to 0$. Squeeze the density
ratio between $0$ and $b(N)/N$, and it is trapped at zero.

This criterion is robust in exactly the ways one wants. If $S$ sits inside a
density-zero set $T$, then $S$ inherits density zero. If $S$ and $T$ both have
density zero, so does their union $S \cup T$ — which is precisely what lets us
absorb the "shift by one" and pass from the squares to the squares-and-their-
neighbors. These closure properties turn a single estimate about squares into a
whole family of sharpness examples.

## Why this matters

At first glance this is a story about the signs of a made-up sequence. But it
speaks to a general phenomenon that recurs across analysis and number theory:
**asymptotic domination breeds order**. Whenever one term in an asymptotic
expansion outshouts the rest, it imposes its own structure — here, a
plus–minus–plus–minus beat — on the whole sequence. The interesting mathematics
lives at the edges, in the rare indices where domination lapses and the imposed
order flickers.

The framework points naturally forward. If the dominant oscillation comes not
from $\omega = -1$ but from a primitive $m$-th root of unity, the signs should
organize into a repeating block of length $m$, with the familiar alternation as
the special case $m = 2$. If the amplitude collapses on the values of a richer
arithmetic object — sums of two squares, say, instead of squares — then the
exceptional set should inherit *that* object's counting law, tying the sign
rhythm directly to classical questions about how integers are represented by
quadratic forms. And if two genuinely competing oscillations interfere, the
density of sign failures should become a continuous, computable function of how
loud each wave is and how well one rotation number can be approximated by
fractions.

There is something quietly satisfying in all of this. A power series is handed to
us as an opaque list of numbers. We listen for the drumbeat, we learn to predict
almost every sign in advance, and we can even name, and count, the precise moments
when the music skips a beat. The noise, it turns out, was a rhythm all along.
