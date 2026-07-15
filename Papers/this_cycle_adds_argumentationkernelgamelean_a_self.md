# Computational evidence

The finite examples used in the formal development were exhaustively reduced by
Lean over all subsets of `Fin 3` and `Fin 4` inside the proofs themselves.

| directed cycle | kernel/stable-extension behaviour |
|---|---|
| 3-cycle | no kernel; no stable extension |
| 4-cycle | alternating sets `{0,2}` and `{1,3}` are distinct stable extensions |

No integer sequence is asserted, so an OEIS search is not applicable. The
3-cycle is the smallest counterexample to unconditional kernel existence among
the cycle examples considered. The 4-cycle simultaneously tests the positive
even-cycle direction and shows that existence need not imply uniqueness without
well-foundedness.
