# Pseudo-Random Generators Cannot Beat the Pigeonhole Bound

**A quantitative negative result, with a tight converse**

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We settle, in a fully quantitative form, the recurring proposal that a pseudo-random number generator (PRNG) can be used to compress arbitrary data by "finding the seed whose output is the file". A PRNG is a deterministic function from seeds to streams; functions do not create information. We formalize this into a family of theorems that close every natural strengthening of the proposal, and we complement them with a sharp converse that isolates exactly what a generator *can* do.

Concretely, we prove: (i) a generator with an $s$-bit seed whose outputs cover all of $\{0,1\}^n$ requires $s \ge n$, and if $s < n$ then a positive-density set of strings is unreachable; (ii) the same conclusion holds when the decoder may additionally read an arbitrary side program, when generators are composed, and when a library of $2^m$ generators may be searched — the library buys exactly $m$ bits; (iii) in the strongest form, for any library of $2^m$ decompressors there is a *single* string simultaneously hard for all of them; (iv) the failure is quantitative — for any decompressor, at most a $2^{1-d}$ fraction of $n$-bit strings admit descriptions of length $\le n-d$, and the average description length over uniform inputs is at least $(n-k)(1-2^{-k})$ for every $k$, hence $n - O(\log n)$; (v) the bound is tight: any set of at most $2^k$ strings admits an injective $k$-bit code, so the $\le 2^s$ outputs of a generator compress to $s$ bits and nothing else is helped.

We also exhibit a fully specified hybrid compressor built on a generator, which simultaneously (a) compresses every generator output to $s+1$ bits, (b) never expands any input beyond $n+1$ bits, (c) still leaves a string requiring $n$ bits whenever $s+1 < n$, and (d) helps at most a $2^{s+2-n}$ fraction of inputs. A concrete 4-bit-seed linear congruential generator producing 8-bit outputs reaches exactly $16$ of the $256$ possible values, leaving $240$ unreachable.

**Keywords:** pseudo-random number generator, Kolmogorov complexity, incompressibility, pigeonhole principle, lossless compression, no free lunch, invariance theorem, seed search.

---

## 1. Introduction

### 1.1 The proposal

A pseudo-random number generator expands a short seed into a long stream of bits that passes statistical tests for randomness. Since an arbitrary file is also a long string of bits, a natural proposal recurs with remarkable persistence:

> Compress a file $x$ by searching for a seed $\sigma$ such that $G(\sigma) = x$, and store $\sigma$.

At $64$ bits of seed and gigabytes of output, the implied compression ratio is astronomical. The proposal is not stupid: it is exactly how one *does* compress a file that was produced by a generator, and it is the operating principle of stream ciphers and of reproducible simulation. The question is whether it extends to arbitrary data.

It does not, and the reason is elementary. Our contribution is not the elementary observation but its systematic quantitative development: we close each of the plausible refinements of the proposal, prove a matching converse, and instantiate the result in a concrete, checkable compressor.

### 1.2 Why the elementary observation needs a careful treatment

Three refinements make the naive counting argument insufficient on its face.

1. **Side information.** Store a seed *plus* a short correction. The naive count of generator outputs says nothing about what happens when the decoder reads more than the seed.
2. **Generator libraries.** Keep $2^m$ generators and, per file, use whichever fits. Each individual generator has hard files; a priori the hard files could differ between generators, so that every file is easy for *someone*.
3. **Average case.** Worst-case incompressibility is compatible, a priori, with excellent average performance.

Each requires a genuine argument. Refinement 2 in particular requires the invariance theorem and a universal machine construction; the conclusion we prove (a single string hard for the whole library) is strictly stronger than the pointwise statement.

### 1.3 Contributions and organization

Section 2 fixes definitions and develops the counting core from first principles, including the self-delimiting numeric index that makes the counting exact. Section 3 treats the pure generator. Section 4 handles side information, composition, and libraries. Section 5 introduces description complexity relative to an arbitrary decompressor, proves incompressibility and its quantitative form, and establishes the invariance theorem and uniform hardness. Section 6 gives the real-valued rate statements. Section 7 proves tightness and the dichotomy. Section 8 presents the concrete hybrid compressor and the linear congruential example. Section 9 gives algorithms, Section 10 discusses applications and limitations, Section 11 lists open directions.

---

## 2. Preliminaries: the counting core

### 2.1 Objects

Throughout, $n$ and $s$ denote non-negative integers.

**Definition 2.1 (Files).** $\{0,1\}^n$ denotes the set of $n$-bit strings, formally the functions $\{0,\dots,n-1\} \to \{0,1\}$. It has exactly $2^n$ elements.

**Definition 2.2 (Programs).** A *program* (equivalently: codeword, compressed file) is a finite bit string; the set of all programs is $\{0,1\}^*$, and $|p|$ denotes the length of $p$.

**Definition 2.3 (Decompressor).** A *decompressor* for $\{0,1\}^n$ is any function $D : \{0,1\}^* \to \{0,1\}^n$. It is *complete* if it is surjective, i.e. every file has at least one program.

We impose **no** computability, efficiency, or structural restriction on $D$. This is essential: a bound proved for arbitrary $D$ automatically applies to every present and future compression scheme, including generator-based ones.

**Definition 2.4 (Code).** A *code* is a function $c : \{0,1\}^n \to \{0,1\}^*$. It is *lossless* precisely when it is injective, since a decoder must recover the input from the codeword.

**Definition 2.5 (Generator).** A *generator* with $s$-bit seeds and $n$-bit outputs is a function $G : \{0,1\}^s \to \{0,1\}^n$. Determinism is built into the word "function"; this is the only property of a PRNG we ever use.

### 2.2 A self-delimiting numeric index

The counting lemma below requires knowing how many programs of length at most $k$ there are. The clean way to obtain this is an explicit injection into an interval of integers.

**Definition 2.6.** Define $\nu : \{0,1\}^* \to \mathbb{N}$ by
$$\nu(\varepsilon) = 1, \qquad \nu(b \cdot p) = 2\,\nu(p) + [b = 1].$$
Equivalently, $\nu(p)$ is the value of the binary numeral obtained by prepending a $1$ to $p$ (read in the appropriate bit order).

**Lemma 2.7.** For every $p$: (i) $\nu(p) \ge 1$; (ii) $\nu(p) < 2^{|p|+1}$; (iii) $\nu$ is injective.

*Proof sketch.* (i) and (ii) are immediate inductions on $p$: the empty string gives $1 < 2$, and the recursion at most doubles and adds one, matching the doubling of the bound. (iii) is an induction using the fact that the parity of $\nu(b \cdot p)$ determines $b$ and the quotient by $2$ determines $\nu(p)$; the base case uses $\nu(\varepsilon) = 1$ while $\nu(b \cdot p) = 2\nu(p) + [b=1] \ge 2$ since $\nu(p) \ge 1$. $\square$

The prepended $1$ is what makes the encoding self-delimiting: without it, $0$, $00$, $000$ would collide.

### 2.3 The counting lemma and the pigeonhole bound

**Theorem 2.8 (Counting Lemma).** *Let $X$ be a finite set and $c : X \to \{0,1\}^*$ injective. For every $k$,*
$$\#\{x \in X : |c(x)| \le k\} \;\le\; 2^{k+1} - 1 .$$

*Proof sketch.* The composite $x \mapsto \nu(c(x))$ is injective on the set in question (injectivity of $\nu$ composed with injectivity of $c$), and by Lemma 2.7 it maps into the integer interval $[1, 2^{k+1}-1]$, since $|c(x)| \le k$ implies $\nu(c(x)) < 2^{|c(x)|+1} \le 2^{k+1}$. An injection into a finite set bounds cardinality. $\square$

**Theorem 2.9 (Pigeonhole Bound).** *For every injective $c : \{0,1\}^n \to \{0,1\}^*$ there exists $x$ with $|c(x)| \ge n$.*

*Proof sketch.* For $n = 0$ the claim is trivial. Otherwise suppose $|c(x)| \le n-1$ for all $x$. Then the set of Theorem 2.8 with $k = n-1$ is all of $\{0,1\}^n$, giving $2^n \le 2^n - 1$, a contradiction. $\square$

**Theorem 2.10 (Quantitative Pigeonhole).** *For every injective $c : \{0,1\}^n \to \{0,1\}^*$ and every $d \ge 0$,*
$$2^d \cdot \#\{x : |c(x)| + d \le n\} \;\le\; 2^{n+1}.$$
*Equivalently, the fraction of files compressed by $d$ bits or more is at most $2^{1-d}$.*

*Proof sketch.* If $d > n$ the set is empty. Otherwise $\{x : |c(x)|+d \le n\} \subseteq \{x : |c(x)| \le n-d\}$, whose cardinality is at most $2^{n-d+1}-1$ by Theorem 2.8; multiplying by $2^d$ gives at most $2^{n+1} - 2^d \le 2^{n+1}$. $\square$

The multiplicative form is stated deliberately: it avoids truncated subtraction and remains meaningful when $d > n$.

---

## 3. The pure generator

We first dispose of the naive proposal, in which the compressed file *is* the seed.

**Theorem 3.1 (A generator creates no entropy).** *Let $G : \{0,1\}^s \to \{0,1\}^n$ be surjective. Then $n \le s$.*

*Proof sketch.* A surjection from a finite set onto another forces $\#\{0,1\}^n \le \#\{0,1\}^s$, i.e. $2^n \le 2^s$; monotonicity of $t \mapsto 2^t$ gives $n \le s$. $\square$

**Theorem 3.2 (Range bound).** *For any $G : \{0,1\}^s \to \{0,1\}^n$, the image of $G$ has at most $2^s$ elements.*

**Theorem 3.3 (Unreachable strings).** *If $s < n$ then there exists $x \in \{0,1\}^n$ with $G(\sigma) \ne x$ for every seed $\sigma$.*

*Proof sketch.* Otherwise $G$ is surjective, and Theorem 3.1 gives $n \le s$, contradicting $s < n$. $\square$

**Theorem 3.4 (Output density).** *If $s \le n$ then*
$$2^{\,n-s} \cdot \#\,\mathrm{image}(G) \;\le\; 2^n,$$
*i.e. the reachable set occupies at most a $2^{s-n}$ fraction of $\{0,1\}^n$.*

*Proof sketch.* Combine Theorem 3.2 with $2^{n-s} \cdot 2^s = 2^n$. $\square$

Theorem 3.4 is the operationally meaningful statement. With a $64$-bit seed and a one-gigabyte target, the reachable fraction is $2^{64 - 8\cdot 10^9}$: the search for "the seed that contains my file" is not a hard search but a search whose target almost surely does not exist.

---

## 4. Side information, composition, and libraries

### 4.1 Seed plus arbitrary side program

The first refinement: store a seed together with a correction.

**Theorem 4.1 (No gain from seed plus side information).** *Let $D : \{0,1\}^s \times \{0,1\}^* \to \{0,1\}^n$ be an arbitrary decoder taking a seed and an arbitrary side program, and let $\mathrm{enc} : \{0,1\}^n \to \{0,1\}^s \times \{0,1\}^*$ be any encoder with*
$$D\big(\mathrm{enc}(x)\big) = x \quad \text{for all } x.$$
*Then there exists $x$ with*
$$s + |\mathrm{enc}(x)_2| \;\ge\; n .$$

*Proof sketch.* Write the seed out as an $s$-bit string and concatenate the side program: $c(x) = \mathrm{seedbits}(\mathrm{enc}(x)_1) \,\|\, \mathrm{enc}(x)_2$. Since the seed part has *fixed* length $s$, two equal concatenations split identically, so equal codewords force equal seeds and equal side programs, hence equal decoded values, hence $c$ is injective. Theorem 2.9 supplies $x$ with $|c(x)| \ge n$, and $|c(x)| = s + |\mathrm{enc}(x)_2|$. $\square$

The theorem places no constraint at all on how the decoder uses the seed: it may run any generator for any number of steps, may run a different generator depending on the side program, may ignore the seed entirely. Only the *fixed length* of the seed field is used.

### 4.2 Composition

**Theorem 4.2 (Chaining does not help).** *If $G_1 : \{0,1\}^s \to \{0,1\}^t$ and $G_2 : \{0,1\}^t \to \{0,1\}^n$ are such that $G_2 \circ G_1$ is surjective, then $n \le s$ — irrespective of the intermediate width $t$.*

*Proof sketch.* $G_2 \circ G_1$ is itself a generator with $s$-bit seeds; apply Theorem 3.1. $\square$

The intermediate state space may be enormous; the bottleneck is the entrance.

### 4.3 A library of generators

**Theorem 4.3 (A library buys only its index).** *Let $F : \{0,1\}^m \times \{0,1\}^s \to \{0,1\}^n$ be a family of $2^m$ generators with $s$-bit seeds, and suppose that for every file $x$ there exist an index $i$ and a seed $\sigma$ with $F(i,\sigma) = x$. Then $n \le m + s$.*

*Proof sketch.* The map $(i,\sigma) \mapsto F(i,\sigma)$ is a surjection from a set of size $2^{m+s}$ onto a set of size $2^n$. $\square$

Selecting a generator is information, and it costs exactly the bits needed to name the selection.

---

## 5. Description complexity relative to a decompressor

### 5.1 Definition and basic properties

**Definition 5.1.** For a decompressor $D : \{0,1\}^* \to X$ and $x \in X$, the *description complexity* of $x$ relative to $D$ is
$$K_D(x) \;=\; \min\{\,|p| : D(p) = x\,\},$$
the minimum of the (possibly empty) set of lengths of programs producing $x$.

**Lemma 5.2.** If $D(p) = x$ then $K_D(x) \le |p|$.

**Lemma 5.3 (Shortest programs exist).** If $x$ has at least one program under $D$, then there is a program $p$ with $|p| = K_D(x)$ and $D(p) = x$.

*Proof sketch.* The set of achievable lengths is a nonempty set of non-negative integers, so it contains its infimum. $\square$

**Theorem 5.4 (Data processing).** *For any $D : \{0,1\}^* \to X$, any $f : X \to Y$, and any $x$ having a program under $D$,*
$$K_{f \circ D}(f(x)) \;\le\; K_D(x).$$

*Proof sketch.* A shortest $D$-program for $x$ is a $(f \circ D)$-program for $f(x)$. $\square$

Theorem 5.4 is the precise sense in which "running a generator on the output of a decoder never increases complexity". It is worth pausing on why this is *not* a route to compression: post-processing can only lower complexities, but the counting theorems below never inspect the decompressor. They bound how many strings can have short descriptions *for any decompressor whatsoever*, so lowering some complexities necessarily raises others.

### 5.2 Incompressibility

**Lemma 5.5 (Shortest-program code).** *If $D$ is complete, there is an injective code $c$ on $\{0,1\}^n$ with $|c(x)| = K_D(x)$ and $D(c(x)) = x$ for every $x$.*

*Proof sketch.* Choose, for each $x$, a shortest program $c(x)$ (Lemma 5.3, using completeness). If $c(x) = c(y)$ then $x = D(c(x)) = D(c(y)) = y$. $\square$

**Theorem 5.6 (Incompressibility).** *For every complete decompressor $D$ on $\{0,1\}^n$ there is a file $x$ with $K_D(x) \ge n$.*

*Proof sketch.* Apply the Pigeonhole Bound (Theorem 2.9) to the code of Lemma 5.5. $\square$

**Theorem 5.7 (Quantitative incompressibility).** *For every complete $D$ on $\{0,1\}^n$ and every $d$,*
$$2^d \cdot \#\{x : K_D(x) + d \le n\} \;\le\; 2^{n+1}.$$

*Proof sketch.* Apply Theorem 2.10 to the code of Lemma 5.5, whose lengths are exactly the complexities. $\square$

### 5.3 Invariance and uniform hardness against a library

The library refinement (Section 4.3) admits a much sharper treatment at the level of description complexity.

**Theorem 5.8 (Invariance).** *Let $D, D' : \{0,1\}^* \to X$ and $q \in \{0,1\}^*$ satisfy $D(q \,\|\, p) = D'(p)$ for all $p$. Then for every $x$ having a $D'$-program,*
$$K_D(x) \;\le\; |q| + K_{D'}(x).$$

*Proof sketch.* Prefix $q$ to a shortest $D'$-program. $\square$

**Definition 5.9 (Universal machine for a finite family).** Given $F : \{0,1\}^m \to (\{0,1\}^* \to \{0,1\}^n)$, define
$$U_F(p) \;=\; F\big(\text{first } m \text{ bits of } p\big)\big(\text{remaining bits of } p\big).$$

**Lemma 5.10.** $U_F(\mathrm{indexbits}(i) \,\|\, p) = F(i)(p)$ for every index $i$ and program $p$; consequently $U_F$ is complete as soon as some member is, and
$$K_{U_F}(x) \;\le\; m + K_{F(i)}(x) \quad \text{for every } i \text{ and every } x \text{ decodable by } F(i).$$

*Proof sketch.* The prefix has fixed length $m$, so taking and dropping $m$ bits recovers the two parts exactly; the complexity bound is Theorem 5.8 with $q = \mathrm{indexbits}(i)$. $\square$

**Theorem 5.11 (Uniform hardness against a whole library).** *Let $F$ be a family of $2^m$ complete decompressors on $\{0,1\}^n$. Then there exists a single file $x$ such that*
$$n \;\le\; m + K_{F(i)}(x) \qquad \text{for every } i .$$

*Proof sketch.* $U_F$ is complete, so Theorem 5.6 yields $x$ with $K_{U_F}(x) \ge n$. For each $i$, Lemma 5.10 gives $n \le K_{U_F}(x) \le m + K_{F(i)}(x)$. $\square$

This is strictly stronger than "each member has some hard file": the hardness is concentrated in one file, uniformly over the library. Note also that the quantifier order is what kills exhaustive search over compressors — one cannot escape by adapting the scheme to the input, because the adaptation is itself describable in $m$ bits.

**Theorem 5.12 (Library-easy strings are rare).** *With $F$ as above and $m + s + 1 \le n$,*
$$2^{\,n-(m+s)} \cdot \#\{x : \exists i,\; K_{F(i)}(x) \le s\} \;\le\; 2^{n+1}.$$
*That is, the strings compressible to $s$ bits by* some *member of the library number at most $2^{m+s+1}$, a $2^{m+s+1-n}$ fraction of all files.*

*Proof sketch.* If $K_{F(i)}(x) \le s$ for some $i$ then $K_{U_F}(x) \le m+s$ by Lemma 5.10, so the set in question is contained in $\{x : K_{U_F}(x) + (n-(m+s)) \le n\}$; apply Theorem 5.7 to $U_F$. $\square$

---

## 6. Rates: fractions of files and average bits per file

The results so far are exact cardinality statements. Transported to the reals, they become the statements a practitioner cares about.

**Theorem 6.1 (Fraction of compressible files).** *For every complete decompressor $D$ on $\{0,1\}^n$ and every $d$,*
$$\frac{\#\{x : K_D(x) + d \le n\}}{2^n} \;\le\; \frac{2}{2^d} = 2^{1-d}.$$

*Proof sketch.* Divide the inequality of Theorem 5.7 by $2^{n+d}$ and use $2^{n+1} = 2\cdot 2^n$. $\square$

Numerically: $d = 8$ (one byte saved) permits at most a $1/128$ fraction; $d = 20$ permits at most $2^{-19}$; $d = 8000$ (one kilobyte saved) permits at most $2^{-7999}$.

**Theorem 6.2 (Average codeword length).** *For every injective code $c$ on $\{0,1\}^n$ and every $k$ with $k + 1 \le n$,*
$$\frac{1}{2^n}\sum_{x \in \{0,1\}^n} |c(x)| \;\ge\; (n-k)\left(1 - 2^{-k}\right).$$

*Proof sketch.* Split $\{0,1\}^n$ into $S = \{x : |c(x)| \ge n-k\}$ and its complement $T$. By the Counting Lemma with parameter $n-k-1$, $\#T \le 2^{n-k}-1$, so $\#S \ge 2^n - 2^{n-k}$. Summing only over $S$ and bounding each term below by $n-k$ gives
$$\sum_x |c(x)| \;\ge\; (n-k)\left(2^n - 2^{n-k}\right),$$
and dividing by $2^n$ yields the claim. $\square$

**Corollary 6.3.** Taking $k = \lceil \log_2 n \rceil$ gives average length at least $n - O(\log n)$. No lossless code — generator-based or otherwise — achieves an average rate materially below $n$ bits per file on uniform inputs.

**Theorem 6.4 (Average description complexity).** *The same bound holds with $|c(x)|$ replaced by $K_D(x)$ for any complete decompressor $D$.*

*Proof sketch.* Apply Theorem 6.2 to the shortest-program code of Lemma 5.5, whose lengths equal the complexities. $\square$

---

## 7. Tightness, and exactly what a generator buys

A negative result without a matching converse cannot calibrate anyone. The converse is equally elementary and equally important.

**Definition 7.1.** For $k, v \ge 0$ let $\mathrm{bits}_k(v)$ be the $k$-bit string whose $i$-th entry is the $i$-th binary digit of $v$.

**Lemma 7.2.** $\mathrm{bits}_k$ is injective on $\{0, 1, \ldots, 2^k - 1\}$.

*Proof sketch.* Two numbers below $2^k$ agreeing on all bits below index $k$ agree on all bits, since both have zero bits at every index $\ge k$; hence they are equal. $\square$

**Theorem 7.3 (Small sets compress exactly).** *Let $A \subseteq \{0,1\}^n$ with $\#A \le 2^k$. Then there is a code $c$ with $|c(x)| = k$ for all $x \in A$ and $c$ injective on $A$.*

*Proof sketch.* Enumerate $A$ by a bijection with $\{0,\dots,\#A-1\}$ and let $c(x)$ be the $k$-bit binary expansion of the index of $x$; indices are below $\#A \le 2^k$, so Lemma 7.2 applies. $\square$

Theorems 2.9 and 7.3 together say: $k$ bits describe $2^k$ objects, no more and no fewer. The pigeonhole bound is exactly sharp.

**Corollary 7.4 (What a generator buys).** *For any generator $G$ with $s$-bit seeds, the image of $G$ — a set of at most $2^s$ files by Theorem 3.2 — admits an injective code of length exactly $s$. This is precisely the "compress to the seed" trick, and Theorem 7.3 shows it is optimal on that set.*

**Theorem 7.5 (PRNG Dichotomy).** *Let $G : \{0,1\}^s \to \{0,1\}^n$ with $s + 1 < n$. Then simultaneously:*
1. *the outputs of $G$ admit an injective $s$-bit code; and*
2. *there is a file $x$ with $K_{H}(x) \ge n$ under the best generator-powered compressor $H$ of Section 8, and no seed produces $x$.*

*A generator helps exactly on the (at most $2^s$) files it already generates, and nowhere else.*

The interpretation deserves emphasis. A generator is not a compressor; it is a *decompressor for one particular family of strings*, namely its own outputs. Those strings had low description complexity by construction — they are named by their seeds. Discovering that they compress is not discovering compression; it is rediscovering the definition.

---

## 8. The demonstration: a hybrid compressor, and a hand-checkable generator

### 8.1 The hybrid decompressor

We now give the best possible realization of the seed idea, and prove all four of its properties.

**Definition 8.1 (Hybrid decompressor).** Given $G : \{0,1\}^s \to \{0,1\}^n$, define $H_G : \{0,1\}^* \to \{0,1\}^n$ by
- $H_G(\varepsilon) = 0^n$ (an arbitrary convention for the empty program);
- $H_G(\mathtt{0} \,\|\, q) = G(\text{first } s \text{ bits of } q)$ — *seed mode*;
- $H_G(\mathtt{1} \,\|\, q) = \text{first } n \text{ bits of } q$ — *literal mode*.

(Short programs are padded with zeros, so $H_G$ is total.)

**Theorem 8.2 (Seed mode wins).** *For every seed $\sigma$, $K_{H_G}(G(\sigma)) \le s + 1$.*

*Proof sketch.* The program $\mathtt{0} \,\|\, \mathrm{seedbits}(\sigma)$ has length $s+1$ and decodes to $G(\sigma)$. $\square$

This is a real win, and an unbounded one: whatever $n$ may be, every generator output costs $s+1$ bits.

**Theorem 8.3 (Literal mode is safe).** *$H_G$ is complete, and $K_{H_G}(x) \le n+1$ for every file $x$.*

*Proof sketch.* $\mathtt{1} \,\|\, x$ decodes to $x$. $\square$

So the scheme never expands data by more than the single flag bit — it is a legitimate, deployable compressor.

**Theorem 8.4 (No free lunch).** *If $s + 1 < n$, there is a file $x$ with*
$$K_{H_G}(x) \ge n \quad\text{and}\quad G(\sigma) \ne x \text{ for every seed } \sigma.$$

*Proof sketch.* Theorem 5.6 applied to the complete decompressor $H_G$ gives $x$ with $K_{H_G}(x) \ge n$. If $x$ were $G(\sigma)$ for some $\sigma$, Theorem 8.2 would give $K_{H_G}(x) \le s + 1 < n$, a contradiction. $\square$

Note that the second conclusion is derived, not assumed: incompressibility under $H_G$ *certifies* non-membership in the range of $G$. Hardness and unreachability are the same phenomenon.

**Theorem 8.5 (The win is rare).** *If $s + 1 \le n$,*
$$2^{\,n-(s+1)} \cdot \#\{x : K_{H_G}(x) \le s+1\} \;\le\; 2^{n+1},$$
*so at most a $2^{\,s+2-n}$ fraction of files enjoy the shortcut.*

*Proof sketch.* $\{x : K_{H_G}(x) \le s+1\} \subseteq \{x : K_{H_G}(x) + (n-(s+1)) \le n\}$; apply Theorem 5.7. $\square$

Theorems 8.2–8.5 are the complete accounting. The flag bit costs $1$ bit on every file to save $n - s - 1$ bits on a $2^{s+2-n}$ fraction; the expected change in length is positive, in exact agreement with Theorem 6.2.

### 8.2 A generator you can enumerate by hand

Let $g(x) = 5x + 3 \bmod 16$ (a linear congruential generator on a 4-bit state) and define an 8-bit output from a 4-bit seed by concatenating two successive states:
$$\mathrm{out}(\sigma) \;=\; g(\sigma) \;+\; 16\, g(g(\sigma)).$$

**Proposition 8.6.** $\#\{\mathrm{out}(\sigma) : 0 \le \sigma < 16\} \le 16$, and exhaustive enumeration shows the image has exactly $16$ elements, so **$240$ of the $256$ possible 8-bit values are unreachable**. In particular $0$ is not an output.

*Proof sketch.* The upper bound is the image bound (Theorem 3.2) in concrete form; the exact count is a finite verification over $16$ seeds and $256$ targets. $\square$

**Proposition 8.7.** Conversely every output *is* named by a 4-bit seed, so it compresses to $4$ bits — the positive half, in miniature.

The proportions do not improve with scale; they worsen. A $64$-bit seed and a one-gigabyte target give a reachable fraction of $2^{64-8\times10^9}$.

---

## 9. Algorithms

### 9.1 Exhaustive seed search (and why it fails)

**Input:** target file $x \in \{0,1\}^n$, generator $G$ with $s$-bit seeds.
**Output:** a seed $\sigma$ with $G(\sigma) = x$, or `FAIL`.

```
for sigma in 0 .. 2^s - 1:
    if G(sigma) == x: return sigma
return FAIL
```

Time $\Theta(2^s \cdot n)$. By Theorem 3.4 the algorithm returns `FAIL` for at least a $1 - 2^{s-n}$ fraction of inputs — for realistic parameters, essentially always. This is the algorithm the folklore proposal calls for, and its failure is not an implementation deficiency: the object it seeks does not exist.

### 9.2 The hybrid compressor

**Encode** $x$: if $x = G(\sigma)$ for some seed $\sigma$ (found by §9.1), emit $\mathtt{0} \,\|\, \mathrm{seedbits}(\sigma)$, of length $s+1$; otherwise emit $\mathtt{1} \,\|\, x$, of length $n+1$.
**Decode** $p$: strip the flag; in seed mode run $G$ on the next $s$ bits, in literal mode copy the next $n$ bits.

Encoding time $O(2^s n)$, decoding time $O(n)$ (one generator run). Correctness is exact for all inputs; the length profile is exactly Theorems 8.2–8.5.

### 9.3 Empirical verification of the counting bound

To confirm Theorem 6.1 numerically for small $n$: enumerate all $2^n$ files, compute $K_D$ by exhaustive search over programs in length-increasing order (which terminates because $D$ is complete), and tabulate the histogram of complexities against the bound $2^{1-d}$. Complexity $\Theta(2^{n} \cdot 2^{n+1})$ in the worst case, tractable for $n \le 12$ with memoization: run every program of length $\le n+1$ once, recording the first (hence shortest) program to reach each file, which reduces the cost to $\Theta(2^{n+2})$ decoder invocations.

---

## 10. Discussion

### 10.1 What the results do *not* say

They do not say compression is impossible. Real files are not uniform: text, images, audio, and program binaries occupy a set of vanishing density inside $\{0,1\}^n$, and Theorem 7.3 says precisely that a set of size $2^k$ can be named in $k$ bits. Every practical compressor is a bet that the input lives in a small, describable set. The theorems here forbid only the *universal* version of the claim.

They also do not depend on computational assumptions. No hardness assumption is used, and none could help: the counting argument never inspects the decompressor. Imposing a resource bound can only *remove* strings from the decodable set, never add them, so every bound proved here holds verbatim under any resource restriction.

### 10.2 The unifying principle

Each escape route fails for the same reason, and it is worth naming: **any freedom the encoder has must be communicated to the decoder, and communicating it costs exactly $\log_2$ of the number of choices.** The seed is a choice among $2^s$: cost $s$ bits. The library member is a choice among $2^m$: cost $m$ bits. The patch is a choice among however many patches there are. Compression schemes fail when their designers count the freedom and forget to count its description.

### 10.3 Relation to classical results

Theorem 5.6 is the finite, decompressor-relative form of the classical incompressibility theorem of algorithmic information theory; Theorem 5.8 is the invariance theorem specialized to prefix simulation; Theorem 2.8 is a counting form of Kraft's inequality for the (non-prefix-free) family of all bit strings. The contribution of the present development is to state all of them for a completely arbitrary decompressor with explicit constants, and to derive from them the specific consequences for generator-based schemes, together with a matching converse.

### 10.4 Practical calibration

For anyone evaluating a compression proposal, the results yield a checklist:
- If the proposal claims to shrink *arbitrary* data, it is wrong; Theorem 2.9 applies regardless of mechanism.
- If it claims to shrink most data by $d$ bits, check $d$ against $2^{1-d}$ (Theorem 6.1).
- If it relies on searching a space of schemes, add $\log_2(\text{space size})$ to the output length (Theorems 4.3 and 5.11).
- If it works, it works because the data lies in a small set; ask what that set is and how large it is (Theorem 7.3). That question is always more productive than the search for a magic decompressor.

---

## 11. Future directions

**C1. Resource-bounded seeds.** *Conjecture:* for every polynomial-time generator family $G_n : \{0,1\}^{s(n)} \to \{0,1\}^n$ and every polynomial-time decoder, the number of $n$-bit strings compressible below $n-d$ bits is at most $2^{n-d+1}$; moreover the time-bounded complexity $K^t$ satisfies $K^t(x) \ge K(x)$ with the counting bound holding uniformly in $t$. Hence no complexity assumption ($\mathrm{P} \ne \mathrm{NP}$, one-way functions) can ever be used to beat the pigeonhole bound. The key insight is that the counting argument never inspects the decoder, so it survives verbatim under any resource bound: bounding resources can only remove decodable strings, never add them. The results of Section 5 are already stated for an arbitrary $D$, so specializing $D$ to a step-indexed interpreter is a purely definitional extension.

**C2. Randomized compressors.** *Conjecture:* if an encoder may toss true coins and is only required to decode correctly with probability $1-\delta$ over its own randomness and a uniform input, then some input still needs at least $n - \log_2(1/\delta) - 1$ bits. The key insight is that a randomized scheme is a distribution over deterministic schemes, and a first-moment argument selects one deterministic scheme with the same error, which the counting bound already kills. Theorem 4.1 already handles "best of $2^m$ deterministic schemes"; the missing step is a Markov-type averaging lemma over finite distributions.

**C3. Structured sources: a sharp "generator dividend".** For a source supported on $A \subseteq \{0,1\}^n$ and a generator $G$ with $s$-bit seeds, we conjecture an exact characterization of the optimal expected code length in terms of the entropy of $A$, the entropy of $A \cap \mathrm{image}(G)$, and the flag overhead — quantifying the dividend a generator pays on a *structured* source, where by Theorem 7.5 it pays nothing on a uniform one.

**C4. Approximate and lossy versions.** If the decoder need only produce a string within Hamming distance $r$ of the target, the counting bound weakens by the log-volume of a Hamming ball. Making this exact (a Gilbert–Varshamov-type statement for generator ranges) would quantify how far "the nearest seed output" is from a typical file, and hence how large a patch the seed-plus-patch scheme actually needs — we expect close to $n$ bits, in agreement with Theorem 4.1.

**C5. Multi-file amortization.** Does compressing $N$ files jointly against a shared generator help? The counting argument applied to $\{0,1\}^{Nn}$ says no in the worst case, but a sharp per-file statement including the shared-seed savings would be a useful practical corollary.

---

## 12. Conclusion

A pseudo-random number generator is a function, and a function moves information without creating it. Every attempt to leverage one into a universal compressor founders on a single count: there are not enough short programs. We have made the count exact ($2^{k+1}-1$ strings of length at most $k$), closed the natural escapes (side information, composition, libraries, average case), strengthened the library case to a single string hard for all $2^m$ members at once, quantified the failure (at most $2^{1-d}$ of files shrink by $d$ bits; average rate $n - O(\log n)$), and proved the matching converse ($2^k$ objects fit in $k$ bits, exactly).

The resulting picture is a clean dichotomy. A generator with an $s$-bit seed compresses its own $\le 2^s$ outputs perfectly, to $s$ bits, and helps with nothing else. It is worth knowing this before spending a year searching for the seed that contains your file.
