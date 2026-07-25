# A Finite-Dimensional Hodge Decomposition for Closed Tropical Cochains

**Aristotle**  
**25 July 2026**

## Abstract

We isolate the linear-algebraic core of Hodge theory for finite balanced weighted polyhedral complexes. Let $P$, $C$, and $N$ be finite-dimensional real inner-product spaces equipped with consecutive coboundary maps $d_-:P\to C$ and $d_+:C\to N$ satisfying $d_+d_-=0$. We define the harmonic subspace in middle degree by

$$
\mathcal H=\ker d_+\cap(\operatorname{im}d_-)^\perp.
$$

Every closed cochain $x\in\ker d_+$ decomposes as $x=e+h$, where $e\in\operatorname{im}d_-$ is exact and $h\in\mathcal H$ is harmonic. The summands are orthogonal and unique. Consequently, adding an exact cochain to a closed cochain leaves its harmonic component unchanged, so harmonic cochains provide canonical representatives of cohomology classes. We also give an explicit two-dimensional counterexample to the stronger assertion that every cochain is exact plus harmonic. The counterexample identifies the missing coexact direction and explains why a full decomposition for arbitrary cochains requires adjoints and a third summand. Projection and singular-value algorithms are presented, together with weighted variants, diagnostics, complexity estimates, and applications to tropical complexes, networks, and discrete data.

## 1. Introduction

Hodge theory separates geometric data into components generated locally and components carrying global information. In a smooth setting this separation is usually expressed through differential forms, adjoint differential operators, and an elliptic Laplacian. On a finite polyhedral complex, the essential closed-form statement requires substantially less machinery. It is a theorem of finite-dimensional inner-product geometry applied to consecutive coboundary maps.

This observation is particularly useful in tropical geometry. Tropical spaces are assembled from polyhedral cells, often with balancing conditions and positive weights. After choosing orientations, incidence data yield cochain spaces and coboundary maps. Positive weights supply inner products. The relation that consecutive coboundaries compose to zero is the algebraic shadow of the boundary-of-a-boundary principle. Once these ingredients are available, closed tropical cochains admit a canonical orthogonal decomposition.

The scope of the theorem must be stated carefully. The two-summand decomposition applies to **closed** cochains. If one omits closedness and claims that every cochain is exact plus harmonic, the statement fails even in dimension two. Arbitrary cochains generally require a coexact term. This distinction is both mathematically decisive and computationally useful: a nonzero closure defect detects when the two-summand model is inapplicable.

The contributions are fourfold. First, we formulate harmonicity intrinsically using only closedness and orthogonality to exact cochains. Second, we prove existence and uniqueness of the exact-plus-harmonic decomposition for every closed cochain. Third, we prove invariance of the harmonic component under exact perturbations. Fourth, we exhibit and analyze the minimal coordinate counterexample to the unrestricted claim. We then translate the results into stable numerical procedures.

## 2. Algebraic and geometric setting

### 2.1 Cochain data

Let $P$, $C$, and $N$ be finite-dimensional real vector spaces equipped with positive-definite inner products. Let

$$
P\xrightarrow{d_-}C\xrightarrow{d_+}N
$$

be linear maps satisfying the cochain identity

$$
d_+\circ d_-=0.
$$

The middle space $C$ is the degree under study. The notation $d_-$ records the coboundary arriving from the preceding degree, while $d_+$ records the coboundary leaving for the next degree.

For a finite weighted polyhedral complex, bases may be indexed by oriented cells. The maps are represented by signed incidence matrices. Cell weights determine diagonal positive-definite Gram matrices and therefore weighted inner products. The abstract analysis below does not require a particular cell model: it uses only finite dimensionality, positive-definite inner products, and the cochain identity.

### 2.2 Exact, closed, and harmonic cochains

**Definition 2.1 (Exact cochain).** A cochain $e\in C$ is exact if there exists $p\in P$ such that $e=d_-p$. The exact subspace is

$$
E=\operatorname{im}d_-.
$$

**Definition 2.2 (Closed cochain).** A cochain $x\in C$ is closed if $d_+x=0$. The closed subspace is

$$
Z=\ker d_+.
$$

**Lemma 2.3 (Exact cochains are closed).** Under the identity $d_+d_-=0$, one has $E\subseteq Z$.

**Proof sketch.** If $e=d_-p$, then $d_+e=d_+d_-p=0$. Thus every member of the image of $d_-$ belongs to the kernel of $d_+$.

**Definition 2.4 (Harmonic cochain).** A cochain $h\in C$ is harmonic if it is closed and orthogonal to every exact cochain. Thus

$$
\mathcal H=Z\cap E^\perp
=\ker d_+\cap(\operatorname{im}d_-)^\perp.
$$

The definition is intrinsic to the middle degree. If an adjoint $d_-^*$ is introduced, orthogonality to $\operatorname{im}d_-$ is equivalent to $d_-^*h=0$, and therefore

$$
\mathcal H=\ker d_+\cap\ker d_-^*.
$$

The adjoint formulation is useful computationally but is not needed for the decomposition proof.

### 2.3 Cohomology

The middle cohomology vector space is the quotient

$$
H=Z/E=\ker d_+/\operatorname{im}d_-.
$$

This quotient is well defined because Lemma 2.3 gives $E\subseteq Z$. Two closed cochains $x$ and $y$ represent the same cohomology class exactly when $y-x$ is exact. A principal objective of Hodge theory is to select one canonical cochain from each such equivalence class.

## 3. Closed Hodge decomposition

### 3.1 Existence

**Theorem 3.1 (Closed Hodge Decomposition).** Let $P$, $C$, and $N$ be finite-dimensional real inner-product spaces, and let $d_-:P\to C$ and $d_+:C\to N$ satisfy $d_+d_-=0$. For every closed cochain $x\in C$, there exist an exact cochain $e\in E$ and a harmonic cochain $h\in\mathcal H$ such that

$$
x=e+h.
$$

Moreover, $e\perp h$.

**Proof sketch.** Because $C$ is finite-dimensional, the exact subspace $E$ admits the orthogonal decomposition

$$
C=E\oplus E^\perp.
$$

Let $e=\operatorname{proj}_E(x)$ and let $h=\operatorname{proj}_{E^\perp}(x)=x-e$. Then $e\in E$, $h\in E^\perp$, and $x=e+h$. By Lemma 2.3, $e$ is closed. Since $x$ is closed,

$$
d_+h=d_+(x-e)=d_+x-d_+e=0.
$$

Hence $h\in Z\cap E^\perp=\mathcal H$. Orthogonality follows from the construction.

The proof reveals that the harmonic component is the residual after best approximation by exact cochains. In particular,

$$
\|x-e\|=\min_{v\in E}\|x-v\|,
$$

and the unique minimizer is $e=\operatorname{proj}_E(x)$. This optimization interpretation is often the most convenient computational entry point.

### 3.2 Uniqueness

**Theorem 3.2 (Uniqueness of the decomposition).** Suppose

$$
x=e_1+h_1=e_2+h_2,
$$

where $e_1,e_2\in E$ and $h_1,h_2\in\mathcal H$. Then $e_1=e_2$ and $h_1=h_2$.

**Proof sketch.** Rearranging gives

$$
e_1-e_2=h_2-h_1.
$$

The left side belongs to $E$, since $E$ is a subspace. The right side belongs to $E^\perp$, since harmonic cochains are orthogonal to $E$. Hence the common vector lies in $E\cap E^\perp$. Its squared norm is its inner product with itself, but orthogonality forces this number to be zero. Positive definiteness gives $e_1-e_2=0$. Substituting back yields $h_1-h_2=0$.

**Corollary 3.3 (Orthogonal splitting of closed cochains).** The closed subspace decomposes as

$$
Z=E\oplus\mathcal H.
$$

**Proof sketch.** Existence gives $Z=E+\mathcal H$. The two subspaces are orthogonal by definition, so their intersection is trivial; uniqueness follows as in Theorem 3.2.

**Corollary 3.4 (Dimension formula).** One has

$$
\dim\mathcal H=\dim Z-\dim E.
$$

Thus the number of independent harmonic modes equals the dimension of cohomology.

**Proof sketch.** Take dimensions in the direct sum $Z=E\oplus\mathcal H$. Since $H=Z/E$, the quotient dimension is also $\dim Z-\dim E$.

### 3.3 Canonical harmonic representatives

**Theorem 3.5 (Invariance under exact perturbations).** Let $x,y\in Z$ be closed cochains such that

$$
y=x+e_0
$$

for some $e_0\in E$. If

$$
x=e_x+h_x,
\qquad
y=e_y+h_y
$$

are their closed Hodge decompositions, then $h_x=h_y$.

**Proof sketch.** From $x=e_x+h_x$ and $y=x+e_0$, we obtain

$$
y=(e_x+e_0)+h_x.
$$

Because $E$ is a subspace, $e_x+e_0$ is exact. Thus the right side is an exact-plus-harmonic decomposition of $y$. By Theorem 3.2, it must agree with the stated decomposition of $y$, so $h_y=h_x$.

**Corollary 3.6 (Harmonic model of cohomology).** The assignment sending a cohomology class $[x]\in H$ to the harmonic component of $x$ is well defined and bijective from $H$ to $\mathcal H$.

**Proof sketch.** Theorem 3.5 proves well-definedness. Every harmonic cochain represents a closed class and is its own harmonic component, proving surjectivity. If the harmonic component of a class is zero, its representative is exact, so the class is zero; this proves injectivity.

This corollary explains the geometric meaning of harmonicity. A cohomology class is an equivalence class containing many closed cochains, but the inner product chooses exactly one representative perpendicular to all exact changes. The quotient $Z/E$ is thereby realized as a concrete subspace of $C$.

## 4. Why arbitrary cochains need a third summand

The closedness hypothesis cannot be discarded. We now give a complete two-dimensional example.

Let

$$
P=\mathbb R,
\qquad C=\mathbb R^2,
\qquad N=\mathbb R
$$

with standard inner products. Define

$$
d_-(a)=(a,0)
$$

and

$$
d_+(u,v)=v.
$$

Then

$$
d_+d_-(a)=d_+(a,0)=0,
$$

so this is a cochain complex. Its exact subspace is

$$
E=\{(a,0):a\in\mathbb R\}=\operatorname{span}\{(1,0)\}.
$$

Its closed subspace is

$$
Z=\{(u,v):v=0\}=\operatorname{span}\{(1,0)\}.
$$

The orthogonal complement of $E$ is the second coordinate axis. Consequently,

$$
\mathcal H=Z\cap E^\perp=\{0\}.
$$

**Proposition 4.1 (Counterexample to unrestricted exact-plus-harmonic decomposition).** Not every cochain in $C$ is a sum of an exact cochain and a harmonic cochain.

**Proof sketch.** Consider $z=(0,1)$. It is not closed because $d_+z=1$. Every exact cochain has the form $(a,0)$, and the only harmonic cochain is $0$. Hence every exact-plus-harmonic sum has second coordinate $0$, whereas $z$ has second coordinate $1$.

The obstruction is structural. Every exact cochain is closed, and every harmonic cochain is closed, so every exact-plus-harmonic sum is closed. Therefore a nonclosed cochain can never possess such a decomposition. In this example the obstruction is visible as the second coordinate.

If adjoints are available, the expected full finite-dimensional statement has three summands:

$$
C=\operatorname{im}d_-\oplus\mathcal H\oplus\operatorname{im}d_+^*.
$$

The third subspace is coexact. For the coordinate example, $d_+^*(a)=(0,a)$, so $z=(0,1)$ is entirely coexact. Establishing the full statement requires additional analysis of adjoints and the Laplacian; it is not part of the two-summand theorem proved above.

## 5. Matrix and weighted formulations

Choose bases and write $D_-$ and $D_+$ for the matrices of the two coboundaries. The cochain condition is

$$
D_+D_-=0.
$$

With the standard Euclidean inner product, harmonic vectors satisfy

$$
D_+h=0,
\qquad D_-^{\mathsf T}h=0.
$$

The first equation imposes closedness; the second expresses orthogonality to every column of $D_-$. Thus

$$
\mathcal H=\ker
\begin{bmatrix}
D_+\\
D_-^{\mathsf T}
\end{bmatrix}.
$$

For a weighted middle space, let $W_C$ be a symmetric positive-definite Gram matrix and define

$$
\langle u,v\rangle_{W_C}=u^{\mathsf T}W_Cv.
$$

Then $h$ is orthogonal to $\operatorname{im}D_-$ exactly when

$$
D_-^{\mathsf T}W_Ch=0.
$$

The weighted harmonic space is therefore

$$
\mathcal H_{W_C}=\ker D_+\cap\ker(D_-^{\mathsf T}W_C).
$$

Given a closed vector $x$, the exact part is the weighted least-squares projection $D_-p_*$, where $p_*$ minimizes

$$
\|x-D_-p\|_{W_C}^2
=(x-D_-p)^{\mathsf T}W_C(x-D_-p).
$$

The normal equations are

$$
D_-^{\mathsf T}W_CD_-p_*=D_-^{\mathsf T}W_Cx.
$$

The coefficient matrix may be singular when $D_-$ has a kernel. The projected vector $D_-p_*$ is nevertheless unique, although the potential $p_*$ need not be. A pseudoinverse or a rank-revealing factorization resolves this nonuniqueness safely.

## 6. Algorithms

### 6.1 Projection algorithm for a closed cochain

Given $D_-$, $D_+$, and a vector $x$, first compute the closure residual $r_c=D_+x$. If $\|r_c\|$ exceeds a tolerance scaled to the data, the two-summand theorem does not apply. If $x$ is closed, compute an orthonormal basis $Q$ for $\operatorname{im}D_-$ using a singular-value or rank-revealing QR decomposition. Then set

$$
e=QQ^{\mathsf T}x,
\qquad h=x-e.
$$

The diagnostic residuals are

$$
r_{\mathrm{sum}}=x-e-h,
\qquad r_{\mathrm{closed}}=D_+h,
\qquad r_{\mathrm{orth}}=Q^{\mathsf T}h.
$$

All three should be small relative to the input scale.

For $D_-\in\mathbb R^{m\times n}$, a dense singular-value decomposition costs $O(mn\min\{m,n\})$ operations. Once $Q$ is known, each projection costs $O(mr)$, where $r=\operatorname{rank}D_-$. Sparse QR or iterative least-squares methods exploit the sparse incidence structure of large complexes.

### 6.2 Harmonic basis algorithm

To compute all harmonic modes, form the stacked matrix

$$
A=
\begin{bmatrix}
D_+\\
D_-^{\mathsf T}
\end{bmatrix}
$$

in the unweighted case, or replace the lower block by $D_-^{\mathsf T}W_C$ in the weighted case. A basis for $\ker A$, obtained by singular-value decomposition, is a basis for $\mathcal H$. The number of singular values below a scale-aware threshold estimates $\dim\mathcal H$.

A useful independent check is

$$
\dim\mathcal H=\dim\ker D_+-\operatorname{rank}D_-.
$$

The identity follows from Corollary 3.4 and $\operatorname{im}D_-\subseteq\ker D_+$. Disagreement indicates a tolerance or conditioning problem.

### 6.3 Exact-perturbation invariance test

Given a closed $x$ and an arbitrary potential $p$, set $y=x+D_-p$. Decompose both vectors. The theorem predicts identical harmonic components. Numerically, one measures

$$
\frac{\|h_y-h_x\|}{1+\|h_x\|}.
$$

This experiment is both an illustration and an implementation test. It checks the cochain identity, projection routine, and harmonic invariance in one calculation.

## 7. Applications

### 7.1 Balanced weighted polyhedral complexes

A finite balanced weighted polyhedral complex provides a natural source of the abstract data. Oriented cells determine finite cochain spaces. Signed incidence numbers determine coboundaries, and incidence nilpotence gives $d_+d_-=0$. Positive cell weights determine inner products. In this setting Theorem 3.1 says that each closed tropical cochain separates into a locally generated exact part and a canonical harmonic part.

Balancing and weights carry geometric information, while the proof itself depends only on the resulting algebraic structure. This modularity is valuable: geometric constructions may vary, but once they produce the three stated ingredients, the same decomposition applies.

### 7.2 Networks and circulation

For a graph, a vertex potential induces edge differences. These gradient-like edge cochains are exact. Closedness is a compatibility condition determined by the next incidence map in the chosen complex. Harmonic edge cochains are orthogonal to all potential differences and therefore record circulation that cannot be removed by changing vertex potentials. Conductance weights modify the energy inner product and hence select the minimum-energy representative.

### 7.3 Sensor calibration and data reconciliation

Suppose measurements are stored on cells and potential offsets live one degree lower. Changing calibration adds an exact cochain. Theorem 3.5 states that such recalibration leaves the harmonic component invariant. Thus the harmonic component functions as a gauge-independent summary of the data, provided the measurements satisfy closedness. The closure residual $D_+x$ is a diagnostic for incompatibility or noise outside the model.

### 7.4 Meshes and discrete geometry

On a finite mesh, weighted cochains encode fluxes, circulations, or discrete differential data. Projecting a closed field onto exact cochains finds the closest potential-driven field, while the harmonic residual records topology-sensitive content. The dimension formula predicts how many independent residual modes can occur.

## 8. Discussion and limitations

The theorem is intentionally minimal. It does not require a Laplacian, elliptic regularity, compactness, or a complete theory of tropical superforms. It proves the exact statement supported by finite-dimensional Hilbert geometry: closed cochains split orthogonally into exact and harmonic parts.

Finite dimensionality ensures that the exact subspace is closed and that orthogonal projections exist. In an infinite-dimensional Hilbert complex, the image of a bounded operator need not be closed. One may then obtain a decomposition involving the closure $\overline{\operatorname{im}d_-}$ rather than the image itself, unless a closed-range hypothesis is imposed.

Positive definiteness is also essential for uniqueness arguments based on $\langle v,v\rangle=0\Rightarrow v=0$. Degenerate or indefinite pairings require a different formulation. In numerical work, extreme weights can make the Gram matrix ill-conditioned even though it remains mathematically positive definite.

Finally, the counterexample prevents a common conceptual error. The harmonic space lies inside the closed space, and the exact space does as well. Their sum can never contain a nonclosed cochain. A full decomposition of all cochains must account for closure defects, normally through the coexact image of an adjoint.

## 9. Future directions

The immediate next step is the full three-summand theorem with pairwise orthogonality and uniqueness. Define the degree-$k$ Laplacian by

$$
\Delta_k=d_{k-1}d_{k-1}^*+d_k^*d_k.
$$

Positivity should identify its kernel with

$$
\ker\Delta_k=\ker d_k\cap\ker d_{k-1}^*.
$$

This would connect the intrinsic harmonic definition used here to the conventional Laplacian definition and extend the decomposition from closed cochains to arbitrary cochains.

A second direction is a complete polyhedral realization: construct the cochain spaces from oriented cells of a finite balanced weighted complex, prove incidence nilpotence, and transport positive weights to Hilbert structures. A third is the bigraded theory of tropical $(p,q)$-forms with two differentials and bicomplex identities. Further work should package the harmonic representative as an explicit linear isomorphism from tropical cohomology to the harmonic subspace, specialize the construction to weighted graphs, and identify degree-zero harmonic functions on connected components.

For locally finite infinite complexes, the central analytic question is closed range. Without it, closure-of-range statements are the natural expectation. With suitable geometric and spectral hypotheses, stronger decompositions may survive after Hilbert completion.

## 10. Conclusion

For consecutive coboundary maps between finite-dimensional real inner-product spaces, the exact subspace lies inside the closed subspace. Orthogonal projection onto the exact subspace then yields a decomposition of every closed cochain into an exact term and a harmonic term. The decomposition is orthogonal and unique, and its harmonic term depends only on the cohomology class.

An explicit two-dimensional complex shows that closedness is indispensable: the nonclosed vector $(0,1)$ cannot be exact plus harmonic. This failure points directly to the coexact summand required for a decomposition of arbitrary cochains. The resulting picture is precise and computationally accessible: project closed data onto the exact range, retain the orthogonal residual as the canonical global signal, and use the closure defect to detect when a third component is necessary.

## Appendix A. A three-coordinate model with nontrivial cohomology

The two-dimensional counterexample has trivial harmonic space. A slightly larger model displays exact, harmonic, and nonclosed directions simultaneously. Let

$$
P=\mathbb R,\qquad C=\mathbb R^3,\qquad N=\mathbb R,
$$

with standard inner products, and define

$$
d_-(a)=(a,0,0),
\qquad
d_+(u,v,w)=w.
$$

The cochain identity holds because $d_+d_-(a)=0$. The exact, closed, and harmonic spaces are respectively

$$
E=\operatorname{span}\{(1,0,0)\},
$$

$$
Z=\operatorname{span}\{(1,0,0),(0,1,0)\},
$$

and

$$
\mathcal H=Z\cap E^\perp=\operatorname{span}\{(0,1,0)\}.
$$

Every closed vector $x=(a,b,0)$ therefore has the explicit decomposition

$$
x=(a,0,0)+(0,b,0).
$$

The first summand is exact and the second is harmonic. The Pythagorean identity

$$
\|x\|^2=\|(a,0,0)\|^2+\|(0,b,0)\|^2
$$

makes orthogonality visible. If $t\in\mathbb R$, then the exact perturbation

$$
y=x+d_-(t)=(a+t,b,0)
$$

has harmonic component $(0,b,0)$, directly illustrating Theorem 3.5. A vector $(a,b,c)$ with $c\ne0$ is not closed. Its third coordinate is invisible to both $E$ and $\mathcal H$, and therefore witnesses the need for an additional summand when arbitrary cochains are considered.

This model also clarifies the dimension formula. Here $\dim Z=2$ and $\dim E=1$, so $\dim\mathcal H=1$. The quotient $Z/E$ records the second coordinate, and the harmonic representative realizes that quotient coordinate as the concrete vector $(0,b,0)$.

## Appendix B. Numerical tolerance and reproducibility

Exact linear identities become approximate in floating-point arithmetic. A robust implementation should scale every tolerance to matrix and vector norms. For example, closedness may be accepted when

$$
\|D_+x\|_2\le \tau\bigl(1+\|D_+\|_2\|x\|_2\bigr),
$$

where $\tau$ is chosen relative to machine precision and expected data error. Rank decisions in singular-value decomposition should similarly compare each singular value with the largest singular value, matrix dimensions, and a user-specified relative threshold.

The output should report rather than hide residuals. At minimum, record the cochain residual $\|D_+D_-\|$, the input closure residual $\|D_+x\|$, the reconstruction residual $\|x-e-h\|$, the harmonic closure residual $\|D_+h\|$, and the orthogonality residual $\|D_-^{\mathsf T}h\|$. In the weighted case, replace the final expression by $\|D_-^{\mathsf T}W_Ch\|$. These quantities distinguish mathematical failure of the hypotheses from ordinary numerical error.
