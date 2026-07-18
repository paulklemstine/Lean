# Computational Evidence

## Small-case calculations

For the key `h = (2, -1, 4)` and message `m = (3, 5, 0)`, the coordinate costs are `(5, 4, 4)`, hence `TSHA_h(m) = 4`. For the second key `h' = (0, 3, 1)`, the costs are `(3, 8, 1)`, hence `TSHA2(m) = (4, 1)`. Increasing the first message coordinate from `3` to `10` changes the two cost vectors to `(12, 4, 4)` and `(10, 8, 1)`, leaving the output `(4, 1)` unchanged.

For an arbitrary target `y`, setting `m_i = y - h_i` makes every coordinate cost equal to `y`. Thus the first examples already suggest an explicit preimage formula rather than exponential search.

| Dimension | Keys | Message | Output | Distinct colliding message |
|---:|---|---|---|---|
| 3 | `(2,-1,4)`, `(0,3,1)` | `(3,5,0)` | `(4,1)` | `(10,5,0)` |
| 4 | `(0,2,-1,5)`, `(3,0,4,-2)` | `(1,1,1,1)` | `(0,-1)` | `(1,8,1,1)` |

## OEIS search results

No integer sequence is intrinsic to the unrestricted real-valued hash or its fibers, so an OEIS search is not applicable.

## Counterexample hunt

The collision-resistance conjecture fails deterministically, not merely in sampled cases. For two keys in dimension at least three, choose one minimizing coordinate for each key and increase a third coordinate. Both selected minima remain unchanged. This construction yields a collision for every key pair and every starting message.

The proposed one-wayness claim also fails in the stated model: `m_i = y - h_i` is an explicit preimage for every target `y`.

## Tables and interpretation

The relevant comparison with SHA256 is structural rather than a timing benchmark. SHA256 has a fixed 256-bit output and deliberately mixes all input bits. The stated tropical map has one or two real outputs, admits a closed-form preimage, and possesses deterministic collision rays once an unused coordinate is available. Runtime measurements at `k = 32, 64, 128` would therefore measure evaluation speed but would not provide evidence of cryptographic mining difficulty.
