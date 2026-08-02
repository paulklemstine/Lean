# Scalar Unitary Values of the Principal Complex Logarithm on a Vertical Line

**Aristotle**  
**August 2, 2026**

## Abstract

We study the scalar function

$$
F(t)=\left|\log(1+ti)\right|,\qquad t\in\mathbb{R},
$$

where $\log$ denotes the principal complex logarithm. This function arises naturally when the logarithmic factor in an exponential-logarithmic operator transformation is restricted to a real scalar multiple of the identity. We prove that $F$ is continuous on the real line, that $F(1/2)<1$, and that $F(3)>1$. The intermediate value theorem then yields a nonzero parameter $t\in[1/2,3]$ for which $F(t)=1$. We further prove the exact reflection identity $F(-t)=F(t)$, so every positive unit-circle intersection has a negative partner. Finally, we show that at either intersection the scalar $\log(1+ti)$ is unitary. The proof supplies a certified existence interval without relying on numerical root finding or an unproved monotonicity claim. We discuss a stable bisection algorithm for numerical exploration, the relation to scalar identity factors in matrix algebras, and the additional exponential-surjectivity, determinant, and trace results needed for coverage questions in $U(2)$ and $SU(2)$.

## 1. Introduction

Unitary transformations preserve inner products and norms. They are central to quantum dynamics, harmonic analysis, signal processing, and matrix-based learning systems. A common way to produce a unitary operator is to exponentiate a Hermitian operator: if $H$ is Hermitian, then $\exp(iH)$ is unitary. Logarithmic factors are more delicate. A principal logarithm can vanish, change norm, and interact with a branch cut; it is not intrinsically unitary-valued.

Consider an operator expression of the form

$$
\exp(iH_1)\log(I+iH_2),
$$

with Hermitian parameters $H_1,H_2$ and identity $I$. If $H_2=0$, the logarithmic factor is $\log I=0$, so the expression is zero. Thus the raw formula does not map every parameter choice into the unitary group. If the output is to be unitary while the exponential factor already is unitary, the logarithmic factor must itself be unitary. This separates two questions: whether the raw expression covers desired matrices, and whether it defines a unitary-valued transformation for all inputs.

A tractable first restriction is the scalar choice $H_2=tI$ for real $t$. Under the standard scalar functional calculus,

$$
\log(I+itI)=\log(1+ti)I.
$$

The relevant scalar question is therefore whether the principal logarithm of $1+ti$ ever lies on the complex unit circle. Equivalently, we seek a nonzero real $t$ satisfying

$$
\left|\log(1+ti)\right|=1.
$$

The principal result of this paper answers this question affirmatively and gives the explicit enclosure $t\in[1/2,3]$. The argument is qualitative but certified: continuity forces a crossing between a rigorously controlled point inside the unit circle and another outside it.

The result is deliberately modest in dimension and strong in logical scope. It does not depend on floating-point calculations, does not assume uniqueness, and does not conflate a scalar existence theorem with matrix-group surjectivity. It provides an exact analytic building block for those broader investigations.

## 2. Preliminaries

### 2.1. Principal logarithm and branch geometry

For $z\in\mathbb{C}\setminus(-\infty,0]$, the principal complex logarithm is

$$
\log z=\ln|z|+i\operatorname{Arg}(z),
$$

where $\operatorname{Arg}(z)\in(-\pi,\pi)$ is the principal argument on the slit plane. The map is continuous and holomorphic on this domain.

The path considered here is

$$
\gamma(t)=1+ti,
$$

whose real part is identically $1$. Hence $\gamma(t)$ lies in the open right half-plane for every $t\in\mathbb{R}$ and never approaches the branch cut as a point of intersection. The composition $t\mapsto\log(1+ti)$ is therefore continuous on all of $\mathbb{R}$.

For this path,

$$
|1+ti|=\sqrt{1+t^2}
$$

and

$$
\operatorname{Arg}(1+ti)=\arctan t.
$$

Consequently,

$$
\log(1+ti)=\ln\sqrt{1+t^2}+i\arctan t.
$$

Taking the Euclidean norm in $\mathbb{C}$ yields

$$
\left|\log(1+ti)\right|^2
=
\left(\ln\sqrt{1+t^2}\right)^2+(\arctan t)^2.
$$

Since $\ln\sqrt{1+t^2}=\frac12\ln(1+t^2)$, one may also write

$$
\left|\log(1+ti)\right|^2
=
\frac14\ln^2(1+t^2)+(\arctan t)^2.
$$

### 2.2. Scalar logarithmic norm

**Definition 2.1 (Scalar logarithmic norm).** Define $F:\mathbb{R}\to\mathbb{R}_{\geq0}$ by

$$
F(t)=\left|\log(1+ti)\right|.
$$

The target equation is $F(t)=1$.

**Proposition 2.2 (Continuity).** The scalar logarithmic norm $F$ is continuous on $\mathbb{R}$.

**Proof sketch.** The affine map $t\mapsto1+ti$ is continuous and has positive real part. It therefore remains in the domain of the principal logarithm. The principal logarithm is continuous on that domain, and complex modulus is continuous. Their composition is $F$. $\square$

### 2.3. Unitary complex scalars

**Definition 2.3 (Unitary scalar).** A complex number $z$ is called unitary if

$$
\overline z z=z\overline z=1.
$$

Because $z\overline z=|z|^2$, this is equivalent to $|z|=1$. Thus the scalar unitary group is precisely the complex unit circle.

This equivalence is the final bridge from the analytic crossing equation to an algebraic unitary statement.

## 3. Endpoint estimates

The existence argument requires one parameter where $F$ is below $1$ and another where it is above $1$. The values $1/2$ and $3$ permit clean estimates.

### 3.1. The inner endpoint

**Lemma 3.1 (Strict interior estimate).** At $t=1/2$,

$$
F\left(\frac12\right)<1.
$$

More precisely,

$$
\left|\log\left(1+\frac{i}{2}\right)\right|\leq\frac34.
$$

**Proof sketch.** For $|z|<1$, integrate the derivative of $s\mapsto\log(1+sz)$ along the segment from $0$ to $1$:

$$
\log(1+z)=\int_0^1\frac{z}{1+sz}\,ds.
$$

The reverse triangle inequality gives $|1+sz|\geq1-s|z|$, and therefore

$$
|\log(1+z)|\leq\int_0^1\frac{|z|}{1-s|z|}\,ds=-\ln(1-|z|).
$$

With $z=i/2$, this gives $|\log(1+i/2)|\leq\ln2$. Finally, $\ln2<3/4$: the strictly convex function $x\mapsto1/x$ lies strictly below the chord joining its values at $1$ and $2$, whose integral is the trapezoidal area $3/4$. Since $\ln2=\int_1^2 dx/x$, the claimed bound follows. The estimate is compatible with the explicit formula

$$
F\left(\frac12\right)^2
=
\frac14\ln^2\left(\frac54\right)+\arctan^2\left(\frac12\right),
$$

but the proof needs no decimal evaluation of either transcendental term. $\square$

The role of this lemma is geometric: at $t=1/2$, the logarithmic image lies strictly inside the unit circle.

### 3.2. The outer endpoint

**Lemma 3.2 (Strict exterior estimate).** At $t=3$,

$$
1<F(3).
$$

**Proof.** First compute

$$
|1+3i|=\sqrt{1^2+3^2}=\sqrt{10}.
$$

The real part of the principal logarithm is therefore

$$
\operatorname{Re}\log(1+3i)=\ln\sqrt{10}.
$$

We use the elementary inequalities

$$
e<3<\sqrt{10}.
$$

The second follows from $9<10$. By strict monotonicity of $\ln$ on the positive real axis,

$$
1=\ln e<\ln\sqrt{10}.
$$

For any complex number $w$, $|\operatorname{Re}w|\leq|w|$. Hence

$$
1<\left|\operatorname{Re}\log(1+3i)\right|
\leq\left|\log(1+3i)\right|=F(3).
$$

This proves the claim. $\square$

This estimate intentionally ignores the imaginary part $\arctan 3$. The real part alone is already larger than $1$, so the full modulus must be larger still.

## 4. Main existence and symmetry results

### 4.1. Certified unit-circle intersection

**Theorem 4.1 (Scalar Logarithmic Unit-Circle Intersection).** There exists a real number $t$ such that

$$
\frac12\leq t\leq3,
\qquad t\neq0,
\qquad
\left|\log(1+ti)\right|=1.
$$

**Proof.** By Proposition 2.2, $F$ is continuous on $[1/2,3]$. Lemmas 3.1 and 3.2 give

$$
F\left(\frac12\right)<1<F(3).
$$

Therefore $1$ lies between the two endpoint values of $F$. The intermediate value theorem supplies $t\in[1/2,3]$ with $F(t)=1$. Since $t\geq1/2>0$, the parameter is nonzero. $\square$

The theorem certifies an interval rather than a particular closed-form parameter. Such an existence statement is appropriate because the equation combines logarithmic and inverse-trigonometric terms and is not expected to have a simple elementary solution.

### 4.2. Reflection symmetry

The principal logarithm does not commute with conjugation everywhere without attention to its branch, but it does along the present path. Both $1+ti$ and $1-ti$ lie in the open right half-plane.

**Theorem 4.2 (Evenness of the scalar logarithmic norm).** For every real $t$,

$$
F(-t)=F(t).
$$

Equivalently,

$$
\left|\log(1-ti)\right|=\left|\log(1+ti)\right|.
$$

**Proof.** Complex conjugation maps $1+ti$ to $1-ti$. Since these points avoid the branch cut, the principal logarithm respects conjugation:

$$
\log(1-ti)=\overline{\log(1+ti)}.
$$

Complex conjugation preserves modulus, so

$$
F(-t)=\left|\overline{\log(1+ti)}\right|=F(t).
$$

$\square$

The same result follows immediately from the explicit squared formula, because both $\ln^2(1+t^2)$ and $\arctan^2 t$ are even. The conjugation proof has the advantage of exposing the underlying complex geometry.

**Corollary 4.3 (Paired positive and negative solutions).** There exists $t>0$ such that

$$
\left|\log(1+ti)\right|=1
\quad\text{and}\quad
\left|\log(1-ti)\right|=1.
$$

**Proof.** Choose the positive parameter supplied by Theorem 4.1. The first equality is its defining property, and Theorem 4.2 gives the second. $\square$

### 4.3. Unitary consequence

**Theorem 4.4 (Existence of a unitary logarithmic scalar).** There exists a nonzero real number $t$ such that $\log(1+ti)$ is a unitary complex scalar.

**Proof.** Choose $t$ from Theorem 4.1 and set

$$
z=\log(1+ti).
$$

Then $|z|=1$, so

$$
\overline z z=z\overline z=|z|^2=1.
$$

Thus $z$ is unitary. $\square$

This conclusion is stronger in interpretation than the bare norm equation: multiplication by $z$ preserves the modulus of every complex number.

## 5. A certified numerical exploration algorithm

The existence proof does not require an approximation to the crossing, but a numerical approximation is useful for visualization and subsequent conjecture formation.

Define

$$
G(t)=F(t)-1.
$$

The endpoint results imply $G(1/2)<0<G(3)$. Bisection therefore preserves a bracket containing at least one root.

### Algorithm 5.1 (Bracket-preserving bisection)

**Input:** endpoints $a=1/2$, $b=3$, tolerance $\varepsilon>0$, and a maximum iteration count $N$.

**Output:** a midpoint approximation $m$ and a final interval $[a,b]$ whose width is at most $\varepsilon$, unless the iteration cap is reached.

1. Compute $G(a)$ and $G(b)$ and verify that they have opposite signs or that one is zero.
2. While $b-a>\varepsilon$ and fewer than $N$ iterations have occurred:
   1. Set $m=(a+b)/2$.
   2. Compute $G(m)$ using the principal complex logarithm.
   3. If $G(m)=0$, return the degenerate bracket $[m,m]$.
   4. If $G(a)$ and $G(m)$ have opposite signs, replace $b$ by $m$.
   5. Otherwise replace $a$ by $m$.
3. Return $m=(a+b)/2$ and $[a,b]$.

After $n$ iterations, the bracket width is

$$
\frac{3-1/2}{2^n}=\frac{5}{2^{n+1}}.
$$

Thus obtaining width at most $\varepsilon$ requires at most

$$
\left\lceil\log_2\left(\frac{5}{2\varepsilon}\right)\right\rceil
$$

iterations, apart from fixed setup costs. Each iteration uses a constant number of elementary transcendental evaluations, so the arithmetic-operation count is $O(\log(1/\varepsilon))$ under the usual fixed-precision model. At arbitrary precision, the bit complexity also depends on the cost of evaluating logarithms and inverse trigonometric functions.

Bisection proves only that the maintained interval contains some crossing, not that the crossing is unique. If multiple roots existed in the initial interval, the signs and midpoint choices would guide the algorithm toward one of them. A uniqueness theorem would require additional analysis.

## 6. Matrix and operator interpretation

Let $A$ be a unital complex matrix algebra and let $I$ denote its identity. For a real scalar $t$, the element $tI$ is Hermitian. Functional calculus suggests

$$
\log(I+itI)=\log(1+ti)I.
$$

If $|\log(1+ti)|=1$, then

$$
\bigl(\log(1+ti)I\bigr)^*\bigl(\log(1+ti)I\bigr)
=|\log(1+ti)|^2I=I.
$$

Thus the scalar theorem identifies the correct parameter needed for a unitary scalar identity factor. A complete operator theorem must state the functional-calculus setting and verify that the chosen branch is valid for the spectrum; for the scalar matrix $(1+ti)I$, the spectrum is the singleton $\{1+ti\}$ in the right half-plane, so no branch-cut obstruction is expected.

Now consider

$$
A(H_1,H_2)=\exp(iH_1)\log(I+iH_2).
$$

When $H_1$ is Hermitian, $\exp(iH_1)$ is unitary. If $H_2=tI$ with a scalar crossing parameter, the second factor is also unitary, and therefore their product is unitary. This gives a distinguished nontrivial scalar slice of the parameter space on which the expression is unitary-valued.

However, the raw expression is not unitary-valued on its entire parameter space. Setting $H_2=0$ gives

$$
A(H_1,0)=\exp(iH_1)\log I=0.
$$

The scalar crossing theorem should therefore be understood as a parameter-existence result, not a universal preservation theorem.

## 7. Toward coverage of $U(2)$ and $SU(2)$

Suppose a scalar $z=\log(1+ti)$ of unit modulus has been fixed. To represent an arbitrary unitary matrix $U$ as

$$
U=\exp(iH_1)zI,
$$

one must represent $z^{-1}U$ as $\exp(iH_1)$ for a Hermitian matrix $H_1$. In finite dimensions, the spectral theorem strongly motivates this: diagonalize a unitary matrix, choose real arguments for its eigenvalues, and conjugate the resulting real diagonal matrix back. A complete development must account for eigenvalue phases and the chosen matrix setting.

For $SU(2)$, determinant bookkeeping adds a constraint. For a square matrix $H$,

$$
\det(\exp(iH))=\exp(i\operatorname{tr}H).
$$

If the scalar factor in dimension two is $zI$, then

$$
\det(zI)=z^2.
$$

Consequently, a representation of a determinant-one target imposes

$$
\exp(i\operatorname{tr}H_1)z^2=1.
$$

Writing $z=e^{i\theta}$ gives the congruence

$$
\operatorname{tr}H_1+2\theta\equiv0\pmod{2\pi}.
$$

Determining the exact trace class, and showing that a Hermitian logarithm may always be chosen in that class, is a separate theorem. The present scalar result supplies $z$ but does not settle this trace-selection problem.

## 8. Polar normalization as an alternative

Rather than searching for parameters whose logarithmic factors are already unitary, one may normalize any invertible logarithmic factor. If

$$
L=\log(I+iH_2)
$$

is invertible, define its polar-normalized factor by

$$
Q=L(L^*L)^{-1/2}.
$$

Under standard hypotheses ensuring that the positive inverse square root exists, one computes

$$
Q^*Q
=(L^*L)^{-1/2}L^*L(L^*L)^{-1/2}=I.
$$

In finite dimensions, invertibility then also gives $QQ^*=I$, so $Q$ is unitary. Multiplying $Q$ by $\exp(iH_1)$ preserves unitarity.

This route has a different purpose from the scalar intersection theorem. The intersection theorem locates raw logarithms that already have unit modulus. Polar normalization modifies the raw logarithm in a controlled manner so that every invertible input yields a unitary factor. The former preserves the original formula at special parameters; the latter changes the formula to gain a global structural property on its invertible domain.

## 9. Discussion

The proof of Theorem 4.1 is an instance of a useful design pattern:

1. identify a scalar path on which branch behavior is controlled;
2. compose with the nonlinear function of interest;
3. measure a structural target by a continuous real-valued quantity;
4. certify endpoint inequalities; and
5. invoke an intermediate-value argument.

Here the structural target is unitarity, reduced in one complex dimension to modulus one. The path $1+ti$ is especially convenient because it lies entirely in the right half-plane. The endpoint $1/2$ is close enough to $0$ for a local logarithm bound, while $3$ is large enough that the real part $\ln\sqrt{10}$ alone exceeds $1$.

The interval $[1/2,3]$ is not presented as optimal. Its virtue is transparent certification. A tighter interval such as $[6/5,5/4]$ may be accessible through explicit rational bounds for $\ln$ and $\arctan$, or through interval arithmetic with proved error estimates.

The explicit formula also suggests monotonicity. If

$$
S(t)=F(t)^2=\frac14\ln^2(1+t^2)+(\arctan t)^2,
$$

then for $t>0$ formal differentiation gives

$$
S'(t)
=
\frac{t\ln(1+t^2)+2\arctan t}{1+t^2}.
$$

Every term in the numerator is positive for $t>0$, so $S'(t)>0$. This strongly indicates that $F$ is strictly increasing on $(0,\infty)$ and hence that the positive crossing is unique. Establishing this carefully, including differentiability and the passage from $S$ to $F$, is a natural strengthening rather than an assumption used in the existence proof.

## 10. Future work

Several concrete directions follow.

First, tighten the certified interval, for example to $[6/5,5/4]$, using explicit upper and lower estimates for the complex logarithm. Such an enclosure would sharpen the numerical location while retaining a fully analytic guarantee.

Second, prove strict monotonicity of $t\mapsto|\log(1+ti)|$ on $(0,\infty)$. The derivative calculation above provides the main analytic route. Strict monotonicity would establish exactly one positive solution and, by evenness, exactly one negative solution.

Third, lift the scalar unitary logarithmic factor to scalar multiples of the identity in matrix $C^*$-algebras, with a precise statement of the functional calculus and unitarity calculation.

Fourth, establish surjectivity of the exponential from Hermitian matrices onto finite-dimensional complex unitary matrices. Combined with the scalar factor theorem, this would support a coverage theorem for $U(2)$.

Fifth, track determinants and traces through the representation to identify the exact trace congruence class needed for $SU(2)$. The phase of the scalar logarithm contributes twice in dimension two and must be canceled by the exponential factor.

Sixth, develop the polar-normalized logarithmic factor and prove its unitarity whenever the logarithmic input is invertible. A determinant-one phase correction could then be studied together with traceless Hermitian parameters.

## 11. Applications and limitations

The scalar theorem has three immediate applications. First, it supplies a benchmark for implementations of the principal complex logarithm: a numerical routine should reproduce the evenness of $F$ and detect a crossing within the certified interval. Second, it provides a principled initialization for models or simulations that require a nonzero logarithmic phase factor of unit magnitude. Third, it illustrates how scalar functional calculus can expose necessary ingredients of a matrix construction before the full noncommutative problem is attempted.

The theorem also has clear limitations. It is existential and does not select a canonical root. It concerns the principal branch; other branches add integer multiples of $2\pi i$ and lead to different norm equations. It treats scalar multiples of the identity rather than arbitrary Hermitian $H_2$, whose spectral values may interact with the branch cut in more complicated ways. Finally, unitarity of a factor at selected parameters does not imply that the original two-parameter expression is unitary for every parameter or that it covers an entire unitary group.

These limitations are useful boundaries rather than defects. They identify precisely which claims follow from continuity and scalar geometry and which require spectral, matrix, or global group-theoretic arguments.

## 12. Reproducible computational protocol

A numerical study should evaluate the same principal branch used in the analysis. For real $t$, the most transparent implementation avoids branch ambiguity by computing

$$
a(t)=\frac12\ln(1+t^2),
\qquad
b(t)=\arctan t,
\qquad
F(t)=\sqrt{a(t)^2+b(t)^2}.
$$

The complex value itself is $a(t)+ib(t)$. A reproducible experiment should report the endpoint values, verify numerically that $F(1/2)<1<F(3)$, run bracket-preserving bisection, and compare $F(t)$ with $F(-t)$ at several samples. It should also compute

$$
|z|,
\qquad
\overline z z,
\qquad
z\overline z,
\quad\text{where }z=\log(1+ti),
$$

at the approximate crossing. All three quantities should be close to $1$, with discrepancies controlled by the stopping tolerance and floating-point rounding.

For visualization, two complementary plots are informative. The first graphs $F(t)$ against $t$ together with the horizontal line at height $1$ and vertical markers at $t=\pm1/2$ and $t=\pm3$. This plot exhibits the certified crossing regions and even symmetry. The second draws the parametric curve

$$
t\longmapsto\left(\frac12\ln(1+t^2),\arctan t\right)
$$

in the logarithm plane together with the unit circle. It shows that changing the sign of $t$ reflects the image across the real axis, while the sought parameters are literal intersections of the curve with the circle.

Numerical output should not be described as a substitute for the existence proof. Standard floating-point libraries approximate transcendental functions and generally do not provide directed rounding by default. The rigorous content comes from the analytic inequalities and intermediate value theorem; computation provides an approximation and an explanatory picture. If a substantially tighter certified interval is desired, interval arithmetic with directed rounding or explicit rational remainder estimates would be appropriate.

The protocol is deterministic, uses no external data, and requires only logarithm, arctangent, square root, and elementary arithmetic. It can therefore be reproduced in any standard scientific-computing environment.

## 13. Conclusion

The principal logarithm along the line $1+ti$ necessarily meets the complex unit circle. The proof rests on four facts: the line avoids the branch cut, the logarithmic norm is continuous, the value at $t=1/2$ is below $1$, and the value at $t=3$ is above $1$. The intermediate value theorem gives a positive crossing in $[1/2,3]$; conjugation gives its negative partner; and unit modulus makes the logarithm a unitary scalar.

This scalar theorem cleanly separates an analytic existence question from broader matrix-coverage questions. It provides a certified unitary logarithmic factor while leaving explicit, falsifiable next steps: uniqueness, tighter enclosures, matrix lifting, Hermitian exponential surjectivity, trace correction for $SU(2)$, and polar normalization. The result is therefore both complete in its one-dimensional claim and useful as a foundation for higher-dimensional unitary constructions.
