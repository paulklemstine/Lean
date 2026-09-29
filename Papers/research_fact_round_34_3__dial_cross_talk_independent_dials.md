# Dial Cross-Talk: Exact Mutual Information Between the Splitting Types of Two Cubic Polynomials

**Aristotle** (Harmonic)

*September 2026*

---

## Abstract

Let $f$ and $g$ be two integer cubic polynomials whose Galois groups are both $S_3$. At each prime $p$ unramified in both splitting fields, each polynomial displays a *splitting type* — $111$, $12$ or $3$ — which we think of as the reading of a three-position dial. We determine exactly how much Shannon information one dial carries about the other when the Frobenius pair is distributed according to the Chebotarev density theorem. If the two quadratic resolvents are different (for example, when the discriminants are coprime), the compositum has Galois group $S_3 \times S_3$ and the mutual information is exactly $0$ bits; the joint entropy is $\tfrac43 + \log_2 3$ bits, twice the entropy $\tfrac23 + \tfrac12\log_2 3$ of a single dial. If the quadratic resolvents coincide but the splitting fields are distinct, the compositum has group $S_3 \times_{C_2} S_3$ and the mutual information is exactly $1$ bit, although each marginal law is unchanged. For semiprimes $N = pq$ with pair read-outs, the values are $0$ and $2$ bits respectively. These statements rest on general results about entropy on finite uniform sample spaces, which we prove in full: count independence forces zero mutual information; entropy and mutual information are additive over product sample spaces; the data processing inequality holds; and on any fibre product over a two-element quotient, read-outs that determine the quadratic character share at least one bit. For two $S_3$ cubics this bound is attained. We compare with numerical experiments over all primes $5 \le p < 30000$. When the resolvents differ, the plug-in estimates ($0.000243$ and $0.000808$ bits) lie within the first-order bias $\approx 0.00089$ bits of the exact value $0$. When the resolvent is shared, the estimates ($1.000267$ and $1.000023$ bits) lie within $3 \cdot 10^{-4}$ of the exact value $1$.

---

## 1. Introduction

### 1.1 The question

For a monic cubic $f \in \mathbb{Z}[x]$ and a prime $p \nmid \operatorname{disc}(f)$, the reduction $f \bmod p$ factors over $\mathbb{F}_p$ in one of three ways: into three linear factors (type $111$), a linear times an irreducible quadratic (type $12$), or not at all (type $3$). The type can be read off from the number of roots of $f$ in $\mathbb{F}_p$, which is $3$, $1$ or $0$ respectively. We call the map $p \mapsto T_f(p) \in \{111, 12, 3\}$ the *dial* of $f$.

If $L_f$ is the splitting field of $f$ and $\operatorname{Gal}(L_f/\mathbb{Q}) \cong S_3$, then $T_f(p)$ is the cycle type of the Frobenius class $\operatorname{Frob}_p \subset S_3$. The Chebotarev density theorem says that the Frobenius classes are equidistributed with respect to the counting measure on the group. So the dial behaves like a random variable with law

$$\Pr[T = 111] = \tfrac16,\qquad \Pr[T = 12] = \tfrac12,\qquad \Pr[T = 3] = \tfrac13.$$

Now take two cubics $f$ and $g$ and read both dials at the *same* prime. The question of this paper is:

> **How much does the reading of one dial reveal about the reading of the other?**

We measure this by Shannon's mutual information $I(T_f ; T_g)$ in bits.

### 1.2 Answer in one line

$$I(T_f ; T_g) = \begin{cases} 0 & \text{if } \mathbb{Q}(\sqrt{\operatorname{disc} f}) \ne \mathbb{Q}(\sqrt{\operatorname{disc} g}),\\[2pt] 1 & \text{if } \mathbb{Q}(\sqrt{\operatorname{disc} f}) = \mathbb{Q}(\sqrt{\operatorname{disc} g}) \text{ and } L_f \ne L_g.\end{cases}$$

The single shared bit in the second case is the common value of the Legendre symbol $\left(\frac{\Delta}{p}\right)$, where $\Delta$ is either discriminant. Nothing else is shared.

### 1.3 Motivation and context

This work belongs to a series of experiments that treat arithmetic statistics as communication channels. A number field is a "transmitter", a prime is a "channel use", and the splitting type is the received "symbol". An earlier installment showed that a quadratic character carries exactly one bit. The present installment asks whether *two* transmitters interfere with each other.

Across $452$ experiments to date, the headline measurements for this question were:

* for primes, a plug-in estimate of $I(\text{type}_1 ; \text{type}_2) = 0.000437$ bits, with a null-model $z$-score of $-0.81$;
* for semiprimes, $I(\text{pair}_1 ; \text{pair}_2) = 0.001424$ bits, with $z = +2.79$.

These are statistics, not theorems. The purpose of this paper is to replace them with exact values and to explain the one situation in which cross-talk does occur. The verdict is **the dials are independent**. The finite-sample values are sampling bias around an exact $0$. The only possible source of cross-talk between two $S_3$ dials is a shared quadratic resolvent, and it then amounts to exactly one bit.

### 1.4 Modelling assumptions

Two classical inputs connect the arithmetic to the finite probability spaces studied below.

**(A) Galois structure of the compositum.** Let $L_f, L_g$ be $S_3$-extensions of $\mathbb{Q}$ with quadratic subfields $K_f = \mathbb{Q}(\sqrt{\operatorname{disc} f})$ and $K_g = \mathbb{Q}(\sqrt{\operatorname{disc} g})$. The field $L_f \cap L_g$ is Galois over $\mathbb{Q}$, so it corresponds to a normal subgroup of $S_3$. Hence it is $\mathbb{Q}$, the quadratic resolvent, or the whole field. Consequently:

* if $K_f \ne K_g$, then $L_f \cap L_g = \mathbb{Q}$ and $\operatorname{Gal}(L_f L_g / \mathbb{Q}) \cong S_3 \times S_3$;
* if $K_f = K_g$ but $L_f \ne L_g$, then $L_f \cap L_g = K_f$ and
$$\operatorname{Gal}(L_f L_g/\mathbb{Q}) \cong S_3 \times_{C_2} S_3 := \{(\sigma, \tau) \in S_3 \times S_3 : \operatorname{sgn}\sigma = \operatorname{sgn}\tau\}.$$

Coprime discriminants are a convenient sufficient condition in practice for $K_f \ne K_g$, but the condition that actually matters is that the quadratic resolvents are distinct.

**(B) Chebotarev.** For primes unramified in $L_f L_g$, the Frobenius class in $\operatorname{Gal}(L_f L_g/\mathbb{Q})$ is equidistributed. So the pair $(T_f(p), T_g(p))$ has the law of the pair of cycle types of a uniformly random element of the compositum group. For a semiprime $N = pq$, we model the two Frobenius elements as independent uniform draws, so the sample space is the square of the compositum group.

All results below are exact statements about uniform probability on finite sets. The arithmetic enters only through the choice of sample space described in (A) and (B).

---

## 2. Entropy on finite uniform sample spaces

Throughout, $S$ is a nonempty finite set with the uniform probability measure, and a *read-out* is any function $g : S \to B$ to a set $B$ with decidable equality. All logarithms are to base $2$.

**Definition 2.1 (fibres).** For $x \in S$, write $S_g(x) = \{y \in S : g(y) = g(x)\}$ for the fibre of $g$ through $x$. For a value $b$, write $n_b = \#\{y \in S : g(y) = b\}$.

**Definition 2.2 (uniform entropy).** The entropy of $g$ on $S$ is
$$H_S(g) = \frac{1}{|S|} \sum_{x \in S} \log_2 \frac{|S|}{|S_g(x)|} = \sum_{b} \frac{n_b}{|S|} \log_2 \frac{|S|}{n_b}.$$
This is the Shannon entropy of the push-forward of the uniform measure along $g$. It depends only on the partition of $S$ into fibres. In particular, two read-outs inducing the same partition have the same entropy, and a constant read-out has entropy $0$.

**Definition 2.3 (conditional entropy).** For read-outs $g : S \to B$ and $k : S \to C$,
$$H_S(g \mid k) = \sum_{c \in k(S)} \frac{\#k^{-1}(c)}{|S|} \, H_{k^{-1}(c)}(g).$$
That is, we average the entropy of $g$ on each fibre of $k$, weighted by the size of the fibre.

**Definition 2.4 (mutual information).**
$$I_S(g ; k) = H_S(g) - H_S(g \mid k).$$

We use three standard facts. The *chain rule* $H_S(g \mid k) = H_S(g, k) - H_S(k)$, where $(g,k)$ denotes the paired read-out. *Symmetry*, $I_S(g;k) = I_S(k;g)$, which follows from the chain rule. And the *Gibbs inequality* $I_S(g;k) \ge 0$, which follows from concavity of the logarithm.

**Definition 2.5 (count independence).** Read-outs $g$ and $k$ are *count-independent* on $S$ if for all values $b, c$
$$|S| \cdot \#\{x \in S : g(x) = b,\ k(x) = c\} = \#\{x \in S : g(x) = b\} \cdot \#\{x \in S : k(x) = c\}.$$
This is the uniform-measure form of $P(b, c) = P(b)\,P(c)$: the joint count table is the outer product of its margins divided by $|S|$.

---

## 3. General results

### 3.1 Independence and zero information

**Theorem 3.1 (independence implies zero mutual information).** If $S$ is nonempty and $g, k$ are count-independent on $S$, then $I_S(g;k) = 0$.

*Proof sketch.* Fix a value $c$ of $k$ and let $S_c = k^{-1}(c)$. For $a \in S_c$, count independence gives
$$\#\{x \in S_c : g(x) = g(a)\} = \frac{\#\{x \in S : g(x) = g(a)\} \cdot |S_c|}{|S|}.$$
Taking logarithms,
$$\log_2 \#\{x \in S_c : g(x) = g(a)\} = \log_2 |S_g(a)| + \log_2 |S_c| - \log_2 |S|.$$
Substitute this into $H_{S_c}(g)$ and multiply by the weight $|S_c|/|S|$. This gives
$$\frac{|S_c|}{|S|} H_{S_c}(g) = \frac{|S_c|}{|S|}\log_2 |S| - \frac{1}{|S|}\sum_{a \in S_c} \log_2 |S_g(a)|.$$
Now sum over $c$. The fibres $S_c$ partition $S$ and $\sum_c |S_c| = |S|$, so
$$H_S(g \mid k) = \log_2|S| - \frac1{|S|}\sum_{a\in S} \log_2|S_g(a)| = H_S(g).$$
Hence $I_S(g;k) = 0$. $\square$

**Theorem 3.2 (product sample spaces are count-independent).** Let $S$ and $T$ be finite sets and let $g : S \to D$ and $k : T \to E$ be read-outs. On $S \times T$, the read-outs $(x,y) \mapsto g(x)$ and $(x,y) \mapsto k(y)$ are count-independent.

*Proof.* For each pair of values $(b, c)$, the joint fibre is the product $g^{-1}(b) \times k^{-1}(c)$. The two marginal fibres are $g^{-1}(b) \times T$ and $S \times k^{-1}(c)$. So
$$|S||T| \cdot |g^{-1}(b)||k^{-1}(c)| = \bigl(|g^{-1}(b)||T|\bigr)\bigl(|S||k^{-1}(c)|\bigr). \qquad\square$$

**Corollary 3.3 (linearly disjoint dials share nothing).** If $S, T$ are nonempty, then $I_{S \times T}(g \circ \mathrm{pr}_1 ; k \circ \mathrm{pr}_2) = 0$. In particular, for finite groups $G, H$ and arbitrary read-outs $T_1 : G \to D$, $T_2 : H \to E$, we have $I_{G \times H}(T_1 ; T_2) = 0$. $\square$

In words: whenever the compositum group is a direct product, *every* pair of splitting-type read-outs of the two factors carries exactly zero bits about each other. Nothing specific to cubics is used.

### 3.2 Additivity over independent blocks

**Theorem 3.4 (additivity of entropy).** For nonempty finite $S, T$ and read-outs $g$ on $S$ and $k$ on $T$,
$$H_{S \times T}\bigl((x,y) \mapsto (g(x), k(y))\bigr) = H_S(g) + H_T(k).$$

*Proof sketch.* The fibre of $(g,k)$ through $(x, y)$ is $S_g(x) \times T_k(y)$. Its logarithmic size splits as $\log_2|S_g(x)| + \log_2|T_k(y)|$, and $\log_2(|S||T|) = \log_2|S| + \log_2|T|$. Summing over $S \times T$ with Fubini gives the claim. $\square$

**Corollary 3.5 (marginals).** $H_{S\times T}(g \circ \mathrm{pr}_1) = H_S(g)$. *Proof:* apply Theorem 3.4 with a constant read-out on $T$, which has entropy zero. $\square$

**Theorem 3.6 (additivity of mutual information).** For nonempty $S, T$ and read-outs $g_1, k_1$ on $S$ and $g_2, k_2$ on $T$,
$$I_{S \times T}\bigl((g_1, g_2) ; (k_1, k_2)\bigr) = I_S(g_1 ; k_1) + I_T(g_2 ; k_2).$$

*Proof sketch.* By the chain rule, $I = H(g) + H(k) - H(g, k)$ on each space. Each of the three entropies on $S \times T$ splits by Theorem 3.4. For the joint term, note that the read-out $((g_1,g_2),(k_1,k_2))$ induces the same partition as $((g_1,k_1),(g_2,k_2))$. $\square$

This is the mechanism that turns statements about primes into statements about semiprimes.

### 3.3 Data processing

**Theorem 3.7 (conditioning on less cannot reduce uncertainty).** For read-outs $k : S \to B$, $g : S \to C$ and any map $h : C \to D$,
$$H_S(k \mid g) \le H_S(k \mid h \circ g).$$

*Proof sketch.* Fix a fibre $F$ of $h \circ g$. Apply the Gibbs inequality on $F$ to get $I_F(k ; g) \ge 0$, which by the chain rule says $H_F(k, g) - H_F(g) \le H_F(k)$. Multiply by $|F|/|S|$ and sum over fibres. The left side becomes $H_S(k \mid g)$: apply the chain rule twice, using that $g$ determines $h \circ g$. The right side is $H_S(k \mid h \circ g)$ by definition. $\square$

**Corollary 3.8 (data processing inequality).** For any map $h$,
$$I_S(k ; h \circ g) \le I_S(k ; g), \qquad I_S(h \circ g ; k) \le I_S(g ; k).$$
The second inequality follows from the first by symmetry of mutual information. $\square$

### 3.4 Fibre products over a two-element quotient

**Definition 3.9.** Let $G, H, C$ be finite groups with homomorphisms $\chi_1 : G \to C$ and $\chi_2 : H \to C$. Their *fibre product* is
$$G \times_C H = \{(a,b) \in G \times H : \chi_1(a) = \chi_2(b)\}.$$
If $G = \operatorname{Gal}(L_1/\mathbb{Q})$ and $H = \operatorname{Gal}(L_2/\mathbb{Q})$, and $\chi_1, \chi_2$ cut out the same subfield $L_1 \cap L_2$, then $G \times_C H$ is the Galois group of the compositum $L_1 L_2$.

**Lemma 3.10 (fibres are products).** For every $c \in C$,
$$\{(a,b) \in G\times_C H : \chi_1(a) = c\} = \chi_1^{-1}(c) \times \chi_2^{-1}(c).$$

**Lemma 3.11 (balance).** Suppose $\chi_1, \chi_2$ are surjective and $|C| = 2$. Then for each $c \in C$, exactly half of $G \times_C H$ satisfies $\chi_1(a) = c$.

*Proof sketch.* All fibres of a surjective homomorphism have the same size, namely the size of the kernel. By Lemma 3.10, each of the two fibres of the common character therefore has $|\ker\chi_1|\cdot|\ker\chi_2|$ elements. $\square$

**Theorem 3.12 (a shared quadratic quotient forces at least one bit).** Let $\chi_1 : G \to C$ and $\chi_2 : H \to C$ be surjective homomorphisms onto a group of order $2$. Let $T_1 : G \to B$ and $T_2 : H \to B'$ be read-outs that *determine the characters*: there are maps $f_1 : B \to C$ and $f_2 : B' \to C$ with $\chi_1 = f_1 \circ T_1$ and $\chi_2 = f_2 \circ T_2$. Then
$$I_{G \times_C H}(T_1 ; T_2) \ge 1.$$

*Proof sketch.* On $S = G\times_C H$, the post-processed read-outs $f_1\circ T_1 = \chi_1$ and $f_2 \circ T_2 = \chi_2$ are *equal*. By Lemma 3.11, their common value is a fair coin on $S$. A read-out that refines a balanced two-valued read-out shares exactly one bit with it, so $I_S(\chi_1 ; \chi_2) = 1$. Applying the data processing inequality (Corollary 3.8) once on each side gives
$$1 = I_S(f_1\circ T_1 ; f_2 \circ T_2) \le I_S(T_1 ; f_2\circ T_2) \le I_S(T_1 ; T_2).\qquad\square$$

The theorem uses nothing about $S_3$. It applies to any pair of Galois extensions that share a quadratic subfield, as long as each splitting-type read-out is fine enough to detect the corresponding quadratic character.

---

## 4. The two cubic dials

Let $P_3 = S_3$ be the symmetric group on three letters. Define the splitting-type read-out $T : S_3 \to \{111, 12, 3\}$ by cycle type. Then $T^{-1}(111) = \{e\}$, $T^{-1}(12)$ is the set of three transpositions, and $T^{-1}(3)$ is the set of two $3$-cycles. The sign character is determined by the type: $\operatorname{sgn}\sigma = -1$ if and only if $T(\sigma) = 12$.

### 4.1 One dial

**Proposition 4.1.** $H_{S_3}(T) = \tfrac23 + \tfrac12 \log_2 3 \approx 1.4591$ bits.

*Proof.* The law is $(\tfrac16, \tfrac12, \tfrac13)$, so
$$H = \tfrac16\log_2 6 + \tfrac12\log_2 2 + \tfrac13\log_2 3 = \tfrac16(1 + \log_2 3) + \tfrac12 + \tfrac13 \log_2 3.\qquad\square$$

### 4.2 Distinct resolvents: the verdict

**Theorem 4.2 (the dials are independent).** On $S_3 \times S_3$,
$$I(T_1 ; T_2) = 0, \qquad H(T_1 \mid T_2) = H(T_1) = \tfrac23 + \tfrac12\log_2 3, \qquad H(T_1, T_2) = \tfrac43 + \log_2 3 \approx 2.9183.$$
Here $T_i$ denotes the type of the $i$-th coordinate.

*Proof.* The first equality is Corollary 3.3. The second follows from the definition of mutual information together with Corollary 3.5 and Proposition 4.1. The third is Theorem 3.4 applied to two copies of Proposition 4.1. $\square$

Explicitly, the joint count table on the $36$ elements of $S_3 \times S_3$ is the outer product of $(1, 3, 2)$ with itself:

| $T_1 \backslash T_2$ | $111$ | $12$ | $3$ |
|---|---|---|---|
| $111$ | $1$ | $3$ | $2$ |
| $12$ | $3$ | $9$ | $6$ |
| $3$ | $2$ | $6$ | $4$ |

### 4.3 Shared resolvent: exactly one bit

Let $S_3 \times_{C_2} S_3 = \{(\sigma,\tau) : \operatorname{sgn}\sigma = \operatorname{sgn}\tau\}$. This is the Galois group of the compositum of two distinct $S_3$-fields with the same quadratic resolvent, for example the splitting fields of $x^3 - 2$ and $x^3 - 3$, both of which contain $\mathbb{Q}(\sqrt{-3})$.

**Proposition 4.3.** $|S_3 \times_{C_2} S_3| = 18$, and the joint count table of $(T_1, T_2)$ is

| $T_1 \backslash T_2$ | $111$ | $12$ | $3$ |
|---|---|---|---|
| $111$ | $1$ | $0$ | $2$ |
| $12$ | $0$ | $9$ | $0$ |
| $3$ | $2$ | $0$ | $4$ |

*Proof.* The even pairs form $A_3 \times A_3$, which has $9$ elements with types in $\{111, 3\}^2$ in proportions $1:2:2:4$. The odd pairs are the $3 \times 3 = 9$ pairs of transpositions. $\square$

**Proposition 4.4 (marginals are unchanged).** On $S_3 \times_{C_2} S_3$, the law of $T_1$ is still $(3, 9, 6)/18 = (\tfrac16, \tfrac12, \tfrac13)$, so $H(T_1) = \tfrac23 + \tfrac12\log_2 3$.

**Proposition 4.5.** On $S_3 \times_{C_2} S_3$, $H(T_1 \mid T_2) = \tfrac12\log_2 3 - \tfrac13$.

*Proof.* We compute the entropy of $T_1$ on each fibre of $T_2$.

* On the fibre $T_2 = 111$ ($3$ elements), $T_1$ has counts $(1, 2)$, so its entropy is $\tfrac13\log_2 3 + \tfrac23\log_2\tfrac32 = \log_2 3 - \tfrac23$.
* On the fibre $T_2 = 12$ ($9$ elements), $T_1$ is constant, so its entropy is $0$.
* On the fibre $T_2 = 3$ ($6$ elements), $T_1$ has counts $(2, 4)$, so its entropy is again $\log_2 3 - \tfrac23$.

Weighting by $3/18$, $9/18$ and $6/18$ gives
$$\tfrac12(\log_2 3 - \tfrac23) = \tfrac12 \log_2 3 - \tfrac13.\qquad\square$$

**Theorem 4.6 (cross-talk is exactly one bit).** On $S_3 \times_{C_2} S_3$, $I(T_1 ; T_2) = 1$.

*Proof.* By Propositions 4.4 and 4.5,
$$I = \bigl(\tfrac23 + \tfrac12\log_2 3\bigr) - \bigl(\tfrac12\log_2 3 - \tfrac13\bigr) = 1.\qquad\square$$

**Structural explanation.** Split by the common sign. On the odd half, both dials are constant ($12$). On the even half, the sample space is the product $A_3 \times A_3$, so by Corollary 3.3 the dials are independent there. So the whole of the mutual information is the entropy of the fair sign coin, $1$ bit.

**Theorem 4.7 (sharpness).** Theorem 3.12 applies to $\chi_1 = \chi_2 = \operatorname{sgn}$ with $C = \{\pm 1\}$, because the type determines the sign. It gives $I(T_1;T_2) \ge 1$, and Theorem 4.6 shows that equality holds. So the general lower bound is attained.

**Proposition 4.8 (genuine dependence).** On $S_3 \times_{C_2} S_3$ the read-outs $T_1, T_2$ are not count-independent. For example, the cell $(12, 111)$ has count $0$, whereas $\#\{T_1 = 12\}\cdot\#\{T_2 = 111\}/18 = 9 \cdot 3/18 = 3/2 \ne 0$.

### 4.4 The dichotomy

**Theorem 4.9 (dichotomy).** For two cubics with Galois group $S_3$ and distinct splitting fields, under the modelling assumptions (A) and (B):
$$I(T_f ; T_g) = \begin{cases} 0 & \text{distinct quadratic resolvents (group } S_3\times S_3),\\ 1 & \text{shared quadratic resolvent (group } S_3 \times_{C_2} S_3).\end{cases}$$

### 4.5 Semiprimes

For $N = pq$, each cubic reports the pair $(T(p), T(q))$, one of nine values. With independent Frobenius draws at $p$ and $q$, the sample space is $\mathcal{G}\times\mathcal{G}$, where $\mathcal{G}$ is the compositum group.

**Theorem 4.10 (semiprime cross-talk).**

1. On $(S_3\times S_3)^2$: $I(\text{pair}_1 ; \text{pair}_2) = 0$.
2. On $(S_3\times_{C_2} S_3)^2$: $I(\text{pair}_1 ; \text{pair}_2) = 2$.
3. In both cases each pair read-out has entropy $H(\text{pair}_i) = \tfrac43 + \log_2 3$.

*Proof.* Parts 1 and 2 follow from Theorem 3.6 together with Theorems 4.2 and 4.6: the values are $0 + 0$ and $1 + 1$. Part 3 follows from Theorem 3.4 together with Propositions 4.1 and 4.4. $\square$

So a shared resolvent doubles the cross-talk for semiprimes, while each individual pair reading carries exactly as much information as before.

---

## 5. Algorithms

### 5.1 Exact cross-talk from a group

**Input:** a finite group $\mathcal{G} \subseteq G \times H$ (listed), read-outs $T_1, T_2$.
**Output:** $I(T_1;T_2)$ in bits.

1. Build the joint count table $n_{bc} = \#\{(a, b') \in \mathcal{G} : T_1(a)=b, T_2(b')=c\}$ and its margins $n_{b\cdot}$ and $n_{\cdot c}$.
2. Return $\sum_{b,c:\,n_{bc}>0} \frac{n_{bc}}{N}\log_2\frac{N n_{bc}}{n_{b\cdot}n_{\cdot c}}$, where $N = |\mathcal{G}|$.

The cost is $O(|\mathcal{G}|)$ time and $O(|B||C|)$ memory. Before computing any logarithm, one can test count independence exactly in integer arithmetic.

### 5.2 Empirical dial experiment

1. List the primes $5\le p<X$ with $p \nmid \operatorname{disc} f \cdot \operatorname{disc} g$.
2. For each such $p$, count the roots of $f$ and $g$ in $\mathbb{F}_p$ and map $3\mapsto 111$, $1\mapsto 12$, $0\mapsto 3$.
3. Form the $3\times 3$ contingency table and compute the plug-in mutual information.
4. Compare with the first-order (Miller–Madow) bias $\frac{(r-1)(c-1)}{2n\ln 2}$, and with a permutation null obtained by shuffling one coordinate.

Naive root counting costs $O(p)$ per prime, so $O(X^2/\log X)$ in total. It could be replaced by computing $\gcd(f, x^p - x)$ in $O(\log p)$ polynomial operations.

---

## 6. Numerical evidence

All primes $5 \le p < 30000$ not dividing either discriminant were used. Values are plug-in estimates.

| pair of cubics | resolvents | $n$ | $\hat I$ (bits) | exact $I$ |
|---|---|---|---|---|
| $x^3+x+1$ vs $x^3-x-1$ (disc $-31$, $-23$) | distinct | 3241 | 0.000243 | 0 |
| $x^3-2$ vs $x^3+x+1$ (disc $-108$, $-31$) | distinct | 3242 | 0.000808 | 0 |
| $x^3-2$ vs $x^3-3$ | both $\mathbb{Q}(\sqrt{-3})$ | 3243 | 1.000267 | 1 |
| $x^3-2$ vs $x^3-5$ | both $\mathbb{Q}(\sqrt{-3})$ | 3242 | 1.000023 | 1 |

For $n \approx 3240$, the first-order bias of the plug-in estimator for independent $3\times3$ variables is $4/(2n\ln 2)\approx 0.00089$ bits. Both distinct-resolvent estimates lie below it. Permutation-null $z$-scores (200 shuffles) were $-1.02$ and $-0.07$.

The joint table for $x^3+x+1$ against $x^3-x-1$ was

$$\begin{pmatrix} 82 & 263 & 180\\ 275 & 811 & 546\\ 170 & 554 & 360\end{pmatrix}
\quad\text{against the product-law prediction}\quad
\begin{pmatrix} 90 & 270 & 180\\ 270 & 810 & 540\\ 180 & 540 & 360\end{pmatrix}.$$

For $x^3-2$ against $x^3-3$, the observed table had $171, 363, 376, 700$ in the four even cells, $1633$ in the $(12,12)$ cell and $0$ elsewhere. The fibre-product law $1:2:2:4:9$ over $18$ predicts $180, 360, 360, 720, 1621$.

For semiprimes built from consecutive good primes ($n = 1620$), the estimate was $\hat I = 0.0243$ bits, against a $9\times 9$ first-order bias of $64/(2n\ln 2)\approx 0.0285$ bits. This larger bias, sixteen times the $3 \times 3$ value at equal $n$, explains why semiprime null $z$-scores (such as the $+2.79$ reported in the headline experiment) are more volatile than prime ones.

The finite-sample $z$-scores are statistical observations. They are not part of the theorems above.

---

## 7. Discussion

**What is exact and what is not.** Theorems 3.1–3.12 are unconditional statements about finite uniform probability spaces. Theorems 4.2–4.10 are exact computations on the groups $S_3 \times S_3$ and $S_3 \times_{C_2} S_3$. The passage to primes uses two classical inputs: the Galois-theoretic identification of the compositum group, and Chebotarev equidistribution. Both enter only through the choice of sample space.

**Coprime discriminants are only a proxy.** What matters is that the quadratic resolvents differ. Coprime discriminants usually guarantee this. The group $S_3\times S_3$ models the right condition exactly.

**Why whole bits?** In both cases the cross-talk equals the entropy of the uniform distribution on the common quotient of the two Galois groups: $\log_2 1 = 0$ for the trivial quotient and $\log_2 2 = 1$ for $C_2$. For $S_3$ this is forced by the structure: once the sign is fixed, what remains of the compositum is a direct product.

**Applications.** Heuristics that combine several independent splitting conditions — in sieve heuristics, in constructing test polynomials, in pseudo-random bit extraction from Legendre-type symbols — implicitly assume zero cross-talk. The dichotomy gives an exact criterion for when this is justified. It also gives an exact penalty (one bit per prime) when two sources share a quadratic resolvent.

---

## 8. Future work

1. **Cross-talk equals the entropy of the common quotient.** For Galois groups $G, H$ with largest common quotient $Q$ and read-outs that determine the image in $Q$, is $I \ge \log_2|Q|$, with equality under a balanced-fibre condition? The proof of Theorem 3.12 uses $|C| = 2$ only through the balance of fibres.
2. **$S_4$ and $S_5$ pairs.** For two $S_4$ quartics with the same cubic resolvent field (common quotient $S_3$), compute $I$ exactly from the class table of $S_4\times_{S_3}S_4$. The splitting type determines only the *conjugacy class* of the image in $S_3$, so the $\log_2 6$ lower bound suggested by direction 1 need not apply, and the true value is expected to be smaller.
3. **$k$-prime additivity and bias law.** For $N = p_1\cdots p_k$, prove $I = k\cdot I(T_1;T_2)$ by iterating Theorem 3.6. Quantify the plug-in bias $(3^k-1)^2/(2n\ln 2)$.
4. **Converse.** Does $I = 0$ force count independence (the equality case of Gibbs), and hence linear disjointness of the two splitting fields at the level of Frobenius statistics?

---

## 9. Conclusion

Two $S_3$ dials read at the same prime are either exactly independent or share exactly one bit. Which case holds is decided by whether their quadratic resolvents coincide. The small positive numbers seen in experiments are the familiar upward bias of plug-in entropy estimates. The underlying truth is an integer number of bits, fixed by Galois theory.
