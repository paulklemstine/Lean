# Computational Evidence: sign changes of `sym^j` Hecke coefficients over sums of `m` squares

## 1. The representability constraint collapses for `m ≥ 4`

Lagrange's four-square theorem says every `n ∈ ℕ` is a sum of four squares. Padding
with zeros, every `n` is a sum of `m` squares for every `m ≥ 4`. Small-case check of the
set `S_m = { n : n is a sum of m squares }`:

| `m` | first few non-representable `n` | `S_m = ℕ`? |
|-----|----------------------------------|------------|
| 1   | 2, 3, 5, 6, 7, 8, 10, ...          | no (only squares) |
| 2   | 3, 6, 7, 11, 12, 14, 15, ...       | no (misses `3 mod 4`, etc.) |
| 3   | 7, 15, 23, 28, ... (`4^a(8b+7)`)  | no (Legendre's three-square theorem) |
| 4   | none                              | **yes** (Lagrange) |
| ≥ 4 | none                              | **yes** |

So for every `m ≥ 4` the constraint "`n` is a sum of `m` squares" is vacuous, and the
restricted sign-change problem is *identical* to the unrestricted one. This is the entire
reason the paper's window `2 ≤ m ≤ 12` extends to all even `m ≥ 2`: only `m = 2` (and, for
odd `m`, `m = 1, 3`) is genuinely restrictive.

## 2. The boundary case `m = 2`: residue obstruction

A sum of two squares is never `≡ 3 (mod 4)` (squares are `0` or `1 mod 4`, so `a² + b²` is
`0, 1, 2 mod 4`). Hence `3 ∉ S_2`, so `S_2 ≠ ℕ`. This is the arithmetic reason `m = 2`
requires a genuinely different argument from the collapse.

- Non-representable-by-two-squares (`ℕ \ S_2`): 3, 6, 7, 11, 12, 14, 15, 19, 21, 22, 23, ...
  (OEIS A022544).
- Sums of two squares (`S_2`): 0, 1, 2, 4, 5, 8, 9, 10, 13, 16, 17, 18, 20, 25, ... (OEIS
  A001481).
- `S_2` is nevertheless infinite (it contains every perfect square `k² = k² + 0²`), which is
  what the sign-change statement needs on the index side.

## 3. Counterexample hunt

The claim to falsify is "for even `m ≥ 4`, sign changes over `S_m` need extra hypotheses
beyond unrestricted oscillation." We searched for an even `m ≥ 4` with `S_m ≠ ℕ`: none exists,
because Lagrange already gives `S_4 = ℕ` and `S_4 ⊆ S_m` for `m ≥ 4`. No counterexample; the
collapse is unconditional for `m ≥ 4`.

## 4. Concrete non-vacuous instance

The alternating sequence `a(n) = (-1)^n` satisfies the abstract oscillation hypothesis
(`+1` on the infinite set of evens, `-1` on the infinite set of odds). Applying the collapse
theorem, `a` changes sign infinitely often over `S_8` (and every `S_m`, `m ≥ 4`), confirming
the machinery is not vacuously true.
