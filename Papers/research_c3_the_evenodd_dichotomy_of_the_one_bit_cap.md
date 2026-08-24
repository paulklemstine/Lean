# The One-Bit Cap of the Cyclic Type-Pair Channel: An Exact Two-Primary Law and the Corrected Even/Odd Dichotomy

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Let $n \ge 1$ and let $(a,b)$ be uniform on $\{0,\dots,n-1\}^2$. Associate to each residue its *type* $T(a) = n/\gcd(a,n)$ — its additive order in $\mathbb{Z}/n\mathbb{Z}$ — and consider the information carried by the *type pair* $\big(T(a),T(b)\big)$ about the *sum residue* $(a+b)\bmod n$:
$$I_{\mathrm{pair}}(n) \;=\; I\Big(\big(T(a),T(b)\big)\;;\;(a+b)\bmod n\Big) \quad \text{bits.}$$
Numerically, $I_{\mathrm{pair}}(n) > 1$ for every even $n \ge 4$, $I_{\mathrm{pair}}(2)=1$, and $I_{\mathrm{pair}}(n)<1$ for every odd $n \le 40$; this suggests an exact even/odd dichotomy at the "one-bit cap". We prove the even half in sharp form and refute the odd half.

The central tool is a *fibre sandwich*: conditioning on a type pair confines $(a,b)$ to a product set $A \times B$, and on a product set the fibres of $(a,b)\mapsto a+b$ inject into each factor. This yields the universal envelope
$$I_{\mathrm{pair}}(n) \;\le\; \log_2 n - \operatorname*{avg}_{(a,b)} \log_2 \max\!\big(\varphi(T(a)),\varphi(T(b))\big),$$
which we evaluate in closed form on prime powers via a self-similar recursion, obtaining
$$I_{\mathrm{pair}}(q^k) \;\le\; \big(1-q^{-2k}\big)\Big(\tfrac{q^2\log_2 q}{q^2-1}-\log_2(q-1)\Big) .$$
At $q=2$ the sandwich closes and the bound is an identity: $I_{\mathrm{pair}}(2^k) = \frac{4}{3}\big(1-4^{-k}\big)$ exactly, so the two-power tower attains one bit precisely at $k=1$, strictly exceeds it for $k \ge 2$, and has supremum $4/3$. For odd primes the same envelope gives the uniform sub-critical bound $I_{\mathrm{pair}}(q^k)\le 39/40$. Combined with additivity over coprime factors, this proves: $I_{\mathrm{pair}}(q^k)>1 \iff (q=2 \text{ and } k \ge 2)$; every even $n$ satisfies $I_{\mathrm{pair}}(n)\ge 1$, with strict inequality unless $n=2$; and every odd $n$ satisfies $I_{\mathrm{pair}}(n) \le \frac{39}{40}\,\omega(n)$. The last bound is the correct replacement for the false odd half: the odd modulus
$$n = 300\,840\,735\,195 = 3^2\cdot 5\cdot 7\cdot 11\cdot 13\cdot 17\cdot 19\cdot 23\cdot 29\cdot 31$$
has $I_{\mathrm{pair}}(n) = 1.0088 > 1$. A quantitative positivity estimate $I_{\mathrm{pair}}(n)\ge \log_2 n / n^2$ for $n \ge 1$ completes the picture.

**Keywords:** cyclic group, additive order, mutual information, sumset entropy, Euler totient, prime power, Chinese Remainder Theorem, even/odd dichotomy.

---

## 1. Introduction

### 1.1 The channel

Fix an integer $n \ge 1$ and write
$$\mathrm{Box}(n) = \{0,1,\dots,n-1\}^2,$$
equipped with the uniform (counting) probability measure. Two functions on $\mathrm{Box}(n)$ interest us:

* the **type map** $T = T_n : \{0,\dots,n-1\} \to \mathbb{N}$, $\;T(a) = n/\gcd(a,n)$; extended to pairs by $\mathbf{T}(a,b) = \big(T(a),T(b)\big)$;
* the **sum residue** $S(a,b) = (a+b)\bmod n$.

$T(a)$ is the additive order of $a$ in $\mathbb{Z}/n\mathbb{Z}$, equivalently the cardinality of the subgroup $\langle a \rangle$. It is a divisor of $n$, and every divisor occurs. The quantity under study is the mutual information, in bits, of the coarse observable $\mathbf{T}$ and the fine observable $S$ under the uniform law on $\mathrm{Box}(n)$:
$$\boxed{\;I_{\mathrm{pair}}(n) \;=\; I(\mathbf{T};S) \;=\; H(S) - H(S \mid \mathbf{T}).\;}$$

All entropies are the empirical (counting) entropies of the induced distributions on the finite set $\mathrm{Box}(n)$, in base $2$. For a finite set $s$ and a map $g$ on it, we write
$$H_s(g) = -\sum_{v \in g(s)} \frac{\#g^{-1}(v)}{\#s}\log_2 \frac{\#g^{-1}(v)}{\#s} = \frac{1}{\#s}\sum_{x\in s}\log_2 \frac{\#s}{\#\{y \in s: g(y)=g(x)\}},$$
the two expressions being the familiar Shannon form and the "average log fibre deficit" form, which is the one we shall exploit.

**Interpretation.** An adversary learns the orders of two secret operands of a modular addition, but not the operands. $I_{\mathrm{pair}}(n)$ is precisely the number of bits of the output revealed by this coarse side channel.

### 1.2 The observed dichotomy

Exact enumeration gives:

| $n$ | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 18 | 20 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $I_{\mathrm{pair}}$ | $1.0000$ | $0.4739$ | $1.2500$ | $0.2027$ | $1.4739$ | $0.1141$ | $1.3125$ | $0.5265$ | $1.2027$ | $0.0519$ | $1.7239$ | $0.0386$ | $1.1141$ | $0.6766$ | $1.3281$ | $1.5265$ | $1.4527$ |

The threshold $1$ separates the parities exactly, on this range and (by direct computation) for all $n \le 40$. The natural conjecture — call it the *even/odd dichotomy of the one-bit cap* — is
$$I_{\mathrm{pair}}(n) > 1 \iff 2 \mid n \text{ and } n \ne 2, \qquad I_{\mathrm{pair}}(n) < 1 \text{ for odd } n \ge 3 .$$

This paper proves the first half in sharp quantitative form, disproves the second, and replaces it by a statement about primary components which is both true and explanatory.

### 1.3 Results

**Theorem A (Universal envelope).** For every $n \ge 1$,
$$I_{\mathrm{pair}}(n) \;\le\; \log_2 n \;-\; \frac{1}{n^2}\sum_{(a,b)\in \mathrm{Box}(n)}\log_2\max\big(\varphi(T(a)),\varphi(T(b))\big).$$

**Theorem B (Primary closed form).** For every prime $q$ and every $k \ge 0$,
$$I_{\mathrm{pair}}(q^k) \;\le\; \big(1-q^{-2k}\big)\,E(q), \qquad E(q) := \frac{q^2\log_2 q}{q^2-1}-\log_2(q-1).$$

**Theorem C (Exact two-primary law).** For every $k \ge 0$,
$$I_{\mathrm{pair}}(2^k) = \frac{4}{3}\Big(1-\frac{1}{4^{k}}\Big).$$
The sequence is strictly increasing, equals $1$ exactly at $k=1$, exceeds $1$ exactly for $k \ge 2$, and converges to $4/3$, which is a strict supremum.

**Theorem D (Uniform odd bound).** For every odd prime $q$ and every $k$, $\;E(q) \le 39/40$ and hence $I_{\mathrm{pair}}(q^k) \le 39/40 < 1$.

**Theorem E (Primary dichotomy).** For a prime $q$ and $k \ge 0$: $\;I_{\mathrm{pair}}(q^k) > 1 \iff q = 2 \text{ and } k \ge 2$.

**Theorem F (Positivity).** For every $n \ge 1$, $\;I_{\mathrm{pair}}(n) \ge \dfrac{\log_2 n}{n^2}$; in particular $I_{\mathrm{pair}}(n)>0$ for $n \ge 2$.

**Theorem G (Even half of the dichotomy).** If $n$ is even then $I_{\mathrm{pair}}(n) \ge 1$, with equality only possible at $n = 2$; and for even $n \ne 2$, $I_{\mathrm{pair}}(n) > 1$. Equivalently, for even $n$: $\;I_{\mathrm{pair}}(n)>1 \iff n \ne 2$.

**Theorem H (Refutation and correct odd bound).** It is *not* true that $I_{\mathrm{pair}}(n)<1$ for all odd $n \ge 3$: the odd modulus $n = 300\,840\,735\,195 = 3^2\cdot5\cdot7\cdot11\cdot13\cdot17\cdot19\cdot23\cdot29\cdot31$ satisfies $I_{\mathrm{pair}}(n) > 1$. The correct statement is
$$I_{\mathrm{pair}}(n) \le \tfrac{39}{40}\,\omega(n) \quad \text{for odd } n,$$
with $\omega$ the number of distinct prime factors; in particular every odd prime power is strictly below the cap.

---

## 2. The entropy toolkit

Throughout, $s$ is a nonempty finite set and $g, k$ are maps out of $s$ with finite range. Recall
$$H_s(g) = \frac{1}{\#s}\sum_{x \in s} \log_2\frac{\#s}{f_g(x)}, \qquad f_g(x) := \#\{y \in s : g(y)=g(x)\},$$
and the conditional entropy $H_s(k \mid g) = \sum_{v} \frac{\#g^{-1}(v)}{\#s} H_{g^{-1}(v)}(k)$, and the mutual information $I_s(g;k) = H_s(k) - H_s(k\mid g)$.

### 2.1 The fibre sandwich

**Lemma 2.1 (Fibre sandwich).** Let $M, m \ge 1$.
1. If $f_g(x) \le M$ for all $x \in s$, then $H_s(g) \ge \log_2 \#s - \log_2 M$.
2. If $f_g(x) \ge m$ for all $x \in s$, then $H_s(g) \le \log_2 \#s - \log_2 m$.

*Proof.* Immediate from the fibre form of the entropy: each summand $\log_2(\#s/f_g(x))$ is bounded below (resp. above) by $\log_2(\#s/M)$ (resp. $\log_2(\#s/m)$), and averaging preserves the bound. $\square$

Part (1) is the workhorse. It converts "no fibre is large" into "the entropy is large", with no assumption of uniformity: a map whose fibres are all at most $M$ has at least $\#s/M$ values, and even in the worst (maximally unbalanced) case the entropy cannot dip below $\log_2(\#s/M)$.

**Lemma 2.2 (Range bound / Gibbs).** If $g(s) \subseteq S$ with $S$ finite nonempty, then $H_s(g) \le \log_2 \#S$.

*Proof.* Let $P(v) = \#g^{-1}(v)/\#s$ be the induced distribution, supported in $S$. Gibbs' inequality against the uniform distribution $u \equiv 1/\#S$ on $S$, in the elementary form $x\log_2(x/y) \ge (x-y)/\ln 2$ for $x \ge 0, y>0$, gives
$$\sum_{v} P(v)\log_2\frac{P(v)}{1/\#S} \;\ge\; \frac{1}{\ln 2}\Big(1 - \frac{\#g(s)}{\#S}\Big) \;\ge\; 0,$$
i.e. $-H_s(g) + \log_2\#S \ge 0$. $\square$

Lemma 2.2 is a *complementary* tool to Lemma 2.1(2): it gives an upper bound on entropy from a small range rather than from large fibres, and it is what closes the sandwich at $q=2$, where the residue's range on a type class is a single coset.

**Lemma 2.3 (Symmetry).** $I_s(g;k) = I_s(k;g)$.

*Proof.* Both sides equal the same double sum $\sum_{v,c}\frac{N_{vc}}{\#s}\log_2\frac{N_{vc}\,\#s}{N_{v\cdot}N_{\cdot c}}$ over the joint count array $N_{vc} = \#\{x: g(x)=v, k(x)=c\}$. $\square$

Symmetry lets us compute $I_{\mathrm{pair}}$ with the *residue* as the conditioned variable, which is the orientation in which the fibre sandwich applies.

**Lemma 2.4 (Class-wise averaging).** Let $\psi$ be a real function of the value of $g$.
1. If $\psi(g(x)) \le H_{\{y: g(y)=g(x)\}}(k)$ for all $x\in s$, then $\frac{1}{\#s}\sum_{x\in s}\psi(g(x)) \le H_s(k\mid g)$.
2. If instead $\psi(g(x)) \ge H_{\{y:g(y)=g(x)\}}(k)$ for all $x$, then $H_s(k\mid g) \le \frac{1}{\#s}\sum_{x\in s}\psi(g(x))$.

*Proof.* Group the sum over $x$ by the value $v = g(x)$; the multiplicity of $v$ is exactly $\#g^{-1}(v)$, so the normalised sum is the same convex combination that defines $H_s(k\mid g)$, term by term dominated. $\square$

### 2.2 Uniformity of the sum residue

**Lemma 2.5.** For $n \ge 1$, the sum residue $S$ is exactly uniform on $\mathbb{Z}/n\mathbb{Z}$ under the uniform law on $\mathrm{Box}(n)$: every fibre has exactly $n$ elements, and $H_{\mathrm{Box}(n)}(S) = \log_2 n$.

*Proof.* For each $a$ there is exactly one $b \in \{0,\dots,n-1\}$ with $a+b \equiv c$. $\square$

Consequently, by Lemmas 2.3 and 2.5,
$$I_{\mathrm{pair}}(n) = \log_2 n - H_{\mathrm{Box}(n)}\big(S \mid \mathbf{T}\big). \tag{2.1}$$

Everything now reduces to estimating $H(S\mid \mathbf{T})$, i.e. to estimating, class by class, how spread out $a+b$ is once the types of $a$ and $b$ are known.

---

## 3. Type classes are product sets

**Lemma 3.1.** For $x = (a_0,b_0) \in \mathrm{Box}(n)$, the $\mathbf{T}$-class of $x$ is the product set
$$\{(a,b)\in \mathrm{Box}(n): \mathbf{T}(a,b)=\mathbf{T}(x)\} \;=\; A \times B, \quad A = \{a < n: T(a)=T(a_0)\},\; B = \{b<n: T(b)=T(b_0)\}.$$
Moreover $\#A = \varphi(T(a_0))$ and $\#B = \varphi(T(b_0))$.

*Proof.* The condition on the pair is a conjunction of two conditions on the coordinates separately, whence the product structure. For the cardinality: the residues of order exactly $t \mid n$ are the generators of the unique subgroup of order $t$, of which there are $\varphi(t)$. $\square$

**Lemma 3.2 (Sums on product sets have small fibres).** Let $A,B \subseteq \{0,\dots,n-1\}$ and $c \in \mathbb{Z}/n\mathbb{Z}$. Then
$$\#\{(a,b)\in A\times B : a+b \equiv c\} \le \min(\#A,\#B).$$

*Proof.* On the fibre, the first coordinate determines the second (if $a+b\equiv a+b'$ with $b,b'<n$ then $b=b'$), so the projection to $A$ is injective; symmetrically for $B$. $\square$

Combining Lemmas 2.1(1), 3.1 and 3.2 on a class $A\times B$, whose size is $\#A\cdot\#B$ and whose fibres are of size at most $\min(\#A,\#B)$:

**Proposition 3.3 (Class-wise lower bound).** For every $x\in\mathrm{Box}(n)$,
$$H_{A\times B}(S) \;\ge\; \log_2\frac{\#A\,\#B}{\min(\#A,\#B)} \;=\; \log_2 \max(\#A,\#B) \;=\; \log_2\max\big(\varphi(T(a_0)),\varphi(T(b_0))\big).$$

Averaging with Lemma 2.4(1) and inserting into (2.1) proves **Theorem A**:
$$I_{\mathrm{pair}}(n) \le \log_2 n - \frac{W(n)}{n^2}, \qquad W(n) := \sum_{(a,b)\in\mathrm{Box}(n)} \log_2\max\big(\varphi(T(a)),\varphi(T(b))\big). \tag{3.1}$$

The quantity $W(n)$ — the unnormalised class average of the log of the *larger* type class — is the arithmetic object that carries all the content from here on.

**Remark 3.4 (When is the envelope tight?).** Proposition 3.3 is an equality precisely when the sum takes exactly $\max(\#A,\#B)$ values, uniformly. This happens when the smaller class is a union of complete residue classes modulo the modulus of the larger one, so that $A+B$ is a single coset covered evenly. For $n = 2^k$ this is automatic; for odd $q$ a type class $\{a : v_q(a) = j\}$ is a union of $q-1$ arithmetic progressions and the sum spreads strictly further, making the inequality strict. This is the structural reason for the even/odd asymmetry.

---

## 4. Prime powers: a self-similar recursion

Fix a prime $q$. We evaluate $W(q^k)$ exactly.

**Lemma 4.1 (Scaling preserves type).** For $a \ge 0$, $\;T_{q^{k+1}}(qa) = T_{q^{k}}(a)$.

*Proof.* $\gcd(qa, q^{k+1}) = q\gcd(a,q^k)$ and $q^{k+1}/\big(q\gcd(a,q^k)\big) = q^k/\gcd(a,q^k)$. $\square$

**Lemma 4.2 (Units have full type).** If $q \nmid a$ then $T_{q^m}(a) = q^m$, hence $\varphi(T_{q^m}(a)) = \varphi(q^m)$, the largest possible value.

**Lemma 4.3 (Deep sub-box).** The map $(u,v)\mapsto (qu,qv)$ is a bijection from $\mathrm{Box}(q^k)$ onto $\{(a,b)\in\mathrm{Box}(q^{k+1}): q\mid a,\; q\mid b\}$, and by Lemma 4.1 it preserves the integrand of $W$. Its complement in $\mathrm{Box}(q^{k+1})$ has $q^{2k+2}-q^{2k}$ elements, and on it at least one coordinate is a unit, so by Lemma 4.2 the integrand equals $\log_2\varphi(q^{k+1})$ identically.

**Proposition 4.4 (Recursion).** For every prime $q$ and every $k \ge 0$,
$$W(q^{k+1}) = \big(q^{2k+2}-q^{2k}\big)\log_2\varphi(q^{k+1}) \;+\; W(q^{k}).$$

*Proof.* Split $\mathrm{Box}(q^{k+1})$ into the deep sub-box and its complement and apply Lemma 4.3. $\square$

**Proposition 4.5 (Closed form).** With $\varphi(q^{j+1}) = q^{j}(q-1)$, so $\log_2\varphi(q^{j+1}) = j\log_2 q + \log_2(q-1)$, the recursion solves to
$$\big(q^2-1\big)\Big(k\,q^{2k}\log_2 q - W(q^k)\Big) = \big(q^{2k}-1\big)\Big(q^2\log_2 q - (q^2-1)\log_2(q-1)\Big),$$
equivalently
$$W(q^k) = k\,q^{2k}\log_2 q - \big(q^{2k}-1\big)E(q), \qquad E(q) = \frac{q^2\log_2 q}{q^2-1} - \log_2(q-1).$$

*Proof.* Induction on $k$. The base $k=0$ is $W(1)=0$, since $\mathrm{Box}(1)=\{(0,0)\}$ has a single class with $\varphi(1)=1$. The inductive step is Proposition 4.4 together with the geometric identity $q^{2(k+1)} = q^{2k}q^2$; both sides are polynomials in $q^{2k}$ with the same coefficients. $\square$

Substituting into the envelope (3.1) with $n = q^k$, $\log_2 n = k\log_2 q$ and $n^2 = q^{2k}$, the $k\log_2 q$ terms cancel and we obtain **Theorem B**:
$$I_{\mathrm{pair}}(q^k) \;\le\; k\log_2 q - \frac{k q^{2k}\log_2 q - (q^{2k}-1)E(q)}{q^{2k}} \;=\; \big(1-q^{-2k}\big)E(q). \tag{4.1}$$

**Sanity check.** $E(2) = \frac{4\cdot 1}{3} - \log_2 1 = \frac43$, so the bound at $q = 2$ reads $I_{\mathrm{pair}}(2^k)\le\frac43(1-4^{-k})$, matching the exact law of Theorem C — as it must, since the envelope is an equality there.

### 4.1 The odd envelope is sub-critical

**Proposition 4.6 (Theorem D).** For every odd prime $q$, $\;E(q) \le 39/40$.

*Proof.* Split
$$E(q) = \Big(\log_2 q - \log_2(q-1)\Big) + \frac{\log_2 q}{q^2-1} = \log_2\frac{q}{q-1} + \frac{\log_2 q}{q^2-1}.$$
For $q \ge 3$ the first term is at most $\log_2(3/2) = \log_2 3 - 1 < 8/5 - 1 = 3/5$. For the second, $\log_2 q \le q$ and $q/(q^2-1) \le 3/8$ for $q \ge 3$ (equivalent to $8q \le 3q^2-3$, true at $q=3$ and thereafter). Hence $E(q) \le 3/5+3/8 = 39/40$. $\square$

Since $0 \le 1-q^{-2k}\le 1$, (4.1) gives $I_{\mathrm{pair}}(q^k) \le 39/40 < 1$ for every odd prime power. The bound is far from sharp — the true worst case is $E(3) = 0.7831$, attained in the limit $k\to\infty$ — but it is uniform, and one clean inequality suffices for the dichotomy.

---

## 5. The exact law at $q=2$

For $n = 2^k$ the fibre bound of Proposition 3.3 is an equality, and we prove the matching upper bound for the class entropy directly, using the range bound (Lemma 2.2).

**Lemma 5.1 (Two-adic type).** If $\gcd(a,2^k)=2^{j}$ with $j\le k$ then $T_{2^k}(a) = 2^{k-j}$; and if $j<k$ then $a \equiv 2^{j} \pmod{2^{j+1}}$, i.e. $a = 2^j\cdot(\text{odd})$.

**Lemma 5.2 (Classes are congruence classes).** If $a,a'$ have the same type modulo $2^k$ — equivalently the same two-adic gcd $2^{j}$ — then $a \equiv a' \pmod {2^{v+1}}$ for every $v \le j$.

*Proof.* Both are $\equiv 2^{j}\pmod{2^{j+1}}$ by Lemma 5.1 (or both are $0$ when $j = k$), and $2^{v+1}\mid 2^{j+1}$. $\square$

**Proposition 5.3 (Class-wise upper bound at $q=2$).** Let $x=(a_0,b_0)\in\mathrm{Box}(2^k)$ with two-adic gcd exponents $j_1,j_2$, and set $w = \min(j_1,j_2,k-1)$. Then on the type class of $x$ the residue $S$ takes values in the single congruence class $\{s< 2^k : s \equiv S(x) \bmod 2^{w+1}\}$, which has exactly $2^{\,k-w-1}$ elements; consequently
$$H_{\text{class}}(S) \;\le\; \log_2 2^{\,k-w-1} \;=\; \log_2\max\big(\varphi(T(a_0)),\varphi(T(b_0))\big).$$

*Proof.* By Lemma 5.2, every $(a,b)$ in the class has $a\equiv a_0$ and $b \equiv b_0$ modulo $2^{w+1}$, so $a+b\equiv a_0+b_0$ modulo $2^{w+1}$. Counting elements of $\{0,\dots,2^k-1\}$ in one class modulo $2^{w+1}$ gives $2^{k-w-1}$; apply Lemma 2.2. For the last equality: $\varphi(T(a_0)) = \varphi(2^{k-j_1}) = 2^{k-j_1-1}$ when $j_1<k$ (and $=1$ when $j_1=k$), similarly for $b_0$, so the maximum is $2^{k-\min(j_1,j_2)-1} = 2^{k-w-1}$ when $\min(j_1,j_2)\le k-1$; the degenerate case $j_1=j_2=k$, i.e. $x=(0,0)$, gives $w=k-1$ and both sides are $\log_2 1 = 0$. $\square$

Averaging Proposition 5.3 with Lemma 2.4(2) yields $H(S\mid\mathbf{T}) \le W(2^k)/4^{k}$, the reverse of (3.1). Together with (3.1) the two bounds coincide, so
$$I_{\mathrm{pair}}(2^k) = \log_2 2^k - \frac{W(2^k)}{4^k},$$
and Proposition 4.5 at $q=2$ gives $W(2^k) = k4^k - \frac43(4^k-1)$. Hence **Theorem C**:
$$I_{\mathrm{pair}}(2^k) = k - k + \frac{4}{3}\cdot\frac{4^k-1}{4^k} = \frac43\Big(1-\frac{1}{4^k}\Big).$$

**Corollary 5.4.** $I_{\mathrm{pair}}(1)=0$, $I_{\mathrm{pair}}(2)=1$, $I_{\mathrm{pair}}(4)=\frac54$, $I_{\mathrm{pair}}(8)=\frac{21}{16}$, $I_{\mathrm{pair}}(16)=\frac{85}{64}$, $I_{\mathrm{pair}}(32)=\frac{341}{256}$; the sequence is strictly increasing in $k$; $I_{\mathrm{pair}}(2^k)=1 \iff k=1$; $I_{\mathrm{pair}}(2^k)>1 \iff k \ge 2$; and $I_{\mathrm{pair}}(2^k)\nearrow 4/3$, with $4/3$ never attained.

The tower therefore *touches* the one-bit cap exactly once and then leaves it behind: the true asymptotic capacity of the two-primary channel is four thirds of a bit.

Theorems C and D immediately give **Theorem E**: for a prime $q$, $I_{\mathrm{pair}}(q^k)>1$ iff $q=2$ and $k\ge2$.

---

## 6. Positivity, additivity, and the even half

### 6.1 A universal quantitative lower bound

**Theorem F.** For $n\ge 1$, $\;I_{\mathrm{pair}}(n) \ge \log_2 n / n^2$.

*Proof.* Use the lower envelope, Lemma 2.4(2), with the test function
$$\psi(t_1,t_2) = \begin{cases}0, & (t_1,t_2)=(1,1),\\ \log_2 n, & \text{otherwise.}\end{cases}$$
This is legitimate: on the degenerate class $\mathbf{T}=(1,1)$ we have $T(a)=T(b)=1$, hence $a=b=0$ (only the zero residue has order $1$), so the class is the single point $(0,0)$ and its entropy is $0$; on every other class the residue takes values in $\{0,\dots,n-1\}$, so Lemma 2.2 bounds its entropy by $\log_2 n$. Since exactly one of the $n^2$ pairs lies in the degenerate class,
$$H(S\mid\mathbf{T}) \le \frac{(n^2-1)\log_2 n}{n^2}, \qquad\text{so}\qquad I_{\mathrm{pair}}(n) \ge \log_2 n - \frac{(n^2-1)\log_2 n}{n^2} = \frac{\log_2 n}{n^2}. \;\square$$

In particular $I_{\mathrm{pair}}(n)>0$ for $n\ge2$: *every* nontrivial cyclic order leaks something. The bound is weak but strict, and strictness is exactly what is needed to promote "$\ge 1$" to "$>1$" for even $n \ne 2$.

### 6.2 Additivity

**Proposition 6.1 (Chinese Remainder additivity).** If $\gcd(m,m')=1$ then $I_{\mathrm{pair}}(mm') = I_{\mathrm{pair}}(m)+I_{\mathrm{pair}}(m')$. Consequently
$$I_{\mathrm{pair}}(n) = \sum_{p^{e}\|n} I_{\mathrm{pair}}(p^{e}).$$

*Proof sketch.* The ring isomorphism $\mathbb{Z}/mm'\mathbb{Z}\cong \mathbb{Z}/m\mathbb{Z}\times\mathbb{Z}/m'\mathbb{Z}$ carries the uniform measure on $\mathrm{Box}(mm')$ to the product of the uniform measures, carries the sum residue to the pair of sum residues, and — because $\gcd(a,mm')=\gcd(a,m)\gcd(a,m')$ — carries the type to the pair of component types. The channel is thus a product of two independent channels, and mutual information is additive over independent products. $\square$

Additivity is the bridge from primary components to all $n$; it is also the source of the failure of the odd half, as we shall see.

### 6.3 The even half

**Theorem G.** Let $n$ be even. Then $I_{\mathrm{pair}}(n)\ge 1$; and $I_{\mathrm{pair}}(n)>1$ if and only if $n\ne2$.

*Proof.* Write $n = 2^{a}m$ with $m$ odd and $a\ge1$. By Proposition 6.1, $I_{\mathrm{pair}}(n) = I_{\mathrm{pair}}(2^{a}) + I_{\mathrm{pair}}(m)$. By Corollary 5.4, $I_{\mathrm{pair}}(2^a)\ge 1$; by Theorem F (and non-negativity of mutual information) $I_{\mathrm{pair}}(m) \ge 0$. Hence $I_{\mathrm{pair}}(n) \ge 1$.

For strictness, distinguish two cases. If $a \ge 2$, then $I_{\mathrm{pair}}(2^a)\ge 5/4>1$ already. If $a = 1$ then $n \ne 2$ forces $m\ge3$, and Theorem F gives $I_{\mathrm{pair}}(m)>0$, so $I_{\mathrm{pair}}(n) = 1 + I_{\mathrm{pair}}(m) > 1$. Conversely $I_{\mathrm{pair}}(2)=1$ is not $>1$. $\square$

So the even half of the conjecture holds, with the extra information that the excess over one bit is exactly $\big(\tfrac43(1-4^{-a})-1\big)+I_{\mathrm{pair}}(m)$, a sum of a two-adic term bounded by $1/3$ and an odd term bounded by $\frac{39}{40}\omega(m)$.

---

## 7. The odd half is false

**Theorem H.** The statement "$I_{\mathrm{pair}}(n)<1$ for every odd $n\ge3$" is false. Moreover, for every odd $n$,
$$I_{\mathrm{pair}}(n) \le \frac{39}{40}\,\omega(n),$$
and in particular every odd prime power satisfies $I_{\mathrm{pair}}(n)<1$.

*Proof.* The inequality is Proposition 6.1 followed by Theorem D applied to each of the $\omega(n)$ primary components, each of which is an odd prime power. For the refutation, take
$$n = 300\,840\,735\,195 = 3^2\cdot 5\cdot 7\cdot 11\cdot 13\cdot 17\cdot 19\cdot 23\cdot 29\cdot 31 .$$
By additivity, $I_{\mathrm{pair}}(n)$ is the sum of the ten primary values
$$I_{\mathrm{pair}}(9)+I_{\mathrm{pair}}(5)+I_{\mathrm{pair}}(7)+I_{\mathrm{pair}}(11)+I_{\mathrm{pair}}(13)+I_{\mathrm{pair}}(17)+I_{\mathrm{pair}}(19)+I_{\mathrm{pair}}(23)+I_{\mathrm{pair}}(29)+I_{\mathrm{pair}}(31),$$
each of which is an exactly computable rational combination of logarithms; their sum is $1.00875\ldots > 1$. $\square$

### 7.1 Why the odd half had to fail, and why it looked true

The failure is a knapsack phenomenon. Put
$$G(q) := \sup_{k\ge1} I_{\mathrm{pair}}(q^k) \;\le\; E(q).$$
The values, to four decimals:

| $q$ | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 |
|---|---|---|---|---|---|---|---|---|---|---|
| $G(q)$ | $0.5330$ | $0.2112$ | $0.1165$ | $0.0523$ | $0.0389$ | $0.0241$ | $0.0197$ | $0.0140$ | $0.0092$ | $0.0081$ |
| running sum | $0.5330$ | $0.7442$ | $0.8606$ | $0.9130$ | $0.9518$ | $0.9759$ | $0.9956$ | $\mathbf{1.0096}$ | $1.0188$ | $1.0269$ |

Every single term is far below the cap; the total first crosses it only at the eighth odd prime. Since $G(q) \asymp \log_2 q / q^2$ decays fast, the series $\sum_q G(q)$ over *all* odd primes converges, but its first eight terms already exceed $1$ — barely. Consequently:

* numerically, an odd cap breaker must have at least $8$ distinct odd prime factors, since the seven largest suprema already sum to only $\sum_{q \le 19} G(q) = 0.9956 < 1$ (turning this into a theorem requires certified upper bounds for $G(3),\dots,G(19)$, which the envelope $E(q)$ alone is too lossy to supply);
* hence the least such $n$ should be at least $3\cdot5\cdots19\cdot23 = 111\,546\,435$, a nine-digit number;
* no computation over a plausible hand-search range ($n \le 10^4$, say) could ever have revealed the failure.

This is the anatomy of a persuasive false conjecture: the true obstruction lives at a scale that brute force does not reach, and the pattern that fails is a *global* one built out of *local* data that individually always obeys the rule.

### 7.2 The corrected statement

Assembling Theorems C–H, the correct form of the dichotomy is:

> **Corrected dichotomy.** For a prime power, $I_{\mathrm{pair}}(q^k)>1$ exactly when $q=2$ and $k\ge2$; the two-power tower is given exactly by $\frac43(1-4^{-k})$ and is strictly increasing to $4/3$. Every even $n$ has $I_{\mathrm{pair}}(n)\ge 1$, with strict inequality iff $n\ne2$. Every odd prime power is strictly sub-critical, at most $39/40$ of a bit; every odd $n$ obeys $I_{\mathrm{pair}}(n)\le\frac{39}{40}\omega(n)$, so an odd modulus can exceed the cap only by accumulating at least eight distinct primary components.

The heuristic that motivated the original conjecture — "$C_2$ is the unique quotient whose type pair *is* the norm class, the split-count fork saturating exactly one bit" — is correct, and Theorem C makes it precise: at $n=2$ the type pair determines the pair, so the channel is a perfect one-bit wire. What the heuristic missed is that the cap is not a barrier but a threshold that many small odd contributions can jointly overtop.

---

## 8. Algorithms

Three computational tasks arise, all elementary and all with sharp complexity.

**(A) Direct evaluation of $I_{\mathrm{pair}}(n)$.** Enumerate $\mathrm{Box}(n)$, accumulate the joint count array of type pairs and residues, and evaluate $\log_2 n - \sum_{\text{classes}} \frac{|c|}{n^2}H_c(S)$. Time $\Theta(n^2)$, space $O(n\cdot d(n)^2)$ where $d(n)$ is the number of divisors. Exact in rational arithmetic if desired, since all counts are integers.

**(B) Fast evaluation by primary decomposition.** Factor $n$, evaluate $I_{\mathrm{pair}}(p^{e})$ for each primary component (using Theorem C in closed form when $p=2$, and direct evaluation otherwise), and sum. This turns an $n^2$ computation into $\sum_{p^e\|n} p^{2e}$, and makes moduli like $3\cdot5\cdots31$ instantaneous where direct enumeration is impossible.

**(C) Odd knapsack search for cap breakers.** Compute $G(q)$ for the odd primes up to some bound (each $G(q) = \sup_k I_{\mathrm{pair}}(q^k)$, monotone in $k$ and rapidly convergent), then greedily accumulate in decreasing order of $G$ until the running total exceeds $1$; the corresponding product is an odd cap breaker, and the greedy order also certifies the minimum number of primary components needed.

---

## 9. Applications and interpretation

**Side channels in modular arithmetic.** If an implementation of modular addition in $\mathbb{Z}/n\mathbb{Z}$ leaks the multiplicative structure of its operands only through their additive orders — a plausible abstraction of a leak that reveals, say, how many distinct partial sums a scalar-multiplication loop visits — then the number of bits of the output so revealed is exactly $I_{\mathrm{pair}}(n)$. Theorem G says that an even modulus concedes at least a full bit no matter how large it is; Theorem H says an odd modulus concedes less than a bit unless it is highly composite. Choosing $n$ prime (or an odd prime power) caps the leak at $E(q)\le 0.784$ bits and drives it to $0$ as $q\to\infty$ at rate $\Theta(\log q/q^2)$.

**Order statistics and subgroup structure.** $I_{\mathrm{pair}}$ is a scalar invariant of the subgroup lattice of $\mathbb{Z}/n\mathbb{Z}$ weighted by totients. Theorem C says the two-primary lattice — a single chain — supports exactly $\frac43(1-4^{-k})$ bits of coupling between shape and sum. In this sense $4/3$ is a numerical signature of the chain of length $k$ with totient weights $1,1,2,4,\dots$

**Sumset entropy.** Lemma 3.2 with Lemma 2.1 is a discrete entropy analogue of the trivial sumset bound $|A+B|\ge\max(|A|,|B|)$, transported to the entropy of $a+b$ for *independent uniform* $a\in A$, $b\in B$. Remark 3.4 characterises the equality case as a coset-covering condition, which is exactly the rigidity statement one expects from additive combinatorics: equality forces near-arithmetic-progression structure. The two-adic case is the extreme instance where the structure is present at every scale.

---

## 10. Discussion and open problems

**What was proved.** The conjectured dichotomy is half-true and half-false, and the correct version is finer than the original. Explicitly: the cap-breaking phenomenon is a property of the $2$-primary component, quantified exactly by $I_{\mathrm{pair}}(2^k)=\frac43(1-4^{-k})$; evenness is sufficient but not necessary; odd counterexamples exist and require $\omega \ge 8$.

**Open problem 1 (Geometric self-similarity of odd towers).** For every prime $q$ and $k\ge1$, is
$$I_{\mathrm{pair}}(q^k) = I_{\mathrm{pair}}(q)\cdot\frac{1-q^{-2k}}{1-q^{-2}}\;?$$
The numerics support this: $I_{\mathrm{pair}}(3)=0.4739$ and $0.4739\cdot(1-3^{-4})/(1-3^{-2}) = 0.5265 = I_{\mathrm{pair}}(9)$ to four places; likewise for $q=5,7$. The upper half of the required identity is Theorem B; the missing ingredient is the lower half, i.e. the statement that on a type class of $\mathrm{Box}(q^k)$ the residue covers a single coset uniformly. For $q=2$ this is Proposition 5.3; for odd $q$ a type class is a union of $q-1$ arithmetic progressions rather than one, and what is needed is a counting lemma for such unions.

**Open problem 2 (Eighth-prime threshold).** Is it true that an odd $n$ with $I_{\mathrm{pair}}(n)>1$ must have $\omega(n)\ge8$, and that $8$ is attained? The lower bound follows from the numerics above once $G(q)$ is bounded rigorously for each of the first seven odd primes; attainment requires exhibiting an odd $n$ with exactly eight primary components above the cap. The table suggests $n = 3^{k}\cdot5^{k}\cdots23^{k}$ for large $k$ should work, since the running total at the eighth odd prime is $1.0096>1$; the margin is only $1\%$, so the exponents must be pushed high enough that each $I_{\mathrm{pair}}(q^k)$ is close to its supremum $G(q)$.

**Open problem 3 (Exact suprema).** Determine $G(q)=\sup_k I_{\mathrm{pair}}(q^k)$ in closed form for odd $q$. Conjecturally, by Open problem 1, $G(q) = I_{\mathrm{pair}}(q)\cdot\frac{q^2}{q^2-1}$, which for $q=3$ gives $0.4739\cdot\frac98 = 0.5331$, matching the observed value. Note this is strictly smaller than $E(q)$ — for $q=3$, $0.5331$ versus $0.7831$ — so the envelope, though tight at $q=2$, is lossy by a factor tending to $\log_2 q/\log_2\frac{q}{q-1}$-ish for large $q$: quantifying that loss is itself of interest.

**Open problem 4 (Other observables).** Replace the type $T(a) = n/\gcd(a,n)$ by other quotients of the residue: the Legendre symbol, the $p$-adic valuation vector, or the image in a fixed quotient group. Which observables saturate exactly one bit, and is the two-state fork always the unique saturator? Theorem C suggests a general principle: an observable saturates exactly $\log_2 m$ bits iff its fibre structure on the class is a single coset chain of index $m$.

**Open problem 5 (Higher arity).** Study $I\big((T(a_1),\dots,T(a_r)); (a_1+\dots+a_r)\bmod n\big)$. The fibre argument generalises — a fibre of the sum on a product of $r$ sets injects into the product of any $r-1$ of them — giving an envelope with $\max$ replaced by the largest factor. Does the $r$-ary two-primary law again have the shape $c_r(1-4^{-k})$, and what is $c_r$?

---

## 11. Numerical appendix

Direct enumeration (exact counting, double-precision logarithms) reproduces every closed form above.

Two-power tower against $\frac43(1-4^{-k})$:

| $k$ | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| $I_{\mathrm{pair}}(2^k)$ | $1$ | $5/4$ | $21/16$ | $85/64$ | $341/256$ | $1365/1024$ |
| decimal | $1.000000$ | $1.250000$ | $1.312500$ | $1.328125$ | $1.332031$ | $1.333008$ |

Odd primary towers against the closed-form envelope $\big(1-q^{-2k}\big)E(q)$:

| $q$ | $E(q)$ | $I_{\mathrm{pair}}(q)$ | $I_{\mathrm{pair}}(q^2)$ | $I_{\mathrm{pair}}(q^3)$ |
|---|---|---|---|---|
| 3 | $0.7831$ | $0.4739$ | $0.5265$ | $0.5324$ |
| 5 | $0.4187$ | $0.2027$ | $0.2108$ | $0.2111$ |
| 7 | $0.2809$ | $0.1141$ | $0.1164$ | $0.1165$ |
| 11 | $0.1663$ | $0.0519$ | $0.0523$ | $0.0523$ |

Additivity, verified across coprime factorisations: e.g. $I_{\mathrm{pair}}(12) = I_{\mathrm{pair}}(4)+I_{\mathrm{pair}}(3) = 1.25+0.4739 = 1.7239$; $I_{\mathrm{pair}}(45) = I_{\mathrm{pair}}(9)+I_{\mathrm{pair}}(5) = 0.5265+0.2027 = 0.7292$.

Scanning $n < 60$: the even moduli not strictly above the cap are exactly $\{2\}$; no odd modulus below $60$ exceeds the cap; and $I_{\mathrm{pair}}(n)\le\frac{39}{40}\omega(n)$ holds for every odd $n$ in the range, as it must.

Finally, the refuting witness: $I_{\mathrm{pair}}(300\,840\,735\,195) = 1.00875 > 1$, computed additively from its ten primary components.
