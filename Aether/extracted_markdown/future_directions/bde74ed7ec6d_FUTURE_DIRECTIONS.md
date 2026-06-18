# Future Directions: Transition Monoid Structure of CA Column Languages

## Overview

The theorem $m^{h+1} = m^h$ for transition monoids of nearest-neighbor CA column languages establishes aperiodicity with exponent $h$. This opens several falsifiable research directions connecting cellular automata, finite semigroup theory, and descriptive complexity.

---

## Hypothesis A: Rule-Dependent Exponent Formula

**Conjecture.** For a nearest-neighbor CA rule $f : \alpha \times \alpha \to \alpha$, the exact aperiodicity exponent of $M_h(f)$ equals $h \cdot d(f)$, where $d(f)$ is the "information depth" of $f$ — defined as 1 if the output of $f(x,y)$ depends on $x$ (i.e., $\exists y. f(0,y) \neq f(1,y)$) and 0 otherwise, with the exponent being 1 when $d(f) = 0$.

More precisely: the exponent is $\lceil h / r(f) \rceil$ where $r(f)$ is the minimum number of step transitions needed for the bottom coordinate to become independent of all input coordinates.

**Test.** Compute the exact exponent for all 16 binary Boolean rules at heights $h = 1, \ldots, 10$. Compare with candidate formulas involving the "left-dependency" and "right-dependency" properties of $f$.

**Refutation.** An explicit rule where the exponent does not match any formula involving only local properties of $f$ and the height $h$.

**Impact.** A closed-form exponent formula would give tight descriptive complexity bounds for individual CA rules, enabling rule-specific optimizations in model checking and language-theoretic analysis.

---

## Hypothesis B: J-Triviality for Aperiodic CA Column Languages

**Conjecture.** The transition monoid $M_h(f)$ is $\mathcal{J}$-trivial (every $\mathcal{J}$-class is a singleton) for every nearest-neighbor CA rule $f$ and every height $h$.

By Simon's theorem, $\mathcal{J}$-triviality is equivalent to the column language being piecewise testable — a strictly stronger property than star-freeness.

**Test.** For all 16 binary Boolean rules and heights $h = 1, \ldots, 5$:
1. Compute the full transition monoid.
2. Compute Green's $\mathcal{J}$-relation by checking two-sided ideal containment.
3. Verify whether all $\mathcal{J}$-classes are singletons.

**Refutation.** A CA rule and height where two distinct monoid elements generate the same two-sided ideal ($M a M = M b M$ with $a \neq b$).

**Impact.** If true, this would place all CA column languages in the piecewise testable fragment, enabling bounded-depth logical descriptions and connecting CA dynamics to Simon's theorem and the theory of partially ordered monoids.

---

## Hypothesis C: Piecewise-Testability Rank Bound

**Conjecture.** If the column language of a nearest-neighbor CA at height $h$ over alphabet $\alpha$ is piecewise testable, then it has piecewise-testability rank at most $r(h, |\alpha|) = h + |\alpha| - 1$.

The piecewise-testability rank is the minimum $r$ such that the language is a Boolean combination of languages of the form $\alpha^* a_1 \alpha^* a_2 \alpha^* \cdots a_r \alpha^*$ for sequences of at most $r$ symbols.

**Test.** For all 16 binary Boolean rules and heights $h = 1, \ldots, 5$:
1. If the monoid is $\mathcal{J}$-trivial, compute the piecewise-testability rank by finding the longest chain in the $\mathcal{J}$-order.
2. Compare with the candidate bound $h + |\alpha| - 1$.

**Refutation.** A rule where the piecewise-testability rank exceeds $h + |\alpha| - 1$.

**Impact.** An explicit rank bound would give tight quantifier-rank bounds for FO[$<$] descriptions, enabling efficient Ehrenfeucht–Fraïssé game strategies and potentially connecting to circuit complexity lower bounds.

---

## Hypothesis D: Generating Function Pole Restrictions

**Conjecture.** For every nearest-neighbor CA rule $f$, height $h$, and finite alphabet $\alpha$, the ordinary generating function

$$G_{f,h}(x) = \sum_{n \geq 0} c_n x^n$$

where $c_n$ counts the number of valid spacetime column sequences of width $n$, is a rational function whose poles are all roots of unity of order at most $|\alpha|^h$.

**Test.** For all 16 binary Boolean rules and heights $h = 1, \ldots, 4$:
1. Compute $c_n$ for $n = 0, \ldots, 2 \cdot |\alpha|^h$.
2. Use the Berlekamp–Massey algorithm to find the minimal linear recurrence.
3. Factor the characteristic polynomial and check whether all roots are roots of unity.

**Refutation.** A generating function whose characteristic polynomial has a root that is not a root of unity, or whose root-of-unity order exceeds $|\alpha|^h$.

**Impact.** Pole restrictions would constrain the asymptotic growth of $c_n$, connecting the algebraic structure of the transition monoid to analytic properties of the counting sequence. This would link CA dynamics to zeta-function theory and could yield orbit-growth constraints.

---

## Hypothesis E: Exponent Ceiling for Larger Neighborhoods

**Conjecture.** For a CA rule $f : \alpha^r \to \alpha$ with neighborhood radius $r$ (depending on $r$ consecutive cells), the aperiodicity exponent of the transition monoid at height $h$ is at most $\lceil h / (r-1) \rceil$.

The intuition: each step transition "shifts" the state by $r - 1$ positions (the overlap between consecutive neighborhoods), so the information flush takes $\lceil h / (r-1) \rceil$ steps instead of $h$.

**Test.** Implement the column-extension DFA for radius-$r$ CA rules. For binary rules with $r = 2, 3, 4$ and heights $h = 1, \ldots, 10$, compute the exact exponent and compare with $\lceil h / (r-1) \rceil$.

**Refutation.** A rule and height where the exponent exceeds $\lceil h / (r-1) \rceil$.

**Impact.** Confirming this bound would generalize the current theorem to all one-dimensional CA, providing a uniform framework for language-theoretic analysis of CA spacetime patterns. It would also clarify the relationship between neighborhood size, information propagation speed, and algebraic complexity.

---

## Summary Table

| Hypothesis | Status | Key Tool | Difficulty |
|---|---|---|---|
| A: Rule-dependent exponent | Open | Enumeration + formula fitting | Medium |
| B: $\mathcal{J}$-triviality | Open | Green's relation computation | Medium |
| C: PT rank bound | Open (depends on B) | Chain computation in $\mathcal{J}$-order | Hard |
| D: GF pole restrictions | Open | Berlekamp–Massey + factoring | Medium |
| E: Larger neighborhood bound | Open | Generalized DFA construction | Medium |

Each hypothesis is:
- **Precise** enough to have a definite truth value
- **Testable** with finite computation on small instances
- **Falsifiable** by explicit counterexample
- **Impactful** if true, opening new connections between domains
