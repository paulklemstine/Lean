# Computational evidence (exploratory, *not* machine-verified)

All numbers below come from floating-point exploration scripts run before formalisation.
They are **not** part of the verified artifact; the verified statements are exactly the Lean
theorems in `Catalog/Shared/Fourier*.lean`, which build with no `sorry` and use only the
standard axioms `propext`, `Classical.choice`, `Quot.sound`.

## 1. Donoho–Stark: minimum of `|supp f| · |supp f̂|` over random `f` on `Z/n`

2000 random sparse complex vectors per `n` (support chosen uniformly, entries in
`{-2,…,2} + i{-2,…,2}`), transform `f̂(k) = ∑_x e^{-2πikx/n} f(x)`, tolerance `10⁻⁹`.

| n | minimum observed `|supp f|·|supp f̂|` | proved lower bound |
|---|---|---|
| 3 | 3 | 3 |
| 4 | 4 | 4 |
| 5 | 5 | 5 |
| 6 | 6 | 6 |
| 8 | 8 | 8 |
| 9 | 9 | 9 |
| 12 | 12 | 12 |

No violation of `|supp f| · |supp f̂| ≥ n` was found, and the bound is attained in every case —
consistent with `FourierCyclic.uncertainty_zmod` and with the extremal families we then proved
(`FourierFA.uncertainty_eq_coset_modulation`).

## 2. Subgroup indicators are extremal, and `|H| · |H^⊥| = |G|`

Indicators `1_H` of the subgroups `H ≤ Z/n`:

| n | \|H\| | \|supp 1_H\| | \|supp (1_H)^\| | product |
|---|---|---|---|---|
| 6 | 1 | 1 | 6 | 6 |
| 6 | 2 | 2 | 3 | 6 |
| 6 | 3 | 3 | 2 | 6 |
| 6 | 6 | 6 | 1 | 6 |
| 8 | 2 | 2 | 4 | 8 |
| 8 | 4 | 4 | 2 | 8 |
| 12 | 3 | 3 | 4 | 12 |
| 12 | 4 | 4 | 3 | 12 |
| 12 | 6 | 6 | 2 | 12 |

The observed `|supp (1_H)^| = |G| / |H|` motivated the Plancherel proof of
`FourierFA.card_subgroup_mul_card_annihilator` (`|H| · |H^⊥| = |G|`), which avoids any appeal to
Pontryagin duality for the quotient group.

## 3. Sumset criterion: exhaustive search on `Z/n`, `n ≤ 8`

For every pair of subsets `A, B ⊆ Z/n` we tested the Cauchy–Schwarz hypothesis
`(n-|A|)(n-|B|) < |A||B|` against the conclusion `A + B = Z/n`.

| n | instances satisfying the hypothesis | counterexamples to `A+B = G` |
|---|---|---|
| 5 | 386 | 0 |
| 6 | 1586 | 0 |
| 7 | 6476 | 0 |
| 8 | 26333 | 0 |

**Negative finding (important).** A follow-up count showed there is *no* pair of cardinalities
with `(n-a)(n-b) < ab` and `a + b ≤ n`. Indeed the two conditions are algebraically equivalent
(`n² < n(a+b)`), so the Fourier/Cauchy–Schwarz argument recovers, but does not beat, the
pigeonhole threshold. This is recorded honestly in Lean as
`FourierAdd.cardCondition_iff`, and the docstring of `FourierAdd.exists_add_eq` states it.
The genuinely new content in that file is therefore the exact Plancherel identity
`FourierAdd.energy_identity` and the covering bound `FourierAdd.card_support_rep_ge`, which do
not reduce to pigeonhole.

## 4. OEIS

No new integer sequence arose: the quantities encountered (`|G|`, `|H|`, `|G|/|H|`) are
divisor data of the group order, and were not searched further.
