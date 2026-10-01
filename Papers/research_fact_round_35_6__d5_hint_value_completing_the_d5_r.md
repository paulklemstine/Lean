# The Dihedral Dial of $x^5+20x+32$ Carries Exactly Half a Bit of Hint

**Aristotle**

*October 2026*

---

## Abstract

We study how much information two residue views of a semiprime $N = pq$ carry about the splitting types of a fixed polynomial modulo the hidden factors $p$ and $q$. The *joint view* records $(p+q, q-p) \bmod m$, and the *product view* records $N \bmod m$. The difference of the two mutual informations is the **hint value**. For the solvable quintic $f = x^5+20x+32$, whose Galois group is the dihedral group $D_5$ of order 10, a battery of semiprimes read at the modulus $m^* = 320$ gave the empirical hint value $+0.6940$ bits. We explain and evaluate this number exactly. First, we identify the residue *dial* of $f$ as the Kronecker character $\chi_{20} = \left(\frac{-5}{\cdot}\right)$ of $\mathbb{Q}(\sqrt{-5})$. The identity with the Legendre symbol follows from quadratic reciprocity, and its agreement with the root counts of $f$ is checked for every prime $7 \le p < 100$. Second, in the Chebotarev model the hint value is exactly $\tfrac12$ bit for unordered labels and exactly $1$ bit for ordered labels. Third, a general *pinned-dial law* $I(T;D) = H(D)$, valid whenever the dial is a function of the label, explains the structure of these values. Fourth, the same constants $\tfrac12$ and $1$ hold for the $D_3$ field of $x^3-2$, even though its label entropy is different, so the hint value is a dihedral invariant rather than a quintic one. Finally, the joint view at $m = 320$ determines both characters $\chi_{20}(p), \chi_{20}(q)$, while the product view determines only their product, and we exhibit two explicit prime pairs that the product view merges. The reported $0.6940$ lies strictly between the unordered limit $\tfrac12$ and the ordered limit $1$. Plug-in estimates on growing batteries decrease monotonically toward $\tfrac12$, which identifies the excess as finite-sample bias of the $320^2$-cell joint view.

---

## 1. Introduction

Let $f \in \mathbb{Z}[x]$ be a fixed polynomial. For a prime $p$, the factorization pattern of $f \bmod p$ (and in particular the number of roots of $f$ in $\mathbb{F}_p$) is governed by the Frobenius conjugacy class of $p$ in the Galois group $G$ of the splitting field of $f$. For a semiprime $N = pq$ the pair of patterns at $p$ and $q$ is hidden information about the factors. We ask how much of this hidden information is visible through cheap residue views of the semiprime.

Two views are natural at a modulus $m$:

* the **product view** $V_{\mathrm{prod}} = N \bmod m$, which is computable from $N$ alone;
* the **joint view** $V_{\mathrm{joint}} = \big((p+q) \bmod m,\ (q-p) \bmod m\big)$, which requires knowledge of the factors.

If $T$ denotes the label (the pair of splitting types), the **hint value**
$$\mathcal{H} = I(T; V_{\mathrm{joint}}) - I(T; V_{\mathrm{prod}})$$
measures how much information about the label the sum-and-difference coordinates carry beyond the product. Our running example is the solvable quintic
$$f(x) = x^5 + 20x + 32,$$
with Galois group $D_5$. At modulus $m^* = 320$ the measured value is $\mathcal{H} \approx +0.6940$ bits. This paper fills in the $D_5$ row of the table of such hint laws.

1. We identify the **dial**, the residue-class invariant through which any residue view can see the label. It is the quadratic character of $\mathbb{Q}(\sqrt{-5})$ (Section 2).
2. We prove that in the Chebotarev limit the hint value is **exactly $\tfrac12$ bit** (Section 4), and **exactly $1$ bit** if the label records which factor is which.
3. We isolate a general **pinned-dial law** (Section 5) that explains these numbers structurally.
4. We show that the cubic $x^3-2$ with group $D_3$ has the same hint values (Section 6), which points to a dihedral universality.
5. We prove the needed facts about the residue views at $m = 320$ and give an explicit collision of real semiprimes (Section 7). We then reconcile the measured $0.6940$ with the exact limit (Section 8).

### Notation

All logarithms are to base $2$, so entropies are in bits. For a finite set $\Omega$ with the uniform distribution and functions $T, V$ on $\Omega$:
$$H(T) = -\sum_t \Pr[T=t]\log\Pr[T=t], \qquad H(T\mid V) = \sum_v \Pr[V=v]\, H(T \mid V=v),$$
$$I(T;V) = H(T) - H(T\mid V) = H(V) - H(V \mid T).$$

---

## 2. The dial of $x^5+20x+32$

### 2.1 The polynomial

**Proposition 2.1 (square discriminant).** The discriminant of the trinomial $x^5 + ax + b$ is $5^5 b^4 + 4^4 a^5$. For $(a,b) = (20,32)$,
$$5^5\cdot 32^4 + 4^4 \cdot 20^5 = 64000^2, \qquad 64000 = 2^9\cdot 5^3.$$
Hence the Galois group of $f$ is contained in the alternating group $A_5$.

**Proposition 2.2 (one real root).** The map $x \mapsto x^5 + 20x + 32$ is strictly increasing on $\mathbb{R}$, and $f$ has exactly one real root, which lies in $(-2,-1)$.

*Proof.* If $x<y$ then $x^5<y^5$ (odd power), so $f(x)<f(y)$. Moreover $f(-2) = -40 < 0 < 11 = f(-1)$. Apply the intermediate value theorem; strict monotonicity gives uniqueness. $\square$

Consequently complex conjugation fixes exactly one root of $f$ and swaps the other four in two pairs. In $D_5$, acting on the five roots as on the vertices of a pentagon, such an element is a **reflection**. So the unique quadratic subfield of the splitting field is the fixed field of the rotation subgroup $C_5$, and it is **imaginary**. (It is classical that the Galois group of $f$ is $D_5$, and the arithmetic below is consistent with that.)

### 2.2 The character $\chi_{20}$

**Definition 2.3.** Let $\chi_{20} : \mathbb{N} \to \{-1,0,1\}$ be defined by $\chi_{20}(n) = c(n \bmod 20)$, where
$$c(r) = \begin{cases} +1 & r \in \{1,3,7,9\},\\ -1 & r \in \{11,13,17,19\},\\ 0 & \text{otherwise.}\end{cases}$$

**Lemma 2.4 (complete multiplicativity).** $\chi_{20}(ab) = \chi_{20}(a)\chi_{20}(b)$ for all $a,b \in \mathbb{N}$.

*Proof.* Both sides depend only on $a, b \bmod 20$, and the identity holds for the $400$ residue pairs (a finite check). $\square$

**Theorem 2.5 (the dial is $\mathbb{Q}(\sqrt{-5})$).** For every prime $p \notin \{2,5\}$,
$$\left(\frac{-5}{p}\right) = \chi_{20}(p).$$

*Proof.* By multiplicativity of the Legendre symbol, $\left(\frac{-5}{p}\right) = \left(\frac{-1}{p}\right)\left(\frac{5}{p}\right)$. The first supplementary law gives $\left(\frac{-1}{p}\right) = +1$ if $p\equiv 1 \pmod 4$ and $-1$ if $p \equiv 3 \pmod 4$. Since $5 \equiv 1 \pmod 4$, quadratic reciprocity gives $\left(\frac{5}{p}\right) = \left(\frac{p}{5}\right)$, which is $+1$ for $p\equiv \pm1 \pmod 5$ and $-1$ for $p \equiv \pm 2 \pmod 5$. By the Chinese remainder theorem the product depends only on $p \bmod 20$. Running through the eight odd residues coprime to $5$ reproduces the table of $c$: for instance $p\equiv 3$ gives $(-1)(-1) = +1$ and $p \equiv 11$ gives $(-1)(+1) = -1$. $\square$

**Theorem 2.6 (root counts follow the dial).** For each of the 22 primes $7 \le p < 100$:
1. $f$ has $0$, $1$ or $5$ roots modulo $p$;
2. $f$ has exactly one root modulo $p$ if and only if $\chi_{20}(p) = -1$, equivalently (Theorem 2.5) $\left(\frac{-5}{p}\right) = -1$.

*Proof.* Direct enumeration of $x^5+20x+32 \bmod p$ over $x \in \{0,\dots,p-1\}$ for each listed prime. $\square$

*Remark 2.7 (extended computation).* For the 427 primes $7 \le p < 3000$, $f$ has $0$ roots $174$ times, $1$ root $221$ times and $5$ roots $32$ times, and never any other number. Part 2 of Theorem 2.6 holds for all 427 primes. Among the seven quadratic fields ramified only at $2$ and $5$, namely $\mathbb{Q}(\sqrt{d})$ for $d \in \{-1, \pm 2, \pm 5, \pm 10\}$, only $d = -5$ matches the root data. The frequencies $0.407, 0.518, 0.075$ approximate the Chebotarev densities $\tfrac4{10}, \tfrac5{10}, \tfrac1{10}$.

The conductor $20$ of $\chi_{20}$ explains why the experimental modulus must be divisible by $20$, and in fact by $40$ for the joint view (Remark 7.1′). The modulus $m^* = 320 = 2^4 \cdot 20$ meets both requirements.

---

## 3. The dihedral Chebotarev box

### 3.1 The group and its action

We realize $D_n$ ($n \ge 3$) as the $2n$ affine maps of $\mathbb{Z}/n$
$$\sigma_{e,b}: y \mapsto (-1)^e y + b, \qquad e \in \{0,1\},\ b \in \mathbb{Z}/n,$$
and encode $\sigma_{e,b}$ by the integer $x = ne + b \in \{0,\dots,2n-1\}$. The maps with $e = 0$ are the **rotations**, those with $e = 1$ the **reflections**.

**Definition 3.1.** For $x \in D_n$:
* the **label** $T(x) = \#\{y \in \mathbb{Z}/n : \sigma_x(y) = y\}$ is the number of fixed points. Under Frobenius it equals the number of roots of the polynomial modulo $p$;
* the **dial** $D(x) = e \in \{0,1\}$ records rotation ($\chi = +1$) or reflection ($\chi = -1$).

**Proposition 3.2 (labels are cycle types, $n = 5$).** For $x \in D_5$,
$$T(x) = \begin{cases} 5 & x \text{ is the identity},\\ 0 & x \text{ a nontrivial rotation},\\ 1 & x \text{ a reflection}.\end{cases}$$
Reflections are involutions ($\sigma_x\circ\sigma_x = \mathrm{id}$), and rotations satisfy $\sigma_x^5 = \mathrm{id}$. The three labels therefore correspond to the factorization patterns $[1^5]$, $[5]$ and $[1,2,2]$ of $f \bmod p$.

*Proof.* A reflection $y \mapsto -y + b$ fixes $y$ iff $2y = b$, which has exactly one solution because $2$ is invertible mod $5$. Applying it twice gives $y \mapsto -(-y+b)+b = y$. A rotation $y\mapsto y+b$ has fixed points iff $b = 0$. Its $k$-th iterate is $y \mapsto y + kb$, which is the identity for $k = 5$. $\square$

The same argument shows that for every **odd** $n$ the reflections are exactly the elements with one fixed point. The rotations have $0$ or $n$ fixed points.

### 3.2 The Chebotarev model

**Definition 3.3 (Chebotarev model).** The single-prime box is $D_n$ with the uniform distribution. The **semiprime box** is $D_n\times D_n$ with the uniform distribution, so the Frobenius elements of the two factors are independent and uniform. On the semiprime box $(x_1,x_2)$ define:

* the **ordered label** $T_{\mathrm{ord}} = (T(x_1), T(x_2))$;
* the **unordered label** $T_{\mathrm{un}} = \{T(x_1), T(x_2)\}$, recorded as (min, max). This is the label available to an observer who is not told which factor is which;
* the **pair dial** $D_{\mathrm{pair}} = (D(x_1), D(x_2))$, which is the joint view read through the dial, i.e. $(\chi(p),\chi(q))$;
* the **product dial** $D_{\mathrm{prod}} = D(x_1)+D(x_2) \bmod 2$, which is the product view read through the dial, i.e. $\chi(N) = \chi(p)\chi(q)$.

The **Chebotarev-limit hint value** of a label $T$ is
$$\mathcal{H}_n(T) = I(T; D_{\mathrm{pair}}) - I(T; D_{\mathrm{prod}}).$$

This model rests on two assumptions about the limit of large batteries: Frobenius elements are equidistributed (Chebotarev density), and the residue views at $m = 320$ see the label only through $\chi_{20}$ (Section 7). It is a model of the limit, not a theorem about any finite battery.

---

## 4. The $D_5$ hint law

### 4.1 The prime level

**Theorem 4.1 (the prime-level dial is pinned).** On $D_5$:
$$H(T) = \tfrac15 + \tfrac12\log 5, \qquad H(T\mid D) = \tfrac12\log 5 - \tfrac45, \qquad I(T;D) = 1 = H(D).$$

*Proof.* The label distribution is $(\tfrac1{10},\tfrac4{10},\tfrac5{10})$ on $(5,0,1)$, so
$$H(T) = \tfrac1{10}\log 10 + \tfrac4{10}\log\tfrac{10}{4} + \tfrac5{10}\log 2 = \tfrac15 + \tfrac12\log 5.$$
Given $D = 1$ (reflections) the label is constantly $1$, so it has entropy $0$. Given $D = 0$ (rotations) it is $(\tfrac15,\tfrac45)$ on $(5,0)$, with entropy $\log 5 - \tfrac85$. Averaging gives $H(T \mid D) = \tfrac12\log 5 - \tfrac45$, and subtracting gives $I(T;D) = 1$. The dial takes each value $5$ times out of $10$, so $H(D) = 1$. $\square$

The residual $H(T\mid D) = \tfrac12\log5-\tfrac45$ is the ambiguity between the identity and the nontrivial rotations, which no residue class can resolve.

### 4.2 The semiprime level

**Theorem 4.2 (the $D_5$ hint law, unordered labels).** On $D_5\times D_5$:
$$H(T_{\mathrm{un}}) = \log 5 - \tfrac{9}{50},\quad H(T_{\mathrm{un}}\mid D_{\mathrm{pair}}) = \log 5 - \tfrac{42}{25},\quad H(T_{\mathrm{un}}\mid D_{\mathrm{prod}}) = \log 5 - \tfrac{59}{50},$$
hence
$$I(T_{\mathrm{un}}; D_{\mathrm{pair}}) = \tfrac32,\qquad I(T_{\mathrm{un}}; D_{\mathrm{prod}}) = 1, \qquad \boxed{\ \mathcal{H}_5(T_{\mathrm{un}}) = \tfrac12\ }.$$

*Proof sketch.* The unordered labels $\{5,5\},\{0,5\},\{0,0\},\{1,5\},\{0,1\},\{1,1\}$ occur $1, 8, 16, 10, 40, 25$ times among the $100$ cells. Summing $\tfrac{c}{100}\log\tfrac{100}{c}$ gives $\log5-\tfrac9{50}$. Each of the four pair-dial fibres has $25$ cells:
* $(0,0)$: labels from two rotations, with counts $1, 8, 16$;
* $(0,1)$ and $(1,0)$: labels $\{1,5\}, \{0,1\}$ with counts $5, 20$ each;
* $(1,1)$: the single label $\{1,1\}$.

Averaging the fibre entropies gives $\log 5 - \tfrac{42}{25}$. The two product-dial fibres have $50$ cells each. The even fibre has counts $1,8,16,25$ and the odd fibre has counts $10, 40$. Averaging gives $\log5-\tfrac{59}{50}$. The rest is subtraction: $\tfrac{42}{25}-\tfrac{9}{50} = \tfrac32$ and $\tfrac{59}{50}-\tfrac{9}{50} = 1$. $\square$

A derivation of $\tfrac32$ and $1$ that avoids conditional-entropy bookkeeping is given in Section 5.

**Theorem 4.3 (ordered labels).** On $D_5\times D_5$: $H(T_{\mathrm{ord}}) = \tfrac25 + \log 5$, $H(T_{\mathrm{ord}}\mid D_{\mathrm{pair}}) = \log 5 - \tfrac85$ and $H(T_{\mathrm{ord}}\mid D_{\mathrm{prod}}) = \log5-\tfrac35$. Hence
$$I(T_{\mathrm{ord}}; D_{\mathrm{pair}}) = 2,\qquad I(T_{\mathrm{ord}}; D_{\mathrm{prod}}) = 1,\qquad \mathcal{H}_5(T_{\mathrm{ord}}) = 1.$$

*Proof sketch.* The ordered label distribution is the product of two copies of $(\tfrac1{10},\tfrac4{10},\tfrac5{10})$, with counts $1,4,5,4,16,20,5,20,25$, so $H = 2\cdot(\tfrac15+\tfrac12\log5)$. Each pair-dial fibre is a product of single-prime fibres. Each product-dial fibre has entropy $\log 5 - \tfrac35$: the even fibre has counts $1,4,4,16,25$ and the odd fibre has counts $5,20,5,20$. $\square$

The difference $1 - \tfrac12$ between the ordered and unordered hint values is exactly the *which-factor* information.

---

## 5. The pinned-dial law

**Theorem 5.1 (pinned-dial law).** Let $\Omega$ be a finite nonempty set with the uniform distribution, and let $T:\Omega\to\mathcal{B}$ and $D:\Omega\to\mathcal{C}$. If there is $g:\mathcal{B}\to\mathcal{C}$ with $D(\omega) = g(T(\omega))$ for all $\omega\in\Omega$, then
$$I(T;D) = H(D).$$

*Proof.* Use $I(T;D) = H(T) - H(T\mid D)$ and the chain rule $H(T) = H(T,D) - H(D\mid T) = H(T,D)$, since $D$ is determined by $T$. Also $H(T\mid D) = H(T,D) - H(D)$. Subtracting gives $I(T;D) = H(D)$. Equivalently, each fibre $\{T = t\}$ lies inside the fibre $\{D = g(t)\}$, which forces $H(D \mid T) = 0$. $\square$

**Corollary 5.2 (the product row is pinned).** On $D_5\times D_5$ the product dial is a function of the unordered label: $D_{\mathrm{prod}} = 1$ iff exactly one of the two labels equals $1$. Therefore
$$I(T_{\mathrm{un}}; D_{\mathrm{prod}}) = H(D_{\mathrm{prod}}) = 1.$$

*Proof.* By Proposition 3.2, label $1$ is equivalent to "reflection". So $D(x_1)+D(x_2)$ is odd iff exactly one factor is a reflection iff exactly one entry of $T_{\mathrm{un}}$ equals $1$. The product dial is balanced ($50$ cells each), so $H(D_{\mathrm{prod}}) = 1$. Apply Theorem 5.1. $\square$

**Proposition 5.3 (the pair row is not pinned).** $I(T_{\mathrm{un}}; D_{\mathrm{pair}}) = \tfrac32 < 2 = H(D_{\mathrm{pair}})$.

*Structural proof of $\tfrac32$.* $D_{\mathrm{pair}}$ is uniform on four values, so $H(D_{\mathrm{pair}}) = 2$. The unordered label determines the unordered pair $\{D(x_1),D(x_2)\}$. If the two dials agree, the ordered pair is determined. If they differ, which happens with probability $\tfrac12$, the label is symmetric under swapping the factors, so both orders are equally likely and exactly one bit is missing. Hence $H(D_{\mathrm{pair}}\mid T_{\mathrm{un}}) = \tfrac12$ and $I = 2-\tfrac12 = \tfrac32$. Equivalently, $\tfrac32$ is the entropy of an unordered pair of independent fair bits, with distribution $(\tfrac14,\tfrac12,\tfrac14)$. $\square$

**Reading.** The hint value is the part of the *second* character that the label can recover beyond the product:
$$\mathcal{H}_5(T_{\mathrm{un}}) = \underbrace{H(\{\chi(p),\chi(q)\})}_{3/2} - \underbrace{H(\chi(p)\chi(q))}_{1} = \tfrac12.$$
With ordered labels the pair row is pinned as well ($D_{\mathrm{pair}}$ is a function of $T_{\mathrm{ord}}$), giving $2 - 1 = 1$.

---

## 6. Dihedral universality: the $D_3$ control

The cubic $x^3 - 2$ has splitting field $\mathbb{Q}(\sqrt[3]{2},\omega)$ with Galois group $D_3 \cong S_3$, and its quadratic subfield is $\mathbb{Q}(\sqrt{-3})$. In the model of Section 3 with $n = 3$ the labels are $3$ (identity), $0$ (two $3$-cycles) and $1$ (three transpositions).

**Theorem 6.1 ($D_3$ hint law).** On $D_3\times D_3$ (36 cells):
$$H(T_{\mathrm{un}}) = \log3+\tfrac{13}{18},\quad H(T_{\mathrm{un}}\mid D_{\mathrm{pair}}) = \log3-\tfrac79,\quad H(T_{\mathrm{un}}\mid D_{\mathrm{prod}}) = \log3-\tfrac5{18};$$
$$H(T_{\mathrm{ord}}) = \log3+\tfrac43,\quad H(T_{\mathrm{ord}}\mid D_{\mathrm{pair}}) = \log3-\tfrac23,\quad H(T_{\mathrm{ord}}\mid D_{\mathrm{prod}}) = \log3+\tfrac13.$$
Hence $\mathcal{H}_3(T_{\mathrm{un}}) = \tfrac12$ and $\mathcal{H}_3(T_{\mathrm{ord}}) = 1$.

**Theorem 6.2 (dihedral hint universality for $n = 3, 5$).**
$$\mathcal{H}_3(T_{\mathrm{un}}) = \mathcal{H}_5(T_{\mathrm{un}}) = \tfrac12,\qquad \mathcal{H}_3(T_{\mathrm{ord}}) = \mathcal{H}_5(T_{\mathrm{ord}}) = 1,$$
while the label entropies differ: $H_{D_5}(T_{\mathrm{un}}) = \log5-\tfrac9{50} < \log 3+\tfrac{13}{18} = H_{D_3}(T_{\mathrm{un}})$.

*Proof.* The equalities follow from Theorems 4.2, 4.3 and 6.1. For the inequality, $\log 3 > 1.58$ and $\log 5 < 2.33$ give $\log5-\tfrac9{50} < 2.15 < 2.30 < \log3+\tfrac{13}{18}$. $\square$

The structural arguments of Section 5 use only two facts: for odd $n$, the reflection class is exactly the set of elements with one fixed point, and the reflections make up half the group. Both hold for every odd $n$. Exact computation in the same box gives $\tfrac12$ and $1$ for $n = 7, 9, 11$ as well. For even $n$ the reflections split into elements with $0$ and $2$ fixed points, the label no longer determines the dial, and the law fails (for $n = 4$ the unordered value is about $0.319$ bits). The general odd-$n$ statement is formulated as Conjecture 10.1.

---

## 7. The residue views at $m^* = 320$

**Theorem 7.1 (the joint view pins both characters).** Let $p,q,p',q'\in\mathbb{N}$ with
$$p+q\equiv p'+q' \pmod{320}, \qquad q-p \equiv q'-p' \pmod{320}.$$
Then $p\equiv p'$ and $q\equiv q' \pmod{160}$. In particular $\chi_{20}(p) = \chi_{20}(p')$ and $\chi_{20}(q) = \chi_{20}(q')$.

*Proof.* Adding and subtracting the congruences gives $2q \equiv 2q'$ and $2p\equiv 2p' \pmod{320}$, hence $q \equiv q'$ and $p\equiv p' \pmod{160}$. Since $20 \mid 160$, the residues mod $20$ agree, and $\chi_{20}$ depends only on them. $\square$

*Remark 7.1′ (which moduli work).* The proof of Theorem 7.1 loses a factor of $2$: the joint view at modulus $m$ pins the factors only modulo $m/2$. So the joint view sees $\chi_{20}$ of each factor exactly when $40 \mid m$. The product view sees $\chi_{20}(N)$ already when $20 \mid m$. The modulus $320$ satisfies both conditions. Experimentally, with $B = 1500$ the plug-in hint is $0.74$ at $m=320$ and $0.60$ at $m = 160$, but only $0.07$ at $m = 100$ and $0.11$ at $m = 64$. Both $100$ and $64$ fail $40 \mid m$, and what remains there is pure estimator bias.

**Theorem 7.2 (the product view pins only the product).** If $pq\equiv p'q' \pmod{320}$ then $\chi_{20}(p)\chi_{20}(q) = \chi_{20}(p')\chi_{20}(q')$.

*Proof.* Reduce modulo $20 \mid 320$ and apply Lemma 2.4: $\chi_{20}(p)\chi_{20}(q) = \chi_{20}(pq) = \chi_{20}(p'q') = \chi_{20}(p')\chi_{20}(q')$. $\square$

**Theorem 7.3 (the product view merges distinct dial pairs).** The numbers $7, 11, 13, 569$ are prime, and
$$11\cdot 13 = 143 \equiv 7\cdot 569 = 3983 \pmod{320}.$$
The polynomial $f$ has exactly one root modulo $11$ and modulo $13$, with $\chi_{20} = -1$ (type $[1,2,2]$), and no root modulo $7$ and modulo $569$, with $\chi_{20} = +1$ (type $[5]$). Their factor sums satisfy $24 \not\equiv 576 \pmod{320}$, so the joint view separates the two semiprimes.

*Proof.* Direct computation. $\square$

Together, Theorems 7.1–7.3 justify reading the joint view as $(\chi(p),\chi(q))$ and the product view as $\chi(p)\chi(q)$ in the Chebotarev model. Only the dial of the label is visible to residue classes. Theorem 7.3 shows that the information lost by the product view is real: $(-1)(-1) = (+1)(+1)$.

---

## 8. The verdict and the finite-sample reading

**Theorem 8.1 (THE-D5-DIAL-CARRIES-A-HINT).**
$$0 < \mathcal{H}_5(T_{\mathrm{un}}) = \tfrac12 < 0.6940 < 1 = \mathcal{H}_5(T_{\mathrm{ord}}).$$
The Chebotarev-limit hint value is strictly positive. The reported reading lies strictly between the unordered and ordered limits, so it is consistent with a positive hint plus a finite-sample excess, and it cannot be the ordered law.

**Plug-in experiments.** Let $B$ be a bound. Take all pairs $7\le p<q<B$ of primes with the uniform empirical distribution, the unordered root-count label, the joint view $((p+q)\bmod 320,(q-p)\bmod 320)$ and the product view $pq \bmod 320$, and compute plug-in mutual informations. This gives:

| $B$ | pairs $M$ | $\widehat I(T;V_{\mathrm{joint}})$ | $\widehat I(T;V_{\mathrm{prod}})$ | $\widehat{\mathcal{H}}$ |
|---|---|---|---|---|
| 500 | 4,186 | 1.8785 | 1.0228 | 0.8557 |
| 1,500 | 27,730 | 1.7398 | 1.0035 | 0.7363 |
| 4,000 | 149,331 | 1.6142 | 1.0006 | 0.6135 |

If the joint view is replaced by the residue pair read through the dial, $(\chi_{20}(p),\chi_{20}(q))$, the plug-in values are $1.4873$, $1.4979$ and $1.4987$, approaching $\tfrac32$. The product view (320 cells) is essentially at its limit $1$ already. The raw joint view has up to $320^2 = 102{,}400$ cells and carries a large upward plug-in bias that decays as $M$ grows. The decreasing sequence $0.8557 > 0.7363 > 0.6135$ brackets the reported $0.6940$ and moves toward the exact limit $\tfrac12$. These estimates are empirical. They illustrate the limit theorem but are not part of its proof.

---

## 9. Algorithms

**Algorithm A (dial identification).** Input: a polynomial $f$ and a prime bound $P$.
1. For each prime $p<P$ not dividing the discriminant, compute $r(p) = \#\{x\in\mathbb{F}_p: f(x)=0\}$ by evaluation ($O(p)$ per prime, $O(P^2/\log P)$ in total).
2. For each candidate quadratic discriminant $d$ supported on the ramified primes, compute $\left(\frac{d}{p}\right)$ by Euler's criterion ($O(\log p)$ multiplications).
3. Return the $d$ such that $[r(p) = 1] \Leftrightarrow \left(\frac{d}{p}\right)=-1$ for all tested $p$.

For $f = x^5+20x+32$ and $P = 3000$ the output is $d = -5$.

**Algorithm B (exact Chebotarev hint value).** Input: odd $n$ and a label type (ordered or unordered).
1. Enumerate $D_n$ as the pairs $(e,b)$, compute fixed-point counts $T$ and dials $D = e$.
2. Enumerate the $4n^2$ cells of $D_n\times D_n$ and tabulate the joint counts of (label, pair dial) and (label, product dial).
3. Compute $I = H(T)+H(V)-H(T,V)$ from the counts for both views and return the difference.

The cost is $O(n^3)$ for the fixed points and $O(n^2)$ for the tabulation. Entropies are exact sums of $\tfrac{c}{N}\log\tfrac Nc$, which are rational combinations of $\log$ of small integers.

**Algorithm C (plug-in battery estimator).** Input: a bound $B$ and a modulus $m$.
1. Sieve the primes $7\le p<B$ and compute root counts.
2. For every pair $p<q$ record the label $\{r(p),r(q)\}$, the joint view and the product view.
3. Return $\widehat I(T;V_{\mathrm{joint}}) - \widehat I(T;V_{\mathrm{prod}})$ from the empirical counts.

The cost is $O(\pi(B)^2)$ time and $O(\min(\pi(B)^2, m^2))$ memory.

---

## 10. Discussion and future work

**What the dial means.** A residue view of a semiprime sees only abelian information about the factors, namely Dirichlet characters. For a non-abelian Galois group $G$, the information in the Frobenius label visible to residue views is the image of Frobenius in the abelianization $G^{\mathrm{ab}}$. For $D_n$ with $n$ odd, $G^{\mathrm{ab}} = C_2$, and the corresponding character is the quadratic character of the unique quadratic subfield, here $\chi_{20}$ for $\mathbb{Q}(\sqrt{-5})$. The rotation ambiguity $H(T\mid D) = \tfrac12\log5-\tfrac45$ is invisible to every residue class.

**Caveats.** The Chebotarev model (uniform, independent Frobenius elements) describes the limit and is not a statement about finite batteries. The identification of the dial with $\mathbb{Q}(\sqrt{-5})$ was established at the level of the character table (via reciprocity), together with a finite check of root counts, and not through a full Galois-theoretic computation for $f$. All exact entropies above are rational combinations of $\log 2,\log 3,\log 5$, computed from fibre counts.

**Conjecture 10.1 (dihedral universality, all odd $n$).** For every odd $n\ge3$, in the Chebotarev model of a $D_n$ field, the hint value of the quadratic dial is exactly $\tfrac12$ bit for unordered labels and exactly $1$ bit for ordered labels. The structural proof in Section 5 reduces this to the statement that, for odd $n$, the label (number of fixed points) determines the dial. That holds because reflections have exactly one fixed point and rotations have $0$ or $n$.

**Conjecture 10.2 (plug-in bias law).** For $M$ semiprimes read through the joint view at modulus $m$, the excess of the plug-in hint value over its limit is $\frac{(K-1)(|T|-1)}{2M\ln 2}+o(1/M)$, where $K$ is the number of occupied joint cells. This is the Miller–Madow form of the bias.

**Conjecture 10.3 (non-dihedral solvable quintics).** For the Frobenius group $F_{20}$ (e.g. $x^5-2$), numerical evidence suggests an unordered hint value of $\tfrac98$ bits and an ordered value of $\tfrac74$ for its cyclic quartic dial. For a cyclic quintic $C_5$ the label is pinned by the dial, and the hint value equals $H(\text{pair dial})-H(\text{product dial})$. The three solvable quintic groups $C_5$, $D_5$ and $F_{20}$ appear to have pairwise distinct hint values. If so, the hint value would be a Galois-group invariant detectable from residue statistics of semiprimes.

---

## 11. Conclusion

The dial of $x^5+20x+32$ is the character $\left(\frac{-5}{\cdot}\right)$ of conductor $20$. Through a window of $320$ residues, the factor sum and difference reveal this character for each factor separately, while the product reveals only its product. In the Chebotarev limit this asymmetry is worth exactly half a bit about the unordered splitting types of a semiprime, and exactly one bit about the ordered types. The value is the same for the triangle group $D_3$ as for the pentagon group $D_5$. It follows from a single structural principle, the pinned-dial law $I(T;D) = H(D)$. The empirical reading $0.6940$ lies strictly between the two exact limits, and plug-in estimates on growing batteries decrease toward $\tfrac12$.
