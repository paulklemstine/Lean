# Computational Evidence: Time-Travel Causal Consistency

The formalization reduces each informal claim about closed timelike curves (CTCs)
to a statement about a *loop map* `evolve : S → S` — the net effect of one traversal
of the loop on the world-state — where self-consistency (Novikov) means a fixed
point `evolve s = s`. Below is the small-case evidence that guided the theorem
statements.

## 1. Novikov ⇔ closed timelike history (small cases)

Model a length-`n` loop by causal steps `steps 0, …, steps (n-1)` and set
`evolve = traverse steps n` (the `n`-fold composition). A *closed timelike history*
is an assignment `h 0, h 1, …` with `h (k+1) = steps k (h k)` and `h n = h 0`.

* `n = 1`, `steps 0 = id` on `Bool`: fixed points are both `true`, `false`; each
  gives a closed history of length 1. ✔
* `n = 2`, `steps 0 = not`, `steps 1 = not` on `Bool`: `evolve = not ∘ not = id`,
  so every state is a fixed point; closed histories `true,false,true` and
  `false,true,false` close up. ✔
* `n = 1`, `steps 0 = not`: `evolve = not`, **no** fixed point, **no** closed
  history — matches the grandfather case below.

The equivalence held on every finite case checked, motivating the general theorem
`selfConsistent_iff_closedHistory`.

## 2. Grandfather paradox (fixed-point hunt)

The action "kill your ancestor" toggles the ancestor's existence, i.e. `not` on
`{alive, dead}`.

| s      | not s  | not s = s ? |
|--------|--------|-------------|
| alive  | dead   | no          |
| dead   | alive  | no          |

No fixed point exists, so no self-consistent single-timeline history exists:
`grandfather_not_selfConsistent`.

## 3. Positive consistency guarantees (counterexample hunt)

* **Monotone / complete lattice.** Any monotone `f` on `Bool` (as a lattice
  `false ≤ true`): `id`, `const true`, `const false`, and `∧`/`∨`-with-constant
  all have fixed points. No monotone self-map without a fixed point was found —
  consistent with Knaster–Tarski (`monotone_selfConsistent`).
* **Continuous on `[0,1]`.** Sampling `f x = x²`, `1-x`, `x/2 + 1/4`,
  `cos x` (rescaled): each crosses the diagonal `y = x` in `[0,1]`. The map
  `x ↦ x + 0.1` fails to be a self-map of `[0,1]` (leaves the interval), so it is
  correctly excluded by the `MapsTo` hypothesis. Matches the 1-D Brouwer / IVT
  theorem `continuous_selfConsistent`.
* **Involution, odd size.** Fixed-point-free involutions require even size: on
  `card = 1,3,5` no fixed-point-free involution exists (a brute check over all
  involutions of small `Fin n` confirms every involution on odd `n` fixes some
  point), while on `card = 2` the swap `not` is fixed-point-free. Matches
  `involutive_odd_selfConsistent`.

## 4. Branching (many-worlds)

Branching step `branch a (s, n) = (a s, n+1)`. Starting from `(alive, 0)` with the
grandfather action `not`:

```
(alive,0) → (dead,1) → (alive,2) → (dead,3) → …
```

The branch index strictly increases, so the multiverse state never repeats
(`branch a` has no fixed point), yet the sequence is a totally consistent history:
the traveller kills the ancestor in branch 1 and lives on in branch 2. This holds
for *every* action, including paradoxical ones, matching
`branching_resolves_paradox`.

## OEIS

No integer sequence central to the claims; the branch index is simply `0,1,2,3,…`
(A001477). No further OEIS lookup was warranted.

## Summary

No counterexample to any stated theorem was found in the sampled finite/continuous
cases; the paradoxical cases (grandfather) behaved exactly as the impossibility
theorems predict, and the branching model resolved them as predicted.
