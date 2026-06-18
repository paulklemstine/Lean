# Future Directions: EML Expression Complexity Theory

## Overview

This document identifies five specific, testable scientific hypotheses arising from the formally verified EML compilation theory. Each hypothesis is falsifiable by finite computation or formal proof, and each would open significant new territory if confirmed.

---

## Hypothesis 1: Polynomial Semantic Normalization on Log-Safe Expressions

**Conjecture:** For every `EMLSafe` expression `e` (i.e., every EML expression whose `eml` nodes have positivity-guaranteed second arguments), there exists a semantically equivalent EML expression `e'` produced by a canonical normalizer such that

$$\text{esize}(e') \leq C \cdot (\text{esize}(e) + 1)^k$$

for universal constants $C, k$ independent of $e$.

**Test:** Enumerate all EMLSafe expressions up to depth 10. Apply a normalizer incorporating constant folding, identity elimination, and exp-log cancellation (e.g., replacing `eml(sub(1, eml(0, e)), 1)` patterns with `e`). Measure the ratio `normalized_size / original_size` and fit a power-law model. If the exponent $k$ remains bounded by 2 across all depths tested, the hypothesis is supported. If a family exhibits exponential growth, it is refuted.

**Impact:** Confirms that EML admits a structured polynomial complexity theory on a natural subclass, analogous to polynomial-size circuit normal forms. This would establish EML as a genuine complexity-theoretic basis for elementary analysis, not merely an expressiveness curiosity.

---

## Hypothesis 2: Necessity of Sharing (Tree vs. DAG Blowup)

**Conjecture:** There exists a family of UExpr expressions $\{e_n\}_{n \geq 1}$ with $\text{size}(e_n) = \Theta(n)$ such that:
- The tree-size of the semantically normalized EML form grows as $\Omega(2^n)$.
- The DAG-size (counting shared subexpressions once) of the same normalized form remains $O(n^c)$ for some constant $c$.

**Test:** Consider the family $e_n = \underbrace{\exp(\exp(\cdots\exp}_{n}(\log(\underbrace{\log(\cdots\log}_{n}(x))\cdots))\cdots))$, which semantically reduces to the identity on $x > e\uparrow\uparrow (n-1)$. Compile to EML, normalize with and without common subexpression elimination, and compare tree-size vs. DAG-size. Plot both on a logarithmic scale against $n$.

**Impact:** If confirmed, this proves that tree-based EML normalization is inherently limited and that DAG-based (circuit-like) representations are essential for polynomial complexity. This would directly motivate extending the Lean formalization from expression trees to expression DAGs, creating a richer formal complexity theory.

---

## Hypothesis 3: Transcendence Rank Predicts Simplifiability

**Conjecture:** Among expressions of fixed tree-size $s$, those with lower transcendence rank $r$ admit EML normal forms with smaller normalized size. Specifically, there exists a function $f(s, r)$ polynomial in $s$ and decreasing in $r$ such that for all EMLSafe expressions $e$ with $\text{size}(e) = s$ and $\text{transcendenceRank}(e) = r$:

$$\text{normalized\_esize}(e) \leq f(s, r).$$

**Test:** Enumerate expressions up to depth 6, stratified by `(size, transcendenceRank)`. For each stratum, compute the maximum normalized EML size. Plot the maximum normalized size against transcendence rank for fixed sizes. If expressions with rank 0 (purely algebraic) always normalize to $O(s)$ while high-rank expressions grow faster, the hypothesis is supported.

**Impact:** Establishes transcendence rank as a meaningful complexity parameter within the EML framework, connecting expression complexity to transcendental number theory and the Schanuel conjecture. This could yield a formal proof that "more transcendental = harder to simplify."

---

## Hypothesis 4: Domain Complexity is the True Obstruction

**Conjecture:** The dominant source of size blowup in EML normalization is not the transcendental syntax itself but the complexity of positivity side conditions induced by nested logarithms and divisions. Specifically:
- On the subclass of expressions where all `log` arguments are provably positive by syntactic inspection (e.g., `log(exp(e))`, `log(const c)` with `c > 0`), normalization is always linear.
- On expressions with deeply nested `log(f(x))` where positivity of `f` depends on the value of `x`, normalization may require case-splitting that causes exponential blowup.

**Test:** Compare normalization growth on two families:
1. **Domain-trivial:** Expressions where every `log` wraps a syntactically positive subexpression.
2. **Domain-complex:** Expressions where `log` arguments involve the variable `x` in ways that make positivity non-obvious.

Measure normalized sizes and fit growth models separately for each family.

**Impact:** If confirmed, this identifies domain analysis (proving positivity of arguments to `log`) as the core computational bottleneck, suggesting that advances in automated positivity proving would directly translate to better EML normalization. This connects EML complexity to real algebraic geometry and semidefinite programming.

---

## Hypothesis 5: EML Compilation Preserves Straight-Line Program Complexity

**Conjecture:** If a unary elementary function $f$ can be computed by a straight-line program (SLP) of length $L$ over the operations $\{+, -, \times, \div, \exp, \log\}$, then there exists an EML straight-line program computing $f$ of length at most $O(L)$.

More precisely, define an EML-SLP as a sequence of instructions where each instruction is either:
- a field operation on two previously computed values, or
- an `eml(a, b)` application on two previously computed values.

Then every elementary SLP of length $L$ can be converted to an EML-SLP of length at most $L + O(1)$, since each `exp` instruction becomes one `eml` instruction (with a precomputed constant 1) and each `log` instruction becomes two instructions (one `eml`, one subtraction).

**Test:** Implement an SLP-to-EML-SLP compiler. Test on benchmark SLPs from computer algebra (e.g., Padé approximants, AGM iterations, hypergeometric evaluators). Verify that the EML-SLP length is within the conjectured bound.

**Impact:** This would establish EML as a complexity-preserving basis not just for expression trees but for the more general computational model of straight-line programs, connecting to algebraic complexity theory (Bürgisser, Clausen, Shokrollahi). It would mean that EML normal forms do not just preserve tree-level complexity but also circuit-level complexity, making EML a first-class citizen in computational complexity theory.

---

## Experimental Infrastructure

All hypotheses above can be tested using the enumeration and analysis tools provided in `algorithms.py` and `demo.py`. The key functions are:

- `enumerate_uexprs(depth)` — generates test expressions
- `compile(e)` — UExpr → EMLExpr compilation
- `eml_normalize(e)` — constant-folding normalization
- `analyze_compilation(e)` — full size/rank/correctness analysis
- `compute_dag_size(e)` — DAG-size measurement for sharing analysis

To run the experiments:
```bash
python3 demo.py          # Full interactive demo
python3 applications.py  # Application-specific experiments
```

## Priority Ordering

1. **Hypothesis 2 (Sharing)** — most immediately testable and likely to yield a clear positive or negative result
2. **Hypothesis 4 (Domain obstruction)** — high impact, moderate difficulty
3. **Hypothesis 1 (Polynomial normalization)** — the central conjecture, hardest to resolve
4. **Hypothesis 3 (Transcendence rank)** — interesting structural insight
5. **Hypothesis 5 (SLP preservation)** — connects to the broadest existing theory
