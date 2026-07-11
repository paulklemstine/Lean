# Infinite Games Against Death: How Long Can You Stay Alive?

Imagine a game with the highest possible stakes. On one side of the board sits **Mortal** — a modest creature with only finite resources, a bounded memory, and a clock that ticks forward one step at a time. On the other side sits **Eternity** — a patient, tireless adversary who can wait not just for a million years, not just forever, but for *transfinitely* long. Eternity's single goal is to see Mortal dead. The only question that matters is: **how long can Mortal survive?**

This sounds like a fable, but it is also a precise mathematical question — and it has a precise, and surprisingly beautiful, answer. Survival is not measured in seconds or in ordinary counting numbers. It is measured in *ordinals*, the numbers mathematicians invented to count past infinity. And the punchline is a clean dichotomy: a purely deterministic Mortal with finite computation can survive exactly $\omega$ rounds — through every finite round, but no further — while a Mortal granted just a *bounded* pinch of nondeterministic choice can survive all the way to $\omega^2$. A little bit of freedom buys an enormous amount of extra life.

## Counting past infinity

To appreciate the game we first need to count past infinity, and to do that we need ordinals.

Start with the familiar counting numbers $0, 1, 2, 3, \dots$. Ordinals begin the same way, but they do not stop. After *all* the finite numbers comes a brand new number, the first infinite ordinal, written $\omega$. It is not a finite number that happens to be very large; it is the first number that comes *after every finite number at once*. Then counting resumes: $\omega, \omega+1, \omega+2, \dots$, and after all of those comes $\omega + \omega = \omega \cdot 2$, then $\omega \cdot 3$, and so on. After every multiple of $\omega$ comes $\omega \cdot \omega = \omega^2$, and the tower keeps climbing.

The crucial feature of ordinals — the property that makes them the right yardstick for a survival game — is that they are **well-ordered**. This means: no matter which collection of ordinals you pick, there is always a *smallest* one in the collection. There are no infinite descending staircases. You can climb ordinals forever, but you can never fall down them forever. Time, in the ordinal world, has a firm floor and only moves up.

Every well-ordered set has an **order type**: the unique ordinal that measures "how long" it is. A finite set of five things has order type $5$. The natural numbers $0,1,2,\dots$ in their usual order have order type $\omega$. Take two copies of the natural numbers, one entirely after the other, and you get order type $\omega \cdot 2$. Order type is the exchange rate that converts a concrete ordered structure into a single ordinal number.

## The rules of the survival game

Now we can state the game exactly. Mortal's computational power is captured by a single ingredient: the set of **moments of being alive** it can possibly reach. Think of a moment as an internal snapshot — a configuration of Mortal's memory and clock that certifies "I am still here." These moments come with a notion of *before* and *after*, and — this is the key constraint imposed by the well-ordering of time — they form a well-ordered set. Call this set $M$.

The game proceeds over rounds indexed by ordinals: round $0$, round $1$, and onward through the transfinite. There is one iron law:

> **At each round Mortal survives, it must exhibit a moment strictly later than the one it showed in every previous round.**

You cannot stall. You cannot reuse a moment. Time only moves forward, so to survive round after round, Mortal must produce an ever-ascending sequence of moments — a fresh, strictly larger snapshot for each round that passes. Eventually the well-ordered set $M$ runs out of room above, and at that round Mortal has no legal move left. That is the round of death.

We can make "how long can Mortal last" completely precise. Define the **survival value** of a game to be the order type of Mortal's set of reachable moments:
$$\mathrm{value}(G) = \text{order type of } M.$$
This single ordinal is the least round Mortal cannot reach — the exact moment death becomes unavoidable.

A **play of length $\beta$** is a schedule that survives the first $\beta$ rounds: an assignment of a distinct, strictly increasing moment to each round below $\beta$. In the language of order theory, it is an *order embedding* of the rounds below $\beta$ into $M$ — a way to fit $\beta$ many increasing steps inside the moment set without collision. We say **Mortal forces round $\beta$** if such a play exists.

## The fundamental theorem

Everything about the game collapses into one clean statement:

> **Fundamental Theorem.** Mortal can force survival to round $\beta$ if and only if $\beta \le \mathrm{value}(G)$.

The reasoning is exactly the reasoning behind order types. If Mortal has a play of length $\beta$, that play embeds $\beta$ increasing steps into $M$, so $\beta$ cannot be longer than $M$'s order type: $\beta \le \mathrm{value}(G)$. Conversely, if $\beta \le \mathrm{value}(G)$, then the rounds below $\beta$ form an initial segment short enough to fit inside $M$, and that fit *is* a winning schedule. Survival is therefore completely determined by a single number, and it is automatically **downward closed**: if you can reach round $\beta$, you can reach every earlier round too. Death has a sharp, well-defined address, and everything before it is survivable.

This reduces the whole drama of the game to a single computation: *find the survival value.* The rest of the story is about what different amounts of computational power buy you.

## The $\omega$ barrier: finite Mortal lives exactly $\omega$ rounds

Consider the most austere Mortal of all: a **finite deterministic** machine. It has a bounded memory and a clock that advances one tick per round, with no choices to make. Its reachable moments are naturally indexed by the ordinary counting numbers $0, 1, 2, \dots$ — one clock reading per round — so its moment set has order type $\omega$.

By the Fundamental Theorem, this Mortal's fate is sealed and computed at once:
- It **survives every finite round.** For any finite number $n$, since $n < \omega$, Mortal forces round $n$. There is no finite deadline it fails to beat.
- It **forces round $\omega$ itself.** Since $\omega \le \omega$, Mortal survives all the way through the first transfinite milestone — it lives past every finite round, together.
- It **dies exactly at $\omega$.** Since $\omega < \omega + 1$, Mortal cannot force round $\omega + 1$. The value $\omega$ is *sharp*: not one round more.

So finite deterministic computation buys you precisely $\omega$ rounds of life. You outlast every finite opponent, but you cannot take a single step beyond the first infinity.

This barrier is not an accident of one particular machine; it is a law about finite computation. **Any** Mortal whose moments can be arranged into the counting numbers — order-preservingly embedded into $0, 1, 2, \dots$ — has survival value at most $\omega$, and therefore cannot force round $\omega + 1$. Embedding into the natural numbers is the mathematical fingerprint of finite deterministic behavior, and it caps survival at $\omega$ no matter how cleverly the machine is built. To break the $\omega$ barrier, Mortal needs genuinely more than finite computation.

## The $\omega^2$ barrier: a pinch of choice buys a second dimension

Now give Mortal a modest new power: **bounded nondeterminism.** At certain critical moments Mortal is allowed to *branch* — to make a bounded choice that lets it, in effect, reset its counter and begin a fresh block of finite time. It is not omnipotent; the branching is bounded. But this small freedom changes the geometry of its life entirely.

The reachable moments now carry two coordinates instead of one. A *major* coordinate counts how many fresh blocks — how many limit stages — Mortal has survived, and a *minor* coordinate counts the ticks within the current block. These pairs are compared **lexicographically**: first by the major coordinate, and only then, as a tiebreaker, by the minor one. A moment with a higher block number is always later, no matter the tick counts within.

The order type of this two-coordinate structure is $\omega \cdot \omega = \omega^2$. Each block contributes $\omega$ ticks, and there are $\omega$ blocks stacked one after another. So by the Fundamental Theorem:
- Mortal **survives every round $\omega \cdot n$**: after finishing $n$ full blocks it is still alive, for every finite $n$.
- Mortal **forces round $\omega^2$**: it survives through all the blocks together.
- Mortal **dies exactly at $\omega^2$**: it cannot force round $\omega^2 + 1$. Again the value is sharp.

Compare the two Mortals. The finite one lives $\omega$ rounds; the nondeterministic one lives $\omega^2$ rounds. Since $\omega < \omega^2$, **nondeterminism strictly extends life** — and not by a little. A bounded amount of choice, applied at the right moments, lifts survival from the first infinity to its square.

## Why choice multiplies life: the refinement principle

Behind the leap from $\omega$ to $\omega^2$ lies a single, reusable mechanism, and it is the most elegant part of the story. Take any survival game and perform a **refinement**: replace each of Mortal's moments by an entire $\omega$-block of sub-moments, ordered so that the original moment is the major coordinate and the new fine structure is the minor one. Intuitively, you are subdividing each instant of the old life into infinitely many finer instants.

> **Refinement Principle.** Refining a game multiplies its survival value by $\omega$:
> $$\mathrm{value}(\text{refined } G) = \omega \cdot \mathrm{value}(G).$$

The $\omega$-to-$\omega^2$ jump is now just one turn of this crank. Start with the finite game, whose value is $\omega$. Refine it once — which is exactly what bounded nondeterminism does, subdividing each block into $\omega$ ticks — and the value becomes $\omega \cdot \omega = \omega^2$. The refinement principle says nothing special happens at $\omega$; the same mechanism will keep climbing. Refine again and reach $\omega^3$; keep going and, in the limit, you approach $\omega^\omega$ and beyond. Each new layer of bounded structure multiplies survival by another factor of infinity.

## Machines that compute in transfinite time

This is not merely a parable. It is a faithful, stripped-down model of a genuine object in the theory of computation: the **Infinite Time Turing Machine**. An ordinary Turing machine runs for finitely many steps. An infinite time machine keeps running through *ordinal* time — and at each limit stage, when infinitely many earlier steps have already elapsed, it takes a limit of its earlier tape contents and continues. Such machines can decide problems no ordinary computer can touch.

The survival game captures exactly how far such a machine can *clock* before its first reckoning. A deterministic infinite time machine with a finite alphabet that must eventually halt traces out clock readings order-isomorphic to $\omega$ before its first limit intervention — that is the finite game. Grant it a bounded amount of nondeterministic branching, so it can reset a bounded counter across limit stages and stack $\omega$-blocks, and its clock readings climb to $\omega^2$ — that is the nondeterministic game. The ordinals $\omega$ and $\omega^2$ are not arbitrary; they are the first two *clockable* milestones a machine meets as it learns to compute in transfinite time, and the sharpness results pin each of them down to the exact round.

## The moral

Strip away the mythology and a crisp principle remains. Survival against an eternal adversary is governed by a single ordinal, the survival value, and that value is set entirely by the shape of what you can reach. Finite deterministic power reaches $\omega$ — every finite deadline, and not one step beyond. A bounded dose of choice reaches $\omega^2$ — a whole new dimension of time. And a single principle, refinement, explains why: every added layer of bounded structure multiplies your lifespan by infinity.

Mortal can never truly become immortal — Eternity always wins in the end, because every well-ordered set eventually runs out of room above. But the *shape* of Mortal's mortality is exquisitely sensitive to its computational power. In the infinite game against death, the difference between $\omega$ and $\omega^2$ is the difference between counting and choosing — and it is measured not in years, but in infinities.
