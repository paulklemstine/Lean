# Computational evidence — amortized model-delta compression (Tropical / min-plus)

This note records the exploratory numerics that guided the Lean development in
`Catalog/Tropical/CompressionDelta/`.  **Status of the numbers below: exploratory.**
Every general law they suggested is *proved* in Lean (no `sorry`, standard axioms only);
the tables themselves were produced by a scratch dynamic program and are reported here
only as the evidence that motivated the theorem statements.

## Setup

The protocol is a min-plus shortest-path problem: for a stream of messages, the encoder
chooses a decoder state per message, paying a model-delta cost `dlt s s'` to move the
shared decoder and then the residual cost `c_i(state)` of coding the message.  The scratch
program is a plain Viterbi/DP over these costs.

## 1. Coherent stream (single domain), two decoder states

Generic state costs `r + 1` bits/message; the specialized state costs `r`, entering it
costs `D` bits.  `r = 3`, `D = 5`:

| n | DP optimum | `n*r + min(D, n)` |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 4 | 4 |
| 3 | 12 | 12 |
| 5 | 20 | 20 |
| 6 | 23 | 23 |
| 9 | 32 | 32 |

The kink at `n = D` is the break-even point.
Proved: `optCost_replicate_eq`, `beats_generic_iff`, `boolModel_optCost`.

## 2. Maximally incoherent stream (domain flips every message)

`r = 3`, `D = 5`, start state wrong / right for the first message:

| n | DP (wrong start) | `n*r + ⌈n/2⌉` | DP (right start) | `n*r + ⌊n/2⌋` |
|---|---|---|---|---|
| 1 | 4 | 4 | 3 | 3 |
| 2 | 7 | 7 | 7 | 7 |
| 5 | 18 | 18 | 17 | 17 |
| 9 | 32 | 32 | 31 | 31 |

Note the optimum is *independent of `D`* for all `D ≥ 1`: switching never pays.
Proved: `optCost_altCosts`, `tendsto_alternating_rate` (rate `r + 1/2`).

## 3. Block-alternating streams: the coherence-length law

Excess over the rate floor `B·L·r`, for `B` blocks of length `L` (domain alternating):

| L | D | excess for B = 0..8 |
|---|---|---|
| 2 | 1 | 0 1 2 3 4 5 6 7 8 |
| 2 | 3 | 0 2 2 4 4 6 6 8 8 |
| 4 | 2 | 0 2 4 6 8 10 12 14 16 |
| 4 | 3 | 0 3 4 7 8 11 12 15 16 |
| 4 | 5 | 0 4 4 8 8 12 12 16 16 |
| 6 | 5 | 0 5 6 11 12 17 18 23 24 |
| 7 | 5 | 0 5 7 12 14 19 21 26 28 |

Every row matches `⌊B/2⌋ · min(2D, L) + (B mod 2) · min(D, L)`.
This is exactly the closed form later proved as `blockExcess_closed_form` together with
`optCost_blockCosts`; the induced per-message rate `r + min(2D, L)/(2L)` is
`tendsto_block_rate`.  Setting `L = 1` reproduces §2 and letting `L → ∞` reproduces §1.

An earlier guess, `excess = min(B·D, ⌈B/2⌉·L)`, is **refuted** by the row `L = 4, D = 3`
at `B = 3`: the guess gives `8`, the true optimum is `7` (a mixed policy — switch into the
first block, then coast — beats both pure policies).  This counterexample is why the Lean
development proves the block law through a two-state min-plus transfer step
(`blockAbsorb`) rather than by comparing two candidate policies.

## 4. Counting side

No numerics were needed: the bound `#{bitstrings of length ≤ t} = 2^(t+1) − 1` is proved
exactly (`card_shortStrings`) and drives `card_compressible_le`,
`exists_long_codeword` and `stream_counting_bound`.
