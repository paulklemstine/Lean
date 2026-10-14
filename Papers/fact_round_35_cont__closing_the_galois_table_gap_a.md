# Computational Evidence — AGL(1,8) type channel (FACT round-35, cont.)

All numbers below were first computed in exploratory Python (exact field arithmetic in
GF(2^k), cycle types computed from the permutations, all ordered pairs enumerated), and then
**every value marked "Lean" was re-derived exactly and machine-checked** in
`Catalog/Geometry/AGL8Channel/*.lean` (kernel `decide` on the genuine permutation group, no
`native_decide`). Values marked "Python only" are exploratory and *not* verified.

## 1. The group (Lean: `Group.lean`)

| object | value | Lean name |
|---|---|---|
| `AGL(1,8)` as permutations of GF(8) | 56 elements | `aglSet_card` |
| derived subgroup | translations `C₂³`, 8 elements; every commutator is a translation and every translation is a commutator | `aglDerived`, `transSet_card` |
| abelianization | `C₇`, readout `aglCoset σ = log_x(σ 1 + σ 0)` | `aglCoset_isCosetReadout`, `aglCoset_image_card` |
| type readout | cycle type, class function of all of `Sym(8)` (not 200 random checks: a theorem) | `aglType_conj` |
| type values | `[1⁸]` ×1, `[2⁴]` ×7, `[1,7]` ×48 | `aglType_aff` |

## 2. Exact channel values

| quantity | exact value | numeric | status |
|---|---|---|---|
| cap `H(coset)` | `log₂ 7` | 2.80735 | Lean `agl8_cap` |
| prime `I₁` | `log₂ 7 − (6/7) log₂ 6 = h(1/7)` | 0.591673 | Lean `agl8_prime_channel`, `agl8_prime_channel_binary` |
| loss `H(coset∣T)` | `(6/7) log₂ 6` = catalog totient sum at q=8 | 2.21568 | Lean `agl8_prime_loss`, `agl8_loss_eq_totient_sum` |
| semiprime `I₂` (unordered) | `log₂ 7 − (78/49) log₂ 6 + (30/49) log₂ 5` | 0.114105 | Lean `agl8_semiprime_channel` |
| semiprime `I₂` (ordered) | same | 0.114105 | Lean `agl8_semiprime_ordered` |
| `I₁ / cap` | 21.07 %–21.08 % | | Lean `agl8_prime_fraction` |
| `I₂ / cap` | 4.06 %–4.07 % | | Lean `agl8_semiprime_fraction` |
| `A₄ = AGL(1,4)` semiprime | `log₂ 3 − 10/9` | 0.473851 | Lean `A4_semiprime_channel` |

Fibre counts used (all checked by kernel `decide` over the 3136 / 144 pairs):

* unordered type pair on `AGL(1,8)²`: `{1⁸,1⁸}:1, {1⁸,2⁴}:14, {2⁴,2⁴}:49, {1⁸,17}:96, {2⁴,17}:672, {17,17}:2304`;
* joint with product coset: `{17,17}` splits `384` (coset 0) + `6×320`; `{1⁸,17}` = `6×16`; `{2⁴,17}` = `6×112`.

## 3. The affine Mersenne ladder `AGL(1,2^k)` (Python only, except q = 4, 8)

| q | n = q−1 | #types | cap | I₁ | I₂ | I₂/cap |
|---|---|---|---|---|---|---|
| 4 (= A₄) | 3 | 3 | 1.585 | 0.9183 | 0.4739 | 29.9 % |
| 8 | 7 | 3 | 2.807 | 0.5917 | 0.1141 | 4.06 % |
| 16 | 15 (not prime) | 5 | 3.907 | 1.6402 | 0.6766 | 17.3 % |
| 32 | 31 | 3 | 4.954 | 0.2056 | 0.00813 | 0.16 % |

Observation: when `q − 1` is prime (q = 4, 8, 32) the type readout is a *trivial-coset
detector* and `I₁ = h(1/n)` exactly; at `q = 16` (`15 = 3·5`) the readout resolves the order
of the multiplier and the channel jumps back up — the anti-monotonicity is a property of the
detector class, not of `AGL(1,q)` in general. This is proved in Lean for every finite group
with a detector readout (`group_detector_law`, `detectorInfo_strictAnti`).

## 4. Pair-detector formula `δ₂(n)` (conjecture; Lean-verified at n = 3, 7)

`δ₂(n) = log₂ n − (2(n−1)/n²) log₂(n−1) − ((n−1)/n)² H_n`. Python values:

| n | δ(n) = I₁ | δ₂(n) = I₂ | n·I₂/I₁ |
|---|---|---|---|
| 3 | 0.91830 | 0.47385 | 1.548 |
| 7 | 0.59167 | 0.11411 | 1.350 |
| 31 | 0.20559 | 0.0081335 | 1.226 |
| 127 | 0.066344 | 6.118e-4 | 1.171 |
| 8191 | 1.7632e-3 | 2.368e-7 | 1.100 |

Counterexample hunt: brute-force enumeration for q = 4, 8, 32 agrees with `δ₂(q−1)` to
machine precision; no counterexample found. `n·I₂/I₁` decreases towards 1 (Python only).

## 5. OEIS

The fibre-count sequences (1, 7, 48) and (1, 14, 49, 96, 672, 2304) are elementary
multiplicities `(q−1)·q` splittings; no OEIS lookup was relevant.
