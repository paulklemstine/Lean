# Future Directions — Noise-Stable Prime Spectrum in Definable Quantum Walks

## Synthesis

The file `Catalog/Shared/NoiseStablePrimeSpectrum.lean` reduces the whole
"definable quantum walk" program to a single, fully formal object: the
additive-character eigenvalue function

```
ceig S j = ∑_{s ∈ S} ψ(j·s),   ψ = ZMod.stdAddChar : ZMod n → ℂ.
```

This *is* the spectrum of the circulant walk generator on the Cayley graph
`Cay(ZMod n, S)`, simultaneously diagonalized in the Fourier basis. Around it we
proved four structural pillars, all with `sorry = 0` and only the standard
axioms `propext, Classical.choice, Quot.sound`:

- **Trace / orthogonality** (`ceig_total`): `∑_j ceig S j = n·[0 ∈ S]`.
- **Hermitian spectrum** (`ceig_conj`): symmetric step sets ⇒ real eigenvalues.
- **Complete-graph spectrum** (`ceig_complete`): the maximally degenerate
  fragile walk `{n−1, −1, …, −1}`.
- **Noise stability** (`weig_perturbation_le`, `weig_perturbation_uniform`):
  eigenvalues are `ℓ¹`-Lipschitz in the gate amplitudes, the rigorous core of
  the conjectured "Wasserstein-`O(ε)`" stability under gate perturbations.

The decisive surprise of this cycle is a *negative* discovery that reshapes the
whole conjecture: the arithmetic squarefree/prime-power separation does **not**
come from the perturbation bound (which is uniform and arithmetic-blind), but
from the *unperturbed* spectrum itself, through Ramanujan sums. Mathlib currently
has **no Ramanujan-sum API**, so the separation must be *built*, not invoked.
The directions below are ordered to build exactly that missing bridge.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `ceig_zero_eq_card` | `ceig S 0 = |S|` | Perron/degree eigenvalue |
| `ceig_total` | `∑_j ceig S j = n·[0∈S]` | spectral trace, traceless ⇔ loop-free |
| `ceig_conj` | symmetric `S` ⇒ `conj (ceig S j) = ceig S j` | self-adjoint walk |
| `ceig_complete` | `ceig (univ\{0}) j = if j=0 then n−1 else −1` | extremal fragile spectrum |
| `weig_perturbation_le` | `‖Δ eig‖ ≤ ∑‖Δw‖` | `ℓ¹`-Lipschitz noise stability |
| `weig_perturbation_uniform` | `‖Δ eig‖ ≤ |T|·ε` | explicit `O(ε)` constant |

## Research Directions

### 1. The Ramanujan–Möbius eigenvalue and the squarefree/prime-power dichotomy
Define the **unit Cayley walk** with step set `S = (ZMod n)ˣ` (all gates coprime
to `n`). Its eigenvalue at mode `j = 1` is the Ramanujan sum
`c_n(1) = ∑_{a ∈ units} ψ(a)`, and the falsifiable claim is the clean identity
`ceig (units) 1 = μ(n)` (Möbius). Consequence: the eigenvalue **vanishes exactly
on non-squarefree `n`** and is `±1` on squarefree `n` — a sharp arithmetic
phase transition living in the spectrum itself.
*The key insight is* that the prime/squarefree separation the concept asks for is
not a noise phenomenon at all but the vanishing locus of a single character sum,
`μ(n) = 0 ⟺ n not squarefree`, so the entire dichotomy collapses to proving one
Möbius identity. *Why now?* All ingredients — `ZMod.stdAddChar`, primitivity,
and `Nat.ArithmeticFunction.moebius` — already exist in Mathlib; only the bridge
lemma `∑_{a∈units} ψ(a) = μ(n)` is missing, and the orthogonality engine
`AddChar.sum_mulShift` used in `ceig_total` is exactly the tool to prove it by
Möbius inversion over divisor subgroups.

### 2. CRT tensorization: why squarefree walks factor and prime powers do not
Formalize that for coprime `m, n` the ring iso `ZMod (m·n) ≃ ZMod m × ZMod n`
induces a multiplicative factorization `ceig_{mn}(S⊗T)(j) = ceig_m(S)(j₁)·ceig_n(T)(j₂)`.
A squarefree modulus then factors fully into a tensor product of `k` prime walks,
while a prime power `p^e` admits no such refinement.
*The key insight is* that the empirical spectral measure of a squarefree walk is a
`k`-fold *convolution* of prime spectra (hence smooth, low-discrepancy, stable),
whereas a prime-power spectrum is rigid and lumpy — the structural mechanism
behind the conjectured stability gap. *Why now?* `ZMod.chineseRemainder` and the
`AddChar` product API make the factorization provable, and it directly upgrades
`ceig_total` from a single modulus to the full multiplicative theory.

### 3. From eigenvalue Lipschitzness to a genuine Wasserstein bound on the spectral measure
Upgrade `weig_perturbation_le` (per-eigenvalue) to a bound on the
`W₁` Wasserstein distance between the empirical eigenphase measures
`μ_U = (1/n)∑_j δ_{arg ceig}` of the clean and noisy walks, via the
Hoffman–Wielandt inequality for normal/circulant matrices.
*The key insight is* that for circulant operators the optimal transport plan is the
identity pairing of Fourier modes, so the global Wasserstein distance is literally
the average of the per-mode bounds already proven — no transport optimization is
needed. *Why now?* The per-mode `ℓ¹` bound is in hand, and Mathlib's measure-theory
and `Finset`-average infrastructure suffice to assemble the `W₁` statement without
new analytic machinery.

### 4. A spectral-gap lower bound separating fragile from robust walks
Prove that the complete walk of `ceig_complete` has spectral gap exactly `n`
(distance between Perron value `n−1` and the degenerate bulk `−1`), and contrast
it with a quantitative *lower* bound `c > 0`, independent of `n`, on the minimal
eigenphase displacement induced by a unit-norm local perturbation on prime-power
moduli.
*The key insight is* that maximal eigenvalue degeneracy (as in `ceig_complete`) is
precisely what makes a perturbation's effect *non-cancelling*: a perturbation
inside a degenerate eigenspace shifts a whole block coherently, giving an
`n`-independent instability constant, while a non-degenerate (squarefree-spread)
spectrum absorbs it. *Why now?* `ceig_complete` already pins down the extremal
degenerate spectrum, giving a concrete first witness against which the lower bound
can be calibrated.

### 5. Definability and computability of the walk family in Lean
Make the "Lean-definable / step-set computable from `n`" clause of the conjecture
literal: provide a `DecidablePred`/computable `S : ℕ → Finset (ZMod n)` and a
`#eval`-able rational approximation of `ceig`, then certify the spectrum of small
moduli by `decide`/`norm_num`.
*The key insight is* that arithmetic certification of a quantum algorithm's
stability reduces to a *decidable* predicate on the finite spectrum once the step
set is computable, turning "is this walk noise-stable?" into a kernel-checkable
proposition. *Why now?* The catalog already prizes executable certificates
(cf. the expander-walk and Carmichael computations), and `ceig` over `ℚ[i]`-style
cyclotomic approximations is finite and decidable, so a fully verified
`example : ceig … = …` census of `n ≤ 30` is immediately within reach.
