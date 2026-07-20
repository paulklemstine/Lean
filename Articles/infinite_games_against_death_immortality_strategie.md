# Infinite Games Against Death: The Algebra of Immortality Strategies

## How can every life be finite while survival has infinite rank?

Imagine a game with the starkest possible stakes. Mortal chooses how long to postpone defeat; Eternity waits. Mortal is not allowed to choose an actually infinite delay. Every legal choice must be a natural number: seven more rounds, nineteen more rounds, or perhaps a billion. Eternity therefore wins every individual play after finitely many steps.

It seems obvious that Mortal has no claim to immortality. Yet that verdict misses a distinction at the heart of infinite mathematics. Although each play ends, there may be no single finite ceiling on how long the strategy can survive. Give a proposed cap $N$, and Mortal asks for $N+1$ rounds. The collection of possible finite durations climbs without bound through

$$
0,1,2,3,\ldots.
$$

Its least ordinal upper bound is the first infinite ordinal, written $\omega$. Thus Mortal can force survival *up to* $\omega$ in a precise cofinal sense, even though Mortal never completes a play of length $\omega$.

This is not a verbal trick. It is a compact model of a phenomenon that appears whenever finite processes approach a limit: algorithms with arbitrarily long finite running times, trees of unbounded finite depth, clocks approaching a limit stage, and games whose positions have transfinite ranks. The essential lesson is that the height of a family need not be the height of any one member.

## The first immortality strategy

A survival profile assigns an ordinal duration to every finite choice. For the simplest strategy, Mortal chooses a natural number $n$, and the resulting play lasts $n$ rounds. Call the profile $s(n)=n$. We say that a profile **forces survival up to** an ordinal $\alpha$ when

$$
\alpha\leq \sup_{n<\omega}s(n).
$$

The first result is the Finite Postponement Theorem: the canonical profile $s(n)=n$ forces survival up to $\omega$.

The proof is the familiar but powerful fact that the natural numbers are cofinal in $\omega$:

$$
\sup_{n<\omega}n=\omega.
$$

Two companion facts explain exactly what this theorem does and does not say. First, every individual play is finite: for each natural number $n$, one has $n<\omega$. Second, no finite uniform cap exists: for every $N$, choosing $n=N+1$ gives $N<n$. The strategy's infinite rank belongs to the whole menu of finite choices, not to a hidden infinite play.

This distinction resembles a hotel with rooms numbered $0,1,2,\ldots$. Every guest occupies a finite-numbered room, but there is no last room. “No last finite value” is not the same as “one value is infinite.” Ordinal suprema preserve that difference.

## Building an infinity out of blocks

One unbounded counter reaches $\omega$. What happens if Mortal can organize survival into finite blocks, with a finite tail inside the final block?

Let $k$ count completed blocks and let $n$ count additional rounds. Define the two-parameter clock

$$
C(k,n)=\omega k+n,
$$

where both $k$ and $n$ are natural numbers and the arithmetic is ordinal arithmetic. The values begin in layers:

$$
0,1,2,\ldots;
$$

$$
\omega,\omega+1,\omega+2,\ldots;
$$

$$
\omega\cdot2,\omega\cdot2+1,\omega\cdot2+2,\ldots,
$$

and so on. For example, $C(0,5)=5$, $C(1,3)=\omega+3$, and $C(2,0)=\omega\cdot2$.

The order matters. Ordinal arithmetic records sequence rather than mere magnitude. A finite amount placed after an $\omega$-block remains visible, so $\omega+3$ lies beyond $\omega$. By contrast, placing finite stages before a fresh infinite block can absorb them: $3+\omega=\omega$. This noncommutativity makes ordinal clocks suitable for ordered computation.

Fix the block budget $k$ and vary only the finite tail $n$. The Exact Fixed-Budget Theorem says

$$
\sup_{n<\omega}C(k,n)=\omega k+\omega=\omega(k+1).
$$

The finite tails approach the beginning of the next block. None reaches it, but together they are cofinal in it.

Now vary $k$ as well. The Two-Level Clock Theorem states

$$
\sup_{k<\omega}\sup_{n<\omega}(\omega k+n)=\omega^2.
$$

This is the promised leap from $\omega$ to $\omega^2$. Every particular pair $(k,n)$ still lies strictly below $\omega^2$. Even every fixed block budget remains below $\omega^2$, regardless of its finite tail. Yet the complete family has exact supremum $\omega^2$.

## What “bounded nondeterminism” really means

The phrase **bounded nondeterminism** can be misleading unless its quantifiers are handled carefully. Here each individual choice comes with a finite block budget. There is no one global number $B$ imposed on all plays. Mortal may choose any finite $k$, and then any finite $n$. Each branch is locally bounded; the family of all branches is not uniformly bounded.

That difference is decisive. If a single global bound $B$ constrained every block count, then all readings would lie below

$$
\omega B+\omega=\omega(B+1),
$$

which is still strictly less than $\omega^2$. The $\omega^2$ phenomenon therefore comes from allowing arbitrary finite budgets across the family while keeping every individual budget finite.

This is a miniature version of a broad mathematical principle: exchanging “for every object there exists a bound” with “there exists one bound for every object” can change the rank of a system. Local finiteness can coexist with global transfinite height.

## A bridge to games made from numbers

The same clocks appear in an apparently different setting: the birthdays of canonical dyadic surreal games. A game's **birthday** is the earliest stage at which it can be constructed from previously available options. For the canonical game representing the dyadic unit $2^{-n}$, the birthday is

$$
b(2^{-n})=n+1.
$$

Thus these birthdays are all finite, but they are unbounded. The Dyadic Birthday Theorem gives

$$
\sup_{n<\omega}b(2^{-n})=\omega.
$$

This realizes the first survival clock through the construction depth of genuine combinatorial games. As the dyadic numbers become smaller, their descriptions require later and later finite birthdays. Numerical size tends toward zero while structural age tends upward without finite bound.

Weighting those birthdays by $\omega$ produces a nested clock. The Nested Birthday Theorem states

$$
\sup_{k<\omega}\omega\,b(2^{-k})=\omega^2.
$$

Since $b(2^{-k})=k+1$, the displayed family is $\omega,\omega\cdot2,\omega\cdot3,\ldots$, whose supremum is $\omega^2$. The survival game and the birthday spectrum therefore tell the same ordinal story: one finite index yields cofinality in $\omega$, while an $\omega$-weighted finite index yields cofinality in $\omega^2$.

## Clocks for infinite-time computation

Ordinary computers execute only finitely many steps before halting, if they halt at all. Infinite-time models ask what could happen if computation were extended through ordinal stages. At successor stages a machine performs an ordinary transition; at a limit stage such as $\omega$, it applies a prescribed update rule and continues.

The block clock $\omega k+n$ captures the bare chronology of such a process without committing to any particular machine language. The parameter $n$ counts successor steps inside a block. The parameter $k$ counts how many limit-sized blocks have been entered. Letting both range over finite values produces times cofinal in $\omega^2$.

This algebra does not by itself prove that a particular machine realizes those times. An operational model must specify configurations, transitions, limit updates, and halting. But the exact clock supplies a blueprint and a benchmark: a proposed machine should have attainable ranks matching $\omega k+n$, and their total supremum should be $\omega^2$.

The same viewpoint applies to nested loops. A conventional loop with no fixed finite bound has potential duration cofinal in $\omega$. A second level that ranges over finitely many such blocks creates the ordinal pattern $\omega^2$. More levels suggest $\omega^3,\omega^4$, and, at finite depth $d$, the hierarchy $\omega^d$.

## The paradox resolved

Can Mortal live forever? Not on any individual branch of this game. Every concrete finite-delay play ends. Every concrete two-counter reading remains below $\omega^2$. Eternity still wins each isolated encounter.

But if survival is measured by the least ordinal bounding all compatible durations, Mortal can force transfinite ranks. The first strategy has exact rank $\omega$. The two-level strategy has exact rank $\omega^2$. These are not actual infinite play lengths smuggled into a finite game; they are heights of cofinal families.

That resolution is the deepest idea in the story. Infinity can describe the organization of finite possibilities without describing any one possibility. A tree may have unbounded finite branches but no infinite branch. A collection of terminating computations may have no uniform finite runtime. A family of finitely born games may have birthday supremum $\omega$. Add one nested layer, and the rank can rise to $\omega^2$.

Mortal's strategy is therefore an immortality strategy only in the algebraic sense: whatever finite horizon Eternity announces, Mortal can pass it, and whatever fixed finite block budget is proposed, a larger finite budget advances the clock. Death is never defeated on a single play. It is postponed beyond every finite bound—and the architecture of those postponements has an exact transfinite shape.

## Why the algebra matters

The notation is spare, but it prevents three common mistakes. First, a supremum need not be attained: $\sup_{n<\omega}n=\omega$, although no natural number equals $\omega$. Second, two finite choices can create a genuinely new transfinite scale when one controls whole $\omega$-blocks and the other controls successor steps. Third, a bound attached separately to every play is weaker than one bound shared by all plays.

These distinctions matter in termination analysis, where every execution may halt although no finite worst-case runtime exists. They matter in search, where every explored branch may be finite while the search tree has limit rank. They matter in scheduling, where arbitrarily many finite phases can be admitted without admitting an infinite phase as a single task. And they matter in game theory, where the birthday of a position measures recursive construction rather than numerical size.

The resulting hierarchy offers a disciplined vocabulary for “almost forever.” One counter escapes every finite ceiling and approaches $\omega$. A counter of $\omega$-blocks escapes every fixed finite collection of those ceilings and approaches $\omega^2$. The next challenge is to determine how far this architecture can be iterated, and which operational systems, trees, and game families realize each level exactly.
