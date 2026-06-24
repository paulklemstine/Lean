# Computational Evidence — Sharpness of the Fitting stabilization bound

The headline theorems prove that for `g : V →ₗ[K] V` over a `d`-dimensional space
(`d = finrank K V`), the range chain `range (g ^ m)` and kernel chain
`ker (g ^ m)` are constant for all `m ≥ d`. Here we record the small-case
evidence that the bound `m ≥ d` is **sharp** (cannot be lowered to `m ≥ d - 1`).

## Witness: a single nilpotent Jordan block `J_d`

Let `J_d` be the `d × d` nilpotent Jordan block (1's on the superdiagonal,
0 elsewhere), acting on `V = K^d`. Then `J_d` shifts basis vectors
`e_i ↦ e_{i-1}` (and `e_0 ↦ 0`), so:

| `m`        | `dim (range (J_d ^ m))` | `dim (ker (J_d ^ m))` |
|------------|--------------------------|------------------------|
| `0`        | `d`                      | `0`                    |
| `1`        | `d - 1`                  | `1`                    |
| `2`        | `d - 2`                  | `2`                    |
| …          | …                        | …                      |
| `d - 1`    | `1`                      | `d - 1`                |
| `d`        | `0`                      | `d`                    |
| `d + 1`    | `0`                      | `d`                    |
| `≥ d`      | `0`                      | `d`                    |

* The range chain strictly decreases on `0, 1, …, d` and only becomes constant at
  step `d`. So `range (J_d ^ (d-1)) = K·e_0 ≠ 0 = range (J_d ^ d)`: the bound
  `m ≥ d` is attained and **cannot** be replaced by `m ≥ d - 1`.
* Symmetrically the kernel chain strictly increases until step `d`.

### Concrete instance `d = 3`

`J_3 = ⎡0 1 0⎤  J_3² = ⎡0 0 1⎤  J_3³ = 0`
`      ⎢0 0 1⎥        ⎢0 0 0⎥`
`      ⎣0 0 0⎦        ⎣0 0 0⎦`

`rank J_3⁰ = 3`, `rank J_3¹ = 2`, `rank J_3² = 1`, `rank J_3³ = 0 = rank J_3⁴`.
First plateau index = `3 = finrank`. ✓ matches `exists_range_pow_plateau_le_finrank`
(plateau index `k ≤ finrank`, here exactly `= finrank`).

## Counterexample hunt — the bound fails for *varying* streams

Take `V = K²` and the stream `f 0 = P` (projection onto `e_0`), `f 1 = id`,
`f 2 = Q` (projection onto `e_1`), `f n = id` otherwise. The composite ranks
`(compFrom f 0 m).rank` read `2, 1, 1, 0, 0, …`: the rank **plateaus at 1** (steps
1–2) and then **drops again** to 0 at step 3. Hence no single dimension bound of
the form "constant from step `finrank`" can hold for general streams — confirming
the Critic's note and motivating Conjecture 3 (periodic streams) in
`FUTURE_DIRECTIONS.md`.

## Method note

These are pen-and-paper / matrix calculations on the canonical nilpotent witness;
the *formal* content (antitone chains, stabilization by `finrank`, sharp plateau
existence) is fully machine-checked and `sorry`-free in
`Catalog/Algebra/FittingStabilizationBound.lean` and
`Catalog/Algebra/FittingKernelBound.lean`.
