

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## YOUR ASSIGNMENT: Von Neumann Entropy Bounds, Spectral Shannon Correspondence, and Holevo Capacity for Finite Quantum Channels

Create the files

- `Physics/QuantumInfo/VonNeumannEntropy.lean`
- `Physics/QuantumInfo/HolevoCapacity.lean`

and make them a coherent finite-dimensional quantum-information development with explicit bridges to classical information theory, post-quantum cryptographic security, and certified robustness style entropy bounds.

Work in the finite-dimensional matrix model first. Prefer a formulation over `Matrix (Fin n) (Fin n) ℂ` with `Fintype`/`DecidableEq` abstraction where feasible, but do not hesitate to specialize to `Fin n` when Mathlib spectral tools are easier there. If the full CPTP formalization is too heavy, formalize a diagonal / commuting / self-adjoint finite-matrix core first and then lift to the strongest generality you can prove with zero sorries.

---

## FILE 1: `Physics/QuantumInfo/VonNeumannEntropy.lean`

### Core definitions to introduce

Define at least the following, with doc comments explicitly mentioning bridges to physics, classical information theory, and cryptographic entropy accounting:

```lean
open Complex Matrix BigOperators Real

noncomputable section

namespace Physics
namespace QuantumInfo

abbrev DensityMatrix (n : ℕ) := Matrix (Fin n) (Fin n) ℂ

def IsHermitianDM {n : ℕ} (ρ : DensityMatrix n) : Prop := ρ.IsHermitian

def traceOne {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  Matrix.trace (Fin n) ℂ ℂ ρ = 1

def positiveSemidefinite {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  ∀ v : Fin n → ℂ, 0 ≤ Complex.re (dotProduct (star v) (ρ.mulVec v))

def IsDensityMatrix {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  IsHermitianDM ρ ∧ positiveSemidefinite ρ ∧ traceOne ρ

def isPure {n : ℕ} (ρ : DensityMatrix n) : Prop :=
  IsDensityMatrix ρ ∧ ρ ⬝ ρ = ρ

def maximallyMixed (n : ℕ) : DensityMatrix n :=
  ((n : ℂ)⁻¹) • (1 : DensityMatrix n)

def spectralProbabilities (n : ℕ) (ρ : DensityMatrix n) : Fin n → ℝ := ...

def shannonEntropyFin (n : ℕ) (p : Fin n → ℝ) : ℝ :=
  - ∑ i, p i * Real.log (p i)

def vonNeumannEntropy (n : ℕ) (ρ : DensityMatrix n) : ℝ := ...

def purity (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  Complex.re (Matrix.trace (Fin n) ℂ ℂ (ρ ⬝ ρ))

def entropyDefect (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  Real.log n - vonNeumannEntropy n ρ

def spectralGapLowerWitness (n : ℕ) (ρ : DensityMatrix n) : Prop := ...

def diagonalDensity (n : ℕ) (p : Fin n → ℝ) : DensityMatrix n := ...

def ClassicalQuantumBridge (n : ℕ) (ρ : DensityMatrix n) : Prop := ...
```

You should define `spectralProbabilities` and `vonNeumannEntropy` in the strongest way Mathlib supports. If a direct eigenvalue list API is painful, introduce an auxiliary predicate/structure encapsulating a spectral decomposition:

```lean
structure FiniteSpectralData (n : ℕ) where
  eig : Fin n → ℝ
  eig_nonneg : ∀ i, 0 ≤ eig i
  eig_sum_one : (∑ i, eig i) = 1
  -- optionally add diagonalization witness if available
```

and then define

```lean
def vonNeumannEntropyOfSpectralData {n : ℕ} (s : FiniteSpectralData n) : ℝ := ...
```

followed by theorems showing that any density matrix admits such data in the intended restricted setting.

Also add at least 5 novel definitions beyond the bare minimum, such as:

```lean
def effectiveRank (n : ℕ) (ρ : DensityMatrix n) : ℝ := Real.exp (vonNeumannEntropy n ρ)
def purityGap (n : ℕ) (ρ : DensityMatrix n) : ℝ := 1 - purity n ρ
def entropyCompressionRatio (n : ℕ) (ρ : DensityMatrix n) : ℝ :=
  vonNeumannEntropy n ρ / Real.log n
def cryptoMinEntropyLowerProxy (n : ℕ) (ρ : DensityMatrix n) : ℝ := ...
def certifiedSpectralMargin (n : ℕ) (ρ : DensityMatrix n) : ℝ := ...
```

Use theorem names that explicitly carry impact keywords where natural, e.g.
`post_quantum_security_entropy_defect_bound`,
`quantum_certified_robustness_maximally_mixed_extremizer`,
`tropical_shannon_bridge_diagonal_state`.

---

## FILE 2: `Physics/QuantumInfo/HolevoCapacity.lean`

### Core definitions to introduce

Define finite ensembles and channels in a way that allows immediate proof of the diagonal/classical special case and then stronger cases if possible.

```lean
namespace Physics
namespace QuantumInfo

structure QuantumEnsemble (ι : Type*) (n : ℕ) [Fintype ι] where
  prob : ι → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum_one : (∑ i, prob i) = 1
  state : ι → DensityMatrix n
  state_isDensity : ∀ i, IsDensityMatrix (state i)

def averageState {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : DensityMatrix n := ∑ i, (E.prob i : ℂ) • E.state i

structure QuantumChannel (n m : ℕ) where
  toLinear : DensityMatrix n → DensityMatrix m
  preservesHermitian : ∀ ρ, IsHermitianDM ρ → IsHermitianDM (toLinear ρ)
  preservesTraceOne : ∀ ρ, traceOne ρ → traceOne (toLinear ρ)
  preservesPSD : ∀ ρ, positiveSemidefinite ρ → positiveSemidefinite (toLinear ρ)

def QuantumChannel.isCPTP {n m : ℕ} (Φ : QuantumChannel n m) : Prop := True
```

If complete positivity is too hard to encode honestly in the first pass, define a separate stronger predicate later or leave `isCPTP` as a placeholder predicate with clearly proved consequences only from the properties you actually use. However, do **not** use axioms or sorries. If you define `isCPTP := True` initially, then every theorem mentioning it must only use the trace-preserving / positivity data actually present in the structure; make that mathematically explicit in doc comments.

Then define:

```lean
def holevoQuantity {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : ℝ :=
  vonNeumannEntropy n (averageState E) - ∑ i, E.prob i * vonNeumannEntropy n (E.state i)

def outputEnsemble {ι : Type*} [Fintype ι] {n m : ℕ}
    (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) : QuantumEnsemble ι m := ...

def holevoQuantityAfterChannel {ι : Type*} [Fintype ι] {n m : ℕ}
    (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) : ℝ :=
  holevoQuantity (outputEnsemble Φ E)

def holevoCapacityUpper (m : ℕ) : ℝ := Real.log m

def diagonalClassicalChannel (n m : ℕ) := ...
def commutingEnsemble {ι : Type*} [Fintype ι] {n : ℕ} (E : QuantumEnsemble ι n) : Prop := ...
def channelEntropyGain (n m : ℕ) (Φ : QuantumChannel n m) (ρ : DensityMatrix n) : ℝ := ...
def postQuantumKeyLeakageProxy {ι : Type*} [Fintype ι] {n : ℕ} (E : QuantumEnsemble ι n) : ℝ := ...
```

---

## TARGET THEOREMS

You must prove a substantial chain of results, not just state them. Aim for 20+ theorems total across the two files, with at least 10 genuinely nontrivial proofs and diverse tactics. The following theorems are the minimum spine.

### Spectral and density-matrix lemmas

Provide exact Lean statements as close as possible to:

```lean
theorem maximallyMixed_isDensityMatrix {n : ℕ} (hn : 0 < n) :
    IsDensityMatrix (maximallyMixed n)

theorem diagonalDensity_isDensityMatrix {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    IsDensityMatrix (diagonalDensity n p)

theorem purity_eq_one_of_pure {n : ℕ} {ρ : DensityMatrix n}
    (hρ : isPure ρ) :
    purity n ρ = 1

theorem entropyDefect_nonneg {n : ℕ} (hn : 0 < n) {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    0 ≤ entropyDefect n ρ
```

If you realize `positiveSemidefinite` is awkward, prove useful helper lemmas:

```lean
theorem positiveSemidefinite_zero {n : ℕ} : positiveSemidefinite (0 : DensityMatrix n)
theorem positiveSemidefinite_add {n : ℕ} {ρ σ : DensityMatrix n} :
    positiveSemidefinite ρ → positiveSemidefinite σ → positiveSemidefinite (ρ + σ)
theorem positiveSemidefinite_smul_nonneg {n : ℕ} {r : ℝ} (hr : 0 ≤ r) {ρ : DensityMatrix n} :
    positiveSemidefinite ρ → positiveSemidefinite ((r : ℂ) • ρ)
```

These are good places to use `linarith`, `ring_nf`, `nlinarith`, and direct unfolding.

### Eigenvalue / spectral probability theorems

In the strongest setting you can support, prove:

```lean
theorem eigenvalues_nonneg {n : ℕ} {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    ∀ i, 0 ≤ spectralProbabilities n ρ i

theorem eigenvalues_sum_one {n : ℕ} {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    (∑ i, spectralProbabilities n ρ i) = 1

theorem vonNeumannEntropy_eq_shannon_spectrum {n : ℕ} {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    vonNeumannEntropy n ρ = shannonEntropyFin n (spectralProbabilities n ρ)
```

If the full theorem is only available for diagonal or commuting matrices, prove the diagonal version first with exact names:

```lean
theorem vonNeumannEntropy_eq_shannon_diagonal {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) = shannonEntropyFin n p
```

This theorem is the key bridge between quantum physics and classical information theory. It also underpins cryptographic entropy accounting and algorithmic computation of capacity.

### Entropy bounds

Prove the core entropy inequalities:

```lean
theorem vonNeumannEntropy_nonneg {n : ℕ} {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    0 ≤ vonNeumannEntropy n ρ

theorem shannonEntropyFin_le_log_card {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    shannonEntropyFin n p ≤ Real.log n

theorem vonNeumannEntropy_le_log_dim {n : ℕ} (hn : 0 < n) {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    vonNeumannEntropy n ρ ≤ Real.log n

theorem vonNeumannEntropy_maximallyMixed {n : ℕ} (hn : 0 < n) :
    vonNeumannEntropy n (maximallyMixed n) = Real.log n
```

Also add a quantitative normalization theorem with an explicit Lipschitz-style output bound, even if only for diagonal states:

```lean
theorem entropyCompressionRatio_mem_unitInterval {n : ℕ} (hn : 1 < n) {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    0 ≤ entropyCompressionRatio n ρ ∧ entropyCompressionRatio n ρ ≤ 1
```

### Zero-entropy / purity characterization

Prove the strongest version you can. Target:

```lean
theorem vonNeumannEntropy_eq_zero_iff_pure {n : ℕ} {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    vonNeumannEntropy n ρ = 0 ↔ isPure ρ
```

If full generality is too hard, prove the diagonal or commuting version:

```lean
theorem vonNeumannEntropy_eq_zero_iff_pure_diagonal {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1) :
    vonNeumannEntropy n (diagonalDensity n p) = 0 ↔ ∃ i, p i = 1
```

and then derive a matrix purity statement for the corresponding diagonal density matrix. This is an excellent place for `by_contra`, `have`, `rcases`, and finite-support combinatorics.

### Holevo quantity and capacity bounds

Prove:

```lean
theorem averageState_isDensityMatrix {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (E : QuantumEnsemble ι n) :
    IsDensityMatrix (averageState E)

theorem holevoQuantity_nonneg_diagonal {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (E : QuantumEnsemble ι n)
    (hcomm : commutingEnsemble E) :
    0 ≤ holevoQuantity E

theorem holevoQuantity_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (E : QuantumEnsemble ι n) :
    0 ≤ holevoQuantity E
```

If the full noncommutative statement is unavailable, make the diagonal/commuting theorem your flagship theorem and state the general conjecture precisely in comments. But prove the strongest theorem you can.

Then prove the capacity upper bound:

```lean
theorem holevoQuantity_le_log_dim {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (hn : 0 < n) (E : QuantumEnsemble ι n) :
    holevoQuantity E ≤ Real.log n
```

The clean proof path is:
1. `averageState_isDensityMatrix`
2. `vonNeumannEntropy_le_log_dim` on the average state
3. `vonNeumannEntropy_nonneg` on each state
4. `linarith`

Also prove a channelized version:

```lean
theorem holevoQuantityAfterChannel_le_output_log_dim
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n m : ℕ} (hm : 0 < m) (Φ : QuantumChannel n m) (E : QuantumEnsemble ι n) :
    holevoQuantityAfterChannel Φ E ≤ Real.log m
```

This is the formal seed of finite-dimensional Holevo capacity. It bridges quantum thermodynamics, classical communication limits, and post-quantum key-rate upper bounds.

---

## ADDITIONAL HIGH-VALUE THEOREMS TO INCLUDE

Add at least 10 more theorems chosen from the following list, or stronger variants:

```lean
theorem shannonEntropyFin_nonneg ...
theorem shannonEntropyFin_eq_zero_of_pointmass ...
theorem shannonEntropyFin_le_log_supportSize ...
theorem maximallyMixed_trace ...
theorem maximallyMixed_purity_formula ...
theorem pure_state_entropy_defect_eq_log_dim ...
theorem effectiveRank_le_dim ...
theorem effectiveRank_eq_dim_of_maximallyMixed ...
theorem post_quantum_security_entropy_defect_bound ...
theorem quantum_certified_robustness_entropy_margin ...
theorem tropical_shannon_bridge_diagonal_state ...
theorem channelEntropyGain_upper_by_log_dim ...
theorem postQuantumKeyLeakageProxy_nonneg ...
theorem holevoQuantity_eq_classical_mutualInfo_diagonal ...
theorem averageState_diagonal_formula ...
theorem outputEnsemble_prob_invariant ...
theorem outputEnsemble_averageState_formula ...
theorem vonNeumannEntropy_concave_commuting_family ...
theorem holevo_crypto_leakage_bridge ...
theorem entropy_defect_purity_tradeoff_diagonal ...
```

For example, a useful computational theorem:

```lean
theorem effectiveRank_le_dim {n : ℕ} (hn : 0 < n) {ρ : DensityMatrix n}
    (hρ : IsDensityMatrix ρ) :
    effectiveRank n ρ ≤ n
```

proved by combining `Real.exp_le_exp.mpr` with `vonNeumannEntropy_le_log_dim` and `Real.exp_log`.

Another useful bridge theorem:

```lean
theorem holevo_crypto_leakage_bridge {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (E : QuantumEnsemble ι n) :
    postQuantumKeyLeakageProxy E = holevoQuantity E
```

---

## PROOF STRATEGY

### Strategy A: Diagonal / commuting first, then lift
This is the most promising route for zero-sorry completion.

1. Define `diagonalDensity n p` explicitly with diagonal entries `(p i : ℂ)` and off-diagonal zero.
2. Prove hermitianity, trace-one, and PSD directly for diagonal states using coordinate expansions.
3. Define `vonNeumannEntropy` for diagonal/commuting states via `shannonEntropyFin` of spectral probabilities.
4. Prove `shannonEntropyFin_nonneg` and `shannonEntropyFin_le_log_card` using standard real inequalities:
   - `x * log x ≥ 0` after sign handling for `x ∈ [0,1]`
   - Jensen/Gibbs if available, otherwise finite KL-divergence style rearrangement in a specialized form
   - pointwise bound `-x log x ≤ 1/e` for auxiliary estimates if needed
5. Deduce quantum statements for diagonal states immediately.
6. Package commuting ensembles as simultaneously diagonalizable if available; otherwise define `commutingEnsemble` to mean “all states are diagonal in the chosen basis” for the first pass.

This route yields a strong classical-quantum bridge and already formalizes the finite Holevo bound in the commuting case, which is mathematically meaningful and highly reusable.

### Strategy B: Spectral-data abstraction
If direct eigenvalue APIs are awkward, avoid fighting the library.

1. Introduce `FiniteSpectralData n`.
2. Prove entropy theorems once for arbitrary `FiniteSpectralData`.
3. Provide constructors from diagonal states immediately.
4. If spectral decomposition theorems are available for self-adjoint matrices, add a theorem producing spectral data from `IsDensityMatrix`.
5. Then define `vonNeumannEntropy` through chosen spectral data in the restricted setting where existence/uniqueness is manageable.

This separates analytic entropy inequalities from matrix representation details and is likely the cleanest architecture.

### Strategy C: Capacity bound by algebraic convexity shadow
For Holevo bounds, you do not need the full machinery of strong subadditivity.

1. Show `averageState E` is a density matrix by linearity of trace and convexity of PSD.
2. Apply `vonNeumannEntropy_le_log_dim` to the average.
3. Use nonnegativity of the component entropies to discard the subtraction term.
4. Conclude by `linarith`.

This gives a robust upper bound with direct cryptographic interpretation: no ensemble can leak more than `log n` nats through an `n`-dimensional system.

### Concrete proof steps and key lemmas
Use these patterns explicitly:

1. **Trace computations**
   ```lean
   simp [maximallyMixed, traceOne, Matrix.trace, Finset.mul_sum, Finset.sum_mul]
   field_simp
   ```
   Expect to need `hn : 0 < n` to justify `(n : ℂ) ≠ 0`.

2. **PSD closure under convex combinations**
   Unfold `positiveSemidefinite`; for `averageState`, show
   ```lean
   Complex.re (dotProduct (star v) ((∑ i, (E.prob i : ℂ) • E.state i).mulVec v))
   =
   ∑ i, E.prob i * Complex.re (dotProduct (star v) ((E.state i).mulVec v))
   ```
   then apply `Finset.sum_nonneg`; use `linarith`.

3. **Entropy nonnegativity**
   Reduce to showing each summand satisfies `0 ≤ -p i * log (p i)`.
   Split cases:
   ```lean
   by_cases h0 : p i = 0
   · simp [h0]
   · have hp : 0 < p i := lt_of_le_of_ne (hp_nonneg i) (Ne.symm h0)
     have hle1 : p i ≤ 1 := ...
     have hlog : Real.log (p i) ≤ 0 := Real.log_nonpos hle1 hp
     nlinarith
   ```

4. **Entropy upper bound**
   Most promising is a classical theorem already in Mathlib if available; otherwise prove for finite distributions using nonnegativity of KL divergence against uniform:
   ```lean
   ∑ i, p i * Real.log (p i / (1/n)) ≥ 0
   ```
   expand to obtain
   `-∑ p i log p i ≤ log n`.
   This is a beautiful bridge to statistical mechanics and cryptographic distinguishability.

5. **Zero entropy iff point mass / purity**
   Use `by_contra`:
   if no coordinate equals `1`, then at least two positive weights or one weight in `(0,1)`, hence a strictly positive entropy summand. For finite types, derive a witness with `Finset.exists_ne_of_one_lt_card` or direct contradiction from `∑ p i = 1`.

6. **Holevo upper bound**
   ```lean
   have havg := averageState_isDensityMatrix E
   have hSavg : vonNeumannEntropy n (averageState E) ≤ Real.log n :=
     vonNeumannEntropy_le_log_dim hn havg
   have hterm : 0 ≤ ∑ i, E.prob i * vonNeumannEntropy n (E.state i) := ...
   linarith [hSavg, hterm]
   ```

Use diverse tactics deliberately: `induction` over finite sums where natural, `rcases` for witness extraction in zero-entropy arguments, `by_contra` for extremal characterization, `omega` for dimension/cardinality side conditions, `linarith`/`nlinarith` for real inequalities, `field_simp` for maximally mixed calculations, and `simp` only as a finishing tool.

---

## CROSS-DOMAIN CONNECTIONS TO MAKE EXPLICIT IN DOC COMMENTS AND THEOREM NAMES

Every major definition and theorem should mention at least one bridge such as:

- **Physics ↔ Classical Information Theory**: `vonNeumannEntropy_eq_shannon_diagonal`
- **Quantum ↔ Cryptography**: `post_quantum_security_entropy_defect_bound`
- **Quantum ↔ ML certified robustness**: `quantum_certified_robustness_entropy_margin`
- **Quantum ↔ Tropical / algebraic**: `tropical_shannon_bridge_diagonal_state`

Suggested theorem names with impact keywords:
- `post_quantum_security_entropy_defect_bound`
- `quantum_thermodynamic_log_dim_barrier`
- `lipschitz_certified_robustness_entropyCompressionRatio`
- `holevo_post_quantum_key_capacity_ceiling`
- `tropical_shannon_bridge_diagonal_state`

For example, formalize a bridge theorem of the form:

```lean
theorem post_quantum_security_entropy_defect_bound {n : ℕ} (hn : 0 < n)
    {ρ : DensityMatrix n} (hρ : IsDensityMatrix ρ) :
    0 ≤ cryptoMinEntropyLowerProxy n ρ ∧
    cryptoMinEntropyLowerProxy n ρ ≤ Real.log n
```

and

```lean
theorem quantum_certified_robustness_maximally_mixed_extremizer {n : ℕ} (hn : 0 < n)
    {ρ : DensityMatrix n} (hρ : IsDensityMatrix ρ) :
    vonNeumannEntropy n ρ ≤ vonNeumannEntropy n (maximallyMixed n)
```

---

## COMPUTATIONAL / ALGORITHMIC SHADOWS

Include explicit complexity-oriented statements in comments and, where possible, simple theorem wrappers:

1. For diagonal states, entropy computation is `O(n)` after probabilities are given.
2. Holevo bound verification for diagonal ensembles is `O(|ι| * n)`.
3. Effective rank is bounded by dimension:
   ```lean
   theorem effectiveRank_le_dim ...
   ```
4. Add a theorem that normalized entropy lies in `[0,1]`:
   this gives a certified feature usable in ML-style robustness pipelines.

Suggested additional definitions:

```lean
def entropyEvaluationCost (n : ℕ) : ℕ := n
def holevoEvaluationCost (ι_card n : ℕ) : ℕ := ι_card * n
def certifiedCapacityGap {ι : Type*} [Fintype ι] {n : ℕ}
    (E : QuantumEnsemble ι n) : ℝ :=
  Real.log n - holevoQuantity E
```

with theorems

```lean
theorem certifiedCapacityGap_nonneg ...
theorem holevoEvaluationCost_linear ...
```

Even if these are simple, they improve utility and provide a computational narrative.

---

## MINIMAL HYPOTHESIS DISCIPLINE

Whenever possible, use the weakest hypotheses:
- `hn : 0 < n` rather than stronger assumptions
- `[Fintype ι] [DecidableEq ι]` only when needed for finite sums
- avoid unnecessary `NormedRing` abstractions unless they genuinely help
- if a theorem is diagonal/classical, state it that way explicitly rather than pretending full generality

Also include at least a few theorems with quantifier alternation, e.g.

```lean
theorem entropy_zero_witness_exists {n : ℕ} (p : Fin n → ℝ)
    (hp_nonneg : ∀ i, 0 ≤ p i) (hp_sum : (∑ i, p i) = 1)
    (hzero : shannonEntropyFin n p = 0) :
    ∃ i, ∀ j, j ≠ i → p j = 0
```

and

```lean
theorem pure_state_has_spectral_atom {n : ℕ} {ρ : DensityMatrix n}
    (hρ : isPure ρ) :
    ∃ i, spectralProbabilities n ρ i = 1
```

---

## FAILURE CASCADE IF FULL GENERALITY RESISTS

Do not stall on the full noncommutative spectral theorem if library friction is too high. Instead complete, in order:

1. Full theory for diagonal density matrices.
2. Holevo nonnegativity and upper bounds for diagonal / commuting ensembles.
3. Average-state density lemmas for general convex combinations.
4. Spectral-data abstraction layer.
5. Any general-lift theorem that Mathlib permits without axioms.

The strongest acceptable fallback theorem is a complete diagonal finite-dimensional development with:
- entropy = Shannon entropy,
- nonnegativity,
- `≤ log n`,
- equality at maximally mixed,
- zero iff pure/point mass,
- Holevo nonnegativity for commuting/diagonal ensembles,
- Holevo `≤ log n`.

That already constitutes a meaningful formalization of the finite Holevo bound in the classical-quantum interface and directly supports catalog results on `holevo_classical_bound`, `QuantumClassicalGap`, `key_derivation_entropy_gap`, and `post_quantum_key_security`.

---

## DELIVERABLE SHAPE

The files should read like a research-grade mathematical narrative, not a pile of isolated lemmas. Include:

1. Definitions section
2. Basic matrix/density lemmas
3. Shannon entropy lemmas on finite distributions
4. Quantum entropy via diagonal/spectral bridge
5. Extremizers: pure states and maximally mixed states
6. Holevo quantity and channel output ensembles
7. Capacity upper bounds and cryptographic bridge theorems

Produce substantial content: 20+ theorems total, 10+ definitions total, zero sorries, and explicit doc comments containing phrases like:

- `Bridge: connects quantum thermodynamic entropy to classical Shannon coding.`
- `Bridge: connects Holevo information to post_quantum_security leakage proxies.`
- `Bridge: connects normalized entropy certificates to lipschitz_certified_robustness style features.`

Conclude by creating `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps such as:
1. lift diagonal Holevo nonnegativity to general CPTP maps via relative entropy monotonicity,
2. formalize complete positivity via Kraus operators / Choi matrices,
3. derive Fannes-type continuity bounds with explicit dimension-dependent constants,
4. connect entropy defect to lattice-based post-quantum key leakage metrics,
5. formalize accessible information lower/upper bounds for finite ensembles.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Formalize finite-dimensional density matrices and von Neumann entropy, then prove the foundational entropy bounds 0 ≤ S(ρ) ≤ log(dim) together with a finite-channel Holevo upper bound for accessible classical information. The specific target is a Lean development where density operators are positive semidefinite trace-1 matrices, entropy is defined spectrally, pure states are characterized by zero entropy, maximally mixed states achieve maximal entropy, and for finite ensembles through a quantum channel Φ one proves the Holevo quantity χ({p_i,ρ_i}) is nonnegative and bounded by log(dim). This directly extends Aristotle's top-ranked quantum-information recommendation while avoiding current inflight topics and overused tropical directions.

            ### Precise Mathematical Framing
            Work in finite-dimensional complex matrix algebras M_n(C). Define DensityMatrix n := {ρ : Matrix n n ℂ // ρ.IsHermitian ∧ ρ.PosSemidef ∧ trace ρ = 1}. Define von Neumann entropy by spectral decomposition S(ρ) = -∑_λ mult(λ) * λ * log λ with the convention 0 log 0 = 0. Prove: (1) spectral probabilities of a density matrix lie in [0,1] and sum to 1; (2) S(ρ) equals Shannon entropy of the eigenvalue distribution; (3) nonnegativity S(ρ) ≥ 0; (4) upper bound S(ρ) ≤ log n with equality for ρ = I/n; (5) S(ρ)=0 iff ρ is rank-1/pure; (6) for a CPTP map Φ and finite ensemble {(p_i,ρ_i)}, χ = S(Φ(∑ p_iρ_i)) - ∑ p_i S(Φ(ρ_i)) is bounded above by log n and recovers the existing `holevo_classical_bound` in quantitative form. The proof pipeline uses matrix spectral theorem, concavity of x ↦ -x log x on [0,1], Jensen/Karamata over eigenvalues, and trace preservation under channels. Algorithmically, the formalization yields a reusable entropy/capacity API for later quantum coding and QKD security proofs.

            ### Lean 4 Sketch
Create Physics/QuantumInfo/VonNeumannEntropy.lean and Physics/QuantumInfo/HolevoCapacity.lean. Definitions: `DensityMatrix`, `isPure`, `maximallyMixed`, `vonNeumannEntropy`, `QuantumChannel.isCPTP`, `holevoQuantity`. Core lemmas: `eigenvalues_nonneg`, `eigenvalues_sum_one`, `vonNeumannEntropy_eq_shannon_spectrum`, `vonNeumannEntropy_nonneg`, `vonNeumannEntropy_le_log_dim`, `vonNeumannEntropy_maximallyMixed`, `vonNeumannEntropy_eq_zero_iff_pure`, `holevoQuantity_nonneg`, `holevoQuantity_le_log_dim`. Use finite-dimensional spectral decomposition lemmas already available for Hermitian matrices where possible, otherwise restrict initially to diagonalizable/self-adjoint finite matrices.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_holevo_dominant_bound` : theorem tropical_holevo_dominant_bound {n : ℕ} (h : ℝ) (ψ : Fin (n + 1) → ℝ)
     (file: Physics/TropicalQuantum/Advanced.lean)
  2. `quantum_singleton_bound` : theorem quantum_singleton_bound (p : StabilizerCodeParams) (hv : p.singletonValid) :
     (file: Physics/PauliClosureFoundations.lean)
  3. `classical_CHSH_bound` : theorem classical_CHSH_bound (a a' b b' : ℤ)
     (file: Physics/Quantum/MoonshotQuantum.lean)
  4. `quantum_singleton_bound` : theorem quantum_singleton_bound (L : ℕ) (hL : L ≥ 1) :
     (file: Physics/Quantum/ToricCode.lean)
  5. `quantum_birthday_bound` : theorem quantum_birthday_bound (S : ℕ) (hS : 0 < S) :
     (file: Physics/QuantumE8ModularForms.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: tropical_cryptography_breakthrough_bridge, tropical_cryptography_breakthrough_bridge, Foundations of Information-Theoretic Shared Structures


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Physics
Research mode: formalize
