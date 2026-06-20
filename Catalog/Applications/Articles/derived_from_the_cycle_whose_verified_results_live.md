# The Library of Babel, Measured Exactly

In 1941 Jorge Luis Borges imagined a library so vast it contained every book
that could ever be written. Its shelves hold every possible arrangement of a
fixed set of orthographic symbols across a fixed number of pages. Somewhere in
its hexagonal galleries lies the true history of your life, the false history of
your life, the correct catalogue of the library, ten thousand false catalogues,
a proof of every theorem, and a refutation of every proof. Borges' narrator
wanders this universe of paper in equal parts ecstasy and despair, because the
library contains everything — and therefore, in a sense, nothing you can find.

Borges wrote a parable. But the parable hides a precise piece of mathematics,
and that mathematics turns out to be completely tractable. If we fix the
alphabet and the book length, the Library of Babel is a *finite* object. We can
count it. We can put a probability measure on it. We can ask: if I pull a book
off the shelf at random, how likely is it to contain the word "Babel"? How
likely to contain the complete works of Shakespeare? And — most beautifully —
what happens to those probabilities as the books grow longer and longer?

This article tells that story, and every claim in it is a theorem with a
machine-checked proof behind it. We will state each result precisely as we go,
so that nothing depends on trusting a hand-wave.

## Building the library out of functions

The first move a mathematician makes is to strip away the hexagons and the dust
and keep only the essential structure. A *volume* is a string of characters of
some fixed length $L$, drawn from an alphabet of $b$ symbols. We can label the
symbols $0, 1, \dots, b-1$ and label the positions $0, 1, \dots, L-1$. Then a
volume is simply a rule that assigns a symbol to each position — in other words,
a function

$$ v : \{0, 1, \dots, L-1\} \to \{0, 1, \dots, b-1\}. $$

The **library** $\mathrm{Library}(b, L)$ is the collection of *all* such
functions: every conceivable book of length $L$ over the alphabet of size $b$.

How big is it? At each of the $L$ positions we may independently choose any of
the $b$ symbols, so the count multiplies:

> **Theorem (size of the library).** The library of all length-$L$ volumes over
> a $b$-symbol alphabet contains exactly $b^L$ volumes.

This is the cleanest possible statement of Borges' vastness. Borges' own library
used roughly $25$ symbols and books of $1{,}312{,}000$ characters, giving
$25^{1{,}312{,}000}$ volumes — a number with more than $1.8$ million digits,
unfathomably larger than the number of atoms in the observable universe (a mere
$80$-digit number). The library is finite, and yet "finite" here is a word that
has lost all human meaning.

## Every book is a needle, and the haystack is uniform

To talk about randomly pulling a book off a shelf, we put the **uniform
probability measure** on the library: every volume is equally likely. Formally,
for any event $A$ (any set of volumes), its probability is the fraction of the
library that lies in $A$:

$$ \Pr(A) = \frac{\#\{ v \in \mathrm{Library}(b,L) : v \in A\}}{\#\,\mathrm{Library}(b,L)}. $$

Because there are $b^L$ volumes in total and each is equally likely, the chance
of drawing one *specific* book is as small as it could be:

> **Theorem (single-volume probability).** Every individual volume has
> probability exactly $b^{-L}$.

Here $b^{-L}$ is $1/b^{L}$. Borges' narrator searches for one book — the
"Vindication," the text that justifies his existence — among $25^{1{,}312{,}000}$
candidates. The probability of finding it by chance is $25^{-1{,}312{,}000}$.
This is the mathematical form of his despair.

There is a charming companion fact. Suppose two librarians, working in different
galleries, each pull a book at random. What is the chance they pulled *the same*
book? The two draws are independent, so we are choosing a pair of volumes
uniformly at random, and asking for the probability they coincide:

> **Theorem (coincidence probability).** Two independent uniformly random
> volumes are identical with probability exactly $b^{-L}$.

The same vanishing number $b^{-L}$ governs both "find a fixed book" and "two
random books match." Coincidences in the Library of Babel essentially never
happen.

## Counting how often a word appears

Despair about *specific books* is the wrong emotion, though. The interesting
question is not "does this exact volume exist" (it does, trivially — everything
exists) but "does a given *passage* appear *somewhere* inside a book?" A reader
does not need the whole infinite text of *Hamlet*; they need the phrase "to be
or not to be" to surface inside whatever volume they happen to hold.

So fix a **pattern**: a short target string of length $k$, say the letters of a
word. We say the pattern *occurs at position $i$* in a volume $v$ if the $k$
consecutive symbols of $v$ starting at position $i$ match the pattern exactly.
The volume *contains* the pattern if it occurs at some position. And we can count
the **occurrence count**: the number of starting positions $i$ (ranging over the
$L - k + 1$ legal windows) at which the pattern appears.

How many occurrences should we expect in a random book? Here the answer is
strikingly clean. There are $L - k + 1$ windows where the pattern could begin. At
each window, the $k$ required symbols must each match, and since the symbols are
chosen uniformly and independently, the chance of a match at any fixed window is
$b^{-k}$. By the linearity of expectation — the principle that the expected total
is the sum of the expected parts, regardless of whether the parts are
independent — we add up $b^{-k}$ across all $L - k + 1$ windows:

> **Theorem (expected number of occurrences).** For a fixed pattern of length
> $k \le L$ over an alphabet of $b \ge 1$ symbols, the expected number of
> occurrences of the pattern in a uniformly random volume of length $L$ is
> $$ (L - k + 1)\, b^{-k}. $$

This single formula is the engine of the whole subject. Let us read off its
consequences.

If the book is short relative to the pattern, $(L-k+1)b^{-k}$ is tiny: short
books rarely contain long words by accident. But the factor $L - k + 1$ grows
without bound as books get longer, while $b^{-k}$ stays fixed. So for a *fixed*
target word, longer and longer books are expected to contain it more and more
often. The phrase "to be or not to be" ($k = 18$ characters) has an expected
count of about $L \cdot 25^{-18}$ in a Borges volume; since $25^{18} \approx
1.4 \times 10^{25}$, you would need books of around $10^{25}$ characters before
expecting even a single appearance. The library's enormity finally works *for*
the reader, not against them — if only the books are long enough.

## The naive bound, and why it is not enough

From the expected count we get a first estimate of how likely a book is to
contain the pattern *at all*. If something is expected to happen $(L-k+1)b^{-k}$
times on average, then it can't happen *at least once* with probability greater
than that average. (If it did, the average number of occurrences would exceed
$(L-k+1)b^{-k}$.) This is the classic **union bound**, and it gives:

> **Theorem (union upper bound).** The probability that a random volume of
> length $L$ contains a fixed pattern of length $k \le L$ is at most
> $$ (L - k + 1)\, b^{-k}. $$

This is a genuine theorem, and useful when the right-hand side is small. But it
has a fatal flaw as a tool for understanding Borges' library: when $L$ is large,
$(L-k+1)b^{-k}$ exceeds $1$, and the bound says only that a probability is "at
most something bigger than $1$" — which is no information at all. Precisely in
the regime Borges cares about (enormous books) the union bound goes *vacuous*.
We need a lower bound, a guarantee that the pattern *will* appear.

## The disjoint-block trick: a guarantee, not just a hope

Here is the clever idea that saves the day. Instead of looking at all $L-k+1$
*overlapping* windows — which are statistically entangled and hard to control —
we chop the book into **disjoint, non-overlapping blocks** of length $k$. A book
of length $L$ holds $\lfloor L/k \rfloor$ such blocks laid end to end, with a
short leftover remainder. Because the blocks share no positions, their contents
are genuinely *independent*: knowing one block tells you nothing about the next.

Each individual block fails to equal the pattern with probability $1 - b^{-k}$.
Independence means the probability that *all* $\lfloor L/k \rfloor$ blocks fail
is the product:

$$ \left(1 - b^{-k}\right)^{\lfloor L/k \rfloor}. $$

We can even count the relevant volumes exactly. The number of volumes in which
none of the $\lfloor L/k\rfloor$ aligned blocks equals the pattern is

$$ \left(b^{k}-1\right)^{\lfloor L/k\rfloor}\, b^{\,L - \lfloor L/k\rfloor \cdot k}, $$

because each block has $b^k - 1$ "wrong" contents and the remaining
$L - \lfloor L/k\rfloor\cdot k$ free positions are unconstrained. Dividing by the
total $b^L$ gives the avoidance probability. Now, if all the aligned blocks fail,
the book certainly does not contain the pattern; conversely, if the book contains
the pattern at all, at least one block could carry it. Containing the pattern is
*at least* as likely as having one aligned block match, so the chance of
containing it is at least $1$ minus the chance every block fails:

> **Theorem (disjoint-block lower bound).** The probability that a random volume
> of length $L$ contains a fixed pattern of length $k \ge 1$ is at least
> $$ 1 - \left(1 - b^{-k}\right)^{\lfloor L/k \rfloor}. $$
> Equivalently, the probability the book *avoids* the pattern entirely is at most
> $\left(1 - b^{-k}\right)^{\lfloor L/k \rfloor}$.

Unlike the union bound, this estimate is *never* vacuous: the right-hand side is
always a genuine probability between $0$ and $1$, for every $L$. And it has teeth.

## Borges, vindicated: everything almost surely appears

Now watch what happens as the books grow. Fix the alphabet with at least two
symbols ($b \ge 2$) and fix any target text of length $k$. The avoidance bound
$(1 - b^{-k})^{\lfloor L/k\rfloor}$ has a base $1 - b^{-k}$ strictly between $0$
and $1$, raised to an exponent $\lfloor L/k\rfloor$ that marches to infinity as
$L$ grows. A number less than $1$, raised to ever-higher powers, collapses to
zero. So the avoidance probability vanishes, and the containment probability
climbs to certainty:

> **Theorem (Borges completeness).** For an alphabet of at least two symbols and
> any fixed finite pattern, the probability that a uniformly random volume
> contains the pattern tends to $1$ as the book length tends to infinity.

This is the rigorous heart of Borges' fantasy. *Any text you like* — your
biography, the proof of the Riemann hypothesis, the words you are reading now —
almost surely appears inside a sufficiently long random book. Not because the
library was designed to contain it, but because containment becomes
*overwhelmingly probable* once there is enough room. The library does not merely
*contain* everything; a random sample of it *practically guarantees* everything,
in the limit.

Notice the role of the hypothesis $b \ge 2$. With a one-symbol alphabet
($b = 1$) there is only a single possible book of each length — the string of
all the same character — and it contains essentially nothing but itself. Variety
is what makes the library complete. Two symbols already suffice; the binary
Library of Babel is just as universal as Borges' twenty-five-symbol one.

## What the trick teaches

Step back and the moral is about *method*. The expected-count formula
$(L-k+1)b^{-k}$ is exact and elegant but yields only the one-directional union
bound, which dies for large books. The disjoint-block decomposition trades the
elegance of overlapping windows for the power of genuine independence, and that
trade buys a two-sided understanding: an explicit lower bound that holds for
every length and sharpens, in the limit, into a clean dichotomy — short books
rarely contain a given text, long books almost surely do, with the crossover
governed by the threshold $b^{k}$.

This pattern — replace an entangled, exact quantity with a cruder but
*independent* decomposition you can actually control — recurs throughout
probability, combinatorics, and the theory of algorithms. The "first moment"
(expectation) tells you what to expect on average; the "second moment" or a
clever independence argument tells you whether the average is actually realized.
Here the disjoint blocks are the independence argument, and they turn a poet's
intuition into a theorem.

## Coda

Borges ends his story with a quiet conjecture: that the library is unbounded and
periodic, that if an eternal traveler crossed it in any direction they would
find, after centuries, the same volumes repeated in the same disorder — "which,
repeated, becomes order: the Order." The mathematics agrees in spirit. The
library of fixed length is finite, exquisitely countable at $b^L$, with each book
a vanishingly rare $b^{-L}$. Yet stretch the books and the rare becomes the
certain: every finite story, every needle, almost surely surfaces in the
ever-growing hay. The despair of the finite searcher and the serenity of the
infinite one are two readings of the same equation — and now we can prove they
are both correct.
