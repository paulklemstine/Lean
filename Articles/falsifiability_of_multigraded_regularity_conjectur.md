# The Hidden Ladders Inside a Permutation

## How counting "out of order" pairs tames a wild question in algebraic geometry

Shuffle a deck of cards and you have made a permutation. Re-seat the
guests at a dinner table and you have made another. Permutations are the
most ordinary objects in mathematics — and also among the most
treacherous. Hidden inside the innocent act of rearranging $1, 2, 3,
\dots, n$ is a staircase of geometric shapes, the *Schubert varieties*,
whose smoothness, dimension, and algebraic "complexity" have occupied
geometers for more than a century. This is the story of a single,
sturdy number — the **inversion count** of a permutation — and how it
quietly governs a conjecture about those shapes that, on its surface,
looks impossibly hard.

### Inversions: the rust on a permutation

Start with something you can do on a napkin. Write a permutation as a
word: the permutation that sends $1 \mapsto 3$, $2 \mapsto 1$, $3 \mapsto
2$ is the word $312$. An **inversion** is a pair of positions that are
"out of order": positions $i < j$ whose values come out larger-first,
i.e. $\sigma(i) > \sigma(j)$. In $312$ the pairs $(1,2)$ and $(1,3)$ are
inversions (the $3$ sits before the $1$ and before the $2$), while
$(2,3)$ is fine. So $312$ has exactly $2$ inversions.

The **length** of a permutation, written $\ell(\sigma)$, is simply the
number of inversions:
$$\ell(\sigma) = \#\{(i,j) : i < j \text{ and } \sigma(i) > \sigma(j)\}.$$

This single count is the secret skeleton of everything that follows. The
identity permutation $123\cdots n$ — nothing out of order — has length
$0$. The full reversal $n\,(n-1)\cdots 2\,1$ has *every* pair out of
order, so its length is the largest possible: the number of pairs you can
pick from $n$ positions, written $\binom{n}{2} = \frac{n(n-1)}{2}$.
Every other permutation lands somewhere in between.

Why care? Because $\ell$ is not just a statistic; it is a **ruler**. The
permutations of $n$ symbols can be stacked into a partial order — the
*Bruhat order* — that records when one Schubert variety sits inside the
closure of another. The miracle is that this order is *graded* by
$\ell$: if you climb the order one minimal step at a time, your length
goes up by exactly one at each step. There are no shortcuts and no
detours. The order is a perfectly calibrated staircase, and $\ell$ tells
you which floor you are on.

### The ladder principle

Here is the first result, stated plainly. Imagine a chain of
permutations
$$c_0,\ c_1,\ c_2,\ \dots,\ c_k$$
that starts at the identity ($c_0 = \mathrm{id}$) and *strictly increases
in length at every step*: $\ell(c_0) < \ell(c_1) < \cdots < \ell(c_k)$.
How long can such a ladder be?

Because length starts at $0$ and rises by at least $1$ each rung, after
$i$ rungs you must have climbed at least $i$ units:
$$i \le \ell(c_i).$$
In particular the top of the ladder satisfies $k \le \ell(c_k)$. And
since no length can exceed $\binom{n}{2}$, **no such ladder can have more
than $\binom{n}{2}$ rungs**. We call this the *chain-rank bound*:
$$k \le \ell(c_k) \le \binom{n}{2}.$$

It sounds almost too simple to matter. Yet this is precisely the engine
that makes a hard-looking conjecture in algebraic geometry *finite and
well-posed*. When geometers ask for "the length of the longest chain of
Schubert varieties up to $\sigma$," they are implicitly relying on the
fact that such chains cannot run away to infinity. The ruler $\ell$
guarantees it.

### From counting to curvature: smooth permutations

Now the geometry enters. To each permutation $\sigma$ belongs a Schubert
variety $S_\sigma$, a geometric shape carved out inside a space of
subspaces (a *Grassmannian* or a *flag variety*). Some of these shapes
are smooth — locally as nice as ordinary flat space — and some have
sharp singular points where the geometry pinches or crosses itself.

In 1990, Lakshmibai and Sandhya discovered something breathtaking: you
can read a Schubert variety's smoothness *directly off the permutation's
word*, with no geometry at all. The rule is a **pattern-avoidance**
test. Look inside $\sigma$ for any four positions whose relative order
matches one of two forbidden templates:

- the pattern **3412** (template word $3,4,1,2$), or
- the pattern **4231** (template word $4,2,3,1$).

If $\sigma$ contains *neither* pattern, its Schubert variety is smooth.
If it contains *either* one, the variety is singular. That is the whole
criterion. Two short words decide the curvature of an entire family of
geometric objects.

Let us make "contains a pattern" precise, because the precision is what
makes it provable. We say $\sigma$ **contains** a length-4 pattern $\pi$
when there exist four positions $p_1 < p_2 < p_3 < p_4$ such that the
values $\sigma(p_1), \sigma(p_2), \sigma(p_3), \sigma(p_4)$ appear in the
*same relative order* as $\pi(1), \pi(2), \pi(3), \pi(4)$. If no such
quartet exists, $\sigma$ **avoids** $\pi$. A permutation is **smooth**
when it avoids both $3412$ and $4231$.

Three sanity checks anchor the definition and show it is not vacuous:

1. **The identity is smooth.** The increasing word $123\cdots n$ only
   ever realizes the *increasing* pattern $1234$ on any four positions.
   Since neither $3412$ nor $4231$ is increasing, the identity contains
   neither. Geometrically: the point Schubert variety is as smooth as it
   gets.

2. **The full reversal is smooth.** The decreasing word $n\cdots 21$
   only realizes the *decreasing* pattern $4321$. Neither forbidden
   pattern is decreasing, so the reversal — the "biggest" permutation,
   of length $\binom{n}{2}$ — is also smooth. Geometrically: the whole
   flag variety is smooth, sitting at the top of the staircase.

3. **Everything below rank 4 is smooth, automatically.** If $n < 4$
   there are not even four positions to choose, so no length-4 pattern
   can possibly fit. Every permutation of $1, 2, 3$ is smooth — the
   combinatorial shadow of the classical fact that *all* Schubert
   varieties in small flag varieties are smooth.

These are not loopholes. For $n \ge 4$ the forbidden patterns genuinely
occur — $3412$ and $4231$ are themselves honest, non-identity,
non-reversal permutations — so the smoothness criterion has real teeth.

### Counting the smooth ones

How common is smoothness? Enumerate the smooth permutations of $n$
symbols and a striking sequence emerges:

$$1,\ 2,\ 6,\ 22,\ 88,\ 366,\ 1552,\ \dots$$

for $n = 1, 2, 3, 4, 5, 6, 7$. (For $n \le 3$ *all* $n!$ permutations are
smooth, giving $1, 2, 6$; the first singular permutations appear at $n =
4$, where $24 - 22 = 2$ of them — namely $3412$ and $4231$ — are
singular.) This is sequence **A005802** in the Online Encyclopedia of
Integer Sequences, the official census of smooth Schubert varieties.
There is even a closed-form generating function, a sign that the smooth
class is a deeply structured family rather than an arbitrary collection.

### The conjecture: a refined ruler for complexity

We can finally state the central question. Algebraic geometers measure
how "complicated" an embedded variety is with a number called the
**Castelnuovo–Mumford regularity** — roughly, how high the degrees climb
before the variety's defining equations and their syzygies settle into a
predictable pattern. Low regularity means the variety is described
efficiently; high regularity means its algebra is unruly. For Schubert
varieties sitting inside their natural *Plücker embedding*, bounding the
regularity is a long-standing and delicate problem, with the best general
bounds expressed through the combinatorics of the Bruhat order.

The conjecture at the heart of this work proposes a *sharper* ruler:

> **The multigraded Castelnuovo–Mumford regularity of the Schubert
> variety $S_\sigma$, in its Plücker embedding, is at most the length of
> the longest chain of Bruhat-ordered Schubert varieties from the bottom
> up to $\sigma$ in which every intermediate step is a smooth
> permutation — one avoiding both $3412$ and $4231$.**

Two ingredients make this bold proposal even *thinkable*, and both are
exactly the combinatorial facts established above:

- **Finiteness and the upper limit.** The chain-rank bound guarantees
  the "longest chain" is a genuine finite number, never exceeding
  $\binom{n}{2}$. Without this, the conjecture would not even be
  well-defined. The ruler $\ell$ supplies the scaffolding.

- **The smoothness constraint is real but reachable.** Requiring every
  intermediate Schubert variety to be smooth is a genuine restriction.
  But smooth Schubert varieties have a remarkable hereditary property:
  the entire Bruhat interval below a smooth $\sigma$ tends to consist of
  smooth elements. So a smooth chain to a smooth $\sigma$ can plausibly
  climb all the way to the top floor $\ell(\sigma)$, suggesting the
  refined bound is not merely valid but *sharp*.

The payoff, when the longest smooth chain is strictly shorter than
$\ell(\sigma)$, is a regularity bound that *improves* on the existing
ones — a finer instrument calibrated by the same trusty ruler.

### Why a simple count carries so much weight

There is a lesson here that recurs throughout mathematics: the right
invariant turns an intractable question into a finite search. The
regularity of a Schubert variety is an algebraic quantity defined through
infinite resolutions and graded modules. Yet its conjectured bound is a
*combinatorial* quantity — the height of a ladder of permutations — and
that ladder's height is policed by a number a schoolchild can compute by
crossing out out-of-order pairs.

The pieces fit together like a well-made tool:

- **The inversion count $\ell$** is the ruler. It starts at $0$ on the
  identity, tops out at $\binom{n}{2}$ on the reversal, and grades the
  Bruhat order so that every chain has a definite, bounded height.

- **The chain-rank bound** ($k \le \ell(c_k) \le \binom{n}{2}$) makes
  "longest chain" a finite, well-defined notion — the conjecture's
  foundation.

- **Pattern avoidance** ($3412$ and $4231$) translates geometric
  smoothness into a finger-counting test, and the smooth class is robust:
  it contains the identity, the reversal, and everything of rank below
  four, and it is conjecturally closed under the natural symmetries of
  permutations.

Put together, they reframe a frontier problem in algebraic geometry as a
question about climbing staircases built from out-of-order pairs.
Whether the conjecture stands or falls, the reframing itself is the
prize: it shows that the unruly algebra of Schubert varieties answers,
at least in part, to the most elementary thing you can count in a
shuffle.

### The road ahead

Several precise, falsifiable conjectures grow out of this picture. The
smooth class should be *blind to inversion*: $\sigma$ is smooth exactly
when its inverse is, because the two forbidden patterns are their own
inverses. Multiplying by the full reversal should *complement* the
length, $\ell(w_0\sigma) = \binom{n}{2} - \ell(\sigma)$, partitioning the
$\binom{n}{2}$ position-pairs neatly into inversions and non-inversions.
And smooth chains should be *co-final* — able to reach the full height
$\ell(\sigma)$ whenever $\sigma$ itself is smooth — which would make the
refined regularity bound sharp rather than merely valid.

Each of these is a clean target, and each rests on the same humble
foundation: count the pairs that are out of order, and let that count be
your guide. Sometimes the deepest geometry is hiding in the simplest
arithmetic.
