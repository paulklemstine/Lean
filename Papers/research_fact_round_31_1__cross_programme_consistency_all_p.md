# Necessary Consistency Laws for Recorded Information Quantities: Capacity Lattices, Synergy Sandwiches, and an Entropy-Column Obstruction

**Aristotle**

*September 2026*

---

## Abstract

A long empirical programme records the same information-theoretic quantities — marginal informations of single observables ("dials"), joint informations of pairs, and capacities of multi-dial "batteries" — many times over. A cross-programme audit of eight such quantities, drawn from twenty-seven consecutive studies, found zero inconsistencies, with a maximal spread of $0.0040$ bits between repeated recordings. A numerical audit of this kind can only fail to find disagreement; by itself it cannot certify that the recorded values are *possible*. We supply the necessary laws that any family of such recordings must satisfy, working entirely within the finitary Shannon calculus of a uniformly weighted finite sample. We prove: (i) the capacity $S \mapsto I(L; F|_S)$ of a sub-battery is monotone, vanishes on the empty battery, and is bounded by the label entropy; (ii) an incremental capacity law, $\mathrm{cap}(S\cup T) \le \mathrm{cap}(S) + \sum_{i\in T} H(F_i)$, which combines with (i) into a two-sided capacity-lattice sandwich; (iii) the identity expressing pairwise synergy as interaction information, $\mathrm{Syn} = I(f;g\mid L) - I(f;g)$; (iv) a synergy sandwich $-\min(I(L;f), I(L;g)) \le \mathrm{Syn} \le \min(H(f\mid L), H(g\mid L))$, whose upper bound is attained by the XOR battery; (v) a battery synergy budget, which converts the recorded four-dial capacity into the falsifiable prediction that the dials' residual entropies total at least $4.3147$ bits; and (vi) that capacity is monotone but not submodular. Finally, an entropy-column obstruction (subadditivity) shows that the recorded joint column, whose $S_3\times S_3$ entry $2.1314$ exceeds the sum $1.0012 + 1.0012$ of its marginals, cannot consist of joint entropies; it is admissible only as a column of informations about the label. The recorded table passes all the necessary checks.

---

## 1. Introduction

### 1.1 The audit

The quantities under audit come from an empirical study of *type channels*: the sample points are primes up to a bound, and each **dial** records the splitting (Frobenius) type of a prime in a fixed number field. Fields with Galois groups $S_3$ (two of them, labelled "a" and "b"), $A_4$ and $D_4$ supply the dials. Each recorded number is an information, measured in bits, carried by one dial, a pair of dials, or the full four-dial battery about a fixed **label**. Eight quantities were recorded at least twice across the programme:

| quantity | recordings (bits) | spread |
|---|---|---|
| $S_3$a marginal | $1.0012$, $1.0012$ | $0.0000$ |
| $S_3$b marginal | $1.0008$, $1.0012$ | $0.0004$ |
| $A_4$ marginal | $0.4733$, $0.4733$ | $0.0000$ |
| $D_4$ marginal | $1.4302$, $1.4342$ | $0.0040$ |
| $S_3$a $\times$ $S_3$b joint | $2.1314$, $2.1314$ | $0.0000$ |
| $A_4 \times D_4$ joint | $1.9125$, $1.9125$ | $0.0000$ |
| $S_3$a $\times$ $S_3$b overlap | $0.9919$, $0.9919$ | $0.0000$ |
| four-field battery capacity | $8.2246$, $8.2246$ | $0.0000$ |

Zero inconsistencies; maximal spread $0.0040$ bits. The verdict of the audit is **all checks pass**.

### 1.2 The problem

Agreement between recordings is a statement about bookkeeping, not about mathematics. Two recordings may agree and both be impossible. The purpose of this paper is to state and prove the **necessary consistency laws** that any honest family of such recordings must satisfy, independently of the data, so that "all checks pass" acquires mathematical content: the recorded numbers are then consistent not only with one another but with every law in the list.

The laws are elementary in the sense that they use only Shannon's inequalities on a finite sample, but together they have three nontrivial consequences for the audit:

1. **An obstruction.** The recorded joint column cannot be a column of entropies (Theorem 7.1). This identifies what kind of quantity it records.
2. **A prediction.** The recorded battery capacity forces an as-yet-unrecorded quantity — the total residual entropy of the four dials — to be at least $4.3147$ bits (Corollary 8.3).
3. **A structural warning.** Battery capacity is not submodular (Theorem 9.1), so greedy selection of dials carries no general approximation guarantee.

### 1.3 Organisation

Section 2 sets up the counting calculus. Section 3 proves the basic properties of capacity; Section 4 the incremental law and the capacity-lattice sandwich. Section 5 defines synergy and proves its identification with interaction information; Section 6 proves the synergy sandwich and its sharpness. Section 7 proves the entropy-column obstruction and audits the recorded table. Section 8 derives the battery synergy budget and its forced prediction. Section 9 proves non-submodularity. Section 10 presents an arithmetic example, Section 11 algorithms, and Section 12 discussion and future work.

---

## 2. The finitary Shannon calculus

Throughout, $\Omega$ is a finite nonempty set with $N = |\Omega|$ points, each of weight $1/N$. In applications $\Omega$ is a finite set of primes. All logarithms are natural; to convert to bits divide by $\log 2$.

**Definition 2.1 (Statistic, fibre counts).** A *statistic* is a function $f : \Omega \to A$ into an arbitrary set $A$. For $a \in A$, the *count* $c_f(a) = |\{x\in\Omega : f(x) = a\}|$. The *image* of $f$ is the set of values $a$ with $c_f(a) > 0$.

**Definition 2.2 (Entropy).** The (empirical) entropy of $f$ is
$$H(f) = -\sum_{a \in \mathrm{im} f} \frac{c_f(a)}{N}\log \frac{c_f(a)}{N}.$$
The entropy in bits is $H_2(f) = H(f)/\log 2$.

**Definition 2.3 (Pairing).** For statistics $f : \Omega\to A$, $g : \Omega \to B$, the pair $(f,g) : \Omega \to A\times B$ is $x \mapsto (f(x), g(x))$.

**Definition 2.4 (Mutual information, residual entropy).** For a *label* $L : \Omega \to \Lambda$ and a statistic $f$,
$$I(L;f) = H(L) + H(f) - H(L,f), \qquad H(f\mid L) = H(f,L) - H(L).$$

We use the following standard facts about empirical entropy, each of which is a finite inequality about counts:

- **(E1)** $0 \le H(f) \le \log|\mathrm{im} f|$.
- **(E2)** $H(\varphi\circ f) = H(f)$ if $\varphi$ is injective; in particular $H(f,g) = H(g,f)$.
- **(E3) Subadditivity.** $H(f,g) \le H(f) + H(g)$.
- **(M1)** $0 \le I(L;f) \le \min(H(L), H(f))$.
- **(M2) Data processing.** For any function $\varphi$, $I(L;\varphi\circ f) \le I(L;f)$.
- **(M3)** $I(L;(f,g)) \le I(L;f) + H(g)$.
- **(M4)** If $f$ determines $L$ (i.e. $f(x)=f(y) \Rightarrow L(x)=L(y)$), then $I(L;f) = H(L)$.

(M3) is the chain-rule inequality $I(L;f,g) - I(L;f) = H(g\mid f) - H(g\mid L,f) \le H(g\mid f) \le H(g)$.

**Lemma 2.5 (Subsingleton statistics).** If $f$ takes values in a set with at most one element, then $H(f) = 0$.

*Proof.* The image has at most one element, so by (E1) $0 \le H(f) \le \log 1 = 0$. $\square$

**Lemma 2.6 (Information–residual split).** For any statistic $f$ and label $L$,
$$H(f) = I(L;f) + H(f\mid L).$$

*Proof.* Expand both sides using Definition 2.4 and (E2): $I(L;f) + H(f\mid L) = H(L) + H(f) - H(L,f) + H(f,L) - H(L) = H(f)$. $\square$

---

## 3. Batteries and capacity

**Definition 3.1 (Battery, sub-battery reading).** A *battery* is a family $F = (F_i)_{i\in\iota}$ of statistics $F_i : \Omega \to A$ indexed by a set $\iota$. For a finite set $S \subseteq \iota$, the *reading* of the sub-battery $S$ is the statistic
$$F|_S : \Omega \to A^S, \qquad F|_S(x) = (F_i(x))_{i\in S}.$$

**Definition 3.2 (Capacity).** The *capacity* of $S$ against the label $L$ is
$$\mathrm{cap}(S) = I(L; F|_S).$$

**Theorem 3.3 (Basic properties of capacity).** For every label $L$ and battery $F$:

1. (*Nonnegativity*) $\mathrm{cap}(S) \ge 0$;
2. (*Label ceiling*) $\mathrm{cap}(S) \le H(L)$;
3. (*Empty battery*) $\mathrm{cap}(\varnothing) = 0$;
4. (*Monotonicity*) if $S \subseteq T$ then $\mathrm{cap}(S) \le \mathrm{cap}(T)$;
5. (*Singletons*) $\mathrm{cap}(\{i\}) = I(L;F_i)$.

*Proof.* (1) and (2) are (M1). For (3), $A^{\varnothing}$ has exactly one element, so by (M1) and Lemma 2.5, $0 \le \mathrm{cap}(\varnothing) \le H(F|_\varnothing) = 0$. For (4), $F|_S = \pi\circ F|_T$ where $\pi : A^T \to A^S$ forgets the coordinates outside $S$; apply (M2). For (5), $F|_{\{i\}}$ and $F_i$ are functions of one another (via the bijection $A^{\{i\}}\cong A$), so (M2) gives both inequalities. $\square$

---

## 4. The incremental capacity law

**Lemma 4.1 (One dial).** For every finite $S\subseteq\iota$ and $j\in\iota$,
$$\mathrm{cap}(S\cup\{j\}) \le \mathrm{cap}(S) + H(F_j).$$

*Proof.* Define $u : A^S \times A \to A^{S\cup\{j\}}$ by $u(v,a)_i = v_i$ if $i\in S$ and $u(v,a)_i = a$ otherwise (so necessarily $i=j$). Then $F|_{S\cup\{j\}} = u\circ(F|_S, F_j)$. By (M2) and (M3),
$$\mathrm{cap}(S\cup\{j\}) \le I(L; (F|_S, F_j)) \le I(L;F|_S) + H(F_j). \qquad\square$$

**Theorem 4.2 (Incremental capacity law).** For all finite $S, T\subseteq\iota$,
$$\mathrm{cap}(S\cup T) \le \mathrm{cap}(S) + \sum_{i\in T} H(F_i).$$

*Proof.* Induction on $T$. For $T=\varnothing$ there is nothing to prove. If $T' = T\cup\{j\}$ with $j\notin T$, then by Lemma 4.1 and the induction hypothesis
$$\mathrm{cap}(S\cup T\cup\{j\}) \le \mathrm{cap}(S\cup T) + H(F_j) \le \mathrm{cap}(S) + \sum_{i\in T} H(F_i) + H(F_j). \qquad\square$$

**Corollary 4.3 (Capacity is bounded by dial entropies).** $\mathrm{cap}(T) \le \sum_{i\in T} H(F_i)$.

*Proof.* Take $S = \varnothing$ in Theorem 4.2 and use $\mathrm{cap}(\varnothing) = 0$. $\square$

**Theorem 4.4 (Capacity-lattice consistency).** For nested finite batteries $S\subseteq T$,
$$0 \;\le\; \mathrm{cap}(S) \;\le\; \mathrm{cap}(T) \;\le\; \min\Big(H(L),\ \mathrm{cap}(S) + \sum_{i\in T\setminus S} H(F_i)\Big).$$

*Proof.* The first two inequalities are Theorem 3.3 (1), (4). For the third, $\mathrm{cap}(T) \le H(L)$ by Theorem 3.3 (2), and since $S\cup(T\setminus S) = T$, Theorem 4.2 gives $\mathrm{cap}(T) \le \mathrm{cap}(S) + \sum_{i\in T\setminus S} H(F_i)$. $\square$

Theorem 4.4 is the complete set of constraints that the laws of this paper impose on a *chain* of recorded capacities: every recorded pair of nested batteries must respect it.

---

## 5. Synergy as interaction information

**Definition 5.1 (Synergy, dial information, conditional dial information).** For a label $L$ and two dials $f, g$:
$$\mathrm{Syn}(f,g) = I(L;(f,g)) - I(L;f) - I(L;g),$$
$$I(f;g) = H(f) + H(g) - H(f,g),$$
$$I(f;g\mid L) = H(L,f) + H(L,g) - H(L,(f,g)) - H(L).$$

Positive synergy means the pair carries more about the label than its two members separately; negative synergy means redundancy.

**Theorem 5.2 (Synergy equals interaction information).**
$$\mathrm{Syn}(f,g) = I(f;g\mid L) - I(f;g).$$

*Proof.* Expand each mutual information by Definition 2.4:
$$\mathrm{Syn} = \big[H(L) + H(f,g) - H(L,(f,g))\big] - \big[H(L) + H(f) - H(L,f)\big] - \big[H(L) + H(g) - H(L,g)\big].$$
Collecting terms gives $H(L,f) + H(L,g) - H(L,(f,g)) - H(L) - \big[H(f) + H(g) - H(f,g)\big]$, which is $I(f;g\mid L) - I(f;g)$. $\square$

The identity splits synergy exactly into a *conditional coupling* $I(f;g\mid L)\ge 0$ minus a *redundancy* $I(f;g)\ge 0$.

---

## 6. The synergy sandwich and its sharpness

**Lemma 6.1 (Pair symmetry and pair monotonicity).** $I(L;(f,g)) = I(L;(g,f))$, and $\max(I(L;f), I(L;g)) \le I(L;(f,g))$.

*Proof.* The swap $(a,b)\mapsto(b,a)$ transforms one pair into the other, and (M2) applies in both directions. The coordinate projections give $f$ and $g$ as functions of $(f,g)$, and (M2) applies again. $\square$

**Theorem 6.2 (Synergy sandwich).**
$$-\min\big(I(L;f),\, I(L;g)\big) \;\le\; \mathrm{Syn}(f,g) \;\le\; \min\big(H(f\mid L),\, H(g\mid L)\big).$$

*Proof.* *Lower bound.* By Lemma 6.1, $I(L;(f,g)) \ge I(L;f)$, so $\mathrm{Syn} \ge -I(L;g)$; symmetrically $\mathrm{Syn} \ge -I(L;f)$. Hence $\mathrm{Syn} \ge -\min(I(L;f), I(L;g))$.

*Upper bound.* By (M3), $I(L;(f,g)) \le I(L;f) + H(g)$, so $\mathrm{Syn} \le H(g) - I(L;g) = H(g\mid L)$ by Lemma 2.6. By Lemma 6.1 and (M3) with the roles exchanged, $I(L;(f,g)) = I(L;(g,f)) \le I(L;g) + H(f)$, giving $\mathrm{Syn} \le H(f\mid L)$. $\square$

**Theorem 6.3 (Sharpness: the XOR battery).** Let $\Omega = \{0,1\}^2$ (four points), $L(x_1,x_2) = x_1\oplus x_2$, $f(x_1,x_2) = x_1$, $g(x_1,x_2) = x_2$. Then
$$I(L;f) = I(L;g) = 0,\qquad I(L;(f,g)) = \log 2, \qquad \mathrm{Syn}(f,g) = \log 2 = \min\big(H(f\mid L), H(g\mid L)\big).$$
In particular, the upper bound in Theorem 6.2 is attained and cannot be improved in general.

*Proof.* Each of $L$, $f$, $g$ takes each of its two values on exactly two of the four points, so $H(L) = H(f) = H(g) = \log 4 - \log 2 = \log 2$. The pairs $(L,f)$ and $(L,g)$ are injective on $\Omega$, so $H(L,f) = H(L,g) = \log 4 = 2\log 2$. Hence $I(L;f) = \log 2 + \log 2 - 2\log 2 = 0$, and likewise $I(L;g) = 0$. The pair $(f,g)$ is the identity, so it determines $L$ and (M4) gives $I(L;(f,g)) = H(L) = \log 2$. Thus $\mathrm{Syn} = \log 2$. Finally $H(f\mid L) = H(f,L) - H(L) = 2\log 2 - \log 2 = \log 2$, and the same for $g$. $\square$

In bits: each dial alone carries $0$ bits, the pair carries $1$ bit, and the synergy of $1$ bit equals each residual entropy.

---

## 7. The entropy-column obstruction and the audit

**Theorem 7.1 (Entropy-column obstruction).** For any two statistics $f, g$ on any finite sample, if $H_2(f) = a$, $H_2(g) = b$ and $H_2(f,g) = c$ (bits), then $c \le a + b$.

*Proof.* Subadditivity (E3), divided by $\log 2 > 0$. $\square$

**Corollary 7.2 (The recorded joint column is not a column of entropies).** There do not exist statistics $f, g$ on any finite sample with
$$H_2(f) = 1.0012,\qquad H_2(g) = 1.0012, \qquad H_2(f,g) = 2.1314.$$

*Proof.* Theorem 7.1 would give $2.1314 \le 2.0024$. $\square$

Thus the $S_3$a $\times$ $S_3$b row of the audited table — self-consistent across recordings — is impossible if read as marginal and joint *entropies*. Read as *informations about the label*, it is admissible: the only constraint Theorem 6.2 imposes from below is $\mathrm{Syn}\ge -\min$, i.e. joint $\ge$ max of marginals, and the positive synergy $2.1314 - 2.0024 = 0.1290$ bits is allowed provided it is funded by the residual entropies $H(f\mid L)$, $H(g\mid L)$. The obstruction therefore settles the semantics of the column. The same arithmetic applies to the $A_4\times D_4$ row, where $1.9125 > 0.4733 + 1.4342 = 1.9075$: it too is super-additive (by $0.0050$ bits) and so cannot be an entropy triple.

**Proposition 7.3 (The recorded table passes the necessary checks).** Using the recorded values (bits):

1. *Monotonicity, marginal $\le$ joint:* $1.0012 \le 2.1314$; $0.4733 \le 1.9125$; $1.4342 \le 1.9125$.
2. *Monotonicity, joint $\le$ four-field capacity:* $2.1314 \le 8.2246$; $1.9125 \le 8.2246$.
3. *Label ceiling:* $8.2246 \le 9.5276$, the label-entropy ceiling used in the audit.
4. *Synergy lower bound:* $2.1314 - 1.0012 - 1.0012 = +0.1290 \ge -1.0012$; $1.9125 - 0.4733 - 1.4342 = +0.0050 \ge -0.4733$.
5. *Spreads:* $|1.0008 - 1.0012| = 0.0004 \le 0.0040$ and $|1.4302 - 1.4342| = 0.0040 \le 0.0040$; all other spreads are $0$.

*Proof.* Direct arithmetic. $\square$

The checks in (1)–(2) are instances of Theorem 3.3(4) (the joint reading of two dials of a battery is a sub-battery reading of the four-dial battery), (3) of Theorem 3.3(2), and (4) of Theorem 6.2. The "overlap" row is not constrained by any law in this paper; its agreement across recordings is the only check applied to it.

---

## 8. The battery synergy budget

**Definition 8.1 (Battery synergy).** For a finite battery $T$, its synergy is $\mathrm{cap}(T) - \sum_{i\in T}\mathrm{cap}(\{i\}) = \mathrm{cap}(T) - \sum_{i\in T} I(L;F_i)$.

**Theorem 8.2 (Battery synergy budget).** For every finite $T$,
$$\mathrm{cap}(T) - \sum_{i\in T} I(L;F_i) \;\le\; \sum_{i\in T} H(F_i\mid L).$$

*Proof.* By Lemma 2.6 and Theorem 3.3(5), $\sum_{i\in T} H(F_i) = \sum_{i\in T}\mathrm{cap}(\{i\}) + \sum_{i\in T} H(F_i\mid L)$. Combine with Corollary 4.3. $\square$

For two dials this is weaker than Theorem 6.2 (it has the *sum* rather than the minimum of the residual entropies), but it applies to batteries of any size.

**Corollary 8.3 (Forced residual entropy).** If a battery has capacity $8.2246$ bits and its one-dial informations sum to $3.9099$ bits, then its residual dial entropies satisfy
$$\sum_{i\in T} \frac{H(F_i\mid L)}{\log 2} \;\ge\; 4.3147 \text{ bits}.$$

*Proof.* Divide Theorem 8.2 by $\log 2$ and substitute: $8.2246 - 3.9099 = 4.3147$. $\square$

Corollary 8.3 is a falsifiable prediction: the per-dial residual entropies of the recorded four-field battery have not been recorded, and any measurement summing to less than $4.3147$ bits would expose an error somewhere in the ledger.

---

## 9. Capacity is not submodular

A set function $\phi$ on finite subsets of $\iota$ is *submodular* if $\phi(S\cup\{i,j\}) - \phi(S\cup\{i\}) - \phi(S\cup\{j\}) + \phi(S) \le 0$ for all $S$ and $i,j\notin S$ (diminishing returns). Monotone submodular functions are exactly the setting in which greedy selection enjoys the classical $(1-1/e)$ approximation guarantee.

**Theorem 9.1 (Capacity is monotone but not submodular).** Let $\Omega = \{0,1\}^2$, $L = x_1\oplus x_2$, and let the battery have two dials, $F_1 = x_1$ and $F_2 = x_2$. Then
$$\mathrm{cap}(\{1,2\}) - \mathrm{cap}(\{1\}) - \mathrm{cap}(\{2\}) + \mathrm{cap}(\varnothing) = \log 2 > 0.$$

*Proof.* By Theorem 3.3(5) and Theorem 6.3, $\mathrm{cap}(\{1\}) = \mathrm{cap}(\{2\}) = 0$. The reading $F|_{\{1,2\}}$ is injective, hence determines $L$, and (M4) gives $\mathrm{cap}(\{1,2\}) = H(L) = \log 2$. Finally $\mathrm{cap}(\varnothing) = 0$ by Theorem 3.3(3). $\square$

Monotonicity (Theorem 3.3) holds for every battery; submodularity fails already for two binary dials. The two dials are *complements*, not substitutes.

---

## 10. An arithmetic example

The XOR phenomenon occurs naturally among the primes. Let $f(p)$ and $g(p)$ be the number of roots modulo $p$ of $x^3-x-1$ (discriminant $-23$) and of $x^3+x+1$ (discriminant $-31$); these are $S_3$ cubics, and the root count ($3$, $1$ or $0$) records whether Frobenius at $p$ is the identity, a transposition or a $3$-cycle. The Frobenius permutation is even exactly when the discriminant is a square modulo $p$. Take the label $L(p) = \left(\frac{-23}{p}\right)\left(\frac{-31}{p}\right)$. Then $f$ determines the first factor and $g$ the second, so $(f,g)$ determines $L$, while — because the two fields are independent — each dial alone says almost nothing about the product.

A direct count over the $546$ primes $p\le 4000$ with $p\notin\{2,3,23,31\}$ gives (bits): $H(f)\approx 1.448$, $H(g)\approx 1.448$, $H(L)\approx 0.997$; $I(L;f)\approx 0.002$, $I(L;g)\approx 0.002$, $I(L;(f,g))\approx 0.997$; synergy $\approx 0.993$, below the sandwich ceiling $\min(H(f\mid L),H(g\mid L))\approx 1.446$. The interaction decomposition gives redundancy $I(f;g)\approx 0.007$ and conditional coupling $I(f;g\mid L)\approx 1.000$, and the capacity second difference is $\approx 0.993$ bits $>0$. This label is chosen for illustration and is not one of the audited rows; the example shows that non-submodularity and near-maximal synergy are not artefacts of toy constructions.

---

## 11. Algorithms

**Algorithm A (Empirical capacity).** Input: a sample of $N$ points, a label column $L$, dial columns $F_i$, a subset $S$. Form the tuple column $F|_S$; count the multiplicities of $L$, of $F|_S$ and of $(L,F|_S)$ with a hash map; return $H(L) + H(F|_S) - H(L,F|_S)$. Cost: $O(N|S|)$ time and $O(N)$ memory. Computing the whole capacity lattice over $k$ dials costs $O(2^k N k)$.

**Algorithm B (Consistency audit of a recorded table).** Input: repeated recordings of marginals $m_i$, pairwise joints $j_{ik}$, battery capacity $c$, label ceiling $h$, tolerance $\tau$. Check (1) every spread $\le\tau$; (2) $\max(m_i,m_k) \le j_{ik} \le c \le h$; (3) $j_{ik} - m_i - m_k \ge -\min(m_i,m_k)$; (4) flag any row with $j_{ik} > m_i + m_k$ as *not an entropy triple* (Theorem 7.1); (5) output the forced residual-entropy bound $c - \sum_i m_i$ (Corollary 8.3). Cost: $O(k^2)$ for $k$ dials.

**Algorithm C (Submodularity test).** For every $S$ and $i,j\notin S$ compute the second difference $\Delta_{ij}(S) = \mathrm{cap}(S\cup\{i,j\}) - \mathrm{cap}(S\cup\{i\}) - \mathrm{cap}(S\cup\{j\}) + \mathrm{cap}(S)$ with Algorithm A, and report positive values as witnesses of non-submodularity. Cost: $O(k^2 2^k)$ capacity evaluations, or $O(2^k)$ with memoisation of the lattice.

---

## 12. Discussion and future work

**What the audit now certifies.** With the laws above, "all checks pass" means that the recorded marginals, joints and capacity are jointly consistent with monotonicity, the label ceiling, the synergy lower bound and the recording tolerance, and that the joint column has been identified as a column of informations — as entropies it would be impossible. Necessary laws can refute but never certify: a table satisfying all of them may still be wrong. What they buy is that the remaining possible errors are those that respect all the laws.

**Limitations.** The audit uses only the recorded rows; the upper half of the synergy sandwich and the incremental law require residual and dial entropies that were not recorded, so those checks remain to be done. The overlap row is unconstrained by the present laws.

**Future directions.**

1. *Submodularity failure for the recorded battery.* Theorem 9.1 gives a toy witness; the conjecture is that the four-field Frobenius battery itself has a positive second difference for some pair of dials, consistent with the positive recorded pairwise synergy of $0.129$ bits for $S_3$a $\times$ $S_3$b.
2. *Testing the residual budget.* Record the four residual entropies and test Corollary 8.3; the conjecture is that their sum lies within $0.5$ bits of the forced bound $4.3147$.
3. *Stability under sample edits.* Conjecture: changing one of $N$ sample points moves $I(L;f)$ by at most $C\log N/N$ nats with $C\le 3$, since entropy is a sum of cell terms whose one-step increments are $O(\log N/N)$. This would convert recorded spreads ($\le 0.0040$ bits) into bounds on how far apart the underlying samples could be.
4. *Chebotarev independence and zero redundancy.* For linearly disjoint number fields the empirical Frobenius dials should satisfy $I(f;g)\to 0$ as the prime bound grows, so by Theorem 5.2 synergy tends to the conditional coupling $I(f;g\mid L)$. The arithmetic example of Section 10 shows this numerically: redundancy $\approx 0.007$ bits against coupling $\approx 1.000$ bit.

---

## Appendix: summary of laws

| law | statement |
|---|---|
| Monotonicity | $S\subseteq T \Rightarrow \mathrm{cap}(S)\le\mathrm{cap}(T)$ |
| Floor / ceiling | $\mathrm{cap}(\varnothing)=0$, $0\le \mathrm{cap}(S)\le H(L)$ |
| Incremental law | $\mathrm{cap}(S\cup T)\le \mathrm{cap}(S)+\sum_{i\in T}H(F_i)$ |
| Lattice sandwich | $0\le\mathrm{cap}(S)\le\mathrm{cap}(T)\le\min(H(L),\mathrm{cap}(S)+\sum_{T\setminus S}H(F_i))$ |
| Interaction identity | $\mathrm{Syn}=I(f;g\mid L)-I(f;g)$ |
| Synergy sandwich | $-\min(I(L;f),I(L;g))\le\mathrm{Syn}\le\min(H(f\mid L),H(g\mid L))$, sharp |
| Entropy obstruction | $H(f,g)\le H(f)+H(g)$; the row $(1.0012,1.0012,2.1314)$ is not an entropy triple |
| Synergy budget | $\mathrm{cap}(T)-\sum I(L;F_i)\le\sum H(F_i\mid L)$; forces $\ge 4.3147$ bits |
| Non-submodularity | XOR second difference $=\log 2>0$ |
