# How Big Is a Function of a Function? The Hidden Explosion Inside Types

## A simple question with a surprising answer

Imagine you are handed a recipe for a kind of machine. Some machines take a
number and return a number. Others take a *machine* and return a number. Still
others take a machine that takes a machine, and so on. In computer science and
logic these recipes are called **types**, and they are the grammar of every
typed programming language and every formal proof.

Here is a deceptively innocent question: *if I tell you how deeply nested a type
is, can you tell me how complicated the things of that type can be?*

It sounds like it ought to be yes. "Deeper" feels like "more complicated." A
three-story building is more complex than a one-story building. Surely a type
nested five arrows deep can only hold so much behavior.

This article tells the story of why that intuition is wrong — spectacularly,
provably wrong — and what the right answer turns out to be. Along the way we
will meet two families of types that look superficially similar but behave like
a candle and a hydrogen bomb, and we will find a single, clean number that
*does* control everything.

## The cast of characters

Let us fix some vocabulary. There is one **base type**, which we will simply
call `o` (think: "the type of plain values," like ordinary numbers). From it we
build **arrow types**: if `A` and `B` are types, then `A → B` is the type of
functions that consume something of type `A` and produce something of type `B`.

That is the whole language. Two rules. Everything below — every monster and
every theorem — is built out of `o` and `→`.

We can measure a type in several natural ways:

- **Depth** is how many arrows you pass through on the longest path from the
  outside in. Formally, depth of `o` is `0`, and depth of `A → B` is
  `1 + max(depth A, depth B)`. Depth is the "height" of the type tree.
- **Size** is the total number of pieces — every `o` and every `→` counted
  once. Formally, size of `o` is `1`, and size of `A → B` is
  `1 + size(A) + size(B)`. Size is the "weight" of the type tree.
- **Width** is the number of arrows alone: `0` for `o`, and
  `1 + width(A) + width(B)` for `A → B`. Width measures branching.

So far these are just bookkeeping. The interesting quantity is the one that
measures *behavior*.

## The number that counts behavior

When you run programs of a given type, they pass through intermediate states as
they compute. Two states that can never be told apart by any future
observation are, for all practical purposes, the same state — this is the idea
behind *minimization*, the art of squeezing a machine down to its smallest
equivalent form. The number of genuinely distinct states a type can force into
existence is its true semantic complexity.

For our types this number has a beautifully simple recursive description. Call
it the **state bound**, written `T(A)`:

- `T(o) = 1`. A plain value has exactly one semantic state — itself.
- `T(A → B) = (T(A) + 1) · (T(B) + 1)`. A function multiplies the
  possibilities of its input and its output, with one extra slot on each side.

That little "+1, then multiply" rule is the engine of everything that follows.
Multiplication, not addition, sits at the heart of functions — and
multiplication is where explosions are born.

It is worth pausing on a pleasing fact: this behavioral state bound `T(A)`
turns out to be *exactly equal* to an independently defined arithmetic measure
of types, the **complexity** `C(A)`, which is defined by the very same
recurrence (`C(o) = 1` and `C(A → B) = (C(A)+1)(C(B)+1)`). Two notions invented
for different reasons — one about counting states, one about scoring types —
coincide perfectly. When that happens in mathematics, it is usually a sign that
you have found something real.

## A gentle giant: the chain types

Let us first meet the well-behaved family. A **chain type** is a pipeline:

```
o → o → o → ... → o
```

Every arrow's left-hand side is just a plain value; the type marches off to the
right in a single straight line. These are the types of ordinary multi-argument
functions, the bread and butter of everyday programming.

How does the state bound grow as the chain gets longer? Using our rule, each
new link does `T ↦ 2 · (T + 1)` — multiply by two, give or take. So the state
bound roughly *doubles* with each level of depth. A chain of depth `d` has a
state bound around `3 · 2^d`. In fact we can prove the clean bound

> **For every chain type, `T(A) ≤ 3^(depth(A) + 1)`.**

This is *singly exponential* in depth: manageable, predictable, the kind of
growth engineers plan for. For chain types, depth really does control
complexity, just as intuition promised. If the world contained only chains,
we could stop here.

## A monster in disguise: the bushy types

Now meet the other family. Instead of always putting a plain value on the left,
let us be greedy and feed each function a copy of the *entire previous type* on
both sides. Define:

- `bushy(0) = o`
- `bushy(n+1) = bushy(n) → bushy(n)`

So `bushy(1)` is `o → o`, `bushy(2)` is `(o → o) → (o → o)`, `bushy(3)` is
`((o → o) → (o → o)) → ((o → o) → (o → o))`, and so on. These are balanced
binary trees of arrows.

Here is the crucial trap. **The depth of `bushy(n)` is exactly `n`** — the same
depth as a chain of length `n`. If you only looked at depth, you could not tell
a bushy type apart from a tame chain.

But watch what the state bound does. The recurrence for bushy types is

> **`T(bushy(n+1)) = (T(bushy(n)) + 1)²`.**

It *squares* at every step. Squaring repeatedly is the textbook recipe for
double exponential growth. Starting from `T(bushy(0)) = 1`, we get
`T(bushy(1)) = 4`, then `T(bushy(2)) = 25`, then `T(bushy(3)) = 676`, then
`457{,}653`, and after that the numbers leave the page. We can prove the lower
bound

> **`T(bushy(n)) + 1 ≥ 2^(2^n)`.**

That tower of twos — two to the power of two to the power of `n` — is one of the
fastest-growing functions that appears in ordinary mathematics. By the time
`n = 6`, the state bound exceeds `2^64`, larger than the number of distinct
states any physical computer could ever enumerate. And all of this hides inside
a type whose *depth is merely six*.

Two types, identical depth, and one is a gentle giant while the other is a
combinatorial inferno. The difference is **width** — how much branching each
arrow carries — and depth is simply blind to it.

## The impossibility theorem

This is not a quirk of one example. It is a fundamental barrier. Suppose you
were an optimistic engineer who hoped that *some* constant `c`, however large,
would let you write a universal guarantee of the form

```
T(A) ≤ c^(depth(A) + 1)   for every type A.
```

You could pick `c` to be a million, a googol, anything you like. The promise is
that depth alone, raised to some fixed base, bounds complexity.

> **No such constant exists.** For *every* candidate `c`, the bushy family
> eventually breaks the bound.

The reason is a race between two kinds of growth. Your proposed bound,
`c^(depth + 1)`, is singly exponential in depth — at the bushy types it grows
like `c^(n+1)`. But the true state bound there grows like `2^(2^n)`, doubly
exponential. A double exponential outruns any single exponential, no matter how
large its base. Push `n` far enough and the monster wins. Depth is therefore
*provably insufficient* as a complexity invariant: there is no rescue, no
cleverly chosen constant, no patch.

This is the heart of the story. A natural, intuitive measure — nesting depth —
that everyone would reach for first is mathematically incapable of doing the
job we want.

## The number that does work

If depth fails, what succeeds? The answer is the humble **size**, the total
count of pieces. And the bound is as clean as one could wish:

> **`T(A) + 1 ≤ 2^(size(A))` for every type `A`.**

In words: the semantic complexity of any type is at most exponential in how
many symbols it takes to write the type down. There are no exceptions, no
families that escape, no hidden constants. Equivalently, the state bound never
exceeds the **predicted bound** `2^(size(A)) − 1`, a quantity you can read off
instantly from the type's syntax.

Why does size succeed where depth fails? Because size, unlike depth, *sees the
whole tree*. The bushy types are deep **and** enormously wide — their size
grows like `2^(n+1) − 1`, exponentially in `n`. When you plug that honest size
into the bound `2^(size)`, you correctly recover the double exponential
`2^(2^(n+1) − 1)` in the depth parameter `n`. Size never lies about how much
type there really is, so the bound built on it never breaks.

There is a tidy way to see exactly what depth misses. For chain types — and
only for tame types like them — depth and width coincide, which is precisely why
depth works there. The general identity `2 · width(A) + 1 = size(A)` shows that
size is really *width in disguise*. The full picture is a clean division of
labor:

- **Depth** measures how tall a type is.
- **Width** (equivalently, size) measures how broad it is.
- **Complexity explodes with breadth, not height.**

Depth controls complexity exactly when a type is as narrow as it is tall — the
chain types. The moment a type branches, breadth takes over and depth becomes a
spectator.

## Why this matters beyond the puzzle

This might look like an elegant curiosity about an artificial language, but the
lesson is broad and practical.

Whenever we try to tame a complicated system by tracking a single "obvious"
number — the depth of a call graph, the number of layers in a network, the
nesting level of a configuration — we are implicitly betting that this number
controls the system's true complexity. The story here is a clean, fully proved
warning that such bets can fail *catastrophically*: two systems can agree on the
intuitive parameter and yet differ by a tower of exponentials. The right
invariant is often not the visually striking one (height) but the one that
accounts for the entire structure (total size).

In the specific world of typed programs and proofs, the consequence is concrete.
If you want to predict, ahead of time, how many states a computation of a given
type might balloon into — say, to allocate memory, to bound a search, or to
guarantee a tool terminates in reasonable time — you must measure the type's
size, not its depth. Size gives you an honest, certified ceiling: at most
`2^(size) − 1` states, guaranteed, always. Depth gives you a comforting number
that the bushy types will happily make a fool of.

There is also a deeper aesthetic payoff. We started with two measures that
looked like rivals and found that one of them, complexity, secretly *is* the
behavioral state count — the same object wearing two costumes. We found a family
of types whose growth pins down the exact shape of the explosion. And we found a
single inequality, `T(A) + 1 ≤ 2^(size A)`, that closes the case for every type
at once. That is what a small piece of mathematics looks like when it is
finished: a sharp question, a counterintuitive answer, a monster to prove it,
and a clean theorem to put everything in its place.

## The takeaway

- Functions multiply complexity (`T(A → B) = (T(A)+1)(T(B)+1)`), and
  multiplication breeds explosions.
- **Depth is a liar.** Two types of the same depth can differ by a double
  exponential, and no constant base ever rescues a depth-only bound.
- **Tame "chain" types** grow only singly exponentially in depth
  (`T(A) ≤ 3^(depth+1)`), which is why depth *seems* to work — until you leave
  the chains.
- **"Bushy" types** square at every level and reach `2^(2^n)`, the hallmark of
  uncontrollable branching.
- **Size tells the truth.** Always, with no exceptions,
  `T(A) + 1 ≤ 2^(size A)`. Breadth, not height, is the real driver of
  complexity.

The next time someone reassures you that a system "isn't very deep, so it can't
be very complex," you will know exactly which type to draw on the napkin to
change their mind.
