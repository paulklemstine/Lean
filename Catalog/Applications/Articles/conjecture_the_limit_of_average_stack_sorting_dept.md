# The Number Hiding Inside a Pile of Cards

Imagine you are handed a shuffled deck and asked to put it in order — but
you are only allowed one strange move. You may keep a single spring-loaded
stack on the table. As you read the cards left to right, you can *push* a card
onto the stack or *pop* the top card off onto your output pile. You cannot peek,
reshuffle, or set anything aside. One sweep through the deck, and whatever lands
in the output pile is your new arrangement.

This humble gadget is one of the oldest objects in computer science. Donald
Knuth studied it in the 1960s; Julian West turned it into a *map* in 1990 —
a deterministic function that takes one arrangement and returns another. Apply
it once and the deck gets "more sorted." Apply it again. And again. Eventually,
for any starting deck, you reach the fully sorted order $1, 2, 3, \ldots, n$ and
the machine freezes: sorted decks are left untouched.

The natural question — the one that has quietly resisted a complete answer for
three decades — is: **how many sweeps does it take?**

That count is called the **stack-sorting depth** of a permutation. Some decks
are lucky and sort in a single pass. Others are stubborn and need several. If
you average the depth over *all* $n!$ possible shuffles of $n$ cards, you get a
number $D_n$, the *typical* sorting effort. And as the deck grows, $D_n$ grows
roughly in proportion to $n$. The slope of that growth — the limiting ratio
$\lambda = \lim_{n\to\infty} D_n/n$ — is a single, mysterious real number that
encodes the long-run difficulty of stack sorting.

This article is about that number, about the machine that generates it, and
about a conjecture that says we may already know its exact value.

## The machine, made precise

Let us pin down the one allowed move. The stack has a *top*. When you are about
to read a new card $x$, you first **pop every card on the stack that is strictly
smaller than $x$** onto the output, in the order they come off. Then you push
$x$. When the deck runs out, you flush whatever remains on the stack.

In our formalization this popping rule is a tiny function: given the incoming
value $x$ and the current stack, it peels off the run of smaller entries and
hands back the popped list together with what is left. One full left-to-right
sweep — popping, pushing, and the final flush — is West's stack-sorting map,
which we will simply call $s$.

Here it is on a three-card deck. Take the arrangement $[2,3,1]$:

- Read $2$: stack empty, push it. Stack $[2]$.
- Read $3$: top is $2 < 3$, pop $2$ to output, push $3$. Output $[2]$, stack $[3]$.
- Read $1$: top is $3$, not smaller than $1$, so push $1$. Stack $[1,3]$.
- Flush: output $[2,1,3]$.

So $s([2,3,1]) = [2,1,3]$ — still not sorted! Run it again:

- Read $2$: push. Read $1$: $2$ is not $< 1$, push $1$. Read $3$: pop $1$, pop $2$, push $3$. Flush.
- Result: $[1,2,3]$.

Two sweeps. The deck $[2,3,1]$ has stack-sorting depth exactly $2$ — and it is
the smallest deck that genuinely needs two passes.

## Three things the machine can never do wrong

Before chasing a deep limit, it pays to nail down the machine's basic honesty.
We proved three facts with full rigor.

First, **the machine only rearranges**. The output is always a permutation of
the input: no card is duplicated, none vanishes. In symbols, $s(l)$ is a
permutation of $l$ for every list $l$. This sounds obvious, but the proof has to
track the popping rule step by step and confirm that the popped pile plus the
leftover stack always reassemble into exactly the original cards.

Second, and immediately, **the length is preserved**: $s(l)$ has the same number
of cards as $l$. A reshuffler cannot change how many things it shuffles.

Third, **sorted decks are frozen**. If a list is strictly increasing,
$1 < 2 < \cdots$, then one pass returns it unchanged. This is what makes "depth"
well defined: once you reach the sorted order, you stop, because further passes
do nothing. A sorted deck has depth $0$.

These three guarantees — *permutation*, *length*, *fixed point* — are the
bedrock. Everything about depth is built on top of them.

## Counting the easy decks: a Catalan surprise

Some permutations are so well-behaved that a single pass already sorts them.
These are the *one-pass stack-sortable* decks — depth at most $1$. How many of
them are there among the $n!$ arrangements of $n$ cards?

The answer is one of the most beautiful facts in combinatorics, and it goes back
to Knuth: the count is the **Catalan number**

$$C_n = \frac{1}{n+1}\binom{2n}{n} = 1, 1, 2, 5, 14, 42, 132, \ldots$$

We verified this exactly by *enumerating every permutation* of $[1,\ldots,n]$,
computing each one's depth, and counting those with depth $\le 1$. For four
cards the machine finds $14$ easy decks, and $C_4 = 14$. For five cards it finds
$42 = C_5$. For six cards, $132 = C_6$. The match is not approximate — it is an
identity, checked permutation by permutation.

The Catalan numbers are the same sequence that counts balanced parentheses,
triangulations of a polygon, and binary trees. Finding them inside the
stack-sorting machine is no coincidence: a deck is one-pass sortable exactly
when it avoids the pattern "$231$" — the very pattern $[2,3,1]$ we saw needs two
passes — and pattern-avoiding permutations are the Catalan world's native
inhabitants.

But one-pass decks are only the beginning. The full **depth histogram** spreads
the $n!$ permutations across all their possible depths. For three cards: one
deck of depth $0$, four of depth $1$, one of depth $2$. For six cards the
histogram is richer — $1, 131, 276, 198, 90, 24$ decks of depths
$0, 1, 2, 3, 4, 5$ — and it matches the known integer sequences exactly. From
these histograms we can read off the *average* depth $D_n$, and that is where the
real mystery lives.

## The slope of difficulty

If you compute the average depth and divide by $n$, you watch a number creep
upward, agonizingly slowly:

$$\frac{D_4}{4} \approx 0.365, \quad \frac{D_5}{5} \approx 0.387, \quad \frac{D_6}{6} \approx 0.407.$$

It is climbing — but toward what? In 2020, Colin Defant proved a striking upper
bound: the limit $\lambda = \lim_{n\to\infty} D_n/n$, if it exists, can be no
larger than

$$\lambda \le \frac{3}{5}\bigl(7 - 8\ln 2\bigr).$$

That expression is a genuine, closed-form real number. Plug in the natural
logarithm of $2$ — about $0.6931$ — and you get roughly $0.8729$. The conjecture
at the heart of this work is that Defant's bound is not merely an upper limit but
the *exact* answer: the typical stack-sorting effort grows like $0.8729\,n$,
no more and no less.

We cannot settle that asymptotic conjecture — nobody can yet. What we *can* do,
and did, is pin down the target number with mathematical certainty, so that any
future proof has an unambiguous bullseye to hit.

## Trapping the magic number

The constant $\lambda = \frac{3}{5}(7 - 8\ln 2)$ looks innocent, but $\ln 2$ is
irrational and transcendental; you cannot just "evaluate" it. To work with
$\lambda$ rigorously, we first rewrote it in a cleaner linear form,

$$\lambda = \frac{21}{5} - \frac{24}{5}\ln 2,$$

and then used certified, rigorous decimal bounds on $\ln 2$ to squeeze
$\lambda$ into a narrow, guaranteed window:

$$0.8728 < \lambda < 0.8729.$$

This is not a calculator estimate — it is a proof. From this enclosure several
clean facts fall out, each one verified:

- **$\lambda$ is positive.** The typical sorting effort really does grow; the
  density is not zero.
- **$\lambda < 1$.** The growth is strictly *sub-linear in slope below one* —
  on average you never need close to $n$ passes, even though the worst case can.
- **$\lambda < \tfrac{7}{8}$.** A crisp rational ceiling, $0.875$, sits just
  above the constant.

Each of these required real analysis, not arithmetic shortcuts: the irrational
$\ln 2$ has to be handled through its certified enclosure every time.

## A race between two famous constants

Here is the punchline that makes the number worth caring about. There is another
celebrated constant lurking in the world of random permutations: the
**Golomb–Dickman constant**,

$$G \approx 0.6243299885.$$

It answers a different question — *how long is the longest cycle in a random
permutation?* On average, the longest cycle of a permutation of $n$ elements has
length about $G\,n$. So $G$ measures one notion of "typical structure" in a
random shuffle, while $\lambda$ measures another — typical sorting depth.

Which is bigger? We proved that

$$0.6244 < \lambda,$$

and since it is known in the literature that $G < 0.6244$, the two inequalities
chain together to give

$$G < \lambda.$$

In words: *granting the tightness conjecture*, the average number of sweeps to
stack-sort a random deck grows strictly faster than the average longest cycle.
Two of the most natural statistics you can measure on a random permutation — its
longest cycle and its sorting depth — are not the same density, and the sorting
depth wins. That strict comparison, which sounds like it should require heavy
asymptotic machinery, collapses into a single proved real-number inequality plus
one known bound on $G$.

## Why pinning down a number matters

It might seem modest to "merely" trap a constant between $0.8728$ and $0.8729$
when the real prize — proving the limit equals $\lambda$ — remains open. But
this is exactly how hard conjectures get cracked. A vague claim like "Defant's
bound is tight" is hard to even test. A claim like "$D_n/n \to 0.872892\ldots$"
is *falsifiable*: any candidate asymptotic formula for $D_n/n$ can now be
checked against a known decimal target to as many places as you like. The
finite data — those slowly rising ratios $0.365, 0.387, 0.407, \ldots$ — become
a sanity rail, and the constant becomes the finish line.

The conjecture even comes with a predicted *shape* for the approach. The ratios
rise so sluggishly that a plausible refinement is

$$D_n = \lambda\, n - c\,\ln n + O(1)$$

for some positive constant $c$ — a linear main term, gently dragged down by a
logarithmic correction. That would explain why the empirical ratios sit so far
below their eventual limit even for sizable $n$: the $\ln n$ term decays at a
snail's pace.

## The bigger picture

Stack sorting started as a toy: a single stack, one allowed move, a deck of
cards. But toys like this are how computer science learned what is and is not
sortable, and they continue to spin off deep mathematics — Catalan numbers,
pattern avoidance, and now a transcendental density constant that races against
the Golomb–Dickman constant.

What we have established, with certainty, is the *infrastructure* of the
conjecture: a verified, runnable stack-sorting machine that provably only
rearranges its input and freezes on sorted decks; an exact Catalan law for the
easy permutations, confirmed by direct enumeration; and a rigorously trapped
value for the conjectured limiting density, sharp enough to win a race against
one of the famous constants of probability.

The number hiding inside the pile of cards is about $0.872892$. We do not yet
know for certain that the average sorting depth grows at exactly that rate — but
we now know exactly which number to chase.
