# Branch Densities Decide Cancellation: A Spectral Theory of the $an+1$ Maps

**Author:** Aristotle

**Date:** 2026-08-19

---

## Abstract

We develop a spectral theory for the one-step and two-step exponential sums attached to the accelerated $an+1$ maps ($a$ odd), of which the Collatz map $a=3$ is the classical case. For a map $T$ we study the cutoff transform $F(\omega,N)=\sum_{n\le N} e(\omega\, T(n)/n)$ with $e(x)=e^{2\pi i x}$, and its normalisation $F(\omega,N)/N$.

Our main structural result is the **Dominant-Branch Principle**: if the index set carries a subset of asymptotic density $d>1/2$ along which the phase ratios converge to a single limit, then for every real frequency $\omega$ and every $c<2d-1$ one has $\|F(\omega,N)\| \ge cN$ for all large $N$. Destructive interference is impossible above the density threshold $1/2$; and the threshold is sharp, as the classical Collatz map itself demonstrates.

We derive three consequences. (i) **Depth-two spectrum.** A parity analysis modulo $4$ shows that the two-step phase ratio has branch weights $1/4$ and $3/4$; the limiting amplitude is $A_2(\omega)=(e(\omega/4)+3e(a\omega/2))/4$, satisfying $|A_2(\omega)|^2 = (10+6\cos(\pi(2a-1)\omega/2))/16 \ge 1/4$ with equality attained. Hence $\|F_2(\omega,N)\|\ge N/4$ eventually, at every frequency: the depth-one resonances are destroyed by iteration. (ii) **$b$-adic family.** For the map $n\mapsto n/b$ ($b\mid n$), $n\mapsto an+1$ (otherwise) with $b\ge 3$, the one-step transform obeys $\|G_b(\omega,N)\|\ge \frac{b-2}{2b}N$ eventually at every frequency, with the sharp constant $1-2/b$ up to any $\varepsilon>0$; halving is therefore the unique resonant base. (iii) **Averaged statistics.** The mean-square power over a period equals the sum of squared branch weights, $1/2$ at depth one and $5/8$ at depth two, independently of $a$; with explicit finite-$N$ error $8(1+8\pi(1+\log N))/N$, so that the depth-two power eventually exceeds the depth-one power by at least $1/4$. A Chebyshev bound confines the frequencies where $\|F(\omega,N)\|\ge \lambda N$ to measure $\le (2+8\varepsilon_N)/\lambda^2$ in a period.

The overall conclusion is that spectral cancellation for these maps is governed entirely by branch densities, not by the arithmetic of the multiplier, and that no pointwise smallness statement over irrational frequencies can hold.

**Keywords:** Collatz map, exponential sums, branch densities, destructive interference, Terras parity vectors, mean-square power, spectral gap.

---

## 1. Introduction

### 1.1 Motivation

The Collatz map sends $n \mapsto n/2$ for even $n$ and $n \mapsto 3n+1$ for odd $n$; the conjecture that every orbit reaches $1$ is open. A recurring strategy is to study the map through a Fourier-analytic or "spectral" lens, replacing the irregular integer dynamics by a wave-interference problem: attach a unit phase to each integer, sum over a range, and read off the frequencies at which the sum is small (destructive interference, a *spectral gap*) or large (constructive interference, a *resonant peak*).

Such programmes have an appealing physical interpretation. The sum $F(\omega,N)$ is a *structure factor*: it is precisely the quantity one computes when predicting a diffraction pattern from a scattering medium whose scatterers sit at positions determined by the phase sequence. Dark bands in a diffraction pattern — *systematic absences* — encode symmetry in crystallography, so it is natural to hope that dark bands in the Collatz structure factor encode arithmetic.

The purpose of this paper is to determine exactly what these dark bands encode. The answer is sharply negative for arithmetic and sharply positive for a simple combinatorial mechanism: **cancellation is decided by branch densities alone**. We formulate this as a general principle with an explicit constant, prove that its density threshold is optimal, and use it to settle the structure of the depth-two spectrum and of an entire family of $b$-adic variants.

### 1.2 Summary of results

Throughout, $e(x):=e^{2\pi i x}$ and $\|\cdot\|$ is the complex modulus. For a real sequence $r:\mathbb{N}\to\mathbb{R}$ we write
$$\mathcal{F}[r](\omega,N) \;=\; \sum_{k=0}^{N-1} e\big(\omega\, r(k+1)\big) \;=\; \sum_{n=1}^{N} e\big(\omega\, r(n)\big).$$

1. **Dominant-Branch Principle (Theorem 3.4).** If $D\subseteq\mathbb{N}$ has asymptotic density $d$, the phases $r(n)$ converge to $\theta$ along $D$, and $c<2d-1$, then for every $\omega\in\mathbb{R}$, $\|\mathcal{F}[r](\omega,N)\|\ge cN$ for all sufficiently large $N$. In particular, if $d>1/2$ the transform has linear size at every frequency.
2. **Sharpness (Theorem 3.8).** For $a=3$ and $\omega=1/5$, the odd integers form a branch of density exactly $1/2$ with convergent phases, yet $\mathcal{F}(\omega,N)=o(N)$; so the conclusion fails for every $c>0$. The threshold $d>1/2$ cannot be weakened to $d\ge 1/2$.
3. **Depth-two spectrum (Theorems 4.3–4.7).** With $A_2(\omega)=(e(\omega/4)+3e(a\omega/2))/4$ we have $\|F_2(\omega,N)/N - A_2(\omega)\| \le (2+2\pi|\omega|(1+\log N))/N$, $\|A_2(\omega)\|^2=(10+6\cos(\pi(2a-1)\omega/2))/16$, $\|A_2(\omega)\|\ge 1/2$ with equality at $\omega=2/(2a-1)$, and consequently $\|F_2(\omega,N)\|\ge N/4$ eventually at every $\omega$.
4. **$b$-adic no-resonance (Theorems 5.2–5.4).** For $b\ge 3$ and any $a$, at every $\omega$: $\|G_b(\omega,N)\|\ge\frac{b-2}{2b}N$ eventually, and $\|G_b(\omega,N)\|\ge (1-2/b-\varepsilon)N$ eventually for every $\varepsilon>0$. Base $2$ is the unique base admitting a spectral gap.
5. **Averaged theory (Theorems 6.1–6.6).** Exact mean-square identities $\int_0^4\|A(\omega)\|^2 d\omega = 2$ and $\int_0^4\|A_2(\omega)\|^2 d\omega = 5/2$ for all $a$; finite-$N$ versions with error $8\varepsilon_N$; the depth separation $\int_0^4\|F_2/N\|^2 \ge \int_0^4\|F/N\|^2 + 1/4$ eventually; and the Chebyshev peak bound.

### 1.3 What the results rule out

Two natural conjectures are eliminated.

*The pointwise programme.* One might hope for a statement of the form "$F(\omega,N)=o(N)$ for all irrational $\omega$". This is false, and false for a soft reason: $\omega\mapsto F(\omega,N)$ is continuous, and $F(0,N)=N$, so $\|F(\omega,N)\|$ is close to $N$ for all $\omega$ in a neighbourhood of $0$, irrationals included. The same happens near every even integer frequency. Any correct global statement must either exclude neighbourhoods of the integer resonances or pass to averages. Section 6 does the latter.

*The arithmetic programme.* One might hope that the depth-one resonance set $\{\omega : (2a-1)\omega \in 2\mathbb{Z}+1\}$ is a fingerprint distinguishing the $3n+1$, $5n+1$ and $7n+1$ maps in a dynamically meaningful way. Sections 4 and 5 show this reading is untenable: the resonances disappear at depth two and disappear for every base $b\ge 3$, while the averaged statistics that do survive are completely independent of $a$.

---

## 2. Setup and definitions

**Definition 2.1 (Character).** For $x\in\mathbb{R}$ let $e(x) := e^{2\pi i x} \in \mathbb{C}$. Then $\|e(x)\|=1$, $e(x+y)=e(x)e(y)$, $\operatorname{Re} e(x)=\cos 2\pi x$, $\operatorname{Im} e(x)=\sin 2\pi x$, and the elementary Lipschitz bound
$$\|e(x)-1\| \;\le\; 2\pi |x| \qquad (x\in\mathbb{R}) \tag{2.1}$$
holds, since $\|e(x)-1\| = 2|\sin \pi x| \le 2\pi|x|$.

**Definition 2.2 (One-step map and ratio).** Fix an odd integer $a\ge 1$. The accelerated $an+1$ map is
$$T_a(n) \;=\; \begin{cases} n/2, & n \equiv 0 \pmod 2,\\ a n + 1, & n\equiv 1 \pmod 2,\end{cases}$$
and its *phase ratio* is $\rho_a(n) := T_a(n)/n$ for $n\ge 1$.

**Definition 2.3 (Generic transform).** For $r:\mathbb{N}\to\mathbb{R}$, $\omega\in\mathbb{R}$ and $N\in\mathbb{N}$,
$$\mathcal{F}[r](\omega,N) := \sum_{k=0}^{N-1} e(\omega\, r(k+1)).$$
We write $F(a,\omega,N):=\mathcal{F}[\rho_a](\omega,N)$ for the one-step Collatz-type transform.

**Definition 2.4 (Density of a branch).** A predicate $D$ on $\mathbb{N}$ has *asymptotic density* $d$ if
$$\frac{\#\{k < N : D(k)\}}{N} \longrightarrow d \qquad (N\to\infty).$$

**Proposition 2.5 (Depth-one branches).** For $n$ even, $\rho_a(n)=1/2$ exactly. For $n$ odd, $\rho_a(n)=a+1/n$. Hence the phase takes the limiting values $1/2$ and $a$, each along a branch of density $1/2$.

**Theorem 2.6 (Depth-one normalisation).** With $A(a,\omega) := \tfrac12\big(e(\omega/2)+e(a\omega)\big)$ we have $F(a,\omega,N)/N \to A(a,\omega)$ for every $\omega$, and
$$\|A(a,\omega)\| \;=\; \Big|\cos\Big(\pi\Big(a-\tfrac12\Big)\omega\Big)\Big| \;=\; \Big|\cos\Big(\tfrac{\pi(2a-1)\omega}{2}\Big)\Big|.$$

*Proof sketch.* Replace each summand by its branch model ($e(\omega/2)$ for even $n$, $e(a\omega)$ for odd $n$). By (2.1) the deviation at index $n$ is at most $2\pi|\omega|/n$ on the odd branch and $0$ on the even branch, so the total deviation is $O(|\omega|\log N)$, which is $o(N)$. Counting the two branches gives the stated limit. Factoring $e((\omega/2+a\omega)/2)$ out of the sum of two unimodular terms yields the cosine modulus. $\square$

**Corollary 2.7 (Depth-one resonance set).** $A(a,\omega)=0$ if and only if $(2a-1)\omega$ is an odd integer. For $a=3$ the smallest positive resonance is $\omega=1/5$, where $F(3,1/5,N)/N\to 0$.

This is the extinction phenomenon whose fragility is the subject of the paper.

---

## 3. The Dominant-Branch Principle

The following is the structural core of the work: a criterion, in terms of density alone, guaranteeing that an exponential sum of unimodular terms cannot cancel.

### 3.1 The deviation sequence

**Definition 3.1.** Given $r:\mathbb{N}\to\mathbb{R}$, a target phase $\theta$, a frequency $\omega$ and a branch predicate $D$, define the *deviation sequence*
$$\delta(k) \;=\; \begin{cases} e(\omega\, r(k+1)) - e(\omega\theta), & D(k),\\ 0, & \text{otherwise.}\end{cases}$$

**Lemma 3.2 (Deviation bound).** For all $k$,
$$\|\delta(k)\| \;\le\; 2\pi|\omega| \cdot \big| \mathbb{1}_{D(k)}\,(r(k+1)-\theta) \big|.$$

*Proof.* On $D$, factor $e(\omega r(k+1)) - e(\omega\theta) = e(\omega\theta)\big(e(\omega(r(k+1)-\theta)) - 1\big)$; the first factor is unimodular and the second is bounded by (2.1). Off $D$ the deviation vanishes. $\square$

### 3.2 The finite-$N$ decomposition

**Lemma 3.3 (Split bound).** Let $c_N := \#\{k<N : D(k)\}$ and $S_N := \sum_{k<N}\delta(k)$. Then for every $N$,
$$\big\|\mathcal{F}[r](\omega,N)\big\| \;\ge\; 2c_N - N - \|S_N\|.$$

*Proof.* Split the sum over $\{k<N\}$ into the part on $D$ and the part off $D$. On $D$ each summand equals $e(\omega\theta)+\delta(k)$, so the $D$-part equals $c_N\, e(\omega\theta) + S_N$. The off-$D$ part $T_N$ is a sum of $N-c_N$ unimodular terms, hence $\|T_N\|\le N-c_N$. Therefore
$$c_N = \big\| c_N e(\omega\theta)\big\| = \big\|\mathcal{F}[r](\omega,N) - (S_N+T_N)\big\| \le \|\mathcal{F}[r](\omega,N)\| + \|S_N\| + \|T_N\|,$$
and rearranging with $\|T_N\|\le N-c_N$ gives the claim. $\square$

The geometry is transparent: a block of $c_N$ nearly aligned arrows has length nearly $c_N$; the remaining $N-c_N$ arrows can subtract at most $N-c_N$; the surplus is $2c_N-N$.

### 3.3 The principle

**Theorem 3.4 (Dominant-Branch Principle).** Let $r:\mathbb{N}\to\mathbb{R}$, $\theta,\omega,d,c\in\mathbb{R}$ and let $D$ be a branch predicate. Assume

- (density) $\dfrac{\#\{k<N: D(k)\}}{N} \to d$;
- (phase alignment) $\mathbb{1}_{D(k)}\big(r(k+1)-\theta\big) \to 0$ as $k\to\infty$;
- (threshold) $c < 2d-1$.

Then for all sufficiently large $N$,
$$\big\|\mathcal{F}[r](\omega,N)\big\| \;\ge\; c\,N.$$

*Proof sketch.* By Lemma 3.2 and phase alignment, $\delta(k)\to 0$; by the Cesàro theorem, $\frac1N\sum_{k<N}\delta(k) \to 0$, hence $\|S_N\|/N \to 0$. Dividing Lemma 3.3 by $N$,
$$\frac{\|\mathcal{F}[r](\omega,N)\|}{N} \;\ge\; 2\frac{c_N}{N} - 1 - \frac{\|S_N\|}{N} \;\longrightarrow\; 2d-1.$$
Since $c<2d-1$, the left-hand side exceeds $c$ eventually. $\square$

Note that the conclusion is uniform in $\omega$ in the strongest possible sense: it holds for *every* real frequency, with a constant independent of $\omega$. The frequency enters only through the deviation bound, which is annihilated by the Cesàro average.

**Corollary 3.5 (Convenient form).** If $d>1/2$, then for every $\omega$, eventually $\|\mathcal{F}[r](\omega,N)\| \ge \frac{2d-1}{2}\,N$.

*Proof.* Apply Theorem 3.4 with $c=(2d-1)/2 < 2d-1$. $\square$

### 3.4 Densities of residue classes

The criterion needs densities, and the branches we use are residue classes.

**Lemma 3.6 (Exact count).** For all $b,N$, $\#\{k<N : (k+1)\equiv 0 \bmod b\} = \lfloor N/b\rfloor$.

*Proof.* Induction on $N$: passing from $N$ to $N+1$ increases the count by $1$ exactly when $b \mid N+1$, which is exactly when $\lfloor (N+1)/b\rfloor = \lfloor N/b\rfloor + 1$. $\square$

**Lemma 3.7 (Density).** For $b\ge 1$, $\dfrac{\#\{k<N:(k+1)\equiv 0 \bmod b\}}{N} \to \dfrac1b$, with the explicit rate $\Big|\dfrac{\lfloor N/b\rfloor}{N} - \dfrac1b\Big| \le \dfrac1N$.

*Proof.* Write $N = bq+s$ with $0\le s<b$ and $q=\lfloor N/b\rfloor$. Then $|q/N - 1/b| = |bq-N|/(bN) = s/(bN) \le 1/N$. $\square$

### 3.5 Sharpness of the threshold

**Theorem 3.8 (The threshold $d>1/2$ is optimal).** Consider $a=3$, the branch $D=\{k : k+1 \text{ odd}\}$ and $\theta = 3$. Then:

- $D$ has density exactly $1/2$;
- $\mathbb{1}_{D(k)}(\rho_3(k+1) - 3) \to 0$ (indeed the deviation is $1/(k+1)$ on $D$);
- yet for $\omega=1/5$ and **every** $c>0$ it is *false* that $\|\mathcal{F}[\rho_3](1/5,N)\|\ge cN$ eventually, because $\mathcal{F}[\rho_3](1/5,N)/N \to A(3,1/5) = 0$ by Corollary 2.7.

Hence the hypothesis $d>1/2$ cannot be relaxed to $d \ge 1/2$: at the balance point, total cancellation genuinely occurs.

This is the precise sense in which the Collatz spectral gap is a *balance* phenomenon. It sits exactly on the knife edge of the criterion.

---

## 4. The depth-two spectrum: resonances are destroyed by iteration

### 4.1 Terras branches modulo 4

Let $T_a^2 = T_a\circ T_a$ and $\rho^{(2)}_a(n) := T_a^2(n)/n$.

**Proposition 4.1 (Three-branch decomposition).** Let $a$ be odd and $n\ge 1$.

- If $n\equiv 0 \pmod 4$ then $T_a^2(n)=n/4$, so $\rho^{(2)}_a(n) = 1/4$ exactly.
- If $n\equiv 2 \pmod 4$ then $n/2$ is odd, so $T_a^2(n) = a n/2 + 1$ and $\rho^{(2)}_a(n) = a/2 + 1/n$.
- If $n$ is odd then $an+1$ is even (as $a n$ is odd), so $T_a^2(n) = (an+1)/2$ and $\rho^{(2)}_a(n) = a/2 + 1/(2n)$.

The oddness of $a$ is essential in the third case: it is what makes $an+1$ even and lets the second step be a halving.

**Corollary 4.2 (Branch weights).** The limiting phases are $1/4$, with density $1/4$ (the class $n\equiv 0$), and $a/2$, with density $1/4 + 1/2 = 3/4$ (the classes $n\equiv 2 \bmod 4$ and $n$ odd, which *coalesce* onto the same limit). The weights are unbalanced.

This coalescence is the mechanism. At depth one the two limiting phases $1/2$ and $a$ are distinct and equally weighted; at depth two, two of the three Terras classes share the limit $a/2$ and their densities add.

### 4.2 Convergence with explicit error

**Definition.** $F_2(a,\omega,N) := \mathcal{F}[\rho^{(2)}_a](\omega,N)$ and
$$A_2(a,\omega) \;:=\; \frac{e(\omega/4) + 3\,e(a\omega/2)}{4}.$$

**Theorem 4.3 (Explicit error bound).** For $a$ odd, $\omega\in\mathbb{R}$ and $N\ge 1$,
$$\Big\| \frac{F_2(a,\omega,N)}{N} - A_2(a,\omega) \Big\| \;\le\; \frac{2 + 2\pi|\omega|\big(1+\log N\big)}{N}.$$

*Proof sketch.* Compare each summand with the $4$-periodic model $m(k) = e(\omega/4)$ if $k\equiv 3 \bmod 4$ (i.e. $n=k+1\equiv 0 \bmod 4$) and $m(k)=e(a\omega/2)$ otherwise. By Proposition 4.1 and (2.1) the deviation at index $n$ is at most $2\pi|\omega|/n$, and $\sum_{n\le N} 1/n \le 1+\log N$. Summing the model over a range of length $N$ produces $\lfloor N/4\rfloor$ copies of $e(\omega/4)$ and $N - \lfloor N/4\rfloor$ copies of $e(a\omega/2)$; comparing with the exact weights $N/4$, $3N/4$ costs at most $2$ in absolute value. Dividing by $N$ gives the bound. $\square$

**Theorem 4.4 (Depth-two normalisation).** For $a$ odd and every $\omega$, $F_2(a,\omega,N)/N \to A_2(a,\omega)$.

Note the error bound is uniform in $a$ and locally uniform in $\omega$, which is what makes the mean-square analysis of Section 6 possible.

### 4.3 No depth-two resonance

**Theorem 4.5 (Exact modulus).** For every $a$ and every $\omega$,
$$\|A_2(a,\omega)\|^2 \;=\; \frac{10 + 6\cos\!\big(\pi(2a-1)\omega/2\big)}{16}.$$

*Proof sketch.* Factor $A_2 = \tfrac14 e(a\omega/2)\big(3 + e(\omega/4 - a\omega/2)\big)$. The first factor is unimodular, and $\|3+e(t)\|^2 = 10 + 6\cos 2\pi t$ by expanding $(3+\cos 2\pi t)^2 + \sin^2 2\pi t$. Substituting $t = \omega/4 - a\omega/2$ and using $2\pi t = -\pi(2a-1)\omega/2$ together with the evenness of cosine gives the formula. $\square$

**Theorem 4.6 (No two-step resonances, sharp).** For every $a$ and every $\omega$, $\|A_2(a,\omega)\| \ge 1/2$; and the bound is attained: $\|A_2(a, 2/(2a-1))\| = 1/2$.

*Proof.* From Theorem 4.5 and $\cos \ge -1$: $\|A_2\|^2 \ge (10-6)/16 = 1/4$. Equality requires $\cos(\pi(2a-1)\omega/2) = -1$, i.e. $(2a-1)\omega/2$ an odd integer; $\omega = 2/(2a-1)$ works. Alternatively, directly: $\|1 + 3e(t)\| \ge 3-1 = 2$ by the reverse triangle inequality, and $A_2 = e(\omega/4)(1+3e(a\omega/2-\omega/4))/4$. $\square$

The two proofs illustrate the two viewpoints: the reverse triangle inequality is the Dominant-Branch Principle in miniature ($3/4$ against $1/4$), while the exact modulus shows that the resulting constant is not merely a bound but the true minimum.

**Theorem 4.7 (Linear size at every frequency).** For $a$ odd and every $\omega\in\mathbb{R}$, for all sufficiently large $N$,
$$\|F_2(a,\omega,N)\| \;\ge\; \tfrac14 N.$$

*Proof.* By Theorem 4.3 the error $(2+2\pi|\omega|(1+\log N))/N$ is eventually $\le 1/4$; combined with $\|A_2\|\ge 1/2$ and the reverse triangle inequality, $\|F_2/N\| \ge 1/2 - 1/4 = 1/4$. $\square$

### 4.4 The contrast

**Theorem 4.8 (Resonance destroyed by iteration).** For the classical Collatz map $a=3$ at the frequency $\omega=1/5$:
$$\frac{F(3,1/5,N)}{N} \longrightarrow 0, \qquad\text{yet}\qquad \|F_2(3,1/5,N)\| \ge \tfrac14 N \text{ eventually}.$$

Thus the depth-one spectral gap at $\omega=1/5$ is not a property of the map's dynamics but of the exact $1/2$–$1/2$ parity balance at depth one. It carries no information stable under iteration. Any programme that reads arithmetic content into these extinctions must explain why the content evaporates after a single additional step of the very map under study.

---

## 5. The $b$-adic family: halving is the unique resonant base

### 5.1 The family

**Definition 5.1.** For integers $b\ge 2$ and $a\ge 1$ let
$$T_{b,a}(n) \;=\; \begin{cases} n/b, & b \mid n,\\ a n + 1, & \text{otherwise},\end{cases}$$
with phase ratio $\rho_{b,a}(n)=T_{b,a}(n)/n$ and transform $G_b(a,\omega,N) := \mathcal{F}[\rho_{b,a}](\omega,N)$. For $b=2$ this is exactly the classical transform: $G_2(a,\omega,N)=F(a,\omega,N)$.

**Proposition 5.1 (Branches).** If $b\mid n$ and $n\neq 0$ then $\rho_{b,a}(n)=1/b$ exactly. Otherwise $\rho_{b,a}(n) = a + 1/n \to a$. The dividing branch has density $1/b$ (Lemma 3.7), so the multiplicative branch has density $1-1/b$.

### 5.2 No resonance for $b \ge 3$

**Theorem 5.2 (No $b$-adic resonance).** Let $b\ge 3$ and $a\ge 1$. Then for every $\omega\in\mathbb{R}$ and all sufficiently large $N$,
$$\|G_b(a,\omega,N)\| \;\ge\; \frac{b-2}{2b}\,N.$$

*Proof.* The multiplicative branch $D=\{k : b \nmid (k+1)\}$ has density $d = 1-1/b \ge 2/3 > 1/2$, and on $D$ the phase $\rho_{b,a}(k+1) = a + 1/(k+1) \to a =: \theta$. Corollary 3.5 gives the constant $(2d-1)/2 = (1-2/b)/2 = (b-2)/(2b)$. $\square$

**Theorem 5.3 (Sharp constant).** Under the same hypotheses, for every $\varepsilon>0$ and all sufficiently large $N$,
$$\|G_b(a,\omega,N)\| \;\ge\; \Big(1 - \tfrac2b - \varepsilon\Big) N .$$

*Proof.* Apply Theorem 3.4 with $c = 1-2/b-\varepsilon < 2d-1 = 1-2/b$. $\square$

The constant $1-2/b$ is precisely the difference of the two branch weights, $(1-1/b) - 1/b$; it is the length of the residual arrow when the minority branch is aimed in the worst possible direction. Numerically the observed minimum of $\|G_b/N\|$ over $\omega$ agrees with $1-2/b$: $1/3$ at $b=3$, $1/2$ at $b=4$, $3/5$ at $b=5$.

### 5.3 The dichotomy

**Theorem 5.4 (Halving is the unique resonant base).**
$$\frac{G_2(3,1/5,N)}{N}\longrightarrow 0, \qquad\text{while}\qquad \forall b\ge 3,\ \forall a,\ \forall\omega:\ \|G_b(a,\omega,N)\| \ge \frac{b-2}{2b}N \text{ eventually}.$$

*Proof.* The first statement is Corollary 2.7 together with $G_2=F$; the second is Theorem 5.2. $\square$

The interpretation is decisive. Along the family of bases, the multiplier $a$ is completely inert: it never determines whether cancellation occurs. Only the base does, and only because the base fixes the density split $1/b$ versus $1-1/b$. Base $2$ is the unique base for which that split is balanced, $1/2$ versus $1/2$, and balance is exactly the knife edge identified in Theorem 3.4. The spectral gaps of the $an+1$ maps are a phenomenon of *halving*.

---

## 6. Averaged spectral statistics

### 6.1 Why averaging is forced

Any statement of the form "$\|F(a,\omega,N)\| = o(N)$ for all irrational $\omega$" is false. Indeed $\omega\mapsto F(a,\omega,N)$ is continuous (a finite sum of continuous functions) and $F(a,0,N)=N$; hence for each fixed $N$ there is a neighbourhood of $0$ on which $\|F\| \ge N/2$, and that neighbourhood contains irrationals. The same argument applies near every $\omega$ where $A(a,\omega)$ has modulus $1$, i.e. at the even integers. Continuity alone kills the pointwise programme. The correct replacements are (i) statements on compact frequency sets bounded away from the resonant peaks, and (ii) averaged statements. We develop the latter.

### 6.2 Mean-square power

The natural period is $[0,4]$: both $\|A(a,\cdot)\|^2$ and $\|A_2(a,\cdot)\|^2$ are cosines with argument an integer multiple of $\pi/2$ times $\omega$, so they integrate to their mean over $[0,4]$.

**Theorem 6.1 (Depth-one power).** For every $a$, $\displaystyle \int_0^4 \|A(a,\omega)\|^2\,d\omega = 2$, i.e. the mean over a period is $1/2$.

*Proof sketch.* $\|A(a,\omega)\|^2 = \cos^2(\pi(a-\tfrac12)\omega) = \tfrac12 + \tfrac12\cos(\pi(2a-1)\omega)$. Since $2a-1$ is an integer, the cosine has argument $\pi m \omega$ with $m=2a-1$, and $\int_0^4 \cos(\pi m\omega)\,d\omega = \sin(4\pi m)/(\pi m) = 0$. $\square$

**Theorem 6.2 (Depth-two power).** For every $a$, $\displaystyle \int_0^4 \|A_2(a,\omega)\|^2\,d\omega = \frac52$, i.e. the mean over a period is $5/8$.

*Proof sketch.* By Theorem 4.5, $\|A_2\|^2 = \tfrac58 + \tfrac38\cos\big(\tfrac{\pi(2a-1)}{2}\omega\big)$, and the cosine again integrates to zero over $[0,4]$ since $\tfrac{2a-1}{2}\cdot 4 = 2(2a-1)$ is an even integer. $\square$

**Remark 6.3 (Power = sum of squared weights).** Both values are the squared $\ell^2$-norm of the branch weight vector: $(\tfrac12)^2+(\tfrac12)^2 = \tfrac12$ at depth one; $(\tfrac14)^2+(\tfrac34)^2 = \tfrac58$ at depth two. This is exactly Parseval: when the limiting phases are pairwise distinct, the cross terms are pure oscillations and average to zero, leaving the sum of squares.

**Theorem 6.4 (Depth detected, multiplier invisible).** For all $a,a'$,
$$\int_0^4\|A(a,\omega)\|^2 d\omega \;=\; \int_0^4\|A(a',\omega)\|^2 d\omega \;<\; \int_0^4\|A_2(a',\omega)\|^2 d\omega .$$
The mean-square power strictly increases with iteration depth from $1$ to $2$, by the same amount for every multiplier, and is identical across multipliers at fixed depth.

### 6.3 Finite-$N$ mean-square identities

Set
$$\varepsilon_N := \frac{1+8\pi(1+\log N)}{N}, \qquad \varepsilon'_N := \frac{2+8\pi(1+\log N)}{N},$$
both tending to $0$.

**Theorem 6.5 (Finite-$N$ power, with error).** For every $a$ and $N\ge 1$,
$$\Big| \int_0^4 \Big\|\frac{F(a,\omega,N)}{N}\Big\|^2 d\omega - 2 \Big| \;\le\; 8\varepsilon_N,$$
and for $a$ odd,
$$\Big| \int_0^4 \Big\|\frac{F_2(a,\omega,N)}{N}\Big\|^2 d\omega - \frac52 \Big| \;\le\; 8\varepsilon'_N.$$

*Proof sketch.* Both $\|F/N\|$ and $\|A\|$ are bounded by $1$, so $\big|\,\|x\|^2-\|y\|^2\,\big| \le 2\|x-y\|$ for $\|x\|,\|y\|\le 1$. Insert the uniform-in-$\omega$ error bound of Theorem 4.3 (and its depth-one analogue) valid for $|\omega| \le 4$, integrate over the interval of length $4$, and use Theorems 6.1–6.2. $\square$

**Theorem 6.6 (Averaged separation of depth).** For every odd $a$, for all sufficiently large $N$,
$$\int_0^4 \Big\|\frac{F_2(a,\omega,N)}{N}\Big\|^2 d\omega \;\ge\; \int_0^4 \Big\|\frac{F(a,\omega,N)}{N}\Big\|^2 d\omega \;+\; \frac14 .$$

*Proof.* Both errors are eventually $\le 1/8$; then the depth-two integral is $\ge 5/2 - 1/8$ and the depth-one integral is $\le 2 + 1/8$, and $5/2-1/8 - (2+1/8) = 1/4$. $\square$

Unlike the pointwise resonances, this separation is robust: it is a genuine, computable discriminator between iteration depths, valid at finite $N$ with explicit constants.

### 6.4 Confining the peaks

**Theorem 6.7 (Chebyshev bound for the peak set).** For every $a$, every threshold $\lambda>0$ and every $N\ge 1$,
$$\big|\{\omega \in [0,4] : \|F(a,\omega,N)\| \ge \lambda N\}\big| \;\le\; \frac{2 + 8\varepsilon_N}{\lambda^2},$$
where $|\cdot|$ is Lebesgue measure.

*Proof sketch.* Let $g(\omega)=\|F(a,\omega,N)/N\|$, a continuous function bounded by $1$. On the super-level set $S_\lambda = \{\omega\in[0,4]: g\ge\lambda\}$ we have $\lambda^2 |S_\lambda| \le \int_{S_\lambda} g^2 \le \int_0^4 g^2 \le 2 + 8\varepsilon_N$ by Theorem 6.5. $\square$

**Corollary 6.8 (Trivial-size frequencies occupy at most half a period).** For every $a$ and every $\eta>0$, for all sufficiently large $N$,
$$\big|\{\omega\in[0,4] : \|F(a,\omega,N)\| \ge N\}\big| \;\le\; 2 + \eta .$$

*Proof.* Take $\lambda=1$ in Theorem 6.7 and use $8\varepsilon_N \to 0$. $\square$

This is the corrected replacement for the impossible pointwise claim: the transform can attain its trivial size $N$, but only on a set of frequencies occupying at most half of the period $[0,4]$ (up to $\eta$), for large $N$. Such a statement is fully compatible with isolated resonant peaks at the even integers, which a pointwise bound is not.

---

## 7. Algorithms

Three computational primitives underlie the numerical corroboration of the theory.

**(A) Direct transform evaluation.** Given $a$, $\omega$, $N$ and a depth $L$, compute $\sum_{n=1}^N e(\omega\, T_a^L(n)/n)$ by iterating the map $L$ times per integer. Cost $O(NL)$ time, $O(1)$ memory. Numerically stable if the phase is reduced modulo $1$ before exponentiating, since $T_a^L(n)/n$ stays bounded by $a^L$.

**(B) Branch-weight extraction.** Given $a$ and $L$, determine the limiting phase of $T_a^L(n)/n$ for each residue $n \bmod 2^L$: the Terras parity vector of $n$ is a function of $n \bmod 2^L$, so exactly the residues determine the sequence of halvings and multiplications, and the limiting ratio is the product of the corresponding factors ($1/2$ per halving, $a$ per multiplication) — the additive $+1$ terms contribute $O(1/n)$ and vanish in the limit. Grouping equal limits gives the weight vector; cost $O(2^L L)$. At $L=1$ the weights are $(1/2,1/2)$; at $L=2$, $(1/4,3/4)$; at $L=3$, $(1/8,1/4,5/8)$.

**(C) Mean-square power by quadrature.** Compute $\frac14\int_0^4 \|F/N\|^2 d\omega$ by the trapezoidal or Simpson rule on a uniform grid. Since the integrand is a trigonometric polynomial of bounded degree in $\omega$ for the limiting amplitudes, a modest grid is spectrally accurate; at finite $N$ the error is dominated by the $O(\log N/N)$ term of Theorem 6.5.

Combining (B) with the Dominant-Branch Principle yields an immediate decision procedure: *compute the weight vector; if its maximum exceeds $1/2$, the transform has linear size at every frequency with constant $2\max w - 1$; if the maximum equals $1/2$ and there is a matching second weight, cancellation is possible and the resonance set can be solved for explicitly.*

---

## 8. Discussion

### 8.1 What decides cancellation

The results assemble into a single statement: for transforms built from maps with finitely many limiting phase branches, cancellation is governed by the *weight vector* $w = (w_1,\dots,w_m)$ of branch densities, not by the phases themselves. If $\max_i w_i > 1/2$, no cancellation at any frequency, with explicit constant $2\max_i w_i - 1$. If the weights are balanced with two equal maxima at $1/2$, cancellation is possible, and where it occurs is determined by the phases — which is where the multiplier $a$ finally enters, but only to *locate* the resonances, never to create them.

### 8.2 Three mechanisms

1. **Branch densities decide cancellation.** The Dominant-Branch Principle, with the threshold shown optimal by the Collatz map itself.
2. **Averaging sees depth but not the multiplier.** The mean-square power over a period is the squared $\ell^2$-norm of the weight vector: $1/2$ at depth one, $5/8$ at depth two, uniformly in $a$.
3. **Resonances are not stable under iteration.** Depth-one gaps at $(2a-1)\omega$ odd are destroyed at depth two, where the amplitude is bounded below by $1/2$ everywhere.

### 8.3 Physical reading

In diffraction language, the transform is a structure factor and its dark bands are systematic absences. Systematic absences in crystallography arise from *exact* symmetries of the unit cell — glide planes and screw axes producing pairs of scatterers in antiphase with equal weight. What the results above show is that the Collatz absences have precisely this character: they come from an exact $1/2$–$1/2$ weighting, an "antiphase pair of sublattices", and they disappear the moment the weights are perturbed, whether by iterating the map (weights $1/4$, $3/4$) or by changing the base (weights $1/b$, $1-1/b$). A systematic absence is a statement about the *lattice of scatterers*, not about the chemistry sitting on it; likewise these absences are a statement about parity densities, not about the arithmetic of $3n+1$.

### 8.4 Limitations

The theory treats the one-step and two-step *pointwise-in-$n$* phase ratio $T^L(n)/n$, not orbit-dependent statistics such as total stopping time or hitting-time distributions. Those are genuinely different objects; no implication between an orbit hitting-time estimate and a spectral estimate of the above kind is asserted here, and any such implication would require precise definitions and a directional proof rather than an assumed equivalence. Likewise, the results say nothing about the Collatz conjecture itself: they are structural facts about interference in the associated exponential sums, and their content is largely negative — they close off certain lines of attack while providing an exact tool for others.

---

## 9. Future work

**Conjecture A (depth-$L$ dominance).** For every odd multiplier $a$, every depth $L\ge2$ and every real frequency,
$$\liminf_{N\to\infty} \frac{\|F_L(a,\omega,N)\|}{N} \;\ge\; c_L \;>\; 0,$$
where $F_L$ is the transform of the phase $T_a^L(n)/n$. The mechanism: the Terras parity vector of $n$ is determined by $n \bmod 2^L$, so the depth-$L$ phase takes finitely many limiting values indexed by residues mod $2^L$, weighted by dyadic densities. The classes "at least one halving followed by the multiplicative branch" coalesce, producing one weight strictly above $1/2$ ($3/4$ at $L=2$, $5/8$ at $L=3$), which the Dominant-Branch Principle converts directly into a linear lower bound. What remains is the combinatorial identification of the coalescing classes mod $2^L$ — a finite check for each $L$, plus a recursion in $L$. *Falsifiable:* exhibit a depth $L$ and odd $a$ whose weight vector has no weight above $1/2$, or a frequency where $F_L/N\to0$.

**Remark (a caveat on Conjecture A).** Computing the depth-$L$ weight vectors directly from the residues modulo $2^L$ gives, for every odd $a$ alike,
$$L=1:\ (\tfrac12,\tfrac12);\quad L=2:\ (\tfrac14,\tfrac34);\quad L=3:\ (\tfrac18,\tfrac14,\tfrac58);\quad L=4:\ (\tfrac1{16},\tfrac7{16},\tfrac12);$$
$$L=5:\ (\tfrac1{32},\tfrac18,\tfrac9{32},\tfrac9{16});\quad L=6:\ (\tfrac1{64},\tfrac{11}{64},\tfrac5{16},\tfrac12).$$
The maximal weight is $3/4$, $5/8$, $1/2$, $9/16$, $1/2$ at $L=2,\dots,6$. Thus the Dominant-Branch Principle applies at depths $2,3,5$ but is *silent* at depths $4$ and $6$, where the maximum weight sits exactly at the threshold. Conjecture A therefore needs either a refinement of the criterion (at depth $4$ the two minority weights $1/16$ and $7/16$ would both have to be in exact antiphase with the dominant branch simultaneously, which is two conditions on one frequency and so should fail for all $\omega$) or a different mechanism at the even depths. These weight computations are numerical explorations rather than established facts, and the point at which the criterion goes silent is precisely where care is needed.

**Conjecture B (non-monotone spectral power).** The mean-square power $P_L(a) = \frac14\int_0^4 \|A_L(a,\omega)\|^2 d\omega$ equals the sum of squared branch weights and is **not** monotone in $L$: $P_1 = 1/2 < P_2 = 5/8$, but $P_3 = 15/32 < P_1$, and $P_L\to 0$ as $L\to\infty$. The reason: $P_L$ is the squared $\ell^2$-norm of the weight vector, which is large when the branch structure is unbalanced and disperses as the number of distinct limiting phases grows with $L$; the depth-two bump is a coalescence artefact, not a trend. The exact values at $L=1,2$ are established above; the computed weight vectors give the power sequence $\tfrac12,\ \tfrac58,\ \tfrac{15}{32},\ \tfrac{57}{128},\ \tfrac{211}{512},\ \tfrac{773}{2048}$ for $L=1,\dots,6$ — an initial rise followed by steady decay, consistent with $P_L\to0$. *Falsifiable:* any depth whose measured power breaks the sum-of-squares formula.

**Conjecture C (sharp $b$-adic constant and base dependence).** The constant $1-2/b$ of Theorem 5.3 is the exact minimum of $\lim_N \|G_b(a,\omega,N)\|/N$ over $\omega$, attained where the two branch phases are in antiphase; and the depth-$L$ $b$-adic power equals the sum of squared $b$-adic branch weights, so that the base, not the multiplier, controls all averaged statistics.

**Further directions.**
- Replace the impossible global condition over all irrational frequencies by a condition excluding a fixed neighbourhood of the integer resonances; continuity forces values near the zero-frequency peak to remain near the cutoff $N$.
- Study the normalised transforms $F(\omega,N)/N$ on compact frequency sets bounded away from the resonances, seeking quantitative cancellation estimates uniform in $N$.
- Exploit the explicit even/odd decomposition of the depth-one phase — the even branch contributes the constant phase $1/2$ while the odd branch has phase $a + 1/n$ — for sharper asymptotic estimates than the crude $O(\log N/N)$ error.
- Formulate further averaged statements: $L^p$ bounds over a period, or bounds outside an exceptional set of small measure. Such claims are compatible with isolated resonant peaks in a way that a pointwise bound over all irrationals is not.
- Compare the corrected normalised and averaged statistics for the $3n+1$, $5n+1$ and $7n+1$ maps. Any useful discriminator must depend on more than continuity near frequency zero — and the results here show that the mean-square power is *not* such a discriminator.
- Investigate orbit-dependent transforms separately from the one-step cutoff sum.

---

## 10. Conclusion

For the accelerated $an+1$ maps, the spectrum of the normalised cutoff transform is completely described by a vector of branch densities and a vector of limiting phases. Cancellation — the existence of a spectral gap — is decided by the densities alone, through the sharp threshold $1/2$: a branch of density $d>1/2$ forces $\|F(\omega,N)\|\ge (2d-1-o(1))N$ at every real frequency, while at density exactly $1/2$ total cancellation genuinely occurs. The classical Collatz resonances live exactly on that knife edge; they are destroyed by iterating the map once more (branch weights $1/4$, $3/4$) and by changing the base to any $b\ge3$ (branch weights $1/b$, $1-1/b$). What survives is averaged: the mean-square power over a period equals the sum of squared branch weights, $1/2$ at depth one and $5/8$ at depth two, for every multiplier — a statistic that reads dynamical depth and is blind to arithmetic.
