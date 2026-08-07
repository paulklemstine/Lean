# Computational Evidence — Diophantine-Lattice Spectral Bounds

All computations below were run in Lean 4 (`#eval`, exact rational arithmetic) before any
proof was attempted; they are what selected the final theorem statements.

## 1. Shifted (deep-hole) spectrum of `ℤⁿ` with the standard form

For `t = (1/2, …, 1/2)` and `m ∈ {-2,…,2}ⁿ` we tabulated the *integral* quantity
`4·Q(t − m) = Σ (1 − 2mᵢ)²`:

| `n` | observed value set of `4·Q(t−m)` |
|---|---|
| 0 | `{0}` |
| 1 | `{1, 9, 25}` |
| 2 | `{2, 10, 18, 26, 34, 50}` |
| 3 | `{3, 11, 19, 27, 35, 43, 51, 59, 75}` |
| 4 | `{4, 12, 20, 28, 36, 44, 52, 60, 68, 76, 84, 100}` |

Two exact patterns, both later proved:

* every value is `≡ n (mod 8)` — so the shifted theta series of `ℤⁿ` at its deep hole is
  supported on `n/4 + 2ℤ≥0`: a **spectral gap of exactly 2** between consecutive
  admissible values (`deepHole_spectrum`, `deepHole_gap_two`);
* the minimum is exactly `n`, i.e. `Q(t−m) ≥ n/4` with equality at `m = 0`
  (`deepHole_isInhomMin`), giving covering radius² `= n/4` together with the rounding
  upper bound (`standard_covering_le`).

Note this immediately falsifies the naive guess "the shifted spectrum is `n/4 + ℤ≥0`":
odd gaps never occur.

## 2. Counterexample hunt for the packing–covering bound

For positive-definite binary forms `Q(x,y) = a x² + b x y + c y²` we computed
`λ₁ = min_{m≠0} Q(m)`, a shortest vector `v`, and `μ = min_{m∈ℤ²} Q(v/2 − m)`
over the box `[-5,5]²`:

| `(a,b,c)` | `λ₁` | `μ` at `v/2` | `μ − λ₁/4` |
|---|---|---|---|
| `(1,0,1)` | 1 | 1/4 | 0 |
| `(1,1,1)` | 1 | 1/4 | 0 |
| `(2,1,3)` | 2 | 1/2 | 0 |
| `(1,0,5)` | 1 | 1/4 | 0 |
| `(3,2,7)` | 3 | 3/4 | 0 |
| `(5,4,9)` | 5 | 5/4 | 0 |

No counterexample to `μ ≥ λ₁/4` was found, and in **every** sample the inequality was an
*equality*. That observation upgraded the intended inequality
(`SpectralGap ≥ MinLatticeEnergy/4`) to the sharp identity
`half_shortest_isInhomMin : μ(v/2) = λ₁/4`, which is what the Lean file proves in
arbitrary dimension for arbitrary positive-definite rational forms.

## 3. Where the mission's literal stub fails

The stub `SpectralGap Q c ≥ MinLatticeEnergy Q` (unnormalised) is *false*: the table above
shows `μ = λ₁/4 < λ₁` whenever `λ₁ > 0`. The factor `1/4` is not cosmetic — it is forced by
the `2`-torsion of `L/2L`, and §2 shows it cannot be improved.

## 4. Gaps at general torsion shifts (cycles 6–8)

Exact rational enumeration of `μ(t) = min_{m ∈ [-3,3]ⁿ} Σ (tᵢ − mᵢ)²` for the standard form:

| `t` | `μ(t)` | predicted |
|---|---|---|
| `(0,0)` | `0` | `t ∈ L`, no gap |
| `(1/2,0)`, `(0,1/2)` | `1/4` | `λ₁/4`, extremal `2`-torsion shift |
| `(1/2,1/2)` | `1/2` | Hamming weight `2`, so `2/4` |
| `(1/2,1/2,0)` | `1/2` | weight `2` |
| `(1/2,1/2,1/2)` | `3/4` | weight `3` (deep hole of `ℤ³`) |
| `(3/2,5/2)` | `1/2` | weight `2`: only the class mod `L` matters |
| `(1/3)` | `1/9` | `λ₁/r²` with `r = 3`, extremal |
| `(1/3,1/3)` | `2/9` | **not** extremal: `λ₂/r² = 2/9` |

Two exact patterns, both now proved:

* the gap at a `2`-torsion shift depends only on its class in `𝔽₂ⁿ` and equals a quarter of the
  Hamming weight of that class (`two_torsion_gap_eq_card`, `gap_spectrum_eq`);
* a torsion shift that is not congruent to `w/r` with `w` shortest jumps to the *next* value of
  the homogeneous form, e.g. `2/9` rather than `1/9` above (`torsion_shift_second_gap`).

No counterexample to `μ(t) ≥ λ₁/r²` was found in any of the samples, in accordance with
`torsion_shift_gap_ge`.

## 5. Cycle 9: weighted gaps, and the counterexample to the parity conjecture

### 5a. Diagonal weight enumerator

For `Q(x,y) = 2x² + 5y²` we computed `μ(t) = min_{m ∈ [-3,3]²} Q(t − m)` exactly:

| `t` | `μ(t)` | predicted `(Σ_{i ∈ s} aᵢ)/4` |
|---|---|---|
| `(1/2, 0)` | `1/2` | `s = {1}`, `2/4` |
| `(0, 1/2)` | `5/4` | `s = {2}`, `5/4` |
| `(1/2, 1/2)` | `7/4` | `s = {1,2}`, `(2+5)/4` |
| `(3/2, 5/2)` | `7/4` | same class mod `L`, so same value |

This is exactly the weighted Hamming law, now proved as `diagonal_stepShift_isInhomMin`,
`diagonal_two_torsion_gap_eq` and `diagonal_gap_spectrum_eq` (sub-conjecture D1 confirmed).

### 5b. Counterexample hunt for Conjecture A (parity ⟹ `2`-torsion)

Exact shell counts `r_t(c) = #{m ∈ ℤ² : |t − m|² = c}` for the standard form (box `[-5,5]²`,
values listed up to a cutoff below which the box is complete):

| `t` | first shells `(c, r_t(c))` | all even? | `2t ∈ ℤ²`? |
|---|---|---|---|
| `(1/2, 1/2)` | `(1/2, 4)`, `(5/2, 8)` | yes | yes |
| `(1/3, 1/3)` | `(2/9, 1)`, `(5/9, 2)`, `(8/9, 1)` | **no** | no |
| `(1/2, 1/3)` | `(13/36, 2)`, `(25/36, 2)`, `(73/36, 2)`, `(85/36, 2)` | **yes** | **no** |

The last row **refutes Conjecture A**: all coefficients are even although `2t = (1, 2/3) ∉ ℤ²`
(theorem `parity_conjecture_false`).  The middle row shows the mechanism of the corrected
criterion: with no half-integral coordinate the *minimal* shell is a single point
(`2/9` with multiplicity `1`), which is the content of `diagonal_min_shell_unique`.
