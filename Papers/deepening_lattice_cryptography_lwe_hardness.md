# Computational Evidence

All computations below were run inside Lean 4 (`#eval`, exact `ℤ`/`ℚ`/`ZMod`
arithmetic — no floating point). They were used to validate each conjectured
statement *before* it was formalised. Every statement listed here is now backed
by a machine-checked, `sorry`-free proof in `Catalog/Cryptography/LWE/`.

---

## 1. Negacyclic convolution is multiplication in `ℤ[X]/(Xⁿ+1)`

Direct evaluation of the convolution
`(f ⊛ g)_k = ∑_{i+j=k} f_i g_j − ∑_{i+j=n+k} f_i g_j` at `n = 4`:

| input | coefficient vector of `f ⊛ g` | expected |
|---|---|---|
| `X³ ⊛ X` | `[-1, 0, 0, 0]` | `X⁴ = −1` ✓ |
| `(1+X) ⊛ (1+X)` | `[1, 2, 1, 0]` | `1 + 2X + X²` ✓ |
| `(1+X+X²+X³) ⊛ (1+X+X²+X³)` | `[-2, 0, 2, 4]` | see below |

The last row is the witness that the **expansion factor is exactly `n`**: with
`‖f‖_∞ = ‖g‖_∞ = 1` and `n = 4`, the output attains `‖f ⊛ g‖_∞ = 4 = n·A·B`.
So the bound `abs_negaConv_le` is tight and cannot be improved to `n−1`.
(For comparison, the naive double-sum bound would have given `n² = 16`.)

Formalised as `RingLWEStruct.embed_negaConv` (structure theorem) and
`RingLWEStruct.abs_negaConv_le` (expansion factor).

## 2. Sharpness of the quarter-modulus rounding condition

For `q = 16` (so the correctness hypothesis is `4|ν| < 16`, i.e. `|ν| ≤ 3`),
decoding `encode(b) + ν`:

| `ν` | `-4` | `-3` | `-2` | `-1` | `0` | `1` | `2` | `3` | `4` |
|---|---|---|---|---|---|---|---|---|---|
| decode of `encode(false)+ν` | F | F | F | F | F | F | F | F | **T** |
| decode of `encode(true)+ν`  | T | T | T | T | T | T | T | T | **F** |

Decoding is correct for every `|ν| ≤ 3` and *fails at `ν = 4`*, exactly where the
hypothesis `4|ν| < q` first breaks, so the constant `4` in
`DualRegev.decodeBit_encodeBit_add` cannot be improved. The table also shows the
condition `4|ν| < q` is **not** necessary: `ν = -4` still decodes correctly. This
asymmetry (the decoding window `[q/4, 3q/4)` is half-open) is what the sharp
dichotomy `DualRegev.decodeBit_correct_iff` records, and the correctness region
turns out to have exactly `q/2 = 8` residues — matching the universal upper bound
`DualRegev.noise_tolerance_le_half`.

## 3. Exact regularity of `⟨a, s⟩`

Modulus `p = 5`, dimension `n = 2`, secret `s = (1, 2) ≠ 0`. Counting
`#{a ∈ ℤ₅² : ⟨a,s⟩ = y}` for each `y`:

| `y` | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| fiber size | 5 | 5 | 5 | 5 | 5 |

All fibers have size `5 = p^{n-1}`, i.e. `⟨a,s⟩` is *perfectly* uniform (not
merely statistically close). Formalised as `LWEReduction.dot_fiber_card_eq` and
`LWEReduction.dotProduct_uniform`.

**Counterexample hunt.** The hypothesis `s ≠ 0` is necessary: for `s = 0` the
fiber over `y = 0` has size `p^n` and all other fibers are empty. The primality
of `p` is also necessary: over `ℤ₄` with `n = 1` and `s = 2`, the fibers over
`y ∈ {0,2}` have size `2` and those over `y ∈ {1,3}` are empty. Both restrictions
appear as hypotheses in the formal statement.

## 4. Smudging (noise flooding) distance

`ℓ¹` distance between the uniform distribution on `{0,…,N−1}` and its shift
by `c`, computed exactly in `ℚ`:

| `(N, c)` | measured `ℓ¹` | `2c/N` |
|---|---|---|
| `(8, 0)` | `0` | `0` |
| `(8, 1)` | `1/4` | `1/4` |
| `(8, 2)` | `1/2` | `1/2` |
| `(8, 4)` | `1` | `1` |
| `(8, 8)` | `2` | `2` |
| `(100, 3)` | `3/50` | `3/50` |
| `(1000, 3)` | `3/500` | `3/500` |

Perfect agreement in all tested cases, including the extreme `c = N` where the
distributions become disjoint and the distance saturates at `2`. Formalised as
`LWEReduction.smudging_l1_eq` (an **equality**, not just a bound).

**Counterexample hunt (uniform is not optimal).** Testing whether uniform noise
minimises the shift distance among all distributions on `N` consecutive
integers, exact `ℚ` computation refutes it:

| `(N, c)` | uniform | best found | witness |
|---|---|---|---|
| `(3, 2)` | `4/3` | `1` | `(1/2, 0, 1/2)` |
| `(8, 3)` | `3/4` | `2/3` | `(1/3,0,0,1/3,0,0,1/3,0)` |

Both witnesses concentrate the mass on a single residue class mod `c`. This
observation drives the corrected Conjecture 5 in `FUTURE_DIRECTIONS.md`.

## 5. OEIS

No new integer sequence arises from this development; the quantities appearing
(`φ(q)`, `p^{n-1}`, `2c/N`, expansion factor `n`) are all classical closed forms,
so no OEIS lookup was applicable.
