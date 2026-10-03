# The Catalog cannot currently be built at all — 2026-09-27

**Finding, not a claim about any theorem.** Recorded because the round-45 S9 work
wanted to machine-check its counting identity in Lean and could not, and because
anyone else attempting a formalization here will hit the same wall.

## Symptom

`lake build` in `/home/raver1975/lean/Catalog` fails before compiling a single Catalog
file. Even an existing, previously-working file (`Cryptography.FactoringBarriers.NegativeResults`)
fails. The error is in **Mathlib's own lakefile**:

```
error: .lake/packages/mathlib/lakefile.lean:3:5: unknown namespace `Lake`
error: .lake/packages/mathlib/lakefile.lean:9:0: unexpected identifier; expected command
   ... (14 further errors)
error: package configuration has errors
```

Line 3 of that file is `open Lake DSL`, immediately after `import Lake` on line 1.
The file is unmodified and correct.

## Diagnosis

* The checkout is **consistent**: `git status` clean; `lake-manifest.json` pins
  mathlib to `8f9d9cff6bd7` = tag `v4.28.0`, and `lean-toolchain` is `leanprover/lean4:v4.28.0`.
  Mathlib's own `lean-toolchain` also says `v4.28.0` and its HEAD is
  `8f9d9cff6b chore: bump toolchain to v4.28.0 (#35406)`.
* **Nothing has ever been built here**: `.lake/packages/mathlib/.lake/build/lib` contains
  no `.olean` for even `Mathlib.GroupTheory.OrderOf`.
* `lake` reports `Lake version 5.0.0-src+7e01a1b (Lean version 4.28.0)`.

⇒ The `v4.28.0` elan toolchain install is **incomplete/hollow**: it ships a `lake`
that cannot resolve its own `Lake` namespace. This is the same failure mode recorded
for the second machine in `remote-machine-ecstasis` ("hollow elan toolchains").

## Attempted workarounds, and why they fail

| Attempt | Result |
|---|---|
| `lake build` with the pinned v4.28.0 | mathlib lakefile does not parse |
| `ELAN_TOOLCHAIN=leanprover/lean4:v4.33.1 lake build ...` | **progresses** (deps begin building) but mathlib's own modules fail: `Mathlib.GroupTheory.OrderOf`, `Mathlib.Tactic.Decide`, `Batteries.*`, `Aesop.*`, `Qq.Typ` all exit 1. Mixing a v4.28.0 mathlib with a v4.33.1 compiler is not viable. |
| Build from source | Not attempted: a cold mathlib build is hours of compute, and the failure is in toolchain resolution, not compilation. |

**Likely fix (not attempted, needs network + hours):** re-fetch and rebuild the toolchain
and packages, i.e. `elan toolchain uninstall leanprover/lean4:v4.28.0 && elan toolchain install
leanprover/lean4:v4.28.0`, then `lake update && lake exe cache get` in `Catalog/`. `cache get`
matters: without it, *every* mathlib module compiles from source.

## What this cost the round

The S9 counting identity `N_fail(p,q) = m_p m_q + Σ_{k=1..min(s_p,s_q)} (2^(k-1) m_p)(2^(k-1) m_q)`
is an **exact integer** statement and is well suited to kernel `decide` verification over
concrete prime pairs. The draft is at `ShortRepetition.UNBUILT.lean`, **unbuilt and
therefore unverified** — it is deliberately NOT in the Catalog, because a file carrying a
`sorry` that has never been compiled would misrepresent the Catalog's guarantee.

The numeric verification in `../S9_SHOR_REPETITIONS.md` (closed form vs brute force across
8 configurations, all |t| ≤ 1.48, plus end-to-end over 600 moduli, t = +1.03) is unaffected
and stands on its own.
