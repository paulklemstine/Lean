# Almost-Lossless Compression Beyond the Pigeonhole Bound: Exact Rates, Derandomised Monte Carlo Codebooks, and Linear-Time Decoding

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

The pigeonhole principle bounds *exact*, universal compression: an injective encoder into bitstrings of length at most $t$ can serve at most $2^{t+1}-1$ messages. We study the relaxation in which the decoder is permitted to fail with probability at most $\varepsilon$, subject to the strict requirement that it **never fail silently** — modelled by a partial decoder whose only alternative to the correct answer is an explicit failure symbol. We prove four groups of results.

*(i) Rate.* A sound code with codewords of length at most $t$ and failure probability at most $\varepsilon$ exists **if and only if** the source possesses a set $S$ of probability mass at least $1-\varepsilon$ with $|S| + 2 \le 2^{t+1}$, or $S$ is the whole alphabet and $|S| + 1 \le 2^{t+1}$. Hence the $\varepsilon$-relaxation of the counting bound is exactly the $(1-\varepsilon)$-quantile of the source, and error detection costs exactly one codeword. For the uniform source on $N$ symbols the bound reads $(1-\varepsilon)N \le 2^{t+1}$: tolerating failure probability $\varepsilon$ saves at most $\log_2\frac{1}{1-\varepsilon}$ bits, and $\varepsilon = 0$ recovers the classical bound.

*(ii) Randomness.* A uniformly random codebook $f : \{1,\dots,q\} \to \{1,\dots,m\}$ collides with probability at most $q(q-1)/(2m)$, with equality at $q=2$. Whenever a Monte Carlo codebook of rate $k$ succeeds — i.e. is injective on a typical set $S$ — the *deterministic* enumerative code on the same $S$ matches its rate and its failure probability, is sound with explicit failure reporting, and decodes exponentially faster. Random number generators therefore purchase no rate whatsoever.

*(iii) Complexity.* The enumerative decoder costs exactly $k+2$ instrumented steps at rate $k$ (at most $k+3$ on any codeword of the scheme), while exhaustive search over an unstructured codebook of $n$ entries costs exactly $n$ probes in the worst case for *every* storage order, and $n(n+1)/2$ summed over all messages, i.e. $(n+1)/2$ on average. The speed-up is unbounded: for every $M$ there is a rate $k$ with $M(k+3) < 2^k$.

*(iv) Robustness and composition.* A one-bit parity checksum detects every single-bit channel corruption while changing neither the good set nor the failure probability, giving a total decoding cost of $2k+4$. Because the scheme is fixed rate, $n$ codewords concatenate parse-free: soundness composes, the good set of the block code is the product of the per-block good sets, the failure probability satisfies $1 - (1-\varepsilon_0)^n \le n\varepsilon$, and block decoding costs exactly $n(k+3)+1$ steps — linear in the transmitted length.

**Keywords:** almost-lossless compression, pigeonhole bound, random coding, birthday bound, derandomisation, enumerative coding, decoder complexity, error detection.

---

## 1. Introduction

### 1.1 The immovable bound

Let $\mathcal{A}$ be a finite set of messages, $|\mathcal{A}| = N$. A lossless compressor that maps every message to a bitstring of length at most $t$ must be injective, and there are exactly $2^{t+1} - 1$ bitstrings of length at most $t$; hence $N \le 2^{t+1}-1$. This is the *pigeonhole bound*. It is a counting statement, so no algorithmic advance can weaken it.

Practical compression evades it not by cleverness but by changing the contract. Real compressors need only work on messages that actually occur. This paper takes the change of contract seriously and asks precisely what it buys.

### 1.2 The relaxed contract, and the one thing we refuse to give up

We relax "always correct" to "correct with probability at least $1-\varepsilon$". We do **not** relax correctness-when-answering. A decoder that returns a wrong message is a *silent corruption*; a decoder that returns "I failed" is a detected failure. Only the second is permitted. Formally this is achieved by making the decoder partial: its codomain is $\mathcal{A} \cup \{\bot\}$.

This is the falsifiability gate of the present work: every scheme comes with (a) a bound on its failure probability, (b) an exact decoding-complexity figure, and (c) a proof that failures are reported.

### 1.3 The question of randomness

Shannon's random-coding argument builds good codes by drawing them at random. Question: does randomness help under the relaxed contract? We answer in two parts. On **rate** the answer is a flat no — a random codebook that succeeds is a codebook that is injective on a typical set, and injectivity on a set of size $q$ into $m$ slots forces $q \le m$, which is precisely the counting constraint the deterministic scheme obeys. On **complexity** the answer is worse than no: a random codebook is an unstructured table whose only decoding procedure is search, costing $\Theta(2^k)$ probes against the deterministic scheme's $k+2$ steps.

### 1.4 Organisation

Section 2 fixes definitions. Section 3 proves the converse (relaxed counting bound). Section 4 gives the explicit enumerative scheme. Section 5 proves the exact rate characterisation and the one-codeword price of error detection. Section 6 treats random codebooks and derandomisation. Section 7 gives exact decoder complexities and the separation. Section 8 adds the checksum. Section 9 treats block composition. Section 10 assembles the master theorem, Section 11 discusses applications, and Section 12 states open problems.

---

## 2. Definitions

Throughout, $\mathcal{A}$ is a finite non-empty set (the *source alphabet*), $\{0,1\}^*$ is the set of finite bitstrings, and $p : \mathcal{A} \to \mathbb{R}_{\ge 0}$ is a probability distribution, $\sum_{x \in \mathcal{A}} p(x) = 1$. We write $p(S) = \sum_{x \in S} p(x)$.

**Definition 2.1 (Code).** A *code* on $\mathcal{A}$ is a pair $c = (E, D)$ with an encoder $E : \mathcal{A} \to \{0,1\}^*$ and a partial decoder $D : \{0,1\}^* \to \mathcal{A} \cup \{\bot\}$. The value $\bot$ is an explicit, detected failure.

**Definition 2.2 (Soundness — no silent corruption).** $c$ is *sound* if for all $x, y \in \mathcal{A}$, $D(E(x)) = y$ implies $y = x$.

**Definition 2.3 (Good set, failure probability).** The *good set* is $G(c) = \{x \in \mathcal{A} : D(E(x)) = x\}$. The *failure probability* is $\mathrm{fail}_p(c) = p(\mathcal{A}\setminus G(c)) = 1 - p(G(c))$.

**Definition 2.4 (Length bound).** $c$ has *length bound* $t$ if $|E(x)| \le t$ for every $x \in \mathcal{A}$. It is *fixed rate* $\ell$ if $|E(x)| = \ell$ for every $x$.

**Definition 2.5 ($\varepsilon$-almost-lossless).** $c$ is *$\varepsilon$-almost-lossless for $p$* if it is sound and $\mathrm{fail}_p(c) \le \varepsilon$.

Note the asymmetry built into Definition 2.2: soundness constrains the decoder only on legitimately produced codewords. Corruption introduced by a noisy channel is a separate concern, addressed in Section 8.

---

## 3. The converse: the $\varepsilon$-relaxed counting bound

**Lemma 3.1 (Injectivity on the good set).** If $c = (E,D)$ is sound, then $E$ is injective on $G(c)$.

*Proof.* Let $x, y \in G(c)$ with $E(x) = E(y)$. Since $y \in G(c)$, $D(E(y)) = y$, hence $D(E(x)) = y$. Soundness gives $y = x$. $\square$

**Lemma 3.2 (Restricted pigeonhole).** If $c$ is sound with length bound $t$, then $|G(c)| + 1 \le 2^{t+1}$.

*Proof.* By Lemma 3.1, $E$ injects $G(c)$ into the set of bitstrings of length at most $t$, which has cardinality $2^{t+1}-1$. $\square$

**Lemma 3.3 (Mass accounting).** For any code $c$, $p(G(c)) = 1 - \mathrm{fail}_p(c)$.

*Proof.* Split $\sum_{x} p(x) = 1$ across $G(c)$ and its complement. $\square$

**Theorem 3.4 ($\varepsilon$-relaxed counting bound).** Let $c$ be sound with length bound $t$ and $\mathrm{fail}_p(c) \le \varepsilon$. Then there exists $S \subseteq \mathcal{A}$ with
$$|S| + 1 \le 2^{t+1} \qquad\text{and}\qquad p(S) \ge 1 - \varepsilon .$$

*Proof.* Take $S = G(c)$; apply Lemma 3.2 and Lemma 3.3. $\square$

The interpretation is important: the relaxation does **not** create rate out of nothing. It replaces the question "how many messages are there?" by "how many messages are needed to cover mass $1-\varepsilon$?" — the $(1-\varepsilon)$-quantile of the source.

**Corollary 3.5 (Falsifiability form).** Suppose every $S$ with $|S|+1 \le 2^{t+1}$ satisfies $p(S) < 1-\varepsilon$. Then every sound code with length bound $t$ has $\mathrm{fail}_p(c) > \varepsilon$. *(Contrapositive of Theorem 3.4.)*

This is the refutation criterion for the whole programme: any claimed scheme at rate $t$ with failure $\le \varepsilon$ is refuted by exhibiting the mass deficit of all small sets.

**Theorem 3.6 (Uniform source).** Let $p$ be uniform on $\mathcal{A}$, $N = |\mathcal{A}| \ge 1$. If $c$ is sound with length bound $t$ and $\mathrm{fail}_p(c) \le \varepsilon$, then
$$(1-\varepsilon)\,N \;\le\; 2^{t+1}, \qquad\text{and, if } \varepsilon<1, \qquad \log_2\!\big((1-\varepsilon)N\big) \le t+1 .$$

*Proof.* Theorem 3.4 supplies $S$ with $p(S) = |S|/N \ge 1-\varepsilon$, so $|S| \ge (1-\varepsilon)N$, and $|S| + 1 \le 2^{t+1}$. The logarithmic form follows by monotonicity of $\log_2$. $\square$

**Corollary 3.7 (Conservativity at $\varepsilon = 0$).** A code that never fails on the uniform source satisfies $N \le 2^{t+1}$: the classical pigeonhole bound is recovered exactly.

**Remark 3.8 (How little error tolerance buys).** Theorem 3.6 says the saving is at most $\log_2 \frac{1}{1-\varepsilon}$ bits: $0.0145$ bits at $\varepsilon = 1\%$, $0.152$ bits at $\varepsilon = 10\%$, one full bit only at $\varepsilon = 50\%$. Large compression gains under the relaxed contract therefore never come from $\varepsilon$ alone; they come from *non-uniformity*, where the $(1-\varepsilon)$-quantile is exponentially smaller than $N$.

---

## 4. Achievability: the enumerative scheme

Fix a *typical set* $S \subseteq \mathcal{A}$ and a rate parameter $k$ with $|S| \le 2^k$. Fix any enumeration $\iota : S \to \{0, 1, \dots, |S|-1\}$ (a bijection).

**Definition 4.1 (Binary index codec).** For $k, n \in \mathbb{N}$, let $\mathrm{toBits}(k,n)$ be the little-endian $k$-bit expansion of $n$, defined by $\mathrm{toBits}(0,n) = \varepsilon_{\mathrm{str}}$ and $\mathrm{toBits}(k+1,n) = [n \bmod 2] \cdot \mathrm{toBits}(k, \lfloor n/2\rfloor)$; and let $\mathrm{fromBits}$ read a little-endian bitstring, $\mathrm{fromBits}(\,) = 0$, $\mathrm{fromBits}(b\cdot l) = b + 2\,\mathrm{fromBits}(l)$.

**Lemma 4.2.** $|\mathrm{toBits}(k,n)| = k$ for all $n$, and $\mathrm{fromBits}(\mathrm{toBits}(k,n)) = n$ whenever $n < 2^k$.

*Proof.* Both by induction on $k$; the second uses $n = (n \bmod 2) + 2\lfloor n/2 \rfloor$ and $\lfloor n/2\rfloor < 2^k$ when $n < 2^{k+1}$. $\square$

**Definition 4.3 (Enumerative code $\mathrm{Enum}(S,k)$).**
$$E(x) = \begin{cases} 1 \cdot \mathrm{toBits}(k, \iota(x)), & x \in S,\\ 0 \cdot \mathrm{toBits}(k, 0), & x \notin S,\end{cases}
\qquad
D(w) = \begin{cases} \iota^{-1}(\mathrm{fromBits}(r)), & w = 1\cdot r,\ \mathrm{fromBits}(r) < |S|,\\ \bot, & \text{otherwise.}\end{cases}$$

**Theorem 4.4 (Properties of the enumerative code).** Assume $|S| \le 2^k$. Then:

1. *(Fixed rate)* $|E(x)| = k+1$ for every $x \in \mathcal{A}$.
2. *(Correctness on $S$)* $D(E(x)) = x$ for every $x \in S$.
3. *(Explicit detection)* $D(E(x)) = \bot$ for every $x \notin S$.
4. *(Soundness)* $\mathrm{Enum}(S,k)$ is sound.
5. *(Good set)* $G(\mathrm{Enum}(S,k)) = S$.
6. *(Failure probability)* $\mathrm{fail}_p(\mathrm{Enum}(S,k)) = p(\mathcal{A}\setminus S)$.

*Proof.* (1) is immediate from Lemma 4.2 since both branches emit one flag bit plus $k$ index bits. (2): $\iota(x) < |S| \le 2^k$, so $\mathrm{fromBits}(\mathrm{toBits}(k,\iota(x))) = \iota(x) < |S|$ and $D$ returns $\iota^{-1}(\iota(x)) = x$. (3): the flag bit is $0$, and $D$ rejects every word beginning with $0$. (4) follows from (2) and (3): on $S$ the answer is $x$ itself, off $S$ there is no answer. (5) is (2) and (3) combined. (6) is (5) plus Definition 2.3. $\square$

**Theorem 4.5 (Achievability).** Let $S$ satisfy $|S| \le 2^k$ and $p(S) \ge 1 - \varepsilon$. Then there is a code $c$ that is sound, has length bound $k+1$, satisfies $\mathrm{fail}_p(c) \le \varepsilon$, has $G(c) = S$, and returns $\bot$ on every $x \notin S$.

*Proof.* Take $c = \mathrm{Enum}(S,k)$ and apply Theorem 4.4 with Lemma 3.3. $\square$

**Corollary 4.6 (Uniform achievability).** For uniform $p$ and any $k$ with $2^k \le N$, choosing $S$ of size exactly $2^k$ gives a sound code with length bound $k+1$ and failure probability exactly $1 - 2^k/N$.

Comparing Corollary 4.6 with Theorem 3.6 pins the optimal uniform rate to within two bits. Section 5 removes even that slack.

---

## 5. The exact rate, and the price of error detection

**Theorem 5.1 (Price of error detection).** Let $c$ be sound with length bound $t$ and $G(c) \ne \mathcal{A}$. Then
$$|G(c)| + 2 \le 2^{t+1}.$$

*Proof sketch.* By Lemma 3.1, $E$ injects $G(c)$ into the $2^{t+1}-1$ short strings, giving $|G(c)| \le 2^{t+1}-1$. Suppose equality. Then $E$ is a bijection from $G(c)$ onto *all* short strings. Pick $x \notin G(c)$. Its codeword $E(x)$ has length at most $t$, hence equals $E(y)$ for some $y \in G(c)$, and then $D(E(x)) = D(E(y)) = y \ne x$ — a silent corruption, contradicting soundness. Hence $|G(c)| \le 2^{t+1}-2$. $\square$

The extra unit is the codeword that must be reserved for saying "$\bot$": the decoder sees only the received string, so a detectable failure must occupy a string of its own.

**Theorem 5.2 (Realisable good sets).** Let $S \subsetneq \mathcal{A}$. There exists a sound code with length bound $t$ and good set exactly $S$ **iff** $|S| + 2 \le 2^{t+1}$.

*Proof sketch.* ($\Rightarrow$) Theorem 5.1. ($\Leftarrow$) Since $|S| + 2 \le 2^{t+1}$, choose an injection $\sigma$ of $S$ into the short strings that misses at least one short string $w_\bot$. Encode $x \in S$ as $\sigma(x)$ and every $x \notin S$ as $w_\bot$; decode $w$ to the unique preimage $\sigma^{-1}(w)$ when it exists and to $\bot$ otherwise. This is sound by construction, has length bound $t$, and has good set $S$. $\square$

**Theorem 5.3 (Exact optimal $\varepsilon$-almost-lossless rate).** For any distribution $p$, any $t \in \mathbb{N}$ and any $\varepsilon \in \mathbb{R}$:
$$\exists\, c \text{ sound, length bound } t,\ \mathrm{fail}_p(c) \le \varepsilon
\iff
\exists\, S \subseteq \mathcal{A}: p(S) \ge 1-\varepsilon \text{ and } \big[(S = \mathcal{A} \wedge |S|+1 \le 2^{t+1}) \vee |S| + 2 \le 2^{t+1}\big].$$

*Proof sketch.* ($\Rightarrow$) Take $S = G(c)$; if $G(c) = \mathcal{A}$ use Lemma 3.2, otherwise Theorem 5.1; the mass bound is Lemma 3.3. ($\Leftarrow$) In the total case ($S = \mathcal{A}$, $|\mathcal{A}|+1 \le 2^{t+1}$) inject all of $\mathcal{A}$ into the short strings and decode by inversion, giving a never-failing sound code. In the partial case apply Theorem 5.2. In both cases $\mathrm{fail}_p(c) = 1 - p(S) \le \varepsilon$. $\square$

Theorem 5.3 is the exact characterisation the programme was after: **the optimal $\varepsilon$-almost-lossless rate at codeword length $t$ is determined solely by the $(1-\varepsilon)$-quantile of the source, offset by exactly one reserved codeword whenever the code can fail at all.**

**Corollary 5.4 (The explicit scheme is within two bits).** If $|S| + 2 \le 2^{t+1}$ — so that $S$ is servable by *some* optimal code of length $t$ — then $\mathrm{Enum}(S, t+1)$ is sound, has length bound $t + 2$ and good set exactly $S$. Two bits of redundancy buy an exponentially faster decoder (Section 7).

---

## 6. Random codebooks: the birthday bound and its derandomisation

Model Shannon's argument at its combinatorial core. A *codebook* on $q$ messages with $m$ available codewords is a map $f : \{1,\dots,q\} \to \{1,\dots,m\}$; it *works* precisely when it is injective. Draw $f$ uniformly from the $m^q$ possibilities.

**Definition 6.1.** $\mathrm{Bad}(q,m) = \{f : \{1,\dots,q\}\to\{1,\dots,m\} \mid f \text{ not injective}\}$.

**Lemma 6.2 (Exact count).** $|\mathrm{Bad}(q,m)| + m^{\underline{q}} = m^q$, where $m^{\underline{q}} = m(m-1)\cdots(m-q+1)$ is the falling factorial.

*Proof.* The injective maps number exactly $m^{\underline{q}}$. $\square$

**Theorem 6.3 (Birthday bound).** $2\,|\mathrm{Bad}(q,m)| \le q(q-1)\,m^{q-1}$, hence for $m \ge 1$
$$\Pr_{f}[\,f \text{ collides}\,] = \frac{|\mathrm{Bad}(q,m)|}{m^q} \;\le\; \frac{q(q-1)}{2m}.$$

*Proof sketch.* By Lemma 6.2 it suffices to prove $2m^{q+1} \le 2\,m^{\underline{q+1}} + (q+1)q\,m^{q}$, which follows by induction on $q$ from $m^{\underline{q+1}} = (m-q)\,m^{\underline{q}}$ together with $m^{\underline q} \le m^q$. Dividing by $m^q$ gives the probability form. $\square$

**Theorem 6.4 (Tightness).** $|\mathrm{Bad}(2,m)| = m$ exactly, so the collision probability at $q = 2$ is exactly $m/m^2 = 1/m = \frac{2\cdot 1}{2m}$: Theorem 6.3 holds with equality and cannot be improved in general.

*Proof.* The non-injective maps $\{1,2\}\to\{1,\dots,m\}$ are exactly the $m$ constant maps; alternatively $m^2 - m^{\underline 2} = m^2 - m(m-1) = m$. $\square$

**Corollary 6.5 (Derandomisation).** If $q(q-1) < 2m$, the collision probability is $< 1$, so an injective codebook exists.

**Theorem 6.6 (Randomness buys no rate).** If $f : \mathcal{A} \to \{1,\dots,m\}$ is injective on $S \subseteq \mathcal{A}$ — however $f$ was obtained — then $|S| \le m$.

*Proof.* An injection from $S$ into an $m$-element set. $\square$

**Theorem 6.7 (Derandomisation of Monte Carlo compression).** Suppose a Monte Carlo experiment succeeds at rate $k$: it produces $f : \mathcal{A} \to \{0,\dots,2^k-1\}$ injective on a typical set $S$ with $p(S) \ge 1-\varepsilon$. Then $\mathrm{Enum}(S,k)$

1. is sound (no silent corruption),
2. has length bound $k+1$, i.e. the same rate,
3. has $\mathrm{fail}_p \le \varepsilon$, i.e. the same reliability,
4. returns $\bot$ explicitly on every $x \notin S$, and
5. decodes every $x \in S$ in exactly $k+2$ steps,

whereas decoding the random codebook by exhaustive search costs up to $2^k$ probes (Theorem 7.4).

*Proof.* Theorem 6.6 gives $|S| \le 2^k$, which is precisely the hypothesis of Theorem 4.4 and Theorem 7.2; the failure bound is Lemma 3.3 with $G = S$. $\square$

**Discussion.** Random coding is a *proof technique*, not a compression resource. What it establishes — the existence of a collision-free assignment of $|S|$ messages to $2^k$ slots — is exactly the statement $|S| \le 2^k$, and that statement is already the design rule of the deterministic enumerative code. The advantage of random coding is that it does not require knowing $S$ constructively; its cost, as Section 7 shows, is a decoder with no structure to exploit.

---

## 7. Exact decoder complexity and the separation

To make complexity claims exact rather than asymptotic we use *instrumented* decoders: procedures that return both an answer and a step count. Each instrumented decoder is proved to compute the same function as the decoder it instruments, so the counts describe genuine decoding.

**Definition 7.1 (Instrumented enumerative decoder).** On input $w$: if $w$ is empty or begins with $0$, return $(\bot, 1)$. Otherwise write $w = 1 \cdot r$, read $r$ with a bit-by-bit reader costing $|r| + 1$ steps (one per bit plus one to detect the end), and perform one indexed table access; return the result with cost $(|r| + 1) + 1$.

**Theorem 7.2 (Exact enumerative decoding cost).** If $|S| \le 2^k$ and $x \in S$, the instrumented enumerative decoder on $E(x)$ returns $x$ at a cost of exactly
$$k + 2 \text{ steps},$$
and its cost never exceeds $k+3$ on any codeword of the scheme.

*Proof.* $E(x) = 1 \cdot \mathrm{toBits}(k,\iota(x))$ with $|\mathrm{toBits}(k,\iota(x))| = k$; the reader costs $k+1$ and the lookup $1$. Correctness is Theorem 4.4(2). $\square$

**Definition 7.3 (Instrumented codebook scan).** Given a codebook $\mathrm{cb} : \mathcal{A} \to \{0,1\}^*$, a received word $w$, and a list $l$ of candidates, probe the candidates left to right, one step per probe, and stop at the first $a$ with $\mathrm{cb}(a) = w$; return $(\bot, |l|)$ if none matches.

The scan is sound: any answer it returns really does encode to the received word.

**Theorem 7.4 (Exact worst-case search cost).** If $a$ is the last entry of the candidate list and no earlier entry has the same codeword, the scan costs exactly $|l|$ probes, where $|l|$ is the length of the whole list. In particular, for an injective codebook of $2^k$ entries, decoding some message costs exactly $2^k$ probes.

*Proof.* Induction on the prefix: every non-matching probe costs $1$ and recurses. $\square$

**Theorem 7.5 (Worst case is order-independent).** Let the codebook be injective and stored in any order as a duplicate-free list $l \ne \varnothing$. Then there exists $x \in l$ whose decoding costs exactly $|l|$ probes.

*Proof.* Take $x$ to be the last element of $l$ and apply Theorem 7.4; injectivity and duplicate-freeness give the no-earlier-match hypothesis. $\square$

**Theorem 7.6 (The average case is exponential too).** For an injective codebook stored as a duplicate-free list $l$ of length $n$,
$$\sum_{x \in l} \mathrm{cost}(x) = \frac{n(n+1)}{2},$$
so the average decoding cost is $(n+1)/2$, i.e. approximately $2^{k-1}$ probes at rate $k$.

*Proof sketch.* Induction on $l$. The head costs $1$; every other element costs one more than it would in the tail, contributing $|l| - 1$ extra probes. Hence $T(n) = T(n-1) + 1 + (n-1) = T(n-1) + n$. $\square$

**Lemma 7.7.** $k + 3 < 2^k$ for all $k \ge 4$.

**Theorem 7.8 (Decoder complexity separation).** For every rate $k \ge 4$, every typical set $S$ with $|S| \le 2^k$ and every $x \in S$: the enumerative decoder's cost $k+2$ is strictly less than the $2^k$ probes of exhaustive search over an injective codebook of $2^k$ entries.

*Proof.* Theorem 7.2, Theorem 7.4 and Lemma 7.7. $\square$

**Theorem 7.9 (Unbounded speed-up).** For every $M \in \mathbb{N}$ there is a rate $k \ge 4$ with $M\,(k+3) < 2^k$; explicitly $k = 4M+8$ works.

*Proof sketch.* $M(4M+11) \le (2M+4)^2 < 2^{4M+8}$, the last step from $2M+4 < 2^{2M+4}$ squared. $\square$

**Discussion.** Theorems 7.5 and 7.6 close the two obvious escapes: reordering the codebook does not help (some message always pays a full pass), and the exponential cost is typical, not exceptional. The enumerative code is fast for a structural reason: its codeword *is* the address of the message in the typical-set table, so decoding is arithmetic followed by one indexed access, never a search.

---

## 8. Channel errors: a one-bit checksum keeps failures loud

Soundness (Definition 2.2) protects against decoder confusion on *undamaged* codewords. A channel that flips a bit can turn one valid codeword into another, and then even a sound code silently returns the wrong message. One bit of redundancy repairs this against single-bit errors.

**Definition 8.1 (Parity).** $\pi(w) = w_1 \oplus w_2 \oplus \cdots \oplus w_{|w|}$, with $\pi(\text{empty}) = 0$.

**Definition 8.2 (Checksummed code).** Given $c = (E,D)$, define $c^\pi$ by $E^\pi(x) = E(x)\cdot \pi(E(x))$ and
$$D^\pi(w) = \begin{cases}\bot, & \pi(w) = 1,\\ D(w_{1..|w|-1}), & \pi(w) = 0.\end{cases}$$

**Lemma 8.3.** $\pi(w \cdot \pi(w)) = 0$, and $\pi$ is additive over concatenation.

**Lemma 8.4 (One flip flips the parity).** For any $w$ and any index $i$, $\pi(w \text{ with bit } i \text{ flipped}) = \neg\,\pi(w)$.

*Proof.* Induction on $w$; flipping the head flips the XOR, and flipping in the tail flips the tail parity. $\square$

**Theorem 8.5 (Every single-bit channel error is detected).** For every $x$ and every position $i$ of $E^\pi(x)$, the decoder $D^\pi$ applied to $E^\pi(x)$ with bit $i$ flipped returns $\bot$. In particular it never returns a wrong message.

*Proof.* $\pi(E^\pi(x)) = 0$ by Lemma 8.3; flipping one bit makes the parity $1$ by Lemma 8.4; $D^\pi$ rejects. $\square$

**Theorem 8.6 (The checksum is otherwise free).** $c^\pi$ is sound whenever $c$ is; $G(c^\pi) = G(c)$; $\mathrm{fail}_p(c^\pi) = \mathrm{fail}_p(c)$; and the length bound rises by exactly one.

*Proof.* $D^\pi(E^\pi(x)) = D(E(x))$ by Lemma 8.3, so all four claims reduce to the corresponding property of $c$. $\square$

**Theorem 8.7 (Cost of the checksummed pipeline).** Verifying the parity costs one step per received bit, i.e. $k+2$ steps for the checksummed enumerative code at rate $k$; the enumerative decode costs a further $k+2$. Total: exactly $2k+4$ steps — still linear in the rate, still exponentially below the $2^k$ probes of search.

---

## 9. Block composition: parse-free concatenation and the union bound

Real sources emit strings, not symbols. Let $c$ be *fixed rate* $\ell$ (Definition 2.4) — the enumerative code is, with $\ell = k+1$, because the failure marker is padded to full length. Then concatenation needs no parsing.

**Definition 9.1 (Block code).** For $n \in \mathbb{N}$, the block encoder sends $v = (v_1,\dots,v_n) \in \mathcal{A}^n$ to $E(v_1)\cdot E(v_2)\cdots E(v_n)$. The block decoder slices the received word into $n$ consecutive chunks of $\ell$ bits, decodes each with $D$, and returns $\bot$ if any chunk fails or if the length does not match.

**Theorem 9.2 (The block decoder inverts the block encoder).** If every $v_i$ lies in $G(c)$, the block decoder returns $v$.

*Proof.* Induction on $n$: because $|E(v_1)| = \ell$ exactly, taking the first $\ell$ bits recovers $E(v_1)$ and dropping them recovers the concatenation of the remaining $n-1$ codewords. $\square$

**Theorem 9.3 (Soundness composes).** If $c$ is sound and fixed rate, the block code is sound for every $n$: it never returns a wrong tuple.

*Proof sketch.* By the same induction, any tuple the block decoder returns has each coordinate equal to a value returned by $D$ on the corresponding chunk, hence — by soundness of $c$ — equal to the true coordinate. $\square$

**Theorem 9.4 (Good sets multiply).** For sound, fixed-rate $c$, the good set of the block code is exactly $G(c)^n$: a block decodes if and only if every one of its symbols does.

*Proof sketch.* ($\supseteq$) Theorem 9.2. ($\subseteq$) The soundness induction of Theorem 9.3 also shows that if the block decoder answers at all then every chunk was decoded, hence every coordinate lies in $G(c)$. $\square$

**Lemma 9.5 (Product mass).** For the product distribution $P(v) = \prod_{i=1}^n p(v_i)$ and any $G \subseteq \mathcal{A}$, $\;P(G^n) = p(G)^n$. In particular $P$ is a probability distribution.

*Proof.* Expand $\big(\sum_{x \in G} p(x)\big)^n$ by distributivity. $\square$

**Theorem 9.6 (Union bound for block composition).** Let $c$ be sound and fixed rate with $\mathrm{fail}_p(c) \le \varepsilon$, where $0 \le \varepsilon$ and $p \ge 0$. Then under the product source,
$$\mathrm{fail}_P(\text{block code}) = 1 - \big(1 - \mathrm{fail}_p(c)\big)^n \;\le\; n\,\varepsilon .$$

*Proof.* By Theorem 9.4 and Lemma 9.5, the block good mass is $p(G(c))^n = (1 - \mathrm{fail}_p(c))^n \ge (1-\varepsilon)^n$. If $\varepsilon \le 1$, Bernoulli's inequality gives $(1-\varepsilon)^n \ge 1 - n\varepsilon$, so the failure mass is at most $n\varepsilon$. If $\varepsilon > 1$ the bound is trivial for $n \ge 1$ (failure probabilities are at most $1 \le n\varepsilon$), and for $n = 0$ the failure probability is $0$. $\square$

Combined with Theorem 9.3 this is the composition guarantee in full: $n$ blocks fail with probability at most $n\varepsilon$, **and never silently**.

**Theorem 9.7 (Exact block decoding complexity).** For the enumerative code at rate $k$ and any $v \in S^n$, the instrumented block decoder returns $v$ at a cost of exactly
$$n\,(k+3) + 1 \text{ steps},$$
for $n(k+1)$ transmitted bits — linear in the length of the message, with a constant close to $1$.

*Proof sketch.* Induction on $n$. Each block costs one slicing step plus the $k+2$ steps of Theorem 7.2; the base case costs $1$ (the empty-string check). $\square$

By contrast, a random codebook for the whole block of $n$ symbols has $2^{nk}$ entries, and Theorems 7.4–7.6 apply to it verbatim: worst-case and average-case search costs are exponential in $nk$.

---

## 10. The master theorem

**Theorem 10.1 (Scheme with full guarantee).** Let $p$ be a distribution on $\mathcal{A}$, $S \subseteq \mathcal{A}$ with $|S| \le 2^k$ and $p(S) \ge 1-\varepsilon$. Then the checksummed enumerative code $\mathrm{Enum}(S,k)^\pi$ satisfies all of the following simultaneously:

1. **Soundness.** A returned message is always the true message.
2. **Rate.** Every codeword has $k+2$ bits: $k$ index bits, one failure flag, one parity bit.
3. **Reliability.** $\mathrm{fail}_p \le \varepsilon$.
4. **Explicit failure reporting.** Every $x \notin S$ decodes to $\bot$.
5. **Exact decoding complexity.** $2k+4$ steps on every $x \in S$: $k+2$ to verify the checksum, $k+2$ to decode the index.
6. **Channel error detection.** Every single-bit corruption of a transmitted codeword is detected, i.e. decodes to $\bot$.

**Theorem 10.2 (Matching converse).** Any sound code — randomised or not — with length bound $t$ and $\mathrm{fail}_p \le \varepsilon$ admits a set $S$ with $|S| + 1 \le 2^{t+1}$ and $p(S) \ge 1 - \varepsilon$; and if it fails anywhere ($G \ne \mathcal{A}$) then $|G| + 2 \le 2^{t+1}$.

Together, Theorems 10.1, 10.2 and 5.3 answer the guiding question completely: the achievable region is exactly the $(1-\varepsilon)$-quantile region, an explicit linear-time scheme attains it to within two bits (and exactly, by Theorem 5.2, if one drops the demand for a *pure index* code), and randomness contributes nothing to it.

---

## 11. Applications and algorithmic notes

**Typical-set compression in practice.** For an i.i.d. source with entropy $H$, the asymptotic equipartition property supplies typical sets of size $\approx 2^{nH}$ carrying mass $\ge 1-\varepsilon$. Theorem 4.5 turns any such set into a concrete code of rate $nH + 1$ bits per block with detected failures, and Theorem 7.2 says decoding costs $nH+2$ steps, not $2^{nH}$. The results here are non-asymptotic: they hold for the finite typical set as given, with no $n \to \infty$ limit.

**Design rule.** Given a target failure probability $\varepsilon$: sort the alphabet by decreasing probability, take the shortest prefix $S$ with $p(S) \ge 1-\varepsilon$, set $k = \lceil \log_2 |S|\rceil$, and emit $k+2$ bits per symbol. By Theorem 5.3, no sound scheme with the same $\varepsilon$ can use fewer than $\lceil\log_2(|S_{\min}|+2)\rceil - 1$ bits, where $S_{\min}$ is a minimum-size set of mass $\ge 1-\varepsilon$; the scheme is within two bits of that, always.

**Why fixed rate matters.** Variable-length codes need a parser, and parsing an unstructured variable-length codebook reintroduces search. Fixed-rate codewords make the block decoder a loop of slices, which is exactly why Theorem 9.7 is linear.

**Storage.** The enumerative decoder needs the table $\iota^{-1}$, of size $|S|$; the same is true of a random codebook. Random coding therefore does not even save memory — only design effort.

**Detected failures as a system primitive.** The $\bot$ symbol is a first-class output. A system can respond by retransmitting, by falling back to an uncompressed representation (costing $\lceil \log_2 N\rceil$ bits on an $\varepsilon$-fraction of messages, hence $\varepsilon \log_2 N$ bits of expected overhead), or by raising an alarm. What it never has to do is verify the output by other means.

---

## 12. Open problems

**Conjecture 12.1 (The union bound is the exact loss of block composition).** Theorem 9.6 gives $\mathrm{fail} = 1 - (1-\varepsilon_0)^n \le n\varepsilon$. Conjecture: this is *exactly optimal* among all sound fixed-rate block schemes of total rate $n(k+1)$ on a product source — no joint (non-product) code of the same rate has smaller failure probability, so joint typicality buys nothing beyond the per-block quantile.

*Route.* Apply the exact characterisation (Theorem 5.3) to the product source. The question becomes: **is a heaviest set of prescribed cardinality in a product measure always a product of per-coordinate heaviest sets?** For product measures with a common marginal this is a rearrangement statement about products of sorted vectors. The characterisation and the product-mass identity (Lemma 9.5) are both in hand; only the rearrangement step is open. (The answer is not a trivial "yes" for arbitrary cardinalities — products of sorted vectors need not be sorted lexicographically — so the correct statement may require the cardinality to be a product $m^n$, which is the case of interest here.)

**Conjecture 12.2 (Query lower bound for unstructured codebooks).** Any decoder that accesses a codebook only through equality probes "$\mathrm{cb}(a) \stackrel{?}{=} w$" needs at least $|\mathrm{codebook}|$ probes in the worst case, for *every* probe order and every *adaptive* strategy — not merely for the left-to-right scan of Theorems 7.4–7.5.

*Route.* An adversary argument: as long as some message has not been probed, the adversary can consistently claim that message is the true one, since no negative probe constrains it. Formalising this requires a model of adaptive probe transcripts and a consistency invariant.

**Further directions.** (a) Extend Theorem 8.5 from single-bit to $d$-bit corruptions using a distance-$(d+1)$ detecting code, and recompute the exact rate and step counts. (b) Quantify the trade-off between the $\varepsilon$-quantile rate and the expected total length of a hybrid scheme that falls back to raw transmission on $\bot$. (c) Determine the exact optimal rate when the decoder is allowed *list* outputs of size $L$ — the counting bound should relax to $|S| \le L(2^{t+1}-1)$, and the price of error detection to one codeword per list slot.

---

## 13. Conclusion

Relaxing exact decoding to $\varepsilon$-almost-lossless decoding does not repeal the pigeonhole bound; it re-indexes it by the $(1-\varepsilon)$-quantile of the source, and charges exactly one codeword for the ability to announce failure. Within that region an explicit, fixed-rate, enumerative scheme is optimal to within two bits, decodes in $k+2$ steps (or $2k+4$ with a single-bit-error-detecting checksum), composes over $n$ blocks parse-free with failure probability $1-(1-\varepsilon_0)^n \le n\varepsilon$ and decoding cost $n(k+3)+1$, and never corrupts silently.

Against this, Monte Carlo codebooks — the classical route to almost-lossless coding — provide no rate advantage at all, because the event that a random codebook succeeds is the event that it is injective on the typical set, which is the counting condition the deterministic scheme is built from; and they charge an unbounded factor in decoding time, because an unstructured table can only be searched. **The resource that pays in almost-lossless compression is structure, not randomness.**
