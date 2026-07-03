# Computational Evidence — Dark Mathematics

We test the structural core of "dark theorems" (a system proves `∃x T(x)` but proves
no instance `T(n)`) inside the explicit model `concreteModel atomTrue` from
`DarkTheorems.lean`, where truth is `cTrue` and provability `cProv` is truth **except
that no atom is ever provable**.

## 1. Small-case calculations

Let `D n := atom n` (the identity predicate) and vary the atom-truth assignment.

| model `atomTrue`         | true atoms      | `Prov (∃x D)` | `Prov (D n)` any n | `Prov (AtLeast k D)` | dark? |
|--------------------------|-----------------|:-------------:|:------------------:|:--------------------:|:-----:|
| `fun _ => True`          | all of ℕ        | yes           | never              | yes, every k         | dark ∞ |
| `fun n => n < 3`         | {0,1,2}         | yes           | never              | yes iff k ≤ 3        | dark at level 3, not 4 |
| `fun n => n < 1`         | {0}             | yes           | never              | yes iff k ≤ 1        | dark at level 1, not 2 |
| `fun _ => False`         | ∅               | no            | never              | only k = 0           | not dark |

Reading off the table:
* Existential provable + no instance provable ⇒ genuine darkness whenever ≥1 atom is true.
* The provable witness-count is exactly the number of true atoms: this is the
  darkness **level**, and the levels are strictly separated (row `n < 3` is dark at 3
  but not 4). Formalized as `darkness_hierarchy_strict`.

## 2. Counting / density check

Family `Tg g n := atom (2n + [g n = false])` for `g : ℕ → Bool`.
* Every `Tg g` is atom-valued, so no instance is ever provable, and (in the
  "all true" model) `∃x Tg g x` is provable ⇒ every `Tg g` is dark.
* Distinct `g` give distinct predicates (the code `2n+…` recovers `g n`), so the dark
  set contains an injective copy of `ℕ → Bool` ⇒ **uncountable** (continuum-sized).
  This is the sharp, checkable form of "most Π₂ statements are dark"
  (`dark_theorems_uncountable`).

Sanity enumeration of the first codes for two assignments:
```
g = all-false : Tg 0=atom 1, Tg 1=atom 3, Tg 2=atom 5, ...   (odds)
g = all-true  : Tg 0=atom 0, Tg 1=atom 2, Tg 2=atom 4, ...   (evens)
```
Different at every coordinate ⇒ injective, as expected.

## 3. Counterexample hunt

* Claim "darkness ⇒ some instance is true" — tested against `fun _ => False`
  (the existential is then *not* provable, so vacuously no dark statement there): no
  counterexample; the shadow theorem `dark_has_true_unprovable_witness` only fires
  when the existential is actually provable, and then soundness delivers a true
  witness. No counterexample found across the assignments above.
* Claim "level k+1 ⇒ level k" — checked on `n < 3`: `AtLeast 3` provable ⇒ `AtLeast 2`,
  `AtLeast 1` provable (drop elements of the witness set). No counterexample.

## 4. OEIS

No integer sequence is central here; the darkness level equals the (possibly
infinite) count of true atoms, and the abundance result is a cardinality statement
(continuum), not a counting sequence, so no OEIS entry applies.

## Conclusion

The computational picture matches all four formalized theorems: darkness is real
(non-vacuous), soundness-relative, strictly stratified by witness count, and generic
(uncountable). Evidence collection was kept minimal since the model is finite-to-check
per case and the general statements are the actual deliverables.
