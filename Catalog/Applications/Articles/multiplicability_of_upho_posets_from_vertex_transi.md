# When Symmetry Lets You Multiply: The Hidden Algebra of Walks on a Graph

## A puzzle about sameness

Imagine you are standing at a crossroads in a perfectly symmetric city. Every
intersection looks exactly like every other one: the same number of streets leave
each corner, the same pattern of buildings, the same view in every direction. No
matter where the city drops you, you cannot tell *where* you are just by looking
around. Mathematicians call such a city — or rather, the network of its streets —
a **vertex-transitive graph**. The word "transitive" captures the idea that the
graph's symmetries can carry any intersection onto any other.

Now here is a subtler question. Standing at one intersection, you might want to do
more than just *look* around. You might want to *do arithmetic with directions* —
to treat "go north then east" as a single combined move, and to combine moves the
way you multiply numbers. When can the streets of a symmetric city be organized
into a clean multiplication table? When does a graph hide, inside its tangle of
walks, the machinery of an algebraic structure where you can multiply?

This question turns out to have a beautiful and surprisingly sharp answer. The
answer separates two famous graphs that look almost like siblings — the
**Petersen graph** and its **line graph** — into opposite camps. One can multiply.
The other, provably, cannot. And the reason comes down to a single classical idea
from 1958: whether the graph is a **Cayley graph**.

This article tells the story of that dividing line, and of the two mathematical
"pillars" that hold it up.

## Walks, prefixes, and the urge to multiply

Let's get concrete. Fix a starting intersection — call it $v_0$ — and consider all
the *walks* that begin there: the empty walk (stay put), one-step walks, two-step
walks, and so on. We can stack these walks into a tower ordered by *extension*: a
short walk sits below a longer walk whenever the long one begins with the short
one. "Go north" sits below "go north, then east," which sits below "go north, east,
south," and so on.

This tower has a very particular shape. Look upward from any walk in it, and the
view looks identical to the view upward from the very bottom — because the city is
symmetric, the choices available after any walk mirror the choices available at the
start. A partially ordered set ("poset") with this self-similar, upward-homogeneous
structure is called an **upho poset** (short for *upper-homogeneous*). It is
"finitary" when each walk has only finitely many predecessors — only finitely many
shorter walks it could have grown out of.

The central question of this work is whether such an upho poset of walks is
**multiplicable**. Informally: can we put a *multiplication* on the walks so that
the order we already have — "this walk extends that walk" — is recovered *exactly*
by the algebra? The precise notion of "good multiplication" here is what we call an
**LCIF monoid**: a set with an associative multiplication and an identity element
that is

- **L**eft-**C**ancellative ($a\cdot b = a\cdot c$ forces $b = c$),
- **I**dentity-**F**ree of nontrivial units (nothing except the identity has an
  inverse), and
- locally **F**inite (each element factors in only finitely many ways).

Given any monoid, there is a natural way to compare two elements: say that $a$
**left-divides** $b$, written $a \preceq b$, when you can get from $a$ to $b$ by
multiplying on the right — that is, when

$$ a \preceq b \iff \exists\, c,\ b = a \cdot c. $$

A monoid is the right kind of engine for our walks precisely when this
left-divisibility relation reproduces the "extends" order on walks. That is the
definition of multiplicability we work with: **an upho poset is multiplicable when
it is the left-divisibility order of an LCIF monoid.**

## Pillar one: why groups are the *wrong* engine

Your first instinct might be to use the city's symmetries themselves as the
multiplication. After all, symmetries compose: do one, then another, and you get a
third. Symmetries form a **group** — the automorphism group $\mathrm{Aut}(G)$ of
the graph. Why not let the group *be* the algebra of moves?

The answer is a small theorem with a big consequence. In *any* group, left-division
is utterly trivial. Pick any two elements $a$ and $b$; then
$b = a \cdot (a^{-1} b)$, so $a$ left-divides $b$. Every element divides every other
element. The divisibility "order" is not a tower at all — it is a flat plain where
everything is comparable to everything, which is to say it carries no information.

We can pin this down precisely. A genuine ordering has to be **antisymmetric**: if
$a \preceq b$ and $b \preceq a$, then $a$ and $b$ must actually be equal. When does
left-divisibility in a group satisfy this? The answer is a clean dichotomy:

> **The collapse dichotomy.** In a group, left-divisibility is antisymmetric — a
> true partial order — *if and only if the group has only one element.*

So the only group whose divisibility order is a real ordering is the trivial group
with a single element. Any nontrivial group "over-collapses." This is the first
pillar of the story, and it carries a moral: **the symmetry group, by itself,
cannot be the algebra of an upho poset.** Symmetry tells you that all the
intersections are alike; it does not, on its own, give you a way to grade your walks
by length and direction.

## Pillar two: why free monoids are the *right* engine

If groups are too floppy, what is just right? The answer is the structure walks
have *naturally*: the **free monoid** on an alphabet of steps. Here the alphabet is
the set of directions you can move, and an element of the free monoid is simply a
*word* — a finite sequence of steps, i.e. a walk. Multiplication is concatenation:
"north, east" times "south" is "north, east, south." The identity is the empty
word.

In this setting, left-divisibility has an utterly transparent meaning. To say that
the word $a$ left-divides the word $b$ is to say that $b = a \cdot c$ for some word
$c$ — that is, $b$ *starts with* $a$. Left-divisibility **is the prefix relation**.

And the prefix relation is everything we wanted:

- It is a genuine ordering. If $a$ is a prefix of $b$ and $b$ is a prefix of $a$,
  the two words have the same length and must be identical. (Antisymmetry holds.)
- It is **finitary**: the words that are prefixes of a given word $b$ are exactly
  the *initial segments* of $b$, and there are only finitely many of them — one for
  each place you could chop $b$. A walk of length $n$ has exactly $n+1$ ancestors.

So the free monoid of walks is the prototype of a finitary upho poset whose
left-divisibility order is a real, well-behaved tower. This is the second pillar:
**free/walk monoids are exactly the structures whose divisibility order is the
prefix order — a finitary partial order.** The very feature that groups lack —
"nothing has an inverse, so growing a word is irreversible" — is what makes the
order rigid and informative.

Putting the two pillars side by side reveals the engine we need. We want a monoid
that is *cancellative and inverse-free* like a free monoid (so the order is real
and finitary) but that *also* knows about the symmetry of the graph (so it actually
describes walks on $G$). We need to graft a group's symmetry onto a free monoid's
grading.

## The bridge: Sabidussi's 1958 theorem

How does the graph's symmetry get involved at all? Through one of the loveliest
classical results in algebraic graph theory.

A **Cayley graph** is a graph built directly out of a group. Take a group $H$ and a
set $S$ of "generators" (closed under inverses, so the graph is undirected). Make
the vertices the elements of $H$, and join $h$ to $h\cdot s$ for each generator
$s$. The result, $\mathrm{Cay}(H, S)$, is a graph in which the group $H$ acts on
itself by left multiplication, and this action is **regular**: for any two vertices
$u$ and $v$, there is *exactly one* group element sending $u$ to $v$ — no fewer
(the action reaches everywhere) and no more (the action pins nothing down twice).

Sabidussi's theorem says this is the whole story:

> **Sabidussi's theorem (1958).** A graph $G$ is a Cayley graph if and only if its
> automorphism group $\mathrm{Aut}(G)$ contains a subgroup that acts *regularly* on
> the vertices.

In other words, being a Cayley graph is exactly the same as harboring, among your
symmetries, a perfectly balanced "regular" subgroup — one that acts like a group
multiplying itself. The forward direction is easy to feel: if $G$ is a Cayley
graph, left multiplication *is* that regular subgroup of symmetries. The reverse
direction is the clever part: given a regular subgroup of symmetries, you can use
it to relabel the vertices by group elements and reconstruct the graph as a Cayley
graph. Both directions hold, and together they give an exact equivalence.

This is the hinge of the whole program. A regular subgroup of symmetries is
precisely a **group law on the vertices** — a way to multiply intersections. It is
the missing ingredient that, grafted onto the free monoid of walk-steps, promises
to deliver an LCIF monoid whose divisibility order is the walk tower.

## The main conjecture, and a tale of two graphs

We can now state the guiding conjecture of this research in plain language:

> **The multiplicability conjecture.** For a symmetric (vertex-transitive) graph
> $G$ with base intersection $v_0$, the finitary upho poset of walks $P(G, v_0)$ is
> multiplicable *if and only if* $\mathrm{Aut}(G)$ contains a regular subgroup —
> equivalently, by Sabidussi, *if and only if $G$ is a Cayley graph.*

The intuition is the marriage of the two pillars: the regular subgroup (from the
symmetry side) supplies a group law on vertices, and the free monoid (from the
order side) supplies the grading by walk length; fuse them and you get an LCIF
monoid whose left-divisibility order is precisely the walk poset.

The drama of the conjecture is best seen in a pair of near-twins: two graphs on
the same number of vertices, both 3-regular, both drenched in symmetry, that land
on opposite sides of the divide.

**The Petersen graph** is the famous 10-vertex, 3-regular graph beloved as a source
of counterexamples. It is intensely symmetric — its automorphism group is the
symmetric group $S_5$ of order $120$, and it is vertex-transitive, so every vertex
looks alike. And yet the Petersen graph is **not** a Cayley graph: a group acting
regularly on its $10$ vertices would have to have order $10$, and one can check that
$S_5$ contains no subgroup of order $10$ that acts regularly. By Sabidussi, it has
no regular subgroup of symmetries. The conjecture therefore predicts that the upho
poset of walks on the Petersen graph is **not multiplicable**: no matter what
multiplication you try to install, the divisibility order will fail to match the
walk order. Symmetry is abundant, but it is *the wrong kind* — it over-collapses,
exactly as the group dichotomy warns.

**The pentagonal prism** — take a regular pentagon, make a copy of it, and join the
two pentagons rung by rung (this is the graph $C_5 \times K_2$) — tells the
opposite story. It too has $10$ vertices and is $3$-regular and vertex-transitive,
yet it **is** a Cayley graph: it is the Cayley graph of the cyclic group
$\mathbb{Z}_{10}$, and its automorphism group (of order $20$) contains a regular
subgroup of order $10$. So the conjecture predicts that *its* walk poset **is**
multiplicable: there is an honest LCIF monoid whose prefix-style divisibility order
reproduces the tower of walks. Two cubic, vertex-transitive graphs on ten vertices,
one multiplicable and one not — the dividing line is exactly the presence or
absence of a regular subgroup.

**A word about the line graph.** The original framing of this phenomenon offered
the *line graph* of the Petersen graph (whose vertices are the $15$ edges of the
Petersen graph, joined when they share an endpoint) as the Cayley contrast. A
direct computation corrects this: by Whitney's theorem the line graph inherits the
automorphism group $S_5$ of order $120$, and a regular subgroup would need order
$15$; but $S_5$ has no element of order $15$ (its largest element order is $6$) and
hence no subgroup of order $15$. So the Petersen line graph is, in fact, *also*
non-Cayley — a nice reminder that abundant symmetry never guarantees the *regular*
symmetry that multiplicability requires. The pentagonal prism is the faithful
Cayley counterpart.

## What has actually been established

It is worth being precise about what is proved and what remains conjectural,
because the foundations here are solid even though the summit is still a
conjecture.

The **order pillar** is fully established. Left-divisibility is always a preorder.
In a group it collapses, and antisymmetry holds exactly when the group is trivial —
the collapse dichotomy is an honest "if and only if," not a one-way slogan. In a
free monoid, left-divisibility coincides with the prefix relation, that prefix
order is antisymmetric, and it is finitary: each word has only finitely many
prefixes. All of this is nailed down.

The **symmetry pillar** is likewise fully established: Sabidussi's theorem — Cayley
graph if and only if regular subgroup of automorphisms — holds in both directions,
with explicit constructions each way (left multiplication going forward, relabeling
by group elements coming back).

What remains is the **fusion**: building the walk monoid $W(G, v_0)$ explicitly and
proving it is an LCIF monoid whose divisibility order is the walk poset exactly when
the regular subgroup exists. This is the content of the conjecture, and the two
pillars are precisely the load-bearing halves it rests on. The path forward is
clear: combine the group law from the regular subgroup with the grading from the
free monoid, and show the resulting structure threads the LCIF needle.

## Why it matters

Beneath the specifics lies a satisfying general lesson about the relationship
between *symmetry* and *computation*. Symmetry, embodied in a group, tells you that
all positions are interchangeable — but precisely because everything is reversible
in a group, symmetry alone cannot *order* or *grade* anything. Computation, embodied
in a free monoid of irreversible steps, gives you grading and order — but on its own
it knows nothing of the global symmetry of the space it moves through. The two are
complementary, almost dual. A graph supports a clean algebra of walks exactly when
its symmetry is "regular enough" to be turned into a group law on positions, at
which point the irreversible free monoid of steps can ride on top of it.

That dividing line — regular subgroup or not, Cayley or not — is the same line that
separates the Petersen graph from its line graph. It is a reminder that two objects
can be drenched in symmetry and still differ in the deepest structural way: one of
them lets you multiply, and the other, forever, does not.
