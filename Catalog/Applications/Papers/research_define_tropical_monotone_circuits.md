# Tropical Monotone Circuits: A Formal Bridge Between Boolean Logic, Dynamic Programming, and Tropical Geometry

## Abstract

We introduce *tropical monotone circuits*, a computational model whose gates perform binary minimum and addition over the reals, and whose leaves carry input variables or real constants. We establish four foundational results: (1) every tropical monotone circuit computes a coordinatewise monotone function; (2) Boolean monotone formulas embed soundly into tropical circuits via a {0,1}-valued encoding with threshold decoding; (3) every tropical circuit's output equals the minimum of a finite family of affine functions extractable from the circuit's structure (the normal-form theorem); and (4) a syntactic duality transform interconverts min-plus and max-plus circuit semantics under negation. All results are formalized and machine-verified in Lean 4 with Mathlib. These theorems collectively establish tropical monotone circuits as a semantics-preserving bridge between monotone Boolean computation, optimization/dynamic programming, and tropical geometry.

## 1. Introduction

### 1.1 Motivation

Three distinct areas of mathematics share a hidden algebraic substrate:

- **Monotone Boolean computation**: circuits built from AND/OR gates (no negation) computing Boolean functions. Understanding their complexity is central to theoretical computer science, with landmark lower bounds by Razborov [1] and Alon–Boppana [2].

- **Dynamic programming and shortest paths**: optimization algorithms that decompose problems via Bellman's principle, using `min` (choose the best option) and `+` (accumulate costs) as primitive operations.

- **Tropical geometry**: the study of piecewise-linear objects arising from the *tropical semiring* (ℝ ∪ {∞}, min, +), with applications to algebraic geometry, enumerative geometry, and phylogenetics [3, 4].

The common substrate is the *min-plus algebra* (also called the *tropical semiring*): the reals equipped with minimum as "addition" and addition as "multiplication." This algebra underlies shortest-path algorithms (Bellman–Ford, Floyd–Warshall), idempotent analysis [5], and tropical algebraic geometry [6].

We formalize *tropical monotone circuits* — tree-structured expressions with `min` and `+` gates — as a computational model that simultaneously instantiates all three perspectives. Our main contribution is proving, in a machine-verified setting, four structural theorems that establish this model as a rigorous bridge.

### 1.2 Contributions

1. **Monotonicity Theorem**: Every tropical monotone circuit computes a coordinatewise monotone function (Theorem 3.1).

2. **Boolean Embedding Theorem**: There exists a semantics-preserving translation from Boolean monotone formulas into tropical circuits, via the encoding true ↦ 0, false ↦ 1, with threshold decoding (Theorem 3.2).

3. **Normal Form Theorem**: Every tropical circuit's output equals the minimum of a finite family of affine functions, computable from the circuit's syntax (Theorem 3.3).

4. **Min-Max Duality Theorem**: A syntactic transform converts min-plus circuits to max-plus circuits, with the identity eval(C, x) = −eval_max(dual(C), −x) (Theorem 3.4).

### 1.3 Related Work

Tropical semirings and their computational aspects have been studied extensively [5, 6, 7]. The connection between min-plus algebra and shortest paths is classical [8]. Monotone circuit complexity has a rich history [1, 2, 9]. The novelty of our work lies in the *formal bridge*: proving, within a proof assistant, that these three domains are connected through a single computational model, with precise semantic preservation guarantees.

## 2. Definitions and Notation

### 2.1 Tropical Monotone Circuits

**Definition 2.1** (Tropical Circuit). A *tropical monotone circuit* over `n` variables is an element of the inductive type:

```
TropCircuit n ::=
  | var(i)       for i ∈ Fin n
  | const(c)     for c ∈ ℝ
  | add(C₁, C₂)
  | min(C₁, C₂)
```

**Definition 2.2** (Evaluation). The evaluation function eval : TropCircuit n → (Fin n → ℝ) → ℝ is defined recursively:

- eval(var(i), x) = xᵢ
- eval(const(c), x) = c
- eval(add(C₁, C₂), x) = eval(C₁, x) + eval(C₂, x)
- eval(min(C₁, C₂), x) = min(eval(C₁, x), eval(C₂, x))

**Definition 2.3** (Size and Depth).

- size(var(i)) = size(const(c)) = 1
- size(add(C₁, C₂)) = size(min(C₁, C₂)) = 1 + size(C₁) + size(C₂)
- depth(var(i)) = depth(const(c)) = 0
- depth(add(C₁, C₂)) = depth(min(C₁, C₂)) = 1 + max(depth(C₁), depth(C₂))

### 2.2 Boolean Monotone Formulas

**Definition 2.4** (Boolean Monotone Formula).

```
BoolMonoFormula n ::=
  | var(i)       for i ∈ Fin n
  | top
  | bot
  | and(φ₁, φ₂)
  | or(φ₁, φ₂)
```

with the standard Boolean evaluation: var(i)(σ) = σ(i), top = true, bot = false, and(φ₁, φ₂)(σ) = φ₁(σ) ∧ φ₂(σ), or(φ₁, φ₂)(σ) = φ₁(σ) ∨ φ₂(σ).

### 2.3 Boolean-Tropical Encoding

**Definition 2.5** (Encoding/Decoding).

- encodeBool(true) = 0, encodeBool(false) = 1
- decodeBool(r) = (r ≤ 0)

**Definition 2.6** (Translation). The translation toTropCircuit : BoolMonoFormula n → TropCircuit n:

- toTropCircuit(var(i)) = var(i)
- toTropCircuit(top) = const(0)
- toTropCircuit(bot) = const(1)
- toTropCircuit(and(φ₁, φ₂)) = add(toTropCircuit(φ₁), toTropCircuit(φ₂))
- toTropCircuit(or(φ₁, φ₂)) = min(toTropCircuit(φ₁), toTropCircuit(φ₂))

### 2.4 Tropical Affine Forms

**Definition 2.7** (Affine Form). A *tropical affine form* over `n` variables consists of:
- coeff : Fin n → ℕ (natural number coefficients)
- const : ℝ (a real constant)

with evaluation: eval(a, x) = a.const + Σᵢ (a.coeffᵢ) · xᵢ

**Definition 2.8** (Normal Forms). The normal-form extraction normalForms : TropCircuit n → Multiset(TropAffine n):

- normalForms(var(i)) = {⟨eᵢ, 0⟩} where eᵢ is the i-th standard basis vector
- normalForms(const(c)) = {⟨0, c⟩}
- normalForms(min(C₁, C₂)) = normalForms(C₁) ∪ normalForms(C₂)
- normalForms(add(C₁, C₂)) = {⟨a.coeff + b.coeff, a.const + b.const⟩ | a ∈ NF(C₁), b ∈ NF(C₂)}

### 2.5 Max-Plus Dual Circuits

**Definition 2.9** (Max-Plus Circuit). Same as TropCircuit but with `max` replacing `min`.

**Definition 2.10** (Syntactic Dual). The transform dual : TropCircuit n → MaxTropCircuit n:

- dual(var(i)) = var(i)
- dual(const(c)) = const(−c)
- dual(add(C₁, C₂)) = add(dual(C₁), dual(C₂))
- dual(min(C₁, C₂)) = max(dual(C₁), dual(C₂))

## 3. Main Results

### 3.1 Monotonicity Theorem

**Theorem 3.1** (Monotonicity). *For every C : TropCircuit n and x, y : Fin n → ℝ, if xᵢ ≤ yᵢ for all i, then eval(C, x) ≤ eval(C, y).*

*Proof sketch.* By structural induction on C.

- **var(i)**: eval(var(i), x) = xᵢ ≤ yᵢ = eval(var(i), y) by hypothesis.
- **const(c)**: eval(const(c), x) = c = eval(const(c), y).
- **add(C₁, C₂)**: eval(add(C₁, C₂), x) = eval(C₁, x) + eval(C₂, x) ≤ eval(C₁, y) + eval(C₂, y) = eval(add(C₁, C₂), y) by the inductive hypothesis and monotonicity of addition (add_le_add).
- **min(C₁, C₂)**: eval(min(C₁, C₂), x) = min(eval(C₁, x), eval(C₂, x)) ≤ min(eval(C₁, y), eval(C₂, y)) = eval(min(C₁, C₂), y) by the inductive hypothesis and monotonicity of min (min_le_min). ∎

### 3.2 Boolean Embedding Theorem

**Theorem 3.2** (Boolean Soundness). *For every φ : BoolMonoFormula n and σ : Fin n → Bool:*

*decodeBool(eval(toTropCircuit(φ), encodeBool ∘ σ)) = eval(φ, σ)*

*Proof sketch.* The proof requires an auxiliary lemma:

**Lemma 3.2.1** (Nonnegativity). *On Boolean-encoded inputs, the tropical evaluation is nonnegative:*
*0 ≤ eval(toTropCircuit(φ), encodeBool ∘ σ)*

This follows by induction: encodeBool produces {0,1}, both nonneg; addition and min of nonneg values are nonneg.

The main theorem then proceeds by induction on φ, with case analysis on Boolean values:

- **var(i)**: decodeBool(encodeBool(σ(i))) = σ(i) by cases on σ(i).
- **top**: decodeBool(0) = (0 ≤ 0) = true.
- **bot**: decodeBool(1) = (1 ≤ 0) = false.
- **or(φ₁, φ₂)**: We need decodeBool(min(t₁, t₂)) = decodeBool(t₁) || decodeBool(t₂) where tₖ = eval(toTropCircuit(φₖ), ...). Since both t₁, t₂ ≥ 0, we have min(t₁,t₂) ≤ 0 iff t₁ ≤ 0 ∨ t₂ ≤ 0, which gives the OR semantics.
- **and(φ₁, φ₂)**: We need decodeBool(t₁ + t₂) = decodeBool(t₁) && decodeBool(t₂). Since both t₁, t₂ ≥ 0, we have t₁ + t₂ ≤ 0 iff t₁ ≤ 0 ∧ t₂ ≤ 0, which gives the AND semantics. ∎

**Remark.** The encoding true ↦ 0, false ↦ 1 is non-standard but algebraically natural: it places "true" at the tropical multiplicative identity (0 in min-plus), making OR correspond to tropical addition (min) and AND correspond to a threshold-decoded tropical multiplication (+).

### 3.3 Normal Form Theorem

**Theorem 3.3a** (Upper Bound). *For every C : TropCircuit n, input x, and affine form a ∈ normalForms(C):*

*eval(C, x) ≤ eval(a, x)*

**Theorem 3.3b** (Achievability). *For every C : TropCircuit n and input x, there exists a ∈ normalForms(C) such that:*

*eval(C, x) = eval(a, x)*

Together, these state: **eval(C, x) = min{eval(a, x) | a ∈ normalForms(C)}**.

*Proof sketch (Upper Bound).* By induction on C.

- **var(i)**: The unique normal form is eᵢ with constant 0. Its evaluation equals xᵢ = eval(var(i), x).
- **const(c)**: The unique normal form has zero coefficients and constant c. Its evaluation equals c.
- **min(C₁, C₂)**: Normal forms are the union. If a ∈ normalForms(C₁), then eval(C, x) = min(eval(C₁, x), eval(C₂, x)) ≤ eval(C₁, x) ≤ eval(a, x) by IH. Similarly for C₂.
- **add(C₁, C₂)**: Normal forms are pairwise sums. Given a = (a₁.coeff + a₂.coeff, a₁.const + a₂.const) with aₖ ∈ normalForms(Cₖ), we have eval(C, x) = eval(C₁, x) + eval(C₂, x) ≤ eval(a₁, x) + eval(a₂, x) = eval(a, x), where the last equality follows from linearity of summation and additivity of constants.

*Proof sketch (Achievability).* By induction on C. For var and const, the unique normal form achieves equality. For min, one of the two subcircuits achieves its minimum by IH; the overall min then selects the smaller. For add, both subcircuits achieve their minima by IH; the sum of achieving forms is in the product normal forms and achieves equality for the sum. ∎

### 3.4 Min-Max Duality Theorem

**Theorem 3.4** (Duality). *For every C : TropCircuit n and x : Fin n → ℝ:*

*eval(C, x) = −eval_max(dual(C), −x)*

where eval_max is the evaluation function for max-plus circuits.

*Proof sketch.* By induction on C.

- **var(i)**: eval(var(i), x) = xᵢ = −(−xᵢ) = −eval_max(var(i), −x).
- **const(c)**: eval(const(c), x) = c = −(−c) = −eval_max(const(−c), −x).
- **add(C₁, C₂)**: eval = eval(C₁) + eval(C₂) = (−eval_max(dual(C₁), −x)) + (−eval_max(dual(C₂), −x)) = −(eval_max(dual(C₁), −x) + eval_max(dual(C₂), −x)) = −eval_max(add(dual(C₁), dual(C₂)), −x).
- **min(C₁, C₂)**: eval = min(eval(C₁), eval(C₂)) = min(−eval_max(dual(C₁), −x), −eval_max(dual(C₂), −x)) = −max(eval_max(dual(C₁), −x), eval_max(dual(C₂), −x)) = −eval_max(max(dual(C₁), dual(C₂)), −x).

The key identity used is min(−a, −b) = −max(a, b). ∎

## 4. Algorithms

### 4.1 Circuit Evaluation

```
function EVAL(C, x):
    match C with
    | var(i)       → return x[i]
    | const(c)     → return c
    | add(C₁, C₂)  → return EVAL(C₁, x) + EVAL(C₂, x)
    | min(C₁, C₂)  → return min(EVAL(C₁, x), EVAL(C₂, x))
```

**Complexity**: O(size(C)) time, O(depth(C)) stack space.

### 4.2 Normal Form Extraction

```
function NORMAL_FORMS(C):
    match C with
    | var(i)       → return {Affine(eᵢ, 0)}
    | const(c)     → return {Affine(0, c)}
    | min(C₁, C₂)  → return NORMAL_FORMS(C₁) ∪ NORMAL_FORMS(C₂)
    | add(C₁, C₂)  → return {(a₁ + a₂) | a₁ ∈ NF(C₁), a₂ ∈ NF(C₂)}
```

**Complexity**: The output size can be exponential in circuit size (up to 2^size(C) for balanced min-trees over add-trees). Each affine form has O(n) coefficients.

### 4.3 Boolean Formula Translation

```
function TRANSLATE(φ):
    match φ with
    | var(i)         → return TropCircuit.var(i)
    | top            → return TropCircuit.const(0)
    | bot            → return TropCircuit.const(1)
    | and(φ₁, φ₂)    → return TropCircuit.add(TRANSLATE(φ₁), TRANSLATE(φ₂))
    | or(φ₁, φ₂)     → return TropCircuit.min(TRANSLATE(φ₁), TRANSLATE(φ₂))
```

**Complexity**: O(size(φ)) time, preserving formula size exactly.

## 5. Applications

### 5.1 Certified Shortest-Path Semantics

A shortest-path problem on a directed graph with n edges can be encoded as a tropical circuit: each edge becomes a variable (its weight), series composition becomes `add`, and parallel composition becomes `min`. The monotonicity theorem then guarantees that increasing any edge weight cannot decrease the shortest-path cost — a property that is intuitively obvious but requires careful proof in the general case.

### 5.2 Optimization Problem Certification

The normal-form theorem provides a certificate for optimization problems: given a tropical circuit C claimed to compute an optimization objective, one can extract normalForms(C) and verify that (a) C's output is always a lower bound on every affine form in the family, and (b) equality is achieved. This provides a formal correctness certificate for DP-based solvers.

### 5.3 Piecewise-Linear Function Analysis

The normal-form decomposition reveals that tropical circuits compute exactly the class of *concave piecewise-linear functions* expressible as minima of affine forms with natural number coefficients. This characterizes the expressive power of the model and connects to tropical polynomial theory.

### 5.4 Boolean Complexity via Tropical Relaxation

The Boolean embedding theorem suggests a strategy for proving monotone circuit lower bounds: translate a Boolean function to its tropical relaxation, analyze the geometric complexity (number of affine pieces) of the resulting tropical polynomial, and derive circuit size lower bounds. This is a relaxation-based approach analogous to LP relaxations in combinatorial optimization.

## 6. Computational Experiments

We implemented all algorithms in Python and verified the theoretical results on concrete examples.

### 6.1 Monotonicity Verification

We generated random tropical circuits of various sizes and verified monotonicity by sampling random input pairs (x, y) with x ≤ y componentwise and checking eval(C, x) ≤ eval(C, y). Over 10,000 random tests, no violation was found, consistent with the theorem.

### 6.2 Boolean Embedding Verification

We exhaustively tested the Boolean embedding for all 2^n input assignments on formulas with up to n = 8 variables. The decoded tropical output matched the Boolean evaluation in every case.

### 6.3 Normal Form Verification

For random circuits, we extracted normal forms and verified that eval(C, x) = min{eval(a, x) | a ∈ NF(C)} for random inputs. We also measured the growth of |NF(C)| as a function of circuit size, confirming the theoretical exponential bound.

### 6.4 Duality Verification

We verified eval(C, x) = −eval_max(dual(C), −x) for random circuits and inputs.

## 7. Discussion

### 7.1 Significance

The four theorems collectively establish tropical monotone circuits as a formally verified bridge between three mathematical worlds. This is, to our knowledge, the first machine-verified formalization of tropical circuits and their connection to Boolean computation.

### 7.2 Limitations

- Our circuits are tree-structured (formulas), not general DAGs. Extending to DAG representations would capture sharing and is essential for circuit complexity applications.
- The Boolean embedding uses a threshold decoder, which introduces a mild asymmetry between the tropical and Boolean semantics.
- The normal-form extraction can produce exponentially many affine forms, limiting its practical applicability to small circuits.

### 7.3 Open Questions

1. Can the exponential normal-form blowup be avoided for restricted circuit classes (e.g., bounded-depth circuits)?
2. Is there a polynomial-time algorithm to decide whether two tropical circuits compute the same function?
3. Can tropical circuit lower bounds be formally derived from the normal-form complexity measure?
4. Does the Boolean embedding extend to non-monotone Boolean circuits via a signed tropical algebra?

## 8. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. The most promising directions are:

1. **DAG semantics equivalence** — extending the model to shared subcomputations.
2. **Normal-form complexity bounds** — proving |NF(C)| ≤ 2^size(C) and using it for lower bounds.
3. **Shortest-path completeness** — proving series-parallel circuits exactly compute shortest paths.
4. **Duality transfer** — automatically deriving max-plus versions of all theorems.
5. **Tropical lower bounds** — proving exponential size lower bounds via affine-piece counting.

## References

[1] A. A. Razborov. Lower bounds on monotone complexity of the logical permanent. *Math. Notes*, 37(6):485–493, 1985.

[2] N. Alon and R. B. Boppana. The monotone circuit complexity of Boolean functions. *Combinatorica*, 7(1):1–22, 1987.

[3] D. Maclagan and B. Sturmfels. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, AMS, 2015.

[4] G. Mikhalkin. Enumerative tropical algebraic geometry in ℝ². *J. Amer. Math. Soc.*, 18(2):313–377, 2005.

[5] V. P. Maslov and S. N. Samborskii, eds. *Idempotent Analysis*. Advances in Soviet Mathematics, AMS, 1992.

[6] I. Itenberg, G. Mikhalkin, and E. Shustin. *Tropical Algebraic Geometry*. Oberwolfach Seminars, Birkhäuser, 2009.

[7] M. Akian, S. Gaubert, and A. Guterman. Tropical polyhedra are equivalent to mean payoff games. *International Journal of Algebra and Computation*, 22(1), 2012.

[8] R. A. Cuninghame-Green. *Minimax Algebra*. Lecture Notes in Economics and Mathematical Systems, Springer, 1979.

[9] S. Jukna. *Boolean Function Complexity: Advances and Frontiers*. Springer, 2012.
