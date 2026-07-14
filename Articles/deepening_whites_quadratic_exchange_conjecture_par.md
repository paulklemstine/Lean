# Shuffling Bases: The Quiet Geometry of Exchange

Imagine you run a small delivery company with a fleet of trucks. Every morning
you load each truck with exactly the same number of packages, and by the end of
the day every package in your warehouse has been assigned to some truck. Now
suppose a rival company loaded the very same packages into their own fleet — same
packages, same number per truck, but a different assignment of which package went
where. A natural question: can you transform your loading plan into theirs using
only the simplest possible operation — pick two trucks, pull all their packages
out, and repack those same packages into the two trucks in any legal way?

This homely question is, essentially, one of the most stubborn open problems in
combinatorics. Strip away the trucks and packages and replace them with the
language of *matroids* — the abstract theory of independence that unifies linear
algebra, graph theory, and geometry — and you arrive at **White's Quadratic
Exchange Conjecture**. This article tells the story of that conjecture, and of a
new set of tools that turn a vague hope ("surely you can always rearrange
things") into a precise, compositional machine — and that settle the conjecture
completely for an infinite family of cases.

## What is a basis, really?

In a vector space, a *basis* is a minimal set of vectors that spans everything.
Matroid theory takes the essential combinatorial skeleton of that idea and keeps
only the part that matters: a **matroid** is a finite ground set together with a
family of subsets called *bases*, all of the same size $r$ (the *rank*), obeying
one crucial rule — the **exchange axiom**. If $B$ and $B'$ are bases and $x$ is an
element in $B$ but not in $B'$, then you can always find some $y$ in $B'$ but not
in $B$ so that swapping $x$ for $y$ turns $B$ back into a basis. Bases are, in a
precise sense, all "the same size and interchangeable at the edges."

The cleanest matroid of all is the **uniform matroid** $U_{r,n}$: the ground set
is $\{1, 2, \dots, n\}$, and *every* subset of size exactly $r$ is a basis.
Nothing is forbidden; any $r$ elements form a legal basis. Uniform matroids are
to matroid theory what the sphere is to geometry — the most symmetric object, the
place where every phenomenon shows up in its purest form.

## From single bases to whole configurations

White's conjecture is not about single bases but about *collections* of them. A
**configuration** is a multiset of bases — a list where the same basis may appear
more than once and order does not matter. Think of it as the full loading plan for
the whole fleet, or as a way of writing an element of a certain algebra as a
product of "basis monomials."

Each configuration has a fingerprint: its **multiset union**, the multiset you get
by pooling together every element of every basis, counting multiplicity. If truck
one holds $\{1,2\}$ and truck two holds $\{2,3\}$, the union fingerprint is
$\{1, 2, 2, 3\}$ — the element $2$ appears twice because two trucks carry it.

Two configurations that share the same fingerprint are carrying exactly the same
packages in exactly the same quantities; they differ only in *who holds what*. The
conjecture asks whether that difference can always be undone by simple moves.

## The move, and the question

The only operation allowed is the **quadratic exchange move**:

> Pick two bases $B_1, B_2$ from your configuration. Replace them by two other
> bases $C_1, C_2$ — subject to a single conservation law: the combined elements
> must be preserved, $B_1 \cup B_2 = C_1 \cup C_2$ as multisets.

It is called *quadratic* because it touches two bases at a time (in the algebraic
picture, it corresponds to a relation among products of two variables). No element
is created or destroyed; the packages in those two trucks are simply repacked.

Call one configuration **reachable** from another if you can get from the first to
the second by a finite sequence of these moves. White's Quadratic Exchange
Conjecture, Part 3, is the sharp statement:

> **Conjecture (White, Part 3).** In any matroid, any two configurations with the
> same multiset union are reachable from one another.

Parts of White's original program have since been *disproved* — in particular the
stronger "symmetric exchange" version, which insists each move swap only a single
element at a time, turns out to be false. But Part 3, which permits *any*
legal repacking of two bases, has resisted all attempts. It remains open in
general. What we can do is build the machinery to attack it, and conquer the
cases where the machinery suffices.

## Moves compose: the congruence principle

The first insight is deceptively simple but structurally decisive. A move that is
legal on two trucks is *still legal if there are other trucks parked nearby that
you don't touch.* Reachability is **local**.

Made precise, this says reachability is a **congruence** for combining
configurations. Write $C + E$ for the configuration obtained by placing all the
bases of $E$ alongside those of $C$. Then:

$$\text{if } C \text{ reaches } D, \text{ then } C + E \text{ reaches } D + E.$$

The same holds on the left, and — combining both sides — if $C$ reaches $D$ and
$C'$ reaches $D'$, then the merged configuration $C + C'$ reaches $D + D'$. As a
special case, tacking on one fixed extra basis $B$ to both sides preserves
reachability. These statements are the *compositional backbone*: they let you
solve a big rearrangement by solving pieces independently and gluing the solutions
together. Any inductive proof of White's conjecture — "fix one truck, then
recurse on the rest" — needs exactly this guarantee that the untouched trucks
come along for free.

## The atomic step, isolated

The second tool packages the single move into a reusable theorem. In *any*
ambient configuration, and for *any* matroid basis family, if you have two bases
$B_1, B_2$ and two family members $C_1, C_2$ with the same combined elements, then
swapping the first pair for the second is one legal step — the ambient trucks
$\text{rest}$ ride along untouched:

$$B_1, B_2, \text{rest} \;\longrightarrow\; C_1, C_2, \text{rest}.$$

For uniform matroids this is especially clean. Because *every* $r$-subset is a
basis, there is no legality to check beyond the conservation law: any two
$r$-subsets $C_1, C_2$ whose pooled elements match those of $B_1, B_2$ are
immediately reachable. The uniform world imposes no obstruction; the only thing
that can stop you is arithmetic — you cannot repack packages you do not have.

## Rank one, solved forever

Now the payoff. Consider the simplest uniform matroids, the **rank-one** family
$U_{1,n}$: here every basis is a single element, a singleton $\{a\}$. A
configuration is just a bag of singletons — one package per truck.

At rank one, the fingerprint tells you *everything*. The multiset union of a bag
of singletons is simply the multiset of chosen elements, and you can rebuild the
entire configuration from it by wrapping each element back in its own set. In
symbols, a configuration $C$ satisfies

$$C = \big(\text{union of } C\big)\ \text{with each element } a \mapsto \{a\}.$$

This reconstruction is faithful — different configurations always have different
fingerprints. So two rank-one configurations with the same union are not merely
reachable: **they are literally identical.** There is nothing to rearrange,
because at rank one each truck holds exactly one package and a move cannot change
which truck holds which — it can only exchange singletons that are already equal.

This yields a complete, unconditional theorem:

> **Theorem.** White's Quadratic Exchange Conjecture (Part 3) holds for every
> rank-one uniform matroid $U_{1,n}$.

It is a small kingdom, but it is conquered totally and for all $n$ at once — an
infinite family of matroids for which the conjecture is now settled. A companion
observation, the **single-basis rigidity** principle, makes the same point at the
smallest scale: two one-truck configurations with the same fingerprint are equal,
a direct consequence of the fact that a set is determined by its elements.

## Why rank one is easy and rank two is hard

Reflecting on *why* rank one collapses reveals exactly where the true difficulty
lives. At rank one, a move is powerless to shuffle content: each basis holds a
single element, so the only "repackings" of two singletons $\{a\}, \{b\}$ that
conserve elements are the trivial ones. Nothing can move.

The moment the rank reaches two, bases start to *overlap and share* elements, and
a single move can genuinely redistribute which basis owns which element. That
freedom is the whole point of the conjecture — and its whole difficulty. The
atomic two-basis theorem is precisely the lever a general proof must pull,
over and over, guided by a decreasing measure of "how far apart" two
configurations still are.

## The road ahead

The strategy that these tools make possible is a clean induction on the number of
bases. To turn configuration $C$ into configuration $D$, peel one basis $T$ off of
$D$; use repeated two-basis moves to *extract* a copy of $T$ to the front of $C$;
then, because reachability is a congruence, delete the common $T$ from both sides
and recurse on the smaller configurations that remain. Everything hinges on a
single missing ingredient — an **extraction lemma** guaranteeing you can always
maneuver a desired basis to the front — and the two-basis redistribution theorem
is exactly the atomic step that lemma will iterate. Beyond uniform matroids, the
same template is poised to reach the well-behaved class of *strongly base-orderable*
matroids, where a compatible ordering of bases stands in for the free
redistribution that the uniform case enjoys.

White's conjecture began with a question about writing algebraic expressions in a
canonical form. It has grown into a story about how local, conservation-respecting
moves can — or cannot — reach every configuration sharing a fingerprint. The bag
of singletons is now fully understood. The rest of the fleet awaits.
