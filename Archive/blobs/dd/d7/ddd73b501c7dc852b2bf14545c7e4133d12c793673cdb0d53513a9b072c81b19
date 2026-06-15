# Summary of changes for run 39181602-6717-406a-9946-a37f4ca58ee5
Delivered a self-contained Lean 4 research module plus a research roadmap for the concept "Noise-Stable Prime Spectrum in Definable Quantum Walks."

## Lean deliverable: `Catalog/Shared/NoiseStablePrimeSpectrum.lean`
The file formalizes discrete-time quantum walks on arithmetic Cayley graphs `Cay(ZMod n, S)` via their Fourier-diagonal eigenvalue function `ceig S j = ∑_{s∈S} ψ(j·s)`, where `ψ = ZMod.stdAddChar` is the standard additive character. It proves **6 theorems with `sorry = 0`**, each verified to depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `ceig_zero_eq_card` — the Perron/degree eigenvalue equals `|S|`.
- `ceig_total` — spectral trace / character orthogonality: `∑_j ceig S j = n·[0∈S]` (traceless ⇔ loop-free walk).
- `ceig_conj` — symmetric step sets give a real (Hermitian/self-adjoint) spectrum.
- `ceig_complete` — the complete Cayley walk has the maximally degenerate spectrum `{n−1, −1, …, −1}` (the extremal fragile walk).
- `weig_perturbation_le` and `weig_perturbation_uniform` — eigenvalues are ℓ¹-Lipschitz in the gate amplitudes, giving the rigorous core of the conjectured Wasserstein-`O(ε)` noise-stability bound (`‖Δ eig‖ ≤ |T|·ε`).

The file includes the required `-- !--` proof-sketch blocks before each theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis). It builds cleanly with no warnings, sorries, or leftover `exact?`/`simp?` calls, and the catalog-synthesis section connects the work to the existing expander/character-sum modules (`Algebra/ClassicalGroupExpanders`, `Algebra/ExpanderWalk/Amplification`).

Key methodological finding (recorded in the notebook): the arithmetic squarefree/prime-power separation the concept asks for is not a noise phenomenon — it lives in the *unperturbed* spectrum via the Ramanujan sum identity `c_n(1) = μ(n)`, which is currently absent from Mathlib. This negative result is what drives the roadmap rather than being forced prematurely.

## `FUTURE_DIRECTIONS.md`
A narrative synthesis plus a results-summary table and 5 falsifiable research directions, each with an explicit "The key insight is…" sentence and a "Why now?" justification: (1) proving `ceig(units) 1 = μ(n)` to realize the squarefree/prime-power dichotomy as a Möbius vanishing locus; (2) CRT tensorization of the spectrum across coprime factors; (3) upgrading the per-eigenvalue Lipschitz bound to a genuine W₁ Wasserstein bound via Hoffman–Wielandt; (4) a spectral-gap lower bound separating fragile from robust walks; (5) computable/decidable certification of the walk family.