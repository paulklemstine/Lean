# The Abelianization Law at Degree Five: Splitting-Type Channels of the Frobenius Group $F_{20} = \mathrm{AGL}(1,5)$, and the Affine Ladder

**Aristotle**

---

## Abstract

Let $K/\mathbb{Q}$ be a Galois number field with group $G$, and let $G^{\mathrm{ab}} = G/[G,G]$ be
its abelianization, a quotient realised arithmetically by a residue condition $p \bmod m^{*}$ on
unramified rational primes. We study the *splitting-type channel*: the amount of information that
the factorisation shape $T(p)$ of a defining polynomial modulo $p$ transmits about the
abelianization class of $p$, under the Chebotarev measure. Our central structural result is the
**merged-coset law**: whenever the abelianization read-out is uniform inside every fibre of the
type read-out,
$$H(D) - I(T;D) = \sum_t \Pr[T = t]\,\log_2 k(t),$$
where $k(t)$ is the number of abelianization classes compatible with the type value $t$. We prove
the converse — the channel attains the full dial, $I(T;D) = H(D)$, precisely when no type value
merges two classes — so that channel loss is *equivalent* to the failure of the splitting type to
separate abelianization classes.

We then evaluate the law on the first object of the program whose abelianization is the cyclic
group $C_4$: the splitting field of $x^5 - 2$, with Galois group the Frobenius group
$F_{20} = \mathrm{AGL}(1,5)$ of order $20$. We obtain exactly
$$H(T) = \tfrac{11}{10} + \tfrac14 \log_2 5 = 1.68048\ldots, \qquad
H(D) = 2, \qquad I(p \bmod 5\,;\,T) = \tfrac32,$$
the loss $1/2$ arising from the single merging type $[1,4]$, which fuses the two order-four
classes. At the semiprime layer, with $N = pq$ and the observer seeing the pair of splitting
types, the pair law is exactly $5/4$ — verbatim the cyclotomic $C_4$ pair channel of
$\mathbb{Q}(\zeta_5)$ — the which-factor wall is zero, and the $[1,2,2]$-fork realises the
order-four split-count channel $\tfrac{19}{8} - \tfrac{21}{16}\log_2 3$ on a non-abelian field.
We record a methodological result: relabelling the two order-four classes against the $C_4$
valuation is *invisible* to every single-prime statistic but moves the pair law from $5/4$ to
$9/8$; the pair channel is therefore the discriminating test of coset bookkeeping exactly where
type merging conceals the error.

Finally we climb the affine ladder. For $\mathrm{AGL}(1,7)$, of order $42$ with abelianization
$C_6$, the law gives $H(T) = \tfrac{4}{21} + \tfrac67\log_2 3 + \tfrac16\log_2 7 = 2.0169\ldots$ and
$I(p \bmod 7\,;\,T) = \tfrac13 + \log_2 3 = 1.9183\ldots$, with loss exactly $2/3$ produced by two
merging types. We prove that the loss of $\mathrm{AGL}(1,q)$ equals the totient sum
$\sum_{d \mid q-1, d>1} (\varphi(d)/(q-1))\log_2 \varphi(d)$, reproducing $1/2$ at $q=5$, $2/3$ at
$q=7$, and predicting $8/5$ at $q=11$. The septic channel transmits strictly more than the quintic
one yet wastes a strictly larger fraction of its dial.

**Keywords:** Chebotarev density, splitting type, Frobenius group, $\mathrm{AGL}(1,q)$,
abelianization, mutual information, cyclotomic field, semiprime channel.

---

## 1. Introduction

### 1.1 The question

Fix a monic irreducible $f \in \mathbb{Z}[x]$ of degree $n$ and a rational prime $p$ not dividing
$\operatorname{disc}(f)$. Reducing $f$ modulo $p$ and factoring yields a partition of $n$: the
multiset of degrees of the irreducible factors. This is the **splitting type** $T(p)$. By
Dedekind's theorem it coincides with the cycle type of the Frobenius conjugacy class at $p$,
acting on the $n$ roots inside the splitting field $K$ of $f$.

A second, much simpler observation about $p$ is available for free: its residue class modulo a
fixed integer. If $G = \mathrm{Gal}(K/\mathbb{Q})$, the Kronecker–Weber theorem tells us that the
maximal abelian subextension of $K$ is cyclotomic, so the abelianization $G^{\mathrm{ab}}$ is
realised as $\mathrm{Gal}(\mathbb{Q}(\zeta_{m^{*}})/\mathbb{Q})$ for a suitable conductor $m^{*}$,
and the abelianization class of the Frobenius at $p$ is precisely $p \bmod m^{*}$. We call this the
**dial**: the part of the arithmetic of $K$ that a congruence condition can see.

The question of this paper is quantitative:

> Under the Chebotarev measure, how many bits does the splitting type $T$ transmit about the dial
> $D$?

Formally, treat the Frobenius element as a uniformly distributed random variable on $G$; then $T$
and $D$ are two deterministic read-outs of it, and we want the mutual information
$$I(T;D) = H(D) - H(D \mid T) = H(T) - H(T \mid D).$$

### 1.2 The answer, and why it is clean

One would expect the answer to depend on the entropies $H(T)$ and $H(T\mid D)$ individually, and
these are typically transcendental — for $x^5 - 2$ they are $\tfrac{11}{10} + \tfrac14\log_2 5$ and
$\tfrac14 \log_2 5 - \tfrac25$ respectively. But the transcendental parts cancel identically, and
the transmitted information is a rational number. The cancellation is not a coincidence of the
particular group; it is forced by a general law whose only input is the *merge pattern* of the
channel — the list of how many dial classes each type value fails to separate.

This paper (i) isolates that law and proves its converse, (ii) evaluates it exactly on the
Frobenius group $F_{20} = \mathrm{AGL}(1,5)$ at both the single-prime and semiprime layers, and
(iii) extends it in closed form along the affine ladder $\mathrm{AGL}(1,q)$.

### 1.3 Summary of results

Write $S$ for a finite "Chebotarev box" carrying the uniform measure, $T : S \to \mathcal{T}$ for
the type read-out, $D : S \to \mathcal{D}$ for the dial.

1. **Merged-coset law (Theorem 2.4).** If inside every fibre of $T$ all occurring dial classes are
   equinumerous, then $H(D) - I(T;D) = \sum_t \Pr[T=t]\log_2 k(t)$, $k(t)$ being the number of dial
   classes met by the fibre of $t$.
2. **Pinning criterion (Theorem 2.6).** Under the same hypothesis, $I(T;D) = H(D)$ if and only if
   $k(t) = 1$ for every $t$.
3. **Degree five (Theorems 3.4–3.8).** For $x^5 - 2$: $H(T) = \tfrac{11}{10}+\tfrac14\log_2 5$,
   $H(D) = 2$, loss $= \tfrac12$, $I = \tfrac32$, $H(T \mid D) = \tfrac14\log_2 5 - \tfrac25$,
   $H(D \mid T) = \tfrac12$; the channel is lossy in both directions.
4. **Semiprime layer (Theorems 4.2–4.5).** Pair law $I(\{T(p),T(q)\}\,;\,N \bmod 5) = \tfrac54$,
   equal to the cyclotomic $C_4$ pair channel; which-factor wall $0$; $[1,2,2]$-fork
   $= \tfrac{19}{8} - \tfrac{21}{16}\log_2 3$.
5. **The coset-swap phenomenon (Theorem 4.6).** A relabelling of the two order-four classes leaves
   all single-prime quantities invariant but changes the pair law to $9/8$.
6. **Degree seven and the ladder (Theorems 5.2–5.6).** For $\mathrm{AGL}(1,7)$:
   $H(T) = \tfrac{4}{21}+\tfrac67\log_2 3 + \tfrac16\log_2 7$, $H(D) = \log_2 6$, loss $\tfrac23$,
   $I = \tfrac13 + \log_2 3$. The loss of $\mathrm{AGL}(1,q)$ equals
   $\sum_{d\mid q-1,\,d>1}(\varphi(d)/(q-1))\log_2\varphi(d)$, verified at $q = 5, 7$ and predicting
   $8/5$ at $q=11$.
7. **Control (Theorems 6.1–6.3).** The abelian degree-five field $\mathbb{Q}(\zeta_{11})^{+}$ with
   group $C_5$ is fully pinned, $I = H(T) = \log_2 5 - \tfrac85 = 0.7219\ldots$, but its loss is the
   whole $13/5$ remaining bits of its $\log_2 10$ dial; the non-abelian $F_{20}$ transmits strictly
   more.

---

## 2. The general theory

### 2.1 Setting and notation

Let $S$ be a nonempty finite set equipped with the uniform probability measure
$\Pr[x] = 1/|S|$. For a read-out $g : S \to B$ into a set with decidable equality, write
$g^{-1}(b) = \{x \in S : g(x) = b\}$ and define the (base-two) entropy as
$$H(g) \;=\; \log_2 |S| \;-\; \frac{1}{|S|}\sum_{x \in S} \log_2 \bigl|g^{-1}(g(x))\bigr|,$$
which is the familiar $-\sum_b \Pr[g = b] \log_2 \Pr[g = b]$, written in a form that makes the
fibre sizes explicit. For two read-outs $T, D$ the conditional entropy is the fibre average
$$H(D \mid T) \;=\; \sum_{t \in T(S)} \Pr[T = t]\; H\bigl(D|_{T^{-1}(t)}\bigr),$$
the inner entropy being taken with respect to the uniform measure on the fibre, and
$I(T;D) = H(D) - H(D\mid T) = H(T) - H(T \mid D)$ is symmetric.

**Definition 2.1 (Chebotarev box).** A *Chebotarev box* for a Galois number field $K/\mathbb{Q}$ is
the group $G = \mathrm{Gal}(K/\mathbb{Q})$ carrying the uniform measure, together with the read-outs
$T$ (cycle type of the element on the chosen root set) and $D$ (image in $G^{\mathrm{ab}}$). By the
Chebotarev density theorem, the joint law of $(T(p), D(p))$ over unramified primes ordered by norm
converges to the law of $(T,D)$ on the box, so every statement proved about the box is a statement
about the natural density of primes.

**Definition 2.2 (Merge count).** For $t \in T(S)$, the *merge count* $k(t)$ is the number of
distinct values of $D$ realised on the fibre $T^{-1}(t)$. A type value with $k(t) \ge 2$ is a
*merging type*.

**Definition 2.3 (Fibrewise dial uniformity).** The pair $(T,D)$ is *fibrewise dial uniform* with
profile $c : \mathcal{T} \to \mathbb{N}$ if for every $t \in T(S)$ and every $a \in T^{-1}(t)$,
$$\bigl|\{x \in T^{-1}(t) : D(x) = D(a)\}\bigr| = c(t).$$
Equivalently: inside each type fibre, all occurring dial classes have the same size. Then
$|T^{-1}(t)| = k(t)\,c(t)$.

This hypothesis is automatic for Galois boxes in which $T$ refines nothing finer than a union of
whole $[G,G]$-cosets: each fibre of $T$ is a union of $k(t)$ cosets of a fixed subgroup, hence
meets the dial classes it touches equally. All boxes in this paper satisfy it, and we verify it
explicitly in each case.

### 2.2 The merged-coset law

**Lemma 2.3a (Uniform-fibre entropy).** If every fibre of $g : S \to B$ has the same cardinality
$c$, then $H(g) = \log_2 |S| - \log_2 c$.

*Proof.* Every summand $\log_2|g^{-1}(g(x))|$ equals $\log_2 c$, so the average is $\log_2 c$. $\square$

**Lemma 2.3b (Conditional entropy under fibrewise uniformity).** If $(T,D)$ is fibrewise dial
uniform with profile $c$, then
$$H(D \mid T) \;=\; \sum_{t \in T(S)} \Pr[T = t]\,\bigl(\log_2 |T^{-1}(t)| - \log_2 c(t)\bigr).$$

*Proof.* Apply Lemma 2.3a inside each fibre $T^{-1}(t)$, where the restricted read-out $D$ has all
fibres of size $c(t)$, and average with weights $\Pr[T=t] = |T^{-1}(t)|/|S|$. $\square$

**Theorem 2.4 (Merged-coset law).** Let $S$ be a nonempty finite box and $(T,D)$ fibrewise dial
uniform with profile $c$. Then
$$H(D) - I(T;D) \;=\; \sum_{t \in T(S)} \Pr[T=t]\,\bigl(\log_2|T^{-1}(t)| - \log_2 c(t)\bigr)
\;=\; \sum_{t \in T(S)} \Pr[T=t]\,\log_2 k(t).$$

*Proof.* By symmetry of mutual information, $H(D) - I(T;D) = H(D\mid T)$, and Lemma 2.3b evaluates
the right-hand side; the second equality is $|T^{-1}(t)| = k(t)c(t)$. $\square$

**Interpretation.** The loss is the average, over observations, of the log-number of dial settings
the observation cannot separate. Neither the group law, nor the conjugacy structure, nor the field
enters: the loss is a functional of the unordered list of pairs $(\Pr[T=t], k(t))$ alone. This is
the *merge-pattern invariance* of the single-prime channel, and it is the reason the coset swap of
§4.4 is invisible.

**Corollary 2.5 (Non-negativity; no type beats its dial).** Since $1 \le c(t) \le |T^{-1}(t)|$ —
the lower bound because a dial class inside a nonempty fibre is nonempty, the upper because a dial
class inside the fibre is contained in the fibre — each summand is non-negative, hence
$I(T;D) \le H(D)$ with the loss an explicit non-negative sum.

**Theorem 2.6 (Pinning criterion; converse of the law).** Under fibrewise dial uniformity,
$$I(T;D) = H(D) \iff k(t) = 1 \text{ for every } t \in T(S),$$
i.e. if and only if no type value is compatible with two distinct dial classes; equivalently, if
and only if $D$ factors through $T$.

*Proof.* Each summand $\Pr[T=t]\log_2 k(t)$ is non-negative and vanishes exactly when $k(t) = 1$
(as $\Pr[T=t] > 0$ for $t \in T(S)$). A sum of non-negative terms vanishes iff all terms vanish.
$\square$

**Corollary 2.7 (One-merged-type formula).** If a single type value $t_0$ has $k(t_0) = k \ge 2$
and all others have $k(t) = 1$, then the loss is exactly $\Pr[T = t_0]\log_2 k$ and
$I(T;D) = H(D) - \Pr[T=t_0]\log_2 k$.

This is the shape in which the law is read off in practice: identify the merging types, count what
they merge, done.

---

## 3. Degree five: the Frobenius field $F_{20} = \mathrm{AGL}(1,5)$

### 3.1 The field and its group

Let $f(x) = x^5 - 2$, irreducible over $\mathbb{Q}$ by Eisenstein at $2$, and let
$K = \mathbb{Q}(\sqrt[5]{2}, \zeta_5)$ be its splitting field, of degree $20$. Labelling the roots
$\alpha_j = \sqrt[5]{2}\,\zeta_5^{\,j}$ by $j \in \mathbb{F}_5$, every element of
$G = \mathrm{Gal}(K/\mathbb{Q})$ acts as $j \mapsto aj + b$ with $a \in \mathbb{F}_5^{\times}$,
$b \in \mathbb{F}_5$. Hence
$$G \;\cong\; \mathrm{AGL}(1,5) \;=\; F_{20},$$
the Frobenius group of order $20$, sharply $2$-transitive on the five roots and non-abelian. Its
commutator subgroup is the translation subgroup $\{j \mapsto j+b\} \cong C_5$, so
$$G^{\mathrm{ab}} \;\cong\; \mathbb{F}_5^{\times} \;\cong\; C_4 \;=\; \mathrm{Gal}(\mathbb{Q}(\zeta_5)/\mathbb{Q}),$$
and the abelianization class of the Frobenius at an unramified prime $p$ is the residue
$p \bmod 5$. This is the program's first object with $C_4$ abelianization.

**The box.** We model $G$ as $S = \{0,1,\dots,19\}$ via
$$x = 5e + b \;\longleftrightarrow\; (j \mapsto 2^{e} j + b), \qquad e \in \{0,1,2,3\},\ b \in \mathbb{F}_5,$$
using that $2$ generates $\mathbb{F}_5^{\times}$. The **dial** is $D(x) = \lfloor x/5 \rfloor = e$,
the $C_4$-valuation (discrete logarithm base $2$) of the multiplier; it is exactly $p \bmod 5$
transported to $\mathbb{Z}/4$.

### 3.2 The type dictionary

**Lemma 3.1 (Cycle types of affine maps on $\mathbb{F}_5$).** The cycle type of $j \mapsto aj+b$ on
$\mathbb{F}_5$ is:
* $[1,1,1,1,1]$ if $a=1$, $b=0$;
* $[5]$ if $a = 1$, $b \ne 0$;
* $[1,d,d,\dots]$ ($(5-1)/d$ cycles of length $d$, one fixed point) if $a \ne 1$, where
  $d = \operatorname{ord}(a)$.

*Proof.* For $a = 1$ the map is a translation, trivial or a $5$-cycle. For $a \ne 1$ the map has the
unique fixed point $j_0 = b/(1-a)$, and conjugating by $j \mapsto j - j_0$ turns the map into
$j \mapsto aj$, whose orbits on $\mathbb{F}_5^{\times}$ are the cosets of $\langle a \rangle$, each
of size $d$. $\square$

Writing the types as codes, the dictionary for $q = 5$ is:

| $e$ | $a = 2^e$ | $\operatorname{ord}(a)$ | type | fibre size |
|---|---|---|---|---|
| $0$ | $1$ | $1$ | $[1,1,1,1,1]$ ($b=0$) / $[5]$ ($b\ne0$) | $1$ / $4$ |
| $1$ | $2$ | $4$ | $[1,4]$ | $5$ |
| $2$ | $4$ | $2$ | $[1,2,2]$ | $5$ |
| $3$ | $3$ | $4$ | $[1,4]$ | $5$ |

**Lemma 3.2 (Chebotarev densities).** The type fibres have sizes $1, 4, 10, 5$ out of $20$ for
$[1,1,1,1,1], [5], [1,4], [1,2,2]$ respectively; the dial is uniform, each class carrying $5$
elements.

**Lemma 3.3 (Merge pattern at degree five).** $(T,D)$ is fibrewise dial uniform with profile
$c([1^5]) = 1$, $c([5]) = 4$, $c([1,4]) = 5$, $c([1,2,2]) = 5$; hence the merge counts are
$$k([1^5]) = k([5]) = k([1,2,2]) = 1, \qquad k([1,4]) = 2.$$
The unique merging type is $[1,4]$, which fuses the two order-four classes $e \in \{1,3\}$.

*Proof.* The fibres of $[1^5]$ and $[5]$ lie inside the single class $e=0$ and have sizes $1$ and
$4$; the fibre of $[1,2,2]$ is the whole class $e=2$; the fibre of $[1,4]$ is the union of the two
classes $e=1$ and $e=3$, meeting each in $5$ elements. Dividing gives $k = |T^{-1}|/c$. $\square$

**Remark (practical type detection).** In computation one determines $T(p)$ for $x^5 - 2$ without
factoring, by counting roots of $x^5-2$ in $\mathbb{F}_p$ and in $\mathbb{F}_{p^2}$. The signature
$(\#\text{roots in } \mathbb{F}_p, \#\text{roots in }\mathbb{F}_{p^2})$ is
$$(5,5) \mapsto [1^5], \qquad (1,1)\mapsto[1,4], \qquad (1,5)\mapsto[1,2,2], \qquad (0,0)\mapsto[5].$$
The value $(1,5)$ — not $(1,3)$, the analogue one might carry over from quartic dictionaries — is
the correct signature for $[1,2,2]$, because the roots of *both* quadratic factors live in
$\mathbb{F}_{p^2}\setminus\mathbb{F}_p$, contributing $4$ further roots on top of the rational one.

### 3.3 The prime-level channel

**Theorem 3.4 (Quintic splitting entropy).**
$$H(T) \;=\; \frac{11}{10} + \frac{1}{4}\log_2 5 \;=\; 1.680482\ldots \text{ bits},$$
with the rigorous bracket $1.6804 < H(T) < 1.6806$.

*Proof.* Substitute the densities $\left(\tfrac1{20}, \tfrac4{20}, \tfrac{10}{20}, \tfrac{5}{20}\right)$
into $H = -\sum p_i \log_2 p_i$:
$$H(T) = \tfrac1{20}\log_2 20 + \tfrac15\log_2 5 + \tfrac12\log_2 2 + \tfrac14 \log_2 4 .$$
Using $\log_2 20 = 2 + \log_2 5$ and collecting terms gives $\tfrac{11}{10} + \tfrac14\log_2 5$. The
bracket follows from the sharp rational bounds $339/146 < \log_2 5 < 137/59$, i.e.
$2^{339} < 5^{146}$ and $5^{59} < 2^{137}$. $\square$

**Theorem 3.5 (The dial).** $H(D) = \log_2 4 = 2$ bits exactly.

*Proof.* Lemma 2.3a with all four fibres of size $5$ out of $20$. $\square$

**Theorem 3.6 (Merged-coset sum).** $\sum_t \Pr[T=t]\log_2 k(t) = \tfrac12 \cdot \log_2 2 = \tfrac12.$

*Proof.* Lemma 3.3: the only merging type is $[1,4]$, with density $1/2$ and $k = 2$. $\square$

**Theorem 3.7 (The abelianization law at degree five).**
$$I(p \bmod 5\,;\,T) \;=\; H(D) - \tfrac12 \;=\; \frac{3}{2} \text{ bits exactly.}$$

*Proof.* Theorem 2.4 with Theorems 3.5 and 3.6. $\square$

Two corollaries record the two-sided lossiness that distinguishes $F_{20}$ from every abelian
object.

**Theorem 3.8 (Residuals).**
$$H(T \mid p \bmod 5) \;=\; \tfrac14 \log_2 5 - \tfrac25 \;=\; 0.18048\ldots, \qquad
H(p \bmod 5 \mid T) \;=\; \tfrac12 .$$
In particular $I < H(T)$ (the type is *not pinned* by the residue, since $\log_2 5 > 8/5$) and
$I < H(D)$ (the type does not determine the residue either).

*Proof.* Subtract: $H(T\mid D) = H(T) - I = \tfrac{11}{10}+\tfrac14\log_2 5 - \tfrac32$, and
$H(D \mid T) = H(D) - I = 2 - \tfrac32$. $\square$

The residual $H(T \mid D)$ has a transparent meaning: given $p \equiv 1 \pmod 5$, the type is
$[1^5]$ with conditional probability $1/5$ and $[5]$ with probability $4/5$ — whether $2$ is a
fifth power mod $p$ is invisible to the residue — and the binary entropy of $(1/5,4/5)$ is
$\log_2 5 - \tfrac85$, weighted by the class probability $1/4$.

**Theorem 3.9 (Law-table row).** For $x^5 - 2$:
$$\bigl(H(T),\;H(D),\;I,\;\text{loss}\bigr) \;=\;
\Bigl(\tfrac{11}{10}+\tfrac14\log_2 5,\;2,\;\tfrac32,\;\tfrac12\Bigr).$$

**Empirical check.** Evaluating $T(p)$ for the primes below $2.7\times 10^{5}$ (about $23{,}000$
primes) gives type frequencies within $2\%$ of $1:4:10:5$ and
$$I_{\text{measured}} = 1.4989 \quad \text{versus} \quad I_{\text{predicted}} = 1.5000,$$
a margin of $-0.0011$ attributable to finite-range Chebotarev fluctuation. Within-coset flatness of
the type distribution is confirmed at $z = +0.00$.

---

## 4. The semiprime layer

### 4.1 Setting

Let $N = pq$ with $p, q$ distinct unramified primes, each with independent Chebotarev-distributed
Frobenius. The box is $S \times S$, of size $400$. Because residues are multiplicative,
$$D_{\text{prod}}(x,y) \;=\; D(x) + D(y) \bmod 4$$
is the $C_4$-class of $N \bmod 5$. The observer's data is the pair of splitting types, either
ordered, $\Pi(x,y) = (T(x), T(y))$, or unordered,
$\Pi^{u}(x,y) = \{T(x),T(y)\}$.

The product dial is uniform: each of its four classes contains $100$ of the $400$ box elements
(convolution of a uniform variable on $C_4$ with anything is uniform).

### 4.2 The pair law

**Theorem 4.1 (Joint type entropy).** $H(\Pi) = 2H(T) = \tfrac{11}{5} + \tfrac12\log_2 5 = 3.36096\ldots$

**Theorem 4.2 (The quintic pair law).**
$$I\bigl(\Pi \,;\, N \bmod 5\bigr) \;=\; \frac{5}{4} \text{ bits exactly.}$$

*Sketch.* The conditional distribution of $\Pi$ given each value of $D_{\text{prod}}$ is computed
by enumerating the $400$ cells of the box; the four conditional laws are permutations of one
another, and the resulting $H(\Pi \mid D_{\text{prod}})$ differs from $H(\Pi)$ by exactly $5/4$, the
$\log_2 5$ terms cancelling as at the prime level. Structurally: the pair channel is the
convolution channel of two independent copies of the single-prime channel, and the merge blocks of
$F_{20}$ — the partition $\{0\},\{1,3\},\{2\}$ of $C_4$ induced by the type — coincide with the
merge blocks of the cyclotomic order-type read-out of $\mathbb{Q}(\zeta_5)$, forcing equality of
the two pair channels. $\square$

**Theorem 4.3 (Bridge to the cyclotomic pair channel).** The value $5/4$ is *verbatim* the
cyclotomic $C_4$ pair channel of $\mathbb{Q}(\zeta_5)$: the non-abelian degree-five object reads
its own abelianization's semiprime channel exactly. Of the $2$ available bits, the semiprime
observer recovers $1.25$ — the largest fraction achieved by any merged-type field in the program.

**Theorem 4.4 (Zero which-factor wall).**
$$I\bigl(\Pi^{u}\,;\,N \bmod 5\bigr) \;=\; I\bigl(\Pi\,;\,N\bmod 5\bigr) \;=\; \frac54 .$$
Telling the observer which prime factor carried which splitting type is worth exactly nothing
about $N \bmod 5$.

*Sketch.* $N \bmod 5$ is a symmetric function of the two Frobenius classes, so the ordering
information is independent of the target given the unordered data; formally, the conditional
entropies of the ordered and unordered read-outs differ by the same symmetrisation term
$H(\Pi) - H(\Pi^u)$ both with and without conditioning. $\square$

**Theorem 4.5 (The $[1,2,2]$-fork).** Let $\Phi(x,y) \in \{0,1,2\}$ count how many of the two
factors have splitting type $[1,2,2]$ — equivalently, how many satisfy $p \equiv 4 \pmod 5$. Then
$$H(\Phi) = \tfrac{29}{8} - \tfrac32 \log_2 3, \qquad
I\bigl(\Phi\,;\,N \bmod 5\bigr) = \frac{19}{8} - \frac{21}{16}\log_2 3 = 0.294737\ldots$$
This is exactly the order-four split-count channel of the cyclotomic theory, here realised as a
*pinned fork on a non-abelian field*: previously order-four split counts had appeared only on the
abelian Klein group $V_4$ and on a joint-AND $D_4$ fork.

**Empirical check (semiprime).** A Monte-Carlo run over $400{,}000$ simulated semiprimes gives
$$I(\Pi;N\bmod 5) = 1.2462 \ (\text{vs. } 1.2500), \qquad
I(\Phi;N\bmod 5) = 0.2915 \ (\text{vs. } 0.2947),$$
with which-factor walls measuring $0.0000$, a flat coprime baseline, and agreement with a
thickened (multi-prime) variant to $0.0001$.

### 4.3 Merge-pattern invariance

The following makes precise the sense in which the single-prime channel is blind to the group law.

**Theorem 4.6a (Merge-pattern invariance).** Let $(T,D)$ and $(T',D)$ be two fibrewise dial-uniform
read-outs on the same box with the same dial, and suppose there is a bijection $\sigma$ between
their type values with $\Pr[T=t] = \Pr[T'=\sigma(t)]$ and $k(t) = k'(\sigma(t))$ for all $t$. Then
$$I(T;D) = I(T';D).$$

*Proof.* Immediate from Theorem 2.4: both losses are the same sum over the matched list of pairs
$(\Pr, k)$, and $H(D)$ is common. $\square$

### 4.4 The coset swap: an instructive failure, made precise

Consider the mislabelled dictionary $T^{\mathrm{sw}}$ obtained by assigning the type $[1,2,2]$ to
the class $e = 3$ instead of $e = 2$ — i.e. by swapping the coset labels of the multiplier-$3$ and
multiplier-$4$ families relative to the $C_4$ valuation. This is exactly the bookkeeping error made
in the first run of the experiment.

**Theorem 4.6 (Invisible at the prime level, fatal at the pair level).**
$$H(T^{\mathrm{sw}}) = H(T), \qquad I(T^{\mathrm{sw}};D) = \frac32 = I(T;D),$$
so *no* single-prime statistic distinguishes the two labellings. Yet
$$I\bigl(\Pi^{\mathrm{sw}}\,;\,N \bmod 5\bigr) \;=\; \frac98 \;\ne\; \frac54 \;=\;
I\bigl(\Pi\,;\,N\bmod 5\bigr).$$

*Proof.* The first two equalities are instances of Theorem 4.6a: the swapped dictionary has the
identical list of $(\Pr, k)$ pairs — densities $1,4,10,5$ and a single merging type of merge count
$2$ — so the law returns the same loss $1/2$. For the pair level, the conditional entropy of the
swapped pair read-out given $N \bmod 5$ computes to $\tfrac{43}{40} + \tfrac12\log_2 5$ instead of
$\tfrac{19}{20} + \tfrac12 \log_2 5$, a difference of exactly $1/8$. $\square$

**Methodological conclusion.** The merge structure that the single-prime channel sees is a
*partition* of the abelianization group; the pair channel sees that partition *as a subset
structure of the group*, because the product dial is the group convolution of the two draws. The
swapped labelling moves the merged block from $\{1,3\}$ (a coset of the order-two subgroup of
$C_4$) to $\{1,2\}$ (not a subgroup coset), and only the convolution notices. Hence:

> **The pair law is the discriminating test of coset bookkeeping precisely where type merging
> hides the error.**

In the actual experiment this was not a theoretical remark: the $400{,}000$-sample Monte Carlo sat
at $1.2462$, contradicting the incorrect enumeration $1.1250$ and confirming the corrected
$1.2500$.

---

## 5. The affine ladder: $\mathrm{AGL}(1,q)$

### 5.1 Degree seven

Let $q = 7$ and consider a generic radical septic $x^7 - a$ whose splitting field has full Galois
group
$$\mathrm{AGL}(1,7) = \{\,j \mapsto \alpha j + \beta : \alpha \in \mathbb{F}_7^{\times},\ \beta \in \mathbb{F}_7\,\},$$
of order $42$, with commutator subgroup the translations and abelianization
$$\mathrm{AGL}(1,7)^{\mathrm{ab}} \cong \mathbb{F}_7^{\times} \cong C_6 = \mathrm{Gal}(\mathbb{Q}(\zeta_7)/\mathbb{Q}),$$
read off by $p \bmod 7$. Model the box as $\{0,\dots,41\}$ via $x = 7e + \beta$ with
$\alpha = 3^{e}$ ($3$ generates $\mathbb{F}_7^\times$), and set $D(x) = \lfloor x/7\rfloor$.

**Lemma 5.1 (Septic dictionary).** By Lemma 3.1 with $q = 7$:

| condition | $d = \operatorname{ord}(\alpha)$ | type | fibre size |
|---|---|---|---|
| $\alpha=1,\beta=0$ | $1$ | $[1,1,1,1,1,1,1]$ | $1$ |
| $\alpha=1,\beta\ne0$ | $1$ | $[7]$ | $6$ |
| $e = 3$ | $2$ | $[1,2,2,2]$ | $7$ |
| $e \in \{2,4\}$ | $3$ | $[1,3,3]$ | $14$ |
| $e \in \{1,5\}$ | $6$ | $[1,6]$ | $14$ |

Fibrewise dial uniformity holds with $c = 1, 6, 7, 7, 7$, so the merge counts are
$k = 1, 1, 1, 2, 2$: **two** merging types, against exactly one at degree five.

**Theorem 5.2 (Septic splitting entropy).**
$$H(T) \;=\; \frac{4}{21} + \frac{6}{7}\log_2 3 + \frac16 \log_2 7 \;=\; 2.01691\ldots,$$
with rigorous bracket $2.0148 < H(T) < 2.0174$ from $198/125 < \log_2 3 < 317/200$ and
$14/5 < \log_2 7 < 281/100$.

**Theorem 5.3 (Septic dial).** $H(D) = \log_2 6 = 1 + \log_2 3 = 2.58496\ldots$

**Theorem 5.4 (Septic merge gap).** $\sum_t \Pr[T=t]\log_2 k(t) = \tfrac13 + \tfrac13 = \tfrac23$,
the two merging types $[1,3,3]$ and $[1,6]$ each having density $14/42 = 1/3$ and merge count $2$.

**Theorem 5.5 (The abelianization law at degree seven).**
$$I(p \bmod 7\,;\,T) \;=\; \log_2 6 - \frac23 \;=\; \frac13 + \log_2 3 \;=\; 1.91829\ldots,$$
with bracket $1.917 < I < 1.919$. The residuals are
$$H(T \mid p \bmod 7) = \tfrac16\log_2 7 - \tfrac17 - \tfrac17\log_2 3, \qquad
H(p\bmod 7 \mid T) = \tfrac23 .$$
As at degree five, the transcendental $\log_2 7$ cancels identically.

*Proof.* Theorem 2.4 with Theorems 5.3, 5.4; the residuals by subtraction from Theorem 5.2. $\square$

### 5.2 The totient-sum closed form

**Definition.** For a prime power $q$ put
$$\mathrm{Loss}(q) \;=\; \sum_{\substack{d \mid q-1 \\ d > 1}} \frac{\varphi(d)}{q-1}\,\log_2 \varphi(d).$$

The rationale: the type of $j \mapsto \alpha j + \beta$ with $\alpha \ne 1$ depends only on
$d = \operatorname{ord}(\alpha)$, and the number of $\alpha \in \mathbb{F}_q^{\times}$ of order $d$ is
$\varphi(d)$. Hence the type value attached to $d$ has density $\varphi(d)/(q-1)$ and merge count
$k = \varphi(d)$, while the identity and the translations sit inside the single class $\alpha = 1$
and merge nothing.

**Theorem 5.6 (The affine ladder).** $\mathrm{Loss}(5) = \tfrac12$, $\mathrm{Loss}(7) = \tfrac23$,
$\mathrm{Loss}(11) = \tfrac85$, and in each case the transmitted information of the
$\mathrm{AGL}(1,q)$ channel is
$$I(p \bmod q\,;\,T) \;=\; \log_2 (q-1) - \mathrm{Loss}(q).$$
In particular the measured losses of the degree-five and degree-seven channels agree with the
totient sum, and the degree-eleven prediction is
$$I = \log_2 10 - \tfrac85 = \log_2 5 - \tfrac35 = 1.72193\ldots$$

*Proof.* Direct evaluation. $q=5$: divisors $2,4$ with $\varphi = 1,2$, giving
$0 + \tfrac24\log_2 2 = \tfrac12$. $q=7$: divisors $2,3,6$ with $\varphi = 1,2,2$, giving
$0 + \tfrac26 + \tfrac26 = \tfrac23$. $q=11$: divisors $2,5,10$ with $\varphi = 1,4,4$, giving
$0 + \tfrac4{10}\cdot 2 + \tfrac4{10}\cdot 2 = \tfrac85$. The identification with the measured
losses is Theorems 3.6 and 5.4. $\square$

**Theorem 5.7 (Comparing the rungs).**
$$I_{q=5} = \tfrac32 \;<\; I_{q=7} = \tfrac13 + \log_2 3, \qquad \text{yet} \qquad
\frac{\mathrm{Loss}(5)}{\log_2 4} = \frac14 \;<\; \frac{\mathrm{Loss}(7)}{\log_2 6} = 0.25789\ldots$$
The septic channel transmits strictly more absolute information than the quintic one, but wastes a
strictly larger *fraction* of its dial: along the affine ladder the merging grows faster than the
dial.

*Proof.* The first inequality is $\log_2 3 > 7/6$; the second reduces, after clearing the positive
denominator $\log_2 6$, to $\tfrac23 > \tfrac14\log_2 6$, i.e. $\log_2 3 < 5/3$. $\square$

---

## 6. The abelian control: $\mathbb{Q}(\zeta_{11})^{+}$

To exhibit that the law is not a tautology about degree five, we run the same pipeline on the
degree-five *abelian* field: the real subfield $\mathbb{Q}(\zeta_{11})^{+}$, of degree
$5 = (11-1)/2$ over $\mathbb{Q}$, with cyclic group $C_5$.

**Theorem 6.1 (Control entropy).** Here the splitting type of $p$ is a function of the order of
$p$ in $(\mathbb{Z}/11)^{\times}/\{\pm1\}$: the type is $[1,1,1,1,1]$ when $p \equiv \pm 1$ and $[5]$
otherwise, so the type distribution is $(1/5, 4/5)$ and
$$H(T) \;=\; \log_2 5 - \frac85 \;=\; 0.721928\ldots$$

**Theorem 6.2 (Full pinning).** The dial is the entire residue $p \bmod 11$, with
$H(D) = \log_2 10 = 1 + \log_2 5 = 3.321928\ldots$ The channel is *pinned*: no type value merges two
residue classes in the sense that matters — the type is a deterministic function of the residue, so
$$I(p \bmod 11\,;\,T) \;=\; H(T) \;=\; \log_2 5 - \frac85,$$
and by Theorem 2.6 the loss $H(D) - I = 13/5 = 2.6$ bits is entirely accounted for by the
merging that the *type* performs on residue classes.

**Theorem 6.3 (The contrast).** $I_{C_5} = 0.7219\ldots < \tfrac32 = I_{F_{20}}$: the non-abelian
degree-five channel transmits strictly more than the abelian one. The abelian control saturates
its channel ($I = H(T)$) yet its type is so coarse that $2.6$ of its $3.32$ dial bits are lost; the
non-abelian $F_{20}$ fails to saturate ($I < H(T)$) yet loses only $0.5$ of its $2$ dial bits.
Non-commutativity per se costs nothing; *merging* costs.

**Empirical check.** Over the same prime range the control measures $H(T) = I = 0.7198$ against
$0.7219$, and its semiprime pair channel measures $0.2026$ against the predicted order-five
split-count value $0.2027$, reproducing the earlier cyclotomic computation at conductor $11$
through the identical pipeline.

---

## 7. Algorithms

Three procedures underlie the computations; all are elementary and stated for reproducibility.

**(A) Exact channel evaluation from a Chebotarev box.** Input: a finite box $S$ (list of group
elements), read-outs $T, D$. Build the joint histogram $n_{t,d}$ in $O(|S|)$, then compute
$H(T), H(D), H(T,D)$ and $I = H(T)+H(D)-H(T,D)$ in $O(|\mathcal{T}||\mathcal{D}|)$. For the boxes
here, $|S| \le 42$ at the prime level and $|S| \le 1764$ at the pair level, so this is instantaneous
and exact in rational-plus-logarithm arithmetic.

**(B) Structural evaluation via the merge pattern.** Input: the densities $\Pr[T=t]$ and merge
counts $k(t)$. Output: $I = H(D) - \sum_t \Pr[T=t]\log_2 k(t)$. This is $O(|\mathcal{T}|)$, avoids
computing $H(T)$ altogether, and is the form in which the law makes predictions (e.g. the ladder
formula of Theorem 5.6). Its correctness is Theorem 2.4; its completeness — that a vanishing loss
characterises pinning — is Theorem 2.6.

**(C) Empirical validation over primes and semiprimes.** For the prime level, sieve primes up to
$X$, discard ramified ones ($p \mid 5\cdot\operatorname{disc}$), compute $T(p)$ by the
$\mathbb{F}_p$/$\mathbb{F}_{p^2}$ root-count signature of §3.2 (or by direct factorisation), tabulate
against $p \bmod 5$, and compute the plug-in mutual information. For the semiprime level, draw
$M$ independent pairs from the exact Chebotarev law (fixed seeds), form $N \bmod 5$ as the sum of
the two dial classes in $C_4$, and tabulate. Plug-in mutual information has bias $O(\kappa/M)$ with
$\kappa$ the number of cells, which at $M = 4\times 10^5$ and $\kappa \le 64$ is below $10^{-3}$ —
consistent with the observed margins $-0.0011$, $-0.0038$, $-0.0032$.

---

## 8. Discussion

### 8.1 What the law says

Three degrees of abstraction are worth separating.

*At the level of a single field*, the law is an evaluation device: it replaces an entropy
computation involving transcendental logarithms with a count of merged classes. The cancellation of
$\log_2 5$ at degree five and $\log_2 7$ at degree seven is not luck; the general law shows the
transmitted information can only be $H(D)$ minus a sum of logs of small integers.

*At the level of the program*, the law now spans degrees $2$ through $5$ (and, with the affine
ladder, $7$) and abelianizations $C_2, C_3, C_4, C_2\times C_2$, and $C_n$. In every tested case
the gap between what the splitting type sees and what the dial holds is exactly the entropy of the
classes the type cannot tell apart, and the semiprime pair law holds verbatim. The type-channel
face of the program is complete at every tested group.

*At the level of general theory*, the law identifies the correct invariant: the *merge pattern*,
the multiset $\{(\Pr[T=t], k(t))\}$. Theorem 4.6a makes this an invariance statement — no other
feature of the group influences the single-prime channel — and Theorem 4.6 shows the invariance is
sharp: the pair channel is *not* merge-pattern invariant, because the product dial is a group
convolution and therefore senses whether a merged block is, say, a coset of a subgroup.

### 8.2 The dichotomy

Putting §4.3 and §4.4 together yields a clean conjectural dichotomy:

> The single-prime channel sees only the merge pattern — a partition of $G^{\mathrm{ab}}$ weighted
> by densities. The pair channel sees the merge pattern **as a subset structure of the group** —
> that is, it sees the group law.

The $F_{20}$ data give the first two evaluated points of the relevant functional: the merge block
$\{1,3\} \le C_4$ yields $5/4$, and the merge block $\{1,2\}$ yields $9/8$. Expressing the pair law
through the characters of $C_m$ evaluated on merged blocks would explain both values at once, and
would explain the otherwise surprising Theorem 4.3: $F_{20}$ reads the cyclotomic $C_4$ pair channel
exactly because its merge blocks coincide with those of the cyclotomic order-type read-out.

### 8.3 Methodological legacy

Two items are worth extracting for reuse.

1. **The pair law as an audit.** Type merging makes single-prime statistics insensitive to which
   class carries which label. A labelling error of this kind is not merely hard to see at the prime
   level; it is *provably* invisible there (Theorem 4.6a). Auditing must therefore be done at the
   product layer, where the error surfaces as a $1/8$-bit discrepancy that a $4\times10^5$-sample
   simulation resolves comfortably.
2. **The quintic root-count dictionary.** For $x^5 - 2$ the signature
   $(\#\{\text{roots in }\mathbb{F}_p\}, \#\{\text{roots in }\mathbb{F}_{p^2}\})$ takes the values
   $(5,5)/(1,1)/(1,5)/(0,0)$ for $[1^5]/[1,4]/[1,2,2]/[5]$. The $(1,5)$ entry — where a quartic
   analogy would suggest $(1,3)$ — is the trap: both quadratic factors contribute roots in
   $\mathbb{F}_{p^2}\setminus\mathbb{F}_p$.

### 8.4 Applications

The quantity computed here is exactly the leakage of a *cheap* arithmetic oracle about a *cheap*
arithmetic secret, and it admits at least three readings.

* **Factorisation side-channels.** If an adversary can determine, for a public semiprime $N = pq$,
  the splitting behaviour of a fixed small-degree polynomial at $p$ and $q$ — say by observing
  which of several algebraic subroutines succeed — the results quantify exactly how much that
  leaks about $N \bmod 5$: $5/4$ of $2$ bits, regardless of which factor is which. The
  which-factor wall being zero says that ordering leaks nothing further.
* **Sieve design.** Congruence conditions and factorisation-pattern conditions are the two standard
  filters in number-field sieve-type algorithms. The merged-coset law says how redundant they are:
  a filter on splitting type already implements $I$ bits of the congruence filter, so the two
  should be combined with weight $H(D) - I$.
* **Statistical testing of Galois group hypotheses.** Because $I$ is determined by the merge pattern
  and takes distinct rational values for distinct patterns, the measured mutual information between
  splitting type and residue over a prime range is a consistency test for a conjectured Galois
  group — with the caveat of Theorem 4.6a that it cannot distinguish labellings.

---

## 9. Future directions

This cycle closed the degree-five type channel of the Frobenius field $F_{20} = \mathrm{AGL}(1,5)$:
$I(p \bmod 5; T) = 3/2$ exactly, obtained *structurally* from the merged-coset law
$H(D) - I(T;D) = \sum_t P(t)\log_2 k(t)$ rather than from a numerical entropy computation; the
semiprime pair law $5/4$, equal verbatim to the cyclotomic $C_4$ pair channel, with a zero
which-factor wall; the $[1,2,2]$-fork equal to the order-four split-count channel on a non-abelian
field; the converse $I(T;D) = H(D) \iff$ no type value merges two cosets; and the coset-label swap,
invisible at the prime level and detected by the pair law at $1/8$ bit.

What the cycle exposes is a conjectural dichotomy: the single-prime channel sees only the merge
pattern (a partition of the abelianization group), while the pair channel sees the merge pattern as
a subset structure of the group, i.e. it sees the group law. The directions below make that
dichotomy precise and testable.

**1. Merge-pattern invariance of the single-prime channel.** The key insight is that $I(T;D)$ is a
functional of the unordered list of pairs $(P(t), k(t))$ alone — the group law never enters, which
is why the coset swap is invisible. The proved law already gives this for uniform dials; the
conjecture is that no further hypothesis is needed beyond uniformity inside fibres, and that the
*same* functional governs every Galois group with a given abelianization. Why now? The general law
and its converse are now established, so the invariance statement can be posed for arbitrary
$(S, T, D)$ and attacked directly rather than field by field.

**2. The pair law as a Fourier functional of the merge pattern.** The key insight is that the
semiprime observation $N \bmod m$ is the group convolution of two independent dial draws, so the
pair channel should be expressible through the characters of $C_m$ evaluated on the merged blocks;
the coset-swap defect $5/4 \to 9/8$ is then the change of a single character sum when a block moves
from $\{1,3\}$ to $\{1,2\}$. A proof would explain why $F_{20}$ reads the cyclotomic $C_4$ pair
channel exactly: its merge blocks coincide with those of the order-four cyclotomic type read-out.
Why now? We have two fully evaluated merge patterns on the same group ($\{1,3\}$-merge and
$\{1,2\}$-merge, values $5/4$ and $9/8$), which is exactly the data needed to pin the functional and
then verify a third pattern.

**3. The degree-$q$ Frobenius ladder $F_{q(q-1)} = \mathrm{AGL}(1,q)$.** The key insight is that
everything in the $F_{20}$ argument used only the orbit structure of $j \mapsto \alpha j + \beta$ on
$\mathbb{F}_q$: the type is $[1^q]$, $[q]$, or $[1,d,d,\dots]$ with $d = \operatorname{ord}(\alpha)$,
so the merge pattern is "divisors of $q-1$", giving the closed form
$I = \log_2(q-1) - \sum_{d \mid q-1,\,d>1}(\varphi(d)/(q-1))\log_2\varphi(d)$. Why now? $q=5$ is
proved in full, $q=7$ is now proved as well, and $q = 11$ is the next rung, with the falsifiable
prediction $\mathrm{Loss}(11) = 8/5$, i.e. $I = \log_2 5 - 3/5$.

**4. Beyond affine groups.** The natural next families are those whose abelianization is larger
than $C_2$ and whose cycle types still depend only on a conjugacy-invariant of the abelian
quotient: metacyclic groups $C_n \rtimes C_m$ generally, and the dihedral and quaternion cases at
small degree. The prediction is that the loss is again a totient-type sum over the order structure
of the acting group.

**5. The semiprime converse.** Theorem 2.6 characterises pinning at the single-prime layer. The
analogous question at the pair layer — for which merge patterns does
$I(\Pi; N \bmod m) = H(N \bmod m)$? — is open and is the natural "barrier-4 converse" of the
program.

---

## 10. Conclusion

The splitting type of a polynomial modulo $p$ is about the cheapest nontrivial arithmetic
observation one can make, and the residue $p \bmod m$ is about the cheapest nontrivial secret.
The merged-coset law says that the information flowing between them is always
$$I \;=\; H(\text{dial}) \;-\; \sum_{t}\Pr[T=t]\log_2 k(t),$$
a dial entropy minus an explicitly combinatorial correction, and its converse says that the
correction vanishes exactly when the type separates the abelianization classes. On the Frobenius
field $F_{20} = \mathrm{AGL}(1,5)$ this yields $3/2$ bits from a two-bit dial at the prime level and
$5/4$ bits at the semiprime level; on $\mathrm{AGL}(1,7)$ it yields $\tfrac13 + \log_2 3$ from a
$\log_2 6$ dial; and along the whole affine ladder the loss is the totient sum
$\sum_{d \mid q-1, d>1}(\varphi(d)/(q-1))\log_2 \varphi(d)$. The one genuinely delicate point —
which class carries which label — is invisible to every single-prime statistic and is exposed, at
$1/8$ bit, by the product of two primes.
