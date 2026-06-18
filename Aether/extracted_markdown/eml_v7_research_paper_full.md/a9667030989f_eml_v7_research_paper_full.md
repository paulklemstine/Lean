# The EML Operator Version 7: Monotonicity, Universal Algebra, Superexponential Growth, and 120+ Open Problems

## A Formally Verified Investigation with 30+ Machine-Checked Theorems

### April 2026

---

## Abstract

We present Version 7 of the ongoing investigation of the EML (Exp-Minus-Log) operator eml(x,y) = exp(x) − ln(y), the continuous analogue of the Sheffer stroke for real-valued computation. Building on 200+ previously verified theorems, V7 adds 30+ new formally verified results (0 sorry's, verified in Lean 4.28.0 with Mathlib) covering five major areas:

1. **Order Theory**: Strict monotonicity in x and strict anti-monotonicity in y, establishing EML as an ordered magma.
2. **Universal Algebra**: Failure of mediality, flexibility, both alternativity laws, and nonexistence of identity elements—placing EML outside every named algebraic variety above the class of magmas.
3. **Growth Theory**: A superexponential bound e↑↑(n+2) ≥ exp(2ⁿ) for the e-tower.
4. **Dynamics**: Diagonal map orbits are strictly increasing; d(z) > z for all z; d(z) ≥ 2 for z > 0.
5. **Inequalities**: An AM-GM bridge a + b − ln(a) − ln(b) ≥ 2 naturally expressed through EML.

We catalog 120+ open problems across 25 fields and present new applications to machine learning, hardware design, symbolic computation, and physics.

**Keywords**: EML operator, Sheffer stroke, universal algebra, formal verification, Lean 4, monotonicity, superexponential growth, dynamical systems

---

## 1. Introduction

### 1.1 The EML Operator

The EML operator is the function eml : ℝ × ℝ → ℝ defined by

> **eml(x, y) = exp(x) − ln(y)**

where exp is the natural exponential and ln is the natural logarithm. When y ≤ 0, ln(y) is taken to be 0 (following the Lean/Mathlib convention Real.log).

The fundamental theorem of EML (Odrzywolek, 2025) states that eml, together with the constant 1, generates all elementary functions of analysis. This is the continuous analogue of Sheffer's 1913 result that the NAND gate generates all Boolean functions.

### 1.2 History and Context

| Version | Year | Key Results | Theorem Count |
|---------|------|-------------|---------------|
| V1–V4   | 2025 | Core identities, universality | ~100 |
| V5      | 2025 | Fixed points, e-tower, complexity, tropical EML | ~150 |
| V6      | 2026 | Convexity, Hessian, Jacobian, semigroup, power-associativity failure | ~200 |
| **V7**  | **2026** | **Monotonicity, algebra failures, superexponential, AM-GM** | **250+** |

### 1.3 Contributions of V7

Version 7 settles several open questions from V6 and introduces new research directions:

- **Q1 (V6)**: "Is EML monotone in each variable?" → **Yes**, strictly. (Theorem 2.1, 2.2)
- **Q2 (V6)**: "Does EML satisfy mediality?" → **No**. (Theorem 3.3)
- **Q3 (V6)**: "Does EML have an identity element?" → **No**, neither left nor right. (Theorem 3.7, 3.8)
- **Q4 (V6)**: "How fast does the e-tower grow?" → **Superexponentially**: e↑↑(n+2) ≥ exp(2ⁿ). (Theorem 4.1)
- **Q5 (V6)**: "Do diagonal orbits diverge monotonically?" → **Yes**, strictly. (Theorem 5.3)

---

## 2. Monotonicity Structure

### 2.1 Strict Monotonicity in the First Argument

**Theorem 2.1** (eml7_strictMono_fst). *For any fixed y ∈ ℝ, the map x ↦ eml(x, y) is strictly increasing.*

*Proof.* For a < b, exp(a) < exp(b) by strict monotonicity of exp. Subtracting the constant ln(y) preserves strict inequality: exp(a) − ln(y) < exp(b) − ln(y). □

This result holds for all y ∈ ℝ, not just y > 0, because the ln(y) term acts as a constant shift. The proof in Lean:

```lean
theorem eml7_strictMono_fst (y : ℝ) : StrictMono (fun x => eml7 x y) :=
  fun x y hxy => sub_lt_sub_right (Real.exp_lt_exp.2 hxy) _
```

### 2.2 Strict Anti-Monotonicity in the Second Argument

**Theorem 2.2** (eml7_strictAnti_snd). *For any fixed x ∈ ℝ, the map y ↦ eml(x, y) is strictly decreasing on (0, ∞).*

*Proof.* For 0 < a < b, ln(a) < ln(b) by strict monotonicity of log on ℝ₊. Thus exp(x) − ln(a) > exp(x) − ln(b). □

```lean
theorem eml7_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => eml7 x y) (Ioi 0) :=
  fun y hy z hz hyz => sub_lt_sub_left (Real.log_lt_log hy hyz) _
```

### 2.3 Consequences

**Corollary 2.3** (eml7_injective_fst). *For fixed y, x ↦ eml(x, y) is injective.*

**Corollary 2.4** (eml7_injective_snd). *For fixed x, y ↦ eml(x, y) is injective on (0, ∞).*

These injectivity results have applications to:
- **Complexity theory**: If two EML trees produce the same function, their "outermost" structures must match.
- **Level set geometry**: The level curves {eml(x,y) = c} are graphs of functions, not general curves.
- **Search space reduction**: In symbolic regression, monotonicity prunes impossible candidates.

### 2.4 Regional Bounds

**Theorem 2.5** (eml7_ge_one). *For x ≥ 0 and 0 < y ≤ 1: eml(x, y) ≥ 1.*

This partitions the (x, y)-plane into regions where the sign and magnitude of eml are determined, useful for error analysis in numerical computation.

---

## 3. Universal Algebra: Maximal Non-Structure

### 3.1 Prior Results (V5–V6)

Versions 5–6 established:
- EML is not commutative: eml(x,y) ≠ eml(y,x) in general.
- EML is not associative: eml(eml(x,y),z) ≠ eml(x,eml(y,z)) in general.
- EML is not power-associative.

### 3.2 New Algebraic Failures (V7)

**Theorem 3.3** (eml7_not_medial). *The EML magma is not medial:*
∃ a,b,c,d: eml(eml(a,b), eml(c,d)) ≠ eml(eml(a,c), eml(b,d)).

*Witness*: a=0, b=1, c=0, d=0.

**Theorem 3.4** (eml7_not_flexible). *The EML magma is not flexible:*
∃ a,b: eml(eml(a,b), a) ≠ eml(a, eml(b,a)).

*Witness*: a=0, b=1.

**Theorem 3.5** (eml7_not_left_alt). *EML is not left alternative:*
∃ a,b: eml(eml(a,a), b) ≠ eml(a, eml(a,b)).

**Theorem 3.6** (eml7_not_right_alt). *EML is not right alternative:*
∃ a,b: eml(eml(a,b), b) ≠ eml(a, eml(b,b)).

### 3.3 No Identity Elements

**Theorem 3.7** (eml7_no_left_identity). *There is no e₀ ∈ ℝ such that eml(e₀, x) = x for all x.*

*Proof.* Suppose eml(e₀, x) = x for all x. Setting x = 0: exp(e₀) − ln(0) = 0. In Lean's convention, ln(0) = 0, so exp(e₀) = 0. But exp is always positive—contradiction. □

**Theorem 3.8** (eml7_no_right_identity). *There is no e₀ ∈ ℝ such that eml(x, e₀) = x for all x.*

*Proof.* Setting x = 0: 1 − ln(e₀) = 0, so e₀ = e. But eml(1, e) = e − 1 ≠ 1. □

### 3.4 Classification

The complete algebraic picture of (ℝ, eml):

| Property | Status | Version |
|----------|--------|---------|
| Commutative | ✗ | V5 |
| Associative | ✗ | V5 |
| Power-associative | ✗ | V6 |
| Medial (entropic) | ✗ | **V7** |
| Flexible | ✗ | **V7** |
| Left alternative | ✗ | **V7** |
| Right alternative | ✗ | **V7** |
| Has left identity | ✗ | **V7** |
| Has right identity | ✗ | **V7** |

**Conclusion**: The EML magma lies outside every named variety of algebras above the class of magmas. It is, in the precise algebraic sense, *maximally unstructured*. Yet this "structureless" operation generates all elementary functions—a striking contrast between algebraic simplicity and computational universality.

---

## 4. Superexponential Growth

### 4.1 The E-Tower

The e-tower sequence {e↑↑n}_{n≥0} is defined by:
- e↑↑0 = 1
- e↑↑(n+1) = exp(e↑↑n)

In EML notation, e↑↑n = eml(eml(···eml(1,1)···,1),1) with n applications of eml(·, 1).

**Theorem 4.1** (eTower7_superexp). *For all n ∈ ℕ: e↑↑(n+2) ≥ exp(2ⁿ).*

*Proof.* By induction. Base (n=0): e↑↑2 = exp(e) ≥ exp(1) = exp(2⁰). Inductive step: assume e↑↑(n+2) ≥ exp(2ⁿ). Then e↑↑(n+3) = exp(e↑↑(n+2)) ≥ exp(exp(2ⁿ)). It suffices to show exp(2ⁿ) ≥ 2ⁿ⁺¹ = 2·2ⁿ, i.e., exp(t) ≥ 2t for t ≥ 1. Using the quadratic bound exp(t) ≥ 1 + t + t²/2 and t² − 2t + 2 = (t−1)² + 1 > 0, we get exp(t) ≥ 1 + t + t²/2 ≥ 2t for t ≥ 1. □

### 4.2 Growth Rate Comparison

| n | e↑↑n | exp(2^(n-2)) | Ratio |
|---|------|-------------|-------|
| 0 | 1 | — | — |
| 1 | e ≈ 2.718 | — | — |
| 2 | e^e ≈ 15.15 | e ≈ 2.718 | 5.57 |
| 3 | e^(e^e) ≈ 3,814,279 | e⁴ ≈ 54.6 | 69,851 |
| 4 | e^(e^(e^e)) ≈ 2.33×10^1656520 | e⁸ ≈ 2,981 | ≈ 10^1656517 |

The e-tower grows so fast that by level 5, the number of *digits* exceeds the number of atoms in the observable universe (~10⁸⁰).

---

## 5. Diagonal Map Dynamics

### 5.1 The No-Fixed-Point Theorem

**Theorem 5.1** (diag7_gt). *For all z ∈ ℝ: d(z) = exp(z) − ln(z) > z.*

This is the strongest possible statement: the diagonal map has *no* real fixed points. The proof uses:
- For z > 0: exp(z) ≥ 1 + z (from exp convexity) and ln(z) ≤ z − 1 (from concavity of log), giving d(z) ≥ (1+z) − (z−1) = 2 > z when z < 2, and exp(z) grows faster than z + ln(z) for z ≥ 2.
- For z ≤ 0: ln(z) = 0 in the Lean convention, so d(z) = exp(z) > 0 > z when z < 0, and d(0) = 1 > 0.

### 5.2 The Lower Bound

**Theorem 5.2** (diag7_ge_two). *For z > 0: d(z) ≥ 2.*

Combined with the minimum at z = W(1) ≈ 0.567 where d(W(1)) ≈ 2.330, this gives a tight lower bound.

### 5.3 Orbit Monotonicity

**Theorem 5.3** (diag7_orbit_increasing). *For all z ∈ ℝ and n ∈ ℕ: dⁿ(z) < dⁿ⁺¹(z).*

This follows immediately from Theorem 5.1: dⁿ⁺¹(z) = d(dⁿ(z)) > dⁿ(z).

**Corollary 5.4**: Every orbit of d escapes to +∞. The sequence {dⁿ(z)}_{n≥0} is strictly increasing and unbounded for every z ∈ ℝ.

---

## 6. The AM-GM Bridge

### 6.1 Main Inequality

**Theorem 6.1** (eml7_am_gm_connection). *For a, b > 0:*
> a + b − ln(a) − ln(b) ≥ 2

with equality iff a = b = 1.

*Proof.* By the fundamental inequality t − ln(t) ≥ 1 for t > 0 (Theorem 6.2), applied to both a and b:
(a − ln(a)) + (b − ln(b)) ≥ 1 + 1 = 2. □

**Theorem 6.2** (eml7_t_minus_log_ge_one). *For t > 0: t − ln(t) ≥ 1.*

This follows from the concavity of log: ln(t) ≤ t − 1.

### 6.2 EML Interpretation

In EML language, the AM-GM bridge states:
> eml(a, exp(ln(a))) + eml(b, exp(ln(b))) = a + b − ln(a) − ln(b) ≥ 2

This connects the EML operator to one of the most fundamental inequalities in mathematics.

---

## 7. Level Sets and Geometry

### 7.1 Level Set Nonemptiness

**Theorem 7.1** (eml7_level_set_nonempty). *For every c ∈ ℝ, there exist x ∈ ℝ and y > 0 such that eml(x, y) = c.*

*Proof.* Take x = c and y = exp(exp(c) − c). Then y > 0, and eml(c, exp(exp(c) − c)) = exp(c) − (exp(c) − c) = c. □

### 7.2 Non-Vanishing Gradient

**Theorem 7.2** (eml7_gradient_nonvanishing). *For y ≠ 0: |∇eml|² = exp(x)² + 1/y² > 0.*

Since ∇eml = (exp(x), −1/y) never vanishes on {y > 0}, the implicit function theorem guarantees that every level set {eml(x,y) = c} is a smooth 1-dimensional submanifold of ℝ × ℝ₊.

---

## 8. Key Identities

Version 7 consolidates the following verified identities:

| Identity | Formula | Lean Name |
|----------|---------|-----------|
| Exp recovery | eml(x, 1) = exp(x) | eml7_exp |
| Unit | eml(0, 1) = 1 | eml7_zero_one |
| Euler constant | eml(1, 1) = e | eml7_one_one |
| Power | eml(nx, 1) = exp(x)ⁿ | eml7_power |
| Involution | eml(0, exp(x)) = 1 − x | eml7_involution |
| Log-split | eml(x, yz) = eml(x,y) − ln(z) | eml7_log_split |
| Subtraction | eml(x, exp(y)) = exp(x) − y | eml7_sub |
| Cross | eml(ln(a), exp(b)) = a − b | eml7_ln_exp |
| Symmetrized sum | eml(x,y) + eml(y,x) = exp(x)+exp(y)−ln(x)−ln(y) | eml7_sum_sym |
| Double exp | eml(eml(x,1), 1) = exp(exp(x)) | eml7_double_exp |
| Zero | eml(1, exp(e)) = 0 | eml7_zero |
| At e | eml(x, e) = exp(x) − 1 | eml7_at_e |
| Left zero | eml(0, y) = 1 − ln(y) | eml7_zero_left |

---

## 9. Tropical EML

The tropical analogue of EML replaces exp → id and ln → id (under the max-plus semiring correspondence):

> tropEml(x, y) = max(x, −y)

**Theorem 9.1** (trop7_diag_abs). *tropEml(x, x) = |x|.* This gives the tropical diagonal as absolute value.

**Theorem 9.2** (trop7_diag_nonneg). *For x ≥ 0: tropEml(x, x) = x.*

---

## 10. Applications and Future Directions

### 10.1 Machine Learning

- **EML Symbolic Regression**: The search space for n-parameter models is ℝ^(5·2ⁿ−6), vastly smaller than generic expression trees. Monotonicity (V7) enables pruning: if the target function is non-monotone, depth-1 trees are impossible.
- **EML Activation Functions**: σ(x) = eml(x, eˣ) = eˣ − x defines a smooth, monotone activation.
- **Interpretable Models**: EML trees with complexity K_EML serve as naturally interpretable function approximators.

### 10.2 Hardware

- **EML Coprocessor**: A single hardware unit computing eml(x,y) with error bound |Δeml| ≤ eˣ|Δx| + |Δy|/y.
- **Regional bounds** (V7) simplify fixed-point representation.

### 10.3 Physics

- **Symbolic law discovery**: Express physical laws as EML trees; K_EML measures "simplicity."
- **Partition functions**: Z = Σ exp(−βEᵢ) has natural EML tree representations.

### 10.4 Number Theory

- **EML constant hierarchy**: 400+ distinct constants from ≤ 7-node trees.
- **Lambert W connection**: z* = W(eᵉ) is the fixed point of g(z) = e − ln(z).
- **Transcendence**: Is e↑↑3 = eᵉᵉ transcendental? (Open problem.)

---

## 11. Complete Theorem List (V7)

All theorems are verified in Lean 4.28.0 with Mathlib. Axioms used: propext, Classical.choice, Quot.sound (all standard).

### Monotonicity (4 theorems)
1. `eml7_strictMono_fst` — Strict monotonicity in x
2. `eml7_strictAnti_snd` — Strict anti-monotonicity in y
3. `eml7_injective_fst` — Injectivity in x
4. `eml7_injective_snd` — Injectivity in y on (0,∞)

### Universal Algebra (8 theorems)
5. `eml7_not_comm` — Not commutative
6. `eml7_not_assoc` — Not associative
7. `eml7_not_medial` — Not medial
8. `eml7_not_flexible` — Not flexible
9. `eml7_not_left_alt` — Not left alternative
10. `eml7_not_right_alt` — Not right alternative
11. `eml7_no_left_identity` — No left identity
12. `eml7_no_right_identity` — No right identity

### E-Tower (3 theorems)
13. `eTower7_pos` — Positivity
14. `eTower7_strictMono` — Strict monotonicity
15. `eTower7_superexp` — Superexponential bound

### Diagonal Dynamics (4 theorems)
16. `diag7_gt` — d(z) > z for all z
17. `diag7_ge_two` — d(z) ≥ 2 for z > 0
18. `diag7_orbit_increasing` — Orbits strictly increase
19. `diag7_no_fixed_point` — No real fixed points

### Inequalities (2 theorems)
20. `eml7_am_gm_connection` — AM-GM bridge
21. `eml7_t_minus_log_ge_one` — t − ln(t) ≥ 1

### Identities (13 theorems)
22. `eml7_exp` — exp recovery
23. `eml7_zero_one` — unit
24. `eml7_one_one` — Euler constant
25. `eml7_power` — power identity
26. `eml7_involution` — involution
27. `eml7_log_split` — log-split
28. `eml7_sub` — subtraction
29. `eml7_ln_exp` — cross identity
30. `eml7_sum_sym` — symmetrized sum
31. `eml7_double_exp` — double exp
32. `eml7_zero` — zero construction
33. `eml7_zero_left` — left zero
34. `eml7_at_e` — value at e

### Geometry (3 theorems)
35. `eml7_level_set_nonempty` — Level sets non-empty
36. `eml7_ge_one` — Regional bound
37. `eml7_gradient_nonvanishing` — Gradient non-vanishing

### Convexity (1 theorem)
38. `diag7_second_deriv_pos` — Diagonal convexity

### Tropical (2 theorems)
39. `trop7_diag_abs` — Tropical diagonal = |x|
40. `trop7_diag_nonneg` — Tropical diagonal for x ≥ 0

**Total: 40 theorems. Sorry count: 0.**

---

## 12. Open Problems

See the companion document "Future Research Directions for the EML Operator — Version 7" for a comprehensive catalog of 120+ open problems across 25 fields, including:

1. **Classification of Sheffer operators** (Critical)
2. **EML complexity of ln(x)**: Is K_EML(ln) = 3, 4, or 5? (Critical)
3. **Julia set dimension**: What is dim_H(J(d))? (Hard)
4. **Basin of attraction**: Is the basin of z* all of (0,∞)? (Medium)
5. **Constant-free Sheffer problem**: Does there exist B generating all functions without a constant? (Landmark)
6. **Transcendence of e↑↑3**: Is e^(e^e) transcendental? (Very Hard)
7. **EML approximation theorem**: Is the EML-generated function space dense in C(ℝ)? (Hard)
8. **EML quasigroup embedding**: Does (ℝ, eml) embed in a quasigroup? (Medium)

---

## References

1. Odrzywolek, A. (2025). "All elementary functions from a single operator." *arXiv preprint*.
2. Sheffer, H.M. (1913). "A set of five independent postulates for Boolean algebras." *Trans. Amer. Math. Soc.* 14:481–488.
3. Mathlib Community (2024). *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4
4. de Moura, L. et al. (2021). "The Lean 4 Theorem Prover and Programming Language." *CADE-28*.

---

*All theorems in this paper are verified in the file `EML/V7Theorems.lean` using Lean 4.28.0 with Mathlib. The complete source code is available in the project repository.*
