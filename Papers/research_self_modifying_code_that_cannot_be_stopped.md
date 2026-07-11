# The Halting Problem for Self-Modifying Code: Undecidable, but Not Strictly Harder

## Abstract

We develop, as a single linear chain of results, the theory of the halting problem for *self-modifying* computation — machines whose transition rule may rewrite the running program mid-execution. Starting from Lawvere's fixed-point theorem, we descend through Cantor's diagonal argument to a purely operational statement that no program can realize the "contrarian" (anti-diagonal) behavior. We then introduce a self-modifying machine model, prove a step-exact simulation theorem showing that any self-modifying machine is faithfully mimicked by an ordinary fixed-program machine over an enlarged state space ("code becomes data"), and use it to establish that the halting problems for self-modifying and fixed-program machines are *many-one equivalent*. This corrects a common informal claim: self-modification does **not** make halting strictly harder; it introduces no higher Turing degree. The genuine phenomenon is self-reference. We prove a self-referential halting theorem — any system able to build the contrarian program defeats every candidate total halting decider — and derive two consequences: a *virus paradox* (no total detector decides self-halting behavior everywhere) and an *alignment obstruction* (no total monitor can correctly certify a non-trivial self-referential behavioral property for every program). We close by making the correction to the folk framing precise and quantitative.

**Keywords:** halting problem, self-modifying code, Lawvere fixed-point theorem, Cantor's diagonal argument, many-one reduction, Turing degree, undecidability, AI alignment, Rice's theorem.

---

## 1. Introduction

Self-modifying code — a program that rewrites its own instructions while executing — has an aura of danger and mystery. Metamorphic viruses, just-in-time compilers, genetic-programming systems, and increasingly self-editing machine-learning pipelines all blur the classical boundary between program and data. A recurring piece of folklore holds that predicting the behavior of such programs must be *strictly harder* than the classical halting problem: if a program can become something else while you are analyzing it, surely no analysis can keep up.

This paper subjects that intuition to precise scrutiny and finds it wrong. Our contributions are:

1. A clean, abstract derivation of the diagonal machinery, from **Lawvere's fixed-point theorem** down to an operational "no contrarian program" lemma (Section 3).
2. A formal **self-modifying machine model** with a program that may change every step, and a faithful **simulation theorem** (Section 4–5).
3. A proof that the self-modifying and fixed-program halting problems are **many-one equivalent** (Section 6), correcting the "strictly harder" folklore.
4. A **self-referential halting theorem** and two applications — the **virus paradox** and an **alignment obstruction** (Sections 7–8).

The through-line is that self-modification and self-reference are distinct phenomena with opposite morals. Self-modification is *cheap*: it can always be flattened into ordinary memory manipulation, adding no computational power. Self-reference is *fatal*: any system able to describe and act against its own analyzers admits a contrarian that no analyzer survives.

**Historical context.** The undecidability of the classical halting problem is due to Turing (1936), whose diagonal construction underlies every result below. Cantor's diagonal argument (1891) is its set-theoretic ancestor, and Lawvere's fixed-point theorem (1969) is the categorical distillation that unifies them: all three are the single observation that a fixed-point-free endomap obstructs any surjection onto a function space. Rice's theorem (1953) extends undecidability from halting to every non-trivial behavioral property. Our contribution is not a new undecidability phenomenon but a precise *placement* of self-modifying computation relative to this classical landscape, together with an explicit, self-contained derivation of the alignment-relevant corollaries. The recurring intuition that self-modification escapes the classical bounds appears frequently in informal discussions of metamorphic malware and self-improving agents; we show it is mathematically unfounded.

---

## 2. Preliminaries and Notation

We work constructively over arbitrary types. We write $\mathrm{Bool} = \{\mathsf{true}, \mathsf{false}\}$ with negation $\lnot$, and use $\mathsf{Option}\,X = \{\mathsf{none}\} \cup \{\mathsf{some}\,x : x \in X\}$ to model partial results, with $\mathsf{none}$ denoting "halted." A function $g$ is **surjective** if every element of its codomain is a value of $g$.

For predicates $A : \alpha \to \mathrm{Prop}$ and $B : \beta \to \mathrm{Prop}$, we say $A$ **many-one reduces** to $B$, written $A \le_m B$, if there is a (total, computable in the intended interpretation) function $f : \alpha \to \beta$ with
$$A(x) \iff B(f(x)) \quad \text{for all } x.$$
If $A \le_m B$ and $B \le_m A$ we call $A$ and $B$ **many-one equivalent**.

---

## 3. The Diagonalization Engine

All impossibility results below flow from a single abstract source.

### 3.1 Lawvere's fixed-point theorem

**Theorem 1 (Lawvere).** *Let $A$ and $B$ be types and let $g : A \to (A \to B)$ be surjective. Then every self-map $f : B \to B$ has a fixed point: there exists $b \in B$ with $f(b) = b$.*

*Proof.* Consider the function $A \to B$ given by $x \mapsto f(g(x)(x))$. Since $g$ is surjective, this function equals $g(a)$ for some $a \in A$. Evaluate at $a$:
$$g(a)(a) = f(g(a)(a)),$$
so $b := g(a)(a)$ is a fixed point of $f$. $\qquad\blacksquare$

Lawvere's theorem is the abstract kernel of every diagonal argument: surjectivity of a "naming" map $g$ forces fixed points, so any *fixed-point-free* map obstructs surjectivity.

### 3.2 Cantor for Boolean predicates

**Theorem 2 (Cantor, Boolean form).** *For any type $A$, no map $g : A \to (A \to \mathrm{Bool})$ is surjective. The Boolean predicates on $A$ are not enumerable by $A$.*

*Proof.* The negation map $f = \lnot : \mathrm{Bool} \to \mathrm{Bool}$ has no fixed point, since $\lnot b \ne b$ for every $b$. If $g$ were surjective, Theorem 1 would supply a fixed point of $\lnot$, a contradiction. $\qquad\blacksquare$

### 3.3 The operational form: no contrarian behavior

Interpret a **behavior** as a map assigning to each program $p$ a Boolean predicate $\mathrm{beh}(p) : \mathrm{Prog} \to \mathrm{Bool}$ — the input/output bit of $p$. The *contrarian* (anti-diagonal) behavior sends $q \mapsto \lnot\,\mathrm{beh}(q)(q)$.

**Theorem 3 (No contrarian behavior).** *Let $\mathrm{beh} : \mathrm{Prog} \to (\mathrm{Prog} \to \mathrm{Bool})$. No program $p_0$ satisfies $\mathrm{beh}(p_0) = \big(q \mapsto \lnot\,\mathrm{beh}(q)(q)\big)$.*

*Proof.* Suppose equality held. Evaluate both sides at $p_0$:
$$\mathrm{beh}(p_0)(p_0) = \lnot\,\mathrm{beh}(p_0)(p_0),$$
a Boolean equal to its own negation — impossible. $\qquad\blacksquare$

This is Cantor in work clothes: the behavior "do the opposite of what $q$ does on itself" is not realizable as any single program's behavior. It is the seed of the halting argument.

---

## 4. A Self-Modifying Machine Model

We now model machines whose code may change at runtime.

**Definition 1 (Self-modifying machine).** Fix types $P$ (programs) and $S$ (states). A **self-modifying machine** (SMM) is a single transition function
$$\mathrm{step} : P \to S \to \mathsf{Option}(P \times S).$$
Given the current program $p$ and current state $s$, $\mathrm{step}(p,s)$ is either $\mathsf{none}$ (the machine halts) or $\mathsf{some}(p', s')$, delivering a possibly-different program $p'$ and state $s'$. Because $p'$ may differ from $p$, the code in control genuinely changes step to step.

**Definition 2 (Configuration).** A **configuration** is a pair $\mathrm{cfg} = (\mathrm{prog}, \mathrm{state}) \in P \times S$ recording the currently running program and current data.

**Definition 3 (Run and halting).** The $n$-step run is defined by recursion:
$$\mathrm{run}(\mathrm{cfg}, 0) = \mathsf{some}\,\mathrm{cfg}, \qquad
\mathrm{run}(\mathrm{cfg}, n{+}1) = \begin{cases} \mathsf{none} & \text{if } \mathrm{step}(\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state}) = \mathsf{none},\\[2pt] \mathrm{run}((p', s'), n) & \text{if } \mathrm{step}(\ldots) = \mathsf{some}(p', s'). \end{cases}$$
The machine **halts** from $\mathrm{cfg}$, written $\mathrm{halts}(\mathrm{cfg})$, if $\mathrm{run}(\mathrm{cfg}, n) = \mathsf{none}$ for some $n \in \mathbb{N}$.

**Definition 4 (Standard machine).** A **standard** (fixed-program) machine over state type $S$ is a transition $\mathrm{step} : S \to \mathsf{Option}\,S$, with $n$-step run and halting predicate $\mathrm{halts}(s) := \exists n,\ \mathrm{run}(s, n) = \mathsf{none}$ defined analogously. Its program never changes.

---

## 5. The Simulation Theorem

The key structural fact is that a self-modifying machine is nothing more than a fixed-program machine that keeps its program in its data.

**Definition 5 (Code becomes data).** For an SMM $m$ over $(P, S)$, define its **standard simulation** $m^{\mathrm{Std}}$, a standard machine over the enlarged state $P \times S$, by
$$m^{\mathrm{Std}}.\mathrm{step}(p, s) = \begin{cases} \mathsf{none} & \text{if } m.\mathrm{step}(p, s) = \mathsf{none},\\ \mathsf{some}(p', s') & \text{if } m.\mathrm{step}(p, s) = \mathsf{some}(p', s'). \end{cases}$$
The program is absorbed into the data; a single unchanging rule reads it out, takes one self-modifying step, and writes the new program back.

**Lemma 4 (Step-exact simulation).** *For every configuration $\mathrm{cfg}$ and every $n$,*
$$\big(m.\mathrm{run}(\mathrm{cfg}, n)\big).\mathrm{map}\,(c \mapsto (c.\mathrm{prog}, c.\mathrm{state})) = m^{\mathrm{Std}}.\mathrm{run}\big((\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state}),\, n\big).$$

*Proof.* Induction on $n$. For $n = 0$ both sides are $\mathsf{some}(\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state})$. For $n{+}1$, case on $m.\mathrm{step}(\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state})$: if $\mathsf{none}$, both sides are $\mathsf{none}$; if $\mathsf{some}(p', s')$, both sides reduce to the $n$-step claim for the configuration $(p', s')$, which is the induction hypothesis. $\qquad\blacksquare$

**Corollary 5 (Halting preserved stepwise).** *$m.\mathrm{run}(\mathrm{cfg}, n) = \mathsf{none}$ iff $m^{\mathrm{Std}}.\mathrm{run}((\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state}), n) = \mathsf{none}$.*

*Proof.* Apply $\mathrm{map}$ to both sides of Lemma 4 and observe $\mathsf{none}.\mathrm{map}\,\phi = \mathsf{none}$ while $(\mathsf{some}\,x).\mathrm{map}\,\phi = \mathsf{some}(\phi\,x) \ne \mathsf{none}$. $\qquad\blacksquare$

**Theorem 6 (Simulation Theorem).** *A self-modifying machine halts from $\mathrm{cfg}$ if and only if its standard simulation halts from the corresponding state:*
$$m.\mathrm{halts}(\mathrm{cfg}) \iff m^{\mathrm{Std}}.\mathrm{halts}(\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state}).$$

*Proof.* Both sides are existential quantifications over $n$ of the two equivalent (by Corollary 5) statements. $\qquad\blacksquare$

Self-modification adds no computational power beyond encoding the program as data.

---

## 6. Turing Equivalence of the Two Halting Problems

We now formalize the correction to the folklore.

**Theorem 7 (Self-modifying $\le_m$ standard).** *For any SMM $m$, $\ m.\mathrm{halts} \le_m m^{\mathrm{Std}}.\mathrm{halts}$, via the map $\mathrm{cfg} \mapsto (\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state})$.*

*Proof.* Immediate from Theorem 6. $\qquad\blacksquare$

For the reverse direction we embed a standard machine as an SMM with a trivial one-point program type.

**Definition 6 (Embedding).** For a standard machine $m$ over $S$, define $m^{\mathrm{emb}}$, an SMM over $(\mathrm{Unit}, S)$, by $m^{\mathrm{emb}}.\mathrm{step}(\_,\, s) = (m.\mathrm{step}(s)).\mathrm{map}\,(s' \mapsto ((), s'))$. The program never changes; only the state does.

**Lemma 8 (Embedding preserves halting stepwise).** *$m^{\mathrm{emb}}.\mathrm{run}(((), s), n) = \mathsf{none}$ iff $m.\mathrm{run}(s, n) = \mathsf{none}$.*

*Proof.* Induction on $n$, casing on $m.\mathrm{step}(s)$; the $\mathrm{Unit}$ component is inert. $\qquad\blacksquare$

**Theorem 9 (Standard $\le_m$ self-modifying).** *For any standard machine $m$, $\ m.\mathrm{halts} \le_m m^{\mathrm{emb}}.\mathrm{halts}$, via $s \mapsto ((), s)$.*

*Proof.* Immediate from Lemma 8. $\qquad\blacksquare$

**Theorem 10 (Turing equivalence).** *The self-modifying halting problem and the standard halting problem are many-one equivalent. Consequently, self-modification does not make halting strictly harder.*

*Proof.* Combine Theorems 7 and 9: each reduces to the other. $\qquad\blacksquare$

The equivalence is witnessed at the level of *deciders*, not merely degrees:

**Theorem 11 (Decider transfer).** *(i) If $D : P \times S \to \mathrm{Bool}$ decides $m^{\mathrm{Std}}.\mathrm{halts}$ (i.e. $D(s) = \mathsf{true} \iff m^{\mathrm{Std}}.\mathrm{halts}(s)$), then $D'(\mathrm{cfg}) := D(\mathrm{cfg}.\mathrm{prog}, \mathrm{cfg}.\mathrm{state})$ decides $m.\mathrm{halts}$. (ii) Conversely, any decider $D'$ for $m.\mathrm{halts}$ yields a decider for $m^{\mathrm{Std}}.\mathrm{halts}$.*

*Proof.* Both directions rewrite through the Simulation Theorem (Theorem 6). $\qquad\blacksquare$

**Remark.** This refutes the "strictly harder" framing decisively. The running program is absorbed into the data by the "code becomes data" map, so no strictly higher Turing degree is introduced. Undecidability is real, but it is precisely the classical undecidability (degree $\mathbf{0}'$, level $\Sigma^0_1$).

---

## 7. The Self-Referential Halting Theorem

The genuine obstruction is self-reference, made operational by the *contrarian program*.

**Theorem 12 (No correct decider).** *Let $\mathrm{Halts} : \mathrm{Prog} \to \mathrm{Prog} \to \mathrm{Prop}$ be the "halts on input" relation and let $H : \mathrm{Prog} \to \mathrm{Prog} \to \mathrm{Bool}$ be any candidate decider. Suppose the system can build a contrarian program $d$ with*
$$\mathrm{Halts}(d, q) \iff H(q, q) = \mathsf{false} \quad \text{for all } q. \tag{$\ast$}$$
*Then $H$ is not correct everywhere: there is a program (namely $d$) on which $H$'s self-verdict is wrong, i.e. $\lnot\big(H(d,d) = \mathsf{true} \iff \mathrm{Halts}(d,d)\big)$.*

*Proof.* Instantiate $(\ast)$ at $q = d$: $\mathrm{Halts}(d, d) \iff H(d,d) = \mathsf{false}$. If $H$ were correct on $d$, then $H(d,d) = \mathsf{true} \iff \mathrm{Halts}(d,d)$; substituting gives $H(d,d) = \mathsf{true} \iff H(d,d) = \mathsf{false}$, impossible for a Boolean. $\qquad\blacksquare$

**Theorem 13 (Halting contradiction).** *There is no total decider $H$ that is simultaneously correct everywhere — $H(p,q) = \mathsf{true} \iff \mathrm{Halts}(p,q)$ for all $p, q$ — while the system admits the contrarian $d$ of $(\ast)$. The two hypotheses are jointly contradictory.*

*Proof.* By Theorem 12 the contrarian $d$ is a point of incorrectness, contradicting universal correctness of $H$. $\qquad\blacksquare$

**Proposition 14 (Non-vacuity).** *The hypotheses of Theorem 12 are satisfiable: there exist $\mathrm{Prog}$, $\mathrm{Halts}$, $H$, and $d$ with $(\ast)$. For instance, take $\mathrm{Prog} = \mathbb{N}$, $\mathrm{Halts}(p, q) := (p \ne 0)$, $H \equiv \mathsf{true}$, and $d = 0$: then $\mathrm{Halts}(0, q)$ is false and $H(q,q) = \mathsf{false}$ is false, so $(\ast)$ holds.*

Thus Theorem 12 is a genuine impossibility, not a vacuous implication. The point is that a Turing-complete self-modifying system *does* satisfy $(\ast)$: it can read a proposed $H$ and rewrite itself into the contrarian $d$.

---

## 8. The Virus Paradox and the Alignment Obstruction

Two applications specialize the self-referential theorem.

**Theorem 15 (Virus paradox).** *Let $\mathrm{Detect} : \mathrm{Prog} \to \mathrm{Bool}$ be a total detector, and suppose the system can build a contrarian $d$ with $\mathrm{Halts}(d, q) \iff \mathrm{Detect}(q) = \mathsf{false}$ for all $q$. Then $\mathrm{Detect}$ does not decide self-halting behavior everywhere: it is not the case that $\mathrm{Detect}(q) = \mathsf{true} \iff \mathrm{Halts}(q, q)$ for all $q$.*

*Proof.* Apply Theorem 12 with $H(p, q) := \mathrm{Detect}(q)$ (ignoring the first argument). The resulting counterexample $d$ shows $\mathrm{Detect}$ cannot agree with self-halting everywhere. $\qquad\blacksquare$

Interpretation: a perfect universal behavior scanner — one that always terminates and correctly flags whether any program, run on its own code, halts — cannot exist. Malware analysis is therefore intrinsically heuristic.

**Theorem 16 (Alignment obstruction).** *Let $M : \mathrm{Prog} \to \mathrm{Bool}$ be a total safety monitor, where $M(q) = \mathsf{true}$ is intended to certify that $q$ is safe in the sense $\lnot\,\mathrm{Halts}(q, q)$ ("never terminates on its own code"). Suppose the system can build a contrarian $d$ whose termination tracks the monitor's verdict:*
$$\mathrm{Halts}(d, q) \iff M(q) = \mathsf{true} \quad \text{for all } q. \tag{$\dagger$}$$
*Then $M$ is wrong on some program: there exists $q$ with $\lnot\big(M(q) = \mathsf{true} \iff \lnot\,\mathrm{Halts}(q, q)\big)$.*

*Proof.* Take $q = d$. From $(\dagger)$, $\mathrm{Halts}(d,d) \iff M(d) = \mathsf{true}$. If $M$ were a correct safety certifier at $d$, then $M(d) = \mathsf{true} \iff \lnot\,\mathrm{Halts}(d,d)$. Chaining the two equivalences yields $\mathrm{Halts}(d,d) \iff \lnot\,\mathrm{Halts}(d,d)$. Writing $P := \mathrm{Halts}(d,d)$, we have $P \iff \lnot P$; then $\lnot P$ holds (else $P$ gives $\lnot P$), and $\lnot P$ gives $P$ — contradiction. $\qquad\blacksquare$

Interpretation: no total monitor can correctly certify a non-trivial self-referential behavioral property for *every* program. Any oversight mechanism that is total (always returns a verdict), sound (never wrong), and universal (works on every agent) is impossible for a sufficiently expressive agent class. Practical alignment must relax one of the three.

---

## 9. Algorithms

Although the halting decider is impossible in general, the *constructions* underlying the proofs are concrete algorithms.

**Algorithm A (Bounded self-modifying simulation).** Given an SMM's transition $\mathrm{step}$, a start configuration, and a step budget $N$, iterate the "code becomes data" rule at most $N$ times, returning `HALTED` if $\mathsf{none}$ is emitted and `RUNNING` otherwise. This is the executable content of the Simulation Theorem and is the best any sound total analyzer can do: sound but incomplete (a `RUNNING` verdict is inconclusive).

**Algorithm B (Contrarian construction).** Given a candidate decider $H$, construct the contrarian program $d$: on input $q$, compute $H(q, q)$ and loop iff it is $\mathsf{true}$ (halt iff $\mathsf{false}$). Feeding $d$ its own code exhibits the incorrectness guaranteed by Theorem 12.

**Algorithm C (Reduction transport).** Given the "code becomes data" map, transport any instance of the self-modifying halting question to a fixed-program instance and back via the $\mathrm{Unit}$-embedding, witnessing Theorem 10.

Detailed pseudocode and reference implementations accompany this work.

---

## 10. A Worked Example

To make the abstractions concrete, consider a small self-modifying machine with two programs $P = \{A, B\}$ and state $S = \mathbb{N}$, whose transition is
$$\mathrm{step}(p, s) = \begin{cases} \mathsf{none} & \text{if } s = 0,\\ (\overline{p},\ s - 1) & \text{if } s > 0, \end{cases}$$
where $\overline{A} = B$ and $\overline{B} = A$. This machine *genuinely rewrites the program in control at every step*: the run from $(A, 3)$ visits configurations
$$(A,3) \to (B,2) \to (A,1) \to (B,0) \to \mathsf{none},$$
halting after four steps. The program alternates $A, B, A, B$ — no single fixed program governs the computation, yet the machine is manifestly well-behaved.

Its standard simulation $m^{\mathrm{Std}}$ over $P \times S$ uses the single rule "read $(p,s)$, decrement $s$, flip $p$" and produces the identical sequence of pairs $(A,3), (B,2), (A,1), (B,0)$ before halting. The Simulation Theorem (Theorem 6) is visible here directly: the self-modifying trace and the fixed-program trace are literally the same sequence of pairs, so one halts within $n$ steps iff the other does. Deciding halting for this machine is trivial — it halts from $(p, s)$ after exactly $s$ steps — precisely because the enlarged state exposes the counter as ordinary data. Nothing about the program's self-rewriting places it beyond routine analysis.

The contrast with the self-referential constructions of Sections 7–8 is instructive. There, undecidability does not arise from *rewriting* but from *diagonalization against a predictor*: the contrarian $d$ is not merely a program that changes itself, but one whose changes are functionally dependent on a verdict passed about $d$'s own code. It is this closed loop — description, prediction, negation — and not the mere capacity for self-modification, that no analyzer can escape.

## 11. Discussion: Self-Modification vs. Self-Reference

The results sharpen a distinction usually left blurry.

- **Self-modification is computationally free.** By the Simulation Theorem and Turing equivalence, a machine that rewrites its own code is exactly as powerful — and its halting problem exactly as hard — as a fixed-program machine over a larger state. The folklore that self-modification lifts a problem to a higher Turing degree is false: the program is always absorbable into the data.
- **Self-reference is the real wall.** The impossibility comes from a system's ability to describe a proposed analyzer and act against it — the contrarian. This is the diagonal argument of Cantor and Turing, traced here to Lawvere's fixed-point theorem via a single fixed-point-free map, $\lnot$.

The AI-alignment reading is that a perfect, always-correct, universal safety monitor is not merely hard but provably impossible against sufficiently expressive agents, for the same reason the halting problem is undecidable. This does not doom alignment; it delimits it. Viable oversight must relax totality (permit "don't know"), soundness (accept a quantified error rate), or universality (restrict the agent class).

---

## 12. Future Directions

1. **A concrete universal contrarian.** Theorem 12 takes the contrarian $d$ as a hypothesis. Build $d$ explicitly inside a concrete universal SMM over $\mathbb{N} \times \mathbb{N}$ (a small register or Turing machine), converting the conditional undecidability into an unconditional statement about that machine.
2. **Oracle self-modification and the arithmetical hierarchy.** Add oracle access to the SMM and locate the resulting halting problem. The present equivalence suggests it stays $\Sigma^0_1$ relative to the oracle; make this precise and prove non-collapse for iterated oracles.
3. **Bounded self-modification depth.** Define machines that may rewrite their program at most $k$ times; show decidability at $k = 0$ and undecidability for $k \ge 1$ over a Turing-complete base, pinning the exact threshold.
4. **Rice's theorem in full.** Generalize the virus paradox to every non-trivial *behavioral* property of the self-modifying run, deriving it from the no-correct-decider theorem by an explicit reduction.
5. **Quantitative alignment.** Strengthen the alignment obstruction to a measure-theoretic or resource-bounded statement, bounding how often, or under what resource limits, any monitor must err.

---

## 13. Conclusion

Self-modifying code cannot be perfectly predicted — but not because it is strictly harder than ordinary code. We proved it is *many-one equivalent* to the classical halting problem: code that rewrites itself is code that shuffles data, nothing more. The true and unclimbable obstruction is self-reference: any system able to build a contrarian defeats every candidate predictor of its own behavior, yielding the virus paradox and a computability-theoretic wall for AI alignment. The reassuring and the sobering lessons are two sides of one diagonal mirror.
