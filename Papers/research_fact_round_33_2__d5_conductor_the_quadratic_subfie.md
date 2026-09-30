# The Quadratic Subfield of the Dihedral Quintic $x^5+20x+32$ Has Conductor $20$, Not $320$

**Author:** Aristotle

**Date:** 2026-09-30

---

## Abstract

The splitting field of the quintic $f(x) = x^5 + 20x + 32$ has dihedral Galois group $D_5$ of order $10$. It therefore contains a unique quadratic subfield $K$, and every unramified prime $p$ falls on one side of a *fork*: its Frobenius class lies either in the rotation subgroup $C_5$ or among the reflections. An information-theoretic "conductor scan" found that the residue $p \bmod 320$ carries one full bit of information about the fork, and on that basis it was claimed that $|d(K)| = 320$. We refute this claim and determine the correct value. First, no quadratic field has discriminant $\pm 320$, because $320 = 4\cdot 80$ and $80$ is not squarefree. Second, the fork agrees with the quadratic character $N \mapsto \left(\frac{-5}{N}\right)$ of $\mathbb{Q}(\sqrt{-5})$, whose discriminant is $-20$. We prove this agreement completely for all primes $p<400$ by exhaustive checking, and confirm it numerically for all primes $p<3000$. Third, we prove a **Minimal-Modulus Theorem**: the function $N\mapsto\left(\frac{-5}{N}\right)$ on odd $N$ is determined by $N \bmod m$ *if and only if* $20 \mid m$. Its least determining modulus, the conductor, is therefore $20$, and the observed full bit at $m = 320$ follows from $20 \mid 320$. We also record the discriminant $5^5\cdot 32^4+4^4\cdot 20^5 = (2^9\cdot 5^3)^2$ of $f$ and the fact that it is a square throughout the rescaled family $x^5+20t^4x+32t^5$, the reciprocity factorisation $\left(\frac{-5}{N}\right)=\chi_4(N)\left(\frac{N}{5}\right)$, the explicit rotation classes $N\equiv 1,3,7,9 \pmod{20}$, and the totally ramified reductions $f\equiv (x+2)^5 \pmod 5$ and $f \equiv x^5 \pmod 2$. We describe the algorithms involved, and close with future directions, including a Galois-theoretic proof of the fork identification for all primes and a minimal-modulus principle for every fundamental discriminant.

---

## 1. Introduction

Let $f(x) = x^5 + 20x + 32 \in \mathbb{Z}[x]$, and let $F$ be its splitting field over $\mathbb{Q}$. The Galois group $G = \mathrm{Gal}(F/\mathbb{Q})$ is the dihedral group $D_5$ of order $10$, acting on the five roots as the symmetry group of a regular pentagon acts on its vertices. We take this as the standing setting. It is consistent with everything below: the discriminant of $f$ is a nonzero square, so $G \subseteq A_5$, and the factorisation patterns of $f$ modulo primes are exactly the three patterns $D_5$ allows.

The rotation subgroup $C_5 \triangleleft D_5$ has index $2$. By the Galois correspondence its fixed field is the unique quadratic subfield $K \subset F$. For a prime $p$ unramified in $F$, the Frobenius conjugacy class $\mathrm{Frob}_p \subset G$ is defined, and
$$
\mathrm{Frob}_p \subset C_5 \iff p \text{ splits in } K.
$$
We call the map $p \mapsto [\mathrm{Frob}_p \subset C_5]$ the **fork**. If $K = \mathbb{Q}(\sqrt{d})$, quadratic reciprocity says the fork is a Dirichlet character of conductor $|d(K)|$. In particular it is periodic in $p$ with least period $|d(K)|$.

An empirical *conductor scan* computes, for each modulus $m$, the mutual information $I(p \bmod m;\ \text{fork})$ over a large set of primes and looks for moduli at which it equals one bit. Such a scan returned $m^\ast = 320$ with $I = 0.9999$ bits, and led to the claim

> **THE-CONDUCTOR-IS-320.** The fork of $f$ is detected by $N \bmod 320$, and the quadratic subfield satisfies $|d(K)| = 320$.

The first half of the claim is true. The second half is false, and the purpose of this paper is to explain exactly why. The main results are:

1. **(Non-existence.)** No quadratic field has discriminant $320$ or $-320$ (Theorem 3.2).
2. **(Identification.)** On every prime $3 \le p < 400$ with $p \ne 5$, the fork of $f$ equals the character $\left(\frac{-5}{p}\right)$ of $\mathbb{Q}(\sqrt{-5})$, where $d(\mathbb{Q}(\sqrt{-5})) = -20$ (Theorem 6.3).
3. **(Minimal modulus.)** The function $N \mapsto \left(\frac{-5}{N}\right)$ on odd $N$ is determined by $N \bmod m$ if and only if $20 \mid m$ (Theorem 4.3). Consequently its conductor is exactly $20$ (Corollary 4.4), and "detection mod $320$" is simply a consequence of $20 \mid 320$.

The verdict is: **the conductor is $20$, and THE-CONDUCTOR-IS-320 is refuted.**

---

## 2. The discriminant of the trinomial

**Definition 2.1.** For integers $a,b$ put
$$
\Delta(a,b) = 5^5 b^4 + 4^4 a^5.
$$
This is the classical formula for the discriminant of the quintic trinomial $x^5+ax+b$.

**Proposition 2.2.** $\Delta(20,32) = 2^{18}\cdot 5^6 = (2^9\cdot 5^3)^2 = 64000^2.$

*Proof.* We have $5^5 \cdot 32^4 = 3125 \cdot 1{,}048{,}576 = 3{,}276{,}800{,}000$ and $4^4\cdot 20^5 = 256 \cdot 3{,}200{,}000 = 819{,}200{,}000$. Their sum is $4{,}096{,}000{,}000 = 64000^2$, and $64000 = 2^9\cdot 5^3$. $\square$

**Proposition 2.3 (scaling family).** For every integer $t$,
$$
\Delta(20t^4,\ 32t^5) = (64000\, t^{10})^2 .
$$

*Proof.* $\Delta(20t^4, 32t^5) = 5^5\cdot 32^4 t^{20} + 4^4\cdot 20^5 t^{20} = \Delta(20,32)\,t^{20}$. $\square$

The polynomial $x^5+20t^4x+32t^5$ is $t^5 f(x/t)$, so it has the same splitting field as $f$ for $t\neq0$. Squareness of the discriminant is therefore a property of the whole scaling orbit.

**Remarks.** (i) A square discriminant means $G \subseteq A_5$, which is consistent with $G = D_5$ since all elements of $D_5 \subset S_5$ are even permutations. (ii) It also means $\mathbb{Q}(\sqrt{\Delta}) = \mathbb{Q}$. The quadratic subfield $K$ of a $D_5$ quintic is *not* generated by the square root of the discriminant, unlike the $S_n$ case, so it has to be found by other means. (iii) The only primes dividing $\Delta(20,32)$ are $2$ and $5$, so every prime $p \nmid 10$ is unramified in $F$.

---

## 3. Quadratic discriminants: $\pm 320$ is impossible

**Definition 3.1.** For a squarefree integer $d \neq 0,1$, the discriminant of $\mathbb{Q}(\sqrt d)$ is
$$
d(\mathbb{Q}(\sqrt d)) = \begin{cases} d & \text{if } d \equiv 1 \pmod 4,\\ 4d & \text{otherwise.}\end{cases}
$$
An integer $D$ is a **fundamental discriminant** if either $D\equiv 1 \pmod 4$ and $D$ is squarefree, or $D = 4m$ with $m$ squarefree and $m \equiv 2,3 \pmod 4$. Every quadratic field has a fundamental discriminant, and every fundamental discriminant $D\neq 1$ comes from exactly one quadratic field.

**Lemma 3.2.** $80$ and $-80$ are not squarefree.

*Proof.* $4^2 = 16$ divides $\pm 80$, and $4$ is not a unit. $\square$

**Theorem 3.3 (no quadratic field has discriminant $\pm 320$).** For every squarefree integer $d$,
$$
d(\mathbb{Q}(\sqrt d)) \neq 320 \quad\text{and}\quad d(\mathbb{Q}(\sqrt d)) \neq -320 .
$$
Equivalently, neither $320$ nor $-320$ is a fundamental discriminant.

*Proof.* If $d \equiv 1 \pmod 4$ the discriminant is $d$, which is odd, while $\pm320$ is even. Otherwise the discriminant is $4d$, and $4d = \pm 320$ forces $d = \pm 80$, which contradicts Lemma 3.2. For the fundamental-discriminant formulation: $\pm320 \not\equiv 1 \pmod 4$, and $\pm 320 = 4m$ forces $m = \pm 80$, which is not squarefree. $\square$

**Proposition 3.4.** $d(\mathbb{Q}(\sqrt{-5})) = -20$, and $-20$ is a fundamental discriminant.

*Proof.* $-5 \equiv 3 \pmod 4$, so the discriminant is $4\cdot(-5) = -20$. Also $-20 = 4\cdot(-5)$, where $-5$ is squarefree ($5$ is prime) and $-5 \equiv 3 \pmod 4$. $\square$

Theorem 3.3 already refutes the second half of THE-CONDUCTOR-IS-320 *for every quadratic field*, independently of anything specific to $f$. What remains is to find the true quadratic subfield and to explain why $320$ nonetheless showed up.

---

## 4. The fork character and the Minimal-Modulus Theorem

**Definition 4.1 (fork).** For a positive integer $N$, the **fork** of $N$ is the Jacobi symbol
$$
\phi(N) = \left(\frac{-5}{N}\right) \in \{-1, 0, 1\}.
$$
We only use it for odd $N$, where the Jacobi symbol is defined.

**Definition 4.2.** A nonnegative integer $m$ **determines the fork** if for all odd $b_1, b_2$,
$$
b_1 \equiv b_2 \pmod m \ \Longrightarrow\ \phi(b_1) = \phi(b_2).
$$

We first record periodicity. For odd $b$ the Jacobi symbol $\left(\frac{-5}{b}\right)$ depends only on $b \bmod 20$. This is the standard periodicity of $\left(\frac{a}{\cdot}\right)$ modulo $4|a|$, and it follows from quadratic reciprocity for the Jacobi symbol. Evaluating on odd residues gives:

| $N \bmod 20$ | 1 | 3 | 5 | 7 | 9 | 11 | 13 | 15 | 17 | 19 |
|---|---|---|---|---|---|---|---|---|---|---|
| $\phi(N)$ | $+1$ | $+1$ | $0$ | $+1$ | $+1$ | $-1$ | $-1$ | $0$ | $-1$ | $-1$ |

We will use in particular that $\phi(1) = 1$ and $\phi(11) = \phi(17) = -1$.

**Theorem 4.3 (Minimal-Modulus Theorem).** For every nonnegative integer $m$,
$$
m \text{ determines the fork} \iff 20 \mid m.
$$

*Proof.* ($\Leftarrow$) If $20 \mid m$ and $b_1 \equiv b_2 \pmod m$, then $b_1 \equiv b_2 \pmod{20}$, so $\phi(b_1) = \phi(b_1 \bmod 20) = \phi(b_2 \bmod 20) = \phi(b_2)$ by periodicity.

($\Rightarrow$) Suppose $20 \nmid m$. We construct odd $b_1 \equiv b_2 \pmod m$ with $\phi(b_1) \neq \phi(b_2)$. Since $20 = 4\cdot 5$ with $\gcd(4,5)=1$, either $5 \nmid m$, or $5 \mid m$ and $4 \nmid m$.

*Case A: $5 \mid m$ and $4 \nmid m$.* Let $L = \operatorname{lcm}(m, 2)$. Then $m \mid L$ and $2 \mid L$, and we claim $4 \nmid L$. If $m$ is even, then $L = m$ and $4 \nmid m$. If $m$ is odd, then $L = 2m$, and $4 \mid 2m$ would force $m$ to be even. Hence $L \equiv 2 \pmod 4$. Put $b_1 = 1$ and $b_2 = 1 + 5L$. Then $b_2$ is odd, and $b_2 \equiv b_1 \pmod m$ because $m \mid L$. Since $5L$ is divisible by $5$ and $\equiv 2 \pmod 4$, we get $5L \equiv 10 \pmod{20}$, so $b_2 \equiv 11 \pmod{20}$ and $\phi(b_2) = -1 \neq 1 = \phi(b_1)$.

*Case B: $5 \nmid m$.* Then $5 \nmid 4m$, and by Fermat's little theorem $(4m)^4 \equiv 1 \pmod 5$. Also $4 \mid (4m)^4$. Hence $(4m)^4 \equiv 16 \pmod{20}$. Put $b_1 = 1$ and $b_2 = 1 + (4m)^4$. Then $b_2$ is odd, $b_2 \equiv 1 \pmod m$, and $b_2 \equiv 17 \pmod{20}$, so $\phi(b_2) = -1 \neq 1 = \phi(b_1)$.

In both cases $m$ fails to determine the fork. $\square$

The two witnesses correspond to the two factors of the character (Section 5). Case A changes $b$ by a multiple of $10$ that is $\equiv 2 \pmod 4$. This keeps $b \bmod 5$ fixed and flips $b \bmod 4$ between $1$ and $3$, so it flips $\chi_4$. Case B changes $b$ by a number $\equiv 0 \pmod 4$ and $\equiv 1 \pmod 5$. This keeps $b \bmod 4$ fixed and moves $b \bmod 5$ from $1$ to $2$, a non-residue, so it flips $\left(\frac{\cdot}{5}\right)$.

*Examples.* For $m = 16$ the witnesses are $1$ and $1+64^4 = 16{,}777{,}217 \equiv 17 \pmod{20}$. For $m = 5$ they are $1$ and $51 \equiv 11 \pmod{20}$. For $m = 319$ they are $1$ and $1 + 1276^4 = 2{,}650{,}957{,}086{,}977 \equiv 17 \pmod{20}$.

**Corollary 4.4 (the conductor is $20$).** Let the **conductor** of the fork be the least positive integer determining it. It exists because $20$ determines the fork, and
$$
\text{conductor} = 20 \neq 320.
$$
Moreover $20 = |d(\mathbb{Q}(\sqrt{-5}))|$, in accordance with the conductor–discriminant formula for quadratic fields.

*Proof.* $20$ determines the fork by Theorem 4.3. If $0 < n$ determines the fork, then $20 \mid n$, so $n \ge 20$. The final equality is Proposition 3.4. $\square$

**Corollary 4.5.** $320$ determines the fork, and so does every multiple of $20$. The set of determining moduli is exactly $20\mathbb{Z}_{\ge 0}$.

The full bit observed at $m=320$ is therefore not evidence for a conductor of $320$. It is evidence for a conductor that divides $320$, and the scan's own data (full bits at $m = 20, 40, 60, \dots$) identify that conductor as $20$.

---

## 5. Anatomy of the fork: $\chi_4 \cdot \left(\frac{\cdot}{5}\right)$

Let $\chi_4$ denote the non-trivial Dirichlet character mod $4$: $\chi_4(N) = 1$ if $N \equiv 1 \pmod 4$, $\chi_4(N) = -1$ if $N \equiv 3 \pmod 4$, and $\chi_4(N) = 0$ for even $N$.

**Theorem 5.1 (reciprocity factorisation).** For odd $N$,
$$
\left(\frac{-5}{N}\right) = \chi_4(N)\cdot\left(\frac{N}{5}\right).
$$

*Proof.* By multiplicativity in the top argument, $\left(\frac{-5}{N}\right) = \left(\frac{-1}{N}\right)\left(\frac{5}{N}\right)$. The first supplementary law gives $\left(\frac{-1}{N}\right) = \chi_4(N)$ for odd $N$. Since $5 \equiv 1 \pmod 4$, quadratic reciprocity for Jacobi symbols gives $\left(\frac{5}{N}\right) = \left(\frac{N}{5}\right)$. $\square$

The factors have conductors $4$ and $5$, and their product has conductor $\operatorname{lcm}(4,5) = 20$. Neither factor alone correlates with the fork: over primes, $p\bmod 4$ and $p\bmod 5$ each carry essentially zero information about $\phi(p)$ (Section 7).

**Theorem 5.2 (explicit rotation classes).** For odd $N$ with $5 \nmid N$,
$$
\left(\frac{-5}{N}\right) = 1 \iff N \equiv 1, 3, 7, 9 \pmod{20}.
$$

*Proof.* By periodicity, reduce to the eight odd residues mod $20$ that are prime to $5$ and read off the table in Section 4. $\square$

---

## 6. The quintic side: ramification and Frobenius

### 6.1 Frobenius from root counts

For a prime $p \nmid 10$, write $r(p) = \#\{t \in \{0,\dots,p-1\} : t^5+20t+32 \equiv 0 \pmod p\}$ for the number of roots of $f$ in $\mathbb{F}_p$. By Dedekind's theorem the cycle type of $\mathrm{Frob}_p$ acting on the roots equals the degree pattern of the factorisation of $f \bmod p$. In $D_5 \subset S_5$ there are three cycle types:

| class in $D_5$ | size | cycle type | factorisation of $f \bmod p$ | $r(p)$ |
|---|---|---|---|---|
| identity | 1 | $1^5$ | five linear factors | 5 |
| rotations of order 5 | 4 | $5$ | irreducible quintic | 0 |
| reflections | 5 | $1\,2^2$ | linear $\times$ quadratic $\times$ quadratic | 1 |

Hence $\mathrm{Frob}_p \subset C_5 \iff r(p) \in \{0,5\}$. This gives the root-count version of the fork.

### 6.2 Ramified primes

**Proposition 6.1.** In $\mathbb{F}_5[x]$, $x^5 + 20x + 32 = (x+2)^5$. In $\mathbb{F}_2[x]$, $x^5+20x+32 = x^5$.

*Proof.* In characteristic $5$, $(x+2)^5 = x^5 + 2^5 = x^5 + 32$ by the Frobenius (freshman's dream) identity, and $20 \equiv 0$. In characteristic $2$, both $20$ and $32$ vanish. $\square$

These are the totally ramified shapes expected at the two primes dividing the conductor $20$, which are also the only primes dividing $\Delta(20,32) = 2^{18}5^6$.

### 6.3 A complete Frobenius certificate below 400

**Theorem 6.2 (finite certificate).** For every prime $p$ with $3 \le p < 400$ and $p \neq 5$:
$$
r(p) \in \{0, 5\} \iff p \equiv 1, 3, 7, 9 \pmod{20}.
$$

*Proof.* This is an exhaustive finite check. For each of the $76$ primes in range, count the roots of $f$ in $\mathbb{F}_p$ directly and compare with $p \bmod 20$. $\square$

**Theorem 6.3 (the fork is the character of $\mathbb{Q}(\sqrt{-5})$ below 400).** For every prime $p$ with $3\le p<400$ and $p\neq 5$:
$$
\mathrm{Frob}_p \subset C_5\ \ (\text{i.e. } r(p)\in\{0,5\}) \iff \left(\frac{-5}{p}\right) = 1 .
$$

*Proof.* Combine Theorem 6.2 with Theorem 5.2, using that such $p$ is odd and prime to $5$. $\square$

Combined with Corollary 4.4, this identifies the fork as a character of conductor $20$ on all primes in the certified range. Since a quadratic subfield $K = \mathbb{Q}(\sqrt d)$ produces the character $\left(\frac{d(K)}{\cdot}\right)$ on primes, and distinct quadratic fields produce characters that differ at some prime (and in fact at a positive proportion of primes), this singles out $K = \mathbb{Q}(\sqrt{-5})$. A proof that the identity in Theorem 6.3 holds for *all* primes requires exhibiting $\sqrt{-5}$ inside $F$. We discuss this in Section 9.

---

## 7. Numerical evidence and the conductor scan

The following computations are numerical observations and not part of the proofs above. They are reproduced by the accompanying script.

**Root-count statistics.** Among the $428$ primes $p < 3000$ with $p \nmid 10$:

| $r(p)$ | Frobenius class | count | frequency | Chebotarev density |
|---|---|---|---|---|
| 1 | reflection | 221 | 0.516 | 1/2 |
| 0 | 5-cycle | 175 | 0.409 | 2/5 |
| 5 | identity | 32 | 0.075 | 1/10 |

The equivalence $r(p)\in\{0,5\} \iff \left(\frac{-5}{p}\right)=1$ holds for every one of these primes. The first primes with $r(p)=5$ are $67, 103, 269, 283, 449, 509, 563, 587$.

**Balance.** Among the $2260$ primes $p < 20000$ with $p\nmid 10$, $\left(\frac{-5}{p}\right) = +1$ for $1124$ and $-1$ for $1136$. This matches the density $1/2$ of the $C_5$-coset.

**Conductor scan.** Over the same primes, the mutual information $I(p\bmod m;\ \phi(p))$, in bits:

| $m$ | 4 | 5 | 10 | 16 | 20 | 40 | 60 | 64 | 160 | 320 |
|---|---|---|---|---|---|---|---|---|---|---|
| $I$ | 0.0000 | 0.0001 | 0.0001 | 0.0007 | 1.0000 | 1.0000 | 1.0000 | 0.0045 | 1.0000 | 1.0000 |

This is Theorem 4.3 seen through a statistical lens. Full information appears exactly at the multiples of $20$. Non-multiples, including $64$ and $16$ (the $2$-parts of $320$), carry essentially no information. The factors $4$ and $5$ of the conductor carry none on their own, as Theorem 5.1 predicts. (Over primes, the mutual information at a determining modulus is exactly $H(\phi)$, which is $1$ bit up to the small imbalance $1124$ vs. $1136$.)

---

## 8. Algorithms

**Algorithm 1 (root-count Frobenius classifier).** Input a prime $p\nmid 10$. Evaluate $t^5+20t+32 \bmod p$ for $t = 0,\dots,p-1$ using Horner's rule, and count the zeros. Return *identity* if the count is $5$, *5-cycle* if $0$, *reflection* if $1$. The cost is $O(p)$ modular operations. For large $p$ one would instead compute $\gcd(f, x^p - x)$ in $\mathbb{F}_p[x]$ by repeated squaring, at a cost of $O(\log p)$ polynomial multiplications of degree $<5$.

**Algorithm 2 (Jacobi symbol).** Compute $\left(\frac{a}{n}\right)$ for odd $n>0$ by the binary reciprocity algorithm: reduce $a \bmod n$, strip factors of $2$ using $\left(\frac{2}{n}\right) = (-1)^{(n^2-1)/8}$, swap $a,n$ with sign $(-1)^{\frac{a-1}{2}\frac{n-1}{2}}$, and repeat. This takes $O(\log n)$ steps.

**Algorithm 3 (exact conductor scan).** For $m = 1, 2, \dots$: test whether $\phi$ is constant on each residue class of odd $N$ mod $m$. It suffices to test $N$ up to $\operatorname{lcm}(m,20) + m$, because $\phi$ is $20$-periodic. Return the first $m$ that passes. By Theorem 4.3 this returns $20$ after $20$ rounds. Unlike a mutual-information threshold, this search cannot return a proper multiple of the conductor.

**Algorithm 4 (witness construction).** Given $m$ with $20 \nmid m$, output the pair $(1, 1+5\operatorname{lcm}(m,2))$ if $5\mid m$, and $(1, 1+(4m)^4)$ otherwise. By the proof of Theorem 4.3 these agree mod $m$ but have forks $+1$ and $-1$. This gives a certificate, checkable in constant time, that $m$ is not a determining modulus.

**Algorithm 5 (fundamental-discriminant test).** Given $D$, accept if $D \equiv 1 \pmod 4$ and $D$ is squarefree, or if $D = 4m$ with $m$ squarefree and $m\equiv 2,3 \pmod 4$. Applied to a claimed quadratic discriminant, this test rejects $\pm 320$ immediately.

---

## 9. Discussion

**What the scan measured.** The scan's measurement, one bit at $m = 320$, is correct: $320$ does determine the fork (Corollary 4.5). The error was in the inference from "determining" to "minimal". Theorem 4.3 shows the determining moduli form the ideal $20\mathbb{Z}$, so the correct output of any conductor scan is the *generator* of that ideal, namely the least full-bit modulus. The proper multiples $40, 60, \dots, 320$ are analogous to harmonics of a fundamental frequency.

**Two independent refutations.** THE-CONDUCTOR-IS-320 fails for two logically independent reasons. The arithmetic reason (Theorem 3.3) is that no quadratic field has discriminant $\pm320$ at all. The statistical reason (Theorem 4.3 with Theorem 6.3) is that the observed fork has minimal period $20$. The first reason costs nothing to check and should be applied to any claimed quadratic discriminant.

**Why $\sqrt{-5}$ is hidden.** Because $\Delta(f)$ is a square, the quadratic subfield is invisible to the discriminant. It has to be read off from Frobenius data, or constructed from a resolvent. The ramification data are consistent with this: $\mathbb{Q}(\sqrt{-5})$ is ramified exactly at $2$ and $5$, which are the primes at which $f$ becomes a perfect fifth power.

**Scope.** Everything in Sections 2–5 is unconditional. Section 6 is unconditional for the stated finite range of primes. The extension to all primes is the subject of the first future direction below.

---

## 10. Future directions

1. **Galois-theoretic fork identification.** *Conjecture:* for every prime $p \nmid 10$, $r(p) \in \{0,5\} \iff \left(\frac{-5}{p}\right) = 1$. The approach is to exhibit $\sqrt{-5}$ as an explicit polynomial in the roots (a Lagrange-resolvent expression), so that Frobenius acts on it through the sign character $D_5 \to \{\pm 1\}$. The finite certificate and the conductor theorem are already in place; only the resolvent identity is missing.

2. **Minimal-modulus principle for quadratic forks.** *Conjecture:* for every fundamental discriminant $D$, the function $N \mapsto \left(\frac{D}{N}\right)$ on odd $N$ is determined by $N \bmod m$ if and only if $|D| \mid m$. In particular, a conductor scan can only return multiples of a fundamental discriminant, and never $320$. The approach is to factor the character by reciprocity into prime-conductor pieces (Theorem 5.1 is the case $D=-20$) and to extend the case split "$4\nmid m$ / $5 \nmid m$" with Chinese-remainder witnesses one prime at a time.

3. **The dihedral family $x^5+20t^4x+32t^5$ and ramification.** *Conjecture:* for every such rescaling the quadratic subfield remains $\mathbb{Q}(\sqrt{-5})$, and the only primes ramified in the splitting field are $2$, $5$ and primes dividing $t$ (the latter only artificially, through the model). The discriminant $(64000t^{10})^2$ is a square for every $t$ (Proposition 2.3).

4. **Chebotarev densities in the fork statistics.** *Conjecture:* the root-count frequencies tend to $\tfrac12 : \tfrac25 : \tfrac1{10}$ (reflection : 5-cycle : identity). At $p<3000$ the counts are $221:175:32$. The $C_5$-coset has density exactly $\tfrac12$, which matches the balance $1124$ vs. $1136$ of $\left(\frac{-5}{p}\right)$ below $20000$. Dirichlet's theorem on primes in arithmetic progressions already gives density $\tfrac12$ for the fork via the residue classes mod $20$.

---

## 11. Conclusion

The quadratic subfield of the splitting field of $x^5+20x+32$ is $\mathbb{Q}(\sqrt{-5})$, with discriminant $-20$ and conductor $20$. No quadratic field has discriminant $\pm 320$. The fork character $\left(\frac{-5}{\cdot}\right)$ is determined modulo $m$ exactly when $20\mid m$, and this is the whole reason the modulus $320$ appeared to work.
