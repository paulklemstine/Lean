# A Radix-Growth Threshold: When Is the Height of a Self-Escalating Positional System $O(\log^* n)$?

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study generalized positional numeral systems whose radix at each position is determined by the weight already accumulated. Given a *radix schedule* $r : \mathbb{N} \to \mathbb{N}$, define weights by $V_0 = 1$ and $V_{k+1} = r(V_k)\,V_k$, and define the *radix height* of $n$ to be $K_r(n) = \min\{k : n < V_k\}$, the number of digit positions required to represent $n$. We determine exactly when $K_r$ is $O(\log^* n)$, where $\log^*$ is the iterated binary logarithm.

Three results are established. First, a **dichotomy**: if $r(x) \ge 2$ everywhere and $2^x \le r(x)$ for all $x \ge x_0$, then $K_r(n) \le x_0 + \log^* n + 1$ for every $n$ — an $O(\log^*)$ bound with additive, not multiplicative, overhead; whereas if $r$ is monotone with $r \ge 2$ and $r(x) \le x^C$ for a fixed $C$ and all large $x$, then for every constant $c$ and every bound $N$ there is an input $n \ge N$ with $c(\log^* n + 1) < K_r(n)$, so $K_r$ is not $O(\log^* n)$. Second, **sharpness**: for schedules bounded above by $2^x$ one has $\log^* n \le 2 K_r(n)$, so the canonical schedule $r(x) = \max(2, 2^x)$ satisfies $\tfrac{1}{2}\log^* n \le K_r(n) \le \log^* n + 1$ and its radix height is genuinely $\Theta(\log^* n)$. Third, **structure**: the polynomial hypothesis is inessential. We isolate a master transfer principle showing that sublinear growth of $k \mapsto \log^*(V_k)$ alone defeats the $O(\log^*)$ bound, deduce that weights bounded by *any fixed height* of iterated exponentials of a linear function of $k$ already fail, and finally characterize the fast regime intrinsically: $K_r(n) = O(\log^* n)$ if and only if the weights overtake the tower of twos along an arithmetic subsequence, $\exists c\ \forall k,\ T_k \le V_{c(k+1)}$.

The threshold is therefore not located at "polynomial versus exponential" but at the *height of the iterated-exponential tower* under which the weights live: bounded height loses, growing height wins.

**Keywords:** mixed-radix representation, iterated logarithm, tower of twos, growth rates, positional numeral systems, hierarchical scales, asymptotic dichotomy.

---

## 1. Introduction

### 1.1 Motivation

A positional numeral system is determined by its sequence of place weights. In base $b$ the weights are $1, b, b^2, \dots$ and representing $n$ costs $\Theta(\log n)$ digits. In a *mixed-radix* system, one fixes a sequence of bases $b_0, b_1, b_2, \dots$ and takes weights $V_0 = 1$, $V_{k+1} = b_k V_k$; the familiar time and calendar systems are of this type, as are factorial number systems ($b_k = k+2$) and combinatorial ranking schemes.

Physical and computational hierarchies suggest a further generalization in which the base at position $k$ is not chosen in advance but is a function of the weight already reached. This is the natural formalization of a self-similar stratification whose coarsening factor is governed by the coarseness already attained: a lattice refinement scheme, a renormalization ladder, a nested unit system. It is also the natural formalization of a recursive escalation in an algorithm, where the size of the next stage is dictated by the size of the current one.

Concretely, we fix a *radix schedule* $r : \mathbb{N} \to \mathbb{N}$ and set

$$V_0 = 1, \qquad V_{k+1} = r(V_k)\, V_k .$$

Constant $r \equiv b$ recovers base $b$. The schedule $r(x) = 2^x$ produces an explosive system with weights $1, 2, 8, 2048, 2^{2059}, \dots$. The schedule $r(x) = x^2 + 2$ produces a system growing doubly exponentially in $k$, which is fast by any ordinary measure yet, as we shall prove, still on the slow side of the threshold we identify.

The quantity of interest is the number of digit positions needed:

$$K_r(n) = \min\{k \in \mathbb{N} : n < V_k\} .$$

For base $b$ this is $\Theta(\log n)$; for exponentially escalating schedules it drops all the way to the iterated logarithm. Our aim is to determine exactly where the transition occurs.

### 1.2 The iterated logarithm and the tower

The relevant yardstick is $\log^*$, the iterated binary logarithm, defined by the recursion

$$\log^* n = \begin{cases} 0, & n \le 1,\\ 1 + \log^*\!\big(\lfloor \log_2 n \rfloor\big), & n > 1, \end{cases}$$

which terminates because $\lfloor \log_2 n\rfloor < n$ for $n \ge 1$. Its inverse is the tower of twos

$$T_0 = 1, \qquad T_{k+1} = 2^{T_k},$$

with $T_1 = 2$, $T_2 = 4$, $T_3 = 16$, $T_4 = 65536$, $T_5 = 2^{65536}$.

### 1.3 Statement of the main results

Throughout, a schedule $r$ is **admissible** if $r(x) \ge 2$ for all $x$. We prove:

- **(Theorem A, exponential regime.)** If $r$ is admissible and $2^x \le r(x)$ for all $x \ge x_0$, then $K_r(n) \le x_0 + \log^* n + 1$ for all $n$.
- **(Theorem B, sharpness.)** If $r$ is admissible and $r(x) \le 2^x$ for all $x \ge 1$, then $\log^* n \le 2 K_r(n)$ for all $n$. Consequently $r(x) = \max(2, 2^x)$ has $K_r(n) = \Theta(\log^* n)$, with the explicit two-sided bound $\tfrac12 \log^* n \le K_r(n) \le \log^* n + 1$.
- **(Theorem C, polynomial regime.)** If $r$ is admissible, monotone, and $r(x) \le x^C$ for all $x \ge x_0$, then for every $c, N$ there is $n \ge N$ with $c(\log^* n + 1) < K_r(n)$. Hence there is no constant $c$ with $K_r(n) \le c(\log^* n + 1)$ for all $n$.
- **(Theorem D, master transfer principle.)** If $r$ is admissible and $\log^*(V_k) \le h(k)$ for some *weakly sublinear* $h$ (for all $c, N$ there is $k \ge N$ with $c(h(k)+1) < k+1$), then the conclusion of Theorem C holds.
- **(Theorem E, fixed-height theorem.)** If $r$ is admissible and $V_k \le E^{(h)}(M + Ek)$ for a fixed height $h$ and constants $M, E \ge 2$, where $E^{(0)}(x) = x$ and $E^{(j+1)}(x) = 2^{E^{(j)}(x)}$, then $K_r$ is not $O(\log^* n)$.
- **(Theorem F, characterization.)** For admissible $r$: $\exists c\ \forall n,\ K_r(n) \le c(\log^* n + 1)$ **iff** $\exists c\ \forall k,\ T_k \le V_{c(k+1)}$.

Theorem F is the conceptual endpoint. It says that the appearance of $\log^*$ is forced: since $\log^*$ inverts the tower, the fast regime is precisely the regime in which the weight sequence can keep pace with a tower after a linear reindexing.

### 1.4 Organization

Section 2 fixes definitions and elementary facts. Section 3 develops the calculus of $\log^*$ and the tower. Section 4 gives basic control on the weights and the radix height. Section 5 proves Theorem A and Section 6 proves Theorem B. Section 7 develops the master transfer principle (Theorem D) and its fixed-height corollary (Theorem E), and derives Theorem C. Section 8 proves the characterization (Theorem F). Section 9 collects concrete instances. Sections 10–12 discuss algorithms, applications, and open directions.

---

## 2. Definitions

**Definition 2.1 (Radix schedule and weights).** A *radix schedule* is a function $r : \mathbb{N}\to\mathbb{N}$. Its *weight sequence* is
$$V_0 = 1, \qquad V_{k+1} = r(V_k)\, V_k .$$
We write $V_k$ when $r$ is understood and $V_k^{(r)}$ otherwise. A schedule is *admissible* if $r(x)\ge 2$ for all $x$, and *monotone* if $x \le y \Rightarrow r(x)\le r(y)$.

**Definition 2.2 (Radix height).** For admissible $r$ and $n \in \mathbb{N}$,
$$K_r(n) = \min\{k : n < V_k\} .$$
The minimum is over a nonempty set (Lemma 4.3), so $K_r(n)$ is well defined.

The interpretation is the standard one: writing $n$ in the mixed-radix system with digit $d_k \in \{0, 1, \dots, r(V_k)-1\}$ at position $k$ requires exactly the positions $0, \dots, K_r(n)-1$, since the positions below $k$ can represent all residues modulo $V_k$ and no more.

**Definition 2.3 (Tower and iterated exponential).** $T_0 = 1$, $T_{k+1} = 2^{T_k}$. More generally $E^{(0)}(x) = x$ and $E^{(h+1)}(x) = 2^{E^{(h)}(x)}$, so $T_k = E^{(k)}(1)$.

**Definition 2.4 (Iterated logarithm).** $\log^* n = 0$ for $n \le 1$, and $\log^* n = 1 + \log^*\lfloor \log_2 n\rfloor$ for $n > 1$. Here $\lfloor \log_2 n \rfloor$ denotes the integer binary logarithm, i.e. the largest $j$ with $2^j \le n$ (and $0$ for $n = 0$).

**Definition 2.5 (The $O(\log^*)$ property).** We say $K_r$ *is $O(\log^* n)$* if there is a constant $c$ with $K_r(n) \le c(\log^* n + 1)$ for all $n$. The additive $+1$ inside the parenthesis is the correct normalization because $\log^* n = 0$ for $n \le 1$ while $K_r(n) \ge 1$ there; without it, no schedule would qualify, for trivial reasons.

**Definition 2.6 (Canonical schedules).** $\mathrm{exp}\text{-}\mathrm{sched}(x) = \max(2, 2^x)$ and, for an exponent $C$, $\mathrm{poly}\text{-}\mathrm{sched}_C(x) = x^C + 2$.

---

## 3. The calculus of $\log^*$ and the tower

All statements in this section are over $\mathbb{N}$ and elementary; we record them because the main proofs use nothing else.

**Lemma 3.1 (Monotonicity).** $\log^*$ is monotone: $m \le n \Rightarrow \log^* m \le \log^* n$.

*Proof sketch.* Strong induction on $n$. If $m \le 1$ the left side is $0$. Otherwise $1 < m \le n$, and $\log^* m = 1 + \log^*\lfloor\log_2 m\rfloor$, $\log^* n = 1 + \log^*\lfloor \log_2 n\rfloor$; since $\lfloor\log_2 \cdot\rfloor$ is monotone and $\lfloor\log_2 n\rfloor < n$, the induction hypothesis applies. $\square$

**Lemma 3.2 (Domination by a single logarithm).** $\log^* n \le \lfloor \log_2 n\rfloor$ for all $n$.

*Proof sketch.* Strong induction. For $n \le 1$ both sides are $0$. For $n > 1$, put $\ell = \lfloor\log_2 n\rfloor \ge 1$; then $\log^* n = 1 + \log^* \ell \le 1 + \lfloor\log_2 \ell\rfloor \le \ell$, the last step because $\lfloor\log_2 \ell\rfloor < \ell$ for $\ell \ge 1$. $\square$

**Lemma 3.3 (Peeling one exponential).** If $a \ge 1$ then $\log^*(2^a) = 1 + \log^* a$; for all $a\ge 0$, $\log^*(2^a) \le 1 + \log^* a$.

*Proof sketch.* For $a \ge 1$, $2^a > 1$ and $\lfloor\log_2 2^a\rfloor = a$; apply the recursion. For $a = 0$ both sides are $0$ and $1$ respectively. $\square$

**Corollary 3.4.** If $n \le 2^a$ then $\log^* n \le 1 + \log^* a$.

**Lemma 3.5 (Fixed height shifts $\log^*$ by a constant).** For all $h, y$: $\log^*\big(E^{(h)}(y)\big) \le h + \log^* y$.

*Proof sketch.* Induction on $h$ using Lemma 3.3. $\square$

**Lemma 3.6 ($\log^*$ inverts the tower).** $T_k \ge 1$ for all $k$, and $\log^*(T_j) = j$ for all $j$.

*Proof sketch.* Induction: $\log^*(T_{j+1}) = \log^*(2^{T_j}) = 1 + \log^*(T_j) = 1 + j$ by Lemma 3.3, valid since $T_j \ge 1$. $\square$

In particular $\log^*$ is unbounded, which guarantees that none of the statements below is vacuous.

**Lemma 3.7 (Tower characterization).** For all $n$: $n < T_{\log^* n + 1}$.

*Proof sketch.* Strong induction. For $n \le 1$: $T_1 = 2 > n$. For $n > 1$ let $\ell = \lfloor\log_2 n\rfloor$. By induction $\ell < T_{\log^*\ell + 1}$, hence $\ell + 1 \le T_{\log^*\ell+1}$ and
$$n < 2^{\ell+1} \le 2^{T_{\log^*\ell + 1}} = T_{\log^*\ell + 2} = T_{\log^* n + 1},$$
using $\log^* n = 1 + \log^*\ell$. $\square$

Lemmas 3.6 and 3.7 together say: $\log^* n$ is, up to $\pm 1$, the height of the shortest tower exceeding $n$. Every subsequent argument uses only this.

---

## 4. Basic control on weights and radix height

Fix an admissible schedule $r$.

**Lemma 4.1.** $V_k \ge 1$ for all $k$, and indeed $2^k \le V_k$.

*Proof sketch.* Induction: $V_{k+1} = r(V_k)V_k \ge 2 \cdot 2^k$. $\square$

**Lemma 4.2 (Monotonicity and strict growth).** $V$ is monotone, and strictly increasing: $V_k < V_{k+1}$.

*Proof sketch.* $V_{k+1} = r(V_k)V_k \ge 2V_k > V_k$ since $V_k \ge 1$. $\square$

**Lemma 4.3 (Existence).** For every $n$ there is $k$ with $n < V_k$; indeed $k = n$ works, since $n < 2^n \le V_n$.

**Lemma 4.4 (Defining properties of $K_r$).** For all $n, k$:
1. $n < V_{K_r(n)}$;
2. if $n < V_k$ then $K_r(n) \le k$;
3. if $V_k \le n$ then $k < K_r(n)$.

*Proof sketch.* (1) and (2) are the definition of a minimum together with Lemma 4.3. (3): if $K_r(n) \le k$ then $V_{K_r(n)} \le V_k \le n$ by Lemma 4.2, contradicting (1). $\square$

**Lemma 4.5 (Monotonicity of the height, and its jump points).** $K_r$ is monotone, and $K_r(V_k) = k+1$ for every $k$.

*Proof sketch.* Monotonicity: if $m \le n$ then $m \le n < V_{K_r(n)}$, so $K_r(m) \le K_r(n)$. For the jump points: $V_k < V_{k+1}$ gives $K_r(V_k) \le k+1$ by 4.4(2), and $V_k \le V_k$ gives $k < K_r(V_k)$ by 4.4(3). $\square$

Lemma 4.5 is the crucial *probe* used in every lower-bound argument: at the input $n = V_k$ the radix height is known exactly, so the only remaining task is to bound $\log^*(V_k)$.

---

## 5. The exponential regime (Theorem A)

**Lemma 5.1 (Weights dominate a shifted tower).** Suppose $r$ is admissible and $2^x \le r(x)$ for all $x \ge x_0$. Then $T_j \le V_{x_0 + j}$ for all $j$.

*Proof.* Induction on $j$. For $j = 0$, $T_0 = 1 \le V_{x_0}$ by Lemma 4.1. Assume $T_j \le V_{x_0+j}$. By Lemma 4.1, $V_{x_0+j} \ge 2^{x_0+j} > x_0 + j \ge x_0$, so the hypothesis applies at $x = V_{x_0+j}$:
$$T_{j+1} = 2^{T_j} \le 2^{V_{x_0+j}} \le r\big(V_{x_0+j}\big) \le r\big(V_{x_0+j}\big) V_{x_0+j} = V_{x_0+j+1}. \qquad\square$$

**Theorem A (Exponential regime).** Let $r$ be admissible with $2^x \le r(x)$ for all $x \ge x_0$. Then for every $n$,
$$K_r(n) \le x_0 + \log^* n + 1 .$$

*Proof.* By Lemma 3.7, $n < T_{\log^* n + 1}$; by Lemma 5.1, $T_{\log^* n + 1} \le V_{x_0 + \log^* n + 1}$. Apply Lemma 4.4(2). $\square$

Two features deserve emphasis. First, the bound has *no multiplicative constant*: the entire cost of the hypothesis being valid only beyond $x_0$ is an additive $x_0$. Second, the proof is a single induction plus the tower characterization of $\log^*$ — there is no hidden analytic estimate.

---

## 6. Sharpness (Theorem B)

An $O(\log^*)$ upper bound would be uninformative if the truth were smaller still. It is not, provided the schedule is also *at most* exponential.

**Lemma 6.1 (Elementary inequality).** For $v \ge 1$, $2v \le 2^v$.

**Lemma 6.2 (Weights trapped under a doubled tower).** Suppose $r$ is admissible and $r(x) \le 2^x$ for all $x \ge 1$. Then $V_k \le T_{2k}$ for all $k$.

*Proof.* Induction on $k$; $V_0 = 1 = T_0$. Assuming $V_k \le T_{2k}$ and writing $v = V_k \ge 1$,
$$V_{k+1} = r(v)\,v \le 2^{v}\cdot 2^{v} = 2^{2v} \le 2^{2^{v}} \le 2^{2^{T_{2k}}} = T_{2k+2} = T_{2(k+1)},$$
using $v < 2^v$, Lemma 6.1, and monotonicity of $x\mapsto 2^x$. $\square$

**Theorem B (Matching lower bound).** Suppose $r$ is admissible and $r(x)\le 2^x$ for all $x \ge 1$. Then $\log^* n \le 2K_r(n)$ for all $n$.

*Proof.* By Lemma 4.4(1), $n < V_{K_r(n)} \le T_{2K_r(n)}$ (Lemma 6.2). Apply $\log^*$, monotone by Lemma 3.1, and use $\log^*(T_j) = j$ (Lemma 3.6). $\square$

**Corollary 6.3 ($\Theta(\log^*)$ for the canonical schedule).** For $r(x) = \max(2, 2^x)$ one has, for every $n$,
$$\tfrac{1}{2}\log^* n \;\le\; K_r(n) \;\le\; \log^* n + 1 .$$

*Proof.* $r(x) \ge 2$ and $r(x)\ge 2^x$ for all $x$, so Theorem A applies with $x_0 = 0$. Also $r(x) \le 2^x$ for $x \ge 1$, so Theorem B applies. $\square$

Thus the exponential regime is not merely $O(\log^*)$ but exactly $\Theta(\log^*)$, and the constants are explicit and small.

---

## 7. The slow side: transfer principles (Theorems D, E, C)

### 7.1 What actually matters

The negative results all follow from one observation. Evaluate the comparison $c(\log^* n + 1)$ versus $K_r(n)$ at $n = V_k$. Lemma 4.5 gives $K_r(V_k) = k+1$ exactly. So the comparison becomes
$$c\big(\log^*(V_k) + 1\big) \;\overset{?}{<}\; k+1,$$
a purely arithmetic question about the sequence $k \mapsto \log^*(V_k)$. If that sequence grows sublinearly — in the weak sense that it dips below $k/c$ infinitely often, for each $c$ — the $O(\log^*)$ bound fails.

**Definition 7.1 (Weakly sublinear).** $h : \mathbb{N}\to\mathbb{N}$ is *weakly sublinear* if for all $c, N \in \mathbb{N}$ there is $k \ge N$ with $c\,(h(k)+1) < k+1$.

**Theorem D (Master transfer principle).** Let $r$ be admissible and suppose $\log^*(V_k) \le h(k)$ for all $k$, with $h$ weakly sublinear. Then for all $c, N$ there is $n \ge N$ with
$$c(\log^* n + 1) < K_r(n).$$

*Proof.* Given $c$ and $N$, choose $k \ge N$ with $c(h(k)+1) < k+1$. Take $n = V_k$. Then $n \ge 2^k > k \ge N$ by Lemma 4.1. By Lemma 4.4(3), $k < K_r(V_k)$, i.e. $K_r(n) \ge k+1$. And
$$c(\log^* n + 1) = c(\log^*(V_k)+1) \le c(h(k)+1) < k+1 \le K_r(n). \qquad\square$$

The witnesses are the weights themselves — the inputs on which the system is maximally inefficient relative to $\log^*$. Because $V_k \ge 2^k$, the witnesses are arbitrarily large: the failure is asymptotic, not a small-$n$ artefact.

### 7.2 Fixed tower height is fatal

**Lemma 7.2 (Doubly exponential is two exponentials of a linear function).** For all $M, E, k$:
$$M^{E^k} \le E^{(2)}\big(M + Ek\big) = 2^{2^{M+Ek}} .$$

*Proof.* Using $x < 2^x$: $M^{E^k} \le (2^M)^{E^k} = 2^{M E^k}$ and $M E^k \le 2^M (2^E)^k = 2^{M+Ek}$. Combine and use monotonicity of $2^{(\cdot)}$. $\square$

**Lemma 7.3 (Logarithm of a linear function is weakly sublinear).** For fixed $a$ and $M, E \ge 2$, the function $h(k) = a + \lfloor\log_2(M+Ek)\rfloor$ is weakly sublinear.

*Proof sketch.* Given $c, N$, pick $t \ge \max\big(4c,\ 4(M+E+a+1),\ N,\ 1\big)$ and set $m = 2t$, $k = 2^m$. Then $k > m \ge N$. Since $M + Ek \le 2^M\cdot 2^E\cdot 2^m = 2^{M+E+m}$, we get $\lfloor\log_2(M+Ek)\rfloor \le M+E+m$, hence
$$c\,(h(k)+1) \le c\big((M+E+a+1) + m\big) \le \tfrac{t}{4}\Big(\tfrac{t}{4} + 2t\Big) = \tfrac{9}{16}t^2 \le t^2 < 2^{t}\cdot 2^{t} = 2^{2t} = k < k+1,$$
using $c \le t/4$, $M+E+a+1 \le t/4$, $m = 2t$ and $t < 2^t$. $\square$

**Theorem E (Fixed-height theorem).** Let $r$ be admissible and suppose there are a *fixed* height $h$ and constants $M, E \ge 2$ with
$$V_k \le E^{(h)}\big(M + Ek\big) \qquad \text{for all } k .$$
Then for all $c, N$ there is $n \ge N$ with $c(\log^* n + 1) < K_r(n)$; in particular $K_r$ is not $O(\log^* n)$.

*Proof.* By Lemmas 3.1, 3.5 and 3.2,
$$\log^*(V_k) \le \log^*\!\big(E^{(h)}(M+Ek)\big) \le h + \log^*(M+Ek) \le h + \lfloor\log_2(M+Ek)\rfloor,$$
which is weakly sublinear by Lemma 7.3. Apply Theorem D. $\square$

**Corollary 7.4 (Doubly exponential weights).** If $r$ is admissible and $V_k \le M^{E^k}$ with $M, E \ge 2$, then $K_r$ is not $O(\log^* n)$. (Take $h=2$ in Theorem E via Lemma 7.2.)

Theorem E is the conceptual heart of the negative side. What kills the $O(\log^*)$ bound is not slow growth in any everyday sense — $E^{(h)}(M+Ek)$ is astronomically large for $h = 3$ and moderate $k$ — but the fact that the *height* $h$ of the tower is constant. Only a bound whose tower height grows with $k$ leaves room for $O(\log^*)$.

### 7.3 The polynomial regime

We now derive Theorem C by showing that a polynomially bounded schedule has doubly exponential weights.

**Lemma 7.5 (Globalizing a polynomial bound).** Let $r$ be monotone, admissible, with $r(x) \le x^C$ for all $x \ge x_0$. Then $r(x) \le r(x_0)\,(x+1)^C$ for all $x$.

*Proof sketch.* For $x < x_0$, $r(x) \le r(x_0) \le r(x_0)(x+1)^C$. For $x \ge x_0$, $r(x) \le x^C \le r(x_0)(x+1)^C$ since $r(x_0) \ge 2 \ge 1$. $\square$

**Lemma 7.6 (One step).** Under the hypotheses of Lemma 7.5, with $M = r(x_0)\,2^C$,
$$V_{k+1} \le M\, V_k^{\,C+1} \qquad\text{for all } k .$$

*Proof sketch.* $V_{k+1} = r(V_k)V_k \le r(x_0)(V_k+1)^C V_k \le r(x_0)(2V_k)^C V_k = M V_k^{C+1}$, using $V_k \ge 1$ so $V_k + 1 \le 2V_k$. $\square$

**Proposition 7.7 (Doubly exponential weight bound).** Under the hypotheses of Lemma 7.5, with $M = r(x_0)2^C \ge 2$ and $E = C+2$,
$$V_k \le M^{\,E^k} \qquad\text{for all } k .$$

*Proof.* We prove the stronger statement $M\,V_k \le M^{E^k}$ by induction. At $k=0$: $M\cdot 1 = M = M^{E^0}$. Assume $M V_k \le M^{E^k}$. Then by Lemma 7.6,
$$M V_{k+1} \le M\cdot M V_k^{C+1} = (M\cdot M)\, V_k^{C+1} \le M^{C+2}\,V_k^{C+2} = (M V_k)^{C+2} \le \big(M^{E^k}\big)^{E} = M^{E^{k+1}},$$
using $M^2 \le M^{C+2}$ and $V_k^{C+1}\le V_k^{C+2}$ (valid as $M, V_k \ge 1$). Finally $V_k \le M V_k$. $\square$

**Theorem C (Polynomial regime).** Let $r$ be monotone and admissible with $r(x) \le x^C$ for all $x \ge x_0$. Then for every $c$ and every $N$ there is $n \ge N$ with
$$c\big(\log^* n + 1\big) < K_r(n),$$
and consequently there is **no** constant $c$ with $K_r(n) \le c(\log^* n + 1)$ for all $n$.

*Proof.* Proposition 7.7 gives $V_k \le M^{E^k}$ with $M = r(x_0)2^C\ge 2$ and $E = C+2 \ge 2$; apply Corollary 7.4. The final clause follows since such a $c$ would contradict the displayed inequality at a suitable $n$. $\square$

**Theorem (Radix-Growth Threshold).** Let $r$ be admissible with $2^x \le r(x)$ for $x\ge x_0$, and let $s$ be monotone, admissible, with $s(x) \le x^C$ for $x \ge y_0$. Then
$$\big(\forall n,\ K_r(n) \le x_0 + \log^* n + 1\big) \quad\text{and}\quad \neg\,\exists c\ \forall n,\ K_s(n) \le c(\log^* n + 1).$$

This is simply Theorem A together with Theorem C, stated side by side to display the dichotomy.

---

## 8. An intrinsic characterization (Theorem F)

The dichotomy above leaves a gap: schedules that are neither super-exponential nor polynomially bounded. The following result closes the conceptual question completely by replacing hypotheses on $r$ with an equivalent condition on the weights.

**Theorem F (Characterization of the fast regime).** Let $r$ be admissible. Then
$$\exists c\ \forall n,\ K_r(n) \le c\,(\log^* n + 1) \qquad\Longleftrightarrow\qquad \exists c\ \forall k,\ T_k \le V_{c(k+1)} .$$

*Proof.*

($\Rightarrow$) Suppose $K_r(n) \le c(\log^* n + 1)$ for all $n$. Fix $k$ and take $n = T_k$. Then $\log^*(T_k) = k$ (Lemma 3.6), so $K_r(T_k) \le c(k+1)$. By Lemma 4.4(1), $T_k < V_{K_r(T_k)}$, and by monotonicity of $V$ (Lemma 4.2), $V_{K_r(T_k)} \le V_{c(k+1)}$. Hence $T_k < V_{c(k+1)}$, in particular $T_k \le V_{c(k+1)}$.

($\Leftarrow$) Suppose $T_k \le V_{c(k+1)}$ for all $k$. Fix $n$ and put $j = \log^* n$. By Lemma 3.7, $n < T_{j+1} \le V_{c(j+2)}$, so $K_r(n) \le c(j+2)$ by Lemma 4.4(2). Since $c(j+2) + cj = 2c(j+1)$, we get $K_r(n) \le 2c(\log^* n + 1)$. Thus the constant $2c$ works. $\square$

Theorem F explains *why* $\log^*$ and not some other slow function appears in the problem. Because $\log^*$ inverts the tower, the class of schedules with $O(\log^*)$ height is exactly the class whose weights track the tower up to a linear reparametrization of the index. The schedule enters only through this single property. In particular:

- Theorem A is the statement that super-exponential schedules satisfy the right-hand condition with $c$ absorbed into a shift.
- Theorem E is the statement that a fixed-height bound is incompatible with it: $E^{(h)}(M+Ek)$ is, for any fixed $h$, eventually dwarfed by $T_{k'}$ for $k'$ linear in $k$.
- Theorem F shows there is no third possibility: the property is a clean dichotomy on the weight sequence itself, even for wild, non-monotone, or oscillating schedules.

---

## 9. Concrete instances

**Example 9.1 (Canonical exponential schedule).** $r(x) = \max(2, 2^x)$ is admissible, satisfies $2^x \le r(x)$ everywhere and $r(x)\le 2^x$ for $x\ge 1$. Its weights are $V_0 = 1$, $V_1 = 2$, $V_2 = 8$, $V_3 = 2^8\cdot 8 = 2048$, $V_4 = 2^{2048}\cdot 2048$, and by Corollary 6.3,
$$\tfrac12\log^* n \le K_r(n) \le \log^* n + 1 \qquad\text{for all } n .$$

**Example 9.2 (Pure exponential with an offset).** $r(x) = 2^{x+1}$ is admissible and satisfies $2^x \le r(x)$ everywhere, so $K_r(n) \le \log^* n + 1$ for all $n$.

**Example 9.3 (The polynomial family).** For each $C$, the schedule $\mathrm{poly}\text{-}\mathrm{sched}_C(x) = x^C + 2$ is admissible and monotone, and for $x \ge 3$ satisfies $x^C + 2 \le 3x^C \le x\cdot x^C = x^{C+1}$. Theorem C (with exponent $C+1$ and threshold $3$) gives: for every $C$, the radix height of $\mathrm{poly}\text{-}\mathrm{sched}_C$ is not $O(\log^* n)$. In particular the concrete schedule $s(x) = x^2 + 2$ has $K_s$ not $O(\log^* n)$, even though its weights grow like $V_k \approx V_{k-1}^3$, i.e. doubly exponentially in $k$.

**Example 9.4 (Quasi-polynomial schedules).** $r(x) = 2^{(\log_2 x)^C}$ is far larger than any polynomial, yet its weights satisfy $V_k \le E^{(2)}(M+Ek)$ for suitable constants, so Theorem E applies and $K_r$ is again not $O(\log^* n)$. This example is invisible to Theorem C but immediate from Theorem E — the practical payoff of separating the transfer principle from the polynomial hypothesis.

**Example 9.5 (Fixed base).** $r \equiv b$ with $b \ge 2$ gives $V_k = b^k$, so $K_r(n) = \Theta(\log n)$, spectacularly far from $O(\log^*)$. This is the $h = 1$, $E = b$ case of Theorem E.

---

## 10. Algorithms

Three computational tasks arise naturally and are worth stating explicitly.

**Algorithm 10.1 (Weight tower with saturating arithmetic).** To compute $K_r(n)$ one needs the weights only up to the first one exceeding $n$. Iterating $V \leftarrow r(V)\cdot V$ from $V=1$ and stopping when $V > n$ costs $K_r(n)$ iterations. For fast schedules $K_r(n)$ is at most about $6$ for any $n$ representable in a computer, so the loop is essentially constant time; the cost is dominated by the arithmetic on the last, largest weight. For exponential schedules the intermediate weights can exceed any machine representation, which is harmless if one *saturates*: replace any value exceeding $n$ by a sentinel, since the loop terminates at the first such value.

**Algorithm 10.2 (Iterated logarithm via bit lengths).** $\lfloor \log_2 n\rfloor$ is the bit length of $n$ minus one, so $\log^* n$ is computed by repeatedly replacing $n$ by its bit length minus one until reaching $1$, counting the steps. On integers with $B$ bits this costs $O(\log^* n)$ bit-length queries, i.e. at most six for any realistic input.

**Algorithm 10.3 (Certifying failure of the $O(\log^*)$ bound).** Given a slow schedule and a target constant $c$, Theorem D tells us where to look: at the weights themselves. Compute $V_k$ for increasing $k$, evaluate $R(k) = (k+1)\big/\big(\log^*(V_k)+1\big)$, and report the least $k$ with $R(k) > c$. This produces an explicit witness $n = V_k$ satisfying $c(\log^* n + 1) < K_r(n)$. For $r(x) = x^2+2$ the quantity $\log^*(V_k)$ is $5$ for all $k$ in a very wide range, so $R(k)$ grows essentially linearly and the search terminates at $k \approx 5c$.

---

## 11. Discussion and applications

### 11.1 Three growth scales, one threshold

The subject matter of this paper is the interaction of three growth scales: the tower $T_k$ (height growing with the index), the fixed-height iterated exponential $E^{(h)}(\text{linear})$, and the iterated logarithm $\log^*$ that inverts the first. The results show that the boundary of the $O(\log^*)$ property lies exactly between the first two, and that the schedule's own growth rate matters only through which side of that boundary the induced weight sequence falls on.

This is worth contrasting with intuition. In most asymptotic questions, the polynomial/exponential divide is the salient one. Here it is a red herring: the polynomial hypothesis produces a *doubly exponential* weight sequence, and the theorem is really about the fact that "doubly" is a constant.

### 11.2 Hierarchical scales in physical modelling

Multiscale descriptions — renormalization ladders, adaptive mesh hierarchies, nested unit systems, coarse-graining schemes — are frequently specified by a rule of the form "the next scale factor is a function of the scale reached so far". The radix height is precisely the number of strata needed to cover a given target scale. The theorem says: a coarsening rule that exponentiates the current scale reaches any target in a number of strata bounded by an iterated logarithm plus a constant — at most half a dozen strata for any physically meaningful target. A rule that raises the current scale to a fixed power, however extravagant that power, provably does not enjoy such a bound.

### 11.3 Iterated logarithms in algorithm analysis

$\log^*$ is the characteristic complexity of several algorithmic phenomena: union-find with path compression, certain interval and range structures, deterministic coin-tossing colourings in distributed computing. The present analysis offers an abstract explanation of when this bound can appear: iterated-logarithmic cost is available exactly when the recursion escalates by *exponentiation*, and is destroyed by any escalation of bounded exponential height. Theorem F further shows that the criterion is robust: it is invariant under linear reparametrizations of the recursion depth.

### 11.4 On the strength of the negative statements

The negative results are proved in the strong form "for every $c$ and every $N$ there is a witness $n \ge N$". This rules out the cheap escape in which a bound fails only for finitely many inputs. It also yields explicit witnesses — the weights $V_k$ themselves — which makes the failure computationally exhibitable, as Algorithm 10.3 shows.

### 11.5 Non-vacuity

Two features guarantee that the theory has content. First, $\log^*$ is unbounded ($\log^*(T_j) = j$), so the comparisons are not trivially satisfied. Second, both regimes are populated by explicit schedules: $\max(2, 2^x)$ and $2^{x+1}$ on the fast side, and the entire family $x^C + 2$ on the slow side. No hypothesis set in this paper is empty.

---

## 12. Future directions

**The intermediate zone.** The master transfer principle asks only that $\log^*(V_k)$ be sublinear in $k$, so every schedule whose weights stay inside a *fixed-height* tower falls on the slow side — including quasi-polynomial schedules $r(x) = 2^{(\log_2 x)^C}$ and even $r(x) = 2^{2^{\log_2\log_2 x}}$. A complete map of the intermediate zone would classify the schedules whose weight towers have slowly *growing* height, e.g. $V_k \le E^{(\alpha(k))}(k)$ for $\alpha$ tending to infinity slowly. Theorem F suggests the right question: for which $\alpha$ does $E^{(\alpha(k))}(k)$ dominate $T_{c k}$ for some $c$?

**Second-order refinements.** Corollary 6.3 gives $\tfrac12\log^* n \le K_r(n)\le \log^* n + 1$ for the canonical schedule. Is the true asymptotic constant $1$? A finer analysis of the doubling in Lemma 6.2 should determine the exact leading behaviour, and quantify the loss incurred by non-canonical exponential schedules.

**Non-monotone and randomized schedules.** Theorem F requires nothing of $r$ beyond admissibility, so it applies verbatim to oscillating schedules that alternate between fast and slow phases. A natural question is the *measure-theoretic* one: for a random schedule drawn from a natural distribution over admissible functions, is the tower-tracking condition satisfied almost surely, or almost never? The answer should be governed by the frequency of exponential phases.

**Higher inverses.** Replacing the tower by the Ackermann hierarchy and $\log^*$ by the inverse Ackermann function $\alpha$ should yield an analogous threshold, one level higher: the height is $O(\alpha(n))$ exactly when the weights track the Ackermann diagonal along a linear reparametrization. The proofs here are structurally generic and should transfer.

**Digit-level structure.** This paper studies only the *number* of digits. The distribution of the digits themselves in a self-escalating system — equidistribution, carry statistics, and the complexity of arithmetic in the representation — is untouched and appears to be rich, since the digit alphabet at position $k$ has size $r(V_k)$ that grows towerially.

**Constructive optimality.** Among all admissible schedules with a prescribed budget on $r$, which minimizes the radix height pointwise? Theorem A suggests the answer is essentially $r(x) = 2^x$, but a precise optimality statement — and its analogue when the cost of a digit at position $k$ is weighted by $\log r(V_k)$, i.e. under a total-information constraint — remains open.

---

## 13. Summary

For self-escalating positional systems with weights $V_0 = 1$, $V_{k+1} = r(V_k)V_k$ and representation length $K_r(n) = \min\{k : n < V_k\}$:

1. **Fast side.** $2^x \le r(x)$ beyond a threshold $x_0$ implies $K_r(n) \le x_0 + \log^* n + 1$ for all $n$.
2. **Sharp.** If additionally $r(x)\le 2^x$ for $x \ge 1$, then $\log^* n \le 2K_r(n)$; for $r(x) = \max(2,2^x)$, $K_r(n) = \Theta(\log^* n)$.
3. **Slow side.** Monotone $r$ with $r(x) \le x^C$ implies weights at most $M^{E^k}$ and hence failure of $O(\log^*)$ on arbitrarily large inputs.
4. **Real cause.** Failure follows from sublinearity of $k \mapsto \log^*(V_k)$ alone, hence from *any* fixed-height iterated-exponential bound on the weights. Polynomiality is incidental.
5. **Exact criterion.** $K_r$ is $O(\log^*)$ if and only if $T_k \le V_{c(k+1)}$ for some constant $c$ and all $k$: the weights must track the tower of twos up to a linear reindexing.

