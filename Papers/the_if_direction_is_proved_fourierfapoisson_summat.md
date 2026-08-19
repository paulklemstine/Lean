# Computational evidence — converse of finite Poisson summation

Research thread: `FourierFA.poisson_summation` (the "if" direction) is proved in
`Catalog/Pythagorean/FourierSubgroupDuality.lean`.  This cycle attacked the **converse**:
for which finsets `S` of a finite abelian group `G` can the identity

```
|G| * ∑_{x ∈ S} f x  =  |S| * ∑_{ψ ∈ S^⊥} f̂ ψ        (P_S),   S^⊥ = {ψ : ψ|_S = 1}
```

hold for *all* `f : G → ℂ`?

Everything below marked **[Lean]** is machine-checked in this project (0 sorries, only the
standard axioms `propext`, `Classical.choice`, `Quot.sound`).  Items marked **[script]** come
from an exploratory Python enumeration and are *not* a formal verification; they were used to
choose which statements to formalise, and each one that mattered was subsequently reproved in
Lean by exhaustive `decide`.

## 1. Small-case enumeration of Poisson sets

By the classification proved this cycle, `(P_S)` reduces to the decidable condition
"`S = ∅`, or `0 ∈ S` and `S` is closed under subtraction" (`FourierFA.poissonSet_iff_comb`
**[Lean]**).  Enumerating all `2^{|G|}` subsets:

| group            | order | nonempty Poisson sets | list |
|------------------|-------|-----------------------|------|
| `ZMod 4`         | 4     | 3 **[Lean]**          | `{0}`, `{0,2}`, `univ` |
| `ZMod 5`         | 5     | 2 **[Lean]**          | `{0}`, `univ` |
| `ZMod 6`         | 6     | 4 **[Lean]**          | `{0}`, `{0,3}`, `{0,2,4}`, `univ` |
| `ZMod 8`         | 8     | 4 **[Lean]**          | `{0}`, `{0,4}`, `{0,2,4,6}`, `univ` |
| `ZMod 2 × ZMod 2`| 4     | 5 **[Lean]**          | `{0}`, three order-2 lines, `univ` |
| `ZMod 9`         | 9     | 3 **[script]**        | — |
| `ZMod 12`        | 12    | 6 **[Lean]**          | via the general divisor formula |
| `ZMod 2 × ZMod 4`| 8     | 8 **[script]**        | — |
| `(ZMod 2)^3`     | 8     | 16 **[script]**       | — |
| `ZMod 3 × ZMod 3`| 9     | 6 **[script]**        | — |

## 2. Sequence identified

For `G = ZMod n` the counts `1, 2, 2, 3, 2, 4, 2, 4, 3, 4, 2, 6` (`n = 1..12`) **[script]**
are exactly `d(n)`, the number of divisors — **OEIS A000005**.  This is not a coincidence:
the general statement "number of nonempty Poisson sets = number of subgroups"
(`FourierFA.card_poissonSets_eq_card_subgroups` **[Lean]**) was proved as an explicit
bijection, and the indexing of the subgroups of a cyclic group by divisors was then proved as
well, giving `FourierFA.card_poissonSets_zmod` **[Lean]**: the count is `d(n)` for *every*
`n`, not just the enumerated ones.  The `ZMod 12` entry above is an instance of that theorem
checked in Lean.

The comparison `ZMod 4` (3) versus `ZMod 2 × ZMod 2` (5) shows the count is *not* a function
of `|G|`; this is formalised as `FourierFA.poissonSpectrum_distinguishes_zmod4_klein`
**[Lean]**.

## 3. Counterexample hunt (universal claim "every nonempty `S` is Poisson")

Refuted immediately, and quantitatively: the defect
`|G| ∑_{x∈S} f − |S| ∑_{ψ∈S^⊥} f̂` at a Dirac delta `δ_{y₀}`, `y₀ ∈ S`, equals
`|G|(|⟨S⟩| − |S|)/|⟨S⟩|` (`FourierFA.poisson_defect_formula` **[Lean]**), hence is
`≥ |⟨S⟩| − |S| ≥ 1` whenever `S` is not a subgroup (`FourierFA.poisson_gap` **[Lean]**).
So there are no "approximate Poisson sets" at all.

## 4. Quadratic-residue table (Pythagorean relevance)

Squares mod `n`, and whether they satisfy `(P_S)`:

| n | squares mod n | Poisson? |
|---|---------------|----------|
| 1 | {0}           | yes **[Lean]** |
| 2 | {0,1}         | yes **[Lean]** |
| 3 | {0,1}         | no **[Lean]** |
| 4 | {0,1}         | no **[Lean]** |
| 5 | {0,1,4}       | no **[Lean]** |
| 6 | {0,1,3,4}     | no **[Lean]** |
| 7 | {0,1,2,4}     | no **[Lean]** |
| 8 | {0,1,4}       | no **[Lean]** |
| 9 | {0,1,4,7}     | no **[script]** |
|10 | {0,1,4,5,6,9} | no **[script]** |
|11 | {0,1,3,4,5,9} | no **[script]** |
|12 | {0,1,4,9}     | no **[script]** |

For `n = 8` the squares generate all of `ZMod 8`, so the gap theorem yields the explicit
bound `‖defect‖ ≥ 8 − 3 = 5` (`FourierFA.poisson_gap_squares_zmod8` **[Lean]**).

## 5. What the evidence changed

* The empty set was found to satisfy `(P_∅)` vacuously — the enumeration flagged it before the
  proof was written, which is why the nonemptiness hypothesis appears in
  `poissonSet_iff_subgroup` and why the hypothesis-free classification
  `poissonSet_iff` carries the extra `S = ∅` disjunct.
* The enumeration showed that unions of Poisson sets are usually not Poisson while
  intersections always are; both were then proved (`poissonSet_inter`,
  `not_poissonSet_union_example`).
