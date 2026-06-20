# The Library of Babel, Counted Exactly

Imagine a library so vast that it contains every book that could ever be
written. Not every book that *has* been written, or *will* be written, but
every book that *could* exist: every novel, every poem, every shopping list,
every government report, every love letter, in every language, alongside an
unimaginable ocean of pure gibberish. Jorge Luis Borges dreamed up this place
in his 1941 story *The Library of Babel*, and ever since, it has haunted
mathematicians, programmers, and philosophers alike.

Borges' library is built from a strict recipe. Every book has exactly the same
length — about 410 pages, which works out to roughly $1{,}312{,}000$
characters. Every book is written using the same small alphabet of $25$
symbols. And crucially, the library contains *every possible arrangement* of
those symbols. Put differently: take $1{,}312{,}000$ slots, fill each one with
one of $25$ letters, in every conceivable way, and bind the results. That is
the Library of Babel.

The library is not infinite. That is the first surprise, and the first piece of
real mathematics. Because each book is finite and the alphabet is finite, there
are only *finitely many* books. But the number is so colossal that it dwarfs
every physical quantity in the universe. This article is about pinning that
number down exactly, and then asking the natural follow-up questions: if I open
a book at random, what is the chance it is the one I want? What is the chance it
contains a particular sentence — say, your own name, or the first line of
*Hamlet*? These questions have clean, exact answers, and we will state every one
of them.

## Counting the unimaginable

Let us replace Borges' specific numbers with two dials we can turn. Let $b$ be
the number of symbols in the alphabet (Borges uses $b = 25$), and let $L$ be the
length of every book (Borges uses $L = 1{,}312{,}000$). A single book is just a
choice of one symbol for each of the $L$ positions. Mathematically, a book — we
will call it a **volume** — is a function that assigns to each position
$1, 2, \dots, L$ one of the $b$ symbols.

How many volumes are there? At the first position you have $b$ choices. For each
of those, the second position again offers $b$ choices, giving $b \times b$
combinations for the first two positions. Continue across all $L$ positions and
the choices multiply:

$$
\text{number of volumes} = \underbrace{b \times b \times \cdots \times b}_{L
\text{ times}} = b^{L}.
$$

This is the first exact result, and it is the bedrock of everything that
follows. The library of all length-$L$ volumes over a $b$-symbol alphabet
contains *exactly* $b^{L}$ books — not approximately, not "on the order of," but
exactly.

For Borges' constants this is $25^{1{,}312{,}000}$. To feel how large that is,
take logarithms: $\log_{10}\left(25^{1{,}312{,}000}\right) = 1{,}312{,}000 \cdot
\log_{10} 25 \approx 1{,}834{,}000$. The number of books in the Library of Babel
is a $1$ followed by roughly $1.8$ *million* zeros. The observable universe
contains perhaps $10^{80}$ atoms — a number with a mere $80$ zeros. There is no
physical analogy that does this number justice; it is simply, cleanly, $b^L$.

## The needle in the cosmic haystack

Now suppose you walk into the library blindfolded and pull a single volume off a
shelf, every volume equally likely. What is the probability that you have
grabbed one *particular* book you had in mind — the complete and correct text of
this very article, say?

Here we need to be precise about "equally likely." We equip the library with the
**uniform probability**: the chance of an event is the number of volumes that
make it true, divided by the total number of volumes. For a single target book,
exactly one volume makes the event true, and there are $b^L$ volumes in all.
So the probability of drawing your chosen book is

$$
\Pr(\text{exactly this book}) = \frac{1}{b^{L}} = b^{-L}.
$$

Again this is exact. For Borges, the chance of randomly grabbing one specific
predetermined book is $25^{-1{,}312{,}000}$ — a number so small that if every
atom in the universe pulled a billion books per second for the entire age of the
cosmos, the probability of ever hitting your target would still be
indistinguishable from zero. The book is *there*, guaranteed, somewhere on the
shelves. Finding it by chance is hopeless. This is the central tension of the
Library: everything exists, but meaning is drowned in noise.

## A more hopeful question: fragments, not whole books

Demanding the *entire* correct book is asking too much. A reader does not need a
volume to be perfect cover to cover; they might be thrilled just to find a
meaningful *passage* — a single quotable sentence sitting somewhere inside an
otherwise random book. This is a fundamentally more optimistic question, and the
mathematics rewards the optimism.

Fix a **pattern**: a short string of length $k$ that we are hunting for, such as
the $11$-character string `to be or no`. We say the pattern *occurs at position
$i$* in a volume if, reading $k$ consecutive symbols starting at slot $i$, we see
exactly the pattern. A volume **contains** the pattern if it occurs at *some*
position. And we can count: the **occurrence count** of a pattern in a volume is
the number of starting positions at which the pattern appears.

Two beautiful facts now emerge. The first concerns a single fixed window. If you
stare at one particular block of $k$ consecutive positions inside a volume, how
many of the $b^L$ volumes show your exact pattern in that window? The $k$
positions in the window are forced — they must spell the pattern — but the other
$L - k$ positions are completely free, each independently one of $b$ symbols. So
the count of matching volumes is

$$
\#\{\text{volumes with the pattern in a fixed window}\} = b^{\,L - k}.
$$

This single combinatorial identity — "freeze $k$ slots, free the rest" — is the
engine of the whole theory.

The second fact is the payoff. How many times, *on average*, does a length-$k$
pattern appear inside a uniformly random length-$L$ volume? A pattern of length
$k$ can start at any of the positions $1, 2, \dots, L - k + 1$ — there are
$L - k + 1$ possible windows. Each window independently shows the pattern with
probability $b^{-k}$ (freeze $k$ slots out of the window, the rest is automatic
once you divide by $b^L$). Adding up the chances across all windows — which is
legitimate even though the windows overlap, because *expected values always
add* — gives the **expected number of occurrences**:

$$
\mathbb{E}[\text{occurrences}] = (L - k + 1)\cdot b^{-k}.
$$

This is exact, and it is the heart of the matter. Let us plug in Borges'
numbers. Take the famous opening of Hamlet's soliloquy, the $11$-character
fragment `to be or no`. With $b = 25$, $L = 1{,}312{,}000$, and $k = 11$:

$$
\mathbb{E}[\text{occurrences of } \texttt{to be or no}]
= (1{,}312{,}000 - 11 + 1)\cdot 25^{-11}
\approx \frac{1{,}311{,}990}{2.38 \times 10^{15}}
\approx 5.5 \times 10^{-10}.
$$

So in a *single* random book you expect about half a billionth of one
occurrence of that phrase. But here is the magic of the formula working the
other way: how long would a book have to be for that fragment to be expected to
appear once? Set the expectation equal to $1$ and solve for $L$: you need
$L \approx 25^{11} \approx 2.4 \times 10^{15}$ characters. A book of a few
quadrillion characters would, on average, contain the phrase `to be or no` once.
The expectation grows linearly with length and shrinks geometrically with the
length of the pattern you demand — a precise quantitative statement of the
trade-off between *how much* you read and *how specific* a thing you seek.

## How likely is "at least once"?

The expected count tells you the average, but you might want a probability: what
is the chance a random book contains the pattern *somewhere*, even once? Here the
overlapping windows make an exact formula messy, but a clean and rigorous
*upper bound* falls right out of the expectation. If the average number of
occurrences is small, then the probability of "at least one" occurrence cannot
be larger than that average. This is the classical **union bound**, and it gives

$$
\Pr(\text{volume contains the pattern}) \le (L - k + 1)\cdot b^{-k}.
$$

The reasoning is simple and airtight: the event "contains the pattern" is the
union of the events "pattern occurs at window $1$," "pattern occurs at window
$2$," and so on. The probability of a union is never more than the sum of the
individual probabilities, and that sum is exactly the expected count we computed
above. So whenever the expected count is, say, $10^{-9}$, the probability of
even a single appearance is at most $10^{-9}$ too. For long, rare patterns the
bound is essentially tight, because two simultaneous occurrences are
astronomically unlikely.

This is the rigorous version of an intuition every programmer who has played
with "library of Babel" websites eventually forms: short strings are easy to
find, long strings are effectively impossible, and the cutoff is governed
precisely by comparing the pattern length $k$ against the logarithm (base $b$) of
the book length $L$. When $k$ is much smaller than $\log_b L$, the pattern is
almost surely present; when $k$ is much larger, it is almost surely absent. The
formula $(L-k+1)\,b^{-k}$ tells you exactly where you sit on that knife edge.

## Why exactness matters

It would have been easy to wave our hands and say the library is "about"
$25^{1{,}312{,}000}$ books, or that finding a phrase is "very unlikely." The
discipline here is to refuse the hand-waving. Every statement above is an
*equation* or a *proven inequality*, with all edge cases accounted for: the
empty alphabet ($b = 0$, an empty library), the trivial single-symbol alphabet
($b = 1$, exactly one book of all-identical symbols), the empty pattern, and
patterns as long as the whole book. The combinatorial backbone — freeze $k$
positions and let the remaining $L - k$ run free, giving $b^{L-k}$ — is what
makes the singleton probability, the expected occurrence count, and the
containment bound all snap into place from a single idea.

There is a poetic consequence hiding in the arithmetic. Borges imagined
librarians wandering the hexagonal galleries forever, searching for the one book
that explains all the others — a perfect catalog. The counting tells us why the
search is doomed by chance and yet not doomed in principle. By chance, the
probability of stumbling on any specific meaningful book is $b^{-L}$, a
vanishing whisper. But the books are *all there*, indexed implicitly by the very
strings they contain. The library does not need a separate catalog; each volume
*is* its own address, a number between $1$ and $b^L$ written in base $b$. The
tragedy of Borges' librarians is not that meaning is absent — it is that meaning
is everywhere, uniformly diluted, and the only honest guide through it is the
mathematics of $b^L$.

## The takeaway

Three exact statements summarize the entire universe of Babel. There are
$b^{L}$ possible books. Any one specific book has probability $b^{-L}$ of being
drawn at random. And a fixed pattern of length $k$ appears, on average,
$(L - k + 1)\,b^{-k}$ times in a random book — with the probability of appearing
at all bounded by the same quantity. From these three formulas you can compute,
for any alphabet and any book length, exactly how vast the library is, exactly
how hopeless it is to find a chosen volume, and exactly how the odds of finding a
meaningful fragment trade off against its length. Borges gave us the dream; the
arithmetic gives us the map.
