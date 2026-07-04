# Computational Evidence — Generalized Honeymoon Oberwolfach Problem

Model used: the **same-table** reading of "sitting together". `2n` guests = `n` couples;
each night the guests are partitioned into a table multiset `{2 (×s), 2m₁, …, 2m_t}`; couples
always share a table; each non-spouse pair shares a table exactly once over the schedule.

## 1. The counting invariant (small cases)

Per night, the number of *ordered* same-table pairs (including the diagonal) equals
`Σ_tables (size)² = 4s + 4·Σ mᵢ²`. Writing this as `4n + 4·msum` with `msum = Σ mᵢ(mᵢ − 1)`
(using `n = s + Σ mᵢ`), the master double count gives

    (#nights) · msum = n(n − 1),      so   msum ∣ n(n − 1)   and   #nights = n(n−1)/msum.

| n | table sizes        | s | (mᵢ)   | msum = Σmᵢ(mᵢ−1) | n(n−1) | #nights forced |
|---|--------------------|---|--------|-------------------|--------|----------------|
| 1 | {2}                | 1 | ()     | 0                 | 0      | any (no pairs) |
| 3 | {6}                | 0 | (3)    | 6                 | 6      | 1              |
| 3 | {2,4}              | 1 | (2)    | 2                 | 6      | 3              |
| 4 | {4,4}              | 0 | (2,2)  | 4                 | 12     | 3              |
| 4 | {8}                | 0 | (4)    | 12                | 12     | 1              |
| 5 | {4,6}              | 0 | (2,3)  | 8                 | 20     | not integral → obstruction |
| 6 | {4,4,4}            | 0 | (2,2,2)| 6                 | 30     | 5              |

The row `n = 5, {4,6}`: `msum = 8` does **not** divide `20`, so the obvious necessary condition
already rules this instance out — a genuine, non-vacuous obstruction.

## 2. Explicit constructions verified

* **One giant round table (all n).** One night, one table of size `2n`. `pairMeetings = (2n)²
  = 4n² = 4n + 4·n(n−1)`, i.e. `msum = n(n−1)`, `#nights = 1`. Verified generically
  (`oneTableSchedule`, `honeymoon_exists`).

* **n = 3, tables {2,4}, 3 nights.** Guests `= Fin 3 × Bool`; couples `= {(a,false),(a,true)}`.
  Night `k`: couple `a = k` sits alone (size-2 table `0`); the other two couples share the
  size-4 table `1`. Each of the three couple-pairs `{a,a'}` shares the size-4 table on the
  single night `k ∉ {a,a'}`, so every cross pair meets exactly once. All axioms verified by
  exhaustive check (`mixedSchedule`), and it meets the necessary condition `2 ∣ 6`, `#nights =
  3` (`mixedSchedule_meets_necessary`).

## 3. Counterexample hunt

Testing the *tightened* claim "`msum ∣ n(n−1)` is also **sufficient**" is out of reach of a
small search, but the necessary direction survived every case above. No counterexample to the
master identity `(#nights)·msum = n(n−1)` was found; the identity is proved unconditionally.

## 4. Relation to the cyclic-adjacency variant

If "sitting together" instead means *being adjacent* around the round table (the classical
Oberwolfach reading), the analogous double count yields `(#nights)·Σ mᵢ = 2n(n−1)`, hence
`Σ mᵢ ∣ 2n(n−1)`. This matches the shape of the divisor `2n(n−1)` appearing in the informal
problem statement and is recorded as a future direction.
