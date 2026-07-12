# Computational Evidence — Clausius/second-law ledger for proof pipelines

We study a **proof pipeline** on a fixed finite register `α`: a list of steps
`fs = [f₁, …, f_k]` with `fᵢ : α → α`, applied in temporal order.  The composite is
`compose fs = f_k ∘ … ∘ f₁`, and the total erased information is
`totalErased fs = log₂(card α) − log₂(|image (compose fs)|)`.

## 1. Small-case calculations

Take `α = Fin 4` (a 2-bit register), so `log₂(card α) = 2`.

| pipeline `fs` (as maps `Fin 4 → Fin 4`)            | image size | totalErased |
|----------------------------------------------------|-----------:|------------:|
| `[]` (identity)                                    | 4          | 0           |
| `[id]`                                             | 4          | 0           |
| `[swap 0 1]` (a bijection)                         | 4          | 0           |
| `[x ↦ x/2]` (2-to-1 collapse to `{0,1}`)           | 2          | 1           |
| `[x ↦ x/2, x ↦ 0]` (then constant)                 | 1          | 2           |
| `[x ↦ 0]` (constant)                               | 1          | 2           |

Observations matching the theory:

* Reversible steps (`id`, `swap`) contribute `0` — consistent with
  `totalErased_zero_of_forall_injective`.
* Appending the constant map after the 2-to-1 collapse takes total erasure from `1` to `2`;
  the *increment* is `1 = log₂ 2 − log₂ 1`, exactly `stepDrop`.  This is the ledger identity
  `totalErased_append_singleton`.
* Total erasure is nondecreasing as the list grows (`0 ≤ 0 ≤ 1 ≤ 2`), confirming
  `totalErased_mono_prefix`.

## 2. Clausius decomposition (per-step productions)

For the pipeline `[x ↦ x/2, x ↦ 0]` on `Fin 4`:

* Step 1 (`x ↦ x/2`): image drops `4 → 2`, production `log₂ 4 − log₂ 2 = 1`.
* Step 2 (`x ↦ 0`): image drops `2 → 1`, production `log₂ 2 − log₂ 1 = 1`.
* Sum of productions `= 1 + 1 = 2 = totalErased`. ✔

This is the discrete Clausius inequality `clausius`: total dissipation equals a sum of
nonnegative per-step productions.

## 3. Counterexample hunt — is erasure additive over composition?

Direct search over constant maps on `Fin 2` (already recorded in the catalog's contrarian
file) shows erasure is **sub-additive, not additive**: two 1-bit-erasing constants compose to
erase only `1` bit.  Our `stepDrop` correctly measures the *marginal* contribution
(here `0` for the second constant, since the image is already a singleton), so the summed
`clausius` decomposition uses marginal — not standalone — productions.  No counterexample to
the monotone/Clausius statements was found.

## 4. Creation ledger sanity check

For `f : Fin 4 → Fin 2`, Bennett's dilation `x ↦ (x, f x) : Fin 4 → Fin 4 × Fin 2` is
injective, so it erases `0` bits.  Its ancilla cost is
`createdBits 4 8 = log₂ 8 − log₂ 4 = 3 − 2 = 1 = log₂(card (Fin 2))`, matching
`bennett_tradeoff`.

## Conclusion

The computational landscape is fully consistent with the formalized theorems: erasure is
monotone along a pipeline, decomposes into nonnegative per-step productions summing to the
total, vanishes exactly for reversible pipelines, and trades cleanly against creation in
Bennett's reversible dilation.
