# Slicing Ellipsoids: a guided tour

*What happens when you cut a stretched ball through its centre? Everything you could want
to know turns out to be governed by two numbers: one determinant, and one vector length.*

---

## 1. Start with a ball, and push

Take the unit ball $B^n = \{x \in \mathbb{R}^n : \|x\| \le 1\}$ and squash it with a linear
map $A$. What comes out is an **ellipsoid**:

$$E(A) \;=\; A\,B^n \;=\; \{\, Ax \;:\; \|x\| \le 1 \,\}.$$

This "image of a ball" definition is deceptively powerful. A linear map multiplies volumes
by the absolute value of its determinant, so before we do anything clever we already know

$$\operatorname{vol}\bigl(E(A)\bigr) \;=\; |\det A| \cdot \omega_n, \qquad
\omega_n := \operatorname{vol}(B^n) = \frac{\pi^{n/2}}{\Gamma(\tfrac n2 + 1)} .$$

One number decides the size. In particular, an ellipsoid with $\det A = 1$ has *exactly* the
volume of the unit ball, no matter how extravagantly elongated it is.

<details>
<summary>The static description, and why the generator is not unique</summary>

For invertible $A$ one can also write the ellipsoid as a sublevel set of a quadratic form,
$$E(A) = \bigl\{x : \langle (AA^{\mathsf T})^{-1}x,\, x\rangle \le 1\bigr\},$$
which shows that $E(A)$ depends on $A$ only through the symmetric matrix $AA^{\mathsf T}$.
Consequently $E(AU) = E(A)$ for every orthogonal $U$ — rotating the ball before you squash
it changes nothing. Whenever we want to reason spectrally we simply choose the *positive
definite* generator $\sqrt{AA^{\mathsf T}}$, whose eigenvalues $\lambda_1,\dots,\lambda_n$
are the semiaxes and whose eigenvectors are the axis directions. The
[spectral theorem](https://en.wikipedia.org/wiki/Spectral_theorem) then says every ellipsoid
is a rotated diagonal one:
$$E(A) = U\cdot E\bigl(\operatorname{diag}(\lambda_1,\dots,\lambda_n)\bigr).$$
Two immediate corollaries: $\operatorname{vol}(E(A)) = (\lambda_1\cdots\lambda_n)\,\omega_n$,
and the ellipsoid is trapped between two round balls,
$B(0,\lambda_{\min}) \subseteq E(A) \subseteq B(0,\lambda_{\max})$.
</details>

---

## 2. The formula everything rests on

Now take a knife. Fix a unit vector $u$ and cut along the hyperplane $u^\perp$ through the
origin. What is the $(n-1)$-dimensional volume of the exposed face?

$$\boxed{\ \operatorname{vol}_{n-1}\bigl(E(A)\cap u^{\perp}\bigr)
= \frac{|\det A|}{\|A^{\mathsf T} u\|}\;\omega_{n-1}. \ }$$

Everything about the body is in $|\det A|$; everything about the direction of the cut is in
the single number $\|A^{\mathsf T}u\|$.

The interactive laboratory below lets you see this in the plane, where "slice volume" is
just chord length. Drag the semiaxes, tilt the ellipse, rotate the cutting direction: the
predicted value $2|\det A|/\|A^{\mathsf T}u\|$ is compared against the chord actually
measured on the picture by bisection, and the two never disagree beyond rounding.

{{interactive_demo:0}}

<details>
<summary>Click to reveal the proof in three steps</summary>

**Step 1 — the slice is a preimage.** Choose an orthonormal frame $\iota$ of the hyperplane:
an $n\times(n-1)$ matrix whose columns are an orthonormal basis of $u^\perp$, characterised
by $\iota^{\mathsf T}\iota = I$ and $\iota\iota^{\mathsf T} = I - uu^{\mathsf T}$. Read in
those coordinates, the slice is $\{y : \|A^{-1}\iota\,y\| \le 1\}$: the preimage of the unit
ball under a *rectangular* map $T = A^{-1}\iota$.

**Step 2 — the Gram determinant.** A rectangular map has no determinant, but the right
substitute is the Gram matrix. If $T^{\mathsf T}T$ is positive definite then
$$\operatorname{vol}_m\{\,y : \|Ty\| \le 1\,\} = \frac{\omega_m}{\sqrt{\det(T^{\mathsf T}T)}} .$$
(Write $T^{\mathsf T}T = R^{\mathsf T}R$ with $R = \sqrt{T^{\mathsf T}T}$; the set is
$R^{-1}(B^m)$, so its volume is $|\det R^{-1}|\omega_m$.)

**Step 3 — evaluate it.** For a hyperplane frame the Gram determinant collapses to a single
vector norm:
$$\det\bigl((A^{-1}\iota)^{\mathsf T}(A^{-1}\iota)\bigr) = \frac{\|A^{\mathsf T}u\|^{2}}{(\det A)^{2}} .$$
The trick is to append one extra column, $p = A^{\mathsf T}u/\|A^{\mathsf T}u\|^2$, so the
matrix becomes square. The new column is orthogonal to the others (because
$\iota^{\mathsf T}u = 0$), so the enlarged Gram matrix is block diagonal and its determinant
factorises; on the other hand the enlarged square matrix has determinant $\pm1/\det A$.
Comparing the two evaluations gives the identity, and substituting it into Step 2 finishes
the proof.

Two loose ends are worth naming. The answer must not depend on which frame you picked —
and it does not, since the final formula does not mention $\iota$. And a frame always
exists: extend $u$ to an orthonormal basis and keep the other $n-1$ vectors. That is what
turns a conditional statement into an unconditional one.
</details>

Here is the algorithm in the cheapest possible form. One $O(n^3)$ determinant, then $O(n^2)$
per direction:

{{algorithm:0}}

And here is the general machinery, valid for a slice by a subspace of *any* dimension
$m \le n$ — the same Gram determinant, not simplified:

{{algorithm:1}}

For $m = n-1$ the two must agree, which is a sharp numerical test of Step 3 above.

---

## 3. Reading the formula: extremes are eigendirections

Suppose the generator is positive definite with eigenvalues $\lambda_1,\dots,\lambda_n$.
Writing a unit vector $u$ in the eigenbasis with coordinates $c$, we get
$$\|Au\|^2 = \sum_i \lambda_i^2 c_i^2, \qquad \sum_i c_i^2 = 1,$$
a weighted average of the squared eigenvalues. Hence
$\lambda_{\min} \le \|Au\| \le \lambda_{\max}$, and the section formula turns into a
two-sided bound:

$$\frac{\det A}{\lambda_{\max}}\,\omega_{n-1} \;\le\;
\operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr) \;\le\;
\frac{\det A}{\lambda_{\min}}\,\omega_{n-1}.$$

Slicing perpendicular to the **shortest** axis gives the **biggest** face; slicing
perpendicular to the longest axis gives the smallest. Cut a cigar lengthwise and you expose
a lot; cut it across and you expose a little.

The heat map below shows the whole section profile of a three-dimensional ellipsoid: the
area of the central slice as a function of direction, drawn over the sphere of directions in
spherical coordinates. The profile never leaves the eigenvalue band, and touches the ends of
the band exactly at the marked eigendirections.

{{visualization:1}}

<details>
<summary>The rigidity statement: the bounds are attained <em>only</em> at eigenvectors</summary>

Suppose $\|Au\| = \lambda_{\max}$ for a unit vector $u$. Then
$\sum_i (\lambda_{\max}^2 - \lambda_i^2)c_i^2 = 0$ is a sum of nonnegative terms, so every
term vanishes: $c_i = 0$ for every $i$ with $\lambda_i < \lambda_{\max}$. In other words
$u$ lies in the top eigenspace, i.e. $Au = \lambda_{\max}u$. The same argument at the other
end gives the minimal case. Consequently:

> the maximal-volume central sections of an ellipsoid are **exactly** those orthogonal to a
> minimal eigenvector, and the minimal-volume ones **exactly** those orthogonal to a maximal
> eigenvector.

So the section-volume function on the sphere *recovers* $\lambda_{\min}$, $\lambda_{\max}$
and the corresponding eigenspaces. Slicing data and spectral data are the same data.
</details>

Because the extremes are eigendirections, finding them requires no optimisation over the
sphere at all — one symmetric eigendecomposition is the whole algorithm:

{{algorithm:2}}

<details>
<summary>A conservation law hiding in the principal sections</summary>

Take the $n$ sections orthogonal to the axes. Their normalised volumes are
$\det A/\lambda_1, \dots, \det A/\lambda_n$, and their product is
$$\prod_{i=1}^{n} \frac{\det A}{\lambda_i} = \frac{(\det A)^n}{\lambda_1\cdots\lambda_n}
= (\det A)^{\,n-1}.$$
The individual slices can be anything, but their product is pinned by the volume. You cannot
make all the principal slices small. Specialising to $\det A = 1$: some eigenvalue is $\le1$
and some is $\ge1$, so a volume-normalised ellipsoid always has a slice at least as large as
the ball's and another at most as large. It can never be uniformly thinner or uniformly
fatter than a ball.
</details>

---

## 4. Duality: the ellipsoid you cannot see

Every symmetric convex body $K$ has a **polar**
$$K^{\circ} = \{\, y : \langle y,x\rangle \le 1 \text{ for all } x \in K \,\},$$
which encodes $K$ by its supporting hyperplanes instead of its points. Polarity reverses
inclusions, turns unions into intersections, and fixes the unit ball. For ellipsoids it is
completely explicit:
$$E(A)^{\circ} = E\bigl((A^{\mathsf T})^{-1}\bigr).$$
Squashing is dual to stretching. More is true: polarity is *covariant*, $(A\cdot S)^\circ =
(A^{\mathsf T})^{-1}\cdot S^\circ$ for **any** set $S$, so in the product
$\operatorname{vol}(S)\operatorname{vol}(S^\circ)$ the factor $|\det A|$ cancels against
$|\det A|^{-1}$. The volume product is a linear invariant, and evaluating it on the
self-polar ball gives the **Blaschke–Santaló equality**:

$$\operatorname{vol}\bigl(E(A)\bigr)\cdot \operatorname{vol}\bigl(E(A)^{\circ}\bigr)
= \omega_n^{2}\qquad\text{for every ellipsoid.}$$

The famous [Blaschke–Santaló inequality](https://en.wikipedia.org/wiki/Blaschke%E2%80%93Santal%C3%B3_inequality)
says this product is *at most* $\omega_n^2$ for every symmetric convex body, with equality
precisely for ellipsoids — and the equality half is exactly what we just proved, in three
lines, from covariance.

The static figure below draws all three bodies at once: an ellipse, its polar dual, and (the
subject of the next section) its slice profile.

{{visualization:0}}

<details>
<summary>A bonus for bodies that are not ellipsoids</summary>

If a body $S$ is squeezed between two ellipsoids, $E(A) \subseteq S \subseteq E(B)$, then
monotonicity of volume and antitonicity of polarity give at once
$$\operatorname{vol}(S)\operatorname{vol}(S^\circ) \le
\frac{|\det B|}{|\det A|}\,\omega_n^2 .$$
Approximating a body by ellipsoids from inside and outside therefore bounds its volume
product, with the quality of the bound equal to the ratio of the two determinants. Such a
sandwich always exists, because every closed bounded body with nonempty interior contains a
maximal-volume ellipsoid — the [John ellipsoid](https://en.wikipedia.org/wiki/John_ellipsoid).
Existence is pure compactness: maximising volume is maximising $\det A$ over the set of
positive semidefinite $A$ with $E(A) \subseteq K$, a set that is closed (which is why the
degenerate, flat generators must be allowed) and bounded, hence compact.
</details>

---

## 5. Drawing the slice profile as a body

Here is the most striking turn of the story. Given a body $K$, define a new body $IK$ — its
**intersection body** — by placing, in each direction $u$, a point at distance equal to the
normalised slice size $\operatorname{vol}_{n-1}(K\cap u^\perp)/\omega_{n-1}$. In other words,
*draw the slice profile as a shape*. This is the central construction of the dual
Brunn–Minkowski theory and the key to the
[Busemann–Petty problem](https://en.wikipedia.org/wiki/Busemann%E2%80%93Petty_problem),
where the innocent question "do uniformly smaller slices force smaller volume?" turns out to
have answer *yes* up to dimension 4 and *no* from dimension 5 on.

For an ellipsoid the profile function is $|\det A|/\|A^{\mathsf T}u\|$, and that is again the
radial function of an ellipsoid. With $S = \sqrt{AA^{\mathsf T}}$,

$$I\bigl(E(A)\bigr) = E\bigl(|\det A|\,S^{-1}\bigr),
\qquad \det\bigl(|\det A|S^{-1}\bigr) = |\det A|^{\,n-1}.$$

**The intersection body of an ellipsoid is an ellipsoid.** When the generator is already
positive definite the recipe is simply $A \mapsto (\det A)\,A^{-1}$; on unimodular
generators it is the involution $A \mapsto A^{-1}$, whose only fixed point is the identity.
Geometrically: *among all ellipsoids of the volume of the ball, the ball is the unique one
that is its own slice profile.*

Play with it. Slide the eccentricity and watch the ellipse and its profile trade axes; slide
it back to $1$ and watch them merge into the disc.

{{interactive_demo:1}}

{{algorithm:3}}

---

## 6. Checking everything numerically

Talk is cheap; here is the whole theory run through a calculator. The script below verifies,
to machine precision, the volume formula, the section formula (against both an independent
Gram-determinant evaluation and a Monte-Carlo estimate), frame independence, the spectral
bounds and their attainment, the determinant conservation law, the codimension-free
sandwich, the coordinate-section product formula, the Blaschke–Santaló equality, and every
claim about the intersection body including the involution and the uniqueness of the ball.

{{demo:0}}

And here is the statistical view: for a random direction, the normalised slice of a
unimodular ellipsoid is $1/\|Au\|$, a quantity whose distribution over the sphere is
explicitly computable. The histogram shows how it concentrates — the ellipsoidal shadow of
the thin-shell phenomenon.

{{demo:1}}

---

## 7. What to take away

Three mechanisms produced every result above.

1. **Determinant homogeneity.** Volume scales by $|\det|$ under a linear map. That alone
   gives the volume formula and, through a cancellation, the invariance of the volume
   product and the Blaschke–Santaló equality.
2. **The Gram determinant.** For rectangular maps, $|\det T|$ becomes
   $\sqrt{\det T^{\mathsf T}T}$. Every section formula is an evaluation of this one quantity;
   the hyperplane case collapses to a single vector norm.
3. **The spectral theorem.** Positive definite generators are diagonal in an orthonormal
   basis, so norms become weighted averages of eigenvalues. Inequalities come from bounding
   the average; rigidity comes from the equality case of a sum of nonnegative terms.

Ellipsoids are the one family of convex bodies where all of this can be written down
exactly, and that is precisely why they serve as the yardstick of high-dimensional convex
geometry: the results above are not asymptotics or estimates, but identities, valid in every
dimension, with their equality cases characterised exactly.

Cut wherever you like. The size of the exposed face is $|\det A|$ divided by
$\|A^{\mathsf T}u\|$.
