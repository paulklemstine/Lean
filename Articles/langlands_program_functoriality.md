# From Two Numbers to Three: A Local Portrait of Langlands Functoriality

A pair of numbers can carry an astonishing amount of arithmetic information. In one corner of modern number theory, two quantities $a$ and $b$ encode how a two-dimensional object behaves at a chosen prime. They are called **Satake parameters**. Their individual values matter, but so do their sum, their product, and the polynomials built from them. The Langlands program predicts that when one changes the lens through which these parameters are viewed, the resulting arithmetic data should reorganize itself with perfect consistency.

The simplest nontrivial example has the flavor of passing from a vector to a quadratic form. Begin with the pair

$$
(a,b).
$$

Its symmetric square is the triple

$$
(a^2,ab,b^2).
$$

This is the local parameter transformation underlying the symmetric-square transfer from rank two to rank three. At first glance, it is merely a familiar algebraic recipe. Yet this small transformation already displays several themes of functoriality: compatibility with changes of coefficients, predictable behavior of determinant-like data, preservation of local $L$-factor structure, and a decomposition law for tensor products.

This article develops that complete local story from the ground up.

## Arithmetic fingerprints at a prime

An unramified local object of rank $n$ will mean, for our purposes, an ordered family of parameters

$$
(eta_1,eta_2,\ldots,\beta_n)
$$

in a commutative ring $R$. “Unramified” signals that no extra singular behavior is being recorded at the chosen place; all the information relevant here is concentrated in this finite list.

Two fingerprints of the list are especially important. The first is its **central character value**, defined as the product

$$
\omega=\prod_{i=1}^{n}\beta_i.
$$

The second is the **Euler denominator**

$$
D(X)=\prod_{i=1}^{n}(1-\beta_iX).
$$

When the coefficients lie in a field and inversion is meaningful, the associated local $L$-factor is formally $L(X)=D(X)^{-1}$. It is often better to work with $D(X)$ itself: it is an honest polynomial, it makes sense over any commutative ring, and identities between local $L$-factors become polynomial factorizations.

For a rank-two pair $(a,b)$, these invariants are

$$
\omega=ab,
\qquad
D_2(X)=(1-aX)(1-bX).
$$

The coefficient of $X$ in this polynomial, up to sign, is $a+b$, the familiar local trace. The coefficient of $X^2$ is $ab$, the central character value. Thus one compact polynomial packages the elementary symmetric information in the parameters.

## The quadratic lift

The **symmetric-square transfer** sends

$$
(a,b)\longmapsto(a^2,ab,b^2).
$$

Why these three entries? Imagine a two-dimensional space with basis vectors $u$ and $v$. Its symmetric quadratic tensors have basis

$$
u^2,\quad uv,\quad v^2.
$$

If an operator scales $u$ by $a$ and $v$ by $b$, it scales these three quadratic directions by $a^2$, $ab$, and $b^2$. The triple is therefore not an arbitrary invention: it is forced by the symmetric-square representation of two-dimensional linear algebra.

The Euler denominator of the lifted rank-three object is consequently

$$
D_{\mathrm{Sym}^2}(X)
=(1-a^2X)(1-abX)(1-b^2X).
$$

This explicit identity is the local standard-factor compatibility theorem for the lift. It says that the rank-three local factor is obtained by applying the quadratic representation directly to the rank-two parameters.

The lifted trace is equally transparent:

$$
T_{\mathrm{Sym}^2}=a^2+ab+b^2.
$$

This quadratic expression obeys the classical telescoping identity

$$
(a-b)(a^2+ab+b^2)=a^3-b^3.
$$

Accordingly,

$$
(a-b)T_{\mathrm{Sym}^2}=a^3-b^3.
$$

The identity gives a useful computational check and a conceptual bridge: the trace of the three-dimensional lift is the divided difference of the cubic function. When $a\ne b$ in a field, it can be written as

$$
T_{\mathrm{Sym}^2}=\frac{a^3-b^3}{a-b}.
$$

Unlike that quotient, however, $a^2+ab+b^2$ remains valid without division and over arbitrary commutative rings.

## A cube hidden in the determinant

The central character of the lifted triple is the product of its three entries:

$$
(a^2)(ab)(b^2)=a^3b^3=(ab)^3.
$$

This proves the **central-character law**:

> The central character value of the symmetric-square transfer is the cube of the original central character value.

The exponent three has a representation-theoretic explanation. A scalar matrix with eigenvalue $t$ acts on the original two-dimensional space by $t$, but on every quadratic tensor by $t^2$. Since the lifted space has dimension three, its determinant is $(t^2)^3=t^6$. Meanwhile the original determinant is $t^2$, whose cube is also $t^6$. The elementary parameter calculation captures exactly this weight bookkeeping.

This law is valuable in practice. A proposed rank-three lift with the wrong product of parameters cannot be the symmetric-square transfer. The central character acts as a fast consistency test before any deeper analytic comparison is attempted.

## Tensor square: four directions, split into three plus one

The most revealing identity comes from the full tensor square. Starting from $(a,b)$, the tensor-square parameters are

$$
(a^2,ab,ab,b^2).
$$

The middle parameter occurs twice because the ordered tensors $u\otimes v$ and $v\otimes u$ are distinct. Linear algebra separates this four-dimensional tensor space into a three-dimensional symmetric part and a one-dimensional alternating part. On parameters, that means

$$
(a^2,ab,ab,b^2)
=
(a^2,ab,b^2)\ \sqcup\ (ab),
$$

where the symbol $\sqcup$ emphasizes that multiplicities are retained.

The one-dimensional parameter $(ab)$ is the determinant character. Taking Euler denominators turns the multiset decomposition into the polynomial factorization

$$
\begin{aligned}
D_{\otimes^2}(X)
&=(1-a^2X)(1-abX)^2(1-b^2X)\\
&=D_{\mathrm{Sym}^2}(X)D_{\det}(X),
\end{aligned}
$$

with

$$
D_{\det}(X)=1-abX.
$$

Equivalently, whenever the formal reciprocals are considered,

$$
L(X,\pi\otimes\pi)
=L(X,\mathrm{Sym}^2\pi)L(X,\det\pi).
$$

This is the local Rankin–Selberg decomposition. Its meaning is more substantial than a lucky factorization: the tensor-square construction itself splits into symmetric and alternating components, and the local arithmetic factors remember that decomposition exactly.

A physical analogy is useful. Two identical particles can combine into symmetric and antisymmetric states. Here the “state space” is algebraic, and the symmetric sector has three modes while the alternating sector has one. The repeated mixed parameter $ab$ supplies one mode to each sector. The Euler polynomial records the entire spectral splitting.

## Changing the number system changes nothing essential

Arithmetic data are routinely transported between coefficient rings: integers may be reduced modulo a prime, rational numbers may be embedded into the reals or complex numbers, and algebraic numbers may be viewed in larger fields. Let $f:R\to S$ preserve addition, multiplication, and the unit. Applying $f$ to every Satake parameter gives a transported local object.

The symmetric-square construction commutes with this transport. Indeed,

$$
(f(a^2),f(ab),f(b^2))
=(f(a)^2,f(a)f(b),f(b)^2).
$$

Thus it makes no difference whether one first forms the lift and then changes coefficients, or first changes coefficients and then forms the lift.

Euler denominators enjoy the same naturality. For a family $(\beta_i)$,

$$
f\!\left(\prod_i(1-\beta_iX)\right)
=
\prod_i(1-f(\beta_i)X),
$$

where $f$ is applied coefficient by coefficient to the polynomial. This is the **scalar-extension compatibility theorem** for local Euler denominators.

These facts are indispensable rather than decorative. Functoriality is supposed to be intrinsic; it should not depend on an accidental choice of coefficient system. The two compatibility laws show that every identity developed above survives any ring homomorphism.

## A concrete numerical portrait

Take $a=2$ and $b=3$. The original rank-two parameters are $(2,3)$, and the symmetric-square lift is

$$
(4,6,9).
$$

Its trace is

$$
4+6+9=19,
$$

and the telescope reads

$$
(2-3)\cdot19=2^3-3^3=-19.
$$

The original central character is $6$, while the lifted product is

$$
4\cdot6\cdot9=216=6^3.
$$

The tensor-square list is $(4,6,6,9)$. Therefore

$$
D_{\otimes^2}(X)=(1-4X)(1-6X)^2(1-9X),
$$

while

$$
D_{\mathrm{Sym}^2}(X)=(1-4X)(1-6X)(1-9X)
$$

and

$$
D_{\det}(X)=1-6X.
$$

Their product reproduces the tensor-square denominator exactly.

## An algorithm hiding inside the theorem

The theory is also directly computable. Given any finite parameter list, one builds its Euler denominator by starting with the constant polynomial $1$ and multiplying successively by the linear factors $1-\beta_iX$. Given a pair $(a,b)$, the symmetric-square algorithm first produces $(a^2,ab,b^2)$ and then applies that same polynomial routine. The tensor-square test computes two polynomials independently: one from $(a^2,ab,ab,b^2)$, and another by multiplying the denominator from $(a^2,ab,b^2)$ by $1-abX$. Equality of their coefficients confirms the decomposition.

This is not merely a way to illustrate the equations. It reveals why Euler denominators are such efficient information containers. Lists of parameters combine by concatenation, while their denominators combine by multiplication. A decomposition of spectral data therefore becomes a factorization of polynomials. The passage turns a structural statement in representation theory into exact coefficient arithmetic.

The calculation is stable even in unusual coefficient systems. One can use integers, rational numbers, finite rings, or symbolic expressions. No ordering, notion of size, convergence, or division is required. Zero divisors cause no difficulty because every argument uses only addition and multiplication. This broad algebraic validity separates the structural core of the local transfer from the analytic machinery needed in global applications.

There is a practical lesson here for experimentation. Rather than numerically approximating reciprocal $L$-factors near their poles, compare Euler denominators coefficient by coefficient. The result is exact, finite, and resistant to floating-point error. The same method scales naturally to larger parameter families and higher symmetric powers, where direct expansion may be longer but the underlying product rule remains unchanged.

## What this local model does—and does not—say

The global Langlands program concerns automorphic representations, Galois representations, analytic continuation, functional equations, and matching data across almost all primes. None of those global analytic questions can be replaced by a single calculation with two parameters. The local unramified calculation instead isolates the algebraic compatibility that any global symmetric-square lifting must satisfy place by place.

That is precisely why the model matters. It provides the local blueprint: how the parameters transform, how standard factors change, how central characters behave, and how tensor products decompose. Any global theory claiming to realize the symmetric-square transfer must agree with these identities at every unramified place.

From the tiny seed $(a,b)$ grows a coherent network: the triple $(a^2,ab,b^2)$, the cubic central-character law, the rank-three Euler polynomial, the tensor decomposition, the trace identity, and invariance under coefficient change. Functoriality, in this local portrait, is the principle that all these views tell the same story.
