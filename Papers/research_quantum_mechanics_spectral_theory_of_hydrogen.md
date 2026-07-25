# Spectral Thresholds, Azimuthal Modes, and the Bipartite Graph of Hydrogenic Dipole Transitions

**Aristotle**  
**July 25, 2026**

## Abstract

We develop a self-contained mathematical model connecting three structural aspects of the hydrogen atom in Rydberg units. First, we study the idealized spectral set consisting of bound energies $E_n=-1/n^2$ for positive integers $n$ together with the scattering continuum $[0,\infty)$. We prove that every bound energy is negative, the levels are strictly increasing, the discrete and continuous portions are disjoint, and zero is an accumulation point of the bound levels. Second, for every integer magnetic quantum number $m$, we analyze the azimuthal mode $\psi_m(\phi)=e^{im\phi}$, prove its $2\pi$-periodicity, compute its derivative, and establish the angular-momentum eigenvalue equation $L_z\psi_m=m\psi_m$ for $L_z=-i\,d/d\phi$. Third, we define an idealized electric-dipole transition graph on orbital states $(\ell,m)$ with $|m|\le\ell$, taking $\Delta\ell=\pm1$ and $|\Delta m|\le1$ as edge conditions. Orbital parity gives a two-coloring of this graph. More generally, a walk of length $k$ from $a$ to $b$ satisfies $(\ell_a+\ell_b)\bmod2=k\bmod2$. It follows that two-step transitions preserve parity and odd closed walks are impossible. We give algorithms for generating finite spectral windows and transition graphs, discuss computational applications, and state precisely the analytic and physical claims that remain outside the model.

## 1. Introduction

Hydrogen is the canonical meeting point of spectral analysis, rotational symmetry, and quantum selection rules. Its familiar bound energies exhibit an infinite discrete family converging to the ionization threshold. Its angular wavefunctions are organized by integer quantum numbers. Its spectroscopic transitions are constrained by changes in angular momentum, producing a network with strong combinatorial structure.

This paper isolates a rigorous core of that picture. The first component is a set-theoretic spectral model rather than an operator-theoretic spectral theorem. In Rydberg units, define the bound levels by $-1/n^2$ and append the nonnegative continuum. This simple definition already supports nontrivial topological conclusions: the bound levels approach zero, zero belongs to their closure, and the negative discrete part remains disjoint from the continuum.

The second component concerns rotation about the $z$-axis. The complex exponentials $e^{im\phi}$ are periodic exactly in the integer-labeled family relevant here, and differentiation turns their winding number into the eigenvalue of the azimuthal angular-momentum operator.

The third component translates dipole selection rules into graph theory. When an allowed transition changes $\ell$ by one, it necessarily reverses the parity of $\ell$. This makes the transition graph bipartite. Induction extends the edge rule to arbitrary walks: endpoint parity remembers path-length parity. The absence of odd cycles is therefore not an additional assumption but a global consequence of the local transition rule.

Care is required in interpreting these results. We do not construct the unbounded Coulomb Hamiltonian on $L^2(\mathbb{R}^3)$, prove self-adjointness, or identify its operator spectrum. We do not construct complete spherical harmonics or derive the dipole rules from matrix elements. Instead, we make the model and its boundaries explicit, then prove all conclusions that follow from it.

## 2. Spectral definitions and elementary structure

### 2.1 Rydberg normalization

Let

$$
\mathbb{N}_{+}=\{1,2,3,\ldots\}
$$

be the positive integers. We use Rydberg units, in which the hydrogenic ground-state energy is $-1$ and the ionization threshold is $0$.

**Definition 2.1 (Bohr energy).** For $n\in\mathbb{N}_{+}$, the bound-state energy is

$$
E_n=-\frac{1}{n^2}.
$$

**Definition 2.2 (Idealized hydrogenic spectral set).** The modeled spectral set is

$$
\Sigma_{\mathrm H}=\{E_n:n\in\mathbb{N}_{+}\}\cup[0,\infty).
$$

The subset $\Sigma_{\mathrm b}=\{E_n:n\in\mathbb{N}_{+}\}$ is called the bound portion, and $\Sigma_{\mathrm c}=[0,\infty)$ is called the scattering portion.

The terminology reflects the standard hydrogenic interpretation, but Definition 2.2 is a set model. It is not, by itself, an assertion that $\Sigma_{\mathrm H}$ is the spectrum of a specified self-adjoint operator.

### 2.2 Sign, low levels, and monotonicity

**Theorem 2.3 (Negativity of bound levels).** For every $n\in\mathbb{N}_{+}$,

$$
E_n<0.
$$

**Proof sketch.** Since $n>0$, one has $n^2>0$ and therefore $1/n^2>0$. Negating this positive number gives $E_n=-1/n^2<0$. $\square$

**Corollary 2.4 (Ground state and first levels).** The ground-state energy is $E_1=-1$, and the first four bound energies are

$$
E_1=-1,\qquad E_2=-\frac14,\qquad E_3=-\frac19,\qquad E_4=-\frac1{16}.
$$

**Proof sketch.** Substitute $n=1,2,3,4$ into Definition 2.1. $\square$

**Theorem 2.5 (Strict ordering).** If $a,b\in\mathbb{N}_{+}$ and $a<b$, then

$$
E_a<E_b.
$$

Thus the sequence $n\mapsto E_n$ is strictly increasing.

**Proof sketch.** Positive integers satisfy $a^2<b^2$. Taking positive reciprocals reverses this inequality, so $1/b^2<1/a^2$. Negation reverses it once more, giving $-1/a^2<-1/b^2$. $\square$

The sequence therefore rises toward the ionization threshold. “Increasing” here refers to the usual order on the real line: the values become less negative.

### 2.3 Threshold convergence and closure

**Theorem 2.6 (Threshold limit).** The bound energies converge to zero:

$$
\lim_{n\to\infty}E_n=0.
$$

Equivalently,

$$
\lim_{j\to\infty}-\frac{1}{(j+1)^2}=0.
$$

**Proof sketch.** Since $(j+1)^2\to\infty$, its reciprocal tends to zero. Multiplication by $-1$ preserves convergence and changes the limit only by a factor of $-1$, leaving zero fixed. More explicitly, for any $\varepsilon>0$, choose $j$ so large that $(j+1)^2>1/\varepsilon$. Then $|E_{j+1}|=1/(j+1)^2<\varepsilon$. $\square$

**Theorem 2.7 (Accumulation at ionization).** Zero belongs to the topological closure of the bound portion $\Sigma_{\mathrm b}$. Equivalently, every open neighborhood of $0$ contains a bound energy.

**Proof sketch.** The sequence $E_{j+1}$ lies entirely in $\Sigma_{\mathrm b}$ and converges to $0$ by Theorem 2.6. A limit of a sequence drawn from a set belongs to that set’s closure. $\square$

It is important to distinguish membership from closure membership. Zero is not equal to $-1/n^2$ for any positive integer $n$, so $0\notin\Sigma_{\mathrm b}$. Nevertheless $0\in\overline{\Sigma_{\mathrm b}}$. In the full modeled set, $0\in\Sigma_{\mathrm c}$.

**Theorem 2.8 (Separation of bound and scattering portions).** The sets $\Sigma_{\mathrm b}$ and $\Sigma_{\mathrm c}$ are disjoint:

$$
\Sigma_{\mathrm b}\cap\Sigma_{\mathrm c}=\varnothing.
$$

**Proof sketch.** Every element of $\Sigma_{\mathrm b}$ is negative by Theorem 2.3, whereas every element of $\Sigma_{\mathrm c}=[0,\infty)$ is nonnegative. No real number is both negative and nonnegative. $\square$

Taken together, Theorems 2.6–2.8 describe a discrete family accumulating exactly at the boundary of a disjoint continuum. The distance between the two sets is zero even though their intersection is empty.

## 3. Azimuthal angular-momentum modes

### 3.1 Definition and single-valuedness

Let $\phi\in\mathbb{R}$ denote the azimuthal angle. Although physical angles are identified modulo $2\pi$, it is convenient to define functions on $\mathbb{R}$ and prove periodicity.

**Definition 3.1 (Azimuthal mode).** For an integer $m\in\mathbb{Z}$, define

$$
\psi_m(\phi)=\exp(im\phi).
$$

**Theorem 3.2 (Full-rotation periodicity).** For every $m\in\mathbb{Z}$ and $\phi\in\mathbb{R}$,

$$
\psi_m(\phi+2\pi)=\psi_m(\phi).
$$

**Proof sketch.** The exponential addition rule gives

$$
\psi_m(\phi+2\pi)=e^{im\phi}e^{2\pi im}.
$$

For integer $m$, Euler’s identity implies $e^{2\pi im}=1$. Hence the product equals $e^{im\phi}=\psi_m(\phi)$. $\square$

The integer restriction is the winding condition. The phase completes $m$ signed turns as $\phi$ completes one positive revolution. Negative $m$ reverses the orientation; $m=0$ yields the constant function $1$.

### 3.2 Differentiation and the eigenvalue equation

**Lemma 3.3 (Derivative of an azimuthal mode).** For every integer $m$,

$$
\frac{d}{d\phi}\psi_m(\phi)=im\psi_m(\phi).
$$

**Proof sketch.** Apply the chain rule to $e^{im\phi}$. The derivative of the exponent $im\phi$ is $im$, and the complex exponential is its own derivative. $\square$

**Definition 3.4 (Azimuthal angular momentum).** In dimensionless units, define

$$
L_z=-i\frac{d}{d\phi}.
$$

Restoring physical units would multiply this operator by $\hbar$.

**Theorem 3.5 (Azimuthal angular-momentum eigenvalue).** For every $m\in\mathbb{Z}$,

$$
L_z\psi_m=m\psi_m.
$$

**Proof sketch.** By Lemma 3.3,

$$
L_z\psi_m=-i(im\psi_m)=m\psi_m,
$$

because $-i^2=1$. $\square$

This theorem identifies the winding number $m$ with the dimensionless $z$-component angular-momentum eigenvalue. It addresses only the azimuthal factor. A complete spherical harmonic has the form of a normalized polar factor multiplied by $e^{im\phi}$ and additionally satisfies a total-angular-momentum equation with eigenvalue $\ell(\ell+1)$.

## 4. The idealized dipole transition graph

### 4.1 Orbital states and edges

**Definition 4.1 (Orbital state).** An orbital state is a pair

$$
a=(\ell_a,m_a)
$$

with $\ell_a\in\mathbb{Z}_{\ge0}$, $m_a\in\mathbb{Z}$, and $|m_a|\le\ell_a$.

The inequality $|m_a|\le\ell_a$ is the standard range condition for magnetic quantum numbers at fixed orbital quantum number.

**Definition 4.2 (Idealized electric-dipole allowedness).** Two orbital states $a=(\ell_a,m_a)$ and $b=(\ell_b,m_b)$ are connected by an allowed transition when

$$
\bigl(\ell_b=\ell_a+1\ \text{or}\ \ell_a=\ell_b+1\bigr)
\quad\text{and}\quad
|m_a-m_b|\le1.
$$

The first condition is $\Delta\ell=\pm1$. Since $m_a-m_b$ is integral, the second condition is equivalent to $\Delta m\in\{-1,0,1\}$.

This definition encodes the familiar orbital electric-dipole selection rule. It does not derive that rule from the electric-dipole operator or an integral of wavefunctions.

**Proposition 4.3 (Symmetry of allowedness).** If a transition from $a$ to $b$ is allowed, then the transition from $b$ to $a$ is allowed.

**Proof sketch.** The alternative $\ell_b=\ell_a+1$ or $\ell_a=\ell_b+1$ is unchanged when the endpoints are exchanged. Moreover, $|m_a-m_b|=|m_b-m_a|$. $\square$

Thus orbital states can be treated as vertices of an undirected graph, with allowed transitions as edges.

### 4.2 Parity coloring

**Definition 4.4 (Orbital parity color).** Assign to a state $a$ the color

$$
c(a)=\ell_a\bmod2\in\{0,1\}.
$$

Color $0$ represents even $\ell$ and color $1$ represents odd $\ell$.

**Theorem 4.5 (Every dipole edge crosses parity).** If $a$ and $b$ are connected by an allowed transition, then

$$
c(a)\ne c(b).
$$

**Proof sketch.** Allowedness requires $|\ell_a-\ell_b|=1$. Consecutive integers have opposite parity, so their residues modulo $2$ differ. The magnetic condition plays no role in this parity conclusion. $\square$

**Corollary 4.6 (Bipartiteness).** The idealized dipole transition graph is bipartite. One part consists of states with even $\ell$, and the other consists of states with odd $\ell$.

This graph-theoretic reformulation is useful because bipartiteness is global: a local selection rule at each edge constrains all possible paths and cycles.

## 5. Walk parity and cycle exclusion

### 5.1 Walks

**Definition 5.1 (Dipole walk).** A dipole walk of length $k$ from state $a$ to state $b$ is a sequence of states

$$
a=v_0,v_1,\ldots,v_k=b
$$

such that each consecutive pair $v_{j-1},v_j$ is connected by an allowed transition. The length is the number of edges, so the stationary walk from a state to itself has length $0$.

**Theorem 5.2 (Walk-parity law).** Let a dipole walk of length $k$ join states $a=(\ell_a,m_a)$ and $b=(\ell_b,m_b)$. Then

$$
(\ell_a+\ell_b)\bmod2=k\bmod2.
$$

Equivalently, the endpoint colors satisfy

$$
c(b)=c(a)+k\pmod2.
$$

**Proof sketch.** Proceed by induction on $k$. For $k=0$, the endpoints coincide, and $\ell_a+\ell_a=2\ell_a$ is even. For the induction step, separate the first edge $a\to v_1$ from the remaining walk. The first edge changes $\ell$ by one and therefore flips parity. Increasing the path length from $k$ to $k+1$ also flips its parity. Applying the induction hypothesis to the remaining walk proves that the two sides continue to agree. $\square$

This result may also be viewed as repeated application of Theorem 4.5: each edge toggles one bit, so after $k$ edges that bit has been toggled $k$ times.

### 5.2 Consequences

**Corollary 5.3 (Two-step parity preservation).** If $a\to b\to c$ consists of two allowed transitions, then

$$
c(a)=c(c).
$$

**Proof sketch.** Apply Theorem 5.2 with $k=2$. Since $2\bmod2=0$, the endpoints have equal parity. $\square$

**Theorem 5.4 (No odd closed dipole walk).** There is no closed dipole walk of odd length. In particular, the transition graph has no odd cycle.

**Proof sketch.** For a closed walk, $a=b$, so

$$
(\ell_a+\ell_b)\bmod2=(2\ell_a)\bmod2=0.
$$

Theorem 5.2 then gives $k\bmod2=0$. Thus $k$ is even, contradicting the assumption that it is odd. $\square$

Theorem 5.4 is equivalent to bipartiteness for an undirected graph, but Theorem 5.2 is stronger as a usable invariant: it tells us the required parity of every path between specified endpoints.

## 6. Algorithms and numerical realization

The preceding results lead naturally to finite computations. Such computations illustrate the theory but do not replace the general arguments.

### 6.1 Bound-spectrum enumeration

Given a cutoff $N\ge1$, compute

$$
(E_1,E_2,\ldots,E_N)=\left(-1,-\frac14,\ldots,-\frac1{N^2}\right).
$$

**Algorithm 6.1 (Finite bound-spectrum generator).**

1. Validate that $N$ is a positive integer.
2. For each $n$ from $1$ through $N$, calculate $-1/n^2$.
3. Return the ordered list.
4. Optionally verify strict increase by checking $E_n<E_{n+1}$.

The algorithm takes $O(N)$ time and $O(N)$ output space. If values are streamed rather than stored, auxiliary space is $O(1)$. The threshold convergence can be visualized by plotting the values against $n$ with a horizontal line at $0$.

### 6.2 Finite transition graph construction

Fix $L\ge0$. Generate all orbital states

$$
V_L=\{(\ell,m):0\le\ell\le L,\ -\ell\le m\le\ell\}.
$$

The number of vertices is

$$
|V_L|=\sum_{\ell=0}^{L}(2\ell+1)=(L+1)^2.
$$

Rather than test every pair of vertices, exploit the selection rule. For each $(\ell,m)$, inspect only states with $\ell+1$ and magnetic labels $m-1,m,m+1$ that remain valid. This generates each undirected edge once. Because each vertex has at most three such forward neighbors, construction takes $O(|V_L|)=O(L^2)$ time and $O(|V_L|+|E_L|)=O(L^2)$ space.

A breadth-first search then finds shortest allowed transition chains. The walk-parity theorem supplies a consistency check: if the endpoints have equal $\ell$ parity, every discovered path length must be even; if they have opposite parity, every path length must be odd.

### 6.3 Azimuthal sampling

For chosen $m$ and sample angles $\phi_j$, compute

$$
\psi_m(\phi_j)=\cos(m\phi_j)+i\sin(m\phi_j).
$$

Sampling $P$ angles costs $O(P)$ time and $O(P)$ space if all samples are retained. Numerically one can compare $\psi_m(\phi)$ with $\psi_m(\phi+2\pi)$ and compare $-i(im\psi_m)$ with $m\psi_m$. Floating-point equality should be assessed with a tolerance because numerical approximations to $\pi$ and complex exponentials introduce rounding error.

## 7. Applications and interpretation

### 7.1 Spectral line crowding

The limit $E_n\to0$ explains why levels become crowded near ionization. The adjacent gap is

$$
E_{n+1}-E_n=\frac{1}{n^2}-\frac{1}{(n+1)^2}
=\frac{2n+1}{n^2(n+1)^2},
$$

which is positive and tends to zero. Thus strict ordering coexists with shrinking separation. This behavior is relevant when choosing numerical truncations: a fixed energy resolution resolves fewer distinct levels near threshold.

### 7.2 Rotational symmetry

The relation $L_z\psi_m=m\psi_m$ links periodic geometry to an observable label. Complex exponentials diagonalize differentiation on the circle. The hydrogenic interpretation is one instance of Fourier analysis: integer characters of the circle are eigenfunctions of its infinitesimal rotation generator.

### 7.3 Transition-network pruning

In finite-state searches, parity gives an inexpensive rejection criterion. If a desired route from $a$ to $b$ is required to use exactly $k$ dipole edges, then the route is impossible unless

$$
(\ell_a+\ell_b)\bmod2=k\bmod2.
$$

This test is constant-time and can be applied before graph traversal. The absence of odd cycles also permits standard bipartite-graph methods and provides a diagnostic for incorrectly generated edges.

### 7.4 Scope of the physical claims

The spectral statements concern the explicitly defined set $\Sigma_{\mathrm H}$. To identify it with the spectrum of a physical Hamiltonian, one must define

$$
H=-\Delta-\frac{2}{r}
$$

as an unbounded self-adjoint operator on $L^2(\mathbb{R}^3)$, specify its domain or construct it through a closed semibounded quadratic form, and analyze both point and continuous spectrum. The singular potential at $r=0$ and behavior at spatial infinity require functional analysis absent from the present set model.

Likewise, Definition 4.2 encodes selection rules. A derivation would define the electric-dipole operator and prove that matrix elements vanish except when the angular conditions hold. Radial overlap can further determine whether an angularly allowed transition has nonzero amplitude. The graph studied here should therefore be read as the graph of transitions allowed by the stated angular rule, not as a complete intensity-weighted spectroscopic network.

## 8. Discussion

### 8.1 Logical independence and synthesis

The three parts of the model are mathematically complementary but logically distinct. The spectral conclusions follow from the real sequence $-1/n^2$ and elementary topology; they do not require angular quantum numbers. The azimuthal eigenvalue equation follows from complex differentiation and periodicity; it does not depend on the energy formula. The graph results follow from integer parity and the chosen edge rule; they do not require either spectral convergence or differentiation.

Their synthesis becomes meaningful when one interprets the labels as aspects of hydrogenic states. A transition may change energy and angular labels simultaneously. The energy difference determines an idealized photon energy, while the graph determines whether the angular labels satisfy the one-step rule. If a transition joins principal levels $n_i$ and $n_f$, then the magnitude of the modeled energy change is

$$
|E_{n_f}-E_{n_i}|=\left|\frac{1}{n_i^2}-\frac{1}{n_f^2}\right|.
$$

The present graph does not include $n$, so it cannot by itself attach this weight to an edge. Adding $n$ to each vertex would permit a weighted transition network. One could then ask for shortest paths in number of photons, minimum or maximum total emitted energy under directed decay constraints, or connectivity after radial-overlap conditions are imposed.

### 8.2 Structural theme

The results reveal a common mathematical mechanism: integer data control qualitative structure.

The positive integer $n$ indexes an infinite discrete spectrum and controls its approach to a threshold. The integer $m$ is a winding number that becomes an angular-momentum eigenvalue. The residue of $\ell$ modulo $2$ colors the transition graph and records path-length parity.

The spectral and graph components also display two kinds of boundary behavior. In energy space, the discrete sequence approaches the continuum boundary without entering the continuum. In the transition graph, every edge crosses the boundary between two parity classes, but two edges return to the original class. One is topological accumulation; the other is combinatorial alternation.

The model is intentionally minimal. That minimality makes the logical dependence transparent. Negativity and monotonicity use only arithmetic. Accumulation uses elementary limits and closure. The $L_z$ eigenvalue equation uses the chain rule and $i^2=-1$. Bipartiteness uses only the fact that allowed transitions change $\ell$ by one. No stronger physical assertion is needed for these conclusions.

## 9. Future work

Several extensions would move from this structural model toward a fuller mathematical account of hydrogen.

1. **Coulomb Hamiltonian as an unbounded self-adjoint operator.** Define $H=-\Delta-2/r$ on $L^2(\mathbb{R}^3)$ from a closed semibounded quadratic form, establish self-adjointness, and prove that its operator spectrum is exactly the set modeled here.

2. **Full spherical harmonics.** Construct associated Legendre functions and normalized $Y_\ell^m$, then prove both $L_zY_\ell^m=mY_\ell^m$ and $L^2Y_\ell^m=\ell(\ell+1)Y_\ell^m$. The present result proves the azimuthal factor of the first equation.

3. **Derivation of selection rules.** Define the electric-dipole operator, spherical tensor components, and relevant inner products. Prove vanishing matrix elements using parity and angular orthogonality, so that $\Delta\ell=\pm1$ and $\Delta m\in\{-1,0,1\}$ emerge as theorems rather than edge definitions.

4. **Graph structure beyond bipartiteness.** Add principal quantum numbers and radial overlap conditions to vertices and edges. Study connected components, shortest allowed transition sequences, and weighted paths whose weights are emitted photon energies.

5. **Spectral multiplicity and hidden symmetry.** Develop the Runge–Lenz symmetry and the $\mathfrak{so}(4)$ representation underlying the $n^2$ orbital degeneracy, connecting operator eigenspaces to finite-dimensional representation theory.

## 10. Conclusion

For the idealized hydrogenic set

$$
\Sigma_{\mathrm H}=\left\{-\frac1{n^2}:n\in\mathbb{N}_{+}\right\}\cup[0,\infty),
$$

the negative levels are strictly increasing and converge to zero, zero lies in their closure, and the bound and scattering portions are disjoint. For every integer $m$, the periodic mode $e^{im\phi}$ satisfies the dimensionless eigenvalue equation $L_z\psi_m=m\psi_m$. For orbital states obeying $|m|\le\ell$, the idealized dipole rule $\Delta\ell=\pm1$ and $|\Delta m|\le1$ defines a symmetric transition graph. Orbital parity bipartitions that graph, and every walk satisfies

$$
(\ell_a+\ell_b)\bmod2=k\bmod2.
$$

Consequently, two-step transitions preserve parity and odd closed walks cannot occur. These results provide a precise bridge from hydrogenic quantum numbers to topology, Fourier modes, and graph invariants while clearly separating the model from the deeper operator theory and matrix-element analysis needed for a complete treatment.