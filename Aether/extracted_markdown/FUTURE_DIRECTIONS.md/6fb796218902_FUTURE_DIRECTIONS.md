# Future Directions: Kernel Density Theorem and Beyond

## Overview

The kernel density theorem establishes the foundational cardinality law for linear maps over prime fields. This document outlines five breakthrough-level research directions that build directly on this result.

---

## Direction 1: Affine Fiber Uniformity Theorem

### Statement

For $f : V \to W$ linear over $\mathbb{F}_q$ and any $y \in \operatorname{range}(f)$, the fiber $f^{-1}(\{y\})$ has cardinality exactly $|\ker(f)|$.

### Significance

The kernel density theorem bounds the kernel (the fiber over 0). The affine fiber theorem says **all fibers are the same size**. This is the exact equidistribution result: a surjective linear map distributes domain elements uniformly across range elements.

### Proof Strategy

The fiber $f^{-1}(\{y\})$ is a coset $v_0 + \ker(f)$ for any $v_0$ with $f(v_0) = y$. Cosets of a finite subgroup all have the same cardinality. Formalize using `AddCoset` or `QuotientGroup.mk` with the translation bijection $v \mapsto v + v_0$.

### Hypotheses to Test

- **H1**: $|f^{-1}(\{y\})| = |\ker(f)|$ for all $y \in \operatorname{range}(f)$.
- **H2**: $f^{-1}(\{y\}) = \emptyset$ for $y \notin \operatorname{range}(f)$.
- **H3**: The fibers partition $V$ into $|\operatorname{range}(f)|$ classes of equal size.

### Cross-Domain Connections

- **Probability theory**: A random element of $V$ maps to each value in $\operatorname{range}(f)$ with equal probability $1/|\operatorname{range}(f)|$.
- **Cryptography**: Linear maps are perfectly uniform random functions when restricted to their range—important for security proofs.
- **Sampling**: Uniform sampling from $V$ followed by applying $f$ produces uniform samples from $\operatorname{range}(f)$.

---

## Direction 2: Multi-Constraint Density Theorem

### Statement

For $f : V \to W$ of rank $r$:
$$|\ker(f)| = |V| / q^r$$

More precisely: $|\ker(f)| = q^{n-r}$ where $n = \dim(V)$ and $r = \dim(\operatorname{range}(f))$.

### Significance

This refines the kernel density bound from $|\ker(f)| \cdot q \leq |V|$ to the exact formula $|\ker(f)| = |V|/q^r$. Each independent constraint reduces the kernel by exactly a factor of $q$. This is the quantitative backbone of multi-parity-check codes.

### Proof Strategy

Combine the product formula $|\ker(f)| \cdot |\operatorname{range}(f)| = |V|$ with $|\operatorname{range}(f)| = q^r$ (from `FiniteField.pow_finrank_eq_card`). The result is immediate.

### Key Lemma

```
theorem card_kernel_eq_card_domain_div_pow_rank (f : V →ₗ[ZMod q] W) :
    Fintype.card f.ker = Fintype.card V / q ^ Module.finrank (ZMod q) f.range
```

### Applications

- **Code dimension formula**: An $[n, k]_q$ code defined by $r = n - k$ independent parity checks has exactly $q^k$ codewords.
- **Constraint satisfaction counting**: Each independent linear constraint over $\mathbb{F}_q$ eliminates exactly a $1/q$ fraction of solutions.
- **Secret sharing threshold**: In Shamir's scheme over $\mathbb{F}_q$, any $t-1$ shares leave $q$ equally likely secrets.

---

## Direction 3: Extension to Prime Power Fields $\mathbb{F}_{p^k}$

### Statement

The kernel density theorem holds for all finite fields $\mathbb{F}_{p^k}$, not just prime fields $\mathbb{F}_p$:

$$|\ker(f)| \cdot |\mathbb{F}_{p^k}| \leq |V|$$

for any nonzero linear map $f : V \to W$ over $\mathbb{F}_{p^k}$.

### Significance

Many applications (AES cryptography, Reed-Solomon codes, elliptic curve cryptography) work over extension fields $\mathbb{F}_{2^8}$, $\mathbb{F}_{2^{128}}$, etc. The prime-field restriction is an artifact of the formalization, not a mathematical limitation.

### Proof Strategy

The proof is mathematically identical. The challenge is formal: replace `[Fact q.Prime]` with `[Field F] [Fintype F]` and verify that all Mathlib lemmas used (`AddSubgroup.card_mul_index`, `LinearMap.quotKerEquivRange`, `FiniteField.pow_finrank_eq_card`) apply in this generality.

### Hypotheses to Test

- **H1**: The product formula holds over any finite field.
- **H2**: Mathlib's `FiniteField` class provides all necessary infrastructure.
- **H3**: The `Fact q.Prime` hypothesis can be fully eliminated.

### Technical Notes

The type `ZMod q` with `[Fact q.Prime]` gives a field instance. For prime powers, use `GaloisField p k` or abstract `[Field F] [Fintype F]`.

---

## Direction 4: Coding-Theoretic Bridge — Formal Linear Codes

### Statement

Define a **linear $[n, k]_q$ code** as a $k$-dimensional submodule $C \leq \mathbb{F}_q^n$, equivalently as $C = \ker(H)$ for a parity-check matrix $H$ of rank $n - k$. Derive:

1. $|C| = q^k$ (code size from product formula).
2. $R = k/n$ (code rate).
3. Singleton bound: $d \leq n - k + 1$ (minimum distance bound).
4. Plotkin bound for binary codes.

### Significance

This creates a formal bridge from abstract linear algebra to coding theory. Currently, coding theory in formal libraries is ad hoc; grounding it in the kernel density theorem provides a unified foundation.

### Proof Strategy

1. Define `LinearCode q n k` as a structure wrapping a `Submodule (ZMod q) (Fin n → ZMod q)` with a finrank hypothesis.
2. Prove cardinality using `card_kernel_mul_card_range`.
3. Define minimum distance and prove basic bounds using counting arguments.

### Deliverables

- `LinearCode` definition
- Code size theorem: $|C| = q^k$
- Hamming distance and minimum distance definitions
- Singleton bound proof
- Generator matrix / parity-check matrix duality

---

## Direction 5: Finite-Field Schwartz-Zippel for Degree 1

### Statement

For a nonzero degree-1 polynomial $P(x_1, \ldots, x_n) = a_1 x_1 + \cdots + a_n x_n + b$ over $\mathbb{F}_q$:

$$|\{x \in \mathbb{F}_q^n : P(x) = 0\}| \leq \frac{q^n}{q} = q^{n-1}$$

This is the degree-1 base case of the Schwartz-Zippel lemma.

### Significance

The Schwartz-Zippel lemma states that a nonzero polynomial of total degree $d$ over $\mathbb{F}_q$ vanishes on at most a fraction $d/q$ of inputs. The kernel density theorem is exactly the $d = 1$ case (for the homogeneous part; the affine case follows from fiber uniformity).

### Proof Strategy

- **Homogeneous case** ($b = 0$): Direct application of `nonzero_linear_map_kernel_density`.
- **Affine case** ($b \neq 0$): The zero set is a fiber $f^{-1}(\{-b\})$, which has size $|\ker(f)|$ by the affine fiber theorem (Direction 1).
- **Inductive step**: For degree $d > 1$, use the Schwartz-Zippel induction: fix one variable, apply the inductive hypothesis, and combine using union bounds.

### Cross-Domain Connections

- **Polynomial identity testing (PIT)**: The Schwartz-Zippel lemma is the foundation of randomized PIT. The kernel density theorem is its linear-algebraic core.
- **Circuit complexity**: PIT lower bounds (e.g., for depth-3 circuits) rely on Schwartz-Zippel. Formalizing the base case is a step toward formalizing these complexity-theoretic results.
- **Algebraic proof systems**: PCP and IOP protocols use Schwartz-Zippel for soundness. Formal verification of these protocols requires the base case.

---

## Research Methodology

### For each direction:

1. **State the theorem** precisely in Lean 4.
2. **Verify examples** computationally with `#eval` or Python.
3. **Check Mathlib coverage** for required building blocks.
4. **Build missing infrastructure** as reusable lemmas.
5. **Prove the theorem** using the subagent workflow.
6. **Write applications** that demonstrate the theorem's value.
7. **Document** with module-level docstrings and cross-references.

### Priority Order

1. Direction 2 (Multi-Constraint) — immediate from existing results, high value.
2. Direction 1 (Fiber Uniformity) — natural next step, needed for Direction 5.
3. Direction 3 (Prime Powers) — broadens applicability, moderate effort.
4. Direction 5 (Schwartz-Zippel) — high impact, depends on Directions 1-2.
5. Direction 4 (Coding Theory) — largest scope, builds on everything above.

### Team Directive

Each direction should be pursued by a team that:
- Validates the hypotheses computationally before attempting formal proofs.
- Builds the formal infrastructure bottom-up (definitions → lemmas → theorems).
- Maintains cross-references between directions.
- Documents all results for downstream reuse.
- Iterates on proof strategies, decomposing aggressively on failure.
