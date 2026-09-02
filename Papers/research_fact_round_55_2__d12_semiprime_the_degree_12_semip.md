# The Splitting-Type Channel of a Semiprime in a Cyclic Extension

### Exact enumeration laws, a symmetrization defect, and an unconditional which-factor wall

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

Let $K/\mathbb{Q}$ be a cyclic extension of degree $n$, with
$\operatorname{Gal}(K/\mathbb{Q}) \cong \mathbb{Z}/n$, and let $N = pq$ be a
semiprime whose two prime factors are unramified in $K$. Each factor carries a
*splitting type* — the order of its Frobenius element, equivalently its residue
degree in $K$ — and the Frobenius of $N$ is the product of the two Frobenii. We
study the exact information-theoretic relationship, under the equidistributed
(Chebotarev) model, between the residue class of $N$ and the unordered pair of
splitting types of its factors.

We prove three results, each valid for every cyclic order $n$, together with
their sharp degree-$12$ specialisations (the case $K = \mathbb{Q}(\zeta_{13})$).

1. **An exact enumeration law.** For divisors $d \le e$ of $n$, the number of
   Frobenius exponent pairs whose unordered splitting-type pair equals
   $\{d,e\}$ is $\varphi(d)\varphi(e)$ when $d = e$ and $2\varphi(d)\varphi(e)$
   otherwise; these are the only type pairs realised, and the counts partition
   the $n^2$ exponent pairs. Consequently the type-pair entropy satisfies the
   closed form $H(\Pi) = \log_2(n^2) - n^{-2}\sum_{d \le e} c_{d,e}\log_2 c_{d,e}$.
2. **A which-factor wall.** On the sub-population where the two factors have
   distinct splitting types, the Boolean "which factor carries the smaller
   type?" has entropy exactly $1$ bit, while *every* read-out symmetric in the
   two factors has mutual information exactly $0$ with it. The bound is sharp:
   the ordered type read-out recovers the entire bit.
3. **A symmetrization-defect law.** $H(\Pi) = 2H(T) - \#\mathrm{asym}(n)/n^2$,
   where $H(T)$ is the single-prime splitting-type entropy and
   $\#\mathrm{asym}(n) = n^2 - \sum_{d\mid n}\varphi(d)^2$. The entropy cost of
   forgetting the order of the two factors is precisely the probability that the
   order is a meaningful question — the exact population on which the wall
   operates. This yields the sandwich $2H(T) - 1 \le H(\Pi) < 2H(T)$.

At $n = 12$ these give $H(\Pi) = \tfrac78 + 2\log_2 3$ and
$I_{\mathrm{pair}}(12) = \tfrac{5}{36} + \log_2 3 \approx 1.7239$ bits, and
$\#\mathrm{asym}(12) = 114$ with defect $19/24$. We additionally determine the
coarser *split-count* channel exactly,
$I_{\mathrm{split}}(12) = \tfrac{199}{72} + \log_2 3 + \tfrac{55}{72}\log_2 5 - \tfrac{253}{144}\log_2 11 \approx 0.0445$
bits, prove $0 < I_{\mathrm{split}}(12) < 1/8$ and
$I_{\mathrm{split}}(12) < I_{\mathrm{pair}}(12)/10$, and explain the smallness by
a rigidity phenomenon: eleven of the twelve residue classes of $N$ carry an
identical split-count profile $(2,10)$, the twelfth carrying $(1,11)$.

**Keywords:** cyclic extension, Frobenius element, splitting type, Euler
totient, Shannon entropy, mutual information, semiprime, symmetrization defect.

---

## 1. Introduction

### 1.1 The question

A semiprime $N = pq$ is the standard object of hardness assumptions in
public-key cryptography, and the standard question about it — recover $p$ and
$q$ — is a global one. A finer family of questions asks not for the factors but
for *invariants* of them, and asks how much of each invariant is visible in $N$.

Fix a cyclic number field $K/\mathbb{Q}$ of degree $n$. Class field theory
attaches to each unramified prime $p$ a Frobenius element
$\mathrm{Frob}_p \in \operatorname{Gal}(K/\mathbb{Q}) \cong \mathbb{Z}/n$, and
the *splitting type* of $p$ in $K$ — the common residue degree of the primes of
$K$ above $p$, equivalently $n$ divided by the number of such primes — is the
order of $\mathrm{Frob}_p$ in the group. The Frobenius symbol is multiplicative
in the sense relevant here: the class of $N = pq$ in the associated ray class
group is the product of the classes of $p$ and $q$, so in exponent coordinates
on $\mathbb{Z}/n$ the exponent of $N$ is the *sum* of the exponents of $p$ and
$q$.

An observer sees $N$; equivalently, in the model below, the observer sees the
exponent sum. The observer would like to know the pair of splitting types. Since
$N = pq = qp$, everything the observer can compute is symmetric in the two
factors, so the accessible target is the *unordered* pair. The natural
quantitative question is: what is the mutual information between the residue
class of $N$ and the unordered splitting-type pair of its factors?

### 1.2 The model

We work with the equidistributed model, which the Chebotarev density theorem
justifies asymptotically: the Frobenius exponents of the two prime factors are
independent and uniform on $\mathbb{Z}/n$. All entropies below are entropies of
push-forwards of the uniform measure on the $n^2$-element exponent box, and are
therefore exact rational combinations of logarithms — there is no sampling and
no approximation anywhere in this paper.

### 1.3 Contributions

Prior work in this programme evaluated the type-pair channel one cyclic order at
a time, by explicit enumeration of the $n^2$ exponent pairs and their fibre
sizes. The present work removes the enumeration entirely. Sections 3–5 establish
three theorems valid for all $n$; Section 6 specialises them to $n = 12$ and
determines the split-count channel exactly; Section 7 gives algorithms and
Section 8 discusses limitations and open problems.

---

## 2. Definitions

Throughout, $n \ge 1$ is an integer, $\varphi$ is Euler's totient function,
$\log_2$ is the base-two logarithm, and $0\log_2 0 := 0$.

**Definition 2.1 (Exponent box).** The *exponent box* is
$$\mathcal{B}_n := \{0,1,\dots,n-1\}^2,$$
the set of Frobenius exponent pairs $(a,b)$ of the two prime factors of a
semiprime. It has $n^2$ elements, each of equal probability $n^{-2}$.

**Definition 2.2 (Splitting type).** For $a \in \{0,\dots,n-1\}$ the *splitting
type* is the order of $a$ in $\mathbb{Z}/n$,
$$T(a) := \frac{n}{\gcd(n,a)} .$$
Thus $T(a) \mid n$, $T(0) = 1$ (the prime splits completely), and $T(a) = n$
exactly when $a$ generates (the prime is inert).

**Definition 2.3 (Type pair).** The *unordered splitting-type pair* of
$(a,b) \in \mathcal{B}_n$ is
$$\Pi(a,b) := \big(\min(T(a),T(b)),\ \max(T(a),T(b))\big),$$
a canonical representative of the unordered pair $\{T(a),T(b)\}$. It is
symmetric: $\Pi(b,a) = \Pi(a,b)$.

**Definition 2.4 (Residue of the semiprime).** The *residue read-out* is
$$R(a,b) := a + b \bmod n,$$
the Frobenius exponent of $N = pq$. It is symmetric.

**Definition 2.5 (Split count).** The *split count* of a type pair $(d,e)$ is
$$s(d,e) := \#\{i \in \{1,2\} : \text{the } i\text{-th entry equals } 1\} \in \{0,1,2\},$$
the number of factors of $N$ that split completely. We write $s(a,b)$ for
$s(\Pi(a,b))$.

**Definition 2.6 (Which-factor bit and the asymmetric population).** Put
$$\mathrm{asym}(n) := \{(a,b) \in \mathcal{B}_n : T(a) \neq T(b)\},$$
and on it define the Boolean
$$W(a,b) := \big[\,T(a) < T(b)\,\big].$$
$W$ answers "does the first factor carry the smaller splitting type?" — a
question that is meaningful precisely on $\mathrm{asym}(n)$.

**Definition 2.7 (Entropies).** For a finite nonempty set $S$ and a map $f$ on
$S$, the *entropy* of $f$ under the uniform measure on $S$ is
$$H_S(f) := \log_2 |S| - \frac{1}{|S|}\sum_{x \in S} \log_2 \#\{y \in S : f(y) = f(x)\},$$
which is the usual Shannon entropy $-\sum_v P(v)\log_2 P(v)$ of the push-forward
of the uniform measure. For a second map $k$ on $S$,
$$H_S(f \mid k) := \sum_{c \in k(S)} \frac{\#k^{-1}(c)}{|S|}\, H_{k^{-1}(c)}(f),
\qquad I_S(f;k) := H_S(f) - H_S(f\mid k).$$

**Definition 2.8 (The channels).** With $S = \mathcal{B}_n$ we write
$$H(T) := H_{\{0,\dots,n-1\}}(T), \qquad H(\Pi) := H_{\mathcal{B}_n}(\Pi),$$
$$I_{\mathrm{pair}}(n) := I_{\mathcal{B}_n}(\Pi ; R), \qquad
I_{\mathrm{split}}(n) := I_{\mathcal{B}_n}(s ; R).$$
$I_{\mathrm{pair}}$ is the number of bits the residue of $N$ reveals about the
unordered splitting-type pair of its two factors; $I_{\mathrm{split}}$ is the
same quantity for the coarser split-count read-out.

**Definition 2.9 (The divisor-pair alphabet and the predicted counts).** Set
$$\mathcal{D}_n := \{(d,e) : d \mid n,\ e \mid n,\ d \le e\},
\qquad
c_{d,e} := \begin{cases}\varphi(d)\varphi(e), & d = e,\\ 2\varphi(d)\varphi(e), & d < e.\end{cases}$$

---

## 3. The exact enumeration law

The single arithmetic input is the classical fibre count for the order function
on a cyclic group: for $d \mid n$,
$$\#\{a \in \{0,\dots,n-1\} : T(a) = d\} = \varphi(d), \tag{3.1}$$
whence $\sum_{d \mid n}\varphi(d) = n$.

**Lemma 3.1 (Fibre geometry).** Let $n \ge 1$ and $d, e \mid n$.

* *(Diagonal.)* $\Pi^{-1}(d,d) = T^{-1}(d) \times T^{-1}(d)$, a combinatorial
  square.
* *(Off-diagonal.)* If $d < e$ then
  $\Pi^{-1}(d,e) = \big(T^{-1}(d) \times T^{-1}(e)\big) \sqcup \big(T^{-1}(e) \times T^{-1}(d)\big)$,
  a disjoint union of two rectangles.

*Proof sketch.* $\Pi(a,b) = (d,d)$ forces $\min = \max = d$, hence
$T(a) = T(b) = d$; conversely such a pair has $\Pi = (d,d)$. For $d < e$,
$\Pi(a,b) = (d,e)$ says $\{T(a),T(b)\} = \{d,e\}$, and since $d \neq e$ exactly
one of the two assignments holds; the two rectangles are disjoint because a pair
in both would need $T(a) = d$ and $T(a) = e$. $\square$

**Theorem 3.2 (Exact enumeration law).** *Let $n \ge 1$ and $(d,e) \in \mathcal{D}_n$.
Then*
$$\#\{(a,b) \in \mathcal{B}_n : \Pi(a,b) = (d,e)\} \;=\; c_{d,e}.$$

*Proof sketch.* Combine Lemma 3.1 with the fibre count (3.1). On the diagonal
the square has $\varphi(d)^2 = c_{d,d}$ elements; off the diagonal the two
disjoint rectangles contribute $2\varphi(d)\varphi(e) = c_{d,e}$. $\square$

**Theorem 3.3 (Support).** *For $n \ge 1$ the image of $\Pi$ on $\mathcal{B}_n$
is exactly $\mathcal{D}_n$.*

*Proof sketch.* Forward: $T(a) \mid n$ always, and $\Pi$ outputs
$(\min,\max)$, so the image lies in $\mathcal{D}_n$. Backward: given divisors
$d \le e$ of $n$, choose by (3.1) exponents $a$ with $T(a) = d$ and $b$ with
$T(b) = e$; then $\Pi(a,b) = (d,e)$. $\square$

**Corollary 3.4 (Partition law).** *For $n \ge 1$,
$\displaystyle\sum_{(d,e) \in \mathcal{D}_n} c_{d,e} = n^2$.*

*Proof sketch.* The fibres of $\Pi$ partition $\mathcal{B}_n$; by Theorem 3.3
they are indexed by $\mathcal{D}_n$ and by Theorem 3.2 they have sizes $c_{d,e}$.
$\square$

**Theorem 3.5 (Entropy law).** *For $n \ge 1$,*
$$H(\Pi) \;=\; \log_2\!\big(n^2\big) \;-\; \frac{1}{n^2}\sum_{(d,e)\in\mathcal{D}_n} c_{d,e}\log_2 c_{d,e}. \tag{3.2}$$

*Proof sketch.* Definition 2.7 rewrites $H_S(f)$ as
$\log_2|S| - |S|^{-1}\sum_{v \in f(S)} \#f^{-1}(v)\log_2 \#f^{-1}(v)$ by grouping
the sum over $x$ into fibres. Apply this with $S = \mathcal{B}_n$
($|S| = n^2$) and $f = \Pi$, then substitute the image (Theorem 3.3) and the
fibre sizes (Theorem 3.2). $\square$

Formula (3.2) reduces a computation over $n^2$ points to a sum over the
$\binom{\tau(n)+1}{2}$ unordered divisor pairs, where $\tau(n)$ is the number of
divisors — a reduction from quadratic in $n$ to (essentially) $\tau(n)^2$ terms.

---

## 4. The which-factor wall

This section is pure symmetry: no arithmetic is used, and the statements hold
for arbitrary finite populations. That generality is the point — the wall is a
statement about the orbit structure of a two-element group acting on the fibres
of a measurement, not about splitting types.

**Lemma 4.1 (Balanced classes).** *Let $S$ be a finite set, $w : S \to \{0,1\}$,
and $\sigma : S \to S$ satisfying $\sigma(S) \subseteq S$,
$\sigma\circ\sigma = \mathrm{id}$ on $S$, and $w(\sigma x) = \lnot\, w(x)$ for
all $x \in S$. Then $\#w^{-1}(0) = \#w^{-1}(1)$, so $2\,\#w^{-1}(b) = |S|$ for
each $b$.*

*Proof sketch.* $\sigma$ restricts to a bijection $w^{-1}(b) \to w^{-1}(\lnot b)$,
with inverse itself. $\square$

**Theorem 4.2 (One hidden bit).** *Under the hypotheses of Lemma 4.1 with $S$
nonempty, $H_S(w) = 1$.*

*Proof sketch.* By Lemma 4.1, each label class has size $|S|/2$, so
$\log_2 \#w^{-1}(w(x)) = \log_2|S| - 1$ for every $x$; substitute in
Definition 2.7. $\square$

**Theorem 4.3 (The wall).** *Let $S$, $w$, $\sigma$ be as in Theorem 4.2, and
let $k : S \to \Gamma$ be any map into any set with $k(\sigma x) = k(x)$ for all
$x \in S$. Then*
$$I_S(w ; k) = 0 .$$

*Proof sketch.* Fix a value $c \in k(S)$ and put $S_c := k^{-1}(c)$. Because
$\sigma$ preserves $k$, it maps $S_c$ into itself, and it still is an involution
that flips $w$ there; $S_c$ is nonempty. Theorem 4.2 applied to $S_c$ gives
$H_{S_c}(w) = 1$. Hence
$H_S(w \mid k) = \sum_c \frac{|S_c|}{|S|}\cdot 1 = 1$, since the fibre sizes sum
to $|S|$. Also $H_S(w) = 1$ by Theorem 4.2, so the mutual information is
$1 - 1 = 0$. $\square$

The mechanism deserves a sentence of emphasis: conditioning on *any* symmetric
observation leaves each conditional distribution of $w$ an exactly fair coin,
because the involution acts within each observation class while flipping the
label. The zero is not an averaging artefact; it holds class by class.

**Lemma 4.4 (Sharpness input).** *If $g$ is a function of $k$ — that is
$g = h \circ k$ for some $h$ — then $H_S(g \mid k) = 0$, because $g$ is constant
on each fibre of $k$ and the entropy of a constant vanishes.*

Now specialise. On $S = \mathrm{asym}(n)$ take $\sigma$ to be the coordinate
swap $(a,b) \mapsto (b,a)$ and $w = W$.

**Lemma 4.5 (The swap is admissible).** *For $n \ge 2$: (i) $\mathrm{asym}(n)$ is
nonempty; (ii) the swap maps $\mathrm{asym}(n)$ to itself and is an involution;
(iii) $W(b,a) = \lnot\, W(a,b)$ on $\mathrm{asym}(n)$.*

*Proof sketch.* (i) Take $(a,b) = (0,1)$: $T(0) = 1$ while $T(1) = n \ge 2$.
(ii) The defining condition $T(a) \neq T(b)$ is symmetric. (iii) On
$\mathrm{asym}(n)$ we have $T(a) \neq T(b)$, so exactly one of $T(a) < T(b)$,
$T(b) < T(a)$ holds. $\square$

**Theorem 4.6 (The which-factor wall).** *Let $n \ge 2$ and let
$k : \mathcal{B}_n \to \Gamma$ be **any** read-out symmetric in the two factors,
i.e. $k(b,a) = k(a,b)$ for all $(a,b)$. Then, on the population
$\mathrm{asym}(n)$,*
$$H(W) = 1 \qquad\text{and}\qquad I(W ; k) = 0 .$$

*Proof sketch.* Lemma 4.5 verifies the hypotheses of Theorems 4.2 and 4.3 with
$\sigma$ the swap. $\square$

Taking $k(a,b) = (\Pi(a,b), R(a,b))$ — the unordered splitting-type pair
*together with* the residue of $N$ — the theorem says an observer holding both
learns nothing at all about which factor owns which type. Since the hypothesis
on $k$ is only symmetry, the same holds for the residue of $N$ to *any* modulus,
for $N$ itself, for the ordinary product $pq$, and for any joint tuple of such
quantities: enriching a symmetric observation cannot break the wall.

**Theorem 4.7 (Sharpness: the wall is not an entropy deficit).** *For $n \ge 2$,
the ordered read-out $O(a,b) := (T(a), T(b))$ satisfies, on $\mathrm{asym}(n)$,*
$$I(W ; O) = 1 .$$

*Proof sketch.* $W = h \circ O$ with $h(x,y) = [x<y]$, so $H(W\mid O) = 0$ by
Lemma 4.4, and $H(W) = 1$ by Theorem 4.2. $\square$

Thus a full bit of which-factor information genuinely exists and is entirely
destroyed by symmetry, not by lack of content. In particular, for the degree-12
case, $I(W ; (\Pi,R)) = 0 < 1 = I(W ; O)$ is a strict gap.

**Corollary 4.8 (Degree 12).** *For $n = 12$ the asymmetric population has
$\#\mathrm{asym}(12) = 114$ of the $144$ exponent pairs, on which the
which-factor bit has entropy exactly $1$ and mutual information exactly $0$ with
the unordered type pair together with the residue of $N$ modulo $13$.*

The count $114 = 144 - 30$ comes from $\sum_{d \mid 12}\varphi(d)^2 = 1+1+4+4+4+16 = 30$;
see Lemma 5.4.

---

## 5. The symmetrization-defect law

The enumeration law of Section 3 and the wall of Section 4 turn out to be two
faces of one identity.

**Lemma 5.1 (Symmetric square split).** *Let $D$ be a finite set of integers and
$g$ a symmetric function on $D \times D$ (i.e. $g(x,y) = g(y,x)$). Then*
$$\sum_{(x,y) \in D\times D} g = \sum_{x \in D} g(x,x) \;+\; 2\!\!\sum_{\substack{(x,y)\in D\times D\\ x<y}}\!\! g .$$

*Proof sketch.* Split the square into diagonal, strict upper triangle and strict
lower triangle; the swap $(x,y)\mapsto(y,x)$ is a bijection between the two
triangles preserving $g$. $\square$

**Lemma 5.2 (Kernel decomposition).** *Write, for $d,e \mid n$,*
$$A(d,e) := \varphi(d)\varphi(e)\big(\log_2\varphi(d) + \log_2\varphi(e)\big), \qquad
M(d,e) := \varphi(d)\varphi(e).$$
*Then $c_{d,d}\log_2 c_{d,d} = A(d,d)$, and for $d < e$,
$c_{d,e}\log_2 c_{d,e} = 2A(d,e) + 2M(d,e)$.*

*Proof sketch.* On the diagonal $c_{d,d} = \varphi(d)^2$, so
$c\log_2 c = \varphi(d)^2 \cdot 2\log_2\varphi(d) = A(d,d)$. Off the diagonal
$c = 2\varphi(d)\varphi(e)$ and
$\log_2 c = 1 + \log_2\varphi(d) + \log_2\varphi(e)$; multiplying out gives
$2M + 2A$. All totients involved are positive because $d,e \mid n$ with $n \ge 1$,
so the logarithms are legitimate. $\square$

The extra $2M$ term is exactly the arithmetic trace of the "factor of $2$" in
the enumeration law: the cost of forgetting which factor got which type.

**Lemma 5.3 (Kernel sums).** *With $D = \{d : d \mid n\}$,*
$$\sum_{(d,e)\in D\times D} A(d,e) = 2n\sum_{d\mid n}\varphi(d)\log_2\varphi(d),
\qquad
\sum_{(d,e)\in D\times D} M(d,e) = n^2 .$$

*Proof sketch.* Both are separable double sums; evaluate the inner sum and use
$\sum_{d\mid n}\varphi(d) = n$ twice. $\square$

**Theorem 5.4 (Counting identity).** *For $n \ge 1$,*
$$\sum_{(d,e)\in\mathcal{D}_n} c_{d,e}\log_2 c_{d,e}
= 2n\sum_{d\mid n}\varphi(d)\log_2\varphi(d) \;+\; \Big(n^2 - \sum_{d\mid n}\varphi(d)^2\Big).$$

*Proof sketch.* Split $\mathcal{D}_n$ into diagonal and strict upper triangle and
apply Lemma 5.2 termwise, obtaining
$\sum_{\mathrm{diag}} A + 2\sum_{\mathrm{up}} A + 2\sum_{\mathrm{up}} M$. By
Lemma 5.1 the first two terms combine into the full square sum of $A$, and
$2\sum_{\mathrm{up}} M = \sum_{\mathrm{square}} M - \sum_{\mathrm{diag}} M$.
Now use Lemma 5.3 and $\sum_{\mathrm{diag}} M = \sum_{d\mid n}\varphi(d)^2$. $\square$

**Lemma 5.5 (Count form of the single-type entropy).** *For $n \ge 1$,*
$$H(T) = \log_2 n - \frac{1}{n}\sum_{d\mid n}\varphi(d)\log_2\varphi(d).$$

*Proof sketch.* The fibres of $T$ on $\{0,\dots,n-1\}$ are indexed by the
divisors of $n$ and have sizes $\varphi(d)$ by (3.1); substitute into
Definition 2.7. $\square$

**Lemma 5.6 (The asymmetric population).** *For $n \ge 1$,*
$$\#\{(a,b) : T(a) = T(b)\} = \sum_{d\mid n}\varphi(d)^2,
\qquad
\#\mathrm{asym}(n) = n^2 - \sum_{d\mid n}\varphi(d)^2 .$$

*Proof sketch.* The set of pairs with equal type is the disjoint union over
divisors $d$ of the squares $T^{-1}(d)\times T^{-1}(d)$, of sizes $\varphi(d)^2$;
the complement in $\mathcal{B}_n$ is $\mathrm{asym}(n)$. $\square$

Write $S(n) := \sum_{d\mid n}\varphi(d)^2$; this is a multiplicative function of
$n$, with $S(p^k) = 1 + \sum_{j=1}^{k} \varphi(p^j)^2$.

**Theorem 5.7 (Symmetrization-defect law).** *For every $n \ge 1$,*
$$\boxed{\; H(\Pi) \;=\; 2H(T) \;-\; \frac{\#\mathrm{asym}(n)}{n^2}\;}
\tag{5.1}$$
*equivalently*
$$H(\Pi) = 2H(T) - 1 + \frac{S(n)}{n^2}. \tag{5.2}$$

*Proof sketch.* Insert the counting identity (Theorem 5.4) into the entropy law
(3.2). The first term becomes
$-\frac{2}{n}\sum_{d\mid n}\varphi(d)\log_2\varphi(d)$, which together with
$\log_2 (n^2) = 2\log_2 n$ reassembles $2H(T)$ by Lemma 5.5. The second term
becomes $-(n^2 - S(n))/n^2$, which is $-\#\mathrm{asym}(n)/n^2$ by Lemma 5.6.
$\square$

Interpretation. The ordered type pair $(T(a),T(b))$ has entropy exactly $2H(T)$
by independence. Symmetrizing merges the ordered pairs $(d,e)$ and $(e,d)$
whenever $d \neq e$, halving those probabilities and hence subtracting one bit
from each affected point; averaging, the loss is exactly the probability of
landing on such a point. That probability is $\#\mathrm{asym}(n)/n^2$ — the
*same* population on which the which-factor wall of Theorem 4.6 operates. The
bit that the wall makes unreachable is precisely the bit that symmetrization
consumes.

**Corollary 5.8 (Symmetrization sandwich).** *For $n \ge 2$,*
$$2H(T) - 1 \;\le\; H(\Pi) \;<\; 2H(T).$$

*Proof sketch.* The defect $\#\mathrm{asym}(n)/n^2$ is a probability, hence
$\le 1$, giving the lower bound; and it is strictly positive for $n \ge 2$ by
Lemma 4.5(i), giving the strict upper bound. $\square$

---

## 6. The degree-12 arm

We now specialise to $n = 12$, i.e. $K = \mathbb{Q}(\zeta_{13})$ with
$\operatorname{Gal}(K/\mathbb{Q}) \cong C_{12}$, and the splitting type of $p$ is
the multiplicative order of $p$ modulo $13$.

### 6.1 The predicted profile

The divisors of $12$ are $1,2,3,4,6,12$ with totients $1,1,2,2,2,4$. The $21$
elements of $\mathcal{D}_{12}$ carry the multiplicities

| $(d,e)$ | $c$ | $(d,e)$ | $c$ | $(d,e)$ | $c$ |
|---|---|---|---|---|---|
| $(1,1)$ | $1$ | $(2,3)$ | $4$ | $(3,12)$ | $16$ |
| $(1,2)$ | $2$ | $(2,4)$ | $4$ | $(4,4)$ | $4$ |
| $(1,3)$ | $4$ | $(2,6)$ | $4$ | $(4,6)$ | $8$ |
| $(1,4)$ | $4$ | $(2,12)$ | $8$ | $(4,12)$ | $16$ |
| $(1,6)$ | $4$ | $(3,3)$ | $4$ | $(6,6)$ | $4$ |
| $(1,12)$ | $8$ | $(3,4)$ | $8$ | $(6,12)$ | $16$ |
| $(2,2)$ | $1$ | $(3,6)$ | $8$ | $(12,12)$ | $16$ |

summing to $144 = 12^2$, in agreement with Corollary 3.4. Every multiplicity is
a power of two, so the entropy weight is an integer:
$$\sum_{(d,e)\in\mathcal{D}_{12}} c\log_2 c = 450 .$$

**Theorem 6.1 (Degree-12 type-pair entropy).**
$$H(\Pi) = \log_2 144 - \frac{450}{144} = 4 + 2\log_2 3 - \frac{25}{8}
= \frac{7}{8} + 2\log_2 3 \approx 4.044925 \text{ bits}.$$

This reproduces, from the closed-form law and with no enumeration of the $144$
exponent pairs, the value previously obtained by exhaustive computation.

**Theorem 6.2 (Degree-12 pair channel).** *Conditioning on the residue of $N$
modulo $13$ leaves $H(\Pi \mid R) = \tfrac{53}{72} + \log_2 3$, so*
$$I_{\mathrm{pair}}(12) = H(\Pi) - H(\Pi\mid R) = \frac{5}{36} + \log_2 3 \approx 1.723851 \text{ bits}.$$

Out of just over four bits of type-pair uncertainty, the residue of $N$ reveals
about $1.72$ — some $42.6\%$ of the total.

**Theorem 6.3 (Degree-12 symmetrization instance).** *$S(12) = 30$, hence
$\#\mathrm{asym}(12) = 114$ and*
$$H(\Pi) = 2H(T) - \frac{114}{144}, \qquad H(T) = \frac{5}{6} + \log_2 3,$$
*consistently: $2\big(\tfrac56 + \log_2 3\big) - \tfrac{19}{24} = \tfrac78 + 2\log_2 3$.*

The same identity has been checked against independently determined entropies at
$n = 4, 6, 10, 16$, where the defects are $10/16$, $26/36$, $66/100$, $170/256$
respectively — the law is a cross-order phenomenon, not a degree-12 coincidence.
As a further cross-check of the general law, at $n = 6$ formula (3.2) yields
$H(\Pi) = -\tfrac1{18} + 2\log_2 3$, again matching the enumerated value.

### 6.2 The split-count channel

The split count $s \in \{0,1,2\}$ is the coarsest nontrivial symmetric read-out
of the type pair. Over the $144$ exponent pairs its profile is $(121, 22, 1)$:
exactly one pair has both factors completely split (both exponents $0$, i.e.
both primes $\equiv 1 \bmod 13$), $22$ have exactly one, and $121$ have none.

**Theorem 6.4 (Unconditional split-count entropy).**
$$H(s) = \frac{277}{72} + 2\log_2 3 - \frac{11}{6}\log_2 11 .$$

*Proof sketch.* Apply the fibre form of Definition 2.7 with the profile
$(1,22,121)$ and $|\mathcal{B}_{12}| = 144$, using
$\log_2 22 = 1 + \log_2 11$, $\log_2 121 = 2\log_2 11$ and
$\log_2 144 = 4 + 2\log_2 3$. $\square$

**Theorem 6.5 (Profile rigidity).** *Partition $\mathcal{B}_{12}$ by the residue
$R = a+b \bmod 12$; each class has exactly $12$ elements. Then all eleven classes
with $R \neq 0$ have the identical split-count profile $(2, 10)$, while the class
$R = 0$ — corresponding to $N \equiv 1 \pmod{13}$ — has profile $(1, 11)$.*

*Proof sketch.* Within the class $R = r$, the split count is $2$ iff $a = b = 0$,
which requires $r = 0$; it is $1$ iff exactly one of $a,b$ is $0$, giving the two
pairs $(0,r)$ and $(r,0)$ when $r \neq 0$ and none when $r = 0$. The remaining
elements have split count $0$. $\square$

This is the structural reason the channel is thin: eleven twelfths of the time,
the observation is statistically indistinguishable from every other
observation. The whole channel is driven by a single lattice point, the
identity exponent pair $(0,0)$.

**Theorem 6.6 (Conditional split-count entropy).**
$$H(s \mid R) = \frac{13}{12} + \log_2 3 - \frac{11}{144}\log_2 11 - \frac{55}{72}\log_2 5 .$$

*Proof sketch.* By Theorem 6.5 there are only two conditional entropies to
compute. The class $R = 0$ contributes the entropy of $(1/12, 11/12)$, namely
$2 + \log_2 3 - \tfrac{11}{12}\log_2 11$; each class $R \neq 0$ contributes the
entropy of $(2/12, 10/12)$, namely $1 + \log_2 3 - \tfrac56\log_2 5$. Weight the
first by $1/12$ and the second by $11/12$. $\square$

**Theorem 6.7 (Degree-12 split-count channel).**
$$I_{\mathrm{split}}(12) = \frac{199}{72} + \log_2 3 + \frac{55}{72}\log_2 5 - \frac{253}{144}\log_2 11
\;\approx\; 0.0445173 \text{ bits}.$$

*Proof sketch.* Subtract Theorem 6.6 from Theorem 6.4:
$\tfrac{277}{72} - \tfrac{13}{12} = \tfrac{199}{72}$ and
$-\tfrac{11}{6} + \tfrac{11}{144} = -\tfrac{253}{144}$. $\square$

**Theorem 6.8 (Bounds).** *$0 < I_{\mathrm{split}}(12) < 1/8$, and moreover
$I_{\mathrm{split}}(12) < I_{\mathrm{pair}}(12)/10$.*

*Proof sketch.* The expression is a rational combination of $\log_2 3$,
$\log_2 5$, $\log_2 11$. Sharp rational bracketing suffices: from
$3^{12} = 531441 > 2^{19}$ one gets $\log_2 3 > 19/12$, from
$3^{17} = 129140163 < 2^{27}$ one gets $\log_2 3 < 27/17$; from
$11^7 = 19487171 > 2^{24}$ one gets $\log_2 11 > 24/7$, and from
$11^{13} < 2^{45}$ one gets $\log_2 11 < 45/13$; comparable brackets hold for
$\log_2 5$. Substituting the appropriate one-sided bounds in each of the three
inequalities yields the claims, the last one combining
$I_{\mathrm{split}}(12) < 1/8$ with $I_{\mathrm{pair}}(12) = \tfrac{5}{36} + \log_2 3 > 1.7$.
$\square$

So the split count leaks — it is not a wall — but it retains under a tenth of
the information carried by the full type pair.

The rigidity of Theorem 6.5 is not special to $n = 12$. Within the residue class
$R = r$ of a general cyclic order $n$, the split count equals $2$ only for the
pair $(0,0)$, which lies in the class $r = 0$; it equals $1$ exactly for the two
pairs $(0,r)$ and $(r,0)$ when $r \neq 0$, and for no pair when $r = 0$. Hence:

**Proposition 6.9 (General split-count profile and channel).** *For $n \ge 2$ the
class $R = 0$ has split-count profile $(1, n-1)$ and every class $R = r \neq 0$
has profile $(2, n-2)$; unconditionally the profile is
$\big(1,\, 2(n-1),\, (n-1)^2\big)$. Consequently, writing $H(\cdot)$ for the
entropy of a probability vector,*
$$I_{\mathrm{split}}(n) = H\!\left(\tfrac{1}{n^2}, \tfrac{2(n-1)}{n^2}, \tfrac{(n-1)^2}{n^2}\right)
- \tfrac1n H\!\left(\tfrac1n, \tfrac{n-1}{n}\right) - \tfrac{n-1}{n} H\!\left(\tfrac2n, \tfrac{n-2}{n}\right).$$

At $n = 12$ this reproduces Theorem 6.7. Across cyclic orders the values are
$$I_{\mathrm{split}}(n) = 0.2947,\ 0.1487,\ 0.0614,\ 0.0445,\ 0.0267
\quad\text{for } n = 4, 6, 10, 12, 16,$$
monotonically decreasing but strictly positive throughout; at $n = 30$ the value
has fallen to $0.00863$.

### 6.3 Summary of the degree-12 arm

| Quantity | Exact value | Numerical |
|---|---|---|
| $H(T)$ | $\tfrac56 + \log_2 3$ | $2.418630$ |
| $H(\Pi)$ | $\tfrac78 + 2\log_2 3$ | $4.044925$ |
| $I_{\mathrm{pair}}(12)$ | $\tfrac{5}{36} + \log_2 3$ | $1.723851$ |
| $I_{\mathrm{split}}(12)$ | $\tfrac{199}{72} + \log_2 3 + \tfrac{55}{72}\log_2 5 - \tfrac{253}{144}\log_2 11$ | $0.044517$ |
| $\#\mathrm{asym}(12)$ | $144 - 30 = 114$ | — |
| symmetrization defect | $114/144 = 19/24$ | $0.791\overline{6}$ |
| which-factor information | exactly $0$ (symmetric read-outs), exactly $1$ (ordered) | — |

---

## 7. Algorithms

Three procedures follow from the theory; all are stated for general $n$.

**Algorithm A (Type-pair entropy by law).** Input $n$; output $H(\Pi)$ exactly.
Enumerate the divisors of $n$; compute $\varphi(d)$ for each; form the
multiplicities $c_{d,e}$ over unordered divisor pairs; return
$\log_2(n^2) - n^{-2}\sum c\log_2 c$. Cost: $O(\sqrt n)$ to list divisors plus
$O(\tau(n)^2)$ arithmetic operations — independent of $n^2$. For $n = 12$ this
is $21$ terms instead of $144$ enumerations; for $n = 10^6$ it is a few hundred
terms instead of $10^{12}$.

**Algorithm B (Symmetrization defect).** Input $n$; output the pair
$(\#\mathrm{asym}(n), 2H(T) - H(\Pi))$. Compute $S(n) = \sum_{d\mid n}\varphi(d)^2$,
return $n^2 - S(n)$ and $(n^2 - S(n))/n^2$. Cost $O(\sqrt n)$ plus totient
evaluations. Because $S$ is multiplicative, $S(n)$ can also be assembled from the
prime factorisation of $n$ in $O(\omega(n))$ multiplications.

**Algorithm C (Channel evaluation with rigidity shortcut).** Input $n$ and a
read-out; output the mutual information with the residue of $N$. Naively this is
an $O(n^2)$ enumeration. When the read-out is the split count, Theorem 6.5
generalises: within the residue class $r$ the split count is $2$ only if $r = 0$
and is $1$ exactly for the pairs $(0,r), (r,0)$, so the profile is $(1, n-1)$ for
$r = 0$ and $(2, n-2)$ for $r \neq 0$, and the channel collapses to a two-term
formula
$$I_{\mathrm{split}}(n) = H\!\left(\tfrac{1}{n^2}, \tfrac{2(n-1)}{n^2}, \tfrac{(n-1)^2}{n^2}\right)
- \tfrac1n H\!\left(\tfrac1n, \tfrac{n-1}{n}\right) - \tfrac{n-1}{n} H\!\left(\tfrac2n, \tfrac{n-2}{n}\right),$$
evaluable in $O(1)$ arithmetic operations. This is the closed form behind the
degree-12 value and behind the decay table of Section 6.2.

---

## 8. Discussion

### 8.1 What changed

Before this work, each cyclic order required its own enumeration: to know the
type-pair entropy at $n$ one enumerated $n^2$ exponent pairs and their fibres.
Three per-order computations have been replaced by three theorems: the
$\varphi$-enumeration law with its entropy consequence (Theorems 3.2, 3.5), the
which-factor wall in maximal generality (Theorem 4.6), and the
symmetrization-defect law (Theorem 5.7). The degree-12 values are now corollaries
rather than data.

### 8.2 The wall in context

Theorem 4.6 is a strong-looking statement with a short proof, and it is worth
being clear about its scope. It does *not* say that a semiprime hides its
factors. It says that any quantity computable from $N$ in a manner insensitive to
the labelling of the two factors is exactly uninformative about an
order-sensitive question. This is a hard barrier of a very particular kind: it is
unconditional (no computational assumption), exact (not asymptotic), and
universal over read-outs — but it applies only to genuinely symmetric functions.
The moment a read-out has access to something order-dependent — say a bound
separating $p$ from $q$, or a partial factorisation — the wall does not apply,
and Theorem 4.7 shows the whole bit becomes available at once.

### 8.3 Numerical corroboration

Independent computational evaluation of all quantities in Section 6 by direct
enumeration reproduces every closed form to machine precision: the type-pair
entropies agree with the law at every order tested ($n$ up to $30$), the
which-factor mutual information evaluates to $0$ to within floating-point noise
for the unordered type pair, the residue, their joint tuple, and the ordinary
product; the ordered read-out gives $1.000000$; and the degree-12 channels
reproduce $1.723851$ and $0.044517$ bits. The empirically observed which-factor
sensitivity of $0.0002$ bits in earlier statistical work is thus explained: the
true value is exactly zero, and $0.0002$ is the estimator's noise floor.

### 8.4 Limitations

The equidistributed model is exact for the combinatorial object studied here —
uniform Frobenius exponents — and is asymptotically correct for primes by
Chebotarev, but finite prime ranges have well-documented bias (Chebyshev-type
races), so the entropies here describe the limiting distribution rather than any
finite sample. We treat only cyclic Galois groups; for non-abelian groups the
Frobenius class is a conjugacy class, the "sum" of exponents is no longer
well-defined, and the entire construction must be rebuilt. Finally, the results
concern *splitting types*, an invariant far coarser than the factors themselves;
none of them bears on the difficulty of integer factorisation.

### 8.5 Future directions

**Does the split-count channel ever close?** The values
$0.2947, 0.1487, 0.0614, 0.0445, 0.0267$ at $n = 4, 6, 10, 12, 16$ fall
monotonically but are strictly positive everywhere examined, and
$0 < I_{\mathrm{split}}(12) < 1/8$ is proved. *Conjecture:*
$I_{\mathrm{split}}(n) > 0$ for every $n \ge 2$, with $I_{\mathrm{split}}(n) \to 0$
as $n \to \infty$. The mechanism is the rigidity of Theorem 6.5, generalised in
Proposition 6.9: the profile at residue $0$ differs from the common profile of
the other $n-1$ residues by exactly one element — the identity exponent pair
$(0,0)$ — so the channel is driven by a single lattice point and should decay
like $\log n / n$. The two-term closed form of Proposition 6.9 turns both halves
of the conjecture into an elementary analytic estimate.

**A wall for every antisymmetric functional.** Theorem 4.6 was proved for a
Boolean label flipped by a fixed-point-free involution. *Conjecture:* for every
function $w$ on exponent pairs with $w(b,a) = \sigma(w(a,b))$ for a fixed-point
free involution $\sigma$ of the value alphabet, every symmetric read-out has zero
mutual information with $w$; and conversely, any $w$ that leaks information about
the order must take a swap-fixed value somewhere. The proof of Theorem 4.3
already isolates exactly this orbit hypothesis, so the general statement is a
pure strengthening.

**Multiplicativity of the symmetrization defect.** Since
$\#\mathrm{asym}(n)/n^2 = 1 - S(n)/n^2$ with $S(n) = \sum_{d\mid n}\varphi(d)^2$
multiplicative, the collision probability factors over prime powers:
*Conjecture:*
$$2H(T) - H(\Pi) = 1 - \prod_{p^k \,\|\, n} \frac{S(p^k)}{p^{2k}},$$
so that the semiprime pair channel of a composite cyclic order is determined by
its prime-power components. Verifying this and extracting the resulting
asymptotics for $H(\Pi)$ along families of $n$ with controlled factorisation is
the natural next step.

---

## 9. Conclusion

For a semiprime in a cyclic extension of degree $n$, the joint statistics of the
two factors' splitting types are governed by a single closed-form counting law in
Euler's totient function, $c_{d,e} = \varphi(d)\varphi(e)$ on the diagonal and
twice that off it. That law determines the type-pair entropy exactly for every
$n$; it decomposes, via a symmetric-square argument, into twice the single-type
entropy minus a defect that equals the probability of the two types differing;
and that same probability measures precisely the population on which an exact,
unconditional information barrier operates — a full bit about *which* factor
carries *which* type, visible to an order-aware observer and invisible to every
symmetric one. At $n = 12$ the numbers are
$I_{\mathrm{pair}}(12) = \tfrac{5}{36} + \log_2 3$,
$I_{\mathrm{split}}(12) = \tfrac{199}{72} + \log_2 3 + \tfrac{55}{72}\log_2 5 - \tfrac{253}{144}\log_2 11$,
and $\#\mathrm{asym}(12) = 114$ — all corollaries of laws that hold everywhere.
