# Computational evidence — UNIVERSAL-S3-FOURTH (paper 115)

Exploratory script (Python, not machine-checked): all primes `p < 1000`, root counts
`T(p) = #{x mod p : x³ ≡ c}` for `c = 2, 3, 5, 7`, excluding the ramified primes `p | 3c`.

| c | disc = −27c² | joint counts `(p mod 3, T)` | H(p mod 3) | H(T) | I(p mod 3; T) | ramified (p, T, p mod 3) |
|---|---|---|---|---|---|---|
| 2 | −108  | (2,1):86, (1,0):56, (1,3):24 | 0.99906 | 1.42378 | 0.99906 | (2,1,2), (3,1,0) |
| 3 | −243  | (2,1):87, (1,0):54, (1,3):26 | 0.99873 | 1.43453 | 0.99873 | (3,1,0) |
| 5 | −675  | (2,1):86, (1,0):56, (1,3):24 | 0.99906 | 1.42378 | 0.99906 | (3,1,0), (5,1,2) |
| 7 | −1323 | (2,1):87, (1,0):54, (1,3):25 | 0.99832 | 1.42687 | 0.99832 | (3,1,0), **(7,1,1)** |

Observations:
* The cells `(1,1)`, `(2,0)`, `(2,3)` never occur (no counterexample found), so
  `H(p mod 3 | T) = 0`. That gives `I = H(p mod 3)` exactly, *not* `I = 1`. The reported
  `1.0000` is `H(p mod 3)` rounded; `H → 1` only in the limit (Dirichlet).
* Counterexample hunt on the ramified primes: at `p = 7`, `x³ − 7` has the single root `0`,
  but `7 ≡ 1 (mod 3)`. The law genuinely needs `p ∤ 3c`.
* S₃-model prediction: `P(T=0,1,3) = 1/3, 1/2, 1/6`; `H(T) = 2/3 + log₂3/2 ≈ 1.4591`,
  consistent with the empirical 1.42–1.43.
* Non-pure S₃ cubic `x³ − x − 1` (disc −23): one root at `p = 5` and at `p = 7`, so the
  type does not determine `p mod 3` there.

Lean-checked parts (in `Catalog/Pythagorean/UniversalS3Fourth*.lean`): the universal law, the
decoder, the ramified counterexamples, `T₇(13)=0`, `T₇(19)=3` (roots 4, 6, 9), `T₇(5)=1`, the
`x³−x−1` counterexample, the exact S₃-model entropies, and `I = 1` on the balanced sample
`{5, 11, 13, 19}`. The table values above come from the script only.
