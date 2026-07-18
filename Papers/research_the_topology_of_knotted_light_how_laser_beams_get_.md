# Alexander-Polynomial Selection Rules for Angular Spectra of Knotted Light

**Aristotle**  
**July 18, 2026**

## Abstract

We study a precise spectral model for knotted optical fields: an angular channel is selected when an equally spaced unit-circle phase is a zero of the knot’s Alexander polynomial. For the prime two-strand torus-knot family $T(2,p)$, with $p$ an odd prime, the normalized Alexander polynomial is the cyclotomic polynomial $\Phi_{2p}$. This identifies the selected channels exactly: on the $2p$-point phase grid, the index $l$ is selected if and only if $\gcd(l,2p)=1$. The trefoil therefore selects $l\equiv1,5\pmod6$, and the cinquefoil selects $l\equiv1,3,7,9\pmod {10}$. We give exact and numerical algorithms for generating and checking these spectra. We also establish a decisive boundary result: the figure-eight polynomial $t^2-3t+1$ has no unit-circle roots and hence selects no channel on any angular grid. Its reciprocal real roots $(3\pm\sqrt5)/2$ cannot be converted into angular residues by reduction modulo one. The contrast separates angular information, carried by root arguments, from radial growth information, carried by root moduli. The results are conditional predictions of an Alexander-filter optical model rather than a derivation from Maxwell’s equations, and they motivate experiments that jointly resolve orbital-angular-momentum channels and radial propagation rates.

## 1. Introduction

Optical phase singularities are curves along which a complex wave amplitude vanishes. In a three-dimensional field, such a curve may close into a knot. The resulting “knotted light” connects singular optics with low-dimensional topology: the field supplies a geometric knot, while knot polynomials offer algebraic summaries of its type.

A natural question is whether a knot polynomial can be read from an optical spectrum. Orbital angular momentum provides a plausible spectral coordinate. In an azimuthal mode with integer charge $l$, the phase varies as $e^{il\theta}$. A finite angular sampling with $N$ positions therefore produces the phases

$$
z_{N,l}=\exp\!\left(\frac{2\pi i l}{N}\right),
\qquad l\in\mathbb Z.
$$

Suppose an optical transfer rule associated with a knot $K$ selects a phase precisely when that phase is a zero of an Alexander polynomial $\Delta_K(t)$. The resulting mathematical spectrum is

$$
S_N(\Delta_K)=\{l\bmod N:\Delta_K(z_{N,l})=0\}.
$$

This definition is the central model of the paper. It is deliberately narrow. It does not assert that every knotted optical field realizes such a transfer rule, nor does topology alone imply a particular electromagnetic coupling. Rather, it determines exactly what follows if an Alexander-polynomial phase filter is implemented.

The prime family of two-strand torus knots admits a complete classification. Its Alexander polynomials are cyclotomic, so their unit-circle roots fit naturally onto an angular phase grid. The selected indices are not isolated numerical coincidences: they are the units in a modular ring. In contrast, the figure-eight knot has reciprocal real roots away from the unit circle. It has no channels at all under the same angular selection rule. This negative result corrects the proposal that one may reduce arbitrary real roots modulo one to manufacture angular residues.

The paper proceeds from definitions to a general theorem, explicit examples, algorithms, and physical interpretation. Section 2 fixes the polynomial normalization and distinguishes angular from radial root data. Section 3 proves the primitive-phase and coprimality lemmas. Section 4 establishes the prime torus-knot selection theorem. Section 5 treats the trefoil and cinquefoil. Section 6 proves the figure-eight exclusion theorem and discusses the unknot. Sections 7 and 8 present algorithms and numerical examples. Sections 9–11 discuss applications, limitations, and future work.

## 2. Mathematical and optical setting

### 2.1 Angular phases and selected spectra

**Definition 2.1 (angular phase grid).** For a positive integer $N$ and an integer $l$, define

$$
z_{N,l}=e^{2\pi i l/N}.
$$

The value depends only on $l$ modulo $N$, and every $z_{N,l}$ has modulus one. The grid is the cyclic group of $N$th roots of unity.

**Definition 2.2 (Alexander-selected angular spectrum).** Let $A(t)\in\mathbb Z[t]$. Its selected spectrum on the $N$-point angular grid is

$$
S_N(A)=\{l\in\{0,1,\ldots,N-1\}:A(z_{N,l})=0\}.
$$

For a knot polynomial, this set is a model of selected orbital-angular-momentum residue classes. The definition tests polynomial values at phases. It does not assign angular meaning to a root merely because the root is real or because its numerical value can be reduced modulo one.

The Alexander polynomial is usually defined only up to multiplication by $\pm t^m$. This ambiguity does not change the nonzero roots and therefore does not change $S_N(A)$: for $z_{N,l}\ne0$, multiplication by $\pm z_{N,l}^m$ cannot create or remove a zero.

### 2.2 Two-strand torus knots

For odd $n\ge3$, the knot $T(2,n)$ is the closure of a two-strand braid with $n$ crossings. We use the normalized alternating Alexander polynomial

$$
A_n(t)=t^{n-1}-t^{n-2}+t^{n-3}-\cdots-t+1
       =\sum_{k=0}^{n-1}(-1)^k t^{n-1-k}.
$$

Because $n$ is odd, multiplication by $t+1$ telescopes:

$$
(t+1)A_n(t)=t^n+1.
$$

Equivalently,

$$
A_n(t)=\frac{t^n+1}{t+1},
$$

where the quotient is a polynomial because $-1$ is a root of $t^n+1$.

When $p$ is an odd prime, the cyclotomic factorization of $t^p+1$ is

$$
t^p+1=(t+1)\Phi_{2p}(t).
$$

Hence

$$
A_p(t)=\Phi_{2p}(t).
$$

This prime assumption is structurally important. For composite odd $n$, the quotient generally splits into several cyclotomic factors rather than a single one.

### 2.3 Primitive roots and modular units

**Definition 2.3 (primitive root of unity).** A complex number $z$ is a primitive $N$th root of unity if $z^N=1$ and $z^d\ne1$ for every integer $d$ with $1\le d<N$.

The roots of $\Phi_N(t)$ are exactly the primitive $N$th roots of unity. There are $\varphi(N)$ of them, where $\varphi$ is Euler’s totient function.

**Definition 2.4 (modular unit).** A residue $l$ modulo $N$ is a unit if it has a multiplicative inverse modulo $N$. Equivalently,

$$
\gcd(l,N)=1.
$$

The set of such residues forms the group $(\mathbb Z/N\mathbb Z)^\times$.

### 2.4 Angular and radial data

Every nonzero complex root $r$ can be written as

$$
r=\rho e^{i\theta},
\qquad \rho>0.
$$

Its argument $\theta$ is compatible with angular phase, while its modulus $\rho$ describes distance from the unit circle. A root can coincide with $z_{N,l}$ only if $\rho=1$. Off-circle roots may still have physical meaning, but not as pure phase-grid points. Their logarithmic moduli $\log\rho$ naturally suggest exponential growth or decay rates.

## 3. Phase-grid lemmas

The classification rests on two elementary facts.

**Lemma 3.1 (generator of the angular grid).** For every positive integer $N$, the phase $z_{N,1}$ is a primitive $N$th root of unity.

**Proof sketch.** Its $N$th power is $e^{2\pi i}=1$. If $z_{N,1}^d=1$ for a positive integer $d<N$, then $e^{2\pi i d/N}=1$, so $d/N$ is an integer. This is impossible for $0<d<N$. Thus its order is exactly $N$. $\square$

**Lemma 3.2 (power representation).** For every integer $l$,

$$
z_{N,l}=z_{N,1}^{\,l}.
$$

**Proof sketch.** Apply the exponential identity $e^{la}=(e^a)^l$ for integer $l$ to $a=2\pi i/N$. $\square$

**Lemma 3.3 (primitive-power criterion).** If $\zeta$ is a primitive $N$th root of unity, then $\zeta^l$ is primitive of order $N$ if and only if $\gcd(l,N)=1$.

**Proof sketch.** The order of $\zeta^l$ is $N/\gcd(l,N)$. Indeed, $(\zeta^l)^m=1$ exactly when $N$ divides $lm$, and the least positive such $m$ is $N/\gcd(l,N)$. This equals $N$ precisely when the greatest common divisor is one. $\square$

These lemmas convert geometry on the unit circle into arithmetic. The $l$th grid point is a primitive point exactly when $l$ is a modular unit.

## 4. Exact selection for prime torus knots

**Theorem 4.1 (primitive-root characterization).** Let $p$ be an odd prime and let $l$ be an integer. Then

$$
A_p(z_{2p,l})=0
$$

if and only if $z_{2p,l}$ is a primitive $2p$th root of unity.

**Proof sketch.** The polynomial identity $A_p(t)=\Phi_{2p}(t)$ holds for every odd prime $p$. By the defining root property of a cyclotomic polynomial, $\Phi_{2p}(z)=0$ exactly for primitive $2p$th roots $z$. Substituting $z=z_{2p,l}$ proves the equivalence. $\square$

**Theorem 4.2 (exact coprimality selection rule).** Let $p$ be an odd prime. On the $2p$-point grid, the Alexander-selected spectrum of $T(2,p)$ is

$$
S_{2p}(A_p)
=
\{l\in\{0,1,\ldots,2p-1\}:\gcd(l,2p)=1\}.
$$

Equivalently, for every integer $l$,

$$
A_p(z_{2p,l})=0
\quad\Longleftrightarrow\quad
\gcd(l,2p)=1.
$$

**Proof sketch.** By Theorem 4.1, vanishing is equivalent to $z_{2p,l}$ being primitive. Lemma 3.1 makes $z_{2p,1}$ primitive, Lemma 3.2 writes $z_{2p,l}$ as its $l$th power, and Lemma 3.3 says that this power remains primitive exactly when $l$ is coprime to $2p$. $\square$

Several consequences follow immediately.

**Corollary 4.3 (channel count).** For odd prime $p$, the number of selected residues in one period is

$$
|S_{2p}(A_p)|=\varphi(2p)=p-1.
$$

**Proof sketch.** Theorem 4.2 identifies the spectrum with the units modulo $2p$, whose cardinality is $\varphi(2p)$. Since $p$ is odd prime, $\varphi(2p)=\varphi(2)\varphi(p)=p-1$. $\square$

**Corollary 4.4 (periodicity and conjugation symmetry).** Selection depends only on $l$ modulo $2p$. Moreover, if $l$ is selected, then $2p-l$ is selected, and the corresponding phases are complex conjugates.

**Proof sketch.** Both $z_{2p,l}$ and $\gcd(l,2p)$ depend only on the residue class. Coprimality is preserved by negation, and $z_{2p,-l}=\overline{z_{2p,l}}$. $\square$

**Corollary 4.5 (Galois organization).** The selected phases form the full set of primitive $2p$th roots and are permuted transitively by exponentiation with units modulo $2p$.

This means the spectrum is algebraically structured rather than a collection of unrelated channels.

## 5. Explicit torus-knot spectra

### 5.1 Trefoil

For $p=3$, the knot $T(2,3)$ is the trefoil and

$$
A_3(t)=t^2-t+1=\Phi_6(t).
$$

**Theorem 5.1 (trefoil spectrum).** In one period $0\le l<6$,

$$
A_3(z_{6,l})=0
\quad\Longleftrightarrow\quad
l\in\{1,5\}.
$$

Thus the full selection rule is $l\equiv1$ or $5\pmod6$.

**Proof sketch.** By Theorem 4.2, selected residues are those coprime to $6$. Direct enumeration gives $1$ and $5$. Equivalently, the roots are $e^{i\pi/3}$ and $e^{5i\pi/3}$. $\square$

A direct substitution illustrates the cancellation. If $z=e^{i\pi/3}$, then $z^2-z+1=0$; conjugating gives the second root. The channel count is $2=3-1$.

### 5.2 Cinquefoil

For $p=5$, the knot $T(2,5)$ is the cinquefoil and

$$
A_5(t)=t^4-t^3+t^2-t+1=\Phi_{10}(t).
$$

**Theorem 5.2 (cinquefoil spectrum).** In one period $0\le l<10$,

$$
A_5(z_{10,l})=0
\quad\Longleftrightarrow\quad
l\in\{1,3,7,9\}.
$$

Thus the complete rule is $l\equiv1,3,7,$ or $9\pmod {10}$.

**Proof sketch.** Theorem 4.2 reduces the test to coprimality with $10$. The residues $1,3,7,9$ and only those residues have greatest common divisor one with $10$. $\square$

The channel count is $4=5-1$. The pairs $(1,9)$ and $(3,7)$ are related by complex conjugation.

## 6. Off-circle roots: figure-eight and unknot

The figure-eight knot has normalized Alexander polynomial

$$
F(t)=t^2-3t+1.
$$

Its roots are

$$
r_+=\frac{3+\sqrt5}{2},
\qquad
r_-=\frac{3-\sqrt5}{2},
$$

with $r_+r_-=1$. Numerically, $r_+\approx2.618$ and $r_-\approx0.382$. Neither has modulus one.

**Theorem 6.1 (figure-eight unit-circle exclusion).** If $z\in\mathbb C$ and $|z|=1$, then

$$
z^2-3z+1\ne0.
$$

**Proof sketch.** Assume $z^2-3z+1=0$. Since $|z|=1$, $z\ne0$; division by $z$ yields $z+z^{-1}=3$. Unit modulus gives $z^{-1}=\overline z$, hence $2\operatorname{Re}(z)=3$. But $|\operatorname{Re}(z)|\le|z|=1$, so the left side lies in $[-2,2]$, a contradiction. $\square$

**Corollary 6.2 (no figure-eight angular-grid channel).** For every positive integer $N$ and every integer $l$,

$$
F(z_{N,l})\ne0.
$$

**Proof sketch.** Every angular-grid point has modulus one, so Theorem 6.1 applies. $\square$

The result rules out the proposed assignment obtained by taking $r_\pm$ modulo one. Reduction modulo one is meaningful for an angular coordinate before exponentiation, not for the modulus of a polynomial root. In general,

$$
F(r)=0
$$

does not imply

$$
F\!\left(e^{2\pi i(r\bmod1)}\right)=0.
$$

Indeed, Theorem 6.1 says the latter is impossible for this polynomial.

For the unknot, the normalized Alexander polynomial is the constant $1$. Therefore

$$
S_N(1)=\varnothing
$$

for every $N$: a nonzero constant has no roots. A baseline channel $l=0$ may be physically useful, but it is an additional convention and not a consequence of the literal zero-selection definition.

## 7. Algorithms

### 7.1 Exact modular spectrum generation

For an odd prime $p$, Theorem 4.2 yields an exact algorithm that avoids complex arithmetic.

**Algorithm 7.1 (modular-unit spectrum generator).**

**Input:** an odd prime $p$.  
**Output:** the selected residues for $T(2,p)$.

1. Set $N=2p$.
2. Initialize an empty list $S$.
3. For each $l=0,1,\ldots,N-1$, compute $\gcd(l,N)$.
4. Append $l$ to $S$ exactly when the greatest common divisor is $1$.
5. Return $S$.

Using the Euclidean algorithm, each greatest-common-divisor computation costs $O(\log N)$ arithmetic steps, so the complete scan costs $O(N\log N)$ in a simple model and uses $O(\varphi(N))$ output space. A sieve can improve bulk generation, but the direct method is transparent and sufficient for moderate $p$.

### 7.2 Numerical polynomial-grid verification

A second algorithm evaluates the polynomial directly and is useful for experiments.

**Algorithm 7.2 (complex phase-grid residual scan).**

**Input:** coefficients $a_0,\ldots,a_d$, grid size $N$, and tolerance $\varepsilon>0$.  
**Output:** indices whose residual is below tolerance.

1. For each $l=0,\ldots,N-1$, compute $z=e^{2\pi il/N}$.
2. Evaluate $A(z)=a_0+a_1z+\cdots+a_dz^d$ by Horner’s rule.
3. Record $l$ if $|A(z)|<\varepsilon$.
4. Return the indices and all residual magnitudes.

The cost is $O(Nd)$ complex operations and $O(N)$ storage if all residuals are retained. Floating-point output is demonstrative rather than exact; for the prime torus family it should be compared against Algorithm 7.1.

### 7.3 Root-geometry classification

**Algorithm 7.3 (angular-versus-radial root classifier).**

**Input:** approximations to the roots $r_j$ and a tolerance $\varepsilon$.  
**Output:** unit-circle candidates and off-circle radial rates.

1. For every root $r_j$, compute its modulus $\rho_j=|r_j|$ and argument $\theta_j=\arg r_j$.
2. If $|\rho_j-1|<\varepsilon$, classify it as angular and report $\theta_j/(2\pi)$ modulo one.
3. Otherwise classify it as radial and report the logarithmic rate $\log\rho_j$.
4. For reciprocal polynomials, compare roots in pairs and check whether rates cancel.

Numerical root finding dominates the complexity; for a dense degree-$d$ polynomial, standard companion-matrix methods are typically cubic in $d$. For the figure-eight quadratic, the roots are available exactly.

## 8. Numerical demonstrations

For the trefoil, evaluation on the six-point grid gives residuals near numerical zero only at $l=1$ and $l=5$. The modular test gives the same set exactly:

$$
\{l:0\le l<6,\ \gcd(l,6)=1\}=\{1,5\}.
$$

For the cinquefoil, the ten-point scan vanishes only at $l=1,3,7,9$, matching

$$
\{l:0\le l<10,\ \gcd(l,10)=1\}=\{1,3,7,9\}.
$$

For the figure-eight polynomial, a scan over any chosen grid finds no zero. The absence is robust as the grid is refined because it follows from Theorem 6.1, not from insufficient sampling. The exact roots instead produce radial rates

$$
\lambda_+=\log\!\left(\frac{3+\sqrt5}{2}\right),
\qquad
\lambda_-=-\lambda_+.
$$

If $\phi=(1+\sqrt5)/2$ is the golden ratio, then $(3+\sqrt5)/2=\phi^2$, so $\lambda_+=2\log\phi$.

## 9. Interpretation and applications

### 9.1 Spectral fingerprints within a prime family

Within $T(2,p)$ for odd primes, the period $2p$ and channel count $p-1$ both recover $p$. Thus an observed modular-unit spectrum determines the family parameter under the model. This is not a universal knot classifier: different knots can share Alexander polynomials, and an optical apparatus may introduce additional channels. It is a precise inverse statement within a restricted family and transfer rule.

### 9.2 Algebraic robustness

The exact selection rule is insensitive to small numerical threshold choices because it is arithmetic. Experimental noise still affects measured amplitudes, but the predicted support is a discrete set with strong symmetries. Conjugate channels should appear in pairs, and multiplication by any modular unit permutes the primitive phases. These constraints provide consistency checks for data.

### 9.3 Angular and radial spectroscopy

The figure-eight result suggests extending measurements beyond orbital angular momentum. A transfer polynomial with off-circle roots may influence radial localization, amplification, attenuation, or evanescence. Jointly resolving root arguments and logarithmic moduli would preserve information lost by a unit-circle-only test.

The logarithmic Mahler measure of a monic polynomial $A(t)=\prod_j(t-r_j)$ is

$$
m(A)=\sum_j\log\max(1,|r_j|).
$$

Cyclotomic prime torus polynomials have $m(A_p)=0$. For the figure-eight polynomial,

$$
m(F)=\log\!\left(\frac{3+\sqrt5}{2}\right)=2\log\phi.
$$

This statistic is a candidate aggregate radial-growth measure.

### 9.4 Holographic implementation

An experimental program would require a hologram or transfer element whose response genuinely contains $A(e^{i\theta})$. One possible design strategy is to encode polynomial coefficients into interferometric paths whose phase delays contribute powers of $e^{i\theta}$. The output amplitude would then be a coherent sum approximating the polynomial. OAM-resolved detection could test the predicted support. Such an implementation is an engineering proposal, not a consequence of the knot alone.

## 10. Limitations and critical distinctions

First, the results analyze a selection model; they do not derive the model from Maxwell’s equations. A phase singularity tracing knot $K$ does not automatically force the field’s OAM amplitudes to equal evaluations of $\Delta_K$.

Second, Alexander polynomials are knot invariants but are not complete invariants. Even perfect recovery of the polynomial need not recover the knot uniquely.

Third, the grid size in this paper is $2p$, the cyclotomic order naturally associated with $A_p$, not simply the minimal crossing number $p$. Confusing those integers changes the sampled phases.

Fourth, primality is essential to the single-cyclotomic-factor theorem. Composite odd parameters produce multiple root strata and require a divisor analysis.

Fifth, no real root should be transformed into an angular channel merely by reducing its numerical value modulo one. Angular sampling concerns $e^{2\pi il/N}$, and only unit-modulus roots can coincide with such phases.

Finally, the literal constant-polynomial rule assigns the unknot an empty selected set. Any “trivial $l=0$ channel” must be specified separately as a reference mode.

## 11. Future work

Composite $T(2,n)$ knots are the immediate algebraic extension. The identity $(t+1)A_n(t)=t^n+1$ suggests decomposition into primitive $2d$th-root strata indexed by divisors $d$ of $n$. This should yield a channel count expressed through totients.

Products of optical filters invite a Chinese-remainder analysis. Prime spectra are modular unit groups, while multiplication of phase factors adds angular indices. The interaction between two moduli should reveal degeneracies controlled by their greatest common divisor.

For off-circle roots, radial propagation should be modeled explicitly. The figure-eight rates $\pm2\log\phi$ provide a simple target. A successful experiment would distinguish phase winding from radial attenuation rather than folding both into one angular observable.

Mahler measure offers a global summary of radial instability and separates cyclotomic zero-growth cases from positive-growth examples. Its relation to optical Lyapunov exponents deserves both analytic and experimental study.

Finally, inverse reconstruction should be tested under realistic noise. Within the prime family, channel count and period identify $p$, but threshold errors may add or remove channels. Group symmetries and conjugate pairing can serve as error-detecting constraints.

## 12. Conclusion

For the prime torus knots $T(2,p)$, Alexander-polynomial selection on the natural $2p$-point phase grid has an exact answer: a channel survives precisely when its index is coprime to $2p$. The trefoil spectrum is $\{1,5\}$ modulo $6$, and the cinquefoil spectrum is $\{1,3,7,9\}$ modulo $10$. The spectrum is therefore the modular unit group, with $p-1$ channels and cyclotomic symmetry.

The figure-eight knot marks the boundary of this angular interpretation. Its polynomial has no unit-circle roots, so no angular grid can contain a selected phase. Its reciprocal real roots instead carry nonzero logarithmic moduli, suggesting radial growth and decay. The correct general lesson is not that every Alexander root is an OAM value, but that complex roots separate into angular and radial data. A viable theory of knotted-light spectroscopy should measure both.
