# Computational Evidence — Brocard–Ramanujan Triangular Classification

All checks below were run in Lean (`#eval`) over `n` in `0..11` using the
`Nat.sqrt`-based perfect-square test `Nat.sqrt k ^ 2 = k`.

## 1. Figurate-factorial trilogy (small cases)

Detector identity used throughout: `t` is triangular ⟺ `8·t + 1` is a perfect square.

| Problem | Detector | Solutions with `n ≤ 11` | Triangular index |
|---|---|---|---|
| `n!` triangular | `8·n! + 1 = □` | `n = 0, 1, 3, 5` | `T₁, T₁, T₃, T₁₅` |
| `n! + 1` triangular | `8·n! + 9 = □` | `n = 2` | `T₂` |
| `n! + 1` square (Brocard) | `n! + 1 = □` | `n = 4, 5, 7` (Brown) | roots `5, 11, 71` |
| `n!` square ∧ triangular | valuation + detector | `n = 0, 1` | `1 = T₁ = 1²` |

Raw `#eval` outputs:
- `{n ≤ 11 : 8·n!+1 = □}` = `[0, 1, 3, 5]`
- `{n ≤ 11 : 8·n!+9 = □}` = `[2]`
- `{n ≤ 11 : n! = □}` = `[0, 1]`

## 2. Counterexample hunt (finite verification window)

- `n!` triangular: verified NO solutions for `6 ≤ n ≤ 50` (theorem
  `FactorialTriangular.no_factorial_triangular_6_to_50`).
- `n!+1` triangular: verified NO solutions for `n ≤ 50`, `n ≠ 2` (theorem
  `FactorialSuccTriangular.no_factorial_succ_triangular_ne_two`).
- `n!` square: ruled out for ALL `n ≥ 2` unconditionally (theorem
  `FactorialSquareTriangular.factorial_not_isSquare`, via Bertrand).

## 3. Modular non-obstruction (why these are Brocard-hard)

For `n ≥ 6`, `n!` is divisible by `16`, so:
- `8·n! + 1 ≡ 1 (mod 16)` and `1` is a quadratic residue mod 16;
- `8·n! + 9 ≡ 9 (mod 16)` and `9` is a quadratic residue mod 16.

Hence no elementary parity/mod obstruction rules out large solutions of the
triangular variants — they are genuinely of Brocard difficulty. By contrast the
*square* condition on `n!` carries a per-prime valuation parity invariant
(odd valuation at a Bertrand prime), which is exactly what makes
`FactorialSquareTriangular` fully resolvable.

## OEIS pointers (informal)
- `n!` triangular: solutions `1, 6, 120` (= `0!/1!, 3!, 5!`), cf. factorials
  that are triangular numbers.
- Square–triangular numbers `0, 1, 36, 1225, …` (Pell), of which only `1` is a
  factorial.
