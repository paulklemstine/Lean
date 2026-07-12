# A Compact Algebraic Core for Four-Dimensional Geometry

## Abstract

We show that four apparently independent constructions in four-dimensional
geometry — the canonical fixed-point-free complex structure on $\mathbb{R}^4$, the
Hopf fibration of the three-sphere, the balanced radii of the Clifford torus, and
the interplay between the volume of the four-ball and the surface measure of the
three-sphere — are all governed by a single sum-of-squares identity,

$$(a+b)^2 = 4ab + (a-b)^2.$$

Alongside this continuous core we isolate a discrete companion, the binomial
identity $\sum_{k=0}^{n}(-1)^k\binom{n}{k}2^{\,n-k} = 1$, from which the Euler
characteristic $1-(-1)^n$ of the boundary of the $n$-cube follows immediately. We
give precise statements and self-contained proofs of each result, explain the
odd-dimensional eigenvalue obstruction in concrete terms, and outline how each
strand extends to higher dimensions.

## 1. Introduction

Four-dimensional geometry is celebrated for phenomena with no lower-dimensional
analogue: rotations without an axis, the linking of the Hopf fibers, exotic smooth
structures, and the peculiar arithmetic of higher-dimensional volumes. Such
phenomena are usually presented one at a time, each with its own machinery. The
purpose of this paper is to expose a common algebraic spine.

Our central observation is elementary but organizing. The identity
$$(a+b)^2 = 4ab + (a-b)^2 \tag{$\star$}$$
relates a product $4ab$, a squared difference $(a-b)^2$, and a squared sum
$(a+b)^2$. These are precisely the quantities that arise when one computes squared
norms, area products, and radius constraints in four dimensions. We will see that
$(\star)$ underlies (i) the sphere identity behind the Hopf map, (ii) the extremal
balance of the Clifford torus, and (iii) the norm preservation of the canonical
complex structure. Its discrete counterpart, the binomial theorem specialized to
$(2-1)^n$, governs the combinatorics of the hypercube.

Throughout, $\mathbb{R}^4$ is modeled as ordered quadruples with the standard
Euclidean structure, and $\mathbb{C}^2$ is identified with $\mathbb{R}^4$ in the
usual way.

## 2. The algebraic core

**Lemma 2.1 (Sum-of-squares core).** *For all real numbers $a,b$,*
$$(a+b)^2 = 4ab + (a-b)^2.$$

*Proof.* Both sides expand to $a^2 + 2ab + b^2$. $\qquad\blacksquare$

Trivial as it is, Lemma 2.1 is the engine of Sections 4, 5, and 6. Its discrete
analogue is the following.

**Lemma 2.2 (Alternating binomial identity).** *For every $n \ge 0$,*
$$\sum_{k=0}^{n} (-1)^k \binom{n}{k}\, 2^{\,n-k} = 1.$$

*Proof.* By the binomial theorem, $\sum_{k=0}^n \binom{n}{k} x^k y^{n-k} =
(x+y)^n$. Set $x = -1$ and $y = 2$ to obtain $(2-1)^n = 1^n = 1$.
$\qquad\blacksquare$

## 3. The canonical complex structure on $\mathbb{R}^4$

We write the squared Euclidean norm of $x = (x_1,x_2,x_3,x_4)$ as
$$\lVert x\rVert^2 = x_1^2 + x_2^2 + x_3^2 + x_4^2.$$

**Definition 3.1.** The *canonical complex structure* $J:\mathbb{R}^4 \to
\mathbb{R}^4$ is
$$J(x_1,x_2,x_3,x_4) = (-x_2,\ x_1,\ -x_4,\ x_3),$$
a simultaneous quarter-turn in the $(x_1,x_2)$- and $(x_3,x_4)$-planes.

**Theorem 3.2 (Complex structure).** $J^2 = -I$; that is, $J(J(x)) = -x$ for all
$x$.

*Proof.* Applying $J$ twice, $J(J(x_1,x_2,x_3,x_4)) = J(-x_2,x_1,-x_4,x_3) =
(-x_1,-x_2,-x_3,-x_4) = -x$. $\qquad\blacksquare$

**Theorem 3.3 (Isometry).** $\lVert J(x)\rVert^2 = \lVert x\rVert^2$ for all $x$.

*Proof.* $\lVert J(x)\rVert^2 = (-x_2)^2 + x_1^2 + (-x_4)^2 + x_3^2 = x_1^2 + x_2^2
+ x_3^2 + x_4^2 = \lVert x\rVert^2$. $\qquad\blacksquare$

**Theorem 3.4 (Fixed-point freeness).** *If $J(x) = x$ then $x = 0$. Consequently
$J$ acts without fixed points on the unit sphere $S^3 = \{\lVert x\rVert^2 = 1\}$.*

*Proof.* The equation $J(x)=x$ reads $(-x_2,x_1,-x_4,x_3) = (x_1,x_2,x_3,x_4)$,
i.e. $-x_2 = x_1$, $x_1 = x_2$, $-x_4 = x_3$, $x_3 = x_4$. From the first two,
$x_1 = x_2$ and $x_1 = -x_2$, so $x_1 = x_2 = 0$; likewise $x_3 = x_4 = 0$. Hence
$x = 0$. If additionally $\lVert x\rVert^2 = 1$ there is no solution, so $J$ has no
fixed point on $S^3$. $\qquad\blacksquare$

**Remark 3.5 (The odd-dimensional obstruction, concretely).** A linear isometry of
an even-dimensional space can act freely on the surrounding odd sphere precisely
when it lacks the eigenvalue $1$; the operator $J - I$ is then invertible. Theorem
3.4 exhibits this in the cleanest possible form: $Jx = x \Rightarrow x = 0$ is
exactly the statement that $J - I$ has trivial kernel. In odd-dimensional spaces no
such $J$ exists — a real operator on an odd-dimensional space always has a real
eigenvalue, and an isometry's only possible real eigenvalues are $\pm 1$, forcing a
fixed direction on the sphere whenever $+1$ occurs. The evenness of $4$ is what
permits the fixed-point-free quarter-turn.

## 4. The Hopf map

Identify $\mathbb{R}^4 \cong \mathbb{C}^2$ via $(z,w)$.

**Definition 4.1.** The *Hopf map* $H:\mathbb{C}^2 \to \mathbb{C}\times\mathbb{R}$
is
$$H(z,w) = \bigl(2z\overline{w},\ |z|^2 - |w|^2\bigr).$$

**Theorem 4.2 (Circle invariance).** *For every $\lambda \in \mathbb{C}$ with
$|\lambda|^2 = 1$,*
$$H(\lambda z,\lambda w) = H(z,w).$$
*Hence $H$ is constant on the diagonal circle orbits $(z,w)\mapsto(\lambda z,
\lambda w)$, and these orbits are exactly its fibers.*

*Proof.* In the first coordinate,
$$2(\lambda z)\overline{(\lambda w)} = 2\lambda\overline{\lambda}\, z\overline{w}
= 2|\lambda|^2 z\overline{w} = 2z\overline{w},$$
using $\lambda\overline{\lambda} = |\lambda|^2 = 1$. In the second coordinate,
$|\lambda z|^2 - |\lambda w|^2 = |\lambda|^2(|z|^2 - |w|^2) = |z|^2 - |w|^2$.
$\qquad\blacksquare$

Since multiplication by $\lambda = i$ realizes the quarter-turn $J$ of Section 3,
the Hopf circle action is generated by $J$; the fibers of $H$ are the orbits of the
fixed-point-free flow that $J$ integrates.

**Theorem 4.3 (Image sphere).** *For all $z,w$,*
$$\bigl|2z\overline{w}\bigr|^2 + \bigl(|z|^2 - |w|^2\bigr)^2 = \bigl(|z|^2 +
|w|^2\bigr)^2.$$
*In particular, on the unit sphere $|z|^2 + |w|^2 = 1$ the image lies on the unit
two-sphere in $\mathbb{C}\times\mathbb{R}$.*

*Proof.* Since $|2z\overline{w}|^2 = 4|z|^2|w|^2$, the claim with $a = |z|^2$,
$b = |w|^2$ is $4ab + (a-b)^2 = (a+b)^2$, which is Lemma 2.1. $\qquad\blacksquare$

Thus the target of the Hopf map is a two-sphere of radius $|z|^2 + |w|^2$, and the
sphere identity is *literally* the sum-of-squares core.

## 5. The Clifford torus

Consider the flat-torus family in $S^3$ given by
$$(\theta,\varphi)\mapsto (r_1\cos\theta,\ r_1\sin\theta,\ r_2\cos\varphi,\
r_2\sin\varphi),\qquad r_1^2 + r_2^2 = 1.$$
Its induced area is proportional to $r_1 r_2$, equivalently governed by the product
$4r_1^2 r_2^2$. Write $a = r_1^2$, $b = r_2^2$, so $a + b = 1$.

**Theorem 5.1 (Clifford balance).** *If $a + b = 1$ then $4ab = 1 - (a-b)^2$.*

*Proof.* By Lemma 2.1, $4ab = (a+b)^2 - (a-b)^2 = 1 - (a-b)^2$. $\qquad\blacksquare$

**Theorem 5.2 (Upper bound).** *If $a+b = 1$ then $4ab \le 1$.*

*Proof.* From Theorem 5.1, $4ab = 1 - (a-b)^2 \le 1$ since $(a-b)^2 \ge 0$.
$\qquad\blacksquare$

**Theorem 5.3 (Extremal balance, uniqueness).** *If $a + b = 1$ then $4ab = 1$ if
and only if $a = b$.*

*Proof.* By Theorem 5.1, $4ab = 1 \iff (a-b)^2 = 0 \iff a = b$. $\qquad\blacksquare$

Hence the product controlling the area is maximized exactly at $r_1^2 = r_2^2 =
\tfrac12$, the balanced Clifford torus $r_1 = r_2 = 1/\sqrt2$, and this maximizer is
unique. The balance condition $a = b$ is also precisely the condition of invariance
under the diagonal circle action of Section 4, tying the extremal torus to the Hopf
symmetry.

## 6. Volume of the four-ball and surface of the three-sphere

**Theorem 6.1 (Volume–surface derivative).** *Let $V(r) = \frac{\pi^2}{2}r^4$ be the
volume of the four-ball of radius $r$. Then $V'(r) = 2\pi^2 r^3$, which is the
three-dimensional surface measure of the bounding three-sphere of radius $r$.*

*Proof.* Differentiating, $V'(r) = \frac{\pi^2}{2}\cdot 4 r^3 = 2\pi^2 r^3$. The
surface measure of $S^3_r$ is the standard $2\pi^2 r^3$. $\qquad\blacksquare$

This is the four-dimensional instance of the general principle that the derivative
of the ball volume with respect to radius equals the boundary sphere's measure
(as with $\frac{d}{dr}\pi r^2 = 2\pi r$). The volume constant $\pi^2/2 = \pi^2/2!$
is the value dictated by the Gamma-function formula for ball volumes in even
dimension, and it is exactly the constant that makes the volume–surface pairing
consistent.

## 7. The hypercube and its boundary Euler characteristic

The $n$-cube $[0,1]^n$ has, for each $0 \le k \le n$, exactly $\binom{n}{k}2^{\,n-k}$
faces of dimension $k$ (choose the $k$ free coordinates, and fix each of the
remaining $n-k$ at one of two values).

**Theorem 7.1 (Total alternating face sum).** *The full $n$-cube satisfies*
$$\sum_{k=0}^{n}(-1)^k \binom{n}{k}2^{\,n-k} = 1.$$

*Proof.* This is Lemma 2.2. $\qquad\blacksquare$

The quantity above is the Euler characteristic of the (contractible) closed cube,
consistently equal to $1$. Deleting the single top-dimensional cell (the
$n$-dimensional interior, contributing $(-1)^n$) leaves the alternating face count
of the *boundary*.

**Theorem 7.2 (Boundary Euler characteristic).** *The boundary $\partial[0,1]^n$,
a topological $(n-1)$-sphere, has Euler characteristic*
$$\chi(\partial[0,1]^n) = 1 - (-1)^n.$$

*Proof.* Subtract the top cell's contribution $(-1)^n$ from the total $1$ of
Theorem 7.1. $\qquad\blacksquare$

For even $n$ this is $0$; for odd $n$ it is $2$ — matching the Euler characteristic
of $S^{n-1}$ ($0$ in even dimension, $2$ in odd dimension). A topological invariant
of the sphere is thereby computed from the binomial theorem alone.

## 8. Algorithms

We record three computational procedures that make the results concrete.

**Algorithm A (Hopf projection and fiber verification).** Given $(z,w)\in
\mathbb{C}^2$, compute $H(z,w) = (2z\overline w, |z|^2-|w|^2)$; verify Theorem 4.3
by checking $|2z\overline w|^2 + (|z|^2-|w|^2)^2 = (|z|^2+|w|^2)^2$; and verify
Theorem 4.2 by sampling unit-modulus $\lambda$ and confirming $H(\lambda z,\lambda
w) = H(z,w)$.

**Algorithm B (Clifford area optimization).** Sweep $t = r_1^2 \in (0,1)$, set
$r_2^2 = 1-t$, and tabulate $4t(1-t)$; the maximum $1$ occurs at $t = \tfrac12$,
confirming Theorem 5.3.

**Algorithm C (Alternating face sum).** For each $k$, count $\binom{n}{k}2^{\,n-k}$
$k$-faces of the $n$-cube; form the alternating sum to get $1$ (Theorem 7.1) and
subtract $(-1)^n$ to get the boundary Euler characteristic (Theorem 7.2).

## 9. Discussion

The unifying lesson is that the "exotic" four-dimensional objects treated here are
shadows of two schoolbook identities: the sum-of-squares identity $(\star)$ on the
continuous side and the binomial theorem on the discrete side. The fixed-point-free
rotation, the Hopf sphere identity, the Clifford balance, and the volume–surface
pairing are each a specialization of $(\star)$ (or, for the derivative, of the same
even-dimensional volume constant), while the cube's boundary invariant is a
specialization of $(2-1)^n = 1$.

This perspective is not merely aesthetic. It provides concrete base cases from which
higher-dimensional generalizations can be bootstrapped, and it isolates the exact
algebraic reason each phenomenon occurs — the vanishing of a squared deviation, the
cancellation $\lambda\overline\lambda = 1$, the invertibility of $J - I$.

## 10. Future work

Several natural conjectures extend these results.

1. **Canonical fixed-point-free isometries.** On $\mathbb{R}^{2n}$ the
coordinate-pairing quarter-turn is conjecturally the unique isometry (up to
orthogonal conjugacy) whose square is central and which acts freely on $S^{2n-1}$;
every fixed-point-free linear isometry of an odd sphere should be orthogonally
conjugate to a block sum of planar rotations.

2. **Balanced tori in every odd sphere.** On $S^{2m-1}$ with $\sum r_i^2 = 1$, the
symmetric point $r_i^2 = 1/m$ should be the unique critical point of the product
functional governing the flat-torus area, and the unique embedding invariant under
the diagonal circle action.

3. **Euler characteristic of simple polytopes.** The value $1-(-1)^n$ should govern
the boundary of *every* simple $n$-polytope, independent of combinatorial type, via
deformation to the cube's face lattice.

4. **Rigidity of the Hopf action.** The diagonal circle should be the maximal
connected subgroup of $SO(4)$ acting freely on $S^3$ with the Hopf fibers as
orbits, its centralizer being $U(2)$ with center that circle.

5. **A four-dimensional isoperimetric hierarchy.** The constant $\pi^2/2$ should
appear as the extremal ratio of a sharp four-dimensional isoperimetric inequality
in which the four-ball uniquely maximizes volume for fixed boundary measure.
