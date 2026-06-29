# The Shape of Symmetry: Counting the Fingerprints of the Permutation Groups

## A table that knows everything about a group

Imagine you could compress everything essential about a symmetry — every way an
object can be rotated, reflected, or shuffled — into a single rectangular grid of
numbers. Mathematicians can. The grid is called a **character table**, and for more
than a century it has been one of the most powerful instruments in algebra. From the
structure of molecules in chemistry to the error-correcting codes that keep your phone
calls clean, character tables quietly do their work in the background.

A character table is, at heart, a fingerprint. Two groups that look different on the
surface but secretly share the same symmetry produce the same table. Physicists read
off selection rules from it — which transitions in an atom are allowed and which are
forbidden. Crystallographers use it to classify the $230$ possible crystal structures.
And yet, for all its power, the character table begins with a deceptively simple
question:

> **How many rows does it have?**

This article is about pinning down the answer for the most fundamental family of
symmetries in all of mathematics — the **symmetric groups** $S_n$, the groups of all
possible shufflings of $n$ objects — and doing so with the full, unforgiving rigor of a
machine-checked proof.

## What is a symmetric group?

Take three coins on a table, labelled $1$, $2$, $3$. You can leave them as they are, swap
two of them, or cycle all three around. Count carefully and you find exactly **six**
distinct rearrangements. This collection of six shuffles, with "do one then another" as
its combination rule, is the symmetric group $S_3$.

In general, the symmetric group $S_n$ consists of all the ways to rearrange $n$
labelled objects. There are $n!$ (n factorial) of them: $S_3$ has $6$ elements, $S_4$ has
$24$, and $S_5$ has $120$. These groups are the beating heart of group theory; a
celebrated theorem of Cayley says that *every* finite group is hiding inside some $S_n$.
Understanding the symmetric groups is, in a real sense, understanding all of finite
symmetry.

## Conjugacy classes: when two shuffles are "the same shape"

Here is the crucial idea. Not all of the six shuffles in $S_3$ are genuinely different in
character. The three swaps — "swap 1 and 2," "swap 1 and 3," "swap 2 and 3" — are all
the *same kind of move*. If you relabel your coins, one turns into another. Algebraists
capture this with the notion of a **conjugacy class**: two elements $g$ and $h$ belong to
the same class when $h = x\,g\,x^{-1}$ for some shuffle $x$ — that is, when $h$ is just $g$
seen through a change of labels.

For $S_3$ the elements fall into exactly **three** conjugacy classes:

- the identity (do nothing) — one element;
- the transpositions (a single swap) — three elements;
- the $3$-cycles (rotate all three) — two elements.

Three classes. And here is the punchline that ties everything together: a foundational
theorem of representation theory says that **the number of rows in a group's character
table equals its number of conjugacy classes.** So the character table of $S_3$ is a
perfectly square $3 \times 3$ grid. The table of any finite group is always square, and
its side length is the number of "shapes" of element it contains.

So our headline question — *how many rows?* — becomes: **how many conjugacy classes does
$S_n$ have?**

## The magic of cycle type

For the symmetric groups there is a breathtakingly clean answer, and it connects to one
of the oldest objects in number theory.

Every shuffle can be broken into **cycles**. Take the rearrangement of five objects that
sends $1\to 2\to 3\to 1$ while swapping $4\leftrightarrow 5$. It is built from one cycle
of length $3$ and one cycle of length $2$. The list of these cycle lengths —
here $3 + 2$ — is called the **cycle type** of the permutation. The deep fact, classical
but powerful, is this:

> **Two permutations are conjugate if and only if they have the same cycle type.**

In other words, relabelling can turn a "$3$-cycle plus a swap" into any other "$3$-cycle
plus a swap," but it can never turn it into something of a different cycle shape. The
cycle type *is* the conjugacy class.

Now notice what a cycle type really is. It is a way of writing $n$ as a sum of positive
whole numbers, where order does not matter. For $n = 5$ we have $3 + 2$, but also $5$,
$4+1$, $3+1+1$, $2+2+1$, $2+1+1+1$, and $1+1+1+1+1$. Such an expression is called a
**partition** of $n$. The number of partitions of $n$ is written $p(n)$, and it is one of
the most studied sequences in mathematics, going back to Euler.

Putting the two facts together yields a small miracle:

> **The number of conjugacy classes of $S_n$ — and therefore the number of rows in its
> character table — is exactly $p(n)$, the number of partitions of $n$.**

The character table of $S_n$ is a perfect $p(n) \times p(n)$ square, and its rows are
indexed by the very same partitions that index its columns. Number theory and symmetry
shake hands.

## From "morally true" to "provably true"

This story has been told in textbooks for generations. What is new here is that the
combinatorial core of it has been encoded with complete precision and verified down to
the last logical step, leaving no room for hand-waving or hidden assumptions. The
central construction is an explicit, reversible dictionary — a **bijection** — between
partitions and conjugacy classes:

$$\text{partitionEquivConjClasses} \;:\; \mathrm{Partition}(n)\;\simeq\;\mathrm{ConjClasses}\big(S_n\big).$$

A bijection is the gold standard of counting: it pairs up the two collections so perfectly
that they are forced to have the same size. Building it requires care in both
directions.

**Forward direction (partition → class).** Given a partition such as $3 + 2$ of $5$, we
must manufacture an actual permutation realizing it. We arrange the five objects into
blocks of sizes $3$ and $2$ and spin each block as a cycle. Parts equal to $1$ become
fixed points — objects that stay put. A subtle point handled with care is that cycles of
length $1$ are invisible to the cycle type, so the construction must track the "$1$"s
separately and recombine them. The result is the lemma that the constructed permutation
has **exactly the prescribed cycle type**, and hence exactly the prescribed partition.

**Backward direction (class → partition).** Given a conjugacy class, we pick any
representative permutation, read off its cycle lengths, and record them as a partition of
$n$. The non-trivial part is showing this is *well defined*: if we had picked a different
representative, would we get the same partition? Yes — precisely because conjugate
permutations share a cycle type. This is the formal statement that the cycle-type
invariant descends to the quotient by conjugation.

Showing these two maps undo each other — that going partition → class → partition, or
class → partition → class, returns you to where you started — completes the bijection.
Injectivity flows from "same class implies same cycle type"; surjectivity flows from
"every class has a representative, and we can build its partition."

## The consequence: an exact head-count

Once the dictionary is in place, counting becomes automatic. Because a bijection
preserves size, we obtain the clean identity

$$\big|\mathrm{ConjClasses}(S_n)\big| \;=\; \big|\mathrm{Partition}(n)\big| \;=\; p(n).$$

This is the result recorded as **card_conjClasses_eq_card_partition**: the number of
conjugacy classes of the symmetric group on $n$ symbols equals the number of partitions
of $n$. It is the statement that the character table of $S_n$ is genuinely a
$p(n)\times p(n)$ object — not for one group, but uniformly for all of them.

Specializing to small cases turns the abstract equality into hard numbers. The partitions
are easy to list by hand:

- $n = 3$: the partitions are $3,\; 2+1,\; 1+1+1$ — that is $p(3) = 3$.
- $n = 4$: $4,\; 3+1,\; 2+2,\; 2+1+1,\; 1+1+1+1$ — that is $p(4) = 5$.
- $n = 5$: $5,\; 4+1,\; 3+2,\; 3+1+1,\; 2+2+1,\; 2+1+1+1,\; 1+1+1+1+1$ — that is
  $p(5) = 7$.

These give the three verified facts

$$\big|\mathrm{ConjClasses}(S_3)\big| = 3, \qquad \big|\mathrm{ConjClasses}(S_4)\big| = 5,
\qquad \big|\mathrm{ConjClasses}(S_5)\big| = 7,$$

recorded as **card_conjClasses_S3**, **card_conjClasses_S4**, and
**card_conjClasses_S5**. So the character tables of $S_3$, $S_4$, and $S_5$ are
$3\times 3$, $5\times 5$, and $7\times 7$ squares respectively. The sequence
$1, 2, 3, 5, 7, 11, 15, \dots$ of partition numbers — Euler's old companion — is exactly
the sequence of character-table sizes for the symmetric groups.

## Filling in the rows

Knowing the *shape* of a table is the skeleton; the flesh is the entries themselves. Two
of the rows can always be written down instantly for any $S_n$. The first is the
**trivial character**, which assigns the value $1$ to every single element — the symmetry
that "sees nothing," the constant heartbeat present in every group. The second is the
**sign character**, which assigns $+1$ to even permutations (those built from an even
number of swaps) and $-1$ to odd ones. The sign is the algebraic ghost behind the
determinant you met in linear algebra and behind the rule that a Rubik's-cube position is
solvable only if its permutation is even.

These two rows are genuinely distinct, and a clean orthogonality relation holds between
them: summed across the whole group, the values of the sign character cancel to zero,
$$\sum_{g \in S_n} \mathrm{sign}(g) = 0 \qquad (n \ge 2),$$
which is the statement that exactly half of all shuffles are even and half are odd. This
is the first instance of the great **orthogonality relations**, the hidden grid lines
that make the character table a rigid, almost crystalline object: its rows behave like
mutually perpendicular unit vectors.

## Why any of this matters

It is tempting to file "counting conjugacy classes" under recreational mathematics. It is
anything but. The number $p(n)$ controls:

- **Chemistry and physics.** The irreducible characters of a symmetry group dictate which
  molecular vibrations are infrared-active, which spectral lines appear, and how energy
  levels split in a magnetic field. The size of the table bounds how many independent
  "modes" there can be.
- **Probability and card shuffling.** The eigenvalues of a shuffle — how fast a deck
  randomizes — are governed by the representation theory of $S_n$. The famous result that
  seven riffle shuffles suffice to mix $52$ cards lives in exactly this world.
- **Quantum information and the hidden subgroup problem.** Whether a quantum computer can
  efficiently analyze the symmetric group is one of the central open questions linking
  $S_n$'s representations to cryptography.
- **Pure combinatorics.** The partitions indexing the table are the same partitions that
  appear in the theory of Young tableaux, the RSK correspondence, and symmetric
  functions — a web of identities of startling beauty, including the fact that the squared
  dimensions of the irreducible representations sum to $n!$.

By nailing down the foundational count — the exact dimensions of the playing field — with
machine-checked certainty, we put the keystone in place. Every richer fact about the
character tables of $S_3$, $S_4$, and $S_5$ now rests on a foundation that cannot wobble:
there are exactly $3$, $5$, and $7$ rows, no more and no fewer, and each one corresponds
to a partition of $3$, $4$, or $5$.

## The bigger picture

What makes this episode satisfying is the convergence of three distinct mathematical
worlds at a single point. **Group theory** asks how many shapes of symmetry a permutation
group has. **Number theory** answers with Euler's ancient partition function. And
**representation theory** translates that answer into the dimensions of a character
table — the master fingerprint of the group. Three subjects, developed over three
centuries, agree on one whole number $p(n)$.

That agreement was always believed. Now it is proved, with a precision that admits no
doubt: the symmetric group on $n$ letters has exactly $p(n)$ irreducible characters, its
character table is a perfect $p(n)\times p(n)$ square, and for the first three interesting
cases that square measures $3$, $5$, and $7$ on a side. The shape of symmetry, it turns
out, is the shape of a partition.
