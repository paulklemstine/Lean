# Computational Evidence

## Direction 5 — counting independent sentences

For `n` atoms: `#branches = 2^n`, `#sentences = 2^(2^n)`, `#settled = 2`
(the two constants), `#independent = 2^(2^n) - 2`, and the ratio
`r(n) = (2^(2^n) - 2) / 2^(2^n) = 1 - 2 / 2^(2^n)`.

| n | branches 2^n | sentences 2^(2^n) | settled | independent | ratio r(n) |
|---|---|---|---|---|---|
| 0 | 1 | 2       | 2 | 0        | 0.0        |
| 1 | 2 | 4       | 2 | 2        | 0.5        |
| 2 | 4 | 16      | 2 | 14       | 0.875      |
| 3 | 8 | 256     | 2 | 254      | 0.9921875  |
| 4 | 16| 65536   | 2 | 65534    | 0.99996948 |
| 5 | 32| 4294967296 | 2 | 4294967294 | 1 − 4.66e-10 |

The ratio climbs to `1` extremely fast (doubly-exponential denominator),
confirming `independent_ratio_tendsto_one`. The constant `2` (valid, refutable)
is the only obstruction; OEIS: `2^(2^n)` is A001146, `2^(2^n) - 2` matches the
count of non-constant Boolean functions offset (cf. A058891 counts distinct-up-
to-symmetry cases; here we count all functions).

## Direction 1 — the `(ℕ, ≤)` countermodel

Take the assertion `P = {0}` (true only at world 0), `R = ≤`.

- **B fails** at world `0`: `P 0` holds, but `□◇P 0` requires every `v ≥ 0` to
  reach some `u ≥ v` with `u = 0`; already `v = 1` has no such `u`.
- **5 fails** at world `0`: `◇P 0` holds (witness `0`), but `□◇P 0` fails at
  `v = 1` for the same reason.
- **T, 4, .2 hold**: `≤` is reflexive, transitive, and directed (`max`).

This is exactly the finite-information obstruction: once you have forced past
world `0` you can never force back, so symmetry (and euclideanness) genuinely
fail while directedness survives.

## Direction 2 — buttons vs switches

On the complete frame (`R _ _ = True`) over `W = Bool` with `P = id`:
`P` holds at `true`, fails at `false`, so `P` is a switch (non-constant) — a
toggle, matching the Continuum Hypothesis behaviour. On `(ℕ, ≤)` the assertion
`P = fun n => 3 ≤ n` is a button: monotone, once true it stays true; and indeed
`□P = P` on the up-set, illustrating `button_iff_box_fixed`.
