# Beyond Power Series: Building a Number System for Infinitely Many Scales

## A question of magnitude

Ask a physicist how a quantity behaves as some parameter $x$ grows without bound,
and you will rarely get a single number. You will get a *story about scales*. A
current might decay like $1/x$. A correction might be exponentially small, like
$e^{-x}$. A resonance might blow up like $x^{2}$, or — stranger still — grow so
fast that it outruns every polynomial *and* every exponential, like $e^{e^{x}}$.

Ordinary mathematics has a beautiful tool for the gentle end of this spectrum:
the **power series**. Near a point we can write a function as
$$a_0 + a_1 x + a_2 x^2 + a_3 x^3 + \cdots,$$
and almost all of calculus follows. But power series are blind to two whole worlds.
They cannot see anything that grows faster than every polynomial — they have no
symbol for $e^{x}$. And they cannot resolve the *infinitely fine gradations* of
smallness that appear when you compare $e^{-x}$ against $1/x$ against $e^{-x^2}$.
A power series knows about $x$, $x^2$, $x^3$. It does not know about $\log x$, or
$e^{x}$, or the towers you build by stacking exponentials.

**Transseries** are the number system that fixes this. They are the natural
arena for *asymptotic expansions beyond power series*: formal expressions that
combine powers of $x$, powers of $\log x$, and powers of $e^{x}$, $e^{e^{x}}$,
and higher towers, all at once. They were forged in the study of differential
equations and "exponentially small" effects — the corrections that vanish faster
than any power and are invisible to classical perturbation theory but decide, for
instance, whether a planet's orbit is stable over cosmic time.

This article tells the story of a small, fully verified foundation for that
number system: how to assign a *sign* to a transseries, how to *multiply* its
basic pieces, when you can *take a square root*, and how to construct a genuine
*infinitesimal* — a positive quantity smaller than every ordinary fraction.

## A ladder of magnitudes

The first idea is to stop thinking of a magnitude as a single number and start
thinking of it as a **position on an infinite ladder of scales**.

Imagine a tower of growth rates. At the bottom rung sit the constants. Above them,
the powers of $x$. Above *those*, things built from $e^{x}$; above those, things
built from $e^{e^{x}}$; and so on upward forever. Each rung of the tower is
indexed by an integer "height" $h$, and at each height we are allowed a *real
exponent*. A single magnitude — a **transmonomial** — is therefore a choice of
finitely many heights together with a real exponent at each one. Multiplying two
of these magnitudes adds their exponents, height by height.

To compare two transmonomials we use a **dictionary (lexicographic) order**: scan
the tower heights from the bottom upward and stop at the *first* (lowest) height
where the two exponents differ; whichever has the larger exponent there is the
larger element of the group. In the verified development this ordered set of
magnitudes is written
$$\textsf{TransMono} \;=\; \mathrm{Lex}\,(\mathbb{Z} \to_{0} \mathbb{R}),$$
"finitely supported real exponents indexed by an integer height, ordered like a
dictionary." It is the *value group* — the group of pure scales — of the whole
theory. A crucial convention, which we will make precise in the section on
infinitesimals, links this order to actual size: the **dominant** term of a
transseries is the one sitting on the *smallest* group element, and a *positive*
group element marks an *infinitesimal* scale — a magnitude smaller than every
constant.

A **transseries** is then a (possibly infinite, but well-structured) sum of real
multiples of these magnitudes:
$$\sum_{g} c_g \cdot (\text{magnitude } g).$$
The precise notion that makes such infinite sums behave — the technical engine
that guarantees you can add, multiply, and order them — is the **Hahn series**.
In the verified development the field of transseries is
$$\textsf{TSeries} \;=\; \mathrm{Lex}\big(\mathrm{HahnSeries}\;\textsf{TransMono}\;\mathbb{R}\big),$$
the Hahn series with real coefficients over our ladder of magnitudes, ordered so
that the *leading term* — the coefficient sitting on the dominant magnitude —
decides everything.

That last sentence is the secret of the whole subject, and it is worth saying
slowly: **the sign and the size of a transseries are decided by its single
dominant term** — the term on the smallest (most significant) magnitude.
Everything else is a correction.

## One brick at a time

Before you can reason about complicated transseries you need to understand the
simplest possible ones: the **one-term series**. We write
$$\textsf{term}(g, a)$$
for the transseries that is exactly the real number $a$ sitting on the single
magnitude $g$, and nothing else. Think of $3x^2$, or $-7e^{x}$, or
$\tfrac12 e^{-x}$. These are the bricks; every transseries is built from them.

The verified foundation establishes, with full rigor, the laws these bricks obey.

### Signs from a single number

The first law is almost shocking in its simplicity. A one-term series is positive
*exactly when its coefficient is positive* — no matter how large or small the
magnitude it sits on:
$$0 < \textsf{term}(g, a) \quad\Longleftrightarrow\quad 0 < a.$$
The magnitude $g$ does not enter at all. Whether you are looking at $3$ (a
constant), $3x^{100}$ (enormous), or $3e^{-x}$ (vanishingly small), the sign is
the sign of the $3$. And dually, a negative coefficient forces a negative series:
if $a < 0$ then $\textsf{term}(g,a) < 0$. This is exactly the "leading term
decides the sign" principle made precise for a single brick.

### The monomial law

The second law says multiplication of bricks is *bookkeeping on the exponents*:
$$\textsf{term}(g, a) \cdot \textsf{term}(h, b) \;=\; \textsf{term}(g + h,\; a\,b).$$
Multiply the coefficients, *add* the magnitudes. This mirrors the schoolroom rule
$x^{m}\cdot x^{n}=x^{m+n}$, but now "exponent" means an entire position on the
infinite ladder of scales. Concretely, $(3x^2)\cdot(-2x^5) = -6x^7$ adds the
exponents $2$ and $5$; the very same law governs $(3e^{x})\cdot(2e^{e^{x}})$,
where the magnitudes live on different rungs of the tower and simply add
coordinate by coordinate. This single law — humble as it looks — is the
computational heart of everything that follows.

### Constants

It is reassuring to check that ordinary numbers are bricks too. The constant $1$
is the brick on the *identity magnitude* $0$ (the bottom rung, where nothing
grows): $1 = \textsf{term}(0, 1)$. More generally every counting number $n$ is
the brick $\textsf{term}(0, n)$. Constants are precisely the transseries that
live entirely on the bottom rung.

### Taking a square root

Now for something with real content. When can a magnitude have a square root
*inside the system*? If you want $\sqrt{\textsf{term}(g,a)}$ to again be an
honest one-term transseries, two things must go right at once:

1. **The coefficient** $a$ must be nonnegative, so that $\sqrt{a}$ is a real
   number. (You cannot take a real square root of a negative coefficient.)
2. **The magnitude** $g$ must be *halvable* on the ladder — it must be $k + k$
   for some magnitude $k$ — so that "half the exponent" makes sense.

When both hold, the square root is exactly what you would hope:
$$\big(\textsf{term}(k, \sqrt{a})\big)^{2} \;=\; \textsf{term}(g, a)
\qquad\text{whenever } g = k + k \text{ and } a \ge 0.$$
Halve the exponent, take the real square root of the coefficient. For example
$\sqrt{9x^{4}} = 3x^{2}$ because $9$ has square root $3$ and the exponent $4$
halves to $2$. The verified statement is careful in a way that an informal
treatment often is not: it tracks **both** the coefficient *and* the exponent.
An earlier, naïve version of this claim handled only the exponent and silently
got the coefficient wrong — a reminder of why machine-checked foundations matter.

### What cannot be a square

The flip side is just as important. A brick with a **negative** coefficient is
*never* a square — not just "has no real square root," but provably not a square
of anything in the entire field:
$$a < 0 \;\Longrightarrow\; \textsf{term}(g,a) \text{ is not a square.}$$
The reason is pure order theory. In any ordered system a square is $\ge 0$. But a
negative-coefficient brick is strictly negative (by the sign law above). A
negative thing cannot equal a nonnegative thing, so no square can produce it.
This is the transseries echo of the familiar fact that $-1$ has no real square
root, and it is a first hint at the deep question lurking in the background: *how
close is this field to being real-closed?*

## Building an infinitesimal

Here is where transseries reveal their most counterintuitive power. They contain
genuine **infinitesimals**: positive quantities smaller than every ordinary
fraction $1/n$.

Take any magnitude $\delta$ that is strictly positive in the value group. By the
convention above, a positive group element marks an *infinitesimal* scale. The
brick $\varepsilon = \textsf{term}(\delta, 1)$ is then a strange and wonderful
object.
On one hand it is strictly positive: $0 < \varepsilon$. On the other hand it is
*infinitesimal* in the strongest sense — no integer multiple of it ever reaches $1$:
$$n \cdot \varepsilon < 1 \qquad\text{for every natural number } n.$$
You can add $\varepsilon$ to itself a billion times, a googol times, as many times
as you like, and you will never climb past $1$. This flatly violates the
**Archimedean property** that the real numbers enjoy (where some multiple of any
positive number eventually exceeds $1$), and that is exactly the point:
transseries are a *non-Archimedean* world, rich enough to hold infinitely many
distinct scales of smallness simultaneously.

Why does it work? Because $\varepsilon$ lives on the positive (infinitesimal)
magnitude $\delta$, while $1$ lives on the bottom rung, the identity magnitude $0$,
which is *smaller* in the group order and therefore *dominant*. Multiplying
$\varepsilon$ by the constant $n$ keeps it on the magnitude $\delta$; by the
"smallest magnitude dominates" principle, the constant $1$ towers over it no
matter how large $n$ is. Concretely, $\varepsilon$ behaves like a reciprocal scale
such as $1/x$ as $x \to \infty$: smaller than every $1/n$.

To make this fully concrete rather than abstract, the foundation pins down an
explicit such magnitude: $\textsf{posExp}$, the generator with real exponent $1$
at tower-height $0$. It is verified to be strictly positive in the value group,
and feeding it into the construction above yields an *explicit, named
infinitesimal* — a concrete witness that this exotic number system is not a mirage
but something you can actually point at and compute with.

## Why this is the right foundation

It is tempting to dream big and try to prove, in one heroic stroke, that the
field of transseries is **real-closed** — the property (shared with the real
numbers) that every odd-degree polynomial has a root and every positive element
has a square root. That is a celebrated and genuinely deep theorem. But heroic
strokes are exactly where errors hide. The work described here deliberately does
*not* claim real closure, and it does *not* claim that every positive transseries
has a square root. It claims something smaller and completely solid: a verified
**base layer**.

That base layer is the set of facts every higher result must stand on:

- the **sign** of a brick is the sign of its coefficient;
- **multiplication** of bricks adds magnitudes and multiplies coefficients;
- a brick has a square root *precisely* when its coefficient is nonnegative and
  its magnitude is halvable, and a negative brick is never a square at all;
- the field genuinely contains positive **infinitesimals**, with an explicit one
  exhibited by name.

Each of these is exactly the kind of statement that "everyone knows" and that
turns out, on close inspection, to have a subtle hypothesis (the coefficient
*and* the exponent in the square-root law) or a subtle proof (the order-theoretic
reason a negative brick can never be a square). Getting them airtight is what lets
the next layer be built without fear.

## The road ahead

The square-root law quietly names the obstacle to going further. A *general*
positive brick has a square root only if its magnitude can be halved — only if
the ladder of magnitudes is *divisible*. Our ladder, indexed by **integer**
heights, is not: you cannot, in general, halve an odd integer height. So the very
first step toward square-root closure is to rebuild the ladder over a *divisible*
index — rational heights, say — after which every positive brick acquires a square
root. From there one climbs toward square roots of arbitrary positive series (by
peeling off the dominant term and recursively correcting), toward a clean
**valuation** that reads off each series' dominant magnitude, and ultimately
toward the summit: real closure of the entire transseries field.

But every one of those steps will lean on the four facts established here. That is
how durable mathematics gets built — not by leaping to the summit, but by setting
one verified stone, then the next, until the tower stands. Transseries give us a
language for *every* scale of growth and decay at once; this foundation makes the
first sentences of that language precise, and true.
