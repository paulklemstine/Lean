# Concurrence, Exterior Algebra, and the Obstruction to Integer-Valued Linking Models of Two-Qubit Entanglement

**Aristotle**  
**July 18, 2026**

## Abstract

A tempting geometric proposal identifies the concurrence of a pure two-qubit state with the absolute value of a linking number derived from Hopf geometry. We show that this identification cannot hold when “linking number” has its ordinary integer-valued meaning. For a two-qubit amplitude vector $\psi=(\alpha,\beta,\gamma,\delta)\in\mathbb C^4$, define the squared norm $N(\psi)=|\alpha|^2+|\beta|^2+|\gamma|^2+|\delta|^2$, determinant coordinate $D(\psi)=\alpha\delta-\beta\gamma$, and concurrence $C(\psi)=2|D(\psi)|$. We prove the sharp inequality $0\le C(\psi)\le N(\psi)$, and hence $C(\psi)\in[0,1]$ for normalized states. We establish that $C(\psi)=0$ exactly when the coefficient matrix has rank one, equivalently when the state is separable. Concurrence is invariant under global unit phase, and each of the four Bell states is normalized and has concurrence one. The normalized state $(1/2,1/\sqrt2,0,1/2)$ has concurrence exactly $1/2$, yielding an immediate obstruction: no integer-valued invariant, including ordinary linking number, can agree in absolute value with concurrence on every normalized pure state. We also clarify that the quaternionic Hopf fibration $S^7\to S^4$ has $S^3$ fibres rather than circle fibres. The viable geometric bridge is therefore not literal integer linking but exterior algebra: concurrence is twice the norm of a determinant, or Plücker, coordinate. We conclude with algorithms, numerical demonstrations, and directions for real-valued Hopf-geometric replacements.

## 1. Introduction

Entanglement is a continuous resource in quantum information. A pure state of two qubits may be unentangled, maximally entangled, or anywhere between these extremes. For such states, concurrence gives a particularly simple quantitative measure. If

$$
|\psi\rangle=\alpha|00\rangle+\beta|01\rangle+\gamma|10\rangle+\delta|11\rangle,
$$

then

$$
C(\psi)=2|\alpha\delta-\beta\gamma|.
$$

The formula resembles an oriented area or determinant. At the same time, the nonlocal character of entanglement suggests topological imagery: two components can remain linked even while spatially separated. This motivates a strong conjectural identification in which concurrence equals the absolute value of an ordinary linking number associated with a Hopf construction.

The purpose of this paper is to distinguish the mathematically valid core of that picture from the part that cannot hold. Three elementary facts settle the issue. First, concurrence varies over the full real interval $[0,1]$ on normalized pure states. Second, ordinary linking number is integer-valued. Third, an explicit normalized state has concurrence $1/2$. Consequently, no construction assigning an integer to every normalized state can reproduce concurrence universally.

The obstruction is conceptual as well as arithmetic. Normalized two-qubit vectors form $S^7$, and the relevant quaternionic Hopf map is $S^7\to S^4$. Its fibres are $S^3$, unlike the circle fibres of the classical Hopf map $S^3\to S^2$. Thus the familiar picture of two linked circles does not transfer literally.

What survives is a precise algebraic-geometric account. The amplitudes form a $2\times2$ coefficient matrix. Its determinant is the coordinate of the exterior product of its two rows. It vanishes exactly on rank-one matrices, which represent product states, and its norm measures departure from this rank-one locus. This interpretation retains a genuine geometric content while respecting the continuous nature of entanglement.

The paper is organized as follows. Section 2 gives definitions and the separability criterion. Section 3 proves the sharp norm bound. Section 4 treats phase invariance and Bell states. Section 5 gives the half-concurrence witness and the universal integer-valued obstruction. Section 6 discusses Hopf dimensions and exterior algebra. Sections 7 and 8 present computational algorithms and applications. Sections 9 and 10 discuss limitations and future directions.

## 2. States, normalization, and the determinant coordinate

### 2.1 Pure two-qubit states

A pure two-qubit amplitude vector is a quadruple

$$
\psi=(\alpha,\beta,\gamma,\delta)\in\mathbb C^4,
$$

representing the ket

$$
|\psi\rangle=\alpha|00\rangle+\beta|01\rangle+\gamma|10\rangle+\delta|11\rangle.
$$

Define its squared norm by

$$
N(\psi)=|\alpha|^2+|\beta|^2+|\gamma|^2+|\delta|^2.
$$

The state is **normalized** when $N(\psi)=1$. A nonzero vector and any nonzero scalar multiple represent the same projective ray after renormalization; in particular, multiplication by a unit complex scalar is a physically irrelevant global phase.

Associate to $\psi$ the coefficient matrix

$$
A_\psi=
\begin{pmatrix}
\alpha&\beta\\
\gamma&\delta
\end{pmatrix}.
$$

Define the determinant coordinate

$$
D(\psi)=\det(A_\psi)=\alpha\delta-\beta\gamma.
$$

Finally, define pure-state concurrence by

$$
C(\psi)=2|D(\psi)|.
$$

This definition is meaningful even without normalization, although its standard quantum-information interpretation uses normalized states.

### 2.2 Product states and rank one

A pure state is a **product state** if there exist one-qubit vectors $u=(u_0,u_1)$ and $v=(v_0,v_1)$ such that

$$
|\psi\rangle=(u_0|0\rangle+u_1|1\rangle)
\otimes(v_0|0\rangle+v_1|1\rangle).
$$

Expanding gives

$$
(\alpha,\beta,\gamma,\delta)
=(u_0v_0,u_0v_1,u_1v_0,u_1v_1),
$$

so

$$
A_\psi=
\begin{pmatrix}u_0\\u_1\end{pmatrix}
\begin{pmatrix}v_0&v_1\end{pmatrix}.
$$

Thus a nonzero product state has a rank-one coefficient matrix. Conversely, every nonzero rank-one $2\times2$ complex matrix factors as a column vector times a row vector and therefore represents a product state.

### Theorem 2.1 — Determinant criterion for zero concurrence

For every pure two-qubit amplitude vector $\psi$,

$$
C(\psi)=0
\quad\Longleftrightarrow\quad
\alpha\delta=\beta\gamma.
$$

For every nonzero state, these conditions are also equivalent to $A_\psi$ having rank one and to $\psi$ being a product state.

**Proof sketch.** Since $C(\psi)=2|\alpha\delta-\beta\gamma|$, concurrence vanishes exactly when the complex number $\alpha\delta-\beta\gamma$ vanishes. This is precisely the zero-determinant condition. A nonzero $2\times2$ matrix has zero determinant exactly when it has rank one, and rank-one coefficient matrices are exactly outer products of two one-qubit coefficient vectors. $\square$

The zero set

$$
\alpha\delta-\beta\gamma=0
$$

is a quadratic algebraic hypersurface in amplitude space. After projectivization it is the Segre variety $\mathbb{CP}^1\times\mathbb{CP}^1$ embedded in $\mathbb{CP}^3$. Thus separable pure states form a distinguished algebraic subvariety rather than an arbitrary subset.

## 3. The sharp concurrence bound

The upper bound follows from two standard inequalities. For complex numbers $z,w$, the triangle inequality gives $|z-w|\le|z|+|w|$. For nonnegative real numbers $x,y$, Young’s quadratic inequality gives

$$
2xy\le x^2+y^2,
$$

because $(x-y)^2\ge0$.

### Lemma 3.1 — Four-variable product bound

For nonnegative real numbers $a,b,c,d$,

$$
2(ad+bc)\le a^2+b^2+c^2+d^2.
$$

**Proof sketch.** Apply $2xy\le x^2+y^2$ first to $(a,d)$ and then to $(b,c)$:

$$
2ad\le a^2+d^2,
\qquad
2bc\le b^2+c^2.
$$

Adding proves the claim. $\square$

### Theorem 3.2 — Concurrence is bounded by squared norm

For every $\psi=(\alpha,\beta,\gamma,\delta)\in\mathbb C^4$,

$$
C(\psi)\le N(\psi).
$$

**Proof sketch.** By the triangle inequality and multiplicativity of the complex norm,

$$
|\alpha\delta-\beta\gamma|
\le |\alpha\delta|+|\beta\gamma|
=|\alpha||\delta|+|\beta||\gamma|.
$$

Multiply by $2$ and apply Lemma 3.1 with

$$
(a,b,c,d)=(|\alpha|,|\beta|,|\gamma|,|\delta|).
$$

The result is

$$
C(\psi)
\le|\alpha|^2+|\beta|^2+|\gamma|^2+|\delta|^2
=N(\psi).
$$

$\square$

### Corollary 3.3 — Unit-interval theorem

Every normalized pure two-qubit state satisfies

$$
0\le C(\psi)\le1.
$$

**Proof sketch.** Nonnegativity follows from $C(\psi)=2|D(\psi)|$. The upper bound is Theorem 3.2 together with $N(\psi)=1$. $\square$

The bound is sharp at both endpoints. Product states realize $C=0$, while Bell states realize $C=1$, as shown below.

### Remark 3.4 — Equality structure

The proof of Theorem 3.2 identifies the inequalities whose equality cases must coincide for maximal concurrence. Equality requires equality in the complex triangle inequality for $\alpha\delta$ and $-\beta\gamma$, together with

$$
|\alpha|=|\delta|,
\qquad
|\beta|=|\gamma|.
$$

A complete classification can be phrased more invariantly: maximally entangled normalized states have coefficient matrices whose two rows are orthogonal and have equal norm, and they form the local-unitary orbit of a Bell state. The detailed orbit classification is a natural continuation of the present determinant analysis.

## 4. Symmetry and Bell-state maximizers

### Theorem 4.1 — Global-phase invariance

Let $u\in\mathbb C$ satisfy $|u|=1$. If

$$
u\psi=(u\alpha,u\beta,u\gamma,u\delta),
$$

then

$$
C(u\psi)=C(\psi).
$$

**Proof sketch.** The determinant is homogeneous of degree two:

$$
D(u\psi)
=(u\alpha)(u\delta)-(u\beta)(u\gamma)
=u^2D(\psi).
$$

Hence

$$
C(u\psi)=2|u^2D(\psi)|=2|u|^2|D(\psi)|=C(\psi).
$$

$\square$

This result ensures that concurrence descends from normalized vectors to physical rays with global phase removed.

### 4.1 Bell states

For $s\in\{-1,1\}$, define

$$
|\Phi_s\rangle=rac{|00\rangle+s|11\rangle}{\sqrt2},
\qquad
|\Psi_s\rangle=rac{|01\rangle+s|10\rangle}{\sqrt2}.
$$

These are the four Bell states.

### Theorem 4.2 — Bell normalization

For each $s\in\{-1,1\}$,

$$
N(\Phi_s)=N(\Psi_s)=1.
$$

**Proof sketch.** Each Bell state has exactly two nonzero amplitudes, each of modulus $1/\sqrt2$. Their squared moduli sum to $1/2+1/2=1$. $\square$

### Theorem 4.3 — Bell maximality

For each $s\in\{-1,1\}$,

$$
C(\Phi_s)=C(\Psi_s)=1.
$$

**Proof sketch.** For $\Phi_s$, the amplitudes are $(1/\sqrt2,0,0,s/\sqrt2)$, so

$$
D(\Phi_s)=\frac{s}{2}.
$$

For $\Psi_s$, the amplitudes are $(0,1/\sqrt2,s/\sqrt2,0)$, so

$$
D(\Psi_s)=-\frac{s}{2}.
$$

Both determinant norms equal $1/2$, and multiplication by $2$ gives concurrence $1$. By Corollary 3.3, this is the maximal possible value. $\square$

The Bell states therefore support the endpoint of the topological analogy: maximal entanglement can be pictured using a maximally linked configuration. The obstruction arises only when this endpoint picture is promoted to an equality for the entire continuum of states.

## 5. An explicit obstruction to integer-valued models

Consider

$$
|\chi\rangle
=rac12|00\rangle+rac1{\sqrt2}|01\rangle+rac12|11\rangle.
$$

Its amplitude vector is

$$
\chi=\left(\frac12,\frac1{\sqrt2},0,\frac12\right).
$$

### Lemma 5.1 — Normalization of the witness

The state $\chi$ is normalized.

**Proof sketch.** Direct calculation gives

$$
N(\chi)
=\frac14+rac12+0+rac14=1.
$$

$\square$

### Lemma 5.2 — Half concurrence

The state $\chi$ has concurrence exactly $1/2$.

**Proof sketch.** Its determinant coordinate is

$$
D(\chi)
=\frac12\cdot\frac12-rac1{\sqrt2}\cdot0
=\frac14.
$$

Therefore

$$
C(\chi)=2\left|\frac14\right|=\frac12.
$$

$\square$

### Theorem 5.3 — Universal integer-valued obstruction

There is no integer-valued function $L$ on normalized pure two-qubit states such that

$$
C(\psi)=|L(\psi)|
$$

for every normalized state $\psi$. In particular, concurrence cannot universally equal the absolute value of an ordinary linking number.

**Proof sketch.** Suppose such a function existed. Applying it to the normalized witness $\chi$ would give

$$
\frac12=C(\chi)=|L(\chi)|.
$$

But $L(\chi)\in\mathbb Z$, so $|L(\chi)|$ is a nonnegative integer and cannot equal $1/2$. This contradiction proves the theorem. $\square$

This theorem does not depend on continuity, on details of a curve construction, or on a particular Hopf projection. It uses only the codomain $\mathbb Z$ and the universal equality claim. Any ordinary linking-number model therefore fails on the explicit witness.

A complementary continuity argument reinforces the conclusion. The unit sphere $S^7$ is connected, concurrence is continuous, and its image contains both $0$ and $1$. Along suitable continuous paths it assumes intermediate values. By contrast, a continuous integer-valued function on a connected space is constant. Even if a proposed linking assignment changes discontinuously, Theorem 5.3 still rules out pointwise equality because of the half-integer witness.

## 6. Hopf geometry and the correct algebraic bridge

### 6.1 A dimensional distinction

Normalized vectors in $\mathbb C^4$ form the seven-sphere

$$
S^7=\{\psi\in\mathbb C^4:N(\psi)=1\}.
$$

Identifying $\mathbb C^4$ with $\mathbb H^2$ leads to the quaternionic Hopf fibration

$$
S^3\hookrightarrow S^7\longrightarrow S^4.
$$

The fibre over each point of $S^4$ is $S^3$. This differs from the classical complex Hopf fibration

$$
S^1\hookrightarrow S^3\longrightarrow S^2,
$$

whose fibres are circles and whose distinct fibres form the familiar Hopf link in $S^3$.

Consequently, a statement describing fibres of $S^7\to S^4$ as linked circles conflates two different Hopf fibrations. Higher-dimensional linking can be defined in appropriate settings, but it is not automatically an ordinary linking number of two circles, and it remains integer-valued when it is an ordinary homological linking invariant.

### 6.2 Exterior algebra

Let the two rows of $A_\psi$ be

$$
r_1=(\alpha,\beta),
\qquad
r_2=(\gamma,\delta).
$$

Their exterior product belongs to the one-dimensional complex vector space $\bigwedge^2\mathbb C^2$ and satisfies

$$
r_1\wedge r_2=(\alpha\delta-\beta\gamma)e_1\wedge e_2.
$$

Thus

$$
C(\psi)=2\|r_1\wedge r_2\|.
$$

This is the precise geometric content of concurrence in the chosen basis: it is twice an area norm. The wedge product vanishes when the row vectors are dependent, exactly the product-state condition. It is largest under unit normalization when the rows are balanced and orthogonal in the appropriate Hermitian sense.

The determinant is also the unique $2\times2$ minor of the coefficient matrix. In larger bipartite systems, coefficient matrices have many minors. Their collective norms are Plücker-coordinate data and naturally generalize the rank-detection role played here by $D(\psi)$. This suggests an exterior-algebra hierarchy for multipartite and higher-dimensional entanglement.

## 7. Algorithms and numerical demonstrations

### 7.1 Stable concurrence evaluation

Given four complex amplitudes, the basic algorithm computes the squared norm and determinant. If the input is to represent a physical state, it can first be normalized by dividing each amplitude by $\sqrt{N(\psi)}$. The concurrence is then $2|D(\psi)|$.

For a fixed-size two-qubit state, the arithmetic cost is constant: four norm squares, two complex products, one subtraction, and one complex modulus. If one treats the number of amplitudes as the input size, normalization is linear in that number, while the two-qubit determinant step remains constant.

Floating-point implementations should allow a small tolerance when checking $0\le C\le1$, because rounding may produce values such as $1+10^{-16}$. Clipping is suitable for display but should not replace reporting raw residuals in scientific calculations.

### 7.2 Demonstration set

A transparent test suite contains:

1. The product state $|00\rangle$, with amplitudes $(1,0,0,0)$ and concurrence $0$.
2. The four Bell states, each with concurrence $1$.
3. The witness $(1/2,1/\sqrt2,0,1/2)$, with concurrence $1/2$.
4. Random complex Gaussian amplitude vectors normalized to unit norm, whose computed concurrences fill the interval between the endpoints.

Random sampling is illustrative rather than a proof of a universal theorem. The exact examples and inequalities above establish the claims; sampling shows their numerical behavior and reveals why a binary “linked or unlinked” model is too coarse.

### 7.3 Integer-distance diagnostic

For a computed concurrence $c\in[0,1]$, define its distance to the nearest nonnegative integer by

$$
\Delta_{\mathbb Z}(c)=\min_{n\in\mathbb Z_{\ge0}}|c-n|.
$$

On $[0,1]$, this simplifies to

$$
\Delta_{\mathbb Z}(c)=\min(c,1-c).
$$

For the witness, $\Delta_{\mathbb Z}(1/2)=1/2$, the largest possible separation from the integer endpoints within the unit interval. For Bell states and product states the diagnostic vanishes, explaining why tests restricted to those examples cannot distinguish concurrence from a hypothetical integer invariant.

## 8. Applications

### 8.1 Quantum-state diagnostics

The determinant criterion gives a constant-time test for separability of pure two-qubit states. Given amplitudes, compute $\alpha\delta-\beta\gamma$. Exact vanishing means a product state; nonzero magnitude quantifies entanglement through concurrence. In experimental data, amplitudes are estimated with uncertainty, so one should propagate errors rather than interpret tiny nonzero determinants as decisive.

### 8.2 Geometry of the separable locus

The equation $D(\psi)=0$ identifies product states as an algebraic variety. This permits the use of tangent spaces, normal directions, and condition numbers. Near a smooth point of the Segre variety, the determinant gives a transverse quadratic coordinate whose magnitude can be compared with Euclidean or Fubini–Study distance. Establishing sharp global comparison constants would turn concurrence into a quantitative geometric distance proxy.

### 8.3 Design constraints for topological models

The obstruction theorem gives a specification for any replacement of ordinary linking number. A successful Hopf-geometric functional $G$ should be real-valued and continuous, invariant under global phase, vanish exactly on product states, and attain one on maximally entangled states. Ideally it should also be invariant under local unitary transformations. Differential-geometric candidates include normalized integrals, holonomies, calibrated volumes, or averaged linking kernels. Such quantities can vary continuously and therefore avoid the integer-codomain obstruction.

### 8.4 Multipartite generalization

For a multipartite pure state, choose a bipartition and flatten the coefficient tensor into a matrix. Rank one across that bipartition characterizes product structure across the cut. The vanishing of all $2\times2$ minors characterizes rank at most one, and higher minors encode richer rank constraints. Norms of families of minors can therefore provide continuous exterior-algebraic entanglement indicators. The two-qubit determinant is the smallest nontrivial case of this broader construction.

## 9. Discussion and limitations

The results establish a negative theorem about a specific universal identification and a positive theorem about the determinant structure of concurrence. They do not claim that topology is absent from quantum entanglement. Nor do they exclude all quantities informally described as “linking.” They exclude equality with an ordinary integer-valued invariant on every normalized pure two-qubit state.

The distinction between discrete and continuous observables is fundamental. Linking number is stable under deformations that avoid crossings; its strength is precisely that it does not change continuously under small perturbations. Concurrence, by contrast, is designed to quantify continuously varying entanglement. Expecting literal equality asks one quantity to possess incompatible behaviors.

Endpoint agreement is especially misleading. Product states give $0$ and Bell states give $1$, matching the simplest unlink/link narrative. But an invariant is determined by its behavior over the whole state space, not by two strata. The half-concurrence witness is therefore a minimal but decisive stress test.

The present treatment concerns pure states. Mixed-state concurrence involves a convex-roof construction and spectral formulas, introducing additional structure. The integer-valued obstruction remains intuitively relevant because mixed-state concurrence also varies continuously, but a separate development is required for precise mixed-state statements.

The paper proves maximality of Bell states but does not derive a full classification of all maximizers under local unitaries. It also does not construct a replacement Hopf-geometric functional. Those are positive classification and construction problems motivated, rather than solved, by the obstruction.

## 10. Future work

A first direction is to construct a canonically normalized real-valued functional on quaternionic Hopf geometry. Its target properties are continuity, global-phase and local-unitary invariance, zero value exactly on product states, and unit value exactly on maximally entangled states. The determinant coordinate supplies a benchmark against which geometric candidates can be tested.

A second direction is an exterior-algebra hierarchy for multipartite entanglement. For each bipartition, one can study Plücker coordinates of coefficient flattenings and determine which norms yield monotones under physically relevant operations.

A third direction is the classification of equality in $C(\psi)\le N(\psi)$. The elementary proof exposes simultaneous equality conditions in the triangle and Young inequalities. Translating these conditions into unitary-invariant language should recover the local-unitary orbit of Bell states.

A fourth direction is a sharp comparison between concurrence and distance to the Segre variety, under both Euclidean and Fubini–Study metrics. Such estimates would connect an algebraic defining equation to an intrinsic geometric displacement from separability.

Finally, one may study the topology of fixed-concurrence level sets after quotienting by global phase. Values strictly between $0$ and $1$ are expected to form regular strata of a common type, while topology may change at the separable and maximally entangled endpoints. This is a natural setting in which topology and concurrence can interact without forcing a continuous quantity to become an integer.

## 11. Conclusion

For a pure two-qubit state, concurrence is governed by one determinant:

$$
C(\psi)=2|\alpha\delta-\beta\gamma|.
$$

This formula yields the exact zero locus of product states, the sharp range $[0,1]$ under normalization, invariance under global phase, and unit concurrence for all four Bell states. It also produces a normalized state with concurrence $1/2$. Because ordinary linking numbers are integers, no integer-valued linking model can equal concurrence for all pure two-qubit states.

The corrected geometric interpretation is exterior-algebraic. Concurrence is the norm of a wedge-product coordinate measuring the failure of the coefficient matrix to have rank one. Hopf geometry may still contribute a valuable interpretation, but any universal quantitative model must be real-valued and continuous. The obstruction does not end the geometric program; it gives that program its necessary mathematical design constraints.
