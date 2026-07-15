# When Arithmetic Objects Refuse to Move

## Rigidity, Selmer groups, and the geometry hidden inside number theory

Some of the most revealing questions in mathematics begin with an imagined motion. Take an object defined by many exact equations, nudge it by an infinitesimal amount, and ask whether the equations can still hold. A circle can move in the plane. A flexible linkage can bend. A generic crystal framework may be locked. The same distinction between flexibility and rigidity appears in arithmetic geometry, although the objects are not made of rods or curves. They are Galois representations: algebraic encodings of how polynomial equations respond to the symmetries of number fields.

For Galois representations arising from regular algebraic automorphic forms over CM fields, an important arithmetic theorem says that a certain adjoint Bloch--Kato Selmer group vanishes under suitable characteristic-zero local conditions. The notable feature is what is *not* required: the structural conclusions do not depend on imposing an auxiliary largeness condition on a reduction modulo a prime. This article explains the geometric meaning of that vanishing. Once the arithmetic input identifies the Selmer group with a tangent space, a suite of consequences follows from linear algebra: infinitesimal rigidity, invariance under changes of realization, stability under coefficient-field extension, a full-rank criterion, and symmetry under contragredient duality.

## A tangent space made from arithmetic

A tangent vector records a possible first-order motion. If a shape depends on parameters $x_1,\ldots,x_m$ and must satisfy constraints $F_1=\cdots=F_r=0$, then near a chosen solution the first-order constraints are governed by the Jacobian matrix. Writing a tentative velocity as $v$, admissibility means

$$
Jv=0.
$$

Thus the tangent space is the kernel of the linearized constraint map.

The same pattern is useful far beyond ordinary geometry. Let $K$ be a field, let $V$ be a $K$-vector space of infinitesimal parameters, let $W$ be a $K$-vector space of linearized obstructions, and let

$$
R:V\longrightarrow W
$$

be the relation map. The associated tangent space is

$$
T=\ker R=\{v\in V:R(v)=0\}.
$$

We call the deformation problem **rigid** when $T=\{0\}$. This does not say merely that the space of motions has dimension zero after a calculation. It says that every first-order candidate motion is literally zero.

In arithmetic geometry, $V$ packages possible infinitesimal changes of a Galois representation, while $W$ packages the failures of those changes to satisfy global and local conditions. The adjoint Bloch--Kato Selmer group $H^1_f$ measures the changes that survive every condition. When an arithmetic comparison supplies an isomorphism

$$
H^1_f\cong T,
$$

Selmer vanishing and geometric rigidity become two descriptions of the same phenomenon.

### Selmer--Tangent Rigidity Theorem

**Theorem.** Suppose the adjoint Bloch--Kato Selmer space $H^1_f$ is linearly isomorphic to the tangent space $T=\ker R$ of a deformation problem. Then

$$
H^1_f=\{0\}\quad\Longleftrightarrow\quad T=\{0\}.
$$

**Why it is true.** A linear isomorphism preserves and reflects the zero vector. If $T$ contains only zero, every Selmer class maps to zero and therefore was zero. Conversely, if the Selmer space is zero, every tangent vector has a Selmer preimage, which must vanish.

This simple argument is the hinge between deep arithmetic and transparent geometry. Constructing the comparison and proving arithmetic vanishing are the difficult number-theoretic steps. Once those are available, their geometric force is unmistakable.

## Five faces of immobility

The first reformulation is elementary but powerful.

### Kernel--Injectivity Criterion

**Theorem.** The deformation problem determined by $R:V\to W$ is rigid if and only if $R$ is injective.

Indeed, injectivity says exactly that $R(v)=0$ forces $v=0$. In other words, no nonzero parameter direction escapes detection by the constraints.

This criterion turns rigidity into an algorithm. Put bases on finite-dimensional $V$ and $W$, represent $R$ by a matrix $A$, and compute its rank. If $A$ has full column rank, the tangent space vanishes. If not, a basis of the nullspace explicitly displays the possible infinitesimal motions.

There is also a physical way to read the result. Imagine testing a structure with a bank of sensors. The vector $v$ is a potential motion and $R(v)$ is the sensor response. Rigidity means that only no motion produces no response. The sensor system is then injective.

### No-Infinitesimal-Families Theorem

**Theorem.** If $T=\{0\}$ and a family of velocities $v_i\in V$ satisfies $R(v_i)=0$ for every index $i$, then $v_i=0$ for every $i$.

The proof is immediate: each velocity lies in $T$. Yet the interpretation matters. There is no hidden one-parameter path through the arithmetic object whose initial velocity obeys all conditions. Every admissible infinitesimal family is stationary to first order.

The result is deliberately first-order. A zero tangent space is the signature of formal unramifiedness at the point, but stronger statements about all higher-order or derived deformations require additional obstruction theory. That distinction motivates one of the main future directions.

## Comparisons that do not lose rigidity

Arithmetic objects often have several realizations. One may compare global and local conditions, change a cohomological model, pass to a dual picture, or enlarge the coefficient field. A useful rigidity theory must survive such translations.

Suppose $R:V\to W$ is followed by another linear map $C:W\to X$. If the composite $C\circ R$ has zero kernel, then $R$ itself has zero kernel. For if $R(v)=0$, then $(C\circ R)(v)=0$, so $v=0$.

### Composite Detection Theorem

**Theorem.** If $\ker(C\circ R)=\{0\}$, then $\ker R=\{0\}$.

This says that a sufficiently discriminating downstream test can certify the original rigidity. Notice the direction: composing can discard information, so rigidity of $R$ does not by itself guarantee rigidity of $C\circ R$. But if even the composite detects every nonzero vector, the original relation map certainly does.

Likewise, if two tangent realizations $T_1$ and $T_2$ are linearly isomorphic, then $T_1=\{0\}$ if and only if $T_2=\{0\}$. Rigidity is therefore intrinsic, not an artifact of a chosen coordinate system or cohomological presentation.

## Enlarging the field without creating motion

Number theorists frequently enlarge coefficient fields so that eigenvalues or other algebraic quantities become available. It would be alarming if such an enlargement manufactured new infinitesimal deformations. Under field extension, it does not.

Let $L/K$ be a field extension. Extending scalars transforms $R$ into

$$
R_L:L\otimes_K V\longrightarrow L\otimes_K W.
$$

### Scalar-Extension Stability Theorem

**Theorem.** If $R$ is injective over $K$, then $R_L$ is injective over $L$. Consequently, rigidity over $K$ remains rigidity after extending coefficients to $L$.

The reason is flatness: every field extension is flat, and tensoring with a flat module preserves injections. In practical terms, changing the language of scalars does not create a vector that the old equations could not detect.

A tiny matrix example captures the idea. Consider

$$
A=\begin{pmatrix}1&2\\0&3\\4&-1\end{pmatrix}.
$$

Its two columns are independent over $\mathbb{Q}$, hence its kernel is zero. Reading the same matrix over $\mathbb{R}$ or $\mathbb{C}$ does not produce a new null vector. The entries have gained a larger ambient field, but the rank remains two.

## When rigidity becomes solvability

Suppose now that $V$ and $W$ are finite-dimensional and have equal dimension $n$. The matrix of $R$ is square. Then injectivity and surjectivity coincide.

### Square Full-Rank Criterion

**Theorem.** If $\dim_K V=\dim_K W<\infty$, then the following are equivalent:

1. $T=\ker R=\{0\}$;
2. $R$ is injective;
3. $R$ is surjective;
4. $R$ has rank $n$;
5. after choosing bases, $\det R\ne 0$.

The proof is rank--nullity. Since

$$
\dim_K V=\dim_K\ker R+\dim_K\operatorname{im}R,
$$

zero kernel is equivalent to image dimension $n$, which is equivalent to the image being all of $W$.

This criterion gives rigidity an obstruction-theoretic interpretation: in a square presentation, every obstruction direction is generated by the linearized relations precisely when there are no infinitesimal deformations. It also predicts how non-rigidity varies in families. If the entries of $R$ depend algebraically on parameters, rank drops where maximal minors vanish. The non-rigid locus is therefore expected to be determinantal rather than arbitrary.

## The mirror of contragredient duality

Regular algebraic automorphic data carry a natural contragredient operation. At the level of an $n$-tuple of algebraic weights

$$
\lambda=(\lambda_1,\ldots,\lambda_n),
$$

this duality reverses the order and changes signs:

$$
\lambda^\vee=(-\lambda_n,\ldots,-\lambda_1).
$$

Applying the operation twice returns the original weight. Therefore it preserves and reflects the zero variation.

### Contragredient Zero-Variation Theorem

**Theorem.** For every weight variation $\delta\lambda$,

$$
(\delta\lambda)^\vee=0\quad\Longleftrightarrow\quad\delta\lambda=0.
$$

**Proof sketch.** If $\delta\lambda=0$, reversing and negating still gives zero. Conversely, if the dual variation is zero, apply duality again. Involutivity gives $((\delta\lambda)^\vee)^\vee=\delta\lambda$, hence the original variation is zero.

This does not by itself establish a duality of complete Selmer complexes, but it identifies the exact symmetry expected of rigidity loci: the mirror operation should not turn a stationary arithmetic point into a moving one.

## What the structure reveals

The main lesson is a pattern of **conservativity**. An injective relation map detects vectors. A linear equivalence neither creates nor destroys zero. A composite known to be injective reflects injectivity backward. Flat scalar extension preserves it forward. An involutive duality reflects zero variation. Each operation respects the distinction between genuine motion and apparent motion.

That pattern clarifies why characteristic-zero hypotheses can be conceptually sufficient for the structural consequences discussed here. Once arithmetic has supplied a characteristic-zero tangent-space comparison and proved adjoint Selmer vanishing, the transport of rigidity uses only these conservative operations. No separate condition on a residual reduction enters the linear-algebraic deductions.

The limits are equally instructive. A non-injective comparison can conceal a tangent vector. A rank test gives surjectivity only when finite dimensions match. A zero first-order tangent space does not automatically settle every higher obstruction. Good hypotheses are not decoration; each protects a precise logical step.

## From a vanished group to a geometric landscape

A vanishing theorem can sound negative: a group is zero, so nothing is there. The geometric reading is far richer. Zero means an automorphic Galois representation is isolated against all admissible first-order perturbations. It means every infinitesimal arithmetic path has zero velocity. It means rigidity persists when coefficients are enlarged, is independent of equivalent tangent models, can be detected after a faithful comparison, and in square finite presentations is exactly a full-rank condition.

This perspective also points outward. In families of automorphic forms, one can study where the relation matrix loses rank and ask whether those exceptional points form determinantal strata. One can ask whether contragredient duality preserves those strata with multiplicity. One can replace the tangent space by a cotangent complex and ask whether first-order rigidity extends through every derived order. One can seek integral refinements in which not just vanishing but the Fitting ideal of the defect survives base change.

The arithmetic theorem supplies the still point. Linear algebra reveals the geometry around it.