# Computational Evidence — GL₂ local Frobenius data (Eichler–Shimura & Deligne)

Concise evidence for the claims formalized in `EichlerShimuraGL2.lean` and `DeligneBoundGL2.lean`.

## 1. Small-case Hecke eigenvalues (weight-2 newforms)

The weight-2 newform of level 11 (`X₀(11)`, the elliptic curve `11a`) has Hecke eigenvalues
`a_p = p + 1 − #E(𝔽_p)`:

| p  | a_p | bound 2√p (≈) | a_p² ≤ 4p ? | eigenvalue modulus √p (≈) |
|----|-----|---------------|-------------|---------------------------|
| 2  | −2  | 2.83          | 4 ≤ 8  ✓    | 1.414                     |
| 3  | −1  | 3.46          | 1 ≤ 12 ✓    | 1.732                     |
| 5  |  1  | 4.47          | 1 ≤ 20 ✓    | 2.236                     |
| 7  | −2  | 5.29          | 4 ≤ 28 ✓    | 2.646                     |
| 13 |  4  | 7.21          | 16 ≤ 52 ✓   | 3.606                     |
| 17 | −2  | 8.25          | 4 ≤ 68 ✓    | 4.123                     |

Every entry satisfies the Deligne bound `a_p² ≤ 4p` (`deligne_bound_iff`), and the Hecke
polynomial `X² − a_p X + p` has complex-conjugate roots of modulus exactly `√p`
(`deligne_root_abs`, `deligne_weil_pair`).

## 2. Eichler–Shimura relation, numerically

For the companion matrix `frobMatrix a p = !![0,-p; 1,a]`:
- `(p=5, a=1)`: `M = !![0,-5; 1,1]`, `M² = !![−5,−5; 1,−4]`, and
  `a·M − p·1 = 1·!![0,-5;1,1] − 5·!![1,0;0,1] = !![−5,−5; 1,−4]`. ✓ (`frobMatrix_eichlerShimura`).
- `tr M = 1 = a`, `det M = 5 = p` (`frobMatrix_trace`, `frobMatrix_det`).

## 3. Counterexample hunt — boundary of the bound

The bound is *not* vacuous: pick `a² > 4p`, e.g. `a = 5, p = 4` (`25 > 16`). Then
`X² − 5X + 4 = (X−1)(X−4)` has *real* roots `1, 4` with moduli `1 ≠ 2 = √4`. So the
conclusion `‖z‖ = √p` genuinely fails when the hypothesis `a² ≤ 4p` is dropped — confirming
the hypothesis is load-bearing, exactly as encoded in `deligne_root_abs`.

At the boundary `a² = 4p` (e.g. `a = 4, p = 4`): `X² − 4X + 4 = (X−2)²`, a repeated *real* root
`2 = √4`, still on the critical circle — matching the `z.im = 0 ⇒ a² = 4p` branch of the proof.

## 4. Sato–Tate angles

Writing `a_p = 2√p cos θ_p` for level-11 data gives `θ_2 ≈ 2.36, θ_3 ≈ 1.86, θ_5 ≈ 1.34,
θ_7 ≈ 1.95, θ_13 ≈ 0.99` — all in `[0, π]`, consistent with Future Direction 2.

## Note on scope

Full Eichler–Shimura (geometry of modular curves) and Deligne's theorem (Weil conjectures) are
far beyond current formalization. The files isolate the *exact finite/real-algebraic core* of
each: the rank-2 Cayley–Hamilton identity and the discriminant characterization of Weil numbers.
These are fully proved (0 `sorry`, only standard axioms).
