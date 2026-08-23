# A Domain-Parameterised Budget Law for Attention Key Retention

### The domain axis is a torsor, the envelope rule needs a shared increment, and accuracy is orthogonal to the knee

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

Truncating an attention mechanism's key cache to its $k$ heaviest keys degrades next-token
accuracy; the *knee* $k^*$ is the smallest budget on a measurement grid retaining a fixed
fraction of full accuracy. We study how $k^*$ depends jointly on the corpus domain and on
the context length, and we establish four structural results.

First, the knee is the left adjoint of the accuracy curve: for monotone sweeps,
$k^*_{\mathrm{idx}} \le j \iff \tau \le \mathrm{acc}(j)$. From this adjunction we derive a
*data-determination* principle — a knee is fixed by exactly two measured readings, the last
failing and the first passing grid index — so knee claims are readings rather than fits.
Applied to a measured sweep over Python source at two context lengths, this yields
$k^*=12$ at context $512$ and $k^*=16$ at context $1024$, against prose values $16$ and
$20$: a constant shift of $-4$ keys, exactly one grid step, at both contexts.

Second, we introduce the two-parameter *budget law*
$k^*(\text{domain}, d) = \mathrm{base}(\text{domain}) + \mathrm{inc}\cdot d$, where $d$
counts context doublings. We prove affine rigidity (agreement at any two distinct contexts
forces equality of laws), non-identifiability from one context, and — the structural
content of the measurement — that an inter-domain shift is context-independent **if and
only if** the two domains share an increment. Unequal increments force a computable
crossover, so the observed constancy was falsifiable.

Third, we show the domain axis at a fixed scale is a $\mathbb{Z}$-torsor: a unique
translation connects any two domains, translations compose additively along chains, and
re-basing all domains by a common amount leaves every inter-domain shift invariant. Hence
an individual base is not an observable; only differences are. Within a torsor fibre the
pointwise budget order is the order of bases and the mixed-workload envelope is the join,
itself a law with the largest base. Outside a fibre this fails maximally: if two domains
have unequal increments and crossing bases, **no** budget law computes their envelope.

Fourth, we prove that the domain parameter is not a measure of predictive difficulty. Every
pair (full accuracy, knee) is realised by an actual domain, hence no function of accuracy
predicts the knee, and a strictly more accurate domain may need strictly fewer *or*
strictly more keys. A concentration bridge identifies what the base does measure: a knee of
$k$ at tolerance $\tau$ certifies a single key carrying more than $\tau/(k+1)$ of the
attention mass.

Finally, we confront a mechanistic rival — geometric attention decay with a rescaled rate,
which divides rather than shifts the knee. Both mechanisms reproduce all four measured
cells exactly, an identifiability failure we state as a theorem; but the ceiling bracket
forces the rescaling exponent above $5/4$, whence every rescaling model predicts at most
$23$ keys at context $4096$ where the additive law predicts exactly $24$. We show no
exponent reconciles both, and that context $4096$ is the first that decides.

**Keywords.** attention key retention, knee of a sweep, Galois connection, budget law,
$\mathbb{Z}$-torsor, envelope of affine functions, grid resolution, attention concentration.

---

## 1. Introduction

### 1.1 The sizing problem

An autoregressive attention model consulting a history of $N$ tokens holds $N$ key/value
pairs in memory. Memory is linear in $N$; throughput and deployability are not. The
standard mitigation is *key retention*: at each decoding step the model attends only to the
$k$ keys carrying the greatest attention mass, and the remainder are discarded. The
practical question is how small $k$ may be.

The empirical answer is characteristically sharp. Retained accuracy — accuracy under
truncation, normalised by untruncated accuracy — rises steeply with $k$ and then flattens.
The location of the bend, the **knee**, is what a deployment must know.

### 1.2 What is at stake structurally

A knee is a single integer, and single integers invite two errors. The first is to treat
$k^*$ as a fitted parameter of a curve, when it is in fact determined by two readings. The
second, more consequential, is to treat $k^*$ as a scalar summary of *difficulty* — the
belief that a corpus a model predicts well is a corpus it can afford to forget. This paper
dismantles both.

The vehicle is a domain jump. Holding the harness, the acceptance bar, the grid, the window
count, and the split protocol byte-identical, we replace an English prose corpus with
Python source (ten files of the CPython standard library) and re-run the sweep at two
context lengths.

### 1.3 The measurement

Retained accuracies for the code corpus, on a grid of step $4$:

| budget $k$ | $4$ | $8$ | $12$ | $16$ | $20$ | $24$ |
|---|---|---|---|---|---|---|
| ctx $512$ | $0.930$ | $0.969$ | $\mathbf{0.981}$ | $0.987$ | $0.988$ | $0.989$ |
| ctx $1024$ | — | $0.960$ | $0.976$ | $\mathbf{0.981}$ | $0.986$ | $0.987$ |

with acceptance bar $\tau = 0.98$. Full (untruncated) accuracy on the code corpus is
$0.6296$ at context $512$ and $0.6520$ at context $1024$, in both cases above the prose
figure. The resulting knees, against the prose reference:

| context | code $k^*$ | prose $k^*$ | shift |
|---|---|---|---|
| $512$ | $12$ | $16$ | $-4$ |
| $1024$ | $16$ | $20$ | $-4$ |

Three horns were registered before the run. **P1** — knees transfer across the domain jump
to within one grid step — *confirmed*. **P2** — the shift is exactly one grid step at both
contexts — *confirmed*. **P3** — the domain the model predicts more accurately requires at
least as many keys — *refuted*: code is the more accurately predicted corpus and needs
strictly fewer keys.

### 1.4 Contributions and organisation

Section 2 develops the knee as an adjoint and proves data determination. Section 3 applies
it to the measurement. Section 4 introduces budget laws and proves rigidity, the
shift/increment equivalence, and the crossover theorem. Section 5 establishes the torsor
structure of the domain axis. Section 6 treats the mixed-workload envelope, positively
inside a fibre and negatively outside it. Section 7 proves accuracy/knee decoupling and the
concentration bridge. Section 8 develops the decay-rescaling rival and the discriminating
experiment. Section 9 addresses grid resolution. Sections 10–12 give algorithms,
discussion, limitations, and future work.

---

## 2. The knee as an adjoint

Throughout, a **sweep** is a function $\mathrm{acc} : \mathbb{N} \to \mathbb{Q}$ assigning
to each grid index $j$ the retained accuracy at budget $g \cdot j$, where $g$ is the grid
step. The **bar** is a rational $\tau$.

**Definition 2.1 (knee index, knee budget).**
$$k^*_{\mathrm{idx}}(\mathrm{acc}, \tau) \;=\; \inf\{\, j \in \mathbb{N} : \tau \le \mathrm{acc}(j) \,\},
\qquad
k^*(g, \mathrm{acc}, \tau) \;=\; g \cdot k^*_{\mathrm{idx}}(\mathrm{acc},\tau).$$

Two immediate facts hold with no hypotheses: any passing index bounds the knee above
($\tau \le \mathrm{acc}(k) \Rightarrow k^*_{\mathrm{idx}} \le k$), and every index strictly
below the knee fails the bar.

**Theorem 2.2 (Galois connection).** *Let $\mathrm{acc}$ be monotone and suppose some index
passes the bar. Then for every $k$,*
$$k^*_{\mathrm{idx}}(\mathrm{acc},\tau) \le k \quad\Longleftrightarrow\quad \tau \le \mathrm{acc}(k).$$

*Proof sketch.* ($\Rightarrow$) The knee itself passes, since the passing set is nonempty
and the infimum of a nonempty set of naturals is a member; monotonicity then transports
this to any larger $k$. ($\Leftarrow$) Immediate from the infimum bound. $\square$

Thus $k^*_{\mathrm{idx}}(-,\tau)$ is left adjoint to $\mathrm{acc}$ between the budget
order and the accuracy order. Two standard consequences follow formally.

**Corollary 2.3 (monotonicity in the bar).** If $\tau \le \sigma$ and some index passes
$\sigma$, then $k^*_{\mathrm{idx}}(\mathrm{acc},\tau) \le k^*_{\mathrm{idx}}(\mathrm{acc},\sigma)$.

**Corollary 2.4 (antitonicity in the sweep).** If $\mathrm{acc}(j) \le \mathrm{acc}'(j)$
for all $j$ and some index passes for $\mathrm{acc}$, then
$k^*_{\mathrm{idx}}(\mathrm{acc}',\tau) \le k^*_{\mathrm{idx}}(\mathrm{acc},\tau)$: a
uniformly better-retaining domain never needs more keys.

The methodologically decisive consequence is the following.

**Theorem 2.5 (data determination).** *Let $\mathrm{acc}$ be monotone and let $j$ satisfy
$\mathrm{acc}(j) < \tau \le \mathrm{acc}(j+1)$. Then
$k^*_{\mathrm{idx}}(\mathrm{acc},\tau) = j+1$.*

*Proof sketch.* The upper bound is the infimum bound applied at $j+1$. For the lower bound,
suppose $k^*_{\mathrm{idx}} \le j$; Theorem 2.2 then gives $\tau \le \mathrm{acc}(j)$,
contradicting the bracket. $\square$

**Corollary 2.6 (bracket congruence).** Two monotone sweeps with the same bracketing pair
have the same knee, regardless of their values at every other index.

A knee claim therefore commits to exactly two numbers. Every other point in a sweep is
corroboration of monotonicity, not evidence for the knee. This is why the results below are
stated as: *every* monotone sweep agreeing with the measurement at the bracketing pair has
the stated knee.

---

## 3. The measurement, formalised

Fix the grid step $g = 4$ and the bar $\tau = 0.98$.

**Theorem 3.1 (code at context 512).** *Every monotone sweep with
$\mathrm{acc}(2) = 0.969$ and $\mathrm{acc}(3) = 0.981$ has knee index $3$, i.e. budget
$k^* = 12$ keys.*

*Proof.* $0.969 < 0.98 \le 0.981$; apply Theorem 2.5 at $j = 2$. $\square$

**Theorem 3.2 (code at context 1024).** *Every monotone sweep with
$\mathrm{acc}(3) = 0.976$ and $\mathrm{acc}(4) = 0.981$ has knee index $4$, i.e.
$k^* = 16$ keys.*

The hypotheses are not vacuous: the measured tables

$$S_{512} = (0,\; 0.930,\; 0.969,\; 0.981,\; 0.987,\; 0.988,\; 0.989, \dots),$$
$$S_{1024} = (0,\; 0,\; 0.960,\; 0.976,\; 0.981,\; 0.986,\; 0.987, \dots)$$

are monotone (verified index by index; the tails are constant), so the knees $12$ and $16$
are attained by actual curves. Moreover all sub-knee readings genuinely fail: $S_{512}(j) < \tau$
for $j < 3$ and $S_{1024}(j) < \tau$ for $j < 4$, so the ✗ column of the sweep is honest.

*Remark 3.3.* The $k=4$ cell at context $1024$ was not swept. It cannot matter: monotonicity
already places it below the $k=8$ reading of $0.960 < \tau$, and by Theorem 2.5 no
unmeasured index can enter a knee value determined by a bracket.

---

## 4. Budget laws

**Definition 4.1 (budget law).** A **budget law** is a pair $L = (b, c) \in \mathbb{Z}^2$
with **base** $b$ and **increment** $c$, evaluated on the number $d$ of context doublings by
$$L(d) \;=\; b + c\,d .$$
By convention $d=0$ is context $512$, so $d=1$ is $1024$, $d=2$ is $2048$, $d=3$ is $4096$.

Immediately $L(0) = b$, $L(d+1) = L(d) + c$, and $L$ is monotone in $d$ exactly when
$c \ge 0$.

**Theorem 4.2 (affine rigidity).** *If two budget laws agree at two distinct contexts
$d \ne e$, they are equal.*

*Proof sketch.* Subtracting the two agreement equations gives
$(c_A - c_B)(d - e) = 0$ over $\mathbb{Z}$; since $d \ne e$ the second factor is nonzero and
$\mathbb{Z}$ is a domain, so $c_A = c_B$; substituting back gives $b_A = b_B$. $\square$

The special case $d=0, e=1$ is the identifiability statement used for the fit. Its converse
is equally important:

**Proposition 4.3 (one context never identifies).** For every law $L$ and every context
$d$ there is a law $L' \ne L$ with $L'(d) = L(d)$; explicitly $L' = (b - d,\; c+1)$.

This is precisely why the round had to be run at two context lengths.

**Theorem 4.4 (constant shift $\iff$ shared increment).** *For budget laws $A, B$:*
$$\big(\exists s \in \mathbb{Z}\; \forall d,\; A(d) - B(d) = s\big) \quad\Longleftrightarrow\quad c_A = c_B.$$

*Proof sketch.* ($\Leftarrow$) With $c_A = c_B$ the increments cancel and the difference is
$b_A - b_B$ at every $d$. ($\Rightarrow$) Evaluate the hypothesis at $d=0$ and $d=1$:
$b_A - b_B = s$ and $(b_A + c_A) - (b_B + c_B) = s$; subtracting gives
$c_A = c_B$. $\square$

**Corollary 4.5.** With a shared increment, $A(d) - B(d) = b_A - b_B$ for every $d$: the
shift is a context-free integer.

This is the structural content of horn P2. A shift measured to be the same at two contexts
is not a coincidence to be explained; it is *equivalent* to the factorisation "increment
depends only on scale, base only on domain". The measurement was falsifiable because the
alternative has teeth:

**Theorem 4.6 (unequal increments force a crossover).** *If $c_A < c_B$ then there is a
computable $D \in \mathbb{N}$ with $A(d) < B(d)$ for all $d \ge D$; one may take
$D = (b_A - b_B)^+ + 1$.*

*Proof sketch.* For $d \ge D$ we have $b_A - b_B < d$ and $c_B - c_A \ge 1$, hence
$b_A - b_B < d \le d(c_B - c_A)$, which rearranges to $A(d) < B(d)$. $\square$

So had the code and prose increments differed, the observed shift would not merely have
drifted; it would have reversed sign at a computable context.

### 4.1 The fit

**Definition 4.7.** $L_{\mathrm{code}} = (12, 4)$ and $L_{\mathrm{prose}} = (16, 4)$.

**Theorem 4.8 (fit and uniqueness).** $L_{\mathrm{code}}(0)=12$, $L_{\mathrm{code}}(1)=16$,
$L_{\mathrm{prose}}(0)=16$, $L_{\mathrm{prose}}(1)=20$. Any law with the code readings equals
$L_{\mathrm{code}}$; any law with the prose readings equals $L_{\mathrm{prose}}$ (Theorem 4.2).

**Theorem 4.9 (the measured shift).** For all $d$,
$L_{\mathrm{prose}}(d) - L_{\mathrm{code}}(d) = 4 = g$, the grid step. Consequently
$|L_{\mathrm{prose}}(d) - L_{\mathrm{code}}(d)| \le g$ (horn P1), the two laws never cross
($L_{\mathrm{code}}(d) < L_{\mathrm{prose}}(d)$ for all $d$), and by Theorem 4.4 the
increments coincide.

**Theorem 4.10 (consistency of §3 and §4).** The knee budgets computed from the measured
sweeps equal the fitted law's predictions: $k^*(S_{512}) = L_{\mathrm{code}}(0)$
and $k^*(S_{1024}) = L_{\mathrm{code}}(1)$.

**Theorem 4.11 (falsifiable extrapolation).** $L_{\mathrm{code}}(3) = 24$ and
$L_{\mathrm{prose}}(3) = 28$: at context $4096$ the law predicts $24$ keys for code and $28$
for prose.

---

## 5. The domain axis is a $\mathbb{Z}$-torsor

Fix an increment $c$ and consider the **fibre** $\mathcal{F}_c = \{L : c_L = c\}$ of all
budget laws at that scale behaviour.

**Definition 5.1 (translation).** For $t \in \mathbb{Z}$, let $\mathrm{tr}_t(b,c) = (b+t, c)$.

Translation preserves the increment, satisfies $\mathrm{tr}_t(L)(d) = L(d) + t$ for every
context, and composes: $\mathrm{tr}_s \circ \mathrm{tr}_t = \mathrm{tr}_{s+t}$, with
$\mathrm{tr}_0 = \mathrm{id}$. So $\mathbb{Z}$ acts on $\mathcal{F}_c$.

**Theorem 5.2 (free and transitive action).** *If $c_A = c_B$ then there is a **unique**
$t \in \mathbb{Z}$ with $\mathrm{tr}_t(A) = B$, namely $t = b_B - b_A$.*

*Proof sketch.* Existence is direct. For uniqueness, comparing bases in
$\mathrm{tr}_t(A) = B$ gives $b_A + t = b_B$. $\square$

Hence each fibre is a $\mathbb{Z}$-torsor. Choosing a base as origin gives a bijection
$\mathcal{F}_c \cong \mathbb{Z}$, $L \mapsto b_L$ — a coordinate chart, not a canonical
identification. *A domain, at a fixed scale, is exactly one integer of information.*

**Definition 5.3 (shift).** $\mathrm{shift}(A,B) = b_B - b_A$.

**Theorem 5.4 (torsor arithmetic).** $\mathrm{shift}(A,A) = 0$;
$\mathrm{shift}(B,A) = -\mathrm{shift}(A,B)$; and the **cocycle law**
$$\mathrm{shift}(A,B) + \mathrm{shift}(B,C) = \mathrm{shift}(A,C).$$
Moreover, when $c_A = c_B$, $\mathrm{shift}(A,B) = B(d) - A(d)$ for every $d$ — the shift is
the observed budget difference, at any context.

The cocycle law is the statement that a ladder of domains is generated by its consecutive
gaps: gaps compose additively along chains, so a domain taxonomy is determined by its
adjacent differences.

**Theorem 5.5 (only differences are observable).** *For every $t \in \mathbb{Z}$ and all
laws $A, B$ in a common fibre,*
$$\mathrm{shift}(\mathrm{tr}_t A,\; \mathrm{tr}_t B) \;=\; \mathrm{shift}(A,B).$$
*Moreover, for any target value $\beta$ there is a translation $t$ with
$(\mathrm{tr}_t A)$'s base equal to $\beta$, all shifts unchanged.*

*Proof sketch.* The first is $(b_B + t) - (b_A + t) = b_B - b_A$. For the second take
$t = \beta - b_A$ and apply the first. $\square$

**Interpretation.** The origin of the domain axis is pure convention. The experiment
measures $\mathrm{shift}(\mathrm{code}, \mathrm{prose}) = 4$; it does **not** measure $12$
and $16$ separately, and no experiment of this design could. The numbers $12$ and $16$ are
coordinates in a chart induced by declaring context $512$ to be $d=0$; the invariant content
is the single integer $4$.

**Theorem 5.6 (the measured domain axis).** $c_{L_{\mathrm{code}}} = c_{L_{\mathrm{prose}}}$;
there is a unique $t$ with $\mathrm{tr}_t(L_{\mathrm{code}}) = L_{\mathrm{prose}}$;
$\mathrm{shift}(L_{\mathrm{code}}, L_{\mathrm{prose}}) = 4 = g$; and this shift is invariant
under common re-basing. A hypothetical third domain at base $8$ extends the ladder
consistently: $\mathrm{shift}((8,4), L_{\mathrm{code}}) + \mathrm{shift}(L_{\mathrm{code}},
L_{\mathrm{prose}}) = 8$.

---

## 6. Mixed workloads: the envelope

Deployments serve heterogeneous traffic. The operational object is the **envelope**
$E(d) = \max_i L_i(d)$ over the domains present.

### 6.1 Inside a fibre: the envelope is the join

**Theorem 6.1 (order = order of bases).** *If $c_A = c_B$ then
$\big(\forall d,\; A(d) \le B(d)\big) \iff b_A \le b_B$.*

*Proof sketch.* ($\Rightarrow$) evaluate at $d=0$. ($\Leftarrow$) add $c\,d$ to both sides.
$\square$

**Theorem 6.2 (envelope law).** *For a nonempty finite family $(b_i)_{i \in S}$ with common
increment $c$,*
$$\max_{i \in S}\big(b_i + c\,d\big) \;=\; \Big(\max_{i\in S} b_i\Big) + c\,d ,$$
*so the envelope is again a budget law, with base the largest base.*

*Proof sketch.* Translation $x \mapsto x + cd$ is an order isomorphism of $\mathbb{Z}$,
hence commutes with finite suprema. $\square$

**Corollary 6.3 (deployment rule).** Size the cache by the **largest-base domain present**.
For prose/code, $\max(L_{\mathrm{code}}(d), L_{\mathrm{prose}}(d)) = L_{\mathrm{prose}}(d)$ at
every $d$, and sizing by code under-provisions the mixture by exactly one grid step,
$$\max(L_{\mathrm{code}}(d), L_{\mathrm{prose}}(d)) - L_{\mathrm{code}}(d) = 4,$$
independently of context.

Corollary 6.3 is a falsifiable claim about corpus mixing: the base of a mixture is the
**maximum** of the constituent bases, never a mixture-weighted mean. Interleaving 90% code
with 10% prose still costs prose's budget.

### 6.2 Outside a fibre: the envelope is not a law

The shared increment in Theorem 6.2 is load-bearing to the maximum possible extent.

**Theorem 6.4 (no envelope law).** *Let $A, B$ be budget laws with $c_A < c_B$ and
$b_B < b_A$ (unequal increments, crossing bases). Then there is **no** budget law $C$ with
$C(d) = \max(A(d), B(d))$ for all $d \in \mathbb{N}$.*

*Proof.* By Theorem 4.6 there is $D$ with $A(d) < B(d)$ for all $d \ge D$, so any such $C$
satisfies $C(d) = B(d)$ for all $d \ge D$; in particular at the two distinct contexts $D$
and $D+1$. Affine rigidity (Theorem 4.2) forces $C = B$. But then
$C(0) = b_B$, whereas $\max(A(0), B(0)) = \max(b_A, b_B) = b_A > b_B$ since the bases cross.
Contradiction. $\square$

**Corollary 6.5 (the failure is realisable).** Taking $A = (16,2)$ and $B = (12,6)$
satisfies both hypotheses, so no budget law computes
$\max\big(16 + 2d,\; 12 + 6d\big)$.

The envelope in Corollary 6.5 reads $16, 18, 24, 30, 36, \dots$ — a genuine kink at $d=1$
that no two-parameter affine formula can straighten. Single-formula cache sizing for a mixed
workload is therefore a privilege, not a modelling default: it is exactly what the measured
constancy of the $-4$ shift (equivalently, the shared increment, Theorem 4.4) buys.

---

## 7. Accuracy is orthogonal to the knee

Horn P3 asserted that the more accurately predicted domain needs at least as many keys. We
show it is not merely false on this data but underivable from accuracy data of any kind.

**Definition 7.1 (measured domain).** A **measured domain** is a pair $D = (a, P)$ where
$a \in \mathbb{Q}$ is full untruncated accuracy and $P$ is an **attention profile**: a
nondecreasing cumulative mass function $\mathrm{cum}_P : \mathbb{N} \to \mathbb{Q}$ with
$\mathrm{cum}_P(0)=0$, the mass of the $j$-th key being
$\mathrm{cum}_P(j+1)-\mathrm{cum}_P(j)$. The **knee at tolerance $\tau$**,
$\mathrm{knee}_\tau(D)$, is the least $k$ with $\tau \le \mathrm{cum}_P(k)$.

**Theorem 7.2 (decoupling).** *For every tolerance $0 < \tau < 1$, every accuracy value
$a$, and every $k \ge 1$, there is a measured domain $D$ with full accuracy exactly $a$ and
$\mathrm{knee}_\tau(D) = k$.*

*Proof sketch.* Take the **uniform profile** on $k$ keys: mass $\tau/k$ on each of the first
$k$ keys, so $\mathrm{cum}(j) = \tau \min(j,k)/k$. Then $\mathrm{cum}(j) < \tau$ for $j<k$
and $\mathrm{cum}(k) = \tau$, giving knee exactly $k$; the accuracy coordinate is a free
label. $\square$

**Theorem 7.3 (no accuracy functional).** *For $0 < \tau < 1$ there is no function
$g : \mathbb{Q} \to \mathbb{N}$ with $\mathrm{knee}_\tau(D) = g(\mathrm{acc}_{\mathrm{full}}(D))$ for all
measured domains $D$.*

*Proof.* By Theorem 7.2 pick $D, E$ both with accuracy $\tfrac12$ and knees $1$ and $2$.
Then $g(\tfrac12) = 1$ and $g(\tfrac12) = 2$. $\square$

**Theorem 7.4 (both directions occur).** *For $0<\tau<1$ there exist measured domains
$D, E$ with $\mathrm{acc}_{\mathrm{full}}(E) < \mathrm{acc}_{\mathrm{full}}(D)$ and
$\mathrm{knee}_\tau(D) < \mathrm{knee}_\tau(E)$ — the observed code/prose pattern — and also
domains realising the reverse. So no monotone weakening of P3 survives either.*

Explicit witnesses: accuracies $\tfrac23$ and $\tfrac13$ paired with knees $(1,2)$ for the
first claim and $(2,1)$ for the second.

**Proposition 7.5 (the measured cell is realisable).** There exist measured domains with
full accuracy $0.6296$ and knee $12$, and with full accuracy $0.6520$ and knee $16$ — the
recorded code cells at contexts $512$ and $1024$ — so the framework does contain the
observation.

### 7.1 What the base does measure: concentration

**Theorem 7.6 (a knee certifies a heavy key).** *Let $P$ be an attention profile with
$0 < \tau < 1$ and $\mathrm{knee}_\tau(P) = k$. Then some key carries more than
$\tau/(k+1)$ of the mass:*
$$\exists j,\quad \frac{\tau}{k+1} \;<\; \mathrm{cum}_P(j+1) - \mathrm{cum}_P(j).$$

*Proof sketch.* Contrapositive of the concentration bound: if every key's mass is at most
$m>0$, then accumulating $\tau$ requires at least $\tau/m$ keys, i.e.
$\mathrm{knee}_\tau(P) \ge \tau/m$. Putting $m = \tau/(k+1)$ would give
$k = \mathrm{knee}_\tau(P) \ge k+1$, absurd. $\square$

**Corollary 7.7 (the shift is a shape statement).** With code meeting tolerance $\tau$ at
$12$ keys, the code profile contains a key of mass exceeding $\tau/13$; in particular the
code profile **cannot** be flat at level $\tau/13$. For prose, whose knee is $16$, the
analogous guarantee only reaches $\tau/17$.

The $-4$ shift is therefore a measurable statement about the *shape* of code attention —
code has a heavier head — and not about its difficulty. This is consistent with the
qualitative character of source code: references are sharp (an identifier binds at one
line, a delimiter matches one partner, a call resolves to one definition), whereas prose
reference is diffuse.

---

## 8. The adversarial round: additive shift or rescaled decay?

An additive fit through two points invites suspicion. We therefore develop a *mechanistic*
rival with a different functional form and push both to breaking point.

### 8.1 Geometric profiles and the continuous knee

**Definition 8.1.** A **geometric profile** with decay rate $r \in (0,1)$ has residual mass
$r^k$ after $k$ keys. Given residual tolerance $\rho = 1 - \tau \in (0,1)$, its knee is
$$k_{\mathrm{geo}}(r,\rho) = \inf\{\, k \in \mathbb{N} : r^k \le \rho \,\}.$$

**Theorem 8.2 (exact knee).** *For $0<r<1$ and $\rho>0$,*
$$k_{\mathrm{geo}}(r,\rho) \;=\; \left\lceil \frac{\log \rho}{\log r} \right\rceil .$$

*Proof sketch.* Since $\log r < 0$, $r^k \le \rho \iff k \log r \le \log \rho \iff
X \le k$ where $X = \log\rho/\log r$. The least natural $k$ with $X \le k$ is
$\lceil X \rceil$. $\square$

Call $X = \log\rho/\log r$ the **continuous knee**: the real number of which the measured
integer is the ceiling.

**Theorem 8.3 (rescaling divides the knee).** *For $a > 0$,*
$$k_{\mathrm{geo}}(r^a,\rho) = \left\lceil \frac{X}{a} \right\rceil,
\qquad X = \frac{\log\rho}{\log r}.$$

*Proof sketch.* $\log(r^a) = a \log r$, so the quotient defining the continuous knee is
divided by $a$; apply Theorem 8.2 to $r^a \in (0,1)$. $\square$

This makes "the same attention shape, decaying $a$ times faster" precise, and shows the
rival mechanism acts **multiplicatively** on the knee where the budget law acts additively.

**Proposition 8.4 (the model is nonempty).** Every $X > 0$ is the continuous knee of an
honest geometric profile: take $r = e^{-1}$ and $\rho = e^{-X}$, both in $(0,1)$, giving
$k_{\mathrm{geo}}(r,\rho) = \lceil X\rceil$.

### 8.2 Both mechanisms fit all four cells

**Lemma 8.5 (ceiling bracket).** If $\lceil X \rceil = n$ then $X \le n$; and if in addition
$n \ge 1$ then $n - 1 < X$.

**Theorem 8.6 (identifiability failure).** *Both mechanisms reproduce the four measured
knees exactly:*

* *Additive:* $L_{\mathrm{prose}}(0)=16$, $L_{\mathrm{prose}}(1)=20$,
  $L_{\mathrm{code}}(0)=12$, $L_{\mathrm{code}}(1)=16$.
* *Rescaling:* with $a = 251/200 = 1.255$ and prose continuous knees $X_0 = 15.05$,
  $X_1 = 20$,
  $$\lceil X_0 \rceil = 16,\quad \lceil X_0/a \rceil = 12, \quad
    \lceil X_1 \rceil = 20,\quad \lceil X_1/a \rceil = 16 .$$

*Verification.* $15.05/1.255 = 11.99\ldots \le 12$ and $> 11$; $20/1.255 = 15.93\ldots \le 16$
and $>15$. By Proposition 8.4 the required geometric profiles exist. $\square$

**Two contexts therefore cannot distinguish an additive base shift from a rescaling of the
attention decay rate.** We state this as the honest limit of the round rather than as a
caveat.

### 8.3 The discriminating experiment

The identifiability failure is removable, and the ceiling bracket removes it.

**Theorem 8.7 (the 512 cell forces $a > 5/4$).** *If $a > 0$, $\lceil X \rceil = 16$ and
$\lceil X/a \rceil = 12$, then $a > 5/4$.*

*Proof.* Lemma 8.5 gives $X > 15$ and $X/a \le 12$, hence $X \le 12a$; so $15 < 12a$, i.e.
$a > 5/4$. $\square$

**Theorem 8.8 (rescaling predicts at most 23 at ctx 4096).** *If $a > 5/4$ and
$\lceil X_3 \rceil = 28$ then $\lceil X_3/a \rceil \le 23$.*

*Proof.* $X_3 \le 28$ and $a > 5/4$ give $X_3/a < 28 \cdot 4/5 = 22.4 \le 23$; take
ceilings. $\square$

**Theorem 8.9 (the separation).** *The additive law predicts exactly $24$ keys for code at
context $4096$. Every decay-rescaling model reproducing the measured $512$ cell predicts
strictly fewer. A single measurement at context $4096$ therefore separates the two
mechanisms.*

**Theorem 8.10 (the exponent window closes).** *There is no $a > 0$ and no $X_0, X_3$ with
$\lceil X_0 \rceil = 16$, $\lceil X_0/a \rceil = 12$, $\lceil X_3 \rceil = 28$ and
$\lceil X_3/a \rceil = 24$.*

*Proof.* The first pair forces $a > 5/4$ (Theorem 8.7). The last pair forces $X_3/a > 23$
while $X_3 \le 28$, hence $23a < 28$, i.e. $a < 28/23 \approx 1.2174$. But
$5/4 = 1.25 > 28/23$. Contradiction. $\square$

So a $4096$ reading of $24$ kills the multiplicative mechanism outright; any reading $\le 23$
kills the additive law. This is a genuine pre-registered decision.

**Theorem 8.11 (the separation is sharp).** *Context $4096$ is the first that decides.* The
single witness $a = 251/200$ also reproduces the additive prediction at context $2048$:
$L_{\mathrm{code}}(2) = 20$, and with prose continuous knee $24$ one has
$\lceil 24 \rceil = 24$, $\lceil 24/a \rceil = 20$. No measurement below $4096$ separates
the mechanisms.

*Remark 8.12.* The general statement behind Theorems 8.7–8.10 is that the admissible
exponent window is
$$\bigcap_d \left( \frac{P_d - 1}{C_d},\; \frac{P_d}{C_d - 1} \right),$$
where $P_d$ and $C_d$ are the prose and code readings at doubling $d$; the additive and
multiplicative branches are numerically indistinguishable exactly while this window is
nonempty, and it becomes empty at $d = 3$.

---

## 9. Grid resolution: the instrument sets the ceiling on discovery

**Definition 9.1.** For grid step $g \ge 1$, $R_g(k) = g\lceil k/g \rceil$,
the least multiple of $g$ at or above $k$.

**Proposition 9.2.** If $g \mid k$ then $R_g(k) = k$: readings already on the
grid are undistorted, so the sweeps of §3 are read faithfully on the step-$4$ grid.

**Theorem 9.3 (a coarse grid hides the shift).**
$$R_8(12) = R_8(16) = 16 .$$
On a grid of step $8$ the code knee $12$ and the prose knee $16$ are the *same reading*, and
the entire effect vanishes without trace. On the step-$4$ grid,
$R_4(12) = 12 \ne 16 = R_4(16)$.

**Proposition 9.4 (general aliasing criterion).** Two knees are indistinguishable on a grid
of step $g$ exactly when they lie in the same $g$-cell, i.e. when
$\lceil a/g \rceil = \lceil b/g \rceil$.

**Consequence.** A domain effect of size $s$ is observable only on grids finer than $s$. The
binding constraint on what a limited-memory experiment can detect is therefore the **grid
step**, not the number of evaluation windows, the corpus size, or the tightness of the bar.
No amount of statistical power substitutes for resolution.

---

## 10. Algorithms

Three procedures suffice to reproduce and extend the entire analysis.

### 10.1 Bracketed knee extraction

Given a monotone sweep on a grid of step $g$ and a bar $\tau$, scan for the unique index $j$
with $\mathrm{acc}(j) < \tau \le \mathrm{acc}(j+1)$ and return $g(j+1)$, together with the
bracketing pair as a certificate. Complexity $O(n)$ in the number of grid points (or
$O(\log n)$ by binary search, valid precisely because Theorem 2.2 makes the passing set
upward closed). By Theorem 2.5, the certificate is a complete justification of the reading.

### 10.2 Two-point law identification and envelope synthesis

Given knee readings at two distinct doublings $d \ne e$, solve
$c = (k_e - k_d)/(e-d)$, $b = k_d - c\,d$; by Theorem 4.2 this is the unique law, and
integrality of $c$ is a testable consistency condition. For a family of laws, test whether
all increments agree; if so return the envelope law $(\max_i b_i, c)$ by Theorem 6.2; if not,
report that the envelope is not a law when some pair has unequal increments with crossing
bases (Theorem 6.4), and return the pointwise envelope instead. Complexity $O(|S|)$.

### 10.3 Mechanism discrimination via the exponent window

Given prose and code readings $(P_d, C_d)$ across the swept doublings, form the interval
$I_d = \big((P_d-1)/C_d,\; P_d/(C_d-1)\big)$ of exponents compatible with cell $d$ (from
Lemma 8.5), and intersect. A nonempty intersection means the multiplicative mechanism
survives; an empty one means it is excluded. Applied to the measured cells the intersection
is nonempty (it contains $1.255$), and adjoining the additive prediction at $d = 3$ empties
it. Complexity $O(\#\text{cells})$.

---

## 11. Discussion

### 11.1 What was actually measured

The invariant content of the round is a single integer: $\mathrm{shift}(\mathrm{code},
\mathrm{prose}) = 4$. Theorem 5.5 shows this is not a rhetorical flourish. Any experiment of
this design measures a torsor element; absolute bases are chart-dependent. The practical
corollary is that domain taxonomies for cache sizing should be published as *tables of
consecutive gaps*, which compose by Theorem 5.4, rather than as tables of absolute budgets,
which do not transport across changes of reference context.

### 11.2 Why the constancy is the result, not the values

Theorem 4.4 converts the repeated $-4$ into a factorisation claim: base depends only on
domain, increment only on scale. Theorem 4.6 shows the alternative was live — a differing
increment forces a sign change at a computable context. The value $-4$ tells you about two
corpora; the *constancy* of $-4$ tells you the model has two separable parameters, and that
is the transportable finding.

### 11.3 The cost of the assumption

Theorem 6.4 is the sharpest statement in the development, and it is a negative one. The
comfortable single-formula sizing rule for mixed workloads is not robust: the moment two
domains differ in increment and cross in base, the envelope leaves the model class
entirely. Deployments that mix domains of genuinely different scale behaviour — say, short
structured queries against long narrative documents — should verify the shared increment
before applying Corollary 6.3, and should expect a kinked envelope otherwise.

### 11.4 Difficulty is the wrong intuition

Theorems 7.3 and 7.4 close off an entire class of would-be explanations. Whatever governs
the base, it is not predictive difficulty, because accuracy and knee are independent
coordinates on the space of domains. Theorem 7.6 supplies the right intuition:
concentration. A small base *is* a heavy attention head; the results connect a downstream
budget reading to an upstream shape property that could, in principle, be measured directly
from attention statistics with no downstream task at all.

### 11.5 Limitations

Stated plainly.

1. **One programming language.** The code corpus is Python only. Nothing here shows the
   base is a property of "code" rather than of Python, or of CPython's particular style.
2. **Single-repository source.** Ten files from one standard library; stylistic homogeneity
   is a plausible confound for the concentration effect.
3. **Two contexts.** Twenty-four evaluation windows per cell, contexts $512$ and $1024$
   only. Two points identify an affine law (Theorem 4.2) but cannot distinguish it from
   the multiplicative rival (Theorem 8.6) — a limitation we prove rather than assert.
4. **One grid step.** The step-$4$ grid resolves the effect (Theorem 9.3) but a shift of
   size $1$, $2$, or $3$ would be invisible to it; sub-grid structure is unmeasured.
5. **One acceptance bar.** All readings are at $\tau = 0.98$ of full accuracy. Corollary 2.3
   guarantees the knee is monotone in the bar but says nothing about how the *shift* moves.

Against these, the design controls are exact: the harness is byte-identical between the two
corpora except for the text; the acceptance gate is exact rather than statistical; splits
are held out per corpus; and the pipeline is deterministic.

---

## 12. Future directions

**D1. Additive base versus multiplicative decay: the 4096 decision.** The additive law and
the decay-rescaling law are not alternative fits of the same curve — they are the linear and
the ceiling-of-a-quotient branches of one two-parameter family, and the branches are
numerically indistinguishable exactly while the admissible exponent window
$\bigcap_d \big((P_d-1)/C_d,\; P_d/(C_d-1)\big)$ stays nonempty; that window is empty from
$d = 3$ on. Because Theorem 8.10 is already established, the experiment is fully
pre-registered: a $4096$ code reading of $24$ kills the multiplicative mechanism, and any
reading $\le 23$ kills the additive law. No further theory is required to run it.

**D2. The base as a concentration invariant.** Theorem 7.6 turns a knee reading into a
lower bound on the heaviest key's mass, suggesting that the base of a domain is exactly the
reciprocal of its asymptotic top-key mass — a *shape* invariant measurable without any
downstream task. The concentration inequality already supports this in one direction, and
the uniform profile shows the bound is tight; what is missing is a matching upper bound for
realistic heavy-tailed profiles.

**D3. Base additivity under corpus mixing.** Theorem 6.2 makes the mixed-workload budget the
*join* of the individual bases, predicting that a mixed corpus has base equal to the maximum
of its constituents and never their weighted mean — a sharp, easily falsified claim about
interleaved prose/code streams. Deployment already sizes caches for mixed workloads, and a
single interleaved-corpus sweep tests it. The shared increment is load-bearing: Theorem 6.4
shows that with unequal increments and crossing bases the envelope is not a budget law at
all.

**D4. Resolution theory of knee grids.** A domain effect of size $s$ is observable only on
grids finer than $s$; Theorem 9.3 shows the whole effect disappears at step $8$. The grid
step, not the number of windows, is the binding constraint on what any limited-memory
experiment can detect, and a systematic account of the trade-off between grid refinement and
window count is the natural next piece of methodology.

**Further axes.** Mathematical and non-English natural-language domains, to test whether the
base ladder extends beyond prose/code; increments measured directly at context $4096$; a
hybrid retention policy combining top-$k$ probing with a recency window, evaluated on code;
and a larger-model cell under quantised offload, to test whether the base is a property of
the corpus or of the model.

---

## 13. Conclusion

A memory-budget table has been converted into a theory with a definite structure. The knee
is an adjoint, hence determined by two readings rather than fitted. The budget factors as
base plus increment times doublings, and the observed constancy of the inter-domain shift is
*equivalent* to that factorisation. The domain axis is a $\mathbb{Z}$-torsor, so only
differences of bases are observable and they compose additively along chains. Inside a
scale class the mixed-workload envelope is the join and is itself a law; outside it, no law
computes the envelope at all. The domain parameter is provably not a function of predictive
accuracy, and it lower-bounds the heaviest key's attention mass instead. And the one
mechanism that could have masqueraded as an additive shift is separated from it by a single,
pre-registered measurement whose outcome will kill one of the two.

Code needs four fewer keys than prose, at every context. That number is the whole of the
domain information at this scale — and it is a statement about the shape of attention, not
about the difficulty of the text.
