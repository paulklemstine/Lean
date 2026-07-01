# Fourier Analysis on Finite Cyclic Groups: Convolution, Parseval, and the Donoho–Stark Uncertainty Principle

## Abstract

We develop the discrete Fourier transform on the finite cyclic group $\mathbb{Z}/N\mathbb{Z}$ from the viewpoint of the representation theory of abelian groups, and prove its three fundamental structural theorems in fully explicit, self-contained form. First, the **convolution theorem**: the transform intertwines cyclic convolution with pointwise multiplication, $\widehat{f\star g} = \hat f\cdot\hat g$. Second, the **Parseval/Plancherel identity**: the transform is an isometry up to the scaling constant $N$, namely $\sum_k |\hat f(k)|^2 = N\sum_j |f(j)|^2$. Third, the **Donoho–Stark uncertainty principle**: for every nonzero $f$, the sizes of the supports of $f$ and $\hat f$ satisfy $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge N$. A central contribution is a clean *stratification* of the hypotheses: the convolution theorem requires only that characters are multiplicative; Parseval additionally requires character orthogonality; and the uncertainty principle requires neither, resting solely on the facts that characters have modulus one and that the transform is invertible. We isolate the two Hölder-type "mixed" bounds $\|\hat f\|_\infty \le |\operatorname{supp} f|\cdot\|f\|_\infty$ and $\|f\|_\infty \le N^{-1}|\operatorname{supp}\hat f|\cdot\|\hat f\|_\infty$ as the analytic engine of the uncertainty bound, and show that the extremal signals are the subgroup indicators, for which the bound is met with equality. We close with three conjectures extending the results to prime order (an additive strengthening), to a complete equality classification, and to arbitrary finite abelian groups.

**Keywords.** Discrete Fourier transform, cyclic group, additive character, convolution theorem, Parseval identity, Plancherel, uncertainty principle, Donoho–Stark, support, representation theory.

---

## 1. Introduction

Fourier analysis exchanges two descriptions of a signal: a *spatial* (or temporal) description that records the value of the signal at each point, and a *spectral* description that records its content in each pure frequency. On a finite cyclic group these two descriptions are related by a linear isomorphism — the discrete Fourier transform (DFT) — that is at once elementary enough to be written down completely and rich enough to exhibit every phenomenon of harmonic analysis in exact, finite form.

This paper presents the three pillars of that theory. We adopt the perspective that the DFT is the decomposition of a function into the *additive characters* of the group — the one-dimensional unitary representations — and we make explicit exactly which property of characters powers each result. The payoff of this bookkeeping is conceptual: it reveals that the celebrated support uncertainty principle of Donoho and Stark is, at heart, weaker in its hypotheses than the more familiar convolution and Parseval theorems, needing only that characters are unimodular and that inversion holds.

Our exposition is self-contained. All definitions are stated inline, and every theorem is accompanied by a complete proof sketch that a reader can reconstruct from the document alone.

## 2. Setup and definitions

Throughout, fix an integer $N \ge 1$ and work over the finite cyclic group $G = \mathbb{Z}/N\mathbb{Z}$, whose elements are the residues $\{0,1,\dots,N-1\}$ under addition modulo $N$. A **signal** is a function $f\colon \mathbb{Z}/N\mathbb{Z}\to\mathbb{C}$. The set of all signals is an $N$-dimensional complex vector space.

### 2.1 Characters

An **additive character** of $\mathbb{Z}/N\mathbb{Z}$ is a homomorphism $\chi$ from the additive group into the multiplicative group of nonzero complex numbers; equivalently, a function satisfying $\chi(a+b) = \chi(a)\chi(b)$ for all $a,b$. We fix the **standard character**

$$\chi(m) = e^{2\pi i m/N},$$

which is *primitive*, meaning it is nontrivial on every nonzero element. Three properties of $\chi$ will be used, and we name them to track their role:

- **(C1) Unimodularity.** $|\chi(m)| = 1$ for all $m$.
- **(C2) Multiplicativity.** $\chi(a+b) = \chi(a)\chi(b)$; in particular $\chi(0)=1$ and $\chi(-m) = \overline{\chi(m)}$.
- **(C3) Orthogonality.** For each $m$, $\displaystyle\sum_{k=0}^{N-1}\chi(mk) = \begin{cases} N, & m = 0,\\ 0, & m\ne 0.\end{cases}$

Property (C3) follows from primitivity: for $m\ne 0$ the value $\chi(m)$ is a root of unity different from $1$, and the finite geometric series of its powers sums to zero.

### 2.2 The discrete Fourier transform

The **discrete Fourier transform** of a signal $f$ is the signal $\hat f = \mathcal{F}f$ defined by

$$\hat f(k) = \sum_{j=0}^{N-1} f(j)\,\overline{\chi(jk)} = \sum_{j=0}^{N-1} f(j)\,\chi(-jk).$$

It is a linear isomorphism of the space of signals, with **inverse** (Fourier inversion)

$$f(j) = \frac{1}{N}\sum_{k=0}^{N-1} \hat f(k)\,\chi(kj).$$

Inversion is itself a consequence of orthogonality (C3): substituting the definition of $\hat f$ into the right-hand side and interchanging the order of summation collapses the inner sum to $N$ exactly when the summation index matches $j$.

### 2.3 Support and norms

The **support** of $f$ is the finite set of points where it is nonzero,

$$\operatorname{supp} f = \{\, j \in \mathbb{Z}/N\mathbb{Z} : f(j)\ne 0 \,\},$$

and $|\operatorname{supp} f|$ denotes its cardinality. We use three norms:

- the **$L^1$ norm** $\displaystyle \|f\|_1 = \sum_{j} |f(j)|$;
- the **$L^2$ norm** $\displaystyle \|f\|_2 = \Big(\sum_j |f(j)|^2\Big)^{1/2}$;
- the **sup-norm** $\displaystyle \|f\|_\infty = \max_{j}|f(j)|$, the maximum of $|f(j)|$ over the (nonempty) group.

Because $\mathbb{Z}/N\mathbb{Z}$ is finite and nonempty, the maximum defining $\|f\|_\infty$ is attained, and $\|f\|_\infty > 0$ if and only if $f\ne 0$.

## 3. Elementary norm estimates

We begin with the basic inequalities that will drive everything. These are the analytic content of the paper; each is elementary but each is essential.

**Lemma 3.1 (Sup-norm dominates values).** For every signal $f$ and every point $j$, $|f(j)| \le \|f\|_\infty$. Moreover $\|f\|_\infty \ge 0$, with $\|f\|_\infty > 0$ precisely when $f\ne 0$.

*Proof.* The value $|f(j)|$ is one of the finitely many quantities over which the maximum is taken, so it is bounded by that maximum. Nonnegativity follows since each $|f(j)|\ge 0$. If $f\ne 0$ then some $|f(j_0)| > 0$, forcing the maximum to be positive; conversely if $f=0$ all values vanish. $\square$

**Lemma 3.2 ($L^1$ bound on Fourier coefficients).** For every $f$ and every frequency $k$,

$$|\hat f(k)| \le \|f\|_1 = \sum_j |f(j)|.$$

*Proof.* By the triangle inequality, $|\hat f(k)| = \big|\sum_j f(j)\chi(-jk)\big| \le \sum_j |f(j)|\,|\chi(-jk)|$. By unimodularity (C1), $|\chi(-jk)| = 1$, so the right side is $\sum_j |f(j)| = \|f\|_1$. $\square$

**Lemma 3.3 (Dual $L^1$ bound from inversion).** For every $f$ and every point $j$,

$$|f(j)| \le \frac{1}{N}\sum_k |\hat f(k)| = \frac{1}{N}\,\|\hat f\|_1.$$

*Proof.* Apply the inversion formula $f(j) = N^{-1}\sum_k \hat f(k)\chi(kj)$, take absolute values, and use the triangle inequality together with $|\chi(kj)| = 1$ from (C1). $\square$

**Lemma 3.4 ($L^1 \le$ support $\times$ sup-norm).** For every $f$,

$$\|f\|_1 = \sum_j |f(j)| \le |\operatorname{supp} f|\cdot\|f\|_\infty.$$

*Proof.* Only points of the support contribute to the sum, since the summand vanishes off the support. Restricting to $\operatorname{supp} f$ and bounding each of the $|\operatorname{supp} f|$ terms by $\|f\|_\infty$ (Lemma 3.1) gives the claim. $\square$

## 4. The convolution theorem

**Definition 4.1 (Cyclic convolution).** For signals $f, g$, their **convolution** $f\star g$ is

$$(f\star g)(x) = \sum_{y=0}^{N-1} f(y)\,g(x - y),$$

with all arithmetic in $\mathbb{Z}/N\mathbb{Z}$.

**Theorem 4.2 (Convolution theorem).** For all signals $f, g$ and every frequency $k$,

$$\widehat{f\star g}(k) = \hat f(k)\cdot\hat g(k).$$

*Proof sketch.* Expand
$$\widehat{f\star g}(k) = \sum_x \chi(-xk)\sum_y f(y)\,g(x-y) = \sum_y f(y)\sum_x \chi(-xk)\,g(x-y),$$
by interchanging the two finite sums. In the inner sum substitute $z = x - y$; the map $x\mapsto x - y$ is a bijection of $\mathbb{Z}/N\mathbb{Z}$ (translation by $-y$), so
$$\sum_x \chi(-xk)\,g(x-y) = \sum_z \chi\big(-(z+y)k\big)\,g(z) = \chi(-yk)\sum_z \chi(-zk)\,g(z),$$
where the last step uses multiplicativity (C2): $\chi(-(z+y)k) = \chi(-yk)\chi(-zk)$. The remaining $z$-sum is exactly $\hat g(k)$, a constant in $y$, so
$$\widehat{f\star g}(k) = \Big(\sum_y f(y)\chi(-yk)\Big)\hat g(k) = \hat f(k)\,\hat g(k).\qquad\square$$

Note that only multiplicativity (C2) and a change of variables were used; **orthogonality played no role.** This is the algebraic heart of the "DFT as representation theory" picture: the transform diagonalizes the convolution algebra because characters are precisely the algebra homomorphisms.

## 5. Character orthogonality and Parseval's identity

**Lemma 5.1 (Character orthogonality).** For every $m\in\mathbb{Z}/N\mathbb{Z}$,

$$\sum_{k=0}^{N-1}\chi(mk) = \begin{cases} N, & m=0,\\ 0, & m\ne 0.\end{cases}$$

*Proof.* If $m=0$ every term equals $\chi(0)=1$, giving $N$. If $m\ne 0$, then since $\chi$ is primitive, $\chi(m)\ne 1$ is a root of unity; the geometric series $\sum_{k}\chi(m)^k$ over a full period of the cyclic group vanishes. $\square$

**Theorem 5.2 (Parseval / Plancherel identity).** For every signal $f$,

$$\sum_{k=0}^{N-1} |\hat f(k)|^2 = N\sum_{j=0}^{N-1} |f(j)|^2.$$

*Proof sketch.* Write $|\hat f(k)|^2 = \hat f(k)\overline{\hat f(k)}$ and expand each factor by definition:
$$\sum_k |\hat f(k)|^2 = \sum_k \Big(\sum_j f(j)\chi(-jk)\Big)\Big(\sum_l \overline{f(l)}\,\overline{\chi(-lk)}\Big) = \sum_{j}\sum_{l} f(j)\overline{f(l)}\sum_k \chi\big((l-j)k\big),$$
after reordering the (finite) sums and using (C2) to combine the character factors into $\chi((l-j)k)$. By orthogonality (Lemma 5.1) the inner sum over $k$ equals $N$ when $l = j$ and $0$ otherwise, collapsing the double sum to $N\sum_j f(j)\overline{f(j)} = N\sum_j |f(j)|^2$. $\square$

The scaling constant $N$ is forced by this normalization of the transform: testing $f = \delta_0$, the unit impulse at $0$, gives $\hat f \equiv 1$, so $\sum_k |\hat f(k)|^2 = N$ while $\sum_j |f(j)|^2 = 1$. A different normalization of $\mathcal{F}$ would rescale the constant. Observe that Parseval used exactly one ingredient beyond the convolution theorem — orthogonality (C3).

## 6. The uncertainty principle

We now assemble the mixed bounds and derive the support inequality. The remarkable feature is that neither multiplicativity nor orthogonality is needed here — only unimodularity (C1) and Fourier inversion.

**Proposition 6.1 (First mixed bound).** For every $f$,
$$\|\hat f\|_\infty \le |\operatorname{supp} f|\cdot\|f\|_\infty.$$

*Proof.* For any $k$, Lemma 3.2 gives $|\hat f(k)| \le \|f\|_1$, and Lemma 3.4 gives $\|f\|_1 \le |\operatorname{supp} f|\cdot\|f\|_\infty$. Taking the maximum over $k$ yields the claim. $\square$

**Proposition 6.2 (Second mixed bound).** For every $f$,
$$\|f\|_\infty \le \frac{1}{N}\,|\operatorname{supp}\hat f|\cdot\|\hat f\|_\infty.$$

*Proof.* For any $j$, Lemma 3.3 gives $|f(j)| \le N^{-1}\|\hat f\|_1$, and Lemma 3.4 applied to $\hat f$ gives $\|\hat f\|_1 \le |\operatorname{supp}\hat f|\cdot\|\hat f\|_\infty$. Taking the maximum over $j$ yields the claim. $\square$

**Theorem 6.3 (Donoho–Stark uncertainty principle).** For every *nonzero* signal $f\colon\mathbb{Z}/N\mathbb{Z}\to\mathbb{C}$,

$$|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge N.$$

*Proof.* Chain Propositions 6.1 and 6.2:
$$\|\hat f\|_\infty \le |\operatorname{supp} f|\cdot\|f\|_\infty \le |\operatorname{supp} f|\cdot\frac{1}{N}\,|\operatorname{supp}\hat f|\cdot\|\hat f\|_\infty.$$
Since $f\ne 0$, the transform $\hat f$ is also nonzero (the transform is invertible), so $\|\hat f\|_\infty > 0$ by Lemma 3.1. Dividing both ends by $\|\hat f\|_\infty$ gives $1 \le N^{-1}|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f|$, i.e. $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge N$. $\square$

**Corollary 6.4.** Any nonzero signal supported on a single point has a transform whose support is the entire group. More generally, no nonzero signal can have both a support smaller than $\sqrt N$ in time and a support smaller than $\sqrt N$ in frequency.

## 7. Extremal signals and sharpness

The bound of Theorem 6.3 is sharp, and the extremizers are highly structured.

**Definition 7.1.** For a subgroup $H \le \mathbb{Z}/N\mathbb{Z}$, its **indicator** $\mathbf{1}_H$ is the signal that is $1$ on $H$ and $0$ elsewhere. Every subgroup of $\mathbb{Z}/N\mathbb{Z}$ has the form $H_d = \{0, d, 2d, \dots\}$ of order $N/d$ for some divisor $d \mid N$.

**Proposition 7.2 (Subgroup indicators are extremal).** If $H \le \mathbb{Z}/N\mathbb{Z}$ has order $|H|$, then $\widehat{\mathbf{1}_H}$ is a scalar multiple of the indicator of the **annihilator** $H^\perp = \{k : \chi(hk)=1 \text{ for all } h\in H\}$, which has order $N/|H|$. Consequently

$$|\operatorname{supp}\mathbf{1}_H|\cdot|\operatorname{supp}\widehat{\mathbf{1}_H}| = |H|\cdot\frac{N}{|H|} = N,$$

so equality holds in Theorem 6.3.

*Proof sketch.* For $k \in H^\perp$, every term of $\widehat{\mathbf{1}_H}(k) = \sum_{h\in H}\chi(-hk)$ equals $1$, giving $|H|$. For $k \notin H^\perp$, the character $h\mapsto\chi(-hk)$ is a nontrivial character of the finite group $H$, so its sum over $H$ vanishes by orthogonality within $H$. Thus $\widehat{\mathbf{1}_H} = |H|\cdot\mathbf{1}_{H^\perp}$, and $|H^\perp| = N/|H|$ by the subgroup–annihilator duality. $\square$

Because the transform commutes with translation and modulation up to scalars — translating $f$ multiplies $\hat f$ by a character (modulation), and vice versa — any translate-and-modulation of a subgroup indicator is also extremal. This produces equality cases at every divisor pair: the achievable extremal support-size pairs are exactly $\{(d, N/d) : d\mid N\}$. Conjecture 2 in Section 9 asserts these are the *only* extremizers.

## 8. Algorithms

The results above are constructive and translate directly into algorithms.

### 8.1 Direct DFT

Computing $\hat f(k) = \sum_j f(j)\chi(-jk)$ for all $k$ by the definition costs $O(N^2)$ complex operations. This is the reference implementation against which correctness is checked; it requires no assumptions on $N$.

### 8.2 Fast convolution via the convolution theorem

To convolve $f$ and $g$: (1) compute $\hat f$ and $\hat g$; (2) multiply pointwise to obtain $\hat f\cdot\hat g$; (3) apply the inverse transform. By Theorem 4.2 the result is $f\star g$. With a fast $O(N\log N)$ transform this yields $O(N\log N)$ convolution, versus $O(N^2)$ for the direct double sum — the basis of fast polynomial and integer multiplication.

### 8.3 Support-product verification

Given $f$, compute $\hat f$, count nonzero entries (above a numerical tolerance) in each, and verify $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge N$. This is an $O(N^2)$ (or $O(N\log N)$ with a fast transform) empirical check of Theorem 6.3, and, on subgroup indicators, of the equality case.

## 9. Discussion and future directions

The organizing insight of this development is a *stratification of hypotheses*:

- the **convolution theorem** (Theorem 4.2) needs only that characters multiply (C2);
- the **Parseval identity** (Theorem 5.2) additionally needs orthogonality (C3);
- the **uncertainty principle** (Theorem 6.3) needs neither — only unimodularity (C1) and invertibility.

Since (C1), (C2), (C3), and inversion hold verbatim for the character theory of *any* finite abelian group (via Pontryagin duality), the entire development transfers with no essential change, which motivates the conjectures below.

**Conjecture 1 (Prime-order additive strengthening).** For a prime $p$ and nonzero $f$ on $\mathbb{Z}/p\mathbb{Z}$,
$$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \ge p + 1,$$
strictly stronger than the multiplicative bound in this setting. The mechanism is a Chebotarëv-type nonvanishing: over a field of prime order, every minor of the Fourier (Vandermonde) matrix at roots of unity is nonzero, so no nonzero signal can be simultaneously sparse in both domains. Prime order is the natural first milestone because the only subgroups are trivial, so the multiplicative equality cases disappear and the additive bound should become provable from determinantal nonvanishing.

**Conjecture 2 (Equality classification on general $\mathbb{Z}/N\mathbb{Z}$).** Equality $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| = N$ holds if and only if $f$ is, up to a nonzero scalar, a translate and modulation of a subgroup indicator; hence the achievable equality sizes are exactly $\{(d, N/d) : d\mid N\}$. The mechanism: the two mixed bounds (Propositions 6.1–6.2) are simultaneously tight only when $f$ is flat on its support and $\hat f$ is flat on its support, and the only functions flat in both domains are the subgroup indicators dictated by the divisor lattice.

**Conjecture 3 (General finite abelian groups).** For every finite abelian group $G$ and nonzero $f\colon G\to\mathbb{C}$, $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge |G|$, with equality exactly for translated, modulated subgroup indicators, the transform taken with respect to the Pontryagin dual. The argument depends on $G$ only through the three structural facts (C1)–(C3) and inversion, all of which hold for the dual pairing on any finite abelian group.

## 10. Conclusion

On the finite cyclic group $\mathbb{Z}/N\mathbb{Z}$, the discrete Fourier transform is simultaneously an isomorphism, an algebra homomorphism from convolution to multiplication, an isometry up to scale, and a rigid constraint on joint support. By tracking which property of characters powers each theorem — multiplicativity for convolution, orthogonality for Parseval, unimodularity and inversion for uncertainty — we obtain a transparent account in which the Donoho–Stark principle emerges from the humblest hypotheses of all. The finite setting sacrifices nothing: every statement is exact, every constant is forced, and the extremal cases are explicitly the subgroup indicators governed by the divisor lattice of $N$.

---

### References (background)

- L. Auslander and R. Tolimieri, "Is computing with the finite Fourier transform pure or applied mathematics?", *Bulletin of the AMS*.
- D. L. Donoho and P. B. Stark, "Uncertainty principles and signal recovery", *SIAM Journal on Applied Mathematics*.
- T. Tao, "An uncertainty principle for cyclic groups of prime order", *Mathematical Research Letters*.
- A. Terras, *Fourier Analysis on Finite Groups and Applications*, Cambridge University Press.
