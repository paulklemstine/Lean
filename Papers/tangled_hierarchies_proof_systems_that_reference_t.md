# Computational Evidence — Tangled Hierarchies and Internal Soundness

All computations below were run in Lean 4 (`#eval`, kernel-evaluated, no external
tooling).  They were used *before* and *during* formalisation to test the conjectures
that became the theorems of `Catalog/Logic/ProvabilityLogic/`.

## 1. Exhaustive check: internal soundness = self-loop (512 frames)

Every relation on a 3-element world set (`2^9 = 512` frames), every Boolean valuation
of one propositional variable (`2^3 = 8`), every world:

```lean
def atomicSound (R : Fin 3 → Fin 3 → Bool) (w : Fin 3) : Bool :=
  vals.all (fun V => (decide (∀ v, R w v = true → V v = true)) → V w)

#eval rels.foldl (fun acc R =>
  acc + ((List.finRange 3).filter (fun w => atomicSound R w != R w w)).length) 0
```

| quantity | value |
|---|---|
| (frame, world) pairs tested | 512 × 3 = 1536 |
| mismatches between "atomically sound at `w`" and `R w w` | **0** |
| sound (frame, world) pairs | 768 = 3 · 256 (exactly the reflexive pairs) |

This is the finite shadow of `uniformlySound_iff_selfLoop` /
`atomicSound_iff_uniformlySound`, and it also confirms that *one* propositional
variable is enough — no richer language is needed to force the tangle.

## 2. Counterexample hunt: a world that is both sound and Löbian

Same 1536 (frame, world) pairs, checking the Löb instance `□(□p→p) → □p` for every
Boolean valuation:

| quantity | value |
|---|---|
| worlds validating both the Löb instance and reflection | **0** |
| worlds validating the Löb instance while reflexive | **0** |
| Löbian worlds | 249 |
| irreflexive worlds | 768 |
| irreflexive worlds where the Löb instance nevertheless *fails* | 519 |

No counterexample to `no_sound_loeb_world` was found, as expected.  The last row is
informative in the other direction: Löb-validity at a world is *strictly stronger*
than irreflexivity of that world (a Löbian world must also avoid reflexive
successors), so the file states only the implication `loebAt_irrefl` and does not
claim a converse.

## 3. The degree spectrum of reflection (cycle frames)

For the cycle frame on `ZMod n`, the degrees `k` for which `□ᵏφ → φ` is valid are
exactly the multiples of `n`:

```
n = 5 : k = 0,5,10 valid; 1,2,3,4,6,7,8,9 invalid
n = 3 : k = 0,3,6   valid; 1,2,4,5        invalid
```

This is the computational form of `cycleFrame_iterSound_self` and
`cycleFrame_not_iterSound_lt`, and it is what suggested the general theorem
`iterSound_iff_cycle` ("degree `n` reflection = an `n`-cycle").

## 4. The reflection tower grows one loop per stage

Iterating the soundness extension on the 4-world chain `0 → 1 → 2 → 3`:

| stages `n` | worlds | self-loops |
|---|---|---|
| 0 | 4 | 0 |
| 1 | 5 | 1 |
| 2 | 6 | 2 |
| 3 | 7 | 3 |
| 4 | 8 | 4 |
| 5 | 9 | 5 |

Exactly the behaviour proved in `iterExt_selfLoop_ncard` / `iterExt_sound_ncard`, and
the reason to expect `iterExt_has_unsound_world` (worlds outgrow loops by the constant
size of the base frame).

## 5. OEIS

The only sequences arising are `0,1,2,3,4,…` (loops per stage, A001477) and
`4,5,6,7,…` (worlds per stage); no interesting new sequence is produced, so no OEIS
identification is claimed.

## Scope of this evidence

Items 1, 2 and 4 are exhaustive finite computations; item 3 is an exhaustive check for
small `n`.  They are *evidence*, not proof: the theorems in
`Catalog/Logic/ProvabilityLogic/TangledSoundness.lean`,
`SoundnessTopology.lean`, `IteratedReflection.lean` and `SelfSoundSystems.lean` are the
verified statements, and they are proved for arbitrary (possibly infinite) frames with
no `sorry` and only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.
