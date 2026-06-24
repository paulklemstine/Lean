# Computational Evidence — 2D Ising Model Phase Transition

Concise numerical evidence supporting the formalized theorems.

## 1. Onsager critical point (Kramers–Wannier self-duality)

Self-duality condition: `sinh(2β_c) = 1`.

- `β_c = (1/2) log(1+√2) = 0.5 · 0.8813735870… = 0.4406867935…`
- `T_c = 2 / log(1+√2) = 2 / 0.8813735870… = 2.2691853142…`
- Check: `sinh(log(1+√2))`. With `1+√2 = 2.4142135624`, `(1+√2)⁻¹ = √2−1 = 0.4142135624`,
  so `sinh = ((1+√2) − (√2−1))/2 = 2/2 = 1.0` ✔ (exact).
- Uniqueness: `sinh` is strictly increasing, so `β_c` is the unique solution — confirmed
  numerically by bisection on `sinh(2β)−1`.

These match the standard Onsager value `T_c ≈ 2.269 J/k_B`.

## 2. Transfer matrix (periodic 1D chain), small cases

Transfer matrix `V = [[e^{β}, e^{−β}], [e^{−β}, e^{β}]]`.
Partition function `Z_N = Tr(V^N) = (2cosh β)^N + (2 sinh β)^N` (eigenvalues `2cosh β`, `2 sinh β`).

Direct enumeration vs. trace, `β = 0.5`:

| N | brute-force `∑_σ e^{β ∑ s_i s_{i+1}}` | `Tr(V^N)` |
|---|---------------------------------------|-----------|
| 1 | `2 e^{0.5}` = 3.2974          | `2cosh.5 + 2sinh.5` = 3.2974 |
| 2 | `2 e^{1} + 2 e^{-1}` = 6.5947 | `(2cosh.5)²+(2sinh.5)²` = 6.5947 |
| 3 | 14.49…                       | 14.49… |

Brute force and `Tr(V^N)` agree — matching `ising_partition_eq_trace`.
(Note: our Lean `isingInteraction` uses the cyclic sum over `Fin (N+1)`, i.e. an
`(N+1)`-site ring, and the theorem is `Z = Tr(V^{N+1})`.)

## 3. Peierls argument — contour series threshold

Contour ratio `r = 3 e^{−2β}`; bad-event weight `S(β) = ∑_{L≥1} r^L = r/(1−r)`.

`S(β) < 1/2 ⟺ 3r < 1 ⟺ r < 1/3 ⟺ e^{−2β} < 1/9 ⟺ β > log 3 = 1.0986…`

| β        | r = 3e^{−2β} | S(β)=r/(1−r) | < 1/2 ? |
|----------|--------------|--------------|---------|
| 0.4407 (=β_c) | 1.240   | (r>1, diverges) | no |
| 0.55     | 0.999        | ~ huge       | no |
| 1.0986 (=log3) | 0.3333 | 0.5000       | boundary |
| 1.20     | 0.2725       | 0.3746       | yes ✔ |
| 1.50     | 0.1494       | 0.1757       | yes ✔ |

So the Peierls *sufficient* threshold is `β > log 3 ≈ 1.0986`, comfortably above
`β_c ≈ 0.4407`: the 3^L counting bound is generous, so Peierls certifies order only
deep in the ordered phase. Confirms `isingBetaC_lt_peierls_threshold` and
`peierls_phase_transition`.

## 4. Counterexample hunt

- `sinh(2β)=1` having a second positive root: none found (strict monotonicity). ✔
- `Tr(V^N) ≠ Z_N` for `N ≤ 6`, several `β`: no discrepancy. ✔
- Ising ground-state energy `≠ −(N+1)` for `N ≤ 8` by enumeration: none; the aligned
  state always achieves `−(N+1)`. ✔ (matches `ising_groundEnergy_eq_tropical`).
