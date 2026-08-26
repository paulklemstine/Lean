# Berggren Moves on $(\mathbb{Z}/m)^3$: Exact Classification, Seed Recovery, and an Information-Theoretic Modulus Separation

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

The three Berggren (Barning–Hall) moves generate a free ternary tree on the primitive Pythagorean triples, rooted at $(3,4,5)$. We exhibit an *exact linear classifier*
$$\mathrm{which}(a,b,c) = \begin{cases} B_1 & \text{if } 5a < 3c, \\ B_2 & \text{if } 3c \le 5a < 4c, \\ B_3 & \text{if } 4c \le 5a,\end{cases}$$
and prove it is simultaneously sound and complete: for every positive Pythagorean triple $v$ and every move index $i$, $\mathrm{which}(B_i v) = i$. Combined with explicit integer inverses $B_i^{-1} = QB_i^{\mathsf T}Q$, $Q = \operatorname{diag}(1,1,-1)$, this yields an $O(k)$ algorithm recovering the entire control word from a *single* observed state, and shows the Berggren monoid acts freely on the positive cone, so the length-$k$ state space has exactly $3^k$ points.

We then push the entire system through the reduction $\mathbb{Z}^3 \to (\mathbb{Z}/m)^3$. Reduction is equivariant, every modular move is a bijection, and the Lorentz form $a^2+b^2-c^2$ remains invariant; the classifier remains *sound* on every state whose hypotenuse is below the modulus, and we exhibit an explicit failure at $m = 7$ showing this hypothesis is sharp. Nevertheless the seed-recovery problem undergoes a sharp phase change. We prove:

1. **(Positive)** If $5\cdot 7^k < m$ then a modular observer recovers every control word of length $\le k$ exactly.
2. **(Impossibility)** If $m^3 < 3^k$ then *no function* of the observed modular state recovers the control word.
3. **(Quantitative)** For every $n$ with $m^3 n < 3^k$ there is an observation consistent with more than $n$ distinct length-$k$ words; the ambiguity is $\Omega(3^k/m^3)$.
4. **(Sharpened)** Every reachable state is a primitive null vector; modulo a prime $p$ the null cone has at most $2p^2$ points, improving the threshold to $2p^2 < 3^k$ and the ambiguity to $\Omega(3^k/2p^2)$.
5. **(Structural)** Recovery for all words of length $\le k$ solves the discrete logarithm for the matrix $B_2$ in $\mathrm{GL}_3(\mathbb{Z}/m)$; via the spectral identity $(B_2 + I)(B_2^2 - 6B_2 + I) = 0$ with silver-ratio roots $3 \pm 2\sqrt 2 = (1\pm\sqrt2)^2$, that problem is identified with index-finding for the negative Pell equation $x^2 - 2y^2 = -1$.

The construction is therefore a clean example of a system whose *encoder is unchanged* by reduction, yet whose invertibility is destroyed purely by the finiteness of the observation channel.

**Keywords:** Berggren moves, Pythagorean tree, Lorentz form, seed recovery, discrete logarithm, Pell equation, silver ratio, information-theoretic hardness.

---

## 1. Introduction

### 1.1 The Barning–Hall tree

A *Pythagorean triple* is a triple $(a,b,c)$ of positive integers with $a^2 + b^2 = c^2$; it is *primitive* when $\gcd(a,b,c) = 1$. Barning (1963) and Hall (1970) independently observed that the three integer matrices

$$B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix}, \qquad B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix}, \qquad B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}$$

carry primitive triples to primitive triples, and that iterating them from the seed $(3,4,5)$ produces each primitive triple exactly once. The resulting structure is an infinite rooted ternary tree.

Each $B_i$ lies in the integral orthogonal group of the Lorentz form $Q(a,b,c) = a^2 + b^2 - c^2$ of signature $(2,1)$; the tree is the orbit of a single primitive null vector under a subgroup of $O(Q,\mathbb{Z})$. Determinants are $\det B_1 = \det B_3 = 1$ and $\det B_2 = -1$.

### 1.2 The seed-recovery problem

Fix the root $r = (3,4,5)$. A *control word* is a finite string $u = i_1 i_2 \cdots i_k \in \{1,2,3\}^k$, and we write $u \cdot r$ for the state obtained by applying $B_{i_k}, \ldots, B_{i_1}$ in order — equivalently, by the matrix product $B_{i_1} B_{i_2} \cdots B_{i_k} r$ read as the composite acting on $r$. (Throughout, when a word is presented as a list, the head is the *last* move applied.)

> **Seed-Recovery Problem.** Given the single observed state $u \cdot r$, reconstruct $u$.

Over $\mathbb{Z}$ we show this is trivially easy. The interest is in the modular variant: the observer sees only $u \cdot r \bmod m$, an element of $(\mathbb{Z}/m)^3$. This is the situation of any finite-register implementation, and it is the setting in which the tree becomes a candidate cryptographic object.

### 1.3 Contributions

Sections 2–3 develop the integer theory: the exact classifier and the linear-time decoder. Section 4 pushes to $(\mathbb{Z}/m)^3$ and isolates the exact sense in which the classifier survives. Section 5 gives the information-theoretic impossibility and its quantitative ambiguity form. Section 6 sharpens the count using the null cone. Section 7 gives the discrete-logarithm reduction and Section 8 the Pell/silver-ratio identification. Section 9 combines the results into a two-sided threshold theorem. Section 10 analyses the relative classifier and the degenerate modulus $m = 2$. Sections 11–13 discuss algorithms, applications, and open problems.

---

## 2. The moves and their invariants

**Definition 2.1 (Moves).** Let $\mathcal{M} = \{B_1, B_2, B_3\}$ act on triples $v = (a,b,c) \in \mathbb{Z}^3$ by
$$B_1 v = (a - 2b + 2c,\; 2a - b + 2c,\; 2a - 2b + 3c),$$
$$B_2 v = (a + 2b + 2c,\; 2a + b + 2c,\; 2a + 2b + 3c),$$
$$B_3 v = (-a + 2b + 2c,\; -2a + b + 2c,\; -2a + 2b + 3c).$$
The branching degree is $|\mathcal{M}| = 3$.

**Definition 2.2 (Inverses).** Define
$$B_1^{-1} v = (a + 2b - 2c,\; -2a - b + 2c,\; -2a - 2b + 3c),$$
$$B_2^{-1} v = (a + 2b - 2c,\; 2a + b - 2c,\; -2a - 2b + 3c),$$
$$B_3^{-1} v = (-a - 2b + 2c,\; 2a + b - 2c,\; -2a - 2b + 3c).$$

**Proposition 2.3.** $B_i^{-1} B_i = B_i B_i^{-1} = \mathrm{id}$ on $\mathbb{Z}^3$, for each $i$. In particular each $B_i$ is injective on $\mathbb{Z}^3$.

*Proof sketch.* Both composites are compositions of integer linear maps; expanding coordinates and simplifying gives the identity in each of the nine cases. Structurally, $B_i^{-1} = Q B_i^{\mathsf T} Q$ with $Q = \operatorname{diag}(1,1,-1)$, which is the general formula for the inverse of a $Q$-isometry. $\square$

**Definition 2.4 (Lorentz form).** $L(a,b,c) = a^2 + b^2 - c^2$.

**Proposition 2.5.** $L(B_i v) = L(v)$ and $L(B_i^{-1} v) = L(v)$ for all $i$ and all $v \in \mathbb{Z}^3$.

*Proof sketch.* Direct polynomial identity in each case; e.g. for $B_2$,
$(a+2b+2c)^2 + (2a+b+2c)^2 - (2a+2b+3c)^2 = a^2 + b^2 - c^2$
after expansion. $\square$

**Definition 2.6 (The positive cone).** Call $v = (a,b,c)$ *valid* if $a > 0$, $b > 0$, $c > 0$ and $a^2 + b^2 = c^2$; write $\mathcal{V}$ for the set of valid triples.

**Lemma 2.7 (Elementary inequalities).** For $v = (a,b,c) \in \mathcal{V}$:
(i) $a < c$; (ii) $b < c$; (iii) $c < a + b$.

*Proof sketch.* (i) $a^2 = c^2 - b^2 < c^2$ with $a, c > 0$. (ii) symmetric. (iii) $(a+b)^2 = c^2 + 2ab > c^2$. $\square$

Part (iii) is the strict triangle inequality; it is exactly what makes the classifier thresholds work.

**Theorem 2.8 (Invariance of the cone).** If $v \in \mathcal{V}$ then $B_i v \in \mathcal{V}$ for every $i$.

*Proof sketch.* The Pythagorean identity is preserved by Proposition 2.5. Positivity of the three coordinates of $B_i v$ follows from Lemma 2.7 by linear arithmetic. For instance, the first coordinate of $B_1 v$ is $a - 2b + 2c = a + 2(c - b) > 0$ since $b < c$; the first coordinate of $B_3 v$ is $-a + 2b + 2c = 2b + (2c - a) > 0$ since $a < c$. The remaining cases are similar. $\square$

**Theorem 2.9 (Grading).** If $v = (a,b,c) \in \mathcal{V}$ then $c < (B_i v)_3$ for every $i$; moreover $(B_i v)_3 \le 7c$.

*Proof sketch.* The three third coordinates are $2a - 2b + 3c$, $2a + 2b + 3c$, $-2a + 2b + 3c$. In each case $3c$ dominates the correction: e.g. $2a - 2b + 3c > c$ reduces to $a + c > b$, true by Lemma 2.7(ii). The upper bound follows from $a < c$, $b < c$: each expression is at most $2c + 2c + 3c = 7c$. $\square$

Thus the tree is *graded by the hypotenuse*, with growth factor in the open interval $(1,7]$ per move — and, on the $B_2$ spine, strictly greater than $5$ (Proposition 8.7).

---

## 3. The exact linear classifier and integer seed recovery

### 3.1 The classifier

**Definition 3.1.** The *Berggren classifier* is
$$\mathrm{which}(a,b,c) = \begin{cases} B_1 & \text{if } 5a < 3c,\\ B_2 & \text{if } 3c \le 5a < 4c,\\ B_3 & \text{if } 4c \le 5a.\end{cases}$$

It reads only the first and third coordinates, uses only two integer comparisons, and involves no division, no square root, and no knowledge of the parent.

**Theorem 3.2 (Soundness and completeness).** For every $v \in \mathcal{V}$ and every $i \in \{1,2,3\}$,
$$\mathrm{which}(B_i v) = i.$$

*Proof sketch.* Write $v = (a,b,c)$ and use Lemma 2.7: $a < c$, $b < c$, $c < a+b$.

- **$B_1$:** $(B_1v)_1 = a - 2b + 2c$, $(B_1v)_3 = 2a - 2b + 3c$. The claim $5(a - 2b + 2c) < 3(2a - 2b + 3c)$ simplifies to $0 < a + 4b - c$, which follows from $c < a + b$ and $b > 0$.
- **$B_2$:** $(B_2v)_1 = a + 2b + 2c$, $(B_2v)_3 = 2a + 2b + 3c$. The failure of the first test, $5(a+2b+2c) \ge 3(2a+2b+3c)$, simplifies to $4b + c \ge a$, true since $a < c$. The success of the second, $5(a+2b+2c) < 4(2a+2b+3c)$, simplifies to $2b < 3a + 2c$, true since $b < c$.
- **$B_3$:** $(B_3v)_1 = -a + 2b + 2c$, $(B_3v)_3 = -2a + 2b + 3c$. Failure of both tests reduces to $5(-a+2b+2c) \ge 4(-2a+2b+3c)$, i.e. $3a + 2b \ge 2c$, which follows from $c < a+b$. $\square$

**Corollary 3.3 (Fibre injectivity).** For $v \in \mathcal{V}$ and $i \ne j$, $B_i v \ne B_j v$.

### 3.2 Origin of the thresholds

The constants $3/5$ and $4/5$ are not tuned. Every primitive triple has the Euclid form $a = m^2 - n^2$, $b = 2mn$, $c = m^2 + n^2$ with $m > n > 0$ coprime of opposite parity. In these coordinates the three Berggren branches are separated by the ratio tests
$$m < 2n \quad (B_1), \qquad 2n < m < 3n \quad (B_2), \qquad m > 3n \quad (B_3).$$
Since $\dfrac{c + a}{c - a} = \dfrac{2m^2}{2n^2} = \left(\dfrac{m}{n}\right)^2$, the test $m/n < 2$ becomes $(c+a)/(c-a) < 4$, i.e. $c + a < 4c - 4a$, i.e. $5a < 3c$. Likewise $m/n < 3$ becomes $(c+a)/(c-a) < 9$, i.e. $5a < 4c$. The square roots cancel exactly, which is why the classifier is purely linear and exactly correct rather than approximately so.

### 3.3 Words, freeness, recovery

**Definition 3.4.** For a word $u = i_1 \cdots i_k$ write $u \cdot v$ for $B_{i_1}(B_{i_2}(\cdots B_{i_k}(v)))$. We have $\varepsilon \cdot v = v$ and $(uw)\cdot v = u \cdot (w \cdot v)$.

**Proposition 3.5.** If $v \in \mathcal{V}$ then $u \cdot v \in \mathcal{V}$ for every word $u$, and $c(v) \le c(u\cdot v)$, with strict inequality when $u \ne \varepsilon$.

**Theorem 3.6 (Freeness).** For $v \in \mathcal{V}$, the map $u \mapsto u\cdot v$ is injective on words. Consequently the set of states reachable in exactly $k$ steps has cardinality exactly $3^k$.

*Proof sketch.* Induction on $|u|$. If one word is empty and the other is not, the hypotenuses differ by Theorem 2.9. If both are nonempty, say $u = iu'$ and $w = jw'$ with $u\cdot v = w\cdot v$, then applying $\mathrm{which}$ and Theorem 3.2 gives $i = j$; injectivity of $B_i$ (Proposition 2.3) gives $u'\cdot v = w'\cdot v$, and the induction hypothesis finishes. $\square$

**Definition 3.7 (Decoder).** Define $R_0(v) = \varepsilon$ and $R_{n+1}(v) = \mathrm{which}(v) \cdot R_n\big(B_{\mathrm{which}(v)}^{-1} v\big)$ (prepending the classified letter).

**Theorem 3.8 (Correctness of integer seed recovery).** For every $v \in \mathcal{V}$ and every word $u$, $R_{|u|}(u \cdot v) = u$.

*Proof sketch.* Induction on $u$. For $u = iu'$, Theorem 3.2 gives $\mathrm{which}(u\cdot v) = i$ since $u'\cdot v \in \mathcal{V}$; then $B_i^{-1}(u\cdot v) = u'\cdot v$ and the induction hypothesis applies. $\square$

A *self-terminating* variant $R'$ replaces the length input by the test "have we reached $(3,4,5)$?"; since a nonempty word strictly increases the hypotenuse, the root is reached only at the end.

**Theorem 3.9 (Integer recovery is easy).** For every $k$ there is a function $f : \mathbb{Z}^3 \to \{1,2,3\}^*$ with $f(u\cdot r) = u$ for every word $u$ of length $\le k$, computable in $O(k)$ arithmetic operations (two comparisons and one $3\times3$ matrix–vector product per letter).

---

## 4. Reduction modulo $m$

### 4.1 Equivariance and reversibility

**Definition 4.1.** Let $\rho_m : \mathbb{Z}^3 \to (\mathbb{Z}/m)^3$ be coordinatewise reduction. Define $B_i^{(m)}$ and $(B_i^{(m)})^{-1}$ on $(\mathbb{Z}/m)^3$ by the same coordinate formulas as $B_i$ and $B_i^{-1}$, read in $\mathbb{Z}/m$, and set $L_m(a,b,c) = a^2+b^2-c^2 \in \mathbb{Z}/m$.

**Proposition 4.2.** (i) $\rho_m(B_i v) = B_i^{(m)}\rho_m(v)$, and hence $\rho_m(u\cdot v) = u \cdot_m \rho_m(v)$ for every word $u$. (ii) Each $B_i^{(m)}$ is a bijection of $(\mathbb{Z}/m)^3$, with inverse $(B_i^{(m)})^{-1}$. (iii) $L_m(B_i^{(m)}w) = L_m(w)$.

*Proof sketch.* (i) is the ring-homomorphism property of reduction applied to linear forms with integer coefficients. (ii) reduces the integer identities of Proposition 2.3. (iii) reduces Proposition 2.5. $\square$

Proposition 4.2(ii) is worth emphasising: the *state map itself loses nothing*. All information loss is attributable to wrap-around in the observation, not to any degeneracy of the dynamics.

### 4.2 Soundness of the classifier below the threshold

**Definition 4.3.** For $m \ge 1$, let $\lambda_m : (\mathbb{Z}/m)^3 \to \mathbb{Z}^3$ send each residue to its representative in $[0,m)$. The *modular classifier* is $\mathrm{which}_m = \mathrm{which} \circ \lambda_m$: an observer holding only the residue lifts canonically and runs the integer test.

**Lemma 4.4.** If $v = (a,b,c) \in \mathbb{Z}^3$ has $0 \le a,b,c < m$ then $\lambda_m(\rho_m(v)) = v$.

**Theorem 4.5 (Modular soundness).** Let $v \in \mathcal{V}$, let $i \in \{1,2,3\}$, and suppose the hypotenuse of $B_i v$ satisfies $c(B_i v) < m$. Then
$$\mathrm{which}_m\big(\rho_m(B_i v)\big) = i.$$

*Proof sketch.* $B_i v \in \mathcal{V}$ by Theorem 2.8, so all three coordinates are positive and, by Lemma 2.7, both legs are below the hypotenuse and hence below $m$. Lemma 4.4 gives $\lambda_m(\rho_m(B_i v)) = B_i v$, and Theorem 3.2 concludes. $\square$

This is the precise sense in which *the classifier remains sound modulo $m$*: it is not the classifier that fails, but the observation channel.

**Theorem 4.6 (Sharpness at $m = 7$).** $\mathrm{which}_7(\rho_7(B_1(3,4,5))) = B_3 \ne B_1$.

*Proof.* $B_1(3,4,5) = (5,12,13) \equiv (5,5,6) \bmod 7$. Then $5a = 25$, $3c = 18$, $4c = 24$; both tests fail and the verdict is $B_3$. $\square$

**Corollary 4.7 (Modular decoding below threshold).** If every intermediate state along a word $u$ has hypotenuse $< m$, then iterated peeling with $\mathrm{which}_m$ and the modular inverses recovers $u$ exactly from $\rho_m(u\cdot v)$.

---

## 5. Information-theoretic impossibility

**Definition 5.1.** Let $r = (3,4,5)$ and $s_m(u) = \rho_m(u\cdot r) \in (\mathbb{Z}/m)^3$ be the *observation*. Say *seed recovery mod $m$ up to length $k$ is possible*, written $\mathrm{Rec}(m,k)$, if there exists a function $f : (\mathbb{Z}/m)^3 \to \{1,2,3\}^*$ with $f(s_m(u)) = u$ for every word $u$ with $|u| \le k$.

Note the strength of the negation: $\neg\mathrm{Rec}(m,k)$ says no function at all exists — not merely no efficient one.

**Lemma 5.2 (Collision obstruction).** If $u \ne w$, $|u|,|w| \le k$, and $s_m(u) = s_m(w)$, then $\neg\mathrm{Rec}(m,k)$.

*Proof.* If $f$ witnessed $\mathrm{Rec}(m,k)$ then $u = f(s_m(u)) = f(s_m(w)) = w$. $\square$

**Lemma 5.3 (Cardinalities).** $|(\mathbb{Z}/m)^3| = m^3$ and the number of words of length exactly $k$ is $3^k$.

**Theorem 5.4 (Existence of collisions).** If $m^3 < 3^k$ then there exist distinct words $u,w$ of length exactly $k$ with $s_m(u) = s_m(w)$.

*Proof.* The map $u \mapsto s_m(u)$ sends a set of size $3^k$ into a set of size $m^3 < 3^k$, so it is not injective. $\square$

**Theorem 5.5 (Impossibility).** If $m^3 < 3^k$ then $\neg\mathrm{Rec}(m,k)$.

*Proof.* Combine Theorems 5.4 and Lemma 5.2. $\square$

**Theorem 5.6 (Quantitative ambiguity, $\Omega(3^k/m^3)$).** Let $n \ge 0$ satisfy $m^3 \cdot n < 3^k$. Then there is an observation $s \in (\mathbb{Z}/m)^3$ such that
$$\#\{\,u \in \{1,2,3\}^k \;:\; s_m(u) = s\,\} > n.$$

*Proof sketch.* This is the strong pigeonhole principle for a map into a finite target: if $|T| \cdot n < |S|$ for $g : S \to T$, some fibre of $g$ has more than $n$ elements. Apply with $S$ the $3^k$ words, $T$ the $m^3$ states. $\square$

Choosing $n = \lceil 3^k/m^3\rceil - 1$ gives an observation whose ambiguity set has size $\ge 3^k/m^3$. Since $m$ is polynomial in the security parameter while $3^k$ is exponential in the word length, the adversary who holds one observed state faces a candidate set of size $\Omega(3^k/\mathrm{poly})$, and — by Theorem 5.5 — cannot narrow it below $2$ using the observation alone once $m^3 < 3^k$.

---

## 6. Sharpening: primitivity and the null cone

The bound $m^3$ is generous. The reachable states are far from arbitrary.

**Definition 6.1.** Call $v \in \mathbb{Z}^3$ *primitive* if every common divisor of its three coordinates is a unit.

**Proposition 6.2.** $(3,4,5)$ is primitive, and each $B_i$ preserves primitivity.

*Proof sketch.* For the root, any common divisor divides $4 - 3 = 1$. For the moves: if $d$ divides all three coordinates of $B_i v$, then since $B_i^{-1}$ has integer entries, $d$ divides all three coordinates of $v = B_i^{-1}(B_iv)$ as explicit integer combinations; primitivity of $v$ gives $d$ a unit. $\square$

**Corollary 6.3.** Every state $u\cdot r$ of the tree is primitive, and $L(u\cdot r) = 0$.

**Corollary 6.4.** Modulo a prime $p$, the observation $s_p(u)$ is never the zero vector.

*Proof.* If all three coordinates of $u\cdot r$ were divisible by $p$, then $p$ would be a unit in $\mathbb{Z}$ by Corollary 6.3, contradicting $p \ge 2$. $\square$

**Definition 6.5 (Null cone).** $\mathcal{C}_m = \{\, w \in (\mathbb{Z}/m)^3 : L_m(w) = 0 \,\}$.

**Proposition 6.6.** $s_m(u) \in \mathcal{C}_m$ for every word $u$ and every $m$.

**Theorem 6.7 (Cone count).** For $p$ prime, $|\mathcal{C}_p| \le 2p^2$.

*Proof sketch.* Project $\mathcal{C}_p \to \mathbb{F}_p^2$, $(a,b,c)\mapsto (a,b)$. Given $(a,b)$, the fibre consists of $c$ with $c^2 = a^2 + b^2$, and in a field the equation $c^2 = c_0^2$ forces $(c - c_0)(c + c_0) = 0$, hence $c \in \{c_0, -c_0\}$. So every fibre has at most $2$ elements, and $|\mathcal{C}_p| \le 2\cdot|\mathbb{F}_p^2| = 2p^2$. $\square$

**Theorem 6.8 (Relative pigeonhole).** Let $S \subseteq (\mathbb{Z}/m)^3$ be any finite set containing all observations of length-$k$ words. If $|S| \cdot n < 3^k$ then some $s \in S$ is the observation of more than $n$ distinct length-$k$ words.

**Corollary 6.9 (Sharpened prime bounds).** Let $p$ be prime.
(i) If $2p^2 \cdot n < 3^k$ then some observation on the null cone is consistent with more than $n$ distinct length-$k$ control words: the ambiguity is $\Omega(3^k/2p^2)$.
(ii) If $2p^2 < 3^k$ then $\neg\mathrm{Rec}(p,k)$.

Part (ii) improves the impossibility threshold from $p^3 < 3^k$ to $2p^2 < 3^k$ — a full factor of $p$. Equivalently, recovery already fails once $k > 2\log_3 p + \log_3 2$, rather than $k > 3\log_3 p$.

---

## 7. The $B_2$ discrete logarithm

Counting is not the only obstruction. A structured one-parameter sub-family already defeats recovery.

**Proposition 7.1 (Iteration is matrix power).** For every $t \ge 0$ and every $w \in (\mathbb{Z}/m)^3$,
$$(B_i^{(m)})^t w = \big(B_i \bmod m\big)^t \cdot w.$$
In particular the observation after $t$ copies of $B_2$ is $\big(B_2 \bmod m\big)^t \cdot (3,4,5)^{\mathsf T}$.

*Proof sketch.* Induction on $t$, using that the coordinate formula for one move is matrix–vector multiplication and that matrix powers commute with the base matrix. $\square$

**Definition 7.2.** Say the *$B_2$ discrete logarithm mod $m$ up to $k$ is easy*, written $\mathrm{DL}(m,k)$, if there is $g : (\mathbb{Z}/m)^3 \to \mathbb{N}$ with $g\big(s_m(2^t)\big) = t$ for all $t \le k$, where $2^t$ denotes the word consisting of $t$ copies of the letter $2$.

**Theorem 7.3 (Reduction).** $\mathrm{Rec}(m,k) \implies \mathrm{DL}(m,k)$.

*Proof.* Let $f$ witness $\mathrm{Rec}(m,k)$ and put $g(s) = |f(s)|$ (the length of the recovered word). For $t \le k$ the word $2^t$ has length $t \le k$, so $f(s_m(2^t)) = 2^t$ and $g(s_m(2^t)) = t$. $\square$

So seed recovery is at least as hard as this matrix discrete logarithm: *unless the discrete-logarithm-like problem for $B_2$ modulo $m$ is easy, seed recovery is not easy.* This is the assumption-based half of the hardness claim, complementary to the unconditional counting half.

**Theorem 7.4 (Ill-posedness for large $k$).** For every $m \ge 1$ the $B_2$-orbit of $r$ modulo $m$ collides within $m^3$ steps: there are $t_1 \ne t_2$, both $\le m^3$, with $s_m(2^{t_1}) = s_m(2^{t_2})$. Consequently $\neg\mathrm{DL}(m,k)$ for $k \ge m^3$.

*Proof sketch.* The $m^3+1$ states $s_m(2^t)$, $t = 0,\ldots,m^3$, live in a set of size $m^3$; pigeonhole. A solver $g$ would then satisfy $t_1 = g(s_m(2^{t_1})) = g(s_m(2^{t_2})) = t_2$. $\square$

**Corollary 7.5.** For $k \ge m^3$, $\neg\mathrm{Rec}(m,k)$. This route is logically independent of Theorem 5.5: it shows that already the *one-dimensional* family of $B_2$-power words is unrecoverable.

---

## 8. The silver-ratio spectrum and the Pell identification

We now explain *why* the $B_2$ discrete logarithm has the character it does.

**Theorem 8.1 (Characteristic polynomial and factorisation).** The characteristic polynomial of $B_2$ is
$$\chi(\lambda) = \lambda^3 - 5\lambda^2 - 5\lambda + 1 = (\lambda + 1)(\lambda^2 - 6\lambda + 1),$$
whose roots are $-1$ and $3 \pm 2\sqrt 2 = (1 \pm \sqrt 2)^2$. Equivalently, as matrix identities over $\mathbb{Z}$,
$$B_2^3 = 5B_2^2 + 5B_2 - I, \qquad (B_2 + I)\big(B_2^2 - 6B_2 + I\big) = 0.$$
Both identities hold verbatim after reduction modulo any $m$.

*Proof sketch.* Direct expansion of the $3\times3$ products entry by entry; the modular versions follow by applying the ring homomorphism $\mathbb{Z}\to\mathbb{Z}/m$ entrywise. $\square$

The numbers $3 \pm 2\sqrt2$ are the squares of the *silver ratio* $\delta_S = 1 + \sqrt2$, the fundamental unit of $\mathbb{Z}[\sqrt2]$. This is the structural reason for everything that follows.

**Definition 8.2 (The $B_2$ orbit and its Pell coordinates).** Let $O_t = 2^t \cdot r$ be the state after $t$ applications of $B_2$ to $(3,4,5)$, with coordinates $(a_t, b_t, c_t)$. Set
$$S_t = a_t + b_t, \qquad C_t = c_t.$$
Then $S_0 = 7$, $C_0 = 5$; $S_1 = 41$, $C_1 = 29$.

**Proposition 8.3 (Two-dimensional evolution).** $\begin{pmatrix}S_{t+1}\\ C_{t+1}\end{pmatrix} = \begin{pmatrix}3 & 4\\ 2 & 3\end{pmatrix}\begin{pmatrix}S_t\\ C_t\end{pmatrix}$; consequently both sequences obey
$$x_{t+2} = 6x_{t+1} - x_t.$$

*Proof sketch.* Adding the first two coordinate formulas for $B_2$ gives $S_{t+1} = 3a_t + 3b_t + 4c_t = 3S_t + 4C_t$, and the third gives $C_{t+1} = 2S_t + 3C_t$. The $2\times2$ matrix has trace $6$ and determinant $1$, so Cayley–Hamilton gives the recurrence. $\square$

These are the *NSW numbers* $S_t = 7, 41, 239, 1393, \ldots$ and the *Pell half-companions* $C_t = 5, 29, 169, 985, \ldots$.

**Theorem 8.4 (Negative Pell conic).** For every $t \ge 0$,
$$S_t^2 - 2C_t^2 = -1.$$

*Proof sketch.* Induction. Base: $49 - 50 = -1$. Step: $(3S+4C)^2 - 2(2S+3C)^2 = 9S^2 + 24SC + 16C^2 - 8S^2 - 24SC - 18C^2 = S^2 - 2C^2$. $\square$

Thus the $B_2$-orbit of $(3,4,5)$ *is* the ladder of solutions to the negative Pell equation $x^2 - 2y^2 = -1$, whose solutions are generated by the odd powers of the silver ratio.

**Theorem 8.5 (The eigenvalue $-1$).** For every $t \ge 0$, $a_t - b_t = (-1)^{t+1}$.

*Proof sketch.* Induction: $3 - 4 = -1 = (-1)^1$, and subtracting the two coordinate formulas for $B_2$ gives $a_{t+1} - b_{t+1} = -(a_t - b_t)$. $\square$

So the $B_2$-spine consists exactly of the *almost-isosceles* Pythagorean triples $(3,4,5), (21,20,29), (119,120,169), (697,696,985), \ldots$, alternating in which leg is larger. Combining, $2a_t = S_t + (-1)^{t+1}$ and $2b_t = S_t - (-1)^{t+1}$.

**Theorem 8.6 (The $B_2$ discrete logarithm is Pell index-finding).** Let $m$ be odd and let $t_1 \equiv t_2 \pmod 2$. Then
$$s_m(2^{t_1}) = s_m(2^{t_2}) \iff \big(S_{t_1} \equiv S_{t_2} \text{ and } C_{t_1} \equiv C_{t_2} \pmod m\big).$$

*Proof sketch.* ($\Rightarrow$) $C_t = c_t$ is a coordinate of the state, and $S_t = a_t + b_t$ is a function of two coordinates; both are determined by the observation, with no hypothesis on $m$. ($\Leftarrow$) Since $m$ is odd, $2$ is a unit in $\mathbb{Z}/m$. Equal parity gives $(-1)^{t_1+1} = (-1)^{t_2+1}$; then $2a_{t_1} = S_{t_1} + (-1)^{t_1+1} \equiv S_{t_2} + (-1)^{t_2+1} = 2a_{t_2}$, and cancelling the unit $2$ gives $a_{t_1} \equiv a_{t_2}$. Same for $b$, and $c$ is $C$. $\square$

Hence "recover $t$ from $B_2^t r \bmod m$" is exactly "locate the index of a given pair in the Pell ladder modulo $m$" — a well-studied index-finding problem whose difficulty is governed by the multiplicative order of the silver ratio $1+\sqrt2$ in $(\mathbb{Z}[\sqrt2]/m)^\times$.

**Proposition 8.7 ($B_2$-spine growth).** $C_{t+1} > 5C_t$, and hence $C_t \ge 5^{t+1}$.

*Proof sketch.* $C_{t+1} = 2S_t + 3C_t = 2(a_t + b_t) + 3c_t > 2c_t + 3c_t = 5c_t$ by the strict triangle inequality (Lemma 2.7(iii)). Induction from $C_0 = 5$ gives the bound. $\square$

Together with the general upper bound $c \mapsto \le 7c$, the growth rate of the $B_2$ spine is pinned between $5$ and $7$ per step. In particular the spine leaves any window $[0,m)$ after $O(\log m)$ steps.

---

## 9. The two-sided threshold

**Theorem 9.1 (Growth bound).** For every word $u$, the hypotenuse of $u\cdot r$ is at most $5\cdot 7^{|u|}$.

*Proof sketch.* Induction using $(B_iv)_3 \le 7c(v)$ from Theorem 2.9, from $c(r) = 5$. $\square$

**Theorem 9.2 (Recovery above the wrap-around threshold).** If $5\cdot 7^k < m$ then $\mathrm{Rec}(m,k)$ holds, witnessed by the self-terminating modular peeling algorithm.

*Proof sketch.* By Theorem 9.1, every state along a word of length $\le k$ has hypotenuse $\le 5\cdot 7^k < m$, and by Lemma 2.7 both legs are smaller still. So Lemma 4.4 applies at every step: the canonical lift of each observation is the true integer state. Then Theorem 4.5 classifies each step correctly, the modular inverse peels it off (by equivariance, Proposition 4.2(i)), and the root test terminates the loop correctly because a nonempty word never returns to $r$. $\square$

**Theorem 9.3 (Two-sided threshold).** For all $m \ge 1$ and $k \ge 0$:
- if $5\cdot 7^k < m$ then $\mathrm{Rec}(m,k)$;
- if $m^3 < 3^k$ then $\neg\mathrm{Rec}(m,k)$.

Moreover the two hypotheses are mutually exclusive: if $5\cdot7^k < m$ then $m^3 \ge m > 5\cdot 7^k \ge 5\cdot 3^k > 3^k$.

**Theorem 9.4 (Modulus separation).** Fix $m \ge 1$ and $k \ge m^3$. Then simultaneously:
1. over $\mathbb{Z}$ the control word is recovered from a single observed state by an explicit $O(k)$ algorithm;
2. over $\mathbb{Z}/m$ no function of the observed state recovers the control word;
3. for every $n$ with $m^3 n < 3^k$, some observation is consistent with more than $n$ distinct control words.

The classifier is not at fault: by Theorem 4.5 it remains sound on every state that has not wrapped around.

Writing $m = 7^{\alpha k}$, the two conditions of Theorem 9.3 place the phase transition in the window $\alpha \in \left[\frac{\log 3}{3\log 7},\, 1\right] \approx [0.188, 1]$. Section 13 discusses the conjectured exact location.

---

## 10. The relative classifier and the degenerate modulus

The classifier of Section 3 is *absolute*: it sees only the child. Suppose the observer also sees the parent $w \in (\mathbb{Z}/m)^3$. Then a purely algebraic test is available.

**Proposition 10.1 (Child differences).** For every $w = (a,b,c) \in (\mathbb{Z}/m)^3$:
$$B_1^{(m)}w - B_2^{(m)}w = (-4b,\, -2b,\, -4b),$$
$$B_2^{(m)}w - B_3^{(m)}w = (2a,\, 4a,\, 4a),$$
$$B_1^{(m)}w - B_3^{(m)}w = (2a - 4b,\, 4a - 2b,\, 4a - 4b).$$

**Definition 10.2.** Call $w$ *separated* if $2a \ne 0$, $2b \ne 0$, and $2a - 4b \ne 0$ in $\mathbb{Z}/m$.

**Definition 10.3 (Relative classifier).** $\mathrm{rel}_m(w,x) = i$ if $x = B_i^{(m)}w$ for the least such $i$, and $\perp$ otherwise.

**Theorem 10.4.** If $w$ is separated then the three children $B_1^{(m)}w, B_2^{(m)}w, B_3^{(m)}w$ are pairwise distinct and $\mathrm{rel}_m(w, B_i^{(m)}w) = i$ for every $i$. Conversely, if $\mathrm{rel}_m(w,x) = i$ then $x = B_i^{(m)}w$.

*Proof sketch.* Distinctness is immediate from Proposition 10.1 and the three nonvanishing conditions (each difference has a coordinate that is one of $2a$, $2b$, $2a - 4b$ up to a unit multiple by $\pm 1, \pm 2$ — reading the appropriate coordinate suffices). Soundness of the sequential test then follows because each earlier branch is excluded. Completeness is by definition of the test. $\square$

So the branching is *locally* visible modulo $m$ precisely on separated states — a condition that fails only on a codimension-one union of three linear subvarieties. In particular for odd $m$ the conditions read $a \ne 0$, $b \ne 0$, $a \ne 2b$.

**Theorem 10.5 (Total collapse modulo $2$).** Every Berggren move acts as the identity on $(\mathbb{Z}/2)^3$. Consequently $s_2(u) = \rho_2(3,4,5) = (1,0,1)$ for every word $u$, no state is separated, and $\neg\mathrm{Rec}(2,k)$ for every $k \ge 1$.

*Proof sketch.* Modulo $2$ all the coefficients $\pm2$ vanish and the coefficient $3$ becomes $1$, so each of $B_1, B_2, B_3$ reduces to the identity matrix; a finite check over the eight states confirms it. Then every word acts trivially, and the empty word and the word "$B_1$" already collide. $\square$

This is the extreme endpoint of the information-loss spectrum: not merely $\Omega(3^k/m^3)$ ambiguity, but *total* ambiguity — the observation is a constant function of the word.

---

## 11. Algorithms

### 11.1 Integer decoder — $O(k)$

**Input:** a valid triple $v$ reachable from $(3,4,5)$; **Output:** the control word.

1. $u \leftarrow \varepsilon$.
2. While $v \ne (3,4,5)$:
   a. $i \leftarrow B_1$ if $5v_1 < 3v_3$, else $B_2$ if $5v_1 < 4v_3$, else $B_3$.
   b. Append $i$ to $u$.
   c. $v \leftarrow B_i^{-1}v$.
3. Return $u$.

**Complexity.** Two comparisons and nine multiply-adds per iteration; the number of iterations equals the word length $k$, because each inverse move strictly decreases the hypotenuse and the root is reached exactly at the end. Total: $O(k)$ operations on integers of $O(k)$ bits, hence $O(k^2)$ bit operations (or $O(k \cdot M(k))$ if one is careful about the growth to $\approx 7^k$).

### 11.2 Modular decoder — correct iff no wrap-around

Identical, but the observer holds $w \in (\mathbb{Z}/m)^3$, lifts each residue to $[0,m)$ before the comparison, and applies the modular inverse. Correct for all words of length $\le k$ whenever $5\cdot7^k < m$; provably incorrect for some word whenever $m^3 < 3^k$.

### 11.3 Ambiguity enumeration

To exhibit the $\Omega(3^k/m^3)$ ambiguity concretely, enumerate all $3^k$ words, compute $s_m(u)$ for each, bucket by observation, and report the largest bucket. Complexity $O(3^k)$ time and $O(\min(3^k, m^3))$ space. The bucket-maximum is guaranteed $> n$ for any $n$ with $m^3 n < 3^k$, by Theorem 5.6 — and in practice tracks $3^k/|\mathcal{C}_m|$ closely, evidence for the exact-orbit-size conjecture of Section 13.

### 11.4 Baby-step giant-step for the $B_2$ discrete logarithm

Because iteration is matrix exponentiation (Proposition 7.1) and the orbit is a Pell ladder (Theorem 8.6), the $B_2$ discrete logarithm modulo $m$ admits the standard meet-in-the-middle attack: precompute $B_2^{j}r$ for $j < \lceil\sqrt{N}\rceil$ (baby steps, stored in a hash table), then multiply the target by $B_2^{-\lceil\sqrt N\rceil}$ repeatedly (giant steps) until a stored value is hit; here $N$ is the orbit period, which divides the order of $B_2$ in $\mathrm{GL}_3(\mathbb{Z}/m)$ and is $O(m)$ for prime $m$. This runs in $O(\sqrt N)$ time and space, i.e. $O(\sqrt m)$ — the same square-root barrier as generic discrete logarithm.

---

## 12. Discussion and applications

**A separation with an unchanged encoder.** The methodological point of this development is that the hardness is not manufactured by complicating the construction. The three matrices, their invertibility, the Lorentz invariant, and the exact classifier all descend unchanged to $\mathbb{Z}/m$ (Proposition 4.2, Theorem 4.5). What changes is the *capacity of the observation channel*: $\log_2(m^3)$ bits, against a message of $k\log_2 3$ bits. When the message exceeds the channel, invertibility of the map is irrelevant.

**Unconditional versus conditional hardness.** Two independent obstructions coexist here, and it is worth keeping them separate.

- *Unconditional* (Theorems 5.5, 5.6, 6.9): once $m^3 < 3^k$ — or $2p^2 < 3^k$ for prime $p$ — no function exists. This holds against computationally unbounded adversaries and needs no assumption.
- *Conditional* (Theorem 7.3): in the intermediate regime, recovery would imply a $\mathrm{GL}_3(\mathbb{Z}/m)$ discrete-logarithm solver for $B_2$, i.e. Pell index-finding. This is a standard-flavour assumption, and Section 11.4 shows the square-root attack is available, so one should size $m$ accordingly.

**Design implications.** A hash-like or commitment-like primitive built from the Berggren tree over a fixed modulus should be sized with the *sharpened* prime bound $2p^2$ rather than $p^3$: recovery already fails at $k > 2\log_3 p + \log_3 2$, one full factor of $p$ earlier than the naive estimate. Conversely, a *verifiable* application — where one wants recovery to succeed — must live above $5\cdot 7^k$, i.e. use $\Theta(k)$-word arithmetic; there is no shortcut, because Theorem 4.6 shows a single wrap-around already flips the classifier's answer.

**Relation to classical number theory.** The $B_2$ spine identifies the almost-isosceles Pythagorean triples with the negative Pell ladder for $\sqrt2$, and the eigenvalue $-1$ of $B_2$ is exactly the alternation $a_t - b_t = (-1)^{t+1}$. The relevant unit is the silver ratio $1 + \sqrt2$, and the period of the orbit modulo $m$ is the multiplicative order of $(1+\sqrt2)^2$ modulo $m$ in $\mathbb{Z}[\sqrt2]$ — the analogue of the Pisano period for the Fibonacci sequence.

**Degenerate moduli as a diagnostic.** The total collapse modulo $2$ (Theorem 10.5) and the local separation analysis (Theorem 10.4) delineate exactly where the branching is invisible: the bad locus is $\{2a = 0\} \cup \{2b = 0\} \cup \{2a = 4b\}$. Any implementation should verify separation at each step, since an adversary who can steer a trajectory onto the bad locus destroys distinguishability locally even for large $m$.

---

## 13. Open problems

**Problem 1 (Exact orbit size).** *Conjecture:* for every $m \ge 3$, the set of states reachable from $(3,4,5)$ by Berggren words modulo $m$ has cardinality
$$\tfrac12\, m^2 \prod_{p \mid m}\big(1 - p^{-2}\big),$$
in particular exactly **half** the punctured null cone for prime modulus.

The Berggren moves generate an index-two subgroup of the modular orthogonal group $O(Q, \mathbb{Z}/m)$ of $Q = a^2 + b^2 - c^2$, so the orbit of a primitive null vector should be a single coset, and the count forced by group order rather than by dynamical accident. We have proved the containment half (Proposition 6.6, Corollary 6.4) and a crude $2p^2$ upper bound (Theorem 6.7). The missing input is the classical count of the zeros of a nondegenerate ternary quadratic form over $\mathbb{F}_p$, one substitution $(x,y,z) = (c-a,\, c+a,\, b)$ away from the elementary count of solutions to $xy = z^2$. Settling it would replace $2p^2$ by $(p^2-1)/2$ in every bound of Section 6.

Exhaustive orbit computation supports the conjecture: for every prime $p \le 41$ one finds $|\mathcal{C}_p| = p^2$ exactly (so the crude bound $2p^2$ is off by a factor of two), and the reachable set has cardinality exactly $(p^2-1)/2$ — e.g. $4, 12, 24, 60, 84, 144, 180, 264, 420, 480, 684, 840$ for $p = 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41$. This is a finite computation, not a proof; the general statement remains open.

**Problem 2 (Location of the phase transition).** *Conjecture:* there is $\alpha \in (0,1)$ such that modular seed recovery of length-$k$ words is possible for $m \ge 7^{(\alpha+\varepsilon)k}$ and impossible for $m \le 7^{(\alpha-\varepsilon)k}$, with
$$\alpha = \frac{\log 3}{\log 7} \approx 0.5646.$$

Recovery survives as long as the *typical* branch of the tree stays below the modulus, and a typical branch grows like the geometric mean of the three per-move hypotenuse factors, not the worst case $7$. The counting obstruction bites at $3^k$ distinguishable states, so the two curves cross at $m \asymp 3^k$ states, giving $\alpha = \log_7 3$. Theorem 9.3 proves the sandwich $5\cdot7^k < m \Rightarrow$ recoverable and $m^3 < 3^k \Rightarrow$ not recoverable, bracketing $\alpha \in [\log 3/(3\log7),\, 1]$; closing the gap requires a *typical-case* growth estimate rather than a worst-case one.

**Problem 3 (Average-case hardness).** All impossibility results here are worst-case existence statements: *some* observation is highly ambiguous. What is the distribution of fibre sizes for a uniformly random length-$k$ word? Conjecturally it concentrates around $3^k/|\text{orbit}|$, which Problem 1 would evaluate.

**Problem 4 (Period of the $B_2$ orbit).** Determine the exact period of $t \mapsto B_2^t r \bmod m$ in terms of the order of $(1+\sqrt2)^2$ in $(\mathbb{Z}[\sqrt2]/m)^\times$, and identify the moduli for which the period is unusually short (the Pell analogue of Wall–Sun–Sun primes).

**Problem 5 (Other seeds and other forms).** The same programme applies to any $\mathrm{Aut}(Q,\mathbb{Z})$-tree over a form of signature $(n,1)$. Which forms admit an exact *linear* classifier of the type in Definition 3.1, and what replaces the thresholds $3/5$, $4/5$?

---

## 14. Conclusion

The Berggren tree provides a rare, fully explicit example of a system that is perfectly invertible over $\mathbb{Z}$ — via two integer comparisons per letter — and provably non-invertible over $\mathbb{Z}/m$ for information-theoretic reasons, with the transition sandwiched between two computable thresholds. The obstruction is not that the modular dynamics degenerates (it does not: every modular move is a bijection preserving the Lorentz form), nor that the classifier fails (it is sound on every un-wrapped state), but simply that $3^k$ messages will not fit through a channel of $m^3$ states. Layered on top of the counting bound sits a genuine computational assumption: a $\mathrm{GL}_3(\mathbb{Z}/m)$ discrete logarithm whose spectral analysis leads directly to the silver ratio $1 + \sqrt2$ and the negative Pell equation. Together these give a two-sided, quantitatively explicit account of what a fixed modulus does to an ancient combinatorial object.
