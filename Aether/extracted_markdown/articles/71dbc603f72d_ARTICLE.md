# The Logarithm Hidden Inside Depth: How Valuation Depth Is the Shadow of a Tropical Lipschitz Constant

## A tale of two arithmetics

There are two ways to keep score when you build something out of smaller
parts.

The first is the way an accountant keeps score: every time you bolt one piece
onto another, the cost goes up by a fixed amount, and the total is the *sum* of
the steps. Stack a hundred parts and you pay a hundred times the unit cost. This
is the arithmetic of *length*, of *depth*, of *how many layers deep* a structure
goes.

The second is the way a biologist watches a colony of bacteria: every
generation *multiplies* what came before, and the total is a *product*. After a
hundred generations you do not have a hundred bacteria — you have an
astronomical number. This is the arithmetic of *growth rate*, of *Lipschitz
constants*, of *how fast an error can blow up*.

These two worlds — additive depth and multiplicative growth — look like they
belong to different universes. One is combinatorial and discrete; the other is
analytic and explosive. And yet, this article is about a precise and provable
bridge between them. The bridge has a name as old as Napier: **the logarithm.**

The headline, stated plainly:

> **Valuation depth is the logarithm of a tropical Lipschitz constant. The
> exponential map turns one law into the other, exactly and without loss.**

To unpack that sentence we need to meet the two sides of the bridge, and then
watch the logarithm carry messages back and forth between them.

## Side one: depth that costs a *maximum*, not a *sum*

Imagine you are computing with numbers, but not the everyday numbers on the real
line. Instead you are working in a **non-Archimedean** world — the world of
*p-adic* numbers, where "size" is measured by divisibility rather than
magnitude. In this world the single most important law is the **ultrametric
inequality**:

$$ \|a + b\| \le \max(\|a\|, \|b\|). $$

Read it slowly. In ordinary arithmetic, when you add two numbers their sizes can
*add up* — and worse, carries ripple from one digit to the next, so a sum of two
n-digit numbers can require touching all n digits. In the ultrametric world,
adding two numbers never makes the result bigger than the *larger* of the two.
There are **no carries**. Addition is, in a deep sense, free of long-range
interaction.

This single fact reshapes the cost of computation. We capture it with a measure
called **valuation depth**, written $\operatorname{vdepth}(f)$: the minimum
number of "valuation queries" needed to compute a function $f$. It obeys three
governing laws, and these laws are the heart of the story:

- **Constants are free:** $\operatorname{vdepth}(0) = 0.$
- **Adding is cheap:**
  $\operatorname{vdepth}(f + g) \le \max\!\big(\operatorname{vdepth} f,\ \operatorname{vdepth} g\big) + 1.$
- **Multiplying is cheap:**
  $\operatorname{vdepth}(f \cdot g) \le \max\!\big(\operatorname{vdepth} f,\ \operatorname{vdepth} g\big) + 1.$

And, crucially, **composing functions is cheap**:

$$ \operatorname{vdepth}(f \circ g) \le \max\!\big(\operatorname{vdepth} f,\ \operatorname{vdepth} g\big) + 1. $$

Look at the structure of these laws. Combining two things costs the **maximum**
of their individual costs, plus one. Not the sum — the *max*. This is the
fingerprint of an algebra mathematicians call **max-plus**, or **tropical**
arithmetic: an arithmetic in which "addition" means "take the maximum" and
"multiplication" means "ordinary addition."

The consequence is dramatic. Classical n-bit addition, because of carries,
requires depth on the order of $\log_2 n$. Ultrametric addition requires depth
**one**, no matter how large $n$ is. We can package this as a clean theorem:

> **Ultrametric locality speedup.** For every $n \ge 2$ there is a classical
> depth $\ge \log_2 n$ and an ultrametric depth equal to $1$, with the classical
> depth no smaller than the ultrametric one — and the gap $\log_2 n$ grows
> without bound.

The same max-not-sum philosophy gives non-Archimedean computation a second
gift, this time about *iteration*. In ordinary analysis, if a map $f$ stretches
distances by a factor $L$, then applying it $n$ times stretches them by $L^n$ —
exponential blow-up, the bane of deep neural networks and long simulations. In
the ultrametric world we can record a map's behavior as a single integer
"exponent," and composition takes the **minimum** of exponents:
$$ \operatorname{exponent}(f \circ g) = \min\!\big(\operatorname{exponent} f,\ \operatorname{exponent} g\big). $$
Iterating then does something almost magical — the exponent **does not change at
all**:

> **Ultrametric robustness.** Iterating a map $n$ times leaves its Lipschitz
> exponent exactly equal to the original: no blow-up, ever.

That is the additive, depth-counting side of the bridge: an arithmetic where
combination costs a maximum, and where stability is the default.

## Side two: tropical objects whose Lipschitz constants *multiply*

Now cross to the other bank of the river. Here live **tropical valuation
objects**: algebraic structures in which the defining law is literally

$$ a \oplus b = \max(a, b). $$

Addition *is* maximum. These objects are the natural homes of valuations — the
functions $v$ that measure "order of vanishing" or "p-adic size." On a tropical
valuation carrier we have a valuation $v$, and we say a map $f$ is **Lipschitz
with constant $C$** when

$$ v(f(x)) \le C \cdot v(x) \quad\text{for all } x. $$

This is the multiplicative world. And here the iteration story is the *opposite*
of the ultrametric exponent's perfect stability — it grows, and we can prove
exactly how:

> **Iterated tropical Lipschitz rate.** If $v(f(x)) \le C\,v(x)$ for all $x$,
> then for every $n$,
> $$ v\big(f^{[n]}(x)\big) \le C^{\,n}\, v(x). $$

There it is: the bacteria-colony arithmetic. A single-step constant $C$ becomes
$C^n$ after $n$ steps.

The deepest result on this side is that the tropical world is not merely *like*
the ultrametric world — it **reconstructs** it. There is a functor, **valuation
reconstruction**, that takes any tropical valuation carrier and builds from it a
genuine ultrametric seminormed object, in such a way that the tropical valuation
*becomes* the ultrametric norm on the nose:

$$ \operatorname{norm}(x) = v(x). $$

Because this translation is exact, every quantitative bound proved in the
cheaper tropical world transfers, with the **same constant**, to the
ultrametric world:

> **Sharp Lipschitz transfer.** If $f$ is $C$-Lipschitz for the tropical
> valuation, then $f$ is $C$-Lipschitz for the reconstructed ultrametric norm —
> same $C$, no loss.

And the iterated rate transfers too: the reconstructed ultrametric norm also
satisfies $\operatorname{norm}(f^{[n]}(x)) \le C^n \operatorname{norm}(x)$. The
tropical and ultrametric pictures are two views of one object.

## The bridge: a logarithm in disguise

We now have two laws sitting side by side. On the depth side, combination costs
a **maximum plus one**. On the tropical side, iteration costs a **power**. Put
them next to each other:

$$
\underbrace{\operatorname{vdepth}(f \circ g) \le \max(d_f, d_g) + 1}_{\text{max-plus, additive}}
\qquad\Longleftrightarrow\qquad
\underbrace{v(f^{[n]}) \le C^{\,n}\, v}_{\text{multiplicative}}
$$

The translator between these is the exponential map $d \mapsto \mathrm{base}^d$,
and the reason is a one-line identity that every schoolchild who has met
logarithms already knows in their bones:

$$ \mathrm{base}^{\max(a,b) + 1} = \mathrm{base} \cdot \max\!\big(\mathrm{base}^a,\ \mathrm{base}^b\big). $$

Read the two sides. On the left is the **depth law** — a max and a "+1." On the
right is the **multiplicative law** — a maximum of two powers, scaled by a
constant factor of `base`. The exponential function takes "max-plus" and turns
it into "multiply-by-a-factor." It is the same function that turns the additive
generations of compound interest into multiplicative growth, and the same one
that lets a slide rule multiply by adding lengths.

Going the other way, the discrete logarithm $\operatorname{Nat.log}$ inverts the
exponential and recovers depth from rate. This is not a loose analogy; it is a
faithful, structure-preserving comparison — what a mathematician would call a
**1-Lipschitz comparison functor**, even an isometry. Depth is **literally the
logarithm** of a tropical Lipschitz constant, and the tropical constant is
**literally the exponential** of depth.

This is why the two sides feel like different universes and yet obey "the same"
law: they *are* the same law, written in two coordinate systems related by
$\log$ and $\exp$. The accountant and the biologist were measuring the same
phenomenon all along, one on a linear scale and the other on a logarithmic one.

## Why the comparison earns its keep

A dictionary between two notations is mildly useful. A *quantitative,
constant-preserving* dictionary is a power tool. Here is what the bridge buys
us.

**Stability is contagious.** On the depth side, the ultrametric law makes
iteration perfectly stable: applying a map a million times does not grow its
exponent. Through the logarithm, this is exactly the statement that a tropical
Lipschitz constant of $C = 1$ stays $1$ under iteration, because $1^n = 1$. The
"no blow-up" miracle of non-Archimedean analysis and the "non-expansive maps
stay non-expansive" fact of tropical geometry are the *same theorem* seen from
two angles.

**Hierarchies transfer.** Valuation depth comes with an infinite ladder of
complexity classes $\mathrm{VAL}_0 \subseteq \mathrm{VAL}_1 \subseteq \cdots$,
and one can prove the ladder is *strict*: a single witness of exact depth $k+1$
forces $\mathrm{VAL}_k \subsetneq \mathrm{VAL}_{k+1}$. Under the exponential
comparison, this additive ladder of depths becomes a *multiplicative* ladder of
tropical growth-rate classes. A separation you find in one world is automatically
a separation in the other.

**Certified robustness for free.** The applications are concrete. In
post-quantum cryptography, a security "gap" is a guarantee that distinct keys are
far apart in valuation; the reconstruction functor carries that gap, unchanged,
into an ultrametric distance guarantee. In certified machine learning, a tropical
Lipschitz bound on a classifier becomes an ultrametric robustness radius around
each input. The numbers you prove in the easy, combinatorial, carry-free world
are *exactly* the numbers you may quote in the hard, geometric, adversarial
world.

**Fast root-finding, explained.** The same logarithm underlies why p-adic
Newton (Hensel) iteration is so fast. Each step doubles your precision, so after
$n$ steps you have $2^n$ digits — meaning $\lceil \log_2 n \rceil + 1$ steps
suffice for $n$ digits. Eleven steps gets you a thousand digits; twenty-one steps
gets you a million. Doubling is multiplication; counting digits is its logarithm.
The bridge is everywhere once you learn to see it.

## The shape of the idea

Step back and the picture is almost embarrassingly clean. Two laws that look
unrelated —

- "combining costs the maximum, plus one," and
- "iterating raises to a power" —

are the **same law** viewed through $\exp$ and $\log$. Valuation depth is the
logarithmic shadow cast by a tropical Lipschitz constant; the tropical constant
is the exponential silhouette of depth. The comparison is exact, loses no
constants, and respects all the structure on both sides.

It is a small instance of one of the most reliable patterns in mathematics: when
two theories obey laws that differ only by swapping "$+$" for "$\times$" and
"$\max$" for "$\cdot$," there is almost always a logarithm standing quietly
between them, ready to translate. Here that translator does more than translate —
it certifies. It lets the carry-free, max-plus simplicity of the non-Archimedean
world pay for the robustness guarantees of the analytic one, with no exchange
fee.

The accountant and the biologist, it turns out, can read each other's ledgers
perfectly. All it takes is a logarithm.
