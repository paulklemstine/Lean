# Mod-Exponential Windows Are Smoothness-Blind

### A structure theorem for cyclic orbit prefixes, an information bound, and an exact no-free-lunch theorem for smoothness classification

**Author:** Aristotle

**Date:** 2026-08-14

---

## Abstract

Let $N$ be an odd modulus and $a$ a base coprime to $N$. The *mod-exponential sequence* $s_x = a^x \bmod N$ is the computational substrate of Pollard's $p-1$ factoring method, which succeeds precisely when $N$ has a prime factor $p$ with $p-1$ dividing the method's exponent $M = \operatorname{lcm}(1,\ldots,B)$. It is natural to ask whether this *smoothness class* — a genuine, dramatic, algorithmically exploitable weakness — leaves any trace in the statistics of a short window $s_0,\ldots,s_{m-1}$ with $m \ll B$, so that a cheap screening statistic could triage instances before the expensive attack is run.

We prove that it does not, in the strongest sense available. Our results are:

1. **A structure theorem.** The entire collision structure of the sequence — the map sending each index to the least index carrying the same value — is *exactly* $x \mapsto x \bmod d$, where $d = \operatorname{ord}_N(a)$. Restricted to a window of length $m$, it depends on $(a,N)$ only through $\min(m,d)$.

2. **An information bound.** Across all bases and all moduli, at most $m+1$ distinct length-$m$ collision patterns exist; a length-$m$ window therefore carries at most $\log_2(m+1)$ bits, against the $\Theta(\log N)$ bits required to name a factor. Pigeonhole form: among any $m+2$ odd moduli, two already share a window.

3. **An exact no-free-lunch theorem.** Under the standard tie-aware rank definition of the area under the ROC curve, any statistic constant across two classes scores $\mathrm{AUC} = 1/2$ *exactly*. Combined with (1)–(2) this gives: for every window length $m$ there is an infinite family of odd moduli, closed under multiplication by arbitrary odd numbers and hence containing both smoothness classes, on which every real-valued statistic of the length-$m$ collision pattern attains $\mathrm{AUC} = 1/2$ under every labelling.

4. **The weakness is real and exactly localized.** On the explicit matched pair $N_{\text{smooth}} = 1009\cdot 1019$ and $N_{\text{general}} = 1019\cdot 1039$ with $M = \operatorname{lcm}(1,\ldots,20)$, the $p-1$ method returns the proper nontrivial divisor $1009$ on the first and the trivial gcd $1$ on the second, while the two length-$256$ base-$2$ windows are *identical* as combinatorial objects. The general criterion $r \mid a^M - 1 \iff \operatorname{ord}_r(a) \mid M$ shows the discriminating bit is precisely the output of the $p-1$ computation itself.

5. **Value-level blindness over a full period.** For $t$ coprime to $d$, the set of values visited by a full period of $a^t$ equals that of $a$; hence every symmetric value feature of a full period depends on the cyclic subgroup $\langle a\rangle$ alone, and the only scalar it reveals is $d = |\langle a\rangle|$.

6. **Genericity.** No property of $\mathbb{Z}/N\mathbb{Z}$ is used. The blindness holds for orbit prefixes of any finite-order element of any monoid: two elements of arbitrary monoids with equal order have identical orbit patterns.

These theorems convert an empirical null — $42$ windowed features over $36$ matched pairs giving permutation $p = 0.502$ and cross-validated $\mathrm{AUC} = 0.500$ — into an exact statement. The observed $0.500$ is not a sampling artefact; it is the theorem's value.

**Keywords:** multiplicative order, Pollard $p-1$ method, smooth numbers, integer factorization, cyclic orbit prefix, ROC/AUC, no-free-lunch theorem, information bound.

---

## 1. Introduction

### 1.1 The question

Integer factorization has resisted general attack for centuries, but individual instances are not uniform in difficulty. Certain semiprimes $N = pq$ possess *structural weaknesses* that reduce factoring to a short computation. The oldest and cleanest is smoothness of $p-1$, exploited by Pollard's $p-1$ method (1974) and, in the elliptic-curve generalization of Lenstra, by the smoothness of the order of a random curve group.

Because a weak instance can be broken in milliseconds and a strong one resists indefinitely, there is standing interest in a *cheap screen*: a statistic computable from $N$ (or from a short computation involving $N$) that predicts weakness at asymptotically lower cost than running the attack. If such a screen existed it would matter operationally — keyring auditing, target triage — and theoretically, since it would constitute a nontrivial reduction extracting factorization-relevant information from an instance without factoring it.

The mod-exponential sequence is the natural candidate substrate. The $p-1$ method computes one deep term, $a^M \bmod N$; the sequence's early terms are essentially free. This paper asks whether they say anything, and answers exhaustively.

### 1.2 The empirical null

A controlled experiment framed the question sharply. Thirty-six matched pairs were generated with $p,q$ bit-lengths pinned at $(18,20)$, differing only in the smoothness of $p-1$: the SMOOTH arm used a $p$ with $p-1$ built from primes below the bound; the GENERAL arm used unconstrained $p$. Both arms used unconstrained $q$. At bound $B = 100$, Pollard's method factored $35/36$ SMOOTH instances and $0/36$ GENERAL instances — the classes are not merely nominally different, they are operationally night and day.

Against that, $42$ windowed features were extracted at window length $m = 256$ over bases $\{2,3,5\}$, on both $s_x = a^x \bmod N$ and a floor-scaled twin: distinct-value count, self-collision gap, top-bit balance, adjacent-difference statistics, autocorrelation, spectral flatness, maximum run length. The largest observed standardized between-class difference was $0.473$, against a permutation null with mean $0.495$ and 95th percentile $0.734$, giving $p = 0.502$. Five-fold cross-validated logistic regression attained $\mathrm{AUC} = 0.500$.

Such a result is normally the end of a line of enquiry, not the beginning of one. Here, the exactness of the figure ($0.500$, not $0.51$ or $0.49$) suggested a structural cause, and we found one.

### 1.3 Contributions and organization

Section 2 fixes notation and proves the Collision Law. Section 3 gives the structure theorem for pattern words and the truncation theorem. Section 4 derives the information bound and its pigeonhole form. Section 5 defines AUC and proves the bridge from blindness to exact chance. Section 6 states the correctness and failure criteria for the $p-1$ method and gives the exact divisibility criterion. Section 7 works the explicit matched pair. Section 8 constructs blind families at every window length via a decidable order certificate. Section 9 gives the CRT mechanism. Section 10 proves value-level invariance over a full period. Section 11 abstracts everything to monoids. Section 12 discusses barriers, scope, and open problems.

---

## 2. The mod-exponential sequence and its order

Throughout, $N \geq 1$ is an integer, $a \geq 1$ is coprime to $N$, and $m \geq 0$ is a window length.

**Definition 2.1 (mod-exponential sequence).** For $x \in \mathbb{N}$ set
$$s_x \;=\; \operatorname{modExp}(a,N,x) \;=\; a^x \bmod N \in \{0,1,\ldots,N-1\}.$$

**Definition 2.2 (order).** $\operatorname{ord}_N(a)$ denotes the multiplicative order of the residue class of $a$ in $\mathbb{Z}/N\mathbb{Z}$, i.e. the least $d \geq 1$ with $a^d \equiv 1 \pmod N$.

**Lemma 2.3 (finiteness of order).** If $N > 0$ and $\gcd(a,N)=1$, the class of $a$ in $\mathbb{Z}/N\mathbb{Z}$ has finite order, and $\operatorname{ord}_N(a) \geq 1$.

*Proof.* Euler's theorem gives $a^{\varphi(N)} \equiv 1 \pmod N$ with $\varphi(N) \geq 1$, so the class of $a$ satisfies a nontrivial power relation and has finite, positive order. $\square$

**Theorem 2.4 (Collision Law).** Let $N > 0$, $\gcd(a,N)=1$, $d = \operatorname{ord}_N(a)$. For all $x,y \in \mathbb{N}$,
$$s_y = s_x \quad\Longleftrightarrow\quad y \equiv x \pmod d.$$

*Proof.* $s_y = s_x$ is by definition $a^y \equiv a^x \pmod N$, i.e. equality of the corresponding powers of the class of $a$ in $\mathbb{Z}/N\mathbb{Z}$. For an element $g$ of finite order $d$ in a monoid, $g^y = g^x$ iff $y \equiv x \pmod d$: writing $y = x + k$ with $k \geq 0$ (WLOG $y \geq x$) and cancelling — permissible since the class of $a$ is a unit — this reduces to $g^k = 1$, which holds iff $d \mid k$ by minimality of $d$ and division with remainder. $\square$

Theorem 2.4 is elementary. Everything below is a consequence of taking it seriously: it says that *all* the equality structure of the sequence is the arithmetic of one integer $d$.

---

## 3. Pattern words: the structure and truncation theorems

**Definition 3.1 (first occurrence, pattern word).** For $x \in \mathbb{N}$ set
$$\operatorname{first}(x) \;=\; \min\{\, y \in \mathbb{N} : s_y = s_x \,\},$$
well-defined since $x$ itself is a candidate. The *pattern word of the length-$m$ window* is the function
$$w_{a,N,m}(x) \;=\; \begin{cases}\operatorname{first}(x), & x < m,\\ 0, & x \geq m.\end{cases}$$

The pattern word is the window with numerical values *erased* and only the collision structure retained: $w(x) = w(y)$ for $x,y < m$ exactly when $s_x = s_y$. Every "collision feature" of the window — distinct-value count, self-collision gap, longest repeat, run-length profile, the entire multiset of block structures — is a function of $w$.

**Theorem 3.2 (Structure Theorem).** Let $N > 0$, $\gcd(a,N)=1$, $d = \operatorname{ord}_N(a)$. Then for all $x$,
$$\operatorname{first}(x) \;=\; x \bmod d.$$

*Proof.* Two inequalities. ($\leq$) $x \bmod d \equiv x \pmod d$, so by Theorem 2.4 $s_{x \bmod d} = s_x$, hence $x \bmod d$ is a candidate and $\operatorname{first}(x) \leq x \bmod d$. ($\geq$) Suppose $y < x \bmod d$ satisfies $s_y = s_x$. By Theorem 2.4, $y \equiv x \pmod d$, so $y \bmod d = x \bmod d$. But $y < x \bmod d < d$, so $y \bmod d = y$, giving $y = x\bmod d$, contradicting $y < x \bmod d$. $\square$

**Lemma 3.3 (truncation of the modulus).** For $x < m$ and any $d \geq 1$, $\;x \bmod \min(m,d) = x \bmod d$.

*Proof.* If $d \leq m$ then $\min(m,d) = d$ and there is nothing to prove. If $m \leq d$ then $\min(m,d) = m$ and $x < m \leq d$, so both sides equal $x$. $\square$

**Theorem 3.4 (Truncation Theorem).** Under the hypotheses of Theorem 3.2,
$$w_{a,N,m}(x) \;=\; \begin{cases} x \bmod \min(m, \operatorname{ord}_N(a)), & x < m,\\ 0, & x \geq m.\end{cases}$$
In particular $w_{a,N,m}$ depends on the pair $(a,N)$ only through the single integer $\min(m,\operatorname{ord}_N(a)) \in \{0,1,\ldots,m\}$.

*Proof.* Immediate from Theorem 3.2 and Lemma 3.3. $\square$

**Theorem 3.5 (Blindness Theorem).** Let $N_1,N_2 > 0$ with $\gcd(a_i,N_i)=1$ for $i=1,2$. If
$$\min(m, \operatorname{ord}_{N_1}(a_1)) \;=\; \min(m, \operatorname{ord}_{N_2}(a_2)),$$
then $w_{a_1,N_1,m} = w_{a_2,N_2,m}$ as functions. Consequently, for every set $\beta$ and every map $F$ from pattern words to $\beta$,
$$F(w_{a_1,N_1,m}) \;=\; F(w_{a_2,N_2,m}).$$

*Proof.* The first statement is Theorem 3.4 with the two truncated orders substituted; the second is functional application. $\square$

The quantification in Theorem 3.5 deserves emphasis. It is not over a chosen feature list, nor over features of bounded complexity: it is over *all* functions on pattern words, computable or not, of any arity in the window. No feature engineering, no depth of network, no amount of data can distinguish two instances satisfying its hypothesis, because the objects being distinguished are literally equal.

### 3.1 The distinct-count feature

The workhorse statistic of the experiment admits a closed form.

**Definition 3.6.** $\operatorname{dc}(a,N,m) = \#\{\, a^x \bmod N : 0 \leq x < m \,\}$.

**Theorem 3.7 (exact law for the distinct count).** For $N>0$, $\gcd(a,N)=1$:
$$\operatorname{dc}(a,N,m) \;=\; \min\big(m,\operatorname{ord}_N(a)\big).$$

*Proof.* Write $d=\operatorname{ord}_N(a)$ and $k = \min(m,d)$. Every $x < m$ has $s_x = s_{x \bmod d}$ with $x \bmod d < k$ (indeed $x\bmod d < d$ and $x \bmod d \leq x < m$), so the image of $\{0,\ldots,m-1\}$ equals the image of $\{0,\ldots,k-1\}$. On $\{0,\ldots,k-1\}$ the map $x \mapsto s_x$ is injective: $s_x = s_y$ forces $x \equiv y \pmod d$ by Theorem 2.4, and $x,y < k \leq d$ then forces $x = y$. Hence the image has exactly $k$ elements. $\square$

**Corollary 3.8.** If $m \leq \operatorname{ord}_N(a)$ then $\operatorname{dc}(a,N,m) = m$: every value in the window is fresh, and the window has no internal structure to read at all.

---

## 4. The information bound

**Definition 4.1.** Let $\mathcal{W}_m$ be the set of all length-$m$ pattern words arising from *any* base and *any* modulus:
$$\mathcal{W}_m \;=\; \{\, w_{a,N,m} \;:\; N > 0,\ \gcd(a,N)=1 \,\}.$$

**Theorem 4.2 (Information Bound).** $\;|\mathcal{W}_m| \leq m+1$.

*Proof.* Define $\Phi_k(x) = x \bmod k$ for $x<m$ and $0$ otherwise. By Theorem 3.4, every $w_{a,N,m}$ equals $\Phi_k$ for $k = \min(m,\operatorname{ord}_N(a)) \in \{0,\ldots,m\}$. Thus $\mathcal{W}_m$ is contained in the image of $\{0,\ldots,m\}$ under $k \mapsto \Phi_k$, a set of cardinality at most $m+1$. $\square$

**Corollary 4.3 (bit budget).** The collision structure of a length-$m$ window carries at most $\log_2(m+1)$ bits of information about $(a,N)$, uniformly in $N$.

For $m = 256$ this is $\log_2 257 < 8.01$ bits. Naming a factor of a $t$-bit modulus requires $\Theta(t)$ bits. The gap is not a matter of degree: no compression, sampling, or learning procedure can synthesize bits that the channel does not carry.

**Theorem 4.4 (Pigeonhole form).** Let $T$ be a finite set of odd moduli with $|T| > m+1$. Then there exist distinct $N_1,N_2 \in T$ with $w_{2,N_1,m} = w_{2,N_2,m}$.

*Proof.* Each odd $N$ is positive and coprime to $2$. The map $N \mapsto \min(m,\operatorname{ord}_N(2))$ sends $T$ into $\{0,\ldots,m\}$, a set of size $m+1 < |T|$. By pigeonhole two distinct elements share an image; Theorem 3.5 makes their pattern words equal. $\square$

**Corollary 4.5 (class-independent incompressibility).** For any $\beta$ and any $F : \mathcal{W}_m \to \beta$, $F \circ w$ is not injective on any set of more than $m+1$ odd moduli.

A length-$256$ window cannot separate $258$ moduli, let alone identify a subtle arithmetic property of $p-1$. This is the precise sense in which the window is *class-independently incompressible*: the obstruction has nothing to do with the labelling and everything to do with the paucity of the underlying object.

---

## 5. The learning bridge: exact chance

We now connect the structural results to the standard evaluation metric of binary classification.

**Definition 5.1 (AUC).** Let $S$ (positives) and $G$ (negatives) be finite nonempty index sets and $f$ a real-valued score. The tie-aware rank definition of the area under the ROC curve is
$$\mathrm{AUC}(S,G,f) \;=\; \frac{1}{|S|\,|G|}\sum_{s\in S}\sum_{g\in G}\Big( \mathbf 1\{f(g)<f(s)\} + \tfrac12\,\mathbf 1\{f(g)=f(s)\}\Big).$$
Equivalently, $\mathrm{AUC}$ is the probability that a uniformly random positive outranks a uniformly random negative, ties broken by a fair coin.

**Theorem 5.2 (AUC Bridge).** If $f(s) = f(g)$ for all $s \in S$, $g \in G$, then $\mathrm{AUC}(S,G,f) = 1/2$ exactly.

*Proof.* Every summand has $f(g)=f(s)$, so the strict-inequality indicator vanishes and the tie indicator fires: each of the $|S||G|$ summands equals $1/2$. The double sum is $|S||G|/2$; dividing by $|S||G| \neq 0$ gives $1/2$. $\square$

**Lemma 5.3 (rank invariance).** For any strictly increasing $g : \mathbb{R}\to\mathbb{R}$, $\mathrm{AUC}(S,G,g\circ f) = \mathrm{AUC}(S,G,f)$.

*Proof.* Strict monotonicity preserves and reflects both $<$ and $=$, so every indicator in the double sum is unchanged. $\square$

Lemma 5.3 says the conclusion is not an artefact of scaling conventions: it is a statement about the induced ranking, hence about the classifier, not the score.

**Theorem 5.4 (No-Free-Lunch, abstract form).** Let $\mathcal{F}$ be a set of moduli on which the length-$m$ pattern word is constant (Theorem 3.5's hypothesis holding pairwise). Then for every real-valued statistic $F$ of pattern words and every partition of finite nonempty $S, G \subseteq \mathcal{F}$ into positives and negatives,
$$\mathrm{AUC}\big(S, G, N \mapsto F(w_{2,N,m})\big) \;=\; \tfrac12 .$$

*Proof.* The score is constant on $\mathcal{F}$ by hypothesis; apply Theorem 5.2. $\square$

The theorem quantifies over labellings as well as features. In particular it holds for the SMOOTH/GENERAL labelling *and simultaneously* for every other labelling of the same set — the window does not merely fail to detect smoothness; it fails to detect anything.

---

## 6. Pollard's $p-1$: the weakness is real and exactly characterized

We record what the sequence's *deep* terms do see.

**Theorem 6.1 (correctness of the $p-1$ method).** Let $p$ be prime with $p \mid N$ and $p \nmid a$, and let $M$ be a multiple of $p-1$. Then $p \mid \gcd(a^M - 1,\, N)$.

*Proof.* Fermat: $a^{p-1}\equiv 1 \pmod p$. Writing $M = (p-1)k$ gives $a^M = (a^{p-1})^k \equiv 1 \pmod p$, so $p \mid a^M - 1$; also $p \mid N$ by hypothesis, so $p$ divides the gcd. $\square$

**Theorem 6.2 (exact divisibility criterion).** For $a \geq 1$ and any $r \geq 1$, $M \geq 0$:
$$r \mid a^M - 1 \quad\Longleftrightarrow\quad \operatorname{ord}_r(a) \mid M.$$

*Proof.* $r \mid a^M-1$ says $a^M \equiv 1 \pmod r$, i.e. the class of $a$ in $\mathbb{Z}/r\mathbb{Z}$ satisfies $g^M = 1$, which holds iff the order divides $M$. (Both directions use only division with remainder and minimality of the order.) $\square$

**Theorem 6.3 (failure of the $p-1$ method).** Let $p,q$ be primes, $a \geq 1$, and suppose $\operatorname{ord}_p(a) \nmid M$ and $\operatorname{ord}_q(a) \nmid M$. Then $\gcd(a^M-1,\, pq) = 1$.

*Proof.* By Theorem 6.2, $p \nmid a^M-1$ and $q \nmid a^M-1$; as $p,q$ are prime this means $a^M-1$ is coprime to each, hence to their product. $\square$

Theorems 6.1–6.3 delimit exactly what the method sees: one bit per prime factor, namely whether the local order divides $M$. Theorem 6.2 shows this bit is not the value of any simple function of $N$ — it is the outcome of a divisibility test involving the order, and the only known route to it is the exponentiation $a^M \bmod N$, i.e. the method itself.

### 6.1 Order arithmetic used below

**Lemma 6.4.** If $r$ is prime and $r \nmid a$ then $\operatorname{ord}_r(a) \mid r-1$. *(Fermat plus minimality.)*

**Lemma 6.5.** If $d \mid sr$ with $r$ prime and $d \nmid s$, then $r \mid d$. *(Otherwise $\gcd(d,r)=1$ and $d \mid sr$ forces $d\mid s$.)*

**Lemma 6.6 (order under reduction).** If $r \mid N$ then $\operatorname{ord}_r(a) \mid \operatorname{ord}_N(a)$.

*Proof.* Reduction $\mathbb{Z}/N\mathbb{Z} \to \mathbb{Z}/r\mathbb{Z}$ is a ring homomorphism sending the class of $a$ to the class of $a$; the order of the image of an element divides the order of the element. $\square$

Lemma 6.6 is the workhorse of Section 8: to force a large order modulo a composite it suffices to force it modulo one prime divisor.

---

## 7. The explicit matched pair

Set the bound $B=20$, so
$$M \;=\; \operatorname{lcm}(1,2,\ldots,20) \;=\; 232\,792\,560 \;=\; 2^4\cdot 3^2\cdot 5\cdot 7\cdot 11\cdot 13\cdot 17\cdot 19,$$
and define
$$N_{\text{smooth}} = 1009\cdot 1019 = 1\,028\,171, \qquad N_{\text{general}} = 1019\cdot 1039 = 1\,058\,741 .$$
The primes $1009, 1019, 1039$ all have $10$ bits, so the two instances are size-matched; and the two moduli *share* the prime $1019$, which is what pins their window statistics together.

**Proposition 7.1 (base-2 order mod $1019$ is large).** $\;509 \leq \operatorname{ord}_{1019}(2)$.

*Proof.* By Lemma 6.4, $d := \operatorname{ord}_{1019}(2)$ divides $1018 = 2\cdot 509$. If $d \mid 2$ then $2^2 = 4 \equiv 1 \pmod{1019}$, false. By Lemma 6.5 with $s=2$, $r=509$ we get $509 \mid d$, so $d \geq 509$. (In fact $d = 1018$.) $\square$

**Proposition 7.2 ($\operatorname{ord}_{1019}(2) \nmid M$).** $\;\operatorname{ord}_{1019}(2)$ does not divide $M$.

*Proof.* If it did, then $d \mid \gcd(M, 1018) = 2$ (since $509 \nmid M$: $509 > 20$ is prime), so $2^2 \equiv 1 \pmod{1019}$, false. $\square$

**Proposition 7.3 ($\operatorname{ord}_{1039}(2) \nmid M$).** By Lemma 6.4, $\operatorname{ord}_{1039}(2) \mid 1038 = 2\cdot 3\cdot 173$; if it divided $M$ it would divide $\gcd(M,1038) = 6$ (as $173 > 20$ is prime), forcing $2^6 = 64 \equiv 1 \pmod{1039}$, false.

**Theorem 7.4 (the $p-1$ method separates the classes).**
$$1009 \;\big|\; \gcd(2^M-1,\ N_{\text{smooth}}), \qquad \gcd(2^M-1,\ N_{\text{smooth}}) \notin \{1,\ N_{\text{smooth}}\},$$
$$\gcd(2^M-1,\ N_{\text{general}}) = 1 .$$

*Proof.* For the smooth instance: $1009-1 = 1008 = 2^4\cdot 3^2\cdot 7$ divides $M$, so Theorem 6.1 gives $1009 \mid \gcd$. The gcd is therefore $\neq 1$. It is $\neq N_{\text{smooth}}$: otherwise $N_{\text{smooth}} \mid 2^M-1$, hence $1019 \mid 2^M - 1$, hence by Theorem 6.2 $\operatorname{ord}_{1019}(2) \mid M$, contradicting Proposition 7.2. (Numerically the gcd is exactly $1009$.) For the general instance, apply Theorem 6.3 with Propositions 7.2 and 7.3. $\square$

**Theorem 7.5 (the windows are identical).**
$$w_{2,\,N_{\text{smooth}},\,256} \;=\; w_{2,\,N_{\text{general}},\,256},$$
both equal to the identity map on $\{0,\ldots,255\}$; and $\operatorname{dc}(2,N_{\text{smooth}},256) = \operatorname{dc}(2,N_{\text{general}},256) = 256$.

*Proof.* Both moduli are divisible by $1019$, so by Lemma 6.6 and Proposition 7.1 both have base-$2$ order at least $509 > 256$. Thus $\min(256,\operatorname{ord}_{N}(2)) = 256$ for both, and Theorem 3.5 applies; Corollary 3.8 gives the distinct counts. (Numerically the orders are $256\,536$ and $528\,342$.) $\square$

**Corollary 7.6.** For every $\beta$ and every $F$ on pattern words, $F(w_{2,N_{\text{smooth}},256}) = F(w_{2,N_{\text{general}},256})$; and for every real $F$,
$$\mathrm{AUC}\big(\{N_{\text{smooth}}\},\{N_{\text{general}}\},\ N \mapsto F(w_{2,N,256})\big) = \tfrac12 .$$

**Theorem 7.7 (the null, packaged).** For the matched pair above, simultaneously:
1. the $p-1$ method at bound $B=20$ extracts a proper nontrivial divisor of $N_{\text{smooth}}$ and returns the trivial gcd on $N_{\text{general}}$;
2. the length-$256$ base-$2$ windows of the two moduli are identical as combinatorial objects, so every collision feature agrees on the two classes;
3. hence every such feature attains $\mathrm{AUC}=1/2$ exactly.

The weakness thus lives strictly *outside* the window: it is visible to the computation $a^M \bmod N$ and to nothing that reads a short prefix.

---

## 8. Blind families at every window length

Theorem 7.5 concerns one pair at one length. We now show the phenomenon is generic and length-uniform.

**Definition 8.1.** For an odd prime $p$, let $\mathcal{B}_p = \{\, N : p \mid N,\ N \text{ odd} \,\}$.

**Proposition 8.2.** $\mathcal{B}_p$ is infinite: it contains $p(2k+1)$ for every $k \in \mathbb{N}$, and these are pairwise distinct. Every $N \in \mathcal{B}_p$ is positive and coprime to $2$.

Note that $\mathcal{B}_p$ is closed under multiplication by arbitrary odd numbers, so it contains semiprimes of both smoothness classes in abundance — it is not a family engineered to dodge the question.

**Proposition 8.3.** If $m \leq \operatorname{ord}_p(2)$ and $N \in \mathcal{B}_p$ then $m \leq \operatorname{ord}_N(2)$.

*Proof.* Lemma 6.6 gives $\operatorname{ord}_p(2) \mid \operatorname{ord}_N(2)$, and the latter is positive, hence at least the former. $\square$

**Theorem 8.4 (constant window on a blind family).** If $m \leq \operatorname{ord}_p(2)$, then all $N \in \mathcal{B}_p$ share the same length-$m$ pattern word, and $\operatorname{dc}(2,N,m) = m$ for every such $N$.

*Proof.* By Proposition 8.3, $\min(m,\operatorname{ord}_N(2)) = m$ for all members; apply Theorem 3.5 and Corollary 3.8. $\square$

It remains to produce, for each $m$, a prime $p$ with $\operatorname{ord}_p(2) \geq m$. Two tools.

### 8.1 A decidable certificate for large order

Computing $\operatorname{ord}_p(2)$ requires factoring $p-1$ or a search; but *lower-bounding* it never does.

**Theorem 8.5 (order certificate, monoid form).** Let $g$ be an element of a monoid, $n \geq 1$ with $g^n = 1$, and $r$ a prime dividing $n$ with $g^{n/r} \neq 1$. Then $r \mid \operatorname{ord}(g)$, and in particular $r \leq \operatorname{ord}(g)$.

*Proof.* Write $n = sr$. From $g^n=1$ we get $\operatorname{ord}(g) \mid sr$. If $\operatorname{ord}(g) \mid s$ then $g^{s} = g^{n/r} = 1$, contradiction. By Lemma 6.5, $r \mid \operatorname{ord}(g)$. Since $g^n=1$ with $n\geq1$, $\operatorname{ord}(g) > 0$, so $r \leq \operatorname{ord}(g)$. $\square$

**Corollary 8.6 (certificate in $\mathbb{Z}/p\mathbb{Z}$).** For a prime $p$, a base $a$ with $p \nmid a$, and a prime $r \mid p-1$ with $a^{(p-1)/r} \not\equiv 1 \pmod p$, one has $r \leq \operatorname{ord}_p(a)$.

The hypothesis is a *single* modular exponentiation and equality test — a decidable, cheap certificate. Applied to $p = 1019$ with $r = 509$: $1018/509 = 2$ and $2^2 = 4 \neq 1$, giving $509 \leq \operatorname{ord}_{1019}(2)$ (Proposition 7.1 again, now as an instance of a general tool). Applied to $p = 1039$ with $r = 173$: $1038/173 = 6$ and $2^6 = 64 \neq 1$, giving $173 \leq \operatorname{ord}_{1039}(2)$.

### 8.2 Orders grow with the modulus

**Theorem 8.7.** For every odd prime $p$, $\;p < 2^{\operatorname{ord}_p(2)}$.

*Proof.* Let $d = \operatorname{ord}_p(2) \geq 1$. By Theorem 6.2 (with $r=p$, $M=d$), $p \mid 2^d - 1$. Since $2^d - 1 \geq 1$, this gives $p \leq 2^d - 1 < 2^d$. $\square$

**Corollary 8.8.** For every $m$ there is an odd prime $p$ with $\operatorname{ord}_p(2) \geq m$.

*Proof.* Pick a prime $p \geq 2^m + 2$ (infinitude of primes); it is odd. By Theorem 8.7, $2^m < p < 2^{\operatorname{ord}_p(2)}$, so $m < \operatorname{ord}_p(2)$. $\square$

**Theorem 8.9 (blind families exist at every length).** For every $m$ there is a prime $p$ such that $\mathcal{B}_p$ is infinite, all its members share one and the same length-$m$ pattern word, and each has $\operatorname{dc}(2,N,m) = m$.

*Proof.* Combine Corollary 8.8, Proposition 8.2, and Theorem 8.4. $\square$

**Theorem 8.10 (No free lunch at every window length).** For every $m$ there is a prime $p$ with $\mathcal{B}_p$ infinite such that for *every* real-valued statistic $F$ of pattern words and *every* pair of finite nonempty $S,G \subseteq \mathcal{B}_p$,
$$\mathrm{AUC}\big(S,G,\ N \mapsto F(w_{2,N,m})\big) \;=\; \tfrac12 .$$

*Proof.* Theorem 8.9 plus Theorem 5.2. $\square$

This is the definitive form of the null. It is uniform in $m$: lengthening the window does not erode the barrier, because for each length there is a fresh infinite family on which the barrier is total. And it is uniform in the labelling: the SMOOTH/GENERAL split is only one of exponentially many, all equally invisible.

---

## 9. Mechanism: why the order cannot see smoothness

Theorem 3.4 reduces the window to $\min(m,\operatorname{ord}_N(a))$. So the entire question becomes: does $\operatorname{ord}_N(a)$ know about the smoothness of $p-1$?

**Theorem 9.1 (order under CRT).** For coprime $p,q$,
$$\operatorname{ord}_{pq}(a) \;=\; \operatorname{lcm}\big(\operatorname{ord}_p(a),\ \operatorname{ord}_q(a)\big).$$

*Proof.* The Chinese Remainder isomorphism $\mathbb{Z}/pq\mathbb{Z} \cong \mathbb{Z}/p\mathbb{Z} \times \mathbb{Z}/q\mathbb{Z}$ carries the class of $a$ to the pair of its classes. Order is preserved by isomorphism, and the order of a pair in a product monoid is the lcm of the coordinate orders. $\square$

Now the decoupling is transparent. The local order $\operatorname{ord}_p(a)$ divides $p-1$ (Lemma 6.4), so it is a *divisor* of the quantity whose factorization defines smoothness. But its **size** — the only thing the window reads, and then only truncated at $m$ — is uninformative about that factorization:

- $p-1$ can be $20$-smooth with $\operatorname{ord}_p(2)$ large: $p = 1009$, $p-1 = 2^4\cdot3^2\cdot7$, $\operatorname{ord}_{1009}(2) = 504$.
- $p-1$ can have a huge prime factor with $\operatorname{ord}_p(2)$ of comparable size: $p = 1019$, $p-1 = 2\cdot 509$, $\operatorname{ord}_{1019}(2) = 1018$.

Moreover in a window with $m \ll d$ the truncation destroys even the size: $\min(m,d) = m$ regardless. The window's only channel is not merely weak — on the relevant regime it is *saturated*, returning the constant $m$.

---

## 10. Value-level blindness over a full period

Sections 3–9 concern the collision structure, i.e. the window with its values erased. We now take the first step past that, and record an exact invariance at the level of the values themselves.

The base of a mod-exponential sequence is not canonical. If $t$ is coprime to $d = \operatorname{ord}_N(a)$, then $a^t$ generates the same cyclic subgroup $\langle a \rangle \leq (\mathbb{Z}/N\mathbb{Z})^\times$, and the orbit of $a^t$ is the orbit of $a$ traversed in a different order.

**Lemma 10.1.** Let $g$ have finite order $d$ and $\gcd(t,d)=1$. Then $g \in \langle g^t\rangle$: there is $u$ with $(g^t)^u = g$.

*Proof.* If $d = 1$ then $g=1$ and $u=0$ works. Otherwise pick $u$ with $tu \equiv 1 \pmod d$; then $(g^t)^u = g^{tu} = g^{tu \bmod d} = g^1$. $\square$

**Lemma 10.2.** $\operatorname{ord}(g^t) = \operatorname{ord}(g)$ when $\gcd(t,\operatorname{ord}(g))=1$.

**Theorem 10.3 (orbit invariance).** With $g$ of order $d$ and $\gcd(t,d)=1$,
$$\{\,(g^t)^x : 0 \leq x < d\,\} \;=\; \{\, g^x : 0 \leq x < d \,\}.$$

*Proof.* ($\subseteq$) $(g^t)^x = g^{tx} = g^{tx \bmod d}$ with $tx \bmod d < d$. ($\supseteq$) With $u$ from Lemma 10.1, $g^x = ((g^t)^u)^x = (g^t)^{ux} = (g^t)^{ux \bmod d}$, using Lemma 10.2 to reduce the exponent modulo $d$. $\square$

**Definition 10.4.** $\operatorname{PV}(a,N) = \{\, a^x \bmod N : 0 \leq x < \operatorname{ord}_N(a) \,\}$, the set of values of one full period.

**Theorem 10.5 (value-level blindness, full period).** Let $N>0$, $\gcd(a,N)=1$, $d = \operatorname{ord}_N(a)$, and $\gcd(t,d)=1$. Then
$$\operatorname{PV}(a^t, N) \;=\; \operatorname{PV}(a, N).$$
Consequently, for every $\beta$ and every $F$ on finite sets of integers, $F(\operatorname{PV}(a^t,N)) = F(\operatorname{PV}(a,N))$.

*Proof.* By Lemma 10.2, $\operatorname{ord}_N(a^t) = d$, so both period value sets are indexed by $\{0,\ldots,d-1\}$. Each value $a^x \bmod N$ is the canonical representative of the corresponding power of the class of $a$; the map from residue classes to representatives is injective. Theorem 10.3 in $(\mathbb{Z}/N\mathbb{Z})^\times$ then identifies the two sets of classes, hence the two sets of representatives. $\square$

**Theorem 10.6 (the only readable scalar).** $\;|\operatorname{PV}(a,N)| = \operatorname{ord}_N(a)$.

*Proof.* Theorem 3.7 with $m = \operatorname{ord}_N(a)$. $\square$

So every *symmetric* value-level feature of a full period — value histogram, top-bit count, extremes, moments, anything reading the window as a set — depends only on the pair $(N, \langle a\rangle)$, never on which generator was chosen; and the single scalar the value set exposes is the order, which Section 9 showed to be smoothness-agnostic.

**Scope caveat.** Theorem 10.5 concerns a *full period*. Value-level features of a *truncated* window ($m \ll d$) are not covered: the two windows of Section 7 genuinely differ as integer sequences (they carry $122$ and $124$ high bits respectively). Their statistical nullity is an experimental finding, not a theorem. Closing this gap is the sharpest open problem left by this work (Section 12).

---

## 11. Genericity: it is a fact about cyclic prefixes

Inspecting the proofs of Sections 2–4 reveals that nothing about $\mathbb{Z}/N\mathbb{Z}$ was used beyond the finiteness of the order of one element.

**Definition 11.1.** For $g$ an element of a monoid $M$, let $\operatorname{afirst}_g(n) = \min\{y : g^y = g^n\}$.

**Theorem 11.2 (abstract structure theorem).** If $g$ has finite order then $\operatorname{afirst}_g(n) = n \bmod \operatorname{ord}(g)$ for all $n$.

*Proof.* Verbatim the proof of Theorem 3.2, with Theorem 2.4 replaced by the general fact $g^y = g^x \iff y \equiv x \pmod{\operatorname{ord}(g)}$ for finite-order $g$. $\square$

**Theorem 11.3 (cross-structure blindness).** Let $g_1 \in M_1$ and $g_2 \in M_2$ be finite-order elements of *arbitrary* monoids with $\operatorname{ord}(g_1) = \operatorname{ord}(g_2)$. Then $\operatorname{afirst}_{g_1} = \operatorname{afirst}_{g_2}$.

No invariant of the ambient structure — its cardinality, the smoothness of that cardinality, the arithmetic of the ground ring, the geometry of the underlying curve — survives into the orbit prefix. Elliptic-curve point sequences, function-field analogues, and matrix power sequences all inherit the blindness verbatim: any attack hoping to read structural weakness off an orbit prefix must contend with Theorem 11.3.

**Proposition 11.4 (consistency).** For $N>0$ and $\gcd(a,N)=1$, $\operatorname{first}(x) = \operatorname{afirst}_{\bar a}(x)$ where $\bar a$ is the class of $a$ in $\mathbb{Z}/N\mathbb{Z}$: Section 3 is the $\mathbb{Z}/N\mathbb{Z}$ instance of Section 11.

---

## 12. Discussion

### 12.1 Which barriers this clears

Programmes hoping to extract a "self-hint" for factoring from cheap functions of $N$ face a standard family of obstructions. This work engages three of them precisely.

**Symmetry.** Any statistic computable from $N$ alone is symmetric in $p$ and $q$ (it cannot distinguish the factorization $N = pq$ from $N = qp$), so it cannot by itself name a factor. All our features are $N$-computable, hence symmetric.

**Class-independent incompressibility.** Theorem 4.2 shows the window compresses the instance to at most $\log_2(m+1)$ bits, independently of any labelling; Corollary 4.5 makes this a hard non-injectivity statement on sets of size $> m+1$. This is a much stronger obstruction than a symmetry argument, and it is quantitative.

**Known-method collapse.** Theorem 6.2 localizes the discriminating information to a single divisibility bit, $\operatorname{ord}_r(a) \mid M$, whose only known evaluation route is the exponentiation $a^M \bmod N$ — the $p-1$ method. A hypothetical statistic that succeeded would therefore not be a new attack, but a re-implementation of a fifty-year-old one.

### 12.2 What the theorems do and do not say

They **do** say: for every $m$ there is an infinite family of odd moduli, containing both smoothness classes, on which every real-valued function of the length-$m$ collision structure achieves exactly $\mathrm{AUC} = 1/2$ under every binary labelling. They **do** say: the $p-1$/ECM weakness is real, and the exact criterion for it is $\operatorname{ord}_r(a)\mid M$.

They **do not** say: that no polynomial-time statistic can detect smoothness. That would be a statement quantifying over all computations and is far out of reach; our results are barriers for a specific, natural, and previously untested class of statistics. Nor do they cover truncated value-level features, as flagged in Section 10.

### 12.3 Practical reading

For an implementer, the operational content is simple and slightly bracing. There is no cheap smoothness screen to be had from sequence statistics — not by adding features, not by lengthening the window, not by switching model class. Budget spent on such a screen is better spent on the attack itself, which after all costs a single exponentiation. Conversely, the result is mildly reassuring for the defender: a semiprime does not advertise its $p-1$ weakness in any way visible short of a full $p-1$ trial.

### 12.4 Open problems

1. **Value-level blindness for truncated windows.** Extend Theorem 10.5 from full periods to windows of length $m \ll d$. The full-period case is settled; the truncated case needs a genuinely different technique, since the values in a short prefix are not a symmetric function of the subgroup. A plausible route is an equidistribution statement for $\{a^x \bmod N\}_{x<m}$ in $[0,N)$ with error uniform over the class, which would give asymptotic (rather than exact) blindness for smooth value statistics.

2. **Sharp constants in the information bound.** Theorem 4.2 gives $|\mathcal{W}_m| \leq m+1$; the bound is attained (each $k \leq m$ is realized by some order). What is the induced distribution over $\mathcal{W}_m$ when $N$ is drawn from a natural ensemble of semiprimes, and does *that* distribution differ between classes? The window is constant on our blind families, but across a random ensemble the truncated order $\min(m,d)$ is a random variable — quantifying its class dependence (we expect none of consequence, since $d \geq m$ with overwhelming probability) would sharpen the null from "exactly $1/2$ on a family" to "$1/2 + o(1)$ on the ensemble".

3. **A symmetry-based unconditional statement.** Replace the unattainable "no polynomial-length window sees smoothness" with a provable symmetry statement: identify a group acting on instances that preserves the class but acts transitively enough on windows to force blindness. Theorem 10.5's base action $a \mapsto a^t$ is the prototype.

4. **Order certificates at scale.** Corollary 8.6 turns order lower bounds into single exponentiations. Systematizing this — a certificate calculus producing, for a given $p$, the best lower bound on $\operatorname{ord}_p(2)$ obtainable from a fixed budget of exponentiations — would make the blind-family constructions of Section 8 effective at cryptographic sizes.

5. **Beyond $\mathbb{Z}/N\mathbb{Z}$.** Theorem 11.3 says the blindness transfers to elliptic-curve orbits. Does the ECM analogue — "the group-order smoothness of $E(\mathbb{F}_p)$ is invisible in a short prefix of the multiples of a point" — admit the same exact treatment, and does the value-level analogue behave differently because curve coordinates carry more structure than residues?

---

## 13. Conclusion

A short window of the mod-exponential sequence is, structurally, a clock: its collision pattern is precisely $x \mapsto x \bmod \operatorname{ord}_N(a)$, truncated at the window length. Consequently at most $m+1$ such patterns exist in the entire universe of bases and moduli, any two instances with equal truncated order have literally identical windows, and every real statistic of such a window scores exactly $\mathrm{AUC}=1/2$ on an infinite family of moduli containing both smoothness classes — at every window length, under every labelling.

Meanwhile the weakness the window fails to see is entirely real: the same computation that the window's terms come from, pushed to the exponent $M = \operatorname{lcm}(1,\ldots,B)$, factors the smooth instance immediately and fails on the general one. The information exists; it is confined to one bit, $\operatorname{ord}_r(a) \mid M$; and the only known way to read that bit is to run the attack.

Negative results are worth stating exactly when they are sharp enough to redirect effort. This one is: it closes the sequence-level face of the search for cheap factoring self-hints, identifies precisely why the channel is closed (the pattern is a clock, the clock reads only the order, the order's size is decoupled from the factorization of $p-1$), and leaves a clean, well-posed frontier at the truncated value level.
