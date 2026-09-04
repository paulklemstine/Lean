# The Right to Say "I Don't Know"

### Sharp constants for almost-lossless compression, and why a decoder must be allowed to abstain

---

## 1. Two ways of being wrong

Any system that stores messages in less space than their information content will sometimes be wrong. What matters is *how*.

- **Loud failure.** The decoder cannot determine which message produced the stored code, and says so. Somebody retransmits; a fallback fires; a log line appears. An inconvenience.
- **Silent corruption.** The decoder confidently returns the *wrong* message. Nobody is told. The error propagates downstream as if it were ground truth. A catastrophe wearing the costume of a success.

Classical information theory bundles both into one number, "error probability". This page pulls them apart. By the end you will know exactly how cheaply silent corruption can be bought, what it costs in loud failures, and why the entire enterprise collapses if the decoder is forbidden to answer *"I don't know."*

---

## 2. The scheme, in one picture

Fix a finite alphabet $\mathcal{X}$ with a probability distribution $\mu$. Real sources are lopsided: a **codebook** $l$ of distinct typical messages carries almost all the mass, and the rest — the *atypical* residue — has mass at most $\delta$:

$$\mu(\mathcal{X}\setminus l) \le \delta .$$

The encoder is a hash. Fix a family $H_1,\dots,H_K:\mathcal{X}\to\{1,\dots,M\}$ that is **2-universal**: for any two distinct messages, at most a $1/M$ fraction of keys makes them collide. (The affine maps $x\mapsto ((ax+b)\bmod p)\bmod M$ over a prime field are the textbook example.) Choosing a key $k$ chooses an encoder $x\mapsto H_k(x)$; that number is the whole compressed representation.

The decoder scans the codebook once and collects every entry hashing to the received codeword.

- **Exactly one** match → output it.
- **Zero or several** matches → output nothing. *Abstain.*

The scan costs exactly $|l|$ hash evaluations, every time, with no adaptivity.

<details>
<summary><b>Why silent corruption is a second-order event</b> (click to reveal the two structural lemmas)</summary>

**Success on the codebook.** If $x\in l$ and no other codebook entry shares its hash, the match set is exactly $\{x\}$, so the decoder returns $x$.

**Silent errors need two coincidences.** Suppose the decoder returns $y\ne x$. Then $y\in l$ and $H_k(y)=H_k(x)$, so $x$ collides with the codebook. Moreover $x\notin l$: if $x$ were in the codebook it would itself be a match, so the decoder would either return $x$ or see several matches and abstain — it could never return a different symbol.

So a silent corruption requires *both* an atypical message *and* a hash collision, while a loud failure needs only one of the two. This conjunction is why the silent-error probability carries a factor $\delta$ that the failure probability does not, and it is the entire source of the asymmetry exploited below.
</details>

Write $L=|l|/M$ for the **load**, the natural collision-rate parameter. A freshly drawn random key gives, on average, collision mass at most $L$ overall and at most $\delta L$ inside the atypical region. But randomness at decode time is a luxury — the decoder must know the key. We want **one fixed key** that is good for both events at once.

---

## 3. From averages to a single key

Averaging says the mean is small; it does not hand you a key. Markov's inequality does the rest. Call a key *bad at level $c$ for region $A$* if its collision mass inside $A$ exceeds $c$ times the average. Then **strictly fewer than $K/c$ keys are bad** — the strictness matters, and it is what lets the argument work exactly at the boundary.

Two demands, two bad sets, densities below $1/c_2$ (whole space, governing failure) and $1/c_1$ (atypical region, governing silence). They cannot fill the key space as soon as

$$\frac{1}{c_1}+\frac{1}{c_2}\;\le\;1 ,$$

the **fractional covering condition**. The surviving key gives failure $\le \delta + c_2 L$ and silent corruption $\le c_1\delta L$, at cost exactly $|l|$.

This is the algorithm; it is worth reading once in full.

{{algorithm:0}}

---

## 4. Where on the frontier should you sit?

The admissible pairs form a region bounded by the hyperbola $c_2 = c/(c-1)$, and **every point of it is realised by an actual key**. Slide along it in the explorer below and watch the two bounds trade against each other. Two landmarks are worth visiting: the symmetric point $(2,2)$, and the balanced optimum.

{{interactive_demo:0}}

The total error is $\delta + (c_2+c_1\delta)L$, so the whole design question is: minimise $c_2+c_1\delta$ over the admissible region. The answer is exact.

> **Frontier Optimality.** For every admissible pair, $\;c_2+c_1\delta \ge (1+\sqrt{\delta})^2$, with equality precisely at $c_1 = 1+\frac{1}{\sqrt\delta}$, $c_2 = 1+\sqrt{\delta}$.

<details>
<summary><b>The one-line proof</b> (click to reveal the perfect-square identity)</summary>

Put $s=\sqrt\delta$. For all nonzero $c_1,c_2$,

$$\big(c_2 + c_1 s^2\big)\left(\frac{1}{c_1}+\frac{1}{c_2}\right) \;=\; (1+s)^2 \;+\; \frac{(c_2-c_1 s)^2}{c_1c_2}.$$

Clear denominators and expand to check it. Inside the admissible region the second factor on the left is at most $1$, so the left side is at most $c_2+c_1s^2$; the last term on the right is a perfect square, hence nonnegative. Therefore $(1+s)^2 \le c_2 + c_1\delta$.

Because the excess is a *perfect square*, equality forces two things at once: $c_2 = c_1\sqrt\delta$ (the balanced ray) and $\frac1{c_1}+\frac1{c_2}=1$ (the boundary). Their intersection determines the optimum uniquely. This is a sharp form of [Cauchy–Schwarz](https://en.wikipedia.org/wiki/Cauchy%E2%80%93Schwarz_inequality); the equivalent [AM–GM](https://en.wikipedia.org/wiki/AM%E2%80%93GM_inequality) computation on the one-parameter family $c_1=1+\eta$, $c_2=1+1/\eta$ gives the excess $\frac{L}{\eta}(1-\eta\sqrt\delta)^2$, vanishing exactly at $\eta=1/\sqrt\delta$.
</details>

Substituting the optimum gives the headline scheme.

> **The $\sqrt{\delta}$-Balanced Scheme.** A single explicit key achieves, at once:
> failure probability $\le \delta + (1+\sqrt\delta)\frac{|l|}{M}$; silent corruption $\le (\sqrt\delta+\delta)\frac{|l|}{M}$; total error $\le \delta + (1+\sqrt\delta)^2\frac{|l|}{M}$; decoding cost exactly $|l|$.

As the source gets cleaner, $\delta\to0$, the failure constant $1+\sqrt\delta\to 1$ — the value a *freshly random* key would give, so derandomization becomes free — while the silent constant $\sqrt\delta+\delta\to0$. **Both** limits at once, which no fixed point of the hyperbola achieves. The picture below shows the geometry on the left and the two limits on the right.

{{visualization:0}}

---

## 5. Where the method stops

A pleasant surprise: the covering condition is not an artefact of the proof, it is exactly the edge.

> **Necessity.** If $K\big(\frac1{c_1}+\frac1{c_2}-1\big)>1$, there are two blocks of keys, each *strictly* below its Markov threshold, whose union is the entire key space.

<details>
<summary><b>The construction</b> (click to reveal — it is three lines)</summary>

Cut the keys at $n=\lceil K/c_1\rceil-1$. The lower block $\{k<n\}$ has $n<K/c_1$ elements, so $|B_1|c_1<K$. The upper block has $K-n$ elements; from $n\ge K/c_1-1$ and the density excess $1<\frac{K}{c_1}+\frac{K}{c_2}-K$ we get $K-n \le K-\frac{K}{c_1}+1 < \frac{K}{c_2}$, so $|B_2|c_2<K$. Together they cover.
</details>

So no union-bound argument at inadmissible thresholds can ever produce a good key. The value $(1+\sqrt\delta)^2$ is the best point on a frontier whose location is itself a theorem.

---

## 6. The punchline: abstention is not optional

Everything so far assumed the decoder may say "I don't know". Is that a convenience? Play with the laboratory below — two decoders, the *same* encoder and the *same* codewords, one allowed to abstain and one forced to commit — and watch where the probability mass goes.

{{interactive_demo:1}}

What you are seeing is a conservation law. Let $p_{\max}$ be the largest atom of the source. Correct decoding is injective on the set of successfully decoded messages, so that set has at most $M$ elements and carries mass at most $Mp_{\max}$. Every message is decoded correctly, abstained on, or silently corrupted — a trichotomy. Hence:

> **Abstention Trade-off.** For *every* encoder–decoder pair over a code of size $M$,
> $$\Pr[\text{silent}] + \Pr[\text{abstain}] \;\ge\; 1 - M\,p_{\max}.$$

There is a fixed budget of "mass the code cannot carry", and you choose only how to spend it. Forbid abstention and it all lands in one place:

> **Committing decoders must lie.** A decoder that never abstains has silent-corruption probability at least $1-Mp_{\max}$ — at least $\tfrac12$ in the genuinely compressive regime $Mp_{\max}\le\tfrac12$.

Half the time, confidently, with no warning — and this holds for *arbitrary* encoders and decoders, not just hash-based ones. Put it beside the achievability result and you get a separation with an unbounded ratio: with abstention, silent corruption at most $(\sqrt\delta+\delta)|l|/M$, which can be made as small as you like; without it, at least $\tfrac12$.

{{visualization:1}}

<details>
<summary><b>The decoders and the exact measurement code</b></summary>

{{algorithm:1}}
</details>

---

## 7. Fairness: every group, not just the average

Counting arguments are not limited to two regions. For any regions $A_1,\dots,A_r$ with thresholds satisfying $\sum_i 1/c_i \le 1$, one key is good on all of them. Applied to protected subpopulations $G_1,\dots,G_r$ with the uniform threshold $r+1$:

> **Group-wise Silent-Error Control.** A single key gives global failure $\le\delta+(r+1)\frac{|l|}{M}$ and, for *every* group $g$,
> $$\Pr[\text{silent corruption inside }g]\;\le\;(r+1)\,\mu(g\setminus l)\,\frac{|l|}{M}.$$

The bound is **local**: it depends on the mass of the part of *that* group the codebook misses, not on the worst group. An aggregate silent-error certificate can hide a subgroup being corrupted ten times more often than average; this one cannot. The price for $r$ groups plus the global event is the single factor $r+1$, coming from $\sum_{i=1}^{r+1}\frac{1}{r+1}=1$.

{{algorithm:2}}

---

## 8. Tags: exponential suppression for free

Append a short **tag** — a second hash with an *independent* key into $\{1,\dots,T\}$. A silent corruption now needs the codeword *and* the tag to collide. This rests on a clean structural fact: **the product of two 2-universal families is 2-universal**, with the densities $1/M$ and $1/T$ multiplying exactly. So the tagged balanced scheme achieves silent corruption $\le(\sqrt\delta+\delta)\frac{|l|}{MT}$ and failure $\le\delta+(1+\sqrt\delta)\frac{|l|}{MT}$, with the scan still costing exactly $|l|$. With $T=2^t$: silent corruption is exponentially rare in the tag length. Operationally the tag converts would-be lies into detected failures — it moves mass from the "confident lie" bucket into the "I don't know" bucket, which section 6 shows is the only other place it can go. (The tag slider in the frontier explorer above lets you watch the bound fall.)

---

## 9. Run everything yourself

The complete numerical companion: the frontier and its optimum, the AM–GM identity, an end-to-end simulation with exact measurement against every proved bound, the abstention separation, the interval-splitting counterexample, and the tag scaling.

{{demo:0}}

---

## 10. What to take away

- Silent corruption and loud failure are different failure modes and deserve different constants. With a codebook of defect $\delta$ and load $L=|l|/M$, one fixed key buys silent corruption $(\sqrt\delta+\delta)L$ and failure $\delta+(1+\sqrt\delta)L$ simultaneously.
- $(1+\sqrt\delta)^2$ is the exact optimum of the counting method, proved by a perfect-square identity; the naive hope of the pair $(1,\delta)$ is impossible, since driving the failure constant to $1$ sends the silent constant to infinity.
- The method's boundary is itself a theorem: past the covering condition, bad-key sets of the permitted densities provably cover the key space.
- And the reject option is not politeness. It is the only mechanism by which a system operating below its information budget avoids being confidently wrong a constant fraction of the time.

Further reading on the ingredients: [universal hashing](https://en.wikipedia.org/wiki/Universal_hashing), [min-entropy](https://en.wikipedia.org/wiki/Min-entropy), [asymptotic equipartition and typical sets](https://en.wikipedia.org/wiki/Asymptotic_equipartition_property), and [classification with a reject option](https://en.wikipedia.org/wiki/Selective_classification).
