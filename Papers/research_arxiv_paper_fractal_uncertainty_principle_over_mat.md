# A Finite-Scale Fractal Uncertainty Principle on Prime-Power Trees

**Aristotle**  
**July 16, 2026**

## Abstract

We establish an explicit finite-scale uncertainty principle for porous subsets of a regular residue tree. A depth-$n$ subset with at most $a$ retained descendants per occupied node has cardinality at most $a^n$. For a normalized finite oscillatory kernel on an ambient space of size $N$, restriction to input and output sets $X$ and $Y$ satisfies the universal energy estimate

$$
\sum_{y\in Y}\left|\sum_{x\in X}\frac{e^{i\phi(y,x)}}{\sqrt N}f(x)\right|^2
\le \frac{|X||Y|}{N}\sum_{x\in X}|f(x)|^2.
$$

Combining the two statements at scale $N=q^n$ yields

$$
E_Y(T_Xf)\le \left(\frac{ab}{q}\right)^nE_X(f).
$$

Hence the restricted energy decays exponentially whenever $ab<q$. The argument is phase-independent and requires no orthogonality; analytically it is a Hilbert–Schmidt estimate, and combinatorially it is an iteration of uniform branching loss. We give the concrete quintic depth-three factor $64/125$, formulate an algorithmic pipeline for computing the bound, and relate the prime-power scale hierarchy to exact Frobenius renormalization in additive cellular dynamics. The method deliberately isolates the strong-porosity regime: when $ab\ge q$, cardinality alone gives no contraction, identifying cancellation or additive-energy improvement as the missing mechanism.

## 1. Introduction

Uncertainty principles prohibit simultaneous concentration of a function and an oscillatory transform. In a finite setting, concentration is naturally described by restricting the input to a set $X$ and measuring transformed energy only on a set $Y$. The geometry of $X$ and $Y$ matters because structured thin sets can persist across many scales.

For non-Archimedean spaces, multiscale geometry is represented exactly by a rooted tree. Fix an integer $q\ge 2$. The depth-$n$ leaves of the regular $q$-ary tree are words of length $n$ over a $q$-symbol alphabet. When $q=p$ is prime, these words model residue classes modulo $p^n$ in the $p$-adic unit ball. Agreement through the first $r$ digits places two leaves in a common ball at depth $r$. Thus nested balls, residue classes, and prefixes are three descriptions of the same object.

Porosity means that descendants are systematically missing. The elementary form studied here assumes a uniform branching cap: every occupied node of one set has at most $a$ occupied children, while every occupied node of the other has at most $b$. This gives exact exponential cardinality bounds. A normalized oscillatory transform on the $q^n$ ambient leaves has entries of modulus $q^{-n/2}$. Restricting such a matrix to at most $a^n$ columns and $b^n$ rows gives squared operator norm at most $(ab/q)^n$.

This argument has two virtues. First, it is modular: the analytic estimate applies to every finite kernel with uniformly bounded entries, while the combinatorial estimate applies to every sequence satisfying a branching recurrence. Second, it exposes the precise limitation of cardinality methods. Contraction occurs if $ab<q$. At and beyond $ab=q$, a proof must exploit phase cancellation or finer arithmetic structure.

The paper proceeds as follows. Section 2 defines energy, restricted transforms, residue trees, and branching porosity. Section 3 proves the universal restricted-kernel estimate. Section 4 develops tree cardinality bounds. Section 5 combines them into the finite-scale fractal uncertainty principle and interprets the threshold dimensionally. Section 6 gives examples and computational procedures. Section 7 records a prime-power bridge to Frobenius dynamics. Sections 8–10 discuss applications, limitations, and future directions.

## 2. Definitions and setting

### 2.1 Finite energy and restricted transforms

Let $A$ and $B$ be finite sets, let $X\subseteq A$ and $Y\subseteq B$, and let $f:A\to\mathbb C$. The **energy of $f$ on $X$** is

$$
E_X(f)=\sum_{x\in X}|f(x)|^2.
$$

Let $K:B\times A\to\mathbb C$ be a kernel. The **transform restricted to the input support $X$** is

$$
(T_Xf)(y)=\sum_{x\in X}K(y,x)f(x).
$$

Its energy captured by $Y$ is

$$
E_Y(T_Xf)=\sum_{y\in Y}|(T_Xf)(y)|^2.
$$

A kernel is **normalized at ambient size $N>0$** if

$$
|K(y,x)|\le N^{-1/2}
$$

for every $x\in A$ and $y\in B$. The standard oscillatory example is

$$
K_\phi(y,x)=\frac{e^{i\phi(y,x)}}{\sqrt N},
$$

where $\phi:B\times A\to\mathbb R$ is arbitrary. Since $|e^{it}|=1$ for real $t$, this kernel has constant modulus $N^{-1/2}$.

### 2.2 Residue trees

Fix $q\ge 2$. The **depth-$n$ $q$-ary tree** consists of words

$$
(d_0,d_1,\ldots,d_{n-1}),\qquad d_j\in\{0,1,\ldots,q-1\}.
$$

There are $q^n$ leaves. A prefix of length $r$ identifies a node at depth $r$ and the set of all leaves descending from it. For prime $q=p$, the word corresponds to the residue

$$
d_0+d_1p+\cdots+d_{n-1}p^{n-1}\pmod {p^n}.
$$

A leaf set determines occupied nodes at every depth: a node is occupied if some selected leaf descends from it.

### 2.3 Uniform branching porosity

A leaf set has **branching bound $a$** if each occupied node above depth $n$ has at most $a$ occupied children. Equivalently, if $c(r)$ counts occupied nodes at depth $r$, then

$$
c(0)\le 1,
\qquad
c(r+1)\le a\,c(r)
$$

for $0\le r<n$. This is a rigid finite-scale version of porosity. If $a<q$, at least one potential direction is absent from every occupied node.

The associated branching dimension is

$$
d_a=\frac{\log a}{\log q},
$$

with the convention that $d_0=0$. Since $a^n=(q^n)^{d_a}$, this quantity records the exponent governing leaf growth.

## 3. The analytic estimate

We first isolate a statement independent of trees or Fourier structure.

### Theorem 3.1 (Restricted Energy Theorem)

Let $X\subseteq A$ and $Y\subseteq B$ be finite, let $N>0$, and suppose

$$
|K(y,x)|\le \frac{1}{\sqrt N}
$$

for all $x\in A$ and $y\in B$. Then every $f:A\to\mathbb C$ satisfies

$$
E_Y(T_Xf)
\le
\frac{|X||Y|}{N}E_X(f).
$$

#### Proof sketch

Fix $y\in Y$. The triangle inequality and kernel bound give

$$
|(T_Xf)(y)|
\le
\sum_{x\in X}|K(y,x)||f(x)|
\le
\frac{1}{\sqrt N}\sum_{x\in X}|f(x)|.
$$

By Cauchy–Schwarz,

$$
\left(\sum_{x\in X}|f(x)|\right)^2
\le
|X|\sum_{x\in X}|f(x)|^2
=
|X|E_X(f).
$$

Therefore

$$
|(T_Xf)(y)|^2\le \frac{|X|}{N}E_X(f).
$$

Summing this inequality over $y\in Y$ proves the claim.

### Corollary 3.2 (Oscillatory Restricted Energy Bound)

Let $\phi:B\times A\to\mathbb R$, let $N>0$, and define

$$
(T_X^\phi f)(y)=
\sum_{x\in X}\frac{e^{i\phi(y,x)}}{\sqrt N}f(x).
$$

Then

$$
E_Y(T_X^\phi f)
\le
\frac{|X||Y|}{N}E_X(f).
$$

#### Proof sketch

The identity $|e^{i\phi(y,x)}|=1$ shows that every kernel entry has modulus exactly $N^{-1/2}$. Theorem 3.1 applies directly.

### Remark 3.3 (Hilbert–Schmidt interpretation)

The matrix restricted to rows $Y$ and columns $X$ has $|X||Y|$ entries, each with squared modulus at most $1/N$. Its Hilbert–Schmidt norm squared is therefore at most $|X||Y|/N$. Since operator norm is bounded by Hilbert–Schmidt norm,

$$
\|1_YT1_X\|_{2\to 2}
\le
\sqrt{\frac{|X||Y|}{N}}.
$$

Squaring this norm inequality gives Theorem 3.1. This interpretation makes clear why orthogonality and phase cancellation are absent from the argument.

## 4. Tree growth under porosity

### Theorem 4.1 (Porous Tree Cardinality)

Let $c:\mathbb N\to\mathbb N$ satisfy

$$
c(0)\le 1
$$

and

$$
c(r+1)\le a\,c(r)
$$

for every $r\ge 0$. Then

$$
c(n)\le a^n
$$

for every $n\ge 0$.

#### Proof sketch

Induct on $n$. The assertion at $n=0$ is $c(0)\le 1=a^0$. If $c(n)\le a^n$, then

$$
c(n+1)\le a\,c(n)\le a\,a^n=a^{n+1}.
$$

### Corollary 4.2 (Two-Tree Product Bound)

Suppose $c_X(0),c_Y(0)\le 1$ and

$$
c_X(r+1)\le a\,c_X(r),
\qquad
c_Y(r+1)\le b\,c_Y(r).
$$

Then

$$
c_X(n)c_Y(n)\le (ab)^n.
$$

#### Proof sketch

Theorem 4.1 gives $c_X(n)\le a^n$ and $c_Y(n)\le b^n$. Multiplication yields

$$
c_X(n)c_Y(n)\le a^nb^n=(ab)^n.
$$

### Remark 4.3 (Variable branching)

The same induction shows that if the bounds vary by level,

$$
c(r+1)\le a_r c(r),
$$

then

$$
c(n)\le \prod_{r=0}^{n-1}a_r.
$$

Although the main theorem uses constant $a$ and $b$, the variable product indicates how block entropy and random branching can enter future extensions.

## 5. Finite-scale porous uncertainty

### Theorem 5.1 (Finite-Scale Porous Fractal Uncertainty Principle)

Let $q\ge 1$ and $n\ge 0$. Let $X$ and $Y$ be finite sets satisfying

$$
|X|\le a^n,
\qquad
|Y|\le b^n.
$$

For any real phase $\phi$ define the normalized transform at ambient size $q^n$ by

$$
(T_X^\phi f)(y)=
\sum_{x\in X}
\frac{e^{i\phi(y,x)}}{\sqrt{q^n}}f(x).
$$

Then

$$
E_Y(T_X^\phi f)
\le
\left(\frac{ab}{q}\right)^nE_X(f).
$$

#### Proof sketch

Corollary 3.2 with $N=q^n$ gives

$$
E_Y(T_X^\phi f)
\le
\frac{|X||Y|}{q^n}E_X(f).
$$

Using $|X||Y|\le a^nb^n=(ab)^n$ yields

$$
\frac{|X||Y|}{q^n}
\le
\frac{(ab)^n}{q^n}
=
\left(\frac{ab}{q}\right)^n.
$$

### Corollary 5.2 (Exponential Decay in the Strong-Porosity Regime)

If $n>0$ and $ab<q$, then

$$
0\le \left(\frac{ab}{q}\right)^n<1.
$$

Consequently, the energy captured on $Y$ is a strict fraction of the input energy, and for fixed $a$, $b$, and $q$ the fraction decays exponentially as $n\to\infty$.

#### Proof sketch

The assumption $ab<q$ implies $0\le ab/q<1$. Positive powers preserve strict inequality below $1$.

### Corollary 5.3 (Operator-Norm Form)

Under the hypotheses of Theorem 5.1,

$$
\|1_YT^\phi1_X\|_{2\to 2}
\le
\left(\frac{ab}{q}\right)^{n/2}.
$$

#### Proof sketch

Apply Theorem 5.1 to an arbitrary input and take square roots. Energy is squared $\ell^2$ norm.

### Proposition 5.4 (Dimension Criterion)

Assume $a,b>0$ and define

$$
d_X=\frac{\log a}{\log q},
\qquad
d_Y=\frac{\log b}{\log q}.
$$

Then the strong-porosity condition $ab<q$ is equivalent to

$$
d_X+d_Y<1.
$$

Moreover,

$$
\left(\frac{ab}{q}\right)^n
=q^{-n(1-d_X-d_Y)}.
$$

#### Proof sketch

Take logarithms base $q$. Since $q>1$, logarithm is increasing, so $ab<q$ becomes $\log_q a+\log_q b<1$. The factor identity follows by exponentiation.

This proposition frames the estimate as a dimension-sum uncertainty principle. The elementary method contracts precisely when the sum of the two maximal branching dimensions is below the ambient tree dimension.

## 6. Examples and algorithms

### 6.1 Quintic depth three

Take $q=5$, $a=b=2$, and $n=3$. Then

$$
|X|,|Y|\le 2^3=8,
\qquad
N=5^3=125.
$$

Theorem 5.1 gives

$$
E_Y(T_X^\phi f)
\le
\left(\frac{4}{5}\right)^3E_X(f)
=
\frac{64}{125}E_X(f).
$$

The energy retention factor is $0.512$, and the operator-norm factor is

$$
\sqrt{\frac{64}{125}}=\frac{8}{5\sqrt5}.
$$

The conclusion holds for every real phase, not merely for a Fourier character.

### 6.2 A digital Fourier example

Let the ambient set be $\mathbb Z/N\mathbb Z$, with $N=q^n$, and use the discrete Fourier phase

$$
\phi(y,x)=\frac{2\pi xy}{N}.
$$

Choose $X$ and $Y$ by retaining only digit sets $D_X,D_Y\subseteq\{0,\ldots,q-1\}$ independently at each position. If $|D_X|=a$ and $|D_Y|=b$, then $|X|=a^n$ and $|Y|=b^n$. The theorem applies with equality in the cardinality estimates. A direct numerical calculation may produce substantially smaller output energy because Fourier phases cancel, but it can never violate the universal upper bound.

### 6.3 Bound-computation algorithm

Given $q,a,b,n$, compute

$$
\rho=\left(\frac{ab}{q}\right)^n.
$$

The algorithm reports contraction exactly when $ab<q$. Integer exponentiation gives the exact rational representation

$$
\rho=\frac{(ab)^n}{q^n}.
$$

Using exponentiation by squaring, the arithmetic requires $O(\log n)$ integer multiplications; the bit complexity depends on the size of the resulting integers, which have $O(n\log q+n\log(ab))$ bits.

### 6.4 Numerical restricted-transform algorithm

For explicit finite sets $X$ and $Y$, a phase $\phi$, and values $f(x)$, compute each output

$$
g(y)=\frac{1}{\sqrt N}\sum_{x\in X}e^{i\phi(y,x)}f(x).
$$

Then compare

$$
E_Y(g)=\sum_{y\in Y}|g(y)|^2
$$

with

$$
\frac{|X||Y|}{N}E_X(f).
$$

A direct implementation costs $O(|X||Y|)$ complex arithmetic operations and uses $O(|Y|)$ output storage beyond the input. If the phase is the standard Fourier phase and the sets are dense, fast Fourier methods may reduce runtime, but the sparse direct algorithm most transparently demonstrates the theorem.

### 6.5 Tree-generation algorithm

A digit-restricted depth-$n$ leaf set can be generated recursively. Begin with the prefix $0$. At each level, append each retained digit $d$ and update the represented residue from $x$ to $x+dq^r$. If $a$ digits are retained at each level, the output contains $a^n$ leaves. Since every leaf must be produced, the runtime and storage are $\Theta(a^n)$.

## 7. Prime-power scale synthesis

The scale $p^k$ has an independent algebraic role in characteristic $p$. Let $S$ denote a unit shift and consider the additive propagation operator

$$
C=S+S^{-1}.
$$

### Theorem 7.1 (Frobenius Two-Ray Renormalization)

Over characteristic $p$, for every $k\ge 0$,

$$
C^{p^k}=S^{p^k}+S^{-p^k}.
$$

#### Proof sketch

In characteristic $p$, the Frobenius identity gives

$$
(U+V)^{p^k}=U^{p^k}+V^{p^k}
$$

for commuting $U$ and $V$. Set $U=S$ and $V=S^{-1}$. The intermediate binomial coefficients vanish modulo $p$, leaving only the two extreme shifts.

### Theorem 7.2 (Prime-Power Scale Synthesis)

Let $p$ be prime and $k\ge 0$. Suppose

$$
|X|\le a^{p^k},
\qquad
|Y|\le b^{p^k}.
$$

At the common scale $p^k$, the additive propagation operator satisfies

$$
(S+S^{-1})^{p^k}=S^{p^k}+S^{-p^k},
$$

while every normalized oscillatory transform at ambient size $p^{p^k}$ satisfies

$$
E_Y(T_X^\phi f)
\le
\left(\frac{ab}{p}\right)^{p^k}E_X(f).
$$

#### Proof sketch

The first statement is Theorem 7.1. The second is Theorem 5.1 with $q=p$ and depth $n=p^k$. The synthesis is a conjunction of two independently established effects at the same scale.

This theorem should not be read as an equivalence between cellular dynamics and Fourier restriction. Its content is that both are naturally graded by prime powers. Frobenius produces exact self-similarity, whereas porosity and normalization produce contraction. This shared grading motivates a transfer-operator framework with both exactly self-similar and contracting sectors.

## 8. Applications and interpretation

### 8.1 Sparse harmonic sensing

Suppose a signal occupies a digit-restricted set $X$, and a measurement system observes only frequencies in another digit-restricted set $Y$. Theorem 5.1 bounds the energy accessible to those measurements without needing to inspect the phase in detail. When $ab<q$, deeper resolution decreases the worst-case captured fraction exponentially.

### 8.2 Hierarchical coding

Tree leaves represent codewords with nested prefixes. Missing descendants model forbidden symbols or erasures that recur at each scale. The cardinality theorem quantifies the surviving codebook, while the uncertainty theorem limits simultaneous concentration in two oscillatory representations. The estimate can therefore serve as a conservative coherence bound for hierarchical dictionaries.

### 8.3 Ultrametric signal models

Many hierarchical data sets are better represented by common ancestry than Euclidean distance. On such data, branching dimension replaces ordinary dimension. Proposition 5.4 shows that a sum-of-dimensions criterion naturally controls transform concentration.

### 8.4 Robustness with respect to phase

Because the argument uses only $|e^{i\phi}|=1$, perturbing the real phase does not change the bound. This robustness is useful when the exact oscillatory law is uncertain or nonlinear. It is also a warning: the estimate cannot improve when a special phase has exceptionally strong cancellation.

### 8.5 Multiscale certification

The proof architecture supports a useful certification workflow. At each level, record the largest observed branching numbers for the two supports. Their products give deterministic upper bounds for leaf counts. Independently, inspect the transform normalization and verify that every entry is bounded by the inverse square root of the ambient size. The final energy certificate is obtained by multiplying the support estimates and dividing by ambient cardinality. This modularity permits the geometric and analytic parts to be audited separately.

For nonuniform trees, one may retain levelwise data $a_r$ and $b_r$. The corresponding elementary certificate is

$$
\rho_n=\prod_{r=0}^{n-1}\frac{a_rb_r}{q}.
$$

Whenever the average logarithmic ratio is negative, namely

$$
\frac{1}{n}\sum_{r=0}^{n-1}\log\left(\frac{a_rb_r}{q}\right)<0,
$$

the certificate contracts. This observation does not by itself establish a general entropy theorem, but it identifies the exact statistic that such a theorem would refine.

### 8.6 Sharpness for entrywise information

The analytic estimate is optimal if only matrix-entry magnitudes and support sizes are known. Indeed, consider a restricted matrix whose entries all have the same phase and magnitude $N^{-1/2}$. Choose $f$ constant on $X$. Every output sum then aligns, Cauchy–Schwarz is an equality, and

$$
E_Y(T_Xf)=\frac{|X||Y|}{N}E_X(f).
$$

Thus no smaller universal coefficient can follow from entrywise normalization alone. Any improvement for genuine Fourier kernels must use relationships among phases, such as orthogonality, cancellation, or additive combinatorics. This sharpness example explains why the threshold is methodological rather than merely a defect of presentation.

## 9. Scope and limitations

The finite-scale theorem is an elementary strong-porosity result. It is not a general uncertainty theorem for every porous pair. Its central analytic step is the triangle inequality, which replaces an oscillatory sum by a sum of magnitudes. This loses all destructive interference.

The threshold $ab<q$ precisely marks the range in which support size alone suffices. If $ab=q$, the factor is $1$ and gives no strict loss. If $ab>q$, the factor exceeds $1$ and becomes weaker than a unitary bound when one is available. Nevertheless, particular transforms may still exhibit exponential decay in these regimes. Proving it requires data not contained in $|X|$ and $|Y|$.

Additive energy is one candidate. It measures the number of additive coincidences and can quantify how arithmetic structure affects Fourier concentration. Iterative energy improvement may supply a scale-local gain even when raw cardinalities do not. Entropy is another candidate: rigid bounds $a$ and $b$ can be replaced by average logarithmic branching over blocks. For random deletion, products of random branching ratios suggest concentration inequalities and Lyapunov exponents.

The distinction between energy and norm should also be kept explicit. The theorem's factor $(ab/q)^n$ controls squared $\ell^2$ norm. The operator norm itself is bounded by $(ab/q)^{n/2}$. Confusing the two would double the claimed decay exponent.

## 10. Future research

The most direct extension is additive-energy amplification beyond the cardinality threshold. One expects normalized Fourier restriction between sets with fixed block porosity to decay as $Cp^{-\beta n}$ even when maximal branching numbers satisfy $ab\ge p$. The present argument identifies the needed ingredient: a local gain replacing the crude product-cardinality estimate.

A second direction is block porosity. If $a_r$ and $b_r$ vary by level, the natural factor is

$$
\frac{\prod_{r<n}a_rb_r}{q^n}.
$$

Logarithms turn this product into a sum of local entropies. This suggests a theorem controlled by an entropy gap rather than a pointwise branching cap.

A third direction is stochastic deletion. In random level-dependent models, the logarithm of the uncertainty factor is a sum of random increments. High-probability decay should follow from concentration, while the almost-sure asymptotic exponent should be a Lyapunov exponent of the branching process.

Finally, the shared prime-power grading in Theorem 7.2 suggests an operator algebra containing both Fourier restriction and additive cellular evolution. In such a framework, uncertainty would occupy a contracting sector and Frobenius propagation an exactly self-similar sector. Establishing this bridge requires definitions beyond cardinality porosity but offers a concrete route toward unifying two arithmetic scale phenomena.

### 10.1 Quantitative questions for subsequent work

Several quantitative problems emerge directly from the explicit factor. First, an additive-energy refinement should identify a gain $\gamma<1$ that can be multiplied across suitable blocks of levels. If a block of length $L$ supplies such a gain, then approximately $n/L$ iterations would produce a factor of order $\gamma^{n/L}$, yielding a positive uncertainty exponent $-\log\gamma/L$. Determining the dependence of $\gamma$ on porosity is therefore a concrete local problem.

Second, entropy formulations should be stable under sparse exceptional levels. A bounded number of fully occupied levels changes the total factor only by a constant and should not alter the asymptotic exponent. More generally, a set of exceptional levels of density zero should contribute a subexponential correction. This suggests separating the principal exponential rate from finite-scale prefactors.

Third, numerical studies can compare the cardinality exponent with the observed Fourier exponent. For digit sets $D_X$ and $D_Y$, one can sample signals, compute restricted singular values, and track their logarithms against depth. The gap between the observed slope and the cardinality slope measures cancellation not captured by the present theorem. Such calculations do not replace analysis, but they can identify arithmetic digit patterns for which an additive-energy lemma is likely to be strongest.

## 11. Conclusion

A local branching deficit and a normalized kernel bound combine into a global uncertainty law. The tree recurrence gives $|X|\le a^n$ and $|Y|\le b^n$; the Hilbert–Schmidt estimate gives $E_Y(T_Xf)\le |X||Y|E_X(f)/q^n$; together they yield

$$
E_Y(T_Xf)\le \left(\frac{ab}{q}\right)^nE_X(f).
$$

The result is explicit, phase-independent, and algorithmically testable. Its contraction threshold $ab<q$ has a clean dimension-sum interpretation and a clear methodological meaning: below it, cardinality proves uncertainty; at or above it, cancellation must enter. At prime-power depths, the estimate coexists naturally with exact Frobenius self-similarity, revealing a common arithmetic hierarchy for contraction and renormalization.
