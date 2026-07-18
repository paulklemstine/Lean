# Spectral Shell Models: Degeneracy, Cubic Filling Laws, and the Limits of Idealized Periodic Tables

**Aristotle**  
**July 18, 2026**

## Abstract

Periodic organization in atomic and nuclear systems can be understood as cumulative eigenvalue degeneracy. This paper develops that statement in two exact shell models. In the Coulomb model, summing the $2l+1$ magnetic sublevels over $l=0,\ldots,n-1$ gives $n^2$ orbital states, and spin doubling yields shell degeneracy $2n^2$. The first $n$ shells therefore contain

$$
C_n=\sum_{k=1}^{n}2k^2=\frac{n(n+1)(2n+1)}{3},
$$

producing closures $2,10,28,60,110,\ldots$. In the isotropic three-dimensional harmonic-oscillator model, level $N$ has spin-inclusive degeneracy $(N+1)(N+2)$, and the levels from $0$ through $n$ contain

$$
M_n=\sum_{N=0}^{n}(N+1)(N+2)=\frac{(n+1)(n+2)(n+3)}{3},
$$

producing $2,8,20,40,70,112,\ldots$. The first three oscillator closures reproduce the first three nuclear magic numbers. A finite diagonal Hamiltonian makes the spectral interpretation literal: standard basis vectors are eigenvectors, shell energies are eigenvalues, multiplicities count available states, and the trace is the total listed energy. The exact formulas also falsify naive physical identifications. Pure Coulomb shells predict $28$ rather than the observed third noble-gas closure $18$, while the bare oscillator predicts $40$ rather than the fourth nuclear magic number $28$. These discrepancies isolate the roles of orbital reordering and spin–orbit splitting. The results establish an exact combinatorial and linear-algebraic baseline for richer spectral models while distinguishing spectral bookkeeping from quantitative physical prediction.

## 1. Introduction

The periodic table and the nuclear magic numbers are both records of shell closure. A shell closes when every state in a low-energy spectral cluster is occupied. The location of such a closure is therefore a cumulative count: one adds the multiplicities of the energy levels encountered up to a spectral gap.

This viewpoint separates three ingredients that are often conflated. First, a Hamiltonian supplies energies and eigenstates. Second, symmetry creates degeneracies, meaning that several independent states share one energy. Third, an ordering rule determines which states are filled first. An idealized model may describe the first ingredient and count the second exactly while failing to capture the third in a realistic many-particle environment.

We analyze two models. The hydrogenic or Coulomb model organizes states by a principal shell number $n\ge 1$. Its orbital angular momenta are $l=0,\ldots,n-1$, each supporting magnetic labels $m=-l,\ldots,l$. Including two spin states gives shell capacity $2n^2$. The isotropic three-dimensional oscillator organizes states by $N\ge 0$ and has spin-inclusive degeneracy $(N+1)(N+2)$.

Both degeneracy laws are quadratic, so their cumulative fillings are cubic. The resulting closed forms are exact for the stated models. They also expose exact failures when compared with observed closures. The Coulomb sequence is not the noble-gas sequence after $10$, because real multi-electron orbital energies are not functions of $n$ alone. The oscillator sequence is not the complete nuclear magic sequence after $20$, because the bare oscillator omits strong spin–orbit splitting.

The main contribution is a self-contained chain from angular-state counting to shell capacities, cumulative formulas, monotonicity, and an explicit Hermitian operator whose eigenvectors realize the shell energies. This chain clarifies the mathematically defensible content of the phrase “the periodic table is a spectrum”: shell closures are cumulative spectral multiplicities, but realistic prediction requires the correct interacting Hamiltonian and level ordering.

## 2. Definitions and physical setting

### 2.1 Hamiltonians, spectra, and degeneracy

A finite-dimensional Hamiltonian is represented by a Hermitian matrix $H$, meaning $H^*=H$. A nonzero vector $v$ is an eigenvector with eigenvalue $E$ if

$$
Hv=Ev.
$$

The spectrum is the collection of eigenvalues. The degeneracy of an eigenvalue is the dimension of its eigenspace. In a particle-filling model, a level of degeneracy $g$ can accommodate $g$ mutually independent one-particle states. If levels are filled in increasing energy order, then the number of particles at a closure is a cumulative sum of degeneracies.

For a continuum model, one often begins with a Schrödinger Hamiltonian

$$
H=-\frac{\hbar^2}{2m}\nabla^2+V(r),
$$

where $V(r)$ is a central potential. The present work does not claim a closed-form solution for a realistic strong-plus-electromagnetic nuclear potential. Instead, it isolates two exact degeneracy laws and realizes their energy bookkeeping in finite diagonal matrices.

### 2.2 Angular and magnetic quantum numbers

For a fixed nonnegative orbital angular momentum $l$, the magnetic quantum number is an integer satisfying

$$
-l\le m\le l.
$$

Consequently, the allowed set is

$$
\{-l,-l+1,\ldots,l-1,l\},
$$

which has cardinality $2l+1$. The associated azimuthal dependence may be represented by a complex exponential proportional to $e^{im\phi}$. Since $m$ is an integer,

$$
e^{im(\phi+2\pi)}=e^{im\phi}e^{2\pi im}=e^{im\phi}.
$$

Thus each such angular state is single-valued under a full rotation.

### 2.3 Coulomb shell quantities

For $n\ge 0$, define the angular count

$$
A_n=\sum_{l=0}^{n-1}(2l+1),
$$

with the empty sum $A_0=0$. For a positive shell index $n$, define the spin-inclusive Coulomb degeneracy

$$
g_n=2n^2.
$$

Define the cumulative filling of the first $n$ Coulomb shells by

$$
C_n=\sum_{k=1}^{n}g_k=\sum_{k=1}^{n}2k^2,
$$

with $C_0=0$.

### 2.4 Harmonic-oscillator quantities

For an oscillator level $N\ge 0$, define its spin-inclusive degeneracy by

$$
h_N=(N+1)(N+2).
$$

Define the cumulative filling through level $n$ by

$$
M_n=\sum_{N=0}^{n}h_N=\sum_{N=0}^{n}(N+1)(N+2).
$$

The difference in indexing is intentional: Coulomb shells begin at $n=1$, whereas oscillator levels begin at $N=0$.

## 3. Angular-momentum state counting

### Lemma 1: Magnetic-subshell cardinality

For every nonnegative integer $l$, the number of integers $m$ satisfying $-l\le m\le l$ is exactly $2l+1$.

**Proof sketch.** The interval begins at $-l$ and ends at $l$, inclusive. An inclusive interval of integers from $a$ to $b$ has $b-a+1$ members. Substitution gives $l-(-l)+1=2l+1$. Each value also labels a $2\pi$-periodic azimuthal state because $e^{2\pi im}=1$ for integer $m$. $\square$

### Theorem 1: Angular-Momentum Counting Theorem

For every nonnegative integer $n$,

$$
A_n=\sum_{l=0}^{n-1}(2l+1)=n^2.
$$

**Proof sketch.** For $n=0$, both sides are zero. Suppose the formula holds for $n$. The next angular count is

$$
A_{n+1}=A_n+(2n+1)=n^2+2n+1=(n+1)^2.
$$

Induction proves the identity for all $n$. Equivalently, successive odd numbers form successive square numbers. $\square$

### Corollary 1: Hydrogenic Shell Degeneracy

The $n$th Coulomb shell has $n^2$ orbital states and, after including two spin states per orbital state, has total degeneracy

$$
g_n=2A_n=2n^2.
$$

The first five capacities are therefore

$$
g_1=2,\quad g_2=8,\quad g_3=18,\quad g_4=32,\quad g_5=50.
$$

This result is a multiplicity statement. It does not by itself assert that shells remain unsplit or are filled as indivisible blocks in a many-electron atom.

## 4. Coulomb cumulative fillings

### Lemma 2: Coulomb recurrence

For every nonnegative integer $n$,

$$
C_{n+1}=C_n+2(n+1)^2.
$$

**Proof sketch.** The first $n+1$ shells consist of the first $n$ shells plus shell $n+1$. By definition, that added shell has capacity $2(n+1)^2$. $\square$

### Theorem 2: Coulomb Cumulative-Filling Theorem

For every nonnegative integer $n$,

$$
3C_n=n(n+1)(2n+1).
$$

Equivalently,

$$
C_n=\frac{n(n+1)(2n+1)}{3}.
$$

**Proof sketch.** The result is immediate for $n=0$. Assume

$$
3C_n=n(n+1)(2n+1).
$$

Using Lemma 2,

$$
3C_{n+1}=3C_n+6(n+1)^2.
$$

Substitute the induction hypothesis and factor:

$$
\begin{aligned}
3C_{n+1}
&=n(n+1)(2n+1)+6(n+1)^2\\
&=(n+1)\bigl(n(2n+1)+6(n+1)\bigr)\\
&=(n+1)(n+2)(2n+3),
\end{aligned}
$$

which is the desired formula with $n$ replaced by $n+1$. $\square$

### Corollary 2: Initial Coulomb closures

The first five cumulative fillings are

$$
C_1=2,\quad C_2=10,\quad C_3=28,\quad C_4=60,\quad C_5=110.
$$

### Theorem 3: Strict Growth of Coulomb Closures

The sequence $(C_n)_{n\ge 0}$ is strictly increasing.

**Proof sketch.** Lemma 2 gives

$$
C_{n+1}-C_n=2(n+1)^2>0
$$

for every $n\ge 0$. $\square$

The cubic expression is a special case of the sum-of-squares formula. More conceptually, it reflects a general degree principle: cumulative sums of quadratic shell capacities are cubic polynomials.

## 5. Harmonic-oscillator cumulative fillings

The spatial degeneracy of a three-dimensional isotropic oscillator at total excitation $N$ equals the number of nonnegative integer triples $(n_x,n_y,n_z)$ satisfying $n_x+n_y+n_z=N$. By the stars-and-bars argument this number is

$$
\binom{N+2}{2}=\frac{(N+1)(N+2)}{2}.
$$

Doubling for spin gives

$$
h_N=(N+1)(N+2).
$$

### Lemma 3: Oscillator recurrence

For every nonnegative integer $n$,

$$
M_{n+1}=M_n+(n+2)(n+3).
$$

**Proof sketch.** Passing from cumulative level $n$ to cumulative level $n+1$ adds the degeneracy

$$
h_{n+1}=((n+1)+1)((n+1)+2)=(n+2)(n+3).
$$

$\square$

### Theorem 4: Oscillator Cumulative-Filling Theorem

For every nonnegative integer $n$,

$$
3M_n=(n+1)(n+2)(n+3).
$$

Equivalently,

$$
M_n=\frac{(n+1)(n+2)(n+3)}{3}.
$$

**Proof sketch.** At $n=0$, one has $M_0=(1)(2)=2$, and both sides of the multiplied formula equal $6$. Assume the result at $n$. Lemma 3 yields

$$
3M_{n+1}=3M_n+3(n+2)(n+3).
$$

Substituting the induction hypothesis gives

$$
\begin{aligned}
3M_{n+1}
&=(n+1)(n+2)(n+3)+3(n+2)(n+3)\\
&=(n+2)(n+3)(n+4),
\end{aligned}
$$

which is the formula at $n+1$. $\square$

### Corollary 3: Initial oscillator closures

The first six cumulative fillings are

$$
M_0=2,\quad M_1=8,\quad M_2=20,\quad M_3=40,\quad M_4=70,\quad M_5=112.
$$

The first three values, $2,8,$ and $20$, coincide with the first three nuclear magic numbers.

### Theorem 5: Strict Growth of Oscillator Closures

The sequence $(M_n)_{n\ge 0}$ is strictly increasing.

**Proof sketch.** By Lemma 3,

$$
M_{n+1}-M_n=(n+2)(n+3)>0
$$

for every $n\ge 0$. $\square$

### Proposition 1: Agreement at the first closure

The first Coulomb closure equals the first oscillator closure:

$$
C_1=M_0=2.
$$

**Proof sketch.** Direct substitution gives $C_1=2(1)^2=2$ and $M_0=(1)(2)=2$. $\square$

This agreement is limited. The second values are $10$ and $8$, respectively, because the models impose different degeneracy laws.

## 6. A literal spectral realization

Fix a positive integer $d$. For $j=0,1,\ldots,d-1$, define idealized hydrogenic shell energies

$$
E_j=-\frac{1}{(j+1)^2}.
$$

Define the $d\times d$ shell Hamiltonian

$$
H_d=\operatorname{diag}(E_0,E_1,\ldots,E_{d-1}).
$$

Let $e_j$ denote the $j$th standard basis vector.

### Theorem 6: Diagonal Shell Hamiltonian Theorem

For every $d$ and every index $j$ with $0\le j<d$:

1. $H_d$ is Hermitian.
2. $H_de_j=E_je_j$, so $e_j$ is an eigenvector with eigenvalue $E_j$.
3. The trace is the sum of the listed shell energies:

$$
\operatorname{tr}(H_d)=\sum_{j=0}^{d-1}E_j.
$$

**Proof sketch.** A real diagonal matrix equals its conjugate transpose, proving Hermiticity. Matrix multiplication by $e_j$ selects column $j$; because all off-diagonal entries vanish, the result has only one nonzero coordinate, equal to $E_j$. Finally, the trace of a matrix is the sum of its diagonal entries. $\square$

To encode shell degeneracy, one expands the state space so that an energy is repeated once for each state in its shell. For example, a hydrogenic truncation through shell $n$ contains $2k^2$ copies of the shell-$k$ energy for every $1\le k\le n$. The rank of the spectral projection onto the first $n$ clusters is then $C_n$. An oscillator truncation repeats level-$N$ energy $(N+1)(N+2)$ times, and the corresponding cumulative rank is $M_n$.

This construction supports a precise interpretation: shell closure is cumulative spectral multiplicity. It does not support the stronger assertion that an atomic number is obtained by rounding a single binding energy. Occupation depends on an ordered family of many-particle states, their multiplicities, and exclusion constraints.

## 7. Exact boundaries of the simple models

The models’ limitations are consequences of their exact formulas, not numerical ambiguities.

### Theorem 7: Coulomb Third-Closure Mismatch

The third pure Coulomb closure is not $18$; specifically,

$$
C_3=28\ne 18.
$$

**Proof sketch.** Theorem 2 gives

$$
C_3=\frac{3\cdot4\cdot7}{3}=28.
$$

Therefore it cannot equal $18$. $\square$

The observed noble-gas atomic numbers begin $2,10,18,36,54,86$. A pure Coulomb model makes energies depend only on the principal quantum number $n$ and leaves all permitted $l$ values within a shell degenerate. Multi-electron atoms break that idealization. Screening, electron-electron interactions, and relativistic effects shift subshell energies. The approximate Madelung rule orders orbitals by $n+l$, with lower $n$ breaking ties. Consequently, the $3s$ and $3p$ states fill before the full $n=3$ Coulomb shell, while the $3d$ states enter later. This produces the observed block structure rather than the unsplit closure $28$.

### Theorem 8: Oscillator Fourth-Closure Mismatch

The fourth bare-oscillator closure is not $28$; specifically,

$$
M_3=40\ne 28.
$$

**Proof sketch.** Theorem 4 gives

$$
M_3=\frac{4\cdot5\cdot6}{3}=40.
$$

Therefore it cannot equal $28$. $\square$

Empirical nuclear magic numbers include $2,8,20,28,50,82,$ and $126$. The bare oscillator reproduces $2,8,20$ but not the subsequent closures. A strong angular spin–orbit term, proportional in a simplified description to $\mathbf L\cdot\mathbf S$, splits states according to the coupling of orbital and spin angular momentum. This splitting reorders levels and opens gaps at the later magic numbers.

The two mismatch theorems illustrate a general modeling principle: if an exact symmetry produces the wrong multiplicity clusters, the correction should often be sought in a physically motivated symmetry-breaking perturbation.

## 8. Algorithms

### 8.1 Direct shell enumeration

Given a maximum shell index, one may enumerate each degeneracy and maintain a cumulative total. For Coulomb shells, iterate over $n=1,\ldots,n_{\max}$, append $2n^2$, and add it to the running closure. For oscillator levels, iterate over $N=0,\ldots,N_{\max}$, append $(N+1)(N+2)$, and update the total.

This method uses linear time in the number of requested levels and linear output space. It is preferable when the individual capacities are required.

### 8.2 Closed-form evaluation

If only one cumulative value is needed, evaluate

$$
C_n=\frac{n(n+1)(2n+1)}{3}
$$

or

$$
M_n=\frac{(n+1)(n+2)(n+3)}{3}.
$$

Under the unit-cost arithmetic model this requires constant time and space. With arbitrary-precision integers, the bit complexity depends on multiplication at bit length $O(\log n)$.

### 8.3 Spectral expansion and diagnostics

To construct a diagonal spectral model, pair each shell energy with its degeneracy, repeat that energy according to the degeneracy, and place the expanded list on the diagonal. The resulting matrix can be checked for symmetry, eigenvector residuals, trace equality, and spectral multiplicities. Explicitly allocating a dense $D\times D$ matrix costs $O(D^2)$ memory, but storing only its diagonal costs $O(D)$ memory. All eigenvalues of a diagonal matrix are read in $O(D)$ time; no general eigensolver is required.

For model comparison, compute predicted closures and compare them with empirical target lists. The first mismatch index is scientifically informative: it identifies where omitted interactions begin to alter level ordering or degeneracy.

## 9. Applications and interpretation

### 9.1 Atomic structure

The Coulomb formulas provide a baseline for the degeneracy of a central $1/r$ potential. They explain the origin of capacities $2n^2$ and make clear which degeneracy must be lifted to recover multi-electron orbital ordering. The baseline is useful precisely because it is analytically rigid.

### 9.2 Nuclear shell structure

The oscillator formulas explain the early nuclear closures and isolate the onset of missing spin–orbit physics. A Woods–Saxon potential with a spin–orbit term is a more realistic next model. Its spectrum generally requires numerical methods, but the exact oscillator counts supply expected multiplicities and comparison targets.

### 9.3 Spectral fingerprints

An ordered spectrum with multiplicities and gaps is invariant under unitary changes of basis. This makes spectral summaries natural structural fingerprints. The shell models offer simple examples where expected multiplicities and cumulative ranks have closed forms. Such invariants can support integrity checks, model identification, and comparisons of operators represented in different coordinates.

This connection should not be overstated. The formulas do not constitute an encryption scheme, a key-exchange protocol, or a security proof. A cryptographic application would additionally require a threat model, entropy analysis, resistance to inverse reconstruction, and implementation-level safeguards. The present contribution is the invariant mathematical substrate: spectra compress structural information in a basis-independent way.

### 9.4 Robustness under perturbations

Exact eigenvalues are fragile under perturbation, but the ranks of isolated spectral clusters can be stable when a positive gap persists. This suggests replacing equality of energies with interval separation and replacing exact degeneracy with the rank of a spectral projection. The diagonal model makes this intuition transparent: small changes to diagonal entries preserve closure counts unless entries cross the boundary between clusters.

## 10. Discussion

The two filling polynomials are structurally similar:

$$
C_n=\frac{n(n+1)(2n+1)}{3},
\qquad
M_n=\frac{(n+1)(n+2)(n+3)}{3}.
$$

Both arise by summing quadratic degeneracies, and both grow cubically. Nevertheless, their coefficients and shifts encode distinct state-counting geometries. The Coulomb law collects angular-momentum multiplets within principal shells. The oscillator law counts triples of Cartesian excitations and doubles for spin.

The phrase “elements as eigenvalues” is most accurate after two refinements. First, the chemical significance lies in spectral multiplicities and ordering, not merely in eigenvalue magnitudes. Second, observed atomic numbers are particle counts at closures, hence cumulative ranks rather than eigenvalues themselves. A better statement is that periodic organization is induced by the spectrum of the relevant many-body Hamiltonian.

The exact mismatch results are central rather than incidental. A model that predicts $C_3=28$ has not reproduced argon’s closure at $18$. A model that predicts $M_3=40$ has not reproduced the nuclear closure at $28$. Any publication of the elegant cubic formulas without these boundaries would confuse a theorem about an ideal spectrum with an empirical theory of matter.

A further distinction concerns energy scales. The combinatorial results are dimensionless: they count states and do not depend on the numerical spacing between adjacent energies. Two Hamiltonians can therefore share the same closure sequence while having very different gaps and binding energies. Conversely, a perturbation may shift every energy while preserving cluster ranks and hence preserving the shell counts. For applications, one should report both kinds of information: multiplicities determine capacities, while gap sizes govern the robustness of those capacities under perturbation and thermal or experimental uncertainty.

## 11. Future work

A natural nuclear extension adds a spin–orbit perturbation proportional to $\mathbf L\cdot\mathbf S$ to an oscillator or Woods–Saxon Hamiltonian. The target is an explicit ordering whose cumulative closures are $2,8,20,28,50,82,126$. The exact oscillator sequence supplies the unperturbed baseline and identifies the first required reordering.

For atomic structure, one may perturb Coulomb energies by an $l$-dependent contribution that orders orbitals by $n+l$, with ties broken by $n$. A quantitative goal is to characterize an open parameter region in which occupations through atomic number $118$ follow the Madelung order.

A third direction concerns perturbative stability. For a finite Hermitian Hamiltonian decomposed into angular-momentum sectors, one expects sufficiently small symmetry-preserving perturbations to preserve cumulative multiplicities whenever adjacent spectral clusters remain separated by a positive gap. This reframes periodicity as stability of spectral-projection ranks.

Finally, a Woods–Saxon potential with a realistic spin–orbit term can be studied using interval eigenvalue bounds. Rather than reporting one floating-point spectrum, one should certify level ordering throughout physically meaningful parameter boxes. The combinatorial formulas developed here specify the multiplicities that those numerical enclosures must support.

## 12. Conclusion

Two exact models demonstrate how periodic structure emerges from spectral degeneracy. Angular momentum supplies $2l+1$ magnetic states per subshell, the odd-number sum gives $n^2$ orbital states per Coulomb shell, and spin doubles the capacity to $2n^2$. Cumulative filling then obeys a cubic law and yields $2,10,28,60,110,\ldots$. The three-dimensional oscillator has capacity $(N+1)(N+2)$ and cumulative closures $2,8,20,40,70,112,\ldots$.

A diagonal Hermitian Hamiltonian realizes the slogan literally at the level of linear algebra: shell energies are eigenvalues, basis states are eigenvectors, and multiplicity governs filling. Comparison with observation supplies equally exact limits. The Coulomb model misses the third noble-gas closure, and the oscillator misses the fourth nuclear magic number. Orbital reordering and spin–orbit splitting are therefore not optional refinements; they are the mechanisms demanded by the mismatch.

Periodic tables are best understood as spectral maps. Their regularities record symmetry, their closures record cumulative multiplicity, and their apparent irregularities record the interactions that break ideal degeneracies.