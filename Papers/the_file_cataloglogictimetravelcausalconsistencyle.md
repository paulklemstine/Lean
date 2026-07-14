# Computational Evidence — Contrarian Time-Travel Consistency

All conjectures below were checked computationally on small state spaces before being
formalized in `TimeTravelContrarian.lean`. A causal loop is modelled by its
one-traversal map `evolve : X → X`; it is *self-consistent* iff `evolve` has a fixed
point. `consistentCount = #{x : evolve x = x}`.

## 1. Reversibility does not force consistency (DISPROVED)

The grandfather flip `not : Bool → Bool` is a bijection:

| b     | not b |
|-------|-------|
| false | true  |
| true  | false |

No fixed point ⇒ `consistentCount = 0`, yet `not` is bijective. So "bijective loop map
⇒ self-consistent" is false. Verified by `decide`.

## 2. Consistency does not descend along repetition (DISPROVED)

`not ∘ not = id` fixes every state (`consistentCount = 2`), but `not` alone fixes none.
So a double loop can be consistent while the single loop is paradoxical.

## 3. Consistency is not compositional (DISPROVED)

On `Fin 3` take `f = ![1,0,2]` (swap 0,1; fixes 2) and `g = ![0,2,1]` (swap 1,2; fixes 0).
Both are self-consistent. Their composite:

| x | g x | f(g x) |
|---|-----|--------|
| 0 | 0   | 1      |
| 1 | 2   | 2      |
| 2 | 1   | 0      |

`f ∘ g` is the 3-cycle `0→1→2→0`, fixed-point free. Two consistent loops compose to a
paradoxical one. Verified by `decide`.

## 4. Involution parity (PROVED)

For an involution `f` on a finite set, `consistentCount ≡ |X| (mod 2)`. Samples:

| involution on X          | |X| | fixed points | count | count vs |X| mod 2 |
|--------------------------|-----|--------------|-------|--------------------|
| `not` on `Bool`          | 2   | ∅            | 0     | 0 ≡ 0              |
| `id` on `Bool`           | 2   | all          | 2     | 0 ≡ 0              |
| `id` on `Fin 3`          | 3   | all          | 3     | 1 ≡ 1              |
| swap(0,1) on `Fin 3`     | 3   | {2}          | 1     | 1 ≡ 1              |

In every case the parity matches. In particular on odd `|X|` the count is odd, hence
positive: an involutive loop on an odd state space is always self-consistent.

## 5. Contraction ⇒ unique history (PROVED)

For a contraction `evolve` on a complete metric space, Banach's theorem gives a unique
fixed point — "deterministic time travel". No numerical search needed; this is the
qualitative Banach regime.

## 6. Eventual consistency (PROVED)

On a finite non-empty state space the orbit `x, evolve x, evolve² x, …` must repeat
(pigeonhole), giving a positive `k` with `evolveᵏ` having a fixed point. E.g. for `not`
on `Bool`, `k = 2` works.
