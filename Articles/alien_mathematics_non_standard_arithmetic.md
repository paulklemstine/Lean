# Alien Arithmetic: A World Where Adding Means Choosing the Bigger Number

Imagine you land on a planet whose mathematicians have never heard of carrying
the one. They add numbers, they multiply numbers, they prove theorems — but
when you peer over their shoulder at the chalkboard you see something deeply
strange. In their world,

$$2 + 3 = 3, \qquad 2 + 2 = 2, \qquad 7 + 0 = 7.$$

At first this looks like a child's mistake. But watch their faces: they are not
making errors. They are doing arithmetic by a different rule. On this planet,
**to add two numbers is simply to keep the larger of the two**, and **to
multiply two numbers is to keep the smaller**. Addition is `max`. Multiplication
is `min`. Everything else follows.

This is not science fiction. It is a perfectly rigorous, internally consistent
algebraic system — one that mathematicians on Earth call an *idempotent
semiring*, and that this article will explore from the ground up. By the end you
will see why the alien rules are not only consistent but *unavoidable* once you
accept a single, beautiful starting point: a finite ladder of values where the
only thing that matters is which rung is higher.

## The ladder of values

Start with the simplest possible universe of numbers: a finite, totally ordered
ladder. Write it as $\{0, 1, 2, \dots, n\}$, the integers from $0$ up to some
fixed top value $n$. (In the formal development this is the type `Fin (n+1)`,
the canonical $n+1$-element ordered set.) There is a smallest rung, the
*bottom*, which we call $\bot$ and identify with $0$. There is a largest rung,
the *top*, which we call $\top$ and which sits at the value $n$.

On this ladder we are not allowed ordinary addition and multiplication, because
those would push us off the top of the ladder — $n + n$ is too big to fit. So
the aliens use the only operations that *always stay on the ladder*: comparison.
Given two rungs, you can always ask "which is higher?" and "which is lower?"
That gives us two operations that never overflow:

- **Addition** $x \oplus y := \max(x, y)$ — climb to the higher of the two rungs.
- **Multiplication** $x \otimes y := \min(x, y)$ — settle for the lower of the two rungs.

These two operations, together with the bottom and top of the ladder, turn out
to satisfy *almost every* law of ordinary high-school algebra. The word
"almost" is where the story gets interesting.

## The laws that survive

Let us check, one law at a time, what an alien algebra student would be taught.

**Addition is commutative and associative.** Of course the higher of $x$ and $y$
is the same as the higher of $y$ and $x$; order does not matter:
$\max(x,y) = \max(y,x)$. And if you take the highest of three rungs, it makes no
difference how you group them: $\max(\max(x,y),z) = \max(x,\max(y,z))$. These are
the alien versions of $x+y = y+x$ and $(x+y)+z = x+(y+z)$, and they hold exactly.

**Multiplication is commutative and associative**, for the mirror-image reason:
the lowest rung is the lowest rung no matter how you order or group the inputs.
$\min(x,y) = \min(y,x)$ and $\min(\min(x,y),z) = \min(x,\min(y,z))$.

**Zero is the additive identity.** In our world, adding zero changes nothing.
Here, "zero" is the bottom of the ladder, $\bot = 0$. And indeed
$\max(0, x) = x$ for every $x$, because nothing is below the bottom. Adding the
smallest possible value, by the rule "keep the larger," always returns the other
number untouched.

**One is the multiplicative identity.** In our world, multiplying by one changes
nothing. Here, "one" is the *top* of the ladder, $\top = n$. And
$\min(\top, x) = x$ for every $x$, because nothing is above the top. Multiplying
by the largest possible value, by the rule "keep the smaller," always returns
the other number. This is the first genuine surprise: on this planet, **the
multiplicative unit is the biggest number, not the number $1$.**

**Multiplication distributes over addition.** This is the law that knits a
semiring together — the rule $a \cdot (b + c) = a\cdot b + a \cdot c$. In alien
notation it reads
$$\min\!\big(x, \max(y,z)\big) = \max\!\big(\min(x,y),\, \min(x,z)\big).$$
In words: the smaller of $x$ and "the larger of $y, z$" equals the larger of
"the smaller of $x,y$" and "the smaller of $x,z$." If you doubt it, try
$x=5, y=3, z=8$: the left side is $\min(5, 8) = 5$; the right side is
$\max(\min(5,3), \min(5,8)) = \max(3,5) = 5$. They agree, and they always do.
This is exactly the *distributive law of a distributive lattice*, and it is the
keystone that makes the whole structure a legitimate algebra rather than a
random pair of operations.

When you assemble all of these laws — commutativity, associativity, the two
identities, distributivity, and the facts that "multiplying by zero gives zero"
($\min(0, x) = 0$, since nothing is below the bottom) — you get a bona fide
**commutative semiring**. An alien algebra textbook would open with this
structure exactly as ours opens with the integers.

## The strange new laws

Here is where the planet diverges from ours in ways no amount of relabeling can
hide.

**Adding a number to itself does nothing.** In our arithmetic, $x + x = 2x$. On
this planet, $x \oplus x = \max(x, x) = x$. Doubling is a no-op. The aliens have
a word for this: *idempotence*. There is no "scaling up" by repeated addition;
the system is fundamentally non-Archimedean. You cannot reach the top by adding
small things together over and over — $1 \oplus 1 \oplus 1 \oplus \cdots$ never
climbs past $1$. The same is true of multiplication: $x \otimes x = \min(x,x) =
x$. Every number is its own square.

**The absorption laws.** Because the two operations are intertwined through the
order, they absorb each other in a way ours never do:
$$\max\!\big(x, \min(x,y)\big) = x, \qquad \min\!\big(x, \max(x,y)\big) = x.$$
Whatever $y$ is, mixing it in this nested way leaves $x$ completely unchanged.
There is a kind of algebraic gravity here: $x$ pulls every nearby expression
back to itself.

**And the deepest break of all: you cannot subtract.** In ordinary arithmetic,
every number has a negative; that is what lets us solve $x + a = 0$. On this
planet, ask the simplest version of that question: is there any number $z$ you
can add to the top value $\top$ to get back down to zero? That would require
$\max(\top, z) = 0$. But the larger of $\top$ and anything is $\top$ itself, so
$\max(\top, z) = \top$, which is the top of the ladder — emphatically *not* the
bottom — as long as the ladder has at least two rungs. So **the top element has
no additive inverse.** There is no subtraction, no negative numbers, no way to
undo an addition. Information, once added, can never be removed. The arithmetic
has an arrow of time.

This single fact is what places the system firmly in the category of *alien*,
non-standard arithmetic. It is a semiring but never a ring. The familiar bridge
from semirings to rings — "just throw in the negatives" — collapses, because the
negatives cannot exist without contradicting the order.

## Why this is not a curiosity but a blueprint

It would be easy to file all of this under "amusing toy." It is anything but.
The max–min semiring is the finite, bounded cousin of one of the most important
ideas in modern mathematics: **tropical arithmetic**, in which addition is `min`
(or `max`) and multiplication is ordinary `+`. Tropical mathematics turns curved
geometric problems into piecewise-linear ones, and it now underpins fast
algorithms in optimization, the study of phylogenetic trees in biology,
scheduling problems in operations research, and even parts of theoretical
physics. The recurring lesson is that when you replace "plus" with "take the
better option," hard nonlinear problems flatten into something a computer can
chew through quickly.

Our chain semiring is the purest possible laboratory for that idea. Because the
ladder is finite, *every* statement about it can be checked by brute force, and
*every* law can be traced back to nothing more than the order relation "is higher
than." There are no hidden assumptions, no appeals to the real numbers, no
analysis — only the comparison of rungs. That makes it the ideal place to ask
the central question of non-standard arithmetic: **which classical theorems
survive when you change the rules, and which ones die?**

The answer, as we have seen, is sharp and instructive. The *additive and
multiplicative structure* survives completely — you keep commutativity,
associativity, identities, and distributivity. What dies is *invertibility*:
subtraction vanishes, and with it the entire apparatus of solving equations by
cancellation. In exchange, you gain new laws — idempotence and absorption — that
have no analogue in ordinary arithmetic at all.

## A connection to logic

There is one more way to read these rules that should make any reader smile.
Reinterpret the bottom $\bot$ as *false* and the top $\top$ as *true*, and let
the rungs in between be shades of truth. Then "addition" $\max$ becomes logical
**OR** (true if either input is true), and "multiplication" $\min$ becomes
logical **AND** (true only if both inputs are true). The additive identity
$\bot$ is the fact that "false OR $p$" equals $p$; the multiplicative identity
$\top$ is the fact that "true AND $p$" equals $p$. Distributivity becomes the
familiar law that AND distributes over OR. Idempotence becomes "$p$ OR $p$ is
just $p$." And the absence of additive inverses becomes the observation that you
cannot un-assert a truth: once something is true, no amount of OR-ing will make
it false again.

So the alien arithmetic is, at the same time, **multi-valued logic** — a
continuum (here, a finite ladder) of truth values obeying exactly the algebra of
fuzzy reasoning. The aliens were not making mistakes when they wrote
$2 + 3 = 3$. They were computing the truth value of "$2$ OR $3$," and on a
ladder of truth, the bolder claim wins.

## What we proved

To make all of this airtight, each law above was stated and verified with
complete rigor on the finite ladder $\{0, 1, \dots, n\}$:

- $\max$ and $\min$ are each commutative and associative.
- $\max$ distributes over $\min$ and $\min$ distributes over $\max$ — the two
  distributive laws of a distributive lattice.
- The bottom $0$ is a two-sided identity for $\max$; the top $\top$ is a
  two-sided identity for $\min$.
- $\max$ and $\min$ are idempotent: $\max(x,x) = \min(x,x) = x$.
- The absorption laws $\max(x,\min(x,y)) = x$ and $\min(x,\max(x,y)) = x$ hold.
- Whenever the ladder has at least two rungs, the top element $\top$ has **no**
  additive inverse: there is no $z$ with $\max(\top, z) = 0$.
- Assembling these facts yields a genuine commutative semiring structure on the
  ladder, with addition $=\max$, multiplication $=\min$, zero $=\bot$, and one
  $=\top$.

Every one of these statements was derived from the order alone — no circular
appeal to a pre-existing algebra was used. The laws are not borrowed; they are
*forced* by the simple act of comparing two values and keeping one.

## The moral

Mathematics is often taught as though its rules were handed down on stone
tablets: of course $x + x = 2x$, of course you can subtract. But the alien
arithmetic shows that these "obvious" facts are really *choices* — consequences
of which operations we picked to call addition and multiplication. Choose
differently, in a way that respects nothing but order, and a coherent parallel
universe of algebra springs into being: one with no negatives, no doubling, an
upside-down notion of "one," and a built-in arrow of time. It is strange. It is
self-consistent. And it is quietly running inside every shortest-path algorithm,
every fuzzy-logic controller, and every tropical-geometry computation on Earth.

The aliens, it turns out, were here all along.
