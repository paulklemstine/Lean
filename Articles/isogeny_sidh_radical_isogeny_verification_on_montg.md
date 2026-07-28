# Folding Elliptic Curves: Radical Two-Isogenies in Montgomery Coordinates

## A two-to-one map hidden in a reciprocal

Modern public-key cryptography often begins with a geometric object that looks deceptively simple: a cubic curve. Over a field $K$, consider the Montgomery equation

$$
y^2=x^3+Ax^2+x.
$$

Its points can be added by a geometric law, turning the curve into a group. When $K$ is finite, this group is both computable and rich enough to support cryptographic constructions. Isogeny-based cryptography goes one step further. Instead of moving only among points on one curve, it moves among curves by special algebraic maps called *isogenies*. An isogeny respects point addition, has finite fibers, and carries the structure of one elliptic curve into another.

The map studied here is a particularly transparent degree-two quotient. Away from $x=0$, define

$$
X=x+x^{-1},\qquad Y=y(1-x^{-2}).
$$

These expressions compress a point on the original Montgomery curve into a point on the new cubic

$$
Y^2=X^3+AX^2-4X-4A.
$$

The formula is short, but it encodes three important ideas. First, it is correct over every field wherever the displayed inverses exist, not merely over a chosen numerical example. Second, it identifies exactly which inputs are folded together. Third, it interacts cleanly with the radical scaling used to normalize quadratic twists. Together these facts provide an algebraic core for reliable degree-two isogeny evaluation.

## Why inversion is the hidden symmetry

The first coordinate $X=x+x^{-1}$ cannot distinguish $x$ from its inverse, because

$$
x+x^{-1}=x^{-1}+(x^{-1})^{-1}.
$$

This is not an accidental symmetry. The companion transformation on the full affine point is

$$
(x,y)\longmapsto \left(x^{-1},-yx^{-2}\right).
$$

If $x\ne0$, both this transformed point and the original point produce exactly the same pair $(X,Y)$. Indeed, the new first coordinate is unchanged, while the second becomes

$$
(-yx^{-2})\left(1-(x^{-1})^{-2}\right)
=-yx^{-2}(1-x^2)
=y(1-x^{-2}).
$$

Thus the quotient behaves like a sheet of paper folded along an algebraic crease: two points related by reciprocal inversion land at one image. This is the characteristic behavior of a degree-two map.

Even better, there are no mysterious extra collisions in the nonzero affine domain. Suppose $x,z\ne0$. Then

$$
x+x^{-1}=z+z^{-1}
$$

holds if and only if either $x=z$ or $xz=1$. To see this, clear denominators and factor the result:

$$
(x-z)(xz-1)=0.
$$

Because a field has no zero divisors, one factor must vanish. Conversely, either alternative plainly gives equal quotient coordinates. This exact fiber classification says that the reciprocal symmetry accounts for every collision of the $X$-coordinate.

## The curve equation survives the fold

Why does the image satisfy the claimed cubic? Begin with a point obeying

$$
y^2=x^3+Ax^2+x
$$

and square the proposed ordinate:

$$
Y^2=y^2(1-x^{-2})^2.
$$

Substituting the original curve equation gives

$$
Y^2=(x^3+Ax^2+x)(1-x^{-2})^2.
$$

Expanding and regrouping in terms of $X=x+x^{-1}$ yields

$$
Y^2=X^3+AX^2-4X-4A.
$$

This identity is the affine correctness theorem for the quotient formula. The restriction $x\ne0$ is essential because the rational map has a pole at the point $(0,0)$. Geometrically, that point is the visible two-torsion point generating the kernel of the intended quotient; a complete projective treatment resolves the pole by including the point at infinity. The present affine result isolates everything that can be established directly from rational identities.

The target cubic has an unusually revealing factorization:

$$
X^3+AX^2-4X-4A=(X+A)(X-2)(X+2).
$$

Consequently, the three points

$$
(-A,0),\qquad (2,0),\qquad (-2,0)
$$

all lie on the target equation. Their zero ordinates mark visible two-torsion on a nonsingular elliptic curve.

There is also a direct explanation for the root $X=-A$. The nonzero two-torsion points of the source have $y=0$ and satisfy

$$
x^2+Ax+1=0.
$$

Dividing by nonzero $x$ gives $x+A+x^{-1}=0$, and hence

$$
x+x^{-1}=-A.
$$

So both nonzero roots of the source’s quadratic factor collapse to the target point $(-A,0)$, exactly as the reciprocal fiber description predicts.

## Where radicals enter

Cryptographic formulas do not always arrive in normalized Montgomery form. One frequently encounters a quadratic twist written as

$$
By^2=x^3+Ax^2+x.
$$

If a radical $r$ has been chosen with $r^2=B$, the scaling

$$
(x,y)\longmapsto(x,ry)
$$

converts the twisted equation to the normalized one. The proof is one line of algebra:

$$
(ry)^2=r^2y^2=By^2=x^3+Ax^2+x.
$$

When $r\ne0$, this normalization is injective: the $x$-coordinate is untouched, and multiplication by a nonzero field element cannot identify two distinct $y$-coordinates. This matters algorithmically. Normalization does not discard information before the quotient is evaluated.

Combining normalization with the degree-two formula gives an end-to-end pipeline. Given

$$
r^2=B,\qquad By^2=x^3+Ax^2+x,\qquad x\ne0,
$$

first set $y'=ry$, then compute

$$
X=x+x^{-1},\qquad Y=y'(1-x^{-2}).
$$

The output necessarily satisfies

$$
Y^2=X^3+AX^2-4X-4A.
$$

The computation uses one inversion for $x^{-1}$, a small fixed number of multiplications and additions, and no search over points. In a finite field, this means its cost is essentially constant per point, with inversion usually dominating.

## A small finite-field example

Take the prime field with $p=101$, choose $A=5$, and consider $x=3$. The right side of the source equation is

$$
3^3+5\cdot3^2+3=75\pmod {101}.
$$

One may select examples by scanning for an $x$ whose right side is a quadratic residue, then choosing a corresponding $y$. For every such point with $x\ne0$, modular inversion supplies $x^{-1}$ and the quotient formulas can be evaluated directly. A numerical program can check three things at once: the source equation, the target equation, and equality of the outputs from the two deck-related inputs.

The finite-field setting also makes the fiber theorem tangible. For every nonzero $x$, calculate $X=x+x^{-1}$. Grouping field elements by this value produces buckets of size one or two. A two-element bucket consists exactly of $x$ and $x^{-1}$; a one-element bucket occurs at a fixed point of inversion, where $x^2=1$. Thus an abstract quotient becomes a visible combinatorial pairing of field elements.

## From local formulas to chains of curves

Isogeny protocols rarely use a single edge. They navigate a graph whose vertices are curve classes and whose edges are low-degree isogenies. A useful abstract model lets a finite commutative group $G$ act freely and transitively on a finite set of curve classes $S$. “Transitive” means every class can be reached from every other; “free” means no nonidentity group element fixes a class.

A labeled step from $C$ to $D$ is valid when its label $a\in G$ satisfies

$$
a\cdot C=D.
$$

This simple definition has strong consequences. If $a$ carries $C$ to $D$ and $b$ carries $D$ to $E$, then the composite label $ba$ carries $C$ to $E$. Reversing a step replaces $a$ by $a^{-1}$. Most importantly, a valid label between fixed endpoints is unique: if both $a\cdot C=D$ and $b\cdot C=D$, freeness forces $a=b$. The endpoint pair therefore determines a unique connector in the acting group.

These laws turn long isogeny walks into algebra. Step labels multiply, reversal inverts them, and two purported labels for the same transition must agree. For cryptographic engineering, this separates two layers cleanly: explicit rational formulas evaluate local maps, while the group action accounts for global composition and uniqueness.

## Why these identities matter in practice

A cryptographic formula lives at the intersection of mathematics and engineering. The field may contain only finitely many elements, but an implementation must still cope with exceptional inputs, inversions, and alternate coordinate models. The condition $x\ne0$ identifies the exceptional affine location instead of hiding it. The fiber theorem explains exactly when duplicate-looking outputs are expected. The target factorization supplies immediate test points, and radical normalization separates square-root selection from ordinary point evaluation.

This separation also encourages modular design. A square-root routine can be assessed by checking $r^2=B$. A normalization routine can be assessed against $(ry)^2=x^3+Ax^2+x$. The quotient routine can be assessed against its target cubic. A chain layer can then multiply labels without reopening the coordinate algebra. Each stage has a short mathematical contract, and the stages fit together because the output statement of one is the input statement of the next.

The formulas are especially attractive over quadratic finite fields, where supersingular curves used in isogeny systems naturally live. Yet the proofs do not depend on enumeration or on a special prime: they are field identities. This universality is useful because the same derivation applies across parameter choices and field representations, provided the required inverses exist.

## What has—and has not—been established

The results here are deliberately affine and algebraic. They prove the target equation, full invariance under the reciprocal deck transformation, exact nonzero fibers of the quotient coordinate, visible target torsion, correctness and injectivity of radical normalization, correctness of the combined algorithm, and the composition, reversal, and uniqueness laws for labels in a free transitive commutative action.

A broader geometric program remains. One would like to extend the rational formula across its pole to smooth projective curves, prove that its kernel is precisely the identity together with $(0,0)$, construct the dual map, and show that the two directions compose to multiplication by two. Over quadratic finite fields, one also wants a direct account of supersingularity and point-count preservation. Those steps would connect the compact affine identities even more tightly to complete supersingular-isogeny systems.

Still, the central picture is already crisp. The reciprocal expression $x+x^{-1}$ folds a Montgomery curve along a two-sheeted symmetry. The ordinate correction $y(1-x^{-2})$ makes that fold respect a new cubic. A chosen square root normalizes twists without losing information. And group-action laws let local evaluations assemble into unambiguous chains. From a handful of field operations emerges a structured bridge between explicit elliptic-curve arithmetic and the global geometry used in isogeny cryptography.
