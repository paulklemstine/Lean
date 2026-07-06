# Computational Evidence — Co-Wellfounded Chains and Direct Sums

Focused evidence for the three formalized results, obtained by evaluating small
order models.

## 1. Small-case models for Theorem 1 (`chain_finite_of_wf_cowf`)

A chain is classified by whether it admits an infinite ascending / descending
sequence. "coWF" = co-wellfounded = no infinite ascending sequence; "WF" = well
founded = no infinite descending sequence.

| chain        | WF? | coWF? | finite? | consistent with T1 |
|--------------|-----|-------|---------|--------------------|
| `Fin 0..n`   | yes | yes   | yes     | ✅ (WF∧coWF ⇒ finite) |
| `ℕ`          | yes | no    | no      | ✅ (coWF fails)      |
| `ℕᵒᵈ` (`ω*`) | no  | yes   | no      | ✅ (WF fails)        |
| `ℤ`          | no  | no    | no      | ✅                   |
| `ω + ω*`     | no  | no    | no      | ✅                   |

No infinite chain in the sample is simultaneously WF and coWF: every infinite
linear order exhibits an infinite monotone sequence in at least one direction,
exactly as the Erdős–Szekeres dichotomy predicts.

## 2. Witness for Theorem 2 (`infinite_cowf_chain_has_descending`)

Take `α = ℕᵒᵈ` (`ω*`). It is infinite and co-wellfounded (ascending chains in
`ℕᵒᵈ` correspond to descending chains in `ℕ`, which terminate). The explicit
descending sequence is `f n = (n : ℕ)` viewed in `ℕᵒᵈ`:
`f 0 > f 1 > f 2 > …`, i.e. a copy of `ω*`. This confirms an infinite
co-wellfounded chain always carries an infinite strictly descending sequence.

## 3. Direct sums for Theorem 3 (`directSum_not_isFAC`)

For `β : ι → Poset`, the direct sum `Σ i, β i` compares two points only inside a
common summand.

| index `ι` | summands            | largest antichain | FAC? |
|-----------|---------------------|-------------------|------|
| `Fin 1`   | `ℕ`                 | 1                 | yes  |
| `Fin 2`   | `ℕ, ℕ`              | 2                 | yes  |
| `Fin k`   | any nonempty        | k                 | yes  |
| `ℕ`       | `Unit` each         | ∞ (whole space)   | **no** |
| `ℕ`       | `ℕ` each            | ∞ (`{⟨n,0⟩}`)      | **no** |

The transition to an infinite index destroys FAC: one point per summand is an
infinite antichain. Finite direct sums stay FAC, so the break is precisely at
`|ι| ≥ ω`.

## 4. Counterexample hunt

* "coWF ⇒ WF for chains": refuted by `ω*` (coWF, not WF).
* "every FAC chain is finite": refuted by `ℕ` (a chain has no 2-element
  antichain, so it is FAC, yet infinite).
* "direct sum of FAC posets is FAC": refuted by countably many copies of `Unit`.

No counterexample was found to any of the three formalized theorems.

## 5. Relation to sequences / OEIS

The only counting quantity appearing is the maximal antichain size of a finite
direct sum of `k` nonempty posets, which is simply `k` (OEIS A000027, the natural
numbers) — a sanity check rather than a discovery.
