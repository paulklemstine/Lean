# Future Directions: Phase Transitions in Proof Emergence

## Conjecture 1: Minimal-Certificate Threshold Law

**Precise statement.** Let $(M_m)_{m \geq 1}$ be a sequence of monotone provability systems on axiom pools of size $n_m \to \infty$, each with a single target $t_m$. Suppose the minimal certificate size is $k_m$ and the number of minimal certificates is $N_m$. Then the $1/2$-threshold satisfies

$$
p_{1/2}(t_m) \;\sim\; N_m^{-1/k_m} \quad \text{as } m \to \infty.
$$

**Test.** Enumerate certificates in random Horn clause systems over $n$ variables with clause length $k$. Compute $p_{1/2}$ empirically by Monte Carlo sampling of random axiom subsets, and compare with $N^{-1/k}$ where $N$ is the number of minimum-size certificates. Vary $n \in \{10, 20, 50, 100\}$ and $k \in \{2, 3, 4, 5\}$.

**Impact.** If confirmed, this provides a universal formula for the onset of provability in finite systems, directly analogous to the Erdős–Rényi threshold $p_c = 1/n$ for graph connectivity.

---

## Conjecture 2: Overlap Sharpness Dichotomy

**Precise statement.** Define the *certificate overlap number* $\Delta(M, t)$ as the maximum, over all pairs of distinct minimal certificates $C_1, C_2$ for $t$, of $|C_1 \cap C_2|$. If $\Delta(M_m, t_m) = o(k_m)$ and $N_m \to \infty$, then the provability transition has width $o(p_c)$ — i.e., the transition is *sharp*.

Conversely, if $\Delta(M_m, t_m) / k_m \to c > 0$, then the transition width is $\Theta(p_c)$ — the transition is *coarse*.

**Test.** Construct parameterized families:
- *Low overlap:* $r$ disjoint certificates of size $k$ (overlap = 0). Measure transition width numerically.
- *High overlap:* $r$ certificates sharing a common core of $\lfloor k/2 \rfloor$ axioms. Compare widths.
Fit transition curves to $\Phi((p - p_c)/w)$ and extract width $w$.

**Impact.** Establishes that proof *entanglement* (shared axiom dependencies) controls transition sharpness — a new structural invariant for proof complexity.

---

## Conjecture 3: Universality Across Proof Formalisms

**Precise statement.** Consider three families of finite proof systems with matched certificate statistics (same $k$, same $N$, same overlap $\Delta$):
1. Propositional Horn clause derivations.
2. Bounded quantifier-free Presburger arithmetic.
3. Equational logic over finite algebras.

Then the rescaled provability curves $\Pr_{p \cdot p_c}[t \text{ provable}]$ converge to the same limiting shape as the system size grows.

**Test.** For each formalism, generate random instances with $n = 50$ axiom candidates, $k = 3$, and ~20 minimal certificates. Run 10,000 Monte Carlo trials per $p$-value. Plot rescaled curves and test for collapse onto a universal curve using Kolmogorov–Smirnov statistics.

**Impact.** Would demonstrate that provability phase transitions are *formalism-independent*, depending only on the combinatorial structure of proof certificates — a universality result analogous to those in statistical physics.

---

## Conjecture 4: Axiom Pivotality Maximizes Discovery

**Precise statement.** Define the *pivotality* of axiom $a$ for target $t$ at parameter $p$ as

$$
\text{Piv}_p(a, t) = \Pr_p[t \text{ provable} \mid a \in A] - \Pr_p[t \text{ provable} \mid a \notin A].
$$

Then among all singleton axiom additions to a base theory, the axiom maximizing $\sum_t \text{Piv}_p(a, t)$ (summed over a target family) also maximizes the expected number of newly provable targets.

**Test.** In a Horn clause system with 100 axiom candidates and 20 targets:
1. Estimate pivotality of each axiom by Monte Carlo (10,000 samples).
2. Compare the greedy pivotality-maximizing axiom selection against random selection and against an oracle that knows the optimal single addition.
3. Measure regret (gap to oracle) across 100 random system instances.

**Impact.** Provides a principled, computationally tractable strategy for axiom selection in automated theorem proving and mathematical discovery systems. Connects proof phase transitions to the theory of Boolean function influence.

---

## Conjecture 5: Proof Susceptibility Peaks at Threshold

**Precise statement.** Define the *proof susceptibility* as the derivative of the provability probability:

$$
\chi_t(p) = \frac{d}{dp} \Pr_p[t \text{ provable}].
$$

For systems with $r$ disjoint certificates of size $k$, the susceptibility peak satisfies

$$
\chi_t^{\max} = \Theta(k \cdot r^{1-1/k})
$$

and occurs at $p^* = r^{-1/k}(1 + O(1/k))$.

**Test.** For $k \in \{2, 3, 5, 10\}$ and $r \in \{1, 5, 10, 50, 100\}$:
1. Compute exact derivative of $1 - (1-p^k)^r$ analytically.
2. Verify peak location and height against the conjectured asymptotics.
3. For non-disjoint certificate systems, numerically differentiate Monte Carlo estimates and compare peak location with the certificate-predicted threshold.

**Impact.** Gives a quantitative prediction of where adding axioms has maximum leverage, directly applicable to prioritizing axiom candidates in proof search. The susceptibility is the logical analogue of specific heat in statistical mechanics.
