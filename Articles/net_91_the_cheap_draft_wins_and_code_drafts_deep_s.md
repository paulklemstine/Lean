# The Cheap Draft Wins: What a Desktop CPU Taught Us About Guessing Ahead

## A gambler's trick for language models

Large language models write one word at a time. Each word costs a full pass through
the network — billions of arithmetic operations to produce a handful of characters.
On a graphics card this is wasteful but tolerable. On an ordinary desktop processor
it is agonising: a seven-billion-parameter model, compressed to four bits per weight,
produces about $5.8$ words per second on a mid-range eight-core chip. A paragraph
takes half a minute.

There is a beautiful trick for going faster, and it is essentially a gamble.
Instead of asking the big model for the next word, ask a *small* model — one perhaps
a fifteenth of the size — to guess the next $d$ words in a row. Then hand the whole
guessed string to the big model **at once** and ask a single question: "reading left
to right, which of these would you have written yourself?" The big model checks all
$d$ guesses in one pass. Every guess that matches is kept for free. At the first
mismatch, the big model's own correction is used, and the rest of the guesses are
thrown away.

The output is *bit-for-bit identical* to what the big model would have produced alone.
Nothing is approximated. The only thing that changes is the time.

The gamble is obvious: you pay for the small model's guesses whether or not they are
used. Guess too little and you leave speed on the table. Guess too much and you burn
time generating text that gets discarded. Somewhere there is a right amount of
guessing — and the central question of this article is: *what determines it?*

## What actually happened on the desktop

We ran the experiment: a seven-billion-parameter instruction-tuned model, four-bit
quantised, running entirely on the processor of a desktop machine — no graphics card
involved at any point. Two candidate guessers from the same model family: a
half-billion-parameter one and a one-and-a-half-billion-parameter one. Two kinds of
task: ordinary English prose, and source code. Three guessing depths: $d = 2$, $4$,
and $8$. Twelve configurations, eight runs each.

Here is the whole result in one table. "Speedup" is measured against the big model
decoding alone; "accept" is the fraction of guessed words that survived verification.

| guesser | depth | prose speedup | prose accept | code speedup | code accept |
|---|---|---|---|---|---|
| 0.5B | $2$ | $1.254\times$ | $63.9\%$ | $1.352\times$ | $71.6\%$ |
| 0.5B | $4$ | $1.416\times$ | $47.7\%$ | $1.616\times$ | $63.0\%$ |
| 0.5B | $8$ | $0.979\times$ **(loss)** | $30.9\%$ | $\mathbf{1.661\times}$ | $56.0\%$ |
| 1.5B | $2$ | $1.016\times$ | $63.2\%$ | $1.195\times$ | $83.4\%$ |
| 1.5B | $4$ | $1.153\times$ | $51.9\%$ | $1.395\times$ | $74.8\%$ |
| 1.5B | $8$ | $0.982\times$ **(loss)** | $44.9\%$ | $1.354\times$ | $60.3\%$ |

Three things jump out, and each one turns out to be a theorem rather than an accident.

## Surprise one: the small guesser wins even when it guesses worse

Look at the bottom-right corner. On code at depth $8$, the larger guesser is *better
at guessing* — $60.3\%$ of its proposals survive versus $56.0\%$ for the small one.
And yet the small guesser is dramatically faster: $1.661\times$ against $1.354\times$.
The same reversal holds in all six head-to-head comparisons. There is no crossover
anywhere in the grid.

Why? Because on a processor, the two halves of the trick scale differently.
Measure time in units of one big-model word. Let $c$ be the cost of one guesser word
in those units — $c \approx 0.118$ for the small guesser, $c \approx 0.234$ for the
large one. A block of depth $d$ costs
$$\text{cost}(c,d) = 1 + c\,d,$$
one verification pass plus $d$ guessing steps, because the guesses must be made
*sequentially* — each one depends on the last. The verification, by contrast, is a
single pass no matter how long the string.

If each guessed position survives independently with probability $a$, the block
delivers on average
$$\text{yield}(a,d) = 1 + a + a^2 + \cdots + a^d$$
words: the free correction token, plus the accepted prefix. Throughput is the ratio,
$$\text{speedup}(a,c,d) = \frac{1 + a + \cdots + a^d}{1 + c\,d},$$
and at $d = 0$ this is exactly $1$, as it must be.

The first law falls out immediately. **At equal acceptance and any positive depth,
the cheaper guesser is strictly faster.** That much is obvious. The content of the
experiment is that the advantage *survives an acceptance deficit* — and the model
says exactly how large a deficit it survives. Push the depth to infinity: the yield
saturates at $1/(1-a)$ while the cost grows like $cd$, so
$$d \cdot \text{speedup}(a,c,d) \longrightarrow \frac{1}{c\,(1-a)}.$$
At large depth a guesser is characterised by a *single number*: cost times rejection
rate, $c(1-a)$. Smaller is better. For the measured code-at-depth-8 pair,
$$0.118 \times 0.44 = 0.052 \quad\text{versus}\quad 0.234 \times 0.397 = 0.093,$$
a rout. To overturn it the large guesser would need an acceptance rate of at least
$77.8\%$. It measured $60.3\%$.

This is the **Draft-Cost Dominance Law**: an acceptance advantage must beat a cost
disadvantage *multiplicatively in the rejection rate*, not additively in the
acceptance rate. Doubling your per-word cost buys you nothing unless you roughly
halve your rejections. Graphics-card folklore — "use the biggest draft model you can
afford, acceptance is king" — comes from a regime where the verification pass is
essentially free and the draft's sequential cost hides in the noise. On a CPU nothing
hides. The arithmetic is the wall.

## Surprise two: guess deeper, and eventually you lose

Prose at depth $8$ is *slower than not guessing at all*: $0.979\times$. This is not a
pathology; it is unavoidable. Because the yield can never exceed $1/(1-a)$ while the
cost $1 + cd$ grows without bound, there is always a depth past which speculation is
a net loss. The exact gate is clean: speculation at depth $d$ is slower than plain
decoding as soon as
$$(1-a)\,(1 + c\,d) > 1.$$
Rejection rate times block cost exceeding one — that is the whole condition.

So there is an optimal depth, and it is interior. The next question is whether it is
*findable*. Could throughput have two humps, so that a search which gives up at the
first decline misses a later revival — meaning the measured prose collapse past
depth $4$ is hiding a resurrection at depth $16$?

It cannot. **Throughput in depth is unimodal.** The argument is a single line once
the comparison is cross-multiplied: going from depth $d$ to $d+1$ pays exactly when
$$\bigl(\text{yield}(d{+}1) - \text{yield}(d)\bigr) \cdot (1 + cd) \;>\; c \cdot \text{yield}(d).$$
The left-hand side involves the *increment* of the yield, which shrinks as $d$ grows
(each extra guess is less likely to be reached). The right-hand side grows, because
the yield accumulates. Once the shrinking side falls below the growing side, it can
never climb back. One decline is terminal.

Consequently, hill-climbing from depth zero and stopping at the first non-improving
step returns the *global* optimum. That justifies a clean definition: the **stopping
depth** of a configuration is the first depth at which one more guess fails to pay.
It always exists, it is always globally optimal, and — the sharpest statement of the
whole story — **it is monotone in acceptance**: a domain whose guesses survive more
often should always guess at least as deep. Nothing about the ordering of two domains'
optimal depths is ever accidental.

Instantiated at the measured small-guesser cost $c = 0.118$: prose (acceptance
$47.7\%$) has stopping depth $2$; code (acceptance $63.0\%$) has stopping depth $3$.
At one and the same decision — whether to guess a third word — the two domains
disagree. **No static depth is optimal for both.** That is the second law:
*optimal depth is domain-parameterised.*

## Surprise three: the acceptance numbers were lying to us — politely

Here is a puzzle the simple model cannot survive. On code, the small guesser was
*faster* at depth $8$ than at depth $4$ ($1.661$ versus $1.616$) with a reported
acceptance of $56\%$. But run the model: at the small guesser's cost, **no**
per-position acceptance probability $a \le 0.8$ makes depth $8$ beat depth $4$.
(You need about $a = 0.85$.) So $56\%$ cannot be a per-position acceptance
probability. The independence assumption is refuted by the data.

The repair is to stop assuming independence and model the *survival profile* directly.
Let $S(k)$ be the probability that the first $k$ guessed positions are **all**
accepted. Then $S(0) = 1$, $S$ is non-increasing, and a block of depth $d$ delivers
$$\text{yield}_S(d) = S(0) + S(1) + \cdots + S(d).$$
The independent model is the special case $S(k) = a^k$; the general case is anything
non-increasing.

Now comes the deflating observation, and it is the most useful result in the whole
study. What the measurement harness reports as "acceptance" is the fraction of guessed
words committed — that is, the *average* $\bigl(\text{yield}_S(d) - 1\bigr)/d$ of the
survival curve over the first $d$ positions. And **the average of any non-increasing
curve is itself non-increasing.**

So the headline pattern — prose acceptance falling $63.9 \to 47.7 \to 30.9$ as depth
doubles, code falling $71.6 \to 63.0 \to 56.0$ — carries *no information whatsoever*
about whether the guesser degrades with depth. It is forced by arithmetic. Any fixed
survival profile, measured at increasing depths, produces a decaying acceptance
number. We call this the **Averaging Law**, and it is a warning label for every
speculative-decoding benchmark ever published.

The law is not vacuous, though: it has a falsifiable edge. Monotone survival also
forces the acceptance of the *positions between* two measured depths to be no larger
than the earlier block's. Acceptance percentages that *rise* with depth are
unrealisable by any survival profile at all — a reported $50\%$ at depth $2$ followed
by $70\%$ at depth $4$ would be self-contradictory. The measured numbers pass this
test comfortably; the block means are $0.716, 0.544, 0.490$ for code and
$0.639, 0.315, 0.141$ for prose, both decreasing.

And the three measured percentages per domain can be reproduced *exactly* by explicit
non-increasing profiles:

| position $k$ | $0$ | $1$ | $2$ | $3$ | $4$ | $5\text{–}8$ |
|---|---|---|---|---|---|---|
| code $S(k)$ | $1.000$ | $0.800$ | $0.632$ | $0.560$ | $0.528$ | $0.490$ |
| prose $S(k)$ | $1.000$ | $0.700$ | $0.578$ | $0.350$ | $0.280$ | $0.141$ |

Look at what the reconstruction reveals. The code curve descends gently:
$0.632 \to 0.560$ from position two to three. The prose curve **falls off a cliff**:
$0.578 \to 0.350$. That cliff, invisible in every reported average, is the mechanism
of the domain split. Prose is predictable for a word or two — a preposition, an
article, the rest of a set phrase — and then the writer has a genuine choice, and the
small model cannot read the large model's mind. Code, by contrast, is syntactically
constrained for long stretches: closing brackets, boilerplate, indentation, the tail
of an identifier already begun.

An important honesty note: only three cumulative sums per domain are pinned by the
data, so the reconstruction is *not unique*. What is proved is realisability — such
profiles exist and are exhibited — never identification. Recovering the true curve
requires instrumenting acceptance position by position, which is precisely the next
experiment.

## The rule you can ship

The whole story compresses into one local test. Guessing one more word pays exactly
when
$$S(d+1) \;>\; c \cdot \text{speedup}(d),$$
the survival probability of the next position exceeds the marginal cost times the
throughput you already have. Because throughput is unimodal, this rule can be applied
greedily and still finds the global optimum — no grid search, no backtracking, one
comparison per depth.

Feed the reconstructed profiles and the measured marginal cost $k = 0.287$ per
position into that rule and out comes the deployed prescription, now derived rather
than fitted: prose stops paying at depth $4$; code still gains from $4$ to $8$.

There is one more twist in the cost. Fitting a block-cost curve to the three
code cells gives
$$\text{cost}(d) = 1.5401 + (0.0992 + \text{extra})\,d + 0.0151\,d^2,$$
with $\text{extra} = 0$ for the small guesser and $0.116$ for the large one. Two
features matter. First, the constant term exceeds $1$: a block costs more than a
single verification pass even before any guessing — there is real fixed overhead per
round trip. Second, the curve is strictly **convex**, and no straight-line cost
whatsoever reproduces the three code speedups. On a processor, verification does not
amortise; it *anti-amortises*. Each additional position in the verified batch costs
more than the last, because a wider batch spills out of cache and the arithmetic
units were already saturated. On a graphics card there are thousands of idle lanes to
absorb a wider batch. On eight CPU cores there are none.

Calibrated on three cells, this single curve predicts all twelve measured speedups —
nine of them entirely out of sample — within $11\%$ relative error, using nothing but
that cell's measured acceptance. Cost is a property of the hardware; yield is a
property of the domain. They separate.

## Why it matters

The practical bottom line is unglamorous and valuable: a $0.6$-gigabyte side model,
costing almost nothing to store and nothing to train, buys up to $66\%$ more
throughput from a seven-billion-parameter model on a machine with no accelerator at
all, with the output guaranteed identical. The prescription is: use the *smallest*
competent guesser, not the best one; guess deep ($d = 8$) for code; guess shallow
($d = 4$) for prose; and never use a fixed depth, because doing so forfeits a quarter
of your throughput on one side or the other.

The conceptual bottom line is larger. Two pieces of received wisdom about speculative
decoding turn out to be artefacts of the hardware they were discovered on. "Bigger
draft models are better" is false when sequential proposal costs real time. "Deeper is
better as long as acceptance holds up" is false when verification does not amortise.
And "acceptance falls with depth, so the drafter degrades" is not even wrong — it is a
statement about averaging that any fixed drafter would produce.

What replaces the folklore is a small, sharp theory: throughput is yield over cost;
yield is a domain-specific survival curve; cost is a convex hardware curve; the optimum
is the first depth where next-position survival drops below marginal cost times current
throughput; and that optimum rises monotonically with acceptance. Everything measured
on the desktop is a corollary. The next thing to measure is the shape of the prose
cliff — and where, exactly, in a sentence it falls.
