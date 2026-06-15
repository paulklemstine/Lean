# The Deceptive Depth of Functions

## Why nesting is not the same as complexity

Imagine you are handed a machine. You are not allowed to open it, but you are
told one number about it: how many layers deep its internal gears are nested.
Layers of gears inside gears inside gears. From that single number — the
*depth* — could you predict how complicated the machine's behavior can get?

It feels like you should be able to. Depth sounds like the natural measure of
complexity. A shallow thing is simple; a deeply nested thing is intricate. This
intuition runs through all of computer science. When programmers talk about
"deeply nested" code, they mean complicated code. When mathematicians talk about
"higher-order" functions — functions that take other functions as arguments,
which in turn take still other functions — the word *higher* carries a whiff of
danger, of spiraling complexity.

This article is about a precise mathematical setting where that intuition is
not just imperfect, but provably, catastrophically wrong. We will look at the
"types" of functional programs — the formal labels that describe what kind of
input a function expects and what kind of output it returns — and at a measure
of how complex the behavior of such a function can be. We will see that two
function types can have *exactly the same depth* and yet differ in complexity by
an amount so vast it cannot be written down with ordinary exponentials. And we
will see exactly which measure *does* control the complexity. The whole story
has been verified down to the last logical step, so there is no hand-waving:
every claim below is a theorem.

## The vocabulary of function types

Let us build the world we are talking about from nothing. We start with a single
"base" type, which you can think of as a plain data value — call it `o`, for
"object." From this one seed we grow more elaborate types using a single
operation: the arrow `→`, which builds the type of functions.

- `o` is the base type.
- `o → o` is the type of functions that take an `o` and return an `o`.
- `(o → o) → o` is the type of functions that take *a function* and return an
  `o`.
- `o → (o → o)` is the type of functions that take an `o` and return *a
  function*.

And so on, without limit. Every type is either the base `o` or an arrow `A → B`
built from two smaller types `A` and `B`. This is the language of *simple
types*, the backbone of typed functional programming and of logic going back to
Church and Curry.

Three numbers measure a type. The **depth** counts the deepest level of arrow
nesting: `o` has depth 0, `o → o` has depth 1, and an arrow `A → B` has depth
one more than the deeper of its two parts. The **size** simply counts every
symbol in the type: `o` has size 1, and `A → B` has size one plus the sizes of
`A` and `B`. And the **width**, or "bushiness," counts how many arrows there are
in total. Depth measures how *tall* the type's tree is; size and width measure
how *big* it is.

## The complexity we care about

Now, why should a type's shape matter at all? Because the type constrains the
*behavior* of any program that inhabits it. A deep, branching type permits a
program to distinguish many different situations, to remember many different
things, to occupy many different internal "states." In the theory of typed
lambda calculus, one can make this precise with a quantity we will call the
**state bound**, written `tsb(A)`.

The state bound is, roughly, a ceiling on how many genuinely different semantic
states a program of type `A` can pass through — how many behaviors are
distinguishable by observation. It is the higher-order cousin of the classical
notion of "states" in a finite automaton, and it is closely related to the
number of equivalence classes you get when you minimize a program by merging
indistinguishable states (a process called bisimulation minimization).

The state bound obeys a beautifully simple law. For the base type, it equals 1:

```
tsb(o) = 1.
```

A plain value has essentially one state. For a function type, it multiplies:

```
tsb(A → B) = (tsb(A) + 1) · (tsb(B) + 1).
```

The "+1"s record that each component contributes its own states plus the
possibility of having "not yet engaged" that component. This single recurrence,
together with the base case, *is* the state bound. One of our first results is
that this measure coincides exactly with an independently defined notion of type
"complexity" — they satisfy the same recurrence, so they are the same function.
That coincidence is reassuring: the quantity we are studying is canonical, not an
accident of one definition.

## First clue: depth never exceeds complexity

Here is a sanity check that the intuition is at least *partly* right. We can
prove that a type's depth is always less than or equal to its state-bound
complexity:

```
depth(A) ≤ tsb(A)   for every type A.
```

So a complex type is at least as deep as its complexity number — depth can never
*overshoot*. The danger, as we will see, runs entirely the other way: depth can
fall hopelessly, unboundedly *behind*.

## The tame world: chains

To see depth behaving itself, consider the simplest possible family of deep
types: **chains**. A chain is a function pipeline,

```
o → o → o → … → o,
```

where every argument is just the base type `o`, and the arrows stack up on the
right. A chain of depth `d` is a function that takes `d` plain inputs, one after
another, and returns a plain output. It is deep, but it never branches.

For chains, depth really does control complexity. We prove:

```
tsb(A) ≤ 3^(depth(A) + 1)   for every chain type A.
```

The state bound of a chain grows *singly* exponentially in its depth — manageably,
predictably. (The exact value turns out to be `3 · 2^depth − 2`, comfortably
under the `3^(depth+1)` ceiling.) If all function types were chains, depth would
be a perfectly good complexity measure, and this article would have a happy,
boring ending.

## The wild world: bushes

But types are allowed to branch, and branching changes everything. Consider the
**bushy** family — balanced binary trees of arrows. Define:

```
bushy(0) = o,
bushy(n+1) = bushy(n) → bushy(n).
```

So `bushy(1) = o → o`, `bushy(2) = (o → o) → (o → o)`, `bushy(3)` is that
whole thing arrowed with itself, and so on. Each step takes the previous type
and feeds it to itself. These are the maximally branching types at each depth.

Two facts about bushes. First, their depth is exactly what you'd expect:

```
depth(bushy(n)) = n.
```

So `bushy(n)` and a chain of length `n` have the *same depth*. Second — and this
is the heart of the matter — the bushy state bound satisfies a *squaring*
recurrence:

```
tsb(bushy(n+1)) = (tsb(bushy(n)) + 1)^2.
```

Squaring at every level. And squaring repeatedly is the engine of *double*
exponential growth. We prove the lower bound:

```
2^(2^n) ≤ tsb(bushy(n)) + 1.
```

Read that carefully. The exponent itself has an exponent. The numbers explode
beyond comprehension: `tsb(bushy(4))` already exceeds four hundred thousand,
`bushy(5)` runs into the hundreds of billions, and `bushy(6)` has no name in
ordinary speech. Yet every one of these bushes is no deeper than the
corresponding harmless chain.

## The impossibility theorem

Now we can state the punchline as a clean, unconditional impossibility. Could
there be *some* universal constant `c`, however enormous — a million, a
googol — such that every type's state bound is at most `c` raised to the power
of its depth (plus one)? That would salvage depth as a complexity measure: the
constant would absorb the slack, and depth would still rule.

There is no such constant. We prove:

```
There is NO constant c with  tsb(A) ≤ c^(depth(A) + 1)  for all types A.
```

The proof is a duel between two growth rates. Any candidate bound `c^(depth+1)`
grows *singly* exponentially in depth. But the bushes grow *doubly*
exponentially in depth. No matter how large you make `c`, a tower of squarings
eventually outpaces it — the bushy family climbs over the ceiling `c^(depth+1)`
at some finite height and never comes back down. Depth, as a predictor of
complexity, is not merely weak. It is fundamentally, permanently incapable of
the job.

## The measure that works

If depth fails, what succeeds? The answer is **size** — the total count of
symbols in the type. We prove a clean, universal upper bound that never fails:

```
tsb(A) + 1 ≤ 2^(size(A))   for every type A.
```

Every type, chain or bush or anything in between, has a state bound at most one
less than two raised to its size. This gives an immediately *computable*
certificate: from the size of a type alone you can pre-compute a guaranteed
ceiling on its complexity, `2^size − 1`, before you ever run a single program.

Why does size work where depth fails? Because size sees the branching that depth
ignores. A chain of depth `d` has size roughly `2d` — small. A bush of depth `n`
has size `2^(n+1) − 1` — *exponentially larger than its depth*. The bushes hide
their enormity in their width, not their height, and size is the measure that
counts width and height together. Depth blinds you to the bushiness; size does
not.

## Why this matters beyond the page

This is not a curiosity confined to lambda calculus. The depth-versus-size story
is a recurring trap across computing.

**State explosion in verification.** When engineers verify that a chip or a
protocol is correct, they build a model of its states and check every one. The
nightmare scenario is "state explosion," where the number of states blows up
beyond any computer's reach. Practitioners often try to bound the blow-up by some
shallow structural feature — the analogue of depth. Our theorem is a warning
written in mathematics: a shallow feature can hide a doubly exponential
explosion. You must measure the whole structure.

**Automata and language theory.** Converting one kind of automaton to another —
making a nondeterministic machine deterministic, or complementing it — is famous
for causing exponential and even doubly exponential state blow-ups. The bushy
recurrence `(x+1)^2` is exactly the signature of such repeated squaring, and our
results give a clean type-theoretic home for that phenomenon.

**Choosing the right parameter.** Modern algorithm design lives and dies by
*parameterized complexity*: pick a parameter, and ask whether a problem is easy
when the parameter is small. Our result is a vivid case study in choosing
parameters. Depth is the *tempting* parameter, and it is the *wrong* one: a
problem can be intractable even when depth is tiny. Size is the parameter that
actually controls the growth. The art of complexity theory is choosing the knob
that the explosion actually listens to.

**The cost of abstraction.** Functional programmers prize higher-order types —
functions that consume and produce other functions — for their expressive power.
Our results quantify the price of that power. A flat pipeline of operations is
cheap. A type that feeds functions to functions to functions, branching as it
goes, can be astronomically more complex even at the same nesting depth. Power
and cost are bought in the same coin: branching.

## The shape of the truth

Strip away the formalism and the moral is almost philosophical. We measure
things by how *deep* they go — how many layers, how many levels of nesting — and
we equate depth with sophistication. But depth is only one dimension. A wide,
branching, bushy structure can dwarf a deep, narrow one while looking shallower
by the depth gauge. The honest measure of complexity is not how far down a thing
reaches, but how much of it there is altogether.

In the precise world of simple types, we have proved this exactly. Depth cannot
bound complexity — not with any constant, not ever. Size always can. Between
those two facts lies a clean, complete, machine-checked account of where
higher-order complexity really comes from: not from the height of the tower, but
from the breadth of the branches.
