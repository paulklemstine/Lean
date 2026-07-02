# The Album That Fills Last: Fairness, Collectors, and a Surprising Rule of Balance

## A childhood puzzle with a grown-up secret

Anyone who has ever tried to complete a sticker album knows the frustration.
You buy pack after pack, and near the end you are stuck chasing the same few
missing stickers while duplicates of everything else pile up in a shoebox. This
is the famous **coupon collector's problem**: if there are $N$ different types of
coupon, each equally likely, how long until you have seen every type at least
once? The answer, roughly $N \ln N$ draws, is a staple of probability courses
and a favorite of anyone who has ever wondered why the last few stickers take
forever.

But real life is messier than the textbook version, and it hides a question the
textbook never asks. Imagine two children collecting from the *same* stream of
packs. The older sibling, the "main collector," only wants a **complete set**:
one of each type. The younger sibling is greedier. In the younger sibling's
album, a type does not count as done until it has been seen $j$ times, not once.

Now here is the moment that gives this story its drama. The instant the older
sibling shouts "I'm finished!" — the moment the last missing type finally
appears — we freeze time and look at the younger sibling's album. How many empty
slots are still staring back?

We call this random count $U_j^N$: the number of types that the younger sibling
has seen fewer than $j$ times at the exact moment the older sibling completes a
full set. The central discovery of this work is a clean and slightly
counterintuitive rule about when that number of empty slots is largest.

## The question of fairness

The coupons need not be equally likely. Some stickers are rare, some are common;
some soda-cap prizes are printed by the millions and others by the thousands.
Write the drawing probabilities as a vector $p = (p_1, \dots, p_N)$ with
$p_i > 0$ and $\sum_i p_i = 1$. Every choice of $p$ is a different "world," and
in each world the younger sibling ends up, on average, with some expected number
of empty slots $E_p[U_j^N]$.

Which world is *worst* for the younger sibling — which drawing distribution
leaves the most empty slots, on average, at the older sibling's finish line?

Intuition can pull in two directions. On one hand, if the coupons are wildly
unequal, the common types get slammed with copies while the rare types lag, so
you might guess that lopsidedness leaves lots of holes. On the other hand,
lopsidedness also means the *older* sibling waits a very long time for the rare
type — and all that waiting gives the younger sibling extra draws to fill in the
common types. Which effect wins?

The answer is crisp: **the perfectly balanced world is the worst one.** When
every type is equally likely, $p = (1/N, \dots, 1/N)$, the younger sibling is
left with the most empty slots, on average. Any deviation from perfect balance
*helps* the younger sibling. Moreover, help arrives monotonically: every time
you take a sliver of probability from a rarer type and give it to a more common
type — a kind of Robin-Hood-in-reverse transfer that makes the distribution more
unequal — the expected number of empty slots strictly goes down.

## The two-collector world, solved completely

The cleanest version of the story has just two types of coupon, drawn with
probabilities $a$ and $1-a$. Here the older sibling finishes the moment *both*
types have shown up. Freeze time, and count how many of the two types the
younger sibling still has fewer than $j$ copies of. The expected number of empty
slots turns out to have a beautifully simple form:

$$ E_a[U_j] = 2 - a^{\,j} - (1-a)^{\,j}. $$

Look at what this formula is telling us. The term $a^j$ is exactly the
probability that the *first* $j$ draws restricted to the eventual "race" are all
the common type — it measures how easily the $a$-type races ahead. Subtracting
$a^j$ and $(1-a)^j$ from the two slots leaves precisely the expected number of
slots still short of the threshold.

Now treat the right-hand side as a function of $a$ on the interval $(0,1)$. It is
symmetric under swapping $a$ and $1-a$, it is smooth, and its derivative,
$-j\,a^{j-1} + j\,(1-a)^{j-1}$, vanishes only at $a = 1/2$. There the function is
at a **strict maximum**, taking the value $2 - 2^{\,1-j}$. Slide $a$ away from
$1/2$ in either direction and the value strictly decreases. That is the
two-type extremality theorem in a single picture: a gentle hill with its summit
squarely over the fair coin. For this two-type world, the balance-is-worst rule
is not a conjecture or a simulation — it is a theorem, proven for every threshold
$j \ge 2$.

## Cracking the general case: inclusion and exclusion

For more than two types the geometry gets richer, but the underlying idea is the
same, and it can be pinned down exactly. The trick is to ask, one type at a time,
for the probability that a given type $i$ is still *empty* in the younger
sibling's album at the finish line.

A type $i$ is empty precisely when its $j$-th copy has not yet appeared by the
time every other type has appeared at least once. Equivalently, every rival type
must "beat" the $j$-th copy of type $i$ to the finish. This is a race with many
competitors, and races with many competitors are exactly what the
**inclusion–exclusion principle** was built for. Peeling off the overlaps
between "type $s$ beats type $i$" events, and using the elegant fact that if we
watch only the draws whose type lies in a chosen subset $\{i\} \cup S$, the
chance that the first $j$ of them are all type $i$ is simply
$\left(p_i / (p_i + \sum_{s \in S} p_s)\right)^j$, we arrive at an exact closed
form:

$$ E_p[U_j^N] \;=\; \sum_{i=1}^{N} \; \sum_{S \subseteq [N]\setminus\{i\}}
(-1)^{|S|}\left(\frac{p_i}{\,p_i + \sum_{s \in S} p_s\,}\right)^{\!j}. $$

This single formula is the engine of the whole theory. It is an exact
expression — no approximations, no asymptotics — for the average number of empty
slots, valid for any number of types $N$, any threshold $j \ge 2$, and any
drawing distribution $p$.

Two features of this formula deserve applause. First, it is **symmetric**:
relabel the coupon types however you like — swap "red" for "blue," reshuffle the
whole palette — and the expected empty count does not budge. Mathematically, the
value depends on $p$ only through the *multiset* of its entries, not on which
type carries which probability. This is the structural fingerprint of a fair
quantity, and it is exactly the property that any "balance is extremal" statement
must rest on.

Second, it collapses gracefully. Plug in $N = 2$ and the towering double sum
melts back into the friendly $2 - a^j - (1-a)^j$ we already met. A general theory
that reproduces the special case you trust is a theory worth believing.

## The value at perfect balance

What does the formula say in the fair world, where every type has probability
$1/N$? All the messy denominators become sums of equal pieces, the powers of
$-1$ organize themselves into a binomial pattern, and the whole expression
condenses into a single alternating sum:

$$ E_{\text{uniform}}[U_j^N] \;=\; N \sum_{s=0}^{N-1} (-1)^s
\binom{N-1}{s}\frac{1}{(1+s)^{\,j}}. $$

This is a concrete number you can compute by hand. For three equally likely
types and a threshold of three copies, it evaluates to
$3\left(1 - \tfrac{2}{8} + \tfrac{1}{27}\right) = \tfrac{85}{36} \approx 2.36$:
of the three slots in the younger sibling's album, about two and a third are
expected to still be empty when the older sibling completes the set. Nudge the
distribution off balance — say to $(1/2, 1/4, 1/4)$ or $(3/5, 1/5, 1/5)$ — and
the expected empty count drops below $85/36$ every time, exactly as the
balance-is-worst rule predicts.

## Why balance is the enemy of the greedy sibling

Strip away the algebra and a clean intuition remains. Perfect balance is the
state in which the older sibling finishes *as fast as possible*, because no
single rare type holds the whole set hostage. A fast finish means fewer total
draws, and fewer total draws means the younger sibling, who needs many copies of
everything, has had the least time to stock up. Unbalance the coupons and you
create bottlenecks: the older sibling now waits on the rare types, and every
extra pack bought during that wait is a free gift to the younger sibling's
album. The mathematics turns this hand-wavy story into a precise, symmetric,
exactly computable law.

There is a name for the shape of this phenomenon. A quantity that is largest at
the balanced point and that decreases under every Robin-Hood-in-reverse transfer
is called **Schur-concave** — it respects the partial order of "how spread out"
a distribution is. The claim that $E_p[U_j^N]$ is Schur-concave for every $N$ and
every $j$ is the grand unifying statement of this subject. For two types it is a
theorem; for the general case the exact closed form reduces the entire question
to a single, concrete inequality about averaging two coordinates at a time — a
sharply posed target rather than a vague hope.

## Beyond the album

The sibling collector is a toy, but the machinery it exposes is not. The same
freeze-frame-at-completion question appears wherever one process races to
coverage while another quietly accumulates redundancy: cache systems that want
every data block loaded at least once while tracking how many blocks are already
comfortably replicated; distributed networks waiting for full gossip coverage
while measuring how thoroughly the popular messages have propagated; quality
testing that runs until every component has been exercised once, then asks how
many components got the stress-testing they really needed. In all of them, the
lesson is the same and slightly subversive: **if you want the deepest coverage
by the time the basic job is done, make the process as lopsided as you can — and
if fate hands you perfect balance, brace for the emptiest album of all.**
