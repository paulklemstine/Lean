# The Two-Tree Closure: Positional Information in the Berggren and Price Trees of Pythagorean Triples

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

The primitive Pythagorean triples form a free ternary tree — the Berggren tree — in which every triple occupies a unique node with a unique address word over the alphabet $\{A,B,C\}$. Because the hypotenuse $N=m^2+n^2$ of a node $(m,n)$ is a sum of two coprime squares, and because knowing $(m,n)$ for a semiprime $N$ yields its Gaussian factorisation and hence its prime factors, a natural question arises: can the address of $N$ — specifically the *ascent letter* at each step — be predicted from quantities computed cheaply from $N$ alone? We answer this negatively at four independent strengths, with exact theorems rather than statistics.

(i) *Residue dials are blind*: for every modulus $M\ge 1$ and at arbitrarily large scale there exist three nodes with the three distinct ascent letters whose hypotenuses are all congruent to $1 \bmod M$; hence no function of $N \bmod M$ computes the letter. (ii) *Gauss-sum probes are residue dials*: the quadratic Gauss sum $G_M(N)$ is $M$-periodic in $N$, so any readout — singly or as a finite battery of moduli dividing a common $M$ — inherits blindness. (iii) *Structural sensors are constant*: the parity profile of every node's triple is exactly $(1,0,1)$ and the Lorentz form vanishes identically, so these channels carry exactly zero information. (iv) *Magnitude mirrors are blind*: the nodes $(20t-1,10t+2)$ and $(20t+1,10t-2)$ share hypotenuse $500t^2+5$ but carry letters $A$ and $B$, so the ascent letter is not a function of $N$ at all; moreover every dyadic window $[X,2X)$ with $X\ge661$ contains nodes of all three letters, killing log-magnitude decile sensors even at the level of support.

We complement these with the positive structure that makes the negative results sharp: the tree is free (distinct words reach distinct nodes; each level has exactly $3^h$ nodes, equidistributed over the three letters), the ambiguity resolved only by factorisation data is precisely the Brahmagupta–Fibonacci composition ambiguity, and the search economics are exact. Writing $E(h,a) = h a^{-h}$ for the expected node count of a restarted guided ascent of height $h$ with per-step accuracy $a$, we prove the brute-force threshold is exactly $1/3$ and the competitive threshold at height $30$ with a $3000$-visit budget is $0.85 < \alpha^\ast \le 0.86$; exhaustive search to depth $30$ costs $(3^{31}-1)/2 > 10^{14}$ visits, and every searcher with a budget below $3^h$ provably misses a depth-$h$ node, adaptively or not. Two rescue conjectures — that magnitude collisions must split letters, and that the $2$-adic Price sensor discriminates — are refuted by explicit infinite families.

**Keywords:** Pythagorean triples, Berggren tree, Price tree, ascent word, Gauss sums, sums of two squares, Brahmagupta–Fibonacci identity, $2$-adic valuation, search lower bounds, integer factorisation.

---

## 1. Introduction

### 1.1 The structure

A *primitive Pythagorean triple* is a triple $(x,y,z)$ of positive coprime integers with $x^2+y^2=z^2$. Euclid's parametrisation puts these in bijection with pairs $(m,n)$ of coprime integers of opposite parity with $m>n\ge 1$, via
$$x = m^2-n^2, \qquad y = 2mn, \qquad z = m^2+n^2 .$$
Berggren's theorem organises these pairs into a rooted ternary tree with root $(2,1)$ and three child maps; in the coordinates used here (Price's presentation) the maps are
$$A:(m,n)\mapsto(2m-n,\,m), \qquad B:(m,n)\mapsto(2m+n,\,m), \qquad C:(m,n)\mapsto(m+2n,\,n).$$
Every primitive triple appears exactly once. In particular every node carries a unique *ascent word* over $\{A,B,C\}$ recording the path from the root.

### 1.2 The question

Let $N = pq$ be a semiprime with $p\equiv q\equiv 1\pmod 4$. Then $N$ is a sum of two coprime squares, so $N$ is the hypotenuse of at least one node, and finding a node $(m,n)$ with $m^2+n^2=N$ yields the Gaussian factorisation of $N$, hence $p$ and $q$. The *energy-ascent programme* asks whether a spectrum, transform, or statistic computed from $N$ can guide a walk up the tree toward the node of $N$: at each step, predict the ascent letter, invert that branch, and recurse.

This paper answers: **no** — sealed at four strengths — and quantifies exactly what a hypothetical reopening probe would have to achieve.

### 1.3 Contributions

1. A complete, self-contained account of the tree's structural laws: coverage, uniqueness of parent, freeness on three generators, exact level sizes and exact letter equidistribution, and depth brackets.
2. Four independent blindness theorems, each with an explicit infinite witness family.
3. Identification of the information-bearing object: the Brahmagupta–Fibonacci composition ambiguity, which requires the factorisation.
4. Exact search economics: restart energy, a brute-force threshold of exactly $1/3$, a competitive accuracy bracket $0.85 < \alpha^\ast \le 0.86$, and unconditional adversary lower bounds.
5. Refutation of two natural rescue conjectures with explicit infinite families.
6. Two counting theorems on collisions, showing both letter-splitting and letter-preserving collisions are unbounded — so the mere existence of a collision is itself letter-free information.

---

## 2. Nodes, letters, and the tree

### 2.1 Definitions

**Definition 2.1 (Node).** A pair $(m,n)$ of naturals is a *node* if $1\le n<m$, $\gcd(m,n)=1$, and $m+n$ is odd. We write $\mathrm{hyp}(m,n)=m^2+n^2$, $\mathrm{leg_{odd}}(m,n)=m^2-n^2$, $\mathrm{leg_{even}}(m,n)=2mn$.

**Proposition 2.2 (Euclid).** For all $m,n$, $(m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2$; at a node all three quantities are positive naturals and the triple is primitive.

*Proof sketch.* The identity is a polynomial identity over $\mathbb{Z}$; positivity of $m^2-n^2$ follows from $n<m$. $\square$

**Definition 2.3 (Children).** $A(m,n) = (2m-n,m)$, $B(m,n)=(2m+n,m)$, $C(m,n)=(m+2n,n)$.

**Proposition 2.4 (Closure).** If $(m,n)$ is a node, so are $A(m,n)$, $B(m,n)$, $C(m,n)$.

*Proof sketch.* Order and positivity are elementary from $n<m$. Coprimality: $\gcd(2m-n,m)=\gcd(n,m)=1$, $\gcd(2m+n,m)=\gcd(n,m)=1$, $\gcd(m+2n,n)=\gcd(m,n)=1$. Opposite parity: each new sum is $3m-n$, $3m+n$, or $m+3n$, and $m+n$ odd forces $m,n$ of opposite parity, which is preserved. $\square$

**Definition 2.5 (Ascent letter).** For a node $(m,n)$,
$$\ell(m,n) = \begin{cases} A, & m<2n,\\ B, & 2n<m<3n,\\ C, & 3n<m.\end{cases}$$

**Lemma 2.6 (Trichotomy).** At any node other than the root $(2,1)$ we have $m\ne 2n$ and $m\ne 3n$, so exactly one of the three cases holds.

*Proof sketch.* $m=2n$ with $\gcd(m,n)=1$ forces $n=1$, $m=2$, the root. $m=3n$ with $\gcd(m,n)=1$ forces $n=1,m=3$, but then $m+n=4$ is even, contradicting the parity condition. $\square$

**Lemma 2.7 (The letter names the branch).** For a node $(m,n)$, $\ell(A(m,n)) = A$, $\ell(B(m,n)) = B$, $\ell(C(m,n))=C$.

*Proof sketch.* $A(m,n) = (2m-n,m)$ and $2m-n<2m$; $B(m,n)=(2m+n,m)$ with $2m<2m+n<3m$ since $n<m$; $C(m,n)=(m+2n,n)$ with $m+2n>3n$ since $m>n$. $\square$

**Definition 2.8 (Parent).** The parent map $\pi$ inverts the branch named by the ascent letter:
$$\pi(m,n) = \begin{cases} (n,\ 2n-m), & \ell(m,n) = A,\\ (n,\ m-2n), & \ell(m,n) = B,\\ (m-2n,\ n), & \ell(m,n) = C.\end{cases}$$

**Theorem 2.9 (Coverage and uniqueness).** Every node is reachable from the root $(2,1)$ by a finite sequence of child maps; $\pi$ maps every non-root node to a node, and $\pi(X(m,n)) = (m,n)$ for $X\in\{A,B,C\}$. Consequently the parent, and hence the entire ascent word, is uniquely determined by the node.

*Proof sketch.* Strong induction on $m$. Given a non-root node $(m,n)$, Lemma 2.6 selects a case; in each case the candidate parent is checked to be a node (order, coprimality via $\gcd$ invariance, parity), and its leading coordinate is strictly smaller than $m$: for letter $A$ the parent is $(n,2n-m)$ with $n<m$; for $B$ it is $(n,m-2n)$ with $n<m$; for $C$ it is $(m-2n,n)$ with $m-2n<m$. Descent terminates at the root. The identities $\pi\circ X = \mathrm{id}$ are direct computations using Lemma 2.7. $\square$

### 2.2 Freeness and the ascent word

**Definition 2.10 (Reading a word).** For a word $w = \ell_1\ell_2\cdots\ell_L$ over $\{A,B,C\}$ and a node $v$, let $\mathrm{follow}(w,v)$ be the result of applying $\ell_1$, then $\ell_2$, and so on.

**Theorem 2.11 (Normal form / freeness).** For every node $v$, the map $w \mapsto \mathrm{follow}(w,v)$ is injective on words over $\{A,B,C\}$; it is therefore a bijection onto the set of nodes lying below $v$. In particular every node of the tree carries a unique ascent word: the tree is free on its three generators.

*Proof sketch.* Each branch strictly increases the leading coordinate, so $\mathrm{follow}(w,v)$ has leading coordinate $\ge$ that of $v$, with equality only for the empty word; the length of a word is therefore bounded. Injectivity is by induction on length using the last letter: appending $\ell$ to $u$ produces a node whose ascent letter is $\ell$ (Lemma 2.7) and whose parent is $\mathrm{follow}(u,v)$ (Theorem 2.9). Hence the final letter and the prefix are both recoverable from the endpoint. $\square$

**Theorem 2.12 (Level sizes and letter equidistribution).** The depth-$h$ descendant set of any node has exactly $3^h$ elements. Writing $D_h$ for the set of nodes at depth $h$ below the root, $|D_h| = 3^h$, and for each letter $L$ and each $h$,
$$\#\{p\in D_{h+1} : \ell(p) = L\} = 3^{h},$$
so the three letter classes partition level $h+1$ into three equal parts.

*Proof sketch.* Level sizes: the three children of a node are pairwise distinct, and children of distinct nodes are distinct because the parent map recovers the node; induct. Equidistribution: by Theorem 2.11 the depth-$(h+1)$ nodes are indexed by words of length $h+1$, of which there are $3^{h+1}$, and the last letter of the word is exactly the ascent letter of the node; the words of length $h+1$ ending in a fixed letter number $3^h$. $\square$

**Theorem 2.13 (Depth bracket).** For a word $w$ of length $L$ read from the root, the leading coordinate $m$ of $\mathrm{follow}(w,(2,1))$ satisfies
$$2 + L \;\le\; m \;\le\; 2\cdot 3^{L}.$$
Both bounds are attained in growth rate. In particular the depth of a node with leading coordinate $m$ lies between $\log_3(m/2)$ and $m-2$.

*Proof sketch.* Each branch increases the leading coordinate by at least $1$ (lower bound) and multiplies it by at most $3$ (upper bound, using $n<m$). $\square$

**Theorem 2.14 (Depth is not logarithmic).** Applying $A$ exactly $k$ times to the root gives the node $(k+2,\,k+1)$, whose hypotenuse is $2k^2+6k+5$. Along this spine the depth grows like $\sqrt{N}$, not $\log N$.

*Proof sketch.* Induction: $A(m+1,m) = (m+2,m+1)$. The hypotenuse is $(k+2)^2 + (k+1)^2 = 2k^2+6k+5$. $\square$

Theorems 2.11–2.14 are the *positive* content that makes the programme plausible: the tree has clean addresses, exact level sizes, and no letter is rare. Everything that follows shows those addresses are unreadable from $N$.

---

## 3. Four blindness theorems

**Definition 3.1 (Letter blindness).** A sensor $s$ defined on nodes is *letter blind* if there exist nodes $(m,n)$ and $(m',n')$ with $s(m,n) = s(m',n')$ but $\ell(m,n)\ne\ell(m',n')$. Equivalently, no function of $s$ computes the ascent letter.

### 3.1 Strength 1: residue dials

**Theorem 3.2 (Residue blindness at every modulus and every scale).** Let $M\ge 1$ and let $n\ge2$ be even with $M\mid n$. Then $(n+1,n)$, $(2n+1,n)$, $(3n+1,n)$ are nodes with ascent letters $A$, $B$, $C$ respectively, and
$$\mathrm{hyp}(n+1,n) \equiv \mathrm{hyp}(2n+1,n)\equiv\mathrm{hyp}(3n+1,n)\equiv 1 \pmod M .$$
Such $n$ exist at every scale (take $n = 2Mt$, $t\ge1$).

*Proof sketch.* Nodehood: consecutive-type coprimality $\gcd(kn+1,n)=1$; the parity condition holds because $n$ is even. Letters: $n+1 < 2n$ for $n\ge2$ gives $A$; $2n<2n+1<3n$ for $n\ge2$ gives $B$; $3n+1>3n$ gives $C$. Residues: the hypotenuses are
$$2n^2+2n+1,\quad 5n^2+4n+1,\quad 10n^2+6n+1,$$
and writing $n = Mc$ each equals $1 + M\cdot(\text{integer})$. $\square$

**Corollary 3.3 (No residue dial computes the letter).** For every $M\ge1$ and every function $g$ from residues mod $M$ to letters, there is a node at which $g(\mathrm{hyp} \bmod M) \ne \ell$. In particular this holds for the smooth modulus $M = 720720 = 2^4\cdot3^2\cdot5\cdot7\cdot11\cdot13$.

*Proof sketch.* Apply Theorem 3.2 with $n = 2M$: the $A$-node and $B$-node give the same input to $g$ but demand different outputs. $\square$

### 3.2 Strength 2: Gauss-sum probes

**Definition 3.4 (Quadratic Gauss sum).** For $M\ge1$, $G_M(N) = \sum_{x=0}^{M-1} \exp(2\pi i N x^2/M)$.

**Lemma 3.5 (Periodicity).** For $M>0$ and all $N,k$, $G_M(N+kM) = G_M(N)$; equivalently $G_M(N) = G_M(N \bmod M)$.

*Proof sketch.* Each summand's exponent changes by $2\pi i k x^2$, an integer multiple of $2\pi i$. $\square$

**Theorem 3.6 (Gauss-sum probes are letter blind).** For every $M\ge1$ and every readout $g:\mathbb{C}\to\{A,B,C\}$ — magnitude, phase, or any function whatsoever — the probe $N\mapsto g(G_M(N))$ fails to compute the ascent letter at some node. This applies in particular to $M = 720720$.

*Proof sketch.* By Lemma 3.5, $g\circ G_M$ factors through $N\bmod M$; apply Corollary 3.3. $\square$

**Theorem 3.7 (Batteries stay blind).** Let $M\ge1$ and let $S$ be a finite set of positive moduli each dividing $M$. For every functional $\mathcal{G}$ of the vector $(G_d(N))_{d\in S}$, the probe $N\mapsto \mathcal{G}\big((G_d(N))_{d\in S}\big)$ is letter blind.

*Proof sketch.* If $d\mid M$ then $(N\bmod M)\bmod d = N \bmod d$, so the whole vector is a function of $N \bmod M$; apply Corollary 3.3. $\square$

This converts an empirical observation — "magnitude spectra built from Gauss sums show no positional signal" — into a statement about capacity: such spectra can carry no positional signal, at any modulus, in any readout, in any battery.

### 3.3 Strength 3: structural sensors are constant

**Definition 3.8 (Parity profile).** $\mathrm{par}(m,n) = \big(\mathrm{leg_{odd}} \bmod 2,\ \mathrm{leg_{even}}\bmod 2,\ \mathrm{hyp}\bmod 2\big)$.

**Theorem 3.9 (Structural constancy).** At every node, $\mathrm{par}(m,n) = (1,0,1)$, and the Lorentz form
$$(m^2-n^2)^2 + (2mn)^2 - (m^2+n^2)^2$$
vanishes identically. Consequently both sensors are letter blind for the trivial reason of being constant.

*Proof sketch.* $m+n$ odd means exactly one of $m,n$ is even, so $m^2-n^2$ and $m^2+n^2$ are odd and $2mn$ is even. The Lorentz form is the Pythagorean identity, a polynomial identity. Constant sensors take equal values at, e.g., the $A$-node $(19,12)$ and the $B$-node $(21,8)$. $\square$

A sensor with a single value has zero mutual information with the letter; the empirical reading of exactly $0.000000$ bits for bracket and sign-count sensors is explained, and shown to be exact rather than a rounded small number.

### 3.4 Strength 4: magnitude mirrors

This is the strongest seal: it removes the modulus, the transform, and the structure, and shows that even *perfect knowledge of $N$ itself* does not determine the letter.

**Theorem 3.10 (Magnitude collision family).** For every $t\ge1$, the pairs $(20t-1,\,10t+2)$ and $(20t+1,\,10t-2)$ are nodes, they share the hypotenuse
$$(20t-1)^2+(10t+2)^2 = (20t+1)^2+(10t-2)^2 = 500t^2+5 = 5\,(100t^2+1),$$
and their ascent letters are $A$ and $B$ respectively.

*Proof sketch.* Expansion gives both sides equal to $500t^2+5$. Nodehood: order and parity are immediate; coprimality follows because a common divisor would divide $2(20t-1)-(2)(\dots)$-type combinations reducing to $5$-free relations — concretely, any common factor of $20t-1$ and $10t+2$ divides $2(10t+2)-(20t-1) = 5$, and $5\nmid 20t-1$; similarly for the second pair, any common factor divides $(20t+1)-2(10t-2)=5$, and $5\nmid 20t+1$. Letters: $20t-1 < 2(10t+2) = 20t+4$, so letter $A$; and $2(10t-2) = 20t-4 < 20t+1 < 30t-6 = 3(10t-2)$ for $t\ge1$ (strictly for $t\ge 1$ with the small case checked directly), so letter $B$. $\square$

**Corollary 3.11 (No magnitude probe computes the letter).** There is no function $f:\mathbb{N}\to\{A,B,C\}$ with $f(\mathrm{hyp}(m,n)) = \ell(m,n)$ at every node. Equivalently, the ascent letter is not a function of the hypotenuse. Likewise the odd leg is not a function of the hypotenuse.

*Proof sketch.* Theorem 3.10 with $t=1$ gives $505 = 19^2+12^2 = 21^2+8^2$ with letters $A$ and $B$. The odd legs are $19^2-12^2 = 217$ and $21^2-8^2=377$. $\square$

The witness is a genuine semiprime: $505 = 5\cdot101$. Since every residue dial is in particular a function of $N$, Corollary 3.11 subsumes Corollary 3.3 — but the four strengths are stated separately because they are refutations of four separate probe classes actually deployed, and because Theorem 3.2 gives control at *every* scale and modulus simultaneously.

**Theorem 3.12 (Every dyadic window carries every letter).** For every $X\ge661$ and every letter $L$, there is a node with ascent letter $L$ whose hypotenuse lies in $[X,2X)$.

*Proof sketch.* Three explicit families supply the letters:
- $A$: $(m+1,m)$ for $m\ge2$, hypotenuse $2m^2+2m+1$;
- $B$: $(4u+1,2u)$ for $u\ge1$, hypotenuse $20u^2+8u+1$;
- $C$: $(8u+1,2u)$ for $u\ge1$, hypotenuse $68u^2+16u+1$.

Each family is a strictly increasing integer sequence whose consecutive ratio is below $2$ from a bounded point on; a discrete intermediate-value argument ("window hit") then guarantees a term in $[X,2X)$ once $X$ exceeds the threshold governed by the largest leading coefficient, here $661$. $\square$

**Corollary 3.13 (Decile sensors are support-blind).** No function of $\lfloor \log_2 N\rfloor$ computes the ascent letter for $N \ge 661$: knowing the log-magnitude decile of $N$ does not even restrict the support of the letter distribution.

*Proof sketch.* Take $X = 1024$; Theorem 3.12 supplies an $A$-node and a $B$-node with hypotenuses in $[1024,2048)$, hence with $\lfloor\log_2\rfloor = 10$. $\square$

This is the theorem that retracts the "spectral summary" probes: conditioned on the log-$N$ decile — which is the correct conditioning, see §7 — they are exact nulls.

---

## 4. Where the information lives: the composition ambiguity

**Theorem 4.1 (Brahmagupta–Fibonacci).** For all integers $a,b,c,d$,
$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2 = (ac+bd)^2+(ad-bc)^2 .$$

*Proof sketch.* Both are polynomial identities; equivalently $|z|^2|w|^2 = |zw|^2 = |z\bar w|^2$ for Gaussian integers $z = a+bi$, $w = c+di$. $\square$

**Theorem 4.2 (The collisions are exactly the two compositions).** Take $(a,b)=(2,1)$ so $a^2+b^2=5$, and $(c,d)=(k,1)$. The two Brahmagupta compositions of $5\,(k^2+1)$ are
$$(2k-1,\ k+2)\qquad\text{and}\qquad(2k+1,\ k-2),$$
which for $k=10t$ are precisely the two nodes of Theorem 3.10. They are always distinct points.

*Proof sketch.* Substitute into Theorem 4.1: $(ac-bd, ad+bc) = (2k-1, 2+k)$ and $(ac+bd,\,|ad-bc|) = (2k+1,\,|2-k|)$. Distinctness: the leading coordinates differ by $2$. $\square$

**Theorem 4.3 (Positional content requires the factorisation).** No probe reading only the hypotenuse computes the ascent letter (Corollary 3.11); yet the composition data $(a,b,c,d)$ — i.e. the factorisation of $N$ into two sums of two squares — determines which node is which, since it produces the two candidate nodes explicitly and they carry different letters for the family of Theorem 3.10.

This is the exact statement of the closure: the ambiguity in the address is the ambiguity in the composition, and resolving the latter is a factorisation-grade task. Empirical measurement of the best available factor-derived oracle places its peak positional content near $0.48$ bits per step; the four blindness theorems say that every probe that avoids the factorisation is at exactly $0$.

---

## 5. Two refuted rescue conjectures

### 5.1 The representation-orbit conjecture is false

**Conjecture (refuted).** *If $N$ has two distinct primitive representations as a sum of two squares, the corresponding nodes carry different ascent letters* — which would make "does $N$ collide?" a usable signal.

**Theorem 5.1 (Sophie Germain counterexample family).** Let $u = 2s+7$ for $s\ge0$, and set $N_s = u^4+4$. Then
$$N_s = (u^2-2u+2)(u^2+2u+2)$$
with both factors exceeding $1$, so $N_s$ is composite; the pairs $(u^2-2,\,2u)$ and $(u^2,\,2)$ are distinct nodes with $\mathrm{hyp} = N_s$; and **both carry ascent letter $C$**.

*Proof sketch.* $(u^2-2)^2 + (2u)^2 = u^4 - 4u^2 + 4 + 4u^2 = u^4+4 = (u^2)^2+4$. Nodehood: $u$ odd makes $u^2-2$ odd and $2u$ even (and $u^2$ odd, $2$ even), giving opposite parity; coprimality of $u^2-2$ and $2u$ holds because any common odd prime divides $u$ and $u^2-2$, hence $2$; coprimality of $u^2$ and $2$ is parity. Letters: $u\ge7$ gives $u^2-2 > 3\cdot 2u$ and $u^2 > 3\cdot 2$, so both are $C$. Distinctness: the small coordinates $2u$ and $2$ differ for $u\ge7$. $\square$

**Corollary 5.2 (Explicit witnesses).** The smallest instance is $2405 = 47^2+14^2 = 49^2+2^2$. A semiprime instance ($s=4$, $u=15$) is
$$50629 = 197\cdot257 = 223^2+30^2 = 225^2+2^2,$$
both nodes with letter $C$.

### 5.2 Both collision behaviours are unbounded

**Definition 5.3.** Say $N$ has a *splitting collision* if it has two distinct primitive representations whose nodes have different ascent letters; a *same-letter collision* if two distinct representations have equal letters.

**Theorem 5.4 (Counting).** For every $T$ there are at least $T$ splitting collisions below $500T^2+5$ (so at least $\sqrt{(X-5)/500}$ up to $X$), and at least $T$ same-letter collisions below $N_T \asymp T^4$ (so $\gg X^{1/4}$ up to $X$). Both counting functions are unbounded.

*Proof sketch.* The families $t\mapsto 500t^2+5$ and $s\mapsto N_s$ are strictly increasing, hence injective, and every member has the required property by Theorems 3.10 and 5.1; take the image of $\{1,\dots,T\}$. $\square$

**Corollary 5.5 (Collision dichotomy at every scale).** Above every bound there exist hypotenuses with splitting collisions and hypotenuses with same-letter collisions. Hence the predicate "$N$ admits a collision" is itself letter-free: it cannot be used as a positional signal.

### 5.3 The sharp two-adic cap is false

The Price tree's natural sensor is the $2$-adic valuation of the sum of two factors. It obeys exact laws.

**Theorem 5.6 (Two-adic law).** Let $p,q$ be odd. Then
$$v_2(p+q) = 1 \iff pq\equiv1\ (4), \qquad v_2(p+q)=2\iff pq\equiv3\ (8), \qquad 8\mid p+q \iff pq\equiv7\ (8).$$

*Proof sketch.* Write $p = 2P+1$, $q = 2Q+1$, so $pq = 4PQ + 2(P+Q)+1$ and $p+q = 2(P+Q+1)$. Then $4\nmid p+q$ iff $P+Q$ is even iff $pq\equiv1 \pmod 4$. The mod-$8$ statements follow from the same expansion by case analysis on $P,Q$ mod $4$; equivalently, $p+q\equiv 0 \pmod 8$ forces $q\equiv -p$, whence $pq \equiv -p^2 \equiv -1\equiv 7 \pmod 8$ since odd squares are $1$ mod $8$; the converse is the same computation run backwards over the four odd residues. $\square$

**Definition 5.7 (Price letters).** For odd $p,q$ and $i\ge0$, the $i$-th Price letter is $A$ (true) if $2^{i+2}\nmid p+q$ and $B$ (false) otherwise. The *Price word* of $N$ is $\big(N\equiv1\ (4),\ N\not\equiv 7\ (8)\big)$.

**Theorem 5.8 (The first two letters are a dial on $N\bmod 8$).** For odd $p,q$ with $N=pq$, the pair of the first two Price letters equals the Price word of $N$; hence $N\equiv M \pmod 8$ implies equal Price words. Moreover two odd numbers have the same Price word iff their residues mod $8$ agree or both lie in $\{1,5\}$ — the two classes the capped mechanism cannot separate.

*Proof sketch.* Immediate from Theorem 5.6; the final claim is a four-by-four case check on odd residues mod $8$. $\square$

**Theorem 5.9 (Death at position 2).** For every $m\equiv7\pmod{16}$, the odd number $N = 9m$ has the two odd factorisations $9\cdot m$ and $3\cdot(3m)$ whose Price letters agree at positions $0$ and $1$ (they must, being functions of $N$) but **disagree at position $2$**: $16\mid 9+m$ while $16 \nmid 3+3m$ (indeed $8 \mid 3+3m$). The smallest instance is $63 = 9\cdot7 = 3\cdot21$, with $v_2(16)=4$ and $v_2(24)=3$.

*Proof sketch.* $m\equiv7\ (16)$ gives $9+m\equiv 0 \ (16)$ and $3+3m \equiv 24 \equiv 8\ (16)$. $\square$

**Theorem 5.10 (Valuation-constant semiprimes: the cap conjecture fails).** Let $q$ be a prime with $q\equiv1\pmod{16}$ and put $N = 7q$. Then $N\equiv7\pmod 8$ and **every** factorisation $N = ab$ into positive factors has $v_2(a+b) = 3$ exactly. By Dirichlet's theorem such $N$ exist above every bound; the smallest is $119 = 7\cdot17$, where $v_2(120)=v_2(24)=3$.

*Proof sketch.* For prime $q\ne7$ the factorisations of $7q$ are exactly $1\cdot 7q$, $7\cdot q$, $q\cdot 7$, $7q\cdot1$. With $q\equiv1\ (16)$: $1+7q \equiv 8 \ (16)$ and $7+q\equiv 8\ (16)$, so both sums have $v_2 = 3$. $\square$

Thus the $2$-adic sensor is not merely a function of $N$ up to its cap (hence blind by Corollary 3.11); beyond the cap it is not a function of $N$ at all, and on an infinite family of semiprimes it is exactly constant — blind by repetition.

---

## 6. Search economics

### 6.1 Restart energy

**Definition 6.1.** A *guided ascent* of height $h$ with per-step accuracy $a\in(0,1]$ succeeds with probability $a^h$; restarting on failure, the expected number of node visits is the **restart energy**
$$E(h,a) = \frac{h}{a^{h}} = h\,a^{-h}.$$

**Theorem 6.2 (Basic laws).** For $0<a\le1$: (i) $E(h,a)\ge h$; (ii) if $a<1$ then $E(h,a) < E(h+1,a)$ — the energy strictly increases with height; (iii) for $h\ge1$ and $0<a<b$, $E(h,b) < E(h,a)$ — strictly decreasing in accuracy; (iv) $E(h,a)\le c \iff h \le c\,a^h$.

*Proof sketch.* (i) $a^h\le1$. (ii) Cross-multiplying, the claim is $h a^{h+1} < (h+1) a^h$, i.e. $ha<h+1$, true since $a<1$. (iii) $a^h<b^h$ for $h\ge1$. (iv) Clear denominators, $a^h>0$. $\square$

**Theorem 6.3 (Competitive accuracy bracket).** At height $30$ with a budget of $3000$ visit-equivalents, every accuracy $a\le0.85$ overshoots the budget, while $a = 0.86$ fits:
$$E(30,\,0.85) > 3000 \ge E(30,\,0.86).$$
Hence the critical accuracy satisfies $0.85 < \alpha^\ast \le 0.86$.

*Proof sketch.* By Theorem 6.2(iv) the budget conditions are $30 \le 3000\cdot a^{30}$, i.e. $a^{30}\ge 0.01$. Direct rational arithmetic gives $(17/20)^{30} < 1/100 \le (43/50)^{30}$. Monotonicity (Theorem 6.2(iii)) extends the failure to every $a\le0.85$. $\square$

Numerically, $0.85^{30}\approx 0.00760$ and $0.86^{30}\approx 0.01126$, bracketing $0.01$; the exact threshold is $\alpha^\ast = 100^{-1/30}\approx 0.85770$.

**Theorem 6.4 (Errors compound; class hints saturate).** If $0\le a<1$ then $a^h\to0$ as $h\to\infty$; quantitatively, for every $\varepsilon>0$ there is $H$ with $a^h<\varepsilon$ for all $h\ge H$. In particular a compounding sequential hint eventually falls below any fixed level $c>0$ that a saturating class hint could supply.

*Proof sketch.* Geometric decay. $\square$

This is the formal content of a taxonomy distinction observed empirically: hints that apply per step compound multiplicatively and therefore die, whereas a hint that saturates at a fixed class-level advantage does not — but for that very reason cannot be iterated into an ascent.

### 6.2 Against brute force

**Theorem 6.5 (Threshold exactly $1/3$).**
1. If $a>1/3$ then there is $H$ with $E(h,a) < 3^h$ for all $h\ge H$: the guided ascent eventually beats exhaustive search of a level.
2. If $0<a<1/3$ then there is $H$ with $3^h < E(h,a)$ for all $h\ge H$: the guided ascent eventually loses to brute force.
3. At $a = 1/2$ the guided ascent wins at *every* depth: $h\,2^h < 3^h$ for all $h\ge0$.

*Proof sketch.* (1) With $r = (3a)^{-1} < 1$, $h r^h \to 0$, and $h r^h<1$ is exactly $h < (3a)^h = 3^h a^h$, i.e. $E(h,a)<3^h$. (2) With $3a<1$, $(3a)^h\to0$, so eventually $3^h a^h < 1 \le h$, i.e. $3^h < E(h,a)$. (3) Induction: for $h\ge2$, $(h+1)2^{h+1} = 2(h+1)2^h \le 3h\,2^h < 3\cdot 3^h$. $\square$

The threshold $1/3$ is the reciprocal of the branching number: a probe must beat uniform random guessing to be worth switching on at all. Note the wide gap between "worth switching on" ($a>1/3$) and "competitive with the incumbent method" ($a>\alpha^\ast\approx 0.858$).

**Theorem 6.6 (The exhaustive alternative).** Exhaustive search of the ternary tree to depth $30$ visits $(3^{31}-1)/2$ nodes, which exceeds $10^{14}$.

*Proof sketch.* The complete ternary tree of depth $h$ has $1+3+\dots+3^{h} = (3^{h+1}-1)/2$ nodes; evaluate at $h=30$. $\square$

### 6.3 Adversary lower bounds

Because the ascent letter is not a function of $N$ (Corollary 3.11), a searcher receives no positional feedback before a hit, and the target may be placed adversarially anywhere on the level.

**Theorem 6.7 (Pigeonhole bound).** If a searcher visits a set $V$ of nodes with $|V| < 3^h$, then some depth-$h$ node is unvisited. If moreover $2|V| < 3^h$, then a strict majority of level $h$ is missed: $3^h < 2\,|D_h\setminus V|$.

*Proof sketch.* $|D_h| = 3^h$ by Theorem 2.12; if all depth-$h$ nodes were visited, $D_h\subseteq V$ and $3^h\le|V|$. The majority form follows from $|D_h\setminus V| + |D_h\cap V| = 3^h$ and $|D_h\cap V|\le |V|$. $\square$

**Theorem 6.8 (Adaptivity gains nothing).** Model a searcher as a sequence of guessed ascent words $S_0,S_1,\dots$. If it makes $k<3^h$ guesses, some word of length $h$ is never guessed; conversely, a searcher guaranteed to hit every depth-$h$ target must issue at least $3^h$ guesses.

*Proof sketch.* The image of $\{0,\dots,k-1\}$ under $S$ has at most $k$ elements, while there are exactly $3^h$ words of length $h$. $\square$

Combined with Theorem 2.14 — depth grows like $\sqrt{N}$ along the $A$-spine — the geometry is doubly unfavourable: targets can be deep, and depth costs exponentially.

---

## 7. Methodology: the correct null

A recurring failure mode in this programme deserves separate statement, because it invalidated several earlier positive readings.

**The row-shuffle null is wrong for deterministic functions of $N$.** A common validation permutes the labels across rows and re-measures the statistic, treating the shuffled distribution as the null. If the sensor is a deterministic function of $N$ and the label is correlated with $|N|$ (as tree position is, since deeper nodes have larger hypotenuses), then shuffling destroys the shared dependence on $|N|$ and the unshuffled statistic scores as "significant" purely by tracking magnitude. Under this null, magnitude mirrors look informative.

**The correct null conditions on magnitude.** Compare only within a bin of $\log N$ — a decile, say. Theorem 3.12 and Corollary 3.13 explain what then happens: within every dyadic window all three letters occur, so any sensor that is a function of $N$ collapses to a null. The retraction of the spectral summaries from "weak signal" to "exact null" is precisely this correction applied.

Two further practices are worth recording. *Derivation-first validation*: before measuring, ask whether the sensor factors through a quantity already proven blind — Theorems 3.2, 3.6, 3.9, 3.10 make this a mechanical check. *Smoke runs as mechanism detectors*: a pilot that succeeds implausibly well usually indicates that a mechanism (a constant, a periodicity, a leaked label) has been discovered, not a signal; the exact identities of Theorem 3.9 were found this way.

---

## 8. Algorithms

Three procedures organise the computational content.

**Ascent-word decoding.** Given a node $(m,n)$, repeatedly read the letter by comparing $m$ with $2n$ and $3n$, apply the corresponding parent map, and prepend the letter; terminate at $(2,1)$. Each step strictly decreases $m$, so termination is guaranteed; the number of steps is between $\log_3(m/2)$ and $m-2$ (Theorem 2.13). The decoder is exact and cheap *given the node* — which is the whole point: the expensive part is finding the node from $N$.

**Collision enumeration.** For a target $N$, enumerate $n$ from $1$ to $\lfloor\sqrt{N/2}\rfloor$, test whether $N-n^2$ is a perfect square, and collect all primitive representations. Cost $O(\sqrt N)$ — the same order as trial division, which is why enumeration is not a shortcut; it serves to *exhibit* collisions, not to exploit them.

**Restart-energy planning.** Given a budget $c$ and a height $h$, solve $h \le c\,a^{h}$ for the minimal admissible accuracy $\alpha^\ast = (h/c)^{1/h}$, and compare with the brute-force threshold $1/3$ and with the exhaustive cost $(3^{h+1}-1)/2$. At $h=30$, $c=3000$: $\alpha^\ast = 100^{-1/30}\approx0.8577$, consistent with the exact bracket $0.85<\alpha^\ast\le0.86$ of Theorem 6.3.

---

## 9. Discussion

The Berggren tree is an unusually clean object: free, ternary, complete, with an exact address for every primitive triple and exact equidistribution of letters at every level. That cleanliness is what makes it a tempting lever against factorisation, and also what makes the negative result so sharp. The map from *address* to *hypotenuse* is many-to-one in a controlled, explicitly parametrised way — the Brahmagupta–Fibonacci composition ambiguity — and every collision family we exhibit is an instance of it. Since the fibre of the map over $N$ is exactly the set of ways of writing $N$ as a sum of two coprime squares, and since determining that set is factorisation-equivalent for semiprimes, positional information about the tree is not merely *hard* to extract from $N$; for a large class of probes it is *absent* from the data those probes see.

It is worth being precise about the logical shape of each seal. Strengths 1 and 2 are statements about *representability*: the probe's input is a coarsening of $N$, and the coarsening merges nodes with different letters. Strength 3 is degenerate: the probe's output is constant. Strength 4 is the strongest and simplest: the target function is not a function of the probe's input even when that input is all of $N$. Once Strength 4 is available, Strengths 1–3 follow logically — but not historically or practically, and Theorem 3.2's uniformity over all moduli and all scales is genuinely stronger than what Corollary 3.11 provides at any single witness.

The economics complete the picture from the other side. Even granting an oracle that is not blind, it must clear $\alpha^\ast\approx0.858$ at height $30$ to be competitive within $3000$ visits, and it must clear $1/3$ merely to beat brute force. The best positional content measured for any factor-derived oracle is about $0.48$ bits per step. A three-way choice carries $\log_2 3 \approx 1.585$ bits, and an accuracy of $0.86$ corresponds to substantially more than half a bit of information gain per step; the measured ceiling and the required floor are on the wrong sides of each other.

---

## 10. Future work

The closure is not a proof that factoring is hard; it is a proof that this particular geometry does not help a specific, broad class of methods. Several genuinely open questions remain.

1. **Densities.** Both splitting and same-letter collisions are unbounded (Theorem 5.4), with lower bounds $\sqrt{X/500}$ and $\gg X^{1/4}$. What are the true asymptotic densities? Is the proportion of splitting collisions among all collisions bounded away from $0$ and $1$?
2. **Frequency halves.** The support-level statements of §3 have natural frequency analogues: given the log-magnitude decile, is the letter distribution asymptotically uniform, or merely full-support? Exact equidistribution over the *tree* measure is Theorem 2.12; equidistribution over the *arithmetic* measure (nodes ordered by hypotenuse) is open.
3. **Beyond the four kinds.** Is there a probe consuming side information strictly weaker than the factorisation that nonetheless reads the letter? Natural candidates: partial factorisation data, class-group information for $\mathbb{Z}[i]$, or quantum period-finding restricted to the composition structure.
4. **Other trees.** The analysis is specific to the ternary Berggren/Price presentation. Do other generating trees for triples — or the analogous trees for higher-degree forms — exhibit the same composition-ambiguity obstruction?
5. **Sharper economics.** The bracket $0.85<\alpha^\ast\le0.86$ is for the specific pair $(h,c) = (30,3000)$. A uniform treatment of the trade-off surface $\alpha^\ast(h,c) = (h/c)^{1/h}$, including a model where accuracy varies with depth, would tell us how a depth-adaptive oracle would have to behave.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Coverage and freeness | Every node is reachable from $(2,1)$; distinct words reach distinct nodes; every node has a unique ascent word. |
| Level structure | Level $h$ has exactly $3^h$ nodes; at level $h+1$ each of the three letters occurs exactly $3^h$ times. |
| Depth bracket | A word of length $L$ from the root reaches leading coordinate in $[2+L,\,2\cdot3^L]$; along the $A$-spine, $\mathrm{hyp} = 2k^2+6k+5$, so depth $\sim\sqrt{N}$. |
| Residue blindness | For every $M$ and every scale, three nodes with letters $A,B,C$ and hypotenuses all $\equiv1 \bmod M$. |
| Gauss-sum blindness | $G_M(N)$ is $M$-periodic; every readout, and every finite battery of moduli dividing $M$, is blind. |
| Structural constancy | Parity profile is $(1,0,1)$ at every node; the Lorentz form vanishes identically. |
| Magnitude blindness | $\mathrm{hyp}(20t-1,10t+2) = \mathrm{hyp}(20t+1,10t-2) = 500t^2+5$ with letters $A$ and $B$; smallest case $505 = 5\cdot101$. |
| Window fullness | For every $X\ge661$ each letter occurs in $[X,2X)$; decile sensors are support-blind. |
| Composition ambiguity | The two colliding nodes are the two Brahmagupta–Fibonacci compositions of the factorisation. |
| Orbit conjecture false | $u^4+4 = (u^2-2)^2+(2u)^2 = (u^2)^2+2^2$ with both letters $C$; $2405$, and the semiprime $50629 = 197\cdot257$. |
| Collision counts | $\ge\sqrt{(X-5)/500}$ splitting and $\gg X^{1/4}$ same-letter collisions up to $X$; both unbounded. |
| Two-adic law | $v_2(p+q)=1\iff pq\equiv1\ (4)$; $=2\iff pq\equiv3\ (8)$; $\ge3\iff pq\equiv7\ (8)$. |
| Death at position 2 | For $m\equiv7\ (16)$, $9m = 9\cdot m = 3\cdot 3m$ disagree at Price letter $2$; smallest $63$. |
| Cap conjecture false | For prime $q\equiv1\ (16)$, every factorisation of $7q$ has $v_2(a+b)=3$; smallest $119 = 7\cdot17$. |
| Restart energy | $E(h,a) = ha^{-h}$; $\ge h$; increasing in $h$; decreasing in $a$; $E\le c \iff h\le c a^h$. |
| Competitive accuracy | $E(30,0.85)>3000\ge E(30,0.86)$, so $0.85<\alpha^\ast\le0.86$. |
| Brute-force threshold | $a>1/3$ eventually beats $3^h$; $a<1/3$ eventually loses; $h2^h<3^h$ for all $h$. |
| Exhaustive cost | Depth-$30$ sweep visits $(3^{31}-1)/2 > 10^{14}$ nodes. |
| Search lower bounds | Budget $<3^h$ misses a depth-$h$ node; budget $<3^h/2$ misses a majority; adaptivity gains nothing. |
