# The Periodic Table Is a Lie: Elements as Eigenvalues of Spacetime

## A table that is secretly a spectrum

Every chemistry classroom has one on the wall. The periodic table: a
tidy grid of boxes, each holding an element, arranged left to right and
top to bottom by atomic number $Z$. Hydrogen is $1$, helium is $2$,
and on it marches up to the heaviest synthetic giants. We are taught to
read it like a calendar — a list of things, sorted.

But sorting is not the same as *explaining*. The deep mystery of the
table is not that the elements can be listed; it is that the list
**repeats**. The noble gases — helium, neon, argon, krypton — recur at
special positions with almost supernatural chemical calm. The reactive
alkali metals recur just after them. Something is oscillating. Something
is *periodic*. And whenever nature is periodic, a mathematician's
instinct is the same: there is a wave underneath, and a wave means an
**operator** and its **eigenvalues**.

This article follows that instinct to its conclusion. The claim is
provocative but precise: the periodic table is not fundamentally a list.
It is the **spectrum of an operator** — the collection of allowed
energy levels of a quantum Hamiltonian — together with the
*multiplicities* of those levels. The elements are eigenvalues. The
"periods" of the table are the degeneracies of those eigenvalues. And
the magic numbers of nuclear physics are the very same story told with a
different operator. Chemistry, in this telling, is applied spectral
theory.

## Shells, degeneracy, and the arithmetic of closing

Start with the hydrogen atom, the one quantum system we can solve
exactly. Its electron can occupy energy levels labelled by a whole
number $n = 1, 2, 3, \dots$ — the **shells**. What makes shells special
is that each one is not a single state but a *bundle* of states that
share the same energy. Physicists call this **degeneracy**: many
distinct configurations, one identical energy.

Where does the degeneracy come from? Within a shell $n$, the electron
can carry different amounts of angular momentum, indexed by
$l = 0, 1, \dots, n-1$. For each value of $l$ there are $2l+1$ ways to
orient that angular momentum in space — the *magnetic sublevels*
$m = -l, -l+1, \dots, l$. Adding these up across the sub-shells gives a
strikingly clean total. The **angular-momentum sum rule** states

$$\sum_{l=0}^{n-1} (2l+1) = n^2.$$

The proof is a one-line induction: the sum for $n$ shells is $n^2$, and
adding the next sub-shell contributes $2n+1$, turning $n^2$ into
$(n+1)^2$. Then each spatial state can hold two electrons — spin up and
spin down — so the full degeneracy of the $n$-th shell is

$$\text{(shell degeneracy)} = 2n^2 = 1\cdot 2,\ 8,\ 18,\ 32,\ \dots$$

These are the row lengths of the periodic table's idealized skeleton.
Now comes the punchline. To find the atomic numbers at which a shell
structure "closes" — the analogues of the noble gases — you accumulate
the degeneracies:

$$F(n) = \sum_{k=1}^{n} 2k^2.$$

This is a Faulhaber sum, and it collapses to a single cubic polynomial.
Multiplying by $3$ to keep everything in whole numbers,

$$3\sum_{k=1}^{n} 2k^2 = n(n+1)(2n+1),$$

so the cumulative fillings are $2,\ 10,\ 28,\ 60,\ 110,\ \dots$. These
grow strictly — every new shell adds $2(n{+}1)^2 > 0$ states, so no two
closings ever coincide. The entire "table" is thus compressed into one
formula: not a memorized list of noble-gas numbers, but a cubic that
generates them on demand.

## The same idea builds the atomic nucleus

Here is where the story doubles. Electrons are not the only particles
that live in shells. Protons and neutrons inside the nucleus do too, and
their shell closings — the famous **magic numbers**
$2, 8, 20, 28, 50, 82, 126$ — mark nuclei of extraordinary stability,
the "islands" where isotopes cluster and lifetimes stretch.

The nuclear potential is not the Coulomb well of the atom; a good first
model is the **isotropic three-dimensional harmonic oscillator**, a
particle in a smooth bowl. Its energy levels are labelled by
$N = 0, 1, 2, \dots$, and the degeneracy of level $N$ is

$$d_{\text{HO}}(N) = (N+1)(N+2) = 2,\ 6,\ 12,\ 20,\ \dots$$

Accumulating these degeneracies gives the oscillator's own closed-shell
polynomial. Again it is a perfect cubic:

$$3\sum_{N=0}^{n} (N+1)(N+2) = (n+1)(n+2)(n+3),$$

producing the fillings $2,\ 8,\ 20,\ 40,\ 70,\ 112,\ \dots$. Read the
first three: $2, 8, 20$. Those are exactly the first three nuclear magic
numbers. A pure bowl, with no forces beyond confinement, already knows
where the first islands of nuclear stability lie.

Two different worlds — the electron cloud and the atomic nucleus — and
two different operators, yet the *shape* of the answer is identical: a
degeneracy law that grows quadratically, summed into a cubic filling
polynomial whose values are the closed shells. Periodicity in both cases
is nothing more nor less than the arithmetic of accumulating
eigenvalue multiplicities.

## Making "elements are eigenvalues" literal

So far "eigenvalue" has been a metaphor for "energy level." We can make
it exact. Place the shell energies $E_0, E_1, \dots, E_{d-1}$ along the
diagonal of a square matrix $H$ and put zeros everywhere else. This
diagonal matrix is a bona-fide Hamiltonian: it is **Hermitian** (equal
to its own conjugate transpose), so it represents a genuine physical
observable with real measured values.

Its spectrum is transparent. The standard basis vector $e_j$ — a column
of zeros with a single $1$ in slot $j$ — satisfies

$$H e_j = E_j\, e_j,$$

so $e_j$ is an eigenvector and its eigenvalue is precisely the $j$-th
shell energy. The **trace** of $H$, the sum of its diagonal, is the
total shell energy $\sum_j E_j$; because the trace is basis-independent,
this total is a conserved bookkeeping invariant of the whole
configuration. In this concrete matrix, "reading off the periodic
table" becomes the literal act of listing a self-adjoint operator's
eigenvalues and counting how many eigenvectors share each one.

## Honesty about a beautiful model

A good story earns trust by admitting its limits, and this one has
sharp, instructive ones. The Coulomb law predicts closings at
$2, 10, 28, 60, 110$ — the correct pattern for a spectrum with $n^2$
degeneracy, but *not* the observed noble gases $2, 10, 18, 36, \dots$.
Real electrons do not fill pure $n$-shells; they obey the **Madelung
rule**, filling orbitals in order of increasing $n+l$. This is not a new
set of eigenvalues but the *same* eigenvalues sorted by a different key —
a permutation of the spectrum. The table diverges from the pure-shell
prediction exactly past $Z = 10$, which is precisely where $(n+l)$
ordering first overtakes $n$ ordering.

The oscillator is equally candid. It nails $2, 8, 20$ and then
overshoots: it predicts $40, 70$ where nature insists on $28, 50$. The
fix is a single extra diagonal term, the **spin–orbit coupling**, which
reshuffles the sublevels and pushes the closings onto the empirical
magic numbers. The islands of stability are not a separate phenomenon;
they are a perturbed spectrum.

So the mathematics is exact — the sum rules, the cubic fillings, the
diagonal spectrum are all theorems, proven cleanly by induction and
linear algebra. What is *heuristic* is the identification with real
atomic numbers, and even the failures are illuminating: each place the
naive model breaks names the precise physical ingredient — Madelung
ordering, spin–orbit splitting — that must be added.

## Why this reframing matters

Casting the periodic table as a spectrum is more than a party trick. It
unifies two of the great classification schemes of physical science —
the chemical elements and the nuclear magic numbers — under one
sentence: *closed shells are cumulative degeneracies of a shell
Hamiltonian's eigenvalues.* It turns a memorized list into a generating
polynomial. It suggests a whole **family of possible periodic tables**,
one for each quadratic degeneracy law $d(k) = ak^2 + bk + c$, with the
Coulomb and oscillator tables sitting as two lattice points among
infinitely many. And it reframes the deepest patterns of chemistry as
statements about operators: every stable configuration is a place where
a spectrum happens to close.

The table on the classroom wall is not wrong. But it is a shadow — the
list of outputs of a machine whose inner workings are pure spectral
theory. Learn to see the operator behind the grid, and the periodic
table stops being something to memorize and becomes something to
*derive*. That is the sense in which the periodic table is a lie: not
false, but incomplete, a beautiful surface hiding an even more beautiful
mathematics underneath.
