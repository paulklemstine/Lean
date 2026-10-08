# The Dial-Overlap Law: Fields Sharing a Galois Quotient Are Redundant by Exactly Its Entropy

**Aristotle**

*2026-10-08*

---

## Abstract

Attach to each number field a *dial*: the map sending an unramified prime $p$ to its splitting type (equivalently, the conjugacy class of its Frobenius). By the Chebotarev density theorem the Frobenius pair of a prime in two fields $L_1, L_2$ is equidistributed on $\mathrm{Gal}(L_1L_2/\mathbb{Q})$. When $L_1$ and $L_2$ share a Galois subfield with group $C$, this group is the fibre product $G\times_C H$. We study the mutual information between the two dials in the resulting uniform model.

We prove an *abstract overlap law*. On a finite uniform sample space, if two readouts both determine a label $\kappa$ and are independent on every fibre of $\kappa$, then their mutual information equals $H(\kappa)$ exactly. Fibrewise independence alone already bounds the mutual information by $H(\kappa)$. Fibre products satisfy fibrewise independence automatically: over each value of the shared character they are honest direct products. This gives the **Overlap Law**: readouts that determine the shared character share exactly $\log_2|C|$ bits, and no readouts share more.

The special case $|C|=2$ is the **Partial-Overlap Law**: two fields that share a quadratic subfield are exactly one bit redundant, whatever their Galois groups. We work out the $S_3$ case completely. The compositum group has order $18$ and the joint splitting-type table is $1:2:2:4:9$. Type agreement is $7/9$, made up of $9/9$ on the inert fibre and $5/9$ on the split fibre. Mutual information is exactly $1$ bit.

These results complete a three-rung ladder for pairs of fields: coprime ($0$ bits), shared quadratic subfield ($1$ bit), same field ($H(T)=\tfrac23+\tfrac12\log_2 3$ bits). We also prove a negative result. Sign-level (residue-visible) mutual information equals $1$ bit for both partial-overlap and same-field pairs, so it cannot separate them, whereas type agreement and full-type redundancy can. Further results cover $S_n\times_{C_2}S_m$ for all $n,m\ge2$, cyclic quartic pairs $C_4\times_{C_2}C_4$, and three dials over a common subfield (total correlation $2\log_2|C|$, co-information $+\log_2|C|$). Experiments on all primes $7<p<60000$ for two $S_3$ pairs found by a scan of $56{,}410$ cubics agree with every prediction to within finite-sample error.

---

## 1. Introduction

### 1.1 Prime dials

Let $f\in\mathbb{Z}[x]$ be an irreducible cubic with splitting field $L$ and $\mathrm{Gal}(L/\mathbb{Q})\cong S_3$. For a prime $p$ not dividing the discriminant of $f$, the number of roots of $f$ modulo $p$ is $3$, $1$ or $0$. Correspondingly $p$ has splitting type $111$, $12$ or $3$ in the cubic field, and its Frobenius conjugacy class in $S_3$ is the identity, a transposition, or a 3-cycle. The map $p\mapsto$ splitting type is what we call a *dial*. By Chebotarev, the Frobenius element behaves like a uniformly random element of $S_3$. The dial therefore shows $111$, $3$, $12$ with frequencies $1/6$, $2/6$, $3/6$, and carries entropy

$$H(T)=\tfrac16\log_2 6+\tfrac13\log_2 3+\tfrac12\log_2 2=\tfrac23+\tfrac12\log_2 3\approx 1.4591\ \text{bits}.$$

### 1.2 The open cell

Read two dials on the same prime. Two regimes were already understood.

1. If the two splitting fields are linearly disjoint (*coprime* discriminants), the Frobenius pair is uniform on $S_3\times S_3$ and the dials are independent.
2. If the two cubics define the *same* field, the dials coincide and share the full $H(T)$.

The intermediate regime was open. It consists of genuinely different $S_3$ fields that share their quadratic resolvent field $\mathbb{Q}(\sqrt d)$. A scan of $56{,}410$ $S_3$ cubics produced two such pairs:

| $d$ | cubic 1 | disc | cubic 2 | disc |
|---|---|---|---|---|
| $-7$ | $x^3-5x-5$ | $-175=-7\cdot5^2$ | $x^3-3x-5$ | $-567=-7\cdot9^2$ |
| $-3$ | $x^3-6x-6$ | $-108=-3\cdot6^2$ | $x^3-3$ | $-243=-3\cdot9^2$ |

The measured mutual-information deficits relative to full redundancy were $+0.9998$, $+0.9998$ and $+1.0000$ bits. This paper explains why the answer is *exactly* one bit and proves a general law that contains it.

A methodological remark is in order. Discriminant *values* are not field invariants: $-175$ and $-567$ differ, yet they define the same quadratic field because they differ by a square factor (the "index-squared trap"). The relevant object is always the field $\mathbb{Q}(\sqrt{\mathrm{disc}})$, never the integer.

### 1.3 Summary of results

- **Abstract Overlap Law (Theorem 3.3).** On a finite uniform space, let $g$ and $k$ both determine a label $\kappa$ and be independent on each fibre of $\kappa$. Then $I(g;k)=H(\kappa)$.
- **Overlap Ceiling (Theorem 3.4).** Fibrewise independence alone gives $I(g;k)\le H(\kappa)$.
- **Fibre-product structure (Propositions 4.2 and 4.4).** Over each value of the shared character, $G\times_C H$ is a direct product. Moreover $|C|\cdot|G\times_C H|=|G|\cdot|H|$, and the shared character is uniform.
- **Overlap Law (Theorem 4.6).** Character-determining readouts share exactly $\log_2|C|$ bits, and arbitrary readouts share at most $\log_2|C|$.
- **Partial-Overlap Law (Corollary 4.7).** Sharing a quadratic subfield costs exactly one bit.
- **The ladder (Theorem 5.1), the $S_3$ tables (Theorem 6.1), insight L11 (Theorem 6.3), cyclic quartics (Theorem 7.2), three dials (Theorem 8.2).**

---

## 2. The counting-entropy framework

Throughout, $s$ is a non-empty finite set equipped with the uniform probability measure, and a *readout* is any function $g:s\to B$ into a set with decidable equality. All logarithms are base $2$.

**Definition 2.1 (Entropy of a readout).** For $g:s\to B$ write $s_b=\{x\in s: g(x)=b\}$. The entropy of $g$ is

$$H_s(g)=-\sum_{b}\frac{|s_b|}{|s|}\log\frac{|s_b|}{|s|}=\log|s|-\frac1{|s|}\sum_{x\in s}\log|s_{g(x)}|.$$

**Definition 2.2 (Conditional entropy and mutual information).** For readouts $g$ and $\kappa:s\to C$, write $s^c=\{x\in s:\kappa(x)=c\}$ for the fibres of $\kappa$ and set

$$H_s(g\mid\kappa)=\sum_{c}\frac{|s^c|}{|s|}\,H_{s^c}(g),\qquad I_s(g;k)=H_s(g)-H_s(g\mid k).$$

We use the following standard facts freely:

- the chain rule $H_s(g\mid k)=H_s(g,k)-H_s(k)$, where $(g,k)$ denotes the paired readout;
- non-negativity $I_s(g;k)\ge 0$;
- the data-processing (coarsening) inequality $I_s(\phi\circ g;k)\le I_s(g;k)$;
- the product rule: on $s=A\times B$, readouts of the two coordinates are independent and $H(g_1,g_2)=H(g_1)+H(g_2)$.

**Definition 2.3 (Determination).** A readout $g$ *determines* a label $\kappa$ on $s$ if $g(x)=g(y)$ implies $\kappa(x)=\kappa(y)$ for all $x,y\in s$. Equivalently, $\kappa=\phi\circ g$ for some function $\phi$.

**Definition 2.4 (Fibrewise independence).** Readouts $g,k$ are *fibrewise independent given $\kappa$* if, for every value $c$,

$$H_{s^c}(g,k)=H_{s^c}(g)+H_{s^c}(k).$$

---

## 3. The abstract overlap law

**Lemma 3.1 (Chain rule along a determined label).** If $g$ determines $\kappa$, then $H_s(g)=H_s(\kappa)+H_s(g\mid\kappa)$.

*Proof.* Because $g$ determines $\kappa$, the readouts $(g,\kappa)$ and $g$ have the same fibres, so $H_s(g,\kappa)=H_s(g)$. The chain rule gives $H_s(g\mid\kappa)=H_s(g,\kappa)-H_s(\kappa)=H_s(g)-H_s(\kappa)$. $\square$

**Lemma 3.2 (Conditional splitting).** If $g$ and $k$ are fibrewise independent given $\kappa$, then $H_s((g,k)\mid\kappa)=H_s(g\mid\kappa)+H_s(k\mid\kappa)$.

*Proof.* Expand each side as a weighted sum over the fibres $s^c$, and apply the hypothesis term by term. $\square$

**Theorem 3.3 (Abstract Overlap Law).** Let $g$ and $k$ both determine $\kappa$, and let them be fibrewise independent given $\kappa$. Then

$$I_s(g;k)=H_s(\kappa).$$

*Proof.* The pair $(g,k)$ also determines $\kappa$. Lemma 3.1 applied to $g$, to $k$ and to $(g,k)$ gives

$$H(g)=H(\kappa)+H(g\mid\kappa),\quad H(k)=H(\kappa)+H(k\mid\kappa),\quad H(g,k)=H(\kappa)+H((g,k)\mid\kappa).$$

By Lemma 3.2 the last conditional term equals $H(g\mid\kappa)+H(k\mid\kappa)$. Therefore

$$I(g;k)=H(g)+H(k)-H(g,k)=2H(\kappa)-H(\kappa)=H(\kappa).\qquad\square$$

**Theorem 3.4 (Overlap Ceiling).** If $g$ and $k$ are fibrewise independent given $\kappa$, then $I_s(g;k)\le H_s(\kappa)$, *whether or not* $g$ and $k$ determine $\kappa$.

*Proof.* Each augmented readout $\tilde g=(g,\kappa)$ and $\tilde k=(k,\kappa)$ determines $\kappa$. They are still fibrewise independent, because $\kappa$ is constant on each fibre and adding a constant coordinate does not change entropies there. Theorem 3.3 gives $I(\tilde g;\tilde k)=H(\kappa)$. Since $g$ is a coarsening of $\tilde g$ (first projection) and $k$ is a coarsening of $\tilde k$, two applications of data processing give $I(g;k)\le I(g;\tilde k)\le I(\tilde g;\tilde k)=H(\kappa)$. $\square$

**Lemma 3.5 (Balanced labels).** Suppose every fibre of $\kappa$ that meets $s$ has size $|s|/m$ for some integer $m>0$. Then $H_s(\kappa)=\log m$.

*Proof.* In the second formula of Definition 2.1 every term equals $\log(|s|/m)$. $\square$

---

## 4. Fibre products: two fields sharing a subfield

**Definition 4.1 (Fibre product).** Let $G,H,C$ be finite groups with homomorphisms $\chi_1:G\to C$ and $\chi_2:H\to C$. Their fibre product is

$$G\times_C H=\{(g,h)\in G\times H:\ \chi_1(g)=\chi_2(h)\}.$$

It contains $(1,1)$, so it is non-empty.

*Arithmetic meaning.* Let $L_1$ and $L_2$ be Galois over $\mathbb{Q}$ with groups $G$ and $H$, and suppose $L_1\cap L_2=K$ is Galois over $\mathbb{Q}$ with group $C$, with $\chi_i$ the restriction maps (which are surjective). Then $\mathrm{Gal}(L_1L_2/\mathbb{Q})\cong G\times_C H$. By Chebotarev, the pair $(\mathrm{Frob}_p|_{L_1},\mathrm{Frob}_p|_{L_2})$ of an unramified prime is equidistributed on $G\times_C H$, up to conjugacy in a way that does not affect class-function readouts. The uniform distribution on $G\times_C H$ is therefore the natural model for two dials read on a common prime. This identification and the Chebotarev equidistribution are the *only* arithmetic inputs. Everything below is exact finite combinatorics about the model.

**Proposition 4.2 (Fibres are products).** For every $c\in C$,

$$\{(g,h)\in G\times_C H:\chi_1(g)=c\}=\chi_1^{-1}(c)\times\chi_2^{-1}(c).$$

Consequently, for any readouts $T_1:G\to B$ and $T_2:H\to B'$, the readouts $T_1(g)$ and $T_2(h)$ are fibrewise independent given the shared character. On every fibre their mutual information is exactly $0$.

*Proof.* The set identity is the definition of $G\times_C H$. On a product of two non-empty sets, readouts of different coordinates satisfy the product rule. An empty fibre contributes nothing. $\square$

Proposition 4.2 is the heart of the matter. **All correlation between the two fields beyond the shared character is zero.**

**Lemma 4.3.** If $\chi:G\to C$ is surjective, every fibre $\chi^{-1}(c)$ is a coset of $\ker\chi$, so $|G|=|C|\cdot|\chi^{-1}(c)|$.

**Proposition 4.4 (Order formula and uniformity).** If $\chi_1$ and $\chi_2$ are surjective, each value $c\in C$ of the shared character occupies the same number $|\ker\chi_1|\cdot|\ker\chi_2|$ of elements of $G\times_C H$. In particular

$$|C|\cdot|G\times_C H|=|G|\cdot|H|,$$

and by Lemma 3.5 the shared character carries exactly $\log|C|$ bits.

*Proof.* By Proposition 4.2 and Lemma 4.3 the fibre over $c$ has $(|G|/|C|)(|H|/|C|)$ elements. Summing over the $|C|$ values gives the formula. $\square$

For $S_3\times_{C_2}S_3$ this gives $2\cdot 18=6\cdot 6$.

**Definition 4.5.** A readout $T_1:G\to B$ *determines the character* if $\chi_1=f_1\circ T_1$ for some $f_1:B\to C$. For example, the cycle type of a permutation determines its sign.

**Theorem 4.6 (The Overlap Law).** Let $\chi_1:G\to C$ and $\chi_2:H\to C$ be surjective homomorphisms of finite groups.

1. If $T_1$ and $T_2$ determine the character, then on the uniform space $G\times_C H$
$$I(T_1;T_2)=\log_2|C|.$$
2. For *arbitrary* readouts $T_1$ and $T_2$, $\ 0\le I(T_1;T_2)\le\log_2|C|$.

*Proof.* Take $\kappa(g,h)=\chi_1(g)$, which equals $\chi_2(h)$ on the fibre product. Fibrewise independence holds by Proposition 4.2. For (1), Theorem 3.3 gives $I=H(\kappa)$, and $H(\kappa)=\log|C|$ by Proposition 4.4. For (2), use Theorem 3.4 instead. $\square$

**Corollary 4.7 (Partial-Overlap Law).** If $|C|=2$, so that the two fields share a quadratic subfield and nothing more, then character-determining readouts share **exactly one bit**. This holds for arbitrary finite Galois groups $G$ and $H$, and no readouts share more.

**Corollary 4.8 (Symmetric groups).** For all $n,m\ge2$, on $S_n\times_{C_2}S_m$ (both maps the sign), the cycle-type readouts share exactly one bit. Arithmetically: an $S_n$ field and an $S_m$ field with the same quadratic resolvent field have splitting-type dials that are exactly one bit redundant.

*Proof.* The sign is surjective for $n\ge2$, and the cycle type determines the sign as $(-1)^{\sum(\ell_i-1)}$. $\square$

---

## 5. The overlap ladder

**Theorem 5.1 (Ladder).** Let $\chi_1:G\to C$ and $\chi_2:H\to C$ be surjective.

1. *(Coprime rung.)* If $C$ is trivial, then $G\times_C H=G\times H$ and **every** pair of readouts has $I=0$.
2. *(Shared-quotient rung.)* For all readouts, $0\le I\le\log|C|$, with equality on the right for character-determining readouts.
3. *(Same-field rung.)* On the diagonal $G\times_G G=\{(g,g)\}$ (identity maps), the full Frobenius readouts share exactly $\log|G|$ bits.

*Proof.* (1) is Theorem 4.6(2) with $\log 1=0$, together with non-negativity. (2) is Theorem 4.6. (3) is Theorem 4.6(1) with $C=G$ and identity readouts. $\square$

So the redundancy between two fields is controlled entirely by the size of their shared Galois quotient.

---

## 6. The $S_3$ pairs in full

Write $T_i\in\{111,3,12\}$ for the splitting type, i.e. the cycle type of the Frobenius in $S_3$, and $\chi$ for the sign. On $S_3\times_{C_2}S_3$ the fibre $\chi=+1$ is $A_3\times A_3$ (9 elements) and the fibre $\chi=-1$ is $\{\text{transpositions}\}^2$ (9 elements).

**Theorem 6.1 (Joint Chebotarev table).** On $S_3\times_{C_2}S_3$, a group of order $18$:

| | $T_2=111$ | $T_2=3$ | $T_2=12$ |
|---|---|---|---|
| $T_1=111$ | 1 | 2 | 0 |
| $T_1=3$ | 2 | 4 | 0 |
| $T_1=12$ | 0 | 0 | 9 |

All four cells mixing $12$ with $111$ or $3$ vanish. Moreover:

1. $I(T_1;T_2)=1$ bit exactly. This follows from Corollary 4.7 and does not require enumeration. Equivalently, $H(T_1)=1.4591$, $H(T_1,T_2)=1.9183$ and $H(T_1\mid T_2)=0.4591$.
2. The types agree on $14$ of the $18$ elements, so the agreement probability is $7/9$ and the off-diagonal mass is $4/18=2/9$.
3. On the fibre $\chi=-1$ the agreement is $9/9$. On the fibre $\chi=+1$ it is $5/9=(1/3)^2+(2/3)^2$, exactly the rate for independent readouts.
4. On each fibre, $I(T_1;T_2\mid\text{fibre})=0$.

*Proof.* The table is obtained by counting. On $A_3\times A_3$ the counts are $1\cdot1$, $1\cdot2$, $2\cdot1$, $2\cdot2$, and on the odd fibre they are $3\cdot3$. Item (4) is Proposition 4.2. $\square$

**Proposition 6.2 (Comparison rungs).** On $S_3\times S_3$ (coprime), $I(T_1;T_2)=0$ and agreement is $14/36=7/18$, exactly half the partial-overlap value. On the diagonal (same field), $I(T_1;T_2)=H(T)=\tfrac23+\tfrac12\log_23$ and agreement is $6/6$.

**Theorem 6.3 (Insight L11: sign is blind, type discriminates).** Consider the residue-visible sign readouts $\chi(g)$ and $\chi(h)$. These are what a Legendre symbol $\left(\frac dp\right)$ computes. Their mutual information is exactly $1$ bit on the partial-overlap space $S_3\times_{C_2}S_3$ and *also* exactly $1$ bit on the same-field diagonal. On the other hand:

- type agreement is $14/18$ versus $6/6$;
- full-type mutual information is $1$ versus $H(T)=\tfrac23+\tfrac12\log_23>1$.

*Proof.* On the fibre product the sign readouts satisfy Corollary 4.7. On the diagonal they are equal, so $I=H(\chi)=1$. The remaining items are Theorem 6.1 and Proposition 6.2. $\square$

*Consequence.* Mutual-information signatures computed from residue-visible data cannot distinguish a partial-overlap pair from a same-field pair. The discriminators are type agreement and off-diagonal mass.

**Remark 6.4 (On the decomposition "$1.5-0.5$").** Writing the redundancy as $H(\cdot)-H(\cdot\mid\cdot)=1.5-0.5$ is correct for the cyclic quartic pair of §7. For $S_3$ the correct decomposition is $H(T)-H(T_1\mid T_2)=1.4591-0.4591$. The value $1$ is the same in both cases, but the summands depend on the readout.

---

## 7. A second family: cyclic quartic fields

**Definition 7.1.** Let $C_4=\mathbb{Z}/4$, $C_2=\mathbb{Z}/2$, and let $r:C_4\to C_2$ be reduction mod 2 (restriction to the quadratic subfield). The residue degree of an unramified prime in a cyclic quartic field is the order of its Frobenius: $\deg(0)=1$, $\deg(2)=2$, $\deg(\pm1)=4$.

**Theorem 7.2.** On $C_4\times_{C_2}C_4$ (order $8$), the residue degree determines the quadratic character (the character is nontrivial exactly when the degree is $4$), and

$$H(\deg_1)=\tfrac32,\qquad H(\deg_1\mid\deg_2)=\tfrac12,\qquad I(\deg_1;\deg_2)=1.$$

*Proof.* $I=1$ is Corollary 4.7. The distribution of $\deg_1$ is $(1/4,1/4,1/2)$, which has entropy $3/2$. $\square$

So the Partial-Overlap Law is not a peculiarity of $S_3$: two cyclic quartic fields sharing their quadratic subfield are also exactly one bit redundant.

---

## 8. Three dials over one subfield

**Definition 8.1.** For surjections $\chi_1:G\to C$, $\chi_2:H\to C$ and $\chi_3:K\to C$, let

$$G\times_C H\times_C K=\{(g,h,k):\chi_1(g)=\chi_2(h)=\chi_3(k)\},$$

which has order $|G||H||K|/|C|^2$.

**Theorem 8.2.** Let readouts $T_1,T_2,T_3$ each determine the character. On the triple fibre product:

1. every pairwise mutual information equals $\log|C|$;
2. $I(T_1;(T_2,T_3))=\log|C|$: once the first dial is matched against the third, the second adds nothing;
3. the total correlation is exactly two units,
$$H(T_1)+H(T_2)+H(T_3)-H(T_1,T_2,T_3)=2\log|C|;$$
4. the co-information is exactly one unit,
$$I(T_1;T_2)+I(T_1;T_3)-I(T_1;(T_2,T_3))=+\log|C|,$$
which is pure redundancy and no synergy.

*Proof.* Each fibre of $\kappa=\chi_1(g)$ is a triple product of coset sets, so any two readouts built from disjoint coordinates are fibrewise independent. Every readout above, including the pair $(T_2,T_3)$, determines $\kappa$. Theorem 3.3 gives (1) and (2), and the uniformity of $\kappa$ gives the value $\log|C|$. For (3), write the total correlation as $I(T_1;(T_2,T_3))+I(T_2;T_3)$. Item (4) is arithmetic. $\square$

For three $S_3$ cubics with a common quadratic resolvent (group of order $54$), the total correlation is $2$ bits and the co-information is $+1$ bit.

---

## 9. Algorithms and experiments

### 9.1 Computing Frobenius types

For a monic cubic $f$ and a prime $p\nmid\mathrm{disc}(f)$, the number of roots in $\mathbb{F}_p$ is $\deg\gcd(x^p-x,f)$ over $\mathbb{F}_p$. Compute $x^p\bmod (f,p)$ by repeated squaring, using $O(\log p)$ multiplications of polynomials of degree at most 2. A Euclidean gcd then finishes the computation. The splitting type is $111$, $12$ or $3$ according as the gcd has degree $3$, $1$ or $0$. All primes below $X$ can be processed in $O(\pi(X)\log X)$ field operations.

### 9.2 Exact entropies on fibre products

Enumerate $G\times_C H$ as the pairs with equal character. Tabulate joint counts of $(T_1,T_2)$ and compute $H(T_1)+H(T_2)-H(T_1,T_2)$. The cost is $O(|G||H|/|C|)$ after $O(|G|+|H|)$ preprocessing. Doing this for $S_n\times_{C_2}S_m$ with $2\le n\le m\le5$ returns exactly $1$ bit in all ten cases, the largest group having order $7200$.

### 9.3 Results on real primes

We used all primes $7<p<60000$ that are unramified in both cubics. The splitting type was read from the number of roots mod $p$, and mutual information was estimated by plug-in.

| Pair | $n$ | plug-in $I$ | law | agreement | law |
|---|---|---|---|---|---|
| $x^3-5x-5$ & $x^3-3x-5$ ($d=-7$) | 6053 | 1.0000 | 1 | 0.7816 | 0.7778 |
| $x^3-6x-6$ & $x^3-3$ ($d=-3$) | 6053 | 1.0000 | 1 | 0.7785 | 0.7778 |
| $x^3+x+1$ & $x^3-x-1$ (coprime) | 6051 | 0.0001 | 0 | 0.3889 | 0.3889 |
| $x^3-5x-5$ twice (same field) | 6053 | 1.4559 | 1.4591 | 1 | 1 |

For the $d=-7$ pair the joint table was $111/111:329$, $111/3:664$, $3/111:658$, $3/3:1369$, $12/12:3033$, with all four structurally-zero cells empty. The $1:2:2:4:9$ law predicts $336, 673, 673, 1345, 3027$. For $d=-3$ the off-diagonal count was $1341$ against a predicted $\tfrac29\cdot6053\approx1345$. In the original larger simulation the off-diagonal mass was $34{,}375$ against $34{,}307$ predicted. The joint class proportions matched the order-18 group, a coprime control reproduced the coprime-synergy statistic reported in earlier work ($0.1300$ versus the previously reported $0.1290$), and a conjugate pair showed full redundancy.

### 9.4 Plug-in bias

The plug-in estimator of mutual information is biased upward by roughly $(|B_1|-1)(|B_2|-1)/(2n\ln 2)$ bits. For sparse joint tables, at about $2$ samples per cell, this reaches about half a bit even for independent readouts. The shared-subfield $S_3$ table has only five structurally non-zero cells, which is why the estimates above are accurate to $10^{-4}$. Joint readouts over large moduli need on the order of $100$ samples per cell, or an explicit bias model.

---

## 10. Discussion

**What the law says.** The redundancy between two number fields, measured through Frobenius readouts, is the entropy of their shared Galois quotient. It is attained exactly by readouts that see that quotient and is never exceeded by any readouts. The proof has two steps. First, the fibre product becomes a direct product once the shared character is fixed. Second, the chain rule turns this structural fact into an entropy identity. The "correlation confined to the residue-invisible fibre" seen in the data is a statement of *zero* correlation: on the $\chi=+1$ fibre the types agree at exactly the independent rate $5/9$.

**Scope and assumptions.** The arithmetic content enters only through the choice of sample space. That choice rests on two facts: the identification $\mathrm{Gal}(L_1L_2/\mathbb{Q})\cong G\times_C H$ when $L_1\cap L_2$ is Galois with group $C$, and Chebotarev equidistribution. The finite-sample statistics are not part of the theorems. They agree with the theorems to within the expected scatter.

**Information is not identity.** Theorem 6.3 is a warning that applies well beyond this setting. Equal mutual information does not imply equal structure. Two pairs of sources can share exactly the same number of bits while having very different joint tables.

**Beyond arithmetic.** Theorems 3.3 and 3.4 apply to any pair of systems coupled through a common label and otherwise independent. Examples include two sensors that read a shared hidden state, two channels that share a parity bit, and two cascades driven by a common factor. In each case the shared information is exactly the label entropy when the readouts reveal the label, and at most that otherwise.

## 11. Future work

1. **Non-abelian shared quotients.** When the shared quotient $Q$ is non-abelian, conjugacy-class readouts see only the class of the image in $Q$. We conjecture that they share exactly $H(\text{class in }Q)$ rather than $\log|Q|$.
2. **$n$ dials.** For $n$ fields over one shared subfield, we conjecture total correlation $(n-1)\log|C|$ and $n$-way co-information $+\log|C|$. The case $n=3$ is Theorem 8.2.
3. **Subfield lattices.** For families whose pairwise intersections are distinct Galois subfields, such as $\mathbb{Q}(\sqrt{-3})$ for one pair and $\mathbb{Q}(\sqrt{-7})$ for another, the joint entropy should obey inclusion–exclusion over the lattice of shared subfields.
4. **Bias laws for structurally sparse joints.** Quantify plug-in bias in terms of the number of *structurally non-zero* cells of the fibre-product table rather than the nominal table size.

## Acknowledgement of conventions

Entropy is in bits. "Readout" means any function of the Frobenius element, and in practice a class function such as the splitting type. The experiments use seed $20260821$ wherever randomness enters.
