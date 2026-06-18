# Future Directions: Symbolic Dynamics as Proof Theory

## Hypothesis 1: Uniform Aperiodicity Exponent Bound

**Conjecture.** For every nearest-neighbor CA rule $f : \alpha \times \alpha \to \alpha$ on a finite alphabet $\alpha$ and every strip height $h \geq 1$, every element $m$ of the transition monoid of the spacetime column language DFA satisfies $m^3 = m^2$.

**Precision.** The exponent 2 is tight: there exist CA rules and heights where some transition monoid element $m$ satisfies $m^2 \neq m$ but $m^3 = m^2$.

**Test.** Exhaustively enumerate transition monoid elements for all 256 elementary CA rules (binary, radius 1) and heights $h = 2, 3, 4, 5$. For each element, verify $m^3 = m^2$ and record whether $m^2 = m$ already.

**What would refute it.** Finding any transition monoid element with $m^3 \neq m^2$. Our theorem proves this cannot happen for the natural DFA construction, so refutation would require showing the syntactic monoid differs from the transition monoid in a way that breaks the bound.

**Impact.** A uniform exponent bound of 2 gives the strongest possible aperiodicity guarantee, placing all CA spacetime column languages in a restricted subclass of star-free languages. This would enable quantifier-rank bounds for FO[<] definitions.

## Hypothesis 2: Exact Period Formula for Additive CA Fixed Points

**Conjecture.** For an additive CA over $\text{GF}(p)$ with local polynomial $P(U)$, the eventual period of $n \mapsto \log_p |\text{Fix}(T_n^m)|$ equals exactly $\text{lcm}\{\text{ord}(\zeta) : \zeta \text{ is a simple root of } P(U)^m - 1 \text{ in } \overline{\mathbb{F}_p}\}$.

**Precision.** "Equals" rather than "divides." The period should be tight — not a proper divisor of the lcm.

**Test.** For all irreducible polynomials $Q$ of degree $\leq 6$ over $\text{GF}(2)$, compute the GCD degree sequence $n \mapsto \deg(\gcd(X^n - 1, Q))$ for $n \leq 500$. Extract the minimal period and compare with the lcm of multiplicative orders of roots of $Q$.

**What would refute it.** Finding a polynomial whose GCD degree sequence has a period that is a proper divisor of the predicted lcm. This would happen if root multiplicities or inseparability in characteristic $p$ cause additional cancellation.

**Impact.** An exact period formula would give a complete algebraic characterization of the dynamical periodicity, connecting CA dynamics directly to the arithmetic of finite field extensions.

## Hypothesis 3: Star-Freeness Implies Zeta Function Pole Restrictions

**Conjecture.** If the spacetime column language of a CA is star-free (which we have shown is always the case), then the dynamical zeta function $\zeta_h(z) = \exp\left(\sum_{n=1}^\infty \frac{|\mathcal{L}_n|}{n} z^n\right)$, where $|\mathcal{L}_n|$ counts the number of valid spacetime strips of width $n$, is a rational function whose poles are all real.

**Precision.** The number of valid strips of width $n$ satisfies a linear recurrence (by transfer matrix theory). The zeta function is rational. The conjecture is that all poles of $1/\zeta_h$ lie on the real axis.

**Test.** For all 256 elementary CA rules and heights $h = 2, 3, 4, 5$:
1. Compute the transfer matrix eigenvalues.
2. Check whether all eigenvalues are real (or occur in complex conjugate pairs that cancel in the zeta function).

**What would refute it.** A transfer matrix with complex eigenvalues of distinct absolute values, producing complex poles of the zeta function.

**Impact.** This would connect the logical complexity class (star-freeness / FO[<]) of the spacetime language to the analytic properties of the counting zeta function — a new bridge between descriptive complexity and dynamical zeta functions.

## Hypothesis 4: Quantifier-Rank Bounds for Permutative CA

**Conjecture.** For a right-permutative CA with alphabet $\alpha$ and strip height $h$, the spacetime column language of width-$n$ strips is definable by an FO[<] sentence of quantifier rank at most $2h + |\alpha|$.

**Precision.** The bound should be linear in $h$ and depend on $|\alpha|$ but not on $n$. The FO[<] formula is over the linear order of column positions.

**Test.** 
1. From the aperiodic DFA, extract the syntactic monoid.
2. Use the algebraic characterization (variety of aperiodic monoids) to compute the minimum quantifier rank.
3. Check whether the rank is bounded by $2h + |\alpha|$ for binary rules with $h \leq 6$.

**What would refute it.** Finding a right-permutative rule where the quantifier rank grows faster than linearly in $h$. This could happen if the interaction between rows creates exponentially complex Boolean combinations.

**Impact.** Linear quantifier-rank bounds would mean that spacetime pattern recognition for permutative CA is not just regular and star-free, but achievable by very shallow logical formulas. This has practical implications for hardware verification of CA-based circuits.

## Hypothesis 5: Nilpotent-Cyclotomic Duality

**Conjecture.** For any additive right-permutative CA over $\text{GF}(p)$:
- The aperiodicity of the spacetime column language transition monoid (Direction A) and 
- the eventual periodicity of fixed-point logarithms (Direction B) 

are both consequences of a single decomposition: the transfer operator splits as $T = T_{\text{nil}} \oplus T_{\text{cyc}}$ where $T_{\text{nil}}$ is nilpotent (governing the aperiodic monoid structure) and $T_{\text{cyc}}$ is a direct sum of cyclic permutations (governing the period).

**Precision.** The nilpotent rank of $T_{\text{nil}}$ bounds the aperiodicity exponent, and the cycle lengths of $T_{\text{cyc}}$ determine the eventual period of fixed-point counts.

**Test.** 
1. For additive binary CA (Rules 90, 150) with heights $h = 2, \ldots, 8$:
2. Compute the transfer matrix $M$ over $\text{GF}(2)$.
3. Decompose $M$ into nilpotent and semisimple parts.
4. Verify that the nilpotent rank matches the aperiodicity exponent of the transition monoid.
5. Verify that the semisimple part's eigenvalue orders match the fixed-point periodicity.

**What would refute it.** A CA where the aperiodicity exponent is not predicted by the nilpotent rank, or where the fixed-point period is not predicted by the semisimple eigenvalue orders. This would mean the two phenomena arise from independent mechanisms rather than a common spectral decomposition.

**Impact.** This would be the deepest result of the program: a single algebraic decomposition unifying the logical complexity of spacetime languages with the arithmetic complexity of orbit statistics. It would place symbolic dynamics firmly in the intersection of semigroup theory and arithmetic geometry, opening new pathways for both fields.
