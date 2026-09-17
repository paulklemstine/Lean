# The Tree Position of a Semiprime Is Adically Sealed

**Author:** Aristotle
**Date:** 2026-09-16

---

## Abstract

Every odd semiprime $N = pq$ with $1 < p < q$ determines a unique *Fermat pair* $(m,n) = \big((q+p)/2,\,(q-p)/2\big)$ with $N = m^2 - n^2$, and this pair is a node of the Berggren ternary tree of primitive Pythagorean triples. The node's address — the unique word in the three Berggren generators leading to it from the root $(2,1)$ — encodes the factorisation of $N$ exactly. We determine precisely how much of that address is visible from $N$.

The address decomposes into two layers. The **$3$-adic skeleton** (which coordinate of the node is divisible by $3$) is a deterministic function of $N \bmod 3$, and conversely determines $N \bmod 3$; for the Fermat pair of $N = pq$ the skeleton flag $3 \mid n$ is literally the trace condition $p \equiv q \pmod 3$. The skeleton channel therefore carries exactly the content of the trace set $\{N \bmod 3\}$ and nothing more. The **metric layer** — branch letters, depth, path composition — is by contrast *sealed*: for every modulus $M \ge 2$ there is a single residue class of $N$ containing nodes with all three branch letters and with nontrivial factorisations; hence no function of $N \bmod M$ computes the branch letter. The same holds for depth (one residue class contains nodes of unboundedly many depths), and positionwise: for every modulus $M \ge 2$ and every depth $t$ there are three nodes in one residue class agreeing in all letters shallower than $t$ and differing at depth $t$, so no function of $N \bmod M$ together with the entire shallower prefix computes the letter at depth $t$.

We also prove two structural facts that explain the seal. (i) *The letter is the balance band:* for $N = pq$ with $0 < p < q$, the first letter is $A$ iff $q > 3p$, $B$ iff $2p < q \le 3p$, $C$ iff $q \le 2p$ — reading the letter is a coarse measurement of the balance of the factorisation. (ii) *The channel is too big:* a node at depth $d$ satisfies $2d + 3 \le m + n \le N$ with equality on the $C$-spine, so the depth is linear in $N$, i.e. exponential in the bit length; even writing the address down is not a polynomial-size operation. Together these results upgrade earlier coordinate-level orthogonality statements for the Pythagorean embedding to *adic strength*, and fence off any proposed factoring method routed through this geometry: such a method must either smuggle in the Fermat pair (circularity) or pay cost comparable to $N$.

An accompanying empirical study on $40{,}000$ random semiprimes with $p,q$ uniform primes in $[2^{16},2^{24})$ agrees on all counts: the skeleton and trace equivalences hold $40000/40000$; the parent-interval law and child-map reconstruction hold on all $86{,}634$ spot-checked descent steps; and no mutual-information signal between $N \bmod 3^k$ ($k \le 6$) and letters or depth exceeds a permutation null ($\max z = +2.51$ over $\approx 150$ tests), while both positive controls fire exactly.

---

## 1. Introduction

### 1.1 The question

Integer factorisation resists direct attack, so a large part of the research literature attacks it obliquely: rather than computing $p$ and $q$ from $N = pq$, one tries to compute some *partial* invariant of the factorisation, cheap enough to obtain and informative enough to reduce the search. The parity of $\lfloor q/p \rfloor$, the residue of $p$ modulo a small prime, the approximate size of the gap $q - p$ — any of these, obtained in polynomial time, would be a serious event.

A recurring source of hope is that the factorisation of $N$ is *geometrically* encoded in a rigid and highly structured object: the tree of primitive Pythagorean triples. The encoding is exact and classical. If $N = pq$ is odd with $p,q$ coprime and $1 < p < q$, then

$$m = \frac{q+p}{2}, \qquad n = \frac{q-p}{2}$$

are integers with $0 < n < m$, $\gcd(m,n) = 1$, and $m + n$ odd, and

$$N = m^2 - n^2.$$

These are exactly Euclid's conditions for $(m,n)$ to generate a primitive Pythagorean triple $(m^2-n^2,\,2mn,\,m^2+n^2)$. So $N$ is the odd leg of a unique primitive triple, and the parametrising pair $(m,n)$ — which we call the **Fermat pair** of $N$ — *is* the factorisation in disguise: $p = m-n$, $q = m+n$.

Moreover the set of such pairs carries a perfect ternary tree structure (Berggren, 1934): root $(2,1)$, and three generators

$$A:(m,n)\mapsto (2m-n,\,m), \qquad B:(m,n)\mapsto(2m+n,\,m), \qquad C:(m,n)\mapsto(m+2n,\,n),$$

under which every primitive pair is reached from the root by a unique finite word. Each semiprime therefore has a unique *address* — a word in $\{A,B,C\}^*$ — and reading that address is equivalent to factoring.

The question of this paper: **how much of the address is a function of $N$?**

### 1.2 The answer

Exactly the part that restates $N \bmod 3$, and nothing else.

More precisely, we isolate the *$3$-adic skeleton* of the node — the pattern of divisibility by $3$ among its coordinates — and show that it is informationally identical to the residue $N \bmod 3$ (Theorems 3.1–3.3), and that in the semiprime case it is literally the trace congruence $p \equiv q \pmod 3$ (Theorem 3.5). Then we show that every other feature of the address — the branch letters, the depth, the sequence of letters at any position — is *not a function of $N$ modulo anything* (Theorems 5.1, 5.4, 5.7, 6.4, 7.4).

The seal statements are exact and constructive: each is witnessed by an explicit three-parameter family of nodes lying in one residue class and carrying the three distinct letters. This is qualitatively stronger than a statistical null: it is not that no signal was detected at the tested levels, but that no signal exists at any level.

### 1.3 Relation to earlier work in this line

Prior work established (i) the exactness of the embedding of an odd semiprime into the Berggren tree, and (ii) the *orthogonality* of the Pythagorean coordinates to residue structure — coordinate-level measurements of the node carry no usable signal about $N$ beyond its residues. The present results strengthen (ii) from a coordinate-level statement to an *adic* one: the entire node *position* is sealed, simultaneously against all moduli, at all depths, and conditionally on all shallower data. Together with the depth bound of §6.3, this closes the Pythagorean-tree line at three strengths: embedding exact, coordinates orthogonal, position adically sealed.

### 1.4 Organisation

§2 fixes definitions. §3 proves the skeleton theorems (the visible layer). §4 proves the parent-interval law and the exactness of the descent, giving the bijection between words and Fermat pairs. §5 proves the letter seal. §6 proves depth blindness and the linear depth bound. §7 proves the strengthened seal: nontrivial factorisations, arbitrary moduli, and positionwise. §8 proves that the letter is the balance band of the factorisation — the reason the seal matters. §9 reports the empirical study. §10 discusses consequences for factoring attacks. §11 lists future directions.

---

## 2. Definitions

Throughout, all quantities are integers.

**Definition 2.1 (Node value).** For a pair $p = (m,n)$ put
$$\mathcal{N}(m,n) := m^2 - n^2 = (m-n)(m+n).$$

**Definition 2.2 (Fermat pair).** A pair $(m,n)$ is a **Fermat pair** if
$$0 < n < m, \qquad \gcd(m,n) = 1, \qquad m+n \text{ odd}.$$
These are exactly the Euclid parameters of primitive Pythagorean triples, hence exactly the nodes of the Berggren tree.

**Definition 2.3 (Berggren generators and words).** The three generators act on pairs by
$$A\cdot(m,n) = (2m-n,\,m), \qquad B\cdot(m,n) = (2m+n,\,m), \qquad C\cdot(m,n) = (m+2n,\,n).$$
The **root** is $r = (2,1)$. A **word** is a finite list $w = g_1 g_2 \cdots g_d$ of generators; its **evaluation** is
$$E(w) := g_1 \cdot \big(g_2 \cdot (\cdots (g_d \cdot r))\big), \qquad E(\varepsilon) = r,$$
and its **depth** is $|w| = d$. (We write words so that the leftmost letter is applied last, i.e. $E(g\,w) = g \cdot E(w)$; the leftmost letter is thus the *last*, deepest step from the root — equivalently, the first letter read on the ascent from the node to the root.)

**Definition 2.4 (Branch letter and parent).** For a pair $(m,n)$ define
$$\ell(m,n) := \begin{cases} A, & m < 2n,\\ B, & 2n \le m < 3n,\\ C, & 3n \le m,\end{cases}
\qquad
\pi(m,n) := \begin{cases} (n,\,2n-m), & m < 2n,\\ (n,\,m-2n), & 2n \le m < 3n,\\ (m-2n,\,n), & 3n \le m.\end{cases}$$

**Definition 2.5 (Letter at depth $t$).** $\ell_t(p) := \ell(\pi^{t}(p))$, where $\pi^t$ is the $t$-fold iterate; $\ell_0 = \ell$. Thus $\ell_t(p)$ is the letter of the $t$-th ancestor of $p$, and $(\ell_0(p), \ell_1(p),\dots)$ reads the address of $p$ from the node upward.

**Definition 2.6 ($M$-residue channel).** A function $f$ defined on integers **factors through $N \bmod M$** if $M \mid a - b$ implies $f(a) = f(b)$. Such an $f$ is precisely what an adversary with access only to the residue of $N$ modulo $M$ can compute.

**Definition 2.7 (Balance band).** For $N = pq$ with $0 < p < q$, the **balance band** of the factorisation is the trichotomy
$$q > 3p \quad (\text{unbalanced}), \qquad 2p < q \le 3p \quad (\text{intermediate}), \qquad q \le 2p \quad (\text{balanced}).$$

---

## 3. The visible layer: the $3$-adic skeleton equals the trace

### 3.1 The skeleton theorem

**Theorem 3.1 (Skeleton).** Let $(m,n)$ be coprime and $N = \mathcal{N}(m,n)$. Then
$$N \equiv 1 \!\!\pmod 3 \iff 3 \mid n, \qquad N \equiv 2 \!\!\pmod 3 \iff 3 \mid m, \qquad N \equiv 0 \!\!\pmod 3 \iff 3 \nmid m \text{ and } 3 \nmid n.$$

*Proof sketch.* Work in $\mathbb{Z}/3$. Squares there take only the values $0$ and $1$: $0^2 = 0$, $1^2 = 1$, $2^2 = 1$. Coprimality of $m,n$ forbids $3 \mid m$ and $3 \mid n$ simultaneously (else $3$ would be a unit). The remaining three configurations of $(m \bmod 3, n \bmod 3)$ up to squaring give $N \equiv m^2 - n^2$ equal to $1 - 0 = 1$, $0 - 1 = 2$, and $1 - 1 = 0$ respectively. The verification is a finite case check over $(\mathbb{Z}/3)^2$ minus the forbidden corner. $\square$

**Theorem 3.2 (Skeleton determined by the residue).** If $(m,n)$ and $(m',n')$ are coprime pairs with $\mathcal{N}(m,n) \equiv \mathcal{N}(m',n') \pmod 3$, then $3 \mid m \iff 3 \mid m'$ and $3 \mid n \iff 3 \mid n'$.

**Theorem 3.3 (Residue determined by the skeleton).** Conversely, if $3 \mid m \iff 3\mid m'$ and $3 \mid n \iff 3 \mid n'$, then $\mathcal{N}(m,n) \equiv \mathcal{N}(m',n') \pmod 3$.

*Proof sketch of 3.2 and 3.3.* Both are immediate from the fact that the three equivalences of Theorem 3.1 are exhaustive and mutually exclusive: the skeleton and the residue are two labellings of the same three-element partition of coprime pairs. $\square$

**Corollary 3.4 (Exact channel content).** The map (node $\mapsto$ skeleton) and the map (node $\mapsto N \bmod 3$) generate the same partition of coprime pairs. The skeleton channel carries *exactly* the information of the trace set $\{N \bmod 3\}$: no more, no less.

### 3.2 The skeleton is the trace

**Theorem 3.5 (Skeleton $=$ trace).** Let $p,q$ be odd and coprime with $1 < p < q$, $N = pq$, and let $(m,n) = ((q+p)/2, (q-p)/2)$ be the Fermat pair. Then $(m,n)$ is a Fermat pair, $\mathcal{N}(m,n) = N$, and
$$3 \mid n \iff p \equiv q \!\!\pmod 3, \qquad N \equiv 1 \!\!\pmod 3 \iff 3 \mid n .$$
Moreover $N \equiv 1 \pmod 3 \iff \big(p \equiv q \pmod 3 \text{ and } 3 \nmid p\big)$.

*Proof sketch.* Oddness of $p,q$ makes $m,n$ integers; writing $p = m-n$, $q = m+n$ and using a Bézout identity for $(p,q)$ produces one for $(m,n)$, so $m,n$ are coprime; $m+n = q$ is odd; $0 < n < m$ is clear. The identity $\mathcal{N}(m,n) = (m-n)(m+n) = pq$ is algebra. For the first equivalence, $2n = q-p$, and $3$ is odd, so $3 \mid n \iff 3 \mid q - p \iff p \equiv q$. The second is Theorem 3.1 applied to the Fermat pair. The last is another finite check in $\mathbb{Z}/3$, using coprimality to exclude $p \equiv q \equiv 0$. $\square$

**Interpretation.** The one feature of the tree position that *is* readable from $N$ is readable because squares modulo $3$ take only two values — a statement about the quadratic character of the residue field $\mathbb{F}_3$, finite in content. It restates the trace congruence $p \equiv q \pmod 3$ and adds nothing to it. Any "attack" built on the skeleton is therefore circular: it consumes $N \bmod 3$ and returns $N \bmod 3$.

---

## 4. The parent-interval law and the exactness of the address

### 4.1 The law

**Theorem 4.1 (Parent-interval law).** For every pair $p = (m,n)$,
$$\ell(p) \cdot \pi(p) = p .$$
That is, applying the band-decided generator to the band-decided parent returns the node: the ratio $m/n$ alone determines the ancestry step.

*Proof sketch.* Three cases. If $m < 2n$: $A \cdot (n, 2n-m) = (2n - (2n-m),\, n) = (m,n)$. If $2n \le m < 3n$: $B \cdot (n, m-2n) = (2n + (m-2n),\, n) = (m,n)$. If $3n \le m$: $C \cdot (m-2n, n) = ((m-2n) + 2n,\, n) = (m,n)$. $\square$

**Lemma 4.2 (No boundary cases).** If $(m,n)$ is a Fermat pair other than the root, then $m \ne 2n$ and $m \ne 3n$.

*Proof sketch.* Either equality makes $n \mid m$, and coprimality then forces $n = 1$, so $(m,n) \in \{(2,1),(3,1)\}$; the first is the root and the second violates the parity condition. $\square$

**Theorem 4.3 (The parent is a node).** If $p$ is a Fermat pair other than the root, $\pi(p)$ is a Fermat pair.

*Proof sketch.* Positivity and the inequality $\pi(p)_2 < \pi(p)_1$ follow from the band inequalities together with Lemma 4.2. Coprimality is preserved because each branch of $\pi$ is an elementary transformation $a \mapsto a + kb$ (possibly composed with a swap and a sign), and $\gcd$ is invariant under these. Opposite parity is preserved because each branch changes $m+n$ by an even amount. $\square$

**Theorem 4.4 (Uniqueness of parent and letter).** Let $p$ be a Fermat pair other than the root. If $q$ is any valid pair and $g$ any generator with $g \cdot q = p$, then $g = \ell(p)$ and $q = \pi(p)$.

*Proof sketch.* By Theorem 4.1, $g \cdot q = \ell(p)\cdot\pi(p)$; the generators are injective on valid pairs and their images on valid pairs are disjoint (the image of $A$ lies in the band $m < 2n$, of $B$ in $2n < m < 3n$, of $C$ in $m > 3n$), so $g = \ell(p)$ and then injectivity gives $q = \pi(p)$. $\square$

### 4.2 Termination and the bijection

**Lemma 4.5 (Strict descent).** For a Fermat pair $p$, $\pi(p)_1 + \pi(p)_2 < p_1 + p_2$.

*Proof sketch.* In each band the sum drops: $(n) + (2n-m) = 3n - m < m+n$ since $m > n$; $(n) + (m-2n) = m - n < m+n$; $(m-2n)+n = m-n < m+n$. $\square$

**Theorem 4.6 (Every node has an address).** For every Fermat pair $p$ there is a word $w$ with $E(w) = p$.

*Proof sketch.* Strong induction on $(p_1 + p_2)$. If $p$ is the root take $w = \varepsilon$. Otherwise $\pi(p)$ is a Fermat pair (Theorem 4.3) with strictly smaller sum (Lemma 4.5); take the word $v$ for it by induction and set $w = \ell(p)\,v$, using Theorem 4.1. $\square$

**Theorem 4.7 (Unique address; the tree is exactly the Fermat pairs).** For every Fermat pair $p$ there is a *unique* word $w$ with $E(w) = p$; and conversely $E(w)$ is a Fermat pair for every $w$. Hence
$$E : \{A,B,C\}^* \longrightarrow \{\text{Fermat pairs}\}$$
is a bijection.

*Proof sketch.* Existence is Theorem 4.6. Uniqueness is the freeness of the Berggren action (equivalently, iterated application of Theorem 4.4). That $E(w)$ is always a Fermat pair follows by induction on $|w|$: the root is one, and each generator preserves positivity, the inequality, coprimality (again $a \mapsto a+kb$) and opposite parity. $\square$

**Remark 4.8.** Theorem 4.7 is the exact, unconditional form of the empirical observation that $40000/40000$ capped descents terminated at the root: no step cap is needed, and the twin-type nodes $n = 1$ that had to be censored in the experiment (they descend one unit at a time in $m$, exhausting the cap) are covered.

**Theorem 4.9 (The address is the factorisation).** For any nonempty word $w$ with $E(w) = (m,n)$,
$$\mathcal{N}(m,n) = (m-n)(m+n), \qquad 0 < m-n, \qquad 2 < m+n .$$
Thus knowledge of the address yields a nontrivial factorisation of $N$; for the Fermat pair of a semiprime, the two factors are exactly $p$ and $q$.

This is the *positive control*: the tree position is not merely correlated with the factorisation; it is the factorisation.

---

## 5. The seal, first form: no residue channel gives the letter

**Theorem 5.1 (Three letters in one residue class).** Let $M \ge 3$ be odd. The three pairs
$$w_A = (M+1,\,M), \qquad w_B = (3M-1,\,M), \qquad w_C = (3M+1,\,M)$$
are Fermat pairs with
$$\mathcal{N}(w_A) = 2M+1, \qquad \mathcal{N}(w_B) = 8M^2 - 6M + 1, \qquad \mathcal{N}(w_C) = 8M^2+6M+1,$$
all congruent to $1$ modulo $M$, and with $\ell(w_A) = A$, $\ell(w_B) = B$, $\ell(w_C) = C$.

*Proof sketch.* Each pair satisfies $0 < n < m$ for $M \ge 3$; coprimality is witnessed by explicit Bézout identities ($1\cdot(M+1) - 1\cdot M = 1$; $-1\cdot(3M-1) + 3\cdot M = 1$; $1\cdot(3M+1) - 3\cdot M = 1$); opposite parity holds because $M$ is odd, so $m+n$ is odd in each case. The $\mathcal{N}$-values are direct expansions, and each is $1$ plus a multiple of $M$. The letters follow from the band definition: $M+1 < 2M$, $2M \le 3M-1 < 3M$, and $3M \le 3M+1$. $\square$

**Theorem 5.2 (No letter function).** Let $M \ge 3$ be odd and let $f$ be any function of $N$ factoring through $N \bmod M$. Then there is a Fermat pair $p$ with $f(\mathcal{N}(p)) \ne \ell(p)$.

*Proof sketch.* If $f$ were correct on all Fermat pairs, then applying it to $w_A$ and $w_B$ of Theorem 5.1 — whose $\mathcal{N}$-values are congruent mod $M$ — would give $A = f(\mathcal{N}(w_A)) = f(\mathcal{N}(w_B)) = B$, a contradiction. $\square$

**Theorem 5.3 ($3$-adic form).** For every $k \ge 1$ and every $f$ factoring through $N \bmod 3^k$, there is a Fermat pair on which $f$ fails to compute the letter. Equivalently, at every $3$-adic level $3^k$ there exist three Fermat pairs whose $N$-values are pairwise congruent modulo $3^k$ and whose letters are $A$, $B$, $C$.

*Proof sketch.* $3^k$ is odd and $\ge 3$ for $k \ge 1$; apply Theorems 5.1 and 5.2 with $M = 3^k$. $\square$

**Remark.** The experiment tested $k \le 6$ statistically; Theorem 5.3 holds for all $k$, exactly.

---

## 6. Depth blindness and the size of the channel

### 6.1 The spine

**Definition 6.1.** The **$C$-spine** of length $d$ is the word $C^d$.

**Lemma 6.2 (Spine evaluation).** $E(C^d) = (2 + 2d,\,1)$ and hence
$$\mathcal{N}(E(C^d)) = (2+2d)^2 - 1 = (2d+1)(2d+3).$$

*Proof sketch.* Induction: $E(C^0) = (2,1)$; and $C\cdot(m,1) = (m+2,1)$. $\square$

These are precisely the twin-type nodes $n=1$ whose descents the capped experiment had to censor ($42$ of $40402$ trials, $0.10\%$, reported).

**Theorem 6.3 (Unbounded depth in one residue class).** For every modulus $M \ge 1$ and every $j \ge 0$,
$$M \mid \mathcal{N}(E(C^{1+jM})) - \mathcal{N}(E(C^{1})),$$
while the depths are $1 + jM$ and $1$. Hence one residue class of $N$ modulo $M$ contains nodes of unboundedly many depths.

*Proof sketch.* By Lemma 6.2, $\mathcal{N}(E(C^{1+jM})) = (4 + 2jM)^2 - 1 = 15 + M(16j + 4j^2M)$, and $\mathcal{N}(E(C^1)) = 15$. $\square$

**Theorem 6.4 (No depth function).** For every $M \ge 1$ and every $f$ factoring through $N \bmod M$ there is a word $w$ with $f(\mathcal{N}(E(w))) \ne |w|$. In particular this holds for $M = 3^k$ at every $3$-adic level.

*Proof sketch.* Apply $f$ to the two spine nodes of Theorem 6.3 with $j = 1$: it must return the same value, but the depths $1$ and $1+M$ differ. $\square$

### 6.2 The depth bound

**Theorem 6.5 (Linear depth bound).** For every word $w$ with $E(w) = (m,n)$,
$$2|w| + 3 \le m+n,$$
with equality exactly on the $C$-spine: $2d+3 = (2+2d)+1$.

*Proof sketch.* Induction on $|w|$. At the root, $2\cdot 0 + 3 = 3 = 2+1$. Each generator increases $m+n$ by at least $2$: $A$ gives $(2m-n)+m - (m+n) = 2m-2n > 0$ and even; $B$ gives $2m+n+m - (m+n) = 2m \ge 2$; $C$ gives $m+2n+n-(m+n) = 2n \ge 2$. $\square$

**Corollary 6.6 (Exponential in the bit length).** For every nonempty word $w$, $2|w| + 3 \le \mathcal{N}(E(w))$.

*Proof sketch.* $\mathcal{N} = (m-n)(m+n)$ with $m - n \ge 1$, so $\mathcal{N} \ge m+n \ge 2|w|+3$. $\square$

Thus the depth of the $N$-node can be as large as $\Theta(N)$, i.e. exponential in $\log N$; the $C$-spine attains the bound. Even granting free access to each individual letter, *writing down* the address is not a polynomial-size operation. The hidden channel is not merely unreadable; it is too large to be a channel at all in the complexity-theoretic sense.

### 6.3 The combined seal

**Theorem 6.7 (The tree position is adically sealed).** For every $k \ge 1$:

1. *(visible)* For coprime pairs $(m,n)$, $(m',n')$ with $\mathcal{N}(m,n) \equiv \mathcal{N}(m',n') \pmod 3$, one has $3 \mid n \iff 3 \mid n'$ — the skeleton is a function of $N \bmod 3$;
2. *(letter sealed)* no function factoring through $N \bmod 3^k$ computes the branch letter on all Fermat pairs;
3. *(depth sealed)* no function factoring through $N \bmod 3^k$ computes the depth on all words.

*Proof.* Combine Theorems 3.2, 5.3 and 6.4. $\square$

---

## 7. The strengthened seal

Three objections to §5 deserve answers, and all three fail.

### 7.1 Nontrivial factorisations, all moduli

The $A$-witness $(M+1,M)$ of Theorem 5.1 has $m-n = 1$, i.e. it encodes the trivial factorisation $N = 1 \cdot N$; and Theorem 5.1 assumed $M$ odd. Both weaknesses are removable simultaneously.

**Theorem 7.1 (Proper witnesses).** Let $M \ge 2$ be *any* integer. The three pairs
$$W_A = (4M-1,\,2M), \qquad W_B = (4M+1,\,2M), \qquad W_C = (6M+1,\,2M)$$
are Fermat pairs, with
$$\mathcal{N}(W_A) = (2M-1)(6M-1), \qquad \mathcal{N}(W_B) = (2M+1)(6M+1), \qquad \mathcal{N}(W_C) = (4M+1)(8M+1),$$
all congruent to $1$ modulo $M$; each has $m - n \ge 2M-1 \ge 3$ (so the exhibited factorisation is nontrivial); and $\ell(W_A) = A$, $\ell(W_B) = B$, $\ell(W_C) = C$.

*Proof sketch.* Coprimality: $1\cdot(4M-1) + 2\cdot(2M) \cdot(-1)$-type Bézout identities work in each case (e.g. $-1\cdot(4M-1) + 2\cdot(2M) = 1$, $1\cdot(4M+1) - 2\cdot 2M = 1$, $1\cdot(6M+1) - 3\cdot 2M = 1$). Parity: $m$ is odd, $n = 2M$ even. Expansions: $(4M-1)^2 - 4M^2 = 12M^2 - 8M + 1 = (2M-1)(6M-1) \equiv 1$; $(4M+1)^2 - 4M^2 = 12M^2+8M+1 = (2M+1)(6M+1) \equiv 1$; $(6M+1)^2 - 4M^2 = 32M^2+12M+1 = (4M+1)(8M+1) \equiv 1$. Bands: $4M-1 < 4M$ gives $A$; $4M \le 4M+1 < 6M$ for $M \ge 1$ gives $B$; $6M \le 6M+1$ gives $C$. $\square$

**Theorem 7.2 (No letter function, proper form).** For every $M \ge 2$ (odd or even) and every $f$ factoring through $N \bmod M$, there is a Fermat pair $p$ with $m - n \ge 3$ and $f(\mathcal{N}(p)) \ne \ell(p)$.

**Theorem 7.3 (Balance band not computable).** For every $M \ge 2$ there exist Fermat pairs $p_1, p_2$ with $\mathcal{N}(p_1) \equiv \mathcal{N}(p_2) \pmod M$ such that $p_1$ is *unbalanced*, $3(m_1 - n_1) < m_1 + n_1$, and $p_2$ is *balanced*, $m_2 + n_2 \le 2(m_2 - n_2)$. No function of $N \bmod M$ separates the two.

*Proof sketch.* Take $p_1 = W_A$, $p_2 = W_C$. Then $3(2M-1) = 6M-3 < 6M-1$ and $8M+1 \le 2(4M+1) = 8M+2$, and $\mathcal{N}(W_A) - \mathcal{N}(W_C) = -20M^2 - 20M$ is divisible by $M$. $\square$

**Theorem 7.4 ($3$-adic proper form).** For every $k \ge 1$ and every $f$ factoring through $N \bmod 3^k$, there is a Fermat pair with nontrivial factorisation on which $f$ fails to compute the letter.

### 7.2 Positionwise: even the deep letters are sealed

A subtler objection: perhaps the letter at depth $t$ becomes computable once all shallower letters are known — a sequential rather than one-shot channel. It does not.

**Definition 7.5 (Depth family).** For $M \ge 2$, $k \in \{1,2,3\}$, $t \ge 0$, put
$$\nu(M,k,t) := (4tM + 2Mk + 1,\; 2M).$$

**Lemma 7.6.** $\nu(M,k,t)$ is a Fermat pair, $\mathcal{N}(\nu(M,k,t)) \equiv 1 \pmod M$, and for $M \ge 1$, $k \ge 1$,
$$\pi\big(\nu(M,k,t+1)\big) = \nu(M,k,t), \qquad \text{hence} \qquad \pi^{r}\big(\nu(M,k,r+u)\big) = \nu(M,k,u).$$

*Proof sketch.* Coprimality: $1 \cdot m + (-(2t+k))\cdot n = 1$. Parity: $m$ odd, $n$ even. Residue: expanding, $\mathcal{N} - 1$ is $M$ times an explicit integer. Descent: for $t \ge 0$, $k \ge 1$, $M\ge1$ we have $m = 4(t+1)M + 2Mk+1 \ge 6M$, so the node is in the $C$-band and $\pi$ subtracts $2n = 4M$ from $m$, which is exactly the step from $t+1$ to $t$. Iterate. $\square$

**Theorem 7.7 (All letters at depth $t$ in one residue class).** For every $M \ge 2$ and every $t \ge 0$ the three nodes $\nu(M,1,t)$, $\nu(M,2,t)$, $\nu(M,3,t)$ satisfy:
- all three have $N \equiv 1 \pmod M$;
- for every $s < t$, all three have $\ell_s = C$ — they agree in the entire shallower prefix;
- $\ell_t(\nu(M,1,t)) = A$, $\ell_t(\nu(M,2,t)) = B$, $\ell_t(\nu(M,3,t)) = C$.

*Proof sketch.* The residue claim and the descent are Lemma 7.6. For $s < t$: $\pi^s(\nu(M,k,t)) = \nu(M,k,t-s)$ with $t-s \ge 1$, whose first coordinate is $\ge 6M$, hence letter $C$. At $s = t$: $\pi^t(\nu(M,k,t)) = \nu(M,k,0) = (2Mk+1, 2M)$, and $2M+1 < 4M$ ($k=1$, letter $A$), $4M \le 4M+1 < 6M$ ($k=2$, letter $B$), $6M \le 6M+1$ ($k=3$, letter $C$). $\square$

**Theorem 7.8 (Positionwise seal).** Let $M \ge 2$ and $t \ge 0$. Let $f(N, u)$ be any function of the residue $N \bmod M$ together with an arbitrary prefix $u = (u_0, u_1, \dots)$ of letters, in the sense that $f(a,u) = f(b,v)$ whenever $M \mid a-b$ and $u_s = v_s$ for all $s < t$. Then there is a Fermat pair $p$ with
$$f\big(\mathcal{N}(p),\, (\ell_s(p))_s\big) \ne \ell_t(p).$$

*Proof sketch.* By Theorem 7.7, $\nu(M,1,t)$ and $\nu(M,2,t)$ have congruent $N$-values and identical prefixes, so $f$ returns the same value on both; but their letters at depth $t$ are $A$ and $B$. $\square$

The seal therefore holds at every position of the address, not merely at the first letter, and even for an adversary who has been *given* the entire shallower path for free.

---

## 8. Why the seal matters: the letter is the balance band

The seal would be uninteresting if the branch letter were itself uninformative. It is not.

**Theorem 8.1 (Letter $=$ balance band).** Let $p, q$ be odd with $0 < p < q$, and let $(m,n) = ((q+p)/2,(q-p)/2)$ be the Fermat pair of $N = pq$. Then
$$\ell(m,n) = A \iff q > 3p, \qquad \ell(m,n) = B \iff 2p < q \le 3p, \qquad \ell(m,n) = C \iff q \le 2p .$$

*Proof sketch.* Substitute $m = (q+p)/2$, $n = (q-p)/2$ into the band inequalities. $m < 2n$ becomes $q+p < 2(q-p)$, i.e. $3p < q$. $m < 3n$ becomes $q+p < 3(q-p)$, i.e. $4p < 2q$, i.e. $2p < q$. The trichotomy follows. $\square$

So the first letter is precisely a coarse measurement of the *balance* of the factorisation — exactly the quantity that governs whether Fermat-type search succeeds quickly. Theorem 7.3 says this measurement is unavailable from any residue channel; Theorem 7.8 says it stays unavailable at every deeper position.

**Theorem 8.2 (Determinism of the band-to-letter map — the live positive control).** If two nodes lie in the same ratio band (i.e. agree on the truth values of $m < 2n$ and $m < 3n$), they have the same letter.

**Theorem 8.3 (Reading the band is reading the factorisation — the circularity barrier).** For a Fermat pair $(m,n)$, $\mathcal{N}(m,n) = (m-n)(m+n)$ with $m-n > 0$ and $m+n > 1$: possession of the node hands over a nontrivial factorisation of $N$.

Theorems 8.2 and 8.3 together are the structural reason the seal must hold — or, read from the other side, the reason that breaking the seal would be a factoring algorithm. The letters are a *deterministic* function of the band; the band is the factorisation; hence any $N$-computable route to the letters would be an $N$-computable route to the factors.

---

## 9. The empirical study

The theorems above were preceded and are corroborated by a computational study; we summarise it because the agreement is informative about the sharpness of the theory.

**Sample.** $40{,}000$ semiprimes $N = pq$ with $p, q$ independent uniform primes in $[2^{16}, 2^{24})$, primality by Miller–Rabin with $12$ bases; fixed random seeds. Descents capped at $5000$ steps; twin-type nodes with $n = 1$ descend one unit at a time in $m$ and exhaust the cap — these were censored and reported: $42$ of $40402$ trials, i.e. $0.10\%$. Total runtime $154$ s.

**Skeleton (Theorem 3.1) and trace restatement (Theorem 3.5).** Agreement $40000/40000 = 100\%$ on both the three-way skeleton equivalence and the identification $3 \mid n \iff q \equiv p \pmod 3 \iff N \equiv 1 \pmod 3$.

**Parent-interval law (Theorem 4.1) and exactness (Theorem 4.7).** All $40{,}000$ descents terminated exactly at the root $(2,1)$; on $86{,}634$ spot-checked steps, the band-decided parent and the child-map reconstruction agreed exactly at every step.

**Blindness (Theorems 5.2, 6.4).** Mutual information $I(N \bmod 3^k;\, \ell_t)$ was measured against a $300$-shuffle permutation null for every letter depth $t \le 10$ and every level $k \le 6$, and likewise for the depth and for the letter-composition counts. Across approximately $150$ tests the worst deviation was $z = +2.51$, within noise even before multiplicity correction. The flagship cell: $k=1$, $I(N \bmod 3;\,\ell_0) = 0.00004$ bits versus null $0.00004$, $z = +0.04$.

**Positive controls.** Two live controls fire, confirming the measurement apparatus is capable of detecting a channel when one exists:
- Trace: $I(N \bmod 3;\, s \bmod 3) = 1.0000$ bits exactly, where $s$ is the factor sum.
- Band determinism: $I(\text{ratio band};\, \ell_0) = 1.4738$ bits $= H(\ell_0)$ exactly — the first letter is a deterministic function of the band, matching Theorem 8.2.
- A third diagnostic: $\mathrm{corr}(\log d_B, \log(q-p)) = -0.141$, the anticorrelation between tree depth and factor gap, replicating earlier observations. The tree *does* respond to the balance of the factorisation; it simply does not respond to $N$.

Every empirical finding is subsumed by a theorem above, and every theorem above strengthens the corresponding empirical claim from "not detected at tested levels" to "does not exist at any level".

---

## 10. Discussion: consequences for factoring

### 10.1 The dichotomy

Combine Theorems 6.7, 7.8, 8.1, 8.3 and Corollary 6.6. Any proposed factoring method that operates by *reading the Berggren position of the $N$-node* is subject to the following dichotomy:

- **Circularity.** If the method obtains the branch letters (or the balance band, or the ratio $m/n$), then by Theorem 8.3 it has already obtained the Fermat pair, hence the factorisation. It cannot obtain them from residues of $N$: Theorems 7.2 and 7.8 rule this out for every modulus, at every position, even conditional on all shallower letters.
- **Cost.** If instead the method enumerates or traverses the tree, Corollary 6.6 bounds the depth from below in the worst case by $\Theta(N)$ — exponential in $\log N$ — and the $C$-spine attains it. The address is not a polynomial-size object.

There is no third option in this geometry: either you already know the answer, or you pay a cost comparable to trial division.

### 10.2 The shape of a closed dial

It is useful to view this result as one member of a family of "residue-dial" results. In each case one identifies a natural invariant of the factorisation, asks how much of it is a function of $N$ modulo small numbers, and finds that the answer is exactly the *trace-set content* — the residues of $N$ themselves — with the remaining structure requiring the factorisation to read. The tree position joins that family, and is in fact the sharpest member so far, because it is sealed *adically*: the seal does not degrade as the modulus grows, and the witnesses are explicit at every modulus and depth.

### 10.3 What the seal does not say

Three honest caveats.

1. The seal is about *residue channels*: functions of $N \bmod M$. It does not rule out channels of other types (lattice reductions, analytic estimates, quantum algorithms). What it does rule out is the specific, recurring hope that the Pythagorean geometry contains a cheap modular fingerprint of the factorisation.
2. The seal is a statement about *worst-case correctness*: a function factoring through $N \bmod M$ must be *wrong somewhere*. It leaves open average-case questions in the classical sense of a biased guess; but the witnesses are dense families (parametrised by $M$ and $t$), and the empirical mutual information at $\approx 4 \times 10^{-5}$ bits shows no exploitable average-case bias either.
3. The skeleton *is* a real channel; it is simply a redundant one. The correct summary is not "the tree says nothing" but "the tree says $N \bmod 3$, twice".

---

## 11. Future directions

**What this line established.** (i) The skeleton equals the trace: for every coprime $(m,n)$ with $N = m^2-n^2$, the divisibility pattern by $3$ in the coordinates and the residue $N \bmod 3$ determine each other, and for the Fermat pair of $N = pq$ the flag $3 \mid n$ is literally $p \equiv q \pmod 3$. (ii) The parent-interval law, exactly: the parent is decided by the ratio band alone and is unique, the descent terminates at the root for *every* Fermat pair, and words correspond bijectively to Fermat pairs — the empirical $40000/40000$ upgraded to a theorem with no step cap and no censoring. (iii) The metric layer is sealed exactly rather than statistically: for every modulus a single residue class contains nodes with all three letters, so no function of $N \bmod M$ computes the letter, and the depth takes unboundedly many values in one class. (iv) Size of the hidden channel: $2d + 3 \le m+n \le N$, saturated exactly on the censored twin-type $C$-spine; the depth is linear in $N$, i.e. exponential in the bit length, so even writing down the position is not a polynomial-size channel. (v) The letter is the balance band: for $N = pq$ the first letter is $A$ iff $q > 3p$, $B$ iff $2p < q \le 3p$, $C$ iff $q \le 2p$; reading it would reveal how balanced the factorisation is, and no residue channel reveals it. (vi) The positionwise seal: with the family $\nu(M,k,t) = (4tM+2Mk+1,\,2M)$, for every modulus $M \ge 2$ and every depth $t$ the nodes $k=1,2,3$ lie in the class $N \equiv 1 \pmod M$, agree in all letters shallower than $t$, and carry letters $A$, $B$, $C$ at depth $t$ — so the seal holds at every position, not only the first.

**Why the failures failed.** The one thing that *is* readable from $N$ — the skeleton — is readable because squares mod $3$ take only the values $\{0,1\}$; that is a statement about the quadratic character of the residue field, and it is finite in content. It cannot be iterated into a deeper channel, because the higher levels $3^k$ have witnesses in a single class carrying all three letters.

**Open directions.**

1. *Other trees and other parametrisations.* The Berggren tree is one of several ternary tree structures on primitive triples (Barning's matrices, the Price tree, the Fibonacci-box tree). Do the analogous position channels seal in the same way, and is there a uniform proof covering all of them at once?
2. *Beyond residue channels.* Formulate and settle the analogous seal for lattice-type channels: is the tree position invisible to a short-vector oracle on a lattice built from $N$?
3. *Quantitative average-case seal.* Upgrade the worst-case statements to a bound on the statistical distance between the joint distribution of $(N \bmod M, \ell_t)$ and the product of its marginals, for $N$ a random semiprime of given bit length. The empirical mutual information $\approx 4\times 10^{-5}$ bits suggests a strong bound is available.
4. *The converse cost question.* Prove a matching lower bound: any algorithm that outputs the balance band of $N = pq$ for all $N$ in a given range, using only oracle access to residues of $N$, must make $\Omega(\cdot)$ queries. The seal shows one query class fails; quantifying the failure is the next step.
5. *Deep-position structure.* The family $\nu(M,k,t)$ agrees on prefixes of all-$C$. Are there witness families agreeing on an *arbitrary prescribed* prefix — i.e. is the seal uniform over prefixes, not just over depths?
6. *Interference proposals.* Claims occasionally circulate of "exact factorisation by interference of Pythagorean triples" in polynomial time. The present results fence such proposals: any such method must either smuggle in the Fermat pair, and so be circular, or aggregate over a structure of size comparable to $N$. Making this into a formal impossibility statement for a precisely specified interference model is an attractive target.
7. *The quantum channel.* The frontier of this research line moves away from the tree geometry and back to quantum-channel questions (the phase diagram of a qubit-trade protocol) and to the converse of the aggregation-cost barrier.

---

## 12. Conclusion

The address of an odd semiprime in the tree of primitive Pythagorean triples exists, is unique, and is equivalent to the factorisation. What we have shown is that it is *sealed*: its skeleton is exactly the trace $N \bmod 3$ restated, and every other feature of it — letter, depth, composition, at any position, at any modulus, with any prefix given free — is provably not a function of $N$'s residues. The one direction in which the tree speaks is a direction in which you were already listening.
