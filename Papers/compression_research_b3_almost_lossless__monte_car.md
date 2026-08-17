# Computational evidence — almost-lossless / Monte-Carlo compression

All numbers below were produced by `#eval` on the *same* Lean definitions that the
theorems in `Catalog/Applications/AlmostLossless/` are stated about (imports:
`Applications.AlmostLossless.Optimal`, `.RandomCoding`, `.Checksum`).  They are
sanity checks and counterexample hunts, not proofs; every claim used in the
development is proved separately and machine-checked (see the file list at the
bottom).

## 1. The index codec (`toBits` / `fromBits`)

`#eval (List.range 8).map (fun n => (toBits 3 n, fromBits (toBits 3 n)))`

| n | `toBits 3 n` (little-endian) | `fromBits ∘ toBits` |
|---|------------------------------|---------------------|
| 0 | [f,f,f] | 0 |
| 1 | [t,f,f] | 1 |
| 2 | [f,t,f] | 2 |
| 3 | [t,t,f] | 3 |
| 4 | [f,f,t] | 4 |
| 5 | [t,f,t] | 5 |
| 6 | [f,t,t] | 6 |
| 7 | [t,t,t] | 7 |

Round trip exact on `0 … 2^k − 1`, as required by `fromBits_toBits`.
Counterexample hunt: `n = 2^k` wraps (e.g. `fromBits (toBits 3 8) = 0`), which is
why the hypothesis `n < 2 ^ k` is load-bearing in that lemma.

## 2. Colliding codebooks vs. the birthday bound

`badCodebooks q m` is the finset of *non-injective* maps `Fin q → Fin m`.
Columns: `|bad|`, total `m^q`, and the proved bound `q(q−1)m^(q−1)/2`
(`card_badCodebooks_le`).

| q | m | \|bad\| | m^q | bound |
|---|---|---------|-----|-------|
| 0 | 2,3,4 | 0 | 1 | 0 |
| 1 | 2,3,4 | 0 | m | 0 |
| 2 | 2 | **2** | 4 | **2** |
| 2 | 3 | **3** | 9 | **3** |
| 2 | 4 | **4** | 16 | **4** |
| 3 | 2 | 8 | 8 | 12 |
| 3 | 3 | 21 | 27 | 27 |
| 3 | 4 | 40 | 64 | 48 |
| 4 | 2 | 16 | 16 | 48 |
| 4 | 3 | 81 | 81 | 162 |
| 4 | 4 | 232 | 256 | 384 |

Observations that drove the formalisation:

* the bound is **attained with equality at `q = 2`** (bad = m), which is now the
  theorem `card_badCodebooks_two` / `collision_prob_two` — so the birthday bound
  cannot be improved in general;
* no violation was found in the sampled range, consistent with
  `card_badCodebooks_le`;
* the collision-free counts `m^q − |bad|` are the falling factorials
  `m·(m−1)···(m−q+1)` (for `m = 4`: 1, 4, 12, 24, 24), i.e. the rows of the
  falling-factorial table (OEIS A008279).  This is exactly what
  `card_badCodebooks_add` proves via `Fintype.card_embedding_eq`.

## 3. Decoder cost: structured vs. exhaustive search

Enumerative decoder cost `k + 2` (proved: `enumDecI_cost_enc`) against exhaustive
codebook search `2^k` (proved: `scanI_cost_exponential`):

| k | enumerative | exhaustive |
|---|-------------|------------|
| 0 | 2 | 1 |
| 1 | 3 | 2 |
| 2 | 4 | 4 |
| 3 | 5 | 8 |
| 4 | 6 | 16 |
| 8 | 10 | 256 |
| 11 | 13 | 2048 |

The crossover is at `k = 3/4`; the formal statement `linear_lt_exp` is therefore
guarded by `4 ≤ k`, and the *unbounded* speed-up is
`decoder_speedup_unbounded`.

## 4. Parity checksum

For `w = [t,f,t,t]`: `parity w = true`, and the transmitted word `w ++ [parity w]`
has `parity = false`.  Flipping each of the 5 positions of the transmitted word in
turn gives parity `[true, true, true, true, true]` — every single-bit corruption is
detected.  This is the theorem `withParity_detects_single_flip`.

## 5. What the evidence does *not* show

The evaluations above are finite samples.  The universal statements
(`card_badCodebooks_le`, `fromBits_toBits`, `enumDecI_cost_enc`,
`withParity_detects_single_flip`, `optimal_rate_iff`, …) are proved in Lean 4 and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

Files: `Catalog/Applications/AlmostLossless/{Core, Enumerative, Complexity,
RandomCoding, Checksum, Optimal, Summary}.lean`.
