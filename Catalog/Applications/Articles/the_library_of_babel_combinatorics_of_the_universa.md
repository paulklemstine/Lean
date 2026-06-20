# The Library of Babel: Doing the Combinatorics of Everything

Imagine a library that contains every book that could ever be written.

Not "every book ever published," and not "every book in some enormous national archive." Every book — every possible arrangement of letters that fits between two covers. Somewhere on its shelves is the true history of your life, written before you were born. Somewhere is the same history, but with a single comma misplaced. Somewhere is a flawless proof of every theorem mathematicians will discover in the next thousand years, and right beside it a thousand convincing-looking proofs that are subtly, fatally wrong.

This is the **Library of Babel**, dreamed up by Jorge Luis Borges in his 1941 short story. Borges imagined an endless honeycomb of hexagonal rooms, each lined with identical shelves, each shelf holding books of exactly 410 pages. The books are filled with what looks like gibberish: random strings drawn from a small alphabet. And yet, because *every* possible string appears, the Library contains all meaning that can ever be expressed — drowned in an ocean of nonsense.

Borges wrote it as a parable about infinity, knowledge, and despair. But underneath the literature lies a precise mathematical object, and that object can be measured. How big is the Library, exactly? If you pulled a book at random, what is the chance it contains a particular sentence — say, a real proof of a real theorem? Is there a "master catalog" volume that tells you where everything is?

These are not vague philosophical musings. They are combinatorics questions with exact answers. This article is about pinning those answers down.

## How big is "everything"?

Let us be precise about what a book is. Fix an **alphabet** of $b$ symbols and a **length** $L$ — the number of character slots in the book. In Borges's Library, the alphabet has $25$ symbols (twenty-two letters plus the comma, period, and space), and each book has $410$ pages of $40$ lines of $80$ characters, for a total of

$$L = 410 \times 40 \times 80 = 1\,312\,000$$

character slots per book.

A single book, then, is just a choice of one symbol for each of its $L$ slots. Mathematically, a book — we'll call it a **volume** — is a function from positions to symbols: position $0$ gets some symbol, position $1$ gets some symbol, and so on, up to position $L-1$. The **Library** is the collection of *all* such functions.

How many are there? Each of the $L$ slots can be filled in $b$ independent ways, so the count is $b$ multiplied by itself $L$ times:

$$\#(\text{Library}) = b^{L}.$$

This is the first exact fact, and it is worth stating as a theorem in its own right, because everything else rests on it:

> **The size of the Library.** The library of all volumes of length $L$ over a $b$-symbol alphabet contains exactly $b^L$ volumes.

For Borges's numbers this is

$$25^{1\,312\,000},$$

a number with about $1.8$ million digits. To feel how absurd that is: the observable universe holds something like $10^{80}$ atoms. The Library's book count has more digits than there are atoms in millions of universes. It is finite — you could, in principle, number every book — but it is finite in the way that the distance to a receding galaxy is finite: technically reachable, practically unreachable forever.

And yet it is *only* finite. That single word is the hinge on which all of the mathematics turns. Because the Library is finite, we can put a uniform probability on it: every book is equally likely, and the chance of any particular book is one divided by the total. This gives us our second exact fact:

> **The chance of a single book.** Under the uniform distribution, every individual volume has probability exactly $b^{-L}$.

Pick a book blindfolded, and the odds you grabbed *that exact book* are $1$ in $25^{1\,312\,000}$. You will never grab the same book twice, not if you draw one per second until the stars burn out.

## The real question: will it contain what I'm looking for?

Knowing the chance of an *exact* book is almost useless. Nobody wants one specific arrangement of 1.3 million characters down to the last comma. What we actually want is a book that *contains* something meaningful — a phrase, a sentence, a proof. We don't care what surrounds it.

So here is the sharper question. Fix a **pattern** — a target string of length $k$. It might be the sentence "the cat sat on the mat," or it might be a complete, line-by-line proof of a theorem written out as $k$ symbols. Now draw a volume at random. What is the probability that the pattern appears *somewhere* inside it?

To answer this we first count occurrences. Slide a window of width $k$ across the book. The book has $L$ slots, so the window can start at position $0$, then $1$, and so on, up to position $L-k$ — that's $L-k+1$ possible starting positions. At each position, the pattern either matches or it doesn't.

Here is the key combinatorial lemma, the engine of the whole theory:

> **Books matching a pattern at a fixed spot.** The number of volumes that display a given length-$k$ pattern at one *fixed* starting position is exactly $b^{L-k}$.

The reason is beautifully simple. If we *demand* that $k$ specific slots spell out our pattern, those $k$ slots are now frozen — there is exactly one way to fill them. The remaining $L-k$ slots are completely free, each with $b$ choices. So the number of books pinned to the pattern at that spot is $b^{L-k}$. Out of $b^L$ books total, the fraction matching at that one spot is $b^{L-k}/b^L = b^{-k}$ — precisely the chance that $k$ random characters happen to spell the pattern, exactly as intuition demands.

Now sum over all $L-k+1$ starting positions. The **expected number of occurrences** of the pattern in a random book is the sum of the per-position chances:

> **Expected occurrences.** For a fixed pattern of length $k$ (with $k \le L$), the average number of times it appears in a uniformly random volume is exactly
> $$(L-k+1)\,\cdot\,b^{-k}.$$

This single formula is the heart of the matter, and it is genuinely two-sided in spirit. The factor $b^{-k}$ is brutally small — it shrinks geometrically in the pattern length. But the factor $L-k+1$ is enormous, because $L$ is over a million. The Library wins meaning back not by making any one position likely, but by offering more than a million positions to try.

From the expectation we get the thing we actually wanted — the probability that the pattern appears *at all*:

> **The chance of finding meaning (union bound).** The probability that a random volume contains a fixed length-$k$ pattern is at most
> $$(L-k+1)\,\cdot\,b^{-k}.$$

This is the formula Borges's story cries out for, made exact. It says: the probability of stumbling on a particular text of length $|T| = k$ is bounded by its length-budget $L-k+1$ times the per-symbol penalty $b^{-k}$ — essentially $|T| \cdot b^{-k}$, exactly the relationship the conjecture predicted. The inequality (rather than equality) is honest: a pattern can appear in *several* places in the same book, so "expected number of copies" slightly overcounts "at least one copy." The bound is the clean, provable statement.

## What the formula tells us about proofs

Let's put numbers to it, because the numbers are the punchline.

Suppose your "meaningful pattern" is a short, genuine proof — say $k = 200$ characters of a clean mathematical argument — and use Borges's alphabet $b = 25$ and book length $L = 1\,312\,000$. The probability a random book contains it is about

$$1.3 \times 10^{6} \times 25^{-200}.$$

Now $25^{-200}$ is $10^{-279}$ or so. Multiply by a million and you get roughly $10^{-273}$. The million-position bonus shaves three digits off a number with hundreds of zeros. The proof is *there* in the Library — many copies of it are — but the chance any single random draw lands on one is so close to zero that the distinction is purely academic.

This is the exact, quantitative form of Borges's despair. The Library contains every proof, but the expected number of random draws you'd need before seeing one is the reciprocal of that probability: about $10^{273}$ draws. Meaning exists, but blind search will never find it. You need a *guide* — a catalog.

## Can the Library catalog itself?

Borges's narrator dreams of a single "total book," a master index that lists where every other book sits. Could such a volume exist?

A counting argument settles it instantly, and it is the same argument that powers Cantor's diagonal and the pigeonhole principle. To pin down the location of every one of the $b^L$ books, the catalog must carry at least $\log_2(b^L) = L \log_2 b$ bits of information — one address per book. But a single book holds only $L$ symbols, i.e. $L \log_2 b$ bits *total*. To name *every* book it would need to name itself, and to name billions of books distinct from itself it would need vastly more room than it has. Since $b^L$ is astronomically larger than the few million bits one book can hold, **no single volume can be the catalog of the whole Library.** The dream of the total book is mathematically impossible.

But there is a back door, and it rescues the project. Spread the catalog across *many* books. If you are allowed $N$ volumes to hold your distributed index, and each volume carries $L \log_2 b$ bits, then the index can address the entire Library as soon as

$$N \cdot L \log_2 b \;\ge\; \log_2\!\big(b^{L}\big) \cdot (\text{address overhead}),$$

which works out to roughly $N > b^{L} / (L \log_2 b)$ volumes. The Library cannot index itself in one book, but it *can* index itself in a (still gigantic) shelf of books. Information that won't fit in one container fits across enough of them — the mathematics of distributed storage, foreshadowed in a 1941 short story.

## A catalog you can actually build: de Bruijn's trick

For the full Library these numbers are hopeless, so let's shrink to a toy we can hold in our hands: a **mini-Library** with an alphabet of $b = 4$ symbols and books of length $L = 16$.

Here is a delightful fact. We can build a *single* book of length $16$ that contains **every possible two-character pattern** — all $4^2 = 16$ of them — exactly once, if we let the book wrap around like a bracelet. Such a string is called a **de Bruijn sequence**, named after the Dutch mathematician Nicolaas de Bruijn.

How? Build a graph whose vertices are the single symbols $\{0,1,2,3\}$ and whose edges are the two-symbol patterns: an edge from symbol $x$ to symbol $y$ stands for the pattern "$xy$." Every vertex has four edges out and four edges in, so the graph is perfectly balanced — and a classical theorem of Euler guarantees that a balanced, connected graph has a closed trail using *every edge exactly once*. Walk that Eulerian circuit, read off the symbols, and you have a length-$16$ cyclic book in which all sixteen two-letter patterns appear once each. It is a perfect, compact catalog of "everything of length two."

This is the constructive flip side of the impossibility result. You cannot fit *all books* into one book — but you *can* fit all *short patterns* into one short book, with no waste, and you can do it efficiently. The de Bruijn construction is the seed of every real "covering" catalog: minimal guides that touch every possibility once.

## The moral of the Library

Strip away the hexagons and the despair, and Borges's fable is a remarkably modern piece of mathematics. It is about the geometry of *all possible texts* — a space so large it dwarfs the physical universe, yet finite enough to measure exactly.

Three facts capture it. First, the space is enormous but countable: $b^L$ books, each vanishingly unlikely. Second, meaning is present but diffuse: any target text of length $k$ appears with probability about $(L-k+1)\,b^{-k}$, a number that is provably positive and provably tiny, which is exactly why the Library is simultaneously complete and useless without a guide. Third, the guide cannot be a single book — diagonal counting forbids it — but it can be a distributed index, and for short patterns it can even be a perfect, efficiently constructible de Bruijn catalog.

The same trio reappears everywhere we store information at scale: the address space is huge, any particular record is rare, no single index can hold everything, but clever distributed and covering structures make the haystack searchable. Borges imagined a library to dramatize the futility of brute force against infinity. The mathematics turns that drama into a recipe: count the space, measure the meaning, and build the guide.

Every possible text already exists. The whole art is in finding it — and now we can say precisely how hard that is.
