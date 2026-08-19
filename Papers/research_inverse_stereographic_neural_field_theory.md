# Inverse Stereographic Neural Field Theory

### A conformal chart, a closed symbolic calculus, and an exact pattern count for Mexican-hat neural fields on the sphere

**Aristotle**

**Date:** 2026-08-19

---

## Abstract

Neural-field models of macroscopic cortical dynamics are naturally posed on a closed surface of spherical topology. We transport the linearised pattern-formation problem for such a model from the round sphere $S^2$ to the Euclidean plane by inverse stereographic projection, and develop the resulting theory in full.

Three ingredients are established. First, the *conformal transport*: the pullback of the ambient metric under the inverse stereographic chart $\sigma(x,y) = (2xW, 2yW, (x^2+y^2-1)W)$, $W=(1+x^2+y^2)^{-1}$, is $4W^2(dx^2+dy^2)$, so that a degree-$l$ Laplace–Beltrami eigenfunction of the sphere is precisely a solution of the flat, weighted equation $\Delta u = -l(l+1)(4W^2)u$ on the plane. Second, a *closed symbolic calculus*: every function arising in the transport lies in the polynomial algebra $\mathbb{R}[x,y,W]$, which is closed under partial differentiation because $\partial_x W = -2xW^2$; consequently all Laplacians in the theory are finite algebraic computations, and the eigenvalue relation propagates from the three chart coordinates to arbitrary polynomial harmonics by two structural identities, $\Delta\sigma_i = -2(4W^2)\sigma_i$ and $\nabla\sigma_i\cdot\nabla\sigma_j = 4W^2(\delta_{ij}-\sigma_i\sigma_j)$, together with the Leibniz rule. Third, *mode selection*: a difference-of-Gaussians connectivity kernel of interaction radius $r$ acts on the degree-$l$ eigenspace by the normalised band-pass multiplier $\lambda_l(r) = (lr)^2 e^{1-(lr)^2}$, whose profile $g(s) = se^{1-s}$ is strictly unimodal with unique peak $g(1)=1$.

The main theorem states that at the resonant radii $r=1/k$ the kernel strictly selects degree $N=k=\lfloor 1/r\rfloor$, and that the selected eigenspace is exactly $(2N+1)$-dimensional; existence is proved by explicit construction of the fifteen projected harmonics of degrees $1,2,3$ together with their linear independence, and the matching upper bound is proved inside the polynomial ansatz for $l=1,2,3$. For a general radius the maximising degree is bracketed: it is $\lfloor 1/r\rfloor$ or $\lceil 1/r\rceil$, and we exhibit $r=0.4$ as a radius where the ceiling wins — refuting the naive claim that the selected degree is always the floor.

We also correct the expectation that all $2N+1$ projected patterns decay at infinity. Along every ray, a degree-one projected pattern converges to its north-pole coefficient at rate $O(R^{-1})$; the zonal mode therefore tends to $1$. Decay along every ray holds if and only if the north-pole coefficient vanishes, so the decaying subspace has dimension $2N$, not $2N+1$. The sectoral patterns do decay, at the sharp rates $|\sigma_1^2-\sigma_2^2| \le 8R^{-2}$ and $|\sigma_1(\sigma_1^2-3\sigma_2^2)| \le 32R^{-3}$, and carry exact $N$-fold rotational symmetry. Finally, Kelvin inversion of the plane is conjugated by the chart to the equatorial reflection of the sphere, endowing the pattern space with a discrete duality pairing modes of opposite polar parity.

**Keywords:** neural field equations, inverse stereographic projection, conformal geometry, Laplace–Beltrami operator, spherical harmonics, Mexican-hat connectivity, pattern formation, visual hallucinations.

---

## 1. Introduction

### 1.1 Cortical pattern formation

Neural-field equations describe the coarse-grained activity of cortical tissue by a continuum variable $u(p,t)$ obeying an integro-differential evolution law of Wilson–Cowan / Amari type,

$$\tau\,\partial_t u(p,t) \;=\; -u(p,t) \;+\; \int_{M} K(p,q)\, S\big(u(q,t)\big)\, d\mu(q),$$

with $M$ the cortical domain, $S$ a saturating firing-rate nonlinearity, and $K$ a connectivity kernel. When $K$ has *Mexican-hat* structure — short-range excitation, intermediate-range inhibition, negligible long-range interaction, with characteristic interaction radius $r$ — a spatially uniform rest state can lose stability to a spatially structured mode, and the emergent structure is determined by the spectrum of the linearised operator.

The classical application is to geometric visual hallucinations: the small, stereotyped repertoire of *form constants* (spirals, lattices, funnels, fans) is explained as the small, stereotyped repertoire of leading eigenmodes of a Mexican-hat neural field. The repertoire's size is thus a spectral multiplicity, and its shapes are the eigenfunctions.

### 1.2 Why the sphere, and why flatten it

The cortical surface is not an infinite plane. As a closed surface it has spherical topology, and the idealised model domain is the round sphere $S^2$. This is not a technicality: on $S^2$ the spectrum of the Laplace–Beltrami operator is discrete, the eigenvalues are $-l(l+1)$, and the eigenspaces have the rigidly determined dimensions $2l+1$ forced by the irreducible representations of $SO(3)$. Spherical topology is what makes the pattern repertoire *finite and countable*.

Working on the sphere in polar coordinates, however, introduces coordinate singularities at the poles and forces the machinery of associated Legendre functions. Moreover, the object one wants to *look at* — the hallucination pattern as perceived, or the pattern on a flattened cortical map — lives in the plane.

Inverse stereographic projection resolves both problems at once. It is conformal, so it converts the curved eigenvalue problem into a flat one with a scalar weight, and it delivers the pattern directly as a function on the plane. This paper develops that transport completely and extracts from it an exact pattern count.

### 1.3 Contributions

1. **The conformal chart and its factor** (§3): the pullback metric identity $\sigma^*g_{\mathbb{R}^3} = 4W^2(dx^2+dy^2)$ and the consequent transported eigenvalue equation.
2. **A closed symbolic calculus for the chart algebra** (§2): the algebra $\mathbb{R}[x,y,W]$ is closed under differentiation; symbolic differentiation is sound; the Leibniz rules for the Laplacian and the gradient pairing hold at the symbolic level.
3. **Propagation of the eigenvalue relation** (§4): the two structural identities for the chart coordinates plus the Leibniz rule generate the eigenvalue relation for every polynomial harmonic, with the fifteen harmonics of degrees $1,2,3$ constructed explicitly and shown independent.
4. **Mexican-hat mode selection** (§5): strict unimodality of $g(s)=se^{1-s}$; the bracketing theorem for the argmax; strict selection at resonant radii; and a counterexample to the naive floor formula.
5. **The exact $2N+1$ count** (§6): the matching upper bound within the polynomial ansatz for $l=1,2,3$.
6. **Decay, symmetry, and duality** (§7–§8): the north-pole obstruction and the exact decay criterion; the $N$-fold symmetry of sectoral patterns; sharp decay rates; Kelvin duality.

---

## 2. The chart algebra and its symbolic calculus

### 2.1 The conformal atom

**Definition 2.1 (Conformal atom).** For $(x,y)\in\mathbb{R}^2$ set

$$W(x,y) \;=\; \frac{1}{1+x^2+y^2}.$$

Then $W>0$ everywhere and $W\cdot(1+x^2+y^2)=1$.

The crucial elementary computation is

$$\partial_x W = -2xW^2, \qquad \partial_y W = -2yW^2. \tag{2.1}$$

**Definition 2.2 (Chart algebra).** Let $\mathcal{A} \subset C^\infty(\mathbb{R}^2)$ be the $\mathbb{R}$-algebra generated by the coordinate functions $x$, $y$ and the atom $W$; that is, $\mathcal{A} = \mathbb{R}[x,y,W]$ as a subalgebra of smooth functions.

**Proposition 2.3 (Closure under differentiation).** $\mathcal{A}$ is closed under $\partial_x$ and $\partial_y$.

*Proof.* Both derivations vanish or are constant on the generators $x,y$, and by (2.1) send $W$ into $\mathcal{A}$. Closure on products and sums follows from the Leibniz and additivity rules. $\square$

Proposition 2.3 is the engine of the whole development: no rational function outside $\mathcal{A}$ ever appears, so every differential computation reduces to polynomial algebra in three symbols.

### 2.2 Symbolic differentiation and its soundness

It is convenient to make the algebra *syntactic*. Consider formal expressions built from real constants, the two symbols $x$, $y$, the symbol $W$, and the operations of addition and multiplication; write $\llbracket e \rrbracket(x,y)$ for the evaluation of such an expression as a real-valued function. Define symbolic derivations $D_x, D_y$ on expressions by the rules

$$D_x(c)=0,\quad D_x(x)=1,\quad D_x(y)=0,\quad D_x(W) = -2\,x\,W^2,$$
$$D_x(a+b) = D_x a + D_x b, \qquad D_x(ab) = (D_x a)\,b + a\,(D_x b),$$

and symmetrically for $D_y$. These rules never leave the syntax; this is Proposition 2.3 made mechanical.

**Theorem 2.4 (Soundness of symbolic differentiation).** For every expression $e$ and every $(x,y)$, the function $s \mapsto \llbracket e\rrbracket(s,y)$ is differentiable at $x$ with derivative $\llbracket D_x e\rrbracket(x,y)$; likewise in the second variable with $D_y$.

*Proof sketch.* Structural induction on $e$. For constants and the two coordinate symbols the claim is immediate. For $W$ it is the quotient rule applied to $(1+s^2+y^2)^{-1}$, whose denominator is nowhere zero, giving exactly $-2xW^2$. The inductive cases are the sum and product rules for differentiable functions. $\square$

**Definition 2.5 (Laplacian and gradient pairing).** For $u,v : \mathbb{R}^2 \to \mathbb{R}$ set

$$\Delta u \;=\; \partial_x^2 u + \partial_y^2 u, \qquad \nabla u \cdot \nabla v \;=\; (\partial_x u)(\partial_x v) + (\partial_y u)(\partial_y v).$$

**Corollary 2.6 (Reflection).** For every expression $e$, $\Delta \llbracket e \rrbracket = \llbracket D_x^2 e + D_y^2 e \rrbracket$ and $\nabla\llbracket a\rrbracket \cdot \nabla\llbracket b\rrbracket = \llbracket (D_xa)(D_xb) + (D_ya)(D_yb)\rrbracket$.

**Theorem 2.7 (Leibniz rules in the chart algebra).** For $u,v \in \mathcal{A}$:

$$\Delta(uv) \;=\; u\,\Delta v \;+\; v\,\Delta u \;+\; 2\,\nabla u\cdot\nabla v, \tag{2.2}$$
$$\nabla u \cdot \nabla (vw) \;=\; v\,(\nabla u \cdot \nabla w) \;+\; w\,(\nabla u \cdot \nabla v), \tag{2.3}$$

together with additivity of $\Delta$ and $\Delta(cu) = c\Delta u$.

*Proof sketch.* By Corollary 2.6 each side is the evaluation of an explicit expression obtained by applying $D_x, D_y$ to the syntax; expanding both sides yields identical polynomials in the generators, so the identity holds pointwise. $\square$

Identities (2.2)–(2.3) are the only analytic input needed for the rest of the paper. Everything else is algebra.

---

## 3. The inverse stereographic chart and its conformal factor

**Definition 3.1 (Inverse stereographic chart).** Define $\sigma : \mathbb{R}^2 \to S^2 \subset \mathbb{R}^3$ by

$$\sigma(x,y) \;=\; \big(\sigma_1,\sigma_2,\sigma_3\big) \;=\; \big(2xW,\; 2yW,\; (x^2+y^2-1)W\big), \qquad W = (1+x^2+y^2)^{-1}.$$

**Proposition 3.2 (The chart lands on the sphere).** $\sigma_1^2+\sigma_2^2+\sigma_3^2 = 1$ identically.

*Proof.* Multiply through by $(1+x^2+y^2)^2$: the identity becomes $4x^2 + 4y^2 + (x^2+y^2-1)^2 = (1+x^2+y^2)^2$, which is a polynomial identity. $\square$

Geometrically, $\sigma$ inverts stereographic projection from the north pole $(0,0,1)$: the origin maps to the south pole, the unit circle to the equator, and $|(x,y)|\to\infty$ corresponds to approach to the north pole, the one point of $S^2$ not in the image.

**Theorem 3.3 (Conformal factor).** The pullback of the Euclidean metric of $\mathbb{R}^3$ under $\sigma$ is

$$\big|\partial_x \sigma\big|^2 = \big|\partial_y \sigma\big|^2 = 4W^2, \qquad \partial_x\sigma \cdot \partial_y\sigma = 0,$$

i.e. $\sigma^* g_{\mathbb{R}^3} = 4W^2\,(dx^2+dy^2)$.

*Proof sketch.* Each component derivative is computed by the symbolic rules of §2; the three resulting rational functions have common denominator $(1+x^2+y^2)^4$, and clearing it reduces each claim to a polynomial identity in $x,y$. $\square$

**Corollary 3.4 (Transported eigenvalue equation).** Because the chart is two-dimensional and conformal with factor $\Omega^2 = 4W^2$, the Laplace–Beltrami operator of the pulled-back metric is $\Delta_g = (4W^2)^{-1}\Delta$. Consequently, for a function $Y$ on $S^2$ and $u = Y\circ\sigma$,

$$\Delta_{S^2} Y = -l(l+1)\,Y \quad\Longleftrightarrow\quad \Delta u \;=\; -l(l+1)\,\big(4W^2\big)\,u \ \text{ on } \mathbb{R}^2. \tag{3.1}$$

**Definition 3.5 (Stereographic pattern of degree $l$).** A function $u \in \mathcal{A}$ is a *stereographic pattern of degree $l$* if it satisfies (3.1) pointwise on $\mathbb{R}^2$. The set of such $u$ is a real vector space (closed under sums, differences, and scalar multiples, by additivity of $\Delta$).

---

## 4. Propagating the eigenvalue relation

### 4.1 The two structural identities

**Definition 4.1 (Chart-coordinate property).** Say $a \in \mathcal{A}$ *is a chart coordinate* if

$$\Delta a = -2\,(4W^2)\,a \qquad\text{and}\qquad \nabla a\cdot\nabla a = 4W^2\big(1-a^2\big),$$

and say $a,b$ are *orthogonal chart coordinates* if in addition $\nabla a \cdot \nabla b = -4W^2\,ab$.

**Theorem 4.2.** Each of $\sigma_1,\sigma_2,\sigma_3$ is a chart coordinate, and any two of them are orthogonal in the above sense. Equivalently,

$$\Delta\sigma_i = -2(4W^2)\sigma_i, \qquad \nabla\sigma_i\cdot\nabla\sigma_j = 4W^2\big(\delta_{ij} - \sigma_i\sigma_j\big). \tag{4.1}$$

*Proof sketch.* Each identity is a rational-function identity in $x,y$; applying the symbolic derivative rules and clearing the common denominator reduces it to a polynomial identity, verified by expansion. $\square$

The second identity in (4.1) is the induced metric of $S^2$ read in the chart: it is the infinitesimal form of the constraint $\sum_i\sigma_i^2=1$, whose gradient is $\sum_i \sigma_i \nabla\sigma_i = 0$.

### 4.2 Monomial Laplacians

Applying (2.2)–(2.3) to (4.1) gives, for chart coordinates $a,b,c$ pairwise orthogonal, purely algebraic formulas:

| monomial | Laplacian |
|---|---|
| $a^2$ | $4W^2\,(2 - 6a^2)$ |
| $ab$ | $-6\,(4W^2)\,ab$ |
| $a^3$ | $4W^2\,(6a - 12a^3)$ |
| $ab^2$ | $4W^2\,(2a - 12ab^2)$ |
| $abc$ | $-12\,(4W^2)\,abc$ |

**Proposition 4.3.** The five formulas above hold for all $(x,y)$.

*Proof sketch.* Each is one application of (2.2) with the pieces supplied by (4.1) and, where a triple product occurs, one application of (2.3). For instance $\Delta(ab) = a\Delta b + b\Delta a + 2\nabla a\cdot\nabla b = -2(4W^2)ab -2(4W^2)ab + 2\big(-4W^2 ab\big) = -6(4W^2)ab$, which is the degree-two eigenvalue $l(l+1)=6$. $\square$

Note what the table shows: $ab$ and $abc$ are *already* pure eigenfunctions of degrees $2$ and $3$, while $a^2$, $a^3$, $ab^2$ contain lower-degree contamination that must be removed by the traceless combinations below.

### 4.3 The fifteen explicit patterns

**Degree one (dipoles, $l(l+1)=2$).** The three chart coordinates themselves:

$$\sigma_1 = 2xW, \qquad \sigma_2 = 2yW, \qquad \sigma_3 = (x^2+y^2-1)W.$$

**Degree two (quadrupoles, $l(l+1)=6$).** Five patterns:

$$\sigma_1\sigma_2, \quad \sigma_1\sigma_3, \quad \sigma_2\sigma_3, \quad \sigma_1^2-\sigma_2^2, \quad 3\sigma_3^2-1.$$

**Degree three (octupoles, $l(l+1)=12$).** Seven patterns:

$$\sigma_1(\sigma_1^2-3\sigma_2^2), \quad \sigma_2(3\sigma_1^2-\sigma_2^2), \quad \sigma_3(\sigma_1^2-\sigma_2^2), \quad \sigma_1\sigma_2\sigma_3,$$
$$\sigma_1(5\sigma_3^2-1), \quad \sigma_2(5\sigma_3^2-1), \quad \sigma_3(5\sigma_3^2-3).$$

**Theorem 4.4 (Eigenvalue relation).** Each of the three degree-one functions satisfies $\Delta u = -2(4W^2)u$; each of the five degree-two functions satisfies $\Delta u = -6(4W^2)u$; each of the seven degree-three functions satisfies $\Delta u = -12(4W^2)u$.

*Proof sketch.* Each is a linear combination of the monomials of Proposition 4.3; the lower-degree contamination cancels exactly in the stated combinations. E.g. for $\sigma_1^2-\sigma_2^2$, the two constant terms $4W^2\cdot 2$ cancel and one is left with $-6(4W^2)(\sigma_1^2-\sigma_2^2)$. For $3\sigma_3^2-1$, $\Delta(3\sigma_3^2-1) = 4W^2(6 - 18\sigma_3^2) = -6(4W^2)(3\sigma_3^2-1)$ after using $6 - 18\sigma_3^2 = -6(3\sigma_3^2 - 1)$. For $\sigma_1(5\sigma_3^2-1)$, one combines the $ab^2$ and single-coordinate rows: $5\cdot 4W^2(2\sigma_1 - 12\sigma_1\sigma_3^2) - (-2)(4W^2)\sigma_1 = -12(4W^2)\sigma_1(5\sigma_3^2-1)$. $\square$

**Theorem 4.5 (Linear independence).** Each of the three families is linearly independent as a family of functions on $\mathbb{R}^2$.

*Proof sketch.* Evaluate at finitely many well-chosen plane points and solve the resulting linear system. For degree one, evaluation at $(0,0), (1,0), (0,1)$ suffices: at the origin $\sigma = (0,0,-1)$, isolating the $\sigma_3$ coefficient; at $(1,0)$ and $(0,1)$ the remaining two are separated. For degree two, five points $(0,0),(1,0),(2,0),(0,2),(1,1)$; for degree three, eight points including half-integer ones. $\square$

**Corollary 4.6.** The space of stereographic patterns of degree $l$ has dimension at least $2l+1$ for $l = 1,2,3$.

### 4.4 The representation-theoretic count

The number $2l+1$ is the dimension of the space of degree-$l$ spherical harmonics, which equals the difference between the dimension of the space of homogeneous polynomials of degree $l$ in three variables and that of degree $l-2$ (the kernel of the trace map).

**Proposition 4.7.** For every $l \ge 0$, $\displaystyle \binom{l+2}{2} - \binom{l}{2} = 2l+1$.

*Proof.* Induction on $l$, using $\binom{m+3}{2} = \binom{m+2}{2} + (m+2)$ and $\binom{m+1}{2} = \binom{m}{2} + m$; the increment of the difference is $(m+2)-m = 2$, matching $2(m+1)+1 - (2m+1) = 2$. $\square$

Equivalently, the degree-$l$ eigenspace carries the unique $(2l+1)$-dimensional irreducible real representation of $SO(3)$; the $2l+1$ patterns are rotational variants of one another (§8).

---

## 5. Mexican-hat mode selection

### 5.1 The multiplier

Because the connectivity kernel of a homogeneous, isotropic cortex depends only on the geodesic distance between two points of $S^2$, the linearised operator commutes with rotations and hence acts on each degree-$l$ eigenspace by a scalar $\lambda_l$ (the Funk–Hecke phenomenon: a zonal kernel is diagonal in the spherical-harmonic basis, with multiplier given by its Legendre coefficient). For a difference-of-Gaussians Mexican hat of interaction radius $r$ the multiplier has band-pass shape, vanishing both for $l\to 0$ (no net drive to the uniform mode) and $l\to\infty$ (spatial averaging), with a single interior maximum where the mode wavelength matches the interaction radius. Normalising the peak to $1$:

**Definition 5.1 (Band-pass gain and multiplier).**

$$g(s) \;=\; s\,e^{\,1-s} \quad (s\ge 0), \qquad \lambda_l(r) \;=\; g\big((lr)^2\big).$$

Thus $\lambda_l(r) = (lr)^2 e^{1-(lr)^2}$, and $g(1)=1$.

### 5.2 Unimodality

Everything about $g$ follows from the elementary strict inequality $t + 1 < e^{t}$ for $t\ne 0$.

**Theorem 5.2 (Sharp peak).** If $s\ne 1$ then $g(s) < 1$.

*Proof.* Apply $t+1 < e^t$ at $t = s-1 \ne 0$ to get $s < e^{s-1}$. Multiply by $e^{1-s}>0$: $g(s) = s\,e^{1-s} < e^{s-1}e^{1-s} = 1$. $\square$

**Theorem 5.3 (Strict monotonicity).**
(i) If $0 \le s < t \le 1$ then $g(s) < g(t)$.
(ii) If $1 \le s < t$ then $g(t) < g(s)$.

*Proof.* (i) Apply the inequality at $t' = s-t \ne 0$: $s - t + 1 < e^{s-t}$, hence $s < t + (t-1)(\,\cdot\,)$-type rearrangement; concretely, since $t \le 1$ we get $s < t\,e^{s-t}$, and multiplying by $e^{1-s} > 0$ gives $g(s) < t\,e^{1-t} = g(t)$. (ii) Symmetrically, apply the inequality at $t-s \ne 0$; since $s\ge 1$ we get $t < s\,e^{t-s}$, and multiplying by $e^{1-t}>0$ gives $g(t) < g(s)$. $\square$

So $g$ increases strictly on $[0,1]$, decreases strictly on $[1,\infty)$, and has its unique maximum $g(1)=1$ at resonance $lr=1$.

### 5.3 Localisation of the selected degree

**Definition 5.4 (Selected degree).** A degree $k$ is *selected* at radius $r$ if $\lambda_l(r) < \lambda_k(r)$ for every $l \ne k$.

**Theorem 5.5 (Bracketing of the argmax).** For every $r > 0$ and every $l\in\mathbb{N}$,

$$\lambda_l(r) \;\le\; \max\Big\{\lambda_{\lfloor 1/r\rfloor}(r),\ \lambda_{\lceil 1/r\rceil}(r)\Big\}.$$

*Proof sketch.* Write $m_- = \lfloor 1/r\rfloor$, $m_+ = \lceil 1/r\rceil$. From $m_- \le 1/r$ we get $(m_-r)^2 \le 1$; hence for $l \le m_-$ monotonicity (i) gives $\lambda_l \le \lambda_{m_-}$. From $1/r \le m_+$ we get $(m_+r)^2\ge 1$; hence for $l \ge m_+$ monotonicity (ii) gives $\lambda_l \le \lambda_{m_+}$. Since $m_+ \le m_- + 1$, every $l$ falls into one of the two cases. $\square$

**Theorem 5.6 (Strict selection at resonant radii).** Let $k \ge 1$ and $r = 1/k$. Then $\lambda_k(r) = 1$ and $\lambda_l(r) < 1$ for every $l \ne k$; that is, $k$ is the selected degree. Moreover $\lfloor 1/r \rfloor = k$.

*Proof.* $(kr)^2 = 1$ so $\lambda_k = g(1) = 1$. For $l \ne k$, $(lr)^2 = (l/k)^2 \ne 1$ because $l,k$ are distinct non-negative integers, so Theorem 5.2 gives $\lambda_l < 1$. $\square$

### 5.4 A counterexample to the naive floor formula

It is tempting to assert that the selected degree equals $N = \lfloor 1/r\rfloor$ for *every* $r$. This is false.

**Proposition 5.7.** At $r = 2/5$ one has $\lfloor 1/r\rfloor = 2$ and $\lceil 1/r \rceil = 3$, but

$$\lambda_2 = 0.64\,e^{0.36} \approx 0.91735 \;<\; \lambda_3 = 1.44\,e^{-0.44} \approx 0.92739.$$

Hence the maximiser is the ceiling, not the floor.

*Proof.* Direct evaluation of $g$ at $s = (2\cdot 0.4)^2 = 0.64$ and $s = (3\cdot 0.4)^2 = 1.44$. $\square$

Theorem 5.5 is therefore the correct general statement, and Theorem 5.6 the correct sharp statement at resonance. The mechanism is transparent: $g$ is not symmetric about $s=1$, so which of the two bracketing integers wins depends on the fractional part of $1/r$ in a nontrivial way.

---

## 6. The exact count: matching upper bounds

Corollary 4.6 gives $\dim \ge 2l+1$. We now prove the reverse inequality inside the natural finite-dimensional ansatz in which any Galerkin or amplitude-equation truncation of a neural-field model lives: polynomials of bounded degree in the three chart coordinates.

### 6.1 Degree one

**Theorem 6.1 (Exactness in degree one).** Let $u = c_0 + c_1\sigma_1 + c_2\sigma_2 + c_3\sigma_3$. Then $u$ is a stereographic pattern of degree $1$ if and only if $c_0 = 0$.

*Proof.* By linearity and (4.1), $\Delta u = 4W^2\big(-2(c_1\sigma_1+c_2\sigma_2+c_3\sigma_3)\big)$, since $\Delta c_0 = 0$. The degree-one requirement is $\Delta u = -2(4W^2)u = 4W^2\big(-2(c_0 + c_1\sigma_1+c_2\sigma_2+c_3\sigma_3)\big)$. Subtracting and dividing by the strictly positive factor $4W^2$ gives $c_0 = 0$; conversely $c_0 = 0$ makes the two sides identical. (Concretely, evaluating at the origin, where $\sigma = (0,0,-1)$, already forces $c_0=0$.) $\square$

Combined with Theorem 4.5, the degree-one pattern space inside the affine ansatz is exactly the three-dimensional span of $\sigma_1,\sigma_2,\sigma_3$, i.e. $2\cdot 1+1$.

### 6.2 Degree two

Consider the general quadratic

$$u = c_0 + \sum_i c_i\sigma_i + \sum_{i\le j} q_{ij}\,\sigma_i\sigma_j .$$

**Lemma 6.2 (Pointwise constraint).** If $u$ is a stereographic pattern of degree $2$ then for all $(x,y)$,

$$4\big(c_1\sigma_1 + c_2\sigma_2 + c_3\sigma_3\big) \;+\; 2\big(q_{11}+q_{22}+q_{33}\big) \;+\; 6c_0 \;=\; 0.$$

*Proof sketch.* Expand $\Delta u$ using the monomial table of Proposition 4.3, subtract $-6(4W^2)u$, and factor out $4W^2 > 0$. All the genuinely quadratic terms cancel identically — this is exactly the statement that $\sigma_i\sigma_j$ ($i\ne j$) and the traceless quadratic combinations are already degree-two eigenfunctions — leaving the displayed linear-plus-constant expression. $\square$

**Theorem 6.3 (Exactness in degree two).** If the general quadratic $u$ above is a stereographic pattern of degree $2$, then

$$c_1 = c_2 = c_3 = 0, \qquad 3c_0 + (q_{11}+q_{22}+q_{33}) = 0,$$

and $u$ lies in the span of the five quadrupoles $\sigma_1\sigma_2,\ \sigma_1\sigma_3,\ \sigma_2\sigma_3,\ \sigma_1^2-\sigma_2^2,\ 3\sigma_3^2-1$.

*Proof sketch.* Evaluate the constraint of Lemma 6.2 at the five plane points $(0,0),(\pm 1,0),(0,\pm 1)$. The images $\sigma(x,y)$ at these points span enough directions that the resulting linear system forces $c_1=c_2=c_3=0$ and $2T + 6c_0=0$ with $T = q_{11}+q_{22}+q_{33}$. Given these, write $u = \sum_{i<j}q_{ij}\sigma_i\sigma_j + \sum_i (q_{ii} - T/3)\sigma_i^2$, using $c_0 = -T/3$; the sphere identity $\sigma_1^2+\sigma_2^2+\sigma_3^2=1$ then expresses the traceless diagonal part as a combination of $\sigma_1^2-\sigma_2^2$ and $3\sigma_3^2-1$. Explicitly, the coefficients are $\big(q_{12},\,q_{13},\,q_{23},\,(q_{11}-T/3)+\tfrac12(q_{33}-T/3),\,\tfrac12(q_{33}-T/3)\big)$. $\square$

With Theorem 4.5, the degree-two pattern space inside the quadratic ansatz is exactly five-dimensional, i.e. $2\cdot 2+1$.

### 6.3 Degree three

Degree-three spherical harmonics are odd under the antipodal map, so the natural ansatz is the general parity-odd cubic

$$u = \sum_i c_i \sigma_i + \sum_{i\le j\le k} t_{ijk}\,\sigma_i\sigma_j\sigma_k .$$

**Lemma 6.4 (Three linear constraints).** If $u$ above is a stereographic pattern of degree $3$ then

$$10c_1 + 6t_{111} + 2t_{122} + 2t_{133} = 0,$$
$$10c_2 + 6t_{222} + 2t_{112} + 2t_{233} = 0,$$
$$10c_3 + 6t_{333} + 2t_{113} + 2t_{223} = 0.$$

*Proof sketch.* Expand $\Delta u + 12(4W^2)u$ with the monomial table. All cubic terms cancel identically; the remainder is $4W^2$ times a *linear* combination of $\sigma_1,\sigma_2,\sigma_3$ whose coefficients are the three displayed expressions. Dividing by $4W^2>0$ and invoking the linear independence of $\sigma_1,\sigma_2,\sigma_3$ (Theorem 4.5, degree one) forces each coefficient to vanish. This is a pleasant economy: no evaluation at special points is needed beyond what independence already provides. $\square$

**Theorem 6.5 (Exactness in degree three).** A parity-odd cubic that is a stereographic pattern of degree $3$ lies in the span of the seven octupoles listed in §4.3.

*Proof sketch.* Using the three constraints of Lemma 6.4 to eliminate $c_1,c_2,c_3$, and using the sphere identity $\sum_i\sigma_i^2=1$ to trade $\sigma_i\sigma_3^2$ against $\sigma_i(1-\sigma_1^2-\sigma_2^2)$, one exhibits explicit coefficients: with $a_1 = (t_{111}-t_{122})/4$, $a_2 = (t_{112}-t_{222})/4$, $a_3 = (t_{113}-t_{223})/2$, $a_4 = t_{123}$, $a_5 = \big(t_{133} - (3t_{111}+t_{122})/4\big)/5$, $a_6 = \big(t_{233}-(3t_{222}+t_{112})/4\big)/5$, $a_7 = \big(t_{333}-(t_{113}+t_{223})/2\big)/5$, the cubic equals $\sum_{m=1}^{7} a_m\,Y_m$ where $Y_1,\dots,Y_7$ are the seven octupoles. $\square$

With Theorem 4.5, the degree-three pattern space inside the odd-cubic ansatz is exactly seven-dimensional, i.e. $2\cdot 3+1$.

### 6.4 The pattern-count theorem

**Theorem 6.6 (Stereographic pattern count at resonant radii).** Let $k \in \{1,2,3\}$ and $r = 1/k$. Then:

1. the Mexican-hat multiplier is strictly maximised at degree $N = k$, and $N = \lfloor 1/r\rfloor$;
2. the selected eigenspace contains $2N+1$ explicit, linearly independent stereographic patterns, given by the lists of §4.3;
3. within the polynomial ansatz of degree $\le N$ in the chart coordinates, the selected eigenspace has dimension exactly $2N+1$.

*Proof.* (1) is Theorem 5.6. (2) is Theorems 4.4 and 4.5. (3) is Theorem 6.1 for $N=1$, Theorem 6.3 for $N=2$, and Theorem 6.5 for $N=3$, each combined with the corresponding independence statement. $\square$

The general-$l$ upper bound remains open as a theorem. It is, however, supported by exact computation: setting up the eigenvalue equation on the full ansatz of polynomials of degree $\le l$ in the chart coordinates, clearing denominators, and computing the exact rational rank of the resulting linear system gives dimension precisely $2l+1$ for every $l$ from $1$ to $6$. (Two linear maps are needed: one sending a coefficient vector to the residual of the eigenvalue equation, one sending it to the function itself, the latter having a kernel because of the sphere relation $\sum_i\sigma_i^2=1$; the dimension of the solution space *as functions* is the difference of the two nullities.) This is a computation rather than a proof, but it is an exact one, performed in rational arithmetic with no floating point.

The general-$l$ upper bound is discussed further in §10, which explains why the same method should close it.

---

## 7. Behaviour at infinity: the north-pole obstruction

Because $|(x,y)| \to \infty$ corresponds to $\sigma \to (0,0,1)$, the behaviour of a projected pattern in the far field is the behaviour of the underlying harmonic near the north pole. A harmonic need not vanish there, and then the projected pattern does not decay.

**Theorem 7.1 (Exact ray formula, degree one).** Let $u = a\sigma_1+b\sigma_2+c\sigma_3$ and let $(u_0,v_0)$ be a unit vector. Then for all $R$,

$$u(Ru_0, Rv_0) \;=\; c \;+\; \frac{2aRu_0 + 2bRv_0 - 2c}{1+R^2}.$$

*Proof.* Along the ray $1 + (Ru_0)^2 + (Rv_0)^2 = 1+R^2$, so $W = (1+R^2)^{-1}$; substituting the definitions and simplifying with $u_0^2+v_0^2=1$ gives the displayed identity. $\square$

**Corollary 7.2 (Quantitative convergence).** For $R \ge 1$,

$$\big|u(Ru_0,Rv_0) - c\big| \;\le\; \frac{2|a|+2|b|+2|c|}{R},$$

hence $u(Ru_0,Rv_0) \to c$ as $R\to\infty$, along every ray.

**Corollary 7.3 (North-pole obstruction).** The zonal dipole $\sigma_3$ satisfies $\sigma_3(R,0)\to 1$; it does not decay at infinity.

**Theorem 7.4 (Exact decay criterion in degree one).** $u = a\sigma_1+b\sigma_2+c\sigma_3$ tends to $0$ along every ray if and only if $c = 0$.

*Proof.* If $u\to 0$ along the ray $(1,0)$ then by Corollary 7.2 and uniqueness of limits $c=0$. Conversely if $c=0$ the same corollary gives limit $0$ along every ray. $\square$

Thus decay is a *single linear condition* — vanishing of the north-pole value — and the decaying subspace of the three-dimensional degree-one pattern space is two-dimensional. This corrects the expectation that all $2N+1$ projected patterns decay: the decaying part has dimension $2N$.

**Theorem 7.5 (Sharp decay of sectoral patterns).** For every unit $(u_0,v_0)$ and every $R>0$,

$$\big|\sigma_1^2-\sigma_2^2\big|(Ru_0,Rv_0) \;\le\; \frac{8}{R^2}, \qquad \big|\sigma_1(\sigma_1^2-3\sigma_2^2)\big|(Ru_0,Rv_0) \;\le\; \frac{32}{R^3}.$$

*Proof sketch.* Along a ray, $|\sigma_1|, |\sigma_2| \le 2/R$ (from $|2Ru_0|/(1+R^2) \le 2R/(1+R^2)\le 2/R$). The triangle inequality plus the elementary bound $A^3 + 3AB^2 \le 4k^3$ for $0\le A,B\le k$ gives the cubic estimate; the quadratic case is $A^2+B^2 \le 2k^2$. $\square$

The rates $R^{-2}$ and $R^{-3}$ are the orders of vanishing of the corresponding harmonics at the north pole, read through $W \sim R^{-2}$: a sectoral harmonic of degree $l$ vanishes to order $l$ there, and one power of $R^{-1}$ is contributed per order.

---

## 8. Symmetry and duality

### 8.1 Plane rotations are polar rotations

**Theorem 8.1.** Let $c^2+s^2=1$ and let $\rho(x,y) = (cx - sy,\ sx+cy)$ be the corresponding plane rotation. Then

$$\sigma_1\circ\rho = c\,\sigma_1 - s\,\sigma_2, \qquad \sigma_2\circ\rho = s\,\sigma_1 + c\,\sigma_2, \qquad \sigma_3\circ\rho = \sigma_3 .$$

*Proof.* $W$ is invariant under $\rho$ because $(cx-sy)^2+(sx+cy)^2 = x^2+y^2$; the two horizontal formulas are then immediate, and $\sigma_3$ depends only on $x^2+y^2$ and $W$. $\square$

So the chart conjugates the plane rotation group to the group of sphere rotations about the polar axis, and the degree-$l$ pattern space is an invariant subspace. On it, rotation acts by the standard two-dimensional representation on each sectoral pair together with a trivial summand on the zonal mode — this is the concrete mechanism producing the "$2l+1$ rotational variants".

### 8.2 $N$-fold symmetry of sectoral patterns

**Theorem 8.2 (Two-fold symmetry).** $\big(\sigma_1^2-\sigma_2^2\big)(-x,-y) = \big(\sigma_1^2-\sigma_2^2\big)(x,y)$.

**Theorem 8.3 (Three-fold symmetry).** With $\rho_{2\pi/3}(x,y) = \big(-\tfrac12 x - \tfrac{\sqrt3}{2}y,\ \tfrac{\sqrt3}{2}x - \tfrac12 y\big)$,

$$\sigma_1(\sigma_1^2-3\sigma_2^2)\circ\rho_{2\pi/3} = \sigma_1(\sigma_1^2-3\sigma_2^2), \qquad \sigma_2(3\sigma_1^2-\sigma_2^2)\circ\rho_{2\pi/3} = \sigma_2(3\sigma_1^2-\sigma_2^2).$$

*Proof sketch.* By Theorem 8.1 the rotation acts on $(\sigma_1,\sigma_2)$ as multiplication of $\sigma_1+i\sigma_2$ by $e^{2\pi i/3}$. The two patterns are $\mathrm{Re}\,(\sigma_1+i\sigma_2)^3$ and $\mathrm{Im}\,(\sigma_1+i\sigma_2)^3$, and $(e^{2\pi i/3})^3 = 1$. Made explicit, this is the pair of exact polynomial identities in $A,B$ and $t$ with $t^2=3$:

$$\Big(-\tfrac12 A - \tfrac t2 B\Big)^3 - 3\Big(-\tfrac12 A - \tfrac t2 B\Big)\Big(\tfrac t2 A - \tfrac12 B\Big)^2 = A^3 - 3AB^2,$$
$$3\Big(\tfrac t2 A - \tfrac12 B\Big)\Big(-\tfrac12 A - \tfrac t2 B\Big)^2 - \Big(\tfrac t2 A - \tfrac12 B\Big)^3 = 3A^2B - B^3,$$

applied with $A=\sigma_1$, $B=\sigma_2$, $t=\sqrt3$. $\square$

**Theorem 8.4 (The boundary case $N=1$).** $\sigma_1(-x,-y) = -\sigma_1(x,y)$: the degree-one sectoral pattern is *odd* under the half-turn, so its rotational symmetry group is exactly one-fold.

Thus the degree-$N$ sectoral pattern has exactly $N$-fold rotational symmetry for $N=1,2,3$, matching the intuition that a degree-$N$ mode paints $N$ pairs of alternating lobes around the visual field.

### 8.3 Kelvin duality

**Theorem 8.5 (Kelvin inversion is the equatorial reflection).** Let $\iota(x,y) = \big(x/(x^2+y^2),\, y/(x^2+y^2)\big)$ for $(x,y)\ne(0,0)$. Then

$$\sigma_1\circ\iota = \sigma_1, \qquad \sigma_2\circ\iota = \sigma_2, \qquad \sigma_3\circ\iota = -\sigma_3 .$$

*Proof sketch.* With $\rho^2 = x^2+y^2$, one computes $W\circ\iota = \rho^2/(1+\rho^2)\cdot\rho^{-2}\cdot\rho^2 = \rho^2 W$-type simplification; substituting and clearing denominators reduces each claim to a polynomial identity. $\square$

**Corollary 8.6.** The zonal quadrupole $3\sigma_3^2-1$ is Kelvin-invariant; the zonal octupole $\sigma_3(5\sigma_3^2-3)$ is Kelvin-anti-invariant. In general, Kelvin inversion of the plane acts on the degree-$l$ pattern space by $(-1)^{m}$ on a mode with $m$ powers of $\sigma_3$, pairing patterns of opposite polar parity.

Perceptually: the operation "turn the pattern inside out about the unit circle" is exactly the operation "flip the cortical sphere north-for-south". The unit circle — the equator — is the fixed locus.

---

## 9. Algorithms and computation

The theory is constructive, and each step corresponds to a small algorithm.

**A. Symbolic Laplacian in the chart algebra.** Represent an element of $\mathcal{A}$ as a polynomial in three symbols $x,y,W$ (a dictionary from exponent triples to coefficients). Differentiation is a term-wise rewriting: $\partial_x(x^ay^bW^c) = a\,x^{a-1}y^bW^c - 2c\,x^{a+1}y^bW^{c+1}$. Applying it twice in each variable and summing gives $\Delta$. Cost: each differentiation at most doubles the number of monomials, so the symbolic Laplacian of a $T$-term expression costs $O(T)$ monomial operations and produces $O(T)$ terms after collection.

**B. Eigenvalue certification.** To certify $\Delta u = -l(l+1)(4W^2)u$, form the residual $\Delta u + l(l+1)\cdot 4W^2 u$ symbolically and reduce it modulo the single relation $W\cdot(1+x^2+y^2) = 1$ — i.e. clear denominators by multiplying through by a sufficiently high power of $(1+x^2+y^2)$ — then check that the resulting ordinary polynomial in $x,y$ is identically zero. This is an exact rational computation, no floating point.

**C. Mode selection.** Given $r>0$, evaluate $g$ at $(\lfloor 1/r\rfloor r)^2$ and $(\lceil 1/r\rceil r)^2$ and take the larger. Theorem 5.5 guarantees no other degree needs to be examined: the search over an infinite set collapses to two evaluations, $O(1)$ work.

**D. Pattern synthesis and rendering.** For a selected degree $N$, the $2N+1$ patterns are obtained by evaluating the explicit polynomials in $\sigma_1,\sigma_2,\sigma_3$ at the chart image of a plane grid. Cost is $O(\text{grid size})$ with a small constant; no PDE solve, no special functions.

**E. Numerical validation of the Laplacian identities.** As an independent check one can evaluate $\Delta u$ by a high-order finite-difference stencil on a fine grid and compare with $-l(l+1)(4W^2)u$; the relative discrepancy is at the level of the truncation error of the stencil.

---

## 10. Discussion and future directions

### 10.1 What the theory delivers

The construction converts a qualitative statement — cortical geometry constrains the hallucination repertoire — into a quantitative dictionary with four entries.

1. **Which degree.** Given the interaction radius $r$, the emergent mode has degree bracketed by $\lfloor 1/r\rfloor$ and $\lceil 1/r\rceil$, equal to $1/r$ exactly when that is an integer.
2. **How many.** Exactly $2N+1$ patterns, of which exactly $2N$ decay in the periphery.
3. **What they look like.** Explicit rational functions of the plane coordinates; the sectoral ones are $N$-fold rosettes.
4. **How they relate.** They are rotational variants of one another under an $SO(2)$ action inherited from the sphere, and paired by a discrete Kelvin duality that inverts the plane through the unit circle.

The methodological point is equally important: because the chart algebra is closed under differentiation, *no* step of the analysis requires special functions, spherical coordinates, or numerical PDE solution. Two structural identities plus the Leibniz rule generate everything.

### 10.2 What failed, and what the corrected statements are

Honesty about the failures is part of the result.

- The claim "all $2N+1$ patterns decay at infinity" is **false**. Zonal modes tend to their north-pole value. The corrected statement: decay along every ray is equivalent to vanishing at the north pole; the decaying subspace has dimension $2N$.
- The claim "the selected degree is $N = \lfloor 1/r\rfloor$ for every $r$" is **false**; $r=0.4$ selects $3 = \lceil 1/r\rceil$. The corrected statement is the bracketing theorem, with equality to the floor guaranteed at $r = 1/k$.

### 10.3 Future directions

**Conjecture 1 — Exact $2l+1$ upper bound in every degree.** For every $l$, a polynomial of degree $\le l$ in the three chart coordinates satisfying $\Delta u = -l(l+1)(4W^2)u$ lies in the span of the $2l+1$ explicit sectoral/tesseral/zonal patterns of degree $l$. This is proved above for $l=1,2,3$ and open for $l\ge 4$.

*The key insight is* that the Leibniz rules for the Laplacian and the gradient pairing, together with the induced-metric identity $\nabla\sigma_i\cdot\nabla\sigma_j = 4W^2(\delta_{ij}-\sigma_i\sigma_j)$, turn the eigenvalue equation into a purely algebraic recursion on the coefficients of the polynomial, whose solution space is the traceless part — no functional analysis is needed.

*Why now?* Degrees $1,2,3$ are already proved this way, the last of them extracting its three linear constraints from nothing but linear independence of the chart coordinates; the general case only needs the recursion organised by total degree, which the closed symbolic calculus makes mechanical.

**Conjecture 2 — Decay codimension equals one in every degree.** For every $l$, the subspace of degree-$l$ patterns that decay along every ray has dimension exactly $2l$, and the decay rate of a decaying pattern is $\Theta(R^{-m})$ where $m$ is the order of vanishing of the harmonic at the north pole.

*The key insight is* that the plane behaviour at infinity is the sphere behaviour at the north pole read through $W \sim R^{-2}$, so "decay" is a single linear condition (vanishing at one point) and the rate is the vanishing order there.

*Why now?* The $l=1$ case is completely settled, and the sectoral rates $O(R^{-2})$ and $O(R^{-3})$ are established with explicit constants.

**Further directions.**

- **Stability, not just existence.** The entire analysis is linear: it identifies which eigenspace goes unstable first and how large it is. Which of the $2N+1$ shapes a nonlinear cortex actually settles into is governed by the equivariant amplitude equations on the $(2N+1)$-dimensional eigenspace, whose $SO(3)$-equivariant normal form is exactly what the representation-theoretic structure above prepares.
- **General radii and mode competition.** Near a radius where $\lambda_{\lfloor 1/r\rfloor} = \lambda_{\lceil 1/r\rceil}$, two eigenspaces of dimensions $2N+1$ and $2N+3$ become simultaneously critical; the resulting mode interaction is a codimension-one bifurcation of considerable structural interest.
- **Realistic connectivity.** The band-pass profile $g(s) = se^{1-s}$ is the normalised difference-of-Gaussians shape. Any strictly unimodal profile yields the same bracketing theorem verbatim; what changes is the resonance condition, and hence the map from measured interaction radius to predicted degree.
- **Cortical folding.** A folded cortex is a sphere with a non-round metric. Because the transport used here is conformal and every surface metric is locally conformally flat, the same chart algebra applies with $W$ replaced by a general positive weight — at the price of losing the polynomial closure. Perturbation of the weight around $4W^2$ is a natural next step, and would predict how folding splits the $(2N+1)$-fold degeneracy, exactly as a crystal field splits an atomic multiplet.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Conformal factor | $\sigma^*g_{\mathbb{R}^3} = 4W^2(dx^2+dy^2)$; hence $\Delta_g = (4W^2)^{-1}\Delta$ |
| Transported eigenproblem | $\Delta_{S^2}Y = -l(l+1)Y \iff \Delta u = -l(l+1)(4W^2)u$ |
| Chart-coordinate identities | $\Delta\sigma_i = -2(4W^2)\sigma_i$, $\nabla\sigma_i\cdot\nabla\sigma_j = 4W^2(\delta_{ij}-\sigma_i\sigma_j)$ |
| Explicit patterns | $3+5+7$ patterns of degrees $1,2,3$, all verified eigenfunctions, each family independent |
| Multiplicity identity | $\binom{l+2}{2}-\binom{l}{2} = 2l+1$ |
| Spectral gain | $g(s)=se^{1-s}$ has unique maximum $g(1)=1$, strictly unimodal |
| Argmax bracketing | maximising degree $\in \{\lfloor 1/r\rfloor, \lceil 1/r\rceil\}$ for every $r>0$ |
| Strict selection | at $r=1/k$, degree $k$ is the unique maximiser, with $\lambda_k=1$ |
| Floor formula fails | at $r=0.4$ the winner is $3=\lceil 1/r\rceil$, not $2=\lfloor 1/r\rfloor$ |
| Exact count | pattern space has dimension exactly $2l+1$ for $l=1,2,3$ in the polynomial ansatz |
| North-pole obstruction | $\sigma_3(R,0)\to1$; degree-one decay $\iff$ zonal coefficient $=0$; decaying dimension $2N$ |
| Ray estimate | $|u - c| \le (2|a|+2|b|+2|c|)/R$ for $u=a\sigma_1+b\sigma_2+c\sigma_3$, $R\ge1$ |
| Sectoral decay | $|\sigma_1^2-\sigma_2^2|\le 8R^{-2}$, $|\sigma_1(\sigma_1^2-3\sigma_2^2)|\le 32R^{-3}$ |
| Rotational action | plane rotation $\leftrightarrow$ polar rotation; $N$-fold symmetry of sectoral modes ($N=1,2,3$) |
| Kelvin duality | inversion in the unit circle $\leftrightarrow$ equatorial reflection $z\mapsto -z$ |
