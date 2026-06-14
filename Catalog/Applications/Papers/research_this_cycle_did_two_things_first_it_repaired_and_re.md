# Discrete Hodge Theory for Message Passing: Decomposition, Cohomology, and Spectral Convergence

## Abstract

We develop, from first principles and in full rigor, the linear-algebraic core of
discrete Hodge theory on finite-dimensional inner product spaces, and we use it to
give a complete account of the asymptotics of linearized message passing on graphs
and simplicial complexes. The objects of study are two-step cochain complexes
$U \xrightarrow{\,e\,} V \xrightarrow{\,d\,} W$ of finite-dimensional real inner
product spaces satisfying the chain condition $d \circ e = 0$, together with the
combinatorial **Hodge Laplacian** $\Delta = d^{*}d + e\,e^{*}$ on the middle space
$V$.

Our results form a single connected chain. (1) A Dirichlet-energy identity
$\langle \Delta x, x\rangle = \lVert dx\rVert^2 + \lVert e^{*}x\rVert^2$ shows
$\Delta$ is positive semidefinite and yields the **discrete Hodge theorem**
$\ker \Delta = \ker d \cap \ker e^{*}$. (2) Orthogonal rank–nullity converts this
into the **Hodge–Betti identity** $\dim\ker\Delta + \operatorname{rank} e =
\dim\ker d$, exhibiting the harmonic dimension as a Betti number. (3) Iterated
orthogonal complementation produces the **strong three-way decomposition**
$V = \operatorname{im} d^{*} \oplus \operatorname{im} e \oplus \ker\Delta$ with
pairwise-orthogonal, jointly-spanning, dimension-additive summands. (4) Inside the
closed space, the exact and harmonic parts are complementary, giving the **Hodge
isomorphism** $\ker d / \operatorname{im} e \cong \ker\Delta$ — each cohomology
class has a unique harmonic representative — and a **Pythagorean minimality**
result identifying that representative as the norm-minimizer of its class. (5)
Modeling one message-passing layer as the linear operator $T = I - \alpha\Delta$,
we prove that harmonic cochains are exact fixed points at every depth while the
residual contracts geometrically; we obtain an explicit, spectrum-uniform depth
threshold, the per-layer contraction factor $1 - \alpha\mu(2-\alpha\lambda)$, and
the optimality of the spectral step $\alpha = 1/\lambda$ with rate
$1 - \mu/\lambda$. Every result is established constructively. We close with
algorithms, applications to topological data analysis and graph learning, and a
program of future directions toward a full operator-algebra of Hodge projectors.

**Keywords:** discrete Hodge theory, combinatorial Hodge Laplacian, cohomology,
Betti numbers, orthogonal decomposition, message passing, graph neural networks,
spectral gap, oversmoothing.

---

## 1. Introduction

Hodge theory, in its classical analytic form, decomposes the differential forms on
a compact Riemannian manifold into exact, coexact, and harmonic components, and
identifies the harmonic forms with the de Rham cohomology. The discrete or
*combinatorial* version replaces forms by cochains on a graph or simplicial
complex and differential operators by incidence matrices. What is lost in
analytic depth is gained in computational immediacy: the entire theory becomes
finite-dimensional linear algebra, every operator is an honest matrix, and every
theorem is checkable on a computer.

This finite-dimensional theory has become unexpectedly central to machine
learning. A graph neural network propagates information by *message passing* —
local averaging of features across edges — and its linearization is precisely an
iteration of $I - \alpha L$ for a graph Laplacian $L$. Higher-order networks on
simplicial complexes use the full Hodge Laplacian $\Delta = d^{*}d + ee^{*}$. The
behavior of these models as depth grows — convergence, the celebrated
*oversmoothing* phenomenon, the emergence of topological features — is governed
entirely by the spectral geometry of $\Delta$.

This paper assembles a self-contained, fully rigorous development of that spectral
geometry. We work at the level of abstract finite-dimensional real inner product
spaces (so all results are basis-free and apply verbatim to any inner product
structure), descending to explicit matrices where it aids intuition. The narrative
arc runs from a single sum-of-squares identity to a sharp convergence theorem for
deep message passing, passing through cohomology and the Hodge isomorphism on the
way.

### 1.1 Setup and standing conventions

Throughout, $U$, $V$, $W$ are finite-dimensional real inner product spaces with
inner product $\langle\cdot,\cdot\rangle$ and induced norm $\lVert\cdot\rVert$. We
fix linear maps
$$ U \xrightarrow{\;e\;} V \xrightarrow{\;d\;} W, \qquad d \circ e = 0
\quad(\text{the chain condition}). $$
We write $d^{*} : W \to V$ and $e^{*} : V \to U$ for the adjoints, characterized by
$\langle d x, w\rangle = \langle x, d^{*} w\rangle$ and
$\langle e u, x\rangle = \langle u, e^{*} x\rangle$. For a subspace $K \le V$,
$K^{\perp}$ denotes its orthogonal complement; $\ker$, $\operatorname{im}$
(equivalently $\operatorname{range}$), and $\dim$ have their usual meanings.

The matrix incarnation, useful for computation, takes $d$ to be a matrix
$D : C_k \to C_{k-1}$ (a discrete divergence, the *down* map) and $e$ to be
$E : C_{k+1} \to C_k$ (a discrete curl/boundary, the *up* map), with the chain
condition reading $D E = 0$, and $\Delta = D^{\top}D + E E^{\top}$.

---

## 2. The Hodge Laplacian and the discrete Hodge theorem

### 2.1 Definition

**Definition 2.1 (Combinatorial Hodge Laplacian).**
The Hodge Laplacian on the middle space $V$ is
$$ \Delta \;=\; d^{*}d \;+\; e\,e^{*} \;:\; V \to V. $$
The summand $d^{*}d$ is the **down (or lower) Laplacian** and $ee^{*}$ is the
**up (or upper) Laplacian**.

### 2.2 The split Dirichlet energy

The foundation of everything below is a single identity.

**Theorem 2.2 (Quadratic-form identity).** For all $x \in V$,
$$ \langle \Delta x,\, x\rangle \;=\; \langle dx, dx\rangle + \langle e^{*}x, e^{*}x\rangle
\;=\; \lVert dx\rVert^2 + \lVert e^{*}x\rVert^2. $$

*Proof sketch.* Expand $\langle \Delta x, x\rangle = \langle d^{*}dx, x\rangle +
\langle e e^{*} x, x\rangle$ using additivity of the inner product. The first term
is $\langle d^{*}dx, x\rangle = \langle dx, dx\rangle$ by the adjunction defining
$d^{*}$. For the second, $\langle e e^{*} x, x\rangle = \langle e^{*}x, e^{*}x\rangle$
by the adjunction defining $e^{*}$ (after one use of symmetry of the real inner
product). $\square$

**Corollary 2.3 (Positive semidefiniteness).** $\langle \Delta x, x\rangle \ge 0$
for all $x$, since it is a sum of two squared norms.

### 2.3 Adjoint kernels and the Hodge theorem

**Lemma 2.4 (Coclosed = perpendicular to gradients).** For any linear map
$e : U \to V$,
$$ \ker(e^{*}) = (\operatorname{im} e)^{\perp}. $$

*Proof sketch.* $e^{*}x = 0$ iff $\langle e^{*}x, u\rangle = 0$ for all $u$, which
by the adjunction $\langle e^{*}x, u\rangle = \langle x, eu\rangle$ holds iff $x$
is orthogonal to every $eu$, i.e. $x \in (\operatorname{im} e)^{\perp}$. The
forward direction uses $\langle x, eu\rangle = \langle e^{*}x, u\rangle = 0$; the
reverse sets $u = e^{*}x$ to force $\langle e^{*}x, e^{*}x\rangle = 0$, hence
$e^{*}x = 0$. $\square$

**Theorem 2.5 (Discrete Hodge theorem).**
$$ \ker \Delta \;=\; \ker d \;\cap\; \ker e^{*}. $$

*Proof sketch.* If $\Delta x = 0$ then $\langle \Delta x, x\rangle = 0$, so by
Theorem 2.2 the sum $\lVert dx\rVert^2 + \lVert e^{*}x\rVert^2 = 0$; both terms
are non-negative, so each vanishes, giving $dx = 0$ and $e^{*}x = 0$. Conversely,
if $dx = 0$ and $e^{*}x = 0$ then $\Delta x = d^{*}(dx) + e(e^{*}x) = 0$. $\square$

Combining Theorem 2.5 with Lemma 2.4, the harmonic space is exactly the part of
the closed space $\ker d$ that is orthogonal to the gradients:
$$ \ker\Delta = \ker d \cap (\operatorname{im} e)^{\perp}. $$

**Lemma 2.6 (Chain inclusion).** Under $d\circ e = 0$,
$\operatorname{im} e \le \ker d$.

*Proof sketch.* For $v = eu$, $dv = d(eu) = (d\circ e)u = 0$. $\square$

The matrix versions of these facts hold verbatim. Writing the full matrix Hodge
Laplacian $L = D^{\top}D + EE^{\top}$:

- $L$ is symmetric: $(D^\top D + E E^\top)^\top = D^\top D + E E^\top$.
- $x^\top L x = \lVert Dx\rVert^2 + \lVert E^\top x\rVert^2 \ge 0$ (PSD).
- $Lx = 0 \iff Dx = 0 \text{ and } E^\top x = 0$ (harmonic = closed & coclosed).
- Under $DE = 0$, $\langle Ey, D^\top z\rangle = 0$ for all $y, z$ (the gradient
  image is orthogonal to the divergence image), whence the **Hodge–Pythagoras**
  identity $\lVert Ey + D^\top z\rVert^2 = \lVert Ey\rVert^2 + \lVert D^\top z\rVert^2$.

---

## 3. Betti numbers from the harmonic kernel

### 3.1 The Hodge–Betti identity

**Theorem 3.1 (Hodge–Betti identity).** Under $d \circ e = 0$,
$$ \dim(\ker\Delta) + \dim(\operatorname{im} e) = \dim(\ker d). $$
Equivalently $\dim\ker\Delta = \dim\ker d - \operatorname{rank} e$.

*Proof sketch.* By Theorem 2.5 and Lemma 2.4,
$\ker\Delta = (\operatorname{im} e)^{\perp} \cap \ker d$. With $K_1 =
\operatorname{im} e \le K_2 = \ker d$ (Lemma 2.6), orthogonal rank–nullity inside
the inner product space gives
$$ \dim K_1 + \dim(K_1^{\perp} \cap K_2) = \dim K_2, $$
which is exactly the claim. The subtraction form follows since the quantities are
natural numbers satisfying the additive identity. $\square$

The number $b := \dim\ker\Delta$ is a **Betti number** of the complex: it is the
dimension of the cohomology $H = \ker d / \operatorname{im} e$ (made precise in
§5). Theorem 3.1 is therefore a *local-to-global* principle in its purest discrete
form: a global topological invariant is computed from the ranks and kernels of two
local incidence operators.

---

## 4. The strong three-way Hodge decomposition

We now upgrade the dimension count to a full orthogonal direct-sum decomposition of
$V$.

### 4.1 Coexact = perpendicular to closed

**Lemma 4.1.** $(\ker d)^{\perp} = \operatorname{im} d^{*}.$

*Proof sketch.* Apply Lemma 2.4 to $d^{*}$ in place of $e$:
$\ker(d^{**}) = (\operatorname{im} d^{*})^{\perp}$, and $d^{**} = d$, so
$\ker d = (\operatorname{im} d^{*})^{\perp}$. Taking orthogonal complements and
using $K^{\perp\perp} = K$ for the finite-dimensional $K = \operatorname{im} d^{*}$
gives the claim. $\square$

### 4.2 Pairwise orthogonality of the three summands

Define the three subspaces:
$$ \text{coexact } = \operatorname{im} d^{*}, \qquad
   \text{exact } = \operatorname{im} e, \qquad
   \text{harmonic } = \ker\Delta. $$

**Lemma 4.2 (Pairwise orthogonality).** Under $d\circ e = 0$:
1. $\operatorname{im} e \le (\operatorname{im} d^{*})^{\perp}$ (exact $\perp$ coexact);
2. $\ker\Delta \le (\operatorname{im} e)^{\perp}$ (harmonic $\perp$ exact);
3. $\ker\Delta \le (\operatorname{im} d^{*})^{\perp}$ (harmonic $\perp$ coexact).

*Proof sketch.* (1) $\operatorname{im} e \le \ker d = (\operatorname{im} d^{*})^{\perp}$
by Lemma 2.6 and Lemma 4.1. (2) By Theorem 2.5 and Lemma 2.4,
$\ker\Delta \le \ker e^{*} = (\operatorname{im} e)^{\perp}$. (3) By Theorem 2.5,
$\ker\Delta \le \ker d = (\operatorname{im} d^{*})^{\perp}$. $\square$

### 4.3 Hodge split of the closed space, span, and dimension

**Theorem 4.3 (Hodge split of closed cochains).** Under $d\circ e = 0$,
$$ \operatorname{im} e \;\oplus\; \ker\Delta \;=\; \ker d, $$
an orthogonal direct sum.

*Proof sketch.* Disjointness is Lemma 4.2(2) together with
$K \cap K^{\perp} = 0$. For the sum, with $K_1 = \operatorname{im} e \le K_2 =
\ker d$, the relative orthogonal-complement identity
$K_1 \oplus (K_1^{\perp} \cap K_2) = K_2$ applies, and
$K_1^{\perp} \cap K_2 = (\operatorname{im} e)^{\perp} \cap \ker d = \ker\Delta$.
$\square$

**Theorem 4.4 (Three-way span).** Under $d\circ e = 0$,
$$ \operatorname{im} d^{*} \;+\; \operatorname{im} e \;+\; \ker\Delta \;=\; V. $$

*Proof sketch.* Reassociate as $\operatorname{im} d^{*} + (\operatorname{im} e +
\ker\Delta)$; the inner sum collapses to $\ker d$ by Theorem 4.3; then
$\operatorname{im} d^{*} = (\ker d)^{\perp}$ (Lemma 4.1) and $K^{\perp} + K = V$
finish it. $\square$

**Theorem 4.5 (Dimension count).** Under $d\circ e = 0$,
$$ \dim(\operatorname{im} d^{*}) + \dim(\operatorname{im} e) + \dim(\ker\Delta) = \dim V. $$

*Proof sketch.* Combine $\dim\operatorname{im} d^{*} = \dim(\ker d)^{\perp}$
(Lemma 4.1), the orthogonal complement dimension identity
$\dim\ker d + \dim(\ker d)^{\perp} = \dim V$, and the Hodge–Betti identity
(Theorem 3.1). $\square$

Together, Lemma 4.2 and Theorems 4.3–4.5 express the cochain space as an internal
orthogonal direct sum
$$ \boxed{\,V = \operatorname{im} d^{*} \;\oplus\; \operatorname{im} e \;\oplus\; \ker\Delta\,} $$
— the **strong (three-way) Hodge decomposition**: coexact $\oplus$ exact $\oplus$
harmonic.

---

## 5. The Hodge isomorphism and minimal representatives

### 5.1 Cohomology and the Hodge isomorphism

The **cohomology** of the complex is the quotient $H = \ker d / \operatorname{im} e$
(closed modulo exact). Theorem 3.1 already shows $\dim H = \dim\ker\Delta$. We
upgrade this to a canonical isomorphism.

**Lemma 5.1 (Harmonics are closed).** $\ker\Delta \le \ker d$.

*Proof sketch.* Immediate from Theorem 2.5: $\ker\Delta = \ker d \cap \ker e^{*}
\le \ker d$. $\square$

**Lemma 5.2 (Harmonic $\cap$ exact $= 0$).**
$\ker\Delta \cap \operatorname{im} e = \{0\}.$

*Proof sketch.* By Lemma 4.2(2), $\ker\Delta \le (\operatorname{im} e)^{\perp}$,
so the intersection lies in $(\operatorname{im} e)^{\perp} \cap \operatorname{im} e
= \{0\}$. $\square$

**Theorem 5.3 (Existence and uniqueness of harmonic representatives).** Under
$d \circ e = 0$:
- *(Existence)* every closed cochain $x \in \ker d$ can be written $x = e u + h$
  with $h \in \ker\Delta$;
- *(Uniqueness)* if $h_1, h_2 \in \ker\Delta$ and $h_1 - h_2 \in \operatorname{im} e$
  then $h_1 = h_2$.

*Proof sketch.* Existence is membership in the sup $\ker d = \operatorname{im} e
\oplus \ker\Delta$ (Theorem 4.3). Uniqueness: $h_1 - h_2 \in \ker\Delta \cap
\operatorname{im} e = \{0\}$ by Lemma 5.2. $\square$

**Theorem 5.4 (Hodge isomorphism).** Under $d\circ e = 0$ there is a canonical
linear isomorphism
$$ H = \ker d / \operatorname{im} e \;\xrightarrow{\;\cong\;}\; \ker\Delta. $$

*Proof sketch.* Inside the ambient space $\ker d$, the exact part
$\operatorname{im} e$ and harmonic part $\ker\Delta$ are complementary: they are
disjoint (Lemma 5.2) and codisjoint (Theorem 4.3). Quotienting $\ker d$ by a
complemented submodule is isomorphic to the complementary submodule, which is
$\ker\Delta$ (re-identified with itself via the inclusion $\ker\Delta \le \ker d$
of Lemma 5.1). $\square$

The isomorphism assigns to each cohomology class its unique harmonic
representative.

### 5.2 Minimal-norm property

**Theorem 5.5 (Pythagorean minimality).** Let $h \in \ker\Delta$ be harmonic. For
any $u \in U$,
$$ \lVert h + e u\rVert^2 = \lVert h\rVert^2 + \lVert e u\rVert^2, $$
and consequently $\lVert h\rVert \le \lVert y\rVert$ for every $y$ cohomologous to
$h$ (i.e. $y = h + eu$). The harmonic representative is the unique norm-minimizer of
its cohomology class.

*Proof sketch.* By Lemma 4.2(2), $h \perp eu$, so
$\lVert h + eu\rVert^2 = \lVert h\rVert^2 + 2\langle h, eu\rangle +
\lVert eu\rVert^2 = \lVert h\rVert^2 + \lVert eu\rVert^2 \ge \lVert h\rVert^2$,
with equality iff $eu = 0$. $\square$

Theorem 5.5 means the Hodge isomorphism is, in fact, a quotient *isometry*: the
quotient norm of a cohomology class equals the norm of its harmonic
representative, because the quotient norm is the infimum of $\lVert x - eu\rVert$
and that infimum is attained exactly at the harmonic representative.

---

## 6. Convergence of message passing

We now model deep, linearized message passing and analyze its asymptotics. Let
$E$ be a real inner product space and $L : E \to E$ a linear operator (think of
$L = \Delta$, or any symmetric PSD operator built from boundary maps).

### 6.1 The message-passing layer

**Definition 6.1 (Message-passing layer).** One layer of (affine-free) gradient
message passing with step $\alpha$ is the linear operator
$$ T = I - \alpha L, \qquad T x = x - \alpha (L x). $$
Depth-$k$ message passing is the iterate $T^k$.

Because $T$ is linear, $T^k$ is linear, and the two structural facts below follow
"for free" from $\operatorname{map\_add}$ and $\operatorname{map\_smul}$.

### 6.2 Harmonics are exact fixed points

**Theorem 6.2 (Harmonic invariance).** If $L h = 0$ then $T^k h = h$ for all $k$.
More generally, for any residual $r$,
$$ T^k(h + r) = h + T^k r. $$

*Proof sketch.* $T h = h - \alpha\cdot 0 = h$; iterate by induction on $k$. The
additive transport follows from linearity of $T^k$. $\square$

This is the abstract form of *topology is depth-invariant*: the harmonic (=
cohomology) component is carried through every layer untouched.

### 6.3 Geometric contraction of the residual

**Theorem 6.3 (Per-layer contraction).** Suppose $0 \le \alpha$ and
$\alpha\lambda \le 2$, and that $L$ obeys the Rayleigh bounds
$\mu\langle x, x\rangle \le \langle x, Lx\rangle$ and
$\langle Lx, Lx\rangle \le \lambda\langle x, Lx\rangle$ for all $x$. Then for
all $x$,
$$ \langle T x, T x\rangle \;\le\; \bigl(1 - \alpha\mu(2 - \alpha\lambda)\bigr)\,\langle x, x\rangle. $$

*Proof sketch.* Expand $\langle Tx, Tx\rangle = \langle x,x\rangle - 2\alpha\langle x, Lx\rangle
+ \alpha^2\langle Lx, Lx\rangle$. Bound $\langle Lx, Lx\rangle \le \lambda\langle x, Lx\rangle$
and then $\langle x, Lx\rangle \ge \mu\langle x, x\rangle$, using $\alpha \ge 0$
and $\alpha\lambda \le 2$. Collecting terms gives the stated factor. $\square$

**Theorem 6.4 (Geometric decay across depth).** If a single layer contracts every
energy by $\rho \ge 0$, i.e. $\langle Tx, Tx\rangle \le \rho\langle x, x\rangle$
for all $x$, then $\langle T^k r, T^k r\rangle \le \rho^k \langle r, r\rangle$.

*Proof sketch.* Induction on $k$:
$\langle T^{k+1} r, T^{k+1} r\rangle \le \rho \langle T^k r, T^k r\rangle \le
\rho\cdot\rho^k\langle r,r\rangle$, using $\rho \ge 0$. $\square$

### 6.4 Convergence to the harmonic component

**Theorem 6.5 (Distance-to-harmonics bound).** With $L h = 0$ and a layer that
contracts every energy by $\rho \ge 0$,
$$ \langle T^k(h+r) - h,\; T^k(h+r) - h\rangle \;\le\; \rho^k\,\langle r, r\rangle. $$

*Proof sketch.* By Theorem 6.2 the gap equals $T^k r$, whose energy is bounded by
Theorem 6.4. $\square$

**Theorem 6.6 (Finite-depth convergence).** If $0 \le \rho < 1$, then for every
tolerance $\varepsilon > 0$ there is a depth $K$ such that for all $k \ge K$,
$$ \langle T^k(h+r) - h,\; T^k(h+r) - h\rangle < \varepsilon. $$

*Proof sketch.* Since $0 \le \rho < 1$, $\rho^k \to 0$, so $\rho^k\langle r,r\rangle
\to 0$; the bound of Theorem 6.5 is eventually below $\varepsilon$. $\square$

### 6.5 The optimal spectral step

**Theorem 6.7 (Optimality of $\alpha = 1/\lambda$).** For $\mu > 0$, $\lambda > 0$
and any step $\alpha$,
$$ 1 - \frac{\mu}{\lambda} \;\le\; 1 - \alpha\mu(2 - \alpha\lambda), $$
with equality at $\alpha = 1/\lambda$. At the optimal step the contraction factor
is exactly
$$ 1 - \frac{1}{\lambda}\,\mu\,\Bigl(2 - \frac{1}{\lambda}\lambda\Bigr) = 1 - \frac{\mu}{\lambda}. $$

*Proof sketch.* The difference
$\bigl(1 - \alpha\mu(2-\alpha\lambda)\bigr) - \bigl(1 - \mu/\lambda\bigr)
= \mu(\alpha\lambda - 1)^2/\lambda \ge 0$ is a perfect square that vanishes exactly
at $\alpha = 1/\lambda$. $\square$

Identifying $\lambda = \lambda_{\max}(\Delta)$ and $\mu$ as the spectral gap
(smallest nonzero eigenvalue), Theorems 6.2–6.7 yield the sharp statement: **deep
message passing transports the harmonic (cohomology) part exactly and suppresses
everything else geometrically at the spectrum-uniform rate $\rho = 1 -
\mu/\lambda_{\max}$, and the spectral step $\alpha = 1/\lambda_{\max}$ is
optimal.**

### 6.6 A spectrum-uniform depth threshold

In the diagonalized picture, a mode of eigenvalue $\nu$ evolves by amplitude
$(1 - \alpha\nu)^k$. Two scalar facts make the filter explicit.

**Proposition 6.8 (Monotone mode decay).** For $0 \le \alpha$, $\mu \le \nu$, and a
normalized step $\alpha\nu \le 1$: $(1 - \alpha\nu)^k \le (1 - \alpha\mu)^k$.
Harmonic modes ($\nu = 0$) keep amplitude $(1 - 0)^k = 1$ at every depth.

**Theorem 6.9 (Explicit depth threshold).** Given a spectral gap $\mu > 0$, a
normalized step (so admissible $\nu$ satisfy $\alpha\nu \le 1$), $0 < \alpha\mu < 1$,
and tolerance $\varepsilon > 0$, there is a critical depth $K_c$ such that for all
$k \ge K_c$ and every $\nu \ge \mu$, $(1 - \alpha\nu)^k < \varepsilon$, while
harmonic modes retain amplitude $1$.

*Proof sketch.* $(1-\alpha\mu)^k \to 0$ provides $K_c$ for the worst surviving mode
$\nu = \mu$; monotonicity (Proposition 6.8) extends the bound uniformly to all
$\nu \ge \mu$. $\square$

This is the precise statement that **depth acts as a low-pass filter onto the
harmonic subspace** — simultaneously the mechanism of useful topological feature
extraction and of *oversmoothing* in deep graph networks, with the transition
scale set explicitly by the spectral gap.

---

## 7. Algorithms

The constructive content above translates directly into algorithms.

**Algorithm A (Hodge decomposition of a cochain).** Given boundary matrices
$D, E$ with $DE = 0$ and a cochain $x$:
1. Form $\Delta = D^\top D + E E^\top$.
2. Compute orthonormal bases of $\operatorname{im} D^\top$ (coexact),
   $\operatorname{im} E$ (exact), and $\ker\Delta$ (harmonic) via SVD.
3. Project $x$ onto each by $P_S x = B_S B_S^\top x$ for the orthonormal basis
   $B_S$.
4. Return $(x_{\text{coex}}, x_{\text{ex}}, x_{\text{harm}})$; by Theorems 4.3–4.5
   they are orthogonal and sum to $x$.

Complexity: $O(n^3)$ for an $n$-dimensional middle space via dense SVD, far less
for sparse incidence structures.

**Algorithm B (Betti number / harmonic dimension).** Return
$\dim\ker D - \operatorname{rank} E$ (Theorem 3.1), each computed from singular
values; this equals $\dim\ker\Delta$ without forming $\Delta$.

**Algorithm C (Harmonic representative of a cohomology class).** Given a closed
$x \in \ker d$, return $P_{\ker\Delta}\, x$; by Theorems 5.3–5.5 this is the
unique harmonic representative and the minimal-norm member of $[x]$.

**Algorithm D (Spectral message passing).** Given $\Delta$, compute
$\lambda_{\max}$ and the spectral gap $\mu$; set $\alpha = 1/\lambda_{\max}$ and
$T = I - \alpha\Delta$; iterate $x_{k+1} = T x_k$. By Theorems 6.2–6.7 the iterate
converges to the harmonic projection of $x_0$ with per-layer rate
$\rho = 1 - \mu/\lambda_{\max}$; the depth to reach tolerance $\varepsilon$ is
$\lceil \log(\varepsilon/\lVert r_0\rVert^2)/\log\rho \rceil$ (Theorem 6.9).

---

## 8. Applications

**Topological data analysis.** Algorithm B computes Betti numbers of a complex
purely from incidence ranks, and Algorithm C produces explicit harmonic cycle
representatives — the canonical, minimal-norm shapes of the holes. These are more
stable to noise than arbitrary generators because they minimize energy
(Theorem 5.5).

**Ranking and preference aggregation (HodgeRank).** Pairwise comparison data form
a flow on the comparison graph. The Hodge decomposition splits it into a
consistent global ranking (the gradient/coexact part), triangularly resolvable
inconsistencies (the exact part), and globally inconsistent cyclic conflict (the
harmonic part). The norm of the harmonic component quantifies the intrinsic
inconsistency of the data.

**Vector-field cleaning in graphics and simulation.** The three-way split
separates a discrete vector field into curl-free and divergence-free parts plus a
harmonic remainder, the discrete Helmholtz–Hodge decomposition used to enforce
incompressibility and to denoise flow fields.

**Graph and simplicial neural networks.** Theorems 6.2–6.9 explain both the power
and the failure mode of depth. Useful: message passing automatically extracts
robust harmonic (topological) features and converges at a predictable rate. Peril:
the same operator is the precise mechanism of *oversmoothing*; the depth threshold
$K_c$ (Theorem 6.9) tells a designer how deep a network can go before all
non-topological signal collapses, as a function of the spectral gap.

---

## 9. Discussion

The development is striking for its economy. A single sum-of-squares identity
(Theorem 2.2) generates positive semidefiniteness, the discrete Hodge theorem, and
— after one application each of orthogonal rank–nullity and relative orthogonal
complementation — the entire decomposition, cohomology, and minimality theory. The
convergence theory then needs only that the layer $T = I - \alpha L$ is linear (so
iteration is automatic) and the scalar recursion of Theorem 6.4. No spectral
theorem, no finite-dimensionality, and no choice of basis are required for the
harmonic-side results; finite dimension enters only where dimensions are counted
(Theorems 3.1, 4.5).

A subtle but important structural point: the exact and harmonic parts are *not*
complementary in the whole space $V$ — their sum is $\ker d$, which is a proper
subspace whenever $d \neq 0$. The Hodge isomorphism therefore must be assembled
inside the ambient space $\ker d$, where complementarity does hold. This is why the
three-way decomposition (in $V$) and the two-way complementarity (in $\ker d$) are
genuinely different statements, both needed.

---

## 10. Future directions

The results above invite a fully operator-algebraic completion of the theory. The
following directions are open and, given the established foundation, tractable.

1. **Resolution of the identity by Hodge projectors.** Writing
   $P_{\text{coex}}, P_{\text{ex}}, P_{\text{harm}}$ for the orthogonal projectors
   onto the three summands, the three-way decomposition should promote to
   $I = P_{\text{coex}} + P_{\text{ex}} + P_{\text{harm}}$ with pairwise
   annihilation $P_i P_j = 0$ ($i \neq j$). With the pairwise-orthogonality lemmas
   (Lemma 4.2) and the span/dimension facts (Theorems 4.4–4.5) already in hand,
   this is projector bookkeeping along the nested split
   $V = \operatorname{im} d^{*} \oplus (\operatorname{im} e \oplus \ker\Delta)$.

2. **The Hodge isomorphism as a quotient isometry.** Theorem 5.5 shows the harmonic
   representative attains the quotient norm $\lVert[x]\rVert = \inf_u \lVert x - eu\rVert$,
   so the linear isomorphism of Theorem 5.4 should refine to a linear *isometry*
   $\lVert[x]\rVert = \lVert P_{\text{harm}} x\rVert$.

3. **Spectral positivity and the eigenvalue structure.** The Rayleigh form
   $\langle \Delta x, x\rangle = \lVert dx\rVert^2 + \lVert e^{*}x\rVert^2$ is a
   manifest sum of squares, so $\Delta$ is positive semidefinite with vanishing
   locus exactly $\ker\Delta$; consequently every eigenvalue is $\ge 0$ and the
   $0$-eigenspace is precisely the harmonic space. This feeds the finite-dimensional
   spectral theorem and underwrites the convergence analysis of §6.

4. **Contraction onto the harmonic projector at the spectral-gap rate.** For an
   admissible step $0 < \alpha < 2/\lambda_{\max}$, the diffusion iterate
   $(I - \alpha\Delta)^k$ should converge to the harmonic projector $P_{\text{harm}}$
   with $\lVert (I-\alpha\Delta)^k x - P_{\text{harm}} x\rVert \le \rho^k
   \lVert x - P_{\text{harm}} x\rVert$, $\rho = \max_{\nu\neq 0}|1 - \alpha\nu|$.
   The harmonic and complementary blocks are simultaneously $\Delta$-invariant; on
   the former $\Delta = 0$, on the latter strict positivity gives contraction.

5. **Functoriality of the harmonic projector under chain maps.** A morphism of
   two-step complexes (a commuting ladder) should induce a map $\ker\Delta \to
   \ker\Delta'$ that commutes with the harmonic projectors on closed cochains and
   agrees with the induced map on cohomology through the Hodge isomorphism, making
   the harmonic projector a natural transformation.

---

## 11. Conclusion

From two matrices satisfying $de = 0$ we have reconstructed, rigorously and
constructively, the full discrete Hodge picture: a positive-semidefinite Laplacian
whose kernel is the harmonic space; a three-way orthogonal decomposition of the
cochain space into coexact, exact, and harmonic parts; an identification of the
harmonic dimension with a Betti number; a canonical isomorphism between harmonic
cochains and cohomology, with the harmonic representative being the unique
minimal-norm member of its class; and a sharp analysis of message passing showing
that depth is a low-pass filter onto the harmonic subspace, converging at the
spectral-gap rate with a provably optimal step. The same theorems that make graph
and simplicial neural networks extract robust topological features also predict
their oversmoothing collapse — and they tell you, in advance and in closed form,
exactly when it happens.
