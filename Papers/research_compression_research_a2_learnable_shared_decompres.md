# Amortized Model-Delta Compression: A Min-Plus Theory of Shared, Adaptable Decompressors

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

A fixed, shared, pretrained decompressor combined with an arithmetic-coded residual is an
extremely strong lossless compressor for structured data such as natural-language text.
The scientific difficulty is that the decompressor is not free when it must be *steered*:
the domain-adaptation patch — a low-rank adapter, a sparse weight difference, a codebook,
a dictionary — is itself a transmitted bitstring and must be charged to the message. This
paper develops a complete and sharp theory of that trade-off in a deliberately austere
model: a finite set $M$ of decoder states, a *model-delta cost* $\delta : M \times M \to
\mathbb{N}$ giving the bits needed to move the shared decoder between states, and
per-message *residual costs* $c : M \to \mathbb{N}$ giving the bits needed to code a
message in a given state. The protocol optimum is the minimum, over all schedules of
decoder states, of the total transmitted bits.

We prove: (i) **Bellman optimality** — the min-plus dynamic program is exactly the protocol
optimum, attained by an explicit schedule; (ii) a **sharp amortization law** — for a
coherent stream of $n$ messages the optimum is exactly $n r + \min(D, n)$ bits, whence the
break-even point is *exactly* at $n = D$ and the amortized rate tends to $r$; (iii) an
**information-theoretic floor** — by pigeonhole, every lossless scheme, delta included,
spends at least $n s$ bits on some stream from a $2^s$-symbol alphabet, so the amortized
protocol sits within $D$ bits of optimal uniformly in $n$; (iv) a **constructive
losslessness gate** — an explicit shared codec that reconstructs an entire stream exactly;
(v) a **tropical bridge** — the dynamic program is literally a power of a min-plus matrix,
so the amortized rate is the growth rate of tropical matrix powers; (vi) the **coherence-
length law** — for a stream of $B$ blocks of $L$ messages with alternating domain, the
optimum is exactly $B L r + \lfloor B/2 \rfloor \min(2D, L) + (B \bmod 2)\min(D, L)$, so
the amortized excess is $\min(2D, L)/(2L)$ bits per message and the delta amortizes against
the *coherence length*, not the stream length; and (vii) a **logarithmic warm-up bound** —
a decompressor steerable to $K$ domains has a domain whose patch exceeds $\log_2 K$ bits
and which therefore shows no gain at all over the generic decoder for its first
$\approx \log_2 K$ messages.

**Keywords:** min-plus semiring, tropical algebra, lossless compression, amortized
analysis, model delta, dynamic programming, coherence length, pigeonhole bound, minimum
description length.

---

## 1. Introduction

### 1.1 The decompressor is a program

Every lossless compressor is a pair: a *program* (the decompressor) and *data* (the
compressed bitstring). Classical compressors keep the program tiny and fixed — a
Lempel–Ziv window, a Burrows–Wheeler transform, a context-mixing ensemble — and pour all
their effort into the data. Modern neural compressors invert the ratio. A pretrained
sequence model, used as a conditional probability oracle for an arithmetic coder, achieves
residual rates on text far below classical baselines, at the price of a program measured
in gigabytes.

This inversion is legitimate provided one is honest about accounting. Two accounting
regimes are commonly conflated:

* **Fixed shared decompressor.** Sender and receiver agree at deployment time on a
  universal artifact; it is negotiated once, never transmitted, and identical for all
  users. Charging for it would be like charging every HTTP request for the source code of
  the browser. Under this regime the compressed size is the residual stream alone.
* **Steered decompressor.** The sender improves the shared artifact for the domain at hand
  by transmitting a patch. The patch *is* part of the message and must be charged.

The first regime is uncontroversial but static. The second is where all the engineering
interest lies, and where the theory has been thin. This paper supplies the theory for the
second regime, in a form sharp enough to yield exact break-even points and exact amortized
rates.

### 1.2 Contributions

We isolate the problem as a scheduling problem over decoder states and solve it exactly in
several regimes. The technical backbone is that both operations involved — accumulating
cost along a schedule and minimizing over schedules — are the two operations of the
min-plus (tropical) semiring, so the theory is genuinely tropical rather than merely
analogous to it.

Section 2 fixes the model and proves Bellman optimality. Section 3 proves the sharp
amortization law and its corollaries (break-even, short-stream futility, asymptotic
freeness, concavity). Section 4 proves the counting floor and constructs an exactly
lossless codec meeting it up to the delta. Section 5 makes the tropical identification
literal. Section 6 establishes the coherence-length law, including the fully incoherent
extreme. Section 7 counts patches and derives the logarithmic warm-up. Section 8 collects
structural laws (superadditivity, monotonicity, no-gain-from-routing). Sections 9–11 give
algorithms, applications, and open problems.

### 1.3 Relation to classical ideas

The trade-off "model bits plus data bits" is the *minimum description length* principle,
and the ultimate version of the question — how few bits describe an object at all — is
Kolmogorov complexity, uncomputable in general. The contribution here is orthogonal to
both: we take the residual rates as given (they are what a real coder measures) and ask
for the *optimal dynamics* of model changes over a stream. That question has a clean,
computable, and sharp answer, and its answer is a shortest path.

---

## 2. The model and Bellman optimality

### 2.1 Costs

Throughout, $M$ is a finite nonempty set of **decoder states**. A state is any
configuration the shared decompressor can be placed in: the pretrained model as shipped,
or the pretrained model plus a specific patch. All costs are nonnegative integers of bits.

**Definition 2.1 (Model-delta cost).** A *model-delta cost* is a function
$\delta : M \times M \to \mathbb{N}$, where $\delta(m, m')$ is the number of bits that must
be transmitted to move the shared decoder from state $m$ to state $m'$. We say the delta
cost is *reflexive-free* if $\delta(m,m) = 0$ for all $m$: staying put costs nothing.

**Definition 2.2 (Residual cost).** A *residual cost* is a function $c : M \to \mathbb{N}$,
where $c(m)$ is the number of bits needed to code one particular message when the decoder
is in state $m$. A *stream* is a finite list $\mathbf{c} = (c_1, \dots, c_n)$ of residual
costs, one per message.

**Definition 2.3 (Schedule and its cost).** Given a starting state $p$ and a stream of
length $n$, a *schedule* is a list $\mathbf{m} = (m_1, \dots, m_n) \in M^n$ of decoder
states, one per message. Its cost is
$$\mathrm{sched}(p, \mathbf{c}, \mathbf{m}) \;=\; \sum_{i=1}^{n}\Big(\delta(m_{i-1}, m_i) + c_i(m_i)\Big), \qquad m_0 := p.$$

Each step pays first the model delta for the switch, then the residual for the message.

**Definition 2.4 (Protocol optimum).** The *protocol optimum* $V_\delta(p, \mathbf{c})$ is
defined by the recursion
$$V_\delta(p, ()) = 0, \qquad V_\delta(p, c :: \mathbf{c}) = \min_{m \in M}\Big(\delta(p,m) + c(m) + V_\delta(m, \mathbf{c})\Big),$$
where $c :: \mathbf{c}$ denotes prepending. The minimum exists because $M$ is finite and
nonempty.

Definition 2.4 defines a dynamic program; that it computes the *optimum over schedules* is
the content of the next theorem.

### 2.2 Bellman optimality

**Theorem 2.5 (Bellman optimality).** For every starting state $p$ and every stream
$\mathbf{c}$ of length $n$, the value $V_\delta(p,\mathbf{c})$ is the least element of the
set of schedule costs:
$$V_\delta(p,\mathbf{c}) \;=\; \min\{\,\mathrm{sched}(p,\mathbf{c},\mathbf{m}) : \mathbf{m} \in M^n\,\},$$
and the minimum is attained by an explicitly constructible schedule.

*Proof sketch.* Two inductions on the stream.

*Lower bound.* For any schedule $(m_1, \dots, m_n)$, unfold one step: the recursion's
minimum is at most the term indexed by $m_1$, namely $\delta(p, m_1) + c_1(m_1) +
V_\delta(m_1, (c_2,\dots,c_n))$. The inductive hypothesis bounds $V_\delta(m_1, \cdot)$ by
the cost of the schedule tail. Adding gives $V_\delta(p, \mathbf{c}) \le
\mathrm{sched}(p,\mathbf{c},\mathbf{m})$.

*Attainment.* Since $M$ is finite and nonempty, the minimum in the recursion is achieved at
some $m_1$. Recursing produces a schedule whose cost is exactly $V_\delta(p, \mathbf{c})$
by construction. Combining the two gives the least-element statement. $\square$

Theorem 2.5 is what licenses all subsequent computations: every bound we prove about
$V_\delta$ is a bound about *every possible protocol*, not merely about the particular
greedy strategies a designer might think of.

### 2.3 Two universal bounds

**Proposition 2.6 (Pay the delta once).** Assume $\delta$ is reflexive-free. For every
target state $m$, every stream $\mathbf{c}$ and every start $p$,
$$V_\delta(p, \mathbf{c}) \;\le\; \delta(p,m) + \sum_{i=1}^{n} c_i(m).$$

*Proof sketch.* Induct on the stream, at each step choosing $m$ in the recursion's
minimum. The first step pays $\delta(p,m)$; every later step pays $\delta(m,m) = 0$. $\square$

This is the *amortized protocol* in its most general form: switch once, then never switch
again.

**Proposition 2.7 (The residual rate is a floor).** If $r \le c_i(m)$ for every message
index $i$ and every state $m$, then for every $p$,
$$n \, r \;\le\; V_\delta(p, \mathbf{c}).$$

*Proof sketch.* Induct on the stream. In the recursion, every branch pays $c_1(m) \ge r$
plus a continuation value which by hypothesis is at least $(n-1)r$; hence every branch is
at least $nr$, hence so is their minimum. $\square$

Propositions 2.6 and 2.7 are the two jaws of the vice. Everything sharp below comes from
closing them on each other.

---

## 3. The sharp amortization law

We now specialize to the fundamental scenario: a **coherent stream** of $n$ statistically
identical messages, i.e. $c_1 = \cdots = c_n = c$.

### 3.1 Standing hypotheses

Fix $r, D \in \mathbb{N}$ and a residual cost $c$, and assume:

* **(H1) Rate floor.** $r \le c(m)$ for all $m \in M$. Call a state *specialized* if
  $c(m) = r$, i.e. if it attains the floor.
* **(H2) Delta is unavoidable.** For all $m, m'$: if $m'$ is specialized and $m$ is not,
  then $D \le \delta(m, m')$. Entering the good state from a bad one costs at least $D$.
* **(H3) Delta is achievable.** There is a specialized state $g$ with $\delta(p, g) \le D$
  from the start state $p$.
* **(H4) Generic start.** $c(p) = r + 1$: the pretrained model out of the box is exactly
  one bit per message worse than the adapted one.
* **(H5) Staying is free.** $\delta(m,m) = 0$ for all $m$.

Hypothesis (H4) normalizes the per-message advantage of specialization to one bit; this is
a choice of unit, not a loss of generality, since costs may be measured in units of the
advantage.

### 3.2 Upper and lower bounds

**Proposition 3.1 (Amortized upper bound).** Under (H3), (H5),
$$V_\delta(p, c^{\,n}) \;\le\; D + n\,r,$$
where $c^{\,n}$ denotes the stream of $n$ copies of $c$.

*Proof sketch.* Apply Proposition 2.6 with target $g$, then use $c(g) = r$ and
$\delta(p,g) \le D$. $\square$

**Theorem 3.2 (Delta lower bound).** Assume (H1) and (H2). Then for every $n$ and every
non-specialized start state $p$ (i.e. $c(p) \ne r$),
$$n\,r + \min(D, n) \;\le\; V_\delta(p, c^{\,n}).$$

*Proof sketch.* Induction on $n$. The case $n=0$ is trivial. For $n+1$ messages, the
recursion minimizes over the state $m$ chosen for the first message, and we bound every
branch:

* *Branch A: $m$ is specialized* ($c(m) = r$). By (H2), $\delta(p,m) \ge D$, and by
  Proposition 2.7 the remaining $n$ messages cost at least $nr$. Total:
  $\ge D + r + nr = (n+1)r + D \ge (n+1)r + \min(D, n+1)$.
* *Branch B: $m$ is not specialized* ($c(m) \ne r$). By (H1) and integrality,
  $c(m) \ge r+1$. The inductive hypothesis applies at $m$ (which is non-specialized), so
  the tail costs at least $nr + \min(D,n)$. Total:
  $\ge (r+1) + nr + \min(D,n) = (n+1)r + 1 + \min(D,n) \ge (n+1)r + \min(D, n+1)$.

Both branches dominate $(n+1)r + \min(D, n+1)$, hence so does the minimum. $\square$

The dichotomy in the proof is the mathematical content of the slogan: *either you pay the
delta once, or you pay one extra bit per message*. There is no third behaviour, and the
lower bound simply records that the cheaper of the two options is $\min(D, n)$.

### 3.3 The sharp law and its corollaries

**Theorem 3.3 (Sharp amortization law).** Under (H1)–(H5), for every $n \in \mathbb{N}$,
$$\boxed{\;V_\delta(p, c^{\,n}) \;=\; n\,r + \min(D, n).\;}$$

*Proof sketch.* The lower bound is Theorem 3.2, applicable since $c(p) = r+1 \ne r$. For
the upper bound, combine two protocols: Proposition 3.1 gives $\le D + nr$, and
Proposition 2.6 with target $p$ itself gives $\le 0 + n\,c(p) = n(r+1) = nr + n$. Hence the
optimum is at most $nr + \min(D, n)$. Antisymmetry closes the proof. $\square$

**Corollary 3.4 (Exact break-even).** Under (H1)–(H5),
$$V_\delta(p, c^{\,n}) < n(r+1) \iff D < n.$$
The adaptive protocol strictly beats the delta-free generic protocol precisely when the
stream is strictly longer than the model delta.

**Corollary 3.5 (Short streams gain nothing).** If $n \le D$ then $V_\delta(p, c^{\,n}) =
n(r+1)$ exactly: the optimum coincides with the generic protocol and the specialized state
is never entered.

**Theorem 3.6 (Asymptotic freeness of the model delta).** Under (H1), (H3), (H5),
$$\lim_{n \to \infty} \frac{V_\delta(p, c^{\,n})}{n} \;=\; r.$$

*Proof sketch.* Squeeze. Proposition 2.7 gives $V/n \ge r$; Proposition 3.1 gives
$V/n \le r + D/n$; and $D/n \to 0$. Note this uses only (H1), (H3), (H5) — no sharpness
hypotheses — and holds for arbitrarily large $D$. $\square$

**Proposition 3.7 (Economies of scale).** In the sharp regime the optimum is concave in
stream length:
$$V(n) + V(n+2) \;\le\; 2\,V(n+1).$$
Equivalently, the marginal cost of one more message is non-increasing.

*Proof sketch.* Substitute the closed form $V(n) = nr + \min(D,n)$; concavity reduces to
concavity of $n \mapsto \min(D,n)$, which is immediate. $\square$

### 3.4 Non-vacuity: an explicit two-state witness

The hypotheses (H1)–(H5) are not vacuous. Take $M = \{\mathsf{gen}, \mathsf{spec}\}$ with

$$c(\mathsf{spec}) = r, \qquad c(\mathsf{gen}) = r+1, \qquad
\delta(m, m') = \begin{cases} D & \text{if } m = \mathsf{gen},\ m' = \mathsf{spec}, \\ 0 & \text{otherwise.}\end{cases}$$

All five hypotheses hold, and consequently
$$V_\delta(\mathsf{gen}, c^{\,n}) = n r + \min(D, n)$$
exactly, with the break-even characterization of Corollary 3.4. Every subsequent
quantitative claim about the two-state model — including the tropical closed form of
Section 5 and the warm-up bound of Section 7 — is instantiated in this concrete witness.

---

## 4. The information-theoretic floor and the losslessness gate

The results of Section 3 compare protocols to each other. This section compares them to
the truth.

### 4.1 Counting bitstrings

**Lemma 4.1.** The set of bitstrings of length at most $t$ has exactly $2^{t+1} - 1$
elements.

*Proof sketch.* Induction on $t$: the strings of length $\le t+1$ are the empty string
together with the two disjoint injective images of the strings of length $\le t$ under
prepending $0$ and prepending $1$. Hence $N_{t+1} + 1 = 2(N_t + 1)$ with $N_0 + 1 = 2$. $\square$

**Theorem 4.2 (Compressible sources are exponentially rare).** Let $\mathrm{enc}$ be any
injective map from a finite set of sources into bitstrings. Then the number of sources
$a$ with $|\mathrm{enc}(a)| \le t$ is at most $2^{t+1} - 1$.

*Proof sketch.* Injectivity makes $\mathrm{enc}$ a bijection onto its image, and that image
lies inside the set counted by Lemma 4.1. $\square$

Injectivity is exactly losslessness: if two sources shared a codeword the decoder could not
distinguish them. Note what the theorem does *not* assume — nothing whatever about the
decompressor. It may be a table, a context mixer, or a sixteen-gigabyte transformer.

**Corollary 4.3 (Pigeonhole bound).** If there are at least $2^{t+1}$ distinct sources,
some source is transmitted in more than $t$ bits.

**Theorem 4.4 (Streaming counting floor).** Let $s \ge 1$ and let $\mathrm{enc}$ be any
injective encoding of streams of $n$ messages drawn from an alphabet of $2^s$ symbols.
Then there exists a stream $x$ with
$$|\mathrm{enc}(x)| \;\ge\; n\,s.$$

*Proof sketch.* There are $(2^s)^n = 2^{ns}$ such streams, so $2^{(ns - 1) + 1}$ sources;
apply Corollary 4.3 with $t = ns - 1$. $\square$

Every bit of the transmission is counted here: the model delta, the residuals, framing,
everything. Theorem 4.4 is the floor the falsifiability gate of this research programme
demands.

### 4.2 A constructively lossless shared codec

The floor is met, up to the delta, by an explicit object.

**Definition 4.5 (Shared codec).** A *shared codec* at rate $s$ over a message type $X$ is
a pair of maps $\mathrm{enc} : X \to \{0,1\}^s$ and $\mathrm{dec} : \{0,1\}^s \to X$; here
$\{0,1\}^s$ is identified with the $2^s$ codeword indices. The codec is *lossless on a
domain* $S \subseteq X$ if $\mathrm{dec}(\mathrm{enc}(x)) = x$ for all $x \in S$. A stream
is encoded and decoded message by message.

The decoder $\mathrm{dec}$ is the shared decompressor fixed at deploy time; selecting
*which* codec is in force is precisely what the transmitted model delta buys.

**Theorem 4.6 (Existence of a domain-adapted codec).** If $|S| \le 2^s$ then there exists a
shared codec at rate $s$ that is lossless on $S$.

*Proof sketch.* $|S| \le 2^s$ gives an injection $e$ of $S$ into the codeword set. Encode
$x \in S$ as $e(x)$ (and arbitrarily off $S$); decode a codeword in the image of $e$ by its
unique preimage (and arbitrarily otherwise). Uniqueness of preimages under an injection
yields the round-trip identity. $\square$

**Theorem 4.7 (Losslessness gate).** If a codec is lossless on $S$, then for every stream
$x_1, \dots, x_n$ with all $x_i \in S$,
$$\mathrm{dec}^\ast(\mathrm{enc}^\ast(x_1,\dots,x_n)) = (x_1, \dots, x_n)$$
exactly, where $\mathrm{enc}^\ast, \mathrm{dec}^\ast$ are the message-wise extensions.

*Proof sketch.* Induction along the list, applying the per-message round-trip to the head
and the inductive hypothesis to the tail. $\square$

**Theorem 4.8 (Amortized protocol, with accounting).** Let $S$ be a domain with
$|S| \le 2^s$ and let $D$ be the length of the transmitted patch selecting the adapted
codec. Then there is a codec that decodes every $S$-stream exactly and whose total bit
budget
$$\mathrm{bits}(n) \;=\; D + n\,s$$
satisfies both
$$\mathrm{bits}(n) < n(s+1) \iff D < n \qquad\text{and}\qquad n\,s \le \mathrm{bits}(n).$$

Combining Theorem 4.8 with the floor of Theorem 4.4 gives the sandwich

$$n\,s \;\le\; \mathrm{bits}(n) \;=\; D + n\,s,$$

so the protocol is within $D$ bits of the information-theoretic optimum **uniformly in
$n$**: the absolute gap never grows, and the relative gap $D/(ns) \to 0$. This is the
precise discharge of the programme's falsifiability gate: lossless decoding, decoder fixed
at deploy time, delta charged to the message, and a strict win over the delta-free
protocol past break-even.

---

## 5. The tropical bridge

### 5.1 Min-plus structure

The **min-plus (tropical) semiring** is $(\mathbb{N} \cup \{\infty\}, \oplus, \otimes)$ with
$a \oplus b = \min(a,b)$ (additive, identity $\infty$) and $a \otimes b = a + b$
(multiplicative, identity $0$). Matrix multiplication over this semiring reads
$$(AB)_{ij} = \min_k \big(A_{ik} + B_{kj}\big),$$
the shortest-path composition.

Definition 2.4 is visibly a min-plus linear recursion. We make the identification exact.

**Definition 5.1 (Cost matrix).** For a delta cost $\delta$ and a residual cost $c$ define
the min-plus matrix $A \in \mathrm{Mat}_{M \times M}$ by
$$A_{ij} \;=\; \delta(i,j) + c(j),$$
"the bits to move the decoder from state $i$ to state $j$ and then code one message
there."

**Proposition 5.2 (One DP step is one tropical linear step).** For every stream
$c :: \mathbf{c}$ and every state $p$,
$$V_\delta(p, c :: \mathbf{c}) \;=\; \bigoplus_{m \in M} \Big(\delta(p,m) \otimes c(m) \otimes V_\delta(m, \mathbf{c})\Big).$$

This is Definition 2.4 rewritten; the content is that the coercion of natural numbers into
the tropical carrier commutes with finite minima, so no information is lost in passing to
the semiring.

**Theorem 5.3 (The optimum is a tropical matrix power).** For a coherent stream of $n$
identical messages with residual cost $c$,
$$\big(A^{\otimes n} \otimes \mathbf{1}\big)_p \;=\; V_\delta(p, c^{\,n}),$$
where $\mathbf{1}$ is the tropical all-ones vector (all entries the multiplicative identity
$0$) and $A^{\otimes n}$ is the $n$-fold min-plus power of the cost matrix.

*Proof sketch.* Induction on $n$. The base case is $A^{\otimes 0} = I$ and
$V_\delta(p, ()) = 0$. The step unfolds one min-plus matrix–vector product and matches it
term by term against Proposition 5.2 using the inductive hypothesis. $\square$

### 5.2 Consequences

Theorem 5.3 converts a compression question into a shortest-path question. Two payoffs.

**A closed form for a $2\times 2$ min-plus power.** In the explicit two-state witness of
§3.4, Theorem 5.3 and Theorem 3.3 combine to give
$$\big(A^{\otimes n} \otimes \mathbf{1}\big)_{\mathsf{gen}} \;=\; n\,r + \min(D, n),$$
a piecewise-linear function of $n$ with a single kink at $n = D$. Piecewise-linear
functions with integer slopes and finitely many kinks are the basic objects of tropical
geometry; here the kink is exactly the break-even point of the compression protocol.

**A conceptual identification of the amortized rate.** Since the amortized bits-per-message
is $\big(A^{\otimes n} \otimes \mathbf{1}\big)_p / n$, the long-run rate is by definition
the growth rate of tropical matrix powers. For min-plus matrices this growth rate is the
**minimum cycle mean** of the associated weighted digraph — the min-plus analogue of the
spectral radius. Thus:

> The asymptotic cost per message of *any* streaming adaptation protocol is the cheapest
> average weight of a cycle in the decoder-state graph, and the optimal protocol is
> eventually periodic with that cycle.

Sections 3 and 6 verify two instances of this principle: the coherent stream realizes the
self-loop cycle of mean $r$, and the block-alternating stream realizes a two-block cycle of
mean $r + \min(2D, L)/(2L)$. The general statement is Conjecture C1 of Section 11.

---

## 6. Coherence length, not stream length

Theorem 3.6 says the delta is asymptotically free. It is essential to understand *why*, and
the cleanest way is to exhibit a regime where it is not.

### 6.1 The maximally incoherent stream

Fix two domains, indexed by $d \in \{0,1\}$, and two specialized decoder states, likewise
indexed. A message of domain $d$ costs $r$ bits in state $d$ and $r+1$ bits in the other
state:
$$c_d(m) = \begin{cases} r & m = d,\\ r+1 & m \neq d.\end{cases}$$
Swapping states costs $D \ge 1$ bits in either direction; staying is free. The
*alternating stream* of length $n$ flips domain at every message.

**Theorem 6.1 (Exact optimum for the alternating stream).** For $D \ge 1$ and every $n$,
starting from state $p$ and with first-message domain $d$,
$$V(p, \mathrm{alt}_d(n)) \;=\; n\,r + \begin{cases}\lfloor n/2 \rfloor & \text{if } p = d,\\ \lceil n/2 \rceil & \text{otherwise.}\end{cases}$$
In particular the value does not depend on $D$: the optimal protocol never switches.

*Proof sketch.* Induction on $n$, carrying both starting states simultaneously. Over
$\{0,1\}$ the DP minimum is a binary minimum, so the recursion becomes a pair of coupled
integer identities that resolve by case analysis on $(d, p)$ together with the inductive
values for the tail. The key inequality is that switching costs at least $1$ bit and buys
at most $1$ bit before the domain flips back. $\square$

**Corollary 6.2 (Linear gap to the floor).** The excess over the rate floor $nr$ is
$\lceil n/2 \rceil$, growing linearly in $n$, in sharp contrast to the bounded excess
$\min(D,n) \le D$ of the coherent regime.

**Corollary 6.3 (Amortized rate of an incoherent stream).**
$$\lim_{n \to \infty} \frac{V(p, \mathrm{alt}_d(n))}{n} \;=\; r + \tfrac{1}{2}.$$

**Corollary 6.4 (Coherent beats incoherent).** For $D \ge 1$ and $n \ge 2D + 2$, the
coherent stream of length $n$ is strictly cheaper than the alternating stream of the same
length.

Stream length, therefore, is *not* the resource that amortizes the delta. Something else
is.

### 6.2 The interpolation: blocks of length $L$

Let the stream consist of $B$ blocks of $L$ consecutive messages, the domain alternating
from block to block. $L$ is the **coherence length**. Setting $L = 1$ recovers §6.1;
letting $L \to \infty$ recovers §3.

**Lemma 6.5 (Block absorption).** For a block of $k$ consecutive messages of a single
domain $d$, followed by an arbitrary remainder stream $R$, the optimum from the matching
state and from the wrong state are
$$V(d, d^{\,k} R) = k r + \min\Big(V(d, R),\; D + V(\bar d, R)\Big),$$
$$V(\bar d, d^{\,k} R) = k r + \min\Big(k + V(\bar d, R),\; D + V(d, R),\; 2D + V(\bar d, R)\Big).$$

*Proof sketch.* Induction on $k$, carrying both starting states. The three terms of the
second formula are precisely the three sensible policies for a wrongly-positioned decoder:
never switch, eating $k$ surplus bits; switch in and stay; switch in and back out. The
triangle inequality for the swap cost ($\delta(i,j) \le \delta(i,k) + \delta(k,j)$, trivially
true here) guarantees no further policy can beat these three. $\square$

**Definition 6.6 (Block excess).** Define $E(0) = 0$, $E(1) = \min(D, L)$ and
$E(B+2) = E(B) + \min(2D, L)$; and $G(0) = 0$, $G(B+1) = E(B)$.

$E$ is the excess over the rate floor when the decoder starts in the wrong state for the
first block; $G$ ("good start") when it starts in the right one, which is exactly a
one-block head start.

**Theorem 6.7 (Exact optimum for block-alternating streams).** For all $B$, $L$, $D$, $r$
and both starting states,
$$V(\bar d, \mathrm{blocks}_d(B, L)) = B\,L\,r + E(B), \qquad V(d, \mathrm{blocks}_d(B, L)) = B\,L\,r + G(B).$$

*Proof sketch.* Induction on $B$ using Lemma 6.5 to absorb the leading block, plus the
recursion $E(B+1) = \min\big(L + G(B),\, D + E(B),\, 2D + G(B)\big)$, which is exactly the
three-policy competition transported to block granularity. The monotonicity facts
$E(B+1) \le D + E(B)$ and $E(B) + \min(2D,L) \le D + E(B+1)$ keep the two branches
consistent. $\square$

**Theorem 6.8 (Closed form).**
$$E(B) \;=\; \Big\lfloor \tfrac{B}{2} \Big\rfloor \cdot \min(2D, L) \;+\; (B \bmod 2)\cdot \min(D, L),$$
hence
$$V(\bar d, \mathrm{blocks}_d(B,L)) \;=\; B\,L\,r \;+\; \Big\lfloor \tfrac{B}{2} \Big\rfloor \min(2D, L) \;+\; (B \bmod 2)\min(D, L).$$
Moreover $B \min(2D,L) \le 2E(B) \le B\min(2D,L) + 2\min(D,L)$.

*Proof sketch.* Strong induction on $B$ in steps of two for the closed form; the two-sided
bounds follow from it, or directly by the same induction. $\square$

**Theorem 6.9 (Coherence-length law).** For $L \ge 1$,
$$\lim_{B \to \infty} \frac{V(\bar d, \mathrm{blocks}_d(B,L))}{B\,L} \;=\; r + \frac{\min(2D, L)}{2L}.$$

*Proof sketch.* Divide the closed form by $BL$ and squeeze using the two-sided bounds of
Theorem 6.8; the leftover $\min(D,L)/(BL)$ term vanishes. $\square$

### 6.3 Reading the law

The excess rate $\min(2D, L)/(2L)$ has two regimes separated by the threshold $L = 2D$.

| Regime | Excess per message | Interpretation |
|---|---|---|
| $L \ge 2D$ (long blocks) | $D/L$ | The delta amortizes against the block; overhead $\to 0$ as blocks grow. |
| $L < 2D$ (short blocks) | $1/2$ | Independent of $D$: the patch is never worth sending; permanent generic-model surcharge. |
| $L = 1$ | $1/2$ | Recovers Corollary 6.3. |
| $L \to \infty$ | $0$ | Recovers Theorem 3.6. |

The design consequence is unambiguous: **the resource that amortizes a model delta is the
coherence length of the stream, not its total length**. A large but thoroughly interleaved
multi-domain corpus is worth nothing for adaptation; the same corpus sorted by domain
realizes the full gain. Quantitatively, sorting a stream from coherence length $L_1$ to
$L_2 \ge 2D$ saves $\min(2D,L_1)/(2L_1) - D/L_2$ bits per message.

---

## 7. How many bits is a domain patch?

A patch is itself a transmitted bitstring, so the counting arguments of Section 4 apply to
the *patch alphabet*.

**Lemma 7.1 (Patches are distinct).** If a shared decompressor is steered to $K$ distinct
domains, the assignment of patches to domains is injective: two domains sharing a patch
would leave the deployed decoder in the same state, contradicting that each domain has its
own optimal state.

**Theorem 7.2 (Some patch is expensive).** If $2^{t+1} \le K$, then some domain's patch is
longer than $t$ bits. In particular the longest patch is at least $\log_2 K - 1$ bits.

*Proof sketch.* Corollary 4.3 applied to the injective patch map on $K$ domains. $\square$

**Theorem 7.3 (Logarithmic warm-up delay).** Under the hypotheses of Theorem 7.2, there
exists a domain $k$ such that, in the two-state model of §3.4 with $D = |{\rm patch}(k)|$,
$$V(\mathsf{gen}, c^{\,n}) = n(r+1) \qquad \text{for every } n \le t.$$
That is, for the first $t \approx \log_2 K$ messages the optimal adaptive protocol
coincides *exactly* with the generic, never-patch protocol: the specialized decoder is
worth precisely nothing.

*Proof sketch.* Pick $k$ with $|{\rm patch}(k)| > t$ from Theorem 7.2 and apply Corollary
3.5 with $D = |{\rm patch}(k)| \ge n$. $\square$

**Theorem 7.4 (Break-even is at least logarithmic).** For that same domain, any stream on
which the adaptive protocol strictly beats the generic one has length $> t$.

**Theorem 7.5 (Total patch overhead).** Under the same hypotheses,
$$\sum_{k=1}^{K} |{\rm patch}(k)| \;>\; t \approx \log_2 K.$$
No engineering of a single domain can drive the total patch overhead of a $K$-domain
deployment to $o(\log K)$.

The moral is a hard architectural constraint. A shared decompressor advertised as serving
many domains must pay, somewhere, for the address space in which those domains are named.
Reparametrizations of the patch — adapter rank, sparsity pattern, quantization level — move
bits around but cannot beat the counting bound without reducing the number of reachable
domains.

---

## 8. Structural laws of the optimum

Four facts that constrain the design space of practical schedulers.

**Theorem 8.1 (Superadditivity).** For all streams $\mathbf{c}, \mathbf{d}$ and every start
$p$,
$$V_\delta(p, \mathbf{c}) + \min_{m \in M} V_\delta(m, \mathbf{d}) \;\le\; V_\delta(p, \mathbf{c} \cdot \mathbf{d}).$$

*Proof sketch.* Induction on $\mathbf{c}$; at each step the recursion's minimum over the
concatenation dominates the corresponding minimum over the prefix plus the best splice
value. $\square$

Interpretation: splitting a stream never *helps* the optimum, and the only advantage of
global knowledge is the choice of decoder state at the splice point. This is the min-plus
counterpart of submultiplicativity of matrix norms.

**Theorem 8.2 (Monotonicity in the delta cost).** If $\delta(i,j) \le \delta'(i,j)$ for all
$i,j$, then $V_\delta(p,\mathbf{c}) \le V_{\delta'}(p, \mathbf{c})$ for all $p, \mathbf{c}$.

**Theorem 8.3 (Switching bound).** If $\delta$ satisfies the triangle inequality
$\delta(i,j) \le \delta(i,k) + \delta(k,j)$, then for all states $s, s'$ and every stream,
$$V_\delta(s, \mathbf{c}) \;\le\; \delta(s,s') + V_\delta(s', \mathbf{c}).$$

**Theorem 8.4 (Triangle inequality = min-plus idempotence; no gain from routing).** Let
$(\delta \odot \delta)(i,j) := \min_k\big(\delta(i,k) + \delta(k,j)\big)$ be the min-plus
self-composition. Assuming $\delta(m,m) = 0$:
$$\delta \odot \delta = \delta \iff \delta \text{ satisfies the triangle inequality},$$
and in that case allowing the encoder to compose two patches leaves the optimum unchanged:
$V_{\delta \odot \delta} = V_\delta$.

*Proof sketch.* The inequality $\delta \odot \delta \le \delta$ always holds by routing
through $i$ itself. Equality at $(i,j)$ says no intermediate $k$ beats the direct patch,
which is the triangle inequality; conversely the triangle inequality makes $\delta$ a lower
bound for every routed cost. The second claim follows since the two cost functions are then
literally equal. $\square$

Since any reasonable patch format allows concatenation of patches, the triangle inequality
holds in practice, and Theorem 8.4 says multi-hop patch routing is a dead end — a useful
negative result for protocol designers.

---

## 9. Algorithms

### 9.1 The scheduling dynamic program

Given a start state $p$, a stream of residual cost vectors $(c_1, \dots, c_n)$ and a delta
matrix $\delta$ over $|M| = k$ states, the backward recursion of Definition 2.4 computes
the optimum and an optimal schedule in $O(n k^2)$ time and $O(k)$ working space (plus
$O(nk)$ if the argmin pointers are stored for schedule reconstruction). Concretely:

```
V[n][*] = 0
for i = n down to 1:
    for each state m': V[i-1][m'] = min over m of ( delta[m'][m] + c_i[m] + V[i][m] )
    argmin pointers stored alongside
answer = V[0][p]; schedule = follow pointers forward from p
```

This is exactly a shortest path in the layered digraph with $n+1$ layers of $k$ nodes and
edge weight $\delta(m,m') + c_i(m')$ from layer $i-1$ to layer $i$. Correctness is Theorem
2.5.

### 9.2 Tropical matrix powering for coherent streams

For a coherent stream, Theorem 5.3 replaces the $O(nk^2)$ sweep by min-plus exponentiation
by squaring: $O(k^3 \log n)$ time, independent of the stream length up to the logarithm.
For $k$ small (as in all the two-state models here) this is essentially free and yields
closed forms directly.

### 9.3 Threshold ("commit for $D$") scheduling

Corollaries 3.4 and 3.5, and the block law of Theorem 6.8, all express the same rule: a
switch is worth making exactly when the coherent run it serves is at least as long as the
delta. This suggests the linear-time greedy scheduler: scan the stream, maintain the
current state, and switch to the state optimal for the upcoming run only if that run has
length at least $D$ (or $2D$, if a switch back will be required). On coherent and
block-alternating streams this greedy rule is *provably optimal* by Theorems 3.3 and 6.7.
Whether it is optimal to within an additive $D$ bits on arbitrary streams is Conjecture C2
of Section 11.

### 9.4 Break-even and coherence diagnostics

Given measured quantities — residual rate advantage per message, patch length $D$ in bits,
empirical coherence length $L$ of the stream — the theory yields immediately actionable
numbers: the break-even stream length ($n = D$ messages), the achievable excess rate
($\min(2D,L)/(2L)$ bits per message), and the value of sorting ($\min(2D,L_1)/(2L_1) -
D/L_2$ bits per message when sorting raises coherence from $L_1$ to $L_2$). These are
one-line computations, and they should be run before any adaptation machinery is built.

---

## 10. Applications and discussion

**Neural compression with adapters.** The most direct reading: the shared decompressor is a
pretrained sequence model, $r$ is the arithmetic-coded residual rate of the domain-adapted
model, $r+1$ that of the generic model (in units of the per-message advantage), and $D$ is
the serialized size of the adapter. Theorem 3.3 gives the exact bit budget, Corollary 3.4
the exact break-even, and Theorem 6.9 the achievable rate on realistic, multi-domain
traffic.

**Shared dictionaries.** Dictionary-based compressors (shared-dictionary transport
encodings, per-domain dictionaries for embedded telemetry) instantiate the same model with
$D$ = dictionary size. The theory says the dictionary must be shorter than the coherent run
it serves; below that threshold it should not be sent at all.

**Federated and edge deployments.** Where a device holds a generic model and the server may
push a specialization, Theorem 7.3 quantifies the warm-up: serving $K$ device profiles
means some profile receives *no benefit whatsoever* for its first $\approx \log_2 K$
messages.

**Database and log compression.** Column stores and log pipelines routinely choose a codec
per block. Theorem 6.9 tells them exactly how large a block must be for a per-block codec
switch to pay: at least $2D$ messages, where $D$ is the codec descriptor size.

**Limitations.** The model is integer-valued, and the per-message advantage of
specialization is normalized to one bit; both are conveniences that make the sharp results
possible and neither restricts the qualitative conclusions, since costs can be rescaled.
The residual costs are treated as *given* — the theory says nothing about how good a model
can be, only how to schedule between models of known quality. The state set is finite;
continuous families of adapters would require a metric-space version of the delta cost, and
the counting bounds of Section 7 would then be replaced by covering-number bounds. Finally,
the sharpness hypotheses (H2) in particular encode that specialization is genuinely gated
behind a patch; a decoder that could drift into a specialized state for free would evade
Theorem 3.2, and correctly so.

---

## 11. Future directions

The following conjectures are stated so that each can be refuted by a single counterexample
inside the min-plus model developed above.

**C1. The amortized rate of any streaming adaptation protocol is a tropical eigenvalue.**
For a finite state set $M$, a delta cost $\delta$ and a periodic stream of residual costs,
the limit $V(n)/n$ exists and equals the minimum cycle mean of the associated min-plus cost
matrix — its tropical eigenvalue — and the optimal protocol is eventually periodic with that
cycle. The key insight is that Theorem 5.3 already identifies the optimum with a tropical
matrix power, so the asymptotic bits-per-message is by definition the growth rate of
tropical powers, which for min-plus matrices is the minimum cycle mean. Both special cases
are proved: coherent streams give cycle mean $r$ (Theorem 3.6), block-alternating streams
give $r + \min(2D, L)/(2L)$ (Theorem 6.9). A general Karp-style theorem would subsume both
and yield a computable design rule for adaptation schedules.

**C2. Optimal adaptation schedules are hysteretic, with threshold exactly $D$.** For every
cost stream — not only replicate and alternating ones — an optimal schedule exists that
changes decoder state at message $i$ only if the state it enters is optimal for at least $D$
of the next messages; and this "commit for $D$ messages" rule is optimal within an additive
$D$ bits. The key insight is that all sharp results so far — the closed form $nr + \min(D,n)$,
break-even exactly at $n = D$, and the block law $\min(2D, L)$ — express the same trade-off:
a switch is worth it iff the coherent run it serves is at least as long as the delta. Since
the exact block optimum shows mixed policies can beat both pure policies, a *provable*
greedy/threshold rule with an additive-$D$ guarantee is the natural next theorem, and it is
directly testable against the dynamic program.

**C3. The $\log K$ warm-up delay is unavoidable on average, not merely in the worst case.**
If a shared decompressor serves $K$ domains with prefix-free patches, then the *average*
patch length is at least $\log_2 K - O(1)$, and hence the average break-even stream length
over domains is $\Omega(\log K)$; no reparametrization — adapter rank, sparsity pattern,
quantization — can beat this without shrinking the number of reachable domains. The key
insight is that Theorem 7.2 is a pigeonhole statement about the patch alphabet itself, and
Kraft's inequality upgrades a worst-case counting bound to an average-case one.

Beyond these, three directions seem especially promising: (i) a continuous version in which
adapters form a metric space and the delta cost is a quantization cost, replacing counting
bounds by covering numbers; (ii) a stochastic version in which the domain evolves as a
Markov chain and the coherence length is its expected sojourn time, for which the
coherence-length law should become an expectation over the stationary distribution; and
(iii) an online version in which the sender does not know the future stream, where the
natural target is a competitive ratio against the offline optimum computed by the dynamic
program of Section 9.1.

---

## 12. Conclusion

Compression with a shared, adaptable decompressor is a scheduling problem over decoder
states, and that scheduling problem is min-plus linear. Working in the tropical semiring
turns qualitative folklore into exact statements: the optimum for a coherent stream is
exactly $n r + \min(D, n)$ bits; the break-even is exactly at $n = D$ messages; short
streams gain exactly nothing; the amortized rate on a block-alternating stream is exactly
$r + \min(2D, L)/(2L)$; and a decompressor serving $K$ domains has a domain with an
$\Omega(\log K)$-bit patch and a correspondingly delayed break-even. Against the pigeonhole
floor of $ns$ bits, the amortized protocol is optimal to within the one-off delta,
uniformly in stream length, with exact lossless reconstruction.

The single sentence to take away is the one that names the paper's central discovery: **the
model delta amortizes against the coherence length of the stream, not against its length.**
Sort your data by domain, patch only when the coherent run exceeds the patch, and the
program becomes free — eventually, provably, and by exactly the amount the formulas above
predict.
