# Computational Evidence

The two theorems proved this cycle are statements of abstract topological
dynamics; the relevant "small cases" are finite combinatorial sanity checks of
the projective-limit construction and of Ellis' lemma. These were used to fix the
correct hypotheses before formalization.

## 1. Inverse limits of finite sets (projective Fraïssé core)

Take `F n` of sizes `(1, 2, 4, 8, …)` (so `|F n| = 2^n`) with the two surjective
bonds "drop the last bit". Threads of `InvLimit f` are exactly the infinite
binary sequences, so the limit is the Cantor set `2^ℕ`:
* `F 0 = {*}`, one base point; every step has exactly 2 preimages.
* number of length-`k` initial segments = `2^k`, matching `|F k|`.
* limit is nonempty (any bit-stream), compact, metrizable, perfect — consistent
  with `nonempty_invLimit`, `isCompact_invLimit`, `metrizableSpace_invLimit` and
  conjecture **C3**.

Constant bonds (all `|F n| = 1`) give a one-point limit; bonds that are *not*
surjective can give the empty limit (e.g. `F n = {0,1}`, `f n` constant `0`, but
require `x (n+1) = 1`): this is exactly why `nonempty_invLimit` assumes
**surjectivity** — the non-surjective case genuinely needs König's lemma. This
counterexample hunt confirmed the hypothesis is load-bearing, not cosmetic.

## 2. Ellis' lemma on finite flows

For a finite discrete space `X` with a `G`-action, closed = arbitrary subset and
minimal subflows = minimal orbits (single orbits, since orbit closures are orbits).
* `G = ℤ/4` acting on `X = ℤ/4` by translation: one orbit, `X` itself is the
  unique minimal subflow. ✓ matches `exists_minimalSubflow`.
* `X = ℤ/2 ⊔ ℤ/3` with the two cyclic rotations: minimal subflows are the two
  orbits `ℤ/2` and `ℤ/3`; neither is contained in the other. ✓ shows minimality
  is about ⊆-minimality, not uniqueness, validating the `∀ L, … → L = K` shape of
  `IsMinimalSubflow`.

## 3. OEIS

The only sequence that appeared is `|F k| = 2^k` (segment counts of the binary
Cantor limit), OEIS **A000079** (`1, 2, 4, 8, 16, …`). No new sequence was
generated; the results are structural rather than enumerative.

## Scope note

No further numerical search was warranted: both main theorems are universally
quantified topological statements whose content is the *existence/structure* of
limits and minimal sets, already discharged in Lean with only the standard axioms
`propext, Classical.choice, Quot.sound`.
