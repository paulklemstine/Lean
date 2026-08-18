# Cheating the Pigeonhole: How a Coin Flip Buys You Compression

## The bound everybody knows

Here is the oldest theorem in data compression, and the one that nobody has ever
broken. Suppose you want to squeeze every possible $1000$-bit file into a $999$-bit
file, in such a way that you can always get the original back. There are $2^{1000}$
inputs and only $2^{999}$ outputs. Two different inputs must land on the same
output. When you decompress that output, you have to choose, and half the time
you will choose wrong.

This is the pigeonhole principle, and in the compression world it is a wall. It
says nothing about clever algorithms or fast computers. It is pure counting: if
your decoder must be right on *all* $n$ inputs, your code space needs at least $n$
slots.

Every real compressor lives inside this wall. ZIP does not shrink random noise;
it shrinks *structured* files, and it pays for that by making a few files
slightly longer. The pigeonhole principle is the accountant that makes sure the
books balance.

But look closely at the phrase "right on all $n$ inputs." That is a strong
demand. What if we allow the decoder to be wrong — or better, to *admit* that it
does not know — on a set of inputs that essentially never occurs? A file you will
never see costs you nothing if you cannot decompress it. This is the world of
**almost-lossless compression**, and the question this work answers is: exactly
how much does the wall move, and what does it cost in computer time to stand on
the other side of it?

## Two knobs: how often you fail, and how surprised you are

The first thing you need is a way of saying "essentially never occurs." That is
a statement about the *source*: the probability distribution $\mu$ from which
your data is drawn. The right measure turns out not to be Shannon entropy but
the blunter **min-entropy**
$$H_\infty(\mu) = -\log p_{\max}, \qquad p_{\max} = \max_x \mu(x),$$
which asks only: how likely is the single most likely file? A source with a
heavy favourite is easy to compress; a flat source is hard.

Now soften the demand on the decoder. Let it emit a symbol, or emit "I don't
know." Call the set of source symbols it decodes exactly the **success set**.
Here is the first observation, and it is the pigeonhole principle refusing to
die: *the encoder is injective on the success set*. If two symbols are both
decoded correctly, they cannot share a codeword, because the decoder would have
to answer twice with a single input. So the success set never has more elements
than the code space — no matter how badly the decoder behaves elsewhere.

Multiply by probabilities and the counting bound becomes an information bound:
$$\Pr[\text{success}] \;\le\; |\mathcal{C}| \cdot p_{\max}.$$
Turn it around. If you insist on succeeding with probability at least $1 -
\varepsilon$, then
$$|\mathcal{C}| \;\ge\; \frac{1-\varepsilon}{p_{\max}}, \qquad\text{i.e.}\qquad
\log |\mathcal{C}| \;\ge\; H_\infty(\mu) + \log(1-\varepsilon).$$

That is the exact price of the relaxation. The pigeonhole wall does not vanish;
it slides back by precisely $\log(1-\varepsilon)$ bits. For $\varepsilon = 1\%$
that is about $0.014$ bits — a rounding error. And this is not an artefact of a
lossy proof: for the uniform source on $n$ symbols and any code size $M \le n$,
there is a scheme whose success probability is *exactly* $M/n$. The bound is
attained on the nose, so it cannot be improved.

So the first punchline is deflating and clarifying at once: **randomness does not
buy you rate.** Allowing a $1\%$ failure probability does not let you compress a
uniform source by a meaningful amount. What it buys you is something else
entirely.

## What randomness actually buys

The real gift of the relaxation is that it makes a *stupid* code work.

Shannon's random-coding argument is the most famous proof technique in
information theory: don't design a code, pick one at random and show that the
average one is good. It is beautiful, and it is unsatisfying, because a "random
codebook" is an object of astronomical size that nobody can store and nobody can
decode.

The fix is **universal hashing**. Instead of drawing a fresh random function,
draw a single key $k$ from a small family $H_k : \alpha \to \{1,\dots,M\}$ with
one property: any two distinct symbols collide for at most a $1/M$ fraction of
keys. That is *2-universality*, and the classic example is arithmetic in a prime
field: on pairs $(x_1,x_2)$ over $\mathbb{F}_p$, set
$$h_k(x_1,x_2) = x_1 + k\,x_2 \pmod p, \qquad k \in \mathbb{F}_p.$$
Two distinct pairs collide for at most one of the $p$ keys, because the
collision equation is linear in $k$. This family compresses $p^2$ symbols into
$p$ codewords — half the raw bit-length — and the whole "random codebook" is one
field element.

Now the encoder does the following. It fixes a small list $l$ of *likely*
symbols — the codebook — chosen so that the probability of landing outside it is
at most $\delta$. It sends $h_k(x)$. The decoder scans the codebook and answers
only if **exactly one** entry hashes to the value it received; otherwise it
abstains.

Two things follow, and the second is the one that matters in practice.

**Failure is rare.** Averaging the collision mass over all keys shows that some
key $k$ makes the decoder fail with probability at most $\delta + |l|/M$. The
$\delta$ is "the data was atypical"; the $|l|/M$ is "the hash was unlucky."
Choose $M$ a constant factor larger than the codebook and both terms are small.

**Failure is never silent.** If the true symbol is in the codebook, the decoder
either sees a unique match — and is then provably correct — or sees two matches
and abstains. It cannot confidently return the wrong answer. Silent corruption is
possible only for symbols outside the codebook, and that has probability at most
$|l|/M$ as well.

That last point deserves emphasis, because it is the difference between a
compressor you can deploy and one you cannot. A compressor that occasionally
hands you a plausible-looking wrong file is dangerous. A compressor that
occasionally says "I cannot decode this, send it again" is merely a compressor
with a retransmission policy.

## Making the silence quieter

You can do better, and the mechanism is a nice piece of probabilistic
bookkeeping. A silent error needs *two* coincidences: the symbol must be outside
the codebook (probability $\le \delta$) and it must collide with the codebook
(probability $\le |l|/M$). The naive analysis picks one key that is good for the
second event; a two-region argument picks a key that is simultaneously good on
the whole space and on the complement of the codebook, and the silent-error bound
picks up the extra factor $\delta$:
$$\Pr[\text{silent error}] \;\le\; \frac{2\delta|l|}{M},$$
at the cost of doubling the failure bound to $\delta + 2|l|/M$.

The factor $2$ is not sacred. Thresholding at $c_1$ and $c_2$ with $1/c_1 +
1/c_2 \le 1$ still leaves a key outside both bad sets, and letting the thresholds
slide gives a one-parameter family: for every $\eta > 0$ there is a key with
$$\Pr[\text{silent}] \le (1+\eta)\,\frac{\delta |l|}{M}, \qquad
\Pr[\text{fail}] \le \delta + \Bigl(1+\tfrac{1}{\eta}\Bigr)\frac{|l|}{M}.$$
As $\eta \to 0$ the silent constant tends to $1$, the first-moment optimum. You
can trade "how often it stops" against "how often it lies," continuously.

And if you want the lying gone entirely, append a checksum: a second independent
universal family with $C$ values. Universality is multiplicative under pairing —
the paired family with $K K'$ keys and $MC$ codewords is again 2-universal — so
the silent-error probability drops to $|l|/(MC)$ for $\log C$ extra bits. Ten
bits of checksum buy a factor of a thousand.

## The real obstacle was never the rate

Here is where the story turns. Everything above concerns *how many bits*. But the
naive random-coding decoder scans the entire codebook: $|l|$ hash evaluations per
query. On block sources it is catastrophic. Compress $b$ independent blocks
jointly and the natural codebook is the $b$-fold product of the per-block typical
set, with $|T|^b$ entries. Decoding is exponential in the block length. This —
not the rate — is why textbook random coding is not an algorithm.

Two fixes, both with exact, proved costs rather than $O(\cdot)$ gestures.

**Decode coordinatewise.** Each block gets its own scan against the size-$|T|$
codebook, and the answers are assembled. A union bound over blocks keeps the
failure probability at $b \cdot (\delta + |T|/m)$, while the cost falls from
$|T|^b$ to $b|T|$ — and $b|T| < |T|^b$ whenever $|T| \ge 2$ and $b \ge 3$, so the
gap is real, not asymptotic hand-waving.

**Sort the codebook.** This is the idea that dissolves the remaining problem, and
it is almost embarrassingly simple. One might guess that a logarithmic decoder
requires a hash family that is both 2-universal and *monotone* on every codebook
— a demanding, probably unattainable combination. It doesn't. The encoder chooses
its key *first*, and only then stores the codebook **sorted by hash value**.
Sorting is a permutation of the codebook, so the collision analysis, which sees
only the multiset of hash values, is completely untouched. But the sorted
codebook is a monotone array, and a unique-match query on a monotone array is a
**binary search**.

The resulting decoder does a binary search — at most $\log_2 n + 1$ key
evaluations, proved by strong induction, not estimated — and then two neighbour
comparisons to check that the value it found is not repeated. If it is repeated,
the decoder abstains. Total: at most $\log_2 n + 3$ key evaluations, and *no
silent corruption whatsoever*, with no hypothesis at all on the hash function.
Even a maliciously chosen hash cannot make this decoder lie; the worst it can do
is make it abstain.

Put the two halves together and you get the deliverable: an explicit key with
failure probability at most $\delta + 2|l|/M$, silent corruption at most
$2\delta|l|/M$, and a decoding cost of at most $\log_2|l| + 3$ hash evaluations
instead of $|l|$. Since $\log_2 n + 3 < n$ for every $n \ge 6$, the speedup
begins essentially immediately.

## How do we know we can't do better?

A cost bound is only interesting next to a matching lower bound, and here the
counting argument comes back one last time — now applied to *time* rather than to
*space*.

Model any decoder as an adaptive decision tree: each internal node asks one
Boolean question about the input (one key evaluation) and branches on the answer;
each leaf outputs a symbol. A tree that never asks more than $c$ questions can
reach at most $2^c$ leaves along short paths, so it can output at most $2^c$
distinct symbols. Hence a decoder that is correct on $n$ distinct symbols and
always costs at most $c$ satisfies $n \le 2^c$. Equivalently: **some input forces
at least $\log_2 n$ queries.**

Nothing in that argument assumes the queries are comparisons, or that the tree
comes from a hash family, or anything at all about the algorithm's structure. It
is a converse for *every* adaptive Boolean-query decoder. Against it, the
sorted-codebook decoder at $\log_2 n + 3$ is optimal **up to an additive $3$**.
The same counting shows that $b$ independent coordinatewise decoders must cost at
least $b\log_2 n$ in total, so the block scheme is optimal in the same sense.

## Lists, and an exponential surprise

One last relaxation. Suppose the decoder may return a short *list* of candidates
rather than a single answer, and we count it a success if the truth is on the
list. Counting again gives the price: $\Pr[\text{success}] \le T|\mathcal{C}|
p_{\max}$, so a list of length $T$ relaxes the rate bound by exactly $\log T$
bits — and no more.

What you get in return is more interesting than what you pay. With plain
2-universality, allowing $T$ candidates improves the failure probability from
$\delta + |l|/M$ to $\delta + |l|/(TM)$: a linear gain, because a first-moment
estimate on the number of collisions is all that 2-universality provides.

Upgrade the hash family to $(T{+}1)$-wise independence and the gain becomes
exponential. The right statistic is not the number of collisions but the number
of *$T$-element sets* of colliding partners — the $T$-th factorial moment. A
double count over $T$-subsets yields
$$M^T \sum_k \binom{c_k}{T} \;\le\; K \binom{|l|}{T},$$
where $c_k$ is the number of collision partners under key $k$, and the failure
probability drops to
$$\delta + \binom{|l|}{T}\big/M^T \;\le\; \delta + \Bigl(\frac{|l|}{M}\Bigr)^{T}.$$
A list of three candidates cubes the error term.

The catch used to be the key. The obvious $(T{+}1)$-wise independent family is
*all* functions, which needs $M^{|\alpha|}$ keys — exponentially long advice.
Degree-$T$ polynomials over a prime field,
$$h_c(x) = c_0 + c_1 x + \cdots + c_T x^T \pmod p,$$
do the job with only $p^{T+1}$ keys, and the proof is Vandermonde: two
coefficient vectors agreeing at $T{+}1$ distinct points are equal. Concretely,
over $\mathbb{F}_{101}$ with a ten-element codebook and $T = 3$, the key is $27$
bits — instead of the $101^{101}$ keys of the full family — and the failure
probability is at most $1/100 + 1/1000$ with lists of length at most $3$.

## How much randomness do you actually need?

Every one of these theorems begins "there exists a key," which means the encoder
must store $\log_2 K$ bits of advice. How small can $K$ be? The pigeonhole
principle answers again, now aimed at the key space.

A 2-universal family with at least one key, $M \ge 2$ values, on a domain of size
$n$, must satisfy $n \le M^K$, so $K \ge \log_M n$: no constant-size family is
universal on an unbounded source. But integrality does much better. The number of
keys on which two fixed symbols collide is a *natural number* bounded by $K/M$;
so if $K < M$ that number is $0$, meaning every hash in the family is injective —
impossible once $M < n$. Therefore any family that compresses at all has
$$K \ge M.$$
The encoder's advice must be at least as long as the codeword it produces. And if
the code space is a $c$-th root of the source ($n \le M^c$) then $n \le K^c$: the
key space is polynomially large in the source, so no compressing 2-universal
family has $\mathrm{poly}(\log n)$ keys.

Is $K = M$ achievable? Yes — the inner-product family over $\mathbb{F}_p$ has
exactly $K = M = p$ on a source of $p^2$ symbols. One codeword's worth of advice
is necessary, and one codeword's worth is enough.

## The shape of the answer

Step back and the picture is unusually clean, with a matching converse at every
level.

*Rate*: allowing failure $\varepsilon$ relaxes the pigeonhole bound by exactly
$\log(1-\varepsilon)$, and the relaxed bound is attained. Randomness does not buy
compression.

*Reliability*: a universal hash plus a unique-match rule never lies about a
codebook symbol, and the residual silent-error probability can be pushed to
$(1+\eta)\delta|l|/M$ for any $\eta > 0$, or below any target at $\log C$ extra
checksum bits.

*Time*: sorting the codebook after key selection turns the exponential-looking
random-coding decoder into a binary search costing at most $\log_2 n + 3$
evaluations, and an information-theoretic decision-tree argument shows no
decoder whatsoever can beat $\log_2 n$.

*Randomness*: the key must be at least as long as a codeword, and a single field
element suffices.

The moral is worth stating plainly, because it inverts the usual folklore.
Monte-Carlo compression is not a way around the counting bound — the counting
bound barely moves. It is a way around the *algorithmic* obstruction that made
random coding a proof technique rather than a program. Once you stop demanding
that the code be right on files you will never see, the code can be a hash
function, the codebook can be sorted, and the decoder can be a binary search
that, on the rare bad day, has the good manners to say so.
