# Adjoint Selmer Vanishing and Infinitesimal Rigidity of Automorphic Galois Representations

**Aristotle**  
**July 15, 2026**

## Abstract

The vanishing of an adjoint Bloch--Kato Selmer group attached to a regular algebraic automorphic Galois representation has a precise deformation-theoretic meaning: the corresponding arithmetic deformation problem has no nonzero first-order tangent vectors. This paper isolates and develops the general linear-algebraic geometry of that conclusion. A deformation presentation over a field $K$ consists of a parameter space $V$, an obstruction space $W$, and a linearized relation map $R:V\to W$; its tangent space is $T=\ker R$, and it is rigid when $T=0$. We prove that rigidity is equivalent to injectivity of $R$, is reflected by a rigid composite, is invariant under linear equivalence of tangent realizations, and excludes every admissible infinitesimal family. If an adjoint Selmer space $H^1_f$ is identified with $T$, then Selmer vanishing is equivalent to rigidity. Rigidity is preserved by arbitrary extension of coefficient fields. For finite-dimensional square presentations it is also equivalent to surjectivity and full rank. Finally, negate-and-reverse contragredient duality preserves and reflects zero algebraic-weight variation. These results organize the consequences of characteristic-zero adjoint Selmer vanishing without introducing a condition on an associated residual representation. We give matrix algorithms, examples, limitations, and applications to determinantal rigidity loci in arithmetic families.

## 1. Introduction

Let $F$ be a CM field and let an automorphic representation of a general linear group over $F$ be regular algebraic. The associated $p$-adic Galois representation carries an adjoint representation, whose Bloch--Kato Selmer group $H^1_f$ measures global cohomology classes satisfying prescribed local conditions. In the deformation-theoretic interpretation, these classes encode admissible first-order variations. Thus a theorem asserting

$$
H^1_f=0
$$

is not merely a numerical statement. It asserts infinitesimal rigidity at the relevant automorphic point.

The motivating arithmetic result proves such adjoint Selmer vanishing under conditions imposed on the characteristic-zero $p$-adic representation, rather than on an associated residual representation modulo $p$. The deep arithmetic construction of the Selmer group and its comparison with a deformation tangent space lie upstream of the present discussion. Our purpose is to state, prove, and computationally illustrate the geometric consequences that follow once that comparison and vanishing are available.

The unifying object is a linear presentation

$$
R:V\longrightarrow W,
$$

where $V$ is the space of infinitesimal parameters and $W$ is the space of linearized obstructions. The admissible tangent vectors form $\ker R$. This elementary model is broad enough to distinguish several logically different transport principles:

- zero tangent space is equivalent to injectivity of the relation map;
- a composite that detects every vector certifies rigidity before comparison;
- isomorphic tangent realizations have equivalent vanishing;
- a Selmer--tangent isomorphism identifies cohomological vanishing with geometric rigidity;
- rigid problems have no nonzero admissible infinitesimal families;
- flat scalar extension preserves rigidity;
- in a square finite-dimensional problem, rigidity is equivalent to surjectivity and full rank;
- contragredient duality preserves and reflects zero weight variation.

These principles are instances of conservativity: the relevant operation does not turn a nonzero vector into an undetectable one, or else is invertible and therefore reflects zero. They also clarify the boundary of the conclusions. A non-injective comparison may hide motion, dimension equality is essential to infer surjectivity from injectivity, and first-order rigidity alone does not settle higher derived deformation theory.

## 2. Arithmetic and deformation-theoretic setting

A **CM field** is a totally imaginary quadratic extension of a totally real number field. A regular algebraic automorphic representation of $\mathrm{GL}_n$ over a CM field has distinct algebraic weight data at each relevant embedding and is expected, under standard hypotheses, to determine a continuous $p$-adic Galois representation

$$
\rho:G_F\longrightarrow \mathrm{GL}_n(E),
$$

where $E$ is a finite extension of $\mathbb{Q}_p$. Its adjoint representation acts on endomorphisms by conjugation:

$$
\operatorname{Ad}(\rho)(g)(X)=\rho(g)X\rho(g)^{-1}.
$$

Depending on the deformation problem, one often removes the scalar direction and works with the trace-zero adjoint representation. The linear-algebraic conclusions below do not depend on that choice; they begin once an adjoint Selmer space has been specified.

The **Bloch--Kato Selmer group** $H^1_f(F,\operatorname{Ad}(\rho))$ is the subspace of global degree-one Galois cohomology classes whose local restrictions satisfy finite, or geometrically admissible, conditions. Away from $p$ these conditions encode controlled ramification; at places above $p$ they encode the chosen $p$-adic Hodge-theoretic behavior. We abbreviate the resulting coefficient-field vector space by $S$.

A deformation functor assigns to a small coefficient algebra the set of lifts of $\rho$ satisfying fixed global and local conditions. Evaluating at the dual numbers $K[\varepsilon]/(\varepsilon^2)$ yields its first-order deformations. Linearizing the defining conditions produces the model developed next.

## 3. Linear deformation presentations

### Definition 3.1: Deformation presentation

Let $K$ be a field. A **linear deformation presentation** over $K$ is a triple $(V,W,R)$ consisting of $K$-vector spaces $V$ and $W$ and a $K$-linear map

$$
R:V\longrightarrow W.
$$

The space $V$ is the parameter space, $W$ is the obstruction space, and $R$ is the linearized relation map.

### Definition 3.2: Tangent space and rigidity

The **tangent space** of $(V,W,R)$ is

$$
T_R=\ker R=\{v\in V:R(v)=0\}.
$$

The presentation is **rigid** if

$$
T_R=\{0\}.
$$

A vector in $T_R$ is an infinitesimal parameter variation satisfying every linearized condition. The definition is structural: it requires equality with the zero subspace, not merely a heuristic dimension count.

### Theorem 3.3: Kernel--injectivity criterion

A linear deformation presentation $(V,W,R)$ is rigid if and only if $R$ is injective.

**Proof.** By definition, rigidity means $\ker R=\{0\}$. A linear map has zero kernel exactly when $R(v)=R(v')$ implies $R(v-v')=0$ and hence $v-v'=0$. This is precisely injectivity. $\square$

This equivalence is the basic dictionary: arithmetic rigidity is a full-column-rank condition on the Jacobian of the global and local constraints.

## 4. Conservative comparison principles

The same tangent problem may be viewed through several obstruction theories. We first record when a downstream comparison can certify the original rigidity.

### Theorem 4.1: Rigidity reflected by composition

Let $V,W,X$ be $K$-vector spaces and let

$$
V\xrightarrow{R}W\xrightarrow{C}X
$$

be linear maps. If $\ker(C\circ R)=\{0\}$, then $\ker R=\{0\}$.

**Proof.** If $v\in\ker R$, then $R(v)=0$, and therefore $(C\circ R)(v)=C(0)=0$. The assumed triviality of the composite kernel forces $v=0$. $\square$

No injectivity hypothesis on $C$ is needed because injectivity of the composite is already assumed. The converse generally fails: take an injective $R$ and the zero map $C$.

### Theorem 4.2: Invariance under tangent equivalence

Let $T_1$ and $T_2$ be $K$-vector spaces and suppose there is a linear isomorphism

$$
\Phi:T_1\overset{\sim}{\longrightarrow}T_2.
$$

Then $T_1=\{0\}$ if and only if $T_2=\{0\}$.

**Proof.** If $T_1=0$, surjectivity of $\Phi$ writes every $t_2\in T_2$ as $\Phi(t_1)$, and $t_1=0$, so $t_2=0$. Conversely, if $T_2=0$, then $\Phi(t_1)=0$ for every $t_1$, and injectivity gives $t_1=0$. $\square$

Thus tangent-space vanishing is independent of coordinates and of any linearly equivalent realization.

## 5. Selmer vanishing as geometric rigidity

We now formulate the bridge to adjoint Bloch--Kato theory.

### Definition 5.1: Selmer--tangent identification

Let $S$ be an adjoint Bloch--Kato Selmer space over $K$. A **Selmer--tangent identification** for a presentation $(V,W,R)$ is a linear isomorphism

$$
\Psi:S\overset{\sim}{\longrightarrow}T_R.
$$

Such an identification asserts that the globally and locally admissible adjoint cohomology classes are exactly the admissible first-order deformations.

### Theorem 5.2: Selmer vanishing from rigidity

If $(V,W,R)$ is rigid and $\Psi:S\overset{\sim}{\to}T_R$ is a Selmer--tangent identification, then $S=\{0\}$.

**Proof.** For $s\in S$, the vector $\Psi(s)$ lies in $T_R$. Rigidity makes it zero. Since $\Psi$ is injective, $s=0$. $\square$

### Theorem 5.3: Rigidity from Selmer vanishing

If $S=\{0\}$ and $\Psi:S\overset{\sim}{\to}T_R$ is a Selmer--tangent identification, then $(V,W,R)$ is rigid.

**Proof.** Let $v\in T_R$. Surjectivity supplies $s\in S$ with $\Psi(s)=v$. The hypothesis gives $s=0$, and hence $v=0$. Thus $T_R=0$. $\square$

### Corollary 5.4: Selmer--rigidity equivalence

Under a Selmer--tangent identification,

$$
S=\{0\}\quad\Longleftrightarrow\quad T_R=\{0\}.
$$

This equivalence is stronger than equality of dimensions. It transports actual vanishing through a canonical or constructed linear equivalence. In the regular algebraic automorphic setting, the arithmetic vanishing theorem therefore says that the corresponding constrained Galois representation has no nonzero admissible first-order deformation.

The structural deductions in this paper require only the characteristic-zero vector spaces and maps just described. Once the arithmetic input has established $S=0$ and $S\cong T_R$, no residual representation hypothesis is used in passing to rigidity, scalar extension, rank, or duality consequences.

## 6. Exclusion of infinitesimal families

An infinitesimal family may be indexed by an arbitrary set $I$. Its velocity field is a map $u:I\to V$, and it is admissible if every velocity satisfies the relations.

### Definition 6.1: Admissible infinitesimal family

For a presentation $(V,W,R)$, an **admissible infinitesimal family** is a collection $(u_i)_{i\in I}$ such that

$$
R(u_i)=0
$$

for every $i\in I$.

### Theorem 6.2: No nonzero infinitesimal family under rigidity

If $(V,W,R)$ is rigid, then every admissible infinitesimal family is identically zero:

$$
R(u_i)=0\text{ for all }i\quad\Longrightarrow\quad u_i=0\text{ for all }i.
$$

**Proof.** Each $u_i$ belongs to $\ker R=T_R$. Rigidity gives $T_R=0$. $\square$

For a differentiable one-parameter family $x(t)$ through the arithmetic point, $u=x'(0)$ is its velocity. If the family preserves all constraints to first order, then $R(u)=0$, so rigidity forces $x'(0)=0$. The theorem should not be overread: it excludes first-order motion, while a complete analysis of nilpotents or higher homotopies requires the full cotangent complex.

## 7. Stability under coefficient-field extension

Coefficient fields are routinely enlarged in arithmetic geometry. The appropriate algebraic operation is tensor product.

Let $L/K$ be a field extension. For $R:V\to W$, define the scalar-extended relation map

$$
R_L=1_L\otimes R:L\otimes_K V\longrightarrow L\otimes_K W,
$$

by $R_L(\ell\otimes v)=\ell\otimes R(v)$.

### Theorem 7.1: Preservation of rigidity by scalar extension

If $R$ is injective, then $R_L$ is injective. Equivalently, a rigid deformation presentation over $K$ remains rigid after extension to $L$.

**Proof sketch.** Every vector space over a field is flat, and in particular $L$ is a flat $K$-module. Tensoring the exact sequence

$$
0\longrightarrow V\xrightarrow{R}W
$$

with $L$ preserves exactness at the left. Hence

$$
0\longrightarrow L\otimes_KV\xrightarrow{R_L}L\otimes_KW
$$

is exact, so $R_L$ is injective. $\square$

In finite dimensions the same fact follows from minors: a nonzero maximal minor over $K$ remains nonzero in the extension field $L$. Flatness gives the result without a finite-dimensional assumption.

The field hypothesis matters. Tensoring with an arbitrary non-flat ring can destroy injectivity. For example, multiplication by an integer may be injective over $\mathbb{Z}$ but become zero after tensoring with a quotient in which that integer vanishes.

## 8. The square finite-dimensional criterion

Assume $V$ and $W$ are finite-dimensional over $K$ and

$$
\dim_KV=\dim_KW=n.
$$

### Theorem 8.1: Rigidity, surjectivity, and full rank

For $R:V\to W$ under the equal-dimension hypothesis, the following are equivalent:

1. the presentation is rigid;
2. $R$ is injective;
3. $R$ is surjective;
4. $\operatorname{rank}R=n$;
5. for any choices of bases, the square matrix $A$ of $R$ has $\det A\ne0$.

**Proof sketch.** Rigidity and injectivity are equivalent by Theorem 3.3. Rank--nullity gives

$$
\dim_KV=\dim_K\ker R+\dim_K\operatorname{im}R.
$$

Thus $\ker R=0$ exactly when $\dim_K\operatorname{im}R=n$. Since $W$ also has dimension $n$, this is equivalent to $\operatorname{im}R=W$. The matrix rank and determinant formulations are standard equivalent descriptions of invertibility. $\square$

Equal dimension is indispensable. The inclusion $K\hookrightarrow K^2$ is injective but not surjective, while the projection $K^2\to K$ is surjective but not injective.

### Corollary 8.2: Obstruction generation

In a square finite-dimensional presentation, rigidity is equivalent to every obstruction vector in $W$ being generated by the linearized relations; explicitly, for every $w\in W$ there exists $v\in V$ with $R(v)=w$.

This makes the rigidity criterion useful in algebraic families. If a matrix $A(z)$ depends algebraically on a parameter $z$, the rigid locus is the nonvanishing locus of its determinant in the square case. More generally, for an $m\times n$ matrix with $m\ge n$, rigidity is the locus where some $n\times n$ minor is nonzero. The non-rigid locus is cut out by all maximal minors and is therefore determinantal.

## 9. Contragredient symmetry of algebraic weights

Let a weight variation of length $n$ be a vector

$$
\delta\lambda=(a_1,\ldots,a_n)
$$

in a coefficient module. Define its **contragredient dual** by negate-and-reverse:

$$
(\delta\lambda)^\vee=(-a_n,\ldots,-a_1).
$$

### Lemma 9.1: Involutivity

For every variation $\delta\lambda$,

$$
((\delta\lambda)^\vee)^\vee=\delta\lambda.
$$

**Proof.** The first application reverses order and negates each entry. The second reverses the order again and applies a second negation, restoring every original entry. $\square$

### Theorem 9.2: Contragredient preservation and reflection of zero variation

For every algebraic-weight variation $\delta\lambda$,

$$
(\delta\lambda)^\vee=0\quad\Longleftrightarrow\quad\delta\lambda=0.
$$

**Proof.** If $\delta\lambda=0$, its dual is visibly zero. Conversely, if $(\delta\lambda)^\vee=0$, apply the dual operation and use Lemma 9.1 to obtain $\delta\lambda=0$. $\square$

At tangent level, the contragredient involution therefore preserves and reflects the absence of weight variation. A stronger arithmetic statement would identify entire Selmer or deformation complexes under contragredient duality; the theorem here supplies the exact elementary symmetry that such an identification must extend.

## 10. Algorithms

### 10.1 Exact rigidity test

For a rational matrix $A\in M_{m\times n}(\mathbb{Q})$, exact Gaussian elimination computes the rank without floating-point error.

**Algorithm.** Convert every entry to a reduced rational number. Scan columns from left to right. In each column, find a nonzero pivot at or below the current pivot row. Swap it into position, normalize the pivot to $1$, and eliminate that column from all other rows. The number of pivots is $\operatorname{rank}A$. The presentation is rigid exactly when the number of pivots is $n$.

The arithmetic operation count is $O(mn\min(m,n))$, which is $O(n^3)$ for square matrices. Bit complexity also depends on numerator and denominator growth.

### 10.2 Nullspace extraction

Reduced row-echelon form also produces a basis of $\ker A$. Mark nonpivot columns as free variables. For each free column, set its variable to $1$, all other free variables to $0$, and solve pivot variables from the reduced equations. A nonempty basis is an explicit certificate of non-rigidity; an empty basis certifies a zero tangent space.

### 10.3 Family and determinant scan

For a square polynomial matrix $A(t)$, compute $d(t)=\det A(t)$. Every parameter with $d(t)\ne0$ is rigid, while roots of $d$ are exactly the possible non-rigid points. In rectangular problems, replace the determinant by the collection of maximal minors. A numerical scan can illustrate the locus, but exact symbolic minors or exact ranks are required for a proof.

## 11. Numerical examples

### Example 11.1: A rigid rectangular presentation

Consider

$$
A=\begin{pmatrix}
1&2\\
0&3\\
4&-1
\end{pmatrix}.
$$

The upper $2\times2$ minor has determinant $3\ne0$, so $A$ has column rank $2$. Hence $\ker A=0$ and the presentation is rigid. Any family of velocities $u_i\in K^2$ satisfying $Au_i=0$ is identically zero. The same minor remains nonzero after every coefficient-field extension.

### Example 11.2: A non-rigid presentation

Let

$$
B=\begin{pmatrix}
1&2&3\\
2&4&6\\
-1&-2&-3
\end{pmatrix}.
$$

All rows are scalar multiples of the first, so $\operatorname{rank}B=1$ and the tangent space has dimension $2$. For instance,

$$
B\begin{pmatrix}-2\\1\\0\end{pmatrix}=0,
\qquad
B\begin{pmatrix}-3\\0\\1\end{pmatrix}=0.
$$

These vectors exhibit two independent infinitesimal motions.

### Example 11.3: A determinantal rigidity transition

Consider the family

$$
A(t)=\begin{pmatrix}1&t\\t&1\end{pmatrix}.
$$

Its determinant is

$$
\det A(t)=1-t^2.
$$

The presentation is rigid for $t\ne\pm1$. At $t=1$, the kernel is spanned by $(1,-1)$; at $t=-1$, it is spanned by $(1,1)$. The exceptional locus is the determinantal set $1-t^2=0$.

### Example 11.4: Contragredient weight variation

For

$$
\delta\lambda=(3,-1,4,0),
$$

one has

$$
(\delta\lambda)^\vee=(0,-4,1,-3),
$$

and dualizing again returns $(3,-1,4,0)$. Neither vector is zero. By contrast, the zero variation is fixed, and Theorem 9.2 says it is the only variation whose dual can be zero.

## 12. Applications and interpretation

### 12.1 Automorphic points as isolated first-order solutions

Under a Selmer--tangent identification, adjoint Bloch--Kato vanishing implies that the automorphic Galois representation is isolated with respect to the chosen deformation conditions at first order. This is the deformation-theoretic content of the vanishing theorem.

### 12.2 Changes of realization

Cohomological constructions often pass through comparison maps. Theorem 4.1 permits rigidity to be certified after a comparison when the entire composite is injective. Theorem 4.2 permits vanishing to move freely across genuine linear equivalences. These statements distinguish a mere map, which may lose information, from an equivalence, which reflects it.

### 12.3 Coefficient independence

Theorem 7.1 ensures that enlarging a characteristic-zero coefficient field cannot introduce tangent vectors. This permits coefficients to be enlarged for convenience without sacrificing an established rigidity statement.

### 12.4 Rigidity loci in families

Theorem 8.1 predicts a determinantal geometry for jumping loci. If relation maps vary coherently over an eigenvariety or another parameter space, failure of rigidity should occur where rank drops. Under suitable finite-presentation hypotheses, maximal minors define the exceptional locus scheme-theoretically.

### 12.5 Dual symmetry

Theorem 9.2 shows that the contragredient involution respects zero algebraic-weight variation. It motivates the expectation that contragredient symmetry extends from weight tangent spaces to complete arithmetic rigidity loci.

## 13. Limitations

The conclusions are exact but conditional on their stated hypotheses.

First, this framework begins with the arithmetic Selmer--tangent comparison and the relevant vanishing theorem; it does not reconstruct their deep automorphic and Galois-cohomological proof. Second, a composite comparison reflects rigidity only when the composite itself has zero kernel. A non-injective post-comparison can hide a nonzero response. Third, injectivity is equivalent to surjectivity only in equal finite dimensions. Fourth, scalar-extension stability uses flatness; arbitrary base change may fail. Fifth, zero tangent space is a first-order property and does not alone prove that a derived deformation ring is concentrated in degree zero. Finally, contragredient zero-variation symmetry is weaker than a perfect duality of Selmer complexes.

These limitations identify natural extensions rather than defects: derived obstruction theory, coherent families, integral base change, and duality of complexes.

## 14. Future directions

A first direction is **derived rigidity without residual adequacy**. One may conjecture that the derived global deformation ring at a regular algebraic automorphic point is concentrated in degree zero and formally étale under characteristic-zero local de Rham regularity and irreducibility assumptions, without adequacy or largeness assumptions on the residual representation. Adjoint Selmer vanishing supplies the degree-one input; higher obstruction groups in the cotangent complex test the stronger claim.

A second direction is **componentwise propagation**. In a characteristic-zero eigenvariety component containing regular noncritical classical points, vanishing on a Zariski-dense set should force generic vanishing, with a proper determinantal jumping locus. The full-rank criterion gives the local algebraic model for this expectation.

A third direction is **contragredient symmetry of rigidity strata**. The contragredient involution should preserve the scheme-theoretic rigidity locus and the multiplicities of non-rigid determinantal strata. This requires lifting negate-and-reverse weight symmetry to a perfect duality of deformation or Selmer complexes.

A fourth direction is **integral coefficient-field invariance**. Away from a finite exceptional set of primes, one expects flat extension of coefficient rings to preserve the Fitting ideal of an integral adjoint Selmer complex. The field-level injectivity theorem is the tangent-space shadow of this finer base-change statement.

## 15. Conclusion

Adjoint Bloch--Kato Selmer vanishing admits a concise geometric translation. A linearized arithmetic deformation problem is rigid precisely when its relation map is injective. Under a Selmer--tangent isomorphism, this is equivalent to Selmer vanishing and excludes every nonzero admissible infinitesimal family. The property survives coefficient-field extension and equivalent tangent realizations, is reflected by an injective composite, becomes surjectivity and full rank in square finite dimension, and is compatible with contragredient zero-variation symmetry.

The resulting picture turns a vanishing group into a geometric statement about an arithmetic point: all permitted first-order directions have been cut out, and this immobility remains visible across the natural operations used to study it.