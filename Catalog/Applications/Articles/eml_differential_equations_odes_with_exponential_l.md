# The Symmetry Hidden Inside a Differential Equation

## Why some equations refuse to be solved

In 1830, a young George Biddell Airy was studying the way light bends around the
edge of a shadow — the faint rainbow fringes you can sometimes see at the border
of a sharp shadow on a sunny day. To describe the brightness of those fringes he
wrote down what looks like one of the simplest differential equations
imaginable:

$$ y'' = x\,y. $$

In words: the curvature of a function at each point $x$ equals the function's own
value, multiplied by $x$. It is shorter than the equation for a swinging pendulum.
And yet, almost two centuries later, there is still no way to write its solution
using the everyday toolkit of mathematics — no finite combination of powers,
roots, exponentials, logarithms, sines, and cosines will ever reproduce the
*Airy function*. It is, in a precise and provable sense, a genuinely new function,
not reducible to the ones we already knew.

How could anyone *prove* such a thing? How do you show that no formula exists,
when there are infinitely many formulas you might try? The answer is one of the
most beautiful ideas in mathematics: when you cannot solve an equation, study its
*symmetries* instead. This is the story of **differential Galois theory**, and of
a recent effort to rebuild its core machinery from the ground up — clean enough
that every step can be checked with complete certainty.

## A two-century-old trick: trade solving for symmetry

The strategy goes back to Évariste Galois, who died in a duel at age twenty after
revolutionizing algebra in a single feverish night of writing. Galois was looking
at ordinary polynomial equations — things like $x^5 - 6x + 3 = 0$ — and asking
the famous question: can the roots be written using only $+,-,\times,\div$ and
$n$-th roots? His insight was to stop staring at the roots and instead look at how
they can be *shuffled*. Each equation carries a group of symmetries permuting its
solutions, and the equation is solvable by radicals exactly when that group is
"built from simple abelian pieces." For the general fifth-degree equation the
symmetry group is too tangled, and so no formula can exist.

In the early twentieth century, Émile Picard and Ernest Vessiot transplanted this
idea from algebraic equations to *differential* equations. Instead of permuting a
finite set of roots, the symmetry group of a linear differential equation acts on
its (finite-dimensional) space of solutions by linear transformations. The
equation can be solved in "closed form" — using exponentials, integrals, and
algebraic functions, the so-called **Liouvillian** functions — exactly when this
*differential Galois group* is solvable in the group-theoretic sense.

For our story the relevant closed-form world is what we will call the **EML
functions**: everything you can build from the rational functions by repeatedly
taking **E**xponentials, **L**ogarithms, and **M**ultiplicative/algebraic
combinations. Airy's equation has no EML solution. The differential Galois group
of Airy's equation turns out to be as large and as un-solvable as it possibly can
be (it is the full group $\mathrm{SL}_2$), and that single fact is the modern
explanation for why no elementary formula will ever capture the rainbow fringes.

## Where do the symmetries live? The field of constants

To make any of this rigorous you first have to answer a deceptively simple
question: *symmetries over what?* In ordinary Galois theory the symmetries fix the
base number field — the rational numbers, say. In the differential world the
analogue of "the numbers that don't move" is the **field of constants**: the
elements whose derivative is zero.

Write $a'$ for the derivative of $a$. A *differential field* is just a field — a
system where you can add, subtract, multiply, and divide — equipped with a
derivative operation obeying the usual rules:

$$ (a+b)' = a' + b', \qquad (ab)' = a'b + ab'. $$

Inside any such field, look at the set of all elements with vanishing derivative:

$$ C = \{\, x : x' = 0 \,\}. $$

The first foundational result is that **$C$ is itself a field** — a self-contained
number system sitting inside the bigger one. This is not obvious. You have to check
that if $x$ and $y$ are constant then so are $x+y$, $xy$, $-x$, and crucially
$1/x$. The sum and product follow straight from the rules above. The inverse takes
the quotient rule: from $(1/x)' = -x'/x^2$ you see that if $x' = 0$ then $1/x$ is
constant too. We call this object the **constants subfield**, and it is the stage
on which the entire drama plays out: the differential Galois group is a group of
matrices *with entries in the constants*, and it fixes every constant.

This is the bedrock. Everything else is about how those constants act.

## The simplest symmetry: ratios that can't change

Start with the easiest possible differential equation, the first-order linear one:

$$ y' = a\,y. $$

Over the real numbers its solution is the exponential $y = e^{\int a}$, and any two
solutions differ only by an overall scale. The abstract, formula-free way to say
"differ only by a scale" is striking:

> **If $y_1$ and $y_2$ both satisfy $y' = a\,y$, and $y_2 \neq 0$, then their ratio
> $y_1/y_2$ is a constant.**

The proof is a single application of the quotient rule. The derivative of
$y_1/y_2$ is
$$ \left(\frac{y_1}{y_2}\right)' = \frac{y_1' y_2 - y_1 y_2'}{y_2^2}
   = \frac{(a y_1) y_2 - y_1 (a y_2)}{y_2^2} = 0. $$
The two copies of $a$ cancel perfectly, and the ratio freezes into a constant.

Why does this matter? Because it pins down the symmetry group of a first-order
equation completely. The solution space is a single line — all multiples of one
solution — and the only thing a symmetry can do is rescale that line by a nonzero
constant. So the differential Galois group of $y' = a y$ sits inside the
**multiplicative group of constants**, the simplest possible kind of symmetry
group. In the slogan of this project, it is the prototypical *EML group*: an
honest, tractable, abelian symmetry. First-order EML equations are always solvable,
and this little cancellation is the reason.

## Climbing to second order: a stage built from constants

Airy's equation is *second* order, and second order is where the difficulty — and
all the interesting symmetry — lives. The relevant family is

$$ y'' = a\,y, $$

with no first-derivative term (every second-order linear equation can be massaged
into this shape). Here the solution space is two-dimensional, and the symmetry
group is a group of $2 \times 2$ matrices.

Two further facts turn that vague picture into a precise structure. First,
**scaling preserves solutions**: if $y$ solves $y'' = a y$ and $c$ is a constant,
then $c\,y$ solves it too. The computation is short — because $c' = 0$, the
constant slides straight through both derivatives:
$$ (c y)'' = c\,y'' = c\,(a y) = a\,(c y). $$
Second, **sums of solutions are solutions**: if $y_1$ and $y_2$ both solve the
equation, so does $y_1 + y_2$, because differentiation is linear. Put together,
these say the solution set is a **vector space over the field of constants** — a
genuine two-dimensional plane on which the Galois group acts linearly. The
abstract algebra has reproduced, with no mention of real numbers or analysis, the
familiar fact that solutions of a linear ODE can be freely added and rescaled.

## The Wronskian: a constant that detects independence

How do you know whether two solutions are *genuinely different* — whether they
really span the two-dimensional plane, or are secretly just multiples of each
other? The classical answer is a single number called the **Wronskian**:

$$ W = y_1\,y_2' - y_2\,y_1'. $$

It measures the "area" spanned by the two solutions and their slopes. Two
remarkable things are true about it, and both fall out of the algebra.

If $y_1$ and $y_2$ are **dependent** — say $y_2 = c\,y_1$ for some constant $c$ —
then the Wronskian is exactly zero:
$$ y_1\,(c y_1)' - (c y_1)\,y_1' = c\,y_1 y_1' - c\,y_1 y_1' = 0. $$
A vanishing Wronskian is the algebraic fingerprint of linear dependence.

And if $y_1, y_2$ are honest solutions of $y'' = a y$, then their Wronskian is
**always a constant** — it never changes as $x$ varies. This is a version of a
classical result called *Abel's identity*, and the proof is again one line:
$$ W' = y_1' y_2' + y_1 y_2'' - y_2' y_1' - y_2 y_1''
      = y_1 (a y_2) - y_2 (a y_1) = 0. $$
The cross terms cancel; the curvature terms cancel; nothing is left. So the
Wronskian is a constant — an element of that base field $C$ we built at the start.
This is precisely the statement that the differential Galois group preserves a
volume: it lives inside the matrices of *constant determinant*. The symmetry group
of a second-order equation is therefore a subgroup of $\mathrm{SL}_2$ (up to a
scalar) over the constants. The abstract machinery has located the group with
surgical precision.

## The decisive move: from second order down to first

We now have the stage and the actors. The final ingredient is the trick that lets
us actually *decide* whether Airy's equation can be solved. It is called the
**Riccati transform**, and it is the engine of the celebrated **Kovacic
algorithm**.

The idea is to study not the solution $y$ itself, but its *logarithmic
derivative*,
$$ v = \frac{y'}{y}. $$
A short computation with the quotient rule shows that whenever $y'' = a y$, this
new quantity $v$ satisfies a *first-order* — but *nonlinear* — equation:
$$ v' + v^2 = a. $$
This is the **Riccati equation**. We have traded a linear second-order problem for
a quadratic first-order one. The payoff is enormous: a deep theorem of
differential Galois theory says the original equation has a Liouvillian (EML)
solution **only if** this Riccati equation has a solution that is an *algebraic
function* — and the first and easiest case to rule out is a *rational* solution,
an honest ratio of polynomials $v = p/q$.

So the whole impossibility question collapses to: **does $v' + v^2 = a$ have a
rational solution?** For Airy, $a = x$, and the question becomes whether
$$ v' + v^2 = x $$
can be solved by any ratio of polynomials at all.

## Counting degrees, catching a parity

Here is where the proof becomes almost magical in its simplicity. Suppose
$v = p/q$ were a rational solution, with $p, q$ polynomials and $q \neq 0$.
Multiply the Riccati equation through by $q^2$ to clear denominators, and it
becomes a clean polynomial identity:
$$ p'q - p q' + p^2 = a\,q^2. $$

Now just count degrees. The right-hand side has degree $\deg a + 2\deg q$. On the
left, the term $p^2$ has the *even* degree $2\deg p$, while the "Wronskian-like"
combination $p'q - pq'$ has degree at most $\deg p + \deg q - 1$ — one less than a
naive product, because differentiation lowers degree.

Two cases. If $p$ is at least as big as $q$, the $p^2$ term dominates everything,
and matching degrees forces
$$ \deg a + 2\deg q = 2\deg p, \quad\text{so}\quad \deg a = 2(\deg p - \deg q), $$
an **even** number. If instead $p$ is smaller than $q$, the entire left-hand side
has degree at most $2\deg q - 2$, which is strictly *less* than the right-hand
side's degree of at least $2\deg q + 1$ — so the equation can never balance.

The conclusion is stark: **a rational solution can exist only when $\deg a$ is
even.** For Airy's equation $a = x$ has degree $1$ — odd. The parity is wrong. No
rational solution exists, the first step of the Kovacic algorithm fails, and Airy's
equation is locked out of the EML world forever.

What makes this argument so satisfying is what it *doesn't* need. There is no
delicate analysis of poles, no requirement that $p$ and $q$ be coprime, no appeal
to the special nature of the Airy function. It is a pure parity argument — the
same flavour as "an odd number can never be twice a whole number" — and it
generalizes instantly: **every equation $y'' = f\,y$ with $f$ of odd degree is
immune to rational Riccati solutions**, and so resists elementary solution. Airy
is merely the smallest, most famous member of an infinite family.

## What the parity argument can and cannot see

Honesty compels a caveat, and it is an interesting one. The degree–parity test is
a one-way street. *Odd* degree guarantees there is no rational solution. *Even*
degree merely means the parity obstruction is silent — it does not promise a
solution exists. For example, the equation behind $y = e^{x^2/2}$ has coefficient
$f = x^2 + 1$ of even degree $2$, and it genuinely does have the rational Riccati
solution $v = x$ (you can check: $v' + v^2 = 1 + x^2 = f$). But other even-degree
coefficients, like $x^4$, sit in a murkier regime where finer information — the
*leading coefficients*, not just the degrees — must be brought in. The frontier of
this little theory is exactly there: a complete, computable criterion for the even
case. The odd case, however, is closed: clean, total, and certain.

## Why build it this way?

You might wonder why anyone would rebuild a nineteenth-century theory so
carefully, separating it into a field of constants, a one-line ratio lemma, a
scaling lemma, a Wronskian lemma, a Riccati transform, and a degree count. The
reason is that this is exactly the skeleton a *machine* can verify. Each piece is
small, each is provable from the axioms of a differential field alone — no real
numbers, no analysis, no hidden assumptions about algebraic closure or
characteristic. The constants form a field; ratios of first-order solutions
freeze; second-order solutions form a plane over the constants; the Wronskian is a
constant determinant; the Riccati transform drops the order; and a parity count
finishes Airy. Stripped to its logical bones, the impossibility of solving Airy's
equation is not a deep mystery at all — it is a sequence of cancellations, each
forced by the product rule, ending in a clash between an even number and an odd
one.

That, in the end, is the quiet power of the Galois viewpoint. Faced with an
equation we cannot solve, we did not solve it. We asked what symmetries it
permits, discovered they live in a field of constants, watched those symmetries
act on a two-dimensional plane, traded the equation for its logarithmic
derivative, and counted to two. The rainbow fringes at the edge of a shadow are
described by a function with no formula — and now we can say exactly, and
provably, why.
