# Strict Hierarchy Separation for the Hardy Growth Hierarchy: A Complete Classification via Exponential Growth Bounds

## Abstract

We establish a strict separation theorem for the Hardy growth hierarchy at every finite level. The Hardy hierarchy stratifies real-valued functions by exponential nesting depth: level 0 contains polynomials, and each application of the operation eml(a, b) = a · exp(b) raises the level by one. We prove that for every n ≥ 0, the (n+1)-fold iterated exponential does not belong to Hardy level n, establishing that the hierarchy is strict and that the depth invariant is sharp. The proof rests on a new quantitative bound: every level-n function f satisfies |f(x)| ≤ exp(C · iterExp(n, x)) eventually, for any C > 0. This "universal ceiling" theorem is proved by structural induction on the HardyLevel derivation and is closed under all constructors including multiplication and the exp-step. All results are formalized and machine-verified.

## 1. Introduction

### 1.1 Background

The study of growth rate hierarchies has a long history, beginning with du Bois-Reymond's work on orders of infinity in the 1870s and Hardy's systematic classification of logarithmico-exponential functions [Hardy 1910]. Modern applications span proof theory (ordinal-indexed fast-growing hierarchies), computational complexity (time and space hierarchies), and asymptotic analysis.

### 1.2 The Hardy Level Hierarchy

We work with a syntactic-semantic hierarchy defined inductively:

**Definition (HardyLevel).** The predicate HardyLevel : ℕ → (ℝ → ℝ) → Prop is defined inductively by:
1. `base_id`: HardyLevel 0 (fun x ↦ x)
2. `base_const c`: HardyLevel 0 (fun _ ↦ c)
3. `add`: HardyLevel n f → HardyLevel n g → HardyLevel n (fun x ↦ f x + g x)
4. `mul`: HardyLevel n f → HardyLevel n g → HardyLevel n (fun x ↦ f x · g x)
5. `exp_step`: HardyLevel n f → HardyLevel n g → HardyLevel (n+1) (fun x ↦ f x · exp(g x))
6. `congr`: HardyLevel n f → EventuallyEq f g → HardyLevel n g

**Definition (iterExp).** The n-fold iterated exponential:
- iterExp 0 x = x
- iterExp (n+1) x = exp(iterExp n x)

### 1.3 Prior Work

The following results were previously established:
- `iterExp_mem_hardyLevel`: iterExp n ∈ HardyLevel n (membership)
- `hardyLevel_zero_poly_bound`: Level-0 functions have polynomial growth
- `exp_not_hardyLevel_zero`: exp ∉ HardyLevel 0 (base separation)
- `hardyLevel_mono`: HardyLevel m f → m ≤ n → HardyLevel n f (monotonicity)

The general separation conjecture — ∀ n ≥ 1, iterExp n ∉ HardyLevel (n-1) — was stated but unproved.

### 1.4 Contributions

We prove:

1. **Universal Growth Ceiling (Theorem 3.1)**: For HardyLevel n f and any C > 0, eventually |f x| ≤ exp(C · iterExp n x).

2. **Strict Separation (Theorem 4.1)**: For all n, ¬ HardyLevel n (iterExp (n+1)).

3. **Exact Hardy Rank (Theorem 4.3)**: iterExp n has Hardy rank exactly n.

4. **Eventual Domination Bound (Corollary 3.2)**: Every level-n function is eventually bounded by iterExp(n+1).

5. **Asymptotic Lower Bound (Theorem 4.4)**: No level-n function eventually dominates iterExp(n+1).

## 2. Definitions and Notation

### 2.1 New Definitions

**EventuallyStrictlySmaller(f, g)**: ∃ N, ∀ x ≥ N, f(x) < g(x).

**HardyRankWitness n f**: f ∈ HardyLevel n ∧ (n = 0 ∨ f ∉ HardyLevel (n-1)). Packages exact rank.

**IsLevelMajorizedBy n f**: ∃ g ∈ HardyLevel n, ∃ C N, ∀ x ≥ N, |f x| ≤ C · |g x|. Asymptotic representability.

### 2.2 Auxiliary Results

**Lemma 2.1 (iterExp_tendsto_atTop)**: For all n, iterExp n → +∞ as x → +∞.

*Proof*: By induction on n. Base: iterExp 0 = id. Step: iterExp (n+1) = exp ∘ iterExp n, composition of two functions tending to +∞.

**Lemma 2.2 (exp_sub_linear_bound)**: For C₁ ∈ ℝ and C₂ < 1, eventually C₁ · t + exp(C₂ · t) ≤ exp(t).

*Proof*: Split into two halves. For the linear term: C₁ · t ≤ ½ · exp(t) since t/exp(t) → 0. For the exponential term: exp(C₂ · t) ≤ ½ · exp(t) since exp((C₂ - 1) · t) → 0 (as C₂ - 1 < 0).

**Lemma 2.3 (exp_step_bound_pulled_back)**: For D < 1 and C > 0, eventually D · iterExp(n, x) + exp(D · iterExp(n, x)) ≤ C · exp(iterExp(n, x)).

*Proof*: The ratio (D · t + exp(D · t)) / (C · exp(t)) → 0 as t → ∞ (since D < 1 makes exp((D-1)t) → 0 and D · t / exp(t) → 0). Pull back through iterExp n using Lemma 2.1.

## 3. The Universal Growth Ceiling

### 3.1 Main Theorem

**Theorem 3.1 (hardyLevel_exp_growth_bound)**: *For HardyLevel n f and any C > 0, there exists N such that for all x ≥ N, |f(x)| ≤ exp(C · iterExp(n, x)).*

**Proof**: By structural induction on the HardyLevel derivation.

**Case base_id (f(x) = x, n = 0)**: Need |x| ≤ exp(C · x). Since x/exp(Cx) → 0 as x → ∞, this holds eventually.

**Case base_const c (f(x) = c, n = 0)**: Need |c| ≤ exp(C · x). Since exp(Cx) → ∞, this holds eventually.

**Case add**: Given HardyLevel n f, HardyLevel n g, and the IH for both. Apply IH with C/2: eventually |f(x)| ≤ exp(C/2 · t) and |g(x)| ≤ exp(C/2 · t) where t = iterExp(n, x). Then |f(x) + g(x)| ≤ 2 · exp(C/2 · t). Since t → ∞, eventually 2 ≤ exp(C/2 · t), so 2 · exp(C/2 · t) ≤ exp(C/2 · t + C/2 · t) = exp(C · t). ∎

**Case mul**: Apply IH with C/2 for both factors. Then |f · g| ≤ exp(C/2 · t) · exp(C/2 · t) = exp(C · t). ∎

**Case exp_step**: This is the crux. We have HardyLevel n f, HardyLevel n g, and need to bound |f(x) · exp(g(x))| ≤ exp(C · iterExp(n+1, x)) = exp(C · exp(t)).

Choose D = min(C, 1)/4. Then D > 0 and D < 1. By IH on f with D: eventually |f(x)| ≤ exp(D · t). By IH on g with D: eventually |g(x)| ≤ exp(D · t), so g(x) ≤ |g(x)| ≤ exp(D · t) and exp(g(x)) ≤ exp(exp(D · t)).

Therefore: |f(x) · exp(g(x))| ≤ exp(D · t) · exp(exp(D · t)) = exp(D · t + exp(D · t)).

By Lemma 2.3: eventually D · t + exp(D · t) ≤ C · exp(t). Hence exp(D · t + exp(D · t)) ≤ exp(C · exp(t)) = exp(C · iterExp(n+1, x)). ∎

**Case congr**: By IH on f: eventually |f(x)| ≤ exp(C · iterExp(n, x)). By eventual equality: eventually |g(x)| = |f(x)|. Combine. ∎

### 3.2 Corollary

**Corollary 3.2 (hardyLevel_n_bounded_by_iterExp_succ)**: *HardyLevel n f implies ∃ A C, ∀ x ≥ A, |f(x)| ≤ C · iterExp(n+1, x).*

*Proof*: Apply Theorem 3.1 with C = 1. Then |f(x)| ≤ exp(iterExp(n, x)) = iterExp(n+1, x). Take A = N, C = 1.

## 4. Strict Separation

### 4.1 The Separation Theorem

**Theorem 4.1 (iterExp_succ_not_hardyLevel)**: *For all n ≥ 0, ¬ HardyLevel n (iterExp(n+1)).*

**Proof**: Assume HardyLevel n (iterExp(n+1)). By Theorem 3.1 with C = 1/2: eventually |iterExp(n+1, x)| ≤ exp(½ · iterExp(n, x)). Since iterExp(n+1, x) = exp(iterExp(n, x)) > 0, we have |iterExp(n+1, x)| = exp(iterExp(n, x)). So:

exp(iterExp(n, x)) ≤ exp(½ · iterExp(n, x))

By strict monotonicity of exp: iterExp(n, x) ≤ ½ · iterExp(n, x). But by Lemma 2.1, iterExp(n, x) → ∞, so eventually iterExp(n, x) > 0, giving ½ · iterExp(n, x) > 0 and iterExp(n, x) > ½ · iterExp(n, x). Contradiction. ∎

**Theorem 4.2 (iterExp_not_mem_lower_hardyLevel)**: *For n ≥ 1, ¬ HardyLevel(n-1)(iterExp n).*

*Proof*: Write n = m + 1. Then n - 1 = m and iterExp n = iterExp(m+1). Apply Theorem 4.1.

### 4.2 Exact Rank

**Theorem 4.3 (iterExp_hasHardyRank)**: *HasHardyRank (iterExp n) n, i.e., iterExp n ∈ HardyLevel n and ∀ e < n, iterExp n ∉ HardyLevel e.*

*Proof*: Membership: iterExp_mem_hardyLevel n. Non-membership: for e < n, if HardyLevel e (iterExp n), then by monotonicity HardyLevel (n-1) (iterExp n), contradicting Theorem 4.2.

### 4.3 Asymptotic Lower Bound

**Theorem 4.4 (no_lower_depth_majorization_of_iterExp)**: *¬ ∃ f, HardyLevel n f ∧ EventuallyDominates f (iterExp(n+1)).*

*Proof*: If f eventually dominates iterExp(n+1), then iterExp(n+1, x) ≤ f(x) eventually. By Theorem 3.1 on f with C = 1/2: |f(x)| ≤ exp(½ · iterExp(n, x)) eventually. Combining: exp(iterExp(n, x)) ≤ exp(½ · iterExp(n, x)), same contradiction as Theorem 4.1.

## 5. Algorithms

### 5.1 Derivation Tree Search

**Input**: Target function f, level bound k, size bound s.
**Output**: EML expression e with depth(e) ≤ k and eval(e) ≈ f, or ∅.

```
ENUMERATE(k, s):
  if s ≤ 0: return {}
  base = {var, const(1), const(2), const(-1)}
  if s ≥ 3:
    sub = ENUMERATE(k, s-1)
    for a, b in sub × sub:
      base ∪= {add(a,b), mul(a,b)}
      if k > 0: base ∪= {eml(a,b)}
  return base

SEARCH(f, k, s, test_points):
  for e in ENUMERATE(k, s):
    if depth(e) ≤ k and ∀ x ∈ test_points: |eval(e,x) - f(x)| < ε:
      return e
  return ∅
```

**Complexity**: O(B^s) where B ≈ 5 is the branching factor. Space: O(s · |results|).

### 5.2 Growth Bound Certificate Synthesis

**Input**: Function f, level n.
**Output**: (C, N) such that |f(x)| ≤ exp(C · iterExp(n, x)) for x ≥ N.

```
SYNTHESIZE(f, n):
  for C in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0]:
    for N in [1, 5, 10, 50, 100, 500]:
      if ∀ x ∈ [N, N+100]: |f(x)| ≤ exp(C · iterExp(n, x)):
        return (C, N)
  return FAIL
```

## 6. Computational Experiments

### 6.1 Growth Comparison

We compare iterExp(n+1) against the best level-n candidates:

| x | x^10 | exp(x) | exp(x)/x^10 |
|---|------|--------|-------------|
| 10 | 10^10 | 2.2×10^4 | 2.2×10^-6 |
| 20 | 10^13 | 4.9×10^8 | 4.9×10^-5 |
| 50 | 10^17 | 5.2×10^21 | 5.2×10^4 |
| 100 | 10^20 | 2.7×10^43 | 2.7×10^23 |

The ratio exp(x)/x^10 → ∞, confirming level-0 functions cannot match exp.

### 6.2 Separation Verification

For n = 0, 1, 2, 3, we verify that iterExp(n, x) > ½ · iterExp(n, x) for all positive x:

| n | x=2 | iterExp(n,2) | ½·iterExp(n,2) | gap |
|---|-----|-------------|----------------|-----|
| 0 | 2 | 2.000 | 1.000 | 1.000 |
| 1 | 2 | 7.389 | 3.694 | 3.694 |
| 2 | 2 | 1618.2 | 809.1 | 809.1 |
| 3 | 2 | ≈10^702 | ≈5×10^701 | huge |

The gap grows explosively, confirming the separation.

## 7. Discussion

### 7.1 Implications

The strict separation theorem has several important consequences:

1. **Completeness of emlDepth**: The EML depth invariant provides an *exact* classification of growth rates, not merely an upper bound.

2. **Impossibility results**: No finite combination of level-n operations can produce level-(n+1) growth. This is an analog of circuit depth lower bounds.

3. **Canonical witnesses**: The iterated exponentials form a canonical chain of level witnesses, providing a concrete yardstick for each growth class.

### 7.2 Limitations

The current formalization covers the *finite* Hardy hierarchy. The classical proof-theoretic hierarchy extends to transfinite ordinals (ω, ε₀, etc.), and our techniques do not directly generalize to that setting.

The hierarchy also does not capture all possible growth rates. Functions like the Ackermann function or the busy beaver function transcend all finite levels, and their classification requires transfinite methods.

### 7.3 Relation to Complexity Theory

The separation theorem is a formal analog of the time hierarchy theorem in computational complexity. Just as the time hierarchy theorem shows that more time gives strictly more computational power, our theorem shows that more exponential nesting gives strictly more asymptotic growth.

However, our result is *unconditional* — it does not rely on unproved assumptions like P ≠ NP. This is because the Hardy hierarchy is defined syntactically, allowing direct structural arguments.

## 8. Future Work

1. **Transfinite extension**: Extend the separation to ordinal-indexed levels (ω, ω², ε₀).
2. **Compositional closure**: Determine whether the hierarchy is closed under function composition.
3. **Effective bounds**: Compute explicit values of N in the growth bound as a function of the expression structure.
4. **Connections to formal languages**: Relate Hardy levels to classes of formal power series or transseries.

## References

1. Hardy, G.H. (1910). *Orders of Infinity*. Cambridge Tracts in Mathematics.
2. du Bois-Reymond, P. (1877). Über asymptotische Werthe, infinitäre Approximationen und infinitäre Auflösung von Gleichungen. *Math. Ann.* 8, 363-414.
3. Löb, M.H. & Wainer, S.S. (1970). Hierarchies of number-theoretic functions. *Archiv für mathematische Logik*, 13, 39-51.
4. Boshernitzan, M. (1986). An extension of Hardy's class L of "orders of infinity." *J. Analyse Math.* 39, 235-255.
5. Aschenbrenner, M., van den Dries, L., & van der Hoeven, J. (2017). *Asymptotic Differential Algebra and Model Theory of Transseries*. Annals of Mathematics Studies, Princeton.
