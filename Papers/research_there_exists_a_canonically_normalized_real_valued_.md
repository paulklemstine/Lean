# A Canonically Normalized Determinant Functional in Quaternionic Two-Qubit Geometry

**Aristotle**  
**August 2, 2026**

## Abstract

A pure two-qubit state may be represented by a $2\times2$ complex coefficient matrix. We study the normalized modulus of its determinant,

$$
H(\psi)=
\begin{cases}
0,&\|\psi\|^2=0,\\[3pt]
\dfrac{2|ad-bc|}{\|\psi\|^2},&\|\psi\|^2\ne0,
\end{cases}
$$

where $\psi=(a,b,c,d)$ and $\|\psi\|^2=|a|^2+|b|^2+|c|^2+|d|^2$. This quantity is the normalized modulus of the exterior-square coordinate singled out by the quaternionic Hopf description; on normalized states it is pure-state concurrence. We give a self-contained algebraic treatment of its fundamental geometry. The complex Lagrange identity decomposes the product of the squared row norms into determinant and Hermitian-overlap terms. From this identity we prove projective scale invariance, the sharp range $0\le H\le1$ on normalized states, and the exact characterization of the zero locus as the rank-one, or product-state, variety. We then classify every sharp maximizer: $H=1$ holds exactly when the two coefficient rows are Hermitian-orthogonal and each has squared norm $1/2$. The equality classification supplies the algebraic core of the Bell-state normal form and explains why a continuous determinant coordinate, rather than an integer-valued linking invariant, is adapted to two-qubit entanglement. We conclude with numerical algorithms, geometric applications, and directions involving distance to the Segre variety, level-set topology, and exterior-power generalizations.

## 1. Introduction

The geometry of a composite quantum state differs fundamentally from the geometry of either subsystem. A pure state of two qubits is specified by four complex amplitudes,

$$
|\psi\rangle=a|00\rangle+b|01\rangle+c|10\rangle+d|11\rangle,
$$

subject to normalization and the irrelevance of global phase. Entanglement records whether this vector factors as a tensor product. It is not a binary phenomenon: pure states interpolate continuously between product states and maximally entangled states.

This continuity rules out a literal integer-valued linking number as a complete entanglement measure. A linking number remains locally constant under nonsingular deformations, whereas the entanglement of a state can vary through every real value in an interval. The useful geometric coordinate is instead the determinant of the coefficient matrix. Its vanishing detects rank one, its modulus varies continuously, and normalization turns it into a projectively well-defined number in $[0,1]$.

The purpose of this paper is to derive these facts from one elementary but powerful identity and to determine all equality cases. Write the coefficient matrix and its rows as

$$
A_\psi=\begin{pmatrix}a&b\\c&d\end{pmatrix},
\qquad r_1=(a,b),\qquad r_2=(c,d).
$$

The determinant $ad-bc$ is the coefficient of $r_1\wedge r_2$ in $\bigwedge^2\mathbb C^2$. It therefore measures the complex area spanned by the rows. The Hermitian inner product $\overline a c+\overline b d$ measures their overlap. The complex Lagrange identity states that the squared exterior area plus the squared overlap equals the product of the squared row lengths. Combining this identity with the arithmetic-geometric mean inequality yields both the sharp bound and its rigidity.

The discussion is entirely intrinsic to pure two-qubit states. No probabilistic interpretation is required for the proofs, although the row squared norms may be read as the probabilities associated with the first qubit in the computational basis. The zero vector is included only to make the functional total; physical states are nonzero rays.

## 2. States, projective geometry, and exterior area

### 2.1 Two-qubit coefficient matrices

A **two-qubit coefficient vector** is a quadruple $\psi=(a,b,c,d)\in\mathbb C^4$, equivalently a matrix

$$
A_\psi=\begin{pmatrix}a&b\\c&d\end{pmatrix}.
$$

Its squared Hilbert norm is

$$
N(\psi)=\|\psi\|^2=|a|^2+|b|^2+|c|^2+|d|^2.
$$

The state is **normalized** when $N(\psi)=1$. Nonzero vectors that differ by multiplication by a scalar $z\in\mathbb C^\times$ determine the same point of complex projective space. In particular, multiplication by a unit complex number is the familiar global-phase equivalence.

Define the squared row norms

$$
x=\|r_1\|^2=|a|^2+|b|^2,
\qquad
y=\|r_2\|^2=|c|^2+|d|^2,
$$

and the Hermitian row overlap

$$
s=\langle r_1,r_2\rangle=\overline a c+\overline b d.
$$

Then $N=x+y$. The exterior-square coordinate is

$$
\Delta=\det A_\psi=ad-bc.
$$

Under a common scalar multiplication $\psi\mapsto z\psi$, the quantities transform as

$$
N\mapsto |z|^2N,
\qquad \Delta\mapsto z^2\Delta,
\qquad |\Delta|\mapsto |z|^2|\Delta|.
$$

These matching homogeneities motivate the following definition.

### 2.2 The normalized Hopf determinant functional

**Definition 2.1.** For $\psi=(a,b,c,d)\in\mathbb C^4$, define

$$
H(\psi)=
\begin{cases}
0,&N(\psi)=0,\\[4pt]
\dfrac{2|\Delta|}{N(\psi)},&N(\psi)\ne0.
\end{cases}
$$

For $N=1$, this is $H=2|ad-bc|$. It agrees with the concurrence of a pure two-qubit state. Geometrically, $|\Delta|$ is the norm of the wedge product $r_1\wedge r_2$, and the denominator removes the scale of the chosen representative. In the quaternionic Hopf description, the determinant is a distinguished complex component of the relational coordinate; the normalized modulus gives a real-valued projective functional.

The normalization factor $2$ is selected so that the maximum on the unit sphere is one. This fact will follow rather than be assumed.

### 2.3 Product states and the Segre variety

A nonzero state is a **product state** if there are vectors $(\alpha,\beta)$ and $(\gamma,\delta)$ such that

$$
|\psi\rangle=(\alpha|0\rangle+\beta|1\rangle)
\otimes(\gamma|0\rangle+\delta|1\rangle).
$$

Its coefficient matrix factors as

$$
A_\psi=
\begin{pmatrix}\alpha\\\beta\end{pmatrix}
\begin{pmatrix}\gamma&\delta\end{pmatrix},
$$

so it has rank one. Conversely, every nonzero rank-one $2\times2$ matrix admits such a factorization. Thus the projective product-state set is the Segre variety $\mathbb{CP}^1\times\mathbb{CP}^1\subset\mathbb{CP}^3$, and its defining equation is

$$
\Delta=ad-bc=0.
$$

## 3. The fundamental identity

The central algebraic statement is a two-dimensional complex Lagrange identity.

**Theorem 3.1 (Complex Lagrange identity).** For all $a,b,c,d\in\mathbb C$,

$$
|ad-bc|^2+|\overline a c+\overline b d|^2
=(|a|^2+|b|^2)(|c|^2+|d|^2).
$$

Equivalently,

$$
|\Delta|^2+|s|^2=xy.
$$

**Proof sketch.** Expand both squared moduli. The determinant term is

$$
|ad-bc|^2=|a|^2|d|^2+|b|^2|c|^2
-2\operatorname{Re}(a\overline b\,\overline c d),
$$

while the inner-product term is

$$
|\overline a c+\overline b d|^2
=|a|^2|c|^2+|b|^2|d|^2
+2\operatorname{Re}(a\overline b\,\overline c d).
$$

The mixed terms cancel. The four remaining products factor as

$$
|a|^2|c|^2+|a|^2|d|^2+|b|^2|c|^2+|b|^2|d|^2
=(|a|^2+|b|^2)(|c|^2+|d|^2).
$$

This proves the identity.

The identity is a Pythagorean decomposition. If $r_1\ne0$, decompose $r_2$ into a component parallel to $r_1$ and a component Hermitian-orthogonal to it. The overlap measures the parallel contribution, while the wedge product measures the orthogonal contribution. In two complex dimensions these account for the full product $\|r_1\|^2\|r_2\|^2$.

**Corollary 3.2 (Determinant-row bound).** For every state,

$$
|\Delta|^2\le xy.
$$

Equality holds if and only if $s=0$, that is, if and only if the two rows are Hermitian-orthogonal.

**Proof sketch.** Rearrange Theorem 3.1 as $|\Delta|^2=xy-|s|^2$. Since $|s|^2\ge0$, the inequality follows, and equality occurs exactly when $|s|^2=0$.

## 4. Projective invariance and the exact zero locus

**Theorem 4.1 (Projective scale invariance).** For every state $\psi$ and every nonzero scalar $z\in\mathbb C$,

$$
H(z\psi)=H(\psi).
$$

**Proof sketch.** If $\psi=0$, both sides are zero. Otherwise, $N(z\psi)=|z|^2N(\psi)$ and $\Delta(z\psi)=z^2\Delta(\psi)$. Hence

$$
H(z\psi)=\frac{2|z^2\Delta|}{|z|^2N}
=\frac{2|z|^2|\Delta|}{|z|^2N}=H(\psi).
$$

Thus $H$ descends to a function on nonzero projective state space. It is continuous there because it is a quotient of continuous functions with positive denominator. The special assignment $H(0)=0$ makes the definition total but does not make it continuous at the origin: along any ray, scale invariance keeps $H$ constant. This causes no difficulty because the zero vector is not a physical state.

**Theorem 4.2 (Exact zero locus).** For every coefficient vector $\psi$,

$$
H(\psi)=0\quad\Longleftrightarrow\quad \Delta=0.
$$

For nonzero states these conditions are further equivalent to $A_\psi$ having rank one and to $\psi$ being a product state.

**Proof sketch.** If $N>0$, the factor $2/N$ is strictly positive, so $H=0$ exactly when $|\Delta|=0$, equivalently $\Delta=0$. If $N=0$, all four amplitudes vanish because each squared modulus is nonnegative, and therefore $\Delta=0$ as well. Finally, a nonzero $2\times2$ matrix has determinant zero exactly when its rank is one, and rank one is equivalent to the tensor factorization displayed in Section 2.3.

This theorem identifies the complete vanishing set, not merely a sufficient class. Algebraically, concurrence is the normalized norm of the quadratic equation cutting out the Segre variety.

## 5. Sharp range on normalized states

We next establish the calibration promised in Definition 2.1.

**Theorem 5.1 (Sharp unit-interval bound).** If $N(\psi)=1$, then

$$
0\le H(\psi)\le1.
$$

Both endpoints are attained.

**Proof sketch.** Nonnegativity is immediate. For a normalized state, $x+y=1$. The complex Lagrange identity and nonnegativity of $|s|^2$ imply

$$
|\Delta|^2\le xy.
$$

The elementary identity $(x-y)^2\ge0$ gives $4xy\le(x+y)^2$, hence

$$
xy\le\frac14.
$$

Therefore $|\Delta|\le1/2$, and

$$
H=2|\Delta|\le1.
$$

The product state $|00\rangle$ attains zero, while the Bell state $(|00\rangle+|11\rangle)/\sqrt2$ attains one.

The proof contains two inequalities:

$$
|\Delta|^2\le xy\le\frac14.
$$

The first loses information exactly when the rows overlap; the second loses information exactly when their squared norms are unequal. Consequently, equality in the final bound is rigid.

### 5.1 Continuous realization of every value

Although not needed for the bound, a one-parameter family makes continuity explicit. For $t\in[0,1]$, let

$$
|\psi_t\rangle=\sqrt t\,|00\rangle+\sqrt{1-t}\,|11\rangle.
$$

This state is normalized and has

$$
H(\psi_t)=2\sqrt{t(1-t)}.
$$

As $t$ runs from $0$ to $1/2$, the value rises continuously from $0$ to $1$. Thus every $c\in[0,1]$ occurs. In particular, an integer-valued quantity cannot equal $H$ on all pure states.

## 6. Complete classification of sharp maximizers

**Theorem 6.1 (Sharp-maximizer classification).** Let $\psi=(a,b,c,d)$ be normalized. Then $H(\psi)=1$ if and only if

$$
\overline a c+\overline b d=0,
$$

and

$$
|a|^2+|b|^2=\frac12,
\qquad
|c|^2+|d|^2=\frac12.
$$

Equivalently, the two coefficient rows are Hermitian-orthogonal and have equal norm $1/\sqrt2$.

**Proof sketch.** Suppose first that $H=1$. Since the state is normalized, $2|\Delta|=1$ and therefore $|\Delta|^2=1/4$. The Lagrange identity gives

$$
\frac14+|s|^2=xy.
$$

Normalization gives $x+y=1$, and AM–GM gives $xy\le1/4$. Hence

$$
\frac14\le\frac14+|s|^2=xy\le\frac14.
$$

Every inequality is equality. Thus $|s|^2=0$, so $s=0$, and $xy=1/4$. The equations $x+y=1$ and $xy=1/4$ imply $(x-y)^2=0$, hence $x=y=1/2$.

Conversely, assume $s=0$ and $x=y=1/2$. The Lagrange identity becomes

$$
|\Delta|^2=xy=\frac14.
$$

Thus $|\Delta|=1/2$ and $H=1$.

The theorem classifies every equality case simultaneously. Orthogonality alone is insufficient if one row is too short; equal row norms alone are insufficient if the rows overlap. Maximal exterior area requires both angular separation and balanced allocation of norm.

### 6.1 Relation to Bell geometry

If the rows are orthogonal and each has norm $1/\sqrt2$, then $\sqrt2 A_\psi$ has orthonormal rows and is therefore unitary. Hence every maximizer has the matrix form

$$
A_\psi=\frac1{\sqrt2}U
$$

for some $2\times2$ unitary matrix $U$. This observation is the algebraic core of the statement that every maximally entangled pure two-qubit state is related to a Bell state by local unitary transformations. Establishing a chosen local-action convention and writing the explicit orbit map are additional representation-theoretic steps, but the required row geometry has already been completely determined.

The standard Bell state has

$$
A_{\Phi^+}=\frac1{\sqrt2}
\begin{pmatrix}1&0\\0&1\end{pmatrix}.
$$

Other maximizers may carry arbitrary phases or rotated local bases, yet Theorem 6.1 shows that their normalized coefficient matrices retain the same balanced orthogonal structure.

## 7. Computational algorithms and numerical diagnostics

The functional and all diagnostic quantities require constant work for a two-qubit state.

### 7.1 Direct evaluation

Given $a,b,c,d\in\mathbb C$:

1. Compute $N=|a|^2+|b|^2+|c|^2+|d|^2$.
2. If $N=0$, return $H=0$.
3. Compute $\Delta=ad-bc$.
4. Return $H=2|\Delta|/N$.

This uses a fixed number of complex arithmetic operations, so its time and memory complexity are $O(1)$. If amplitudes are supplied as floating-point values, a robust implementation should compare residuals against a tolerance rather than test identities literally.

### 7.2 Identity and endpoint diagnostics

To diagnose the geometry, also compute

$$
x=|a|^2+|b|^2,
\quad y=|c|^2+|d|^2,
\quad s=\overline a c+\overline b d.
$$

The residual

$$
R_{\mathrm{Lag}}=\left||\Delta|^2+|s|^2-xy\right|
$$

checks numerical consistency with the Lagrange identity. For a normalized state, the maximizer residuals are

$$
R_{\perp}=|s|,
\qquad R_{\mathrm{bal}}=\left|x-\frac12\right|+
\left|y-\frac12\right|.
$$

A state numerically close to $H=1$ should make both residuals small. The identity explains why this is necessary: the deficit from maximality splits between overlap and imbalance.

### 7.3 Representative examples

For $|00\rangle$, the coefficient matrix has only $a=1$ nonzero. The determinant vanishes, so $H=0$.

For the Bell state $(|00\rangle+|11\rangle)/\sqrt2$, one has $a=d=1/\sqrt2$ and $b=c=0$. Thus $|\Delta|=1/2$, $s=0$, and $x=y=1/2$, giving $H=1$.

For

$$
|\chi\rangle=\frac{\sqrt{2+\sqrt3}}2|00\rangle+
\frac{\sqrt{2-\sqrt3}}2|11\rangle,
$$

the two real coefficients have squared sum one and product $1/4$. Hence $H=1/2$. This explicit interior value exhibits the obstruction to any integer-valued replacement.

Multiplying any of these vectors by, for example, $z=2e^{i\pi/3}$ changes its norm and global phase but leaves $H$ unchanged.

## 8. Geometric interpretation and applications

### 8.1 Exterior algebra rather than discrete linking

The determinant is a Plücker coordinate: it records the second exterior power of the row span. This places concurrence naturally within algebraic and differential geometry. A product state has a decomposable flattening of rank one, so its exterior square vanishes. Entanglement appears as nonzero exterior area.

A discrete linking number may still describe topology associated with selected level sets or fibers, but it cannot itself reproduce the continuously varying magnitude $H$. The normalized determinant is compatible with continuous deformation while retaining a precise projective meaning.

### 8.2 Distance from the product-state variety

The equation $\Delta=0$ cuts out the Segre variety. Since $H$ is the normalized modulus of this defining quadratic, it serves as an algebraic measure of departure from that variety. It is not automatically identical to metric distance: a defining polynomial and a geodesic distance have different local scaling in tangent and normal directions. Nevertheless, singular-value coordinates suggest an exact connection.

For a normalized matrix with Schmidt coefficients $\sigma_1,\sigma_2\ge0$, one has

$$
\sigma_1^2+\sigma_2^2=1,
\qquad H=2\sigma_1\sigma_2.
$$

Thus

$$
\sigma_1^2,\sigma_2^2=rac{1\pm\sqrt{1-H^2}}2.
$$

The larger Schmidt coefficient controls the best product-state overlap. This leads to a candidate exact Euclidean distance formula discussed in Section 10.

### 8.3 Level-set stratification

The endpoints have distinct geometry. At $H=0$, the state lies on the Segre variety. At $H=1$, the coefficient rows are balanced and orthogonal, producing an enlarged symmetry. Interior values correspond to two unequal nonzero Schmidt coefficients. This suggests that all projective level sets with $0<c<1$ share a common homogeneous-space type, while topology or stabilizer dimension changes at the endpoints.

### 8.4 Extension to larger systems

For a bipartite state represented by an $m\times n$ coefficient matrix, rank one is detected by the vanishing of all $2\times2$ minors. Those minors are coordinates of the exterior-square map. Higher minors encode higher exterior powers and rank strata. Consequently, the two-qubit determinant is the first nontrivial member of a potential hierarchy of normalized minor norms.

For multipartite states, one may flatten the coefficient tensor across each bipartition and collect the Plücker coordinates of the resulting matrices. Norms and inequalities among these coordinates could provide complementary entanglement diagnostics. Care is required: monotonicity under allowed quantum operations and compatibility across different flattenings do not follow from the two-qubit case alone.

## 9. Discussion

### 9.1 Stability and near-maximizers

The same identities also give quantitative information near the upper endpoint. Suppose a normalized state has $H=1-\varepsilon$ with $0\le\varepsilon\le1$. Then

$$
|\Delta|^2=\frac{(1-\varepsilon)^2}{4}.
$$

Because $|\Delta|^2+|s|^2=xy\le1/4$, one obtains

$$
|s|^2\le\frac{1-(1-\varepsilon)^2}{4}
=\frac{2\varepsilon-\varepsilon^2}{4}.
$$

Thus near-maximal concurrence forces the rows to be nearly orthogonal. Balance is controlled as well. Since $x+y=1$,

$$
(x-y)^2=1-4xy\le1-4|\Delta|^2
=2\varepsilon-\varepsilon^2.
$$

Consequently,

$$
|x-y|\le\sqrt{2\varepsilon-\varepsilon^2}.
$$

These estimates are direct consequences of the exact argument and require no compactness or limiting procedure. They show that rigidity at $H=1$ is stable: a sequence whose functional values approach one must simultaneously approach row orthogonality and equal row weights. The estimates can guide numerical threshold choices, although floating-point diagnostics should also account for input and rounding errors.

### 9.2 Structural summary

The results may be summarized as a chain of exact equivalences and inequalities:

$$
H=0
\quad\Longleftrightarrow\quad
\Delta=0
\quad\Longleftrightarrow\quad
\operatorname{rank}(A_\psi)\le1,
$$

for nonzero states, and, under normalization,

$$
0\le H=2|\Delta|\le2\sqrt{xy}\le1.
$$

At the upper endpoint,

$$
H=1
\quad\Longleftrightarrow\quad
s=0\text{ and }x=y=\frac12.
$$

The complex Lagrange identity unifies every statement. It interprets the determinant not as an arbitrary polynomial but as the portion of the row-norm product not consumed by Hermitian overlap. AM–GM then identifies balance as the remaining requirement for maximality.

The functional is canonical in three complementary senses. It is algebraically natural because it is the norm of the unique $2\times2$ determinant; projectively natural because numerator and denominator have the same scaling degree; and metrically calibrated because its normalized range is exactly $[0,1]$. These features explain why the expression appears across quantum information, exterior algebra, and Hopf-geometric descriptions.

There are also clear boundaries to the present conclusions. The value assigned at the zero vector is conventional, and continuity is asserted on the nonzero projective domain. The sharp-maximizer theorem identifies the row geometry but does not by itself build a full theory of local unitary group actions. Finally, higher-dimensional minor norms require separate analysis before they can be called entanglement monotones.

## 10. Future directions

### 10.1 Local-unitary normal form

The equality classification implies that $\sqrt2 A_\psi$ is unitary for every normalized maximizer. A next step is to formulate the left and right $U(2)$ actions explicitly and prove that every such matrix lies in the local-unitary orbit of

$$
\frac1{\sqrt2}\begin{pmatrix}1&0\\0&1\end{pmatrix}.
$$

This should reduce to constructing a unitary transformation from an orthonormal basis and tracking transpose or conjugation conventions in the coefficient-matrix action.

### 10.2 Exact distance to the Segre variety

For normalized pure states, the proposed minimal Euclidean distance to normalized product states is

$$
\sqrt{2-2\sqrt{\frac{1+\sqrt{1-H(\psi)^2}}2}}.
$$

A singular-value decomposition should identify the nearest product state and simultaneously yield the corresponding Fubini–Study distance. Proving optimal constants relating $H$ directly to these distances would quantify how the determinant vanishes near tangent and transverse directions of the Segre variety.

### 10.3 Interior level-set topology

After quotienting global phase, one expects each level $H=c$ with $0<c<1$ to be a smooth homogeneous space of fixed diffeomorphism type. The endpoint $H=1$ has additional symmetry, while $H=0$ is the Segre stratum. Singular-value coordinates and stabilizer calculations should determine the precise topology and show where changes occur.

### 10.4 Exterior-power hierarchy

For larger bipartite flattenings, the complete family of minors gives Plücker coordinates for exterior powers. A systematic theory should determine which normalized combinations are invariant under projective scaling, which satisfy sharp norm inequalities, and which are monotone under specified classes of local operations. The two-qubit theorem supplies the base case: one minor, one exact Lagrange identity, and a fully classified equality locus.

## 11. Conclusion

The normalized determinant

$$
H(\psi)=\frac{2|ad-bc|}{|a|^2+|b|^2+|c|^2+|d|^2}
$$

for nonzero two-qubit vectors is a continuous projective measure with exact geometric endpoints. It vanishes precisely on product states, takes every value in $[0,1]$ on normalized states, and reaches one precisely for balanced Hermitian-orthogonal rows. The complex Lagrange identity exposes the mechanism: determinant area and row overlap partition the product of row energies, while AM–GM limits that product under fixed total norm.

This replaces a discrete linking intuition with a calibrated exterior-area coordinate. The result is both elementary and structurally informative: separability is rank collapse, maximal entanglement is balanced orthogonality, and the intervening geometry is measured by the normalized magnitude of a single Plücker coordinate.