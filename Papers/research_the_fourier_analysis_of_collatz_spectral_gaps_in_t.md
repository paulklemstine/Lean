# The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map

## Abstract

The Collatz (or $3n+1$) map is one of the most famous unsolved problems in elementary number theory, yet its dynamics are notoriously resistant to the standard tools of arithmetic. We develop a bridge between the **arithmetic dynamics** of the Collatz map and the **Fourier analysis** of exponential (character) sums. Our starting point is a sharp dichotomy for the geometric character sum $S_N(\omega) = \sum_{n<N} e(\omega)^n$, where $e(\omega) = e^{2\pi i \omega}$: at every integer frequency the sum resonates fully, $S_N(m) = N$, while at every non-integer frequency it is bounded by $1/\lvert\sin(\pi\omega)\rvert$ *uniformly in $N$*. This is the precise sense in which a linear phase concentrates energy only at integer frequencies — the *spectral gap*. We then establish the central connector of the paper: the Collatz branch selector is exactly the Fourier character at the Nyquist frequency $\omega = 1/2$, since $\bigl(e(1/2)\bigr)^n = (-1)^n$ equals $1$ precisely when $n$ is even. Consequently the Collatz map may be written with no reference to parity, purely in Fourier terms, and the associated Collatz Fourier transform $F_N(\omega) = \sum_{n<N} e(\omega\, T(n))$ splits along a parity partition into two linear-phase sub-sums. On the dynamics side we prove that powers of two collapse to the terminal cycle in exactly logarithmically many steps, $T^{[k]}(2^k) = 1$, the cleanest instance of convergence to $\{1,4,2,1\}$. Together these results recast the Collatz conjecture as a statement about the absence of resonances at irrational frequencies.

## 1. Introduction

Define the Collatz map $T : \mathbb{N} \to \mathbb{N}$ by

$$T(n) = \begin{cases} n/2 & n \equiv 0 \pmod 2, \\ 3n+1 & n \equiv 1 \pmod 2. \end{cases}$$

The Collatz conjecture asserts that for every positive integer $n$ there exists $k$ with $T^{[k]}(n) = 1$; equivalently, every orbit is eventually absorbed by the cycle $1 \to 4 \to 2 \to 1$. Despite its elementary statement, the conjecture has resisted all approaches for nearly a century.

This paper proposes and develops a spectral point of view. Rather than tracking a single orbit — the erratic staircase produced by iterating $T$ — we study the map through **exponential sums**, the fundamental objects of Fourier analysis on the integers. The guiding intuition is physical: a "mixing" dynamical system spreads its energy across the frequency spectrum rather than concentrating it at any single tone, and this spreading is measured by a *spectral gap*.

Our contributions are threefold.

1. **A sharp spectral dichotomy** for geometric character sums (Section 3): full resonance at integer frequencies and a uniform-in-$N$ gap at all others, resting on a clean half-angle modulus identity.
2. **A parity–Fourier bridge** (Section 4): the Collatz branch decision is literally the value of the Nyquist character $e(1/2)$, yielding a Fourier form of the map and a parity split of its Fourier transform.
3. **An exact convergence result** (Section 5): the orbit of $2^k$ reaches $1$ in exactly $k$ steps, a logarithmic stopping time consistent with the spectral-gap heuristic.

We stress that we do *not* resolve the Collatz conjecture. What we provide is a faithful reformulation and a set of rigorous anchor results that make the spectral programme precise.

## 2. Preliminaries: the additive character

Throughout, $e : \mathbb{R} \to \mathbb{C}$ denotes the additive character

$$e(x) = e^{2\pi i x}.$$

We collect its basic properties.

**Lemma 2.1 (Unit modulus).** *For every real $\omega$, $\lvert e(\omega) \rvert = 1$.*

*Proof.* The modulus of $\exp(z)$ is $\exp(\operatorname{Re} z)$, and $2\pi i \omega$ is purely imaginary, so $\operatorname{Re}(2\pi i \omega) = 0$ and $\lvert e(\omega)\rvert = e^0 = 1$. $\square$

**Lemma 2.2 (Powers scale the frequency).** *For $\omega \in \mathbb{R}$ and $n \in \mathbb{N}$, $\;e(\omega)^n = e(\omega n) = e^{2\pi i \omega n}$.*

*Proof.* By the exponential law $\exp(z)^n = \exp(nz)$ applied to $z = 2\pi i \omega$. $\square$

**Lemma 2.3 (Integer frequencies trivialize).** *For every integer $m$, $\;e(m) = 1$.*

*Proof.* $e(m) = e^{2\pi i m}$, and $\exp(w) = 1$ if and only if $w \in 2\pi i \mathbb{Z}$; here $w = 2\pi i m$. $\square$

**Lemma 2.4 (Half-angle modulus).** *For every real $\omega$,*

$$\lvert e(\omega) - 1 \rvert = 2\,\lvert \sin(\pi\omega)\rvert.$$

*Proof.* Write $e(\omega) - 1 = (\cos 2\pi\omega - 1) + i\sin 2\pi\omega$. Then
$$\lvert e(\omega) - 1\rvert^2 = (\cos 2\pi\omega - 1)^2 + \sin^2 2\pi\omega = 2 - 2\cos 2\pi\omega.$$
Using the double-angle identity $\cos 2\theta = 1 - 2\sin^2\theta$ with $\theta = \pi\omega$ gives $2 - 2\cos 2\pi\omega = 4\sin^2(\pi\omega)$, so $\lvert e(\omega)-1\rvert = 2\lvert\sin(\pi\omega)\rvert$. $\square$

This identity is the analytic core of the spectral gap: it converts the algebraic quantity $e(\omega) - 1$ appearing in a geometric-series denominator into the trigonometric quantity $\sin(\pi\omega)$ that measures distance to the nearest integer frequency.

## 3. The spectral dichotomy

For a frequency $\omega$ and a length $N$, define the **geometric character sum**

$$S_N(\omega) = \sum_{n=0}^{N-1} e(\omega)^n.$$

Being a partial sum of a geometric series, its behaviour is entirely dictated by whether the ratio $e(\omega)$ equals $1$.

**Theorem 3.1 (Full resonance).** *For every integer $m$ and every $N$,*
$$S_N(m) = N.$$

*Proof.* By Lemma 2.3, $e(m) = 1$, hence $e(m)^n = 1$ for all $n$, and the sum of $N$ ones is $N$. $\square$

**Theorem 3.2 (Spectral gap).** *For every non-integer frequency $\omega$ (equivalently $e(\omega) \neq 1$) and every $N$,*
$$\bigl\lvert S_N(\omega)\bigr\rvert \;\le\; \frac{1}{\lvert \sin(\pi\omega)\rvert}.$$
*In particular the bound is independent of $N$.*

*Proof.* Since $e(\omega) \neq 1$, the geometric-sum formula gives
$$S_N(\omega) = \frac{e(\omega)^N - 1}{e(\omega) - 1}.$$
Taking moduli and using $\lvert e(\omega)^N\rvert = 1$ (Lemma 2.1) we bound the numerator: $\lvert e(\omega)^N - 1\rvert \le \lvert e(\omega)^N\rvert + 1 = 2$. For the denominator, Lemma 2.4 gives $\lvert e(\omega) - 1\rvert = 2\lvert\sin(\pi\omega)\rvert$. Hence
$$\lvert S_N(\omega)\rvert \le \frac{2}{2\lvert\sin(\pi\omega)\rvert} = \frac{1}{\lvert\sin(\pi\omega)\rvert}. \qquad \square$$

**Interpretation.** Theorems 3.1 and 3.2 are two halves of a single dichotomy. At integer frequencies the character sum grows linearly in $N$ — the waves $e(\omega)^n$ march in lockstep and reinforce. At every other frequency the sum is trapped below a fixed ceiling forever, no matter how many terms are added; the waves scatter and cancel. The gulf between "grows like $N$" and "$O(1)$" is the *spectral gap*, the quantitative signature that a linear phase is *mixing*: it concentrates energy only at the integer frequencies. The ceiling $1/\lvert\sin(\pi\omega)\rvert$ degrades gracefully as $\omega$ approaches an integer, exactly capturing the transition into resonance.

## 4. The bridge: a character selects the Collatz branch

We now connect the Fourier machinery of Section 3 to the arithmetic of the Collatz map. The key is the **Nyquist frequency** $\omega = 1/2$.

**Lemma 4.1 (Nyquist character).** $\;e(1/2) = -1.$

*Proof.* $e(1/2) = e^{2\pi i \cdot 1/2} = e^{\pi i} = -1$ by Euler's identity. $\square$

**Corollary 4.2.** *For $n \in \mathbb{N}$, $\;\bigl(e(1/2)\bigr)^n = (-1)^n$, which equals $1$ when $n$ is even and $-1$ when $n$ is odd.*

The parity test that drives the Collatz map is therefore encoded by a single Fourier character.

**Theorem 4.3 (The connector).** *For every $n \in \mathbb{N}$,*
$$T(n) = \begin{cases} n/2 & \text{if } \bigl(e(1/2)\bigr)^n = 1, \\ 3n+1 & \text{otherwise.} \end{cases}$$

*Proof.* By Corollary 4.2, $\bigl(e(1/2)\bigr)^n = 1$ if and only if $n$ is even. The condition "$n$ even" is exactly the branch condition in the definition of $T$; substituting the Fourier condition for the parity condition changes nothing. $\square$

Theorem 4.3 is exact, not asymptotic: the branch selection of the Collatz map is *literally* the evaluation of the Nyquist character. Parity (an arithmetic notion) and the Nyquist tone (a Fourier notion) coincide.

**Definition 4.4 (Collatz Fourier transform).** For a frequency $\omega$ and length $N$,
$$F_N(\omega) = \sum_{n=0}^{N-1} e\bigl(\omega\, T(n)\bigr).$$

Because the branch of $T$ is a parity decision, $F_N$ decomposes along the parity partition of $\{0,\dots,N-1\}$.

**Theorem 4.5 (Parity split).** *For every $\omega$ and $N$,*
$$F_N(\omega) = \sum_{\substack{0 \le n < N \\ n \text{ even}}} e\!\left(\omega \cdot \tfrac{n}{2}\right) \;+\; \sum_{\substack{0 \le n < N \\ n \text{ odd}}} e\bigl(\omega \cdot (3n+1)\bigr).$$

*Proof.* Partition $\{0,\dots,N-1\}$ into its even and odd elements. On the even part $T(n) = n/2$; on the odd part $T(n) = 3n+1$. Substituting these values of $T(n)$ into $e(\omega\, T(n))$ and summing each part separately yields the two displayed sums. $\square$

**Interpretation.** Both sub-sums in Theorem 4.5 are *linear phases*: over the even inputs the phase $\omega\cdot(n/2)$ advances arithmetically, and over the odd inputs the phase $\omega\cdot(3n+1)$ likewise advances arithmetically. Each is therefore a geometric character sum in disguise and is governed by the resonance/gap dichotomy of Section 3. The apparently chaotic Collatz map is, from the Fourier side, two geometric sums stitched together along the parity seam. This is the structural payoff of the bridge: it opens the door to Weyl-type bounds for $F_N$ obtained by bounding each branch separately.

## 5. Dynamics: convergence of powers of two

We record the cleanest rigorous instance of convergence to the terminal cycle.

**Lemma 5.1 (Halving a power of two).** *For every $k \in \mathbb{N}$, $\;T\bigl(2^{k+1}\bigr) = 2^{k}$.*

*Proof.* $2^{k+1}$ is even, so $T$ halves it: $T(2^{k+1}) = 2^{k+1}/2 = 2^k$. $\square$

**Theorem 5.2 (Exact stopping time for powers of two).** *For every $k \in \mathbb{N}$,*
$$T^{[k]}\bigl(2^k\bigr) = 1.$$

*Proof.* By induction on $k$. For $k=0$, $T^{[0]}(2^0) = 2^0 = 1$. For the inductive step, assume $T^{[k]}(2^k) = 1$. Then
$$T^{[k+1]}\bigl(2^{k+1}\bigr) = T^{[k]}\bigl(T(2^{k+1})\bigr) = T^{[k]}\bigl(2^{k}\bigr) = 1,$$
using Lemma 5.1 for the middle equality and the inductive hypothesis for the last. $\square$

**Interpretation.** For $n = 2^k$ the stopping time is *exactly* $k = \log_2 n$. This is the extreme, provable case of the conjectured phenomenon that orbits reach $1$ in $O(\log n)$ steps — which, under the spectral heuristic, corresponds to a spectral gap of width $\Omega(1/\log n)$. Wide gaps signify rapid mixing, and rapid mixing signifies short trips to $1$.

## 6. The comparison family: $qn+1$

For odd $q$, define $T_q(n) = n/2$ if $n$ is even and $qn+1$ if $n$ is odd, so $T_3$ is the classical Collatz map. The bridge of Section 4 is *insensitive to $q$*: the branch selector is still the Nyquist character (Theorem 4.3 holds verbatim with $qn+1$ replacing $3n+1$), and the Fourier transform still splits along parity (Theorem 4.5 holds with the odd-branch phase $\omega(qn+1)$). Only the coefficient inside the odd branch changes.

This is significant because the maps $T_5$ and $T_7$ are believed *not* to send every integer to $1$ — they possess apparently divergent orbits. Since the branching machinery is identical across the family, whatever distinguishes the convergent $T_3$ from the divergent $T_5$ must reside entirely in the interaction between the energy injected by the odd branch and the energy drained by the halving branch. In the spectral language, the question becomes: for which $q$ does the transform $F_N$ maintain a spectral gap at all irrational frequencies, and for which $q$ does a resonance emerge?

## 7. Discussion

The reformulation offered here reframes the Collatz conjecture as a statement about the *absence of resonances*. Convergence of every orbit to $1$ corresponds, heuristically, to the Collatz Fourier transform having no concentration of energy at any irrational frequency — a global spectral gap. The rigorous results in this paper are the anchor points of that programme:

- The **dichotomy** (Theorems 3.1, 3.2) establishes the vocabulary of resonance and gap for the simplest linear phases.
- The **bridge** (Theorems 4.3, 4.5) shows the Collatz branching is genuinely a Fourier phenomenon at the Nyquist frequency, and that its transform is built from linear phases.
- The **dynamics** (Theorem 5.2) exhibits the target behaviour in the one family where it is provable, with the logarithmic stopping time predicted by the heuristic.

The strength of the viewpoint is that it is *uniform across the $qn+1$ family*, isolating the source of divergence to the odd-branch coefficient. Its limitation is equally clear: turning the heuristic "gap $\Rightarrow$ convergence" into a theorem requires controlling the interference between the two branch sums, which is where the full difficulty of Collatz reappears in analytic clothing.

## 8. Future work

Several concrete directions extend the results above.

1. **Higher-frequency character detection.** The Nyquist character $e(1/2)$ detects parity; the characters $e(k/2^j)$ detect residues modulo $2^j$, the natural setting for the 2-adic (Terras) encoding of Collatz. A general "character selects residue class" lemma would express the accelerated Collatz map as a finite Fourier expansion.

2. **Weyl-type bounds for $F_N$.** Starting from the parity split (Theorem 4.5), bound each sub-sum. The even branch is a genuine linear phase and inherits the geometric spectral gap; the odd branch is again linear, so a two-term spectral-gap bound for $F_N$ should be provable unconditionally.

3. **From gaps to stopping times.** Make the gap-to-stopping-time heuristic precise. A tractable first target generalizes the exact result for $2^k$ to $n\cdot 2^k$, yielding $O(\log n)$ stopping times on a set of positive density.

4. **Comparison maps $5n+1$, $7n+1$.** Study the $qn+1$ family and pinpoint exactly where divergence enters the Fourier picture.

5. **Discrete orthogonality.** Add the finite orthogonality relation $\sum_{n<N} e(k/N)^n = N\cdot[\,N \mid k\,]$ to link the continuous spectral gap with the discrete Fourier transform used in large-scale numerical experiments.

## 9. Conclusion

By reading the Collatz map through Fourier analysis, we have replaced a question about the arithmetic of even and odd numbers with a question about waves, resonance, and cancellation. The parity test dissolves into the Nyquist character; convergence to $1$ becomes the absence of rogue resonances; and the mystery of why $3n+1$ converges while $5n+1$ apparently does not becomes a question about spectral gaps. The conjecture remains open, but it now stands in a new language — one equipped with the powerful, well-developed machinery of harmonic analysis.
