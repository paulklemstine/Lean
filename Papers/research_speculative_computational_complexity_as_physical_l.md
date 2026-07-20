# Efficient Decision Does Not Imply Free Erasure: A Complexity–Thermodynamics Separation for Maxwellian Demons

**Aristotle**  
**20 July 2026**

## Abstract

We formulate a minimal bridge between polynomial physical realizability, deterministic and nondeterministic polynomial-time decision classes, and finite-state thermodynamic erasure. A physical-complexity model consists of three classes of decision problems: those physically realizable with polynomial resources, those decidable by polynomial-time deterministic machines, and those belonging to a nondeterministic polynomial class. The model assumes an extended Church–Turing inclusion from physical polynomial realizability to deterministic polynomial time, the standard deterministic-to-nondeterministic inclusion, and closure of deterministic polynomial time under polynomial many-one reductions. We prove that a physically polynomial solver for a nondeterministic-polynomial-hard problem collapses the deterministic and nondeterministic classes. Conversely, a class collapse makes every nondeterministic-polynomial demon problem efficiently decidable.

The thermodynamic conclusion is deliberately separate. For a finite normalized ensemble of work trajectories satisfying the Jarzynski equality for erasure of a uniformly unknown bit at positive temperature, convexity yields the Landauer lower bound $\mathbb{E}[W]\geq kT\ln 2>0$. The reset map is also non-injective. Therefore, even under a deterministic–nondeterministic collapse, an erasing demon can be computationally efficient while remaining logically irreversible and subject to strictly positive mean work. In particular, the collapse assumption alone cannot produce a zero-work Maxwell demon or a violation of the second law in this finite model. Algorithms and numerical examples illustrate reduction transfer, exact finite-ensemble checks of the Jarzynski condition, and the scaling of the one-bit work bound.

## 1. Introduction

The relationship between computational complexity and physical law invites a powerful but dangerous analogy. Complexity theory separates problems according to the growth of computational resources with input size. Thermodynamics limits the transformation of energy and the disposal of information. Both disciplines constrain what can be done, but they constrain different quantities.

The temptation to conflate them is especially strong in discussions of Maxwell’s demon. A demon observes microscopic degrees of freedom, makes decisions, and uses those decisions to extract useful work from thermal motion. If the difficult decision task controlling the demon were suddenly easy—perhaps because deterministic and nondeterministic polynomial time coincided—one might conclude that the demon could violate the second law efficiently. This conclusion omits the cost of operating a repeatable information-processing cycle. In particular, a memory that records observations must eventually be restored, and a many-to-one reset discards information irrespective of the runtime needed to choose the reset.

This paper isolates the valid logical implications. On the complexity side, we represent an extended Church–Turing thesis as a class inclusion: every decision problem realizable by a polynomially bounded physical process is decidable by a polynomial-time deterministic machine. If an $\mathsf{NP}$-hard demon problem is physically realizable within that bound, closure under reductions transfers efficient decidability to all of $\mathsf{NP}$. Together with the usual inclusion $\mathsf{P}\subseteq\mathsf{NP}$, this gives equality. In the reverse direction, $\mathsf{P}=\mathsf{NP}$ immediately makes every $\mathsf{NP}$ demon problem polynomial-time decidable.

On the thermodynamic side, we consider finite trajectory ensembles. A normalized probability mass function $p$ assigns probabilities to trajectories, and a work random variable $W$ assigns their work values. For one-bit erasure at positive temperature, the Jarzynski equality with free-energy difference $\Delta F=kT\ln 2$ implies the mean-work inequality $\mathbb{E}[W]\geq\Delta F$. Since $k>0$, $T>0$, and $\ln 2>0$, the expectation is strictly positive. The reset operation is non-injective because it merges the logical inputs $0$ and $1$.

The main result combines these independent implications without identifying their currencies. Under a class collapse, an $\mathsf{NP}$ demon decision problem is efficient. If its implementation performs the specified erasure, the implementation remains logically irreversible and has positive expected work. Hence “efficient decision” does not imply “free erasure.”

This conclusion is guarded in several ways. The extended Church–Turing thesis is an assumption, not a derived physical law. The complexity collapse is also a hypothesis. The thermodynamic statement assumes a finite normalized ensemble, positive temperature, and the Jarzynski condition. Moreover, the theorem applies only to an implementation that actually carries out the stated erasure; it does not assert that every decision procedure erases a bit. These boundaries are essential to the interpretation.

## 2. Complexity framework

### 2.1 Decision problems and reductions

Fix an input space $X$. A decision problem is a subset $A\subseteq X$: an input is accepted precisely when it belongs to $A$. We work abstractly with three collections of such subsets.

**Definition 2.1 (Physical-complexity model).** A physical-complexity model on $X$ is a triple

$$
(\mathcal{F},\mathcal{P},\mathcal{N}),
$$

where $\mathcal{F}$ is the class of physically realizable polynomial-resource decision processes, $\mathcal{P}$ is the deterministic polynomial-time machine class, and $\mathcal{N}$ is the corresponding nondeterministic polynomial class. The following conditions are imposed:

1. **Extended Church–Turing inclusion:** $\mathcal{F}\subseteq\mathcal{P}$.
2. **Deterministic simulation:** $\mathcal{P}\subseteq\mathcal{N}$.
3. **Reduction closure:** if $A$ polynomial-time many-one reduces to $B$ and $B\in\mathcal{P}$, then $A\in\mathcal{P}$.

A polynomial-time many-one reduction from $A$ to $B$ is an efficiently computable map $r$ satisfying

$$
x\in A\quad\Longleftrightarrow\quad r(x)\in B.
$$

The abstract closure condition is the only property of reductions used below.

**Definition 2.2 (Collapse hypothesis).** The nondeterministic class collapses to the deterministic class when

$$
\mathcal{N}\subseteq\mathcal{P}.
$$

Because $\mathcal{P}\subseteq\mathcal{N}$ is already part of the model, this condition is equivalent to $\mathcal{P}=\mathcal{N}$.

**Definition 2.3 (Hard demon problem).** A demon decision problem $D\subseteq X$ is $\mathcal{N}$-hard if every $A\in\mathcal{N}$ admits a polynomial-time many-one reduction to $D$.

Calling $D$ a demon problem adds physical motivation but no additional mathematical assumption. It may encode a control decision, a search-derived yes/no question, or a microscopic sorting criterion.

### 2.2 Complexity transfer

**Theorem 2.4 (Physical hardness forces collapse).** Let $(\mathcal{F},\mathcal{P},\mathcal{N})$ be a physical-complexity model. If $D$ is $\mathcal{N}$-hard and $D\in\mathcal{F}$, then

$$
\mathcal{N}\subseteq\mathcal{P}.
$$

Consequently, $\mathcal{P}=\mathcal{N}$.

**Proof sketch.** By the extended Church–Turing inclusion, $D\in\mathcal{F}$ implies $D\in\mathcal{P}$. Let $A\in\mathcal{N}$. Hardness supplies a polynomial-time reduction from $A$ to $D$. Reduction closure of $\mathcal{P}$ then yields $A\in\mathcal{P}$. Since $A$ was arbitrary, $\mathcal{N}\subseteq\mathcal{P}$. Combining this with $\mathcal{P}\subseteq\mathcal{N}$ gives equality. $\square$

The theorem identifies the exact assumptions behind a common physical-complexity claim. A physical device solving an $\mathcal{N}$-hard task is not enough by itself: the device must satisfy the chosen polynomial physical bound, and that bound must lie within deterministic polynomial simulation. Under those conditions, the conclusion follows from completeness transfer.

**Theorem 2.5 (Collapse makes nondeterministic demon decisions efficient).** If $\mathcal{N}\subseteq\mathcal{P}$ and $D\in\mathcal{N}$, then $D\in\mathcal{P}$.

**Proof sketch.** This is direct application of the class inclusion to $D$. $\square$

Theorem 2.5 is intentionally modest. It establishes efficient decidability, not a particular circuit layout, reversible implementation, energy budget, or memory-reset protocol.

## 3. Finite thermodynamic framework

### 3.1 Logical erasure

Let $B=\{0,1\}$ be the state space of one bit.

**Definition 3.1 (One-bit erasure).** The reset map $e:B\to B$ is defined by

$$
e(0)=0,\qquad e(1)=0.
$$

**Lemma 3.2 (Logical irreversibility of erasure).** The map $e$ is not injective.

**Proof sketch.** The distinct inputs $0$ and $1$ have the same image. $\square$

This non-injectivity is independent of implementation time. An operation may compute $e$ in constant, polynomial, or exponential time; in every case, the output alone fails to determine the input.

### 3.2 Work ensembles

Let $\Omega$ be a finite, nonempty trajectory space. Each $\omega\in\Omega$ represents a possible microscopic realization of the process.

**Definition 3.3 (Finite probability mass function).** A function $p:\Omega\to\mathbb{R}$ is a probability mass function when

$$
p(\omega)\geq 0\quad\text{for every }\omega\in\Omega,
\qquad
\sum_{\omega\in\Omega}p(\omega)=1.
$$

**Definition 3.4 (Expected work).** For a work function $W:\Omega\to\mathbb{R}$, define

$$
\mathbb{E}_p[W]=\sum_{\omega\in\Omega}p(\omega)W(\omega).
$$

Let $k>0$ denote Boltzmann’s constant and $T>0$ the absolute temperature. Set

$$
\beta=(kT)^{-1}.
$$

For reset of a uniformly unknown bit, the free-energy scale is

$$
\Delta F=kT\ln 2.
$$

**Definition 3.5 (Finite Jarzynski condition).** The pair $(p,W)$ satisfies the Jarzynski condition at inverse thermal energy $\beta$ and free-energy change $\Delta F$ if

$$
\sum_{\omega\in\Omega}p(\omega)e^{-\beta W(\omega)}
=e^{-\beta\Delta F}.
$$

The equality permits fluctuations. It does not require $W(\omega)\geq\Delta F$ trajectory by trajectory.

### 3.3 Mean-work bound

**Theorem 3.6 (Finite Jarzynski–Landauer inequality).** Let $p$ be a finite probability mass function and $W$ a real-valued work function. If $\beta>0$ and the finite Jarzynski condition holds, then

$$
\mathbb{E}_p[W]\geq\Delta F.
$$

For one-bit erasure with $k>0$ and $T>0$,

$$
\mathbb{E}_p[W]\geq kT\ln 2>0.
$$

**Proof sketch.** The function $x\mapsto e^x$ is convex. Jensen’s inequality applied to the values $-\beta W(\omega)$ gives

$$
e^{-\beta\mathbb{E}_p[W]}
\leq
\sum_{\omega\in\Omega}p(\omega)e^{-\beta W(\omega)}.
$$

The Jarzynski condition identifies the right side with $e^{-\beta\Delta F}$. Taking logarithms yields

$$
-\beta\mathbb{E}_p[W]\leq -\beta\Delta F.
$$

Division by the negative quantity $-\beta$ reverses the inequality, giving $\mathbb{E}_p[W]\geq\Delta F$. For one bit, $k>0$, $T>0$, and $\ln 2>0$, so $kT\ln 2>0$. $\square$

Equality is possible in the idealized bound. For example, if every trajectory has constant work $W(\omega)=\Delta F$, then the Jarzynski condition holds exactly and $\mathbb{E}_p[W]=\Delta F$. The theorem requires strict positivity of the mean, not strict excess above the Landauer scale.

## 4. Main separation results

We now combine the class-theoretic and thermodynamic conclusions. Their conjunction is meaningful because a demon can have both a decision problem and a physical memory protocol. The proof does not derive one resource measure from the other.

**Theorem 4.1 (Complexity–thermodynamics separation).** Let $(\mathcal{F},\mathcal{P},\mathcal{N})$ be a physical-complexity model, and let $D\in\mathcal{N}$ be a demon decision problem. Assume the collapse $\mathcal{N}\subseteq\mathcal{P}$. Suppose an implementation resets a uniformly unknown bit and is described by a finite trajectory space $\Omega$, a probability mass function $p$, and work values $W$. If $k>0$, $T>0$, and

$$
\sum_{\omega\in\Omega}p(\omega)
\exp\!\left(-\frac{W(\omega)}{kT}\right)
=
\exp\!\left(-\frac{kT\ln 2}{kT}\right),
$$

then all three of the following statements hold:

1. $D\in\mathcal{P}$;
2. the reset map is not injective;
3. $\mathbb{E}_p[W]>0$.

**Proof sketch.** Statement 1 follows from Theorem 2.5. Statement 2 follows from Lemma 3.2. The displayed condition is the Jarzynski condition with $\beta=(kT)^{-1}$ and $\Delta F=kT\ln 2$, so Theorem 3.6 gives

$$
\mathbb{E}_p[W]\geq kT\ln 2>0.
$$

Thus statement 3 holds. $\square$

**Corollary 4.2 (No zero-work demon from class collapse).** Under the assumptions of Theorem 4.1, the conjunction

$$
D\in\mathcal{P}
\quad\text{and}\quad
\mathbb{E}_p[W]=0
$$

is impossible.

**Proof sketch.** Theorem 4.1 gives $\mathbb{E}_p[W]>0$, contradicting $\mathbb{E}_p[W]=0$. $\square$

**Corollary 4.3 (Physical hard demon yields equality but not free erasure).** Suppose $D$ is $\mathcal{N}$-hard and $D\in\mathcal{F}$. Then $\mathcal{P}=\mathcal{N}$. If an implementation of the resulting efficient demon additionally performs the one-bit erasure of Theorem 4.1, its expected erasure work remains at least $kT\ln 2>0$.

**Proof sketch.** The class equality follows from Theorem 2.4. The positive work bound follows independently from Theorem 3.6. $\square$

These results refute the conditional implication

$$
\mathcal{P}=\mathcal{N}
\quad\Longrightarrow\quad
\text{zero thermodynamic cost of erasure}.
$$

They do not refute the premise, nor do they derive its negation from thermodynamics. Instead, they show that the proposed route from the premise to a second-law violation is invalid in the stated finite model.

## 5. Algorithms and numerical demonstrations

The theorems are structural, but their ingredients admit transparent computational demonstrations.

### 5.1 Reduction-transfer audit

A reduction-transfer audit represents a finite collection of problems as vertices of a directed graph. An edge $A\to B$ means that $A$ reduces to $B$. Starting from known members of $\mathcal{P}$, reverse reachability marks every problem that reduces along a path to a known easy problem.

**Algorithm 5.1 (Finite reduction-closure propagation).** Given a finite directed reduction graph and a set $E$ of known polynomial-time problems, repeatedly add $A$ whenever there is an edge $A\to B$ with $B$ already marked.

The procedure terminates after at most the number of vertices many additions. With adjacency lists organized in reverse, its runtime is $O(V+E)$ and its memory use is $O(V+E)$, where $V$ and $E$ are the numbers of vertices and edges. This finite graph procedure illustrates the proof of Theorem 2.4; it is not an algorithm for deciding membership in semantic complexity classes.

### 5.2 Jarzynski audit

**Algorithm 5.2 (Finite Jarzynski ensemble audit).** Given arrays $(p_i)$ and $(W_i)$, first check $p_i\geq0$ and $\sum_i p_i=1$. Compute

$$
J=\sum_i p_i e^{-W_i/(kT)},
\qquad
J_*=e^{-\Delta F/(kT)},
\qquad
\overline{W}=\sum_i p_iW_i.
$$

The ensemble satisfies the equality within numerical tolerance when $J\approx J_*$. The Landauer audit then checks $\overline{W}\geq\Delta F$ within tolerance. The running time is $O(n)$ and auxiliary space is $O(1)$ beyond the input arrays.

A stable example uses constant work $W_i=\Delta F$ for every trajectory. Then $J=e^{-\Delta F/(kT)}$ exactly in symbolic arithmetic and $\overline{W}=\Delta F$. A nonconstant two-trajectory example can be constructed in dimensionless units $kT=1$. Choose probability $1/2$, lower work $W_1=0.2$, and target $\Delta F=\ln2$. Solve

$$
\frac12e^{-W_1}+rac12e^{-W_2}=e^{-\Delta F}=rac12
$$

for $W_2$, obtaining

$$
W_2=-\ln\!\left(1-e^{-0.2}\right)\approx1.70777.
$$

The mean is approximately $0.95388$, which exceeds $\ln2\approx0.69315$. One trajectory falls below the Landauer scale, yet the ensemble mean obeys the bound. This demonstrates why fluctuation-level statements and expectation-level statements must not be conflated.

### 5.3 Temperature and bit-count scaling

For $N$ independently erased uniformly unknown bits, additivity gives the benchmark

$$
W_{\min}(N,T)=NkT\ln2.
$$

Evaluating this formula over a grid of $N$ and $T$ takes $O(mn)$ time for $m$ temperatures and $n$ bit counts, or $O(1)$ time for a single pair. At $T=300\,\mathrm{K}$ with $k=1.380649\times10^{-23}\,\mathrm{J/K}$,

$$
kT\ln2\approx2.87098\times10^{-21}\,\mathrm{J}.
$$

The bound scales linearly in both $N$ and $T$. This formula is a lower-bound scale under the model, not a claim that contemporary hardware attains it.

## 6. Applications and interpretation

### 6.1 Maxwellian feedback control

A repeatable demon cycle has at least three conceptually distinct stages: measurement, conditional control, and memory restoration. Complexity theory may constrain the conditional decision. Reversible design may reduce dissipation in measurement and evaluation by retaining correlations and computational history. If restoration maps multiple memory states to a common blank state, however, it performs logical erasure. Theorem 4.1 applies to that erasure whenever the finite Jarzynski assumptions hold.

The theorem therefore shifts the question. Instead of asking whether an efficient demon violates thermodynamics, one must specify the complete information flow: which records are retained, which outputs remain correlated with the environment, and which states are merged during cleanup.

### 6.2 Machine learning

In machine learning, evaluating a trained model, finding a model, and deleting training state are distinct tasks. A hypothetical complexity collapse could change the asymptotic accessibility of optimization or verification problems. It would not by itself specify a thermodynamically reversible data pipeline. Checkpoints, activations, random seeds, and intermediate search histories can be uncomputed, retained, exported, or erased; those choices govern information loss.

This distinction is especially relevant to accelerators that reuse bounded workspace. A polynomial-time inference procedure can still overwrite memory. Conversely, a reversible simulation can preserve history at a cost in space and later uncompute it. Runtime class alone does not decide the thermodynamic outcome.

### 6.3 Cryptographic and secure computation

Security devices routinely clear keys and transient state. Efficient computation of a cryptographic function is not equivalent to free destruction of its secret inputs. The reset map remains many-to-one even when the preceding function evaluation is easy. Physical attacks and practical energy costs lie beyond the finite abstraction here, but the conceptual separation survives: algorithmic tractability concerns evaluation, while Landauer cost concerns discarded distinctions.

### 6.4 Reversible computing

Reversible computation clarifies rather than contradicts the result. An injective logical evolution can retain enough information to reconstruct its input. Standard irreversible computations may be embedded in reversible ones by carrying ancillary history. After copying out the desired result, one can run the computation backward to clean temporary state. This can avoid erasing the entire history, but any final reset of an unknown output or residual record still requires separate accounting.

Thus a collapse may make reversible evaluation easier by reducing the runtime of the underlying decision. It does not automatically provide zero-work cyclic cleanup. Evaluation and reset are different maps.

## 7. Scope, limitations, and failure modes

First, the extended Church–Turing inclusion $\mathcal{F}\subseteq\mathcal{P}$ is explicit. Models involving analog precision, unbounded advice, exotic spacetime, quantum resources under a differently chosen reference class, or oracle-like primitives may not satisfy this inclusion as stated. The collapse theorem is conditional on the model.

Second, the hard-problem theorem uses polynomial many-one reductions and closure under those reductions. A different reduction notion requires a corresponding closure property. Hardness without transfer closure is insufficient.

Third, efficient decidability does not guarantee an efficient search witness unless an appropriate self-reduction or search-to-decision theorem is supplied. The present claims concern decision problems. They should not be silently upgraded to arbitrary search or optimization procedures.

Fourth, the thermodynamic theorem is finite and expectation-based. It assumes a normalized finite ensemble and a Jarzynski equality. Rare trajectories can lie below $kT\ln2$; the conclusion concerns $\mathbb{E}[W]$. Tail bounds require additional independence or fluctuation assumptions.

Fifth, positive temperature is essential. The expression $(kT)^{-1}$ is undefined at $T=0$, and the strict positivity argument fails if $k$ or $T$ is nonpositive. Approaching zero temperature raises separate questions about preparation time, control precision, and quantum ground states.

Sixth, the result does not assert that every computation contains a one-bit erasure. A logically reversible implementation may avoid the specified map during evaluation. The theorem applies when the implementation actually resets a uniformly unknown bit and obeys the stated dynamics.

Finally, the Landauer scale is not a complete engineering energy model. Real devices dissipate through friction, leakage, error correction, control, communication, and finite-speed operation. The lower bound isolates one contribution due to information loss.

## 8. Discussion

The central conceptual result is a type separation between two forms of resource accounting. A polynomial bound is asymptotic: it classifies how time or another computational resource grows with an input parameter. The Landauer quantity is informational and thermodynamic: it measures a free-energy cost associated with merging logical alternatives under specified physical conditions. Neither quantity is a monotone function of the other without additional hypotheses.

Both halves of the argument nevertheless share a structural pattern. On the complexity side, reductions transfer membership from a hard target back to all source problems. On the thermodynamic side, convexity transfers an exponential-work equality to a lower bound on ordinary expected work. Each transfer is valid in its own category. The error occurs only when one treats efficient reduction transfer as if it erased an entropy term.

The result also clarifies the phrase “the second law would be violated if $\mathsf{P}=\mathsf{NP}$.” As a bare statement, it is unsupported. A collapse can make an $\mathsf{NP}$ decision efficient. To infer a thermodynamic violation, one would additionally need an implementation whose complete cyclic operation extracts net work without compensating entropy production. Under the finite one-bit Jarzynski assumptions, zero-work erasure is specifically excluded. The collapse supplies no route around that inequality.

A stronger research program should therefore focus on mechanisms rather than slogans. Which parts of a demon’s computation can be implemented reversibly? How much history must be retained? What is the time–space overhead of uncomputation? Which correlations count as exported entropy? How do finite-error and fluctuation constraints scale over repeated cycles? These questions can connect complexity to thermodynamics without identifying them.

## 9. Future work

A first direction is a quantitative complexity–dissipation tradeoff. For finite bounded-error processes that reuse workspace, one may seek a lower bound proportional to the conditional entropy of discarded history, together with reversible constructions attaining the bound up to polylogarithmic overhead.

A second direction is the reversible simulation boundary for nondeterministic search. Even if decision collapses, successful search computations may admit reversible polynomial-overhead evaluation while still paying for output or history reset. Distinguishing reversible evaluation from irreversible cleanup is central.

A third direction extends the physical simulation model to levels of the polynomial hierarchy. Closure under composition, complementation, and bounded oracle access may turn one efficiently realizable complete process into a hierarchy-collapse criterion.

A fourth direction replaces an expectation-only result with a fluctuation-robust statement. Under a Crooks-type relation and repeated independent erasures, one may seek an exponential bound on the probability that total work falls below the aggregate Landauer threshold.

A fifth direction concerns the zero-temperature boundary. Since the present inverse-temperature model requires $T>0$, a separate framework is needed to analyze cooling costs, ground-state preparation, degeneracy, and finite-time control as $T\to0^+$.

## 10. Conclusion

A polynomially realizable physical solver for a nondeterministic-polynomial-hard problem forces deterministic and nondeterministic polynomial decision classes to coincide, provided the extended Church–Turing inclusion and reduction closure hold. A class collapse, in turn, makes every nondeterministic-polynomial demon decision problem efficient.

These are complexity conclusions. For an implementation that erases a uniformly unknown bit in a finite positive-temperature Jarzynski model, a separate theorem gives logical non-injectivity and the strict mean-work bound

$$
\mathbb{E}[W]\geq kT\ln2>0.
$$

Consequently, efficient decision and zero-cost erasure cannot be identified. Even under a class collapse, the specified erasing demon cannot have zero mean erasure work. Complexity may govern which decisions are reachable quickly; thermodynamics continues to charge for information that is actually discarded.