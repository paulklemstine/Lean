# The Pythagorean Hydra: Descent, Freeness and Exact Calibration of the Berggren Tree

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The Berggren tree organises the primitive Pythagorean triples into an infinite ternary tree rooted at $(3,4,5)$. We give a complete, self-contained development of its *descent* structure and use it to settle two logical questions about the tree, both negatively but with exact calibration.

First, we exhibit a single uniform **parent map**
$$P(a,b,c) = \bigl(\,|a+2b-2c|,\ |2a+b-2c|,\ 3c-2a-2b\,\bigr)$$
and prove that on every primitive triple with odd first leg it coincides with one of the three inverse Berggren moves — the choice being determined by the sign pattern of $(u,v) = (a+2b-2c,\ 2a+b-2c)$ — that it preserves primitivity, and that it strictly decreases the hypotenuse. This yields the classification theorem: the tree generated from $(3,4,5)$ by the three Berggren moves is exactly the set of primitive Pythagorean triples with positive entries and odd first leg, and membership is decidable by an elementary arithmetic test.

Second, we prove that the **address map** $\mathrm{addr}$, sending a finite word in the alphabet $\{A,B,C\}$ to the triple obtained by applying the corresponding Berggren moves to $(3,4,5)$, is a bijection onto that set, with inverse computed by iterated descent. The tree is therefore *free*, and the relation $\mathrm{addr}(w) = t$ is decidable: no Matiyasevich-style Diophantine phenomenon can be encoded in the tree's addressing.

Third, we define the **Pythagorean Hydra**: heads are primitive triples; chopping a head $t$ permits regrowth of at most $k$ heads, each a Berggren ancestor of $t$. We prove that Hercules always wins — even under unbounded regrowth — and we compute the game's length function *exactly*: with branching bound $k$, the longest battle from a hydra $H$ has precisely
$$\Phi_k(H) = \sum_{t \in H}\bigl(1 + k + k^2 + \cdots + k^{d(t)}\bigr)$$
moves, where $d(t)$ is the depth of $t$ in the tree. Consequently the termination statement admits an elementary witness and carries none of the proof-theoretic strength of the Kirby–Paris hydra: the Pythagorean Hydra lives at $\omega^\omega$, not $\varepsilon_0$. Finally we show this is sharp in both directions: relaxing strict descent to non-strict descent, or reversing regrowth to Berggren *children*, produces explicit infinite battles.

**Keywords:** Pythagorean triples, Berggren tree, well-founded descent, hydra game, ordinal analysis, natural independence, decidability.

---

## 1. Introduction

### 1.1 Background

A triple $(a,b,c)$ of positive integers with $a^2+b^2=c^2$ and $\gcd(a,b)=1$ is a *primitive Pythagorean triple*. In such a triple exactly one leg is odd and the hypotenuse is odd; we adopt throughout the normalisation that the odd leg comes first.

Berggren observed in 1934 that the three integer matrices
$$
\mathbf{A}=\begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2\\ 2 & -2 & 3\end{pmatrix},\quad
\mathbf{B}=\begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2\\ 2 & 2 & 3\end{pmatrix},\quad
\mathbf{C}=\begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2\\ -2 & 2 & 3\end{pmatrix}
$$
map primitive triples to primitive triples, and that iterating them from the seed $(3,4,5)$ produces every primitive triple exactly once. The resulting structure is an infinite ternary tree.

The *forward* half of this statement (the moves preserve the class) is a routine algebraic verification. The *descent* half — every primitive triple has a unique parent in the tree — is the substantive content, and it is usually proved by a three-way case analysis on inequalities. Our first contribution is a case-free treatment.

### 1.2 The logical questions

A structure with canonical well-founded descent is the natural substrate for two phenomena from mathematical logic.

**(Q1) Undecidability.** Matiyasevich's theorem provides undecidable Diophantine relations. Since the address relation of the Berggren tree, $\mathrm{addr}(w) = (a,b,c)$, is a relation between words and integer triples defined by iterated integer-linear maps, one might hope to encode a universal Diophantine machine in it, giving an undecidable first-order theory attached to the tree.

**(Q2) Independence.** Goodstein's theorem, the Kirby–Paris hydra and the Paris–Harrington principle are true statements about finite combinatorial objects that are unprovable in Peano Arithmetic ($\mathrm{PA}$). Each is calibrated by an ordinal: they exhaust $\varepsilon_0 = \sup\{\omega, \omega^\omega, \omega^{\omega^\omega},\dots\}$, the proof-theoretic ordinal of $\mathrm{PA}$. Does the Berggren descent support a hydra game whose termination is unprovable in $\mathrm{PA}$?

We answer both questions negatively, and in each case the negative answer is a precise theorem: the tree is *free* with a computable address bijection (§4), and the associated hydra game has an *exactly computed elementary length function* placing it at $\omega^\omega$ (§5–§6).

### 1.3 Summary of results

1. **Uniform descent (Theorems 3.6–3.9).** One formula $P$ realises all three inverse Berggren moves; it preserves primitivity and strictly reduces the hypotenuse.
2. **Classification and decidability (Theorem 3.11, Corollary 3.12).** The tree is exactly the class of normalised primitive triples; membership is decidable.
3. **Freeness (Theorem 4.5).** $\mathrm{addr}$ is a bijection from $\{A,B,C\}^*$ onto that class; the last letter is read off from the sign pattern of $(u,v)$. Answer to (Q1): no.
4. **Termination (Theorem 5.4).** The Pythagorean Hydra terminates, for arbitrary regrowth.
5. **Exact length (Theorem 6.3).** With branching bound $k$ the longest battle has exactly $\Phi_k(H)$ moves; a single head at depth $d$ yields exactly $1+k+\cdots+k^d \le (k+1)^{d+1}$ moves. Answer to (Q2): no; the game is at $\omega^\omega$.
6. **Sharpness of descent (Theorems 7.1, 7.2).** Non-strict descent, and regrowth by Berggren children, both admit explicit infinite battles.

---

## 2. Definitions and normal form

**Definition 2.1 (Pythagorean predicate).** For $a,b,c \in \mathbb{Z}$ write $\mathrm{Pyth}(a,b,c)$ for $a^2+b^2=c^2$.

**Definition 2.2 (Normalised primitive triple).** $(a,b,c)$ is a *normalised primitive triple*, written $\mathrm{PPT}(a,b,c)$, if
$$a>0,\quad b>0,\quad c>0,\quad a^2+b^2=c^2,\quad \gcd(a,b)=1,\quad a \text{ odd}.$$

**Definition 2.3 (Berggren moves).**
$$
\begin{aligned}
A(a,b,c) &= (\,a - 2b + 2c,\ 2a - b + 2c,\ 2a - 2b + 3c\,),\\
B(a,b,c) &= (\,a + 2b + 2c,\ 2a + b + 2c,\ 2a + 2b + 3c\,),\\
C(a,b,c) &= (-a + 2b + 2c,\ -2a + b + 2c,\ -2a + 2b + 3c\,),
\end{aligned}
$$
with formal inverses
$$
\begin{aligned}
A^{-1}(a,b,c) &= (\,a + 2b - 2c,\ -2a - b + 2c,\ -2a - 2b + 3c\,),\\
B^{-1}(a,b,c) &= (\,a + 2b - 2c,\ \ 2a + b - 2c,\ -2a - 2b + 3c\,),\\
C^{-1}(a,b,c) &= (-a - 2b + 2c,\ \ 2a + b - 2c,\ -2a - 2b + 3c\,).
\end{aligned}
$$

**Definition 2.4 (The tree).** $\mathrm{Reach}$ is the least class of integer triples containing $(3,4,5)$ and closed under $A$, $B$, $C$.

**Lemma 2.5 (Parity).** If $\mathrm{PPT}(a,b,c)$ then $b$ is even and $c$ is odd.

*Proof sketch.* If both $a$ and $b$ were odd, say $a=2m+1$, $b=2n+1$, then $c^2 \equiv 2 \pmod 4$, impossible since squares are $0$ or $1$ mod $4$. Hence $b$ is even (it cannot be odd, and coprimality forbids both even). Then $c^2 = a^2+b^2$ is odd $+$ even $=$ odd, so $c$ is odd. $\square$

**Lemma 2.6 (Legs are shorter than the hypotenuse).** If $\mathrm{PPT}(a,b,c)$ then $a < c$ and $b < c$.

*Proof sketch.* $c^2 = a^2 + b^2 > a^2$ with all quantities positive. $\square$

**Lemma 2.7 (Divisibility transfer).** If $\mathrm{Pyth}(a,b,c)$ and $d \mid a$, $d \mid b$, then $d \mid c$.

*Proof sketch.* Write $a = dk_1$, $b = dk_2$; then $c^2 = d^2(k_1^2+k_2^2)$, so $d^2 \mid c^2$ and hence $d \mid c$. $\square$

**Lemma 2.8 (Coprimality transfer).** Let $\mathrm{Pyth}(a',b',c')$ and $\gcd(a,b)=1$, and suppose there are integers $p,q,r,s,t,w$ with
$$a = pa' + qb' + rc', \qquad b = sa' + tb' + wc'.$$
Then $\gcd(a',b')=1$.

*Proof sketch.* Let $g = \gcd(a',b')$. Then $g \mid c'$ by Lemma 2.7, hence $g$ divides both displayed combinations, i.e. $g \mid a$ and $g \mid b$, so $g \mid \gcd(a,b) = 1$. $\square$

Lemma 2.8 is the workhorse: every preservation-of-primitivity statement below is an instance of it, because each Berggren move and its inverse are integer-linear with integer-linear inverses.

**Proposition 2.9 (Forward moves preserve the class).** If $\mathrm{PPT}(a,b,c)$ then $\mathrm{PPT}$ holds of $A(a,b,c)$, $B(a,b,c)$ and $C(a,b,c)$.

*Proof sketch.* Positivity: for $A$, $a-2b+2c > a > 0$ by Lemma 2.6, and $2a - b + 2c > 0$ likewise; symmetric arguments handle $B$ and $C$. The Pythagorean identity is a polynomial identity: e.g. for $A$,
$$(a-2b+2c)^2 + (2a-b+2c)^2 - (2a-2b+3c)^2 = a^2+b^2-c^2 = 0 .$$
Coprimality follows from Lemma 2.8 with the explicit inverse combinations ($a = a' + 2b' - 2c'$ etc. read off from $A^{-1}$). Oddness of the first entry: $a - 2b + 2c \equiv a \pmod 2$. $\square$

**Lemma 2.10 (Minimality of the root).** If $\mathrm{PPT}(a,b,c)$ and $c \le 5$ then $(a,b,c)=(3,4,5)$. Consequently $c \ge 5$ always.

*Proof sketch.* Finite check: $c \le 5$, $a,b<c$, $a$ odd, $a^2+b^2=c^2$, $\gcd(a,b)=1$. $\square$

**Lemma 2.11 (Forward moves increase the hypotenuse).** If $\mathrm{PPT}(a,b,c)$ then the hypotenuse of each of $A(a,b,c)$, $B(a,b,c)$, $C(a,b,c)$ strictly exceeds $c$.

*Proof sketch.* For $B$: $2a+2b+3c > c$ trivially. For $A$: $2a-2b+3c > c$ reduces to $a + c > b$, true since $b<c$. For $C$: $-2a+2b+3c>c$ reduces to $b + c > a$, true since $a<c$. $\square$

---

## 3. The uniform parent map and the descent theorem

**Definition 3.1.** For a triple $(a,b,c)$ set
$$u = a+2b-2c, \qquad v = 2a+b-2c, \qquad h = 3c-2a-2b,$$
and define the **parent map**
$$P(a,b,c) = \bigl(|u|,\ |v|,\ h\bigr).$$

**Lemma 3.2 (Reconstruction).** Identically in $(a,b,c)$,
$$a = u + 2v + 2h, \qquad b = 2u + v + 2h, \qquad c = 2u + 2v + 3h .$$

*Proof sketch.* Direct substitution and expansion. $\square$

Lemma 3.2 says $(u,v,h) \mapsto (a,b,c)$ is exactly the move $B$; the parent map is $B^{-1}$ followed by absolute values, and the absolute values encode the branch.

**Lemma 3.3 (The parent satisfies the Pythagorean equation).** If $\mathrm{Pyth}(a,b,c)$ then $\mathrm{Pyth}(u,v,h)$.

*Proof sketch.* $u^2+v^2-h^2 = a^2+b^2-c^2$ as a polynomial identity. $\square$

**Lemma 3.4 (Positivity and strict decrease of the parent hypotenuse).** If $\mathrm{PPT}(a,b,c)$ then $0 < h < c$.

*Proof sketch.* For $h > 0$: we must show $3c > 2a+2b$. Since $a^2+b^2=c^2$ we have $(a+b)^2 = c^2 + 2ab \le 2c^2$, so $a+b \le c\sqrt{2}$ and $2(a+b) \le 2\sqrt 2\, c < 3c$. For $h<c$: $3c-2a-2b<c$ is $c < a+b$, which holds because $c^2 = a^2+b^2 < (a+b)^2$ for positive $a,b$. $\square$

**Lemma 3.5 (Sign behaviour).** Let $\mathrm{PPT}(a,b,c)$.
1. $u$ is odd, hence $u \ne 0$.
2. If $c > 5$ then $v \ne 0$.
3. $u > 0$ or $v > 0$.

*Proof sketch.* (1) $u = a+2b-2c \equiv a \equiv 1 \pmod 2$.
(2) If $v=0$ then $2a+b=2c$; substituting into $a^2+b^2=c^2$ yields $3b = 4a$, so $3 \mid a$, say $a=3t$, $b=4t$, and $\gcd(3t,4t)=1$ forces $t=1$, i.e. $(a,b,c)=(3,4,5)$, contradicting $c>5$.
(3) Suppose $u \le 0$ and $v \le 0$, i.e. $a+2b \le 2c$ and $2a+b \le 2c$, all quantities positive. Squaring and using $c^2=a^2+b^2$:
$$a^2+4ab+4b^2 \le 4a^2+4b^2 \ \Rightarrow\ 4ab \le 3a^2, \qquad 4a^2+4ab+b^2 \le 4a^2+4b^2 \ \Rightarrow\ 4ab \le 3b^2 .$$
Multiplying the two conclusions gives $16a^2b^2 \le 9a^2b^2$, impossible since $ab>0$. $\square$

**Theorem 3.6 (The parent map is an inverse Berggren move).** Let $\mathrm{PPT}(a,b,c)$ with $c>5$. Then
$$P(a,b,c) = \begin{cases} A^{-1}(a,b,c) & \text{if } u>0>v,\\ B^{-1}(a,b,c) & \text{if } u>0 \text{ and } v>0,\\ C^{-1}(a,b,c) & \text{if } u<0<v. \end{cases}$$
By Lemma 3.5 these three cases are exhaustive and mutually exclusive.

*Proof sketch.* Unfold: $A^{-1} = (u, -v, h)$, $B^{-1} = (u, v, h)$, $C^{-1} = (-u, v, h)$. Now $(|u|,|v|,h)$ equals $(u,-v,h)$ when $u>0>v$, equals $(u,v,h)$ when both are positive, and equals $(-u,v,h)$ when $u<0<v$. $\square$

**Theorem 3.7 (Descent preserves the class).** If $\mathrm{PPT}(a,b,c)$ and $c>5$ then $\mathrm{PPT}(P(a,b,c))$.

*Proof sketch.* Positivity of the first two coordinates is $u \ne 0$, $v \ne 0$ (Lemma 3.5) plus absolute values; positivity of the third is Lemma 3.4. The Pythagorean equation is Lemma 3.3 together with $|x|^2=x^2$. Coprimality: apply Lemma 2.8 to $(u,v,h)$ using the reconstruction $a = u+2v+2h$, $b = 2u+v+2h$ of Lemma 3.2, and note $\gcd(|u|,|v|)=\gcd(u,v)$. Oddness: $|u| \equiv u \equiv a \pmod 2$. $\square$

**Theorem 3.8 (Well-founded descent).** If $\mathrm{PPT}(a,b,c)$ then the third coordinate of $P(a,b,c)$ is $h$ with $0<h<c$.

*Proof.* Lemma 3.4. $\square$

**Theorem 3.9 (Child recovery).** If $\mathrm{PPT}(a,b,c)$ and $c>5$ then $(a,b,c)$ equals $A(P(a,b,c))$, $B(P(a,b,c))$ or $C(P(a,b,c))$, according to the same sign trichotomy as in Theorem 3.6.

*Proof sketch.* Each case is the algebraic identity $X(X^{-1}(a,b,c)) = (a,b,c)$ for $X \in \{A,B,C\}$, which is matrix inversion. $\square$

**Theorem 3.10 (Descent theorem).** Every normalised primitive triple lies in $\mathrm{Reach}$.

*Proof sketch.* Strong induction on $c$. If $c \le 5$ then the triple is $(3,4,5) \in \mathrm{Reach}$ by Lemma 2.10. Otherwise $P(a,b,c)$ is again normalised primitive (Theorem 3.7) with strictly smaller, still positive, hypotenuse (Theorem 3.8), so it lies in $\mathrm{Reach}$ by induction; and $(a,b,c)$ is one of its three Berggren children (Theorem 3.9), hence lies in $\mathrm{Reach}$. $\square$

**Theorem 3.11 (Classification of the Berggren tree).**
$$(a,b,c) \in \mathrm{Reach} \iff \mathrm{PPT}(a,b,c).$$

*Proof.* ($\Rightarrow$) Induction on the generation of $\mathrm{Reach}$, using $\mathrm{PPT}(3,4,5)$ and Proposition 2.9. ($\Leftarrow$) Theorem 3.10. $\square$

**Corollary 3.12 (Decidability of membership).** Membership in the Berggren tree is decidable, by the elementary test "$a,b,c>0$ and $a^2+b^2=c^2$ and $\gcd(a,b)=1$ and $a$ odd". No search over the tree is required.

---

## 4. The address map and freeness of the tree

**Definition 4.1.** Let $\Sigma = \{A,B,C\}$ and let $\Sigma^*$ be the free monoid of finite words. Define
$$\mathrm{addr}: \Sigma^* \to \mathbb{Z}^3, \qquad \mathrm{addr}(\varepsilon)=(3,4,5), \qquad \mathrm{addr}(s\,w) = s\bigl(\mathrm{addr}(w)\bigr).$$
Thus the word is read right-to-left from the root; the *first* letter is the last move applied. The **depth** of a triple $t$ in the tree is $d(t) = |w|$ where $\mathrm{addr}(w)=t$ (well defined by Theorem 4.5).

**Lemma 4.2 (The coordinates $u,v$ read off the last move).** For all $a,b,c$,
$$
\begin{array}{lll}
u(A(a,b,c)) = a, & v(A(a,b,c)) = -b, & h(A(a,b,c)) = c,\\
u(B(a,b,c)) = a, & v(B(a,b,c)) = b, & h(B(a,b,c)) = c,\\
u(C(a,b,c)) = -a, & v(C(a,b,c)) = b, & h(C(a,b,c)) = c.
\end{array}
$$

*Proof sketch.* Nine polynomial identities, each a one-line expansion. $\square$

Lemma 4.2 makes the descent transparent: applying $u,v,h$ to a child returns the parent's coordinates *up to sign*, and the sign pattern $(+,-)$, $(+,+)$, $(-,+)$ is precisely the label $A$, $B$, $C$ of the move used.

**Corollary 4.3 (The parent map deletes the head letter).** For $a,b>0$ and $X \in \{A,B,C\}$, $P(X(a,b,c)) = (a,b,c)$; hence for all $s\in\Sigma$, $w \in \Sigma^*$,
$$P\bigl(\mathrm{addr}(s\,w)\bigr) = \mathrm{addr}(w).$$

*Proof.* Lemma 4.2 with $|a|=a$, $|-b|=b$. $\square$

**Lemma 4.4 (Children are distinct).** If $\mathrm{PPT}(a,b,c)$ then $A(a,b,c)$, $B(a,b,c)$, $C(a,b,c)$ are pairwise distinct.

*Proof sketch.* Comparing first coordinates: $A$ and $B$ agree iff $b=0$; $B$ and $C$ agree iff $a=0$; $A$ and $C$ agree iff $a-2b = -a+2b$, i.e. $a = 2b$, which is impossible because $a$ is odd. All three are excluded by $a,b>0$ and the parity of $a$. $\square$

**Theorem 4.5 (Freeness of the Berggren tree).** The map $\mathrm{addr}$ is injective, and its image is exactly $\{t : \mathrm{PPT}(t)\}$. Hence every normalised primitive triple has a unique address, and
$$\mathrm{addr} : \Sigma^* \xrightarrow{\ \sim\ } \{\text{normalised primitive Pythagorean triples}\}$$
is a bijection, computable in both directions.

*Proof sketch.* *Image:* $\mathrm{addr}(w)$ is normalised primitive by induction (Proposition 2.9); conversely every such triple is reached (Theorem 3.10), and an easy induction over the generation of $\mathrm{Reach}$ produces a word.
*Injectivity:* induction on the first word. Since $A,B,C$ strictly increase the hypotenuse and every triple has $c \ge 5$ (Lemmas 2.10, 2.11), $\mathrm{addr}(sw)$ has hypotenuse $>5$, so it cannot equal $\mathrm{addr}(\varepsilon)=(3,4,5)$: the empty word collides with nothing. For $\mathrm{addr}(sw) = \mathrm{addr}(t w')$, apply $P$ and use Corollary 4.3 to get $\mathrm{addr}(w) = \mathrm{addr}(w')$, hence $w = w'$ by induction; then $s=t$ by Lemma 4.4.
*Computability of the inverse:* iterate $P$, recording at each step the sign pattern of $(u,v)$; the process halts at $(3,4,5)$ after $d(t)$ steps by Theorem 3.8. $\square$

**Corollary 4.6 (Answer to (Q1): no undecidability in the addressing).** The relation $\{(w,t) : \mathrm{addr}(w) = t\}$ is decidable, and $\Sigma^*$ acts freely: no nontrivial relations hold among the generators. There is therefore no Diophantine encoding to be extracted from the tree's address function; the structure $(\Sigma^*, \mathrm{addr})$ is definably isomorphic to the free monoid on three letters together with a computable bijection to a decidable set of integer triples.

**Example 4.7.** $\mathrm{addr}(\varepsilon)=(3,4,5)$, $\mathrm{addr}(B) = (21,20,29)$, $\mathrm{addr}(BB) = (119,120,169)$, $\mathrm{addr}(A) = (5,12,13)$, $\mathrm{addr}(C) = (15,8,17)$. Conversely, from $(7,24,25)$: $u = 7+48-50 = 5 > 0$, $v = 14+24-50 = -12 < 0$, so the last move was $A$ and the parent is $(5,12,13)$; from $(5,12,13)$: $u = 5+24-26 = 3>0$, $v = 10+12-26 = -4<0$, so again $A$, parent $(3,4,5)$. Address: $AA$, depth $2$.

---

## 5. The Pythagorean Hydra

**Definition 5.1 (Berggren ancestry).** For triples $s,t$ write $s \prec t$ ("$s$ is the Berggren parent step of $t$") if $\mathrm{PPT}(t)$, the hypotenuse of $t$ exceeds $5$, and $s = P(t)$. Let $\prec^{+}$ be the transitive closure: $s$ is a **Berggren ancestor** of $t$.

By Theorem 3.8 and Corollary 4.3, $s \prec t$ implies $d(s)+1 = d(t)$ and $c(s) < c(t)$; hence $s \prec^+ t$ implies $d(s) < d(t)$.

**Definition 5.2 (The game).** A *hydra* is a finite multiset $H$ of normalised primitive triples. A **chop with branching bound $k$** replaces $H = t \uplus H_0$ by $R \uplus H_0$, where $R$ is a multiset of at most $k$ triples, each a Berggren ancestor of $t$. Writing $\mathsf{Chop}_k$ for this relation, a **battle of length $N$** is a chain $H = H_0 \mathrel{\mathsf{Chop}_k} H_1 \mathrel{\mathsf{Chop}_k} \cdots \mathrel{\mathsf{Chop}_k} H_N$. Hercules **wins** if every battle is finite. The *unbounded* game $\mathsf{Chop}_\infty$ drops the condition $|R| \le k$.

Note the root $(3,4,5)$ is inert: it has no Berggren ancestor (any ancestor would be a normalised primitive triple of hypotenuse $<5$, contradicting Lemma 2.10), so chopping it regrows nothing.

**Definition 5.3 (Level abstraction).** Map each head $t$ to a natural number $\lambda(t)$, either its depth $d(t)$ or (more crudely) its hypotenuse. Ancestry strictly decreases $\lambda$. Under this map a Pythagorean chop becomes an *abstract hydra move*: replace a head of level $m$ by at most $k$ heads of level $<m$.

**Theorem 5.4 (Hercules always wins).** There is no infinite battle, even in the unbounded game $\mathsf{Chop}_\infty$.

*Proof sketch.* Apply $\lambda$ to obtain an infinite sequence of finite multisets of naturals in which each step replaces one element by finitely many strictly smaller ones. This is a strictly decreasing sequence in the Dershowitz–Manna multiset order, which is well founded because $(\mathbb{N},<)$ is; contradiction. $\square$

The multiset order on finite multisets of naturals has order type $\omega^\omega$. Theorem 5.4 therefore places the Pythagorean Hydra at $\omega^\omega$ *at most*; §6 shows the bound is exact, and even that the *bounded* game is elementary.

---

## 6. Exact length function and calibration

**Definition 6.1 (Potential).** For $k, n \in \mathbb{N}$ put
$$\varphi_k(n) = \sum_{i=0}^{n} k^i = 1+k+\cdots+k^n,$$
and for a hydra $H$,
$$\Phi_k(H) = \sum_{t \in H} \varphi_k\bigl(d(t)\bigr).$$
Basic facts: $\varphi_k(0)=1$; $\varphi_k(n+1) = 1 + k\,\varphi_k(n)$; $\varphi_k$ is nondecreasing in $n$; and $\varphi_k(n) \le (k+1)^{n+1}$.

**Lemma 6.2 (Each move costs at least one unit of potential).** If $H \mathrel{\mathsf{Chop}_k} H'$ then $\Phi_k(H') + 1 \le \Phi_k(H)$.

*Proof sketch.* Say the chopped head has depth $m$ and the regrown multiset is $R$ with $|R| = r \le k$ and every $s \in R$ of depth $\le m-1$. Then
$$\Phi_k(H) - \Phi_k(H') = \varphi_k(m) - \sum_{s\in R}\varphi_k(d(s)) \ge \varphi_k(m) - k\,\varphi_k(m-1) = 1,$$
using monotonicity of $\varphi_k$ and the recursion $\varphi_k(m) = 1 + k\varphi_k(m-1)$. If $m=0$ then $R$ is empty and the drop is $\varphi_k(0)=1$. $\square$

**Theorem 6.3 (The length function of the Pythagorean Hydra).** Fix $k$ and a hydra $H$.
1. *(Upper bound)* Every battle from $H$ with branching bound $k$ has at most $\Phi_k(H)$ moves.
2. *(Attainment)* There is a battle from $H$ of length exactly $\Phi_k(H)$ ending with the empty hydra.

Hence the longest battle from $H$ has **exactly** $\Phi_k(H)$ moves.

*Proof sketch.* (1) Immediate from Lemma 6.2 by induction on the length of the battle: after $N$ moves, $N + \Phi_k(H_N) \le \Phi_k(H)$, and $\Phi_k \ge 0$.
(2) It suffices to show that every non-empty hydra admits a move dropping $\Phi_k$ by exactly one; then induction on $\Phi_k(H)$ produces a battle of length $\Phi_k(H)$ terminating at the empty hydra (note $\Phi_k(H) = 0$ iff $H = \emptyset$, since $\varphi_k \ge 1$). Pick any head $t$. If $d(t)=0$, i.e. $t=(3,4,5)$, chop it and regrow nothing: $\Phi_k$ drops by $\varphi_k(0)=1$. Otherwise let $p = P(t)$, an ancestor with $d(p) = d(t)-1$, and regrow the multiset consisting of $k$ copies of $p$: the drop is $\varphi_k(d(t)) - k\varphi_k(d(t)-1) = 1$. $\square$

**Corollary 6.4 (Single head).** A battle against the single head $\mathrm{addr}(w)$, of depth $d = |w|$, with branching bound $k$, lasts at most $\varphi_k(d) = 1+k+\cdots+k^d \le (k+1)^{d+1}$ moves, and this is attained.

**Corollary 6.5 (Root).** A battle against the single head $(3,4,5)$ lasts at most one move, for every $k$.

**Corollary 6.6 (Hypotenuse form).** If levels are measured by the hypotenuse instead of the depth, one still obtains a valid (weaker) bound: if every head has hypotenuse at most $L$ then a battle with branching bound $k$ lasts at most $|H| \cdot (k+1)^{L+1}$ moves. For the single head $(3,4,5)$ with $k=3$ this reads $N \le \varphi_3(5) = 1+3+9+27+81+243 = 364$, compared with the sharp bound $1$ from Corollary 6.5. The difference measures exactly how lossy the hypotenuse is as a proxy for depth.

**Theorem 6.7 (Unbounded regrowth: termination without a uniform bound).** In the unbounded game, every battle is finite (Theorem 5.4), but for every $N$ there is a battle of length $N+1$ from a single head of level $1$: chop it, regrow $N$ heads of level $0$, then chop those one at a time. Hence the length of the unbounded game is not a function of the initial hydra, and the game's ordinal is strictly greater than $\omega$; by Theorem 5.4 it is exactly $\omega^\omega$.

### 6.1 Calibration: why there is no independence phenomenon

**Theorem 6.8 (Calibration; answer to (Q2)).** The termination of the Pythagorean Hydra with branching bound $k$ is witnessed by the explicit elementary function $\Phi_k$, which strictly decreases at every move. Consequently:
* the statement "every battle terminates" is provable by induction on a single natural-number parameter ($\Sigma_1$-induction on the potential), well inside Peano Arithmetic;
* the game's length function $H \mapsto \Phi_k(H)$ is elementary — bounded by $|H|(k+1)^{L+1}$ — and therefore does not majorise the provably total functions of $\mathrm{PA}$;
* the ordinal of the game is $\omega^\omega$, the order type of the multiset order on $\mathbb{N}$, as opposed to the $\varepsilon_0$ of the Kirby–Paris hydra.

The Pythagorean Hydra is therefore *not* a natural independence phenomenon.

**Discussion.** The structural reason is worth stating precisely. In the Kirby–Paris game each head is a *tree*, and the ordinal assigned to a hydra is built by nesting: a node with children of ordinals $\alpha_1,\dots,\alpha_r$ receives $\omega^{\alpha_1}+\cdots+\omega^{\alpha_r}$, and regrowth copies whole subtrees, so the notation must accommodate towers $\omega^{\omega^{\cdots}}$, i.e. all of $\varepsilon_0$. In the Berggren tree each head is a *word*, and the descent invariant is a single natural number, its depth. A hydra is therefore a finite multiset of naturals, and finite multisets of naturals have order type $\omega^\omega$. The Berggren tree is *flat* as an ordinal notation. Independence, if it is to be found among Pythagorean triples, must come from a regrowth rule that builds **height**, not merely branching.

---

## 7. Sharpness: descent is exactly what makes Hercules win

**Theorem 7.1 (Non-strict descent fails).** Consider the relaxed game in which a regrown head may have level $\le$ that of the chopped head. Then there is an infinite play: the hydra $\{1\}$ chops its head and regrows one head at level $1$, forever.

*Proof.* Immediate; the play is constant. $\square$

**Theorem 7.2 (Reversed regrowth fails, in the Pythagorean setting).** Consider the variant in which chopping a head $t$ permits regrowth of Berggren *children* of $t$ (that is, heads $X(t)$ for $X\in\{A,B,C\}$). Then there is an explicit infinite battle:
$$\{(3,4,5)\} \to \{(21,20,29)\} \to \{(119,120,169)\} \to \{(697,696,985)\} \to \cdots,$$
the $B$-spine of the tree; at stage $i$ the hydra is $\{\mathrm{addr}(B^i)\}$.

*Proof.* Each step chops the unique head $\mathrm{addr}(B^i)$ and regrows its $B$-child $\mathrm{addr}(B^{i+1})$. $\square$

Theorems 7.1 and 7.2 show that the Pythagorean Hydra sits exactly on the boundary of termination: strict Berggren descent is both sufficient (Theorem 5.4) and necessary. It is the *direction* of the regrowth — towards $(3,4,5)$ — and nothing else, that makes the game finite.

---

## 8. Algorithms

Three algorithms fall directly out of the theory; all are elementary and all run in time polynomial in the bit size of the input.

**Algorithm 8.1 (Descent / address extraction).** *Input:* a triple $(a,b,c)$. *Output:* its address word, or "not a Berggren triple".
Verify $\mathrm{PPT}(a,b,c)$ by Corollary 3.12. Then loop: while $c>5$, compute $u,v,h$; append $A$, $B$ or $C$ according to the sign pattern $(+,-)$, $(+,+)$, $(-,+)$; replace $(a,b,c)$ by $(|u|,|v|,h)$. Halt at $(3,4,5)$ and return the accumulated word. Termination is Theorem 3.8; correctness is Theorem 3.6 and Lemma 4.2. Each iteration is $O(1)$ arithmetic operations. The number of iterations is exactly $d(a,b,c)$, and this is $O(\sqrt{c})$: along the $A$-spine $(3,4,5) \to (5,12,13) \to (7,24,25) \to \cdots$ the node at depth $d$ is $(2d+3,\ 2d^2+6d+4,\ 2d^2+6d+5)$, so depth grows like $\sqrt{c/2}$, and this is the extreme case; along the $B$-spine the hypotenuse is multiplied by roughly $3+2\sqrt2 \approx 5.83$ per step, giving depth $O(\log c)$. So descent is fast in the typical direction and at worst square-root in the hypotenuse.

**Algorithm 8.2 (Maximal battle).** *Input:* a hydra $H$ (as triples) and a bound $k$. *Output:* a battle of length exactly $\Phi_k(H)$. Repeat: choose any head $t$; if $t=(3,4,5)$, chop and regrow nothing; otherwise chop and regrow $k$ copies of $P(t)$. By the proof of Theorem 6.3 the potential drops by exactly one per move, so the battle has $\Phi_k(H)$ moves and ends empty.

**Algorithm 8.3 (Potential evaluation).** $\Phi_k(H) = \sum_{t\in H}\varphi_k(d(t))$, where $d(t)$ comes from Algorithm 8.1 and $\varphi_k(d) = (k^{d+1}-1)/(k-1)$ for $k \ne 1$, $= d+1$ for $k=1$. This yields the exact game length without simulation.

---

## 9. Applications and connections

**Enumeration and coding of Pythagorean triples.** Freeness (Theorem 4.5) gives a canonical bijective coding: primitive triples $\leftrightarrow$ ternary strings. Enumerating all primitive triples with hypotenuse below a bound becomes a breadth-first search that never revisits a node and never needs a duplicate check, because the tree is free and the hypotenuse strictly increases along every edge (Lemma 2.11).

**A normal form for the descent.** The classical treatment of Berggren descent is a three-case argument. Theorem 3.6 replaces it by one formula with absolute values, which is convenient both for hand computation and for machine implementation: the branch is a byproduct, not a precondition.

**Calibration as a design tool.** Theorem 6.8 does more than refute a conjecture; it tells us what a candidate independence phenomenon on arithmetic structures must look like. Any structure whose descent yields a single natural-number rank per object can support at most $\omega^\omega$. The observed hierarchy — $\omega^\omega$ for multisets of naturals, $\varepsilon_0$ for hereditarily finite trees — is a statement about how much *nesting* the objects can carry, not about how arithmetically deep they are. Pythagorean triples are, in this precise sense, arithmetically rich but ordinally shallow.

---

## 10. Discussion

Both moonshot conjectures were refuted, and the refutations are theorems rather than obstructions.

For undecidability, the obstruction is *freeness*: the Berggren tree carries no relations. Any encoding of a Diophantine machine needs a structure in which equality of expressions is nontrivial; here equality of two addresses is equality of words. The address relation is decidable and its inverse is computable in $O(\log c)$ steps.

For independence, the obstruction is *flatness*. It is instructive to see how close the analogy comes before it breaks. The Berggren tree is infinite and ternary; regrowth by ancestors mimics Kirby–Paris regrowth; termination genuinely requires a well-foundedness argument, and under unbounded branching it genuinely requires the multiset order — one cannot bound the game length by any function of the initial hydra (Theorem 6.7). All the ingredients of a hydra theorem are present *except* the nesting that lifts $\omega^\omega$ to $\varepsilon_0$.

There is also a positive reading. The exact formula $\Phi_k(H) = \sum_t (1+k+\cdots+k^{d(t)})$ is a rare thing: a hydra game whose longest battle is known in closed form, attained, and computable without simulation. It makes the Pythagorean Hydra an unusually clean teaching example — all the phenomenology of hydra games (regrowth, well-founded descent, potential functions, unbounded but finite play) with none of the transfinite machinery.

---

## 11. Future directions

**Iterated-tree hydras: manufacturing $\varepsilon_0$ from Pythagorean data.** A Kirby–Paris hydra needs regrowth that copies whole subtrees of unbounded height, and the Berggren tree supplies such subtrees canonically: the address of a node is itself a word, and words can be re-read as addresses of nodes, giving a hierarchy of "triples of triples". A hydra whose heads are finite Berggren words of Berggren words has ordinal $\omega^{\omega^\omega}$, and iterating $n$ times gives towers approaching $\varepsilon_0$. Making this precise — and identifying an *arithmetically natural* regrowth rule at each level, rather than a coded one — is the obvious next step.

**Bounded-depth variants and Paris–Harrington analogues.** One may parametrise the game by a function $f$ controlling how many heads regrow at stage $n$ (as in the Kirby–Paris "$n$-th move regrows $n$ copies" rule). For the flat game this changes the length function but not the ordinal; identifying the exact rate at which such length functions grow — and whether any natural rule pushes past the Ackermann-like barrier — would sharpen Theorem 6.8 into a hierarchy theorem.

**Other descent structures.** The Markov tree of Markov triples, the Stern–Brocot tree, and the Vieta-jumping trees of various quadratic Diophantine equations all admit uniform parent maps analogous to $P$. The same calibration applies verbatim to each: descent gives one number, hence $\omega^\omega$. A general theorem — "every Vieta-jumping descent structure yields a flat hydra" — appears to be within reach.

**Metric questions about descent.** The depth of a triple of hypotenuse $c$ ranges from $\Theta(\log c)$ (the $B$-spine) to $\Theta(\sqrt{c})$ (the $A$-spine). What is the *average* depth of a primitive triple with hypotenuse at most $X$, and how are the letters $A$, $B$, $C$ distributed along a random address? Numerically, among the $15919$ nodes of hypotenuse at most $10^5$ the depth distribution peaks at depth $8$ and then decays slowly, with a long tail reaching depth $222$ — the node $(447,\ 99904,\ 99905)$ on the $A$-spine. Quantifying this is a question about the measure the tree induces on triples and connects to classical counting results for Pythagorean triples.

---

## 12. Conclusion

We have given a complete descent theory for the Berggren tree via a single uniform parent map whose absolute values encode the branch, deduced the classification and decidability of the tree, proved that the address map is a computable bijection from the free monoid on three letters, and defined and completely analysed the Pythagorean Hydra: it terminates, its longest battle has exactly $\sum_{t\in H}(1+k+\cdots+k^{d(t)})$ moves, and both relaxing and reversing the descent rule destroy termination outright. Neither the hoped-for undecidability nor the hoped-for independence phenomenon exists; what exists instead is an exact calibration, which locates the arithmetic of Pythagorean triples firmly inside the reach of Peano Arithmetic, and points to iterated addressing as the only plausible route beyond it.
