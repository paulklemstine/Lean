# The Periodic Table Is a Spectrum—But Not the Spectrum You First Expect

## A spectral journey from shells to the limits of simple models

The periodic table looks like a chart, but it behaves like music. Its columns repeat themes. Its rows lengthen according to a hidden rhythm. Certain configurations are unusually complete, while the next particle begins a new phrase. This pattern is not imposed by graphic design. It arises because quantum states arrive in groups, and the sizes of those groups are controlled by symmetry.

That observation suggests a provocative slogan: **the periodic table is a spectrum**. A spectrum, in quantum mechanics, is the collection of energies allowed by a Hamiltonian, the operator that encodes a system’s dynamics. Each energy may occur more than once. That multiplicity—the number of independent states sharing the same energy—is called its degeneracy. Fill the states from lower energy upward, and every completely filled group creates a closure. Periodicity is therefore a form of spectral bookkeeping.

The slogan contains a precise mathematical core, but it must be handled carefully. A maximally symmetric Coulomb model produces shell capacities $2,8,18,32,50,\ldots$ and cumulative closures $2,10,28,60,110,\ldots$. Those are not the observed noble-gas atomic numbers beyond neon. A simple three-dimensional oscillator produces nuclear closures $2,8,20,40,70,112,\ldots$; it matches the first three familiar nuclear magic numbers, then misses the next ones. The failures are valuable. They identify the physical interactions that a more realistic Hamiltonian must contain.

## Why angular momentum counts states

Begin with a shell labeled by a positive integer $n$. Within it, the orbital angular-momentum label $l$ takes the values

$$
l=0,1,\ldots,n-1.
$$

For each $l$, the magnetic quantum number $m$ ranges from $-l$ to $l$. Thus that subshell contains exactly $2l+1$ magnetic states. These are not arbitrary labels: their angular wave patterns are single-valued after a full rotation, so an azimuthal factor returns to itself when the angle increases by $2\pi$.

Adding the magnetic states across all subshells gives the Angular-Momentum Counting Theorem:

$$
\sum_{l=0}^{n-1}(2l+1)=n^2.
$$

The proof can be seen geometrically or algebraically. The odd numbers build successive square borders: $1+3+5+\cdots +(2n-1)=n^2$. Equivalently, if the identity holds at $n$, then adding the next odd number $2n+1$ changes $n^2$ into $(n+1)^2$.

Electrons also have two spin states. Doubling the angular count gives the Hydrogenic Shell Degeneracy Theorem:

$$
g_n=2n^2.
$$

The first five capacities are therefore $2,8,18,32,$ and $50$. This simple sequence explains why square numbers appear so naturally in idealized atomic shell structure: they are the cumulative count of magnetic orientations, doubled by spin.

## Closing a shell creates a cubic law

If shell $k$ holds $2k^2$ particles, the total number needed to fill the first $n$ shells is

$$
C_n=\sum_{k=1}^{n}2k^2.
$$

The Coulomb Cumulative-Filling Theorem states that

$$
3C_n=n(n+1)(2n+1),
$$

or, equivalently,

$$
C_n=\frac{n(n+1)(2n+1)}{3}.
$$

The resulting closures begin

$$
2,10,28,60,110,\ldots.
$$

Every new shell contributes $2(n+1)^2>0$, so these totals increase strictly. The cubic growth is not an accident: summing a quadratic degeneracy law naturally produces a cubic filling law.

This is the first exact sense in which a periodic table can be generated from a spectrum. Supply a sequence of energy levels with multiplicities $2n^2$, order them by energy, and the closed-shell positions are precisely the cumulative sums above.

Yet the observed noble-gas atomic numbers begin $2,10,18,36,54,86$. The idealized Coulomb sequence agrees at $2$ and $10$, then predicts $28$ where nature gives $18$. The discrepancy is decisive. In a pure Coulomb field, energy depends only on $n$, leaving different $l$ values exactly degenerate. In many-electron atoms, screening and electron interactions break that degeneracy. Orbitals are filled approximately according to the Madelung ordering: increasing $n+l$, with lower $n$ breaking ties. The real periodic table is still spectral, but its relevant spectrum is richer than the pure hydrogenic one.

## A second table inside the nucleus

The same counting philosophy applies to nuclei. A common first approximation treats nucleons as occupying levels of a three-dimensional isotropic harmonic oscillator. Label an oscillator level by a nonnegative integer $N$. Including spin, its degeneracy is

$$
h_N=(N+1)(N+2).
$$

The capacities begin $2,6,12,20,30,42,\ldots$. Filling all levels from $0$ through $n$ gives

$$
M_n=\sum_{N=0}^{n}(N+1)(N+2).
$$

The Oscillator Cumulative-Filling Theorem states

$$
3M_n=(n+1)(n+2)(n+3),
$$

and hence

$$
M_n=\frac{(n+1)(n+2)(n+3)}{3}.
$$

This produces

$$
2,8,20,40,70,112,\ldots.
$$

Again, each increment $(n+2)(n+3)$ is positive, so the closures strictly increase. The first three totals—$2,8,$ and $20$—are nuclear magic numbers, particle counts associated with especially stable proton or neutron shells.

Then the simple model fails: the fourth empirical magic number is $28$, not $40$, and the next is $50$, not $70$. Here the missing physics is different. Strong spin–orbit coupling splits levels that the bare oscillator treats as degenerate and reorders them so that new gaps appear. The error is not random; it begins exactly where a neglected interaction becomes essential.

The two models agree at their first closure: both produce $2$. After that they tell different stories because they encode different symmetries and different degeneracy laws.

## Making “elements as eigenvalues” literal

The spectral picture can be stated without metaphor. Choose any finite number $d$ of idealized shells and assign the hydrogenic energies

$$
E_j=-\frac{1}{(j+1)^2},\qquad j=0,1,\ldots,d-1.
$$

Construct the diagonal matrix

$$
H_d=\operatorname{diag}(E_0,E_1,\ldots,E_{d-1}).
$$

This matrix is real and symmetric, hence Hermitian. Its standard basis vector $e_j$ satisfies

$$
H_de_j=E_je_j.
$$

Thus each $e_j$ is an eigenvector and each $E_j$ is its eigenvalue. The spectrum is exactly the listed shell energies, while degeneracy is represented by repeating an energy once for every state belonging to that shell. The trace obeys

$$
\operatorname{tr}(H_d)=\sum_{j=0}^{d-1}E_j,
$$

so even a global matrix invariant records the total energy of this truncated shell list.

This Diagonal Shell Hamiltonian Theorem establishes the clean mathematical mechanism: energy levels are eigenvalues, states are eigenvectors, and shell capacities are eigenvalue multiplicities. A “closed shell” is the point at which all states in one or more spectral clusters have been occupied.

The popular phrase “elements are eigenvalues” should therefore be refined. Atomic number is not obtained by simply rounding a binding energy divided by a universal constant. Rather, chemically important closures arise from the ordered spectrum and multiplicities of a many-body Hamiltonian. What matters is not only where an eigenvalue lies but how many states share it, how interactions split it, and which level comes next.

## The most informative result is the mismatch

Simple theories are often judged by whether they reproduce a list. A better standard asks whether they explain both their successes and their failures.

The Coulomb model proves exactly that the third closure is $28$, so it cannot equal the observed third noble-gas closure $18$. This is a mathematical counterexample to the naive claim that pure $n$-shell degeneracy directly generates the periodic table. It points toward $l$-dependent energy shifts and Madelung ordering.

The oscillator model proves exactly that its fourth closure is $40$, so it cannot equal the empirical fourth nuclear magic number $28$. This counterexample points toward spin–orbit splitting.

In each case, the mismatch acts like a spectroscope aimed at the theory itself. It reveals which symmetry is too perfect. Exact degeneracies create elegant formulas; real interactions break those degeneracies in structured ways. The observed table is formed not by symmetry alone but by symmetry and its controlled breaking.

## From chemistry to cryptographic fingerprints

Why place this story near cryptography? Spectra can serve as compact fingerprints. A finite Hamiltonian can be summarized by its ordered eigenvalues, multiplicities, gaps, and cumulative ranks. Such summaries are insensitive to a change of basis: two matrix representations of the same operator share the same spectrum. That invariance makes spectral data useful wherever one needs a coordinate-free signature.

The present formulas offer particularly transparent test cases. A claimed hydrogenic shell list can be checked against $2n^2$ and its cubic cumulative law. An oscillator list can be checked against $(N+1)(N+2)$ and its own cubic law. These are not cryptographic protocols by themselves, and physical spectra should not be treated as secret keys without a security analysis. But the underlying idea—encoding structure through invariant spectral fingerprints—connects quantum models with spectral graph methods, integrity checks, and physically informed identification.

## A better periodic-table slogan

The periodic table is not literally the output of one elementary Hamiltonian. The pure Coulomb spectrum predicts the wrong later closures, and the bare oscillator misses later nuclear magic numbers. But the deeper claim survives in a stronger form:

> Periodic organization is the visible shadow of spectral multiplicity, ordering, and symmetry breaking.

The square identity counts magnetic states. Spin doubles them. Quadratic capacities sum to cubic closure laws. Diagonal Hamiltonians make the eigenvalue picture explicit. Disagreement with experiment identifies the interactions that must split and reorder the ideal levels.

Chemistry is not “just” a list of eigenvalues. It is the art of reading a complicated many-body spectrum: its clusters, gaps, multiplicities, and the way those structures change when particles are added. There is also a practical lesson in how to build scientific models. Begin with the simplest symmetry that permits exact counting. Derive its capacities and closures without tuning. Compare those predictions with observation. Then treat the first mismatch not as an embarrassment but as a design specification for the next operator. Here, $28\ne18$ requests orbital-dependent splitting, while $40\ne28$ requests nuclear spin–orbit coupling. Exact elementary models become scaffolding for more realistic computation.

The periodic table is not a lie. It is a compressed spectral map—and its irregularities are part of the message.