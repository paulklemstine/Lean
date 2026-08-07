# Computational Evidence

All numbers below were produced by evaluating the *definitions used in the Lean files*
(`#eval` against the compiled modules), not by external scripts. They are sanity checks that
the formal statements say what they are meant to say; the mathematical content is carried by
the machine-checked theorems, not by these tables.

## 1. Prefix-free codes and Kraft's inequality

Definitions from `Catalog/Computation/PrefixFreeThermoCoding.lean`
(`PrefixFree`, `boolLists`, Kraft sum `∑ 2^{-|w|}`).

| code `S`                     | prefix-free? | Kraft sum |
|------------------------------|--------------|-----------|
| `{0, 10, 11}`                | yes (decided in Lean) | `1`   |
| `{00, 10, 11}`               | yes (decided in Lean) | `3/4` |
| `{0, 01, 1, 10}`             | **no**       | `3/2` (> 1, so Kraft must fail) |

`#eval (boolLists 3).card = 8`, matching `card_boolLists : (boolLists n).card = 2 ^ n`.

The first row is the equality case: the code is complete (`Kraft = 1`) and, matched with
`p = (1/2, 1/4, 1/4)`, has expected length `1/2·1 + 1/4·2 + 1/4·2 = 1.5` bits, exactly the
Shannon entropy `H(p) = 1.5`. This instance is checked *as a theorem* in the file (final
`example`, discharged by `dyadic_code_achieves_entropy`), not just numerically.

The third row is the intended counterexample hunt: dropping prefix-freeness immediately
breaks the bound (`3/2 > 1`), so the hypothesis of `kraft_inequality` is load-bearing.

## 2. Verification fibers and history capacity

Definitions from `Catalog/Computation/ReversibleVerificationFrontier.lean`.

| verifier `f`                          | `maxFiber f` | minimal history states |
|---------------------------------------|--------------|------------------------|
| `Fin 6 → Fin 2`, `x ↦ x mod 2`        | `3`          | `3`                    |
| `Fin 6 → Fin 6`, `x ↦ x` (injective)  | `1`          | `1` (already reversible) |
| `Fin 6 → Fin 3`, constant             | `6`          | `6` (full input space) |

These match the three regimes of `reversible_history_iff`: partial merging, no merging, and
total collapse (`total_collapse_needs_full_history`).

## 3. Description cost versus search cost

For the canonical code on binary statements of length `N = n + 2`
(`Catalog/Computation/SearchCostSeparation.lean`):

| `N` | mean description length | proved lower bound on mean search work (`2^{N-2}`) |
|-----|--------------------------|-----------------------------------------------------|
| 2   | 2                        | 1                                                    |
| 6   | 6                        | 16                                                   |
| 12  | 12                       | 1024                                                 |
| 22  | 22                       | 1048576                                              |

The left column grows linearly, the right exponentially — the separation proved in
`linear_description_exponential_search`. The counting input is
`card_compressible_le`: at most `2^{m+1} − 1` statements admit a description of length `≤ m`,
e.g. only `2^{N-1} − 1 < 2^{N-1}` of the `2^N` statements can be compressed below `N − 1`
bits.

## 4. OEIS

The only integer sequences appearing are `2^n` (A000079) and `2^{n+1} − 1`
(A000225, the cardinality of the set of binary words of length `≤ n`, `card_shortWords`).
No new or unidentified sequence arose, so no OEIS search was needed beyond these.

## 5. Counterexample hunt (negative results worth recording)

* **Kraft without prefix-freeness fails** — row 3 of §1.
* **`erasedBits f = log₂ (maxFiber f)` is false in general.** For `f : Fin 6 → Fin 2`,
  `x ↦ x mod 2`, we have `maxFiber = 3` but the fibers have sizes `3` and `3`, so
  `erasedBits f = log₂ 6 − log₂ 2 = log₂ 3 = log₂ (maxFiber f)`; changing the codomain to
  `Fin 4` with fiber sizes `3,1,1,1` gives `erasedBits = log₂ 6 − log₂ 4 < log₂ 3`. Hence
  only the *inequality* `erasedBits_le_logb_maxFiber` is provable in general, and the
  equality is proved exactly in the collapsing case (`erasedBits_constant_eq_logb`).
* **The equality case of the coding theorem needs `p i > 0`.** With a zero-probability
  theorem the codeword length is unconstrained, so `expected_length_eq_entropy_iff` would be
  false without that hypothesis; it is therefore kept explicit.

---

# Cycle 2 evidence: Kraft's converse and the fiber-entropy chain

## 6. The packing construction, computed

The code produced by `KraftConverse.word` (big-endian name of the cumulative dyadic block
`∑_{j<i} 2^{L-ℓ j}`), evaluated directly from the Lean definition:

| length profile `ℓ` | depth `L` | codewords produced | Kraft sum |
|---|---|---|---|
| `(1,2,2)`   | 2 | `0`, `10`, `11`        | `1`   |
| `(1,2,3,3)` | 3 | `0`, `10`, `110`, `111`| `1`   |

Both outputs are prefix-free and complete, matching the classical codes used in
`PrefixFreeThermoCoding`. The first row is also checked inside the Lean file itself
(`example ... := by decide`).

## 7. Counterexample hunt: is sorting really needed?

Evaluating the same construction on the **unsorted** profile `(2,1)` at depth `L = 2`:

| index `i` | block start `pref` | codeword |
|---|---|---|
| 0 | 0 | `00` |
| 1 | 1 | `0`  |

`0` is a prefix of `00`, so the output is *not* prefix-free: the second block starts at the
misaligned position `1`, which is not a multiple of its own size `2`. This is exactly the
role of `pref_dvd`, and it is why `kraft_converse` sorts the profile with `Tuple.sort`
before packing. The hypothesis is load-bearing, not cosmetic.

## 8. The three quantities of the refined space–heat chain

For the collapsing verifier `collapse32 = ![0,0,1] : Fin 3 → Fin 2` (fiber sizes `2, 1`,
`maxFiber = 2`, `imageCard = 2`, all computed by `decide` in the Lean file):

| quantity | value | numeric |
|---|---|---|
| dissipated bits `erasedBits`         | `log₂ 3 − 1` | `0.584963…` |
| expected history capacity `condEntropy` | `2/3`     | `0.666667…` |
| worst-case capacity `log₂ maxFiber`  | `1`          | `1.000000…` |

Both inequalities are strict: the previous cycle's bound overestimates the realised
dissipation by `≈ 0.415` bits, and the new middle term cuts that slack to `≈ 0.082` bits. The chain
collapses to equalities exactly on regular verifiers (`regular_verifier_chain_eq`), e.g.
`x ↦ x mod 2` on `Fin 6`, where all three equal `log₂ 3`.

## 9. The Jensen defect of the space–heat chain (this cycle)

The remaining slack of the refined chain — the quantity `condEntropy f − erasedBits f` from
§8 — was conjectured (future direction B′) to be exactly the *Jensen defect*
`log₂ |im f| − H(f_*p)` of the fiber-size distribution against the uniform distribution on
the image.  Before formalising, the identity was checked on all fiber profiles below, where
`f_*p` is the fiber-size distribution `(c_b / N)_b` induced by the uniform input.

| fiber sizes `(c_b)` | `N` | `|im f|` | `erasedBits` | `condEntropy` | `log₂ maxFiber` | `H(f_*p)` | `log₂|im f| − H(f_*p)` |
|---|---|---|---|---|---|---|---|
| `(2,1)`   | 3 | 2 | 0.584963 | 0.666667 | 1.000000 | 0.918296 | 0.081704 |
| `(3,1)`   | 4 | 2 | 1.000000 | 1.188722 | 1.584963 | 0.811278 | 0.188722 |
| `(2,2)`   | 4 | 2 | 1.000000 | 1.000000 | 1.000000 | 1.000000 | 0.000000 |
| `(4,1,1)` | 6 | 3 | 1.000000 | 1.333333 | 2.000000 | 1.251629 | 0.333333 |
| `(5,2,1)` | 8 | 3 | 1.415037 | 1.701205 | 2.321928 | 1.298795 | 0.286168 |
| `(1,1,1,1)`| 4 | 4 | 0.000000 | 0.000000 | 0.000000 | 2.000000 | 0.000000 |

In every row the last column equals `condEntropy − erasedBits` to the printed precision,
and it vanishes exactly on the regular profiles `(2,2)` and `(1,1,1,1)`.  This is the
numerical prediction; the identity itself is now proved for **all** finite verifiers in
`Catalog/Computation/WeightedFiberEntropy.lean` (`jensen_defect_identity`), together with
non-negativity of the defect (`jensen_defect_nonneg`), its vanishing on regular verifiers
(`jensen_defect_eq_zero_of_regular`), and its strict positivity for `![0,0,1]`
(`jensen_defect_collapse32_pos`, machine-checked from `strict_refinement_example`).

**Negative finding recorded.**  The chain rule `H(x ∣ f x) = H(p) − H(f_*p)` does *not*
require `p` to be a probability vector — it holds for every non-negative weight — but it
*does* fail if negative weights are allowed, since the step
`log₂ (p x / (f_*p)(f x)) = log₂ p x − log₂ (f_*p)(f x)` needs both arguments positive and
Lean's convention `logb 2 t = 0` for `t ≤ 0` then breaks the split.  The Lean statement
therefore carries `hp : ∀ x, 0 ≤ p x` and nothing more; degenerate (zero-weight) fibers are
handled explicitly rather than excluded.
