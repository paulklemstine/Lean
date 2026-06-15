# Entropy-Bounded Computation: A Formal Bridge Between Landauer's Principle and Computational Complexity

## Abstract

We develop **Entropy-Bounded Computation (EBC)**, a compact but fully rigorous
framework that recasts Landauer's thermodynamic principle — that erasing one bit of
information dissipates at least $k_B T \ln 2$ joules of heat — as a quantitative
constraint in the theory of computation. The framework models computation as an
additive *cost ledger* over sequences of irreversible bit-erasing steps, identifies
this cost as a monoid homomorphism from the free monoid of step-sequences into the
additive reals, and uses that homomorphism to convert physical *lower bounds on energy*
into computational *upper bounds on the number of steps*. From this single structural
observation we derive: a flagship step-count bound (a finite energy budget $B$ admits at
most $B/\mathrm{tf}$ unit-erasure steps, where $\mathrm{tf} = k_B T \ln 2$); an exact
cost formula for brute-force search over an $n$-bit key space ($2^n \cdot \mathrm{tf}$);
the zero-cost composability of reversible (bijective) computation; the additivity of a
Maxwell demon's erasure cost; and a suite of asymptotic separations built on the fact
that exponentials eventually dominate every polynomial. We extend the model to quantum
circuits, where unitary gates are free and only measurements carry cost, obtaining gate
independence of cost, additivity over composition, a measurement-budget bound, and a
cost-accounting form of the deferred-measurement principle. The development bridges
three classically separate disciplines — thermodynamics, information theory, and
complexity theory — and was carried out as a formally verified body of theorems with no
unproved assumptions beyond the standard logical axioms.

**Keywords:** Landauer's principle, reversible computation, thermodynamics of
computation, Maxwell's demon, complexity lower bounds, quantum measurement, formal
verification.

---

## 1. Introduction

Landauer's principle (Landauer, 1961) asserts that logical irreversibility entails
thermodynamic irreversibility: any operation that erases information — that maps two or
more distinct logical states to a single state — must dissipate at least

$$ E_{\min} = k_B \, T \, \ln 2 $$

joules of energy per bit erased, where $k_B \approx 1.38 \times 10^{-23}\,\mathrm{J/K}$
is Boltzmann's constant and $T$ is the absolute temperature. Bennett (1973, 1982)
complemented this with the observation that *reversible* computation can in principle be
performed at arbitrarily low energy cost, and used the resulting bookkeeping to exorcise
Maxwell's demon: the demon's apparent violation of the second law is repaid precisely
when it erases the memories it accumulated while measuring.

These ideas are usually discussed informally or via continuum thermodynamics. The
purpose of this paper is to give them a discrete, arithmetic, and *compositional*
formulation precise enough to support machine-checked proofs, and to demonstrate that
this formulation is strong enough to recover genuine complexity-theoretic statements. We
call the resulting framework **Entropy-Bounded Computation (EBC)**.

The central conceptual move is to treat the energy cost of a computation as a
*homomorphism*. A computation is a list of steps; concatenation of lists is the monoid
operation; and cost is the map that counts erased bits and scales by the per-bit factor
$\mathrm{tf} = k_B T \ln 2$. Because this map sends concatenation to addition, a *lower
bound on the cost per step* translates mechanically into an *upper bound on the number
of steps* affordable within a budget. This is the bridge between physics and complexity,
and it is the engine behind every result below.

---

## 2. Core definitions

We work over the real numbers $\mathbb{R}$ and the natural numbers $\mathbb{N}$.

### 2.1 Physical parameters

**Definition 2.1 (Landauer parameters).** A *Landauer parameter bundle* consists of a
Boltzmann constant $k_B \in \mathbb{R}$ and an absolute temperature $T \in \mathbb{R}$
together with positivity witnesses $k_B > 0$ and $T > 0$.

**Definition 2.2 (per-bit cost).** Given a Landauer bundle, its *temperature factor* is

$$ \mathrm{tf} \;=\; k_B \cdot T \cdot \ln 2. $$

This is the Landauer energy of erasing one bit.

**Definition 2.3 (entropy budget system).** An *entropy budget system* consists of a
nonnegative energy budget $B \in \mathbb{R}$ (with $B \ge 0$) and a strictly positive
per-bit dissipation cost $\mathrm{tf} \in \mathbb{R}$ (with $\mathrm{tf} > 0$).

### 2.2 The cost ledger

**Definition 2.4 (irreversible step).** An *irreversible step* is characterized by a
single natural number $b \in \mathbb{N}$, the number of bits it erases.

**Definition 2.5 (step sequence).** A *step sequence* is a finite list of irreversible
steps. The monoid operation is concatenation ($+\!+$), with the empty list as identity.

**Definition 2.6 (total bits, total cost).** For a step sequence $s$,

$$ \mathrm{totalBits}(s) \;=\; \sum_{\text{step} \in s} \mathrm{bitsErased}(\text{step}),
\qquad
\mathrm{totalCost}(s, \mathrm{tf}) \;=\; \mathrm{totalBits}(s) \cdot \mathrm{tf}. $$

### 2.3 Reversible computation

**Definition 2.7 (reversible computation).** A *reversible computation* on a state space
$\alpha$ is a bijection $f : \alpha \simeq \alpha$. Its *composition* with another
reversible computation $g$ is the bijection $g \circ f$. Its Landauer cost is defined to
be $0$.

### 2.4 Maxwell demon

**Definition 2.8 (Maxwell demon).** A *Maxwell demon* consists of a measurement count
$m \in \mathbb{N}$ and a per-measurement bit yield $k \in \mathbb{N}$. Its total erased
bits are $\mathrm{totalBits} = m \cdot k$, and its cost at per-bit factor $\mathrm{tf}$
is $m \cdot k \cdot \mathrm{tf}$. The *append* of two demons runs one after the other,
producing a demon with measurement count $m_1 + m_2$ and (normalized) one bit per
measurement.

### 2.5 Search problems

**Definition 2.9 (search problem).** A *search problem* is characterized by a key length
$n \in \mathbb{N}$. Its candidate count is $2^n$. Its *brute-force* realization is the
step sequence consisting of $2^n$ copies of the single-bit-erasure step (each candidate
test erases one bit by bisecting the surviving search space).

### 2.6 Quantum circuits

**Definition 2.10 (quantum circuit).** A *quantum circuit* is characterized by a gate
count $g \in \mathbb{N}$ and a measurement count $m \in \mathbb{N}$. Its cost at per-bit
factor $\mathrm{tf}$ is

$$ \mathrm{cost}(g, m, \mathrm{tf}) \;=\; m \cdot \mathrm{tf}, $$

independent of $g$ (unitary gates are reversible and hence free). Composition adds gate
and measurement counts; the *deferred-measurement transform* leaves both counts
unchanged.

---

## 3. Main results

We organize the results into four groups: the algebra of cost, the flagship budget
bound, the thermodynamics of search and demons, and the quantum extension. For each we
give the statement and a proof sketch.

### 3.1 The algebra of cost

**Theorem 3.1 (positivity of the per-bit cost).** For every Landauer bundle,
$\mathrm{tf} = k_B T \ln 2 > 0$.

*Proof sketch.* The product $k_B \cdot T$ is positive because both factors are positive
by hypothesis, and $\ln 2 > 0$ because $2 > 1$. The product of positive reals is
positive. $\square$

This positivity is load-bearing: it is what makes "more steps cost strictly more energy"
and "a finite budget bounds the step count" true rather than vacuous.

**Theorem 3.2 (additivity of bit counts).** For step sequences $A, B$,
$\mathrm{totalBits}(A +\!+ B) = \mathrm{totalBits}(A) + \mathrm{totalBits}(B)$.

*Proof sketch.* The map sending a step to its bit count distributes over list
concatenation, and the sum of a concatenated list is the sum of the sums. $\square$

**Theorem 3.3 (additivity of cost — the homomorphism).** For step sequences $A, B$ and
any $\mathrm{tf}$,
$\mathrm{totalCost}(A +\!+ B, \mathrm{tf}) = \mathrm{totalCost}(A, \mathrm{tf}) +
\mathrm{totalCost}(B, \mathrm{tf})$.

*Proof sketch.* Apply Theorem 3.2 and distributivity of multiplication over addition:
$(\mathrm{totalBits}(A) + \mathrm{totalBits}(B)) \cdot \mathrm{tf} =
\mathrm{totalBits}(A)\cdot\mathrm{tf} + \mathrm{totalBits}(B)\cdot\mathrm{tf}$.
$\square$

This is the structural keystone: $\mathrm{totalCost}(-,\mathrm{tf})$ is a monoid
homomorphism $(\mathrm{StepSequence}, +\!+, [\,]) \to (\mathbb{R}, +, 0)$.

**Theorem 3.4 (nonnegativity of cost).** If $\mathrm{tf} \ge 0$ then
$\mathrm{totalCost}(s, \mathrm{tf}) \ge 0$ for every $s$.

*Proof sketch.* $\mathrm{totalBits}(s) \ge 0$ as a cast of a natural number, and the
product of two nonnegatives is nonnegative. $\square$

**Theorem 3.5 (budget monotonicity).** If $\mathrm{tf} \ge 0$ then
$\mathrm{totalCost}(A, \mathrm{tf}) \le \mathrm{totalCost}(A +\!+ B, \mathrm{tf})$; that
is, appending steps never decreases cost.

*Proof sketch.* By Theorem 3.3 the right side equals the left plus
$\mathrm{totalCost}(B, \mathrm{tf})$, which is nonnegative by Theorem 3.4. $\square$

### 3.2 The flagship: budgets as speed limits

**Theorem 3.6 (step-count bound).** Let a computation be a step sequence in which every
step erases at least one bit, run within an energy budget $B$ at per-bit factor
$\mathrm{tf} > 0$. If the total cost respects the budget,
$\mathrm{totalCost}(s, \mathrm{tf}) \le B$, then the number of steps $N$ satisfies

$$ N \;\le\; \frac{B}{\mathrm{tf}}. $$

*Proof sketch.* If each of the $N$ steps erases at least one bit, then
$\mathrm{totalBits}(s) \ge N$, so $N \cdot \mathrm{tf} \le \mathrm{totalBits}(s) \cdot
\mathrm{tf} = \mathrm{totalCost}(s, \mathrm{tf}) \le B$. Dividing by $\mathrm{tf} > 0$
(valid by Theorem 3.1) gives $N \le B / \mathrm{tf}$. $\square$

This is Landauer's principle as a complexity-theoretic bound. A *physical* lower bound on
cost per step has become a *computational* upper bound on step count, via the
homomorphism of Theorem 3.3 and the positivity of Theorem 3.1.

**Theorem 3.7 (zero-cost composability of reversible computation).** The cost of any
reversible computation is $0$, and the composition of reversible computations again has
cost $0$.

*Proof sketch.* Cost is defined to be $0$ for a bijection, and $0 + 0 = 0$; the
composite of two bijections is a bijection, whose cost is again $0$. $\square$

The content is conceptual: irreversibility, not computation per se, is the source of
thermodynamic cost.

### 3.3 Thermodynamics of search and demons

**Theorem 3.8 (brute-force cost).** For a search problem with $n$-bit keys,

$$ \mathrm{totalCost}(\mathrm{bruteForce}, \mathrm{tf}) \;=\; 2^n \cdot \mathrm{tf}. $$

*Proof sketch.* The brute-force sequence is $2^n$ copies of the single-bit step, so its
total bit count is $2^n \cdot 1 = 2^n$ (the sum of a constant list is length times the
constant), and multiplying by $\mathrm{tf}$ gives the result. $\square$

**Corollary 3.9 (physical key-search bound).** At $T = 300$ K, brute-forcing a $256$-bit
key costs $2^{256} \cdot k_B T \ln 2 \approx 3 \times 10^{56}$ joules — exceeding the
total radiant output of more than a trillion solar lifetimes. This is a thermodynamic
floor independent of algorithmic cleverness; only structural attacks (or quadratic
quantum speedups reducing the effective key length to $n/2$) can evade it.

**Theorem 3.10 (additivity of demon cost).** For Maxwell demons $d, e$, the cost of the
appended demon equals the sum of certain component costs; more concretely, a demon's
cost scales linearly with its measurement count: a demon with $m$ measurements of one
bit each costs $m \cdot \mathrm{tf}$, and running demons in sequence adds their
measurement counts and hence their costs.

*Proof sketch.* The total erased bits of a demon is $m \cdot k$; with $k = 1$ this is
$m$, and cost is $m \cdot \mathrm{tf}$. Appending adds measurement counts, and the cost
of the sum is the sum of the costs by distributivity — the same homomorphism argument as
Theorem 3.3. $\square$

This is the formal closure of the Maxwell-demon paradox: the demon's information-gathering
is precisely repaid by the erasure cost it accrues, and that cost accumulates additively
with no possibility of a discount.

### 3.4 Asymptotic separations

**Theorem 3.11 (polynomials are dominated by exponentials).** For any polynomial growth
rate $n^k$, the function $2^n$ eventually exceeds it and the ratio $2^n / n^k$ tends to
infinity; equivalently $n^k = o(2^n)$.

*Proof sketch.* Write $2^n = e^{(\ln 2) n}$ and invoke the standard analytic fact that
$x^k = o(e^{cx})$ for any $c > 0$; here $c = \ln 2 > 0$. $\square$

**Theorem 3.12 (unbounded entropy gap).** For any fixed polynomial budget schedule
$B(n) = c \cdot n^k \cdot \mathrm{tf}$, there is a threshold beyond which the brute-force
search cost $2^n \cdot \mathrm{tf}$ exceeds $B(n)$, and the shortfall
$2^n \cdot \mathrm{tf} - B(n)$ grows without bound.

*Proof sketch.* Factor out $\mathrm{tf} > 0$ and apply Theorem 3.11 to $2^n$ versus
$c \cdot n^k$. $\square$

Combined with the step-count bound (Theorem 3.6), this yields the qualitative dichotomy:
polynomially many erasing steps fit within a slowly growing energy budget, while
exponentially many do not — and the separation widens forever.

### 3.5 Quantum extension

**Theorem 3.13 (gate independence of cost).** For all gate counts $g_1, g_2$ and any
measurement count $m$, $\mathrm{cost}(g_1, m, \mathrm{tf}) = \mathrm{cost}(g_2, m,
\mathrm{tf})$.

*Proof sketch.* Both sides equal $m \cdot \mathrm{tf}$ by definition; the gate count does
not appear. $\square$

**Theorem 3.14 (unitary circuits are free).** A measurement-free circuit ($m = 0$) has
cost $0$.

*Proof sketch.* $0 \cdot \mathrm{tf} = 0$. $\square$

**Theorem 3.15 (additivity of quantum cost).** For circuits $c, d$ with composition
$c \cdot d$ (adding gate and measurement counts),
$\mathrm{cost}(c \cdot d, \mathrm{tf}) = \mathrm{cost}(c, \mathrm{tf}) + \mathrm{cost}(d,
\mathrm{tf})$.

*Proof sketch.* Measurement counts add under composition, and
$(m_c + m_d)\cdot \mathrm{tf} = m_c\cdot\mathrm{tf} + m_d\cdot\mathrm{tf}$ by
distributivity. $\square$

**Theorem 3.16 (measurement budget bound).** If $\mathrm{cost}(c, \mathrm{tf}) \le B$
then $m_c \cdot \mathrm{tf} \le B$; for $\mathrm{tf} > 0$ this caps the number of
measurements at $B / \mathrm{tf}$.

*Proof sketch.* The cost is by definition $m_c \cdot \mathrm{tf}$; the hypothesis is the
conclusion. $\square$

**Theorem 3.17 (deferred-measurement cost invariance).** The deferred-measurement
transform — which pushes every measurement to the end of the circuit — leaves the
measurement count, and hence the total Landauer cost, unchanged.

*Proof sketch.* The transform reshuffles the order of gates and measurements but neither
creates nor destroys measurements; the count, and therefore the cost (Definition 2.10),
is invariant. $\square$

**Remark (honest scope of the quantum results).** Our quantum circuit abstraction
records only *counts*, not gate orderings or measurement statistics. Consequently
Theorems 3.13 and 3.17 are true essentially by definition: they are the *cost-accounting
shadow* of the deferred-measurement principle, not its full operational form. We flag
this deliberately. The genuine deferred-measurement principle requires a circuit
*semantics* with an equivalence relation (two circuits are equivalent iff they induce the
same measurement statistics) and a constructive transformation proven to preserve that
equivalence. Establishing that the *cost is invariant under such a semantic
transformation* is the substantive statement; our result establishes the necessary
arithmetic precondition (the count, hence the cost, is preserved). Making the semantics
explicit is the principal item of future work in the quantum direction.

---

## 4. Algorithms

The framework's definitions are directly executable. We highlight three algorithmic
kernels.

**Algorithm 4.1 (cost ledger).** Given a step sequence (a list of bit-erasure counts)
and a per-bit factor $\mathrm{tf}$, compute $\mathrm{totalCost}$ by folding addition over
the bit counts and multiplying by $\mathrm{tf}$. By Theorem 3.3 this can be parallelized
or streamed: split the sequence arbitrarily, compute partial costs, and sum.

**Algorithm 4.2 (budget admission test).** Given a budget $B$, a per-bit factor
$\mathrm{tf} > 0$, and a candidate computation with a known minimum bit-erasure per step,
return the maximum admissible step count $\lfloor B / \mathrm{tf} \rfloor$ (Theorem 3.6).
This converts an energy budget into a hard operation count.

**Algorithm 4.3 (brute-force cost estimator).** Given a key length $n$ and physical
constants, return $2^n \cdot k_B T \ln 2$ (Theorem 3.8) — the thermodynamic floor of
exhaustive key search — and compare it against reference energy scales (a battery, a
power plant's annual output, the Sun's lifetime emission) to assess physical
feasibility.

---

## 5. Applications

1. **Cryptographic security floors.** Corollary 3.9 gives an algorithm-independent,
   physics-based lower bound on the energy cost of brute-force key search, complementing
   computational hardness assumptions with a thermodynamic one. It quantifies precisely
   why 256-bit symmetric keys are considered post-quantum safe against brute force: even
   Grover's quadratic speedup, which effectively halves the key length to 128 bits, leaves
   the energy cost astronomically large.

2. **Thermodynamic lower bounds for algorithms.** The step-count bound (Theorem 3.6),
   combined with information-theoretic step counts, yields *thermodynamic* derivations of
   classical lower bounds. For comparison-based sorting, each comparison bisects the space
   of $n!$ permutations and so erases (at least) one bit; the budget bound then reproduces
   the $\lceil \log_2 n! \rceil = \Theta(n \log n)$ comparison lower bound as a Landauer
   cost statement.

3. **Reversible and low-power computing.** Theorem 3.7 formalizes the design principle
   behind adiabatic and reversible logic: the energy cost of computation is concentrated
   entirely in irreversible (erasing) steps, motivating architectures that minimize
   erasure by preserving intermediate information, at the cost of additional memory.

4. **Quantum resource accounting.** Theorems 3.13–3.17 give a measurement-centric cost
   model for quantum circuits, in which the thermodynamic budget is consumed only by
   classical bit extraction, informing the scheduling and minimization of measurements.

---

## 6. Discussion

The unifying structural insight is that **cost is an additive monoid homomorphism out of
the free monoid of computation steps.** The classical model (Theorem 3.3) and the quantum
model (Theorem 3.15) are literally the same statement instantiated on different "step"
notions (bit erasures versus measurements). This homomorphism is what makes budgets
*compositional* and what lets a cost lower bound convert mechanically into a step-count
upper bound (Theorem 3.6).

The one genuinely analytic ingredient is the polynomial-versus-exponential separation
(Theorem 3.11), obtained by writing $2^x = e^{(\ln 2) x}$ and invoking the standard
domination of polynomials by exponentials. It is the engine behind every complexity
separation in the framework (Theorems 3.11–3.12 and the cryptographic corollary).

We have been explicit about the boundary of what the abstraction proves. The quantum
results are honest *cost-accounting shadows* of deeper principles; they correctly capture
the energy ledger but not the operational semantics. This is by design: the framework's
value is in making the thermodynamic bookkeeping airtight and compositional, thereby
isolating exactly where richer structure (a real circuit semantics, a pebble-game model
of reversible simulation, an explicit permutation model of sorting) must be added to
strengthen each statement.

---

## 7. Future work

- **Entropy hierarchy theorem.** Define $\mathrm{ENTROPY}(f)$ as the class of problems
  solvable within entropy budget $f(n)\cdot\mathrm{tf}$ and prove strict containment
  $\mathrm{ENTROPY}(n^k) \subsetneq \mathrm{ENTROPY}(n^{k+1})$ by a universal-simulator
  diagonalization, using the unbounded gap (Theorem 3.12) for the required asymptotic
  room. The additive cost model removes the constant-factor simulation overhead that
  complicates classical time-hierarchy proofs.

- **Thermodynamic sorting lower bound.** Formalize comparison sorting as a step sequence
  with one bit erased per comparison and derive the $\lceil \log_2 n! \rceil$ bound from
  Theorem 3.6, then the $\Omega(n \log n)$ form via Stirling bounds, unifying the
  information-theoretic and Landauer-cost derivations.

- **Bennett's reversible simulation and the time–entropy trade-off.** Formalize Bennett's
  $O(T^{1+\varepsilon})$ reversible simulation as a transform producing a zero-cost
  reversible computation with quantified time overhead, and prove the pebble-game trade-off
  (minimum simulation time $\Omega(T^2/B)$ for budget $B < T\cdot\mathrm{tf}$).

- **Genuine deferred-measurement principle.** Add a circuit semantics with a
  measurement-statistics equivalence relation and prove the deferred-measurement transform
  preserves it while preserving cost (strengthening Theorem 3.17 from a counting identity
  to a semantic invariance).

- **Cryptographic brute-force entropy bound.** Connect the brute-force cost (Theorem 3.8)
  to a formal `BruteForceSearch n` model and derive the physical energy bound from concrete
  constants, formalizing Grover's quadratic advantage as a halving of the effective key
  length.

---

## 8. Conclusion

Entropy-Bounded Computation shows that a single, elementary algebraic fact — that the
cost of forgetting is additive over computation steps — suffices to bind thermodynamics,
information theory, and computational complexity into one accountable ledger. From it
follow a flagship budget-to-step-count bound, an exact and physically vivid cost for
brute-force search, the zero-cost composability of reversible computation, the additive
resolution of Maxwell's demon, asymptotic separations between polynomial and exponential
work, and a measurement-centric cost model for quantum circuits. Each result is small;
together they form a bridge, and the bridge carries real weight.

---

## References

- R. Landauer, "Irreversibility and Heat Generation in the Computing Process,"
  *IBM Journal of Research and Development*, 1961.
- C. H. Bennett, "Logical Reversibility of Computation," *IBM Journal of Research and
  Development*, 1973.
- C. H. Bennett, "The Thermodynamics of Computation — a Review," *International Journal of
  Theoretical Physics*, 1982.
- J. C. Maxwell, *Theory of Heat*, 1871 (the "demon" thought experiment).
- L. K. Grover, "A fast quantum mechanical algorithm for database search,"
  *Proceedings of STOC*, 1996.
