# The Split-Count Law: the Complete Information Content of a Character-Pinned Fork

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $\chi$ be a surjective homomorphism from the unit group modulo a fixed
modulus $f$ onto an abelian group of order $n \ge 2$, and call a prime $p$
*split* when $\chi(p) = 1$. For a semiprime $N = pq$ the labels $\chi(p)$ and
$\chi(q)$ are independent and uniform, while only their product $\chi(N)$ is
observable from the residue of $N$. We determine the *complete* information such
a **character-pinned fork** carries about the residue class of $N$. Because the
two factors are exchangeable, the sufficient statistic is the **split-count**
$s = [\chi(p)=1] + [\chi(q)=1] \in \{0,1,2\}$, which is marginally
$\mathrm{Bin}(2, 1/n)$; we prove that the ordered pair of split events carries
exactly the same information as the count, and that the split event of a single
designated factor carries exactly zero. The resulting channel has the
order-universal closed form
$$
I_s(n) = H\!\left(\mathrm{Bin}(2,\tfrac1n)\right)
 - \tfrac1n H\!\left(\tfrac{n-1}{n},0,\tfrac1n\right)
 - \tfrac{n-1}{n}H\!\left(\tfrac{n-2}{n},\tfrac2n,0\right),
$$
depending on the order $n$ alone and not on the modulus, the group, or the
character. We obtain: $I_s(2) = 1$ bit exactly and $I_s(3) = \log_2 3 - 10/9 =
0.47385\ldots$; a one-bit cap $I_s(n) \le 1$ with equality **iff** $n = 2$,
proved from a general equality case for binary-input channels; the universal
comparison $I_{\mathrm{OR}}(n) \le I_{\mathrm{AND}}(n)$, strict for $n > 2$, via
a *mirror principle* for binary channels; the failure of the naive hierarchy
$I_s \ge I_{\mathrm{XOR}} \ge I_{\mathrm{AND}} \ge I_{\mathrm{OR}}$ from $n = 8$
onwards; the complete asymptotic law
$I_s(n) = \bigl(\log n + 2 - \tfrac{1}{2n} + O(n^{-2})\bigr)/(n^2\log 2)$ with
every constant exact; and, for forks of arity $r$, an exact $\chi^2$ divergence
$(n-1)^{1-r}$ yielding the **no-amplification law**
$I^{(r)}(n) \le (n-1)^{1-r}/\log 2 \to 0$, together with the arity constant
$n^r I^{(r)}(n) \log 2 - \log n \to r$. A consequence of independent interest is
that the widely quoted ceiling of $0.3113$ bits for the OR projection of a fork
is an artifact of the projection: the complete channel reaches a full bit. We
also show that the channel remains factoring-inert: it is symmetric in the
factors, is a function of $N \bmod f$ alone, and reproduces exactly what
classical reciprocity already provides.

**Keywords:** split-count, character-pinned fork, mutual information, binary
entropy, data processing inequality, $\chi^2$ divergence, quadratic character,
semiprime residues.

---

## 1. Introduction

### 1.1 The leak, and how to measure it

A product $N = pq$ of two primes hides its factors, but not perfectly. The
residue of $N$ modulo any fixed $f$ constrains the residues of $p$ and $q$, and
the question of *how much* it constrains them is a question with a numerical
answer.

The classical vehicle for such constraints is a character. Fix a modulus $f$ and
a surjective homomorphism
$$
\chi : (\mathbb{Z}/f\mathbb{Z})^\times \longrightarrow G, \qquad |G| = n \ge 2,
$$
onto an abelian group $G$. Say that a prime $p \nmid f$ **splits** when
$\chi(p) = 1$; in the classical picture $\chi$ cuts out an abelian extension and
$\chi(p) = 1$ is exactly the condition that $p$ splits completely there. For
$n = 2$ this is quadratic residuacity, for $n = 3$ cubic residuacity, and so on.

Two standard facts supply the probabilistic model. Primes equidistribute among
the classes, so $\chi(p)$ is uniform on $G$; and $\chi$ is multiplicative, so
$\chi(N) = \chi(p)\chi(q)$. For a semiprime built from two independently chosen
primes, therefore:

> **The fork model.** $\chi(p)$ and $\chi(q)$ are independent and uniform on
> $G$; the observer sees $\chi(N) = \chi(p)\chi(q)$ and nothing else.

We call the pair (hidden labels, observed product) a **character-pinned fork**.
The subject of this paper is the exact information content of a fork.

### 1.2 The wrong question and the right one

The natural first question is Boolean: "does at least one factor split?" One can
compute exactly how much $\chi(N)$ says about the answer, and the value at
$n = 2$ is
$$
I_{\mathrm{OR}}(2) = \tfrac32 - \tfrac34 \log_2 3 = 0.31128\ldots \text{ bits},
$$
which is a ceiling for the OR question over every choice of character and every
class-rate profile.

This is the wrong question. OR is one of several functions of the pair of split
events, and it destroys information: it cannot distinguish "exactly one splits"
from "both split". The right question asks for the *complete* content of the
fork. Since $pq = qp$, no observer can distinguish the two factors, so the
complete symmetric statistic is the **split-count**
$$
s = [\chi(p) = 1] + [\chi(q) = 1] \in \{0, 1, 2\},
$$
and every Boolean face — OR, AND, XOR — is a deterministic function of $s$. By
the data processing inequality, the split-count dominates all of them. Our main
object is
$$
I_s(n) := I\bigl(\text{class of } \chi(N)\ ;\ s\bigr).
$$

### 1.3 Results

* **The split-count law** (Theorem 3.3): an order-universal closed form for
  $I_s(n)$, with $I_s(2) = 1$ exactly and $I_s(3) = \log_2 3 - 10/9$.
* **Sufficiency and the which-factor wall** (Theorems 3.5, 3.6): the ordered
  pair of split events carries exactly $I_s(n)$; the split event of one
  designated factor carries exactly $0$.
* **The one-bit cap with its equality case** (Theorems 4.1–4.3):
  $I_s(n) \le 1$ always, and $I_s(n) = 1$ iff $n = 2$.
* **AND beats OR at every order** (Theorems 5.3, 5.5), through a mirror
  principle for binary channels (Theorem 5.2), with equality exactly at $n = 2$;
  and the *honest hierarchy correction* (Proposition 5.7): XOR dominates AND iff
  $n \le 7$.
* **The complete asymptotic law** (Theorems 6.2–6.5), including the exact
  additive constant $2$ and the exact second-order term $-1/(2n)$, and the
  refutation of two previously proposed decay rates (Proposition 6.6).
* **The arity-$r$ theory** (Theorems 7.3–7.7): binomial marginals at every
  arity, completeness at the quadratic characters, the exact $\chi^2$ divergence
  $(n-1)^{1-r}$, the no-amplification law and the arity constant $r$.
* **The arithmetic anchor** (Theorem 8.1): the coefficients of the arity-$r$
  table are genuine zero-sum counts in $\mathbb{Z}/n\mathbb{Z}$.
* **Factoring inertness** (Section 9): a structural account of why a full bit of
  leakage at the quadratic characters yields no factoring advantage.

---

## 2. Preliminaries: finite information theory

We fix notation and record the four general facts we shall use. All entropies
are in bits unless stated; $\log$ denotes the natural logarithm and
$\log_2 x = \log x / \log 2$.

**Definition 2.1 (tables and marginals).** A *finite joint table* is a function
$p : A \times B \to \mathbb{R}_{\ge 0}$ on finite sets with
$\sum_{a,b} p(a,b) = 1$. Its marginals are
$p_A(a) = \sum_b p(a,b)$ and $p_B(b) = \sum_a p(a,b)$, and its **mutual
information** is
$$
I(p) = \sum_{a \in A}\sum_{b \in B} p(a,b)\,
 \log_2 \frac{p(a,b)}{p_A(a)\,p_B(b)},
$$
with the convention that cells with $p(a,b) = 0$ contribute $0$. The entropy of
a weight vector $q$ is $H(q) = -\sum q_i \log_2 q_i$.

**Lemma 2.2 (log-sum inequality).** For nonnegative $a_i$ and positive $b_i$
over a finite index set,
$$
\sum_i a_i \log \frac{a_i}{b_i} \ \ge\ \Bigl(\sum_i a_i\Bigr)
 \log \frac{\sum_i a_i}{\sum_i b_i},
$$
with strict inequality as soon as some ratio $a_i/b_i$ differs from
$\bigl(\sum a_j\bigr)/\bigl(\sum b_j\bigr)$.

*Proof sketch.* Pointwise, for $x \ge 0$, $y > 0$, $c > 0$ one has
$x\log(x/y) - x\log c \ge x - cy$ (this is $\log t \ge 1 - 1/t$ rearranged), with
equality iff $x = cy$. Summing with $c = (\sum a)/(\sum b)$ makes the right-hand
side telescope to zero. $\square$

**Lemma 2.3 (data processing).** If $g : B \to C$ and $(g_*p)(a,c) =
\sum_{b : g(b) = c} p(a,b)$, then $I(g_*p) \le I(p)$.

*Proof sketch.* Group the cells of the row $a$ by fibres of $g$ and apply
Lemma 2.2 within each fibre. $\square$

**Lemma 2.4 (input cap).** $I(p) \le H(p_A)$; in particular if $|A| = 2$ then
$I(p) \le 1$ bit.

*Proof sketch.* Split each cell as
$p\log_2\frac{p}{p_A p_B} = p \log_2 \frac{p}{p_B} - p\log_2 p_A$; the first
group of terms sums to $-H(\text{output} \mid \text{input}) \le 0$ after
regrouping by the log-sum inequality, and the second sums to $H(p_A)$. The
binary case follows since a two-point distribution has entropy at most $1$. $\square$

**Lemma 2.5 (channel decomposition).** If $p(a,b) = w(a)k(a,b)$ with $w$ a prior
and $k(a,\cdot)$ conditional laws, then
$$
I(p) = H\Bigl(\textstyle\sum_a w(a) k(a,\cdot)\Bigr) - \sum_a w(a)\,H(k(a,\cdot)).
$$

**Lemma 2.6 ($\chi^2$ domination).** With
$\chi^2(p) = \sum_{a,b} \bigl(p(a,b) - p_A(a)p_B(b)\bigr)^2/\bigl(p_A(a)p_B(b)\bigr)$
one has $I(p)\log 2 \le \chi^2(p)$.

*Proof sketch.* Cellwise, $\log t \le t - 1$ gives
$p \log \frac{p}{p_Ap_B} \le \frac{(p - p_Ap_B)^2}{p_Ap_B} + (p - p_Ap_B)$, and
the linear remainders sum to zero. $\square$

**Lemma 2.7 (independence control).** A product table $p(a,b) = w(a)v(b)$ has
$I(p) = 0$.

---

## 3. The split-count channel

### 3.1 The conditional laws

Throughout, $n \ge 2$ is the order of the character and $x := 1/n$.

**Proposition 3.1 (conditional split-count laws).** In the fork model, write
$A_1$ for the event $\chi(N) = 1$ and $A_{\ne}$ for its complement. Then
$P(A_1) = 1/n$, and
$$
P(s \mid A_1) = \left(\tfrac{n-1}{n},\ 0,\ \tfrac1n\right), \qquad
P(s \mid A_{\ne}) = \left(\tfrac{n-2}{n},\ \tfrac2n,\ 0\right),
$$
listing the probabilities of $s = 0, 1, 2$.

*Proof.* Condition on $\chi(N) = c$. Given $c$, the label $\chi(p)$ is uniform
on $G$ and $\chi(q) = c\,\chi(p)^{-1}$ is determined. If $c = 1$ then
$\chi(q) = 1$ exactly when $\chi(p) = 1$, so $s \in \{0,2\}$ with
$P(s = 2) = 1/n$. If $c \ne 1$, the two events $\chi(p) = 1$ and $\chi(q) = 1$
(i.e. $\chi(p) = c$) are distinct and disjoint, each of probability $1/n$, and
they cannot both occur; so $P(s = 1) = 2/n$ and $P(s = 2) = 0$. $\square$

Note that only the *class* of $\chi(N)$ — identity or not — enters. The channel
input is binary; this is the source of the one-bit cap.

**Theorem 3.2 (binomial marginal).** The split-count is marginally
$\mathrm{Bin}(2, 1/n)$:
$$
P(s = 0) = \Bigl(\tfrac{n-1}{n}\Bigr)^2,\quad
P(s = 1) = \tfrac{2(n-1)}{n^2},\quad
P(s = 2) = \tfrac{1}{n^2}.
$$

*Proof.* Mix the two rows of Proposition 3.1 with weights $1/n$ and $(n-1)/n$;
alternatively, note directly that $[\chi(p)=1]$ and $[\chi(q)=1]$ are
independent $\mathrm{Bern}(1/n)$. $\square$

### 3.2 The law

**Theorem 3.3 (the split-count law).** For every order $n \ge 2$,
$$
I_s(n) \;=\; H\!\left(\mathrm{Bin}\bigl(2,\tfrac1n\bigr)\right)
 \;-\; \tfrac1n\,H\!\left(\tfrac{n-1}{n},\,0,\,\tfrac1n\right)
 \;-\; \tfrac{n-1}{n}\,H\!\left(\tfrac{n-2}{n},\,\tfrac2n,\,0\right).
$$
In particular $I_s$ depends only on the order $n$: not on the modulus $f$, not
on the group $G$ (cyclic or not), not on the particular character.

*Proof.* Lemma 2.5 with the prior $(1/n, (n-1)/n)$ and the conditional rows of
Proposition 3.1; the output marginal is $\mathrm{Bin}(2,1/n)$ by Theorem 3.2. All
four ingredients depend on $n$ alone. $\square$

**Theorem 3.4 (exact values).**
$$
I_s(2) = 1, \qquad
I_s(3) = \log_2 3 - \tfrac{10}{9} = 0.4738513\ldots,
$$
$$
I_s(8) = \tfrac{117}{32} + \tfrac{21}{32}\log_2 3 - \tfrac{105}{64}\log_2 7
 = 0.0905649\ldots
$$

*Proof.* Substitute in Theorem 3.3. At $n = 2$ the joint table is
$\bigl(\begin{smallmatrix} 1/4 & 0 & 1/4\\ 0 & 1/2 & 0\end{smallmatrix}\bigr)$,
whose mutual information is $1$; the mechanism is that the observable determines
the parity of $s$ exactly and that parity is a fair coin. $\square$

### 3.3 Sufficiency and the which-factor wall

**Theorem 3.5 (the split-count is sufficient).** Let $e \in \{0,1\}^2$ be the
*ordered* pair of split events, with joint law against the class of $\chi(N)$.
Then
$$
I\bigl(\text{class of }\chi(N)\,;\,e\bigr) = I_s(n).
$$
Hence no asymmetric refinement of the fork's Boolean data carries more than the
count.

*Proof sketch.* The split-count is the pushforward of $e$ under $(e_1,e_2)
\mapsto e_1 + e_2$, so "$\le$" is Lemma 2.3. For "$\ge$", the two cells of $e$
with $e_1 + e_2 = 1$ are *equal* in every row of the table (the fork law is
exchangeable), so the fibre contributes $2 \cdot \tfrac{u}{2}\log_2\frac{u/2}{v/2}
= u\log_2\frac uv$: merging them changes nothing. $\square$

**Theorem 3.6 (the which-factor wall).** The split event of a single designated
factor is *exactly independent* of the class of $\chi(N)$:
$$
I\bigl(\text{class of }\chi(N)\,;\,[\chi(p)=1]\bigr) = 0 .
$$

*Proof.* For every $c \in G$, $P(\chi(p) = 1 \mid \chi(N) = c) = 1/n$, since
$\chi(p)$ is uniform given the product. The table is a product table; apply
Lemma 2.7. $\square$

Theorems 3.5 and 3.6 pin the phenomenon precisely: a fork tells you *how many*
factors split and, to the last bit, nothing about *which*.

---

## 4. The one-bit cap and its equality case

**Theorem 4.1 (cap).** $I_s(n) \le 1$ for all $n \ge 2$; moreover $I_s(n) > 0$
for all $n \ge 2$, so the fork is never vacuous.

*Proof.* The cap is Lemma 2.4, since the input alphabet (identity class of
$\chi(N)$ or not) has two symbols. Positivity holds because the cell
$(A_1, s = 1)$ has probability $0$ while its independent-model value
$\tfrac1n \cdot \tfrac{2(n-1)}{n^2}$ is positive, and a table with one cell off
the independent value has strictly positive mutual information (strict log-sum,
Lemma 2.2). $\square$

**Theorem 4.2 (equality case for binary inputs).** Let $p$ be any joint table
with two input symbols, positive marginals, and arbitrary finite output
alphabet. If $I(p) = 1$ bit then the input prior is balanced:
$p_A(0) = p_A(1) = 1/2$.

*Proof.* By Lemma 2.4, $1 = I(p) \le H(p_A) \le 1$, so $H(p_A) = 1$; a
two-point distribution has entropy exactly one bit iff it is uniform. $\square$

**Theorem 4.3 (the cap is attained exactly at the quadratic characters).** For
$n \ge 2$,
$$
I_s(n) = 1 \iff n = 2 .
$$

*Proof.* If $I_s(n) = 1$, Theorem 4.2 forces the class prior
$(1/n, (n-1)/n)$ to be balanced, i.e. $1/n = 1/2$, i.e. $n = 2$. Conversely
$I_s(2) = 1$ by Theorem 3.4. $\square$

The argument is purely prior-theoretic and therefore robust: it applies verbatim
to *any* zero/one splitting profile whose class prior is unbalanced, not just to
the "identity class versus the rest" profile. It also explains an exhaustive
numerical finding. Let a *splitting profile* on a modulus $f$ be an arbitrary
subset $S$ of the unit group $U$ modulo $f$, a prime being declared split when
its residue lies in $S$; take as observable the *full* residue class of
$N = pq$ — one of $|U|$ symbols, not a binary flag — and compute the exact
information it carries about the split-count. Enumerating all $2^{|U|}$
profiles on nine moduli, including the non-cyclic unit groups
$C_2 \times C_2$, $C_2 \times C_4$, $C_2 \times C_2 \times C_2$ and
$C_2 \times C_6$, the maximum is exactly $1.000000$ bits in every case, and the
maximisers are exactly the index-two subgroups — the kernels of the quadratic
characters — together with their complementary cosets (complementing the
splitting predicate sends $s$ to $2 - s$, which cannot change the information).

---

## 5. The Boolean faces: OR, AND, XOR

Every Boolean question about the split pattern factors through $s$:
$$
\mathrm{OR} = \mathbf 1[s \ge 1], \qquad
\mathrm{AND} = \mathbf 1[s = 2], \qquad
\mathrm{XOR} = \mathbf 1[s = 1].
$$

**Theorem 5.1 (faces are dominated).** For every $g : \{0,1,2\} \to \{0,1\}$,
the information carried by $g(s)$ is at most $I_s(n)$. In particular
$I_{\mathrm{OR}}, I_{\mathrm{AND}}, I_{\mathrm{XOR}} \le I_s$.

*Proof.* Lemma 2.3. $\square$

Writing $H_b$ for the binary entropy function (in bits), the two one-sided faces
have closed forms
$$
I_{\mathrm{AND}}(n) = H_b\!\left(\tfrac{1}{n^2}\right)
 - \tfrac1n H_b\!\left(\tfrac1n\right),
$$
$$
I_{\mathrm{OR}}(n) = H_b\!\left(\tfrac2n - \tfrac1{n^2}\right)
 - \tfrac1n H_b\!\left(\tfrac1n\right)
 - \Bigl(1 - \tfrac1n\Bigr) H_b\!\left(\tfrac2n\right),
$$
obtained from Lemma 2.5 applied to the two binary channels
$$
k_{\mathrm{AND}} = \begin{pmatrix} 1 - \tfrac1n & \tfrac1n \\ 1 & 0\end{pmatrix},
\qquad
k_{\mathrm{OR}} = \begin{pmatrix} 1 - \tfrac1n & \tfrac1n \\
 1 - \tfrac2n & \tfrac2n\end{pmatrix},
$$
both with prior $(1/n, 1 - 1/n)$.

### 5.1 The mirror principle

The two one-sided faces share a prior and a first row and differ only in the
second row, which is $\mathrm{Bern}(0)$ for AND and $\mathrm{Bern}(2x)$ for OR,
with $x = 1/n$. These are mirror images about the *useless* value $q = x$, at
which the two rows would coincide and the channel would carry nothing. Define,
for $x \in (0,1)$ and $q \in [0,1]$, the natural-units mutual information of the
binary channel with prior $(x, 1-x)$, first row $\mathrm{Bern}(x)$ and second row
$\mathrm{Bern}(q)$:
$$
\mathcal I(x,q) = H\bigl(x^2 + (1-x)q\bigr) - x H(x) - (1-x)H(q),
$$
where here $H(y) = -y\log y - (1-y)\log(1-y)$ is binary entropy in nats.

**Theorem 5.2 (mirror principle).** Let $0 < t \le x < 1/2$. Then
$$
\mathcal I(x, x+t) \;<\; \mathcal I(x, x-t).
$$
That is: with an unbalanced prior, a second row that *undershoots* the useless
value by $t$ is strictly more informative than one that *overshoots* it by $t$.

*Proof.* The output-marginal probabilities at $q = x \pm t$ are
$x^2 + (1-x)(x \pm t) = x \pm (1-x)t$, so with
$$
\varphi(u) := H(x + u) - H(x - u)
$$
the difference $\mathcal I(x,x+t) - \mathcal I(x,x-t)$ equals
$\varphi\bigl((1-x)t\bigr) - (1-x)\varphi(t)$. Thus the claim is the strict
sub-homogeneity $\varphi(\lambda t) < \lambda \varphi(t)$ for
$\lambda = 1 - x \in (0,1)$.

For $0 < u < x$ we may differentiate:
$$
\varphi'(u) = \log\bigl((1-x)^2 - u^2\bigr) - \log\bigl(x^2 - u^2\bigr)
 = \log\frac{(1-x)^2 - u^2}{x^2 - u^2}.
$$
For $0 \le d < e < x$ one checks
$$
\bigl((1-x)^2 - e^2\bigr)\bigl(x^2 - d^2\bigr)
 - \bigl((1-x)^2 - d^2\bigr)\bigl(x^2 - e^2\bigr)
 = (1 - 2x)(e^2 - d^2) > 0
$$
precisely because $x < 1/2$; hence $\varphi'$ is *strictly increasing* on
$[0, x)$. Now $\varphi(0) = 0$, so the mean value theorem gives $d \in (0,\lambda t)$
and $e \in (\lambda t, t)$ with
$$
\frac{\varphi(\lambda t)}{\lambda t} = \varphi'(d) < \varphi'(e)
 = \frac{\varphi(t) - \varphi(\lambda t)}{t - \lambda t},
$$
and clearing denominators yields $\varphi(\lambda t) < \lambda\varphi(t)$. $\square$

**Theorem 5.3 (AND strictly beats OR for $n > 2$).** For every real $n > 2$,
$$
I_{\mathrm{OR}}(n) < I_{\mathrm{AND}}(n).
$$

*Proof.* Apply Theorem 5.2 with $x = 1/n < 1/2$ and $t = x$: the OR face is
$\mathcal I(x, x + t)$ (second row $\mathrm{Bern}(2/n)$) and the AND face is
$\mathcal I(x, x - t)$ (second row $\mathrm{Bern}(0)$); divide by $\log 2$ to
convert nats to bits. $\square$

**Theorem 5.4 (coincidence at the quadratic characters).**
$$
I_{\mathrm{AND}}(2) = I_{\mathrm{OR}}(2) = \tfrac32 - \tfrac34\log_2 3
 = 0.3112781\ldots,
\qquad I_{\mathrm{XOR}}(2) = I_s(2) = 1 .
$$

*Proof.* Direct evaluation of the three pushed tables at $n = 2$. At $x = 1/2$
the derivative $\varphi'$ above is constant in $u$, which is exactly why the
mirror principle degenerates and the two one-sided faces coincide. $\square$

**Theorem 5.5 (AND dominates OR at every order).** For all $n \ge 2$,
$I_{\mathrm{OR}}(n) \le I_{\mathrm{AND}}(n)$, with equality iff $n = 2$.

*Proof.* Combine Theorems 5.3 and 5.4. $\square$

**Theorem 5.6 (the OR ceiling is a projection artifact).** At the quadratic
characters,
$$
I_{\mathrm{OR}}(2) = 0.31128\ldots < 1 = I_s(2),
$$
so the complete channel exceeds its OR projection by a factor of $3.21$.

### 5.2 The honest hierarchy correction

At $n = 3$ the exact values are
$$
I_{\mathrm{OR}}(3) = \log_2 3 - \tfrac59\log_2 5 - \tfrac29 = 0.072780\ldots,
$$
$$
I_{\mathrm{AND}}(3) = \tfrac53\log_2 3 - \tfrac{22}{9} = 0.197160\ldots,
$$
$$
I_{\mathrm{XOR}}(3) = \tfrac43\log_2 3 - \tfrac59\log_2 5 - \tfrac49
 = 0.378879\ldots,
$$
against $I_s(3) = 0.47385\ldots$, so
$I_{\mathrm{OR}} < I_{\mathrm{AND}} < I_{\mathrm{XOR}} < I_s$. It is tempting to
conjecture this chain for all $n$. It is false.

**Proposition 5.7 (crossover at $n = 8$).** The exact values
$$
I_{\mathrm{OR}}(8) = \tfrac{31}8 + \tfrac{27}{64}\log_2 3
 - \tfrac{15}{64}\log_2 5 - \tfrac{91}{64}\log_2 7 = 0.0077455\ldots,
$$
$$
I_{\mathrm{XOR}}(8) = \tfrac{13}4 + \tfrac{21}{32}\log_2 3
 - \tfrac{25}{16}\log_2 5 - \tfrac{7}{32}\log_2 7 = 0.0480098\ldots,
$$
$$
I_{\mathrm{AND}}(8) = \tfrac{45}8 - \tfrac{63}{32}\log_2 3
 - \tfrac78 \log_2 7 = 0.0481700\ldots,
$$
$$
I_s(8) = 0.0905650\ldots
$$
satisfy $I_{\mathrm{OR}}(8) < I_{\mathrm{XOR}}(8) < I_{\mathrm{AND}}(8) <
I_s(8)$: the AND face overtakes the XOR face. Numerically the crossover happens
between $n = 7$ and $n = 8$, so $I_{\mathrm{XOR}} \ge I_{\mathrm{AND}}$ holds iff
$n \le 7$.

*Proof.* Each strict inequality reduces, after clearing denominators, to a
comparison of integer powers, e.g. $3^{84}\cdot 7^{21} < 2^{76}\cdot 5^{50}$ for
$I_{\mathrm{XOR}}(8) < I_{\mathrm{AND}}(8)$, $2^{40}\cdot 5^{85} <
3^{15}\cdot 7^{77}$ for $I_{\mathrm{OR}}(8) < I_{\mathrm{XOR}}(8)$, and
$2^{126}\cdot 7^{49} < 3^{168}$ for $I_{\mathrm{AND}}(8) < I_s(8)$. $\square$

The surviving universals are therefore: $I_s \ge$ every projection at every
order (Theorem 5.1); $I_{\mathrm{AND}} \ge I_{\mathrm{OR}}$ at every order
(Theorem 5.5); and $I_{\mathrm{XOR}} \ge I_{\mathrm{AND}}$ exactly for
$n \le 7$.

---

## 6. Asymptotics: the exact decay law

### 6.1 The four-cell expansion

Only four of the six cells of the fork table are nonzero. Writing $x = 1/n$:

**Theorem 6.1 (exact expansion).** For $n \ge 2$,
$$
I_s(n)\log 2 = 3x(1-x)\bigl(-\log(1-x)\bigr) + x^2\log n
 + (1-x)(1-2x)\log\frac{1-2x}{(1-x)^2}.
$$

*Proof sketch.* The four cells and their log-ratios are: $(A_1, s = 0)$ and the
two "one splits" contributions with ratio $(1-x)^{-1}$; $(A_1, s = 2)$ with
ratio $n$; and $(A_{\ne}, s = 0)$ with ratio $(1-2x)/(1-x)^2$. Collecting the
first three gives the coefficient $3x(1-x)$. $\square$

### 6.2 Bounds, rate, constant, second order

**Theorem 6.2 (two-sided bounds).** For all $n \ge 2$,
$$
\frac{1 + \log n}{n^2\log 2} \;\le\; I_s(n) \;\le\; \frac{3 + \log n}{n^2\log 2}.
$$

*Proof sketch.* In Theorem 6.1 the dominant term is $x^2\log n$; the remaining
cells contribute between $1/n^2$ and $3/n^2$ nats, using
$-\log(1-x) \le x/(1-x)$ and the negativity of the last log-ratio. $\square$

**Theorem 6.3 (sharp rate).**
$$
\lim_{n \to \infty} \frac{n^2 I_s(n)}{\log_2 n} = 1 .
$$

**Theorem 6.4 (exact additive constant).** For every real $n \ge 3$,
$$
\bigl| n^2 I_s(n)\log 2 - \log n - 2 \bigr| \le \frac 2n ,
$$
hence $n^2 I_s(n)\log 2 - \log n \to 2$, equivalently
$n^2 I_s(n) - \log_2 n \to 2/\log 2 = 2.8854\ldots$.

*Proof sketch.* Multiply Theorem 6.1 by $n^2$ and subtract $\log n$; the
remainder is $3n(1-x)\bigl(-\log(1-x)\bigr) + n^2(1-x)(1-2x)\log\frac{1-2x}{(1-x)^2}$.
Expanding both logarithms to second order gives $3 - 1 = 2$ with an error
controlled by $2/n$. $\square$

The constant $2$ has a clean provenance: $+3$ from the three cells in which
exactly one factor splits, $-1$ from the majority-class cell.

**Theorem 6.5 (second-order term).** For every real $n \ge 3$,
$$
\Bigl| n^2 I_s(n)\log 2 - \log n - 2 + \frac{1}{2n}\Bigr| \le \frac{12}{n^2},
$$
hence $n\bigl(n^2 I_s(n)\log 2 - \log n - 2\bigr) \to -\tfrac12$: the constant
$2$ is approached from below at exactly half the rate permitted by Theorem 6.4.

Together:
$$
\boxed{\;I_s(n) = \frac{\log n + 2 - \frac{1}{2n} + O(n^{-2})}{n^2\log 2}\;}
$$

**Proposition 6.6 (two refutations).** (i) There is no constant $c > 0$ with
$I_s(n) \ge c/n$ for all $n \ge 2$; indeed $n\,I_s(n) \to 0$. (ii) The scaled
quantity $n\,I_s(n)/\log_2 n$ tends to $0$, not to $1$; the correct
normalisation is $n^2$.

---

## 7. Forks of higher arity

Let $N = p_1 p_2 \cdots p_r$ with $r \ge 2$ independent uniform labels, and let
$k$ count the split factors, $k \in \{0, 1, \ldots, r\}$. As before the
observable is the class of $\chi(N)$: identity or not.

**Definition 7.1 (the arity-$r$ table).** Put
$$
a_m = \frac{(n-1)^m + (n-1)(-1)^m}{n}
$$
for the number of $m$-tuples of non-identity classes whose product is the
identity. The joint table is
$$
p(A_1, k) = \binom rk \frac{a_{r-k}}{n^r}, \qquad
p(A_{\ne}, k) = \binom rk \frac{(n-1)^{r-k} - a_{r-k}}{n^r},
$$
and $I^{(r)}(n)$ denotes its mutual information.

The rationale: if $k$ of the $r$ labels are the identity, the product is the
identity precisely when the remaining $m = r-k$ non-identity labels multiply to
the identity, and there are $a_m$ such tuples out of $(n-1)^m$.

**Theorem 7.2 (binomial marginals at every arity).** The split-count marginal is
$\mathrm{Bin}(r, 1/n)$: $P(k) = \binom rk (n-1)^{r-k}/n^r$.

**Theorem 7.3 (consistency).** $I^{(2)}(n) = I_s(n)$ for all $n \ge 2$.

**Theorem 7.4 (one-bit cap at every arity; completeness at $n = 2$).** For every
$r \ge 1$, $I^{(r)}(n) \le 1$; and $I^{(r)}(2) = 1$ for all $r \ge 1$. For
$r \ge 2$ and $n \ge 3$, $I^{(r)}(n) < 1$.

*Proof.* The cap is Lemma 2.4 (binary input). At $n = 2$ the parity of the
number of non-split factors is determined by the class of $\chi(N)$ and is a
fair coin, so the channel is a noiseless bit. $\square$

**Theorem 7.5 (exact $\chi^2$ divergence).** For $r \ge 1$ and $n \ge 2$,
$$
\chi^2\bigl(p^{(r)}\bigr) = \frac{n-1}{(n-1)^r} = (n-1)^{1-r}.
$$

*Proof sketch.* Cellwise, the deviation from independence in column $k$ is
proportional to $\binom rk (n-1)^{-(r-k)}$ up to a factor depending only on $n$
and $r$; summing over $k$ with the binomial theorem
$\sum_k \binom rk y^{r-k} = (1+y)^r$ at $y = 1/(n-1)$ collapses everything to
$(n-1)^{1-r}$. $\square$

**Theorem 7.6 (no-amplification law).** For $r \ge 1$ and $n \ge 2$,
$$
I^{(r)}(n) \;\le\; \frac{(n-1)^{1-r}}{\log 2},
$$
and for every fixed $n \ge 3$, $I^{(r)}(n) \to 0$ geometrically as
$r \to \infty$.

*Proof.* Lemma 2.6 with Theorem 7.5. $\square$

More factors therefore *destroy* the leak rather than accumulating it — each
additional non-identity label mixes the product class further. The single
exception is $n = 2$, where the parity channel is noiseless at every arity.

**Theorem 7.7 (the arity constant).** For every fixed $r \ge 2$ and real
$n \ge 3$,
$$
\bigl| n^r I^{(r)}(n)\log 2 - \log n - r \bigr|
 \;\le\; \frac{2r}{n-1} + \frac{6\cdot 2^r}{n},
$$
hence $n^r I^{(r)}(n)\log 2 - \log n \to r$ as $n \to \infty$.

*Proof sketch.* Group the table by the number $m = r - k$ of non-splitting
factors. The column contribution is $\binom rm T(n,m)/n^{r+1}$ with
$$
T(n,m) = \bigl((n-1)^m + (n-1)(-1)^m\bigr)
 \log\frac{(n-1)^m + (n-1)(-1)^m}{(n-1)^m}
 + (n-1)\bigl((n-1)^m - (-1)^m\bigr)
 \log\frac{(n-1)^m - (-1)^m}{(n-1)^m}.
$$
One computes $T(n,0) = n\log n$ and $T(n,1) = (n-1)n\log\frac{n}{n-1}$; for
$m \ge 2$ the two cells cancel to first order and $|T(n,m)| \le 6$. Since
$(n-1)\log\frac{n}{n-1} = 1 + O(1/n)$, the two leading columns supply
$\log n + r$ and the tail is $O(2^r/n)$. $\square$

For $r = 2$ this recovers Theorem 6.4 (constant $2$); at $r = 3$ the constant is
$3$, and so on: the constant *is* the arity.

---

## 8. The arithmetic anchor

The coefficients $a_m$ of Definition 7.1 were introduced as counts; they really
are counts, and this can be established directly in $\mathbb{Z}/n\mathbb{Z}$.

**Theorem 8.1 (zero-sum counts).** Let $n \ge 2$ and let $m \ge 0$. The number
of $m$-tuples $(y_1,\ldots,y_m)$ of nonzero elements of
$\mathbb{Z}/n\mathbb{Z}$ with $\sum y_i = 0$ is
$$
A_m = \frac{(n-1)^m + (n-1)(-1)^m}{n},
$$
and for any fixed $c \ne 0$ the number with $\sum y_i = c$ is
$$
B_m = \frac{(n-1)^m - (-1)^m}{n},
$$
*the same for every nonzero target $c$*, whether or not $n$ is prime.

*Proof.* Peel off the first coordinate. If $\sum_{i \le m+1} y_i = 0$ then
$y_1$ ranges over the $n-1$ nonzero classes and the rest sum to $-y_1 \ne 0$,
giving $A_{m+1} = (n-1)B_m$. If the target is $c \ne 0$, then $y_1 = c$ leaves a
zero-sum tail and the other $n-2$ choices leave a nonzero-sum tail, giving
$B_{m+1} = A_m + (n-2)B_m$. With $A_0 = 1$, $B_0 = 0$ the coupled recursion has
the stated solution, as one verifies by substitution (the characteristic roots
are $n-1$ and $-1$). $\square$

The uniformity of $B_m$ over nonzero targets is worth a remark: for composite
$n$ there is no unit acting transitively on the nonzero classes, so this is not
a symmetry statement but an honest consequence of the two-term recursion. It is
what makes the arity-$r$ table order-universal even for non-cyclic groups.

---

## 9. Why the leak is factoring-inert

The split-count law says that a quadratic fork leaks one full bit — the largest
value attainable by any character-pinned fork of any order on any modulus. It is
important to explain why this does not translate into an attack.

**(a) Symmetry.** By Theorem 3.6 the leak is exactly symmetric: the split event
of a designated factor is *independent* of the observable. The channel reports
how many factors split; it never reports which. Any factoring strategy needs an
asymmetry between $p$ and $q$, and there is provably none here.

**(b) It is a residue dial.** Everything the channel delivers is a function of
$N \bmod f$, computable in polynomial time from $N$ alone. Conditioning on the
residue of $N$ does not require, and does not provide, any knowledge of the
factorisation.

**(c) The Chinese Remainder seal.** For a composite modulus the character
factors through the CRT decomposition, and the fork channels for coprime moduli
are independent. Combining $t$ different moduli of orders $n_1, \ldots, n_t$
gives at most $\sum_i I_s(n_i)$ bits, each about a *different* residue class
that is already computable; no coupling to the factorisation is created.

**(d) It is classical reciprocity, quantified.** At $n = 2$ the full bit is
exactly the Jacobi symbol of $N$: the observable determines the parity of the
number of non-residue factors and nothing else. That statement is the classical
reciprocity law, known to be efficiently computable and factoring-useless.

**(e) Arity kills it.** By Theorem 7.6 the leak decays geometrically in the
number of factors for $n \ge 3$: an adversary cannot accumulate information by
considering multi-prime moduli.

Numerical experiments support the model with high precision. Over tens of
thousands of semiprimes below $2^{22}$ across eight moduli, the measured channel
tracks the closed form: at order $3$, moduli $7$, $9$ and $21$ give $0.4731$,
$0.4718$, $0.4755$ against the predicted $0.47385$; at order $4$, modulus $16$
gives $0.2894$ against $0.29474$; at order $5$, modulus $11$ gives $0.2060$
against $0.20271$; at order $6$, modulus $7$ gives $0.1482$ against $0.14868$.
The empirical split-count distributions match $\mathrm{Bin}(2,1/n)$ throughout,
and the which-factor channel measures $0.0000$–$0.0003$ bits — statistical zero,
as Theorem 3.6 demands. Controls behave: characters on moduli coprime to the
observable register $0.0001$–$0.0003$ bits (flat), and replacing the modulus by
its square leaves the channel invariant at $I_s(n)$.

---

## 10. Algorithms

Three routines suffice to reproduce everything above.

**Algorithm A (exact channel evaluation).** Given $n$, build the $2 \times 3$
table $\bigl(\pi_a k_{a,s}\bigr)$ with $\pi = (1/n, (n-1)/n)$ and the rows of
Proposition 3.1, then sum $p\log_2\frac{p}{p_A p_B}$ over the four nonzero
cells. Cost $O(1)$. The same routine with a pushforward map $g$ evaluates any
Boolean face; with the arity-$r$ table it evaluates $I^{(r)}(n)$ in $O(r)$
arithmetic operations (using exact rationals for $a_m$).

**Algorithm B (empirical channel estimation).** Sieve primes up to a bound $B$;
form semiprimes $N = pq$ coprime to $f$; for each, record the observable class
$[\chi(N) = 1]$ and the split-count $[\chi(p)=1] + [\chi(q)=1]$; accumulate a
$2 \times 3$ contingency table and return its plug-in mutual information. Cost
$O(B\log\log B)$ for the sieve plus $O(M)$ for $M$ samples. The plug-in estimator
has an upward bias of order $(\#\text{cells})/(2M\log 2)$, negligible for
$M \sim 10^4$–$10^5$.

**Algorithm C (profile enumeration).** For a fixed modulus $f$ with unit group
$U$, enumerate all zero/one profiles $\sigma : U \to \{0,1\}$ (there are
$2^{|U|}$), and for each compute the exact channel between $[\chi(N) \in
\sigma^{-1}(1)]$ and the split-count of the induced splitting condition. Cost
$O(2^{|U|}|U|^2)$; feasible for $|U| \le 20$. This is how the one-bit maximum,
attained only at quadratic kernels, is confirmed on non-cyclic groups.

---

## 11. Discussion

Three general lessons emerge.

**Choose the sufficient statistic before quoting a ceiling.** The $0.3113$-bit
ceiling for the OR question is correct and sharp *for that question*. Reported
as "what a fork carries", it understates the truth by a factor of $3.21$ at the
quadratic characters. The exchangeability of $pq$ is what identifies the
split-count as the complete symmetric statistic, and once that is done the
computation is elementary.

**Unbalanced priors break Boolean symmetry.** The mirror principle (Theorem 5.2)
is a general fact about binary channels with an unbalanced prior: the
deterministic side of the mirror is more informative. AND beating OR at every
order is a corollary; the equality at $n = 2$ is the degenerate balanced case.
The same mechanism should govern other one-sided-versus-one-sided comparisons in
statistical inference on rare events.

**Beware plausible hierarchies.** The chain
$I_s \ge I_{\mathrm{XOR}} \ge I_{\mathrm{AND}} \ge I_{\mathrm{OR}}$ is true for
$n \le 7$ and false thereafter. Two of its three links are theorems; the third
crosses over. The exact values at $n = 8$ settle it by integer certificates such
as $3^{84}\cdot 7^{21} < 2^{76}\cdot 5^{50}$.

Structurally, the picture is now complete for this family of leaks. There is one
number, $I_s(n)$; it is bounded by one bit; it is maximised only by the
quadratic characters; it decays like $\log_2 n / n^2$ with all constants known;
it degrades geometrically in the number of factors; and it is symmetric in the
factors and computable from the residue, hence useless for factoring.

---

## 12. Future directions

1. **Beyond zero/one profiles.** We treated the observable as the binary event
   $\chi(N) = 1$. The full class of $\chi(N)$ is an $n$-ary observable; the
   corresponding channel is capped by $\log_2 n$ rather than $1$ bit, and its
   exact law and maximisers are open.
2. **Correlated labels.** The model assumes independent uniform labels. For
   semiprimes drawn from restricted families (balanced primes, primes in fixed
   progressions, strong primes), the labels are still uniform but the sampling
   may induce correlations; quantifying the resulting deviation from $I_s(n)$ is
   a concrete next step.
3. **Non-abelian pinning.** Replacing $\chi$ by a Frobenius class in a
   non-abelian Galois group makes "split" a conjugacy-class condition and the
   product structure a class-multiplication problem. Does an analogue of the
   split-count remain sufficient?
4. **Higher moments of the mirror principle.** Theorem 5.2 compares two mirror
   points. A full description of $q \mapsto \mathcal I(x,q)$'s curvature would
   quantify how much any perturbed face loses, giving sharp bounds for arbitrary
   noisy projections rather than just Boolean ones.
5. **Joint multi-modulus channels.** Section 9(c) bounds the combined leak by a
   sum. Establishing exactly when the sum is attained — i.e. when the fork
   channels for coprime moduli are jointly independent given the observable —
   would close the last structural gap.
6. **Estimator theory.** The plug-in estimator used in the numerical experiments
   is biased upward by $O(1/M)$. Since $I_s(n)$ is $O(\log n / n^2)$, detecting
   the channel at large $n$ requires $M \gg n^2/\log n$ samples; a matched
   estimator with provable coverage would make large-order experiments
   meaningful.

---

## Appendix: reference values

| $n$ | $I_s(n)$ | $I_{\mathrm{XOR}}$ | $I_{\mathrm{AND}}$ | $I_{\mathrm{OR}}$ |
|---|---|---|---|---|
| 2 | 1.000000 | 1.000000 | 0.311278 | 0.311278 |
| 3 | 0.473851 | 0.378879 | 0.197160 | 0.072780 |
| 4 | 0.294737 | 0.204434 | 0.134471 | 0.035880 |
| 5 | 0.202710 | 0.127621 | 0.097907 | 0.021537 |
| 6 | 0.148683 | 0.087159 | 0.074785 | 0.014393 |
| 7 | 0.114105 | 0.063273 | 0.059201 | 0.010306 |
| 8 | 0.090565 | 0.048010 | 0.048170 | 0.007746 |
| 9 | 0.073775 | 0.037669 | 0.040053 | 0.006036 |
| 10 | 0.061356 | 0.030342 | 0.033894 | 0.004837 |
| 11 | 0.051897 | 0.024961 | 0.029100 | 0.003963 |
| 12 | 0.044517 | 0.020894 | 0.025290 | 0.003306 |

(The AND/XOR crossover between $n = 7$ and $n = 8$ is visible in columns three
and four.)

| $n$ | $n^2 I_s(n)\log 2 - \log n$ | $2 - \tfrac{1}{2n}$ |
|---|---|---|
| 10 | 1.950312 | 1.950000 |
| 100 | 1.995000 | 1.995000 |
| 1000 | 1.999500 | 1.999500 |
| 10000 | 1.999950 | 1.999950 |

| $r$ | $I^{(r)}(2)$ | $I^{(r)}(3)$ | $I^{(r)}(4)$ | bound $(n-1)^{1-r}/\log 2$ at $n=3$ |
|---|---|---|---|---|
| 2 | 1.000000 | 0.473851 | 0.294737 | 0.721348 |
| 3 | 1.000000 | 0.233473 | 0.101473 | 0.360674 |
| 4 | 1.000000 | 0.112964 | 0.033943 | 0.180337 |
| 5 | 1.000000 | 0.054386 | 0.011177 | 0.090168 |
