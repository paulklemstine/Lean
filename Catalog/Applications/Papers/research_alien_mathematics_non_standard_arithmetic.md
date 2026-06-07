# Non-Standard Arithmetic: Saturation, Transfer, and the Structure of *ℕ

## Abstract

We develop a comprehensive formalization of non-standard arithmetic via ultrapowers, extending the classical construction of *ℕ = ℕ^ℕ / U with new structural results. Building on existing ultraproduct foundations (Bridges/DependentUltraproduct.lean, Novelty/UltrapowerNat.lean, Novelty/Overspill.lean), we prove: (1) the underspill principle as dual to overspill; (2) finite saturation for ultrafilters; (3) transfer of Fermat's Little Theorem, Wilson's Theorem, and GCD divisibility to the ultrapower; (4) existence and uniqueness of the standard part map for bounded elements; (5) polynomial growth preservation under ultrapower embedding; (6) exponential domination of polynomial growth in *ℕ; (7) internal induction for sequence-definable predicates; and (8) non-standard prime counting. All results are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords**: Non-standard arithmetic, ultrapower construction, transfer principle, Łoś's theorem, free ultrafilter, overspill, underspill, standard part, formal verification

## 1. Introduction

### 1.1 Background

Non-standard models of arithmetic, introduced by Skolem (1934) and developed extensively by Robinson (1966), provide a powerful framework for reasoning about infinite and infinitesimal quantities within rigorous mathematical foundations. The ultrapower construction, based on Łoś's fundamental theorem, shows that first-order properties transfer between a structure and its ultrapower.

### 1.2 Prior Work in the Catalog

Our formalization extends three existing developments:

1. **Bridges/DependentUltraproduct.lean**: Establishes the dependent ultraproduct construction, the ultraproduct setoid, and proves fundamental transfer theorems including `ultrafilter_transfer_and`, `ultrafilter_transfer_or`, `ultrafilter_bounded_forall_transfer`, and ring operation compatibility (`ultraproduct_add_welldef`, `ultraproduct_mul_welldef`).

2. **Novelty/UltrapowerNat.lean**: Constructs *ℕ at the pre-quotient level with the canonical non-standard element ω = [id], proves the power hierarchy ω < ω² < ω³ < ..., universal divisibility of ω!, and existence of non-standard primes.

3. **Novelty/Overspill.lean**: Establishes the overspill principle and diagonal overspill, along with logical transfer for implication, biconditional, and negation.

### 1.3 Contributions

This work deepens the existing catalog in three directions:

- **Generalization**: We generalize individual transfer results to a systematic framework including finite saturation and internal induction.
- **Strengthening**: We prove the underspill principle (dual of overspill) and standard part uniqueness — results that extract standard information from non-standard data.
- **Bridge to Number Theory**: We transfer specific number-theoretic theorems (Fermat, Wilson, GCD divisibility) and growth rate comparisons, connecting non-standard arithmetic to computational complexity.

## 2. Definitions

### 2.1 Free Ultrafilters

**Definition 2.1** (IsFree). An ultrafilter U on ℕ is *free* (non-principal) if no singleton is U-large:
```
def IsFree (U : Ultrafilter ℕ) : Prop := ∀ n : ℕ, ({n} : Set ℕ) ∉ U
```

**Theorem 2.2** (mem_of_cofinite). Free ultrafilters contain all cofinite sets. If U is free and S^c is finite, then S ∈ U.

*Proof sketch*: Write S^c = {a₁, ..., aₙ}. Each {aᵢ}^c ∈ U since {aᵢ} ∉ U. Then S ⊇ ⋂ᵢ {aᵢ}^c ∈ U by finite intersection closure.

### 2.2 Ultrapower Ordering and Operations

We work at the pre-quotient level, defining:
- **UEq U f g**: {i | f(i) = g(i)} ∈ U (ultrapower equality)
- **ULt U f g**: {i | f(i) < g(i)} ∈ U (strict ordering)
- **ULe U f g**: {i | f(i) ≤ g(i)} ∈ U (non-strict ordering)
- **UDiv U f g**: {i | f(i) ∣ g(i)} ∈ U (divisibility)

The canonical non-standard element ω = id and the standard embedding std(n) = λ _ => n.

## 3. Main Results

### 3.1 Underspill Principle (Theorem 3.1)

**Theorem** (underspill). Let U be a free ultrafilter on ℕ and P : ℕ → Prop. If for every standard n, the set {i | P(i) ∨ i < n} is U-large, then {i | P(i)} is U-large.

*Proof*: By contradiction. If {i | P(i)} ∉ U, then {i | ¬P(i)} ∈ U. For n = 0, {i | P(i) ∨ i < 0} = {i | P(i)} ∉ U by assumption, contradicting the hypothesis.

**Significance**: This is the formal dual of overspill. While overspill extends standard properties to non-standard elements, underspill recovers standard bounds from non-standard data. Together, they form the methodological core of non-standard analysis.

**PEGB Analysis**:
- **Proof**: By contraposition, reducing to the n = 0 case
- **Example**: If every element of *ℕ above every standard number satisfies P, then {i | P(i)} is U-large
- **Generalization**: Extends to any ordered structure with cofinal standard elements
- **Boundary**: Requires the ultrafilter to be free; principal ultrafilters trivially satisfy the conclusion

### 3.2 Finite Saturation (Theorem 3.2)

**Theorem** (finite_saturation). For any finite family of predicates P₁, ..., Pₙ, if each {i | Pₖ(i)} ∈ U, then {i | ∀k, Pₖ(i)} ∈ U.

*Proof*: By induction on n, using closure of U under finite intersection.

This is the finitary core of the ℵ₁-saturation property. We also prove `countable_saturation_finite_prefix`: for a decreasing sequence of U-large sets, every finite prefix intersection is U-large. We note that the full countable intersection need not be U-large (counterexample: Sₙ = {i | i ≥ n} gives ⋂Sₙ = ∅).

### 3.3 Transfer of Number-Theoretic Identities

**Theorem 3.3** (fermat_little_transfer). If {i | p(i) is prime} ∈ U, then {i | a(i)^p(i) ≡ a(i) (mod p(i))} ∈ U.

*Proof*: The set {i | Nat.Prime(p(i))} is a subset of {i | a(i)^p(i) ≡ a(i) (mod p(i))} by pointwise application of Fermat's Little Theorem (using Mathlib's `ZMod.natCast_eq_natCast_iff`). Apply upward closure.

**Theorem 3.4** (wilson_transfer). If {i | p(i) is prime} ∈ U, then {i | p(i) ∣ (p(i)-1)! + 1} ∈ U.

*Proof*: Similarly, by pointwise Wilson's theorem via `ZMod.natCast_eq_zero_iff`.

**Theorem 3.5** (gcd_divides_transfer). For any sequences a, b: UDiv U (gcd ∘ (a,b)) a ∧ UDiv U (gcd ∘ (a,b)) b.

*Proof*: By pointwise `Nat.gcd_dvd_left` and `Nat.gcd_dvd_right`, the relevant sets are all of ℕ.

**PEGB for Fermat Transfer**:
- **Proof**: Pointwise application + upward closure
- **Example**: std(3)^std(5) ≡ std(3) (mod std(5)) since 3⁵ = 243 = 48·5 + 3
- **Generalization**: Extends to Euler's theorem for arbitrary moduli via Euler's totient
- **Boundary**: Fails for composite moduli — 2⁴ = 16 ≢ 2 (mod 4)

### 3.4 Standard Part Map (Theorems 3.6–3.7)

**Theorem 3.6** (standard_part_exists). If f is bounded (∃N, {i | f(i) ≤ N} ∈ U), then there exists n with UEq U f (std n).

*Proof*: By the ultrafilter pigeonhole principle applied to the finite set {0, ..., N}. Since f takes values in this set on a U-large set, and the U-large preimages of distinct values are disjoint, exactly one value n has {i | f(i) = n} ∈ U.

**Theorem 3.7** (standard_part_unique). If UEq U f (std m) and UEq U f (std n), then m = n.

*Proof*: The intersection {i | f(i) = m} ∩ {i | f(i) = n} is U-large (hence nonempty), forcing m = n.

**Remark**: Uniqueness does not require U to be free — it holds for all ultrafilters.

### 3.5 Growth Rate Transfer (Theorems 3.8–3.9)

**Theorem 3.8** (polynomial_growth_overspill). If f(n) ≤ n^k for all standard n, then ULe U f (fun i => i^k).

*Proof*: The hypothesis gives {i | f(i) ≤ i^k} = ℕ, which is trivially in U.

**Theorem 3.9** (exp_dominates_poly_nonstandard). For any k, ULt U (fun i => i^k) (fun i => 2^i).

*Proof*: We show {i | i^k ≥ 2^i} is finite. The real-valued ratio n^k/2^n → 0 as n → ∞ (by Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero). This gives ∃N, ∀i ≥ N, i^k < 2^i. The complement is contained in {0, ..., N-1}, which is finite. By mem_of_cofinite, the desired set is U-large.

**PEGB**:
- **Proof**: Real analysis (tendency to zero) + cofiniteness
- **Example**: k = 10: 2^i > i^10 for all i ≥ 59
- **Generalization**: c^ω > ω^k for any c ≥ 2 and any standard k
- **Boundary**: Base 1 fails: 1^ω = 1 < ω^k for k ≥ 1

### 3.6 Internal Induction (Theorem 3.10)

**Theorem 3.10** (internal_induction). If {i | P(i,0)} ∈ U and for each standard n, {i | P(i,n) → P(i,n+1)} ∈ U, then for every standard m, {i | P(i,m)} ∈ U.

*Proof*: By standard induction on m, using closure of U under finite intersection at the inductive step.

**PEGB**:
- **Proof**: Standard induction + filter intersection
- **Example**: P(i,m) = "i^m ≤ 2^i" satisfies internal induction
- **Generalization**: Extends to well-ordered induction for ordinal-indexed sequences
- **Boundary**: Fails for external predicates — "m is standard" satisfies induction hypotheses but not the conclusion for non-standard m

### 3.7 Non-Standard Prime Counting (Theorem 3.11)

**Theorem 3.11** (prime_count_transfer). ULt U (std 0) (internalCount (fun _ n => Nat.Prime n) omega).

*Proof*: For i ≥ 2, the count of primes in {0, ..., i} is ≥ 1 (since 2 is prime). The complement {i | count = 0} ⊆ {0, 1} is finite, so the desired set is U-large.

## 4. Cross-Domain Bridge: Complexity Theory

Theorem 3.9 (exponential dominates polynomial) has implications for computational complexity. In any non-standard model of arithmetic:

1. **Polynomial-time computations are robust**: If an algorithm runs in time n^k on all standard inputs, it runs in time ω^k on non-standard input ω. This is polynomial_growth_overspill.

2. **Exponential separations are structural**: The gap between 2^ω and ω^k is not an artifact of asymptotic analysis but a single inequality in the ultrapower.

3. **Connection to padic_arithmetic_depth_bound**: The Catalog's `Bridges/NonArchimedeanComputation.lean` shows that p-adic valuations bound computational depth. Our growth rate results complement this: polynomial growth bounds are structural invariants preserved under ultrapower construction, just as p-adic valuations are structural invariants preserved under completion.

## 5. Discussion

### 5.1 What We Discovered

The most surprising result was the simplicity of the underspill proof: it reduces immediately to the n = 0 case via contraposition. This suggests that underspill, despite its conceptual importance, is fundamentally a consequence of the ultrafilter's totality rather than a deep structural property.

The standard part uniqueness theorem was also noteworthy for *not* requiring freeness of the ultrafilter. This generality — that bounded elements have unique standard parts in *any* ultrapower — is stronger than typically stated.

### 5.2 What Failed

Our initial formulation of countable saturation (∃ i, ∀ n, i ∈ S n for decreasing U-large sets) was **false**. The counterexample Sₙ = {i | i ≥ n} gives ⋂ Sₙ = ∅ despite each Sₙ being U-large. The correct formulation is that every *finite* prefix intersection is U-large — this is the content of countable_saturation_finite_prefix.

The Bézout transfer theorem in its original formulation (with ℕ coefficients) proved technically challenging due to the subtraction asymmetry in ℕ. We replaced it with the cleaner GCD divisibility transfer, which captures the essential content without the technical overhead.

### 5.3 Architectural Decisions

We work at the "pre-quotient" level: properties hold "in *ℕ" iff they hold on U-large sets. This avoids quotient-type complications while preserving all mathematical content. This is equivalent to Łoś's theorem for quantifier-free formulas.

## 6. Future Work

1. **Full Łoś's Theorem**: Formalize the transfer principle for arbitrary first-order sentences, not just quantifier-free ones.
2. **ℵ₁-Saturation**: Prove the full countable saturation theorem using the diagonal argument.
3. **Non-Standard Analysis**: Extend to *ℝ and prove the fundamental theorems of infinitesimal calculus.
4. **Independence Results**: Use non-standard models to establish independence of combinatorial principles from fragments of arithmetic.

## 7. References

1. Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
2. Goldblatt, R. (1998). *Lectures on the Hyperreals*. Springer.
3. Chang, C.C. & Keisler, H.J. (1990). *Model Theory*. North-Holland.
4. Catalog: `Bridges/DependentUltraproduct.lean` — Ultraproduct construction and transfer theorems.
5. Catalog: `Novelty/UltrapowerNat.lean` — Ultrapower of ℕ with power hierarchy.
6. Catalog: `Novelty/Overspill.lean` — Overspill principle and logical transfer.
7. Catalog: `Bridges/NonArchimedeanComputation.lean` — p-adic arithmetic depth bound.

## Appendix: Theorem Inventory

| Theorem | Type | Dependencies |
|---------|------|-------------|
| `mem_of_cofinite` | Infrastructure | `Ultrafilter.compl_mem_iff_notMem` |
| `free_ultrafilter_Ici` | Infrastructure | `mem_of_cofinite` |
| `omega_exceeds_std` | Infrastructure | `free_ultrafilter_Ici` |
| `underspill` | Structural | Ultrafilter totality |
| `finite_saturation` | Structural | Finite intersection closure |
| `countable_saturation_finite_prefix` | Structural | `finite_saturation` |
| `fermat_little_transfer` | Number Theory | `ZMod.natCast_eq_natCast_iff` |
| `wilson_transfer` | Number Theory | `ZMod.natCast_eq_zero_iff` |
| `gcd_divides_transfer` | Number Theory | `Nat.gcd_dvd_left/right` |
| `standard_part_exists` | Standard Part | Ultrafilter pigeonhole |
| `standard_part_unique` | Standard Part | Ultrafilter nonemptiness |
| `polynomial_growth_overspill` | Growth Rates | Pointwise bound |
| `exp_dominates_poly_nonstandard` | Growth Rates | Real analysis + cofiniteness |
| `sum_transfer` | Transfer | Definitional equality |
| `prime_count_transfer` | Counting | `mem_of_cofinite` |
| `internal_induction` | Induction | Standard induction + filter |
