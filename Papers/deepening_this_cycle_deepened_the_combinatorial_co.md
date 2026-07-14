# Computational Evidence — The Modal Logic of Forcing (S4.2)

This deepening adds a Kripke-semantic **modal logic of forcing** on top of the
multiverse combinatorial core (`MultiverseSetTheory.lean`). The central claim is a
*soundness* statement: forcing frames (reflexive, transitive, directed
accessibility relations) validate exactly the modal axioms of **S4.2** — `K`, `T`,
`4`, `.2` — and, crucially, **not** the `S5` axiom `B`.

Because the theorems are universally quantified soundness/failure statements over
Kripke frames, the decisive evidence is finite frame checking rather than large
numerical search. We record the small frames used and their behaviour.

## 1. Frame conditions vs. axioms (semantic dictionary)

| Modal axiom | Schema                    | Frame condition needed |
|-------------|---------------------------|------------------------|
| K           | □(p→q) → (□p→□q)          | none                   |
| Nec         | ⊢p ⟹ ⊢□p                 | none                   |
| T           | □p → p                    | reflexive              |
| 4           | □p → □□p                  | transitive             |
| .2          | ◇□p → □◇p                 | directed (confluent)   |
| B (S5 only) | p → □◇p                   | symmetric              |

Forcing extension is reflexive (force with the trivial poset), transitive
(iterate forcing) and directed (product/amalgamation of two forcings), but **not**
symmetric (you cannot force back to a strictly smaller ground model). This is
exactly the S4.2 fingerprint, matching the Hamkins–Löwe theorem.

## 2. Small-frame check for `.2` (directedness)

Two-generic-extension diamond: at ground `w`, suppose `◇□p` witnessed by `v₁` with
`□p` true. For any accessible `v₂`, directedness gives a common extension `u ⊒ v₁,
v₂`; since `□p` at `v₁` forces `p` at `u`, we get `◇p` at `v₂`. Checked by hand on
the 3-world frame `w → v₁, w → v₂, v₁ → u, v₂ → u`; the Lean proof `sound_Two`
generalises this to arbitrary directed frames.

## 3. Counterexample hunt for `B` (S5)

We searched for the smallest reflexive-transitive-directed frame refuting
`B : p → □◇p`. The minimal witness is the **2-world sink frame**:

```
worlds:  wT (atom = true),  wF (atom = false)
acc:     wT → wT,  wT → wF,  wF → wF        (wF is a sink)
```

- reflexive ✓, transitive ✓, directed ✓ (wF is a common upper bound of everything).
- `p` (the atom) holds at `wT`.
- `□◇p` at `wT` requires `◇p` at every accessible world, including `wF`.
- from `wF` the only accessible world is `wF`, where `p` is false ⇒ `◇p` fails.
- therefore `B` fails at `wT`.

This is formalised as `B_fails` (frame `sinkFrame`, relation `sinkR`). No smaller
reflexive frame works: a 1-world frame is symmetric, hence validates `B`.

## 4. Contingency of CH under forcing (concrete instance)

Over the 3-atom multiverse `{CH, V=L, Meas}` (2³ = 8 worlds), in the
flip-reachability forcing frame:

- `◇CH` at Gödel's `L`: witnessed by `L` itself (CH true there).
- `◇¬CH` at `L`: witnessed by the Cohen world, reachable by flipping `{CH, V=L}`.
- hence `◇CH ∧ ◇¬CH` (modal contingency) and `¬□CH`.

This is `CH_contingent` / `CH_not_necessary`, the modal reading of the classical
independence of the Continuum Hypothesis.

## Conclusion

All evidence is finite and exhaustive at the frame level; the Lean file promotes
these checks to fully general theorems with machine-verified proofs (0 sorries,
only `propext`/`Classical.choice`/`Quot.sound`).
