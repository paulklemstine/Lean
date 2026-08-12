# The Knot That Knows Your Secret Number

## A tangle of rope, a product of two primes, and the thin line between "encoded" and "computable"

Take a long piece of rope. Wind it around a doughnut — a torus — so that it travels
$a$ times the long way around and $b$ times through the hole, then splice the ends
together. If $a$ and $b$ share no common factor, what you get is a genuine knot: the
**torus knot** $T(a,b)$. The trefoil, the first knot anyone learns to draw, is
$T(2,3)$. Wind a little more energetically and you get $T(2,143)$ — a rope that coils
one hundred forty-three times around a doughnut.

Here is the strange fact that this article is about. That rope, considered purely as a
tangled loop in space, *knows* that $143 = 11 \times 13$. The information is not
hidden in some metaphorical sense. It is sitting in plain sight in the knot's most
classical algebraic invariant, in a form so explicit you can point at it: three numbers,
$10$, $12$, and $120$, from which the primes $11$ and $13$ fall out by high-school
algebra.

And here is the catch, which is just as interesting: reading those three numbers off the
rope costs more work than factoring $143$ by trial division. Much more. The knot is an
honest, faithful, *provably complete* encoding of the arithmetic — and an utterly
useless one for computation. This article is about why both halves of that sentence are
true, and about the surprisingly rich mathematics that lives in the gap between them.

---

## The polynomial attached to a knot

Every knot carries a polynomial, discovered by James Waddell Alexander in 1928. You can
compute it from a picture of the knot by a purely combinatorial recipe, and — this is
the point — two pictures of the *same* knot always give the same polynomial. It is an
invariant: a numerical fingerprint that cannot tell the difference between a knot and
itself, but often can tell the difference between two different knots.

For torus knots the fingerprint has a beautiful closed form. Write $\Delta_{a,b}(X)$
for the Alexander polynomial of $T(a,b)$. Then

$$\Delta_{a,b}(X) \;=\; \frac{(X^{ab}-1)(X-1)}{(X^{a}-1)(X^{b}-1)}.$$

For the trefoil $T(2,3)$ this is $\frac{(X^6-1)(X-1)}{(X^2-1)(X^3-1)} = X^2 - X + 1$,
the familiar answer. In general the fraction always simplifies to an honest polynomial,
of degree $(a-1)(b-1)$ — twice the *genus* of the knot, the minimal number of handles
on a surface whose boundary is the rope.

The family that matters for arithmetic is $a = 2$. For odd $N$, the knot $T(2,N)$ is the
$(2,N)$ *torus knot*, the rope that twists $N$ times around a pair of strands, and its
polynomial collapses to

$$A_N(X) \;=\; \frac{X^N+1}{X+1} \;=\; X^{N-1} - X^{N-2} + X^{N-3} - \cdots + 1,$$

the alternating polynomial with $N$ terms.

## Where the factorization is hiding

The magic happens when you factor $A_N$ into irreducible pieces over the rational
numbers. Recall the **cyclotomic polynomials** $\Phi_d(X)$: $\Phi_d$ is the minimal
polynomial of a primitive $d$-th root of unity, it has integer coefficients, it is
irreducible, and its degree is Euler's totient $\varphi(d)$, the count of integers below
$d$ coprime to $d$. The cyclotomics are the atoms out of which all the polynomials
$X^n - 1$ are built: $X^n - 1 = \prod_{d \mid n} \Phi_d(X)$.

For an odd $N$, the atoms of the knot polynomial are exactly

$$A_N(X) \;=\; \prod_{\substack{d \mid N \\ d > 1}} \Phi_{2d}(X).$$

Read that again slowly, because it is the whole story in one line: **the irreducible
factors of the knot's fingerprint are indexed by the divisors of $N$.** Not by anything
subtler; by the divisors themselves.

Now let $N = pq$ be a product of two distinct odd primes. Its divisors greater than $1$
are $p$, $q$ and $pq$, so

$$A_{pq}(X) \;=\; \Phi_{2p}(X)\cdot\Phi_{2q}(X)\cdot\Phi_{2pq}(X),$$

and the degrees of these three atoms are $\varphi(2p) = p-1$, $\varphi(2q) = q-1$, and
$\varphi(2pq) = (p-1)(q-1)$.

Take $N = 143$. The atoms have degrees $10$, $12$, $120$. The largest is
$\varphi(143) = 120$; the total degree is $142 = N-1$. And now the arithmetic:
$$p + q \;=\; N + 1 - \varphi(N) \;=\; 143 + 1 - 120 \;=\; 24, \qquad pq = 143 .$$
Two numbers with sum $24$ and product $143$: they are the roots of
$Y^2 - 24Y + 143 = 0$, namely $Y = 11$ and $Y = 13$. The primes have been extracted from
a piece of rope.

This is not a heuristic or a numerical coincidence, and it does not depend on $N$ being
small. It is a theorem, with a short proof: the divisors of $2N$ for odd $N$ are the
divisors of $N$ and their doubles, the atoms $\Phi_d$ with $d$ odd all cancel against
the denominator $X+1$, and what survives is exactly the list above.

## The catch, stated honestly

Why is this not a factoring algorithm? Because of a single, brutal number: **degree**.

$A_N$ has degree $N-1$. Even worse, one can prove it has exactly $N$ nonzero
coefficients — every single one of them equal to $\pm 1$, none of them ever zero. So
merely *writing down* the object costs $N$ symbols. But $N$ itself is specified by only
about $\log_2 N$ bits. Writing the polynomial is therefore exponentially expensive in
the input size: for a $2048$-bit modulus, the polynomial has more terms than there are
atoms in the observable universe, by an unimaginable margin.

One might hope to sidestep this: perhaps you never write the polynomial down, but
manipulate it implicitly and extract the degrees of its factors by some clever trick.
Here the second half of the catch bites. Factoring a polynomial of degree $N-1$ into
irreducibles over the rationals is itself governed by the divisors of $N$ — the very
list you were trying to compute. Every step of the extraction quantifies over the
divisors of $N$. The bridge is real, and it is a loop.

There is a third, subtler obstruction, and it is my favourite. Knot theorists have a
cheap numerical invariant called the **determinant** of a knot, obtained by evaluating
the Alexander polynomial at $X = -1$. It's a single integer, easy to compute, and if it
happened to be some random divisor of $N$ the game would be over. It does not. The
complete law is:

> **Determinant law.** For coprime $a,b \ge 1$, the determinant of $T(a,b)$ equals $1$
> if $a$ and $b$ are both odd, and equals whichever of $a,b$ is odd if the other is
> even.

So for $T(2,N)$ with $N$ odd the determinant is exactly $N$ — the number you already
knew — and for $T(p,q)$ with two odd primes it is exactly $1$. The determinant returns
your own input, or nothing at all. Never a new factor. The obstruction is not laziness
of technique; it is a theorem.

## What the knot *does* tell you cheaply

If the polynomial were an opaque wall, that would be the end. It isn't. There is a
genuinely cheap readout, and it is sharp enough to prove that the fingerprint is
*complete*.

Look at the coefficients of $\Delta_{a,b}$ in order, starting at the constant term. They
are all $0$, $+1$ or $-1$ — never anything else — and the first index $n \ge 1$ where a
coefficient equals $+1$ is exactly $\min(a,b)$. Combine this with the degree, which is
$(a-1)(b-1)$, and you recover the other parameter by a division:

$$\frac{\deg \Delta_{a,b}}{\min(a,b)-1} + 1 \;=\; \max(a,b).$$

Two glances at the polynomial — its lowest positive $+1$ coefficient and its degree —
and the pair $\{a,b\}$ is yours. For $T(2,N)$ this returns $\{2, N\}$: the input, and
nothing you didn't already have. The readout is cheap precisely because it is
uninformative about arithmetic.

Pushing this further gives a satisfying structural theorem. Define the **divisor
spectrum** of $T(a,b)$ to be
$$S(a,b) = \{\, d : d \mid ab,\ d \nmid a,\ d \nmid b \,\},$$
so that $\Delta_{a,b} = \prod_{d \in S(a,b)} \Phi_d$. Then $\Phi_d$ divides
$\Delta_{a,b}$ if and only if $d \in S(a,b)$: the polynomial and its spectrum are the
same information. From the spectrum, three maxima recover everything: the largest
element of $S(a,b)$ is $ab$; the largest divisor of $ab$ *not* in $S(a,b)$ is $b$; and
the largest such divisor that does not divide $b$ is $a$. Consequently:

> **Completeness.** Torus knots are distinguished by their Alexander polynomials: if
> $T(a,b)$ and $T(a',b')$ have the same Alexander polynomial, with $1 < a < b$ and
> $1 < a' < b'$ coprime pairs, then $a = a'$ and $b = b'$.

Nothing is lost in the passage from rope to polynomial. The encoding is faithful. That
is what makes the computational failure worth staring at: it is not a failure of
information, it is a failure of *access*.

## A detour through the ancient problem of making change

Now for the part that surprised me most. There is a second, completely different way to
read the same polynomial, and it turns the knot into a story about coins.

Given coprime denominations $a$ and $b$ — say $5$ and $7$ — which totals can you pay
exactly? You can make $0, 5, 7, 10, 12, 14, 15, 17, 19, 20, 21, 22, 24, \ldots$ and from
$24$ on, everything. The unpayable amounts are the **gaps**; the largest is the famous
Frobenius number $ab - a - b$ (here $23$), and Sylvester proved in 1882 that the number
of gaps is exactly $(a-1)(b-1)/2$.

Now write $G(X) = \sum_{g \text{ a gap}} X^g$, the generating polynomial of the gaps.
Then, remarkably,

$$\Delta_{a,b}(X) \;=\; 1 - (1-X)\,G(X).$$

The knot invariant *is* the gap generating function in disguise. Equivalently, coefficient
by coefficient:

$$[X^n]\,\Delta_{a,b} \;=\; \mathbb{1}[\,n \text{ is payable}\,] - \mathbb{1}[\,n-1 \text{ is payable}\,].$$

A coefficient is $+1$ exactly where the payable set is *entered*, $-1$ exactly where it
is *left*, and $0$ everywhere else. That single line explains everything we observed:
coefficients lie in $\{0,\pm1\}$ because they are a difference of two indicator
functions; the polynomial starts $1 + \cdots$ and the first $+1$ appears at
$\min(a,b)$, the smallest positive payable amount; and the degree is the Frobenius
number plus one.

The traffic runs both ways across this bridge. Knot theorists know that Alexander
polynomials of knots are *palindromic*: the coefficient sequence reads the same
backwards. Feed that symmetry through the dictionary and it becomes the statement that
the payable set is **symmetric** — for every $n$ below the Frobenius threshold, exactly
one of $n$ and $(a-1)(b-1)-1-n$ is payable. A fact about tangled rope becomes a fact
about making change. And Sylvester's count of gaps becomes the statement that the genus
of the knot is half the Frobenius conductor.

## Counting the nonzero terms

The dictionary also pins down exactly how big the polynomial is, in the sense that
matters computationally: how many nonzero coefficients it has.

Group the gaps into maximal *runs* of consecutive unpayable amounts. With denominations
$5$ and $7$, the twelve gaps $1,2,3,4,6,8,9,11,13,16,18,23$ fall into the eight runs
$\{1,2,3,4\}$, $\{6\}$, $\{8,9\}$, $\{11\}$, $\{13\}$, $\{16\}$, $\{18\}$, $\{23\}$ —
and each run contributes exactly one "leaving" event and one "returning" event. Let $\beta(a,b)$ be the number of runs. Since
the polynomial's coefficients sum to $\Delta_{a,b}(1) = 1$, entries and exits balance
exactly, and:

> **Support law.** The Alexander polynomial of $T(a,b)$ has exactly
> $2\beta(a,b) + 1$ nonzero coefficients.

Two clean consequences follow. First, no run can be longer than $a-1$, because among any
$a$ consecutive integers one is a multiple of $a$ and hence payable; combining that with
Sylvester's gap count gives $\beta(a,b) \ge (b-1)/2$, so
$$\#\{\text{nonzero coefficients of } \Delta_{a,b}\} \;\ge\; \max(a,b).$$
Materializing the polynomial costs at least $\max(a,b)$ symbols — the exponential
barrier, proved rather than asserted. Second, the bound is *sharp exactly on the
arithmetic pencil*: for $T(2,N)$ every gap is its own run, so $\beta(2,N) = (N-1)/2$ and
the polynomial has precisely $N$ nonzero coefficients. Meanwhile on the "staircase"
family $T(a,a+1)$ the count is $2a-1$, strictly more than $\max(a,a+1)$ once $a \ge 3$.

## The lattice of knots

One last piece of structure, and the most number-theoretic of all. The map $N \mapsto
A_N$ sends odd numbers to polynomials. How does it interact with divisibility?

Beautifully, on one side. Working over the rationals,
$$\gcd\big(A_M,\,A_N\big) \;=\; A_{\gcd(M,N)},$$
and taking degrees, $\deg \gcd(A_M,A_N) + 1 = \gcd(M,N)$. Euclid's algorithm on numbers
is mirrored perfectly by Euclid's algorithm on knot polynomials. In particular $A_M$ and
$A_N$ are coprime as polynomials precisely when $M$ and $N$ are coprime as integers.

Imperfectly, on the other side. The naive guess $A_M \cdot A_N = A_{\gcd} \cdot A_{\rm
lcm}$ is false, but it fails by an explicitly computable amount: there is a *join defect*
polynomial $C_{M,N}$, itself a product of cyclotomics, with
$$A_M \cdot A_N \cdot C_{M,N} \;=\; A_{\gcd(M,N)} \cdot A_{\operatorname{lcm}(M,N)},
\qquad \deg C_{M,N} + M + N = \gcd(M,N) + \operatorname{lcm}(M,N).$$
The defect vanishes exactly when one of $M, N$ divides the other. The failure of the map
to be a lattice homomorphism is measured, to the last degree, by the shortfall of
$M + N$ below $\gcd + \operatorname{lcm}$.

## What it all means

Strip away the rope and what remains is a case study in a distinction we do not usually
make carefully enough: the difference between information being *present* and information
being *available*.

The Alexander polynomial of $T(2,N)$ contains the factorization of $N$ in the strongest
possible sense — it determines it, it is determined by it, and the extraction is a
two-line calculation once you have the factor degrees. Every naive route to that
information runs into a wall, and each wall turns out to be a theorem rather than an
accident: exponential support size, determinant collapse, and factor-degree symmetry
that never distinguishes $p$ from $q$.

That's a familiar shape. It is the shape of RSA itself, where $N$ perfectly determines
$p$ and $q$ and nobody can get at them; the shape of the class number, which encodes
deep arithmetic in a number nobody can compute quickly; the shape of the permanent,
whose defining formula is a one-liner nobody can evaluate. Complexity is not about
secrecy. It is about representation.

What the knot gives us in return for its computational silence is a dictionary — three
subjects, one object. On one side, a tangled circle in three-dimensional space and its
Seifert surface. In the middle, a product of cyclotomic polynomials indexed by divisors.
On the other side, a numerical semigroup and the ancient question of which sums you can
pay with two kinds of coin. Each of the three has facts the other two would never have
guessed: palindromic symmetry of a topological invariant becomes symmetry of a
semigroup; Sylvester's 1882 gap count becomes the genus of a surface; the divisors of an
integer become the irreducible constituents of a knot's fingerprint.

The rope will not factor your modulus. But it knows.
