# Local Ihara Factors, Lucas Recurrences, and the Critical Circle

**Aristotle**  
**July 18, 2026**

## Abstract

The Ihara zeta function translates primitive non-backtracking cycles of a finite graph into an Euler product. For regular graphs, its determinant description decomposes spectrally into quadratic factors of the form $1-\lambda u+qu^2$, where $\lambda$ is an adjacency eigenvalue and $q$ is the branching parameter. This paper develops a self-contained local theory of one such factor. If $\alpha+\beta=\lambda$ and $\alpha\beta=q$, then the factor splits as $(1-\alpha u)(1-\beta u)$, and the power sums $S_n=\alpha^n+\beta^n$ satisfy the Lucas recurrence $S_{n+2}=\lambda S_{n+1}-qS_n$ with $S_0=2$ and $S_1=\lambda$. We prove the exact finite explicit formula

$$
(1-\lambda u+qu^2)\sum_{k=0}^{N}S_{k+1}u^k
=
\lambda-2qu-S_{N+2}u^{N+1}+qS_{N+1}u^{N+2}.
$$

It identifies the spectral power sums with coefficients of the local logarithmic derivative and displays the complete truncation boundary. For real $\lambda$, positive $q$, and $\lambda^2\le 4q$, every zero of the local factor lies on the circle $|u|=q^{-1/2}$. We give algorithms, numerical examples, and applications to spectral diagnostics while carefully separating this local result from the additional global machinery required to enumerate primitive graph cycles.

## 1. Introduction

The classical Riemann zeta function can be presented simultaneously as a Dirichlet series and an Euler product. Its Euler factors package prime numbers, while its zeros govern fluctuations in prime counting. A finite graph has a parallel arithmetic built from closed non-backtracking walks. The irreducible members of that family—closed walks that are not repetitions of shorter closed walks—play the role of primes.

Let $G$ be a finite graph. Informally, its Ihara zeta function is

$$
\zeta_G(u)=\prod_{[C]}(1-u^{|C|})^{-1},
$$

where $[C]$ runs over prime-cycle classes and $|C|$ denotes length. Precise global definitions normally quotient by cyclic change of starting point and impose reducedness conditions excluding immediate reversal and tails. Those global conventions matter for cycle enumeration, but the local spectral results of this paper need only the quadratic factor

$$
L_{\lambda,q}(u)=1-\lambda u+qu^2.
$$

For a regular graph, such factors arise from the adjacency spectrum in the determinant formulation of the graph zeta function. Our purpose is to isolate exactly what follows from this one polynomial. This restriction has two advantages. First, the argument is elementary and completely explicit. Second, it distinguishes established local spectral facts from stronger global analogies with integer primes.

The central observation is that the reciprocal roots of $L_{\lambda,q}$ generate a Lucas sequence. The recurrence annihilates all interior terms when the local factor is multiplied by a truncated generating series. The survivors give an exact finite explicit formula. Under the Ramanujan eigenvalue bound, the reciprocal roots have modulus $\sqrt q$, hence the zeros in the $u$-plane lie on the critical circle of radius $q^{-1/2}$.

The paper proceeds as follows. Section 2 defines the local objects. Section 3 proves factorization and the Lucas recurrence. Section 4 establishes the finite explicit formula and its generating-function interpretation. Section 5 proves the critical-circle theorem. Sections 6 and 7 present algorithms and numerical examples. Sections 8–10 discuss applications, limitations, and future work.

## 2. Definitions and setting

### 2.1 Graph zeta motivation

A **closed walk** is a sequence of adjacent oriented edge traversals that begins and ends at the same vertex. It is **non-backtracking** if no step immediately reverses the preceding step. A reduced closed walk is **primitive** if it is not the $m$-fold repetition of a shorter closed walk for any integer $m\ge 2$. A **prime cycle** is an equivalence class of primitive reduced closed walks under cyclic rotation of the starting position.

The Ihara zeta function is the formal Euler product

$$
\zeta_G(u)=\prod_{[C]}(1-u^{|C|})^{-1}.
$$

This definition explains the analogy with arithmetic Euler products: each primitive cycle contributes all positive repetitions. Establishing a determinant formula for this full product requires global graph machinery not assumed below.

### 2.2 Local quadratic factor

Let $\lambda,q,u\in\mathbb C$. Define the **local Ihara factor** by

$$
L_{\lambda,q}(u)=1-\lambda u+qu^2.
$$

When $\lambda$ is an adjacency eigenvalue of a regular graph, this polynomial is the corresponding local spectral contribution in the usual determinant decomposition. Throughout most algebraic statements, $\lambda$ and $q$ may be complex. For the critical-circle statement they will be real, with $q>0$.

### 2.3 Reciprocal roots and spectral power sums

Choose $\alpha,\beta\in\mathbb C$ such that

$$
\alpha+\beta=\lambda,
\qquad
\alpha\beta=q.
$$

Thus $\alpha$ and $\beta$ are roots of

$$
x^2-\lambda x+q=0.
$$

They are called reciprocal roots of the local factor because, when nonzero, $\alpha^{-1}$ and $\beta^{-1}$ are its zeros in the variable $u$.

For every integer $n\ge 0$, define the **spectral power sum**

$$
S_n(\alpha,\beta)=\alpha^n+\beta^n.
$$

When the parameters are understood, we write simply $S_n$. These power sums are symmetric in $\alpha$ and $\beta$, so they can be computed from $\lambda$ and $q$ without choosing an ordering or evaluating radicals.

## 3. Factorization and the Lucas recurrence

### Theorem 3.1 (Reciprocal-root factorization)

If $\alpha+\beta=\lambda$ and $\alpha\beta=q$, then for every $u\in\mathbb C$,

$$
L_{\lambda,q}(u)=(1-\alpha u)(1-\beta u).
$$

**Proof sketch.** Expanding the right-hand side yields

$$
(1-\alpha u)(1-\beta u)
=1-(\alpha+\beta)u+\alpha\beta u^2.
$$

Substitution of the sum and product relations gives $1-\lambda u+qu^2$. $\square$

### Theorem 3.2 (Lucas recurrence for spectral power sums)

Under the same hypotheses, the sequence $S_n=\alpha^n+\beta^n$ satisfies

$$
S_{n+2}=\lambda S_{n+1}-qS_n
$$

for every $n\ge 0$.

**Proof sketch.** Since $\alpha$ and $\beta$ solve $x^2-\lambda x+q=0$, each obeys $x^{n+2}=\lambda x^{n+1}-qx^n$. Add the identity for $x=\alpha$ to the identity for $x=\beta$. The result is precisely the stated recurrence. $\square$

### Proposition 3.3 (Initial values)

The initial values of the spectral power sums are

$$
S_0=2,
\qquad
S_1=\lambda.
$$

**Proof sketch.** The first equality is $\alpha^0+\beta^0=1+1=2$. The second is $\alpha+\beta=\lambda$. $\square$

Together, Theorem 3.2 and Proposition 3.3 show that $S_n$ is the Lucas sequence determined by the parameter pair $(\lambda,q)$. In particular, if $\lambda$ and $q$ lie in a commutative ring such as $\mathbb Z$, the recurrence computes every $S_n$ in that ring even if $\alpha$ and $\beta$ themselves require a field extension.

### Corollary 3.4 (Polynomial dependence)

For every $n\ge 0$, $S_n$ is a polynomial in $\lambda$ and $q$ with integer coefficients.

**Proof sketch.** The claim follows by induction. It holds for $S_0=2$ and $S_1=\lambda$. If it holds for two consecutive terms, then $S_{n+2}=\lambda S_{n+1}-qS_n$ is again an integer-coefficient polynomial in $\lambda$ and $q$. $\square$

The first few values are

$$
\begin{aligned}
S_0&=2,\\
S_1&=\lambda,\\
S_2&=\lambda^2-2q,\\
S_3&=\lambda^3-3q\lambda,\\
S_4&=\lambda^4-4q\lambda^2+2q^2.
\end{aligned}
$$

These are Newton power sums for a quadratic polynomial, expressed here through a graph-zeta lens.

## 4. The finite explicit formula

Define the truncated generating polynomial

$$
T_N(u)=\sum_{k=0}^{N}S_{k+1}u^k.
$$

The shift by one is chosen so that the stable numerator becomes $\lambda-2qu$.

### Theorem 4.1 (Finite local explicit formula)

For every integer $N\ge 0$,

$$
L_{\lambda,q}(u)T_N(u)
=
\lambda-2qu-S_{N+2}u^{N+1}+qS_{N+1}u^{N+2}.
$$

Equivalently,

$$
(1-\lambda u+qu^2)
\sum_{k=0}^{N}(\alpha^{k+1}+\beta^{k+1})u^k
=
\lambda-2qu-(\alpha^{N+2}+\beta^{N+2})u^{N+1}
+q(\alpha^{N+1}+\beta^{N+1})u^{N+2}.
$$

**Proof sketch.** Multiply $T_N(u)$ separately by $1$, $-\lambda u$, and $qu^2$, then collect coefficients. The constant coefficient is $S_1=\lambda$. The coefficient of $u$ is $S_2-\lambda S_1=-qS_0=-2q$. For every interior degree, the coefficient is

$$
S_{j+1}-\lambda S_j+qS_{j-1},
$$

which vanishes by the recurrence. At the upper boundary, no later summands are available to complete the cancellation. The two surviving terms are $-S_{N+2}u^{N+1}$ and $qS_{N+1}u^{N+2}$. $\square$

This theorem is an exact finite identity, not merely an asymptotic statement. Its last two terms are the complete boundary error caused by stopping after $N+1$ coefficients.

### Corollary 4.2 (Infinite generating function)

If $u$ lies in a region where $S_nu^n\to 0$, then

$$
\sum_{k=0}^{\infty}S_{k+1}u^k
=
\frac{\lambda-2qu}{1-\lambda u+qu^2}.
$$

**Proof sketch.** Divide Theorem 4.1 by the local factor and let $N\to\infty$. The convergence assumption removes both boundary terms. For example, it is enough that $|\alpha u|<1$ and $|\beta u|<1$. $\square$

### Proposition 4.3 (Logarithmic-derivative interpretation)

Where $L_{\lambda,q}(u)\ne 0$,

$$
-\frac{d}{du}\log L_{\lambda,q}(u)
=
\frac{\lambda-2qu}{1-\lambda u+qu^2}.
$$

Consequently, in the domain of convergence,

$$
-\frac{L'_{\lambda,q}(u)}{L_{\lambda,q}(u)}
=
\sum_{k=0}^{\infty}S_{k+1}u^k.
$$

**Proof sketch.** Differentiate $L_{\lambda,q}(u)=1-\lambda u+qu^2$ to obtain $L'_{\lambda,q}(u)=-\lambda+2qu$, and negate the quotient. The coefficient expansion then follows from Corollary 4.2. Alternatively, factorization gives

$$
-\frac{d}{du}\log[(1-\alpha u)(1-\beta u)]
=
\frac{\alpha}{1-\alpha u}+\frac{\beta}{1-\beta u},
$$

and geometric-series expansion yields the same power sums. $\square$

This local formula resembles the role of logarithmic derivatives in classical zeta theory: primitive data and their repetitions become additive coefficients. The present statement identifies the local spectral coefficients. Interpreting the coefficients as global primitive-cycle counts requires the full product and non-backtracking trace identities.

## 5. The Ramanujan bound and the critical circle

We now assume $\lambda,q\in\mathbb R$ and $q>0$.

### Definition 5.1 (Local Ramanujan bound)

The pair $(\lambda,q)$ satisfies the local Ramanujan bound if

$$
|\lambda|\le 2\sqrt q,
$$

or equivalently,

$$
\lambda^2\le 4q.
$$

### Definition 5.2 (Critical circle)

The critical circle associated with $q$ is

$$
\mathcal C_q=\left\{u\in\mathbb C:|u|=\frac{1}{\sqrt q}\right\}.
$$

### Theorem 5.3 (Local critical-circle theorem)

Let $q>0$ and $\lambda^2\le 4q$. If $z\in\mathbb C$ satisfies

$$
1-\lambda z+qz^2=0,
$$

then

$$
|z|=\frac{1}{\sqrt q}.
$$

**Proof sketch.** The reciprocal roots are

$$
\alpha,\beta=\frac{\lambda\pm\sqrt{\lambda^2-4q}}{2}.
$$

Because the discriminant is nonpositive and the coefficients are real, $\alpha$ and $\beta$ are a conjugate pair, with the repeated real-root case allowed at equality. Their product is $q$. For conjugate roots, $\alpha\beta=|\alpha|^2=q$, so $|\alpha|=|\beta|=\sqrt q$. The zeros of $L_{\lambda,q}$ are their reciprocals; therefore each has modulus $q^{-1/2}$. At the boundary $\lambda^2=4q$, the repeated reciprocal root is $\lambda/2=\pm\sqrt q$, and the same conclusion holds. $\square$

### Corollary 5.4 (Angular parametrization)

Under the assumptions of Theorem 5.3, there exists $\theta\in[0,\pi]$ such that

$$
\lambda=2\sqrt q\cos\theta,
$$

and the reciprocal roots may be written as

$$
\alpha=\sqrt q\,e^{i\theta},
\qquad
\beta=\sqrt q\,e^{-i\theta}.
$$

Hence

$$
S_n=2q^{n/2}\cos(n\theta).
$$

**Proof sketch.** The normalized value $\lambda/(2\sqrt q)$ lies in $[-1,1]$, so it is the cosine of an angle. The displayed roots have sum $\lambda$ and product $q$, and the power-sum identity follows immediately. $\square$

### Corollary 5.5 (Power-sum bound)

Under the local Ramanujan bound,

$$
|S_n|\le 2q^{n/2}
$$

for every $n\ge 0$.

**Proof sketch.** Apply the triangle inequality to $S_n=\alpha^n+\beta^n$ and use $|\alpha|=|\beta|=\sqrt q$. Equivalently, use the cosine formula. $\square$

Theorem 5.3 is precisely local. A full graph-level Riemann-hypothesis statement must take a product over all nontrivial spectral factors and separately account for trivial poles and degree-dependent factors.

## 6. Algorithms

### 6.1 Linear-time spectral power sums

The recurrence gives a stable symbolic algorithm that avoids extracting roots.

**Input:** parameters $\lambda,q$ and a nonnegative integer $N$.  
**Output:** $S_0,S_1,\ldots,S_N$.

1. If $N=0$, return $[2]$.
2. Initialize $S_0=2$ and $S_1=\lambda$.
3. For $n=0,1,\ldots,N-2$, compute $S_{n+2}=\lambda S_{n+1}-qS_n$.
4. Return the list.

The algorithm uses $O(N)$ arithmetic operations and $O(N)$ storage if all coefficients are retained. If only $S_N$ is needed, storage drops to $O(1)$. Exact integer or rational arithmetic is available whenever the parameters are exact.

### 6.2 Critical-circle diagnostic

For real $\lambda$ and $q>0$, test whether $\lambda^2\le 4q$. If true, compute the two zeros of $1-\lambda u+qu^2$ and compare their moduli with $q^{-1/2}$. The inequality itself is the exact mathematical criterion; numerical root computation is only a visualization. This costs $O(1)$ arithmetic per eigenvalue and $O(m)$ for $m$ spectral values.

### 6.3 Finite explicit-formula evaluation

Given $N$, compute $S_0$ through $S_{N+2}$ by recurrence. Evaluate

$$
T_N(u)=\sum_{k=0}^{N}S_{k+1}u^k
$$

by Horner's method, then compare $L_{\lambda,q}(u)T_N(u)$ with

$$
\lambda-2qu-S_{N+2}u^{N+1}+qS_{N+1}u^{N+2}.
$$

Both sides require $O(N)$ operations. The comparison demonstrates exact cancellation up to floating-point rounding when numerical complex arithmetic is used.

## 7. Numerical examples

### Example 7.1: The pair $(\lambda,q)=(2,2)$

The recurrence is

$$
S_{n+2}=2S_{n+1}-2S_n,
$$

with $S_0=2$ and $S_1=2$. It gives

$$
(S_0,\ldots,S_7)=(2,2,0,-4,-8,-8,0,16).
$$

The Ramanujan inequality holds because $\lambda^2=4\le 8=4q$. The local factor is

$$
1-2u+2u^2,
$$

whose zeros are $(1\pm i)/2$. Both have modulus $1/\sqrt2$, as predicted.

For $N=3$,

$$
T_3(u)=2-4u^2-8u^3.
$$

The finite formula gives

$$
(1-2u+2u^2)(2-4u^2-8u^3)
=2-4u+8u^4-16u^5.
$$

Here $-S_5u^4=8u^4$ and $2S_4u^5=-16u^5$, exactly matching the boundary terms.

### Example 7.2: Boundary eigenvalue

Let $q=4$ and $\lambda=4=2\sqrt q$. Then

$$
1-4u+4u^2=(1-2u)^2.
$$

The critical circle has radius $1/2$, and the repeated zero is $u=1/2$. The reciprocal roots are $\alpha=\beta=2$, so

$$
S_n=2^{n+1}.
$$

This saturates the bound $|S_n|\le 2q^{n/2}$.

### Example 7.3: Outside the Ramanujan range

Let $q=2$ and $\lambda=3$. Then $\lambda^2=9>8=4q$. The reciprocal roots are real and unequal:

$$
\alpha=2,
\qquad
\beta=1.
$$

The local zeros are $1/2$ and $1$, while the proposed critical radius is $1/\sqrt2$. Thus neither zero lies on that circle. The sequence is $S_n=2^n+1$, dominated exponentially by the larger root. This contrast shows that the Ramanujan hypothesis in Theorem 5.3 is substantive.

## 8. Applications

### 8.1 Spectral certification of local zeta behavior

For a proposed $(q+1)$-regular network, each nontrivial adjacency eigenvalue can be checked against $|\lambda|\le 2\sqrt q$. Passing the test certifies that its local zeta zeros have radius $q^{-1/2}$. This converts an eigenvalue bound familiar in expander theory into a geometric statement about zeros.

### 8.2 Efficient coefficient generation

Direct computation of $\alpha^n+\beta^n$ can require complex radicals and repeated exponentiation. The Lucas recurrence uses only $\lambda$ and $q$, preserves exact arithmetic, and runs in linear time. It is therefore suitable for symbolic experiments, integer parameter families, and comparisons across spectra.

### 8.3 Oscillation and mixing

Under the Ramanujan bound, $S_n=2q^{n/2}\cos(n\theta)$. After normalization by $q^{n/2}$, the coefficients are bounded oscillations. Outside the bound, one real reciprocal root may dominate, producing unbalanced exponential behavior. This makes the local power sums a concise diagnostic of the distinction between tempered and untempered spectral data.

### 8.4 Toward cycle-counting formulas

In a full graph treatment, traces of powers of the non-backtracking matrix count rooted closed non-backtracking walks. Möbius inversion then separates primitive cycles from repetitions. The local logarithmic derivative derived here supplies the spectral side of that future dictionary, while the trace and inversion steps would supply its combinatorial side.

## 9. Structural interpretation

The local factor can be read in three mutually reinforcing ways. Algebraically, it is the characteristic polynomial of a two-mode system after the variable is reversed. Dynamically, its reciprocal roots are the two elementary modes whose powers evolve with length. Analytically, its logarithmic derivative converts multiplication of factors into addition of coefficient sequences. The Lucas recurrence is the common language among these views.

This interpretation explains why the same two parameters play different roles. The sum parameter $\lambda$ is visible immediately as $S_1$ and, in graph applications, originates as an adjacency eigenvalue. The product parameter $q$ controls the determinant of the two-mode evolution and fixes the geometric mean of the reciprocal-root moduli. Under the Ramanujan inequality, the roots have equal modulus, so $q$ sets their common radial growth while $\lambda$ selects their angular phase.

The finite explicit formula is particularly useful because it avoids an often-hidden interchange of limits and series. For a fixed $N$, it is a polynomial identity valid for every complex $u$. No convergence assumption is needed. Convergence enters only when the boundary terms are discarded to obtain the infinite generating function. Under the critical-circle hypothesis, Corollary 5.5 gives

$$
|S_{N+2}u^{N+1}|
\le 2q^{(N+2)/2}|u|^{N+1}
$$

and

$$
|qS_{N+1}u^{N+2}|
\le 2q^{(N+3)/2}|u|^{N+2}.
$$

Thus both boundary terms tend to zero whenever $|u|<q^{-1/2}$. The critical circle is therefore also the natural boundary of the elementary geometric-series argument for a local factor.

There is a useful transfer-matrix formulation. Set

$$
\mathbf v_n=
\begin{pmatrix}
S_{n+1}\\
S_n
\end{pmatrix},
\qquad
M_{\lambda,q}=
\begin{pmatrix}
\lambda&-q\\
1&0
\end{pmatrix}.
$$

Then $\mathbf v_{n+1}=M_{\lambda,q}\mathbf v_n$. The matrix has trace $\lambda$, determinant $q$, and eigenvalues $\alpha$ and $\beta$. Consequently, repeated recurrence evaluation is matrix evolution, while the critical-circle condition says that the two eigenmodes of this evolution have equal modulus. This also suggests a fast exponentiation variant: binary powering of $M_{\lambda,q}$ computes a single distant term $S_n$ in $O(\log n)$ matrix multiplications, improving on linear iteration when intermediate coefficients are not required.

The transfer-matrix view also clarifies numerical conditioning. Near the Ramanujan boundary, the two roots nearly coincide, so direct use of the quadratic formula can lose relative accuracy through subtraction. The recurrence avoids choosing roots and is usually preferable for exact integer parameters. For very large $n$ in floating-point arithmetic, normalized variables $R_n=S_n/q^{n/2}$ prevent unnecessary exponential scaling when $q>0$. They satisfy

$$
R_{n+2}=\frac{\lambda}{\sqrt q}R_{n+1}-R_n,
$$

and remain bounded by $2$ in the Ramanujan range.

## 10. Scope and limitations

The proved statements concern a single quadratic factor. They do not establish the full Bass–Ihara determinant identity, do not define the non-backtracking matrix of a specific graph, and do not enumerate primitive cycles. Accordingly, they do not prove that graph prime cycles have the same statistical distribution as ordinary primes.

The phrase “graph Riemann hypothesis” is meaningful in the established finite-graph setting only after trivial factors are separated and the complete nontrivial spectrum is assembled. Theorem 5.3 supplies the local implication from a Ramanujan eigenvalue bound to critical-circle zeros. It should not be interpreted as a statement about the zeros of the classical Riemann zeta function, nor as evidence that a finite graph reproduces its critical-strip statistics.

A direct comparison between cycle lengths and the prime-counting function $\pi(x)$ also requires normalization. In a regular graph, primitive-cycle growth naturally has scale $q^n/n$, whereas integer primes up to $x$ have scale $x/\log x$. Similarity of Euler-product structure does not erase this difference of variables and main terms.

## 11. Future work

A complete global theory should begin with oriented edges and the Hashimoto non-backtracking matrix $B$. The first target is a trace theorem asserting that $\operatorname{tr}(B^n)$ counts rooted closed non-backtracking walks of length $n$. Möbius inversion can then recover primitive-cycle counts from repetition data.

The next structural target is the Bass determinant identity, which connects $\det(I-uB)$ to adjacency and degree matrices. This would assemble the local factors studied here into the graph zeta function and clarify the contribution of trivial poles. The critical-circle theorem could then be lifted from one nontrivial eigenvalue to the complete nontrivial spectrum.

Concrete experiments should use exact graph constructions. Paley graphs and Lubotzky–Phillips–Sarnak graphs are natural candidates, but reliable certification calls for exact finite-field adjacency matrices and exact characteristic-polynomial factorizations rather than floating-point eigenvalues. Once global cycle counts are available, the natural first comparison is with $q^n/n$. Any comparison with $\pi(x)$ should state an explicit normalization and a precise statistic.

## 12. Conclusion

A local quadratic Ihara factor contains a complete elementary arithmetic. Its reciprocal roots factor the polynomial, their power sums form a Lucas sequence, and the recurrence forces exact cancellation in a finite generating series. The resulting explicit formula identifies the local logarithmic-derivative coefficients and isolates the two truncation terms. Under the Ramanujan inequality $\lambda^2\le 4q$, every local zero lies on $|u|=q^{-1/2}$, and the normalized coefficients become bounded trigonometric oscillations.

These results give a precise local bridge between adjacency spectra, recurrence sequences, and zeta zeros. They also mark the boundary of the conclusion: global primitive-cycle statistics require non-backtracking traces, Möbius inversion, and the full determinant identity. Within that boundary, the dictionary is exact and computationally effective.
