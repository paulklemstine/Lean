# The Möbius–Diophantine Bridge: Integral Coordinates for Hyperbolic Translation on the Poincaré Diameter

**Aristotle**  
**16 July 2026**

## Abstract

We study repeated Möbius translation by the rational point $1/2$ on a diameter of the Poincaré disk. Möbius addition on the diameter is the binary operation

$$
x\boxplus y=\frac{x+y}{1+xy}.
$$

Starting at $x_0=0$ and setting $x_{n+1}=x_n\boxplus 1/2$, we lift the rational orbit to integer homogeneous coordinates $(a_n,b_n)$ satisfying

$$
(a_0,b_0)=(0,1),\qquad
(a_{n+1},b_{n+1})=(2a_n+b_n,a_n+2b_n).
$$

We prove the exact formulas

$$
2a_n=3^n-1,\qquad 2b_n=3^n+1,
$$

the exponential Lorentzian norm identity

$$
b_n^2-a_n^2=3^n,
$$

and strict disk containment $|a_n/b_n|<1$. Consequently,

$$
x_n=\frac{3^n-1}{3^n+1}
=\tanh\left(\frac{n\log 3}{2}\right).
$$

The construction gives an explicit bridge among fractional-linear dynamics, integral matrix recurrences, Lorentzian quadratic forms, exponential Diophantine equations, and rapidity. We present direct, matrix, and fast-powering algorithms, discuss exact computational demonstrations, and outline extensions to arbitrary rational translations, Pell-type forms, and full two-dimensional disk actions. We also clarify why broader claims about primes or unique factorization on hyperbolic orbits require additional algebraic definitions not supplied by geometry alone.

## 1. Introduction

The open unit disk

$$
\mathbb D=\{z\in\mathbb C:|z|<1\}
$$

supports the Poincaré model of hyperbolic geometry. Its Euclidean boundary represents points at infinite hyperbolic distance. Although the full disk is two-dimensional, every diameter through the origin is a geodesic. The real diameter

$$
I=(-1,1)
$$

therefore provides the simplest setting in which to compare ordinary arithmetic with hyperbolic displacement.

The natural composition law for directed displacements on $I$ is Möbius addition,

$$
x\boxplus y=\frac{x+y}{1+xy}.
$$

It is also the one-dimensional Einstein velocity-addition law in units where the limiting speed is $1$. The rapidity transformation $x\mapsto\operatorname{artanh}(x)$ converts this nonlinear law into ordinary addition. Thus $I$, equipped with $\boxplus$, is a concrete model of the additive real line written in bounded coordinates.

Our purpose is to develop one exact arithmetic orbit under this law. We choose the rational translation parameter $1/2$, initialize at $0$, and iterate. Rationality guarantees that every orbit point is rational, but more is true: a natural choice of integer homogeneous coordinates follows a symmetric linear recurrence, admits a closed form, and solves an exponential norm equation at every time. The construction can be summarized by

$$
\text{Möbius translation}
\longleftrightarrow
\text{integer matrix iteration}
\longleftrightarrow
\text{Lorentzian norm scaling}.
$$

The resulting theorem is deliberately narrower than proposals for a complete “hyperbolic number theory.” A discrete geometric orbit does not automatically possess well-defined addition, multiplication, irreducibility, or unique factorization. The present work instead establishes the precise algebraic-geometric bridge that is available without making those further choices.

## 2. Möbius addition and the rational orbit

### 2.1 Definition of the operation

**Definition 2.1 (Möbius addition).** For $x,y\in\mathbb R$ with $1+xy\ne0$, define

$$
x\boxplus y=\frac{x+y}{1+xy}.
$$

For $x,y\in(-1,1)$, the denominator is positive. Moreover,

$$
1-(x\boxplus y)^2
=\frac{(1-x^2)(1-y^2)}{(1+xy)^2}>0,
$$

so $x\boxplus y\in(-1,1)$. Thus the operation is closed on the Poincaré diameter.

**Lemma 2.2 (Rapidity linearization).** For all $x,y\in(-1,1)$,

$$
\operatorname{artanh}(x\boxplus y)
=\operatorname{artanh}(x)+\operatorname{artanh}(y).
$$

**Proof sketch.** Write $x=\tanh u$ and $y=\tanh v$. The hyperbolic tangent addition formula gives

$$
\tanh(u+v)=\frac{\tanh u+\tanh v}{1+\tanh u\tanh v}=x\boxplus y.
$$

Applying $\operatorname{artanh}$ yields the result. Equivalently, substitute the logarithmic formula for $\operatorname{artanh}$ and simplify. $\square$

### 2.2 Translation by one half

**Definition 2.3 (The orbit).** Define a sequence $(x_n)_{n\ge0}$ by

$$
x_0=0,\qquad x_{n+1}=x_n\boxplus\frac12.
$$

The first values are

$$
x_0=0,\quad x_1=\frac12,\quad x_2=\frac45,
\quad x_3=\frac{13}{14},\quad x_4=\frac{40}{41}.
$$

The fractions suggest powers of $3$, but deriving their exact form through homogeneous coordinates exposes more structure than direct scalar iteration.

## 3. Integral homogeneous coordinates

**Definition 3.1 (Coordinate recurrence).** Define integer sequences $(a_n)$ and $(b_n)$ by

$$
(a_0,b_0)=(0,1)
$$

and

$$
a_{n+1}=2a_n+b_n,\qquad
b_{n+1}=a_n+2b_n.
$$

Equivalently,

$$
\begin{pmatrix}a_{n+1}\\b_{n+1}\end{pmatrix}
=
M\begin{pmatrix}a_n\\b_n\end{pmatrix},
\qquad
M=\begin{pmatrix}2&1\\1&2\end{pmatrix}.
$$

The adjective “homogeneous” reflects the fact that a ratio $a/b$ is unchanged when both coordinates are multiplied by the same nonzero scalar. The recurrence selects a canonical, though not always reduced in more general settings, integral lift of the rational orbit.

**Lemma 3.2 (Sign properties).** For every $n\ge0$,

$$
a_n\ge0\qquad\text{and}\qquad b_n>0.
$$

**Proof sketch.** The claim holds at $n=0$. If $a_n\ge0$ and $b_n>0$, then

$$
a_{n+1}=2a_n+b_n>0,
$$

and

$$
b_{n+1}=a_n+2b_n>0.
$$

Induction proves the assertion. $\square$

**Lemma 3.3 (Coordinate realization of translation).** If $x_n=a_n/b_n$, then

$$
\frac{a_{n+1}}{b_{n+1}}
=\frac{a_n}{b_n}\boxplus\frac12.
$$

**Proof.** Since $b_n>0$ and $a_n+2b_n>0$, all displayed denominators are nonzero. Direct calculation gives

$$
\begin{aligned}
\frac{a_n}{b_n}\boxplus\frac12
&=\frac{a_n/b_n+1/2}{1+(a_n/b_n)(1/2)}\\
&=\frac{2a_n+b_n}{a_n+2b_n}\\
&=\frac{a_{n+1}}{b_{n+1}}.
\end{aligned}
$$

$\square$

Thus the nonlinear scalar recurrence is exactly the projectivization of a linear integral recurrence.

## 4. Closed forms

There are two complementary derivations of the coordinate formulas.

### 4.1 Sum-and-difference derivation

Define

$$
u_n=a_n+b_n,
\qquad
v_n=b_n-a_n.
$$

The recurrence gives

$$
\begin{aligned}
u_{n+1}
&=(2a_n+b_n)+(a_n+2b_n)
=3(a_n+b_n)=3u_n,\\
v_{n+1}
&=(a_n+2b_n)-(2a_n+b_n)
=b_n-a_n=v_n.
\end{aligned}
$$

Since $u_0=1$ and $v_0=1$, it follows that

$$
u_n=3^n,
\qquad
v_n=1.
$$

Solving $a_n+b_n=3^n$ and $b_n-a_n=1$ yields the closed form.

**Theorem 4.1 (Closed-Form Coordinate Theorem).** For every nonnegative integer $n$,

$$
2a_n=3^n-1,
\qquad
2b_n=3^n+1.
$$

Equivalently,

$$
a_n=\frac{3^n-1}{2},
\qquad
b_n=\frac{3^n+1}{2}.
$$

**Proof sketch.** The sum $a_n+b_n$ is multiplied by $3$ at each step, while the difference $b_n-a_n$ is invariant. Their initial values are both $1$. Solving the resulting pair of linear equations gives the formulas. Because $3^n$ is odd, the halves are integers. $\square$

### 4.2 Spectral derivation

The matrix $M$ has eigenvectors $(1,1)^T$ and $(-1,1)^T$ with eigenvalues $3$ and $1$, respectively. Since

$$
\begin{pmatrix}0\\1\end{pmatrix}
=\frac12\begin{pmatrix}1\\1\end{pmatrix}
+\frac12\begin{pmatrix}-1\\1\end{pmatrix},
$$

we have

$$
M^n\begin{pmatrix}0\\1\end{pmatrix}
=\frac{3^n}{2}\begin{pmatrix}1\\1\end{pmatrix}
+\frac12\begin{pmatrix}-1\\1\end{pmatrix}
=
\begin{pmatrix}(3^n-1)/2\\(3^n+1)/2\end{pmatrix}.
$$

This derivation explains why the base $3$ appears: it is the expanding eigenvalue of the integer update matrix.

**Corollary 4.2 (Closed form of the orbit).** For every $n\ge0$,

$$
x_n=\frac{a_n}{b_n}=\frac{3^n-1}{3^n+1}.
$$

**Proof sketch.** Substitute the formulas of Theorem 4.1 and cancel the common factor $1/2$. $\square$

## 5. Lorentzian norm and the Diophantine identity

Let

$$
Q(a,b)=b^2-a^2.
$$

This indefinite quadratic form is the two-dimensional Lorentzian norm. It factors as

$$
Q(a,b)=(b-a)(b+a).
$$

**Lemma 5.1 (One-step norm scaling).** If

$$
(a',b')=(2a+b,a+2b),
$$

then

$$
Q(a',b')=3Q(a,b).
$$

**Proof.** Expansion gives

$$
\begin{aligned}
Q(a',b')
&=(a+2b)^2-(2a+b)^2\\
&=(a^2+4ab+4b^2)-(4a^2+4ab+b^2)\\
&=3(b^2-a^2)=3Q(a,b).
\end{aligned}
$$

$\square$

**Theorem 5.2 (Exponential Lorentzian Norm Theorem).** For every $n\ge0$,

$$
b_n^2-a_n^2=3^n.
$$

**Proof sketch.** The initial norm is $Q(a_0,b_0)=1$. Lemma 5.1 multiplies the norm by $3$ at every step, so induction gives $Q(a_n,b_n)=3^n$. Alternatively, Theorem 4.1 gives $b_n-a_n=1$ and $b_n+a_n=3^n$, whose product is $3^n$. $\square$

This identity places every coordinate pair on the integer conic

$$
b^2-a^2=3^n.
$$

It is stronger than mere rationality of the orbit. The dynamic time $n$ is recorded exactly as the exponent in a Diophantine norm equation.

The matrix identity behind the calculation is

$$
M^TJM=3J,
\qquad
J=\begin{pmatrix}-1&0\\0&1\end{pmatrix}.
$$

Thus $M$ is an integral Lorentzian similitude with multiplier $3$. The normalized matrix $M/\sqrt3$ preserves $J$ exactly and represents a Lorentz boost.

## 6. Disk containment and convergence

**Theorem 6.1 (Strict Disk Containment).** For every $n\ge0$,

$$
\left|\frac{a_n}{b_n}\right|<1.
$$

**Proof sketch.** Lemma 3.2 gives $b_n>0$ and $a_n\ge0$. Theorem 5.2 gives

$$
b_n^2-a_n^2=3^n>0.
$$

Hence $b_n^2>a_n^2$. Positivity implies $b_n>a_n\ge0$, and division by $b_n$ yields $0\le a_n/b_n<1$. $\square$

This proof is notable because disk containment is deduced from an integer norm equation. No approximation or limiting argument is needed.

**Corollary 6.2 (Monotonicity and boundary convergence).** The sequence $(x_n)$ is strictly increasing and converges to $1$. Its Euclidean boundary gap is

$$
1-x_n=\frac{2}{3^n+1}.
$$

**Proof sketch.** The closed form immediately gives the boundary-gap identity, which tends to zero. Strict increase follows because $3^{n+1}>3^n$ and the function $t\mapsto(t-1)/(t+1)$ is strictly increasing for $t>0$. $\square$

### 6.1 Rapidity interpretation

Because

$$
\operatorname{artanh}\left(\frac12\right)
=\frac12\log\frac{1+1/2}{1-1/2}
=\frac12\log 3,
$$

Lemma 2.2 implies

$$
\operatorname{artanh}(x_n)=\frac{n\log3}{2}.
$$

**Corollary 6.3 (Equal hyperbolic spacing).** For every $n\ge0$,

$$
x_n=\tanh\left(\frac{n\log3}{2}\right).
$$

Hence consecutive orbit points are equally spaced in rapidity, even though their Euclidean gaps shrink exponentially.

**Proof sketch.** Iterating rapidity addition from $x_0=0$ gives $n$ times the rapidity of $1/2$. Applying $\tanh$ yields the statement. The identity agrees with Corollary 4.2 because $\tanh(t/2)=(e^t-1)/(e^t+1)$. $\square$

## 7. Main synthesis

**Theorem 7.1 (Möbius–Diophantine Bridge Theorem).** Let $(a_n,b_n)$ be the integer sequence defined by

$$
(a_0,b_0)=(0,1),
\qquad
(a_{n+1},b_{n+1})=(2a_n+b_n,a_n+2b_n).
$$

Define $x_n=a_n/b_n$ and define Möbius addition by

$$
x\boxplus y=\frac{x+y}{1+xy}.
$$

Then, for every nonnegative integer $n$, all of the following hold:

1. $|x_n|<1$, so $x_n$ lies strictly inside the Poincaré diameter;
2. $x_{n+1}=x_n\boxplus 1/2$;
3. $b_n^2-a_n^2=3^n$;
4. $2a_n=3^n-1$;
5. $2b_n=3^n+1$.

**Proof sketch.** The sign properties follow inductively from the recurrence. Lemma 3.3 proves that projectivizing the integer update yields Möbius translation by $1/2$. The sum and difference of the coordinates evolve as $a_n+b_n=3^n$ and $b_n-a_n=1$, proving the closed forms. Their product gives the Lorentzian norm identity. Finally, positivity of that norm and of $b_n$ implies $|a_n/b_n|<1$. $\square$

The theorem gives three equivalent descriptions of the same orbit:

$$
\boxed{
\frac{a_n}{b_n}
=rac{3^n-1}{3^n+1}
=	anh\left(\frac{n\log3}{2}\right)
}
$$

with

$$
\boxed{b_n^2-a_n^2=3^n.}
$$

## 8. Algorithms

### 8.1 Iterative homogeneous-coordinate algorithm

The most direct exact algorithm stores $(a,b)$ and repeatedly applies

$$
(a,b)\leftarrow(2a+b,a+2b).
$$

After $n$ updates it returns $(a_n,b_n)$. It uses $O(n)$ integer-update steps and constant auxiliary storage. Since the output has $\Theta(n)$ bits, the bit cost depends on the integer-arithmetic model; with schoolbook addition, each update costs linear time in the current bit length, giving $O(n^2)$ aggregate bit operations up to constants.

An implementation should compute both new values from the old pair before assignment. In-place sequential replacement would corrupt the recurrence.

### 8.2 Closed-form exponentiation algorithm

Compute $u=3^n$ by exponentiation by squaring, then return

$$
a=(u-1)/2,\qquad b=(u+1)/2.
$$

This uses $O(\log n)$ integer multiplications. The integers still contain $\Theta(n)$ bits, so output size remains unavoidable. This method is ideal for the specific step $1/2$ because the spectral decomposition is explicit.

### 8.3 Matrix-powering algorithm

For extensibility, compute

$$
M^n\begin{pmatrix}0\\1\end{pmatrix}
$$

by binary exponentiation. This takes $O(\log n)$ two-by-two matrix multiplications and constant matrix storage. It is less specialized than the closed form and generalizes immediately to rational translations represented by other symmetric integer matrices.

### 8.4 Exact validation protocol

For each selected $n$, compute $(a_n,b_n)$ and test the identities

$$
2a_n=3^n-1,
\qquad
2b_n=3^n+1,
\qquad
b_n^2-a_n^2=3^n.
$$

Then compare the exact rational orbit value $a_n/b_n$ with the Möbius update from the previous term using cross multiplication, avoiding floating-point error. Floating-point values are appropriate only for visualization.

## 9. Numerical examples

The first eight coordinate pairs are

| $n$ | $a_n$ | $b_n$ | $x_n=a_n/b_n$ | $b_n^2-a_n^2$ |
|---:|---:|---:|---:|---:|
| $0$ | $0$ | $1$ | $0$ | $1$ |
| $1$ | $1$ | $2$ | $0.5$ | $3$ |
| $2$ | $4$ | $5$ | $0.8$ | $9$ |
| $3$ | $13$ | $14$ | $0.928571\ldots$ | $27$ |
| $4$ | $40$ | $41$ | $0.975609\ldots$ | $81$ |
| $5$ | $121$ | $122$ | $0.991803\ldots$ | $243$ |
| $6$ | $364$ | $365$ | $0.997260\ldots$ | $729$ |
| $7$ | $1093$ | $1094$ | $0.999085\ldots$ | $2187$ |

Two patterns are visible. First, $b_n-a_n=1$, so the coordinate fractions are already reduced. Second, the Euclidean ratios crowd near $1$, while their rapidities form the arithmetic progression

$$
0,\ \frac{
\log3}{2},\ \log3,\ \frac{3\log3}{2},\ldots.
$$

## 10. Applications and interpretation

### 10.1 Hyperbolic dynamics

The orbit is a discrete geodesic translation. Its bounded coordinate approaches the disk boundary, while its intrinsic displacement grows linearly. This makes it a simple exact model for comparing Euclidean display coordinates with hyperbolic distance.

### 10.2 Special relativity

Interpreting $x_n$ as a velocity in units of the limiting speed, the operation $\boxplus$ is Einstein velocity addition. Repeatedly composing velocity $1/2$ produces $x_n$. Rapidity is additive, and the matrix $M/\sqrt3$ is a Lorentz transformation. The integral lift supplies exact rational velocities for all finite $n$.

### 10.3 Diophantine arithmetic

Every time step gives an integer solution to

$$
b^2-a^2=3^n.
$$

Here the solutions are particularly rigid because $b-a=1$ and $b+a=3^n$. The recurrence demonstrates how an orbit under fractional-linear dynamics can generate a structured family of exponential Diophantine solutions.

### 10.4 Exact computation and testing

The identities provide mutual checks for implementations of Möbius dynamics. Recurrence, closed form, matrix power, and rapidity all compute the same orbit through mathematically distinct routes. Agreement among them is useful for testing exact-arithmetic and visualization software.

## 11. General rational translations

Let $p,q\in\mathbb Z$ with $q\ne0$, and consider the rational step $p/q$. If $x=a/b$, then

$$
x\boxplus\frac pq
=\frac{qa+pb}{pa+qb}.
$$

This motivates the homogeneous update

$$
\begin{pmatrix}a'\\b'\end{pmatrix}
=
\begin{pmatrix}q&p\\p&q\end{pmatrix}
\begin{pmatrix}a\\b\end{pmatrix}.
$$

A direct expansion yields

$$
b'^2-a'^2=(q^2-p^2)(b^2-a^2).
$$

Thus the multiplier $3$ in the present work is the special value $2^2-1^2$. When $|p|<|q|$, this multiplier is positive and the step $p/q$ lies inside the diameter. The eigenvalues are $q+p$ and $q-p$, suggesting closed forms

$$
a_n=\frac{(q+p)^n-(q-p)^n}{2},
\qquad
b_n=\frac{(q+p)^n+(q-p)^n}{2}
$$

for the orbit initialized at $(0,1)$, subject to the expected parity and normalization considerations. Common factors may appear, so homogeneous coordinates and reduced rational coordinates must be distinguished.

This family points toward quadratic forms $b^2-Da^2$. Matrices preserving or scaling such forms connect hyperbolic transformations with Pell equations and units in real quadratic orders.

## 12. Scope and limitations

The established results concern one geodesic diameter and one translation. They do not by themselves define a ring of “hyperbolic integers.” If a set is described as an orbit under a discrete group, ordinary addition and multiplication need not descend to that orbit. A complete arithmetic theory would need:

1. a precisely specified carrier set;
2. well-defined addition and multiplication;
3. closure, associativity, identities, and distributivity;
4. independence from choices of representatives;
5. a definition of units and irreducibles;
6. a theorem connecting any geometric notion of prime to algebraic irreducibility.

Likewise, vertices of a hyperbolic tessellation are geometric objects, not automatically prime elements. Statements about unique factorization are meaningful only after the ambient algebraic structure is fixed.

Prime-counting proposals also require care. A counting function must specify a locally finite set, a base point, a metric or height, and a radius convention. Hyperbolic area grows exponentially in hyperbolic distance, whereas Euclidean area in a displayed disk behaves differently. An expression involving $R^2/\log R$ can have entirely different meaning depending on whether $R$ denotes hyperbolic distance, Euclidean radius, matrix norm, or arithmetic height.

Finally, no zeta functional equation or critical-line theorem follows from the present one-dimensional recurrence. Such assertions require a separately defined spectrum or Dirichlet series, an analytic continuation, and substantial analytic theory.

## 13. Future work

The immediate next step is to establish the rational-$p/q$ construction uniformly, including disk containment for $|p|<|q|$, exact Lorentzian norm scaling, and a careful account of coordinate primitivity. A second direction is to derive the rapidity formula

$$
x_n=\tanh\left(n\operatorname{artanh}(p/q)\right)
$$

and use it to prove monotonicity and boundary convergence whenever $0<p/q<1$.

A third direction replaces $b^2-a^2$ by $b^2-Da^2$. This should expose the relation between hyperbolic matrix actions and units of real quadratic orders. A fourth develops determinant-one real matrices acting on the upper half-plane, transports the action to the disk by a Cayley transformation, and identifies the current construction as a geodesic restriction.

Only after these foundations are in place should one attempt a broader arithmetic of discrete hyperbolic orbits. The operations, primes, factorization laws, counting parameters, and analytic generating functions must be specified independently and then related to the geometry by theorems.

## 14. Conclusion

Repeated Möbius translation by $1/2$ on the Poincaré diameter admits an exact integral lift. The coordinate matrix

$$
\begin{pmatrix}2&1\\1&2\end{pmatrix}
$$

has expanding and fixed eigenvalues $3$ and $1$, producing the coordinate formulas

$$
(a_n,b_n)=\left(\frac{3^n-1}{2},\frac{3^n+1}{2}\right).
$$

The same matrix scales the Lorentzian form $b^2-a^2$ by $3$, giving

$$
b_n^2-a_n^2=3^n.
$$

This positivity keeps every ratio $a_n/b_n$ strictly inside the disk. Meanwhile, rapidity reveals that the orbit consists of equally spaced hyperbolic points:

$$
\frac{a_n}{b_n}
=\frac{3^n-1}{3^n+1}
=\tanh\left(\frac{n\log3}{2}\right).
$$

The result is a self-contained instance in which curved geometry, integer recurrence, Lorentzian structure, and Diophantine arithmetic coincide exactly. It supplies a precise foundation for broader investigations of arithmetic generated by hyperbolic dynamics while making clear which additional definitions those investigations require.

## Appendix A. Additional structural consequences

The closed forms yield several elementary consequences that help characterize the orbit.

**Proposition A.1 (Consecutive-coordinate property).** For every $n\ge0$,

$$
b_n-a_n=1.
$$

Consequently, $\gcd(a_n,b_n)=1$, so the homogeneous representation $a_n/b_n$ is reduced.

**Proof sketch.** Subtract the two recurrence equations to obtain

$$
b_{n+1}-a_{n+1}=b_n-a_n.
$$

The difference is therefore constant and equals its initial value $1$. Any common divisor of two integers divides their difference, so a common divisor of $a_n$ and $b_n$ must divide $1$. $\square$

**Proposition A.2 (Exact Euclidean increment).** For every $n\ge0$,

$$
x_{n+1}-x_n=\frac{4\cdot 3^n}{(3^{n+1}+1)(3^n+1)}.
$$

In particular, every increment is positive and the increments decay asymptotically like $4/3^{n+1}$.

**Proof sketch.** Substitute $x_n=(3^n-1)/(3^n+1)$ and combine the two fractions. The numerator simplifies to $4\cdot3^n$. Positivity is immediate, and division of numerator and denominator by $3^{2n+1}$ gives the asymptotic behavior. $\square$

**Proposition A.3 (Semigroup law for orbit indices).** For all nonnegative integers $m$ and $n$,

$$
x_m\boxplus x_n=x_{m+n}.
$$

**Proof sketch.** By Corollary 6.3, $x_k=\tanh(k\log3/2)$. The hyperbolic tangent addition formula therefore gives

$$
x_m\boxplus x_n
=\tanh\left(\frac{m\log3}{2}+\frac{n\log3}{2}\right)
=x_{m+n}.
$$

This identifies the nonnegative orbit with an additive semigroup under Möbius addition. $\square$

The last proposition is an arithmetic law intrinsic to this particular orbit: adding indices corresponds exactly to Möbius-adding orbit points. It should not be confused with a full ring structure, since no compatible multiplication has been specified.

## Appendix B. Reproducible computational protocol

A numerical experiment should preserve the distinction between exact arithmetic and visualization. First generate $(a_n,b_n)$ using arbitrary-precision integers. Second verify the recurrence and the three integer identities by equality tests. Third form rational values only when displaying fractions; a rational type represented by numerator and denominator avoids rounding. Finally convert to floating point solely for plotting $x_n$, the boundary gap $1-x_n$, or rapidity.

A robust experiment compares independent computational paths. The iterative recurrence and the closed formula should produce identical integer pairs. Matrix exponentiation supplies a third path. The Möbius-step identity can be checked without division by cross-multiplying the rational numerators and denominators. For rapidity plots, finite floating-point precision eventually rounds $x_n$ to $1$, so the stable expression $n\log3/2$ should be used instead of numerically evaluating $\operatorname{artanh}(x_n)$ at large $n$.

### Computational scale

The recurrence remains exact at scales where decimal coordinates become visually uninformative. At iteration $n$, both $a_n$ and $b_n$ have approximately $n\log_2 3$ binary digits, while the ratio differs from $1$ by about $2\cdot3^{-n}$. Standard floating-point arithmetic therefore rounds the ratio to $1$ after relatively few iterations even though the integer pair continues to encode a point strictly inside the disk. This contrast is not a defect of the mathematics; it is a reminder that bounded geometric coordinates can lose visible resolution near an ideal boundary. Exact integers, rational fractions, logarithmic gaps, and rapidity each preserve a different aspect of the orbit. A reproducible computation should select the representation appropriate to the question rather than treating one decimal approximation as the entire state.
