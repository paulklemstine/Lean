# Compression, Coin Flips, and the Price of Admitting Defeat

## Why you cannot win against the pigeons

Here is the oldest theorem in data compression, and it takes one sentence to state and one paragraph to prove.

Suppose you want a compressor that turns each of $N$ possible messages into a string of at most $t$ bits, in such a way that the original message can always be recovered. Then the encoder must be injective — two different messages cannot receive the same codeword, because the decoder would have no way to tell them apart. But there are only

$$1 + 2 + 4 + \cdots + 2^{t} = 2^{t+1} - 1$$

bitstrings of length at most $t$. So $N \le 2^{t+1} - 1$. If you have a million messages, you need about twenty bits, and no amount of cleverness will get you nineteen. This is the **pigeonhole bound**, and it is completely immovable — it is a statement about counting, not about algorithms, so no future breakthrough will soften it.

And yet, in practice, we compress far below it all the time. A photograph of a cloudy sky compresses to a fraction of a percent of its raw size; a text file collapses by a factor of four. How?

The answer is that real compressors are not required to succeed on *all* $N$ messages. They are tuned to the messages that actually occur. Random noise does not compress — but random noise does not arrive. What arrives is structured, and structure means that a small subset of the message space carries almost all of the probability.

This article is about making that intuition into a theorem, and about a question that follows immediately: **if we are allowed a small probability of failure, can randomness — coin flips, random codebooks, Monte Carlo methods — help us?** Claude Shannon's celebrated random-coding argument suggests it can. We will see that the answer is subtler and, in a precise sense, disappointing for randomness: **random codebooks buy exactly zero bits of rate and cost an unbounded factor in decoding time.**

## Failing loudly

The first thing to get right is what "failure" means. There are two very different ways for a decoder to be wrong.

- It can hand you a message and be *wrong about it*. This is **silent corruption**, and it is catastrophic: you get a plausible-looking file that is not your file, with nothing to warn you.
- It can announce that it cannot decode. This is a **detected failure**: annoying, but honest. You retransmit, you fall back, you raise an alarm.

Everything below insists on the second kind. Formally, a **code** on a finite alphabet $\mathcal{A}$ of messages is a pair: an encoder $E : \mathcal{A} \to \{0,1\}^*$ and a *partial* decoder $D : \{0,1\}^* \to \mathcal{A} \cup \{\bot\}$, where $\bot$ means "I failed". The code is **sound** if

$$D(E(x)) = y \quad \Longrightarrow \quad y = x .$$

Soundness is the no-silent-corruption promise: the decoder may refuse to answer, but if it answers, it is right. The **good set** $G$ is the set of messages $x$ with $D(E(x)) = x$, and if messages are drawn from a distribution $p$, the **failure probability** is the mass $p(\mathcal{A} \setminus G)$ of everything outside the good set.

## The pigeonhole bound, relaxed by exactly one quantile

Now suppose we allow a failure probability of at most $\varepsilon$. What happens to the counting bound?

A sound code is injective **on its good set** — the same argument as before, restricted. So the good set obeys $|G| + 1 \le 2^{t+1}$ when codewords are at most $t$ bits, and the good set has mass at least $1 - \varepsilon$. That gives:

> **The $\varepsilon$-relaxed counting bound.** If a sound code has codewords of length at most $t$ and fails with probability at most $\varepsilon$, then the source has a set $S$ of at most $2^{t+1} - 1$ messages carrying probability mass at least $1 - \varepsilon$.

In other words, **the relaxation buys you exactly one thing: permission to ignore an $\varepsilon$-light set. Nothing more.** The relaxed bound is not a new resource; it is a change of the question from "how many messages are there?" to "how many messages do I need to cover $1 - \varepsilon$ of the probability?"

For a *uniform* source on $N$ messages there is no light set worth discarding — every message weighs the same — and the bound becomes clean and quantitative:

$$(1 - \varepsilon) \, N \;\le\; 2^{t+1}, \qquad\text{equivalently}\qquad \log_2\big((1-\varepsilon)N\big) \le t + 1 .$$

So tolerating a failure probability $\varepsilon$ saves you at most $\log_2\frac{1}{1-\varepsilon}$ bits. At $\varepsilon = 1\%$ that is $0.0145$ bits. At $\varepsilon = 50\%$ it is one single bit. **The pigeonhole bound is not so much broken by error tolerance as gently dented.** Setting $\varepsilon = 0$ recovers the classical bound exactly, so the relaxed statement is conservative.

The real gains of compression come from *non-uniform* sources, where the $(1-\varepsilon)$-quantile can be exponentially smaller than the whole alphabet. That is the entire content of practical compression, stated in one line.

## A scheme that meets the bound — and a surprise about error detection

The converse says what is impossible. What is achievable?

Take any set $S$ of messages with mass at least $1 - \varepsilon$ and at most $2^k$ elements. Number its elements $0, 1, \dots, |S|-1$. The **enumerative code** transmits:

- for $x \in S$: the bit $1$, followed by the $k$-bit binary index of $x$ within $S$;
- for $x \notin S$: the single-bit failure marker $0$, padded to the same length.

The decoder reads the flag bit; if it is $0$ it returns $\bot$, and if it is $1$ it reads the $k$-bit index and looks up the corresponding element of $S$. This code is sound, uses exactly $k+1$ bits on *every* message, has good set exactly $S$, and fails with probability exactly $p(\mathcal{A} \setminus S)$. Comparing with the converse, it is within two bits of optimal.

But "within two bits" turns out to be an overstatement of the gap, because there is an exact answer. Call a set $S$ *realisable at length $t$* if some sound code of codeword length at most $t$ has $S$ as its good set. Then:

> **Exact characterisation of achievable rates.** A sound code with codewords of length at most $t$ and failure probability at most $\varepsilon$ exists **if and only if** the source has a set $S$ with $p(S) \ge 1 - \varepsilon$ satisfying either $S = \mathcal{A}$ and $|S| + 1 \le 2^{t+1}$, or $|S| + 2 \le 2^{t+1}$.

Read the two cases carefully; the difference between them is one unit, and that unit is a genuine phenomenon. If the code ever fails, it must have some way of *saying* it failed — and, since the decoder's answer depends only on the received bitstring, saying it failed consumes a codeword. **Error detection costs exactly one codeword, no more and no less.** Not one bit; one codeword. On a $2^{t+1}$-strong budget of short strings that is a vanishing rate penalty, but it is not zero, and the characterisation above shows it is unavoidable.

So the optimal $\varepsilon$-almost-lossless rate is *precisely* the $(1-\varepsilon)$-quantile of the source, plus one reserved codeword for the alarm.

## Enter randomness — and exit randomness

Shannon's random-coding argument is one of the great tricks in mathematics. To show a good code exists, do not construct one; draw one at random and show that the average performance is good, so some particular choice must be at least as good. In our setting the random object is a **codebook**: an assignment $f$ of each message to one of $m$ available codewords, drawn uniformly at random. The code works, on a set of $q$ messages, if $f$ does not collide there.

This is the birthday problem. Counting the non-injective codebooks among all $m^q$ of them gives

$$\Pr[\text{collision}] \;\le\; \frac{q(q-1)}{2m},$$

and the bound is **tight**: for $q = 2$ exactly $m$ of the $m^2$ codebooks collide, so the collision probability is exactly $1/m = \frac{2 \cdot 1}{2m}$. Whenever $q(q-1) < 2m$ the bound is below $1$, and therefore an injective codebook exists — the classical derandomisation step.

So random coding works. The question is what it *bought*. And here is the deflating observation. Suppose a Monte Carlo run succeeds: it produces a codebook $f : \mathcal{A} \to \{0,1,\dots,2^k-1\}$ that happens to be injective on a typical set $S$ of mass $\ge 1-\varepsilon$. Injectivity on $S$ forces $|S| \le 2^k$ — which is exactly the hypothesis the deterministic enumerative code needs. Therefore:

> **Derandomisation of Monte Carlo compression.** Whenever a random codebook of rate $k$ succeeds on a typical set $S$, the deterministic enumerative code on the same $S$ achieves the same rate $k+1$, the same failure probability $\le \varepsilon$, sound and explicitly reported failures — and decodes in $k+2$ steps, whereas the random codebook must be decoded by searching it.

The rate advantage of randomness is not small; it is **zero**. Randomness cannot beat counting, because injectivity *is* counting.

## The real obstacle: it is the decoder, not the rate

Which brings us to the point that the rate-centric view of compression hides. A random codebook is an unstructured table. It has no arithmetic; there is nothing to invert. Given a received word $w$, the only thing you can do is scan the table looking for an entry equal to $w$. How expensive is that?

Exactly as expensive as it looks, and provably so. Instrument the two decoders with step counters — count one step per bit read, one per table probe — and the picture is stark.

- **Enumerative decoding costs exactly $k + 2$ steps** on a typical message: one step for the flag bit, $k$ for the index bits, one for the indexed lookup. It never costs more than $k+3$ on any codeword of the scheme. Linear in the number of transmitted bits.
- **Exhaustive-search decoding of an unstructured codebook of $n$ entries costs exactly $n$ probes in the worst case**, i.e. $2^k$ at rate $k$. Worse, this is *order-independent*: for every way of arranging the codebook there is some message whose decoding scans the whole thing. And it is not a rare worst case — summing the cost over all $n$ messages gives exactly $n(n+1)/2$, an average of $(n+1)/2 \approx 2^{k-1}$ probes.

The separation is therefore total: for every rate $k \ge 4$, enumerative decoding is strictly cheaper, and the ratio is unbounded. Concretely, for any target speed-up factor $M$, the rate $k = 4M + 8$ already satisfies $M \cdot (k+3) < 2^k$. Randomness costs an unbounded factor in decoding time while gaining nothing in rate — this is the honest verdict on "can random number generators help?"

The deeper moral is that **structure, not randomness, is the resource**. The enumerative code is fast for exactly one reason: its codewords are *addresses*, so decoding is an array lookup rather than a search. A random codebook is fast to *design* and slow to *use*.

## Guarding the channel: failures that stay loud

Soundness protects against decoder confusion, but not against a channel that flips a bit in flight. A single flipped bit can turn a valid codeword into a different valid codeword, and then the decoder cheerfully returns the wrong message — silent corruption through the back door.

The classical fix costs one bit. Append to every codeword its **parity**, the exclusive-or of all its bits; the augmented word then always has parity $0$. Flipping any single bit flips the parity, so a corrupted word has parity $1$ and the decoder rejects it outright. This costs exactly one bit of rate, changes neither the good set nor the failure probability, and costs one step per received bit to verify. The complete pipeline — verify the checksum, then decode the index — runs in $2k + 4$ steps at rate $k$, still linear, still exponentially faster than search.

Assembled, the guarantee reads: for any typical set $S$ with $|S| \le 2^k$ and mass $\ge 1 - \varepsilon$, there is a code which is sound, uses $k+2$ bits per message, fails with probability at most $\varepsilon$, returns an explicit $\bot$ on every message it cannot decode, decodes in $2k+4$ steps, and detects every single-bit channel error. That is a scheme, a probability bound, and a decoding-complexity figure, all at once — with no silent corruption anywhere.

## Stacking blocks without paying interest

One last piece. Real messages are long: we compress $n$ symbols, not one. Does the guarantee survive concatenation?

It does, and the reason is a detail that looked cosmetic earlier: the enumerative code is **fixed rate** — *every* codeword, including the failure marker, has exactly $k+1$ bits. So the concatenation of $n$ codewords is *parse-free*. The block decoder does not need to find the boundaries; it slices the received string into $n$ chunks of $k+1$ bits and decodes each. There is no exponential parsing search hiding at the block level.

Three things then compose cleanly. Soundness composes: the block code never corrupts silently. The good set of the block code is exactly the product of the per-block good sets — a block decodes if and only if every one of its symbols does. And the failure probability obeys the union bound: if each block fails with probability at most $\varepsilon$ under an independent identically distributed source, then

$$\Pr[\text{block failure}] = 1 - (1-\varepsilon_0)^n \;\le\; n\varepsilon,$$

with the inequality coming from Bernoulli's inequality $(1-\varepsilon)^n \ge 1 - n\varepsilon$. Finally, the exact cost: decoding $n$ blocks takes $n(k+3) + 1$ steps for $n(k+1)$ transmitted bits — **linear in the length of the message**, with a constant near $1$. Compare: a random codebook for the whole block of $n$ symbols would have $2^{nk}$ entries to search.

## What is still open

Two questions remain, and both are sharp enough to be attacked.

First: **is the union bound the exact loss of block composition?** We know $\Pr[\text{failure}] = 1 - (1-\varepsilon_0)^n$ for the product scheme. Is that optimal among *all* sound fixed-rate schemes of the same total rate — i.e., does joint coding across blocks buy nothing over per-block quantiles? Via the exact rate characterisation, this reduces to a clean rearrangement question: **is the heaviest set of a given size in a product measure always a product of per-coordinate heaviest sets?** For product measures with a common marginal this is a statement about products of sorted vectors, and it is the last missing step.

Second: **is exhaustive search genuinely necessary for unstructured codebooks?** We have proved that the left-to-right scan costs a full pass in the worst case, for every ordering. The conjecture is stronger: any decoder that accesses the codebook only through equality probes "$f(a) \stackrel{?}{=} w$" needs at least $|{\rm codebook}|$ probes in the worst case, even adaptively. The expected proof is an adversary argument — until a probe returns "yes", the adversary keeps every unprobed message consistent with the transcript.

## The moral

The pigeonhole principle is not the enemy of compression; it is its accountant. Allowing an $\varepsilon$ chance of failure does not repeal the accounting — it merely replaces "how many messages exist" by "how many messages matter", plus one codeword reserved for saying *I don't know*. Randomness, which promised so much, turns out to buy no rate at all and to charge an exponential fee at decoding time. What actually pays is structure: an index is an address, and an address can be followed in a single step.

Loud failures, fixed-length codewords, and arithmetic instead of lookup tables — three unglamorous choices, and together they give a compressor whose failure probability, rate, and running time are all known exactly.
