# Isometry and Scalar Extension for Quadratic Forms over Number Fields

**Aristotle**  
**27 July 2026**

## Abstract

This paper develops the elementary algebraic infrastructure underlying local–global questions for quadratic forms over number fields. We prove that anisotropy and isotropy are invariant under isometric equivalence. We then prove that isotropy ascends along every field extension when $2$ is invertible: if a quadratic form $Q$ over $K$ has a nonzero zero, then its scalar extension $Q_L$ over any extension $L/K$ also has a nonzero zero. Contrapositively, anisotropy of $Q_L$ implies anisotropy of $Q$. Since every number field has characteristic $0$, these conclusions apply uniformly to arbitrary number fields and all of their field extensions. The proofs are constructive at the level of witnesses: isometries transport zeros through an invertible linear map, while scalar extension transports $v$ to the pure tensor $1\otimes v$. We give matrix formulations, computational algorithms, examples, and a precise account of how these results form the forward half of a future Hasse–Minkowski framework. No converse local–global theorem is claimed here.

## 1. Introduction

Quadratic forms occupy a central position between linear algebra, arithmetic, and geometry. Given a field $K$ and a $K$-vector space $V$, a quadratic form is a degree-two function $Q:V\to K$. Its zero locus is a quadratic cone, and its arithmetic depends strongly on the field in which solutions are sought. The form

$$
Q(x,y)=x^2+y^2
$$

has no nonzero zero over $\mathbb Q$ or $\mathbb R$, but it has the nonzero zero $(1,i)$ over $\mathbb C$. Thus changing the field can change anisotropy into isotropy.

Two operations recur throughout the subject. The first is an invertible change of coordinates preserving the value of the form, called an isometry. The second is scalar extension from a field $K$ to a larger field $L$. Any robust classification theory must show that the existence of a nonzero zero behaves predictably under both operations.

This paper establishes four closely linked results.

1. Isometric quadratic forms are anisotropic simultaneously.
2. Equivalently, isometric quadratic forms are isotropic simultaneously.
3. Isotropy ascends along arbitrary field extensions when $2$ is invertible.
4. Contrapositively, anisotropy over the extension field descends to the base field.

For number fields the hypothesis on $2$ is automatic. Accordingly, if $K$ is any number field, $L/K$ any field extension, and $Q$ any quadratic form over $K$, then

$$
Q\text{ isotropic over }K\quad\Longrightarrow\quad Q_L\text{ isotropic over }L,
$$

and

$$
Q_L\text{ anisotropic over }L\quad\Longrightarrow\quad Q\text{ anisotropic over }K.
$$

These implications are elementary relative to the full Hasse–Minkowski theorem, but they are logically indispensable. In a local–global setting, each completion $K_v$ is a field extension of $K$, so every global zero induces a local zero. The difficult converse—that local isotropy at every place implies global isotropy—requires place theory, local classification, and arithmetic reciprocity. It is not established in this paper.

The emphasis here is therefore foundational and exact. We state the constructions without finite-dimensionality assumptions, prove that witness vectors remain nonzero, explain the matrix interpretation, and derive algorithms that illustrate the theory with rational and algebraic examples.

## 2. Algebraic preliminaries

### 2.1 Fields, vector spaces, and characteristic

Let $K$ be a field and $V$ a vector space over $K$. The condition that $2$ be invertible means that there exists an element $1/2\in K$ satisfying $2(1/2)=1$. This holds precisely when the characteristic of $K$ is not $2$. Every number field is a finite extension of $\mathbb Q$, hence has characteristic $0$, so the condition always holds for number fields.

The assumption is standard when quadratic forms are treated through their associated symmetric bilinear forms. The scalar-extension result below is stated in this setting.

### 2.2 Quadratic forms

**Definition 2.1 (Quadratic form).** A quadratic form on a $K$-vector space $V$ is a map $Q:V\to K$ such that

$$
Q(av)=a^2Q(v)
$$

for all $a\in K$ and $v\in V$, and whose polarization

$$
B_Q(u,v)=\frac{Q(u+v)-Q(u)-Q(v)}{2}
$$

is bilinear. In characteristic different from $2$, one recovers

$$
Q(v)=B_Q(v,v).
$$

When $V=K^n$, every quadratic form is represented by a symmetric matrix $A\in M_n(K)$ through

$$
Q(x)=x^{\mathsf T}Ax.
$$

The matrix depends on a basis, whereas the quadratic form does not.

**Definition 2.2 (Zero, isotropy, and anisotropy).** A vector $v\in V$ is a zero of $Q$ if $Q(v)=0$. The quadratic form is **isotropic** if there exists $v\in V$ such that

$$
v\ne 0\qquad\text{and}\qquad Q(v)=0.
$$

It is **anisotropic** if

$$
Q(v)=0\quad\Longrightarrow\quad v=0
$$

for every $v\in V$.

Thus isotropy is exactly the negation of anisotropy. No nondegeneracy or finite-dimensionality assumption is needed for these definitions.

### 2.3 Isometries

**Definition 2.3 (Isometry).** Let $Q:V\to K$ and $Q':W\to K$ be quadratic forms. An isometric equivalence is an invertible $K$-linear map $e:V\to W$ satisfying

$$
Q'(e(v))=Q(v)
$$

for every $v\in V$.

In coordinates, if $e$ is represented by an invertible matrix $P$ and the forms are represented by symmetric matrices $A$ and $A'$, then the isometry condition is

$$
A=P^{\mathsf T}A'P,
$$

or equivalently $A'=(P^{-1})^{\mathsf T}AP^{-1}$. If one defines a transformed form by $Q'(u)=Q(Pu)$, then its matrix is $P^{\mathsf T}AP$; the direction depends only on which map is designated as the isometry.

### 2.4 Scalar extension

Let $L/K$ be a field extension. The scalar extension of $V$ is

$$
V_L=L\otimes_K V.
$$

It is naturally an $L$-vector space. There is a canonical $K$-linear map

$$
\iota:V\longrightarrow V_L,\qquad v\longmapsto 1\otimes v.
$$

The scalar extension of $Q$ is a quadratic form

$$
Q_L:V_L\longrightarrow L
$$

characterized on pure tensors by

$$
Q_L(a\otimes v)=a^2Q(v),
$$

where $Q(v)$ is viewed in $L$ through the embedding $K\hookrightarrow L$. In particular,

$$
Q_L(1\otimes v)=Q(v).
$$

In finite-dimensional coordinates, $Q_L$ is represented by exactly the same coefficient matrix as $Q$, with entries now regarded as elements of $L$.

## 3. Invariance under isometry

We begin with the coordinate-invariance result.

**Theorem 3.1 (Isometry invariance of anisotropy).** Let $K$ be a field, let $V$ and $W$ be $K$-vector spaces, and let $Q$ and $Q'$ be quadratic forms on $V$ and $W$, respectively. If $e:V\to W$ is an isometric equivalence, then $Q$ is anisotropic if and only if $Q'$ is anisotropic.

**Proof sketch.** Suppose first that $Q$ is anisotropic. Let $w\in W$ satisfy $Q'(w)=0$. Since $e$ is surjective, $w=e(v)$ for $v=e^{-1}(w)$. The isometry identity yields

$$
Q(v)=Q'(e(v))=Q'(w)=0.
$$

Anisotropy of $Q$ gives $v=0$, so $w=e(v)=0$. Hence $Q'$ is anisotropic. Conversely, apply the same reasoning to the inverse linear equivalence $e^{-1}:W\to V$, which is also an isometry in the reverse direction. $\square$

**Corollary 3.2 (Isometry invariance of isotropy).** Under the hypotheses of Theorem 3.1, $Q$ is isotropic if and only if $Q'$ is isotropic.

**Proof sketch.** Isotropy is the logical negation of anisotropy, so the equivalence follows by negating both sides of Theorem 3.1. Equivalently, a nonzero zero $v$ of $Q$ is sent to the nonzero zero $e(v)$ of $Q'$, and a nonzero zero of $Q'$ is pulled back through $e^{-1}$. Invertibility ensures that nonzero vectors remain nonzero. $\square$

**Remark 3.3.** The theorem does not require $V$ or $W$ to be finite-dimensional, and it does not require the forms to be nondegenerate. It is a direct consequence of the definitions of isometry and anisotropy.

**Example 3.4.** Let

$$
Q(x,y,z)=x^2+y^2-z^2
$$

and let

$$
P=\begin{pmatrix}1&1&0\\0&1&0\\0&0&1\end{pmatrix}.
$$

Define $Q'(u)=Q(Pu)$. Since $P$ is invertible, $P$ gives an isometry from $Q'$ to $Q$. The vector $v=(3,4,5)$ satisfies $Q(v)=0$. Therefore $u=P^{-1}v=(-1,4,5)$ satisfies $Q'(u)=0$. The displayed witness changes, but isotropy does not.

## 4. Scalar extension and witness transport

The key mechanism for scalar extension is the canonical pure tensor $1\otimes v$.

**Lemma 4.1 (Nonvanishing of the canonical image).** Let $L/K$ be a field extension and $V$ a $K$-vector space. If $v\in V$ is nonzero, then $1\otimes v$ is nonzero in $L\otimes_K V$.

**Proof sketch.** Extend $v$ to a basis of $V$, or equivalently choose a $K$-linear functional $f:V\to K$ with $f(v)=1$. Scalar extension gives an $L$-linear map

$$
1\otimes f:L\otimes_K V\longrightarrow L\otimes_K K\cong L.
$$

It sends $1\otimes v$ to $1\otimes f(v)=1\otimes 1$, corresponding to $1\in L$. This is nonzero, so $1\otimes v$ cannot be zero. $\square$

This lemma is a manifestation of faithful flatness of field extensions, but the linear-functional proof requires no general commutative-algebra machinery.

**Theorem 4.2 (Isotropy ascends under scalar extension).** Let $K$ be a field in which $2$ is invertible, let $L/K$ be a field extension, let $V$ be a $K$-vector space, and let $Q:V\to K$ be a quadratic form. If $Q$ is isotropic over $K$, then $Q_L$ is isotropic over $L$.

**Proof sketch.** Choose $v\in V$ with $v\ne 0$ and $Q(v)=0$. Set

$$
w=1\otimes v\in L\otimes_K V.
$$

By Lemma 4.1, $w\ne 0$. By the defining property of scalar extension,

$$
Q_L(w)=Q_L(1\otimes v)=Q(v)=0.
$$

Thus $w$ is a nonzero zero of $Q_L$, proving isotropy. $\square$

**Theorem 4.3 (Anisotropy descends from a field extension).** Under the hypotheses of Theorem 4.2, if $Q_L$ is anisotropic over $L$, then $Q$ is anisotropic over $K$.

**Proof sketch.** This is the contrapositive of Theorem 4.2. If $Q$ were not anisotropic, it would be isotropic, and Theorem 4.2 would produce a nonzero zero of $Q_L$, contradicting the assumed anisotropy of $Q_L$. $\square$

The direction of these statements is essential. One cannot reverse Theorem 4.2 in general.

**Example 4.4 (Anisotropy need not ascend).** Over $K=\mathbb Q$, the form

$$
Q(x,y)=x^2+y^2
$$

is anisotropic. Indeed, if $x^2+y^2=0$ with rational $x$ and $y$, then viewing the equation over $\mathbb R$ shows $x=y=0$. Over $L=\mathbb Q(i)$, however,

$$
Q(1,i)=1+i^2=0,
$$

so $Q_L$ is isotropic.

**Example 4.5 (A witness that persists).** The form

$$
Q(x,y,z)=x^2+y^2-z^2
$$

is isotropic over $\mathbb Q$ because $Q(3,4,5)=0$. For every extension $L/\mathbb Q$, the same coordinate vector, interpreted in $L^3$, remains a nonzero zero. This is the finite-dimensional coordinate realization of $1\otimes(3,4,5)$.

## 5. Specialization to number fields

**Definition 5.1 (Number field).** A number field is a field $K$ that is finite-dimensional as a vector space over $\mathbb Q$.

Every number field has characteristic $0$. Consequently, $2\ne 0$ and is invertible in $K$.

**Theorem 5.2 (Number-field isotropy ascent).** Let $K$ be a number field, let $L/K$ be any field extension, let $V$ be a $K$-vector space, and let $Q$ be a quadratic form on $V$. If $Q$ is isotropic over $K$, then $Q_L$ is isotropic over $L$.

**Proof sketch.** Since $K$ has characteristic $0$, the element $2$ is invertible. Apply Theorem 4.2. $\square$

**Theorem 5.3 (Number-field anisotropy descent).** Under the hypotheses of Theorem 5.2, if $Q_L$ is anisotropic over $L$, then $Q$ is anisotropic over $K$.

**Proof sketch.** Apply Theorem 4.3, again using characteristic $0$. $\square$

These statements allow $L$ to be arbitrary. It may be a finite algebraic extension, an algebraic closure, or a completion of $K$ once a place and its completion are fixed.

### 5.1 Relation to the local–global problem

For each place $v$ of a number field $K$, let $K_v$ denote the corresponding completion. The canonical embedding $K\hookrightarrow K_v$ makes $K_v$ a field extension of $K$. Theorem 5.2 therefore gives the forward local implication

$$
Q\text{ isotropic over }K
\quad\Longrightarrow\quad
Q\text{ isotropic over }K_v\text{ for every place }v.
$$

The Hasse–Minkowski theorem asserts the converse for quadratic forms over number fields:

$$
Q\text{ isotropic over }K
\quad\Longleftrightarrow\quad
Q\text{ isotropic over }K_v\text{ for every place }v.
$$

Only the forward implication is derived here. The reverse implication is a genuinely arithmetic theorem. It requires a complete account of places and completions, local invariants, and reciprocity. Distinguishing the established scalar-extension direction from the unproved local–global converse prevents a common logical overreach: isotropy over one extension, or even over many selected extensions, does not by elementary algebra alone produce a global witness.

## 6. Algorithms and numerical demonstrations

The theorems suggest three practical procedures. They are demonstrations and diagnostic tools rather than complete decision procedures in unrestricted dimension.

### 6.1 Transporting a known isotropic witness

Given a matrix $A$ over $K$ and a nonzero vector $v$ satisfying $v^{\mathsf T}Av=0$, scalar extension requires no search.

**Algorithm 6.1 (Scalar-extension witness transport).** Input a symmetric matrix $A\in M_n(K)$, a nonzero vector $v\in K^n$ with $v^{\mathsf T}Av=0$, and an embedding $K\hookrightarrow L$. Map each coordinate of $v$ into $L$ and output the resulting vector $v_L\in L^n$.

Correctness follows because the polynomial expression defining $Q$ is preserved by the embedding:

$$
v_L^{\mathsf T}Av_L=0.
$$

The operation uses $O(n)$ field embeddings once the witness is known. If the zero equation is rechecked by dense matrix multiplication, the check costs $O(n^2)$ field operations.

### 6.2 Verifying an isometric coordinate change

**Algorithm 6.2 (Matrix congruence verification).** Given symmetric matrices $A,A'\in M_n(K)$ and an invertible matrix $P$, compute $P^{\mathsf T}A'P$ and test whether it equals $A$. If equality holds, $x\mapsto Px$ is an isometry from the form represented by $A$ to the form represented by $A'$.

With classical dense matrix multiplication, this costs $O(n^3)$ field operations. A zero $v$ of the first form can be transported to the other form by applying the appropriate inverse map, also in $O(n^3)$ time if a fresh matrix inversion is required, or $O(n^2)$ after factorization.

### 6.3 Bounded rational witness search

**Algorithm 6.3 (Primitive bounded search).** For an integral symmetric matrix $A$ and bound $B$, enumerate integer vectors $v\in[-B,B]^n$, omit $0$, optionally retain only primitive vectors with coordinate gcd equal to $1$, and test $v^{\mathsf T}Av=0$.

The worst-case search examines $(2B+1)^n-1$ vectors and performs $O(n^2)$ arithmetic per vector. Finding a witness proves isotropy over $\mathbb Q$. Failure to find one proves only that no witness lies in the searched box; it is not generally a proof of anisotropy.

### 6.4 Examples

For $A=\operatorname{diag}(1,1,-1)$, the bounded search finds Pythagorean triples such as $(3,4,5)$. A shear coordinate change preserves the evaluated values exactly. For $A=\operatorname{diag}(1,1)$, no nonzero rational witness appears, but adjoining a square root of $-1$ produces $(1,i)$. Together these examples display both the permanence of existing zeros and the possibility that a larger field creates new ones.

## 7. Applications to classification

### 7.1 Basis-independent reasoning

Theorem 3.1 permits diagonalization and normal-form calculations without changing isotropy. If a form is simplified by a sequence of invertible congruences, the final representative and the original form have exactly the same isotropic behavior.

### 7.2 Certificates across fields

Theorem 5.3 turns anisotropy in a convenient extension into a certificate over the base field. This direction may at first appear counterintuitive because extensions usually add solutions. Precisely for that reason, if even the larger field has no nonzero zero, the smaller field cannot have one.

The converse certificate is witness-based: a global isotropic vector automatically certifies isotropy in every extension. This is computationally efficient because it avoids repeated solution searches.

### 7.3 Local screening

Suppose one seeks global isotropy over a number field $K$. If there is a place $v$ for which $Q$ is anisotropic over $K_v$, then $Q$ cannot be isotropic over $K$, by Theorem 5.3. Thus any single local obstruction rules out global isotropy. Establishing that the absence of all local obstructions is sufficient is the further content of Hasse–Minkowski.

### 7.4 Compatibility with arithmetic invariants

A mature classification of nondegenerate quadratic forms over number fields uses dimension, determinant or discriminant square class, signatures at real places, and local Hasse invariants. Isometry invariance ensures these data refer to the form rather than a chosen matrix. Scalar extension explains how the form is carried into each local field where the invariants are computed.

## 8. Scope and limitations

The established theorems are unconditional within their hypotheses, but their scope should be stated precisely.

First, scalar extension proves only that a particular existing witness survives. It does not characterize all new zeros over $L$. Second, isotropy over an extension does not imply isotropy over the base field; Example 4.4 supplies a counterexample. Third, the present arguments do not construct number-field places or completions. Fourth, they do not define or prove properties of local Hasse invariants. Fifth, they do not prove finite support, a product formula, or the reverse local–global implication.

These are not defects in the foundational results. Rather, they locate the exact boundary between functorial linear algebra and arithmetic reciprocity. The tensor $1\otimes v$ explains the easy direction. Producing a global $v$ from unrelated local witnesses is the hard direction.

## 9. Future research directions

A natural next step is **concrete completion ascent**: formulate the canonical map into every completion $K_v$ and prove directly that each nonzero global zero maps to a nonzero local zero. This specializes Theorem 5.2 to place-theoretic extensions while making the local objects explicit.

The central goal is **ternary local–global isotropy**: every nondegenerate ternary quadratic form over a number field should be isotropic globally if and only if it is isotropic over every archimedean and nonarchimedean completion.

For dimension two, one seeks **binary classification by square class**: two nondegenerate binary forms with equal discriminant square class and equal local Hasse invariants at every place should be isometric.

For arbitrary nondegenerate forms, **finite support of local Hasse invariants** should show that the invariant is nontrivial at only finitely many nonarchimedean places. This finiteness makes global products meaningful and reduces computation to finitely many exceptional places.

Finally, the **product formula** should assert that the product of all local Hasse invariants is $1$. Consequently, one local invariant is determined by all the others. Together, finite support and the product formula express the reciprocity constraint needed to assemble local classification data globally.

## 10. Conclusion

The behavior of quadratic forms under coordinate change and field extension is governed by two canonical transports. An isometry carries a vector through an invertible linear map and preserves the value of the form. Scalar extension carries a vector $v$ to $1\otimes v$ and preserves both its nonvanishing and its quadratic value. From these observations follow isometry invariance of anisotropy and isotropy, ascent of isotropy under field extension, and descent of anisotropy from the extension field.

For arbitrary number fields, characteristic $0$ makes these results automatic for every extension. They establish the global-to-extended direction required by any local–global theory and justify the use of convenient coordinates and larger fields in classification arguments. The reverse passage—from local witnesses at every completion to one global witness—remains the arithmetic frontier, where local invariants and reciprocity must enter.
## Acknowledgment of method

The presentation follows a deliberately witness-centered method. Rather than beginning with classification invariants, it asks what happens to an explicit vector under each canonical construction. This viewpoint separates three logically different tasks: transporting a known zero, detecting an obstruction, and reconstructing a global zero from local data. The first is solved by the results above, the second can often be approached through a single extension or completion, and the third requires the deeper reciprocity theory identified as future work. Keeping these tasks separate clarifies both the power and the limits of scalar extension.
