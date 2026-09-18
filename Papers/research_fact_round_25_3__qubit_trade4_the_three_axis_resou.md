# The Three-Axis Resource Surface of Repeated Order Finding: The Standard Corner Is Optimal

**Author:** Aristotle

**Date:** 2026-09-17

---

## Abstract

A Shor-style order-finding attempt on a fixed modulus is controlled by three resources: the width $t$ of the counting register, the number $s$ of samples drawn from a single base, and the number $k$ of independent base re-draws. Together these span a three-dimensional *resource surface*, each of whose points carries a success probability and a total gate cost. We develop the exact mathematics of this surface under a Bernoulli-shot model in which the sample and re-draw axes enter only through their product $n = ks$, the width axis enters through a per-shot success probability $q(d) = q_0 2^{-d}$ that halves with each of the $d = T - t$ bits shaved off the full width $T$, and the cost of a configuration is $G = n t^2$ (or $n t^3$).

We prove four structural results. First, a **cap-lift law**: the failure probability is exactly multiplicative in the number of independent blocks, $1 - P(q, mn) = (1 - P(q,m))^n$, so re-draw doublings square the failure probability and $j$ doublings decay it doubly exponentially. Second, an **exact fungibility increment**: doubling either cheap axis raises the success probability by precisely the Bernoulli variance $P(1-P)$, hence strictly positively below saturation and never by more than $1/4$, with equality exactly at $P = 1/2$. Third, **standard-corner optimality**: for full width $T \geq 8$ and any shave $1 \leq d \leq T/2$, every configuration meeting a target probability $P^\ast$ at reduced width $T - d$ costs strictly more gates than an efficient full-register configuration; the engine is the inequality $\tfrac54 T^2 < 2^d (T-d)^2$ (and its cubic analogue), combined with a union-bound shot floor $n \geq P^\ast 2^d / q_0$. Fourth, **absolute placement**: the optimum is polynomial and strictly cheaper than square-root-scale exhaustive search, via the elementary but genuinely inductive separation $24 M^3 < 2^M$ for $M \geq 20$; while moving off the corner is exponentially penalised, with a floor of $(2^d/4)(P^\ast/q_0)T^2$ gates at a shave of $d$ bits.

The resource surface therefore exists and is genuinely fungible in two of its three directions, but its global minimum sits at the textbook parameterisation, and every point of it remains a quantum resource, none approaching classical factoring complexity by economising on qubits.

**Keywords:** order finding, resource trade-off, register width, Bernoulli shot model, cap-lift law, union bound, exponential–polynomial separation.

---

## 1. Introduction

### 1.1 Three knobs, one budget

The quantum part of Shor's factoring algorithm is order finding: given a modulus $N$ and a base $a$ coprime to it, determine the multiplicative order $r$ of $a$ modulo $N$. A single attempt is parameterised by three quantities that a practitioner controls independently.

- **Register width $t$.** The phase-estimation register holds $t$ qubits. Textbook practice takes $t \approx 2\log_2 N$ — enough resolution that the continued-fraction post-processing recovers $r$ from a measured phase with constant probability. We call this full width $T$ the *wall*, and write $d = T - t \geq 0$ for the number of bits shaved off it.
- **Samples per base $s$.** For a fixed base, the circuit is run $s$ times and each measurement is post-processed independently.
- **Base re-draws $k$.** A fresh base $a$ is drawn $k$ times. This axis is not cosmetic: for a fixed base the order may be odd, or $a^{r/2} \equiv -1$, and then *no* amount of resampling that base yields a factorisation. Re-drawing is the only escape from this per-$N$ cap, and it is what Shor's algorithm actually prescribes.

Each configuration $(t, s, k)$ has a success probability and a gate bill. The central question is where on this three-dimensional surface the cheapest successful configuration lies, and in particular whether the widely-pursued strategy of trading register width against repetition ever pays.

### 1.2 What we prove

Our answer is that the minimum sits at the full-register corner $d = 0$, and that it does so by an exponential margin. More precisely, the paper establishes:

1. the exact law governing the re-draw axis (Section 3);
2. the exact fungibility structure of the two cheap axes, including a hard $1/4$ ceiling per doubling (Section 4);
3. a union-bound lower bound on shot counts that grows like $2^d$ (Section 5);
4. a real-variable trade-off inequality $\tfrac54 T^2 < 2^d(T-d)^2$ that makes the exponential beat the quadratic saving, and its cubic analogue (Section 6);
5. the resulting corner-optimality theorem, in general, three-axis, and concrete forms (Section 7);
6. the placement of the corner on the absolute scale: an exponential wall upward and a cubic-versus-exponential separation downward (Section 8);
7. a comparison with measured data from a 24-modulus experimental round (Section 9).

### 1.3 What changed under scrutiny

It is worth stating at the outset what a careful treatment does to the informal verdict. The claim "the standard corner is optimal" is often heard as a claim about a particular fitted dataset. It is not. Once the accounting is done, the verdict reduces to a single inequality between a quadratic and an exponential, with explicitly load-bearing hypotheses: it is **false** at $T = 4$, $d = 2$, and it degenerates at $d = T$. The correct theorem concerns *moderate shaves of a sufficiently large register*, and that is the form in which we state it. This restriction is not a weakness — it is exactly the regime in which real devices operate — but it is a genuine correction to the folklore statement.

---

## 2. The model

Throughout, $\mathbb{N}$ denotes the non-negative integers and all probabilities are real numbers.

### Definition 2.1 (Success probability of a repeated attempt)
For $q \in \mathbb{R}$ and $n \in \mathbb{N}$, define
$$P(q, n) \;=\; 1 - (1-q)^n .$$
When $q \in [0,1]$ this is the probability that at least one of $n$ independent trials, each succeeding with probability $q$, succeeds. The corresponding **failure probability** is $1 - P(q,n) = (1-q)^n$.

### Definition 2.2 (Per-shot probability at a shaved register)
For a base quality $q_0 \in \mathbb{R}$ and a shave $d \in \mathbb{N}$, define
$$q(q_0, d) \;=\; \frac{q_0}{2^{d}} .$$
Here $q_0$ is the per-shot success probability at the full register width, and the factor $2^{-d}$ encodes the modelling assumption that each shaved bit halves the chance that one run yields a usable convergent. (The continued-fraction step succeeds when the measured phase lands within a resolution-sized window of a rational $c/r$; halving the resolution halves the window.)

Two elementary facts are used repeatedly: $q(q_0, 0) = q_0$; and for $q_0 \geq 0$, $q(q_0,d) \leq q_0$, with $q(q_0,d) > 0$ whenever $q_0 > 0$.

### Definition 2.3 (Gate cost)
The **cost** of a configuration performing $n = ks$ shots on a register of width $t$ is
$$G(n,t) \;=\; n\,t^{2} \;=\; k\,s\,t^{2},$$
counting one modular-exponentiation circuit of size $\Theta(t^2)$ per shot. Section 7.3 shows that all conclusions survive replacing $t^2$ by $t^3$.

### Remark 2.4 (Why $s$ and $k$ merge)
The model treats all shots as independent Bernoulli trials with the same per-shot probability $q$, whether they come from resampling one base or from drawing a new base. Consequently the surface depends on $(s,k)$ only through the product $n = ks$. This is a modelling decision, and an honest one to flag: it is exactly the assumption that makes the two cheap axes *perfectly* fungible, and it is the assumption under which the cap-lift law below is an identity rather than an approximation. Its empirical adequacy is examined in Section 9.

### Basic properties

The following are immediate and recorded for later use. For $q \in [0,1]$ and $n \in \mathbb{N}$:

- $P(q,0) = 0$ and $P(q,1) = q$;
- $P(q,n) \geq 0$, since $(1-q)^n \leq 1$;
- $P(q,n) < 1$ whenever $q < 1$, since $(1-q)^n > 0$;
- **(shot monotonicity)** if $0 < q < 1$ and $m < n$ then $P(q,m) < P(q,n)$, since $x \mapsto (1-q)^x$ is strictly decreasing;
- **(quality monotonicity)** if $q < q' \leq 1$ and $n \geq 1$ then $P(q,n) < P(q',n)$, since $(1-q')^n < (1-q)^n$.

The two monotonicity statements say that the surface rises in every resource direction — widening the register, adding samples, adding re-draws. The whole content of the paper is that *rising everywhere* and *being worth its price everywhere* are different things.

---

## 3. The cap-lift law

The re-draw axis exists to escape a per-modulus ceiling. The following identity says that the escape is exactly multiplicative.

### Theorem 3.1 (Cap-lift law)
For all $q \in \mathbb{R}$ and all $m, n \in \mathbb{N}$,
$$1 - P(q, mn) \;=\; \bigl(1 - P(q, m)\bigr)^{n}.$$

*Proof.* Both sides equal $(1-q)^{mn}$: the left by Definition 2.1, the right by $\bigl((1-q)^m\bigr)^n = (1-q)^{mn}$. $\square$

Reading $m$ as the block size (samples per base) and $n$ as the number of blocks (re-draws), Theorem 3.1 says that the failure probability of a single base's block is raised to the power of the number of bases. The per-$N$ unlucky cap attached to one base is therefore escaped exactly as $1 - (1 - P_{\text{block}})^k$.

### Corollary 3.2 (Doubling squares failure)
$1 - P(q, 2n) = \bigl(1 - P(q,n)\bigr)^{2}$.

### Corollary 3.3 (Doubly exponential decay)
For all $j \in \mathbb{N}$,
$$1 - P(q, 2^{j} n) \;=\; \bigl(1 - P(q, n)\bigr)^{2^{j}}.$$

*Proof.* Apply Theorem 3.1 with block size $n$ and $2^j$ blocks. $\square$

Corollary 3.3 is the precise sense in which the re-draw axis is powerful: measured in *doublings*, failure collapses doubly exponentially. It is also the precise sense in which it is weak, as the next section shows: measured in *cost*, each doubling doubles the bill while buying a quantity that is capped at $1/4$.

---

## 4. Fungibility of the sample and re-draw axes

### Theorem 4.1 (Perfect fungibility)
For all $q$ and all $k, s \in \mathbb{N}$, $P(q, ks) = P(q, sk)$. The surface depends on the samples axis and the re-draw axis only through their product.

*Proof.* Commutativity of multiplication. $\square$

Trivial as a proof, this is a genuine structural statement about the surface: the two cheap axes are not merely comparable, they are *indistinguishable*. Any claim of a trade-off between them is empty, and a two-dimensional slice of the surface collapses to a one-dimensional one.

### Theorem 4.2 (Exact fungibility increment)
For all $q$ and $n$, writing $P = P(q,n)$,
$$P(q, 2n) - P(q, n) \;=\; P\,(1 - P).$$

*Proof.* By Corollary 3.2, $1 - P(q,2n) = (1-P)^2$, so $P(q,2n) = 1 - (1-P)^2 = 2P - P^2$, whence $P(q,2n) - P = P - P^2 = P(1-P)$. $\square$

The increment is the Bernoulli variance of the current configuration. This single identity yields the whole qualitative behaviour of the cheap axes.

### Corollary 4.3 (Positivity below saturation)
If $0 < q < 1$ and $n \geq 1$, then $P(q,2n) - P(q,n) > 0$.

*Proof.* $P = P(q,n)$ satisfies $0 < P < 1$: positivity because $(1-q)^n < 1$ for $n \geq 1$ and $0 < q$, and $P < 1$ because $(1-q)^n > 0$. Hence $P(1-P) > 0$. $\square$

This is the exact version of the experimentally observed "$\Delta P > 0$ everywhere below saturation": doubling any single cheap resource always helps, at any interior point of the surface.

### Corollary 4.4 (Saturation ceiling)
For all $q$ and $n$, $P(q,2n) - P(q,n) \leq \tfrac14$.

*Proof.* $P(1-P) = \tfrac14 - (P - \tfrac12)^2 \leq \tfrac14$. $\square$

### Corollary 4.5 (Extremal case)
$P(q,2n) - P(q,n) = \tfrac14$ if and only if $P(q,n) = \tfrac12$.

*Proof.* From the identity $P(1-P) = \tfrac14 - (P-\tfrac12)^2$: equality holds iff $(P - \tfrac12)^2 = 0$. $\square$

Together, Corollaries 4.3–4.5 give a complete picture of the cheap axes. Doubling always buys something; it buys the most, exactly a quarter, when the configuration is at the knife edge $P = 1/2$; and it buys progressively less as the configuration saturates. In particular, *no finite number of doublings can be leveraged into unbounded value* — each one purchases at most $0.25$ of probability, at double the cost of the previous one.

---

## 5. The union bound and the exponential shot floor

We now turn to lower bounds, which is where the width axis reveals its character. Lower bounds must hold for *every* admissible configuration, so they cannot be derived from a favourable schedule; the union bound is the right tool.

### Lemma 5.1 (Union bound)
For $q \leq 1$ and $n \in \mathbb{N}$, $P(q,n) \leq n q$.

*Proof.* Bernoulli's inequality gives $1 + n(-q) \leq (1 - q)^n$ for $-q \geq -1$, i.e. $1 - nq \leq (1-q)^n$. Subtracting from $1$ gives $P(q,n) = 1 - (1-q)^n \leq nq$. $\square$

### Theorem 5.2 (Exponential shot floor)
Let $0 < q_0 \leq 1$, $d, n \in \mathbb{N}$, and suppose the configuration of $n$ shots at a register shaved by $d$ bits reaches probability at least $P^\ast$, i.e. $P^\ast \leq P\bigl(q(q_0,d), n\bigr)$. Then
$$P^\ast \cdot 2^{d} \;\leq\; n\,q_0, \qquad\text{equivalently}\qquad n \;\geq\; \frac{P^\ast}{q_0}\,2^{d}.$$

*Proof.* Since $q(q_0,d) = q_0/2^d \leq q_0 \leq 1$, Lemma 5.1 applies and gives $P^\ast \leq P(q(q_0,d),n) \leq n q_0 / 2^d$. Multiply through by $2^d > 0$. $\square$

Theorem 5.2 is the crux. It is a bound on the *minimum possible* shot count, holding uniformly over all strategies within the model, and it grows exponentially in the number of shaved bits. Note carefully the asymmetry with Section 4: the cheap axes reward you at most $1/4$ per doubling of cost, while the width axis *punishes* you by a full factor of $2$ per bit.

---

## 6. Exponential samples beat a quadratic width saving

The shot floor is not by itself a cost statement, because shaved shots are cheaper. The following real-variable inequality settles the competition.

### Theorem 6.1 (Trade-off inequality, quadratic model)
For every real $T \geq 8$ and every integer $d$ with $1 \leq d$ and $2d \leq T$,
$$\tfrac54\,T^{2} \;<\; 2^{d}\,(T-d)^{2}.$$

*Proof.* Three cases.

*Case $d = 1$.* The claim is $\tfrac54 T^2 < 2(T-1)^2$, i.e. $0 < \tfrac34 T^2 - 4T + 2$. The quadratic $\tfrac34 T^2 - 4T + 2$ has its larger root below $5$ and is increasing beyond $T = 8/3$, and at $T = 8$ it equals $48 - 32 + 2 = 18 > 0$; hence it is positive for all $T \geq 8$.

*Case $d = 2$.* The claim is $\tfrac54 T^2 < 4(T-2)^2$, i.e. $0 < \tfrac{11}{4}T^2 - 16T + 16$, which at $T = 8$ equals $176 - 128 + 16 = 64 > 0$ and is increasing beyond $T = 32/11$.

*Case $d \geq 3$.* Here $2^d \geq 2^3 = 8$. From $2d \leq T$ we get $T - d \geq T/2 > 0$, hence $(T-d)^2 \geq T^2/4$. Therefore
$$2^d (T-d)^2 \;\geq\; 8 \cdot \frac{T^2}{4} \;=\; 2T^2 \;>\; \tfrac54 T^2,$$
the last step because $T^2 > 0$. $\square$

### Theorem 6.2 (Trade-off inequality, cubic model)
For every real $T \geq 8$ and every integer $d$ with $1 \leq d$ and $2d \leq T$,
$$\tfrac54\,T^{3} \;<\; 2^{d}\,(T-d)^{3}.$$

*Proof.* The same scheme, with the small cases $d \in \{1,2,3\}$ handled by cubic polynomial positivity on $T \geq 8$, and the tail $d \geq 4$ by $2^d \geq 16$ together with $(T-d)^3 \geq (T/2)^3 = T^3/8$, giving $2^d(T-d)^3 \geq 2T^3 > \tfrac54 T^3$. $\square$

### Remark 6.3 (Sharpness of the hypotheses)
Both hypotheses in Theorem 6.1 are load-bearing.

- *Largeness of $T$ is needed.* At $T = 4$, $d = 2$ we have $\tfrac54 \cdot 16 = 20$ while $2^2 \cdot 2^2 = 16 < 20$: the inequality fails. A tiny register halved is a genuinely different regime.
- *The shave bound is used.* At $d = T$ the right-hand side vanishes, so the inequality is not merely unproved but false. The restriction $2d \leq T$ is what makes the case analysis of the tail work.

Numerically, one finds that $2^d (T-d)^2 > \tfrac54 T^2$ in fact holds for all $1 \leq d \leq T-1$ when $T \geq 8$, not only for $d \leq T/2$; see Section 10 for the route to that stronger statement.

---

## 7. The standard corner is optimal

### 7.1 The general theorem

We compare a *shaved* configuration against a *full-register* one. To make the comparison meaningful, the full-register configuration must not be absurdly wasteful; we ask only that it be **efficient** in the following weak sense.

### Definition 7.1 (Efficient corner configuration)
A configuration of $n_0$ shots at the full register, aiming at target $P^\ast$ with per-shot probability $q_0$, is **efficient** if
$$n_0 q_0 \;\leq\; \tfrac54\,P^\ast,$$
i.e. its expected number of successes overshoots the union-bound floor $P^\ast$ by at most $25\%$.

### Theorem 7.2 (Standard-corner optimality)
Let $0 < q_0 \leq 1$ and $P^\ast > 0$. Let $T, d, t, n_0, n \in \mathbb{N}$ with
$$T \geq 8, \qquad 1 \leq d, \qquad 2d \leq T, \qquad t + d = T,$$
suppose the corner configuration is efficient ($n_0 q_0 \leq \tfrac54 P^\ast$), and suppose the shaved configuration meets the target, $P^\ast \leq P(q(q_0,d), n)$. Then
$$G(n_0, T) \;=\; n_0 T^{2} \;<\; n\,t^{2} \;=\; G(n, t).$$

*Proof.* Write $t = T - d$ as reals. By Theorem 5.2, $P^\ast 2^d \leq n q_0$. Multiplying by $(T-d)^2 \geq 0$,
$$P^\ast \, 2^d (T-d)^2 \;\leq\; n q_0 (T-d)^2 . \tag{1}$$
By Theorem 6.1 and $P^\ast > 0$,
$$P^\ast \cdot \tfrac54 T^2 \;<\; P^\ast \cdot 2^d (T-d)^2 . \tag{2}$$
By efficiency, multiplying $n_0 q_0 \leq \tfrac54 P^\ast$ by $T^2 \geq 0$,
$$n_0 q_0 T^2 \;\leq\; \tfrac54 P^\ast T^2 . \tag{3}$$
Chaining (3), (2), (1):
$$n_0 q_0 T^2 \;\leq\; \tfrac54 P^\ast T^2 \;<\; P^\ast 2^d (T-d)^2 \;\leq\; n q_0 (T-d)^2 .$$
Dividing by $q_0 > 0$ gives $n_0 T^2 < n (T-d)^2 = n t^2$. $\square$

The argument is worth restating in words. The shaved configuration must pay an exponential number of shots (Theorem 5.2); it receives in return only a quadratic discount per shot; and the trade-off inequality (Theorem 6.1) says the exponential outruns the discount with at least $25\%$ of margin to spare — precisely the margin absorbed by the efficiency hypothesis on the corner.

### 7.2 The three-axis form

### Corollary 7.3 (Minimum of the resource surface)
Under the hypotheses of Theorem 7.2, with the shot count written as $n = ks$ for a re-draw count $k$ and a per-base sample count $s$,
$$G(n_0, T) \;<\; G(ks, t).$$
No interior point $(k, s, t)$ of the three-axis resource surface that meets the target probability is cheaper than the full-register corner.

*Proof.* Immediate from Theorem 7.2, since the surface depends on $(k,s)$ only through $ks$ (Theorem 4.1). $\square$

This is the formal content of the verdict. The surface exists; it is fungible in two of its three directions; and its minimum over all admissible points lies at $d = 0$.

### 7.3 Robustness to the cost model

### Theorem 7.4 (Corner optimality under cubic pricing)
Under the hypotheses of Theorem 7.2, $n_0 T^3 < n t^3$.

*Proof.* Identical to Theorem 7.2, using Theorem 6.2 in place of Theorem 6.1. $\square$

Thus the verdict does not turn on whether one prices a width-$t$ modular-exponentiation register at $t^2$ or $t^3$ gates. What it *does* turn on is the exponential shot floor, which is a consequence of the geometric decay of per-shot quality with shaved bits.

### 7.4 A concrete instance

Take the round's fitted parameters: $q_0 = 1/8$ and target $P^\ast = 3/10$.

### Proposition 7.5 (Three shots suffice at the corner)
$P\bigl(q(1/8, 0), 3\bigr) = 1 - (7/8)^3 = 169/512 = 0.330078\ldots \geq 3/10$.

### Proposition 7.6 (The corner is efficient, with equality)
$n_0 q_0 = 3 \cdot \tfrac18 = \tfrac38 = \tfrac54 \cdot \tfrac{3}{10} = \tfrac54 P^\ast$.

The efficiency hypothesis of Definition 7.1 is therefore satisfied *exactly*, not with slack — the fitted parameters sit precisely on the boundary of the hypothesis.

### Corollary 7.7 (Concrete corner optimality)
For every $T \geq 8$, every $d$ with $1 \leq d$ and $2d \leq T$, and $t = T - d$: if $n$ shots at width $t$ with per-shot probability $q(1/8, d)$ reach probability $3/10$, then
$$3\,T^{2} \;<\; n\,t^{2}.$$

*Proof.* Theorem 7.2 with $q_0 = 1/8$, $P^\ast = 3/10$, $n_0 = 3$, using Proposition 7.6. $\square$

Moreover the corner is *attained*: by Proposition 7.5 the three-shot full-register configuration is itself admissible, so $3T^2$ is a genuine cost of a working configuration and not a vacuous comparison point.

---

## 8. Locating the corner on the absolute scale

Theorem 7.2 is a statement about the *shape* of the surface. It says nothing about where the surface sits. This section supplies both bounds: an exponential wall above the corner in the width direction, and a polynomial ceiling on the corner itself, strictly below square-root-scale classical search.

### 8.1 The wall above

### Theorem 8.1 (Exponential cost floor at a shave of $d$ bits)
Let $0 < q_0 \leq 1$, and suppose $n$ shots at width $t$ with a shave of $d$ bits reach probability $P^\ast$. Then
$$\frac{P^\ast}{q_0}\,2^{d}\,t^{2} \;\leq\; G(n,t).$$

*Proof.* Theorem 5.2 gives $P^\ast 2^d \leq n q_0$, i.e. $(P^\ast/q_0)2^d \leq n$. Multiply by $t^2 \geq 0$ and use $G(n,t) = nt^2$. $\square$

### Theorem 8.2 (The wall, in comparative form)
Let $0 < q_0 \leq 1$ and $P^\ast > 0$. Let $T \geq 8$, $d \geq 1$ with $2d \leq T$, and $t = T - d$. Then every configuration of $n$ shots reaching $P^\ast$ at width $t$ satisfies
$$\frac{2^{d}}{4}\cdot\left(\frac{P^\ast}{q_0}\,T^{2}\right) \;\leq\; G(n,t).$$

*Proof.* From $2d \leq T$ we get $t = T - d \geq T/2$, so $t^2 \geq (T/2)^2$. Theorem 8.1 then gives
$$G(n,t) \;\geq\; \frac{P^\ast}{q_0}2^d t^2 \;\geq\; \frac{P^\ast}{q_0}2^d \left(\frac{T}{2}\right)^2 \;=\; \frac{2^d}{4}\cdot \frac{P^\ast}{q_0}T^2 . \qquad \square$$

The quantity $(P^\ast/q_0)T^2$ is exactly the union-bound cost floor at the corner. Theorem 8.2 therefore says: measured against that floor, the penalty for shaving is at least $2^d/4$, and it **doubles with every further bit removed**. Shaving is not a trade-off curve; it is a cliff, and the case $d \geq 3$ already shows a net penalty.

### 8.2 The floor below: cubic beats exponential

### Theorem 8.3 (Cubic–exponential separation)
For every integer $M \geq 20$,
$$24\,M^{3} \;<\; 2^{M}.$$

*Proof.* By induction starting at $M = 20$.

*Base.* $24 \cdot 20^3 = 24 \cdot 8000 = 192\,000 < 1\,048\,576 = 2^{20}$.

*Step.* Assume $24M^3 < 2^M$ for some $M \geq 20$. It suffices to show
$$24(M+1)^3 \;\leq\; 2\cdot 24 M^3,$$
for then $24(M+1)^3 \leq 2 \cdot 24M^3 < 2 \cdot 2^M = 2^{M+1}$. The displayed inequality is equivalent to $(1 + 1/M)^3 \leq 2$, which holds as soon as $M \geq 4$ (since $(5/4)^3 = 125/64 < 2$ and the left side decreases in $M$); in polynomial form, $2M^3 - (M+1)^3 = M^3 - 3M^2 - 3M - 1 \geq 0$ for $M \geq 4$. As $M \geq 20 \geq 4$, the step holds. $\square$

The proof is short but not formal: it is a genuine ratio argument, the standard mechanism by which an exponential overtakes a polynomial once and forever. What makes the base case $M = 20$ rather than something larger is the tightness of the constant $24$; this constant is exactly what is needed for the following.

### Theorem 8.4 (The corner is strictly below square-root-scale search)
Let $M \geq 20$ and let the full register width be $T = 2M$. Then the corner's cubic-model cost satisfies
$$3\,T^{3} \;<\; 2^{M}.$$

*Proof.* $3T^3 = 3(2M)^3 = 24M^3 < 2^M$ by Theorem 8.3. $\square$

The interpretation: for a modulus of $2M$ bits, an exhaustive search of the square-root range costs on the order of $2^M$ operations, and $T = 2M$ is the textbook register width. Theorem 8.4 says that the entire three-shot, full-register attempt — priced under the *more pessimistic* cubic gate model — costs strictly less than that search, for every $M \geq 20$, i.e. for every modulus of at least $40$ bits.

### 8.3 The complete geography

Combining Sections 7 and 8:

- **At the corner**: a polynomial cost, $3T^2$ (quadratic pricing) or $3T^3$ (cubic pricing), strictly below $2^{M}$ for $T = 2M$, $M \geq 20$.
- **Off the corner along the width axis**: a floor of $(2^d/4)(P^\ast/q_0)T^2$, exponentially increasing in the shave.
- **Along the sample and re-draw axes**: perfect fungibility with each other, strictly increasing success probability, but a saturating payoff capped at $1/4$ per doubling of cost.

The surface has a polynomial floor at the textbook parameterisation and rises exponentially in every direction in which one attempts to economise on register width.

---

## 9. The measured cells

The theory above was developed alongside an experimental round on $24$ constructed controlled-order semiprimes ($12$ mixed-role, $12$ same-role), with $K = 6$ independent bases per modulus and fresh role structure, on the grid $t \in \{T-4, T-2, T\}$, $s \in \{1,5,20\}$, $k \in \{1,2,4\}$, $20$ trials per cell, at full width $T = 40$.

### 9.1 The cap lift

At $t = T$ and $s = 5$, the measured success probabilities were
$$k=1:\ 0.504, \qquad k=2:\ 0.735, \qquad k=4:\ 0.940 .$$
The cap-lift law (Theorem 3.1) predicts, from the $k = 1$ cell alone,
$$1 - (1 - 0.504)^2 = 0.753984, \qquad 1 - (1-0.504)^4 = 0.9394759\ldots$$

- The $k = 4$ prediction matches the measurement to within $6 \times 10^{-4}$.
- The $k = 2$ prediction sits $1.9 \times 10^{-2}$ above the measurement — the single visible deviation, within the sampling error of $20$ trials on each of $24$ moduli.

The measured $k{=}1 \to k{=}2$ increment is $0.735 - 0.504 = 0.231$, consistent with the saturation ceiling of Corollary 4.4, which forbids any doubling increment above $0.25$. The observed mean increment across mixed-axis single-resource doublings was $+0.18$, positive at every point below saturation, as Corollary 4.3 requires.

### 9.2 The cost cells

Set $q_0 = 1/8$ and $P^\ast = 3/10$, and take $T = 40$. The model's shot floor (Theorem 5.2) reads $n \geq (3/10) \cdot 8 \cdot 2^d = 2.4 \cdot 2^d$, so:

### Proposition 9.1 (Integer shot floors)
If $n$ shots at a shave of $d$ bits reach $P^\ast = 3/10$ with $q_0 = 1/8$, then $n \geq \lceil 2.4 \cdot 2^d \rceil$. In particular $n \geq 10$ at $d = 2$ (since $2.4 \cdot 4 = 9.6$) and $n \geq 39$ at $d = 4$ (since $2.4 \cdot 16 = 38.4$).

*Proof.* Theorem 5.2 gives $(3/10)2^d \leq n/8$, i.e. $n \geq 2.4\cdot 2^d$; take the ceiling since $n$ is an integer. $\square$

### Corollary 9.2 (The three cells)
With $T = 40$:

| cell | width $t$ | shots | gate cost $n t^2$ |
|---|---|---|---|
| corner, $d=0$ | $40$ | $3$ (attained) | $4800$ |
| $d = 2$ | $38$ | $\geq 10$ | $\geq 14440$ |
| $d = 4$ | $36$ | $\geq 39$ | $\geq 50544$ |

*Proof.* The corner row is Proposition 7.5 together with $3 \cdot 40^2 = 4800$. The others combine Proposition 9.1 with $10 \cdot 38^2 = 14440$ and $39 \cdot 36^2 = 50544$. $\square$

Shaving two bits triples the cost; shaving four multiplies it by more than ten. It must be stressed that the two lower rows are *floors over all configurations*, not measurements of a particular schedule: no reallocation of samples and re-draws can bring a shaved register below them.

### 9.3 A disclosed accounting correction

The round as originally reported quoted the corner cost as $6400$ rather than $4800$, and the $d=4$ floor as $51840$ rather than $50544$. The discrepancy is an accounting artefact: the original figures priced the corner at $n_0 = 4$ shots rather than the $3$ that Proposition 7.5 shows to suffice at the fitted $q_0$, and rounded the $d=4$ floor from $40$ shots rather than the exact ceiling $39$. Both sets of numbers are recorded here for transparency. Critically, **the verdict is unaffected**: it does not depend on the fitted numbers at all, only on the inequality of Theorem 6.1, and the corrected numbers are if anything more favourable to the corner (the ratio $d{=}2$ to corner rises from $2.26$ to $3.01$).

This is the sense in which a precise treatment changes the claim. The informal verdict was a statement about a table. The theorem is a statement about $\tfrac54 T^2 < 2^d(T-d)^2$, valid for all $T \geq 8$ and all moderate shaves, for any fitted parameters satisfying the efficiency condition.

---

## 10. Discussion

### 10.1 Why the asymmetry is structural

It is tempting to summarise the result as "repetition is cheap and width is expensive", but the structure is sharper than that. The two cheap axes and the expensive axis fail to be fungible for two independent reasons, and both are visible in the formulas.

*The cheap axes have a concave payoff.* The gain per doubling is $P(1-P)$, which is bounded by $1/4$ and tends to $0$ as $P \to 1$. Cost, however, doubles with each doubling. The marginal return per gate on the cheap axes therefore *decreases*, and decreases to zero.

*The expensive axis has a geometric penalty and only a polynomial rebate.* Each shaved bit multiplies the required shot count by $2$ and divides the per-shot cost by only $\bigl(t/(t-1)\bigr)^2 \to 1$. Even at the most favourable admissible shave the rebate factor $(T-d)^2/T^2$ is at least $1/4$, while the penalty is at least $2$.

The optimum is a corner and not an interior point because the objective is a product of a convex exponential in $d$ and a polynomial in $d$, over a box; the minimum of such an object over the admissible shave range is attained at an endpoint, and Theorem 6.1 identifies which endpoint.

### 10.2 The role of the efficiency hypothesis

Definition 7.1 is the only non-structural assumption in Theorem 7.2, and it is worth being clear about its function. Without it, the theorem would be false for a trivial reason: a maximally wasteful corner configuration (say $n_0 = 10^9$ shots) is obviously more expensive than a modest shaved one. The hypothesis excludes exactly that pathology by requiring the corner to be within $25\%$ of its own union-bound floor. The constant $5/4$ is not arbitrary: it is the margin that Theorem 6.1 delivers, and the concrete instance ($q_0 = 1/8$, $P^\ast = 3/10$, $n_0 = 3$) meets it with equality, which is a mild coincidence of the fitted parameters rather than a design choice.

A cleaner formulation would replace the hypothesis by the exact least sufficient shot count $N(q, P^\ast) = \lceil \log(1-P^\ast)/\log(1-q)\rceil$; see Section 11.

### 10.3 Scope and limitations

The model is deliberately minimal, and three of its choices deserve scrutiny.

1. **Geometric decay in the shave.** We assume $q(d) = q_0 2^{-d}$ exactly. Real post-processing at a shaved register may decay faster (loss of unique convergents) or slower (partial recovery from multiple convergents). The results require only that the decay be at least geometric with ratio $2$; any faster decay strengthens them.
2. **Independence across shots and bases.** Treating a re-draw as just another Bernoulli shot with the same $q$ is what makes Theorems 3.1 and 4.1 exact. If a fraction of bases is *structurally* unusable, the correct model has a mixture $q \mapsto m\,q$ with a mixed-role fraction $m$, and the cap-lift law reads $1 - (1 - p_1 m)^{ks}$ — the form the round actually fitted, with $m \approx 1/2$. All results of Sections 5–8 survive verbatim with $q_0$ replaced by $m q_0$, since they use only $q \leq q_0$ and the $2^{-d}$ scaling.
3. **Cost as shots times circuit size.** We ignore per-shot overheads (state preparation, readout, error-correction cycles). Any additive per-shot overhead makes the shaved configurations *worse*, since they use more shots; the verdict is robust in the favourable direction.

### 10.4 Consequences for the qubit-shaving programme

A long line of work asks how few qubits suffice for order finding, and the results here should not be read as contradicting it. Reducing $t$ below $2\log_2 N$ *is* possible; what the theorems say is that doing so within this model is never *cheaper in total gate count*, once the repetitions that restore the success probability are priced. The distinction matters operationally: if qubits are the binding constraint and gates are free, shaving may still be the right engineering choice. If the total budget is what binds, it is not.

The second half of the verdict — Theorem 8.4 — addresses the complementary worry. It would be a hollow optimality result if the cheapest quantum configuration were still more expensive than simply searching. It is not: at $40$ bits and above, even the pessimistically priced corner sits strictly below square-root-scale search, and the gap widens exponentially thereafter.

---

## 11. Future directions

Three concrete extensions suggest themselves, in increasing order of difficulty.

### 11.1 Exact repetition counts and a hypothesis-free optimality law

The current optimality theorem prices the shaved configuration by the union-bound floor $P^\ast/q$ and the corner by the efficiency hypothesis $n_0 q_0 \leq \tfrac54 P^\ast$. The honest object is the exact least sufficient count
$$N(q, P^\ast) \;=\; \left\lceil \frac{\log(1 - P^\ast)}{\log(1-q)} \right\rceil .$$
The key insight is that the two-sided estimate
$$\frac{P^\ast}{q} \;\leq\; N(q, P^\ast) \;\leq\; 1 + \frac{\ln\bigl(1/(1-P^\ast)\bigr)}{q}$$
pins $N$ to within an additive $1$, so the efficiency hypothesis can be *derived* rather than assumed, at the price of a logarithm in the statement. The lower half is exactly Theorem 5.2; the upper half follows from $1 + x \leq e^x$. What remains is the ceiling arithmetic.

### 11.2 Deep shaves: removing the $2d \leq T$ hypothesis

Numerically, $2^d(T-d)^2 > \tfrac54 T^2$ holds for every $1 \leq d \leq T-1$ when $T \geq 8$, not merely for $d \leq T/2$. The key insight is that
$$d \;\longmapsto\; d\ln 2 + 2\ln(T-d)$$
is *concave* on $[0, T)$, so its minimum over a closed interval is attained at an endpoint: the interior is free, and only $d = 1$ and $d = T-1$ require checking. The former is already established (Theorem 6.1, case $d=1$); the latter reduces to the induction $m^2 < 2^{m-1}$, structurally identical to the ratio argument of Theorem 8.3.

### 11.3 Adaptive schedules across the width axis

Every result above prices a *fixed* configuration. A real scheduler may distribute its budget across several widths — cheap narrow shots first, a wide shot only on failure. The key insight is that the failure probability of a schedule $(d_1, n_1), \ldots, (d_r, n_r)$ factorises as
$$\prod_{i=1}^{r} \bigl(1 - q_0 2^{-d_i}\bigr)^{n_i},$$
so the cost-constrained optimum is a linear program in the $n_i$ with a concave objective — and one expects the corner to be, again, the winning vertex. The factorisation is exactly the cap-lift law of Theorem 3.1 in multi-block form, so the machinery is already in place; what is needed is the convex-analytic argument that the optimum of a concave objective over a polytope is attained at a vertex, plus the identification of which vertex.

### 11.4 Beyond the model

Further afield: a treatment in which the per-shot probability at a shaved register is derived from the continued-fraction analysis rather than posited; a version of the cost model incorporating error-correction overheads, which scale with circuit depth and would further penalise repetition-heavy strategies; and an extension of the surface to include a fourth axis, the arithmetic circuit's own space–time trade-off, which is the one genuine remaining candidate for a non-corner optimum.

---

## 12. Conclusion

The three-axis resource surface of repeated order finding is real, and it is fungible — but only in two of its three directions, and only up to a saturating ceiling. The samples and re-draw axes are perfectly interchangeable, entering the success probability solely through their product; each doubling of either buys exactly the Bernoulli variance $P(1-P)$ of the current configuration, always positive below saturation, never more than $1/4$. The register-width axis is categorically different: each bit shaved halves the per-shot success probability, forcing a shot count of at least $(P^\ast/q_0)2^d$, against which the quadratic (or cubic) saving in circuit size cannot compete. The resulting inequality $\tfrac54 T^2 < 2^d (T-d)^2$, valid for every full width $T \geq 8$ and every moderate shave $1 \leq d \leq T/2$, places the global minimum of the surface at the full-register corner and nowhere else.

That minimum is in a good place. Under the pessimistic cubic pricing, the corner costs $3T^3 = 24M^3$ gates for a $2M$-bit modulus, strictly less than the $2^M$ operations of a square-root-scale exhaustive search for every $M \geq 20$ — while the cost of any shaved configuration is at least $2^d/4$ times the corner's own union-bound floor, a penalty that doubles with each further bit.

The textbook parameterisation of order finding is therefore not a convenient starting point awaiting optimisation. Within this model, it is the optimum.
