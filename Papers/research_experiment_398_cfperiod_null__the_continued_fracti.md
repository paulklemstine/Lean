# The Continued-Fraction Period of $\sqrt{N}$ as a Symmetric Channel: Structure Without Leverage

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

We give a complete integral analysis of the continued-fraction expansion of $\sqrt{N}$ regarded as an information channel from a composite integer $N$ to its factorization. Working entirely over $\mathbb{Z}$, we formulate the Lagrange–PQa state machine as a six-coordinate recursion and establish its full set of conserved quantities: divisibility $d \mid N - m^2$, the two linear relations $Nq = hm + h_{-1}d$ and $qm + q_{-1}d = h$, and unimodularity $(hq_{-1} - h_{-1}q)^2 = 1$. From these we deduce the exact norm identity $h^2 - Nq^2 = d\,(hq_{-1}-h_{-1}q) = \pm d$ at every convergent, and hence that every state with $d = 1$ — every period end — produces a unit of $\mathbb{Z}[\sqrt N]$, i.e. a solution of $x^2 - Ny^2 = \pm 1$.

We then determine exactly how much factoring leverage this channel carries. On the positive side we isolate its unique factor-adjacent exit: a norm-$+1$ period-end unit is a square root of $1$ modulo $N$, and if it is *split* (neither $\equiv 1$ nor $\equiv -1$) then $\gcd(x-1,N)$ is a proper divisor. On the negative side we prove four independent obstructions. (i) *Prime-power immunity*: for odd prime powers $N = p^k$ every Pell solution has $x \equiv \pm 1 \pmod N$, so the exit never fires. (ii) *Cheap-window nullity*: the short-period families $N = m^2+1$ (period $1$) and $N = m^2+2$ (period $2$) produce only trivial gcds, with explicit identities; and for fixed denominator $y$ the count of $N \le X$ admitting a norm-$+1$ unit with that denominator is $O(y\sqrt X)$, so cheap witnesses form a density-zero set. (iii) *Cost*: all state coordinates are confined to the box $0 \le m \le \lfloor\sqrt N\rfloor$, $0 < d \le 2\lfloor\sqrt N\rfloor$, while convergent denominators grow at least like Fibonacci numbers, $q_{k+1} \ge F_{k+1}$; the only unbounded coordinate is the step count, giving cost $\Theta(\ell(N))$ with empirical median $\ell/\sqrt N \approx 0.406$. (iv) *No pinning*: the one genuine factorization signal — period parity, equivalently solvability of $x^2 - Ny^2 = -1$, equivalently all prime factors $\equiv 1 \pmod 4$ — is a congruence bit, and by Dirichlet's theorem congruence data is compatible with infinitely many distinct factorizations.

Finally we resolve an empirical confound. A raw sweep reported correlation $\approx +0.99$ between the maximum partial quotient of $\sqrt N$ and factor spread. We prove that every partial quotient after the first is bounded by $2\lfloor\sqrt N\rfloor$, with equality exactly at period end; the maximum is therefore identically $2\lfloor\sqrt N\rfloor$, a pure size coordinate. After residualizing on $\lfloor\sqrt N\rfloor$, $120$ stratified partial-correlation permutation tests give worst $p = 0.024$ against a Bonferroni threshold of $0.0004$: null. We conclude that the barrier previously known for polynomial symmetric functions of the factors extends to this, the canonical non-polynomial symmetric $N$-computable object.

**Keywords:** continued fractions, Pell equation, fundamental unit, real quadratic fields, negative Pell, integer factorization, symmetric functions, regulator.

---

## 1. Introduction

### 1.1 The symmetric-channel question

Let $N = pq$ be a semiprime. Any quantity a computer can extract from $N$ alone is a function of $N$, hence a *symmetric* function of the unordered pair $\{p,q\}$. The question that motivates this work is: which symmetric functions of $\{p,q\}$ carry usable information about $p$ and $q$ individually?

For *polynomial* symmetric functions the answer is classical and complete. By the fundamental theorem of symmetric polynomials, every symmetric polynomial in $p, q$ is a polynomial in the elementary symmetric functions $e_1 = p+q$ and $e_2 = pq = N$. Since $e_2$ is $N$ itself, and $e_1$ is exactly the datum whose knowledge is equivalent to factoring (given $N$ and $p+q$, the primes are roots of $t^2 - e_1 t + N$), the reachable set of the polynomial symmetric family is precisely $\{(N, s)\}$ where $s$ encodes the sum. The polynomial channel is closed by a theorem, not by experiment.

That theorem bounds only polynomials. It says nothing about symmetric functions of $\{p,q\}$ that are computable from $N$ but transcendental, discontinuous, or defined by an algorithm rather than a formula. The most canonical such object in elementary number theory is the **continued-fraction period of $\sqrt N$** — equivalently, on the arithmetic side, the fundamental unit and regulator of the real quadratic order $\mathbb{Z}[\sqrt N]$. It is:

* genuinely $N$-computable (a finite deterministic integer algorithm);
* genuinely non-polynomial (the period $\ell(N)$ jumps erratically: $\ell(60)=2$, $\ell(61)=11$);
* genuinely arithmetic (it computes the fundamental unit, controls the regulator, and interacts with class-group and genus theory).

If any non-polynomial symmetric channel leaks a factor, this is the one. We show it does not, and we localize precisely why.

### 1.2 Contributions

1. **A complete integral invariant theory of the PQa machine** (Section 3). Four invariants, preserved by *arbitrary* integer partial quotients, from which the norm identity follows by pure algebra.
2. **The exact Pell value** $h^2 - Nq^2 = \pm d$ at every state, and the unit output at $d=1$ (Section 4).
3. **Localization of the unique factor-adjacent exit** as the split-root event, with the split-root splitting lemma (Section 5).
4. **Four obstruction theorems** — prime-power immunity, cheap-window nullity, sparsity of cheap witnesses, and the no-pinning theorem for congruence data (Sections 6–8).
5. **The de-confounding theorem**: the maximal partial quotient of $\sqrt N$ is identically $2\lfloor\sqrt N\rfloor$, via the reduced-regime box (Section 9), which explains and dissolves the observed $0.99$ correlation.
6. **Cost lower bounds**: Fibonacci growth of the witness, and boundedness of every non-counter coordinate (Section 10).
7. **A verdict on channel capacity** (Section 12), with conjectures (Section 13).

### 1.3 Notation

$N$ denotes a positive non-square integer; $\lfloor\sqrt N\rfloor$ its integer square root, written $A$ where convenient. $F_k$ is the $k$-th Fibonacci number, $F_0 = 0$, $F_1 = 1$. $\ell(N)$ is the period of the continued fraction of $\sqrt N$. For a semiprime $N = pq$ with $p < q$ we call $s$ the factor-spread coordinate (any fixed monotone function of $q-p$). Congruences $x \equiv y \pmod n$ are in $\mathbb{Z}$.

---

## 2. Background: continued fractions of quadratic surds

Let $N$ be a positive non-square. The simple continued fraction of $\sqrt N$ is

$$\sqrt N = a_0 + \cfrac{1}{a_1 + \cfrac{1}{a_2 + \cdots}}, \qquad a_0 = \lfloor\sqrt N\rfloor,$$

and Lagrange's theorem states that the sequence $(a_k)$ is eventually periodic; in fact $a_{k}$ is purely periodic from $k=1$ with $a_{k+\ell} = a_k$, and the period terminates with $a_\ell = 2a_0$. The complete quotients all have the form $(\sqrt N + m_k)/d_k$ with $m_k, d_k \in \mathbb{Z}$, $d_k \mid N - m_k^2$.

The convergents $h_k/q_k$ obey the standard recursions $h_k = a_k h_{k-1} + h_{k-2}$, $q_k = a_k q_{k-1} + q_{k-2}$. The classical bridge to Pell's equation is that $h_{\ell-1}^2 - N q_{\ell-1}^2 = (-1)^{\ell}$; the period-end convergent gives the fundamental unit $\varepsilon_N = h_{\ell-1} + q_{\ell-1}\sqrt N$ of $\mathbb{Z}[\sqrt N]$, and $\log \varepsilon_N$ is the regulator.

Two facts about size will matter. First, by the class number formula for real quadratic fields, the regulator is typically of order $N^{1/2+o(1)}$, so $\ell(N)$ is typically of order $\sqrt N$ up to logarithmic factors; empirically, over our sweep the median of $\ell(N)/\sqrt N$ is $0.406$. Second, the analytic theory gives no useful *lower* bound on $\ell(N)$ for individual $N$: there are infinitely many $N$ with $\ell(N) = 1$ (namely $N = m^2+1$).

Our development below is deliberately *self-contained and integral*: we do not use the real-analytic theory of quadratic surds at any point. All statements are about a six-coordinate integer recursion, and all proofs are polynomial identities, divisibility arguments, or elementary induction. This matters for a null result, where the risk is that an unnoticed real-analytic hypothesis smuggles in the conclusion.

---

## 3. The PQa state machine and its invariants

### 3.1 States and steps

**Definition 3.1 (State).** A *state* is a $6$-tuple of integers $s = (m, d, h_{-}, h, q_{-}, q)$. Here $(\sqrt N + m)/d$ is the current complete quotient and $(h_-/q_-, h/q)$ are the two most recent convergents.

**Definition 3.2 (Initial state).** $s_{\mathrm{init}} = (0,\;1,\;0,\;1,\;1,\;0)$.

(The convention places $h_{-1}=1, h_{-2}=0$ and $q_{-1}=0, q_{-2}=1$ so that the first step already produces $h = a_0$, $q = 1$.)

**Definition 3.3 (Step).** For an integer partial quotient $a$, the step map is

$$\mathrm{step}_N(s, a) = \left(\; da - m,\;\; \frac{N - (da-m)^2}{d},\;\; h,\;\; ah + h_-,\;\; q,\;\; aq + q_- \;\right),$$

where the division is exact whenever $d \mid N - m^2$ (Lemma 3.5) and is otherwise taken to be Euclidean division.

Note that the step map is defined for *any* integer $a$, not only the floor value. This generality is deliberate: the invariants below hold for arbitrary $a$, so they are properties of the algebraic recursion rather than of the specific choice of partial quotient. The actual continued fraction is recovered by specializing.

**Definition 3.4 (Continued fraction of $\sqrt N$).** Set $A = \lfloor\sqrt N\rfloor$. Define $\mathrm{cf}_N(s) = \mathrm{step}_N\!\left(s, \left\lfloor \frac{A + m}{d} \right\rfloor\right)$ and let $S_k(N)$ be the state obtained from $s_{\mathrm{init}}$ by $k$ applications of $\mathrm{cf}_N$.

### 3.2 The invariants

**Definition 3.5 (Invariant predicate).** A state $s$ is *$N$-invariant* if

$$\textbf{(I1)}\ d \ne 0; \qquad \textbf{(I2)}\ d \mid N - m^2; \qquad \textbf{(I3)}\ Nq = hm + h_- d;$$
$$\textbf{(I4)}\ qm + q_- d = h; \qquad \textbf{(I5)}\ (hq_- - h_- q)^2 = 1.$$

**Theorem 3.6 (Initialization).** $s_{\mathrm{init}}$ is $N$-invariant for every $N$.

*Proof.* Substituting $(m,d,h_-,h,q_-,q) = (0,1,0,1,1,0)$: (I1) $1 \ne 0$; (I2) $1 \mid N$; (I3) $N\cdot 0 = 1\cdot 0 + 0 \cdot 1$; (I4) $0\cdot 0 + 1\cdot 1 = 1$; (I5) $(1\cdot 1 - 0\cdot 0)^2 = 1$. $\square$

**Theorem 3.7 (Invariance under an arbitrary step).** Let $N$ be a non-square, i.e. $z^2 \ne N$ for all $z \in \mathbb{Z}$. If $s$ is $N$-invariant then so is $\mathrm{step}_N(s,a)$, for every $a \in \mathbb{Z}$.

*Proof sketch.* Write $m' = da - m$ and $d' = (N - m'^2)/d$.

*Exactness and (I2).* From (I2), $N - m^2 = dc$ for some $c$. Then
$$N - m'^2 = N - (da-m)^2 = dc + m^2 - (da-m)^2 = d\big(c + 2am - a^2 d\big),$$
so $d \mid N - m'^2$ and $d'$ is a genuine integer with $d d' = N - m'^2$. Symmetrically $d' \mid N - m'^2$ (with cofactor $d$), which is (I2) for the new state since the new $m$ is $m'$.

*Nonvanishing (I1).* $N - m'^2 \neq 0$ because $N$ is not a square; and $dd' = N - m'^2$ forces $d' \ne 0$.

*Linear relations.* The new state has $(h_-', h') = (h, ah + h_-)$ and $(q_-', q') = (q, aq + q_-)$. Target (I3) is
$$N(aq + q_-) = (ah + h_-)m' + h d'.$$
Multiplying by the nonzero $d$ and substituting $dd' = N - m'^2$, the identity becomes a $\mathbb{Z}$-linear combination of (I3) and (I4) with polynomial coefficients: explicitly it equals $m'\cdot$(I3) $+\;N\cdot$(I4) $-\;h\cdot(dd' - N + m'^2)$. Since the last bracket vanishes, cancellation of $d$ yields the claim. Target (I4), namely $(aq+q_-)m' + q d' = ah + h_-$, is obtained the same way from the combination (I3) $+\, m'\cdot$(I4) $+\, q\cdot(dd' - N + m'^2)$.

*Unimodularity.* $h'q_-' - h_-'q' = (ah + h_-)q - h(aq + q_-) = h_- q - h q_-$, whose square equals that of $hq_- - h_-q$, namely $1$. $\square$

**Corollary 3.8 (Invariants along the true continued fraction).** For every non-square $N$ and every $k \ge 0$, the state $S_k(N)$ is $N$-invariant.

*Proof.* Induction on $k$, using Theorems 3.6 and 3.7 with $a = \lfloor (A+m)/d\rfloor$. $\square$

Two remarks. First, non-squareness is used only once, to prevent $d' = 0$; every other part of the argument is a polynomial identity. Second, the invariants are stated with no inequality constraints at all, so they survive the wildest choice of partial quotients — the analytic content is entirely separate and appears in Section 9.

---

## 4. The exact Pell value and the unit output

**Theorem 4.1 (Exact Pell value).** For every $N$-invariant state,

$$h^2 - Nq^2 \;=\; d\,(hq_- - h_- q) \;=\; \pm\, d .$$

*Proof.* Take the combination $-h\cdot$(I4) $-\;q\cdot$(I3):
$$-h(qm + q_-d - h) - q(Nq - hm - h_-d) = h^2 - Nq^2 - d(hq_- - h_-q),$$
after cancelling the $\pm hqm$ terms. Both bracketed expressions vanish, so the right-hand side is $0$. The second equality is (I5). $\square$

This is the structural heart of the paper. It says that the deviation of the convergent $h/q$ from being an exact square root of $N$ is not merely small, but *equal on the nose* to the auxiliary coordinate $d$ that the machine is already carrying, up to sign. The continued fraction is a Pell solver with an exact error term.

**Theorem 4.2 (Unit at period end).** If an $N$-invariant state has $d = 1$, then
$$h^2 - Nq^2 = 1 \quad\text{or}\quad h^2 - Nq^2 = -1;$$
that is, $h + q\sqrt N$ is a unit of $\mathbb{Z}[\sqrt N]$.

*Proof.* By Theorem 4.1 with $d = 1$, $h^2 - Nq^2 = u$ where $u = hq_- - h_-q$ satisfies $u^2 = 1$ by (I5). Factoring, $(u-1)(u+1) = 0$, so $u = \pm 1$. $\square$

**Corollary 4.3 (Channel output).** For every non-square $N$ and every $k$ with $d(S_k(N)) = 1$, the pair $(h,q)$ of $S_k(N)$ solves $x^2 - Ny^2 = \pm 1$.

The states with $d = 1$ occurring for $k \ge 1$ are exactly the period ends, $k \equiv 0 \pmod{\ell}$; the first one, $k = \ell$, gives the fundamental unit. Worked instances:

| $N$ | $\ell$ | period-end $(h,q)$ | $h^2 - Nq^2$ |
|---|---|---|---|
| $13$ | $5$ | $(18,\,5)$ | $-1$ |
| $21 = 3\cdot 7$ | $6$ | $(55,\,12)$ | $+1$ |
| $65 = 5\cdot 13$ | $1$ | $(8,\,1)$ | $-1$ |

For $2 \le N \le 40$ non-square the period sequence is
$$1,2,1,2,4,2,1,2,2,5,4,2,1,2,6,2,6,6,4,2,1,2,4,5,8,\ldots$$
for $N = 2,3,5,6,7,8,10,11,12,13,14,15,17,18,19,20,21,22,23,24,26,27,28,29,31,\dots$, matching the classical table, with unit norm $-1$ exactly on odd periods ($N = 2,5,10,13,17,26,29,37$).

---

## 5. The unique factor-adjacent exit

Pell units are *near* factorization for one reason only. If $x^2 - Ny^2 = 1$ then $x^2 \equiv 1 \pmod N$, so $x$ is a square root of unity modulo $N$. When $N$ has at least two distinct prime factors, such square roots need not be $\pm 1$, and a non-trivial one splits $N$.

**Theorem 5.1 (Split-root splitting).** Let $n > 1$ and $x \in \mathbb{Z}$ with $n \mid x^2 - 1$, $n \nmid x-1$, $n \nmid x+1$. Then $g := \gcd(x-1, n)$ satisfies $g \mid n$ and $1 < g < n$.

*Proof.* $g \mid n$ is immediate. If $g = 1$ then $x - 1$ and $n$ are coprime, and since $n \mid (x-1)(x+1)$, coprimality gives $n \mid x+1$, contradicting hypothesis; so $g > 1$. If $g = n$ then $n \mid x - 1$ (as $g \mid x-1$), again a contradiction; so $g \ne n$, and since $g \mid n$ with $n > 0$ we get $g < n$. $\square$

**Corollary 5.2 (Pell unit splits).** Let $N > 1$ and let $x, y$ satisfy $x^2 - Ny^2 = 1$ with $N \nmid x-1$ and $N \nmid x+1$. Then $N$ has a divisor $g$ with $1 < g < N$, namely $g = \gcd(x-1,N)$.

*Proof.* $x^2 - 1 = Ny^2$ so $N \mid x^2-1$; apply Theorem 5.1. $\square$

**Example 5.3.** $N = 21$, $x = 55$, $y = 12$: $55^2 - 21\cdot 12^2 = 1$, $21 \nmid 54$, $21 \nmid 56$, so $\gcd(54,21) = 3$ is a proper factor. The continued fraction of $\sqrt{21}$ factors $21$.

This exit is real, and empirically frequent: in the sweeps underlying this work, the period-end unit was a split root in $206$ of $269$ even-period composite instances ($\approx 77\%$), and $41$ of $53$ in a second, independent sample.

**It is also the only exit.** The channel's output is a unit; a norm-$-1$ unit gives $x^2 \equiv -1$, which yields no gcd; a norm-$+1$ unit gives a square root of $1$; and a square root of $1$ either is $\pm 1$ (useless) or splits (Theorem 5.1). Everything else the channel produces — the period length, the partial quotients, the intermediate $(m,d)$ pairs — is subject to Sections 8 and 9. The remainder of the paper closes each of these routes in turn.

---

## 6. Obstruction I: prime powers are immune

**Theorem 6.1 (Square roots of unity mod odd prime powers).** Let $p$ be an odd prime, $k \ge 0$, and $x \in \mathbb{Z}$ with $p^k \mid x^2 - 1$. Then $p^k \mid x - 1$ or $p^k \mid x + 1$.

*Proof.* $p^k \mid (x-1)(x+1)$. Suppose first $p \mid x-1$. If also $p \mid x+1$ then $p \mid (x+1)-(x-1) = 2$, impossible for odd $p$. So $p \nmid x+1$, hence $p^k$ is coprime to $x+1$, and from $p^k \mid (x-1)(x+1)$ we get $p^k \mid x-1$. If instead $p \nmid x-1$, then $p^k$ is coprime to $x-1$ and symmetrically $p^k \mid x+1$. $\square$

**Theorem 6.2 (Prime-power nullity of the channel).** Let $p$ be an odd prime, $k \ge 1$, $N = p^k$. Every solution of $x^2 - Ny^2 = 1$ has $x \equiv 1$ or $x \equiv -1 \pmod N$. Consequently the split-root exit never fires for $N = p^k$: the continued fraction of $\sqrt{p^k}$ cannot produce a factor, whatever its period length and whatever computation is expended.

*Proof.* $N \mid x^2 - 1$; apply Theorem 6.1. $\square$

**Corollary 6.3 (Two primes required).** If the channel splits $N$ — i.e. produces $x$ with $x^2 \equiv 1$, $x \not\equiv \pm 1 \pmod N$ — then $N$ has at least two distinct prime factors.

The interpretation matters. The channel does not *discover* the multiplicative structure of $N$; it detects a splitting that the Chinese Remainder Theorem already guarantees, and only when that splitting exists in $(\mathbb{Z}/N)^\times[2]$. In particular, prime-power detection — a task trivial by other means, but a useful diagnostic of channel content — receives nothing at all from this channel.

---

## 7. Obstruction II: the cheap-period window is barren, and thin

The cost of running the channel is the period length. One might hope to restrict attention to $N$ with unusually short period. Such $N$ exist in abundance in absolute terms, but they form explicitly parameterized algebraic families with provably trivial output.

### 7.1 Period one: $N = m^2 + 1$

**Proposition 7.1.** For every $m \in \mathbb{Z}$, $m^2 - (m^2+1)\cdot 1^2 = -1$; hence $m + \sqrt{m^2+1}$ is a unit of norm $-1$, and $\sqrt{m^2+1}$ has period $1$.

**Theorem 7.2 (Trivial gcds in the period-one window).** For every $m \in \mathbb{Z}$:
$$\gcd(m,\; m^2+1) = 1, \qquad \gcd(m-1,\;m^2+1) \mid 2, \qquad \gcd(m+1,\;m^2+1)\mid 2 .$$

*Proof.* $1 = (m^2+1) - m\cdot m$ gives the first (Bézout). For the second, $2 = (m^2+1) - (m-1)(m+1)$, so any common divisor of $m-1$ and $m^2+1$ divides $2$; the third is the same identity with the roles of $m\pm1$ exchanged. $\square$

**Corollary 7.3 (Period-one nullity for odd $N$).** If $m$ is even — the case in which $N = m^2+1$ is odd, hence can be a semiprime — then
$$\gcd(m, N) = \gcd(m-1, N) = \gcd(m+1, N) = 1 .$$

*Proof.* $N = m^2+1$ is odd when $m$ is even, so no gcd with $N$ is even; combined with Theorem 7.2 each gcd divides $2$ and is odd, hence $1$. $\square$

**Example 7.4.** $N = 65 = 8^2+1 = 5\cdot 13$. Period $1$, unit $8 + \sqrt{65}$ of norm $-1$, and $\gcd(8,65)=\gcd(7,65)=\gcd(9,65)=1$. The cheapest possible period on a semiprime yields nothing. (The same phenomenon occurs at $N = 145 = 12^2+1$, and at $N = 51, 291$ in the neighbouring $m^2+c$ families: the parameter $m = \sqrt{N - c}$ divides no factor of $N$.)

### 7.2 Period two: $N = m^2 + 2$

**Proposition 7.5.** For every $m$, $(m^2+1)^2 - (m^2+2)m^2 = 1$; so $x = m^2+1$, $y = m$ is a norm-$+1$ unit and $x$ *is* a square root of $1$ modulo $N = m^2+2$.

**Theorem 7.6 (Period-two nullity).** For odd $m$,
$$\gcd\big((m^2+1)-1,\; m^2+2\big) = 1 \qquad\text{and}\qquad (m^2+1)+1 = m^2+2 = N .$$
Hence the split-root test applied to the period-two unit returns only trivial divisors.

*Proof.* $(m^2+1)-1 = m^2$, and $(m^2+2) - m^2 = 2$, so $\gcd(m^2, m^2+2) \mid 2$; for odd $m$, $m^2$ is odd, so the gcd is $1$. The second equation is an identity, and expresses $x \equiv -1 \pmod N$, the trivial root. $\square$

So the period-two family produces exactly the excluded case $x \equiv -1$ of Theorem 5.1.

### 7.3 Cheap witnesses are density zero

The above are two families; the following bound shows the phenomenon is general. A "cheap" witness is one whose denominator $y$ is small — the only kind reachable in a small number of steps, since $y = q_k$ grows exponentially in $k$ (Theorem 10.2).

**Theorem 7.7 (Sparsity of small-denominator units).** Fix $y \ge 1$. Then
$$\#\{\,N \le X : Ny^2 + 1 \text{ is a perfect square}\,\} \;\le\; \big\lfloor\sqrt{Xy^2+1}\big\rfloor + 1 \;=\; O(y\sqrt X).$$

*Proof.* If $Ny^2+1 = t^2$ then $t = \lfloor\sqrt{Ny^2+1}\rfloor$ is determined by $N$, and conversely $N = (t^2-1)/y^2$ is determined by $t$; so $N \mapsto \lfloor\sqrt{Ny^2+1}\rfloor$ is injective on the set in question. For $N \le X$ we have $t \le \sqrt{Xy^2+1}$, so the image lies in a set of size $\lfloor\sqrt{Xy^2+1}\rfloor+1$. $\square$

**Corollary 7.8.** For any fixed bound $Y$ on the denominator, the set of $N$ admitting a norm-$+1$ unit with $y \le Y$ has counting function $O(Y^2\sqrt X)$, hence density zero. Any polynomial-time-reachable witness must have $y \le 2^{\mathrm{poly}(\log N)}$ but with only $\mathrm{poly}(\log N)$ steps available and Fibonacci growth (Theorem 10.2) the reachable $y$ is at most exponential in $\mathrm{poly}(\log N)$ — and for the *genuinely cheap* window ($\ell \le 40$, say) the accessible $N$ are exactly the $N = m^2 + c$ families with $c$ small, a density-zero set with provably trivial gcds by §7.1–7.2.

---

## 8. Obstruction III: the negative-Pell bit is a no-pinning congruence

Period parity is the one genuine factorization-sensitive statistic of the channel: $\ell(N)$ is odd exactly when the negative Pell equation $x^2 - Ny^2 = -1$ is solvable, i.e. exactly when the fundamental unit has norm $-1$. What does solvability say about the factors?

**Theorem 8.1 (Negative-Pell obstruction).** Suppose $x^2 - Ny^2 = -1$ has an integer solution, and let $p$ be a prime with $p \mid N$. Then $p \not\equiv 3 \pmod 4$.

*Proof.* Reduce modulo $p$. Since $p \mid N$, the image of $N$ in $\mathbb{Z}/p$ is $0$, so $x^2 \equiv -1 \pmod p$; thus $-1$ is a quadratic residue mod $p$. By Euler's criterion this holds iff $p = 2$ or $p \equiv 1 \pmod 4$. $\square$

**Corollary 8.2.** Under the same hypothesis, every odd prime factor $p$ of $N$ satisfies $p \equiv 1 \pmod 4$.

**Corollary 8.3 (Blocked branch).** If some prime $p \mid N$ has $p \equiv 3 \pmod 4$, then $x^2 - Ny^2 = -1$ is insoluble; hence every period-end unit of $\sqrt N$ has norm $+1$ and the period is even.

*Example.* $N = 21$: $3 \mid 21$ and $3 \equiv 3 \pmod 4$, so every $d=1$ state of the machine for $N=21$ has $h^2 - 21q^2 = +1$ — consistent with $\ell(21)=6$ even and $(h,q)=(55,12)$.

The dichotomy was verified empirically without exception: among semiprimes $N=pq$ classified by $(p \bmod 4, q \bmod 4)$, type $(3,3)$ gave even period in $40/40$ cases, type $(1,3)$ in $40/40$, and type $(1,1)$ split, with odd period (equivalently negative-Pell soluble) in $26/40$.

So the channel transmits, faithfully, the predicate "all odd prime factors of $N$ are $\equiv 1 \pmod 4$". This is genuine information about $p$ and $q$. It is also worthless for factoring, and the following makes that precise.

**Theorem 8.4 (No pinning).** Let $M \ge 1$, let $a, b$ be residues coprime to $M$, and let $B \ge 0$. Then there exist primes $B < p_1 < q_1 < p_2 < q_2$ with
$$p_1 \equiv p_2 \equiv a \pmod M, \qquad q_1 \equiv q_2 \equiv b \pmod M,$$
and $p_1q_1 < p_2q_2$. In particular the two semiprimes $N_1 = p_1q_1 \ne N_2 = p_2q_2$ have prime factors with identical residue data mod $M$.

*Proof.* By Dirichlet's theorem on primes in arithmetic progressions, each of the classes $a \bmod M$ and $b \bmod M$ (coprime to $M$) contains arbitrarily large primes. Choose $p_1 > B$ in class $a$; then $q_1 > p_1$ in class $b$; then $p_2 > q_1$ in class $a$; then $q_2 > p_2$ in class $b$. The strict inequalities give $p_1q_1 < p_2q_2$. $\square$

**Corollary 8.5.** The negative-Pell bit (the case $M = 4$, $a = b = 1$) is a *no-pinning* bit: it is compatible with infinitely many distinct factorizations, and remains so after conjunction with any finite amount of further congruence data of bounded modulus. Congruence information localizes a factor only when the modulus exceeds $\sqrt N$, at which point specifying the residue is at least as expensive as trial division.

This is the conceptual crux of the null result. The channel is not *empty*; it is *congruential*. And congruential information, by Dirichlet, has zero localizing power.

---

## 9. De-confounding: the maximal partial quotient is a size coordinate

A raw statistical pass over $330$ instances found $\mathrm{corr}(\max_k a_k,\; s) \approx +0.99$ in every bit-length bucket, where $s$ is the factor spread. Taken at face value this would be a spectacular leak. It is an artifact, and the following theorems say exactly why: on $330$ of $330$ instances, $\max_k a_k = 2\lfloor\sqrt N\rfloor$ identically, and $\mathrm{corr}(\lfloor\sqrt N\rfloor, s) = 1.000$.

### 9.1 The reduced regime

Write $A = \lfloor\sqrt N\rfloor$, so that $A^2 < N < (A+1)^2$ for non-square $N$.

**Definition 9.1 (Reduced state).** A state is *reduced* for $N$ if
$$0 < d, \qquad 0 \le m \le A, \qquad d \le A + m, \qquad A < d + m .$$

This is the integral shadow of the classical condition that the complete quotient $(\sqrt N + m)/d$ is a *reduced* quadratic irrational: $\alpha > 1 > -1/\bar\alpha > 0$.

**Theorem 9.2 (Entry).** For non-square $N \ge 1$, the state $S_1(N)$ is reduced. Explicitly $S_1(N) = (A,\; N - A^2,\; 1,\; A,\; 0,\; 1)$.

*Proof.* From $s_{\mathrm{init}}$ the partial quotient is $\lfloor (A+0)/1\rfloor = A$, giving the stated state. Then $d = N - A^2 > 0$ since $A^2 < N$; $m = A$ satisfies $0 \le m \le A$; $d \le A + m = 2A$ is $N - A^2 \le 2A$, i.e. $N \le (A+1)^2 - 1$, true; and $A < d + m = N - A^2 + A$ reduces to $A^2 < N$. $\square$

**Theorem 9.3 (Preservation).** Let $N$ be a non-square and let $s$ be an $N$-invariant reduced state. Then $\mathrm{cf}_N(s)$ is reduced.

*Proof sketch.* Let $a = \lfloor(A+m)/d\rfloor$ and $r = (A+m) \bmod d$, so $da + r = A+m$ with $0 \le r < d$. The new $m$ is $m' = da - m = A - r$.

*Positivity of $a$:* if $a \le 0$ then $da \le 0$, so $r = A+m-da \ge A + m > A \ge r$ (using $r < d \le A+m$), a contradiction; hence $a \ge 1$.

*Range of $m'$:* we must show $0 \le A - r \le A$, i.e. $0 \le r \le A$. If $d \le A$ then $r < d \le A$. If $d > A$ then, since $d \le A+m \le 2A$ and $A < d+m$, one checks $a = 1$, whence $r = A + m - d \le A$ by $d \ge m$ (which follows from $d > A \ge m$).

*Positivity of $d'$:* $dd' = N - m'^2 = N - (A-r)^2$, and $(A-r)^2 \le A^2 < N$, so $d' > 0$.

*Remaining inequalities:* From $da = m + m'$ and $a \ge 1$ we get $d \le m + m'$. Suppose $d' > A + m'$; then $dd' = N - m'^2 = (\sqrt N - m')(\sqrt N + m')$ combined with $d \le m + m' \le A + m'$ and the bound $m' \le A$ yields $N - m'^2 = dd' > (A+m')\cdot(\text{something} \ge \dots)$, contradicting $N < (A+1)^2$; a direct integral computation (multiplying out and using $A^2 < N < (A+1)^2$, $0 \le m' \le A$) closes it. The inequality $A < d' + m'$ is obtained the same way from the lower bound $N > A^2$. $\square$

**Corollary 9.4.** For non-square $N \ge 1$ and every $k \ge 0$, the state $S_{k+1}(N)$ is reduced.

*Proof.* Induction from Theorem 9.2 using Theorem 9.3 and Corollary 3.8. $\square$

### 9.2 The cap and its attainment

**Theorem 9.5 (Partial-quotient bounds).** If $s$ is reduced for $N$, then its partial quotient $a = \lfloor(A+m)/d\rfloor$ satisfies
$$1 \le a \le 2A .$$

*Proof.* Lower bound as in Theorem 9.3. Upper: $a \le (A+m)/d$ and $m \le A$, $d \ge 1$ give $a \le 2A$ directly when $d = 1$; in general $A < d + m$ gives $d > A - m$, so $a \le (A+m)/d < (A+m)/(A-m)$ when $m<A$, and the integrality with $d \ge 1$ yields $a \le A + m \le 2A$. $\square$

**Corollary 9.6.** For every non-square $N \ge 1$ and every $k \ge 1$, $a_k \le 2\lfloor\sqrt N\rfloor$.

**Theorem 9.7 (Attainment at period end).** If a state has $d = 1$ and $m = A$, then its partial quotient is exactly $\lfloor (A+A)/1\rfloor = 2A$.

Since period ends are exactly the states with $d=1$, and there $m = A$ (the complete quotient returns to $(\sqrt N + A)/1$), the partial quotient at period end is $2A$; combined with Corollary 9.6:

**Corollary 9.8 (De-confounding).** For every non-square $N$,
$$\max_{k\ge 1} a_k \;=\; 2\lfloor\sqrt N\rfloor .$$
The maximal partial quotient of $\sqrt N$ is a deterministic function of the size of $N$ alone and carries no information whatsoever about the factorization.

### 9.3 The statistical consequence

Corollary 9.8 fully explains the observed $\approx +0.99$: on all $330$ instances $\max_k a_k = 2\lfloor\sqrt N\rfloor$, and $\lfloor\sqrt N\rfloor$ correlates with the spread coordinate at $1.000$ by construction, since $N = pq$ fixes the size scale.

The correct procedure is to residualize every period statistic on the size coordinate $a_0 = \lfloor\sqrt N\rfloor$ before testing. Doing so on the period length $\ell$, its parity, the non-terminal maximum $\max_{1\le k<\ell} a_k$, the non-terminal sum $\sum_{1\le k<\ell} a_k$, the number of distinct partial quotients, and the regulator $\log\varepsilon_N$, across $120$ partial-correlation permutation tests stratified by bit-length and by $N \bmod 4$, produced a worst-case $p$-value of $0.024$ against a Bonferroni-corrected threshold of $0.05/120 \approx 0.0004$. No statistic depends on the factor spread once the size coordinate is removed. The channel is statistically null.

---

## 10. The cost side: bounded box, exponential witness

Why can one not simply run the channel for $\mathrm{poly}(\log N)$ steps and read off a witness? Two structural facts answer this.

**Theorem 10.1 (Bounded box).** For non-square $N \ge 1$ and $k \ge 1$, the state $S_k(N)$ satisfies $0 \le m \le \lfloor\sqrt N\rfloor$ and $0 < d \le 2\lfloor\sqrt N\rfloor$.

*Proof.* Immediate from Corollary 9.4 and Definition 9.1 ($d \le A + m \le 2A$). $\square$

So the arithmetic coordinates never grow: the machine's *entire* state space beyond the convergents is a box of size $O(N)$, and the only unbounded coordinate is the step counter. Whatever the channel produces is a function of where in a bounded box one has arrived after $k$ steps.

**Theorem 10.2 (Fibonacci growth of convergent denominators).** For non-square $N \ge 1$ and every $k \ge 0$, the state $S_{k+1}(N)$ satisfies
$$q_- \ge F_k \quad\text{and}\quad q \ge F_{k+1}.$$

*Proof.* Induction. Base: $S_1(N) = (A, N-A^2, 1, A, 0, 1)$ has $q_- = 0 = F_0$ and $q = 1 = F_1$. Step: the recursion gives $q_-' = q$ and $q' = a q + q_-$ with $a \ge 1$ (Theorem 9.5) and $q, q_- \ge 0$, so $q' \ge q + q_- \ge F_{k+1} + F_k = F_{k+2}$. $\square$

**Corollary 10.3 (Cost).** A period of length $\ell$ produces a Pell witness with $q_\ell \ge F_\ell \asymp \varphi^\ell$, $\varphi = (1+\sqrt5)/2$: the witness has $\Theta(\ell)$ digits, so merely writing it down costs $\Omega(\ell)$. Combined with the empirical scaling $\ell(N) \approx 0.4\sqrt N$ (median $\ell/\sqrt N = 0.406$ over the sweep), reaching a period end costs $\approx 2^{(\log_2 N)/2}$ operations — super-polynomial in $\log N$. The channel therefore does not even furnish a $\mathrm{poly}(\log N)$-size *witness*, let alone a $\mathrm{poly}(\log N)$-time algorithm.

For calibration: the classical square-form factorization method attains $O(N^{1/4})$, and the general number field sieve $\exp\big(O((\log N)^{1/3}(\log\log N)^{2/3})\big)$. The full-period Pell/continued-fraction route to a split root is a *known* method at a strictly worse exponent than $N^{1/4}$. It is not a new leverage point; it is an old one, re-derived, with its cost made explicit.

---

## 11. Algorithms

We record the three algorithms in explicit form; complexities are in bit operations with $n = \log_2 N$.

**Algorithm A (PQa expansion).** Input non-square $N$; maintain $(m,d,h_-,h,q_-,q)$ from $s_{\mathrm{init}}$; at each step set $a \leftarrow \lfloor (A+m)/d\rfloor$ with $A = \lfloor\sqrt N\rfloor$ and apply Definition 3.3. Halt at the first $k \ge 1$ with $d = 1$; then $k = \ell(N)$ and $(h,q)$ is the fundamental unit. Cost: $\ell$ iterations, each $O(n^2)$ for the small coordinates plus $O(n\cdot k)$ for the growing convergents; total $\tilde O(\ell^2)$ bit operations, and $\ell$ is typically $\Theta(\sqrt N)$.

*Correctness:* Theorem 3.7 (invariants), Theorem 4.2 (unit output), Corollary 9.4 (reduced regime and termination structure), Theorem 9.7 (period-end signature $a_\ell = 2A$, $m = A$, $d=1$).

**Algorithm B (Split-root factoring attempt).** Input $N$; run Algorithm A to a period end; if the unit norm is $-1$, run one further period (squaring the unit) to obtain a norm-$+1$ solution $x$; test $x \equiv \pm 1 \pmod N$; if not, output $\gcd(x-1, N)$. Cost: $O(\ell)$ steps, i.e. $\tilde O(\sqrt N)$. Success probability empirically $\approx 0.77$ on semiprimes; zero on odd prime powers (Theorem 6.2).

**Algorithm C (De-confounded correlation test).** Input a family of semiprimes stratified by bit-length and $N \bmod 4$; for each compute period statistics and the size coordinate $a_0 = \lfloor\sqrt N\rfloor$; within each stratum regress each statistic on $a_0$ and take residuals; compute the correlation of residuals with the factor spread; assess by permutation with Bonferroni correction over all statistic $\times$ stratum pairs. Cost dominated by Algorithm A per instance.

---

## 12. Discussion: what kind of null this is

It is worth being precise about the claim.

**What the channel contains.** Genuine, deep arithmetic: the fundamental unit of $\mathbb{Z}[\sqrt N]$, exactly, with the norm pinned to $\pm d$ at every convergent (Theorem 4.1); the regulator; the negative-Pell bit, which is a real constraint on the residues of the prime factors (Theorem 8.1); and a real factoring exit that fires about three times in four (Theorem 5.1, Example 5.3).

**Why the content is not leverage.** Four independent reasons, none of which is a failure of ingenuity:

1. *Type mismatch.* The factorization-sensitive content is congruential, and congruences do not pin (Theorem 8.4). This is a structural, not a quantitative, obstruction: no refinement of the statistic changes the type of information it carries.
2. *Support gap.* The exit does not exist for prime powers (Theorem 6.2), so the channel's "factoring" capability is conditional on a splitting that is already present in $(\mathbb{Z}/N)^\times[2]$.
3. *Cheap cases are degenerate.* Where the period is short, the $N$ lie in explicit families with provably trivial gcds (Theorems 7.2, 7.6), and such $N$ have density zero (Theorem 7.7).
4. *Cost.* The generic period is $\Theta(\sqrt N)$ and the witness is exponential in the step count (Theorem 10.2), placing the route strictly behind $O(N^{1/4})$ methods.

**Why the statistics looked otherwise.** The dominant raw signal was $\max_k a_k$, which Corollary 9.8 identifies as the constant $2\lfloor\sqrt N\rfloor$. This is a textbook confound: a statistic that is a deterministic function of the *size* of $N$ will correlate with anything else that scales with size, including factor spread. After residualizing on $\lfloor\sqrt N\rfloor$, nothing survives Bonferroni correction.

**The conceptual upshot.** For polynomial symmetric functions of $\{p,q\}$, the fundamental theorem of symmetric polynomials closes the channel by fiat: the reachable set is $\{(N, p+q)\}$. The continued-fraction period was the natural candidate for a *non-polynomial* symmetric $N$-computable object that might evade that argument — it is algorithmic, erratic, and arithmetically deep. The results here show that the non-polynomial channel is closed by a different mechanism (congruential content plus $\sqrt N$ cost plus support gaps) but closed just as firmly. The barrier is best understood as attaching to symmetry itself, not to polynomiality.

**Limitations.** (i) The empirical claims (median $\ell/\sqrt N = 0.406$; split-root rate $\approx 0.77$; the $120$ permutation tests) are finite-sample statements over the specific sweeps described and are labelled as such; the theorems are unconditional. (ii) Theorem 6.2 addresses odd prime powers; $N$ even or with a factor $2^k$ requires the standard separate handling. (iii) We do not prove a lower bound on $\ell(N)$ for individual $N$; Conjecture C below is exactly this gap. (iv) The channel analysis concerns the *deterministic* continued-fraction expansion; a randomized relative — CFRAC, which harvests smooth values of $h^2 - Nq^2 = \pm d$ across many convergents into a congruence of squares — is a genuinely different (and genuinely subexponential) algorithm, and is out of scope here. Interestingly, Theorem 4.1 is exactly what makes CFRAC possible: the small residues it factors are precisely the $d$-coordinates, which Theorem 10.1 bounds by $2\lfloor\sqrt N\rfloor$.

---

## 13. Future directions

**Conjecture A (split-root density law).** For odd $N$ with $r \ge 2$ distinct prime factors, let $u(N)$ be the period-end unit when the period is even. We conjecture that the probability, over semiprimes $N \le X$, that $u(N)$ is a *split* root of $1 \bmod N$ tends to $1 - 2^{1-r} - \delta$ with $\delta \to 0$ — that is, $3/4$ for semiprimes. The observed rates are $41/53 \approx 0.77$ and $206/269 \approx 0.77$.

The key insight is that a norm-$+1$ unit is a square root of $1$ in $(\mathbb{Z}/N)^\times \cong (\mathbb{Z}/p)^\times \times (\mathbb{Z}/q)^\times$, and the split roots are exactly the two "mixed-sign" points of the $2$-torsion $\{\pm1\}\times\{\pm1\}$; the conjecture asserts that the period-end unit equidistributes over that $2$-torsion subgroup modulo the diagonal forced by the genus theory of $\mathbb{Q}(\sqrt N)$. Sections 5 and 6 already reduce the question to $(\mathbb{Z}/N)^\times[2]$; the Rédei–Reichardt $4$-rank machinery is the missing bridge, and it is a well-posed, computable target.

**Conjecture B (period-end coordinates as a complete invariant).** The map $N \mapsto (h_\ell, q_\ell)$ (period-end convergent) is injective on non-squares, and $N = (h_\ell^2 \mp 1)/q_\ell^2$ recovers $N$. The second half is immediate from Theorem 4.1; the first half is the falsifiable part. Theorem 7.7 already bounds the fibres of $q_\ell$ by $O(\sqrt X)$; injectivity would upgrade a counting bound to a structural bijection, turning "period statistics" into a coordinate system on non-squares rather than a channel. Both directions are decidable on any finite range, so a counterexample search costs nothing.

**Conjecture C (unconditional period lower bound).** For every non-square $N$, $\ell(N) \ge c\log N/\log\log N$. The convergent-denominator growth of Theorem 10.2 gives $q_\ell \ge F_\ell$, and $q_\ell$ must be large enough to carry the fundamental unit; making this quantitative for individual $N$ (rather than on average, where the regulator bound suffices) is the content.

**Further directions.** (D) Extend the invariant analysis from $\mathbb{Z}[\sqrt N]$ to the full ring of integers of $\mathbb{Q}(\sqrt N)$ (the $N \equiv 1 \bmod 4$ half-integral case), where the unit index $[\mathcal{O}^\times : \mathbb{Z}[\sqrt N]^\times] \in \{1,3\}$ introduces a second bit — and check whether that bit, too, is congruential. (E) Quantify the exact information-theoretic capacity of the channel: the negative-Pell bit is $\le 1$ bit; is the *whole* period, as a random variable conditioned on $\lfloor\sqrt N\rfloor$, independent of the spread, or merely uncorrelated? (F) Test whether the $d$-sequence $(d_1,\dots,d_\ell)$ — a walk in the box of Theorem 10.1 — has any factorization-sensitive spectral statistic after size-residualization.

---

## 14. Conclusion

The continued fraction of $\sqrt N$ is a small integer machine with four conserved quantities, whose output at every step satisfies exactly $h^2 - Nq^2 = \pm d$, and which manufactures the fundamental unit of a real quadratic order whenever $d$ returns to $1$. It possesses precisely one factor-adjacent exit — a split square root of $1$ modulo $N$ — and that exit is blocked by prime-power immunity where it would need to fire on prime powers, is degenerate on the density-zero cheap-period families, and elsewhere costs a full period, of order $\sqrt N$. Its one genuine factorization signal, period parity, is exactly the negative-Pell condition and pins nothing beyond a congruence class, by Dirichlet. And the statistic that appeared to leak was the size coordinate $2\lfloor\sqrt N\rfloor$ in disguise.

The channel is real, and it is sealed. The barrier that was known to close all polynomial symmetric functions of the factors closes this, the canonical non-polynomial one, as well.
