# Growth Comparator Algebras: A Foundational Formalization of the Transseries Hierarchy

## Abstract

We introduce and formally verify the theory of **Growth Comparator Algebras** (GCAs), a novel algebraic structure that axiomatizes the asymptotic growth hierarchy underlying transseries. A GCA consists of a totally ordered set equipped with an order automorphism σ (the "depth shift") satisfying σ(x) > x for all x. We prove that this single axiom — combined with the order automorphism structure — implies the full hierarchy of structural theorems: strict monotonicity of depth iteration, absence of fixed points, the inverse bound σ⁻¹(x) < x, and the self-similarity of the hierarchy.

On the analytic side, we establish the complete separation hierarchy for iterated exponentials and logarithms: exponential dominates polynomial, polynomial dominates logarithm, and each depth level strictly dominates the one below. We prove the **Self-Similarity Theorem**: if f asymptotically dominates g, then exp∘f dominates exp∘g, showing that the depth shift acts functorially on growth rates.

We instantiate the abstract theory with the canonical integer GCA (ℤ, σ(n) = n+1) and prove its discreteness: no growth rates exist between consecutive depth levels. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Background

Transseries, introduced by Écalle in connection with the study of differential equations and analytic continuation, are formal objects that extend power series by incorporating iterated exponentials and logarithms. The field of transseries, denoted ℝ((t^{-1}))^{LE}, was shown by van den Dries, Macintyre, and Marker to carry a rich model-theoretic structure: it is an elementary extension of the real field and admits a natural valuation.

Hardy fields, introduced by Hardy (1910) and developed by Bourbaki, Boshernitzan, and Rosenlicht, provide the analytic counterpart: they are fields of germs of real-valued functions at infinity, totally ordered by eventual comparison.

### 1.2 Contributions

This work makes three principal contributions:

1. **A novel algebraic structure**: We define the Growth Comparator Algebra, axiomatizing the essential algebraic properties of the growth hierarchy. The axioms are minimal: a linear order, an order automorphism σ, a base point, and the condition σ(x) > x.

2. **Complete separation hierarchy**: We prove the full chain of asymptotic separations for iterated exponentials and logarithms, establishing the foundational results of asymptotic analysis in a unified framework.

3. **Self-similarity theorem**: We prove that the depth shift acts functorially on the preorder of growth rates, establishing the structural self-similarity of the hierarchy.

### 1.3 Relation to Prior Work

The growth hierarchy has been studied informally in numerous works on asymptotic analysis. Our contribution is the identification of the minimal algebraic axioms and the complete formal verification of the resulting theory. The GCA structure is related to, but distinct from, the value group of a Hardy field: while the value group carries an additive group structure, the GCA captures only the order-theoretic and shift-structure aspects, making it applicable in broader settings.

## 2. Definitions

### 2.1 Iterated Exponentials and Logarithms

**Definition 2.1** (Iterated Exponential). For n ∈ ℕ and x ∈ ℝ, define:
- iterExp(0, x) = x
- iterExp(n+1, x) = exp(iterExp(n, x))

**Definition 2.2** (Iterated Logarithm). For n ∈ ℕ and x ∈ ℝ, define:
- iterLog(0, x) = x  
- iterLog(n+1, x) = log(iterLog(n, x))

### 2.2 Asymptotic Dominance

**Definition 2.3** (Asymptotic Dominance). We say f *asymptotically dominates* g, written f ≫ g, if:

  lim_{x→∞} g(x)/f(x) = 0

**Definition 2.4** (Asymptotic Equivalence). We say f ~ g if:

  lim_{x→∞} g(x)/f(x) = 1

### 2.3 Growth Comparator Algebra

**Definition 2.5** (Growth Comparator Algebra). A **Growth Comparator Algebra** (GCA) is a triple (Γ, ≤, σ) where:
1. (Γ, ≤) is a totally ordered set
2. σ : Γ ≃o Γ is an order automorphism (the "depth shift")
3. There is a distinguished element base ∈ Γ
4. σ(x) > x for all x ∈ Γ (the "inflation axiom")

The inflation axiom encodes the fundamental property that exponentiation strictly increases growth rate.

## 3. Main Results

### 3.1 Separation Theorems

**Theorem 3.1** (Exponential Dominates Polynomial). For all n ∈ ℕ:

  lim_{x→∞} x^n / exp(x) = 0

*Proof sketch.* This follows from the classical result that x^n · e^{-x} → 0. We use the Mathlib lemma `Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero` and the identity x^n / exp(x) = x^n · exp(-x). □

**Theorem 3.2** (Polynomial Dominates Logarithm). For all α > 0 and n ∈ ℕ:

  lim_{x→∞} log(x)^n / x^α = 0

*Proof sketch.* Substitute x = e^t. Then log(x)^n / x^α = t^n / e^{αt}. By scaling, this reduces to the case of Theorem 3.1. The key technical step is composing the convergence result with the substitution, using the fact that log → ∞ at infinity. □

**Theorem 3.3** (Iterated Exponential Separation). For all n ∈ ℕ:

  iterExp(n) ≫ iterExp(n+1)

that is, iterExp(n, x) / iterExp(n+1, x) → 0 as x → ∞.

*Proof sketch.* iterExp(n+1, x) = exp(iterExp(n, x)). Since iterExp(n, x) → ∞ (proved by induction), the ratio iterExp(n, x) / exp(iterExp(n, x)) = t / exp(t) evaluated at t = iterExp(n, x) → 0 by Theorem 3.1 (case n=1) composed with the divergence. □

### 3.2 Structural Theorems

**Theorem 3.4** (Transitivity of Asymptotic Dominance). If f ≫ g and g ≫ h (with f, g eventually positive), then f ≫ h.

*Proof sketch.* Write h/f = (h/g)(g/f). Both factors → 0, so their product → 0. Uses the fact that 0 · 0 = 0 in the nhds filter. □

**Theorem 3.5** (Irreflexivity). For eventually nonzero f, ¬(f ≫ f).

*Proof sketch.* f(x)/f(x) = 1 eventually, so the limit is 1 ≠ 0. □

### 3.3 Self-Similarity Theorem

**Theorem 3.6** (Depth Shift Preserves Dominance). If f ≫ g, f → ∞, and g → ∞, then exp∘f ≫ exp∘g.

*Proof sketch.* exp(g(x)) / exp(f(x)) = exp(g(x) - f(x)). Since g/f → 0 and f → ∞, we have f - g → ∞: specifically, f(x) - g(x) = f(x)(1 - g(x)/f(x)) and the factor (1 - g(x)/f(x)) → 1 while f(x) → ∞. Hence exp(g - f) = exp(-(f - g)) → 0 by the classical result exp(-t) → 0 as t → ∞. □

### 3.4 GCA Structure Theorems

**Theorem 3.7** (No Fixed Points). In any GCA, σ(x) ≠ x for all x.

*Proof.* Immediate from σ(x) > x. □

**Theorem 3.8** (Inverse Bound). In any GCA, σ⁻¹(x) < x for all x.

*Proof.* From σ(y) > y with y = σ⁻¹(x), we get σ(σ⁻¹(x)) > σ⁻¹(x), i.e., x > σ⁻¹(x). □

**Theorem 3.9** (Depth Hierarchy). In any GCA, the sequence σⁿ(base) is strictly increasing in n.

*Proof.* By induction. Base: σ⁰(base) = base < σ(base) = σ¹(base) by the inflation axiom. Step: if σⁿ(base) < σⁿ⁺¹(base), then σⁿ⁺¹(base) < σⁿ⁺²(base) by applying σ (which is strictly monotone) to the inductive hypothesis. □

**Theorem 3.10** (Strict Monotonicity of Iteration). For any GCA and any x ∈ Γ, the map n ↦ σⁿ(x) is strictly monotone.

*Proof.* σⁿ⁺¹(x) = σ(σⁿ(x)) > σⁿ(x) by the inflation axiom, so n ↦ σⁿ(x) is a strict monotone function by `strictMono_nat_of_lt_succ`. □

### 3.5 Concrete Results for the Integer GCA

**Theorem 3.11** (Integer Iteration). In the ℤ GCA with σ(n) = n+1: σⁿ(0) = n for all n ∈ ℕ.

**Theorem 3.12** (Discreteness). In the ℤ GCA, there is no integer strictly between σⁿ(0) and σⁿ⁺¹(0) = σⁿ(0) + 1. That is, the integer GCA has no "fractional" depth levels.

### 3.6 EML Connection

**Theorem 3.13** (EML Asymptotic). For b > 0:

  lim_{a→∞} (exp(a) - log(b)) / exp(a) = 1

This establishes that the EML operation exp(a) - log(b) is asymptotically equivalent to its leading (exponential) term, connecting to the EML framework in the Catalog.

## 4. The PEGB Analysis

### 4.1 Exponential Dominates Polynomial (PEGB)

- **P**roof: Complete formal proof using tendsto_pow_mul_exp_neg_atTop_nhds_zero
- **E**xample: x¹⁰/exp(x) at x=100: ≈ 10¹⁰/exp(100) ≈ 3.7 × 10⁻³⁴
- **G**eneralization: Extends to x^α/exp(x^β) → 0 for any α and β > 0
- **B**oundary: When β = 0, exp(x⁰) = e is constant, and x^α/e → ∞. The critical boundary is β = 0.

### 4.2 Self-Similarity Theorem (PEGB)

- **P**roof: exp(g-f) → 0 via f-g → ∞ 
- **E**xample: x ≫ log(x), so exp(x) ≫ exp(log(x)) = x. Consistency check.
- **G**eneralization: Any order-preserving embedding φ : ℝ → ℝ with φ(t)/t → ∞ would yield a similar depth shift.
- **B**oundary: Requires both f, g → ∞. If g is bounded, exp∘g is bounded and exp∘f still dominates (trivially). If only f → ∞ but g oscillates, the theorem may fail.

### 4.3 GCA Strict Monotonicity (PEGB)

- **P**roof: Induction using σ(x) > x
- **E**xample: ℤ GCA: 0 < 1 < 2 < 3 < ...
- **G**eneralization: Works for any order automorphism with a positive translation length
- **B**oundary: If we relax σ(x) > x to σ(x) ≥ x, fixed points are possible and monotonicity fails.

## 5. Conjectures

**Conjecture 5.1** (Density of Polynomial Exponents). For any dense linear order (Γ, ≤) with a GCA structure, the set {x ∈ Γ : σ⁻¹(base) < x < base} is infinite and has no endpoints in Γ.

*Testable prediction*: Construct a GCA on ℚ × ℚ with lexicographic order and σ(a,b) = (a+1, b). The interval between σ⁻¹(0,0) = (-1, 0) and (0, 0) should contain all elements of the form (-1, q) for q > 0 and (0, q) for q < 0 — infinitely many, confirming density.

## 6. Discussion

The Growth Comparator Algebra provides a clean axiomatization of the essential structure underlying transseries. The single axiom σ(x) > x, combined with the order automorphism structure, is surprisingly powerful: it implies the full hierarchy of structural theorems without any reference to analysis, topology, or the specific functions involved.

The key philosophical insight is that the hierarchy of growth rates is not a property of real analysis per se — it is a purely order-theoretic phenomenon arising from the existence of a "positive translation" automorphism. This suggests that similar hierarchies might arise in other mathematical settings, such as ordinal arithmetic, surreal numbers, or the theory of Hardy fields over non-Archimedean fields.

## 7. Future Work

The most natural extensions are:
1. **Multiplicative structure**: Defining a multiplication on growth levels corresponding to composition of growth functions.
2. **Field structure on transseries**: Proving that finitely-supported transseries form an ordered field.
3. **Connection to surreal numbers**: Exploring the embedding of the GCA into the surreal numbers.
4. **Continuous GCA**: Studying GCAs on ℝ or on ordered fields, where the density between depth levels gives rise to a rich "polynomial" layer.

## References

1. Écalle, J. *Introduction aux fonctions analysables et preuve constructive de la conjecture de Dulac*. Hermann, 1992.
2. van den Dries, L., Macintyre, A., and Marker, D. "Logarithmic-exponential series." *Annals of Pure and Applied Logic*, 111(1-2):61-113, 2001.
3. Hardy, G. H. *Orders of Infinity: The Infinitärcalcül of Paul du Bois-Reymond*. Cambridge Tracts in Mathematics, 1910.
4. Rosenlicht, M. "Hardy fields." *Journal of Mathematical Analysis and Applications*, 93(2):297-311, 1983.
5. Aschenbrenner, M., van den Dries, L., and van der Hoeven, J. *Asymptotic Differential Algebra and Model Theory of Transseries*. Annals of Mathematics Studies, Princeton, 2017.
