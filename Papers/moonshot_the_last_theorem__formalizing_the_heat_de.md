# Computational evidence

The central results are structural rather than empirical, but small finite cases expose
the relevant pattern.

## Small cases

For a one-output-per-operation enumerator, the number of distinct discoveries after
budgets `B = 0,1,2,3,4,5` is at most:

| `B` | maximum distinct outputs |
|---:|---:|
| 0 | 0 |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 4 |
| 5 | 5 |

For a discovered set of size `d = 3`, the upper bound on its fraction among the first
`N` numbered theorems is `3/N`:

| `N` | `3/N` |
|---:|---:|
| 10 | 0.3 |
| 100 | 0.03 |
| 1000 | 0.003 |
| 10000 | 0.0003 |

For idealized area-law storage `C(M)=M²`:

| `M` | `C(M)` |
|---:|---:|
| 1 | 1 |
| 2 | 4 |
| 3 | 9 |
| 4 | 16 |
| 5 | 25 |

Thus doubling mass multiplies capacity by four. Merging masses `2` and `3` changes
capacity from `2²+3²=13` to `(2+3)²=25`, a gain of `12 = 2·2·3`.

## OEIS search

The area-law sample `1,4,9,16,25,...` is the square numbers (OEIS A000290). No OEIS
sequence is germane to the finite-set density theorem.

## Counterexample hunt

The phrase “all countably many theorems can be discovered in finite time” has an
immediate counterexample under its global-time reading: the identity enumeration of
`ℕ`. At every finite budget `B`, only `{0,...,B-1}` has appeared, leaving `B` itself
undiscovered. The formal no-go theorem generalizes this to every enumeration of every
infinite type.

No counterexample exists to the corrected pointwise statement that a surjective
numbering gives each individual theorem some finite index; this does not provide one
uniform finite bound for all theorems.

## Scope of the numerical constants

`10^120` is treated in the formalization as a named finite operation budget, not as a
mathematically derived cosmological constant. Likewise, `C(M)=cM²` is an explicit
idealized area-law model; the Lean theorems prove its scaling consequences rather than
deriving the physical Bekenstein bound from general relativity and quantum theory.
