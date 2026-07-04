# Computational Evidence — Dark Mathematics

We model a deductive system abstractly by a Cook–Reckhow proof system over the
formula type `DarkFormula` (instance statements `inst n` = `T(n)`, and counting
statements `atLeast k` = "there are at least `k` witnesses `x` with `T(x)`").
A system is **dark of level `k`** if it proves `atLeast k` but proves no `inst n`.

## 1. Small-case check of the strict hierarchy

The explicit witness system `boundedDark k` has proof objects `{ j // j ≤ k }`,
each concluding `atLeast j`. Its provability profile:

| `k` | provable counting statements | provable instances | dark levels reached | fails at |
|-----|------------------------------|--------------------|---------------------|----------|
| 0   | `atLeast 0`                  | none               | 0                   | level 1  |
| 1   | `atLeast 0,1`                | none               | 0,1                 | level 2  |
| 2   | `atLeast 0,1,2`              | none               | 0,1,2               | level 3  |
| 3   | `atLeast 0,1,2,3`            | none               | 0,1,2,3             | level 4  |

So `boundedDark k` is dark of every level `j ≤ k` but not of level `k+1`. The
top provable level equals `k` exactly, so the levels are genuinely distinct: the
hierarchy does not collapse. This is verified in `Core.lean`
(`dark_hierarchy_strict`).

## 2. Join amplification

Combining two dark theories via the lattice join (`ProofSystemCollapse.union`)
proves `atLeast (max a b)` while still naming no witness. Sample:

| `a` | `b` | `max a b` = join level |
|-----|-----|------------------------|
| 1   | 1   | 1                      |
| 1   | 3   | 3                      |
| 2   | 5   | 5                      |

The join can strictly exceed each component's level, so darkness compounds.
Verified as `dark_union_join` / `dark_union_boundedDark` in `DensityAndJoin.lean`.

## 3. Counterexample hunt for the density conjecture

The programme conjectured that dark theorems are *dense* among `Π₂` statements.
We tested the naive uniform reading by enumerating provability profiles over a
finite instance pool `Fin N` (a profile = the set of instances a theory proves;
dark ⇔ the empty set).

| `N` | total profiles `2^N` | dark profiles | uniform density |
|-----|----------------------|---------------|-----------------|
| 1   | 2                    | 1             | 1/2             |
| 2   | 4                    | 1             | 1/4             |
| 3   | 8                    | 1             | 1/8             |
| 4   | 16                   | 1             | 1/16            |

There is always **exactly one** dark profile (the empty one), so the uniform
density is `2^{-N} → 0`. This is a decisive counterexample to the *naive*
density conjecture: under uniform counting, dark theorems are exponentially
*rare*, not dense. Verified as `darkProfiles_card`, `allProfiles_card`, and
`naive_density_refuted` in `DensityAndJoin.lean`.

**Conclusion.** The strict-hierarchy and join-amplification hypotheses survived;
the naive-uniform density hypothesis was falsified. Genericity of independence
must therefore be phrased in a coarser (non-uniform) topology — recorded as a
future direction.
