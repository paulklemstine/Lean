# Computational Evidence — Product Hilton–Milner

All computations below were run in Lean 4 (`#eval`) over `Fin n` with exact
natural-number arithmetic, so they are exact, not floating point.

## 1. The Hilton–Milner value and the extremal family size

Define `h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1` and the canonical Hilton–Milner
family

    HMfam(n,k,x,Y) = { A ⊆ [n] : |A| = k, (x ∈ A ∧ A ∩ Y ≠ ∅) ∨ A = Y }

for a fixed point `x` and a fixed `k`-set `Y` with `x ∉ Y`.  The identity
`|HMfam| = h(n,k)` was checked directly:

| n | k | Y        | `|HMfam|` | `h(n,k)` |
|---|---|----------|-----------|----------|
| 6 | 3 | {1,2,3}  | 10        | 10       |
| 7 | 3 | {1,2,3}  | 13        | 13       |
| 8 | 4 | {1,2,3,4}| 35        | 35       |

This is the content of the formal theorem `card_hiltonMilnerFamily`.

## 2. The elementary meeting count

The number of `k`-subsets of `[n]` meeting a fixed `m`-set equals
`C(n,k) - C(n-m,k)`:

| n | k | m | `#{A : |A|=k, A∩B≠∅}` | `C(n,k)-C(n-m,k)` |
|---|---|---|-----------------------|-------------------|
| 6 | 3 | 2 | 16                    | 16                |
| 7 | 3 | 3 | 31                    | 31                |

This underlies the per-family bound `card_le_of_meets` and the mixed-uniformity
product bound `crossIntersecting_prod_le`.

## 3. Counterexample hunt

No counterexamples were sought against the *sharp* product bound
`|F|·|G| ≤ h(n,k)·C(n-1,ℓ-1)` because it is a known theorem for large `n`; the
formal file instead proves unconditional weaker product bounds (elementary and
Erdős–Ko–Rado) together with the exact extremal count, none of which admit
counterexamples (they are proved in Lean with only the standard axioms
`propext`, `Classical.choice`, `Quot.sound`).

The small tables above also serve as a sanity check that the definitions in the
Lean file compute the intended quantities.
