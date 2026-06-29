# Why Airy's Equation Refuses to Be a Polynomial

## A curve that bends the rules

In 1838 the British astronomer George Biddell Airy was trying to understand
a stubborn optical puzzle: what exactly happens to light near a *caustic*, the
bright fold you see at the edge of a rainbow or shimmering on the bottom of a
coffee cup? The wave theory of light told him that the brightness should be
governed by a single, deceptively simple differential equation:

$$ y'' = x\,y. $$

In words: the curvature of the function $y$ at each point $x$ is equal to the
function's own value, multiplied by how far you are from the origin. To the
left of zero the equation behaves like the equation of a spring, producing
gentle oscillations; to the right of zero it behaves like a runaway
exponential. Right at the origin the two regimes meet, and the resulting
function — the **Airy function** — sits at the heart of optics, quantum
mechanics, and the theory of random matrices.

Airy's equation looks like it ought to be tame. After all, its right-hand side
is just "$x$ times $y$" — about as simple as a variable coefficient can be. So
here is a natural question, the kind a curious student might ask on first
meeting the equation:

> Is there a *polynomial* that solves Airy's equation?

A polynomial — something like $p(x) = 3x^4 - x + 7$ — is the friendliest kind
of function there is. It is built from a finite number of powers of $x$, it is
infinitely smooth, and we can differentiate it forever without leaving the
world of polynomials. Many famous differential equations have beautiful
polynomial solutions: Legendre's equation gives the Legendre polynomials,
Hermite's equation gives the Hermite polynomials, and so on. Could Airy's
equation hide a polynomial too?

The answer, it turns out, is a clean and total **no** — and the reason why is
a small gem of mathematical reasoning that requires nothing more than counting.

## Counting the degree

Every nonzero polynomial has a **degree**: the highest power of $x$ that
appears in it. The polynomial $3x^4 - x + 7$ has degree $4$; the constant $5$
has degree $0$. The degree is a kind of fingerprint, and it interacts with the
basic operations of algebra in completely predictable ways.

Two rules are all we need.

**Rule 1 — Multiplying by $x$ raises the degree by one.** If $p$ has degree
$n$, then $x \cdot p$ has degree $n+1$. Multiplying by $x$ shifts every term up
one power, so the top term $x^n$ becomes $x^{n+1}$. Nothing can cancel it.

**Rule 2 — Differentiating lowers the degree by (at least) one.** The
derivative of $x^n$ is $n\,x^{n-1}$, so taking a derivative knocks the degree
down by one. Differentiate *twice* and you lose at least two degrees: the
second derivative $p''$ has degree at most $n - 2$.

Now put the two sides of Airy's equation head to head. Suppose, for the sake of
argument, that some nonzero polynomial $p$ of degree $n$ satisfied $p'' = x\,p$.

* The **right-hand side**, $x \cdot p$, has degree $n + 1$ by Rule 1.
* The **left-hand side**, $p''$, has degree at most $n - 2$ by Rule 2.

But if two polynomials are equal, they must have the *same* degree. We would
need
$$ n + 1 \le n - 2, $$
which simplifies to $1 \le -2$. That is absurd. The right-hand side is always
*more* wiggly — higher degree — than the left-hand side can ever be. There is
no room for the two to meet.

The only escape hatch is the polynomial we quietly excluded at the start: the
**zero polynomial**, $p = 0$, which has no degree to compare and trivially
satisfies $0 = x \cdot 0$. And that is the whole story.

> **Theorem (No polynomial solutions of Airy's equation).** The only
> polynomial $p$ satisfying $p'' = x\,p$ is the zero polynomial $p = 0$.

What is striking is how little machinery the proof needs. No calculus of
limits, no infinite series, no clever substitution — just the observation that
multiplying by $x$ pushes a polynomial *up* the degree ladder while
differentiating pulls it *down*, and the two can never be reconciled.

## A second disguise: the Riccati form

Differential equations love disguises. A standard trick for studying a
second-order linear equation like Airy's is to look not at $y$ itself but at
the **logarithmic derivative** $u = y'/y$ — the relative rate at which $y$ is
growing. This substitution turns the linear equation into a *nonlinear* one
called a **Riccati equation**. For Airy's equation, the logarithmic-derivative
substitution produces

$$ u' + u^2 = x. $$

This is the same equation wearing a different costume. It is natural to ask the
same question of it: does the Riccati form admit a polynomial solution $u$? And
again the answer is a flat **no** — but now the degree-counting argument has a
small twist, because of that squared term $u^2$.

Suppose $u$ is a polynomial of degree $d$. We compare the degrees of the three
pieces.

* The term $u^2$ has degree $2d$, because squaring a polynomial doubles its
  degree.
* The term $u'$ has degree at most $d - 1$, one less than $u$.
* The right-hand side $x$ has degree exactly $1$.

Now split into two cases.

**Case 1: $u$ is a constant ($d = 0$).** Then $u'$ is zero and $u^2$ is a
constant, so the entire left-hand side $u' + u^2$ is a constant — degree $0$.
But the right-hand side $x$ has degree $1$. A constant can never equal $x$.
Contradiction.

**Case 2: $u$ has degree $d \ge 1$.** Now the squared term dominates
everything. Its degree $2d$ is at least $2$, and it strictly exceeds the degree
of $u'$ (which is at most $d-1 < 2d$). When you add a high-degree polynomial to
a strictly lower-degree one, the high degree survives — nothing cancels the top
term. So $u' + u^2$ has degree exactly $2d \ge 2$. But the right-hand side $x$
has degree $1$. Again the degrees cannot match.

Either way we reach a contradiction, and so:

> **Theorem (No polynomial solutions of the Riccati form).** There is no
> polynomial $u$ satisfying $u' + u^2 = x$.

Here there is not even a zero-polynomial escape hatch: the Riccati equation has
*no* polynomial solution whatsoever, not even the trivial one, because $0' +
0^2 = 0 \ne x$.

## Why this matters

It would be easy to dismiss these results as negative trivia — "this equation
doesn't have *that* kind of solution, so what?" But absence theorems are some
of the most useful tools in mathematics, precisely because they tell you where
*not* to look.

The Airy function genuinely exists; it is smooth, well-behaved, and central to
physics. What our two theorems prove is that this function lives *outside* the
cozy world of polynomials. No amount of algebraic cleverness — no finite
combination of powers of $x$ — will ever capture it. To write the Airy function
down you are forced into richer territory: infinite power series, integrals,
or special transcendental functions. The simplicity of the equation is a kind
of trap; its solutions are irreducibly more complicated than the equation that
defines them.

This is a recurring theme across mathematics and physics. The pendulum's exact
period cannot be written with elementary functions. The orbit of three
gravitating bodies has no closed-form solution. Time and again, a short,
innocent-looking equation turns out to demand answers that no finite formula
can express. The degree-counting proof for Airy's equation is a miniature,
fully rigorous instance of this phenomenon — and one you can verify with pencil
and paper in a single sitting.

## The shape of the argument

Step back and notice the architecture of both proofs, because the same skeleton
appears throughout the study of differential equations with polynomial
coefficients.

1. **Assume a polynomial solution exists**, and give its degree a name.
2. **Track how each operation moves the degree.** Multiplication by $x$ adds
   one; differentiation subtracts (at least) one; squaring doubles.
3. **Compare the two sides of the equation.** If they are forced to have
   different degrees, no such solution can exist.

This "degree bookkeeping" is a complete, self-contained method. It generalizes
immediately. Replace $x$ by any polynomial coefficient $q(x)$ of degree at
least one, and the equation $p'' = q\,p$ still has no nonzero polynomial
solution, by exactly the same imbalance: the right-hand side outpaces the left.
Push to higher derivatives, $p^{(k)} = x\,p$, and the gap only widens. The
single idea — *that some operations build polynomials up faster than others can
tear them down* — rules out an entire family of would-be solutions in one
stroke.

Airy set out to explain a band of light at the edge of a rainbow. Two hundred
years later, the equation he wrote down still rewards a fresh look — and one of
its secrets, that it can never be solved by a polynomial, turns out to rest on
nothing deeper than knowing how to count.
