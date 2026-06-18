# Future Directions — Reversible Computing and Thermodynamic Efficiency

## Synthesis

This cycle laid down a self-contained, axiom-clean Lean 4 foundation for the
thermodynamics of computation, organized around a single algebraic dichotomy:
a **bijection of the state space reindexes the entropy sum (entropy invariant)**,
whereas a **non-injective collapse contracts it (entropy drops)**. From this one
observation we obtained, with fully machine-checked proofs:

* `shannonEntropy_equiv_invariant` / `shannonEntropy_pushforward` — Shannon
  entropy is conserved by every reversible step.
* `landauerCost_reversible_eq_zero` — reversible computation dissipates exactly
  zero heat, for *every* input distribution.
* `erasureCost_eq` / `erasureCost_lower_bound` / `erasureCost_one_bit` —
  **Landauer's bound**: erasing an `n`-bit register dissipates exactly
  `n · kT · log 2`, i.e. `kT log 2` per bit.
* `bennett` / `bennett_apply_zero` / `bennettCost_eq_zero` — **Bennett's
  embedding** `(a,b) ↦ (a, b + f a)` realizes *any* function reversibly, computes
  it in a clean ancilla, and provably costs no heat.

Together these connect computational structure (injectivity/bijectivity of the
transition map) to a thermodynamic invariant (entropy, hence dissipated heat).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `shannonEntropy_equiv_invariant` | `H(P∘e) = H(P)` for `e : α ≃ β` | proved |
| `shannonEntropy_uniform` | `H(uniform) = log (card α)` | proved |
| `shannonEntropy_dirac` | `H(δ_{a₀}) = 0` | proved |
| `landauerCost_reversible_eq_zero` | reversible step ⇒ `cost = 0` | proved |
| `erasureCost_eq` | `n`-bit erase `= n·kT·log 2` | proved |
| `bennettCost_eq_zero` | Bennett embedding ⇒ `cost = 0` | proved |

All results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Maximality of the uniform distribution (Gibbs' inequality, finite form)

Conjecture: for every `P : FinDist α` on an `m`-state space,
`shannonEntropy P ≤ log m`, with equality iff `P = uniform`. The key insight is
that erasure cost is a *worst-case* statement precisely because uniform input
maximizes entropy; without this maximality the `n·kT·log 2` bound would only be
"typical", not extremal. Why now? We already have `shannonEntropy_uniform` and the
`FinDist` API; the missing piece is Jensen/`Real.add_pow_le_pow_mul_pow_of_sqrt`
style concavity of `x ↦ -x log x`, which Mathlib supports via `Real.inner_le_nnorm`-free
convexity lemmas (`Real.add_pow_le...`, `StrictConcaveOn`). This upgrades the
bound from "for the uniform input" to "for all inputs, at most".

### 2. Subadditivity and the data-processing direction

Conjecture: any (possibly irreversible) stochastic map can only *decrease* a
suitably defined entropy-production-adjusted free energy, so
`landauerCost ≥ kT · (H_in − H_out)` becomes a genuine inequality witnessed by
the non-injective part of the map. The key insight is that an arbitrary map
factors as "reversible embedding (Bennett) ∘ erasure of garbage", localizing all
dissipation in the erase step. Why now? `bennett` already gives the reversible
half constructively; pairing it with `erasureCost_eq` for the garbage register
would yield a decomposition theorem for *any* computable function's minimal cost.

### 3. Composition / circuit-level accounting

Conjecture: Landauer cost is additive along compositions of reversible gates and
exactly zero for any finite reversible circuit (a composite of `Equiv`s), so the
total dissipation of a circuit equals `kT log 2` times the number of bits erased
at readout. The key insight is that `Equiv` is closed under composition (`Equiv.trans`)
and `shannonEntropy_pushforward` is functorial, so cost telescopes. Why now? The
zero-cost theorem is already stated per-step; promoting it to `e₁.trans e₂` and to
`List (α ≃ α)` folds is a direct, mechanizable induction.

### 4. Toffoli/CNOT universality with zero cost

Conjecture: the Toffoli gate (a specific `Equiv` on `Bool³`) is reversible-universal,
and any Boolean function realized as a Toffoli network has Landauer cost zero up to
the final ancilla erasure. The key insight is that Bennett's embedding specializes,
when `β = Bool` with XOR as the group operation, exactly to controlled-NOT/Toffoli
logic, tying our abstract `bennett` to concrete hardware gates. Why now? We have
`bennett` for any additive group; instantiating `β = ZMod 2` (or `Bool` with `xor`)
makes the construction literally a CNOT, ready for a universality proof.

### 5. Quantitative bridge to the catalog's quantum entropy

Conjecture: the classical erasure bound `erasureCost_eq` is the diagonal (commuting)
case of a von Neumann erasure bound `kT · S(ρ)`, matching `Physics/HolevoCapacity.lean`'s
entropy conventions, so classical Landauer is recovered from the quantum statement by
restricting to diagonal density matrices. The key insight is that Shannon entropy of a
distribution equals von Neumann entropy of the corresponding diagonal density matrix.
Why now? The catalog already contains `Physics.QuantumInfo.VonNeumannEntropy`; building
a `FinDist → DensityMatrix` diagonal embedding and proving entropy agreement would
unify the classical and quantum thermodynamic-cost theories in one repository.
