# The Cake–Plastic Spectral Bridge: A Cubic Portion Constant and the Padovan Matrix

**Aristotle**  
**15 July 2026**

## Abstract

Let $\rho$ denote the real number in $(0,1)$ satisfying $\rho^3+\rho^2=1$, and let $\mu=1+\rho$ be the candidate optimal ratio arising from the problem of balancing adjacent two-slice portions under successive radial cuts of a circular cake. This paper develops an exact algebraic and spectral interpretation of these constants. We prove existence and uniqueness of $\rho$, show that its reciprocal $p=\rho^{-1}$ is the plastic number characterized by $p^3=p+1$, and establish the identity $\mu=p^2$. We then consider the nonnegative Padovan transition matrix

$$
A=
\begin{pmatrix}
0&1&0\\
0&0&1\\
1&1&0
\end{pmatrix}
$$

and prove that $v=(1,p,p^2)^{\mathsf T}$ is a strictly positive eigenvector with eigenvalue $p$. Consequently, the cake portion constant is the square of a positive matrix eigenvalue. We also derive the bounds $1<p<2$ and $1<\mu<2$, give numerical algorithms for computing the constants and checking the identities, and discuss how the positive eigenvector suggests a self-similar three-state cutting strategy. The results isolate a precise common scaling law shared by circular portion balancing, the Padovan recurrence, and substitution dynamics. They do not assume or establish the global optimality of the candidate ratio; rather, they supply the algebraic connector needed for future upper- and lower-bound arguments.

## 1. Introduction

Consider a unit circular cake divided by radial cuts. The cuts determine cyclically ordered slices. A two-slice portion is the union of two adjacent slices, including the pair formed by the last and first slices in the cyclic order. At any finite stage, one may compare the largest two-slice portion with the smallest. The ratio of these two quantities measures imbalance: a ratio of $1$ means all adjacent pairs have equal size, while larger values indicate disparity.

For an infinite sequence of radial cuts, every finite prefix produces such a ratio. A natural minimax problem asks for a schedule whose worst ratio over all stages is as small as possible. The candidate constant studied here is

$$
\mu=1+\rho,
$$

where $\rho\in(0,1)$ solves

$$
\rho^3+\rho^2=1.
$$

The present paper concerns the exact structure of this candidate rather than the complete minimax theorem. In particular, it does not claim that every infinite cutting sequence must attain ratio at least $\mu$, nor does it specify and analyze a complete schedule attaining ratio at most $\mu$. Those geometric statements require definitions and invariants for the evolving cyclic configuration. Our goal is instead to prove that the proposed ratio belongs to a familiar and rigid algebraic system.

The key step is inversion. Setting $p=1/\rho$ turns the equation for $\rho$ into

$$
p^3=p+1.
$$

Thus $p$ is the plastic number, the cubic analogue of the golden ratio associated with Padovan-type recurrences. The same substitution also yields

$$
\mu=1+\rho=p^2.
$$

This already interprets the candidate imbalance ratio as two powers of a fundamental recurrence scale.

The spectral interpretation is equally direct but conceptually informative. The matrix

$$
A=
\begin{pmatrix}
0&1&0\\
0&0&1\\
1&1&0
\end{pmatrix}
$$

updates a triple by $(x,y,z)\mapsto(y,z,x+y)$. Its action captures a three-state shift-and-combine rule. The vector $(1,p,p^2)^{\mathsf T}$ is preserved in direction and expanded by $p$. All its entries are positive, so it can represent actual lengths, frequencies, or weights. This supplies an exact self-similar profile potentially relevant to iterative cutting constructions.

The paper is organized as follows. Section 2 defines the cake scale, plastic scale, portion constant, and transition matrix. Section 3 proves existence and uniqueness of the cake scale. Section 4 establishes the reciprocal cubic and the square identity. Section 5 proves the positive eigenvector theorem and connects the matrix to the Padovan recurrence. Section 6 derives elementary bounds. Section 7 presents numerical algorithms, Section 8 discusses applications and interpretation, and Sections 9–10 delimit the result and formulate future research directions.

## 2. Definitions and setting

### 2.1. Circular portions and the candidate ratio

A finite radial configuration consists of positive slice sizes

$$
s_0,s_1,\ldots,s_{m-1}>0,
\qquad
\sum_{i=0}^{m-1}s_i=1,
$$

listed in cyclic order. Indices are interpreted modulo $m$. The adjacent two-slice portions are

$$
q_i=s_i+s_{i+1},
\qquad i\in\{0,1,\ldots,m-1\}.
$$

The stage ratio is

$$
R(s)=\frac{\max_i q_i}{\min_i q_i}.
$$

Positivity of the slices makes the denominator positive. A radial refinement chooses one slice and replaces it by two positive slices having the same total size. An infinite cutting schedule is a sequence of such refinements. Its worst-stage ratio is the supremum of $R(s)$ over its finite stages. The associated minimax constant is the infimum of these worst-stage ratios over all admissible infinite schedules.

This framework motivates, but is not required for, the algebraic results below. We study the proposed value $\mu=1+\rho$ independently of whether the minimax constant has already been identified with it.

### 2.2. The cake polynomial and scale

**Definition 2.1 (Cake polynomial).** For $x\in\mathbb R$, define

$$
f(x)=x^3+x^2.
$$

**Definition 2.2 (Cake scale).** The cake scale is a number $\rho\in(0,1)$ satisfying

$$
f(\rho)=1,
$$

or equivalently

$$
\rho^3+\rho^2=1.
$$

Existence and uniqueness will be proved in Section 3, so this definition selects a single real number.

**Definition 2.3 (Candidate portion constant).** Define

$$
\mu=1+\rho.
$$

### 2.3. Reciprocal scale and transition matrix

**Definition 2.4 (Plastic scale).** Define

$$
p=\rho^{-1}=\frac1\rho.
$$

**Definition 2.5 (Padovan transition matrix).** Define

$$
A=
\begin{pmatrix}
0&1&0\\
0&0&1\\
1&1&0
\end{pmatrix}.
$$

For a column vector $(x,y,z)^{\mathsf T}$, this matrix acts as

$$
A
\begin{pmatrix}x\\y\\z\end{pmatrix}
=
\begin{pmatrix}y\\z\\x+y\end{pmatrix}.
$$

**Definition 2.6 (Plastic profile).** Define the column vector

$$
v=
\begin{pmatrix}1\\p\\p^2\end{pmatrix}.
$$

The main objective is to connect $\mu$, $p$, $A$, and $v$ exactly.

## 3. Existence and uniqueness of the cake scale

We begin by showing that Definition 2.2 is well posed.

**Lemma 3.1 (Strict monotonicity).** The function $f(x)=x^3+x^2$ is strictly increasing on $[0,\infty)$.

**Proof sketch.** Let $0\leq x<y$. The factorization

$$
y^2-x^2=(y-x)(x+y)
$$

is positive because $y-x>0$ and $x+y>0$. Similarly,

$$
y^3-x^3=(y-x)(x^2+xy+y^2)>0.
$$

Adding the two inequalities gives $f(y)-f(x)>0$. Hence $f(x)<f(y)$. $\square$

**Theorem 3.2 (Existence and uniqueness of the cake scale).** There exists exactly one $\rho\in(0,1)$ such that

$$
\rho^3+\rho^2=1.
$$

**Proof sketch.** The polynomial $f$ is continuous. At the endpoints,

$$
f(0)=0<1,
\qquad
f(1)=2>1.
$$

The intermediate value theorem therefore produces at least one $\rho\in(0,1)$ satisfying $f(\rho)=1$. If $\rho_1$ and $\rho_2$ were two such points, strict monotonicity on $[0,\infty)$ would force $\rho_1=\rho_2$. $\square$

This theorem gives two inequalities that will be used repeatedly:

$$
0<\rho<1.
$$

It also permits stable numerical computation by any root-finding method that respects the bracket $[0,1]$.

## 4. The plastic number and the square identity

We now transform the defining cubic by taking a reciprocal.

**Theorem 4.1 (Reciprocal cubic theorem).** Let $p=1/\rho$. Then $p>0$ and

$$
p^3=p+1.
$$

**Proof sketch.** Positivity follows from $\rho>0$. Divide

$$
\rho^3+\rho^2=1
$$

by the positive quantity $\rho^3$. This yields

$$
1+\frac1\rho=\frac1{\rho^3}.
$$

Substituting $p=1/\rho$ gives $1+p=p^3$. $\square$

The positive real solution of $p^3=p+1$ is conventionally called the plastic number. Uniqueness can also be read from Theorem 3.2 under the reciprocal correspondence between $(0,1)$ and $(1,\infty)$. For completeness, the polynomial $g(x)=x^3-x-1$ is strictly increasing for $x\geq1$ because $g'(x)=3x^2-1>0$ there, while $g(1)=-1$ and $g(2)=5$. Hence it has exactly one root in $(1,2)$.

**Theorem 4.2 (Cake–Plastic Identity).** The candidate portion constant is the square of the plastic number:

$$
\mu=p^2.
$$

**Proof sketch.** Divide the cake equation by $\rho^2>0$:

$$
\rho+1=\frac1{\rho^2}.
$$

The left-hand side is $\mu=1+\rho$, while the right-hand side is $p^2$. Therefore $\mu=p^2$. $\square$

An equivalent derivation starts from $p^3=p+1$ and divides by $p>0$:

$$
p^2=1+\frac1p=1+\rho.
$$

This identity is the first main bridge. It equates an additive expression in the contracting scale $\rho$ with a multiplicative expression in the expanding scale $p$.

**Corollary 4.3 (Equivalent descriptions).** The four relations

$$
\rho^3+\rho^2=1,
\qquad
p=\rho^{-1},
\qquad
p^3=p+1,
\qquad
\mu=1+\rho=p^2
$$

are mutually compatible and determine all three positive constants $\rho$, $p$, and $\mu$ from any one of them.

**Proof sketch.** Theorems 3.2, 4.1, and 4.2 establish the forward implications. Conversely, a positive $p$ satisfying $p^3=p+1$ obeys $p>1$; setting $\rho=1/p$ and dividing by $p^3$ gives $\rho^3+\rho^2=1$. Uniqueness then identifies the same $\rho$, and $\mu$ follows. $\square$

## 5. Positive spectral structure and Padovan dynamics

### 5.1. The eigenvector identity

**Lemma 5.1 (Positivity of the plastic profile).** Every coordinate of

$$
v=(1,p,p^2)^{\mathsf T}
$$

is strictly positive.

**Proof sketch.** The first coordinate is $1>0$. Since $p=1/\rho$ and $\rho>0$, we have $p>0$, and therefore $p^2>0$. $\square$

**Theorem 5.2 (Positive eigenvector theorem).** For the Padovan transition matrix $A$ and plastic profile $v$,

$$
Av=pv.
$$

Thus $p$ is a positive eigenvalue of $A$ with a strictly positive eigenvector.

**Proof sketch.** Direct multiplication gives

$$
Av=
\begin{pmatrix}
p\\p^2\\1+p\end{pmatrix}.
$$

The reciprocal cubic theorem gives $1+p=p^3$. Hence

$$
Av=
\begin{pmatrix}
p\\p^2\\p^3\end{pmatrix}
=p
\begin{pmatrix}1\\p\\p^2\end{pmatrix}
=pv.
$$

Strict positivity follows from Lemma 5.1. $\square$

**Theorem 5.3 (Combined cake–spectral connector).** The candidate portion ratio is the square of a positive eigenvalue of $A$. More precisely, there exist $p>0$ and a vector $v$ with all coordinates positive such that

$$
Av=pv,
\qquad
\mu=p^2,
$$

and these are realized by the plastic number $p$ and the profile $v=(1,p,p^2)^{\mathsf T}$.

**Proof sketch.** Combine Theorem 4.2, Lemma 5.1, and Theorem 5.2. $\square$

This is the central result. It packages the exact relation between the cake constant and three-state linear dynamics without requiring asymptotic arguments.

### 5.2. The Padovan recurrence

The matrix $A$ encodes a scalar recurrence. Let a sequence $(a_n)_{n\geq0}$ satisfy

$$
a_{n+3}=a_{n+1}+a_n.
$$

If the state vector is

$$
w_n=
\begin{pmatrix}a_n\\a_{n+1}\\a_{n+2}\end{pmatrix},
$$

then

$$
w_{n+1}=Aw_n.
$$

Indeed,

$$
Aw_n=
\begin{pmatrix}a_{n+1}\\a_{n+2}\\a_n+a_{n+1}\end{pmatrix}
=
\begin{pmatrix}a_{n+1}\\a_{n+2}\\a_{n+3}\end{pmatrix}.
$$

This is a standard Padovan-type recurrence. The eigenvector theorem exhibits an exact geometric solution.

**Corollary 5.4 (Exact geometric Padovan solution).** The sequence $a_n=p^n$ satisfies

$$
a_{n+3}=a_{n+1}+a_n
$$

for every $n\geq0$.

**Proof sketch.** Since $p^3=p+1$, multiplication by $p^n$ gives

$$
p^{n+3}=p^{n+1}+p^n.
$$

Thus $a_n=p^n$ satisfies the recurrence. $\square$

The profile $v=(1,p,p^2)^{\mathsf T}$ is simply the initial three-term window of this geometric solution. Applying $A$ shifts the window and multiplies it by $p$.

### 5.3. Substitution interpretation

The update

$$
(x,y,z)\mapsto(y,z,x+y)
$$

can be interpreted as a three-state substitution or production rule at the level of counts or weights. Positivity is essential: the profile $1:p:p^2$ can represent physical quantities. If a state has this profile, one update returns the same profile at scale $p$.

The theorem establishes a positive eigenpair, but we deliberately avoid claiming more than has been shown. In particular, identifying $p$ as the spectral radius, proving uniqueness among all positive eigenvalues directly from the characteristic polynomial, and deriving convergence of arbitrary positive recurrence ratios require additional arguments. Those are natural extensions discussed later.

## 6. Quantitative bounds

The defining interval for $\rho$ immediately bounds the portion constant, and a slightly sharper lower bound on $\rho$ bounds $p$.

**Lemma 6.1 (Half-unit lower bound).** The cake scale satisfies

$$
\rho>\frac12.
$$

**Proof sketch.** If $0<\rho\leq1/2$, monotonicity of $f$ gives

$$
1=f(\rho)\leq f\left(\frac12\right)
=\frac18+\frac14
=\frac38,
$$

which is impossible. Therefore $\rho>1/2$. $\square$

**Theorem 6.2 (Bounds for the plastic number).** The plastic number satisfies

$$
1<p<2.
$$

**Proof sketch.** Since $0<\rho<1$, reciprocal order gives $p=1/\rho>1$. Lemma 6.1 gives $\rho>1/2$, so $p<2$. $\square$

**Theorem 6.3 (Bounds for the candidate portion constant).** The candidate ratio satisfies

$$
1<\mu<2.
$$

**Proof sketch.** From $0<\rho<1$, adding $1$ throughout gives

$$
1<1+\rho<2.
$$

Since $\mu=1+\rho$, the result follows. $\square$

These inequalities agree with the intended interpretation. A ratio of positive maximum to minimum is at least $1$. The proposed value is strictly larger than perfect equality but strictly smaller than a doubling.

## 7. Numerical algorithms and examples

The exact equations admit several simple and stable computational procedures.

### 7.1. Bisection for the cake scale

Because $f(x)=x^3+x^2-1$ is continuous and strictly increasing on $[0,1]$, bisection produces certified nested intervals containing $\rho$.

**Algorithm 7.1 (Monotone cubic bisection).** Begin with $L=0$ and $U=1$. At each iteration, set $M=(L+U)/2$. If $M^3+M^2<1$, replace $L$ by $M$; otherwise replace $U$ by $M$. After $N$ steps, output $(L+U)/2$.

The bracket width is $2^{-N}$, so the midpoint error is at most $2^{-(N+1)}$. The algorithm uses constant memory and $O(N)$ arithmetic operations. To obtain absolute error at most $\varepsilon$, it suffices to take $N=O(\log(1/\varepsilon))$.

For example, the computation gives

$$
\rho\approx0.7548776662466927.
$$

Then

$$
p=\frac1\rho\approx1.324717957244746,
$$

and

$$
\mu=1+\rho\approx1.754877666246693.
$$

The independent expression $p^2$ gives the same value to numerical precision.

### 7.2. Newton iteration

For faster local convergence, apply Newton’s method to

$$
h(p)=p^3-p-1.
$$

The update is

$$
p_{k+1}=p_k-\frac{p_k^3-p_k-1}{3p_k^2-1}.
$$

Starting from a point in $(1,2)$, such as $p_0=3/2$, the iteration rapidly converges to $p$. Once close to the root, the number of correct digits approximately doubles at each step. Each iteration uses constant memory and a constant number of arithmetic operations, though the cost of high-precision arithmetic grows with the requested precision.

### 7.3. Eigenpair residual

Given an approximation $\widehat p$, form

$$
\widehat v=(1,\widehat p,\widehat p^2)^{\mathsf T}
$$

and compute the residual

$$
r=A\widehat v-\widehat p\widehat v.
$$

Its first two coordinates vanish algebraically; the third is

$$
r_3=1+\widehat p-\widehat p^3.
$$

Thus the matrix residual is exactly the cubic residual. This is a useful consistency check: root accuracy and eigenpair accuracy are two views of the same numerical error.

### 7.4. Padovan growth experiment

Starting from any chosen triple $(a_0,a_1,a_2)$, repeatedly apply

$$
(a_n,a_{n+1},a_{n+2})
\mapsto
(a_{n+1},a_{n+2},a_n+a_{n+1}).
$$

For the exact profile $(1,p,p^2)$, each update multiplies every coordinate by $p$. For common positive integer initial conditions, numerical experiments suggest that successive-term ratios approach $p$, although a general convergence theorem is outside the proved results of this paper. Such experiments help visualize the role of the positive eigenvector while keeping the distinction between exact identity and asymptotic conjecture clear.

## 8. Applications and mathematical interpretation

### 8.1. A template for self-similar cutting

An infinite cutting strategy is difficult to control because every refinement changes neighboring portions. A useful design principle is to classify local configurations into finitely many states and arrange that refinement transforms those states by a substitution rule. The matrix $A$ supplies a particularly economical three-state rule, and the profile $(1,p,p^2)$ supplies its invariant proportions.

If slice or gap types can be assigned weights proportional to $1$, $p$, and $p^2$, then one substitution stage scales the profile by $p$. The identity $p^2=1+\rho$ makes the target two-slice ratio directly available within the same scale hierarchy. This does not yet prove that every intermediate circular configuration obeys the desired ratio, but it identifies the quantities a construction should preserve.

### 8.2. Recurrence theory

The relation $p^3=p+1$ is exactly the characteristic relation obtained from a geometric trial solution $a_n=\lambda^n$ in

$$
a_{n+3}=a_{n+1}+a_n.
$$

Substitution gives

$$
\lambda^{n+3}=\lambda^{n+1}+\lambda^n,
$$

which reduces to $\lambda^3=\lambda+1$ for nonzero $\lambda$. The plastic number is therefore the positive geometric growth factor of the Padovan recurrence. The cake ratio $p^2$ represents two recurrence steps of that scale.

### 8.3. Positive linear systems

Nonnegative matrices arise in population dynamics, input-output models, symbolic substitutions, automata, and scheduling systems. A strictly positive eigenvector describes a composition preserved by the update, while the associated positive eigenvalue gives its growth factor. Here the interpretation is exact:

$$
(1,p,p^2)\mapsto(p,p^2,p^3)=p(1,p,p^2).
$$

This can model three age classes, three task types, or three symbolic blocks, provided the update follows $(x,y,z)\mapsto(y,z,x+y)$. The result does not depend on a probabilistic or asymptotic approximation.

### 8.4. Additive versus multiplicative descriptions

The equality

$$
1+\rho=p^2
$$

joins two modes of reasoning. The left side is additive and naturally resembles the size of a pair: a base unit plus an adjacent contribution. The right side is multiplicative and naturally resembles repeated scaling. Their equality is forced by the cubic. Such dual descriptions are valuable because geometric inequalities often prefer sums, while recurrence and spectral arguments prefer powers.

### 8.5. Comparison with the golden ratio

The golden ratio $\varphi$ satisfies $\varphi^2=\varphi+1$ and is attached to a two-state Fibonacci transition. The plastic number satisfies $p^3=p+1$ and is attached here to a three-state Padovan transition. The analogy is structural rather than identical: quadratic versus cubic, two-step versus three-step memory, and eigenprofiles $(1,\varphi)$ versus $(1,p,p^2)$. This comparison helps explain why a cubic constant is natural when three local states interact.

## 9. Scope, limitations, and discussion

The established results are exact:

1. there is a unique $\rho\in(0,1)$ with $\rho^3+\rho^2=1$;
2. its reciprocal $p$ satisfies $p^3=p+1$;
3. the candidate portion constant obeys $\mu=1+\rho=p^2$;
4. the Padovan matrix has the strictly positive eigenpair $(p,(1,p,p^2)^{\mathsf T})$;
5. $1<p<2$ and $1<\mu<2$.

These statements establish a bridge, not the full optimization theorem for circular cutting. To prove that the minimax constant for infinite radial cutting is exactly $\mu$, two additional directions are necessary.

First, an upper-bound construction must define a complete infinite schedule and prove that every finite stage has adjacent-pair ratio at most $p^2$. A substitution suggested by $A$ and $v$ is a promising organizing principle, but the cyclic adjacency conditions and intermediate stages must be checked.

Second, a lower-bound theorem must show that every infinite schedule has some stage with ratio at least $p^2$. Such a result is strategy-independent and likely requires an invariant, potential, or finite-state obstruction. The cubic relation suggests that a sharp transition inequality may close only when the threshold satisfies $p^3=p+1$.

Care is also needed with spectral terminology. The existence of a positive eigenpair has been proved directly. A full Perron–Frobenius interpretation would additionally establish the spectral radius and the relevant uniqueness or dominance properties. These are plausible for the nonnegative matrix $A$, but they are logically separate results.

## 10. Future work

Several concrete extensions emerge.

### 10.1. Finite circular configuration theory

One should develop cyclic slice vectors, adjacent-pair portions, stage ratios, and one-cut refinements as a unified finite theory. Rotation of the starting index must leave the ratio invariant. Positive rescaling of every slice must also leave it invariant, because both the maximum and minimum portions scale by the same factor.

### 10.2. A substitution-based upper bound

The three weights $(1,p,p^2)$ and update matrix $A$ should be used to define a self-similar cutting schedule. The main challenge is to prove that all stages, including transitions between complete substitution levels, keep the portion ratio at most

$$
p^2=1+\rho.
$$

### 10.3. A universal lower-bound obstruction

A sharp lower bound may arise from a potential assigned to a finite set of local states. Its transition inequalities should encode the impossibility of maintaining all adjacent portions below a threshold smaller than $p^2$. The equality case may reduce to $p^3=p+1$, explaining the same cubic from an adversarial direction.

### 10.4. Asymptotic Padovan convergence

For positive solutions of the Padovan recurrence, one expects appropriate successive ratios to converge to $p$ under nondegenerate initial conditions. Proving this requires control of the other roots or a positive-matrix convergence argument. Such a theorem would upgrade the exact eigenvector identity to a dynamical attractor statement.

### 10.5. Spectral strengthening

Computing

$$
\det(\lambda I-A)=\lambda^3-\lambda-1
$$

would connect the matrix directly to the plastic polynomial. One can then seek a proof that $p$ is the unique positive eigenvalue and equals the spectral radius. This would justify a full Perron–Frobenius description.

## 11. Conclusion

The candidate two-slice cake ratio is governed by a compact chain of exact identities. The unique number $\rho\in(0,1)$ satisfying

$$
\rho^3+\rho^2=1
$$

has reciprocal equal to the plastic number $p$, characterized by

$$
p^3=p+1.
$$

The candidate ratio is

$$
\mu=1+\rho=p^2.
$$

Finally, the positive profile $(1,p,p^2)^{\mathsf T}$ obeys

$$
A
\begin{pmatrix}1\\p\\p^2\end{pmatrix}
=p
\begin{pmatrix}1\\p\\p^2\end{pmatrix}
$$

for the Padovan transition matrix $A$. Thus a local balancing constant for adjacent circular portions is exactly the square of a positive three-state growth factor.

This spectral bridge identifies the algebraic architecture behind the proposed optimum. The remaining work is geometric and combinatorial: turn the positive profile into a complete strategy and turn the cubic threshold into a universal obstruction. Together, those directions would transform an exact connector into a full optimality theory.
