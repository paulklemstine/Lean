# The Price of Approximation: When Simplicity Meets the Infinite

## A tale of two truths

There is a peculiar tension at the heart of every machine that learns. On one
hand, we want our models to be *flexible* — able to bend and curve to match any
pattern in the data, no matter how intricate. On the other hand, we want them to
be *simple* — describable in a few lines, cheap to store, easy to reason about.
These two desires pull in opposite directions, and the story of how they
reconcile is one of the most beautiful in modern mathematics.

This article tells that story for a particular family of mathematical machines:
the **EML closures**, where E stands for *Exponential*, M for *Multiplicative*,
and L for *Logarithmic*. These are functions you can build out of a tiny
vocabulary — take an input $x$, add things together, multiply them, raise $e$ to
a power, take a logarithm — and nothing else. No magic constants, no lookup
tables, just the four operations and the variable $x$.

The remarkable claim we will make precise is this: **the EML family can
approximate any continuous function you like, to any accuracy you like — but the
better you want the approximation, the more complex your formula must become, and
this growth in complexity is genuinely unavoidable.** Universal flexibility and
irreducible complexity are not enemies. They are two faces of the same coin.

## Building functions from a four-letter alphabet

Imagine you are given a single building block — the identity function, which just
echoes its input: $x \mapsto x$. From this seed, and four operations, you can
grow an astonishing forest of functions.

- **Addition.** Combine two formulas $s$ and $t$ into $s + t$.
- **Multiplication.** Combine them into $s \times t$.
- **Exponentiation.** Wrap a formula $t$ into $e^{t}$.
- **Logarithm.** Wrap a formula $t$ into $\log t$.

From $x$ alone, addition gives you $x + x = 2x$, then $x + x + x = 3x$, and so on.
Multiplication gives you $x \cdot x = x^2$ and all the powers. Exponentiation
gives you $e^x$, and combining the lot gives you wonders like $e^{x^2}$,
$\log(1 + e^x)$ — the "softplus" function beloved of neural networks — and
$e^{x}\log(x^2 + e^x)$. We call any such formula an **EML term**, and the set of
functions you can write this way the **EML class**.

Two numbers measure how complicated a term is. Its **size** counts how many
symbols it uses — every leaf $x$ and every operator. Its **depth** counts how
deeply the operators are nested, like the height of the tree you would draw to
represent the formula. A short, shallow formula is "simple"; a long, deeply
nested one is "complex."

Crucially, our alphabet is *finite* and *constant-free*. There is no way to write
down the number $7$ directly, or $\pi$, or any other constant. You only have $x$
and the four operations. This restriction is not a handicap — it is what makes the
theory sharp, and as we will see, it isolates exactly one missing ingredient with
surgical precision.

## The optimist's theorem: you can approximate anything

Here is the first half of the story, the optimistic half. Fix any interval of the
real line, say $[a, b]$. Now pick any continuous function $f$ defined on that
interval — it can wiggle, spike, oscillate, do whatever a continuous function is
allowed to do. The claim is:

> **Density Theorem.** Finite combinations of the *exponential monomials*
> $x \mapsto e^{k x}$ (for $k = 0, 1, 2, \dots$) can approximate $f$ as closely as
> you wish, uniformly across the whole interval. Formally, the linear span of
> $\{\,e^{0\cdot x}, e^{1\cdot x}, e^{2\cdot x}, \dots\,\}$ is **dense** in the
> space $C([a,b])$ of continuous functions.

In plain language: take a handful of exponential curves of different growth rates,
mix them together with the right coefficients, and you can mimic any continuous
shape to within any tolerance $\varepsilon$ you name. The bumps and valleys of
$f$ get traced out by an orchestra of exponentials playing in concert.

This is a cousin of the celebrated Stone–Weierstrass theorem, the cornerstone
result that explains *why* neural networks, polynomial regressions, and Fourier
series all work as universal approximators. The exponential monomials are
particularly natural here because they sit so comfortably inside the EML
vocabulary: $e^{kx}$ is just $e$ raised to the power "$x$ added to itself $k$
times."

So far, pure optimism. Any target, any accuracy. What could possibly go wrong?

## The realist's theorem: simplicity is a finite resource

Now the second half, the sobering half. Let us ask a Kolmogorov-style question,
named for the great Andrey Kolmogorov who taught us to measure the complexity of
an object by the length of the shortest description that produces it.

For an EML-computable function $g$, define its **EML complexity** $K(g)$ to be the
size of the *smallest* EML term that computes it. This is a genuine complexity
measure — the analogue, for our four-letter language, of "the length of the
shortest program."

Here is the key structural fact, and it follows from nothing more than counting.
Because our alphabet is finite, there are only finitely many terms of any given
size. A term of size $n$ is a string drawn from a finite vocabulary with at most
$n$ symbols, and there are only so many such strings. Therefore:

> **Finiteness Principle.** For each budget $n$, only finitely many distinct
> functions are EML-computable by a term of size at most $n$. Call this finite
> collection $\mathrm{computableLE}(n)$ — a *finite island* in the vast ocean of
> functions.

Each island is finite. The full EML class is the union of all these islands as
$n$ grows. And here is where the two halves of our story collide.

## The collision: an infinite family that escapes every island

We now build an explicit infinite family of functions, all living inside the EML
class, and watch them outrun every finite budget.

For each natural number $k$, consider the term obtained by adding the variable to
itself $k+1$ times — call it $\mathrm{repAdd}(k)$ — and then exponentiating:
$$
\mathrm{expBasis}(k) \;=\; \exp\bigl(\underbrace{x + x + \cdots + x}_{k+1}\bigr)
\;=\; e^{(k+1)x}.
$$
A direct calculation, by induction on $k$, pins down both its meaning and its
cost exactly:

- **What it computes:** $\mathrm{expBasis}(k)$ evaluates to the function
  $x \mapsto e^{(k+1)x}$.
- **What it costs:** its size is exactly $2k + 2$.

That second line is the linear complexity bound. Spelled out as a theorem about
the complexity measure $K$:
$$
K\bigl(x \mapsto e^{(k+1)x}\bigr) \;\le\; 2k + 2.
$$
The complexity of the $k$-th generator grows *linearly* in $k$. Doubling the
frequency roughly doubles the description length — no more, no less.

Next, a small but decisive observation: **distinct frequencies give distinct
functions.** If $e^{(a+1)x}$ and $e^{(b+1)x}$ agree for all $x$, then evaluating
at $x = 1$ and using the fact that the exponential function never repeats a value
forces $a = b$. The family is *injective*: every generator is a brand-new
function, never a disguised repeat of an earlier one.

Put the pieces together. Each island $\mathrm{computableLE}(n)$ is finite. The
generator family $\{e^{(k+1)x} : k = 0, 1, 2, \dots\}$ is infinite and never
repeats. An infinite, non-repeating family cannot fit inside any single finite
island. Therefore:

> **Escape Theorem.** For every budget $n$, only finitely many of the exponential
> generators are computable within size $n$. The dense generating family escapes
> every finite complexity island.

This is the heart of the matter. The exponentials that make the optimist's
Density Theorem work are *exactly* the witnesses that complexity must grow without
bound. They are dense — they can approximate anything — and they are
incompressible *as a family*: no fixed description budget can hold them all.

## The synthesis: universal approximation has a price

We can now state the headline result, which marries the two halves into a single
sentence.

> **Density Meets Incompressibility.** On every compact interval $[a, b]$, the
> linear span of the exponential monomials is uniformly dense in the continuous
> functions, *and* every nonconstant generator $x \mapsto e^{(k+1)x}$ is
> EML-computable. Universal approximation is realized by an EML-computable family
> whose complexity is unbounded across the family.

This is not a hollow "A and B." The first conjunct is the genuine, hard density
theorem. The second is proved by the explicit term construction above, with its
exact size accounting. Together they say something profound about the cost of
accuracy: as you demand approximations of finer and finer continuous targets, you
are forced to reach for generators of higher and higher frequency, and each such
generator costs strictly more to describe. The complexity of approximation is not
a wart on the theory — it is a theorem.

This is the EML incarnation of a guiding intuition behind the whole field of
learning theory: to approximate a function $f$ to accuracy $\varepsilon$, you need
description length scaling like $K(f)/\varepsilon$, tying the cost of learning
directly to the intrinsic, Kolmogorov-style complexity of the target. The EML
class makes this slogan precise and, for the exponential generators, exact.

## The one function that got away

There is a delicious twist, the kind of detail that reveals the theory is alive.
Look back at the generator family. It runs $e^{(k+1)x}$ for $k = 0, 1, 2, \dots$,
that is, $e^{x}, e^{2x}, e^{3x}, \dots$. But the Density Theorem invokes the
monomials starting from $e^{0 \cdot x} = e^{0} = 1$ — the *constant function*.

The constant-free EML class can build every nonconstant generator, but it cannot
build the constant $1$. Why not? Because every formula you can write starts from
$x$ and propagates $x$'s value through additions, products, exponentials, and
logarithms; there is no way to "forget" the input entirely and return a fixed
number. The single function the language cannot name is the one density needs and
the one our generators skip: $k = 0$.

This is not a defect. It is a discovery. It pinpoints, with no ambiguity, the
*unique* primitive you would need to add — a constant leaf — to extend the
complexity theory to constants. The boundary of the theory is exactly one bit of
information wide. Adding a single leaf "$1$" to the alphabet would let you name
every rational constant $q$ (each with its own finite complexity $K(c_q)$), though
intriguingly the complexities of those constants would themselves grow without
bound as the rationals grow more intricate — but that is a story for a future
chapter.

## Why this matters beyond the page

It is tempting to file all this under "abstract nonsense," but the tension it
captures is everywhere in computational practice.

When you train a neural network, you are searching for a short description — a set
of weights — that reproduces a complicated function. The Density Theorem is your
license to believe a good approximation *exists*. The Escape Theorem is the
warning that the price of accuracy is real: more accuracy, more parameters, no
free lunch. The two together explain a daily experience of every practitioner:
you can always do better, but better always costs more.

The same duality drives data compression, the design of function libraries, the
theory of which problems admit short certificates, and the philosophy of
Occam's razor itself. Simplicity is a *finite resource*, doled out island by
island. Expressiveness is the *infinite union* of all those islands. The
exponential generators are the explicit ladder that climbs from each finite stage
to the infinite whole, one rung — one frequency, one unit of complexity — at a
time.

## The shape of the argument

Strip the story to its skeleton and it is astonishingly clean:

1. **Density** is a statement about the *union* of all the islands: every
   continuous function is approximated by *some* term, of *some* size.
2. **Incompressibility** is a statement about each *individual* island: each one
   is finite.
3. **The bridge** is an explicit infinite, injective, EML-computable family whose
   members fan out across the islands, proving the union is genuinely
   infinite-dimensional while every stage stays finite.

That is the whole mechanism by which "universal approximation" and "Kolmogorov
incompressibility" coexist without contradiction. They were never in conflict.
One is about what the language can *reach*; the other is about what any fixed
*budget* can *hold*. The exponential monomials, those humble curves $e^{kx}$, are
the place where the two truths shake hands.

And so the tension we began with dissolves into harmony. You can approximate
anything — and you will pay, fairly and predictably, for every digit of accuracy
you demand. In mathematics, as in life, the most flexible tools are exactly the
ones whose mastery has no upper bound.
