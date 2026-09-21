# Splitting Labels Are Not Residue Filters: Non-Abelianness as an Obstruction to Candidate Narrowing

**Author:** Aristotle
**Date:** 2026-09-21

---

## Abstract

A *splitting-label battery* attached to a semiprime $N = pq$ measures, for a family of small auxiliary polynomials $f_i$, the decomposition type of the hidden prime factors — concretely, the number of roots of $f_i$ modulo $p$. Such batteries have substantial measured information content about the pair $(p,q)$; the configuration motivating this work reports a joint capacity of $12.7$ bits. We settle the *utility* question for such batteries: whether that information can be converted into **candidate-set narrowing**, i.e. into a sound rule that, on reading the labels, excludes residue classes of $p$ modulo some $m$.

The answer is negative, and the obstruction is structural rather than quantitative. We work with the smallest non-abelian probe, $f(X) = X^3 - 2$, whose splitting field $\mathbb{Q}(\sqrt[3]{2},\omega)$ has Galois group $S_3$, and prove: (i) an exact anatomy of the label $T(p) = \#\{x \in \mathbb{Z}/p : x^3 \equiv 2\}$, namely $T(p) = 1 \iff p \equiv 2 \pmod 3$ and $T(p) \in \{0,3\}$ otherwise; (ii) that for every modulus $2 \le m \le 24$ there is **no** function $g:\mathbb{Z}/m \to \mathbb{N}$ with $g(p \bmod m) = T(p)$ on the primes $p \equiv 1 \pmod 3$, each case refuted by an explicit pair of primes in one class carrying the labels $0$ and $3$, with refutations propagating to all divisors; (iii) a **no-pinning theorem**: every *sound* label filter (one that never excludes the true prime) must assign identical residue support to the labels $0$ and $3$ — at modulus $9$ all of $\{1,4,7\}$ is accepted by both, so the narrowing factor is exactly $1$, and at every modulus $2 \le m \le 24$ some class is accepted by both labels.

We then give the matching information-theoretic layer for a finite (residue, label) channel: the chain rule $H(R,T) = H(R) + H(T\mid R)$; the **capacity law** $I(R;T) \le H(T)$; **saturation**, $I(R;T) = H(T)$ whenever the label is a function of the residue; and the **gap theorem**, $I(R;T) < H(T)$ strictly whenever one residue class carries two labels of positive mass. Consequently a measured deficit $I < H(T)$ — such as the reported $I = 1.0012$ against $H(T) = 2.2982$ — is a *certificate* that no residue-to-label table exists, never a measurement defect. Under equidistribution the deficit is total: the cubic channel modelled with uniform residues on $\{1,4,7\} \bmod 9$ and residue-independent label densities $(2/3, 1/3)$ has $I(R;T) = 0$ while $H(T) = \log 3 - \tfrac23 \log 2 > 0$, and the posterior mass of any single joint residue class remains at its prior value.

An adversarial control anchors the interpretation: for the *abelian* probe $X^2 - 2$ the table does exist, at modulus $8$, by the second supplement to quadratic reciprocity. Filterability is therefore a statement about abelianness of the splitting field, not about the number of bits available. We also record the $21$-prime census ($p < 200$, $p \equiv 1 \bmod 3$) with verified cell counts $(6,2 \mid 5,2 \mid 5,1)$: every residue row is mixed.

**Keywords:** splitting label, cubic residue, non-abelian extension, residue filter, mutual information, capacity law, candidate narrowing, Kronecker–Weber.

---

## 1. Introduction

### 1.1 The setting

Let $N = pq$ be a semiprime with unknown prime factors. A *dial* is an arithmetic measurement that returns a small invariant of the factors. The prototypical dial is built from a monic integer polynomial $f$: its label at a prime $p$ is the count
$$T_f(p) \;=\; \#\{\, x \in \mathbb{Z}/p \;:\; f(x) \equiv 0 \pmod p \,\},$$
which records the splitting type of $p$ in the number field defined by $f$. A *battery* is a finite family of dials; its readings form a label vector. The battery that motivates this paper has six dials and a measured joint capacity of $12.7$ bits with respect to the pair $(p \bmod m^*, q \bmod m^*)$ for a fixed auxiliary modulus $m^*$, against a joint residue-vector entropy of roughly $20$ bits.

### 1.2 The utility question

Twelve and a half bits is a large amount of information in absolute terms. The natural next step — the *utility* step — is to convert it into search. Searches over prime candidates are organized by residue classes: knowing $p \bmod m$ to lie in a set $S \subseteq \mathbb{Z}/m$ prunes the candidate pool by the factor $|S| / \varphi(m)$ (among classes coprime to $m$). So one asks for a lookup table:

> Read the label vector; consult a table indexed by labels; discard the residue classes the table forbids.

Such a table is a **filter**. The demand it places on arithmetic is severe and completely explicit: the label must be a *function of the residue*,
$$\exists\, g : \mathbb{Z}/m \to \mathbb{N} \quad \text{with} \quad g(p \bmod m) = T_f(p) \ \text{ for all primes } p .$$
Nothing weaker suffices for a table lookup, and — as we show in §4 — nothing weaker even in the approximate, one-sided sense suffices for *narrowing*.

### 1.3 The design flaw, and its promotion to a theorem

The experiment that prompted this analysis built its utility tables by *polynomial evaluation at the residue*: it asked "is $f(r) \equiv 0 \pmod{m^*}$?" and used the answer as a proxy for the label of a prime in the class $r$. This conflates two different objects. The first is a property of the integer $r$; the second is a property of the primes lying in the class $r$. A built-in consistency assertion — verifying that the constructed filter never excludes the *true* $p$ — caught the discrepancy: $6$ exclusions of the true prime in $150$ trials for one family of tables (the failure was localized to an enumeration-precedence error in a quartic probe), while a cubic family passed $0/150$ only because its accepted sets covered nearly all residues, i.e. only by not filtering at all.

The diagnosis is the finding. The conversion requires a map
$$r \bmod m^* \;\longmapsto\; \text{splitting type of a prime } \equiv r \pmod{m^*},$$
and **that map does not exist** for a non-abelian probe. Primes in the same residue class carry different splitting types. This is also, exactly, why every measured channel sits strictly below its label-entropy ceiling: the gap *is* the within-class variation.

### 1.4 Contributions

1. **Exact anatomy of the cubic label** (§3): a clean split into a *free abelian bit* (determined by $p \bmod 3$) and a *hard bit* ($0$ versus $3$).
2. **Non-existence of the residue-to-type map** (§4.1) for every modulus $2 \le m \le 24$, by explicit witness pairs, with divisor propagation.
3. **No-pinning** (§4.2): a sound filter's accepted sets for labels $0$ and $3$ intersect in at least three residues mod $9$ and are in fact identical there; at every modulus $\le 24$ some class survives both labels. The narrowing factor is $1$.
4. **The information layer** (§5): chain rule, capacity law, saturation for functional labels, the strict gap theorem, and vanishing mutual information under independence — with the reading that a measured gap is a certificate of non-filterability.
5. **The abelian control** (§6): $X^2 - 2$ *does* admit a residue table at modulus $8$; the verdict is about non-abelianness, not about bit count.
6. **Census** (§7): a verified enumeration of the measured window.

---

## 2. Definitions

Throughout, $p$ denotes a prime and $\mathbb{Z}/p$ the field with $p$ elements.

**Definition 2.1 (cube-root count).** For integers $c \ge 0$ and $p \ge 1$ set
$$C(c,p) \;=\; \#\{\, x \in \{0,1,\dots,p-1\} \;:\; x^3 \equiv c \pmod p \,\}.$$
Equivalently, when $p$ is prime, $C(c,p) = \#\{x \in \mathbb{Z}/p : x^3 = \bar c\}$.

**Definition 2.2 (the cubic label).** The *cubic label* of $p$ is $T(p) = C(2,p)$, the number of cube roots of $2$ modulo $p$. This is the label of the battery's cubic channel, i.e. the probe $f(X) = X^3 - 2$.

**Definition 2.3 (square-root count and quadratic label).** Analogously $S(c,p) = \#\{x \in \mathbb{Z}/p : x^2 = \bar c\}$, and the *quadratic label* of $p$ is $S(2,p)$, the probe $f(X) = X^2 - 2$.

**Definition 2.4 (residue-to-type map).** For a modulus $m \ge 1$, say that $m$ *admits a residue-to-type map* if there exists $g : \mathbb{Z}/m \to \mathbb{N}$ such that
$$g\!\left(p \bmod m\right) \;=\; T(p) \qquad \text{for every prime } p \ge 5 \text{ with } p \equiv 1 \!\!\pmod 3 .$$
The restriction to $p \equiv 1 \pmod 3$ is deliberate: by Theorem 3.4 the label on the complementary classes is already a function of $p \bmod 3$, so including those classes would only make the hypothesis easier to refute. We refute the *strongest* form.

**Definition 2.5 (sound label filter).** A *label filter* modulo $m$ is a map $F : \mathbb{N} \to \mathcal{P}(\mathbb{Z}/m)$ assigning to each observable label $t$ the set $F(t)$ of residues it permits. It is **sound** if it never excludes a true prime:
$$\forall \text{ primes } p \ge 5: \quad (p \bmod m) \in F\big(T(p)\big).$$
Soundness is the minimal correctness requirement on a search-pruning rule: an unsound filter can delete the answer.

**Definition 2.6 (finite residue–label channel).** Let $R$ and $T$ be finite sets. A *channel* is a function $P : R \times T \to \mathbb{R}_{\ge 0}$ with $\sum_{r}\sum_{t} P(r,t) = 1$. Its marginals are $P_R(r) = \sum_t P(r,t)$ and $P_T(t) = \sum_r P(r,t)$. Writing $\eta(x) = -x\log x$ (with $\eta(0)=0$), the entropies are
$$H(R) = \sum_r \eta(P_R(r)), \qquad H(T) = \sum_t \eta(P_T(t)), \qquad H(R,T) = \sum_{r,t} \eta(P(r,t)),$$
and the **conditional entropy** is assembled from pointwise terms:
$$\kappa(a,s) \;=\; -a\log a + a \log s, \qquad H(T \mid R) \;=\; \sum_{r}\sum_{t} \kappa\big(P(r,t),\, P_R(r)\big).$$
The **mutual information** is $I(R;T) = H(T) - H(T\mid R)$.

*(Remark. Entropies here are in nats; conversion to bits is division by $\log 2$ and changes nothing.)*

---

## 3. The anatomy of the cubic label

### 3.1 The abelian half

**Lemma 3.1 (inverting the cube map).** *Let $p$ be prime and suppose $3k = 2(p-1) + 1$ for some integer $k \ge 0$. Then $(x^3)^k = x$ for every $x \in \mathbb{Z}/p$.*

*Proof sketch.* $(x^3)^k = x^{3k} = x^{2(p-1)+1}$. For $x = 0$ both sides vanish (note $3k \ge 1$). For $x \ne 0$, Fermat's little theorem gives $x^{p-1} = 1$, so $x^{2(p-1)+1} = (x^{p-1})^2 \cdot x = x$. $\square$

**Theorem 3.2 (cubing is bijective when $p \equiv 2 \bmod 3$).** *If $p$ is prime with $p \equiv 2 \pmod 3$, the map $x \mapsto x^3$ is a bijection of $\mathbb{Z}/p$.*

*Proof sketch.* Since $p \equiv 2 \pmod 3$ we have $2(p-1)+1 = 2p - 1 \equiv 0 \pmod 3$, so $k = (2p-1)/3$ is an integer and Lemma 3.1 applies. Injectivity: if $x^3 = y^3$ then $x = (x^3)^k = (y^3)^k = y$. Surjectivity: given $y$, the element $y^k$ satisfies $(y^k)^3 = (y^3)^k = y$. $\square$

**Corollary 3.3 (the abelian half is a filter).** *For every prime $p \equiv 2 \pmod 3$ and every $c$, $C(c,p) = 1$. In particular $T(p) = 1$.*

Thus on half the primes the label is constant, and that constancy is itself a residue condition. This part of the label is a perfectly valid filter — and a perfectly useless one, since it reports $p \bmod 3$, which any residue-indexed search already knows.

### 3.2 The non-abelian half

**Lemma 3.4 (the group of cube roots of unity).** *If $p \equiv 1 \pmod 3$ then $\mu_3 = \{x \in \mathbb{Z}/p : x^3 = 1\}$ has exactly $3$ elements.*

*Proof sketch.* Upper bound: $\mu_3$ is contained in the root set of $X^3 - 1$ over a field, which has at most $3$ elements. Lower bound: the unit group $(\mathbb{Z}/p)^\times$ has order $p - 1$, and $p \equiv 1 \pmod 3$ gives $3 \mid p-1$; Cauchy's theorem supplies a unit $u$ of order exactly $3$. Then $1, u, u^2$ are three distinct elements of $\mu_3$ (distinct because $u$ has order $3$). $\square$

**Lemma 3.5 (fibres are cosets).** *Let $p$ be prime, $c \ne 0$ in $\mathbb{Z}/p$, and suppose $a^3 = c$ for some $a$. Then $\{x : x^3 = c\} = a\,\mu_3$, and in particular $\#\{x : x^3 = c\} = |\mu_3|$.*

*Proof sketch.* Necessarily $a \ne 0$. The map $\zeta \mapsto a\zeta$ is a bijection from $\mu_3$ onto the fibre: if $\zeta^3 = 1$ then $(a\zeta)^3 = c$; conversely if $x^3 = c$ then $(x/a)^3 = 1$. $\square$

**Theorem 3.6 (dichotomy).** *If $p$ is prime with $p \equiv 1 \pmod 3$ and $p \nmid c$, then $C(c,p) \in \{0, 3\}$.*

*Proof sketch.* If the fibre is empty the count is $0$; otherwise Lemma 3.5 and Lemma 3.4 give $3$. $\square$

### 3.3 The exact information content

**Theorem 3.7 (label anatomy).** *For every prime $p \ge 5$,*
$$T(p) = 1 \iff p \equiv 2 \pmod 3, \qquad\text{and}\qquad p \equiv 1 \!\!\pmod 3 \implies T(p) \in \{0,3\}.$$

*Proof sketch.* ($\Leftarrow$) is Corollary 3.3. ($\Rightarrow$): a prime $p \ge 5$ satisfies $p \equiv 1$ or $2 \pmod 3$; in the first case Theorem 3.6 with $c = 2$ (and $p \nmid 2$, since $p \ge 5$) gives $T(p) \in \{0,3\}$, excluding $T(p) = 1$. $\square$

So the cubic label decomposes into:

- a **free bit** — the value of $p \bmod 3$, recoverable from the label and already available to a residue search; and
- a **hard bit** — on the classes $p \equiv 1 \pmod 3$, whether $2$ is a cube modulo $p$.

The rest of the paper is about the hard bit. Note the Galois-theoretic reading: the free bit is the image of the Frobenius conjugacy class in the abelianization $S_3 \to S_3^{\mathrm{ab}} \cong \mathbb{Z}/2$, which corresponds to the cyclotomic subfield $\mathbb{Q}(\omega) \subseteq \mathbb{Q}(\sqrt[3]2, \omega)$. The hard bit lives past the abelianization.

---

## 4. The refutation

### 4.1 No residue-to-type map

**Lemma 4.1 (divisor propagation).** *If $d \mid m$ and $d$ admits a residue-to-type map, so does $m$.*

*Proof sketch.* Compose the map for $d$ with the canonical projection $\mathbb{Z}/m \to \mathbb{Z}/d$; since $p \bmod m$ projects to $p \bmod d$, the composite computes $T(p)$. $\square$

Contrapositively, a refutation at $m$ refutes every divisor of $m$. Thus the finite check below in fact rules out a much larger family of moduli than its literal range.

**Lemma 4.2 (witness refutation).** *Suppose $a, b \ge 5$ are primes with $a \equiv b \equiv 1 \pmod 3$, $a \equiv b \pmod m$, and $T(a) \ne T(b)$. Then $m$ admits no residue-to-type map.*

*Proof sketch.* A map $g$ would give $T(a) = g(a \bmod m) = g(b \bmod m) = T(b)$. $\square$

**Theorem 4.3 (the labels are not filters).** *For every modulus $m$ with $2 \le m \le 24$, there is no function $g : \mathbb{Z}/m \to \mathbb{N}$ satisfying $g(p \bmod m) = T(p)$ for all primes $p \ge 5$ with $p \equiv 1 \pmod 3$.*

*Proof sketch.* One witness pair per modulus, each verified by direct computation of the two labels and of the shared residue. A complete list of smallest witnesses (here $a$ carries the label $0$ and $b$ the label $3$, and $a \equiv b \equiv r \pmod m$):

| $m$ | $r$ | $a$ ($T=0$) | $b$ ($T=3$) | | $m$ | $r$ | $a$ ($T=0$) | $b$ ($T=3$) |
|---|---|---|---|---|---|---|---|---|
| $2$ | $1$ | $7$ | $31$ | | $14$ | $3$ | $73$ | $31$ |
| $3$ | $1$ | $7$ | $31$ | | $15$ | $13$ | $13$ | $43$ |
| $4$ | $3$ | $7$ | $31$ | | $16$ | $15$ | $79$ | $31$ |
| $5$ | $3$ | $13$ | $43$ | | $17$ | $7$ | $7$ | $109$ |
| $6$ | $1$ | $7$ | $31$ | | $18$ | $13$ | $13$ | $31$ |
| $7$ | $3$ | $73$ | $31$ | | $19$ | $13$ | $13$ | $127$ |
| $8$ | $7$ | $7$ | $31$ | | $20$ | $3$ | $103$ | $43$ |
| $9$ | $4$ | $13$ | $31$ | | $21$ | $10$ | $73$ | $31$ |
| $10$ | $3$ | $13$ | $43$ | | $22$ | $9$ | $97$ | $31$ |
| $11$ | $9$ | $97$ | $31$ | | $23$ | $19$ | $19$ | $157$ |
| $12$ | $7$ | $7$ | $31$ | | $24$ | $7$ | $7$ | $31$ |
| $13$ | $1$ | $79$ | $157$ | | | | | |

The cleanest single example is the pair $(7, 31)$: their difference is $24$, so they collide modulo every divisor of $24$, and $T(7) = 0$ while $T(31) = 3$ because $4^3 = 64 \equiv 2 \pmod{31}$. $\square$

The refutation is *robust in a strong sense*: it does not merely say that no exact table exists; because the two witnesses lie in a common class, **no** assignment of a single label to that class is correct for all primes in it.

### 4.2 No pinning: sound filters do not narrow

Theorem 4.3 forbids exact tables. One might hope for an approximate rule: on reading a label, forbid *some* residues. Soundness (Definition 2.5) is the only constraint such a rule must satisfy — and it is fatal.

**Lemma 4.4 (shared classes are shared by both labels).** *Let $F$ be a sound filter mod $m$, and let $a, b \ge 5$ be primes with $a \equiv b \pmod m$, $T(a) = 0$ and $T(b) = 3$. Then $(a \bmod m) \in F(0) \cap F(3)$.*

*Proof sketch.* Soundness at $a$ gives $(a \bmod m) \in F(0)$; soundness at $b$ gives $(b \bmod m) \in F(3)$; and $a \equiv b \pmod m$ identifies the two residues. $\square$

**Theorem 4.5 (no pinning at modulus 9).** *Every sound filter $F$ mod $9$ satisfies*
$$\{1,4,7\} \subseteq F(0) \qquad\text{and}\qquad \{1,4,7\} \subseteq F(3).$$

*Proof sketch.* Apply Lemma 4.4 three times, once per class of $\mathbb{Z}/9$ congruent to $1$ mod $3$:

| class mod $9$ | prime with label $0$ | prime with label $3$ |
|---|---|---|
| $1$ | $19$ | $127$ |
| $4$ | $13$ | $31$ |
| $7$ | $7$ | $43$ |

Each row forces its class into both $F(0)$ and $F(3)$. $\square$

**Corollary 4.6 (narrowing factor exactly one).** *For any sound filter $F$ mod $9$, $|F(0) \cap F(3)| \ge 3$; that is, at least three residues survive both possible readings of the hard bit. Since only three classes mod $9$ are congruent to $1$ mod $3$, the hard bit removes nothing at all.*

**Theorem 4.7 (the free bit, and only the free bit).** *Every sound filter $F$ mod $9$ satisfies $\{2,5,8\} \subseteq F(1)$, and by Theorem 3.7 the label $1$ occurs only at primes $\equiv 2 \bmod 3$. Hence the only separation a sound filter can effect is $\{2,5,8\}$ versus $\{1,4,7\}$ — the value of $p \bmod 3$.*

*Proof sketch.* The primes $11, 5, 17$ have labels $1$ and reduce to $2, 5, 8$ mod $9$ respectively; soundness puts each into $F(1)$. The converse direction is Theorem 3.7. $\square$

**Theorem 4.8 (no pinning at every modulus $\le 24$).** *For every $m$ with $2 \le m \le 24$ and every sound filter $F$ mod $m$, there exists a residue class $r \in \mathbb{Z}/m$ with $r \in F(0) \cap F(3)$.*

*Proof sketch.* Take the witness pair supplied for $m$ in Theorem 4.3, arranged so that one member has label $0$ and the other label $3$, and apply Lemma 4.4. $\square$

**Remark 4.9 (the empirical picture is even flatter).** Theorem 4.8 guarantees *one* shared class per modulus. Direct enumeration of the primes below $5000$ shows far more: for every $m$ with $2 \le m \le 24$, the minimal sound accept-sets satisfy $F_{\min}(0) = F_{\min}(3)$ on the classes coprime to $m$, so the ratio $|F_{\min}(0) \cap F_{\min}(3)| / |F_{\min}(0) \cup F_{\min}(3)|$ equals $1$ at every modulus. (The class $0 \bmod m$ is excluded as degenerate: it contains the single prime $p = m$.) Not one class is separated anywhere in the checked range.

The interpretive content: **whatever the dial reads, that class survives.** A narrowing rule would have to be able, at least sometimes, to say "not this class" — and it never can. Producing the narrowing would require deciding the splitting type of the individual candidate prime, which is precisely the per-prime determination that the factoring problem itself withholds. The argument closes in a circle; that circle is the theorem.

---

## 5. The information layer: capacity, saturation, and the gap

We now explain why the shortfall observed in every measured channel is not an artifact. Fix a channel $P$ on $R \times T$ as in Definition 2.6.

**Lemma 5.1 (pointwise nonnegativity and strict positivity).** *For $0 \le a \le s$ we have $\kappa(a,s) = -a\log a + a \log s \ge 0$, with $\kappa(a,a) = 0$ and $\kappa(0,s) = 0$; and if $0 < a < s$ then $\kappa(a,s) > 0$.*

*Proof sketch.* For $a = 0$ both terms vanish. For $a > 0$, $\kappa(a,s) = a(\log s - \log a)$, and $\log$ is increasing, strictly so on positives: $a \le s$ gives $\ge 0$, $a < s$ gives $> 0$. $\square$

**Lemma 5.2 (marginal dominance).** $P(r,t) \le P_R(r)$ for all $r,t$, since the marginal is a sum of nonnegative terms including $P(r,t)$.

**Theorem 5.3 (chain rule).** $H(R,T) = H(R) + H(T \mid R)$.

*Proof sketch.* Expand $H(T\mid R) = \sum_{r,t}\big(\eta(P(r,t)) + P(r,t)\log P_R(r)\big)$. The first block is $H(R,T)$. For the second, fix $r$ and sum over $t$: $\big(\sum_t P(r,t)\big)\log P_R(r) = P_R(r)\log P_R(r) = -\eta(P_R(r))$. Summing over $r$ gives $-H(R)$. Rearranging yields the claim. $\square$

**Corollary 5.4.** $I(R;T) = H(R) + H(T) - H(R,T)$, the symmetric form.

**Theorem 5.5 (capacity law).** $H(T\mid R) \ge 0$, hence
$$I(R;T) \;\le\; H(T).$$

*Proof sketch.* Immediate from Lemmas 5.1 and 5.2 applied termwise, then from the definition $I = H(T) - H(T\mid R)$. $\square$

**Theorem 5.6 (filters saturate the ceiling).** *Suppose the label is a function of the residue: there is $g : R \to T$ such that $P(r,t) \ne 0 \implies t = g(r)$. Then $H(T\mid R) = 0$ and*
$$I(R;T) = H(T).$$

*Proof sketch.* Fix $r,t$. If $P(r,t) = 0$ the term vanishes. Otherwise $t = g(r)$, and every $t' \ne t$ has $P(r,t') = 0$ (else $t' = g(r) = t$); hence $P_R(r) = P(r,t)$ and $\kappa(P(r,t), P_R(r)) = \kappa(a,a) = 0$. $\square$

This is the precise sense in which the utility programme's hypothesis is an *information-theoretic* hypothesis: a residue-to-type table exists if and only if the channel attains its ceiling.

**Theorem 5.7 (the gap theorem).** *If there are $r \in R$ and $t_1 \ne t_2$ in $T$ with $P(r,t_1) > 0$ and $P(r,t_2) > 0$, then $H(T\mid R) > 0$, hence*
$$I(R;T) \;<\; H(T).$$

*Proof sketch.* From $P(r,t_1) + P(r,t_2) \le P_R(r)$ and $P(r,t_2) > 0$ we get $0 < P(r,t_1) < P_R(r)$; Lemma 5.1 makes the corresponding term strictly positive, and all other terms are nonnegative. $\square$

**Corollary 5.8 (measured gaps are certificates).** *A measured strict inequality $I(R;T) < H(T)$ is equivalent (given the contrapositive of Theorem 5.6) to the existence of a residue class carrying two labels. The deficit $H(T) - I(R;T) = H(T\mid R)$ **is** the within-class variation; it is never attributable to measurement error.*

Applied to the reported reading $I = 1.0012$ against $H(T) = 2.2982$: the deficit of $1.297$ bits is exactly the amount of label entropy that lives *inside* residue classes and is therefore unavailable to any residue-indexed filter.

**Theorem 5.9 (independence: zero utility at positive entropy).** *If $P(r,t) = a(r)\,b(t)$ for probability vectors $a, b$, then $I(R;T) = 0$.*

*Proof sketch.* The marginals are $P_R = a$, $P_T = b$. Using $\eta(xy) = y\,\eta(x) + x\,\eta(y)$,
$$H(R,T) = \sum_{r,t}\big(b(t)\eta(a(r)) + a(r)\eta(b(t))\big) = H(R) + H(T),$$
so $I = H(R) + H(T) - H(R,T) = 0$ by Corollary 5.4. $\square$

### 5.1 The equidistribution model of the cubic channel

Chebotarev-type equidistribution predicts that among primes in a fixed class mod $9$ congruent to $1$ mod $3$, the cubic label takes the value $0$ with density $2/3$ and the value $3$ with density $1/3$ — *independently of which of the three classes* $1, 4, 7$ one chose. Encode this as the channel on $R = \{1,4,7\}$, $T = \{0,3\}$ with
$$P(r,t) = \tfrac13 \cdot \begin{cases} 2/3, & t = 0,\\ 1/3, & t = 3.\end{cases}$$

**Theorem 5.10 (total gap in the equidistribution model).**
$$I(R;T) = 0, \qquad H(T) = \log 3 - \tfrac23\log 2 > 0, \qquad\text{hence}\qquad I(R;T) < H(T).$$

*Proof sketch.* The law is a product, so $I = 0$ by Theorem 5.9. The label marginal is $(2/3, 1/3)$, giving
$$H(T) = -\tfrac23\log\tfrac23 - \tfrac13\log\tfrac13 = \log 3 - \tfrac23 \log 2 .$$
Positivity: $\log 3 - \tfrac23\log 2 > 0 \iff 3\log 3 > 2 \log 2 \iff \log 27 > \log 4$, true since $27 > 4$. $\square$

So in the idealized model the *entire* label entropy is within-class variation, and the channel's utility for residue narrowing is exactly zero. This is the Bayesian formulation of the corrected understanding: the battery's labels are statistics of the **joint** draw $(p \bmod m^*, q \bmod m^*)$, and while the label vector is a genuine $12.7$-bit posterior update on that joint vector (whose prior entropy is $\approx 20$ bits), it is not a posterior update on any single residue coordinate.

**Theorem 5.11 (no pinning, Bayesian form).** *In the equidistribution model, $P_R(r) = 1/3$ for every $r$ and $P(r,t) \le 1/3$ for every $(r,t)$: the posterior mass of a single residue class is unchanged by the label, remaining at its prior value. For the joint pair $(p \bmod 9, q \bmod 9)$ under the corresponding product model the constant is $1/9$.*

*Proof sketch.* Direct evaluation of the marginals of the product law. $\square$

The general principle: constant-bounded posterior mass on joint residue vectors, and **no candidate filter without circularity**.

---

## 6. The adversarial control: abelian probes *are* filters

A negative result needs a control showing the framework can detect a positive instance. Replace $X^3 - 2$ by $X^2 - 2$.

**Theorem 6.1 (two square roots or none).** *For an odd prime $p$: if $2$ is a square in $\mathbb{Z}/p$ then $S(2,p) = 2$; otherwise $S(2,p) = 0$.*

*Proof sketch.* If $a^2 = 2$ then the solution set is $\{a, -a\}$, of size $2$ because $p$ is odd and $a \ne 0$. Otherwise the solution set is empty. $\square$

**Theorem 6.2 (the quadratic label is a residue function).** *For every odd prime $p$,*
$$S(2,p) = \begin{cases} 2, & p \equiv 1 \text{ or } 7 \pmod 8,\\ 0, & p \equiv 3 \text{ or } 5 \pmod 8.\end{cases}$$
*Consequently the explicit map $g : \mathbb{Z}/8 \to \mathbb{N}$, $g(r) = 2$ if $r \in \{1,7\}$ and $g(r) = 0$ otherwise, satisfies $g(p \bmod 8) = S(2,p)$ for all odd primes $p$.*

*Proof sketch.* This is the second supplement to quadratic reciprocity: $2$ is a quadratic residue mod $p$ exactly when $p \equiv \pm 1 \pmod 8$. Combine with Theorem 6.1 and note that an odd $p$ reduces to one of $1,3,5,7$ mod $8$. $\square$

**Theorem 6.3 (the boundary).** *The abelian probe $X^2 - 2$ admits a residue-to-label table at modulus $8$; the non-abelian probe $X^3 - 2$ admits no residue-to-type table at any modulus $2 \le m \le 24$.*

*Proof sketch.* Theorem 6.2 and Theorem 4.3. $\square$

**Interpretation.** The dividing line is the Galois group of the splitting field, not the size of the label alphabet nor the number of available bits:

- $\mathbb{Q}(\sqrt2)$ is abelian over $\mathbb{Q}$ and embeds in $\mathbb{Q}(\zeta_8)$. By Kronecker–Weber, abelian extensions are exactly those whose splitting behaviour is governed by congruence conditions — so a table *must* exist, and it does, with modulus $8$.
- $\mathbb{Q}(\sqrt[3]2, \omega)$ has Galois group $S_3$, whose commutator subgroup $A_3$ is nontrivial. The label is a class function of the Frobenius, and its non-abelian part is invisible to every congruence. Only the abelian quotient — the $\mathbb{Z}/2$ recording $p \bmod 3$ — filters.

This is why "add more dials" cannot help. More non-abelian dials add more capacity with respect to the joint draw and zero narrowing power for a single residue coordinate.

---

## 7. The measured window

To make the within-class variation concrete, consider the window of primes $5 \le p < 200$ with $p \equiv 1 \pmod 3$, i.e. those whose label is not already determined by $p \bmod 3$. There are $21$ such primes. Classify by residue mod $9$ (necessarily one of $1, 4, 7$) and by the cubic label ($0$ or $3$):

$$
\begin{array}{c|cc|c}
p \bmod 9 & T(p) = 0 & T(p) = 3 & \text{row total}\\\hline
1 & 6 & 2 & 8\\
4 & 5 & 2 & 7\\
7 & 5 & 1 & 6\\\hline
\text{total} & 16 & 5 & 21
\end{array}
$$

**Theorem 7.1 (census).** *The window contains exactly $21$ primes, with the cell counts displayed above.*

**Theorem 7.2 (labels are $0$ or $3$).** *Every prime of the window has label $0$ or $3$ — not by enumeration but as an instance of Theorem 3.6, since each such $p$ satisfies $p \equiv 1 \pmod 3$ and $p \nmid 2$.*

**Theorem 7.3 (every row is mixed).** *All six cells are strictly positive: every residue class mod $9$ in the window carries both labels.*

**Corollary 7.4 (the measured channel gap).** *Taking the empirical channel $P(r,t) = (\text{cell count})/21$, Theorem 5.7 applies with $r$ the class $1$ and $t_1 = 0 \ne t_2 = 3$, so*
$$H(T \mid R) > 0 \qquad\text{and}\qquad I(R;T) < H(T)$$
*strictly — the qualitative shape of every dial reading of the battery, including $I = 1.0012 < 2.2982 = H(T)$.*

Note the logical direction. Theorem 7.3 is verified by enumeration, but it is *not* what makes the verdict general. The general statement is Theorem 4.3 / Theorem 4.8; the census is a witness that the phenomenon is already visible in a tiny window, and it supplies the numbers whose entropy deficit matches the measured gap.

---

## 8. Algorithms

Three procedures suffice to reproduce everything above.

### 8.1 Label evaluation

**Cubic label by exponentiation.** For a prime $p \ge 5$: if $p \equiv 2 \pmod 3$ return $1$. Otherwise ($p \equiv 1 \pmod 3$) apply Euler's criterion for cubic residues: $2$ is a cube modulo $p$ if and only if $2^{(p-1)/3} \equiv 1 \pmod p$; return $3$ if so and $0$ otherwise. Cost: $O(\log p)$ modular multiplications, versus $O(p)$ for naive enumeration. Correctness follows because the cubic residues form the kernel of $x \mapsto x^{(p-1)/3}$ on $(\mathbb{Z}/p)^\times$, an index-$3$ subgroup.

### 8.2 Witness search (refuting a modulus)

**Input:** modulus $m$, prime bound $B$.
**Output:** a pair $(a,b)$ of primes $\equiv 1 \bmod 3$, $a \equiv b \pmod m$, $T(a) = 0$, $T(b) = 3$ — or "none found below $B$".

Sweep primes $p \le B$ with $p \equiv 1 \pmod 3$; bucket by $(p \bmod m)$ and by label; emit the first bucket containing both labels. Cost: $O(B/\log B)$ label evaluations, i.e. $\tilde O(B)$. Empirically the smallest witness for every $m \le 24$ occurs well below $B = 200$, and the pair $(7,31)$ alone handles all divisors of $24$.

### 8.3 Sound-filter maximality check

**Input:** modulus $m$, prime bound $B$.
**Output:** for each label $t$, the *minimal* sound accept-set $F_{\min}(t) = \{p \bmod m : T(p) = t,\ p \le B\}$, and the narrowing factor
$$\nu(m) \;=\; \frac{|F_{\min}(0) \cap F_{\min}(3)|}{|\{r : r \equiv 1 \bmod 3\}|}.$$
Any sound filter must contain $F_{\min}$, so an observed $\nu(m) = 1$ certifies that no sound filter narrows. The theorems of §4.2 assert $\nu(m) = 1$ for all $m \le 24$ (for the hard bit), and the computation confirms it in the window.

### 8.4 Channel statistics

Given the cell counts, compute $H(R), H(T), H(R,T)$ by direct summation of $\eta$, then $H(T\mid R) = H(R,T) - H(R)$ and $I = H(T) - H(T\mid R)$. Cost $O(|R||T|)$. The gap $H(T) - I = H(T\mid R)$ is the diagnostic quantity.

---

## 9. Discussion

### 9.1 What was refuted, and what was not

We did **not** refute that splitting labels carry information — they do, provably and measurably. We refuted the conversion of that information into candidate narrowing *via residue classes*. The distinction matters because the conversion step is where every practical use of the measurement would live. A channel may have high capacity with respect to one random variable and zero with respect to another; the utility of a measurement is always relative to the variable one intends to act on.

### 9.2 Capacity is about the joint draw

The battery's labels are statistics of the joint pair $(p \bmod m^*, q \bmod m^*)$. Their $12.7$ bits are a genuine posterior update on that $\approx 20$-bit joint vector — the capacity law $I \le H(T)$ is satisfied with room to spare, exactly as it must be. But an update on a joint law is not automatically an update on a marginal, and it is precisely the marginal (the residue class of $p$ alone) that a sieve or search can act on. The gap theorem quantifies the difference: the within-class variation $H(T\mid R)$ measures the part of the label's randomness that survives conditioning on the residue, and by Theorem 5.6 that part vanishes if and only if the sought table exists.

### 9.3 Why non-abelianness is the right invariant

Kronecker–Weber says a finite abelian extension of $\mathbb{Q}$ lies in a cyclotomic field; equivalently, its splitting behaviour is determined by a congruence condition on $p$ — a residue-to-type table with modulus equal to the conductor. So for abelian probes the table exists by theory, and for $X^2 - 2$ we exhibited it explicitly at modulus $8$. Conversely, a table for a probe with splitting field $L$ would force the Frobenius class in $\mathrm{Gal}(L/\mathbb{Q})$ to be a function of $p \bmod m$, hence force $L$ inside $\mathbb{Q}(\zeta_m)$, hence force $\mathrm{Gal}(L/\mathbb{Q})$ abelian. For $L = \mathbb{Q}(\sqrt[3]2,\omega)$, $\mathrm{Gal}(L/\mathbb{Q}) \cong S_3$ is not abelian; and indeed $\mathbb{Q}(\sqrt[3]2)$ is not even normal over $\mathbb{Q}$. The finite verification of §4 is a concrete, unconditional shadow of this structural fact: it does not presuppose Chebotarev or class field theory, it merely exhibits collisions.

### 9.4 The circularity

Reading the hard bit *for a specific candidate* $p$ requires deciding whether $2$ is a cube modulo $p$ — cheap if $p$ is known, impossible if $p$ is what you are hunting. The battery reads labels of the *hidden* factors; to use them as a filter one would need to compare them against per-candidate labels, but the candidates are residue classes, not primes, and a class has no label. Any attempt to give it one is refuted by Theorem 4.3. This is the "no candidate filter without circularity" principle.

### 9.5 Methodological note

The finding began as a bug: utility tables built by evaluating the probe polynomial at the residue, rather than by determining the type of primes in that class. What converted a bug into a theorem was a *soundness assertion* — a runtime check that the constructed filter never excludes the true factor. The check failed, and the failure had a diagnosis of much wider scope than the code path that produced it. A general recommendation follows: in any pipeline that prunes a search space, instrument the pruning step with a "never excludes the truth" assertion on instances where the truth is known. It is cheap, and its failures are informative.

---

## 10. Future directions

**D1. The unconditional non-existence theorem.** *Conjecture:* for every modulus $m \ge 1$ there exist primes $p \equiv q \pmod m$, both $\equiv 1 \pmod 3$, with $\#\{x : x^3 \equiv 2 \bmod p\} = 0$ and $\#\{x : x^3 \equiv 2 \bmod q\} = 3$. Equivalently, the cubic label is not periodic in $p$ under any modulus. The key insight is that periodicity of a splitting label modulo $m$ is exactly the statement that the splitting field embeds in $\mathbb{Q}(\zeta_m)$, i.e. that the label's field is abelian — and $\mathbb{Q}(\sqrt[3]2,\omega)$ has Galois group $S_3$ with nontrivial commutator subgroup. A proof therefore needs only the abelian half of class field theory plus the explicit $S_3$ structure, not full Chebotarev: one shows that a period $m$ forces $\mathbb{Q}(\sqrt[3]2) \subseteq \mathbb{Q}(\zeta_m)$ and contradicts it by comparing the ramification of $3$ or by the non-normality of $\mathbb{Q}(\sqrt[3]2)$. The finite verification ($m \le 24$) is complete; the missing step is a single structural lemma.

**D2. The capacity–utility dichotomy.** *Conjecture:* for any finite family of dials whose labels are class functions of the Frobenius of a non-abelian extension, the mutual information with the residue vector $p \bmod m$ is bounded by the information carried by the maximal abelian subextension — and that bound is the *entire* utility: candidate narrowing beyond it is impossible. The key insight is that the capacity law $I \le H(T)$ refines to $I \le H(T \text{ restricted to the abelianization})$, because the residue vector is measurable with respect to the abelian quotient only. In the channel framework of §5 this is a data-processing inequality for the projection $\mathrm{Gal}(L/\mathbb{Q}) \to \mathrm{Gal}(L/\mathbb{Q})^{\mathrm{ab}}$; the chain rule and equality case are already available, and the missing ingredient is a short data-processing lemma in the same pointwise calculus.

**D3. Bayesian no-pinning.** Strengthen Theorem 5.11 from the product model to the general case: show that for any battery of non-abelian dials the posterior mass assigned to any single joint residue vector remains bounded by a constant multiple of its prior, uniformly in the label reading. This would convert "the narrowing factor is $1$" from a statement about *sound set-valued filters* into a statement about *arbitrary Bayesian decision rules*, closing the last loophole — the possibility of soft, probability-weighted candidate reordering.

**D4. Higher-degree and composite probes.** Extend the census and refutations to $X^n - a$ for $n = 4, 5, 6$ and to non-cyclotomic quartics, and locate the exact boundary: which probes have abelian splitting fields (hence tables), which have solvable-but-non-abelian ones (hence tables only for the abelianization), and how much of the label entropy each abelianization can capture.

**D5. Quantifying the useful fraction.** For a probe with splitting field $L$, the abelianization captures a computable fraction of $H(T)$. Determine this fraction for standard probe families and compare it with the total battery capacity. The prediction of D2 is that the useful fraction equals the abelian fraction exactly — which for $X^3 - 2$ would give the observed one free bit and nothing else.

---

## 11. Conclusion

The six-dial battery measures honestly and measures a great deal. The measurement is about the joint residue draw of the hidden factors; it is not about any single factor's residue class, and the two are not interchangeable. For the smallest non-abelian probe we have made this precise: the cubic label splits into a free bit given by $p \bmod 3$ and a hard bit that is provably not a function of $p \bmod m$ for any $m \le 24$; every sound residue filter must therefore accept the same classes for both readings of the hard bit, so the narrowing factor is exactly $1$; and the information-theoretic shortfall $I < H(T)$ observed in every channel is not noise but a certificate of precisely that non-functionality, since $I = H(T)$ holds if and only if the label is a function of the residue.

The control experiment fixes the interpretation: the abelian probe $X^2 - 2$ *does* yield a filter, at modulus $8$. What blocks the cubic probe is not a shortage of bits but the non-abelianness of $S_3$ — the part of the Frobenius that no congruence can see. The labels are not filters.
