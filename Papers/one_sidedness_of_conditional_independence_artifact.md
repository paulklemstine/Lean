# Computational evidence

All numbers below were **computed inside Lean and are backed by sorry-free
proofs** in `Catalog/Novelty/ConditionalArtifactWitness.lean`; nothing here
comes from an unchecked scratch calculation.  Entropies are in bits, weights
are unnormalised (mass is carried explicitly by the `nlp(mass)` term), and

```
CMI p = ∑_z [ H(p_{X,z}) + H(p_{Y,z}) − H(p_z) − nlp(mass p_z) ].
```

## 1. The two test populations (`Bool × Bool × Bool`)

| name    | weight                                   | support |
|---------|------------------------------------------|---------|
| `xorW`  | `1/4` on `{(x,y,z) : z = x xor y}`       | 4 cells |
| `copyW` | `1/2` on `{(x,y,z) : x = y = z}`         | 2 cells |

Hand computation for `xorW`, slice `z`: mass `1/2`, two atoms of `1/4`;
`H(marg₁)=H(marg₂)=1`, `H(slice)=1`, `nlp(1/2)=1/2`, so each slice contributes
`1 + 1 − 1 − 1/2 = 1/2` and `CMI = 1`.  Lean confirms:
`xor_CMI_eq_one : CMI xorW = 1`.

## 2. Readings table (every entry is a proved theorem)

| quantity                                | `xorW` | `copyW` | theorem |
|-----------------------------------------|--------|---------|---------|
| `I(X;Y)` (single-dial, `Z` summed out)  | `0`    | `1`     | `xor_MI_eq_zero`, `copy_MI_eq_one` |
| `I(X;Y|Z)` (conditional)                | `1`    | `0`     | `xor_CMI_eq_one`, `copy_CMI_eq_zero` |
| `I(X;(Y,Z))` (pair channel)             | `1`    | `1`     | `xor_MI_pair_eq_one`, `copy_MI_pair_eq_one` |
| `I(X;Z)` (context channel)              | `0`    | `1`     | `xor_MI_context_eq_zero`, `copy_MI_context_eq_one` |
| `I(f(X);Y|Z)`, `f ≡ true` (dial merge)  | `0`    | –       | `xor_CMI_merge_eq_zero` |
| `I(X;Y|g(Z))`, `g ≡ true` (context merge)| `0`   | `1`     | `xor_CMI_contextMerge_eq_zero`, `copy_CMI_contextMerge_eq_one` |
| label entropy destroyed by the dial merge | `1`  | –       | `xor_labelLoss_total_eq_one` |

## 3. What the table shows

* **Chain-rule check** (`chain_rule_numerics`): `1 = 1 − 0` and `0 = 1 − 1`.
  The four readings were each computed separately from the definitions, so this
  is an independent numerical confirmation of `CMI_eq_MI_sub_MI`.
* **One-sidedness, negative half**: the dial merge turns `1` into `0`.  A
  reported conditional independence can be pure artifact.
* **One-sidedness, positive half** is a theorem, not a sample: no merge of any
  population can raise the reading (`CMI_pushFst3_le`).
* **Context merges are two-sided**: `1 → 0` on `xorW` but `0 → 1` on `copyW`.
  So the sign guarantee is specific to the dial axis.
* **Error bar sharpness**: the dial merge destroys exactly `1` bit of label
  entropy and exactly `1` bit of conditional information, so the bound
  `CMI_loss_le_label_entropy_loss` is attained (`error_bar_is_tight`).

## 3b. Criterion data

The detection criterion of `StrictLabelDeficit` was checked on the same witness
and *fires*: in the context `z = true` the single fiber of the collapsing merge
has the cell `(x,y) = (true,true)` equal to `0` while its rank-one prediction
from row and column sums is `1/4 · 1/4 / (1/2) = 1/8`
(`xor_nonproduct_cell`).  Feeding this one cell into
`CMI_lt_of_nonproduct_fiber` reproves the strict drop
(`xor_strict_from_nonproduct`) *without* evaluating either conditional reading —
an independent route to the same conclusion.  The corresponding deficit gap is
`0 < 1/2` (`xor_fiber_gap`).

## 4. Counterexample hunt

The universal claim under test is `I(f(X);Y|Z) ≤ I(X;Y|Z)`.  Two families were
probed for violations before the general proof was attempted:

* deterministic-response populations (`copyW` and its relabellings) — no
  violation; merges collapse the reading to `0`;
* parity populations (`xorW`) — no violation; merges collapse the reading to
  `0` even though the unconditional reading is already `0`.

No counterexample exists: the inequality is now proved in general
(`ConditionalLabelDPI.CMI_pushFst3_le`).  Violations *were* found for the two
neighbouring claims, and both are recorded as theorems rather than folklore:
merging the conditioning variable (`context_merge_is_two_sided`) and comparing
conditional with unconditional readings
(`conditional_and_unconditional_independent`).

No OEIS sequence arises: the objects here are real-valued information
functionals, not integer sequences.
