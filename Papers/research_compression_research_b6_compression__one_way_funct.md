# Compression Beyond the Pigeonhole Bound, II: Las Vegas Randomness, Search-to-Decision, and the One-Way Boundary

**Author:** Aristotle

**Date:** 2026-08-18

---

## Abstract

We give a precise calibration of what randomness is worth to a lossless compressor, and of where efficient compression collides with cryptographic hardness. On the information-theoretic side we prove a double-counting theorem for *Las Vegas* (zero-error, seeded) compression: for any finite seed space $R$, any target budget $s$, and any finite target set $T$, the total number of (object, good seed) incidences is at most $|R|\,(2^{s+1}-1)$. Consequently a randomized compressor with success probability $\delta$ gains at most $\log_2(1/\delta)+1$ bits over the deterministic pigeonhole ceiling — *independently of the number of random bits consumed* — and a compressor required to succeed for every seed gains exactly nothing. The bound is tight to within one bit, witnessed by an explicit seeded prefix system, and the seed budget obeys a strict hierarchy: with $2^k$ seeds every string of length $k+s$ is compressible to $s$ bits, while with $2^{k-1}$ seeds no seeded family achieves this. A layer-cake inequality upgrades all counting bounds to average-case (Shannon-type) statements: the average description length of a set of $2^n$ objects is at least $n-2$ deterministically and at least $n-k-3$ with $2^k$ seeds, and the constant $2$ is sharp.

On the computational side we fix an abstract class $\mathcal C$ of feasible algorithms closed under guarding, bounded search, and *Las Vegas simulation* (run finitely many seeds, return the first verified output). We prove that a one-way function for $\mathcal C$ defeats every Las Vegas algorithm **totally**: there is a value in the range on which all seeds fail simultaneously. This holds for inversion, for exact compression search, and for approximate compression search with arbitrary additive slack; and the existence of a one-way function is *equivalent* to hardness of Las Vegas compression search. Our main new contribution concerns the *decision* task "does $y$ have a program of length $n$ extending the prefix $w$?", whose answers carry no certificate. We show that the classical bit-by-bit reconstruction needs the decision oracle to be correct **only at the single string being compressed**, that Las Vegas families of such locally correct oracles derandomize into deterministic inverters, and hence that under a one-way function every seeded decision oracle is wrong at some describable value. Finally we show the obstruction is purely computational: the ideal (non-effective) oracle, fed to the same reconstruction, is an exact shortest-program finder. Randomness helps compression exactly up to the computational-hardness boundary, and no further.

**Keywords:** Kolmogorov complexity, one-way functions, Las Vegas algorithms, search-to-decision reduction, pigeonhole bound, description length, derandomization.

---

## 1. Introduction

### 1.1 Two walls

Lossless compression meets two distinct obstacles, and confusing them is the source of most folklore in the area.

The first is *informational* and unconditional. Fix any decoder $D$ mapping programs to objects. The number of objects $y$ admitting a $D$-program of length at most $s$ is at most the number of binary strings of length at most $s$, namely $2^{s+1}-1$. No cleverness, no computation, no oracle changes this. Short descriptions are scarce.

The second obstacle is *computational* and conditional. Scarcity says nothing about *finding* the short description that a given object happens to have. A string may possess a $50$-bit program while every efficient algorithm fails to locate it. This second wall, unlike the first, cannot be established unconditionally with present techniques; it is exactly as strong as the standard assumptions of cryptography.

This paper calibrates both walls in the presence of randomness, and links them.

### 1.2 The question

Randomness is the reflexive answer to a hard search problem, and it is easy to convince oneself that it should help compression. A randomized compressor can pick, per input, a code adapted to that input; surely the union over seeds of "what this code compresses well" is much larger than what any single code compresses well?

It is larger — by an amount we compute exactly. The question splits into two sub-questions with strikingly different answers:

* **How many objects can a randomized compressor handle?** This is combinatorics. Answer: a factor $1/\delta$ more than a deterministic one, where $\delta$ is the success probability; equivalently $\log_2(1/\delta)+1$ extra bits. Seed length is irrelevant.
* **Can a randomized compressor *find* short descriptions that a deterministic one cannot?** This is complexity theory. Answer: no, not at all, provided the ambient class can simulate "try all seeds and keep the verified answer".

The second answer has an obvious apparent loophole: it depends on outputs being *verifiable*. So we test the loophole against the one compression task whose outputs are not verifiable — the decision task — and find that the loophole closes.

### 1.3 Contributions

1. **A Las Vegas counting theorem** (§3) and its four corollaries: the success-probability law, worthlessness of zero-error randomness, tightness within one bit, and survival of incompressible strings.
2. **Average-case bounds from pure counting** (§4) via a layer-cake inequality, deterministic and seeded, with a sharpness computation showing the additive constant cannot be improved beyond $O(1)$.
3. **A strict seed hierarchy** (§4.4): each random bit is worth exactly one bit of compression.
4. **Total failure of Las Vegas algorithms at the one-way boundary** (§5), for inversion, exact compression search, and approximate compression search, together with an equivalence: one-way functions exist iff Las Vegas compression search is hard.
5. **Search-to-decision under local correctness** (§6), the main new technical contribution: reconstruction needs oracle correctness at a single point; Las Vegas deciders therefore derandomize; one-way functions defeat them.
6. **Separation of the informational and computational obstructions** (§7): the ideal oracle solves the same task perfectly.

---

## 2. Setting and definitions

Throughout, a *string* is a finite sequence of bits; $|y|$ denotes length, $wp$ (or $w \,\|\, p$) denotes concatenation, and $\mathrm{Bit}(n)$ denotes the set of strings of length exactly $n$, so $|\mathrm{Bit}(n)| = 2^n$.

**Definition 2.1 (Decompressor, describability, complexity).**
A *decompressor* (equivalently a *decoder*) is a function $D$ from strings to a set of objects. An object $y$ is *describable* under $D$ if $y = D(p)$ for some string $p$; such a $p$ is a *$D$-program* for $y$. For describable $y$ the *complexity* is
$$K_D(y) \;=\; \min\{\,|p| : D(p)=y\,\}.$$
We use only two facts about $K_D$: it is bounded above by the length of any program ($D(p)=y \Rightarrow K_D(y)\le |p|$), and a shortest program exists whenever $y$ is describable.

**Definition 2.2 (Pigeonhole ceiling).**
For any $D$, any $s$, and any finite set $T$ all of whose members satisfy $K_D(y) \le s$, we have $|T| \le 2^{s+1}-1$.

This is the base bound; everything unconditional in this paper is derived from it by counting.

**Definition 2.3 (Seeded / Las Vegas compressor).**
A *seeded family* is a map $r \mapsto D_r$ from a finite seed set $R$ to decompressors. The *good-seed set* of $y$ at budget $s$ is
$$G_s(y) \;=\; \{\, r \in R : y \text{ describable under } D_r \text{ and } K_{D_r}(y) \le s \,\},$$
and the *success probability* of the scheme at $y$ is $|G_s(y)|/|R|$ under the uniform seed distribution. The scheme is *Las Vegas* in the sense that it never produces an incorrect decoding: an output is either a valid program under the drawn seed or a failure. The *seeded complexity* is
$$K^{\mathrm{seed}}(y) \;=\; \min\{\, |p| : \exists r \in R,\ D_r(p) = y \,\}.$$

**Definition 2.4 (Search-closed class).**
A *search-closed class* $\mathcal C$ consists of a set $\mathcal C_{\mathrm{Comp}}$ of algorithms (functions from strings to strings) together with a notion of *allowed fuel bound*, closed under the operations one expects of any reasonable deterministic complexity class: composing an algorithm with a verification test that guards its output, and running a bounded search over lengths up to an allowed fuel bound. An algorithm $A$ *inverts* $f$, written $\mathrm{Inv}(f,A)$, if $f(A(y)) = y$ for every $y$ in the range of $f$. A function $f$ is *honest in $\mathcal C$* if preimages can be searched for within an allowed fuel bound (their lengths are bounded by an allowed function of $|y|$).

**Definition 2.5 (One-way function).**
$f$ is *one-way in $\mathcal C$*, written $\mathrm{OW}_{\mathcal C}(f)$, if $f \in \mathcal C_{\mathrm{Comp}}$, $f$ is honest in $\mathcal C$, and no $A \in \mathcal C_{\mathrm{Comp}}$ inverts $f$.

This is a worst-case, uniform, deterministic formulation: for every efficient $A$ there is *some* $y$ in the range with $f(A(y)) \ne y$. It is the weakest assumption under which the statements below have content, and everything we prove is monotone: the results transfer verbatim to any stronger notion (average-case, non-uniform) of hardness.

**Definition 2.6 (Compression tasks).**
Let $D$ be a decompressor.

* $A$ is a **shortest-program finder** for $D$ if for every describable $y$, $D(A(y)) = y$ and $|A(y)| = K_D(y)$.
* $A$ is a **$\delta$-approximate finder** if for every describable $y$, $D(A(y)) = y$ and $|A(y)| \le K_D(y) + \delta(|y|)$.
* A **prefix-decision oracle** for $D$ is a predicate $\mathrm{dec}(y,w,n)$ intended to answer: *is there a string $p$ of length $n$ with $D(wp)=y$?*

The seeded (Las Vegas) versions of the first two: a family $\{A_r\}$ with finite seed list $R$ is a **seeded shortest finder** if for every describable $y$ there is $r \in R$ with $D(A_r(y)) = y$ and $|A_r(y)| = K_D(y)$; a **seeded approximate finder with slack $g$** if instead $|A_r(y)| \le K_D(y) + g(|y|)$.

**The bridge.** Read a one-way function $f$ as a decompressor: a $f$-program for $y$ *is* a preimage of $y$. Then a shortest-program finder for $f$ is in particular an inverter of $f$. This is the elementary observation that makes the whole dictionary work, and every hardness statement below is an instance of it.

---

## 3. Las Vegas compression: the counting theory

### 3.1 The budget theorem

**Theorem 3.1 (Las Vegas double counting).** *For every finite seed set $R$, every seeded family $\{D_r\}_{r\in R}$, every $s$, and every finite target set $T$,*
$$\sum_{y \in T} |G_s(y)| \;\le\; |R| \cdot \bigl(2^{s+1}-1\bigr).$$

*Proof sketch.* Write $|G_s(y)|$ as $\sum_{r\in R} \mathbf 1[\,K_{D_r}(y)\le s\,]$ and exchange the two summations. The inner sum over $y \in T$ for fixed $r$ counts the elements of $T$ compressible to $s$ bits by the single decompressor $D_r$, which is at most $2^{s+1}-1$ by the pigeonhole ceiling (Definition 2.2). Summing $|R|$ such bounds gives the claim. $\square$

The theorem is best read as a *budget*: the right-hand side is the total supply of (seed, short program) pairs; the left-hand side is the total demand generated by $T$. Randomness redistributes description length; it does not manufacture it.

### 3.2 Success probability, not seed length

**Corollary 3.2 (Success-probability law).** *If every $y \in T$ is compressed to $s$ bits by at least $m$ seeds, then*
$$m\,|T| \;\le\; |R|\,(2^{s+1}-1), \qquad\text{i.e.}\qquad |T| \;\le\; \frac{2^{s+1}-1}{\delta}, \quad \delta = m/|R|.$$

*Proof sketch.* $m|T| = \sum_{y\in T} m \le \sum_{y\in T}|G_s(y)|$, then apply Theorem 3.1. $\square$

Equivalently: relative to the deterministic ceiling $2^{s+1}-1$, a Las Vegas compressor with success probability $\delta$ gains at most $\log_2(1/\delta)+1$ bits. The number of random bits does not appear. A scheme drawing a $10^6$-bit seed but succeeding with probability $1/2$ gains one bit.

**Corollary 3.3 (Zero-error randomness gains nothing).** *If $R$ is nonempty and every $y \in T$ is compressed to $s$ bits by **every** seed, then $|T| \le 2^{s+1}-1$.*

*Proof sketch.* Apply Corollary 3.2 with $m = |R|$; the factor $|R|>0$ cancels from both sides. $\square$

**Corollary 3.4 (Quantified gain).** *If $|R| \le m\,2^{k}$ and every $y\in T$ has at least $m$ good seeds (success probability $\ge 2^{-k}$), then $|T| \le 2^{k}(2^{s+1}-1)$: the gain over the deterministic ceiling is at most $k$ bits.*

### 3.3 Tightness

The bound is not a lossy estimate. Let $j,i \ge 0$ and take the seed set $R = \{0,1\}^{j}\times\{0,1\}^{i}$ with the **seeded prefix system**
$$D_{(u,v)}(p) \;=\; u\,p ,$$
so the first seed component is prepended to the program and the second is ignored — deliberately wasted randomness.

**Theorem 3.5 (Tightness within one bit).** *For all $i,j,s$: every string $y$ of length $j+s$ satisfies $|G_s(y)| \ge 2^{i}$ (indeed exactly $2^i$: the good seeds are those whose $u$-component equals the first $j$ bits of $y$), and*
$$|R|\,(2^{s+1}-1) \;<\; 2\cdot\bigl(2^{i}\cdot|\mathrm{Bit}(j+s)|\bigr).$$

*Proof sketch.* For the first part, if $u$ is the length-$j$ prefix of $y$ then $p = y_{>j}$ (the last $s$ bits) satisfies $D_{(u,v)}(p) = y$ for all $2^i$ choices of $v$, whence $K_{D_{(u,v)}}(y)\le s$. For the second, $|R| = 2^{i+j}$, $|\mathrm{Bit}(j+s)| = 2^{j+s}$, and $2^{i+j}(2^{s+1}-1) < 2^{i+j}\cdot 2^{s+1} = 2\cdot 2^{i}\cdot 2^{j+s}$. $\square$

Thus the demand attains more than half the budget, so Corollary 3.2 is optimal up to one bit; and — the conceptual point — the achieved compression depends only on the success probability $2^{-j}$, never on the $i$ extra random bits.

### 3.4 Incompressible strings survive

**Theorem 3.6 (Las Vegas incompressibility).** *For every seeded family $\{D_r\}_{r\in R}$ over a nonempty finite $R$ and all $s,k$, there exists a string $y$ of length $k+s+1$ with*
$$2^{k}\,|G_s(y)| \;<\; |R|,$$
*i.e. whose success probability is strictly below $2^{-k}$.*

*Proof sketch.* Suppose not: every $y \in \mathrm{Bit}(k+s+1)$ has $|R| \le 2^k|G_s(y)|$. Summing over the $2^{k+s+1}$ such strings gives $2^{k+s+1}|R| \le 2^{k}\sum_y |G_s(y)| \le 2^{k}\,|R|(2^{s+1}-1) < 2^{k}|R|2^{s+1} = 2^{k+s+1}|R|$, a contradiction. $\square$

Randomness cannot delete hard instances; it can only dilute them at the fixed exchange rate of Corollary 3.2.

---

## 4. Average-case bounds, sharpness, and the seed hierarchy

### 4.1 The layer-cake inequality

Worst-case counting statements upgrade mechanically to statements about *sums* of description lengths.

**Lemma 4.1 (Layer-cake).** *Let $c : T \to \mathbb N$ be any function on a finite set $T$, let $S \in \mathbb N$, and suppose that for every $s < S$ we have $|\{y \in T : c(y) \le s\}| \le \mathrm{bnd}(s)$. Then*
$$S\,|T| \;\le\; \sum_{y\in T} c(y) \;+\; \sum_{s<S} \mathrm{bnd}(s).$$

*Proof sketch.* For each $s$, split $T$ into $\{c \le s\}$ and $\{c > s\}$, so $|T| = |\{c\le s\}| + |\{c>s\}|$. Sum over $s < S$: the left side is $S|T|$, the first term is at most $\sum_{s<S}\mathrm{bnd}(s)$, and the second is $\sum_{s<S}|\{y : c(y)>s\}| = \sum_{y\in T} |\{s < S : s < c(y)\}| \le \sum_{y\in T} c(y)$ by exchanging the order of summation. $\square$

### 4.2 Average description length

**Theorem 4.2 (Average description length).** *For any decompressor $D$ and any finite set $T$ of describable objects with $|T| \ge 2^n$,*
$$(n-2)\,|T| \;\le\; \sum_{y \in T} K_D(y).$$

*Proof sketch.* Apply Lemma 4.1 with $c = K_D$, $S = n-1$ and $\mathrm{bnd}(s) = 2^{s+1}-1$, licensed by the pigeonhole ceiling. The geometric sum satisfies $\sum_{s<n-1}(2^{s+1}-1) \le 2^{n} \le |T|$, giving $(n-1)|T| \le \sum_y K_D(y) + |T|$, i.e. $(n-2)|T| \le \sum_y K_D(y)$. (For $n<3$ the statement is vacuous over $\mathbb N$.) $\square$

This is a Shannon-type theorem obtained without any probability distribution: it holds for every decompressor whatsoever, computable or not.

**Theorem 4.3 (Average description length with randomness).** *Let $\{D_r\}_{r\in R}$ be a seeded family with $|R| \le 2^{k}$, and let $T$ be a finite set with $|T| \ge 2^{n}$, each member describable under at least one seed. Then*
$$(n-k-3)\,|T| \;\le\; \sum_{y\in T} K^{\mathrm{seed}}(y).$$

*Proof sketch.* The seeded pigeonhole ceiling bounds the number of objects with $K^{\mathrm{seed}} \le s$ by $|R|(2^{s+1}-1) \le 2^{k}(2^{s+1}-1)$. Feed this into Lemma 4.1 with $S = n-k-2$; the geometric sum is now at most $2^{n-1} \le |T|$, and the same rearrangement yields the claim. $\square$

So randomness saves at most $k+O(1)$ bits *on average*, matching the worst-case law of §3 — a strong statement, since one might have hoped for a distributional escape.

### 4.3 The constant is sharp

**Theorem 4.4 (Sharpness).** *Let $T_m$ be the set of all strings of length at most $m$ and let $D$ be the identity decompressor, so $K_D(y) = |y|$. Then exactly*
$$\sum_{y\in T_m} K_D(y) \;+\; 2\cdot 2^{m+1} \;=\; (m+1)2^{m+1} + 2, \qquad |T_m| + 1 = 2^{m+1}.$$

*Proof sketch.* $T_m$ is the disjoint union of $\mathrm{Bit}(\ell)$ for $\ell \le m$, so $|T_m| = \sum_{\ell\le m}2^{\ell} = 2^{m+1}-1$ and $\sum_{y}K_D(y) = \sum_{\ell \le m} \ell\,2^{\ell}$. The identity $\sum_{\ell<M} \ell 2^{\ell} + 2\cdot 2^{M} = M2^{M}+2$, proved by induction on $M$, gives the result with $M = m+1$. $\square$

Reading this with $n = m+1$: the average description length is $n - 2 + o(1)$. Theorem 4.2 therefore cannot be improved beyond an additive $O(1)$, and the exponent-counting argument behind it is asymptotically optimal.

### 4.4 A strict hierarchy in the seed budget

**Theorem 4.5 (Strict seed hierarchy).** *Fix $s$ and $k \ge 1$.*

1. *With $2^{k}$ seeds the prefix system succeeds everywhere: every $y$ of length $k+s$ has a good seed, i.e. is compressible to $s$ bits under some seed.*
2. *With at most $2^{k-1}$ seeds no seeded family whatsoever achieves this: for every $\{D_r\}$ with $|R| \le 2^{k-1}$ there is a string $y$ of length $k+s$ with $G_s(y) = \varnothing$.*

*Proof sketch.* (1) is Theorem 3.5 with $i=0$, $j=k$. For (2), suppose every $y \in \mathrm{Bit}(k+s)$ had a good seed. The seeded pigeonhole ceiling then gives $2^{k+s} \le |R|(2^{s+1}-1) \le 2^{k-1}(2^{s+1}-1) = 2^{k+s} - 2^{k-1}$, which is false since $2^{k-1}>0$. $\square$

Each random bit is therefore worth exactly one bit of compression, and the budget is rigid: halving the seed space strictly weakens the compressor. Complementing this from the other direction, a *derandomization* result holds: a seeded family with $k$-bit seeds is simulated by a single deterministic decompressor at additive cost $2k+1$ bits, via a self-delimiting encoding of the seed (write $|r|$ in unary, then $r$, then the program). Randomness is thus worth between $k$ and $2k+1$ bits, and nothing outside that window.

---

## 5. The computational boundary: Las Vegas algorithms versus one-way functions

We now impose efficiency. Fix a search-closed class $\mathcal C$ (Definition 2.4).

### 5.1 Derandomization by verification

**Definition 5.1 (Las Vegas simulation).** For an algorithm family $A : (\text{seed},\text{input}) \mapsto \text{output}$, a target function $f$ and a finite list of seeds $R$, define
$$\mathrm{try}_{f,A,R}(y) \;=\; \begin{cases} A_r(y) & \text{for the first } r\in R \text{ with } f(A_r(y)) = y,\\ y & \text{if no such } r \text{ exists.}\end{cases}$$

**Definition 5.2 (Las Vegas class).** A *Las Vegas class* is a search-closed class additionally closed under Las Vegas simulation: if $f \in \mathcal C_{\mathrm{Comp}}$ and every slice $A_r \in \mathcal C_{\mathrm{Comp}}$, then $\mathrm{try}_{f,A,R} \in \mathcal C_{\mathrm{Comp}}$ for every finite list $R$.

The closure axiom is exactly the formal content of "you can run finitely many seeds and check which answer is right"; every reasonable deterministic class with verification satisfies it.

**Lemma 5.3 (Las Vegas inversion derandomizes).** *If for every $y$ in the range of $f$ some seed $r \in R$ satisfies $f(A_r(y)) = y$, then $\mathrm{try}_{f,A,R}$ inverts $f$.*

*Proof sketch.* Given such $y$, the search for the first verifying seed cannot return "none" (the witness $r$ would be found), and whichever seed $r'$ it returns satisfies the verification predicate by construction. $\square$

### 5.2 Total failure

**Theorem 5.4 (One-way functions defeat Las Vegas algorithms totally).** *Let $\mathcal C$ be a Las Vegas class and $f$ one-way in $\mathcal C$. For every seeded family $A$ with all slices in $\mathcal C_{\mathrm{Comp}}$ and every finite seed list $R$, there exists $y$ in the range of $f$ with*
$$f(A_r(y)) \neq y \quad\text{for all } r \in R .$$

*Proof sketch.* Otherwise every $y$ in the range has a good seed, so $\mathrm{try}_{f,A,R}$ inverts $f$ (Lemma 5.3) and lies in $\mathcal C_{\mathrm{Comp}}$ by the closure axiom — contradicting one-wayness. $\square$

The conclusion is qualitatively stronger than "fails with noticeable probability": on the exhibited input the algorithm fails with probability $1$ over the seed list. This is the exact computational analogue of Corollary 3.3.

**Corollary 5.5 (Las Vegas compression search is blocked).** *Under the hypotheses of Theorem 5.4, no seeded family with slices in $\mathcal C_{\mathrm{Comp}}$ and finite seed list is a seeded shortest finder for $f$ read as a decompressor.*

**Corollary 5.6 (Approximation does not help).** *The same holds for seeded approximate finders with **any** additive slack function $g$ whatsoever.*

*Proof sketch of both.* A seeded finder in particular outputs, for each describable $y$ and some seed, a program $p$ with $f(p) = y$; Theorem 5.4 exhibits a $y$ where every seed fails to do even that. Optimality of the program length is never used. $\square$

The moral of Corollary 5.6 deserves emphasis: the cryptographic obstruction is to producing *any* valid description, not an optimal one. Slack is free to the adversary and worthless to the algorithm.

### 5.3 Equivalences

**Theorem 5.7 (Las Vegas inversion $\equiv$ deterministic inversion).** *For a Las Vegas class $\mathcal C$, the following are equivalent:*

1. *every honest $f\in\mathcal C_{\mathrm{Comp}}$ is inverted by some $A \in \mathcal C_{\mathrm{Comp}}$;*
2. *every honest $f\in\mathcal C_{\mathrm{Comp}}$ is inverted by some seeded family with all slices in $\mathcal C_{\mathrm{Comp}}$ and a finite seed list (some seed succeeding at each point of the range).*

*Proof sketch.* $(1)\Rightarrow(2)$ take the constant family with the single seed list $[\,\varepsilon\,]$. $(2)\Rightarrow(1)$ is Lemma 5.3 plus the closure axiom. $\square$

**Theorem 5.8 (The characterization).** *For a Las Vegas class $\mathcal C$ the following are equivalent:*

1. *a one-way function for $\mathcal C$ exists;*
2. *some honest decompressor $D \in \mathcal C_{\mathrm{Comp}}$ has a hard **deterministic** compression-search problem (no $A \in \mathcal C_{\mathrm{Comp}}$ is a shortest-program finder for $D$);*
3. *some honest $D \in \mathcal C_{\mathrm{Comp}}$ has a hard **Las Vegas** compression-search problem (no seeded family with finite seed list is a seeded shortest finder for $D$).*

*Proof sketch.* $(1)\Rightarrow(3)$ is Corollary 5.5. $(3)\Rightarrow(2)$ is immediate (a deterministic finder is a one-seed family). $(2)\Rightarrow(1)$ is the deterministic equivalence between one-wayness and hardness of compression search, which follows from the bridge of §2 and closure under guarded bounded search: from an inverter for every honest function one builds a shortest-program finder by searching lengths upward and verifying. $\square$

This is the promised map of compression tasks to cryptographic assumptions: **randomizing the compressor changes nothing about which assumption is needed.**

### 5.4 Non-vacuity and non-triviality

Two checks certify that Theorem 5.4 is neither empty nor secretly unconditional.

* **The class of all functions** is a Las Vegas class, contains no one-way function, and in it a single-seed algorithm solves compression search for every honest decompressor. Hence §5 is genuinely conditional.
* **The class of length-nondecreasing algorithms** (those with $|A(y)| \ge |y|$) is a Las Vegas class — verification never shortens the input and the fallback branch echoes it — and it carries a genuine one-way function, namely the tagging map $y \mapsto \mathrm{true}\,\|\,y$, which cannot be inverted by any length-nondecreasing algorithm. In that class, therefore, every Las Vegas algorithm with any finite seed list fails on some string for all of its seeds, and Las Vegas compression search is hard.

---

## 6. Search-to-decision, local correctness, and Las Vegas deciders

### 6.1 Why the decision task looked like a loophole

Everything in §5 rests on *verification*: the derandomizing simulation works because a candidate program can be checked by running it. The compression dictionary, however, contains a task with no certificate — the decision problem studied in the literature on time-bounded Kolmogorov complexity, phrased here in prefix-conditional form:

> $\mathrm{dec}(y,w,n)$: is there a string $p$ with $|p|=n$ and $D(wp) = y$?

A "yes" answer cannot be checked without solving the problem again. So a Las Vegas decider might plausibly evade Theorem 5.4. It does not, and the reason is that although individual answers are uncheckable, a *sequence* of them composes into a certificate.

### 6.2 Bit-by-bit reconstruction

**Definition 6.1 (Reconstruction).** Given a predicate $\mathrm{dec}(\cdot,\cdot)$ of a prefix and a remaining length, define $\mathrm{rebuild}(0,w) = w$ and
$$\mathrm{rebuild}(n+1, w) \;=\; \begin{cases}\mathrm{rebuild}(n,\; w0) & \text{if } \mathrm{dec}(w0, n),\\ \mathrm{rebuild}(n,\; w1) & \text{otherwise.}\end{cases}$$

**Lemma 6.2 (Correctness of reconstruction).** *Suppose $\mathrm{dec}(w,n)$ holds precisely when some $p$ of length $n$ satisfies $D(wp)=y$. Then for all $n$ and $w$ such that some length-$n$ continuation of $w$ is a $D$-program for $y$, the string $\mathrm{rebuild}(n,w)$ is a $D$-program for $y$ of length $|w|+n$.*

*Proof sketch.* Induction on $n$. For $n=0$ the continuation is empty, so $D(w)=y$. For $n+1$, write the witness as $bt$ with $|t| = n$. If $\mathrm{dec}(w0,n)$ holds we descend into $w0$ with a witness supplied by the oracle's correctness; otherwise the $0$-branch is dead, forcing $b = 1$, and $t$ itself witnesses the $1$-branch. In both cases the inductive hypothesis applies, and lengths add. $\square$

**Definition 6.3 (Decision-to-finder).** With a fuel bound $\mathrm{fuel}(\cdot)$, define
$$\mathcal F_{\mathrm{dec}}(y) \;=\; \mathrm{rebuild}\bigl(n_0(y),\ \varepsilon\bigr), \qquad n_0(y) = \min\{\,n \le \mathrm{fuel}(|y|) : \mathrm{dec}(y,\varepsilon,n)\,\}.$$

**Theorem 6.4 (Search-to-decision for compression).** *If $\mathrm{dec}$ is a correct prefix-decision oracle for $D$ and $\mathrm{fuel}(|y|) \ge K_D(y)$, then for every describable $y$: $D(\mathcal F_{\mathrm{dec}}(y)) = y$ and $|\mathcal F_{\mathrm{dec}}(y)| = K_D(y)$. That is, $\mathcal F_{\mathrm{dec}}$ is an exact shortest-program finder.*

*Proof sketch.* Correctness of the oracle at the empty prefix makes $n \mapsto \mathrm{dec}(y,\varepsilon,n)$ the predicate "$y$ has a program of length $n$", whose least solution below the fuel bound is exactly $K_D(y)$; then apply Lemma 6.2 with $w = \varepsilon$. $\square$

**Corollary 6.5 (One-way functions have no efficient prefix decider).** *If $f$ is one-way in a search-closed class $\mathcal C$ and $\mathrm{fuel}$ is an admissible bound, then no correct prefix-decision oracle for $f$ can have $\mathcal F_{\mathrm{dec}} \in \mathcal C_{\mathrm{Comp}}$ — otherwise $\mathcal F_{\mathrm{dec}}$ would invert $f$.*

Hence exact, approximate, and prefix-decision compression all sit at the same cryptographic level.

### 6.3 Local correctness: the key new lemma

Theorem 6.4 assumes a *globally* correct oracle. A Las Vegas decider offers much less: for each $y$ some seed is right *about $y$*, and all seeds may be arbitrarily wrong about everything else. The following definition and lemma close that gap.

**Definition 6.6 (Local correctness).** An oracle $\mathrm{dec}$ is *locally correct at $y$* for $D$ if for all prefixes $w$ and lengths $n$,
$$\mathrm{dec}(y,w,n) = \text{true} \iff \exists p,\ |p| = n \ \wedge\ D(wp) = y .$$
No constraint is placed on $\mathrm{dec}(y',\cdot,\cdot)$ for $y' \ne y$.

**Theorem 6.7 (Local correctness suffices).** *If $\mathrm{dec}$ is locally correct at $y$, $y$ is describable under $D$, and $\mathrm{fuel}(|y|)\ge K_D(y)$, then $D(\mathcal F_{\mathrm{dec}}(y)) = y$ and $|\mathcal F_{\mathrm{dec}}(y)| = K_D(y)$.*

*Proof sketch.* Define the *globalization* $\widehat{\mathrm{dec}}$ by keeping $\mathrm{dec}$'s answers at the string $y$ and replacing all others by the ideal (not necessarily effective) answers:
$$\widehat{\mathrm{dec}}(y',w,n) = \begin{cases}\mathrm{dec}(y,w,n) & y' = y,\\ [\exists p,\ |p|=n \wedge D(wp)=y'] & y' \ne y.\end{cases}$$
By local correctness at $y$, $\widehat{\mathrm{dec}}$ is globally correct, so Theorem 6.4 applies to it. But $\mathcal F$ evaluated at $y$ queries the oracle only in its $y$-slice, and $\widehat{\mathrm{dec}}(y,\cdot,\cdot) = \mathrm{dec}(y,\cdot,\cdot)$ by construction — so the two runs are literally the same computation. Transporting the conclusion along that equality finishes the proof. $\square$

The globalization is a purely mathematical device: it is not required to be computable, and it never has to be constructed by any algorithm. It exists only to license the transfer of a global theorem to a local hypothesis.

### 6.4 Las Vegas deciders derandomize

**Theorem 6.8 (Las Vegas decision oracles yield an inverter).** *Let $f$ be a function, $\{\mathrm{dec}_r\}_{r \in R}$ a family of decision oracles indexed by a finite seed list $R$, and $\mathrm{fuel}$ a bound with $\mathrm{fuel}(|y|) \ge K_f(y)$ for every describable $y$. If for every $y$ in the range of $f$ there is a seed $r \in R$ such that $\mathrm{dec}_r$ is locally correct at $y$, then*
$$\mathrm{try}_{f,\ (r \mapsto \mathcal F_{\mathrm{dec}_r}),\ R}$$
*inverts $f$ deterministically.*

*Proof sketch.* Fix $y$ in the range and a seed $r$ locally correct at $y$. Theorem 6.7 says $\mathcal F_{\mathrm{dec}_r}(y)$ is a genuine $f$-program for $y$, so the hypothesis of Lemma 5.3 is met and the simulation inverts. $\square$

The pivot of the argument: *the oracle's answers need not be checkable — only the reconstructed program is, and that suffices.* This is exactly the reason the decision task fails to be a loophole.

**Theorem 6.9 (One-way functions defeat Las Vegas deciders).** *Let $\mathcal C$ be a Las Vegas class, $f$ one-way in $\mathcal C$, $\mathrm{fuel}$ an admissible bound as above, and $\{\mathrm{dec}_r\}$ a seeded family of oracles whose induced finders $\mathcal F_{\mathrm{dec}_r}$ all lie in $\mathcal C_{\mathrm{Comp}}$. Then for every finite seed list $R$ there is a value $y$ in the range of $f$ such that **every** seed's oracle is **not** locally correct at $y$ — it answers some prefix query about $y$ incorrectly.*

*Proof sketch.* Apply Theorem 5.4 to the seeded family $r \mapsto \mathcal F_{\mathrm{dec}_r}$ to obtain a describable $y$ on which all seeds fail to output a preimage. If some $\mathrm{dec}_r$ were locally correct at $y$, Theorem 6.7 would make $\mathcal F_{\mathrm{dec}_r}(y)$ a valid program, contradiction. $\square$

**Corollary 6.10 (Decision is at least as hard as search).** *A seeded family of locally correct decision oracles yields a seeded shortest-program finder: for every describable $y$ some seed's reconstruction outputs a program of length exactly $K_D(y)$.*

---

## 7. The obstruction is computational, not informational

**Definition 7.1 (Ideal oracle).** For a decompressor $D$ let $\mathrm{dec}^{\ast}_D(y,w,n)$ be true precisely when some $p$ of length $n$ satisfies $D(wp) = y$. This is a well-defined predicate for every $D$, effective or not.

**Theorem 7.2 (No information-theoretic obstruction).** *For every $D$ and every admissible fuel bound, $\mathcal F_{\mathrm{dec}^{\ast}_D}$ is an exact shortest-program finder for $D$: for every describable $y$ it outputs a $D$-program for $y$ of length $K_D(y)$.*

*Proof sketch.* $\mathrm{dec}^{\ast}_D$ is globally correct by definition; apply Theorem 6.4. $\square$

Combining, we obtain the summary of the dictionary.

**Theorem 7.3 (The Las Vegas dictionary).** *Let $\mathcal C$ be a Las Vegas class, $f$ one-way in $\mathcal C$, $\mathrm{fuel}$ an admissible bound with $\mathrm{fuel}(|y|)\ge K_f(y)$ for all describable $y$, $A$ a seeded family with slices in $\mathcal C_{\mathrm{Comp}}$, $R$ a finite seed list, $g$ any slack function, and $\{\mathrm{dec}_r\}$ a seeded oracle family with all induced finders in $\mathcal C_{\mathrm{Comp}}$. Then simultaneously:*

1. *there is a describable $y$ with $f(A_r(y)) \ne y$ for all $r \in R$ — Las Vegas inversion fails totally;*
2. *$A$ is not a seeded shortest finder for $f$ — Las Vegas exact compression fails;*
3. *$A$ is not a seeded approximate finder with slack $g$ — Las Vegas approximate compression fails, for every $g$;*
4. *there is a describable $y$ at which no $\mathrm{dec}_r$ is locally correct — Las Vegas prefix-decision fails;*

*and yet*

5. *$\mathcal F_{\mathrm{dec}^{\ast}_f}$ is an exact shortest-program finder for $f$.*

Items 1–4 are the four faces of a single cryptographic barrier; item 5 certifies that the barrier is about computation and not about the existence of the information.

---

## 8. Algorithms

Three algorithms carry the constructive content.

**A. Las Vegas simulation (derandomization by verification).** Input: a target $f$, a seeded family $A$, a finite seed list $R$, an input $y$. For each $r \in R$ in order, compute $c \leftarrow A_r(y)$ and test $f(c) = y$; return the first $c$ that passes, else return $y$. Cost: $|R|$ invocations of a slice plus $|R|$ evaluations of $f$. Correctness: if some seed produces a preimage, the output is a preimage (Lemma 5.3). This single procedure is what makes Las Vegas randomness worthless against verifiable tasks.

**B. Prefix reconstruction (search-to-decision).** Input: an oracle $\mathrm{dec}$, a target $y$, a length $n$. Set $w \leftarrow \varepsilon$; repeat $n$ times: if $\mathrm{dec}(y, w0, \text{remaining}-1)$ then $w \leftarrow w0$ else $w \leftarrow w1$; return $w$. Cost: exactly $n$ oracle queries, one per output bit. Correctness under global correctness is Lemma 6.2; under local correctness at $y$ alone it is Theorem 6.7. Composed with a bounded search for the least feasible length, it becomes an exact shortest-program finder (Definition 6.3, Theorem 6.4).

**C. Good-seed census (the counting certificate).** Input: a seeded family over a finite $R$, a budget $s$, a finite target set $T$. For each $y \in T$, enumerate the programs of length $\le s$ under each seed and record $|G_s(y)|$; report $\sum_{y}|G_s(y)|$ against the budget $|R|(2^{s+1}-1)$, the minimum success probability $\min_y |G_s(y)|/|R|$ against $\log_2(1/\delta)+1$, and the seeded complexities against the average-case bounds. Cost: $O(|R|\cdot 2^{s+1}\cdot \text{(decode)})$ by brute force. This is the direct experimental counterpart of Theorems 3.1–3.6 and 4.2–4.5.

---

## 9. Discussion and applications

**What randomness is worth.** The two halves of this paper give a single, quantitative answer to "can random number generators help compression?".

* *Informationally*: yes, by exactly $\log_2(1/\delta)$ bits, where $\delta$ is the failure probability you are willing to tolerate. This holds in the worst case (Corollary 3.2), on average (Theorem 4.3), tightly (Theorem 3.5), and rigidly (Theorem 4.5). It does not depend on how much entropy you consume. If failure is not allowed, the gain is zero (Corollary 3.3).
* *Computationally*: no, not at all. Every compression task in the dictionary is exactly as hard with a finite seed list as without (Theorems 5.4, 5.8, 6.9).

**A design rule.** A compressor promising to fail at most once in $2^{10}$ tries may hope for about $11$ extra bits over the deterministic ceiling and no more, whatever its seed length. Engineering effort spent lengthening the seed is misdirected; effort spent on relaxing the success requirement is the only lever that moves the bound.

**A warning to optimizers.** Any procedure that reliably finds shortest (or even near-shortest, or even merely valid) descriptions for an honest decompressor is an inverter for that decompressor read as a function. If that decompressor is a cryptographic primitive, the procedure breaks it. Since Corollary 5.6 permits arbitrary additive slack, this is not a statement about optimality: it is a statement about *ever producing a correct description*. Universal compression is universal cryptanalysis.

**Where hardness lives.** Theorem 7.2 localizes the difficulty precisely. The ideal oracle exists and solves the task; the bit-by-bit reconstruction is a correct and cheap reduction. What fails is only membership in the class. This makes the barrier a clean target for conditional lower bounds rather than a diffuse impossibility.

**Relation to time-bounded complexity.** The hardness assumptions in the literature on polynomial-time Kolmogorov complexity are usually phrased in terms of a decision problem ("is the complexity at most $n$?"), whereas the compression tasks natural to a practitioner are search problems. Sections 6 and 7 supply the bridge in a form robust enough for randomized algorithms: a decider need only be right about the *one* string being compressed, so the bridge survives the passage from worst-case correctness to seed-wise correctness. Corollary 6.10 makes the direction explicit: the decision task is at least as hard as the search task, uniformly in the seed structure.

**Scope and limitations.** Our notion of one-wayness is worst-case, uniform, and deterministic, and our seed sets are finite lists rather than distributions with a parameter. This is a deliberate minimality: it keeps the arguments purely combinatorial and makes them transfer upward to stronger hardness notions. The price is that the results say nothing directly about *distributional* compression, where an algorithm need only succeed on most inputs of a sampled distribution — precisely the gap addressed by the third conjecture below.

---

## 10. Future directions

**Conjecture 1 — The average-case randomness slack is $1$, not $3$.** For every seeded family with $|R| \le 2^{k}$ and every finite $T$ with $|T| \ge 2^{n}$ whose members are describable under some seed, $(n-k-1)|T| \le \sum_{y\in T} K^{\mathrm{seed}}(y)$; and the constant $1$ cannot be replaced by $0$. Theorem 4.3 gives $n-k-3$; numerical data for the prefix families indicate the truth is $n-k-1$, so the gap is an artifact of the proof. The layer-cake argument discards the geometric tail $\sum_{s<S}2^{k+s+1}$ in one lump, whereas a rank-based argument — order $T$ by seeded complexity and charge the $i$-th element at least $\log_2(i/|R|)$ — loses only the single bit inherent in $2^{s+1}-1$. Since the layer-cake lemma takes an arbitrary bound function as input, the rank argument can be substituted without disturbing anything downstream.

**Conjecture 2 — Verification, not randomness, is what collapses Las Vegas to deterministic.** There is a Las Vegas class $\mathcal C$, a function $f$ one-way for $\mathcal C$, and a seeded family with all slices in $\mathcal C$ and only two seeds, such that for every $y$ at least one seed outputs the *number* $K_f(y)$ correctly — even though no seeded family can output a *program*. The simulation derandomizes precisely because the answer to the search task is checkable in the class; for tasks whose output carries no certificate (a bare complexity value, a bare yes/no answer at a single query) the argument is unavailable, so a genuine Las Vegas/deterministic gap should be exhibitable. Theorem 6.9 shows the *prefix* decision task still collapses, because its answers compose into a checkable program; isolating the smallest non-composable task would pin down exactly which side of the dictionary randomness can inhabit.

**Conjecture 3 — Distributional compression is equivalent to distributional one-wayness.** For a Las Vegas class closed under sampling, the following are equivalent: (i) some honest $f$ is *distributionally* one-way — no class algorithm outputs a preimage for more than a $1 - 1/|T|$ fraction of $T = f(\mathrm{Bit}(n))$ for infinitely many $n$; (ii) some honest decompressor $D$ has the property that no class algorithm outputs shortest $D$-programs for more than a $1 - 1/|T|$ fraction of the same set. This would move the entire dictionary from the worst case to the average case, matching the counting results of §4, which are already average-case statements.

Further natural targets: making the derandomization window $[k,\,2k+1]$ of §4.4 tight; extending the search-to-decision bridge to *conditional* complexity, where the prefix carries side information; and quantifying how the total-failure conclusion of Theorem 5.4 degrades when the seed list is allowed to grow with the input length.

---

## 11. Conclusion

The pigeonhole principle bounds how many objects can have short descriptions. Cryptographic hardness bounds how many of those descriptions can be found. This paper measures the distance between the two bounds when randomness is available, and finds it to be exactly $\log_2(1/\delta)$ bits on the information side and exactly zero on the computation side.

The technical heart is a single observation about certificates. Randomness collapses to determinism whenever a candidate answer can be checked, because one may simply run every seed and keep the answer that passes. The decision version of compressibility appears to escape this, since a yes/no answer admits no certificate — but its answers, taken along a descending chain of prefixes, assemble into a program, and a program can be run. The loophole closes. Randomness helps compression exactly up to the computational-hardness boundary, and no further.
