# Saucer Wisdom: Would Aliens Discover the Same Mathematics?

Imagine that, tomorrow, a signal arrives from a distant star. After the
excitement fades, a stubborn question remains: *what would we have in common
with whoever sent it?* Not language, surely — their sounds and symbols are their
own. Not history, not biology, not art. But if the signal contains mathematics,
would we recognize it? Would an alien civilization, an artificial
superintelligence, or a mind evolved in an ocean of liquid methane discover the
*same* theorems we did — or a wholly foreign body of truths we could never
translate?

This is not idle science fiction. It is a precise mathematical question, and it
has precise mathematical answers. Some pieces of mathematics are **universal**:
any sufficiently expressive, self-consistent reasoner is *forced* to accept them.
Other pieces are **contingent**: they depend on choices, and a different mind
could consistently choose otherwise. Telling the two apart is the heart of the
story.

## Sentences, worlds, and what it means to be forced

To make the question sharp, we need a way to talk about "a body of mathematical
belief" without committing to any particular alien notation. Here is the setup,
stripped to its bones.

Fix a collection of **worlds** — the possible structures a theory can describe.
For a geometer, a world is a plane with points and lines; for an algebraist, a
world is a group or a ring; for a number theorist, a world is a model of
arithmetic. A **sentence** is any claim that is either true or false in each
world: "the group is commutative," "there are infinitely many primes," "through a
point not on a line there is exactly one parallel." A **theory** is just a
collection of sentences you have adopted as axioms. A world is a **model** of a
theory when every axiom of the theory holds there, and a theory is
**consistent** when it has at least one model — when it is not secretly
self-contradictory.

Now the key relation. A theory $T$ **entails** a sentence $\varphi$, written
$T \models \varphi$, when $\varphi$ holds in *every* model of $T$. Entailment is
the mathematician's notion of "follows from": if you accept the axioms, you have
no choice but to accept $\varphi$.

With this vocabulary we can finally define the thing we care about. Say that a
sentence $\varphi$ is **universal over $T$** when it is entailed by *every*
consistent extension of $T$ — every larger, still-coherent theory a reasoner
might build on top of $T$. A universal sentence is one no consistent mind can
escape. No matter how the aliens strengthen their axioms, as long as they never
fall into contradiction, they are dragged to $\varphi$.

## Universality is exactly provability

The first surprise is how tidy this notion turns out to be. It threatens to be
exotic — a truth that survives *every possible* strengthening of your theory
sounds like it should be rare and hard to detect. But there is a clean theorem.

> **Universality Theorem.** Over any consistent base theory $T$, a sentence is
> universal over $T$ if and only if $T$ already entails it. In symbols,
> $\varphi$ is universal over $T$ exactly when $T \models \varphi$.

The proof is a small gem of logic. One direction is the workhorse fact that
mathematics never *loses* theorems as you add axioms:

> **Monotonicity.** If $T \subseteq T'$ and $T \models \varphi$, then
> $T' \models \varphi$.

Why? A model of the bigger theory $T'$ satisfies all of $T'$'s axioms, so in
particular it satisfies all of $T$'s axioms; hence it is also a model of $T$, and
therefore $\varphi$ holds there. Every theorem of $T$ automatically becomes a
theorem of any extension. So if $T$ entails $\varphi$, then so does every
extension — universal. The other direction is a one-line trick: a theory is
*itself* one of its own consistent extensions. So if $\varphi$ survives every
consistent extension of $T$, it survives $T$ in particular, meaning
$T \models \varphi$.

This is exactly the sense in which a well-chosen foundation — the arithmetic of
counting numbers, say — is universal. Its theorems form a rock-bottom layer that
*every* consistent extension inherits. Add axioms about sets, about analysis,
about exotic infinities; you can never revoke a theorem of basic arithmetic
without collapsing into contradiction. In this sense the aliens' arithmetic and
ours must overlap: whatever richer superstructure they build, the arithmetic
theorems sit inside it, untouched.

## The parallel postulate: a truth you can refuse

Not everything is universal, and the most famous example is over two thousand
years old. Euclid's fifth postulate — through a point not on a given line there
passes exactly one parallel — resisted every attempt to derive it from the other
axioms. The reason, discovered in the nineteenth century, is that it *cannot* be
derived: there are perfectly consistent geometries in which it fails. On a
sphere there are no parallels at all; in hyperbolic space there are infinitely
many. The parallel postulate is **independent** of the remaining axioms.

Our framework captures independence exactly, and shows precisely why it defeats
universality.

> **Independence Defeats Universality.** If a sentence $\varphi$ has both a model
> and a countermodel over $T$ — a world of $T$ where $\varphi$ holds and a world
> of $T$ where it fails — then neither $\varphi$ nor its negation $\neg\varphi$
> is universal over $T$.

The argument is beautifully symmetric. Take the world where $\varphi$ fails; it
is a consistent extension of $T$ (adjoin $\neg\varphi$ as a new axiom) that does
*not* entail $\varphi$. So $\varphi$ is not universal. By the mirror-image
argument using the world where $\varphi$ holds, $\neg\varphi$ is not universal
either. An independent sentence is one a consistent reasoner may freely affirm
*or* deny.

To see this happen in miniature, forget geometry for a moment and look at groups
— sets with a multiplication. Some groups are **commutative**: $x \cdot y$ always
equals $y \cdot x$. Others are not. The tiny group $\mathbb{Z}/2\mathbb{Z}$ with
two elements is commutative; the group $S_3$ of the six ways to shuffle three
objects is not (shuffling then rotating differs from rotating then shuffling).
Because both kinds of group exist, the sentence "this group is commutative" is
independent of the bare axioms of a group — the algebraic twin of the parallel
postulate. Neither commutativity nor its denial is forced.

And yet — this is the crucial counterpoint — the moment a civilization *adopts*
commutativity as an axiom, it becomes universal *over that stronger theory*.
Every consistent extension of the theory of commutative groups keeps
commutativity, by monotonicity. Universality, then, is never absolute; it is
always relative to what you have already committed to. The aliens might build
their algebra on commutative structures and ours on something wilder, and both
of us would be right. What we could never do is prove the other side wrong from
shared axioms alone.

## The Riemann Hypothesis and the shape of an open question

The deepest unsolved problem in mathematics is the Riemann Hypothesis, a
statement about the fine distribution of the prime numbers. Is it universal — is
every sufficiently rich arithmetic reasoner forced to accept it (or forced to
reject it)? Our framework does not settle this — nobody can — but it tells us
*exactly what the question is asking*.

> **The Decidability Reduction.** Over a consistent theory $T$, the statement
> "$\varphi$ is universal or $\neg\varphi$ is universal" is equivalent to "$T$
> decides $\varphi$" — that is, $T \models \varphi$ or $T \models \neg\varphi$.

This falls right out of the Universality Theorem applied to both $\varphi$ and
its negation. Reading $T$ as arithmetic and $\varphi$ as the Riemann Hypothesis,
the slogan "the Riemann Hypothesis is universal" means *exactly* "arithmetic
settles the Riemann Hypothesis." That is a genuine open problem, which is why
universality here is a real conjecture and not a theorem in disguise. The
framework converts a vague philosophical worry ("would aliens have to agree
about primes?") into a crisp mathematical target ("does arithmetic decide RH?").

## Would aliens discover primes?

Which brings us to the concrete heart of the matter. Forget the fancy
metatheory: would a non-human intelligence discover the *primes* — $2, 3, 5, 7,
11, \dots$, the numbers with no divisors but $1$ and themselves? Are primes a
human quirk, an artifact of our particular obsession with counting, or are they
baked into arithmetic itself?

The answer is that primes are not a convention but a **definitional invariant**
of multiplication. Any intelligence with the notion of "divides" — with the
ability to ask whether one count fits evenly into another — is forced to the very
same primes we found. Three independent characterizations, each using only
structure any counting mind possesses, all pick out identical numbers.

> **Primes from divisibility.** A number $p$ is prime exactly when $p \ge 2$ and
> its only divisors are $1$ and $p$. This uses nothing beyond the relation
> "divides."

> **Primes as indecomposable.** A number $p \ge 2$ is prime exactly when it
> *cannot* be broken into a product $p = a \cdot b$ of two smaller factors, each
> at least $2$. This is what a mind reaches by trying to smash numbers apart.

> **Primes as abstract atoms.** In the counting numbers, "prime" coincides with
> the general algebraic notions of a *prime* element (one that, whenever it
> divides a product, divides one of the factors) and an *irreducible* element
> (one with no nontrivial factorization). These definitions make sense in *any*
> system with a multiplication, so an alien who axiomatizes multiplication in the
> abstract recovers precisely our primes.

Three routes, one destination. Whether the aliens arrive by studying divisors,
by breaking numbers apart, or by pure abstract algebra, they land on the same
set. And they have a canonical *method* for finding a prime, too:

> **The canonical prime finder.** For any number $n \ge 2$, the smallest divisor
> of $n$ greater than $1$ is always prime. Feed in any number, turn the crank,
> out comes a prime.

Finally, two theorems guarantee that primes are not merely definable but
genuinely *fundamental*. First, Euclid's twenty-three-centuries-old jewel:

> **Infinitude of primes.** Beyond every bound there is another prime; the primes
> never run out. No finite mind, however vast, exhausts them.

And second, the theorem that earns primes the name "atoms of arithmetic":

> **The Fundamental Theorem of Arithmetic.** Every positive whole number is a
> product of primes, and — up to reordering the factors — in only one way. The
> multiset of prime factors is an invariant of the number, independent of how you
> found it.

That uniqueness is the punchline. It means the prime factorization of a number
is not a story we tell about it but a fact *about the number itself*. Two
civilizations that never met, using different notations, different base systems,
different everything, would nonetheless agree — down to the last factor — on the
prime decomposition of any given quantity. If the aliens count, they have
multiplication; if they have multiplication, they have divisibility; and if they
have divisibility, they have our primes.

## The saucer's wisdom

So what would we share with the senders of that signal? Not our parallel
postulate — they might live in a curved world and choose a different geometry,
and neither of us could refute the other from common ground. Not necessarily
commutative algebra, nor any of the countless truths that are contingent on which
axioms a mind adopts. Those are the *style* of a mathematics, and style can
differ.

But the arithmetic core is not style; it is structure. The primes, their
infinitude, the uniqueness of factorization — these are forced on anyone who
counts and multiplies, as inescapable as the fact that a theory once proved stays
proved in every consistent enlargement. That is the saucer's wisdom: across any
gulf of biology, history, or physics, a consistent reasoner and we would meet at
the primes. When the message finally comes, the numbers will already be waiting —
the same numbers, on both ends of the line.
