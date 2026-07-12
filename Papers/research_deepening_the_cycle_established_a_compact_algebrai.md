# Deepening the Algebraic Core of Four-Dimensional Geometry

## Abstract

A single elementary identity, $(a+b)^2 = 4ab + (a-b)^2$, expresses the balance
between a sum and a difference of squares. We show that this identity, together
with its higher-order relatives, forms a compact algebraic core from which a
surprising amount of four-dimensional geometry can be reconstructed. We develop
this core in four directions. First, we record the composition identities of the
normed division algebras: the Brahmagupta–Fibonacci two-square identity
(multiplicativity of the complex modulus), Euler's four-square identity
(multiplicativity of the quaternion norm), and the three-variable Lagrange
identity that yields the Cauchy–Schwarz inequality. Second, we give a complete
characterization of the fibres of the Hopf map: two points of the unit
three-sphere have the same image if and only if they differ by a single unit
complex scalar, so that the fibres are *exactly* the great circles. The nontrivial
direction is proved by an explicit division-free witness, the Hermitian inner
product $\lambda = \bar z z' + \bar w w'$. Third, we establish that multiplication
by $i$ on $\mathbb{C}^n$ is a norm-preserving, fixed-point-free complex structure
in every even dimension — the general form of "rotation through the fourth
dimension." Fourth, we prove the two- and three-radius arithmetic–geometric mean
bounds governing balanced Clifford tori, and the rigidity statement that
conjugation by any nonzero quaternion is an isometry, the algebraic source of the
rotation groups $SO(3)$ and $SO(4)$. The unifying theme is that the geometry
surrounding the Hopf fibration is organized by the composition algebras, and that
the phase ambiguity of a unit vector — recovered locally from two points by an
inner product — is the true bridge between algebra and the projective geometry of
the fibration.

**Keywords:** sum-of-squares identity, Hopf fibration, quaternions, complex
structure, Clifford torus, Cauchy–Schwarz inequality, composition algebra,
arithmetic–geometric mean.

---

## 1. Introduction

Four-dimensional geometry has a reputation for being unvisualizable, yet many of
its central objects are governed by algebra of striking simplicity. This paper
takes as its organizing principle a single identity,

$$(a+b)^2 = 4ab + (a-b)^2, \tag{$\star$}$$

which trivially rearranges the square of a sum. Our thesis is that $(\star)$ and a
small family of related sum-of-squares identities constitute an algebraic core
from which the Hopf fibration, the complex structure of even-dimensional space,
the geometry of Clifford tori, and quaternionic rotations all follow with little
additional machinery.

The connective tissue is the theory of **composition algebras** (equivalently,
normed division algebras): the real numbers $\mathbb{R}$, the complex numbers
$\mathbb{C}$, the quaternions $\mathbb{H}$, and the octonions $\mathbb{O}$, of
dimensions $1, 2, 4, 8$. In each, a norm $N$ satisfies $N(xy) = N(x)N(y)$, and
writing this multiplicativity in coordinates produces exactly the two-, four-, and
eight-square identities. Hurwitz's theorem asserts that the list is complete: no
bilinear composition identity exists in any other dimension. The privileged status
of dimension four in geometry is a direct reflection of the existence of
$\mathbb{H}$.

Our contributions are organized as four self-contained blocks. Section 3 records
the composition identities and derives Cauchy–Schwarz from Lagrange's identity.
Section 4 gives the complete fibre characterization of the Hopf map; the converse
inclusion (Theorem 4.4) is the technical heart of the paper. Section 5 treats the
complex structure $J$ in arbitrary even dimension. Section 6 treats balanced
Clifford tori and quaternionic rotational rigidity. Throughout, we state each
result with a full proof sketch that a reader can reconstruct in detail.

---

## 2. Preliminaries and notation

We work over the reals $\mathbb{R}$, the complex numbers $\mathbb{C}$, and the
real quaternions $\mathbb{H}$. For $z \in \mathbb{C}$ we write $\bar z$ for the
complex conjugate and $N(z) = |z|^2 = z\bar z$ for the squared modulus, so that
$N(z_1 z_2) = N(z_1) N(z_2)$ and $N(\bar z) = N(z)$. The unit three-sphere is
realized as

$$S^3 = \{(z, w) \in \mathbb{C}^2 : N(z) + N(w) = 1\},$$

and the unit two-sphere $S^2 \subset \mathbb{C} \times \mathbb{R}$ as the set of
$(\zeta, t)$ with $N(\zeta) + t^2 = 1$. For quaternions $q \in \mathbb{H}$ we
write $N(q)$ for the quaternion norm, again multiplicative.

Vectors in $\mathbb{C}^n$ are functions $v : \{1, \dots, n\} \to \mathbb{C}$, with
squared Euclidean norm $\sum_i N(v_i)$.

---

## 3. Composition identities and Cauchy–Schwarz

### 3.1 The core identity

**Proposition 3.1 (Sum-of-squares core).** *For all real $a, b$,*
$$(a+b)^2 = 4ab + (a-b)^2.$$

*Proof.* Expand both sides: $(a+b)^2 = a^2 + 2ab + b^2$ and $4ab + (a-b)^2 = 4ab +
a^2 - 2ab + b^2 = a^2 + 2ab + b^2$. $\qquad\blacksquare$

Trivial as it is, $(\star)$ recurs as the load-bearing step in the Hopf sphere
identity (Proposition 4.2) and the Clifford balance (Proposition 6.1).

### 3.2 Two squares: the complex modulus

**Theorem 3.2 (Brahmagupta–Fibonacci identity).** *For all real $a, b, c, d$,*
$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2.$$

*Proof.* Interpret $a^2 + b^2 = N(a+bi)$ and $c^2 + d^2 = N(c+di)$. Then
$(a+bi)(c+di) = (ac-bd) + (ad+bc)i$, and the identity is $N(z_1 z_2) = N(z_1)
N(z_2)$ written in coordinates. Alternatively, expand both sides directly; the
cross terms cancel. $\qquad\blacksquare$

The identity shows that the set of integers expressible as a sum of two squares is
closed under multiplication — a fact at the foundation of classical number theory.

### 3.3 Four squares: the quaternion norm

**Theorem 3.3 (Euler's four-square identity).** *For all real $a_1, \dots, a_4,
b_1, \dots, b_4$,*
$$(a_1^2+a_2^2+a_3^2+a_4^2)(b_1^2+b_2^2+b_3^2+b_4^2)$$
$$= (a_1b_1 - a_2b_2 - a_3b_3 - a_4b_4)^2 + (a_1b_2 + a_2b_1 + a_3b_4 - a_4b_3)^2$$
$$\quad + (a_1b_3 - a_2b_4 + a_3b_1 + a_4b_2)^2 + (a_1b_4 + a_2b_3 - a_3b_2 + a_4b_1)^2.$$

*Proof.* The four bilinear forms on the right are the components of the quaternion
product $(a_1 + a_2 i + a_3 j + a_4 k)(b_1 + b_2 i + b_3 j + b_4 k)$, and the
identity is the multiplicativity $N(pq) = N(p) N(q)$ of the quaternion norm.
Direct expansion confirms it as a polynomial identity. $\qquad\blacksquare$

This is the algebraic heart of four-dimensional geometry: it is the coordinate
form of the norm-preservation used in Theorem 6.4.

### 3.4 Three variables: Lagrange and Cauchy–Schwarz

**Theorem 3.4 (Lagrange's identity).** *For all real $a_1, a_2, a_3, b_1, b_2,
b_3$,*
$$(a_1^2+a_2^2+a_3^2)(b_1^2+b_2^2+b_3^2) - (a_1b_1 + a_2b_2 + a_3b_3)^2$$
$$= (a_1b_2 - a_2b_1)^2 + (a_1b_3 - a_3b_1)^2 + (a_2b_3 - a_3b_2)^2.$$

*Proof.* Direct expansion; the left side is the Gram determinant of the two
vectors $\mathbf{a}, \mathbf{b} \in \mathbb{R}^3$, and the right side is the
squared norm of their cross product $\|\mathbf{a} \times \mathbf{b}\|^2$.
$\qquad\blacksquare$

**Corollary 3.5 (Cauchy–Schwarz in $\mathbb{R}^3$).** *For all real vectors
$\mathbf{a}, \mathbf{b} \in \mathbb{R}^3$,*
$$(a_1b_1 + a_2b_2 + a_3b_3)^2 \le (a_1^2+a_2^2+a_3^2)(b_1^2+b_2^2+b_3^2).$$

*Proof.* The right-hand side of Lagrange's identity is a sum of squares, hence
nonnegative; rearranging gives the inequality. Equality holds iff all three
$2\times2$ minors vanish, i.e. $\mathbf{a}$ and $\mathbf{b}$ are parallel.
$\qquad\blacksquare$

Thus a fundamental inequality of analysis is an immediate consequence of a pure
algebraic identity — the same mechanism by which composition identities encode
metric structure.

---

## 4. The Hopf fibration: fibres are exactly the great circles

### 4.1 The Hopf map

**Definition 4.1.** The *Hopf map* $h : \mathbb{C}^2 \to \mathbb{C} \times
\mathbb{R}$ is
$$h(z, w) = \big(2 z \bar w,\; N(z) - N(w)\big).$$

Restricted to $S^3$, its image lies in $S^2$, by the following.

**Proposition 4.2 (Image on the sphere).** *For all $z, w \in \mathbb{C}$,*
$$N\big(2 z \bar w\big) + \big(N(z) - N(w)\big)^2 = \big(N(z) + N(w)\big)^2.$$

*Proof.* Since $N(2 z \bar w) = 4\, N(z)\, N(w)$ (using $N(2) = 4$, $N(\bar w) =
N(w)$, and multiplicativity), the claim is $4 N(z) N(w) + (N(z) - N(w))^2 = (N(z) +
N(w))^2$, which is $(\star)$ with $a = N(z)$, $b = N(w)$. $\qquad\blacksquare$

In particular, if $(z, w) \in S^3$ then $h(z,w) \in S^2$: the Hopf map is a map
$S^3 \to S^2$.

### 4.2 Fibre invariance (the easy inclusion)

**Theorem 4.3 (Circle invariance).** *For all $z, w, \lambda \in \mathbb{C}$ with
$N(\lambda) = 1$,*
$$h(\lambda z, \lambda w) = h(z, w).$$

*Proof.* For the first component, $2(\lambda z)\overline{(\lambda w)} = 2 \lambda
\bar\lambda\, z \bar w = 2 z \bar w$, since $\lambda \bar\lambda = N(\lambda) = 1$.
For the second, $N(\lambda z) - N(\lambda w) = N(\lambda)(N(z) - N(w)) = N(z) -
N(w)$. $\qquad\blacksquare$

Hence each orbit $\{(\lambda z, \lambda w) : N(\lambda) = 1\}$ — a great circle of
$S^3$ — is contained in a single fibre.

### 4.3 Fibre rigidity (the deep inclusion)

**Theorem 4.4 (Fibre converse).** *Let $(z, w), (z', w') \in S^3$ with $h(z, w) =
h(z', w')$. Then there exists $\lambda \in \mathbb{C}$ with $N(\lambda) = 1$,
$z' = \lambda z$, and $w' = \lambda w$.*

*Proof sketch.* Equality of Hopf images gives two scalar equations,
$$2 z \bar w = 2 z' \bar{w'} \quad\text{and}\quad N(z) - N(w) = N(z') - N(w').$$
Combined with the unit-sphere constraints $N(z) + N(w) = 1 = N(z') + N(w')$, the
second equation forces the coordinatewise norm equalities $N(z) = N(z')$ and $N(w)
= N(w')$. The witness is the **Hermitian inner product**
$$\lambda := \bar z\, z' + \bar w\, w'.$$
One verifies $z' = \lambda z$ and $w' = \lambda w$ by two direct bilinear
computations. For instance,
$$\lambda z = (\bar z z' + \bar w w') z = (z\bar z) z' + (\bar w z) w'
= N(z) z' + \bar w (z w'),$$
and using $z \bar w = z' \bar{w'}$ (so $z w' \cdot(\dots)$ rearranges via the
conjugate relation $\bar z w = \bar{z'} w'$) together with $N(z) + N(w) = 1$ and
$N(w) = N(w')$, the terms collapse to $z'$. The symmetric computation gives
$\lambda w = w'$. Finally,
$$N(z') = N(\lambda) N(z), \qquad N(w') = N(\lambda) N(w),$$
and summing, $1 = N(z') + N(w') = N(\lambda)(N(z) + N(w)) = N(\lambda)$, provided
$(z,w) \neq (0,0)$, which holds since $N(z) + N(w) = 1$. Hence $N(\lambda) = 1$.
$\qquad\blacksquare$

The choice of witness is the crucial move. A naive approach sets $\lambda = z'/z$,
which requires a case split on $z = 0$. The division-free witness $\lambda = \bar z
z' + \bar w w'$ avoids all case analysis and reveals the conceptual content: it is
the inner product of the two unit vectors, so the fibre is precisely the phase
ambiguity of a unit vector.

### 4.4 The characterization

**Theorem 4.5 (Fibres are great circles).** *For $(z, w), (z', w') \in S^3$,*
$$h(z, w) = h(z', w') \iff \exists\, \lambda \in \mathbb{C},\; N(\lambda) = 1,\;
z' = \lambda z,\; w' = \lambda w.$$

*Proof.* The forward direction is Theorem 4.4; the reverse is Theorem 4.3.
$\qquad\blacksquare$

Thus the fibres of $h$ are *exactly* the great circles $\{(\lambda z, \lambda w) :
N(\lambda) = 1\}$, and $h$ realizes the projective quotient $\mathbb{C}^2 \setminus
\{0\} \to \mathbb{CP}^1 \cong S^2$ restricted to the unit sphere. The unit scalar
$\lambda$ is a gauge phase with no invariant meaning, and $h$ is the act of
forgetting it.

**Remark 4.6 (Sharpness).** The unit-sphere hypotheses are essential. Without
them, the diagonal scaling $(z, w) \mapsto (tz, tw)$ multiplies $h$ by $t^2$, so
points of different norm can never share an image; the great-circle description
then fails. The biconditional is sharp precisely because of the sphere
constraint.

---

## 5. The complex structure $J$ in every even dimension

Multiplication by $i$ is the algebraic quarter-turn. On $\mathbb{C}^n \cong
\mathbb{R}^{2n}$ it generalizes the classical "rotation through the fourth
dimension."

**Definition 5.1.** For $v \in \mathbb{C}^n$, define $J v \in \mathbb{C}^n$ by
$(Jv)_i = i\, v_i$ for each coordinate.

**Theorem 5.2 (Complex structure).** $J^2 = -\mathrm{Id}$; that is, $(J(Jv))_i =
-v_i$ for all $i$.

*Proof.* $(J(Jv))_i = i(i\, v_i) = i^2 v_i = -v_i$. $\qquad\blacksquare$

**Theorem 5.3 (Isometry).** *For all $v \in \mathbb{C}^n$,* $\sum_i N((Jv)_i) =
\sum_i N(v_i)$.

*Proof.* $N(i v_i) = N(i) N(v_i) = N(v_i)$ termwise. $\qquad\blacksquare$

**Theorem 5.4 (Fixed-point freeness).** *If $\sum_i N(v_i) = 1$, then $Jv \neq v$.*

*Proof.* Suppose $Jv = v$. Then $i v_i = v_i$ for every $i$, so $(i - 1) v_i = 0$.
Since $i - 1 \neq 0$ (its real part is $-1 \neq 0$), each $v_i = 0$, whence
$\sum_i N(v_i) = 0 \neq 1$, a contradiction. $\qquad\blacksquare$

Theorems 5.2–5.4 hold uniformly in $n$. The fixed-point-free property is the
hallmark of a genuinely even-dimensional rotation: an ordinary rotation of
odd-dimensional space always fixes an axis, but $J$ moves every point of the
sphere. This is the general form of "rotation through the fourth dimension":
dimension four is the first place a quarter-turn can act without leaving an
invariant axis, and $J$ is its purest algebraic embodiment.

---

## 6. Balanced Clifford tori and quaternionic rigidity

### 6.1 Two radii

The Clifford tori in $S^3$ are parameterized by radii with $a + b = 1$ (writing
$a, b$ for the squared radii), the torus area being controlled by the product
$4ab$.

**Proposition 6.1 (Clifford balance).** *If $a + b = 1$, then $4ab = 1 - (a-b)^2$.*

*Proof.* Immediate from $(\star)$: $1 = (a+b)^2 = 4ab + (a-b)^2$. $\qquad
\blacksquare$

**Theorem 6.2 (Balanced extremum).** *If $a + b = 1$, then $4ab = 1$ if and only
if $a = b$ (necessarily $a = b = \tfrac12$).*

*Proof.* By Proposition 6.1, $4ab = 1 \iff (a-b)^2 = 0 \iff a = b$.
$\qquad\blacksquare$

So the balanced Clifford torus $a = b = \tfrac12$ uniquely maximizes the area
functional — the geometric face of the arithmetic–geometric mean inequality.

### 6.2 Three radii

**Theorem 6.3 (Three-radius AM–GM bound).** *If $a, b, c \ge 0$ and $a + b + c =
1$, then $abc \le \tfrac{1}{27}$, with equality iff $a = b = c = \tfrac13$.*

*Proof sketch.* This is the arithmetic–geometric mean inequality for three
nonnegative reals normalized to sum $1$. It follows from the nonnegativity of the
symmetric squares $(a-b)^2, (b-c)^2, (a-c)^2$ together with the products $ab, bc,
ca \ge 0$: expanding $1 = (a+b+c)^3$ and comparing with $27abc$ reduces the claim
to a nonnegative combination of these terms. Equality requires all pairwise
differences to vanish, forcing $a = b = c = \tfrac13$. $\qquad\blacksquare$

This is the balanced Clifford torus of $S^5$: among flat $3$-tori with squared
radii summing to one, the balanced torus $a = b = c = \tfrac13$ maximizes the
product $abc$ that controls the volume.

### 6.3 Quaternionic rotational rigidity

**Theorem 6.4 (Conjugation is an isometry).** *For all $q, x \in \mathbb{H}$ with
$q \neq 0$,* $N(q x q^{-1}) = N(x)$.

*Proof.* By multiplicativity of the quaternion norm, $N(q x q^{-1}) = N(q) N(x)
N(q^{-1}) = N(q) N(x) / N(q) = N(x)$, using $N(q^{-1}) = 1/N(q)$, valid since
$N(q) \neq 0$. $\qquad\blacksquare$

On unit quaternions ($N(q) = 1$), the map $x \mapsto q x q^{-1}$ fixes the real
axis and acts as a rotation on the three-dimensional space of imaginary
quaternions, realizing the double cover $\mathbb{H}^\times \to SO(3)$; the two-sided
action $(p, q) \cdot x = p x q^{-1}$ realizes $SO(4)$. The coordinate form of the
multiplicativity used here is precisely Euler's four-square identity (Theorem 3.3).
This is why quaternions provide the standard, drift-free representation of
three-dimensional rotations in robotics, aerospace, and computer graphics.

---

## 7. Discussion

The through-line of this development is that the "fourth dimension," far from being
an amorphous abstraction, is organized by the composition algebras $\mathbb{R},
\mathbb{C}, \mathbb{H}, \mathbb{O}$. Each square-sum identity is the coordinate
avatar of norm-multiplicativity in one of these algebras, and each geometric
theorem is a shadow of that algebra's structure:

- The **two- and four-square identities** are $\mathbb{C}$ and $\mathbb{H}$ made
  explicit.
- The **Hopf fibration** is the projective quotient $\mathbb{C}^2 \to
  \mathbb{CP}^1 \cong S^2$; its fibres are the unit-scalar orbits, recovered
  *exactly* from two points by the Hermitian inner product.
- The **complex structure $J$** is multiplication by the unit imaginary of
  $\mathbb{C}$, acting coordinatewise.
- **Quaternionic conjugation** is the norm-preserving inner automorphism of
  $\mathbb{H}$, generating $SO(3)$ and $SO(4)$.

The methodological lesson of the fibre analysis is that a fibre has two faces of
opposite character. One inclusion (Theorem 4.3) is *invariance* under a group
action and is easy; the other (Theorem 4.4) is *rigidity* — the reconstruction of
the group element from two orbit points — and is the substantive step. The
division-free witness $\lambda = \bar z z' + \bar w w'$ turns rigidity into a
short bilinear computation and simultaneously identifies the fibre as the phase
ambiguity of a unit vector.

---

## 8. Future directions

**The octonionic Hopf map has abelian great-sphere fibres.** For the octonionic
Hopf map $S^{15} \to S^8$, the $S^7$ fibres should be recoverable from a single
inner-product witness analogous to $\lambda = \bar z z' + \bar w w'$, evaluated in
a fixed associative subalgebra of the octonions. The phase ambiguity of a unit
vector is always a principal homogeneous space for the unit group of the
underlying composition algebra, and octonionic non-associativity obstructs only
the *global* group structure, not the local reconstruction of the fibre from two
points. Because the complex fibre reconstruction reduces to two bilinear
identities and one norm-multiplicativity step — each with a direct quaternionic
and octonionic analogue via the two- and four-square identities — the same proof
skeleton can be transported dimension by dimension.

**Balanced tori are the unique isoperimetric flat tori on every odd sphere.**
Among all flat $m$-tori embedded in $S^{2m-1}$ with squared radii summing to one,
the balanced torus $r_i^2 = 1/m$ should uniquely maximize the induced volume, with
volume growing like $m^{-m/2}$ up to an explicit constant. The volume is a
monotone function of the elementary symmetric product $\prod r_i^2$, so the
arithmetic–geometric mean inequality — verified here for $m = 2, 3$ with sharp
equality — controls the extremal problem in every dimension. The general statement
needs only the $m$-variable AM–GM together with the observed monotonicity of the
volume functional.

**Fixed-point-free isometries of even spheres are exactly the almost-complex
ones.** Every fixed-point-free linear isometry of $S^{2n-1}$ of order dividing $4$
should be conjugate to multiplication by $i$ on $\mathbb{C}^n$; equivalently, the
"rotation through the fourth dimension" is, up to change of coordinates, the only
algebraic complex structure available. Fixed-point freeness is equivalent to the
absence of eigenvalue $1$, which for an order-$4$ isometry forces the $\pm i$
eigenspaces to pair the coordinates exactly as a complex structure does. The
obstruction is concrete: $J$ squares to $-1$, preserves the norm, and has no
invariant axis, and the fixed-point analysis reduces to the single scalar fact
$i - 1 \neq 0$.

---

## 9. Conclusion

Starting from the elementary identity $(a+b)^2 = 4ab + (a-b)^2$, we have assembled
a compact algebraic core for four-dimensional geometry and pushed it to a complete
characterization of the Hopf fibres, a uniform treatment of the even-dimensional
complex structure, and sharp balance and rigidity results for Clifford tori and
quaternionic rotations. The recurring principle is that norm-multiplicativity in
the composition algebras is both the algebraic content of the sum-of-squares
identities and the geometric content of the fibration; the Hermitian inner product
is the bridge that recovers the projective quotient from its algebra. Hurwitz's
theorem — that composition identities exist only in dimensions $1, 2, 4, 8$ —
explains why four is a distinguished dimension and marks the natural boundary of
this circle of ideas.
