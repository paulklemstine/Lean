# Euler Bricks, the Diagonal Cone, and a Rational Cuboid Quadric

**Aristotle — August 2, 2026**

## Abstract

A perfect cuboid is a rectangular box with positive integer edges, integer face diagonals, and an integer space diagonal. Its existence remains unresolved. This paper develops a self-contained algebraic framework for the problem without assuming that a perfect cuboid exists. We verify that the classical box with edges $(44,117,240)$ is an Euler brick with face diagonals $(125,244,267)$, while its squared space diagonal $73225$ is strictly between $270^2$ and $271^2$. We prove that scaling preserves both Euler bricks and hypothetical perfect cuboids. For rational edge and diagonal data, we derive the exact diagonal-cone relation $a^2+b^2+c^2=2d^2$ and prove its converse under the three face equations. Normalizing by a nonzero edge maps the cuboid equations to the affine quadric $w^2=u^2+v^2-1$. We then give a two-parameter rational parametrization of this quadric and prove its completeness away from the base point $(1,0,0)$. The resulting description shows that rational points on the ambient quadric are not the main obstruction: a perfect cuboid must additionally satisfy three simultaneous rational-square conditions, which become explicit quartic Diophantine constraints in parameter space.

## 1. Introduction

Let a rectangular box have edge lengths $x,y,z$. Denote the face diagonals opposite the three coordinate pairs by $a,b,c$, and denote the space diagonal by $d$. The Pythagorean theorem gives

$$
a^2=x^2+y^2,
\qquad
b^2=x^2+z^2,
\qquad
c^2=y^2+z^2,
$$

and

$$
d^2=x^2+y^2+z^2.
$$

The perfect-cuboid problem asks whether these equations admit a solution in positive integers. The question is elementary to state but arithmetically severe: it requires four related sums of squares to be squares simultaneously.

A box whose edges and three face diagonals are integers is called an Euler brick. Many Euler bricks are known, but no known Euler brick has an integer space diagonal. Conversely, no impossibility theorem rules out all positive integer solutions.

This paper isolates three structural facts. First, the standard Euler brick $(44,117,240)$ is an exact, transparent near-miss. Second, the four diagonals satisfy a quadratic cone equation that is equivalent to the space-diagonal equation once the face equations are imposed. Third, after scale is removed, a key part of the cuboid system lies on a rational affine quadric admitting a complete two-parameter parametrization. These facts do not settle existence. They identify the remaining obstruction as a simultaneous-square problem on a rationally parametrized surface.

## 2. Definitions and basic equations

### 2.1 Squares, Euler bricks, and perfect cuboids

A nonnegative integer $n$ is a **perfect square** if there exists a nonnegative integer $k$ such that $n=k^2$.

An ordered triple $(x,y,z)$ of nonnegative integers is an **Euler brick** if each of

$$
x^2+y^2,
\qquad
x^2+z^2,
\qquad
 y^2+z^2
$$

is a perfect square. In the geometric problem the edges are required to be positive; allowing zero temporarily is convenient for purely algebraic scaling statements.

An ordered triple $(x,y,z)$ is a **perfect cuboid** if it is an Euler brick and

$$
x^2+y^2+z^2
$$

is also a perfect square. Equivalently, there exist integers $a,b,c,d$ satisfying all four Pythagorean equations above.

The equations are homogeneous of degree two. This homogeneity means that scale is secondary: multiplying all lengths by a common factor preserves every equation. The intrinsic problem concerns proportions, together with the arithmetic question of clearing denominators.

### 2.2 Rational form

It is useful to work over the rational numbers. Any integer solution is a rational solution, while a positive rational solution can be multiplied by a common denominator to produce an integer solution. Accordingly, the positive rational and positive integer existence problems are equivalent. Care is needed only to preserve nonzero and positivity conditions under scaling.

## 3. A classical near-miss

### Theorem 3.1 (The $(44,117,240)$ Euler brick)

The box with edge lengths $44$, $117$, and $240$ is an Euler brick. Its three face diagonals are $125$, $244$, and $267$.

#### Proof

Direct calculation gives

$$
44^2+117^2=1936+13689=15625=125^2,
$$

$$
44^2+240^2=1936+57600=59536=244^2,
$$

and

$$
117^2+240^2=13689+57600=71289=267^2.
$$

Thus all three face-diagonal squares are perfect squares. $\square$

### Lemma 3.2 (The integer $73225$ is not a square)

There is no nonnegative integer $k$ satisfying $k^2=73225$.

#### Proof

The consecutive squares around $73225$ are

$$
270^2=72900
$$

and

$$
271^2=73441.
$$

Hence

$$
270^2<73225<271^2.
$$

Since the square function is strictly increasing on nonnegative integers, no integer square lies strictly between these consecutive squares. $\square$

### Corollary 3.3 (A genuine near-miss)

The Euler brick $(44,117,240)$ is not a perfect cuboid.

#### Proof

Its squared space diagonal is

$$
44^2+117^2+240^2=73225,
$$

which is not a square by Lemma 3.2. $\square$

Numerically, its space diagonal is approximately $270.6004$. The proximity to $270$ or $271$ is not itself mathematically decisive; the strict interval between consecutive integer squares is.

## 4. Homogeneity and scaling

### Theorem 4.1 (Scaling Euler bricks)

If $(x,y,z)$ is an Euler brick and $k$ is a nonnegative integer, then $(kx,ky,kz)$ is an Euler brick. If the original face diagonals are $a,b,c$, then the scaled face diagonals are $ka,kb,kc$.

#### Proof

For the first face,

$$
(kx)^2+(ky)^2=k^2(x^2+y^2)=k^2a^2=(ka)^2.
$$

The same calculation applies to the other two faces. No positivity assumption on $k$ is required for the algebraic statement; $k=0$ gives a degenerate brick. $\square$

### Theorem 4.2 (Scaling perfect cuboids)

If $(x,y,z)$ is a perfect cuboid with space diagonal $d$, then $(kx,ky,kz)$ is a perfect cuboid with space diagonal $kd$ for every nonnegative integer $k$.

#### Proof

The face equations are preserved by Theorem 4.1, and

$$
(kx)^2+(ky)^2+(kz)^2
=k^2(x^2+y^2+z^2)
=k^2d^2
=(kd)^2.
$$

Thus the space diagonal remains integral. $\square$

These theorems imply that a single positive perfect cuboid would generate infinitely many by scaling. They also motivate a primitive reduction: one would like to divide a hypothetical cuboid by the greatest common divisor of its edges. Proving that all resulting diagonals remain integral requires a divisibility argument and is a natural next step.

## 5. The diagonal cone

The face and space diagonals satisfy a relation in which the edges disappear.

### Theorem 5.1 (Diagonal-Cone Theorem)

Let $x,y,z,a,b,c,d$ be rational numbers satisfying

$$
a^2=x^2+y^2,
\qquad
b^2=x^2+z^2,
\qquad
c^2=y^2+z^2,
$$

and

$$
d^2=x^2+y^2+z^2.
$$

Then

$$
a^2+b^2+c^2=2d^2.
$$

#### Proof

Adding the three face equations gives

$$
\begin{aligned}
a^2+b^2+c^2
&=(x^2+y^2)+(x^2+z^2)+(y^2+z^2)\\
&=2x^2+2y^2+2z^2\\
&=2(x^2+y^2+z^2)\\
&=2d^2.
\end{aligned}
$$

$\square$

The equation

$$
a^2+b^2+c^2=2d^2
$$

defines a quadratic cone in four-dimensional diagonal space. It provides a quick necessary condition on any candidate diagonal quadruple.

### Theorem 5.2 (Converse Diagonal-Cone Theorem)

Let $x,y,z,a,b,c,d$ be rational numbers satisfying the three face equations

$$
a^2=x^2+y^2,
\qquad
b^2=x^2+z^2,
\qquad
c^2=y^2+z^2.
$$

If in addition

$$
a^2+b^2+c^2=2d^2,
$$

then

$$
d^2=x^2+y^2+z^2.
$$

#### Proof

The sum of the face equations yields

$$
a^2+b^2+c^2=2(x^2+y^2+z^2).
$$

Comparing this with the cone equation gives

$$
2(x^2+y^2+z^2)=2d^2.
$$

Division by $2$ proves the claim. $\square$

Thus, conditional on the three face equations, the diagonal-cone equation is an exact replacement for the space-diagonal equation. It neither loses nor adds solutions.

## 6. Normalization and the cuboid quadric

Suppose $x\ne0$. Normalize two face diagonals and the space diagonal by defining

$$
u=\frac{a}{x},
\qquad
v=\frac{b}{x},
\qquad
w=\frac{d}{x}.
$$

### Definition 6.1 (Cuboid quadric)

The **cuboid quadric** is the affine surface over the rational numbers defined by

$$
w^2=u^2+v^2-1.
$$

### Theorem 6.2 (Normalization Theorem)

Let $x,y,z,a,b,d$ be rational numbers with $x\ne0$ and

$$
a^2=x^2+y^2,
\qquad
b^2=x^2+z^2,
\qquad
 d^2=x^2+y^2+z^2.
$$

Then the normalized point

$$
\left(\frac{a}{x},\frac{b}{x},\frac{d}{x}\right)
$$

lies on the cuboid quadric.

#### Proof

Divide each equation by $x^2$. Then

$$
u^2=1+\frac{y^2}{x^2},
\qquad
v^2=1+\frac{z^2}{x^2},
$$

and

$$
w^2=1+\frac{y^2}{x^2}+\frac{z^2}{x^2}.
$$

Consequently,

$$
u^2+v^2-1
=1+\frac{y^2}{x^2}+\frac{z^2}{x^2}
=w^2.
$$

$\square$

Normalization removes the common scale and moves the problem into the geometry of a rational surface. The point $(1,0,0)$ lies on this surface because $0^2=1^2+0^2-1$.

## 7. Rational parametrization

A quadric containing a rational point can often be parametrized by lines through that point. Here the construction is explicit.

Take a line through $(1,0,0)$ in the form

$$
(u,v,w)=(1+t,pt,qt),
$$

where $p,q$ are rational slopes and $t$ is the line parameter. Substitution into $w^2=u^2+v^2-1$ gives

$$
q^2t^2=(1+t)^2+p^2t^2-1.
$$

Expanding and collecting terms yields

$$
t\bigl(2+t(1+p^2-q^2)\bigr)=0.
$$

The root $t=0$ is the base point. If

$$
D=1+p^2-q^2\ne0,
$$

the second intersection occurs at

$$
t=-\frac{2}{D}.
$$

This gives the following theorem.

### Theorem 7.1 (Rational Parametrization Theorem)

For rational parameters $p,q$ satisfying $1+p^2-q^2\ne0$, define

$$
D=1+p^2-q^2,
$$

$$
u=\frac{p^2-q^2-1}{D},
\qquad
v=\frac{-2p}{D},
\qquad
w=\frac{-2q}{D}.
$$

Then $(u,v,w)$ lies on the cuboid quadric:

$$
w^2=u^2+v^2-1.
$$

#### Proof

The line-intersection derivation already proves the identity geometrically. It can also be checked algebraically. Multiplying the desired equation by $D^2$ reduces it to

$$
4q^2=(p^2-q^2-1)^2+4p^2-(1+p^2-q^2)^2.
$$

Expanding the two squares and cancelling like terms leaves $4q^2=4q^2$. $\square$

The exceptional condition $D=0$ is the tangent direction at the base point in this affine chart. It does not represent a missing ordinary second intersection.

### Example 7.2

Set $p=1$ and $q=\tfrac12$. Then $D=\tfrac74$, and

$$
u=-\frac17,
\qquad
v=-\frac87,
\qquad
w=-\frac47.
$$

Indeed,

$$
w^2=\frac{16}{49}
$$

and

$$
u^2+v^2-1
=\frac{1}{49}+\frac{64}{49}-1
=\frac{16}{49}.
$$

### Theorem 7.3 (Completeness away from the base point)

Let $(u,v,w)$ be a rational point on

$$
w^2=u^2+v^2-1
$$

with $u\ne1$. Define

$$
p=\frac{v}{u-1},
\qquad
q=\frac{w}{u-1}.
$$

Then $1+p^2-q^2\ne0$, and the formulas in Theorem 7.1 recover exactly the original point $(u,v,w)$.

#### Proof

Using the quadric equation,

$$
\begin{aligned}
1+p^2-q^2
&=1+\frac{v^2}{(u-1)^2}-\frac{w^2}{(u-1)^2}\\
&=\frac{(u-1)^2+v^2-w^2}{(u-1)^2}\\
&=\frac{(u-1)^2+v^2-(u^2+v^2-1)}{(u-1)^2}\\
&=\frac{-2(u-1)}{(u-1)^2}\\
&=-\frac{2}{u-1}.
\end{aligned}
$$

Since $u\ne1$, this denominator is defined and the result is nonzero. Also,

$$
p^2-q^2-1=-\frac{2u}{u-1}.
$$

Dividing this expression by $1+p^2-q^2=-2/(u-1)$ recovers $u$. Similarly,

$$
\frac{-2p}{1+p^2-q^2}
=
\frac{-2v/(u-1)}{-2/(u-1)}
=v,
$$

and the same calculation recovers $w$. $\square$

The theorem proves that the parametrization is surjective onto all rational points of the quadric except the chosen base point. The base point itself is already known explicitly.

## 8. The residual simultaneous-square conditions

The rationality of the quadric does not solve the perfect-cuboid problem. A normalized point must permit reconstruction of rational edge ratios. From

$$
u^2=1+\left(\frac{y}{x}\right)^2
$$

and

$$
v^2=1+\left(\frac{z}{x}\right)^2,
$$

we require

$$
u^2-1=r^2,
\qquad
v^2-1=s^2
$$

for rational numbers $r=y/x$ and $s=z/x$. The omitted face diagonal further requires

$$
\left(\frac{c}{x}\right)^2=r^2+s^2=u^2+v^2-2.
$$

Therefore the relevant normalized point must satisfy all three conditions

$$
u^2-1\in(\mathbb{Q}^{\times})^2,
\qquad
v^2-1\in(\mathbb{Q}^{\times})^2,
\qquad
u^2+v^2-2\in(\mathbb{Q}^{\times})^2,
$$

with signs and nonzero conditions chosen for a positive, nondegenerate cuboid. Here $(\mathbb{Q}^{\times})^2$ denotes the set of nonzero rational squares.

Substitution of the parametrization makes this explicit. With $D=1+p^2-q^2$,

$$
u^2-1
=
\frac{(p^2-q^2-1)^2-D^2}{D^2}
=
\frac{-4(p^2-q^2)}{D^2},
$$

while

$$
v^2-1
=
\frac{4p^2-D^2}{D^2}.
$$

The third condition is

$$
u^2+v^2-2
=
\frac{(p^2-q^2-1)^2+4p^2-2D^2}{D^2}.
$$

Since $D^2$ is already a square, the numerators must be rational squares up to the same explicit interpretation. Clearing denominators and adjoining auxiliary square-root variables produces an intersection of quartic equations. This is the concrete Diophantine core left by the rational-surface reduction.

The distinction is important. The ambient equation $w^2=u^2+v^2-1$ has a dense supply of rational points described by two free rational parameters. Perfect-cuboid candidates occupy a much thinner subset cut out by several simultaneous square requirements.

## 9. Algorithms and numerical exploration

Exact arithmetic is essential. Floating-point square roots can falsely classify large integers near squares, while rational roundoff can obscure exact identities.

### 9.1 Exact Euler-brick test

Given nonnegative integers $x,y,z$, compute

$$
S_1=x^2+y^2,
\qquad
S_2=x^2+z^2,
\qquad
S_3=y^2+z^2.
$$

For each $S_i$, compute the integer square root $r_i=\lfloor\sqrt{S_i}\rfloor$ and test whether $r_i^2=S_i$. The triple is an Euler brick exactly when all three tests pass. A perfect-cuboid test adds

$$
S_4=x^2+y^2+z^2
$$

and applies the same criterion. Integer square root algorithms run in time polynomial in the bit length of the input, and all comparisons are exact.

### 9.2 Exact parametrization test

Represent $p$ and $q$ as reduced rational numbers. Compute $D=1+p^2-q^2$. If $D=0$, report the tangent exception. Otherwise compute $u,v,w$ from Theorem 7.1 and verify the identity

$$
w^2-u^2-v^2+1=0
$$

using rational arithmetic. To recover parameters from a point with $u\ne1$, compute $p=v/(u-1)$ and $q=w/(u-1)$.

### 9.3 Bounded search

A direct bounded search orders positive triples, for example $1\le x\le y\le z\le B$, and applies the exact square tests. The naive search examines $O(B^3)$ triples. Filters based on parity, modular square residues, primitive gcd conditions, and precomputed Pythagorean pairs can reduce the practical cost. A finite search proves only nonexistence within its stated range; it cannot resolve the unbounded existence question.

## 10. Applications and interpretation

The diagonal cone provides a consistency relation for integer-distance geometry: any proposed collection of four cuboid diagonals failing $a^2+b^2+c^2=2d^2$ can be rejected before edge reconstruction. Conversely, satisfying the cone is enough to recover the space equation only when the three face equations are also present.

The normalization illustrates a general method in Diophantine geometry. Homogeneous equations are first quotiented by scale, a rational point is identified, and lines through that point parametrize a quadric. The remaining arithmetic is then transferred into parameter space, where congruences, factorization, descent, or the geometry of higher-degree curves may be applied.

Euler bricks also serve as useful test cases for exact-search software. The triple $(44,117,240)$ simultaneously checks successful recognition of three face squares and rejection of a nearly square space diagonal.

## 11. Discussion

The results establish a precise hierarchy:

1. Euler-brick conditions impose three Pythagorean equations.
2. The space equation is equivalent, under those conditions, to the diagonal-cone equation.
3. Normalization sends selected data to the rational quadric $w^2=u^2+v^2-1$.
4. Every rational point on that quadric, except the base point, is generated by rational parameters $p,q$.
5. Only points satisfying three additional simultaneous-square constraints correspond to full rational cuboid data.

This hierarchy explains why merely parametrizing the quadric cannot settle the problem. Rationality of an ambient variety is compatible with arithmetic scarcity on a subvariety or on a thin subset selected by square classes.

The near-miss $(44,117,240)$ further cautions against numerical intuition. Three exact integral diagonals do not force the fourth, and a squared length close to a square is arithmetically no better than any other nonsquare.

## 12. A worked parameter-space analysis

It is useful to see how the parametrization reorganizes a concrete calculation. Choose rational slopes $p=1$ and $q=\tfrac12$. As above, the denominator is $D=\tfrac74$, and the quadric point is

$$
(u,v,w)=\left(-\frac17,-\frac87,-\frac47\right).
$$

The quadric identity holds exactly, but the first edge-recovery expression is

$$
u^2-1=\frac{1}{49}-1=-\frac{48}{49}.
$$

It is negative and therefore cannot equal the square of a rational edge ratio. This point is immediately discarded. The example illustrates that the parametrization covers the entire algebraic surface, including regions with no real positive cuboid interpretation.

Now consider the filters in their natural order. Given $p,q\in\mathbb{Q}$, first reject the tangent case $D=0$. Second, compute $u$ and $v$ and require $u^2\ge1$ and $v^2\ge1$; otherwise real edge ratios cannot exist. Third, apply exact rational-square tests to $u^2-1$ and $v^2-1$. A rational number $A/B$ in lowest terms with $A,B>0$ is a rational square exactly when both $A$ and $B$ are integer squares. Finally, test $u^2+v^2-2$. Only after all three tests pass does one reconstruct rational edge and face-diagonal ratios and clear denominators.

This ordering is mathematically lossless and computationally economical. Sign tests are cheaper than square tests, and the parametrization ensures the space relation from the outset. Nevertheless, enumeration by bounded numerator and denominator is subtle: the same point may be represented by different unreduced inputs, and a height bound on $p,q$ is not identical to a height bound on the resulting cuboid. Any reported finite search must therefore state exactly which parameter or edge region it covers.

### 12.1 Relation between normalized and integral solutions

Suppose a normalized point passes all square tests, so that there exist positive rationals $r,s,t$ with

$$
r^2=u^2-1,
\qquad
s^2=v^2-1,
\qquad
t^2=u^2+v^2-2.
$$

Choose a positive integer $L$ divisible by the denominators of $r,s,u,v,w,t$. Define

$$
x=L,
\qquad
y=Lr,
\qquad
z=Ls,
$$

and

$$
a=Lu,
\qquad
b=Lv,
\qquad
c=Lt,
\qquad
d=Lw,
$$

replacing signs of diagonal ratios by their absolute values where necessary. Every quantity is then integral. Multiplying the normalized identities by $L^2$ proves all four cuboid equations. Hence the simultaneous rational-square conditions, together with positivity and nondegeneracy, are not merely necessary; they are sufficient to produce an integer perfect cuboid after clearing denominators.

This establishes the exact conceptual endpoint of the reduction. The unresolved existence question can be transferred from seven positive integers to rational parameters $p,q$ plus three rational square roots. The transfer does not reduce the logical strength of the problem, but it exposes a smaller and more structured arena for arithmetic analysis.

### 12.2 Symmetry and duplication

Permuting $x,y,z$ preserves the cuboid property but changes the chosen normalization and therefore changes $(u,v,w)$ and its slope parameters. Sign changes of diagonals also leave squared equations invariant. Consequently, parameter-space searches contain natural symmetries and duplicate representations. Selecting positive edges, ordering them as $x\le y\le z$, reducing rational parameters, and fixing diagonal signs can remove many duplicates. A complete symmetry quotient requires care because the chart singles out $x$ and the base point $(1,0,0)$.

## 13. Future work

The most immediate task is to introduce auxiliary variables for the square roots of $u^2-1$, $v^2-1$, and $u^2+v^2-2$, substitute the rational parametrization, and clear denominators. The resulting quartic system would give an explicit parameter-space model suitable for factorization, descent, and local-solubility analysis.

A second objective is primitive reduction. One should prove that the greatest common divisor of the edges of a positive perfect cuboid divides every face diagonal and the space diagonal. Division by this common factor would restrict both theory and search to primitive tuples.

Third, square residues modulo $4$, $8$, $16$, $3$, and $5$ can impose parity and divisibility constraints. Such restrictions can prune searches and may organize the quartic parameter space into impossible congruence classes.

Fourth, exact bounded searches should separate the correctness of the integer-square checker from the chosen numerical bound. This yields reusable evidence with a precisely delimited conclusion.

Finally, parametric families of Euler bricks deserve systematic treatment. For each family, the squared space diagonal becomes a polynomial or rational function of the family parameters. Determining when that expression is square may lead to curves whose arithmetic can be studied independently.

## 14. Conclusion

The perfect-cuboid problem remains open, but its algebraic structure can be made explicit. The classical brick $(44,117,240)$ has three integral face diagonals and a provably nonintegral space diagonal. Scaling preserves all relevant properties. The diagonals of any rational perfect cuboid lie on the exact cone $a^2+b^2+c^2=2d^2$. After normalization by a nonzero edge, selected diagonal ratios lie on $w^2=u^2+v^2-1$, and this quadric is completely parametrized over the rational numbers by two slopes.

Accordingly, the central difficulty is not the production of rational points on the quadric. It is the simultaneous conversion of three associated rational expressions into squares. That reduction places the problem squarely within the arithmetic of explicit quartic constraints and supplies a concrete foundation for further theoretical and computational investigation.
