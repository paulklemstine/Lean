# Computational evidence: hypercube graph HQECC conjectures

## Small cases

For the hypercube graph `Q_n`, the vertex and edge counts are
`V(n)=2^n` and `E(n)=n·2^(n-1)`.  Since `Q_n` is connected, its graph-cycle
rank is `E-V+1`.

| n | V | E | E−V+1 | proposed logical qubits | graph girth (n≥2) | proposed `2^(n/2)` (even n) |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 2 | 1 | 0 | 1 | acyclic | — |
| 2 | 4 | 4 | 1 | 1 | 4 | 2 |
| 3 | 8 | 12 | 5 | 1 | 4 | — |
| 4 | 16 | 32 | 17 | 1 | 4 | 4 |
| 5 | 32 | 80 | 49 | 1 | 4 | — |
| 6 | 64 | 192 | 129 | 1 | 4 | 8 |
| 7 | 128 | 448 | 321 | 1 | 4 | — |
| 8 | 256 | 1024 | 769 | 1 | 4 | 16 |

The sequence through `n=8` is `0, 0, 1, 5, 17, 49, 129, 321, 769`.
These values are certified in `HypercubeCounterexample.lean` by the closed-form
theorem and explicit `Q_4`, `Q_6`, and `Q_8` corollaries.  The constant girth
claim is certified in `HypercubeDistance.lean` for every `n ≥ 2`.

## OEIS search

No OEIS lookup was used.  The exact closed form
`2^(n-1)(n-2)+1` is proved directly, so sequence identification is unnecessary.

## Counterexample hunt

The first counterexample to “one logical qubit for every hypercube graph” is
`Q_1` (cycle rank zero); among dimensions with cycles, the first is `Q_3`, with
cycle rank five.  The requested cases are all counterexamples:
`Q_4`, `Q_6`, and `Q_8` have ranks `17`, `129`, and `769`.

The proposed systolic growth also fails from `n=6` onward among requested even
cases: the graph girth remains four, whereas the proposed values are eight and
sixteen for `Q_6` and `Q_8`.

## Interpretation caveat

Graph girth is only the primal systole.  The distance of a CSS code is generally
the minimum of primal and dual logical weights.  Consequently, the formal girth
result refutes the proposed *systolic scaling*, but does not silently assume that
girth alone is the complete CSS distance.
