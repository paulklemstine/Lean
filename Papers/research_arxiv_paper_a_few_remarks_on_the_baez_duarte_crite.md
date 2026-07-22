# Finite Geometric-Mixture Identities for the Báez–Duarte Transform

**Aristotle**  
**July 22, 2026**

## Abstract

We isolate the finite algebraic structure underlying the Báez–Duarte transform. Given arbitrary real weights $\mu(n)$ and a cutoff $N$, define reciprocal-power moments by

$$
M_j(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^{2j+2}}
$$

and their alternating binomial transform by

$$
C_k(N)=\sum_{j=0}^{k}(-1)^j\binom{k}{j}M_j(N).
$$

We prove the exact geometric-mixture representation

$$
C_k(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}
\left(1-\frac{1}{n^2}\right)^k.
$$

No convergence assumption is involved. We derive a first-difference identity in which the reciprocal-square weight is raised to a reciprocal fourth power. For nonnegative weights, we prove nonnegativity and monotonic decrease in $k$. We also state and explain the complementary divisor-lattice Möbius identity

$$
\sum_{ab=n}\mu_{\mathrm{arith}}(a)\sigma_s(b)=n^s,
$$

which places arithmetic inversion beside binomial inversion. Algorithms for direct moment evaluation, stable geometric-mixture evaluation, and numerical identity testing are presented with complexity analysis. The results distinguish the exact finite combinatorics of the transform from the analytic questions required for passage to infinite series and from claims concerning the Riemann hypothesis.

## 1. Introduction

The Báez–Duarte approach to the Riemann hypothesis studies a sequence obtained by applying an alternating binomial transform to values related to reciprocal-power Dirichlet series. Such transforms often conceal their elementary structure: they are written as alternating sums of quantities that are themselves sums, while their most useful interpretation is as a superposition of geometric modes.

This paper develops that structure at a finite cutoff. The finite setting has three advantages. First, every exchange of sums is unconditionally valid. Second, the exact algebra can be separated from truncation errors and limiting arguments. Third, numerical implementations can compare two mathematically equal formulas with different stability profiles.

Let $\mu:\mathbb{N}_{>0}\to\mathbb{R}$ be any real sequence. The notation is intentionally general. The arithmetic Möbius function is an important eventual specialization, but none of the principal finite transform identities requires multiplicativity, integrality, or a sign restriction.

The central result identifies three views of one object:

1. reciprocal-power moments $M_j(N)$;
2. their alternating binomial transform $C_k(N)$;
3. a finite mixture of geometric sequences in $k$.

The third view makes finite-difference behavior immediate. It also exhibits the positive-weight case as a discrete moment problem on $[0,1)$. Separately, arithmetic Möbius inversion on the divisor lattice recovers powers from divisor sums. The two inversion mechanisms act on different partial orders but share a common conceptual role: both remove accumulated data to recover primitive components.

The scope is deliberately precise. The results below do not establish an infinite-series criterion, a truncation estimate, or the Riemann hypothesis. For arithmetic Möbius weights, signs destroy the direct positivity argument. What is established is the exact finite algebra that any analytic continuation of the program must respect.

## 2. Definitions and notation

Write $\mathbb{N}_0=\{0,1,2,\ldots\}$ and $\mathbb{N}_{>0}=\{1,2,3,\ldots\}$. Fix a cutoff $N\in\mathbb{N}_0$ and a real weight sequence $\mu$. When $N=0$, all sums indexed by $1\le n\le N$ are empty and hence equal to zero.

### Definition 2.1 (Cutoff reciprocal-power moments)

For $j\in\mathbb{N}_0$, define

$$
M_j(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^{2j+2}}.
$$

The exponent can be separated as $n^{2j+2}=n^2(n^2)^j$. Therefore

$$
M_j(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}\left(\frac{1}{n^2}\right)^j.
$$

Thus the moments themselves form a finite geometric mixture in the index $j$, with nodes $x_n=n^{-2}$.

### Definition 2.2 (Cutoff Báez–Duarte coefficients)

For $k\in\mathbb{N}_0$, define the alternating binomial transform

$$
C_k(N)=\sum_{j=0}^{k}(-1)^j\binom{k}{j}M_j(N).
$$

This transform is triangular: $C_k(N)$ depends only on $M_0(N),\ldots,M_k(N)$. The alternating signs can cause substantial cancellation in direct numerical evaluation.

### Definition 2.3 (Geometric nodes and amplitudes)

For $1\le n\le N$, define

$$
x_n=\frac{1}{n^2},\qquad r_n=1-x_n=1-\frac{1}{n^2},
\qquad a_n=\frac{\mu(n)}{n^2}.
$$

The nodes satisfy $0<x_n\le 1$ and the geometric ratios satisfy $0\le r_n<1$. In this notation, the principal representation will read

$$
C_k(N)=\sum_{n=1}^{N}a_nr_n^k.
$$

### Definition 2.4 (Forward difference)

For a sequence $f=(f_k)_{k\ge0}$, its forward difference is

$$
(\Delta f)_k=f_{k+1}-f_k.
$$

The negative forward difference is therefore

$$
(-\Delta f)_k=f_k-f_{k+1}.
$$

### Definition 2.5 (Arithmetic Möbius and divisor-power sum)

The arithmetic Möbius function $\mu_{\mathrm{arith}}$ is defined by $\mu_{\mathrm{arith}}(1)=1$; it is zero when its argument is divisible by the square of a prime; and it equals $(-1)^r$ when its argument is the product of $r$ distinct primes. For $s\in\mathbb{N}_0$, define

$$
\sigma_s(m)=\sum_{d\mid m}d^s.
$$

The symbol $\mu$ used for arbitrary real weights and the symbol $\mu_{\mathrm{arith}}$ used for the arithmetic Möbius function must be distinguished: positivity results apply only when the chosen weights are nonnegative.

## 3. The binomial collapse

The transform is governed by a pointwise polynomial identity.

### Lemma 3.1 (Alternating binomial collapse)

For every real number $x$ and every $k\in\mathbb{N}_0$,

$$
\sum_{j=0}^{k}(-1)^j\binom{k}{j}x^j=(1-x)^k.
$$

#### Proof sketch

Apply the binomial theorem to $1+(-x)$:

$$
(1-x)^k=\sum_{j=0}^{k}\binom{k}{j}1^{k-j}(-x)^j.
$$

Since $1^{k-j}=1$ and $(-x)^j=(-1)^jx^j$, the displayed expression is exactly the desired sum. $\square$

This identity is elementary, but its pointwise use is decisive. The reciprocal-power moment supplies $x=x_n=n^{-2}$ separately for every $n$.

## 4. Main geometric-mixture theorem

### Theorem 4.1 (Finite Báez–Duarte identity)

For every real weight sequence $\mu$, every cutoff $N\in\mathbb{N}_0$, and every $k\in\mathbb{N}_0$,

$$
C_k(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}
\left(1-\frac{1}{n^2}\right)^k.
$$

Equivalently, with $a_n=\mu(n)/n^2$ and $r_n=1-1/n^2$,

$$
C_k(N)=\sum_{n=1}^{N}a_nr_n^k.
$$

#### Proof sketch

Insert the moment definition into the binomial transform:

$$
C_k(N)=\sum_{j=0}^{k}(-1)^j\binom{k}{j}
\sum_{n=1}^{N}\frac{\mu(n)}{n^{2j+2}}.
$$

Because both sums are finite, reverse their order without any convergence hypothesis:

$$
C_k(N)=\sum_{n=1}^{N}\sum_{j=0}^{k}
(-1)^j\binom{k}{j}\frac{\mu(n)}{n^{2j+2}}.
$$

Factor $n^{2j+2}=n^2(n^2)^j$ to obtain

$$
C_k(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}
\sum_{j=0}^{k}(-1)^j\binom{k}{j}
\left(\frac{1}{n^2}\right)^j.
$$

Lemma 3.1 with $x=1/n^2$ collapses the inner sum to $(1-1/n^2)^k$. $\square$

### Remark 4.2 (Boundary cases)

If $N=0$, both sides are empty sums. If $k=0$, the theorem gives

$$
C_0(N)=M_0(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}.
$$

For $n=1$, the geometric ratio is $r_1=0$. With the standard convention $r^0=1$, this mode contributes $\mu(1)$ at $k=0$ and contributes zero for every $k\ge1$.

### Interpretation 4.3 (Discrete spectral decomposition)

The theorem decomposes $C_k(N)$ into modes $r_n^k$. The index $k$ acts as discrete time. Small $n$ gives rapid decay, while large $n$ gives a ratio close to one and therefore slow decay. This spectral language is descriptive rather than dependent on an operator-theoretic construction: the finite sequence is literally a linear combination of geometric sequences.

### Corollary 4.4 (Linear recurrence at fixed cutoff)

For fixed $N$, the sequence $k\mapsto C_k(N)$ satisfies a linear recurrence whose characteristic polynomial divides

$$
P_N(t)=\prod_{n=1}^{N}(t-r_n).
$$

#### Proof sketch

Each sequence $r_n^k$ is annihilated by the shift operator minus $r_n$. The product of these commuting first-order operators annihilates their finite linear combination. If some amplitude vanishes, the corresponding factor may be omitted, which is why the minimal characteristic polynomial need only divide $P_N$. $\square$

This corollary is an immediate mathematical consequence of the geometric representation and gives a further computational route for producing long coefficient sequences at a fixed cutoff.

## 5. Finite-difference calculus

### Theorem 5.1 (First-difference law)

For every real weight sequence $\mu$, every cutoff $N$, and every $k\in\mathbb{N}_0$,

$$
C_k(N)-C_{k+1}(N)
=
\sum_{n=1}^{N}\frac{\mu(n)}{n^4}
\left(1-\frac{1}{n^2}\right)^k.
$$

#### Proof sketch

Use Theorem 4.1 at $k$ and $k+1$, then subtract term by term. For each $n$, write $r_n=1-1/n^2$. The difference of the corresponding modes is

$$
\frac{\mu(n)}{n^2}r_n^k-
\frac{\mu(n)}{n^2}r_n^{k+1}
=
\frac{\mu(n)}{n^2}r_n^k(1-r_n).
$$

Since $1-r_n=1/n^2$, this equals $\mu(n)n^{-4}r_n^k$. Summation proves the formula. $\square$

The theorem says that the negative forward difference inserts one additional reciprocal-square factor. In operator notation,

$$
(-\Delta C)_k=
\sum_{n=1}^{N}\frac{\mu(n)}{n^4}r_n^k.
$$

### Proposition 5.2 (Higher-difference extension)

For every $q,k\in\mathbb{N}_0$,

$$
(-1)^q(\Delta^q C)_k
=
\sum_{n=1}^{N}\frac{\mu(n)}{n^{2q+2}}
\left(1-\frac{1}{n^2}\right)^k.
$$

#### Proof sketch

For a single mode $r^k$, one has $\Delta(r^k)=r^{k+1}-r^k=-(1-r)r^k$. Iterating gives

$$
\Delta^q(r^k)=(-1)^q(1-r)^qr^k.
$$

Apply this to each $r_n$, observe that $1-r_n=n^{-2}$, multiply by the amplitude $\mu(n)n^{-2}$, and sum. The case $q=1$ is Theorem 5.1. $\square$

This extension clarifies the complete finite-difference hierarchy suggested by the first-difference result. It follows directly in the finite setting because all operations distribute over finite sums.

## 6. Positive weights and discrete moment structure

Assume throughout this section that

$$
\mu(n)\ge0\qquad(1\le n\le N).
$$

### Theorem 6.1 (Nonnegativity)

For every $k\in\mathbb{N}_0$,

$$
C_k(N)\ge0.
$$

#### Proof sketch

For $n\ge1$, the ratio $r_n=1-1/n^2$ lies in $[0,1)$. Thus $r_n^k\ge0$. The amplitude $\mu(n)/n^2$ is nonnegative by assumption. Every summand in Theorem 4.1 is therefore nonnegative. $\square$

### Theorem 6.2 (Monotonicity)

For every $k\in\mathbb{N}_0$,

$$
C_{k+1}(N)\le C_k(N).
$$

#### Proof sketch

Since $0\le r_n\le1$, one has $r_n^{k+1}\le r_n^k$. Multiplication by the nonnegative amplitude $\mu(n)/n^2$ preserves the inequality, and summing over $n$ gives the result. Equivalently, Theorem 5.1 expresses $C_k(N)-C_{k+1}(N)$ as a sum of nonnegative terms. $\square$

### Corollary 6.3 (Complete monotonicity at finite cutoff)

For every $q,k\in\mathbb{N}_0$,

$$
(-1)^q(\Delta^q C)_k\ge0.
$$

#### Proof sketch

Apply Proposition 5.2. Every factor on its right-hand side is nonnegative. $\square$

### Definition 6.4 (Representing measure)

Define the finite positive measure

$$
\nu_N=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}\,\delta_{r_n},
$$

where $\delta_r$ denotes unit point mass at $r$. Its support lies in $[0,1)$. Theorem 4.1 becomes

$$
C_k(N)=\int_{[0,1)}t^k\,d\nu_N(t).
$$

Thus $C_k(N)$ is a Hausdorff moment sequence of a discrete measure with prescribed support $\{1-n^{-2}:1\le n\le N\}$.

### Warning 6.5 (Signed arithmetic weights)

The arithmetic Möbius function is signed. Therefore Theorems 6.1 and 6.2, and Corollary 6.3, cannot be applied to it merely by substituting $\mu=\mu_{\mathrm{arith}}$. The geometric-mixture identity and difference law remain valid for signed weights, but termwise positivity does not.

## 7. Divisor-lattice Möbius inversion

The preceding transform uses alternating binomial coefficients. A distinct inversion principle occurs on the divisor lattice.

### Theorem 7.1 (Divisor Möbius identity)

For every $s\in\mathbb{N}_0$ and every positive integer $n$,

$$
\sum_{ab=n}\mu_{\mathrm{arith}}(a)\sigma_s(b)=n^s.
$$

Equivalently, using Dirichlet convolution $*$,

$$
\mu_{\mathrm{arith}}*\sigma_s=\operatorname{pow}_s,
$$

where $\operatorname{pow}_s(n)=n^s$.

#### Proof sketch

Let $\mathbf{1}(n)=1$. By definition,

$$
\sigma_s(n)=\sum_{d\mid n}d^s=(\mathbf{1}*\operatorname{pow}_s)(n).
$$

The arithmetic Möbius function is the Dirichlet-convolution inverse of $\mathbf{1}$:

$$
\mu_{\mathrm{arith}}*\mathbf{1}=\varepsilon,
$$

where $\varepsilon(1)=1$ and $\varepsilon(n)=0$ for $n>1$. Associativity of Dirichlet convolution gives

$$
\mu_{\mathrm{arith}}*\sigma_s
=
\mu_{\mathrm{arith}}*(\mathbf{1}*\operatorname{pow}_s)
=
(\mu_{\mathrm{arith}}*\mathbf{1})*\operatorname{pow}_s
=
\varepsilon*\operatorname{pow}_s
=
\operatorname{pow}_s.
$$

Evaluating at $n$ yields the stated sum. $\square$

### Discussion 7.2 (Two incidence structures)

Binomial inversion can be viewed through the Boolean lattice of subsets, where $\binom{k}{j}$ counts rank-$j$ subsets of a $k$-element set. Arithmetic Möbius inversion is attached to the divisibility poset. Both invert an accumulation process, but they are not the same transform. The finite Báez–Duarte identity places them in a common investigation because reciprocal-power data undergo binomial transformation while the arithmetic Möbius function governs divisor convolution. A future two-parameter theory may clarify whether these incidence structures admit a useful tensor-product formulation.

## 8. Algorithms

### Algorithm 8.1 (Moment-transform evaluation)

Given weights $\mu(1),\ldots,\mu(N)$ and a maximum index $K$, compute all moments $M_j(N)$ for $0\le j\le K$, then apply the triangular binomial transform.

For each $j$, direct moment summation costs $O(N)$ arithmetic operations. Computing all $K+1$ moments costs $O(NK)$. Computing every $C_k(N)$ by its defining triangular sum costs $O(K^2)$. Total arithmetic complexity is therefore $O(NK+K^2)$, with $O(K)$ auxiliary storage if moments and outputs are retained.

This method mirrors the definition but may be numerically unstable for large $k$, because terms involving $\binom{k}{j}$ can be individually large while their alternating sum is small.

### Algorithm 8.2 (Geometric-mixture evaluation)

Precompute $a_n=\mu(n)/n^2$ and $r_n=1-1/n^2$. Initialize mode values $v_n=a_n$. For $k=0,\ldots,K$, sum the current $v_n$ to obtain $C_k(N)$ and update $v_n\leftarrow r_nv_n$.

This computes all coefficients in $O(NK)$ arithmetic operations and $O(N)$ auxiliary memory. It avoids repeated exponentiation and avoids binomial coefficients. For nonnegative weights, every accumulation is nonnegative, making the method especially stable. For signed weights, cancellation across modes can still occur, but cancellation internal to the alternating binomial formula has been eliminated.

### Algorithm 8.3 (Identity and difference audit)

For selected $N$ and $K$, compute each $C_k(N)$ by both methods. Report the absolute discrepancy and compare $C_k(N)-C_{k+1}(N)$ with the reciprocal-fourth-power mixture. Under exact rational arithmetic the discrepancies vanish identically. Under floating-point arithmetic they measure implementation and rounding effects rather than mathematical error.

The audit requires $O(NK+K^2)$ operations if the direct binomial route is recomputed and $O(NK)$ for the geometric and difference routes. It is useful for detecting indexing errors, especially the exponent $2j+2$, the inclusive cutoff, and the boundary mode $n=1$.

## 9. Numerical examples and applications

### Example 9.1 (Unit weights)

Let $\mu(n)=1$ and $N=4$. Then

$$
C_k(4)=
1\cdot0^k+rac14\left(\frac34\right)^k
+rac19\left(\frac89\right)^k
+rac1{16}\left(\frac{15}{16}\right)^k.
$$

At $k=0$, the value is $1+1/4+1/9+1/16$. For $k\ge1$, the first mode vanishes. Nonnegativity, monotonicity, and complete monotonicity are visible term by term.

### Example 9.2 (Alternating signs)

Let $\mu(n)=(-1)^{n+1}$. The finite identity remains exact:

$$
C_k(N)=\sum_{n=1}^{N}\frac{(-1)^{n+1}}{n^2}
\left(1-\frac{1}{n^2}\right)^k.
$$

However, no termwise positivity argument is available. This example separates the algebraic theorem, which is sign-independent, from the order properties, which require nonnegative amplitudes.

### Example 9.3 (Arithmetic Möbius weights)

For $\mu=\mu_{\mathrm{arith}}$, squareful integers contribute zero, squarefree integers with an even number of prime factors contribute positively, and squarefree integers with an odd number contribute negatively. The cutoff formula becomes

$$
C_k(N)=\sum_{n=1}^{N}\frac{\mu_{\mathrm{arith}}(n)}{n^2}
\left(1-\frac{1}{n^2}\right)^k.
$$

This is the finite geometric core relevant to the Báez–Duarte setting. Its large-$N$ behavior depends on cancellation among arithmetic signs and cannot be inferred from the positive model.

### Application 9.4 (Stable numerical exploration)

The geometric representation is preferable for exploratory computation. Ratios can be updated recursively, all cutoffs can be accumulated incrementally, and the influence of each integer is explicit. Long-lived modes correspond to large $n$ and can be analyzed as a tail, while small-$n$ contributions can be evaluated exactly or at high precision.

### Application 9.5 (Inverse problems)

At a finite cutoff, the distinct ratios $r_1,\ldots,r_N$ determine a Vandermonde system. Knowing $C_0(N),\ldots,C_{N-1}(N)$ permits recovery of the amplitudes $a_n$ in principle. The system may be ill-conditioned numerically because the ratios cluster near $1$, but algebraic uniqueness is clear. This observation motivates rigidity questions for infinite, absolutely summable mixtures.

## 10. Error structure and scaling

The finite identity also gives an exact increment in the cutoff. For every $N,k\in\mathbb{N}_0$,

$$
C_k(N+1)-C_k(N)=
\frac{\mu(N+1)}{(N+1)^2}
\left(1-\frac{1}{(N+1)^2}\right)^k.
$$

This follows by subtracting the two geometric mixtures; all terms through $N$ cancel. The formula exposes a two-scale competition. The amplitude of the newly added mode is of order $(N+1)^{-2}$ times the weight, while its decay ratio approaches $1$ as $N$ grows. For $k$ much smaller than $N^2$, the approximation

$$
\left(1-\frac{1}{N^2}\right)^k\approx e^{-k/N^2}
$$

suggests that the mode remains substantial. For $k$ much larger than $N^2$, it is strongly damped. This observation does not itself provide a uniform theorem, but it identifies $k/N^2$ as a natural scaling variable for tail analysis.

If the weights satisfy an absolute bound $|\mu(n)|\le B$, then comparison with the reciprocal-square tail gives, whenever an infinite mixture is known to exist absolutely,

$$
\left|\sum_{n>N}\frac{\mu(n)}{n^2}
\left(1-\frac{1}{n^2}\right)^k\right|
\le B\sum_{n>N}\frac{1}{n^2}.
$$

The right-hand side is independent of $k$ but does not exploit geometric damping. More refined estimates should split the tail around the transition $n\asymp\sqrt{k}$. The exact finite representation therefore indicates both a baseline bound and the location from which stronger uniform bounds may come.

Roundoff error has a different character. In the defining transform, the condition number can grow because $\binom{k}{j}$ amplifies moment errors before alternating cancellation. In the geometric method, each mode is obtained by multiplying by a number in $[0,1]$. For nonnegative weights, summation has no cancellation and is backward stable under standard assumptions. For signed weights, compensated summation or higher precision remains advisable.

## 11. Discussion

The finite theory draws a sharp boundary between combinatorics and analysis. The exchange of sums in Theorem 4.1 is harmless because both index sets are finite. In an infinite version, one must justify rearrangement or proceed through controlled limits. The finite theorem therefore does not smuggle in an unproved convergence claim.

The positive-weight case supplies a model of maximal regularity. It realizes the coefficient sequence as moments of a positive measure, immediately producing a hierarchy of finite-difference inequalities. Arithmetic Möbius weights replace positivity with oscillation. Understanding whether this oscillation forces sufficient decay is the genuinely number-theoretic issue.

The divisor identity adds a complementary arithmetic layer. In the geometric mixture, $\mu(n)$ is an amplitude attached directly to the integer $n$. In divisor inversion, $\mu_{\mathrm{arith}}$ is a convolution inverse that removes divisor aggregation. Their simultaneous presence suggests organizing future work around two axes: binomial rank and divisor incidence.

From a computational perspective, the finite identity is also an algorithmic refactoring. It replaces a triangular alternating transform by mode evolution. The arithmetic complexity is competitive, and numerical behavior is often better. The first-difference law supplies an independent checksum and gives a direct way to calculate changes without subtracting nearly equal coefficients.

### 11.1 Limits of the finite conclusions

The hypotheses and quantifiers deserve emphasis. The cutoff $N$ and transform index $k$ are arbitrary nonnegative integers, and the weights may be any real sequence on the positive integers. Thus the algebraic identities are not numerical approximations. By contrast, no statement here identifies a rate at which $C_k(N)$ approaches an infinite coefficient as $N$ grows. Such a rate requires assumptions on the weights and a tail argument.

Likewise, monotonicity is conditional rather than universal. It follows from the sign of every amplitude $\mu(n)/n^2$. A signed sequence can still happen to be decreasing over some range, but that observation would not follow from the theorem. Finally, the divisor Möbius identity is an exact arithmetic convolution statement, not an assertion that divisor inversion and the binomial transform are already one operation. Their proposed combination remains a research direction. These distinctions prevent finite algebra, positive-measure structure, and infinite arithmetic cancellation from being silently conflated.

## 12. Future work

Several problems arise naturally.

First, one should quantify passage from finite cutoffs to full coefficients. For fixed $k$, reciprocal-square tails are manageable under suitable hypotheses, but the important question is uniformity when $k$ grows with $N$. The factor $(1-n^{-2})^k$ couples the two scales and may permit sharper estimates than the raw moment formula suggests.

Second, the complete finite-difference hierarchy should be extended to infinite positive mixtures under summability, together with a representation and uniqueness theorem for measures supported on $\{1-n^{-2}:n\ge1\}$.

Third, the infinite alternating binomial transform should be studied on weighted Banach sequence spaces. Finite triangular inversion is algebraic; bounded involution after completion depends on balancing Pascal growth against sequence decay.

Fourth, divisor-lattice and Boolean-lattice inversions may admit a two-parameter incidence algebra whose spectral data jointly encode reciprocal moments and divisor sums.

Finally, rigidity of geometric supports should be investigated. The support points have a single accumulation point at $1$. Sufficient decay and absolute summability may force two representations of the same sequence to agree term by term, converting transform data back into unique arithmetic amplitudes.

## 13. Conclusion

The finite Báez–Duarte transform has an exact and elementary geometric structure. Alternating binomial combinations of reciprocal-power moments are precisely finite mixtures of modes $(1-n^{-2})^k$. Negative forward differences insert additional reciprocal-square factors. Nonnegative weights yield nonnegative, decreasing, and indeed completely monotone sequences. Separately, divisor-lattice Möbius inversion recovers $n^s$ from the convolution of $\mu_{\mathrm{arith}}$ with $\sigma_s$.

These facts do not settle the analytic or arithmetic questions attached to the full criterion. They do something more foundational: they isolate the identities that are exact before limits are taken. The remaining difficulty can therefore be stated cleanly in terms of tails, cancellation, continuity of transforms, and uniqueness of geometric representations.