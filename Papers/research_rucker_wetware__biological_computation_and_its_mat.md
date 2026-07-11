# Wetware Computation: Iterated Dynamics and the Information Cost of Determinism

## Abstract

We develop a minimal mathematical model of *wetware* computation — biological
computation viewed as a discrete dynamical system — and use it to prove a
cross-domain **connector** relating enumerative combinatorics to asymptotic real
analysis. A wetware system is a state space $S$ together with a step map
$\text{step} : S \to S$; running the system means iterating the step map, and
this iteration obeys a flow (semigroup) law that makes it an action of
$(\mathbb{N}, +)$. Within this model we prove three results. First,
**finite-data universality**: every function $f : X \to Y$ is computed by some
wetware system equipped with an encoder and a decoder in a single step — the
finite analogue of the Turing-completeness of neural networks. Second,
**eventual periodicity**: on any finite state space every orbit revisits a state,
so it is eventually periodic; a finite deterministic machine cannot realize
aperiodic behavior by pure iteration. Third, and central, an **energy connector**:
measuring the specification cost of a machine on $n$ neurons by the Shannon
information (base-2 logarithm) of its number of configurations, a deterministic
transition map costs exactly $n \log_2 n$ bits while an arbitrary binary
connection matrix costs exactly $n^2$ bits. We prove the strict separation
$n \log_2 n < n^2$ for all $n \ge 1$ and the asymptotic separation
$\tfrac{n \log_2 n}{n^2} \to 0$: the information cost of *determinism* is
asymptotically negligible next to that of arbitrary *connectivity*. The
combinatorial identities $n^n$ and $2^{(n^2)}$ and the analytic limit
$\log_2 n / n \to 0$ are the two ends of the bridge.

**Keywords:** dynamical systems, iterated maps, neural computation, wetware,
Turing completeness, pigeonhole principle, eventual periodicity, Shannon
information, enumerative combinatorics, asymptotic analysis.

---

## 1. Introduction

The brain is an existence proof that matter can compute, and a remarkably
economical one: it dwarfs engineered systems in capability per watt. To reason
precisely about *why*, we abstract away substrate and ask what is common to all
computers. The answer we adopt here is austere: a computer is a rule that maps a
total state to its successor, and computation is the iteration of that rule. We
call an instance of this abstraction a **wetware system**, both to evoke its
biological motivation and to emphasize that the model is substrate-neutral.

From this single primitive we extract three kinds of statement, each belonging
to a different mathematical tradition:

1. an **expressiveness** result (algebra of functions): the model can compute any
   function on finite data;
2. a **limitative** result (combinatorics of finite orbits): finite machines
   must eventually cycle;
3. a **resource** result (information theory meets asymptotics): deterministic
   dynamics is far cheaper to specify than arbitrary connectivity.

The third is the paper's connector: it links the *counting* of hardware
configurations to the *asymptotic behavior* of a ratio, and shows that a single
logarithm mediates between them.

---

## 2. The model

### 2.1 Wetware systems and their runs

**Definition 2.1 (Wetware system).** A *wetware system* on a type $S$ is a
structure consisting of a single **step map** $\text{step} : S \to S$. The type
$S$ is the *state space* (the space of neural configurations) and $\text{step}$
is the *one-step transition*.

**Definition 2.2 (Run).** The *run* of a wetware system $W$ for $t \in \mathbb{N}$
steps from a state $x \in S$ is the $t$-fold iterate of the step map,
$$\mathrm{run}(t, x) := \text{step}^{[t]}(x),$$
where $\text{step}^{[0]} = \mathrm{id}$ and $\text{step}^{[t+1]} = \text{step} \circ \text{step}^{[t]}$.

Two immediate identities hold by definition: $\mathrm{run}(0, x) = x$ and
$\mathrm{run}(1, x) = \text{step}(x)$, together with the recursion
$\mathrm{run}(t+1, x) = \text{step}(\mathrm{run}(t, x))$.

### 2.2 The flow law

**Theorem 2.3 (Flow / semigroup law).** For all $s, t \in \mathbb{N}$ and
$x \in S$,
$$\mathrm{run}(s + t, x) = \mathrm{run}\big(s, \mathrm{run}(t, x)\big).$$

*Proof.* Iteration is additive in the exponent: $\text{step}^{[s+t]} =
\text{step}^{[s]} \circ \text{step}^{[t]}$. Applying both sides to $x$ gives the
claim. $\qquad\blacksquare$

The flow law says a wetware system is a (left) action of the monoid
$(\mathbb{N}, +)$ on $S$. This is the algebraic content of "iterated
computation": clock time composes additively, and the machine's future depends
only on its present state, not on its history. Every subsequent argument uses
the run and, implicitly, this compositional structure.

---

## 3. Finite-data universality

We make precise what it means for a wetware system to *compute* a function, using
an explicit encoder and decoder — the standard interface between a mathematical
function and a physical process.

**Definition 3.1 (Computation).** Let $W$ be a wetware system on $S$, let
$\text{enc} : X \to S$ and $\text{dec} : S \to Y$, and let $T \in \mathbb{N}$. We
say $W$ *computes* $f : X \to Y$ in $T$ steps (with encoder $\text{enc}$ and
decoder $\text{dec}$) if
$$\text{dec}\big(\mathrm{run}(T, \text{enc}(x))\big) = f(x) \qquad \text{for all } x \in X.$$

**Theorem 3.2 (Finite-data universality).** For every function $f : X \to Y$
there exist a state space $S'$, a wetware system $W$ on $S'$, an encoder
$\text{enc} : X \to S'$, and a decoder $\text{dec} : S' \to Y$ such that $W$
computes $f$ in a single step ($T = 1$).

*Proof (explicit construction).* Take the state space to be the disjoint union
$S' = X \sqcup Y$, whose points are tagged either as a *pending input* (a copy of
some $x \in X$) or as a *produced output* (a copy of some $y \in Y$). Define:

- **encoder** $\text{enc}(x) = \iota_X(x)$, injecting the input as pending;
- **step map** $\text{step}$ sending a pending input $\iota_X(x)$ to the output
  $\iota_Y(f(x))$, and fixing every output $\iota_Y(y) \mapsto \iota_Y(y)$;
- **decoder** $\text{dec}$ sending $\iota_X(x) \mapsto f(x)$ and $\iota_Y(y)
  \mapsto y$.

Then for any input $x$,
$$\mathrm{run}(1, \text{enc}(x)) = \text{step}(\iota_X(x)) = \iota_Y(f(x)),$$
and decoding gives $\text{dec}(\iota_Y(f(x))) = f(x)$. Hence
$\text{dec}(\mathrm{run}(1, \text{enc}(x))) = f(x)$ for all $x$. $\qquad\blacksquare$

**Remark 3.3.** Theorem 3.2 is the finite-state analogue of the Turing-
completeness of neural networks: the *model* places no restriction on which
functions are realizable. Real limits arise not from expressiveness but from
resources — the state space needed, the number of steps, and (Section 5) the
information required to specify the machine. A genuine simulation of Turing
machines with unbounded tape requires an unbounded state space; the present
theorem is the bounded-data specialization, which already shows the model is
computationally unopinionated.

---

## 4. A limitative result: eventual periodicity

**Theorem 4.1 (Eventual periodicity of finite orbits).** Let $S$ be a finite
state space and $W$ a wetware system on $S$. For every $x \in S$ there exist
natural numbers $i < j$ with
$$\mathrm{run}(i, x) = \mathrm{run}(j, x).$$

*Proof.* Consider the orbit map $k \mapsto \mathrm{run}(k, x)$ from the infinite
set $\mathbb{N}$ to the finite set $S$. No injection from an infinite set into a
finite set exists, so there are distinct indices that collide; ordering them
gives $i < j$ with equal images. $\qquad\blacksquare$

**Corollary 4.2.** From index $i$ onward the orbit is periodic with period
dividing $j - i$: for all $k \ge i$, $\mathrm{run}(k, x) = \mathrm{run}(k + (j-i),
x)$. Consequently a finite, deterministic wetware system cannot produce
aperiodic behavior by pure iteration.

*Proof of the corollary.* Let $p = j - i > 0$. By the flow law and
$\mathrm{run}(i,x) = \mathrm{run}(i+p,x)$, induction on $k - i$ propagates the
coincidence forward: $\mathrm{run}(k+p, x) = \mathrm{run}(k-i, \mathrm{run}(i+p,x))
= \mathrm{run}(k-i, \mathrm{run}(i,x)) = \mathrm{run}(k,x)$. $\qquad\blacksquare$

This is a geometric ceiling on biological computation: unbounded novelty requires
either unbounded state or an external, non-deterministic input stream. It also
explains why the brain's open-endedness is compatible with finiteness — its
effective state space is astronomically large and continually re-driven by a
changing environment.

---

## 5. The energy connector

We now compare two hardware disciplines on $n$ neurons by the information needed
to specify one machine.

### 5.1 Configuration counts (enumerative combinatorics)

**Definition 5.1 (Wetware / silicon configurations).** On $n$ neurons:

- a **wetware** configuration is a deterministic transition map $\text{Fin}\,n
  \to \text{Fin}\,n$ (one successor per state);
- a **silicon** configuration is an arbitrary binary connection matrix
  $\text{Fin}\,n \to \text{Fin}\,n \to \mathrm{Bool}$ (a present/absent bit for
  each ordered pair).

**Lemma 5.2 (Counts).**
$$\#\{\text{wetware configs}\} = n^n, \qquad \#\{\text{silicon configs}\} = 2^{(n^2)}.$$

*Proof.* The number of functions from an $n$-element set to itself is $n^n$. The
number of Boolean-valued functions on the $n \times n = n^2$ ordered pairs is
$2^{n^2}$. $\qquad\blacksquare$

### 5.2 Energy as Shannon information

**Definition 5.3 (Energy).** The *energy* of a discipline on $n$ neurons is the
Shannon information — the number of bits — needed to name one configuration,
i.e. the base-2 logarithm of the configuration count:
$$\mathrm{wetwareEnergy}(n) = \log_2\!\big(n^n\big), \qquad
  \mathrm{siliconEnergy}(n) = \log_2\!\big(2^{(n^2)}\big).$$

**Theorem 5.4 (Closed forms).** For all $n$,
$$\mathrm{wetwareEnergy}(n) = n \log_2 n, \qquad \mathrm{siliconEnergy}(n) = n^2.$$

*Proof.* Using $\log_2(a^b) = b \log_2 a$: $\log_2(n^n) = n \log_2 n$, and
$\log_2(2^{n^2}) = n^2 \log_2 2 = n^2$. $\qquad\blacksquare$

Thus $\mathrm{wetwareEnergy}(n) = \Theta(n \log n)$ and $\mathrm{siliconEnergy}(n)
= \Theta(n^2)$ — indeed both are *exact*, not merely order-of-magnitude.

### 5.3 The strict separation

**Theorem 5.5 (Wetware beats silicon).** For every integer $n \ge 1$,
$$\mathrm{wetwareEnergy}(n) < \mathrm{siliconEnergy}(n), \qquad \text{i.e.} \qquad n \log_2 n < n^2.$$

*Proof.* For every $n \ge 1$ we have the elementary bound $n < 2^n$. Applying the
strictly increasing function $\log_2$ gives $\log_2 n < \log_2(2^n) = n$.
Multiplying by the strictly positive $n$ preserves the strict inequality:
$n \log_2 n < n \cdot n = n^2$. $\qquad\blacksquare$

### 5.4 The asymptotic separation

**Lemma 5.6 (Analytic core).** As a limit over the reals,
$$\lim_{x \to \infty} \frac{\log_2 x}{x} = 0.$$

*Proof sketch.* Write $\log_2 x = \ln x / \ln 2$. The standard fact $\ln x / x
\to 0$ (equivalently $u \ln u \to 0$ as $u \to 0^+$ under $u = 1/x$, since
$x \ln x \to 0$) gives the result after dividing by the constant $\ln 2$.
$\qquad\blacksquare$

**Theorem 5.7 (Asymptotic separation — the connector).**
$$\lim_{n \to \infty} \frac{\mathrm{wetwareEnergy}(n)}{\mathrm{siliconEnergy}(n)} = 0.$$

*Proof.* For $n \ge 1$, by Theorem 5.4,
$$\frac{\mathrm{wetwareEnergy}(n)}{\mathrm{siliconEnergy}(n)}
= \frac{n \log_2 n}{n^2} = \frac{\log_2 n}{n}.$$
By Lemma 5.6 composed with $n \to \infty$ over the integers, this ratio tends to
$0$. $\qquad\blacksquare$

**Interpretation.** The two ends of the bridge belong to different fields: the
identities $n^n$ and $2^{n^2}$ are pure enumerative combinatorics, while the
limit $\log_2 n / n \to 0$ is asymptotic real analysis. The connector says the
information cost of *determinism* — committing to one successor per state — is not
merely smaller than the cost of arbitrary *connectivity*, but an asymptotically
vanishing fraction of it. Doubling $n$ scales silicon cost by $\approx 4$ but
wetware cost by only $\approx 2 \cdot \tfrac{\log_2 2n}{\log_2 n}$, barely above
$2$. At brain scale ($n \sim 10^{10}$), $\log_2 n \approx 33$–$36$, so
determinism buys a factor-of-$n$ reduction against full connectivity.

---

## 6. Algorithms

The results above are constructive and yield directly executable procedures. We
summarize the two most useful.

**Algorithm A (Orbit / eventual-period detection).** Given a finite state space
and a step map, iterate from a start state, recording visited states with their
first-visit times, until a state repeats. The first repeated state marks the
onset $i$ of the cycle and the current time $j$ gives period $j - i$. This is the
computational witness of Theorem 4.1; with a hash set it runs in time and space
$O(i + p)$ where $p = j - i$ is the eventual period.

**Algorithm B (Energy comparison and crossover analysis).** Given $n$, compute
$\mathrm{wetwareEnergy}(n) = n \log_2 n$ and $\mathrm{siliconEnergy}(n) = n^2$,
their difference, and their ratio. Sweeping $n$ exhibits both the strict
inequality of Theorem 5.5 (the ratio is $< 1$ for all $n \ge 2$, and equals the
degenerate boundary at $n = 1$ where $\log_2 1 = 0$) and the decay of Theorem 5.7.

---

## 7. Applications

- **Neuromorphic hardware budgeting.** The $n \log n$ versus $n^2$ split is a
  first-principles argument for sparse, deterministic transition-style
  architectures over dense arbitrary-connectivity fabrics when specification and
  configuration memory dominate cost.
- **Model compression.** A deterministic routing layer (one successor per unit)
  requires $n \log_2 n$ bits to store, against $n^2$ for a dense adjacency
  layer — a concrete compression target that grows more favorable with scale.
- **Dynamical-systems view of learning.** Framing computation as an
  $(\mathbb{N},+)$-action clarifies when iterated updates converge (fixed points)
  or cycle (Corollary 4.2), informing analyses of recurrent and diffusion-style
  models.

---

## 8. Discussion and future work

The model is deliberately minimal, which is both its strength (the results are
clean and exact) and the source of its open questions.

1. **Full Turing-completeness (unbounded tape).** Theorem 3.2 is the finite-data
   analogue. A genuine simulation of Turing machines requires an unbounded state
   space (e.g. $\mathbb{Z}$-indexed configurations, or reals encoding a stack).
   One would define a register/stack machine and show a wetware system on
   $\mathbb{N}$- or $\mathbb{R}$-valued states simulates each step, recovering
   universality in full.

2. **Sharper information bounds.** Upgrade the exact identities to a two-sided
   coding theorem: any prefix-free encoding of transition maps needs $\ge n
   \log_2 n$ bits (Kraft inequality), while $n \lceil \log_2 n \rceil$ bits
   suffice, pinning $\Theta(n \log n)$ from both sides.

3. **Continuous dynamics / neural manifolds.** Replace the finite state space
   with a smooth manifold and the step map with the time-1 flow of a vector
   field. Study which $f : X \to Y$ are realizable, connecting to control theory
   and reachability.

4. **The "super-Turing" hypothesis (open/speculative).** The conjecture that
   continuous-dynamics wetware computes functions no Turing machine can (à la
   analog recurrent networks with real weights) is *not* provable for standard
   discrete/computable models and is physically contentious. A careful treatment
   would isolate the exact resource — unbounded real precision — that any would-be
   super-Turing model assumes, and prove the corresponding *conditional*
   separation, clarifying that any such power comes from the reals, not the
   biology.

5. **Energy landscapes and geometry.** Tie eventual periodicity to attractor
   structure: bound cycle lengths, count fixed points, and relate the geometry of
   the state graph of the step map to computational capacity.

---

## 9. Conclusion

Stripped to its essentials, a computer is an iterated step map, and this single
idea supports a surprising amount of structure. The model is universal on finite
data, necessarily periodic when finite, and — most tellingly — reveals that
determinism is a profound information bargain: specifying a deterministic machine
costs $n \log_2 n$ bits against $n^2$ for arbitrary connectivity, a gap that
widens without bound as machines grow. Enumerative combinatorics and asymptotic
analysis, joined by a logarithm, converge on the same conclusion: constraint is
cheap, and the economy of thought may be, at bottom, the economy of determinism.
