# The Argument That Nobody Can Refute: Finding the Skeptic's Core of Any Debate

Picture a heated debate. Claims fly across the room, each one attacking
another. "Your first point is wrong," says one voice. "But *your*
objection is itself flawed," replies a second. A third chimes in to
undercut the second. Soon the arguments form a tangled web — not of who
is *right* in some absolute sense, but of who attacks whom.

Now ask a deceptively simple question: **which claims should a perfectly
cautious, skeptical observer accept?** Not the boldest claims, not the
loudest, but exactly those that can be defended against every possible
objection, using only other claims that are themselves beyond reproach.

Remarkably, this question has a clean, definitive answer. There is always
a unique "skeptical core" of a debate — a collection of arguments that is
internally consistent, that defends every one of its members, and that
concedes as little as possible. This core is called the **grounded
extension**, and this article is about a theorem that pins down exactly
what it is: *the grounded extension is the smallest complete position one
can hold.*

## Debates as diagrams

The whole subject rests on a startlingly minimalist idea, introduced by
the computer scientist Phan Minh Dung in 1995. Forget about the *content*
of arguments entirely. Forget whether a claim is about climate policy, a
legal case, or the plot of a film. Keep only two things:

1. a set of **arguments**, and
2. a relation of **attack** between them.

That's it. An argument is just a dot; an attack is just an arrow from one
dot to another, meaning "this argument defeats that one." A whole debate
— an *argumentation framework* — is nothing more than a directed graph.

Write $R\,a\,b$ to mean "argument $a$ attacks argument $b$." Everything we
will say is built from this single relation. The magic is that from such
a bare skeleton, rich and non-obvious structure emerges.

## Three rules for a defensible position

Suppose you want to commit to some set $S$ of arguments — to say "these
are the claims I endorse." When is $S$ a *reasonable* position? Dung
distilled the answer into a few crisp conditions.

**Conflict-freeness.** First, a position should not shoot itself in the
foot. If you endorse two arguments and one attacks the other, you are
holding a contradiction. So we insist that $S$ be *conflict-free*: no
argument in $S$ attacks any argument in $S$. Formally,
$$\text{$S$ is conflict-free} \iff \forall a, b \in S,\ \neg R\,a\,b.$$

**Defense.** Second, a position should be able to stand up to criticism.
Say that $S$ **defends** an argument $a$ if every attacker of $a$ is
itself attacked by something in $S$:
$$\text{$S$ defends $a$} \iff \forall b,\ R\,b\,a \Rightarrow \exists c \in S,\ R\,c\,b.$$
In words: whoever tries to knock down $a$, your position has a
counterargument ready. A set that is conflict-free *and* defends every one
of its own members is called **admissible** — it is coherent and it can
hold its ground.

**Completeness.** Third, a rational thinker should accept everything they
can defend. If your position $S$ already defends an argument $a$ — if you
have a rebuttal to every attack on $a$ — then intellectual honesty demands
that you include $a$. A position that is admissible *and* contains every
argument it defends is called a **complete extension**. These are the
fully self-aware positions: internally consistent, defensible, and with no
"free" arguments left on the table.

## The defense operator

The idea of defense is so central that it deserves a name as a machine.
Given any set $S$, collect *all* the arguments that $S$ defends and call
that new set $F(S)$:
$$F(S) = \{\, a : \text{$S$ defends $a$}\,\}.$$
This is the **characteristic operator**, or **defense operator**, of the
framework. Feeding a position into $F$ tells you everything that position
is capable of protecting.

Two features of $F$ drive the entire theory.

The first is **monotonicity**: a larger position defends at least as much.
If $S \subseteq T$, then $F(S) \subseteq F(T)$. More allies means more
counterarguments available, so nothing you could defend before is lost.

The second is a subtler gem, and it is where consistency and defense
secretly cooperate. **The defense operator turns coherent positions into
coherent positions.** If $S$ is conflict-free, then $F(S)$ is
conflict-free too. Why? Suppose two arguments $a$ and $b$ are both
defended by $S$, yet $a$ attacks $b$. Because $S$ defends $b$ against the
attacker $a$, some $c \in S$ attacks $a$. But $S$ also defends $a$, so
against *that* attacker $c$, some $d \in S$ attacks $c$. Now $c$ and $d$
both live in $S$ and $d$ attacks $c$ — contradicting the conflict-freeness
of $S$. The apparent clash dissolves. This little argument, turning a
would-be conflict into a contradiction two steps down, is the quiet engine
of everything that follows.

## The least fixed point

Complete extensions are exactly the *fixed points* of $F$ that happen to be
conflict-free: positions with $F(S) = S$, meaning "I defend precisely what
I already accept — no more, no less." A debate can have many such fixed
points, corresponding to different coherent worldviews one might adopt.

But there is always a *smallest* one. Start from the empty position,
which commits to nothing. Apply $F$: this hands you exactly the arguments
that *nobody* successfully attacks — the unassailable facts that need no
defense. Apply $F$ again: now you also get the arguments defended by those
facts. Keep going. Each round is at least as large as the last, and the
process climbs toward a limiting position — the **least fixed point** of
$F$. This is the **grounded extension**.

The grounded extension is the ultimate skeptic. It concedes an argument
only when forced to, only when the argument is defended by material already
beyond dispute. It is the common ground that *every* rational participant,
no matter their broader commitments, must accept.

There is one subtlety that makes the mathematics genuinely deep. One might
hope that a few rounds of $F$ — or at worst infinitely many rounds, one
for each counting number — always suffice to reach the grounded extension.
For debates with infinitely many arguments, that is *false*: sometimes you
must iterate *transfinitely*, continuing the process through ordinal
stages far beyond the ordinary integers. The construction still succeeds,
but only if we are willing to build the grounded extension as the limit of
a transfinite chain of approximations.

## The theorem

Here is the payoff, Dung's characterization of grounded semantics, stated
plainly:

> **Theorem.** In every argumentation framework, the grounded extension is
> a complete extension, and it is contained in every other complete
> extension. In short, it is *the least complete extension*.

Two things must be shown, and each has a distinct flavor.

That the grounded extension is contained in every complete extension is
the "soft" half. Any complete extension $S$ satisfies $F(S) \subseteq S$
(it accepts everything it defends), and a fundamental principle about
least fixed points says the least fixed point sits below anything the
operator does not push upward. So the grounded extension slides underneath
every complete position automatically.

The hard half is showing the grounded extension is complete *at all* — and
the crux is that it is **conflict-free**. This is genuinely subtle, and it
is where a tempting shortcut fails. One might guess that *any* fixed point
of the defense operator is conflict-free. It is not. A framework in which
nobody attacks anybody has the set of *all* arguments as a fixed point,
and larger fixed points can positively contain conflicts. Conflict-freeness
is a privilege of the *least* fixed point, not of fixed points in general.

To prove it, we ride the transfinite construction. The starting position
(the empty set) is trivially conflict-free. At each successor stage we
apply $F$, which — by that quiet engine above — preserves
conflict-freeness. At each limit stage we take a union of everything built
so far; because the approximations only ever grow, this union is a
*chain*, and here a second principle kicks in:

> **A union of a growing chain of conflict-free sets is conflict-free.**

Indeed, if a conflict appeared in the union, both offending arguments
would already sit together inside a single set far enough along the chain
— and that set is conflict-free, contradiction. Running conflict-freeness
up through every ordinal stage by transfinite induction, we conclude the
grounded extension itself is conflict-free. Being also a fixed point, it
is admissible, hence complete. The two halves meet: least, and complete.

As a clean corollary, the theory yields a crisp litmus test for *any*
position:

> **A set is a complete extension if and only if it is a conflict-free
> fixed point of the defense operator.**

Coherence plus self-stability is exactly completeness — no more, no less.

## Why this matters beyond the seminar room

This is not an idle formalism. Argumentation frameworks are the backbone
of a thriving area of artificial intelligence concerned with *defeasible*
reasoning — reasoning where conclusions can be retracted in light of new
objections, exactly as they are in law, medicine, ethics, and everyday
life. When an automated system must weigh conflicting evidence, or when
multiple AI agents must negotiate a shared conclusion, the grounded
extension is the standard answer to "what should we all, at minimum,
agree on?"

Its uniqueness is precisely what makes it so useful. Other semantics —
the bolder *preferred* and *stable* extensions — can multiply into several
competing worldviews, forcing a system to choose among them. The grounded
extension never does. It is always there, always singular, always the most
defensible common denominator. It is the argument that nobody can refute,
because it accepts nothing that anybody could.

There is a pleasing philosophical moral here too. We began by throwing
away the meaning of every argument, keeping only the pattern of who
attacks whom. And yet, from that bare graph of conflict, a canonical
notion of *justified belief* emerged, uniquely determined and provably
consistent. Rationality, it turns out, has a shape — and at the very
center of that shape sits the skeptic's core, the least complete position,
the ground on which every reasonable mind must stand.
