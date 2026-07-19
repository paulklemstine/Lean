# Computational Evidence

## Small-case calculations

The recurrence was expanded by hand for representative boundary families.

| Graph | Cops | Initial observation | Predicted stabilized outcome |
|---|---:|---|---|
| One vertex | 1 | Every state is captured | Every state winning at horizon 0 |
| Edgeless graph on at least two vertices | 1 | Neither player can change vertices | Exactly the captured states are winning |
| Complete graph on `n > 0` vertices | 1 | A cop can move to the robber's current vertex | Every state is winning within one round because capture is tested after the cops' move |
| Any finite graph | 0 | Capture has no witness | No state is winning at any finite horizon |

The last row is included as a proved example in `KCopwinAlgorithm.lean`. It is an important boundary check on the quantifier structure.

## Counterexample hunt

Two common transcription errors were tested conceptually:

1. Replacing “there exists a cops' move such that every robber response wins” by “for every robber response there exists a cops' move” lets cops react after observing the robber and is therefore not the stated game.
2. Omitting the stay-put option changes isolated vertices and can alter the recognized game.

These checks determined the definitions of `CopsMove`, `StayAdj`, and `winStep`.

## Sequence and database search

No numerical sequence is central to the correctness theorem, so no OEIS identifier is claimed. The relevant numerical data are finite-state counts and stabilization depths, which are proposed as targets for subsequent experiments rather than used as evidence for the proof.
