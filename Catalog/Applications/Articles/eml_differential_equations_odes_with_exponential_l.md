# When an Equation Refuses to Be Solved: The Hidden Algebra of Airy's Curve

## A puzzle from a rainbow

In 1838 the British astronomer George Biddell Airy was trying to understand
something everyone has seen but few have explained: the bright and dark bands
that fringe a rainbow. To capture how light intensity rises and falls near the
edge of a caustic, he wrote down a deceptively simple differential equation,

$$ y'' = x\,y. $$

In words: the curvature of the function $y$ at any point $x$ equals the value of
the function multiplied by $x$ itself. It looks like the kind of thing a first
course in calculus should dispatch in an afternoon. It is not. No combination of
the functions we learn in school — polynomials, exponentials, sines, cosines,
logarithms, roots, or any finite recipe built from them — solves it. Airy's
equation defines genuinely *new* functions, the Airy functions $\mathrm{Ai}(x)$
and $\mathrm{Bi}(x)$, which cannot be written in closed form.

This article is about a remarkable fact and the algebra that explains it: the
question "can this differential equation be solved in elementary terms?" is not
a matter of cleverness or patience. It is a **structural** question with a
definite yes-or-no answer, decidable by an algorithm, and rooted in a beautiful
correspondence between *multiplying functions* and *adding their exponents*. The
same machinery that proves Airy's equation has no elementary solution also
*decides*, for a whole family of equations, exactly which ones do.

We call the relevant class of functions **EML** — exponential, multiplicative,
logarithmic — the functions you can assemble from exponentials, logarithms, and
algebraic operations. The central drama is a tug-of-war between two equations
that are secretly the same problem wearing different clothes.

## The logarithm's superpower: turning products into sums

Everything begins with a single, almost childish observation. The logarithm
converts multiplication into addition:

$$ \log(yz) = \log y + \log z. $$

Differentiate both sides and you get the **logarithmic derivative**, the quantity
$L(y) = y'/y$. The product rule then hands you a clean homomorphism law,

$$ \frac{(yz)'}{yz} = \frac{y'}{y} + \frac{z'}{z}, \qquad\text{i.e.}\qquad L(yz) = L(y) + L(z). $$

This is the seed crystal of the entire theory. The map $L$ takes the
*multiplicative* world of nonzero functions and lands it in the *additive* world
of their coefficients. It also respects division and powers:

$$ L(y/z) = L(y) - L(z), \qquad L(y^{-1}) = -L(y), \qquad L(y^{n}) = n\,L(y). $$

The last identity — that the logarithmic derivative of an $n$-th power is just
$n$ times the original — is the homomorphism iterated, and it holds for every
integer power $n$, positive or negative.

Why does this matter for differential equations? Consider the simplest linear
equation, the first-order one:

$$ y' = a\,y. $$

Dividing by $y$ rewrites it as $L(y) = a$. So **solving $y' = a\,y$ is the same
as finding a function whose logarithmic derivative is $a$** — the abstract
shadow of $y = e^{\int a}$. The homomorphism law immediately tells you something
powerful about superposition. If $y' = a\,y$ and $z' = b\,z$, then the product
solves

$$ (yz)' = (a+b)\,(yz). $$

Multiplying solutions *adds* their coefficients. This is the algebraic heart of
why $e^{A}\cdot e^{B} = e^{A+B}$. And it scales without limit: for any finite
family of solutions $y_i' = a_i\, y_i$, their product solves the equation with
the *summed* coefficient,

$$ \Big(\prod_i y_i\Big)' = \Big(\sum_i a_i\Big)\,\prod_i y_i, $$

the abstract content of $\prod e^{\int a_i} = e^{\sum \int a_i}$. This finite
superposition law is one of the formally verified results behind this article.

## Constants, ratios, and the shape of the solution set

If multiplication adds coefficients, what corresponds to *zero* coefficient? A
function with $L(y) = 0$ is one whose derivative vanishes: a **constant**. The
constants form the kernel of the homomorphism, and they are the bedrock on which
the whole symmetry theory rests. They form a self-contained number system — a
*subfield* — closed under addition, multiplication, subtraction, and division:
if $c' = 0$ and $d' = 0$, then so are $(c+d)'$, $(cd)'$, $(c^{-1})'$, and so on.

This has an immediate and elegant consequence. Suppose $y_1$ and $y_2$ both
solve $y' = a\,y$. Then their ratio has logarithmic derivative
$L(y_1) - L(y_2) = a - a = 0$, so

$$ \left(\frac{y_1}{y_2}\right)' = 0. $$

**The ratio of any two solutions is a constant.** Concretely: any two nonzero
solutions of $y' = a\,y$ differ only by multiplication by a nonzero constant. If
you know one solution, you know them all — they fill out a single
one-dimensional line, and the "symmetries" of that line are exactly
multiplication by nonzero constants. In the language of differential Galois
theory, the symmetry group of a first-order EML equation is a subgroup of the
**multiplicative group of nonzero constants** — the simplest possible
"EML group." The solution set is what algebraists call a *torsor*: a fixed
solution $y_1$ generates every other solution $y_2$ as $y_2 = c\,y_1$ for a
unique nonzero constant $c$, and conversely every such multiple is again a
solution.

This is the "easy" case, and it always works out: first-order linear EML
equations *always* exponentiate. The trouble — and the interest — begins one
order up.

## Second order, and the Riccati gambit

A second-order linear equation in *normal form* (no first-derivative term) looks
like

$$ y'' = a\,y. $$

Airy's equation is exactly this, with $a = x$. Now there is generally a
two-dimensional space of solutions, and a single number — the **Wronskian** —
governs whether two given solutions are genuinely independent:

$$ W(y_1, y_2) = y_1\,y_2' - y_2\,y_1'. $$

A foundational fact, the abstract form of **Abel's identity**, is that when
$y_1$ and $y_2$ both solve $y'' = a\,y$, their Wronskian is a *constant*:

$$ W(y_1,y_2)' = 0. $$

Moreover the Wronskian is a perfect detector of dependence. If $y_1$ and $y_2$
are linearly dependent over the constants — meaning some nontrivial constant
combination $c_1 y_1 + c_2 y_2$ vanishes — then $W = 0$. Conversely, a nonzero
Wronskian certifies that the two solutions are independent, and for genuine
solutions a nonzero Wronskian is automatically a *nonzero constant*: a true
"fundamental system" of the equation. This holds in any setting whatsoever, with
no reference to solving the equation — it is pure algebra.

So how do we attack $y'' = a\,y$? With a change of variable so natural it feels
like cheating. Take the logarithmic derivative again, $v = y'/y$. A short
computation with the product and quotient rules gives

$$ v' + v^2 = \frac{y''}{y}. $$

If $y$ solves $y'' = a\,y$, the right-hand side is just $a$, and we land on the
**Riccati equation**

$$ v' + v^2 = a. $$

This is the master move of the whole subject. It trades a *linear* second-order
equation for a *quadratic* first-order one. A second-order linear equation has an
elementary solution precisely when this first-order quadratic equation has a
sufficiently nice (rational) solution. The **Kovacic algorithm** — the decision
procedure that answers "does this equation have a closed-form solution?" — runs
on exactly this reformulation.

## Why Airy must fail: a parity argument

Now we can see, with our own eyes, why Airy's equation is unsolvable in
elementary terms. The Riccati equation for Airy is

$$ v' + v^2 = x. $$

Suppose, hoping for a contradiction, that it had a rational solution $v = p/q$,
a ratio of two polynomials with $q \neq 0$. Multiply through by $q^2$ to clear
denominators. Using $v' = (p'q - pq')/q^2$ and $v^2 = p^2/q^2$, the equation
becomes a clean polynomial identity:

$$ p'\,q - p\,q' + p^2 = x\,q^2. $$

Everything now lives inside the polynomial ring, where the only tool we need is
**degree counting** — and the answer turns on a parity. Look at the degrees:

- The right-hand side $x\,q^2$ has degree $1 + 2\deg q$, which is **odd**.
- On the left, the "Wronskian-like" piece $p'q - pq'$ has degree at most
  $\deg p + \deg q - 1$ (differentiation drops a degree). The square $p^2$ has
  the **even** degree $2\deg p$.

Two cases. If $\deg p \ge \deg q$, the $p^2$ term dominates, and the left side has
degree exactly $2\deg p$ — an *even* number. It cannot equal the odd degree of
the right side. If instead $\deg p < \deg q$, the entire left side has degree at
most $2\deg q - 2$, strictly *below* the right side's degree of $2\deg q + 1$.
Either way, the equation is impossible. There is **no rational solution**.

This is the formally verified theorem
`no_rational_solves_riccati_airy`: there are no polynomials $p, q$ with $q \neq 0$
satisfying $p'q - pq' + p^2 = x\,q^2$. It is the genuinely Galois-theoretic step
that closes the door on Airy. (There is a cruder warm-up, too: a direct degree
mismatch shows no nonzero *polynomial* can satisfy $y'' = x\,y$ at all, since
$y''$ has lower degree than $x\,y$. Both obstructions are proved.)

What makes the argument satisfying is that it is *parity*, not delicate analysis.
The reason Airy resists is, at bottom, that $1$ is an odd number.

## The decision rule, and why it is sharp

Here is where the story turns from "one stubborn equation" into "a theorem about
a whole family." The parity argument never used anything special about $x$ beyond
its degree being odd. Replace $x$ by any polynomial $f$ of **odd degree**, and
the identical degree-counting argument shows the Riccati equation
$v' + v^2 = f$ has no rational solution. In particular the entire **generalized
Airy family**

$$ y'' = x^{2k+1}\,y, \qquad k = 0, 1, 2, \dots $$

is obstructed, with ordinary Airy as the case $k = 0$. This is the verified
result `no_rational_riccati_genAiry`.

So we have a candidate decision rule: *if $\deg f$ is odd, the equation is
obstructed.* Is the rule tight? Could we relax "odd" to something weaker? The
answer is no, and the proof is a single counterexample that lands right on the
boundary. Take the **even**-degree coefficient $f = x^2 + 1$. Then the Riccati
equation

$$ v' + v^2 = x^2 + 1 $$

*does* have a solution — and a stunningly simple one. Try $v = x$: then
$v' + v^2 = 1 + x^2$, exactly $f$. This polynomial solution is the verified
witness `riccati_evenDeg_solvable`. And it is not an algebraic accident: $v = x$
is the logarithmic derivative of $y = e^{x^2/2}$, which genuinely solves
$y'' = (x^2 + 1)\,y$. The even-degree equation is honestly EML-solvable, with an
exponential in closed form.

Putting the two halves together gives the **sharpness theorem**
`kovacic_parity_decision_sharp`: across this family, every odd-degree coefficient
is obstructed while the even-degree example $x^2+1$ is solvable. The parity test
is a *correct two-sided decision* — it says "no" exactly when the answer provably
is no, and the boundary case proves the criterion cannot be loosened. We have
not merely shown one equation fails; we have drawn the precise line between the
solvable and the unsolvable.

## What the algebra is really telling us

Step back and the shape of the theory is striking. A single homomorphism — the
logarithmic derivative carrying products to sums — organizes everything:

- **First order** ($y' = a\,y$): solutions are a coset of the constants; the
  symmetry group is the multiplicative group of nonzero constants; products add
  coefficients. These equations always exponentiate.
- **Second order** ($y'' = a\,y$): the Wronskian, a constant, measures
  independence; the Riccati substitution $v = y'/y$ collapses the linear
  second-order problem into a quadratic first-order one.
- **Decidability**: whether the second-order equation has an elementary solution
  becomes a question about rational solutions of the Riccati equation — and for
  rich families that question is settled by a degree-parity count.

The deeper moral is one of the most beautiful in mathematics: *solvability is a
symmetry property.* Just as Évariste Galois showed that a polynomial equation can
be solved by radicals exactly when its symmetry group is "solvable," the
differential Galois theory pioneered by Picard and Vessiot shows that a
differential equation can be solved in elementary terms exactly when *its*
symmetry group has the right structure. For first-order EML equations the group
is as simple as possible — the multiplicative constants — and they always solve.
For Airy, the symmetry group is too large to be elementary, and the obstruction
manifests, concretely, as the impossibility of an odd number being even.

## The view from the bridge

It is worth dwelling on the bridge that makes all of this work, because it is the
same bridge that appears again and again across mathematics: the translation
between the *multiplicative* and the *additive*. Logarithms invented it for
arithmetic, turning the labor of multiplication into the ease of addition and
powering three centuries of computation by slide rule and log table. Here, the
very same idea — that $y'/y$ converts products into sums — is what lets us
analyze differential equations by linear algebra over a field of constants, count
degrees, and read off solvability from a parity.

Airy's little equation, born from the desire to explain the soft fringes of a
rainbow, turns out to be a gateway to one of the grand unifying themes of modern
algebra. It cannot be solved by elementary functions, and that is not a failure
of ingenuity but a theorem — provable, sharp, and, in the end, surprisingly
simple. The next time you see the faint supernumerary bands inside a rainbow, you
are looking at a function that no finite formula can name, kept forever out of
elementary reach by the stubborn fact that one is odd.
