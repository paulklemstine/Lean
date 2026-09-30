# The Type-Channel Law: How Much a Splitting Type Reveals About the Residue Class of a Prime

**Aristotle** (Harmonic)
2026-09-29

---

## Abstract

Let $f \in \mathbb{Z}[x]$ be a separable polynomial of degree $n$ with Galois group $G \le S_n$. By Chebotarev's density theorem the Frobenius element of a random unramified prime is uniformly distributed on $G$, and its cycle type is the splitting type $T$ of $f$ modulo $p$. By class field theory, the coset $c$ of the Frobenius modulo the derived subgroup $G'$ is determined by $p$ modulo the conductor of the maximal abelian subfield. The *type channel* is the mutual information $I(c;T)$ for $g$ uniform on $G$. It measures how much the factorization pattern of $f \bmod p$ reveals about the residue class of $p$.

We prove a consolidated law for this channel, which unifies a series of earlier empirical and case-by-case findings. (i) **The unified law.** $I(c;T) = H(T) - H(T\mid c) = \log_2[G:G'] - H(c\mid T)$. The channel equals $H(T)$ when $G$ is abelian and vanishes when $G$ is perfect. (ii) **A two-sided sandwich.** $\max(0, H(T) - \log_2|G'|) \le I(c;T) \le \min(H(T), \log_2[G:G'])$. (iii) **Universality.** Realisations of a group related by an injective homomorphism that respects derived subgroups and splitting-type partitions have identical channels, for any coset labelling. This covers conjugate permutation representations and realisations of different degree. (iv) **A calculus of batteries.** Joint channels of several dials obey the chain rule $I(c;(T_1,T_2)) = I(c;T_1) + I(c;T_2\mid T_1)$ with a nonnegative conditional term. They are monotone, capped by $\log_2[G:G']$, and saturate as soon as one dial is complete. (v) **Exact degree-six channels.** For $x^6-2$ (group $D_6$) the channel is $\tfrac43 + \tfrac14\log_2 3$ bits, with a strictly positive loss $\tfrac23 - \tfrac14\log_2 3$. The degree-$\le 4$ type encoding under-reports it by exactly $\tfrac13$ bit. For the Galois closure of $x^3-2$ (group $S_3$ acting regularly on six points) the channel is exactly one bit, the same as for the cubic realisation.

We also record two negative results. The informal statement "$I$ equals the expected entropy of the abelianization class given the type" is false, and $S_3$ is a counterexample. Unconditional super-additivity of batteries fails for every nontrivial abelianization. All closed forms are cross-checked numerically against real primes below $60{,}000$.

---

## 1. Introduction

A polynomial $f\in\mathbb{Z}[x]$ that is irreducible over $\mathbb{Q}$ usually factors modulo primes. The pattern of factor degrees, the *splitting type*, is governed by the Galois group $G$ of $f$. Classical results (Frobenius, Chebotarev, Artin) say that for primes $p \nmid \operatorname{disc}(f)$ the Frobenius conjugacy class $\operatorname{Frob}_p \subset G$ has cycle type equal to the splitting type, and that $\operatorname{Frob}_p$ is equidistributed in $G$ as $p$ varies. Class field theory adds that the image of $\operatorname{Frob}_p$ in the abelianization $G^{\mathrm{ab}} = G/G'$ depends only on $p$ modulo the conductor $m$ of the maximal abelian subextension.

This raises a quantitative question with a cryptographic flavour. An adversary who observes only how $f$ factors modulo a secret prime $p$ wants to know how many bits of information that gives about $p \bmod m$. Equivalently, how much of the abelian part of the Frobenius can be recovered from its cycle type? The question arose in an extended experimental programme on "type channels" in degrees two through six, on joint readouts ("batteries"), and on the universality of channel values across fields with the same Galois group. This paper consolidates that programme into a single set of statements with complete proofs, corrects one informal claim, and extends the exact computations to degree six.

Throughout, the arithmetic enters only through the dictionary

$$\text{(prime } p\text{, uniformly at random)} \;\longleftrightarrow\; (g \in G \text{ uniformly at random}),$$
$$\text{splitting type of } f \bmod p \;\longleftrightarrow\; \text{cycle type of } g,\qquad p \bmod m \;\longleftrightarrow\; gG' \in G/G'.$$

Every theorem below is a statement about finite groups with the uniform measure. The arithmetic interpretation follows from Chebotarev's theorem in the limit of many primes.

### 1.1 Summary of contributions

| # | result | statement |
|---|---|---|
| 1 | Unified law | $I = H(T)-H(T\mid c) = \log_2[G:G'] - H(c\mid T)$; abelian $\Rightarrow I=H(T)$; perfect $\Rightarrow I=0$ |
| 2 | Residual bound | $H(T\mid c) \le \log_2 \lvert G'\rvert$ |
| 3 | Sandwich | $\max(0,H(T)-\log_2\lvert G'\rvert) \le I \le \min(H(T),\log_2[G:G'])$ |
| 4 | Universality | injective homomorphic transport preserves $I$, in label-free form |
| 5 | Battery calculus | chain rule, monotonicity, ceiling, saturation |
| 6 | Negative results | $I \ne H(c\mid T)$ in general; batteries are not always super-additive |
| 7 | Degree six | $D_6$: $I = \tfrac43+\tfrac14\log_2 3$; regular $S_3$: $I = 1$ |
| 8 | Field audit | $D_4$ lower bound non-vacuous; conjugate $D_4$ has identical channel; $S_4$ battery saturated |

---

## 2. Setting and definitions

### 2.1 Finite Shannon calculus

Let $S$ be a finite nonempty set with the uniform probability measure. A *readout* is any function $f : S \to A$ into a set with decidable equality. The *fibre* of $f$ over $a$ is $S_a = \{w \in S : f(w) = a\}$, and $p_f(a) = |S_a|/|S|$.

**Definition 2.1 (entropy, mutual information).**
$$H(f) = -\sum_{a \in f(S)} p_f(a)\log_2 p_f(a), \qquad I(f;g) = H(f) + H(g) - H(f,g),$$
where $(f,g)$ denotes the pair readout $w\mapsto (f(w),g(w))$. The conditional entropy is $H(f\mid g) = H(f,g) - H(g)$.

**Definition 2.2 (conditional mutual information).** For readouts $f,g,t$,
$$I(f;g\mid t) = \sum_{b\in t(S)} p_t(b)\, I_{S_b}(f;g),$$
where $I_{S_b}$ is the mutual information computed on the fibre $S_b = t^{-1}(b)$ with its own uniform measure.

We use the following standard facts, all of which have elementary proofs on uniform finite spaces.

**Lemma 2.3 (Gibbs).** $I(f;g) \ge 0$, and consequently $I(f;g\mid t) \ge 0$.

**Lemma 2.4 (data processing for entropy).** For any map $\varphi$, $H(\varphi\circ f) \le H(f)$.

*Proof sketch.* $H(\varphi\circ f) \le H(\varphi\circ f, f)$, and the pair readout $(\varphi\circ f, f)$ is an injective relabelling of $f$ (via $a\mapsto(\varphi(a),a)$), so it has entropy $H(f)$. $\square$

**Corollary 2.5 (ceiling).** $H(\mathrm{id}_S) = \log_2|S|$, since every fibre is a singleton. Hence every readout satisfies $H(f) \le \log_2 |S|$.

**Lemma 2.6 (transport).** If $e : S \to S'$ is injective, then for all readouts $f,g$ on $S'$ we have $H_{e(S)}(f) = H_S(f\circ e)$ and $I_{e(S)}(f;g) = I_S(f\circ e; g\circ e)$.

*Proof sketch.* Image fibres correspond bijectively to fibres, with equal cardinalities, because $e$ is injective. $\square$

**Lemma 2.7 (partition invariance).** If $f$ and $f'$ induce the same partition of $S$, meaning $f(a)=f(b)\iff f'(a)=f'(b)$ for all $a,b\in S$, then $I(f;g) = I(f';g)$ for every $g$.

*Proof sketch.* Entropies depend only on the multiset of fibre sizes, and the fibres of $(f,g)$ and $(f',g)$ are the same subsets of $S$. $\square$

**Lemma 2.8 (chain rule).** For readouts $X, t$,
$$H(X,t) = H(t) + \sum_{b \in t(S)} p_t(b)\, H_{S_b}(X).$$

*Proof sketch.* Write $p_{(X,t)}(a,b) = p_t(b)\,p_{X\mid S_b}(a)$, expand the logarithm of the product, and sum over $a$ first using $\sum_a p_{X\mid S_b}(a) = 1$. $\square$

### 2.2 The group setting

Let $\Gamma$ be a group, $S \subseteq \Gamma$ a finite subgroup (the Galois group), and $N \subseteq S$ a subgroup. In applications $N = S'$ is the derived subgroup.

**Definition 2.9 (coset readout).** A readout $c : \Gamma\to K$ is a *coset readout* for $N$ in $S$ if for all $a, b \in S$,
$$c(a) = c(b) \iff a^{-1}b \in N.$$
We write $k = |c(S)| = [S:N]$ for the number of cosets.

**Definition 2.10 (derived subgroup).** $N$ is the *derived subgroup* of $S$ if it contains every commutator $aba^{-1}b^{-1}$ ($a,b\in S$) and is the smallest subgroup that does.

**Definition 2.11 (splitting-type readout, type channel).** A *splitting-type readout* is any readout $T$ on $S$. The canonical one for $S \le S_n$ is the cycle type. The *type channel* is $I(c;T)$, computed with $g$ uniform on $S$.

**Definition 2.12 (loss, completeness).** The *loss* of the channel is $\log_2 k - I(c;T)$. The readout $T$ is *complete* if it determines the coset, that is, $T(a) = T(b) \Rightarrow c(a) = c(b)$ for $a,b\in S$.

**Definition 2.13 (faithful sextic type).** For $g \in S_6$ let
$$\tau_6(g) = \bigl(\#\{\text{fixed points}\},\ \#\{\text{points on 2-cycles}\},\ \#\{\text{points on 3-cycles}\}\bigr).$$
This separates all eleven cycle types of $S_6$. The *quartic record* $\tau_4(g) = (\#\text{fixed points}, \#\text{points on 2-cycles})$ is faithful only in degree $\le 4$.

**The arithmetic dictionary.** For $f$ with Galois group $S$ acting on its roots, a random unramified prime $p$ gives $\operatorname{Frob}_p$ uniformly distributed on $S$ (Chebotarev). The cycle type of $\operatorname{Frob}_p$ is the splitting type of $f \bmod p$, and $\operatorname{Frob}_p\, S'$ is determined by $p \bmod m$ (class field theory, with $m$ the conductor of the maximal abelian subfield). Hence $I(c;T)$ is the asymptotic mutual information between $p \bmod m$ and the splitting type.

---

## 3. The basic structure of coset readouts

**Lemma 3.1 (Lagrange in bits).** If $c$ is a coset readout for $N \subseteq S$, then $|S| = k\,|N|$, every fibre of $c$ has size $|N|$, and
$$H(c) = \log_2 k, \qquad \log_2|S| = \log_2 k + \log_2|N|.$$

*Proof sketch.* The fibre of $c$ through $a$ is the coset $aN$, which has $|N|$ elements. A readout with $k$ fibres of equal size has entropy $\log_2 k$. $\square$

**Lemma 3.2 (completeness criterion).** $I(c;T) = \log_2 k$ if and only if $T$ is complete, i.e. $H(c\mid T) = 0$.

*Proof sketch.* $I(c;T) = H(c) - H(c\mid T) = \log_2 k - H(c\mid T)$, and $H(c\mid T) = 0$ exactly when $c$ is constant on each fibre of $T$. $\square$

---

## 4. The unified type-channel law

**Theorem 4.1 (Unified Type-Channel Law).** Let $S$ be a finite group with derived subgroup $N$, $c$ a coset readout for $N$, and $T$ any readout. Then

1. $I(c;T) = H(T) - H(T\mid c)$;
2. $I(c;T) = \log_2[S:N] - H(c\mid T)$;
3. *(abelian endpoint)* if $S$ is abelian, then $I(c;T) = H(T)$;
4. *(perfect endpoint)* if $N = S$, then $I(c;T) = 0$.

*Proof sketch.* (1) is the definition of mutual information rearranged. (2) follows from (1)'s symmetric counterpart $I = H(c) - H(c\mid T)$ together with Lemma 3.1. For (3): if $S$ is abelian, every commutator is trivial, so $N = \{1\}$ and $c$ is injective on $S$. Then $T$ is a function of $c$ on $S$, so $H(T\mid c) = 0$ and $I = H(T)$. For (4): if $N = S$ there is a single coset, $c$ is constant, $H(c) = 0$, and $0 \le I \le H(c) = 0$. $\square$

**Remark 4.2 (reading the law).** Form (1) says the channel is the splitting-type entropy minus the part of it that the residue class cannot account for. Form (2) says the channel is the ceiling $\log_2[G:G']$ minus the loss $H(c\mid T)$, the coset uncertainty that survives observation of the type.

### 4.1 A correction to the informal statement

An earlier informal version of the law asserted that for groups strictly between abelian and perfect, the channel "is exactly $\mathbb{E}[H(G^{\mathrm{ab}}\text{-class}\mid T)]$", i.e. $I(c;T) = H(c\mid T)$. This is false.

**Proposition 4.3 (counterexample).** For $S = S_3$ realised by $x^3+x+1$ with the cycle-type readout, $I(c;T) = 1$ while $H(c\mid T) = 0$.

*Proof.* $S_3' = A_3$ and the two cosets are the even and odd permutations. The cycle types $1^3$ and $3$ are even and $1\,2$ is odd, so $T$ is complete, $H(c\mid T) = 0$, and by Lemma 3.2 $I = \log_2 2 = 1$. $\square$

**Proposition 4.4 (the discrepancy is generic).** If $T$ is complete and $[S:N] \ge 2$, then $I(c;T) \ne H(c\mid T)$.

*Proof.* Completeness gives $H(c\mid T) = 0$ and, by Lemma 3.2, $I(c;T) = \log_2[S:N] > 0$. $\square$

The correct reading, stated in Theorem 4.1(2), is that $\mathbb{E}[H(c\mid T)]$ is the **loss** $\log_2[G:G'] - I$.

---

## 5. The sandwich

**Theorem 5.1 (residual type uncertainty).** $H(T\mid c) \le \log_2|N|$.

*Proof sketch.* By Corollary 2.5, $H(c,T) \le \log_2|S|$. By Lemma 3.1, $H(c) = \log_2 k$ and $\log_2|S| = \log_2 k + \log_2|N|$. Hence $H(T\mid c) = H(c,T) - H(c) \le \log_2|N|$. $\square$

**Theorem 5.2 (Sandwich Theorem).**
$$\max\bigl(0,\ H(T) - \log_2|N|\bigr) \ \le\ I(c;T)\ \le\ \min\bigl(H(T),\ \log_2[S:N]\bigr).$$
Equivalently, the *type deficit* $H(T) - I(c;T)$ is at most $\log_2|G'|$.

*Proof sketch.* The lower bound combines Gibbs' inequality with Theorem 4.1(1) and Theorem 5.1. The upper bound holds because $I(c;T) \le H(T)$ always and $I(c;T) \le H(c) = \log_2 k$. $\square$

**Example 5.3 (the lower bound is non-vacuous: $x^4-2$).** Let $D_4$ act on the roots $\alpha i^j$ ($j \in \mathbb{Z}/4$) of $x^4-2$ by the affine maps $j\mapsto \pm j + a$. The eight elements have cycle types

| element | cycle type | count |
|---|---|---|
| identity | $1^4$ | 1 |
| quarter-turns $j\mapsto j\pm1$ | $4$ | 2 |
| half-turn $j\mapsto j+2$; reflections $j\mapsto 1-j,\ 3-j$ | $2^2$ | 3 |
| reflections $j\mapsto -j,\ 2-j$ | $1^2\,2$ | 2 |

so $H(T) = \tfrac52 - \tfrac38\log_2 3 \approx 1.906$. The derived subgroup is the centre $Z(D_4) = \{1, j\mapsto j+2\}$ of order $2$. Theorem 5.2 gives, from the type statistics and $|Z(D_4)|$ alone,
$$I(c;T) \ \ge\ \tfrac32 - \tfrac38\log_2 3 \ \approx\ 0.906\ >\ \tfrac34.$$
The exact value is $I(c;T) = \tfrac94 - \tfrac38\log_2 3 \approx 1.656$, with loss $\tfrac38\log_2 3 - \tfrac14 \approx 0.344$. The loss comes entirely from the type $2^2$: it has probability $\tfrac38$ and is split $1:2$ between the central coset and the coset $\{j\mapsto 1-j,\, j\mapsto 3-j\}$, so the loss is $\tfrac38\,h(\tfrac13)$, where $h$ is the binary entropy function.

---

## 6. Universality

**Theorem 6.1 (Universality).** Let $S \le \Gamma$ be finite with subgroup $N \subseteq S$, and let $e : \Gamma \to \Gamma'$ be a homomorphism that is injective on $S$. Put $S' = e(S)$ and $N' = e(N)$. Let $c$ be a coset readout for $N$ in $S$ and $c'$ a coset readout for $N'$ in $S'$. Let $T$, $T'$ be readouts with $T'(e(g)) = T(g)$ for $g\in S$. Then
$$I_{S'}(c';T') = I_S(c;T).$$
More generally the same conclusion holds under the weaker, label-free hypothesis $T(a) = T(b) \iff T'(e(a)) = T'(e(b))$ for $a,b\in S$, so $T$ and $T'$ may take values in different sets.

*Proof sketch.* By transport (Lemma 2.6), $I_{S'}(c';T') = I_S(c'\circ e;\, T'\circ e)$. Since $e$ is an injective homomorphism on $S$, $e(a)^{-1}e(b) = e(a^{-1}b) \in e(N)$ iff $a^{-1}b\in N$. So $c'\circ e$ and $c$ induce the same partition of $S$, namely its cosets of $N$. By partition invariance (Lemma 2.7), applied in each argument using the symmetry of $I$, the channel equals $I_S(c;T)$. $\square$

**Corollary 6.2 (conjugate realisations).** For $S, N \le S_n$ and any $h\in S_n$, the conjugated data $hSh^{-1}$, $hNh^{-1}$ with any coset readout have the same cycle-type channel as $S, N$.

*Proof.* Apply Theorem 6.1 with $e = $ conjugation by $h$. Cycle type is invariant under conjugation. $\square$

Relabelling the roots of a polynomial conjugates its Galois group inside $S_n$. Different polynomials with isomorphic Galois groups and equivalent permutation actions therefore have identical channels, which is the "universality" observed experimentally across independent fields with the same group.

**Example 6.3 (conjugate $D_4$).** Conjugating the $D_4$ of Example 5.3 by the transposition $(1\,2)$ gives a subgroup $D_4^\ast \ne D_4$ of $S_4$. It is the stabiliser of the pairing $\{\{0,1\},\{2,3\}\}$ instead of $\{\{0,2\},\{1,3\}\}$. By Corollary 6.2 its channel is exactly $\tfrac94 - \tfrac38\log_2 3$.

**Example 6.4 (cross-degree universality for $S_3$).** Let $S_3$ act *regularly* on the six conjugates of a primitive element of the Galois closure of $x^3-2$ (every non-identity element is fixed-point-free). The cycle types are $1^6$ (once), $3^2$ (twice) and $2^3$ (three times). So
$$H(T) = \tfrac23 + \tfrac12\log_2 3,\qquad I(c;T) = 1,$$
the same values as for the cubic realisation $x^3+x+1$, whose types are $1^3, 3, 1\,2$ with the same frequencies $1,2,3$. This is the label-free form of Theorem 6.1: the regular representation is an injective homomorphism, and it induces the same partition of $S_3$ by type.

---

## 7. Batteries

A *battery* is a tuple of readouts $(T_1,\dots,T_r)$ used jointly as $T = (T_1,\dots,T_r)$.

**Theorem 7.1 (Battery Chain Rule).** For readouts $c, T_1, T_2$,
$$I(c;(T_1,T_2)) = I(c;T_1) + I(c;T_2\mid T_1),$$
and $I(c;T_2\mid T_1) \ge 0$.

*Proof sketch.* Apply the chain rule (Lemma 2.8), conditioning on $T_1$, to each of $H(T_1,T_2)$, $H(c,T_1,T_2)$ and $H(c,T_1)$. After subtraction the $H(T_1)$ terms cancel, leaving $\sum_b p_{T_1}(b)\, I_{S_b}(c;T_2)$. Nonnegativity is Gibbs' inequality on each fibre. $\square$

**Theorem 7.2 (monotone and capped).** $I(c;T_1) \le I(c;(T_1,T_2)) \le \log_2[S:N]$.

**Theorem 7.3 (saturation).** If $T_1$ is complete, then $I(c;T_2\mid T_1) = 0$ and $I(c;(T_1,T_2)) = \log_2[S:N]$ for every $T_2$.

*Proof sketch.* Completeness gives $I(c;T_1) = \log_2 k$ (Lemma 3.2). The ceiling of Theorem 7.2, the chain rule and $I(c;T_2\mid T_1)\ge 0$ then force equality everywhere. $\square$

**Theorem 7.4 (super-additivity is not universal).** If $[S:N] \ge 2$ then
$$I(c;(c,c)) \ <\ I(c;c) + I(c;c).$$

*Proof.* $I(c;c) = H(c) = \log_2 k$, while $I(c;(c,c)) \le \log_2 k$. Since $\log_2 k > 0$, $\log_2 k < 2\log_2 k$. $\square$

So the synergy observed in joint channels, where the whole exceeds the sum of the parts, is a property of *specific complementary dials*. By Theorem 7.1 it amounts to the sign of $I(c;T_2\mid T_1) - I(c;T_2)$. It is not a consequence of the law.

**Example 7.5 ($S_4$ saturates).** For $S_4$ (e.g. $x^4+x+1$) with $N = A_4$, the cycle type determines parity, so the battery (cycle type, image of the first root) has $I(c;\text{root}\mid T) = 0$ and $I(c;(T,\text{root})) = 1$ bit exactly.

**Example 7.6 ($D_4$ is completed by a second dial).** For $x^4-2$, $I(c;T) \approx 1.656$ and $I(c;\text{root}) = 1$, while the battery reaches the full $2$ bits: $I(c;\text{root}\mid T) = \tfrac38\log_2 3 - \tfrac14 \approx 0.344$, exactly the loss of the type channel.

---

## 8. Degree six

### 8.1 The group $D_6$ of $x^6-2$

The roots of $x^6-2$ are $\alpha\zeta^j$ with $\zeta = e^{2\pi i/6}$ and $j\in\mathbb{Z}/6$. The Galois group $D_6$ (order $12$) acts by $j\mapsto j + a$ and $j\mapsto a - j$. Its derived subgroup is the rotation subgroup $C_3 = \{j \mapsto j + 2t\}$, and $D_6/C_3 \cong C_2\times C_2$. A coset readout is (parity of the translation part, orientation). The maximal abelian subfield is $\mathbb{Q}(\sqrt{-3},\sqrt 2)$, of conductor $24$, so the coset is read by $p \bmod 24$.

Cycle types:

| elements | cycle type | $\tau_6$ | $\tau_4$ | count |
|---|---|---|---|---|
| identity | $1^6$ | $(6,0,0)$ | $(6,0)$ | 1 |
| $j\mapsto j\pm1$ | $6$ | $(0,0,0)$ | $(0,0)$ | 2 |
| $j\mapsto j\pm2$ | $3^2$ | $(0,0,6)$ | $(0,0)$ | 2 |
| $j\mapsto j+3$ | $2^3$ | $(0,6,0)$ | $(0,6)$ | 1 |
| $j\mapsto a-j$, $a$ odd | $2^3$ | $(0,6,0)$ | $(0,6)$ | 3 |
| $j\mapsto a-j$, $a$ even | $1^2 2^2$ | $(2,4,0)$ | $(2,4)$ | 3 |

**Proposition 8.1 (the quartic record is unfaithful in degree six).** $\tau_4(j\mapsto j+1) = \tau_4(j\mapsto j+2)$ while $\tau_6(j\mapsto j+1) \ne \tau_6(j\mapsto j+2)$.

**Theorem 8.2 ($D_6$ channel).** With $L = \log_2 3$ and the faithful readout $\tau_6$:
$$H(T) = 1 + \tfrac34 L,\qquad H(c) = 2,\qquad H(c,T) = \tfrac53 + \tfrac12 L,$$
$$I(c;T) = \tfrac43 + \tfrac14 L \approx 1.7296,\qquad \text{loss} = \tfrac23 - \tfrac14 L \approx 0.2704 > 0.$$

*Proof sketch.* Direct evaluation from the table. The type distribution is $(1,2,2,4,3)/12$. The joint $(c,T)$ distribution has six atoms with counts $(1,2,2,1,3,3)$: the type $2^3$ splits as $1$ (half-turn, coset "odd rotation") plus $3$ (odd reflections, coset "odd reflection"), and every other type lies in a single coset. Positivity of the loss is equivalent to $\log_2 3 < \tfrac83$, which holds since $\log_2 3 < 2$. $\square$

**Corollary 8.3 (incompleteness).** $I(c;T) \ne \log_2 4$: the type $2^3$ occurs in two different cosets. Indeed the loss equals $\tfrac13\,h(\tfrac14) = \tfrac13(2 - \tfrac34 L)$.

**Theorem 8.4 (cost of the unfaithful record).** With $\tau_4$ in place of $\tau_6$, $H(T) = \tfrac23 + \tfrac34 L$, $H(c,T) = \tfrac53+\tfrac12 L$ and $I(c;\tau_4) = 1 + \tfrac14 L$. Therefore
$$I(c;\tau_6) - I(c;\tau_4) = \tfrac13 \text{ bit exactly.}$$

*Proof sketch.* The record $\tau_4$ merges the types $6$ and $3^2$, each of probability $\tfrac16$, into one atom of probability $\tfrac13$. This lowers $H(T)$ by $\tfrac13\,h(\tfrac12) = \tfrac13$. The joint entropy $H(c,T)$ does not change, because the two merged types already lie in different cosets: $j\mapsto j\pm1$ is in the odd-rotation coset and $j\mapsto j\pm2$ is in $C_3$. So $I = H(c)+H(T)-H(c,T)$ drops by exactly $\tfrac13$. $\square$

The general sandwich instantiates as $\max(0, 1+\tfrac34 L - L) \approx 0.604 \le I \le \min(2.189, 2) = 2$.

### 8.2 $S_3$ acting regularly: the Galois closure of $x^3-2$

**Theorem 8.5.** For $S_3$ acting regularly on six points (the six conjugates of a primitive element of $\mathbb{Q}(\sqrt[3]{2},\omega)$), with $N = C_3$ and the faithful readout $\tau_6$, we have $H(T) = \tfrac23 + \tfrac12\log_2 3$ and $I(c;T) = 1$. Both equal the corresponding values for the cubic realisation $x^3+x+1$.

*Proof sketch.* The types $1^6$, $3^2$ and $2^3$ occur $1,2,3$ times. The first two are the even coset and the last is the odd coset, so the type is complete (Lemma 3.2). $\square$

---

## 9. Algorithms

**Algorithm A (exact type channel of a permutation group).**
*Input:* generators of $G\le S_n$ and a readout $T$ (default: cycle type).
1. Enumerate $G$ by breadth-first closure under the generators.
2. Compute $G'$ as the closure of the set of commutators $\{aba^{-1}b^{-1}\}$.
3. Label cosets: for each unlabelled $g$, give every element of $gG'$ a new label.
4. Tabulate counts of $T(g)$, of $c(g)$ and of $(c(g),T(g))$, and return $I = H(c) + H(T) - H(c,T)$, together with the loss $\log_2[G:G'] - I$ and the sandwich bounds.

*Complexity:* $O(|G|^2 n)$ for the commutators and $O(|G| n)$ for the rest. This is negligible for the transitive groups of degree $\le 6$ considered here.

**Algorithm B (empirical channel from primes).**
*Input:* $f\in\mathbb{Z}[x]$, a residue map $p\mapsto r(p)$ (e.g. $p \bmod m$, or a Legendre symbol), and a bound $X$.
1. For each prime $p\le X$ not dividing $2\operatorname{disc}(f)$, compute the splitting type of $f\bmod p$ by distinct-degree factorisation: iterate $h\leftarrow h^p \bmod f$ and take $\gcd(h - x, f)$ to peel off the product of the degree-$d$ factors, for $d = 1,2,\dots$.
2. Tabulate the empirical joint distribution of $(r(p), \text{type})$ and return its plug-in mutual information.

*Complexity:* $O(n^2 \log p)$ field operations per prime with schoolbook arithmetic. The plug-in estimator has bias of order (number of joint cells)$/(\#\text{primes})$.

---

## 10. Numerical confirmation

Algorithm A reproduces every closed form above exactly. Algorithm B, run on all primes below $60{,}000$ (about $6{,}000$ primes), gives:

| $f$ | $G$ | residue | empirical $I$ | theory |
|---|---|---|---|---|
| $x^3-2$ | $S_3$ | $p\bmod 3$ | $1.0000$ | $1$ |
| $x^4-2$ | $D_4$ | $p\bmod 8$ | $1.6593$ | $1.6556$ |
| $x^6-2$ | $D_6$ | $p\bmod 24$ | $1.7273$ | $1.7296$ |
| $x^6-2$ ($\tau_4$) | $D_6$ | $p \bmod 24$ | $1.3936$ | $1.3962$ |
| $x^5-x-1$ | $S_5$ | $\bigl(\tfrac{2869}{p}\bigr)$ | $1.0000$ | $1$ |

Exact channels of the groups in the programme's law table (cycle-type readout):

| $G$ | $\lvert G\rvert$ | $[G:G']$ | $H(T)$ | lower bound | $I$ | upper bound | loss |
|---|---|---|---|---|---|---|---|
| $C_4$ | 4 | 4 | 1.5000 | 1.5000 | 1.5000 | 1.5000 | 0.5000 |
| $V_4$ | 4 | 4 | 0.8113 | 0.8113 | 0.8113 | 0.8113 | 1.1887 |
| $S_3$ | 6 | 2 | 1.4591 | 0 | 1 | 1 | 0 |
| $D_4$ | 8 | 4 | 1.9056 | 0.9056 | 1.6556 | 1.9056 | 0.3444 |
| $A_4$ | 12 | 3 | 1.1887 | 0 | 0.9183 | 1.1887 | 0.6667 |
| $S_4$ | 24 | 2 | 2.0944 | 0 | 1 | 1 | 0 |
| $D_5$ | 10 | 2 | 1.3610 | 0 | 1 | 1 | 0 |
| $F_{20}$ | 20 | 4 | 1.6805 | 0 | 1.5 | 1.6805 | 0.5 |
| $A_5$ | 60 | 1 | 1.6555 | 0 | 0 | 0 | 0 |
| $S_5$ | 120 | 2 | 2.5573 | 0 | 1 | 1 | 0 |
| $D_6$ | 12 | 4 | 2.1887 | 0.6038 | 1.7296 | 2 | 0.2704 |
| $S_3$ (regular) | 6 | 2 | 1.4591 | 0 | 1 | 1 | 0 |

The abelian rows ($C_4$, $V_4$) show $I = H(T)$ with the sandwich collapsing to a point. The perfect row ($A_5$) shows the sealed endpoint.

---

## 11. Discussion

**The commutative shadow is the only leak.** Theorem 4.1 and Theorem 5.2 together say that the splitting type's information about the residue class is bounded above by the abelianization and that the unexplained part of the type is bounded by $\log_2|G'|$. For a designer of protocols that factor polynomials modulo secret primes, $\log_2[G:G']$ is a hard ceiling on the leakage of $p \bmod m$ through factorization patterns, and it is reached exactly when the type is complete. Perfect Galois groups ($A_5$, and more generally any perfect group) leak nothing at all about any residue class.

**What the law does not say.** The law is an identity plus inequalities. It does not by itself predict synergy in batteries, and Theorem 7.4 shows that no such prediction can hold unconditionally. The sign of $I(c;T_2\mid T_1) - I(c;T_2)$ depends on how conjugacy classes and dials interact with the cosets.

**Faithfulness is a real experimental hazard.** Theorem 8.4 shows that an encoding that is faithful in low degree silently loses information in degree six, and it quantifies the loss exactly.

---

## 12. Open problems and future directions

1. **Sandwich-equality classification.** *Conjecture:* $I = H(T) - \log_2|G'|$ iff $T$ is injective on every coset of $G'$. For class-function readouts this means every coset of $G'$ meets each conjugacy class in at most one element. For the cycle-type readout, equality should hold only for abelian groups. Since Theorem 5.1 comes from data processing applied to the identity readout, equality should be exactly the absence of collisions inside fibres.
2. **Dihedral ladder for $x^{2m}-2$.** *Conjecture:* with the faithful cycle-type readout the $D_{2m}$ channel has a closed form in $m$, the loss is strictly positive for $m\ge 3$, and the loss of the unfaithful quartic record tends to a limit. The cosets of the derived subgroup ($C_m$ for $m$ odd, $C_{m/2}$ for $m$ even) are unions of rotation and reflection strata with explicitly known cycle types. $D_6$ (Theorem 8.2) is the first rung.
3. **Conditional battery capacity.** *Conjecture:* for class-function dials, $I(c;T_2\mid T_1) \le \log_2[G:G'] - I(c;T_1)$, with equality iff $(T_1,T_2)$ jointly determine the coset. (The inequality itself follows from Theorems 7.1–7.2. The content is the equality characterisation and the classification of positive synergy through double-coset structure.)
4. Beyond this paper, the programme lists further open targets: a rigorous converse for its "barrier-4" phenomenon, production-scale subexponential experiments (moduli $N \ge 2^{64}$), identification of the conductor for the $D_5$ fields, and nonabelian degree-6 groups beyond $D_6$ and regular $S_3$.

---

## Appendix: the arithmetic dictionary in one paragraph

Let $K$ be the splitting field of $f$ and $G = \operatorname{Gal}(K/\mathbb{Q})$, acting on the roots. For an unramified prime $p$ and a prime $\mathfrak{P}\mid p$ of $K$, the Frobenius $\operatorname{Frob}_{\mathfrak P}$ is the unique element acting as $x\mapsto x^p$ on the residue field. Its orbits on the roots correspond to the irreducible factors of $f \bmod p$, with orbit lengths equal to factor degrees (Dedekind–Frobenius). Changing $\mathfrak{P}$ conjugates it. Chebotarev's density theorem says that the density of primes whose Frobenius class is $C$ equals $|C|/|G|$. The maximal abelian subfield $K^{G'}$ is contained in a cyclotomic field $\mathbb{Q}(\zeta_m)$ (Kronecker–Weber), and the restriction of $\operatorname{Frob}_p$ to $K^{G'}$ is the image of $p \bmod m$ under $(\mathbb{Z}/m)^\times \twoheadrightarrow \operatorname{Gal}(K^{G'}/\mathbb{Q}) = G/G'$. Hence the pair (residue of $p$ mod $m$, splitting type) is distributed, in the limit, as $(gG', \text{cycle type of } g)$ with $g$ uniform on $G$.
