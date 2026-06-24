# One Logarithm Is Enough: How a Single Curve Can Imitate Every Continuous Shape

## A puzzle about copying curves

Imagine you are handed a wild, wiggly curve drawn across a page — a temperature
chart, a stock price, the silhouette of a mountain range. Now suppose your only
tool is one fixed, gentle curve: the graph of $t \mapsto \log(1 + t)$, a smooth
function that rises slowly from $0$ at $t = 0$ to about $0.693$ at $t = 1$. You are
allowed to add copies of this curve, scale them, multiply them together, and add
plain horizontal lines (constants). Nothing else. No new ingredients, no second
function.

Could you, with only these moves, reproduce *any* continuous shape on the unit
interval $[0,1]$ — to any accuracy you like?

It sounds impossible. A single logarithm is a humble, monotone thing. How could
combinations of it possibly capture the violent oscillations of, say,
$\sin(100\,t)$, or a sharp Lipschitz zig-zag? Yet the answer is a clean and
slightly astonishing **yes**. The set of all functions you can build from
$\log(1 + t)$ using addition, multiplication, and constants is *dense* in the
space of all continuous functions on $[0,1]$. Whatever continuous target you
name, and whatever tolerance $\varepsilon > 0$ you demand, there is a
combination of logarithms that stays within $\varepsilon$ of your target
everywhere.

This article is about why that is true, why it matters for modern computing, and
why getting the *reasoning* exactly right turned out to be surprisingly subtle.

## The cast of characters: EML networks

The story belongs to a family of computational models sometimes called **EML
networks** — for **E**xp, **M**ultiply, **L**og. These are functions assembled
from a small alphabet of primitive operations: the exponential function
$\exp$, the logarithm $\log$, addition $+$, and multiplication $\times$. They are
cousins of neural networks, but instead of the familiar ReLU or sigmoid
activations, their expressive power comes from the interplay of exponentials and
logarithms.

EML networks are attractive because exp and log are exactly the operations that
turn multiplication into addition and back again — the engine behind slide rules,
log-likelihoods, and a great deal of numerical computing. A central theoretical
question is: *how expressive are they?* Can a network built only from these
primitives approximate arbitrary behavior? Classical "universal approximation"
theorems answer such questions for standard neural networks, but they usually do
so *existentially* — they promise that *some* network works, without pinning down
which ingredients are essential.

The result at the heart of this article isolates the essential ingredient with
almost shocking economy: **a single logarithmic coordinate suffices.**

## The master key: Stone–Weierstrass

To see why one logarithm can do so much, we need a classical gem of twentieth
century analysis: the **Stone–Weierstrass theorem**.

Marshall Stone's theorem generalizes a famous fact discovered by Karl
Weierstrass in 1885: every continuous function on a closed interval can be
approximated as closely as you like by *polynomials*. Stone realized that
polynomials are not special for any deep reason — what matters are three
structural properties of the collection of approximating functions:

1. **It is an algebra.** You can add its members, multiply them, and scale them
   by constants, and you stay inside the collection.
2. **It contains the constants.** The flat function $t \mapsto c$ is available
   for every real $c$.
3. **It separates points.** For any two distinct inputs $x \neq y$, *some*
   member of the collection assigns them different values. The collection can
   "tell points apart."

Stone's theorem says: *any* collection of continuous functions on a compact
space satisfying these three properties is dense — it can approximate every
continuous function arbitrarily well. The specific functions you started with are
irrelevant. Only the structural skeleton matters.

This is a liberating idea. It converts a hard analytic question ("can I
approximate this wild function?") into three easy-to-check structural questions.
And of those three, two are nearly automatic for any algebra worth its name. The
only one with any teeth is the third: **separating points.**

## The whole game is separation

Here is the crux. When we build all combinations of $\log(1 + t)$ — sums,
products, scalings, plus constants — we automatically get an algebra that
contains the constants. Properties (1) and (2) come for free. So the entire
question of whether one logarithm can imitate every continuous function reduces
to a single, almost childish-sounding check:

> Given two different points $x \neq y$ in $[0,1]$, does $\log(1 + t)$ assign
> them different values?

And the answer is obviously yes — because $\log(1 + t)$ is **strictly
increasing**. As $t$ climbs from $0$ to $1$, the quantity $1 + t$ climbs from $1$
to $2$, and since the logarithm is one-to-one on the positive numbers, distinct
inputs always produce distinct outputs:
$$
x \neq y \quad \Longrightarrow \quad \log(1 + x) \neq \log(1 + y).
$$

That single observation — *the generator is injective* — is the load-bearing
fact. Everything else is machinery. The strict monotonicity of the logarithm is
the seed from which universal approximation grows.

So the formal chain of reasoning is:

$$
\underbrace{\log(1+t)\ \text{is injective}}_{\text{strict monotonicity}}
\;\Longrightarrow\;
\underbrace{\text{the generated algebra separates points}}_{\text{telling inputs apart}}
\;\Longrightarrow\;
\underbrace{\text{the algebra is dense}}_{\text{Stone–Weierstrass}}.
$$

## What the approximants actually look like

There is a pleasingly concrete payoff. Because every combination of a single
generator $g(t) = \log(1+t)$ built by adding, multiplying, and scaling is just a
**polynomial in that generator**, the approximating functions have an explicit
form. Every continuous target $F$ on $[0,1]$ can be approximated, within any
$\varepsilon > 0$, by a function of the shape
$$
t \;\longmapsto\; p\big(\log(1 + t)\big)
= a_0 + a_1 \log(1+t) + a_2 \big(\log(1+t)\big)^2 + \cdots + a_n \big(\log(1+t)\big)^n,
$$
for some ordinary real polynomial $p(u) = a_0 + a_1 u + \cdots + a_n u^n$. In
words: *compose a polynomial with a logarithm and you can match any continuous
curve.*

There is a beautiful way to see why this must work, which also hints at how to
actually compute the coefficients. Make the change of variable $u = \log(1 + t)$.
As $t$ ranges over $[0,1]$, the new variable $u$ ranges over $[0, \log 2]$, and
the relationship is reversible: $t = e^{u} - 1$. So approximating $F(t)$ by
$p(\log(1+t))$ on $[0,1]$ is *exactly the same problem* as approximating the
reshaped function $u \mapsto F(e^u - 1)$ by an ordinary polynomial $p(u)$ on
$[0, \log 2]$ — and that is precisely the classical Weierstrass theorem, which we
know how to solve with tools like Bernstein polynomials. The logarithm is just a
lens that warps the interval; through that lens, ordinary polynomials do the rest.

## A concrete miniature: approximating $x^2$

To make this tangible, consider the simplest nontrivial target: $F(t) = t^2$ on
$[0,1]$. Using the change of variable $u = \log(1+t)$, equivalently $t = e^u - 1$,
we want a polynomial $p$ with $p(u) \approx (e^u - 1)^2 = e^{2u} - 2e^u + 1$ on
$[0, \log 2]$. Truncating the Taylor expansions of the exponentials gives a short
polynomial in $u$, and substituting $u = \log(1+t)$ back yields an explicit
EML approximant
$$
t \;\longmapsto\; p\big(\log(1+t)\big)
$$
that hugs the parabola $t^2$ across the whole interval. The companion code for
this article computes these coefficients and reports the actual error: even a
low-degree polynomial in $\log(1+t)$ tracks $t^2$ to within a fraction of a
percent, and the error shrinks rapidly as the degree grows.

## Why the careful version of the story matters

There is a cautionary subplot here, and it is a genuinely interesting one about
the *discipline of proof*.

A tempting but flawed way to argue that "the log-generated algebra is dense"
would be to invoke a generic statement like "EML networks are universal
approximators, therefore this particular EML-generated algebra is dense." That
reasoning is **circular**. The generic universal-approximation claim is the very
thing one wants to establish; using it to justify a specific instance is borrowing
the conclusion to prove a premise. It feels like progress but proves nothing.

The version of the story told here is deliberately **non-circular**. It never
appeals to any pre-existing EML universal-approximation result. It uses only two
honest ingredients:

- the general Stone–Weierstrass theorem (a fact about *arbitrary* algebras, with
  no EML content whatsoever), and
- elementary properties of the logarithm — that it is continuous away from zero
  and injective on the positive numbers.

From these, and nothing else, the density of the log-coordinate algebra follows.
This matters because in mathematics — and especially in the modern enterprise of
machine-checked mathematics — the *provenance* of a fact is as important as the
fact itself. A theorem is only as trustworthy as the chain of reasoning behind
it, and a single circular link can quietly invalidate the whole argument. Building
the result from genuinely independent foundations turns a plausible-sounding slogan
into a theorem you can stake your name on.

## The bigger picture

Strip away the specifics and a general principle emerges, one with real reach:

> **Any strictly monotone, continuous "generator" on a compact interval —
> $\exp$, $\tanh$, softplus, or our $\log(1+t)$ — single-handedly generates a
> dense algebra. One injective curve is enough to imitate them all.**

The logarithm is not magic; *monotonicity* is. The same three-step argument
applies verbatim to any activation function that never doubles back on itself.
This reframes universal approximation not as a property of clever architectures
with many moving parts, but as a consequence of a single, transparent geometric
condition: *the building block must be able to tell points apart.*

And the idea scales. In higher dimensions, on the cube $[0,1]^d$, one simply uses
the family of coordinate logarithms $t \mapsto \log(1 + t_i)$, one per axis.
Because each is injective in its own coordinate, the products of these generators
separate points of the whole cube, and Stone–Weierstrass applies again, word for
word. Universality in any dimension flows from the same humble source.

## Coda: economy as insight

There is an aesthetic lesson lurking here. The most powerful theorems are often
the ones that reveal how *little* you need. Universal approximation can sound like
a story about abundance — more neurons, more layers, more parameters. This result
tells the opposite story. A single rising curve, combined only with the
arithmetic everyone learns as a child, already contains every continuous shape as
a limit. The richness was never in the ingredients. It was in the structure — in
addition, multiplication, and the simple, decisive fact that a logarithm always
knows the difference between two distinct numbers.
