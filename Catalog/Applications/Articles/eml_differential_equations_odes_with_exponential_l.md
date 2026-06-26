# The Equation That Refuses a Formula

## A rainbow, a telescope, and a stubborn little curve

If you have ever looked closely at the bright edge of a rainbow, or at the
fringe of light spilling past the rim of a shadow, you have seen the
fingerprints of a single mathematical object. Near a *caustic* — the place
where light rays pile up and focus — the brightness of light is governed by a
special function that wiggles on one side and fades smoothly to nothing on the
other. Astronomers meet the same curve when they sharpen a telescope; physicists
meet it at the turning point of a quantum particle, exactly where a ball would
roll back if the world were classical instead of quantum.

That curve is the **Airy function**, and it is the solution to one of the most
deceptively simple differential equations ever written down:

$$ y'' = x\,y. $$

In words: *the curvature of the graph at each point equals the height of the
graph times the horizontal position.* That is all. No exotic ingredients, no
hidden constants. And yet this equation hides a secret that took mathematicians
the better part of two centuries to fully articulate, and that we can now state
with complete precision: **Airy's equation has no solution that can be written
as a formula built from ordinary algebra.**

This article is about *why* — and about a clean, modern way to prove a sharp
version of that impossibility using nothing more sophisticated than counting the
degree of a polynomial.

## What "no formula" really means

We have to be careful. The Airy function certainly *exists*: you can compute it
to a billion decimal places, plot it, build a telescope around it. When we say
"no formula," we mean something specific and historically deep.

In the 1800s, Joseph Liouville asked a revolutionary question: which integrals
and which differential equations can be solved "in closed form" — using
polynomials, roots, exponentials, logarithms, and the four arithmetic
operations? He discovered that *most* cannot. The integral $\int e^{-x^2}\,dx$,
the engine of all of statistics, has no elementary antiderivative. It is not
that we have been too lazy to find one; it is that none exists, and this is a
*theorem*, as firm as the irrationality of $\sqrt{2}$.

Differential equations have their own version of this story, and it is even
richer. It is called **differential Galois theory**. Just as ordinary Galois
theory attaches a symmetry group to a polynomial equation and reads off whether
the roots can be expressed by radicals, differential Galois theory attaches a
symmetry group to a *differential* equation and reads off whether its solutions
can be expressed in elementary terms. For a second-order linear equation like
Airy's, there is even an explicit recipe — the **Kovacic algorithm** — that
takes the equation as input and decides, in finite time, whether a "nice"
(so-called *Liouvillian*) solution exists.

For Airy's equation, the verdict is: **no**. The Airy function is genuinely
new — it cannot be assembled from the classical toolkit. This article gives a
self-contained, rigorous proof of the crucial first and most decisive step of
that verdict.

## The trick that changes everything: Riccati's substitution

Here is the central idea, and it is beautiful. A second-order equation looks
hard because it talks about curvature ($y''$). But there is a classical change
of variables — due to the 18th-century Italian count Jacopo Riccati — that
trades the second-order *linear* equation for a first-order *nonlinear* one.

Set
$$ v = \frac{y'}{y}, $$
the *logarithmic derivative* of the unknown solution. If $y'' = q\,y$, then a
one-line computation with the quotient rule shows that $v$ satisfies the
**Riccati equation**
$$ v' + v^2 = q. $$

For Airy ($q = x$) this becomes
$$ v' + v^2 = x. $$

Why is this a good trade? Because of a fundamental principle of differential
Galois theory: the original linear equation has a "nice" (Liouvillian) solution
**only if** its Riccati equation has a solution that is *algebraic* — in the
simplest case, a **rational function**, a ratio of two polynomials. The hunt for
elementary solutions of a hard second-order equation collapses into the hunt for
a humble fraction $v = p/q$ solving a first-order equation. This is exactly the
reducible-case test at the heart of the Kovacic algorithm.

So the whole question — *can the rainbow's curve be written as a formula?* —
funnels down to a single sharp puzzle:

> **Is there a rational function $v = p/q$ with $v' + v^2 = x$?**

If the answer is no, the most important door to an elementary solution is shut.

## Clearing the fraction

Fractions are awkward to reason about, so we clear them. Suppose $v = p/q$ with
polynomials $p, q$ and $q \neq 0$. The quotient rule gives
$$ v' = \frac{p'q - p q'}{q^2}, \qquad v^2 = \frac{p^2}{q^2}. $$
Substituting into $v' + v^2 = x$ and multiplying through by $q^2$ turns the
rational equation into a pristine **polynomial identity**:
$$ p'\,q - p\,q' + p^2 = x\,q^2. $$

Every term here is an honest polynomial. The fractions are gone. A rational
solution of Airy's Riccati equation exists *if and only if* there are
polynomials $p, q$ (with $q \neq 0$) making this identity true. We have turned a
question about calculus into a question about algebra — and algebra we can win by
counting.

## The proof is parity

Here is the entire argument, and the wonderful thing is that you can follow it
with no machinery beyond the **degree** of a polynomial — the highest power of
$x$ that appears. Write $\deg p$ and $\deg q$ for these degrees. Recall two
schoolbook facts: the degree of a product adds ($\deg(fg) = \deg f + \deg g$),
and differentiation *lowers* degree by one.

Look at the right-hand side, $x\,q^2$. Its degree is
$$ \deg(x\,q^2) = 1 + 2\deg q, $$
which is **odd** — an even number $2\deg q$ plus one. That single observation is
the seed of the whole impossibility. Now we examine the left-hand side and show
it can *never* be odd of the right size.

The left-hand side has two pieces. The square $p^2$ has degree $2\deg p$,
always **even**. The cross term $p'q - p q'$ — a "Wronskian-like" combination —
is the interesting one. Naively it looks like it should have degree
$\deg p + \deg q$. But here is a small gem we prove along the way:

> **The cross term drops a degree.** For any polynomials $p$ and $q$,
> $$ \deg\!\big(p'q - p q'\big) \le \deg p + \deg q - 1. $$

The leading terms of $p'q$ and $p q'$ are designed to cancel — exactly the
phenomenon that makes the classical *Wronskian* of two solutions degenerate.
(In the Lean formalization this is the lemma `natDegree_wronskianLike_le`.)

With that in hand the case analysis is short and decisive:

**Case 1: $\deg p \ge \deg q$.** Then the square $p^2$ (degree $2\deg p$) sits
*above* the cross term (degree at most $\deg p + \deg q - 1 \le 2\deg p - 1$), so
the whole left side has degree exactly $2\deg p$ — even. But it must equal the
right side, of degree $1 + 2\deg q$ — odd. An even number cannot equal an odd
number. Contradiction.

**Case 2: $\deg p < \deg q$.** Now $p^2$ has degree $2\deg p \le 2\deg q - 2$,
and the cross term has degree at most $\deg p + \deg q - 1 \le 2\deg q - 2$. So
the entire left side has degree at most $2\deg q - 2$ — but the right side has
degree $1 + 2\deg q$, which is at least two larger. The two sides cannot match.
Contradiction.

Either way, no polynomials $p, q$ exist. The fraction we sought does not exist.
**Airy's Riccati equation has no rational solution.** (This is the theorem
`no_rational_solves_riccati_airy`.)

That is the whole proof. No pole counting, no residues, no heavy differential
algebra — just the parity of an exponent. And it is rigorous: every step has
been checked by machine.

## The result is bigger than Airy

Notice what the argument actually used about the right-hand side $q = x$: only
that its degree, $1$, is **odd**. Nothing about Airy in particular. So the same
two-line parity dichotomy proves a sweeping generalization:

> **The odd-degree obstruction.** Let $f$ be *any* polynomial of odd degree.
> Then the Riccati equation $v' + v^2 = f$ has no rational solution; equivalently,
> the cleared identity $p'q - pq' + p^2 = f\,q^2$ has no solution with $q \neq 0$.

(In Lean this is `no_rational_solves_riccati_odd_deg`, and Airy is the special
case $f = x$.) Translated back through Riccati's substitution, this says: for an
entire infinite family of equations $y'' = f\,y$ with $\deg f$ odd — $y''=xy$,
$y''=x^3y$, $y'' = (x^5 - x)y$, and so on — the reducible-case test of the
Kovacic algorithm *always fails*. The most accessible route to an elementary
solution is closed for all of them at once.

The odd-degree hypothesis is not a technicality we failed to remove; it is
*load-bearing*. For $f = x^2$, degree two and **even**, the parity clash
disappears, and indeed such equations *can* have rational Riccati solutions. The
boundary between solvable and unsolvable runs exactly along the parity of the
degree. That is the kind of clean dividing line mathematicians dream of.

## A tower of barriers

It helps to see where this fits. The impossibility of solving Airy's equation in
closed form is established by a tower of increasingly strong obstructions, each
ruling out a larger class of would-be solutions:

1. **The polynomial barrier.** No nonzero polynomial $p$ can satisfy $p'' = x p$.
   The reason is a blunt degree mismatch: differentiating twice *lowers* degree,
   while multiplying by $x$ *raises* it, so $p''$ is always too small to equal
   $x p$. (In Lean: `no_poly_solves_airy`, and more generally
   `no_poly_solves_second_order_pos_deg` for any coefficient of positive degree.)

2. **The rational Riccati barrier** — the new result of this work. Even allowing
   *fractions* of polynomials as candidate logarithmic derivatives, the parity
   argument above shuts the door. This is genuinely stronger than the polynomial
   layer, and it is the true Galois-theoretic step, because rational solutions of
   the Riccati equation are exactly what the Kovacic algorithm searches for.

3. **The abstract differential-field layer.** Above both sits the structural
   fact, true in any differential field, that the Wronskian of two solutions of
   $y'' = a y$ has zero derivative — the polynomial echo of Abel's classical
   identity. (In Lean: `poly_wronskian_derivative_zero`.) It is what guarantees
   the solution space is only two-dimensional and frames the Galois group as a
   group of $2 \times 2$ matrices.

The combined first step — *no polynomial solution and no rational Riccati
solution* — is bundled together in the single statement
`airy_no_poly_and_no_rational_riccati`, the formal certificate that the two most
elementary doors to a closed-form Airy function are both locked.

## Why this is worth caring about

It would be easy to file this under "abstract curiosities," but the Airy function
is one of the most practically important special functions in all of applied
mathematics. It describes:

- the **intensity of light** at a caustic, the optics of rainbows and the
  shimmer at the edge of shadows;
- the wavefunction of a **quantum particle near a turning point**, the bedrock
  of the WKB approximation in quantum mechanics;
- the diffraction pattern at the edge of a **telescope aperture**;
- the statistics of the largest eigenvalue of huge random matrices — the
  **Tracy–Widom distribution** that governs everything from the heights of
  randomly growing interfaces to fluctuations in number theory.

Every time an engineer or physicist reaches for the Airy function, they are
reaching for something that *provably has no elementary formula*. Understanding
*why* — knowing that the obstruction is as simple and as unbreakable as the
parity of a single integer — is what turns "we couldn't find a formula" into "no
formula can exist." That distinction is the whole difference between ignorance
and knowledge.

## The shape of an impossibility

There is a quiet aesthetic lesson here. Impossibility proofs are often imagined
as forbidding, technical fortresses. But the best of them have the opposite
character: they reveal that the obstruction was something almost embarrassingly
simple, hiding in plain sight. You cannot square the circle because $\pi$ is
transcendental. You cannot solve the general quintic by radicals because a
certain group is not solvable. And you cannot write the Airy function as an
elementary formula because — at the very first and most important step — an even
number cannot equal an odd number.

The next time you see the bright fringe of a rainbow, you can know two things at
once: that the curve of its brightness is computed by a function science cannot
do without, and that this function is, in the most precise sense, *irreducibly
new* — a stranger that no amount of algebra will ever tame. The proof of its
strangeness fits in a paragraph, and it comes down to counting.
