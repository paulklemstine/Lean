# Logarithmic Lifts, Quantized Winding, and the Topological Charge of Orbital-Angular-Momentum Beams

**Aristotle**  
**15 July 2026**

## Abstract

We develop a self-contained analytic account of topological charge for complex optical fields sampled around a closed azimuthal contour. For a smooth non-vanishing loop $\gamma:[0,2\pi]\to\mathbb C\setminus\{0\}$, the charge is the logarithmic-derivative integral

$$
w(\gamma)=\frac{1}{2\pi i}\int_0^{2\pi}\frac{\gamma'(\theta)}{\gamma(\theta)}\,d\theta.
$$

We establish the product law $w(\gamma\delta)=w(\gamma)+w(\delta)$, inversion and constant-scaling laws, integer quantization for closed loops, and realization of every integer by an orbital-angular-momentum phase. We then characterize the kernel exactly: a smooth non-vanishing loop has zero winding if and only if it admits a logarithmic lift that closes after one turn. This gives a sharp dressing theorem: multiplication by an envelope of the form $e^{L(\theta)}$ preserves charge whenever $L$ is smooth and periodic. The full off-axis Laguerre–Gauss-like amplitude therefore carries the charge of its phase. Finally, for the model $(p,q)$ torus beam, the meridional charge is $pq$ and, for coprime positive parameters, equals $\operatorname{lcm}(p,q)$; the trefoil case has charge $6$. Numerical algorithms based on discrete phase increments are presented with resolution and non-vanishing diagnostics.

## 1. Introduction

A complex optical field carries local amplitude and phase. Around an optical vortex, its phase can accumulate an integral multiple of $2\pi$ even though the field returns to the same value after one geometric circuit. The resulting integer is the topological charge. It determines the handedness and multiplicity of the phase twist and underlies the orbital angular momentum label of structured light.

The central mathematical object is not a particular closed-form beam but a loop in the punctured complex plane. The exclusion of $0$ is decisive: phase is undefined at a zero, and a loop can change its winding only by crossing that excluded point. The logarithmic derivative $\gamma'/\gamma$ captures infinitesimal changes of both magnitude and phase, while its integral isolates the global phase defect.

Three structural questions organize the analysis.

1. Why do charges add when non-vanishing fields are multiplied?
2. Which changes of amplitude or polarization leave charge unchanged?
3. What analytic property distinguishes zero charge from nonzero charge?

The answers are respectively the product rule, periodic exponential dressing, and the existence of a closing logarithmic lift. Together they show that robustness is neither an accident of the exponential ansatz nor an unconditional property of amplitude changes. It follows from a precise kernel theorem.

## 2. Analytic setting and definitions

### 2.1 Smooth non-vanishing loops

A **smooth non-vanishing loop** is a continuously differentiable function

$$
\gamma:[0,2\pi]\longrightarrow\mathbb C\setminus\{0\}
$$

satisfying the closure condition $\gamma(2\pi)=\gamma(0)$. It is often convenient to regard $\gamma$ as a smooth function on $\mathbb R$ and impose closure only at the endpoints of the selected turn.

The **logarithmic derivative** is

$$
D_{\log}\gamma(\theta)=\frac{\gamma'(\theta)}{\gamma(\theta)}.
$$

Non-vanishing guarantees that this quotient is defined and continuous. The **winding number** or **topological charge** of $\gamma$ is

$$
w(\gamma)=\frac{1}{2\pi i}\int_0^{2\pi}D_{\log}\gamma(\theta)\,d\theta.
$$

Although the formula is complex-valued a priori, closure forces it to be an integer embedded in $\mathbb C$.

### 2.2 Orbital-angular-momentum phases and amplitudes

For $\ell\in\mathbb Z$, define the elementary orbital-angular-momentum phase

$$
\Phi_\ell(\theta)=e^{i\ell\theta}.
$$

A Laguerre–Gauss-like radial model is

$$
A_\ell(r,\theta)=r^{|\ell|}\Phi_\ell(\theta),
$$

where $r\geq 0$. If $\ell\neq 0$, then $A_\ell(0,\theta)=0$, whereas $A_\ell(r,\theta)\neq 0$ for every $r>0$. Thus the axis is the singular core and any positive-radius circle is an admissible contour.

### 2.3 Periodic logarithmic lifts

A **periodic logarithmic lift** of a non-vanishing loop $\gamma$ is a differentiable function $L:[0,2\pi]\to\mathbb C$ such that

$$
e^{L(\theta)}=\gamma(\theta),
\qquad
L'(\theta)=\frac{\gamma'(\theta)}{\gamma(\theta)},
\qquad
L(2\pi)=L(0).
$$

The first condition says that $L$ is a continuous branch of logarithm along the loop; the second fixes its differential behavior; the third says the logarithm itself, not only its exponential, closes after one turn.

## 3. Algebra of winding

### Theorem 1 (Product law)

Let $\gamma$ and $\delta$ be continuously differentiable, non-vanishing complex loops whose logarithmic derivatives are continuous. Then

$$
w(\gamma\delta)=w(\gamma)+w(\delta).
$$

**Proof sketch.** The ordinary Leibniz rule and non-vanishing give the pointwise identity

$$
\frac{(\gamma\delta)'}{\gamma\delta}
=\frac{\gamma'\delta+\gamma\delta'}{\gamma\delta}
=\frac{\gamma'}{\gamma}+\frac{\delta'}{\delta}.
$$

Integrate over $[0,2\pi]$ and use linearity of the integral. Multiplication by $(2\pi i)^{-1}$ yields the claim. $\square$

### Corollary 2 (Identity, inversion, and powers)

For every admissible loop $\gamma$,

$$
w(1)=0,
\qquad
w(\gamma^{-1})=-w(\gamma),
\qquad
w(\gamma^m)=m\,w(\gamma)
$$

for every $m\in\mathbb Z$.

**Proof sketch.** A constant has derivative zero. Since $\gamma\gamma^{-1}=1$, the product law gives $w(\gamma)+w(\gamma^{-1})=0$. The power formula follows by induction for positive powers, by the identity for $m=0$, and by inversion for negative powers. $\square$

### Corollary 3 (Nonzero constant scaling)

If $c\in\mathbb C\setminus\{0\}$, then

$$
w(c\gamma)=w(\gamma).
$$

**Proof sketch.** The constant loop $c$ has zero logarithmic derivative, so Theorem 1 gives $w(c\gamma)=w(c)+w(\gamma)=w(\gamma)$. Equivalently, $(c\gamma)'/(c\gamma)=\gamma'/\gamma$ pointwise. $\square$

The product law should not be confused with an addition law for fields. Pointwise addition can introduce zeros and alter winding discontinuously. Indeed, $\Phi_1+\Phi_1=2\Phi_1$ still has winding $1$, not $2$. The additive operation in the target corresponds to multiplication in the source.

## 4. Quantization and realization

### Theorem 4 (Charge of an elementary orbital-angular-momentum phase)

For every integer $\ell$,

$$
w(\Phi_\ell)=\ell.
$$

**Proof sketch.** Since $\Phi_\ell'=i\ell\Phi_\ell$ and $\Phi_\ell$ never vanishes,

$$
\frac{\Phi_\ell'}{\Phi_\ell}=i\ell.
$$

Hence

$$
w(\Phi_\ell)=\frac{1}{2\pi i}\int_0^{2\pi}i\ell\,d\theta=\ell.
$$

The endpoint condition follows from $e^{2\pi i\ell}=1$. $\square$

### Theorem 5 (Integer quantization)

For every smooth non-vanishing closed loop $\gamma$, there exists $n\in\mathbb Z$ such that

$$
w(\gamma)=n.
$$

**Proof sketch.** Define

$$
G(\theta)=\int_0^\theta\frac{\gamma'(t)}{\gamma(t)}\,dt.
$$

Differentiating $\gamma(\theta)e^{-G(\theta)}$ shows that it is constant. Closure of $\gamma$ therefore implies $e^{-G(2\pi)}=1$. The kernel of the complex exponential is $2\pi i\mathbb Z$, so $G(2\pi)=2\pi i n$ for some integer $n$. Dividing by $2\pi i$ gives the result. $\square$

### Corollary 6 (Surjectivity)

Every integer is the winding number of a smooth non-vanishing closed loop.

**Proof sketch.** Given $n\in\mathbb Z$, choose $\Phi_n(\theta)=e^{in\theta}$ and apply Theorem 4. $\square$

Thus winding is an integer-valued, surjective homomorphism from multiplicative smooth non-vanishing closed loops to the additive integers.

### Corollary 7 (Finite-family charge conservation)

For charges $\ell_1,\ldots,\ell_N\in\mathbb Z$,

$$
\prod_{j=1}^N\Phi_{\ell_j}(\theta)
=\Phi_{\sum_{j=1}^N\ell_j}(\theta)
$$

and

$$
w\!\left(\prod_{j=1}^N\Phi_{\ell_j}\right)
=\sum_{j=1}^N\ell_j.
$$

**Proof sketch.** Repeatedly use $e^ae^b=e^{a+b}$ and Theorem 1. $\square$

For opposite charges, $\Phi_\ell\Phi_{-\ell}=1$, so the product has zero winding and is everywhere non-vanishing. This is charge annihilation in the multiplicative model.

## 5. The logarithmic-lift kernel theorem

The preceding results suggest that zero winding is equivalent to the absence of a global logarithmic obstruction. We now state and prove that equivalence.

### Lemma 8 (A periodic logarithm has zero winding)

If $\gamma=e^L$, where $L$ is differentiable and $L(2\pi)=L(0)$, then

$$
w(\gamma)=0.
$$

**Proof sketch.** Differentiating gives $\gamma'/\gamma=L'$. Therefore

$$
w(\gamma)=\frac{1}{2\pi i}\int_0^{2\pi}L'(\theta)\,d\theta
=\frac{L(2\pi)-L(0)}{2\pi i}=0.
$$

$\square$

### Lemma 9 (Construction of a closing logarithm from zero winding)

Let $\gamma$ be smooth and non-vanishing. If $w(\gamma)=0$, then

$$
L(\theta)=\log\gamma(0)+\int_0^\theta\frac{\gamma'(t)}{\gamma(t)}\,dt
$$

is a periodic logarithmic lift of $\gamma$, where any logarithm of the nonzero initial value may be chosen.

**Proof sketch.** The fundamental theorem of calculus gives $L'=\gamma'/\gamma$. Consider

$$
R(\theta)=\frac{e^{L(\theta)}}{\gamma(\theta)}.
$$

The quotient rule and the identity $L'=\gamma'/\gamma$ show $R'(\theta)=0$. At $\theta=0$, the integral vanishes and $e^{\log\gamma(0)}=\gamma(0)$, so $R(0)=1$. Hence $R\equiv1$, proving $e^L=\gamma$. Finally,

$$
L(2\pi)-L(0)=\int_0^{2\pi}\frac{\gamma'}{\gamma}\, d\theta
=2\pi i\,w(\gamma)=0.
$$

Thus $L$ closes. $\square$

### Theorem 10 (Logarithmic-lift kernel theorem)

For a smooth non-vanishing loop $\gamma$, the following are equivalent:

1. $w(\gamma)=0$;
2. $\gamma$ admits a periodic logarithmic lift.

**Proof sketch.** Lemma 8 proves the reverse implication and Lemma 9 proves the forward implication. $\square$

This theorem gives an analytic description of the kernel of winding. A loop is topologically trivial with respect to the origin exactly when its logarithm can be chosen continuously and single-valuedly around a complete turn.

## 6. Physical amplitude and dressing

### Theorem 11 (Charge of the full off-axis amplitude)

For $\ell\in\mathbb Z$ and $r>0$,

$$
w\bigl(A_\ell(r,\cdot)\bigr)=\ell.
$$

If $\ell\neq0$, the amplitude vanishes on the axis and is nonzero at every positive radius.

**Proof sketch.** At fixed $r>0$, the radial factor $r^{|\ell|}$ is a nonzero constant. Corollary 3 and Theorem 4 give

$$
w\bigl(r^{|\ell|}\Phi_\ell\bigr)=w(\Phi_\ell)=\ell.
$$

At $r=0$, the factor $0^{|\ell|}$ vanishes when $|\ell|>0$. For $r>0$, both the radial factor and exponential phase are nonzero. $\square$

### Theorem 12 (Periodic exponential dressing)

Let $L$ be differentiable with continuous derivative and $L(2\pi)=L(0)$. Then

$$
w(e^L)=0.
$$

For every smooth non-vanishing loop $\gamma$,

$$
w(e^L\gamma)=w(\gamma).
$$

**Proof sketch.** The first statement is Lemma 8. The second follows from the product law. $\square$

The hypothesis is sharp in its topological content. A non-vanishing envelope need not have zero winding. For instance, $E(\theta)=e^{im\theta}$ is non-vanishing and closed for integer $m$, but its natural logarithmic lift $im\theta$ has endpoint defect $2\pi i m$ and does not close when $m\neq0$. Multiplying by $E$ shifts charge by $m$.

### Example 13 (A nontrivial charge-preserving envelope)

Let

$$
L(\theta)=a\cos\theta+ib\sin\theta
$$

for real $a$ and $b$. Then $L(2\pi)=L(0)$, and the envelope

$$
E(\theta)=e^{a\cos\theta+ib\sin\theta}
$$

varies in both magnitude and phase while satisfying $w(E)=0$. Consequently $w(E\Phi_\ell)=\ell$.

## 7. Torus-beam arithmetic

For integers $p$ and $q$, define the model meridional phase of a $(p,q)$ torus beam by

$$
T_{p,q}(\theta)=e^{ipq\theta}.
$$

### Theorem 14 (Torus-beam charge)

For all integers $p$ and $q$,

$$
w(T_{p,q})=pq.
$$

**Proof sketch.** This is Theorem 4 with $\ell=pq$. $\square$

### Theorem 15 (Coprime torus-beam arithmetic bridge)

Let $p,q\in\mathbb N$ be coprime. Then

$$
w(T_{p,q})=\operatorname{lcm}(p,q).
$$

In particular, for trefoil parameters $(p,q)=(2,3)$,

$$
w(T_{2,3})=6.
$$

**Proof sketch.** Coprimality implies $\gcd(p,q)=1$. The identity

$$
\gcd(p,q)\operatorname{lcm}(p,q)=pq
$$

therefore reduces to $\operatorname{lcm}(p,q)=pq$. Combine this with Theorem 14. $\square$

The scalar identity reflects a familiar topological distinction: coprime torus parameters specify a single knot, while a nontrivial greatest common divisor indicates a multi-component link. The present theorem identifies the coprime meridional charge with an arithmetic invariant; assigning and conserving charge componentwise in the non-coprime case is a natural extension.

## 8. Numerical algorithms

### 8.1 Discrete phase-increment estimator

Let $z_0,z_1,\ldots,z_{N-1}$ be nonzero complex samples in cyclic order, with $z_N=z_0$. Define

$$
\Delta_j=\operatorname{Arg}\left(z_{j+1}\overline{z_j}\right)\in(-\pi,\pi].
$$

The estimator is

$$
\widehat w_N=\frac{1}{2\pi}\sum_{j=0}^{N-1}\Delta_j.
$$

This formula is invariant under positive amplitude scaling at each sample and under a common nonzero constant factor. If every true phase increment between adjacent samples has magnitude strictly less than $\pi$, unwrapping selects the correct branch and the sum recovers the winding. The algorithm requires $O(N)$ time and $O(1)$ auxiliary memory when streamed.

### 8.2 Product-law diagnostic

Given sampled loops $z_j$ and $u_j$, compute three estimates: $\widehat w(z)$, $\widehat w(u)$, and $\widehat w(zu)$. The residual

$$
\varepsilon=\widehat w(zu)-\widehat w(z)-\widehat w(u)
$$

should be near zero when sampling resolves all three loops and no sample approaches zero. A large residual is a useful indicator of branch aliasing, under-resolution, or numerical contamination near a singularity.

### 8.3 Logarithmic endpoint-defect estimator

For a sampled non-vanishing loop, recursively choose unwrapped phase increments $\Delta_j$ and accumulate

$$
D_N=i\sum_{j=0}^{N-1}\Delta_j
$$

along with the telescoping log-magnitude changes. Closure cancels the magnitude contribution, leaving $D_N\approx2\pi i\widehat w_N$. A near-zero endpoint defect indicates a numerically closing logarithmic lift. This computes the kernel criterion without selecting a global principal logarithm.

### 8.4 Stability conditions

No phase algorithm is reliable at a zero. A numerical implementation should report

$$
\rho_{\min}=\min_j|z_j|
$$

and reject or refine data when $\rho_{\min}$ is below a chosen tolerance. It should also monitor the largest phase step. Sampling must be refined whenever an increment approaches $\pi$, because the principal argument then cannot distinguish alternative turns.

## 9. Worked examples

### 9.1 Multiplication and cancellation

Take $\gamma(\theta)=e^{3i\theta}$ and $\delta(\theta)=e^{-i\theta}$. Their individual windings are $3$ and $-1$. Their product is

$$
\gamma(\theta)\delta(\theta)=e^{2i\theta},
$$

so its winding is $2$, exactly the sum of the inputs. If instead $\delta=e^{-3i\theta}$, the product is the constant $1$ and the winding is zero. These examples show both signed additivity and complete cancellation.

For the finite family with charges $4,-2,-2,5$, the product field is

$$
e^{4i\theta}e^{-2i\theta}e^{-2i\theta}e^{5i\theta}=e^{5i\theta},
$$

and therefore has total winding $5$. The intermediate cancellation does not depend on the order of multiplication.

### 9.2 Neutral and charged dressings

Let the base beam be $\Phi_3$. The envelope

$$
E_0(\theta)=\exp\!\left(0.4\cos\theta+0.2i\sin\theta\right)
$$

has a periodic logarithm and hence zero winding. Although $|E_0|$ varies between $e^{-0.4}$ and $e^{0.4}$ and its phase oscillates, $E_0\Phi_3$ has winding $3$.

Now consider

$$
E_{-2}(\theta)=e^{-2i\theta}.
$$

This envelope is smooth, closed, and nowhere zero, but its winding is $-2$. It has no periodic logarithmic lift. Consequently,

$$
w(E_{-2}\Phi_3)=-2+3=1.
$$

The comparison isolates the exact role of the periodic-logarithm condition: non-vanishing alone does not imply neutrality.

### 9.3 A distorted loop with unchanged charge

For $a>0$ and integer $n$, define

$$
\Gamma_{a,n}(\theta)=e^{a\cos\theta}e^{in\theta}.
$$

Its image repeatedly changes distance from the origin, but the positive radial factor has a periodic real logarithm $a\cos\theta$. Therefore $w(\Gamma_{a,n})=n$. This example illustrates that winding is insensitive to substantial radial distortion.

### 9.4 Coprime and non-coprime torus parameters

For $(p,q)=(2,3)$, the model charge is $6$ and $\operatorname{lcm}(2,3)=6$. For $(p,q)=(3,5)$, it is $15=\operatorname{lcm}(3,5)$. By contrast, $(p,q)=(2,4)$ has model charge $8$ while $\operatorname{lcm}(2,4)=4$. Thus the least-common-multiple identification requires coprimality; the unconditional statement is $w(T_{p,q})=pq$.

## 10. Applications

### 10.1 Structured-light communication

Integer charge provides a discrete label for spatial modes. The product law predicts how multiplicative modulation combines labels, while dressing invariance identifies a class of amplitude distortions that preserve them. The non-vanishing condition marks the failure mode: deep fades crossing zero can permit charge changes.

### 10.2 Optical manipulation

Orbital angular momentum can transfer torque to matter. The sign of winding encodes handedness, and the integer magnitude measures phase circulation. Opposite-charge multiplication illustrates a mathematical mechanism for cancellation.

### 10.3 Beam characterization

Discrete winding estimation offers a direct diagnostic from complex-field samples on a contour. Because the estimator uses relative phase increments, constant calibration factors do not affect the answer. Radially sampling several circles can reveal whether all contours enclose the same singularity set.

### 10.4 Knotted and linked singularities

The torus-beam formula links a phase charge to $p$, $q$, and their least common multiple in the coprime case. This suggests a componentwise accounting for torus links governed by the identity $\gcd(p,q)\operatorname{lcm}(p,q)=pq$.

## 11. Discussion

The logarithmic derivative unifies the theory. Algebraically, it changes products into sums. Analytically, its integral is the endpoint difference of a lifted logarithm. Topologically, that endpoint difference records how many times the loop surrounds the excluded origin.

The kernel theorem sharpens common claims about amplitude robustness. Multiplication by a nonzero constant is always harmless. Multiplication by a varying nonzero envelope is harmless exactly when that envelope has zero winding, equivalently, under the smoothness assumptions used here, when it has a periodic logarithmic lift. An envelope that winds is not topologically neutral even if its modulus never vanishes.

Quantization also follows from closure rather than from choosing an integer in advance. The elementary phases realize all integer values, but the integrality theorem applies to arbitrary smooth non-vanishing closed loops. Their images may distort, retrace, and vary greatly in modulus; the winding remains integral.

The present multiplicative theory does not claim additivity under physical field superposition by addition. Additive interference is subtler because zeros may appear. Any extension to parameterized deformations or sums must track singular events explicitly.

## 12. Future work

A first direction is to classify smooth non-vanishing closed loops by the endpoint defect of a logarithmic lift. The defect should be $2\pi i n$, independent of lift, and should classify homotopy classes through non-vanishing loops.

A second direction is a general charge-shift theorem for envelopes. The product law predicts that an arbitrary smooth non-vanishing closed envelope shifts charge by its own winding, with invariance exactly in the periodic-logarithm kernel.

A third direction concerns torus links. For a $(p,q)$ singularity, $\gcd(p,q)$ should count connected components, each carrying meridional charge $\operatorname{lcm}(p,q)$, so total charge decomposes as

$$
\gcd(p,q)\operatorname{lcm}(p,q)=pq.
$$

A fourth direction is charge conservation in continuously parameterized families. Uniform non-vanishing should force constant winding; a jump should require a zero and should equal the signed index of local singular events.

Finally, polarization can be treated through invertible matrix-valued loops. The determinant converts matrix multiplication into scalar multiplication, suggesting that the winding of the determinant is the natural additive polarization charge and that its kernel is characterized by a periodic matrix logarithm under appropriate hypotheses.

## 13. Scope and assumptions

The contour formulation uses a continuously differentiable field and a continuous logarithmic derivative on a full angular turn. These assumptions ensure ordinary integration and differentiation suffice. Piecewise-smooth contours can be treated by splitting the interval at finitely many breakpoints and summing the resulting integrals, provided the field remains nonzero and the endpoint values match.

The observation contour is fixed at positive radius and must not pass through a field zero. Zeros inside the contour are allowed and are precisely what the winding detects collectively. Moving the contour without crossing a zero is expected to preserve winding; crossing a zero changes which singularities are enclosed and may change the integer. The radial amplitude theorem concerns the displayed model $r^{|\ell|}e^{i\ell\theta}$ and fixed $r>0$; it does not assert that every experimentally realized beam has this exact profile.

The torus-beam result concerns the meridional phase model $e^{ipq\theta}$. It establishes its winding and the arithmetic equality under coprimality. It does not by itself derive the complete three-dimensional geometry of an optical torus knot or count components in the non-coprime case. Those componentwise statements belong to the proposed future program.

Likewise, the operation governed by the product theorem is pointwise multiplication. Coherent optical superposition is usually pointwise addition, for which zeros caused by destructive interference must be analyzed. The results therefore give a conservation law for multiplicative composition and dressing, not an unrestricted law for every physical method of combining beams.

Finally, numerical phase unwrapping is a discretization of the invariant rather than a substitute for its hypotheses. A value near an integer is persuasive only when amplitude remains safely away from zero and refinement leaves the estimate stable. Reporting minimum amplitude, maximum phase increment, and convergence under doubled resolution makes the computation auditable.

## 14. Conclusion

The topological charge of an orbital-angular-momentum beam is the winding of its complex field around zero. The contour integral of the logarithmic derivative proves that charge is additive under multiplication, integer-valued on closed loops, and capable of realizing every integer. Its kernel consists exactly of loops with periodic logarithmic lifts. This kernel characterization yields a precise dressing-invariance theorem and confirms that the full off-axis Laguerre–Gauss-like amplitude carries the same charge as its phase. For coprime torus parameters, the meridional charge equals their least common multiple. These results place optical twisting, complex analysis, topology, and elementary arithmetic within one coherent framework.