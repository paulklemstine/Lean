# Computational Evidence — Cycle 6 (Markov-chain frame definability)

All computations below were carried out inside Lean 4 with **exact rational
arithmetic** (`ℚ`), using a computable replica `sp` of the file's `stepPow`
(the library version is `ℝ`-valued and therefore noncomputable):

```lean
def sp {S : Type} [Fintype S] [DecidableEq S] (P : S → S → ℚ) : ℕ → S → S → ℚ
  | 0,     u, v => if u = v then 1 else 0
  | n + 1, u, v => ∑ z, P u z * sp P n z v
```

They are exploratory calculations that guided the statements; the theorems
themselves are proved in Lean without any appeal to these evaluations.

---

## 1. Soundness spectrum of the deterministic `n`-cycle

`cyc3 u v = [v = u+1]` on `Fin 3`, return probabilities `P^n(0,0)` for `n = 0..9`:

```
[1, 0, 0, 1, 0, 0, 1, 0, 0, 1]
```

Positive exactly at `n ∈ {0, 3, 6, 9}`.  The same computation on `Fin 2` gives
`[1,0,1,0,1,0,1,0]`, positive exactly at the even `n`.

**Supports** `iterSound_cycleChain_iff` (`IterSoundAt … k w ↔ n ∣ k`) and
`soundMonoid_cycleChain` (spectrum `= nℕ`).  The sequence of indicator values is the
characteristic sequence of `nℕ` (OEIS A079978 for `n = 3`, A059841 for `n = 2`); no
richer structure appears, matching the theorem exactly.

## 2. Primitivity of an irreducible lazy chain

`lazy3 u v = 1/2` if `v = u`, `1/2` if `v = u+1`, else `0`, on `Fin 3`.
Positivity pattern of the whole matrix `P^n` for `n = 0..7` (a `3×3` boolean grid per
`n`):

```
n = 0 : I            (only the diagonal)
n = 1 : 2 per row    (diagonal and successor)
n ≥ 2 : all entries positive
```

Sample of the actual numbers, `P^n(0,2)` for `n = 0..7`:

```
[0, 0, 1/4, 3/8, 3/8, 11/32, 21/64, 21/64]
```

**Supports** `exists_uniform_primitive`: a uniform threshold exists, here `N = 2`.
Note `N = 2 = a + b` with `a = 0` (`0 ⇝ 0`) and `b = 2` (`0 ⇝ 2`), exactly the bound
produced by the path-padding lemma `iterR_of_add_le`.

## 3. Counterexample hunt: is the self-loop hypothesis needed?

`two` (the `2`-cycle) is irreducible but has no self-loop; `P^n(0,0)` is positive only
for even `n`, so its spectrum `2ℕ` is **not** cofinite.

**Supports** `cycleChain_spectrum_not_cofinite`, and shows the looping hypothesis of
`exists_forall_iterSound` is load-bearing rather than decorative.

## 4. Lumpability check

The `4`-cycle lumped onto the `2`-cycle by `x ↦ x mod 2`.  For every pair
`(u, y) ∈ Fin 4 × Fin 2` we computed

```
(∑_{v : f v = y} P₄(u,v)) − P₂(f u, y)
```

obtaining

```
[0, 0, 0, 0, 0, 0, 0, 0]
```

i.e. strong lumpability holds exactly.

**Supports** `cycleLumpable` and hence `cycleSystem_thm_mono`.

## 5. The open case: irreducible, aperiodic, **no** self-loop

`ap` on `Fin 3`: `0 → 1` surely, `1 → 2` or `1 → 0` with probability `1/2` each,
`2 → 0` surely.  This chain has cycles of length `2` and `3`, hence period `1`, but no
self-loop.  Indicator of `0 < P^n(0,0)` for `n = 0..11`:

```
[true, false, true, true, true, true, true, true, true, true, true, true]
```

So the spectrum is `{0, 2, 3, 4, 5, …}` — cofinite, but with a **gap at `1`**: it is the
numerical semigroup `⟨2,3⟩`, whose Frobenius number is `1`.

**Consequence for the formalisation.**  The proof technique used in
`Probability.MarkovPrimitivity` (path padding through a self-loop) cannot reach this
case: the threshold is not `a + b` but is governed by the Frobenius number of the
cycle-length semigroup.  This is precisely the content of Future Direction 1
(*Frobenius Threshold for Aperiodic Soundness Spectra*), and the table above is the
computational evidence motivating it.

## 6. Cycle 7: the primitivity exponent of the loopless chain `apChain`

Exact rational computation of the support pattern of `apChainⁿ` (entry shown as `+` when
the exact rational is `> 0`, `.` when it is `0`), for `n = 0, …, 8`:

```
n = 0   + . .    n = 1   . + .    n = 2   + . +
        . + .            + . +            + + .
        . . +            + . .            . + .

n = 3   + + .    n = 4   + + +    n = 5   + + +
        + + +            + + +            + + +
        + . +            + + .            + + +

n ≥ 5   all entries strictly positive.
```

Two readings of the same table.

* **Aperiodicity.** The diagonal entry at state `0` is positive for `n = 0, 2, 3, 4, …`
  and zero only at `n = 1`, matching `apChain_spectrum` (spectrum `⟨2,3⟩`) and
  `apChain_aperiodic` (no `d ≥ 2` divides both `2` and `3`).
* **Primitivity threshold.** The first `n` after which *every* entry stays positive is
  `n = 5`, so `apChain_primitive` is witnessed with exponent `5`.  For a `3`-state chain
  Wielandt's bound is `3² − 2·3 + 2 = 5`, so this smallest loopless example is already
  *extremal*: it is the computational evidence behind Future Direction 1.

## 7. Cycle 8: primitivity exponent of the nearest-neighbour chain

Exact rational computation (in Lean, over `ℚ`, by iterating the support matrix
`A n i j = 1` iff `|i − j| ≤ 1`) of the least `k` for which **every** entry of the `k`-th
power is strictly positive:

| `n` (states) | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| least fully positive power | 0 | 1 | 2 | 3 | 4 | 5 | 6 |

The pattern is `n − 1` throughout, which is exactly the two-sided statement now proved as
`nbrChain_exponent_eq` in `Catalog/Probability/MarkovExponentBounds.lean`: the upper
bound comes from the diameter principle plus loop padding, and the matching lower bound
from the speed limit "one step moves the index by at most one".  So the exponent
`card S − 1` of `stepPow_pos_of_lazy_card_le` cannot be improved for any number of
states.

## 8. Cycle 9: the diamond gfp on the absorbing chain

The two-state absorbing chain `absorbChain` (`P i 1 = 1`, `P i 0 = 0`) has support
pattern

```
n = 0   + .        n ≥ 1   . +
        . +                . +
```

so state `0` never returns to itself (its diagonal entry vanishes for every `n ≥ 1`)
while state `1` returns at every step.  Yet `0` has a successor inside `{0, 1}` at every
stage, so it belongs to every post-fixed set of the diamond operator.  This is the
numerical shape of the counterexample proved in
`Catalog/Probability/MarkovRecurrenceFixedPoint.lean`
(`absorb_zero_not_recurrent`, `absorb_zero_mem_gfpDia`, `gfpDia_ne_recurrent`): the
greatest fixed point of the diamond is the set of states *reaching* recurrence, strictly
larger than the recurrent set.
