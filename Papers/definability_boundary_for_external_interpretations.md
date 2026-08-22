# Computational Evidence — Definability Boundary for External Interpretations

All numbers below were produced by Lean `#eval` computations in the same
toolchain as the formal files (Lean 4.28.0 / Mathlib).  They are *exploratory
computations*, not proofs; the theorems they motivated are proved (sorry-free)
in `Catalog/Applications/ExternalInterpretation*.lean`.

## 1. Counting recoverable interpretations: `2 ^ (#orbits)`

Harness (Boolean interpretations invariant under a list of generating
permutations of `Fin n`, and the corresponding orbit count):

```lean
def countInv (n : ℕ) (gs : List (Fin n → Fin n)) : ℕ :=
  ((Finset.univ : Finset (Fin n → Bool)).filter
    (fun f => gs.all (fun g => (List.finRange n).all (fun x => f (g x) = f x)))).card
```

| model | generators | `#orbits` | recoverable Boolean interpretations | `2 ^ #orbits` |
|---|---|---|---|---|
| `Fin 4` | `(0 1 2 3)` | 1 | 2 | 2 |
| `Fin 4` | `(0 1)(2 3)` | 2 | 4 | 4 |
| `Fin 6` | `(0 1)`, `(2 3 4)` | 3 | 8 | 8 |

This is exactly the content of `card_orbitConstant_eq_pow`
(`|V| ^ #orbits` recoverable interpretations).

## 2. Burnside cross-check

For the cyclic group `C₄ = ⟨(0 1 2 3)⟩` acting on `Fin 4`:

```
Σ_{g ∈ C₄} |Fix g| = 4 + 0 + 0 + 0 = 4 = (#orbits) · |G| = 1 · 4
recoverable Boolean interpretations = 2 = 2 ^ 1
```

so `2 ^ (Σ_g |Fix g|) = 2⁴ = 16 = 2⁴ = (recoverable count)^{|G|} = 2⁴`,
matching `burnside_recoverable_count`.

## 3. Kernels of tuples (logical invariance)

The number of distinct *kernels* (equality patterns) of tuples `Fin k → Fin m`:

| `k \ m` | 2 | 3 | 4 |
|---|---|---|---|
| 1 | 1 | 1 | 1 |
| 2 | 2 | 2 | 2 |
| 3 | 4 | 5 | 5 |
| 4 | 8 | 14 | 15 |

The `m ≥ k` diagonal `1, 2, 5, 15` is the Bell number sequence
[OEIS A000110](https://oeis.org/A000110) (set partitions of a `k`-element set);
truncated columns count partitions with at most `m` blocks (e.g. `k=4, m=2`:
`1 + 7 = 8`; `k=4, m=3`: `1 + 7 + 6 = 14`).

## 4. Direct test of the logical-invariance theorem

Counting `Equiv.Perm (Fin m)`-invariant Boolean interpretations of `k`-tuples:

```lean
def countInvTuple (k m : ℕ) : ℕ :=
  ((Finset.univ : Finset ((Fin k → Fin m) → Bool)).filter
    (fun I => ∀ s : Equiv.Perm (Fin m), ∀ f : Fin k → Fin m, I (fun i => s (f i)) = I f)).card
```

| `k` | `m` | invariant Boolean interpretations | `2 ^ (#kernels)` |
|---|---|---|---|
| 1 | 3 | 2 | `2^1 = 2` |
| 2 | 2 | 4 | `2^2 = 4` |
| 2 | 3 | 4 | `2^2 = 4` |
| 3 | 2 | 16 | `2^4 = 16` |

Every entry agrees, i.e. the recoverable tuple interpretations are exactly the
functions of the kernel — the statement proved as
`perm_tuple_recoverable_iff_kernel` (proved for an arbitrary, possibly infinite,
carrier and any finite arity).  For an *infinite* arity the pattern breaks:
surjectivity of a sequence separates the two injective sequences `n ↦ 2n` and
`n ↦ n`, which share a kernel
(`kernel_classification_fails_for_infinite_arity`).

## 5. Counterexample hunt

* **Orbit constancy ⇒ definability?**  Searched the finite/cofinite language on
  `ℕ` with the trivial automorphism group: parity is orbit-constant, and its
  fibre `{n | Even n}` is infinite with infinite complement, so it is undefinable.
  Formalised as `parity_not_definable` — the universal form of the conjecture
  ("recoverable ⟺ orbit-constant ∧ definable *in a bounded language*") is
  therefore **false** for infinite models.
* **Is the counting enrichment needed in the finite case?**  Yes: with only the
  trivial invariant language `{∅, M}` no non-constant interpretation is
  definable, while the counting language defines every orbit indicator
  (`counting_strictly_stronger`).
* **Graph test bed.**  On the path `0—1—2` the automorphism group was computed by
  exhaustive search over `Equiv.Perm (Fin 3)` (6 permutations): it is
  `{id, (0 2)}`.  Degrees `(1,2,1)` are orbit-constant; vertex labels are not
  (`autGroup_P3_eq`, `P3_recoverable_iff`, `P3_labels_not_recoverable`).
