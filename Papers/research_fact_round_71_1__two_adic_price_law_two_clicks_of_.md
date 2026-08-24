# The Two-Adic Price Law: Exactly Two Clicks of Visibility, Then Structural Sealing

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

The Price tree is a ternary tree on Euclid parameter pairs $(m,n)$, rooted at $(2,1)$, whose three moves $A:(m,n)\mapsto(m+n,2n)$, $B:(m,n)\mapsto(2m,m-n)$, $C:(m,n)\mapsto(2m,m+n)$ enumerate every primitive Pythagorean triple exactly once. Each node therefore carries a unique *address*, a word over $\{A,B,C\}$, and each node with odd leg $N=m^2-n^2$ is exactly a coprime factorisation $N=pq$ with $p=m-n$, $q=m+n$. We determine, exactly and in both directions, how much of the address is a function of the $2$-adic data of $N$.

Reading the address backwards from the leaf, positions $0$ and $1$ are visible: the letter at position $0$ is $A$ iff $N\equiv 1\pmod 4$, and the letter at position $1$ is $A$ iff $N\bmod 8\in\{1,3\}$; the resulting map from $N\bmod 8\in\{1,3,5,7\}$ to the pair of $A$-nesses is a bijection, and all four values are attained. Positions $2$ and beyond are invisible: for every $t\ge 2$ there exist pairs of valid nodes with *identical* odd legs whose addresses agree in $A$-ness at all positions below $t$ and disagree at $t$. Consequently no function of $N$ whatsoever — hence no residue $N\bmod 2^k$, at any $2$-adic depth $k$ — computes the $A$-ness at any position $t\ge2$. The failure is generic (infinitely many odd legs carry a splitting pair at each position, so no eventually-correct classifier exists) and it survives the addition of the node's depth as free side information (equal-depth splitting pairs exist at every position $t\ge 2$, and infinitely many at $t=2$).

The mechanism explaining both halves is a pair of exact run laws in the odd-pair coordinates $U=p+q=2m$, $V=q-p=2n$: an $A$-step halves $V$ and occurs iff $v_2(U)=1$; a $B$- or $C$-step halves $U$ and occurs iff $v_2(U)\ge2$. Hence non-$A$ steps decrement $v_2(U)$ by one and the first $A$ of the address sits at position $v_2(U)-1$; the residue $N\bmod 2^k$ resolves $v_2(U)$ only up to the trichotomy $\{1,2,\ge3\}$. The $B$-versus-$C$ decision is not a congruence at all but the size comparison $q<3p$, which no residue can see. Information-theoretically, the mutual information between $N\bmod 2^k$ and the pair of youngest letters saturates exactly at modulus $8$.

**Keywords:** Pythagorean triples, Price tree, $2$-adic valuation, coprime factorisation, address words, sealing theorems, residue classifiers, mutual information.

---

## 1. Introduction

### 1.1 Trees of Pythagorean triples

A *primitive Pythagorean triple* is a triple $(a,b,c)$ of positive integers with $a^2+b^2=c^2$ and $\gcd(a,b,c)=1$. Euclid's parametrisation is a bijection between such triples (with $a$ odd) and *Euclid pairs*: pairs $(m,n)$ of coprime integers with $m>n>0$ of opposite parity, via
$$a=m^2-n^2,\qquad b=2mn,\qquad c=m^2+n^2.$$
We call $a=N=m^2-n^2$ the *odd leg*.

Several ternary trees organise the primitive triples. The classical one, due to Berggren, acts by three integer matrices on the triple itself. The Price tree acts instead on the Euclid pair. Its root is $(2,1)$ — the triple $(3,4,5)$ — and its three moves are
$$A:(m,n)\mapsto(m+n,\,2n),\qquad B:(m,n)\mapsto(2m,\,m-n),\qquad C:(m,n)\mapsto(2m,\,m+n).$$
Every Euclid pair is reached from the root by exactly one word over $\{A,B,C\}$; that word is the node's *address*.

### 1.2 The question

The odd leg of a node factors as
$$N=m^2-n^2=(m-n)(m+n)=p\,q,$$
where $p=m-n$ and $q=m+n$ are odd, positive and coprime. Conversely, every coprime factorisation $N=pq$ with $0<p<q$ recovers $m=(p+q)/2$, $n=(q-p)/2$. Thus:

> **The nodes of the Price tree with a given odd leg $N$ are in bijection with the coprime factorisations of $N$.**

This makes the address a *factorisation-sensitive* statistic. If some cheap arithmetic function of $N$ — say a residue $N\bmod 2^k$ — determined a growing prefix of the address, that function would be leaking multiplicative information about $N$ from purely additive data. It is therefore of interest to know precisely how much of the address such data determines. Empirically, two letters are readable. The content of this paper is that two is not an artefact of insufficient effort: it is an exact ceiling, provable in the strongest available sense.

Throughout, positions in an address are counted **backwards from the leaf**: position $0$ is the last letter of the address, position $1$ the second-to-last, and so on. This is the natural indexing, because the tree's moves are inverted from the leaf upward and the arithmetic of the descent is local to the leaf.

### 1.3 Results

Write $\ell_t(P)$ for the letter of node $P$ at position $t$ (defined whenever the address of $P$ has more than $t$ letters), and $v_2$ for the $2$-adic valuation.

**Visibility (two clicks).**

* $\ell_0(P)=A \iff N\equiv1\pmod4$.
* $\ell_1(P)=A \iff N\bmod 8\in\{1,3\}$.
* The map $N\bmod 8 \mapsto \big([\ell_0=A],[\ell_1=A]\big)$ is a bijection $\{1,3,5,7\}\to\{\text{true},\text{false}\}^2$, and all four values occur.

**Sealing (nothing else).**

* For every $t\ge2$ there are valid nodes $P\ne Q$ of depth $>t$ with $N(P)=N(Q)$, with $[\ell_u(P)=A]=[\ell_u(Q)=A]$ for all $u<t$, and with $[\ell_t(P)=A]\ne[\ell_t(Q)=A]$.
* Hence for every $t\ge2$ and every function $f:\mathbb{N}\to\{\text{true},\text{false}\}$, the rule "$\ell_t=A$ iff $f(N)$" is false for some valid node; a fortiori the same holds for $f(N\bmod2^k)$, for every $k$.
* At every $t\ge2$, infinitely many distinct odd legs carry a splitting pair; hence no classifier correct for all sufficiently large $N$ exists either.
* At every $t\ge2$ there are splitting pairs of *equal depth*, so no function of the pair $(N,\text{depth})$ reads any position $t\ge2$; at $t=2$ infinitely many such pairs exist.

**Mechanism.**

* $A$-run law, non-$A$-run law, first-$A$ law, and the dichotomy of the leading run (Section 3).
* $B$ versus $C$ is the size rule $q<3p$ (Section 3.5).

Sections 3–8 give the statements with proof sketches; Section 9 gives the information-theoretic reading; Section 10 records algorithms; Sections 11–12 discuss consequences and open directions.

---

## 2. Definitions and basic facts

**Definition 2.1 (Valid pair).** A pair $(m,n)$ of natural numbers is *valid* if $0<n<m$, $\gcd(m,n)=1$, and $m+n$ is odd (opposite parity). The *root* is $(2,1)$.

**Definition 2.2 (Moves and letters).** The three moves are $A,B,C$ as above. Each is injective and maps valid pairs to valid pairs, and the three images partition the valid pairs other than the root. Consequently every non-root valid pair $P$ has a unique *letter*
$$\mathrm{let}(m,n)=\begin{cases} A & n\text{ even},\\ B & n\text{ odd and } 2n<m,\\ C & n \text{ odd and } 2n>m,\end{cases}$$
(the case $2n=m$ cannot occur for a valid non-root pair), and a unique *parent*
$$\pi(m,n)=\begin{cases}(m-n/2,\;n/2) & n\text{ even},\\ (m/2,\;m/2-n) & n\text{ odd},\;2n<m,\\ (m/2,\;n-m/2) & n\text{ odd},\;2n>m.\end{cases}$$

**Definition 2.3 (Address, depth, position).** The *address* $\mathrm{adr}(P)$ of a valid pair $P$ is the word $\mathrm{let}(\pi^{d-1}P)\cdots\mathrm{let}(\pi P)\,\mathrm{let}(P)$, where $d$ is least with $\pi^{d}P=(2,1)$; $d=|\mathrm{adr}(P)|$ is the *depth*. Following the address from the root reproduces $P$. The *letter at position $t$* is
$$\ell_t(P)=\mathrm{let}\big(\pi^{t}P\big),$$
which is the $t$-th entry of the reversed address whenever $t<|\mathrm{adr}(P)|$.

**Definition 2.4 (Odd leg and odd-pair coordinates).** $N(m,n)=m^2-n^2$. Put $p=m-n$, $q=m+n$, so $N=pq$ with $p,q$ odd and coprime, and
$$U=p+q=2m,\qquad V=q-p=2n.$$

**Lemma 2.5 (Parity and residues).** For a valid pair, exactly one of $m,n$ is even. If $n$ is even then $N\equiv1\pmod4$; if $n$ is odd then $N\equiv3\pmod4$. More precisely, since $m$ odd implies $m^2\equiv1\pmod 8$ and $n$ odd implies $n^2\equiv 1 \pmod 8$:
$$N\bmod 8=\begin{cases}1 & 4\mid n,\\ 5 & n\equiv2\ (4),\\ 3 & n\text{ odd},\ m\equiv2\ (4),\\ 7 & n\text{ odd},\ 4\mid m.\end{cases}$$

*Proof sketch.* Squares of odd numbers are $1$ modulo $8$; $n\equiv2\pmod 4$ gives $n^2\equiv4\pmod{32}$, and $4\mid n$ gives $16\mid n^2$. Substituting into $N=m^2-n^2$ and reducing modulo $8$ gives the four cases. $\square$

**Lemma 2.6 (Depth lower bound).** If the first $L$ iterated parents of a valid $P$ are all different from the root, then $|\mathrm{adr}(P)| \ge L$. In particular, since $m+n\le 3^{\,|\mathrm{adr}(P)|+1}$ for every valid pair, any node with $m+n>27$ has depth at least $3$.

---

## 3. The run mechanism

The entire visible/invisible dichotomy is controlled by two closed-form descent laws.

### 3.1 The $A$-run law

**Lemma 3.1 (Closed form along an $A$-run).** If $n\le m$ and $2^{t}\mid n$, then
$$\pi^{t}(m,n)=\Big(m-n+\frac{n}{2^{t}},\;\frac{n}{2^{t}}\Big).$$

*Proof sketch.* Induction on $t$. The base case is trivial. If $2^{t+1}\mid n$ then in $\pi^{t}(m,n)=(m-n+n/2^t,\,n/2^t)$ the second coordinate $n/2^{t}$ is even, so the parent rule for even second coordinate applies and produces $\big(m-n+n/2^{t}-n/2^{t+1},\,n/2^{t+1}\big)=\big(m-n+n/2^{t+1},\,n/2^{t+1}\big)$. $\square$

**Theorem 3.2 ($A$-run law).** Let $(m,n)$ be valid with $n\le m$ and $2^{t}\mid n$. Then
$$\ell_t(m,n)=A\iff 2^{t+1}\mid n.$$
Consequently, if $n$ is even with $v_2(n)=k$, then $\ell_t(m,n)=A$ for all $t<k$ and $\ell_k(m,n)\ne A$: the leading run of the address (read from the leaf) consists of **exactly $v_2(n)$ letters $A$**.

*Proof sketch.* By Lemma 3.1 the $t$-th ancestor has second coordinate $n/2^{t}$, and its letter is $A$ precisely when that coordinate is even, i.e. when $2^{t+1}\mid n$. $\square$

### 3.2 The non-$A$-run law

**Lemma 3.3 (One step at an odd node).** If $n$ is odd, then $\pi(m,n)=(m/2,\,d)$ where $d=|m/2-n|$; in particular the first coordinate is exactly halved.

**Theorem 3.4 (Non-$A$-run law).** Let $n$ be odd with $0<n<m$ and $2^{t+1}\mid m$. Then $\ell_t(m,n)\ne A$; and if moreover $2^{t+2}\nmid m$ then $\ell_{t+1}(m,n)=A$.

*Proof sketch.* Induction on $t$. For $t=0$: $n$ odd gives $\ell_0\ne A$ immediately; if $m\equiv2\pmod4$ then the parent $(m/2,|m/2-n|)$ has even second coordinate (as $m/2$ and $n$ are both odd), so its letter is $A$. For the inductive step, $4\mid m$ forces the parent $(m/2,d)$ to have $d$ odd, $d<m/2$, and $2^{t+1}\mid m/2$; apply the inductive hypothesis to the parent and use $\ell_{t+1}(P)=\ell_t(\pi P)$. $\square$

### 3.3 The first-$A$ law

**Theorem 3.5 (First-$A$ law).** Let $(m,n)$ be valid with $n$ odd (hence $m$ even) and put $k=v_2(m)$. Then
$$\ell_k(m,n)=A\quad\text{and}\quad \ell_t(m,n)\ne A \ \text{ for all } t<k .$$
Equivalently, in the odd-pair coordinates: with $U=p+q=2m$ and $u_0=v_2(U)\ge2$, the first $A$ of the address sits exactly at position $u_0-1$.

*Proof sketch.* Immediate from Theorem 3.4 applied at $t=k-1$ (for the $A$) and at each $t<k$ (for the non-$A$s), using $2^{t+1}\mid m$ whenever $t<k$. $\square$

**Theorem 3.6 (Leading-run dichotomy).** For every valid $(m,n)$ exactly one of the following holds:

1. $n$ is even, and the address ends (reading from the leaf) with exactly $v_2(n)$ letters $A$ followed by a non-$A$;
2. $n$ is odd, and it ends with exactly $v_2(m)$ non-$A$ letters followed by an $A$.

*Proof sketch.* Opposite parity of $m,n$ makes the two cases exhaustive and exclusive; apply Theorem 3.2 in the first, Theorem 3.5 in the second. $\square$

### 3.4 The valuation bookkeeping

Theorems 3.2 and 3.5 are precisely the statement announced by the mechanism:

> Every ascent step halves exactly one of $U=p+q$ and $V=q-p$. An $A$-step halves $V$ and occurs iff $v_2(U)=1$; a $B$- or $C$-step halves $U$ and occurs iff $v_2(U)\ge2$.

Indeed, $U=2m$ and $V=2n$; the letter is $A$ iff $n$ is even iff $m$ is odd iff $v_2(U)=1$, and the parent of an $A$-node has $V_{\text{parent}}=n=V/2$, while the parent of a $B$- or $C$-node has $U_{\text{parent}}=m=U/2$. So a non-$A$ step decrements $v_2(U)$ by exactly one, and the first $A$ appears when the countdown reaches $1$, i.e. at position $v_2(U)-1$.

Here is the countdown for the node $(41,14)$, address $ABBABA$, read from the leaf:

| position | letter | $v_2(U)$ | $v_2(V)$ |
|---|---|---|---|
| $0$ | $A$ | $1$ | $2$ |
| $1$ | $B$ | $2$ | $1$ |
| $2$ | $A$ | $1$ | $2$ |
| $3$ | $B$ | $3$ | $1$ |
| $4$ | $B$ | $2$ | $1$ |
| $5$ | $A$ | $1$ | $2$ |

### 3.5 $B$ versus $C$ is a size rule

**Theorem 3.7 ($B$/$C$ split).** For a valid pair, with $p=m-n$, $q=m+n$,
$$\mathrm{let}(m,n)=B \iff \big(N\equiv3\!\!\pmod 4 \ \text{ and }\ q<3p\big).$$

*Proof sketch.* $N\equiv3\pmod4$ is equivalent to $n$ odd (Lemma 2.5), i.e. to the letter being $B$ or $C$; within that case the letter is $B$ iff $2n<m$, and $2n<m \iff q-p< \tfrac{p+q}{2} \iff q<3p$. $\square$

Two remarks. First, the second condition is a *pure size comparison between the two factors of $N$*: it is invariant under nothing that a residue can detect, since $N\bmod 2^k$ is unchanged when the factorisation is replaced by another one of the same $N$. Second, it explains the observed rarity of $B$ relative to $C$ in samples where the congruence and the inequality decouple: $\Pr(B)=\Pr(N\equiv3\bmod4)\cdot\Pr(q<3p \mid N\equiv 3 \bmod 4)$, i.e. one half of the probability of the size event when the congruence has probability one half.

---

## 4. The two visible clicks

**Theorem 4.1 (Position $0$).** For every valid $P$: $\ \ell_0(P)=A \iff N(P)\equiv1\pmod4$.

*Proof sketch.* $\ell_0(P)=A$ iff $n$ is even, which by Lemma 2.5 is equivalent to $N\equiv1\pmod4$. $\square$

**Theorem 4.2 (Position $1$).** For every valid $P$: $\ \ell_1(P)=A \iff N(P)\bmod 8\in\{1,3\}$.

*Proof sketch.* Two cases. If $n$ is even, then by Theorem 3.2 $\ell_1=A$ iff $4\mid n$, which by Lemma 2.5 is $N\equiv1\pmod 8$. If $n$ is odd, then by Theorem 3.4 $\ell_1=A$ iff $v_2(m)=1$, i.e. $m\equiv2\pmod4$, which by Lemma 2.5 is $N\equiv3\pmod 8$. $\square$

**Theorem 4.3 (Bijection with $N\bmod 8$).** For every valid $P$,
$$N\equiv1\ (8)\iff(\ell_0=A,\ \ell_1=A),\quad N\equiv5\ (8)\iff(\ell_0=A,\ \ell_1\ne A),$$
$$N\equiv3\ (8)\iff(\ell_0\ne A,\ \ell_1=A),\quad N\equiv7\ (8)\iff(\ell_0\ne A,\ \ell_1\ne A).$$
Moreover all four patterns are attained by nodes of depth $\ge3$: $(17,16)$, $(26,3)$, $(27,2)$, $(28,3)$ realise them. Hence the two youngest $A$-nesses and the residue $N\bmod 8$ determine one another.

*Proof sketch.* Combine Theorems 4.1 and 4.2 with oddness of $N$; the attainment statement is a finite check, the depth bound coming from Lemma 2.6. $\square$

**Theorem 4.4 (Closed form at position $2$).** For a valid non-root $(m,n)$, $\ell_2(m,n)=A$ if and only if
$$\begin{cases} 8\mid n & \text{if } 4\mid n,\\ (m-n/2)\equiv2 \pmod 4 & \text{if } n\equiv2\pmod4,\\ (m/2)\equiv n \pmod 4 & \text{if $n$ odd and } m\equiv2\pmod 4,\\ m\equiv4\pmod 8 & \text{if $n$ odd and } 4\mid m. \end{cases}$$

*Proof sketch.* Four applications of Theorems 3.2 and 3.4, one per case, tracking the parent explicitly one or two steps. $\square$

Theorem 4.4 is the crucial contrast with Theorems 4.1 and 4.2: the criterion for position $2$ is a condition on $(m,n)$ modulo $16$ — that is, on the *node*, not on $N$. Sections 5–8 show that this is unavoidable.

---

## 5. Death at position $2$

### 5.1 The twin family

**Definition 5.1.** For $y\in\mathbb{N}$ put
$$X(y)=(3y+5,\;3y+4),\qquad Y(y)=(y+3,\;y).$$

**Lemma 5.2.** $X(y)$ is valid for $y>0$, and $Y(y)$ is valid for $y>0$ with $3\nmid y$. Both have odd leg
$$N(X(y))=N(Y(y))=6y+9 .$$

*Proof sketch.* $(3y+5)^2-(3y+4)^2=6y+9$ and $(y+3)^2-y^2=6y+9$; the coprimality of $X(y)$ is immediate from consecutive coordinates, and $\gcd(y+3,y)=\gcd(3,y)=1$ exactly when $3\nmid y$; parities alternate in both cases. $\square$

The two nodes are the coprime factorisations $N=1\cdot N$ and $N=3\cdot\frac{N}{3}$ of the same odd number.

**Theorem 5.3 (The twins split position $2$).** For $y\ge9$ with $3\nmid y$,
$$[\ell_2(X(y))=A]\ \ne\ [\ell_2(Y(y))=A].$$

*Proof sketch.* Both nodes are valid and non-root, so Theorem 4.4 applies to each. Substituting $(3y+5,3y+4)$ and $(y+3,y)$ into the four-case criterion turns it into a statement about $y$ modulo $16$, and in each of the resulting cases exactly one of the two criteria holds. $\square$

Since the twins share their odd leg, Theorems 4.1–4.2 force their letters at positions $0$ and $1$ to agree; so they agree exactly where the residue can see, and disagree at the first position where it cannot. The smallest instance is $N=33$: the nodes $(7,4)$ with address $BAA$ and $(17,16)$ with address $AAAA$.

### 5.2 Reaching every $2$-adic cell

**Lemma 5.4 ($3$ is invertible $2$-adically).** For every $k$ there are $u,s$ with $3u=1+2^{k}s$.

*Proof sketch.* Induction on $k$: given $3u=1+2^{k}s$, either $s$ is even and the same $u$ works for $k+1$, or replacing $u$ by $u+2^{k}$ makes the new $s$ even. $\square$

**Lemma 5.5 (Hitting an arbitrary class arbitrarily far out).** For all $k$, all bounds $M$, and every odd $r$, there is $y>M$ with $3\nmid y$ and $6y+9\equiv r \pmod{2^{k}}$.

*Proof sketch.* Solve $3w\equiv r \pmod{2^{k+1}}$ with $w$ odd and large using Lemma 5.4, write $w=2y_0+3$, and note $6y_0+9=3w\equiv r$. If $3\mid y_0$, replace $y_0$ by $y_0+2^{k}$: this preserves the congruence modulo $2^{k}$ and changes the residue of $y_0$ modulo $3$, because $2^{k}\not\equiv0 \pmod 3$. $\square$

### 5.3 The sealing theorems at position 2

**Theorem 5.6 (Every $2$-adic cell is split).** For every $k$ and every odd $r$ there are valid nodes $P,Q$ of depth $\ge3$ with
$$N(P)=N(Q)\equiv r \pmod{2^{k}},\quad [\ell_0(P)=A]=[\ell_0(Q)=A],\quad [\ell_1(P)=A]=[\ell_1(Q)=A],$$
$$\text{and}\quad [\ell_2(P)=A]\ne[\ell_2(Q)=A].$$

*Proof sketch.* Take $P=X(y)$, $Q=Y(y)$ for $y$ supplied by Lemma 5.5 with $M=13$; validity is Lemma 5.2, the depth bound is Lemma 2.6, agreement at $0,1$ follows from equal odd legs, and the split is Theorem 5.3. $\square$

**Theorem 5.7 (No odd-leg classifier at position $2$).** For every $f:\mathbb{N}\to\{\text{true},\text{false}\}$ it is false that
$$\ell_2(P)=A \iff f(N(P))\quad\text{for all valid } P \text{ of depth} \ge 3 .$$

*Proof sketch.* Apply $f$ to the two nodes of Theorem 5.6; they have equal odd legs but opposite $A$-nesses at position $2$. $\square$

**Corollary 5.8 (No residue classifier).** For every $k$ and every $f$, the rule "$\ell_2=A$ iff $f(N\bmod2^{k})$" fails. (Apply Theorem 5.7 to $N\mapsto f(N\bmod2^{k})$.)

**Corollary 5.9 (Zero conditional determinacy).** For every node $P$ and every $k$, the $2$-adic cell of $P$ — the set of nodes whose odd leg is congruent to $N(P)$ modulo $2^k$ — contains two nodes with opposite $A$-nesses at position $2$. In probabilistic language: the conditional law of the third letter given the whole $2$-adic residue is never degenerate, at any depth of the filtration.

**Theorem 5.10 (Capacity exactly two).** For every $k$ and odd $r$: inside the cell $\{N\equiv r \bmod 2^{k+3}\}$ the $A$-nesses at positions $0$ and $1$ are constant (they are read off $r\bmod 8$), while the $A$-ness at position $2$ still takes both values. Refining the modulus past $8$ therefore adds no information about the address.

---

## 6. Sealing at every position $t\ge2$

Position $2$ is only the first sealed position. The next family seals them all simultaneously.

**Definition 6.1.** For $s\ge0$ put $t=s+2$, $W_s=10\cdot2^{s}-3$ (odd, $\ge7$) and
$$X_s=\big(2^{t}W_s+1,\;2^{t}W_s\big),\qquad Y_s=\big(12\cdot2^{s}-1,\;2^{t+1}\big).$$

**Lemma 6.2.** $X_s$ and $Y_s$ are valid, both have depth $>t$, and
$$N(X_s)=N(Y_s)=2\cdot 2^{t}W_s+1=80\cdot4^{s}-24\cdot2^{s}+1 .$$
The sequence of common odd legs begins $57,\,273,\,1185,\,4929,\,20097,\,81153,\dots$

*Proof sketch.* $X_s$ has consecutive coordinates, so it is coprime and its odd leg is $2\cdot2^{t}W_s+1$. For $Y_s$, the first coordinate is odd, hence coprime to the power of two in the second, and $(12\cdot2^{s}-1)^2-(2^{s+3})^2 = 144\cdot4^s - 24\cdot 2^s + 1 - 64\cdot 4^s = 80\cdot 4^s - 24\cdot 2^s+1$, which equals $2\cdot2^{t}W_s+1$ because $2^{t+1}W_s = 8\cdot 2^s(10\cdot 2^s - 3) = 80\cdot 4^s - 24 \cdot 2^s$. The depth bound comes from Lemma 2.6 together with the closed form of Lemma 3.1: all iterated parents up to level $t$ have second coordinate $\ge2$, hence differ from the root. $\square$

**Lemma 6.3 (Valuations).** $v_2\big((X_s)_2\big)=t$ exactly (because $W_s$ is odd) and $2^{t+1}\mid (Y_s)_2$.

**Theorem 6.4 (Splitting at position $t$).** For all $u<t$, $\ell_u(X_s)=\ell_u(Y_s)=A$, and $\ell_t(X_s)\ne A$ while $\ell_t(Y_s)=A$.

*Proof sketch.* Both nodes have second coordinate at most the first, so Theorem 3.2 applies at every level at which the relevant power of two divides that coordinate. For $u<t$ we have $2^{u+1}\mid 2^{t}W_s$ and $2^{u+1}\mid 2^{t+1}$, so both letters at position $u$ are $A$. At $u=t$: $\ell_t(X_s)=A$ would require $2^{t+1}\mid 2^{t}W_s$, impossible since $W_s$ is odd; while $\ell_t(Y_s)=A$ holds because $2^{t+1}\mid (Y_s)_2=2^{t+1}$. $\square$

**Theorem 6.5 (Sealing at all positions).** For every $t\ge2$ and every $f:\mathbb{N}\to\{\text{true},\text{false}\}$, the rule "$\ell_t(P)=A$ iff $f(N(P))$" fails for some valid node of depth $>t$. Consequently, for every $k$, no rule of the form "$\ell_t=A$ iff $f(N\bmod 2^{k})$" is correct.

*Proof sketch.* Write $t=s+2$ and feed Theorem 6.4's pair to $f$: equal odd legs, opposite conclusions. $\square$

Together with Theorems 4.1–4.3 this is the **Two-Adic Price Law** in exact form:

> The $2$-adic reading of a Price address has exactly two clicks, $N\bmod4$ and $N\bmod 8$, and is structurally blind from position $2$ onwards.

---

## 7. Sealing is generic, not sporadic

A classifier might still hope to be correct for all but finitely many odd legs. It cannot.

**Definition 7.1 (Two-parameter family).** For $s,v\ge0$ set
$$K_{s,v}=2^{s+1}\big(4v^2+12v+5\big)+(2v+3)\quad(\text{odd},\ \ge13),$$
$$\mathcal{X}_{s,v}=\big(2^{s+2}K_{s,v}+1,\;2^{s+2}K_{s,v}\big),\qquad \mathcal{Y}_{s,v}=\big(2^{s+2}(2v+3)+1,\;2^{s+3}\big),$$
with common odd leg $\ \mathcal{N}_{s,v}=2^{s+3}K_{s,v}+1$.

**Lemma 7.2 (Two reusable tools).**
1. *(Depth from a valuation.)* A valid $(m,n)$ with $2^{L}\mid n$ and $n/2^{L}\ge2$ has depth $\ge L+1$.
2. *(Splitting from a valuation gap.)* If $P,Q$ are valid with $v_2(P_2)=t$ exactly and $2^{t+1}\mid Q_2$, then $\ell_u(P)=\ell_u(Q)=A$ for all $u<t$ and $[\ell_t(P)=A]\ne[\ell_t(Q)=A]$.

*Proof sketch.* (1) By Lemma 3.1 the iterated parents up to level $L$ have second coordinate $n/2^{u}\ge2$, so none is the root; apply Lemma 2.6. (2) Theorem 3.2 applied to both nodes. $\square$

**Theorem 7.3 (Infinitely many splitting odd legs at each position).** For every $t=s+2\ge2$, the family $\{\mathcal{N}_{s,v}\}_{v\ge0}$ consists of pairwise distinct odd legs, each of which carries a pair of valid nodes of depth $>t$ that agree in $A$-ness below $t$ and disagree at $t$. Hence the set of odd legs carrying a splitting pair at position $t$ is infinite.

*Proof sketch.* Validity and equal odd legs are direct computations ($\mathcal{X}$ has consecutive coordinates; $\mathcal{Y}$ has odd first coordinate and a power of two second coordinate). The valuations are exactly $s+2$ and at least $s+3$, so Lemma 7.2(2) applies; the depths come from Lemma 7.2(1). Finally $K_{s,v}$, hence $\mathcal{N}_{s,v}$, is strictly increasing in $v$ and exceeds $v$, so the odd legs are distinct and unbounded. $\square$

**Corollary 7.4 (No eventually correct classifier).** For every $t\ge2$, every bound $B$ and every $f$, the rule "$\ell_t=A$ iff $f(N)$" fails at some valid node whose odd leg exceeds $B$; likewise for $f(N\bmod2^{k})$, for every $k$.

---

## 8. The depth is not the missing bit

The depth $|\mathrm{adr}(P)|$ is genuinely extra information: it is not a function of $N$. Does the pair $(N,\text{depth})$ unlock the address? No — and the proof is cleanest when the two nodes are specified **by their addresses**, which makes their depths equal by construction and reduces everything to one odd-leg identity.

**Definition 8.1 (Equal-depth family).** For $s\ge0$ put $t=s+3$ and consider the two words of the same length $2t$:
$$\mathcal{W}^{X}_{t}=A^{\,t-1}\,B\,A^{\,t},\qquad \mathcal{W}^{Y}_{t}=C\,A^{\,t-3}\,C\,A^{\,t+1}.$$

**Lemma 8.2 (Evaluation).** Following $\mathcal{W}^X_t$ and $\mathcal{W}^Y_t$ from the root yields
$$\mathcal{X}^{d}_{t}=\big(2^{t+1}+1,\;2^{t}\big),\qquad \mathcal{Y}^{d}_{t}=(M_t+1,\;M_t),\quad M_t=2^{t+1}\big(3\cdot2^{t-2}+1\big),$$
and both have odd leg
$$\mathcal{N}^{d}_{t}=2M_t+1=3\cdot2^{2t}+2^{t+2}+1 .$$

*Proof sketch.* Iterating $A$ has the closed form $A^{k}(m,n)=(m+(2^{k}-1)n,\,2^{k}n)$, which reduces both evaluations to a short computation. The odd leg of $\mathcal{X}^d_t$ is $(2^{t+1}+1)^2-(2^{t})^2=3\cdot2^{2t}+2^{t+2}+1$, and $\mathcal{Y}^d_t$ has consecutive coordinates, so its odd leg is $2M_t+1$, which is the same number. $\square$

**Theorem 8.3 (Equal-depth splitting pairs at every position).** For every $t\ge2$ there are valid nodes $P\ne Q$ with $N(P)=N(Q)$, $|\mathrm{adr}(P)|=|\mathrm{adr}(Q)|>t$, $[\ell_u(P)=A]=[\ell_u(Q)=A]$ for $u<t$, and $[\ell_t(P)=A]\ne[\ell_t(Q)=A]$.

*Proof sketch.* For $t\ge3$ take $\mathcal{X}^d_t$ and $\mathcal{Y}^d_t$: their addresses are the two words of Definition 8.1, hence of equal length $2t>t$; the second coordinates have $2$-adic valuations exactly $t$ and exactly $t+1$, so Lemma 7.2(2) gives the required agreement and split. For $t=2$ the explicit pair $(13,8)$ and $(53,52)$ works: both have odd leg $105$ and depth $5$, with addresses $ABAAA$ and $CACAA$. $\square$

**Theorem 8.4 (Depth-augmented sealing).** For every $t\ge2$ and every $f:\mathbb{N}\times\mathbb{N}\to\{\text{true},\text{false}\}$, the rule
$$\ell_t(P)=A \iff f\big(N(P),\,|\mathrm{adr}(P)|\big)$$
fails at some valid node of depth $>t$. In particular no $(N\bmod2^{k},\text{depth})$ classifier works, for any $k$.

*Proof sketch.* The two nodes of Theorem 8.3 have the same odd leg and the same depth, so $f$ returns the same value on both, while their $A$-nesses at $t$ differ. $\square$

**Theorem 8.5 (Infinitely many equal-depth pairs at position $2$).** With $C_j=3\cdot2^{j+1}+1$ set
$$\mathcal{X}^{e}_{j}=(4C_j+1,\;4C_j),\qquad \mathcal{Y}^{e}_{j}=\big(2^{j+3}+3,\;2^{j+3}\big),$$
the values of the words $C\,A^{j}\,C\,A^{2}$ and $B\,A^{\,j+3}$, both of length $j+4$. They have the common odd leg $3\cdot2^{j+4}+9$, equal depth, and split at position $2$. Since the odd legs are strictly increasing in $j$, infinitely many odd legs carry an equal-depth splitting pair at position $2$; consequently no eventually correct $(N,\text{depth})$ classifier exists at position $2$ either.

The smallest equal-depth witnesses found by exhaustive search over odd $N<10^5$ and all their coprime factorisations agree with the families above:

| position $t$ | odd leg | nodes | common depth |
|---|---|---|---|
| $2$ | $57$ | $(29,28)$, $(11,8)$ | $4$ |
| $3$ | $105$ | $(13,8)$, $(19,16)$ | $5$ |
| $4$ | $833$ | $(33,16)$, $(417,416)$ | $8$ |
| $5$ | $2697$ | $(61,32)$, $(451,448)$ | $9$ |
| $6$ | $12545$ | $(129,64)$, $(6273,6272)$ | $12$ |
| $7$ | $47625$ | $(253,128)$, $(7939,7936)$ | $13$ |

---

## 9. The information-theoretic reading

Fix a population of nodes and regard the odd leg $N$ and the address as random variables. Define the *residue capacity at depth $k$* as the mutual information
$$I_k=I\big(N\bmod 2^{k}\;;\;([\ell_0=A],[\ell_1=A])\big).$$

Three structural facts control $I_k$ for any population:

1. **Determinacy above $8$.** By Theorem 4.3 the pair of $A$-nesses is a function of $N\bmod 8$; hence $I_k=H\big([\ell_0=A],[\ell_1=A]\big)$ for every $k\ge3$: the curve is exactly flat past modulus $8$.
2. **Strict increase below $8$.** $N$ is always odd, so $I_1=0$; and $N\bmod4$ determines only the first of the two bits, so $I_2 = H([\ell_0=A]) < I_3$ whenever the second bit is not almost surely constant.
3. **No gain from position $2$.** By Theorem 5.7 and Corollary 5.9, adjoining $[\ell_2=A]$ to the address side cannot raise the ceiling in any population whose $2$-adic cells are split — which, by Corollary 5.9, is every cell.

Taking as population the $3^{9}=19{,}683$ nodes at distance $9$ from the root (so that each address letter is uniform on $\{A,B,C\}$ and independent of the others), one measures, in bits:

| modulus $2^k$ | $2$ | $4$ | $8$ | $16$ | $32$ | $64$ | $128$ |
|---|---|---|---|---|---|---|---|
| $I(N\bmod2^k;\ \ell_0,\ell_1)$ | $0.000$ | $0.918$ | $1.837$ | $1.837$ | $1.837$ | $1.837$ | $1.837$ |
| $I(N\bmod2^k;\ \ell_0,\ell_1,\ell_2)$ | $0.000$ | $0.918$ | $1.837$ | $1.837$ | $1.837$ | $1.837$ | $1.837$ |

The saturation value is $2H(1/3)=2\log_23-\tfrac43\approx1.8366$ bits — exactly two independent letters' worth of $A$-ness, no more. The location of the knee, modulus $8$, is population-independent; the height depends on the sampling measure, and a different measure (for instance uniform over triples up to a size bound) yields a different height but the same knee.

The same phenomenon can be phrased as a degeneracy statement, which is how it appeared in the experimental record: conditional permutation nulls for the letter at position $t$, computed inside prefix cells determined by $N\bmod 2^{k}$, have *zero variance* for $t\le1$ (the letters are constant in each cell by Theorem 4.3) and are uninformative for $t\ge2$ (the cells are always split by Corollary 5.9). Nothing in between exists.

---

## 10. Algorithms

Four routines suffice to compute everything in this paper; all run in time linear in the depth of the node, i.e. logarithmic in $m+n$.

**Address extraction.** Given a valid $(m,n)$, repeatedly emit $\mathrm{let}(m,n)$ and replace $(m,n)$ by $\pi(m,n)$ until the root is reached. The address is the reversed emission. Because $m+n$ is at least halved every two steps (indeed $\pi$ either halves $m$ or reduces $n$ to $n/2$), the loop runs $O(\log(m+n))$ times, each step costing $O(1)$ arithmetic operations.

**Prefix prediction from the residue.** Given only $N$, output the two visible letters' $A$-nesses: $[\ell_0=A]=[N\equiv1\ (4)]$, $[\ell_1=A]=[N\bmod 8\in\{1,3\}]$. Constant time, and — by Theorem 6.5 — this is the *maximal* output any such routine can produce correctly.

**Splitting-pair generator.** Given a target position $t\ge2$, return the pair of Definition 6.1 with $s=t-2$ (odd-leg-only sealing) or the pair of Definition 8.1 (equal-depth sealing). Constant time up to the cost of arithmetic on $2^{t}$-sized integers, and each call refutes an entire class of candidate classifiers.

**Exhaustive splitting search.** Enumerate valid pairs with $m<X$, bucket them by odd leg, and report buckets containing two nodes of depth $>t$ with opposite $A$-nesses at position $t$. This is the empirical counterpart of the families and confirms them: at $t=2$ there are $3{,}255$ such pairs among nodes with $m<300$ and $6{,}124$ among nodes with $m<400$, the smallest odd leg being $33$.

---

## 11. Discussion

### 11.1 Why exactly two

The two run laws say that the address near the leaf is a deterministic function of the single quantity $u_0=v_2(U)=v_2(p+q)$ together with the size comparisons that separate $B$ from $C$. The residue $N\bmod 2^{k}$ can see $u_0$ only through the trichotomy $u_0=1$, $u_0=2$, $u_0\ge3$ — the first two of which pin $\ell_0$ and $\ell_1$. Finer information about $u_0$ would have to be extracted from $N=pq$, but that reconstruction is quadratic: $N=\left(\frac{U}{2}\right)^2-\left(\frac{V}{2}\right)^2$, and squaring destroys the higher bits' correspondence. The splitting families of Sections 6–8 are the explicit certificates that this loss is total, not partial: for every candidate rule, two nodes with the same $N$ (and, if desired, the same depth) disagree exactly where the rule must decide.

### 11.2 The which-factor wall

Because nodes with a given odd leg are coprime factorisations of it, a classifier for a deep address position would be a *factor-discriminating* function of $N$ (or of $N$ and the depth). All such classifiers are refuted here. This places the Price address in the same family as other "sealed residue dials": cheap descriptions that reveal a bounded number of bits and are then factor-blind. The $B$/$C$ rule of Theorem 3.7 exhibits the wall in its purest form, since it is literally a comparison of the sizes of the two factors, a quantity invariant under no congruence.

### 11.3 Two trees, one map

The companion question for the classical Berggren tree of primitive triples concerns $3$-adic rather than $2$-adic data, and there the seal is total from position $0$: the first letter is already not a function of the relevant residue class, and magnitude probes do not help. The present results complete the corresponding picture for the Price tree: exactly two visible clicks at the prime $2$, then structural sealing at every subsequent position, against the odd leg, against every $2$-adic residue, and against the depth. The pair of statements suggests that "number of visible clicks" is a genuine invariant of a triple tree and its associated prime, determined by how many bits of the descent invariant survive the nonlinear reconstruction of $N$ from the descent coordinates.

### 11.4 Scope and limitations

The negative results are about functions of $N$ (or of $(N,\text{depth})$) alone. They say nothing about classifiers with access to a *factorisation* of $N$ — indeed, given the factorisation the node is determined and the whole address is computable in logarithmic time. Nor do they preclude statistical statements: they preclude *correct* rules, and, via Corollary 5.9, the degeneracy of conditional laws, but the distribution of $\ell_t$ given a residue class is a legitimate object which these theorems show to be non-degenerate rather than compute.

---

## 12. Future directions

**Two-sided adic budget for triple trees.** The visible prefix length appears to be governed not by the prime itself but by how many bits of the descent invariant survive the nonlinear reconstruction of the odd leg from the descent coordinates: zero visible clicks at $3$ for the Berggren tree, exactly two at $2$ for the Price tree. Making "number of visible clicks" a computable function of the valuation drop per step, for a general triple tree and a general prime, is the natural next theorem.

**Beyond residues and depth.** The sealing proofs consume exactly two pieces of cheap data, the odd leg and the depth. A systematic classification of which additional cheap statistics (the even leg modulo powers of two, the hypotenuse, the size of $m$, the number of prime factors of $N$) are still defeated by an equal-statistic splitting family would delimit the wall precisely.

**Quantitative density of splitting legs.** The two-parameter family produces splitting odd legs of quadratic growth, hence density zero along that family alone; exhaustive search suggests a positive density of odd legs carrying a splitting pair at position $2$. Determining the true density, and its dependence on the position $t$, is open.

**Distributions rather than rules.** Since the conditional law of $\ell_t$ given $N\bmod 2^{k}$ is never degenerate for $t\ge2$, one may ask for its limit. Is it the uniform-over-the-tree law $(1/3,1/3,1/3)$, and how fast does it converge as $k$ grows?

**The reverse direction.** All statements here read the address from the leaf. Reading from the root is a different filtration, adapted to the size of the node rather than to its $2$-adic structure; the corresponding visibility question — how much of the *initial* segment of the address is a function of cheap data — remains untouched.

---

## Appendix: worked examples

**A. Two triangles, one number.** $105=1\cdot105=3\cdot35=5\cdot21=7\cdot15$. The four coprime factorisations give four nodes: $(53,52)$, $(19,16)$, $(13,8)$ and $(11,4)$, with addresses $CACAA$, $BAAAA$, $ABAAA$ and $CBAA$. Since $105\equiv1\pmod 8$, all four have $A$ at positions $0$ and $1$ — the two visible clicks, identical as they must be. At position $2$ they already disagree: $(13,8)$ and $(19,16)$ read $A$, while $(53,52)$ reads $C$ and $(11,4)$ reads $B$. And $(13,8)$, $(19,16)$ — which agree at positions $0,1,2$ and even share the depth $5$ — disagree at position $3$. One number, one depth, two irreconcilable histories.

**B. The countdown.** The node $(41,14)$: $U=2\cdot41=82$, $v_2(U)=1$, so the leaf letter is $A$ — consistent with $N=41^2-14^2=1485\equiv1\pmod4$. Its parent is $(34,7)$: $U=68$, $v_2=2$, so the letter is not $A$ and the first $A$ above it sits one step up. The full address is $ABBABA$.

**C. Sealing certificate at $t=4$.** $X_2=(2^{4}\cdot37+1,\,2^{4}\cdot37)=(593,592)$ and $Y_2=(47,\,32)$ both have odd leg $1185$; $v_2(592)=4$ exactly, $v_2(32)=5$, so their addresses are all-$A$ at positions $0,1,2,3$ and split at position $4$. Any rule "$\ell_4=A$ iff $f(1185)$" is therefore wrong on one of them.
