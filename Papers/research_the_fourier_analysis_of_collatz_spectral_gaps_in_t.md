# A Continuity Obstruction to Global Irrational-Frequency Gaps in Finite Collatz Exponential Sums

**Aristotle**  
**19 July 2026**

## Abstract

Let $T:\mathbb N_{>0}\to\mathbb N_{>0}$ be the unaccelerated Collatz map, defined by $T(n)=n/2$ for even $n$ and $T(n)=3n+1$ for odd $n$. For a cutoff $N$ and real frequency $\omega$, consider the finite exponential sum

$$
F_N(\omega)=\sum_{n=1}^{N}\exp\!\left(2\pi i\omega\frac{T(n)}{n}\right).
$$

A proposed spectral-gap criterion asks for a constant $C<\sqrt N$ such that $|F_N(\omega)|<C$ at every irrational frequency. We show that this criterion is impossible for every $N>1$. The reason is topological rather than Collatz-specific: $F_N$ is continuous, $F_N(0)=N$, and irrational numbers are dense. Consequently, for every $\varepsilon>0$ there is an irrational $\omega$ for which $|F_N(\omega)|>N-\varepsilon$. The triangle inequality supplies the sharp global bound $|F_N(\omega)|\leq N$. More generally, every finite exponential sum of $N$ unit-amplitude terms has irrational frequencies at which its magnitude exceeds any prescribed $C<N$. We also derive an exact even–odd decomposition of the Collatz sum, describe reliable numerical procedures, and formulate corrected research questions based on normalization, resonance exclusion, averaged estimates, and orbit-dependent transforms. The results do not resolve the Collatz conjecture; they identify a universal obstruction that any viable spectral formulation must avoid.

## 1. Introduction

The Collatz map is defined by the elementary parity-dependent rule

$$
T(n)=
\begin{cases}
n/2, & n\equiv0\pmod 2,\\
3n+1, & n\equiv1\pmod 2.
\end{cases}
$$

The Collatz conjecture asserts that every positive integer eventually reaches $1$ under iteration of $T$. Equivalently, every forward orbit is conjectured eventually to enter the cycle

$$
1\longmapsto4\longmapsto2\longmapsto1.
$$

Despite extensive computation and substantial partial theory, the conjecture remains unresolved. Its mixture of contraction on even inputs and expansion on odd inputs has encouraged probabilistic, dynamical, arithmetic, and spectral interpretations.

One proposed spectral statistic is the finite Fourier-type sum

$$
F_N(\omega)=\sum_{n=1}^{N}e^{2\pi i\omega T(n)/n}.
$$

The ratio $T(n)/n$ records the one-step multiplicative behavior of the map, while the frequency $\omega$ turns these ratios into phases on the unit circle. Small magnitude would indicate cancellation among the phases; large magnitude would indicate coherence. This motivates a proposed “spectral gap” asserting the existence of $C<\sqrt N$ such that $|F_N(\omega)|<C$ for every irrational $\omega$.

The central observation of this paper is that irrationality is not a separation condition from resonance. Irrational numbers lie arbitrarily close to zero and, more generally, to every integer. Because every summand equals $1$ at zero frequency, $F_N(0)=N$. Since the finite sum is continuous, its magnitude remains close to $N$ at all sufficiently small frequencies, including irrational ones. Thus the proposed bound fails for reasons independent of the arithmetic of $T$.

This negative conclusion serves several purposes. It gives a complete resolution of the stated finite-cutoff gap question. It isolates the universal zero-frequency peak from genuinely arithmetic cancellation. It also prevents an invalid inference from the one-step sum to Collatz stopping times. The appropriate response is not to abandon Fourier analysis, but to reformulate the spectral problem using normalized sums on sets bounded away from resonances, averaged norms, or signals constructed from individual orbits.

The paper is organized as follows. Section 2 establishes definitions and elementary properties. Section 3 proves a general near-peak principle for continuous complex-valued functions. Section 4 applies it to the Collatz sum and disproves the proposed global irrational-frequency gap. Section 5 extends the obstruction to arbitrary finite phase sums. Section 6 derives the exact parity decomposition. Sections 7 and 8 present algorithms and numerical interpretation. Sections 9 and 10 discuss corrected formulations, applications, limitations, and future work.

## 2. Definitions and preliminary observations

Throughout, $\mathbb N_{>0}=\{1,2,3,\ldots\}$, $i^2=-1$, and $|z|$ denotes the complex modulus.

**Definition 2.1 (Collatz map).** The unaccelerated Collatz map $T:\mathbb N_{>0}\to\mathbb N_{>0}$ is

$$
T(n)=
\begin{cases}
n/2, & n\text{ even},\\
3n+1, & n\text{ odd}.
\end{cases}
$$

**Definition 2.2 (finite Collatz exponential sum).** For an integer $N\geq1$ and $\omega\in\mathbb R$, define

$$
F_N(\omega)=\sum_{n=1}^{N}
\exp\!\left(2\pi i\omega\frac{T(n)}{n}\right).
$$

The terminology “Fourier transform” is suggestive, but $F_N$ is most precisely a finite exponential sum with nonuniform real phases $T(n)/n$. Each summand has modulus one.

**Definition 2.3 (proposed global irrational-frequency gap).** For a fixed $N>1$, the proposed gap property is the assertion that there exists $C\in\mathbb R$ satisfying $C<\sqrt N$ and

$$
|F_N(\omega)|<C
$$

for every irrational $\omega\in\mathbb R$.

The strict inequalities are part of the proposal. They will be contradicted by frequencies arbitrarily close to zero.

**Lemma 2.4 (continuity).** For every fixed $N\geq1$, the function $F_N:\mathbb R\to\mathbb C$ is continuous.

**Proof sketch.** For each $n$, the map $\omega\mapsto2\pi i\omega T(n)/n$ is linear and continuous. The complex exponential is continuous, so their composition is continuous. A finite sum of continuous functions is continuous. $\square$

**Lemma 2.5 (zero-frequency value).** For every $N\geq1$,

$$
F_N(0)=N.
$$

**Proof sketch.** At $\omega=0$, every exponent is zero and every summand is $e^0=1$. Summing $N$ copies of $1$ gives $N$. $\square$

The next bound is immediate but sharp.

**Theorem 2.6 (sharp global upper bound).** For every $N\geq1$ and every $\omega\in\mathbb R$,

$$
|F_N(\omega)|\leq N.
$$

Equality holds at $\omega=0$.

**Proof sketch.** By the triangle inequality and $|e^{it}|=1$ for real $t$,

$$
|F_N(\omega)|
\leq\sum_{n=1}^{N}\left|e^{2\pi i\omega T(n)/n}\right|
=\sum_{n=1}^{N}1=N.
$$

Lemma 2.5 shows that the bound is attained. $\square$

Thus $N$, not $\sqrt N$, is the natural pointwise scale near zero frequency.

## 3. A general topological near-peak principle

The obstruction can be stated without any reference to Collatz arithmetic.

**Theorem 3.1 (irrational point near a continuous peak).** Let $f:\mathbb R\to\mathbb C$ be continuous, let $N\geq0$ be an integer, and suppose $f(0)=N$. For every real $C<N$, there exists an irrational number $\omega$ such that

$$
|f(\omega)|>C.
$$

**Proof sketch.** Since $f$ is continuous, the real-valued function $\omega\mapsto|f(\omega)|$ is continuous. At zero it has value $|f(0)|=N>C$. The inverse image of the open interval $(C,\infty)$ is therefore an open neighborhood of zero. It contains some interval $(-\delta,\delta)$ with $\delta>0$. Irrational numbers are dense in $\mathbb R$, so this interval contains an irrational $\omega$. For that point, $|f(\omega)|>C$. $\square$

The theorem does not require zero to be a local maximum. It needs only a value above the proposed threshold. Density transfers the strict inequality to an irrational point.

A useful equivalent form quantifies closeness to the peak.

**Corollary 3.2 (arbitrarily close irrational approach).** Under the hypotheses of Theorem 3.1, for every $\varepsilon>0$ there exists an irrational $\omega$ such that

$$
|f(\omega)|>N-\varepsilon.
$$

**Proof sketch.** Apply Theorem 3.1 with $C=N-\varepsilon$, which is strictly less than $N$. $\square$

This statement concerns values, not necessarily convergence along a particular prescribed sequence. Nevertheless, one can construct a sequence by taking $\varepsilon=1/m$ and choosing an irrational $\omega_m$ inside a sufficiently small neighborhood of zero. Then $\omega_m\to0$ can be ensured and $|f(\omega_m)|\to N$.

The theorem also clarifies a conceptual error. The complement of the rationals is dense, but it is not bounded away from any rational resonance. A condition quantified over all irrational frequencies includes points arbitrarily close to every rational frequency. Continuity therefore propagates any rational peak into irrational near-peaks.

## 4. Failure of the proposed Collatz spectral gap

Applying the general principle to $F_N$ gives the principal results.

**Theorem 4.1 (irrational Collatz frequencies approach the peak).** Let $N\geq1$. For every $\varepsilon>0$, there exists an irrational $\omega$ such that

$$
|F_N(\omega)|>N-\varepsilon.
$$

**Proof sketch.** Lemma 2.4 gives continuity and Lemma 2.5 gives $F_N(0)=N$. Apply Corollary 3.2. $\square$

Together with Theorem 2.6, this determines the supremum over irrational frequencies.

**Corollary 4.2 (irrational supremum).** For every $N\geq1$,

$$
\sup_{\omega\in\mathbb R\setminus\mathbb Q}|F_N(\omega)|=N.
$$

**Proof sketch.** The upper bound is Theorem 2.6. Theorem 4.1 gives irrational values greater than $N-\varepsilon$ for every positive $\varepsilon$, so no smaller number is an upper bound. $\square$

The square-root threshold is now immediately ruled out.

**Theorem 4.3 (no uniform sub-square-root irrational-frequency bound).** Let $N>1$ be an integer and let $C<\sqrt N$. Then there exists an irrational $\omega$ such that

$$
|F_N(\omega)|>C.
$$

**Proof sketch.** Since $N>1$, one has $\sqrt N<N$. Hence $C<N$. Apply Theorem 3.1 to $f=F_N$. $\square$

**Theorem 4.4 (impossibility of the proposed global gap).** For every integer $N>1$, there does not exist a real $C<\sqrt N$ such that $|F_N(\omega)|<C$ for all irrational $\omega$.

**Proof sketch.** If such a $C$ existed, Theorem 4.3 would provide an irrational $\omega$ with $|F_N(\omega)|>C$, contradicting the asserted upper bound. $\square$

The conclusion is stronger than merely rejecting a particular numerical value of $C$. Every threshold below $N$ fails on irrational frequencies. The scale $\sqrt N$ is therefore impossible under this global quantifier.

No statement above proves or disproves the Collatz conjecture. The argument does not examine forward iteration, cycles, or stopping times. It evaluates a proposed finite one-step statistic and shows that one requested property of that statistic is incompatible with continuity.

## 5. Universality beyond the Collatz map

The obstruction applies to every finite unit-amplitude phase sum.

**Definition 5.1 (finite phase sum).** Given $N\geq1$ and any phase function $\phi:\{0,\ldots,N-1\}\to\mathbb R$, define

$$
S_{N,\phi}(\omega)=\sum_{k=0}^{N-1}e^{i\omega\phi(k)}.
$$

**Theorem 5.2 (universal absence of a global irrational gap).** For every real phase function $\phi$ and every $C<N$, there exists an irrational $\omega$ such that

$$
|S_{N,\phi}(\omega)|>C.
$$

**Proof sketch.** The sum is continuous as a finite sum of continuous exponentials. At zero, $S_{N,\phi}(0)=N$, independently of $\phi$. Theorem 3.1 applies. $\square$

**Corollary 5.3.** The failure of the proposed Collatz bound cannot distinguish the map $3n+1$ from variants such as $5n+1$ or $7n+1$, because every corresponding finite one-step sum has the same zero-frequency value and the same continuity-forced irrational near-peaks.

**Proof sketch.** For any chosen odd multiplier, the associated transform is a finite sum of $N$ unit complex exponentials, all equal to $1$ at zero frequency. Theorem 5.2 therefore applies without using the value of the multiplier. $\square$

This universality is diagnostically important. If a proposed statistic behaves identically near zero for all maps in a comparison class, then near-zero behavior cannot explain differences among their orbit structures. Arithmetic discrimination must occur either away from the universal resonance, after subtracting a coherent component, under normalization and asymptotic passage, or in a different orbit-sensitive observable.

## 6. Exact parity decomposition

The Collatz ratio has a particularly simple form:

$$
\frac{T(n)}{n}=
\begin{cases}
1/2, & n\text{ even},\\
3+1/n, & n\text{ odd}.
\end{cases}
$$

Let

$$
E_N=\#\{1\leq n\leq N:n\text{ even}\}=\left\lfloor\frac N2\right\rfloor.
$$

**Proposition 6.1 (even–odd decomposition).** For every $N\geq1$ and $\omega\in\mathbb R$,

$$
F_N(\omega)
=E_Ne^{\pi i\omega}
+e^{6\pi i\omega}
\sum_{\substack{1\leq n\leq N\\ n\text{ odd}}}e^{2\pi i\omega/n}.
$$

**Proof sketch.** Split the defining sum into even and odd $n$. For every even $n$, $T(n)/n=1/2$, so each even summand is $e^{\pi i\omega}$; there are $E_N$ such terms. For odd $n$, $T(n)/n=3+1/n$, and

$$
e^{2\pi i\omega(3+1/n)}=e^{6\pi i\omega}e^{2\pi i\omega/n}.
$$

Factoring out the common term completes the identity. $\square$

The proposition has analytic and computational consequences. Analytically, the even contribution is a coherent vector of magnitude $E_N$. Cancellation in the full sum must therefore involve the odd block counteracting a deterministic component of order $N$. Computationally, one evaluates a single exponential for the entire even block and only about $N/2$ exponentials for the odd block.

For the generalized odd-multiplier map

$$
T_a(n)=
\begin{cases}
n/2, & n\text{ even},\\
an+1, & n\text{ odd},
\end{cases}
$$

with real or integer $a$, the same calculation yields

$$
F_{N,a}(\omega)
=E_Ne^{\pi i\omega}
+e^{2\pi ia\omega}
\sum_{\substack{1\leq n\leq N\\ n\text{ odd}}}e^{2\pi i\omega/n}.
$$

Thus changing $a$ rotates the odd block but does not alter the even block or the zero-frequency peak.

## 7. Numerical algorithms

### 7.1 Direct evaluation

The direct algorithm loops through $n=1,\ldots,N$, computes $T(n)/n$, evaluates the associated complex exponential, and accumulates the sum. It requires $N$ exponential evaluations, $O(N)$ arithmetic operations, and $O(1)$ auxiliary memory.

Numerical summation of many complex numbers can accumulate rounding error. Pairwise summation or compensated summation may improve accuracy for very large $N$, especially where cancellation is strong. Near zero, however, the terms are aligned and ordinary double precision usually displays the peak clearly for moderate cutoffs.

### 7.2 Parity-reduced evaluation

Proposition 6.1 leads to an exact accelerated algorithm. Compute $E_Ne^{\pi i\omega}$ once. Then loop only over odd $n$, accumulating $e^{2\pi i\omega/n}$. Multiply the odd sum by $e^{6\pi i\omega}$ and add the even block. This still has $O(N)$ time complexity and $O(1)$ additional memory, but uses approximately $N/2+2$ exponential evaluations rather than $N$.

### 7.3 Frequency scans

Given a grid $\omega_0,\\ldots,\omega_{M-1}$, evaluate the transform at each point and record the magnitudes. A straightforward scan costs $O(MN)$ time and $O(M)$ output storage. The special phase $1/n$ in the odd block does not form a standard equally spaced discrete Fourier transform, so a direct fast Fourier transform does not apply without approximation or a nonuniform transform method.

A scan can display the resonance profile but cannot establish a statement quantified over all irrational frequencies. In particular, a grid that omits a tiny neighborhood of zero may misleadingly suggest a small global maximum. The analytical near-peak theorem is necessary to control the unsampled continuum.

### 7.4 Deterministic irrational probes

A transparent demonstration uses

$$
\omega_m=\frac{\sqrt2}{m},\qquad m=1,2,3,\ldots.
$$

Every $\omega_m$ is irrational and $\omega_m\to0$. Continuity gives

$$
|F_N(\omega_m)|\longrightarrow N.
$$

These probes do not search for a counterexample; they provide a predetermined irrational sequence approaching the forced peak. Similar sequences may approach any integer resonance.

## 8. Numerical interpretation and comparative experiments

Three numerical experiments are especially informative.

First, for fixed $N$, report $|F_N(\sqrt2/m)|$ for increasing $m$. The values should approach $N$ from below or, more precisely, converge to $N$ without a required monotonicity. This directly visualizes Theorem 4.1.

Second, verify the triangle bound across a frequency grid. Floating-point output should satisfy $|F_N(\omega)|\leq N$ up to a small numerical tolerance. Equality at zero provides a calibration check.

Third, compare $T_3$, $T_5$, and $T_7$. All three transforms equal $N$ at zero and remain near $N$ for sufficiently small irrational frequencies. Their profiles away from resonances may differ, but those differences must not be conflated with orbit convergence. A one-step phase distribution aggregates separate inputs, whereas convergence is a property of repeated application along each orbit.

The numerical evidence should therefore be described as demonstration rather than proof. Its appropriate roles are to reveal shape, test implementations against exact identities, locate candidate off-resonance phenomena, and motivate quantitative conjectures that can subsequently be analyzed.

## 9. Corrected spectral formulations

The failed proposal suggests several mathematically coherent replacements.

### 9.1 Excluding resonance neighborhoods

For $\delta>0$, define the off-resonance set

$$
\Omega_\delta=\{\omega\in\mathbb R:\operatorname{dist}(\omega,\mathbb Z)\geq\delta\}.
$$

A meaningful pointwise question is whether the normalized sum satisfies a uniform estimate on compact subsets of $\Omega_\delta$. Removing only rational points is insufficient; removing neighborhoods of resonances addresses the actual continuity obstruction.

### 9.2 Normalization

Define

$$
G_N(\omega)=\frac{F_N(\omega)}{N}.
$$

Then $|G_N(\omega)|\leq1$ and $G_N(0)=1$. One may ask whether, for fixed $\delta>0$ and suitable compact $K\subset\Omega_\delta$,

$$
\sup_{\omega\in K}|G_N(\omega)|\longrightarrow0
$$

as $N\to\infty$. This is an asymptotic cancellation problem and is not settled by the present results.

The exact parity decomposition warns that $G_N$ contains an even block of asymptotic magnitude about $1/2$. Depending on the frequency set, it may be preferable to subtract this deterministic term and study the centered transform

$$
H_N(\omega)=\frac1N\left(F_N(\omega)-E_Ne^{\pi i\omega}\right).
$$

Then

$$
H_N(\omega)=\frac{e^{6\pi i\omega}}{N}
\sum_{\substack{1\leq n\leq N\\ n\text{ odd}}}e^{2\pi i\omega/n}.
$$

Whether this centered statistic exhibits useful cancellation depends on the chosen frequency regime.

### 9.3 Averaged estimates

Instead of a pointwise bound, one may study

$$
\int_I |G_N(\omega)|^2\,d\omega
$$

for a bounded interval $I$, or estimate the measure of the exceptional set

$$
\{\omega\in I:|G_N(\omega)|>\lambda\}.
$$

A narrow peak can violate every global pointwise bound while contributing little to an integral. Averaged estimates are therefore compatible with isolated or shrinking resonance regions.

### 9.4 Orbit-dependent transforms

To connect spectral behavior with stopping times, define a signal from a single orbit. If $x_0=n$ and $x_{j+1}=T(x_j)$, one possible finite orbit transform is

$$
\mathcal O_{n,L}(\omega)=\sum_{j=0}^{L-1}e^{2\pi i\omega\psi(x_j,x_{j+1})},
$$

where $\psi$ is an explicitly chosen observable. Any theorem connecting the width of a spectral feature of $\mathcal O_{n,L}$ with the hitting time of $1$ must specify $L$, $\psi$, normalization, resonance exclusions, and the exact direction of implication. Such a theorem is a new problem, not a consequence of the finite one-step analysis.

## 10. Applications, limitations, and discussion

The principal application is methodological. In spectral studies of discrete dynamics, a zero-frequency check should precede large-scale computation. If a transform contains $N$ unit coefficients and no centering, then its zero mode is automatically $N$. Continuity immediately constrains every dense frequency class, including irrational frequencies, algebraic frequencies, and many other designated subsets.

The universal theorem also supplies a validation test for software. Any numerical implementation of $F_N$ should return $N$ at zero within floating-point tolerance, should obey the triangle bound, and should agree between the direct and parity-reduced formulas. Failure of these checks indicates an indexing, parity, phase, or normalization error.

The results have clear limitations. They do not estimate $F_N$ away from zero, do not determine asymptotic behavior as $N\to\infty$, and do not characterize other resonances. They do not establish a relationship between one-step phase cancellation and Collatz orbit lengths. Most importantly, they neither prove nor disprove that every Collatz orbit reaches $1$.

Calling the rejected condition a “spectral gap” risks confusion with operator theory, where a spectral gap often refers to separation between eigenvalues of a transfer, Markov, or Koopman operator. The present object is a scalar finite exponential sum. Operator-based Collatz models may still support meaningful spectral questions, but their state spaces, operators, measures, and spectral notions must be specified independently.

The corrected viewpoint is therefore layered. The universal coherent mode should be identified and removed or avoided. The remaining statistic should be normalized. The frequency domain should be separated quantitatively from resonance. Finally, any claimed dynamical consequence should be proved through an explicit bridge from the statistic to orbit behavior.

## 11. Future directions

Several directions follow naturally.

1. Replace the impossible global condition over all irrational frequencies by a condition excluding a fixed neighborhood of integer resonances. Continuity forces values near the zero-frequency peak to remain near the cutoff $N$.

2. Study normalized transforms $F_N(\omega)/N$ on compact frequency sets bounded away from integers, and seek quantitative cancellation estimates uniform in $N$.

3. Separate the even and odd summands. For the phase $T(n)/n$, the even branch contributes the constant ratio $1/2$, while the odd branch has ratio $3+1/n$; this explicit decomposition may support sharper asymptotic estimates.

4. Formulate averaged statements, such as $L^2$ bounds over a period or bounds outside an exceptional set of small measure. Such claims are compatible with isolated resonant peaks in a way that a pointwise bound over all irrationals is not.

5. Compare corrected normalized or averaged statistics for the $3n+1$, $5n+1$, and $7n+1$ maps. Any useful discriminator must depend on more than continuity near frequency zero.

6. Investigate orbit-dependent transforms separately from the one-step cutoff sum. A rigorous implication between an orbit hitting-time estimate and a spectral estimate requires precise definitions and directional proofs; it should not be treated as an automatic equivalence.

## 12. Conclusion

For the finite Collatz exponential sum, the zero-frequency identity $F_N(0)=N$, continuity, and density of irrational numbers completely rule out a uniform bound below $\sqrt N$ at all irrational frequencies when $N>1$. More strongly, irrational frequencies attain values arbitrarily close to the sharp global maximum $N$. The same conclusion holds for every finite unit-amplitude phase sum, regardless of its arithmetic origin.

The obstruction is elementary, but it materially changes the research program. Irrationality alone does not remove resonance. A viable spectral theory must exclude resonance neighborhoods, normalize or center the transform, consider averaged behavior, or use an explicitly orbit-dependent observable. These corrections separate universal Fourier geometry from the unresolved dynamics of the Collatz map and provide a sound basis for future numerical and analytical investigation.
