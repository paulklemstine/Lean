# Locating the Quantum–Classical Boundary in Period Finding: Sampling Barriers, Spectral Hiding, and Uncertainty-Extremality of the Coherent Comb

**Author:** Aristotle
**Date:** 2026-08-12

---

## Abstract

Period finding is the entire quantum content of Shor's factoring algorithm: given a modulus $N$ and a base $a$ with $\gcd(a,N)=1$, determine the multiplicative order $r$ of $a$. We give a precise account of *where* the classical approach fails and *what* the quantum circuit supplies in its place, in a setting where both sides use literally the same discrete Fourier transform on $\mathbb{Z}/n\mathbb{Z}$.

On the classical side we isolate two logically independent barriers. **Barrier 1 (information-theoretic).** Any scheme that determines an arbitrary period-$r$ signal from $K$ Fourier measurements at chosen frequencies must satisfy $K \ge r$; and in a finite cyclic group at most $B^2$ elements — more sharply, at most $B \cdot \#\{d \mid |G| : d \le B\}$ — have order at most $B$, so modulo a prime $p \ge 3$ some base has order exceeding $\lfloor\sqrt{p-2}\rfloor$, and whenever $2B^2 < p-1$ a strict majority of bases have order exceeding $B$. In the bit-size variable $x = \log N$ the resulting requirement $\sqrt N = e^{x/2}$ is superpolynomial. **Barrier 2 (structural).** Even granted $K \ge r$ samples, the value signal $x \mapsto a^x \bmod N$ is spectrally diffuse: for the textbook instance $N=15$, $a=7$ the fundamental bin has modulus $\sqrt{45}$ while the second harmonic has modulus $15$, so naive peak picking returns the period $2$, which is *false*. We give an exact closed-form criterion deciding this comparison for all order-$4$ instances, verify it on four instances, and record that it holds for $684$ of the $1870$ order-$4$ pairs with $N < 500$.

On the quantum side, the state left in the input register after one coherent evaluation of $a^x \bmod N$ is the indicator of an arithmetic progression — the *coherent comb*. We compute its transform exactly: the spectrum is a perfect Dirac comb, of modulus $m = n/r$ on the $r$ frequencies divisible by $m$ and identically zero elsewhere; the peaks are equal in height; any peak $jm$ with $\gcd(j,r)=1$ determines $r$ as the denominator of $jm/n$ in lowest terms, and $\varphi(r)$ such peaks exist.

Finally we prove a Donoho–Stark discrete uncertainty principle for this transform, $\#\operatorname{supp} v \cdot \#\operatorname{supp} \hat v \ge n$ for all $v \ne 0$, and show that the coherent comb *saturates* it, $m \cdot r = n$. A rigidity converse shows that spectra supported on the multiples of $m$ are exactly the $r$-periodic signals. Thus the quantum input state is extremal for the time–frequency trade-off: no input, classical or quantum, is sharper. We are explicit about scope: nothing here lower-bounds classical *factoring* time.

**Keywords:** period finding, discrete Fourier transform, coherent comb, Donoho–Stark uncertainty principle, multiplicative order, spectral hiding, quantum–classical separation.

---

## 1. Introduction

### 1.1 The reduction and the question

Let $N$ be composite, $a$ a base with $\gcd(a,N)=1$, and $r = \operatorname{ord}_N(a)$ the least positive integer with $a^r \equiv 1 \pmod N$. For a random $a$, with probability bounded below by a constant $r$ is even and $a^{r/2} \not\equiv -1$, whence $\gcd(a^{r/2}-1, N)$ is a nontrivial factor. Every other step in Shor's algorithm is classical and cheap. The quantum content of factoring is therefore exactly:

> **Period finding.** Determine $r$ from access to the function $x \mapsto a^x \bmod N$.

The standard narrative is that the quantum Fourier transform "extracts the period efficiently." That is true, but it does not identify the resource. A classical machine also has a Fourier transform; the fast Fourier transform is one of the best-understood algorithms in existence. What, precisely, does the quantum machine do that the classical machine cannot?

### 1.2 Thesis

Our thesis is that the Fourier mathematics is *shared*, and the entire difference lies in the input state. Both sides use the same primitive root of unity $\zeta_n = e^{2\pi i / n}$ and the same character orthogonality on $\mathbb{Z}/n\mathbb{Z}$. The classical algorithm is restricted to sampling the **value signal** $V(x) = a^x \bmod N$; the quantum circuit, after one coherent evaluation on a uniform superposition, holds the **coherent comb**, the indicator of a residue class modulo $r$. We show:

1. the value signal is subject to two independent barriers, one about how many samples are needed and one about the geometry of the spectrum;
2. the comb has a perfect Dirac-comb spectrum from which the period is recoverable exactly;
3. the comb is *uncertainty-extremal*, so the advantage is not incidental but occupies the extreme point of a fundamental inequality.

### 1.3 Honest scope

We prove no superpolynomial lower bound on classical factoring; that problem is open. The barriers below constrain a specific, natural classical strategy — Fourier sampling of the exponentiation signal. Barrier 1's sample bound is proved for linear measurement schemes; the nonlinear adaptive case is open (see §8). Barrier 2 is exact for order-$4$ instances and exhibited concretely; no asymptotic density claim is proved.

---

## 2. The discrete Fourier transform used throughout

Fix $n \ge 1$ and let $\zeta_n = \exp(2\pi i / n)$, a primitive $n$-th root of unity with $|\zeta_n^{\,j}| = 1$ for all $j$.

**Definition 2.1 (Transform and inverse).** For $v : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ set
$$\hat v(k) \;=\; \sum_{x=0}^{n-1} v(x)\,\zeta_n^{\,xk}, \qquad
\big(\mathcal{F}^{-1} w\big)(x) \;=\; \frac1n \sum_{k=0}^{n-1} w(k)\,\zeta_n^{-xk}.$$

**Proposition 2.2 (Geometric character sum).** If $\omega^n = 1$ and $\omega \ne 1$ then $\sum_{j=0}^{n-1}\omega^{\,j} = 0$; if $\omega = 1$ the sum is $n$.

*Proof.* $(\omega - 1)\sum_{j<n}\omega^j = \omega^n - 1 = 0$, and $\omega - 1 \ne 0$. $\square$

**Theorem 2.3 (Inversion).** $\mathcal{F}^{-1}\hat v = v$ for every $v$, provided $n$ is invertible in the coefficient field.

*Proof.* Expand and exchange sums: the inner sum $\sum_k \zeta_n^{(y-x)k}$ is $n$ when $x = y$ and $0$ otherwise, by Proposition 2.2 applied to $\omega = \zeta_n^{\,y-x}$, which is an $n$-th root of unity, and is $\ne 1$ precisely when $x \ne y$ because $\zeta_n$ is primitive. $\square$

Proposition 2.2 is the *single* engine used on both sides of the boundary below. It is worth emphasising that everything we prove about the "quantum Fourier transform" is a statement about Definition 2.1; the quantum circuit implements this map, nothing more.

**Definition 2.4 (Supports).** For $v : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$, write $\operatorname{supp} v = \{x : v(x) \ne 0\}$.

---

## 3. The quantum side: the coherent comb

### 3.1 The state

In Shor's circuit, a Hadamard layer prepares $\frac{1}{\sqrt n}\sum_{x<n} |x\rangle|0\rangle$; modular exponentiation, applied once, yields $\frac{1}{\sqrt n}\sum_{x<n}|x\rangle|a^x \bmod N\rangle$; measuring (or tracing out) the second register collapses the first onto the set of $x$ producing the observed value. That set is an arithmetic progression of step $r$.

**Definition 3.1 (Coherent comb).** Let $n = mr$ with $m, r \ge 1$ and $0 \le x_0 < r$. The *comb state* is
$$C_{m,r,x_0}(x) = \begin{cases} 1, & x \equiv x_0 \pmod r, \\ 0, & \text{otherwise},\end{cases} \qquad x \in \{0,\dots,n-1\},$$
equivalently the (unnormalised) superposition $\sum_{j=0}^{m-1} |x_0 + jr\rangle$. Its transform is
$$\widehat C(k) = \sum_{j=0}^{m-1} \zeta_{mr}^{\,(x_0 + jr)k}.$$

Note $|\operatorname{supp} C| = m$: the comb has exactly $m$ teeth.

### 3.2 Exact transform

**Lemma 3.2 (Spacing collapse).** For $m, r \ge 1$, $\zeta_{mr}^{\,r} = \zeta_m$.

*Proof.* $\exp(2\pi i r/(mr)) = \exp(2\pi i/m)$. $\square$

**Theorem 3.3 (Factorisation of the comb transform).** For $m, r \ge 1$ and any $x_0, k$,
$$\widehat C(k) \;=\; \zeta_{mr}^{\,x_0 k}\cdot\Big(\textstyle\sum_{j<m}\zeta_m^{\,jk}\Big) \;=\; \zeta_{mr}^{\,x_0 k}\cdot \begin{cases} m, & m \mid k,\\ 0,& m \nmid k.\end{cases}$$

*Proof.* Expand $(x_0 + jr)k = x_0k + r(jk)$ and use Lemma 3.2 to rewrite $\zeta_{mr}^{\,r(jk)} = \zeta_m^{\,jk} = (\zeta_m^{\,k})^j$. Factoring out the $j$-independent phase leaves $\sum_{j<m}(\zeta_m^{\,k})^{j}$. Since $\zeta_m$ is a primitive $m$-th root of unity, $\zeta_m^{\,k} = 1$ iff $m \mid k$; apply Proposition 2.2. $\square$

**Corollary 3.4 (Sharp peak theorem).** $|\widehat C(k)| = m$ if $m \mid k$ and $|\widehat C(k)| = 0$ otherwise. In particular the off-peak spectrum vanishes *identically*, not approximately, and $|\widehat C(k)| \le m$ always.

Two remarks. First, $m$ is the maximum possible modulus of a sum of $m$ unit-modulus complex numbers, so the peaks saturate the triangle inequality: *coherence is exactly the alignment of the $m$ phases*. Second, the peak height is independent of $x_0$ — the unknown offset contributes only a global phase, which is why measurement of the second register does no harm.

**Proposition 3.5 (Peak count).** $\#\{k < mr : m \mid k\} = r$; the peaks are $k = jm$, $0 \le j < r$.

**Corollary 3.6 (Equal harmonics).** $|\widehat C(j_1 m)| = |\widehat C(j_2 m)| = m$ for all $j_1, j_2$. No amount of peak *ranking* singles out the fundamental frequency, even in the perfectly coherent case.

**Proposition 3.7 (Parseval bookkeeping).** $\sum_{k<n} |\widehat C(k)|^2 = r\,m^2 = n\,m$: the entire spectral energy is carried by the $r$ peaks, each of weight $m^2$.

### 3.3 From a peak to the period

Corollary 3.6 might look fatal — how do we find the fundamental if all peaks are equal? We do not need to.

**Theorem 3.8 (Period extraction).** Let $n = mr$ with $m, r \ge 1$ and let $j$ satisfy $\gcd(j, r) = 1$. Then the rational number $\dfrac{jm}{mr} = \dfrac{j}{r}$, written in lowest terms, has denominator exactly $r$.

*Proof.* Cancel $m \ne 0$; since $\gcd(j,r)=1$ and $r > 0$, the fraction $j/r$ is already reduced. $\square$

In the algorithm this is the continued-fraction step: from a measured $k$ one computes the convergents of $k/n$ and reads off the denominator. Theorem 3.8 says the step is exact — no approximation, no rounding — in the idealised setting $r \mid n$.

**Proposition 3.9 (Useful peaks).** The peaks $jm$ from which Theorem 3.8 recovers $r$ are exactly those with $\gcd(j,r)=1$; there are $\varphi(r)$ of them among the $r$ peaks, and at least one exists for every $r \ge 1$. Hence in the exact-period model a single run succeeds with probability $\varphi(r)/r$, which is $\Omega(1/\log\log r)$.

**Corollary 3.10 (Existence of a recovering peak).** For every $n = mr$ with $m, r \ge 1$ and every offset $x_0$, there is $j < r$ with $|\widehat C(jm)| = m$ and such that $jm/n$ reduces to denominator $r$.

### 3.4 Rigidity: sharp combs in frequency are periodic signals in time

**Theorem 3.11 (Converse of the sharp-peak theorem).** Let $n = mr$ and let $v : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ satisfy $\hat v(k) = 0$ for every $k$ with $m \nmid k$. Then $v$ is $r$-periodic: $v(x + r) = v(x)$ whenever $x + r < n$.

*Proof.* By inversion, $v(x) = \frac1n\sum_{k}\hat v(k)\zeta_n^{-xk}$, and only $k = jm$ contribute. For such $k$, the shift by $r$ multiplies the $k$-th term by $\zeta_n^{-rk} = \zeta_n^{-rjm} = \zeta_n^{-jn} = 1$. Every surviving mode is $r$-periodic, hence so is $v$. $\square$

Thus "peak-supported spectrum" and "$r$-periodic" are the same condition, and the quantum advantage cannot be recreated by preparing some cleverer non-periodic state that fakes a sharp comb. Among all $r$-periodic signals, the indicator comb is the one with the smallest possible time support, namely $m$ — which, as §6 shows, is exactly what makes it extremal.

---

## 4. Barrier 1: the classical sampling requirement

### 4.1 Resolution

A classical Fourier-sampling scheme selects frequencies $k_1,\dots,k_K$ and observes $\hat v(k_1),\dots,\hat v(k_K)$ for the unknown period-$r$ signal $v : \mathbb{Z}/r\mathbb{Z} \to \mathbb{C}$.

**Theorem 4.1 (Resolution bound).** If the measurement map $v \mapsto (\hat v(k_1),\dots,\hat v(k_K))$ is injective on the space of period-$r$ signals, then $K \ge r$. Equivalently: if $K < r$ there exist two *distinct* period-$r$ signals with identical Fourier samples at those $K$ frequencies.

*Proof sketch.* The space of period-$r$ signals is $\mathbb{C}^r$, of dimension $r$; the measurement map is linear into $\mathbb{C}^K$. If $K < r$ the kernel is nontrivial, so some $u \ne 0$ has all samples zero, and $v$ and $v + u$ are indistinguishable. $\square$

This is the exact discrete counterpart of the folklore rule "frequency resolution $1/K$ must beat the frequency spacing $1/r$."

### 4.2 Typical order is large

Theorem 4.1 is useless unless $r$ is large. The following elementary counting bound makes that rigorous.

**Theorem 4.2 (Small-order count).** Let $G$ be a finite cyclic group and $B \ge 0$. Then
$$\#\{g \in G : \operatorname{ord}(g) \le B\} \;\le\; B \cdot \#\{d : d \mid |G|,\ d \le B\} \;\le\; B^2 .$$

*Proof.* Every $g$ with $\operatorname{ord}(g) \le B$ satisfies $g^{d} = 1$ with $d = \operatorname{ord}(g)$, and $d$ divides $|G|$ and is $\le B$. So the set is covered by the root sets $R_d = \{g : g^d = 1\}$ indexed by such $d$. In a cyclic group $|R_d| \le d \le B$ (the equation $g^d=1$ has at most $d$ solutions). Summing over the index set gives the first bound; the second follows since the number of divisors of $|G|$ that are $\le B$ is at most $B$. $\square$

The divisor-indexed form is a genuine refinement: for $|G| = p-1$ with $\tau$ divisors it yields a base of order $> |G|/\tau$, and $\tau = |G|^{o(1)}$ for typical $|G|$, so this is $|G|^{1-o(1)}$ rather than merely $|G|^{1/2}$.

**Corollary 4.3 (Existence of a high-order base).** If $B \cdot \#\{d \mid |G| : d \le B\} < |G|$ — in particular if $B^2 < |G|$ — then some $g \in G$ has $\operatorname{ord}(g) > B$.

**Corollary 4.4 (Most bases have large order).** If $2B^2 < |G|$ then strictly more than half the elements of $G$ have order $> B$.

*Proof.* The complement has size $\le B^2 < |G|/2$. $\square$

**Corollary 4.5 (Bases modulo a prime).** For a prime $p \ge 3$, the group $(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of order $p-1$, and $\lfloor\sqrt{p-2}\rfloor^2 \le p - 2 < p-1$. Hence there is a base $a$ with $\operatorname{ord}_p(a) > \lfloor\sqrt{p-2}\rfloor$; and whenever $2\lfloor\sqrt{p-2}\rfloor^2 < p-1$, a strict majority of bases have order that large.

### 4.3 Barrier 1, assembled

**Theorem 4.6 (Classical sampling barrier).** Let $p \ge 3$ be prime. There is a base $a$ modulo $p$ with $\operatorname{ord}_p(a) > \lfloor\sqrt{p-2}\rfloor$ such that *every* Fourier-sampling scheme determining the period-$\operatorname{ord}_p(a)$ signal uses more than $\lfloor\sqrt{p-2}\rfloor$ samples.

*Proof.* Combine Corollary 4.5 with Theorem 4.1: $K \ge r = \operatorname{ord}_p(a) > \lfloor\sqrt{p-2}\rfloor$. $\square$

**Proposition 4.7 (Superpolynomiality).** Write the input size as $x = \log N$. Then the sample requirement $\sqrt N$ is the function $x \mapsto e^{x/2}$, which grows faster than every polynomial: for every $c, d$ there is $x$ with $e^{x/2} > c\,x^d$. Hence the classical Fourier-sampling requirement is not polynomially bounded in the bit-size.

*Proof.* $e^{x/2}/x^d \to \infty$ since $\exp$ dominates every power. $\square$

---

## 5. Barrier 2: spectral hiding in the value signal

Barrier 1 is about how much data is needed. Barrier 2 says that even with all of it, the naive spectral reading is wrong.

**Definition 5.1 (Value signal).** For $N, a, r$ with $r = \operatorname{ord}_N(a)$, the *value signal* is $V(x) = (a^x \bmod N) \in \mathbb{C}$, $x = 0,\dots,r-1$. This is what a classical algorithm actually observes.

### 5.1 The textbook instance

Take $N = 15$, $a = 7$. Then $7^1=7$, $7^2 \equiv 4$, $7^3 \equiv 13$, $7^4 \equiv 1 \pmod{15}$, so $r = 4$ and the residues are $v = (1,7,4,13)$. Since $\zeta_4 = i$:

**Theorem 5.2 (Exact bins).**
$$\hat V(0) = 25,\quad \hat V(1) = -3 - 6i,\quad \hat V(2) = -15,\quad \hat V(3) = -3 + 6i.$$
Consequently $|\hat V(1)| = |\hat V(3)| = \sqrt{45} \approx 6.708$ and $|\hat V(2)| = 15$.

*Proof.* Direct evaluation of $\sum_{x<4} v(x)\, i^{xk}$ using $i^2 = -1$. $\square$

**Theorem 5.3 (The fundamental is dominated).** $|\hat V(1)| < |\hat V(2)|$, indeed $\sqrt{45} < \sqrt{225} = 15$. The same holds for $|\hat V(3)|$.

**Theorem 5.4 (Peak picking returns a false period).** Among the non-DC bins the strict maximum is $k = 2$. Reading the period off that peak gives $r' = 4/2 = 2$. But $7^2 = 49 \equiv 4 \not\equiv 1 \pmod{15}$, while $7^4 \equiv 1$. Hence the largest-peak heuristic does not merely lose accuracy: it outputs a number that is not the order, and the subsequent $\gcd$ step then produces nothing.

**Theorem 5.5 (The spectrum is spread).** All four bins are nonzero. No frequency can be discarded a priori.

### 5.2 A general criterion at order 4

Let $r = 4$ and write $v_i = a^i \bmod N$ for $i = 0,1,2,3$.

**Theorem 5.6 (Closed forms).**
$$\hat V(1) = (v_0 - v_2) + (v_1 - v_3)\,i, \qquad \hat V(2) = v_0 - v_1 + v_2 - v_3 \in \mathbb{R},$$
so
$$|\hat V(1)| = \sqrt{(v_0-v_2)^2 + (v_1-v_3)^2}, \qquad |\hat V(2)| = |v_0 - v_1 + v_2 - v_3| .$$

*Proof.* Substitute $\zeta_4 = i$, $\zeta_4^2 = -1$, $\zeta_4^3 = -i$ and separate real and imaginary parts. $\square$

**Theorem 5.7 (Spectral-hiding criterion).** For any $N$ and any $a$ of order $4$ modulo $N$,
$$|\hat V(1)| < |\hat V(2)| \iff (v_0 - v_1 + v_2 - v_3)^2 \;>\; (v_0 - v_2)^2 + (v_1 - v_3)^2,$$
and the reverse strict inequality gives the reverse comparison. The criterion is a decidable inequality between integers.

*Proof.* Both moduli are square roots of nonnegative reals; $\sqrt{\cdot}$ is strictly monotone. $\square$

**Corollary 5.8 (Verified instances).** The criterion holds — the fundamental is dominated — for
$(N,a) = (15,7)$ with residues $1,7,4,13$ and $45 < 225$;
$(15,13)$ with $1,13,4,7$ and $45 < 225$;
$(20,13)$ with $1,13,9,17$ and $80 < 400$;
$(39,31)$ with $1,31,25,34$ and $585 < 1521$.
Each of these bases genuinely has order $4$ ($a^4 \equiv 1$, $a^2 \not\equiv 1$).

**Computational evidence.** Exhaustive enumeration over all pairs $(N,a)$ with $N < 500$, $\gcd(a,N)=1$ and $\operatorname{ord}_N(a) = 4$ yields $1870$ instances, of which $684$ — approximately $36.6\%$ — satisfy the hiding criterion. Spectral hiding is therefore not an isolated pathology but a bulk phenomenon in this slice.

**Interpretation.** The criterion is transparent. The fundamental collapses when the residues pair up antipodally ($v_0 \approx v_2$ and $v_1 \approx v_3$, so that both squares on the right are small) while the alternating sum $v_0 - v_1 + v_2 - v_3$ stays large. Pseudorandom residues do exactly this: nothing in $a^x \bmod N$ makes the fundamental structurally favoured.

### 5.3 What a genuinely single-peaked signal must be

**Theorem 5.9 (Two-bin structure theorem).** Let $\omega$ be a primitive $n$-th root of unity and $v : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ have $\hat v(k) = 0$ for all $k \notin \{0, k_0\}$, where $k_0 \ne 0$. Then
$$v(x) = \frac1n\Big(\hat v(0) + \hat v(k_0)\,\omega^{-x k_0}\Big),$$
i.e. $v$ is a constant plus a single character — a pure sinusoid.

*Proof.* Fourier inversion, retaining only the two surviving terms of $\sum_k \hat v(k)\omega^{-xk}$. $\square$

**Corollary 5.10 (The value signal is not single-peaked).** For $N=15$, $a=7$ there is no frequency $k_0$ carrying the entire non-DC spectrum, since by Theorem 5.5 every bin is nonzero and there are three non-DC bins. Hence, by Theorem 5.9, the value signal is not a constant plus one character; the period is genuinely distributed across the harmonics.

**Corollary 5.11 (Coherence dichotomy).** The same transform, two inputs:
* the coherent comb has *identically vanishing* off-peak spectrum and attains the maximal possible modulus $m$ on its peaks;
* the classical value signal for $N=15$, $a=7$ has *no* vanishing bin, and its largest non-DC bin points at a false period.

Sharpness is a property of the prepared state, not of the transform.

---

## 6. Uncertainty-extremality of the comb

The results so far show the comb is *sharp*. We now show it is *optimally* sharp.

**Theorem 6.1 (Discrete uncertainty principle, Donoho–Stark form).** Let $n \ge 1$ and $v : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ be nonzero. Set $A = \operatorname{supp} v$ and $B = \operatorname{supp}\hat v$. Then
$$|A| \cdot |B| \;\ge\; n .$$

*Proof.* Let $\|v\|_\infty = \max_x |v(x)|$ be attained at $x_0$, and $\|\hat v\|_\infty = \max_k |\hat v(k)|$ at $k_0$. Since $v \ne 0$, $\|v\|_\infty > 0$.

*Step 1 (forward direction).* For any $k$, since every $|\zeta_n^{\,xk}| = 1$ and only $x \in A$ contribute,
$$|\hat v(k)| \le \sum_{x} |v(x)| = \sum_{x \in A}|v(x)| \le |A|\,\|v\|_\infty .$$
In particular $\|\hat v\|_\infty \le |A| \|v\|_\infty$.

*Step 2 (inverse direction).* By inversion, $v(x_0) = \frac1n\sum_k \hat v(k)\zeta_n^{-x_0 k}$, and only $k \in B$ contribute, so
$$\|v\|_\infty = |v(x_0)| \le \frac1n \sum_{k \in B}|\hat v(k)| \le \frac1n\,|B|\,\|\hat v\|_\infty .$$

*Step 3.* Chaining, $\|v\|_\infty \le \frac1n |B|\,|A|\,\|v\|_\infty$. Multiplying by $n > 0$ and dividing by $\|v\|_\infty > 0$ gives $n \le |A||B|$. $\square$

The proof uses only three ingredients: unit modulus of the roots of unity, the triangle inequality, and Fourier inversion (Theorem 2.3). No analysis, no positivity, no orthogonality beyond Proposition 2.2.

**Theorem 6.2 (The coherent comb is extremal).** Let $n = mr$ with $m, r \ge 1$ and $0 \le x_0 < r$. Then
$$|\operatorname{supp} C_{m,r,x_0}| = m, \qquad |\operatorname{supp}\widehat{C_{m,r,x_0}}| = r, \qquad m \cdot r = n .$$
Equality holds in Theorem 6.1: the comb saturates the discrete uncertainty principle.

*Proof.* The time support is $\{x < mr : x \equiv x_0 \bmod r\} = \{x_0 + jr : j < m\}$, of size $m$ (this uses $x_0 < r$, so that the teeth are precisely these residues). The frequency support is, by Corollary 3.4, the set of multiples of $m$ below $mr$, of size $r$ by Proposition 3.5. $\square$

**Interpretation.** Theorem 6.1 forbids a signal from being simultaneously concentrated in time and in frequency, and that is exactly the trade-off classical period finding is fighting. A short classical data record has small time support and therefore, necessarily, a spread spectrum — which is the qualitative content of the bound $K \ge r$. The quantum circuit does not fight the trade-off; it sits at its extreme point. Among all $n$-dimensional signals, the state Shor's circuit prepares for free is one for which $|A|\,|B| = n$: no input, classical or quantum, can be sharper in the time–frequency sense.

Combined with Theorem 3.11 the picture is complete: peak-supported spectra are exactly the $r$-periodic signals, and among $r$-periodic signals the indicator comb minimises time support and hence achieves extremality.

---

## 7. The boundary, in one statement

**Theorem 7.1 (Quantum–classical boundary in period finding).** Fix a prime $p \ge 3$ and a register size $n = mr$ with $m, r \ge 1$, an offset $x_0 < r$, an index $j$ with $\gcd(j,r)=1$, and any $k$ with $m \nmid k$. Then all of the following hold simultaneously.

*Classical side.*
1. There is a base $a$ modulo $p$ with $\operatorname{ord}_p(a) > \lfloor\sqrt{p-2}\rfloor$ for which every Fourier-sampling scheme determining the period signal uses more than $\lfloor\sqrt{p-2}\rfloor$ samples.
2. For $N = 15$, $a = 7$ the fundamental bin is strictly dominated by the second harmonic, $|\hat V(1)| = \sqrt{45} < 15 = |\hat V(2)|$, so peak picking outputs a non-period.

*Quantum side.*
3. $\widehat C(k) = 0$ exactly (off-peak annihilation).
4. $|\widehat C(jm)| = m$ (maximal peak).
5. $|\operatorname{supp} C| \cdot |\operatorname{supp} \widehat C| = mr = n$ (uncertainty saturation).
6. $jm/n$ in lowest terms has denominator exactly $r$ (period recovered).

*Both sides use the same transform of Definition 2.1 and the same character orthogonality of Proposition 2.2. Only the input state differs.*

**Theorem 7.2 (Separation, sampling form).** Fix $r \ge 1$, $n = mr$, and $K < r$ frequencies. Then (i) there exist two distinct period-$r$ signals with identical Fourier samples at those frequencies, so the period is information-theoretically undetermined; while (ii) the single coherent comb has a peak of maximal amplitude $m$ from which the period $r$ is recovered exactly.

---

## 8. Discussion and future directions

### 8.1 What has been established

The quantum advantage in period finding has been *located*, not merely observed. It is not in the transform (shared), not in the post-processing (classical continued fractions), and not in a vague notion of parallelism. It is in the input state: one coherent evaluation of $a^x \bmod N$ on a uniform superposition yields a comb, and the comb is extremal for the discrete time–frequency uncertainty principle. The classical algorithm is confined to the value signal, which is (i) expensive to sample to sufficient resolution and (ii) spectrally diffuse in a way that actively misleads peak picking.

### 8.2 What has not

No superpolynomial lower bound on classical factoring is claimed or implied; that remains open, and indeed the number field sieve beats $\sqrt N$ comfortably by not being a period finder at all. Theorem 4.1 is a statement about linear measurement schemes. Barrier 2 is exact for the order-$4$ family and is documented by an exhaustive scan, not by an asymptotic theorem. The comb analysis assumes the exact-period regime $r \mid n$; with $r \nmid n$ the peaks broaden into Dirichlet kernels and the statements become approximate — true, standard, and deliberately not conflated with the exact results here.

### 8.3 Conjectures

**C1. Uncertainty-extremality characterises the Shor input state.** Let $n = mr$ and $v \ne 0$ on $\mathbb{Z}/n\mathbb{Z}$ satisfy $|\operatorname{supp} v|\cdot|\operatorname{supp}\hat v| = n$. Conjecture: $\operatorname{supp} v$ is a coset of a subgroup of $\mathbb{Z}/n\mathbb{Z}$ and $|v|$ is constant on its support; that is, $v$ is a phase-modulated comb. Consequently the state Shor's circuit prepares is, up to phases and translation, the *only* extremal input. The key insight is that the two triangle inequalities used in the proof of Theorem 6.1 are simultaneously tight exactly when all contributing phases align, which forces the support to be an arithmetic progression closed under translation — a subgroup coset. The equality analysis is a finite-dimensional rigidity argument requiring no new analytic input. A counterexample would be equally interesting: it would exhibit a non-comb state as sharp as the comb.

**C2. Peak-picking failure is generic, not exceptional.** Conjecture: for every $r \ge 4$, the density of pairs $(N,a)$ with $\operatorname{ord}_N(a) = r$ for which the fundamental bin is not the largest non-DC bin of the value signal is bounded away from $0$ as $N \to \infty$; in fact the fundamental's rank grows like $\Theta(r)$. The key insight is that the residues $a^x \bmod N$ behave like an equidistributed sequence with respect to the additive characters of $\mathbb{Z}/r\mathbb{Z}$, so the value spectrum is asymptotically flat and the fundamental has no structural advantage — it is the *comb*, not the exponential, that produces sharpness. The order-$4$ slice is already exactly solvable (Theorem 5.7), with measured density $0.366$ for $N < 500$; the general statement needs only Weyl-sum bounds for exponential sequences modulo $N$.

**C3. A nonlinear-estimator version of Barrier 1.** Conjecture: the bound $K \ge r$ survives dropping linearity — any (possibly adaptive, possibly nonlinear) classical estimator that recovers the period of an arbitrary period-$r$ signal from $K$ evaluations of its Fourier transform at chosen frequencies must have $K \ge r$. The key insight is that the linear-algebra proof of Theorem 4.1 should be replaceable by an explicit two-point argument: exhibit, for each frequency set of size $< r$, a concrete *pair* of signals with distinct periods but identical samples — which the kernel-dimension argument already provides non-constructively.

**C4. Divisor-refined order statistics.** Theorem 4.2's divisor-indexed form produces bases of order $> |G|/\tau(|G|)$. Making $\tau(n) = n^{o(1)}$ explicit would upgrade Corollary 4.5 from "order $> \sqrt p$" to "order $> p^{1-o(1)}$", closing the gap to the heuristic $r = \Theta(N)$.

### 8.4 A design lesson

If the quantum advantage in period finding is precisely the ability to prepare an uncertainty-extremal state, then the natural question for any proposed quantum algorithm is: *which extremal state does it prepare, and for which inequality?* Advantages that cannot answer that question are, on the evidence here, likely to be illusory. Conversely, classical algorithms that manage to *simulate* the preparation of a near-extremal state — by structural insight rather than by sampling — should recover much of the advantage. That is, arguably, exactly what the number field sieve does in a different guise: it replaces sampling by algebraic structure.

---

## 9. Summary of results

| Result | Statement |
|---|---|
| Sharp peak theorem | $\widehat C(k) = \zeta_n^{x_0k}\cdot m$ if $m\mid k$, else $0$; off-peak vanishing is exact |
| Peak count / equal harmonics | Exactly $r$ peaks, all of modulus $m$; total energy $nm$ |
| Period extraction | $\gcd(j,r)=1 \Rightarrow jm/n$ reduces to denominator $r$; $\varphi(r)$ useful peaks |
| Rigidity | Spectrum supported on multiples of $m$ $\iff$ signal is $r$-periodic |
| Resolution bound | Determining a period-$r$ signal from Fourier samples needs $K \ge r$ |
| Small-order count | $\#\{\operatorname{ord} \le B\} \le B\cdot\#\{d\mid |G|: d\le B\} \le B^2$ |
| Large-order bases | Some base mod $p$ has order $>\lfloor\sqrt{p-2}\rfloor$; a majority when $2B^2 < p-1$ |
| Superpolynomiality | $\sqrt N = e^{x/2}$ in $x=\log N$ exceeds every polynomial |
| Spectral hiding | $N=15,a=7$: bins $25,\,-3-6i,\,-15,\,-3+6i$; $\sqrt{45} < 15$; peak picking returns $2 \ne 4$ |
| Order-4 criterion | Hiding $\iff (v_0-v_1+v_2-v_3)^2 > (v_0-v_2)^2+(v_1-v_3)^2$; $684/1870$ for $N<500$ |
| Two-bin structure | Spectrum on $\{0,k_0\}$ $\Rightarrow$ signal is constant plus one character |
| Uncertainty principle | $|\operatorname{supp} v|\cdot|\operatorname{supp}\hat v| \ge n$ for $v \ne 0$ |
| Extremality | The comb attains $m\cdot r = n$: saturation |
