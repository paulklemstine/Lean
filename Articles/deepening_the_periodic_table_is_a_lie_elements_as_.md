# The Periodic Table Is a Lie: Elements as Eigenvalues of Spacetime

## A different way to read Mendeleev's chart

Every schoolroom has one on the wall. The periodic table, with its neat rows and
columns of colored boxes, is the single most recognizable diagram in all of
science. Hydrogen sits in the top-left corner with the number $1$. Helium is
$2$. Carbon is $6$, oxygen $8$, gold $79$. That number — the *atomic number*
$Z$ — is what orders the whole table. It counts the protons packed into the
nucleus, and with them the electrons that give each element its personality.

But here is a quiet, subversive question: is the atomic number really the *thing
itself*, or is it just a label we hang on the door? A cloakroom ticket is not
your coat. A house number is not your house. What if the integers $1, 2, 3,
\dots$ that march across the periodic table are not the fundamental objects, but
*shadows* — the visible readouts of something deeper?

Physics has a name for the deeper thing. In quantum mechanics, every measurable
quantity — energy, position, momentum, spin — is encoded not as a number but as
an **operator**: a rule that acts on the states of a system. When you measure
the quantity, nature does not hand you an arbitrary value. It hands you one of a
special, discrete list of numbers baked into the operator itself. Those numbers
are called the operator's **eigenvalues**, and the whole collection is its
**spectrum**. The word is not an accident: the colors of a glowing gas, the
"spectral lines" that let us read the chemistry of distant stars, are literally
the eigenvalues of an energy operator made visible.

So the provocative claim of this article is exactly this: **the periodic table
is a spectrum.** The atomic numbers are not the primary data. They are the
eigenvalues of a single, self-adjoint operator — a legitimate quantum
observable — and everything we usually treat as brute arithmetic about the
elements turns out to be a *spectral* fact in disguise.

## Building the operator

Let us make the claim precise, and then prove it.

Fix a number $n$ of elements — say the first $118$, or the first million;
nothing depends on the choice. We work in the $n$-dimensional space of lists of
$n$ real numbers, which we can think of as the state space of a little quantum
system with $n$ available slots, one per element. On this space we define a
single operator, which we call the **nuclear Hamiltonian** $H_n$. It is the
simplest operator imaginable that still knows about the elements: it is
**diagonal**, and its diagonal entries are exactly the atomic numbers

$$H_n = \operatorname{diag}(1,\, 2,\, 3,\, \dots,\, n).$$

Concretely, $H_n$ takes the $i$-th slot and multiplies it by the $i$-th atomic
number, leaving the slots uncoupled. In symbols, if we write $z_i = i$ for the
atomic number of the $i$-th element (so $z_1 = 1$, $z_2 = 2$, and so on), then
$H_n$ scales the $i$-th coordinate by $z_i$.

Two things must be true for this to be a *physically honest* object rather than
a numerical trick.

**First, it must be a genuine observable.** In quantum mechanics, an operator
represents a real, measurable quantity only if it is **self-adjoint** (also
called Hermitian) — the abstract guarantee that all its measured values come out
real, never imaginary. A diagonal operator with real entries is automatically
self-adjoint, so:

> **Theorem (Observable).** *The nuclear Hamiltonian $H_n$ is self-adjoint.*

It passes the test. $H_n$ is not a bookkeeping gimmick; it is exactly the kind of
operator nature is allowed to use for a measurable quantity.

**Second — and this is the heart of the matter — its spectrum must recover the
periodic table.** This is where the diagonal construction pays off.

## The spectrum *is* the periodic table

An eigenvalue of $H_n$ is a number $\mu$ for which some nonzero state $x$
satisfies $H_n x = \mu x$: applying the operator merely rescales the state,
without rotating it. Such a state is an **eigenstate**, and it is as close as a
quantum system comes to standing perfectly still.

For our diagonal operator, the eigenstates are the purest states of all: the
"one slot lit up" states, where the $i$-th coordinate is $1$ and all the others
are $0$. Feed such a state into $H_n$ and it comes back scaled by exactly the
$i$-th atomic number. So each atomic number is an eigenvalue:

> **Theorem (Every element is a spectral line).** *For each element $i$, the
> atomic number $z_i$ is an eigenvalue of $H_n$, and the "$i$-th slot lit up"
> state is its eigenstate.*

The converse is the part that makes the claim airtight. Could $H_n$ have *extra*
eigenvalues — ghost numbers that are not atomic numbers at all? No. Suppose $\mu$
is any eigenvalue, with eigenstate $x \ne 0$. Because $x$ is nonzero, at least
one of its coordinates, say the $j$-th, is nonzero. Reading off the $j$-th
coordinate of the equation $H_n x = \mu x$ gives $z_j\, x_j = \mu\, x_j$, and
since $x_j \ne 0$ we may cancel it to conclude $\mu = z_j$. Every eigenvalue is
forced to be an atomic number. Putting the two directions together:

> **Theorem (The periodic table is a spectrum).** *The spectrum of the nuclear
> Hamiltonian — its complete set of eigenvalues — is exactly the set of atomic
> numbers $\{1, 2, \dots, n\}$, with no more and no less.*

This is the promised inversion. We did not *assume* the atomic numbers and build
a table; we built one operator and *derived* the atomic numbers as the only
values it can return. The integers on Mendeleev's chart are the readings of a
measurement.

## Why this is more than a relabeling

If the story ended there, a skeptic could shrug: "You dressed the numbers
$1, \dots, n$ in a fancy diagonal coat." The reason the reframing matters is that
the spectral viewpoint comes with a whole toolbox — trace, determinant,
characteristic polynomial, power sums — and each tool, applied to our operator,
turns a famous piece of *arithmetic* into a *spectral* identity. The periodic
table starts talking to number theory.

**The trace and Gauss's triangle.** The *trace* of an operator is the sum of its
diagonal entries, and a foundational theorem of linear algebra says it also
equals the sum of the eigenvalues. For the nuclear Hamiltonian, summing the
eigenvalues means summing the atomic numbers $1 + 2 + \cdots + n$ — the sum a
young Carl Friedrich Gauss reputedly computed in seconds by pairing the ends. The
answer is the **triangular number**:

$$\operatorname{tr}(H_n) = 1 + 2 + \cdots + n = \frac{n(n+1)}{2}.$$

So the trace of our quantum observable is *literally* a Gauss triangular number.
The total "spectral weight" of the periodic table is a triangle.

**The determinant and the factorial.** The *determinant* of an operator is the
product of its eigenvalues. Multiplying the atomic numbers together gives
$1 \cdot 2 \cdot 3 \cdots n$ — the **factorial**:

$$\det(H_n) = 1 \cdot 2 \cdots n = n!.$$

The single number that measures how the operator scales volume in state space is
the factorial of the number of elements. Combinatorics — the mathematics of
counting arrangements — meets the periodic table through a determinant.

**The characteristic polynomial.** Every operator carries a fingerprint
polynomial whose roots are precisely its eigenvalues. For $H_n$ it factors
completely into linear pieces, one per element:

$$\det(X\,I - H_n) = (X - 1)(X - 2)\cdots(X - n) = \prod_{i=1}^{n} (X - z_i).$$

Reading a physical operator's fingerprint spells out the periodic table one
factor at a time.

**The power-sum ladder.** The trace identity is just the bottom rung of an
infinite ladder. Raise the operator to the $k$-th power first — which, for a
diagonal operator, simply raises each eigenvalue to the $k$-th power — and *then*
take the trace, and you get the **$k$-th power sum** of the atomic numbers:

$$\operatorname{tr}(H_n^{\,k}) = 1^k + 2^k + \cdots + n^k = \sum_{i=1}^{n} z_i^{\,k}.$$

The case $k=1$ is Gauss's triangle. The case $k=2$ is the sum of squares
$\frac{n(n+1)(2n+1)}{6}$. The case $k=3$ is the sum of cubes, famously the square
of the triangular number. Each rung is a different classical summation formula,
and the operator generates them all at once — a single object whose *spectral
moments* enumerate an entire family of number-theoretic identities.

## What the reframing buys us

Why go to the trouble of turning a wall chart into an operator? Because
reframing is how mathematics makes progress. Once you see the periodic table as a
spectrum, you inherit every question spectral theory knows how to ask, and every
one of them becomes a question about the elements.

- **Turn on the couplings.** Our operator is diagonal — the elements do not
  "talk" to each other. Add off-diagonal terms, and the spectrum deforms in
  controlled ways governed by classical *interlacing* theorems. This is precisely
  how physicists model interactions, and it suggests a language for perturbations
  of the elemental ladder.
- **Go to infinity.** Nothing forces $n$ to be finite. Push the construction into
  an infinite-dimensional space and the spectrum becomes an unbounded discrete
  set stretching off to infinity — the natural home for a genuinely quantum
  operator.
- **Weight by isotopes.** Give each eigenvalue a multiplicity equal to the number
  of stable isotopes of that element, and the trace stops counting bare integers
  and starts counting *physical nuclei* — a bridge from pure arithmetic toward
  measured nuclear data.
- **Take the temperature of the table.** Sums like $\sum z_i^{-s}$ and
  $\sum e^{-\beta z_i}$ are the *spectral zeta function* and the *heat trace* of
  the operator — the same machinery that connects the primes to the Riemann zeta
  function and that governs the thermodynamics of quantum systems.

## The moral

The periodic table looks like a filing cabinet: a place to store $118$ facts. The
spectral picture says it is something more alive — the set of allowed readings of
a single measurement, a chord struck on one instrument. The atomic numbers are
not the notes written on the page; they are the notes you *hear*.

Gauss's triangle, the factorial, the sum of squares and cubes, the whole
polynomial fingerprint of the elements — all of them fall out of one self-adjoint
operator whose spectrum is the periodic table. The chart on the classroom wall
was never really a list of integers. It was a spectrum all along, waiting for
someone to name the operator.

So the next time you look at that familiar grid, try seeing past the numbers in
the boxes. Behind each one stands an eigenstate, quietly humming at its own atomic
frequency. The periodic table is a lie only in the gentlest sense: it shows you
the answers, and hides the question. The question is an operator — and its
spectrum is the elements.
