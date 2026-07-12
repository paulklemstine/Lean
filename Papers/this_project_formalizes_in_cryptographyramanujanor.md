# Computational Evidence

The theorem is topological/logical (Baire category on the Cantor space `ℕ → Bool`),
so the relevant "computation" is the finite combinatorics behind the two structural
facts. We record small-case checks that motivate the formal proof.

## 1. No isolated points (finite-cylinder counting)

A basic open neighbourhood of `x : ℕ → Bool` is a cylinder fixing coordinates on a
finite set `I ⊆ ℕ` and leaving the rest free:

    C(I, x) = { y | ∀ i ∈ I, y i = x i }.

Its cardinality is `2^(ℕ \ I)`, i.e. it contains `2` choices at *every* index outside
`I`. Small cases:

| |I| | # free coords among first 5 | points of C(I,x) in {0..4}-cube |
|-----|-----------------------------|---------------------------------|
| 0   | 5                           | 32                              |
| 1   | 4                           | 16                              |
| 2   | 3                           | 8                               |
| 5   | 0 (but infinitely many later)| ≥ 2 (flip any index ≥ 5)       |

For every finite `I` there is an index `j ∉ I`; flipping `x` at `j` yields a point
`y ≠ x` inside `C(I, x)`. Hence no cylinder equals `{x}`, so `{x}` is never open:
`ℕ → Bool` has no isolated points. This is exactly `singleton_notMem_nhds`.

## 2. Perfect sets are subsingletons

An oracle `O : ℕ → Option Bool` that is perfect for `T` satisfies `O n = some (T n)`
for all `n`, so `T n` is forced to be the unwrapped value of `O n`. Two perfect worlds
for the same `O` must agree everywhere. Example: `O = fun _ => some true` is perfect
only for `T = fun _ => true`; `O = fun n => some (n.bodd)` is perfect only for
`T = Nat.bodd`. Each oracle pins down `≤ 1` world (`perfect_unique`).

## 3. Countable union → meagre → dense complement

Each perfect set is a point (or empty), hence nowhere dense (Part 1). A countable
family therefore covers a countable union of nowhere dense sets = a meagre set. In the
finite-cube picture, the covered worlds occupy a vanishing fraction: covering the first
`k` oracles constrains at most `k` coordinates, leaving `2^(rest)` free worlds. By the
Baire category theorem the defeating set is comeager, matching `missed_dense`.

## Counterexample hunt

The claim "some countable family covers a comeager set of worlds" would contradict the
theorem. Testing the natural candidates (echo oracles `O_T = fun n => some (T n)` for
`T` ranging over a countable dense set of eventually-periodic truths) confirms each
covers exactly one world, so any countable batch covers only countably many worlds —
never comeager. No counterexample found, consistent with the proof.
