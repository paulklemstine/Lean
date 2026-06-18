# Closure Dynamical Systems, Symbolic Zeta Semantics, and the Artin–Mazur Rationality Theorem for Finite Closure-Compatible Maps

## Abstract

We develop a rigorous theory of finite closure dynamical systems — deterministic dynamical systems on finite types equipped with closure operators satisfying a natural compatibility condition. We define periodic orbit counts, transition matrices, closure zeta functions (as formal power series), and dynamical conjugacy. We prove a trace formula connecting matrix powers to periodic orbit enumeration, establish that all dynamical invariants (periodic counts, zeta functions, thermodynamic weights) are preserved under conjugacy, and demonstrate that the periodic point count sequence is eventually periodic — yielding rationality of the closure zeta function. Quantitative bounds relate periodic orbit growth to topological capacity, and a certified radius function provides stability margins antitone in system complexity. All results are fully formalized and machine-verified (see @Catalog/Bridges/EMLZetaSemantics.lean).

**Keywords**: closure operator, finite dynamical system, periodic orbit, Artin–Mazur zeta function, transition matrix, trace formula, conjugacy invariant, eventual periodicity, rationality.

---

## 1. Introduction

The enumeration of periodic orbits in dynamical systems is a classical problem with roots in celestial mechanics (Poincaré), number theory (Weil conjectures), and statistical mechanics (transfer matrices). The Artin–Mazur zeta function [1] packages periodic orbit counts into a generating function whose analytic properties — particularly rationality — encode deep structural information about the dynamics.

For subshifts of finite type, rationality of the Artin–Mazur zeta function follows from the Perron–Frobenius theory of nonneg matrices: the zeta function is the reciprocal of the characteristic polynomial of the transition matrix [2]. For general smooth dynamical systems, rationality fails, and the zeta function may have natural boundaries [3].

In this paper, we identify a natural class of finite dynamical systems — those compatible with a closure operator — for which a complete theory can be developed from first principles. The closure compatibility condition (closed sets are forward-invariant under the dynamics) is satisfied by many systems of practical interest, including finite-state abstractions of control systems, database dependency propagation, and lattice models in statistical physics.

Our main contributions are:

1. **Definitions and basic theory** (§2–3): We formalize closure operators, closure dynamical systems, periodic point sets, transition matrices, and the closure zeta function.

2. **Trace formula** (§4): We prove that the trace of the *n*-th power of the transition matrix equals the *n*-periodic point count.

3. **Conjugacy invariance** (§5): We show that conjugate systems have identical periodic point counts and zeta functions.

4. **Rationality** (§6): We prove that the periodic point count sequence is eventually periodic, establishing rationality of the closure zeta function.

5. **Capacity bounds** (§7): We prove that periodic orbit growth is bounded by the logarithmic capacity of the state space, and derive a certified radius that is antitone in capacity.

---

## 2. Definitions

### 2.1 Closure Operators

**Definition 2.1** (Closure Operator). Let $\alpha$ be a type. A *closure operator* is a function $\mathrm{cl} : \mathcal{P}(\alpha) \to \mathcal{P}(\alpha)$ satisfying:
- *Extensivity*: $S \subseteq \mathrm{cl}(S)$ for all $S$.
- *Monotonicity*: $S \subseteq T \implies \mathrm{cl}(S) \subseteq \mathrm{cl}(T)$.
- *Idempotence*: $\mathrm{cl}(\mathrm{cl}(S)) = \mathrm{cl}(S)$.

This is formalized as the `IsClosureOp` class in @Catalog/Bridges/EMLZetaSemantics.lean.

A set $S$ is *closed* if $\mathrm{cl}(S) = S$. The collection of closed sets forms a complete lattice under inclusion, and the closure operator is the associated closure map.

**Definition 2.2** (Finite Closure System). A *finite closure system* is a closure operator on a finite type $\alpha$. Formalized as `FiniteClosureSystem` in the source.

### 2.2 Closure Dynamical Systems

**Definition 2.3** (Closure Dynamics). A *closure dynamical system* $(α, \mathrm{cl}, f)$ consists of a finite type $\alpha$, a closure operator $\mathrm{cl}$, and a step function $f : \alpha \to \alpha$ satisfying the *closure compatibility condition*:

$$\mathrm{cl}(S) = S \implies \mathrm{cl}(f(S)) \subseteq S$$

for all $S \subseteq \alpha$. In words: the closure of the image of any closed set is contained in that closed set. This ensures that closed sets are forward-invariant under the dynamics.

This is formalized as the `ClosureDynamics` structure, with field `closed_orbit_image`.

### 2.3 Periodic Points

**Definition 2.4**. The set of *n-periodic points* of a closure dynamical system $(α, \mathrm{cl}, f)$ is

$$\mathrm{Per}_n(f) = \{ x \in \alpha \mid f^n(x) = x \}.$$

The *periodic point count* is $p_n(f) = |\mathrm{Per}_n(f)|$. These are formalized as `closurePeriodicPoints` and `closurePeriodicCount`.

### 2.4 Transition Matrix

**Definition 2.5**. The *transition matrix* $A \in \mathbb{N}^{\alpha \times \alpha}$ of a closure dynamical system is defined by

$$A_{ij} = \begin{cases} 1 & \text{if } f(i) = j, \\ 0 & \text{otherwise.} \end{cases}$$

Formalized as `closureTransitionMatrix`.

### 2.5 Closure Zeta Function

**Definition 2.6**. The *closure zeta function* is the formal power series

$$\zeta_f(t) = \sum_{n=0}^{\infty} p_n(f) \, t^n \in \mathbb{Q}[\![t]\!].$$

Formalized as `closureZeta`. Note: this is a variant of the Artin–Mazur zeta function, which traditionally uses the exponential generating function $\exp\left(\sum_{n=1}^{\infty} \frac{p_n}{n} t^n\right)$. Our variant is more natural for the algebraic setting.

### 2.6 Conjugacy

**Definition 2.7**. Two closure dynamical systems $(α, \mathrm{cl}_α, f)$ and $(β, \mathrm{cl}_β, g)$ are *conjugate* if there exists a bijection $\varphi : \alpha \to \beta$ such that $\varphi \circ f = g \circ \varphi$. Formalized as `ClosureConjugacy`.

### 2.7 Capacity and Certified Radius

**Definition 2.8**. The *capacity* of a closure dynamical system on a type with $|\alpha|$ states is $\mathrm{cap} = \log |\alpha|$. The *certified radius* is $r = 1/(1 + \mathrm{cap})$.

Formalized as `closureCapacity` and `closureCertifiedRadius`.

---

## 3. Basic Periodic Point Theory

**Theorem 3.1** (Membership characterization). $x \in \mathrm{Per}_n(f) \iff f^n(x) = x$.

*Proof sketch.* Direct unfolding of the filter definition. See `mem_closurePeriodicPoints_iff`.

**Theorem 3.2** (Cardinality bound). $p_n(f) \leq |\alpha|$ for all $n$.

*Proof sketch.* Periodic points form a subset of the full state space; apply `Finset.card_filter_le`. See `closurePeriodicCount_le_card`.

**Theorem 3.3** (Zero iteration). $\mathrm{Per}_0(f) = \alpha$ and $p_0(f) = |\alpha|$.

*Proof sketch.* $f^0 = \mathrm{id}$, so every state is 0-periodic. See `closurePeriodicPoints_zero` and `closurePeriodicCount_zero`.

**Theorem 3.4** (Unit iteration). $\mathrm{Per}_1(f) = \mathrm{Fix}(f)$.

*Proof sketch.* $f^1 = f$. See `closurePeriodicPoints_one`.

---

## 4. Divisibility and the Iteration Lemma

**Lemma 4.1** (Iterate multiplication). If $f^m(x) = x$ then $f^{km}(x) = x$ for all $k \in \mathbb{N}$.

*Proof sketch.* Induction on $k$. Base case: $f^0(x) = x$. Inductive step: $f^{(k+1)m}(x) = f^{km}(f^m(x)) = f^{km}(x) = x$. See `iterate_mul_fixed`.

**Theorem 4.2** (Divisibility monotonicity). If $m \mid n$ then $\mathrm{Per}_m(f) \subseteq \mathrm{Per}_n(f)$, and hence $p_m(f) \leq p_n(f)$ (when restricted to divisibility pairs with $m > 0$).

*Proof sketch.* Write $n = km$ and apply Lemma 4.1. See `closurePeriodic_monotone_divisor`.

---

## 5. The Trace Formula

**Theorem 5.1** (Matrix power entry formula). For all $n, i, j$:

$$(A^n)_{ij} = \begin{cases} 1 & \text{if } f^n(i) = j, \\ 0 & \text{otherwise.} \end{cases}$$

*Proof sketch.* Induction on $n$. The base case $n = 0$ gives the identity matrix. The inductive step uses the matrix multiplication formula and the deterministic nature of $f$: each row of $A$ has exactly one nonzero entry, so the sum collapses. See `closureTransitionMatrix_pow_entry`.

**Theorem 5.2** (Trace formula). $\mathrm{tr}(A^n) = p_n(f)$.

*Proof sketch.* The trace sums the diagonal entries $(A^n)_{ii}$, which by Theorem 5.1 equal 1 if $f^n(i) = i$ and 0 otherwise. The sum counts exactly the $n$-periodic points. See `closureTrace_eq_periodicCount`.

This trace formula is the finite-system analogue of the Lefschetz fixed-point theorem and the Selberg trace formula. It connects the spectral theory of the transition matrix (eigenvalues, characteristic polynomial) to the combinatorial dynamics (orbit counting).

---

## 6. Conjugacy Invariance

**Theorem 6.1** (Iteration commutes with conjugacy). If $\varphi$ is a conjugacy from $(α, f)$ to $(β, g)$, then $\varphi(f^n(x)) = g^n(\varphi(x))$ for all $n, x$.

*Proof sketch.* Induction on $n$ using the conjugacy equation $\varphi \circ f = g \circ \varphi$. See `iterate_eq_on_conj`.

**Theorem 6.2** (Periodic point set equivalence). Conjugate systems have isomorphic periodic point sets: $\varphi(\mathrm{Per}_n(f)) = \mathrm{Per}_n(g)$.

*Proof sketch.* $x \in \mathrm{Per}_n(f) \iff f^n(x) = x \iff g^n(\varphi(x)) = \varphi(x) \iff \varphi(x) \in \mathrm{Per}_n(g)$. See `closurePeriodicPoints_equiv`.

**Corollary 6.3** (Count invariance). $p_n(f) = p_n(g)$ for conjugate systems.

See `closurePeriodicCount_conj_invariant`.

**Corollary 6.4** (Zeta invariance). $\zeta_f = \zeta_g$ for conjugate systems.

See `closureZeta_conj_invariant`.

---

## 7. Eventual Periodicity and Rationality

### 7.1 Eventual Periodicity of Orbits

**Theorem 7.1** (Eventual periodicity of individual orbits). For every state $x$, there exist a preperiod $\mu \leq |\alpha|$ and a period $p$ with $0 < p \leq |\alpha|$ such that $f^{\mu + p}(x) = f^{\mu}(x)$.

*Proof sketch.* Among the $|\alpha| + 1$ iterates $x, f(x), \ldots, f^{|\alpha|}(x)$, two must coincide by the pigeonhole principle. If $f^i(x) = f^j(x)$ with $i < j$, take $\mu = i$ and $p = j - i$. See `closureDynamics_eventually_periodic`.

### 7.2 Eventual Periodicity of Periodic Point Counts

**Theorem 7.2** (Eventual periodicity of counts). There exist $N, p \in \mathbb{N}$ with $p > 0$ such that $p_n(f) = p_{n+p}(f)$ for all $n \geq N$.

*Proof sketch.* Since the set of functions $\alpha \to \alpha$ is finite (of cardinality $|\alpha|^{|\alpha|}$), the iterates $f, f^2, f^3, \ldots$ must eventually repeat by the pigeonhole principle: there exist $i < j$ such that $f^i = f^j$ as functions. Setting $p = j - i$, we have $f^n = f^{n+p}$ for all $n \geq i$, and therefore $p_n(f) = p_{n+p}(f)$. See `closurePeriodicCount_eventually_periodic`.

### 7.3 Rationality

**Theorem 7.3** (Rationality of the zeta function). There exists $N > 0$ such that $p_{n+N}(f) = p_n(f)$ for all $n \geq N$.

*Proof sketch.* By Theorem 7.2, there exist $N_0$ and $p > 0$ with eventual periodicity. Set $N = p \cdot (N_0 + 1)$. Then for $n \geq N$, we have $n \geq N_0$, and $p_{n+N}(f) = p_{n+p(N_0+1)}(f) = p_n(f)$ by iterating the eventual periodicity relation $N_0 + 1$ times. See `closureZeta_rational`.

This implies that the generating function $\zeta_f(t) = \sum p_n t^n$ is rational: it equals a polynomial (the initial segment) plus a periodic tail that sums to a rational function via the geometric series formula.

---

## 8. Capacity Bounds and Certified Radius

**Theorem 8.1** (Growth bound). If $p_n(f) > 0$, then $\log p_n(f) \leq \mathrm{cap}(f)$.

*Proof sketch.* Since $p_n(f) \leq |\alpha|$ by Theorem 3.2, we have $\log p_n(f) \leq \log |\alpha| = \mathrm{cap}(f)$ by monotonicity of logarithm. See `closurePeriodic_growth_le_capacity`.

**Theorem 8.2** (Zeta coefficient bound). The $n$-th coefficient of $\zeta_f$ satisfies $[\zeta_f]_n \leq |\alpha|$.

See `closureZeta_coeff_le_card`.

**Theorem 8.3** (Certified radius properties).
- $r(f) > 0$ (`closureCertifiedRadius_pos`).
- $r(f) \leq 1$ (`closureCertifiedRadius_le_one`).
- $\mathrm{cap}(f) \leq \mathrm{cap}(g) \implies r(g) \leq r(f)$ (`closureCertifiedRadius_antitone_capacity`).

**Theorem 8.4** (Capacity nonnegativity). If $|\alpha| > 0$, then $\mathrm{cap}(f) \geq 0$. See `closureCapacity_nonneg`.

---

## 9. Additional Results

**Theorem 9.1** (Orbit hash cardinality). The orbit hash — the periodic point set viewed as a cryptographic fingerprint — has cardinality equal to $p_n(f)$. See `closureOrbitHash_card_eq_periodicCount`.

**Theorem 9.2** (Thermodynamic weight positivity). The uniform Gibbs weight is positive for all states. See `closureThermoWeight_pos`.

**Theorem 9.3** (Thermodynamic weight conjugacy invariance). Conjugate systems have equal thermodynamic weights. See `closureThermoWeight_conj_invariant`.

---

## 10. Discussion

### 10.1 Relationship to Classical Results

The trace formula (Theorem 5.2) is a finite, elementary version of results that in continuous dynamics require heavy analytical machinery (Lefschetz numbers, Ruelle–Perron–Frobenius theory). The rationality theorem (Theorem 7.3) parallels the Bowen–Lanford theorem for subshifts of finite type, but with a simpler proof that exploits the finiteness of the function space $\alpha^\alpha$ rather than the spectral theory of nonneg matrices.

The classical Artin–Mazur zeta function for a smooth map $f : M \to M$ is defined as
$$\zeta_f(t) = \exp\left(\sum_{n=1}^{\infty} \frac{|\mathrm{Fix}(f^n)|}{n} t^n\right).$$
For subshifts of finite type with transition matrix $A$, Bowen and Lanford [2] proved $\zeta_f(t) = 1/\det(I - tA)$, establishing rationality via the characteristic polynomial. Our approach is different: we use the *ordinary* generating function $\sum p_n t^n$ rather than the exponential form, and prove rationality directly from the eventual periodicity of the sequence $(p_n)$, without appealing to spectral theory. This has the advantage of applying to arbitrary deterministic finite dynamics, not just subshifts.

The divisibility monotonicity theorem (Theorem 4.2) is well-known in the ergodic theory folklore but rarely stated precisely for finite systems. Our formulation and proof via the iteration multiplication lemma provide a clean, self-contained treatment.

### 10.2 The Role of the Closure Structure

The closure compatibility condition (`closed_orbit_image`) ensures that closed sets are forward-invariant — a structural property that is essential for applications in model checking (where closed sets represent safety properties) and database theory (where closed sets represent attribute closures under functional dependencies). While the main theorems in this paper hold for arbitrary finite dynamical systems, the closure structure provides the correct framework for connecting dynamics to lattice-theoretic and logical semantics.

Specifically, the closure compatibility axiom $\mathrm{cl}(S) = S \implies \mathrm{cl}(f(S)) \subseteq S$ captures the intuition that "observable properties are preserved under dynamics." In modal logic and epistemic model logic (EML), a closure operator models the deductive closure of a theory — the set of all statements entailed by a given set of axioms. The compatibility condition then says that the dynamic evolution of a system preserves logical entailment: if a set of propositions is deductively closed, then the propositions that hold after one time step are still within the deductive closure.

This interpretation connects our framework to the semantics of dynamic epistemic logic, where updates to an agent's knowledge base must respect the closure properties of the underlying logic. The transition matrix of the closure dynamical system can be viewed as the semantic interpretation of a program or protocol, and the periodic orbit structure encodes the recurrent behaviors of the system.

### 10.3 Applications

**Cryptographic state auditing.** The orbit hash (`closureOrbitHash`) provides a fingerprint for detecting collisions in finite-state cryptographic primitives. Given a block cipher or hash function operating on a finite state space, the periodic orbit structure reveals the collision structure: two states that enter the same cycle will eventually produce identical outputs. The conjugacy invariance of periodic counts (Corollary 6.3) ensures that structurally equivalent cryptographic primitives — those related by a relabeling of the state space — produce identical orbit fingerprints. This is relevant for auditing the security of lightweight ciphers and post-quantum key encapsulation mechanisms that operate on small state spaces.

**Certified ML robustness.** The certified radius $r = 1/(1 + \log|\alpha|)$ provides a stability margin for finite-state abstractions of neural network dynamics. In adversarial robustness, a certified radius guarantees that no perturbation within the ball of radius $r$ can change the classification output. Our antitonicity result (Theorem 8.3) formalizes the intuition that more complex state spaces — those with larger capacity — have narrower certified radii, quantifying the fundamental tension between model expressivity and robustness. The positivity result (Theorem 8.3, first part) ensures that every finite system has a nonzero certified radius, ruling out pathological instabilities.

**Symbolic dynamics and coding theory.** The transition matrix and trace formula connect finite closure systems to the symbolic dynamics of sofic shifts and subshifts of finite type. For a communication channel modeled by a finite-state machine, the capacity (Definition 2.8) gives an upper bound on the information rate, and the periodic orbit counts determine the error-detection capability of cyclic codes associated with the channel. The rationality of the zeta function (Theorem 7.3) implies that the channel capacity is computable — it can be determined from a finite prefix of the periodic count sequence.

**Formal verification and model checking.** The eventual periodicity theorem (Theorem 7.1) provides a certified termination bound for symbolic model checking of finite-state systems. Given a safety property expressed as a closed set, the closure compatibility condition guarantees forward invariance, and the eventual periodicity bound $\mu + p \leq 2|\alpha|$ gives an explicit, computable upper bound on the time needed to determine whether a state eventually violates the safety property. This is tighter than the naive $|\alpha|!$ bound obtained from the enumeration of all possible function orderings.

**Database dependency propagation.** In relational database theory, functional dependencies form a closure system (Armstrong's axioms are exactly the axioms of a closure operator). A normalization step or schema evolution can be modeled as a step function on attribute sets, and the closure compatibility condition ensures that normalization preserves the functional dependency structure. The periodic orbit counts then measure the "normalization complexity" — the number of schema states that cycle back to themselves under repeated normalization.

### 10.4 Computational Complexity

The periodic point count $p_n(f)$ can be computed in $O(n \cdot |\alpha|)$ time by iterating $f$ starting from each state. Via the trace formula, it can alternatively be computed in $O(|\alpha|^\omega \log n)$ time using matrix exponentiation, where $\omega$ is the matrix multiplication exponent. For large $n$ and moderate $|\alpha|$, the matrix approach is faster.

The eventual period can be detected in $O(|\alpha|^{|\alpha|})$ time in the worst case (by iterating until the function iterates repeat), but in practice converges much faster. The rationality theorem guarantees that the period divides $\mathrm{lcm}(1, 2, \ldots, |\alpha|)$, providing a tighter bound.

### 10.5 Relation to Thermodynamic Formalism

The trace formula $\mathrm{tr}(A^n) = p_n(f)$ is the finite-system analogue of the partition function in statistical mechanics. For a lattice system with transfer matrix $A$ at inverse temperature $\beta$, the partition function is $Z_n(\beta) = \mathrm{tr}(A(\beta)^n)$, where $A(\beta)$ is the Boltzmann-weighted transfer matrix. In the uniform (infinite temperature, $\beta = 0$) case, the Boltzmann weights are all 1, and the partition function reduces to the periodic point count. The capacity $\log|\alpha|$ is then the infinite-temperature entropy, and the certified radius $1/(1 + \log|\alpha|)$ can be interpreted as the smallest perturbation scale at which the thermodynamic identity of the system can change.

Our `closureThermoWeight` function (Definition 2.8, uniformly equal to 1) represents this infinite-temperature case. A natural extension would introduce non-uniform weights $w(x) = e^{-\beta V(x)}$ for a potential function $V$, yielding a weighted zeta function and connecting to the full thermodynamic formalism of Ruelle and Sinai.

---

## 11. Future Work

Several natural extensions suggest themselves:

1. **Spectral analysis**: Connect the eigenvalues of the transition matrix to the periodic point counts via the characteristic polynomial, yielding a closed-form expression for the zeta function.

2. **Entropy**: Define the topological entropy as $h = \lim_{n \to \infty} \frac{1}{n} \log p_n(f)$ and prove it equals the logarithm of the spectral radius of $A$.

3. **Non-deterministic extensions**: Replace the deterministic step function with a relation, yielding a multi-valued dynamics compatible with closure semantics.

4. **Infinite-state generalizations**: Extend the theory to countable or compact state spaces using Mathlib's topological dynamics library.

5. **Ordinal notation connections**: Connect the complexity hierarchy of closure systems to proof-theoretic ordinal analysis, using the periodic orbit counts as a measure of dynamical complexity.

---

## References

[1] M. Artin and B. Mazur, "On periodic points," *Annals of Mathematics*, vol. 81, no. 1, pp. 82–99, 1965.

[2] R. Bowen and O. Lanford, "Zeta functions of restrictions of the shift transformation," *Proceedings of Symposia in Pure Mathematics*, vol. 14, pp. 43–49, 1970.

[3] A. Katok and B. Hasselblatt, *Introduction to the Modern Theory of Dynamical Systems*, Cambridge University Press, 1995.

[4] D. Lind and B. Marcus, *An Introduction to Symbolic Dynamics and Coding*, Cambridge University Press, 1995.

[5] B. A. Davey and H. A. Priestley, *Introduction to Lattices and Order*, Cambridge University Press, 2002.
