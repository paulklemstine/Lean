# The Retention Knee of Attention Profiles: Additive Delay, Multiplicative Decay Tax, and the Gauge Freedom of the Master Knee

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We develop a rigorous theory of the *retention knee* of a discrete attention profile: for a nonnegative weight sequence $w = (w_i)_{i\ge 0}$ and a gate $\tau$, the knee $k^*(w,\tau)$ is the least number of leading positions whose cumulative mass reaches $\tau$. The motivation is an empirical five-domain table measured at a fixed context length and gate — code $12$, English prose $20$, mathematics $20$, German prose $24$, French prose $40$ — and the resulting dispute over whether the cross-domain "tokenizer tax" is an additive step ($+4$) or a multiplicative factor ($\times 2$).

We prove that the two candidate mechanisms are structurally distinct phenomena, not reparametrisations of one another. A *delay* by $d$ inert positions shifts the knee by exactly $+d$ at every positive gate. An $m$-th *root of the decay ratio* multiplies the knee by $m$ up to a ceiling: if the fine profile has geometric knee $B$, the coarse one has knee $\lceil B/m\rceil$, with equality $B = mA$ precisely when $m \mid B$. For a genuine root tax with $m \ge 2$, the gap between the two knees is unbounded as the gate tightens, so no fixed additive constant can describe it.

We then sharpen the multiplicative law to a two-sided integer bound, $B \le mA < B+m$, and deduce that an English knee of $20$ under a square-root tax forces a French knee in $\{39,40\}$ — the reported value $40$ is correct up to one position, and is singled out only by a parity assumption that a coarse measurement grid cannot verify.

Finally we study whether one *master* profile can generate the whole table under integer tax exponents. It can, in more than one way. The master knee $120$ works with exponents $(10,6,6,5,3)$ and is minimal among masters dividing every entry exactly; but exact divisibility is not required by the ceiling law, and the master knee $118$ reproduces the same table with the same exponents. An exhaustive finite search shows no master below $118$ suffices, and a complete interval analysis shows the admissible masters for the exponent vector $(10,6,5,3)$ are exactly $\{118,119,120\}$. Consequently the five-domain fingerprint does not determine the master profile: $118$ and $120$ are observationally indistinguishable on this data. We also prove a rigidity theorem — exact multiplicativity at *all* gates forces the taxed retention curve to be a block dilation of the untaxed one, with no geometric hypothesis — and a tail-class separation theorem showing heavy-tailed profiles outgrow every geometric profile by an unbounded factor.

**Keywords:** retention knee, attention profile, geometric tail, ceiling division, tokenizer tax, multiplicative rigidity, tail-class dichotomy.

---

## 1. Introduction

### 1.1 The measurement

Consider any system that must decide, position by position, how much of a long context to consult. Its attention weights over the context, sorted in decreasing order, form a probability profile. The practical question — *how many positions must be kept to preserve a prescribed fraction of the attention mass?* — has a single-number answer, the **knee**, and that number turns out to depend systematically on the domain being read.

At a fixed context length of $1024$ positions and a fixed gate, the following table has been measured:

| domain | code | English prose | mathematics | German prose | French prose |
|---|---|---|---|---|---|
| $k^*$ | $12$ | $20$ | $20$ | $24$ | $40$ |

Two features of this table demand explanation. German exceeds English by exactly $+4$. French exceeds English by exactly $\times 2$. These are different kinds of statement, and if both are instances of a single "tokenizer tax", that tax is not a single mechanism.

The French entry is the hard-won one. On an extended grid at gate $0.98$ the measured retained masses were

| $k$ | $36$ | $40$ | $48$ | $56$ | $64$ |
|---|---|---|---|---|---|
| retained | $0.9795$ | $0.9830$ | $0.9855$ | $0.9896$ | $0.9916$ |

so $k=36$ fails the gate and $k=40$ passes it. Two pre-registered hypotheses were in play: that a knee exists within the extended grid (confirmed), and that it lies near $28$–$32$ (refuted). The reported knee is $40$.

### 1.2 What this paper does

We formalise the knee and prove what can, and cannot, be inferred from data of this shape. Section 2 sets up profiles, retention and the knee, and records their basic calculus. Section 3 proves the additive law for delays. Section 4 solves the geometric knee in closed form, proves the root law and its exactness criterion, and gives the sharp two-sided bound. Section 5 applies these to the French entry. Section 6 analyses the master-knee reconstruction and establishes its exact gauge freedom. Section 7 proves multiplicative rigidity. Section 8 proves the tail-class separation. Section 9 discusses measurement grids. Sections 10–11 discuss consequences and open directions.

Throughout, all statements are exact; no asymptotic or statistical approximation is used anywhere. Every constant appearing in a theorem is the true constant.

---

## 2. Profiles, retention and the knee

### 2.1 Definitions

**Definition 2.1 (Profile).** A *profile* is a function $w : \mathbb{N} \to \mathbb{R}$. It is *nonnegative* if $w_i \ge 0$ for all $i$, and *strictly positive* if $w_i > 0$ for all $i$. We do not require monotonicity or normalisation except where stated; in applications $w$ is the decreasing rearrangement of an attention row and sums to $1$.

**Definition 2.2 (Retained mass).** The *retained mass* of the first $k$ positions is
$$R_w(k) = \sum_{i < k} w_i, \qquad R_w(0) = 0, \qquad R_w(k+1) = R_w(k) + w_k .$$

**Definition 2.3 (Knee).** For a gate $\tau \in \mathbb{R}$, the *knee* is
$$k^*(w,\tau) = \inf\{\, k \in \mathbb{N} : \tau \le R_w(k) \,\},$$
with the convention that the infimum of the empty set is $0$. Every result below either assumes the gate is reachable or derives reachability.

**Definition 2.4 (Delay).** For $d \in \mathbb{N}$, the profile $w$ *delayed by* $d$ is
$$(\mathrm{delay}_d\,w)_i = \begin{cases} 0, & i < d,\\ w_{i-d}, & i \ge d.\end{cases}$$

**Definition 2.5 (Geometric profile).** For $r \in [0,1)$, the *geometric profile with ratio $r$* is $\mathrm{geom}(r)_i = (1-r)r^i$.

**Definition 2.6 (Heavy profile).** The *heavy* (telescoping) profile is $\mathrm{heavy}_i = \dfrac{1}{(i+1)(i+2)}$.

### 2.2 Basic calculus

**Proposition 2.7 (Monotonicity).** If $w$ is nonnegative then $R_w$ is monotone nondecreasing.

*Proof.* For $a \le b$, $R_w(b) - R_w(a)$ is a sum of nonnegative terms. $\square$

**Proposition 2.8 (Knee specification).** If the gate set $\{k : \tau \le R_w(k)\}$ is nonempty then $\tau \le R_w(k^*(w,\tau))$, and $\tau > R_w(j)$ for every $j < k^*(w,\tau)$.

*Proof.* The first claim is membership of an infimum of a nonempty subset of $\mathbb{N}$ in that subset; the second is minimality. $\square$

**Proposition 2.9 (Characterisation).** If $\tau \le R_w(n)$ and $\tau > R_w(j)$ for all $j < n$, then $k^*(w,\tau) = n$.

*Proof.* The first hypothesis gives $k^* \le n$; if $k^* < n$ then $\tau \le R_w(k^*)$ contradicts the second hypothesis at $j = k^*$. $\square$

**Proposition 2.10 (Persistence).** For nonnegative $w$ with reachable gate, $\tau \le R_w(k)$ for every $k \ge k^*(w,\tau)$.

*Proof.* Combine Propositions 2.7 and 2.8. $\square$

**Proposition 2.11 (Domination).** If $R_w(k) \le R_v(k)$ for all $k$ and the gate is reachable for $w$, then $k^*(v,\tau) \le k^*(w,\tau)$. A heavier head means an earlier knee.

*Proof.* $\tau \le R_w(k^*(w,\tau)) \le R_v(k^*(w,\tau))$, so $k^*(w,\tau)$ lies in $v$'s gate set. $\square$

**Proposition 2.12 (Self-calibration).** If $w$ is strictly positive then $R_w$ is strictly increasing and $k^*(w, R_w(k)) = k$ for every $k$.

*Proof.* Strict monotonicity follows from $R_w(k+1) - R_w(k) = w_k > 0$; then Proposition 2.9 applies with $n=k$. $\square$

**Proposition 2.13 (Density lower bound).** If $w_i \le p$ for all $i$ with $p>0$ and the gate is reachable, then $\tau/p \le k^*(w,\tau)$.

*Proof.* $\tau \le R_w(k^*) \le k^* p$. $\square$

---

## 3. The additive law: delays

**Lemma 3.1.** $R_{\mathrm{delay}_d w}(d+k) = R_w(k)$ for all $k$, and $R_{\mathrm{delay}_d w}(k) = 0$ for $k \le d$.

*Proof.* The second statement is immediate since all terms vanish. The first is induction on $k$: the base case is the second statement at $k=d$, and the step adds $(\mathrm{delay}_d w)_{d+n} = w_n$ to both sides. $\square$

**Theorem 3.2 (Additive tokenizer tax).** Let $\tau > 0$ and suppose $w$'s gate set is nonempty. Then
$$k^*(\mathrm{delay}_d\,w,\ \tau) \;=\; d + k^*(w,\tau).$$

*Proof.* By Lemma 3.1, $R_{\mathrm{delay}_d w}(d + k^*(w,\tau)) = R_w(k^*(w,\tau)) \ge \tau$. For $j < d + k^*(w,\tau)$: if $j \le d$ then $R_{\mathrm{delay}_d w}(j) = 0 < \tau$; otherwise $j = d+t$ with $t < k^*(w,\tau)$ and $R_{\mathrm{delay}_d w}(j) = R_w(t) < \tau$. Apply Proposition 2.9. $\square$

The shift is *exact* and *gate-independent*: it is the same $d$ for every $\tau > 0$. This is the precise content of a "$+4$" law.

---

## 4. The multiplicative law: geometric tails

### 4.1 The geometric knee

**Lemma 4.1.** $R_{\mathrm{geom}(r)}(k) = 1 - r^k$.

*Proof.* Induction: $R(k+1) = (1-r^k) + (1-r)r^k = 1 - r^{k+1}$. $\square$

It is therefore natural to reparametrise the gate by the **tail budget** $t = 1-\tau$ and define

**Definition 4.2 (Geometric knee).** $k_{\mathrm{geom}}(r,t) = \inf\{k : r^k \le t\}$.

**Lemma 4.3.** For $r<1$ and $t>0$ the set $\{k : r^k \le t\}$ is nonempty, and for $0 \le r < 1$, $t > 0$,
$$k_{\mathrm{geom}}(r,t) \le n \iff r^n \le t .$$

*Proof.* Nonemptiness is the fact that $r^n \to 0$. For the equivalence: if $k_{\mathrm{geom}} \le n$ then $r^n \le r^{k_{\mathrm{geom}}} \le t$ by antitonicity of $n \mapsto r^n$; conversely $r^n \le t$ puts $n$ in the set. $\square$

**Proposition 4.4 (Gate translation).** $k^*(\mathrm{geom}(r),\tau) = k_{\mathrm{geom}}(r, 1-\tau)$.

*Proof.* By Lemma 4.1, $\tau \le R(k) \iff r^k \le 1-\tau$; the two gate sets coincide. $\square$

**Proposition 4.5 (Calibration).** For $0<r<1$, $k_{\mathrm{geom}}(r, r^n) = n$.

*Proof.* $\le$ is Lemma 4.3 with $n$. If $k_{\mathrm{geom}} < n$ then $r^{n-1} \le r^n$, contradicting $r<1$. $\square$

**Theorem 4.6 (Closed form).** For $0<r<1$ and $t>0$,
$$k_{\mathrm{geom}}(r,t) = \left\lceil \frac{\log t}{\log r} \right\rceil_{+},$$
the nonnegative ceiling.

*Proof.* Since $\log r < 0$, $r^k \le t \iff k\log r \le \log t \iff \log t/\log r \le k$. So the gate set is the set of naturals above $\log t/\log r$, whose least element is the ceiling. $\square$

**Definition 4.7 (Ideal knee).** $\kappa(r,t) = \dfrac{\log t}{\log r}$.

**Proposition 4.8 (One-position accuracy).** For $0<r<1$ and $0 < t \le 1$,
$$\kappa(r,t) \le k_{\mathrm{geom}}(r,t) < \kappa(r,t) + 1, \qquad \kappa(r,t) \ge 0 .$$

*Proof.* Immediate from Theorem 4.6 and $x \le \lceil x\rceil < x+1$; nonnegativity from $\log t \le 0$, $\log r<0$. $\square$

### 4.2 The root law

**Theorem 4.9 (Root-of-ratio law).** Let $0 \le r < 1$, $t>0$, $m \ge 1$. Then
$$k_{\mathrm{geom}}(r^m, t) \;=\; \left\lceil \frac{k_{\mathrm{geom}}(r,t)}{m} \right\rceil .$$

*Proof.* For every $n$, by Lemma 4.3 applied twice and $(r^m)^n = r^{mn}$,
$$k_{\mathrm{geom}}(r^m,t) \le n \iff r^{mn}\le t \iff k_{\mathrm{geom}}(r,t) \le mn \iff \left\lceil \tfrac{k_{\mathrm{geom}}(r,t)}{m}\right\rceil \le n,$$
the last step being the defining adjunction of ceiling division. Two naturals with the same down-set are equal. $\square$

**Theorem 4.10 (Exactness criterion).** Under the hypotheses of Theorem 4.9, writing $B = k_{\mathrm{geom}}(r,t)$ and $A = k_{\mathrm{geom}}(r^m,t)$:
$$B = mA \iff m \mid B .$$

*Proof.* ($\Rightarrow$) trivial. ($\Leftarrow$) if $B = mc$, then $\lceil B/m\rceil = c$ and $mA = mc = B$. $\square$

**Proposition 4.11 (Ceiling interval form).** For $m \ge 1$ and $v \ge 1$,
$$\left\lceil \frac{B}{m}\right\rceil = v \iff m(v-1) < B \le mv .$$

*Proof.* $\lceil B/m\rceil \le v \iff B \le mv$, and $\lceil B/m\rceil \le v-1 \iff B \le m(v-1)$; subtract. $\square$

**Theorem 4.12 (Sharp two-sided bound).** Let $0 \le r<1$, $t>0$, $m \ge 1$, $B = k_{\mathrm{geom}}(r,t)$, $A = k_{\mathrm{geom}}(r^m,t)$. Then
$$B \;\le\; mA \;<\; B+m .$$
The multiplicative law holds with an error strictly smaller than the multiplier.

*Proof.* By Theorem 4.9, $A = \lceil B/m\rceil$. If $A=0$ then $B \le 0$ and both inequalities hold. Otherwise write $A = a+1$ with $a \ge 0$; Proposition 4.11 with $v=A$ gives $mA - m = ma < B \le mA$. $\square$

**Corollary 4.13 (Exact multiplicativity of the ideal knee).** $\kappa(r^m,t) = \kappa(r,t)/m$.

*Proof.* $\log(r^m) = m\log r$. $\square$

**Theorem 4.14 (Gate invariance of the tax ratio).** For $0<r_1,r_2<1$ and $0<t<1$,
$$\frac{\kappa(r_1,t)}{\kappa(r_2,t)} = \frac{\log r_2}{\log r_1},$$
independently of the gate $t$.

*Proof.* $\dfrac{\log t/\log r_1}{\log t/\log r_2} = \dfrac{\log r_2}{\log r_1}$, valid since $\log t \ne 0$ and $\log r_i \ne 0$. $\square$

This is the paper's most directly falsifiable prediction: the *ratio* of two domains' knees is a pure tail invariant, so it must be reproduced at every gate, and the only gate dependence is the sub-unit rounding error of Proposition 4.8.

### 4.3 No additive surrogate

**Theorem 4.15 (Unbounded root gap).** Let $0<r<1$, $m \ge 2$ and $N \in \mathbb{N}$. Then there exists $t>0$ with
$$N + k_{\mathrm{geom}}(r^m, t) \;\le\; k_{\mathrm{geom}}(r,t).$$

*Proof.* Take $t = r^{mN+m}$. By Proposition 4.5, $k_{\mathrm{geom}}(r,t) = mN+m$; by Theorem 4.9 and $m \mid mN+m$, $k_{\mathrm{geom}}(r^m,t) = N+1$. Since $m \ge 2$, $N + (N+1) \le mN+m$. $\square$

**Corollary 4.16 (A delay is not a root).** For $0<r<1$, $m \ge 2$ and any fixed $d$, there is a gate $t>0$ with $k_{\mathrm{geom}}(r,t) \ne d + k_{\mathrm{geom}}(r^m,t)$.

*Proof.* Apply Theorem 4.15 with $N = d+1$. $\square$

Thus a "$+4$" law and a "$\times 2$" law cannot both be manifestations of one mechanism: no additive constant reproduces a root tax across gates.

---

## 5. The French entry

**Theorem 5.1 (Structural form of the verdict).** Suppose the French profile is geometric with ratio $r$ and the English profile is geometric with ratio $r^2$ (i.e. French pays a square-root decay tax). If the English knee is $20$ and the French knee is even, then the French knee is exactly $40$.

*Proof.* Theorem 4.10 with $m=2$: evenness of $B$ gives $B = 2A = 40$. $\square$

**Theorem 5.2 (The French knee is $39$ or $40$).** Under the same hypotheses but *without* the parity assumption, the French knee lies in $\{39,40\}$.

*Proof.* Theorem 4.12 with $m=2$, $A=20$: $B \le 40 < B+2$, so $38 < B \le 40$ and $B \in \{39,40\}$. $\square$

The parity hypothesis of Theorem 5.1 is exactly the single bit that removes $39$. It is not observable on the reported grid $\{36,40,48,56,64\}$, which never tests $39$. The honest content of the measurement is Theorem 5.2 plus a bracketing statement:

**Theorem 5.3 (Bracketing from the reported data).** Let $w$ be nonnegative with $R_w(36) = 0.9795$ and $R_w(40) = 0.9830$. Then at gate $0.98$,
$$36 < k^*(w, 0.98) \le 40 .$$

*Proof.* $0.9795 < 0.98 \le 0.9830$; apply the general bracket of Theorem 9.2 below. $\square$

---

## 6. The master knee and its gauge freedom

### 6.1 Reconstruction

Suppose all five domains share one master geometric profile with ratio $r$ and knee $B = k_{\mathrm{geom}}(r,t)$, and each domain $j$ observes the ratio $r^{m_j}$ for an integer **tax exponent** $m_j \ge 1$. By Theorem 4.9 the observed knee of domain $j$ is $\lceil B/m_j\rceil$.

**Theorem 6.1 (Reconstruction at $B=120$).** If the master knee is $120$, then the exponent vector $(10,6,6,5,3)$ reproduces the table:
$$\lceil 120/10\rceil = 12,\quad \lceil 120/6\rceil = 20,\quad \lceil 120/5\rceil = 24,\quad \lceil 120/3\rceil = 40 .$$

*Proof.* Direct evaluation, combined with Theorem 4.9. $\square$

**Theorem 6.2 (Minimality among exact divisors).** If $B>0$ is a common multiple of $20$ and $24$, then $120 \le B$.

*Proof.* $\mathrm{lcm}(20,24)=120$ divides $B$ and $B>0$. $\square$

Theorem 6.2 is what makes $120$ look canonical. But it assumes *exact divisibility*, a condition the ceiling law of Theorem 4.9 does not impose.

### 6.2 A smaller master

**Theorem 6.3 (Reconstruction at $B=118$).** If the master knee is $118$, the *same* exponent vector $(10,6,6,5,3)$ reproduces the *same* table:
$$\lceil 118/10\rceil = 12,\quad \lceil 118/6\rceil = 20,\quad \lceil 118/5\rceil = 24,\quad \lceil 118/3\rceil = 40 .$$

*Proof.* $118/10 = 11.8$, $118/6 = 19.67$, $118/5 = 23.6$, $118/3 = 39.33$; take ceilings. Combine with Theorem 4.9. $\square$

To show $118$ is genuinely minimal we must quantify over *all* exponent choices, which is an unbounded search a priori. It is made finite by the following observation.

**Lemma 6.4 (Exponent bound).** If $m \ge 1$, $\lceil B/m\rceil = v$ and $v \ge 2$, then $m \le B$.

*Proof.* If $m > B$ then $B \le m\cdot 1$, so $\lceil B/m\rceil \le 1 < v$. $\square$

**Definition 6.5.** Say $B$ *realizes* $v$ if there is $m \ge 1$ with $\lceil B/m\rceil = v$, and $B$ *covers the table* if it realizes each of $12, 20, 24, 40$.

By Lemma 6.4, for the entries at hand (all $\ge 2$) it suffices to search $1 \le m \le B$, so covering is decidable by finite computation for each $B$.

**Theorem 6.6 (Minimality of $118$).** No $B < 118$ covers the table: there are no exponents $m_1,m_2,m_3,m_4 \ge 1$ with
$$\lceil B/m_1\rceil = 12,\quad \lceil B/m_2\rceil = 20,\quad \lceil B/m_3\rceil = 24,\quad \lceil B/m_4\rceil = 40 .$$

*Proof.* By Lemma 6.4 each $m_i \le B$, so covering is equivalent to a finite predicate; exhaustive evaluation over $B = 0,\dots,117$ and $m \le B$ shows the predicate fails everywhere. $\square$

A short structural reason: by Proposition 4.11, $\lceil B/m_4\rceil = 40$ forces $39m_4 < B \le 40m_4$, so $B > 39$ and, since also $\lceil B/m_3\rceil = 24$ needs $23m_3 < B \le 24m_3$, the two intervals must overlap; the tightest overlap compatible with the remaining two constraints occurs at $m_4=3, m_3=5$, forcing $B > 117$.

**Theorem 6.7 (Observational indistinguishability).** Two master profiles, one with master knee $118$ and one with master knee $120$, produce identical values on all four table entries under the exponents $(10,6,5,3)$, while having different master knees.

*Proof.* Theorems 6.1 and 6.3 give the same four values; $118 \ne 120$. $\square$

### 6.3 The exact solution set

**Theorem 6.8 (Gauge freedom).** For $B \in \mathbb{N}$,
$$\Big(\lceil B/10\rceil = 12 \ \wedge\ \lceil B/6\rceil = 20 \ \wedge\ \lceil B/5\rceil = 24 \ \wedge\ \lceil B/3\rceil = 40\Big) \iff B \in \{118,119,120\}.$$

*Proof.* By Proposition 4.11 the four conditions are respectively
$$110 < B \le 120,\qquad 114 < B \le 120,\qquad 115 < B \le 120,\qquad 117 < B \le 120,$$
whose conjunction is $117 < B \le 120$, i.e. $B \in \{118,119,120\}$. $\square$

**Interpretation.** The five-domain table, measured at a single gate and a single context, determines the master profile only up to a three-element ambiguity, and the exponent vector only up to the corresponding rescaling. The value $120$ is not privileged by the physics; it is privileged only by the extra — and unjustified — demand of exact divisibility. Any claim that a particular master knee or exponent vector is canonical requires an independent observable.

---

## 7. Rigidity of exact multiplicativity

The results so far are about geometric profiles. The following theorem needs no such assumption.

**Theorem 7.1 (Multiplicative rigidity).** Let $A, B$ be strictly positive profiles and $m \ge 1$. Suppose
$$k^*(A,\tau) = m\,k^*(B,\tau) \qquad \text{for every } \tau > 0 .$$
Then for every $k \ge 1$,
$$R_A(mk) = R_B(k).$$

*Proof sketch.* Both directions use self-calibration (Proposition 2.12). Fix $k \ge 1$ and put $\tau = R_B(k) > 0$. Then $k^*(B,\tau) = k$, so the hypothesis gives $k^*(A,\tau) = mk$, whence $\tau \le R_A(mk)$, i.e. $R_B(k) \le R_A(mk)$. Conversely put $\sigma = R_A(mk) > 0$; then $k^*(A,\sigma) = mk$, so $m\,k^*(B,\sigma) = mk$ and $k^*(B,\sigma) = k$, giving $\sigma \le R_B(k)$, i.e. $R_A(mk) \le R_B(k)$. Antisymmetry concludes. $\square$

Thus "the tax is an exact multiplier at every gate" is not a weak statistical statement but a complete determination: $A$'s retention curve, sampled at multiples of $m$, *is* $B$'s retention curve. $A$ is a block dilation of $B$. The internal distribution of mass within each block of $m$ positions is unconstrained; the block totals are rigid.

**Corollary 7.2 (Composite taxes compose).** Ceiling division composes: $\lceil \lceil B/m\rceil / m'\rceil = \lceil B/(mm')\rceil$. Consequently, taxing a geometric profile by an $m$-th root and then an $m'$-th root is the same as taxing by an $(mm')$-th root:
$$k_{\mathrm{geom}}(r^{mm'},t) = \left\lceil \frac{\lceil k_{\mathrm{geom}}(r,t)/m\rceil}{m'} \right\rceil .$$

*Proof.* Both sides have the same down-set: $\lceil\lceil B/m\rceil/m'\rceil \le n \iff \lceil B/m\rceil \le m'n \iff B \le mm'n \iff \lceil B/(mm')\rceil \le n$. $\square$

**Theorem 7.3 (Composite delay-after-root law).** For $0\le r<1$, $0<\tau<1$, $d \ge 0$, $m \ge 1$,
$$k^*\big(\mathrm{delay}_d(\mathrm{geom}(r^m)),\ \tau\big) = d + \left\lceil \frac{k_{\mathrm{geom}}(r,1-\tau)}{m} \right\rceil .$$

*Proof.* Theorem 3.2, then Proposition 4.4 and Theorem 4.9. $\square$

This is the general two-parameter tax: an additive part $d$ and a multiplicative part $m$, cleanly separated. A measurement at two gates suffices in principle to separate them, since only the multiplicative part scales with the gate.

**Theorem 7.4 (Mixed-corpus sandwich).** For $\lambda \in [0,1]$, nonnegative profiles $A,B$ with reachable gates, and the mixture $(\lambda A + (1-\lambda)B)$,
$$\min\big(k^*(A,\tau),k^*(B,\tau)\big) \le k^*\big(\lambda A + (1-\lambda)B,\ \tau\big) \le \max\big(k^*(A,\tau),k^*(B,\tau)\big).$$

*Proof.* Retention is affine in $\lambda$: $R_{\mathrm{mix}}(k) = \lambda R_A(k) + (1-\lambda)R_B(k)$, so $R_{\mathrm{mix}}$ lies between $\min(R_A,R_B)$ and $\max(R_A,R_B)$ pointwise; Proposition 2.11 transfers this to the knees. $\square$

Mixing corpora therefore cannot produce a knee outside the range of the constituents — the observed spread across domains is not a mixing artefact.

---

## 8. Tail classes

Everything above assumes geometric decay. The alternative class behaves qualitatively differently.

**Lemma 8.1.** $R_{\mathrm{heavy}}(k) = \dfrac{k}{k+1}$.

*Proof.* Telescoping: $\frac{1}{(i+1)(i+2)} = \frac1{i+1}-\frac1{i+2}$. $\square$

So the heavy knee at tail budget $t$ is about $1/t$: polynomial in $1/t$, where the geometric knee is logarithmic.

**Lemma 8.2.** For $0<r<1$ and any $C \in \mathbb{N}$ there is $n \ge 1$ with $Cn\,r^n < 1$.

*Proof sketch.* Write $s = 1/r > 1$ and $c = s-1 > 0$. Bernoulli's inequality gives $s^p \ge 1 + pc$, so $s^{2p} \ge (1+pc)^2 \ge 1 + 2pc + p^2c^2$. Choosing $p$ a natural number exceeding $\max(2C/c^2, 1)$ makes $p c^2 > 2C$, hence $p^2c^2 > 2Cp$ and $s^{2p} > 2Cp = C\cdot(2p)$. Taking $n=2p$ and inverting gives $Cn r^n < 1$. $\square$

**Theorem 8.3 (Tail-class separation).** For $0<r<1$ and every $C \in \mathbb{N}$ there is a gate $\tau \in (0,1)$ with
$$C\,k^*(\mathrm{geom}(r),\tau) \;\le\; k^*(\mathrm{heavy},\tau).$$

*Proof sketch.* Choose $n$ as in Lemma 8.2 and set $\tau = 1-r^n$. By Proposition 4.4 and Proposition 4.5, $k^*(\mathrm{geom}(r),\tau) = n$ exactly. For the heavy profile, Lemma 8.1 gives $\tau \le R_{\mathrm{heavy}}(j) \iff (j+1)r^n \ge 1$; for every $j < Cn$ we have $(j+1)r^n \le Cn\,r^n < 1$, so every such $j$ fails the gate, whence $k^*(\mathrm{heavy},\tau)\ge Cn = C\,k^*(\mathrm{geom}(r),\tau)$. Reachability of the gate for the heavy profile follows from $R_{\mathrm{heavy}}(k)\to 1$. $\square$

**Consequence.** Across tail classes there is no bounded multiplier, let alone a bounded additive tax. The "$+4$ versus $\times 2$" question is therefore *conditional* on all five domains inhabiting the geometric class; if any does not, no fixed tax of either kind exists for it. This gives an experimental discriminator: a geometric-class domain responds to a doubling of context length with an additive shift of the knee, a polynomial-class domain with a multiplicative one.

---

## 9. Measurement grids

Real measurements test a finite set $G$ of cut-offs.

**Definition 9.1.** $k^*_G(w,\tau) = \inf\{k \in G : \tau \le R_w(k)\}$.

**Theorem 9.2 (Grids never underestimate; brackets).** For nonnegative $w$ with a passing grid point:
1. $k^*(w,\tau) \le k^*_G(w,\tau)$;
2. $k^*_G(w,\tau) = \inf\{k \in G : k^*(w,\tau) \le k\}$ — the grid reports the least tested point at or above the true knee;
3. if $k^*(w,\tau) \in G$ then $k^*_G(w,\tau) = k^*(w,\tau)$;
4. if $\tau > R_w(a)$ and $\tau \le R_w(b)$ then $a < k^*(w,\tau) \le b$.

*Proof.* (1) A passing grid point passes, so it lies in the full gate set. (2) By Proposition 2.10, for nonnegative $w$ the conditions "$\tau \le R_w(k)$" and "$k^*(w,\tau)\le k$" define the same set of $k$; intersect with $G$. (3) Immediate from (2). (4) The second inequality is (1)-style minimality; the first is Proposition 2.8. $\square$

Applied to the French data of Section 1.1 with $\tau = 0.98$: $R(36)=0.9795 < \tau \le 0.9830 = R(40)$ gives $36 < k^* \le 40$. The grid $\{36,40,48,56,64\}$ resolves the knee to a window of four positions; combined with Theorem 5.2 it resolves it to $\{39,40\}$, but only under the geometric-square-root hypothesis.

---

## 10. Discussion

### 10.1 What the theory settles

1. **Two mechanisms, structurally distinct.** Delay is additive and gate-independent (Theorem 3.2). Root-of-ratio is multiplicative up to a ceiling (Theorem 4.9), exact on multiples (Theorem 4.10), and cannot be imitated by any fixed additive constant (Corollary 4.16).

2. **The $\times 2$ verdict is consistent but not tight.** A square-root decay tax with an English knee of $20$ predicts a French knee in $\{39,40\}$ (Theorem 5.2). The reported $40$ requires an unverified parity assumption (Theorem 5.1).

3. **Exact multiplicativity is rigid.** If the multiplier law holds at every gate, the taxed retention curve is a block dilation of the untaxed one (Theorem 7.1), with no geometric hypothesis.

4. **The master profile is underdetermined.** The admissible masters are exactly $\{118,119,120\}$ (Theorem 6.8), $118$ is the true minimum over all exponent vectors (Theorem 6.6), and $118$ and $120$ are observationally indistinguishable on the table (Theorem 6.7).

### 10.2 What the theory does not settle

The theory is conditional on the *empirical* premise that the domain tails are geometric with the claimed exponent relations — in particular that $r_{\mathrm{EN}} = r_{\mathrm{FR}}^2$. Nothing here establishes that premise. Theorem 8.3 shows what is at stake: outside the geometric class the language of fixed taxes has no referent at all.

Nor does the theory explain *why* the exponents take the values they do. The observation that German adds $+4$ while French multiplies by $2$ suggests that the tax mechanism differs across languages — a delay-like mechanism for one, a dilation-like mechanism for the other — but the five-domain table cannot separate these hypotheses at a single gate, precisely because a single gate provides only one equation per domain.

### 10.3 Design consequences

For a system that must budget memory:

- If a domain's tax is additive, the extra cost is a constant and can be amortised; tightening the retention gate does not make it worse.
- If it is multiplicative, the extra cost scales with the gate; tightening from $98\%$ to $99.5\%$ inflates the difference.
- The gate-invariance of the ratio (Theorem 4.14) means one can calibrate a domain's multiplier once, at a convenient gate, and transfer it.
- The grid analysis (Theorem 9.2) means a coarse grid is *safe*: it over-provisions, never under-provisions.

---

## 11. Future directions

**Conjecture 1 (Gate-invariant tax ratio).** For any two domains whose attention profiles have geometric tails with ratios $r_1, r_2$, the measured knee ratio satisfies
$$\left| \frac{k^*_1(\tau)}{k^*_2(\tau)} - \frac{\log r_2}{\log r_1}\right| \longrightarrow 0 \quad \text{as } \tau \to 1,$$
uniformly over corpora. The key insight is Theorem 4.14: the ideal knee factorises into a gate-dependent numerator and a domain-dependent denominator, so the domain multiplier is a pure tail invariant. The only gate dependence left is the sub-unit rounding of Proposition 4.8. The integer half of the prediction is already proved: Theorem 4.12 gives $B \le mA < B+m$, whence the French knee admits only $39$ or $40$ for an English knee of $20$. What remains open is the empirical premise that both tails are geometric with $r_{\mathrm{EN}} = r_{\mathrm{FR}}^2$. The prediction $|k^*_{\mathrm{FR}} - 2k^*_{\mathrm{EN}}| \le 2$ at *every* context is testable with the existing measurement apparatus at zero additional modelling cost.

**Conjecture 2 (Tail-class dichotomy).** Every language/domain profile falls into exactly one of two knee classes — logarithmic ($k^* = \Theta(\log(1/t))$, geometric tails) or polynomial ($k^* = \Theta(t^{-1/\alpha})$, power-law tails) — and no natural-language corpus is in the polynomial class at context $1024$. The key insight is Theorem 8.3: the two classes are separated by an unbounded factor, not a constant, so a single doubling of the context length distinguishes them — the geometric class shifts the knee by an additive constant, the polynomial class by a multiplicative one. The "$+4$ versus $\times 2$" dispute is exactly the question of which class the domains live in.

**Further programme.**
- French at a second context (e.g. $512$) on the extended grid, to test gate/context invariance of the ratio.
- Increments at context $4096$, to separate additive from multiplicative context response.
- Additional languages, to see whether the multiplier set is discrete (as $\{1, 1.2, 2\}$ from the current table would suggest) or continuous.
- An independent observable to break the $\{118,119,120\}$ degeneracy — for instance a sixth domain whose entry is sensitive to $B \bmod 6$.
- Direct estimation of the tail ratios $r$ per domain, converting the conditional theory into an unconditional one.

---

## 12. Conclusion

The retention knee is a clean, exactly analysable observable, and it supports exactly two structural tax mechanisms: an additive delay, which shifts it by a gate-independent constant, and a multiplicative decay tax, which scales it by an integer up to a single ceiling step. These are provably different, and no fixed additive constant can imitate a root tax across gates.

Applied to the five-domain table, the theory confirms that a square-root decay tax is consistent with the French knee being double the English one — but sharpens the claim to "$39$ or $40$", the residual ambiguity being exactly the parity bit that a coarse grid cannot see. It also shows that the reconstruction of a single master profile from the table is not unique: the admissible master knees are precisely $118$, $119$ and $120$, so the table's apparent determination of a canonical master at $120$ is an artefact of an unnecessary divisibility assumption.

Finally, the theory delivers two falsifiable predictions at no modelling cost: the tax ratio between domains must be independent of the gate, and doubling the context must separate logarithmic from polynomial tail classes by the *kind* of shift it induces. Both are within reach of the measurements already being made.
