# Computational Evidence — Periodic Table of Finite Groups (cycle v16)

Concise numerical sanity checks performed before formalization. All claims below
were subsequently turned into machine-checked Lean theorems (0 `sorry`, axioms
`propext`/`Classical.choice`/`Quot.sound` only).

## 1. The composition-factor mass law (Conjecture 1)

For a chain `⊥ = H₀ ≤ H₁ ≤ … ≤ Hₙ = ⊤`, the order is the product of the relative
indices `[Hᵢ₊₁ : Hᵢ]`. Small cases:

| Group        | sample series (factor orders)     | product | `|G|` |
|--------------|-----------------------------------|---------|-------|
| `C₆`         | `1 ◁ C₂ ◁ C₆`  → `(2, 3)`         | 6       | 6     |
| `C₆`         | `1 ◁ C₃ ◁ C₆`  → `(3, 2)`         | 6       | 6     |
| `S₃`         | `1 ◁ A₃ ◁ S₃`  → `(3, 2)`         | 6       | 6     |
| `C₂ × C₂`    | `1 ◁ C₂ ◁ V₄`  → `(2, 2)`         | 4       | 4     |

The product is invariant under reordering of factors (different series, same
multiset) — this is exactly `sameFactorMultiset_imp_sameCard`. No counterexample is
possible: the telescoping `relIndex_mul_relIndex` makes the identity hold for *every*
monotone chain, proven in `relIndex_prod_telescope`.

## 2. Valence of the simple block (Conjecture 2)

Minimal normal subgroup counts (`valence`):

| Group        | minimal normal subgroups | valence |
|--------------|--------------------------|---------|
| `A₅` (simple)| `{⊤}`                    | 1       |
| `Cₚ` (simple)| `{⊤}`                    | 1       |
| `C₆` (nilp.) | `{C₂-part, C₃-part}`      | 2 = ω(6)|
| `C₁₂`        | `{C₂..., C₃...}`         | 2 = ω(12)|

The simple-group entry (`valence = 1`) is proved (`simpleGroup_valence_one`); the
nilpotent column `valence = ω(|G|)` is recorded as Future Direction 2.

## 3. Solvability charge & threshold (Conjectures 3, 4)

* `isSolvable_prod_iff` checked on `S₃ × C₂` (solvable), `A₅ × C₂` (not solvable).
* Counterexample hunt for Conjecture 3 ("uniqueness"): the formation
  `{G : factors ⊆ {cyclic, A₅}}` is sub/quotient/product-closed, false on `A₆`, true
  on the non-solvable `A₅`. **Counterexample found** ⇒ Conjecture 3 is false as
  stated (see Lab Notes in `SolvabilityCharge.lean`).
* Threshold: smallest non-solvable group order, from the group catalogue, is `60`
  (`A₅`); all orders `1..59` are solvable. The upper witness `|A₅| = 60` and
  `¬IsSolvable A₅` are proved; the lower bound `< 60 ⇒ solvable` is Future
  Direction 4.

## Note on method

The mass law and valence claims are universally quantified over infinite families,
so finite enumeration only provides spot checks; the decisive evidence is the Lean
proofs themselves. The non-commutativity witness for `A₅` (`(0 1 2)` vs `(0 1 3)`)
was confirmed by `decide` on `Equiv.Perm (Fin 5)` before being embedded into the
structured proof of `alternatingGroup_fin5_noncomm`.
