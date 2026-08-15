# The 3SUM–Birthday-Bound Hierarchy: Collision Factoring and Three Independent $\sqrt{N}$ Barriers

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

We establish a structural bridge between two canonical computational problems — the $3$SUM problem of fine-grained complexity and integer factoring — and then determine, exactly, how much that bridge can carry.

The bridge is a *reveal lemma*: if $N = pq$ is a semiprime and $s$ is any integer with $0 < s < N$ and $p \mid s$, then $\gcd(s, N) = p$. The side condition $q \nmid s$ that is customarily imposed is redundant: it follows from $s < N$. Applied to $s = a + b + c$, this says that a $3$SUM instance solved modulo an unknown prime factor of $N$ yields that factor by one greatest-common-divisor computation.

We then analyse the family of collision-based factoring schemes that the reveal lemma makes available — sumset collisions ($a+b \equiv c+d$), $3$SUM collisions ($a+b+c \equiv d+e+f$), general $r$-SUM collisions, and evaluation schemes with structured value sets. These form an apparent hierarchy: guaranteeing an $r$-SUM collision modulo $p$ requires only $k \approx p^{1/r}$ *stored* elements, so the exponent improves from $1/2$ to $1/3$ and beyond.

Our main theorem shows that the hierarchy collapses. For a finite search space $S$ and modulus $p \ge 1$, a collision is guaranteed against every residue map into $\{0, \dots, p-1\}$ **if and only if** $p < |S|$. The criterion mentions only $|S|$ — the number of inspected objects — and never the arity. The threshold is exactly $p+1$ for every scheme in the family, and since the larger factor of $N = pq$ satisfies $p \geq \sqrt{N}$, every such scheme must inspect more than $\sqrt{N}$ objects.

We prove two further, logically independent obstructions with the same $\sqrt N$ magnitude. The **amplitude barrier**: $r$-tuples drawn from $A \subseteq [1, M]$ realise at most $rM + 1$ distinct sums, so if $rM < p$ then *every* modular collision is trivial and the scheme cannot factor regardless of how many tuples it inspects; success therefore forces $p \leq rM$. The **span barrier**: any scheme extracting factors as $\gcd$ of differences of its values, if it reveals a factor $f$, must produce two values differing by at least $f$; hence the numbers manipulated span at least $\sqrt N$. The **coverage barrier**: a fixed scheme with $k$ search points and values below $B$ reveals at most $\log_P(B) \cdot k^2$ primes $\geq P$, so no fixed scheme is universal.

Finally we give a positive master theorem: once the counting and amplitude barriers are cleared, $r$-SUM collision factoring provably outputs the factor $p$. The consequence is a sharp trichotomy of costs — inspected tuples, integer amplitude, and prime coverage — all pinned at $\Omega(\sqrt N)$ by three different arguments.

**Keywords:** $3$SUM, birthday bound, integer factoring, pigeonhole principle, semiprimes, collision search, sumsets, fine-grained complexity.

---

## 1. Introduction

### 1.1 Two problems, one bridge

The **$3$SUM problem** asks, given a finite set $A$ of integers, whether there exist $a, b, c \in A$ with $a + b + c = 0$. It occupies a distinguished position in fine-grained complexity: a large family of problems in computational geometry and string algorithms is known to be $3$SUM-hard, and the $3$SUM conjecture — no truly subquadratic algorithm exists — anchors a web of conditional lower bounds.

**Integer factoring** asks, given $N$, for a nontrivial divisor. For $N = pq$ a product of two primes of comparable size, it is the canonical hardness assumption of public-key cryptography.

These problems are not usually discussed together. This paper connects them, in a direction that is elementary to state and, we believe, has not been articulated as a hierarchy before: *a $3$SUM instance taken modulo an unknown prime factor of $N$ is a factoring oracle.* The connection runs through a lemma of two lines and a greatest-common-divisor computation, and the interesting mathematics lies not in the bridge itself but in the precise accounting of what crossing it costs.

### 1.2 The seductive hierarchy

Once one accepts the reveal lemma, factoring $N = pq$ reduces to producing a quantity below $N$ that is divisible by $p$. The birthday bound supplies such quantities: generate more than $p$ integers, and two of them are congruent modulo $p$; their difference is a nonzero multiple of $p$.

The design space is then: how do we generate many integers cheaply? Natural answers form a ladder of increasing arity.

| Collision type | Search space size | Stored elements for a guarantee | Objects inspected |
|---|---|---|---|
| Sumset, $a + b \equiv c + d$ | $k^2$ | $k \sim p^{1/2}$ | $> p \ge \sqrt N$ |
| $3$SUM, $a+b+c \equiv d+e+f$ | $k^3$ | $k \sim p^{1/3}$ | $> p \ge \sqrt N$ |
| $r$-SUM | $k^r$ | $k \sim p^{1/r}$ | $> p \ge \sqrt N$ |
| Structured evaluation, value set $B$, $\lvert B\rvert \approx p/h$ | $k$ | $k \sim p/h$ | $> \lvert B \rvert$ |

The third column is the seduction: the exponent genuinely improves. The fourth column is the content of this paper: it does not.

### 1.3 Contributions

1. **A hypothesis-free reveal lemma** (Section 3), together with its $3$SUM, $r$-SUM, and collision-difference forms, and a complete census for $N = 143$ illustrating why the failure mode of the method is structurally impossible in the relevant range.
2. **The collapse theorem** (Section 4): a collision is guaranteed exactly when the search space exceeds $p$, an arity-free criterion. Both directions are proved — pigeonhole and an explicit adversary — so the threshold $p+1$ is sharp, not merely an upper bound on some analysis.
3. **The $\sqrt N$ barrier in arity-free form** (Section 5).
4. **Two independent further barriers** (Sections 6 and 7): amplitude and span, plus the coverage bound limiting the universality of any fixed scheme.
5. **A positive master theorem** (Section 8) certifying that the method works once the barriers are cleared.

---

## 2. Notation and standing conventions

All variables denote natural numbers unless stated otherwise. For a finite set $S$ we write $|S|$ for its cardinality. We write $a \equiv b \pmod p$, and for natural numbers we freely use the equivalence

$$ a \equiv b \pmod p \quad\text{with}\quad b \le a \qquad \Longleftrightarrow \qquad p \mid a - b, $$

with $a - b$ the ordinary (nonnegative) difference. We write $\lfloor\sqrt N\rfloor$ for the integer square root; all our inequalities involving square roots are stated in this integer form and are therefore exact, not asymptotic.

A **semiprime** is $N = pq$ with $p, q$ prime. Where a *larger factor* is referred to, we assume $q \le p$, so that $\lfloor\sqrt N\rfloor \le p$.

**Definition 2.1 (Residue map).** Given a finite *search space* $S$ (a finite set of arbitrary objects: integers, tuples, ideal classes) and a modulus $p \ge 1$, a **residue map** is a function $f$ from the ambient type into $\{0, 1, \dots, p-1\}$. A **collision** for $f$ on $S$ is a pair $x, y \in S$ with $x \neq y$ and $f(x) = f(y)$.

**Definition 2.2 (Guaranteed collision).** We say $S$ *guarantees collisions modulo $p$* if **every** residue map $f$ into $\{0, \dots, p-1\}$ admits a collision on $S$. This universal quantification is the correct notion for a lower bound: an algorithm designer who does not know $p$ cannot rely on a favourable $f$.

---

## 3. The reveal lemma

### 3.1 Statement and proof

**Theorem 3.1 (Factor reveal).** *Let $p$ and $q$ be primes and $N = pq$. Let $s$ satisfy $0 < s < N$ and $p \mid s$. Then $\gcd(s, N) = p$.*

*Proof.* Put $g = \gcd(s, N)$. Since $p \mid s$ and $p \mid N$, we have $p \mid g$; write $g = pd$. Since $g \mid N = pq$ we get $pd \mid pq$, and as $p \neq 0$ this gives $d \mid q$. As $q$ is prime, $d = 1$ or $d = q$.

If $d = 1$ then $g = p$, as claimed. If $d = q$ then $g = pq = N$, and since $g \mid s$ we get $N \mid s$; with $s > 0$ this forces $s \geq N$, contradicting $s < N$. $\square$

**Remark 3.2 (A redundant hypothesis).** The literature customarily states this with the extra hypothesis $q \nmid s$, to exclude the case where the greatest common divisor returns $N$. The proof above shows the hypothesis is *implied by* $s < N$: if both $p \mid s$ and $q \mid s$ then, since $p$ and $q$ are distinct primes and hence coprime, $pq \mid s$, so $s \geq N$. We record this separately, since it is the structural reason the empirical "divisible by both" column of any experiment in range is empty.

**Proposition 3.3 (No double divisibility below $N$).** *Let $p \neq q$ be primes and $0 < s < pq$. Then it is not the case that both $p \mid s$ and $q \mid s$.*

*Proof.* Coprimality of $p$ and $q$ upgrades the two divisibilities to $pq \mid s$, whence $s \geq pq$, contradiction. $\square$

### 3.2 The forms in which the lemma is used

**Corollary 3.4 ($3$SUM reveal).** *If $p, q$ are prime, $0 < a+b+c < pq$, and $p \mid a+b+c$, then $\gcd(a+b+c,\, pq) = p$.*

**Corollary 3.5 ($r$-SUM reveal).** *Let $I$ be a finite index set and $f : I \to \mathbb{N}$. If $0 < \sum_{i \in I} f(i) < pq$ and $p \mid \sum_{i \in I} f(i)$, then $\gcd\bigl(\sum_{i\in I} f(i),\, pq\bigr) = p$.*

The reveal phenomenon is thus not special to triples; the arity plays no role whatsoever in the reveal step. This is the first hint of the paper's theme.

**Corollary 3.6 (Collision reveal).** *Let $p, q$ be prime and $t < s < pq$ with $p \mid s - t$. Then $\gcd(s - t,\, pq) = p$.*

*Proof.* Apply Theorem 3.1 to the quantity $s - t$, which is positive by $t < s$ and satisfies $s - t \le s < pq$. $\square$

This is the shape actually produced by every search: not a sum divisible by $p$ (we have no way to arrange that) but a *difference of two sums* that is divisible by $p$, arising from a congruence.

**Corollary 3.7 (Sumset collision).** *If $c + d < a + b < pq$ and $(a+b) \equiv (c+d) \pmod p$, then $\gcd\bigl((a+b)-(c+d),\, pq\bigr) = p$.*

**Theorem 3.8 ($3$SUM collision dichotomy).** *Let $p, q$ be prime and let two triples satisfy $a+b+c < pq$, $a'+b'+c' < pq$, and $(a+b+c) \equiv (a'+b'+c') \pmod p$. Then exactly one of the following holds:*

1. *$a+b+c = a'+b'+c'$ — the collision is trivial and yields no information; or*
2. *$\gcd\bigl(\max - \min,\; pq\bigr) = p$, where $\max$ and $\min$ are the larger and smaller of the two integer sums.*

*Proof.* Trichotomy on the two integer sums. If they are equal we are in case 1. Otherwise the smaller is strictly less than the larger, both are below $pq$, and their congruence gives $p \mid \max - \min$; apply Corollary 3.6. $\square$

Theorem 3.8 is the precise statement of what a search can hope for, and it already isolates the enemy: **trivial collisions**. A modular collision between two tuples whose integer sums coincide is worthless. Section 6 shows this failure mode is not a nuisance but a barrier.

### 3.3 A complete census: $N = 143$

Take $N = 143 = 11 \cdot 13$ and consider all ordered triples $1 \le a < b < c \le 12$. Every such triple has $a+b+c \le 10+11+12 = 33 < 143$, so Theorem 3.1 applies to every one of them.

**Proposition 3.9 (Census).** *Among the triples $1 \le a<b<c\le 12$:*

- *exactly $20$ have $11 \mid a+b+c$ and $13 \nmid a+b+c$;*
- *exactly $0$ have both $11 \mid a+b+c$ and $13 \mid a+b+c$.*

The second count is not a coincidence of the range: by Proposition 3.3 it is $0$ for **every** range in which the triple sums stay below $143$ — in particular for all $1 \le a<b<c\le n$ with $3n < 143$. The first count is genuinely range-dependent: restricting to $1 \le a<b<c\le 11$ leaves $15$ such triples.

**Corollary 3.10.** *For every triple with $0 < a+b+c < 143$ and $11 \mid a+b+c$, one has $\gcd(a+b+c, 143) = 11$.*

Thus every one of the $20$ triples in the census factors $143$ on the spot: e.g. $2+4+5 = 11$, $1+9+12 = 22$, $3+8+11 = 22$, $10+11+12 = 33$, each with $\gcd(\cdot, 143) = 11$. The method's failure mode — accidentally hitting a multiple of $N$ — has zero instances, provably.

---

## 4. The collapse of the hierarchy

We now leave the reveal step behind and analyse the search step in the abstract.

### 4.1 The upper side: pigeonhole

**Theorem 4.1 (Birthday bound, upper side).** *Let $p \ge 1$, let $S$ be a finite search space with $p < |S|$, and let $f$ be any residue map with $f(x) < p$ for all $x$. Then there exist $x, y \in S$ with $x \neq y$ and $f(x) = f(y)$.*

*Proof.* $f$ maps $S$ into the $p$-element set $\{0, \dots, p-1\}$ and $|S| > p$, so $f$ is not injective on $S$. $\square$

**Theorem 4.2 (Structured value sets).** *Let $S$ be a finite search space, $B$ a finite set of naturals, and $f$ a map with $f(x) \in B$ for all $x \in S$. If $|B| < |S|$, then $f$ has a collision on $S$.*

Theorem 4.2 is the general form: the collision threshold is the size of the **value set**, whatever it happens to be. Theorem 4.1 is the case $B = \{0,\dots,p-1\}$. The "structured evaluation" row of the hierarchy — schemes whose values are confined to a set of size roughly $p/h$ for some structural parameter $h$ (for example an evaluation indexed by a class group of class number $h$) — is the case $|B| \approx p/h$, and Theorem 4.2 says such a scheme collides after only $|B| + 1$ evaluations, a genuine factor-$h$ improvement in *evaluation count*. Section 7 shows why this improvement is nonetheless confined.

### 4.2 The lower side: an adversary

**Theorem 4.3 (Birthday bound, lower side).** *Let $p \ge 1$ and let $S$ be a finite search space with $|S| \le p$. Then there exists a residue map $f$ with $f(x) < p$ for all $x$, which is injective on $S$.*

*Proof.* Since $|S| \le p$, there is an injection $e$ from $S$ into a $p$-element set, which we identify with $\{0, \dots, p-1\}$. Define $f(x) = e(x)$ for $x \in S$ and $f(x) = 0$ otherwise. Then $f(x) < p$ everywhere (using $p \ge 1$ for the default value), and $f$ restricted to $S$ is $e$, hence injective. $\square$

The importance of Theorem 4.3 is methodological. Without it, "the scheme needs more than $p$ tuples" would be a statement about one particular analysis. With it, the statement becomes a theorem about *all possible* schemes of this shape: for $|S| \le p$ there is a concrete residue assignment defeating the scheme.

### 4.3 The collapse

**Theorem 4.4 (Collapse of the birthday-bound hierarchy).** *Let $p \ge 1$ and let $S$ be a finite search space. Then*
$$ S \text{ guarantees collisions modulo } p \qquad \Longleftrightarrow \qquad p < |S|. $$

*Proof.* ($\Leftarrow$) is Theorem 4.1. ($\Rightarrow$): suppose the guarantee holds but $|S| \le p$. By Theorem 4.3 there is a residue map $f$ into $\{0,\dots,p-1\}$ injective on $S$. By the guarantee, $f$ has a collision $x \ne y$ on $S$ with $f(x)=f(y)$; injectivity gives $x = y$, a contradiction. $\square$

**Corollary 4.5 (Exact threshold).** *$S$ guarantees collisions modulo $p$ if and only if $|S| \ge p+1$.*

**Discussion.** Theorem 4.4 is deliberately unimpressive as a piece of mathematics and consequential as a piece of accounting. Its criterion is a statement about $|S|$ alone. It is blind to:

- the **arity** $r$ of the scheme;
- the way $S$ is *generated* — as $A^r$ for a stored set $A$, as a class-group orbit, as anything;
- the **additive structure** of the underlying numbers;
- the particular residue map, since the criterion quantifies over all of them.

Consequently every row of the hierarchy table has the same entry in the "objects inspected" column: $p+1$. What differs between rows is only the *generation cost*: how few stored elements suffice to name a search space of that size. Arity $r$ buys storage $|A| \approx p^{1/r}$, and nothing else.

### 4.4 The $r$-SUM instance

**Definition 4.6 (Tuple space).** For $r \ge 0$ and a finite set $A$ of naturals, the *$r$-tuple space* $T_r(A)$ is the set of all functions from $\{1,\dots,r\}$ to $A$. Its cardinality is $|A|^r$.

**Theorem 4.7 ($r$-SUM collision).** *Let $p \ge 1$, let $A$ be finite with $|A| = k$, and suppose $p < k^r$. Then there exist distinct $u, v \in T_r(A)$ with*
$$ \sum_{i=1}^r u_i \;\equiv\; \sum_{i=1}^r v_i \pmod p. $$

*Proof.* Apply Theorem 4.1 with $S = T_r(A)$, of cardinality $k^r > p$, and the residue map $u \mapsto \bigl(\sum_i u_i\bigr) \bmod p$. $\square$

For $r = 2$ this is the sumset collision $a + b \equiv c+d$; for $r=3$ the $3$SUM collision $a+b+c \equiv d+e+f$.

**Theorem 4.8 ($r$-SUM adversary).** *If $k^r \le p$ there is a residue map into $\{0,\dots,p-1\}$ injective on $T_r(A)$: no $r$-SUM scheme with $|A| = k$ can be guaranteed to collide.*

**Corollary 4.9 (Storage monotonicity).** *If $k \ge 1$, $r \le r'$, and $p < k^r$, then $p < k^{r'}$. Raising the arity never increases the storage requirement.*

Corollary 4.9 is the *only* sense in which the hierarchy is real, and we state it explicitly to make the contrast exact.

### 4.5 A quantitative snapshot: $p = 997$

**Proposition 4.10.** *For every natural $k$:*
$$ 997 < k^3 \iff k \ge 10, \qquad\qquad 997 < k^2 \iff k \ge 32. $$

*Proof.* $9^3 = 729 \le 997 < 1000 = 10^3$ and $31^2 = 961 \le 997 < 1024 = 32^2$; monotonicity of $k \mapsto k^m$ does the rest. $\square$

**Corollary 4.11 (The exponent gap, and its emptiness).** *At $p = 997$ the $3$SUM scheme requires $10$ stored elements where the sumset scheme requires $32$ — a $3.2\times$ improvement in storage, the promised $p^{1/2} \to p^{1/3}$. Yet the inspected search spaces are $10^3 = 1000$ and $32^2 = 1024$, both exceeding $997$ by the smallest possible margin, and differing from each other by $2.4\%$.*

The two schemes do the same work. One of them merely remembers less while doing it.

---

## 5. The $\sqrt N$ barrier

**Lemma 5.1.** *If $q \le p$ then $\lfloor\sqrt{pq}\rfloor \le p$.*

*Proof.* $pq \le p^2$, so $\lfloor\sqrt{pq}\rfloor \le \lfloor\sqrt{p^2}\rfloor = p$. $\square$

**Theorem 5.2 (Arity-independent cost barrier).** *Let $N = pq$ with $q \le p$ and $p \ge 1$. If a search space $S$ guarantees collisions modulo $p$, then*
$$ |S| > \lfloor\sqrt{N}\rfloor. $$

*Proof.* Theorem 4.4 gives $|S| > p$, and Lemma 5.1 gives $p \ge \lfloor\sqrt N\rfloor$. $\square$

**Corollary 5.3 ($r$-SUM barrier).** *For any arity $r$ and any $A$ with $p < |A|^r$ and $q \le p$, we have $|A|^r > \lfloor\sqrt{pq}\rfloor$: a guaranteed $r$-SUM scheme inspects more than $\sqrt N$ tuples.*

This is the paper's headline negative result, and it is worth being precise about what it does and does not say.

*It does say:* no scheme in this family — of any arity, over any set of integers, with any generation rule — can be *guaranteed* to find a collision modulo the larger prime factor of $N$ while inspecting at most $\sqrt N$ objects. The bound is unconditional, non-asymptotic and non-probabilistic.

*It does not say:* that factoring requires $\sqrt N$ work. It says that *this family of methods* does. Sieve methods do not proceed by waiting for a residue collision in a search space, and are not subject to Theorem 5.2. The theorem's value is precisely that it draws the boundary of the collision paradigm sharply enough to say where one must leave it.

---

## 6. The amplitude barrier

Theorem 5.2 counts objects. We now show a completely different quantity is also stuck at $\sqrt N$: the *arithmetic size* of the integers a scheme manipulates. This obstruction is invisible to the counting analysis, and it applies even to schemes that inspect infinitely many tuples.

**Definition 6.1 (Sum set of a tuple space).** For $r \ge 0$ and finite $A$, let
$$ \Sigma_r(A) \;=\; \Bigl\{ \textstyle\sum_{i=1}^r u_i \;:\; u \in T_r(A) \Bigr\}, $$
the set of *distinct integer values* achieved as $r$-tuple sums.

**Lemma 6.2.** *If every $a \in A$ satisfies $a \le M$, then every $s \in \Sigma_r(A)$ satisfies $s \le rM$.*

**Theorem 6.3 (Amplitude bound).** *If $A \subseteq [1, M]$, then $|\Sigma_r(A)| \le rM + 1$, however large $|A|^r$ may be.*

*Proof.* By Lemma 6.2, $\Sigma_r(A) \subseteq \{0,1,\dots,rM\}$. $\square$

**Theorem 6.4 (All collisions trivial when entries are small).** *Let $A \subseteq [1,M]$ and suppose $rM < p$. Then for any $u, v \in T_r(A)$ with $\sum_i u_i \equiv \sum_i v_i \pmod p$, one has $\sum_i u_i = \sum_i v_i$.*

*Proof.* Suppose without loss of generality $\sum u_i < \sum v_i$. The congruence gives $p \mid \sum v_i - \sum u_i$, and this difference is positive, hence $\ge p$. But both sums lie in $[0, rM]$, so the difference is at most $rM < p$ — contradiction. $\square$

**Corollary 6.5 (Amplitude barrier).** *A scheme with $A \subseteq [1,M]$ and $rM < p$ cannot factor $N = pq$ by collision, no matter how many tuples it inspects: every collision it finds has difference $0$, and the reveal step returns $\gcd(0, N) = N$, never a proper factor. Success therefore requires $p \le rM$, i.e. entries of size at least $p/r \ge \sqrt N / r$.*

**Remark 6.6 (Structure cannot help).** Theorem 6.3 depends only on the interval $[1,M]$ containing $A$ — never on $A$'s additive structure. Sidon sets, geometric progressions, smooth-number sets, and any other additive-combinatorial device produce sums confined to the same interval and are therefore subject to the same bound. This is a sharp limitation on a natural line of attack: one cannot arrange for a small-entry set to have an unusually rich modular image, because the *integer* image is capped by amplitude alone.

**Remark 6.7 (The bound is nearly attained).** Theorem 6.3 gives the necessary condition $p \le rM$. For the full interval $A = \{1,\dots,M\}$ the sum set is exactly $\{r, r+1, \dots, rM\}$, of size $r(M-1)+1$, so the counting condition $p < |\Sigma_r(A)|$ holds precisely when $M \ge p/r + 1$. The two conditions differ by a single additive step, so the amplitude bound is essentially attained rather than lossy. For $r = 3$ this predicts the smallest workable entry bound $M = \lceil p/3\rceil + 1$, i.e. $M = 5$ at $p = 11$ and $M = 35$ at $p = 101$ — values confirmed by direct enumeration.

---

## 7. The span and coverage barriers

The previous sections analysed specific generation rules. We now abstract entirely.

**Definition 7.1 (Abstract collision scheme).** A *scheme* consists of a finite **search space** $S$ (whose cardinality $k = |S|$ is the scheme's cost) together with a **value map** $v : S \to \mathbb{N}$. Its **difference set** is
$$ D \;=\; \{\, v(x) - v(y) \;:\; x, y \in S,\; v(x)\ge v(y) \,\}, $$
and the scheme **reveals** $f$ from $N$ if some $d \in D$ has $d > 0$ and $\gcd(d, N) = f$.

**Lemma 7.2.** *$|D| \le k^2$.*

This definition is deliberately permissive. It covers sumset, $3$SUM, $r$-SUM, structured evaluation schemes, and anything else whose output is "take a $\gcd$ of a difference of two computed numbers with $N$". Whatever is proved about it applies to all of them at once.

### 7.1 Span

**Theorem 7.3 (Span barrier).** *If a scheme reveals $f$ from $N$, then some $d \in D$ satisfies $d \ge f$.*

*Proof.* Take $d \in D$ with $d > 0$ and $\gcd(d, N) = f$. Then $f \mid d$ and $d > 0$, so $f \le d$. $\square$

**Corollary 7.4 ($\sqrt N$ form).** *If $N = pq$ with $q \le p$ and a scheme reveals $p$, then two of its values differ by at least $\lfloor\sqrt N\rfloor$; in particular its largest value is at least $\lfloor \sqrt N\rfloor$.*

**Corollary 7.5 (Small values never factor).** *If all values of a scheme are $< B$ and $B \le p$, the scheme cannot reveal $p$ from $N = pq$.*

*Proof.* All differences are $< B \le p$, contradicting Theorem 7.3. $\square$

A cleaner special case, in the same spirit but stated for integer value sets directly:

**Theorem 7.6 (Interval span barrier).** *If all values of a scheme lie in an interval $[L, L+p)$, then any two congruent values modulo $p$ are equal. Consequently no useful collision exists, and the value range must be at least $p$.*

**Remark 7.7 (Structure improves counting, never span).** Return to the structured-evaluation row. By Theorem 4.2, confining values to a set $B$ with $|B| \approx p/h$ makes collisions appear after only $|B| + 1$ evaluations — a genuine factor-$h$ saving over the generic $p+1$. But Theorem 7.3 is untouched by this: the revealed factor $p$ still forces two *integer values at distance at least $p$*. Structure compresses the number of objects; it cannot compress the objects. This is a clean separation between two resources that the naive cost accounting conflates.

### 7.2 Coverage

Could a single fixed scheme — a fixed table of numbers, computed once — factor many different semiprimes? The next bound says no, by pure counting on prime divisors.

**Lemma 7.8.** *Let $Q$ be a finite set of distinct primes, all $\ge P$, all dividing a positive integer $d$. Then $P^{|Q|} \le d$.*

*Proof.* The primes are distinct, so their product divides $d$; the product is at least $P^{|Q|}$; and $d > 0$. $\square$

**Corollary 7.9.** *If $P > 1$ and $d > 0$, then $d$ has at most $\log_P d$ distinct prime divisors $\ge P$.*

**Theorem 7.10 (Coverage barrier).** *Let a scheme have $k$ search points and let $Q$ be a set of primes such that every $p \in Q$ satisfies $p \ge P > 1$ and divides some difference $d \in D$ with $0 < d \le B$. Then*
$$ |Q| \;\le\; \log_P(B)\cdot k^2. $$

*Proof sketch.* Choose for each $p \in Q$ a witnessing difference $g(p) \in D$ with $0 < g(p) \le B$ and $p \mid g(p)$. The image $g(Q)$ is contained in $D$, so $|g(Q)| \le k^2$ by Lemma 7.2. Each fibre $g^{-1}(b)$ consists of distinct primes $\ge P$ all dividing the single positive integer $b \le B$, so by Corollary 7.9 and monotonicity of the logarithm, $|g^{-1}(b)| \le \log_P b \le \log_P B$. Summing over fibres, $|Q| \le \log_P(B)\cdot|g(Q)| \le \log_P(B)\cdot k^2$. $\square$

**Corollary 7.11 (Cost form).** *A scheme required to reveal each of $T$ distinct primes $\ge P$, with all differences bounded by $B$, must have search space size $k$ satisfying $T \le \log_P(B)\cdot k^2$, i.e.*
$$ k \;\ge\; \sqrt{T / \log_P B}. $$

The significance of Theorem 7.10 is that it is a *non-uniformity* bound: it limits what precomputation can achieve. Whereas Theorem 5.2 says a scheme is slow on each input, Theorem 7.10 says a scheme cannot be reused across inputs. Together they close the two obvious escape routes.

---

## 8. The positive theorem: collision factoring, certified

We now assemble the pieces. The following says that the two barriers are not merely necessary but, once cleared, sufficient.

**Theorem 8.1 (Master theorem for $r$-SUM collision factoring).** *Let $N = pq$ with $p, q$ prime. Let $A$ be a finite set of positive integers with $a \le M$ for all $a \in A$, and suppose*

1. *(amplitude) $rM < N$, and*
2. *(counting) $p < |\Sigma_r(A)|$.*

*Then there exist $s, t \in \Sigma_r(A)$ with $t < s$ and*
$$ \gcd(s - t,\, N) \;=\; p. $$

*Proof.* Since $|\Sigma_r(A)| > p$, the map $x \mapsto x \bmod p$ cannot be injective on $\Sigma_r(A)$; pick $s \ne t$ in $\Sigma_r(A)$ with $s \equiv t \pmod p$ and, relabelling, $t < s$. Then $p \mid s - t$. Also $s \le rM < N$ by Lemma 6.2 and hypothesis 1. Corollary 3.6 gives $\gcd(s-t, N) = p$. $\square$

**Corollary 8.2 ($3$SUM instance).** *With $r = 3$: if $A \subseteq [1,M]$ with $3M < N$ and the triple-sum set $\Sigma_3(A)$ has more than $p$ elements, then two achieved triple sums differ by a quantity whose $\gcd$ with $N$ is exactly $p$.*

**Theorem 8.3 (Both barriers are necessary).** *Let $q \le p$, let $A \subseteq [1, M]$, and suppose $p < |\Sigma_r(A)|$ (so that a useful collision is guaranteed). Then*

1. $p \le rM$ *— the entries must have size at least $p/r$; and*
2. $|A|^r > \lfloor\sqrt{pq}\rfloor$ *— the tuple count exceeds $\sqrt N$.*

*Proof.* (1) By Theorem 6.3, $|\Sigma_r(A)| \le rM+1$; combined with $p < |\Sigma_r(A)|$ this gives $p < rM+1$, i.e. $p \le rM$. (2) $\Sigma_r(A)$ is an image of $T_r(A)$, so $|\Sigma_r(A)| \le |A|^r$, whence $p < |A|^r$; now apply Corollary 5.3. $\square$

**Corollary 8.4 ($3$SUM cost profile).** *A $3$SUM scheme against $N = pq$ with $q \le p$ requires entries of size at least $p/3$ and inspects more than $\lfloor\sqrt N\rfloor$ triples. Both costs are $\Omega(\sqrt N)$.*

This is the final accounting. The exponent improvement $p^{1/2} \to p^{1/3}$ is real, it is confined to storage, and every other resource stays at $\sqrt N$.

---

## 9. Algorithms

We record the two procedures the theory certifies, with their complexities.

### 9.1 Sum-set collision factoring

**Input:** a semiprime $N$, an arity $r$, an entry bound $M$.
**Output:** a nontrivial factor of $N$, or failure.

1. Choose $A \subseteq [1, M]$.
2. Enumerate $\Sigma_r(A)$, maintaining a dictionary from residues modulo a *guessed* modulus — or, in practice, maintain the achieved sums themselves and sort.
3. For each pair of achieved sums $t < s$, compute $g = \gcd(s - t, N)$.
4. If $1 < g < N$, output $g$.

By Theorem 8.1, if $rM < N$ and $|\Sigma_r(A)| > p$, step 4 succeeds. By Theorem 8.3, this requires $M \ge p/r$ and more than $\sqrt N$ inspected tuples, so the procedure is $\Omega(\sqrt N)$ and — with sorting — $O(k^r \log k^r)$ where $k = |A|$.

Note a subtlety the theory clarifies: one does not need to know $p$ to run the algorithm. The residue structure modulo $p$ is invisible; only the $\gcd$ test at the end reveals whether a difference happened to be a multiple of $p$. The birthday bound guarantees that *some* pair works once the sum set exceeds $p$ in size.

### 9.2 Threshold and barrier calculator

Given $p$ (or a target $N$) and an arity $r$, one computes:

- the **storage threshold** $k^\ast(p, r) = \min\{k : k^r > p\} = \lfloor p^{1/r}\rfloor + 1$;
- the **work** $\bigl(k^\ast\bigr)^r$, which always exceeds $p$ and is within a small factor of it;
- the **amplitude threshold** $M^\ast(p,r) = \lceil p/r\rceil$ (necessary), attained by the full interval at $\lceil p/r\rceil + 1$;
- the **span requirement** $\lfloor\sqrt N\rfloor$.

The output is the hierarchy table for that instance, exhibiting the collapse numerically. This is the computation performed in the accompanying numerical study.

---

## 10. Applications and interpretation

**A bridge between problem families.** Corollary 3.4 makes precise the sense in which $3$SUM modulo an unknown prime is a factoring primitive. This is a bridge in the fine-grained complexity sense: an efficient algorithm for the modular variant of $3$SUM against adversarially hidden moduli would break factoring. The bridge is one-directional and, as our barriers show, load-limited; but it identifies a modular $3$SUM variant whose hardness is at least that of factoring at the $\sqrt N$ scale.

**A design principle for cost accounting.** The clearest methodological lesson is Corollary 4.11: an improvement in one resource (storage, $p^{1/2} \to p^{1/3}$) may be exactly compensated by no improvement at all in another (work, always $> p$). Because the collapse theorem is an *equivalence*, this is not a limitation of an analysis but a fact about the problem. Whenever a family of algorithms is parameterised by "how cleverly the search space is generated," it is worth asking whether the acceptance criterion depends on generation at all. Here it does not.

**Three barriers of different type.** It is unusual for a single $\Omega(\sqrt N)$ bound to be provable in three independent ways:

- *counting* (Theorem 5.2) — you must inspect many objects;
- *amplitude/span* (Corollary 6.5, Corollary 7.4) — the objects must themselves be large;
- *coverage* (Theorem 7.10) — one fixed set of objects cannot serve many inputs.

Each of these could in principle be circumvented separately; none of them can be circumvented by arity. That robustness is the reason we regard $\sqrt N$ as the true home of the collision paradigm rather than an artefact.

**What is not claimed.** None of this bears on the complexity of factoring itself. Sub-exponential methods exist and are not collision searches. The results here delimit a paradigm, and delimiting a paradigm crisply is useful precisely because it tells the algorithm designer where not to look.

---

## 11. Future directions

The framework above suggests three falsifiable conjectures.

**C1. Every $\gcd$-extraction scheme obeys a span–coverage trade-off.** For an abstract scheme with $k$ search points and values bounded by $B$ that reveals the larger factor of *every* semiprime $N = pq$ with $\sqrt N \in [P, 2P)$, one should have
$$ k^2 \cdot \log_P B \;\ge\; \pi(2P) - \pi(P), $$
hence $k \ge P^{1/2 - o(1)}$ — a $\sqrt N$ lower bound with no probabilistic or oracle assumptions. The coverage barrier (Theorem 7.10) already bounds the number of large primes a fixed value set can expose by $\log_P(B)\cdot k^2$; only a prime-counting input is needed to convert this into an unconditional cost bound.

**C2. Non-uniform sets do not beat the amplitude barrier.** For every finite $A \subseteq [1,M]$ and every arity $r$, the number of distinct residues modulo $p$ realised by $r$-tuple sums over $A$ should be at most $\min(rM+1,\, p)$, and the requirement $p \le rM$ for a guaranteed factor-revealing collision should be unimprovable by any choice of $A$ — Sidon sets, geometric progressions and smooth-number sets included. The amplitude bound depends only on the interval containing $A$, never on its additive structure, so additive-combinatorial cleverness cannot help. Because the measured interval thresholds match the predicted values exactly at small $p$ ($M = 5$ at $p = 11$, $M = 35$ at $p = 101$, both with $r = 3$), the conjecture is sharp and would be falsified by a single counterexample set.

**C3. Modular structure can beat the counting threshold but never the span.** For any scheme whose values are constrained to a structured residue set $B$ with $|B| \approx p/h$, collisions appear after $|B|+1$ evaluations, yet the revealed factor still forces two integer values at distance $\ge p$. Structure should therefore improve the collision *count* by the factor $h$ while leaving the arithmetic size of the manipulated objects untouched, since the span barrier constrains numerical values alone and is invariant under any change of indexing.

Beyond these, two directions seem worth pursuing. First, a *probabilistic* refinement: the collapse theorem is a worst-case guarantee, and the average-case birthday behaviour (collisions after $\Theta(\sqrt{p})$ random samples) deserves the same arity-independence analysis — we expect the same collapse, with $\sqrt p$ in place of $p$, and with the amplitude barrier unchanged. Second, an examination of whether any *non*-collision extraction rule (something other than $\gcd$ of a difference) evades Theorem 7.3, which would identify precisely which feature of the paradigm the span barrier punishes.

---

## 12. Conclusion

A single greatest-common-divisor computation converts a $3$SUM solution modulo a hidden prime into that prime, with no side conditions beyond smallness. This makes a family of collision-based factoring schemes available, apparently arranged in a hierarchy in which higher arity means a better exponent.

The hierarchy collapses. A collision is guaranteed exactly when the search space exceeds the modulus — a criterion in which the arity does not appear — so all schemes share the threshold $p+1$, and hence exceed $\sqrt N$. Two independent barriers reach the same magnitude for different reasons: the amplitude/span obstruction forces the manipulated integers to be of size $\sqrt N$, and the coverage obstruction forbids a fixed scheme from serving many inputs. Once both barriers are cleared, the method provably works.

The improvement from $p^{1/2}$ to $p^{1/3}$ is real, and it is an improvement in storage alone. The barrier does not move.
