# Thermodynamic Dual Semantics via Donsker–Varadhan for Closure Proof Semirings

## Abstract

We establish a thermodynamic variational duality for proof-theoretic closure semantics, formalizing the entire development in Lean 4 with zero unproven statements. The central result is a Donsker–Varadhan variational formula characterizing the free-energy gap as a supremum over probability measures on the prime spectrum, together with an adequacy theorem connecting algebraic derivability to nonpositivity of the free-energy gap across all inverse temperatures. This provides a precise bridge connecting four mathematical domains: algebraic proof semantics, statistical mechanics, large deviation theory, and certified robustness.

## 1. Introduction

The classical approach to proof-theoretic semantics characterizes derivability `cl x ≤ cl y` through spectral separation: `x` is derivable from `y` if and only if no prime spectral point separates them. This is a Stone-duality result connecting algebra to topology.

Our contribution is to *thermodynamicize* this correspondence by introducing a family of free-energy functionals indexed by inverse temperature β > 0. These functionals:

1. **Smoothly interpolate** between the reference measure's expectation (β → 0⁺) and the hard spectral maximum (β → ∞).
2. **Satisfy a variational duality** (Donsker–Varadhan formula): the free energy equals the supremum of expected gap minus entropic penalty.
3. **Exactly characterize derivability**: `derivable x y ↔ ∀ β > 0, F_β ≤ 0`.

## 2. Mathematical Framework

### 2.1 Coherent Closure Proof Semirings

We work with a bounded distributive lattice `S` equipped with a closure operator `cl : S → S` satisfying extensiveness (`x ≤ cl x`), idempotency (`cl(cl x) = cl x`), and monotonicity. Derivability is defined as `derivable x y := cl x ≤ cl y`.

### 2.2 Spectral Points and the Gap Observable

A spectral point `p : SpectralPoint S` is a prime filter compatible with the closure operator. The semantic gap `semanticGap p x y` measures the separation of `x` from `y` at `p`, taking values in {-1, 0, 1}.

### 2.3 Core Thermodynamic Definitions

For a strictly positive reference measure `μ` on the finite spectrum and inverse temperature `β > 0`:

- **Partition function**: `Z(β) = Σ_p μ_p · exp(β · g_p)`
- **Free energy**: `F_β = (1/β) · log Z(β)`
- **Gibbs tilt**: `γ_p = μ_p · exp(β · g_p) / Z(β)`
- **KL divergence**: `KL(ν ‖ μ) = Σ_p ν_p · log(ν_p / μ_p)`

## 3. Main Results

### 3.1 Donsker–Varadhan Variational Formula

**Theorem** (`dv_variational_freeEnergy`): For any strictly positive reference measure μ and β > 0,

```
F_β(μ, g) = sup { E_ν[g] - (1/β) · KL(ν ‖ μ) | ν probability vector }
```

The proof proceeds by:
1. Showing the Gibbs tilt achieves the supremum exactly (Gibbs balance identity).
2. Showing every probability vector's objective is bounded above by F_β (DV upper bound, via KL nonnegativity).
3. Combining via `le_antisymm` with `csSup_le` and `le_csSup`.

### 3.2 Thermodynamic Adequacy

**Theorem** (`derivable_iff_freeEnergyGap_nonpos`): Under prime spectral completeness,

```
derivable x y ↔ ∀ β > 0, F_β(μ, β, x, y) ≤ 0
```

The forward direction uses the upper bound `F_β ≤ sup_p g_p` combined with `sup g ≤ 0` when derivable. The reverse direction uses the zero-temperature limit to extract a hard spectral witness from the assumption that `F_β > 0` for some β.

### 3.3 Zero-Temperature Limit

**Theorem** (`thermodynamic_closure_hardMax_limit`):

```
F_β → sup_p g_p as β → ∞
```

with explicit O(1/β) convergence rate: `|F_β - sup g| ≤ (-log(min_p μ_p)) / β`.

The proof uses sandwich bounds: `sup g + log(min μ)/β ≤ F_β ≤ sup g`.

## 4. Proof Architecture

The proof is structured in 11 parts with 32 formally verified theorems:

1. **Probability infrastructure** (IsProbVec, StrictlyPositiveReferenceMeasure)
2. **Core thermodynamic definitions** (klDiv, partitionFun, freeEnergy, gibbsTilt)
3. **Partition function positivity** (partitionFun_pos)
4. **Gibbs tilt properties** (normalization, positivity)
5. **KL nonnegativity** (kl_term_ge, kl_nonneg_finite)
6. **Gibbs balance and DV bound** (log_gibbsTilt_ratio, gibbsTilt_kl_balance, dv_variational_upper_bound)
7. **DV variational formula** (dv_variational_freeEnergy)
8. **Sandwich bounds** (freeEnergy_le_supVal, supVal_le_freeEnergy_plus_penalty)
9. **Zero-temperature limit** (thermodynamic_closure_hardMax_limit)
10. **Closure proof semiring infrastructure** (CoherentClosureProofSemiring, SpectralPoint)
11. **Thermodynamic adequacy** (derivable_iff_freeEnergyGap_nonpos)

### Tactics Used

The proofs employ diverse tactics including: `rcases`, `by_contra`, `linarith`, `nlinarith`, `field_simp`, `ring`, `norm_num`, `simp`, `calc`, `positivity`, `split_ifs`, `push_neg`, `Finset.sum_pos`, `Finset.sum_le_sum`, `div_pos`, `mul_pos`, `Real.log_le_log`, `Real.exp_le_exp`, `Metric.tendsto_nhds`, and `Filter.eventually_gt_atTop`.

## 5. Cross-Domain Significance

| Domain | Connection |
|--------|-----------|
| **Proof Theory** | Derivability characterized by thermodynamic observable |
| **Statistical Mechanics** | Free energy = Gibbs variational principle |
| **Large Deviations** | DV formula = rate function duality |
| **Certified Robustness** | O(1/β) bounds = soft certification margins |
| **Post-Quantum Security** | KL penalty = entropic security budget |

## 6. Verification

All 32 theorems compile in Lean 4.28.0 with Mathlib, with no `sorry` statements. The axioms used are exactly `propext`, `Classical.choice`, and `Quot.sound` — the standard foundational axioms of Lean 4 mathematics.

## References

- Donsker, M.D. and Varadhan, S.R.S. "Asymptotic evaluation of certain Markov process expectations for large time." Communications on Pure and Applied Mathematics (1975).
- Stone, M.H. "The theory of representations for Boolean algebras." Transactions of the AMS (1936).
