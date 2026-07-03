# The Infinite from the Finite: How Sheared Vectors Are Built One Truncation at a Time

## A tower reaching up, a tower reaching in

Some of the most useful objects in mathematics are infinite, but they are only
useful because they are secretly assembled out of finite pieces. A real number is
an infinite decimal, yet we compute with it through its finite truncations. A
power series is an infinite list of coefficients, yet every question we can
actually answer about it is answered at some finite degree. The art is knowing
*which* infinite objects are honestly the limit of their finite shadows — and
which only pretend to be.

This article is about one such object from arithmetic geometry, and about a clean,
surprising answer to exactly this question. The object is a *sheared vector*: an
infinite sequence of coordinates that is allowed to be nonzero only finitely often.
The claim, stated once and for all, is that these sheared vectors are the *colimit*
of their truncations — you can build every one of them by climbing a tower of
finite-length approximations — and that the shearing condition is not a technical
convenience but the exact, minimal price of admission.

To make the statement vivid we need two ideas: what a *Witt vector* is, and what a
*colimit* is.

## Witt vectors, in one paragraph

Fix a prime number $p$. To every commutative ring $A$ one can attach a new ring,
the ring of **Witt vectors** $W(A)$, whose elements are infinite sequences
$$
a = (a_0, a_1, a_2, \dots), \qquad a_i \in A.
$$
What makes $W(A)$ remarkable is *how* these sequences add and multiply: not
coordinate by coordinate, but through a system of universal polynomial formulas
engineered so that the "ghost components"
$$
w_n(a) = a_0^{p^n} + p\,a_1^{p^{n-1}} + \cdots + p^n a_n
$$
behave like ordinary coordinates. Witt vectors are the machine that turns a ring
of characteristic $p$ into a ring of characteristic zero in the most canonical way
possible; over the field with $p$ elements they reconstruct the $p$-adic integers.
They are everywhere in modern number theory.

A **truncated Witt vector** simply stops after finitely many coordinates:
$W_n(A)$ consists of the length-$n$ tuples $(a_0, \dots, a_{n-1})$, and one passes
from length $n+1$ to length $n$ by forgetting the last entry. There is a classical
way to view the full ring $W(A)$ as the *inverse* limit of these truncations —
gluing together compatible finite approximations, the way an infinite decimal is
glued from its digits.

But this article is about the opposite direction.

## Colimits: building up instead of drilling down

An **inverse limit** drills down: it collects all the finite views of an object
and asks for one master object compatible with every view. A **colimit** (or
direct limit) builds up: you have a rising tower of pieces,
$$
X_1 \subseteq X_2 \subseteq X_3 \subseteq \cdots,
$$
each sitting inside the next, and the colimit is simply their union $\bigcup_n X_n$
— everything you can reach by going far enough up the tower. The union of the
intervals $[-n, n]$ is the whole real line; the colimit of the polynomials of
degree $\le n$ is all polynomials. Nothing lives in the colimit that does not
already live at some finite stage.

Here is the tension. The full ring of Witt vectors $W(A)$ is an inverse limit, and
inverse limits are famously *bad* at being colimits: an infinite sequence that is
nonzero in every coordinate cannot possibly come from any single finite stage.
So $W$, as it stands, does not build up from its truncations.

The fix is **shearing**. Restrict attention to the sequences with *finite
essential support* — those that are eventually equal to the basepoint $0$:
$$
\chi W(A) \;=\; \bigl\{\, a = (a_0, a_1, a_2, \dots) \;:\; a_k = 0 \text{ for all
sufficiently large } k \,\bigr\}.
$$
These are the **sheared Witt vectors**. And with this single restriction, the
object snaps into place as an honest colimit.

## The shearing theorem, stated plainly

Here is the mechanism in its purest form, stripped of arithmetic. Take *any* set
$A$ of coordinate values and *any* basepoint $b \in A$. Consider two families of
sequences:

- the **truncated** family at level $n$: all sequences that are equal to $b$ from
  coordinate $n$ onward;
- the **sheared** family: all sequences that are *eventually* equal to $b$.

**Shearing Theorem.** *The sheared family is exactly the rising union of the
truncated families:*
$$
\bigcup_{n \ge 0} \bigl\{\, g : \mathbb{N} \to A \;:\; g(k) = b \text{ for all }
k \ge n \,\bigr\}
\;=\;
\bigl\{\, g : \mathbb{N} \to A \;:\; g(k) = b \text{ for all sufficiently large }
k \,\bigr\}.
$$

The proof is a single honest observation: a sequence lies in the union precisely
when *some* level $n$ works, and "some level works" is the literal definition of
"eventually equal to $b$." Every truncated vector is sheared (its support is
bounded by its length); and every sheared vector, having a finite support, lands
in the truncated family the moment $n$ exceeds that support. Truncated vectors
$W_n(A) \cong A^n$ embed into $A^{\mathbb N}$ by padding with the basepoint, and
their union is $\chi W$. That is the colimit, in isolation.

## Two colimits at once

The real theorem is richer, because in practice the ring $A$ is *itself* a colimit.
Rings in arithmetic geometry are constantly presented as rising unions of smaller
subrings: adjoin one variable, then another, then another; or take a field and pile
on algebraic extensions. Write such a presentation as a monotone, directed family
of subrings
$$
S_1 \subseteq S_2 \subseteq \cdots, \qquad R = \bigcup_i S_i.
$$
Now there are two towers in play at once — the *arithmetic* tower of subrings
$S_i$, and the *arity* tower of truncation levels $n$ — and the question is whether
the sheared vectors over the big ring $R$ can be built by climbing both towers
simultaneously.

**Double Colimit Theorem.** *The sheared Witt coordinate sequences over the colimit
ring $R = \bigcup_i S_i$ — the sequences with finite support whose every coordinate
lies in $R$ — are exactly the double rising union, over truncation level $n$ and
stage $i$, of the truncated coordinate sequences whose every coordinate lies in the
single stage $S_i$:*
$$
\bigcup_{i}\ \bigcup_{n}\ \bigl\{\, g : g(k)=0 \text{ for } k \ge n,\ \text{and }
g(k) \in S_i \text{ for all } k \,\bigr\}
\;=\;
\bigl\{\, g : g \text{ has finite support, and } g(k) \in \textstyle\bigcup_i S_i
\text{ for all } k \,\bigr\}.
$$

This is the mission statement in one equation: the colimit in the *base ring*
variable and the colimit in the *truncation* variable fuse into a single directed
union that computes the sheared object.

The subtle direction is showing that every sheared vector over $R$ descends to a
single stage. A sheared vector has only finitely many nonzero coordinates, say the
first $n$ of them; each of those finitely many coordinates lives in *some* stage
$S_{i_k}$; and because the tower is directed, finitely many stages always have a
common upper bound $M$. All the relevant coordinates then live in the one ring
$S_M$, and the vector is a truncated vector at level $n$ over stage $M$. **The same
"finitely many things have an upper bound" principle powers both towers at once** —
the finite support bounds the arity, the finite list of stages bounds the base
ring, and directedness collapses them into a single stage. That fusion is the
heart of the result.

## Why the shearing is not optional

It is tempting to think finite support is a harmless simplification. It is not —
and there is a clean way to see the failure. Take a field $K$ with more than one
element and the polynomial ring $K[x_0, x_1, x_2, \dots]$ in countably many
variables, presented as the rising union of the subrings $S_i = K[x_0, \dots,
x_{i-1}]$ generated by the first $i$ variables. Now form the *unsheared* vector
whose $k$-th coordinate is the variable $x_k$:
$$
X = (x_0, x_1, x_2, \dots).
$$

**Necessity Theorem.** *Every individual coordinate of $X$ descends to a finite
stage — indeed $x_k \in S_{k+1}$ — yet the whole vector $X$ descends to no stage at
all. Hence, without the finite-support restriction, the colimit identification is
false.*

The reason is arithmetic and absolute: if $X$ came from stage $S_i$, then in
particular the coordinate $x_{i+1}$ would lie in $K[x_0, \dots, x_{i-1}]$ — a
polynomial ring that simply does not contain the variable $x_{i+1}$. Coordinate by
coordinate the vector is perfectly tame; taken all at once it escapes every finite
stage forever. Shearing is precisely the minimal repair that keeps the
infinite-arity Witt functor honest about colimits.

## The tropical echo

The most satisfying part of the story is that none of this is really about Witt
vectors. Strip away the elaborate addition and multiplication and what remains is a
statement about *eventually-basepoint sequences* — and that statement does not care
what the coordinate values mean. Change the basepoint and the same mechanism
reappears in an entirely different world.

Consider the **tropical semiring**, where "addition" is taking the minimum and
"multiplication" is ordinary addition, with the value $+\infty$ playing the role of
zero. Tropical mathematics is the min-plus shadow of ordinary algebra; it turns
polynomials into piecewise-linear functions and geometry into combinatorics. In
this world the natural finitely-supported vectors are the sequences that are
*eventually $+\infty$*.

**Tropical Corollary.** *Over the tropical semiring, the eventually-$\infty$
(finitely-supported) vectors are exactly the colimit of the truncated ones — the
identical shearing mechanism, with the basepoint $0$ replaced by the tropical zero
$+\infty$.*

Witt vectors and tropical vectors, two objects with nothing obvious in common, obey
the *same* colimit law, and they differ only in the choice of basepoint. The
shearing phenomenon is basepoint-agnostic: it is a fact about how finite support
interacts with rising unions, and it is indifferent to whether the coordinates are
$p$-adic ghosts or tropical distances.

## What it means

There is a recurring lesson in mathematics that infinite objects earn their keep
only when they are governed by the finite. Sheared Witt vectors pass that test in
the strongest possible way: not only is every one of them approximated by finite
truncations, every one of them *is* a finite truncation, living at a definite,
findable stage of a definite, findable tower. The unsheared vectors fail the test
just as decisively, and the counterexample — a vector that is finite in every
coordinate but infinite as a whole — shows exactly where the boundary lies.

That boundary, drawn once for Witt vectors, turns out to be drawn everywhere at
once. The same line separates the tame from the wild in the tropical world, and in
any setting where finitely-supported sequences meet a rising union of value sets.
Shearing is the name of the repair; the colimit is the reward; and the fact that
both are indifferent to the meaning of the coordinates is what makes the idea
beautiful.
