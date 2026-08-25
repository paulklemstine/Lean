# Ellipsoids as Positive-Definite Images of Balls: Exact Central-Section Formulas, Spectral Slicing Bounds, and Duality

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop a complete and self-contained theory of ellipsoids in $\mathbb{R}^n$ defined as linear images of the closed Euclidean unit ball, $E(A) = A B^n$, and derive exact formulas for the volumes of their central sections in terms of the determinant and the spectrum of the generating matrix. The central result is the **hyperplane section formula**
$$\operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr) = \frac{|\det A|}{\|A^{\mathsf T}u\|}\,\omega_{n-1},\qquad \|u\|=1,$$
where $\omega_m$ denotes the volume of the unit $m$-ball. From it we obtain: two-sided **spectral slicing bounds** $\det A/\lambda_{\max} \le \operatorname{vol}_{n-1}(E(A)\cap u^\perp)/\omega_{n-1} \le \det A/\lambda_{\min}$ for positive definite generators, together with the exact **equality case** — extremal sections occur precisely orthogonal to extremal eigenvectors; the **determinant normalization identity** $\prod_{i}(\det A/\lambda_i) = (\det A)^{n-1}$; a **codimension-free** Gram-determinant formula valid for sections by subspaces of arbitrary dimension $m \le n$, with the resulting sandwich $\lambda_{\min}^{m}\omega_m \le \operatorname{vol}_m(\text{section}) \le \lambda_{\max}^{m}\omega_m$; the **polar duality** law $E(A)^\circ = E((A^{\mathsf T})^{-1})$ with the resulting **Blaschke–Santaló equality** $\operatorname{vol}(E(A))\operatorname{vol}(E(A)^\circ) = \omega_n^2$ and a Santaló-type estimate for bodies squeezed between ellipsoids; the theorem that **the intersection body of an ellipsoid is an ellipsoid**, explicitly $I(E(A)) = E(|\det A|\,S^{-1})$ with $S = \sqrt{AA^{\mathsf T}}$, whose restriction to unimodular positive definite generators is the involution $A \mapsto A^{-1}$ with the identity matrix as unique fixed point — so the ball is the unique unimodular ellipsoid equal to its own intersection body; and the **existence of a maximal-volume inscribed ellipsoid** (John ellipsoid) in any closed bounded body containing a nondegenerate ellipsoid. Every statement is proved from the linear-image definition by elementary spectral and Gram-determinant arguments, requiring no integral-geometric input.

**Keywords:** ellipsoid, central section, Gram determinant, spectral decomposition, polar duality, Blaschke–Santaló, intersection body, John ellipsoid, convex geometry.

---

## 1. Introduction

### 1.1 Motivation

The central-section behaviour of a convex body is one of the recurring themes of high-dimensional geometry. Questions of the form "what do the $(n-1)$-dimensional slices through the origin tell us about the body?" underlie the Busemann–Petty problem, the slicing (hyperplane) conjecture, the dual Brunn–Minkowski theory, and much of the geometry of Banach spaces. In almost all of these settings the answers are hard, partial, or dimension-dependent.

Ellipsoids are the exception. Because an ellipsoid is by definition a linear image of a ball, and because linear maps act on volume through a single scalar — the determinant — all of the slicing data of an ellipsoid can be computed in closed form. This makes ellipsoids the calibration standard of the subject: they are the extremisers in the Blaschke–Santaló inequality, they are the bodies for which the Busemann–Petty problem is trivially affirmative, and via John's theorem they are the universal approximating family for arbitrary convex bodies.

The present work carries out that computation systematically, from a single definition, and pushes it as far as it will go: to sections of arbitrary codimension, to the equality cases of the resulting inequalities, to the polar dual, to the intersection body, and to the existence of extremal inscribed ellipsoids.

### 1.2 The point of view

The organising decision is to define an ellipsoid *dynamically*, as an image
$$E(A) = A B^n = \{Ax : \|x\| \le 1\},$$
rather than *statically*, as a sublevel set $\{x : \langle Qx,x\rangle \le 1\}$ of a positive definite quadratic form. The two descriptions are equivalent (Proposition 2.4), and the static one is often more convenient for checking membership; but the dynamic one is what makes every volume computation a determinant computation and every section computation a Gram-determinant computation. The price is that the generator $A$ is not unique — $A$ and $AU$ generate the same ellipsoid for orthogonal $U$ — and a recurring technical theme is to exploit this redundancy rather than fight it: one normalises $A$ to be positive definite exactly when it helps, and keeps it general otherwise.

### 1.3 Summary of results

- **§2** Definition, quadratic-form description, convexity, symmetry, compactness, the volume formula $\operatorname{vol}(E(A)) = |\det A|\,\omega_n$, orthogonal invariance, and the spectral normal form.
- **§3** The Gram-determinant volume formula for preimages of the ball under rectangular maps, the central-section Gram identity, and the hyperplane section formula.
- **§4** Spectral slicing bounds, their attainment, the exact equality case, frame independence, existence of slicing frames, and the determinant-normalization identity.
- **§5** Sections of arbitrary codimension: the codimension-free Gram formula, determinant bounds from quadratic-form bounds, the $m$-dimensional sandwich, and coordinate sections of diagonal ellipsoids.
- **§6** Polar duality: the calculus of polars, linear covariance, the bipolar theorem for ellipsoids, the Blaschke–Santaló equality, and a Santaló-type estimate for ellipsoidally approximable bodies.
- **§7** Intersection bodies: the intersection body of an ellipsoid is an ellipsoid; its determinant and volume; the involution structure and the uniqueness of the ball as a fixed point.
- **§8** Existence of the maximal-volume inscribed (John) ellipsoid via compactness of the set of inscribed generators.
- **§9** Algorithms and numerical illustration.
- **§10** Discussion and future directions.

### 1.4 Notation

Throughout, $n, m$ are nonnegative integers; $\mathbb{R}^n$ carries the standard inner product $\langle x,y\rangle = x \cdot y$ and Euclidean norm $\|x\| = \sqrt{x\cdot x}$; $B^n = \{x : \|x\| \le 1\}$ is the closed unit ball and $B(0,r)$ the closed ball of radius $r$; $\omega_n = \operatorname{vol}_n(B^n)$; $\operatorname{vol}_m$ is $m$-dimensional Lebesgue measure on an $m$-dimensional space; $A^{\mathsf T}$ is the transpose; $\operatorname{diag}(d)$ the diagonal matrix with entries $d_i$; $I$ the identity. A matrix $A$ is *positive definite*, written $A \succ 0$, if it is symmetric with $\langle Ax,x\rangle > 0$ for all $x \neq 0$; *positive semidefinite*, $A \succeq 0$, if $\langle Ax,x\rangle \ge 0$. For $A \succeq 0$ we write $\sqrt{A}$ for the unique positive semidefinite square root. For a unit vector $u$, $u^\perp = \{x : \langle x,u\rangle = 0\}$.

---

## 2. Ellipsoids, volume and spectral normal form

### 2.1 Definition and basic structure

> **Definition 2.1 (Ellipsoid).** For an $n \times n$ real matrix $A$, the *ellipsoid generated by $A$* is the image of the closed Euclidean unit ball under the linear map $x \mapsto Ax$:
> $$E(A) := A\,B^n = \{\, Ax : \|x\| \le 1 \,\}.$$

We call $A$ a *generator*. When $A$ is singular, $E(A)$ is a degenerate (lower-dimensional) ellipsoid; such generators are deliberately admitted, and in §8 their presence is what makes a certain constraint set closed.

> **Proposition 2.2 (Membership).** If $\det A \neq 0$, then $x \in E(A) \iff \|A^{-1}x\| \le 1$.

*Proof.* If $x = Ay$ with $\|y\|\le 1$ then $A^{-1}x = y$. Conversely, if $\|A^{-1}x\|\le 1$ then $x = A(A^{-1}x)$ exhibits $x$ as an image of a ball point. $\square$

> **Proposition 2.3 (Elementary properties).** For every $A$: $E(A)$ is convex, compact, and centrally symmetric, i.e. $-E(A) = E(A)$.

*Proof.* Convexity and compactness are preserved by continuous linear images of the convex compact ball. Symmetry: $-E(A) = A(-B^n) = A B^n$, since $-B^n = B^n$ and negation commutes with the linear map. $\square$

> **Proposition 2.4 (Quadratic-form description).** If $\det A \neq 0$, then
> $$E(A) = \bigl\{ x \in \mathbb{R}^n : \langle (AA^{\mathsf T})^{-1}x,\, x\rangle \le 1 \bigr\}.$$

*Proof.* By Proposition 2.2, $x \in E(A)$ iff $\|A^{-1}x\|^2 \le 1$. Now $\|A^{-1}x\|^2 = \langle (A^{-1})^{\mathsf T}A^{-1}x, x\rangle$, and $(A^{-1})^{\mathsf T}A^{-1} = (A^{\mathsf T})^{-1}A^{-1} = (AA^{\mathsf T})^{-1}$. $\square$

Proposition 2.4 shows that the ellipsoid depends on $A$ only through the positive definite Gram matrix $AA^{\mathsf T}$, which is the precise statement of generator non-uniqueness. Note the general identity, used repeatedly below:
$$\|Ay\|^2 = \langle (A^{\mathsf T}A)\,y,\, y\rangle, \tag{2.1}$$
valid for rectangular $A$ as well; the squared norm of an image is the quadratic form of the Gram matrix.

### 2.2 Volume

> **Theorem 2.5 (Volume of an ellipsoid).** For every $n \times n$ matrix $A$,
> $$\operatorname{vol}\bigl(E(A)\bigr) = |\det A|\;\omega_n .$$

*Proof.* Lebesgue measure is a Haar measure on $\mathbb{R}^n$ and a linear map $L$ scales it by $|\det L|$: $\operatorname{vol}(L(S)) = |\det L|\operatorname{vol}(S)$ for measurable $S$. Apply this with $L$ the map $x\mapsto Ax$ and $S = B^n$. $\square$

> **Corollary 2.6 (Determinant normalization).** If $\det A = 1$ then $\operatorname{vol}(E(A)) = \omega_n$: a unimodular generator produces an ellipsoid of exactly the volume of the unit ball.

Corollary 2.6 is the normalisation used throughout §4 and §7: it isolates *shape* from *size*, so that any remaining variation is genuinely about eccentricity and orientation rather than scale.

### 2.3 Orthogonal invariance and the spectral form

> **Lemma 2.7.** If $U^{\mathsf T}U = I$ then $\|Uy\| = \|y\|$ for all $y$; if in addition $UU^{\mathsf T} = I$ then $U(B(0,r)) = B(0,r)$ for every $r \ge 0$.

*Proof.* By (2.1), $\|Uy\|^2 = \langle U^{\mathsf T}Uy,y\rangle = \|y\|^2$. For the second claim, $U(B(0,r)) \subseteq B(0,r)$ by isometry, and conversely $x = U(U^{\mathsf T}x)$ with $\|U^{\mathsf T}x\| = \|x\|$ (using $UU^{\mathsf T}=I$ and the first claim applied to $U^{\mathsf T}$). $\square$

> **Theorem 2.8 (Right orthogonal invariance).** If $U$ is orthogonal then $E(AU) = E(A)$.

*Proof.* $E(AU) = (AU)(B^n) = A\bigl(U(B^n)\bigr) = A B^n$ by Lemma 2.7. $\square$

> **Theorem 2.9 (Composition).** For all $A,B$: $E(AB) = A\bigl(E(B)\bigr)$.

*Proof.* Immediate from associativity of the image: $(AB)(B^n) = A(B(B^n))$. $\square$

> **Theorem 2.10 (Spectral normal form).** Let $A \succ 0$ with eigenvalues $\lambda_1,\dots,\lambda_n > 0$ and orthonormal eigenvector matrix $U$ (so $A = U\operatorname{diag}(\lambda)U^{\mathsf T}$). Then
> $$E(A) = U\bigl(E(\operatorname{diag}(\lambda))\bigr).$$
> Every ellipsoid is therefore an orthogonal image of a diagonal ellipsoid with semiaxes the eigenvalues of its positive definite generator.

*Proof.* By the spectral theorem $A = U \operatorname{diag}(\lambda) U^{\mathsf T}$. By Theorem 2.9, $E(A) = E\bigl((U\operatorname{diag}(\lambda))U^{\mathsf T}\bigr)$, which by Theorem 2.8 (with the orthogonal matrix $U^{\mathsf T}$) equals $E(U\operatorname{diag}(\lambda)) = U(E(\operatorname{diag}(\lambda)))$, again by Theorem 2.9. $\square$

> **Theorem 2.11 (Eigenvalue sandwich).** Let $A \succ 0$ with $\lambda_{\min} = \min_i\lambda_i$, $\lambda_{\max} = \max_i\lambda_i$. Then
> $$B(0,\lambda_{\min}) \subseteq E(A) \subseteq B(0,\lambda_{\max}).$$
> More generally, if $\lambda_i \in [\ell, h]$ for all $i$ with $\ell \ge 0$, then $B(0,\ell)\subseteq E(A)\subseteq B(0,h)$.

*Proof.* By (2.1) and the spectral theorem, $\|Ay\|^2 = \sum_i \lambda_i^2 c_i^2$ where $c$ are the coordinates of $y$ in the eigenbasis, so $\ell\|y\| \le \|Ay\| \le h\|y\|$. The upper inclusion follows since $x = Ay$ with $\|y\|\le 1$ gives $\|x\|\le h$. For the lower inclusion, given $\|x\|\le \ell$ set $y = A^{-1}x$; then $\ell\|y\| \le \|Ay\| = \|x\| \le \ell$, so $\|y\|\le 1$ (using $\ell>0$; the case $\ell=0$ is vacuous) and $x \in E(A)$. $\square$

Since $\det A = \prod_i \lambda_i$ for $A \succ 0$, Theorem 2.5 also reads $\operatorname{vol}(E(A)) = (\lambda_1\cdots\lambda_n)\,\omega_n$: volume is the product of semiaxes.

---

## 3. The central-section formula

### 3.1 Sections as preimages

> **Definition 3.1 (Central section in a frame).** Let $\iota$ be an $n \times m$ matrix with orthonormal columns, $\iota^{\mathsf T}\iota = I_m$; its column span $V = \operatorname{ran}\iota$ is an $m$-dimensional subspace and $\iota : \mathbb{R}^m \to V$ is an isometry. The *central section of $E(A)$ in the frame $\iota$* is
> $$\Sigma(A,\iota) := \{\, y \in \mathbb{R}^m : \iota y \in E(A) \,\},$$
> the pullback to $\mathbb{R}^m$ of $E(A)\cap V$. Since $\iota$ is an isometry onto $V$, $\operatorname{vol}_m(\Sigma(A,\iota)) = \operatorname{vol}_m(E(A)\cap V)$.

Working with the pullback rather than with the subset of $V$ is what keeps every computation matricial.

> **Lemma 3.2.** If $\det A \neq 0$ then $\Sigma(A,\iota) = \{\, y : \|A^{-1}\iota\,y\| \le 1 \,\}$.

*Proof.* Immediate from Proposition 2.2. $\square$

So a central section is a *preimage of the unit ball under a rectangular linear map*, and we need the volume of such a preimage.

### 3.2 The Gram-determinant volume formula

> **Lemma 3.3 (Injectivity criterion).** If the $n \times m$ matrix $T$ has trivial kernel, then $T^{\mathsf T}T \succ 0$.

*Proof.* $T^{\mathsf T}T$ is symmetric, and $\langle T^{\mathsf T}T y, y\rangle = \|Ty\|^2 \ge 0$ by (2.1), with equality iff $Ty=0$ iff $y=0$. $\square$

> **Theorem 3.4 (Gram-determinant volume formula).** Let $T$ be an $n\times m$ matrix with $T^{\mathsf T}T \succ 0$. Then
> $$\operatorname{vol}_m\{\, y \in \mathbb{R}^m : \|Ty\| \le 1 \,\} = \frac{\omega_m}{\sqrt{\det(T^{\mathsf T}T)}}.$$

*Proof.* By (2.1), the set is $\{y : \langle Gy,y\rangle \le 1\}$ with $G = T^{\mathsf T}T \succ 0$. Write $G = R^{\mathsf T}R$ with $R = \sqrt G \succ 0$; then the set is $\{y : \|Ry\|\le 1\} = R^{-1}(B^m)$, whose volume by Theorem 2.5 is $|\det R^{-1}|\omega_m = \omega_m/\det\sqrt{G} = \omega_m/\sqrt{\det G}$. $\square$

Combining Lemma 3.2 and Theorem 3.4 already gives a completely general section formula, in every codimension:

> **Theorem 3.5 (Codimension-free section formula).** Let $\det A \ne 0$ and let $\iota$ be an $n\times m$ frame with $\iota^{\mathsf T}\iota = I_m$. Then $(A^{-1}\iota)^{\mathsf T}(A^{-1}\iota) \succ 0$ and
> $$\operatorname{vol}_m\bigl(E(A)\cap \operatorname{ran}\iota\bigr) = \frac{\omega_m}{\sqrt{\det\bigl((A^{-1}\iota)^{\mathsf T}(A^{-1}\iota)\bigr)}}.$$

*Proof.* If $(A^{-1}\iota)y = 0$ then $\iota y = 0$ (apply $A$), hence $y = \iota^{\mathsf T}\iota y = 0$; so $A^{-1}\iota$ is injective and Lemma 3.3 applies. Now use Lemma 3.2 and Theorem 3.4. $\square$

Everything that follows is the evaluation of the Gram determinant $\det((A^{-1}\iota)^{\mathsf T}(A^{-1}\iota))$ in cases of interest.

### 3.3 The hyperplane Gram identity

> **Theorem 3.6 (Central-section Gram identity).** Let $n = m+1$, let $\det A \neq 0$, let $u$ be a unit vector and let $\iota$ be an $n\times m$ matrix with
> $$\iota^{\mathsf T}\iota = I_m, \qquad \iota\,\iota^{\mathsf T} = I_n - uu^{\mathsf T}$$
> (that is, $\iota$ is an orthonormal frame of the hyperplane $u^\perp$: the second condition says its columns span exactly $u^\perp$). Then
> $$\det\bigl((A^{-1}\iota)^{\mathsf T}(A^{-1}\iota)\bigr) = \frac{\|A^{\mathsf T}u\|^{2}}{(\det A)^{2}}.$$

*Proof sketch.* Set $T = A^{-1}\iota$, an $n \times m$ matrix, and $p = (A^{\mathsf T}u)/\|A^{\mathsf T}u\|^2$, a vector in $\mathbb{R}^n$. (Note $A^{\mathsf T}u \neq 0$ since $A$ is invertible and $u \neq 0$.) Form the *augmented* square $n\times n$ matrix $N = [\,T \mid p\,]$ obtained by appending $p$ as a final column.

Two computations drive the proof.

1. *The augmented Gram matrix is block diagonal.* Its $(m,m)$ block is $T^{\mathsf T}T$; the off-diagonal block is $T^{\mathsf T}p = \iota^{\mathsf T}(A^{-1})^{\mathsf T}A^{\mathsf T}u/\|A^{\mathsf T}u\|^2 = \iota^{\mathsf T}u/\|A^{\mathsf T}u\|^2 = 0$, because the columns of $\iota$ lie in $u^\perp$: indeed $\iota\,\iota^{\mathsf T}u = (I-uu^{\mathsf T})u = 0$, and multiplying on the left by $\iota^{\mathsf T}$ and using $\iota^{\mathsf T}\iota = I_m$ gives $\iota^{\mathsf T}u = 0$. The final diagonal entry is $\|p\|^2 = 1/\|A^{\mathsf T}u\|^2$. Hence
   $$\det(N^{\mathsf T}N) = \det(T^{\mathsf T}T)\cdot \frac{1}{\|A^{\mathsf T}u\|^{2}}.$$
2. *The augmented matrix has a computable determinant.* We have $AN = [\,\iota \mid Ap\,]$ and $Ap = A A^{\mathsf T}u/\|A^{\mathsf T}u\|^2$. The square matrix $[\,\iota\mid w\,]$ with $w = AA^{\mathsf T}u/\|A^{\mathsf T}u\|^2$ has determinant equal to $\langle w,u\rangle = \|A^{\mathsf T}u\|^2/\|A^{\mathsf T}u\|^2 = 1$ up to the sign fixed by the orientation of $\iota$: expanding along the last column and using that $[\,\iota \mid u\,]$ is orthogonal (its Gram matrix is $I$ by the two frame conditions), one gets $\det[\,\iota\mid w\,] = \pm\langle u, w\rangle = \pm 1$. Hence $|\det(AN)| = 1$, so $|\det N| = 1/|\det A|$ and $\det(N^{\mathsf T}N) = (\det N)^2 = 1/(\det A)^2$.

Comparing the two evaluations of $\det(N^{\mathsf T}N)$ gives $\det(T^{\mathsf T}T) = \|A^{\mathsf T}u\|^2/(\det A)^2$. $\square$

> **Theorem 3.7 (Central section formula).** Let $\det A \ne 0$, let $u$ be a unit vector in $\mathbb{R}^n$, and let $\iota$ be an orthonormal frame of $u^\perp$ as in Theorem 3.6. Then
> $$\operatorname{vol}_{n-1}\bigl(E(A)\cap u^{\perp}\bigr) = \frac{|\det A|}{\|A^{\mathsf T}u\|}\;\omega_{n-1}.$$

*Proof.* Substitute Theorem 3.6 into Theorem 3.5 with $m = n-1$: the volume is $\omega_{n-1}\bigl(\|A^{\mathsf T}u\|^2/(\det A)^2\bigr)^{-1/2} = \omega_{n-1}|\det A|/\|A^{\mathsf T}u\|$. $\square$

### 3.4 Frames exist, and the answer does not depend on them

Theorem 3.7 is stated relative to a frame $\iota$. Two complementary facts make it unconditional.

> **Theorem 3.8 (Frame independence).** If $\iota$ and $\kappa$ are two orthonormal frames of the same hyperplane $u^\perp$ (both satisfying the conditions of Theorem 3.6), then $\operatorname{vol}_{n-1}(\Sigma(A,\iota)) = \operatorname{vol}_{n-1}(\Sigma(A,\kappa))$.

*Proof.* Both are computed by Theorem 3.7 to be $|\det A|\,\omega_{n-1}/\|A^{\mathsf T}u\|$, an expression not involving the frame. $\square$

> **Theorem 3.9 (Existence of slicing frames).** Every unit vector $u \in \mathbb{R}^n$ ($n = m+1 \ge 1$) admits an $n\times m$ matrix $\iota$ with $\iota^{\mathsf T}\iota = I_m$ and $\iota\iota^{\mathsf T} = I_n - uu^{\mathsf T}$.

*Proof sketch.* Extend $u$ to an orthonormal basis $(u, v_1,\dots,v_m)$ of $\mathbb{R}^n$ (Gram–Schmidt on any basis containing $u$). Let $Q$ be the orthogonal matrix with these columns; then $QQ^{\mathsf T} = I$ expands as $uu^{\mathsf T} + \sum_j v_jv_j^{\mathsf T} = I$. Take $\iota = [\,v_1\mid\cdots\mid v_m\,]$: orthonormality of the $v_j$ gives $\iota^{\mathsf T}\iota = I_m$, and the displayed identity gives $\iota\iota^{\mathsf T} = I - uu^{\mathsf T}$. $\square$

> **Corollary 3.10 (Unconditional section formula).** For every invertible $A$ and every unit vector $u$ there is an orthonormal frame of $u^\perp$, and for every such frame the section volume equals $|\det A|\,\omega_{n-1}/\|A^{\mathsf T}u\|$. In particular the function
> $$u \longmapsto \operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr)$$
> is well defined on the unit sphere and given by that formula.

---

## 4. Spectral slicing bounds and their equality cases

Throughout this section $A \succ 0$ with eigenvalues $\lambda_1,\dots,\lambda_n > 0$; then $A^{\mathsf T} = A$, $\det A > 0$, and the section formula reads $\operatorname{vol}_{n-1}(E(A)\cap u^\perp) = (\det A/\|Au\|)\,\omega_{n-1}$.

### 4.1 The weighted-average lemma

> **Lemma 4.1.** Let $A \succ 0$ and let $u$ be a unit vector with coordinates $c$ in an orthonormal eigenbasis of $A$. Then
> $$\|Au\|^2 = \sum_{i}\lambda_i^2 c_i^2, \qquad \sum_i c_i^2 = 1 .$$
> Consequently $\lambda_{\min} \le \|Au\| \le \lambda_{\max}$; more generally, if $\ell \le \lambda_i \le h$ for all $i$ with $\ell \ge 0$, then $\ell \le \|Au\| \le h$.

*Proof.* The eigenbasis is orthonormal, so $u = \sum_i c_iw_i$ with $\|u\|^2 = \sum c_i^2 = 1$ and $Au = \sum_i \lambda_ic_iw_i$, whence $\|Au\|^2 = \sum\lambda_i^2c_i^2$. This is a convex combination of the $\lambda_i^2$ with weights $c_i^2$, so it lies in $[\ell^2,h^2]$. $\square$

### 4.2 The two-sided bounds

> **Theorem 4.2 (Spectral slicing bounds).** Let $A \succ 0$ with $0 < \ell \le \lambda_i \le h$ for all $i$, and let $u$ be a unit vector. Then
> $$\frac{\det A}{h}\;\omega_{n-1} \;\le\; \operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr) \;\le\; \frac{\det A}{\ell}\;\omega_{n-1}.$$
> In particular the extreme values over all directions are $\det A/\lambda_{\max}$ and $\det A/\lambda_{\min}$ times $\omega_{n-1}$.

*Proof.* Combine Corollary 3.10 with Lemma 4.1 and monotonicity of $t \mapsto \det A/t$ on $(0,\infty)$. $\square$

> **Theorem 4.3 (Sections in eigendirections).** If $Au = \lambda u$ with $\|u\|=1$ and $\lambda>0$, then
> $$\operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr) = \frac{\det A}{\lambda}\;\omega_{n-1}.$$

*Proof.* $\|Au\| = \lambda\|u\| = \lambda$; substitute into Corollary 3.10. $\square$

Thus the bounds of Theorem 4.2 are attained. Both statements have a transparent geometric reading: the section orthogonal to the $i$-th axis of a diagonal ellipsoid with semiaxes $\lambda$ is the $(n-1)$-dimensional ellipsoid with semiaxes $\{\lambda_j\}_{j\neq i}$, of volume $\bigl(\prod_{j\ne i}\lambda_j\bigr)\omega_{n-1} = (\det A/\lambda_i)\omega_{n-1}$.

### 4.3 The equality case

The converse of Theorem 4.3 is the sharper statement, and it identifies the extremal directions exactly.

> **Lemma 4.4 (Equality in a weighted average).** Let $\lambda_i>0$, $\lambda_i \le h$ for all $i$, and let $c$ satisfy $\sum_i c_i^2 = 1$ and $\sum_i \lambda_i^2c_i^2 = h^2$. Then $\lambda_ic_i = hc_i$ for every $i$; i.e. $c_i = 0$ whenever $\lambda_i < h$.

*Proof.* $\sum_i (h^2 - \lambda_i^2)c_i^2 = h^2 - h^2 = 0$ is a sum of nonnegative terms, so each vanishes: $(h^2-\lambda_i^2)c_i^2 = 0$. If $\lambda_i < h$ then $h^2 - \lambda_i^2 > 0$ forces $c_i = 0$, and then $\lambda_ic_i = 0 = hc_i$; if $\lambda_i = h$ the identity is trivial. $\square$

> **Theorem 4.5 (Extremal norms are eigenvalue equations).** Let $A\succ0$, $\|u\| = 1$.
> 1. If $\lambda_i \le h$ for all $i$, then $\|Au\| = h \iff Au = hu$.
> 2. If $\lambda_i \ge \ell \ge 0$ for all $i$, then $\|Au\| = \ell \iff Au = \ell u$.

*Proof.* ($\Leftarrow$) is Theorem 4.3's computation. ($\Rightarrow$) for (1): write $u$ in the eigenbasis with coordinates $c$; Lemma 4.1 gives $\sum\lambda_i^2c_i^2 = h^2$, so Lemma 4.4 gives $\lambda_ic_i = hc_i$ for all $i$, i.e. $Au = \sum_i\lambda_ic_iw_i = h\sum_ic_iw_i = hu$. Part (2) is the same argument with the inequality reversed: $\sum_i(\lambda_i^2-\ell^2)c_i^2 = 0$ with nonnegative terms. $\square$

> **Theorem 4.6 (Extremal sections are exactly the eigendirections).** Let $A \succ 0$ and let $u$ be a unit vector with orthonormal frame $\iota$ of $u^\perp$.
> 1. If $\ell > 0$ is a lower bound for the spectrum, then
> $$\operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr) = \frac{\det A}{\ell}\,\omega_{n-1} \iff Au = \ell u.$$
> 2. If $h > 0$ is an upper bound for the spectrum, then
> $$\operatorname{vol}_{n-1}\bigl(E(A)\cap u^\perp\bigr) = \frac{\det A}{h}\,\omega_{n-1} \iff Au = h u.$$

*Proof.* By Corollary 3.10 the section volume is $(\det A/\|Au\|)\omega_{n-1}$, and $\omega_{n-1} > 0$, so the stated volume equality is equivalent to $\det A/\|Au\| = \det A/\ell$, i.e. (as $\det A>0$ and $\|Au\|>0$) to $\|Au\| = \ell$. Apply Theorem 4.5. $\square$

The content of Theorem 4.6 is a *rigidity* statement: the maximal-volume central sections of an ellipsoid are exactly those orthogonal to a minimal-eigenvalue eigenvector, and the minimal-volume ones exactly those orthogonal to a maximal-eigenvalue eigenvector. In particular the section-volume function on the sphere determines $\lambda_{\min}$, $\lambda_{\max}$ and the corresponding eigenspaces.

### 4.4 The determinant-normalization identity

> **Theorem 4.7 (Product of the principal sections).** For $A\succ0$ in $\mathbb{R}^n$, $n \ge 1$,
> $$\prod_{i=1}^{n}\frac{\det A}{\lambda_i} = (\det A)^{\,n-1}.$$
> Equivalently, the product of the $n$ normalised principal section volumes equals $(\det A)^{n-1}$, i.e. $\operatorname{vol}(E(A))^{n-1}$ up to the ball normalisation.

*Proof.* $\prod_i (\det A/\lambda_i) = (\det A)^n/\prod_i\lambda_i = (\det A)^n/\det A = (\det A)^{n-1}$. $\square$

This is a conservation law: however the eccentricities are distributed among the axes, the geometric mean of the principal sections is pinned by the volume. One cannot make all principal sections small without shrinking the body.

### 4.5 Unimodular ellipsoids straddle the ball

> **Lemma 4.8.** If $A \succ 0$ and $\det A = 1$, then some eigenvalue is $\le 1$ and some eigenvalue is $\ge 1$.

*Proof.* If all $\lambda_i > 1$ then $\det A = \prod\lambda_i > 1$; if all $\lambda_i < 1$ then $\det A < 1$. $\square$

> **Theorem 4.9 (Extremal sections of a unimodular ellipsoid).** Let $A \succ 0$ with $\det A = 1$ in $\mathbb{R}^n$, $n \ge 1$. Then there exist unit vectors $u_+$ and $u_-$ such that
> $$\operatorname{vol}_{n-1}\bigl(E(A)\cap u_+^{\perp}\bigr) \;\ge\; \omega_{n-1} \;\ge\; \operatorname{vol}_{n-1}\bigl(E(A)\cap u_-^{\perp}\bigr).$$
> Both may be taken to be eigenvectors: $u_+$ for an eigenvalue $\le 1$, $u_-$ for an eigenvalue $\ge 1$.

*Proof.* Choose by Lemma 4.8 an eigenvalue $\lambda \le 1$ with unit eigenvector $u_+$; by Theorem 4.3 the section volume is $(1/\lambda)\omega_{n-1} \ge \omega_{n-1}$. Symmetrically for $u_-$ with $\lambda' \ge 1$. $\square$

So no volume-normalised ellipsoid can be uniformly "thinner" or uniformly "fatter" than the unit ball in the sense of central sections. In §7 this is refined to a uniqueness statement.

---

## 5. Sections of arbitrary codimension

Theorem 3.5 already computes any central section as a Gram determinant. We now extract quantitative consequences.

### 5.1 Determinant bounds from quadratic-form bounds

> **Theorem 5.1.** Let $G \succ 0$ be $m\times m$ and $c \in \mathbb{R}$.
> 1. If $\langle Gy,y\rangle \le c\,\|y\|^2$ for all $y$, then $\det G \le c^{\,m}$.
> 2. If $c \ge 0$ and $c\,\|y\|^2 \le \langle Gy,y\rangle$ for all $y$, then $c^{\,m} \le \det G$.

*Proof.* Let $\mu_1,\dots,\mu_m > 0$ be the eigenvalues of $G$, so $\det G = \prod_j \mu_j$. Testing the hypothesis on a unit eigenvector for $\mu_j$ gives $\mu_j \le c$ in case (1) and $\mu_j \ge c$ in case (2). Multiply the $m$ inequalities, all sides being nonnegative. $\square$

### 5.2 The $m$-dimensional sandwich

> **Theorem 5.2 (Codimension-free slicing sandwich).** Let $A \succ 0$ in $\mathbb{R}^n$ with all eigenvalues in $[\ell,h]$, $0 < \ell \le h$, and let $\iota$ be any $n\times m$ frame with $\iota^{\mathsf T}\iota = I_m$. Then
> $$\ell^{\,m}\,\omega_m \;\le\; \operatorname{vol}_m\bigl(E(A)\cap\operatorname{ran}\iota\bigr) \;\le\; h^{\,m}\,\omega_m.$$

*Proof.* Let $G = (A^{-1}\iota)^{\mathsf T}(A^{-1}\iota)$. For $y \in \mathbb{R}^m$ set $z = \iota y$ (so $\|z\| = \|y\|$, as $\iota$ is an isometry) and $w = A^{-1}z$; then by (2.1), $\langle Gy,y\rangle = \|w\|^2$. By the eigenvalue bounds applied to $w$ (Lemma 4.1), $\ell\|w\| \le \|Aw\| = \|z\| = \|y\| \le h\|w\|$, hence
$$\frac{1}{h^2}\|y\|^2 \;\le\; \langle Gy,y\rangle \;\le\; \frac{1}{\ell^2}\|y\|^2 .$$
By Theorem 5.1, $h^{-2m} \le \det G \le \ell^{-2m}$, so $\ell^{m} \le (\det G)^{-1/2} \le h^{m}$. Now apply Theorem 3.5. $\square$

Theorem 5.2 is the exact quantitative form of the geometric statement that $B(0,\ell) \subseteq E(A) \subseteq B(0,h)$ (Theorem 2.11): a ball sandwich forces a slice sandwich in every dimension, with the same constants.

### 5.3 Coordinate sections of diagonal ellipsoids

> **Theorem 5.3 (Coordinate sections).** Let $d_1,\dots,d_n$ be nonzero reals, $A = \operatorname{diag}(d)$, and let $f : \{1,\dots,m\}\to\{1,\dots,n\}$ be injective, with $\iota$ the corresponding coordinate frame (whose $j$-th column is the standard basis vector $e_{f(j)}$). Then
> $$\operatorname{vol}_m\bigl(E(A) \cap \operatorname{span}\{e_{f(1)},\dots,e_{f(m)}\}\bigr) = \Bigl(\prod_{j=1}^{m}|d_{f(j)}|\Bigr)\,\omega_m .$$

*Proof.* Here $A^{-1}\iota$ has columns $d_{f(j)}^{-1}e_{f(j)}$, so $(A^{-1}\iota)^{\mathsf T}(A^{-1}\iota) = \operatorname{diag}\bigl(d_{f(j)}^{-2}\bigr)$, whose determinant is $\prod_j d_{f(j)}^{-2}$. Theorem 3.5 gives the volume $\omega_m\prod_j|d_{f(j)}|$. $\square$

This is the exact $m$-dimensional analogue of "volume equals the product of the semiaxes", and it specialises to the familiar worked cases: for $n=2$, $A = \operatorname{diag}(a,b)$ and the frame $e_1$, the "section" is the segment of half-length $a$, of $1$-volume $a\cdot\omega_1 = 2a$; for $n=3$, $A=\operatorname{diag}(a,b,c)$ and the frame $(e_1,e_2)$, the section is the ellipse of area $ab\,\omega_2 = \pi ab$.

---

## 6. Polar duality

> **Definition 6.1 (Polar set).** For $S \subseteq \mathbb{R}^n$,
> $$S^{\circ} := \{\, y \in \mathbb{R}^n : \langle y,x\rangle \le 1 \text{ for all } x \in S \,\}.$$

> **Proposition 6.2 (Calculus of polars).** For all $S,T$: (i) $S \subseteq T \Rightarrow T^\circ \subseteq S^\circ$; (ii) $(S\cup T)^\circ = S^\circ \cap T^\circ$; (iii) $(B^n)^\circ = B^n$.

*Proof.* (i) and (ii) are immediate from the definition. (iii) By Cauchy–Schwarz, $\|y\|\le1$ implies $\langle y,x\rangle \le 1$ for $\|x\|\le1$. Conversely if $y \ne 0$ satisfies the defining condition, testing at $x = y/\|y\| \in B^n$ gives $\|y\| \le 1$. $\square$

> **Theorem 6.3 (Linear covariance).** For invertible $A$ and any set $S$,
> $$\bigl(A\,S\bigr)^{\circ} = (A^{\mathsf T})^{-1}\,S^{\circ}.$$

*Proof.* $y \in (AS)^\circ$ iff $\langle y, Ax\rangle \le 1$ for all $x \in S$, iff $\langle A^{\mathsf T}y, x\rangle \le 1$ for all $x\in S$, iff $A^{\mathsf T}y \in S^\circ$, iff $y \in (A^{\mathsf T})^{-1}S^\circ$. $\square$

> **Corollary 6.4 (Polar of an ellipsoid).** For invertible $A$, $\ E(A)^{\circ} = E\bigl((A^{\mathsf T})^{-1}\bigr)$.

*Proof.* $E(A)^\circ = (A B^n)^\circ = (A^{\mathsf T})^{-1}(B^n)^\circ = (A^{\mathsf T})^{-1}B^n = E((A^{\mathsf T})^{-1})$, by Theorem 6.3 and Proposition 6.2(iii). $\square$

> **Corollary 6.5 (Bipolar theorem for ellipsoids).** For invertible $A$, $\ \bigl(E(A)^\circ\bigr)^\circ = E(A)$.

*Proof.* Apply Corollary 6.4 twice and simplify: the inverse transpose of $(A^{\mathsf T})^{-1}$ is $A$. $\square$

> **Corollary 6.6 (Volume of the polar).** For invertible $A$, $\ \operatorname{vol}\bigl(E(A)^\circ\bigr) = |\det A|^{-1}\omega_n$.

*Proof.* Theorem 2.5 applied to $(A^{\mathsf T})^{-1}$, whose determinant is $(\det A)^{-1}$. $\square$

> **Theorem 6.7 (Blaschke–Santaló equality for ellipsoids).** For every invertible $A$,
> $$\operatorname{vol}\bigl(E(A)\bigr)\cdot\operatorname{vol}\bigl(E(A)^{\circ}\bigr) = \omega_n^{2}.$$
> Every ellipsoid has exactly the volume product of the ball.

*Proof.* Multiply Theorem 2.5 and Corollary 6.6: $|\det A|\,\omega_n \cdot |\det A|^{-1}\omega_n = \omega_n^2$. $\square$

> **Theorem 6.8 (Linear invariance of the volume product).** For invertible $A$ and any measurable $S$,
> $$\operatorname{vol}(A\,S)\cdot\operatorname{vol}\bigl((A\,S)^{\circ}\bigr) = \operatorname{vol}(S)\cdot\operatorname{vol}(S^{\circ}).$$

*Proof.* By Theorem 6.3, $(AS)^\circ = (A^{\mathsf T})^{-1}S^\circ$. The two determinant factors $|\det A|$ and $|\det A|^{-1}$ cancel. $\square$

Theorem 6.8 explains Theorem 6.7 conceptually: the volume product is an affine invariant of a symmetric body, and every ellipsoid is a linear image of the ball, whose volume product is $\omega_n^2$ by self-polarity.

> **Theorem 6.9 (Santaló-type estimate for ellipsoidally squeezed bodies).** Suppose $E(A) \subseteq S \subseteq E(B)$ with $A$ invertible. Then
> $$\operatorname{vol}(S)\cdot\operatorname{vol}(S^{\circ}) \;\le\; \frac{|\det B|}{|\det A|}\;\omega_n^{2}.$$
> Taking $A = B$ recovers Theorem 6.7 exactly.

*Proof.* Monotonicity gives $\operatorname{vol}(S)\le\operatorname{vol}(E(B)) = |\det B|\omega_n$. Antitonicity of polarity (Proposition 6.2(i)) plus $E(A)\subseteq S$ gives $S^\circ\subseteq E(A)^\circ$, whence $\operatorname{vol}(S^\circ) \le |\det A|^{-1}\omega_n$ by Corollary 6.6. Multiply. $\square$

The ratio $|\det B|/|\det A|$ measures how well the body is approximated by ellipsoids from inside and outside; by John's theorem (see §8 for the existence half) such a sandwich always exists with a dimension-dependent ratio, so Theorem 6.9 is a genuinely applicable bound.

---

## 7. The intersection body of an ellipsoid

### 7.1 Definition and statement

For a star-shaped body $K$ with radial function $\rho_K(u) = \sup\{t\ge0 : tu \in K\}$, the *intersection body* $IK$ is the star body with radial function
$$\rho_{IK}(u) = \operatorname{vol}_{n-1}\bigl(K \cap u^{\perp}\bigr)\big/\omega_{n-1},$$
the normalised central-section volume in the direction $u$. Intersection bodies are the central objects of the dual Brunn–Minkowski theory and are the key to the Busemann–Petty problem.

By Corollary 3.10, for an ellipsoid the normalised section function is
$$u \longmapsto \frac{|\det A|}{\|A^{\mathsf T}u\|},$$
and the question is whether this is the radial function of an ellipsoid. It is.

> **Definition 7.1 (Gram square root and intersection generator).** For invertible $A$ put
> $$S := \sqrt{A A^{\mathsf T}} \succ 0, \qquad \mathcal{I}(A) := |\det A|\;S^{-1}.$$

> **Lemma 7.2.** For invertible $A$: $AA^{\mathsf T}\succ0$; $\det S = |\det A|$; and $\mathcal{I}(A)^{-1} = S/|\det A|$.

*Proof.* $AA^{\mathsf T}$ is symmetric with $\langle AA^{\mathsf T}x,x\rangle = \|A^{\mathsf T}x\|^2 > 0$ for $x\ne0$. Then $(\det S)^2 = \det(S^2) = \det(AA^{\mathsf T}) = (\det A)^2$ and $\det S>0$ give $\det S = |\det A|$. The last claim is immediate. $\square$

> **Lemma 7.3 (Radial description of an ellipsoid).** For invertible $H$, a unit vector $u$ and $t \ge 0$:
> $$t\,u \in E(H) \iff t\,\|H^{-1}u\| \le 1 .$$

*Proof.* Proposition 2.2 and homogeneity of the norm. $\square$

> **Theorem 7.4 (Intersection body of an ellipsoid).** Let $A$ be invertible, $u$ a unit vector and $t \ge 0$. Then
> $$t\,u \in E\bigl(\mathcal{I}(A)\bigr) \iff t\,\|A^{\mathsf T}u\| \le |\det A| \iff t \;\le\; \frac{\operatorname{vol}_{n-1}\bigl(E(A)\cap u^{\perp}\bigr)}{\omega_{n-1}} .$$
> Hence $I\bigl(E(A)\bigr) = E\bigl(|\det A|\sqrt{AA^{\mathsf T}}^{\,-1}\bigr)$: **the intersection body of an ellipsoid is an ellipsoid.**

*Proof.* By Lemma 7.3 applied to $H = \mathcal I(A)$ and Lemma 7.2, $tu \in E(\mathcal I(A))$ iff $t\,\|\mathcal I(A)^{-1}u\| \le 1$ iff $t\,\|Su\| \le |\det A|$. Now $\|Su\|^2 = \langle S^2u,u\rangle = \langle AA^{\mathsf T}u,u\rangle = \|A^{\mathsf T}u\|^2$, using $S$ symmetric and $S^2 = AA^{\mathsf T}$; so $\|Su\| = \|A^{\mathsf T}u\|$ and the first equivalence follows. The second is Corollary 3.10 rearranged (both $\|A^{\mathsf T}u\|>0$ and $|\det A|>0$). $\square$

The proof also explains *why* the square root appears: $S$ is the unique positive definite matrix with $\|Su\| = \|A^{\mathsf T}u\|$ for every $u$; it is the "shape" of $A$ with the rotational ambiguity of the polar decomposition removed.

### 7.2 Determinant, volume, and the involution

> **Theorem 7.5.** For invertible $A$ in $\mathbb{R}^n$: $\ \det \mathcal{I}(A) = |\det A|^{\,n-1}$ and
> $$\operatorname{vol}\bigl(I(E(A))\bigr) = |\det A|^{\,n-1}\,\omega_n .$$
> In particular a unimodular ellipsoid has an intersection body of exactly the volume of the ball.

*Proof.* $\det(|\det A| S^{-1}) = |\det A|^n(\det S)^{-1} = |\det A|^n/|\det A| = |\det A|^{n-1}$ by Lemma 7.2; then apply Theorem 2.5. $\square$

> **Proposition 7.6.** If $A \succ 0$ then $\mathcal{I}(A) = (\det A)\,A^{-1}$.

*Proof.* For $A \succ 0$, $AA^{\mathsf T} = A^2$, so $S = \sqrt{A^2} = A$ by uniqueness of the positive semidefinite square root, and $\det A > 0$. $\square$

> **Theorem 7.7 (Involution on unimodular generators).** If $A \succ 0$ and $\det A = 1$, then $\mathcal{I}(A) = A^{-1}$ and $\mathcal{I}(\mathcal{I}(A)) = A$.

*Proof.* By Proposition 7.6, $\mathcal I(A) = A^{-1}$, which is again positive definite of determinant $1$; applying Proposition 7.6 again gives $\mathcal I(A^{-1}) = (A^{-1})^{-1} = A$. $\square$

> **Theorem 7.8 (The ball is the unique unimodular fixed point).** If $A \succ 0$, $\det A = 1$ and $\mathcal{I}(A) = A$, then $A = I$; equivalently $E(A) = B^n$. Thus **the ball is the unique unimodular ellipsoid that equals its own intersection body.**

*Proof.* By Theorem 7.7, $\mathcal I(A) = A^{-1}$, so the hypothesis says $A^{-1} = A$, i.e. $A^2 = I$. A positive definite matrix with $A^2 = I$ has all eigenvalues positive and squaring to $1$, hence all equal to $1$, hence $A = I$ by the spectral theorem. $\square$

Theorem 7.8 sharpens Theorem 4.9: not only does a unimodular ellipsoid have both a section larger and a section smaller than the ball's — the *entire* section profile equals the ball's only for the ball itself.

---

## 8. Existence of the maximal-volume inscribed ellipsoid

> **Definition 8.1 (Inscribed generators).** For a set $K \subseteq \mathbb{R}^n$,
> $$\mathcal{G}(K) := \{\, A : A \succeq 0 \text{ and } E(A)\subseteq K \,\}.$$

Admitting *degenerate* (singular positive semidefinite) generators is essential: the flat limits of nondegenerate inscribed ellipsoids are exactly what a closed constraint set must contain.

> **Lemma 8.2 (Closedness).** If $K$ is closed then $\mathcal{G}(K)$ is closed in the space of matrices.

*Proof sketch.* The set of positive semidefinite matrices is closed (it is an intersection of closed half-spaces $\{A : \langle Ax,x\rangle \ge 0\}$ together with the closed symmetry condition). The constraint $E(A)\subseteq K$ is $\{A : \forall x \in B^n,\ Ax \in K\}$, an intersection over $x\in B^n$ of the closed sets $\{A : Ax \in K\}$ (closed as preimages of the closed $K$ under the continuous map $A \mapsto Ax$). $\square$

> **Lemma 8.3 (Boundedness).** If $K \subseteq B(0,R)$ then every $A \in \mathcal{G}(K)$ has all entries bounded by $R$ in absolute value; hence $\mathcal{G}(K)$ is bounded, and by Lemma 8.2 compact.

*Proof.* For a standard basis vector $e_j \in B^n$, $Ae_j \in K \subseteq B(0,R)$, so the $j$-th column of $A$ has norm at most $R$; each coordinate of a vector is bounded by its norm. $\square$

> **Theorem 8.4 (Existence of a maximiser).** Let $K$ be closed with $K \subseteq B(0,R)$, and suppose $K$ contains a nondegenerate ellipsoid $E(A_0)$ with $A_0 \succ 0$. Then there exists $A \succ 0$ with $E(A)\subseteq K$ and
> $$\det A \;\ge\; \det B \quad\text{for every } B \succeq 0 \text{ with } E(B)\subseteq K,$$
> equivalently
> $$\operatorname{vol}\bigl(E(A)\bigr) \;\ge\; \operatorname{vol}\bigl(E(B)\bigr)\quad\text{for all such } B .$$

*Proof.* $\mathcal G(K)$ is nonempty (it contains $A_0$) and compact by Lemmas 8.2–8.3. The determinant is a polynomial, hence continuous, so it attains a maximum at some $A \in \mathcal G(K)$. Since $\det A \ge \det A_0 > 0$, the maximiser is nonsingular, and being positive semidefinite and nonsingular it is positive definite. The volume reformulation is Theorem 2.5, monotone in $\det$ since all determinants involved are nonnegative. $\square$

> **Corollary 8.5.** For every $n$ there is a maximal-volume ellipsoid inscribed in the unit ball, namely (necessarily) the unit ball itself; more usefully, the theorem applies verbatim to any closed bounded body with nonempty interior, since such a body contains a small ball, which is a nondegenerate ellipsoid.

The maximiser of Theorem 8.4 is the **John ellipsoid** of $K$. Uniqueness (not addressed here) follows from strict concavity of $\det^{1/n}$ on positive definite matrices; combined with Theorem 6.9 it yields the classical statement that any symmetric convex body is squeezed between an ellipsoid and its $\sqrt n$-dilate, hence has volume product within a factor $n^{n/2}$ of the extremal value.

---

## 9. Algorithms and numerical illustration

All results above are constructive and translate directly into short numerical procedures.

### 9.1 Exact section volume

**Input:** invertible $A \in \mathbb{R}^{n\times n}$, unit vector $u$.
**Output:** $\operatorname{vol}_{n-1}(E(A)\cap u^\perp)$.

1. Compute $\delta \leftarrow |\det A|$ (cost $O(n^3)$ by LU factorisation).
2. Compute $\nu \leftarrow \|A^{\mathsf T}u\|$ (cost $O(n^2)$).
3. Return $(\delta/\nu)\cdot\omega_{n-1}$, where $\omega_m = \pi^{m/2}/\Gamma(m/2+1)$.

The dominating cost is the determinant; once $\delta$ is cached, each further direction costs $O(n^2)$. This is the algorithmic content of Corollary 3.10 and is what makes ellipsoids so cheap to use as slicing benchmarks.

### 9.2 Section volume by Gram determinant (any codimension)

**Input:** invertible $A$, frame $\iota \in \mathbb{R}^{n\times m}$ with orthonormal columns.
**Output:** $\operatorname{vol}_m(E(A)\cap\operatorname{ran}\iota)$.

1. $T \leftarrow A^{-1}\iota$ (solve $AT = \iota$, cost $O(n^3 + n^2m)$).
2. $G \leftarrow T^{\mathsf T}T$ (cost $O(nm^2)$).
3. Return $\omega_m/\sqrt{\det G}$ (cost $O(m^3)$).

For $m = n-1$ this must agree with §9.1, which is a sharp numerical test of Theorem 3.6.

### 9.3 Extremal directions

By Theorem 4.6, the maximal section is found by an eigendecomposition of the positive definite generator: diagonalise $A = U\operatorname{diag}(\lambda)U^{\mathsf T}$ ($O(n^3)$), take $u$ the eigenvector for $\lambda_{\min}$ for the maximal section and for $\lambda_{\max}$ for the minimal section. No optimisation over the sphere is needed — the spectral data *is* the answer.

### 9.4 Building a slicing frame

By Theorem 3.9: form any matrix whose first column is $u$, apply Gram–Schmidt (or take the $Q$ factor of a QR decomposition), and drop the first column. The residual identities $\iota^{\mathsf T}\iota = I$ and $\iota\iota^{\mathsf T} = I - uu^{\mathsf T}$ are then verifiable to machine precision and serve as a numerical validation of the construction.

### 9.5 Intersection body

By Theorem 7.4: compute $S = \sqrt{AA^{\mathsf T}}$ from the eigendecomposition of $AA^{\mathsf T}$ (replace each eigenvalue by its square root), then $\mathcal I(A) = |\det A|S^{-1}$. The predicted radial function $|\det A|/\|A^{\mathsf T}u\|$ can be compared directly with the normalised section volume computed by §9.1 or §9.2.

### 9.6 Monte-Carlo cross-validation

The whole edifice can be tested against a direct estimate: sample $y$ uniformly in the cube $[-r,r]^{n-1}$ (with $r$ the circumradius of the section), test $\|A^{-1}\iota y\| \le 1$, and multiply the acceptance rate by $(2r)^{n-1}$. This converges at the usual $O(N^{-1/2})$ rate and agrees with the closed form to within sampling error — a useful reality check in low dimensions, and a reminder of how much the exact formula buys.

---

## 10. Discussion

### 10.1 What makes it all work

Three mechanisms account for every theorem above.

1. **Determinant homogeneity.** Volume under a linear map scales by $|\det|$. This alone gives Theorem 2.5 and, via cancellation, the linear invariance of the volume product (Theorem 6.8) and the Blaschke–Santaló equality (Theorem 6.7).
2. **The Gram determinant.** For rectangular maps the determinant is replaced by $\sqrt{\det T^{\mathsf T}T}$ (Theorem 3.4). All section formulas are evaluations of this one quantity; the hyperplane case simplifies to a single vector norm (Theorem 3.6) because appending one orthogonal column makes the matrix square.
3. **The spectral theorem.** Every positive definite generator is diagonal in an orthonormal basis, turning norms into weighted averages of eigenvalues (Lemma 4.1). Inequalities follow from bounding the average; equality cases follow from the vanishing of a sum of nonnegative terms (Lemma 4.4). This yields both the slicing bounds and their rigidity.

The redundancy $E(AU) = E(A)$ for orthogonal $U$ is not a defect but a tool: it lets one replace an arbitrary generator by the positive definite $\sqrt{AA^{\mathsf T}}$ whenever spectral reasoning is needed, which is exactly the manoeuvre behind Theorem 7.4.

### 10.2 Relation to the classical theory

- **Blaschke–Santaló.** The inequality $\operatorname{vol}(K)\operatorname{vol}(K^\circ)\le\omega_n^2$ for symmetric convex $K$ has ellipsoids as its equality case; Theorem 6.7 is that equality case, obtained here for free from covariance. Theorem 6.9 converts an ellipsoidal sandwich into a quantitative bound for general bodies.
- **Busemann–Petty.** The problem asks whether $\operatorname{vol}_{n-1}(K\cap u^\perp)\le\operatorname{vol}_{n-1}(L\cap u^\perp)$ for all $u$ implies $\operatorname{vol}(K)\le\operatorname{vol}(L)$; the answer is affirmative for $n \le 4$ and negative for $n \ge 5$, and the pivotal notion is the intersection body. Theorem 7.4 shows the ellipsoid class is closed under the intersection-body operator — which is precisely why the problem is easy when $L$ is a ball: the comparison reduces to the explicit formula of Corollary 3.10.
- **John's theorem.** Theorem 8.4 is the existence half; it is stated so that degenerate generators keep the feasible set closed, a formulation that also makes the argument dimension-free.
- **Slicing conjecture.** For ellipsoids the isotropic constant is bounded by an absolute constant, immediately from Corollary 3.10 combined with the normalisation $\det A = 1$: Theorem 4.9 shows that a unimodular ellipsoid always has a section of volume at least $\omega_{n-1}$, which is the ellipsoidal instance of the hyperplane conjecture.

### 10.3 Limits of the present development

The theory here is exact but confined to ellipsoids centred at the origin. Non-central sections (by affine hyperplanes $\{x : \langle x,u\rangle = c\}$) are also computable — the section is again an ellipsoid, scaled by $\sqrt{1 - c^2/\|A^{\mathsf T}u\|^2}$ — but require a separate argument. Non-symmetric bodies, projections rather than sections (the dual theory, where $\|A^{\mathsf T}u\|$ is replaced by $\|A u\|$ and one obtains the *projection body*), and $L_p$-analogues are natural next targets.

### 10.4 Future directions

**What the thread has established.** A complete development of ellipsoids as $E(A) = A B^n$: their volume $|\det A|\,\omega_n$, orthogonal invariance, the spectral decomposition $E(A) = U\,E(\operatorname{diag}\lambda)$, the eigenvalue sandwich $B(0,\lambda_{\min})\subseteq E(A)\subseteq B(0,\lambda_{\max})$, the Gram-determinant volume formula for preimages of the ball, and the explicit hyperplane section formula $\operatorname{vol}_{n-1}(E(A)\cap u^\perp) = (|\det A|/\|A^{\mathsf T}u\|)\,\omega_{n-1}$; two-sided slicing bounds by the extreme eigenvalues, their attainment in eigendirections and the exact equality case, frame independence and the existence of slicing frames, the determinant-normalization identity $\prod_i(\det A/\lambda_i) = (\det A)^{n-1}$, polar duality $E(A)^\circ = E((A^{\mathsf T})^{-1})$, the Blaschke–Santaló *equality* $\operatorname{vol}(E(A))\operatorname{vol}(E(A)^\circ) = \omega_n^2$, and worked two- and three-dimensional coordinate sections; the codimension-free Gram formula for sections by arbitrary $m$-dimensional subspaces, determinant bounds for positive definite matrices from bounds on their quadratic forms, the sandwich $\ell^m\omega_m \le \operatorname{vol}_m(\text{section})\le h^m\omega_m$, and the exact product formula for coordinate sections of a diagonal ellipsoid; the calculus of polar sets (antitonicity, polars of unions, self-polarity of the ball), full linear covariance $(A\cdot S)^\circ = (A^{\mathsf T})^{-1}S^\circ$, invariance of the volume product under invertible linear maps, the bipolar theorem for ellipsoids, and a Santaló-type estimate for any body squeezed between two ellipsoids; the theorem that the intersection body of an ellipsoid is an ellipsoid, with generator $|\det A|\,S^{-1}$ for $S = \sqrt{AA^{\mathsf T}}$, determinant $|\det A|^{n-1}$, the simplification $\mathcal I(A) = (\det A)A^{-1}$ for positive definite generators, and the consequence that on unimodular positive definite generators the operator is the involution $A \mapsto A^{-1}$ whose only fixed point is the identity — the ball is the unique unimodular ellipsoid that is its own intersection body; the existence of slicing frames for every unit vector, which removes the frame hypothesis from every section theorem; and the existence of a maximal-volume inscribed ellipsoid in any closed bounded body containing a nondegenerate ellipsoid.

**Where to go next.**

1. *Uniqueness of the John ellipsoid*, via strict log-concavity of the determinant on positive definite matrices, together with the contact-point characterisation (John's condition $\sum c_i u_iu_i^{\mathsf T} = I$) and the resulting $\sqrt n$ (resp. $n$) approximation constants for symmetric (resp. general) bodies.
2. *Non-central and affine sections*: the volume of $E(A)\cap\{ \langle x,u\rangle = c\}$, the resulting concavity properties of the section function in $c$ (an ellipsoidal instance of Brunn's theorem), and the corresponding Fourier-analytic description of the section function.
3. *Projection bodies and the dual theory*: prove that the projection body of an ellipsoid is an ellipsoid, identify its generator, and pair the resulting Petty projection identity with the Blaschke–Santaló equality proved here.
4. *Busemann–Petty in the ellipsoid class*: use the closure of ellipsoids under the intersection-body operator to give a complete, formula-level answer for ellipsoid-versus-ball comparisons in all dimensions, together with the sharp constants.
5. *Quantitative stability*: upgrade the rigidity of Theorem 4.6 and the uniqueness of Theorem 7.8 to stability statements — if the section profile is within $\varepsilon$ of the ball's, how close must the ellipsoid be to a ball?
6. *$L_p$ and Orlicz analogues*: replace the Euclidean ball by an $L_p$ ball and ask which of the identities above survive; the determinant homogeneity does, the Gram-determinant mechanism partially, and the spectral rigidity generally does not — mapping that boundary precisely would be informative.
7. *Random sections*: with the exact formula in hand, the distribution of $\operatorname{vol}_{n-1}(E(A)\cap u^\perp)$ for uniformly random $u$ is the distribution of $|\det A|/\|A^{\mathsf T}u\|$, which is explicitly computable; concentration of this quantity is the ellipsoidal shadow of the thin-shell phenomenon.

---

## 11. Conclusion

Defining an ellipsoid as a linear image of a ball turns every question about its volume into a determinant computation and every question about its sections into a Gram-determinant computation. The result is a compact and complete calculus: one scalar $|\det A|$ for volume, one scalar $\|A^{\mathsf T}u\|$ per direction for sections, the spectrum of the generator for the extremes, exact rigidity in the equality cases, exact self-duality of the volume product, and a closed class under the intersection-body operator with the ball as its unique unimodular fixed point. These identities are not approximations valid in a limit; they hold in every dimension for every ellipsoid, and they are the reason that ellipsoids remain the yardstick of high-dimensional convex geometry.
