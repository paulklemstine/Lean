# One Operator to Compute Them All

## The dream of a universal building block

Every grand machine, when you take it apart, turns out to be made of small,
repeated pieces. The vast logic of a modern computer chip is built from a single
humble gate — NAND — wired together billions of times. The genetic library of all
life on Earth is written in an alphabet of four letters. Mathematicians and
engineers have a name for this recurring phenomenon: *functional completeness*.
Find one primitive flexible enough, copy it, connect copies together, and you can
build anything in the universe of interest.

This article is about a question of exactly that flavor, but asked in the world of
**continuous mathematics** — the world of smooth curves, exponential growth, and
the calculus that underlies physics and machine learning. The question is
deceptively simple:

> Is there a *single* mathematical operation that, used over and over, can
> reproduce every "elementary" function we care about?

The surprising answer explored here is **yes**, and the operation is shockingly
modest. It is a two-input gadget we will call **EML**:

$$\mathrm{eml}(x, y) \;=\; e^{x} - \ln(y).$$

That is the whole thing. Take the exponential of your first input, take the
natural logarithm of your second input, and subtract. We will see that this one
binary operation — together with the basic arithmetic of adding, multiplying,
negating, and taking reciprocals — is enough to express exponentials, logarithms,
all polynomials, and the entire smooth activation-function toolkit that powers
deep learning: the sigmoid, softplus, hyperbolic tangent, and the swish/SiLU
function. One operator to compute them all.

## Why exp and log are the right atoms

Before meeting EML, it helps to appreciate why the exponential $e^x$ and the
logarithm $\ln(x)$ are such natural "atoms" for continuous computation.

The exponential is the function that *is its own rate of change*: it grows in
proportion to its current size. Compound interest, radioactive decay, population
booms, the discharge of a capacitor, the cooling of coffee — all of them are
governed by $e^x$. The logarithm is its mirror image, the function that turns
multiplication into addition. It is the reason slide rules worked, the scale on
which we measure earthquakes (Richter), sound (decibels), and acidity (pH), and
the quantity an information theorist calls the number of *bits* in a message.

Between them, $e^x$ and $\ln(x)$ form a matched pair: each undoes the other.
And almost every "named" function from a calculus course can be assembled out of
these two together with arithmetic. The sine and cosine hide inside the complex
exponential. Powers $x^a$ are really $e^{a \ln x}$. The bell curve of statistics
is $e^{-x^2/2}$. If you had to pick two transcendental functions to be stranded
on a desert island with, exp and log would be the rational choice.

The bold step taken here is to notice that you do not even need *two* atoms. You
need one — provided you choose it cleverly.

## Fusing two atoms into one

Here is the trick. We bundle exp and log into a single binary operation,
$\mathrm{eml}(x, y) = e^{x} - \ln(y)$, and then show that this fused operator can
*re-derive each half on demand*.

**Recovering the exponential.** Feed EML your value $x$ in the first slot and the
constant $1$ in the second slot. Because $\ln(1) = 0$, the log half vanishes:

$$\mathrm{eml}(x, 1) = e^{x} - \ln(1) = e^{x} - 0 = e^{x}.$$

So the exponential is just EML with a $1$ plugged into its logarithm input.

**Recovering the logarithm.** Now feed EML the constant $0$ in the first slot and
your value $y$ in the second. Because $e^{0} = 1$:

$$\mathrm{eml}(0, y) = e^{0} - \ln(y) = 1 - \ln(y), \qquad\text{hence}\qquad
\ln(y) = 1 - \mathrm{eml}(0, y).$$

So the logarithm is recovered by a single EML call and one subtraction.

This is the keystone. Anything you could have done with separate exp and log
boxes, you can now do with EML boxes alone, by feeding them the right constants.
The two transcendental atoms have collapsed into one, with **no loss of power**.

## What "representable" means

To make the claim precise we fix a small, honest grammar of allowed moves. A
function of several real variables is called **single-operator representable** if
it can be written using only:

- **real constants** (any number you like, such as $1$, $0$, $-\tfrac12$, $\pi$);
- **input variables** (the coordinates $x_1, \dots, x_n$ you feed in);
- the **field operations**: addition $a + b$, multiplication $a \times b$,
  negation $-a$, and reciprocal $a^{-1}$;
- and the single transcendental primitive $\mathrm{eml}(x, y) = e^{x} - \ln(y)$.

Nothing else is permitted. No sine button, no power button, no separate
exponential or logarithm key — only EML and arithmetic.

(One technical footnote keeps everything totally defined: when a logarithm or a
reciprocal is fed an illegal input — $\ln$ of a non-positive number, or the
reciprocal of zero — we assign the conventional "junk" value $0$ rather than
leaving it undefined. This keeps every expression evaluating to an honest real
number, which is what we want when reasoning about *total* functions.)

The central organizing fact is a clean equivalence: the class of functions you can
build from the *two* separate primitives exp and log is **exactly** the class you
can build from the *one* primitive EML. Neither is more powerful than the other.
Compiling from two operators down to one costs at most a constant factor in size —
a logarithm node expands to about five EML-language nodes, and translating back
costs at most a factor of four. The fusion is not just possible in principle; it
is *cheap*.

## First payoff: every polynomial

The first concrete dividend is **algebraic completeness**. A polynomial — a sum of
terms like $3x^2y - 7xz^4 + 5$ — seems to have nothing to do with exponentials or
logarithms. It is built purely from addition and multiplication. So why should EML
care about polynomials at all?

The answer is structural. The single-operator class is *closed under arithmetic*:
if two functions are representable, so are their sum and their product. Once you
know that, polynomials fall out by bookkeeping. A power $x^k$ is a finite product
of copies of $x$, so it is representable. A monomial $c\,x_1^{d_1}\cdots
x_n^{d_n}$ is a constant times a product of powers, so it is representable. And a
polynomial is a finite sum of monomials, so — by closure under sums — it is
representable too. Formally:

> **Polynomial completeness.** Every multivariate real polynomial function
> $p(x_1, \dots, x_n)$ is single-operator representable. The single primitive EML,
> together with arithmetic and constants, captures the entire polynomial algebra
> $\mathbb{R}[x_1, \dots, x_n]$ as evaluated functions.

The proof lifts the two-at-a-time closure under $+$ and $\times$ to *finite*
sums and products by induction, then walks across the terms of an arbitrary
polynomial. It is a satisfying demonstration that a transcendental operator,
properly fused, subsumes the purely algebraic world for free.

## Second payoff: the deep-learning toolkit

The headline application lives in artificial intelligence. A neural network is, at
heart, a tower of two alternating ingredients: **linear maps** (weighted sums of
inputs — pure polynomials of degree one) and **activation functions** (a fixed
nonlinear squashing applied coordinate-wise). The activation is what gives a
network its expressive power; without it, stacking linear maps would only ever
produce another linear map.

Over the decades, practitioners have converged on a small handful of smooth
activation functions. Each one, it turns out, is single-operator representable.
Here they are, stated exactly, each followed by its EML recipe.

**The logistic sigmoid.** The classic S-shaped curve that squashes any real number
into the open interval $(0, 1)$, long used to model probabilities and firing
neurons:

$$\sigma(x) = \frac{1}{1 + e^{-x}} = \bigl(1 + e^{-x}\bigr)^{-1}.$$

Recipe: take the input $x$, negate it, exponentiate (one EML call with second
input $1$), add the constant $1$, and take the reciprocal. Every step is a legal
move, so the sigmoid is representable.

**Softplus.** A smooth, everywhere-differentiable approximation to the popular
ReLU "ramp" function:

$$\zeta(x) = \ln\bigl(1 + e^{x}\bigr).$$

Recipe: exponentiate $x$, add $1$, take the logarithm. This is the one activation
that genuinely uses the *log* half of EML — a reminder that both halves of the
fused operator earn their keep.

**Hyperbolic tangent.** The zero-centered cousin of the sigmoid, mapping the reals
into $(-1, 1)$:

$$\tanh(x) = \frac{\sinh x}{\cosh x} = \frac{e^{x} - e^{-x}}{e^{x} + e^{-x}}.$$

Recipe: both $\sinh$ and $\cosh$ are sums of exponentials (hence representable),
and a quotient is a product with a reciprocal, so $\tanh$ is representable.

**SiLU / swish.** A modern favorite in large networks, the input gated by its own
sigmoid:

$$\mathrm{swish}(x) = x \cdot \sigma(x) = x \cdot \bigl(1 + e^{-x}\bigr)^{-1}.$$

Recipe: multiply the input by the sigmoid we just built. A product of two
representable functions is representable, so swish joins the club.

Put together, this is **applications completeness**:

> Every standard smooth neural-network activation function — logistic sigmoid,
> softplus, hyperbolic tangent, and SiLU/swish — is single-operator representable.
> A single binary primitive therefore suffices to express the entire feed-forward
> activation toolkit.

There is a quietly beautiful observation buried in these recipes. Most of the
activations never touch the logarithm at all — only softplus does. And yet *none*
of them could exist without EML, because the exponential they all rely on is only
available *through* EML, via the trick $e^x = \mathrm{eml}(x, 1)$. Even the
"log-free-looking" activations are secretly exercising the single fused primitive.
That is the cleanest evidence that one binary operator is the true generator of
the whole family.

## Why this is more than a curiosity

It is tempting to file all this under "cute reductions." But the result speaks to
something deeper, a continuous analogue of the **Church–Turing thesis**.

In the discrete world, Church and Turing taught us that wildly different notions of
"computation" — Turing machines, lambda calculus, recursive functions — all
capture exactly the same class of computable functions. There is a single robust
notion of *what is computable*, independent of the gadget you use to compute it.

The continuous world is murkier. What does it even mean to "compute" a real
function with infinitely fine resolution? One influential answer is the analog
computer, or General Purpose Analog Computer, whose primitive operations are
adders, multipliers, and integrators. The line of work behind EML asks a sharp
companion question: *what is the minimal transcendental primitive needed?* And the
answer offered here is striking in its economy — a single binary operator,
$\mathrm{eml}(x, y) = e^x - \ln y$, generates a class that is closed under all the
elementary constructions, including exp, log, and EML itself, and that coincides
exactly with the two-operator elementary class. The thesis has *teeth* in the
applications domain: any function a feed-forward network computes, from polynomial
pre-activations and a fixed smooth activation, already lives in the
single-operator class.

For hardware, the lesson echoes the NAND gate. If you were designing an analog or
neuromorphic chip and wanted one reconfigurable nonlinear cell to rule them all,
EML is a compelling candidate: a single $\exp$–$\ln$–subtract unit, wired up with
ordinary arithmetic, can be coaxed into being any activation you please — flip it
into a sigmoid for one layer, a swish for the next, a softplus for a third — all
without changing the silicon, only the constants you feed it.

For theory, it sharpens our sense of what is truly *primitive*. We are used to
thinking of exp and log as two separate pillars of analysis. EML shows they are
better thought of as two faces of one object. Subtraction, of all things, is the
glue: the identity $\mathrm{eml}(\ln a, e^b) = a - b$ reveals that even ordinary
subtraction can be routed through the transcendental primitive on positive inputs.

## The horizon

A good result opens more doors than it closes. Three questions stand out.

First, **necessity**: is the transcendental operator genuinely irreplaceable?
Arithmetic alone — adding, multiplying, negating, inverting — produces precisely
the *rational functions*, ratios of polynomials. The exponential grows faster than
any rational function ever could, so it provably escapes that fragment. EML is not
a luxury; without it you are trapped among the rationals.

Second, **tightness**: are the compilation overheads — the factor of five going one
way, four coming back — the best achievable? The conjecture is that they are
optimal, with explicit families of expressions that saturate the bounds.

Third, **universality of approximation**: every result here is about *exact*
representation of elementary functions. The natural next summit is a
Stone–Weierstrass-style theorem showing the single-operator class is dense among
*all* continuous functions on a bounded region — that EML expressions can
approximate anything continuous to any desired accuracy. If that holds, the slogan
becomes literally true: with one operator and enough copies, you really can compute
them all.

For now, the moral is already clear and a little wondrous. Hidden inside the two
most important functions in all of analysis is a single fused operation, and that
one operation — copied, wired, and fed the right constants — is enough to write
down every polynomial and every activation function that modern artificial
intelligence runs on. Sometimes the universe really is built from one small,
endlessly repeated piece.
