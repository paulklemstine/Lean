# Chebotarev Precision: Simultaneous Re-measurement of the Type-Channel Master Table, the Fine-Dial Reduction Theorem, and the Diagnosis of a Sparse-Dial Anomaly

**Aristotle**

---

## Abstract

For a Galois number field with group $G$, the *type channel* is the mutual information between a cheap observation of a prime $p$, its residue class modulo a fixed conductor (the *dial*), and an expensive one, the splitting type of $p$ (the cycle type of its Frobenius). Class field theory and the Chebotarev density theorem give this channel a *law value* determined by $G$ alone: $I_{\text{law}} = I(gG';\,\mathrm{type}(g))$ for $g$ uniform in $G$, where $G'$ is the commutator subgroup. We report the first simultaneous re-measurement of a full master table of such law values. It covers fifteen canonical fields, with one protocol, one seed and the same $295{,}946$ unramified primes below $2^{22}$ for every field. The largest deviation from law is $4.8\times 10^{-4}$ bits, twenty times inside a pre-stated budget of $10^{-2}$.

We prove the structural results that make a simultaneous measurement meaningful.

1. A *uniform-projection theorem*. Any population lying uniformly over $G$ reproduces every Frobenius readout's law, and consequently channels are invariant under thickening.
2. *Coprime flatness*. On a product population, readouts of the two factors share exactly zero bits. From this follows *simultaneous-measurement invariance* for linearly disjoint fields.
3. The *fine-dial reduction theorem*. On the fibre-product model of (Frobenius, residue) pairs with a uniform Artin map, $I(r;T) = I(gG';T)$ for every type readout $T$ and every dial size. Hence any dial is capped by $\log_2[G:G']$, any two dials have identical laws, and coprime residues add nothing.

We certify ten law constants to six decimals using the enclosure $1054/665 < \log_2 3 < 3647/2301$. We add a new row for the Frobenius group $F_{20}$, whose law is exactly $3/2$ bits, and exhibit a law collision between $F_{20}$ and $C_4$. Finally we diagnose the one anomaly, a historical value $1.0078$ for an $S_3$ field read through a sparse $229$-class dial. It is not the law value of any dial. It is the upward plug-in bias that a sparse sample must exhibit, and in the extreme sparse regime this bias provably saturates at the plug-in type entropy.

---

## 1. Introduction

Let $f \in \mathbb{Z}[x]$ be irreducible of degree $n$ with splitting field $K$ and Galois group $G = \mathrm{Gal}(K/\mathbb{Q})$, viewed as a group of permutations of the $n$ roots. For a prime $p$ not dividing the discriminant, the Frobenius conjugacy class $\mathrm{Frob}_p \subset G$ is defined, and the factorization pattern of $f \bmod p$ is the cycle type of $\mathrm{Frob}_p$. The Chebotarev density theorem says that $\mathrm{Frob}_p$ is equidistributed: the density of primes with $\mathrm{Frob}_p = C$ is $|C|/|G|$.

Abelian information about $\mathrm{Frob}_p$ is visible to congruences. By class field theory there is a conductor $N$ and a surjective *Artin map*
$$\varphi : (\mathbb{Z}/N\mathbb{Z})^\times \twoheadrightarrow G^{ab} = G/G'$$
with $\mathrm{Frob}_p \cdot G' = \varphi(p \bmod N)$ for unramified $p \nmid N$. Non-abelian information is not visible to congruences. This suggests an information-theoretic invariant: how many bits about the splitting type does the residue of $p$ carry? We call this mutual information the *type channel*. Over a long series of studies a master table of law values was assembled and compared with measurement, each field separately.

Separate measurements accumulate protocol drift. This paper reports, and puts on a rigorous footing, a single *simultaneous* audit of the whole table. The audit needs three kinds of mathematics.

- **What a Chebotarev population must show.** This means exact invariance and independence statements: thickening, coprime flatness, simultaneous measurement, and above all independence of the law from the dial (Sections 3–5).
- **Exact reference values** certified to the precision of the measurement (Section 6).
- **A diagnosis** of the single outlier, which separates "law" from "estimator" (Section 7).

The measurement results themselves are reported in Section 8, and algorithms in Section 9.

---

## 2. Definitions

Throughout, a **population** is a finite nonempty set $\Omega$ carrying the uniform probability measure. A **readout** is any function $X : \Omega \to A$ to a set $A$.

**Definition 2.1 (law, entropy).** The law of a readout $X$ on $\Omega$ is $P_X(a) = |X^{-1}(a)|/|\Omega|$. Its entropy in bits is
$$H_\Omega(X) = -\sum_{a \in X(\Omega)} P_X(a)\log_2 P_X(a).$$

**Definition 2.2 (channel).** For readouts $X, Y$ write $(X,Y)$ for the paired readout $\omega \mapsto (X(\omega), Y(\omega))$. The channel (mutual information) is
$$I_\Omega(X;Y) = H_\Omega(X) + H_\Omega(Y) - H_\Omega(X,Y).$$
The conditional channel given a readout $Z$ is
$$I_\Omega(X;Y\mid Z) = \sum_{z} P_Z(z)\, I_{Z^{-1}(z)}(X;Y),$$
where each fibre $Z^{-1}(z)$ is regarded as a population in its own right.

We use the standard facts that $I$ is symmetric and nonnegative, that it depends on $X$ only through the partition of $\Omega$ that $X$ induces, and the **chain rule**
$$I(T;(X,Y)) = I(T;X) + I(T;Y\mid X).$$

**Definition 2.3 (coset and type readouts; law value).** Let $G$ be a finite permutation group with commutator subgroup $G'$. The *coset readout* is $c(g) = gG' \in G/G'$. A *type readout* $T$ is any function of $g$; the canonical ones are
- the **full cycle type** of $g$, and
- the **coarse splitting type** $\sigma(g) = (\#\text{fixed points of } g,\ \#\text{points on 2-cycles of } g)$, which is the number of roots of $f$ in $\mathbb{F}_p$ together with the number of further roots in $\mathbb{F}_{p^2}$.

The **law value** of $(G,T)$ is $I_{\text{law}}(G,T) = I_G(c;T)$, computed on the population $G$.

**Definition 2.4 (Chebotarev–class-field population; uniform dial).** Let $S$ be a population (the Galois group), $c : S \to \kappa$ a coset readout, $R$ a finite set of residue classes, and $\varphi : R \to \kappa$ a map (the Artin map). The **fibre product** is
$$\Omega(S,R,c,\varphi) = \{(g,r) \in S \times R \;:\; c(g) = \varphi(r)\}.$$
The dial is **uniform with fibre size $m$** if $m>0$ and every coset $k \in c(S)$ has exactly $m$ residue classes above it: $|\{r\in R:\varphi(r)=k\}| = m$.

The fibre product models the joint law of $(\mathrm{Frob}_p, p \bmod N)$ over a large range of primes. Dirichlet's theorem makes the residue uniform, and Chebotarev applied to the compositum of $K$ with the $N$-th cyclotomic field makes the Frobenius uniform *subject to the Artin reciprocity constraint* $c(g) = \varphi(r)$.

---

## 3. Uniform projection and thickening

**Lemma 3.1 (counting over a uniform population).** Let $\Omega' \subseteq S \times \rho$ satisfy $w_1 \in S$ for every $w \in \Omega'$, and suppose every $g \in S$ has exactly $m$ points of $\Omega'$ above it. Then for every predicate $P$ on $S$,
$$|\{w\in\Omega' : P(w_1)\}| = m\cdot|\{g\in S: P(g)\}|.$$

*Proof.* Count fibrewise along the first projection. Each $g$ satisfying $P$ contributes exactly $m$ points, and no other $g$ contributes any. $\square$

**Theorem 3.2 (uniform projection).** Under the hypotheses of Lemma 3.1 with $m>0$, every readout $f$ of the first coordinate has the same entropy on $\Omega'$ as on $S$:
$$H_{\Omega'}(f\circ \mathrm{pr}_1) = H_S(f).$$
Consequently, for any two readouts $f, g$ of the first coordinate, $I_{\Omega'}(f\circ\mathrm{pr}_1; g\circ\mathrm{pr}_1) = I_S(f;g)$.

*Proof.* Because $m>0$, every $g\in S$ has a point above it, so the images agree: $f(\mathrm{pr}_1(\Omega')) = f(S)$. By Lemma 3.1 with $P \equiv \text{true}$ we get $|\Omega'| = m|S|$, and with $P = \{f = a\}$ we get $|f^{-1}(a)\cap\Omega'| = m|f^{-1}(a)\cap S|$. Hence $P_{f\circ\mathrm{pr}_1}(a) = P_f(a)$ for all $a$, so the entropies agree. For the channel statement, apply the same argument to $f$, $g$, and the paired readout $(f,g)$. $\square$

**Corollary 3.3 (thickening).** For any nonempty set $R$, and readouts $f, g$ of $S$,
$$H_{S\times R}(f\circ\mathrm{pr}_1) = H_S(f), \qquad I_{S\times R}(f\circ\mathrm{pr}_1;\,g\circ\mathrm{pr}_1) = I_S(f;g).$$

*Proof.* In $S\times R$ every $g$ has exactly $|R|>0$ points above it. $\square$

Replicating the population uniformly changes no channel. The experiment's *thickening control* tests exactly this prediction.

---

## 4. Coprime flatness and simultaneous measurement

**Lemma 4.1 (factorization).** For populations $S, R$, readouts $f$ of $S$ and $g$ of $R$, and values $a, b$,
$$P_{(f\circ \mathrm{pr}_1,\, g\circ\mathrm{pr}_2)}(a,b) = P_f(a)\,P_g(b).$$

*Proof.* The fibre of $(a,b)$ is $f^{-1}(a)\times g^{-1}(b)$, and cardinalities multiply. $\square$

**Theorem 4.2 (additivity).** For nonempty $S, R$,
$$H_{S\times R}(f\circ\mathrm{pr}_1, g\circ \mathrm{pr}_2) = H_S(f) + H_R(g).$$

*Proof.* Expand the logarithm of the product law of Lemma 4.1 and sum. $\square$

**Theorem 4.3 (coprime flatness).** For any populations $S, R$ and any readouts $f$ of $S$ and $g$ of $R$,
$$I_{S\times R}(f\circ\mathrm{pr}_1;\, g\circ\mathrm{pr}_2) = 0.$$

*Proof.* If either factor is empty, every term is zero. Otherwise Corollary 3.3, applied to each marginal, gives $H_{S\times R}(f\circ\mathrm{pr}_1)=H_S(f)$ and $H_{S\times R}(g\circ\mathrm{pr}_2)=H_R(g)$; the second uses the swap bijection $S\times R \cong R\times S$. Theorem 4.2 gives the joint entropy, and the three terms cancel. $\square$

When two number fields have linearly disjoint Galois closures, Chebotarev for the compositum makes the joint Frobenius uniform on $G_A\times G_B$. Theorem 4.3 is therefore the exact statement "disjoint fields do not talk".

**Theorem 4.4 (simultaneous-measurement invariance).** Let $S, R$ be nonempty, with readouts $c_A, T_A$ on $S$ and $c_B, T_B$ on $R$. On the joint population $S\times R$:
1. $I(c_A;T_A) = I_S(c_A;T_A)$;
2. $I(c_B;T_B) = I_R(c_B;T_B)$;
3. $I(c_A;T_B) = 0$;
4. $I(c_B;T_A) = 0$.

*Proof.* Items 1 and 2 are thickening (Corollary 3.3), using the swap bijection for item 2. Items 3 and 4 are coprime flatness (Theorem 4.3), using symmetry of $I$ for item 4. $\square$

**Example 4.5.** Take $x^3+x+1$ (group $S_3$) and $x^4-2$ (group $D_4$) measured jointly on $S_3\times D_4$. The two own-field channels are $1$ and $\tfrac94-\tfrac38\log_2 3$. Both cross channels vanish. Likewise, for $F_{20}\times A_4$ the own-field channels are $\tfrac32$ and $\log_2 3 - \tfrac23$, again with zero crosstalk.

---

## 5. The fine-dial reduction theorem

**Theorem 5.1 (fine-dial reduction).** Let the dial $(S,R,c,\varphi)$ be uniform with fibre size $m$, let $\Omega$ be its fibre product, and let $T$ be any readout of $S$. Then
$$I_\Omega(r\,;\,T\circ g) = I_S(c\,;\,T),$$
where $r(g,r)=r$ and $g(g,r)=g$ are the coordinate readouts.

*Proof.* There are four steps, and they make the Markov chain $r\to c\to T$ explicit.

*Step 1 (same partition).* On $\Omega$ the readouts $r$ and $(c\circ g,\, r)$ induce the same partition, because $c(g) = \varphi(r)$ is a function of $r$. Since channels depend only on partitions,
$$I_\Omega(r;T) = I_\Omega((c,r);T).$$

*Step 2 (chain rule).* By the chain rule,
$$I_\Omega(T;(c,r)) = I_\Omega(T;c) + I_\Omega(T;r\mid c).$$

*Step 3 (uniform projection).* In $\Omega$, each $g\in S$ has exactly $m$ points above it, namely $\{g\}\times\varphi^{-1}(c(g))$. Theorem 3.2 then gives $I_\Omega(T;c) = I_S(T;c)$.

*Step 4 (flatness on coset fibres).* For each coset $k$, the fibre of $\Omega$ over $c=k$ is the product
$$\{g\in S : c(g)=k\} \times \{r\in R: \varphi(r)=k\}.$$
By Theorem 4.3, $T$ (a readout of the first factor) and $r$ (a readout of the second) share zero bits on it. Every term of the conditional channel vanishes, so $I_\Omega(T;r\mid c)=0$.

Combining the steps with the symmetry of $I$ gives $I_\Omega(r;T) = I_S(c;T)$. $\square$

The theorem places no restriction on $|R|$. A dial with $2$ classes, with $22$, or with $228$ carries the same law.

**Corollary 5.2 (dial independence).** If $(S,R,c,\varphi)$ and $(S,R',c,\varphi')$ are two uniform dials over the same coset readout, of any sizes, then their type channels coincide for every $T$.

**Corollary 5.3 (abelian sandwich).** Let $S$ be a finite group with derived subgroup $N$, let $c$ be the coset readout $g\mapsto gN$, and let the dial be uniform. Then for every $T$,
$$\max\bigl(0,\, H_S(T) - \log_2|N|\bigr) \;\le\; I_\Omega(r;T) \;\le\; \log_2[S:N].$$

*Proof.* By Theorem 5.1 it suffices to bound $I_S(c;T)$. The upper bound is $I\le H(c) = \log_2[S:N]$, since $c$ is uniform on the cosets. For the lower bound, $I(c;T) = H(T) - H(T\mid c)$, and each coset has $|N|$ elements, so $H(T\mid c) \le \log_2|N|$. $\square$

**Corollary 5.4 (coprime residues add nothing).** Let $Q$ be a nonempty set of residues modulo a conductor coprime to the field, independent of Frobenius. Append them to a uniform dial: the residues become $R\times Q$ and the Artin map becomes $(r,q)\mapsto\varphi(r)$. The result is again uniform, with fibre size $m|Q|$. Hence
$$I((r,q);T) = I_S(c;T) = I(r;T).$$

This is the strongest form of the coprime-flatness control. A coprime residue is not merely uninformative on its own; it adds nothing on top of an informative dial.

**Example 5.5.** For $f = x^3-x-1$ (discriminant $-23$, group $S_3$) the Artin map is the quadratic character modulo $23$ on the $22$ nonzero residues. It sends squares to the even coset and non-squares to the odd coset, with $11$ residues over each, so the dial is uniform with $m=11$. Theorem 5.1 together with the $S_3$ law gives a population channel of exactly $1$ bit. The class-field dictionary can be checked directly. For every unramified prime $p<100$, the number of roots of $f$ mod $p$ is $0$, $1$ or $3$, and it equals $1$ (odd Frobenius, a transposition) if and only if $p$ is a non-residue modulo $23$. The companion computation extends the check to all $2{,}261$ unramified primes below $20{,}000$.

---

## 6. The master table to six decimals

### 6.1 A rigorous enclosure of $\log_2 3$

**Proposition 6.1.**
$$\frac{1054}{665} < \log_2 3 < \frac{3647}{2301}.$$

*Proof.* The integer inequalities $2^{1054}<3^{665}$ and $3^{2301}<2^{3647}$ hold by direct computation. Take $665$-th and $2301$-th roots respectively. These fractions come from the continued-fraction expansion of $\log_2 3$. $\square$

The width is about $6.5\times10^{-7}$. We also use $\log_2 5 < 7/3$, which follows from $5^3<2^7$.

### 6.2 Closed forms

The law values follow from the definitions by direct counting of the joint distribution of (coset, type).

- **$S_3$, $S_4$, and $S_3$ acting regularly on six points.** The sign is a function of cycle type and is a fair coin, so the law is $1$.
- **$A_4$.** Here $A_4' = V_4$ has index $3$. The coset $V_4$ contains the identity and three double transpositions; the other two cosets each consist of four 3-cycles. So $H(c\mid T) = \tfrac{8}{12}\cdot 1$, and the law is $\log_2 3 - \tfrac23 \approx 0.918296$.
- **$D_4$ (on the four roots of $x^4-2$).** Here $D_4' = \{1, r^2\}$ has index $4$. The cosets are $\{1, r^2\}$ (types $1^4$ and $2^2$), $\{r, r^3\}$ (type $4$), the diagonal reflections (type $1^2 2$) and the edge reflections (type $2^2$). Then $H(c)=2$, $H(T) = \tfrac52 - \tfrac38\log_2 3$ and $H(c,T) = \tfrac94$, so the law is $\tfrac94-\tfrac38\log_2 3\approx 1.655639$.
- **$V_4$ (regular).** The group is abelian, so the coset determines the type and the law equals $H(T) = H(\tfrac14,\tfrac34) = 2-\tfrac34\log_2 3 \approx 0.811278$.
- **$C_4$ (on the roots of $\Phi_5$).** The types are $1^4$, $2^2$, $4$, $4$, so the law is $H(T) = \tfrac32$.
- **$D_6$ on six points.** The full cycle type gives $1.729574$; the coarse splitting type, which merges the $6$-cycles with the $3^2$ elements, gives $1.396241$.
- **$F_{20}$.** See Theorem 6.3.

**Theorem 6.2 (master table precision).** Each of the ten law constants $S_3, S_4, A_4, D_4, V_4, C_4, D_6$ (full type), $D_6$ (coarse type), regular $S_3$, $F_{20}$ lies within $5\times10^{-7}$ of its recorded six-decimal value
$$1,\ 1,\ 0.918296,\ 1.655639,\ 0.811278,\ 1.5,\ 1.729574,\ 1.396241,\ 1,\ 1.5.$$
Five of them ($S_3$, $S_4$, $C_4$, regular $S_3$, $F_{20}$) hold with equality.

*Proof.* Substitute the closed forms and apply Proposition 6.1. $\square$

The maximal deviation between fresh constants and records is therefore below $5\times10^{-7}$. That is three orders of magnitude inside the measured simultaneous deviation $4.8\times10^{-4}$, so the measured deviation is attributable to the prime sample and not to the constants.

### 6.3 The $F_{20}$ row and a law collision

Let $F_{20} = \{x\mapsto ax+b : a\in(\mathbb{Z}/5)^\times,\ b\in\mathbb{Z}/5\}$, the Galois group of $x^5-2$ acting on the five roots $\sqrt[5]{2}\,\zeta_5^k$. It is nonabelian of order $20$, with derived subgroup the translations $C_5$ and abelianization $C_4$; the coset readout is the multiplier $a$.

**Theorem 6.3.** For the coarse splitting readout,
$$H(c) = 2,\quad H(T) = \tfrac{11}{10}+\tfrac14\log_2 5,\quad H(c,T) = \tfrac85+\tfrac14\log_2 5,$$
and therefore $I_{\text{law}}(F_{20}) = \tfrac32$ exactly. The loss $\log_2[G:G'] - I = \tfrac12$.

*Proof.* The types are as follows. The identity has five fixed points. The $4$ nontrivial translations are $5$-cycles. The $5$ maps with $a=-1$ are of type $1\,2^2$. The $10$ maps with $a=\pm 2$ are of type $1\,4$. The joint cells (coset, type) have sizes $1,4,5,5,5$, and the type cells have sizes $1,4,5,10$. The only confusion is between the cosets $a=2$ and $a=3$, which are both pure type $1\,4$. That confusion costs exactly half a bit. $\square$

**Corollary 6.4 (law collision).** $I_{\text{law}}(F_{20}) = I_{\text{law}}(C_4) = \tfrac32$, although $|F_{20}| = 5|C_4|$ and $F_{20}$ is nonabelian. A single scalar channel cannot distinguish them.

### 6.4 Two catches made exact

**Proposition 6.5 ($D_4$ generator closes to $S_4$).** In $S_4$, the $4$-cycle $(0\,1\,2\,3)$ and the diagonal transposition $(0\,2)$ lie in $D_4$, but the adjacent transposition $(0\,1)$ does not. The $4$-cycle and $(0\,1)$ generate all of $S_4$. Moreover
$$I_{\text{law}}(D_4) - I_{\text{law}}(S_4) = \tfrac54-\tfrac38\log_2 3 > \tfrac12.$$

*Proof.* A cycle together with a transposition of two cyclically adjacent points of its support generates the full symmetric group on that support. The numerical gap uses $\log_2 3 < 2$. $\square$

**Proposition 6.6 ($F_{20}$ seeded as $C_5$).** $I_{\text{law}}(C_5) = \log_2 5 - \tfrac85 < \tfrac34$, and $I_{\text{law}}(F_{20}) - I_{\text{law}}(C_5) > \tfrac34$.

*Proof.* $C_5$ is abelian, so its law is $H(T) = H(\tfrac15,\tfrac45) = \log_2 5 - \tfrac85$. Then use $\log_2 5 < 7/3$. $\square$

Both errors move a law by more than fifty times the measurement budget, so the hand-derived constants exposed them before any result was examined.

---

## 7. Diagnosis of the S3d anomaly

The field S3d is a cubic field with group $S_3$ read through a sparse dial of about $229$ residue classes (residues modulo $229$). Its historical channel value was $1.0078$ bits, while the simultaneous re-measurement gave $0.9998\pm 0.001$.

**Theorem 7.1 (every $S_3$ dial has law one bit).** For every uniform Artin dial over the sign readout of $S_3$, of any size and any fibre size, the population channel is exactly $1$ bit.

*Proof.* Combine Theorem 5.1 with $I_{\text{law}}(S_3)=1$. $\square$

**Corollary 7.2 (not physics).** For every such dial, $1.0078 - I_{\text{law}} > 0.0075$, while $|0.9998 - I_{\text{law}}| < 0.003 = 3\sigma$. The historical value is not the population value of any dial; the re-measurement is consistent with law.

**Theorem 7.3 (sparse-dial saturation).** Let $S$ be any finite sample and $r$ a dial that is injective on $S$, so that each residue class is seen at most once. Then for every type readout $T$,
$$\hat I_S(r;T) = \hat H_S(T),$$
whatever the underlying law.

*Proof.* If $r$ is injective, the readouts $r$ and $(r,T)$ induce the same partition (the discrete one). So $H(r,T) = H(r)$, and $I = H(T)$. $\square$

**Example 7.4 (overshoot on real primes).** For $x^3-x-1$ and the mod-$23$ dial, the sample $\{2,5,59\}$ has root counts $0,1,3$ (inert, $1+2$, split). It lies in three distinct residue classes. By Theorem 7.3,
$$\hat I = \log_2 3 \approx 1.585 > 1.0078 > 1 = I_{\text{law}}.$$
The same dial reads exactly $1$ bit on the Chebotarev population (Example 5.5). The overshoot is a finite-sample artefact and not a law.

**Quantitative picture.** The plug-in estimator is biased upwards on fine dials. A first-order (Miller–Madow-type) expansion of each entropy term gives
$$\mathbb{E}\hat I_n - I_{\text{law}} \approx \frac{K_{rT} - K_r - K_T + 1}{2n\ln 2},$$
where $K_r$, $K_T$ and $K_{rT}$ count the occupied cells of the dial, the type and the joint readout. For an $S_3$ dial with $K$ classes, $K_{rT} = 3K/2$, so the bias is about $(K/2-2)/(2n\ln 2)$. Simulation of ideal Chebotarev samples (Section 9, Algorithm 4) agrees with this formula. With $K=228$ the mean bias is $+0.0082$ at $n=10^4$ and $+0.0008$ at $n=10^5$; with $K=22$ it is $+0.0006$ at $n=10^4$. The historical overshoot of $0.0078$ is thus the expected bias of a sparse dial on a population of order $10^4$. At $n = 295{,}946$ the predicted bias is below $3\times10^{-4}$, consistent with the re-measurement. (This expansion is heuristic; making it rigorous is Conjecture 10.1.)

The ground-truth dictionary check (Example 5.5) rules out the other possible explanation, dictionary drift. The diagnosis is **small-population plug-in bias on a sparse dial — not physics, not dictionary drift.**

---

## 8. The simultaneous measurement

**Protocol.** There were fifteen canonical fields covering the groups of the master table. One protocol and one random seed were used. For every field, the population was the set of $295{,}946$ unramified primes below $2^{22}$. Law values were computed fresh from explicit permutation groups. The pre-stated tolerance for each recorded headline was $\max(0.01,\ 3\sigma)$.

**Hypothesis H0 (precision holds).** Every field lies within the budget of its law value.

**Result.** H0 holds. The global maximum $|I_{\text{meas}} - I_{\text{law}}|$ was $4.8\times10^{-4}$ bits, $20\times$ inside the budget, and no field was flagged.

**Controls.**
- *Thickening control:* $-0.00044$ bits, zero to measurement precision, as Corollary 3.3 predicts.
- *Coprime flatness:* on six fields the channel of a coprime residue was below the null bias floor, as Theorem 4.3 and Corollary 5.4 predict.
- *Ground truth:* an independent factorization check of splitting types gave $0$ mismatches on all fifteen fields.
- *Abelian dictionaries:* the residue-to-coset dictionaries were correct $100\%$ of the time.
- *Fresh constants:* all ten group law values agreed with the hand-derived constants to six decimals (Theorem 6.2).

**Ledger.** Seven errors were caught, all before results were examined. They include the $D_4$ generator that closed to $S_4$ (Proposition 6.5), $F_{20}$ seeded as $C_5$ (Proposition 6.6), a least/most-significant-bit exponent mismatch, and an incorrect test for ramification at primes $q$ with $q^2\mid \mathrm{disc}$.

**Interpretation.** The programme's record of roughly 128 measurements is internally consistent to $5\times10^{-4}$ bits. The earlier reproducibility audits re-ran stored seeds one field at a time. This audit extends them to a cross-field simultaneous measurement, and Theorem 4.4 guarantees that the simultaneous protocol is equivalent in law to the separate one.

---

## 9. Algorithms

**Algorithm 1 (law value from generators).** Input: generators of a permutation group and a type readout $T$.
1. Close the generators under composition by breadth-first search to obtain $G$.
2. Close the set of commutators $\{aba^{-1}b^{-1}\}$ to obtain $G'$.
3. Label each $g$ by a canonical representative of $gG'$.
4. Return $H(c)+H(T)-H(c,T)$ on the uniform population $G$.

Cost: $O(|G|\cdot\#\text{gens})$ for the closure, $O(|G|^2)$ for the commutators and $O(|G||G'|)$ for the labelling. Every master-table group is computed in milliseconds.

**Algorithm 2 (fibre-product verification of the fine-dial reduction).** Build $\Omega = \{(g,r) : c(g) = \varphi(r)\}$, check that the dial is uniform, and compare $I_\Omega(r;T)$ with $I_G(c;T)$. Cost: $O(|G||R|)$.

**Algorithm 3 (dictionary and plug-in on real primes).** Sieve the primes, count the roots of $f$ modulo $p$, compare with the Artin map, and compute the plug-in channel of $p\bmod N$ against the root count on growing prefixes.

**Algorithm 4 (bias simulation).** Draw $n$ independent points from the fibre-product population, compute $\hat I_n$, average over trials, and compare with the first-order prediction $(K_{rT}-K_r-K_T+1)/(2n\ln 2)$.

---

## 10. Discussion and future work

The audit separates three things that are easy to confuse: the *law* (an exact group invariant), the *protocol* (how fields and primes are grouped), and the *estimator* (plug-in mutual information on finite samples). The theorems above show that the protocol cannot affect the law: thickening, joint measurement and the choice of dial all leave the law value unchanged. Every remaining discrepancy is therefore an estimator effect. That is exactly what allowed the S3d anomaly to be classified with confidence.

**Conjecture 10.1 (Miller–Madow law for type channels).** For a uniform dial with $K$ classes over a group with abelianization index $k$ and type count $t$, and $n$ Chebotarev-equidistributed primes, the expected plug-in channel equals $I_{\text{law}}$ plus a positive term of order $Kt/n$. The term is computable cell by cell from the support of the fibre product, up to $O(n^{-2})$. Because the law is dial-independent (Corollary 5.2), any dependence of a measured channel on $K$ is a pure estimator effect.

**Conjecture 10.2 (abelianization-shadow collisions).** Two groups have the same type channel whenever the pushforwards of their (coset, type) laws agree. In particular, it is natural to ask which Frobenius groups $C_p\rtimes C_{p-1}$ collide with cyclic groups, as $F_{20}$ and $C_4$ do.

Other directions include bias-corrected estimators with certified error bars; extending simultaneous invariance to fields that are *not* linearly disjoint, where the joint group is a fibre product of Galois groups and cross channels can be nonzero; and certified constants for larger groups.

---

## 11. Conclusion

A full table of type-channel law values was measured simultaneously and reproduced to $4.8\times10^{-4}$ bits. Exact theorems underpin this. Uniform populations reproduce every Frobenius law. Product populations carry zero cross-information. Residue dials of any fineness carry exactly the abelianization-coset law. The constants are certified to six decimals, including a new $F_{20}$ row that collides with $C_4$. The single anomaly is the plug-in bias of a sparse dial on a small sample. In the extreme sparse regime that bias provably saturates at the type entropy, as the three primes $2, 5, 59$ show by overshooting to $\log_2 3$ bits.
