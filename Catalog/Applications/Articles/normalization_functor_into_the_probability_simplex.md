# The Arithmetic of the Infinite Library

Jorge Luis Borges imagined a library containing every book that could ever be
written. Not the books that *have* been written, nor the ones that one day
*will* be — but every possible book: every novel, every refutation of every
novel, the true catalogue of the library, the false catalogues, the biography
you have not yet lived and the one you narrowly avoided. The Library of Babel
holds them all, shelved in identical hexagonal galleries that recede beyond
sight.

Borges was a writer, not an accountant. He left the bookkeeping to us. And it
turns out that once you write down the rules of his library precisely, the
infinite mist resolves into something startlingly exact: you can count the
books, you can compute the chance of stumbling on any particular one, and you
can say — to the digit — how often the phrase you are searching for is expected
to appear. This article is about those exact answers.

## What, precisely, is a book?

To do arithmetic we first need a definition. Strip a book down to its essence
and it is just a sequence of symbols. Fix an **alphabet** of $b$ distinct
symbols — Borges used twenty-five (twenty-two letters, the comma, the period,
and the space) — and fix a **length** $L$, the number of symbols a single
volume holds. Then a *volume* is nothing more than a rule that assigns, to each
position $1, 2, \dots, L$, one of the $b$ available symbols.

Mathematically, a volume is a function from positions to symbols. The
**library** is the collection of *all* such functions, with no exceptions, no
favorites, no gaps. That is the entire model, and everything below follows from
it.

## Result 1: How many books?

The first question Borges' narrator never quite answers is the simplest: how
many books are there?

The reasoning is the reasoning of a combination lock. The first position can be
filled in $b$ ways. For each of those, the second position can independently be
filled in $b$ ways, giving $b \times b$ possibilities for the first two
positions. Continue across all $L$ positions and the count multiplies out to

$$\text{(number of volumes)} = b^{L}.$$

That is the whole library in a single expression. With Borges' alphabet of $b =
25$ symbols and his volumes of $L = 1{,}312{,}000$ characters (410 pages, 40
lines, 80 characters), the count is

$$25^{1{,}312{,}000},$$

a number with roughly $1.8$ million digits. It dwarfs the number of atoms in the
observable universe (a paltry eighty digits) so completely that the comparison
is not even useful. The library is finite, and yet for every practical purpose
it is a model of the unimaginable.

The formal statement of this fact carries the name **`card_library`**: the
library of all volumes of length $L$ over $b$ symbols has exactly $b^L$ members.

## Result 2: The chance of any one book

Now imagine a librarian who reaches blindly into the collection and pulls a
single volume, each book equally likely. This is the *uniform distribution* on
the library — the honest assumption that no book is privileged over any other.
The probability of any particular outcome is, by definition, the number of ways
that outcome can happen divided by the total number of possibilities.

For a single named book — say, the one you are holding — there is exactly one
way to draw it out of $b^L$ equally likely books. So its probability is

$$\Pr[\text{a specific volume}] = \frac{1}{b^{L}} = b^{-L}.$$

This is the theorem **`prob_singleton`**: every individual volume has
probability exactly $b^{-L}$. For Borges' numbers that is $25^{-1{,}312{,}000}$
— a probability so small that if you drew one book per microsecond for the
entire history of the universe, your chance of ever having seen a chosen book
remains, for all intents, zero. The library is democratic and merciless in
equal measure: all books are equally likely, and that equality makes each one
essentially impossible to find.

## The real question: how often does a phrase appear?

Counting books is a warm-up. The deep question — the one that makes the library
feel alive — is about *content*. Somewhere in Babel is a book containing the
sentence you are about to read. How often, across the shelves, does a given
phrase occur? If you open a single random volume, how many times should you
expect to find it?

To ask this precisely we need to talk about **patterns**. A pattern is a short
sequence of symbols of some length $k$ — a word, a phrase, a fragment of code.
We say the pattern **occurs at position $i$** in a volume if the volume's
symbols, read off starting at position $i$, match the pattern symbol for symbol.
Formally this is the predicate **`OccursAt`**, and a volume **`Contains`** the
pattern if it occurs at *some* position. The **`occurrenceCount`** of a pattern
in a volume is simply the number of starting positions at which it occurs.

Here is the elegant part. Fix any valid starting position $i$ — one with enough
room for the whole pattern, i.e. $i + k \le L$. How many of the $b^L$ volumes
display the pattern *exactly there*? The pattern pins down the symbols at $k$
specific positions; the remaining $L - k$ positions are free to be anything.
Each free position contributes a factor of $b$, so the number of matching
volumes is

$$b^{\,L-k}.$$

This counting lemma is **`card_occursAt`**, and it is the engine of everything
that follows. (Its proof rests on two general bookkeeping lemmas,
**`card_filter_agree`** and **`card_agree_inj`**, which count functions forced
to agree with a fixed template on a chosen set of inputs.)

## The main result: expected occurrences

Now we assemble the pieces. A pattern of length $k$ has $L - k + 1$ possible
starting positions inside a volume of length $L$. At each one, the fraction of
volumes that match is $b^{L-k}/b^{L} = b^{-k}$. Probabilities of "match here"
add up across positions — a fact known as *linearity of expectation*, which
holds whether or not the events overlap — so the **expected number of
occurrences** of the pattern in a single uniformly random volume is the number
of positions times the per-position probability:

$$\boxed{\;\mathbb{E}[\text{occurrences}] = (L - k + 1)\cdot b^{-k}.\;}$$

This is the centerpiece, the theorem **`expected_substring_count`**. It is exact
— not an approximation, not an asymptotic estimate, but an equality, valid
whenever the pattern fits ($k \le L$) and the alphabet is nonempty ($b > 0$, so
that the library actually contains books).

Read it slowly, because it explains the entire emotional texture of Borges'
library. The expected count *grows* linearly with the length $L$ of the books —
longer books, more room, more occurrences. But it *shrinks exponentially* with
the length $k$ of the phrase — every extra symbol you demand divides your
expectations by the full alphabet size $b$.

A concrete example. Take a binary library, $b = 2$, with volumes of length
$L = 10$. How often should the two-symbol pattern "$01$" appear in a random
volume? Here $k = 2$, so

$$\mathbb{E} = (10 - 2 + 1)\cdot 2^{-2} = 9 \cdot \tfrac14 = 2.25.$$

A random ten-bit book contains the fragment "$01$" $2.25$ times on average. You
can check this by brute force: list all $2^{10} = 1024$ binary strings of length
ten, count the "$01$"s in each, average them — and you will get exactly
$2.25$. The formula and the exhaustive count agree to the last digit. (The
accompanying demo does precisely this.)

Now demand a longer phrase. In Borges' real library — $b = 25$,
$L = 1{,}312{,}000$ — a specific full sentence of, say, $k = 50$ characters has
expected count

$$(1{,}312{,}000 - 50 + 1)\cdot 25^{-50} \approx 1.3 \times 10^{6} \cdot
10^{-70} \approx 10^{-64}.$$

You would expect to find it once for every $10^{64}$ books you read. The phrase
*is* in the library — Babel contains everything — but the expectation quantifies
exactly how lost it is.

## Result 4: the chance a phrase appears at all

The expected count tells you the average over all positions, but a worried
reader wants a yes-or-no question answered: what is the *probability* that a
random volume contains the phrase *somewhere*?

There is a clean upper bound, and it is the same number we already met. The
event "the pattern appears somewhere" is the union of the events "the pattern
appears at position $i$" over all valid $i$. The probability of a union is never
more than the sum of the individual probabilities — this is the **union bound**,
one of the most reliable tools in all of probability. Each position contributes
$b^{-k}$, and there are $L - k + 1$ of them, so

$$\Pr[\text{volume contains the pattern}] \;\le\; (L - k + 1)\cdot b^{-k}.$$

This is the theorem **`prob_contains_substring_bound`**. It is a *bound* rather
than an equality precisely because a single volume can contain the pattern at
several overlapping positions, and the union bound deliberately ignores that
double-counting. When the right-hand side is tiny — as it is for any phrase of
meaningful length — the bound is essentially tight, and it tells you the chance
of a hit is negligible. When the right-hand side exceeds $1$, the bound becomes
vacuous, which is itself informative: it signals the regime (short patterns,
long books) where the phrase is so common that almost every volume contains it.

## Why the bookkeeping matters

It would be easy to dismiss all this as a curiosity — a way of putting numbers
on a fantasy. But the model of Babel is, quietly, the model of a great deal of
the real world.

Replace "alphabet of $b$ symbols" with "four DNA bases" and a *volume* becomes a
genome; the expected-occurrence formula is exactly how biologists estimate how
often a given motif should appear by chance, and therefore which motifs appear
*more* often than chance and so might mean something. Replace it with "the 256
possible bytes" and a volume becomes a file; the same formula underlies
estimates of how often a fixed signature collides at random, a basic
consideration in data forensics and in the design of hash functions. Replace it
with "two symbols" and you are doing the combinatorics of bit-strings that sits
under coding theory and cryptography. The union bound in particular — the engine
behind Result 4 — is one of the workhorses of theoretical computer science,
used to prove that rare bad events stay rare.

What Borges intuited as vertigo, the mathematics renders as a pair of competing
exponentials: the library's size $b^L$ explodes, but the rarity $b^{-k}$ of any
specified content collapses just as fast. Meaning is not absent from Babel; it
is present in overwhelming abundance. It is simply diluted to homeopathic
concentration by the sheer volume of nonsense surrounding it. The expected count
$(L-k+1)\,b^{-k}$ is the precise exchange rate between the two.

## Coda

Borges ends his story with a melancholy hope: that the library, though
boundless to any single traveler, is *periodic* — that an immortal walker would
eventually find the same disordered shelves repeating, and that this repetition,
"repeated, would be an order: the Order." Our arithmetic offers a humbler
consolation. The library is not boundless. It is exactly $b^L$ books. Each is
exactly $b^{-L}$ likely. Each phrase you love appears, on average, exactly
$(L-k+1)\,b^{-k}$ times. The infinite, looked at squarely, turns out to be
finite, countable, and — to anyone willing to do the multiplication — entirely
understood.
