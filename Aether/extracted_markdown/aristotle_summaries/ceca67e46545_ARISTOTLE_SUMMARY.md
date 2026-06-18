# Summary of changes for run 0bb62dee-5ef5-4dfa-aafa-aad90182d3d6
Added a new self-contained Lean development on ordinal analysis / ordinal collapsing functions, plus the required research conjectures.

**New file:** `Catalog/Logic/OrdinalCollapsingBridge.lean` (namespace `ProofTheoreticBridge`), built on Mathlib's Veblen hierarchy (`Ordinal.veblen`) and fixed-point API (`nfp`, `deriv`).

Definitions:
- `eps0 = veblen 1 0` — ε₀, the proof-theoretic ordinal of Peano Arithmetic.
- `psiOmegaOmega = nfp (veblen · 0) 0` — Γ₀, the Feferman–Schütte ordinal, which in Bachmann–Buchholz collapsing notation is exactly ψ(Ω^ω).
- `ptStrength o = veblen o 0` — the explicit order-preserving "bridge" from system-indexing ordinals to proof-theoretic strengths.

Theorems proved with complete, machine-checked proofs (no `sorry` reaches any of them; each depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`, confirmed via `#print axioms`):
- `omega_opow_eps0` : ω^ε₀ = ε₀ (ε₀ is an epsilon number).
- `eps0_least` : ε₀ is the least epsilon number.
- `omega0_le_eps0`, `one_lt_eps0`, `eps0_eq_nfp`, `ptStrength_zero`, `ptStrength_one` (supporting facts).
- `psiOmegaOmega_fp` : Γ₀ is strongly critical (a fixed point of the diagonal Veblen map).
- **`eps0_lt_psiOmegaOmega`** : the headline separation ε₀ < ψ(Ω^ω).
- `ptStrength_strictMono` : the bridge map is strictly monotone (order-preserving).
- `ptStrength_lt_psiOmegaOmega` : everything below Γ₀ stays below Γ₀ (Veblen-closure).
- `psiOmegaOmega_least_strongly_critical` : Γ₀ is the least strongly critical ordinal.
- `bridge_PA_below_psi` plus two `example` blocks (an in-action check and a boundary case showing 0 is not strongly critical).

One clearly-labelled open strengthening, `epsilon_numbers_unbounded_below_psi` (unboundedness of epsilon numbers below Γ₀), is left as an explicit `sorry`; a low-effort proof attempt did not succeed and it is documented as future work.

Each theorem carries a brief proof-sketch comment. The file compiles cleanly with the project's Lean/Mathlib toolchain.

**`FUTURE_DIRECTIONS.md`** (project root): five concrete, falsifiable research directions extending the work (closing the unboundedness sorry; the two-variable Veblen-closure characterization of Γ₀; the ε-tower via `veblen 1`; bundling the bridge as an `OrderEmbedding`/`OrderIso`; and linking ε₀ to Cantor normal form), each with a "The key insight is..." sentence and a "Why now?" justification.