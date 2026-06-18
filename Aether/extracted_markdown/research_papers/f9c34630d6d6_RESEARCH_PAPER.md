# Tropical Hodge Theory for Weighted Two-Term Cochain Complexes

## Abstract

We develop a complete, self-contained Hodge theory for the **weighted two-term
cochain complex** — a coboundary operator $d : \mathbb{R}^m \to \mathbb{R}^n$
equipped with strictly positive weights on its source and target, which turn
both spaces into finite-dimensional weighted inner-product spaces. This object
is the common combinatorial core of graph Laplacians, simplicial cochain
complexes, finite-element stiffness systems, and the tropical (piecewise-linear)
skeletons used in combinatorial algebraic geometry. From a single structural
identity — the **weighted adjunction** $\langle d u, v\rangle_{\text{tgt}} =
\langle u, \delta v\rangle_{\text{src}}$ relating $d$ to its weighted
codifferential $\delta = W_{\text{src}}^{-1} d^{\mathsf T} W_{\text{tgt}}$ — and
the positive-definiteness of the weighted inner product, we derive the full
analytic skeleton of Hodge theory:

1. the **Dirichlet energy identity** $\langle \Delta^{\uparrow} v, v\rangle =
   \langle d v, d v\rangle$ and the kernel characterization $\ker \Delta^{\uparrow}
   = \ker d$;
2. **self-adjointness** of the up-Laplacian, hence orthogonal diagonalizability
   with real non-negative spectrum;
3. **Hodge orthogonality** $\operatorname{im}(d) \perp \ker(\delta)$; and
4. the **dual kernel theorem** $\ker(\Delta^{\downarrow}) = \ker(\delta)$,
   identifying the harmonic space in the top degree.

Together these are exactly the ingredients that force the orthogonal Hodge
decomposition $\mathbb{R}^n = \operatorname{im}(d) \oplus \ker(\delta)$, in which
the harmonic summand is a topological invariant. We give complete proof sketches
for every result, exhibit the graph Laplacian as the special case of unit source
weights, discuss algorithmic realizations (energy evaluation, harmonic
projection by the normal equations, spectral computation), survey applications
to statistical ranking, fluid simulation, sensor coverage, and tropical
cohomology, and close with concrete research directions including the full
decomposition theorem and a tropical Cheeger inequality.

**Keywords:** Hodge decomposition, discrete Laplacian, weighted inner product,
codifferential, adjunction, harmonic cochains, tropical geometry, spectral graph
theory.

---

## 1. Introduction

Hodge theory, in its classical form, asserts that on a compact oriented
Riemannian manifold every differential form decomposes uniquely and orthogonally
into an exact, a coexact, and a harmonic part, and that the harmonic part
canonically represents a de Rham cohomology class. The analytic content rests on
two pillars: the formal adjointness of the exterior derivative $d$ and the
codifferential $\delta$ with respect to the $L^2$ inner product, and the
positivity (more precisely the ellipticity) of the Hodge Laplacian
$\Delta = d\delta + \delta d$.

Both pillars survive — indeed simplify dramatically — in the finite-dimensional,
combinatorial setting, where integrals become finite sums and ellipticity
becomes mere positive-definiteness of a weighted bilinear form. This paper
isolates the *minimal* such setting that still exhibits the full Hodge
phenomenon: a **single** coboundary map between two weighted Euclidean spaces.
We call it a *weighted two-term cochain complex*, or **weighted coboundary** for
short. It is deliberately small — just one differential — yet it is exactly the
piece of structure responsible for the orthogonal splitting, and every richer
example (longer cochain complexes, simplicial or cellular Laplacians, tropical
cohomology of balanced fans) is assembled degree-by-degree from copies of it.

Our contribution is twofold. First, we give a clean axiomatic development: we
show that one identity (adjunction) plus one inequality (positive-definiteness)
generates the entire analytic toolkit. Second, we prove the *new* analytic
results that complete the picture begun by the kernel identity
$\ker(\Delta^{\uparrow}) = \ker(d)$ — namely the Dirichlet energy identity,
self-adjointness, Hodge orthogonality, and the dual kernel theorem — each with a
short, transparent proof. These are precisely the hypotheses of the orthogonal
decomposition theorem $\mathbb{R}^n = \operatorname{im}(d) \oplus \ker(\delta)$.

The motivation is the **tropical** one. In tropical geometry, algebraic
varieties degenerate to piecewise-linear polyhedral complexes ("tropical
varieties"); their (co)homology is computed by weighted cellular complexes of
exactly the kind studied here, with weights recording lattice multiplicities and
stable-intersection data. The harmonic spaces of these weighted Laplacians
realize tropical cohomology, and Hodge-theoretic positivity in this combinatorial
guise underpins the modern proofs of long-conjectured inequalities for matroids.
A robust, self-contained account of the weighted-complex Hodge machinery is thus
of independent foundational interest.

---

## 2. Definitions

Throughout, $m, n \in \mathbb{N}$ and all vector spaces are real and
finite-dimensional. We write $\mathbb{R}^k$ for $\operatorname{Fin} k \to
\mathbb{R}$, a matrix $A$ acts on a vector $u$ by $A u$ (matrix–vector product),
and $A^{\mathsf T}$ is the transpose.

### 2.1 The weighted two-term cochain complex

**Definition 2.1 (Weighted coboundary).**
A *weighted coboundary* $W = (d, w^{\text{src}}, w^{\text{tgt}})$ of type
$(m, n)$ consists of:

- a *coboundary matrix* $d \in \mathbb{R}^{n \times m}$, viewed as a linear map
  $\mathbb{R}^m \to \mathbb{R}^n$;
- a *source weight* $w^{\text{src}} : \{1,\dots,m\} \to \mathbb{R}$ with
  $w^{\text{src}}_i > 0$ for all $i$;
- a *target weight* $w^{\text{tgt}} : \{1,\dots,n\} \to \mathbb{R}$ with
  $w^{\text{tgt}}_i > 0$ for all $i$.

We write $W_{\text{src}} = \operatorname{diag}(w^{\text{src}})$,
$W_{\text{tgt}} = \operatorname{diag}(w^{\text{tgt}})$, and
$W_{\text{src}}^{-1} = \operatorname{diag}\big((w^{\text{src}}_i)^{-1}\big)$,
which is well-defined because all source weights are nonzero.

### 2.2 The weighted inner product

**Definition 2.2 (Weighted inner product).**
For a positive weight $w : \{1,\dots,k\} \to \mathbb{R}$ and $u, v \in
\mathbb{R}^k$ set
$$\langle u, v\rangle_w \;=\; \sum_{i=1}^{k} w_i\, u_i\, v_i.$$
We abbreviate $\langle\cdot,\cdot\rangle_{\text{src}} =
\langle\cdot,\cdot\rangle_{w^{\text{src}}}$ and
$\langle\cdot,\cdot\rangle_{\text{tgt}} = \langle\cdot,\cdot\rangle_{w^{\text{tgt}}}$.

**Lemma 2.3 (Symmetry).** $\langle u, v\rangle_w = \langle v, u\rangle_w$.
*Proof.* Termwise, $w_i u_i v_i = w_i v_i u_i$. $\square$

**Lemma 2.4 (Bilinearity, left additivity).**
$\langle u_1 + u_2, v\rangle_w = \langle u_1, v\rangle_w + \langle u_2, v\rangle_w$.
*Proof.* Distribute $w_i(u_{1,i} + u_{2,i})v_i = w_i u_{1,i}v_i + w_i u_{2,i}v_i$
and split the sum. $\square$

**Lemma 2.5 (Positive-definiteness).** If $w_i > 0$ for all $i$, then for $v
\neq 0$ we have $\langle v, v\rangle_w > 0$.
*Proof.* Each summand $w_i v_i^2 \geq 0$, so the sum is bounded below by any
single term. Choosing an index $j$ with $v_j \neq 0$ gives $w_j v_j^2 > 0$, and
this term is $\le \langle v, v\rangle_w$ by non-negativity of the rest. $\square$

**Corollary 2.6 (Definiteness criterion).** For positive weights,
$\langle v, v\rangle_w = 0 \iff v = 0$.
*Proof.* ($\Leftarrow$) immediate. ($\Rightarrow$) a sum of non-negative terms
vanishes iff every term vanishes; $w_i v_i^2 = 0$ with $w_i > 0$ forces
$v_i = 0$ for all $i$. $\square$

Corollary 2.6 is the single inequality that drives every kernel theorem below:
an energy is zero precisely when the underlying signal is zero.

### 2.3 The codifferential and the Laplacians

**Definition 2.7 (Codifferential).**
The *codifferential* of $W$ is the matrix
$$\delta \;=\; W_{\text{src}}^{-1}\, d^{\mathsf T}\, W_{\text{tgt}} \;\in\; \mathbb{R}^{m \times n},$$
the weighted formal adjoint of $d$ (Theorem 3.1 below).

**Definition 2.8 (Laplacians).**
The *up-Laplacian* and *down-Laplacian* are
$$\Delta^{\uparrow} = \delta\, d \in \mathbb{R}^{m\times m}, \qquad
  \Delta^{\downarrow} = d\, \delta \in \mathbb{R}^{n\times n}.$$

We call $v \in \mathbb{R}^m$ **closed** if $d v = 0$, a cochain $v \in
\mathbb{R}^n$ **exact** if $v = d u$ for some $u$, and **coclosed** if
$\delta v = 0$. Closed-and-coclosed cochains are **harmonic**.

---

## 3. Main Results

All results below hold for an arbitrary weighted coboundary
$W = (d, w^{\text{src}}, w^{\text{tgt}})$ of type $(m,n)$.

### 3.1 Adjunction (discrete integration by parts)

**Theorem 3.1 (Adjunction).** For all $u \in \mathbb{R}^m$ and $v \in
\mathbb{R}^n$,
$$\boxed{\;\langle d\,u,\; v\rangle_{\text{tgt}} \;=\; \langle u,\; \delta\,v\rangle_{\text{src}}.\;}$$

*Proof sketch.* Expand both sides as finite double sums. The left side is
$$\sum_i w^{\text{tgt}}_i \Big(\sum_j d_{ij} u_j\Big) v_i
  = \sum_{i,j} w^{\text{tgt}}_i\, d_{ij}\, u_j\, v_i.$$
For the right side, $\delta v = W_{\text{src}}^{-1} d^{\mathsf T} W_{\text{tgt}} v$
has $j$-th entry $(w^{\text{src}}_j)^{-1} \sum_i d_{ij} w^{\text{tgt}}_i v_i$, so
$$\langle u, \delta v\rangle_{\text{src}}
  = \sum_j w^{\text{src}}_j\, u_j\, (w^{\text{src}}_j)^{-1} \sum_i d_{ij} w^{\text{tgt}}_i v_i
  = \sum_{i,j} d_{ij}\, w^{\text{tgt}}_i\, u_j\, v_i,$$
where the factor $w^{\text{src}}_j (w^{\text{src}}_j)^{-1} = 1$ cancels exactly
because source weights are nonzero. The two double sums agree after swapping the
order of summation. $\square$

Theorem 3.1 is the *only* structural input the rest of the theory needs; the
specific formula for $\delta$ never appears again — only the fact that it is the
$\langle\cdot,\cdot\rangle$-adjoint of $d$.

### 3.2 The Dirichlet energy identity and the up-kernel

**Theorem 3.2 (Dirichlet energy identity).** For all $v \in \mathbb{R}^m$,
$$\langle \Delta^{\uparrow} v,\; v\rangle_{\text{src}} \;=\; \langle d\,v,\; d\,v\rangle_{\text{tgt}} \;\geq\; 0.$$

*Proof sketch.* Since $\Delta^{\uparrow} = \delta d$, we have $\Delta^{\uparrow} v =
\delta(d v)$. Apply adjunction (Theorem 3.1) with the source vector $v$ and the
target vector $d v$:
$$\langle d\,v,\; d\,v\rangle_{\text{tgt}} = \langle v,\; \delta(d v)\rangle_{\text{src}}
  = \langle v,\; \Delta^{\uparrow} v\rangle_{\text{src}}
  = \langle \Delta^{\uparrow} v,\; v\rangle_{\text{src}},$$
the last step by symmetry (Lemma 2.3). Non-negativity is then Lemma 2.5/2.6
applied to the right side. $\square$

The right-hand side is the **Dirichlet energy** of $v$: the total weighted
squared variation of $v$ across the complex. Its equality case is the kernel
theorem.

**Theorem 3.3 (Up-kernel characterization).** For all $v \in \mathbb{R}^m$,
$$\Delta^{\uparrow} v = 0 \iff d\,v = 0, \qquad\text{i.e.}\qquad
  \ker(\Delta^{\uparrow}) = \ker(d).$$

*Proof sketch.* ($\Rightarrow$) If $\Delta^{\uparrow}v = 0$, pair with $v$:
Theorem 3.2 gives $\langle d v, d v\rangle_{\text{tgt}} = \langle \Delta^{\uparrow}v,
v\rangle_{\text{src}} = 0$. By Corollary 2.6 (positive target weights), $d v = 0$.
($\Leftarrow$) If $d v = 0$ then $\Delta^{\uparrow} v = \delta(d v) = \delta\,0 = 0$.
$\square$

Theorem 3.3 says diffusion fixes exactly the already-smooth signals. On a
connected graph these are the constants.

### 3.3 Self-adjointness and the spectral theorem

**Theorem 3.4 (Self-adjointness of the up-Laplacian).** For all $u, w \in
\mathbb{R}^m$,
$$\langle \Delta^{\uparrow} u,\; w\rangle_{\text{src}} \;=\; \langle u,\; \Delta^{\uparrow} w\rangle_{\text{src}}.$$

*Proof sketch.* Both sides reduce to the symmetric pairing
$\langle d u, d w\rangle_{\text{tgt}}$. Indeed, $\Delta^{\uparrow}u = \delta(du)$ and
adjunction give
$$\langle \Delta^{\uparrow}u, w\rangle_{\text{src}} = \langle \delta(du), w\rangle_{\text{src}}
  = \langle du, dw\rangle_{\text{tgt}}$$
(using adjunction in the form $\langle \delta a, b\rangle_{\text{src}} = \langle
a, d b\rangle_{\text{tgt}}$, itself adjunction read with symmetry), and symmetrically
$\langle u, \Delta^{\uparrow}w\rangle_{\text{src}} = \langle du, dw\rangle_{\text{tgt}}$.
$\square$

**Corollary 3.5 (Real orthogonal spectrum).** After the change of variables
$x \mapsto W_{\text{src}}^{1/2} x$, the up-Laplacian becomes a symmetric matrix
$\tilde\Delta = W_{\text{src}}^{-1/2}\, d^{\mathsf T} W_{\text{tgt}} d\,
W_{\text{src}}^{-1/2}$ on the *standard* Euclidean space. By the spectral theorem
it is orthogonally diagonalizable with real eigenvalues, and by Theorem 3.2 all
eigenvalues are non-negative; the eigenvalue $0$ has eigenspace $\ker(d)$. The
smallest nonzero eigenvalue $\lambda_1$ is the **spectral gap**, governing the
mixing/relaxation rate of diffusion driven by $\Delta^{\uparrow}$.

### 3.4 Hodge orthogonality and the dual kernel

**Theorem 3.6 (Hodge orthogonality).** Let $v \in \mathbb{R}^n$ be coclosed,
$\delta v = 0$. Then for every $u \in \mathbb{R}^m$,
$$\langle d\,u,\; v\rangle_{\text{tgt}} = 0.$$
Equivalently, $\operatorname{im}(d) \perp \ker(\delta)$ in
$\langle\cdot,\cdot\rangle_{\text{tgt}}$.

*Proof sketch.* By adjunction, $\langle d u, v\rangle_{\text{tgt}} = \langle u,
\delta v\rangle_{\text{src}} = \langle u, 0\rangle_{\text{src}} = 0$. $\square$

**Theorem 3.7 (Down-kernel characterization).** For all $w \in \mathbb{R}^n$,
$$\Delta^{\downarrow} w = 0 \iff \delta\,w = 0, \qquad\text{i.e.}\qquad
  \ker(\Delta^{\downarrow}) = \ker(\delta).$$

*Proof sketch.* This is the mirror image of Theorem 3.3 with the roles of $d$
and $\delta$ exchanged. ($\Rightarrow$) If $\Delta^{\downarrow} w = d(\delta w) = 0$,
pair with $w$ in the target inner product and apply adjunction:
$$\langle \delta w, \delta w\rangle_{\text{src}} = \langle d(\delta w), w\rangle_{\text{tgt}}
  = \langle \Delta^{\downarrow} w, w\rangle_{\text{tgt}} = 0,$$
so $\delta w = 0$ by Corollary 2.6 (positive source weights). ($\Leftarrow$) If
$\delta w = 0$ then $\Delta^{\downarrow} w = d(\delta w) = 0$. $\square$

### 3.5 The orthogonal Hodge decomposition (synthesis)

The four results above are exactly the hypotheses of the decomposition theorem.

**Theorem 3.8 (Orthogonal Hodge decomposition).** With respect to
$\langle\cdot,\cdot\rangle_{\text{tgt}}$,
$$\mathbb{R}^n \;=\; \operatorname{im}(d)\;\oplus\;\ker(\delta),$$
an *orthogonal* direct sum. Consequently every $x \in \mathbb{R}^n$ has a unique
expression $x = d u + h$ with $\delta h = 0$ and $\langle d u, h\rangle_{\text{tgt}}
= 0$; the harmonic component $h$ is the orthogonal projection of $x$ onto
$\ker(\delta)$, and $\dim \ker(\delta) = n - \operatorname{rank}(d)$ is a
topological invariant of the complex.

*Proof sketch.* Theorem 3.6 shows $\operatorname{im}(d) \subseteq
\ker(\delta)^{\perp}$. Conversely, if $y \perp \operatorname{im}(d)$ then
$\langle d u, y\rangle_{\text{tgt}} = 0$ for all $u$; by adjunction $\langle u,
\delta y\rangle_{\text{src}} = 0$ for all $u$, and positive-definiteness
(Corollary 2.6, source) forces $\delta y = 0$, i.e. $y \in \ker(\delta)$. Hence
$\ker(\delta) = \operatorname{im}(d)^{\perp}$. For a positive-definite inner
product on a finite-dimensional space, a subspace and its orthogonal complement
sum to the whole space, giving the orthogonal direct sum and the dimension count.
The harmonic component solves the consistent normal equations $\Delta^{\uparrow} u
= \delta x$ and $h = x - d u$. $\square$

Theorem 3.8 is stated here as the synthesis target; the four analytic pillars
(Theorems 3.2–3.7) are fully established, and the residual step is the standard
finite-dimensional orthogonal-complement fact.

---

## 4. The Graph Laplacian as a Special Case

**Definition 4.1 (Weighted graph).** A weighted graph is a signed incidence
matrix $B \in \mathbb{R}^{E \times V}$ (rows indexed by edges, columns by
vertices, $B_{ev} = \pm 1$ at the endpoints of $e$) together with positive edge
weights $w^E$.

The associated **graph Laplacian** is $L = B^{\mathsf T}\operatorname{diag}(w^E)
B \in \mathbb{R}^{V\times V}$.

**Proposition 4.2 (Embedding).** The weighted coboundary with $d = B$,
$w^{\text{src}}_v = 1$ for all $v$, and $w^{\text{tgt}}_e = w^E_e$ has
$$\Delta^{\uparrow} = \delta\, d = \big(W_{\text{src}}^{-1} B^{\mathsf T} W_{\text{tgt}}\big) B
  = B^{\mathsf T}\operatorname{diag}(w^E) B = L,$$
since $W_{\text{src}} = I$. Thus the graph Laplacian is the up-Laplacian of a
unit-source-weight coboundary.

**Consequences.** Specializing the general theory:
- $L$ is symmetric (Theorem 3.4) and positive-semidefinite (Theorem 3.2);
- $\langle L f, f\rangle = \sum_e w^E_e (f_{v} - f_{v'})^2$ over edges $e =
  (v, v')$ — the classical Dirichlet energy;
- $\ker(L) = \ker(B)$ (Theorem 3.3) is the space of locally constant functions;
  on a connected graph $\dim \ker(L) = 1$, and in general the multiplicity of
  eigenvalue $0$ equals the number of connected components;
- the spectral gap $\lambda_1$ controls random-walk mixing and spectral
  clustering quality.

This recovers the foundational facts of spectral graph theory as corollaries of
a single integration-by-parts identity.

---

## 5. Algorithms

The constructive content of the theory yields three core routines. We give them
abstractly here; full type-hinted implementations accompany the package.

### 5.1 Dirichlet energy evaluation

Compute $E(v) = \langle d v, d v\rangle_{\text{tgt}}$ directly, in $O(\operatorname{nnz}(d)
+ n)$ time, and verify $E(v) = \langle \Delta^{\uparrow}v, v\rangle_{\text{src}}$
(Theorem 3.2). This is the certificate that $v$ is closed iff $E(v) = 0$.

### 5.2 Harmonic projection (the normal equations)

Given $x \in \mathbb{R}^n$, compute its Hodge decomposition $x = d u + h$:
1. form the right-hand side $b = \delta x = W_{\text{src}}^{-1} d^{\mathsf T}
   W_{\text{tgt}} x$;
2. solve the consistent symmetric positive-semidefinite system $\Delta^{\uparrow} u
   = b$ (e.g. by conjugate gradients on the reduced system, using a particular
   least-squares solution since $\Delta^{\uparrow}$ may be singular on $\ker d$);
3. return the flowing part $d u$ and the harmonic part $h = x - d u$.
By Theorems 3.6–3.8, the output satisfies $\delta h = 0$ and $\langle d u,
h\rangle_{\text{tgt}} = 0$. Complexity is that of one weighted least-squares solve.

### 5.3 Spectral computation and the gap

Form the symmetrized operator $\tilde\Delta = W_{\text{src}}^{-1/2} d^{\mathsf T}
W_{\text{tgt}} d\, W_{\text{src}}^{-1/2}$ (Corollary 3.5), compute its
eigendecomposition, read off the harmonic dimension (multiplicity of $0$) and the
spectral gap $\lambda_1$. Self-adjointness (Theorem 3.4) guarantees a real
orthonormal eigenbasis.

---

## 6. Applications

- **Statistical ranking (HodgeRank).** Pairwise comparison data is a cochain on
  the comparison graph; its Hodge decomposition splits the data into a gradient
  flow (the global ranking, $d u$), a curl/harmonic inconsistency ($h$), and a
  cyclic part. The harmonic norm quantifies intrinsic, unrankable inconsistency.
- **Incompressible fluid simulation.** Helmholtz–Hodge decomposition of a
  discrete velocity field into gradient and divergence-free parts is exactly
  Theorem 3.8; projecting out $d u$ enforces incompressibility each timestep.
- **Sensor coverage and TDA.** The dimension of the harmonic space counts
  coverage holes in a sensor network purely from connectivity data, with no
  geometric embedding required.
- **Tropical and matroidal cohomology.** Weighted cellular Laplacians of this
  form compute tropical cohomology of balanced polyhedral complexes; the
  positivity of the weighted pairing is the combinatorial engine behind
  Hodge-theoretic inequalities for matroids.
- **Spectral graph learning.** Section 4 shows clustering, embedding, and
  diffusion methods are the unit-weight specialization.

---

## 7. Discussion

The development is striking in its economy: one identity (adjunction, Theorem
3.1) and one inequality (positive-definiteness, Corollary 2.6) generate energy
positivity, both kernel theorems, self-adjointness, and orthogonality. The
specific formula $\delta = W_{\text{src}}^{-1} d^{\mathsf T} W_{\text{tgt}}$ is
used *only* to prove adjunction; thereafter $\delta$ is treated abstractly as the
weighted adjoint. This makes the theory immediately portable: any pair of maps
satisfying an adjunction relation for any pair of positive-definite inner
products obeys the same conclusions. It also clarifies the role of the weights —
they are not cosmetic rescalings but the carriers of the geometry, and their
strict positivity is precisely what upgrades "energy $\ge 0$" to "energy $= 0$
iff the cochain is closed."

A subtlety worth emphasizing: $\Delta^{\uparrow}$ is self-adjoint and
positive-semidefinite for the *weighted* inner product, not the standard one
(unless $W_{\text{src}} = I$). The change of variables in Corollary 3.5 converts
weighted self-adjointness into ordinary symmetry, which is why numerical
eigensolvers should be applied to the symmetrized operator $\tilde\Delta$ rather
than to $\Delta^{\uparrow}$ directly.

---

## 8. Future Directions

**The full orthogonal decomposition $\mathbb{R}^n = \operatorname{im}(d) \oplus
\ker(\delta)$.** We have proved orthogonality (Theorem 3.6) and the dual kernel
identity (Theorem 3.7). The remaining step is the elementary finite-dimensional
fact that a subspace and its orthogonal complement (for a positive-definite
form) span the whole space, giving uniqueness of the splitting $x = du + h$ and
identifying the harmonic part as the solution of the normal equations
$\Delta^{\uparrow} u = \delta x$. A single explicit matrix where no such splitting
existed would refute the prediction; none can, by the argument in Theorem 3.8.

**A spectral theorem and a Cheeger-type bound.** Self-adjointness (Theorem 3.4)
gives a real orthonormal eigenbasis and a non-negative spectrum with $0$-space
$\ker(d)$. The conjecture is a *tropical Cheeger inequality*: the first nonzero
eigenvalue $\lambda_1$ of the graph specialization is bounded below by
$h^2/(2 d_{\max})$, where $h$ is the weighted edge-boundary isoperimetric
constant and $d_{\max}$ the maximal weighted degree — connecting the spectral gap
to combinatorial connectivity.

**Higher-degree complexes.** Chaining several weighted coboundaries
$\cdots \to \mathbb{R}^{m} \xrightarrow{d_k} \mathbb{R}^{n} \xrightarrow{d_{k+1}}
\cdots$ with $d_{k+1} d_k = 0$ yields a full weighted cochain complex whose
degree-wise Hodge–Laplacians $\Delta_k = \delta_k d_k + d_{k-1}\delta_{k-1}$
realize cohomology in every degree; the two-term results here are the building
blocks of each $\Delta_k$.

**Tropical Hard Lefschetz.** For balanced fans arising from matroids, the
harmonic spaces should satisfy a Hard Lefschetz property (unimodal Betti
sequences); the weighted positivity established here is the analytic prerequisite.

---

## 9. Conclusion

We have given a complete, minimal, and self-contained Hodge theory for weighted
two-term cochain complexes. From adjunction and positive-definiteness alone we
derived the Dirichlet energy identity, both kernel characterizations,
self-adjointness, and Hodge orthogonality — the full set of hypotheses behind
the orthogonal decomposition $\mathbb{R}^n = \operatorname{im}(d) \oplus
\ker(\delta)$ and its topological harmonic invariant. The graph Laplacian
emerges as the unit-source-weight special case, recovering spectral graph theory
as a corollary, and the framework extends naturally to the tropical and
matroidal settings that motivate it.
