# Quadratic Reciprocity Through Five Windows, with Rigorous Proofs of Both Supplementary Laws

## Abstract

The Law of Quadratic Reciprocity — Gauss's *theorema aureum* — is among the most consequential theorems in number theory, seeding class field theory and the modern Langlands program. This paper surveys five structurally distinct proofs of the law and its two supplements, organized around a single common foundation, Euler's criterion. We then give complete, self-contained proofs of the two supplementary laws in their classical exponent form:
$$\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}}, \qquad \left(\frac{2}{p}\right) = (-1)^{\frac{p^2-1}{8}},$$
for every odd prime $p$. Crucially, our proofs of the supplements are logically **independent** of the main reciprocity law and of the Gauss-sum machinery: the first supplement follows from Euler's criterion applied at $-1$, and the second follows from Gauss's lemma together with a residue computation modulo $8$. We isolate the exact combinatorial lemma at the heart of the second supplement — that a certain count of "upper-half" multiples of $2$ has the same parity as $\frac{p^2-1}{8}$ — and prove it by reduction to the residue of $p$ modulo $8$. We conclude with algorithmic applications (fast evaluation of the Jacobi symbol) and open directions toward a unified sign functional binding the three principal proofs.

**Keywords:** quadratic reciprocity, Legendre symbol, Euler's criterion, Gauss's lemma, Gauss sums, Eisenstein lattice-point counting, Zolotarev permutation sign, supplementary laws.

## 1. Introduction

Let $p$ be an odd prime and let $a$ be an integer coprime to $p$. The **Legendre symbol** $\left(\frac{a}{p}\right)$ equals $+1$ if $a$ is a nonzero quadratic residue modulo $p$ (that is, $a \equiv x^2 \pmod p$ for some $x$) and $-1$ otherwise; by convention $\left(\frac{a}{p}\right) = 0$ when $p \mid a$. The symbol is completely multiplicative in its upper argument and depends only on $a \bmod p$.

The **Law of Quadratic Reciprocity** states that, for distinct odd primes $p$ and $q$,
$$\left(\frac{p}{q}\right)\left(\frac{q}{p}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}. \tag{QR}$$
Equivalently, $\left(\frac{p}{q}\right) = \left(\frac{q}{p}\right)$ unless $p \equiv q \equiv 3 \pmod 4$, in which case the two symbols differ in sign.

Two special cases stand apart because they cannot be reduced to (QR) — they concern the residuacity of $-1$ and $2$, and are called the **supplementary laws**:
$$\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}}, \tag{S1}$$
$$\left(\frac{2}{p}\right) = (-1)^{\frac{p^2-1}{8}}. \tag{S2}$$

This paper has two goals. First (Sections 2–5), to present five distinct proof strategies for reciprocity and its supplements, all descending from a single elementary root, and to explain what each contributes. Second (Sections 6–7), to give complete and independent proofs of (S1) and (S2), with full attention to the combinatorial parity lemma that drives (S2). Sections 8–10 treat algorithms, applications, and open problems.

Throughout, "independent" is meant in a precise, anti-circular sense: the proofs of (S1) and (S2) below do not invoke (QR), do not invoke any Gauss-sum square-value identity, and neither supplement is used to prove the other.

## 2. The common root: Euler's criterion

Every window in this paper opens from one theorem.

**Theorem 2.1 (Euler's criterion).** For an odd prime $p$ and $a$ coprime to $p$,
$$a^{\frac{p-1}{2}} \equiv \left(\frac{a}{p}\right) \pmod p.$$

*Proof sketch.* The multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of order $p-1$. If $g$ is a generator and $a = g^k$, then $a$ is a square iff $k$ is even. Meanwhile $a^{\frac{p-1}{2}} = g^{k(p-1)/2}$, which is $+1$ iff $(p-1) \mid k(p-1)/2$, i.e. iff $k$ is even. Since $a^{p-1} = 1$, the value $a^{\frac{p-1}{2}}$ is a square root of $1$, hence $\pm 1$, and it is $+1$ exactly for squares. $\square$

Euler's criterion is the sole shared ancestor of the arguments below; all logical independence claims are relative to it. It already yields (S1) with no further input (Section 6).

## 3. Window I — Gauss's lemma and the counting proof

**Lemma 3.1 (Gauss's lemma).** Let $p$ be an odd prime and $a$ coprime to $p$. Consider the half-system $a, 2a, \dots, \frac{p-1}{2}a$ reduced to representatives in $\{1, \dots, p-1\}$, and let $\mu$ be the number of these representatives exceeding $p/2$. Then
$$\left(\frac{a}{p}\right) = (-1)^{\mu}.$$

*Proof sketch.* Reducing each $ja$ into $\{1,\dots,p-1\}$ and folding representatives above $p/2$ to their negatives $p - r \in \{1,\dots,\frac{p-1}{2}\}$ produces, up to sign, a permutation of $\{1,\dots,\frac{p-1}{2}\}$. Multiplying all the congruences $ja \equiv \pm r_j$ and cancelling the common factor $\left(\frac{p-1}{2}\right)!$ leaves $a^{\frac{p-1}{2}} \equiv (-1)^\mu$; Euler's criterion converts the left side into $\left(\frac{a}{p}\right)$. $\square$

Gauss's lemma is the workhorse behind the second supplement (Section 7). It reframes residuacity as a *tally*: the parity of how many multiples of $a$ get pushed past the midpoint $p/2$.

## 4. Window II — Eisenstein's lattice-point proof of (QR)

Eisenstein's proof interprets Gauss's lemma geometrically. Applying Lemma 3.1 to compute $\left(\frac{q}{p}\right)$, the exponent $\mu$ equals $\sum_{j=1}^{(p-1)/2} \lfloor jq/p \rfloor \bmod 2$, which counts lattice points $(x,y)$ with $1 \le x \le \frac{p-1}{2}$ lying below the line $y = qx/p$ inside a $\frac{p-1}{2} \times \frac{q-1}{2}$ rectangle. Computing $\left(\frac{p}{q}\right)$ symmetrically counts the lattice points on the other side of the same diagonal. Because the diagonal $py = qx$ passes through no interior lattice point (as $\gcd(p,q)=1$), the two counts partition the rectangle's interior, whose total lattice-point count is $\frac{p-1}{2}\cdot\frac{q-1}{2}$. Hence
$$\left(\frac{p}{q}\right)\left(\frac{q}{p}\right) = (-1)^{\sum \lfloor jq/p\rfloor + \sum \lfloor iq/... \rfloor} = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}},$$
which is (QR). This is the most visual of the classical proofs: reciprocity as the partition of dots in a box by a diagonal.

## 5. Windows III–V — Gauss sums, permutation sign, and class field theory

**Window III (Gauss sums).** Fix a primitive $p$-th root of unity $\zeta$ and form the quadratic Gauss sum $g = \sum_{k=1}^{p-1}\left(\frac{k}{p}\right)\zeta^k$. One shows $g^2 = \left(\frac{-1}{p}\right)p = (-1)^{\frac{p-1}{2}}p$, tying the value directly to (S1). Working in the ring $\mathbb{Z}[\zeta]$ and comparing $g^q$ computed two ways modulo $q$ — via the Frobenius $x \mapsto x^q$ and via the multiplicativity of the symbol — yields $\left(\frac{q}{p}\right)$ on one side and $\left(\frac{p}{q}\right)$ on the other, giving (QR). Gauss sums are the prototype of $L$-function analytic machinery.

**Window IV (Zolotarev's permutation sign).** For $a$ coprime to $p$, multiplication-by-$a$ is a permutation $\pi_a$ of $\mathbb{Z}/p\mathbb{Z}$. Zolotarev's theorem states $\left(\frac{a}{p}\right) = \operatorname{sgn}(\pi_a)$. Residuacity is thereby recast as the parity of a shuffle. For coprime odd moduli this globalizes to a "grid-transpose" permutation of the $m \times n$ Chinese-Remainder array whose sign is $(-1)^{\frac{m-1}{2}\cdot\frac{n-1}{2}}$, recovering reciprocity for the Jacobi symbol.

**Window V (Class field theory).** From a structural height, (QR) is the simplest instance of Artin reciprocity: the splitting of a prime $p$ in the quadratic field $\mathbb{Q}(\sqrt{q^*})$, with $q^* = (-1)^{\frac{q-1}{2}}q$, is governed by a residue symbol, and Artin's reciprocity map identifies this splitting with the Legendre symbol. This is the modern lens that subsumes all classical reciprocity laws.

These three routes — III, IV, and V — are, together with the elementary counting of Windows I–II, structurally independent arguments sharing only Euler's criterion.

## 6. The first supplementary law

**Theorem 6.1 (First supplement, S1).** For every odd prime $p$,
$$\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}}.$$
Equivalently, $-1$ is a quadratic residue modulo $p$ iff $p \equiv 1 \pmod 4$.

*Proof.* By Euler's criterion, $\left(\frac{-1}{p}\right) \equiv (-1)^{\frac{p-1}{2}} \pmod p$. Both sides lie in $\{-1, +1\}$, and these two values are distinct modulo $p$ because $p$ is odd (so $p \nmid 2$). A congruence between two elements of $\{-1,+1\}$ modulo an odd prime forces equality in $\mathbb{Z}$. Hence $\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}}$. $\square$

Equivalently, one may package the sign via the nontrivial quadratic character modulo $4$: the value $\left(\frac{-1}{p}\right)$ equals $+1$ when $p \equiv 1 \pmod 4$ and $-1$ when $p \equiv 3 \pmod 4$, and $(-1)^{\frac{p-1}{2}}$ realizes exactly this dichotomy since $\frac{p-1}{2}$ is even iff $p \equiv 1 \pmod 4$. This proof uses only Euler's criterion — no Gauss sums, no reciprocity.

**Corollary 6.2 (Two-squares connection).** An odd prime is a sum of two integer squares iff $p \equiv 1 \pmod 4$. The forward implication rests on $-1$ being a residue, i.e. on Theorem 6.1.

## 7. The second supplementary law

The second supplement is the substantive combinatorial result. We prove it via Gauss's lemma applied to $a = 2$, isolating the parity computation as an independent lemma.

### 7.1 The relevant count

Applying Gauss's lemma with $a = 2$, we must count
$$\mu = \#\left\{ x : 1 \le x \le \tfrac{p-1}{2},\ \left(2x \bmod p\right) > \tfrac{p}{2}\right\}.$$

**Lemma 7.1 (Counting the upper-half doublings).** For an odd prime $p \ne 2$,
$$\mu = \left\lfloor \tfrac{p}{2}\right\rfloor - \left\lfloor \tfrac{p}{4}\right\rfloor.$$

*Proof.* For $1 \le x \le \frac{p-1}{2}$ we have $2 \le 2x \le p-1 < p$, so $2x$ is already its own least nonnegative residue: $(2x \bmod p) = 2x$. The upper-half condition $2x > p/2$ is therefore equivalent to $x > p/4$. Thus the qualifying $x$ are exactly those with $\lfloor p/4 \rfloor < x \le \lfloor p/2 \rfloor$, an interval of integers of length $\lfloor p/2\rfloor - \lfloor p/4\rfloor$. $\square$

### 7.2 The parity identity

**Lemma 7.2 (Parity of the count).** For an odd natural number $p$,
$$\left(\left\lfloor \tfrac{p}{2}\right\rfloor - \left\lfloor \tfrac{p}{4}\right\rfloor\right) \equiv \frac{p^2-1}{8} \pmod 2.$$

*Proof.* Write $p = 8k + r$ with $0 \le r < 8$; since $p$ is odd, $r \in \{1,3,5,7\}$. Then
$$p^2 = 64k^2 + 16kr + r^2,\qquad \frac{p^2-1}{8} = 8k^2 + 2kr + \frac{r^2-1}{8},$$
so modulo $2$ the exponent depends only on $\frac{r^2-1}{8}$. Likewise $\lfloor p/2\rfloor - \lfloor p/4\rfloor$ modulo $2$ depends only on $r$ (the $8k$ contributes $4k - 2k = 2k$, even). Checking the four odd residues:

| $r$ | $\frac{r^2-1}{8}\bmod 2$ | $(\lfloor r/2\rfloor - \lfloor r/4\rfloor)\bmod 2$ |
|-----|--------------------------|----------------------------------------------------|
| $1$ | $0$ | $0-0=0$ |
| $3$ | $1$ | $1-0=1$ |
| $5$ | $1$ | $2-1=1$ |
| $7$ | $0$ | $3-1=2\equiv 0$ |

The columns agree for every odd $r$, proving the congruence. $\square$

### 7.3 The theorem

**Theorem 7.3 (Second supplement, S2).** For every odd prime $p$,
$$\left(\frac{2}{p}\right) = (-1)^{\frac{p^2-1}{8}}.$$
Equivalently, $2$ is a quadratic residue modulo $p$ iff $p \equiv \pm 1 \pmod 8$.

*Proof.* Since $p$ is odd, $2 \not\equiv 0 \pmod p$, so Gauss's lemma applies to $a = 2$ and gives $\left(\frac{2}{p}\right) = (-1)^{\mu}$ with $\mu$ as above. By Lemma 7.1, $\mu = \lfloor p/2\rfloor - \lfloor p/4\rfloor$; by Lemma 7.2, $\mu \equiv \frac{p^2-1}{8} \pmod 2$. Since $(-1)^N$ depends only on $N \bmod 2$, we conclude $\left(\frac{2}{p}\right) = (-1)^{\frac{p^2-1}{8}}$. The residue-class reformulation follows because $\frac{p^2-1}{8}$ is even exactly when $r \in \{1,7\}$, i.e. $p \equiv \pm 1 \pmod 8$. $\square$

This proof depends only on Gauss's lemma (hence on Euler's criterion) plus the elementary modulo-$8$ computation. It uses neither reciprocity, nor Gauss sums, nor the first supplement.

**Supporting fact used above.** For an odd prime $p$, the integer $2$ is nonzero modulo $p$: if $p \mid 2$ then $p = 2$, contradicting oddness. This is what licenses the application of Gauss's lemma at $a=2$.

## 8. Algorithms

The theory yields fast algorithms. The **Jacobi symbol** $\left(\frac{a}{n}\right)$ for odd $n>0$ extends the Legendre symbol multiplicatively over the prime factorization of $n$; reciprocity and the supplements hold for it verbatim (with $\pm 1 \pmod 8$ and $\pmod 4$ conditions read off $n$).

**Fast Jacobi evaluation.** Using (a) multiplicativity, (b) the second supplement to strip factors of $2$, and (c) reciprocity to swap $\left(\frac{a}{n}\right) \leftrightarrow \left(\frac{n}{a}\right)$, one computes $\left(\frac{a}{n}\right)$ in $O(\log^2 n)$ bit operations *without factoring $n$* — a structure exactly mirroring the Euclidean algorithm. This is the standard subroutine behind the Solovay–Strassen primality test and quadratic-residue-based cryptography.

## 9. Applications

- **Sums of two squares.** Corollary 6.2: primes $\equiv 1 \pmod 4$ are sums of two squares, powered by (S1).
- **Primality testing.** The Solovay–Strassen test compares $a^{(n-1)/2} \bmod n$ against the Jacobi symbol $\left(\frac{a}{n}\right)$; agreement for random $a$ is strong evidence of primality (Euler witnesses).
- **Cryptography.** The hardness of the quadratic residuosity problem — distinguishing residues from non-residues modulo a composite of unknown factorization — underlies the Goldwasser–Micali cryptosystem and related constructions. The Jacobi symbol is efficiently computable, but residuosity modulo a composite is not, and this gap is the security assumption.
- **Coding and pseudorandomness.** Legendre-symbol sequences $\left(\frac{n}{p}\right)$ furnish quadratic-residue codes and low-autocorrelation binary sequences.

## 10. Discussion and future directions

The five windows are not redundant. Each links reciprocity to a different mathematical domain — elementary congruences (Euler), combinatorial counting (Gauss's lemma), lattice geometry (Eisenstein), harmonic analysis over finite fields (Gauss sums), and Galois symmetry (Zolotarev / class field theory). Their agreement is itself informative: it certifies the golden theorem as *overdetermined*, cornered simultaneously from many directions.

Three concrete conjectural directions emerge.

**Permutation-sign reciprocity for all odd moduli.** For coprime odd $m,n$, the product $\left(\frac{m}{n}\right)\left(\frac{n}{m}\right)$ should equal the sign of the grid-transpose permutation of the $m \times n$ Chinese-Remainder array, which equals $(-1)^{\frac{m-1}{2}\cdot\frac{n-1}{2}}$. Reciprocity thereby becomes a pure statement about shuffling a rectangle, generalizing past primes to all odd moduli.

**A unified sign functional.** One seeks a single integer-valued invariant $\Phi(a,p)$ — simultaneously a Frobenius eigenvalue, a lattice-point parity, and a permutation sign — with $\Phi(a,p) = \left(\frac{a}{p}\right)$ in all three descriptions, so that the three classical proofs become three evaluations of one functional and their pairwise agreements encode genuine combinatorial identities.

**Higher supplements in exponent form.** For every fixed small integer $d$, the value $\left(\frac{d}{p}\right)$ should admit a closed exponent formula $(-1)^{f_d(p)}$ with $f_d$ an explicit quadratic quasi-polynomial in $p \bmod 4d$, the period $4d$ being optimal exactly when $d$ is squarefree — extending the two supplements $\frac{p-1}{2}$ and $\frac{p^2-1}{8}$ into a single conductor-controlled family.

## 11. Conclusion

We have surveyed five structurally independent proofs of quadratic reciprocity, all descending from Euler's criterion, and given complete, mutually independent proofs of both supplementary laws in exponent form: $\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}}$ and $\left(\frac{2}{p}\right) = (-1)^{\frac{p^2-1}{8}}$. The second supplement was reduced to a transparent parity identity between the count of upper-half doublings and $\frac{p^2-1}{8}$, settled by a residue computation modulo $8$. These results anchor a rich algorithmic and cryptographic toolkit and point toward a unified combinatorial account of reciprocity across its many proofs.
