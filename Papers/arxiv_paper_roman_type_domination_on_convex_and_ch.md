# Computational evidence

All tables below were produced by exhaustive brute-force enumeration of *all*
labellings `f : V → {0,1,2}` (resp. `{0,1,2,3}`) of the complete bipartite graph
`K_{m,n}`, run inside Lean 4 with `#eval` (so the enumeration uses the very same
definitions of `IsRDF`, `IsIDF`, `IsDRDF` that are formalized in the `.lean`
files, transcribed to a list-based representation of `Fin m ⊕ Fin n`).

These computations guided the choice of the exact formulas that are then *proved*
in `Geometry/RomanDomination/ConvexBipartite.lean`.  They are exploratory only:
the machine-checked statements are the Lean theorems, not these tables.

## 1. Roman domination number of `K_{m,n}`

Exhaustive minimisation of `w(f)` over Roman dominating functions,
`1 ≤ m, n ≤ 5`.  The last column is the conjectured (and now proved) formula
`min 4 (min (m+1) (n+1))`.

| m \ n | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| **1** | 2 | 2 | 2 | 2 | 2 |
| **2** | 2 | 3 | 3 | 3 | 3 |
| **3** | 2 | 3 | 4 | 4 | 4 |
| **4** | 2 | 3 | 4 | 4 | 4 |
| **5** | 2 | 3 | 4 | 4 | 4 |

Every entry agrees with `min 4 (min (m+1) (n+1))` — no counterexample in the
25 tested pairs.  This is the statement `gammaR_K`.

## 2. Italian (Roman-`{2}`) domination number of `K_{m,n}`

| m \ n | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| **1** | 2 | 2 | 2 | 2 | 2 |
| **2** | 2 | 2 | 2 | 2 | 2 |
| **3** | 2 | 2 | 3 | 3 | 3 |
| **4** | 2 | 2 | 3 | 4 | 4 |
| **5** | 2 | 2 | 3 | 4 | 4 |

The formula `min 4 (min m n)` matches **exactly** on all pairs with
`m, n ≥ 2`, and fails only when `min(m,n) = 1` (the formula predicts `1`, the
true value is `2`).  Accordingly the formalized theorem `gammaI_K` carries the
hypotheses `2 ≤ m`, `2 ≤ n`.  This is a case where the computation directly
corrected a naive guess.

## 3. Double Roman domination number of `K_{m,n}`

| m \ n | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| **1** | 3 | 3 | 3 | 3 |
| **2** | 3 | 4 | 4 | 4 |
| **3** | 3 | 4 | 6 | 6 |
| **4** | 3 | 4 | 6 | 6 |

So `γ_dR(K_{m,n})` depends only on `k = min(m,n)`: it is `3` for `k = 1`,
`4` for `k = 2`, and `6` for `k ≥ 3`.  Note that this is *not* of the shape
`min 6 (k+2)` (which would give `5` at `k = 3`).  Proving this exact value is
left to future work (see `FUTURE_DIRECTIONS.md`); the general two-sided bounds
`2γ ≤ γ_dR ≤ 3γ`, `γ_R ≤ γ_dR ≤ 2γ_R` *are* proved.

## 4. Consistency with the proved inequality chain

Reading the three tables together for `m, n ≥ 3` gives
`γ_I = 4 ≤ γ_R = 4 ≤ γ_dR = 6 ≤ 2γ_R = 8`, and `γ(K_{m,n}) = 2`, so
`2γ = 4 ≤ γ_dR = 6 ≤ 3γ = 6` — the double Roman upper bound `γ_dR ≤ 3γ` is
attained here.  For `m = 1` (a star) one gets `γ = 1`, `γ_R = 2 = 2γ`,
`γ_dR = 3 = 3γ`: both extremes of the chain are simultaneously tight.

## 5. OEIS

The rows of the tables are eventually constant and carry no interesting
sequence structure; no OEIS entry was searched for or is claimed.

## 6. Counterexample hunt

For the universally quantified statements that are formalized (the inequality
chain between the six parameters) no counterexample can exist, since they are
proved.  The exploratory search above was instead used in the *opposite*
direction: to reject the candidate identity `γ_I(K_{m,n}) = min 4 (min m n)` for
`min(m,n) = 1`, and to reject `γ_dR(K_{m,n}) = min 6 (min m n + 2)`.
