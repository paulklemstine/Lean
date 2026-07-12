# Formal Limits of Molecular Computing: Discrete Reaction Networks, Parallelism, and Storage

## Abstract

Molecular computing proposes to perform computation with populations of molecules
that transform one another through chemical reactions. We develop a rigorous
discrete framework for such systems and prove a coherent body of results
delimiting their power. We adopt the standard *population* (Petri-net) semantics
of a chemical reaction network (CRN): states are molecule-count vectors and
reactions consume reactant complexes and create product complexes. We prove that
this dynamics is **strongly monotone** and **translation-invariant**, that
**coverability** is upward monotone, and that any balanced linear functional is a
**conserved quantity** along every trajectory. From monotonicity we derive the
central structural limitation: **no reaction can detect the absence of a
species** (no zero-test), which is precisely the obstruction that keeps the exact
discrete model strictly below Turing power. Turning to performance, we formalize
the folklore that molecular parallelism gives only a **constant-factor speedup**:
if work $W$ is spread across $T$ steps with at most $p$ operations per step, then
$W \le T \cdot p$, whence the speedup is at most $p$; and with a fixed volume cap
$P$ on simultaneous operations, exponential work forces unbounded parallel time,
$T \ge 2^n/P$. Finally, we establish information-theoretic **storage bounds**: a
register of $k$ two-state units distinguishes at most $2^k$ inputs, so
distinguishing $N$ inputs requires $k \ge \log_2 N$ units, and any injective
description scheme for $M$ behaviors requires $k \ge \log_2 M$ — a discrete shadow
of the "volume proportional to Kolmogorov complexity" principle. All results are
elementary in statement, exact (non-asymptotic where possible), and proved from
first principles.

**Keywords:** chemical reaction networks, mass-action kinetics, Petri nets,
monotone dynamics, zero-test, conservation laws, molecular parallelism, DNA
storage, Kolmogorov complexity, coverability.

---

## 1. Introduction

A *molecular computer* is a physical system — canonically a solution of DNA
strands or other reactive species — that carries out computation through chemical
reactions rather than through electronic logic gates. The appeal is twofold. First,
the information density of matter is extraordinary: a cubic micrometer can hold an
enormous number of molecules, each a potential unit of state. Second, all those
molecules react *in parallel*, suggesting a natural, massively concurrent
substrate for computation. These observations have fueled ambitious conjectures:
that a speck of DNA might store on the order of $10^{18}$ bits, that molecular
parallelism might crush NP-complete problems, and that chemical reaction networks
might be universal computers.

Each of these claims is partly true and partly mistaken, and the boundary between
the two is sharp and mathematical. This paper draws that boundary. We work in the
discrete, population-level model of chemical reaction networks, which abstracts a
reacting mixture as a bag of molecules undergoing state transitions. Within this
model we prove:

1. **Structural laws** of the dynamics: strong monotonicity, translation
   invariance, monotone coverability, and conservation of balanced functionals.
2. **A universality obstruction**: reactions cannot test for the absence of a
   species, so the exact discrete model cannot implement a register machine's
   zero-test and is therefore not Turing-complete on its own.
3. **A parallelism bound**: molecular concurrency yields at most a constant-factor
   ($p$-fold, volume-capped) speedup, and cannot reduce exponential work to
   bounded time.
4. **Storage and description bounds**: $\log_2 N$ two-state units are necessary to
   distinguish $N$ inputs, and description length (hence volume) is bounded below
   by the log of the number of realizable behaviors.

The results are individually elementary; their value lies in their precision and
in assembling them into a single, self-consistent account of what molecular
computers can and cannot do.

---

## 2. The discrete model of a chemical reaction network

Throughout, let $S$ be a type of *species*. A **state** is a function
$x : S \to \mathbb{N}$ recording the count $x(s)$ of each species. States are
ordered pointwise: $x \le y$ means $x(s) \le y(s)$ for all $s$. Addition and
truncated subtraction are pointwise, with $\mathbb{N}$-subtraction
$a - b = \max(a-b, 0)$.

**Definition 2.1 (Reaction).** A *reaction* $r$ consists of two states, the
*reactant complex* $r.\mathrm{reactant} : S \to \mathbb{N}$ and the *product
complex* $r.\mathrm{product} : S \to \mathbb{N}$.

**Definition 2.2 (Enabled).** A reaction $r$ is *enabled* at a state $x$, written
$r.\mathrm{enabled}(x)$, when $r.\mathrm{reactant} \le x$: every reactant molecule
required is present.

**Definition 2.3 (Firing).** Firing $r$ at $x$ yields the state
$$r.\mathrm{fire}(x)(s) \;=\; x(s) - r.\mathrm{reactant}(s) + r.\mathrm{product}(s).$$
On enabled states the truncated subtraction is exact, so firing consumes exactly
the reactants and creates exactly the products.

**Definition 2.4 (CRN, step, reachability).** A *chemical reaction network* is a
finite list $rs$ of reactions. A *step* relates $x$ to $y$, written
$\mathrm{Step}_{rs}(x,y)$, when some $r \in rs$ is enabled at $x$ and
$y = r.\mathrm{fire}(x)$. *Reachability* $\mathrm{Reach}_{rs}$ is the reflexive–
transitive closure of $\mathrm{Step}_{rs}$: $\mathrm{Reach}_{rs}(x,y)$ holds when
$y$ can be obtained from $x$ by finitely many firings.

This is exactly the vector-addition-system / Petri-net view of mass-action
kinetics, stripped to its combinatorial core. Reaction *rates* are abstracted away;
we keep only the reachable transitions, which is the appropriate level for
questions of computational power.

---

## 3. Structural laws of the dynamics

### 3.1 Monotonicity

**Lemma 3.1 (Enabledness is upward closed).** If $r$ is enabled at $x$ and
$x \le y$, then $r$ is enabled at $y$.

*Proof.* $r.\mathrm{reactant} \le x \le y$ by transitivity. $\qquad\blacksquare$

**Theorem 3.2 (Strong monotonicity).** If $r$ is enabled at $x$, then for every
surplus $d : S \to \mathbb{N}$,
$$r.\mathrm{fire}(x + d) \;=\; r.\mathrm{fire}(x) + d.$$

*Proof.* Fix a species $s$. Since $r.\mathrm{reactant}(s) \le x(s)$, the truncated
subtraction is exact, and
$(x(s) + d(s)) - r.\mathrm{reactant}(s) + r.\mathrm{product}(s)
= \big(x(s) - r.\mathrm{reactant}(s) + r.\mathrm{product}(s)\big) + d(s)$
is a valid identity over $\mathbb{N}$. $\qquad\blacksquare$

**Corollary 3.3 (Monotone firing).** If $r$ is enabled at $x$ and $x \le y$, then
$r.\mathrm{fire}(x) \le r.\mathrm{fire}(y)$.

The content of Theorem 3.2 is that extra molecules are *inert bystanders*: firing
a reaction on an enriched state does the same thing and leaves the surplus exactly
as it was. This is the defining feature of the model and the source of both its
robustness and its limitations.

### 3.2 Translation invariance

**Theorem 3.4 (Step shift).** If $\mathrm{Step}_{rs}(x,y)$ then
$\mathrm{Step}_{rs}(x+d, y+d)$ for every $d$.

*Proof.* Let $r$ witness the step, enabled at $x$ with $y = r.\mathrm{fire}(x)$.
Then $r$ is enabled at $x + d$ (Lemma 3.1), and by Theorem 3.2,
$r.\mathrm{fire}(x+d) = r.\mathrm{fire}(x) + d = y + d$. $\qquad\blacksquare$

**Theorem 3.5 (Reachability shift).** If $\mathrm{Reach}_{rs}(x,y)$ then
$\mathrm{Reach}_{rs}(x+d, y+d)$ for every $d$.

*Proof.* Induction on the reflexive–transitive closure, applying Theorem 3.4 at
each step. $\qquad\blacksquare$

Adding a fixed background of molecules translates entire trajectories rigidly:
the network's behavior is invariant under a global additive shift of the state.

### 3.3 Coverability

**Definition 3.6 (Coverable).** A target $t$ is *coverable* from $x$ if some
reachable $y$ dominates it: $\exists y,\ \mathrm{Reach}_{rs}(x,y) \wedge t \le y$.

**Theorem 3.7 (Coverability is upward monotone).** If $x \le x'$ and $t$ is
coverable from $x$, then $t$ is coverable from $x'$.

*Proof.* Let $y$ witness coverability from $x$, so $\mathrm{Reach}_{rs}(x,y)$ and
$t \le y$. Put $d = x' - x$, so $x + d = x'$ (exact since $x \le x'$). By
Theorem 3.5, $\mathrm{Reach}_{rs}(x', y + d)$, and $t \le y \le y + d$. Thus
$y + d$ witnesses coverability from $x'$. $\qquad\blacksquare$

Coverability — "can we eventually accumulate at least a given amount of each
species?" — is the canonical decidable question about such systems, and its upward
monotonicity is the structural hallmark that separates CRN/Petri-net dynamics from
more expressive models.

### 3.4 Conservation laws

Let $S$ be finite. A *linear functional* is a weighting $w : S \to \mathbb{Z}$
(mass, charge, atom count of a fixed element, etc.). Its value on a state is
$$\mathrm{mass}_w(x) \;=\; \sum_{s \in S} w(s)\, x(s) \ \in \mathbb{Z}.$$

**Definition 3.8 (Conserved by a reaction).** $w$ is *conserved* by $r$ if
$\sum_s w(s)\, r.\mathrm{product}(s) = \sum_s w(s)\, r.\mathrm{reactant}(s)$ — the
reactant and product complexes carry equal $w$-weight (the reaction is
$w$-balanced).

**Theorem 3.9 (Invariance under firing).** If $w$ is conserved by $r$ and $r$ is
enabled at $x$, then $\mathrm{mass}_w(r.\mathrm{fire}(x)) = \mathrm{mass}_w(x)$.

*Proof.* On enabled states $r.\mathrm{fire}(x)(s) = x(s) - r.\mathrm{reactant}(s) +
r.\mathrm{product}(s)$ over $\mathbb{Z}$. Substituting and splitting the sum,
$$\mathrm{mass}_w(r.\mathrm{fire}(x)) = \mathrm{mass}_w(x)
- \sum_s w(s)\, r.\mathrm{reactant}(s) + \sum_s w(s)\, r.\mathrm{product}(s),$$
and the last two terms cancel by the balance condition. $\qquad\blacksquare$

**Theorem 3.10 (Conservation along trajectories).** If every reaction of $rs$
conserves $w$, then $\mathrm{mass}_w(y) = \mathrm{mass}_w(x)$ whenever
$\mathrm{Reach}_{rs}(x,y)$.

*Proof.* Induction on reachability using Theorem 3.9. $\qquad\blacksquare$

Theorem 3.10 simultaneously expresses conservation of mass, of charge, and of each
atomic species, and it furnishes *non-reachability certificates*: if
$\mathrm{mass}_w(x) \ne \mathrm{mass}_w(t)$ for some balanced $w$, then $t$ is
unreachable from $x$.

---

## 4. The fundamental limitation: no zero-test

Register (counter) machines are Turing-complete, and their power rests on the
*zero-test*: the ability to branch on whether a counter is empty. We show the
discrete CRN model cannot implement it.

**Theorem 4.1 (No zero-test / no absence detector).** Let $S$ have decidable
equality and fix a species $s_0$. There is no reaction $r$ whose enabling
condition coincides with "$s_0$ is absent"; that is,
$$\neg\; \big(\forall x,\ r.\mathrm{enabled}(x) \iff x(s_0) = 0\big).$$

*Proof.* Suppose such an $r$ exists. A reaction is always enabled at its own
reactant complex, $r.\mathrm{enabled}(r.\mathrm{reactant})$, so the hypothesis
forces $r.\mathrm{reactant}(s_0) = 0$. Now define
$$z(s) = \begin{cases} 1 & s = s_0,\\ r.\mathrm{reactant}(s) & s \ne s_0.\end{cases}$$
Then $r.\mathrm{reactant} \le z$ (they agree off $s_0$, and at $s_0$ we have
$0 \le 1$), so $r.\mathrm{enabled}(z)$. The hypothesis then yields $z(s_0) = 0$,
contradicting $z(s_0) = 1$. $\qquad\blacksquare$

The proof is a direct exploitation of monotonicity (Lemma 3.1): enabling is
upward closed, but "$x(s_0) = 0$" is downward closed, and no nontrivial condition
is both. Consequently the exact discrete mass-action model is only as strong as a
vector addition system / Petri net, for which coverability is decidable — a
positive counterpoint that also precludes universality.

**Remark 4.2 (Recovering universality).** The obstruction is specific to the
*exact, deterministic* reading of the dynamics. Stochastic chemical reaction
networks with mass-action rates can simulate register machines with unbounded time
and vanishing error probability (Soloveichik–Cook–Winfree–Bruck): given more time,
the probability of an erroneous "phantom" reaction masking a nonempty counter can
be driven to zero. Universality thus reappears once one adds a probabilistic,
continuous-time layer and tolerates error — precisely the ingredients the exact
model lacks.

---

## 5. Molecular parallelism yields only a constant-factor speedup

We now abstract a computation by its **work** $W$ (total primitive operations
required) and a **schedule** over $T$ steps, where $\mathrm{ops}(t)$ operations
occur at step $t$, each step bounded by the parallelism $p$.

**Theorem 5.1 (Work–time bound).** If $\mathrm{ops}(t) \le p$ for all
$t \in \{0,\dots,T-1\}$ and $W \le \sum_t \mathrm{ops}(t)$, then $W \le T \cdot p$.

*Proof.* $W \le \sum_t \mathrm{ops}(t) \le \sum_t p = T \cdot p$. $\qquad\blacksquare$

**Theorem 5.2 (Parallel time lower bound).** Under the hypotheses of Theorem 5.1
with $p \ge 1$, we have $\lfloor W / p \rfloor \le T$.

*Proof.* Divide $W \le T \cdot p$ by $p$ and cancel. $\qquad\blacksquare$

**Theorem 5.3 (Speedup at most $p$).** Under the same hypotheses, $W \le p \cdot T$.
Since the sequential running time is $W$ (one operation per step) and the parallel
time is $T$, the speedup satisfies $W/T \le p$.

*Proof.* Commute the product in Theorem 5.1. $\qquad\blacksquare$

**Theorem 5.4 (Volume-bounded speedup).** If the device admits at most $P$
simultaneously active molecules ($p \le P$, a bound proportional to volume), then
$W \le P \cdot T$.

*Proof.* Chain $W \le p \cdot T \le P \cdot T$. $\qquad\blacksquare$

**Theorem 5.5 (No exponential speedup).** Suppose a family of problems indexed by
input size $n$ has work at least $2^n$, run on a device of fixed volume so that
$2^n \le P \cdot T_{\mathrm{par}}(n)$ for all $n$. Then $T_{\mathrm{par}}$ is
unbounded: there is no constant $C$ with $T_{\mathrm{par}}(n) \le C$ for all $n$.

*Proof.* If such a $C$ existed, then $2^n \le P \cdot T_{\mathrm{par}}(n) \le P\cdot C$
for all $n$, contradicting the unboundedness of $2^n$. $\qquad\blacksquare$

**Theorem 5.6 (Quantitative exponential lower bound).** With a fixed budget
$P \ge 1$ and $2^n \le P \cdot T_{\mathrm{par}}(n)$ for all $n$, we have
$T_{\mathrm{par}}(n) \ge \lfloor 2^n / P \rfloor$.

*Proof.* Divide the hypothesis by $P$ and cancel. $\qquad\blacksquare$

**Interpretation.** Parallelism divides running time by the number of concurrent
workers and no more. A test tube contains roughly $2^{80}$ molecules; treated as a
fixed constant $P$, this yields a one-time factor-$P$ speedup — dramatic but
constant — and cannot convert exponential work into bounded, or even polynomial,
time. The bound also encodes a physical truth: only $P$ molecules fit, and those
molecules must first be *prepared* (synthesized and mixed), so the search space is
never explored for free.

---

## 6. Information-theoretic storage and description bounds

Model $k$ bits of molecular state as the type $\mathrm{Fin}\,k \to \mathrm{Bool}$,
of which there are exactly $2^k$. A **configuration map** assigns to each
distinguishable input a molecular state.

**Theorem 6.1 (Storage capacity).** If $I$ is finite and
$\mathrm{config} : I \to (\mathrm{Fin}\,k \to \mathrm{Bool})$ is injective, then
$|I| \le 2^k$.

*Proof.* An injection into a set of size $2^k = |\mathrm{Fin}\,k \to \mathrm{Bool}|$
bounds the domain cardinality. $\qquad\blacksquare$

**Theorem 6.2 (Bit lower bound).** Under the hypotheses of Theorem 6.1,
$\log_2 |I| \le k$; distinguishing $N$ inputs requires at least $\log_2 N$
two-state units.

*Proof.* Apply the monotone $\log_2$ to $|I| \le 2^k$ and simplify
$\log_2 2^k = k$. $\qquad\blacksquare$

**Theorem 6.3 (Insufficient volume).** If $2^k < |I|$, no injective encoding
$I \to (\mathrm{Fin}\,k \to \mathrm{Bool})$ exists: some two inputs must share a
state.

*Proof.* Immediate from Theorem 6.1 by contradiction. $\qquad\blacksquare$

**Theorem 6.4 (Kolmogorov-style volume lower bound).** For a finite family $B$ of
distinct behaviors, any injective description scheme
$\mathrm{descr} : B \to (\mathrm{Fin}\,k \to \mathrm{Bool})$ satisfies
$\log_2 |B| \le k$.

*Proof.* Specialize Theorem 6.2 to $B$. $\qquad\blacksquare$

Since the number of two-state molecules — and hence the physical volume — scales
with the description length $k$, Theorem 6.4 is the discrete shadow of the
principle that the minimum volume of a molecular computer for a family of tasks is
bounded below by the family's descriptive (Kolmogorov) complexity: more distinct
behaviors demand proportionally more volume.

**Theorem 6.5 (Density sanity check).** $2^{59} < 10^{18} \le 2^{60}$.
Consequently a $59$-unit register holds fewer than $10^{18}$ configurations, so no
injective encoding of $10^{18}$ behaviors fits in $59$ units; $60$ units suffice.

*Proof.* Direct numerical verification. $\qquad\blacksquare$

The headline claim of storing $10^{18}$ bits is therefore consistent with
information theory: it requires on the order of $60$ two-state units per
addressable state, feasible only because molecular components are extraordinarily
small. Information theory constrains and quantifies the density conjecture rather
than refuting it.

---

## 7. Algorithms and computational illustrations

The theory suggests several concrete algorithms, developed in the accompanying
computational material:

1. **CRN reachability / coverability search.** A breadth-first exploration of the
   reachable set from an initial state, pruned by conservation certificates
   (Theorem 3.10): any target disagreeing with the source on a balanced functional
   is discarded without search. Complexity is governed by the (possibly infinite)
   reachable set; conservation invariants and coverability monotonicity
   (Theorem 3.7) bound it in practice.

2. **Conservation-law finder.** Given a CRN, the balanced functionals $w$ form the
   integer kernel of the stoichiometry matrix (products minus reactants). Computing
   an integer basis of this kernel yields all linear conservation laws, each an
   independent non-reachability certificate.

3. **Speedup/volume calculator.** Given work $W$, parallelism $p$, and volume cap
   $P$, compute the parallel time lower bound $\lceil W/p \rceil$, the speedup cap
   $\min(p, W)$, and — for an exponential-work family — the forced growth
   $\lceil 2^n/P \rceil$ of parallel time (Theorems 5.3–5.6).

4. **Storage sizer.** Given $N$ inputs (or $M$ behaviors), return the minimal
   register size $\lceil \log_2 N \rceil$ and verify feasibility against a volume
   budget (Theorems 6.1–6.5).

---

## 8. Applications

- **Design certification.** Conservation laws (Theorem 3.10) certify that a
  proposed molecular computer *cannot* reach an illegal state, a lightweight
  correctness check independent of full reachability analysis.
- **Feasibility screening.** The storage bounds (Section 6) give an immediate,
  encoding-independent lower bound on the molecular resources any proposed device
  must have, ruling out impossible designs before synthesis.
- **Expectation setting for DNA computing.** Theorem 5.5 tempers the hope of
  brute-forcing NP-complete problems with molecular parallelism, redirecting
  effort toward tasks where a large constant-factor speedup is genuinely valuable.
- **Guidance toward universality.** Theorem 4.1 identifies the exact missing
  ingredient — absence detection — explaining why practical universal molecular
  computers are built on *stochastic*, error-tolerant primitives (Remark 4.2).

---

## 9. Discussion

The results form a self-consistent map of molecular computation's frontier. On the
side of *power*, the discrete model is provably limited: monotonicity forbids
absence detection (Theorem 4.1), and volume-bounded parallelism forbids
exponential speedup (Theorem 5.5). On the side of *structure*, the same
monotonicity delivers translation invariance and monotone coverability, while
balance delivers conservation laws that both constrain dynamics and certify
impossibility. On the side of *resources*, information theory pins the storage
cost at $\log_2 N$ units and the volume at the log of the behavioral repertoire.

A recurring theme is that the model's greatest strength and its sharpest weakness
are the same property. Monotonicity makes chemistry robust to surplus and
analytically tractable (decidable coverability), yet it is exactly what blocks the
zero-test and thus universality. The way forward — randomness with vanishing error —
is not a patch but a principled trade of certainty for power.

**Limitations.** We treat the exact, rate-free discrete dynamics; quantitative
stochastic behavior and continuous-time kinetics are outside the present scope. The
parallelism model is deliberately abstract (work and per-step throughput),
capturing the counting argument that underlies the speedup limit rather than the
details of any particular molecular architecture.

---

## 10. Future directions

This work formalizes three pillars of the nanotechnology-computation program:
discrete mass-action CRNs, the parallelism limit, and information-theoretic
storage bounds. Natural next steps:

1. **Turing-completeness with error.** The no-zero-test obstruction is exactly why
   *exact* CRNs are only as strong as Petri nets (decidable coverability).
   Formalize the Soloveichik–Cook–Winfree–Bruck construction: stochastic CRNs that
   simulate a register machine with unbounded time and vanishing error probability
   recover full Turing power. This requires a probabilistic / continuous-time layer
   atop the present discrete semantics.

2. **Decidability of coverability.** Prove that the well-quasi-order machinery
   (Dickson's lemma) and a Karp–Miller construction imply coverability of the CRN
   model is decidable — a positive counterpart to the no-zero-test theorem.

3. **Reachability invariants via conservation.** Use conservation along
   trajectories to derive Farkas-style non-reachability certificates: when no
   nonnegative combination of conserved functionals separates source from target,
   seek additional siphon/trap structure to certify non-reachability.

---

## 11. Conclusion

Molecular computing is neither omnipotent nor illusory. In the exact discrete
model, chemical reaction networks are monotone, conservative, blind to absence,
capped in speedup by their volume, and bounded in memory by information. These are
theorems, not engineering contingencies. They delimit the possible precisely, and
in doing so they point ingenuity where it can succeed: randomized, error-tolerant
designs for universality; exploitation of molecular memory's staggering density;
and problems for which a large constant-factor speedup is a decisive advantage.
