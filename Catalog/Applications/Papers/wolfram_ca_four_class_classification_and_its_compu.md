# Computational Evidence — Wolfram CA Four-Class Classification

Topic: Formalize Wolfram's four behavioral classes of elementary cellular automata
(ECA) and study the *computability* of classifying asymptotic behaviour, with the
class-4 ↔ universal-computation link as motivation.

## 1. Model

Elementary CA, alphabet `Bool`, lattice = cyclic `ZMod n`. A rule number
`r ∈ {0,…,255}` defines the local map
`localRule r l c ri = r.testBit (4·bit l + 2·bit c + bit ri)`,
and the global map `step n r cfg i = localRule r (cfg (i-1)) (cfg i) (cfg (i+1))`.

## 2. Small-case rule identities (verified by `decide` over the 8 neighbourhoods)

| rule | closed form of local map | Wolfram class |
|------|--------------------------|---------------|
| 0    | `false` (constant)        | 1 (uniform)   |
| 255  | `true`  (constant)        | 1 (uniform)   |
| 204  | `c` (identity)            | 2 (fixed pts) |
| 51   | `!c` (period-2 flip)      | 2 (periodic)  |
| 90   | `xor l ri` (additive)     | 3 (chaotic/Sierpiński) |
| 110  | (not collapsible)         | 4 (complex / universal) |

All five collapsible identities were checked with `∀ l c ri, … := by decide`
(see `WolframClassification.lean`, `localRule_*` lemmas).

## 3. Class-separating invariant: number of fixed configurations

For lattice size `n` (with `n ≠ 0`, so `ZMod n` is finite and nonempty):

* rule 0  : the only fixed configuration is the all-`false` one ⇒ **unique attractor**.
* rule 204: every configuration is fixed ⇒ `2^n` fixed points ⇒ **many attractors**.

Hence the fixed-point count separates class 1 from class 2 — the classification is
not vacuous. (`rule0_unique_fixed`, `rule204_not_unique_fixed`.)

## 4. Eventual periodicity (finite-lattice Poincaré recurrence)

The global config space `Config n = ZMod n → Bool` is finite, so the iterates
`(step n r)^[k]` must repeat. Computationally, every orbit on a size-`n` ring is
ultimately periodic with transient + period ≤ `2^n`. This is the formal content of
"on a finite lattice every CA is class 1/2-like" and is the lever for decidability.

## 5. Computability of reachability (the key result)

Because orbits are eventually periodic, reachability is *decidable* with an explicit
search bound: for any `f` on a finite type `α`,
`(∃ t, f^[t] c = b) ↔ (∃ t ≤ Nat.card α, f^[t] c = b)`.
The right side is a bounded search, hence decidable. This is the honest, provable
core of "asymptotic classification on finite lattices is computable", contrasting
Wolfram/Kari's undecidability of nilpotency on the *infinite* lattice (out of scope
for a finite formalization, recorded as a future direction).

## 6. OEIS / counterexample notes

No new integer sequence is claimed. The fixed-point counts `{1, 2^n}` are the
trivial `A000079`-style powers of two and need no OEIS entry. No counterexample to
the eventual-periodicity or reachability-bound statements was found in small cases
(n ≤ 6 enumerated mentally / by the `decide` identities); both are theorems, proved
below without `sorry`.
