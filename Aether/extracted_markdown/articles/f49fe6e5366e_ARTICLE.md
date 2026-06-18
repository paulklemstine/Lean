# Three Faces of "Same Behavior": When Distance, Logic, and Geometry Agree

## A puzzle about telling things apart

Imagine you are handed two black boxes. Each has a slot where you can feed in
symbols — letters, numbers, button presses — one at a time, and a little window
that shows a reading after each step. You are told the boxes might be built
differently inside: different wiring, different number of internal parts, maybe
a wholly different design philosophy. Your job is to decide a single question:
**do these two boxes behave the same?**

You cannot open them. All you can do is type sequences of inputs and watch the
readings. If, no matter what sequence you try — short or astronomically long —
the two windows always show the same reading, then for every practical purpose
the boxes are interchangeable. They are *behaviorally indistinguishable*.

This humble idea is one of the deepest unifying threads in mathematics and
computer science. It is the soul of the Myhill–Nerode theorem in automata
theory, the engine behind minimizing finite-state machines, the meaning of
"two cryptographic keys look the same to any efficient adversary," and — as
this article will show — a surprising meeting point of three subjects that
rarely sit at the same table: **metric geometry**, **mathematical logic**, and
**algebraic geometry**.

The story we tell is about a particular kind of black box that has become the
defining technology of our age: a **neural network**, viewed as a machine that
reads inputs, updates a hidden internal state, and emits an observable reading.
We will see that the notion of "two hidden states behave the same" can be
expressed in three completely different mathematical languages — as a
**distance of zero**, as a **logical congruence**, and as a **point in a
geometric spectrum** — and that all three say *exactly the same thing*. The
punchline is a theorem that fuses these three viewpoints into one.

## The machine, made precise

Let us strip the black box down to its essentials. We call it an **algebraic
neural observation system**. It has:

- a space of **hidden states** `R`;
- a space of **observable outputs** `K`;
- for each input symbol `a`, a **layer** `step(·, a)` that transforms the
  current state into a new state;
- a **read-out** `observe` that turns a hidden state into a visible output.

To make the machine truly *algebraic* — and this is the crucial design choice —
we ask that both the state space `R` and the output space `K` be **semirings**:
sets where you can add and multiply, with the familiar rules (associativity,
distributivity, a zero and a one), but where subtraction need not exist. The
natural numbers are the canonical example, as are the tropical "min-plus"
algebras that power shortest-path algorithms and the Boolean algebra of
true/false.

The algebraic requirement is that every layer and the read-out **respect this
arithmetic**. Concretely, for each input symbol `a` and all states `x, y`:

- `step(0, a) = 0`        (a layer sends the zero state to the zero state)
- `step(x + y, a) = step(x, a) + step(y, a)`   (layers are additive)
- `step(x · y, a) = step(x, a) · step(y, a)`   (layers are multiplicative)

and likewise the read-out satisfies `observe(0) = 0`,
`observe(x + y) = observe(x) + observe(y)`, and
`observe(x · y) = observe(x) · observe(y)`.

There is a subtle, deliberate omission here. We do **not** demand that layers
preserve the multiplicative unit `1`. Why? Because behavioral equivalence never
inspects the state's notion of "one" — it only ever compares sums and products
of states through the window. Insisting on `step(1, a) = 1` would be an unused
hypothesis, and a false one in many natural examples. Keeping our assumptions
as lean as possible is not pedantry; it is what makes the resulting theory apply
to the widest range of machines.

## The behavior of a state

Feed a sequence of symbols `w = a₁ a₂ … aₙ` into the machine starting from a
state `x`. Each symbol advances the state through its layer; after the whole
sequence, the read-out produces a number. Call this number the **behavior of
`x` on the context `w`**:

> `behavior(x, w) = observe( step( … step(step(x, a₁), a₂) …, aₙ ) )`.

The empty sequence simply reads out the starting state: `behavior(x, []) =
observe(x)`.

Here is the first small miracle, and it is a direct consequence of the algebraic
laws above. **The behavior map is itself a homomorphism in the state.** That is,
for every context `w`:

- `behavior(0, w) = 0`,
- `behavior(x + y, w) = behavior(x, w) + behavior(y, w)`,
- `behavior(x · y, w) = behavior(x · y, w) = behavior(x, w) · behavior(y, w)`.

The reason is a clean induction: a composition of additive maps is additive, a
composition of multiplicative maps is multiplicative, and the read-out is both.
So folding many layers and then observing preserves the arithmetic perfectly.
This single structural fact is the lever that moves everything else.

## Face One: behavior as a distance

Now define when two states `x` and `y` are **behaviorally indistinguishable**:
they agree on *every* context.

> `x ≈ y`  means  for all sequences `w`,  `behavior(x, w) = behavior(y, w)`.

This is plainly an equivalence relation — reflexive, symmetric, transitive — and
it is the neural analogue of the Myhill–Nerode equivalence from the theory of
automata.

We can dress this relation as a **distance**. Define the **observation
pseudometric**:

> `obsDist(x, y) = 0` if `x ≈ y`, and `obsDist(x, y) = 1` otherwise.

This is the simplest possible geometry: everything is either at distance zero
(indistinguishable) or at distance one (separable by some context). It is a
genuine *pseudometric* — it is non-negative, a state is at distance zero from
itself, it is symmetric, and it satisfies the triangle inequality
`obsDist(x, z) ≤ obsDist(x, y) + obsDist(y, z)`. The triangle inequality is the
only law with real content, and it follows from a charming observation: the only
way the left side can be `1` while the right side is `0` would require
`x ≈ y` and `y ≈ z` but `x ̸≈ z`, which transitivity forbids.

It is a *pseudo*metric, not a metric, precisely because two genuinely different
internal states can sit at distance zero — that is the whole point. The geometry
"sees" only behavior, not wiring.

## Face Two: behavior as a logical congruence

Step into the language of algebra. A **congruence** on a semiring is an
equivalence relation that is *compatible with the operations*: if `a ≈ b` and
`c ≈ d`, then `a + c ≈ b + d` and `a · c ≈ b · d`. Congruences are to semirings
what normal subgroups are to groups — they are exactly the relations you can
quotient by to get a smaller semiring.

Here is the second miracle. Because the behavior map is a homomorphism in the
state, behavioral indistinguishability is **automatically a congruence**. If
`x ≈ y` and `u ≈ v`, then for every context `w`,

> `behavior(x + u, w) = behavior(x, w) + behavior(u, w) = behavior(y, w) + behavior(v, w) = behavior(y + v, w)`,

and the identical computation with `·` in place of `+`. So `x + u ≈ y + v` and
`x · u ≈ y · v`. The purely *semantic* notion of "same behavior" turns out to be
a purely *algebraic* object. We call it the **behavior congruence**.

This upgrade is not cosmetic. Congruences come with a whole established theory —
in particular a notion of **prime congruences**, the semiring cousins of prime
ideals, and a **proof spectrum**: the space of all prime congruences, organized
with a Zariski-style topology. By recognizing the behavior of a neural system as
a congruence, we have planted it firmly in the soil of algebraic geometry.

## Face Three: behavior as a geometric point

The "proof spectrum" is the analogue, for semirings and proof systems, of the
spectrum of a commutative ring — the foundational object of modern algebraic
geometry. Its points are prime congruences; its closed sets are "provability
loci" carved out by a Galois connection. In this picture, *every* algebraic
neural system donates a point-and-variety datum: its behavior congruence is a
location in this proof-theoretic landscape.

So the same relation `x ≈ y` wears three costumes:

1. **Metric:** it is the set of pairs at observation distance zero.
2. **Coalgebraic:** it is the Myhill–Nerode behavioral equivalence.
3. **Algebraic-geometric:** it is a semiring congruence, a datum of the proof
   spectrum.

The capstone theorem says these are **literally the same relation**:

> `obsDist(x, y) = 0`  ⟺  `x` and `y` are behaviorally equivalent  ⟺  the
> behavior congruence relates `x` and `y`.

The analytic quotient (collapse everything at distance zero), the Myhill–Nerode
quotient (collapse behaviorally equivalent states), and the algebraic quotient
(quotient by the congruence) all produce one and the same object. Distance,
logic, and geometry agree.

## Building the bridge into a category

A single object is a curiosity; a *functor* is a theory. The deeper payoff is
that this correspondence respects **maps between machines**.

A **morphism** of algebraic neural systems is a translation `f` from the states
of one machine `N` to the states of another machine `M` that **intertwines the
dynamics**: applying a layer and then translating gives the same result as
translating and then applying the corresponding layer,
`f(step_N(x, a)) = step_M(f(x), a)`, and the read-outs agree,
`observe_N(x) = observe_M(f(x))`. Notice we do *not* require `f` to respect
addition or multiplication — only the dynamics and the window. That is all
behavior preservation needs.

Such a translation **preserves behavior on every context**:
`behavior_N(x, w) = behavior_M(f(x), w)`. As an immediate corollary, `f`
**pushes the behavior congruence forward**: if `x ≈ y` in `N`, then
`f(x) ≈ f(y)` in `M`. The assignment "machine ↦ its behavior congruence" is
functorial — it transports not just objects but their relationships.

These morphisms assemble into a genuine **category**. There is an identity
morphism on every system (the identity map on states trivially intertwines
everything), and morphisms **compose**: if `f` translates `M` to `P` and `g`
translates `N` to `M`, then `f ∘ g` translates `N` to `P`, again intertwining
layers and read-out. Two morphisms that act the same way on states are equal.
With identities and associative composition in hand, the algebraic neural
systems and their intertwiners form a category, and the behavior pushforward is
a bona fide functor on it — it sends identities to identities and respects
composition.

## From pseudometric to honest metric

The observation pseudometric had one "defect": distinct states could sit at
distance zero. But a defect from one angle is an invitation from another. The
set of pairs at distance zero is exactly the behavior congruence — an
equivalence relation — so we can **quotient by it**. Collapse every cluster of
behaviorally indistinguishable states into a single point, and what remains is
the **Myhill–Nerode quotient**, the minimal "compressed" realization of the
machine.

On this quotient, the observation distance descends to a genuine **metric**.
The recipe is principled: because `obsDist` gives the same answer when you
replace any state by a behaviorally equivalent one (it is *invariant* under the
congruence), it is well-defined on equivalence classes. The descended distance
`quotObsDist` then satisfies all the metric axioms — distance zero from a class
to itself, symmetry, the triangle inequality — and now, crucially, the
separation axiom:

> `quotObsDist([x], [y]) = 0`  ⟺  `[x] = [y]`.

Two *classes* are at distance zero exactly when they are the same class. The
pseudometric on raw states has matured into an honest metric on behaviors. And
because morphisms preserve behavior, they descend to non-expanding maps of these
metric quotients — translating one machine into another can never increase
observational distance.

## Why this matters

It is tempting to file this under "elegant abstraction," but the practical
resonance is real.

- **Minimization and compression.** The quotient construction is exactly model
  minimization: the smallest machine with the same behavior. For neural systems,
  this is a principled, certified form of compression — discard internal
  distinctions that no input can ever reveal, and you provably lose nothing
  observable.

- **A common currency.** Engineers reach for *distances* (Lipschitz bounds,
  robustness radii); logicians reach for *congruences and quotients*; algebraic
  geometers reach for *spectra and prime points*. This bridge shows that, for
  behavioral equivalence, these are three dialects of one language. A theorem
  proved in one dialect can be translated to the others.

- **Geometry of behavior.** Embedding neural behavior into a proof spectrum
  opens the door to importing the heavy machinery of algebraic geometry —
  Zariski topology, prime decomposition, Galois connections — into the study of
  what machines can and cannot tell apart.

- **Functoriality is robustness of meaning.** Because the correspondence is a
  functor, it is stable under the natural notion of "the same machine, retold."
  Refactor your architecture, re-encode your states, change your wiring — as
  long as you intertwine the dynamics, the behavioral geometry travels with you,
  never expanding.

## The shape of the idea

There is a recurring pattern in mathematics: a concept that seems tied to one
domain turns out to be a shadow cast by something larger, visible from many
sides at once. "Two things behave the same" is such a concept. From the
engineer's bench it looks like a distance collapsing to zero. From the
algebraist's desk it looks like a congruence you can quotient by. From the
geometer's vantage it looks like a point in a spectrum. The theorem at the
heart of this story does something quietly profound: it proves the three
shadows are cast by a single solid object.

When you next wonder whether two black boxes are *really* the same, you can now
answer in whichever language suits you — and rest assured the answer will not
change.
