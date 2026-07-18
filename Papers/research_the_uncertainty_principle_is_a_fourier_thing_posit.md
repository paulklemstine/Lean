# Analytic Continuation as a General Mechanism for Transform Uncertainty

**Aristotle**  
**July 18, 2026**

## Abstract

Uncertainty principles are often identified with the variance inequality for quantum position and momentum, but their mathematical source is the duality created by integral transforms. This paper develops a self-contained qualitative theory for transforms whose outputs admit holomorphic continuation. The central result is an identity-principle uncertainty theorem: a holomorphic transform output on a connected complex domain cannot vanish on a nonempty open subset without vanishing identically. For entire outputs, this implies that compact support is impossible for a nonzero function, that the zero set of a nonzero entire function has planar Lebesgue measure zero, and that its support has infinite measure. Positive-measure vanishing and finite-measure support therefore force an entire function to be zero. The framework applies directly to compactly supported Fourier inputs through entire continuation, to Laplace transforms on right half-planes, and to Mellin transforms on vertical strips. Sine, sinc, cosine, and Gaussian examples clarify the sharp distinction between exact support and rapid decay. A Hilbert-space Gram inequality supplies the finite-dimensional quantitative companion. We also identify the precise boundary of the framework: invertibility alone is insufficient, and Radon uncertainty requires geometric range information rather than one-variable holomorphy. Numerical algorithms illustrate concentration tradeoffs without confusing thresholded finite computations with exact support theorems.

## 1. Introduction

The familiar Heisenberg inequality

$$
\Delta x\,\Delta p\geq \frac{\hbar}{2}
$$

expresses a physical relation between position and momentum, but its mathematical architecture is Fourier duality. Momentum is proportional to spatial frequency, and localization of a function competes with localization of its Fourier transform. Similar tradeoffs occur in signal processing, spectroscopy, tomography, sparse approximation, and learned representations.

Uncertainty has several inequivalent meanings. Variance principles compare second moments. Entropic principles compare information measures. Support principles ask whether a function and its transform can both be exactly confined. This paper focuses on a qualitative support mechanism that applies whenever a transformed signal extends holomorphically to a connected complex domain.

The mechanism is the identity principle of complex analysis. A smooth real function may vanish on an interval and be nonzero elsewhere. A holomorphic function cannot: vanishing on any nonempty open part of a connected domain forces global vanishing. Entire functions are even more rigid. Unless identically zero, their zeros are isolated; consequently their zero sets have planar measure zero and their nonzero sets have infinite measure.

These observations lead to a transform-independent principle, but only under appropriate hypotheses. If a transform maps a class of inputs to holomorphic functions on a connected domain, then no nonzero output can contain an open spectral gap. If the transform is injective, an identically zero output implies a zero input. For Fourier transforms of compactly supported integrable functions, the output extends to an entire function, giving a compact-support obstruction. Laplace transforms are holomorphic on half-planes, and Mellin transforms on vertical strips, so the same identity-principle engine applies on their natural domains.

A universal claim based only on invertibility would be false. The identity transform is invertible and preserves compact support. The correct structural ingredients are analytic continuation and, for transferring output vanishing back to the signal, injectivity. The Radon transform demonstrates another boundary: its support theory depends on projection geometry and the Fourier-slice theorem, not simply on holomorphy in one complex variable.

The contributions are as follows:

1. a general identity-principle uncertainty theorem on connected complex domains;
2. compact-support, zero-set, positive-measure, and infinite-support consequences for entire functions;
3. specializations to Fourier, Laplace, and Mellin settings;
4. worked sine, sinc, cosine, and Gaussian examples;
5. a Hilbert-space Gram inequality linking qualitative support rigidity to quantitative concentration;
6. reproducible numerical procedures for observing width tradeoffs and transform-domain leakage.

## 2. Definitions and analytic background

### 2.1 Support and measure

Let $f:X\to\mathbb C$ be a function on a topological space. Its nonzero set is

$$
\operatorname{nz}(f)=\{x\in X:f(x)\neq 0\}.
$$

Its topological support is the closure

$$
\operatorname{supp}_{\mathrm{top}}(f)=\overline{\operatorname{nz}(f)}.
$$

The function has compact support when this closed set is compact. In measure-theoretic claims below, it is convenient to discuss the nonzero set itself. Since adjoining or removing a null boundary does not change measure in common regular cases, the distinction is harmless for examples, but the exact statements will specify the set being measured.

We identify $\mathbb C$ with $\mathbb R^2$ and write $m_2$ for planar Lebesgue measure. A set $E\subseteq\mathbb C$ is null if $m_2(E)=0$, has positive measure if $m_2(E)>0$, and has finite measure if $m_2(E)<\infty$.

### 2.2 Holomorphy and connected domains

A function $F:U\to\mathbb C$ on an open set $U\subseteq\mathbb C$ is holomorphic if it is complex differentiable at every point of $U$. It is entire if $U=\mathbb C$. A domain is a nonempty connected open subset of $\mathbb C$.

The basic engine is the following classical result.

**Lemma 2.1 (Identity principle).** Let $U\subseteq\mathbb C$ be a connected open set, and let $F:U\to\mathbb C$ be holomorphic. If there is a nonempty open set $W\subseteq U$ such that $F(z)=0$ for every $z\in W$, then $F(z)=0$ for every $z\in U$.

**Proof sketch.** Choose $z_0\in W$. Because $F$ is zero in a neighborhood of $z_0$, every derivative of $F$ at $z_0$ is zero, so its local power series is identically zero. More generally, the zeros of a nonzero holomorphic function are isolated. The existence of an open set of zeros is therefore incompatible with nontriviality. Connectedness ensures that the zero germ propagates throughout $U$ by analytic continuation. $\square$

Connectedness is essential. A function may be zero on one connected component and nonzero on another. Openness is used to speak of holomorphy in neighborhoods and to initiate continuation.

### 2.3 Integral transforms and analytic output

An integral transform has the schematic form

$$
(Tf)(s)=\int_X K(s,x)f(x)\,d\mu(x),
$$

where $K$ is a kernel. The relevant condition is not merely that $T$ be invertible. We require that, for the chosen input class, $Tf$ extend to a holomorphic function on a connected complex domain $U$. When $T$ is injective on that input class, $Tf\equiv 0$ implies $f=0$.

This suggests the following terminology.

**Definition 2.2 (Analytic transform class).** A pair $(T,\mathcal A)$ is an analytic transform class on a domain $U$ if every $f\in\mathcal A$ has an output $Tf$ admitting a holomorphic representative on $U$. It is faithful if $T$ is injective on $\mathcal A$.

This definition separates two roles. Holomorphy prohibits open regions of exact zeros in the output. Faithfulness converts global output vanishing into input vanishing.

## 3. Main analytic uncertainty results

### 3.1 The general open-gap theorem

**Theorem 3.1 (Identity-principle uncertainty).** Let $U\subseteq\mathbb C$ be a connected open set and let $F:U\to\mathbb C$ be holomorphic. If $F$ vanishes on a nonempty open subset of $U$, then $F$ vanishes throughout $U$. Consequently, for a faithful analytic transform class $(T,\mathcal A)$ on $U$, no nonzero input $f\in\mathcal A$ can have an output $Tf$ that vanishes on a nonempty open subset of $U$.

**Proof sketch.** The first claim is Lemma 2.1. For the second, open-set vanishing gives $Tf\equiv 0$ on $U$, and injectivity gives $f=0$. $\square$

A common support statement follows immediately. If a subset $K\subset U$ has a complement containing a nonempty open set and $F$ is supported in $K$, then $F$ vanishes on that open complement. Thus a nonzero analytic output cannot be confined to such a $K$.

### 3.2 Compact support for entire functions

**Theorem 3.2 (Compact-support obstruction).** If $F:\mathbb C\to\mathbb C$ is entire and has compact topological support, then $F\equiv 0$.

**Proof sketch.** Let $K=\operatorname{supp}_{\mathrm{top}}(F)$. The complex plane is not compact, so $\mathbb C\setminus K$ is nonempty. It is open because $K$ is closed. By the definition of support, $F$ vanishes on $\mathbb C\setminus K$. The identity principle on the connected domain $\mathbb C$ gives $F\equiv 0$. $\square$

This theorem is qualitative: it distinguishes exact zero from arbitrarily rapid decay. A Gaussian decays faster than any exponential of a linear function along the real axis, yet it does not have compact support.

### 3.3 Nullity of zero sets

**Lemma 3.3 (Isolation of zeros).** Let $F$ be holomorphic on a domain $U$. If $F$ is not identically zero, then every zero of $F$ is isolated.

**Proof sketch.** At a zero $z_0$, expand $F$ into a power series. Since $F$ is not locally zero, there is a least $n$ with nonzero coefficient. Then

$$
F(z)=(z-z_0)^nG(z),
$$

where $G$ is holomorphic and $G(z_0)\neq 0$. Continuity makes $G$ nonzero near $z_0$, leaving $z_0$ as the only zero in a sufficiently small disk. $\square$

**Lemma 3.4 (Countability of a discrete planar set).** Every discrete subset of $\mathbb C$ is countable.

**Proof sketch.** The plane has a countable base consisting, for example, of disks with rational centers and rational radii. For each point of a discrete set, choose a basis disk containing that point and no other point of the set. Assigning a suitably chosen basis disk to each point gives an injection into a countable family. $\square$

**Theorem 3.5 (Zero-set measure theorem).** If $F:\mathbb C\to\mathbb C$ is a nonzero entire function, then

$$
m_2\bigl(\{z\in\mathbb C:F(z)=0\}\bigr)=0.
$$

**Proof sketch.** By Lemma 3.3, the zero set is discrete. By Lemma 3.4, it is countable. Every singleton has planar Lebesgue measure zero, and countable unions of null sets are null. $\square$

### 3.4 Infinite measure of the nonzero set

**Theorem 3.6 (Infinite-support-measure theorem).** If $F:\mathbb C\to\mathbb C$ is a nonzero entire function, then

$$
m_2\bigl(\{z\in\mathbb C:F(z)\neq 0\}\bigr)=\infty.
$$

**Proof sketch.** The zero set is null by Theorem 3.5. The nonzero set is its complement in $\mathbb C$, up to a disjoint partition. Since $m_2(\mathbb C)=\infty$, removing a null set leaves infinite measure. $\square$

Two useful contrapositives make the uncertainty content explicit.

**Corollary 3.7 (Positive-measure vanishing).** If an entire function vanishes on a subset of $\mathbb C$ having positive planar Lebesgue measure, then it is identically zero.

**Proof sketch.** A nonzero entire function has a null zero set by Theorem 3.5, contradicting positive measure. $\square$

**Corollary 3.8 (Finite-measure nonzero set).** If an entire function has a nonzero set of finite planar Lebesgue measure, then it is identically zero.

**Proof sketch.** A nonzero entire function has a nonzero set of infinite measure by Theorem 3.6. $\square$

These results are stronger than the compact-support obstruction for an entire function: the nonzero set cannot even have finite measure. They should nevertheless not be conflated with the full finite-measure Fourier support theorem for arbitrary real-line signals. Here the entire-output hypothesis is already a strong regularity consequence, typically supplied by compact support of the input.

## 4. Fourier specialization

For $f\in L^1(\mathbb R)$, adopt the Fourier convention

$$
\widehat f(k)=\int_{\mathbb R}f(x)e^{-ikx}\,dx.
$$

If $f$ is supported in $[-R,R]$, define for $z\in\mathbb C$

$$
F(z)=\int_{-R}^{R}f(x)e^{-izx}\,dx.
$$

Differentiation under the integral yields

$$
F^{(n)}(z)=\int_{-R}^{R}(-ix)^n f(x)e^{-izx}\,dx.
$$

On compact subsets of the $z$-plane the integrands admit an integrable uniform bound because $|x|\leq R$. Hence $F$ is entire and restricts to $\widehat f$ on the real axis. This is the elementary analytic-continuation direction of Paley–Wiener theory.

**Theorem 4.1 (Fourier compact-support uncertainty).** Let $f\in L^1(\mathbb R)$ have compact support. If the entire continuation $F$ of $\widehat f$ has compact support in $\mathbb C$, or if its nonzero set has finite planar measure, then $F\equiv 0$. By injectivity of the Fourier transform on $L^1(\mathbb R)$, $f=0$ almost everywhere.

**Proof sketch.** Entire continuation follows from the compact support of $f$. Apply Theorem 3.2 in the compact case or Corollary 3.8 in the finite-measure case. Fourier injectivity returns the conclusion to the input. $\square$

A real-axis spectral gap also suffices by a related identity argument: if the entire continuation vanishes on an interval of real frequencies, those zeros have an accumulation point in the complex domain, forcing global vanishing. This is stronger than merely saying the continuation cannot vanish on a two-dimensional open patch.

### 4.1 Box and sinc

Let

$$
f(x)=\mathbf 1_{[-1,1]}(x).
$$

Then

$$
\widehat f(k)=\int_{-1}^{1}e^{-ikx}\,dx=
\begin{cases}
2\dfrac{\sin k}{k},&k\neq 0,\\
2,&k=0.
\end{cases}
$$

The apparent singularity at zero is removable. The complex sine function is entire and nonzero as a function because $\sin(\pi/2)=1$. Its zeros are isolated multiples of $\pi$, hence null. The sinc transform therefore has an unbounded tail and is nonzero almost everywhere on the real axis. Hard localization of the box creates global spectral reach.

The complex cosine is likewise entire and nonzero because $\cos 0=1$. Its zeros are isolated and its nonzero set has infinite planar measure. Sine and cosine thus provide elementary models of analytic outputs with sparse zero sets but extensive support.

### 4.2 Gaussian

For $a>0$, set

$$
f_a(x)=e^{-a x^2}.
$$

Under the stated Fourier convention,

$$
\widehat f_a(k)=\sqrt{\frac{\pi}{a}}\,e^{-k^2/(4a)}.
$$

Both functions have full real support but rapid decay. Their complex continuations are entire. Moreover,

$$
e^{-z^2}\neq 0
$$

for every $z\in\mathbb C$, because the exponential function has no zeros. Thus its nonzero set and topological support are all of $\mathbb C$.

After $L^2$ normalization and a unitary Fourier convention, Gaussian width obeys reciprocal scaling: narrowing in position broadens in frequency. Gaussians attain equality in the variance uncertainty relation. They demonstrate that optimal concentration means balanced tails, not simultaneous compact support.

## 5. Laplace half-plane uncertainty

For suitable $f:[0,\infty)\to\mathbb C$, the Laplace transform is

$$
\mathcal Lf(s)=\int_0^\infty f(t)e^{-st}\,dt.
$$

If, for example, $f\in L^1([0,\infty))$, the integral defines a holomorphic function on the right half-plane

$$
H_0=\{s\in\mathbb C:\operatorname{Re}s>0\}.
$$

More general exponential growth assumptions shift the boundary. Every half-plane $H_c=\{s:\operatorname{Re}s>c\}$ is convex and therefore connected.

**Theorem 5.1 (Laplace open-gap uncertainty).** Let $F$ be holomorphic on $H_c$. If there is a nonempty open set $W\subseteq H_c$ on which $F=0$, then $F=0$ throughout $H_c$. If $F=\mathcal Lf$ in an input class where the Laplace transform is injective, then $f=0$ almost everywhere.

**Proof sketch.** Convexity gives connectedness of $H_c$. Apply Theorem 3.1, then injectivity. $\square$

The theorem does not say that a Laplace transform is compactly supported in an ordinary real-frequency sense, because its natural variable occupies a half-plane and its behavior depends on both decay and oscillation. It says precisely that an analytic Laplace-domain output cannot possess a nonempty open region of exact silence unless it is globally silent.

A numerical example uses $f(t)=e^{-t}\mathbf 1_{[0,\infty)}(t)$, for which

$$
\mathcal Lf(s)=\frac{1}{s+1},\qquad \operatorname{Re}s>-1.
$$

This function decays as $|s|$ grows but never vanishes in its domain. Truncating the time integral introduces numerical and truncation error, yet sampled values still illustrate the absence of a two-dimensional open zero patch.

## 6. Mellin strip uncertainty

For a function on the positive real axis, define

$$
\mathcal Mf(s)=\int_0^\infty f(x)x^{s-1}\,dx.
$$

Convergence often holds on a vertical strip

$$
S_{a,b}=\{s\in\mathbb C:a<\operatorname{Re}s<b\}.
$$

The strip is the intersection of two half-planes, hence convex and connected.

**Theorem 6.1 (Mellin strip uncertainty).** Let $F$ be holomorphic on $S_{a,b}$. If $F$ vanishes on a nonempty open subset of $S_{a,b}$, then $F$ vanishes throughout the strip. If $F=\mathcal Mf$ in a class on which the Mellin transform is injective, then $f=0$ almost everywhere.

**Proof sketch.** Apply Theorem 3.1 to the connected strip, then use injectivity. $\square$

The Mellin–Fourier relationship explains this result structurally. Substitute $x=e^u$, so $dx=e^u du$. Then

$$
\mathcal Mf(\sigma+i\omega)
=\int_{-\infty}^{\infty}f(e^u)e^{\sigma u}e^{i\omega u}\,du.
$$

For fixed $\sigma$, this is a Fourier transform in $u$ up to the sign convention. Translation in $u$ corresponds to multiplication of $x$ by a scale factor. Thus geometric progressions and multiplicative sparsity become additive structures in logarithmic coordinates.

For the illustrative input $f(x)=e^{-x}$,

$$
\mathcal Mf(s)=\Gamma(s),\qquad \operatorname{Re}s>0.
$$

The gamma function has no zeros. Its magnitude along vertical lines can become very small, but exact support conclusions concern zeros, not thresholded smallness.

## 7. Quantitative Hilbert-space companion

Support rigidity is qualitative. Variance uncertainty and numerical concentration are quantitative. Their elementary finite-dimensional engine is Gram positivity.

**Theorem 7.1 (Signal–probe Gram inequality).** In a real inner-product space, for any vectors $u$ and $v$,

$$
0\leq \lVert u\rVert^2\lVert v\rVert^2-\langle u,v\rangle^2.
$$

Equivalently,

$$
|\langle u,v\rangle|\leq \lVert u\rVert\lVert v\rVert.
$$

**Proof sketch.** If $v=0$, the result is immediate. Otherwise consider

$$
\left\lVert u-\frac{\langle u,v\rangle}{\lVert v\rVert^2}v\right\rVert^2\geq 0.
$$

Expanding and multiplying by $\lVert v\rVert^2$ gives the stated determinant inequality. Equivalently, the $2\times2$ Gram matrix of $u$ and $v$ is positive semidefinite, so its determinant is nonnegative. $\square$

In uncertainty derivations, $u$ may be a centered position-weighted signal and $v$ a centered frequency or derivative probe. Their inner product is constrained by commutation or integration by parts. Gram positivity then converts that constraint into a product lower bound. In discrete signal analysis, the same inequality bounds correlations with dictionary atoms and underlies Bessel-type energy estimates.

Analytic continuation and Gram positivity should not be collapsed into one theorem. The former forbids exact open gaps and finite support under strong regularity. The latter bounds degrees of concentration in finite-dimensional or $L^2$ geometry. They are complementary modules.

## 8. Numerical algorithms

Numerics cannot establish exact support on an infinite domain. Sampling, truncation, and floating-point thresholds always replace exact statements with concentration diagnostics. The following algorithms are therefore illustrations of width reciprocity and analytic leakage.

### 8.1 Fourier width experiment

Sample a normalized Gaussian on a symmetric grid, compute a centered discrete Fourier transform, normalize spectral energy, and estimate standard deviations

$$
\Delta x=\left(\int (x-\mu_x)^2|f(x)|^2dx\right)^{1/2},
$$

$$
\Delta k=\left(\int (k-\mu_k)^2|\widehat f(k)|^2dk\right)^{1/2}.
$$

Repeating over several Gaussian widths shows $\Delta x\propto\sigma$ and $\Delta k\propto\sigma^{-1}$. The product remains approximately constant, with deviations controlled by window truncation and grid resolution.

For a box pulse, threshold the magnitude of the discrete spectrum and report the occupied spectral fraction. This fraction depends on the threshold and window, so it is not a mathematical support. The visible sinc sidelobes nevertheless demonstrate that sharpening an edge spreads spectral content.

With $N$ samples, the fast Fourier transform costs $O(N\log N)$ time and $O(N)$ memory.

### 8.2 Laplace-domain sampling

For sampled $t_j\geq0$, quadrature approximates

$$
F(s)\approx\sum_j f(t_j)e^{-s t_j}w_j
$$

on a grid of complex points $s=\sigma+i\omega$ in a right half-plane. Plotting $\log_{10}|F(s)|$ reveals decay and oscillation. An apparent zero below a tolerance is not exact vanishing. For $f(t)=e^{-t}$, comparison with $1/(s+1)$ provides an error check. A direct computation on $N$ time samples and $M$ complex points costs $O(NM)$ time and $O(M)$ output memory if evaluated in batches.

### 8.3 Mellin-domain sampling

Use logarithmic coordinates $x=e^u$. For fixed $\sigma$,

$$
\mathcal Mf(\sigma+i\omega)
=\int g_\sigma(u)e^{i\omega u}\,du,
\qquad
g_\sigma(u)=f(e^u)e^{\sigma u}.
$$

An FFT over a uniform $u$-grid computes an entire vertical line of Mellin samples in $O(N\log N)$ time. Varying $\sigma$ explores the strip. This algorithm makes scale-frequency duality explicit and avoids poorly resolved quadrature over many orders of magnitude in $x$.

## 9. Applications

### 9.1 Sparse learned representations

Suppose a learned integral transform is injective and all outputs in its model class extend holomorphically to a common connected domain with controlled growth. Theorem 3.1 gives a deterministic uniqueness obstruction: no nonzero code may vanish on an open part of that domain. If outputs are entire, Corollary 3.8 forbids finite-measure nonzero sets. Thus exact sparsity assumptions must be checked against analytic regularity.

The practical replacement is approximate sparsity. Growth bounds combined with propagation-of-smallness inequalities may quantify the minimum leakage outside a selected support. Such results could supplement incoherence and restricted-isometry analyses with analytic certificates.

### 9.2 Time-frequency design

Windowed spectral methods choose between temporal resolution and frequency resolution. Gaussian windows offer optimal variance balance, while compactly supported windows necessarily develop spectral tails. Filter designers can suppress sidelobes but cannot make both impulse response and frequency response exactly compact under the analytic hypotheses.

### 9.3 Scale-equivariant models

Mellin variables encode multiplicative scale as additive log-frequency. A narrow receptive field in logarithmic position necessarily spreads in Mellin frequency. This informs wavelet-like and scale-equivariant architectures, where strip width and growth may become measures of usable scale resolution.

### 9.4 Tomography and the Radon boundary

For a planar function $f$, the Radon transform records line integrals

$$
Rf(\theta,p)=\int_{x\cdot\theta=p}f(x)\,d\ell(x).
$$

The Fourier-slice theorem identifies the one-dimensional Fourier transform in $p$ with the restriction of the two-dimensional Fourier transform of $f$ to the radial line in direction $\theta$. Support uncertainty for Radon data therefore couples spatial support, angular coverage, and slice frequency. The one-variable identity principle alone does not supply a complete strip-support theorem. Geometric range conditions and angular information are indispensable.

## 10. Limitations and scope

First, invertibility is not enough. The identity operator is an immediate counterexample to a universal compact-support prohibition. Second, the entire-function finite-measure theorem does not by itself prove the full Benedicks–Amrein–Berthier theorem for arbitrary finite-measure supports on the real line; the present route assumes entire continuation, commonly derived from compact input support. Third, numerical thresholding cannot verify exact zeros or infinite support. Fourth, holomorphic rigidity is qualitative and can be unstable in finite precision: a function may be extremely small on a region without being zero.

The results are exact within their stated hypotheses. Their value lies partly in exposing which hypotheses do the work. Connectedness prevents separate analytic components. Holomorphy forces continuation. Infinite ambient measure turns a null zero set into an infinite-measure nonzero set. Injectivity transfers transformed vanishing back to the input.

## 11. Future work

A quantitative theory should replace exact vanishing by smallness. Uniform growth bounds for analytic transform outputs may combine with three-circle inequalities, Remez-type estimates, or harmonic measure to lower-bound mass outside measurable sets.

For Mellin transforms, logarithmic coordinates invite fractal uncertainty principles for multiplicatively porous sets. The expected bounds should depend on the number of resolved scales and porosity parameters.

Radon uncertainty requires a separate geometric program using the Fourier-slice theorem, support theorems, and angular sampling. A sharp stability inequality should connect strip width, missing angles, and concentration in offset space.

Learned transforms motivate deterministic uniqueness certificates based on analytic continuation and growth, complementing coherence-based sparse recovery. Finally, quantitative Fourier restrictions along families of Radon slices may connect fractal uncertainty to incidence problems involving tube families.

## 12. Conclusion

The common core of several transform uncertainty principles is analytic continuation. A holomorphic function on a connected domain cannot vanish on an open patch without vanishing globally. A nonzero entire function has only a null set of zeros and therefore an infinite-measure nonzero set. These facts yield compact- and finite-support obstructions for analytic transform outputs, with direct forms for Fourier, Laplace, and Mellin analysis.

The framework also draws a sharp conceptual boundary. Uncertainty is not a consequence of invertibility by itself, and not every transform is governed by the same analytic mechanism. For holomorphic transform classes, the operative pair is analytic rigidity plus injectivity. For Radon data, geometry enters. For quantitative concentration, Hilbert-space Gram positivity enters. Together these perspectives show uncertainty not as a peculiarity of quantum measurement, but as a family of structural limits imposed by representation.