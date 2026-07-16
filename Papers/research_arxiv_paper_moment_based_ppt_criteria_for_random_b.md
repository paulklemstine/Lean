# Shifted Hankel Moment Certificates for Detecting Negative Partial-Transpose Spectra

**Aristotle**  
**July 16, 2026**

## Abstract

Moment-based relaxations of the positive-partial-transpose condition replace full spectral reconstruction by positivity tests on finite Hankel matrices assembled from experimentally accessible power moments. This paper develops the deterministic finite-spectrum algebra underlying those tests. For a finite weighted real spectrum with moments $p_k=\sum_jw_jx_j^k$, we define the level-$m$ shifted Hankel matrix $H_m=(p_{a+b+1})_{0\le a,b<m}$. Its quadratic form admits the exact representation

$$
c^{\mathsf T}H_mc=\sum_jw_jx_jf_c(x_j)^2,
$$

where $f_c(t)=\sum_{a=0}^{m-1}c_at^a$. It follows that nonnegative weights and nonnegative spectral nodes make every $H_m$ positive semidefinite. The matrices form a nested hierarchy: positivity at level $m+1$ implies positivity at level $m$. At the first nonlinear level, nonnegative spectra obey $p_2^2\le p_1p_3$; a strict reverse inequality therefore certifies a negative node. We also prove a deterministic stability theorem: if the exact determinant violation has margin $\delta$, moments bounded by $B$ and measured with uniform error $\varepsilon$ retain the violation whenever $2(2B\varepsilon+\varepsilon^2)<\delta$. A Gram factorization clarifies the geometric content and yields practical algorithms for testing, witness extraction, and error certification. The results isolate the model-independent core needed to study random induced bipartite states, while making no claim here about the existence or value of asymptotic random-state thresholds.

## 1. Introduction

Let $\rho$ be a density operator on a bipartite Hilbert space. Partial transposition with respect to one subsystem produces an operator $\rho^\Gamma$. Every separable state has $\rho^\Gamma\succeq0$, so a negative eigenvalue of $\rho^\Gamma$ is a rigorous certificate of entanglement. This is the positive-partial-transpose, or PPT, criterion.

Full diagonalization is often poorly matched to experiment. The matrix dimension grows rapidly, whereas traces of low powers can sometimes be estimated without reconstructing every entry. This motivates a hierarchy based on the moments of the partial-transpose spectrum. Its finite-dimensional algebra is an instance of the classical moment problem: which moment sequences can arise from a measure supported on the nonnegative real axis?

The support constraint $x\ge0$ is encoded by a shifted quadratic form. For any real polynomial $f$, a nonnegative weighted spectrum satisfies

$$
\sum_jw_jx_jf(x_j)^2\ge0.
$$

Restricting $f$ to degree at most $m-1$ turns this requirement into positive semidefiniteness of an $m\times m$ shifted Hankel matrix. This formulation has four immediate advantages. First, it depends on finitely many moments. Second, it exposes an exact sum-of-squares identity. Third, its levels are nested by polynomial inclusion. Fourth, a negative eigenvector of the matrix provides an explicit polynomial witness.

This paper establishes those facts for arbitrary finite real spectra with nonnegative weights. The first nonlinear condition is the determinant inequality $p_2^2\le p_1p_3$. Its strict failure forces a negative spectral node, and an explicit perturbation budget makes the test usable with approximate data.

The intended application is to induced random states on $\mathbb C^d\otimes\mathbb C^d$, obtained by tracing out an environment $\mathbb C^s$ from a random pure state. In regimes such as $s\sim\lambda d^2$, random-matrix methods can supply limiting moments and concentration. The present work deliberately separates that probabilistic layer from the deterministic implication connecting moments to spectral negativity. No asymptotic threshold theorem is asserted here.

## 2. Finite weighted spectra and moments

### 2.1. Basic definitions

Let $J$ be a finite index set. A **finite weighted real spectrum** consists of nodes $x_j\in\mathbb R$ and weights $w_j\in\mathbb R$ for $j\in J$. Throughout the positivity results, weights satisfy $w_j\ge0$. The nodes are not assumed nonnegative unless explicitly stated.

**Definition 2.1 (Power moments).** For every integer $k\ge0$, the $k$th power moment is

$$
p_k=\sum_{j\in J}w_jx_j^k.
$$

Repeated eigenvalues can be represented either by repeated indices or by a single node carrying its multiplicity as a weight. The normalization $\sum_jw_j=1$ is not needed for any theorem below.

**Definition 2.2 (Shifted Hankel matrix).** For an integer $m\ge1$, the level-$m$ shifted Hankel matrix is

$$
H_m=\bigl(p_{a+b+1}\bigr)_{0\le a,b<m}.
$$

Thus

$$
H_1=(p_1),\qquad
H_2=\begin{pmatrix}p_1&p_2\\p_2&p_3\end{pmatrix},
$$

and level $m$ requires moments only through $p_{2m-1}$.

**Definition 2.3 (Polynomial probe).** Given $c=(c_0,\ldots,c_{m-1})^{\mathsf T}\in\mathbb R^m$, define

$$
f_c(t)=\sum_{a=0}^{m-1}c_at^a.
$$

The probe degree is at most $m-1$. Its scale is irrelevant to the sign of the associated quadratic form, though normalization becomes useful for optimization.

### 2.2. Connection with partial transpose

For a Hermitian matrix $A$ with eigenvalues $x_j$, choosing unit weights gives $p_k=\operatorname{Tr}(A^k)$. More general nonnegative weights accommodate multiplicities and weighted spectral models. If $A=\rho^\Gamma$, then $x_j\ge0$ for all $j$ is exactly the PPT condition. Hence any necessary consequence of node nonnegativity becomes a PPT moment criterion. A violated criterion certifies a negative partial-transpose eigenvalue and therefore entanglement.

The converse must be treated carefully. A finite collection of moment inequalities need not detect every negative node. Consequently, each finite level is a relaxation: violation is conclusive, while satisfaction is generally inconclusive.

## 3. Exact quadratic identity and positivity

The algebraic core is an identity requiring no sign assumptions.

**Theorem 3.1 (Shifted-Hankel sum-of-squares identity).** For every finite weighted real spectrum, every $m\ge1$, and every $c\in\mathbb R^m$,

$$
c^{\mathsf T}H_mc
=\sum_{j\in J}w_jx_jf_c(x_j)^2.
$$

**Proof sketch.** Expand the quadratic form and substitute the moment definition:

$$
\begin{aligned}
c^{\mathsf T}H_mc
&=\sum_{a,b=0}^{m-1}c_ac_bp_{a+b+1}\\
&=\sum_{a,b=0}^{m-1}c_ac_b\sum_jw_jx_j^{a+b+1}\\
&=\sum_jw_jx_j
\left(\sum_ac_ax_j^a\right)
\left(\sum_bc_bx_j^b\right).
\end{aligned}
$$

The two parenthesized factors both equal $f_c(x_j)$, yielding the result. All sums are finite, so their reordering is immediate. $\square$

This identity converts support information into matrix positivity.

**Theorem 3.2 (Positive shifted moments of a nonnegative spectrum).** Suppose $w_j\ge0$ and $x_j\ge0$ for every $j\in J$. Then $H_m$ is positive semidefinite for every $m\ge1$; explicitly,

$$
c^{\mathsf T}H_mc\ge0
$$

for every $c\in\mathbb R^m$.

**Proof sketch.** By Theorem 3.1, the quadratic form is a sum of terms $w_jx_jf_c(x_j)^2$. Every factor is nonnegative under the hypotheses, so the sum is nonnegative. $\square$

For partial-transpose spectra this gives a hierarchy of necessary PPT conditions. If any $H_m$ has a negative quadratic direction, the spectrum cannot be supported on $[0,\infty)$.

### 3.1. Gram geometry

The positivity has an exact Euclidean factorization.

**Theorem 3.3 (Gram representation).** If $w_j\ge0$ and $x_j\ge0$, define feature vectors $v_a\in\mathbb R^J$ for $0\le a<m$ by

$$
v_a(j)=\sqrt{w_jx_j}\,x_j^a.
$$

Then

$$
(H_m)_{ab}=\langle v_a,v_b\rangle
=\sum_jv_a(j)v_b(j).
$$

**Proof sketch.** Multiplying the two feature coordinates gives

$$
v_a(j)v_b(j)=w_jx_jx_j^{a+b}=w_jx_j^{a+b+1}.
$$

Summing over $j$ produces $p_{a+b+1}$. $\square$

Equivalently, if $V$ is the matrix whose $a$th column is $v_a$, then $H_m=V^{\mathsf T}V$. This immediately implies positive semidefiniteness and identifies the quadratic form with $\|Vc\|_2^2$.

The shift by one in $p_{a+b+1}$ is essential. It inserts the factor $x_j$, thereby testing whether the spectral measure remains nonnegative after multiplication by the coordinate function. In moment-problem language, $H_m$ is a localizing matrix for the half-line constraint $x\ge0$.

## 4. Nesting of the hierarchy

The spaces of polynomial probes satisfy

$$
\mathbb R[t]_{\le m-1}\subset\mathbb R[t]_{\le m}.
$$

Matrix positivity inherits this inclusion.

**Theorem 4.1 (Nesting Theorem).** If $H_{m+1}$ is positive semidefinite, then $H_m$ is positive semidefinite.

**Proof sketch.** Given $c=(c_0,\ldots,c_{m-1})\in\mathbb R^m$, extend it to

$$
\widetilde c=(c_0,\ldots,c_{m-1},0)\in\mathbb R^{m+1}.
$$

The corresponding polynomial is unchanged. Since the leading coefficient vanishes,

$$
\widetilde c^{\mathsf T}H_{m+1}\widetilde c=c^{\mathsf T}H_mc.
$$

The left side is nonnegative by hypothesis, proving the claim. $\square$

**Corollary 4.2 (Monotonicity of violations).** If $H_m$ is not positive semidefinite, then no $H_r$ with $r\ge m$ is positive semidefinite.

**Proof sketch.** Repeated application of Theorem 4.1 would otherwise force $H_m$ to be positive semidefinite. Equivalently, a violating degree-at-most-$m-1$ probe remains available at every higher level by padding its coefficient vector with zeros. $\square$

Nesting is logically weaker than strict improvement. A higher level has more probes, but whether it detects strictly more spectra in a particular ensemble is a separate question.

## 5. The first nonlinear moment certificate

At level one, the criterion is $p_1\ge0$. At level two, positive semidefiniteness of

$$
H_2=\begin{pmatrix}p_1&p_2\\p_2&p_3\end{pmatrix}
$$

requires both nonnegative diagonal behavior and a nonnegative determinant.

**Theorem 5.1 (First nonlinear moment inequality).** If $w_j\ge0$ and $x_j\ge0$ for every $j$, then

$$
p_2^2\le p_1p_3.
$$

**Proof sketch.** Define vectors $u,v\in\mathbb R^J$ by

$$
u_j=\sqrt{w_jx_j},\qquad v_j=\sqrt{w_jx_j}\,x_j.
$$

Then

$$
\langle u,u\rangle=p_1,\qquad
\langle u,v\rangle=p_2,\qquad
\langle v,v\rangle=p_3.
$$

Cauchy--Schwarz gives $\langle u,v\rangle^2\le\langle u,u\rangle\langle v,v\rangle$, which is the claimed inequality. Equivalently, it is $\det H_2\ge0$. $\square$

The contrapositive gives a sharp logical certificate.

**Theorem 5.2 (Negative-node certificate).** Suppose $w_j\ge0$ for all $j$. If

$$
p_1p_3<p_2^2,
$$

then there exists at least one $j$ such that $x_j<0$.

**Proof sketch.** If all nodes were nonnegative, Theorem 5.1 would imply the opposite weak inequality. The strict violation therefore rules out universal nonnegativity. $\square$

For a partial-transpose spectrum, this certifies non-PPT behavior. The theorem does not say that every negative spectrum violates the inequality. Cancellation can allow $p_1p_3\ge p_2^2$ even in the presence of negative nodes.

### 5.1. Examples

For nodes $1,2,3$ with unit weights,

$$
p_1=6,\qquad p_2=14,\qquad p_3=36,
$$

so $p_2^2=196\le216=p_1p_3$.

For nodes $-1,2,3$ with unit weights,

$$
p_1=4,\qquad p_2=14,\qquad p_3=34,
$$

and $p_2^2=196>136=p_1p_3$. The negative node is detected.

A negative node can nevertheless evade this level. For nodes $-0.01,1,2$ with respective weights $0.01,1,1$, direct moment evaluation gives $p_2^2-p_1p_3\approx-1.99909$, so the shifted-Hankel determinant is positive despite the negative node. This does not contradict Theorem 5.2: the theorem asserts that violation implies negativity, not that negativity implies violation.

## 6. Robustness under moment error

Measured moments are approximate. A useful certificate must remain valid under controlled perturbations.

Let $p_1,p_2,p_3$ be exact moments and $q_1,q_2,q_3$ their estimates. Define the exact and observed violation functions

$$
D(p)=p_2^2-p_1p_3,
\qquad
D(q)=q_2^2-q_1q_3.
$$

A positive value certifies violation.

**Theorem 6.1 (Deterministic stability of the first certificate).** Assume that for some $B,\varepsilon,\delta\ge0$,

$$
|p_1|,|p_2|,|p_3|\le B,
$$

$$
|q_i-p_i|\le\varepsilon\quad(i=1,2,3),
$$

and

$$
D(p)=p_2^2-p_1p_3\ge\delta.
$$

If

$$
2\bigl(2B\varepsilon+\varepsilon^2\bigr)<\delta,
$$

then

$$
q_1q_3<q_2^2.
$$

**Proof sketch.** Write $e_i=q_i-p_i$. Expanding the product gives

$$
q_1q_3-p_1p_3=p_1e_3+p_3e_1+e_1e_3,
$$

so

$$
|q_1q_3-p_1p_3|\le2B\varepsilon+\varepsilon^2.
$$

Similarly,

$$
q_2^2-p_2^2=2p_2e_2+e_2^2,
$$

and therefore

$$
|q_2^2-p_2^2|\le2B\varepsilon+\varepsilon^2.
$$

Combining the worst possible adverse changes yields

$$
D(q)\ge D(p)-2(2B\varepsilon+\varepsilon^2)>0.
$$

Thus $q_2^2>q_1q_3$. $\square$

The theorem is distribution-free and simultaneous over the entire error box. If separate error bounds $\varepsilon_i$ are known, one can sharpen the estimate to

$$
|q_1q_3-p_1p_3|
\le |p_1|\varepsilon_3+|p_3|\varepsilon_1+\varepsilon_1\varepsilon_3
$$

and

$$
|q_2^2-p_2^2|
\le2|p_2|\varepsilon_2+\varepsilon_2^2.
$$

These refinements follow from the same expansion, although the uniform theorem is simpler to deploy.

## 7. Algorithms

### 7.1. Computing moments and the first certificate

Given nodes and weights, compute $p_1,p_2,p_3$ in one pass. Form

$$
D=p_2^2-p_1p_3.
$$

If $D>0$, report a certified negative node. The arithmetic cost is $O(n)$ for $n$ spectral nodes and the memory cost is $O(1)$ beyond the input. If only moments are supplied, evaluation is constant time.

With an uncertainty bound, compute the safety reserve

$$
R=D-2(2B\varepsilon+\varepsilon^2).
$$

A positive reserve certifies that every admissible exact or measured perturbation retains the violating sign, according to which quantities are treated as nominal.

### 7.2. General level-$m$ test

Given moments $p_1,\ldots,p_{2m-1}$:

1. Construct $H_m$ using $(H_m)_{ab}=p_{a+b+1}$.
2. Compute its smallest eigenvalue $\lambda_{\min}$.
3. If $\lambda_{\min}<0$ beyond the numerical tolerance, extract a normalized eigenvector $c$.
4. Return the polynomial $f_c(t)=\sum_{a=0}^{m-1}c_at^a$ as a witness.

Dense construction costs $O(m^2)$ and symmetric eigendecomposition costs $O(m^3)$. The witness satisfies

$$
c^{\mathsf T}H_mc=\lambda_{\min}<0.
$$

By Theorem 3.1, a spectrum with nonnegative weights cannot then have all nodes nonnegative.

### 7.3. Optimality of the least-eigenvalue probe

Among coefficient vectors with $\|c\|_2=1$, the Rayleigh--Ritz principle gives

$$
\min_{\|c\|_2=1}c^{\mathsf T}H_mc=\lambda_{\min}(H_m).
$$

Thus the least-eigenvalue eigenvector is the strongest witness in coefficient Euclidean norm. Other normalizations, such as normalization with respect to a limiting spectral measure, lead to generalized eigenvalue problems and connect the method to orthogonal polynomials.

## 8. Application to random induced bipartite states

Consider a random pure state on

$$
\mathbb C^d\otimes\mathbb C^d\otimes\mathbb C^s
$$

and trace out the $s$-dimensional environment. The resulting mixed state on $\mathbb C^d\otimes\mathbb C^d$ is an induced random state. Partial transposition produces a random Hermitian matrix whose moments can be studied by combinatorial expansions.

For fixed $m$, the level-$m$ criterion depends on finitely many moments. A prospective asymptotic threshold analysis in the scaling $s\sim\lambda d^2$ has three logically distinct steps:

1. determine the limiting moments of the partial-transpose spectrum;
2. establish concentration of the empirical moments around those limits;
3. analyze the sign or smallest eigenvalue of the resulting deterministic shifted Hankel matrix.

The theorems above provide the bridge from the third step to a rigorous spectral conclusion. The stability theorem additionally explains how concentration bounds can be converted into high-probability sign preservation when the limiting determinant has a nonzero margin.

However, the finite-spectrum results alone do not prove that a unique threshold $\lambda_m$ exists, do not identify its value, and do not establish a transition probability. Those assertions require ensemble-specific asymptotics. Keeping this distinction explicit prevents deterministic moment geometry from being conflated with probabilistic threshold behavior.

## 9. Discussion

The shifted-Hankel method can be understood in three equivalent languages.

First, it is a **moment consistency test**: moments of a nonnegative weighted spectrum must make all localizing matrices positive semidefinite.

Second, it is a **polynomial witness method**: a violation supplies a polynomial $f$ for which the signed quantity $\sum_jw_jx_jf(x_j)^2$ is negative.

Third, under nonnegative support it is a **Gram construction**: monomial features weighted by $\sqrt{w_jx_j}$ have $H_m$ as their inner-product matrix.

These viewpoints explain both the power and limitations of the hierarchy. Increasing $m$ enlarges the probe space, and nesting guarantees that no previous witness is lost. Nevertheless, bounded-degree polynomials may fail to localize sufficiently near a small negative component. Completeness requires an asymptotic argument and suitable assumptions on the spectrum.

The first determinant certificate is attractive experimentally because it uses only three moments and has a transparent error analysis. Higher levels offer stronger detection but raise measurement and conditioning costs. Hankel matrices built from high powers can be ill-conditioned when spectral scales vary widely. Rescaling nodes, changing from monomials to orthogonal polynomial bases, and using interval arithmetic are natural numerical remedies.

The theory also clarifies what constitutes a valid conclusion. A negative matrix direction is decisive: some node is negative. A positive finite matrix is not decisive: it only says that no polynomial of the permitted degree found a contradiction. This asymmetry should be preserved in statistical reporting.

## 10. Scope, assumptions, and boundary cases

The hypotheses in the preceding results are minimal but consequential. The sum-of-squares identity itself is purely algebraic: weights and nodes may have either sign. Nonnegative weights are needed when interpreting a strict violation as evidence about the sign of a node. If negative weights were allowed, a negative quadratic form could arise from a negative weight even when all nodes were nonnegative. Node nonnegativity is needed only for the forward positivity theorem, not for constructing or evaluating the matrices.

Zero weights and zero nodes cause no difficulty. A zero-weight node contributes to no moment and is observationally irrelevant. A zero node contributes to $p_0$ but not to any entry of the shifted matrix, because every entry uses a positive power. Accordingly, the shifted hierarchy detects support on the open negative half-line but cannot distinguish additional mass at zero from its absence when only shifted moments are considered.

The case $m=0$ is vacuous and is excluded from the matrix discussion by taking $m\ge1$. At $m=1$, the only probe is constant and the condition is $p_1\ge0$. At $m=2$, the determinant supplies the first nonlinear interaction among moments. For $m>2$, positive semidefiniteness requires all eigenvalues to be nonnegative; checking only the full determinant is insufficient, because an even number of negative eigenvalues can leave the determinant positive.

Moment scaling also deserves attention. If every node is multiplied by a positive constant $r$, then $p_k$ is multiplied by $r^k$. The first gap becomes

$$
(r^2p_2)^2-(rp_1)(r^3p_3)=r^4(p_2^2-p_1p_3),
$$

so its sign is invariant under positive rescaling. At higher levels, diagonal congruence similarly preserves inertia: changing $x_j$ to $rx_j$ transforms $H_m$ by positive diagonal scaling together with an overall positive factor. Thus the presence or absence of a violating direction is independent of the choice of positive spectral units.

Weights may also be multiplied by a common positive constant. Every moment and every entry of $H_m$ is then multiplied by that constant, preserving positive semidefiniteness and the sign of every quadratic form. Hence probability normalization is optional. This is useful when weights represent integer multiplicities.

Numerically, exact positivity and floating-point positivity must not be confused. A computed eigenvalue near zero should be reported as indeterminate unless a rigorous perturbation or interval bound separates it from zero. For the level-two test, Theorem 6.1 supplies such a bound directly. For general $m$, standard eigenvalue perturbation gives the route: if an entrywise moment error implies an operator-norm matrix error at most $\eta$, then a computed smallest eigenvalue below $-\eta$ certifies that the exact matrix has a negative eigenvalue. Developing sharp, measurement-aware values of $\eta$ is an important practical extension.

## 11. Future directions

Several extensions follow naturally.

**Exact induced-state thresholds.** For each fixed $m\ge2$, one may seek a unique constant $\lambda_m>0$ governing the switch between typical violation and satisfaction when $s\sim\lambda d^2$. The limiting partial-transpose moments should determine a finite Hankel determinant or smallest eigenvalue whose sign changes at an algebraic critical point.

**Strictness and convergence.** Nesting suggests studying whether $\lambda_m<\lambda_{m+1}$ and whether the sequence converges to the full PPT threshold. This requires proving that added polynomial degrees detect genuinely new negative spectral support.

**Finite-size transition windows.** If moment concentration is exponential and the limiting determinant crosses zero transversely, the deterministic stability budget can support quantitative bounds away from a narrow critical window.

**Universality.** Because the certificate itself is model-independent, one may test whether the same fixed-level constants persist for non-Gaussian induced ensembles with matching low-order moments.

**Optimal experimental witnesses.** The least shifted-Hankel eigenvector solves a Rayleigh-quotient problem. Under physically meaningful normalization, this links sample-efficient detection to generalized eigenvalues, orthogonal polynomials, and Christoffel functions.

## 12. Conclusion

A finite weighted spectrum supported on the nonnegative half-line generates positive semidefinite shifted Hankel matrices at every level. The exact identity

$$
c^{\mathsf T}H_mc=\sum_jw_jx_jf_c(x_j)^2
$$

is the organizing principle: it proves positivity, supplies a Gram factorization, and turns negative eigenvectors into polynomial witnesses. The hierarchy is nested. Its first nonlinear condition is $p_2^2\le p_1p_3$, whose strict failure certifies a negative node. If the exact violation exceeds twice the perturbation allowance $2B\varepsilon+\varepsilon^2$, the certificate survives uniformly bounded moment error.

These statements provide a complete deterministic account of the finite moment mechanism. They support practical detection algorithms and furnish the algebraic foundation for future random-matrix threshold analyses, while clearly separating what follows from finite moment geometry from what still requires probabilistic asymptotics.
