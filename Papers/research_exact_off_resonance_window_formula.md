# The Exact Off-Resonance Window Formula: Sinc Laws, Sidelobe Sharpness, and their Arithmetic Shadow

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We give a complete, exact analysis of the rectangularly windowed tone
$$W(T,\omega) \;=\; \int_{-T}^{T} e^{i\omega t}\,dt,$$
the fundamental object underlying finite-time frequency measurement. We prove the closed form $W(T,\omega) = 2\sin(\omega T)/\omega$ for $\omega \neq 0$ and $W(T,0)=2T$ at resonance, unified as the *sinc law* $W(T,\omega) = 2T\operatorname{sinc}(\omega T)$, and derive from it the complete quantitative geometry of the response: global peak dominance $|W| \le 2T$; the sidelobe envelope $|W| \le 2/|\omega|$ **together with its sharpness**, equality holding at every half-integer detuning $\omega = (2k+1)\pi/(2T)$; the exact zero set $\omega = k\pi/T$ ($k \neq 0$) with strict positivity throughout the main lobe $0 < \omega T < \pi$; a quadratic main-lobe lower bound $|W| \ge 2T(1 - (\omega T)^2/4)$ for $|\omega T| \le 1$; and a resolution bound stating that half of the peak amplitude is retained only for $|\omega| \le 2/T$.

We then develop the arithmetic counterpart — the exponential (Weyl) sum $S_N(\alpha) = \sum_{n<N} e^{2\pi i n\alpha}$ — proving the Dirichlet-kernel modulus law $|S_N(\alpha)| = |\sin(\pi N\alpha)|/|\sin(\pi\alpha)|$, the classical bound $|S_N(\alpha)| \le 1/(2\|\alpha\|)$, a Jordan main-lobe bound $|S_N(\alpha)| \ge (2/\pi)N$ for $|\alpha| \le 1/(2N)$ with the constant $2/\pi$ shown to be exactly attained in the limit, Weyl cancellation for irrational frequencies, and an arithmetic resonance theorem derived from Dirichlet approximation. An exact **sampling bridge** $C_N(\alpha) = S_N(\alpha)\,C_1(\alpha)$ factors the continuous window through the exponential sum, and the modulus is shown invariant under recentring.

Two applications close the paper. A **sharp Rayleigh criterion** for the rectangular window identifies an exact critical time–bandwidth product $c \in [4.2, 4.4)$ (numerically $c \approx 4.27836$) below which the midpoint of two equal tones is strictly brighter than a tone centre and above which it is strictly darker; the proof rests on a complete sign analysis of $G(x) = \sin x\,(2-\cos x) - x$, whose derivative $G'(x) = 2\cos x\,(1-\cos x)$ makes the monotonicity transparent. A **Fejér identity** rewrites $|S_N(\alpha)|^2$ as a triangularly weighted cosine polynomial, from which we deduce nonnegativity, unit-normalized total mass $N$, and uniform-in-$N$ concentration $|S_N(\alpha)|^2 \le 1/(4\delta^2)$ for $\|\alpha\| \ge \delta$ — the approximate-identity property — and transport it to the continuous window through the sampling bridge.

**Keywords:** sinc kernel, Dirichlet kernel, Fejér kernel, exponential sums, Weyl equidistribution, spectral leakage, Rayleigh criterion, time–bandwidth product.

---

## 1. Introduction

### 1.1 The measurement problem

Finite observation is the universal constraint of frequency measurement. A pure tone of angular frequency $\omega_0$, observed only on a bounded time interval, cannot be distinguished from a tone of frequency $\omega_0 + \varepsilon$ for sufficiently small $\varepsilon$. Quantifying "sufficiently small" is the content of this paper.

The canonical model is a matched-filter correlation. Given a signal and a candidate frequency, one multiplies by the conjugate candidate and integrates over the observation window. If the signal is a pure tone, the result depends only on the *detuning* $\omega$ — the difference between the candidate and the true frequency — and on the window. For the symmetric rectangular window of half-width $T$ this is the **windowed tone**

$$W(T,\omega) \;=\; \int_{-T}^{T} e^{i\omega t}\,dt. \tag{1.1}$$

It is elementary that $W(T,0) = 2T$ and that $|W(T,\omega)| < 2T$ for $\omega \ne 0$, and one occasionally sees this qualitative statement offered as "the resonance theorem". Our thesis is that the qualitative statement is nearly useless in practice, and that the correct object of study is the exact identity, from which every practically relevant quantity — peak width, first-zero location, sidelobe amplitude, resolution threshold — follows by pure computation.

### 1.2 The arithmetic shadow

The same kernel governs a superficially unrelated subject. In analytic number theory one studies the exponential sum

$$S_N(\alpha) \;=\; \sum_{n=0}^{N-1} e^{2\pi i n\alpha}, \tag{1.2}$$

whose behaviour controls equidistribution, Weyl's criterion, the circle method, and the theory of Fourier series. $S_N$ is the sampled version of the same window: one measures at integer times $0, 1, \dots, N-1$ rather than continuously. Its modulus is the Dirichlet kernel, and the two objects are related not by analogy but by an exact factorization (Theorem 5.2 below).

### 1.3 Contributions

1. The exact sinc law and the complete quantitative geometry of the continuous window (§3), including a *sharpness* theorem for the sidelobe envelope that appears not to be commonly recorded in explicit form.
2. The exact arithmetic counterpart (§4), including the exact-attainment of the Jordan constant $2/\pi$.
3. The sampling bridge and recentring invariance (§5).
4. A sharp Rayleigh criterion with an exact critical time–bandwidth product (§6).
5. The Fejér triangular identity with mass and concentration bounds, transported to the continuous setting (§7).

---

## 2. Definitions

Throughout, $T > 0$ denotes a window half-width, $\omega \in \mathbb{R}$ an angular detuning, $\alpha \in \mathbb{R}$ a frequency in cycles per unit time, and $N \in \mathbb{N}$ a sample count.

**Definition 2.1 (Cardinal sine).** The *cardinal sine* is
$$\operatorname{sinc}(x) = \begin{cases} \dfrac{\sin x}{x}, & x \neq 0,\\[2mm] 1, & x = 0.\end{cases}$$

**Definition 2.2 (Windowed tone).** For $T, \omega \in \mathbb{R}$,
$$W(T,\omega) = \int_{-T}^{T} e^{i\omega t}\,dt .$$

**Definition 2.3 (Exponential sum).** For $N \in \mathbb{N}$, $\alpha \in \mathbb{R}$,
$$S_N(\alpha) = \sum_{n=0}^{N-1} e^{2\pi i n\alpha}.$$

**Definition 2.4 (Continuous window in cycle units).** For $b, \alpha \in \mathbb{R}$,
$$C_b(\alpha) = \int_0^b e^{2\pi i \alpha s}\,ds .$$

**Definition 2.5 (Distance to the nearest integer).** $\|\alpha\| = |\alpha - \operatorname{round}(\alpha)|$, so $0 \le \|\alpha\| \le 1/2$.

**Definition 2.6 (Two-tone response).** For a superposition of two equal-amplitude tones separated by $\Delta$ and analysed at detuning $\omega$ through the window of half-width $T$,
$$R_{T,\Delta}(\omega) \;=\; W\!\left(T, \omega - \tfrac{\Delta}{2}\right) + W\!\left(T, \omega + \tfrac{\Delta}{2}\right).$$

**Definition 2.7 (Rayleigh gap function).** $G(x) = \sin x\,(2 - \cos x) - x$.

### Elementary properties of $\operatorname{sinc}$

**Lemma 2.8.** $\operatorname{sinc}$ is even, and $|\operatorname{sinc}(x)| \le 1$ for all $x$.

*Proof sketch.* Evenness is immediate from $\sin(-x) = -\sin x$ (with the value at $0$ matching by definition). For the bound, the case $x = 0$ is trivial; for $x \neq 0$, $|\operatorname{sinc}(x)| = |\sin x|/|x| \le 1$ since $|\sin x| \le |x|$. $\square$

**Lemma 2.9 (Quadratic lower bound).** For $|x| \le 1$,
$$\operatorname{sinc}(x) \;\ge\; 1 - \frac{x^2}{4}.$$

*Proof sketch.* By evenness it suffices to treat $0 < x \le 1$. The refined Maclaurin estimate $\sin x > x - x^3/4$, valid on $(0,1]$, gives $\sin x / x > 1 - x^2/4$; the case $x=0$ is an equality. $\square$

---

## 3. The continuous window: exact law and quantitative geometry

### 3.1 The sinc law

**Theorem 3.1 (Resonance value).** For every $T$, $\;W(T,0) = 2T$.

*Proof.* The integrand is identically $1$, and $\int_{-T}^{T} 1\,dt = 2T$. $\square$

**Theorem 3.2 (Exact off-resonance formula).** For $\omega \neq 0$ and any $T$,
$$W(T,\omega) \;=\; \frac{2\sin(\omega T)}{\omega}.$$
In particular $W(T,\omega)$ is real.

*Proof sketch.* Since $i\omega \neq 0$, the antiderivative of $e^{i\omega t}$ is $e^{i\omega t}/(i\omega)$, so
$$W(T,\omega) = \frac{e^{i\omega T} - e^{-i\omega T}}{i\omega}.$$
Writing $e^{\pm i\omega T} = \cos(\omega T) \pm i\sin(\omega T)$, the cosine terms cancel and the sine terms double:
$$W(T,\omega) = \frac{2i\sin(\omega T)}{i\omega} = \frac{2\sin(\omega T)}{\omega}. \qquad\square$$

**Theorem 3.3 (The sinc law).** For all $T, \omega \in \mathbb{R}$,
$$W(T,\omega) \;=\; 2T\,\operatorname{sinc}(\omega T).$$

*Proof sketch.* If $\omega = 0$ this reads $2T\cdot 1 = 2T$, which is Theorem 3.1. If $T = 0$ both sides vanish. Otherwise $\omega T \neq 0$ and $2T\operatorname{sinc}(\omega T) = 2T\sin(\omega T)/(\omega T) = 2\sin(\omega T)/\omega$, which is Theorem 3.2. $\square$

Theorem 3.3 is the organizing identity of the paper. The apparent case split of Theorems 3.1–3.2 is an artefact of the $0/0$ form; the true statement is a single smooth function of $\omega T$.

**Corollary 3.4 (Reality).** $\operatorname{Im} W(T,\omega) = 0$ for all $T, \omega$. The symmetric rectangular window produces a purely real response.

### 3.2 Peak dominance

**Theorem 3.5 (Peak dominance).** For $T \ge 0$ and all $\omega$,
$$|W(T,\omega)| \;\le\; 2T,$$
with equality at $\omega = 0$.

*Proof sketch.* By Theorem 3.3 and Lemma 2.8, $|W| = 2T\,|\operatorname{sinc}(\omega T)| \le 2T$. $\square$

Thus the peak scales linearly with window length: doubling the observation time doubles the resonant response.

### 3.3 Sidelobes and their sharpness

**Theorem 3.6 (Sidelobe envelope).** For $\omega \neq 0$ and any $T$,
$$|W(T,\omega)| \;\le\; \frac{2}{|\omega|}.$$

*Proof sketch.* By Theorem 3.2, $|W| = 2|\sin(\omega T)|/|\omega| \le 2/|\omega|$ since $|\sin| \le 1$. $\square$

The window length is absent from the bound. This is the mathematical content of *spectral leakage*: a distant interfering tone contaminates the measurement at strength $2/|\omega|$ no matter how long one observes. Increasing $T$ raises the peak but does not lower the far sidelobes; only tapering the window can.

The bound is not merely an envelope — it is attained infinitely often.

**Theorem 3.7 (Sharpness of the sidelobe envelope).** Let $T > 0$ and $k \in \mathbb{Z}$, and set
$$\omega_k = \frac{(2k+1)\pi}{2T}.$$
Then
$$|W(T,\omega_k)| \;=\; \frac{2}{|\omega_k|}.$$

*Proof sketch.* One computes $\omega_k T = k\pi + \pi/2$, whence by the addition formula
$$\sin(\omega_k T) = \sin(k\pi)\cos(\pi/2) + \cos(k\pi)\sin(\pi/2) = \cos(k\pi) = (-1)^k,$$
so $|\sin(\omega_k T)| = 1$. Theorem 3.2 then gives $|W| = 2\cdot 1/|\omega_k|$. $\square$

The detunings $\omega_k$ are exactly the midpoints between consecutive zeros (Theorem 3.8), i.e. the crests of the sidelobes. So the curve $2/|\omega|$ is touched once inside every sidelobe, and no smaller envelope of the form $c/|\omega|$ with $c < 2$ is valid.

### 3.4 The zero set and the main lobe

**Theorem 3.8 (Exact zero set).** Let $T > 0$ and $\omega \neq 0$. Then
$$W(T,\omega) = 0 \iff \exists k \in \mathbb{Z}\setminus\{0\}:\ \omega = \frac{k\pi}{T}.$$

*Proof sketch.* By Theorem 3.2, $W = 0$ iff $\sin(\omega T) = 0$, i.e. iff $\omega T = k\pi$ for some integer $k$; and $k = 0$ is excluded because $\omega \neq 0$ and $T \neq 0$. Conversely $\omega = k\pi/T$ gives $\omega T = k\pi$ and $\sin(k\pi) = 0$. $\square$

**Theorem 3.9 (No zero inside the main lobe).** If $T > 0$, $\omega > 0$, and $\omega T < \pi$, then $W(T,\omega) > 0$.

*Proof sketch.* $\sin$ is strictly positive on $(0,\pi)$, so $\sin(\omega T) > 0$; divide by $\omega > 0$. $\square$

Theorem 3.9 is the statement that Theorem 3.6 alone cannot supply: it certifies that $\pi/T$ is the *first* zero, with the response strictly positive on the entire main lobe. Full-width at first null is therefore exactly $2\pi/T$.

**Theorem 3.10 (Quantitative main lobe).** For $T \ge 0$ and $|\omega T| \le 1$,
$$|W(T,\omega)| \;\ge\; 2T\left(1 - \frac{(\omega T)^2}{4}\right).$$

*Proof sketch.* Combine Theorem 3.3 with Lemma 2.9 applied at $x = \omega T$; note $|x| \le 1$ forces $\operatorname{sinc}(x) \ge 3/4 > 0$, so the modulus equals $2T\operatorname{sinc}(\omega T)$. $\square$

At $|\omega T| = 1$ this guarantees at least $75\%$ of peak; at $|\omega T| = 0.5$, at least $93.75\%$.

**Theorem 3.11 (Resolution bound).** Let $T > 0$. If $|W(T,\omega)| \ge T$ — that is, if the response retains at least half of its peak amplitude $2T$ — then
$$|\omega| \;\le\; \frac{2}{T}.$$

*Proof sketch.* If $\omega = 0$ the conclusion is trivial. Otherwise $T \le |W| \le 2/|\omega|$ by Theorem 3.6, and rearranging gives $|\omega| T \le 2$. $\square$

**Remark 3.12 (Uncertainty).** Theorem 3.11 is the time–frequency uncertainty principle in elementary form: the half-amplitude bandwidth of a rectangular observation of total duration $2T$ is $O(1/T)$. Combined with Theorem 3.10 (which shows the peak is genuinely broad on the scale $1/T$), it brackets the peak width from both sides: the response is near-peak for $|\omega| \lesssim 1/T$ and definitively sub-half-peak for $|\omega| > 2/T$.

---

## 4. The arithmetic shadow: exponential sums

### 4.1 The discrete sinc law

**Theorem 4.1 (Discrete resonance).** For every $N$ and every $k \in \mathbb{Z}$, $\;S_N(k) = N$.

*Proof sketch.* Each summand is $e^{2\pi i n k} = 1$. $\square$

**Lemma 4.2.** For real $\theta$, $\;|e^{i\theta} - 1| = 2\,|\sin(\theta/2)|$.

*Proof sketch.* $e^{i\theta} - 1 = e^{i\theta/2}(e^{i\theta/2} - e^{-i\theta/2}) = 2i\,e^{i\theta/2}\sin(\theta/2)$; take moduli. $\square$

**Theorem 4.3 (Dirichlet-kernel law).** If $\sin(\pi\alpha) \neq 0$ (equivalently $\alpha \notin \mathbb{Z}$) then
$$|S_N(\alpha)| \;=\; \frac{|\sin(\pi N\alpha)|}{|\sin(\pi\alpha)|}.$$

*Proof sketch.* $S_N(\alpha)$ is a geometric series with ratio $q = e^{2\pi i \alpha} \neq 1$, hence
$$S_N(\alpha) = \frac{q^N - 1}{q - 1} = \frac{e^{2\pi i N\alpha} - 1}{e^{2\pi i \alpha} - 1}.$$
Apply Lemma 4.2 to numerator ($\theta = 2\pi N\alpha$) and denominator ($\theta = 2\pi\alpha$); the factors of $2$ cancel. $\square$

Theorem 4.3 is the exact discrete analogue of Theorem 3.2: numerator $\sin(\pi N\alpha)$ mirrors $\sin(\omega T)$, denominator $\sin(\pi\alpha)$ mirrors $\omega$. The denominator's periodicity is the only difference, and it is precisely what makes $S_N$ resonate at *every* integer rather than only at $0$.

**Theorem 4.4 (Discrete sidelobe bound).** For $\alpha \notin \mathbb{Z}$,
$$|S_N(\alpha)| \;\le\; \frac{1}{|\sin(\pi\alpha)|},$$
uniformly in $N$.

### 4.2 Jordan's inequality and the classical bound

**Theorem 4.5 (Jordan's inequality on the circle).** For all $\alpha \in \mathbb{R}$,
$$2\|\alpha\| \;\le\; |\sin(\pi\alpha)|.$$

*Proof sketch.* Both sides are $1$-periodic and even about $0$, so one may assume $0 \le \alpha \le 1/2$, where $\|\alpha\| = \alpha$ and $|\sin(\pi\alpha)| = \sin(\pi\alpha)$. Concavity of $\sin$ on $[0,\pi]$ gives $\sin(\pi\alpha) \ge 2\alpha$ there, with equality at the endpoints. $\square$

**Theorem 4.6 (Classical exponential-sum bound).** If $\|\alpha\| > 0$ then
$$|S_N(\alpha)| \;\le\; \frac{1}{2\|\alpha\|}.$$

*Proof sketch.* Combine Theorems 4.4 and 4.5. $\square$

This is the workhorse bound of analytic number theory. As in the continuous case, the sample count $N$ has disappeared: no amount of extra data suppresses a fixed off-resonance frequency below $1/(2\|\alpha\|)$.

### 4.3 Weyl cancellation

**Theorem 4.7 (Cancellation at fixed non-integer frequency).** If $\alpha \notin \mathbb{Z}$ then
$$\frac{|S_N(\alpha)|}{N} \;\longrightarrow\; 0 \qquad (N \to \infty).$$

*Proof sketch.* By Theorem 4.4 the numerator is bounded by the constant $1/|\sin(\pi\alpha)|$, and dividing a bounded quantity by $N \to \infty$ gives $0$. $\square$

**Theorem 4.8 (Weyl's criterion input).** If $\alpha$ is irrational and $h \in \mathbb{Z}\setminus\{0\}$, then
$$\frac{|S_N(h\alpha)|}{N} \;\longrightarrow\; 0.$$

*Proof sketch.* $h\alpha$ is irrational, hence non-integral, so Theorem 4.7 applies. $\square$

By Weyl's criterion, Theorem 4.8 is exactly the statement that the sequence $(n\alpha)_{n\ge 0}$ is equidistributed modulo $1$ for every irrational $\alpha$. Thus the resolution analysis of a finite observation window, transposed to the integers, becomes the fundamental equidistribution theorem for irrational rotations.

### 4.4 The discrete main lobe and the sharpness of $2/\pi$

**Theorem 4.9 (Jordan main-lobe bound).** For $|\alpha| \le \dfrac{1}{2N}$,
$$|S_N(\alpha)| \;\ge\; \frac{2}{\pi}\,N.$$

*Proof sketch.* On this range $|\pi N \alpha| \le \pi/2$, so by concavity of $\sin$ on $[0,\pi/2]$ (Jordan's inequality in its usual form, $\sin u \ge (2/\pi)u$ for $0 \le u \le \pi/2$) the numerator of Theorem 4.3 satisfies $|\sin(\pi N\alpha)| \ge (2/\pi)\pi N |\alpha| = 2N|\alpha|$, while $|\sin(\pi\alpha)| \le \pi|\alpha|$. Dividing, $|S_N(\alpha)| \ge 2N/\pi$. (The resonance case $\alpha=0$ is Theorem 4.1, where $|S_N| = N > 2N/\pi$.) $\square$

Hence throughout the discrete main lobe the sum retains at least $63.66\%$ of its peak.

**Theorem 4.10 (Exact value at the main-lobe edge).** For $N \ge 1$,
$$\bigl|S_N\bigl(\tfrac{1}{2N}\bigr)\bigr| \;=\; \frac{1}{\sin\bigl(\pi/(2N)\bigr)}.$$

*Proof sketch.* Apply Theorem 4.3 with $\alpha = 1/(2N)$: the numerator is $|\sin(\pi/2)| = 1$. $\square$

**Theorem 4.11 (The constant $2/\pi$ is exactly attained).**
$$\frac{\bigl|S_N\bigl(\tfrac{1}{2N}\bigr)\bigr|}{N} \;\longrightarrow\; \frac{2}{\pi} \qquad (N \to \infty).$$

*Proof sketch.* By Theorem 4.10 the ratio equals $\dfrac{1}{N\sin(\pi/(2N))} = \dfrac{2/\pi}{\operatorname{sinc}(\pi/(2N))}$, and $\pi/(2N) \to 0$ with $\operatorname{sinc}$ continuous and $\operatorname{sinc}(0)=1$. A finite-$N$ form of the same estimate gives the explicit bound $|S_N(1/(2N))| \le (2/\pi)N + 1/N$. $\square$

Theorem 4.11 shows Theorem 4.9 is asymptotically optimal: no constant larger than $2/\pi$ can be used.

**Theorem 4.12 (Discrete resolution bound).** If $N \ge 1$ and $|S_N(\alpha)| \ge N/2$ then $\|\alpha\| \le 1/N$.

*Proof sketch.* By Theorem 4.6, $N/2 \le 1/(2\|\alpha\|)$, i.e. $\|\alpha\| \le 1/N$ (with the degenerate case $\|\alpha\|=0$ trivially satisfying the conclusion). $\square$

This is the exact discrete counterpart of Theorem 3.11.

### 4.5 Arithmetic resonance

**Theorem 4.13 (Periodicity).** $S_N(\alpha + k) = S_N(\alpha)$ for every $k \in \mathbb{Z}$.

**Theorem 4.14 (Arithmetic resonance).** For every real $\alpha$ and every $N \ge 1$ there exists an integer $q$ with $1 \le q \le N$ such that the frequency $q\alpha$ is *resonant at every scale up to about $N/2$*: for all $M$ with $2M \le N+1$,
$$|S_M(q\alpha)| \;\ge\; \frac{2}{\pi}\,M.$$

*Proof sketch.* Dirichlet's approximation theorem supplies $q \le N$ and an integer $p$ with $|q\alpha - p| \le 1/(N+1)$, i.e. $\|q\alpha\| \le 1/(N+1)$. By periodicity (Theorem 4.13) we may replace $q\alpha$ by its representative $\beta$ with $|\beta| = \|q\alpha\| \le 1/(N+1)$. For $2M \le N+1$ this gives $|\beta| \le 1/(2M)$, so Theorem 4.9 applies at sample count $M$. $\square$

Thus *every* real frequency, however irrational, exhibits a genuine resonance after passing to a suitable bounded harmonic — the quantitative engine behind the pigeonhole step in Weyl differencing.

---

## 5. The sampling bridge

The continuous and discrete windows are not merely analogous; they are exactly related.

**Lemma 5.1 (One sampling cell).** For all $c, \alpha \in \mathbb{R}$,
$$\int_c^{c+1} e^{2\pi i \alpha s}\,ds \;=\; e^{2\pi i \alpha c}\,C_1(\alpha).$$

*Proof sketch.* Substitute $s = c + u$; the phase factorizes as $e^{2\pi i\alpha c}e^{2\pi i \alpha u}$ and the constant pulls out of the integral over $u \in [0,1]$. $\square$

**Theorem 5.2 (Sampling bridge / Dirichlet $\times$ sinc factorization).** For every $N \in \mathbb{N}$ and $\alpha \in \mathbb{R}$,
$$C_N(\alpha) \;=\; S_N(\alpha)\cdot C_1(\alpha).$$
In particular $\;|C_N(\alpha)| = |S_N(\alpha)|\cdot|C_1(\alpha)|$.

*Proof sketch.* Split $[0,N]$ into unit cells $[n, n+1]$ for $n = 0, \dots, N-1$ and apply Lemma 5.1 to each, obtaining $C_N(\alpha) = \sum_{n<N} e^{2\pi i \alpha n}\,C_1(\alpha) = S_N(\alpha)C_1(\alpha)$. Formally this is an induction on $N$ with the cell lemma as the inductive step. $\square$

This is the exact form of the engineering slogan "a sampled measurement is a Dirichlet comb times a sinc envelope". The exponential sum contributes the sharp periodic resonance structure (peaks at every integer), and the single cell $C_1(\alpha) = \operatorname{sinc}(\pi\alpha)e^{i\pi\alpha}$ contributes the slowly decaying, non-periodic envelope which selects the $\alpha = 0$ resonance and suppresses its aliases.

**Theorem 5.3 (Exact continuous modulus).** For $\alpha \neq 0$,
$$|C_b(\alpha)| \;=\; \frac{|\sin(\pi\alpha b)|}{\pi|\alpha|}.$$

**Theorem 5.4 (Recentring invariance).** For all $b, \alpha$,
$$|C_b(\alpha)| \;=\; \bigl|W\bigl(\tfrac{b}{2},\ 2\pi\alpha\bigr)\bigr|.$$

*Proof sketch.* Translating the window by $b/2$ multiplies the integral by a unimodular phase $e^{-\pi i \alpha b}$, which the modulus discards; the substitution $\omega = 2\pi\alpha$ converts cycle units into angular units. Directly: both sides equal $|\sin(\pi\alpha b)|/(\pi|\alpha|)$ by Theorems 5.3 and 3.2. $\square$

Thus the sinc law of §3 and the Dirichlet law of §4 are two views of a single object, and any statement about one transports to the other.

---

## 6. A sharp Rayleigh criterion

### 6.1 The two-tone response

**Theorem 6.1 (Sinc form of the two-tone response).**
$$R_{T,\Delta}(\omega) \;=\; 2T\Bigl[\operatorname{sinc}\bigl((\omega - \tfrac{\Delta}{2})T\bigr) + \operatorname{sinc}\bigl((\omega + \tfrac{\Delta}{2})T\bigr)\Bigr].$$

*Proof sketch.* Apply Theorem 3.3 to each summand of Definition 2.6. $\square$

Two special values decide resolvability.

**Theorem 6.2 (Value at a tone centre).** For $\Delta > 0$,
$$R_{T,\Delta}\bigl(\tfrac{\Delta}{2}\bigr) \;=\; \frac{2\Delta T + 2\sin(\Delta T)}{\Delta}.$$

*Proof sketch.* At $\omega = \Delta/2$ the first sinc is $\operatorname{sinc}(0) = 1$ contributing $2T$, and the second is $\operatorname{sinc}(\Delta T)$ contributing $2\sin(\Delta T)/\Delta$. $\square$

**Theorem 6.3 (Value at the midpoint).** For $\Delta > 0$,
$$R_{T,\Delta}(0) \;=\; \frac{8\sin(\Delta T/2)}{\Delta}.$$

*Proof sketch.* At $\omega = 0$ the two arguments are $\mp \Delta T/2$; evenness of $\operatorname{sinc}$ makes them equal, so $R = 4T\operatorname{sinc}(\Delta T/2) = 8\sin(\Delta T/2)/\Delta$. $\square$

**Definition 6.4 (Resolution).** Two tones separated by $\Delta$ are *resolved* by the window of half-width $T$ if $R_{T,\Delta}(0) < R_{T,\Delta}(\Delta/2)$: the midpoint is strictly darker than a tone centre, i.e. there is a genuine dip.

### 6.2 Reduction to a transcendental inequality

Put $x = \Delta T/2$. Then $\Delta T = 2x$ and, using $\sin(2x) = 2\sin x\cos x$, Theorems 6.2–6.3 give
$$R_{T,\Delta}(\Delta/2) = \frac{4x + 4\sin x\cos x}{\Delta},\qquad R_{T,\Delta}(0) = \frac{8\sin x}{\Delta}.$$
Multiplying by $\Delta/4 > 0$, the resolution condition $R(0) < R(\Delta/2)$ becomes
$$2\sin x \;<\; x + \sin x \cos x, \quad\text{i.e.}\quad \sin x\,(2 - \cos x) \;<\; x, \quad\text{i.e.}\quad G(x) < 0. \tag{6.1}$$

So the entire Rayleigh question is the sign of a single one-variable function.

### 6.3 Sign analysis of the gap function

**Lemma 6.5 (Derivative).** $G$ is differentiable with
$$G'(x) \;=\; 2\cos x\,(1 - \cos x).$$

*Proof sketch.* $\frac{d}{dx}[\sin x(2 - \cos x)] = \cos x(2-\cos x) + \sin^2 x = 2\cos x - \cos^2 x + 1 - \cos^2 x = 2\cos x - 2\cos^2 x + 1$. Subtracting $1$ from the derivative of $-x$ gives $2\cos x - 2\cos^2 x = 2\cos x(1 - \cos x)$. $\square$

Since $1 - \cos x \ge 0$ always, the sign of $G'$ is that of $\cos x$. This single observation drives everything.

**Lemma 6.6 (Monotonicity).** $G$ is strictly increasing on $[0, \pi/2]$ and strictly decreasing on $[\pi/2, \pi]$.

*Proof sketch.* On the interior of $[0,\pi/2]$, $\cos x > 0$ and $1 - \cos x > 0$ except at the single point $x=0$; hence $G' > 0$ a.e. and $G$ is strictly monotone. Symmetrically on $[\pi/2,\pi]$ with $\cos x < 0$. $\square$

**Lemma 6.7 (Boundary values).** $G(0) = 0$, $G(\pi/2) = 2 > 0$, and $G(\pi) = -\pi < 0$.

**Theorem 6.8 (Exact critical scale).** There is a unique $x_c$ with $2.1 \le x_c < 2.2$ such that
$$G(x) > 0 \ \text{ for } 0 < x < x_c, \qquad G(x_c) = 0, \qquad G(x) < 0 \ \text{ for } x > x_c.$$

*Proof sketch.* On $(0,\pi/2]$, $G$ is strictly increasing from $G(0)=0$, hence strictly positive. On $[\pi/2,\pi]$, $G$ is strictly decreasing from $G(\pi/2)=2 > 0$ to $G(\pi) = -\pi < 0$, so by the intermediate value theorem it has a unique zero $x_c$ there, positive before and negative after. Numerical evaluation of $G$ at the two rational points $2.1$ and $2.2$ (via certified bounds on $\sin$ and $\cos$ at those arguments) gives $G(2.1) \ge 0 > G(2.2)$, locating $x_c \in [2.1, 2.2)$. Beyond $\pi$ the inequality $G < 0$ persists: for $x \ge \pi$ one has $\sin x (2 - \cos x) \le 3 < \pi \le x$ whenever $\sin x \le 1$ and $2-\cos x\le 3$, which covers $x \ge \pi$ directly; the delicate strip $[2.2,\pi]$ is handled by the strict antitonicity together with $G(2.2)<0$, sharpened by a cubic upper bound for $\cos$ obtained from the half-angle identity $\cos x = 1 - 2\sin^2(x/2)$. $\square$

Numerically $x_c = 2.13918\ldots$

### 6.4 The threshold theorem

**Theorem 6.9 (Sharp Rayleigh criterion).** Let $T > 0$. There is an exact critical time–bandwidth product
$$c = 2x_c \in [4.2,\ 4.4), \qquad c \approx 4.27836,$$
such that for every separation $\Delta > 0$:

- if $\Delta T < c$, then $R_{T,\Delta}(\Delta/2) < R_{T,\Delta}(0)$ — the midpoint is **strictly brighter** than a tone centre, and the pair is unresolved (a single blob with a central *bulge*);
- if $\Delta T > c$, then $R_{T,\Delta}(0) < R_{T,\Delta}(\Delta/2)$ — the midpoint is **strictly darker**, and the pair is resolved.

*Proof sketch.* Set $x = \Delta T/2$, so $\Delta T \lessgtr c \iff x \lessgtr x_c$. By (6.1) the two claims are precisely $G(x) > 0$ and $G(x) < 0$, which is Theorem 6.8. $\square$

**Corollary 6.10 (Two-sided bracket).** For every $T > 0$: no resolution occurs when $\Delta T \le 4.2$, and resolution is strict as soon as $\Delta T \ge 4.4$.

**Theorem 6.11 (Perfect resolution at the first null).** For $T > 0$ and $\Delta = 2\pi/T$ (i.e. $\Delta T = 2\pi$),
$$R_{T,\Delta}(0) = 0 \qquad\text{and}\qquad R_{T,\Delta}(\pi/T) = 2T.$$

*Proof sketch.* At $\Delta T = 2\pi$, $\sin(\Delta T/2) = \sin\pi = 0$, killing the midpoint value by Theorem 6.3. At $\omega = \pi/T = \Delta/2$, the second sinc has argument $\Delta T = 2\pi$ with $\sin(2\pi)=0$, so only the first term $2T$ survives. $\square$

**Remark 6.12.** Theorem 6.11 is the classical "each tone sits on the other's first zero" configuration. Since $2\pi \approx 6.283 > c \approx 4.278$, resolvability sets in strictly earlier than perfect separation: there is a genuine intermediate regime, $4.278 < \Delta T < 6.283$, in which the tones are distinguishable but their sidelobes still interfere.

---

## 7. The Fejér identity: energy, mass, and concentration

Amplitude bounds are the natural language of §§3–6; energy is the natural language of approximation theory. The bridge between them is an exact algebraic identity.

**Theorem 7.1 (Fejér's triangular identity).** For every $N \in \mathbb{N}$ and $\alpha \in \mathbb{R}$,
$$|S_N(\alpha)|^2 \;=\; 2\sum_{d=0}^{N-1} (N - d)\cos(2\pi d\alpha) \;-\; N .$$

*Proof sketch.* Expand $|S_N|^2 = S_N \overline{S_N} = \sum_{m,n<N} e^{2\pi i (m-n)\alpha}$ and group the $N^2$ terms by the lag $d = m-n \in \{-(N-1),\dots,N-1\}$. There are $N - |d|$ pairs with a given lag, and conjugate lags combine into cosines:
$$|S_N|^2 = N + 2\sum_{d=1}^{N-1}(N-d)\cos(2\pi d\alpha).$$
The stated form differs only in that the $d = 0$ term, contributing $2N\cos 0 = 2N$, is included in the sum and compensated by the trailing $-N$. Formally the identity is proved by induction on $N$, the inductive step being the cross-term computation $\operatorname{Re}\bigl(S_N(\alpha)\overline{e^{2\pi i N\alpha}}\bigr) = \sum_{n<N}\cos(2\pi(N-n)\alpha)$ combined with an index reflection. $\square$

**Corollary 7.2 (Fejér positivity).** For all $N, \alpha$,
$$2\sum_{d=0}^{N-1}(N-d)\cos(2\pi d\alpha) - N \;\ge\; 0.$$

*Proof sketch.* It is a squared modulus. $\square$

This is a genuinely non-obvious fact about triangularly weighted cosine polynomials — the analogous statement with constant weights (the Dirichlet kernel) is false, which is exactly why Fejér means converge where Fourier partial sums may not.

Write $K_N(\alpha) = |S_N(\alpha)|^2$ for the (unnormalized) Fejér kernel.

**Theorem 7.3 (Total mass).** $\displaystyle\int_0^1 K_N(\alpha)\,d\alpha = N.$

*Proof sketch.* Integrate the triangular identity term by term. Every harmonic $\cos(2\pi d\alpha)$ with $d \ge 1$ has zero mean over a full period, so only the $d = 0$ term survives, contributing $2N$; subtracting $\int_0^1 N\,d\alpha = N$ leaves $N$. $\square$

**Theorem 7.4 (Uniform concentration).** If $\delta > 0$ and $\|\alpha\| \ge \delta$, then
$$K_N(\alpha) \;\le\; \frac{1}{4\delta^2},$$
uniformly in $N$.

*Proof sketch.* By Theorem 4.6, $|S_N(\alpha)| \le 1/(2\|\alpha\|) \le 1/(2\delta)$; square. $\square$

**Remark 7.5 (Approximate identity).** Theorems 7.3–7.4, with Corollary 7.2, say that $\frac{1}{N}K_N$ is nonnegative, has total mass $1$, and is $O(1/(N\delta^2)) \to 0$ outside any fixed neighbourhood of the integers. That is precisely the approximate-identity property, and it is the analytic engine behind Fejér's theorem: convolution with $\frac{1}{N}K_N$ (i.e. Cesàro averaging of Fourier partial sums) converges uniformly for continuous functions. Its mass $N$ is concentrated in a window of width $\asymp 1/N$ around each integer — the discrete main lobe of §4.4.

**Theorem 7.6 (Transport to the continuous window).** For every $N$ and $\alpha$,
$$|C_N(\alpha)|^2 \;=\; \Bigl(2\sum_{d=0}^{N-1}(N-d)\cos(2\pi d\alpha) - N\Bigr)\cdot |C_1(\alpha)|^2 .$$

*Proof sketch.* Square the modulus in Theorem 5.2 and substitute Theorem 7.1. $\square$

So the energy spectrum of a rectangular observation of length $N$ is exactly a triangularly weighted cosine polynomial times the energy of a single sampling cell — an exact autocorrelation (Wiener–Khinchin) factorization, obtained here without any measure-theoretic machinery.

---

## 8. Algorithmic consequences

The results above translate directly into procedures.

**8.1 Window-length design.** Given a required frequency resolution $\Delta_{\min}$ (in angular units) for two equal tones, Theorem 6.9 gives the exact minimal observation: $2T > 2c/\Delta_{\min}$ with $c \approx 4.27836$, i.e. total observation time $> 8.5567/\Delta_{\min}$. Any shorter observation *provably* fails to produce a dip; any longer one *provably* produces one. Compare the conventional rule "$\Delta T \ge 2\pi$" (Theorem 6.11), which is safe but wastes a factor of $6.283/4.278 \approx 1.47$ in observation time.

**8.2 Leakage budgeting.** Given an interferer at detuning $\omega$ and a required suppression ratio $\rho$ relative to the peak $2T$, Theorems 3.5–3.7 give the exact worst case: $|W(T,\omega)|/(2T) \le 1/(T|\omega|)$, and this is attained. Thus one needs $T|\omega| \ge 1/\rho$, and no window-length increase alone suppresses the interferer below $2/|\omega|$ in absolute terms.

**8.3 Peak localization from a coarse grid.** Theorem 3.11 states that half-peak occurs only for $|\omega| \le 2/T$. Hence sampling the response on a grid of spacing $2/T$ guarantees at least one grid point with response $\ge T$ near a true tone, and Theorem 3.10 then localizes it: from a measured value $v = |W(T,\omega)|$ on the main lobe, $\omega T$ is bracketed by inverting the monotone map $x \mapsto \operatorname{sinc}(x)$ on $[0,\pi]$.

**8.4 Detecting arithmetic resonance.** Theorem 4.14 furnishes a concrete search: given $\alpha$ and a budget $N$, run the continued-fraction expansion of $\alpha$ to obtain a denominator $q \le N$ with $\|q\alpha\| \le 1/(N+1)$; then $|S_M(q\alpha)| \ge (2/\pi)M$ for all $M \le (N+1)/2$. The cost is $O(\log N)$ arithmetic operations, versus $O(N)$ for a naive scan.

---

## 9. Discussion

### 9.1 What the exact formula buys

A qualitative "resonance theorem" — the response is maximal at zero detuning — is a corollary of Theorem 3.5, itself a one-line corollary of the sinc law. But the qualitative statement is strictly weaker than every application in §8. It cannot locate the first zero (Theorem 3.8), cannot certify that the main lobe is zero-free (Theorem 3.9), cannot bound leakage (Theorem 3.6), cannot certify that the leakage bound is tight (Theorem 3.7), and cannot decide two-tone resolvability (Theorem 6.9). The lesson is general: in oscillatory-integral analysis, the exact evaluation, where available, dominates the extremal characterization.

### 9.2 The unity of continuous and discrete

The sampling bridge (Theorem 5.2) is not an approximation theorem. It is an identity, and it explains why the sinc kernel of signal processing and the Dirichlet kernel of Fourier analysis are the same object seen through different sampling. The corollaries mirror one another exactly:

| Continuous | Discrete |
|---|---|
| $W(T,0) = 2T$ | $S_N(k) = N$, $k \in \mathbb{Z}$ |
| $W(T,\omega) = 2\sin(\omega T)/\omega$ | $\vert S_N(\alpha)\vert = \vert\sin(\pi N\alpha)\vert/\vert\sin(\pi\alpha)\vert$ |
| $\vert W\vert \le 2/\vert\omega\vert$ | $\vert S_N\vert \le 1/(2\Vert\alpha\Vert)$ |
| zeros at $\omega = k\pi/T$ | zeros at $\alpha = k/N$, $N \nmid k$ |
| half-peak $\Rightarrow \vert\omega\vert \le 2/T$ | half-peak $\Rightarrow \Vert\alpha\Vert \le 1/N$ |
| main lobe $\ge 2T(1 - (\omega T)^2/4)$ | main lobe $\ge (2/\pi)N$, sharp |

The only structural difference is the periodicity of the discrete denominator, which creates aliases; the continuous cell factor $C_1(\alpha)$ is exactly what suppresses them.

### 9.3 The Rayleigh constant

The critical time–bandwidth product $c \approx 4.27836$ appears to be less widely known than it deserves, largely because optics literature usually adopts the convenient "first-zero" convention $\Delta T = 2\pi$ (Theorem 6.11), which is a *sufficient* but far from *necessary* condition. The exactness here comes from the striking simplicity of $G'(x) = 2\cos x(1-\cos x)$, which reduces a transcendental resolvability question to a single sign change.

### 9.4 Limitations

All results here concern the *rectangular* window. Tapered windows (Hann, Hamming, Kaiser, Gaussian) trade a wider main lobe for dramatically faster sidelobe decay — for the Hann window the envelope decays like $|\omega|^{-3}$ rather than $|\omega|^{-1}$ — and their exact analysis, though similar in spirit, involves different kernels. Second, the analysis is noise-free: it describes the deterministic response of the matched filter, not detection performance in additive noise, where the relevant threshold is set by the signal-to-noise ratio as well as by $\Delta T$.

---

## 10. Future work

1. **Tapered windows.** Establish exact closed forms and sidelobe-sharpness statements for the Hann, Hamming, and Kaiser windows, and compute the analogue of the Rayleigh constant $c$ for each. The Hann case reduces to a sum of three shifted sinc kernels and should be tractable by the same $G$-function method.
2. **Multi-tone resolution.** Extend Theorem 6.9 from two tones to $k$ equal tones on an arithmetic grid; the resolvability condition becomes a sign condition on a $k$-term trigonometric polynomial whose derivative may retain the factorized form of Lemma 6.5.
3. **Unequal amplitudes.** For tones of amplitudes $1$ and $\lambda < 1$ the critical product $c(\lambda)$ becomes a function of the amplitude ratio; determining $c(\lambda)$ and its asymptotics as $\lambda \to 0$ (where the weaker tone is masked entirely by the stronger one's sidelobes) is a natural next question, with direct relevance to dynamic-range specifications.
4. **Higher-dimensional windows.** The sinc kernel becomes a product kernel on rectangles and a Bessel kernel on discs; the disc case is the Airy pattern of optics, and the corresponding exact Rayleigh threshold involves zeros of $J_1$.
5. **Quantitative Weyl differencing.** Theorem 4.14 gives a resonance at every scale up to $N/2$ after passing to a harmonic $q \le N$; iterating this through the van der Corput differencing scheme with explicit constants may yield fully explicit equidistribution rates for polynomial sequences.
6. **Fejér kernels of higher order.** The triangular weights of Theorem 7.1 are the first in a family (Jackson, de la Vallée Poussin) with faster off-resonance decay; the mass–concentration pair of Theorems 7.3–7.4 should generalize with $1/(4\delta^2)$ replaced by $O(\delta^{-2m})$ at order $m$.

---

## Appendix A: Summary of principal results

| Result | Statement |
|---|---|
| Sinc law | $W(T,\omega) = 2T\operatorname{sinc}(\omega T)$; $=2\sin(\omega T)/\omega$ for $\omega\ne0$; $=2T$ at $\omega=0$ |
| Peak dominance | $\vert W(T,\omega)\vert \le 2T$ |
| Sidelobe envelope | $\vert W(T,\omega)\vert \le 2/\vert\omega\vert$, $\omega \ne 0$ |
| Envelope sharpness | equality at $\omega = (2k+1)\pi/(2T)$, all $k \in \mathbb{Z}$ |
| Zero set | $W = 0 \iff \omega = k\pi/T$, $k \ne 0$ |
| Main-lobe positivity | $W > 0$ on $0 < \omega T < \pi$ |
| Main-lobe lower bound | $\vert W\vert \ge 2T(1 - (\omega T)^2/4)$ for $\vert\omega T\vert \le 1$ |
| Resolution bound | $\vert W\vert \ge T \Rightarrow \vert\omega\vert \le 2/T$ |
| Dirichlet law | $\vert S_N(\alpha)\vert = \vert\sin(\pi N\alpha)\vert / \vert\sin(\pi\alpha)\vert$ |
| Classical bound | $\vert S_N(\alpha)\vert \le 1/(2\Vert\alpha\Vert)$ |
| Jordan main lobe | $\vert S_N(\alpha)\vert \ge (2/\pi)N$ for $\vert\alpha\vert \le 1/(2N)$ |
| Sharpness of $2/\pi$ | $\vert S_N(1/(2N))\vert / N \to 2/\pi$ |
| Weyl cancellation | $\vert S_N(h\alpha)\vert/N \to 0$ for irrational $\alpha$, $h \ne 0$ |
| Arithmetic resonance | $\exists q \le N$: $\vert S_M(q\alpha)\vert \ge (2/\pi)M$ for $2M \le N+1$ |
| Sampling bridge | $C_N(\alpha) = S_N(\alpha)\,C_1(\alpha)$ |
| Recentring invariance | $\vert C_b(\alpha)\vert = \vert W(b/2, 2\pi\alpha)\vert$ |
| Rayleigh threshold | exact $c \in [4.2,4.4)$, $c \approx 4.27836$ |
| Rayleigh derivative | $G'(x) = 2\cos x\,(1 - \cos x)$ |
| Perfect null | $\Delta T = 2\pi$: midpoint $0$, centres $2T$ |
| Fejér identity | $\vert S_N(\alpha)\vert^2 = 2\sum_{d<N}(N-d)\cos(2\pi d\alpha) - N$ |
| Fejér mass | $\int_0^1 \vert S_N\vert^2 = N$ |
| Fejér concentration | $\vert S_N(\alpha)\vert^2 \le 1/(4\delta^2)$ when $\Vert\alpha\Vert \ge \delta$ |
