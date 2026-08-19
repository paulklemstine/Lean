# Almost-Lossless Compression Beyond the Pigeonhole Bound: Exact Rate Characterisation, Monte Carlo Schemes with Detected Failure, and a Rate–Time Hyperbola

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

The pigeonhole principle forbids a code that decodes every source word exactly with fewer codewords than source words. We study the *almost-lossless* relaxation, in which the decoder is permitted to fail with probability at most $\varepsilon$ but is never permitted to fail *silently*, and we determine precisely how much the counting bound relaxes.

Three groups of results are established. First, on the rate side, we prove an exact characterisation — the **$\varepsilon$-relaxed pigeonhole principle** — stating that a codeword alphabet $C$ admits an $\varepsilon$-reliable code for a source $\mu$ if and only if some set of at most $|C|$ source words carries probability at least $1-\varepsilon$. For a uniform source this specialises to the sharp bound $|C| \ge (1-\varepsilon)|S|$, and we show that this bound is *unaffected by shared randomness*: every randomized ensemble of codes has average failure probability at least $1 - |C|/|S|$, and more generally, for every source, an ensemble with average failure $\le\varepsilon$ implies a deterministic code with failure $\le \varepsilon$. We also show that honesty (no silent corruption) is free: any code is matched, on its correct set, by an honest uniqueness-scan code whose decoder probes at most one candidate.

Second, on the construction side, we give a Monte Carlo scheme based on $2$-universal hashing whose average failure probability is at most $\varepsilon + t(t-1)/|M|$ for a typical set of size $t$ and hash range $M$, whose decoder is honest *for every seed* — failures are always detected — and whose cost is an exactly computed number of candidate tests. Derandomising by the probabilistic method and invoking the existence of a prime in $(n, 2n]$, we obtain a fully explicit deterministic scheme over $\mathbb{F}_p$ with $t^2 < p \le 2t^2$ that decodes every typical word correctly using an alphabet of $p+1 \le 2t^2+1$ symbols: a *quadratic* rate penalty relative to the information-theoretic optimum $t$, and nothing more.

Third, and centrally, we address decoder complexity, which we identify as the true obstacle. For a **bucketed** two-hash decoder with a pairwise independent bucket hash of range $m_1$, the expected number of candidate tests when decoding a typical word is *exactly* $1 + (t-1)/m_1$ — an identity, not a bound. Against this we prove a universal converse by Cauchy–Schwarz over codeword fibres: for *every* candidate-scanning scheme and *every* seed, the total decoding work over the typical set is at least $t^2/|M|$, so the average per-word cost is at least $t/|M|$. Rate and decoding time therefore obey a hyperbolic trade-off, and the bucketed decoder is optimal to within an additive $1$.

Finally, we compute the Monte Carlo failure probability *exactly* in the planar case: for $T \subseteq \mathbb{F}_p^2$ whose difference set realises $d$ distinct projective directions, the number of bad seeds is exactly $1 + d(p-1)$, giving failure probability exactly $(1+d(p-1))/p^2$. A worked example over $\mathbb{F}_{11}$ shows the union bound loose by more than a factor of two.

**Keywords:** almost-lossless source coding, pigeonhole principle, typical sets, 2-universal hashing, pairwise independence, derandomisation, decoder complexity, Cauchy–Schwarz converse, projective directions.

---

## 1. Introduction

### 1.1 The exact bound and the crack in it

Let $S$ be a finite set of source words and $C$ a finite set of codewords. A *lossless* fixed-length code is a pair $(\mathrm{enc}, \mathrm{dec})$ with $\mathrm{dec}(\mathrm{enc}(s)) = s$ for all $s$; the pigeonhole principle forces $|C| \ge |S|$. This is the reason there is no universal compressor, and it is completely insensitive to the cleverness of the encoder.

The relaxation studied here is the one that all of practical information theory lives in. We allow the decoder to fail on a set of source words of probability at most $\varepsilon$. The research question we address is precise:

> *Pigeonhole governs exact decoding of all strings. Relax to: the decoder fails with probability at most $\varepsilon$. How far does the counting bound actually relax, can shared randomness (a random number generator) help, and what is the resulting decoding complexity?*

We answer all three parts, and add a fourth constraint that we regard as non-negotiable for a usable scheme: **no silent corruption**. A decoder that occasionally returns a wrong word without flagging it is unusable, because its output carries no information about its own reliability. Every scheme in this paper is *honest*: on every input it returns either the true source word or an explicit failure symbol.

### 1.2 Summary of contributions

1. **Exact relaxed pigeonhole** (Theorem 3.5): $\varepsilon$-reliability with alphabet $C$ $\iff$ existence of a set of size $\le |C|$ with probability $\ge 1-\varepsilon$. The counting bound does not relax by a constant factor; it relaxes into a statement about source concentration.
2. **Randomness is worthless for rate** (Theorems 3.3, 3.7): the uniform-source lower bound $1 - |C|/|S|$ applies verbatim to the average failure probability of any randomized ensemble, and for arbitrary sources any ensemble can be derandomised without loss.
3. **Honesty is free** (Theorem 3.8): every code is matched by an honest scan code with the same correct set and decoder cost $\le 1$.
4. **Monte Carlo scheme with detected failure** (Theorems 5.3, 5.4): honest for every seed; average failure $\le \varepsilon + t(t-1)/|M|$.
5. **Explicit derandomised scheme with quadratic rate** (Theorem 6.3).
6. **Exact expected decoder cost** $1 + (t-1)/m_1$ for bucketed decoding with a pairwise independent bucket hash (Theorem 7.3).
7. **Universal rate–time converse** (Theorems 7.4, 7.5): total work $\ge t^2/|M|$; average work $\ge t/|M|$.
8. **Exact planar failure probability** $(1 + d(p-1))/p^2$ (Theorems 8.3, 8.4) with a worked example beating the union bound by a factor $>2$.

---

## 2. Definitions

Throughout, $S$ is a finite type of source words, $C$ a finite type of codewords, and all probabilities are exact rationals; no asymptotics or limits are used anywhere. All statements are one-shot and finite.

**Definition 2.1 (Code).** A *code* from $S$ to $C$ is a pair $K = (\mathrm{enc}, \mathrm{dec})$ with $\mathrm{enc} : S \to C$ and $\mathrm{dec} : C \to S \cup \{\bot\}$, where $\bot$ denotes an explicit decoding failure.

**Definition 2.2 (Correctness).** The word $s$ is *decoded correctly* by $K$, written $\mathrm{Corr}_K(s)$, if $\mathrm{dec}(\mathrm{enc}(s)) = s$.

**Definition 2.3 (Honesty).** $K$ is *honest* if for every $s \in S$, either $\mathrm{dec}(\mathrm{enc}(s)) = s$ or $\mathrm{dec}(\mathrm{enc}(s)) = \bot$. Equivalently, $\mathrm{dec}(\mathrm{enc}(s)) = t$ with $t \ne \bot$ implies $t = s$: the decoder never returns a wrong word.

**Definition 2.4 (Source).** A *source* on $S$ is a weight function $\mu : S \to \mathbb{Q}_{\ge 0}$ with $\sum_{s} \mu(s) = 1$. For $A \subseteq S$ we write $\mu(A) = \sum_{s \in A} \mu(s)$. The *uniform source* assigns $\mu(s) = 1/|S|$.

**Definition 2.5 (Failure probability).** $P_{\text{fail}}(\mu, K) = \mu(\{s : \neg\,\mathrm{Corr}_K(s)\})$. A code is *$\varepsilon$-reliable* for $\mu$ if $P_{\text{fail}}(\mu, K) \le \varepsilon$.

**Definition 2.6 (Randomized ensemble).** For a finite nonempty seed set $\Omega$, an ensemble is a family $(K_\omega)_{\omega \in \Omega}$ of codes; its *average failure probability* under a uniform seed is
$$\overline{P}_{\text{fail}}(\mu, K) \;=\; \frac{1}{|\Omega|}\sum_{\omega \in \Omega} P_{\text{fail}}(\mu, K_\omega).$$

**Definition 2.7 (Hash family; 2-universality; pairwise independence).** A *hash family* is a map $h : A \times S \to M$ written $h_a(x)$, with $A$ (seeds) and $M$ (hash range) finite. It is *2-universal* if for all $x \ne y$,
$$\#\{a \in A : h_a(x) = h_a(y)\}\cdot |M| \;\le\; |A|,$$
i.e. the collision probability is at most $1/|M|$; it is *pairwise independent* if the same relation holds with equality.

**Definition 2.8 (Bad seed).** Given a set $T \subseteq S$, the seed $a$ *collides on* $T$ if there are distinct $x, y \in T$ with $h_a(x) = h_a(y)$. A non-colliding seed is exactly one for which $h_a$ is injective on $T$.

**Definition 2.9 (Scan scheme).** A *scan scheme* consists of: a *typical set* $T \subseteq S$; a hash family $h : A \times S \to M$ used as the codeword; and, for each seed $a$ and each codeword $m$, a finite *candidate set* $\mathrm{cand}_a(m) \subseteq T$, subject to the two axioms

* $\mathrm{cand}_a(m) \subseteq T$ (candidates are typical), and
* $x \in T \implies x \in \mathrm{cand}_a(h_a(x))$ (the true word is always a candidate).

**Definition 2.10 (Uniqueness-scan decoder and its cost).** On receiving $m$, the decoder tests each $y \in \mathrm{cand}_a(m)$ for $h_a(y) = m$, and returns $y$ if exactly one candidate matches, and $\bot$ otherwise (no match, or two or more matches). Its *cost* is $\mathrm{cost}_a(m) := |\mathrm{cand}_a(m)|$, the number of candidate tests. The induced code sends $\mathrm{enc}(s) = h_a(s)$ for $s \in T$ and $\mathrm{enc}(s) = \bot$ otherwise; its codeword alphabet has $|M| + 1$ symbols.

Two instances recur:

* **Linear scan:** $\mathrm{cand}_a(m) = T$ for all $m$. Cost exactly $|T|$.
* **Bucketed scheme:** two independently seeded hashes $h_1 : A_1 \times S \to M_1$ (the *bucket hash*) and $h_2 : A_2 \times S \to M_2$ (the *checksum*), with codeword $(h_1(x), h_2(x))$ and $\mathrm{cand}_{(a_1,a_2)}(m) = \{y \in T : h_1{}_{a_1}(y) = m_1\}$. The decoder scans one bucket of a precomputed index of $T$ and uses the checksum to disambiguate.

---

## 3. The rate side: exactly how far the counting bound relaxes

### 3.1 The pigeonhole core

**Theorem 3.1 (Counting Lemma).** *For every code $K : S \to C$, the set $\{s : \mathrm{Corr}_K(s)\}$ injects into $C$; hence $|\{s : \mathrm{Corr}_K(s)\}| \le |C|$, and at least $|S| - |C|$ source words fail to decode.*

*Proof.* If $\mathrm{Corr}_K(x)$, $\mathrm{Corr}_K(y)$ and $\mathrm{enc}(x) = \mathrm{enc}(y)$ then $x = \mathrm{dec}(\mathrm{enc}(x)) = \mathrm{dec}(\mathrm{enc}(y)) = y$. So $\mathrm{enc}$ is injective on the correct set, which therefore has cardinality at most $|C|$. The failure count follows by complementation. $\square$

No honesty, probability, or randomness is used. This is the exact residue of the pigeonhole principle in the relaxed setting.

**Theorem 3.2 (Uniform converse).** *For the uniform source, every code $K : S \to C$ satisfies*
$$P_{\text{fail}} \;\ge\; 1 - \frac{|C|}{|S|}.$$
*Equivalently, if $K$ is $\varepsilon$-reliable then $(1-\varepsilon)|S| \le |C|$.*

*Proof.* The incorrect set has cardinality at least $|S| - |C|$ by Theorem 3.1, and each word has weight $1/|S|$. $\square$

### 3.2 Randomness buys nothing

**Theorem 3.3 (Randomized converse, uniform source).** *For every finite nonempty seed set $\Omega$ and every ensemble $(K_\omega)$ of codes into $C$, the average failure probability on the uniform source satisfies $\overline{P}_{\text{fail}} \ge 1 - |C|/|S|$.*

*Proof.* By Theorem 3.2 each summand $P_{\text{fail}}(K_\omega)$ is at least $b := 1 - |C|/|S|$; the average of $|\Omega|$ numbers each at least $b$ is at least $b$. $\square$

This settles the "can a random number generator help?" question in the negative in the strongest possible sense: *no ensemble whatsoever*, of any size, structure or distribution over deterministic codes, beats the deterministic bound on a uniform source. Shannon's random-coding argument does not violate this — it exploits *source concentration*, not randomness, as Theorem 3.5 makes precise.

### 3.3 Achievability and the exact characterisation

**Lemma 3.4 (Generic achievability).** *If a code decodes every element of $T$ correctly and $\mu(T) \ge 1-\varepsilon$, then $P_{\text{fail}} \le \varepsilon$.*

*Proof.* The incorrect set is contained in $S \setminus T$, whose probability is $1 - \mu(T) \le \varepsilon$. $\square$

The prototypical achiever is the **table code** for $T$: enumerate $T$ as $t_0, \dots, t_{|T|-1}$, encode $t_i$ by the index $i$ and every atypical word by $\bot$; decode index $i$ to $t_i$ and $\bot$ to $\bot$. It is honest by construction, uses $|T| + 1$ symbols, decodes every typical word correctly and hence has $P_{\text{fail}} \le \varepsilon$ whenever $\mu(T) \ge 1-\varepsilon$, with a single table lookup — $O(1)$ — per decoding.

**Theorem 3.5 ($\varepsilon$-relaxed pigeonhole principle).** *Let $\mu$ be a source on $S$ and $C$ a nonempty finite alphabet. Then*
$$\exists\, K : S \to C \text{ with } P_{\text{fail}}(\mu, K) \le \varepsilon \qquad\Longleftrightarrow\qquad \exists\, T \subseteq S \text{ with } |T| \le |C| \text{ and } \mu(T) \ge 1 - \varepsilon .$$

*Proof.* ($\Rightarrow$) Take $T = \{s : \mathrm{Corr}_K(s)\}$. By Theorem 3.1, $|T| \le |C|$; and $\mu(T) = 1 - P_{\text{fail}} \ge 1-\varepsilon$.
($\Leftarrow$) Since $|T| \le |C|$ there is an injection $f$ of an index set of $T$ into $C$. Encode $t_i$ by $f(i)$ and every atypical word by a fixed junk codeword $c_0$; decode $c$ by the unique $t_i$ with $f(i) = c$, if one exists, and by $\bot$ otherwise. This decodes every element of $T$ correctly, so Lemma 3.4 applies. $\square$

**Interpretation.** The relaxation is *not* a multiplicative loosening of the counting bound. It converts the question "how many codewords?" into the question "how small can a $(1-\varepsilon)$-mass set be?" — the *concentration function* of the source. For a uniform source every set of size $|C|$ has probability exactly $|C|/|S|$ and Theorem 3.5 collapses to Theorem 3.2; for a concentrated source the smallest $(1-\varepsilon)$-mass set can be exponentially smaller than $S$, which is exactly the phenomenon exploited by all typical-set coding.

**Corollary 3.6 (Every ensemble is dominated by one of its members).** *For any source and any ensemble, some seed $\omega$ satisfies $P_{\text{fail}}(K_\omega) \le \overline{P}_{\text{fail}}$.*

*Proof.* A finite family of rationals contains a member no larger than its mean. $\square$

**Theorem 3.7 (General derandomisation).** *For every source $\mu$, if a randomized ensemble into $C$ satisfies $\overline{P}_{\text{fail}} \le \varepsilon$, then there exists a set $T$ with $|T| \le |C|$ and $\mu(T) \ge 1-\varepsilon$, and consequently a single deterministic code into $C$ with $P_{\text{fail}} \le \varepsilon$.*

*Proof.* Combine Corollary 3.6 with both directions of Theorem 3.5. $\square$

So shared randomness is *never necessary* for rate — for any source, not merely the uniform one. Its role is entirely computational: it lets one exhibit a good object without searching for it.

### 3.4 Honesty is free

**Theorem 3.8 (Honesty is free).** *Let $K : S \to C$ be an arbitrary code, honest or not. Then there is a scan scheme (with trivial seed set) whose induced code $K'$ satisfies: (i) $\mathrm{Corr}_{K'}(s) \iff \mathrm{Corr}_K(s)$ for every $s$; (ii) $K'$ is honest; (iii) every decoding of $K'$ probes at most one candidate. The only cost is one extra alphabet symbol.*

*Proof.* Let $T = \{s : \mathrm{Corr}_K(s)\}$, take $h(s) = \mathrm{enc}(s)$ as the hash and $\mathrm{cand}(m) = \{s \in T : \mathrm{enc}(s) = m\}$. By Theorem 3.1 the encoder is injective on $T$, so every candidate set has at most one element, giving (iii); the uniqueness-scan decoder returns the true word for each $s \in T$ and $\bot$ elsewhere, giving (i) and (ii). $\square$

The moral: any purported advantage of silent corruption is illusory. One may as well always flag failures.

---

## 4. Hashing: the derandomised random codebook

Shannon's argument draws a codebook uniformly at random. For almost-lossless source coding, the only property of the random codebook used anywhere is that two fixed distinct source words collide with probability at most $1/|M|$ — i.e. 2-universality. Replacing a random codebook (exponentially many random bits, exponential storage) with a 2-universal family (a seed of $k$ field elements, evaluation in $k$ multiplications) is therefore lossless in the analysis and enormous in the implementation.

**Theorem 4.1 (Union bound over pairs).** *Let $h$ be 2-universal and $T \subseteq S$. Then*
$$\#\{a \in A : h_a \text{ is not injective on } T\}\cdot|M| \;\le\; |T^{\ne}|\cdot|A|,$$
*where $T^{\ne}$ is the set of ordered pairs of distinct elements of $T$, of cardinality $t(t-1)$ with $t = |T|$. Equivalently, a uniformly random seed is bad with probability at most $t(t-1)/|M|$.*

*Proof.* The bad set is the union over ordered pairs $(x,y)$ with $x \ne y$ of $\{a : h_a(x) = h_a(y)\}$, each of size at most $|A|/|M|$ by 2-universality; sum. $\square$

**Theorem 4.2 (Derandomisation by the probabilistic method).** *If $|M| > t(t-1)$ then some seed $a$ is injective on $T$.*

*Proof.* By Theorem 4.1 the bad fraction is $< 1$, so the good set is nonempty. $\square$

**Theorem 4.3 (The inner-product family is exactly pairwise independent).** *Let $p$ be prime and $h_a(x) = \langle a, x\rangle = \sum_{i<k} a_i x_i$ for $a, x \in \mathbb{F}_p^k$. Then for all $x \ne y$,*
$$\#\{a : \langle a, x\rangle = \langle a, y\rangle\}\cdot p = p^k,$$
*i.e. exactly a $1/p$ fraction of seeds collide; in particular the family is 2-universal.*

*Proof.* $\langle a,x\rangle = \langle a,y\rangle \iff \langle a, x-y\rangle = 0$ with $z := x - y \ne 0$. The map $a \mapsto \langle a, z\rangle$ is a nonzero additive homomorphism $\mathbb{F}_p^k \to \mathbb{F}_p$, hence surjective (its image is a nonzero subgroup of the simple group $\mathbb{F}_p^+$), and all fibres of a surjective homomorphism of finite abelian groups have the same cardinality $|A|/|M| = p^{k-1}$. $\square$

Two independently seeded 2-universal families combine coordinatewise into a 2-universal family into $M_1 \times M_2$; this is what licenses the bucketed construction of Section 7. Two-universality is also preserved under precomposition with an injection $S' \hookrightarrow S$, which is what lets one hash an arbitrary finite source by embedding it in a vector space.

---

## 5. The Monte Carlo scheme and its guarantees

Fix a scan scheme with typical set $T$, hash family $h$, and candidate sets as in Definition 2.9.

**Theorem 5.1 (Unconditional honesty).** *For every seed $a$ — including seeds for which $h_a$ collides all over $T$ — the induced code is honest.*

*Proof.* The decoder returns some $y \ne \bot$ only when exactly one candidate matches the received codeword. If the transmitted word is $x \in T$, then $x$ itself is a candidate for $h_a(x)$ and matches; uniqueness therefore forces $y = x$. If the transmitted word is atypical, the encoder sent $\bot$ and the decoder returns $\bot$. $\square$

This is the design principle behind "no silent corruption": the decoder does not trust the seed. A catastrophic seed produces *ambiguity*, and ambiguity is reported, not resolved by guessing.

**Theorem 5.2 (Exact decoding cost).** *Decoding a received codeword $m$ under seed $a$ performs exactly $|\mathrm{cand}_a(m)|$ hash evaluations and comparisons — a single pass, with no search or backtracking. In particular the linear-scan decoder costs exactly $|T|$ tests.*

*Proof.* The instrumented scan increments its counter exactly once per element of the candidate list, and the candidate list is the finite candidate set enumerated once. $\square$

**Theorem 5.3 (Correctness under a good seed).** *If $h_a$ is injective on $T$, then every typical word decodes correctly.*

*Proof.* For $x \in T$, $x$ is a candidate for $h_a(x)$ and matches; any other matching candidate $y \in T$ would satisfy $h_a(y) = h_a(x)$ with $y \ne x$, contradicting injectivity. So the match is unique. $\square$

**Theorem 5.4 (Monte Carlo reliability — the deliverable bound).** *Let $h$ be 2-universal, let $\mu(T) \ge 1 - \varepsilon$ with $\varepsilon \ge 0$, and draw the seed uniformly at random. Then*
$$\overline{P}_{\text{fail}} \;\le\; \varepsilon \;+\; \frac{t(t-1)}{|M|},$$
*where $t = |T|$. Moreover every failure is detected: for every seed the code is honest.*

*Proof.* Split the seeds into the bad set $B$ (colliding on $T$) and its complement. For $a \notin B$, Theorem 5.3 and Lemma 3.4 give $P_{\text{fail}}(K_a) \le \varepsilon$. For $a \in B$ we use only the trivial bound $P_{\text{fail}} \le 1$. Averaging,
$$\overline{P}_{\text{fail}} \;\le\; \frac{|B^c|\,\varepsilon + |B|}{|A|} \;\le\; \varepsilon + \frac{|B|}{|A|} \;\le\; \varepsilon + \frac{t(t-1)}{|M|}$$
by Theorem 4.1. Honesty is Theorem 5.1. $\square$

The two error terms have different characters: $\varepsilon$ is *atypicality loss*, intrinsic to the source and irreducible by Theorem 3.5; $t(t-1)/|M|$ is *collision loss*, an artefact of the construction which we can drive to zero by enlarging $M$ — or eliminate entirely by derandomising.

**A concrete compressor.** Take $S = \mathbb{F}_p^k$ (length-$k$ strings over a $p$-symbol alphabet), seed $a \in \mathbb{F}_p^k$ drawn by a random number generator and shared by encoder and decoder, and codeword $\langle a, x\rangle \in \mathbb{F}_p$ plus the failure flag: $p+1$ symbols in total, against $p^k$ source words. By Theorems 4.3, 5.1, 5.2 and 5.4 this scheme is honest for every seed, decodes in exactly $|T|$ tests (linear scan) and fails with average probability at most $\varepsilon + t(t-1)/p$.

**No paradox.** On the *uniform* source over all of $\mathbb{F}_p^k$ the same $(p+1)$-symbol alphabet fails with probability at least $1 - (p+1)/p^k$ by Theorem 3.2. The compressor wins only because the source is concentrated: it is the smallness of $T$, never the randomness of the seed, that does the work.

---

## 6. Derandomisation and the price of explicitness

**Theorem 6.1 (Perfect seed).** *If $h$ is 2-universal and $|M| > t(t-1)$, then there is a seed $a$ for which the linear-scan code is honest, decodes every typical word correctly (zero failure on $T$), and costs exactly $t$ tests. Consequently there is a deterministic code with $P_{\text{fail}} \le \varepsilon$ whenever $\mu(T) \ge 1-\varepsilon$.*

*Proof.* Theorem 4.2 supplies the seed; Theorems 5.1, 5.3, 5.2 supply the three properties; Lemma 3.4 converts correctness on $T$ into the failure bound. $\square$

**Lemma 6.2 (Embedding an arbitrary source).** *Any finite $S$ embeds into $\mathbb{F}_p^{|S|}$ for any $p \ge 2$, since $|S| \le 2^{|S|} \le p^{|S|}$; and 2-universality is preserved by precomposition with an injection.*

**Theorem 6.3 (Quadratic-rate deterministic scheme).** *For every nonempty typical set $T$ of size $t$ in a finite source there exist a prime $p$ with $t^2 < p \le 2t^2$ and an explicit inner-product hash scheme over $\mathbb{F}_p$, with an explicit seed, whose code is honest, decodes every word of $T$ correctly, costs exactly $t$ candidate tests per decoding, and transmits one of only $p + 1 \le 2t^2 + 1$ symbols.*

*Proof.* Bertrand's postulate gives a prime $p$ with $t^2 < p \le 2t^2$. Embed $S$ into $\mathbb{F}_p^{|S|}$ (Lemma 6.2) and use the inner-product family, 2-universal by Theorem 4.3. Since $|T^{\ne}| = t^2 - t < t^2 < p = |\mathbb{F}_p|$, Theorem 6.1 applies. $\square$

**The price of explicitness.** Theorem 3.5 says $t$ symbols suffice information-theoretically (via a table). Theorem 6.3 achieves $p + 1 = \Theta(t^2)$ with no table at all — the *birthday penalty*: to make a random-like map injective on $t$ points one needs range $\gtrsim t^2$, because $\binom{t}{2}$ pairs each collide with probability $1/|M|$. In bits, the constructive scheme spends $2\log_2 t + O(1)$ where $\log_2 t$ would do: a factor-two rate loss bought in exchange for a compact, evaluable, table-free description. Whether the squaring is *necessary* for pairwise independent families is a precise open question (Section 9).

---

## 7. Decoder complexity: an exact cost and a universal converse

Rate is settled by Section 3; the operative obstacle is time. The linear-scan decoder costs $t$ tests — no better than exhaustive search over the typical set — and a naive random codebook is worse still. This section shows that a two-hash bucketed decoder achieves *constant* expected cost, computes that cost exactly, and proves a matching converse valid for all schemes.

### 7.1 The bucketed decoder

Recall the bucketed scheme: bucket hash $h_1$ with range $M_1$, $|M_1| = m_1$, checksum hash $h_2$, codeword $(h_1(x), h_2(x))$, candidates $\mathrm{cand}(m) = \{y \in T : h_1(y) = m_1\}$. Write
$$\mathrm{col}(a_1, x) \;=\; \#\{y \in T \setminus \{x\} : h_{1,a_1}(y) = h_{1,a_1}(x)\}$$
for the number of *false* candidates.

**Lemma 7.1 (Bucket size).** *For $x \in T$, the bucket containing $x$ has size $1 + \mathrm{col}(a_1, x)$, and this is exactly the decoder's cost when $x$ is transmitted.*

*Proof.* The bucket is $\{x\}$ together with the false candidates, and these are disjoint. Combine with Theorem 5.2. $\square$

**Lemma 7.2 (Expected false-candidate count).** *If $h_1$ is pairwise independent, then for every $x$,*
$$\frac{1}{|A_1|}\sum_{a_1 \in A_1} \mathrm{col}(a_1, x) \;=\; \frac{|T \setminus \{x\}|}{m_1},$$
*with "$\le$" in place of "$=$" if $h_1$ is merely 2-universal.*

*Proof.* Exchange the order of summation:
$$\sum_{a_1} \mathrm{col}(a_1, x) \;=\; \sum_{y \in T\setminus\{x\}} \#\{a_1 : h_{1,a_1}(y) = h_{1,a_1}(x)\} \;=\; \sum_{y \in T\setminus\{x\}} \frac{|A_1|}{m_1},$$
using pairwise independence for each of the $|T\setminus\{x\}|$ inner counts. Divide by $|A_1|$. $\square$

**Theorem 7.3 (Exact expected decoder cost).** *Let $h_1$ be pairwise independent with $m_1$ buckets and let $x \in T$, $t = |T|$. Then the expected number of candidate tests performed by the bucketed decoder when $x$ is transmitted, averaged over a uniform bucket-hash seed, is exactly*
$$\mathbb{E}[\mathrm{cost}] \;=\; 1 + \frac{t-1}{m_1}.$$

*Proof.* Average the identity of Lemma 7.1 over $a_1$ and insert Lemma 7.2. $\square$

Three consequences. (i) With $m_1 \ge t$, the expected cost is below $2$: *constant-time* decoding, against $t$ for the naive scan. (ii) Since Theorem 7.3 is an *identity*, the corresponding upper bound for 2-universal families is attained and cannot be improved within this class — any improvement must come from a family that is *not* pairwise independent, or from a different candidate structure. (iii) The checksum hash $h_2$ plays no part in the cost; its role is purely to keep the failure probability small (Theorem 5.4 applied to the product family) while the bucket hash keeps the work small. Rate and time are thereby controlled by two independent knobs, $|M_2|$ and $m_1$.

### 7.2 The universal converse

Is $1 + (t-1)/m_1$ near-optimal, or merely one scheme's performance? The following converse — which assumes nothing beyond Definition 2.9, and holds for *every* seed, not merely on average — settles it.

**Theorem 7.4 (Total-work lower bound; Cauchy–Schwarz over fibres).** *For every scan scheme with typical set $T$, $|T| = t$, codeword set $M$, and every seed $a$,*
$$\sum_{x \in T} \mathrm{cost}_a(h_a(x)) \;\ge\; \frac{t^2}{|M|}.$$

*Proof.* Partition $T$ into fibres $F_m = \{y \in T : h_a(y) = m\}$, $m \in M$, of sizes $n_m$ summing to $t$. If $x \in T$ then every $y \in F_{h_a(x)}$ is itself a typical word whose own codeword is $h_a(x)$, so by the axiom "the true word is always a candidate", $y \in \mathrm{cand}_a(h_a(y)) = \mathrm{cand}_a(h_a(x))$. Hence $F_{h_a(x)} \subseteq \mathrm{cand}_a(h_a(x))$ and $\mathrm{cost}_a(h_a(x)) \ge n_{h_a(x)}$. Summing over $x \in T$ and grouping by fibre,
$$\sum_{x \in T} \mathrm{cost}_a(h_a(x)) \;\ge\; \sum_{x \in T} n_{h_a(x)} \;=\; \sum_{m \in M} n_m^2 \;\ge\; \frac{1}{|M|}\Big(\sum_{m} n_m\Big)^2 \;=\; \frac{t^2}{|M|},$$
the middle inequality being Cauchy–Schwarz (equivalently, the power-mean inequality). $\square$

**Theorem 7.5 (Rate–time hyperbola).** *For every scan scheme with nonempty typical set and every seed, the average cost of decoding a typical word satisfies*
$$\frac{1}{t}\sum_{x \in T}\mathrm{cost}_a(h_a(x)) \;\ge\; \frac{t}{|M|}.$$
*Moreover every decoding costs at least one test.*

*Proof.* Divide Theorem 7.4 by $t$. The final claim holds because the true word is always a candidate, so no candidate set met in decoding a typical word is empty. $\square$

**Interpretation and optimality gap.** Writing $m = |M|$ for the number of codewords, Theorems 7.3 and 7.5 read
$$\underbrace{\max\Big(1, \frac{t}{m}\Big)}_{\text{unavoidable}} \;\le\; \mathbb{E}[\mathrm{cost}] \;\le\; \underbrace{1 + \frac{t-1}{m}}_{\text{achieved by bucketing}} .$$
The two differ by less than $1$ probe, uniformly in $t$ and $m$. So the bucketed decoder is optimal to within an additive constant, and — this is the structural content — *rate and time are conjugate*: compressing harder (small $m$) forces the decoder to sift a proportionally larger bucket ($\ge t/m$ tests). One cannot have both a $t$-symbol alphabet and sublinear decoding unless the candidate structure violates the (very weak) axioms of Definition 2.9. The table code escapes only because it uses $m = t$ codewords, where the hyperbola bottoms out at $1$.

---

## 8. Exact failure probability: from probability to projective geometry

The union bound of Theorem 4.1 is the standard tool, and like most union bounds it is loose. For the inner-product family in the plane, the exact answer can be computed, and it is a statement about *directions*, not pairs.

Throughout this section $p$ is prime, $S = \mathbb{F}_p^2$, $h_a(x) = \langle a, x\rangle$. For $z \ne 0$ let $z^{\perp} = \{a : \langle a, z\rangle = 0\}$, a line through the origin with exactly $p$ points (the kernel of a surjective functional on a $p^2$-element group). A seed $a$ is bad for $T$ iff $\langle a, x - y\rangle = 0$ for some pair of distinct $x, y \in T$, i.e. iff $a \in z^{\perp}$ for some difference direction $z$. Since $(\lambda z)^{\perp} = z^{\perp}$ for $\lambda \ne 0$, only the *projective* direction of $z$ matters.

**Lemma 8.1 (Two lines meet at the origin).** *If $z, w$ are nonzero and non-proportional (i.e. $z_0w_1 - z_1w_0 \ne 0$) then $z^{\perp} \cap w^{\perp} = \{0\}$.*

*Proof.* $a$ lies in both iff $a$ solves a $2\times2$ homogeneous linear system with nonzero determinant, forcing $a = 0$. $\square$

**Theorem 8.2 (Pencil count).** *Let $D$ be a nonempty set of pairwise non-proportional nonzero directions, $|D| = d$. Then*
$$\#\Big(\bigcup_{z \in D} z^{\perp}\Big) \;=\; 1 + d\,(p-1).$$

*Proof.* Each $z^{\perp}$ contains the origin and $p-1$ further points; by Lemma 8.1 the punctured lines $z^{\perp}\setminus\{0\}$ are pairwise disjoint. Hence the union has $1 + d(p-1)$ elements. $\square$

**Theorem 8.3 (Exact bad-seed count).** *Let $T \subseteq \mathbb{F}_p^2$ and let $D$ be a set of representatives for the projective directions realised by the differences of $T$: nonzero, pairwise non-proportional, covering every difference of distinct elements of $T$, and each genuinely occurring as such a difference. Then the number of seeds that collide on $T$ is exactly $1 + |D|(p-1)$.*

*Proof.* By the discussion above, the bad seeds are precisely $\bigcup_{z \in D} z^{\perp}$ — the covering hypothesis gives "$\subseteq$" and the realisability hypothesis gives "$\supseteq$". Apply Theorem 8.2. $\square$

**Theorem 8.4 (Exact planar failure probability).** *Under the hypotheses of Theorem 8.3 with $d = |D|$, a uniformly random seed is bad with probability exactly*
$$\frac{1 + d(p-1)}{p^2}.$$

*Since $d \le \binom{t}{2} = t(t-1)/2$, this never exceeds the union bound $t(t-1)/p$ by more than lower-order terms, and is strictly smaller as soon as two differences are proportional.*

**Worked example.** Let $p = 11$ and $T = \{(1,0), (0,1), (2,3)\} \subseteq \mathbb{F}_{11}^2$. Its three differences $(1,-1) = (1,10)$, $(-1,-3) = (10,8)$, $(-2,-2) = (9,9)$ are pairwise non-proportional, so $d = 3$ and Theorem 8.3 predicts exactly $1 + 3\cdot 10 = 31$ bad seeds among the $121$. Exhaustive enumeration of all $121$ seeds confirms the count is $31$, so the failure probability is exactly $31/121 \approx 0.2562$. The union bound of Theorem 4.1 gives $|T^{\ne}|/p = 6/11 = 66/121 \approx 0.5455$ — loose by a factor $2.13$.

**Why this reframing matters.** "Probability that a random seed collides" has become "normalised measure of a pencil of hyperplanes". Lower bounds on the number $d$ of distinct projective directions of a difference set — a purely geometric quantity, governed by results in additive combinatorics — become lower bounds on the failure probability, and hence lower bounds on the range $|M|$ that a pairwise independent family must use. This is the route towards proving that the quadratic penalty of Theorem 6.3 is *necessary* rather than merely convenient (Section 9).

---

## 9. Discussion, open problems, and future work

### 9.1 What the results say together

* **Rate.** The pigeonhole bound relaxes exactly to the concentration function of the source (Theorem 3.5). It does not relax at all for a uniform source (Theorem 3.2), and shared randomness cannot change this for any source (Theorems 3.3, 3.7).
* **Construction.** Hashing recovers near-optimality without tables, at a quadratic rate penalty, with unconditional honesty (Theorems 5.4, 6.3).
* **Time.** Rate and decoding time obey a hyperbola $\mathbb{E}[\mathrm{cost}] \ge \max(1, t/m)$, achieved to within an additive $1$ by bucketing (Theorems 7.3, 7.5).
* **Exactness.** In the plane, the Monte Carlo failure probability is not merely bounded but computed, by a projective count (Theorem 8.4).

Notably, all failure modes are *detected*. Honesty holds for every seed and requires no assumption about the hash quality (Theorem 5.1), and it costs one alphabet symbol (Theorem 3.8). The falsifiability gate posed for this line of work — "for each scheme: a bound on the failure probability and an explicit decoder-complexity figure; no silent corruption allowed" — is met by each scheme presented: table code ($P_{\text{fail}} \le \varepsilon$, cost $1$, alphabet $t+1$); linear-scan Monte Carlo scheme ($P_{\text{fail}} \le \varepsilon + t(t-1)/|M|$, cost exactly $t$, alphabet $|M|+1$); derandomised inner-product scheme ($P_{\text{fail}} \le \varepsilon$ deterministically, cost exactly $t$, alphabet $\le 2t^2+1$); bucketed scheme (same failure bound for the product family, expected cost exactly $1 + (t-1)/m_1$).

### 9.2 Algorithmic summary

Encoding is always $O(k)$ field operations (one inner product). Decoding is: $O(1)$ table lookup for the table code; exactly $t$ tests for the linear scan; expected $1 + (t-1)/m_1$ tests for the bucketed decoder, after an $O(t)$ precomputation of the index of $T$ (which is a one-time cost shared by encoder and decoder, and is the analogue of the codebook). Derandomisation, when performed by exhaustive search over seeds, costs $O(|A| \cdot t \log t)$ in the worst case but succeeds after $O(1)$ expected random trials once $|M| > 2t(t-1)$, since then at least half of the seeds are good.

### 9.3 Future directions

**FD1 — The birthday penalty is unavoidable for pairwise-independent codebooks.**
*Conjecture.* Let $h$ be a pairwise independent hash family (an equality, not merely the 2-universal inequality). Then for every $T$ with $|T| \le \sqrt{|M|}$ the probability that a uniform seed is injective on $T$ satisfies $P(\text{injective on } T) \le \exp(-c\,|T|^2/|M|)$ whenever the difference set of $T$ has $\Omega(|T|^2)$ distinct projective directions. Consequently no pairwise independent family attains the information-theoretic alphabet size $|T|$, and the squaring in the explicit quadratic-rate scheme is necessary in this class.
*Key insight.* The exact planar count ($1 + d(p-1)$ bad seeds for $d$ projective directions) turns "probability of a collision" into "measure of a pencil of hyperplanes", so lower bounds on $d$ — a purely projective-geometric quantity — become lower bounds on the failure probability.
*Why now.* The planar case is already an equality, proved and cross-checked numerically; the only missing ingredient is inclusion–exclusion over the subspace lattice in dimension $k \ge 3$, where current data show the naive formula fails.

**FD2 — Exact failure probability in all dimensions via the subspace lattice.**
*Conjecture.* For the inner-product family over $\mathbb{F}_p^k$ and a typical set $T$ whose difference directions span the subspaces $V_1, \dots, V_d$, the number of bad seeds equals
$$\sum_{\emptyset \ne I \subseteq [d]} (-1)^{|I|+1}\, p^{\,k - \dim \mathrm{span}\{z_i : i \in I\}},$$
i.e. the Möbius function of the lattice of subspaces generated by the directions governs the exact failure probability.
*Key insight.* $\{a : \langle a, z\rangle = 0\}$ is a hyperplane and the bad set is a union of hyperplanes, so the exact count is a matroid/Möbius computation over $\mathbb{F}_p$, not a probabilistic estimate: the union bound is precisely the first Bonferroni term of this expansion.
*Why now.* The $k = 2$ instance is already proved (pairwise intersections trivial $\Rightarrow$ the Möbius expansion truncates), and the failure of the naive formula at $p = 13$, $k = 3$ isolates exactly the missing higher-order terms.

**FD3 — Constant-time decoding at optimal rate.**
*Conjecture.* There is an explicit scheme with codeword alphabet of size $(1 + o(1))|T|$ — matching the exact relaxed pigeonhole bound, with no squaring — whose decoder performs $O(1)$ expected candidate tests, obtained by composing a bucket hash of range $|T|$ with a rate-optimal index inside each bucket. Note that the rate–time hyperbola permits this: at $m = t$ the lower bound on expected cost is exactly $1$. The obstruction is not information-theoretic but constructive, namely exhibiting an explicit family whose bucket occupancies are simultaneously near-uniform and cheaply invertible.

**Further threads.** (a) Extend the exact-count programme to affine (non-homogeneous) families $h_a(x) = \langle a, x \rangle + b$, where the bad set becomes a union of affine hyperplanes and the Möbius computation acquires a geometric-lattice flavour. (b) Quantify the rate–time hyperbola in *bits*: since $\log_2 m + \log_2 \mathbb{E}[\mathrm{cost}] \ge \log_2 t$, the sum of transmitted bits and decoding-search bits is bounded below by the entropy-like quantity $\log_2 t$, suggesting a conservation law worth stating intrinsically. (c) Multi-shot and streaming variants, where the typical set is a product set and the index admits a factored representation, potentially decoupling $t$ from the storage cost of the codebook. (d) Adversarial seeds: replace the average over seeds by a worst-case guarantee under a computational assumption, retaining unconditional honesty as the safety net.

---

## 10. Conclusion

Relaxing exact decoding to $\varepsilon$-reliable decoding does not so much weaken the pigeonhole bound as *change its subject*: from the cardinality of the source alphabet to the concentration of the source distribution. Randomness — the traditional protagonist of achievability arguments — turns out to contribute nothing to rate, in any setting, and to serve only as a device for avoiding an explicit search. What it does not eliminate is time. Once one insists on decoding quickly, a second and independent conservation law appears, with rate and expected decoding work bounded below along a hyperbola, and a simple two-hash bucketed decoder sitting within a single probe of that boundary while announcing every one of its failures.
