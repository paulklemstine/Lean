# Information Reconciliation: Transcripts, Corrected Keys, and Exact Leakage

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Two parties hold binary strings that agree except in a small number of
positions, and must bring them into exact agreement by communicating over a
public channel. We give a complete and rigorous account of the syndrome-based
solution to this *information reconciliation* problem, treating the public
transcript as a first-class mathematical object and accounting exactly for what
it reveals.

For a public parity-check matrix $H \in \mathbb{F}_2^{m \times n}$ and a
correction radius $t$, we prove: (i) **correctness** — under the separation
hypothesis that every nonzero kernel vector has Hamming weight exceeding $2t$,
the receiver's corrected string equals the sender's string exactly, for every
input pair within radius $t$; (ii) **exact leakage** — the transcript partitions
the $2^n$ candidate keys into $2^r$ classes of $2^{n-r}$ keys each, where
$r = \operatorname{rank} H$, so the transcript reveals precisely $r$ bits, no
more and no fewer; this is restated as a min-entropy identity
$H_\infty(\text{key} \mid \text{transcript}) = n - r$, as a Shannon identity
$H(\text{transcript}) = r$, and as the chain rule $n = H(\text{transcript}) +
H_\infty(\text{key} \mid \text{transcript})$; (iii) **operational leakage** —
every transcript-only guessing strategy, of unbounded computational power,
succeeds on at most $2^r$ of the $2^n$ keys; (iv) a **universal converse** —
*every* correct protocol, interactive or one-shot, linear or arbitrary, must
publish at least $V(n,t) = \sum_{i \le t}\binom{n}{i}$ distinguishable
transcripts, and on some admissible input actually reduces the adversary's
candidate set to at most $2^n / V(n,t)$ keys; (v) **composition** — leakage of
stacked rounds is subadditive in rank and correctness is monotone under adding
rounds; and (vi) **optimality** — perfect schemes, for which $2^m = V(n,t)$,
have total decoders, full rank, and meet the universal bound with equality for
every transcript. The $[3,1]$ repetition scheme and the $[7,4]$ Hamming scheme
are worked out explicitly as instances, leaving exactly $1$ and $4$ secret bits
respectively.

The unifying observation is that correctness and privacy are two readings of a
single structure: the fibers of the syndrome map. Read locally, inside the
Hamming ball of radius $t$, a fiber is a singleton — that is correctness. Read
globally, as a partition of the whole space, the fibers are $2^r$ cosets of the
kernel — that is leakage.

**Keywords:** information reconciliation, syndrome decoding, parity-check matrix,
Hamming ball volume, min-entropy, leakage, sphere-packing bound, perfect codes.

---

## 1. Introduction

### 1.1 The problem

Let $n$ be a positive integer and let $\mathbb{F}_2 = \mathbb{Z}/2\mathbb{Z}$ be
the field with two elements. Two parties, whom we call Alice and Bob, hold
strings
$$a, b \in \mathbb{F}_2^n,$$
called *raw keys*. They are promised that the strings are close: their
**error pattern** $e = a - b$ (equivalently $a+b$, since the characteristic is
$2$) has small Hamming weight. They wish to reach exact agreement on a common
string, communicating only over a channel that is authenticated but completely
public.

This is the *information reconciliation* problem. It arises whenever a physical
process delivers correlated but non-identical bit strings to two parties: most
prominently as the post-processing step of quantum key distribution, where
detector noise and channel imperfections produce a small discrepancy rate; also
in physically unclonable functions, biometric key extraction, and fuzzy
extractors generally.

Two requirements pull against each other.

- **Correctness.** After the protocol both parties must hold the *same* string.
  Approximate agreement is worthless: downstream privacy amplification and
  encryption are exact operations, and a single differing bit destroys them.
- **Privacy.** Every bit published is available to an adversary Eve, and reduces
  the residual uncertainty of the key. The subsequent privacy-amplification step
  must be told exactly how many bits were lost, and any overestimate wastes key
  while any underestimate breaks security.

The purpose of this paper is to make the second requirement as precise as the
first: to model the transcript explicitly, prove correctness of the corrected
keys, and account exactly — not merely bound loosely — for the leakage.

### 1.2 Notation

For $x \in \mathbb{F}_2^n$ write $\|x\|$ for its **Hamming weight**, the number
of coordinates at which $x$ is nonzero, and $d(x,y) = \|x-y\|$ for the Hamming
distance. Write
$$V(n,t) \;=\; \sum_{i=0}^{t}\binom{n}{i}$$
for the volume of the Hamming ball of radius $t$ in $\mathbb{F}_2^n$; this is the
number of vectors of weight at most $t$. All logarithms denoted $\log$ are base
$2$, and entropies are measured in bits.

### 1.3 Contributions and organisation

Section 2 sets up the syndrome model and proves correctness. Section 3 gives the
exact leakage accounting in counting, min-entropy, Shannon, and operational
(guessing) forms. Section 4 proves the protocol-independent converse. Section 5
treats perfect schemes and the two classical examples. Section 6 treats
composition of rounds. Section 7 gives algorithms and complexity. Sections 8 and
9 discuss applications and future directions.

---

## 2. The syndrome model and correctness

### 2.1 Definitions

**Definition 2.1 (Key, syndrome space).** A *key* of length $n$ is a vector
$a \in \mathbb{F}_2^n$; we also write $\mathrm{Key}(n) = \mathbb{F}_2^n$. A
*syndrome* of length $m$ is a vector in $\mathbb{F}_2^m$.

**Definition 2.2 (Reconciliation scheme).** A *syndrome-based reconciliation
scheme* $S = (H, t)$ consists of a public matrix
$H \in \mathbb{F}_2^{m \times n}$ — the *parity-check matrix* — together with a
non-negative integer $t$, the *advertised correction radius*.

**Definition 2.3 (Syndrome, transcript, fiber, ball).** For a scheme $S=(H,t)$
define
$$\sigma(x) \;=\; Hx \in \mathbb{F}_2^m \qquad (x \in \mathbb{F}_2^n),$$
the *syndrome* of $x$. The *transcript* of a run in which Alice holds $a$ is
$\mathrm{tr}(a) = \sigma(a)$. The *fiber* of a syndrome $s$ is
$\sigma^{-1}(s) = \{x : \sigma(x) = s\}$, the set of keys consistent with the
public data. The *ball* of the scheme is
$B_t = \{x \in \mathbb{F}_2^n : \|x\| \le t\}$, so $|B_t| = V(n,t)$.

The map $\sigma$ is $\mathbb{F}_2$-linear; we record the three properties used
throughout: $\sigma(0) = 0$, $\sigma(x+y) = \sigma(x)+\sigma(y)$, and
$\sigma(x-y)=\sigma(x)-\sigma(y)$.

**Definition 2.4 (Separation).** The scheme $S = (H,t)$ is **separating** if
every nonzero kernel vector is heavy:
$$\forall c \in \mathbb{F}_2^n,\quad Hc = 0 \ \text{ and } \ c \ne 0
\;\Longrightarrow\; \|c\| > 2t.$$

Equivalently, the linear code $\ker H$ has minimum distance strictly greater than
$2t$. This is the classical hypothesis for unique decoding up to radius $t$,
stated here in exactly the form the correctness argument consumes.

### 2.2 The protocol

The protocol has one message.

1. Alice computes and broadcasts $s = \sigma(a)$. This is the **entire** public
   transcript: $m$ bits.
2. Bob computes $s - \sigma(b)$. By linearity this equals $\sigma(a-b) =
   \sigma(e)$: he learns the syndrome of the error pattern.
3. Bob applies a **decoder** $D$ to $\sigma(e)$, obtaining a candidate error
   pattern, and outputs $b + D(s - \sigma(b))$.

**Definition 2.5 (Decoder, correction map).** Fix the *minimum-weight syndrome
decoder*
$$D(s) \;=\;
\begin{cases}
\text{some } e \text{ with } \sigma(e) = s \text{ and } \|e\| \le t, & \text{if such an } e \text{ exists},\\
0, & \text{otherwise,}
\end{cases}$$
and Bob's *correction map*
$$C(b, s) \;=\; b + D\big(s - \sigma(b)\big).$$

We stress that $D$ is specified only by its defining property — "return *a*
low-weight preimage" — and not by any algorithm. This is deliberate. Correctness
must be derived from the *uniqueness* of the low-weight preimage, not from
properties of a particular decoding procedure; whether such a preimage exists at
all for every $s$ is a strictly stronger property (totality), established in
Section 5 only for perfect schemes.

### 2.3 Hamming weight subadditivity

**Lemma 2.6.** For all $x, y \in \mathbb{F}_2^n$, $\|x-y\| \le \|x\| + \|y\|$.

*Proof.* The Hamming distance satisfies the triangle inequality
$d(x,y) \le d(x,0) + d(0,y)$. Since $d(x,0)=\|x\|$, $d(0,y)=\|y\|$ and
$d(x,y) = \|x-y\|$, the claim follows. $\square$

### 2.4 Unique decoding

**Theorem 2.7 (Injectivity on the ball).** Let $S$ be separating and let
$x, y \in \mathbb{F}_2^n$ with $\|x\| \le t$, $\|y\| \le t$ and
$\sigma(x) = \sigma(y)$. Then $x = y$.

*Proof.* Suppose not, so $x - y \ne 0$. By linearity
$\sigma(x-y) = \sigma(x)-\sigma(y) = 0$, so $x-y$ is a nonzero kernel vector, and
separation gives $\|x-y\| > 2t$. On the other hand Lemma 2.6 gives
$\|x-y\| \le \|x\| + \|y\| \le 2t$. These are contradictory. $\square$

This single theorem is the heart of the correctness argument; everything in
Section 2.5 is bookkeeping around it. It is also exactly tight: the separation
hypothesis cannot be weakened. If some nonzero kernel vector $c$ has
$\|c\| \le 2t$, split its support into two parts of size $\le t$ to write
$c = x + y$ with $\|x\|,\|y\| \le t$ and $x \ne y$; then $\sigma(x) = \sigma(y)$
while $x \ne y$, and unique decoding fails.

*Concrete failure.* For $n = 4$, $m=2$, $t=1$ and
$H = \begin{pmatrix}1&1&0&0\\0&0&1&1\end{pmatrix}$, the nonzero kernel weights
are $\{2,4\}$; since $2 \not> 2 = 2t$, the scheme is not separating, and indeed
the two distinct weight-one patterns $1000$ and $0100$ share the syndrome $10$.
Bob cannot tell which bit to flip.

**Theorem 2.8 (Decoder correctness).** Let $S$ be separating and let $e$ satisfy
$\|e\| \le t$. Then $D(\sigma(e)) = e$.

*Proof.* A low-weight preimage of $\sigma(e)$ exists, namely $e$ itself, so $D$
returns some $x$ with $\sigma(x) = \sigma(e)$ and $\|x\| \le t$. By Theorem 2.7,
$x = e$. $\square$

### 2.5 Correctness of the reconciled key

**Theorem 2.9 (Correctness of information reconciliation).** Let $S$ be
separating and let $a, b \in \mathbb{F}_2^n$ with $\|a-b\| \le t$. Then
$$C\big(b, \mathrm{tr}(a)\big) \;=\; a.$$

*Proof.* By linearity $\mathrm{tr}(a) - \sigma(b) = \sigma(a) - \sigma(b) =
\sigma(a-b)$. By Theorem 2.8 applied to $e = a - b$, we get
$D(\sigma(a-b)) = a-b$. Hence $C(b, \mathrm{tr}(a)) = b + (a - b) = a$.
$\square$

Two reformulations are worth recording.

**Corollary 2.10 (Error-pattern form).** For a separating $S$, any $b$ and any
$e$ with $\|e\| \le t$: $C\big(b, \mathrm{tr}(b+e)\big) = b + e$. Bob's output is
Alice's key regardless of which key Bob started from, provided the discrepancy
is within radius.

**Corollary 2.11 (Idempotence).** For a separating $S$ and any $a$:
$C(a, \mathrm{tr}(a)) = a$. If the parties already agree, the protocol leaves the
key untouched — the decoder returns the zero error pattern.

Theorem 2.9 is a *worst-case, exact* statement: there is no failure probability,
no approximation, and no dependence on how the error pattern was generated. The
promise $\|a-b\| \le t$ is the sole hypothesis.

### 2.6 What the transcript determines

**Theorem 2.12 (Transcript = coset).** For all $a, a' \in \mathbb{F}_2^n$,
$$\mathrm{tr}(a) = \mathrm{tr}(a') \iff \sigma(a - a') = 0 \iff a - a' \in \ker H.$$
Consequently the set of keys consistent with the observed transcript is exactly
the coset
$$\sigma^{-1}(\mathrm{tr}(a)) \;=\; a + \ker H,$$
and Alice's key always lies in it.

*Proof.* By linearity $\sigma(a) = \sigma(a')$ iff $\sigma(a-a')=0$. Membership
$x \in \sigma^{-1}(\mathrm{tr}(a))$ is $\sigma(x) = \sigma(a)$, i.e.
$\sigma(x-a) = 0$, i.e. $x \in a + \ker H$. Taking $x = a$ gives consistency.
$\square$

Theorem 2.12 is the precise sense in which the transcript is *all* that goes
public: two runs of the protocol with the same transcript are literally
indistinguishable to an observer, and the transcript pins the key down to a coset
of the code and to nothing finer. Sections 3 and 4 turn this qualitative
statement into quantities.

---

## 3. Exact leakage accounting

Throughout this section $S = (H, t)$ is a scheme and
$$r \;=\; \operatorname{rank} H \;=\; \dim_{\mathbb{F}_2} \mathrm{im}\,\sigma.$$
We call $r$ the **leakage rank** of the scheme. Two elementary bounds will be
used constantly: $r \le m$ (the image sits in $\mathbb{F}_2^m$) and $r \le n$
(rank–nullity).

### 3.1 Counting consistent keys

**Theorem 3.1 (Kernel count).** $|\sigma^{-1}(0)| = 2^{\,n-r}$.

*Proof.* $\sigma^{-1}(0) = \ker \sigma$ is an $\mathbb{F}_2$-subspace; a
finite-dimensional vector space over $\mathbb{F}_2$ of dimension $d$ has $2^d$
elements; and rank–nullity gives $\dim\ker\sigma = n - r$. $\square$

**Theorem 3.2 (All fibers are equinumerous).** For every $a$,
$|\sigma^{-1}(\mathrm{tr}(a))| = |\sigma^{-1}(0)|$.

*Proof.* The mutually inverse translations $x \mapsto x - a$ and $y \mapsto y+a$
are bijections between $\sigma^{-1}(\mathrm{tr}(a))$ and $\sigma^{-1}(0)$: if
$\sigma(x) = \sigma(a)$ then $\sigma(x-a)=0$, and conversely. $\square$

**Theorem 3.3 (Residual key space).** For every $a$,
$$\big|\{x : \sigma(x) = \mathrm{tr}(a)\}\big| \;=\; 2^{\,n-r}.$$

*Proof.* Combine Theorems 3.1 and 3.2. $\square$

**Theorem 3.4 (Exact leakage identity).** For every $a$,
$$2^{n} \;=\; 2^{r} \cdot \big|\{x : \sigma(x) = \mathrm{tr}(a)\}\big|
\;=\; 2^{r}\cdot 2^{\,n-r}.$$
The $2^n$ a-priori keys split into $2^r$ transcript classes of $2^{n-r}$ keys
each; the transcript reveals exactly $r$ bits about the key.

The word *exactly* is doing real work. The upper bound "at most $m$ bits leak"
is the crude statement obtained from $r \le m$; the refinement is that the
correct figure is the rank, so any linear dependence among the published parity
checks is *free*. Publishing a check that is the sum of two already-published
checks costs zero bits of privacy. Conversely, no protocol-level trick can push
the leakage below $r$: the fibers really do have $2^{n-r}$ elements, not more.

**Corollary 3.5 (Length bounds).** For every $a$:
$2^n \le 2^m \cdot |\sigma^{-1}(\mathrm{tr}(a))|$ and
$2^{\,n-m} \le |\sigma^{-1}(\mathrm{tr}(a))|$.

### 3.2 Min-entropy form

For a uniformly distributed raw key, conditioning on the transcript yields the
uniform distribution on a fiber, by Theorem 3.2. Hence the conditional
min-entropy is the logarithm of the fiber size.

**Theorem 3.6 (Residual min-entropy).** For every $a$,
$$H_\infty\big(\text{key} \mid \text{transcript}\big)
= \log_2 \big|\sigma^{-1}(\mathrm{tr}(a))\big| \;=\; n - r \;\ge\; n-m.$$

This is the number that privacy amplification needs as input. Using $n-m$ is
always safe; using $n-r$ is safe and never worse, and is strictly better whenever
the published checks are dependent.

### 3.3 Shannon form and the chain rule

**Definition 3.7.** For a uniformly random key define the transcript probability
$$p(s) \;=\; \frac{|\sigma^{-1}(s)|}{2^n},$$
and the transcript entropy $H(\text{transcript}) = -\sum_{s \in \mathrm{im}\,\sigma} p(s)\log_2 p(s)$.

**Theorem 3.8 (Uniformity of the transcript).** Every achievable transcript
$s = \mathrm{tr}(a)$ has $p(s) = 2^{-r}$.

*Proof.* Theorem 3.3 gives $|\sigma^{-1}(s)| = 2^{n-r}$, and
$2^{n-r}/2^n = 2^{-r}$. $\square$

**Theorem 3.9 (Transcript entropy).** $H(\text{transcript}) = r$ bits, and
consequently $H(\text{transcript}) \le m$.

*Proof.* The image of $\sigma$ is a subspace of dimension $r$, hence has $2^r$
elements. Each contributes $-2^{-r}\log_2 2^{-r} = r\,2^{-r}$ to the sum, and
$2^r \cdot r\,2^{-r} = r$. $\square$

**Theorem 3.10 (Reconciliation chain rule).** For every $a$,
$$n \;=\; H(\text{transcript}) \;+\; H_\infty(\text{key}\mid\text{transcript}).$$

*Proof.* Immediate from Theorems 3.9 and 3.6: $r + (n-r) = n$. $\square$

The chain rule is the complete bookkeeping of the protocol. The raw key carries
$n$ bits of entropy; after the protocol, $r$ of them are public and $n-r$ are
secret. Nothing is lost, nothing is double-counted, and the split is governed by
the single integer $r$.

### 3.4 Operational form: guessing the key

Entropy statements are only as meaningful as their operational consequences. Here
is the strongest such consequence, and it holds against a computationally
unbounded adversary.

**Theorem 3.11 (Number of achievable transcripts).**
$|\mathrm{im}\,\sigma| = 2^{r}$.

*Proof.* $\mathrm{im}\,\sigma$ is a subspace of dimension $r$ over
$\mathbb{F}_2$. $\square$

**Theorem 3.12 (Guessing bound).** Let $g : \mathbb{F}_2^m \to \mathbb{F}_2^n$ be
*any* function — an eavesdropper strategy that reads the transcript and outputs a
guess at the key. Then
$$\big|\{a \in \mathbb{F}_2^n : g(\mathrm{tr}(a)) = a\}\big| \;\le\; 2^{r}
\;\le\; 2^m.$$

*Proof.* Let $W = \{a : g(\mathrm{tr}(a)) = a\}$ be the set of keys on which $g$
succeeds. The map $\sigma$ is injective on $W$: if $a, a' \in W$ and
$\sigma(a) = \sigma(a')$ then $a = g(\mathrm{tr}(a)) = g(\mathrm{tr}(a')) = a'$.
So $|W| \le |\mathrm{im}\,\sigma| = 2^r$ by Theorem 3.11. $\square$

**Corollary 3.13 (Guessing probability).** For a uniformly random key, any
transcript-only strategy succeeds with probability at most
$2^{r}/2^{n} = 2^{\,r-n}$.

Theorem 3.12 converts the counting statement into a security guarantee of the
form a practitioner can use directly: after reconciliation with a rank-$r$
transcript, the key retains $n-r$ bits of guessing security, exactly.

---

## 4. A universal converse: correctness forces leakage

Everything so far concerns the syndrome construction. It is natural to ask
whether its leakage is an artefact of linearity — whether a cleverer,
interactive, adaptive, or nonlinear protocol could reconcile $t$ discrepancies
while publishing substantially less. This section rules that out.

### 4.1 The abstract protocol model

**Definition 4.1 (Protocol).** Let $T$ be a finite set of *transcripts*. A
*reconciliation protocol* of radius $t$ consists of

- a transcript map $\tau : \mathbb{F}_2^n \times \mathbb{F}_2^n \to T$, where
  $\tau(a,b)$ is the entire public conversation of a run in which Alice holds $a$
  and Bob holds $b$;
- a reconstruction map $R : \mathbb{F}_2^n \times T \to \mathbb{F}_2^n$, where
  $R(b,\tau)$ is Bob's output;

subject to the **correctness** requirement
$$\|a - b\| \le t \;\Longrightarrow\; R\big(b, \tau(a,b)\big) = a .$$

Letting $\tau$ depend on *both* inputs is what makes the model general: any
multi-round, adaptive, interactive protocol produces a transcript that is a
function of both parties' inputs, and this definition assumes nothing about how
that function factors through rounds. No linearity, no structure, no algorithmic
assumption is imposed.

### 4.2 The injection

**Theorem 4.2 (Transcript injectivity on the ball).** Let $(\tau, R, t)$ be a
correct protocol. Then the map $a \mapsto \tau(a, 0)$ is injective on the ball
$B_t = \{a : \|a\| \le t\}$.

*Proof.* Let $x, y \in B_t$ with $\tau(x,0) = \tau(y,0)$. Since $\|x - 0\| \le t$,
correctness gives $R(0, \tau(x,0)) = x$; likewise $R(0,\tau(y,0)) = y$. Hence
$x = R(0,\tau(x,0)) = R(0,\tau(y,0)) = y$. $\square$

This is the whole idea, and it is worth pausing on. Freezing Bob's input converts
an arbitrary interactive protocol into a *one-way encoding* of Alice's input:
whatever the parties did, the resulting transcript must determine $a$ among all
strings in the ball, because Bob — who has nothing else — recovers $a$ from it.

### 4.3 The bound

**Theorem 4.3 (Universal leakage bound).** Every correct reconciliation protocol
of radius $t$ on $n$-bit strings satisfies
$$V(n,t) \;=\; \sum_{i=0}^{t}\binom{n}{i} \;\le\; |T|,$$
equivalently, the transcript carries at least $\log_2 V(n,t)$ bits.

*Proof.* By Theorem 4.2 the map $a \mapsto \tau(a,0)$ injects $B_t$ into $T$, and
$|B_t| = V(n,t)$. $\square$

**Corollary 4.4 (Single-error cost).** A protocol correcting a single discrepancy
in an $n$-bit string has $|T| \ge n+1$, i.e. publishes at least $\log_2(n+1)$
bits. One must at minimum be able to name the flipped position, or announce that
there is none.

Specialised to the syndrome scheme with $|T| = 2^m$, Theorem 4.3 reads
$V(n,t) \le 2^m$: the **sphere-packing leakage bound**. It can also be proved
directly for syndrome schemes from Theorem 2.7 (the syndrome map injects $B_t$
into $\mathbb{F}_2^m$), and indeed the syndrome scheme is an instance of
Definition 4.1 via $\tau(a,b) = \sigma(a)$ and $R = C$, so the general bound
applies verbatim.

### 4.4 The loss is actually incurred

Theorem 4.3 bounds the *size of the transcript alphabet*. One might hope that a
large alphabet is used only rarely, so the privacy loss is not really suffered.
It is.

**Theorem 4.5 (Worst-case residual bound).** For every correct protocol
$(\tau,R,t)$ there exists an input $a$ with $\|a\| \le t$ such that
$$V(n,t)\cdot \big|\{x \in \mathbb{F}_2^n : \tau(x,0) = \tau(a,0)\}\big| \;\le\; 2^n .$$
That is, on some admissible input the transcript narrows the adversary's
candidate set to at most $2^n / V(n,t)$ keys.

*Proof.* For $b \in B_t$ let $c(b) = |\{x : \tau(x,0)=\tau(b,0)\}|$, the size of
the transcript class of $b$. By Theorem 4.2, distinct $b, b' \in B_t$ have
distinct transcripts $\tau(b,0)\neq\tau(b',0)$, so their classes are disjoint.
The classes are subsets of $\mathbb{F}_2^n$, hence
$$\sum_{b \in B_t} c(b) \;=\; \Big|\bigcup_{b\in B_t}\{x:\tau(x,0)=\tau(b,0)\}\Big| \;\le\; 2^n.$$
Let $a \in B_t$ minimise $c$ (the ball is nonempty, containing $0$). Then
$|B_t|\cdot c(a) \le \sum_{b\in B_t}c(b) \le 2^n$, and $|B_t| = V(n,t)$.
$\square$

### 4.5 Pigeonhole privacy bounds

The averaging step above is an instance of a general principle worth isolating,
since it applies to public data of *any* origin, not only reconciliation
transcripts.

**Theorem 4.6 (Pigeonhole privacy bound).** Let $F$ be a finite set and
$f : \mathbb{F}_2^n \to F$ any function of the key. Then there exists $y \in F$
with
$$2^n \;\le\; |F|\cdot\big|\{x : f(x)=y\}\big|,$$
i.e. some public value leaves at least $2^n/|F|$ keys consistent with it.

*Proof.* Suppose $|F|\cdot|f^{-1}(y)| < 2^n$ for every $y \in F$. Summing the
strict inequality over the nonempty index set $F$ and using
$\sum_{y}|f^{-1}(y)| = 2^n$ gives $|F|\cdot 2^n < |F|\cdot 2^n$, absurd.
$\square$

**Theorem 4.7 (Composition with side information).** For finite $F, G$ and any
$f : \mathbb{F}_2^n\to F$, $g : \mathbb{F}_2^n \to G$, there exist $y \in F$,
$z \in G$ with
$$2^n \;\le\; |F|\cdot|G|\cdot\big|\{x : f(x)=y \text{ and } g(x)=z\}\big| .$$

*Proof.* Apply Theorem 4.6 to the pair map $x \mapsto (f(x),g(x))$ into
$F\times G$, and note that the fiber of $(y,z)$ under the pair map is exactly the
set on the right. $\square$

Theorem 4.7 says that leakage from independent public releases is at worst
*additive in bits*: a transcript worth $\log|F|$ bits together with side
information worth $\log|G|$ bits cannot cost more than $\log|F| + \log|G|$ bits
of residual uncertainty in the worst case. This is the guarantee one wants when
composing reconciliation with other public post-processing.

---

## 5. Perfect schemes: attaining the bound

Theorem 4.3 is a lower bound; we now show it is achieved, and characterise the
structure of the schemes that achieve it.

**Definition 5.1 (Perfect scheme).** A scheme $S = (H,t)$ with $H$ of size
$m \times n$ is **perfect** if
$$2^m \;=\; V(n,t) \;=\; \sum_{i=0}^{t}\binom{n}{i} .$$

Equivalently, the transcript length exactly matches the sphere-packing bound: not
one bit is published beyond what Theorem 4.3 forces.

**Theorem 5.2 (Surjectivity on the ball).** If $S$ is separating and perfect,
then $\sigma(B_t) = \mathbb{F}_2^m$: every syndrome is the syndrome of an error
pattern of weight at most $t$.

*Proof.* By Theorem 2.7 the map $\sigma$ is injective on $B_t$, so
$|\sigma(B_t)| = |B_t| = V(n,t) = 2^m = |\mathbb{F}_2^m|$. A subset of a finite
set with the same cardinality is the whole set. $\square$

**Corollary 5.3 (Total decoding).** If $S$ is separating and perfect, then for
every $s \in \mathbb{F}_2^m$ there is $e$ with $\sigma(e) = s$ and $\|e\|\le t$;
consequently the decoder always returns a genuine explanation:
$\sigma(D(s)) = s$ and $\|D(s)\| \le t$ for all $s$.

Decoding failure — the event that the received syndrome has no low-weight
explanation, which for a general separating scheme is possible and must be
detected and handled — simply does not occur for perfect schemes.

**Theorem 5.4 (Full rank).** If $S$ is separating and perfect, then
$r = \operatorname{rank} H = m$.

*Proof.* By Theorem 5.2 the image of $\sigma$ contains $\sigma(B_t)=\mathbb{F}_2^m$,
so $|\mathrm{im}\,\sigma| = 2^m$. By Theorem 3.11 that cardinality is $2^r$, and
$2^m = 2^r$ forces $m = r$. $\square$

So a perfect scheme wastes nothing in either direction: it publishes the minimum
number of bits, and each published bit carries a full bit of information.

**Theorem 5.5 (The bound is met for every transcript).** If $S$ is separating and
perfect, then for every $a$,
$$V(n,t)\cdot \big|\{x : \sigma(x) = \mathrm{tr}(a)\}\big| \;=\; 2^n,$$
and the residual key space has exactly $2^{\,n-m}$ elements.

*Proof.* By Theorem 3.3 and Theorem 5.4 the fiber has $2^{n-r} = 2^{n-m}$
elements; multiplying by $V(n,t) = 2^m$ gives $2^{n}$. $\square$

Compare Theorem 4.5, which asserts $V(n,t)\cdot(\text{fiber}) \le 2^n$ for
*some* input of any correct protocol. For a perfect scheme, equality holds for
*every* input. Perfect schemes are exactly the ones for which the worst case is
the only case.

### 5.1 Worked example: the $[3,1]$ repetition scheme

Take $n=3$, $m=2$, $t=1$ and
$$H \;=\; \begin{pmatrix} 1 & 1 & 0\\ 0 & 1 & 1\end{pmatrix},$$
whose two rows are the parity checks $x_0+x_1$ and $x_1+x_2$.

- **Separating.** $\ker H = \{000, 111\}$; the unique nonzero codeword has weight
  $3 > 2 = 2t$. (Exhaustive check over all $2^3$ vectors.)
- **Perfect.** $2^m = 4 = 1 + 3 = \binom{3}{0}+\binom{3}{1} = V(3,1)$.
- **Rank.** $r = m = 2$ by Theorem 5.4: both published bits are informative.
- **Residual.** Exactly $2^{3-2}=2$ keys survive any transcript: precisely
  **one secret bit** out of three.
- **Correctness in the concrete.** If Alice holds $(1,1,1)$ and Bob holds
  $(1,0,1)$, then $\|a-b\|=1 \le t$, Alice publishes $\mathrm{tr}(a) = (0,0)$, and
  Bob's correction yields $(1,1,1)$.

### 5.2 Worked example: the $[7,4]$ Hamming scheme

Take $n=7$, $m=3$, $t=1$ and
$$H \;=\;\begin{pmatrix}
1&0&1&0&1&0&1\\
0&1&1&0&0&1&1\\
0&0&0&1&1&1&1
\end{pmatrix},$$
whose $j$-th column is the binary numeral of $j$ for $j = 1,\dots,7$.

- **Separating.** No nonzero kernel vector has weight $\le 2$: the columns are
  pairwise distinct and nonzero, so no one or two columns sum to zero.
  (Exhaustive check over all $2^7$ vectors.)
- **Perfect.** $2^m = 8 = 1 + 7 = V(7,1)$.
- **Rank.** $r = 3$: three bits published, three bits leaked, no redundancy.
- **Total decoding.** Each of the $8$ syndromes is realised by exactly one
  pattern of weight $\le 1$: the syndrome $000$ by the zero pattern, and the
  syndrome $j$ (read as a binary numeral) by the single flip at position $j$.
  The transcript is literally the index of the erroneous bit.
- **Residual.** Exactly $2^{7-3}=16$ keys remain consistent with any transcript:
  **four secret bits** out of seven, and the identity $8 \times 16 = 2^7$ of
  Theorem 5.5 holds on the nose.

Both examples confirm that the universal bound of Section 4 is not merely
non-vacuous but tight, and that the classical perfect codes are exactly the
leakage-optimal reconciliation schemes.

---

## 6. Composition: multiple rounds

Practical protocols publish parity checks in several rounds. We model this by
stacking matrices.

**Definition 6.1 (Stacked scheme).** Given $S_1 = (H_1, \cdot)$ with $H_1$ of
size $m_1\times n$ and $S_2 = (H_2,\cdot)$ with $H_2$ of size $m_2\times n$, and
a radius $t$, the *composite* scheme is
$$S_1 \Vert S_2 \;=\; \left(\begin{pmatrix}H_1\\H_2\end{pmatrix},\ t\right),
\qquad \text{of size } (m_1+m_2)\times n .$$

**Proposition 6.2 (Composite transcript).** For all $x$, the composite syndrome
is the concatenation of the round syndromes:
$\sigma_{12}(x) = \big(\sigma_1(x),\ \sigma_2(x)\big)$. Consequently
$\sigma_{12}(x) = 0$ iff $\sigma_1(x)=0$ and $\sigma_2(x)=0$, so
$$\ker \sigma_{12} \;=\; \ker\sigma_1 \cap \ker\sigma_2,$$
and a key is consistent with the composite transcript exactly when it is
consistent with both round transcripts.

*Proof.* Row $i$ of the stacked matrix is row $i$ of $H_1$ for $i < m_1$ and row
$i-m_1$ of $H_2$ otherwise; the matrix-vector product is computed row-wise.
$\square$

**Theorem 6.3 (Subadditivity of leakage).**
$$\operatorname{rank}\begin{pmatrix}H_1\\H_2\end{pmatrix}
\;\le\; \operatorname{rank} H_1 + \operatorname{rank} H_2 .$$

*Proof.* Write $K_i = \ker\sigma_i$ and $r_i = \operatorname{rank} H_i$, so
rank–nullity gives $r_i + \dim K_i = n$ and likewise
$r_{12} + \dim(K_1 \cap K_2) = n$ by Proposition 6.2. The modular law for
subspaces gives $\dim(K_1+K_2) + \dim(K_1\cap K_2) = \dim K_1 + \dim K_2$, and
$\dim(K_1+K_2)\le n$. Combining,
$$n - r_{12} = \dim(K_1\cap K_2) = \dim K_1 + \dim K_2 - \dim(K_1+K_2)
\ \ge\ (n-r_1)+(n-r_2) - n,$$
i.e. $r_{12} \le r_1 + r_2$. $\square$

The proof identifies the *deficiency* precisely: $r_1 + r_2 - r_{12} =
n - \dim(K_1+K_2)$, which is the dimension of the intersection of the two row
spaces. Rounds that re-ask questions already answered pay nothing for the repeat.

**Corollary 6.4 (Residual key space under composition).**
$$|\sigma_1^{-1}(0)|\cdot|\sigma_2^{-1}(0)| \;\le\; 2^n\cdot |\sigma_{12}^{-1}(0)| ,$$
i.e. the two rounds together shrink the residual key space by at most the product
of their individual shrink factors.

**Theorem 6.5 (Correctness is monotone).** If $S_1$ is separating with radius
$t$, then $S_1\Vert S_2$ is separating with radius $t$, for *any* $S_2$.
Consequently the composite protocol still reconciles every $t$-close pair
exactly.

*Proof.* A nonzero composite kernel vector $c$ satisfies $\sigma_1(c)=0$ by
Proposition 6.2, so $\|c\|>2t$ by separation of $S_1$. Correctness then follows
from Theorem 2.9 applied to the composite. $\square$

Together, Theorems 6.3 and 6.5 give the designer's rule of thumb its exact form:
**extra rounds can only cost privacy, never correctness, and the cost is at most
additive in the round ranks.**

---

## 7. Algorithms and complexity

The theory above suggests four concrete computational tasks. We record them with
their complexities; all arithmetic is over $\mathbb{F}_2$ and can be done with
machine words, giving an extra $1/w$ factor in practice.

**(A) Transcript generation.** Compute $s = Hx$. Cost $O(mn)$ bit operations, or
$O(mn/w)$ word operations with bit-packed rows. This is Alice's entire
computational burden.

**(B) Syndrome decoding.** Given $s$, find $e$ with $He = s$ and $\|e\|\le t$.
For a general $H$ this is the classical syndrome-decoding problem, which is
NP-hard in general; but for the schemes used in practice it is easy. For a
perfect scheme, Corollary 5.3 guarantees the answer exists; for Hamming codes,
$s$ read as a binary numeral *is* the index of the flipped bit, giving $O(m)$
decoding. Generic small-$t$ decoding by enumeration costs
$O\big(V(n,t)\cdot m\big)$; precomputing a syndrome table costs $O(2^m \cdot n)$
memory and gives $O(1)$ lookups.

**(C) Rank computation (leakage accounting).** Gaussian elimination over
$\mathbb{F}_2$ on the $m\times n$ matrix: $O(m^2 n)$ bit operations, or
$O(m^2 n / w)$ with bit-packing. The output $r$ is precisely the number of bits
to subtract in privacy amplification.

**(D) Separation verification.** Certifying $\min\{\|c\| : c \in \ker H,\ c\ne 0\}
> 2t$ is computing the minimum distance of a linear code, which is NP-hard in
general. Two practical routes: enumerate the $2^{n-r}$ codewords, costing
$O(2^{n-r} n)$ and feasible for small $n$ (this is how the two worked examples
are certified); or use the column criterion, which for $t = 1$ reduces to
"the columns of $H$ are nonzero and pairwise distinct" — an $O(mn)$ check after
sorting — and for general $t$ to "no $2t$ columns are linearly dependent."

**Pipeline.** In deployment the pipeline is: (D) once, offline, when the matrix
is chosen; (C) once, offline, to fix the leakage figure $r$; then per session (A)
by Alice, (B) by Bob, followed by privacy amplification extracting $n - r$ bits.

---

## 8. Applications and discussion

**Quantum key distribution.** Reconciliation is the mandatory bridge between
sifting and privacy amplification. Theorem 3.10 is exactly the accounting a QKD
implementation must perform: from the $n$ sifted bits, subtract $r$ for the
reconciliation transcript (and further terms for the eavesdropper's quantum side
information, which composes with the transcript by Theorem 4.7) to obtain the
extractable secret length. Using $m$ instead of $r$ is a common, safe, but
lossy simplification; Theorem 3.4 says the correct figure is the rank.

**Fuzzy extractors and biometric keys.** The syndrome $\sigma(a)$ is precisely
the *secure sketch* of the code-offset construction: it allows recovery of $a$
from any $b$ within distance $t$, and Theorem 3.6 quantifies the entropy loss as
exactly $r$ bits. The universal bound of Theorem 4.3 shows that this loss is not
a defect of the code-offset construction but a law: any sketch supporting
$t$-error recovery loses at least $\log_2 V(n,t)$ bits.

**Why the worst-case framing is the right one.** All correctness statements here
are worst-case: no distribution on error patterns is assumed. This matters
because in adversarial settings the error pattern may be chosen by the adversary
(a noisy-channel attack), and any protocol whose correctness depends on the error
being "typical" fails under such an attack. The cost of this strength is that
$t$ must be chosen to dominate the physical error rate with margin.

**The unity of correctness and leakage.** It is worth restating the structural
observation that organises this paper. Both halves are statements about the
fibers $\sigma^{-1}(s)$. Correctness (Theorem 2.7) says each fiber meets the ball
$B_t$ in at most one point. Leakage (Theorem 3.4) says the fibers partition
$\mathbb{F}_2^n$ into $2^r$ blocks of size $2^{n-r}$. The separation hypothesis
controls the first reading; the rank controls the second; and the perfect case
(Section 5) is exactly the case where the two readings coincide, i.e. where the
ball hits every fiber exactly once.

**Limitations.** Three should be named. First, the decoder is specified
abstractly; for a general separating scheme it may be computationally
intractable, and totality is only established in the perfect case. Second, the
converse of Section 4 is worst-case over inputs, and hence does not yet bound the
*expected* transcript length of protocols with variable-length transcripts —
which is precisely where interactive protocols such as Cascade claim their
advantage. Third, the composition analysis in Section 6 covers stacked linear
rounds; the fully adaptive case, where the second round's matrix depends on the
first round's transcript, is not covered by Theorem 6.3 as stated, although the
pigeonhole bound of Theorem 4.7 still applies to the composite transcript.

---

## 9. Future directions

**Interactive advantage collapse for two-way reconciliation.** The converse of
Section 4 fixes Bob's string at $0$, which suffices to force $|T| \ge V(n,t)$. It
does not yet cover protocols whose transcript is allowed to be *shorter on
average* over a distribution of error patterns — the actual selling point of
interactive schemes such as Cascade. **Conjecture:** for the uniform error model
of weight exactly $t$, the expected transcript length of any correct two-way
protocol is at least $\log_2 V(n,t) - O(1)$, so interaction buys at most a
constant number of bits. The key insight is that fixing one party's input
converts interaction into a one-way encoding, and an averaging (entropy) version
of that reduction turns the worst-case injection of Theorem 4.2 into an
expected-length bound via Kraft's inequality for prefix-free codes.

**Leakage superadditivity gap for composed rounds.** Theorem 6.3 gives
$r_{12} \le r_1 + r_2$. **Conjecture:** the deficiency $r_1 + r_2 - r_{12}$
equals the dimension of the intersection of the two row spaces — the proof of
Theorem 6.3 already exhibits it as $n - \dim(K_1+K_2)$, and the remaining step is
to identify that quantity with the row-space overlap — and consequently a
$k$-round protocol whose rounds are pairwise independent in this sense leaks
exactly $\sum_i r_i$ bits, with no saving.

**Adaptive composition.** Extend Section 6 to rounds whose parity-check matrices
are chosen as a function of earlier transcripts. The expected outcome is that the
rank bound survives in the form of an average, with the per-round rank replaced
by a conditional rank.

**Non-binary and non-Hamming metrics.** The arguments of Sections 2–4 use only
that the ambient object is a finite abelian group with a translation-invariant
metric and a linear syndrome map. Generalising to $\mathbb{F}_q^n$ (replacing
$V(n,t)$ by $\sum_{i\le t}\binom{n}{i}(q-1)^i$), and to edit or Lee metrics,
should be routine and would cover reconciliation of non-binary measurement data.

**Rate-optimal families.** Perfect schemes exist only for very special
parameters (Hamming, Golay, repetition). For a fixed error rate $\delta = t/n$
and growing $n$, the natural question is how closely a family of schemes can
approach the bound $r/n \to \log_2 V(n,\delta n)/n \to h(\delta)$, the binary
entropy function. Low-density parity-check families are the practical answer; a
matching exact-leakage analysis in the present style, with $r$ rather than $m$ as
the leakage figure, would sharpen the standard accounting.

---

## 10. Conclusion

Information reconciliation admits a complete and exact theory. The public
transcript of the syndrome protocol is a linear image of the key; correctness of
the corrected key follows from a single inequality on the minimum weight of the
kernel; and the privacy cost is not merely bounded but *determined*, equal to the
rank of the parity-check matrix, in counting, min-entropy, Shannon, and guessing
formulations alike, tied together by the chain rule
$n = H(\text{transcript}) + H_\infty(\text{key}\mid\text{transcript})$.

The cost is moreover unavoidable: any correct protocol whatsoever, however
interactive or nonlinear, must publish at least $\log_2 V(n,t)$ bits, and on some
input genuinely suffers that loss. Classical perfect codes — the three-bit
repetition scheme, the $[7,4]$ Hamming scheme — attain the bound exactly, leaving
$1$ and $4$ secret bits respectively. Composition of rounds is subadditive in
leakage and monotone in correctness.

Correctness and privacy, in this subject, are not competing desiderata to be
balanced by engineering judgement. They are two readings of the same partition of
the key space into syndrome fibers, and the number that governs both is the rank.
