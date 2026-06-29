# Certified Discrete Morse Inequalities: Formal Verification of the Geometry-Topology Bridge

## Abstract

We present the first machine-verified proof of the discrete Morse inequalities for finite chain complexes of finite-dimensional vector spaces. Working in the Lean 4 proof assistant with Mathlib, we formalize a complete algebraic framework comprising: (1) the algebraic weak inequality dim H_n ≤ dim C_n relating homology to chain group dimensions; (2) the Euler characteristic identity expressing the alternating sum of chain dimensions as the alternating sum of Betti numbers; (3) the weak Morse inequality β_n ≤ crit_n bounding Betti numbers by critical cell counts; (4) the strong Morse inequality bounding cumulative alternating partial sums; and (5) the Euler characteristic Morse identity. Our approach avoids Mathlib's categorical homological algebra machinery in favor of a self-contained linear-algebraic formalization based on kernels, ranges, and quotient dimensions, yielding clean, maintainable proofs. We additionally formalize a concrete example (the point complex) and provide Python implementations demonstrating the inequalities on simplicial complexes including the circle, torus, real projective plane, and Klein bottle.

**Keywords:** Discrete Morse theory, Morse inequalities, Euler characteristic, formal verification, finite chain complexes, homological algebra, topological data analysis.

## 1. Introduction

### 1.1 Background and Motivation

Morse theory, originating in M. Morse's study of geodesics on Riemannian manifolds [Morse, 1934], establishes a fundamental connection between the critical point structure of smooth functions and the topology of underlying manifolds. The central results — the weak and strong Morse inequalities — bound Betti numbers by critical point counts and recover the Euler characteristic as an alternating sum of critical indices.

Forman's discrete Morse theory [Forman, 1998] extends this framework to CW complexes and simplicial complexes through the notion of acyclic matchings. A discrete Morse function on a cell complex partitions cells into matched pairs (which cancel geometrically) and unmatched cells (critical cells). The Morse complex, built from critical cells alone, has the same homology as the original complex.

### 1.2 Contributions

Our contributions are:

1. **Formalization of finite chain complexes** as a clean Lean 4 structure with boundary operators, the chain complex condition d ∘ d = 0, and finite-dimensionality.

2. **Construction of homology** as quotient modules (cycles/boundaries) with verified finite-dimensionality.

3. **Proof of five main theorems** (see §3), all machine-verified with no sorry statements and using only standard axioms (propext, Classical.choice, Quot.sound).

4. **Abstract Morse data framework** that cleanly separates the algebraic inequality machinery from the specific construction of Morse reductions.

5. **Concrete example** (point complex with trivial Morse data) demonstrating the framework's usability.

6. **Python implementation** of homology computation, discrete Morse reduction, and inequality verification for simplicial complexes.

### 1.3 Related Work

Formal verification of algebraic topology has received increasing attention. Heras et al. formalized simplicial homology in Isabelle/HOL. The Kenzo system provides certified homology computations. Mathlib contains extensive homological algebra using categorical machinery (HomologicalComplex, ChainComplex), but these are oriented toward abstract category theory rather than finite-dimensional linear algebra.

Our approach is deliberately low-tech: we avoid the categorical framework in favor of direct linear-algebraic constructions. This makes the proofs more accessible and the theorems more immediately applicable to computational settings.

## 2. Definitions and Setup

### 2.1 Finite Chain Complexes

**Definition 2.1** (FinChainComplex). A *finite chain complex* over a field K is a sequence of finite-dimensional K-vector spaces {C_n}_{n ≥ 0} equipped with K-linear maps d_n : C_{n+1} → C_n satisfying d_n ∘ d_{n+1} = 0 for all n ≥ 0.

In Lean 4:
```
structure FinChainComplex (K : Type*) [Field K] where
  C : ℕ → Type*
  instAddCommGroup : ∀ n, AddCommGroup (C n)
  instModule : ∀ n, Module K (C n)
  instFiniteDimensional : ∀ n, FiniteDimensional K (C n)
  d : ∀ n, C (n + 1) →ₗ[K] C n
  d_comp_d : ∀ n, (d n).comp (d (n + 1)) = 0
```

### 2.2 Cycles, Boundaries, and Homology

**Definition 2.2** (Cycles). The *cycles* at degree n are:
- Z_0 = C_0 (all chains at degree 0 are cycles), formalized as ⊤ : Submodule K (C 0)
- Z_{n+1} = ker(d_n) ⊆ C_{n+1}

**Definition 2.3** (Boundaries). The *boundaries* at degree n are B_n = range(d_n) ⊆ C_n.

**Lemma 2.4** (boundaries_le_cycles). B_n ≤ Z_n for all n. This follows from d_n ∘ d_{n+1} = 0.

**Definition 2.5** (Homology). The *n-th homology* is H_n = Z_n / (B_n ∩ Z_n), formalized as the quotient of cycles by the comap of boundaries through the subtype inclusion.

**Definition 2.6** (Betti number). β_n = dim_K H_n, the rank of homology in degree n.

### 2.3 Discrete Morse Data

**Definition 2.7** (DiscreteMorseData). *Discrete Morse data* for a chain complex consists of:
1. An *original* chain complex F.
2. A function criticalCount : ℕ → ℕ giving the number of critical cells per degree.
3. A *reduced* chain complex R (the Morse complex).
4. A proof that dim R_n = criticalCount(n) for all n.
5. Linear equivalences H_n(R) ≃ H_n(F) preserving homology in each degree.

This abstraction captures the output of any discrete Morse reduction algorithm without requiring the specific construction of acyclic matchings.

## 3. Main Results

### Theorem 3.1 (Algebraic Weak Inequality)

**Statement.** For any finite chain complex F, dim H_n(F) ≤ dim C_n for all n ≥ 0.

**Proof sketch.** Homology H_n is a quotient of Z_n, which is a submodule of C_n. By Submodule.finrank_quotient_le and Submodule.finrank_le:
```
dim H_n ≤ dim Z_n ≤ dim C_n.
```
□

### Theorem 3.2 (Euler Characteristic Telescoping Identity)

**Statement.** For a finite chain complex F, for any N:
```
Σ_{n=0}^{N} (-1)^n dim C_n - Σ_{n=0}^{N} (-1)^n dim H_n = (-1)^N · dim(range d_N).
```

**Proof sketch.** By induction on N.

*Base case (N = 0):* From the quotient decomposition dim C_0 = dim Z_0 = dim H_0 + dim(B_0 in Z_0) = dim H_0 + dim(range d_0), so the difference is dim(range d_0) = (-1)^0 · dim(range d_0). ✓

*Inductive step (N → N+1):* By rank-nullity for d_N:
```
dim C_{N+1} = dim(ker d_N) + dim(range d_N) = dim Z_{N+1} + dim(range d_N).
```
By the quotient decomposition:
```
dim Z_{N+1} = dim H_{N+1} + dim(B_{N+1} in Z_{N+1}) = dim H_{N+1} + dim(range d_{N+1}).
```
Combining:
```
dim C_{N+1} = dim H_{N+1} + dim(range d_{N+1}) + dim(range d_N).
```
The contribution of the (N+1)-th term to the alternating difference is:
```
(-1)^{N+1} · (dim C_{N+1} - dim H_{N+1}) = (-1)^{N+1} · (dim(range d_{N+1}) + dim(range d_N)).
```
Adding to the inductive hypothesis:
```
(-1)^N · dim(range d_N) + (-1)^{N+1} · dim(range d_{N+1}) + (-1)^{N+1} · dim(range d_N)
= (-1)^{N+1} · dim(range d_{N+1}).  ✓
```
□

### Corollary 3.3 (Euler Characteristic Identity)

**Statement.** If dim(range d_N) = 0 (e.g., when C_{N+1} = 0), then:
```
Σ_{n=0}^{N} (-1)^n dim C_n = Σ_{n=0}^{N} (-1)^n β_n.
```

### Theorem 3.4 (Strong Algebraic Inequality)

**Statement.** For any finite chain complex F and any k ≥ 0:
```
Σ_{i=0}^{k} (-1)^{k-i} dim H_i ≤ Σ_{i=0}^{k} (-1)^{k-i} dim C_i.
```

**Proof sketch.** Multiply the telescoping identity (Theorem 3.2) by (-1)^k:
```
(-1)^k · [Σ (-1)^n dim C_n - Σ (-1)^n dim H_n] = (-1)^{2k} · dim(range d_k) = dim(range d_k) ≥ 0.
```
Since (-1)^{k-i} = (-1)^k · (-1)^i for i ≤ k (as k-i and k+i have the same parity), the left side becomes:
```
Σ_{i=0}^{k} (-1)^{k-i} dim C_i - Σ_{i=0}^{k} (-1)^{k-i} dim H_i = dim(range d_k) ≥ 0.
```
□

### Theorem 3.5 (Weak Morse Inequality)

**Statement.** For any discrete Morse data M, β_n(M) ≤ criticalCount(M, n) for all n.

**Proof sketch.** By the homology equivalence, β_n(original) = β_n(reduced). By the algebraic weak inequality applied to the reduced complex, β_n(reduced) ≤ dim R_n. By the reduction hypothesis, dim R_n = criticalCount(n). □

### Theorem 3.6 (Strong Morse Inequality)

**Statement.** For any discrete Morse data M and any k ≥ 0:
```
Σ_{i=0}^{k} (-1)^{k-i} β_i ≤ Σ_{i=0}^{k} (-1)^{k-i} crit_i.
```

**Proof sketch.** Apply Theorem 3.4 (strong algebraic inequality) to the reduced complex and use betti_eq_reduced_homology and reduced_finrank to translate. □

### Theorem 3.7 (Euler Characteristic Morse Identity)

**Statement.** For any discrete Morse data M with range(d_N^{red}) = 0:
```
Σ_{n=0}^{N} (-1)^n β_n = Σ_{n=0}^{N} (-1)^n crit_n.
```

## 4. Key Technical Lemma

### Lemma 4.1 (finrank_boundariesInCycles)

The dimension of boundaries viewed as a submodule of cycles equals the dimension of boundaries:
```
dim(B_n ∩ Z_n as submodule of Z_n) = dim(B_n).
```

This is a non-trivial structural lemma. Since B_n ≤ Z_n, the comap of B_n through the subtype inclusion Z_n ↪ C_n is isomorphic to B_n as a vector space. The proof constructs an explicit linear bijection and applies LinearEquiv.finrank_eq.

## 5. Algorithms

### 5.1 Homology Computation

**Input:** Boundary matrices d_1, ..., d_D of a chain complex.
**Output:** Betti numbers β_0, ..., β_D.

```
Algorithm: ComputeHomology(d_1, ..., d_D)
  for k = 1 to D:
    r_k ← rank(d_k)          // via SVD, O(min(m,n)²·max(m,n))
  β_0 ← dim C_0 - r_1
  for k = 1 to D-1:
    β_k ← (dim C_k - r_k) - r_{k+1}
  β_D ← dim C_D - r_D
  return β_0, ..., β_D
```

**Time complexity:** O(Σ_k min(n_k, n_{k+1})² · max(n_k, n_{k+1})) for SVD.
**Space complexity:** O(max_k n_k · n_{k+1}).

### 5.2 Greedy Discrete Morse Reduction

**Input:** Simplicial complex K.
**Output:** Acyclic matching M, critical cells C.

```
Algorithm: GreedyMorseReduction(K)
  remaining ← all simplices of K
  M ← ∅; C ← ∅
  while remaining ≠ ∅:
    found ← false
    for dim d = 0 to max_dim:
      for σ ∈ remaining with dim(σ) = d:
        cofacets ← {τ ∈ remaining : σ ⊂ τ, dim(τ) = d+1}
        if |cofacets| = 1:
          M ← M ∪ {(σ, cofacets[0])}
          remaining ← remaining \ {σ, cofacets[0]}
          found ← true; break
      if found: break
    if not found:
      σ ← lowest-dim simplex in remaining
      C ← C ∪ {σ}; remaining ← remaining \ {σ}
  return M, C
```

**Time complexity:** O(n² · d) where n = |K|, d = max dimension.
**Space complexity:** O(n).

### 5.3 Inequality Verification

**Input:** Betti numbers β, critical counts c.
**Output:** Boolean results for weak, strong, and Euler tests.

The verification is straightforward O(D) computation of the relevant sums and comparisons.

## 6. Computational Experiments

### 6.1 Test Suite

| Space | f-vector | β | crit | χ | Weak | Strong |
|-------|----------|---|------|---|------|--------|
| Point | [1] | [1] | [1] | 1 | ✓ | ✓ |
| Circle S¹ | [3, 3] | [1, 1] | [1, 1] | 0 | ✓ | ✓ |
| Torus T² | [7, 21, 14] | [1, 2, 1] | [1, 2, 1] | 0 | ✓ | ✓ |
| RP² (ℚ) | [6, 15, 10] | [1, 0, 0] | [1, 1, 1] | 1 | ✓ | ✓ |
| Square | [4, 5, 2] | [1, 0, 0] | [1, 0, 0] | 1 | ✓ | ✓ |
| Sphere S² | [4, 6, 4] | [1, 0, 1] | [1, 0, 1] | 2 | ✓ | ✓ |

### 6.2 Morse Compression Ratios

The torus provides a compelling illustration of Morse compression. A minimal triangulation has 42 cells (7 + 21 + 14), but the Morse complex has only 4 critical cells (1 + 2 + 1) — a compression ratio of over 10:1. This ratio grows without bound as the triangulation is refined, while the topology remains constant.

### 6.3 RP² and Coefficient Sensitivity

Over ℚ, the real projective plane has β = [1, 0, 0] — the 2-torsion in H_1(RP²; ℤ) ≅ ℤ/2ℤ is invisible. The standard Morse function has critical cells [1, 1, 1], so the weak inequality β_1 = 0 ≤ 1 = crit_1 is strict. Over 𝔽₂, one would instead get β_1 = 1, recovering the torsion. This illustrates the coefficient sensitivity of Morse inequalities.

## 7. Discussion

### 7.1 Design Decisions

**Why avoid Mathlib's HomologicalComplex?** Mathlib's categorical homological algebra is powerful but complex, requiring navigating a web of category-theoretic abstractions (ShortComplex, HomologicalComplex, ShortComplex.Exact, etc.). Our self-contained approach defines homology directly using Submodule.ker, LinearMap.range, and quotient modules, resulting in proofs that are shorter, more readable, and more suitable for the finite-dimensional setting.

**Why the ℕ-indexed convention?** We index chain groups by ℕ rather than ℤ, treating degree 0 specially (cycles = ⊤). This avoids the complexity of ℤ-indexed graded objects while capturing all finite chain complexes.

**Why the abstract Morse data structure?** Separating the algebraic inequality machinery from specific Morse reduction algorithms allows the theorems to apply to any construction that produces a homology-equivalent reduced complex — whether from Forman's discrete Morse theory, optimal Morse matchings, algebraic Morse theory, or any other source.

### 7.2 Limitations

1. **No explicit Morse reduction construction.** We formalize the abstract framework but not a specific algorithm for constructing acyclic matchings. This is a natural next step.

2. **Degree-0 convention.** Our treatment of degree 0 (cycles = ⊤) is standard but requires case-splitting in some proofs. A cochain complex convention (d going up) would avoid this at the cost of non-standard orientation.

3. **Coefficient field assumption.** Working over a field avoids torsion phenomena. Extending to PID coefficients would require careful handling of the universal coefficient theorem.

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps. Key targets include:

1. **Explicit discrete Morse reduction** — formalizing Forman's matching algorithm and proving it produces valid Morse data.
2. **Spectral Morse theory** — connecting eigenvalue counts of combinatorial Laplacians to critical cell counts.
3. **Persistent homology with verified Morse preprocessing** — certified TDA pipelines.
4. **Witten deformation on finite complexes** — semiclassical correspondence between spectral and Morse-theoretic data.

## 9. Conclusion

We have produced the first machine-verified proof of the complete Morse inequality package for finite chain complexes. The formalization demonstrates that the algebraic heart of Morse theory — the bridge from geometric complexity (cell counts) to topological invariants (Betti numbers) — can be certified with full rigor. The abstract Morse data framework provides reusable infrastructure for any future formalization that produces homology-equivalent reduced complexes.

## References

1. M. Morse. *The Calculus of Variations in the Large*. AMS Colloquium Publications, 1934.
2. R. Forman. Morse theory for cell complexes. *Advances in Mathematics*, 134:90–145, 1998.
3. R. Forman. A user's guide to discrete Morse theory. *Séminaire Lotharingien de Combinatoire*, 48:B48c, 2002.
4. E. Witten. Supersymmetry and Morse theory. *Journal of Differential Geometry*, 17(4):661–692, 1982.
5. H. Edelsbrunner and J. Harer. *Computational Topology: An Introduction*. AMS, 2010.
6. D. Kozlov. *Combinatorial Algebraic Topology*. Springer, 2008.
7. Mathlib Community. *Mathlib4*. https://github.com/leanprover-community/mathlib4, 2024.
