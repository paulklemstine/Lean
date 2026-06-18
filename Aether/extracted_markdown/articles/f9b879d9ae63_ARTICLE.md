# Why Deep Functions Aren't Always Complicated — and Wide Ones Always Are

## A puzzle about the shape of types

Every programming language that lets you pass functions to functions has, hidden
inside it, a small zoo of *types*. The simplest type is just a plain value — call
it `base`. From there you build function types with an arrow: `base → base` is the
type of a function turning a value into a value. But arrows can nest. You can have
a function that takes a function and returns a value: `(base → base) → base`. You
can have a function that returns a function that returns a function, and so on,
out to whatever monstrous nesting your patience allows.

Two numbers describe the shape of such a type. The first is its **depth**: how many
arrows you have to pass through, at most, to get from the outside to the innermost
value. The second is its **size**: how many pieces the whole type is built from in
total. A long thin pipeline `base → base → base → base` is *deep* but not very big.
A bushy, balanced tree of arrows is both deep *and* big.

Now here is the question that this work answers, completely and rigorously. When you
actually *run* programs of a given type — when you ask how many genuinely different
internal states a computation at that type can pass through — what controls the
answer? Is it depth? Is it size? Is it something else entirely?

The intuitive guess, the one almost everyone reaches for first, is **depth**. Depth
*feels* like the right notion of complexity. A deeply nested function looks
intimidating; a flat one looks tame. The headline result here is that this intuition
is *provably wrong*, and we can say exactly how wrong, and exactly what to use
instead.

## A ruler for semantic complexity

To make the question precise we need a single number that measures how complex the
behavior of a type can be. The mathematics in this work uses a quantity called the
**type-state bound**, written `typeStateBound`. It is defined by a beautifully simple
rule that mirrors the structure of the type itself:

- A plain value has type-state bound **1**:
  `typeStateBound(base) = 1`.
- A function type multiplies the (incremented) bounds of its parts:
  `typeStateBound(A → B) = (typeStateBound(A) + 1) · (typeStateBound(B) + 1)`.

That multiplication is the whole story. It says that when you combine two types with
an arrow, their complexities don't *add* — they *multiply*. Multiplication is the
engine of explosion, and almost everything surprising below flows from this one rule.

This bound is not an arbitrary invention. It is the natural ceiling on the number of
distinguishable semantic states a higher-order computation can occupy — the kind of
quantity that governs **automata minimization**, **bisimulation collapse**, and the
classic phenomenon computer scientists call *state explosion*. When you minimize a
system down to its essential, behaviorally-distinct states, this is the number you
are bumping against.

One of the first things proved is reassuring: this freshly minted ruler is not a new
animal at all. It coincides *exactly* with a previously studied measure called type
**complexity**, which obeys the identical recurrence. Formally,

> **Theorem (the two rulers agree).** For every type `A`,
> `typeStateBound(A) = complexity(A)`.

So we are measuring something canonical, not something we cooked up to make the
theorems come out nicely.

## The case for the prosecution: depth is not enough

Let's now put the intuitive suspect — depth — on trial.

First, a sanity check that keeps everyone honest:

> **Theorem (depth is dominated).** For every type `A`,
> `depth(A) ≤ complexity(A)`.

Depth never exceeds complexity. Fine. But "never exceeds" is a one-way street, and
the real question is whether depth can *predict* complexity. Can we promise that a
type of depth `d` has complexity at most some fixed function of `d`?

To answer, we compare two families of types that are deliberately engineered to have
the *same depth* but opposite shapes.

### The pipelines (chain types)

A **chain type** is the thin pipeline: `base → base → base → ⋯ → base`. Every arrow's
left side is just a plain value; all the nesting happens on the right. These are the
leanest possible types at each depth — a single unbranching spine.

For chains, depth really is in control. Because each step only doubles things (the
left side contributes a factor of `(1+1) = 2`), the complexity grows like a clean
single exponential:

> **Theorem (chains are tame).** If `A` is a chain type, then
> `typeStateBound(A) ≤ 3^(depth(A) + 1)`.

Concretely, the chains have type-state bounds `1, 4, 10, 22, 46, …`, each roughly
double the previous one — comfortably under the `3^(d+1)` ceiling. If chains were the
whole world, depth *would* be the right complexity measure, and this article would be
much shorter.

### The bushes (bushy types)

Now meet the opposite extreme. A **bushy type** `bushy(n)` is a perfectly balanced
binary tree of arrows. You start from a plain value and repeatedly glue a type to a
copy of itself: `bushy(0) = base`, and `bushy(n+1) = bushy(n) → bushy(n)`. So
`bushy(1) = base → base`, `bushy(2) = (base→base) → (base→base)`, and so on.

These trees have *exactly the same depth* as a chain of the same number of levels:

> **Theorem (bushes are deep, precisely).** `depth(bushy(n)) = n`.

But watch what the multiplicative recurrence does when both halves are the *same*
big type. Each level squares the previous bound:

> **Theorem (bushes square).**
> `typeStateBound(bushy(n+1)) = (typeStateBound(bushy(n)) + 1)^2`.

Squaring, applied over and over, is the signature of *doubly* exponential growth —
a tower, not a ramp. And indeed:

> **Theorem (bushes explode).**
> `2^(2^n) ≤ typeStateBound(bushy(n)) + 1`.

Read that exponent carefully: `2^(2^n)`. The bound is exponential in something that
is *itself* exponential in the depth. The first few values are `1, 4, 25, 676,
458329, …` — by depth four the type-state bound has already blown past four hundred
thousand, while the chain of depth four is still sitting quietly at `46`.

Same depth. Wildly different complexity. The contrast is the crux of the whole story.

### The verdict: an impossibility theorem

This isn't just a quantitative gap; it is a *qualitative* impossibility. No matter
what constant base you pick for an exponential-in-depth formula, the bushes will
eventually outrun it. The result is stated as cleanly as such a thing can be:

> **Impossibility Theorem.** There is **no** constant `c` such that
> `typeStateBound(A) ≤ c^(depth(A) + 1)` holds for *every* type `A`.

The proof is a lovely little argument by contradiction. Suppose such a `c` existed.
Apply it to the bushes: since `depth(bushy(n)) = n`, you'd get
`typeStateBound(bushy(n)) ≤ c^(n+1)`. But the bushes grow like `2^(2^n)`. Pitting
`c^(n+1)` (single exponential in `n`) against `2^(2^n)` (double exponential in `n`),
the double exponential wins for large `n` — overwhelmingly. The supposed bound
collapses. Depth, all by itself, simply cannot be a leash on semantic complexity.

## The case for the defense: size is exactly right

If depth is the wrong parameter, what is the right one? The answer is the type's
**size** — its total number of building blocks — and the relationship is astonishingly
clean:

> **Size Bound.** For every type `A`,
> `typeStateBound(A) + 1 ≤ 2^(size(A))`.

Equivalently, the type-state bound never exceeds `2^(size(A)) − 1`, a quantity this
work calls the **predicted bound**. Every type, no matter how its arrows are arranged,
fits under a simple exponential in its size. There are no exceptions, no special cases,
no pathological families that escape. Size is the honest, universal controlling
parameter that depth pretended to be.

Why does size succeed where depth fails? Because size *sees the whole tree*. Depth
only measures the longest root-to-leaf path; it is blind to branching, so it cannot
tell a thin chain from a fat bush. Size counts every node, so it notices when a type
is wide. And in the multiplicative recurrence, width is exactly what fuels the
explosion. The bushes are doubly exponential in depth precisely because they are
*exponentially wide*: the size of `bushy(n)` is `2^(n+1) − 1`, so a double exponential
in depth is just a single exponential in size in disguise.

This reframing — that overwhelming-looking depth-driven blowup is really ordinary
size-driven growth — is the conceptual payoff. The "explosion" was never about depth.
It was about how much type you were quietly carrying along.

## Depth and width, together

There is one more elegant piece that ties the picture together. For chain types,
depth and a second quantity called **arrow width** (the number of arrow constructors)
coincide exactly. In general the two are linked by a tidy identity:

> **Width–size identity.** For every type `A`,
> `2 · arrowWidth(A) + 1 = size(A)`.

So size and width carry the same information up to a factor of two, and width is
always strictly less than size. The bushes max out width — `arrowWidth(bushy(n)) =
2^n − 1` — while chains keep it minimal, equal to their depth. The slogan that emerges
is precise: **depth bounds complexity only when width is held down.** It is the
*product* of depth-driven nesting and width-driven branching that decides which growth
regime you land in. Pin down size (equivalently, width) and the complexity is leashed;
let width run free and depth tells you nothing.

A bridge result even bounds size in terms of depth — `size(A) ≤ 2^(depth(A)+1) − 1`,
the familiar full-binary-tree ceiling — which, chained with the size bound, recovers
the worst-case double-exponential-in-depth growth from first principles. The bushes
are not a fluke; they are the extremal family that attains the order of every bound
in sight.

## Why this matters beyond type theory

It is tempting to file all this under "cute facts about lambda calculus," but the
lesson is far more general, and it shows up wherever people try to tame complexity by
choosing a parameter to measure it.

In **algorithm design**, a whole discipline — parameterized complexity — is built on
finding the *right* knob: a structural parameter such that problems become easy when
the knob is small. This work is a crisp cautionary tale. A parameter that *looks*
natural (depth) can be hopeless, while a humbler one (size, or width) can be exactly
the leash you need. Choosing the wrong parameter doesn't just give weak bounds; it
can make *no* bound possible at all.

In **verification and model checking**, "state explosion" is the dragon practitioners
fight every day. The multiplicative recurrence here is the same multiplication that
makes the product of two systems blow up. The theorems say, in a clean toy setting,
exactly when collapse (minimization, bisimulation) can save you and when it cannot:
manage the *total size*, not just the nesting depth, and budget for double-exponential
worst cases when your structure is allowed to branch.

And in **the broader project of measuring complexity** — whether of programs, proofs,
networks, or learning machines — the moral rings true again and again: the
parameter you find intuitive is not always the parameter that governs the math.
Sometimes the deepest-looking thing is tame, and the thing that really controls the
explosion is the one you weren't counting. The honest way to know is to *prove* it —
to pin down each definition, build the extremal families that probe the limits, and
let the inequalities deliver their verdict. That is exactly what has been done here,
end to end, with no gaps left to intuition.

Depth is seductive. Size is decisive. And the difference between them is a tower of
exponentials tall.
