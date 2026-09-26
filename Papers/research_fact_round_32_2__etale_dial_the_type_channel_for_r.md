# What a Sum Remembers: Readable Type Channels for Pairs of Residues, the Half-Conductor Law, and Reducible Polynomials

**Aristotle** (Harmonic)
2026-09-26

---

## Abstract

Let $p, q$ be units modulo an integer $m$ and suppose we are shown only the *hinted view* $(p+q \bmod m,\; pq \bmod m)$. Which functions of the residues — which *type maps* — can be read off from this view, in the sense that the unordered pair of types $\{f(p), f(q)\}$ is determined? Over a field the answer is "all of them", since the sum and product determine the roots of $x^2 - sx + n$. Over the ring $\mathbb Z/m\mathbb Z$ the answer is far more delicate, and it governs how arithmetic "dials" — Legendre symbols, splitting types of primes in abelian number fields, factorisation types of reducible polynomials — can or cannot be recovered from a hint about a sum.

We give a complete answer. (i) The hinted view determines the unordered pair itself exactly when $m \in \{0,1,2,\ell,2\ell\}$ with $\ell$ an odd prime; outside this list there are exactly two obstructions, square-zero elements and Chinese-remainder *matching ambiguity*. (ii) At a prime power $\ell^k$ the pair is determined modulo $\ell^{\lceil k/2\rceil}$ and no finer (the *half-conductor law*), and a type map is readable iff it factors through the residue modulo $\ell^{\lceil k/2 \rceil}$; pairs with $p \not\equiv q \pmod \ell$ lose nothing at all (a Hensel-type refinement). (iii) Readable channels are closed under coarsening but not under joins, and on a product ring every readable channel is pulled back from a single factor. (iv) Consequently, for every $m \ge 1$: *a type map on $(\mathbb Z/m)^\times$ is readable iff, for a single prime $\ell$ with $\ell^k \,\|\, m$, it depends only on the residue modulo $\ell^{\lceil k/2\rceil}$.*

At conductor $8$ this corrects a previously proposed explanation of an empirically "sum-sufficient" dial: the claim that $(p+q) \bmod 8$ together with $pq \bmod 8$ determines $p \bmod 8$ is false (the primes $17, 41$ versus $13, 29$ refute it). What is true is that a type map at conductor $8$ is readable iff it is invariant under multiplication by $5$, i.e. iff it only sees $p \bmod 4$. Of the three quadratic subfields $\mathbb Q(i)$, $\mathbb Q(\sqrt 2)$, $\mathbb Q(\sqrt{-2})$ of $\mathbb Q(\zeta_8)$, exactly one — $\mathbb Q(i)$ — has a readable Legendre channel, and the étale type of the reducible polynomial $(x^2+1)(x^2-2)$ is *not* readable even though its first factor is.

---

## 1. Introduction

### 1.1 The question

Many arithmetic invariants of a prime $p$ are functions of $p$ modulo a fixed integer $m$, the *conductor*. The Legendre symbol $\left(\tfrac{-1}{p}\right)$ depends on $p \bmod 4$; $\left(\tfrac{2}{p}\right)$ depends on $p \bmod 8$; by quadratic reciprocity $\left(\tfrac{\Delta}{p}\right)$ depends on $p$ modulo $|\Delta|$ or $4|\Delta|$; and, by the Kronecker–Weber theorem, the splitting type of $p$ in any abelian number field is a function of $p$ modulo the conductor of the field. We call any function
$$f : (\mathbb Z/m\mathbb Z)^\times \longrightarrow B$$
a *type map* (or *dial*, or *channel*) of conductor $m$.

Now suppose two primes $p, q \nmid m$ are hidden, and we see only
$$ s \equiv p + q, \qquad n \equiv pq \pmod m. $$
This is the situation of a semiprime $N = pq$ accompanied by a hint about $p + q$ modulo $m$: the product is known, and a partial sum is leaked. The natural question is which dials survive: **for which type maps $f$ does the hinted view $(s,n)$ determine the unordered pair $\{f(p), f(q)\}$?**

Over a field this is trivial: $p$ and $q$ are the two roots of $x^2 - sx + n$, so the view determines $\{p,q\}$ and hence every function of it. Over $\mathbb Z/m\mathbb Z$ the polynomial $x^2 - sx + n$ may have many more than two roots, and different factorisations $x^2 - sx + n = (x-p)(x-q) = (x-p')(x-q')$ may coexist.

### 1.2 Motivation: a routing table that depends on the dial

An empirical study of several dials — two $S_3$ dials at conductors $31$ and $23$, an $A_4$ dial at $9$, a $D_4$ dial at $8$, an $F_{20}$ dial at $5$, and a $C_5$ dial at $11$ — measured how much of the type information is carried by the sum channel, by the difference channel, and by their synergy. The pattern was not uniform: most dials were "combination-required", but the $D_4$ dial at conductor $8$ appeared to be *sum-sufficient*. The proposed explanation was:

> *Given $N = pq \bmod 8$, the residue $(p+q) \bmod 8$ determines $p \bmod 8$ and $q \bmod 8$ (via $q \equiv N p^{-1}$), hence determines the type pair.*

This paper tests that explanation, finds it false, and replaces it by exact theorems that hold at every conductor.

### 1.3 Summary of results

1. **Conductor classification (Theorem 3.5).** The hinted view mod $m$ determines the unordered unit pair iff $m = 0, 1, 2, \ell$ or $2\ell$ with $\ell$ an odd prime.
2. **Half-conductor law (Theorems 4.2, 4.3, 4.5).** At $\ell^k$ the pair is determined modulo $\ell^{\lceil k/2\rceil}$, this is sharp, and the readable type maps are exactly those factoring through $(\mathbb Z/\ell^{\lceil k/2\rceil})^\times$.
3. **Hensel refinement (Theorem 4.6).** If $\ell^{t+1} \nmid p-q$, the pair is determined modulo $\ell^{k-t}$; if $p \not\equiv q \pmod\ell$ it is determined modulo the full conductor.
4. **Conductor 8 (Section 5).** The proposed explanation is false; readable dials at $8$ are exactly the $\times 5$-invariant ones; exactly one of the three quadratic channels of $\mathbb Q(\zeta_8)$ is readable; étale types of reducible polynomials need not be readable even when a factor is.
5. **Join failure and single-factor law (Section 6).** Readable channels do not combine; on a product ring they come from one factor.
6. **General classification (Theorem 6.7).** For every $m \ge 1$, readable $=$ "depends only on the residue modulo $\ell^{\lceil k/2 \rceil}$ for one prime power $\ell^k \,\|\, m$".

---

## 2. Definitions and first properties

Throughout, $R$ is a commutative ring and $R^\times$ its group of units.

**Definition 2.1 (Vieta-injective).** $R$ is *Vieta-injective* if for all units $p,q,p',q' \in R^\times$,
$$ p + q = p' + q' \ \text{ and }\ pq = p'q' \ \Longrightarrow\ \{p, q\} = \{p', q'\}, $$
i.e. $(p,q) = (p',q')$ or $(p,q) = (q',p')$.

**Definition 2.2 (Sum-sufficient / readable).** A type map $f : R^\times \to B$ is *sum-sufficient* (or *readable*) if for all units $p,q,p',q'$ with $p+q = p'+q'$ and $pq = p'q'$ we have the equality of unordered pairs $\{f(p),f(q)\} = \{f(p'),f(q')\}$.

We call the value $(p+q, pq)$ the *hinted view* or *cell* of the unordered pair $\{p,q\}$. A cell is *colliding* if it hosts more than one unordered pair.

**Proposition 2.3 (Universality).** $R$ is Vieta-injective iff the identity map of $R^\times$ is sum-sufficient, iff every type map on $R^\times$ is sum-sufficient.

*Proof.* The first equivalence is the definition. If $R$ is Vieta-injective, equal cells force equal unordered pairs of units, hence equal unordered pairs of types. $\square$

**Proposition 2.4 (Coarsening).** If $f$ is sum-sufficient and $g : B \to C$ is any function, then $g \circ f$ is sum-sufficient.

**Proposition 2.5 (Pullback).** If $\varphi : R \to S$ is a ring homomorphism and $g : S^\times \to B$ is sum-sufficient, then $g \circ \varphi^\times$ is sum-sufficient on $R^\times$.

*Proof.* A ring homomorphism maps equal sums to equal sums and equal products to equal products. $\square$

**Proposition 2.6.** If $f$ is sum-sufficient and injective, then $R$ is Vieta-injective. Vieta-injectivity and sum-sufficiency are invariant under ring isomorphisms.

---

## 3. The conductor classification

### 3.1 Domains

**Theorem 3.1 (Domains are Vieta-injective).** If $D$ is an integral domain, then $p+q = p'+q'$ and $pq = p'q'$ imply $\{p,q\} = \{p',q'\}$ for *all* elements (not only units). In particular $\mathbb Z$ and $\mathbb Z/\ell$ ($\ell$ prime) are Vieta-injective, and every type map of prime conductor is readable.

*Proof.* The key identity is
$$ (p - p')(p - q') \;=\; p\bigl((p+q) - (p'+q')\bigr) \;-\; (pq - p'q'). \tag{3.1}$$
If the sums and products agree, the right side vanishes, so $p = p'$ or $p = q'$; the other element is then recovered by cancelling from the equal sums. $\square$

Identity (3.1) is the engine of the whole paper: it converts "same cell" into "a product of two differences vanishes", and all the finer results measure how far this product can vanish without either factor vanishing.

### 3.2 Two obstructions

**Theorem 3.2 (Nilpotent obstruction).** If $R$ contains $a \neq 0$ with $a^2 = 0$, then $R$ is not Vieta-injective: the pairs $\{1,1\}$ and $\{1+a, 1-a\}$ are pairs of units with sum $2$ and product $1 - a^2 = 1$.

**Theorem 3.3 (Matching obstruction).** Let $R = R_1 \times R_2$ and suppose $u_1 \ne v_1$ in $R_1^\times$ and $u_2 \ne v_2$ in $R_2^\times$. Then the cells of
$$ \{(u_1,u_2), (v_1,v_2)\} \quad\text{and}\quad \{(u_1,v_2), (v_1,u_2)\} $$
coincide, but the pairs differ. Hence $R$ is not Vieta-injective.

*Proof.* Sums and products are computed componentwise, and in each component the two multisets $\{u_i, v_i\}$ agree. What is lost is the *matching* between components. $\square$

**Proposition 3.4.** If $R_1$ has a single unit and $R_2$ is Vieta-injective, then $R_1 \times R_2$ is Vieta-injective.

### 3.3 The classification

**Theorem 3.5 (Conductor classification).** $\mathbb Z/m\mathbb Z$ is Vieta-injective if and only if
$$ m = 0,\ 1,\ 2,\quad m = \ell,\quad\text{or}\quad m = 2\ell \qquad(\ell \text{ an odd prime}). $$

*Proof sketch.* ($\Leftarrow$) $m = 0$ gives $\mathbb Z$ and $m=\ell$ a field (Theorem 3.1); $m = 1, 2$ have a single unit; and $\mathbb Z/2\ell \cong \mathbb Z/2 \times \mathbb Z/\ell$ with $(\mathbb Z/2)^\times$ trivial (Proposition 3.4).

($\Rightarrow$) Suppose $m \notin$ the list. If $\ell^2 \mid m$ for some prime $\ell$, write $m = \ell^2 c$; then $a = \ell c$ is a nonzero element with $a^2 = \ell^2 c^2 \equiv 0$, and Theorem 3.2 applies. So $m$ is squarefree, $m \ge 3$. If $m$ had no odd prime factor it would be $1$ or $2$; so let $\ell \ge 3$ be an odd prime with $m = \ell c$, $\gcd(\ell,c) = 1$. As $m \ne \ell, 2\ell$, we have $c \ge 3$. By the Chinese remainder theorem $\mathbb Z/m \cong \mathbb Z/\ell \times \mathbb Z/c$, and in each factor $1 \neq -1$; Theorem 3.3 applies. $\square$

Exhaustive enumeration for $1 \le m \le 60$ produces the Vieta-injective list
$$1, 2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 22, 23, 26, 29, 31, 34, 37, 38, 41, 43, 46, 47, 53, 58, 59,$$
as predicted. At $m = 8$ there are $4$ colliding cells, at $m = 9$ there are $6$, at $m = 15$ there are $6$ (all of matching type), at $m = 16$ there are $16$.

---

## 4. The half-conductor law

### 4.1 How much of the pair survives at a prime power

**Lemma 4.1 (Valuation pigeonhole).** Let $\ell$ be prime and $2j \le k+1$. If $\ell^k \mid ab$ for integers $a,b$, then $\ell^j \mid a$ or $\ell^j \mid b$.

*Proof.* If $ab = 0$ this is clear. Otherwise $v_\ell(a) + v_\ell(b) \ge k$; if both were $\le j - 1$, the sum would be at most $2j - 2 \le k - 1$. $\square$

**Theorem 4.2 (Half-conductor law).** Let $\ell$ be prime, $k \ge 0$, and let $p,q,p',q'$ be arbitrary integers with
$$ \ell^k \mid (p+q) - (p'+q') \quad\text{and}\quad \ell^k \mid pq - p'q'. $$
Then $\{p, q\} \equiv \{p', q'\} \pmod{\ell^{\lceil k/2\rceil}}$ as unordered pairs: either $p \equiv p'$ and $q \equiv q'$, or $p \equiv q'$ and $q \equiv p'$, modulo $\ell^{\lceil k/2\rceil}$.

*Proof.* By (3.1), $\ell^k \mid (p-p')(p-q')$. Apply Lemma 4.1 with $j = \lceil k/2\rceil$ (so $2j \le k+1$): $\ell^j$ divides $p - p'$ or $p - q'$. The second element follows from the congruence of sums modulo $\ell^j$. $\square$

No coprimality is needed, and the prime $2$ is included.

**Theorem 4.3 (Sharpness).** Let $j = \lceil k/2\rceil$ and $a = \ell^j$. The pairs $\{1,1\}$ and $\{1+a, 1-a\}$ have the same sum and the same product modulo $\ell^k$ (the product differs by $a^2 = \ell^{2j}$, and $2j \ge k$), yet $1 \not\equiv 1 \pm a \pmod{\ell^{j+1}}$. Hence, whenever $j + 1 \le k$, the reduction $(\mathbb Z/\ell^k)^\times \to (\mathbb Z/\ell^{j+1})^\times$ is **not** readable, while the reduction to $(\mathbb Z/\ell^{j})^\times$ is readable.

Numerically, the maximal resolution $r \mid m$ at which the hinted view mod $m$ determines $\{p,q\} \bmod r$ is:

| $m$ | $8$ | $16$ | $32$ | $64$ | $9$ | $27$ | $81$ | $25$ |
|---|---|---|---|---|---|---|---|---|
| maximal resolution | $4$ | $4$ | $8$ | $8$ | $3$ | $9$ | $9$ | $5$ |
| $\ell^{\lceil k/2\rceil}$ | $4$ | $4$ | $8$ | $8$ | $3$ | $9$ | $9$ | $5$ |

### 4.2 Classification of readable maps at a prime power

**Lemma 4.4 (Square-zero rigidity).** In any commutative ring $R$, if $f$ is sum-sufficient and $x, y \in R^\times$ satisfy $(y-x)^2 = 0$, then $f(x) = f(y)$.

*Proof.* Put $d = y - x$. Then $w = x - d$ is a unit (with inverse $(x+d)x^{-2}$, since $(x-d)(x+d) = x^2$). The pairs $\{x,x\}$ and $\{y, w\}$ have sum $2x$ and product $x^2 - d^2 = x^2$. Sum-sufficiency gives $\{f(x),f(x)\} = \{f(y), f(w)\}$, so $f(y) = f(x)$. $\square$

**Theorem 4.5 (Classification at prime-power conductor).** A type map $f : (\mathbb Z/\ell^k)^\times \to B$ is readable if and only if it depends only on the residue modulo $\ell^{\lceil k/2\rceil}$:
$$ x \equiv y \pmod{\ell^{\lceil k/2\rceil}} \ \Longrightarrow\ f(x) = f(y). $$

*Proof.* ($\Leftarrow$) By Theorem 4.2 the reduction to $(\mathbb Z/\ell^{\lceil k/2\rceil})^\times$ is readable, and $f$ is a coarsening of it (Proposition 2.4). ($\Rightarrow$) If $x \equiv y \pmod{\ell^{j}}$ with $j = \lceil k/2 \rceil$, then $(y-x)^2$ is divisible by $\ell^{2j}$, hence by $\ell^k$, so $(y-x)^2 = 0$ in $\mathbb Z/\ell^k$; apply Lemma 4.4. $\square$

### 4.3 The Hensel refinement

**Theorem 4.6 (Discriminant-refined law).** Let $t + 1 \le k$ and suppose $\ell^{t+1} \nmid p - q$. If $\ell^k$ divides both $(p+q)-(p'+q')$ and $pq - p'q'$, then $\{p,q\} \equiv \{p',q'\} \pmod{\ell^{k-t}}$.

In particular (the case $t = 0$, **Hensel form**): *if $p \not\equiv q \pmod \ell$, the hinted view modulo $\ell^k$ determines the unordered pair modulo the full conductor $\ell^k$.*

*Proof sketch.* If both $p-p'$ and $p-q'$ were divisible by $\ell^{t+1}$, then so would be $p - q = (p-p') + (p-q') - ((p+q)-(p'+q'))$, a contradiction. So one of the two factors in (3.1) has valuation $\le t$, and the other must absorb at least $k - t$ factors of $\ell$. $\square$

This is the arithmetic of Hensel's lemma for the polynomial $x^2 - sx + n$: simple roots modulo $\ell$ (unit discriminant $(p-q)^2$) lift uniquely; all collisions of the half-conductor law come from pairs that are congruent modulo $\ell$.

---

## 5. Conductor 8: the $D_4$ dial, the three quadratic channels, and reducible polynomials

### 5.1 The proposed explanation is false

**Proposition 5.1.** The primes $17, 41$ and $13, 29$ satisfy
$$ 17\cdot 41 \equiv 13 \cdot 29 \equiv 1, \qquad 17 + 41 \equiv 13 + 29 \equiv 2 \pmod 8, $$
but $17 \equiv 41 \equiv 1$ while $13 \equiv 29 \equiv 5 \pmod 8$. Hence $(pq \bmod 8,\ p+q \bmod 8)$ does not determine $p \bmod 8$.

This is also a structural consequence of Theorem 3.5: $8$ is not of the form $0,1,2,\ell,2\ell$ (indeed $4^2 \equiv 0$), so $\mathbb Z/8$ is not Vieta-injective. The step "$q \equiv Np^{-1}$" silently transports a field fact — a monic quadratic has at most one factorisation into linear factors — to a ring where it fails: modulo $8$ one has $(x-1)^2 \equiv (x-5)^2 \equiv x^2 - 2x + 1$.

### 5.2 The exact criterion

The units mod $8$ are $\{1,3,5,7\} \cong (\mathbb Z/2)^2$. Let $\langle 5 \rangle = \{1, 5\}$, the kernel of reduction $(\mathbb Z/8)^\times \to (\mathbb Z/4)^\times$.

**Lemma 5.2 (Vieta fibres at 8).** The colliding cells of $\mathbb Z/8$ are exactly
$$ \{1,1\}\sim\{5,5\},\qquad \{3,3\}\sim\{7,7\},\qquad \{1,3\}\sim\{5,7\},\qquad \{1,7\}\sim\{3,5\}, $$
four colliding cells out of ten unordered pairs. In every case, if $(p,q)$ and $(p',q')$ share a cell, then after possibly swapping $p' \leftrightarrow q'$ we have $p' \in \{p, 5p\}$ and $q' \in \{q, 5q\}$.

**Theorem 5.3 (Criterion at conductor 8).** A type map $f$ on $(\mathbb Z/8)^\times$ is readable if and only if $f(5u) = f(u)$ for all units $u$ — equivalently, iff $f$ depends only on $p \bmod 4$.

*Proof.* ($\Rightarrow$) The diagonal collisions $\{1,1\}\sim\{5,5\}$ and $\{3,3\}\sim\{7,7\}$ force $f(5) = f(1)$ and $f(7) = f(3)$, which is $\times 5$-invariance on all four units. ($\Leftarrow$) By Lemma 5.2 every collision replaces each slot by itself or by its $\times5$-translate. $\square$

This is precisely the half-conductor law at $\ell = 2$, $k = 3$: $2^{\lceil 3/2\rceil} = 4$.

**Theorem 5.4 (The $\mathbb Q(i)$ layer at every conductor divisible by 8).** If $8 \mid m$, then every type map on $(\mathbb Z/m)^\times$ that factors through reduction to $(\mathbb Z/4)^\times$ is readable.

*Proof.* Reduction $m \to 4$ factors as $m \to 8 \to 4$; the map $(\mathbb Z/8)^\times \to (\mathbb Z/4)^\times$ is readable by Theorem 4.2, and readability pulls back along $\mathbb Z/m \to \mathbb Z/8$ (Proposition 2.5). $\square$

### 5.3 The three quadratic channels of $\mathbb Q(\zeta_8)$

The cyclotomic field $\mathbb Q(\zeta_8)$ has three quadratic subfields, each with a Legendre channel of conductor dividing $8$:

| field | channel | value $+1$ for $p \equiv$ | $\times 5$-invariant? | readable? |
|---|---|---|---|---|
| $\mathbb Q(i)$ | $\chi_4(p) = \left(\frac{-1}{p}\right)$ | $1 \pmod 4$ | yes | **yes** |
| $\mathbb Q(\sqrt 2)$ | $\chi_8(p) = \left(\frac{2}{p}\right)$ | $\pm 1 \pmod 8$ | no ($\chi_8(1) \ne \chi_8(5)$) | no |
| $\mathbb Q(\sqrt{-2})$ | $\chi_8'(p) = \left(\frac{-2}{p}\right)$ | $1, 3 \pmod 8$ | no ($\chi_8'(1) \ne \chi_8'(5)$) | no |

**Theorem 5.5 (Exactly one quadratic channel).** Among the Legendre channels of $\mathbb Q(i)$, $\mathbb Q(\sqrt 2)$, $\mathbb Q(\sqrt{-2})$, exactly the first is readable from the hinted view modulo $8$.

### 5.4 Reducible polynomials: the étale type channel

For a separable polynomial $F \in \mathbb Z[x]$ and an unramified prime $p$, the *étale type* of $p$ records how each irreducible factor of $F$ factors modulo $p$. For $F = (x^2+1)(x^2-2)$ it is the pair of Legendre symbols
$$ \tau(p) = \bigl(\chi_4(p),\ \chi_8(p)\bigr), $$
the *partition type* (the number of split quadratic factors) is $\pi(p) = [\chi_4(p) = 1] + [\chi_8(p) = 1]$, and for the irreducible polynomial $x^4+1$, whose splitting field is $\mathbb Q(\zeta_8)$, complete splitting occurs iff $p \equiv 1 \pmod 8$.

**Theorem 5.6 (Readability is not inherited from factors).**
1. The étale type $\tau$ of $(x^2+1)(x^2-2)$ is not readable, although its first coordinate $\chi_4$ is.
2. The partition type $\pi$ of $(x^2+1)(x^2-2)$ is not readable.
3. The complete-splitting indicator of $x^4+1$ is not readable.

*Proof.* (1) If $\tau$ were readable, so would be its coarsening $\chi_8$ (Proposition 2.4), contradicting Theorem 5.5. (2), (3) Each fails $\times5$-invariance at $u = 1$: $\pi(1) = 2 \ne 1 = \pi(5)$, and $1 \equiv 1$ but $5 \not\equiv 1 \pmod 8$. $\square$

So a reducible polynomial can have a readable factor and an unreadable étale type. The type channel of a reducible polynomial is the *join* of its factors' channels, and joins are exactly where readability breaks — the subject of the next section.

---

## 6. Combining channels: join failure and the single-factor law

### 6.1 Join failure

**Theorem 6.1 (Join failure).** Let $\ell_1 \ne \ell_2$ be odd primes and $m = \ell_1\ell_2$. The channels $p \mapsto p \bmod \ell_1$ and $p \mapsto p \bmod \ell_2$ are each readable at conductor $m$, but the joint channel $p \mapsto (p \bmod \ell_1, p \bmod \ell_2)$ is not. At $m = 15$ this gives the concrete example: mod $3$ readable, mod $5$ readable, jointly not.

*Proof.* Each single channel is pulled back from a field (Theorem 3.1, Proposition 2.5). The joint channel is injective by the Chinese remainder theorem, so by Proposition 2.6 its readability would make $\mathbb Z/\ell_1\ell_2$ Vieta-injective, contradicting Theorem 3.5. $\square$

Readable channels therefore form a down-set (closed under coarsening) that is **not** a lattice.

### 6.2 The swap dichotomy

**Lemma 6.2 (Swap dichotomy).** Let $g : X \times Y \to B$ satisfy, for all $x,x' \in X$ and $y,y' \in Y$,
$$ \{g(x,y),\ g(x',y')\} = \{g(x,y'),\ g(x',y)\} \quad\text{(as unordered pairs)}. $$
Then $g$ is independent of $y$, or $g$ is independent of $x$.

*Proof.* Suppose $g(x_0,y_1) \ne g(x_0,y_2)$ and $g(x_1,y_0) \ne g(x_2,y_0)$. Applying the hypothesis to $(x_0, x', y_1, y_2)$ and using $g(x_0,y_1) \ne g(x_0,y_2)$, the matching must be crossed, which forces $g(x',y_1) = g(x_0,y_1)$ for every $x'$: the column $y_1$ is constant. Now apply the hypothesis to $(x_1,x_2,y_1,y_0)$: either matching yields $g(x_1,y_0) = g(x_2,y_0)$, using the constancy of column $y_1$ in the uncrossed case. Contradiction. $\square$

### 6.3 Readable channels on a product ring

**Theorem 6.3 (Product dichotomy).** If $f$ is readable on $(R_1 \times R_2)^\times = R_1^\times \times R_2^\times$, then $f$ depends only on the $R_1$-component or only on the $R_2$-component.

*Proof.* By Theorem 3.3 the pairs $\{(x,y),(x',y')\}$ and $\{(x,y'),(x',y)\}$ always share a cell, so $g(x,y) = f(x,y)$ satisfies the hypothesis of Lemma 6.2. $\square$

**Theorem 6.4 (Classification on a product).** A type map on $(R_1\times R_2)^\times$ is readable iff it is of the form $h \circ \mathrm{pr}_1$ with $h$ readable on $R_1^\times$, or $h \circ \mathrm{pr}_2$ with $h$ readable on $R_2^\times$.

*Proof.* ($\Rightarrow$) By Theorem 6.3, say $f$ depends only on the first component; then $f = h\circ \mathrm{pr}_1$ with $h(u) = f(u,1)$, and $h$ is readable because a collision in $R_1$ lifts to a collision in the product by pairing with $1$ in the second slot. ($\Leftarrow$) Pullback along a projection (Proposition 2.5). $\square$

**Corollary 6.5 (Coprime conductors).** If $\gcd(a,b) = 1$, a type map on $(\mathbb Z/ab)^\times$ is readable iff it is a readable type map of the residue mod $a$, or a readable type map of the residue mod $b$.

**Corollary 6.6 (Two prime powers).** For distinct primes $\ell_1, \ell_2$, a type map on $(\mathbb Z/\ell_1^{k_1}\ell_2^{k_2})^\times$ is readable iff it depends only on the residue modulo $\ell_1^{\lceil k_1/2\rceil}$ or only on the residue modulo $\ell_2^{\lceil k_2/2 \rceil}$.

### 6.4 Every conductor

**Theorem 6.7 (Readable channels at an arbitrary conductor).** Let $m \ge 1$ and $f : (\mathbb Z/m)^\times \to B$. Then $f$ is readable if and only if there exist a prime $\ell$ and an exponent $k \ge 0$ with $\ell^k \mid m$ and $\gcd(m/\ell^k, \ell) = 1$ (that is, $\ell^k \,\|\, m$) such that
$$ x \equiv y \pmod{\ell^{\lceil k/2\rceil}} \ \Longrightarrow\ f(x) = f(y). $$

*Proof sketch.* ($\Leftarrow$) The reduction $m \to \ell^k \to \ell^{\lceil k/2\rceil}$ is readable by Theorem 4.2 and Proposition 2.5; $f$ is a coarsening.

($\Rightarrow$) Strong induction on $m$. For $m = 1$ every map is constant. Otherwise let $\ell$ be the smallest prime factor of $m$, $\ell^k \,\|\, m$, $r = m/\ell^k < m$. By Corollary 6.5, $f$ is a readable map of the residue mod $\ell^k$ — and then Theorem 4.5 finishes — or a readable map $h$ of the residue mod $r$. In the latter case the induction hypothesis gives a prime power $\ell'^{k'} \,\|\, r$ through whose half-resolution $h$ factors; since $\ell' \ne \ell$, also $\ell'^{k'} \,\|\, m$. (If $k' = 0$, $h$ is constant and any witness works.) $\square$

**Examples.** At $m = 24 = 2^3 \cdot 3$ the readable channels are functions of $p \bmod 4$ or functions of $p \bmod 3$, never both; indeed $p \bmod 2, 3, 4, 6$ are readable (units mod $6$ are units mod $3$) while $p \bmod 8, 12, 24$ are not. At $m = 8$ we recover Theorem 5.3.

A brute-force test of the criterion against the definition on 3487 type maps (all reductions modulo divisors, random maps factoring through random divisors, and random maps) at conductors $2 \le m \le 48$ found complete agreement.

---

## 7. Algorithms

**Algorithm A (Brute-force readability test).** Enumerate the $\binom{\varphi(m)+1}{2}$ unordered pairs of units, bucket them by cell $(p+q, pq) \bmod m$, and check that the multiset $\{f(p), f(q)\}$ is constant on every bucket. Time $O(\varphi(m)^2)$, memory $O(\varphi(m)^2)$.

**Algorithm B (Readability by the classification).** Factor $m = \prod \ell_i^{k_i}$. For each $i$, check whether $f$ is constant on the fibres of $u \mapsto u \bmod \ell_i^{\lceil k_i/2\rceil}$ (one pass over $(\mathbb Z/m)^\times$ with a dictionary). Return true iff some $i$ succeeds. Time $O(\omega(m)\,\varphi(m))$ after factoring — quadratically faster than Algorithm A, and correct by Theorem 6.7.

**Algorithm C (Maximal resolution).** For $m$, return the largest divisor $r \mid m$ such that the reduction $u \mapsto u \bmod r$ is readable, testing each divisor with Algorithm B. At a prime power $\ell^k$ the answer is $\ell^{\lceil k/2\rceil}$ (Theorems 4.2 and 4.3). At composite conductors the answer can carry a harmless extra factor $2$ that units cannot see: at $m = 24$ the answer is $6$, because the units modulo $6$ carry exactly the same information as the units modulo $3$.

---

## 8. Discussion

**The routing is dial-dependent — for a reason.** The empirical observation that different Galois dials route their information differently through sum and difference channels now has a structural backbone. The hinted view sees a single prime-power component of the conductor, at half resolution. A dial whose type map lives on that component at that resolution is readable from the sum; a dial that needs the full conductor, or two coprime components, requires the combination.

**What the $D_4$ dial at 8 must be doing.** If a dial at conductor $8$ is exactly sum-sufficient in the sense studied here, Theorem 5.3 says its type map sees only $p \bmod 4$ — the $\mathbb Q(i)$ layer of the conductor-8 tower. The previously proposed explanation ("the sum determines $p \bmod 8$") is incompatible with arithmetic in $\mathbb Z/8$. We stress that the theorems concern the hinted view of residues; they do not by themselves compute empirical percentages from finite prime samples.

**Two orthogonal failure modes.** Nilpotents ($\ell^2 \mid m$) cost resolution: they collapse $\ell^k$ to $\ell^{\lceil k/2\rceil}$. CRT splittings cost *matching*: they collapse a product to one factor. The general theorem is the product of these two effects.

**Reducible polynomials.** Because the étale type of a product $F_1 F_2$ is the join of the factor types, and readability is not closed under joins, the type channel of a reducible polynomial is generally unreadable even when each factor's channel is, unless all the information lives in a single prime-power layer at half resolution.

---

## 9. Future work

1. **Frobenius-cycle ($n$-tuple) dials.** For $n$ hidden units with elementary symmetric functions $e_1,\dots,e_n$ known mod $m = \prod \ell_i^{k_i}$, we conjecture that a type map is readable (the multiset $\{f(p_j)\}$ is determined) iff it factors through $(\mathbb Z/\ell_i^{\lceil k_i/n\rceil})^\times$ for a single $i$ (for odd $\ell_i > n$). The swap dichotomy should generalise: componentwise permutations of an $n$-tuple on a product ring preserve every $e_j$, and a grid function invariant under all mixed permutations must depend on one coordinate.
2. **Quantitative collision counts.** Count colliding cells at every conductor in closed form; the data $4, 6, 6, 16$ at $m = 8, 9, 15, 16$ suggest a multiplicative formula over the two obstruction types.
3. **Beyond residues.** Replace $\mathbb Z/m$ by residue rings of number fields, where non-abelian dials (e.g. $S_3$, $A_4$, $F_{20}$) become functions of Frobenius conjugacy classes rather than of residues.
4. **Statistical readability.** Relate exact readability to the empirical "carried percentages" of sum and difference channels, e.g. via the fraction of pairs lying in non-colliding cells, which the Hensel form controls.

---

*All results above are stated with complete hypotheses; every finite claim (fibres at $8$, the prime counterexample, the tables) is a finite computation reproducible by direct enumeration.*
