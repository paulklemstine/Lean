# The Logic of a Shuffled Deck

## What a random walk knows about itself

Imagine a token hopping around a small set of rooms. In each room it consults a table of
probabilities and jumps to a neighbouring room. This is a *Markov chain*: the workhorse
of queueing theory, statistical physics, population genetics, PageRank, and card
shuffling. Everything about it is contained in a square matrix $P$ whose entry $P(u,v)$
is the chance of moving from room $u$ to room $v$ in one step, and whose rows sum to one
because the token must go *somewhere*.

Now imagine a completely different subject: modal logic, the study of statements like
"necessarily $\varphi$", written $\Box\varphi$. Since the 1950s the standard semantics
for $\Box$ has been *possible worlds*: a set $W$ of worlds with an accessibility relation
$R$, and the rule

$$\Box\varphi \text{ is true at } w \quad\Longleftrightarrow\quad \varphi \text{ is true at every } v \text{ with } w \mathrel{R} v .$$

Different constraints on $R$ validate different axioms, and the mapping between the two —
which axioms force which shapes of relation — is called *frame definability*. It is the
central technical machinery of the field.

These two worlds look unrelated. One is about numbers between $0$ and $1$; the other is
about truth. This article is about a dictionary that makes them the *same subject*, and
about what the dictionary buys you: a proof that no probabilistic system can obey the
logic of provability; an exact arithmetic criterion for when a random walk mixes; sharp
bounds on how long mixing takes; and a precise identification of what "eventually
recurring" means as a logical fixed point.

## Step one: forget the numbers, keep the zeros

The whole bridge rests on one deliberately crude move. Given the matrix $P$, throw away
the actual probabilities and remember only which of them are nonzero. Define the
**support frame** of $P$: the worlds are the states, and $u$ accesses $v$ exactly when

$$P(u,v) > 0 .$$

That is, "$v$ is accessible from $u$" means "the token *can* go from $u$ to $v$".

This looks like a lossy simplification, and it is — but a remarkable amount survives it.
The first result says that the loss is exactly zero as far as *possibility* is concerned:

> **Support-Power Theorem.** For a matrix with nonnegative entries and any $n \ge 0$,
> the $n$-step probability $P^n(u,v)$ is strictly positive if and only if the support
> frame contains a path of exactly $n$ edges from $u$ to $v$.

The proof is an induction on $n$ using the recursion $P^{n+1}(u,v) = \sum_z P(u,z)P^n(z,v)$
and the elementary fact that a sum of nonnegative reals is positive precisely when one of
its summands is. Positivity of matrix powers *is* $n$-step accessibility. Every
combinatorial statement about the frame is simultaneously a statement about where the
chain can be after $n$ steps, and Chapman–Kolmogorov, $P^{n+m} = P^n P^m$, becomes the
statement that paths concatenate.

## Step two: probability abhors a dead end

The first consequence is a genuine impossibility theorem, and it comes from the most
boring fact about probability distributions: they cannot be identically zero. If the row
of $P$ at $u$ sums to $1$, some entry in it is positive, so *every* state of a chain has a
successor. In modal jargon, the support frame of a stochastic matrix is **serial**.

Seriality is the fingerprint of probability in this dictionary. It is also fatal to a
famous axiom. In the logic of provability — the modal system GL, whose $\Box$ means "is
provable in arithmetic" — the governing principle is **Löb's axiom**

$$\Box(\Box\varphi \to \varphi) \to \Box\varphi ,$$

Gödel's second incompleteness theorem in modal dress. Löb's axiom is valid on exactly
those frames that are transitive and *converse well-founded*: there is no infinite
forward chain $w_0 R w_1 R w_2 R \cdots$. Every path must eventually stop dead.

But a stochastic chain never stops. From every state there is somewhere to go, forever.
So:

> **No nonempty Markov chain is a provability frame.** If $P$ is a stochastic matrix on a
> nonempty finite state space, Löb's axiom is not valid on the support frame of $P$.

The mechanism is a two-line clash of quantifiers: converse well-foundedness would let us
prove a falsehood at every world by well-founded induction, because seriality always
offers another step. Conservation of probability mass and the discipline of Gödelian
provability are simply incompatible. In this sense, the logic of a random walk is the
exact opposite of the logic of a formal theory reasoning about itself.

What a chain does instead is the *other* option. Every transition matrix $P$ manufactures
a proof-system-like object whose "theorems" are the modal formulas valid on its support
frame. Such a system is consistent, and when $P$ is stochastic it proves its own
consistency statement $\neg\Box\bot$ — the very sentence Gödel says a sufficiently strong
theory cannot prove about itself. There is no paradox: the price is that the system is
not Löbian. And it internalises its full soundness schema $\Box\varphi \to \varphi$
exactly when the chain is **lazy**, meaning every state has positive holding probability
$P(w,w) > 0$. Laziness — the modeller's standard trick of letting the token sometimes
stay put — is precisely self-declared soundness.

## Step three: the spectrum of a state is a numerical semigroup

Now zoom in on a single state $w$ and ask a subtler question. For which exponents $n$
does the *reflection principle of degree $n$*,

$$\Box^n\varphi \to \varphi ,$$

hold at $w$ for every formula $\varphi$ and every assignment of truth values? Call the set
of such $n$ the **soundness spectrum** of $w$.

There is a beautifully clean answer, and it is purely combinatorial: degree $n$ holds at
$w$ if and only if $w$ lies on a closed walk of exactly $n$ steps. (One direction is
immediate; the other takes the valuation making the variable false at $w$ and true
everywhere else.) Under the support dictionary, this says the soundness spectrum of a
state is the set

$$\{\,n : P^n(w,w) > 0\,\},$$

the support of its return-time distribution.

And this set has algebra: if you can return in $n$ steps and in $m$ steps, you can return
in $n+m$ steps by doing both. Together with the trivial return of length $0$, the spectrum
is an **additive submonoid of $\mathbb{N}$** — a *numerical semigroup*, the object number
theorists know from the Chicken McNugget problem. For the deterministic $n$-cycle, where
the token marches $0 \to 1 \to \cdots \to n-1 \to 0$, the spectrum is exactly $n\mathbb{N}$:
the modal degree of self-soundness coincides, on the nose, with the probabilistic
*period*.

## Step four: the sharp criterion

Here is the question that organises everything. When is the spectrum **cofinite** — when
does the chain eventually admit a return of *every* sufficiently large length?

If two of the return lengths are coprime, say $a$ and $b$ with $\gcd(a,b)=1$, the classical
Chicken McNugget theorem answers it: every integer greater than $ab - a - b$ is a
nonnegative combination of $a$ and $b$. But that is not the real theorem, because a
numerical semigroup can have overall gcd $1$ while *no two* of its generators are coprime
— the semigroup generated by $6, 10, 15$ is the standard example. The correct criterion
does not mention generators at all:

> **Cofiniteness Criterion.** An additive submonoid $S \subseteq \mathbb{N}$ contains every
> sufficiently large integer if and only if no integer $d \ge 2$ divides all of $S$.

Call the right-hand condition **aperiodicity**. One direction is easy: a cofinite $S$
contains $Nd+1$ for large $N$, which $d$ cannot divide. The other direction is where the
idea lives. Instead of hunting for two coprime elements, form the group of *differences*

$$D = \{\,x - y : x, y \in S\,\} \subseteq \mathbb{Z}.$$

Every subgroup of $\mathbb{Z}$ is cyclic, so $D = d\mathbb{Z}$ for a single $d \ge 0$. Since
$S \subseteq D$, this $d$ divides every element of $S$; aperiodicity rules out $d = 0$ and
$d \ge 2$, leaving $d = 1$. So $1$ is a difference: $S$ contains two **consecutive**
integers $y$ and $y+1$. And two consecutive elements suffice, by an argument you can do on
a napkin. Given $n \ge y^2$, divide: $n = qy + r$ with $0 \le r < y$, and $n \ge y^2$ forces
$q \ge y > r$. Then

$$n = (q - r)\,y + r\,(y+1),$$

a nonnegative combination of $y$ and $y+1$. So everything from $y^2$ on lies in $S$.

Translated back through the dictionary, this is the sharp form of a cornerstone of
Markov-chain theory. A finite chain is **irreducible** if every state can reach every
state, and **primitive** if some power of $P$ has all entries strictly positive — the
condition that makes the Perron–Frobenius theorem deliver convergence to a unique
stationary distribution.

> **Primitivity is Aperiodicity.** For a finite irreducible chain with nonnegative
> entries, the following are equivalent: some power of $P$ is strictly positive in every
> entry; and one — equivalently every — state is aperiodic, meaning no $d \ge 2$ divides
> all of its return lengths.

Textbook treatments usually reach primitivity by assuming a self-loop somewhere, and
laziness is the standard engineering fix for a periodic chain. The criterion shows the
self-loop is a *shortcut, not the theorem*. A self-loop is just the special case
$1 \in S$; two coprime cycle lengths is the special case $\gcd = 1$; and the loopless
$3$-state chain $0 \to 1 \to 0$, $1 \to 2 \to 0$ — which has closed walks of lengths $2$
and $3$ and no holding probability anywhere — is primitive too, invisibly to the
self-loop route. The $n$-cycle for $n \ge 2$ sits on the other side: $n$ divides every
return length, the spectrum is $n\mathbb{N}$, and the chain never mixes.

That aperiodicity at *one* state forces it at *all* states — the classical statement that
periodicity is a class property — falls out as a corollary rather than being assumed.

## Step five: how long is "eventually"?

A cofiniteness statement with an unspecified threshold is unsatisfying; a modeller wants
a number. The bounds come from a shortest-path principle proved by pure pigeonhole:

> **Diameter Principle.** In a frame with $N$ worlds, if $v$ is reachable from $u$ at all,
> it is reachable in fewer than $N$ steps.

Present a path as a function from step indices to worlds; if it is at least $N$ steps long
it visits some world twice, and excising the loop between the two visits leaves a shorter
path. Iterate.

From this, explicit exponents fall out. If every state of an $N$-state irreducible chain
has positive holding probability, then $P^k$ is strictly positive in every entry for
*every* $k \ge N - 1$: reach the target in fewer than $N$ steps, then idle. If only *one*
state holds, route through it — an approach of length $< N$ and an exit of length $< N$ —
and the exponent $2(N-1)$ works.

And the first bound cannot be improved. On the **nearest-neighbour chain** on
$\{0, 1, \dots, N-1\}$, where the token stays put or steps to an adjacent index, one step
changes the index by at most one, so getting from $0$ to $N-1$ genuinely requires $N-1$
steps. Its primitivity exponent is *exactly* $N-1$.

## Step six: what the diamond computes

One last question, and it has a twist. The dual of $\Box$ is the diamond
$\Diamond\varphi = \neg\Box\neg\varphi$, "some accessible world satisfies $\varphi$". A set
$X$ of states is a *post-fixed point* of the diamond when every member of $X$ has a
successor in $X$; the union of all such sets is the **greatest fixed point** of the
diamond, and it is genuinely a fixed point. Intuitively it should be the set of states
from which the walk can go on forever — and on a finite state space, going on forever
means repeating.

The natural guess is that this greatest fixed point is the **recurrent** set: the states
the chain returns to, which is what long-run behaviour is made of. That guess is *false*,
and the counterexample is embarrassingly small. Take two states with the rule "jump to
state $1$ and stay there". State $0$ is transient — the walk leaves and never comes back —
but state $0$ certainly has an infinite forward path, so it belongs to the greatest fixed
point. The correct statement inserts one word:

> **Recurrence Identification.** On a finite frame, the greatest fixed point of the
> diamond is exactly the set of worlds from which some world lying on a cycle is
> reachable.

One inclusion is a post-fixed-point argument; the other is another pigeonhole on the
orbit of a choice of successors. The moral is a genuine limitation of modal expressiveness:
the diamond only ever looks *forward*, so it can see that the walk survives, but it cannot
see whether the walk comes *home*. Distinguishing "reaches recurrence" from "is recurrent"
needs a cyclic operator, not a fixed point of a monotone one.

Combined with seriality, this yields a clean statement about chains: on a finite
stochastic chain, from *every* state one can reach a state with positive return
probability. Not "somewhere there is a recurrent state", but "from everywhere you can get
to one".

## Step seven: aggregation is a morphism

Practitioners routinely shrink a chain by merging states. The merge is legitimate — the
aggregated process is again Markov — when the map $f$ on states is **strongly lumpable**:
the total probability of moving from $u$ into the block $f^{-1}(y)$ depends on $u$ only
through its own block. This is precisely the notion of a **bounded morphism** of frames,
the structure-preserving map of modal logic: a positive transition maps to a positive
transition (one summand bounds the block sum), and conversely a positive block sum must
contain a positive summand. Strikingly, this uses only nonnegativity — row-stochasticity
plays no role at all.

The payoff is immediate. Modal validity transfers along surjective lumpings, so
aggregating a chain can only *add* valid principles; and laziness — self-declared
soundness — is inherited by every lumping. It also yields limitative results with tiny,
computable witnesses. The $2$-cycle has no holding probability; it lumps onto the
one-state chain, which does; and validity transfers. Hence:

> **Non-laziness is not modally definable.** No collection of modal axioms can force a
> chain to have zero holding probabilities.

## Why this is more than an analogy

The pattern behind all of it is that one combinatorial gadget — the existence of an
$n$-edge path — has three simultaneous readings: iterated necessity in the logic,
positivity of a matrix power in linear algebra, and addition of return times in number
theory. Prove something once, and it is three theorems.

Read one way, the results say what probability contributes to logic: seriality, and hence
the impossibility of Gödelian self-reference in any conservative stochastic system. Read
the other way, they say what logic contributes to probability: that mixing is a purely
arithmetic condition on a numerical semigroup; that the standard laziness assumption is
an artefact; that aggregation is a morphism whose limitations are the failures of modal
definability; and that "the walk goes on forever" and "the walk comes home" are separated
by exactly the expressive gap of the diamond.

The token hopping between rooms turns out to have an opinion about its own soundness. The
surprise is that it is always, and provably, an optimist.
