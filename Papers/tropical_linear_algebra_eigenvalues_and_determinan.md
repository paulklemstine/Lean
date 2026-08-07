# Computational evidence — tropical linear algebra

All computations below were performed with exact rational arithmetic (`ℚ`) inside Lean 4
(`#eval`, brute-force max-plus routines over lists), *before* the corresponding general
theorems were formalised.  Where a claim is now backed by a machine-checked theorem, the
Lean name is given.

## 1. Maximum cycle mean of small matrices

| matrix | entries | max cycle mean λ | check |
|---|---|---|---|
| `A₁` | `[[0,2],[2,0]]` | `2` | cycle `1→2→1` has mean `(2+2)/2 = 2` |
| `A₂` | `[[1,3],[2,0]]` | `5/2` | loops give `1` and `0`, 2-cycle gives `5/2` |
| `A₃` | `[[0,1,-1],[-1,0,2],[3,-2,0]]` | `2` | cycle `1→2→3→1` has mean `(1+2+3)/3 = 2` |

`A₁` is the example formalised in `Examples.lean`: `TropicalLA.Examples.maxCycleMean_example`
proves `maxCycleMean A₁ = 2` (via existence + uniqueness of the tropical eigenvalue), and
`isTropEigen_example` exhibits the constant eigenvector.

## 2. Growth rate of tropical powers (evidence for the Gelfand formula)

For `A₃` the normalised largest entry `‖A^{⊗(m+1)}‖/(m+1)`, `m = 0,…,7`:

```
3, 5/2, 2, 9/4, 11/5, 2, 15/7, 17/8   →  2 = λ(A₃)
```

The sequence oscillates around `λ` and the deviation decays like `C/m`, exactly the
behaviour predicted (and now proved) by `TropicalLA.abs_specNorm_sub_le` and
`TropicalLA.tendsto_specNorm_div`, with `C` the spread of an eigenvector.

The first tropical powers of `A₃` (`A^{⊗1}, …, A^{⊗4}`):

```
[[0,1,-1],[-1,0,2],[3,-2,0]]      [[2,1,3],[5,0,2],[3,4,2]]
[[6,3,3],[5,6,4],[5,4,6]]         [[6,7,5],[7,6,8],[9,6,6]]
```

## 3. Counterexample hunt: is the tropical determinant multiplicative?

An unverified sampling experiment (20000 random pairs of `2 × 2` matrices with integer
entries drawn uniformly from `[-3,3]`, computed outside Lean) found the inequality
`tdet A + tdet B ≤ tdet (A ⊗ B)` **strict in 5392 of 20000 cases (≈ 27%)**; equality held
in the remaining ≈ 73%.  So failure of multiplicativity is common rather than exceptional.
The following small degenerate pair is the violation that was then machine-checked in Lean:

```
A = [[0,0],[0,0]],  B = [[0,0],[-1,-1]]
tdet A = 0,  tdet B = -1,  A ⊗ B = [[0,0],[0,0]],  tdet (A ⊗ B) = 0
tdet A + tdet B = -1  <  0 = tdet (A ⊗ B)
```

This is now the machine-checked theorem `TropicalLA.Examples.tdet_tmul_strict`; the
general one-sided statement is `TropicalLA.tdet_tmul_ge` (supermultiplicativity).

## 4. Characteristic polynomial corners

For `A₁ = [[0,2],[2,0]]` (with `n = 2`) the coefficients are `c₀ = 0`, `c₁ = 0`
(best diagonal entry), `c₂ = 4` (best permutation), so

```
p(x) = max(2x, x, 4)
```

whose corner locus (points where the maximum is attained twice) contains `x = 2 = λ`,
matching `TropicalLA.eigen_isTropicalRoot`: at `x = λ` the maximum equals `n·λ = 4` and
is attained both in degree `0` and in the degree given by the critical cycle (here `2`).

## 5. Sequence lookup

No new integer sequence arises: the objects here are real-valued optima (assignment
values, cycle means), so an OEIS search is not applicable.

---

# Second cycle — evidence for cyclicity and for the Newton-polygon results

The numbers in this section come from an exploratory exact-integer computation
(brute-force max-plus multiplication, rational cycle means) run outside Lean; they are
*experimental data*, not verified claims.  The general statements they suggested are now
machine-checked in `TropicalCyclicity.lean`, `TropicalCyclicityInteger.lean` and
`TropicalNewtonPolygon.lean`.

## 6. Period and transient of tropical powers (evidence for conjecture C1)

For each integer matrix we searched for the smallest `p ≥ 1` and `N ≥ 0` with
`A^{⊗(m+p+1)} = (p·λ) ⊗ A^{⊗(m+1)}` for all `N ≤ m ≤ 13`:

| matrix | `λ` | period `p` | transient `N` |
|---|---|---|---|
| `[[0,-2],[-3,-1]]` | `0` | `1` | `4` |
| `[[0,2],[2,0]]` | `2` | `2` | `0` |
| `[[-10,0],[0,-10]]` | `0` | `2` | `0` |
| `[[1,3,-2],[-4,0,2],[5,-3,-1]]` | `10/3` | `3` | `2` |

Every sample was eventually exactly periodic, with `p·λ ∈ ℤ` in each case — the two
features the proof of `TropicalLA.exists_cyclicity` exploits (a critical cycle of length
`q` makes `q·λ` an integer, and integrality makes the box of normalised powers finite).

## 7. Counterexample hunt: is the eigenvector spread a two-sided bound?

Sub-conjecture 1 of the previous cycle asked whether every entry of `A^{⊗(m+1)} − (m+1)λ`
lies in `[−spread(v), spread(v)]`.  Searching small matrices found immediate violations of
the lower half, the simplest being

```
A = [[0,-3],[0,-3]],  v = (0,0) is an eigenvector,  λ = 0,  spread(v) = 0
A^{⊗(m+1)} i 1 = -3   for every m and every i
```

so the deviation `−3` is bounded but not by the spread.  This is now the machine-checked
theorem `TropicalLA.no_spread_lower_bound`; the corrected uniform bound (with constant
`spread(v) + (1+q)·|min entry − λ|`) is `TropicalLA.exists_uniform_entry_bound`.

## 8. Newton polygon of the characteristic polynomial

For `A₄ = [[1,3,-2],[-4,0,2],[5,-3,-1]]` (with `n = 3`, `λ = 10/3`) the characteristic
coefficients are `c₀ = 0`, `c₁ = 1`, `c₂ = 3`, `c₃ = 10`, so

```
max_{1 ≤ k ≤ 3} c_k / k = max(1, 3/2, 10/3) = 10/3 = λ,
```

matching the verified `TropicalLA.isGreatest_charCoeff_div`; and for `x > 10/3` the
degree-`0` monomial `3x` strictly dominates all others, so `10/3` is the largest corner —
the content of `TropicalLA.isGreatest_tropicalRoot`.

## 9. Matrices with `−∞` entries: is irreducibility necessary?

Before attacking conjecture C4 we swept all `2 × 2` matrices with entries in
`{⊥, −1, 0, 1}` (256 matrices).  For each one, strong connectivity of the support digraph
was decided by transitive closure, and existence of a finite eigenvector was decided
exactly: writing `d = v₀ − v₁`, an eigenpair exists iff the nonincreasing function
`f(d) = max(a₀₀, a₀₁ − d)` and the nondecreasing function `g(d) = max(a₁₀ + d, a₁₁)` are
both finite and cross.

```
matrices swept                                256
strongly connected support                    144
admit a finite eigenvector                    201
strongly connected but no finite eigenvector    0     <- the implication survived
finite eigenvector but not strongly connected  57     <- the converse fails badly
```

The smallest witness against the converse is

```
A = [[0, ⊥], [⊥, 0]],   v = (0, 0),   max_j (A i j + v j) = 0 = 0 + v i
```

whose support digraph consists of two isolated loops.  Across the 57 failures the pattern
was always the same: the classes carrying the optimum were all *final* and had *equal*
maximum cycle mean (e.g. `[[0,⊥],[⊥,1]]`, whose two loops have different means, does *not*
have a finite eigenvector).  The displayed example is now the machine-checked pair
`TropicalLA.diagBotExample_isTropEigenBot` /
`TropicalLA.diagBotExample_not_stronglyConnected`, packaged as
`TropicalLA.not_stronglyConnected_of_isTropEigenBot_false`; the surviving implication is
the theorem `TropicalLA.exists_tropEigenBot_of_stronglyConnected`, and the observed
"equal final-class means" pattern is recorded as conjecture **D4** in
`FUTURE_DIRECTIONS.md`.

The same sweep was used to test the *condensation criterion* — "every row nonempty, all
final strongly connected components have the same maximum cycle mean `lam`, and every
component has maximum cycle mean at most `lam`" — against the exact existence test:

```
matrices swept                                    256
disagreements between the two criteria              0
```

which is what suggested the walk-level criterion that is now the theorem
`TropicalLA.tropEigenBot_iff_criticalReachable` (conditions `AllSuppCyclesLe` and
`ReachesCritical`), and what remains as conjecture **D4′**.

*(The sweeps themselves were exploratory computations and are not machine-checked; only the
displayed counterexample, the general implication and the walk-level criterion are formally
verified in Lean.)*
