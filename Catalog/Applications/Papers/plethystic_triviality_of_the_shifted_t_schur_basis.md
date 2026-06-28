# Computational Evidence — Plethystic Triviality of the Shifted t-Schur Basis

Working ring: `Λ = MvPolynomial ℕ K` over `K = ℚ(t)` (`RatFunc ℚ`), where the variable
`X k` models the odd power sum `p_{2k+1}`. The plethysm under study is
`φ_t : p_{2k+1} ↦ (1 - t^{2k+1}) p_{2k+1}`, with scalars `c_k = 1 - t^{2k+1}`.

## 1. Small-case calculations (one-row functions / `λ = (1)`)

The one-row Schur Q-function and its t-deformation were computed from the Newton/vertex
recursion `qGen` and checked against the headline identity `S^t_λ = φ_t(Q_λ)`:

| λ        | Q_λ                | S^t_λ = φ_t(Q_λ)                | scalar factor |
|----------|--------------------|---------------------------------|---------------|
| (1)      | `2 p_1`            | `2 (1 - t) p_1`                 | `(1 - t)`     |
| (k+1 row)| `q_{k}` (Newton)   | `φ_t(q_k)` (verified by `qt_eq_phiT_q`) | diagonal `∏(1-t^{n_i})` |

Lean facts confirming the (1) row:
- `Qfun_singleton : Qfun [1] = C 2 * X 0`
- `Sfun_singleton : Sfun [1] = C (2 * cc 0) * X 0`, i.e. exactly `(1 - t) · Q_{(1)}`.

This is the "coefficient comparison in the finite odd power-sum ring" falsifiability test:
the coefficient of `p_1` changes from `2` to `2(1-t)`, precisely the predicted plethystic
rescaling. No discrepancy was found.

## 2. Structural verification at the operator level

- The intertwining relation `Bt_n ∘ φ_t = φ_t ∘ B_n` (`Bt_phiT`) was verified, which forces
  `S^t_λ = φ_t(Q_λ)` for *every* list of parts (`Sfun_eq_phiT_Qfun`), not just small cases.
- The deformed one-row family satisfies `qt n = φ_t (q n)` (`qt_eq_phiT_q`), verified by
  strong induction on `n` through the Newton recursion.

## 3. Invertibility / triviality check

- `cc k = 1 - t^{2k+1} ≠ 0` for all `k` (`cc_ne`): each diagonal scalar is a unit in `K`,
  so `φ_t` is invertible. Hence `Q_λ = ψ_t(S^t_λ)` (`Qfun_eq_psiT_Sfun`).
- Diagonal-plethysm group law verified on generators: `Φ v ∘ Φ w = Φ (v·w)`,
  `Φ 1 = id` (`Phi_comp`, `Phi_one`). The inverse relation `φ_t ∘ ψ_t = id`
  (`phiT_psiT_eq_id`) follows from `c_k · c_k⁻¹ = 1`.

## 4. Counterexample hunt (non-triviality boundary)

We tested whether triviality could degenerate to `φ_t = id` (which would make the claim
vacuous):
- `cc 0 = 1 - t ≠ 1` because `t = RatFunc.X ≠ 0` (`cc_zero_ne_one`).
- Therefore `φ_t ≠ id` (`phiT_ne_id`) and at the basis level `S^t_{(1)} = 2(1-t)p_1 ≠
  2 p_1 = Q_{(1)}`. The deformation is real.
- General boundary: `Φ w = id ⟹ w k = 1 ∀ k` (`weight_eq_one_of_Phi_eq_id`), so the
  parametrization `w ↦ Φ w` is faithful; triviality would fail over any base ring where
  some `1 - t^{2k+1}` vanishes.

No counterexample to `S^t_λ = φ_t(Q_λ)` was found. All checks are discharged inside Lean
(see `PlethysticTrivialityShiftedTSchur.lean`, `OddPowerSumPlethysm.lean`,
`DiagonalPlethysmGroup.lean`) with axioms restricted to
`propext, Classical.choice, Quot.sound`.

## 5. OEIS / table notes

The integer coefficients arising (`2`, the doubling in the Schur-Q vertex normalization)
match the standard `Q_{(n)}` normalization `Q_{(1)} = 2 p_1`; no new integer sequence is
introduced — the deformation lives entirely in the `K`-valued diagonal scalars
`∏_i (1 - t^{n_i})`, not in the combinatorial coefficients.
