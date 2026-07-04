# Escher Staircases in Algebra: The Impossible Staircase Made of Ideals

## A staircase that climbs forever and ends where it began

In one of M. C. Escher's most famous lithographs, a troop of monks trudges
endlessly up a rectangular staircase. Each step is genuinely higher than the last,
yet after four flights the monks arrive back exactly where they started. The image
is a visual paradox: local ascent, global return. It cannot be built out of wood and
stone — but, as it turns out, it *can* be built out of algebra.

The bricks of this algebraic staircase are **ideals**. An ideal of a commutative
ring $R$ is a subset $I \subseteq R$ that contains $0$, is closed under addition, and
*absorbs* multiplication: if $a \in I$ and $r \in R$, then $ra \in I$. Ideals are the
natural "sub-objects" of a ring — they are exactly the kernels of ring
homomorphisms, and they generalize the notion of a number being divisible by a fixed
divisor. The ideals of a ring, ordered by inclusion, form a lattice, and much of the
structure of the ring is encoded in the shape of that lattice.

An **Escher staircase** is an infinite strictly ascending chain of ideals

$$ I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots $$

where each rung is *strictly* larger than the one below. The name is more than a
metaphor. In the flagship example below, the ascent begins at the very bottom of the
lattice — the zero ideal $\{0\}$ — and the *meet* (the largest ideal contained in all
of them, written $\bigwedge_n I_n$) is again $\{0\}$. You climb forever, and yet the
common floor beneath every step you ever reach is the single point you started from.
The staircase loops back.

## The one thing that forbids the staircase

Whether a ring admits an Escher staircase is not a matter of luck or cleverness. It
is governed by a single, classical property.

A ring is called **Noetherian** — after Emmy Noether, who placed the idea at the
center of modern algebra — if it satisfies the *ascending chain condition*: every
ascending chain of ideals eventually stops growing. There is no infinite strict
climb; sooner or later two consecutive rungs coincide and the chain stabilizes.
Noetherian rings are the "well-behaved" rings of algebra and geometry: the integers,
any field, any polynomial ring in finitely many variables over a field, and the
coordinate rings of algebraic varieties are all Noetherian.

The connection to our staircase is immediate and exact:

> **The Invariant Theorem.** A commutative ring admits an Escher staircase if and
> only if it is **not** Noetherian.

This is a clean dichotomy. An Escher staircase is not an exotic accident — it is
*precisely* the visible failure of the ascending chain condition. To exhibit an
impossible staircase in a ring is to certify that the ring is non-Noetherian, and
conversely, every non-Noetherian ring hides such a staircase inside it. The
"impossible architecture" is exactly the geometry of a ring that Noether's condition
cannot tame.

## Building the staircase by hand

Abstract existence is one thing; a staircase you can point at is another. Here is a
completely explicit one.

Consider the ring $R = \prod_{n \in \mathbb{N}} \mathbb{Z}$ of all infinite
sequences of integers $f = (f_0, f_1, f_2, \dots)$, added and multiplied
coordinate by coordinate. For each $n$, let

$$ S_n = \{\, f \in R : f_k = 0 \text{ for all } k \ge n \,\} $$

be the set of sequences that vanish from index $n$ onward. Each $S_n$ is an ideal:
adding two eventually-zero sequences keeps them eventually zero, and multiplying by
*any* sequence preserves the zeros. Now watch the staircase assemble itself.

- **The bottom is the floor.** $S_0$ consists of sequences that vanish for every
  $k \ge 0$ — that is, the single zero sequence. So $S_0 = \{0\}$.
- **Every step is strictly higher.** The sequence $e_n$ that is $1$ in position $n$
  and $0$ everywhere else belongs to $S_{n+1}$ (it vanishes from index $n+1$ on) but
  *not* to $S_n$ (it is nonzero at position $n$). So $S_n \subsetneq S_{n+1}$, with
  $e_n$ as an explicit witness to the strict jump.
- **The climb never ends.** Because a fresh witness $e_n$ appears at every level, the
  chain $S_0 \subsetneq S_1 \subsetneq S_2 \subsetneq \cdots$ is strictly ascending
  forever.
- **The staircase loops back.** What is the meet $\bigwedge_n S_n$, the set of
  sequences lying in *every* rung? A sequence in all the $S_n$ lies in particular in
  $S_0 = \{0\}$, so it must be zero. The infimum of the entire ascending tower is the
  zero ideal — the very floor the ascent began from.

There it is: an ideal-theoretic Escher staircase, climbed step by explicit step, that
returns to its starting point. And by the Invariant Theorem, its mere existence
proves that $\prod_n \mathbb{Z}$ is not Noetherian.

A second, equally vivid staircase lives in the polynomial ring
$k[x_0, x_1, x_2, \dots]$ in *countably many* variables over a field $k$. Let
$V_n = \langle x_0, x_1, \dots, x_{n-1}\rangle$ be the ideal generated by the first
$n$ variables. Then $V_0 = \{0\}$, and $x_n$ lies in $V_{n+1}$ but not in $V_n$ —
because a genuine polynomial identity would be needed to express $x_n$ using only the
earlier variables, and none exists (setting the earlier variables to zero would force
$x_n = 0$, which is false). So

$$ \langle x_0\rangle \subsetneq \langle x_0, x_1\rangle \subsetneq \langle x_0, x_1, x_2\rangle \subsetneq \cdots $$

is another impossible staircase, again with meet $\{0\}$.

## Where the staircase cannot be built

The dichotomy has a negative side, and it is just as sharp. Some rings are so rigid
that no Escher staircase can exist inside them.

The cleanest example is the ring $\mathbb{Z}_p$ of **$p$-adic integers**. This ring is
a *discrete valuation ring*: it has essentially one prime, and every ideal is a power
of that prime. Its ideal lattice is a single descending ladder
$\mathbb{Z}_p \supset p\mathbb{Z}_p \supset p^2\mathbb{Z}_p \supset \cdots$, with no
room for an infinite strict *ascent*. Discrete valuation rings are Noetherian, so by
the Invariant Theorem, $\mathbb{Z}_p$ admits **no** Escher staircase. Every ascending
chain of ideals in the $p$-adics eventually freezes.

The same rigidity appears in polynomial rings the moment we cap the number of
variables. The **Hilbert Basis Theorem** — one of the founding results of modern
algebra — says that if $R$ is Noetherian, so is $R[x]$. Iterating, $k[x_1, \dots, x_n]$
is Noetherian for every finite $n$. This produces a beautiful *dichotomy for
polynomial rings*: over a field, a polynomial ring admits an Escher staircase exactly
when it has infinitely many variables. Finitely many variables: no staircase.
Countably many: the explicit variable staircase above. The phenomenon is pinned
precisely on the *infinitude* of the variable set.

## How the staircase travels between rings

The heart of this work is understanding how the impossible staircase behaves when we
build new rings from old — because that is where the real surprises live. Three
transfer laws tell the story.

**Products: a local-to-global law.** Form the product ring $R \times S$, whose
elements are pairs $(r, s)$ with coordinatewise operations. Then

$$ R \times S \text{ admits an Escher staircase} \iff R \text{ does or } S \text{ does.} $$

In other words, the impossible staircase of a finite product is always visible in a
single coordinate. The reason is that each projection $R \times S \to R$ and
$R \times S \to S$ is surjective, and non-Noetherianity is inherited by anything that
*surjects onto* a non-Noetherian ring; conversely a product of two Noetherian rings
is Noetherian. This is a genuine local-to-global principle: the obstruction is
detected factorwise.

**One variable is neutral.** Adjoin a single indeterminate to form $R[x]$. Then

$$ R[x] \text{ admits an Escher staircase} \iff R \text{ does.} $$

Adjoining one variable can neither manufacture nor dissolve the staircase. If $R$ is
Noetherian, the Hilbert Basis Theorem keeps $R[x]$ Noetherian (no staircase created);
if $R$ is not, the evaluation map $R[x] \to R$ sending $x \mapsto 0$ is a surjection,
so $R[x]$ cannot be Noetherian either (no staircase destroyed). Combined with the
polynomial dichotomy, this locates the phenomenon exactly: it is the *infinite* jump
from finitely many to infinitely many variables that matters, never any single step.

**The collapse: a staircase that vanishes upstairs.** The most Escher-like result of
all concerns *subrings*. One might expect that enlarging a ring can only make its
ideal structure richer — that a staircase, once present, survives when you embed the
ring into a bigger one. This is false, and dramatically so.

Take the non-Noetherian domain $\mathbb{Q}[x_0, x_1, x_2, \dots]$, which carries the
infinite variable staircase described above. Being an integral domain, it embeds into
its **field of fractions** $\mathbb{Q}(x_0, x_1, \dots)$ by an injective ring
homomorphism. But a field has only two ideals — $\{0\}$ and the whole field — so it is
trivially Noetherian and has *no* Escher staircase whatsoever. The infinite ascending
tower $\langle x_0\rangle \subsetneq \langle x_0, x_1\rangle \subsetneq \cdots$, so
carefully built downstairs, has no analogue upstairs: every nonzero element becomes
invertible, and each rung swells to the entire field.

> **The Collapse Theorem.** There is an injective ring homomorphism from a ring that
> *admits* an Escher staircase into a ring that admits *none* — concretely,
> $\mathbb{Q}[x_0, x_1, \dots] \hookrightarrow \mathbb{Q}(x_0, x_1, \dots)$, a
> non-Noetherian domain sitting inside a field.

This is the algebraic realization of Escher's illusion in its purest form. The
staircase is a feature of how far a ring stands *from* being Noetherian, and shrinking
a ring can push it *further* from Noetherian than any ring containing it. Injective
maps — subring inclusions — carry information the wrong way for the ascending chain
condition. The impossible staircase that climbs forever inside the subring simply is
not there once you step up to the overring. It was, all along, a trick of the
architecture.

## Why this matters

Non-Noetherian rings are usually treated as pathologies — the wild frontier beyond
the well-ordered world Noether mapped out. The Escher staircase reframes them as
objects with their own vivid geometry. "Admits an Escher staircase" is a genuine ring
invariant, equal on the nose to non-Noetherianity, and the transfer laws show it
behaves *functorially* along surjections while breaking, spectacularly, along
inclusions.

That asymmetry is the point. In most of mathematics, sub-objects inherit good
behavior and quotients can misbehave; here it is exactly reversed. A ring can be more
tangled than everything containing it, and the tangle can be exhibited as a concrete,
climbable, looping staircase. Escher drew a picture of a place that cannot exist. In
the lattice of ideals, that place exists — and now we know exactly which rings contain
it, and what happens to it when you try to walk out the door.
