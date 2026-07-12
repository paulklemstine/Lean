# Closed Geodesics and the Wrapping Lattice of the Flat Three-Torus

## Abstract

We give a self-contained and fully rigorous account of the geodesic and
homotopical structure of the **flat three-torus** $\mathbb{T}^3 = (\mathbb{R}/\mathbb{Z})^3$,
regarded as a model of a spatially closed ("donut-shaped") universe. Working in
the universal cover $\mathbb{R}^3$ and its integer-lattice quotient, we prove
four results. First, every straight line with an integer direction vector
projects to a **closed geodesic of period one** on the torus. Second, every
*nonzero* integer direction yields a genuinely **non-constant** loop, so the
torus is threaded by closed geodesics that actually wrap around it. Third, the
group of covering translations — equivalently, the fundamental group — is exactly
the integer lattice, giving $\pi_1(\mathbb{T}^3) \cong \mathbb{Z}^3$; its three
standard generators are $\mathbb{Z}$-linearly independent, yielding **three
independent families of wrapping**. Fourth, the assignment of an integer
direction to the free-homotopy class of its geodesic is **injective**, so the
torus carries a full $\mathbb{Z}^3$ of inequivalent closed geodesics. We then
develop the **wrapping spectrum** — the multiset of geodesic lengths as lattice
norms — and connect it to observational cosmology. Finally we record the
**minimal-volume problem** for closed hyperbolic three-manifolds and the
conjecture that the Weeks manifold, of volume $\approx 0.9427073627769277$, is
the unique minimizer.

**Keywords:** three-torus, closed geodesic, fundamental group, integer lattice,
covering space, flat manifold, systole, hyperbolic three-manifold, Weeks
manifold, cosmic topology.

---

## 1. Introduction

The global topology of the physical universe is not fixed by Einstein's field
equations, which are local. A spatial slice that is everywhere flat may
nonetheless be finite and multiply connected; the simplest such possibility is
the **three-torus** $\mathbb{T}^3$, popularized as the "donut-shaped" universe.
In such a cosmos a traveler moving on a straight path can return to the starting
point, and light can reach an observer along several distinct geodesic routes,
producing potentially observable repetitions (ghost images, matched circles in
the microwave background).

This paper isolates the mathematical core of that picture and proves it cleanly.
We model $\mathbb{T}^3$ as the quotient of $\mathbb{R}^3$ by the integer
translation lattice $\mathbb{Z}^3$, realize geodesics as projected straight
lines, and establish (i) closedness of integer-direction geodesics, (ii) their
genuine non-triviality, (iii) the identification of the covering-translation
group with $\mathbb{Z}^3$ and hence $\pi_1(\mathbb{T}^3) \cong \mathbb{Z}^3$
with three independent generators, and (iv) an injective correspondence between
integer directions and homotopy classes of closed geodesics. Around this core we
build the length ("wrapping") spectrum and its cosmological reading, and we frame
the minimal-volume problem in the hyperbolic setting.

All statements are elementary in the sense that they reduce to arithmetic on the
circle $\mathbb{R}/\mathbb{Z}$; no unproved topological input is used. Where we
invoke the phrase "fundamental group," we mean it in the concrete guise of the
covering-translation (deck) group, which for a universal covering of a manifold
is canonically isomorphic to $\pi_1$.

---

## 2. Definitions and setup

Throughout, $\mathbb{R}/\mathbb{Z}$ denotes the circle of circumference one,
i.e. the additive quotient group of the reals by the integers. For a real number
$r$ we write $[r] \in \mathbb{R}/\mathbb{Z}$ for its class. The key elementary
fact is:
$$[r] = 0 \iff r \in \mathbb{Z}, \qquad [r+m] = [r] \text{ for all } m \in \mathbb{Z}.$$

**Definition 2.1 (Flat three-torus).**
The *flat three-torus* is
$$\mathbb{T}^3 := (\mathbb{R}/\mathbb{Z})^3 = \{\, (u_0, u_1, u_2) : u_i \in \mathbb{R}/\mathbb{Z} \,\},$$
an abelian group under coordinatewise addition, equipped with the flat Riemannian
metric inherited from $\mathbb{R}^3$.

**Definition 2.2 (Covering projection).**
The *universal covering projection* is the group homomorphism
$$\pi : \mathbb{R}^3 \to \mathbb{T}^3, \qquad \pi(x_0, x_1, x_2) = ([x_0], [x_1], [x_2]).$$
It is a local isometry and a covering map; $\mathbb{R}^3$ is its universal cover.

**Definition 2.3 (Integer geodesic).**
For a direction vector $n = (n_0, n_1, n_2) \in \mathbb{Z}^3$ the *integer
geodesic* with direction $n$ is
$$\gamma_n : \mathbb{R} \to \mathbb{T}^3, \qquad \gamma_n(t) = \pi(t\,n) = ([t\,n_0], [t\,n_1], [t\,n_2]).$$
By construction $\gamma_n$ is the projection of the straight line $t \mapsto t\,n$
in the universal cover, hence a geodesic of the flat metric.

**Definition 2.4 (Wrapping lattice).**
The *wrapping lattice* is the image of the injection
$$\iota : \mathbb{Z}^3 \hookrightarrow \mathbb{R}^3, \qquad \iota(n) = (n_0, n_1, n_2),$$
the group of covering translations of $\pi$.

---

## 3. Closed geodesics

**Theorem 3.1 (Closedness / period one).**
For every $n \in \mathbb{Z}^3$ and every $t \in \mathbb{R}$,
$$\gamma_n(t + 1) = \gamma_n(t).$$
That is, every integer-direction geodesic is a closed loop of period one.

*Proof sketch.* Coordinatewise, $(t+1)n_i = t\,n_i + n_i$, and $n_i \in \mathbb{Z}$,
so $[(t+1)n_i] = [t\,n_i + n_i] = [t\,n_i]$ because adding an integer does not
change the class on the circle. As this holds in each coordinate,
$\gamma_n(t+1) = \gamma_n(t)$. $\qquad\blacksquare$

**Remark.** Closedness by itself is not enough to certify wrapping: the constant
path $\gamma_0$ is also period-one. The next theorem rules out this degeneracy.

**Theorem 3.2 (Non-triviality of wrapping).**
If $n \in \mathbb{Z}^3$ is nonzero, then $\gamma_n$ is non-constant; explicitly,
there is $t \in \mathbb{R}$ with $\gamma_n(t) \neq \gamma_n(0)$.

*Proof sketch.* Choose a coordinate $i$ with $n_i \neq 0$. Evaluate at the
half-period $t^\* = \tfrac{1}{2 n_i}$. Then the $i$-th coordinate is
$[t^\* n_i] = [\tfrac12]$. Now $[\tfrac12] = 0$ would require $\tfrac12 \in \mathbb{Z}$,
which is false; equivalently, $\tfrac12$ is the unique element of order two on the
circle and is distinct from $0$. Hence $\gamma_n(t^\*) \neq \gamma_n(0)$, so
$\gamma_n$ is non-constant. $\qquad\blacksquare$

**Corollary 3.3.** The flat three-torus contains infinitely many non-constant
closed geodesics — at least one for every nonzero $n \in \mathbb{Z}^3$. (That
they are genuinely distinct as homotopy classes is Theorem 5.2.)

---

## 4. The wrapping lattice and $\pi_1(\mathbb{T}^3) \cong \mathbb{Z}^3$

**Theorem 4.1 (Kernel of the covering projection).**
For $x \in \mathbb{R}^3$,
$$\pi(x) = 0 \iff x_i \in \mathbb{Z} \text{ for every } i.$$
Equivalently, $\ker \pi = \iota(\mathbb{Z}^3)$, the wrapping lattice.

*Proof sketch.* By definition $\pi(x) = 0$ means $[x_i] = 0$ for all $i$, and
$[x_i] = 0$ holds if and only if $x_i \in \mathbb{Z}$. Collecting the three
integer coordinates into a vector $m \in \mathbb{Z}^3$ gives $x = \iota(m)$;
conversely any $\iota(m)$ has all-integer coordinates and projects to $0$.
$\qquad\blacksquare$

**Theorem 4.2 (Faithfulness of the lattice).**
The map $\iota : \mathbb{Z}^3 \to \mathbb{R}^3$ is injective: distinct integer
vectors give distinct covering translations.

*Proof sketch.* If $\iota(a) = \iota(b)$ then $a_i = b_i$ as reals for each $i$;
since these are integers, $a = b$. $\qquad\blacksquare$

**Theorem 4.3 ($\pi_1(\mathbb{T}^3) \cong \mathbb{Z}^3$).**
The group of covering translations of the universal cover $\pi$ equals the image
of $\iota$, and $\iota$ is an injective group homomorphism. Hence the
fundamental group of the flat three-torus is free abelian of rank three:
$$\pi_1(\mathbb{T}^3) \;\cong\; \ker \pi \;=\; \iota(\mathbb{Z}^3) \;\cong\; \mathbb{Z}^3.$$

*Proof sketch.* By Theorem 4.1 the covering-translation group $\ker \pi$ is
exactly $\iota(\mathbb{Z}^3)$. By Theorem 4.2, $\iota$ is an injective
homomorphism, so it is an isomorphism onto its image. For a universal covering of
a (path-connected, locally nice) space, the deck-transformation group is
canonically isomorphic to $\pi_1$; therefore $\pi_1(\mathbb{T}^3) \cong \mathbb{Z}^3$.
$\qquad\blacksquare$

**Theorem 4.4 (Three independent families of wrapping).**
The three standard directions $e_0 = (1,0,0)$, $e_1 = (0,1,0)$, $e_2 = (0,0,1)$
are $\mathbb{Z}$-linearly independent and generate the wrapping lattice.
Consequently $\pi_1(\mathbb{T}^3)$ has exactly three independent generators, and
there are exactly three independent families of ways to loop around the donut
universe.

*Proof sketch.* The $e_i$ are the standard basis of the free $\mathbb{Z}$-module
$\mathbb{Z}^3$: a relation $\sum_i c_i e_i = 0$ reads coordinatewise as
$c_j = 0$ for each $j$, so they are independent; and every integer vector is
$\sum_i n_i e_i$, so they generate. The rank three is a topological invariant
(the first Betti number $b_1(\mathbb{T}^3) = 3$). $\qquad\blacksquare$

---

## 5. Homotopy classes of closed geodesics

We record the free-homotopy class of $\gamma_n$ by the endpoint of its canonical
lift starting at the origin. The lift of $\gamma_n$ through $0$ is the straight
line $t \mapsto t\,n$, whose value at $t = 1$ is the lattice point $\iota(n) \in \ker\pi$.

**Definition 5.1 (Homotopy class map).**
Let $c : \mathbb{Z}^3 \to \ker\pi$ be given by $c(n) = \iota(n)$. Since
$\iota(n)$ has all-integer coordinates, $c(n) \in \ker\pi$ by Theorem 4.1, and
$\pi(c(n)) = \gamma_n(1)$: projecting the lift's endpoint recovers the geodesic
at time one.

**Theorem 5.2 (Injectivity; infinitely many distinct geodesics).**
The map $c$ is injective. Hence distinct integer directions yield inequivalent
closed geodesics, and the flat three-torus supports a full $\mathbb{Z}^3$ of
distinct free-homotopy classes of closed geodesics.

*Proof sketch.* If $c(a) = c(b)$ then $\iota(a) = \iota(b)$, and by Theorem 4.2
$a = b$. Injectivity from the infinite set $\mathbb{Z}^3$ gives infinitely many
classes. $\qquad\blacksquare$

**Remark (primitivity).** A direction $n$ is *primitive* if $\gcd(n_0,n_1,n_2)=1$.
Non-primitive $n = d\,m$ ($d \ge 2$) traverses the same image as $m$ but $d$
times; the *primitive* closed geodesics are those with $\gcd = 1$, and they
biject with primitive lattice vectors. This is the geometric content underlying
the length spectrum below.

---

## 6. The wrapping spectrum

For a general flat torus $\mathbb{R}^3 / L$, where $L$ is a rank-three lattice
(the cubic case is $L = \mathbb{Z}^3$), the metric length of the closed geodesic
in the class of $v \in L$ is the Euclidean norm $\lVert v \rVert$. This turns a
dynamical question into a lattice-counting one.

**Definition 6.1 (Wrapping / length spectrum).**
The *wrapping spectrum* of $\mathbb{R}^3 / L$ is the multiset
$$\mathcal{L}(L) = \{\, \lVert v \rVert : v \in L \setminus \{0\} \,\},$$
and the *systole* is $\mathrm{sys}(L) = \min_{v \in L \setminus \{0\}} \lVert v \rVert$,
the length of the shortest non-constant closed geodesic.

**Proposition 6.2 (Cubic spectrum).**
For $L = \mathbb{Z}^3$ the distinct lengths are $\sqrt{k}$ where $k$ ranges over
positive integers expressible as a sum of three squares, i.e. all $k$ *not* of
the form $4^a(8b+7)$ (Legendre's three-square theorem). The systole is $1$,
attained by the six vectors $\pm e_i$. The number of geodesics of length
$\sqrt{k}$ is $r_3(k)$, the number of representations of $k$ as an ordered sum of
three squares.

*Proof sketch.* Lengths are norms $\sqrt{n_0^2+n_1^2+n_2^2}$; the set of
attainable $k = n_0^2+n_1^2+n_2^2$ is characterized by the three-square theorem,
and multiplicities are the representation counts $r_3(k)$. The minimum nonzero
norm is $1$. $\qquad\blacksquare$

**Conjecture 6.3 (Spectral rigidity of flat tori).**
The set of lengths of *primitive* closed geodesics of $\mathbb{R}^3 / L$ equals
the set of norms of primitive vectors of $L$, and the wrapping spectrum is a
complete isometry invariant of the flat torus up to finitely many exceptions.
(Distinct lattices can be isospectral, so "up to finitely many exceptions" is
necessary; the conjecture asserts that the failure set is small.)

---

## 7. Algorithms

We summarize three computational procedures used to explore the theory
numerically (implemented in the accompanying software).

**Algorithm A (Geodesic sampler and closure check).** Given $n \in \mathbb{Z}^3$
and a sample count $N$, compute $\gamma_n(t) = (t\,n \bmod 1)$ at $t = k/N$ and
verify $\gamma_n(t+1) = \gamma_n(t)$ to machine precision, and $\gamma_n(t^\*) \neq \gamma_n(0)$
at the half-period. Complexity $O(N)$.

**Algorithm B (Wrapping-spectrum enumeration).** Enumerate lattice vectors
$v \in \mathbb{Z}^3$ with $\lVert v \rVert \le R$ by iterating $|n_i| \le R$,
record norms and multiplicities $r_3(k)$, and read off the systole. Complexity
$O(R^3)$ vectors; the systole is found in the first shell.

**Algorithm C (Primitive-class counting).** For each shell $k$, count primitive
directions by inclusion–exclusion / gcd filtering, giving the number of
*distinct* primitive closed geodesics of length $\sqrt{k}$.

---

## 8. Applications: cosmic topology

If a spatial slice of the universe is a flat torus, multiple geodesic routes
connect any two points, so a single source can produce several images separated
by the wrapping vectors. Two concrete signatures follow directly from the results
above:

- **Ghost images / cosmic crystallography.** Repeated images of the same object
  are separated by lattice translations $\iota(n)$; the histogram of pairwise
  separations peaks at the wrapping spectrum $\mathcal{L}(L)$ of §6.
- **Matched circles in the microwave background.** If the diameter of the last
  scattering surface exceeds the systole, the sphere self-intersects across the
  identification, producing pairs of temperature circles matched by the deck
  translations of §4. Their angular radii are fixed by the systole and the
  spectrum.

These are falsifiable predictions: the *three independent generators* of
$\pi_1(\mathbb{T}^3)$ (Theorem 4.4) predict three fundamental matched-circle
families, and the spectrum (Prop. 6.2) predicts their sizes.

---

## 9. The minimal-volume problem for hyperbolic universes

Flat tori can be rescaled freely, so "smallest flat universe" is not well posed
without extra normalization. The situation changes dramatically under negative
curvature. By Mostow rigidity, a closed hyperbolic three-manifold of dimension
$\ge 3$ has its complete hyperbolic metric — and therefore its **volume** —
determined by its topology alone; volume becomes a topological invariant. It is
then meaningful to ask for the *smallest* such universe.

**Conjecture 9.1 (Minimality of the Weeks manifold).**
Among all closed orientable hyperbolic three-manifolds, the **Weeks manifold**
uniquely attains the minimal volume
$$V_{\text{Weeks}} \approx 0.9427073627769277,$$
and no closed orientable hyperbolic three-manifold has volume below $0.94$.

The Weeks manifold is obtained by $(5,1)$ and $(5,2)$ Dehn surgery on the two
components of the Whitehead link; it is arithmetic, with invariant trace field
$\mathbb{Q}(\sqrt{-3},\sqrt{5})$-related number fields, and its volume equals a
specific value of the Lobachevsky function. The set of volumes of closed
hyperbolic three-manifolds is a well-ordered subset of $\mathbb{R}$ (a
consequence of Thurston–Jørgensen theory), so a minimum exists; the conjecture is
that the Weeks manifold realizes it.

---

## 10. Discussion

The flat-torus results of §§3–5 are complete and elementary: closedness reduces
to "adding an integer is invisible on the circle," non-triviality to "one-half is
not an integer," and the fundamental-group computation to "projecting to zero
means all coordinates are integers." Their strength lies not in depth but in
airtight precision — in particular, in separating *periodicity* (trivially shared
by the constant loop) from genuine *wrapping*, and in rendering
$\pi_1 \cong \mathbb{Z}^3$ through the covering-translation group rather than by
appeal to heavier topological machinery.

The wrapping spectrum (§6) converts the geometry into number theory — sums of
three squares — and connects to observational cosmology (§8). The minimal-volume
problem (§9) points to the deep rigidity phenomena that distinguish curved from
flat universes.

---

## 11. Future directions

1. **Systolic wrapping spectrum of the flat torus.** For $\mathbb{R}^3 / L$, the
   set of primitive-geodesic lengths should equal the set of primitive-lattice
   norms, with systole equal to the minimal nonzero lattice norm, making the
   spectrum a near-complete isometry invariant. The abelian fundamental group
   makes each conjugacy class a single lattice vector, turning dynamics into
   lattice counting.

2. **Three-family rigidity of $\pi_1$.** Any closed flat three-manifold whose
   fundamental group is generated by exactly three independent commuting families
   of loops should be finitely covered by $\mathbb{T}^3$, with the number of
   independent families a homeomorphism invariant equal to the first Betti
   number — comparable against the Bieberbach classification of flat manifolds.

3. **Closed timelike curves from a temporal wrapping factor.** Adjoining a
   compact time circle $\mathbb{R}/\tau\mathbb{Z}$ to form a product Lorentzian
   structure should force closed timelike geodesics whose homotopy classes are
   the timelike vectors of the extended lattice $\mathbb{Z}^3 \times \mathbb{Z}$
   — causal pathology as a purely lattice-theoretic phenomenon, via the same
   integer-direction-closes-up mechanism.

4. **Minimality of the Weeks manifold.** Establish Conjecture 9.1 — that the
   Weeks manifold uniquely minimizes volume among closed orientable hyperbolic
   three-manifolds, with no such manifold below volume $0.94$.

---

## References (selected, standard)

- W. Thurston, *The Geometry and Topology of Three-Manifolds*.
- J. Weeks, *The Shape of Space*.
- R. Rucker, *The Fourth Dimension* (popular exposition of donut-shaped space).
- D. Gabai, R. Meyerhoff, P. Milley, *Minimum volume cusped hyperbolic
  three-manifolds* and related work on the closed minimal-volume problem.
- M. Lachièze-Rey, J.-P. Luminet, *Cosmic Topology* (matched circles, cosmic
  crystallography).
