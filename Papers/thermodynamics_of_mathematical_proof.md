# Computational Evidence — Thermodynamics of Mathematical Proof

We model a proof/computation step as a function `f : α → β` between finite state spaces and
define the **erased information**

```
erasedBits f = log₂(card α) − log₂(|image f|).
```

The Landauer cost of the step is `erasedBits f · k_B · T · ln 2`.

## 1. Small-case calculations

| step `f`                         | card α | \|image\| | erasedBits           | reversible? |
|----------------------------------|:------:|:---------:|:--------------------:|:-----------:|
| `id : Bool → Bool`               |   2    |    2      | `log₂2 − log₂2 = 0`  |   yes       |
| `not : Bool → Bool`              |   2    |    2      | `0`                  |   yes       |
| `AND : Bool² → Bool`             |   4    |    2      | `log₂4 − log₂2 = 1`  |   no        |
| `OR  : Bool² → Bool`             |   4    |    2      | `1`                  |   no        |
| `const : Fin 2 → Fin 2`          |   2    |    1      | `log₂2 − log₂1 = 1`  |   no        |
| `collapse n : Fin(2ⁿ) → Fin 1`   |  2ⁿ    |    1      | `n`                  |   no        |
| `bigCollapse m : Fin(2^(2ᵐ))→Fin1`| 2^(2ᵐ)|    1      | `2ᵐ`                 |   no        |
| Bennett `x ↦ (x, f x)`           | card α | card α    | `0`                  |   yes       |

These are exactly the values proved in the Lean files (`erasedBits_andGate = 1`,
`erasedBits_collapse n = n`, `erasedBits_bigCollapse m = 2^m`, `erasedBits_bennett = 0`).

## 2. Sequences

* `erasedBits (collapse n) = n`: the identity sequence `0,1,2,3,…` — linear erasure.
* `erasedBits (bigCollapse m) = 2^m`: `1,2,4,8,16,…` (OEIS A000079, powers of two) — the
  erasure of the doubly-exponential state space is exponential in the size parameter `m`,
  while its *description* is just the number `m`.  This is the exponential creation/erasure gap.
* Number of programs of length `< n` over a binary alphabet: `2ⁿ − 1` = `0,1,3,7,15,…`
  (OEIS A000225, Mersenne numbers).  Since there are `2ⁿ` Boolean predicates on `n` bits and
  only `2ⁿ − 1` shorter descriptions, some predicate is incompressible — the pigeonhole
  behind `incompressible`.

## 3. Counterexample hunt

We probed two tempting universal claims and found both **false**:

* *"Every non-identity step erases information."*  Counterexample: `not` (bijection, erases
  `0`).  Formalized as `exists_reversible_nontrivial_step`.
* *"Erasure is additive under composition,
  `erasedBits (g∘f) = erasedBits f + erasedBits g`."*  Counterexample: two constant maps on
  `Fin 2`, giving `1 ≠ 1 + 1`.  Formalized as `erasedBits_not_additive`.  The true statement
  is monotonicity `erasedBits f ≤ erasedBits (g∘f)` (`erasedBits_mono_comp`).

## 4. Sanity checks

All numeric erasure values above are confirmed inside Lean by `decide` on the finite image
cardinalities plus exact `logb` evaluation, so the table is machine-verified rather than
hand-computed.
