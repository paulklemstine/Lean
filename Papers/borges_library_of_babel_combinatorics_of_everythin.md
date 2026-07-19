# Computational Evidence

The formal theorem is a general finite-counting argument, but small binary cases illustrate its sharp content.

| Book length `L` | Program length `k` | Books `2^L` | Programs `2^k` | Guaranteed unnamed books `2^L - 2^k` |
|---:|---:|---:|---:|---:|
| 2 | 1 | 4 | 2 | 2 |
| 3 | 1 | 8 | 2 | 6 |
| 3 | 2 | 8 | 4 | 4 |
| 4 | 2 | 16 | 4 | 12 |
| 8 | 4 | 256 | 16 | 240 |

The lower bound is sharp when the decoder is injective: exactly one distinct book is named by each program. Collisions only increase the number of unnamed books.

For topology, any two distinct binary books have positive integral Hamming distance, hence the open ball of radius `1` around a book is its singleton. Thus every singleton is open (and closed), confirming discreteness and ruling out connectedness as soon as at least two books exist.

No OEIS search is relevant: the sequences used are the elementary powers `2^n` and their differences, rather than a newly observed sequence.

Counterexample hunt: the requested simultaneous claims “connected” and “totally disconnected” fail already for one-character binary books. The library has two points at Hamming distance one, and each point is open. The Lean development therefore proves the corrected statement: every nontrivial finite Hamming library is **not connected**.
