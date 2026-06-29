# The Shape of a Perfect Search

There is a moment, familiar to anyone who has ever flipped through a physical
dictionary, that contains the entire theory of efficient computation in
miniature. You want the word *quokka*. You don't start at *aardvark* and read
forward. You split the book roughly in half, glance at the page, decide whether
*quokka* lies to the left or the right, and throw away the half that can't
contain it. Then you do it again. And again. A thousand-page dictionary
surrenders its secret in about ten glances, not a thousand.

That instinct has a name — **binary search** — and it is arguably the most
important small algorithm ever discovered. It is also, famously, one of the
hardest small algorithms to get *exactly* right. Donald Knuth observed that
although the idea was published in 1946, the first *correct* version that
handled all the boundary cases didn't appear until 1962. Sixteen years of
off-by-one errors. Jon Bentley, who taught binary search to professional
programmers for years, reported that roughly ninety percent of them failed to
code it correctly when given a couple of hours to try.

This article is about what it means to pin binary search down so completely that
there is *nothing left to get wrong* — to state precisely what it computes, to
prove that it always computes that, and to prove exactly how fast it does so.
And then it's about a small surprise: the same logarithmic search that finds a
word in a dictionary turns out to navigate a far stranger space — the
**factorial number system**, a counting system where each digit lives in a
column of a different width, and where every whole number below a factorial gets
a unique address.

## The trouble with "the middle"

Most people first meet binary search as "search a sorted array." That framing is
true but misleading, because it bundles together two completely different ideas
and makes them look like one. The first idea is *the search itself*. The second
is *the assumption that the data is sorted*. Untangling them is the key to
understanding why binary search is correct.

Here is the cleaner way to think about it. Forget arrays. Imagine a switch that
is **off** at some starting point and **on** at some ending point, and you want
to find exactly where it flips. Formally, picture a function $p$ that takes a
position $i$ and returns either *false* (off) or *true* (on). You know two
anchor facts:

$$p(\text{lo}) = \text{false}, \qquad p(\text{hi}) = \text{true}.$$

Somewhere strictly between $\text{lo}$ and $\text{hi}$, the switch must flip from
off to on. Binary search finds that flip point. It looks at the midpoint
$\text{mid} = \lfloor(\text{lo}+\text{hi})/2\rfloor$, asks the single question
"is the switch on here?", and then keeps the half of the interval that still
straddles the flip:

- If $p(\text{mid})$ is **true**, the flip is at or before the midpoint, so we
  recurse on $[\text{lo}, \text{mid}]$.
- If $p(\text{mid})$ is **false**, the flip is after the midpoint, so we recurse
  on $[\text{mid}, \text{hi}]$.

We stop when the interval has shrunk to a single step — when $\text{hi}$ is just
one past $\text{lo}$ — and we return $\text{hi}$.

The beautiful thing about this "threshold" picture is what it does *not* require.
It says nothing about the data being sorted. The only thing the algorithm leans
on is the **loop invariant**: at every recursive call, the left anchor reads
false and the right anchor reads true. That property is preserved *by
construction* — whichever half we keep, we always keep an off-end and an on-end.
This is the secret of writing binary search correctly. You don't reason about
arrays and comparisons; you reason about a single invariant that can never be
violated.

When this is made fully rigorous, the correctness statement reads like a
contract. If $\text{lo} < \text{hi}$ with $p(\text{lo})$ false and $p(\text{hi})$
true, then the index $r$ that binary search returns satisfies, all at once:

$$\text{lo} < r \le \text{hi}, \qquad p(r) = \text{true}, \qquad p(r-1) = \text{false}.$$

In words: the answer lies inside the interval, the switch is on at the answer,
and the switch is off one step earlier. That is *exactly* the boundary — the
first position where the predicate becomes true. There is no ambiguity, no
off-by-one wiggle room, no special case lurking at the ends. The contract holds
for **every** predicate satisfying the two anchor conditions, with no assumption
of monotonicity whatsoever.

Where does the sorted array come back in? Only at the very end, and only if you
want it. If you are searching a sorted list for the first entry that is at least
some target $t$, you simply take $p(i)$ to mean "the $i$-th entry is $\ge t$."
Because the list is sorted, this predicate really is a clean off-then-on switch,
and the boundary the search finds is precisely the first index whose entry
reaches the target. Monotonicity — sortedness — is what turns the abstract flip
point into the concrete "first index $\ge t$." It is a topping, not the cake.

## Counting the glances

Knowing binary search is correct is half the story. The other half is the
promise that made it famous: it is *fast*. But how fast, exactly?

Every step of the algorithm throws away half of the remaining interval. Start
with a gap of width $g = \text{hi} - \text{lo}$; after one step the gap is at
most about $g/2$; after two, about $g/4$; and so on until the gap is one. The
number of halvings is the **logarithm** of $g$ — which is why a thousand-page
dictionary needs only about ten glances ($2^{10} = 1024$).

But "about a logarithm" is the kind of phrase that hides off-by-one demons, and
this is where a genuinely interesting subtlety appears. There are two natural
candidates for "the logarithm of $g$": the **floor logarithm**
$\lfloor \log_2 g \rfloor$ and the **ceiling logarithm**
$\lceil \log_2 g \rceil$. They differ exactly when $g$ is not a power of two, and
choosing the wrong one quietly breaks any attempt at an exact bound.

Consider the smallest interesting case: a gap of three, say searching over
positions $0$ to $3$. Trace the algorithm and you find it can take **two** steps
in the worst case. Now look at the floor logarithm: $\lfloor \log_2 3 \rfloor =
1$. One. The floor logarithm undercounts. You might patch this by writing "floor
logarithm plus one," but that patch fails elsewhere, because the "plus one"
slack gets consumed in a different branch of the recursion and the bookkeeping
no longer lines up.

The honest answer is the **ceiling logarithm**, and the reason is elegant. The
ceiling logarithm obeys its own recurrence that mirrors the algorithm's
recurrence *exactly*:

$$\lceil \log_2 g \rceil = \lceil \log_2 \lceil g/2 \rceil \rceil + 1.$$

That $\lceil g/2 \rceil$ — a *ceiling* in the halving — is precisely the worst
case the algorithm itself can be forced into, when an adversary keeps steering
the search into the slightly larger of the two halves. Because the two
recurrences match step for step, the bound comes out clean and, crucially,
**tight**: the worst-case number of comparisons binary search performs over an
interval of width $g$ is

$$\lceil \log_2 g \rceil,$$

no more, and — for adversarial inputs — no less. The gap-of-three example hits
this exactly: two steps, and $\lceil \log_2 3 \rceil = 2$. This is the rare
satisfaction of a complexity bound that is not merely an upper estimate with
some looseness baked in, but the genuine, attained worst case.

A small practical note hides inside all this. The algorithm refers to the
"position one before the answer," $r - 1$, and on whole numbers subtraction can
misbehave at zero. It doesn't here, and the reason is the invariant again: the
left anchor is always strictly below the answer, so $r$ is always at least one,
and $r - 1$ is always a sensible position. The correctness and the safety come
from the same source.

## A number system with elastic columns

Now for the strange country that this same search can explore.

We write numbers in base ten out of habit, not necessity. In base ten, the
columns have fixed widths: ones, tens, hundreds, each ten times the last. But
nothing forces the columns to grow at a constant rate. The **factorial number
system** — the *factoradic* — lets each column grow faster than the last. Reading
from the right, the place values are
$$0! = 1, \quad 1! = 1, \quad 2! = 2, \quad 3! = 6, \quad 4! = 24, \ \ldots$$
the factorials. And the rule for the digits is delightfully strict: the digit in
the $i$-th column may only range from $0$ up to $i$. The ones-from-the-right
column allows only $0$. The next allows $0$ or $1$. The next allows $0, 1, 2$.
The columns get *wider* as the digits get *more permissive*, in perfect balance.

A length-$k$ factoradic number is built from a digit function $c$ by the sum

$$\text{value}(c, k) = \sum_{i < k} c(i)\cdot i!,$$

and we call a digit assignment **valid** when it respects the column limits,
$c(i) \le i$ for every column $i < k$. This balance is not a coincidence; it is
the whole point. Because the digits are capped exactly at $i$, the largest
representable length-$k$ value is one short of a factorial:

$$\text{value}(c, k) < k! \quad \text{whenever } c \text{ is valid.}$$

This single inequality — that valid factoradic numbers of length $k$ stay
strictly below $k!$ — is the engine that makes everything else run. It says the
columns never overflow into the next factorial. From it follow the two
"splitting" identities that read a factoradic number's structure directly:
dividing a length-$(k{+}1)$ value by $k!$ recovers the top digit $c(k)$, and
taking the remainder modulo $k!$ recovers everything below it. Division and
remainder peel the number apart exactly along its columns.

Those identities deliver the system's headline property: **uniqueness**. If two
valid digit assignments produce the same value, they must be the same
assignment, digit for digit. Every whole number from $0$ up to $k! - 1$ has one
and only one factoradic address of length $k$. And the address is easy to read
off explicitly: the $i$-th digit of a number $n$ is

$$\text{digit}(n, i) = \left\lfloor \frac{n}{i!} \right\rfloor \bmod (i+1).$$

Run the construction the other way and it closes the loop perfectly: for any
$n < k!$, reassembling its extracted digits gives back $n$ exactly. The
factoradic is therefore a flawless dictionary between the plain numbers
$\{0, 1, \ldots, k!-1\}$ and the valid length-$k$ digit tuples — a bijection, in
the mathematician's word.

The factoradic is not a curiosity. It is the natural coordinate system for
*permutations*. There are exactly $k!$ ways to arrange $k$ objects, and the
factoradic gives each arrangement a number between $0$ and $k! - 1$ — a feature
used in real software to enumerate, rank, and unrank permutations without storing
them all.

## Where the two stories meet

Here is the payoff that ties the perfect search to the elastic number system.

Suppose you want to locate a target inside the space of all length-$k$
factoradic numbers — equivalently, inside the integers $\{0, 1, \ldots, k! - 1\}$.
How quickly can you do it, and is the space you're searching genuinely as large
as it claims to be, or is it secretly full of gaps and padding?

Both halves of this question have already been answered, and they snap together
into a single statement. First, the search space is *dense and faithful*: every
$n$ below $k!$ really is realized as the factoradic value of its own digits, so
there are no holes — the range $[0, k!)$ is a true size-$k!$ image of the digit
tuples, not a sparse scattering inside a larger padded interval. Second, the
addresses are *unambiguous*: distinct targets below $k!$ have distinct digit
codes, so a search key can never point to two different places. And third, the
*cost* is logarithmic in the exact sense established earlier: binary search over
$[0, k!)$ finishes in at most

$$\lceil \log_2 k! \rceil$$

comparisons — the ceiling logarithm of the factorial, the same tight bound that
governs the dictionary search.

What makes this combination satisfying is that the two ingredients are
completely independent and only meet at the surface. The complexity bound is pure
combinatorics: it knows nothing about factorials, permutations, or number
systems — only about halving an interval. The factoradic facts are pure number
theory: they know nothing about searching — only about how factorials partition
the integers. Neither argument smuggles in the other. They compose cleanly at the
one place they share: the size of the index space, $k!$. A reusable bound about
*how fast you can search* meets a reusable fact about *what there is to search*,
and the result is a precise, end-to-end guarantee.

There is a tantalizing generality lurking here. The factoradic is just one
member of a family of **mixed-radix** systems, where column $i$ has its own width
$r_i$ (the factoradic takes $r_i = i + 1$). The same reasoning suggests that for
*any* such system, binary search over its value space $[0, \prod_i r_i)$ costs
the ceiling logarithm of the product of the radices, and the digit map is always
a clean bijection onto that range. The logarithmic search cost is *uniform* across
positional number systems — base ten, base two, factoradic, or any elastic-column
scheme you care to invent.

## Why bother being this careful?

It would be fair to ask why anyone needs to nail down, to the last off-by-one,
something as old and as well-loved as binary search. The answer is that the
places where these algorithms run — flight controllers, medical devices,
cryptographic libraries, the database under your bank account — are exactly the
places where "ninety percent of programmers get it wrong" is not an amusing
statistic but a liability. A search routine that is *provably* correct for every
input, and *provably* logarithmic in the worst case, is a component you can build
on without ever revisiting.

But there is a deeper pleasure in it, too. When you strip binary search down to
its threshold-finding core, you discover that its correctness needs no sorting,
that its true cost is the ceiling logarithm and not the floor, and that the very
same logarithmic sweep that finds a word in a dictionary also charts the
factorial number system that catalogs every permutation. The humble act of
splitting a problem in half, examined closely enough, turns out to connect the
most practical of algorithms to the elegant arithmetic of factorials — a small
idea with the reach of a large one.
