# Depth Decay of the Magnitude Channel on the Berggren Tree of Primitive Pythagorean Triples

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Primitive Pythagorean triples are organized by Berggren's ternary tree, and in the standard $(m,n)$ parametrization the descent from a triple towards the root $(3,4,5)$ is governed entirely by the position of the ratio $r=m/n$ relative to the two cut points $2$ and $3$. The resulting address word over the alphabet $\{A,B,C\}$ is a Gauss-map style digit expansion of $r$. We study how much of that address is legible to a *fixed-precision magnitude sensor*: the functional $P_W(m,n)=\lfloor 2^{W}m/n\rfloor$, whose budget $W$ does not grow with the size or the depth of the state. We prove that the sensor's reach is exactly the leading translation run plus one letter, and no more.

Three positive results establish the channel. First, the first descent letter is an explicit function of the single one-bit reading $\lfloor 2m/n\rfloor$. Second, the leading $C$-run has length exactly $L=\lfloor (m-n)/(2n)\rfloor$, and any two admissible states with equal one-bit readings agree on all letters $0,\dots,L$ — the entire run together with the inversion letter that terminates it; along the pure-$C$ spine this makes arbitrarily many letters readable. Third, this depth is metered: $L \le P_1(m,n)/4$, so reading depth $L$ costs $\Theta(\log L)$ output bits.

Four negative results pin the boundary. (i) *Depth null*: for every budget $W$ and every depth $k$ there exist admissible states $s^{\pm}$ with $P_W(s^+)=P_W(s^-)$, identical addresses $C^kB$ through position $k$, and different letters at position $k+1$; hence the depth-$(k+1)$ letter is not a function of $P_W$, for any $W$ and any $k$. (ii) The colliding pairs occur with arbitrarily large denominators. (iii) *Universal null*: the same failure holds for every rational rescaling $\lfloor (a/b)(m/n)\rfloor$, by a construction based on an *attained* boundary and the right-continuity of the floor function; refining the scale is structurally useless. (iv) *Capacity null*: every word over $\{A,B,C\}$ is realized by an admissible state, and on the ratio-bounded stratum the $W$-window sensor takes at most $2\cdot 2^{W}$ values against $2^{k}$ behaviours, so $2\cdot2^{W}<2^{k}$ already forces a collision by pigeonhole, independently of any explicit construction.

The threshold is sharp: depth $1$ is always readable, depth $2$ is null for every budget. The mechanism is that the $C$-branch is a translation of the ratio (an isometry, transparent to truncation) while the $A$- and $B$-branches are inversions (expansive, opaque), and that the only dyadic branch boundary is the top-level cut point $2$. We interpret these results as a quantitative sealing statement for cryptographic shortcut attempts on the Pythagorean tree: a computable fixed-window sensor reads the coarse digits of the ratio and nothing finer, and the full address again costs a Euclidean descent.

**Keywords:** Pythagorean triples, Berggren tree, Gauss map, continued fractions, information channel, dyadic rationals, pigeonhole capacity bound, factoring shortcuts.

---

## 1. Introduction

### 1.1 The Berggren tree

A *primitive Pythagorean triple* is a triple $(x,y,z)$ of positive integers with $x^2+y^2=z^2$ and $\gcd(x,y,z)=1$. Euclid's parametrization puts these in bijection with pairs $(m,n)$ of positive integers satisfying
$$0 < n < m, \qquad \gcd(m,n)=1, \qquad m+n \text{ odd},$$
via $(x,y,z)=(m^2-n^2,\,2mn,\,m^2+n^2)$. We call such a pair **admissible** and write $\mathrm{Adm}$ for the set of admissible pairs.

Berggren observed that the primitive triples form a rooted ternary tree in which each triple has exactly three children and every primitive triple occurs exactly once. In $(m,n)$ coordinates the tree is rooted at $(2,1)$ — the triple $(3,4,5)$ — and the three child maps are
$$
\mathsf{A}(m,n)=(2m-n,\,m),\qquad
\mathsf{B}(m,n)=(2m+n,\,m),\qquad
\mathsf{C}(m,n)=(m+2n,\,n).
$$

Each admissible pair other than the root therefore has a unique **address**: the finite word over $\Sigma=\{A,B,C\}$ recording which child map was applied at each step from the root. Equivalently, the address read from the state upwards is the sequence of letters produced by the *descent map*.

### 1.2 The descent as a Gauss-map digit expansion

Define, for a pair $s=(m,n)$, the letter
$$
\mathrm{letter}(s)=
\begin{cases}
A & m < 2n,\\
B & 2n < m < 3n,\\
C & 3n < m,
\end{cases}
\qquad
\mathrm{par}(s)=
\begin{cases}
(n,\;2n-m) & m<2n,\\
(n,\;m-2n) & 2n<m<3n,\\
(m-2n,\;n) & 3n<m.
\end{cases}
$$
The descent letter at depth $k$ is $\ell_k(s) := \mathrm{letter}\big(\mathrm{par}^{k}(s)\big)$, with $\ell_0$ the first letter.

In terms of the ratio $r=m/n$ the parent ratios are
$$
A: r\mapsto \frac{1}{2-r},\qquad
B: r\mapsto \frac{1}{r-2},\qquad
C: r\mapsto r-2.
$$
This is precisely the shape of a Gauss-map digit extraction: subtract an integer, and invert when the remainder is small. **The address of a triple is a digit expansion of its ratio.**

Two arithmetic facts keep the descent away from the boundaries and make everything well-defined.

**Lemma 1.1 (No boundary states).** *If $s$ is admissible and $m=2n$, then $s$ is the root $(2,1)$. If $s$ is admissible then $m \neq (2j+3)n$ for every $j \ge 0$; in particular $m\neq 3n$.*

*Proof sketch.* If $n \mid m$ then $\gcd(m,n)=n$, forcing $n=1$; then $m=2$ (root case) or $m=2j+3$, which is odd, contradicting the parity condition $m+n$ odd with $n=1$. $\square$

**Lemma 1.2 (Descent preserves admissibility).** *If $s$ is admissible and $s\neq(2,1)$, then $\mathrm{par}(s)$ is admissible.*

*Proof sketch.* In each of the three cases positivity and the strict inequality follow from Lemma 1.1; the parity condition is preserved because each branch replaces $\{m,n\}$ by $\{n, m\pm 2n\}$ or $\{m-2n,n\}$, and $\pm 2n$ does not change parity; coprimality follows because any common divisor of the parent's entries divides both $m$ and $n$ by an explicit two-term linear combination. $\square$

### 1.3 The sensor model

**Definition 1.3 ($W$-window magnitude sensor).** For $W \in \mathbb{N}$, the $W$-window sensor is
$$P_W(m,n) \;=\; \left\lfloor \frac{2^{W}m}{n}\right\rfloor.$$
It reads the magnitude of the ratio to $W$ binary places and nothing else. The budget $W$ is fixed: it does not grow with $m$, $n$, or the depth of $s$ in the tree.

**Definition 1.4 (Rational-scale sensor).** For positive integers $a,b$,
$$G_{a,b}(m,n) \;=\; \left\lfloor \frac{a\,m}{b\,n}\right\rfloor .$$
Note $G_{2^{W},1}=P_W$: this class contains every monotone rational rescaling of the magnitude followed by truncation.

The question of this paper: **for which $k$ is $\ell_k$ a function of the sensor reading?**

### 1.4 Empirical motivation

The question was posed empirically. On a large sampled population of admissible states, the mutual information between a fixed-window magnitude feature and the descent letter at depth $t$ decays roughly by a factor of two every two levels:
$$
0.184,\;0.143,\;0.094,\;0.078,\;0.054,\;0.040,\;0.032,\;0.019 \quad (t=1,\dots,8),
$$
in bits. Raw mutual information, however, overstates the per-step channel, because the letters are themselves strongly dependent: a sensor that reads only $\ell_0$ appears informative about $\ell_3$ merely through the correlation of $\ell_3$ with $\ell_0$. The honest test conditions on the path prefix, permuting labels *within* prefix classes. Under that control the picture is stark: the second letter is read with overwhelming significance, the third marginally, the fourth is at the edge, and **the fifth is statistically null**. Separately, depth itself is visible: a magnitude feature carries about $0.111$ bits about the depth of the state.

The theorems below explain the entire shape of this curve: they identify the readable prefix exactly, prove that nothing beyond it is readable at any budget, and give a capacity bound that forces the decay independently of any construction.

---

## 2. The channel exists: depth-one readability

**Definition 2.1.** The decoder $D:\mathbb{N}\to\Sigma$ is
$$D(p)=\begin{cases} A & p \le 3,\\ B & 4\le p\le 5,\\ C & p \ge 6.\end{cases}$$

**Theorem 2.2 (First-letter readability).** *For every admissible $s=(m,n)$,*
$$\ell_0(s) = D\big(P_1(s)\big) = D\big(\lfloor 2m/n\rfloor\big).$$

*Proof sketch.* Three cases. If $m<2n$ then $2m<4n$, so $\lfloor 2m/n\rfloor \le 3$. If $2n<m<3n$ then $4n \le 2m < 6n$, so the reading lies in $\{4,5\}$. If $m>3n$ then $2m\ge 6n$, so the reading is $\ge 6$. The strict separations use Lemma 1.1 to exclude $m=2n$ (away from the root) and $m=3n$. $\square$

**Corollary 2.3.** *Two admissible states with the same one-bit reading have the same first letter.*

The one-bit reading is the coarsest nontrivial magnitude functional, and it already suffices for the first digit. The reason is structural and worth naming now: **the top-level cut point $2$ is a dyadic rational**, so it is exactly representable at finite binary precision and a truncation sensor can be aligned with it. All deeper cut points will fail to be dyadic, and that is precisely the obstruction of Section 4.

---

## 3. The reach of the channel: the leading translation run

### 3.1 Translation branches are transparent

**Lemma 3.1 ($C$-steps shift the reading).** *If $s$ is admissible with $\ell_0(s)=C$, then*
$$P_1(\mathrm{par}(s)) + 4 = P_1(s).$$

*Proof sketch.* In the $C$ case $\mathrm{par}(m,n)=(m-2n,n)$ and $2m = 2(m-2n)+ n\cdot 4$; divide by $n$ and use $\lfloor (x+4n)/n\rfloor = \lfloor x/n\rfloor + 4$. $\square$

This is the crux of the positive theory. The $C$-branch acts on ratios as $r\mapsto r-2$, an *isometry*; the sensor's reading is merely translated by a constant, and no precision is lost. The $A$- and $B$-branches act by inversion, which expands differences without bound near the fixed boundaries.

**Proposition 3.2 (Prefix propagation).** *Let $s,s'$ be admissible with $P_1(s)=P_1(s')$, and suppose $\ell_j(s)=C$ for all $j<k$. Then $\ell_k(s)=\ell_k(s')$.*

*Proof sketch.* Induction on $k$. The base case is Corollary 2.3. For the step, $\ell_0(s)=C$; by Corollary 2.3 also $\ell_0(s')=C$; by Lemma 3.1 both readings drop by exactly $4$, so $P_1(\mathrm{par}(s))=P_1(\mathrm{par}(s'))$; both parents are admissible by Lemma 1.2 (a state with letter $C$ is not the root); apply the induction hypothesis and $\ell_{k+1}(s)=\ell_k(\mathrm{par}(s))$. $\square$

Note the asymmetry in the hypothesis: only $s$ is assumed to have a $C$-prefix. The agreement of the earlier letters propagates the property to $s'$ automatically.

### 3.2 The run length is one integer division

**Lemma 3.3 (Run bound).** *If $s=(m,n)$ is admissible and $j<\lfloor (m-n)/(2n)\rfloor$, then $2jn+3n<m$.*

*Proof sketch.* The division inequality gives $(j+1)\cdot 2n \le m-n$, hence $(2j+3)n\le m$; equality is excluded by Lemma 1.1. $\square$

**Lemma 3.4 (Iterated translation).** *If $s=(m,n)$ is admissible and $j\le L:=\lfloor (m-n)/(2n)\rfloor$, then $\mathrm{par}^{j}(s) = (m-2jn,\,n)$.*

*Proof sketch.* Induction on $j$, using Lemma 3.3 to verify that at each intermediate stage the numerator still exceeds $3n$, so the $C$-branch applies. $\square$

**Theorem 3.5 (Exact leading run).** *For admissible $s=(m,n)$ put $L=\lfloor (m-n)/(2n)\rfloor$. Then $\ell_j(s)=C$ for all $j<L$, and $\ell_L(s)\neq C$. Thus the address of $s$ begins with exactly $L$ consecutive $C$'s.*

*Proof sketch.* The first claim is Lemmas 3.3–3.4. For the second, the division identity $2nL + \big((m-n)\bmod 2n\big) = m-n$ with $(m-n)\bmod 2n < 2n$ gives $m-2Ln < 3n$, so the letter of $\mathrm{par}^{L}(s)=(m-2Ln,n)$ is $A$ or $B$. $\square$

**Theorem 3.6 (Readable prefix).** *Let $s=(m,n)$ be admissible, $L=\lfloor (m-n)/(2n)\rfloor$. For every admissible $s'$ with $P_1(s)=P_1(s')$ we have $\ell_j(s)=\ell_j(s')$ for all $j\le L$. That is, the one-bit magnitude reading determines the entire leading $C$-run together with the inversion letter terminating it.*

*Proof sketch.* Combine Theorem 3.5 with Proposition 3.2 applied at each $j\le L$. $\square$

**Theorem 3.7 (The spine is readable to any depth).** *For every $L$, the pair $(2L+2,1)$ is admissible, its address begins with $L$ consecutive $C$'s, and every admissible $s'$ with the same one-bit reading agrees with it on letters $0,\dots,L$.*

*Proof sketch.* Admissibility is immediate ($n=1$, $m$ even); the run length is $\lfloor (2L+1)/2\rfloor = L$; apply Theorem 3.6. $\square$

Theorem 3.7 is the conceptual corrective to the phrase "depth decay": *depth per se is not the obstruction*. Along the translation spine the sensor reads arbitrarily deep. What kills the channel is the first inversion.

### 3.3 Depth is metered

**Theorem 3.8 (Price of depth).** *For admissible $s$, the readable run length satisfies*
$$L \;=\; \left\lfloor\frac{m-n}{2n}\right\rfloor \;\le\; \frac{P_1(s)}{4}.$$

*Proof sketch.* $L\cdot 2n \le m-n$ implies $4Ln \le 2m$ (using $n\le m$), hence $4L \le \lfloor 2m/n\rfloor$. $\square$

So depth is visible, but the sensor must *output* a number of size at least $4L$ to see depth $L$ — about $\log_2 L$ output bits. The channel is real, metered, and cheap only logarithmically.

---

## 4. The channel is null beyond the first inversion

### 4.1 The straddling construction

Fix a depth $k\ge 0$ and a scale $q$ with $6\mid q$ (in particular $6 \le q$). Define
$$
s^{+}_{q,k} = \big((7+6k)q + 1,\; 3q\big), \qquad
s^{-}_{q,k} = \big((7+6k)q - 1,\; 3q\big).
$$
Their ratios are
$$\frac{7}{3} + 2k \pm \frac{1}{3q}.$$

**Lemma 4.1 (Admissibility).** *For $6\le q$ with $2\mid q$ and $3\mid q$, and any $K \ge 7$, the pairs $(Kq+1,3q)$ and $(Kq-1,3q)$ are admissible.*

*Proof sketch.* Order and positivity are clear from $K\ge7$. Parity: $q$ is even, so $Kq$ is even and $Kq\pm1$ is odd while $3q$ is even, giving $m+n$ odd. Coprimality: a common divisor $g$ of $Kq\pm1$ and $3q$ divides $3(Kq\pm1) \mp$ (multiple of $3q$) $= \pm 3$, so $g\in\{1,3\}$; but $3\mid Kq$ (as $3\mid q$), so $3\nmid Kq\pm1$, forcing $g=1$. $\square$

Applying this with $K=7+6k$ gives admissibility of both straddling states.

### 4.2 The sensor cannot separate them

**Theorem 4.2 (Probe collision).** *If $0<q$ and $2^{W}<q$, then*
$$P_W\big(s^{+}_{q,k}\big) = P_W\big(s^{-}_{q,k}\big).$$

*Proof sketch.* Write $M=2^{W}$, $K=7+6k$, and divide $MK$ by $3$: $MK=3t+\rho$ with $\rho \in \{1,2\}$ — crucially $\rho \ne 0$, because $3 \nmid 2^{W}$ and $K \equiv 1 \pmod 3$. Then
$$M(Kq \pm 1) = 3q\,t + (\rho q \pm M).$$
The hypothesis $M<q\le \rho q$ gives $0 \le \rho q - M$ and $\rho q + M < 3q$ (using $\rho \le 2$), so in both cases the remainder term lies in $[0,3q)$ and both quotients by $3q$ equal $t$. $\square$

The arithmetic heart is $\rho \ne 0$: the sensor's grid $\{j/2^{W}\}$ never contains the boundary $7/3+2k$, because $7/3$ is **not a dyadic rational**. The two ratios lie strictly on either side of the boundary but within one grid cell, so no binary truncation separates them.

### 4.3 The common prefix and the divergence

**Lemma 4.3 (Translation prefix).** *For $q>0$ and $m$ with $9q + 6jq < m + 6q$, one has $\mathrm{par}^{j}(m,3q) = (m-6jq,\,3q)$. Consequently, if $9q+6jq<m$ then $\ell_j(m,3q)=C$.*

*Proof sketch.* Induction: the hypothesis guarantees the numerator exceeds $3\cdot(3q)=9q$ at each stage, so the $C$-branch applies and subtracts $6q$. $\square$

**Lemma 4.4 (Both states reach the same inversion).** *For $q\ge 6$ and all $j<k$, $\ell_j(s^{\pm}_{q,k})=C$; moreover*
$$\mathrm{par}^{k}\big(s^{+}_{q,k}\big) = (7q+1,\,3q), \qquad \mathrm{par}^{k}\big(s^{-}_{q,k}\big) = (7q-1,\,3q),$$
*and $\ell_k(s^{+}_{q,k}) = \ell_k(s^{-}_{q,k}) = B$, since $6q < 7q\pm 1 < 9q$.*

**Theorem 4.5 (Divergence one step later).** *For $q \ge 6$,*
$$\ell_{k+1}\big(s^{+}_{q,k}\big) = B, \qquad \ell_{k+1}\big(s^{-}_{q,k}\big) = C.$$

*Proof sketch.* From $(7q\pm1,\,3q)$ the $B$-branch gives $\mathrm{par}(7q+1,3q)=(3q,\,q+1)$ and $\mathrm{par}(7q-1,3q)=(3q,\,q-1)$. Now compare $3q$ against the cut points: $2(q+1) \le 3q < 3(q+1)$ gives letter $B$; while $3q \ge 3(q-1)$ gives letter $C$. The inversion has taken a hairline difference around $7/3$ and thrown the images to opposite sides of $3$. $\square$

### 4.4 The main negative theorems

**Theorem 4.6 (Depth null).** *For every window budget $W$ and every depth $k$ there exist admissible $s,s'$ with*
1. $P_W(s) = P_W(s')$,
2. $\ell_j(s) = \ell_j(s')$ for all $j\le k$ (the common prefix $C^{k}B$),
3. $\ell_{k+1}(s) \neq \ell_{k+1}(s')$.

*Proof sketch.* Take $q = 6\cdot 2^{W}$, so $6\mid q$ and $2^{W}<q$, and set $s=s^{+}_{q,k}$, $s'=s^{-}_{q,k}$. Apply Lemma 4.1, Theorem 4.2, Lemma 4.4 and Theorem 4.5. $\square$

**Theorem 4.7 (Non-measurability).** *For every $W$ and every $k$ there is no function $f:\mathbb{N}\to\Sigma$ with $\ell_{k+1}(s) = f(P_W(s))$ for all admissible $s$.*

*Proof.* Immediate from Theorem 4.6: the two states have equal readings and unequal letters. $\square$

**Theorem 4.8 (Unbounded counterexamples).** *For every $W$, $k$ and every size bound $N$, the colliding pair of Theorem 4.6 can be chosen with both denominators exceeding $N$.*

*Proof sketch.* Take $q = 6\cdot 2^{W}\cdot (N+1)$; then $6 \mid q$, $2^{W}<q$, and the common denominator $3q$ exceeds $N$. $\square$

Thus the failure is not a small-state artefact; it recurs at every scale.

**Theorem 4.9 (Sharp threshold).** *Depth one is readable and depth two is null:*
1. *for all admissible $s,s'$ with $P_1(s)=P_1(s')$, $\ell_0(s)=\ell_0(s')$;*
2. *for every $W$ there are admissible $s,s'$ with $P_W(s)=P_W(s')$, $\ell_0(s)=\ell_0(s')$, and $\ell_1(s)\ne\ell_1(s')$.*

*Proof.* (1) is Corollary 2.3; (2) is Theorem 4.6 with $k=0$. $\square$

Together with Theorem 3.6 this pins the reach exactly:

> **The magnitude channel reads the leading $C$-run and the inversion letter that terminates it, and nothing beyond.**

---

## 5. No rescaling helps: the universal null

The dyadic argument above exploited the non-dyadicity of $7/3$. It is natural to hope that a base-$3$ sensor, which resolves $7/3$ exactly, sees further. It does not, and the reason is a different and stronger mechanism: **attained boundaries plus right-continuity of the floor function**.

**Definition 5.1.** For $k\ge0$ set
$$
T_k = (4k+5,\;2), \qquad U_{k,u} = \big((4k+5)u + 1,\; 2u\big) \ \ (u \text{ even}, \ u \ge 2).
$$
The ratio of $T_k$ is exactly $\tfrac52 + 2k$; the ratio of $U_{k,u}$ is a whisker above it.

**Lemma 5.2.** *$T_k$ and $U_{k,u}$ are admissible for even $u\ge2$.*

*Proof sketch.* $4k+5$ is odd and coprime to $2$; for $U_{k,u}$, the numerator is odd (as $u$ is even) and any common divisor of $(4k+5)u+1$ and $2u$ divides $2$, hence is $1$ by oddness. $\square$

**Lemma 5.3 (Both have leading run $k$).** *The leading $C$-run of both $T_k$ and $U_{k,u}$ has length exactly $k$, and*
$$\mathrm{par}^{k}(T_k) = (5,2), \qquad \mathrm{par}^{k}(U_{k,u}) = (5u+1,\,2u).$$
*Both take letter $B$ at position $k$.*

*Proof sketch.* Apply Theorem 3.5 and Lemma 3.4 after computing $\lfloor(4k+3)/4\rfloor=k$ and $\lfloor((4k+5)u+1-2u)/(4u)\rfloor=k$. $\square$

**Lemma 5.4 (Divergence).** *$\ell_{k+1}(T_k)=B$ while $\ell_{k+1}(U_{k,u})=A$.*

*Proof sketch.* $\mathrm{par}(5,2)=(2,1)$, the root, whose letter is $B$ (indeed $2\cdot1 \le 2 < 3\cdot 1$ gives $B$ under our convention). By contrast $\mathrm{par}(5u+1,2u)=(2u,\,u+1)$, and $2u < 2(u+1)$, so the letter is $A$: the inversion has pushed the ratio *below* $2$. $\square$

**Theorem 5.5 (Right-continuity collision).** *For all positive integers $a,b$ and any even $u > a$,*
$$G_{a,b}(T_k) = G_{a,b}(U_{k,u}).$$

*Proof sketch.* Put $D=2b$, $A=a(4k+5)$, and write $A=DI+p$ with $0\le p<D$. Then $G_{a,b}(T_k)=\lfloor A/D\rfloor=I$, while
$$a\big((4k+5)u+1\big) = (Du)\,I + (pu + a),$$
and $pu+a < (p+1)u \le Du$ because $a<u$ and $p+1 \le D$. Hence the second quotient is also $I$. $\square$

**Theorem 5.6 (Universal depth null).** *For all positive integers $a,b$ and every depth $k$ there are admissible $s,s'$ with $G_{a,b}(s)=G_{a,b}(s')$, $\ell_j(s)=\ell_j(s')$ for all $j\le k$, and $\ell_{k+1}(s)\ne\ell_{k+1}(s')$. Consequently the depth-$(k+1)$ letter is not a function of $G_{a,b}$.*

*Proof.* Take $s=T_k$, $s'=U_{k,2a+2}$ and combine Lemmas 5.2–5.4 with Theorem 5.5. $\square$

Since $G_{2^{W},1}=P_W$, Theorem 5.6 subsumes Theorem 4.6. The conceptual content is worth isolating: the deeper branch boundary $\tfrac52+2k$ is *attained* by an admissible state, and a truncation sensor assigns a point and its immediate right neighbours the same value no matter what the scale. **No monotone rational rescaling of the magnitude can resolve an attained boundary.** Improving the ruler is the wrong move; the sensor class itself is inadequate.

---

## 6. Capacity: the decay is information-theoretic

The two negative theorems above exhibit explicit adversarial pairs. A skeptic might suspect these are engineered pathologies of measure zero. The following independent argument removes that objection: the obstruction is a *capacity* bound.

### 6.1 Every word is realized

**Definition 6.1.** For $w=x_1x_2\cdots x_k \in \Sigma^{*}$, define $\mathrm{build}(\varepsilon)=(2,1)$ and $\mathrm{build}(x\cdot w) = \mathsf{X}(\mathrm{build}(w))$, where $\mathsf{X}\in\{\mathsf A,\mathsf B,\mathsf C\}$ is the child map of $x$.

**Lemma 6.2 (Children are tagged sections).** *For admissible $s$ and any letter $x$: (i) $\mathsf{X}(s)$ is admissible; (ii) $\mathrm{letter}(\mathsf{X}(s)) = x$; (iii) $\mathrm{par}(\mathsf{X}(s)) = s$.*

*Proof sketch.* (i) Coprimality and parity are preserved by each map by explicit linear combinations. (ii) For $\mathsf{A}$: $2m-n<2m$ gives $A$. For $\mathsf{B}$: $2m \le 2m+n < 3m$ (using $n<m$) gives $B$. For $\mathsf{C}$: $m+2n \ge 3n$ with strictness from $m>n$ gives $C$. (iii) Direct computation in each case. $\square$

**Theorem 6.3 (Path realization).** *For every word $w$ of length $k$ and every $j<k$, $\ell_j(\mathrm{build}(w)) = w_j$. In particular all $3^{k}$ depth-$k$ behaviours occur among admissible states.*

*Proof sketch.* Induction on $w$ using Lemma 6.2(ii) for $j=0$ and Lemma 6.2(iii) plus $\ell_{j+1}(s)=\ell_j(\mathrm{par}(s))$ for the step. $\square$

### 6.2 The bounded stratum and the pigeonhole

**Lemma 6.4 (Ratio bound on the $\{A,B\}$-stratum).** *If every letter of $w$ lies in $\{A,B\}$, then $\mathrm{build}(w)=(m,n)$ satisfies $n < m < 3n$.*

*Proof sketch.* Induction: the root satisfies $1<2<3$; the maps $\mathsf{A},\mathsf{B}$ send $(m,n)$ with $n<m$ to $(2m\mp n,\,m)$ whose ratio is $2 \mp n/m \in (1,3)$. $\square$

**Lemma 6.5 (Bounded reading).** *On that stratum, $P_W(\mathrm{build}(w)) \in [2^{W},\,3\cdot 2^{W})$, a set of $2\cdot2^{W}$ values.*

**Theorem 6.6 (Capacity bound).** *If $2\cdot 2^{W} < 2^{k}$, there are admissible states $s\ne s'$ with $P_W(s)=P_W(s')$ and $\ell_j(s)\ne\ell_j(s')$ for some $j<k$.*

*Proof sketch.* Map each $v\in\{0,1\}^{k}$ to the word over $\{A,B\}$ it encodes and then to $\mathrm{build}$ of that word. There are $2^{k}$ such states, all with readings in a set of size $2\cdot 2^{W}$; by pigeonhole two distinct $v \ne v'$ collide. By Theorem 6.3 the two states' letters differ at the first index where $v$ and $v'$ differ. $\square$

Two bits of depth beyond the sensor's budget already destroy injectivity. This is the theorem behind the empirically observed halving of mutual information every couple of levels: a channel with $O(2^{W})$ output symbols cannot transmit $k$ ternary letters when $3^{k}$ (or even $2^k$) exceeds its alphabet.

---

## 7. Algorithms

The proofs are constructive and yield four short procedures.

**Algorithm A (Descent / address extraction).** Given admissible $(m,n)$, repeatedly compare $m$ against $2n$ and $3n$, emit the letter, and replace $(m,n)$ by the corresponding parent, halting at $(2,1)$. Because each $A$/$B$ step performs $m \bmod 2n$-like reduction and each maximal $C$-run of length $L$ can be executed in one division ($m \leftarrow m-2Ln$), the algorithm runs in $O(\log \max(m,n))$ divisions — it *is* the Euclidean algorithm in disguise. This is the cost the sensor was meant to avoid.

**Algorithm B (Window read).** Given $(m,n)$ and a budget $W$, output $P_W(m,n) = \lfloor 2^{W}m/n\rfloor$, then the predicted prefix: run length $L=\lfloor (m-n)/(2n)\rfloor$ (one division), predicted letters $C^{L}$, and the terminating letter obtained by classifying $m-2Ln$ against $2n$. Cost: two divisions, independent of depth. Guaranteed correct on positions $0,\dots,L$ by Theorem 3.6; guaranteed *not* determined at position $L+1$ by Theorem 4.6.

**Algorithm C (Adversary generator).** Given $W$ and $k$, output $\big((7+6k)q+1,\,3q\big)$ and $\big((7+6k)q-1,\,3q\big)$ with $q=6\cdot2^{W}$ (or $q=6\cdot2^{W}(N+1)$ for denominators above $N$). Cost $O(1)$ arithmetic operations; certified colliding pair by Theorems 4.2–4.5. The rational-scale variant outputs $(4k+5,2)$ and $\big((4k+5)u+1,\,2u\big)$ with $u=2a+2$.

**Algorithm D (Capacity collision search).** Given $W$ and $k$ with $2\cdot2^{W}<2^{k}$, enumerate the $2^{k}$ states built from $\{A,B\}$-words of length $k$, bucket them by their $W$-window reading, and return any bucket with two members. Cost $O(2^{k})$ states, each built in $O(k)$ arithmetic steps; success guaranteed by Theorem 6.6.

---

## 8. Discussion: what this says about factoring shortcuts

The Berggren tree has repeatedly been proposed as a source of structure that might yield a shortcut to integer factorization, on the grounds that a target $N$ determines a location in the tree whose address encodes arithmetic information about $N$. Any such attack requires a *cheap, $N$-computable* readout of the address. The natural family of cheap readouts is exactly the fixed-window magnitude sensors studied here.

The results close this route quantitatively and in three independent registers.

**(1) The channel exists.** Theorem 2.2 and Theorem 3.6 show that a one-bit reading determines a genuine, sometimes long, prefix of the address. This is a real leak, and it must be measured rather than waved away.

**(2) The channel is metered above breakeven.** Theorem 3.8 shows that reading a run of length $L$ requires the sensor to output a value of size $\ge 4L$: about $\log_2 L$ bits. Combined with the observed effective advantage — an exponent factor at best around $0.85$ relative to a direct exact search — the readout does not pay for itself.

**(3) The channel is depth-limited, provably.** Theorem 4.6, Theorem 4.8, Theorem 5.6 and Theorem 6.6 show that no fixed budget, no rational rescaling, and no favourable choice of state size recovers a single letter past the first inversion; and the capacity form shows the limitation is entropic rather than adversarial. The empirical decay — significant at the second letter, marginal at the third, edge at the fourth, null at the fifth — is exactly the signature these theorems predict for a population whose addresses contain their first inversion early.

The unifying mechanism can be stated in one line. **The descent letters are Gauss-map digits of the ratio. A fixed $W$-bit window resolves the ratio to $O(2^{-W})$, which is precisely enough for the coarse digits and never enough for the fine ones. The first two or three letters are those coarse digits; the deeper letters are finer digits, and no fixed-budget window sees a finer digit.** Recovering the full address requires the full Euclidean descent, which is the very computation an attack sought to avoid. The tree remains sealed in practice.

---

## 9. Future directions

Two structural patterns drive the natural next questions.

### 9.1 A dyadic-boundary criterion for readability

The evidence is that a letter is readable by *some* fixed-precision truncation sensor exactly when the branch boundary separating its two alternatives is a dyadic rational. The depth-$1$ boundaries are $\{2,3\}$; the boundary $2$ is dyadic, hence always resolvable. The depth-$t$ boundaries are the Möbius pullbacks of $\{2,3\}$ along the first $t-1$ letters. Along the $C$-spine these pullbacks are translates $2+2j$, $3+2j$ — dyadic, hence still resolvable, which is exactly Theorem 3.7. Along any path containing an inversion they are non-dyadic rationals such as $7/3$ and $5/2$, hence never resolvable, which is exactly Theorem 4.6. Both halves are already in place; what remains is the general pullback computation and the resulting clean criterion:

> **Conjecture.** The letter at position $t$ is a function of some $P_W$ restricted to a stratum if and only if every depth-$t$ boundary reachable within that stratum is dyadic.

### 9.2 Euclidean-step hierarchy

One tempting refinement was refuted within this work: "a base-$3$ window sees deeper than a base-$2$ window" is false, because Theorem 5.6 shows that every rational-scale truncation fails at the very first letter past the inversion — the boundary $\tfrac52+2k$ is *attained*, and truncation is right-continuous.

So the surviving question concerns a different sensor class. What a sensor really needs is not finer scaling but **Euclidean steps**: the pair $\big(\lfloor m/n\rfloor,\; m \bmod n\big)$ is one step of the Euclidean algorithm and already determines strictly more letters than any single truncation, precisely because it resolves attained boundaries. The universal null identifies the exact failure mode, and a $t$-step Euclidean sensor is exactly the object that repairs it. This makes the following the sharp question:

> **Conjecture.** A $t$-step Euclidean sensor reads $\Theta(t)$ letters of the address, and no sensor of comparable cost reads more. Equivalently, address extraction is Euclidean-complete: reading $k$ letters costs $\Theta(k)$ Euclidean steps.

If this hierarchy holds, the conclusion is a clean complexity statement: the tree's structure is not hidden behind numerical precision at all, but behind the Euclidean algorithm — which is to say, behind exactly the work a shortcut was trying to skip.

### 9.3 Other directions

- **Beyond truncation.** Characterize the full class of *depth-null* functionals: which computable functions of $(m,n)$ with bounded output determine no letter past the first inversion? The capacity argument suggests a general theorem for any functional with $O(\mathrm{poly}(W))$ output range on the bounded stratum.
- **Randomized and noisy sensors.** Quantify the channel capacity in bits as a function of $W$, and compare against the measured mutual-information decay curve.
- **Other Möbius trees.** The same analysis applies verbatim to any ternary (or $d$-ary) tree generated by integer Möbius maps with a mixture of translations and inversions. The prediction is that readability always extends exactly along the maximal translation prefix.

---

## 10. Conclusion

For the Berggren tree of primitive Pythagorean triples in $(m,n)$ coordinates, the reach of a fixed-precision magnitude sensor is now known exactly. Positively: the first descent letter is a function of a single one-bit reading; the entire leading translation run, of length $\lfloor (m-n)/(2n)\rfloor$, together with the inversion letter terminating it, is determined by that same reading; and along the pure-translation spine arbitrarily many letters are legible. Negatively: for every window budget and every depth there are admissible pairs with identical readings, identical prefixes $C^{k}B$, and different letters one step later, with the colliding pairs available at arbitrarily large scale; the same holds for every rational rescaling of the magnitude, because the deeper boundaries are attained and truncation is right-continuous; and a pigeonhole capacity bound forces collisions as soon as the depth exceeds the budget by two bits. The threshold is sharp — depth one always readable, depth two always null.

Depth decay, properly understood, is inversion decay. The magnitude channel sees only the first steps.
