# When a Quadratic Equation Changes Its Number System

## The geometry that survives a change of arithmetic

A circle drawn on paper does not care whether we describe its points with rational numbers, real numbers, or complex numbers. Yet the equation defining that circle cares very much. The equation

$$
x^2+y^2=1
$$

has many rational solutions, still more real solutions, and a vast complex solution set. By contrast,

$$
x^2+y^2=0
$$

has only the zero solution over the rational or real numbers, but gains nonzero solutions over the complex numbers, such as $(1,i)$. The geometry is recognizably the same, while the available arithmetic has changed.

This tension sits at the heart of the theory of quadratic forms. It also motivates one of the great local–global questions in number theory: can the existence of a solution over a number field be decided by looking at all of its completions, one place at a time? The full answer is the Hasse–Minkowski theorem. Before one can reach that global summit, however, two pieces of algebraic infrastructure must be completely secure. First, changing coordinates without changing the quadratic geometry must preserve whether nonzero zeros exist. Second, enlarging the field must carry every existing nonzero zero along with it.

The results developed here establish exactly those foundations, for arbitrary fields of characteristic different from $2$ and, in particular, for every algebraic number field. Their proofs expose a simple but powerful principle: a solution already present cannot be destroyed by either an invertible change of coordinates or an extension of scalars.

## Quadratic forms, isotropy, and anisotropy

Let $K$ be a field and let $V$ be a vector space over $K$. A quadratic form on $V$ is a function $Q:V\to K$ satisfying the scaling rule

$$
Q(av)=a^2Q(v)
$$

and arising from a symmetric bilinear law when the characteristic is not $2$. In coordinates, a familiar example is

$$
Q(x_1,\ldots,x_n)=\sum_{i,j}a_{ij}x_ix_j,
$$

where the matrix $A=(a_{ij})$ may be taken symmetric.

A vector $v$ is called a zero of $Q$ if $Q(v)=0$. The zero vector always qualifies, so the interesting question is whether there is a nonzero zero. The form is **isotropic** if some $v\ne 0$ satisfies $Q(v)=0$. It is **anisotropic** if $Q(v)=0$ forces $v=0$.

These words encode arithmetic geometry. Over the real numbers, $x^2+y^2$ is anisotropic because a sum of two squares can vanish only when both coordinates vanish. The form $x^2-y^2$ is isotropic because $(1,1)$ is a nonzero zero. Over the complex numbers, even $x^2+y^2$ becomes isotropic because $(1,i)$ lies on its zero locus.

This last example teaches the first essential lesson: anisotropy may disappear after the field is enlarged. The reverse behavior cannot occur. Once a nonzero zero exists, an extension of the field does not erase it.

## Coordinates should not decide geometry

Suppose $Q$ is a quadratic form on a $K$-vector space $V$, and $Q'$ is a quadratic form on another $K$-vector space $W$. An isometry between them is an invertible linear map $e:V\to W$ such that

$$
Q'(e(v))=Q(v)
$$

for every $v\in V$. This is the algebraic meaning of saying that the two formulas describe the same quadratic geometry in different coordinates.

The first main result is the **Isometry Invariance Theorem**:

> If two quadratic forms over the same field are related by a linear isometry, then one is anisotropic if and only if the other is anisotropic. Equivalently, one is isotropic if and only if the other is isotropic.

The proof is short enough to see directly. Assume $Q$ is anisotropic and let $w\in W$ satisfy $Q'(w)=0$. Because $e$ is invertible, write $w=e(v)$ with $v=e^{-1}(w)$. The isometry identity gives

$$
Q(v)=Q'(e(v))=Q'(w)=0.
$$

Anisotropy of $Q$ forces $v=0$, hence $w=e(0)=0$. Thus $Q'$ is anisotropic. Applying the same argument to the inverse isometry proves the converse.

This theorem is more than a consistency check. Classification theory constantly replaces a quadratic form by a diagonal or otherwise simpler representative. If a computation transforms a matrix $A$ by an invertible matrix $P$, the new matrix is

$$
A'=P^{\mathsf T}AP.
$$

The theorem guarantees that the search for nonzero zeros has not been altered. One may choose convenient coordinates without changing the answer.

## Enlarging the field

Now let $L$ be a field extension of $K$. Extending scalars replaces $V$ by the $L$-vector space

$$
V_L=L\otimes_K V.
$$

The quadratic form $Q$ acquires a corresponding scalar extension $Q_L$ on $V_L$. Concretely, if $Q$ is given by a matrix with entries in $K$, the same matrix can simply be read as having entries in $L$.

The second main result is the **Scalar-Extension Isotropy Theorem**:

> Let $K$ be a field in which $2$ is invertible, let $L/K$ be any field extension, and let $Q$ be a quadratic form over $K$. If $Q$ is isotropic over $K$, then its scalar extension $Q_L$ is isotropic over $L$.

Suppose $v\ne 0$ and $Q(v)=0$. The canonical image of $v$ in the enlarged space is

$$
1\otimes v\in L\otimes_K V.
$$

By the definition of scalar extension,

$$
Q_L(1\otimes v)=Q(v)=0.
$$

The only subtle point is ensuring that $1\otimes v$ remains nonzero. Because $K\to L$ is an injective map of fields, scalar extension is faithful: a nonzero vector cannot collapse under this canonical embedding. Therefore $1\otimes v$ is a nonzero zero of $Q_L$.

The contrapositive is equally useful and deserves its own name, the **Anisotropy Descent Theorem**:

> Under the same assumptions, if $Q_L$ is anisotropic over $L$, then $Q$ is anisotropic over $K$.

This does not say that anisotropy always survives extension; the example $x^2+y^2$ from the rationals to the complex numbers shows otherwise. It says that anisotropy found in a larger field is a decisive certificate of anisotropy in the smaller one.

## Why number fields matter

A number field is a finite extension of the rational numbers. Examples include the Gaussian rational field $\mathbb Q(i)$ and real quadratic fields such as $\mathbb Q(\sqrt{2})$. Every number field has characteristic $0$, so $2$ is automatically invertible. The scalar-extension theorems therefore apply without additional arithmetic restrictions.

The resulting number-field statement is broad:

> For every number field $K$, every field extension $L/K$, every $K$-vector space $V$, and every quadratic form $Q$ on $V$, isotropy over $K$ implies isotropy after extension to $L$. Conversely, anisotropy after extension to $L$ implies anisotropy over $K$.

This includes algebraic extensions, real and complex embeddings when available, and the completions that arise from absolute values. If a global vector solves the equation, its image solves every extended equation. Thus one half of any local–global principle is elementary but indispensable:

$$
\text{global isotropy}\quad\Longrightarrow\quad\text{isotropy after every scalar extension}.
$$

The difficult direction runs backward. A different local solution may exist in every completion, with no single global vector visible at first. The Hasse–Minkowski theorem says that for quadratic forms over number fields, those compatible local facts are enough: a nontrivial global zero exists if and only if a nontrivial zero exists over every completion. The present results supply the forward implication and the invariance principles needed to formulate the reverse implication cleanly; they do not by themselves prove that reverse implication.

## A computational window

Small numerical experiments make the structure tangible. Consider

$$
Q(x,y,z)=x^2+y^2-z^2.
$$

The vector $(3,4,5)$ is a nonzero rational zero. If the same coefficients are viewed in any larger field, the same vector remains a zero. If we change coordinates with an invertible matrix $P$ and define $Q'(u)=Q(Pu)$, then $P^{-1}(3,4,5)$ is a zero of $Q'$. The witness moves, but the geometric fact of isotropy does not.

Now consider

$$
R(x,y)=x^2+y^2.
$$

A bounded rational search finds no nonzero zero, in agreement with its anisotropy over $\mathbb Q$. After adjoining an element $i$ with $i^2=-1$, however, $(1,i)$ becomes a nonzero zero. This is not a failure of the theorem: isotropy ascends, while anisotropy need not.

These examples suggest practical algorithms. Matrix congruence checks verify that coordinate changes preserve values. Witness transport maps known zeros into extended fields. Bounded searches can discover isotropic vectors in low dimensions, though failure to find one is not generally a proof of anisotropy. For rigorous classification, one supplements such searches with algebraic invariants: dimension, discriminant square class, signatures at real places, and Hasse invariants.

## The road toward a local–global classification

The algebraic foundation points toward a larger program. One must construct the completions $K_v$ associated with all archimedean and nonarchimedean places $v$ of a number field $K$. One must understand nondegenerate forms locally and define their Hasse invariants. One must prove that only finitely many local invariants are nontrivial and that their product is $1$. Finally, reciprocity must bind the local data into a global classification.

Several concrete milestones emerge. For ternary nondegenerate forms, one seeks the equivalence between global isotropy and isotropy over every completion. For binary forms, one seeks classification by discriminant square class together with local Hasse invariants. For arbitrary nondegenerate forms, finite support and the product formula would show that all but finitely many local checks are automatic and that one local invariant is determined by the others.

The foundational theorems proved here are modest in appearance because their arguments follow the natural maps. Yet this is precisely their strength. An isometry cannot change whether a nonzero zero exists. A field extension cannot destroy a zero already present. These facts anchor every later passage between equations, coordinate systems, and arithmetic worlds. Before local information can be assembled into a global answer, one must know that the question itself survives the journey.