# The Library of Babel, Counted Exactly

*Borges imagined a library containing every possible book. Here is what the
mathematics says about searching it.*

## A universe made of pages

In 1941 Jorge Luis Borges published a short story about a library so large it
might as well be the universe. Its hexagonal galleries stretch in every
direction, filled with identical-looking volumes. Each volume has the same
length, written in the same small alphabet, and — crucially — the library
contains *every possible book* of that length. Every novel ever written and
every novel that never will be. The true history of your life, and ten thousand
false ones. A perfect proof of every theorem, and a flawed one on the very next
shelf. Somewhere there is a book that is nothing but the letter "a" repeated from
cover to cover.

The story is usually read as a parable about meaning, infinity, and despair. But
underneath the parable is something a mathematician can pin down completely. The
Library of Babel is not infinite. It is *finite* — staggeringly, incomprehensibly
finite — and because it is finite, we can count it. We can compute the exact
probability of stumbling on the book you want. We can ask how a single book could
serve as a catalog to all the others, and prove precisely why no such catalog can
exist. And we can prove the strangest fact of all: that a long enough random book
is *almost certain* to contain any text you name.

This article is about those calculations. Every claim below is a theorem that has
been checked down to the last symbol.

## The model: a book is a function

To do the mathematics, we strip a book down to its essentials. Fix an **alphabet**
of `b` symbols and a **length** `L`. A *volume* is then just a choice of one symbol
for each of the `L` positions — formally, a function from the positions
`{0, 1, …, L-1}` to the symbols `{0, 1, …, b-1}`. The **Library** is the collection
of *all* such functions.

Borges' own library used 25 orthographic symbols (22 letters plus the comma,
period, and space) and books of exactly 410 pages, 40 lines, 80 characters — that
is, `L = 1,312,000` symbols. To keep examples concrete, we will also use a
"mini-Library" with `b = 4` symbols and books of length `L = 16`, small enough to
fit on a laptop yet large enough to show the same phenomena.

## How big is the library?

The first theorem is the one Borges himself essentially states. Because each of
the `L` positions can independently be any of the `b` symbols, the number of
distinct volumes is `b` multiplied by itself `L` times:

> **The library has exactly `b^L` volumes.**

For the mini-Library that is `4^16 = 4,294,967,296` — about four billion books,
already too many to print. For Borges' library it is `25^1312000`, a number with
roughly 1.8 million digits. To grasp the scale: the observable universe holds
something like `10^80` atoms, a number with 81 digits. The Library of Babel
dwarfs the physical universe not by a factor, but by more than a *million orders
of magnitude*. And yet — it is finite. You could, in principle, number every book.

## One book in a vastness

If you reach blind into the shelves and pull out a single volume, what is the
chance you grabbed a *particular* book you had in mind — say, this article,
encoded into the alphabet?

> **Every individual volume has probability exactly `b^(-L)`.**

That is one divided by `b^L`: one chance in the total number of books, as fairness
demands. For the mini-Library, the odds of guessing a specific 16-symbol book are
1 in 4.29 billion. For Borges' library the probability is `25^(-1312000)`, a
decimal that begins with more than 1.8 million zeros before the first nonzero
digit. This is the precise mathematical form of the librarians' despair in the
story: the book you want certainly exists, and you will certainly never find it by
chance.

## Two readers, one book

A cousin of that fact concerns coincidence. Suppose two readers, in galleries
light-years apart, each pull a random volume. What is the chance they are holding
*the same* book?

> **Two independent uniform volumes coincide with probability exactly `b^(-L)`.**

It is the same minuscule number as before — and for a clean reason. The first
reader's book can be anything; the second reader must then match it exactly,
position by position, which happens with probability `b^(-L)`. Two strangers in
the Library of Babel are as unlikely to share a book as you are to name the one
book in your hand in advance.

## Expected sightings of a phrase

Single books are hopeless, but *phrases* are another matter. Fix a target
**pattern** of length `k` — a word, a sentence, a snippet of code. A random
volume of length `L` has `L - k + 1` possible starting positions where that
pattern could begin. At each position, the `k` symbols match the pattern with
probability `b^(-k)` (each of the `k` symbols must line up, independently). Adding
up the chances at every position gives the central counting result of this work:

> **The expected number of occurrences of a fixed length-`k` pattern in a random
> volume is exactly `(L - k + 1) · b^(-k)`.**

This is an *exact* equality, not an approximation, and it holds for every alphabet
size, every book length, and every pattern (provided the pattern fits inside the
book and the alphabet is nonempty). It is the engine behind everything that
follows. Notice its shape: it grows linearly in the book length `L` and shrinks
exponentially in the pattern length `k`. A short phrase in a long book is expected
to appear many times; a long phrase in a short book, essentially never.

Plug in numbers. In the mini-Library (`b = 4`, `L = 16`), a specific 3-symbol
pattern is expected to appear `(16 - 3 + 1)·4^(-3) = 14/64 ≈ 0.219` times — most
books don't contain it, but roughly one in five does. Now consider Borges'
library and the pattern "the". With `b = 25`, `k = 3`, `L = 1,312,000`, the
expected number of occurrences is about `1,311,998 / 25^3 ≈ 84` — every Babel
book contains the string "the" dozens of times, purely by chance.

## The pessimist's bound

The expected count tells you the *average* number of sightings, but a librarian
wants the probability of *at least one*. Here the average gives a clean upper
limit. If something happens 0.219 times on average, it certainly cannot happen
with probability more than 0.219. This is the **union bound**:

> **The probability that a random volume contains a fixed length-`k` pattern is at
> most `(L - k + 1) · b^(-k)`.**

This bound is honest but pessimistic. When the book is long the right-hand side
can exceed 1 and become useless — it tells you "the probability is at most 84,"
which is true but vacuous. To find meaning in the library we need a bound that
pushes from *below*, guaranteeing the pattern *is* there.

## Disjoint blocks: a guarantee from below

The trick is to stop letting occurrences overlap. Carve the book into
`m = ⌊L/k⌋` consecutive, non-overlapping blocks, each exactly `k` symbols long
(with a short leftover at the end). Because the blocks share no positions, their
contents are *statistically independent* — like independent dice rolls. Each block
fails to equal the pattern with probability `1 - b^(-k)`. For *all* `m` blocks to
miss, all these independent failures must occur, giving probability
`(1 - b^(-k))^m`.

Making this rigorous required counting, exactly, how many books avoid the pattern
on every aligned block. The answer is beautiful in its cleanliness:

> **The number of volumes in which no aligned block matches the pattern is exactly
> `(b^k - 1)^(⌊L/k⌋) · b^(L - ⌊L/k⌋·k)`.**

Each of the `⌊L/k⌋` blocks may be any of the `b^k - 1` non-matching strings, and
the `L - ⌊L/k⌋·k` leftover symbols are unconstrained. The proof builds an explicit
dictionary — a bijection — that re-reads any book as a list of its blocks plus its
remainder, sending block number `t` at offset `j` to the original position
`t·k + j`. Once you can translate cleanly between "a book" and "a list of blocks,"
the count is just multiplication.

Dividing by the total `b^L` and subtracting from one turns this exact count into
the lower bound we wanted:

> **The probability that a random volume contains a fixed length-`k` pattern is at
> least `1 - (1 - b^(-k))^(⌊L/k⌋)`.**

Unlike the pessimist's bound, this one is always a genuine probability between 0
and 1, and it is never vacuous.

## Borges completeness: the library keeps its promise

Now let the book length `L` grow without limit, keeping the alphabet (at least two
symbols) and the pattern fixed. The number of disjoint blocks `⌊L/k⌋` grows too,
and `(1 - b^(-k))^(⌊L/k⌋)` — a number slightly below 1 raised to an ever larger
power — collapses toward zero. The lower bound therefore climbs toward 1:

> **For any alphabet of at least two symbols, the probability that a random volume
> contains a fixed pattern tends to 1 as the book length tends to infinity.**

This is the rigorous heart of Borges' fantasy. Any text you can name — a sonnet,
a contract, a complete and correct proof of a theorem — is *almost certain* to
appear inside a sufficiently long random book. Not because the library was
designed to contain it, but because length alone forces it. Give a monkey enough
pages and the collected works of Shakespeare become not merely possible but
overwhelmingly likely.

The two bounds together — the union bound from above and the disjoint-block bound
from below — sandwich the truth:

```
1 - (1 - b^(-k))^(⌊L/k⌋)   ≤   P(book contains the pattern)   ≤   (L - k + 1)·b^(-k).
```

The left side guarantees that meaning eventually appears; the right side reminds
us how rare any *specific* meaning is at any fixed scale.

## Could one book catalog them all?

Borges' librarians dream of a single "total book," a catalog indexing every
volume's location. Can it exist? A counting argument settles it instantly. To name
one of `b^L` books you need about `log₂(b^L) = L·log₂ b` bits of information. A
single book holds only `L` symbols, i.e. `L·log₂ b` bits — *exactly enough to name
one other book, not all of them.* Since `b^L` is astronomically larger than the
`L·log₂ b` bits a single volume can carry, no one book can encode the addresses of
all the rest. The catalog is logically impossible.

But split the work across many books and it becomes possible. A *distributed*
catalog spanning `N` volumes carries `N·L·log₂ b` bits, and once
`N > b^L / (L·log₂ b)` that is enough to index the entire library. The dream is
not impossible — only un-completable by any single volume, which is, fittingly,
the exact shape of Borges' melancholy.

## Why count the uncountable-feeling?

The Library of Babel is more than a literary curiosity. It is the purest possible
model of an **information space**: the set of all messages of a given size. Every
hard drive, every genome of fixed length, every fixed-size cryptographic key, every
neural-network weight file lives inside its own Library of Babel. The theorems here
are statements about those spaces too. The expected-count formula is the
mathematics of how often a motif appears in random DNA. The union bound is the
back-of-the-envelope calculation a cryptographer uses to argue a key is hard to
guess. The disjoint-block argument is a workhorse of probabilistic combinatorics,
used to prove that random structures almost surely contain whatever substructure
you ask for.

Borges gave us a haunting image: infinite meaning, infinitely diluted. The
mathematics gives us the exact dilution. Every possible text exists. Finding the
one you want, at any fixed scale, is essentially impossible — and yet, paradoxically,
make the books long enough and *everything* becomes inevitable. The library always
keeps its promise. It simply never tells you which shelf.
