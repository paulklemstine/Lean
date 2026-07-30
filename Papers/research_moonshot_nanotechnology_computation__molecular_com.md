# Molecular Computation Under Explicit Resource Accounting: Universality, Description Volume, and Preparation-Limited Parallelism

## Abstract

Chemical reaction networks provide a minimal language in which molecular populations represent data and reactions represent state transitions. This paper develops a self-contained mathematical account of three foundational questions: computational universality, physical description capacity, and the end-to-end value of molecular parallelism. First, any deterministic transition system is compiled into a unary reaction network whose one-hot population follows every finite execution trace exactly. Under discrete stochastic mass-action kinetics, the transition enabled at a one-hot source has propensity equal to its assigned rate, and positive rate therefore implies positive propensity. Decoded outputs and fixed halting states are preserved. Second, for a medium with positive integer capacity $b$ bits per volume unit, the exact minimum integer volume for a $K$-bit description is $\lceil K/b\rceil$; feasibility is equivalent to being at least this minimum. This gives a precise conditional form of description-volume proportionality and implies that a reliable $N$-bit register has $2^N$ Boolean states. Third, a preparation-aware cost model distinguishes parallel testing from candidate construction. If each of $N$ candidates costs $c\ge1$ units to prepare, sequential elapsed time is $(c+1)N$ and ideal molecular elapsed time is $cN+1$. The sequential time is at most twice the molecular time, even when $N=2^n$ for Boolean exhaustive search. The results separate mathematical consequences of explicit models from empirical claims about DNA density and reaction throughput.

## 1. Introduction

Molecular computation replaces electronic gates with transformations among molecular species. Its appeal rests on three observations. Molecules are small, so a physical volume may contain an enormous number of distinguishable components. Chemical reactions are intrinsically concurrent, so many local transformations can proceed at once. Finally, reaction rules can be designed to represent symbolic processes, suggesting that chemistry can implement general computation rather than only numerical simulation.

These observations motivate several different claims that should not be conflated. A **logical universality claim** asks whether a reaction formalism can reproduce arbitrary computation. A **capacity claim** asks how much reliable information fits in a given volume. A **throughput claim** asks how many correct transitions occur per unit time. A **complexity claim** asks whether parallel chemistry changes the end-to-end asymptotic cost of solving a problem. The first and fourth can be studied within mathematical models. The second and third require empirical premises before mathematics can draw numerical conclusions.

We adopt deliberately transparent models. Computation is represented by discrete molecular populations and integer-stoichiometric reactions. Deterministic state transitions are compiled into unary reactions using one species per configuration. Kinetic availability is described by stochastic mass-action propensity using falling factorials. Storage capacity is represented by a fixed number of reliable bits per integer volume unit. Exhaustive search is charged both for preparing candidate witnesses and for testing them.

Within these models, four conclusions follow. First, reaction networks exactly simulate every finite trace of an arbitrary deterministic machine, including a Turing machine represented by its instantaneous configurations. Second, unary compiled transitions agree cleanly with mass-action kinetics at their source states. Third, minimum description volume is exactly ceiling division by bit density. Fourth, perfect parallel testing does not create an exponential end-to-end speedup when every candidate must be separately prepared at positive cost.

The finite-trace qualification is important. A mathematical compilation may associate a species with every configuration, potentially yielding an infinite species family. The simulation theorem concerns exact traces in the reaction formalism; it does not assert that an unlimited family can be synthesized in a laboratory. Likewise, numerical DNA claims are treated conditionally. If a device reliably stores $10^{18}$ bits, then it has $2^{10^{18}}$ Boolean states. If it performs $10^{15}$ correct operations in one second, its throughput is $10^{15}$ operations per second. Establishing those antecedents belongs to experimental science.

## 2. Reaction-Network Model

### 2.1 Species, populations, and reactions

Let $I$ be a finite or discrete set of molecular species. A **population** is a function

$$
x:I\to\mathbb{N},
$$

where $x(i)$ is the number of molecules of species $i$. A **reaction** $R$ is a pair of functions

$$
r_R,p_R:I\to\mathbb{N},
$$

with finite support, called its reactant and product stoichiometries. The reaction is written formally as

$$
\sum_{i\in I}r_R(i)S_i\longrightarrow\sum_{i\in I}p_R(i)S_i.
$$

The reaction is **enabled** at population $x$ if

$$
r_R(i)\le x(i)
$$

for every $i\in I$. When enabled, it produces the updated population

$$
x'(i)=x(i)-r_R(i)+p_R(i).
$$

All subtraction here is safe because enabledness guarantees enough reactants.

For $q\in I$, define the **one-hot population** $e_q$ by

$$
e_q(i)=
\begin{cases}
1,&i=q,\\
0,&i\ne q.
\end{cases}
$$

One-hot encoding uses the identity of a single molecule, rather than a concentration, to represent a discrete state.

### 2.2 Deterministic transition compilation

Let $Q$ be a set of configurations and let

$$
T:Q\to Q
$$

be a deterministic transition function. Associate one species $S_q$ with each configuration $q\in Q$. For every $q$, introduce the unary reaction

$$
R_q:S_q\longrightarrow S_{T(q)}.
$$

The **compiled run** from initial configuration $q_0$ is the population sequence $X_0,X_1,\ldots$ defined by

$$
X_0=e_{q_0},
$$

and by firing $R_q$ whenever $X_t=e_q$. Because exactly one molecule is present, this produces a deterministic reaction trace.

This construction is intentionally extensional: it compiles the full next-state function. For a finite transition system it is a finite network. For an infinite configuration set it is a mathematical reaction schema. A physically economical compiler may instead encode a configuration into several species and use finite control; that is a separate engineering problem.

## 3. Exact Finite-Trace Universality

### 3.1 Trace simulation

Write $T^t$ for the $t$-fold iterate of $T$, with $T^0$ the identity.

**Theorem 1 (Exact Finite-Trace Simulation).** Let $Q$ be any deterministic configuration space, let $T:Q\to Q$, let $q_0\in Q$, and let $t\in\mathbb{N}$. The compiled unary reaction network satisfies

$$
X_t=e_{T^t(q_0)}.
$$

**Proof sketch.** Use induction on $t$. At $t=0$, the statement is $X_0=e_{q_0}$, which is the initialization rule. Suppose $X_t=e_{T^t(q_0)}$. The compiled reaction associated with $T^t(q_0)$ consumes the unique molecule of that species and produces one molecule of species $T(T^t(q_0))=T^{t+1}(q_0)$. Hence $X_{t+1}=e_{T^{t+1}(q_0)}$. This proves the statement for every finite $t$. $\square$

A deterministic Turing machine fits the theorem by taking $Q$ to be its set of instantaneous descriptions. Such a description contains the control state, tape contents, and head position. Its transition rule is a deterministic function after adopting the usual convention that a halting configuration maps to itself. Therefore every finite Turing-machine execution trace has an exact unary CRN trace.

The theorem supplies a precise universality notion: the reaction formalism can simulate the transition semantics of an arbitrary deterministic machine. It is stronger than merely computing the same final Boolean function, because it preserves every intermediate configuration. It is also carefully limited: it does not claim a finite-species laboratory realization for an infinite set $Q$.

### 3.2 Preservation of observations

Often the complete configuration is not itself the output. Let $Y$ be an output space and let

$$
D:Q\to Y
$$

be any decoding function.

**Corollary 2 (Decoded-Output Preservation).** Under the assumptions of Theorem 1, decoding the unique configuration represented at reaction time $t$ yields

$$
D(T^t(q_0)).
$$

Equivalently, there exists a represented state $q=T^t(q_0)$ such that $X_t=e_q$ and $D(q)=D(T^t(q_0))$.

**Proof sketch.** Theorem 1 identifies the represented state exactly as $T^t(q_0)$. Applying $D$ to this equality gives the result. $\square$

This applies to output tapes, accept/reject predicates, numerical result registers, or any other deterministic observation of a machine configuration.

### 3.3 Fixed halting states

A configuration $h$ is a **fixed halting state** if

$$
T(h)=h.
$$

**Corollary 3 (Halting Preservation).** If $h$ is a fixed halting state, then a compiled reaction run initialized at $e_h$ satisfies

$$
X_t=e_h
$$

for every $t\in\mathbb{N}$.

**Proof sketch.** By induction, $T^t(h)=h$ for all $t$. Apply Theorem 1. $\square$

The compiled dynamics therefore do not invent post-halting behavior. Once the deterministic machine remains fixed, its molecular encoding remains fixed as a represented state as well.

## 4. Discrete Mass-Action Kinetics

Logical enabledness says that a reaction may fire; kinetics quantifies its tendency to fire. For natural numbers $n$ and $m$, define the descending factorial

$$
(n)_m=
\begin{cases}
1,&m=0,\\
n(n-1)\cdots(n-m+1),&m>0.
\end{cases}
$$

For a reaction $R$ with nonnegative integer rate $k$, define its discrete stochastic mass-action propensity at population $x$ by

$$
a_R(x)=k\prod_{i\in I}(x(i))_{r_R(i)}.
$$

Only species with nonzero reactant stoichiometry affect the product. This expression counts ordered reactant tuples, multiplied by the kinetic rate parameter.

**Theorem 4 (Exact Source Propensity).** For the compiled transition $R_q:S_q\to S_{T(q)}$ evaluated at its source population $e_q$,

$$
a_{R_q}(e_q)=k.
$$

**Proof sketch.** The reactant stoichiometry is one at $q$ and zero elsewhere. At $q$, the factor is $(1)_1=1$. At every other species, the factor is $(0)_0=1$. Their product is $1$, leaving $a_{R_q}(e_q)=k$. $\square$

**Corollary 5 (Enabledness and Positive Propensity).** If $k>0$, then $R_q$ is enabled at $e_q$ and has strictly positive propensity there.

**Proof sketch.** The source contains exactly the one required molecule, so the reaction is enabled. Theorem 4 gives propensity $k>0$. $\square$

These results link transition compilation with the local mass-action rule. They do not establish global timing guarantees in the presence of competing reactions, degradation, diffusion, or measurement error. Such effects would require an expanded stochastic model.

## 5. Description Capacity and Minimum Volume

### 5.1 Capacity model

Let $b\in\mathbb{N}$ denote reliable bits per integer volume unit, let $K\in\mathbb{N}$ be a description length, and let $V\in\mathbb{N}$ be volume. Define the feasibility relation

$$
\operatorname{Fits}(b,V,K)\quad\Longleftrightarrow\quad K\le bV.
$$

Assume $b>0$. Define minimum volume by ceiling division:

$$
V_{\min}(b,K)=\left\lceil\frac{K}{b}\right\rceil.
$$

For integers, this may be computed without floating point as

$$
V_{\min}(b,K)=\left\lfloor\frac{K+b-1}{b}\right\rfloor.
$$

### 5.2 Exact characterization

**Theorem 6 (Minimum Volume Fits).** If $b>0$, then

$$
K\le bV_{\min}(b,K).
$$

**Proof sketch.** By the defining property of the ceiling, $K/b\le\lceil K/b\rceil$. Multiplication by positive $b$ preserves the inequality. $\square$

**Theorem 7 (Feasibility–Minimality Equivalence).** If $b>0$, then for every $V$,

$$
V_{\min}(b,K)\le V
\quad\Longleftrightarrow\quad
K\le bV.
$$

**Proof sketch.** If $V_{\min}(b,K)\le V$, Theorem 6 and monotonicity give $K\le bV$. Conversely, if $K\le bV$, then $K/b\le V$; because $V$ is an integer, the least integer no smaller than $K/b$ is at most $V$. $\square$

**Corollary 8 (Strict Minimality).** If $V<V_{\min}(b,K)$, then the $K$-bit description does not fit in volume $V$.

**Proof sketch.** Otherwise Theorem 7 would imply $V_{\min}(b,K)\le V$, contradicting the strict inequality. $\square$

**Corollary 9 (Unit-Density Proportionality).** At one bit per volume unit,

$$
V_{\min}(1,K)=K.
$$

**Proof sketch.** Ceiling division by one is the identity. $\square$

This is an exact proportionality theorem under an explicit capacity convention. If $K$ is interpreted as a chosen description length of a function, implementation, or reaction network, then physical volume grows linearly with that length. A two-sided theorem in terms of Kolmogorov complexity $K(f)$ would additionally require a universal prefix-free description language and a fabrication model that translates descriptions to devices with bounded additive overhead. Without those choices, an unconditional physical equation between volume and Kolmogorov complexity would be under-specified.

### 5.3 State count

An $N$-bit register is a function from $N$ bit positions to the two-element set $\{0,1\}$. Independent choice at each position gives the following result.

**Theorem 10 (Boolean Register State Count).** A reliable $N$-bit register has exactly

$$
2^N
$$

distinct Boolean states. In particular, a reliable register advertised as containing $10^{18}$ bits has

$$
2^{10^{18}}
$$

possible Boolean states.

**Proof sketch.** There are two choices at each of $N$ labeled positions, and the multiplication principle yields a product of $N$ factors of $2$. $\square$

The adjective “reliable” matters. Correlated errors, inaccessible configurations, or ambiguous readout reduce the number of distinguishable states. The theorem states the mathematical consequence of the bit-register premise; it does not establish a physical density for DNA.

## 6. Preparation-Aware Molecular Parallelism

### 6.1 Cost definitions

Let $N$ be the number of candidate solutions and let $c$ be the preparation cost per candidate. Normalize one candidate test to one unit of time.

A sequential exhaustive method prepares and tests all candidates one by one:

$$
T_{\mathrm{seq}}(c,N)=(c+1)N.
$$

An idealized molecular method prepares all $N$ witnesses and tests them in one perfectly parallel round:

$$
T_{\mathrm{mol}}(c,N)=cN+1.
$$

This model grants the molecular method perfect testing parallelism. Its only charged bottleneck is separate candidate preparation. The model does not claim that all real preparation must literally occur serially; rather, it makes explicit the accounting assumption under which the theorem is derived.

### 6.2 Linear lower bound and constant-factor comparison

**Theorem 11 (Preparation Lower Bound).** For all $c,N\in\mathbb{N}$,

$$
cN\le T_{\mathrm{mol}}(c,N).
$$

**Proof sketch.** By definition, $T_{\mathrm{mol}}(c,N)=cN+1$. $\square$

**Theorem 12 (Preparation-Aware Constant-Factor Bound).** If $c\ge1$, then for every $N$,

$$
T_{\mathrm{seq}}(c,N)\le2T_{\mathrm{mol}}(c,N).
$$

**Proof sketch.** Since $c\ge1$, one has $c+1\le2c$. Therefore

$$
(c+1)N\le2cN\le2(cN+1).
$$

The left side is $T_{\mathrm{seq}}(c,N)$ and the final expression is $2T_{\mathrm{mol}}(c,N)$. $\square$

For $N>0$, the speedup ratio is

$$
\frac{T_{\mathrm{seq}}(c,N)}{T_{\mathrm{mol}}(c,N)}
=
\frac{(c+1)N}{cN+1}
<
\frac{c+1}{c}
\le2.
$$

As $N\to\infty$, the ratio approaches $(c+1)/c$, which is largest at $c=1$ and then approaches $2$.

### 6.3 Boolean exhaustive search

A Boolean search problem on $n$ variables has

$$
N=2^n
$$

candidate assignments. Substitution into Theorem 12 gives the central complexity statement.

**Corollary 13 (Exhaustive Boolean Search Bound).** If $c\ge1$, then

$$
T_{\mathrm{seq}}(c,2^n)
\le
2T_{\mathrm{mol}}(c,2^n)
$$

for every $n\in\mathbb{N}$.

Thus, in this preparation-charged model, ideal molecular parallel testing yields at most a constant-factor end-to-end advantage, not an exponential one. Both elapsed times remain $\Theta(c2^n)$ when $c$ is fixed and positive.

For $c=1$, the first eight cases are:

| Variables $n$ | Candidates $2^n$ | Molecular time $2^n+1$ | Sequential time $2^{n+1}$ | Speedup |
|---:|---:|---:|---:|---:|
| $0$ | $1$ | $2$ | $2$ | $1.000$ |
| $1$ | $2$ | $3$ | $4$ | $1.333$ |
| $2$ | $4$ | $5$ | $8$ | $1.600$ |
| $3$ | $8$ | $9$ | $16$ | $1.778$ |
| $4$ | $16$ | $17$ | $32$ | $1.882$ |
| $5$ | $32$ | $33$ | $64$ | $1.939$ |
| $6$ | $64$ | $65$ | $128$ | $1.969$ |
| $7$ | $128$ | $129$ | $256$ | $1.984$ |

The table shows the ratio tending toward $2$. The exponential number of tests has been compressed to one test round, but the exponential preparation term remains.

## 7. Algorithms and Numerical Evaluation

### 7.1 Deterministic trace compilation

Given a transition function $T$, initial state $q_0$, and horizon $t$, simulation requires repeated application of $T$. A direct algorithm stores only the current state and performs $t$ updates. Its running time is $O(tC_T)$, where $C_T$ is the cost of evaluating $T$, and its auxiliary space is $O(S_Q)$ for one state representation. The reaction interpretation labels each update $q\mapsto T(q)$ as the unary reaction $S_q\to S_{T(q)}$.

The inductive invariant is that after $j$ iterations the current state equals $T^j(q_0)$. This invariant is exactly the content of Theorem 1.

### 7.2 Exact minimum-volume computation

For $b>0$, compute

$$
V_{\min}=\frac{K+b-1}{b}
$$

using integer floor division. The algorithm uses a constant number of arithmetic operations. In a bit-complexity model its cost is dominated by addition and division on $O(\log K+\log b)$-bit integers. It avoids floating-point rounding and directly satisfies $K\le bV_{\min}$ and, when $V_{\min}>0$, $b(V_{\min}-1)<K$.

### 7.3 Preparation-aware comparison

Given $c$ and either a candidate count $N$ or Boolean dimension $n$, compute

$$
T_{\mathrm{mol}}=cN+1,
\qquad
T_{\mathrm{seq}}=(c+1)N.
$$

For Boolean search, first compute $N=2^n$. Arbitrary-precision integer arithmetic makes the calculation exact. The algorithm takes a constant number of arithmetic operations after exponentiation; exponentiation by squaring takes $O(\log n)$ integer multiplications when viewed as computing the power, while writing the resulting $2^n$-scale integer requires $O(n)$ bits.

## 8. Applications and Interpretation

### 8.1 Universal molecular control

The trace theorem applies to finite controllers, protocol state machines, cellular automata represented globally, and Turing-machine configurations. It provides a reference semantics for compilation: the intended chemical trace can be compared step by step with the source machine. A practical compiler would seek a more compact species representation, bounded molecular counts, bimolecular reactions, and robustness to stochastic failure.

### 8.2 Description-aware nanodevice design

The volume law gives an immediate lower bound whenever a device must carry a $K$-bit explicit specification and the medium exposes at most $b$ reliable bits per chosen volume unit. The law is independent of whether the bits are DNA bases, molecular conformations, magnetic domains, or another substrate. What changes between technologies is the defensible value of $b$ and the overhead required for addressing, error correction, and readout.

### 8.3 Molecular search and NP-complete problems

Molecular systems may evaluate many assignments concurrently, which can shorten the testing phase of satisfiability search. The preparation-aware theorem warns against counting only reaction depth while omitting witness generation. If every assignment requires a separate prepared object and preparation is charged linearly, exhaustive search remains exponential in $n$. An asymptotic improvement would require additional structure: compressed generation, shared computation between candidates, non-exhaustive algorithms, or a physical preparation process whose resource accounting differs from the present model.

### 8.4 Conditional capacity and throughput statements

Two frequently cited scales can be stated without confusing arithmetic with measurement. First, if a cubic micrometre device reliably stores $10^{18}$ independent bits, then its Boolean state count is $2^{10^{18}}$. Second, if a device completes exactly $10^{15}$ logically correct operations in one second, then it achieves $10^{15}$ operations per second. Neither antecedent follows from the abstract models developed here. A meaningful experimental protocol must specify temperature, duration, error correction, energy and material inputs, read/write conventions, and what counts as a logically correct operation.

## 9. Limitations

The universality construction uses one species per configuration. This is mathematically direct but can be physically extravagant or infinite. It establishes expressiveness, not manufacturing feasibility. The mass-action result concerns a single compiled transition at a one-hot source; it does not analyze races, leakage, side reactions, or expected completion times in larger networks.

The storage model treats capacity as an integer number of independent reliable bits per volume unit. Real media have geometry, addressing costs, redundancy, correlated noise, and thermodynamic constraints. The ceiling law remains correct once an effective capacity $b$ is justified, but the model itself does not supply that value.

The parallelism result is conditional on the chosen preparation accounting. If witnesses can be generated through a shared physical process at sublinear charged cost, a different model is needed. Conversely, bounds on fabrication throughput may strengthen the lower bound by converting required witness count into elapsed time.

Finally, no claim is made that raw reaction events are equivalent to useful logical operations. Throughput comparisons require a common operational definition and an error-corrected benchmark.

## 10. Future Work

Several directions sharpen the boundary between logical possibility and physical realization.

1. **Bimolecular finite-control compilation.** Develop finite CRNs using reactions with at most two reactants and fixed controller overhead, with quantitative stochastic guarantees for each simulated transition.
2. **Robust noisy traces.** Encode each logical state redundantly and prove exponentially decreasing majority-decoding error over finite traces when individual failures remain below one half.
3. **Two-sided description-volume laws.** Fix a universal prefix-free CRN language and a fabrication model, then relate minimum implementation volume to Kolmogorov complexity up to additive constants.
4. **Preparation-throughput lower bounds.** If every assignment needs a distinct witness and fabrication throughput is at most $R$, prove an end-to-end lower bound of $2^n/R$ for exhaustive Boolean search.
5. **Empirical DNA benchmarks.** Test storage density and sustained error-corrected transition rate simultaneously under declared environmental and protocol conditions.

## 11. Conclusion

Chemical reaction networks can reproduce arbitrary deterministic computation at the level of exact finite traces. Their compiled unary transitions are compatible with discrete mass-action kinetics: at a one-hot source, propensity equals the assigned rate. Physical descriptions obey a sharp capacity law, with minimum integer volume $\lceil K/b\rceil$ for $K$ bits at positive density $b$. Molecular parallel testing can collapse many tests into one round, but under linear per-candidate preparation cost it yields at most a factor-two end-to-end improvement over sequential exhaustive search.

Together these results offer a disciplined foundation for molecular computing. Universality is a theorem about expressiveness. Capacity and throughput figures are conditional on measurable premises. Complexity conclusions depend on complete resource accounting. Keeping these categories separate makes the genuine promise of molecular computation clearer: extraordinary density and concurrency, constrained—as every computation is—by representation, preparation, reliability, and time.
