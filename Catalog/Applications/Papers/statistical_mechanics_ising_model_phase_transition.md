# Computational Evidence — 2D Ising Model Phase Transition

All numbers below were checked against the formalized definitions; the decisive
identities are *proved* (0 sorries) in the accompanying Lean files.

## 1. Critical temperature / Kramers–Wannier self-duality

Units `J = k_B = 1`, `β_c = ½ ln(1+√2)`, `T_c = 2/ln(1+√2)`.

| quantity            | value (numeric) | proved identity                         |
|---------------------|-----------------|-----------------------------------------|
| `ln(1+√2)`          | `0.8813735870`  | `log_one_add_sqrt_two_pos`              |
| `β_c`               | `0.4406867935`  | `betaC_pos`                             |
| `2β_c`              | `0.8813735870`  | `exp_two_betaC : e^{2β_c}=1+√2`         |
| `sinh(2β_c)`        | `1.0000000000`  | `sinh_two_betaC` (**self-dual point**)  |
| `tanh(β_c)`         | `0.4142135624`  | `tanh_betaC = √2-1 = e^{-2β_c}`         |
| `T_c`               | `2.2691853142`  | `TC_bounds : 2 < T_c < 3`               |

The self-duality fixed point `sinh(2β)·sinh(2β*) = 1` with `β = β*` forces
`sinh(2β) = 1`; numerically the unique positive root is `β = 0.44069 = β_c`. ✓

## 2. Transfer matrix (1D row transfer), zero field

`T(β) = [[e^β, e^{-β}], [e^{-β}, e^β]]`, eigenvalues `λ₊ = 2cosh β`,
`λ₋ = 2sinh β`. Small-case partition function `Z_N = Tr T^N = λ₊^N + λ₋^N`:

| β    | λ₊       | λ₋       | Z_1   | Z_2     | Z_3      |
|------|----------|----------|-------|---------|----------|
| 0.25 | 2.06430  | 0.50521  | 2.569 | 4.516   | 8.927    |
| 0.50 | 2.25525  | 1.04219  | 3.297 | 6.172   | 12.616   |
| 1.00 | 3.08616  | 2.35040  | 5.437 | 15.05   | 42.39    |

Always `λ₊ > λ₋ > 0` (proved `lamPlus_gt_lamMinus`), so `Z_N` is dominated by
`λ₊^N`; the per-site free energy `(1/N)·ln Z_N → ln λ₊ = ln(2cosh β)`. This is the
1D solution: a strictly positive eigenvalue gap for every finite `β`, hence **no
phase transition in 1D** (consistent with the model being exactly solvable).

## 3. Peierls majorant and the low-temperature threshold

`P(β) = ∑_{L} L·x^L = x/(1-x)^2` with `x = 3e^{-2β}` (proved `peierls_closed_form`).

| β                | x = 3e^{-2β} | P(β) = x/(1-x)^2 | < 1/2 ? |
|------------------|--------------|------------------|---------|
| ½ln 3 ≈ 0.549    | 1.000        | +∞ (diverges)    | no      |
| 1.000            | 0.4060       | 1.151            | no      |
| β₀ = ½ln 12 ≈ 1.242 | 0.2500    | 0.4444 = 4/9     | **yes** |
| 1.500            | 0.1494       | 0.2067           | yes     |
| 2.000            | 0.0549       | 0.0615           | yes     |

The witnessed threshold `β₀ = ½ ln 12 ≈ 1.2425` gives `x = 1/4`, `P = 4/9 < 1/2`
(proved `peierls_threshold`).  Note `β₀ > β_c ≈ 0.4407`: the *elementary* Peierls
majorant overestimates the true transition point, which is exactly why Onsager's
exact `β_c` is a strictly stronger result than the Peierls criterion.

## 4. Counterexample hunt

* Tested whether `sinh(2β) = 1` admits a second positive root: `sinh` is strictly
  increasing, so the root is unique — no counterexample to canonicity of `β_c`.
* Tested the ground-state bound `H(σ) ≥ -2N` on random `±1` configurations of the
  `3×3` and `4×4` tori (`N = 9, 16`): minimum `-2N` attained only by all-aligned
  configurations; no configuration beat it (consistent with
  `hamiltonian_ground_bound` + `hamiltonian_allUp`).
* Tested `1 - 4x + x^2 > 0` for `x ∈ (0, 1/4]` on a fine grid: always positive
  (the algebraic heart of `peierls_threshold`); first sign change at
  `x = 2 - √3 ≈ 0.268 > 1/4`, confirming the margin.

## 5. OEIS

No integer sequence is the *object* of the proved theorems. The contour counts
underlying the full Peierls argument (self-avoiding polygons on `ℤ²`) are related
to OEIS A002931 (self-avoiding polygons by perimeter); the crude bound `L·3^L`
used for the majorant is deliberately looser than the true growth `~ μ^L`,
`μ ≈ 2.638` (the connective constant), and is all that is needed for convergence.
