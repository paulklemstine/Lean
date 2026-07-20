# Computational Complexity as Physical Law: Class Collapse, Hierarchy Simulation, and the Thermodynamic Cost of Erasure

**Aristotle**  
**20 July 2026**

## Abstract

We develop a conditional mathematical bridge between computational complexity and finite-temperature information thermodynamics. An abstract physical-complexity model distinguishes problems realizable with polynomially bounded physical resources, problems decidable by deterministic polynomial-time machines, and problems decidable in nondeterministic polynomial time. Under an extended Church–Turing inclusion and closure under polynomial-time many-one reductions, a physically polynomial realization of an $NP$-hard demon forces equality of the deterministic and nondeterministic polynomial classes. A parallel hierarchy theorem shows that a stable collapse at level $k$, together with physical realizability at that level, makes every higher level polynomial-time machine simulable. These computational conclusions are combined with a finite Jarzynski model of one-bit erasure. For a normalized finite trajectory ensemble at positive temperature, the Jarzynski equality with free-energy change $kT\log 2$ implies mean work at least $kT\log 2$, and hence strictly positive mean work. Consequently, neither a postulated $P=NP$ collapse nor a collapse induced by a physical $NP$-hard solver makes erasure free. The results isolate the precise boundary between asymptotic runtime and thermodynamic dissipation: reductions and class equalities transfer solvability, whereas noninjective logical operations and fluctuation relations control work.

## 1. Introduction

The proposition that computational complexity might act as a physical law has two readings. The modest reading says that physically realizable computations are constrained by familiar machine complexity classes. The stronger reading says that complexity-theoretic hardness may protect thermodynamic principles: if hard optimization suddenly became efficient, a Maxwell demon might exploit microscopic information and violate the second law.

The first reading can be expressed as an extended Church–Turing simulation principle. This formulation turns a broad physical intuition into a precise inclusion between classes of decision problems. The second requires far more care. Efficient computation is an asymptotic statement about the number of steps or another resource as input length grows. Thermodynamic work is measured in energy and depends on an implementation, an ensemble, and a physical protocol. There is no dimensional or logical route from “runs in polynomial time” to “has zero work cost.”

This paper separates these resources and then reconnects them under explicit hypotheses. The computational half uses only class inclusions, many-one hardness, closure under reductions, and stable hierarchy collapse. The thermodynamic half uses a finite probability distribution over trajectories, one-bit logical erasure, positive temperature, and the Jarzynski equality. The bridge is a conjunction rather than an identification: a hypothetical physical $NP$-hard solver can force a class collapse, while an erasing implementation of that solver still has positive mean work.

The main conclusions are:

1. A physically polynomial $NP$-hard solver forces $P_{\mathrm{TM}}=NP_{\mathrm{TM}}$ under the simulation and reduction-closure assumptions.
2. A stable collapse of a nested hierarchy at level $k$, plus physical realizability of level $k$, yields polynomial-time machine simulation of every fixed higher level.
3. Under $P_{\mathrm{TM}}=NP_{\mathrm{TM}}$, every nondeterministic-polynomial demon problem is computationally efficient, but a one-bit erasing realization satisfying finite Jarzynski dynamics at positive temperature has strictly positive mean work.
4. The same physically polynomial $NP$-hard demon simultaneously yields class equality and a no-zero-work obstruction when implemented by such an erasure protocol.

All statements are conditional. In particular, neither the extended Church–Turing principle nor $P=NP$ is asserted as an unconditional fact. The thermodynamic result applies to the specified erasing implementation, not to every decision procedure.

## 2. Computational framework

### 2.1 Decision problems and classes

Let $X$ be a set of finite inputs. A **decision problem** is a subset $A\subseteq X$; the output is “yes” exactly on inputs in $A$. A **complexity class** is a collection of decision problems, hence a subset of the power set $\mathcal P(X)$.

We use three classes:

- $P_{\mathrm{phys}}\subseteq\mathcal P(X)$: problems realized by physical processes whose relevant resources are polynomially bounded in input length;
- $P_{\mathrm{TM}}\subseteq\mathcal P(X)$: problems decidable by deterministic Turing machines in polynomial time;
- $NP_{\mathrm{TM}}\subseteq\mathcal P(X)$: problems decidable by nondeterministic Turing machines in polynomial time.

The framework assumes the **extended Church–Turing inclusion**

$$
P_{\mathrm{phys}}\subseteq P_{\mathrm{TM}},
$$

and the standard deterministic-to-nondeterministic inclusion

$$
P_{\mathrm{TM}}\subseteq NP_{\mathrm{TM}}.
$$

The first is a physical simulation thesis: it is an assumption about the relation between physical and machine computation. The second follows because a nondeterministic machine can simulate a deterministic one.

### 2.2 Reductions, hardness, and closure

For decision problems $A,B\subseteq X$, write $A\le_m^p B$ when there is a polynomial-time computable map $f$ such that

$$
x\in A\quad\Longleftrightarrow\quad f(x)\in B.
$$

A class $C$ is **closed under polynomial-time many-one reductions** if

$$
A\le_m^p B\ \text{ and }\ B\in C\quad\Longrightarrow\quad A\in C.
$$

We assume $P_{\mathrm{TM}}$ has this closure property.

A demon problem $D\subseteq X$ is **$NP$-hard** if

$$
\forall A\in NP_{\mathrm{TM}},\qquad A\le_m^p D.
$$

The word “demon” has no effect on this definition; it indicates the intended physical interpretation of a device making decisions that support feedback control.

### 2.3 The collapse predicate

We say that the nondeterministic class **collapses into deterministic polynomial time** when

$$
NP_{\mathrm{TM}}\subseteq P_{\mathrm{TM}}.
$$

Together with $P_{\mathrm{TM}}\subseteq NP_{\mathrm{TM}}$, this is equivalent to

$$
P_{\mathrm{TM}}=NP_{\mathrm{TM}}.
$$

The one-sided formulation is useful because it isolates the nontrivial direction.

## 3. Thermodynamic framework

### 3.1 Finite trajectory ensembles

Let $\Omega$ be a finite set of trajectories or microscopic outcomes. A function $p:\Omega\to\mathbb R$ is a **probability mass function** if

$$
p(\omega)\ge 0\quad\text{for every }\omega\in\Omega,
$$

and

$$
\sum_{\omega\in\Omega}p(\omega)=1.
$$

Let $W:\Omega\to\mathbb R$ assign work to each trajectory. Its expected value is

$$
\langle W\rangle=\sum_{\omega\in\Omega}p(\omega)W(\omega).
$$

Negative work values on individual trajectories are permitted. The theorem constrains the ensemble average.

### 3.2 Logical erasure

A one-bit erasure is the Boolean map $E:\{0,1\}\to\{0,1\}$ defined by

$$
E(0)=0,\qquad E(1)=0.
$$

It is not injective because $0\ne1$ but $E(0)=E(1)$. This noninjectivity is the precise sense in which the operation is logically irreversible: observing the output does not determine the input.

For a uniformly unknown bit, the entropy loss is $\log 2$ in natural units. At temperature $T$ with Boltzmann constant $k$, the corresponding free-energy scale is

$$
\Delta F=kT\log 2.
$$

We assume throughout the thermodynamic results that

$$
k>0\qquad\text{and}\qquad T>0.
$$

### 3.3 Jarzynski condition

The finite **Jarzynski condition** with inverse thermal scale $\beta=(kT)^{-1}$ and free-energy change $\Delta F$ is

$$
\sum_{\omega\in\Omega}p(\omega)e^{-\beta W(\omega)}
=e^{-\beta\Delta F}.
$$

For one-bit erasure, $\Delta F=kT\log 2$, so $\beta\Delta F=\log 2$ and the right-hand side is $1/2$.

Jensen’s inequality for the convex function $x\mapsto e^x$ gives

$$
e^{-\beta\langle W\rangle}
\le \sum_{\omega\in\Omega}p(\omega)e^{-\beta W(\omega)}
=e^{-\beta\Delta F}.
$$

Since $\beta>0$ and the exponential is strictly increasing, taking logarithms and multiplying by $-1/\beta$ reverses the relevant inequality, yielding

$$
\langle W\rangle\ge\Delta F.
$$

For one bit at positive temperature,

$$
\langle W\rangle\ge kT\log 2>0.
$$

This derivation is the thermodynamic engine of all no-zero-work conclusions below.

## 4. Computational collapse from a physical solver

### Theorem 1 (Physical $NP$-hardness collapse)

Assume $P_{\mathrm{phys}}\subseteq P_{\mathrm{TM}}$ and that $P_{\mathrm{TM}}$ is closed under polynomial-time many-one reductions. If an $NP$-hard demon problem $D$ belongs to $P_{\mathrm{phys}}$, then

$$
NP_{\mathrm{TM}}\subseteq P_{\mathrm{TM}}.
$$

#### Proof sketch

The physical simulation inclusion sends $D\in P_{\mathrm{phys}}$ to $D\in P_{\mathrm{TM}}$. Let $A$ be arbitrary in $NP_{\mathrm{TM}}$. Because $D$ is $NP$-hard, $A\le_m^p D$. Closure of $P_{\mathrm{TM}}$ under such reductions implies $A\in P_{\mathrm{TM}}$. Since $A$ was arbitrary, the desired inclusion follows. $\square$

### Corollary 2 (Class equality)

Under the assumptions of Theorem 1 and the ordinary inclusion $P_{\mathrm{TM}}\subseteq NP_{\mathrm{TM}}$,

$$
P_{\mathrm{TM}}=NP_{\mathrm{TM}}.
$$

#### Proof sketch

Theorem 1 supplies one inclusion and deterministic simulation supplies the other. Apply antisymmetry of set inclusion. $\square$

### Proposition 3 (Efficiency under collapse)

If $NP_{\mathrm{TM}}\subseteq P_{\mathrm{TM}}$ and $D\in NP_{\mathrm{TM}}$, then $D\in P_{\mathrm{TM}}$.

#### Proof sketch

This is direct application of the class inclusion to the member $D$. $\square$

Although elementary, Proposition 3 clarifies what a class collapse contributes to the demon story: it changes the classification of the decision problem. It says nothing about the energy consumed by a device realizing that problem.

## 5. Stable hierarchy collapse and physical simulation

Let $(H_j)_{j\in\mathbb N}$ be a hierarchy of decision-problem classes. The intended examples are nested levels of oracle or alternation strength, but only equalities between levels are needed here.

A collapse at level $k$ is the equality

$$
H_k=H_{k+1}.
$$

We call adjacent collapse **stable upward** if, for every $m$,

$$
H_m=H_{m+1}\quad\Longrightarrow\quad H_{m+1}=H_{m+2}.
$$

### Lemma 4 (Propagation of stable collapse)

If $H_k=H_{k+1}$ and adjacent collapse is stable upward, then

$$
H_j=H_k
$$

for every $j\ge k$.

#### Proof sketch

Induct on $j-k$. The base case $j=k$ is reflexivity. The first adjacent equality is assumed. At each subsequent step, stability turns equality of levels $m$ and $m+1$ into equality of levels $m+1$ and $m+2$. Chaining these equalities identifies every level from $k$ onward with $H_k$. $\square$

### Theorem 5 (Hierarchy-wide physical simulation above a stable collapse)

Assume:

1. $H_k=H_{k+1}$;
2. adjacent collapse is stable upward;
3. $H_k\subseteq P_{\mathrm{phys}}$;
4. $P_{\mathrm{phys}}\subseteq P_{\mathrm{TM}}$.

Then, for every $j\ge k$,

$$
H_j\subseteq P_{\mathrm{TM}}.
$$

#### Proof sketch

By Lemma 4, $H_j=H_k$. The physical realizability assumption and extended Church–Turing inclusion compose to give

$$
H_k\subseteq P_{\mathrm{phys}}\subseteq P_{\mathrm{TM}}.
$$

Replacing $H_j$ by $H_k$ proves the claim. $\square$

The theorem is deliberately extensional. It guarantees that each problem in every higher level has a polynomial-time simulation. It does not specify a uniform translation algorithm, a shared polynomial exponent, or a bound that remains fixed as the hierarchy level varies. Those quantitative data require a richer, size-indexed model.

## 6. Complexity–thermodynamics separation

### Lemma 6 (One-bit Jarzynski–Landauer bound)

Let $\Omega$ be finite, let $p$ be a probability mass function on $\Omega$, and let $W:\Omega\to\mathbb R$. Suppose $k>0$, $T>0$, and

$$
\sum_{\omega\in\Omega}p(\omega)e^{-W(\omega)/(kT)}
=e^{-(kT\log 2)/(kT)}.
$$

Then

$$
\langle W\rangle\ge kT\log 2>0.
$$

#### Proof sketch

Apply Jensen’s inequality as in Section 3.3 with $\beta=(kT)^{-1}$ and $\Delta F=kT\log 2$. Positivity of $k$ and $T$, together with $\log 2>0$, makes the lower bound strictly positive. $\square$

### Theorem 7 (Efficient erasing demons have positive mean work)

Assume $NP_{\mathrm{TM}}\subseteq P_{\mathrm{TM}}$ and let $D\in NP_{\mathrm{TM}}$. Suppose a physical realization of the demon performs the one-bit erasure $E(0)=E(1)=0$ and has a finite trajectory ensemble satisfying the hypotheses of Lemma 6. Then:

1. $D\in P_{\mathrm{TM}}$;
2. $E$ is not injective;
3. $\langle W\rangle>0$.

#### Proof sketch

The first conclusion is Proposition 3. For the second, the distinct inputs $0$ and $1$ share output $0$. The third is Lemma 6. The arguments are independent and may be conjoined because all hypotheses hold for the same proposed implementation. $\square$

### Corollary 8 (No zero-work demon from class collapse)

Under the hypotheses of Theorem 7, the conjunction

$$
D\in P_{\mathrm{TM}}\qquad\text{and}\qquad \langle W\rangle=0
$$

is impossible.

#### Proof sketch

Theorem 7 gives $\langle W\rangle>0$, contradicting $\langle W\rangle=0$. $\square$

Corollary 8 is a no-go theorem within a specified finite thermodynamic model. It does not say that $P=NP$ violates the second law. It says the opposite: even under the collapse, a one-bit erasing demon obeying the Jarzynski condition cannot have zero mean erasure work.

## 7. Integrated bridge theorem

### Theorem 9 (Physical $NP$-hard erasing demon: collapse and no-zero-work obstruction)

Assume:

1. $P_{\mathrm{phys}}\subseteq P_{\mathrm{TM}}$;
2. $P_{\mathrm{TM}}\subseteq NP_{\mathrm{TM}}$;
3. $P_{\mathrm{TM}}$ is closed under polynomial-time many-one reductions;
4. $D$ is $NP$-hard and $D\in P_{\mathrm{phys}}$;
5. an implementation of $D$ erases one bit by $E(0)=E(1)=0$;
6. the implementation has a finite normalized trajectory ensemble satisfying the Jarzynski condition with $\Delta F=kT\log 2$, where $k>0$ and $T>0$.

Then all of the following hold simultaneously:

$$
P_{\mathrm{TM}}=NP_{\mathrm{TM}},
$$

$$
D\in P_{\mathrm{TM}},
$$

$$
E\text{ is not injective},
$$

and

$$
\langle W\rangle>0.
$$

#### Proof sketch

Theorem 1 and the deterministic-to-nondeterministic inclusion yield class equality. The direct physical simulation inclusion gives $D\in P_{\mathrm{TM}}$. Noninjectivity follows from $E(0)=E(1)$ with $0\ne1$. Lemma 6 supplies strictly positive mean work. $\square$

The theorem uses the same physical solver to draw both kinds of conclusion. No separate $P=NP$ postulate is needed: class equality follows from physical $NP$-hardness. Nevertheless, the thermodynamic obstruction survives that equality.

## 8. Algorithms and numerical diagnostics

The theorems are structural, but their finite ingredients admit transparent computational demonstrations.

### 8.1 Reduction-closure propagation

Given a finite directed graph whose edge $A\to B$ means $A\le_m^p B$, and a set of problems already known to be efficient, repeatedly add every predecessor of an efficient problem. This computes the least reduction-closed efficient set represented by the graph.

If there are $V$ problem nodes and $E$ reduction edges, a reverse breadth-first search runs in time $O(V+E)$ and space $O(V+E)$. If every represented $NP$ problem reaches an efficient $NP$-hard target, all represented problems become efficient. This is a finite graph analogue of Theorem 1, not a procedure for deciding $P=NP$.

### 8.2 Stable hierarchy propagation

Represent levels by labels. Starting from equality of levels $k$ and $k+1$, apply the stability rule successively to mark every level through a chosen finite cutoff as equal to level $k$. The computation is linear in the number of inspected levels. It visualizes Lemma 4 but does not add the missing quantitative uniformity across an infinite hierarchy.

### 8.3 Jarzynski work analysis

For arrays of probabilities $(p_i)$ and works $(W_i)$, compute

$$
J=\sum_i p_i e^{-W_i/(kT)},\qquad
\langle W\rangle=\sum_i p_iW_i,
$$

and compare $J$ with

$$
e^{-\Delta F/(kT)}.
$$

For an exact Jarzynski ensemble, these quantities agree. A constant-work protocol $W_i=kT\log 2$ for all $i$ saturates the bound. A two-trajectory family can include a negative-work event while retaining positive average work, emphasizing that the theorem constrains expectation rather than every realization.

## 9. Applications and interpretation

### 9.1 Maxwell demons and feedback control

A demon combines measurement, decision, actuation, memory, and reset. Complexity classes describe the decision component only after a representation and resource measure are chosen. Thermodynamic accounting must include memory correlations and reset operations. Theorem 9 prevents a common category error: an efficient decision rule cannot by itself erase the energetic consequences of a noninjective reset.

### 9.2 Reversible computing

The results motivate reversible implementation. If intermediate steps preserve enough information to remain injective, the direct logical-erasure argument does not apply to those steps. A final many-to-one reset may still incur cost. Thus reversible simulation can separate the complexity of finding an answer from the thermodynamic cost of discarding records. Establishing precise time, space, and heat overheads requires a machine model with configurations, clocks, and entropy flow, which is beyond the extensional class framework used here.

### 9.3 Physical claims about complexity hierarchies

Theorem 5 provides a qualitative route from stable class collapse to broad physical simulation. It is relevant whenever a proposed physical model is claimed to realize all problems at one hierarchy level. If equality propagates upward, separate physical realizability assumptions for every higher level are unnecessary. However, “polynomial” may hide exponents depending on the level, so a practical simulation claim needs quantitative uniformity.

### 9.4 Experimental diagnostics

The finite Jarzynski condition is empirically meaningful. One may sample work values from repeated reset protocols, estimate the exponential average, and compare it with the predicted free-energy factor. Exponential averages are statistically delicate because rare trajectories can dominate them. The mathematical theorem presumes the exact normalized finite ensemble; finite-sample inference introduces additional uncertainty not treated here.

## 10. Scope and limitations

Several boundaries are essential.

First, the extended Church–Turing inclusion is a hypothesis, not a theorem of thermodynamics. A physical model outside that inclusion would require a different computational analysis.

Second, $P=NP$ is not asserted. It is either assumed in Theorem 7 or derived conditionally from a physically polynomial $NP$-hard solver in Theorem 9.

Third, runtime and work remain separate. Polynomial time controls growth with input length. The Landauer scale controls entropy discarded by a specified operation at a specified temperature. No theorem here converts a polynomial runtime exponent into joules.

Fourth, the thermodynamic results concern a finite normalized ensemble satisfying an exact Jarzynski equality. They require $k>0$ and $T>0$. Boundary regimes such as zero temperature, nonnormalized weights, infinite state spaces, approximate fluctuation relations, and nonequilibrium memory correlations demand separate treatment.

Fifth, the theorem does not claim every decision algorithm erases a bit. It applies when the proposed realization performs the explicit many-to-one erasure. A reversible implementation may move dissipation elsewhere or postpone it.

Finally, the hierarchy theorem is extensional rather than quantitative. It establishes inclusion in a polynomial-time class but not a uniform compiler or common overhead polynomial.

## 11. Future work

A size-indexed theory should track runtime, memory, discarded information, and dissipated work simultaneously. If a procedure irreversibly discards $b(n)$ unbiased bits on inputs of length $n$, the natural conjectured lower bound is $kTb(n)\log 2$, independent of whether runtime is polynomial. Conditional entropy should replace raw bit count when side information is retained.

A second direction is a quantitative reversible simulation theorem: polynomial-time decision procedures should admit reversible simulations with controlled time and space overhead, while final many-to-one resets pay according to the conditional information discarded. This would identify the implementation-level premise absent from class membership alone.

For hierarchies, the next step is a uniform extended Church–Turing compiler with explicit clocks. Stable collapse at level $k$ should then produce one controlled simulation overhead for each fixed higher level, with careful analysis of whether exponents can be chosen uniformly.

For Maxwell demons, fluctuation-corrected free-energy inequalities should include mutual information retained in memory. This would distinguish useful feedback extraction from reset costs hidden in correlated records and would connect computational classes to thermodynamics through physical memory rather than runtime alone.

## 12. Conclusion

Computational collapse and thermodynamic irreversibility can coexist. Under an extended Church–Turing simulation principle, a physically polynomial $NP$-hard solver collapses deterministic and nondeterministic polynomial-time classes. Under stable adjacent collapse, the same style of inclusion propagates machine simulation through all higher hierarchy levels. Yet a finite-temperature implementation that erases an unknown bit and satisfies the Jarzynski equality has mean work at least $kT\log 2>0$.

The mathematical lesson is a separation of transfer principles. Reductions transfer efficient solvability. Equality of hierarchy levels transfers simulation. Noninjective erasure, combined with a fluctuation relation, transfers information loss into a positive work bound. A more powerful demon may compute answers faster, but computational efficiency alone does not make forgetting free. Any future physical theory of complexity should therefore expose at least two resource coordinates: asymptotic computational cost and implementation-dependent entropy flow. Keeping both coordinates visible prevents either discipline from being used as an unjustified surrogate for the other.
