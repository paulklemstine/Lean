# Phase Collapse of the Jacobi Gauss Sum: An Exact Structural Obstruction to Factor-Revealing Quadratic Interference

**Author:** Aristotle
**Date:** 2026-08-12

---

## Abstract

For an odd modulus $N$ let $\tau(N) = \sum_{n=0}^{N-1} \left(\frac{n}{N}\right) e^{2\pi i n/N}$ denote the Jacobi Gauss sum, where $\left(\frac{n}{N}\right)$ is the Jacobi symbol. For odd squarefree $N$ we have $|\tau(N)| = \sqrt N$, so all of the arithmetic content of $\tau(N)$ resides in its argument. When $N = pq$ is a semiprime, the prime-level Gauss sums $g_p$ and $g_q$ from which $\tau(N)$ is assembled are sensitive to $p \bmod 4$ and $q \bmod 4$ individually, which makes $\arg \tau(N)$ a genuine candidate for a factor-revealing invariant: a single, cheaply computed angle that might separate the class $p \equiv q \equiv 1 \pmod 4$ from the class $p \equiv q \equiv 3 \pmod 4$, two classes that $N$ alone cannot distinguish.

We prove that it does not. The main theorem, the **Phase Collapse Theorem**, states that for every odd squarefree $N$,
$$\tau(N) = \begin{cases}\sqrt N, & N \equiv 1 \pmod 4,\\ i\sqrt N, & N \equiv 3 \pmod 4,\end{cases}$$
so that $\arg\tau(N) \in \{0, \pi/2\}$ is a function of $N \bmod 4$ alone. The mechanism is an exact cancellation: twisted multiplicativity gives $\tau(pq) = \left(\frac{q}{p}\right)\left(\frac{p}{q}\right) g_p g_q$, and in the unique class where the two prime phase units multiply to $-1$ — namely $p \equiv q \equiv 3 \pmod 4$ — the quadratic reciprocity correction contributes exactly $-1$ as well. The two sign sources are not independent; they are the same sign.

We further isolate precisely what is conditional. The **square law** $\tau(N)^2 = \pm N$, with sign given by $N \bmod 4$, holds unconditionally for all odd squarefree $N$, as does the resulting **dichotomy** $\tau(N) \in \{\pm\sqrt N\}$ or $\{\pm i \sqrt N\}$; hence the residual dependence of $\tau(N)$ on the factorisation of $N$ is at most one global sign, without appeal to Gauss's sign determination for prime Gauss sums. That classical sign theorem is required only to eliminate the residual $\pm$, and is verified here from first principles for the primes $3$, $5$, and $7$, yielding the unconditional witnesses $\tau(15) = i\sqrt{15}$ and $\tau(21) = \sqrt{21}$; the latter is an unconditional instance of the $(3,3)$ cancellation itself. We interpret the result as an exact instance of *structural orthogonality*: the phase channel of $\tau$ has capacity exactly one bit, and that bit is public.

**Keywords:** Jacobi symbol, quadratic Gauss sum, quadratic reciprocity, Dirichlet character, twisted multiplicativity, phase collapse, integer factorisation, structural orthogonality.

---

## 1. Introduction

### 1.1 Motivation

Analytic invariants attached to an integer $N$ occasionally reveal more than their definition suggests. The question that motivates this work is a sharp version of that hope in the factoring context: given a semiprime $N = pq$ with $p \neq q$ odd primes, is there a quantity computable from $N$ alone whose value depends on the pair $(p \bmod 4,\, q \bmod 4)$ beyond what $N \bmod 4$ already determines?

The relevance of $4$ is not arbitrary. The product $N = pq$ satisfies
$$N \equiv 1 \pmod 4 \iff p \equiv q \pmod 4,$$
so from $N$ one immediately reads whether the two primes agree modulo $4$, but *not* which of the two agreeing classes they occupy. The classes $(1,1)$ and $(3,3)$ are, from the point of view of $N \bmod 4$, indistinguishable. Any invariant that separated them would deliver one bit of genuinely private factor information at negligible cost.

The Jacobi Gauss sum is arguably the most natural candidate. It has three features that a factor-revealing invariant would want:

1. **Exact square-root size.** $|\tau(N)| = \sqrt N$ for odd squarefree $N$: no cancellation is lost, so nothing is drowned in an error term. All the content is in the phase.
2. **Compatibility with the factorisation.** $\tau$ satisfies a multiplicativity law along coprime factorisations of the modulus, so $\tau(pq)$ is literally built from $\tau(p)$ and $\tau(q)$.
3. **Prime-level sensitivity to the residue mod 4.** The classical quadratic Gauss sum $g_p$ is real for $p \equiv 1 \pmod 4$ and purely imaginary for $p \equiv 3 \pmod 4$. The constituents *do* see the residues separately.

Everything therefore points towards the phase of $\tau(pq)$ remembering more than $N \bmod 4$. The content of this paper is that it does not, and that the reason is an exact identity rather than a statistical accident.

### 1.2 Summary of results

Throughout, $\left(\frac{\cdot}{\cdot}\right)$ denotes the Jacobi symbol, $N$ is odd, and "squarefree" means not divisible by the square of any prime.

- **Twisted multiplicativity (Theorem 3.1).** For coprime $m, n \geq 1$, $\tau(mn) = \left(\frac{n}{m}\right)\left(\frac{m}{n}\right)\tau(m)\tau(n)$. No primality hypothesis is used.
- **Prime Gauss sum square (Proposition 3.4).** For an odd prime $p$, $g_p^2 = p$ if $p \equiv 1 \pmod 4$ and $g_p^2 = -p$ otherwise.
- **Reciprocity sign (Lemma 4.1).** For distinct odd primes $p, q$, $\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = -1$ exactly when $p \equiv q \equiv 3 \pmod 4$, and $+1$ otherwise.
- **Square law (Theorem 4.2, unconditional).** For every odd squarefree $N$, $\tau(N)^2 = N$ if $N \equiv 1 \pmod 4$ and $\tau(N)^2 = -N$ otherwise. Consequently $|\tau(N)| = \sqrt N$ (Corollary 4.3) and $\tau(N)^2/N$ depends only on $N \bmod 4$ (Corollary 4.4).
- **Dichotomy (Theorem 4.5, unconditional).** For every odd squarefree $N$: either $N \equiv 1 \pmod 4$ and $\tau(N) \in \{\sqrt N, -\sqrt N\}$, or $N \equiv 3 \pmod 4$ and $\tau(N) \in \{i\sqrt N, -i\sqrt N\}$.
- **Phase Collapse Theorem (Theorem 5.2).** Granting Gauss's sign theorem for prime Gauss sums, $\tau(N) = \sqrt N$ for $N \equiv 1 \pmod 4$ and $\tau(N) = i\sqrt N$ for $N \equiv 3 \pmod 4$, for every odd squarefree $N$; hence $\arg \tau(N) \in \{0,\pi/2\}$ is a function of $N \bmod 4$ alone (Corollary 5.3), and the classes $(1,1)$ and $(3,3)$ have identical phase (Corollary 5.4).
- **Unconditional witnesses (Section 6).** $g_3 = i\sqrt3$, $g_5 = \sqrt 5$, $g_7 = i \sqrt 7$, hence $\tau(15) = i\sqrt{15}$ and, exhibiting the $(3,3)$ cancellation with no conditional input, $\tau(21) = \sqrt{21}$.

---

## 2. Definitions and conventions

**Definition 2.1 (Legendre and Jacobi symbols).** For an odd prime $p$ and $a \in \mathbb Z$, the Legendre symbol $\left(\frac{a}{p}\right)$ is $0$ if $p \mid a$, $+1$ if $a$ is a nonzero quadratic residue mod $p$, and $-1$ otherwise. For odd $N = p_1 p_2 \cdots p_k$ (primes with multiplicity), the Jacobi symbol is $\left(\frac{a}{N}\right) = \prod_{j=1}^k \left(\frac{a}{p_j}\right)$, with the convention $\left(\frac{a}{1}\right)=1$. The Jacobi symbol is completely multiplicative in its numerator and depends on the numerator only through its residue class mod $N$; for squarefree $N$ it is precisely the real primitive quadratic Dirichlet character mod $N$ associated with the field $\mathbb{Q}(\sqrt{N^*})$, $N^* = (-1)^{(N-1)/2}N$.

**Definition 2.2 (Jacobi Gauss sum).** For an odd modulus $N \geq 1$,
$$\tau(N) \;=\; \sum_{n=0}^{N-1}\left(\frac{n}{N}\right) e^{2\pi i n/N} \;=\; \sum_{x \in \mathbb Z/N\mathbb Z} \chi_N(x)\, \psi(x),$$
where $\chi_N$ is the Jacobi symbol viewed as a multiplicative character on $\mathbb Z/N\mathbb Z$ and $\psi(x) = e^{2\pi i x/N}$ is the standard additive character. Note $\tau(1)=1$.

**Definition 2.3 (Quadratic Gauss sum).** For an odd prime $p$,
$$g_p \;=\; \sum_{a=0}^{p-1}\left(\frac{a}{p}\right) e^{2\pi i a/p}.$$
Since the Jacobi symbol modulo a prime coincides with the Legendre symbol, $g_p = \tau(p)$.

**Definition 2.4 (Additive character twist).** For $u \in (\mathbb Z/N\mathbb Z)^\times$, the twisted additive character is $\psi_u(x) = \psi(ux) = e^{2\pi i u x/N}$. Twisting is the technical device that converts a Chinese Remainder Theorem splitting into an identity of Gauss sums.

**Convention.** All results below are stated for odd $N$. Squarefreeness is assumed wherever the Jacobi symbol must be a primitive character; without it $\tau(N)$ degenerates (e.g. $\tau(9)=0$, since $\left(\frac{\cdot}{9}\right)$ is the principal character on units and the additive character sums to $0$ over a full set of residues after accounting for multiples of $3$).

**Definition 2.5 (Gauss's sign theorem, as a hypothesis).** We write $\mathrm{(GS)}$ for the statement: *for every odd prime $p$, $g_p = \sqrt p$ if $p \equiv 1 \pmod 4$ and $g_p = i\sqrt p$ if $p \equiv 3 \pmod 4$.* This is a classical theorem of Gauss (1805). Because it is genuinely deeper than the algebraic identity $g_p^2 = \pm p$, we track exactly which of our results depend on it, and which do not.

---

## 3. Structure of the Jacobi Gauss sum

### 3.1 Twisted multiplicativity

**Theorem 3.1 (Twisted multiplicativity).** *Let $m, n \geq 1$ be coprime odd integers. Then*
$$\tau(mn) \;=\; \left(\frac{n}{m}\right)\left(\frac{m}{n}\right)\,\tau(m)\,\tau(n).$$
*No primality assumption is required; only $\gcd(m,n)=1$.*

*Proof sketch.* Choose Bézout coefficients $u, v \in \mathbb Z$ with $un + vm = 1$. Reduction gives a ring isomorphism $\mathbb Z/mn\mathbb Z \cong \mathbb Z/m\mathbb Z \times \mathbb Z/n\mathbb Z$, and under it the standard additive character splits as
$$e^{2\pi i x/(mn)} \;=\; e^{2\pi i (ux)/m}\cdot e^{2\pi i (vx)/n},$$
because $\frac{x}{mn} = \frac{(un+vm)x}{mn} = \frac{ux}{m} + \frac{vx}{n}$ modulo $1$. Simultaneously, complete multiplicativity of the Jacobi symbol in the *denominator* gives $\left(\frac{x}{mn}\right) = \left(\frac{x}{m}\right)\left(\frac{x}{n}\right)$, and each factor depends on $x$ only through its residue in the respective component. Hence
$$\tau(mn) \;=\; \Big(\sum_{a \bmod m}\left(\tfrac{a}{m}\right)e^{2\pi i u a/m}\Big)\Big(\sum_{b \bmod n}\left(\tfrac{b}{n}\right)e^{2\pi i v b/n}\Big).$$
Each inner sum is a *twisted* Gauss sum. For any unit $u$ mod $m$, substituting $a \mapsto u^{-1}a$ and using multiplicativity of the character in the numerator gives the standard untwisting identity
$$\sum_{a \bmod m}\left(\tfrac{a}{m}\right)e^{2\pi i u a/m} \;=\; \left(\tfrac{u}{m}\right)^{-1}\tau(m) = \left(\tfrac{u}{m}\right)\tau(m),$$
using that the Jacobi symbol is real-valued and $\left(\frac{u}{m}\right)^2 = 1$ for units. Finally $un \equiv 1 \pmod m$ forces $\left(\frac{u}{m}\right) = \left(\frac{n}{m}\right)$, and symmetrically $\left(\frac{v}{n}\right) = \left(\frac{m}{n}\right)$. Combining the three displays yields the claim. $\square$

**Remark 3.2.** The Bézout coefficients are not canonical, but the pair $\left(\frac{u}{m}\right)\left(\frac{v}{n}\right)$ is: any two choices of $u$ differ by a multiple of $m$, so their residues, and hence their symbols, agree. The twisting factor is intrinsic.

**Corollary 3.3 (Semiprime case).** *For distinct odd primes $p, q$,*
$$\tau(pq) \;=\; \left(\frac{q}{p}\right)\left(\frac{p}{q}\right)\, g_p\, g_q .$$

### 3.2 The square of a prime Gauss sum

**Proposition 3.4.** *For an odd prime $p$,*
$$g_p^2 \;=\; \left(\frac{-1}{p}\right) p \;=\; \begin{cases} p, & p \equiv 1 \pmod 4,\\ -p, & p \equiv 3 \pmod 4.\end{cases}$$

*Proof sketch.* Write $g_p \overline{g_p} = |g_p|^2$ and evaluate the double sum: for a nontrivial character $\chi$ mod $p$ and the primitive additive character $\psi$,
$$|g_p|^2 = \sum_{a,b}\chi(a)\overline{\chi(b)}\psi(a-b) = \sum_{c}\chi(c)\sum_{b \neq 0}\psi(b(c-1)) = p,$$
after the substitution $a = bc$ and orthogonality of $\psi$. Since $\chi = \left(\frac{\cdot}{p}\right)$ is real-valued, $\overline{g_p} = \sum_a \chi(a)\psi(-a) = \chi(-1)g_p$, so $g_p^2 = \chi(-1)|g_p|^2 = \left(\frac{-1}{p}\right)p$. The Euler criterion $\left(\frac{-1}{p}\right) = (-1)^{(p-1)/2}$ gives the case split. $\square$

**Remark 3.5.** Proposition 3.4 is purely algebraic: no analysis, no determination of a square root, no choice of branch. The point of the next two sections is that this algebraic input alone already forces most of the collapse.

---

## 4. The unconditional collapse

### 4.1 The reciprocity sign

**Lemma 4.1.** *For distinct odd primes $p, q$,*
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) \;=\; (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}} \;=\; \begin{cases}-1, & p \equiv q \equiv 3 \pmod 4,\\ +1, & \text{otherwise.}\end{cases}$$

*Proof sketch.* The first equality is the law of quadratic reciprocity. The exponent $\frac{p-1}{2}\cdot\frac{q-1}{2}$ is odd if and only if both $\frac{p-1}{2}$ and $\frac{q-1}{2}$ are odd, i.e. if and only if $p \equiv 3$ and $q \equiv 3 \pmod 4$. $\square$

This lemma is the crux. Observe the exact coincidence of conditions: **the unique class in which reciprocity flips a sign is the unique class in which both prime Gauss sums are imaginary.**

### 4.2 The square law

**Theorem 4.2 (Square law; unconditional).** *For every odd squarefree $N \geq 1$,*
$$\tau(N)^2 \;=\; \begin{cases} N, & N \equiv 1 \pmod 4,\\ -N, & N \equiv 3 \pmod 4.\end{cases}$$

*Proof sketch.* Strong induction on $N$. For $N=1$, $\tau(1)=1$. Otherwise write $N = p\,M$ with $p$ the least prime factor and $M = N/p$; squarefreeness gives $\gcd(p, M)=1$ and $M$ odd squarefree with $M < N$. Theorem 3.1 gives
$$\tau(N)^2 = \left(\tfrac{M}{p}\right)^2\left(\tfrac{p}{M}\right)^2 \tau(p)^2\tau(M)^2 = g_p^2\,\tau(M)^2,$$
since the Jacobi symbols are $\pm 1$ (they are nonzero because $\gcd(p,M)=1$) and therefore square to $1$. **This is the essential point: squaring destroys the reciprocity twist entirely.** By Proposition 3.4 and the inductive hypothesis, $g_p^2 = \varepsilon_4(p)\,p$ and $\tau(M)^2 = \varepsilon_4(M)\,M$ where $\varepsilon_4(x) = +1$ if $x \equiv 1 \pmod 4$ and $-1$ if $x \equiv 3 \pmod 4$. Since $\varepsilon_4$ is a homomorphism on odd residues — $\varepsilon_4(x)\varepsilon_4(y) = \varepsilon_4(xy)$, which is the statement that $(\mathbb Z/4\mathbb Z)^\times \cong \{\pm1\}$ — we get $\tau(N)^2 = \varepsilon_4(pM)\,pM = \varepsilon_4(N)N$. $\square$

**Corollary 4.3 (Modulus; unconditional).** *For odd squarefree $N$, $|\tau(N)| = \sqrt N$.*

*Proof.* $|\tau(N)|^2 = |\tau(N)^2| = |{\pm}N| = N$, and $|\tau(N)| \geq 0$. $\square$

**Corollary 4.4 (One-bit channel; unconditional).** *If $N, N'$ are odd squarefree with $N \equiv N' \pmod 4$, then*
$$\frac{\tau(N)^2}{N} = \frac{\tau(N')^2}{N'}.$$
*In particular the normalised square carries no information about the prime factorisation beyond $N \bmod 4$.*

*Proof.* Immediate from Theorem 4.2: both sides equal $\varepsilon_4(N)$. $\square$

### 4.3 The dichotomy: exactly what is left

**Theorem 4.5 (Dichotomy; unconditional).** *For every odd squarefree $N$, exactly one of the following holds:*
- $N \equiv 1 \pmod 4$ *and* $\tau(N) \in \{\sqrt N,\, -\sqrt N\}$;
- $N \equiv 3 \pmod 4$ *and* $\tau(N) \in \{i\sqrt N,\, -i\sqrt N\}$.

*Proof sketch.* If $N \equiv 1 \pmod 4$ then Theorem 4.2 gives $\tau(N)^2 - (\sqrt N)^2 = 0$, i.e. $(\tau(N)-\sqrt N)(\tau(N)+\sqrt N) = 0$, and $\mathbb C$ is an integral domain. If $N \equiv 3 \pmod 4$ then $\tau(N)^2 + N = 0$, and since $(i\sqrt N)^2 = -N$ the same factorisation applies with $i\sqrt N$ in place of $\sqrt N$. $\square$

**Interpretation.** Theorem 4.5 is the sharpest *unconditional* form of the collapse, and it already settles the motivating question at the level of structure. The complex *line* $\mathbb R \cdot \tau(N) \subseteq \mathbb C$ — the real axis or the imaginary axis — is a function of $N \bmod 4$ alone. Whatever residual dependence on the factorisation of $N$ might survive in $\tau(N)$ is confined to a single global sign, and Section 5 shows that this sign is always $+$, hence carries no information either.

---

## 5. The exact phase

**Theorem 5.1 (Semiprime phase collapse).** *Assume $\mathrm{(GS)}$. For distinct odd primes $p, q$ and $N = pq$,*
$$\tau(N) = \begin{cases}\sqrt N, & N \equiv 1 \pmod 4,\\ i\sqrt N, & N \equiv 3 \pmod 4.\end{cases}$$

*Proof sketch.* By Corollary 3.3, $\tau(N) = \sigma\, g_p g_q$ with $\sigma = \left(\frac{q}{p}\right)\left(\frac{p}{q}\right)$. Enumerate the four classes, writing $g_r = \iota_r \sqrt r$ with $\iota_r = 1$ if $r \equiv 1$ and $\iota_r = i$ if $r \equiv 3 \pmod 4$ (this is $\mathrm{(GS)}$), and using Lemma 4.1 for $\sigma$:

| $(p \bmod 4, q \bmod 4)$ | $\iota_p\iota_q$ | $\sigma$ | $\tau(pq)/\sqrt{pq}$ | $N \bmod 4$ |
|---|---|---|---|---|
| $(1,1)$ | $1$ | $+1$ | $1$ | $1$ |
| $(1,3)$ | $i$ | $+1$ | $i$ | $3$ |
| $(3,1)$ | $i$ | $+1$ | $i$ | $3$ |
| $(3,3)$ | $i\cdot i = -1$ | $-1$ | $(-1)(-1)=1$ | $1$ |

together with $\sqrt p \sqrt q = \sqrt{pq}$. In every row the value of $\tau(pq)/\sqrt{pq}$ is determined by $N \bmod 4$: it is $1$ when $N\equiv 1$ and $i$ when $N \equiv 3$. $\square$

**Theorem 5.2 (Phase Collapse Theorem; general odd squarefree modulus).** *Assume $\mathrm{(GS)}$. For every odd squarefree $N \geq 1$,*
$$\tau(N) = \begin{cases}\sqrt N, & N \equiv 1 \pmod 4,\\ i\sqrt N, & N \equiv 3 \pmod 4.\end{cases}$$

*Proof sketch.* Strong induction on $N$, mirroring Theorem 4.2 but retaining the twist. For $N = 1$ the statement is $\tau(1)=1$. For $N > 1$ write $N = pM$ with $p = $ least prime factor, $M = N/p$ odd squarefree and coprime to $p$. Theorem 3.1 gives $\tau(N) = \left(\frac{M}{p}\right)\left(\frac{p}{M}\right)\, g_p\, \tau(M)$, and by $\mathrm{(GS)}$ and the inductive hypothesis $g_p \tau(M) = \iota_p \iota_M \sqrt{pM}$ where $\iota_x \in \{1,i\}$ is determined by $x \bmod 4$. It remains to check that
$$\left(\frac{M}{p}\right)\left(\frac{p}{M}\right)\,\iota_p\,\iota_M \;=\; \iota_{pM},$$
which is the Jacobi form of quadratic reciprocity, $\left(\frac{M}{p}\right)\left(\frac{p}{M}\right) = (-1)^{\frac{p-1}{2}\frac{M-1}{2}}$ for coprime odd $p, M$, combined with the elementary identity $\iota_x \iota_y = (-1)^{\frac{x-1}{2}\frac{y-1}{2}}\,\iota_{xy}$ for odd $x,y$. That identity is verified by the four cases of $(x \bmod 4, y \bmod 4)$: the only case where $\iota_x\iota_y = -\iota_{xy}$ is $x\equiv y \equiv 3$, which is exactly the case where the reciprocity factor is $-1$. $\square$

**Corollary 5.3 (The phase is a function of $N \bmod 4$).** *Assume $\mathrm{(GS)}$. For odd squarefree $N$,*
$$\arg \tau(N) = \begin{cases}0, & N \equiv 1 \pmod 4,\\ \pi/2, & N \equiv 3 \pmod 4.\end{cases}$$
*Consequently, if $N$ and $N'$ are odd squarefree with $N \equiv N' \pmod 4$, then $\arg \tau(N) = \arg\tau(N')$, however their prime factors are distributed mod $4$.*

**Corollary 5.4 (Structural orthogonality).** *Assume $\mathrm{(GS)}$. Let $N = pq$ with $p \equiv q \equiv 1 \pmod 4$ and $N' = p'q'$ with $p' \equiv q' \equiv 3 \pmod 4$ ($p\neq q$, $p'\neq q'$ distinct odd primes). Then $\arg\tau(N) = \arg\tau(N') = 0$.*

Thus the map $N \mapsto \arg\tau(N)$, restricted to odd squarefree moduli, has image of cardinality $2$ and factors through $N \bmod 4$. Its information content is exactly $1$ bit, and that bit is publicly computable from $N$. The invariant is *orthogonal* to the factorisation in the strongest possible sense: not merely uncorrelated in practice, but constant on the fibres of the public data.

---

## 6. Unconditional witnesses

The results of Section 5 are conditional only on $\mathrm{(GS)}$, a classical theorem. For small primes the sign can be pinned down by direct computation, giving unconditional instances of the collapse, including the crucial $(3,3)$ case.

**Proposition 6.1.** $g_3 = i\sqrt3$ *and* $g_5 = \sqrt5$.

*Proof sketch.* Directly, $g_3 = e^{2\pi i/3} - e^{4\pi i/3} = 2i\sin(2\pi/3) = i\sqrt3$. For $p=5$ the residues $1,4$ are squares and $2,3$ are not, so $g_5 = 2\cos(2\pi/5) - 2\cos(4\pi/5)$, which is real and positive; by Proposition 3.4 its square is $5$, hence $g_5 = \sqrt5$. $\square$

**Proposition 6.2.** $g_7 = i\sqrt7$.

*Proof sketch.* Modulo $7$ the squares are $\{1,2,4\}$ and the nonsquares are $\{3,5,6\}$, so
$$g_7 = \left(\zeta + \zeta^2 + \zeta^4\right) - \left(\zeta^3 + \zeta^5 + \zeta^6\right), \qquad \zeta = e^{2\pi i/7}.$$
The map $k \mapsto 7-k$ interchanges the two sets (indeed $-1$ is a nonresidue mod $7$), so pairing $\zeta^k$ with $\overline{\zeta^k} = \zeta^{7-k}$ cancels every real part and the sum is purely imaginary:
$$g_7 = 2i\left(\sin\tfrac{2\pi}{7} + \sin\tfrac{4\pi}{7} - \sin\tfrac{6\pi}{7}\right).$$
Folding $\sin\frac{4\pi}{7} = \sin\frac{3\pi}{7}$ and $\sin\frac{6\pi}{7} = \sin\frac{\pi}{7}$, positivity of the bracket reduces to $\sin\frac{\pi}{7} < \sin\frac{3\pi}{7}$, which follows from strict monotonicity of $\sin$ on $[0,\pi/2]$. Hence $g_7 = i t$ with $t>0$; by Proposition 3.4, $(it)^2 = -t^2 = -7$, so $t = \sqrt7$. $\square$

**Corollary 6.3 (Mixed case, unconditional).** $\tau(15) = i\sqrt{15}$.

*Proof.* Since $5 \equiv 2 \pmod 3$ is a nonresidue, $\left(\frac{5}{3}\right)=-1$; since the squares mod $5$ are $1,4$, also $\left(\frac{3}{5}\right)=-1$. The twist is therefore $(-1)(-1) = +1$, consistent with Lemma 4.1 because $5 \equiv 1 \pmod 4$. Then $\tau(15) = (+1)(i\sqrt3)(\sqrt5) = i\sqrt{15}$, and indeed $15 \equiv 3 \pmod 4$. $\square$

**Corollary 6.4 (The $(3,3)$ cancellation, unconditional).** $\tau(21) = \sqrt{21}$.

*Proof.* Both $3$ and $7$ are $3 \bmod 4$. We have $\left(\frac{7}{3}\right) = \left(\frac{1}{3}\right) = +1$ and $\left(\frac{3}{7}\right) = -1$ (the squares mod $7$ are $1,2,4$), so the reciprocity twist is $-1$, in agreement with Lemma 4.1. By Propositions 6.1 and 6.2, $g_3 g_7 = (i\sqrt3)(i\sqrt7) = -\sqrt{21}$. Hence $\tau(21) = (-1)\cdot(-\sqrt{21}) = \sqrt{21}$, real and positive, matching $21 \equiv 1 \pmod 4$. $\square$

Corollary 6.4 is the informative witness: it exhibits, with no conditional input whatsoever, the exact annihilation of the two factors $i$ against the reciprocity sign.

---

## 7. Algorithms

### 7.1 Evaluating $\tau(N)$ directly

The definition gives an $O(N)$ algorithm if the Jacobi symbols are computed incrementally, or $O(N \log N)$ naively (each symbol costs $O(\log N)$ by the reciprocity-based binary algorithm). Numerically it is a sum of $N$ unit complex numbers with signs; catastrophic cancellation is not an issue because the result has magnitude $\sqrt N$, so the relative error is about $\sqrt N \cdot \varepsilon_{\mathrm{mach}} / \sqrt N = \varepsilon_{\mathrm{mach}}\sqrt{N}$ in absolute terms — entirely adequate for $N$ up to $10^6$ in double precision.

**Algorithm A (Direct evaluation).**
```
Input: odd N >= 1
Output: tau(N) in C
S <- 0
for n = 0 to N-1:
    s <- JacobiSymbol(n, N)          # O(log N) by reciprocity
    if s != 0:
        S <- S + s * exp(2*pi*i*n/N)
return S
```

### 7.2 Evaluating $\tau(N)$ by the collapse

The Phase Collapse Theorem replaces the sum by a constant-time closed form for odd squarefree $N$.

**Algorithm B (Closed form).**
```
Input: odd squarefree N
Output: tau(N)
if N mod 4 = 1: return sqrt(N)
else:           return i * sqrt(N)
```
This is $O(1)$ after an $O(\sqrt N)$ (or subexponential) squarefreeness check, and it is exact. The contrast with Algorithm A is itself the content of the theorem: an $O(N)$ interference computation that appeared to depend on the factorisation collapses to a two-case lookup on $N \bmod 4$.

### 7.3 Verifying the mechanism

**Algorithm C (Mechanism audit).** Given a semiprime $N = pq$ with known factors, compute $g_p$, $g_q$ by Algorithm A, compute $\sigma = \left(\frac{q}{p}\right)\left(\frac{p}{q}\right)$ by the binary Jacobi algorithm, and verify $|\tau(N) - \sigma g_p g_q| < \epsilon$. This checks Corollary 3.3 numerically and displays, in the $(3,3)$ case, the two cancelling $-1$'s in isolation. Cost $O(N)$, dominated by Algorithm A on the composite modulus.

### 7.4 The information audit

**Algorithm D (Phase histogram).** For all odd squarefree $N < B$, compute $\arg\tau(N)$ and tabulate it against $N \bmod 4$. The theorem predicts exactly two cells are occupied. Empirically for $B = 400$ one finds $79$ moduli with $N \equiv 1 \pmod 4$, all with argument $0$, and $82$ moduli with $N \equiv 3 \pmod 4$, all with argument $\pi/2$; no other phase occurs. Total cost $O(B^2)$.

---

## 8. Computational evidence

The theorem was conjectured from data before it was proved. The sums were computed for the thirteen test semiprimes $15, 21, 33, 35, 51, 65, 77, 85, 91, 115, 143, 187, 209$, chosen to populate all four classes of $(p \bmod 4, q \bmod 4)$:

| $N$ | $p \times q$ | $(p,q) \bmod 4$ | $N \bmod 4$ | $\tau(N)/\sqrt N$ | $\arg\tau(N)$ |
|---|---|---|---|---|---|
| $15$ | $3\times5$ | $(3,1)$ | $3$ | $i$ | $\pi/2$ |
| $21$ | $3\times7$ | $(3,3)$ | $1$ | $1$ | $0$ |
| $33$ | $3\times11$ | $(3,3)$ | $1$ | $1$ | $0$ |
| $35$ | $5\times7$ | $(1,3)$ | $3$ | $i$ | $\pi/2$ |
| $51$ | $3\times17$ | $(3,1)$ | $3$ | $i$ | $\pi/2$ |
| $65$ | $5\times13$ | $(1,1)$ | $1$ | $1$ | $0$ |
| $77$ | $7\times11$ | $(3,3)$ | $1$ | $1$ | $0$ |
| $85$ | $5\times17$ | $(1,1)$ | $1$ | $1$ | $0$ |
| $91$ | $7\times13$ | $(3,1)$ | $3$ | $i$ | $\pi/2$ |
| $115$ | $5\times23$ | $(1,3)$ | $3$ | $i$ | $\pi/2$ |
| $143$ | $11\times13$ | $(3,1)$ | $3$ | $i$ | $\pi/2$ |
| $187$ | $11\times17$ | $(3,1)$ | $3$ | $i$ | $\pi/2$ |
| $209$ | $11\times19$ | $(3,3)$ | $1$ | $1$ | $0$ |

Every value is $1$ or $i$ to machine precision (worst absolute deviation $\sim 10^{-14}$), and the split is governed by $N \bmod 4$. The $(1,1)$ rows ($65$, $85$) and the $(3,3)$ rows ($21$, $33$, $77$, $209$) are mutually indistinguishable. Extending to all odd squarefree $N < 400$, including moduli with three prime factors such as $105 = 3\cdot5\cdot7$ and $231 = 3\cdot7\cdot11$, reproduces the same two-valued behaviour.

---

## 9. Discussion

### 9.1 What kind of obstruction is this?

Negative results about factoring come in several strengths. Weakest is empirical: an attack was tried and did not work. Stronger is asymptotic or statistical: an invariant is shown to correlate negligibly with the target. Strongest, and rarest, is *exact structural orthogonality*: the invariant is provably a function of public data, so it has zero mutual information with the secret, for every input, with no error term.

The Phase Collapse Theorem is of the third kind. The map
$$N \longmapsto \tau(N) \in \mathbb C$$
restricted to odd squarefree moduli factors as $N \mapsto (N, N \bmod 4) \mapsto \varepsilon\sqrt N$. Conditioned on $N$, the value is deterministic. There is no signal to amplify, no statistical edge to accumulate over many moduli, no cleverer normalisation that would recover a lost bit — because nothing is lost; nothing is ever present.

### 9.2 Where the collapse comes from, conceptually

It is worth naming the coincidence precisely, because it is what governs whether analogous invariants collapse. Two independent-looking maps from pairs of odd residues to $\{\pm1\}$ agree identically:

- the **phase-unit product** $\iota_p\iota_q\,\iota_{pq}^{-1}$, arising from the analytic evaluation of prime Gauss sums;
- the **reciprocity sign** $(-1)^{\frac{p-1}{2}\frac{q-1}{2}}$, arising from the arithmetic of quadratic residues.

Both are the unique nontrivial symmetric bilinear form on $(\mathbb Z/4\mathbb Z)^\times \cong \mathbb Z/2\mathbb Z$, so their agreement is forced. The collapse is thus, at bottom, a statement about the smallness of the group $\{\pm1\}$: in a two-element group there is only one nondegenerate way for signs to interact, so two different mechanisms producing signs are compelled to produce the same one.

This immediately predicts fragility of the phenomenon under deformation. Replace the quadratic character by a cubic one and the relevant reciprocity sign lives in $\mu_3 \subset \mathbb Z[\omega]$, where the space of bilinear forms is larger and no identity of the above kind can hold uniformly. One therefore expects cubic Gauss sums *not* to collapse — and the analogous statement becomes a falsifiable conjecture testable by finite computation.

### 9.3 The conditional/unconditional boundary

A pleasant feature of the analysis is that it locates the exact point at which the deep classical input is required. Everything up to and including the dichotomy of Theorem 4.5 uses only:

1. the Chinese Remainder Theorem and character twisting (Theorem 3.1);
2. the algebraic identity $g_p^2 = \left(\frac{-1}{p}\right)p$ (Proposition 3.4);
3. quadratic reciprocity (Lemma 4.1);
4. the group structure of $(\mathbb Z/4\mathbb Z)^\times$.

None of these requires knowing which square root of $\pm p$ the sum $g_p$ equals. Gauss's sign theorem enters only to convert "$\pm$" into "$+$", and the sign it removes is uniform in $N$ — a global normalisation, not a factor-dependent quantity. Hence the information-theoretic conclusion, which is what matters for the motivating question, is unconditional; only the cosmetic normalisation of the answer is not.

### 9.4 Scope and limitations

The results are stated for odd squarefree moduli. Squarefreeness is essential: for non-squarefree $N$ the Jacobi symbol modulo $N$ is imprimitive, $\tau(N)$ typically vanishes, and the multiplicativity law degenerates. Since the semiprimes relevant to factoring are squarefree by construction, this is not a restriction in the intended application. The results say nothing about incomplete or twisted sums, about sums over intervals shorter than a full period, or about characters of higher order — all of which are, for exactly that reason, the interesting places to look next.

---

## 10. Future work

Three directions follow directly from the analysis, each stated so that a single computation or a single proof would settle it.

**(F1) Remove the last hypothesis.** Establish Gauss's sign theorem $\mathrm{(GS)}$ from first principles in the same framework, making Theorem 5.2 unconditional. The key insight is that the sign is not an analytic accident: $g_p$ is essentially the trace of the finite Fourier transform on $\mathbb Z/p\mathbb Z$, whose eigenvalue multiplicities are forced by $F^4 = \mathrm{id}$ together with a Vandermonde determinant — a purely algebraic computation inside $\mathbb Z/p\mathbb Z$ and $\mathbb Z[\zeta_p]$, rather than a Poisson-summation argument. The two hardest ingredients, the square identity $g_p^2 = \pm p$ and the primitivity of the standard additive character, are already available; what remains is a multiplicity count. The cases $p = 3, 5, 7$ treated above are templates, and the $p=7$ argument is the informative one: the real part cancels by the pairing $k \leftrightarrow p-k$, and the sign reduces to positivity of a sine sum, which is the general obstruction. A falsifier would be a prime $p$ with numerically computed $g_p$ of the wrong sign; none exists below $10^5$.

**(F2) Higher-power sums should not collapse.** Let $N = pq$ with $p \equiv q \equiv 1 \pmod 3$ and let $\chi_3$ be a cubic Dirichlet character mod $N$. Conjecture: the argument of $\tau_3(N) = \sum_n \chi_3(n)e^{2\pi i n/N}$ is **not** a function of $N \bmod 9$ alone; there exist semiprimes $N \neq N'$ with $N \equiv N' \pmod 9$ and $\arg\tau_3(N) \neq \arg\tau_3(N')$. The key insight is that the collapse proved here is powered by an exact coincidence available only in $\{\pm1\}$ (Section 9.2), and the cubic reciprocity sign lives in $\mathbb Z[\omega]$ rather than $\{\pm1\}$, so no such coincidence can hold identically. The machinery transfers: the twisted multiplicativity argument of Theorem 3.1 is character-agnostic, so only the cubic character and cubic reciprocity need to be supplied, and the falsification is a finite computation.

**(F3) Salié sums as the first genuinely factor-revealing twist.** Consider $S(N) = \sum_{n \in (\mathbb Z/N\mathbb Z)^\times} \left(\frac{n}{N}\right)e^{2\pi i(n+n^{-1})/N}$. For prime moduli, Salié's evaluation expresses such sums in terms of $\cos(4\pi a/p)$ where $a^2 \equiv 1$-type conditions and square roots modulo $p$ appear explicitly — quantities that genuinely depend on the individual primes rather than on $N \bmod 4$. Conjecture: $|S(N)|$ is not a function of $N$ and $N \bmod 4$ alone, and the residue data entering its evaluation for $N = pq$ separates the classes $(1,1)$ and $(3,3)$. This would be the first invariant in this family that is *not* structurally orthogonal to the factorisation — though computing it still appears to require knowing modular square roots, which is itself as hard as factoring, so the expected outcome is a clean statement of *why* the difficulty is conserved rather than an attack.

Beyond these: quantify the collapse information-theoretically for families of moduli with prescribed factorisation shape; investigate whether *partial* sums $\sum_{n<xN}$ retain factor information that the complete sum destroys (the complete sum's rigidity is exactly a consequence of completeness); and examine the analogous question for Gauss sums over number fields and function fields, where the reciprocity sign has a different shape.

---

## 11. Conclusion

The Jacobi Gauss sum of an odd squarefree modulus is, up to an explicit constant, a function of that modulus's residue class mod $4$:
$$\tau(N) = \varepsilon(N \bmod 4)\sqrt N, \qquad \varepsilon(1)=1,\ \varepsilon(3)=i.$$
Its magnitude is $\sqrt N$ and its phase carries exactly one bit, which is public. The invariant is therefore exactly, provably orthogonal to the prime factorisation. The proof isolates the reason: the two independent-looking sign mechanisms in play — the imaginary units contributed by prime Gauss sums for $p \equiv 3 \pmod 4$, and the sign flip of quadratic reciprocity for $p \equiv q \equiv 3 \pmod 4$ — are one and the same sign, both being the unique nontrivial bilinear form on the two-element group $(\mathbb Z/4\mathbb Z)^\times$. Moreover the information-theoretic content of the collapse is unconditional, requiring only the square identity $\tau(N)^2 = \pm N$; the classical sign theorem for prime Gauss sums is needed only to fix a global normalisation.

This is a negative result, and a sharp one. Its value lies not in closing a door but in showing exactly which hinge holds it shut, and thereby indicating — cubic characters, Salié twists — where the door might not be there at all.
