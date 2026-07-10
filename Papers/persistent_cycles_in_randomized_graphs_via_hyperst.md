# Computational evidence — Persistent Cycles in Randomized Graphs

This note records the small-case reasoning that guided the formalization in
`Retention.lean`, `Contrarian.lean` and `LongPath.lean`.  The claims below are all
*proved* in the accompanying Lean files (with only the standard axioms
`propext, Classical.choice, Quot.sound`); the evidence here is what convinced us
each conjecture was worth stating in the direction it was stated.

## 1. The exact survival law `p^|S|`

Model: a finite edge set `ι`; each edge kept independently with probability `p`;
outcome `ω : ι → Bool`, weight `∏_e (if ω e then p else 1-p)`.

Small cases of "the fixed set `S` survives entirely":

| `|S|` | probability |
|------:|:-----------|
| 0     | `1`         |
| 1     | `p`         |
| 2     | `p^2`       |
| 3     | `p^3`       |
| `L`   | `p^L`       |

This is `PersistentCycles.prob_survives`.  Sanity checks:
* Total mass `∑_ω weight = (p + (1-p))^{|ι|} = 1` for every real `p`
  (`sum_weight`); e.g. `|ι| = 2`: `p^2 + 2p(1-p) + (1-p)^2 = 1`.
* Monotone: `p^{|T|} ≤ p^{|S|}` when `S ⊆ T`, `0 ≤ p ≤ 1` (`prob_survives_antitone`).

## 2. Counterexample hunt: does a *single* long cycle persist?

Bold conjecture: "for fixed `p < 1`, a fixed cycle of length `L` survives a.a.s.
as `L → ∞`."

Numerically, with `p = 0.9`:

| `L`  | `p^L`  |
|-----:|:-------|
| 10   | 0.349  |
| 50   | 0.0052 |
| 100  | 2.7e-5 |
| 500  | 1.3e-23|

`p^L → 0`, so the conjecture is **false** — a single prescribed long cycle is
fragile.  Formalized as `PersistentCycles.single_structure_fragility`
(`Tendsto (fun L => Prob p (survives univ) on Fin L) atTop (𝓝 0)`, and the value
is exactly `p^L`).  Persistence must therefore come from having *many* cycles.

## 3. First moment / union bound

For a family `F` of candidate cycles:
* Expected number surviving `= ∑_{S∈F} p^{|S|}` (`exp_surviving_eq`), a linear
  identity — e.g. `N` disjoint length-`L` cycles give expectation `N·p^L`.
* `P(at least one survives) ≤ ∑_{S∈F} p^{|S|}` (`prob_survivor_family_le`).
  Hence if the expected count `→ 0` then *a.a.s. none survives*; if the expected
  count is bounded below and the second moment behaves, some survive.
* Expected number of retained edges `= p·|ι|` (`exp_retained_edges`): with
  `p ≈ d/log n` this is the surviving-degree scaling driving the `d − εd` target.

## 4. Deterministic backbone (why degree ⇒ long path)

Take a longest path `v_0 … v_ℓ`.  Every neighbour of `v_ℓ` lies on the path (else
extend it), and `v_ℓ` has `≥ k` neighbours, all distinct path-vertices `≠ v_ℓ`.
So `ℓ + 1 ≥ k + 1`, i.e. `ℓ ≥ k`.

Small cases:
* `k = 2` (2-regular): the extremal graph is the cycle `C_n`, a single path/cycle
  of length `n ≥ 2` — the bound `ℓ ≥ 2` holds and is tight for `C_3`.
* `K_{k+1}` (complete graph, degree `k`): Hamiltonian path of length `k`, so the
  bound `ℓ ≥ k` is tight.

Formalized as `PersistentCycles.exists_long_path` and
`exists_long_path_of_minDegree`.

## OEIS

No new integer sequence arises; the governing quantities are the elementary
`p^L` (survival) and `p·|E|` (expected retained edges).
