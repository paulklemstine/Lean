# Future Directions — Quantum Hamiltonian Complexity & the Local Hamiltonian Problem

## Synthesis

This cycle extended `Physics/LocalHamiltonianQMA.lean` from an additive *energy
lower-bound* algebra (`EnergyLB`, `energyLB_add`, `energyLB_sum`, the soundness lemma
`promise_gap_consistent`, and the single-qubit frustration witness
`frustration_no_common_ground_state`) into a full **spectral + variational layer** that
makes Kitaev's projector picture quantitative. The new results sit in the same
`LocalHamiltonian` namespace and reuse `qform`, `normSq2`, `EnergyLB`, `IsYesWitness`,
`qform_add`, and `normSq2_eq_zero_iff` directly, rather than re-deriving them.

The new backbone is the **Gram identity** `qform_gram_eq : (qform (Aᴴ * A) x).re =
normSq2 (A.mulVec x)`. From this one identity we obtain, uniformly:

* `gram_energyLB_zero` — every penalty Hamiltonian `Aᴴ A` is positive semidefinite;
* `IsHermIdem.energyLB_zero` — every projector (Hermitian idempotent, the canonical
  Kitaev local term) carries the certificate `EnergyLB · 0`;
* `qform_eigenvector_re` / `energyLB_le_eigenvalue` — a certified lower bound is a
  *genuine* lower bound on the discrete spectrum (Kitaev soundness via the Rayleigh
  quotient);
* `frustrationFree_total_energy_zero` — in the YES (frustration-free) case the additive
  bound `∑ 0 = 0` is achieved exactly;
* `energyLB_le_witness` — a normalized witness sandwiches the certificate below the
  threshold (`lam ≤ a`), the numeric strengthening of `promise_gap_consistent`.

Together these close the loop `certified lower bound ≤ ground energy ≤ witness upper
bound`, the variational skeleton of the promise-gap separation underpinning
QMA-completeness.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `qform_gram_eq` | `(qform (Aᴴ*A) x).re = ‖A x‖²` | PSD engine for all penalty terms |
| `gram_energyLB_zero` | `EnergyLB (Aᴴ*A) 0` | every penalty Hamiltonian ≥ 0 |
| `IsHermIdem.energyLB_zero` | projector ⇒ `EnergyLB P 0` | Kitaev local terms are ≥ 0 |
| `qform_eigenvector_re` | Rayleigh quotient = eigenvalue·‖x‖² | spectral meaning of `qform` |
| `energyLB_le_eigenvalue` | `EnergyLB H lam ⇒ lam ≤ μ` | soundness: bounds the spectrum |
| `frustrationFree_total_energy_zero` | common ground state ⇒ total energy 0 | YES case is tight |
| `energyLB_le_witness` | `EnergyLB H lam ∧ YesWitness a ⇒ lam ≤ a` | promise-gap sandwich |
| `energyLB_mono`, `energyLB_smul_nonneg` | order-ideal + nonneg scaling | certificate calculus closure |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`; no `sorry`.

## Research Directions

### 1. Super-additivity of ground energy as a quantitative frustration measure
We proved that frustration-free families achieve the additive bound `∑ 0 = 0` exactly
(`frustrationFree_total_energy_zero`), and that `EnergyLB` is super-additive
(`energyLB_sum`). The natural next object is the *frustration gap*
`F(H) = groundEnergy(∑ Hᵢ) − ∑ groundEnergy(Hᵢ) ≥ 0`, conjecturally strictly positive
iff no common ground state exists. **The key insight is** that the existing
`frustration_no_common_ground_state` witness (terms `(I−Z)/2`, `(I−X)/2`) should be
upgradeable to a *numeric* lower bound `F ≥ c > 0` provable by exhibiting an explicit
`EnergyLB (Hz + Hx) c` with `c > 0` while each term has ground energy `0`. **Why now?**
The PSD machinery (`gram_energyLB_zero`) plus `qform_eigenvector_re` already lets us
compute exact energies on `Fin 2`, so the constant `c` is a finite, decidable
eigenvalue computation rather than an abstract estimate.

### 2. Spectral gap amplification under tensoring / direct sums
`energyLB_le_eigenvalue` shows certificates bound single eigenvalues. Conjecture: for
block-diagonal `H ⊕ H'`, `EnergyLB (H ⊕ H') (min lam lam')`, and for Kronecker products
of PSD terms the certificate multiplies. **The key insight is** that `qform_gram_eq`
tensorizes: `(A ⊗ B)ᴴ (A ⊗ B) = (Aᴴ A) ⊗ (Bᴴ B)`, so positive semidefiniteness is
closed under `⊗`, giving a constructive amplification of `EnergyLB · 0` certificates
across qubits. **Why now?** Mathlib has `Matrix.kroneckerMap` with the mixed-product
law already; the PSD-closure proof is a direct corollary of the Gram identity we just
established, with no new analytic input.

### 3. Decidable promise-gap verification over ℚ-Hamiltonians
`energyLB_le_witness` reduces a NO-certificate to a single inequality on `normSq2`.
Conjecture: for Hamiltonians with Gaussian-rational entries and rational witnesses,
the predicate `EnergyLB H lam` restricted to a finite rational state lattice is
*decidable*, yielding a verifiable QMA-style checker. **The key insight is** that
`qform` and `normSq2` are polynomial in the (real, imaginary) coordinates, so a
certificate becomes a positivity statement amenable to `decide`/`polyrith` once the
field is `ℚ`. **Why now?** The `Fin 2` examples (`qform_Hz`, `qform_Hx`) already
evaluate symbolically; generalizing to a `decide`-backed checker is an engineering step
on top of the existing computational lemmas.

### 4. From projectors to the Kitaev clock: history-state lower bounds
The reduction's heart is the *clock Hamiltonian* whose ground space is spanned by
history states `∑_t |t⟩|ψ_t⟩`. Conjecture: the clock term is a projector
(`IsHermIdem`) and its `EnergyLB · 0` certificate, combined additively
(`energyLB_sum`) with propagation terms, yields a polynomially small spectral gap.
**The key insight is** that each Kitaev term `H_prop,t = ½(|t⟩⟨t| + |t+1⟩⟨t+1| −
U_t|t+1⟩⟨t| − U_t†|t⟩⟨t+1|)` is exactly `½ Bᴴ B` for an isometry-difference `B`, so
`gram_energyLB_zero` applies term-by-term. **Why now?** We now have both the PSD
certificate for each term and the additive composition law, the two ingredients needed
to state (and bound) the clock Hamiltonian without leaving the current namespace.

### 5. A variational characterization of QMA-completeness thresholds
Combining `energyLB_le_witness` (upper) with `energyLB_le_eigenvalue` (lower) gives a
sandwich `lam ≤ groundEnergy ≤ a`. Conjecture: the promise problem is *exactly* the
question of whether this sandwich can be closed to width `< (b−a)` in polynomial
certificate size, and the gap `b−a` is preserved under the amplification of Direction 2.
**The key insight is** that the two one-sided bounds we proved are dual linear
functionals on the state space, so the promise gap is literally a duality gap of a
semidefinite feasibility problem over PSD penalty terms. **Why now?** With both
inequalities formalized and the PSD-closure conjectured in Direction 2, the SDP-duality
framing is the minimal abstraction that unifies all current lemmas into a single
complexity-theoretic statement.
