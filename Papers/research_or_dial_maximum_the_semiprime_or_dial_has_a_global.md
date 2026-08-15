# A Global Maximum for the Semiprime OR Dial

### The variational principle $\max_r I\big(N \bmod m ; [E(p) \vee E(q)]\big) = H(3/4) - \tfrac12 H(1/2) = 0.31128\ldots$ bits, with a complete classification of the maximizers

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $N = pq$ be a semiprime whose prime factors are independent and uniformly distributed over the class group $G = (\mathbb{Z}/m)^\times$, and let a *fork event* $E(p)$ occur with a probability depending only on the residue class of $p$, encoded by a **class-rate profile** $r : G \to [0,1]$. We study the mutual information

$$\Phi(r) \;=\; I\big(N \bmod m \,;\, [\,E(p) \vee E(q)\,]\big)$$

between the observable residue class of the semiprime and the OR of the two fork events. We prove a sharp variational principle: for every finite abelian class group and every profile,

$$\Phi(r) \;\le\; g(2) \;=\; H(3/4) - \tfrac12 H(1/2) \;=\; \tfrac32\log 2 - \tfrac34\log 3 \ \text{nats} \;=\; 0.311278\ldots \ \text{bits},$$

and the bound is attained. Three rigidity theorems (the mean no-fork rate must equal $1/2$; the conditional no-fork probabilities must lie in $\{0, 1/2\}$; the profile must be $0/1$-valued) combine into a complete classification: **the maximizers are exactly the indicator functions of cosets of index-two subgroups**, equivalently the profiles $r = (1 + \varepsilon\chi)/2$ with $\chi$ a nontrivial $\pm1$-valued character and $\varepsilon = \pm 1$. Quadratic-character kernels and their complements, and nothing else, reach the cap. Subgroup kernels of index $n \ne 2$ are strictly below it, and a class group of odd order — carrying no quadratic character — never attains it.

The framework subsumes the closed-form laws of the individual channels: the AND companion law $\Phi_{\mathrm{AND}}(n) = H(n^{-2}) - n^{-1}H(n^{-1})$ and the order-$n$ OR law $g(n)$, both maximized at $n = 2$. We further extend the cap beyond semiprimes: for $k$-almost primes with $k \ge 2$ factors, $\Phi_k \le g(2)$ always, and for $k \ge 3$ there is a uniform gap $\Phi_k \le g(2) - 1/500$, so the cap is attained in the semiprime regime alone; along the extremal quadratic kernels the exact value $\Phi_k = H(2^{-k}) - \frac12 H(2^{-(k-1)})$ decays like $2^{-k}$. Finally, the XOR variant of a quadratic kernel event is a *deterministic function of $N$*, carrying a full bit of mutual information while being computable from $N$ alone — a sharp demonstration that raw mutual information with $N \bmod m$ is not a measure of factorization information.

**Keywords:** semiprime, quadratic character, mutual information, binary entropy, variational principle, group convolution, factorization obstruction.

---

## 1. Introduction

### 1.1 The residue dial

A recurring theme in the analytic study of factoring is the *residue dial*: one attempts to extract information about the prime factors of $N$ from events that are governed by the residue classes of those factors. The prototype is splitting behaviour in a number field. If $K/\mathbb{Q}$ is abelian of conductor $m$, then whether a prime $p$ splits in $K$ depends only on $p \bmod m$; the ancient case is $K = \mathbb{Q}(\sqrt{d})$, where splitting is governed by a Legendre or Kronecker symbol, and the classical reciprocity laws let one evaluate the symbol without knowing anything else about $p$.

Suppose now that one has access, for a semiprime $N = pq$, to a single aggregated bit about such events at the two unknown factors — for definiteness, the OR:

$$B = [\,E(p) \ \text{or} \ E(q)\,].$$

An adversary who knows $N$ knows $N \bmod m$. The natural quantitative question is: **how much does $B$ tell that adversary that they did not already know?** In information-theoretic terms, what is $I(N \bmod m ; B)$, and how large can it be made by choosing the underlying event well?

Individual channels have been measured. A quadratic splitting event yields about $0.31$ bits; a cubic (order-three) event about $0.073$; a quartic about $0.036$; a genuinely fractional profile coming from an $S_3$ cubic yields about $0.12$. The purpose of this paper is to replace the list of measurements by a theorem: to determine the exact maximum of the channel over *all* profiles on *all* class groups, to prove it is attained, and to classify the optima.

### 1.2 Results

Let $G$ be a finite abelian group (the intended example is $G = (\mathbb{Z}/m)^\times$), $r : G \to [0,1]$ a class-rate profile, $s = 1 - r$ the complementary *no-fork* profile, $\mu = \operatorname{avg} s$ its mean, and $H$ the binary entropy. The main results are:

* **(Global cap, Theorem 4.1.)** $\Phi(r) \le g(2) := H(1/4) - \frac12 H(1/2) = H(3/4) - \frac12$ for every $G$ and every $r$; in bits, $0.3111 < g(2) < 0.3114$.
* **(Attainment, Theorem 5.1.)** If $G$ has a subgroup $K$ of index two, the profile $r = \mathbb{1}_K$ attains the cap exactly, and $\Phi$ has a genuine greatest value on the set of all profiles.
* **(Rigidity, Theorems 6.1–6.3.)** A maximizer has $\mu = 1/2$; its conditional no-fork probabilities take only the values $0$ and $1/2$; and it is $0/1$-valued.
* **(Classification, Theorem 6.4 and Corollary 6.5.)** $\Phi(r) = g(2)$ if and only if $r$ is the indicator of a coset of an index-two subgroup; equivalently $r = (1 + \varepsilon\chi)/2$ with $\chi$ a nontrivial $\pm 1$-valued character and $\varepsilon \in \{\pm 1\}$.
* **(Strictness and obstruction, Theorems 7.3 and 7.4.)** Subgroup kernels of index $\neq 2$ are strictly below the cap, and no profile on a class group of odd order attains it.
* **(Multi-prime cap, Theorems 8.2–8.4.)** For $k$-almost primes, $\Phi_k \le g(2)$ for all $k \ge 2$, with the uniform improvement $\Phi_k \le g(2) - 1/500$ for $k \ge 3$; index-$d$ kernels give exactly $H(d^{-k}) - d^{-1}H(d^{-(k-1)})$.
* **(Factor-uselessness, Theorem 9.1.)** For an index-two kernel, $E(p) \oplus E(q)$ holds if and only if $N \notin K$: the XOR bit is determined by $N$.

### 1.3 Method

The proof has a group-theoretic half and an analytic half, joined by concavity.

The group-theoretic half is a *counting identity*: conditioning on $N \equiv c$ makes the factor pair uniform over $\{(a, ca^{-1}) : a \in G\}$, so the conditional no-fork probability is the convolution $f = s * s$. From this we extract a **window law** $\max(0, 2\mu-1) \le f(c) \le \mu$ and a **mean law** $\operatorname{avg} f = \mu^2$.

The analytic half exploits concavity of $H$: over an interval $[L,U]$ with prescribed mean, the average of $H \circ f$ is minimized when $f$ is supported on the endpoints, and the chord of $H$ across $[L,U]$ gives the bound. This reduces the optimization over $[0,1]^{|G|}$ to two sharp one-variable inequalities in $\mu$, each with equality precisely at $\mu = 1/2$. The classification then comes from tracing the equality conditions back through the chord bound to the convolution.

---

## 2. Setup and definitions

Throughout, $G$ is a finite abelian group written multiplicatively, $|G| = \operatorname{card} G$, and for $F : G \to \mathbb{R}$ we write

$$\operatorname{avg} F = \frac{1}{|G|}\sum_{a \in G} F(a).$$

We use natural logarithms internally; the binary entropy is $H(x) = -x\log x - (1-x)\log(1-x)$ in *nats*, with $H(0) = H(1) = 0$, and all displayed "bits" values are the nat values divided by $\log 2$. We record $H(1/2) = \log 2$ and $H(1/4) = H(3/4) = 2\log 2 - \frac34\log 3$; the exact combination we need is isolated in Definition 2.4.

**Definition 2.1 (Class-rate profile).** A *class-rate profile* is a function $r : G \to [0,1]$. Its interpretation: a prime $p$ whose class is $c$ triggers the fork event $E(p)$ with probability $r(c)$, independently across primes. The *no-fork profile* is $s = 1 - r$, and $\mu := \operatorname{avg} s$ is the *mean no-fork rate*.

**Definition 2.2 (Conditional no-fork probability).** For a no-fork profile $s$,

$$f_s(c) \;:=\; \operatorname{avg}_a\big[\,s(a)\, s(c a^{-1})\,\big] \;=\; (s * s)(c).$$

**Lemma 2.3 (Counting identity).** *If $p, q$ are independent and uniform on $G$ and $N = pq$, then conditional on $N = c$ the pair $(p,q)$ is uniform on $\{(a, ca^{-1}) : a \in G\}$, and consequently*

$$\Pr\big[\neg E(p) \wedge \neg E(q) \mid N = c\big] = f_s(c), \qquad \Pr\big[E(p)\vee E(q) \mid N = c\big] = 1 - f_s(c).$$

*Proof.* The map $a \mapsto (a, ca^{-1})$ is a bijection from $G$ onto the set of ordered pairs with product $c$, and the joint law of $(p,q)$ is uniform on $G \times G$, hence uniform on each product fibre. Independence of the fork events given the classes gives the product $s(a)s(ca^{-1})$, and averaging over the fibre gives $f_s(c)$. $\square$

**Definition 2.4 (The OR dial and the cap).** The *dial* of the profile is

$$\Phi(s) \;:=\; H(\mu^2) \;-\; \operatorname{avg}_c H\big(f_s(c)\big), \qquad \mu = \operatorname{avg} s .$$

The *cap constant* is

$$g(2) \;:=\; H(1/4) - \tfrac12 \log 2 \;=\; \tfrac32\log 2 - \tfrac34 \log 3 \ \text{nats}.$$

**Remark 2.5 (Why $\Phi$ is the mutual information).** Since $N \bmod m$ is uniform on $G$ (as $p,q$ are) and, unconditionally, $\Pr[\neg E(p)\wedge\neg E(q)] = \mu^2$, the entropy of the OR bit is $H(\mu^2)$ (using $H(x) = H(1-x)$), while its conditional entropy given the class is $\operatorname{avg}_c H(f_s(c))$. Hence $\Phi = H(B) - H(B \mid N) = I(N; B)$ exactly. In particular $\Phi \ge 0$, by concavity of $H$ together with the mean law below.

**Remark 2.6 (OR/AND duality).** Writing $\mathrm{AND}$ for the event $E(p) \wedge E(q)$, the same computation with $r$ in place of $s$ gives $I(N; \mathrm{AND}) = \Phi(r)$. Thus the AND channel of a profile is the OR channel of its complement, and every statement below about $\Phi$ applies verbatim to both. In particular the cap holds for the AND channel too.

**Numerical value.** In bits, $g(2) = 0.3112781\ldots$. A rigorous sandwich: from $3^{12} = 531441 = 2^{19}\cdot(1 + 7153/524288)$ one gets $\frac{19\log 2 + 7153/531441}{12} \le \log 3 \le \frac{19\log 2 + 7153/524288}{12}$, whence $0.2157 < g(2) < 0.2158$ nats and $0.3111 < g(2)/\log 2 < 0.3114$ bits.

---

## 3. The window law and the mean law

**Theorem 3.1 (Window law).** *Let $s : G \to [0,1]$ with mean $\mu$. Then for every $c \in G$,*

$$\max(0,\ 2\mu - 1) \;\le\; f_s(c) \;\le\; \mu .$$

*Proof.* Upper bound: $s(ca^{-1}) \le 1$ gives $s(a)s(ca^{-1}) \le s(a)$ pointwise, and averaging gives $f_s(c) \le \operatorname{avg} s = \mu$. Lower bound: on $[0,1]^2$ one has $xy \ge x + y - 1$ (equivalently $(1-x)(1-y)\ge 0$), so $s(a)s(ca^{-1}) \ge s(a) + s(ca^{-1}) - 1$; averaging over $a$ and using invariance of the average under the involution $a \mapsto ca^{-1}$ gives $f_s(c) \ge 2\mu - 1$. Nonnegativity is immediate. $\square$

**Theorem 3.2 (Mean law).** *$\operatorname{avg}_c f_s(c) = \mu^2$.*

*Proof.* $\operatorname{avg}_c \operatorname{avg}_a s(a)s(ca^{-1}) = \operatorname{avg}_a s(a)\operatorname{avg}_c s(ca^{-1}) = \operatorname{avg}_a s(a) \cdot \mu = \mu^2$, using Fubini for finite sums and the translation invariance $\operatorname{avg}_c F(ca^{-1}) = \operatorname{avg} F$. $\square$

These two facts are the only structural input needed. Everything else is one-variable analysis.

**Degenerate cases.** If $\mu = 0$ then $f_s \equiv 0$ and $\Phi = 0$: the OR event is certain. If $\mu = 1$ then $s \equiv 1$, $f_s \equiv 1$ and $\Phi = 0$: the OR event is impossible. Both are strictly below the cap, so we may assume $0 < \mu < 1$ henceforth.

---

## 4. The cap

**Lemma 4.1 (Chord bound).** *Let $0 \le L < U \le 1$ and $x \in [L,U]$. Then*

$$\frac{(U-x)H(L) + (x-L)H(U)}{U - L} \;\le\; H(x).$$

*Proof.* $H$ is concave on $[0,1]$; write $x$ as the convex combination $\lambda L + (1-\lambda)U$ with $\lambda = (U-x)/(U-L)$ and apply concavity. $\square$

Averaging Lemma 4.1 over $c$ with $x = f_s(c)$ and using the mean law replaces the unknown quantity $\operatorname{avg}_c H(f_s(c))$ by an explicit function of $\mu$ alone. Two regimes arise from the window law.

**Proposition 4.2 (Low regime).** *If $0 < \mu \le 1/2$, then $\Phi(s) \le H(\mu^2) - \mu H(\mu)$.*

*Proof.* The window is $[L,U] = [0,\mu]$. The chord bound gives $H(f_s(c)) \ge \frac{f_s(c)}{\mu}H(\mu)$ for each $c$; averaging and using $\operatorname{avg} f_s = \mu^2$ gives $\operatorname{avg}_c H(f_s(c)) \ge \mu H(\mu)$. Subtract from $H(\mu^2)$. $\square$

**Proposition 4.3 (High regime).** *If $1/2 \le \mu < 1$, then $\Phi(s) \le H(\mu^2) - \big(\mu H(2\mu-1) + (1-\mu)H(\mu)\big)$.*

*Proof.* The window is $[L,U] = [2\mu-1, \mu]$ of length $1-\mu$. The chord bound gives
$H(f_s(c)) \ge \frac{(\mu - f_s(c))H(2\mu-1) + (f_s(c) - 2\mu + 1)H(\mu)}{1-\mu}$; averaging and substituting $\operatorname{avg} f_s = \mu^2$ yields, after simplification, $\operatorname{avg}_c H(f_s(c)) \ge \mu H(2\mu-1) + (1-\mu)H(\mu)$. $\square$

It remains to bound the two one-variable functions.

**Lemma 4.4 (Left branch).** *For $0 < \mu \le 1/2$, $\;H(\mu^2) - \mu H(\mu) \le g(2)$, with equality iff $\mu = 1/2$.*

*Proof sketch.* Expanding entropies and factoring $1-\mu^2 = (1-\mu)(1+\mu)$ turns the left side into
$$-\mu^2\log\mu - (1-\mu)\log(1-\mu) - (1-\mu^2)\log(1+\mu).$$
Each term is estimated by the tangent-line inequality $x\log a + x - a \le x\log x$ (valid for $a, x > 0$, and an equality at $x = a$), applied at base points chosen so that all three become equalities simultaneously at $\mu = 1/2$: namely $a = 1/2$ for the terms in $\mu$ and $1-\mu$, and $a = 3/2$ for the term in $1+\mu$. Summing gives $H(\mu^2)-\mu H(\mu) \le g(2) - (\tfrac12-\mu)\big(\mu + \tfrac12)\log 3 - \log 2\big)$, and the correction term is strictly positive for $\mu < 1/2$ because $\log 3 > \frac32\log 2$. For very small $\mu$ (say $\mu \le 1/4$) the same tangent inequality at $a = 1$ gives a cruder bound with room to spare. $\square$

**Lemma 4.5 (Right branch).** *For $1/2 \le \mu < 1$, $\;H(\mu^2) - \big(\mu H(2\mu-1) + (1-\mu)H(\mu)\big) \le g(2)$, with equality iff $\mu = 1/2$.*

*Proof sketch.* After expansion the left side equals
$$(\mu - 3\mu^2)\log\mu - (1-\mu^2)\log(1+\mu) + \mu(2\mu-1)\log(2\mu-1) + 2\mu(1-\mu)\log 2 .$$
For $1/2 \le \mu \le 4/5$ one again uses tangent lines based at $1/2$ and $3/2$ together with $\log x \le x-1$ for the $\log(2\mu-1)$ term; the residual is $(2\mu-1)Q(\mu)$ with $Q$ positive on the range, giving strict inequality off $\mu = 1/2$. For $4/5 \le \mu < 1$ all logarithms are estimated at base points $1$ and $2$, and the whole expression collapses to $(1-\mu)^2(4\mu - \log 2) \le \frac{4}{25} < g(2)$. $\square$

**Theorem 4.6 (Global cap).** *For every finite abelian $G$ and every profile $r : G \to [0,1]$,*

$$\Phi(r) \;\le\; g(2) \;=\; H(3/4) - \tfrac12 H(1/2) \;=\; 0.311278\ldots\ \text{bits}.$$

*Proof.* Combine the degenerate cases with Propositions 4.2–4.3 and Lemmas 4.4–4.5. $\square$

By Remark 2.6 the same bound holds for the AND channel.

---

## 5. Attainment: the quadratic-character kernels

**Definition 5.1.** For a subgroup $K \le G$ let $\mathbb{1}_K$ be its indicator, the *kernel profile*. Its mean is $\operatorname{avg}\mathbb{1}_K = 1/[G:K]$.

**Lemma 5.2 (Convolution of a kernel profile).** *If $[G:K] = n$ then $f_{\mathbb{1}_K} = \frac1n \mathbb{1}_K$: the conditional no-fork probability is $1/n$ on $K$ and $0$ off $K$.*

*Proof.* $f(c) = \operatorname{avg}_a \mathbb{1}_K(a)\mathbb{1}_K(ca^{-1})$. The product is nonzero only if $a \in K$ and $c \in aK = K$; so $f(c) = 0$ for $c \notin K$, and for $c \in K$ it equals $|K|/|G| = 1/n$. $\square$

**Theorem 5.3 (Subgroup law).** *For a subgroup $K$ of index $n$,*

$$\Phi(\mathbb{1}_K) \;=\; H\!\left(\frac{1}{n^2}\right) - \frac1n H\!\left(\frac1n\right).$$

*Proof.* $\mu = 1/n$, so the first term is $H(1/n^2)$. By Lemma 5.2, $H(f(c))$ equals $H(1/n)$ on $K$ and $0$ elsewhere, and $K$ has density $1/n$. $\square$

Interpreted through Remark 2.6 this is exactly the **AND companion law** $\Phi_{\mathrm{AND}}(n) = H(n^{-2}) - n^{-1}H(n^{-1})$ for the order-$n$ character event.

**Theorem 5.4 (Attainment).** *If $[G:K] = 2$ then $\Phi(\mathbb{1}_K) = g(2)$. Consequently, on any class group possessing an index-two subgroup, $g(2)$ is the greatest value of the dial over all profiles.*

*Proof.* Put $n = 2$ in Theorem 5.3: $H(1/4) - \frac12 H(1/2) = g(2)$ by definition. Greatestness follows from Theorem 4.6. $\square$

**Corollary 5.5 (Marginal at the optimum).** *At a maximizer the OR event has unconditional probability $1 - \mu^2 = 3/4$.*

**Theorem 5.6 (Arithmetic realizations).** *For every odd prime $p$, the group $(\mathbb{Z}/p)^\times$ is cyclic of even order and its subgroup of squares has index two; hence the dial on $(\mathbb{Z}/p)^\times$ has greatest value $g(2)$, attained by the Legendre-symbol (quadratic residue) kernel. The same holds for the conductor $m = 4$, where $(\mathbb{Z}/4)^\times \cong C_2$ and the trivial subgroup has index two.*

*Proof.* In a finite cyclic group $\langle g\rangle$ of even order, $\langle g^2\rangle$ is the subgroup of squares and has index two; for $(\mathbb{Z}/p)^\times$ this is the quadratic residue subgroup. Apply Theorem 5.4. $\square$

Concretely: the splitting events for $\mathbb{Q}(\sqrt5)$ at $m=5$, $\mathbb{Q}(i)$ at $m=4$, $\mathbb{Q}(\sqrt{-11})$ at $m=11$, and the Kronecker symbol $(8\mid p)$ at $m = 8$ (whose class group $C_2\times C_2$ is *not* cyclic, and carries three distinct index-two kernels) all sit exactly at $0.3113$ bits with $\Pr[\mathrm{OR}] = 3/4$.

---

## 6. Rigidity and the complete classification

**Theorem 6.1 (First rigidity: the mean is forced).** *If $\mu \ne 1/2$ then $\Phi(s) < g(2)$. Hence any maximizer has $\mu = 1/2$.*

*Proof.* Immediate from the strict versions of Lemmas 4.4 and 4.5 together with the degenerate cases. $\square$

**Theorem 6.2 (Second rigidity: two-valued conditionals).** *If $\Phi(s) = g(2)$ then for every class $c$, $f_s(c) \in \{0, 1/2\}$.*

*Proof.* By Theorem 6.1, $\mu = 1/2$, so the window is $[0,1/2]$ and $H(f_s(c)) \ge 2\log 2\, f_s(c)$ (the chord through $(0,0)$ and $(1/2,\log 2)$), with equality *iff* $f_s(c) \in \{0,1/2\}$ by strict concavity. Averaging and using $\operatorname{avg} f_s = 1/4$ gives $\operatorname{avg}_c H(f_s) \ge \frac12\log 2$, i.e. $\Phi \le H(1/4) - \frac12\log 2 = g(2)$. Equality forces the nonnegative deficiency function $c \mapsto H(f_s(c)) - 2\log 2\,f_s(c)$ to have zero average, hence to vanish identically. $\square$

**Theorem 6.3 (Third rigidity: the profile is deterministic).** *If $\Phi(s) = g(2)$ then $s$ takes only the values $0$ and $1$.*

*Proof sketch.* Let $c$ be a class with $f_s(c) = \mu = 1/2$; such a $c$ exists because $f_s$ has average $\mu^2$ and, by Theorem 6.2, its values are in $\{0,\mu\}$, and $f_s \not\equiv 0$ since $\mu > 0$. Equality in the pointwise estimate $s(a)s(ca^{-1}) \le s(a)$ used for the window bound, after averaging, forces $s(a)\big(1 - s(ca^{-1})\big) = 0$ for every $a$. Thus for each $a$ either $s(a) = 0$ or $s(ca^{-1}) = 1$; applying the same relation at the partner index $ca^{-1}$ and using the involution $a \mapsto ca^{-1}$ propagates the value $1$ back to $a$. Hence every value of $s$ is $0$ or $1$. $\square$

Thus a maximizer is the indicator $\mathbb{1}_A$ of a subset $A \subseteq G$ with $|A| = |G|/2$ (mean $1/2$). Write $R_A(c) = \#\{a \in A : ca^{-1} \in A\}$ for the representation count, so $f_{\mathbb{1}_A}(c) = R_A(c)/|G|$. Theorem 6.2 says $R_A(c) \in \{0, |G|/2\}$ for all $c$, while $\sum_c R_A(c) = |A|^2 = |G|^2/4$; hence $R_A$ takes the value $|G|/2$ on exactly $|G|/2$ classes and $0$ on the rest.

**Theorem 6.4 (Classification).** *A profile $s : G \to [0,1]$ satisfies $\Phi(s) = g(2)$ if and only if there exist a subgroup $K \le G$ of index two and $x \in G$ with $s = \mathbb{1}_{xK}$: the maximizers are exactly the indicators of cosets of index-two subgroups.*

*Proof sketch.* ($\Leftarrow$) The dial is invariant under translation of the profile, $\Phi(s(x^{-1}\cdot)) = \Phi(s)$, because $f_{s(x^{-1}\cdot)}(c) = f_s(x^{-2}c)$ and averaging over $c$ is translation invariant. Hence a coset indicator has the same dial as the kernel indicator, namely $g(2)$ by Theorem 5.4.

($\Rightarrow$) Let $s = \mathbb{1}_A$ as above, and let $D = \{c : R_A(c) = |G|/2\}$, a set of size $|G|/2$. For $c \in D$ the condition $R_A(c) = |A|$ says precisely $cA^{-1} = A$, i.e. $c \in \mathrm{Stab}(A) := \{g : gA = A\}$ once one notes $A^{-1}$ may be replaced by $A$ after fixing a base point; carrying this out, one shows the stabilizer subgroup $K_0 = \mathrm{Stab}(A)$ has $|K_0| \ge |A| = |G|/2$, so $K_0$ has index one or two, and $A$ is a union of $K_0$-cosets of total size $|G|/2$. Index one would force $A = G$, contradicting $|A| = |G|/2 < |G|$; hence $[G:K_0] = 2$ and $A$ is a single coset. $\square$

**Corollary 6.5 (Character form).** *$\Phi(s) = g(2)$ if and only if $s = \dfrac{1 + \varepsilon\chi}{2}$ for some homomorphism $\chi : G \to \{\pm 1\}$ that is not identically $1$, and some sign $\varepsilon \in \{\pm 1\}$.*

*Proof.* Given $K$ of index two, the map $\chi_K(a) = 1$ if $a \in K$ and $-1$ otherwise is a homomorphism (index two implies $K$ is normal and $G/K \cong \{\pm 1\}$), and $\mathbb{1}_{xK} = (1 + \chi_K(x)\chi_K)/2$. Conversely, the kernel of a nontrivial $\pm1$-valued character has index two, and $(1+\varepsilon\chi)/2$ is the indicator of the coset on which $\chi = \varepsilon$. $\square$

On $(\mathbb{Z}/m)^\times$ the nontrivial $\pm1$-valued characters are exactly the quadratic (Kronecker) characters of conductor dividing $m$. So: **the maximizing fork events are precisely the quadratic-residue events and their complements.**

---

## 7. The ladder of order-$n$ events, and two obstructions

Theorem 5.3 gives the exact value for every subgroup kernel. Two derived families are worth recording explicitly.

**The AND law.** For the order-$n$ event "$p \in K$" with $[G:K] = n$, the AND channel reads
$$\Phi_{\mathrm{AND}}(n) = H(n^{-2}) - n^{-1}H(n^{-1}) : \quad 0.311278,\ 0.197160,\ 0.134471,\ 0.097907,\ \ldots \ \text{bits for } n = 2,3,4,5.$$

**The OR law.** For the same event, the OR channel corresponds to the complementary no-fork profile $s = \mathbb{1}_{G\setminus K}$, with $\mu = (n-1)/n$. A direct count gives $f_s(c) = (n-1)/n$ for $c \in K$ and $(n-2)/n$ otherwise, whence

$$g(n) \;=\; H\!\left(\Big(\frac{n-1}{n}\Big)^{\!2}\right) - \left[\frac1n H\!\left(\frac{n-1}{n}\right) + \frac{n-1}{n}H\!\left(\frac{n-2}{n}\right)\right],$$

reading $g(2) = 0.311278$, $g(3) = 0.072780$, $g(4) = 0.035880$, $g(5) = 0.021537$ bits. Realizations: the cyclic cubic field of conductor $7$ gives $g(3)$; $\mathbb{Q}(\zeta_5)$ gives $g(4)$; every imaginary or real quadratic field gives $g(2)$.

**Theorem 7.1 (The AND law is capped).** *For every integer $n \ge 2$, $H(n^{-2}) - n^{-1}H(n^{-1}) \le g(2)$.*

*Proof.* This is the left-branch inequality (Lemma 4.4) at $\mu = 1/n \le 1/2$. $\square$

**Theorem 7.2 (Strictness off index two).** *If $[G:K] \ne 2$ then $\Phi(\mathbb{1}_K) < g(2)$.*

*Proof.* The mean is $1/[G:K] \ne 1/2$; apply Theorem 6.1. $\square$

**Theorem 7.3 (Odd-order obstruction).** *If $|G|$ is odd, then no profile on $G$ attains the cap: $\Phi(s) < g(2)$ for all $s$.*

*Proof.* By Theorem 6.4 a maximizer would yield a subgroup of index two, whose index divides $|G|$ — impossible for $|G|$ odd. $\square$

Thus, for instance, no fork event whatsoever, however cleverly designed, reaches the cap on a class group of order $9$ or $27$; the possibility of a quadratic character is a purely arithmetic prerequisite.

---

## 8. Beyond semiprimes: the multi-prime dial

Let $N = p_1p_2\cdots p_k$ with the $p_i$ independent and uniform on $G$, and consider the OR of all $k$ fork events. Conditioning on the product class replaces $s * s$ by the $k$-fold convolution.

**Definition 8.1.** For $s : G \to [0,1]$ set $s^{*1} = s$ and $s^{*(j+1)} = s^{*j} * s$, where $(t*s)(c) = \operatorname{avg}_a t(a)s(ca^{-1})$. The *$k$-prime dial* is

$$\Phi_k(s) \;=\; H(\mu^{k}) - \operatorname{avg}_c H\big(s^{*k}(c)\big), \qquad \mu = \operatorname{avg} s,$$

so that $\Phi_2 = \Phi$.

**Lemma 8.2 (Multi-prime mean and window).** *$\operatorname{avg}_c s^{*k}(c) = \mu^{k}$ and $0 \le s^{*k}(c) \le \mu^{k-1}$ for every $c$.*

*Proof.* The mean law follows from $\operatorname{avg}(t*s) = (\operatorname{avg} t)(\operatorname{avg} s)$ by induction. For the window, $(t*s)(c) \le \operatorname{avg} t$ whenever $0 \le s \le 1$, so by induction $s^{*k} \le \operatorname{avg} s^{*(k-1)} = \mu^{k-1}$. $\square$

**Lemma 8.3 (Analytic core).** *For $0 \le \mu \le 1$ and $0 \le x \le \mu^2$,*

$$H(\mu x) - \mu H(x) \;\le\; g(2),$$

*and if moreover $x \le \mu^{3}$ then $H(\mu x) - \mu H(x) \le g(2) - 1/500$.*

*Proof sketch.* For $\mu \le 1/2$ one bounds $H(\mu x) \le H(\mu)\cdot$(a linear factor) using tangent lines at $2/3$, $3/4$ and $8/9$ for the entropy, and the elementary comparison $-x\log x \le H(x) \le -x\log x + x$; the resulting one-variable estimate is monotone and maximized at the boundary. For $\mu \ge 1/2$ the function $x \mapsto H(\mu x) - \mu H(x)$ is shown to be monotone increasing on $[0,\mu^2]$ by differentiating (the derivative is $\mu\log\frac{1-\mu x}{\mu x} - \mu\log\frac{1-x}{x} \ge 0$ for $x \le 1/2$), so the maximum over the admissible range is at $x = \mu^2$, where the value is $H(\mu^3)-\mu H(\mu^2)$ — the semiprime bound with an extra factor of $\mu$, itself below $g(2)$ with room to spare. The quantitative version tracks the slack, which is bounded below by $1/500$ once $x \le \mu^3$. $\square$

**Theorem 8.4 (Multi-prime cap).** *For every finite abelian $G$, every profile and every $k \ge 2$,*

$$\Phi_k(s) \;\le\; g(2).$$

*Moreover, for $k \ge 3$,*

$$\Phi_k(s) \;\le\; g(2) - \frac{1}{500} \;<\; g(2),$$

*uniformly in the profile, the group and $k$.*

*Proof.* Applying the chord bound on the window $[0, \mu^{k-1}]$ with mean $\mu^{k}$ gives $\operatorname{avg}_c H(s^{*k}) \ge \mu\,H(\mu^{k-1})$, so $\Phi_k \le H(\mu \cdot \mu^{k-1}) - \mu H(\mu^{k-1})$, which is of the form $H(\mu x) - \mu H(x)$ with $x = \mu^{k-1} \le \mu^2$ for $k \ge 3$ (and $x = \mu$ for $k=2$, which is the semiprime case treated in §4). Lemma 8.3 finishes both statements. $\square$

**Theorem 8.5 (Multi-prime subgroup law).** *For $[G:K] = d$ and $k$ prime factors,*

$$\Phi_k(\mathbb{1}_K) \;=\; H\big(d^{-k}\big) - \frac1d H\big(d^{-(k-1)}\big).$$

*Proof.* By induction, $\mathbb{1}_K^{*k} = d^{-(k-1)}\mathbb{1}_K$; the computation is then as in Theorem 5.3. $\square$

**Corollary 8.6 (Geometric decay along the extremals).** *For $d = 2$, $\Phi_k = H(2^{-k}) - \frac12 H(2^{-(k-1)})$, equal to $g(2)$ at $k = 2$ and bounded by $(1+\log 2)2^{-k}$ for $k \ge 3$: numerically $0.1379$ bits at $k = 3$, $0.065508$ at $k=4$, $0.031977$ at $k = 5$.*

So the cap $g(2)$ is a genuinely *semiprime* phenomenon. Adding prime factors makes the OR event nearly certain, and near-certain events carry almost no information.

---

## 9. Factor-uselessness: why a bigger dial reading is not better

**Theorem 9.1 (XOR is determined by the product).** *Let $K \le G$ have index two and let the fork event be $E(p) = [p \in K]$. Then for all $p,q$,*

$$E(p) \oplus E(q) \iff pq \notin K .$$

*Proof.* With $\chi = \chi_K$ the associated $\pm1$-character, $E(p)\oplus E(q)$ holds iff $\chi(p)\chi(q) = -1$, i.e. $\chi(pq) = -1$, i.e. $pq \notin K$. (A direct coset argument avoiding characters: pick $a \notin K$; then $G = K \sqcup aK$ and $a^2 \in K$, and one checks the four cases.) $\square$

**Corollary 9.2.** *The XOR channel of a quadratic kernel event has $I(N \bmod m; \mathrm{XOR}) = 1$ bit exactly, and this bit is computable from $N$ alone.*

This is the crux of the matter. Mutual information with $N \bmod m$ measures *correlation with a quantity the observer already possesses*, not knowledge of the factorization. The XOR channel maximizes that correlation trivially — it is a function of $N$ — and provides no assistance whatsoever in recovering $p$ and $q$. The same phenomenon, in weaker form, explains the OR maximum: what the extremal quadratic profile achieves is a clean split of classes into "OR certain" ($\chi(N) = -1$: the factors lie in different cosets, so exactly one forks — the OR is forced) and "OR a fair coin" ($\chi(N) = +1$). The dial reading is entirely a function of $\chi(N)$, which reciprocity makes free.

Consequently: the cap theorem should be read as a *structural closure* of this line of attack. Any fork event of residue type, on any modulus, aggregated by OR (or AND) over the factors of a semiprime, leaks at most $0.3113$ bits about $N \bmod m$ — and the profiles that leak the most leak information that is already public. Meanwhile the genuinely "which factor is which" content of such channels is smaller still; for the $S_3$ cubic example below, direct estimation puts the *which-factor* component at roughly $0.002$ bits.

---

## 10. Computation

Three algorithms suffice to reproduce every numeric claim in this paper.

**(A) Exact dial evaluation.** Given a modulus $m$ and a profile $s$ on $(\mathbb{Z}/m)^\times$, compute $f(c) = \frac{1}{\varphi}\sum_a s(a)s(ca^{-1})$ for all $c$ (cost $O(\varphi^2)$), then $\Phi = H(\mu^2) - \frac1\varphi\sum_c H(f(c))$. All arithmetic is exact rational if $s$ is rational; entropies are evaluated in double precision.

**(B) Exhaustive $0/1$ enumeration.** By Theorem 6.3 the maximum over all profiles equals the maximum over $0/1$ profiles, of which there are $2^\varphi$. Enumerating all of them for
$$m \in \{3,4,5,7,8,9,11,16,21\}$$
— covering prime and composite conductors and unit groups $C_2$, $C_4$, $C_6$, $C_{10}$, $C_2\times C_2$, $C_2\times C_4$, $C_2 \times C_6$ — the maximum is $0.311278$ bits on every one of them, and the argmax set consists exactly of the coset indicators of index-two subgroups: two for each index-two subgroup, so six profiles for $m = 8$, $16$ and $21$ (three quadratic characters each) and two for the cyclic cases. No profile anywhere exceeds the cap. Every subgroup-kernel profile reproduces $H(n^{-2}) - n^{-1}H(n^{-1})$ to $10^{-9}$.

**(C) Continuous coordinate ascent.** Optimizing $\Phi$ over the cube $[0,1]^\varphi$ by cyclic one-coordinate maximization from random starts (e.g. $m = 7, 11, 16$) converges to $0.311278$ and never exceeds it, in agreement with Theorem 4.6 — and the limit points are always $0/1$-valued, in agreement with Theorem 6.3.

A worked variable-profile example: the cubic $x^3 + x + 1$ has Galois group $S_3$; taking modulus $31$ and a profile with per-class identity rates in the range $0.287$–$0.349$ on the quadratic residues and $1.0$ on the non-residues, the exact dial evaluation gives $\Phi \approx 0.1230$ bits, comfortably below the cap, in line with Theorem 6.3 (a fractional profile can never be extremal).

---

## 11. Discussion

**A single number closes a family of channels.** Before the variational principle one had a heterogeneous collection of measured channels; now one has a theorem stating that the supremum over *all* of them is $H(3/4) - \frac12 H(1/2)$, attained precisely on the quadratic locus. Every previously computed value is an instance: the quadratic channels are the maximizers; the order-$n$ channels are the subgroup kernels, obeying the exact ladder $g(n)$ and $\Phi_{\mathrm{AND}}(n)$; the variable $S_3$ profile is a non-extremal interior point.

**Why $3/4$?** The extremal marginal $\Pr[\mathrm{OR}] = 3/4$ has a transparent cause. For an index-two event, "no fork" needs both factors in the complement of $K$, an event of probability $1/2 \cdot 1/2$. The optimum trades off two competing effects: making the OR event rarer raises its unconditional entropy but also makes the class-conditional distributions more extreme. The optimum $\mu = 1/2$, forced by Theorem 6.1, is the unique balance point, and the value $H(1/4) - \frac12 H(1/2)$ is what it buys.

**Structural symmetries.** The dial is invariant under (i) translation of the profile by a group element, (ii) complementation $s \mapsto 1-s$ at the level of OR/AND duality, and (iii) group automorphisms of $G$. Together with the classification these explain the observed degeneracies — that a character event and its complement give identical readings, and that the AND transform of a maximizer is again a maximizer.

**Information is not knowledge.** The XOR result is the cleanest available refutation of the naive identification of mutual information with cryptanalytic value: a full bit, exactly, of mutual information with $N \bmod m$, and zero factoring content, because the bit is a function of $N$. Any future attempt to convert residue-type channels into a factoring advantage must therefore measure a *conditional* quantity — information about the unordered pair $\{p,q\}$ given $N$ — rather than raw correlation with $N$.

**Limits of the model.** We assume the two (or $k$) prime factors are independent and uniform over the class group. For actual semiprimes drawn from a bounded range, equidistribution of primes in residue classes makes this an excellent approximation, with error governed by the effective error term in the prime number theorem for arithmetic progressions; but the model is genuinely an idealization, and does not account for correlations induced by, e.g., restricting $p, q$ to a common interval or to special forms. We also treat only class-determined events; events depending on finer arithmetic of $p$ (such as the size of the class group of $\mathbb{Q}(\sqrt{-p})$) fall outside the framework.

---

## 12. Future directions

The following are the natural next questions raised by the results above.

1. **Exact multi-prime maximum.** For $k \ge 3$ factors we conjecture that the maximum of the OR dial is exactly the index-two kernel value $H(2^{-k}) - \frac12 H(2^{-(k-1)})$ — $0.1379$ bits for $k=3$, $0.0655$ for $k=4$ — attained again precisely at cosets of index-two subgroups. The uniform gap $g(2) - 1/500$ proved here is far from this conjectured value, so a genuinely $k$-sensitive argument is needed; the natural route is a $k$-fold refinement of the window law, replacing $s^{*k} \le \mu^{k-1}$ with a bound that sees the whole convolution structure.

2. **Non-abelian class groups.** The counting identity uses commutativity only through the parametrization $(a, ca^{-1})$ of the product fibre. For a non-abelian Galois group — the $S_3$ cubic being the first case — the fibres of the multiplication map are still of uniform size, but the convolution is no longer symmetric and the profile is a class function rather than a function on an abelian group. Does the same cap hold, with maximizers the pullbacks of index-two subgroups (i.e. sign characters)?

3. **Conditional (which-factor) information.** Replace $I(N; B)$ by the information $B$ carries about the unordered pair $\{p, q\}$ given $N$ — the quantity that would actually matter for factoring. Preliminary estimates in the $S_3$ example put it near $0.002$ bits. Is there a *zero* theorem: does every residue-type OR channel carry exactly zero which-factor information in the equidistributed model?

4. **Correlated and dependent profiles.** Allow the two fork events to be governed by different profiles $r_1, r_2$ (asymmetric channels), or to be correlated through a shared auxiliary randomness. Does the cap survive, and is it still the quadratic locus that saturates it?

5. **Beyond OR: general Boolean aggregation.** OR, AND and XOR are three of the sixteen binary Boolean functions. The symmetric ones are captured here; XOR degenerates to a deterministic function of $N$. Determine the maximum dial for every symmetric $k$-ary aggregation rule (threshold functions, majority), and identify which rules — if any — beat $g(2)$ without collapsing to a function of $N$.

---

## 13. Conclusion

The semiprime OR dial has a global maximum, and it is small: $g(2) = H(3/4) - \frac12 H(1/2) = \frac32\log 2 - \frac34\log 3$ nats, or $0.311278\ldots$ bits. The maximum is attained, and only attained, by the quadratic-character kernels and their cosets; every other index, every fractional profile, and every class group of odd order falls strictly below. The bound survives to $k$-almost primes and, for $k \ge 3$, becomes strict with a uniform margin, the extremal values decaying like $2^{-k}$. And the channel that reads highest of all — XOR at a quadratic kernel, a full bit — is a deterministic function of $N$, which is the sharpest way of saying that this entire dial measures what the observer already knows.

---

### Appendix: numerical table

| Channel | Class group | Formula | Bits |
|---|---|---|---|
| Quadratic OR ($\mathbb{Q}(\sqrt5)$, $m=5$) | $C_4$ | $H(1/4) - \tfrac12H(1/2)$ | $0.311278$ |
| Quadratic OR ($\mathbb{Q}(i)$, $m=4$) | $C_2$ | same | $0.311278$ |
| Quadratic OR ($\mathbb{Q}(\sqrt{-11})$, $m=11$) | $C_{10}$ | same | $0.311278$ |
| Kronecker $(8\mid p)$, $m = 8$ | $C_2\times C_2$ | same | $0.311278$ |
| Cyclic cubic OR, $m = 7$ | $C_6$ | $g(3)$ | $0.072780$ |
| Quartic OR, $\mathbb{Q}(\zeta_5)$ | $C_4$ | $g(4)$ | $0.035880$ |
| AND, order 3 | any | $H(1/9)-\tfrac13H(1/3)$ | $0.197160$ |
| AND, order 4 | any | $H(1/16)-\tfrac14H(1/4)$ | $0.134471$ |
| $S_3$ cubic $x^3+x+1$, $m = 31$, variable profile | $C_{30}$ | exact evaluation | $\approx 0.1230$ |
| Quadratic OR, 3 factors | any with $\chi$ | $H(1/8) - \tfrac12 H(1/4)$ | $0.137925$ |
| Quadratic OR, 4 factors | any with $\chi$ | $H(1/16) - \tfrac12 H(1/8)$ | $0.065508$ |
| XOR at a quadratic kernel | any with $\chi$ | deterministic in $N$ | $1.000000$ |
