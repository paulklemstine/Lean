# Integer Power Laws for Contour-Integral Winding in Nonvanishing Optical Modes

## Abstract

Complex optical fields carry phase information whose singular sets may form vortex lines, links, and knots. Around a contour that avoids all zeros, the logarithmic derivative gives an analytic measure of phase winding. This paper develops the multiplicative algebra of that contour integral for arbitrary smooth, nowhere-vanishing complex modes. We prove closure under pointwise multiplication, identify the pointwise logarithmic-derivative product identity, and derive additivity of contour-integral winding. We then establish simultaneous smoothness and winding laws for natural powers, show that inversion preserves admissibility and reverses winding, and extend the power law from natural to arbitrary integer exponents. The culmination is a two-mode integer composition theorem: for admissible modes $\gamma$ and $\delta$ and integers $k$ and $\ell$, the winding of $\gamma^k\delta^\ell$ is $kW(\gamma)+\ell W(\delta)$. The arguments isolate the analytic foundation of charge composition without assuming winding quantization or a particular knot geometry. Numerical quadrature procedures and examples demonstrate the laws for helical and amplitude-modulated modes, while the discussion distinguishes local phase charge from the global knot type of a three-dimensional singularity.

## 1. Introduction

A scalar monochromatic optical field is naturally represented by a complex amplitude. Its modulus describes intensity and its argument describes phase. At a zero of the amplitude, phase becomes undefined. In a three-dimensional field, such zeros can trace curves that close into loops, link with one another, or form knots. These phase-singular curves are the dark cores of optical vortices and provide the geometric basis for knotted light.

The local structure surrounding a vortex is measured by phase circulation. If a closed sampling contour avoids the zero set, the complex field restricted to that contour takes values in the punctured complex plane $\mathbb{C}\setminus\{0\}$. Its image may wind around the missing origin. The standard logarithmic-derivative integral records this behavior:

$$
W(\gamma)=\frac{1}{2\pi i}\int_0^{2\pi}
\frac{\gamma'(\theta)}{\gamma(\theta)}\,d\theta.
$$

For a periodic closed loop, a separate quantization theorem identifies this value with an integer degree. Our purpose is different and logically prior: we develop the exact algebraic behavior of the integral under coherent multiplication, inversion, and integer powers. These laws hold directly from smoothness and nonvanishing, independently of a quantization argument.

The main theorem states that two independently powered modes compose linearly at the level of winding:

$$
W(\gamma^k\delta^\ell)=kW(\gamma)+\ell W(\delta),
\qquad k,\ell\in\mathbb{Z}.
$$

The result applies to arbitrary continuously differentiable complex fields along the contour, not only to ideal azimuthal harmonics. It therefore separates a general analytic law from any specific beam-generation model.

The paper proceeds as follows. Section 2 defines admissible optical loops and contour-integral winding. Section 3 establishes closure and additivity under multiplication. Section 4 treats natural powers. Section 5 develops inversion and integer powers. Section 6 proves the two-mode composition theorem. Section 7 gives numerical algorithms, Section 8 presents examples and applications, and Sections 9–10 discuss scope and future directions.

## 2. Analytic setting

### 2.1. Admissible optical loops

Let $I=[0,2\pi]$, and let $\gamma:\mathbb{R}\to\mathbb{C}$ describe the complex field sampled along one azimuthal turn. Working on $\mathbb{R}$ rather than only on $I$ is convenient for differentiation; the integral itself is taken over $I$.

**Definition 2.1 (Smooth nonvanishing optical loop).** A pair $(\gamma,\gamma')$ is called an admissible optical loop if:

1. $\gamma$ is differentiable at every $\theta\in\mathbb{R}$ with derivative $\gamma'(\theta)$;
2. $\gamma(\theta)\neq 0$ for every $\theta\in\mathbb{R}$;
3. $\gamma'$ is continuous on $\mathbb{R}$.

The terminology “loop” reflects the intended optical use, although the algebraic theorems below do not require an explicit endpoint condition $\gamma(0)=\gamma(2\pi)$. When that periodicity condition is imposed, the path is closed in the usual topological sense.

The derivative assumptions imply that $\gamma$ itself is continuous. Since it never vanishes, the quotient $\gamma'/\gamma$ is continuous. Consequently it is integrable on every compact interval.

**Lemma 2.2 (Continuity and integrability of the logarithmic derivative).** If $(\gamma,\gamma')$ is admissible, then the function

$$
L_\gamma(\theta)=\frac{\gamma'(\theta)}{\gamma(\theta)}
$$

is continuous on $\mathbb{R}$ and integrable on every finite interval.

**Proof sketch.** Differentiability implies continuity of $\gamma$, while $\gamma'$ is continuous by assumption. Division is continuous wherever the denominator is nonzero. Thus $L_\gamma$ is continuous, and every continuous complex-valued function is integrable on a compact interval. $\square$

### 2.2. Contour-integral winding

**Definition 2.3 (Normalized contour-integral winding).** For an admissible optical loop $\gamma$, define

$$
W(\gamma)=\frac{1}{2\pi i}
\int_0^{2\pi}L_\gamma(\theta)\,d\theta
=rac{1}{2\pi i}
\int_0^{2\pi}\frac{\gamma'(\theta)}{\gamma(\theta)}\,d\theta.
$$

This normalization makes the pure phase mode $\gamma_m(\theta)=e^{im\theta}$ have winding $m$ for every integer $m$, because $\gamma_m'/\gamma_m=im$.

A caution is important. Definition 2.3 produces a complex number for any admissible path on the interval. To interpret it as a topological degree and conclude that it is integral, one additionally imposes closure and proves a winding quantization theorem. None of the algebraic identities proved below depend on that additional result.

## 3. Multiplicative closure and winding additivity

The decisive observation is that the logarithmic derivative converts a product into a sum.

**Theorem 3.1 (Closure under coherent multiplication).** Let $(\gamma,\gamma')$ and $(\delta,\delta')$ be admissible optical loops. Define

$$
\mu(\theta)=\gamma(\theta)\delta(\theta)
$$

and

$$
\mu'(\theta)=\gamma'(\theta)\delta(\theta)
+\gamma(\theta)\delta'(\theta).
$$

Then $(\mu,\mu')$ is an admissible optical loop.

**Proof sketch.** The ordinary product rule gives the displayed derivative. A product of two nonzero complex numbers is nonzero, so $\mu$ never vanishes. The functions $\gamma$ and $\delta$ are continuous because they are differentiable; therefore both products in the formula for $\mu'$ are continuous, as is their sum. $\square$

**Lemma 3.2 (Pointwise logarithmic-derivative splitting).** Under the assumptions of Theorem 3.1, for every $\theta\in\mathbb{R}$,

$$
\frac{\mu'(\theta)}{\mu(\theta)}
=rac{\gamma'(\theta)}{\gamma(\theta)}
+rac{\delta'(\theta)}{\delta(\theta)}.
$$

**Proof sketch.** Substitute the product-rule expression for $\mu'$ and divide by $\gamma\delta$. Because both factors are nonzero, ordinary field algebra gives

$$
\frac{\gamma'\delta+\gamma\delta'}{\gamma\delta}
=rac{\gamma'}{\gamma}+\frac{\delta'}{\delta}.
$$

The identity is pointwise and requires no integration. $\square$

**Theorem 3.3 (Winding Product Theorem).** If $\gamma$ and $\delta$ are admissible optical loops, then

$$
W(\gamma\delta)=W(\gamma)+W(\delta).
$$

**Proof sketch.** By Theorem 3.1, the product is admissible. Lemma 3.2 identifies its logarithmic derivative as the sum of the two component logarithmic derivatives. All three functions are integrable by Lemma 2.2. Linearity of integration therefore yields

$$
\begin{aligned}
W(\gamma\delta)
&=\frac{1}{2\pi i}\int_0^{2\pi}
\left(\frac{\gamma'}{\gamma}+\frac{\delta'}{\delta}\right)d\theta\\
&=W(\gamma)+W(\delta).
\end{aligned}
$$

$\square$

The theorem is analytic charge conservation for coherent multiplication. It is stronger than a calculation for Fourier modes because the factors may have arbitrary smooth amplitude and phase profiles.

## 4. Natural powers

For $n\in\mathbb{N}$, define $\gamma^n$ pointwise. Powering preserves nonvanishing, and the winding scales by $n$.

**Theorem 4.1 (Simultaneous smoothness and winding law for natural powers).** Let $(\gamma,\gamma')$ be admissible. For every $n\in\mathbb{N}$, the field $\gamma^n$ is admissible with continuous derivative

$$
\frac{d}{d\theta}\gamma(\theta)^n
=n\gamma(\theta)^{n-1}\gamma'(\theta),
$$

where the derivative is interpreted as zero when $n=0$. Moreover,

$$
W(\gamma^n)=nW(\gamma).
$$

**Proof sketch.** Proceed by induction on $n$. For $n=0$, $\gamma^0=1$ is constant, is nowhere zero, and has derivative and winding zero. Suppose the claim holds for $n$. Then

$$
\gamma^{n+1}=\gamma^n\gamma.
$$

Theorem 3.1 shows that this product is admissible. The product rule, together with the induction hypothesis, simplifies to

$$
(\gamma^{n+1})'=(n+1)\gamma^n\gamma'.
$$

The Winding Product Theorem gives

$$
W(\gamma^{n+1})=W(\gamma^n)+W(\gamma)
=nW(\gamma)+W(\gamma)
=(n+1)W(\gamma).
$$

Thus smoothness, nonvanishing, the derivative formula, and the winding formula advance together. $\square$

**Corollary 4.2 (Repeated coherent composition).** If $\gamma$ is admissible, the product of $n$ identical copies of $\gamma$ has winding $nW(\gamma)$.

This formulation emphasizes that the power law is repeated additivity rather than a separate phenomenon.

## 5. Inversion and integer powers

Natural powers account only for nonnegative multiplicities. To permit charge reversal, we study pointwise inversion.

**Theorem 5.1 (Closure under inversion).** Let $(\gamma,\gamma')$ be admissible. Then the reciprocal field $\gamma^{-1}$ is admissible, with derivative

$$
(\gamma^{-1})'(\theta)
=-\frac{\gamma'(\theta)}{\gamma(\theta)^2}.
$$

**Proof sketch.** Since $\gamma$ never vanishes, its reciprocal is defined and never zero. The reciprocal rule gives the derivative. The numerator $-\gamma'$ is continuous and the denominator $\gamma^2$ is continuous and nonzero, so their quotient is continuous. $\square$

**Theorem 5.2 (Winding Inversion Theorem).** If $\gamma$ is admissible, then

$$
W(\gamma^{-1})=-W(\gamma).
$$

**Proof sketch.** The product $\gamma^{-1}\gamma$ is identically $1$. By Theorem 3.3,

$$
W(1)=W(\gamma^{-1})+W(\gamma).
$$

The constant field has zero logarithmic derivative and hence zero winding. Rearranging proves the claim. This proof exposes inversion as the group inverse for coherent multiplication. $\square$

For an integer $k$, the pointwise power $\gamma^k$ means the ordinary natural power when $k\geq 0$ and the corresponding natural power of $\gamma^{-1}$ when $k<0$.

**Theorem 5.3 (Integer Power Theorem).** Let $\gamma$ be admissible and let $k\in\mathbb{Z}$. Then $\gamma^k$ is admissible with some continuous derivative, and

$$
W(\gamma^k)=kW(\gamma).
$$

**Proof sketch.** If $k=n\geq 0$, apply Theorem 4.1. If $k=-n$ for $n\in\mathbb{N}$, then $\gamma^k=(\gamma^{-1})^n$. Theorems 5.1 and 4.1 give admissibility, while Theorems 4.1 and 5.2 give

$$
W((\gamma^{-1})^n)
=nW(\gamma^{-1})=-nW(\gamma)=kW(\gamma).
$$

This includes $k=0$, for which both sides vanish. $\square$

The theorem separates existence from formula: a continuous derivative exists for every integer power, although its convenient closed form depends on the sign of the exponent.

## 6. Integer-weighted two-mode composition

We now combine the preceding results.

**Theorem 6.1 (Two-Mode Integer Composition Theorem).** Let $\gamma$ and $\delta$ be admissible optical loops, and let $k,\ell\in\mathbb{Z}$. Then the field

$$
F(\theta)=\gamma(\theta)^k\delta(\theta)^\ell
$$

is admissible, and its contour-integral winding is

$$
W(F)=kW(\gamma)+\ell W(\delta).
$$

**Proof sketch.** Theorem 5.3 makes both powered factors admissible. Theorem 3.1 then makes their product admissible. Applying Theorem 3.3 and then Theorem 5.3 to each factor yields

$$
\begin{aligned}
W(\gamma^k\delta^\ell)
&=W(\gamma^k)+W(\delta^\ell)\\
&=kW(\gamma)+\ell W(\delta).
\end{aligned}
$$

$\square$

This theorem says that the winding functional is a homomorphism from the multiplicative family generated by admissible modes to the additive complex numbers. Once closure and inversion are available, integer exponents become integer coefficients.

**Corollary 6.2 (Cancellation criterion).** Under the assumptions of Theorem 6.1, if

$$
kW(\gamma)+\ell W(\delta)=0,
$$

then the composite field $\gamma^k\delta^\ell$ has zero contour-integral winding.

Zero winding does not imply that the field is constant, nor does it by itself rule out intricate amplitude and phase variation. It states only that the net logarithmic circulation on the contour cancels.

**Corollary 6.3 (Helical charge synthesis).** If

$$
\gamma_p(\theta)=e^{ip\theta},\qquad
\delta_q(\theta)=e^{iq\theta},
$$

for integers $p$ and $q$, then

$$
W(\gamma_p^k\delta_q^\ell)=kp+\ell q.
$$

**Proof sketch.** Direct differentiation gives $W(\gamma_p)=p$ and $W(\delta_q)=q$. Substitute these values into Theorem 6.1. $\square$

## 7. Structural viewpoint

The preceding theorems can be summarized as a homomorphism principle. Consider all admissible fields under pointwise multiplication. The constant field $1$ acts as an identity, Theorem 3.1 supplies closure, and Theorem 5.1 supplies inverses. Associativity comes from multiplication in $\mathbb{C}$. Thus admissible fields form an abelian group. Contour-integral winding maps this multiplicative group to the additive group of complex numbers, and Theorem 3.3 says precisely that this map is a group homomorphism.

This viewpoint explains why the later formulas are inevitable once product additivity has been established. In any group homomorphism $H$ from a multiplicative group to an additive group,

$$
H(x^k)=kH(x)
$$

for every integer $k$. Natural powers arise by repeated multiplication; the zeroth power maps to zero because it is the identity; and negative powers map to negatives because they use group inverses. The analytic work lies in proving that the fields and integrals satisfy the hypotheses needed to realize this abstract pattern.

The kernel of the winding map consists of admissible fields with zero contour-integral winding. It is closed under multiplication and inversion. Consequently, multiplying any mode by a zero-winding factor leaves its winding unchanged. This offers a broad class of charge-preserving deformations at the algebraic level: amplitude modulations and phase fluctuations may be inserted whenever their net logarithmic circulation vanishes. Conversely, the image of the winding map records all charge values available from the chosen family of fields. For two generators, Theorem 6.1 describes their integer span.

This group-theoretic interpretation does not add topological assumptions. In particular, without closure of the path and a quantization theorem, the image need not yet be identified with $\mathbb{Z}$. It simply clarifies the structure already encoded by the contour integral.

## 8. Numerical algorithms

The theorems are exact, but sampled optical data require numerical estimators. Two complementary procedures are useful.

### 8.1. Logarithmic-derivative quadrature

Given callable functions for $\gamma$ and $\gamma'$, choose a uniform mesh

$$
\theta_j=\frac{2\pi j}{N},\qquad j=0,\ldots,N-1.
$$

Evaluate $r_j=\gamma'(\theta_j)/\gamma(\theta_j)$ and apply the periodic trapezoidal rule:

$$
\widehat W_N(\gamma)=rac{1}{2\pi i}
\frac{2\pi}{N}
\sum_{j=0}^{N-1}r_j.
$$

For a smooth periodic integrand, convergence is typically rapid. The dominant work is $N$ field evaluations, so time complexity is $O(N)$ and auxiliary memory can be $O(1)$ in a streaming implementation. A safety threshold should reject samples for which $|\gamma(\theta_j)|$ is too small, because division near a zero is ill-conditioned and may indicate that the contour intersects a singularity.

### 8.2. Unwrapped-phase estimator

If derivatives are unavailable, sample $\gamma(\theta_j)$, compute principal phases, unwrap successive jumps by multiples of $2\pi$, and divide the total phase change by $2\pi$. For a closed, adequately sampled loop,

$$
\widehat W_N^{\mathrm{phase}}(\gamma)
=\frac{\widetilde\phi(2\pi)-\widetilde\phi(0)}{2\pi}.
$$

This also takes $O(N)$ time and $O(N)$ memory in a simple array implementation. It is intuitive but can fail when phase changes by more than $\pi$ between adjacent samples or when the field approaches zero. Adaptive refinement and minimum-amplitude checks reduce these risks.

### 8.3. Identity-residual testing

For modes $\gamma$ and $\delta$ and integers $k$ and $\ell$, compute

$$
R_N=\widehat W_N(\gamma^k\delta^\ell)
-k\widehat W_N(\gamma)-\ell\widehat W_N(\delta).
$$

The exact theorem predicts $R_N=0$; numerically, $|R_N|$ measures quadrature and floating-point error. This residual test is more informative than rounding each winding independently because it directly probes the composition law.

## 9. Examples and applications

### 9.1. Pure helical modes

Take $\gamma(\theta)=e^{2i\theta}$ and $\delta(\theta)=e^{-3i\theta}$. Their windings are $2$ and $-3$. With $k=4$ and $\ell=-1$,

$$
F(\theta)=\gamma(\theta)^4\delta(\theta)^{-1}
=e^{11i\theta},
$$

and Theorem 6.1 gives

$$
W(F)=4(2)+(-1)(-3)=11.
$$

The example illustrates both charge amplification and reversal through a negative exponent.

### 9.2. Amplitude-modulated modes

Let

$$
\gamma(\theta)=(2+0.3\cos\theta)e^{2i\theta}.
$$

The positive amplitude factor never vanishes. Its logarithmic derivative contributes a real periodic derivative whose integral over one turn is zero, while the helical phase contributes $2i$. Thus $W(\gamma)=2$. The winding law is not restricted to constant-amplitude circles in the complex plane.

More generally, if $a(\theta)>0$ is smooth and periodic and

$$
\gamma(\theta)=a(\theta)e^{im\theta},
$$

then

$$
\frac{\gamma'}{\gamma}=rac{a'}{a}+im.
$$

The first term integrates to the net change of $\log a$, which is zero over a period, leaving winding $m$.

### 9.3. Charge cancellation without triviality

Let $W(\gamma)=2$ and $W(\delta)=3$. Choosing $k=3$ and $\ell=-2$ yields

$$
W(\gamma^3\delta^{-2})=3\cdot 2-2\cdot 3=0.
$$

The composite can still possess nonconstant intensity and phase. The result expresses cancellation of net circulation, not disappearance of all optical structure.

### 9.4. Modular design of vortex charge

Suppose two experimentally available modes have charges $p$ and $q$. Integer-powered multiplication generates charges of the form

$$
kp+\ell q.
$$

Elementary number theory then implies that the attainable integer charges are multiples of $\gcd(p,q)$, provided both positive and negative exponents can be implemented at the level of the complex field. Thus the analytic composition theorem supports a simple design principle: select primitive component charges with the desired greatest common divisor, then solve a linear Diophantine equation for the exponents.

This application uses charge values known independently for the component modes. The theorem guarantees how those values compose; it does not prescribe a particular optical device for implementing reciprocal fields.

## 10. Interpretation, limitations, and broader context

### 10.1. Multiplication versus additive interference

The operation studied here is pointwise multiplication. It is sometimes described informally as coherent composition, but it must not be confused with linear superposition by addition. If $\gamma$ and $\delta$ are nonzero, their product is automatically nonzero. Their sum may vanish by destructive interference, creating contour crossings at which the logarithmic derivative is singular. Consequently no analogous unrestricted identity states that $W(\gamma+\delta)$ equals the sum of the component windings.

This distinction explains why the multiplicative setting is algebraically stable. Admissible modes form a multiplicative structure with inverses, and winding respects that structure additively.

### 10.2. Local charge versus global knot type

The contour integral measures the phase behavior around a chosen path. In a three-dimensional optical field, a small meridional contour around a vortex filament records local topological charge. The knot type of the filament, by contrast, depends on how the entire zero curve is embedded in space. Two filaments can carry the same local charge while having different knot types, and a single knotted filament can be examined by many local contours.

Therefore the results provide an algebra of local phase charge, not a classification of knots. Connecting the two requires a parameterized three-dimensional zero set, regularity conditions ensuring it forms curves, and invariants sensitive to global embedding.

### 10.3. What remains for topological classification

For closed smooth loops in $\mathbb{C}\setminus\{0\}$, winding is expected to be integral and invariant under nonvanishing homotopy. Those facts are not assumed in the proofs above. The current theory instead establishes algebraic identities of the normalized contour integral under minimal analytic hypotheses.

A complete classification program would add two central results. First, every closed nonvanishing smooth loop should have integer winding. Second, zero winding should be characterized by the existence of a continuous periodic logarithmic lift $g$ satisfying $\gamma=e^g$. These would identify winding with the fundamental-group coordinate of the punctured complex plane.

### 10.4. Robust numerical use

Although winding is topologically robust for closed loops under nonvanishing deformations, numerical estimators are vulnerable near zeros. If $|\gamma|$ becomes small, the quotient $\gamma'/\gamma$ grows and fixed-grid quadrature can lose accuracy. Similarly, phase unwrapping can miss rapid rotations. Practical computation should report the minimum sampled amplitude, refine the mesh near large logarithmic derivatives, and compare derivative-based and phase-based estimates when possible.

## 11. Future research

Several extensions follow naturally.

1. **Finite multimode composition.** For a finite family $\{\gamma_j\}$ and integer weights $\{k_j\}$, one expects
   $$
   W\!\left(\prod_j\gamma_j^{k_j}\right)
   =\sum_j k_jW(\gamma_j).
   $$
   This follows mathematically by finite induction, but a full treatment should specify empty products, derivative witnesses, and numerical assembly.

2. **Homotopy invariance.** A smooth nonvanishing family $H(s,\theta)$ should have winding independent of $s$ when it forms a homotopy of closed loops. This would connect the analytic laws directly to the topology of $\mathbb{C}\setminus\{0\}$.

3. **Quantization and logarithmic lifts.** Proving integrality for closed loops and characterizing zero winding through a periodic logarithm would complete the classification of contour phase behavior.

4. **Motion of singularities.** Parameterized optical fields can model vortex lines moving through three-dimensional space. Conservation of total local winding should persist under deformations that create no boundary zeros, while collision events can redistribute charge locally.

5. **Knot-sensitive data.** Meridional winding should be combined with longitudinal behavior and explicit torus-knot field models. Such data may distinguish beam families that share the same local charge but differ globally.

## 12. Conclusion

For smooth complex optical modes that do not vanish on a sampling contour, the logarithmic derivative supplies an exact and compositional charge calculus. Multiplication preserves admissibility and adds winding. Natural powers preserve admissibility and multiply winding by a natural number. Inversion preserves admissibility and negates winding. Together these facts yield the integer power law and the two-mode composition formula

$$
W(\gamma^k\delta^\ell)=kW(\gamma)+\ell W(\delta).
$$

The result is general: it does not depend on a pure helical ansatz, constant amplitude, winding quantization, or a chosen knot geometry. It identifies the analytic algebra that underlies the controlled composition of optical phase charge. That algebra is a necessary local component of a broader theory relating complex-field singularities, three-dimensional vortex motion, and the topology of knotted light.