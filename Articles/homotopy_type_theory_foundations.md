# The Shape of Sameness: How Homotopy Type Theory Rebuilds Mathematics from Paths

## A new answer to an ancient question

When are two things *the same*? It sounds like a question for philosophers, but it
is secretly the engine of all of mathematics. Two fractions are "the same" if they
reduce to the same lowest terms. Two shapes are "the same" if you can slide and
rotate one onto the other. Two groups are "the same" if there is a dictionary
translating every statement about one into a true statement about the other. Each
field has its own private notion of sameness, and most of a working
mathematician's day is spent quietly deciding which one applies.

In the 2000s a small group of logicians and geometers — among them the Fields
medalist Vladimir Voevodsky — noticed something startling. If you take the logic
that computers use to check proofs and look very closely at how it handles the word
"equals," you find that *equality itself has a shape*. The statement "$a$ equals
$b$" is not a yes-or-no fact. It is a **space** — a space whose points are the
different *reasons* or *ways* in which $a$ and $b$ might be identified. This is the
founding observation of **Homotopy Type Theory** (HoTT), and it dissolves the old
problem of "which sameness?" into a single uniform framework, because every kind of
sameness becomes a path in a space.

This article tells the story of three load-bearing pillars of that framework, all of
which can be stated and proved with complete rigor: the **fundamental theorem of
identity types**, the construction of **higher inductive types** through
propositional truncation, and the fate of the famous **univalence axiom**. Along the
way we will see a surprising twist: in a world where every "reason for equality" is
forced to be identical, two of these pillars become astonishingly simple, while the
third becomes outright impossible — and yet survives, ghost-like, on the realm of
logical propositions.

## Equality as a space

Picture a type — a collection of mathematical objects — as a landscape. The objects
are towns. For any two towns $a$ and $b$, the *identity type* $a = b$ is the set of
**roads** between them. If there are no roads, the towns are genuinely different. If
there is exactly one road, they are the same in exactly one way. If there are many
roads, they are the same in many inequivalent ways — like a doughnut and a coffee
mug, which can be matched up by deformation, but with a choice of *how* to wrap the
handle.

This picture gives mathematics a geometric grammar. A function becomes a map of
landscapes. A proof that two functions agree becomes a continuous deformation
between them. Loops, holes, and higher-dimensional voids — the raw material of the
branch of geometry called *homotopy theory* — appear automatically, with no circles
or spheres ever mentioned. Geometry is not added on top of logic; it is *already
inside* logic.

To talk about this precisely we need three notions.

**Contractibility.** A space is *contractible* if it can be shrunk to a single
point. Formally, a type $A$ is contractible when it has a distinguished element — a
**center** $c$ — together with a guarantee that *every* element of $A$ equals $c$.
Contractible types are the "true singletons" of HoTT: they have exactly one element,
and exactly one reason for it.

**Fibers.** Given a function $f : A \to B$ and a target point $y$, the **fiber** of
$f$ over $y$ collects every input that $f$ sends to $y$, packaged with the evidence:
$$\mathrm{Fiber}(f, y) = \{\, (x, p) : p \text{ is a proof that } f(x) = y \,\}.$$
The fiber is the complete "preimage with receipts."

**Equivalence.** Here is the crucial definition that makes the whole theory hum. A
function $f$ is an **equivalence** — the HoTT word for a perfect, invertible
correspondence — exactly when *every one of its fibers is contractible*. Read that
again: $f$ matches up $A$ and $B$ flawlessly precisely when, for each target $y$,
there is *one and only one* source point mapping to it, with one and only one
reason. This single, elegant condition replaces the usual juggling of inverse maps
and round-trip equations.

## A point that swallows its space

The first concrete result is so clean it feels like sleight of hand. Fix a town $a$
in our landscape and consider the space of **all roads starting at $a$** — formally,
the type of pairs $(y, p)$ where $y$ is any town and $p$ is a road from $a$ to $y$:
$$\sum_{y} (a = y).$$
This is called the *based path space*. The claim is:

> **The based path space is contractible.** ($\texttt{singleton\_isContr}$)

Its center is the pair $(a, \mathrm{refl})$ — town $a$ together with the trivial
"stay put" road. And the theorem says every other pair $(y, p)$ can be continuously
slid back to this center. Intuitively, you just walk backward along $p$, dragging the
endpoint home. No matter how baroque the road network looks, the moment you remember
*where you started*, the whole thing collapses to a point.

This little fact is the seed from which the entire identity-type theory grows.

## The fundamental theorem of identity types

Now we plant that seed. Suppose that over each town $x$ we attach some extra data —
a type $B(x)$, varying from town to town. (Think of $B(x)$ as "the souvenirs
available in town $x$.") Fix a souvenir $b$ available at our home town $a$. There is a
completely canonical way to *carry* that souvenir along any road: if $p$ is a road
from $a$ to $x$, then transporting $b$ along $p$ produces a souvenir in town $x$. This
transport map is written
$$\mathrm{encode}_x : (a = x) \longrightarrow B(x), \qquad p \mapsto p_*(b).$$

When is this transport a *perfect* correspondence at every town simultaneously — an
equivalence for every $x$? The fundamental theorem gives a breathtakingly economical
answer:

> **Fundamental Theorem of Identity Types.** The transport map $\mathrm{encode}_x$ is
> an equivalence for every town $x$ **if and only if** the total collection of all
> souvenirs everywhere, $\sum_x B(x)$, is contractible.
> ($\texttt{fundamental\_identity\_forward}$ and
> $\texttt{fundamental\_identity\_backward}$.)

In words: the souvenir family $B$ behaves *exactly like the identity/road family* if
and only if, globally, there is essentially one souvenir in the entire landscape.
This is the standard tool used throughout HoTT to "characterize the path space" of an
exotic type — to compute, for instance, that the loops on a circle are the integers.
Normally its proof is a substantial exercise in the calculus of fibrations.

Here is the twist that makes this package distinctive. The proofs in our development
are *short* — almost shockingly so. The reason is a deliberate design choice: we use
the proof system's built-in equality, which is **proof-irrelevant**. In that setting
any two roads between the same two towns are themselves identified; the road space is
"flat," a mere yes/no. This is the *set-level shadow* of the full theory. And in that
shadow the fundamental theorem decomposes into two almost trivial observations:

- **Forward direction.** If transport is an equivalence, every fiber is inhabited, so
  every souvenir is reachable from the home souvenir $b$. The total space therefore
  has a center, $(a, b)$, and everything contracts to it.
- **Backward direction.** If the total space is contractible it is, in particular, a
  *subsingleton* — any two of its elements are equal ($\texttt{IsContr.subsingleton}$).
  That forces the needed fiber to be inhabited; and because the fiber is built out of
  two propositions, its contractibility comes for free.

The lesson is not that the theorem is shallow, but that **its difficulty lives
entirely in the higher-dimensional structure**. Flatten the road spaces and the
theorem snaps into place. A small corollary confirms the construction is genuine: for
the "lifted identity family" the transport map is provably a fiberwise equivalence
($\texttt{isEquiv\_encode\_of\_isContr}$), recovering the based path space as a
special case.

## Building new spaces by decree: higher inductive types

Classical mathematics builds sets by listing elements. Homotopy type theory can do
something stranger and more powerful: it can build a space by listing both its
*points* **and** its *paths*. These are **higher inductive types**, and they are how
HoTT constructs circles, spheres, tori, and quotients directly, as first-class
geometric objects.

The simplest non-trivial example is **propositional truncation**, written $\|A\|$.
Start with any type $A$ and *forcibly glue all of its points together*. You declare:

1. every element $a$ of $A$ gives a point $\mathrm{mk}(a)$ of $\|A\|$ (the point
   constructor), and
2. **any two points of $\|A\|$ are equal** (the path constructor).

The result remembers only one bit of information: whether $A$ was inhabited at all.
It converts a potentially rich type — say, "the set of all square roots of 2" — into
the bare proposition "a square root of 2 *exists*," discarding *which* one. This is
exactly the move a working mathematician makes when they say "there exists" and then
refuse to be pinned down to a specific witness.

In our development $\|A\|$ is realized as a quotient by the *total* relation — the
relation that holds between any two elements whatsoever. The defining higher
constructor then becomes a theorem:

> **The truncation is a mere proposition.** Any two elements of $\|A\|$ are equal.
> ($\texttt{Trunc.isProp}$.)

This is the genuinely "higher-inductive" fact: it is *false* for an ordinary quotient
unless the relation is total, and its proof essentially *is* the path constructor in
disguise.

The truncation comes with a **universal property**, the precise sense in which it is
the *best possible* approximation of $A$ by a proposition. Any function from $A$ into a
proposition $P$ factors uniquely through the truncation: there is a lifted map
$\|A\| \to P$ that agrees with the original on points ($\texttt{Trunc.lift\_mk}$),
and a dependent version for proving properties ($\texttt{Trunc.ind}$). Because the
target is a proposition, the awkward coherence conditions that usually accompany
higher inductive types evaporate.

Two consequences show the construction is no mere bookkeeping:

- **Idempotence.** If $A$ was *already* a proposition, then truncating it changes
  nothing: the map $\mathrm{mk} : A \to \|A\|$ is itself an equivalence
  ($\texttt{Trunc.equivOfIsProp}$). Squashing a flat thing leaves it flat.
- **Truncation respects products.** Knowing that a pair exists is the same as knowing
  each component exists:
  $$\|A \times B\| \;\simeq\; \|A\| \times \|B\|.$$
  ($\texttt{Trunc.prod\_equiv}$.) The forward direction is easy; the backward
  direction must take two *separately* truncated witnesses and weave them into a
  single truncated pair, which requires eliminating through the truncation twice. It
  is the first place where the recursor genuinely earns its keep.

## Univalence: the axiom that says "equivalent means equal"

We arrive at the crown jewel and the great controversy of the subject: the
**univalence axiom**. Voevodsky's insight was that the language of types contains a
canonical map turning *identifications of types* into *equivalences between them*:
$$\mathrm{idToEquiv} : (A = B) \longrightarrow (A \simeq B).$$
If you know two types are literally equal, you certainly know they are equivalent —
just transport along the equality. Univalence is the bold assertion that this map is
itself an **equivalence**: that *being equivalent is the same as being equal*. It is
the formal embodiment of every mathematician's instinct that isomorphic structures
are interchangeable, promoted from a convention to a law.

Univalence is extraordinarily productive — but it cannot be bolted onto a system
whose equality is proof-irrelevant, and our development proves exactly why, turning
the impossibility into a theorem.

### The Bool obstruction

Consider the two-element type $\mathrm{Bool} = \{\mathrm{true}, \mathrm{false}\}$. It
has **two** different self-equivalences: the identity, and the swap map $\mathrm{not}$
that exchanges the two elements ($\texttt{negEquiv}$). These are honestly different —
one fixes $\mathrm{true}$, the other moves it.

Now suppose univalence held. Bundle up the data asserting it — the map
$\mathrm{idToEquiv}$ together with an inverse ($\texttt{UnivalenceData}$). Univalence
would convert each of the two self-equivalences of $\mathrm{Bool}$ into a
*self-identification* $\mathrm{Bool} = \mathrm{Bool}$, and it would keep them
distinct, because $\mathrm{idToEquiv}$ is supposed to be invertible. But in a
proof-irrelevant world there is *only one* identification $\mathrm{Bool} =
\mathrm{Bool}$ — all equalities are the same. Two distinct things mapping
invertibly to one thing is a contradiction. Hence:

> **Univalence is inconsistent here.** From the bundled univalence data one derives a
> contradiction. ($\texttt{UnivalenceData.not\_inhabited}$.)

This is not a defect of the result; it is a precise diagnosis. Univalence demands that
equality be *proof-relevant* — that the space of identifications be at least as rich as
the space of equivalences. The two-element type, with its two symmetries, is the
**minimal witness** that this richness is missing.

### The ghost that survives

And yet univalence does not vanish entirely. Restrict attention to **propositions** —
types that are themselves flat, with at most one element. For propositions $P$ and
$Q$, "equivalent" just means "imply each other," and a foundational principle called
*propositional extensionality* already says that mutually implying propositions are
*equal*. On this restricted realm the obstruction disappears, because a proposition
has no nontrivial symmetries. There we can prove:

> **Univalence holds on propositions.** For propositions, identity and equivalence
> genuinely coincide, and the canonical map $\mathrm{idToEquiv}$ realizes the
> correspondence. ($\texttt{propUnivalence}$ and
> $\texttt{propUnivalence\_idToEquiv}$.)

So univalence is not simply true or false in this setting. It is a measurement
instrument. It holds exactly on the flat part of the mathematical universe and breaks
exactly where genuine symmetry begins — and the breaking point is the humble
two-element type.

## Why this matters

Step back from the technical machinery and the larger picture is this. Homotopy type
theory proposes that **logic and geometry are the same subject seen from two angles**.
Equality is a space; functions are maps of spaces; proofs are paths. The fundamental
theorem of identity types is the tool that lets you *compute* with these spaces. Higher
inductive types let you *build* new ones — circles, quotients, truncations — by decree.
And univalence is the principle that finally makes "isomorphic things are equal" a
theorem of the foundations rather than an apology in a footnote.

The experiments recorded here add a sharp empirical contour to that vision. Working
inside a proof-irrelevant system — the *0-truncated shadow* of the univalent universe
— two of the three pillars stand effortlessly, because their content is invariant
under flattening. The third, univalence, collapses globally yet survives on
propositions, pinned in place by the symmetries of a single two-element type. The
boundary between "easy," "impossible," and "ghost" is not arbitrary; it is governed
precisely by *how much higher-dimensional structure each statement secretly needs*.

That is the quiet promise of homotopy type theory: a foundation in which the question
"when are two things the same?" is not answered once and for all by fiat, but is
handed back to mathematics as a *space* to be explored — with its own points, its own
roads, and, every so often, its own surprising holes.
