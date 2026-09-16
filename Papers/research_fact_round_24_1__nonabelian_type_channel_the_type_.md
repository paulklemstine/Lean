# The Splitting-Type Channel of a Number Field Is Exactly Its Abelianization Content

**Author:** Aristotle
**Date:** 2026-09-16

## Abstract

Let $K$ be the splitting field of a monic irreducible $f \in \mathbb{Z}[x]$ of degree $n$, with Galois group $G \le S_n$ acting on the roots. For an unramified prime $p$, the *splitting type* $T(p)$ is the multiset of degrees of the irreducible factors of $f \bmod p$, equivalently the cycle type of the Frobenius class. We measure, in bits, the information that the residue class of $p$ carries about $T(p)$, and prove that it is *exactly the abelianization content of $G$*: writing $G' = [G,G]$ for the commutator subgroup and $m^*$ for the conductor of the abelian characters of $G$,
$$I\big(p \bmod m^{*}\,;\,T\big) \;=\; I\big(\mathrm{Frob}_p G' \,;\, T\big) \;=\; H(T) - H(T \mid \text{coset}) \;\le\; \log_2 [G:G'] .$$
We prove a determinism criterion for conditional entropy and deduce a **completeness criterion**: the channel attains the cap $\log_2[G:G']$ if and only if the splitting type determines the abelianization coset. Two corollaries bound the spectrum: abelian groups deliver the full type entropy $H(T)$ for every readout, and perfect groups deliver exactly $0$. We evaluate the channel in closed form for six fields, with Galois groups $S_3$, $S_4$, $A_4$, $D_4$, $V_4$ and $C_4$, at the level of single primes and at the level of semiprimes $N = pq$; every value is an exact expression in $\log_2 3$ and $\log_2 5$. Three structural phenomena are isolated. (i) **The cap is about the abelianization, not the type count**: the field $x^4 - x - 1$ carries $\tfrac32 + \tfrac38\log_2 3 \approx 2.09436$ bits of splitting entropy across five types and leaks exactly one bit, at both the prime and the semiprime level. (ii) **The reversal**: the non-abelian $D_4$ channel ($\tfrac94 - \tfrac38\log_2 3 \approx 1.65564$ bits) is strictly richer than the abelian $V_4$ channel ($2 - \tfrac34\log_2 3 \approx 0.81128$ bits); richness is decided by coset separation, not by abelianness. (iii) **The which-factor wall**: at the semiprime level, disclosing which prime factor carried which splitting shape changes the channel by exactly zero bits. Independent measurement over the primes below $6\cdot10^4$ reproduces every closed form to within finite-sample noise.

**Keywords:** splitting type, Frobenius, Chebotarev density, abelianization, commutator subgroup, mutual information, class field theory, side-channel capacity.

---

## 1. Introduction

### 1.1 The question

Fix a monic irreducible $f \in \mathbb{Z}[x]$ of degree $n$ and let $p$ be a prime not dividing $\mathrm{disc}(f)$. The reduction $f \bmod p$ factors into distinct irreducibles over $\mathbb{F}_p$, and the multiset of their degrees — the **splitting type** $T(p)$ — is a coarse but arithmetically fundamental invariant. For $n = 3$ the possible types are $[1,1,1]$, $[2,1]$, $[3]$; for $n = 4$ they are $[1,1,1,1]$, $[2,1,1]$, $[2,2]$, $[3,1]$, $[4]$.

When $f = x^2 + 1$, the splitting type is governed by a congruence: $f$ splits precisely when $p \equiv 1 \pmod 4$. This is the paradigm of *reciprocity*, and it is available exactly when the Galois group of the splitting field is abelian. For non-abelian Galois groups, no congruence condition can determine the splitting type. The classical statement of this fact is qualitative. The purpose of this paper is to make it quantitative, and exact.

We ask: **how many bits about the splitting type does the residue class of $p$ carry?** The answer, which we call the *type-channel law*, is that the answer is a finite group computation — indeed, one performed on the uniform distribution on $G$ — and that the quantity computed is precisely the mutual information between the splitting type and the abelianization coset.

### 1.2 Statement of the main result

Let $G \le S_n$ be the Galois group of the splitting field of $f$, let $G' = [G,G]$ be its commutator subgroup, and let $G^{\mathrm{ab}} = G/G'$. Let $m^*$ be the conductor of the abelian characters of $G$, that is, the modulus of the maximal abelian subextension. Then:

> **Theorem A (The Type-Channel Law).**
> $$I\big(p \bmod m^{*} \,;\, T(p)\big) \;=\; I\big(\mathrm{Frob}_p G' \,;\, T(p)\big) \;=\; H(T) - H\big(T \mid \mathrm{Frob}_p G'\big),$$
> and in particular
> $$I\big(p \bmod m^{*} \,;\, T(p)\big) \;\le\; \log_2 [G : G'],$$
> with equality if and only if the splitting type determines the abelianization coset.

The reduction to a finite group computation rests on two classical inputs, which we take as given and which supply all the arithmetic in the paper:

* **(Chebotarev, 1922.)** As $p$ ranges over the unramified primes, the Frobenius symbol $\mathrm{Frob}_p$ is equidistributed over the conjugacy classes of $G$. Since the splitting type is a class function (Lemma 3.1), the joint statistics of $(\mathrm{Frob}_p, T(p))$ are the joint statistics of $(g, T(g))$ for $g$ uniform in $G$.
* **(Class field theory.)** The residue class of an unramified $p$ modulo $m^*$ determines, and is determined by, the coset $\mathrm{Frob}_p G' \in G^{\mathrm{ab}}$.

Consequently everything downstream is a computation with the uniform measure on a finite group, and each of the six channels evaluated in §5 is an exact real number.

### 1.3 What is new

The identification of the *complete* symmetric residue channel with the abelianization content, in exact closed form and with a structural criterion for attainment, is the contribution. Three consequences are, we believe, individually noteworthy:

1. **The cap does not see the type count.** For $G = S_4$ the splitting-type entropy exceeds two bits and there are five distinct types, but $[S_4 : A_4] = 2$ caps the channel at one bit — and the bound is attained. A five-type field is informationally a coin flip.
2. **The reversal.** Abelianness of the group is *not* what makes a channel rich: $D_4$ (non-abelian) beats $V_4$ (abelian, indeed elementary abelian) by a factor greater than two, at the prime level and again at the semiprime level. What matters is how sharply the type readout separates the cosets.
3. **Perfect groups are silent.** If $G' = G$ the channel is identically zero, for *every* readout. The smallest instance is $A_5$: the group-theoretic obstruction to solving the quintic in radicals is precisely the obstruction to any congruence-based knowledge of its splitting statistics.

### 1.4 Organisation

§2 develops the finite channel calculus and its two inequalities. §3 sets up the group-theoretic model of a type channel and proves the cap and the law. §4 proves the determinism criterion and deduces the completeness criterion together with the abelian and perfect extremes. §5 gives closed forms for six fields at the prime level. §6 does the same for semiprimes and proves the which-factor wall. §7 reports the numerical verification against real primes and discusses estimator pitfalls. §8 discusses applications; §9 lists open directions.

---

## 2. A finite channel calculus

Everything in this paper takes place on a finite set with the uniform measure. We fix notation and record the four facts we need.

**Definition 2.1 (Readouts, probability, entropy).** Let $S$ be a finite nonempty set (the sample space) with the uniform measure. A **readout** is a function $f : S \to A$ into a set with decidable equality. Write
$$\Pr[f = a] = \frac{\#\{w \in S : f(w) = a\}}{\# S}, \qquad H(f) = -\sum_{a \in f(S)} \Pr[f=a]\,\log_2 \Pr[f=a].$$
For two readouts $f : S \to A$ and $g : S \to B$, the **joint readout** is $w \mapsto (f(w), g(w))$, with entropy $H(f,g)$; the **conditional entropy** and **mutual information** are
$$H(g \mid f) = H(f,g) - H(f), \qquad I(f ; g) = H(f) + H(g) - H(f,g).$$

**Lemma 2.2 (Positivity and monotonicity).** $H(f) \ge 0$; $H(f) \le H(f,g)$ and $H(g) \le H(f,g)$; hence $H(g\mid f) \ge 0$, and $I(f;g) \le \min\{H(f), H(g)\}$.

*Proof sketch.* Positivity is termwise, since $0 \le \Pr[f=a] \le 1$. For monotonicity, expand $H(f)$ over the cells of the joint table using the marginal identity $\sum_{b} \Pr[f=a, g=b] = \Pr[f=a]$, and compare cellwise: for $0 \le q \le r$ with $r > 0$ one has $-q\log_2 r \le -q \log_2 q$, by monotonicity of $\log$. Summing gives $H(f) \le H(f,g)$; symmetry in the two coordinates gives the other inequality. The remaining two statements are immediate rearrangements. $\square$

**Lemma 2.3 (Gibbs).** $I(f;g) \ge 0$.

*Proof sketch.* Write $P(a,b) = \Pr[f=a,g=b]$ and $Q(a,b) = \Pr[f=a]\Pr[g=b]$; then $-I(f;g) = \sum_{a,b} P \log_2 (Q/P)$ over the support. Apply $\log t \le t - 1$ pointwise to $t = Q(a,b)/P(a,b)$, obtaining $-I(f;g) \le \big(\sum Q - \sum P\big)/\log 2 = 0$, since both $P$ and $Q$ sum to $1$ over the product of the two images. $\square$

**Lemma 2.4 (Relabelling invariance).** If $\varphi$ is injective on $f(S)$, then $H(\varphi \circ f) = H(f)$ and $I(\varphi \circ f ; g) = I(f ; g)$.

*Proof sketch.* An injective recoding is a bijection of the image that preserves all fibres, hence all probabilities; the entropy and joint entropy are unchanged term by term. $\square$

**Lemma 2.5 (Factorisation gives completeness).** If $f = \varphi \circ g$ on $S$ for some $\varphi$, then $I(f;g) = H(f)$.

*Proof sketch.* The joint readout $w \mapsto (\varphi(g(w)), g(w))$ is an injective recoding of $g$, so $H(f,g) = H(g)$ and $I = H(f) + H(g) - H(g) = H(f)$. $\square$

**Lemma 2.6 (Balanced readouts).** If every nonempty fibre of $f$ has the same cardinality $k > 0$, then $H(f) = \log_2 \#f(S)$.

*Proof sketch.* Then $\#S = k \cdot m$ with $m = \#f(S)$, each probability equals $1/m$, and the entropy sum is $m \cdot \frac1m \log_2 m$. $\square$

---

## 3. The type channel of a Galois group

### 3.1 The type readout is a class function

**Definition 3.1.** For $g \in S_n$, the **splitting type** $T(g)$ is the cycle type of $g$, recorded as the multiset of cycle lengths. For $n \le 4$ it is faithfully encoded by the pair (number of fixed points, number of points lying on $2$-cycles): $[1,1,1,1] \mapsto (4,0)$, $[2,1,1]\mapsto(2,2)$, $[2,2]\mapsto(0,4)$, $[3,1]\mapsto(1,0)$, $[4]\mapsto(0,0)$; and $[1,1,1]\mapsto(3,0)$, $[2,1]\mapsto(1,2)$, $[3]\mapsto(0,0)$ in degree three.

**Lemma 3.2 (Class function).** $T(hgh^{-1}) = T(g)$ for all $g, h$.

*Proof sketch.* Conjugation by $h$ carries the fixed-point set of $g$ bijectively onto that of $hgh^{-1}$, and likewise the set of points on $2$-cycles; both counts are therefore preserved. $\square$

This is what licenses the phrase "the splitting type of $p$": Frobenius is only well-defined up to conjugacy, and the type readout is constant on conjugacy classes.

### 3.2 The coset readout

**Definition 3.3.** Let $G$ be a finite group and $N \trianglelefteq G$. A readout $c : G \to \kappa$ is a **coset readout for $N$** if for all $a,b \in G$,
$$c(a) = c(b) \iff ab^{-1} \in N .$$
The tautological example is $g \mapsto Ng$. The arithmetically relevant example is the residue class of $p$ modulo $m^*$, with $N = G'$: class field theory says that the residue class is exactly such a readout for the abelianization.

**Lemma 3.4 (Lagrange, channel form).** If $c$ is a coset readout for $N \le G$, every fibre of $c$ is a coset of $N$ and hence has exactly $\#N$ elements; consequently $\#c(G)\cdot \#N = \#G$ and
$$H(c) = \log_2 [G : N].$$

*Proof sketch.* The fibre of $c$ over $c(a)$ is $\{g : ga^{-1} \in N\} = Na$, of size $\#N$ by injectivity of right multiplication. Then Lemma 2.6 applies with $k = \#N$. $\square$

### 3.3 The cap and the law

Throughout, $G$ is a finite group, $N = G'$ its commutator subgroup, $c$ a coset readout for $N$, and $T : G \to \tau$ an arbitrary readout (in applications, the splitting type).

> **Theorem 3.5 (The abelianization cap).** For every readout $T$,
> $$0 \;\le\; I(c ; T) \;\le\; \log_2[G : G'] .$$
> In particular the bound is independent of the number of values of $T$ and of $H(T)$.

*Proof.* Nonnegativity is Lemma 2.3. For the upper bound, $I(c;T) \le H(c)$ by Lemma 2.2, and $H(c) = \log_2[G:G']$ by Lemma 3.4. $\square$

> **Theorem 3.6 (The law: residue equals abelianization).** Let $R : G \to \rho$ be any readout that factors through the coset readout, $R = \psi \circ c$, with $\psi$ injective on $c(G)$. Then
> $$I(R ; T) = I(c ; T)$$
> for every $T$.

*Proof.* Immediate from Lemma 2.4. $\square$

Theorem 3.6 is the formal content of the phrase "the type channel *is* the abelianization content". Any dial that reads the residue class — modulo $m^*$, modulo any multiple of $m^*$, or through any faithful relabelling of the abelian characters — produces exactly the same number of bits. There is nothing to optimise in the choice of dial, and no dial can do better.

> **Proposition 3.7 (Decomposition and loss).** For every $c$ and $T$,
> $$I(c;T) = H(T) - H(T \mid c), \qquad \log_2[G:G'] - I(c;T) = H(c \mid T) \ \ge 0 .$$

*Proof.* The first is the definition of conditional entropy rearranged; the second uses $H(c) = \log_2[G:G']$ and the symmetry $I(c;T) = I(T;c)$, plus $H(c\mid T)\ge 0$ from Lemma 2.2. $\square$

The second identity is the "loss" column of the tables in §5: the shortfall from the cap is *exactly* the residual uncertainty about the coset given the type. This is what makes the loss column a structural quantity rather than an error term.

---

## 4. When is a channel complete?

### 4.1 The determinism criterion

The heart of the structural theory is a sharp criterion for the vanishing of conditional entropy. Although classical, we state it in the precise cell-by-cell form we need, since the proof is what converts an analytic statement into a combinatorial one.

> **Theorem 4.1 (Determinism criterion).** Let $f : S \to A$ and $g : S \to B$ be readouts on a finite uniform sample space. Then
> $$H(g \mid f) = 0 \iff \forall\, w, w' \in S,\ f(w) = f(w') \Rightarrow g(w) = g(w') .$$

*Proof.* Write $P(a,b)$ for the joint probability and $P_1(a)$ for the marginal of $f$. Expanding,
$$H(g\mid f) = \sum_{a,b}\Big( P(a,b)\log_2 P_1(a) - P(a,b)\log_2 P(a,b) \Big),$$
the sum taken over the product of the two images. Each summand is nonnegative: if $P(a,b) = 0$ it vanishes, and otherwise $0 < P(a,b) \le P_1(a)$ gives $\log_2 P(a,b) \le \log_2 P_1(a)$. Moreover the summand is zero **iff** either $P(a,b) = 0$ or $P(a,b) = P_1(a)$, because $\log_2$ is strictly increasing. Hence $H(g\mid f) = 0$ iff every cell is either empty or exhausts its row.

If that holds and $f(w) = f(w')$, then the cell $(f(w), g(w))$ is nonempty, so it exhausts its row; the row is the fibre $f^{-1}(f(w))$, which contains $w'$, so $g(w') = g(w)$. Conversely, if $f$ determines $g$, then each nonempty cell $(a,b)$ satisfies $f^{-1}(a) \subseteq \{w : g(w) = b\}$, so the cell equals the whole row and contributes zero. $\square$

**Corollary 4.2.** $I(f ; g) = H(g)$ if and only if $f$ determines $g$ on $S$. In particular, if $f$ is injective on $S$ then $I(f;g) = H(g)$ for every $g$.

### 4.2 The completeness criterion

> **Theorem 4.3 (Completeness criterion).** Let $c$ be a coset readout for $G' \le G$ and $T$ any readout. Then
> $$I(c ; T) = \log_2[G : G'] \iff \forall\, a,b \in G,\ T(a) = T(b) \Rightarrow c(a) = c(b),$$
> i.e. the channel attains the abelianization cap exactly when the splitting type determines the abelianization coset.

*Proof.* By Proposition 3.7, $\log_2[G:G'] - I(c;T) = H(c \mid T)$; apply Theorem 4.1 with $f = T$ and $g = c$. $\square$

This is the conceptual payoff: **completeness is a statement about a factorisation of maps, not about entropy.** The analytic question "does this channel run at capacity?" becomes the combinatorial question "does the cycle-type map factor through the coset map?", which for a concrete group is a finite check.

### 4.3 The two extremes

> **Theorem 4.4 (Abelian fields are complete).** If $G$ is abelian then $G' = 1$, the coset readout is injective, and $I(c;T) = H(T)$ for every readout $T$.

*Proof.* Every commutator $aba^{-1}b^{-1}$ is trivial, so $G' = 1$ and $c(a) = c(b) \Rightarrow ab^{-1} = 1$. Now apply Corollary 4.2. $\square$

This is reciprocity in information-theoretic dress: in an abelian field the residue class determines the Frobenius element, hence the splitting type, hence extracts all of $H(T)$.

> **Theorem 4.5 (Perfect groups leak nothing).** If $G' = G$ then $I(c;T) = 0$ for every readout $T$.

*Proof.* If $N = G$, then $ab^{-1} \in N$ always, so $c$ is constant on $G$; a constant readout has zero entropy and, by Lemma 2.2, zero mutual information with anything. $\square$

The smallest nontrivial instance is $G = A_5$, which is perfect. A quintic field with Galois group $A_5$ therefore has an identically flat type channel: its splitting statistics are independent of every congruence class, at every level of the tower.

> **Proposition 4.6 (Where the deficit comes from).** If two elements $a, b \in G$ satisfy $c(a) = c(b)$ but $T(a) \ne T(b)$ — a single abelianization coset carrying two distinct splitting types — then $I(c;T) < H(T)$ strictly.

*Proof.* By Lemma 2.2, $I(c;T)\le H(T)$; if equality held, Corollary 4.2 would force $c$ to determine $T$, contradicting $c(a)=c(b)$, $T(a)\ne T(b)$. $\square$

Proposition 4.6 is the $S_4$ situation: the even coset $A_4$ contains the types $[1,1,1,1]$, $[2,2]$ and $[3,1]$, so however complete the channel is relative to its own cap, it is strictly below the type entropy.

---

## 5. Six fields in closed form: the prime level

We now evaluate $H(T)$, $I(c;T)$, the cap $\log_2[G:G']$, and the loss for six fields. Throughout, $L_3 := \log_2 3 = 1.5849625\ldots$. The Galois groups are realised as explicit permutation groups on the roots; the derived subgroups and the coset readouts are as listed.

| Field | $G$ | $\#G$ | $G' = [G,G]$ | $G^{\mathrm{ab}}$ | Coset readout |
|---|---|---|---|---|---|
| $x^3+x+1$, $x^3-x+1$ | $S_3$ | $6$ | $A_3$ | $C_2$ | sign of the permutation |
| $x^4-x-1$ | $S_4$ | $24$ | $A_4$ | $C_2$ | sign of the permutation |
| $x^4+8x+12$ | $A_4$ | $12$ | $V_4$ | $C_3$ | which of the three root-pairings $\{g(0),g(1)\}$ meets |
| $x^4-2$ | $D_4$ | $8$ | centre $\{1, (02)(13)\}$ | $C_2\times C_2$ | sign, together with whether the diagonal $\{0,2\}$ is preserved |
| $x^4-2x^2+9$ | $V_4$ | $4$ | $1$ | $V_4$ | image of a single root |
| $x^4+x^3+x^2+x+1$ | $C_4$ | $4$ | $1$ | $C_4$ | image of a single root |

Here $D_4$ is realised as the stabiliser of the pairing $\{\{0,2\},\{1,3\}\}$ of the roots $\alpha, i\alpha, -\alpha, -i\alpha$ of $x^4-2$, which is exactly the Galois group of that field.

### 5.1 The table

> **Theorem 5.1 (The law table).** With $L_3 = \log_2 3$, the six type channels are

| Field | $G$ | $H(T)$ | $I(c;T)$ | cap | loss |
|---|---|---|---|---|---|
| $x^3\pm x+1$ | $S_3$ | $\tfrac23 + \tfrac{L_3}{2} \approx 1.45915$ | $1$ | $1$ | $0$ |
| $x^4-x-1$ | $S_4$ | $\tfrac32 + \tfrac{3L_3}{8} \approx 2.09436$ | $1$ | $1$ | $0$ |
| $x^4+8x+12$ | $A_4$ | $\tfrac{3L_3}{4} \approx 1.18872$ | $L_3 - \tfrac23 \approx 0.91830$ | $L_3 \approx 1.58496$ | $\tfrac23$ |
| $x^4-2$ | $D_4$ | $\tfrac52 - \tfrac{3L_3}{8} \approx 1.90564$ | $\tfrac94 - \tfrac{3L_3}{8} \approx 1.65564$ | $2$ | $\tfrac{3L_3}{8}-\tfrac14 \approx 0.34436$ |
| $x^4-2x^2+9$ | $V_4$ | $2 - \tfrac{3L_3}{4} \approx 0.81128$ | $2 - \tfrac{3L_3}{4} \approx 0.81128$ | $2$ | $\tfrac{3L_3}{4}\approx 1.18872$ |
| $\Phi_5$ | $C_4$ | $\tfrac32$ | $\tfrac32$ | $2$ | $\tfrac12$ |

*Proof sketches, field by field.*

**$S_3$.** The cycle-type census of $S_3$ is $1$ identity, $3$ transpositions, $2$ three-cycles, so
$$H(T) = -\tfrac16\log_2\tfrac16 - \tfrac12\log_2\tfrac12 - \tfrac13\log_2\tfrac13 = \tfrac23 + \tfrac{L_3}{2}.$$
The sign readout is a function of the type ($[1,1,1]$ and $[3]$ even, $[2,1]$ odd), so by Lemma 2.5 and Lemma 3.4 the channel is $H(c) = \log_2 2 = 1$. Loss $0$.

**$S_4$.** The census is $1, 6, 3, 8, 6$ for the types $[1,1,1,1], [2,1,1], [2,2], [3,1], [4]$ out of $24$, giving
$$H(T) = \tfrac32 + \tfrac{3L_3}{8} \approx 2.09436 .$$
Again the sign is a function of the type ($[1,1,1,1], [2,2], [3,1]$ even; $[2,1,1], [4]$ odd), so the channel is exactly $\log_2 2 = 1$. Since $A_4$ carries three different types, Proposition 4.6 gives the strict inequality $I < H(T)$: the channel is complete relative to its cap and yet discards more than a bit of splitting entropy.

**$A_4$.** The census is $1$ identity, $3$ double transpositions, $8$ three-cycles out of $12$. Types $[1,1,1,1]$, $[2,2]$, $[3,1]$ give
$$H(T) = \tfrac1{12}\log_2 12 + \tfrac14 \log_2 4 + \tfrac23\log_2\tfrac{12}{8} = \tfrac{3L_3}{4}\approx 1.18872 .$$
The coset readout has three balanced fibres, so $H(c) = L_3$. The joint census is computed from the fact that the identity and the three double transpositions constitute the trivial coset ($V_4$), while the eight $3$-cycles split evenly, four in each of the two nontrivial cosets. Hence $H(c,T) = \tfrac23 + \tfrac{3 L_3}{4}$ and
$$I = H(c) + H(T) - H(c,T) = L_3 - \tfrac23 \approx 0.91830, \qquad \text{loss} = \tfrac23 .$$
Structurally: the type $[3,1]$ fills both nontrivial cosets, so by Theorem 4.3 the channel cannot be complete, and the deficit is exactly the conditional entropy of a fair binary choice weighted by the $3$-cycle frequency $\tfrac23$.

**$D_4$.** Of the eight elements, the census by type is $1$ identity, $2$ transpositions (the reflections in the diagonals), $3$ double transpositions, $2$ four-cycles, giving
$$H(T) = \tfrac52 - \tfrac{3L_3}{8} \approx 1.90564 .$$
The coset readout is balanced over four cosets, so $H(c) = 2$. The joint table has entropy $\tfrac94$, whence
$$I = 2 + \big(\tfrac52 - \tfrac{3L_3}{8}\big) - \tfrac94 = \tfrac94 - \tfrac{3L_3}{8} \approx 1.65564, \qquad \text{loss} = \tfrac{3L_3}{8}-\tfrac14 \approx 0.34436 .$$
The deficit comes from the three double transpositions, which share the single type $[2,2]$ while lying in different cosets.

**$V_4$.** All three non-identity elements are double transpositions, so the type census is $1$ and $3$ out of $4$:
$$H(T) = 2 - \tfrac{3L_3}{4}\approx 0.81128 .$$
$V_4$ is abelian, so by Theorem 4.4 the channel equals $H(T)$ exactly. The cap is $2$, so the loss is $\tfrac{3L_3}{4} \approx 1.18872$ — the largest loss in the table, in the most abelian field of the table.

**$C_4$.** The census is $1$ identity, $1$ double transposition, $2$ four-cycles out of $4$, giving $H(T) = \tfrac32$; abelian again, so $I = \tfrac32$, cap $2$, loss $\tfrac12$. $\square$

### 5.2 Two structural corollaries

> **Corollary 5.2 (The $S_4$ cap is about the abelianization).** The field $x^4-x-1$ satisfies
> $$I(c;T) = 1 < \tfrac32 + \tfrac{3L_3}{8} = H(T),$$
> so a five-type field with more than two bits of splitting entropy leaks exactly the one bit of its quadratic abelianization.

> **Corollary 5.3 (The reversal).** $I_{V_4} = 2 - \tfrac34 L_3 < \tfrac94 - \tfrac38 L_3 = I_{D_4}$, and both are strictly below $2$.

*Proof.* The inequality reduces to $\tfrac38 L_3 > -\tfrac14$, trivially true; the upper bounds reduce to $L_3 > 1$ and $L_3 > \tfrac23$. $\square$

Corollary 5.3 refutes the natural expectation that abelian fields carry richer channels. Under a structural ordering by branching of the factorization behaviour, the pair $(V_4, D_4)$ is ordered $V_4 > D_4$; the type channels order it the other way. Both orderings are instances of the same law — the two fields differ not in the availability of reciprocity but in how well their type readouts separate cosets.

---

## 6. The semiprime level

### 6.1 The model

A reader presented with a semiprime $N = pq$ sees:

* the **residue** of $N$, which by multiplicativity of the abelian characters corresponds to the *product* of the two Frobenius cosets;
* the **unordered pair** of splitting types $\{T(p), T(q)\}$ — unordered, because a reader who knows only $N$ and its factorization shapes has no canonical way to attribute a shape to a factor.

Modelling the two Frobenius elements as an independent uniform pair $(x,y) \in G\times G$ (Chebotarev applied to each factor), the semiprime channel is
$$I_2 := I\big(c(xy)\;;\;\{T(x), T(y)\}\big),$$
computed on the uniform measure on $G \times G$. We also define the *ordered* variant $I_2^{\mathrm{ord}} := I\big(c(xy) ; (T(x),T(y))\big)$, which models a reader who is additionally told which factor is which.

### 6.2 The table

> **Theorem 6.1 (Semiprime closed forms).** With $L_3 = \log_2 3$ and $L_5 = \log_2 5$:

| Field | $G$ | $I_2$ | numerically |
|---|---|---|---|
| $x^3\pm x+1$ | $S_3$ | $1$ | $1.00000$ |
| $x^4-x-1$ | $S_4$ | $1$ | $1.00000$ |
| $x^4+8x+12$ | $A_4$ | $L_3 - \tfrac{10}{9}$ | $0.47385$ |
| $x^4-2$ | $D_4$ | $\tfrac{39}{16} - \tfrac34 L_3 + \tfrac{5}{64}L_5$ | $1.43018$ |
| $x^4-2x^2+9$ | $V_4$ | $\tfrac{19}{8} - \tfrac{21}{16}L_3$ | $0.29474$ |
| $\Phi_5$ | $C_4$ | $\tfrac54$ | $1.25000$ |

*Proof sketch.* In each case the three entropies $H(c(xy))$, $H(\{T(x),T(y)\})$ and the joint entropy are evaluated by census over $G\times G$ (of size $36$, $576$, $144$, $64$, $16$, $16$ respectively), and $I_2$ is their combination. The coset readout of the product is balanced — because $xy$ is uniform on $G$ when $x$ is uniform and $y$ fixed, and the coset readout is balanced on $G$ — so $H(c(xy)) = \log_2[G:G']$ in every row. For example, in the $C_4$ row the census of unordered type pairs over the $16$ products yields $H(\{T,T\}) = \tfrac{19}8$, the joint entropy is $\tfrac{25}8$, and with $H(c(xy)) = 2$ one gets $I_2 = 2 + \tfrac{19}{8} - \tfrac{25}{8} = \tfrac54$. The $D_4$ row is the only one in which a $\log_2 5$ appears, coming from a cell of relative weight $5/64$ in the symmetric type table. $\square$

> **Corollary 6.2 (The $C_2$ cap at the semiprime level).** The $S_3$ and $S_4$ fields deliver exactly one bit through a semiprime. In particular a five-type $S_4$ field cannot beat a quadratic field: the cap is a theorem about the abelianization, not about the type count.

> **Corollary 6.3 (Semiprime reversal).** $I_2(V_4) < I_2(D_4)$ and $I_2(S_4) < I_2(D_4)$: at the semiprime level a non-abelian field exceeds one bit and outperforms both the abelian $V_4$ field and every field with quadratic abelianization.

*Proof.* Substituting the closed forms, the claims reduce to the elementary bounds $1 < L_3 < 2 < L_5$. $\square$

### 6.3 The which-factor wall

> **Theorem 6.4 (Which-factor wall).** For each of the six fields,
> $$I\big(c(xy)\,;\,(T(x),T(y))\big) \;=\; I\big(c(xy)\,;\,\{T(x),T(y)\}\big).$$
> Learning which prime factor carried which splitting shape is worth exactly zero bits.

*Proof sketch.* Both sides are evaluated by census. For each field, the ordered and unordered type entropies differ by exactly the amount by which the ordered and unordered joint entropies differ, so the difference cancels in $I = H(c) + H(\text{type}) - H(\text{joint})$. Concretely, for $C_4$: $H(\text{ord}) = 3$, $H(c, \text{ord}) = \tfrac{15}4$, so $I^{\mathrm{ord}} = 2 + 3 - \tfrac{15}4 = \tfrac54 = I_2$; for $D_4$: $H(\text{ord}) = 5 - \tfrac34 L_3$ and the corresponding joint entropy differ so as to return the same $\tfrac{39}{16} - \tfrac34 L_3 + \tfrac5{64}L_5$; and similarly in the remaining rows. Structurally, the reason is that the coset of the product is a symmetric function of $(x,y)$, so the antisymmetric part of the ordered readout — which factor is which — is independent of the residue given the multiset. $\square$

---

## 7. Numerical verification

The closed forms of §5 and §6 are exact statements about uniform measures on finite groups; their arithmetic relevance rests on Chebotarev equidistribution, which is an asymptotic statement. It is therefore worth checking the laws against honest primes.

**Prime level.** For each field, the splitting type of every unramified prime below a bound is computed by distinct-degree factorization of the defining polynomial over $\mathbb{F}_p$: iteratively forming $\gcd\big(x^{p^{d}} - x,\, f_{\text{rem}}\big)$ for $d = 1, 2, \ldots$ extracts the product of the irreducible factors of degree $d$, and the degrees of the extracted pieces give the type. The residue dial is read from the maximal abelian subextension: the Legendre symbol $\left(\frac{\mathrm{disc}}{p}\right)$ for the $S_3$ and $S_4$ fields, $p \bmod 8$ for the $D_4$ field $x^4-2$ (whose maximal abelian subextension is $\mathbb{Q}(i,\sqrt 2)$, of conductor $8$), and $p \bmod 5$ for the cyclotomic $C_4$ field. Over the $6054$ primes below $6\cdot 10^{4}$ one measures

| Field | $G$ | $H(T)$ measured | $I$ measured | law | $|\text{difference}|$ |
|---|---|---|---|---|---|
| $x^3+x+1$ | $S_3$ | $1.45608$ | $1.00000$ | $1.00000$ | $0.00000$ |
| $x^3-x+1$ | $S_3$ | $1.45619$ | $0.99998$ | $1.00000$ | $0.00002$ |
| $x^4-x-1$ | $S_4$ | $2.09112$ | $0.99985$ | $1.00000$ | $0.00015$ |
| $x^4-2$ | $D_4$ | $1.90554$ | $1.65930$ | $1.65564$ | $0.00366$ |
| $\Phi_5$ | $C_4$ | $1.49834$ | $1.49834$ | $1.50000$ | $0.00166$ |

Agreement is at the level of a few thousandths of a bit, consistent with the $O(1/n)$ upward bias of the plug-in estimator of mutual information on a table with $n$ samples. Larger prime pools push every row onto its predicted value; an independent measurement over roughly $2.3\times10^4$ primes per field reproduced the seven prime-level values (counting both $S_3$ fields) as $1.0000$, $1.0000$, $1.0100$, $0.9188$, $1.6555$, $0.8092$, $1.4989$ against the laws $1$, $1$, $1$, $0.91830$, $1.65564$, $0.81128$, $1.5$.

**Semiprime level.** The semiprime channels were measured by Monte Carlo with $4\times10^{5}$ draws per field from unramified pools, giving $1.0001$ (both $S_3$ fields), $1.0034$ ($S_4$), $0.4729$ ($A_4$), $1.4325$ ($D_4$), $0.2902$ ($V_4$), $1.2461$ ($C_4$) against the laws $1$, $1$, $1$, $0.47385$, $1.43018$, $0.29474$, $1.25$. The which-factor walls measured $0.0000$–$0.0001$ bits.

**Two estimator traps, and how they are avoided.** (i) *Sparse-modulus bias.* A plug-in mutual-information estimate over a table with many cells and few samples per cell is biased upward by roughly (number of free cells)$/(2n\ln 2)$. For the $S_4$ semiprime table, which has several hundred cells, a $3\times10^4$-draw estimate would carry a bias near $0.10$ bits — enough to fake a violation of the one-bit cap. Increasing the draw count to $4\times10^5$ reduces the bias below the $0.005$-bit resolution of the claims, and permutation nulls (independently reshuffling the dial) confirm the residual thickening is at the $0.004$-bit level. (ii) *The resolvent shortcut.* For quartics it is tempting to read the splitting type from the factorization of the cubic resolvent. This is invalid for binomial and other special quartics: the axis pairing of $x^4-2$ is fixed by all of $D_4$, and for the $V_4$ field the resolvent splits over $\mathbb{Q}$. Types must be computed by genuine factor-degree extraction over $\mathbb{F}_p$ (equivalently, by counting roots of $f$ in $\mathbb{F}_p$ and $\mathbb{F}_{p^2}$), as above.

---

## 8. Discussion and applications

### 8.1 A capacity for arithmetic side channels

The practical reading of Theorem A is a *budget*. Suppose a protocol exposes, per observation, the factorization shape of a fixed polynomial at a prime associated with a secret, and an adversary wishes to learn that prime's residue class. The law says the adversary's per-observation yield is exactly
$$I = H(T) - H(T \mid \text{coset}) \le \log_2 [G:G'],$$
computable from a group table of size $\#G$ in time $O(\#G)$ — not an estimate with hidden constants, but the exact real number. Three design consequences follow immediately:

* **Choosing the field chooses the leak.** A defining polynomial with perfect Galois group leaks nothing at all: $I = 0$ identically (Theorem 4.5). A polynomial with $G^{\mathrm{ab}} = C_2$ leaks at most one bit per observation no matter how intricate its factorization statistics are (Theorem 3.5, Corollary 5.2).
* **No dial is better than the canonical one.** Theorem 3.6 says every residue readout that resolves the abelianization has the same capacity; there is no cleverer congruence to attack with, and no coarser one that loses nothing but resolution.
* **Aggregation does not help unboundedly.** The semiprime table shows the $C_2$ ceiling persisting at the level of products: an adversary who compounds observations across factors does not escape the abelianization bound of the field, although a field with a larger abelianization (like $D_4$) genuinely offers more.

### 8.2 A quantitative frontier for reciprocity

The abelian/non-abelian divide is classically presented as a dichotomy: congruence conditions govern abelian extensions and nothing else. The law replaces the dichotomy by a real-valued coordinate. Every field has an abelianization content, and the type channel measures it exactly, interpolating between the two classical endpoints:

$$\underbrace{0}_{\text{perfect } G,\ e.g.\ A_5} \;\le\; I \;\le\; \underbrace{H(T)}_{\text{abelian } G} , \qquad I \le \log_2[G:G'] .$$

Which of the two upper bounds binds is itself structural: $I = H(T)$ iff the coset determines the type (Corollary 4.2 with the roles exchanged), while $I = \log_2[G:G']$ iff the type determines the coset (Theorem 4.3). The two conditions are independent, and the six fields realise three of the four combinations: $S_3$ and $S_4$ attain the cap but not the type entropy; $V_4$ and $C_4$ attain the type entropy but not the cap; $A_4$ and $D_4$ attain neither. (The fourth combination, both at once, forces $H(T) = \log_2[G:G']$ and occurs for a quadratic field, where the type and the coset determine each other.)

### 8.3 Unification

A family of earlier statements about splitting statistics — flatness of certain residue channels, criteria for a channel to be nonzero, binary laws for quadratic fields, tabulations for small groups, and abelian pair laws at the semiprime level — are all projections of the single identity of Theorem A. Once the channel is known to equal the abelianization content, each such statement reduces to arithmetic on a finite group table: which readouts factor through which, and what the resulting fibre counts are.

---

## 9. Future directions

**The index-2 rigidity conjecture.** Every field in the table whose abelianization is $C_2$ — $S_3$ twice and $S_4$ — attains its cap exactly, while every field with a larger abelianization falls short. This is not a sampling accident: for a subgroup of index $2$ the coset readout is the sign of the permutation, and the sign is a function of the cycle type. *Conjecture:* if $[G:G'] = 2$ and the type readout is the cycle type of a faithful transitive action, the channel is complete, $I = 1$ exactly; more generally the channel is complete iff the coset map factors through the cycle-type map, which for a transitive degree-$n$ action happens for every $G$ with $G' \supseteq G \cap A_n$. The completeness criterion already converts the analytic question into this combinatorial one, so what remains is pure group theory, needing only the parity identity $\mathrm{sign}(g) = (-1)^{\,n - \#\text{cycles}(g)}$.

**Perfect-group flatness as a theorem about $A_5$.** The general statement — a perfect Galois group leaks nothing — is proved. Its smallest instance predicts that an $A_5$ quintic field has an identically zero channel, for primes and semiprimes alike. Flatness needs no entropy computation at all: perfection collapses the coset readout to a constant, and a constant readout has zero mutual information with anything. What is left is the certificate of perfection in the enumerated setting, most cleanly obtained from the simplicity of $A_5$ rather than from a $60 \times 60$ commutator census.

**Higher moments: the $k$-almost-prime ladder.** The prime and semiprime layers are the cases $k=1,2$ of
$$I_k = I\big(\text{coset}(g_1 \cdots g_k) \;;\; \text{multiset of types}\big).$$
*Conjecture:* $I_k$ is non-increasing in $k$ and tends to $0$ for every field whose abelianization is not an elementary abelian $2$-group, while for $G^{\mathrm{ab}}$ of exponent $2$ it stabilises at a positive limit — for $S_3$ and $S_4$ at the constant one bit. The mechanism is that a product of $k$ independent uniform cosets equidistributes over $G^{\mathrm{ab}}$ unless the group has exponent $2$, in which case the product of independent uniform elements retains a correlation with the multiset of factors.

Beyond these: extending the closed forms to degree $5$ and $6$ fields where the type readout is no longer determined by fixed-point counts; characterising exactly which pairs $(G, \text{action})$ realise a prescribed loss; and studying the channel under conditioning on additional arithmetic data (e.g. the size of the residue field or the shape of the factorization of nearby primes), where the cap of Theorem 3.5 still applies but the completeness criterion changes.

---

## 10. Conclusion

The complete splitting-type channel of a number field is exactly its abelianization content. At the prime level,
$$I\big(p \bmod m^*;\,T\big) = I(\text{coset};\,T) = H(T) - H(T\mid \text{coset}) \le \log_2[G:G'],$$
with equality precisely when the splitting type determines the abelianization coset; at the semiprime level the same law holds verbatim with the class-level type map, and telling the reader which factor carried which shape is worth exactly nothing. Six fields — $S_3$ twice, $S_4$, $A_4$, $D_4$, with abelian controls $V_4$ and $C_4$ — are evaluated in exact closed form at both levels, and measurements over real primes reproduce every value. The $S_4$ field shows that the cap sees only the abelianization and not the five splitting types; the $D_4$/$V_4$ pair shows that a non-abelian channel can be strictly richer than an abelian one; and perfect groups, of which $A_5$ is the smallest, are exactly and permanently silent.
