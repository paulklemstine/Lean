# Depth Rigidity for Iterated Exponentials in the Full EML Language with Inversions

## Abstract

We prove that the n-fold iterated exponential function `iterExp(n)` requires exponential nesting depth at least n in any expression built from input variables, positive constants, multiplication, inversion, and exponentiation over the positive reals. This extends the known depth hierarchy for inverse-free EML expressions to the full language with division, resolving the central question of whether cancellation identities involving reciprocals can compress exponential tower depth. Our proof introduces a novel semantic invariant — the **reciprocal envelope** — that bounds both a function and its reciprocal simultaneously, making the invariant inherently stable under inversion. The full proof is machine-verified in Lean 4 with Mathlib, yielding zero unresolved goals.

## 1. Introduction

### 1.1 Background and Motivation

The Exponential-Multiplicative Language (EML) is an expression language over the reals built from variables, constants, multiplication, and the combined operation `eml(a,b) = a · exp(b)`. Equivalently, one can work with a simplified positive-real fragment using `var`, `const`, `mul`, `inv`, and `exp` as primitives.

The **depth** of an EML expression counts the maximum number of nested exponentiations on any root-to-leaf path. The **depth hierarchy conjecture** asserts that the n-fold iterated exponential
```
iterExp(0, x) = x,    iterExp(n+1, x) = exp(iterExp(n, x))
```
requires depth at least n in any expression computing it exactly on positive reals.

For the inverse-free fragment (no `inv` nodes), this was established in prior work using one-sided asymptotic majorant arguments. However, the full language with inversions remained open because division introduces cancellation identities:
- `exp(f) · exp(-f) = 1`
- `exp(f) / exp(g) = exp(f - g)`
- `1/(1/f) = f`

These identities potentially allow depth reduction through algebraic manipulation.

### 1.2 Main Result

**Theorem (Depth Rigidity with Inversions).** Let `e` be an expression in `{var, const, mul, inv, exp}` with all positive constants. If `e.eval(x) = iterExp(n, x)` for all `x > 0`, then `depth(e) ≥ n`.

This is the strongest form of the depth rigidity theorem: it covers the full language with division and applies to expression trees (which subsume DAGs via unfolding).

### 1.3 Proof Overview

Our proof proceeds in three stages:

1. **Define the reciprocal envelope** (Section 3): a semantic invariant `HasReciprocalEnvelope(d, f)` asserting that for large x, both `f(x) ≤ iterExp(d, C·x^N)` and `1/f(x) ≤ iterExp(d, C·x^N)`.

2. **Prove structural stability** (Section 4): the reciprocal envelope is preserved by multiplication (at the same level), trivially preserved by inversion (swap the two bounds), and increased by exactly 1 under exponentiation.

3. **Prove separation** (Section 5): `iterExp(n)` does not have a reciprocal envelope at any level `d < n`, using the tower domination theorem.

## 2. Definitions and Notation

### 2.1 Iterated Exponential

```
iterExp : ℕ → ℝ → ℝ
iterExp 0 x = x
iterExp (n+1) x = exp(iterExp n x)
```

Key properties (all machine-verified):
- `iterExp n` is strictly monotone for all n
- `iterExp n x > 0` when `x > 0`
- `iterExp k (iterExp m x) = iterExp (k+m) x`
- For n ≥ 1 and x ≥ 0: `iterExp n x ≥ 1`

### 2.2 Positive-Real Expression Language

```
PosExpr ::= var | const(c) | mul(a, b) | inv(a) | exp(a)
```

Evaluation:
```
eval(var, x) = x
eval(const(c), x) = c
eval(mul(a,b), x) = eval(a,x) · eval(b,x)
eval(inv(a), x) = 1/eval(a,x)
eval(exp(a), x) = exp(eval(a,x))
```

Depth:
```
depth(var) = depth(const) = 0
depth(mul(a,b)) = max(depth(a), depth(b))
depth(inv(a)) = depth(a)
depth(exp(a)) = 1 + depth(a)
```

### 2.3 Reciprocal Envelope (Novel Definition)

**Definition.** A function `f : ℝ → ℝ` has a **reciprocal envelope at level d**, written `HasReciprocalEnvelope(d, f)`, if there exist `C > 0`, `N ∈ ℕ`, and `X₀ > 0` such that for all `x ≥ X₀`:
```
f(x) ≤ iterExp(d, C · x^N)   and   1/f(x) ≤ iterExp(d, C · x^N)
```

The two-sided nature of this bound is the key innovation. It makes the invariant self-dual under reciprocal: if `f` has envelope at level `d`, so does `1/f` — trivially, by swapping the two conjuncts.

## 3. Structural Lemmas

### 3.1 Positivity

**Theorem (eval_pos_of_posConsts).** If all constants in `e` are positive, then `e.eval(x) > 0` for all `x > 0`.

*Proof.* By structural induction. Products and exponentials of positive values are positive; the reciprocal of a positive value is positive. ∎

### 3.2 Envelope for Base Cases

**Lemma.** `HasReciprocalEnvelope(0, id)` and `HasReciprocalEnvelope(0, const(c))` for `c > 0`.

*Proof.* For `id`: take `C = 1, N = 1, X₀ = 1`. Then `x ≤ x` and `1/x ≤ 1 ≤ x` for `x ≥ 1`.
For `const(c)`: take `C = 1 + max(c, 1/c), N = 0, X₀ = 1`. ∎

### 3.3 Inversion Preserves Envelope

**Theorem (HasReciprocalEnvelope.inv).** If `HasReciprocalEnvelope(d, f)`, then `HasReciprocalEnvelope(d, 1/f)`.

*Proof.* Use the same witnesses `C, N, X₀`. The bounds `f(x) ≤ B` and `(f(x))⁻¹ ≤ B` become `(1/f(x)) ≤ B` and `(1/f(x))⁻¹ = f(x) ≤ B`. ∎

This is the conceptual heart of the argument: the reciprocal envelope is *defined* to be self-dual, so inversion is a trivial operation.

### 3.4 Tower Absorption

**Lemma (iterExp_mul_bound).** For `d ≥ 1` and `u, v ≥ 0`:
```
iterExp(d, u) · iterExp(d, v) ≤ iterExp(d, u + v + 1)
```

*Proof.* For `d = 1`: `exp(u) · exp(v) = exp(u+v) ≤ exp(u+v+1)`.
For `d ≥ 2`: use the sum absorption lemma `iterExp(d-1, u) + iterExp(d-1, v) ≤ iterExp(d-1, max(u,v) + 1)` (proved by induction using `2·exp(t) ≤ exp(t+1)` since `e ≥ 2`). ∎

### 3.5 Multiplication Preserves Envelope

**Theorem (HasReciprocalEnvelope.mul).** If `HasReciprocalEnvelope(d, f)` and `HasReciprocalEnvelope(d, g)` and both `f, g` are eventually positive, then `HasReciprocalEnvelope(d, f·g)`.

*Proof.* For `d = 0`: polynomial multiplication gives `(C₁·x^{N₁})(C₂·x^{N₂}) = C₁C₂·x^{N₁+N₂}`.
For `d ≥ 1`: use `iterExp_mul_bound` and monotonicity of `iterExp(d)`. The reciprocal bound uses the same argument applied to `f⁻¹·g⁻¹`. ∎

### 3.6 Exponentiation Increases Envelope

**Theorem (HasReciprocalEnvelope.exp_comp).** If `HasReciprocalEnvelope(d, f)` and `f` is eventually positive, then `HasReciprocalEnvelope(d+1, exp ∘ f)`.

*Proof.* Upper bound: `exp(f(x)) ≤ exp(iterExp(d, C·x^N)) = iterExp(d+1, C·x^N)`.
Lower bound: since `f(x) > 0` for large x, `1/exp(f(x)) = exp(-f(x)) < 1 ≤ iterExp(d+1, C·x^N)`. ∎

## 4. Main Theorems

### 4.1 Envelope Theorem

**Theorem (hasReciprocalEnvelope_of_posConsts).** Every expression `e` with positive constants satisfies `HasReciprocalEnvelope(depth(e), e.eval)`.

*Proof.* By structural induction on `e`:
- `var`: §3.2
- `const(c)`: §3.2
- `mul(a,b)`: IH gives envelopes at `depth(a)` and `depth(b)`; monotonicity lifts both to `max(depth(a), depth(b)) = depth(mul(a,b))`; §3.5 gives the product envelope. Positivity from §3.1.
- `inv(a)`: IH gives envelope at `depth(a) = depth(inv(a))`; §3.3 gives the reciprocal envelope.
- `exp(a)`: IH gives envelope at `depth(a)`; §3.6 gives envelope at `depth(a)+1 = depth(exp(a))`. ∎

### 4.2 Separation Theorem

**Theorem (iterExp_no_low_envelope).** For `d < n`, `iterExp(n)` does not have a reciprocal envelope at level `d`.

*Proof.* Suppose `HasReciprocalEnvelope(d, iterExp(n))` with witnesses `C, N, X₀`. Then `iterExp(n, x) ≤ iterExp(d, C·x^N)` for `x ≥ X₀`. By `iterExp_poly_lt_iterExp_succ`, there exists `X₁` such that `iterExp(d, C·x^N) < iterExp(d+1, x)` for `x ≥ X₁`. Since `d+1 ≤ n`, level monotonicity gives `iterExp(d+1, x) ≤ iterExp(n, x)` for `x ≥ 0`. Combining: `iterExp(n, x) < iterExp(n, x)` for `x ≥ max(X₀, X₁)`. Contradiction. ∎

### 4.3 Depth Rigidity

**Theorem (iterExp_depth_rigidity_full).** If `e` has positive constants and computes `iterExp(n)` on positive reals, then `depth(e) ≥ n`.

*Proof.* Suppose `depth(e) < n`. By §4.1, `e.eval` has an envelope at level `depth(e)`. Since `e.eval = iterExp(n)` on `(0,∞)`, this transfers to an envelope for `iterExp(n)` at level `depth(e) < n`. This contradicts §4.2. ∎

## 5. Cross-Domain Connections

### 5.1 Compiler Optimization

**Theorem (compiler_cannot_compress_iterExp).** Any semantics-preserving optimizer `O` satisfies `depth(O(canonIterExp(n))) ≥ n`.

This formalizes an impossibility result for expression simplification with division.

### 5.2 Differential Algebra

The reciprocal envelope connects to the Liouvillian tower: the number of iterated logarithms needed to reduce a function to polynomial growth equals the depth (= growth rank = logTameIndex). This is formally captured by the `logTameIndex_eq_growthRank` theorem.

### 5.3 Circuit Complexity

The depth rigidity theorem is a lower bound for arithmetic circuits with division over the exponential basis `{×, ÷, exp}`. Such lower bounds are rare in algebraic complexity.

## 6. Computational Experiments

### 6.1 Exhaustive Search

We enumerate all expressions with size ≤ 7 and depth < n, evaluating at test points {0.1, 0.5, 1.0, 1.5, 2.0}. No expression of depth < n matches `iterExp(n)` at all test points, consistent with the theorem.

### 6.2 Inversion Stress Tests

We test specific cancellation attempts:
- `exp(exp(x)) · exp(x) / exp(x)`: simplifies to `exp(exp(x))`, depth 2 ≠ depth 3
- `1/(1/exp(exp(exp(x))))`: depth 3, consistent with theorem
- `exp(x · exp(x) / exp(x))`: depth 2, does not compute `iterExp(3)`

See `demo.py` for the full interactive demonstration.

### 6.3 Envelope Verification

We numerically verify reciprocal envelopes for small expressions at test points {1, 2, 3, 4, 5}, confirming that the envelope parameters (d, C, N) found by `find_envelope_parameters` satisfy both bounds.

## 7. Discussion

### 7.1 Significance

The depth rigidity theorem establishes that exponential tower depth is a **semantically meaningful** quantity, not a syntactic artifact. It survives the introduction of division — the most dangerous operation for asymptotic arguments — because the reciprocal envelope is designed to be self-dual.

### 7.2 Limitations

- The theorem applies to exact computation on all positive reals. Approximate computation or computation on a discrete set could potentially circumvent the lower bound.
- The expression language is restricted to `{var, const, mul, inv, exp}`. Adding `log` or `+` would require a different analysis.
- The proof is non-constructive in the sense that it uses classical logic (via proof by contradiction).

### 7.3 Comparison to Prior Work

The inverse-free depth hierarchy uses one-sided majorant bounds (`HasPolyTowerMajorant`). Our reciprocal envelope subsumes and generalizes this: for positive functions, the one-sided bound plus positivity implies the reciprocal envelope. The innovation is the two-sided formulation that trivializes inversion.

## 8. Future Work

1. **Addition:** Extend to the full field language `{+, ×, ÷, exp}`. Addition is harder because `exp(a) + exp(b)` cannot be written as `exp(something)` in general.

2. **Logarithms:** Add `log` as a primitive. The depth hierarchy should still hold because `log(exp(f)) = f` merely removes one exponential layer.

3. **DAG sharing:** Extend from trees to DAGs directly, without the tree-unfolding reduction.

4. **Approximate computation:** Establish depth lower bounds for approximate computation: if `|e.eval(x) - iterExp(n, x)| ≤ ε · iterExp(n, x)` for small ε, must `depth(e) ≥ n`?

5. **Differential characterization:** Connect the reciprocal envelope to the differential-algebraic complexity of functions, establishing a bridge to Liouvillian theory.

## 9. Formalization Details

The complete proof is formalized in Lean 4 with Mathlib in two files:
- `Pythagorean/DepthRigidityFull/Defs.lean` (~150 lines): definitions
- `Pythagorean/DepthRigidityFull/Theorems.lean` (~450 lines): proofs

Key statistics:
- 0 remaining `sorry` statements
- 3 standard axioms used: `propext`, `Classical.choice`, `Quot.sound`
- 20+ theorems and lemmas proved
- Novel definitions: `HasReciprocalEnvelope`, `PosExpr.logTameIndex`

## References

1. Richardson, D. "Some undecidable problems involving elementary functions of a real variable." *J. Symbolic Logic* 33(4), 1968.
2. Hopcroft, J. and Ullman, J. "Introduction to Automata Theory, Languages, and Computation." Addison-Wesley, 1979.
3. Strassen, V. "Algebraic Complexity Theory." In *Handbook of Theoretical Computer Science*, Vol. A, 1990.
4. The Mathlib Community. "Mathlib4." https://github.com/leanprover-community/mathlib4
