# Computational Evidence

The claims here are finite and decidable, so "computation" is exact rather than
statistical. The concrete multiverse has **3 universes** (`L`, `cohen`,
`measurable`) and **4 statements** (`ZFC`, `CH`, `VeqL`, `LargeCardinal`), giving a
`4 × 3` truth table.

## 1. The truth table `choldsB`

| statement \\ universe | L | cohen | measurable |
|-----------------------|---|-------|------------|
| ZFC                   | T | T     | T          |
| CH                    | T | F     | T          |
| V=L                   | T | F     | F          |
| LargeCardinal         | F | F     | T          |

Row-wise reading gives the multiverse status of each statement:

| statement     | ∃ (possible) | ∀ (multiverse-true) | independent? |
|---------------|:------------:|:-------------------:|:------------:|
| ZFC           | yes          | **yes**             | no (determined) |
| CH            | yes          | no                  | **yes**      |
| V=L           | yes          | no                  | **yes**      |
| LargeCardinal | yes          | no                  | **yes**      |

This directly witnesses: ZFC is multiverse-true; CH, V=L and large cardinals are
each independent (true somewhere, false somewhere), hence undetermined.

## 2. Tropical signatures (the connector)

Encode `true ↦ 1 = trop 0`, `false ↦ 0 = trop ⊤` and read off the two big
operators over the 3 universes (tropical `∑` = `min`, tropical `∏` = `+`):

| statement | tropical Σ (= `min`) | tropical Π (= `+`) |
|-----------|:--------------------:|:------------------:|
| ZFC       | `1`                  | `1`                |
| CH        | `1`                  | `≠ 1`              |

* `Σ = 1` reproduces `∃ u, holds u s` (possibility).
* `Π = 1` reproduces `∀ u, holds u s` (multiverse truth).

So independence of CH is the *mismatch* `Σ = 1` but `Π ≠ 1`; a determined truth
(ZFC) has `Σ = Π = 1`. These are exactly `ch_tropical_signature` and
`zfc_tropical_signature`.

## 3. Counterexample hunt

* Searched for a universe with both `V=L` and `LargeCardinal`: none exists
  (theorem `veqL_large_cardinal_incompatible`), matching the classical fact that
  `V=L` refutes measurable cardinals.
* Searched for a forcing extension flipping `ZFC`: none exists
  (`zfc_not_forcingClosed`), since ZFC holds in every universe.
* Checked the forcing-flip map for CH on all 3 universes (L↦cohen, cohen↦L,
  measurable↦cohen): every universe has an extension with opposite CH value
  (`ch_forcingClosed`).

No counterexample to any stated theorem was found; all finite checks are
discharged in Lean by `decide`/`simp`, so the evidence is a proof, not a sample.

## 4. OEIS

No integer sequence arises; the objects are a fixed finite truth table, so an
OEIS search is not applicable.
