# When Time Can Run Backwards: The Hidden Symmetry of Reversible Cellular Automata

## A universe on a ring

Imagine a circular necklace of $n$ beads, each of which is either black or
white. At every tick of a clock, all the beads change color simultaneously,
according to a fixed rule that looks only at each bead and its two immediate
neighbors. That is the whole of a *cellular automaton*: a tiny toy universe
whose physics is nothing more than a lookup table.

These deceptively simple systems have fascinated scientists for decades. From a
single local rule — "if my left neighbor is black and I am white, become black,
otherwise stay the same," and so on — extraordinary complexity can emerge:
fractals, chaos, gliders that sail across the grid, even patterns rich enough to
perform arbitrary computation. Cellular automata are the physicists' Lego set
for building whole worlds out of one repeated rule.

Now ask a question that goes to the heart of physics: **can such a universe run
backwards?** In our own world, the fundamental microscopic laws are believed to
be reversible — if you knew the exact state of everything, you could in
principle reconstruct the entire past. Yet most cellular automata are ruthlessly
forgetful. Apply the rule that turns *every* bead white, and after one step the
whole necklace is white regardless of how it started. The past has been erased.
There is no rewinding.

A cellular automaton is called **reversible** when no information is ever lost:
every configuration has exactly one predecessor, so the dynamics can be undone,
step by step, forever. Reversible automata are the ones that behave like honest
physical laws. And here is the beautiful question this article is about: *which*
rules are reversible, and — the deeper part — **what structure do the reversible
rules form when you consider them all together?**

The answer turns out to be a story about **symmetry** and **groups**, the
mathematical language of things that can be undone and combined.

## The formal stage

Let us fix notation so that every claim below is precise. Our lattice is the
cyclic group $\mathbb{Z}/n$ — the $n$ positions arranged in a ring. A
**configuration** is an assignment of a bit to each site,
$$c : \mathbb{Z}/n \to \{0,1\}.$$
There are $2^n$ possible configurations in all.

An **elementary rule** (radius $1$) is a function
$$r : \{0,1\}^3 \to \{0,1\}$$
that reads a cell's left neighbor, the cell itself, and its right neighbor, and
outputs the cell's next value. Because there are $2^3 = 8$ possible
neighborhoods and each can be sent to either $0$ or $1$, there are exactly
$$2^{8} = 256$$
elementary rules — the famous "Wolfram rules," numbered $0$ through $255$.

Each local rule $r$ induces a **global map** on configurations,
$$(F_r c)(i) = r\big(c(i-1),\, c(i),\, c(i+1)\big),$$
applied simultaneously at every site. The automaton is **reversible** precisely
when $F_r$ is a bijection of the $2^n$ configurations — a permutation of the
state space with a well-defined inverse.

## The first law: everything respects translation

Before asking which rules are reversible, there is a structural fact true of
*every* rule, reversible or not. Because the local rule is applied identically
at every site, the global dynamics cannot tell one position on the ring from
another. Concretely, let the **shift** $S$ rotate a configuration by one site,
$(Sc)(i) = c(i+1)$. Then for every elementary rule,
$$F_r \circ S = S \circ F_r.$$

In words: **shifting and then updating gives the same result as updating and
then shifting.** This translation invariance — a finite-lattice version of a
classical observation of Hedlund — is the seed of all the symmetry to come. It
says that the shift is a fundamental symmetry of *any* cellular automaton, and
so the reversible ones, in particular, live inside the world of maps that
commute with the shift.

## The six honest rules

Which of the $256$ elementary rules are reversible? On a ring, the reversible
elementary rules are exactly **six** of them — and they are the simplest
imaginable. Each depends on a *single* neighbor, optionally flipped:

- **Rule 204** copies the cell itself: $F(c) = c$. This is the **identity** —
  nothing ever changes.
- **Rule 51** flips the cell: $F(c)(i) = \lnot c(i)$. This is the
  **complement**, which swaps black and white everywhere.
- **Rule 170** copies the right neighbor: $F(c)(i) = c(i+1)$. This is the
  **left shift** — the whole pattern slides one step.
- **Rule 240** copies the left neighbor: $F(c)(i) = c(i-1)$. This is the
  **right shift**, the inverse slide.
- **Rule 15** copies the *flipped* left neighbor: the **complement of the right
  shift**.
- **Rule 85** copies the *flipped* right neighbor: the **complement of the left
  shift**.

Every one of these is a bijection, for a transparent reason: shifting is
reversible (just shift back), complementing is reversible (complement again),
and composing reversible operations is reversible. The identity is trivially
reversible. So all six are genuinely invertible dynamics — six honest little
universes that can run backwards.

What is striking is that these six exhaust the reversible elementary rules.
Every rule that actually *combines* information from two or more neighbors — and
that is the overwhelming majority — destroys information and cannot be undone.
Reversibility is a razor: it slices away all but the affine single-site rules.

## The rule that forgets

To feel why reversibility is special, look at its opposite. Take the constant
rule that outputs $0$ no matter what: $F(c)(i) = 0$ for all $i$. After a single
tick, *every* starting configuration collapses to the all-white necklace.
Infinitely many pasts, one present. The all-black configuration has no
predecessor at all — nothing ever maps to it. So $F$ is not a bijection: it is
not surjective, and it is wildly non-injective. On any nontrivial ring
($n \ge 1$), the constant rule is irreversible. Time, for that universe, has a
firm arrow.

## Reversible rules form a group

Here is where the "Galois theory" of the title enters. Reversibility is not just
a property of individual rules — the reversible dynamics fit together into an
algebraic object. If $F$ and $G$ are both reversible, so is their composition
$F \circ G$ (do one then the other, and undo in reverse order), and so is the
inverse $F^{-1}$. In the language of algebra, the reversible, shift-commuting
maps form a **group**: a set closed under composition and inversion, with the
identity as neutral element.

More precisely, since every cellular map commutes with the shift $S$, the
reversible ones live inside the **centralizer of the shift** — the set of all
permutations of the $2^n$ configurations that commute with $S$. This centralizer
is a genuine subgroup of the full symmetric group on the state space, and it is
the natural home of reversible dynamics. We call it the **reversibility group**.

Both of our fundamental building blocks belong to it: the shift $S$ commutes
with itself, and the complement $C$ commutes with the shift (flipping colors and
rotating can be done in either order with the same result).

## The arithmetic of shift and complement

What does the group generated by the shift $S$ and the complement $C$ actually
look like? Its structure is clean and completely computable.

- **The complement is an involution:** $C^2 = \mathrm{id}$. Flip twice and you
  are back where you started.
- **The shift has order exactly $n$:** $S^n = \mathrm{id}$, and no smaller power
  works. This is not obvious — one must show that for $0 < k < n$, the $k$-fold
  shift genuinely moves *something*. The clean witness is the "point mass"
  configuration that is black at a single site and white elsewhere: shifting it
  $k$ steps relocates the lone black bead, so $S^k$ cannot be the identity. Thus
  the shift has order precisely $n$, matching the size of the ring.
- **The two commute:** $SC = CS$.

From these three facts the group $\langle S, C\rangle$ is **abelian** — every
pair of its elements commutes — and it is a product of a cyclic rotation part of
order $n$ and a two-element flip part. Symbolically it behaves like
$\mathbb{Z}/n \times \mathbb{Z}/2$: rotate by some amount, optionally flip, and
that is every element. A small, transparent, perfectly reversible algebra of
symmetries sitting inside the vast symmetric group on $2^n$ states.

## A cautionary tale about numerology

The original motivating conjecture for this line of work proposed that the
radius-$1$ reversibility group had order $8!/4 = 10080$ — the idea being that
reversible rules could realize a large chunk of all permutations of the eight
neighborhoods. It is a tempting guess, and it is **false**. Two facts sink it.
First, the permutations of the eight neighborhoods that commute with the natural
cyclic symmetry form a group of order only $36$, not $10080$. Second, and more
fundamentally, a *global* reversible map is far more constrained than an
arbitrary shuffle of neighborhoods: as we saw, only six local rules survive the
reversibility razor at all. The honest structure is the small abelian group of
shifts and complements — humbler than the conjecture, but true, and provably so.

This is a healthy reminder that in mathematics, an elegant formula is worth
nothing until it is proved, and that the real structure a problem hides is often
quieter and more beautiful than the one we first imagine.

## Why it matters

Reversible cellular automata are not a mere curiosity. They are the discrete
model for **reversible computation** — computation that, in principle, dissipates
no energy, because it never erases information (Landauer's principle ties the
erasure of a bit to an unavoidable release of heat). They model conservative,
time-symmetric physics on a lattice. They underlie certain cryptographic and
lattice-gas simulations, where invertibility guarantees that a scrambling step
can be perfectly unscrambled.

Understanding *which* rules are reversible, and how the reversible ones assemble
into a group, is understanding the landscape of computations that can be run
backwards. The message of this article is that the landscape, at least for the
elementary rules on a ring, is not a chaotic thicket but a crystalline structure
— six generators, one commuting shift, one flipping complement, and an abelian
group that ties them together. In the smallest universe we could build, time's
arrow, when it can be reversed at all, is governed by a symmetry as clean as
arithmetic.
