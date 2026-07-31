# Unitarity Obstructions and Design Criteria for Quantum Exponential–Logarithm Activations

**Aristotle**  
**31 July 2026**

## Abstract

We study the matrix-valued activation

$$
N(H_1,H_2)=\exp(iH_1)\,\Log(I+iH_2),
$$

where $H_1$ and $H_2$ are Hermitian elements of a nontrivial unital complex $C^*$-algebra, $I$ is the identity, and $\Log$ is the principal logarithm defined by continuous functional calculus. The expression is motivated by replacing scalar exponential and logarithmic operations in exponential–matrix-logarithm architectures with operator analogues. We prove that the raw activation is not unitary-valued: for every $H_1$, setting $H_2=0$ gives $N(H_1,0)=0$, which cannot be unitary. More generally, we prove that a unitary output forces the logarithmic factor $\Log(I+iH_2)$ itself to be unitary. Equivalently, multiplication by the unitary exponential factor cannot correct any failure of unitarity in the logarithmic factor. We give a spectral characterization in finite dimensions, derive a practical numerical diagnostic, and describe algorithms illustrating the obstruction. The results distinguish the false claim that the raw expression defines an $SU(2)$-valued activation on its full domain from the still-open restricted question of whether selected parameters can cover $U(2)$ or $SU(2)$. We conclude with mathematically coherent repairs based on domain restriction, polar normalization, and determinant correction.

## 1. Introduction

Parameterized quantum circuits require transformations compatible with quantum kinematics. For a closed finite-dimensional system, deterministic reversible evolution is represented by a unitary matrix. In a single-qubit model the ambient gate group is $U(2)$, while physically significant phase-normalized gates are often represented by

$$
SU(2)=\{U\in M_2(\mathbb C):U^*U=I,\ \det U=1\}.
$$

A natural route from classical neural architectures to quantum ones is to replace scalar functions by matrix functions. If $H$ is Hermitian, the exponential $\exp(iH)$ is unitary, making it a standard and robust parameterization of quantum gates. This encourages the proposed exponential–logarithm expression

$$
N(H_1,H_2)=\exp(iH_1)\,\Log(I+iH_2).
$$

At first sight, the formula appears expressive. For $2\times2$ matrices, each Hermitian input contributes four real parameters, whereas $SU(2)$ is three-dimensional. The first factor is always unitary, and the second uses an analytically rich matrix function. These observations may suggest that the map could implement arbitrary single-qubit gates.

Such parameter counting does not establish either codomain membership or surjectivity. A map can have many parameters and nevertheless leave a target manifold, collapse dimensions, or encounter singularities. The first question must therefore be whether $N(H_1,H_2)$ is unitary for all Hermitian inputs. We answer this question negatively with a universal boundary case. We then prove a factor criterion showing that the first exponential can neither mask nor repair a nonunitary logarithmic factor.

The results hold not only for matrices but in every nontrivial unital complex $C^*$-algebra, including bounded operators on a two-dimensional complex Hilbert space. This generality makes clear that the obstruction is algebraic rather than a numerical artifact of a chosen representation.

The contributions are:

1. a precise definition of the raw quantum exponential–logarithm activation in a unital $C^*$-algebra;
2. a zero-input theorem showing that every choice with $H_2=0$ produces zero;
3. a proof that the activation is therefore not unitary-valued on its natural full domain;
4. an exclusion theorem showing that no first Hamiltonian repairs the zero-second-input case;
5. a necessary, and in fact equivalent, condition reducing output unitarity to unitarity of the logarithmic factor;
6. a finite-dimensional spectral criterion and numerical procedures for diagnosing the obstruction; and
7. design alternatives that preserve unitarity by construction.

A crucial logical distinction runs throughout. Our results disprove the claim that the raw formula is an everywhere $SU(2)$-valued activation. They do not by themselves disprove the weaker set-theoretic possibility that every target in $SU(2)$ might occur for at least one specially chosen pair $(H_1,H_2)$. The latter question requires restrictions ensuring that the logarithmic factor lies in the unitary group.

## 2. Algebraic and analytic setting

### 2.1 Unital $C^*$-algebras

Let $A$ be a complex unital $C^*$-algebra, with identity $I$, involution $a\mapsto a^*$, multiplication, and norm satisfying

$$
\|a^*a\|=\|a\|^2.
$$

The canonical example is $A=M_n(\mathbb C)$ with $a^*$ equal to conjugate transpose and the operator norm. We assume that $A$ is nontrivial, meaning $0\ne I$.

**Definition 2.1 (Hermitian element).** An element $H\in A$ is Hermitian, or self-adjoint, if $H^*=H$.

**Definition 2.2 (Unitary element).** An element $U\in A$ is unitary if

$$
U^*U=UU^*=I.
$$

Unitary elements form a group under multiplication. If $U$ is unitary, then $U^{-1}=U^*$, and in a nontrivial algebra $U\ne0$.

**Lemma 2.3 (Closure properties).** If $U$ and $V$ are unitary, then $U^*$ and $UV$ are unitary.

**Proof sketch.** Direct calculation gives $(U^*)^*U^*=UU^*=I$ and $U^*(U^*)=U^*U=I$. Similarly,

$$
(UV)^*(UV)=V^*U^*UV=V^*V=I,
$$

with the reverse product treated analogously. $\square$

### 2.2 Exponential and principal logarithm

For $a\in A$, define the exponential by the norm-convergent series

$$
\exp(a)=\sum_{k=0}^{\infty}\frac{a^k}{k!}.
$$

**Lemma 2.4 (Hermitian exponential is unitary).** If $H$ is Hermitian, then $\exp(iH)$ is unitary.

**Proof sketch.** Since $(iH)^*=-iH$, functional calculus gives $\exp(iH)^*=\exp(-iH)$. The two exponentials commute and multiply to $\exp(0)=I$. $\square$

For a normal element whose spectrum avoids the branch cut $(-\infty,0]$, the principal logarithm is defined by continuous or holomorphic functional calculus. If $H$ is Hermitian, then the spectrum of $I+iH$ lies on the vertical line $1+i\mathbb R$, which is disjoint from the nonpositive real axis. Thus $\Log(I+iH)$ is well-defined. The scalar branch is

$$
\Log z=\log|z|+i\Arg z,
$$

with $\Arg z\in(-\pi,\pi)$.

A basic identity is

$$
\Log(I)=0.
$$

### 2.3 The activation

**Definition 2.5 (Raw quantum exponential–logarithm activation).** For Hermitian $H_1,H_2\in A$, define

$$
N(H_1,H_2)=\exp(iH_1)\,\Log(I+iH_2).
$$

We write

$$
E(H_1)=\exp(iH_1),\qquad L(H_2)=\Log(I+iH_2),
$$

so that $N(H_1,H_2)=E(H_1)L(H_2)$. Lemma 2.4 guarantees that $E(H_1)$ is unitary. No corresponding general statement holds for $L(H_2)$.

## 3. The zero-input obstruction

The key obstruction is visible at the origin of the second parameter space.

**Theorem 3.1 (Zero-Input Theorem).** For every Hermitian $H_1\in A$,

$$
N(H_1,0)=0.
$$

**Proof.** Substituting $H_2=0$ gives

$$
N(H_1,0)=\exp(iH_1)\Log(I+i0)
=\exp(iH_1)\Log(I)
=\exp(iH_1)0
=0.
$$

$\square$

This immediately resolves the full-domain codomain question.

**Theorem 3.2 (Failure of global unitary-valuedness).** In every nontrivial unital complex $C^*$-algebra, there exist Hermitian $H_1,H_2$ for which $N(H_1,H_2)$ is not unitary. In particular, the raw activation does not define a map from all Hermitian pairs into $U(A)$, and for $A=M_2(\mathbb C)$ it does not define an unrestricted map into $SU(2)$.

**Proof.** Choose $H_1=0$ and $H_2=0$. By Theorem 3.1 the output is zero. If zero were unitary, then

$$
0^*0=I,
$$

which would imply $0=I$, contradicting nontriviality. $\square$

The obstruction is stronger than the existence statement suggests: every first input fails when the second input is zero.

**Theorem 3.3 (Unitary-target exclusion at zero second input).** Let $H_1$ be Hermitian and let $U$ be any unitary element of a nontrivial unital complex $C^*$-algebra. Then

$$
N(H_1,0)\ne U.
$$

**Proof.** Theorem 3.1 gives $N(H_1,0)=0$. A unitary element cannot equal zero because $U^*U=I\ne0$. Therefore the two elements are unequal. $\square$

This theorem rules out the possibility that $H_1$ could compensate for the degenerate logarithmic factor. The failure is independent of the expressivity of the Hermitian exponential.

## 4. The logarithmic factor controls unitarity

The zero case belongs to a general phenomenon. Left multiplication by a unitary element preserves unitary membership.

**Lemma 4.1 (Unitary cancellation).** Let $E\in A$ be unitary and $L\in A$ arbitrary. If $EL$ is unitary, then $L$ is unitary.

**Proof.** Since $E$ is unitary, $E^*$ is unitary. If $EL$ is unitary, closure under products implies that $E^*(EL)$ is unitary. Associativity and $E^*E=I$ yield

$$
E^*(EL)=(E^*E)L=IL=L.
$$

Hence $L$ is unitary. $\square$

The converse is immediate from closure under products, giving an equivalence.

**Corollary 4.2 (Factor equivalence).** If $E$ is unitary, then

$$
EL\text{ is unitary}\quad\Longleftrightarrow\quad L\text{ is unitary}.
$$

Applying this to the activation gives the central structural result.

**Theorem 4.3 (Log-Factor Necessity Theorem).** For Hermitian $H_1,H_2\in A$, if $N(H_1,H_2)$ is unitary, then

$$
\Log(I+iH_2)
$$

is unitary.

**Proof.** Set $E=\exp(iH_1)$ and $L=\Log(I+iH_2)$. Lemma 2.4 makes $E$ unitary. Since $N(H_1,H_2)=EL$, Lemma 4.1 applies. $\square$

**Corollary 4.4 (Nonunitary-log obstruction).** If $\Log(I+iH_2)$ is not unitary, then $N(H_1,H_2)$ is not unitary for every Hermitian $H_1$.

**Proof.** This is the contrapositive of Theorem 4.3. $\square$

One can also see the result through a Gram identity.

**Lemma 4.5 (Preservation of the Gram element).** For Hermitian $H_1,H_2$,

$$
N(H_1,H_2)^*N(H_1,H_2)
=L(H_2)^*L(H_2).
$$

**Proof.** With $E=E(H_1)$ and $L=L(H_2)$,

$$
(EL)^*(EL)=L^*E^*EL=L^*L.
$$

$\square$

In finite dimensions, Lemma 4.5 implies that $N(H_1,H_2)$ and $L(H_2)$ have exactly the same singular values. Therefore $H_1$ changes the left singular vectors but cannot change norm distortion, rank, invertibility, or distance from unitarity as measured by $\|L^*L-I\|$ in any unitarily invariant norm.

## 5. Finite-dimensional spectral characterization

Let $A=M_n(\mathbb C)$ and let $H_2$ be Hermitian. By the spectral theorem there are a unitary matrix $Q$ and real numbers $\lambda_1,\ldots,\lambda_n$ such that

$$
H_2=Q\operatorname{diag}(\lambda_1,\ldots,\lambda_n)Q^*.
$$

Functional calculus yields

$$
L(H_2)=Q\operatorname{diag}\bigl(\Log(1+i\lambda_1),\ldots,
\Log(1+i\lambda_n)\bigr)Q^*.
$$

Because this matrix is normal, it is unitary exactly when all its eigenvalues have modulus one.

**Theorem 5.1 (Spectral unitary criterion).** For Hermitian $H_2\in M_n(\mathbb C)$, the logarithmic factor $L(H_2)=\Log(I+iH_2)$ is unitary if and only if

$$
|\Log(1+i\lambda_j)|=1
$$

for every eigenvalue $\lambda_j$ of $H_2$.

**Proof sketch.** The displayed diagonalization gives

$$
L(H_2)^*L(H_2)
=Q\operatorname{diag}\bigl(|\Log(1+i\lambda_1)|^2,\ldots,
|\Log(1+i\lambda_n)|^2\bigr)Q^*.
$$

This equals $I$ exactly when every diagonal entry is $1$. $\square$

For real $t$, the principal argument of $1+it$ is $\arctan t$ and its modulus is $\sqrt{1+t^2}$. Hence

$$
\Log(1+it)=\frac12\log(1+t^2)+i\arctan t,
$$

and

$$
|\Log(1+it)|^2
=\frac14\log^2(1+t^2)+\arctan^2t.
$$

Define the scalar diagnostic

$$
g(t)=\frac14\log^2(1+t^2)+\arctan^2t-1.
$$

Then the logarithmic factor is unitary precisely when every eigenvalue $\lambda_j$ of $H_2$ is a zero of $g$. In particular, $g(0)=-1$, so any zero eigenvalue of $H_2$ forces a zero eigenvalue of $L(H_2)$ and prevents unitarity.

**Corollary 5.2 (Kernel obstruction).** If a finite-dimensional Hermitian $H_2$ has $0$ as an eigenvalue, then $N(H_1,H_2)$ is nonunitary for every Hermitian $H_1$.

**Proof sketch.** The corresponding eigenvalue of $L(H_2)$ is $\Log(1)=0$, which has modulus different from one. Apply Theorem 5.1 and Corollary 4.4. $\square$

For a scalar second Hamiltonian $H_2=tI$,

$$
L(H_2)=\Log(1+it)I.
$$

Thus scalar choices reduce the matrix condition to the one-dimensional equation $g(t)=0$. The values $g(0)=-1$ and the eventual growth of the logarithmic term suggest an intermediate-value route to nonzero roots. Producing a certified interval for such a root, and incorporating the resulting phase into a complete $U(2)$ or $SU(2)$ coverage theorem, are explicit next tasks.

## 6. Numerical algorithms and examples

### 6.1 Stable evaluation by spectral calculus

Directly evaluating a generic matrix logarithm can obscure the special structure of $I+iH_2$. For Hermitian $H_2$, diagonalization provides a transparent algorithm.

**Algorithm 6.1 (Hermitian spectral activation evaluation).**

**Input:** Hermitian matrices $H_1,H_2\in M_n(\mathbb C)$.

1. Compute eigendecompositions $H_k=Q_kD_kQ_k^*$ for $k=1,2$.
2. Form
   $$
   E=Q_1\operatorname{diag}(e^{i(D_1)_{jj}})Q_1^*.
   $$
3. Form
   $$
   L=Q_2\operatorname{diag}(\Log(1+i(D_2)_{jj}))Q_2^*.
   $$
4. Return $N=EL$, together with residuals
   $$
   r_L=\|L^*L-I\|_F,
   \qquad
   r_N=\|N^*N-I\|_F.
   $$

Hermitian eigendecomposition costs $O(n^3)$ time and $O(n^2)$ storage. Matrix multiplication has the same asymptotic time. Lemma 4.5 predicts $r_L=r_N$ up to floating-point error.

### 6.2 Representative cases

For $H_1=\operatorname{diag}(0.3,-0.7)$ and $H_2=0$, the algorithm gives $L=0$ and $N=0$. The residual is

$$
\|N^*N-I\|_F=\|I\|_F=\sqrt{2},
$$

so the output is maximally separated from satisfying the unitary identity in this simple Frobenius measure.

For a generic Hermitian second input such as

$$
H_2=
\begin{pmatrix}
0.8 & 0.2-0.1i\\
0.2+0.1i & -0.4
\end{pmatrix},
$$

the eigenvalues of $H_2$ determine two scalar values $\Log(1+i\lambda_j)$. Unless both happen to have modulus one, $L$ is nonunitary. Changing $H_1$ alters $N$ but leaves $N^*N=L^*L$ unchanged.

### 6.3 Scalar root search

A bisection procedure can explore the equation $g(t)=0$.

**Algorithm 6.2 (Scalar unit-circle intersection search).**

**Input:** numbers $a<b$ with $g(a)g(b)\le0$ and tolerance $\varepsilon>0$.

1. While $b-a>\varepsilon$, set $m=(a+b)/2$.
2. If $g(a)g(m)\le0$, replace $b$ by $m$; otherwise replace $a$ by $m$.
3. Return $(a+b)/2$.

After $k$ iterations the interval width is $(b-a)/2^k$, so obtaining width at most $\varepsilon$ requires $O(\log((b-a)/\varepsilon))$ evaluations and $O(1)$ additional storage. A floating-point root is exploratory rather than a proof; a rigorous coverage result would require certified interval bounds for the transcendental functions.

## 7. Consequences for single-qubit coverage

Every $U\in U(2)$ has a Hermitian logarithm and may be expressed as $U=\exp(iH)$ for some Hermitian $H$. This fact makes the first factor highly expressive, but it does not establish coverage by the product under an arbitrary second input.

Suppose a selected $H_2$ makes $L(H_2)$ unitary. Then for a target $U$, the equation

$$
\exp(iH_1)L(H_2)=U
$$

is equivalent to

$$
\exp(iH_1)=U L(H_2)^*.
$$

The right-hand side is unitary, so finite-dimensional exponential surjectivity supplies a Hermitian $H_1$. Therefore any single fixed admissible unitary logarithmic factor would be enough for $U(n)$ coverage. Establishing such a factor and tracking branch and determinant conditions are the essential next steps.

For $SU(2)$, determinant bookkeeping is necessary. Since

$$
\det(\exp(iH_1))=\exp(i\operatorname{tr}H_1),
$$

the determinant-one condition on the product becomes

$$
\exp(i\operatorname{tr}H_1)\det L(H_2)=1.
$$

If $H_2=tI$ and $\Log(1+it)=e^{i\theta}$ has unit modulus, then in dimension two

$$
\det L(H_2)=e^{2i\theta}.
$$

Thus the trace must satisfy

$$
\operatorname{tr}H_1+2\theta\equiv0\pmod{2\pi}.
$$

This congruence identifies the form of the required trace correction. A complete $SU(2)$ theorem must show that a representing Hermitian logarithm can be selected in the appropriate congruence class.

## 8. Architecture repairs

### 8.1 Restricting the second parameter

The simplest repair is to define the activation only on

$$
\mathcal D=\{H_2=H_2^*:L(H_2)^*L(H_2)=I\}.
$$

On pairs $(H_1,H_2)$ with $H_2\in\mathcal D$, the activation is unitary by Corollary 4.2. In finite dimensions, Theorem 5.1 characterizes $\mathcal D$ spectrally. The cost is that $\mathcal D$ is highly constrained and may be disconnected or inconvenient for gradient-based optimization.

### 8.2 Polar normalization

For invertible $L$, define

$$
P(L)=L(L^*L)^{-1/2}.
$$

**Proposition 8.1 (Unitarity of the polar factor).** If $L$ is invertible, then $P(L)$ is unitary.

**Proof sketch.** The positive element $L^*L$ is invertible. Functional calculus defines $(L^*L)^{-1/2}$. Then

$$
P(L)^*P(L)
=(L^*L)^{-1/2}L^*L(L^*L)^{-1/2}=I.
$$

In finite dimensions, a square matrix with $P(L)^*P(L)=I$ is unitary. $\square$

This leads to the normalized activation

$$
\widetilde N(H_1,H_2)
=\exp(iH_1)P\bigl(\Log(I+iH_2)\bigr),
$$

which is unitary whenever the logarithmic factor is invertible. The point $H_2=0$ remains singular because $L(0)=0$. A regularized polar map may improve numerical stability but must be analyzed carefully: replacing $L^*L$ by $L^*L+\varepsilon I$ generally yields a contraction rather than an exactly unitary matrix.

### 8.3 Determinant correction

For $V\in U(2)$, choose a square root of $\det V$ and define

$$
V_{\mathrm{special}}=\frac{V}{\sqrt{\det V}}.
$$

Then $V_{\mathrm{special}}\in SU(2)$, although a globally continuous choice of square root introduces phase and branch issues. An architecture intended for $SU(2)$ must state and manage this choice explicitly.

### 8.4 Keep the logarithm inside a Hermitian generator

Another design is to construct a Hermitian function $K(H_1,H_2)$ and output

$$
\exp(iK(H_1,H_2)).
$$

For example, Hermitian and skew-Hermitian components of a logarithmic feature may be combined before exponentiation. This approach guarantees unitarity on the full domain, although its approximation properties differ from those of the original product.

## 9. Applications and interpretation

The results have immediate relevance to quantum machine learning. If an activation is advertised as a deterministic quantum gate, exact unitarity is a structural requirement. A nonunitary map may still represent a valid quantum operation after embedding it in a larger system, introducing Kraus operators, conditioning on measurement outcomes, or interpreting it as an unnormalized amplitude transformation. Those interpretations require additional data and have different physical and optimization semantics.

The factor criterion also supplies a useful training diagnostic. Since

$$
N^*N-I=L^*L-I,
$$

any penalty based on the Gram residual is independent of $H_1$. Optimizing $H_1$ cannot reduce that penalty. A learning algorithm that attempts to repair nonunitarity by updating both parameter blocks wastes effort in the first block; only $H_2$, normalization, or the architecture itself can change the residual.

In numerical linear algebra, the same identity implies identical condition numbers and singular spectra for $N$ and $L$ whenever these notions are defined. Hence instability near $H_2=0$ cannot be ameliorated by the first exponential. In model design, this separation is advantageous: $H_1$ controls a unitary orientation, while $H_2$ controls all radial distortion.

## 10. Discussion

The mathematical obstruction is elementary but decisive. The expression combines one factor known to be unitary with another factor that vanishes at a natural input. Multiplication does not average their properties. Because the first factor is invertible and norm-preserving, the second factor completely determines whether the product satisfies the unitary equations.

This observation corrects a common inference: replacing scalar functions with matrix functions does not automatically preserve the geometry of a target matrix group. The scalar exponential $e^{ix}$ lies on the unit circle for real $x$, but the scalar logarithm $\Log(1+ix)$ generally does not. Functional calculus transfers this scalar behavior to eigenvalues. The matrix setting adds expressive eigenspaces but cannot eliminate the scalar modulus condition.

There are three levels of claim that should not be conflated:

1. **Full-domain codomain claim:** every Hermitian pair produces a unitary output. This is false by Theorem 3.2.
2. **Restricted codomain claim:** every pair satisfying an explicit condition on $H_2$ produces a unitary output. This follows when $L(H_2)$ is unitary, or after exact polar normalization on the invertible domain.
3. **Coverage claim:** every target unitary has at least one representing pair. This may be approachable once a single admissible unitary logarithmic factor is established and exponential surjectivity and determinant constraints are handled.

The zero-input theorem settles only the first, but the log-factor theorem precisely identifies the missing hypothesis needed for the second and the key gateway to the third.

## 11. Future work

Several concrete questions follow.

First, certify a nonzero real solution of

$$
\frac14\log^2(1+t^2)+\arctan^2t=1.
$$

A rigorous interval proof would produce a scalar unitary logarithmic factor.

Second, use such a scalar $t$ to prove $U(2)$ coverage with $H_2=tI$. The problem reduces to global surjectivity of the Hermitian exponential and phase tracking.

Third, determine the exact trace congruence for $SU(2)$ representations. If $\Log(1+it)=e^{i\theta}$, the expected condition is

$$
\operatorname{tr}H_1\equiv-2\theta\pmod{2\pi},
$$

but a complete theorem must align this with the choice of Hermitian logarithm of each target.

Fourth, analyze the polar-normalized architecture on the domain where $L$ is invertible, including differentiability, behavior near singular values, and determinant-one phase correction. One should determine whether traceless Hermitian parameters suffice after normalization.

Finally, compare the optimization geometry of restricted, polar-normalized, and generator-based architectures. The relevant criteria include exact group membership, smoothness, conditioning, expressive coverage, gradient stability, and physical implementability.

## 12. Conclusion

The raw quantum exponential–logarithm activation

$$
\exp(iH_1)\Log(I+iH_2)
$$

does not define a unitary-valued map on all Hermitian inputs. Its second-zero slice is identically zero, so it cannot be an unrestricted $SU(2)$ activation. More generally, output unitarity is equivalent to unitarity of the logarithmic factor: the first Hamiltonian contributes a unitary left multiplier but cannot change singular values or repair a defective factor.

These results replace an overbroad universality conjecture with a precise design criterion. Any viable version must restrict the logarithmic spectrum, normalize the logarithmic factor, or move the logarithmic information inside a unitary-by-construction parameterization. The remaining coverage problem is thereby isolated in a form suitable for scalar analysis, spectral methods, and determinant-aware quantum architecture design.
