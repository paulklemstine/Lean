# Anti-Mathematics: What Happens When You Break the Rules of Set Theory

## A thought experiment at the foundations

Almost all of modern mathematics rests on a short list of ground rules for how
collections — *sets* — are allowed to behave. These rules are the axioms of set
theory. They are so quietly effective that most mathematicians never think about
them: they say things like "two sets with the same members are the same set," "you
can put any two things together into a pair," and "there exists an infinite set."
From this handful of assumptions, the entire cathedral of numbers, functions,
geometry, and analysis is built.

But here is a mischievous question. What if we did the opposite? What if we took
one of these sacred rules and *negated* it — declared it false — and then honestly
followed the consequences? Would the resulting "anti-mathematics" collapse into
nonsense, or would it describe a coherent, alien world with its own internal logic?

This article is a tour of three such experiments. In each one we do not merely
*assume* the negation of an axiom and hope for the best; we *build a concrete
universe of sets* where the negation is demonstrably true, and where every other
rule we want to keep still holds exactly as before. Building the universe is the
whole point: it proves, beyond any doubt, that the negated theory is consistent —
that it is a real mathematical world, not a contradiction in disguise.

Three axioms, three worlds:

- **Negate Infinity**, and you fall into the world of *finite* sets — a complete,
  self-consistent universe in which nothing infinite can ever be assembled.
- **Negate Extensionality**, and you enter a world of *indistinguishable* sets —
  distinct objects that share every single member, like identical twins that
  refuse to be identified.
- **Negate Foundation**, and you meet sets that *contain themselves* — the famous
  "Quine atom" $\Omega = \{\Omega\}$, a set whose only member is itself, curling
  back on its own tail forever.

Remarkably, all three of these worlds can be constructed out of nothing more
exotic than the ordinary counting numbers $0, 1, 2, 3, \dots$

## The trick that turns numbers into sets

The engine behind everything here is a beautiful piece of bookkeeping discovered
by Wilhelm Ackermann in 1937. It lets a single natural number *be* a finite set.

Write a number in binary. For example,
$$ 13 = 1101_2 = 2^0 + 2^2 + 2^3. $$
Now read off *which positions* carry a $1$. In $13$ the bits at positions $0$, $2$,
and $3$ are on. Ackermann's idea is to declare that these positions are the
*members* of the set coded by $13$. In symbols, we define membership by

$$ a \in b \quad :\Longleftrightarrow \quad \text{the } a\text{-th binary digit of } b \text{ is } 1. $$

So $13$ *is* the set $\{0, 2, 3\}$. And since $0, 2, 3$ are themselves numbers, they
too are sets: $0 = \varnothing$ (its binary expansion is all zeros, so it has no
members), $2 = 10_2 = \{1\}$, $3 = 11_2 = \{0, 1\}$. Peel the onion all the way down
and everything bottoms out at the empty set. Every natural number is, in this
reading, a *hereditarily finite set*: a finite set whose members are finite sets
whose members are finite sets, and so on, terminating after finitely many steps.

This correspondence is not an analogy; it is an exact dictionary. Every finite set
built from the empty set corresponds to exactly one number, and vice versa. The
counting numbers, viewed through Ackermann's lens, *are* the universe of finite
sets.

What makes this dictionary so powerful is that the set operations become clean
operations on binary digits:

- The **empty set** is the number $0$.
- To form $\{a\} \cup b$ — adjoin the element $a$ to a set $b$ — just switch on
  bit $a$: this is the bitwise operation $b \mathbin{|} 2^a$.
- The **union** $a \cup b$ of two sets is the bitwise OR $a \mathbin{|} b$.
- The **subset** relation $x \subseteq a$ becomes the elegant bitmask identity
  $x \mathbin{\&} a = x$ (every $1$-bit of $x$ is also a $1$-bit of $a$).

With this dictionary in hand we can now visit the three anti-worlds.

## World I: A universe with no infinity

The Axiom of Infinity asserts that there exists an *inductive set* — a set $I$
that contains the empty set and is closed under the "successor" operation
$x \mapsto x \cup \{x\}$. This is the axiom that gets mathematics off the ground:
the smallest inductive set is essentially the set of natural numbers, and without
it there is no infinity anywhere.

In the Ackermann universe, we can check that almost all the usual axioms hold. Two
numbers with the same bits are equal, so **Extensionality** holds. The empty set
exists (it is $0$). **Pairing**, **Union**, and **Power Set** all hold, realized by
simple bit manipulations. **Foundation** holds in its strongest form, for a lovely
reason: whenever $a \in b$, the code of $a$ is strictly *smaller* than the code of
$b$. (If bit $a$ of $b$ is switched on, then $b$ is at least $2^a$, which already
exceeds $a$.) Because membership always makes the number go down, and numbers
cannot decrease forever, there are no infinite descending membership chains — and
in particular no set can be a member of itself.

But now watch what happens to Infinity. Suppose, for contradiction, that some
number $I$ *were* inductive: it contains $0$ and is closed under successor. Then it
would have to contain the successor of $0$, and the successor of that, and so on —
the entire tower of *von Neumann numerals*
$$ \varnothing,\ \{\varnothing\},\ \{\varnothing, \{\varnothing\}\},\ \dots $$
Each numeral, once inside $I$, forces the next one in too. But every member of $I$
must have a code *smaller* than $I$ itself. And the $n$-th numeral has a code that
is *at least* $n$. Chain these facts together: the $I$-th numeral is a member of
$I$, so its code is less than $I$; yet its code is at least $I$. That says $I < I$,
which is absurd.

**Anti-Infinity Theorem.** *In the Ackermann universe, no set is inductive.
Consequently the Axiom of Infinity fails, and the universe is a complete,
consistent model of set theory in which every set is hereditarily finite.*

This is a genuinely different mathematics. It is perfectly consistent — it has to
be, because we built it — and yet it can never contain the natural numbers as a
completed whole. It is the mathematics of the strictly, unavoidably finite.

## World II: A universe of indistinguishable twins

The Axiom of Extensionality is the soul of set theory: a set is *nothing but* its
members. If two sets have exactly the same elements, they are literally the same
set. This is why $\{1, 2\}$ and $\{2, 1\}$ are the same object — order and
repetition are invisible.

To negate it, we need two *different* objects with *identical* membership. Take the
Ackermann universe and bolt on one extra object — call it $\star$ — which, like the
number $0$, has no members at all, but which we declare to be a new thing, distinct
from $0$. Formally the universe is $\{\,\star\,\} \cup \{0, 1, 2, \dots\}$, membership
among the numbers is as before, and $\star$ neither belongs to anything nor
contains anything.

Now $0$ and $\star$ are a matched pair: both are empty, so they have exactly the
same members (namely none), yet they are different objects.

**Failure of Extensionality.** *There exist two distinct objects with precisely the
same members.*

It is tempting to think we can repair the damage by simply *identifying* any two
objects that share their members — sweep the duplicates under the rug and recover
ordinary set theory. Call two objects **indistinguishable** if they have the same
members; this is a perfectly nice equivalence relation (reflexive, symmetric,
transitive), and among the *genuine* numbers it collapses nothing: distinct
numbers always differ in some bit, so they always have different members. Only $0$
and $\star$ get glued.

But the repair fails, and the reason is subtle and important. For "identify the
indistinguishables" to make sense, membership itself would have to respect the
identification: if $a$ and $a'$ are indistinguishable, then $a$ should belong to a
set exactly when $a'$ does. It does not. Consider the number $1 = \{0\}$. The empty
Ackermann set $0$ is a member of $1$. Its twin $\star$ is *not* a member of $1$ —
nothing contains $\star$. So we have two indistinguishable objects, one of which
belongs to $1$ and one of which does not.

**Membership is not a congruence.** *There are indistinguishable objects $a \approx
a'$ and a set $b$ with $a \in b$ but $a' \notin b$.*

This is the precise obstruction. In anti-extensional set theory you genuinely
cannot collapse the duplicates away, because membership can *tell them apart from
the outside* even though they are identical *from the inside*. The failure of
Extensionality is not a cosmetic redundancy; it is a permanent feature of the
landscape.

## World III: A universe where a set contains itself

The Axiom of Foundation (also called Regularity) forbids the vicious circles that
give set theory its air of paradox. It guarantees that you can never have $x \in x$,
nor an infinite regress $\cdots \in x_3 \in x_2 \in x_1$. Equivalently, every
nonempty set has a member that is "$\in$-minimal" — a member sharing no elements
with the original set, a place where the descent bottoms out.

To negate Foundation we build the smallest possible monster. Start again with the
Ackermann universe, where Foundation holds and $a \in b$ always forces the code to
strictly decrease. Add a single new object $\Omega$ and decree, brazenly, that its
one and only member is *itself*:
$$ \Omega = \{\Omega\}. $$
This is a **Quine atom**, named for the philosopher W. V. O. Quine. Among the
ordinary numbers, membership still strictly decreases and everything is
well-behaved; the genuine sets never contain themselves, and $\Omega$ stays cleanly
distinguishable from all of them (so this is *not* a stealth failure of
Extensionality). But $\Omega$ itself is a closed loop.

**The self-membership.** *The atom satisfies $\Omega \in \Omega$, and $\Omega$'s only
member is $\Omega$.*

Foundation now shatters in two visible ways. First, in element form: $\Omega$ is a
nonempty set, but it has no $\in$-minimal member. Its only member is $\Omega$, and
$\Omega \in \Omega$, so that member is not disjoint from $\Omega$ — the descent
never bottoms out.

**Regularity fails.** *The nonempty set $\Omega$ has no $\in$-minimal member.*

Second, and most sharply, in terms of well-foundedness. Foundation is exactly the
statement that the membership relation is *well-founded*: there are no infinite
descending chains. But $\Omega \in \Omega \in \Omega \in \cdots$ is such a chain — an
infinite regress that never terminates.

**Anti-Foundation Theorem.** *Membership in this universe is not well-founded: the
self-loop $\Omega \in \Omega$ is an infinite descending chain, so the Axiom of
Foundation fails.*

Far from being a paradox, self-membered sets turn out to be a respectable and
useful part of mathematics. Non-well-founded set theory is the natural home for
circular and self-referential structures: streams that go on forever, processes
that loop, graphs that point back to themselves. Our little atom $\Omega$ is the
seed of that entire theory.

## Why build the worlds at all?

There is a temptation, when you negate an axiom, to just wave your hands: "assume
Infinity is false and see what follows." But assumptions can be secretly
self-contradictory, and reasoning from a contradiction proves everything and
nothing. The discipline here is to *exhibit a model* — an actual, concrete universe
of objects with an actual membership relation — in which the negation is provably
true and the surviving axioms provably hold. A model is an existence proof for a
whole theory. It converts "what if?" into "here it is."

And the punchline is that the raw material never changed. The same humble counting
numbers, read through Ackermann's binary dictionary, gave us the finite universe;
add one empty twin and you get indistinguishability; add one self-looping atom and
you get non-well-foundedness. The rules of mathematics are not laws of nature. They
are choices. Change a choice, follow the logic honestly, and a new and perfectly
coherent world opens up — anti-mathematics, every bit as real as the mathematics we
started with.
