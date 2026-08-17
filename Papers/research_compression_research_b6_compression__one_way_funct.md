# Compression Beyond the Pigeonhole Bound: Randomness, Search, and the Cryptographic Boundary

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We give a complete, self-contained and resource-abstract account of three successive limits on data compression, and prove that the third is exactly the cryptographic hardness boundary.

First, an unconditional counting theorem: for an arbitrary decompressor $D$ — any map from bit strings to objects — at most $2^{s+1}-1$ objects admit a $D$-program of length $\le s$. Consequently some string of every length $s+1$ is incompressible, and at most a $2^{-(c-1)}$ fraction of length-$n$ strings compress to $n-c$ bits.

Second, a *seed-budget theorem*: a randomized (seeded) family of decompressors indexed by a finite seed space $R$ compresses at most $|R| \cdot (2^{s+1}-1)$ objects to $s$ bits, and this is tight — with all $2^k$ seeds of length $k$, the "seed carries the prefix" family compresses every string of length $k+s$ to $s$ bits. In the converse direction, a single deterministic decompressor simulates any seeded family at an additive cost of $2k+1$ bits for $k$-bit seeds. Randomness therefore helps worst-case compression by exactly the seed length, up to an additive constant, and no computational assumption can alter this.

Third, an equivalence between compression and cryptography. Working relative to an abstract class $\mathcal{C}$ of algorithms closed under *length guarding* and *bounded search over the guard parameter*, we prove that inverting all honest functions of $\mathcal{C}$ is equivalent to solving the shortest-program problem for all honest decompressors of $\mathcal{C}$; hence **one-way functions exist for $\mathcal{C}$ if and only if compression search is hard for $\mathcal{C}$**. The equivalence is robust: it survives arbitrary additive approximation slack $\delta$, and a decision oracle for the prefix-compressibility predicate already yields an optimal-program finder by a bit-by-bit reconstruction. Finally, we show the resulting *description gap* is not a finite artefact: for any collection of algorithms closed under finite patching in which $f$ is uninvertible, every algorithm of the collection fails on an infinite set of inputs — and we exhibit an explicit collection and function witnessing that this hypothesis is satisfiable.

The overall calibration: *randomness helps compression exactly up to the seed length, and efficient compression then stops precisely at the cryptographic hardness boundary — whether one demands exact optimality, approximate optimality, or merely a yes/no answer.*

**Keywords:** Kolmogorov complexity, one-way functions, compression, search-to-decision reduction, derandomization, pigeonhole bound, incompressibility.

---

## 1. Introduction

### 1.1 The question

Fix a way of interpreting descriptions as objects. How short can a description be, and can it be found?

The first half of that question — how short a description *can* be — is classical and has a clean answer: counting. The second half — whether the short description can be *produced by an algorithm* — is where the subject becomes computational, and where, as we show, it becomes cryptographic.

This paper develops both halves in a single elementary framework designed so that the counting arguments and the reductions can be stated without recourse to any particular machine model. The central deliverable is a *characterization*: a precise mapping between compression tasks and cryptographic assumptions, together with the consequences for achievable worst-case bounds.

### 1.2 Why resource-abstractness

Statements like "shortest-program finding is as hard as inverting one-way functions" are folklore, but their proofs are usually entangled with a machine model, a time bound, and an error probability. The reduction actually uses only two closure properties of the class of algorithms in question:

* the ability to form a **length-guarded** variant of a function, and
* the ability to run a **bounded linear search** over the guard parameter, calling a family of subroutines.

We therefore axiomatize exactly those two properties. Everything else — polynomial time, logarithmic space, circuit families, any resource discipline whatsoever — is a parameter. This makes each theorem a statement about *all* such settings at once, and makes the hypotheses that are genuinely needed visible: we found that *honesty* (every value in the range has a preimage of admissible length) is essential, and that the conditional, prefix-based decision oracle is strictly what the search-to-decision reduction consumes.

### 1.3 Results

* **Theorem A (Pigeonhole Ceiling).** At most $2^{s+1}-1$ objects have $D$-complexity $\le s$, for any $D$.
* **Theorem B (Seed-Budget).** A seeded family with seed space $R$ compresses at most $|R|(2^{s+1}-1)$ objects to $s$ bits.
* **Theorem C (Randomness Gain Is Exactly the Seed Length).** The bound of Theorem B is achieved by the prefix family; and derandomization costs only $2k+1$ additive bits.
* **Theorem D (Main Equivalence).** For a search-closed class, inverting all honest functions $\iff$ optimally compressing for all honest decompressors.
* **Theorem E (Cryptographic Form).** One-way functions exist for a search-closed class $\iff$ compression search is hard for it; and likewise for approximate compression search with arbitrary slack.
* **Theorem F (Search to Decision).** A prefix-compressibility decision oracle yields an optimal-program finder, hence an inverter; under a one-way function no algorithm of the class implements the oracle.
* **Theorem G (Description Gap).** Under a one-way function, every algorithm of the class misses a string possessing a short description; universality does not close the gap.
* **Theorem H (Infinite Failure).** If the collection of algorithms is closed under finite patching, every algorithm misses *infinitely many* such strings; witnessed by an explicit collection and function.

---

## 2. Description systems and complexity

Throughout, $\mathrm{Str}$ denotes the set of finite bit strings (finite lists of booleans), $|p|$ the length of $p \in \mathrm{Str}$, $\frown$ concatenation, and $\alpha$ an arbitrary set of objects.

**Definition 2.1 (Decompressor, describability, complexity).** A *decompressor* is any function $D : \mathrm{Str} \to \alpha$. An object $y \in \alpha$ is *describable* under $D$ if $D(p) = y$ for some $p$; in that case $p$ is a *$D$-program* for $y$. The *complexity* of $y$ is
$$K_D(y) \;=\; \inf\{\, n \in \mathbb{N} \;:\; \exists p,\ |p| = n \ \wedge\ D(p) = y \,\},$$
with the convention $K_D(y)=0$ if $y$ is not describable.

Note that no computability or efficiency requirement is placed on $D$. This is deliberate: the counting theorems of §3 must hold against arbitrary adversarial decompressors, while §5 onwards restricts to a class of algorithms and asks what such a class can *find*.

**Lemma 2.2 (Basic facts).**
(i) If $D(p) = y$ then $K_D(y) \le |p|$.
(ii) If $y$ is describable then there exists $p$ with $|p| = K_D(y)$ and $D(p) = y$ — the infimum is attained.
(iii) $\bigl(\exists p,\ |p| \le s \wedge D(p) = y\bigr) \iff \bigl(y \text{ describable and } K_D(y) \le s\bigr)$.

*Proof sketch.* (i) is immediate from the definition of the infimum over a set containing $|p|$. For (ii), the set of lengths of $D$-programs for $y$ is a nonempty set of naturals, hence contains its infimum; well-ordering delivers a witness of exactly that length. (iii) follows from (i) and (ii). $\square$

### 2.1 A concrete injective numeral

The counting arguments need one elementary fact: there are exactly $2^{s+1}-1$ bit strings of length $\le s$. We use an explicit *leading-one numeral*, which also makes the counting constructive.

**Definition 2.3.** Define $\nu : \mathrm{Str} \to \mathbb{N}$ by $\nu(\varepsilon) = 1$ and $\nu(b \frown t) = 2\nu(t) + [b]$, where $[b] \in \{0,1\}$ is the bit value of $b$.

**Lemma 2.4.** $\nu$ is injective, $\nu(p) \ge 1$, and $\nu(p) < 2^{|p|+1}$.

*Proof sketch.* Positivity and the bound are immediate inductions: $\nu(b\frown t) = 2\nu(t)+[b] < 2\cdot 2^{|t|+1} = 2^{|t|+2}$. Injectivity is an induction on the first argument, using positivity to rule out $\varepsilon$ against a nonempty string (in that case $\nu(\varepsilon)=1$ while $\nu(b\frown t) = 2\nu(t)+[b] \ge 2$), and parity to recover the leading bit in the cons/cons case. $\square$

Thus $p \mapsto \nu(p) - 1$ injects the strings of length $\le s$ into $\{0, 1, \dots, 2^{s+1}-2\}$, a set of size $2^{s+1}-1$.

---

## 3. The unconditional ceiling

**Theorem 3.1 (Pigeonhole Ceiling).** Let $D : \mathrm{Str} \to \alpha$ be any decompressor, $s \in \mathbb{N}$, and $T$ a finite set of objects such that every $y \in T$ is describable with $K_D(y) \le s$. Then
$$|T| \;\le\; 2^{s+1} - 1 .$$

*Proof sketch.* By Lemma 2.2(iii), choose for each $y \in T$ a program $\pi(y)$ with $|\pi(y)| \le s$ and $D(\pi(y)) = y$. The map $y \mapsto \nu(\pi(y)) - 1$ sends $T$ into $\{0,\dots,2^{s+1}-2\}$ by Lemma 2.4, and it is injective on $T$: if $\nu(\pi(y)) - 1 = \nu(\pi(z)) - 1$ then (using $\nu \ge 1$) $\nu(\pi(y)) = \nu(\pi(z))$, so $\pi(y) = \pi(z)$ by injectivity of $\nu$, hence $y = D(\pi(y)) = D(\pi(z)) = z$. Comparing cardinalities gives the claim. $\square$

This is the information-theoretic ceiling. It is independent of the computational power available to the compressor or the decompressor; it is a statement about how many short strings exist.

**Theorem 3.2 (Incompressible strings exist).** For every $D : \mathrm{Str} \to \mathrm{Str}$ and every $s$, there exists $y$ with $|y| = s+1$ that is *not* compressible to $s$ bits, i.e. it fails to satisfy "describable and $K_D(y) \le s$".

*Proof sketch.* Otherwise all $2^{s+1}$ strings of length exactly $s+1$ would form a set $T$ satisfying the hypothesis of Theorem 3.1, giving $2^{s+1} \le 2^{s+1}-1$, absurd. $\square$

**Theorem 3.3 (Density of incompressibility).** For any $D : \mathrm{Str} \to \mathrm{Str}$ and $1 \le c \le n$, let $m$ be the number of strings of length $n$ compressible to $n-c$ bits. Then
$$2^{c-1} \cdot m \;\le\; 2^{n}.$$
Equivalently, at most a $2^{-(c-1)}$ fraction of length-$n$ strings can be compressed by $c$ bits.

*Proof sketch.* By Theorem 3.1, $m \le 2^{n-c+1}-1$. Multiply by $2^{c-1}$ and use $2^{c-1}\cdot 2^{n-c+1} = 2^{n}$. $\square$

Theorem 3.3 is the quantitative reason lossless compression is useful only on structured data: saving $c$ bits is possible for at most a $2^{-(c-1)}$ fraction of inputs, whatever the format.

---

## 4. Randomness: the seed budget and its tightness

Randomized compression is modelled as follows: the compressor and decompressor share a seed $r$ drawn from a finite space $R$; the seed is *not* charged to the program length.

**Definition 4.1 (Seeded system).** A *seeded decompression system* is a family $D : R \to (\mathrm{Str} \to \alpha)$ with $R$ finite. An object $y$ is *$s$-compressible under the system* if there is a seed $r$ with $y$ describable under $D_r$ and $K_{D_r}(y) \le s$.

**Theorem 4.2 (Seed-Budget Theorem).** If $T$ is a finite set of objects all $s$-compressible under a seeded system with seed space $R$, then
$$|T| \;\le\; |R| \cdot \bigl(2^{s+1}-1\bigr).$$

*Proof sketch.* For each $y \in T$ choose a pair $(r_y, p_y)$ with $|p_y| \le s$ and $D_{r_y}(p_y) = y$. The map $y \mapsto (r_y,\, \nu(p_y)-1)$ injects $T$ into $R \times \{0,\dots,2^{s+1}-2\}$, by the same argument as Theorem 3.1 applied fibrewise. Hence $|T| \le |R|\,(2^{s+1}-1)$. $\square$

Writing $|R| = 2^{k}$, this says that $k$ random bits buy at most $k+1$ bits of compression. Is the bound attained?

**Definition 4.3 (Prefix family).** For $r \in \mathrm{Str}$, let $P_r(p) = r \frown p$.

**Theorem 4.4 (Matching construction).** For all $k, s$ and every $y$ with $|y| = k+s$, there is a seed $r$ with $|r| = k$ such that $y$ is describable under $P_r$ and $K_{P_r}(y) \le s$.

*Proof sketch.* Take $r$ to be the first $k$ bits of $y$ and $p$ the remaining $s$ bits; then $P_r(p) = y$ and $|p| = s$. $\square$

**Theorem 4.5 (Randomness gain is exactly the seed length).** For all $k,s$:
1. every one of the $2^{k}\cdot 2^{s}$ strings of length $k+s$ is compressed to $s$ bits by the prefix family with the $2^{k}$ seeds of length $k$; and
2. no seeded family with seed space $R$ compresses more than $|R|(2^{s+1}-1)$ objects to $s$ bits.

*Proof sketch.* (1) is Theorem 4.4 together with the count $|\{y : |y| = k+s\}| = 2^{k+s}$; (2) is Theorem 4.2. $\square$

Part (1) exceeds the deterministic ceiling by a factor of $2^{k}$, and part (2) says no family exceeds it by more than that factor. Randomness therefore contributes exactly $\log_2|R|$ bits, up to one additive bit — never more.

### 4.1 Derandomization at the seed price

The complementary statement is that the gain is *only* bookkeeping: a deterministic decompressor recovers it by paying for the seed inside the program.

**Definition 4.6 (Self-delimiting pairing).** For $i \in \mathbb{N}$ and $p \in \mathrm{Str}$, let $\mathrm{tag}(i,p) = \underbrace{\texttt{1}\cdots\texttt{1}}_{i} \frown \texttt{0} \frown p$; the parser $\mathrm{parse}$ reads the leading run of $\texttt{1}$s, discards the separating $\texttt{0}$, and returns $(i,p)$. Then $|\mathrm{tag}(i,p)| = i + 1 + |p|$ and $\mathrm{parse}(\mathrm{tag}(i,p)) = (i,p)$. For strings, let $\langle p, q\rangle = \mathrm{tag}(|p|,\, p \frown q)$, so that $|\langle p,q\rangle| = 2|p| + 1 + |q|$ and the pair is uniquely recoverable.

**Definition 4.7 (Packaged family).** Given a family $D$ indexed by *strings* (seeds), define $\mathrm{Idx}\,D\,(z) = D_{r}(p)$ where $(r,p) = \langle\cdot,\cdot\rangle^{-1}(z)$.

**Theorem 4.8 (Derandomization cost).** For every seeded family $D$, every seed $r$ and every $y$ describable under $D_r$,
$$K_{\mathrm{Idx}\,D}(y) \;\le\; 2|r| + 1 + K_{D_r}(y).$$
In particular, if $|r| = k$ and $K_{D_r}(y) \le s$, then $y$ is describable under the single deterministic decompressor $\mathrm{Idx}\,D$ with $K_{\mathrm{Idx}\,D}(y) \le 2k+1+s$.

*Proof sketch.* Take a shortest $D_r$-program $p$ for $y$ and feed $\langle r,p\rangle$ to $\mathrm{Idx}\,D$; use the length identity of Definition 4.6. $\square$

Theorems 4.2 and 4.8 bracket the value of randomness from both sides: it is worth the seed length, to within a factor $2$ on that length coming from the self-delimiting encoding, and nothing more. This answers, quantitatively and unconditionally, the question "can random number generators help compression?".

### 4.2 Universality and subadditivity

The same pairing yields the classical invariance phenomenon, which we record because it is used in §7.

**Definition 4.9 (Universal decompressor).** For a family $D : \mathbb{N} \to (\mathrm{Str} \to \mathrm{Str})$, define $U_D(z) = D_i(p)$ where $(i,p) = \mathrm{parse}(z)$.

**Theorem 4.10 (Invariance).** If $y$ is describable under $D_i$, then $K_{U_D}(y) \le K_{D_i}(y) + i + 1$. Moreover $y$ is describable under $U_D$ iff it is describable under some $D_i$.

*Proof sketch.* Prefix a shortest $D_i$-program with the unary index; the length identity gives the bound. The "moreover" follows by parsing an arbitrary $U_D$-program. $\square$

**Theorem 4.11 (Subadditivity).** For decompressors $D_1, D_2$ and describable $x, y$,
$$K_{D_1 \otimes D_2}(x \frown y) \;\le\; 2K_{D_1}(x) + 1 + K_{D_2}(y),$$
where $(D_1 \otimes D_2)(z) = D_1(p) \frown D_2(q)$ for $(p,q) = \langle\cdot,\cdot\rangle^{-1}(z)$.

*Proof sketch.* Pair shortest programs for $x$ and $y$; apply the length identity for $\langle\cdot,\cdot\rangle$. $\square$

---

## 5. Compression search and inversion

We now turn from *existence* of short descriptions to their *discovery*.

**Definition 5.1 (Inversion task).** An algorithm $A$ *inverts* $f : \mathrm{Str} \to \mathrm{Str}$ if $f(A(y)) = y$ for every $y$ in the range of $f$.

**Definition 5.2 (Compression-search task).** An algorithm $A$ is a *shortest-program finder* for the decompressor $D$ if for every describable $y$,
$$D(A(y)) = y \quad\text{and}\quad |A(y)| = K_D(y).$$

Definition 5.2 is the finitary analogue of computing a witness for $K^{t}$ (the resource-bounded complexity), i.e. of the search version of MINKT.

**Proposition 5.3 (Compression search dominates inversion).** Every shortest-program finder for $D$ inverts $D$.

*Proof.* Immediate: the first conjunct of Definition 5.2 is precisely the inversion condition. $\square$

The converse requires work, because an inverter offers no control over the *length* of the preimage it returns. The following device supplies that control.

**Definition 5.4 (Length guard).** For $f : \mathrm{Str}\to\mathrm{Str}$ and $l \in \mathbb{N}$ let
$$f_l(p) \;=\; \begin{cases} \texttt{1} \frown f(p), & |p| \le l, \\ \texttt{0} \frown p, & |p| > l.\end{cases}$$

The tag bit turns a length constraint into an inversion constraint: any inverter $A_l$ for $f_l$, queried on $\texttt{1}\frown y$, must return a $p$ with $f_l(p) = \texttt{1}\frown y$, which forces both $|p| \le l$ and $f(p) = y$. Conversely $\texttt{1}\frown y$ lies in the range of $f_l$ exactly when $y$ has an $f$-program of length $\le l$, i.e. when $K_f(y) \le l$. Hence:

**Lemma 5.5 (Guard semantics).** For any $y$ and $l$: $\texttt{1}\frown y$ is describable under $f_l$ $\iff$ $y$ is describable under $f$ and $K_f(y) \le l$. If $A_l$ inverts $f_l$ and $K_f(y)\le l$, then $A_l(\texttt{1}\frown y)$ is an $f$-program for $y$ of length $\le l$.

**Definition 5.6 (Bounded search).** For a predicate $P : \mathbb{N}\to\{\text{true},\text{false}\}$ and a fuel bound $F$, let $\mathrm{least}(P,F)$ be the least $l \le F$ with $P(l)$, computed by linear scan (returning $F$'s scan default if none exists). If some $l \le F$ satisfies $P$, then $P(\mathrm{least}(P,F))$ holds and $P(m)$ fails for all $m < \mathrm{least}(P,F)$.

**Definition 5.7 (Assembled compressor).** Given $f$, a family of algorithms $A_\bullet$, and a fuel bound $F$, define
$$\mathrm{SF}_{f,A,F}(y) \;=\; A_{l^\star}(\texttt{1}\frown y), \qquad l^\star = \mathrm{least}\bigl(l \mapsto [\,f_l(A_l(\texttt{1}\frown y)) = \texttt{1}\frown y\,],\, F(|y|)\bigr).$$

**Theorem 5.8 (Inversion solves compression search).** Suppose $A_l$ inverts $f_l$ for every $l$. Then for every describable $y$ with $K_f(y) \le F(|y|)$,
$$f\bigl(\mathrm{SF}_{f,A,F}(y)\bigr) = y \quad\text{and}\quad \bigl|\mathrm{SF}_{f,A,F}(y)\bigr| = K_f(y).$$

*Proof sketch.* Write $P(l)$ for the tested predicate. The key claim is $P(l) \iff K_f(y) \le l$. ($\Leftarrow$) If $K_f(y) \le l$ then by Lemma 5.5 $\texttt{1}\frown y$ is in the range of $f_l$, so the inverter $A_l$ returns a preimage and $P(l)$ holds. ($\Rightarrow$) If $P(l)$ holds then $f_l(A_l(\texttt{1}\frown y)) = \texttt{1}\frown y$, so by the guard semantics $|A_l(\texttt{1}\frown y)| \le l$ and $f$ maps it to $y$, whence $K_f(y) \le l$. Since $K_f(y) \le F(|y|)$, the search finds $l^\star = K_f(y)$; the returned program satisfies $f(\cdot) = y$ and has length $\le l^\star = K_f(y)$, and $\ge K_f(y)$ by minimality of $K$. Hence equality. $\square$

Theorem 5.8 is the heart of the matter. Note where each hypothesis is used: the guard supplies *length control*; the search supplies *optimality*; the fuel bound supplies *termination at the right place*, and this is exactly where honesty will enter.

---

## 6. Classes of algorithms and the equivalence

**Definition 6.1 (Search-closed class).** A *search-closed class* $\mathcal{C}$ consists of a set $\mathrm{Comp}(\mathcal{C}) \subseteq \{\mathrm{Str}\to\mathrm{Str}\}$ of algorithms together with a predicate $\mathrm{Allowed}(\mathcal{C})$ on resource bounds $b : \mathbb{N}\to\mathbb{N}$, subject to:

* **(F1)** every constant bound is allowed;
* **(F2)** the identity bound $n \mapsto n$ is allowed;
* **(F3)** allowed bounds are closed under pointwise maximum;
* **(G)** *guard closure*: if $f \in \mathrm{Comp}(\mathcal{C})$ then $f_l \in \mathrm{Comp}(\mathcal{C})$ for every $l$;
* **(S)** *search closure*: if $f \in \mathrm{Comp}(\mathcal{C})$, $A_l \in \mathrm{Comp}(\mathcal{C})$ for all $l$, and $b$ is allowed, then $\mathrm{SF}_{f,A,b} \in \mathrm{Comp}(\mathcal{C})$.

The intended instance is "polynomial-time computable functions" with "polynomially bounded" resource bounds, but nothing below depends on that reading.

**Definition 6.2 (Honesty).** $f$ is *honest in $\mathcal{C}$* if there is an allowed bound $b$ with $K_f(y) \le b(|y|)$ for every describable $y$: every value has a preimage of admissible length. Candidate one-way functions in cryptography are honest in this sense.

**Lemma 6.3 (Guards preserve honesty).** If $\mathcal{C}$ satisfies (F1)–(F3), then $f_l$ is honest in $\mathcal{C}$ with bound $n \mapsto \max(l, n)$, for every $f$ and $l$.

*Proof sketch.* Let $y$ be describable under $f_l$, say $f_l(p) = y$. If $|p| \le l$ then $K_{f_l}(y) \le |p| \le l \le \max(l,|y|)$. Otherwise $y = \texttt{0}\frown p$, so $|y| = |p|+1$ and $K_{f_l}(y) \le |p| \le |y| \le \max(l,|y|)$. The bound $n\mapsto\max(l,n)$ is allowed by (F1)–(F3). $\square$

**Definition 6.4 (One-wayness, compression hardness).**
$f$ is *one-way in $\mathcal{C}$* if $f \in \mathrm{Comp}(\mathcal{C})$, $f$ is honest in $\mathcal{C}$, and no $A \in \mathrm{Comp}(\mathcal{C})$ inverts $f$.
The compression-search problem for $D$ is *hard for $\mathcal{C}$* if $D \in \mathrm{Comp}(\mathcal{C})$, $D$ is honest in $\mathcal{C}$, and no $A \in \mathrm{Comp}(\mathcal{C})$ is a shortest-program finder for $D$.

**Theorem 6.5 (Main equivalence).** For every search-closed class $\mathcal{C}$, the following are equivalent:
1. every honest $f \in \mathrm{Comp}(\mathcal{C})$ is inverted by some $A \in \mathrm{Comp}(\mathcal{C})$;
2. every honest $D \in \mathrm{Comp}(\mathcal{C})$ admits a shortest-program finder in $\mathrm{Comp}(\mathcal{C})$.

*Proof sketch.* (2) $\Rightarrow$ (1) is Proposition 5.3. For (1) $\Rightarrow$ (2), let $f$ be honest with allowed bound $b$. By guard closure (G) each $f_l$ lies in $\mathrm{Comp}(\mathcal{C})$, and by Lemma 6.3 each is honest, so (1) supplies $A_l \in \mathrm{Comp}(\mathcal{C})$ inverting $f_l$. Search closure (S) puts $\mathrm{SF}_{f,A,b}$ in $\mathrm{Comp}(\mathcal{C})$, and Theorem 5.8 — whose fuel hypothesis $K_f(y) \le b(|y|)$ is exactly honesty — shows it is a shortest-program finder for $f$. $\square$

**Theorem 6.6 (One-way functions $\iff$ hardness of compression search).** For every search-closed class $\mathcal{C}$,
$$\exists f \text{ one-way in } \mathcal{C} \iff \exists D \text{ with compression search hard for } \mathcal{C}.$$

*Proof sketch.* ($\Rightarrow$) A one-way $f$ is itself an honest member of the class, and by Proposition 5.3 a shortest-program finder for $f$ would invert it; hence none exists. ($\Leftarrow$) Contrapositive: if no one-way function exists, then every honest member of the class is invertible in the class, so by Theorem 6.5 every honest member admits a shortest-program finder — contradicting hardness for the witness $D$. $\square$

### 6.1 Robustness I: approximation

**Definition 6.7.** $A$ is a *$\delta$-approximate* shortest-program finder for $D$ if for every describable $y$: $D(A(y)) = y$ and $|A(y)| \le K_D(y) + \delta(|y|)$.

**Theorem 6.8 (Approximation does not help).** For every search-closed class $\mathcal{C}$ and *every* slack function $\delta$, statement (1) of Theorem 6.5 is equivalent to: every honest $D \in \mathrm{Comp}(\mathcal{C})$ admits a $\delta$-approximate shortest-program finder in $\mathrm{Comp}(\mathcal{C})$. Consequently one-way functions exist for $\mathcal{C}$ iff *approximate* compression search is hard for $\mathcal{C}$.

*Proof sketch.* An exact finder is trivially $\delta$-approximate, giving one direction from Theorem 6.5. Conversely, an approximate finder still satisfies $D(A(y)) = y$, hence inverts $D$; so approximate solvability for all honest members implies invertibility for all honest members, and Theorem 6.5 closes the loop. $\square$

This is a strong statement: the equivalence is insensitive to the accuracy demanded. Even a compressor allowed to overshoot the optimum by a huge margin, as long as it always outputs a *valid* program, is as powerful as an inverter of one-way functions.

### 6.2 Robustness II: decision versus search

**Definition 6.9 (Prefix-compressibility oracle).** A predicate $\mathrm{dec}(y, w, n)$ is a *correct prefix oracle* for $D$ if
$$\mathrm{dec}(y,w,n) = \text{true} \iff \exists p,\ |p| = n \ \wedge\ D(w \frown p) = y.$$

**Definition 6.10 (Bit-by-bit reconstruction).** Define $\mathrm{rebuild}$ by $\mathrm{rebuild}(0,w) = w$ and
$$\mathrm{rebuild}(n+1, w) \;=\; \begin{cases}\mathrm{rebuild}(n,\, w\frown\texttt{0}) & \text{if } \mathrm{dec}(y,\, w\frown\texttt{0},\, n),\\ \mathrm{rebuild}(n,\, w\frown\texttt{1}) & \text{otherwise.}\end{cases}$$

**Lemma 6.11 (Correctness of reconstruction).** If $\mathrm{dec}$ is a correct prefix oracle for $D$ and some length-$n$ continuation of $w$ is a $D$-program for $y$, then $D(\mathrm{rebuild}(n,w)) = y$ and $|\mathrm{rebuild}(n,w)| = |w| + n$.

*Proof sketch.* Induction on $n$. For $n = 0$ the continuation is empty and $w$ itself works. For $n+1$: write a surviving continuation as $b \frown t$ with $|t| = n$. If the oracle accepts $w\frown\texttt{0}$, the induction hypothesis applies to $w\frown\texttt{0}$; otherwise the $\texttt{0}$-branch is provably dead, so $b$ must be $\texttt{1}$ and the induction hypothesis applies to $w\frown\texttt{1}$ with the continuation $t$. Lengths add by construction. $\square$

**Definition 6.12.** The *decision-based finder* is
$$\mathrm{DF}_{\mathrm{dec},F}(y) \;=\; \mathrm{rebuild}\bigl(\mathrm{least}(n \mapsto \mathrm{dec}(y,\varepsilon,n),\, F(|y|)),\; \varepsilon\bigr).$$

**Theorem 6.13 (Search to decision).** If $\mathrm{dec}$ is a correct prefix oracle for $D$ and $K_D(y) \le F(|y|)$ for every describable $y$, then $\mathrm{DF}_{\mathrm{dec},F}$ is a shortest-program finder for $D$, and in particular inverts $D$.

*Proof sketch.* By correctness of the oracle at the empty prefix, $\mathrm{dec}(y,\varepsilon,n)$ holds iff $y$ has a $D$-program of length exactly $n$. The bounded search therefore returns $n^\star = K_D(y)$ (the least such $n$, which exists within the fuel by hypothesis), and Lemma 6.11 with $w = \varepsilon$ shows the reconstructed string is a $D$-program for $y$ of length exactly $n^\star$. $\square$

**Theorem 6.14 (No prefix oracle under one-wayness).** If $f$ is one-way in $\mathcal{C}$, $\mathrm{dec}$ is a correct prefix oracle for $f$ with an allowed fuel $F$ covering $K_f$, then $\mathrm{DF}_{\mathrm{dec},F} \notin \mathrm{Comp}(\mathcal{C})$.

*Proof.* Otherwise Theorem 6.13 makes it an inverter for $f$ inside the class, contradicting one-wayness. $\square$

**Corollary 6.15 (The tasks coincide).** For any decompressor $D$: an exact shortest-program finder, a $\delta$-approximate finder, and a correct prefix oracle each yield an inverter for $D$; and inside a search-closed class, invertibility of all honest members yields all three back. The four tasks therefore sit at the same cryptographic level.

**Remark 6.16 (Why *prefix* decision).** The reduction of Theorem 6.13 consumes *conditional* information: it asks about continuations of a prefix $w$. An *unconditional* length oracle — one that returns the number $K_D(y)$ but no structural information — does not obviously suffice, and we were unable to convert it into an inverter without additional closure assumptions. This gap is genuine and is recorded as a conjecture in §9.

---

## 7. Consequences for achievable worst-case bounds

**Theorem 7.1 (Description gap).** Let $f$ be one-way in $\mathcal{C}$. Then there is an allowed bound $b$ such that for *every* $A \in \mathrm{Comp}(\mathcal{C})$ there exists a string $y$ with:
$y$ is describable under $f$; $K_f(y) \le b(|y|)$; and $f(A(y)) \ne y$.

*Proof sketch.* Honesty supplies $b$. Since $A$ does not invert $f$, negating the universally quantified inversion condition yields a describable $y$ with $f(A(y)) \ne y$; honesty bounds its complexity. $\square$

The content is the contrast between the two clauses: a short description of $y$ *exists* (second clause) and $A$ *fails to produce one* (third clause). The obstruction is not information; it is search.

**Theorem 7.2 (Universality does not close the gap).** Let $f$ be one-way in $\mathcal{C}$ and suppose $f = D_i$ for a family $D$ with universal decompressor $U_D$. Then there is an allowed bound $b$ such that for every $A \in \mathrm{Comp}(\mathcal{C})$ there is a $y$ describable under $f$ with $K_{U_D}(y) \le b(|y|) + i + 1$ and $f(A(y)) \ne y$.

*Proof sketch.* Apply Theorem 7.1 and then the invariance theorem 4.10 to transfer the complexity bound to the universal system, at additive cost $i+1$. $\square$

So even measured in a single universal description language — the "best possible" format, optimal up to additive constants — the missed strings still have short descriptions.

### 7.1 The failures are infinite, not finite

A natural objection to Theorem 7.1: an algorithm failing on finitely many inputs can be repaired with a lookup table, so a single failure may be an artefact of the model. The objection collapses as soon as the collection of algorithms is closed under exactly that repair.

**Definition 7.3 (Patch closure).** A set $\mathcal{A}$ of algorithms is *patch-closed* if for every $A \in \mathcal{A}$, every finite set $F$ of inputs and every function $g$, the patched algorithm
$$y \mapsto \begin{cases} g(y) & y \in F\\ A(y) & y \notin F\end{cases}$$
again lies in $\mathcal{A}$. (This is closure under finite advice, i.e. a lookup table.)

**Theorem 7.4 (Infinite failure of inversion).** Let $\mathcal{A}$ be patch-closed and suppose no $A \in \mathcal{A}$ inverts $f$. Then for every $A \in \mathcal{A}$ the failure set
$$\{\, y : y \text{ describable under } f \ \wedge\ f(A(y)) \ne y \,\}$$
is infinite.

*Proof sketch.* Suppose it were finite, say equal to $F$. For each $y$ choose (classically) some $g(y)$ that is an $f$-preimage of $y$ whenever $y$ is describable. Patch $A$ with $g$ on $F$: by patch closure the result $A'$ lies in $\mathcal{A}$. For $y \in F$, $A'$ returns $g(y)$, a correct preimage; for $y \notin F$, $y$ is not a failure point of $A$, so $A$ — and hence $A'$ — already succeeds. Thus $A'$ inverts $f$, contradicting hardness. $\square$

**Theorem 7.5 (Infinite failure of compression).** Under the same hypotheses, for every $A \in \mathcal{A}$ the set
$$\{\, y : y \text{ describable under } f \ \wedge\ \neg( f(A(y)) = y \ \wedge\ |A(y)| = K_f(y)) \,\}$$
is infinite: every candidate compressor fails to output a shortest program on infinitely many inputs, each of which nevertheless *has* a description.

*Proof.* The set of Theorem 7.4 is contained in it, and supersets of infinite sets are infinite. $\square$

### 7.2 The hypotheses are satisfiable

Theorems 7.4–7.5 would be vacuous if patch-closed collections never contained uninvertible functions. They do.

**Definition 7.6.** Let $\mathcal{T} = \{\, A : \{y : A(y) = \mathrm{tail}(y)\} \text{ is finite}\,\}$, the algorithms agreeing with the "delete the first bit" map only finitely often. Let $\tau(p) = \texttt{1}\frown p$ be the tagging function.

**Proposition 7.7.** (i) $\mathcal{T}$ is patch-closed. (ii) $\tau \in \mathcal{T}$. (iii) No $A \in \mathcal{T}$ inverts $\tau$. Consequently, by Theorem 7.4, every $A \in \mathcal{T}$ fails to invert $\tau$ on infinitely many inputs.

*Proof sketch.* (i) The agreement set of a patched algorithm is contained in the union of the original agreement set and the (finite) patch domain, hence finite. (ii) $\tau(y)$ has length $|y|+1$ while $\mathrm{tail}(y)$ has length $|y|-1$, so the agreement set is empty. (iii) If $A$ inverted $\tau$, then for every $p$, $A(\texttt{1}\frown p)$ would have to equal $p = \mathrm{tail}(\texttt{1}\frown p)$; the map $p \mapsto \texttt{1}\frown p$ is injective, so the agreement set of $A$ would be infinite, contradicting $A \in \mathcal{T}$. $\square$

**Remark 7.8 (A tension worth recording).** Patch closure and the strong search-closure axiom (S) pull in opposite directions: (S) forces the class to control output lengths uniformly in the guard parameter, whereas finite patching destroys any uniform length control. Whether a single class can satisfy both *and* contain a one-way function is open (§9, Conjecture 3').

### 7.3 A non-vacuity witness for the class-level theory

The class axioms of Definition 6.1 are also satisfiable in both regimes.

* **The full class** (all functions, all bounds allowed) satisfies (F1)–(F3), (G), (S); it has no one-way function (every function has a set-theoretic inverse), and correspondingly compression search is easy for it — consistent with Theorem 6.6.
* **The length class** $\mathrm{Comp} = \{g : |p| \le |g(p)| \text{ for all } p\}$ with all bounds allowed is search-closed: guarding either prepends a bit to $f(p)$ (preserving the inequality) or echoes $p$ with a tag, and the assembled search algorithm inherits the inequality from its subroutines because its input is $\texttt{1}\frown y$. The tagging function $\tau(p) = \texttt{1}\frown p$ is *one-way in the length class*: it lies in the class and is honest, but an inverter would have to map $[\texttt{1}]$ to $\varepsilon$, shortening its input, which the class forbids. Hence by Theorem 6.6 the compression-search problem is hard for the length class.

The "hardness" in the second example is of course resource-theoretic rather than cryptographic, but that is precisely the point of a resource-abstract axiomatization: the *reduction* is valid in every setting satisfying the axioms, and the axioms are consistent with genuine hardness.

---

## 8. The calibration theorem

Everything above assembles into a single statement, the deliverable of the programme.

**Theorem 8.1 (Calibration).** Let $\mathcal{C}$ be a search-closed class admitting a one-way function, and let $s, k \in \mathbb{N}$. Then all of the following hold simultaneously.

1. **(Information-theoretic ceiling.)** For every decompressor $D$ and every finite $T$ all of whose members have $D$-complexity $\le s$: $|T| \le 2^{s+1}-1$.
2. **(Sharpness.)** For every decompressor $D$ there is a string of length $s+1$ not compressible to $s$ bits.
3. **(Randomness.)** Every string of length $k+s$ is compressible to $s$ bits by a seeded family with $2^{k}$ seeds of length $k$ — the gain of $k$ bits is achieved — while no seeded family with seed space $R$ compresses more than $|R|(2^{s+1}-1)$ objects to $s$ bits, and derandomizing costs only $2k+1$ additive bits.
4. **(Computational boundary.)** There is a decompressor of the class for which no algorithm of the class ever outputs shortest programs; equivalently, there are strings with short descriptions that no algorithm of the class produces — infinitely many per algorithm when the collection is patch-closed.

*Proof.* Item 1 is Theorem 3.1, item 2 is Theorem 3.2, item 3 combines Theorems 4.5 and 4.8, and item 4 is Theorem 6.6 applied to the assumed one-way function, together with Theorems 7.1 and 7.5. $\square$

In words: **randomness helps compression exactly up to the seed length, and no further; efficient compression then stops again at the cryptographic hardness boundary, and stops there whether one demands exact optimality, approximate optimality within any slack, or a mere yes/no decision.**

---

## 9. Discussion and future directions

### 9.1 What the failures taught us

Two attempted strengthenings did not go through, and both shaped the picture.

*Unconditional length estimation.* An oracle returning the *number* $K_D(y)$, with no program and no conditional structure, could not be converted into an inverter without an extra closure axiom. The reduction of §6.2 genuinely uses the *prefix* predicate — the conditional question "does this partial program extend to a solution?" — which is strictly more informative.

*Honesty.* The class-level equivalence needs honesty. Without it, the bounded search of Definition 5.7 may run out of fuel before reaching $K_f(y)$, and a function can be one-way for the trivial reason that its preimages are astronomically longer than its outputs. Honesty is thus not a technical convenience but the hypothesis that makes the fuel sufficient.

### 9.2 Open problems

**Conjecture 1 (Unconditional estimation gap).** There is a search-closed class $\mathcal{C}$ and a decompressor $D$ in it such that the unconditional length-estimation task — output the number $K_D(y)$ — is solvable in $\mathcal{C}$, while no algorithm of $\mathcal{C}$ is a shortest-program finder for $D$. The key insight is that the reduction consumes *conditional* information, so a separating class should be closed under guarding and bounded search but **not** under prefix restriction $D \mapsto (p \mapsto D(w\frown p))$. Both sides of the separation are already formulated; the conjecture reduces to constructing one explicit class and verifying three closure axioms.

**Conjecture 2 (Honesty is necessary, not cosmetic).** There is a search-closed class $\mathcal{C}$ and a non-honest $f$ in it that is not invertible in $\mathcal{C}$, while every honest decompressor of $\mathcal{C}$ admits a shortest-program finder in $\mathcal{C}$. Honesty is exactly the hypothesis that makes the search fuel sufficient, so violating it should decouple the two sides of the main equivalence, making it sharp rather than an artefact of the formulation. The length-class technique — defining a class by a length inequality — plausibly yields a non-honest witness.

**Conjecture 3 (Quantitative gap theorem) — partially resolved.** For every search-closed class with a one-way $f$ and every algorithm $A$ of the class, the failure set is infinite; moreover, beyond some threshold, each length interval should contain a failure. Theorem 7.4 establishes the infinitude under patch closure; what remains is the *uniform per-length* version, and the reconciliation of patch closure with the search axiom noted in Remark 7.8.

**Conjecture 3' (Compatibility).** There is a single collection of algorithms that is simultaneously search-closed and patch-closed and contains a one-way function. The tension is real: search closure demands uniform control of output lengths in the guard parameter, and finite patching destroys it. A positive resolution would merge Theorems 6.6 and 7.5 into one statement about efficient compressors.

**Further directions.**
* *Average-case calibration.* All statements here are worst-case. The natural next step is a distributional version: for a samplable distribution, how much of the mass is compressible, and does the equivalence with inversion survive when both tasks are required only with high probability?
* *Seeds that are not free.* Theorem 4.8 charges $2k+1$ bits for a $k$-bit seed. Charging seeds fractionally (amortized over many inputs) should interpolate between Theorems 4.2 and 4.8 and connect to pseudorandom generators: a one-way function yields a generator, which manufactures cheap seeds, which by the seed-budget theorem cannot help beyond their true entropy — a satisfying closed loop worth making precise.
* *Refining the guard.* The guard $f_l$ tags accepted outputs with a single bit. A multi-bit guard encoding the length itself would give a one-shot reduction with no search, at the price of a stronger closure axiom; identifying the weakest closure that supports a search-free reduction would sharpen Definition 6.1.

### 9.3 Interpretation

The programme began with a practical-sounding question: can randomness push compression beyond the counting bound? The answer is now fully quantified. Randomness buys exactly its own length in bits — the seed is a description, moved off the ledger, and Theorem 4.8 moves it back on at almost no loss. Beyond that, the only remaining obstacle to compressing an object with a short description is the difficulty of *searching* for that description, and that difficulty is not an independent phenomenon: it is precisely the assumption on which modern cryptography rests. Files stay large for the same reason keys stay secret.

---

## Appendix: algorithmic summary

For reference, the three algorithms driving the reductions.

**A1. Guarded-search compressor** (Definition 5.7). *Input:* $y$; access to inverters $A_l$ for $f_l$; fuel $F$. For $l = 0, 1, \dots, F(|y|)$: compute $p \leftarrow A_l(\texttt{1}\frown y)$; if $f_l(p) = \texttt{1}\frown y$, output $p$ and stop. Correct by Theorem 5.8; makes at most $K_f(y)+1$ subroutine calls when $y$ is describable within the fuel.

**A2. Prefix-oracle reconstruction** (Definitions 6.10, 6.12). *Input:* $y$; oracle $\mathrm{dec}$; fuel $F$. First $n^\star \leftarrow$ least $n \le F(|y|)$ with $\mathrm{dec}(y,\varepsilon,n)$. Then $w \leftarrow \varepsilon$; repeat $n^\star$ times: if $\mathrm{dec}(y, w\frown\texttt{0}, \text{remaining}-1)$ then $w \leftarrow w\frown\texttt{0}$ else $w \leftarrow w\frown\texttt{1}$. Output $w$. Uses $n^\star + O(F(|y|))$ oracle calls, i.e. one call per output bit plus the length search; correct by Lemma 6.11 and Theorem 6.13.

**A3. Seed packaging** (Definitions 4.6, 4.7). To derandomize a seeded family: given seed $r$ and program $p$, emit $|r|$ in unary, a separating $\texttt{0}$, then $r \frown p$; the deterministic decompressor parses this and calls $D_r(p)$. Overhead $2|r|+1$ bits; correct by Theorem 4.8.
