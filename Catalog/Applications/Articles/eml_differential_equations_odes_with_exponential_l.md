# The Equation That Refuses a Formula

## A rainbow, a telescope, and a stubborn little differential equation

In 1838 the British astronomer George Biddell Airy was trying to understand a
puzzle of light. When light passes near a sharp edge — the rim of a rainbow, the
boundary of a shadow, the focus of a telescope — it does not stop cleanly. It
ripples. The brightness oscillates on one side of the boundary and fades smoothly
to nothing on the other. To capture this delicate behavior, Airy wrote down what
looks like one of the simplest possible differential equations:

$$ y'' = x\,y. $$

In words: *the curvature of the function at each point equals the function's own
height multiplied by how far you are along the axis.* Where $x$ is negative the
function curves back toward the axis and oscillates like a wave; where $x$ is
positive it curves away and either explodes or decays. The two basic solutions,
written $\mathrm{Ai}(x)$ and $\mathrm{Bi}(x)$, are now called the **Airy
functions**, and they appear everywhere physicists look at the edge of things:
optics, quantum mechanics near a "turning point," the theory of how rainbows get
their supernumerary fringes, even the statistics of the largest eigenvalues of
random matrices.

Here is the strange part. Despite the equation being almost childishly simple,
its solutions cannot be written down with the symbols we usually reach for. There
is no formula for $\mathrm{Ai}(x)$ built from powers, roots, exponentials,
logarithms, sines, and cosines. The Airy functions are genuinely *new*
functions — not shortcuts for combinations of old ones.

That kind of statement is easy to assert and notoriously hard to prove. "I can't
find a formula" is not the same as "no formula exists." Mathematicians have a
long, embarrassing history of failing to find things that were there all along.
To say with certainty that *no* elementary formula can ever work, you need an
argument that rules out every possibility at once.

This article tells the story of one such argument — a clean, complete, and fully
rigorous proof that a large and natural family of candidate formulas is
*impossible*. The family is the **exponential–polynomials**: functions of the
shape

$$ f(x) = q(x)\,e^{p(x)}, $$

where $q$ and $p$ are ordinary polynomials and $q$ is not the zero polynomial.
This family already contains an enormous amount of what we mean by "closed-form":
every polynomial (take $p=0$), every pure exponential like $e^{x}$ and the
Gaussian bell $e^{-x^2}$, products like $x^3 e^{2x}$, and so on. If the Airy
equation had a tidy elementary solution of the most common shape, it would very
plausibly live here.

It doesn't. And the reason is beautiful: it comes down to **counting**, and to a
single mismatch between an *odd* number and an *even* number.

## The trick: peel off the exponential

The first move is the one every good physicist or mathematician makes when they
see $e^{p(x)}$ sitting in a problem: differentiate and watch what happens to the
exponential.

If $f(x) = q(x) e^{p(x)}$, then by the product rule and the chain rule,

$$ f'(x) = \big(q'(x) + q(x)\,p'(x)\big)\, e^{p(x)}. $$

Notice the shape is preserved: a polynomial times the *same* exponential
$e^{p(x)}$. The exponential never goes away and never changes; only the
polynomial prefactor evolves. Differentiating $q(x) e^{p(x)}$ is the same as
applying the operator

$$ q \;\longmapsto\; q' + q\,p' $$

to the prefactor. Apply it twice and you get the second derivative. After a short
computation, the second derivative of $q\, e^{p}$ is

$$ f''(x) = \Big(\,q'' + 2\,q'\,p' + q\,p'' + q\,(p')^2\,\Big)\, e^{p(x)}. $$

That bracketed polynomial is the hero of the story. Call it the **Airy
coefficient** of $q$ and $p$:

$$ \mathrm{airyCoeff}(q,p) \;=\; q'' + 2\,q'\,p' + q\,p'' + q\,(p')^2. $$

It is, by definition, the exact polynomial you get when you differentiate
$q\,e^{p}$ twice and then strip the exponential back off. This is not an
approximation or a heuristic; it is an algebraic identity, true for every choice
of polynomials $q$ and $p$.

Now suppose, hopefully, that $f = q\,e^{p}$ actually solves Airy's equation
$f'' = x f$. The left side is $\mathrm{airyCoeff}(q,p)\, e^{p}$. The right side
is $x\cdot q(x)\, e^{p(x)}$. The exponential factor is *the same on both sides*,
and an exponential is never zero, so we can cancel it cleanly. What remains is a
purely algebraic equation between polynomials:

$$ \mathrm{airyCoeff}(q,p) \;=\; x\cdot q. $$

We have completely removed calculus from the problem. The analytic question "does
this function solve a differential equation?" has become the algebraic question
"can these two polynomials be equal?" And polynomials are things we can *count*.

## The decisive count

Every nonzero polynomial has a **degree**: the highest power of $x$ that appears.
The degree of $x \cdot q$ is simply one more than the degree of $q$. If $q$ has
degree $d$, then $x\cdot q$ has degree $d+1$. Keep that number in mind: the target
on the right-hand side has degree $d+1$.

Now look at the Airy coefficient itself. It has four terms, and we ask which one
is biggest. Write $m$ for the degree of $p'$ (the derivative of $p$). The four
terms have degrees:

- $q''$ has degree $d-2$ (differentiating lowers degree),
- $2\,q'\,p'$ has degree $(d-1)+m$,
- $q\,p''$ has degree $d + (m-1)$,
- $q\,(p')^2$ has degree $d + 2m$.

When $p$ is genuinely nonconstant, so $p'$ is not zero and $m \ge 0$, the last
term $q\,(p')^2$ towers over the other three: its degree $d + 2m$ is strictly
larger than each of $d-2$, $d-1+m$, and $d+m-1$. Nothing can cancel it. So the
Airy coefficient has degree *exactly*

$$ \deg\big(\mathrm{airyCoeff}(q,p)\big) = d + 2m. $$

Here is the punchline. For the two polynomials to be equal, their degrees must
match:

$$ d + 2m \;=\; d + 1, \qquad\text{which forces}\qquad 2m = 1. $$

But $2m$ is an **even** number and $1$ is **odd**. No whole number $m$ can make
$2m$ equal to $1$. The equation is impossible — not approximately, not usually,
but *always*, by the most elementary fact about even and odd numbers. The
$(p')^2$ term, by squaring the derivative of the exponent, can only ever raise the
degree by an *even* amount, while the multiplication by $x$ on the right raises it
by exactly *one*. Even can never meet odd.

There is one remaining loophole to close: what if $p$ is constant, so that
$e^{p}$ is just a constant multiplier and $p' = 0$? Then the Airy coefficient
collapses to $q''$, whose degree is at most $d-2$, strictly *less* than the
target degree $d+1$. Mismatch again. (If $q$ itself is constant the gap is even
more obvious: a constant cannot equal $x$ times a nonzero constant.) Every branch
of the argument ends in the same wall.

So we have proved, with complete rigor and astonishing economy, the central fact:

> **No exponential–polynomial solves Airy's equation.** If $q$ is a nonzero real
> polynomial and $p$ is any real polynomial, then $f = q\,e^{p}$ does **not**
> satisfy $f'' = x\,f$.

The Airy functions are forced to live outside this entire universe of formulas.
Whatever $\mathrm{Ai}(x)$ is, it is not a polynomial, not an exponential, not a
polynomial times an exponential, not any finite assembly of those parts.

## Why a counting argument is so satisfying

It is worth savoring *why* this works. A naive person hunting for a formula tries
candidate after candidate, each one failing for its own particular reason. That
process never ends and never proves anything; the next candidate might always
succeed. The degree argument does something categorically stronger. It assigns to
each side of the equation a single integer — a fingerprint — and shows the
fingerprints can never match, no matter how cleverly you choose the polynomials.
One side always carries an even excess; the other always carries an odd one. The
infinitely many candidates are all rejected by one stroke.

This is the same spirit in which one proves that $\sqrt{2}$ is irrational (a
parity contradiction between even and odd) or that you cannot square the circle
with ruler and compass (an algebraic invariant that constructions can never
reach). In each case an *invariant* — something that stays put no matter how you
manipulate the objects — exposes an impossibility that brute force could never
confirm. Here the invariant is the parity of the degree, and the manipulation is
the act of writing down a formula.

## The bigger picture: a hierarchy of "solvable"

The Airy obstruction is a small, sharp instance of one of the grand themes of
mathematics: the realization that *most* problems do not have answers in the
vocabulary we start with, and that the right response is to enlarge the
vocabulary honestly rather than to keep searching in vain.

Évariste Galois discovered the prototype for polynomial equations: the quintic
$x^5 + \cdots = 0$ has no solution by radicals, not because nobody is clever
enough, but because a hidden symmetry group forbids it. In the 20th century this
idea was carried over to *differential* equations by Picard, Vessiot, Kolchin,
and others, creating **differential Galois theory**. To every linear differential
equation it attaches a symmetry group, and the shape of that group dictates
exactly which kinds of formulas — polynomials, exponentials, logarithms, algebraic
functions, and their finite combinations, the so-called **Liouvillian**
functions — can possibly appear in a solution. For Airy's equation that group is
as large and "unsolvable" as it can be, which is the deep reason the Airy
functions resist every elementary formula.

The full differential-Galois machinery is heavy. What makes the result in this
article delightful is that for the most important and most common family of
candidate formulas — a polynomial times an exponential — you do not need any of
that machinery. You need the product rule, the chain rule, and the fact that two
plus two is even. A single algebraic identity converts the analytic question into
a counting question, and counting finishes the job.

## Where this idea goes next

The argument is a template, not a one-off. Its engine — *factor out the
exponential, compare degrees* — keeps running when you change the equation:

- **Other linear equations.** Replace the right-hand side $x\,y$ by any
  polynomial combination $a(x)\,y' + b(x)\,y$. The same cancellation turns the
  problem into a single polynomial identity, and a degree count again decides,
  case by case, exactly which $q\,e^{p}$ can survive.

- **Higher-order Airy cousins.** For equations like $y''' = x\,y$ or, more
  generally, $y^{(n)} = x\,y$, the $n$-th derivative of $q\,e^{p}$ still factors
  as a polynomial times $e^{p}$, and the dominant term is still $q\,(p')^{n}$.
  The same even-versus-odd tension reappears in a new guise.

- **Complex coefficients.** Nothing in the argument truly needed the numbers to
  be real. Over the complex numbers the exponential still never vanishes and the
  degree bookkeeping is identical, so the obstruction lifts verbatim.

- **A decision procedure.** Because matching the Airy coefficient against a target
  polynomial is just a finite system of equations in the unknown coefficients of
  $q$ and $p$, one can build an *algorithm* that, given a polynomial differential
  equation, decides whether any $q\,e^{p}$ solves it — and constructs the solution
  when one exists. This connects the elementary count back to the powerful,
  general algorithms of Risch and Kovacic for finding closed-form solutions.

Airy's little equation, born from the study of how light bends around a shadow,
turns out to be a perfect teaching example of a profound idea: that the boundary
between "has a formula" and "needs a new function" is not a matter of cleverness
but of arithmetic. Some equations simply live on the other side of that line, and
once you learn to count, you can prove it.
