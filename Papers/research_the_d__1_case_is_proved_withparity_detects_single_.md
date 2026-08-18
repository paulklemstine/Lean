# Bounds, Rigidity and Perfection for Binary Codes: A Complete Development over Words of Bounded Length

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

We develop the combinatorial theory of binary block codes from first
principles in a model where a word is a finite sequence of bits and the
Hamming distance is defined by coordinatewise comparison over the common
prefix. Working in this model we prove, in a single coherent chain: the
Hamming ball counting lemma $V(n,r) = \sum_{i \le r}\binom{n}{i}$ and
the homogeneity of the cube; the sphere-packing bound; the Singleton
bound $|C| \le 2^{\,n+1-d}$ obtained by puncturing; the
Gilbert–Varshamov existence bound obtained by greedy maximality; and the
Plotkin bound $|C|(2d - n) \le 2d$ for $n < 2d$ obtained by double
counting the total pairwise distance. On the algebraic side we show that
coordinatewise XOR makes the set of length-$n$ words a metric group —
distance is the weight of the difference and translation is an isometry
— and deduce that for a linear code minimum distance coincides with
minimum nonzero weight. Three exact results follow. (i) *Rigidity*: a
length-$(n+1)$ code of minimum distance $2$ and maximal size $2^n$ is
either the even-weight code or the odd-weight code, and nothing else;
the proof uses connectivity of the Hamming cube under single flips.
(ii) *Perfection*: a perfect single-error-correcting binary code of
length $n$ exists **if and only if** $n+1$ is a power of two; necessity
is a divisibility argument extracted from the equality case of sphere
packing, and sufficiency is a construction of the Hamming code of order
$k$ via a syndrome defined as the XOR of the indices of the nonzero
coordinates, requiring no linear algebra. (iii) *Odd/even collapse*: for
odd $d$ the extremal function satisfies $A(n,d) = A(n+1,d+1)$, via
mutually inverse extension and puncturing maps; the parity hypothesis is
necessary, as $A(4,3) < A(3,2)$. Consequences include
$A(n+1,2) = 2^n$, $A(2^k-1,3) = 2^{\,2^k-1-k}$, $A(7,3) = 16$,
$A(8,4) = 16$ and $A(2^k,4) = 2^{\,2^k-1-k}$.

**Keywords:** Hamming distance, sphere-packing bound, Singleton bound,
Gilbert–Varshamov bound, Plotkin bound, perfect codes, Hamming codes,
extremal function $A(n,d)$, parity code, linear codes.

---

## 1. Introduction

### 1.1 The problem

Let $\mathbb{F}_2^n$ denote the set of binary words of length $n$,
equipped with the **Hamming distance** $d(x,y) = |\{ j : x_j \neq y_j\}|$.
A **code** of length $n$ is a subset $C \subseteq \mathbb{F}_2^n$; its
**minimum distance** is the least distance between distinct codewords. A
code of minimum distance $d$ detects any pattern of at most $d-1$ errors
and corrects any pattern of at most $\lfloor (d-1)/2 \rfloor$ errors.
The fundamental extremal quantity is
$$A(n,d) \;=\; \max\{\, |C| \;:\; C \subseteq \mathbb{F}_2^n,\ C \text{ has minimum distance} \ge d \,\}.$$

Determining $A(n,d)$ exactly is open in general; the theory consists of
upper bounds (packing-type and counting-type), lower bounds
(construction-type), exact values in special families, and structural
results explaining relations between different parameter pairs. This
paper gives a complete, self-contained development of the binary
classical core of that theory, together with three exact theorems —
a rigidity classification, a perfection characterisation, and a
collapse identity — that are the principal contributions.

### 1.2 The word model and the length hypothesis

We work with words as *finite sequences of bits of unrestricted length*,
comparing two words coordinatewise as far as both extend. Concretely,
for words $x, y$,
$$d(x,y) \;=\; \#\{\, j < \min(|x|,|y|) \;:\; x_j \neq y_j \,\}.$$
This makes $d$ total and symmetric but only a *pseudometric-like*
quantity in general: the triangle inequality
$d(x,y) \le d(x,z) + d(z,y)$ can fail if the three words have different
lengths, since a short intermediate word $z$ truncates the comparison.
For instance, with $x = 00$, $y = 11$ and $z$ the empty word,
$d(x,y) = 2$ while $d(x,z) + d(z,y) = 0$.

Consequently **every metric statement below carries an explicit
equal-length hypothesis**, and this is not a technicality: it is exactly
the hypothesis under which the truncation phenomenon disappears. We
write
$$W_n \;=\; \{\, x : |x| = n \,\}$$
for the set of length-$n$ words, so $|W_n| = 2^n$. A code of length $n$
is a finite subset $C \subseteq W_n$.

Two basic facts hold without any hypothesis, and one with:

* $d(x,y) = d(y,x)$, and $d(x,y) \le \min(|x|,|y|)$;
* if $|x| = |y|$ and $d(x,y) = 0$ then $x = y$;
* **(triangle inequality)** if $|x| = |y| = |z|$ then
  $d(x,y) \le d(x,z) + d(z,y)$.

A third fact drives several proofs:

**Lemma 1.1 (Additivity over concatenation).** If $|x| = |y|$, then for
all words $p, q$,
$$d(x \,\| \, p,\; y \,\|\, q) \;=\; d(x,y) + d(p,q),$$
where $\|$ denotes concatenation.

*Proof.* Induct on $x$; when $x$ and $y$ are both empty the two sides
agree, and the inductive step peels one letter off each side, which
contributes the same indicator to both sides. $\square$

### 1.3 Organisation

Section 2 establishes ball counting and sphere packing. Section 3 treats
the parity code and single-error detection. Section 4 develops the
metric group structure and the linear minimum-weight criterion.
Section 5 proves the Singleton and Gilbert–Varshamov bounds. Section 6
proves the Plotkin bound. Section 7 gives the arithmetic obstruction to
perfection and the Hamming code construction, culminating in the
existence characterisation. Section 8 proves the rigidity classification
of optimal detecting codes. Section 9 develops the extremal function and
the odd/even collapse. Section 10 discusses algorithms and applications;
Section 11 lists open problems.

---

## 2. Ball counting and sphere packing

**Definition 2.1.** For $n, r \in \mathbb{N}$ and a word $c$, the
**Hamming ball** is
$$B(n, r, c) \;=\; \{\, z \in W_n \;:\; d(z, c) \le r \,\}.$$

**Theorem 2.2 (Ball Counting Lemma).** For every $c$ with $|c| = n$,
$$|B(n,r,c)| \;=\; V(n,r) \;:=\; \sum_{i=0}^{r} \binom{n}{i}.$$

*Proof sketch.* Induct on $n$, peeling the leading letter. Write
$c = b \,\|\, c'$ with $|c'| = n-1$. A word $z \in W_n$ splits as
$z = a \,\|\, z'$, and $d(z,c) = [a \neq b] + d(z', c')$. Therefore
$$B(n, r, b\|c') \;=\; \bigl(b \,\|\, B(n-1, r, c')\bigr) \;\sqcup\;
\bigl(\bar b \,\|\, B(n-1, r-1, c')\bigr),$$
a disjoint union because the two parts differ in the leading letter.
The base cases $r = 0$ (a single word) and $n = 0$ (the empty word,
count $1$) are immediate. Taking cardinalities gives
$V(n,r) = V(n-1,r) + V(n-1,r-1)$, which is precisely Pascal's rule for
partial binomial sums,
$$\sum_{i \le r}\binom{n}{i} = \sum_{i \le r}\binom{n-1}{i} + \sum_{i \le r-1}\binom{n-1}{i},$$
proved by re-indexing and $\binom{n}{i} = \binom{n-1}{i} + \binom{n-1}{i-1}$. $\square$

**Corollary 2.3 (Homogeneity).** If $|c| = |c'| = n$ then
$|B(n,r,c)| = |B(n,r,c')|$: ball volume is independent of the centre.

**Definition 2.4.** A code $C$ has **minimum distance at least $d$**,
written $\mathrm{MinDist}(C, d)$, if $d(x,y) \ge d$ for all distinct
$x, y \in C$.

**Proposition 2.5 (Packing).** Let $C \subseteq W_n$ with
$\mathrm{MinDist}(C, 2t+1)$. Then the balls $B(n,t,x)$, $x \in C$, are
pairwise disjoint.

*Proof.* If $z \in B(n,t,x) \cap B(n,t,y)$ with $x \neq y$ then, all
three words having length $n$, the triangle inequality gives
$d(x,y) \le d(x,z) + d(z,y) \le 2t < 2t+1$, contradicting the minimum
distance. $\square$

**Theorem 2.6 (Sphere-packing / Hamming bound).** If $C \subseteq W_n$
and $\mathrm{MinDist}(C, 2t+1)$, then
$$|C| \cdot \sum_{i=0}^{t}\binom{n}{i} \;\le\; 2^{n}.$$

*Proof.* By Proposition 2.5 the union $\bigsqcup_{x \in C} B(n,t,x)$ has
cardinality $\sum_{x\in C} |B(n,t,x)| = |C| \cdot V(n,t)$ by
Corollary 2.3, and it is contained in $W_n$, of size $2^n$. $\square$

**Definition 2.7.** A code $C \subseteq W_n$ with
$\mathrm{MinDist}(C, 2t+1)$ is **perfect** (with radius $t$) if
$\bigcup_{x \in C} B(n,t,x) = W_n$, i.e. the balls tile.

**Theorem 2.8 (Equality case: packing implies tiling).** Let
$C \subseteq W_n$ with $\mathrm{MinDist}(C, 2t+1)$ and suppose
$$|C| \cdot \sum_{i=0}^{t}\binom{n}{i} \;=\; 2^{n}.$$
Then $\bigcup_{x\in C} B(n,t,x) = W_n$; the code is perfect.

*Proof.* The union is contained in $W_n$; by disjointness its
cardinality equals $|C| \cdot V(n,t) = 2^n = |W_n|$. A subset of a
finite set of equal cardinality is the whole set. $\square$

Theorem 2.8 is the hinge of Section 7: it converts a numerical identity
into a geometric statement, which is what makes perfection checkable in
practice.

---

## 3. The parity code and single-error detection

**Definition 3.1.** The **parity** of a word $l$ is
$\pi(l) = l_0 \oplus l_1 \oplus \cdots$, the XOR of all its letters. The
**parity extension** is $\widehat{l} = l \,\|\, [\pi(l)]$.

**Theorem 3.2 (Parity is the mod-2 reduction of distance).** If
$|l| = |m|$, then
$$\pi(l) = \pi(m) \iff d(l,m) \text{ is even.}$$

*Proof sketch.* Induction on the common length. Peeling the leading
letters $a$ and $b$, the parity condition flips exactly when
$a \neq b$, and so does the parity of the distance, since
$d(a\|l', b\|m') = [a\neq b] + d(l',m')$. $\square$

**Definition 3.3.** The **parity code** of length $n+1$ is
$P_n = \{\, \widehat{l} : l \in W_n \,\}$.

Since $\widehat{\cdot}$ is injective (it is left-inverted by deletion of
the last letter), $|P_n| = 2^n$, and $P_n \subseteq W_{n+1}$. Every
codeword satisfies $\pi(\widehat{l}) = 0$.

**Lemma 3.4.** If $|l| = |m|$ then
$d(\widehat{l}, \widehat{m}) = d(l,m) + [\pi(l) \neq \pi(m)]$. (Immediate
from Lemma 1.1.)

**Theorem 3.5 (Minimum distance two).** $\mathrm{MinDist}(P_n, 2)$; and
for $n \ge 1$ the value $2$ is attained, so the minimum distance is
exactly $2$.

*Proof.* Distinct codewords have parity $0$, so by Theorem 3.2 their
distance is even; being nonzero, it is at least $2$. Attainment: for
$n\ge 1$ take $l, m$ differing in exactly one coordinate; then
$d(l,m) = 1$ and the parities differ, so
$d(\widehat l, \widehat m) = 2$. $\square$

**Theorem 3.6 (Every single flip is detected).** If $|x| = |\widehat{l}|$
and $d(\widehat{l}, x) = 1$, then $x \notin P_n$.

*Proof.* By Theorem 3.2, $\pi(x) \neq \pi(\widehat l) = 0$, while every
element of $P_n$ has parity $0$. $\square$

**Theorem 3.7 (No single error is corrected).** For $n \ge 1$ there
exist a word $x$ of length $n+1$ and two distinct codewords
$c_1, c_2 \in P_n$ with $d(x, c_1) = d(x, c_2) = 1$.

*Proof.* Take $c_1, c_2$ at distance $2$ (Theorem 3.5) and let $x$ be
obtained from $c_1$ by flipping one of the two disagreeing
coordinates. $\square$

Thus the parity code detects exactly one error and corrects none; this
is a property of the geometry, not of any particular decoder.

**Theorem 3.8 (Optimality).** If $C \subseteq W_{n+1}$ and
$\mathrm{MinDist}(C, 2)$, then $|C| \le 2^n$.

*Proof.* Two length-$(n+1)$ words that agree away from the last
coordinate are at distance at most $1$. Hence deletion of the last
coordinate is injective on $C$, embedding $C$ into $W_n$. $\square$

Combining, $A(n+1, 2) = 2^n$, attained by $P_n$.

---

## 4. The Hamming cube as a metric group

**Definition 4.1.** For words $l, m$, let $l \oplus m$ be the
coordinatewise XOR (truncated to the common length). The **weight**
$w(l)$ is the number of $1$'s in $l$. The **zero word** of length $n$ is
$0_n$.

**Theorem 4.2 (Distance is the weight of the difference).** If
$|l| = |m|$ then $d(l,m) = w(l \oplus m)$. In particular
$d(l, 0_n) = w(l)$ for $|l| = n$.

*Proof sketch.* Induction, peeling leading letters: $a \neq b$ iff
$a \oplus b = 1$. $\square$

**Theorem 4.3 (Nondegeneracy).** If $|l| = |m| = n$ then
$l \oplus m = 0_n \iff l = m$.

**Theorem 4.4 (Translation invariance).** If $|x| = |y| = |z| = n$ then
$$d(x \oplus z,\; y \oplus z) \;=\; d(x,y).$$

*Proof sketch.* Induction on $n$; at each coordinate,
$(a\oplus c) \neq (b \oplus c)$ iff $a \neq b$. $\square$

Thus $(W_n, \oplus, d)$ is a metric group: an abelian group of exponent
$2$ on which the metric is translation-invariant, and hence entirely
determined by the weight function.

**Theorem 4.5 (Parity is a homomorphism).** If $|l| = |m|$ then
$\pi(l \oplus m) = \pi(l) \oplus \pi(m)$.

**Definition 4.6.** A code $C \subseteq W_n$ is **linear** if
$0_n \in C$ and $x \oplus y \in C$ for all $x, y \in C$.

**Theorem 4.7 (Minimum distance = minimum nonzero weight).** Let
$C \subseteq W_n$ be linear. Then
$$\mathrm{MinDist}(C, d) \iff \bigl(\forall x \in C,\ x \neq 0_n \Rightarrow w(x) \ge d\bigr).$$

*Proof.* ($\Rightarrow$) For $x \in C$ nonzero, $0_n \in C$ and
$x \neq 0_n$, so $d \le d(x, 0_n) = w(x)$ by Theorem 4.2.
($\Leftarrow$) For distinct $x, y \in C$, closure gives
$x \oplus y \in C$, and by Theorem 4.3 it is nonzero; translation
invariance (Theorem 4.4) with $z = y$ gives
$d(x,y) = d(x \oplus y, 0_n) = w(x\oplus y) \ge d$. $\square$

**Remark 4.8.** The hypothesis $0_n \in C$ is load-bearing in the
backward direction: a coset $a \oplus C$ of a linear code has exactly
the same distance multiset but contains no zero word, and the weight
condition on it carries no information.

**Theorem 4.9 (The parity code is the even-weight code, and is linear).**
$$P_n \;=\; \{\, x \in W_{n+1} \;:\; \pi(x) = 0 \,\},$$
$0_{n+1} \in P_n$, and $P_n$ is closed under $\oplus$. Consequently
every nonzero $x \in P_n$ has $w(x) \ge 2$.

*Proof.* Inclusion $\subseteq$ is $\pi(\widehat l) = 0$. Conversely, if
$\pi(x) = 0$ and $|x| = n+1$, write $x = l \,\|\, [b]$; then
$\pi(l) \oplus b = 0$, so $b = \pi(l)$ and $x = \widehat l$. Linearity
is Theorem 4.5. The weight statement is Theorem 4.7 applied with
$d = 2$, using Theorem 3.5. $\square$

---

## 5. Singleton and Gilbert–Varshamov

**Lemma 5.1 (Prefix agreement bounds distance).** If $|x| = |y| = n$ and
the length-$k$ prefixes of $x$ and $y$ agree, then $d(x,y) \le n - k$.

*Proof.* Split $x = x_{<k} \| x_{\ge k}$ and likewise for $y$; by
Lemma 1.1, $d(x,y) = d(x_{<k}, y_{<k}) + d(x_{\ge k}, y_{\ge k})
= 0 + d(x_{\ge k}, y_{\ge k}) \le n-k$. $\square$

**Theorem 5.2 (Singleton bound).** If $C \subseteq W_n$,
$\mathrm{MinDist}(C, d)$ and $d \ge 1$, then
$$|C| \;\le\; 2^{\,n+1-d}$$
(with truncated subtraction, so that the statement reads $|C| \le 1$
when $d > n+1$).

*Proof.* Let $k = n+1-d$. If two distinct codewords had equal length-$k$
prefixes then Lemma 5.1 would give $d(x,y) \le n - k = d - 1$,
contradicting $\mathrm{MinDist}(C,d)$ (note $n-k = d-1$ exactly when
$d \le n+1$; in the degenerate case $d > n+1$ we have $k = 0$ and all
prefixes agree trivially, forcing $|C| \le 1$, which is also what the
right-hand side asserts). Hence prefix truncation is injective from $C$
into the $2^k$ words of length $k$. $\square$

**Theorem 5.3 (Gilbert–Varshamov bound).** For all $n$ and all
$d \ge 1$ there exists $C \subseteq W_n$ with $\mathrm{MinDist}(C,d)$
and
$$2^{n} \;\le\; |C| \cdot \sum_{i=0}^{d-1}\binom{n}{i}.$$

*Proof.* The family $\mathcal{S}$ of codes $C \subseteq W_n$ with
$\mathrm{MinDist}(C,d)$ is a nonempty (it contains $\varnothing$) finite
family; choose $C \in \mathcal{S}$ of maximum cardinality — equivalently,
maximal under inclusion. Then for every $z \in W_n$ we must have
$d(z, x) \le d-1$ for some $x \in C$: otherwise $C \cup \{z\}$ would
still have minimum distance $\ge d$ and be strictly larger. Hence
$$W_n \;\subseteq\; \bigcup_{x \in C} B(n, d-1, x),$$
and Theorem 2.2 gives $2^n \le |C| \cdot V(n, d-1)$. $\square$

**Remark 5.4.** Theorem 5.3 is the exact converse of sphere packing:
packing says radius-$t$ balls do not overlap, greed says radius-$(d-1)$
balls leave no gaps. Together they bracket the extremal function:
$$\frac{2^{n}}{V(n,d-1)} \;\le\; A(n,d) \;\le\; 2^{\,n+1-d}.$$
The bound is non-vacuous: the extracted code genuinely lies in $W_n$
and has minimum distance $d$; for $d=1$ it returns all of $W_n$, of
size $2^n$.

---

## 6. The Plotkin bound

Sphere packing is vacuous when $2d > n$, since the radius-$t$ balls then
exceed the cube. That regime is covered by a double count.

**Lemma 6.1 (Coordinate form of the distance).** If $|x| = |y| = n$ then
$$d(x,y) \;=\; \sum_{j=0}^{n-1} [\,x_j \neq y_j\,].$$

**Lemma 6.2 (One-coordinate pair count).** Let $C$ be a finite code and
$c : C \to \{0,1\}$ any function. If $k = |\{x \in C : c(x) = 1\}|$ and
$M = |C|$, then
$$\sum_{x \in C}\sum_{y \in C} [\,c(x) \neq c(y)\,] \;=\; 2k(M-k).$$

*Proof.* The sum counts ordered pairs with differing values; there are
$k(M-k)$ with $c(x)=1, c(y)=0$ and as many with the roles swapped.
$\square$

**Theorem 6.3 (Upper estimate).** If $C \subseteq W_n$ then
$$2 \sum_{x \in C}\sum_{y \in C} d(x,y) \;\le\; n\,|C|^{2}.$$

*Proof.* Exchange the order of summation using Lemma 6.1 to write the
double sum as $\sum_{j<n} \sum_{x,y} [x_j \neq y_j]$, and apply
Lemma 6.2 at each coordinate $j$ with $k = k_j$. The claim reduces to
$4k(M-k) \le M^{2}$ for $0 \le k \le M$, which upon writing
$M = k + f$ is $4kf \le (k+f)^2$, i.e. $(k-f)^2 \ge 0$. $\square$

**Theorem 6.4 (Lower estimate).** If $\mathrm{MinDist}(C, d)$ then
$$d\,|C|\,(|C|-1) \;\le\; \sum_{x\in C}\sum_{y\in C} d(x,y).$$

*Proof.* For fixed $x$, the inner sum has $|C|-1$ terms each $\ge d$
(the term $y = x$ contributes $0$). $\square$

**Theorem 6.5 (Plotkin bound).** If $C \subseteq W_n$,
$\mathrm{MinDist}(C,d)$ and $n < 2d$, then
$$|C|\,(2d - n) \;\le\; 2d.$$

*Proof.* Write $M = |C|$; we may assume $M \ge 1$. Combining
Theorems 6.3 and 6.4,
$$2 d M (M-1) \;\le\; 2\sum_{x,y} d(x,y) \;\le\; n M^{2}.$$
Dividing by $M$ (positive) gives $2d(M-1) \le nM$, i.e.
$M(2d - n) \le 2d$. $\square$

**Corollary 6.6.** Under the hypotheses of Theorem 6.5, $|C| \le 2d$,
a bound independent of the length.

*Proof.* $2d - n \ge 1$ since $n < 2d$, so
$|C| \le |C|(2d-n) \le 2d$. $\square$

**Corollary 6.7.** If $C \subseteq W_n$, $\mathrm{MinDist}(C,d)$ and
$n < d$, then $|C| \le 1$.

*Proof.* Two distinct codewords would be at distance $\ge d > n$,
impossible since distances are bounded by the common length $n$.
$\square$

**Remark 6.8.** The hypothesis $n < 2d$ is load-bearing rather than
cosmetic: with truncated subtraction, dropping it degenerates the
conclusion into $0 \le 2d$, which says nothing.

**Remark 6.9 (Two views of one metric).** The recursive view
$d(a\|x, b\|y) = [a \neq b] + d(x,y)$ powers the packing arguments; the
coordinate view of Lemma 6.1 powers the double counts. Both are needed,
and it matters that they are two descriptions of the *same* function, so
that results from the two halves of the theory can be combined.

---

## 7. Perfect single-error-correcting codes

### 7.1 The arithmetic obstruction

**Theorem 7.1 (Necessity).** Let $C \subseteq W_n$ with
$\mathrm{MinDist}(C, 3)$ and suppose the radius-$1$ balls around the
codewords cover $W_n$. Then there is $k$ with $n + 1 = 2^{k}$.

*Proof.* By Proposition 2.5 (with $t=1$, $2t+1 = 3$) the balls are
disjoint; by hypothesis they cover. Hence
$$|C| \cdot V(n,1) \;=\; 2^{n}, \qquad V(n,1) = \binom{n}{0} + \binom{n}{1} = n+1 .$$
Thus $(n+1) \mid 2^{n}$. Since $2$ is prime, every divisor of $2^n$ is
of the form $2^k$ with $k \le n$. $\square$

**Corollary 7.2 (No perfect code of length four).** There is no
$C \subseteq W_4$ with $\mathrm{MinDist}(C,3)$ whose radius-$1$ balls
cover $W_4$. Indeed $5 = 4+1$ is not a power of two.

**Theorem 7.3 (Strict sphere packing off the admissible lengths).** If
$C \subseteq W_n$, $\mathrm{MinDist}(C,3)$ and $n+1$ is not a power of
two, then $|C| \cdot (n+1) < 2^{n}$.

*Proof.* Sphere packing gives $\le$; equality would give perfection by
Theorem 2.8 and hence $n+1 = 2^k$ by Theorem 7.1. $\square$

### 7.2 The Hamming code without matrices

Fix $k$ and set $n = 2^k - 1$. Index the coordinates of a length-$n$
word by $1, 2, \dots, 2^k-1$: these are exactly the nonzero $k$-bit
patterns.

**Definition 7.4 (Syndrome).** For a word $z$ and a starting index $s$,
define
$$\mathrm{syn}_s(\varepsilon) = 0, \qquad
\mathrm{syn}_s(a \| z') = \bigl(a \cdot s\bigr) \veebar \mathrm{syn}_{s+1}(z'),$$
where $\veebar$ is bitwise XOR of natural numbers and $a \cdot s$ means
$s$ if $a = 1$ and $0$ otherwise. In words: $\mathrm{syn}_1(z)$ is the
XOR of the *indices* of the coordinates where $z$ has a $1$.

**Definition 7.5.** The **Hamming code of order $k$** is
$$\mathcal{H}_k \;=\; \{\, x \in W_{2^k - 1} \;:\; \mathrm{syn}_1(x) = 0 \,\}.$$

**Lemma 7.6 (Homomorphism).** If $|x| = |y|$ then
$\mathrm{syn}_s(x \oplus y) = \mathrm{syn}_s(x) \veebar \mathrm{syn}_s(y)$.
Hence $\mathcal{H}_k$ is linear.

**Lemma 7.7 (Weight one).** If $w(z) = 1$ then
$\mathrm{syn}_s(z) = s + i$ for the unique position $i$ of the $1$.

**Lemma 7.8 (Low weights have nonzero syndrome).** If
$1 \le w(z) \le 2$ and $s \ge 1$, then $\mathrm{syn}_s(z) \neq 0$.

*Proof.* Weight one: the syndrome equals a value $s + i \ge 1$.
Weight two: the syndrome is $(s+i) \veebar (s+j)$ with $i \neq j$, and
$a \veebar b = 0$ iff $a = b$, so it is nonzero. $\square$

**Theorem 7.9 (Minimum distance three).** $\mathrm{MinDist}(\mathcal{H}_k, 3)$.

*Proof.* $\mathcal{H}_k$ is linear (Lemma 7.6) and contains $0$. By
Theorem 4.7 it suffices that no nonzero codeword has weight $1$ or $2$,
which is Lemma 7.8 with $s = 1$. $\square$

Lemma 7.8 is precisely the classical requirement that the columns of the
parity-check matrix be *distinct and nonzero*; here it is a one-line
property of XOR rather than a statement about matrices.

**Lemma 7.10 (Syndromes are legal positions).** If
$s + |z| \le 2^{k}$ then $\mathrm{syn}_s(z) < 2^{k}$.

*Proof.* By induction, using that the XOR of two numbers below $2^k$ is
below $2^k$. $\square$

**Theorem 7.11 (Covering / decoding).** For every $x \in W_{2^k-1}$
there is $c \in \mathcal{H}_k$ with $d(x,c) \le 1$. Explicitly: let
$v = \mathrm{syn}_1(x)$. If $v = 0$ then $c = x$; otherwise flip the
coordinate at index $v$.

*Proof.* By Lemma 7.10, $v \le 2^k - 1$, so index $v$ exists. Flipping
position $v$ changes the syndrome by $\veebar v$ and changes the word by
Hamming distance $1$; the new syndrome is $v \veebar v = 0$. $\square$

**Theorem 7.12 (Perfection).** The radius-$1$ balls around the codewords
of $\mathcal{H}_k$ tile $W_{2^k - 1}$.

*Proof.* Containment in $W_{2^k-1}$ is clear; covering is Theorem 7.11;
disjointness is Proposition 2.5 with Theorem 7.9. $\square$

**Corollary 7.13 (Size).**
$|\mathcal{H}_k| \cdot 2^{k} = 2^{\,2^{k}-1}$, i.e.
$|\mathcal{H}_k| = 2^{\,2^k - 1 - k}$.

*Proof.* By tiling, $|\mathcal{H}_k| \cdot V(2^k-1, 1) = 2^{2^k-1}$, and
$V(2^k-1,1) = 2^k$. $\square$

Note the size is an *output* of the construction rather than an input:
it is forced by the tiling and the ball count.

**Corollary 7.14 (Unique decoding).** For every $x \in W_{2^k-1}$ there
is a *unique* $c \in \mathcal{H}_k$ with $d(x,c) \le 1$.

*Proof.* Existence is Theorem 7.11; uniqueness is disjointness of the
balls. $\square$

**Theorem 7.15 (Existence characterisation).** A perfect
single-error-correcting binary code of length $n$ exists **iff**
$n + 1 = 2^{k}$ for some $k$.

*Proof.* ($\Rightarrow$) Theorem 7.1. ($\Leftarrow$) Take
$\mathcal{H}_k$ and apply Theorem 7.12. $\square$

**Small cases.** $k=2$: $\mathcal{H}_2 = \{000, 111\}$, the triple
repetition code — the smallest Hamming code is the most elementary
error-correcting code. $k=3$: $\mathcal{H}_3$ is the $[7,4,3]$ code with
$16$ codewords; sixteen balls of eight words tile the $128$-word cube.
The degenerate $k=0$ gives the length-$0$ code $\{\varepsilon\}$, perfect
for trivial reasons; we keep the statement uniform rather than excluding
it.

**Theorem 7.16 (Exact extremal values at Hamming lengths).** For every
$k$,
$$A(2^k - 1,\, 3) \;=\; |\mathcal{H}_k| \;=\; 2^{\,2^k - 1 - k}.$$
In particular $A(7,3) = 16$: no binary code of length $7$ with minimum
distance $3$ has more than $16$ words, and $16$ is achieved.

*Proof.* Upper bound: sphere packing with $t=1$ gives
$|C| \cdot 2^k \le 2^{2^k-1}$ for any such $C$. Lower bound:
$\mathcal{H}_k$ realises it. $\square$

---

## 8. Rigidity: the optimal detecting codes are exactly two

We saw $A(n+1,2) = 2^n$ with the parity code attaining it. The
even-weight code is not the only optimum; its coset is another.

**Definition 8.1.** The **odd-weight code** is
$O_n = \{\, x \in W_{n+1} : \pi(x) = 1 \,\}$.

**Theorem 8.2.** $|O_n| = 2^n$ and $\mathrm{MinDist}(O_n, 2)$; moreover
$O_n \neq P_n$ for every $n$.

*Proof.* Words of length $n+1$ split into the two parity classes, of
sizes $|P_n| = 2^n$ and $|O_n|$, summing to $2^{n+1}$; hence
$|O_n| = 2^n$. Two odd-parity words have equal parity, hence even
distance (Theorem 3.2), hence distance $\ge 2$ if distinct. Finally
$0_{n+1} \in P_n \setminus O_n$. $\square$

The rigidity theorem says these are the *only* optima. The key
ingredient is a graph-theoretic fact about the cube, proved by the same
peel-the-first-coordinate recursion as the ball count.

**Theorem 8.3 (Connectivity of the Hamming cube).** Let
$h : W_n \to \{0,1\}$ satisfy $h(x) = h(y)$ whenever $d(x,y) = 1$. Then
$h$ is constant on $W_n$.

*Proof sketch.* Induct on $n$. For $n=0$ there is one word. For the
step, note first that $h$ restricted to words with a fixed leading
letter is constant, by the inductive hypothesis applied to the tails
(two length-$n$ words at distance $1$ give two length-$(n+1)$ words at
distance $1$ once the same leading letter is prepended). Second, a word
$b \| z$ and the word $\bar b \| z$ are at distance $1$, so the two
constants agree. $\square$

**Theorem 8.4 (Parity is constant on an optimal detecting code).** Let
$C \subseteq W_{n+1}$ with $\mathrm{MinDist}(C, 2)$ and $|C| = 2^n$.
Then all codewords of $C$ have the same parity.

*Proof.* Deletion of the last coordinate, $x \mapsto x^-$, is injective
on $C$ (proof of Theorem 3.8) and lands in $W_n$; since
$|C| = 2^n = |W_n|$ it is a bijection $C \to W_n$. Write $F : W_n \to C$
for the inverse, so $F(l) = l \,\|\, [p(l)]$ for a unique bit $p(l)$.

Let $x, y \in W_n$ with $d(x,y) = 1$. Then
$d(F(x), F(y)) = 1 + [\,p(x) \neq p(y)\,]$ by Lemma 1.1, and
$F(x) \neq F(y)$, so the minimum distance forces $p(x) \neq p(y)$. Also
$\pi(x) \neq \pi(y)$ because $d(x,y) = 1$ is odd (Theorem 3.2). Hence
$$\pi(F(x)) = \pi(x) \oplus p(x) \quad\text{and}\quad \pi(F(y)) = \pi(y) \oplus p(y)$$
differ in both summands, so they are equal. Thus
$l \mapsto \pi(F(l))$ is constant along edges of the cube; by
Theorem 8.3 it is constant. Since $F$ is onto $C$, all codewords share
one parity. $\square$

**Theorem 8.5 (Classification of optimal detecting codes).** Let
$C \subseteq W_{n+1}$ with $\mathrm{MinDist}(C,2)$ and $|C| = 2^n$.
Then $C = P_n$ or $C = O_n$.

*Proof.* $C$ is nonempty; let $c_0 \in C$. By Theorem 8.4 all codewords
have parity $\pi(c_0)$. If $\pi(c_0) = 0$ then
$C \subseteq \{x \in W_{n+1} : \pi(x) = 0\} = P_n$ (Theorem 4.9), and
$|C| = 2^n = |P_n|$ forces equality. If $\pi(c_0) = 1$ then similarly
$C = O_n$. $\square$

**Remark 8.6 (Sharpness).** Both alternatives genuinely occur
(Theorem 8.2), and the cardinality hypothesis cannot be dropped: any
proper subset of $P_n$ still has minimum distance $2$ but is neither
$P_n$ nor $O_n$.

The interpretation is a strong uniqueness statement about checksums: an
*optimal* single-error-detecting scheme must attach to each payload
exactly its parity bit, up to a single global complement.

---

## 9. The extremal function and the odd/even collapse

**Definition 9.1.** For $n, d \in \mathbb{N}$,
$$A(n,d) \;=\; \max\{\, |C| \;:\; C \subseteq W_n,\ \mathrm{MinDist}(C,d) \,\}.$$

**Proposition 9.2 (Well-posedness and attainment).** The set of
achievable sizes is nonempty (it contains $0$, via $C = \varnothing$) and
bounded above by $2^n$; hence $A(n,d)$ is a genuine maximum, attained by
some code, and $A(n,d) \le 2^n$. Moreover every code
$C \subseteq W_n$ with $\mathrm{MinDist}(C,d)$ satisfies $|C| \le A(n,d)$.

**Theorem 9.3 (Extension raises odd distance).** Let $C \subseteq W_n$
with $\mathrm{MinDist}(C, d)$ and $d$ odd. Then the parity-extended code
$\widehat{C} = \{\widehat{x} : x \in C\}$ satisfies
$\widehat{C} \subseteq W_{n+1}$, $|\widehat C| = |C|$, and
$\mathrm{MinDist}(\widehat C, d+1)$.

*Proof.* Injectivity of $\widehat{\cdot}$ gives the cardinality. For
distinct $x, y \in C$: if $\pi(x) \neq \pi(y)$ then
$d(\widehat x, \widehat y) = d(x,y) + 1 \ge d+1$. If $\pi(x) = \pi(y)$
then $d(\widehat x, \widehat y) = d(x,y)$, which is *even* by
Theorem 3.2, and an even number that is $\ge$ the odd number $d$ is
$\ge d+1$. $\square$

**Remark 9.4.** The naive argument "$d \le d(x,y)$ so
$d+1 \le d(x,y)+1$" is invalid, since the parity bit need not always
disagree. The evenness argument is the correct route, and it is exactly
where oddness of $d$ enters.

**Corollary 9.5.** For odd $d$, $A(n,d) \le A(n+1, d+1)$.

**Lemma 9.6 (Puncturing costs at most one).** If $|x| = |y|$ then
$d(x,y) \le d(x^-, y^-) + 1$, where $x^-$ deletes the last coordinate.

*Proof.* Split $x = x^- \| [\text{last}]$, likewise for $y$, and apply
Lemma 1.1; the final block contributes at most $1$. $\square$

**Theorem 9.7 (Puncturing lowers distance by at most one, injectively).**
Let $C \subseteq W_{n+1}$ with $\mathrm{MinDist}(C, d+1)$ and
$d \ge 1$. Then $x \mapsto x^-$ is injective on $C$, its image lies in
$W_n$, and the image has minimum distance $\ge d$.

*Proof.* Injectivity: if $x^- = y^-$ with $x \neq y$, they differ only
in the last coordinate, so $d(x,y) \le 1 < d+1$. Distance: by
Lemma 9.6, $d+1 \le d(x,y) \le d(x^-, y^-) + 1$. $\square$

**Corollary 9.8.** For every $d \ge 1$ and every $n$,
$A(n+1, d+1) \le A(n, d)$ — with no parity hypothesis.

**Theorem 9.9 (Odd/even collapse).** For every $n$ and every odd $d$,
$$A(n, d) \;=\; A(n+1, d+1).$$

*Proof.* Corollary 9.5 and Corollary 9.8. $\square$

Extension and puncturing are mutually inverse at the level of optimal
codes; this is the structural reason binary code tables list only odd
minimum distances.

**Consequences.**

* $A(n, 1) = 2^{n}$: distance $1$ imposes no condition, so all of $W_n$
  qualifies.
* $A(n+1, 2) = 2^{n}$ — a second, purely structural proof of the
  optimality of the parity code, obtained from $A(n,1) = 2^n$ by
  Theorem 9.9 with $d = 1$.
* $A(8, 4) = A(7,3) = 16$: the *extended* Hamming code of length $8$ is
  optimal for minimum distance $4$.
* $A(2^{k}, 4) = A(2^k - 1, 3) = 2^{\,2^k - 1 - k}$ for every $k$: all
  extended Hamming codes are optimal.
* **Monotonicity:** $A(n, e) \le A(n, d)$ whenever $d \le e$.
* **Iterated puncturing:** $A(n+j, d+j) \le A(n,d)$ for all $j$ and all
  $d \ge 1$ — a Singleton-type decay obtained by iterating
  Corollary 9.8.

**Theorem 9.10 (The oddness hypothesis is necessary).**
$A(4,3) < A(3,2)$. Hence Theorem 9.9 fails for the even distance
$d = 2$.

*Proof.* $A(3,2) = 4$ by the previous list. For $A(4,3)$, sphere packing
with $t = 1$ and $n=4$ gives $|C| \cdot 5 \le 16$, so $|C| \le 3$.
$\square$

In words: no minimum-distance-$2$ code of length $3$ and size $4$ can be
extended to a minimum-distance-$3$ code of length $4$. Puncturing always
works; extension needs oddness. **Odd distances are the primitive
ones**, which is why sphere packing is naturally stated at $d = 2t+1$.

---

## 10. Algorithms and applications

### 10.1 Syndrome decoding

The decoding rule for $\mathcal{H}_k$ is as cheap as error correction
gets. Given a received word $x$ of length $2^k - 1$:

1. compute $v = \mathrm{syn}_1(x)$, the XOR of the indices $i$ with
   $x_i = 1$;
2. if $v = 0$, accept $x$;
3. otherwise flip coordinate $v$ and accept.

Cost: $O(n)$ word-XOR operations, $O(1)$ memory, no tables. Correctness
is Theorem 7.11, and Corollary 7.14 guarantees the answer is the unique
codeword within distance $1$. This is the algorithm behind
single-error-correcting ECC memory, where the extended Hamming code of
length $2^k$ (obtained by parity extension, Theorem 9.3) yields the
familiar *SECDED* behaviour: correct one error, detect two. Theorem 9.9
explains why the extension is free: $A(2^k, 4) = A(2^k-1, 3)$, so
SECDED costs exactly one extra bit and no codewords.

### 10.2 Greedy code construction (Gilbert–Varshamov in practice)

The proof of Theorem 5.3 is an algorithm: scan the $2^n$ words in any
order, adding a word to the code whenever it is at distance $\ge d$ from
everything already chosen. The result is a maximal code, hence
$|C| \ge 2^n / V(n, d-1)$. It runs in $O(2^n \cdot |C| \cdot n)$ time
and is the standard baseline against which explicit constructions are
measured.

### 10.3 Bound comparison

For fixed $n$ and $d$ the three upper bounds
$$U_{\mathrm{SP}} = \left\lfloor \frac{2^n}{V(n, \lfloor (d-1)/2\rfloor)} \right\rfloor,
\quad U_{\mathrm{Sing}} = 2^{\,n+1-d},
\quad U_{\mathrm{Plot}} = \left\lfloor \frac{2d}{2d-n} \right\rfloor \ (n < 2d)$$
have complementary regimes: sphere packing is strongest for small $d$
relative to $n$, Singleton is strongest in the intermediate range, and
Plotkin dominates as $d$ approaches and exceeds $n/2$. Taking the
minimum of the three, together with the Gilbert–Varshamov lower bound,
produces the classical bracketing table for $A(n,d)$, exact at
$(n,d) \in \{(7,3), (8,4), (2^k-1, 3), (2^k, 4), (n+1, 2), (n,1)\}$ by
the results above.

### 10.4 Where the constraints bite

Every constraint proved here is binding on real systems. The
non-existence of a perfect code of length $4$ (Corollary 7.2) says no
amount of engineering can produce a $4$-bit single-error-correcting
scheme with no wasted syndromes: $5 \nmid 16$. The rigidity theorem
(Theorem 8.5) says the parity bit used on serial lines and in barcode
check digits is not a convention but the unique optimal choice up to
complementation. The Plotkin bound explains why very-high-distance codes
(deep-space telemetry, spread-spectrum synchronisation words) have very
few codewords: at $n < 2d$ the code size is capped by $2d$, independent
of how long you make the word.

---

## 11. Discussion and open problems

The development is remarkably economical in its ingredients. A single
recursion — peel the leading coordinate — produces both the ball count
(Theorem 2.2) and the connectivity of the cube (Theorem 8.3), i.e. both
the metric and the graph-theoretic input. Ball counting produces sphere
packing above and, via greedy maximality, Gilbert–Varshamov below.
Splitting a word into blocks (Lemma 1.1) produces Singleton, puncturing,
extension, and the coordinate additivity used throughout. Double
counting produces Plotkin, covering the regime the packing bound cannot
reach. The equality case of packing (Theorem 2.8) converts a numerical
identity into a tiling; the tiling converts into a divisibility; and the
divisibility, together with the primality of $2$, eliminates infinitely
many lengths at a stroke. The syndrome-as-XOR construction shows the
remaining lengths all occur.

Three open directions stand out.

**(1) Equality in Plotkin and Hadamard matrices.** The Plotkin bound
$|C|(2d-n) \le 2d$ is attained at $n = 2d-1$ only under strong
conditions. Equality forces every coordinate to split the code exactly
in half (the per-coordinate estimate $4k(M-k) \le M^2$ must be tight at
every $j$, i.e. $M = 2k$) *and* every pair of codewords to be at
distance exactly $d$. Written as $\pm 1$ vectors, the codewords are then
pairwise orthogonal — precisely a Hadamard matrix. The conjecture is
that $A(2d-1, d) = 2d$ holds exactly when a Hadamard matrix of order
$2d$ exists. First instances: $A(3,2) = 4$ (the parity code) and
$A(7,4) = 8$ (the punctured Hadamard code) hold, while no code of length
$5$, distance $3$, size $6$ exists. The double-count proof already
isolates the two inequalities whose equality cases are required, so the
problem reduces to tracking equality through a sum comparison.

**(2) Binary MDS codes are trivial.** A code attaining the Singleton
bound, $|C| = 2^{\,n+1-d}$ with $2 \le d \le n$, should be either the
whole even-weight code ($d=2$) or the repetition code ($d = n$). The
puncturing map of Theorem 5.2 is a *bijection* in the equality case, so
every shortening of an MDS code is again MDS; iterating shortening
reduces any putative example to a length-$d$ code of size $2$, and the
parity/repetition dichotomy is the base case. Theorem 4.9 already
disposes of half the $d=2$ branch.

**(3) Uniqueness of the Hamming code.** For $k \ge 2$, any
$C \subseteq W_{2^k-1}$ with minimum distance $3$ and
$|C| = 2^{\,2^k-1-k}$ should equal $\mathcal{H}_k$ up to a permutation
of coordinates. The first testable instance is $k = 3$: a length-$7$,
distance-$3$ code with $16$ words must be a coordinate permutation of
the $[7,4,3]$ code. Perfection is forced by Theorem 2.8, so the content
is that the tiling determines the code up to symmetry.

Beyond these, natural continuations include: the Elias–Bassalygo and
linear-programming bounds (which require a genuinely different,
harmonic-analytic technique); the classification of *all* perfect binary
codes, where the Golay code $[23,12,7]$ enters and Tietäväinen's theorem
asserts that Hamming, Golay, repetition and trivial codes exhaust the
list; nonbinary alphabets, where $V(n,r) = \sum_i \binom{n}{i}(q-1)^i$
and the same architecture goes through; and asymptotics, where the
Gilbert–Varshamov and sphere-packing bounds become the classical
entropy-rate inequalities.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Ball counting | $\lvert B(n,r,c)\rvert = \sum_{i \le r}\binom{n}{i}$, independent of $c$ |
| Sphere packing | $\mathrm{MinDist}(C, 2t+1) \Rightarrow \lvert C\rvert \cdot V(n,t) \le 2^n$ |
| Packing $\Rightarrow$ tiling | equality in sphere packing implies the balls cover $W_n$ |
| Singleton | $\mathrm{MinDist}(C,d),\ d \ge 1 \Rightarrow \lvert C \rvert \le 2^{\,n+1-d}$ |
| Gilbert–Varshamov | $\exists C:\ \mathrm{MinDist}(C,d)$ and $2^n \le \lvert C\rvert \cdot V(n,d-1)$ |
| Plotkin | $n < 2d \Rightarrow \lvert C\rvert (2d-n) \le 2d$, hence $\lvert C \rvert \le 2d$ |
| Metric group | $d(x,y) = w(x\oplus y)$ and $d(x\oplus z, y \oplus z) = d(x,y)$ |
| Linear criterion | for linear $C$: $\mathrm{MinDist}(C,d) \iff$ all nonzero weights $\ge d$ |
| Parity code | $P_n$ = even-weight words; $\lvert P_n \rvert = 2^n$, min distance exactly $2$ |
| Detecting optimality | $\mathrm{MinDist}(C,2),\ C \subseteq W_{n+1} \Rightarrow \lvert C \rvert \le 2^n$ |
| Rigidity | equality forces $C = P_n$ or $C = O_n$ |
| Perfection obstruction | perfect $1$-error-correcting of length $n$ $\Rightarrow n+1 = 2^k$ |
| Hamming construction | $\mathcal{H}_k$ has min distance $3$ and tiles $W_{2^k-1}$ |
| Characterisation | perfect code of length $n$ exists $\iff n+1$ is a power of two |
| Exact values | $A(n,1)=2^n$, $A(n+1,2)=2^n$, $A(2^k-1,3)=2^{2^k-1-k}$, $A(7,3)=16$, $A(8,4)=16$, $A(2^k,4)=2^{2^k-1-k}$ |
| Odd/even collapse | $d$ odd $\Rightarrow A(n,d) = A(n+1,d+1)$; false for $d$ even ($A(4,3) < A(3,2)$) |
