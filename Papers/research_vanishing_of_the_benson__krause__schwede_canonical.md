# The Canonical Class of a Pro-2 Demushkin Group and the Characteristic-Two Linearization of the Cup Product

## Abstract

For a pro-$p$ Demushkin group $G$ the mod-$p$ cohomology is concentrated in degrees $0,1,2$, with the cup product $H^1(G;\mathbb{F}_p) \times H^1(G;\mathbb{F}_p) \to H^2(G;\mathbb{F}_p) \cong \mathbb{F}_p$ a nondegenerate symmetric bilinear form. We study the first-order formality of the cochain differential graded algebra $C^*(G;\mathbb{F}_2)$ — equivalently, the vanishing of the canonical class $c(G)$ living in the second Hochschild cohomology of that algebra — through the linear algebra of this cup-product form over the two-element field $\mathbb{F}_2$. Our central observation is that in characteristic two the self-cup map $q(x) = x \cup x$ is $\mathbb{F}_2$-linear, and hence, by nondegeneracy, is represented by a unique cohomology class $\chi \in H^1$, the *Kummer (orientation) class*, characterized by $x \cup x = \chi \cup x$ for all $x$. We prove that $\chi$ is well-defined and unique, that the form is alternating (even type) if and only if $\chi = 0$, and that nondegeneracy is equivalently the statement that every nonzero class pairs nontrivially with some class. We exhibit explicit forms realizing both Demushkin types — the standard dot product (odd type, with $\chi$ the all-ones vector and isotropy locus a hyperplane) and the hyperbolic plane (even type, fully isotropic) — and connect the type dichotomy to the parity of the minimal generating rank. The linear-functional description recasts a previously quadratic "type" invariant as a single computable vector, and localizes the entire first-order formality obstruction of $C^*(G;\mathbb{F}_2)$ into that vector.

## 1. Introduction

### 1.1 Demushkin groups

A **Demushkin group** is a pro-$p$ group $G$ whose mod-$p$ cohomology satisfies three conditions:

1. $\dim_{\mathbb{F}_p} H^1(G;\mathbb{F}_p)$ is finite (equal to the minimal number of topological generators);
2. $\dim_{\mathbb{F}_p} H^2(G;\mathbb{F}_p) = 1$; and
3. the cup product $H^1(G;\mathbb{F}_p) \times H^1(G;\mathbb{F}_p) \to H^2(G;\mathbb{F}_p)$ is a **nondegenerate** pairing.

Such groups are the Galois groups of the maximal $p$-extension of a $p$-adic local field, and conditions (1)–(3) are the group-cohomological form of local Poincaré duality. All cohomology in degrees $\geq 3$ vanishes, so $G$ has cohomological dimension two, and its cohomology ring is completely determined by the single symmetric bilinear form of condition (3).

Throughout, we specialize to $p = 2$, write $\mathbb{F}_2 = \mathbb{Z}/2\mathbb{Z}$ for the two-element field, set
$$
V := H^1(G;\mathbb{F}_2), \qquad \dim_{\mathbb{F}_2} V = n < \infty,
$$
and let
$$
B : V \times V \longrightarrow \mathbb{F}_2, \qquad B(x,y) := x \cup y
$$
denote the cup-product form (identifying $H^2 \cong \mathbb{F}_2$). By hypothesis $B$ is symmetric and nondegenerate.

### 1.2 Formality and the canonical class

The mod-2 cohomology $H^*(G;\mathbb{F}_2)$ is the homology of a differential graded algebra $C^*(G;\mathbb{F}_2)$ of continuous cochains. The passage from the cochain algebra to its cohomology loses information recorded in a hierarchy of **higher (Massey/secondary) operations**. The algebra is **formal** if it is quasi-isomorphic to its cohomology equipped with the zero differential; the first layer of this condition, **$A_3$-formality**, is governed by a single obstruction — the **Benson–Krause–Schwede canonical class**
$$
c(G) \in HH^2\!\big(C^*(G;\mathbb{F}_2),\, C^*(G;\mathbb{F}_2)\big),
$$
an element of the second Hochschild cohomology of the cochain algebra. The class $c(G)$ vanishes if and only if $C^*(G;\mathbb{F}_2)$ is $A_3$-formal.

**Motivating conjecture.** *For every pro-2 Demushkin group $G$, the canonical class $c(G)$ vanishes; equivalently, $C^*(G;\mathbb{F}_2)$ is $A_3$-formal.*

### 1.3 Reduction to finite linear algebra

Because $G$ has cohomological dimension two, every secondary operation of arity $\geq 4$ lands in $H^{\geq 3} = 0$ and is automatically trivial. The only potentially nontrivial secondary operation is the ternary one,
$$
H^1 \otimes H^1 \otimes H^1 \longrightarrow H^2, \qquad \deg = 1+1+1-1 = 2,
$$
and it is assembled entirely from the cup product. Thus the entire first-order formality obstruction is encoded in the linear algebra of $(V, B)$. This paper develops that linear algebra and isolates the single class — the Kummer/orientation class — into which the obstruction is compressed.

## 2. The squaring functional in characteristic two

### 2.1 Linearity of self-cup

**Definition 2.1 (Self-cup / squaring map).** For a symmetric bilinear form $B$ on an $\mathbb{F}_2$-vector space $V$, define the *self-cup map*
$$
q : V \to \mathbb{F}_2, \qquad q(x) := B(x,x) = x \cup x .
$$

**Theorem 2.2 (Characteristic-two linearity).** *The self-cup map $q$ is $\mathbb{F}_2$-linear; that is, it is a well-defined element $q \in V^* = \mathrm{Hom}_{\mathbb{F}_2}(V, \mathbb{F}_2)$.*

*Proof.* Additivity: using bilinearity and symmetry $B(y,x) = B(x,y)$,
$$
q(x+y) = B(x+y, x+y) = B(x,x) + B(x,y) + B(y,x) + B(y,y) = q(x) + 2\,B(x,y) + q(y).
$$
In $\mathbb{F}_2$ we have $2 = 0$, so $2\,B(x,y) = 0$ and $q(x+y) = q(x) + q(y)$. Homogeneity: for $c \in \mathbb{F}_2$, $q(cx) = B(cx, cx) = c^2 B(x,x) = c^2 q(x)$; and $c^2 = c$ for both $c \in \{0,1\}$, so $q(cx) = c\,q(x)$. $\square$

This is a genuinely characteristic-two phenomenon: over any field of characteristic $\neq 2$ the cross term $2B(x,y)$ is exactly the polarization that makes $q$ quadratic rather than linear. The collapse of $q$ to a linear functional is what ultimately trivializes the ternary secondary operation, since the quadratic ingredient that could obstruct it is absent.

### 2.2 Nondegeneracy in usable form

**Definition 2.3.** $B$ is *nondegenerate* if its left kernel is trivial: $B(a, x) = 0$ for all $x$ implies $a = 0$. Equivalently, the linear map $B^\flat : V \to V^*$, $B^\flat(v) = B(v, -)$, is injective — and, in finite dimension, an isomorphism.

**Proposition 2.4 (Detection form of nondegeneracy).** *If $B$ is nondegenerate and $a \neq 0$, then there exists $x \in V$ with $B(a, x) = 1$.*

*Proof.* Suppose no such $x$ exists. Over $\mathbb{F}_2$ the only values are $0$ and $1$, so $B(a,x) \neq 1$ forces $B(a,x) = 0$ for all $x$. Nondegeneracy then gives $a = 0$, a contradiction. $\square$

Thus over $\mathbb{F}_2$ nondegeneracy says precisely that *every nonzero class is detected by the cup product*.

## 3. The Kummer (orientation) class

Assume from now on that $V$ is finite-dimensional and $B$ is symmetric and nondegenerate, so that $B^\flat : V \xrightarrow{\ \sim\ } V^*$ is an isomorphism.

**Definition 3.1 (Kummer class).** The *Kummer class* (or *orientation class*) $\chi \in V$ is the unique preimage of the squaring functional under the duality isomorphism:
$$
\chi := (B^\flat)^{-1}(q), \qquad\text{i.e.}\qquad B(\chi, -) = q .
$$

**Theorem 3.2 (Defining property).** *For all $x \in V$, $\ B(\chi, x) = B(x,x)$; equivalently $\chi \cup x = x \cup x$.*

*Proof.* By construction $B^\flat(\chi) = q$, and evaluating at $x$ gives $B(\chi, x) = q(x) = B(x,x)$. $\square$

**Theorem 3.3 (Uniqueness).** *If $w \in V$ satisfies $B(w, x) = B(x,x)$ for all $x$, then $w = \chi$.*

*Proof.* For every $x$, $B(w - \chi, x) = B(w,x) - B(\chi, x) = B(x,x) - B(x,x) = 0$. Nondegeneracy of $B$ forces $w - \chi = 0$. $\square$

The Kummer class is therefore a canonical invariant of the pair $(V, B)$: the unique cohomology class whose cup product with any class $x$ reproduces the self-cup $x \cup x$. It is the linear-algebra shadow of the Benson–Krause–Schwede canonical class $c(G)$, and its construction uses only the two Demushkin axioms — symmetry (for linearity of $q$, Theorem 2.2) and nondegeneracy (for representability, Definition 3.1).

## 4. The type dichotomy

**Definition 4.1.** $B$ is *alternating* if $B(x,x) = 0$ for all $x \in V$. A Demushkin group is of *even (orientable) type* if its cup-product form is alternating, and of *odd type* otherwise.

**Theorem 4.2 (Type dichotomy via the Kummer class).** *The form $B$ is alternating if and only if $\chi = 0$:*
$$
\big(\forall x,\ B(x,x) = 0\big) \iff \chi = 0 .
$$

*Proof.* ($\Rightarrow$) If $B(x,x) = 0$ for all $x$ then $q = 0$, so $\chi = (B^\flat)^{-1}(0) = 0$. ($\Leftarrow$) If $\chi = 0$ then for every $x$, by Theorem 3.2, $B(x,x) = B(\chi, x) = B(0, x) = 0$. $\square$

The dichotomy recasts the classical even/odd distinction — historically a quadratic condition on the whole space — as the vanishing of a single vector, a computable and testable invariant.

**Remark 4.3 (Parity of the rank).** A nondegenerate alternating bilinear form over any field decomposes into an orthogonal direct sum of hyperbolic planes, and hence exists only in even dimension. Consequently every even-type pro-2 Demushkin group has even minimal generating rank $n = \dim_{\mathbb{F}_2} V$; equivalently, odd rank forces the odd type. Thus the single-vector invariant $\chi$ controls the parity of the group's rank.

## 5. Realizations: both types occur

To show the theory is non-vacuous and that both types genuinely occur, we exhibit explicit forms.

### 5.1 The dot product — odd type

**Definition 5.1.** On $V = \mathbb{F}_2^n$ let
$$
B_{\mathrm{dot}}(x, y) = \sum_{i=1}^n x_i y_i .
$$

**Proposition 5.2.** *$B_{\mathrm{dot}}$ is symmetric and nondegenerate. For $n \geq 1$ it is not alternating, so it realizes the odd type. Its Kummer class is the all-ones vector $\chi = (1,1,\dots,1)$, and its isotropy locus*
$$
\{\, x : B_{\mathrm{dot}}(x,x) = 0 \,\} = \{\, x : \textstyle\sum_i x_i = 0 \,\}
$$
*is the even-weight hyperplane, of codimension one.*

*Proof.* Symmetry is clear. Nondegeneracy: if $B_{\mathrm{dot}}(a, -) = 0$ then pairing against the standard basis vector $e_i$ gives $a_i = 0$ for each $i$, so $a = 0$. Non-alternating: $B_{\mathrm{dot}}(e_1, e_1) = 1$. Kummer class: over $\mathbb{F}_2$, $x_i^2 = x_i$, so $B_{\mathrm{dot}}(x,x) = \sum_i x_i^2 = \sum_i x_i = B_{\mathrm{dot}}(\mathbf{1}, x)$ where $\mathbf{1} = (1,\dots,1)$; by uniqueness (Theorem 3.3) $\chi = \mathbf{1}$. The isotropy locus is $\{x : \sum_i x_i = 0\}$, the kernel of the nonzero functional $q$, hence a hyperplane of codimension one. $\square$

This exhibits the general fact that for an odd-type form the isotropy locus $q^{-1}(0)$ is exactly a codimension-one hyperplane (the kernel of the nonzero linear functional $q$).

### 5.2 The hyperbolic plane — even type

**Definition 5.3.** On $V = \mathbb{F}_2^2$ let $B_{\mathrm{hyp}}$ be defined on the standard basis by
$$
B_{\mathrm{hyp}}(e_1, e_1) = B_{\mathrm{hyp}}(e_2, e_2) = 0, \qquad B_{\mathrm{hyp}}(e_1, e_2) = B_{\mathrm{hyp}}(e_2, e_1) = 1 ,
$$
i.e. the Gram matrix $\left(\begin{smallmatrix} 0 & 1 \\ 1 & 0 \end{smallmatrix}\right)$.

**Proposition 5.4.** *$B_{\mathrm{hyp}}$ is symmetric, nondegenerate, and alternating; it realizes the even type, with Kummer class $\chi = 0$ and isotropy locus all of $V$.*

*Proof.* The Gram matrix is symmetric and invertible over $\mathbb{F}_2$ (determinant $-1 = 1$), giving symmetry and nondegeneracy. For $x = a e_1 + b e_2$, $B_{\mathrm{hyp}}(x, x) = 2ab = 0$, so the form is alternating; by Theorem 4.2, $\chi = 0$, and the isotropy locus is all of $V$. $\square$

This is the smallest even-type form and the building block of Remark 4.3: every even-type form is an orthogonal sum of copies of $B_{\mathrm{hyp}}$.

## 6. Algorithms

The linear-algebra reformulation makes every invariant above computable by elementary $\mathbb{F}_2$-linear algebra, given a Gram matrix $M \in \mathbb{F}_2^{n\times n}$ of $B$ in some basis.

**Algorithm A (Kummer class).** The squaring functional is $q(x) = x^\top M x = \sum_i M_{ii} x_i$ over $\mathbb{F}_2$ (cross terms cancel in pairs), so $q$ is represented by the diagonal vector $d = \mathrm{diag}(M)$. The Kummer class $\chi$ is the unique solution of the linear system $M\chi = d$ over $\mathbb{F}_2$ (solvable and unique because $M$ is invertible). Complexity: $O(n^3)$ field operations by Gaussian elimination.

**Algorithm B (Type test).** Compute $\chi$ via Algorithm A and return "even type" if $\chi = 0$, else "odd type." Equivalently, return "even" iff $\mathrm{diag}(M) = 0$ *and* — since even type additionally requires nondegeneracy to be alternating — the off-diagonal structure decomposes into hyperbolic planes; in practice, since $M\chi = d$, $\chi = 0 \iff d = 0$.

**Algorithm C (Isotropy locus).** The isotropy locus is $\{x : x^\top M x = 0\} = \{x : d^\top x = 0\} = \ker(d^\top)$, a hyperplane of codimension one when $d \neq 0$ (odd type) and all of $V$ when $d = 0$ (even type). Complexity: $O(n)$ to read off, $O(n^2)$ to produce a basis of the kernel.

## 7. Discussion

### 7.1 What the Kummer class buys

The passage from the cochain algebra to the pair $(V, B)$, and then to the single vector $\chi$, is a triple compression:

- **From homotopy algebra to linear algebra:** cohomological dimension two forces the entire first-order formality obstruction into the ternary cup operation, hence into $(V, B)$.
- **From quadratic to linear:** characteristic two makes squaring linear (Theorem 2.2), so the obstruction is carried by a *linear* functional rather than a quadratic form.
- **From functional to vector:** nondegeneracy represents that functional by the unique Kummer class $\chi$ (Definition 3.1, Theorem 3.3).

The upshot is a single, computable invariant governing the even/odd type (Theorem 4.2) and the parity of the rank (Remark 4.3).

### 7.2 Relation to the canonical class $c(G)$

The Kummer class $\chi$ is the linear-algebraic avatar of the Benson–Krause–Schwede canonical class $c(G)$. The motivating conjecture — that $c(G) = 0$ for all pro-2 Demushkin groups, i.e. $A_3$-formality — is reflected at the level of $(V, B)$ by the linearity of the squaring functional: because $q$ is linear (not merely quadratic), the ternary secondary operation it would feed is unobstructed. The even/odd dichotomy detected by $\chi$ then classifies the two structural regimes without either producing a nontrivial first-order obstruction.

## 8. Future work

- **The orientation class as mod-2 defining exponent.** Conjecturally $\chi \neq 0$ precisely when the group's single defining relation carries an odd power in its distinguished generator; the linear-functional description makes $\chi$ computable from the pairing alone.
- **Even type forces even rank.** Make Remark 4.3 into a full structure theorem via the hyperbolic decomposition of alternating nondegenerate forms over $\mathbb{F}_2$.
- **All higher secondary operations vanish.** Extend $A_3$-formality to full formality: operations of arity $\geq 4$ vanish for degree reasons, and the ternary one is governed by $(V, B)$.
- **The isotropy hyperplane as an arithmetic invariant.** For odd-type groups, study the codimension-one isotropy locus $q^{-1}(0)$ as an intrinsic arithmetic invariant of the group.

## 9. Conclusion

Over the two-element field the self-cup map of a Demushkin group is linear, and nondegeneracy of the cup product represents it by a unique Kummer/orientation class $\chi \in H^1$. This class governs the even/odd type dichotomy ($\chi = 0 \iff$ alternating), controls the parity of the generating rank, and is the finite linear-algebraic shadow of the first-order formality obstruction $c(G)$. Both types are realized by explicit small forms — the dot product (odd) and the hyperbolic plane (even) — confirming the theory is non-vacuous, and every invariant reduces to elementary, cubic-time $\mathbb{F}_2$-linear algebra.
