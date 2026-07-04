# Escher Staircases in Algebra: Infinite Staircases That Loop Back to the Start

## An impossible picture

Look at one of Escher's famous lithographs and you will find a staircase where
every step rises above the last, yet after four turns you are back exactly where
you began. Climb forever, and you never leave the ground floor. The drawing is a
visual paradox: a chain that only ever goes *up* somehow *closes into a loop*.

Mathematicians love a good paradox, because a paradox is usually a signpost
pointing at something we have not yet understood clearly. This article is about
the algebraic version of Escher's staircase. It turns out that infinite chains of
"algebraic sizes" — the objects called *ideals* — can behave exactly like the
lithograph: they can climb forever and, in a precise sense, loop back to their
starting point. And once you see *why* this happens, the paradox dissolves into a
single clean fact about how infinite towers of nested sets behave.

The reward for understanding it is more than a curiosity. The existence of such a
staircase turns out to be a perfect litmus test for one of the most important
dividing lines in all of algebra: the line between *Noetherian* rings, the
well-behaved workhorses of modern mathematics, and the wild, non-Noetherian rings
that resist our usual tools.

## Rings, ideals, and the meaning of "size"

Start with a **ring**: a set of objects you can add, subtract, and multiply,
following the ordinary rules of arithmetic. The integers $\mathbb{Z}$ form a
ring. So do polynomials, matrices, and functions of many kinds.

Inside a ring live special subsets called **ideals**. An ideal $I$ is a subset
that is closed under addition and, crucially, "absorbs" multiplication: if $x$ is
in $I$ and $r$ is *any* element of the ring, then $r\cdot x$ is still in $I$. In
the integers, the multiples of $6$ form an ideal; so do the multiples of $2$.
Ideals are the natural notion of a "sub-size" of a ring, and they can be compared:
the multiples of $6$ sit *inside* the multiples of $2$, because every multiple of
$6$ is even. We write this as an inclusion, $I \subseteq J$.

An **ascending chain** of ideals is a tower
$$I_0 \subseteq I_1 \subseteq I_2 \subseteq \cdots$$
where each ideal contains the previous one. If every inclusion is *strict* — each
step genuinely adds something new, $I_n \subsetneq I_{n+1}$ — then we have an
infinite staircase that only ever climbs. This is the object we will call an

> **Escher staircase:** an infinite, strictly ascending chain of ideals
> $I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots$.

## The great dividing line: Noetherian rings

In the 1920s Emmy Noether identified the single most consequential "good
behaviour" property a ring can have. A ring is called **Noetherian** if it
satisfies the *ascending chain condition*: **every** ascending chain of ideals
eventually stops growing. You may climb for a while, but sooner or later you hit a
step from which you can rise no further — the chain stabilizes.

The integers are Noetherian. Polynomial rings in finitely many variables are
Noetherian. Almost every ring a student meets in a first course is Noetherian, and
this is exactly why those rings are so tractable: the ascending chain condition is
the engine behind unique factorization results, dimension theory, and much of
algebraic geometry.

The definition makes the connection to our staircase immediate and total:

> **The Characterization Theorem.** A commutative ring admits an Escher staircase
> if and only if it is *not* Noetherian.

In words: an infinite, strictly climbing tower of ideals is not just *evidence* of
bad behaviour — it is *precisely* the failure of the ascending chain condition,
repackaged. A ring is wild exactly when it contains an impossible staircase. The
staircase is a faithful certificate of non-Noetherianity.

Why is this true? One direction is almost the definition read backwards: if a
staircase exists, some chain never stabilizes, so the ascending chain condition
fails. The other direction is the substantive one. Saying a ring is Noetherian is
the same as saying the collection of its ideals, ordered by inclusion, is
*well-founded going downward* — there are no infinite strictly *descending* runs
when you reverse the order. When that well-foundedness fails, a standard principle
lets you *extract* an actual infinite strictly ascending sequence, step by step,
rather than merely knowing one exists abstractly. Assemble those steps and you have
built an Escher staircase by hand.

## The staircase that loops back

Now for the paradox. We will build an explicit Escher staircase and watch it loop
back to its starting point.

Consider the ring of all infinite sequences
$$f = (f_0, f_1, f_2, \dots)$$
whose entries are drawn from the two-element number system $\mathbb{F}_2 =
\{0,1\}$, in which $1+1=0$. Add and multiply sequences slot by slot. This is a
perfectly good commutative ring — call it the **Boolean product ring** $B =
\prod_{\mathbb{N}} \mathbb{F}_2$. (Nothing essential changes if you use the
integers in each slot instead; the two-element system just keeps the bookkeeping
clean.)

For each $n$, define
$$I_n = \{\, f \in B : f_i = 0 \text{ for every index } i \ge n \,\},$$
the sequences that are "supported below $n$" — allowed to be nonzero only in the
first $n$ slots, and forced to be zero from position $n$ onward. These are genuine
ideals: multiplying such a sequence, slot by slot, by *any* sequence keeps the
late slots zero.

These ideals climb, and they climb *strictly*:
$$I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots$$
Each rung genuinely adds room. To see the strictness, look at the sequence that is
$1$ in slot $n$ and $0$ everywhere else. It vanishes from position $n+1$ onward, so
it lives in $I_{n+1}$; but it is nonzero at position $n$, so it is *not* in $I_n$.
Every step of the staircase is real.

Here is the loop. What is the bottom rung? A sequence lies in $I_0$ only if it is
zero at *every* index $i \ge 0$ — that is, it is the all-zeros sequence. So
$$I_0 = \{0\},$$
the smallest ideal there is. And what is the *infinite intersection* of the whole
tower, the set of sequences that belong to **every** rung at once? A sequence in
all the $I_n$ must vanish beyond index $n$ for every $n$ — it must be zero
everywhere. So
$$\bigcap_{n=0}^{\infty} I_n = \{0\} = I_0.$$
The staircase climbs forever, adding something new at every single step — and yet
the meet of everything it ever reaches is exactly the point it started from.
Climb to infinity, and you are back on the ground floor.

## The paradox dissolves

Stated that way it sounds impossible. But now watch it evaporate. The intersection
of an ascending chain is always contained in its very first term, simply because
the first term is one of the sets being intersected — and the first term, being
the smallest, is contained in every later one, so it survives the intersection
untouched. Therefore, for *any* ascending chain whatsoever,
$$\bigcap_{n=0}^{\infty} I_n = I_0.$$

This is the **Loop-Back Lemma**, and it is a one-line truth about nested sets. The
intersection of an ascending tower is *always* its bottom rung — there is no other
possibility. The Escher effect is not a rare accident that occurs in exotic rings;
it is guaranteed the moment a chain ascends at all. What made the picture feel
impossible was a confusion between two different questions: "does the chain keep
*growing*?" (yes, forever) and "what do all its members share?" (only the bottom
rung). A staircase can rise without bound while its common ground never budges.
Escher's optical trick and the algebraist's ideal chain are the same illusion,
lit from two angles.

## The mirror image, and the ring with no staircase at all

There is a satisfying mirror to this story. Inside the integers, consider the
*descending* dyadic chain of ideals
$$(2^0) \supseteq (2^1) \supseteq (2^2) \supseteq \cdots,$$
the multiples of $1$, then the multiples of $2$, then of $4$, and so on, each
sitting inside the last. This is a genuinely *shrinking* tower — and it too
collapses to the zero ideal:
$$\bigcap_{n=0}^{\infty} (2^n) = \{0\},$$
because a nonzero integer can only be divisible by finitely many powers of $2$.
The ascending "loop-back to zero" and this descending "collapse to zero" are two
faces of the same phenomenon — a vanishing intersection — approached from opposite
directions.

Finally, the negative instance that completes the picture. Not every ring hosts an
Escher staircase — indeed, by the Characterization Theorem, the *nice* rings never
do. The cleanest example is the ring of **$p$-adic integers** $\mathbb{Z}_p$, a
number system built by allowing infinitely long carries in base $p$. It is a
*discrete valuation ring*: its ideals are perfectly linearly ordered and are
nothing but the powers of a single prime element, $(p) \supseteq (p^2) \supseteq
\cdots$. Every ascending chain of ideals in $\mathbb{Z}_p$ stops almost
immediately. It is Noetherian, and so — with no room for argument — it admits **no
Escher staircase**. In the world of $p$-adic integers, all staircases are finite,
honest, and end at a top step. Escher's architecture simply cannot be built there.

## Why it matters

The moral is larger than the trick. The single yes/no question "does this ring
contain an impossible staircase?" turns out to *exactly* separate the tame rings
from the wild ones — the Noetherian universe, where nearly all of classical algebra
and geometry lives, from the untamed rings beyond it. Non-Noetherian rings are not
fringe curiosities: rings of continuous functions, rings of all algebraic
integers, infinite polynomial rings, and the coordinate rings of infinite-
dimensional spaces are all non-Noetherian, and all of them, we now know, hide an
Escher staircase inside.

Seeing that staircase for what it is — not a paradox, but a precise and
inevitable feature of any ring that fails the ascending chain condition — turns
Escher's impossible drawing into a working piece of mathematics. And it invites a
tantalizing next question. Every non-Noetherian ring has *a* staircase; but *how
fast* must its rungs grow, how many generators does each successive ideal demand?
That growth rate promises a finer invariant, one that could distinguish
non-Noetherian rings that the crude yes/no test lumps together — a way to measure
not just *whether* a ring is wild, but *how* wild it is. The impossible staircase,
it seems, has more floors left to explore.
