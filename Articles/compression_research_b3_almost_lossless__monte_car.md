# The Pigeonhole's Price: How a Coin Flip Buys You Compression

## A rule you cannot break

Here is one of the most stubborn facts in all of mathematics, and one every
programmer has bumped into: **you cannot compress everything.**

Suppose you want a compressor that takes any file of $n$ bits and produces a
shorter description, and a decompressor that always recovers the original file
exactly. There are $2^n$ possible files. If your compressed descriptions come
from a set of $M$ possible codewords, and every file must be recovered exactly,
then two different files can never receive the same codeword — the
decompressor would have no way to tell them apart. So the encoding map must be
injective, and injectivity forces

$$2^n \le M.$$

That is the **pigeonhole barrier**, and in its general form it says: if an
encoder $E : \mathcal{A} \to \{1, \dots, M\}$ admits a decoder $D$ with
$D(E(x)) = x$ for *every* $x$ in the source alphabet $\mathcal{A}$, then
$M \ge |\mathcal{A}|$. No cleverness escapes it. It is not a statement about
algorithms; it is a statement about counting.

This is why "universal compressors" are snake oil, why zip files of random noise
are bigger than the noise, and why the joke about compressing the internet down
to a single byte is a joke.

But the barrier has a hairline crack in it, and the crack is the word *every*.

## Relaxing "every" to "almost every"

What if we allow the decoder to fail — rarely? Say, with probability at most
$\varepsilon = 10^{-12}$, which is far less likely than a cosmic ray flipping a
bit in your RAM while you read this sentence. This is **almost-lossless
compression**, and it is the setting where Claude Shannon's information theory
lives.

The idea, in one line: most real sources don't produce all $|\mathcal{A}|$
strings with equal enthusiasm. English text, images, sensor readings — they
concentrate on a much smaller **typical set** $S \subseteq \mathcal{A}$. If we
only insist on decoding strings from $S$, we only need to distinguish $|S|$
things, not $|\mathcal{A}|$ things, and $\log_2 |S|$ can be dramatically smaller
than $\log_2 |\mathcal{A}|$.

And here is where the plot thickens, because Shannon's method of *constructing*
such a code is one of the strangest arguments in mathematics: **don't design the
code at all. Roll dice.**

## The random codebook

Pick a random function. Concretely, choose a **codebook** $H$ that assigns to
every string $x \in \mathcal{A}$ a codeword $H(x) \in \{1,\dots,M\}$, with each
of the $M^{|\mathcal{A}|}$ possible functions equally likely. To transmit $x$,
send $H(x)$. To decode a received codeword $c$, list every typical string
$y \in S$ with $H(y) = c$; if there is **exactly one**, output it; otherwise
declare failure.

Why on earth should this work? Because of a single clean count. Fix two distinct
strings $p \ne q$. Among all $M^{|\mathcal{A}|}$ codebooks, how many satisfy
$H(p) = H(q)$? Exactly $M^{|\mathcal{A}|}/M$ of them — a proportion of exactly
$1/M$. Written without any division, so that it is a statement about integers
and nothing else:

$$M \cdot \#\{H : H(p) = H(q)\} = M^{|\mathcal{A}|}, \qquad p \ne q.$$

A random codebook confuses any *fixed* pair of strings with probability exactly
$1/M$. The transmitted string $x$ has at most $|S| - 1$ typical competitors, so
by a union bound the chance that *some* competitor collides with $x$ is at most
$(|S|-1)/M$. Choose

$$M \ \ge\ \frac{|S| - 1}{\varepsilon}$$

and a random codebook decodes $x$ correctly with probability at least
$1 - \varepsilon$.

Look at the rate this buys:

$$\log_2 M \ \approx\ \log_2 |S| \;+\; \log_2 \frac{1}{\varepsilon}.$$

The first term is the true information content of the source. The second is the
entire price of reliability — and it is a *constant*, independent of how long
the message is. Stretch $\varepsilon$ to $10^{-12}$ and you pay forty extra
bits. Once. For the whole message. The pigeonhole barrier, which demanded
$\log_2 |\mathcal{A}|$ bits, has been walked around rather than broken.

## Exactly how often does it fail?

Union bounds are approximations, and it is natural to ask what the truth is. It
turns out the failure probability of uniform random hashing can be written down
in closed form. With $k = |S| - 1$ competitors,

$$\mathbb{P}[\text{failure at } x] \;=\; 1 - \Bigl(1 - \tfrac{1}{M}\Bigr)^{k}.$$

The proof is a pretty induction. Call a codebook *separating* for $x$ against a
competitor set $D$ if $H(y) \ne H(x)$ for all $y \in D$. Adding one new
competitor $a \notin D$ multiplies the number of separating codebooks by exactly
$(M-1)/M$: given the value $H(x)$, the new value $H(a)$ is free to be any of the
$M$ symbols but must avoid one. Iterating gives the exact count of separating
codebooks and hence the formula.

This closed form is worth pausing on, because it explains both of the bounds one
normally sees. Expanding, $1 - (1-1/M)^k \le k/M$ recovers the union bound; and
Bonferroni's second inequality (inclusion–exclusion truncated after two terms)
gives a *lower* bound of the same order. Concretely, if the typical set isn't
too big compared with the codebook — precisely, if $2(k-1) \le M$ — then

$$\mathbb{P}[\text{failure at } x] \ \ge\ \frac{k}{2M}.$$

The two bounds pin the failure probability at $\Theta(k/M)$: the union bound is
tight up to a factor of two. There is nothing to be gained by analysing random
hashing more cleverly.

And that lower bound has teeth. To get failure probability $\le \varepsilon$
from a random codebook you genuinely need $M \gtrsim k/(2\varepsilon)$ — the
factor $1/\varepsilon$ is a real feature of the random construction, not an
artefact of a lazy proof.

Is that factor necessary in principle? No — and this is the interesting tension.
There is a **converse** bound that applies to *any* encoder and *any* decoder
whatsoever, however cleverly designed, randomised, or equipped with side
information: the set of strings on which decoding is exact has size at most $M$.
(The proof is the pigeonhole argument again, restricted to the set where
decoding works: on that set the encoder must be injective.) Consequently, to
decode a $(1-\varepsilon)$ fraction of a typical set $S$ you need
$M \ge (1-\varepsilon)|S|$ — and *no more* than that, information-theoretically.
Random hashing overshoots by a factor of $1/\varepsilon$. The gap between
$(1-\varepsilon)|S|$ and $|S|/\varepsilon$ is the price of not thinking.

## The obstacle nobody advertises

Here is the thing the textbook presentation glosses over. The rate is beautiful.
The decoder is a catastrophe.

To decode, we scan the typical set. That costs exactly $|S|$ hash comparisons —
and this can be made precise: the scanning decoder performs one comparison per
candidate, exactly $|S|$ of them, no more and no less. But $|S|$ is
*exponential* in the block length $n$; for a source with entropy $h$ per symbol,
$|S| \approx 2^{hn}$. For $n = 1000$ and $h = 1/2$, that is $2^{500}$
comparisons. Shannon's random code is optimal and utterly unusable.

So the real research question is not "can randomness beat the pigeonhole
bound?" — it can, and everyone knows it. The question is: **can randomness beat
the pigeonhole bound with a decoder you could actually run?**

## Blocking: turning a product into a sum

The fix is to stop treating the message as one atom.

Split the string into $b$ blocks $x = (x_1, \dots, x_b)$, each block drawn from
a block alphabet with its own typical set $T$. The global typical set is the
product $T^b$, of size $|T|^b$ — that is what the flat decoder must scan. Now
draw one random codebook $H$ indexed by *(block position, block value)* pairs,
and hash each block with its own slice:

$$\text{encode}(x) \;=\; \bigl(H(1,x_1),\, H(2,x_2),\, \dots,\, H(b,x_b)\bigr).$$

The decoder runs the scanning decoder independently on each block and succeeds
only if every block decodes unambiguously. And now the cost is

$$b \cdot |T| \quad\text{instead of}\quad |T|^{b}.$$

Exponential becomes linear. That the blocked cost really is smaller is an
elementary but genuine inequality: for $|T| \ge 2$ and $b \ge 3$,
$$b\,|T| \;<\; |T|^{\,b},$$
with the gap growing exponentially in the number of blocks. For a modest example
— $|T| = 2^{20}$ and $b = 50$ — the flat decoder needs $2^{1000}$ comparisons
and the blocked decoder needs about $5 \times 10^7$. That is the difference
between "heat death of the universe" and "a fraction of a second".

What does this cost? Exactly one union bound. The blocked scheme fails if *any*
block collides, so

$$\mathbb{P}[\text{failure}] \ \le\ \frac{b\,(|T| - 1)}{M},$$

and choosing $M \ge b(|T|-1)/\varepsilon$ restores the $1-\varepsilon$
guarantee. In rate terms we pay an extra $\log_2 b$ bits — logarithmic in the
number of blocks — to convert an exponential search into a linear one. That is
an extraordinary bargain, and it is the central engineering content of the whole
story.

There is a hint of a deeper structure here. The number of blocks $b$ appears as
a *multiplier* in the failure probability and as a *root* in the search cost
($|T^b|^{1/b} = |T|$ candidates per block). The two exponents are conjugate to
one another, which suggests that rate and decoder complexity trade off along a
genuine Pareto frontier governed by a Legendre-type duality — with the flat
scheme at one endpoint and the fully blocked scheme at the other. Both endpoints
are now theorems; the interpolation is open.

## The loophole: when failure is not failure

Now for the part that should make you uneasy.

A compression scheme has two ways to disappoint you. It can say *"I don't
know"* — annoying, but honest, and you retransmit. Or it can hand you a
confident, wrong answer. In storage and communication this second mode is called
**silent corruption**, and it is the one that destroys archives and quietly
poisons databases.

The scanning decoder is reassuringly safe as long as the transmitted string is
typical: if $x$ is on the candidate list, then any string the decoder outputs
must be $x$ itself. The reason is simple — the decoder outputs something only
when exactly one candidate matches the received codeword, and $x$ is always one
matching candidate, so the unique match must be $x$. This soundness property
survives the blocked construction intact: if every block of the transmitted
string is typical, any output of the blocked decoder equals the transmitted
string exactly, block by block.

But read that hypothesis again. **Typical.** What if the source, on a bad day,
emits an atypical string?

Then $x$ is not on the candidate list, and the decoder can find exactly one
typical string that happens to share $x$'s codeword — and output it, with total
confidence, and be completely wrong. This is not a theoretical worry. In a small
explicit instance (six-letter alphabet, two typical strings, sixteen-symbol
codebook space), the probability of confident-and-wrong output on an atypical
input measures at $3/8$. Not $3/8$ of a percent. Three eighths.

Typicality-based reasoning simply does not deliver a no-silent-corruption
guarantee, and any claim that it does is quietly assuming the source never
misbehaves.

## One checksum closes it — for every decoder at once

The fix is old and simple: send a checksum. Draw a second, independent random
function $C$ into $\{1, \dots, K\}$ and transmit the pair $(H(x), C(x))$. The
decoder runs as before, obtains a candidate $y$, and accepts it only if
$C(y)$ equals the received checksum.

What makes this satisfying is the *generality* of the guarantee. Let the inner
decoder be **anything at all** — the scanning decoder, the blocked decoder, a
neural network, an adversary, any randomised procedure whatsoever that proposes
a candidate. Then for **every** source string $x$, typical or not, with no
assumption on $x$ and none on the inner decoder:

$$\mathbb{P}\bigl[\text{decoder outputs a string} \ne x\bigr] \ \le\ \frac{1}{K}.$$

The proof is a *fibrewise* argument, and it is the conceptual heart of the
result. Condition on the inner decoder's randomness. Once that is fixed, the
candidate $y_0$ it proposes is *determined* — a single string, not a
distribution. A silent corruption requires $y_0 \ne x$ together with
$C(y_0) = C(x)$: a collision of the independent checksum on one fixed pair,
which happens for exactly a $1/K$ fraction of checksums. Averaging over the
inner randomness preserves the bound. The inner decoder's cleverness, or
malice, is irrelevant — it is quantified over before the checksum is drawn.

The price is $\log_2 K$ bits and one extra comparison. Thirty-two bits buys
silent-corruption probability below $2.4 \times 10^{-10}$; sixty-four bits buys
$5 \times 10^{-20}$. Failures are now loud.

## The scheme, assembled

Put the three pieces together and you get a compression scheme with a complete
specification — rate, reliability, complexity, and safety, each an exact
statement rather than an asymptotic gesture:

- **Encoder.** Hash each of the $b$ blocks with its own slice of a random
  codebook of size $M$, and append one global random checksum from $K$ values.
- **Decoder.** Scan each block's typical set, demand a unique match in every
  block, then verify the checksum.
- **Rate.** $b \log_2 M + \log_2 K$ bits, with
  $\log_2 M \approx \log_2 |T| + \log_2(b/\varepsilon)$.
- **Reliability.** For $M \ge b(|T|-1)/\varepsilon$, a random codebook recovers
  any fixed typical string with probability at least $1 - \varepsilon$.
- **Complexity.** Exactly $b\,|T| + 1$ comparisons — not $O(b|T|)$, exactly
  $b|T| + 1$.
- **Safety.** For every source string, typical or atypical, the probability of a
  confident wrong answer is at most $1/K$.

And if you dislike randomness at runtime, you can remove it. Averaging the
failure count over all codebooks shows that **some** fixed codebook of size $M$
is ambiguous on at most $|S|(|S|-1)/M$ of the typical strings — so with
$M \ge |S|/\varepsilon$ there is a deterministic codebook losing at most an
$\varepsilon$ fraction of the typical set, at the same code length. Randomness
is a proof technique here, not an operational requirement. Note, though, what
derandomisation *cannot* give you: a codebook with an *empty* bad set. That
would contradict the converse bound. Averaging only ever yields a codebook whose
bad set is small.

## What the numbers say

Everything above can be checked by brute force on a small instance, and the
numbers behave exactly as the theorems predict. With a six-letter alphabet, a
typical set of three strings, and every codebook enumerated:

| $M$ | measured failure probability | union bound $(|S|-1)/M$ | Bonferroni bound $(|S|-1)/(2M)$ |
|-----|------------------------------|--------------------------|----------------------------------|
| 2   | $3/4 = 0.750$                | $1$                      | $1/2$                            |
| 3   | $5/9 \approx 0.556$          | $2/3 \approx 0.667$      | $1/3 \approx 0.333$              |
| 4   | $7/16 = 0.438$               | $1/2$                    | $1/4$                            |
| 8   | $15/64 \approx 0.234$        | $1/4$                    | $1/8$                            |
| 16  | $31/256 \approx 0.121$       | $1/8$                    | $1/16$                           |

Every measured value equals $1 - (1-1/M)^{2} = (2M-1)/M^2$ on the nose, and sits
neatly between the two bounds, both of which are tight to within a factor of
two. And the silent-corruption experiment: $3/8$ without a checksum, $3/16$ with
a two-valued checksum, $3/32$ with a four-valued one — each division by $K$
exactly as the $1/K$ bound demands.

## The moral

The pigeonhole principle is not wrong, and it was never in danger. What the
almost-lossless story shows is that it is answering a question we rarely need
answered: *can you be exactly right about everything?* Change "everything" to
"almost everything" and the counting bound relaxes by exactly the fraction you
are willing to lose — no more and no less, as the converse bound shows.

But relaxing the requirement is only half the job. Shannon's random code takes
the crack in the pigeonhole and walks through it at optimal rate, then leaves
you with a decoder that runs in exponential time and a silent-corruption
loophole hiding behind the word "typical". Blocking closes the first gap,
converting an exponential search into a linear one for a logarithmic price in
rate. An independent checksum closes the second, universally, for any inner
decoder whatsoever, at a cost of $1/K$.

Three ingredients — a counting identity, a product construction, and a coin
flip — and the result is a scheme where you can state, exactly and without
asymptotics, how many bits it sends, how often it fails, how many operations it
performs, and how often it lies. That last number is the one that matters, and
it is the one the textbook version forgets to compute.
