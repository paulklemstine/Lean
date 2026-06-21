# When Sets Pull Together: The Hidden Physics of Union-Closed Families

Imagine a library where every shelf holds a *collection of topics*. One shelf
might carry $\{\text{history}, \text{geography}\}$; another $\{\text{geography},
\text{cooking}\}$. Now impose a single house rule: **whenever two shelves
exist, the shelf combining all their topics must also exist.** Put the two
shelves above together and you are forced to also stock the shelf
$\{\text{history}, \text{geography}, \text{cooking}\}$.

That one rule — *closure under merging* — turns an arbitrary catalogue into
something with surprising internal tension. The collections start to **pull
toward one another**. Popular topics get more popular. Combining two
collections never shrinks the total amount of "stuff" on the shelves. And a
single topic emerges that sits on a huge fraction of all shelves. These are
not vague impressions; they are precise mathematical theorems, and in this
article we will state every one of them and explain why they are true.

The objects in question are called **union-closed families**, and they are one
of the most deceptively simple structures in combinatorics. They are also a
secret doorway into statistical physics: a union-closed family behaves like a
gas of particles whose configurations are biased to clump. We will travel from
counting topics on shelves to *positive correlation*, the same phenomenon that
makes magnets magnetize.

---

## The cast of characters

Fix a finite "universe" of topics, which mathematicians call the **ground
set** $\alpha$. A *configuration* is any subset $s \subseteq \alpha$ — a shelf.
A **family** $F$ is a finite collection of such subsets — our whole catalogue.

The single rule that animates everything is:

> **Union-closed.** A family $F$ is *union-closed* if for every two members
> $s, t \in F$, their union $s \cup t$ is also a member of $F$.

In symbols, $\forall s, t \in F,\; s \cup t \in F$. Merge any two shelves and
you stay inside the catalogue.

We will measure these catalogues with three counters. The first is
**popularity**: for a topic $a$, the *member count* $\mathrm{mc}(a)$ is the
number of shelves that contain $a$,
$$
\mathrm{mc}(a) \;=\; \#\{\, s \in F : a \in s \,\}.
$$
The second is **co-popularity**: for two topics $a, b$, the *joint count*
$\mathrm{jc}(a,b)$ counts shelves carrying *both*,
$$
\mathrm{jc}(a,b) \;=\; \#\{\, s \in F : a \in s \text{ and } b \in s \,\}.
$$
The third is **reach**: the *union count* $\mathrm{uc}(a,b)$ counts shelves
carrying *at least one*,
$$
\mathrm{uc}(a,b) \;=\; \#\{\, s \in F : a \in s \text{ or } b \in s \,\}.
$$

Here is the mental switch that makes the whole subject sing. Pick a shelf
uniformly at random from $F$. Then $\mathrm{mc}(a)/|F|$ is exactly the
**probability** that the chosen shelf contains topic $a$ — its *occupancy*. And
$\mathrm{jc}(a,b)/|F|$ is the probability it contains both — a *two-point
correlation function*, the bread and butter of statistical mechanics. A
union-closed family is a probability distribution on configurations, and the
counts above are its observables.

---

## A bookkeeping miracle

Before any deep structure, there is an identity so clean it feels like
cheating. Add up the popularity of every topic. Separately, add up the size of
every shelf. **You get the same number.**

> **Theorem A (Double counting).**
> $$\sum_{a \in \alpha} \mathrm{mc}(a) \;=\; \sum_{s \in F} |s|.$$

Why? Both sides count the same thing — the number of *(topic, shelf)* incidence
pairs where the topic sits on the shelf — just organized differently. The left
side sweeps topic by topic; the right side sweeps shelf by shelf. It is the
discrete Fubini theorem: you can integrate a table by rows or by columns.

Trivial as it looks, this identity is the engine room. Dividing by $|F|$ turns
it into a statement about averages: *the average occupancy summed over sites
equals the average shelf size.* That is the bridge from "how big are the
shelves" to "how popular are the topics," and it powers the next result.

---

## The emergence of a popular topic

Statistical physics is obsessed with **order parameters**: a single number
whose becoming nonzero signals that a system has spontaneously organized
itself. For union-closed families there is a clean combinatorial avatar.

Suppose the shelves are *big on average* — specifically, suppose the average
shelf occupies at least half of the universe. Then some topic must be **truly
popular**: it sits on at least half of all the shelves.

> **Theorem B (Majority from average).** If $F$ is nonempty and the shelves are
> large on average in the sense that
> $$2 \sum_{s \in F} |s| \;\ge\; |F| \cdot |\alpha|,$$
> then there exists a topic $a \in \alpha$ with
> $$2\,\mathrm{mc}(a) \;\ge\; |F|.$$

The proof is a pigeonhole argument dressed up by Theorem A. Suppose, for
contradiction, that *every* topic were unpopular, $2\,\mathrm{mc}(a) < |F|$ for
all $a$. Sum that strict inequality over all $|\alpha|$ topics: the left side
is $2\sum_a \mathrm{mc}(a)$, which by Theorem A equals $2\sum_{s} |s|$; the
right side is $|\alpha|\cdot|F|$. We would get $2\sum_s |s| < |F|\cdot|\alpha|$,
flatly contradicting the hypothesis. So at least one topic must clear the bar.

This is the discrete fingerprint of **symmetry breaking**: a global average
condition forces a *local* concentration. Notice it does not even need
union-closure — it is a property of any large-on-average family — but it sets
the stage for the central conjecture of the field, which we will meet at the
end.

---

## Upward-closed worlds are automatically merge-closed

Some catalogues obey an even stronger rule. Call $F$ an **upper-set family**
(an *upset*) if it is closed under *growing* shelves: whenever a shelf $s$ is in
$F$ and $t$ is any larger shelf $s \subseteq t$, then $t$ is in $F$ too. In the
library metaphor: if a collection of topics qualifies, so does every
super-collection.

These upsets are the *monotone* worlds — "more is always allowed." It turns out
they are special cases of our merging worlds:

> **Theorem (Bridge: every upset is union-closed).** If $F$ is an upper-set
> family, then $F$ is union-closed.

The reason is immediate once you say it correctly: given $s, t \in F$, the
union $s \cup t$ contains $s$, i.e. $s \subseteq s \cup t$. Since $F$ is
upward-closed and $s \in F$, the bigger set $s \cup t$ must also be in $F$.

This bridge matters because upsets are the natural language of *monotone
events* in probability — events that stay true when you add more particles.
The bridge says every monotone event lives inside the union-closed world, so
theorems about union-closed families automatically apply to them. It is the
hinge connecting order theory (upsets) to algebra (closure under $\cup$).

---

## Two at a time: inclusion–exclusion

How do the three counters relate? The same way probabilities of "or," "and,"
and the individual events always relate — by inclusion–exclusion:

> **Theorem (Inclusion–exclusion).** For any two topics $a, b$,
> $$\mathrm{uc}(a,b) \;=\; \mathrm{mc}(a) + \mathrm{mc}(b) - \mathrm{jc}(a,b).$$

Counting the shelves that contain $a$ or $b$, we count those with $a$, add
those with $b$, and then subtract the ones we counted twice — exactly the
shelves with both. Dividing by $|F|$ gives the familiar law
$P(a \cup b) = P(a) + P(b) - P(a\cap b)$ for the random-shelf distribution.
This is the algebraic skeleton beneath the correlation story: it tells us that
the *two-point function* $\mathrm{jc}(a,b)$ is the genuine measure of how much
the presence of $a$ and the presence of $b$ overlap.

---

## Coarse-graining never destroys mass

Now the physics gets serious. Given any family $F$ — not necessarily
union-closed — there is a smallest union-closed family containing it. We build
it explicitly by taking **all possible merges**: every set you can obtain as
the union of some nonempty sub-collection of $F$.

> **Definition (Union closure).** The *union closure* $\overline{F}$ is the
> family of all sets of the form $\bigcup_{s \in G} s$ where $G$ is a nonempty
> sub-collection $G \subseteq F$.

Two facts pin down that $\overline{F}$ is what we want. First, it *contains the
original*: every shelf $s$ is the merge of the one-element sub-collection
$\{s\}$, so $F \subseteq \overline{F}$ (extensiveness). Second, it *is itself
union-closed*: merging $\bigcup_{s\in G_1} s$ with $\bigcup_{s \in G_2} s$ gives
$\bigcup_{s \in G_1 \cup G_2} s$, again a merge of a sub-collection of $F$. So
$\overline{F}$ is genuinely a closure operator: extensive and idempotent.

Think of closure as **coarse-graining**: you replace a fine description by the
collection of all aggregates it can form. In thermodynamics, coarse-graining is
where entropy comes from — you lose track of microscopic detail and the
effective system gets "bigger." The discrete analog is exactly true here:

> **Theorem C (Monotonicity of total occupancy).**
> $$\sum_{s \in F} |s| \;\le\; \sum_{s \in \overline{F}} |s|.$$

The total amount of "stuff" — summed shelf size, i.e. the total particle number
over all configurations — **cannot decrease** under closure. The proof is a
one-liner given the structure: $F$ is a *subset* of $\overline{F}$ and shelf
sizes are nonnegative, so summing over the larger family can only add more. But
the interpretation is the punchline: closing a system under its own merging
dynamics is an irreversible, mass-non-decreasing process — the combinatorial
shadow of the second law.

---

## The clincher: sets prefer to clump

We have been circling the central theme — **positive correlation** — and now we
land on it. Take the *richest possible* catalogue: the family $2^\alpha$ of
*all* subsets of the universe, the full powerset. Pick a shelf uniformly at
random, which is the same as flipping an independent fair coin for each topic
to decide whether it is on the shelf.

For this maximally symmetric system, the two-point correlation never works
*against* you:

> **Theorem D (Nonnegative correlation — the FKG base case).** On the full
> powerset $2^\alpha$, for any two topics $a, b$,
> $$|2^\alpha| \cdot \mathrm{jc}(a,b) \;\ge\; \mathrm{mc}(a)\cdot\mathrm{mc}(b).$$

Divide through by $|2^\alpha|^2$ and read it as probabilities:
$$
P(a \text{ and } b) \;\ge\; P(a)\cdot P(b).
$$
The presence of one topic *never makes another less likely*. When $a$ and $b$
are different topics this is an equality — independent fair coins, exactly
$P(a)P(b) = \tfrac12\cdot\tfrac12 = \tfrac14$ — and the inequality is saturated.
When $a = b$ it is strict: $P(a \text{ and } a) = P(a) = \tfrac12$ is much
bigger than $P(a)^2 = \tfrac14$, because a topic is perfectly correlated with
itself.

The hidden engine is a beautiful counting fact: the number of subsets of an
$n$-element universe that contain a fixed set of $k$ chosen topics is exactly
$2^{n-k}$ — you fix $k$ coins to "heads" and let the other $n-k$ flip freely.
So $\mathrm{mc}(a) = 2^{n-1}$, and $\mathrm{jc}(a,b) = 2^{n-2}$ for distinct
$a,b$. Then $|2^\alpha|\cdot\mathrm{jc}(a,b) = 2^n \cdot 2^{n-2} = 2^{2n-2}$,
while $\mathrm{mc}(a)\cdot\mathrm{mc}(b) = 2^{n-1}\cdot 2^{n-1} = 2^{2n-2}$ —
equal, on the nose.

This is the **base case of the FKG inequality**, one of the load-bearing pillars
of statistical mechanics. FKG (Fortuin–Kasteleyn–Ginibre) says that in a wide
class of systems, *increasing events are positively correlated*: if turning on
more particles makes two events more likely, then those events conspire to
happen together. It is the mathematics behind why magnetic domains align and why
percolation clusters cohere. Theorem D is the seed crystal — the simplest
nontrivial instance — from which that whole tree grows.

---

## Why these toy theorems are not a toy

String the results together and a worldview appears. A union-closed family is a
*lattice gas*: configurations on a discrete site-set, biased by a closure rule
that favors aggregation. Theorem A is its conservation law. Theorem B is its
order-parameter phenomenon. Theorem C is its arrow of time. Theorem D is its
correlation inequality. The "bridge" theorem says the monotone events — the
physically natural observables — are all inside this world.

And there is a famous open problem lurking. **Frankl's union-closed sets
conjecture** asserts that in *any* finite union-closed family with at least one
nonempty set, some element belongs to at least half the members — exactly the
conclusion of Theorem B, but conjectured to hold *without* the average-size
hypothesis. Theorem B proves it whenever the shelves are large on average;
closing the gap for *all* union-closed families has resisted mathematicians for
four decades. The recent breakthrough showing *some* element is on at least
about $38\%$ of the sets — using, fittingly, an *entropy* argument — only
underscores how deeply this combinatorial puzzle is entangled with information
and physics.

So the next time you tidy a bookshelf and notice that combining two piles never
makes a smaller pile, that your favorite topic seems to be everywhere, and that
once you start merging you can never quite un-merge — you are not imagining
things. You are feeling the same pull that aligns magnets, the gentle but
unbreakable tendency of structured collections to draw together.
