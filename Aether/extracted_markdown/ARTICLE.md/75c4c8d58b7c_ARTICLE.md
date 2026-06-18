# When a Neural Network Becomes a Geometric Point

## A bridge between how machines see and how proofs add up

There is a quiet kind of magic that happens whenever two very different
mathematical worlds turn out to be describing the same thing. It is the magic
of discovering that the distance between two melodies and the difference between
two prime numbers obey the same law, or that the way heat spreads through a
metal bar is the same equation that prices a financial option. This article is
about one such bridge — a newly built one — connecting two worlds that, at first
glance, could not look more different.

On one side stands the world of **neural networks**: layered machines that
shuffle hidden numbers around and, at the end, emit an observable answer. On the
other side stands the world of **algebraic geometry of proofs**: an abstract
landscape where logical systems are treated like geometric spaces, with "points"
that play the role of prime numbers. The surprising claim, made precise and
checked line by line, is this:

> *When a neural observation system is algebraic in the right way, the question
> "are these two internal states secretly the same?" is literally a point in the
> geometry of proofs — and a notion of distance you can compute by watching the
> network agrees, exactly, with that algebraic structure.*

Let us unpack what that means, and why it is beautiful.

---

## Part 1: The network as a black box you can only probe

Imagine a sealed machine with a hidden internal state. You cannot open it. All
you can do is feed it a sequence of input symbols — call them a *word* — and read
off a single number when you stop. Push the buttons `a, b, a`, read a number.
Push `b, b`, read another. The machine is deterministic: each button press
transforms the hidden state by a fixed rule, and at any moment a fixed *read-out*
rule converts the hidden state into the visible number.

This is the essence of what we call a **neural observation system**. It is a
stripped-down model of what a recurrent neural network does: hidden activations
evolve as inputs arrive, and a final layer reads out a prediction. Formally we
have two ingredients:

- a **step** function, `step : state → symbol → state`, the one-layer dynamics;
- an **observe** function, `observe : state → output`, the read-out.

The **behavior** of a hidden state `x` under a word `w` is what you get by
running the word through the machine and then reading out:

> `behavior(x, w) = observe(w folded through step starting at x)`.

Now here is the natural question, and it is the *only* question an outsider can
ever ask: **when are two hidden states indistinguishable?** Two states `x` and
`y` are *behaviorally equivalent* when **no word can tell them apart** — for every
possible probing sequence `w`, the output is the same:

> `x ≈ y` exactly when `behavior(x, w) = behavior(y, w)` for all words `w`.

This is an old and deep idea wearing new clothes. In automata theory it is the
**Myhill–Nerode equivalence**; in the theory of state machines it is
**bisimulation**; in cryptography it is **indistinguishability** — two secrets
are "the same" if no efficient observer can separate them. Quotienting a network
by this equivalence yields its smallest faithful version: a certified
compression that keeps every observable answer intact while throwing away the
redundant internal bookkeeping.

So far, so classical. The equivalence `≈` is, unsurprisingly, an *equivalence
relation*: reflexive, symmetric, transitive. But that is all it seems to be — a
way of sorting states into buckets. The first act of our story is to show it is
secretly much more.

---

## Part 2: Making the network algebraic

Here is the twist that opens the door. Suppose the hidden states are not just an
amorphous set, but live in an algebraic structure called a **semiring** — a place
where you can *add* and *multiply* (think of the natural numbers, or the
non-negative reals, or the "tropical" world where addition is `max` and
multiplication is `+`). Suppose, too, that the network's machinery respects this
structure: each layer and the read-out **preserve addition and multiplication and
send zero to zero**. We call such a machine an **algebraic neural observation
system**.

Concretely, an algebraic neural system asks for six gentle laws:

1. `step(0, a) = 0` — a dead state stays dead;
2. `step(x + y, a) = step(x, a) + step(y, a)` — layers are additive;
3. `step(x · y, a) = step(x, a) · step(y, a)` — layers are multiplicative;
4. `observe(0) = 0` — nothing reads as zero;
5. `observe(x + y) = observe(x) + observe(y)` — read-out is additive;
6. `observe(x · y) = observe(x) · observe(y)` — read-out is multiplicative.

Notice what is **not** required: we never demand `step(1, a) = 1` or that the
multiplicative unit be preserved. This is a deliberate, minimal choice.
Behavioral equivalence only ever inspects sums and products of states, never the
bare multiplicative unit of the state space, so insisting on preserving `1` would
be an *unused* hypothesis — and in general a false one. A good bridge carries
exactly the weight it must and not an ounce more.

From these six laws, a small cascade of consequences follows. Running a whole
word through the layers also preserves the algebra: feeding `0` through any word
gives `0`; feeding `x + y` gives the sum of feeding `x` and feeding `y`; feeding
`x · y` gives the product. And since the read-out preserves the algebra too, the
**behavior map itself becomes a homomorphism in its state argument**:

> `behavior(0, w) = 0`,
> `behavior(x + y, w) = behavior(x, w) + behavior(y, w)`,
> `behavior(x · y, w) = behavior(x, w) · behavior(y, w)`.

This is the engine of everything that follows. The way the network *responds* to
probing now carries the full additive and multiplicative skeleton of the states
it is probing.

---

## Part 3: From a bucket-sort to a congruence

Recall the equivalence `x ≈ y` ("no word tells them apart"). With the algebraic
laws in hand, something lovely happens. Suppose `x ≈ y` and `u ≈ v`. Then for
every word `w`,

> `behavior(x + u, w) = behavior(x, w) + behavior(u, w) = behavior(y, w) + behavior(v, w) = behavior(y + v, w)`,

so `x + u ≈ y + v`. The identical argument with products shows `x · u ≈ y · v`.
In words: **behavioral equivalence respects addition and multiplication**. An
equivalence relation that respects the algebraic operations has a special name in
universal algebra — it is a **congruence**. (It is exactly the kind of relation
you quotient by to build a new algebraic structure, the way you build modular
arithmetic by declaring numbers equivalent when they differ by a multiple of
twelve.)

So the humble "are these states the same?" relation is upgraded, for free, into a
**semiring congruence**. We package it as an object called `behaviorCongruence`.
And this is the moment the bridge touches its far shore — because semiring
congruences are precisely the inhabitants of the second world.

---

## Part 4: The geometry of proofs

In the parallel world, mathematicians have been building an **algebraic geometry
of proof systems**. The dictionary runs like this. Classical algebraic geometry
studies rings through their **ideals**, and the deepest points are the **prime
ideals**, organized into a space called the *spectrum* with its Zariski topology.
Proof-theoretic algebraic geometry plays the same game one level over: a logical
or computational system forms a semiring (disjunction behaves like addition,
conjunction like multiplication), and the role of ideals is played by
**congruences**. The "geometric points" are the **prime congruences**, gathered
into a **proof spectrum**.

A congruence `C` has a **zero-class**: the set of elements equivalent to zero,
the things that "vanish." For a prime congruence, that vanishing set behaves like
a prime ideal — if a product vanishes, one of the factors must. These zero-classes
are the *vanishing loci*, the provability regions of the proof world. There is
even a Galois connection linking sets of equations to the points where they hold,
mirroring the correspondence between algebraic sets and the ideals that cut them
out.

Our `behaviorCongruence` lands squarely inside this world. Its zero-class is
exactly the set of **behaviorally-null states** — the states `x` for which
`behavior(x, w) = 0` for *every* word `w`, the internal configurations the
network can never make visibly nonzero. What looked like a piece of machine-
learning bookkeeping turns out to be a *point datum in the geometry of proofs*.

---

## Part 5: Distance you can watch

The third strand of the story is **geometry** in its most intuitive form:
distance. We define an **observation pseudometric** `obsDist` on the states. Two
states are at distance `0` if no word separates them, and at distance `1` if some
word does:

> `obsDist(x, y) = 0` if `x ≈ y`, and `obsDist(x, y) = 1` otherwise.

A *pseudometric* is a notion of distance that is allowed to assign distance zero
to distinct points (which is exactly what we want — distinct internal states can
be behaviorally identical). It must satisfy four laws, and `obsDist` satisfies
all of them: it is **non-negative**, every state is at distance zero from itself,
it is **symmetric** (`obsDist(x, y) = obsDist(y, x)`), and it obeys the
**triangle inequality** (`obsDist(x, z) ≤ obsDist(x, y) + obsDist(y, z)`).

Now we reach the keystone. We have three a-priori-different ways of saying "these
two states are the same":

1. the **algebraic** one — the semiring congruence `behaviorCongruence`;
2. the **metric** one — the kernel `{ (x, y) : obsDist(x, y) = 0 }`;
3. the **coalgebraic** one — the original Myhill–Nerode equivalence.

The punchline theorem, `pseudometric_kernel_eq_congruence`, says they coincide:

> **The set of state-pairs at distance zero is exactly the semiring congruence.**

The analytic quotient (collapse everything at distance zero) and the algebraic
quotient (quotient by the congruence) are the *same* quotient. The loop closes:

> neural observation pseudometric → congruence kernel → proof-spectrum congruence.

---

## Part 6: A filtration, and why it is computable

There is a bonus that makes all of this concrete rather than merely elegant. You
do not have to probe with *infinitely* many words to detect equivalence; you can
do it depth by depth. Define `≈ₖ` ("equivalent up to depth `k`") to mean the two
states agree on every word of length at most `k`. Each `≈ₖ` is checkable with a
finite budget — roughly `|alphabet|ᵏ` probes — and the depths form a *refinement
filtration*: agreeing to depth `k+1` implies agreeing to depth `k`. The true
behavioral equivalence is exactly the **intersection of all the depths**:

> `x ≈ y` if and only if `x ≈ₖ y` for every `k`.

This is the engine behind **partition refinement**, the classical algorithm for
minimizing automata, and it gives a practical recipe: keep splitting states by
deeper and deeper observations until the partition stops changing. When it
stabilizes, you have computed the congruence — and, by the bridge, a point in the
proof spectrum and the kernel of the observation pseudometric, all at once.

---

## Part 7: The bridge is a functor

A relationship between two mathematical worlds is most powerful when it respects
*maps*, not just objects. Suppose you have a semantics-preserving transformation
between two algebraic neural systems — a state map that intertwines the dynamics
and read-outs (a "morphism" of architectures, the kind of map a faithful
compression or refactoring induces). Then the behavior is transported correctly
across the map, and the congruence is **pushed forward**: equivalent states stay
equivalent, and the algebraic point in the proof spectrum moves coherently. In
the language of category theory, the assignment

> `network ↦ behaviorCongruence(network)`

is a **functor**. Compressing, refactoring, or re-implementing a network does not
just preserve its outputs — it acts predictably on its geometric shadow in the
proof world.

---

## Why this matters

Three lessons hang together here.

**First, indistinguishability is algebra.** The cryptographer's "no observer can
tell these apart," the automata theorist's Myhill–Nerode classes, and the ML
engineer's "these neurons are redundant" are, under one mild algebraic
hypothesis, the *same* mathematical object: a semiring congruence. That object is
not a vague resemblance but a rigid algebraic structure, and rigidity is exactly
what lets you compute with it and reason about it safely.

**Second, the analytic and the algebraic agree.** It is one thing to define a
distance and another to define a congruence; it is a small miracle, made exact
here, that the points-at-distance-zero and the algebra-respecting equivalence are
the very same relation. When two definitions built for different purposes collapse
onto each other, you have usually found something real.

**Third, compression is geometry.** Minimizing a network is collapsing a
pseudometric; certifying that a compression is faithful is checking that a functor
preserves a point in the proof spectrum. The everyday engineering act of "making
the model smaller without changing what it does" turns out to be a move in a
geometry that also describes how proofs combine.

The bridge built here is small but load-bearing. It says that the way a machine
*sees* and the way a proof *adds up* are, in the right light, the same shape. And
once you have seen two worlds share a shape, you can carry tools across — the
spectral geometry of proofs into the compression of networks, and the concrete,
depth-by-depth computability of networks back into the abstract geometry of
proofs. That is what bridges are for.
