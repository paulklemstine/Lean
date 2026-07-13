# Computational Evidence: the universal core of a theory

The central claims concern an abstract consequence operator, so the most
informative "small cases" are concrete finite consequence systems where every
quantity can be evaluated by hand.

## 1. Small-case calculations (identity consequence operator on ℕ)

Take `C Γ = Γ` (a statement is a consequence of `Γ` exactly when it is assumed).
Consistency means "does not entail everything", i.e. `Γ ≠ univ`.

| base    | consistent? | some consistent extensions        | universal core (∩ of extensions) |
|---------|-------------|-----------------------------------|----------------------------------|
| `{0}`   | yes         | `{0}`, `{0,1}`, `{0,1,2}`, …       | `{0}`                            |
| `{0,1}` | yes         | `{0,1}`, `{0,1,2}`, …              | `{0,1}`                          |
| `∅`     | yes         | every proper subset of `ℕ`        | `∅`                              |
| `univ`  | no          | (none: already entails all)       | — (base excluded)                |

In every consistent row the intersection over consistent extensions returns the
base itself: the extensions can only *add* statements, and the base appears among
them (it extends itself), so the intersection is pinned to the base. This matches
`universal_eq_base`.

## 2. Strictness check

For base `{0}` the extension `{0,1}` is consistent and *strictly* larger:
`{0} ⊊ {0,1}` and `{0,1} ≠ univ`. Hence the intersection genuinely ranges over
sets bigger than the base, so `universal_eq_base` is a real coincidence, not a
degenerate one. This is the content of `strict_extension` and
`extension_consistent`.

## 3. Compactness / finite-character check

With the same identity operator and `bot := 0`:

- `{1}` is consistent (`0 ∉ {1}`), and every finite subset of `{1}` (namely `∅`
  and `{1}`) is consistent — consistent-iff-finite holds.
- Any theory containing `0` is inconsistent, detected already by the finite
  subset `{0}` — again finite character.

Lindenbaum completion of `{1}`: greedily add naturals while avoiding `0`; the
limit `ℕ \ {0}` is consistent (omits `0`) and maximal (adding anything left, i.e.
`0`, breaks consistency) and closed (`C` is the identity). This is the explicit
witness behind `exists_maximal`.

## 4. Counterexample hunt

The universal claim tested is: *for a consistent base, the intersection of the
theorem-sets of all consistent extensions equals the base's theorem-set.* Across
the finite identity systems above (and their subset lattices up to `ℕ`), no
counterexample appears: dropping the consistency restriction, or dropping
consistency of the base, is the only way to break the equality, exactly as the
hypotheses of `universal_eq_base` predict. The one genuine failure mode — a rising
chain of consistent theories with an inconsistent union — requires a non-compact
operator and is recorded as Future Direction 4.

## 5. OEIS

No integer sequence is intrinsic to these results; the objects are theories
(sets of statements) rather than counts, so an OEIS search is not applicable.
