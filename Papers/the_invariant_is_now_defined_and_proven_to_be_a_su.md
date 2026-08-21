# Computational evidence — degree monoids of transition systems

All computations below were run in Lean (`#eval`) against a brute-force reference
implementation of the chain machine `chainRel S` (states `ℕ`; `0 → s-1` for each `s ∈ S`,
`i → i-1` for `i > 0`), by breadth-first computation of the set of states reachable in
exactly `n` steps. They motivated and then cross-checked the formal theorems in
`Catalog/Computation/DegreeMonoid*.lean`. The theorems themselves are proved symbolically;
none of them relies on a computation.

## 1. Return-time sets of small chain machines

| loop lengths `S` | return times `n < 20` | conclusion |
|---|---|---|
| `{2,3}` | 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, … | `⟨2,3⟩`, unique gap `1` |
| `{3,5}` | 0, 3, 5, 6, 8, 9, 10, 11, 12, … | `⟨3,5⟩`, gaps `1,2,4,7` |
| `{4,6}` | 0, 4, 6, 8, 10, 12, 14, 16, 18 | period `2`, unique gap `2` |

This is exactly `degreeMonoid (chainRel S) 0 = AddSubmonoid.closure S`
(`degreeMonoid_chainRel`), together with the structure theorem: every sufficiently large
multiple of the period `gcd S` occurs.

## 2. Gap counts vs. Sylvester's formula

Brute-force count of `n ∉ ⟨p,q⟩` for coprime `p,q`, compared with `(p-1)(q-1)/2`, and the
largest gap compared with the Frobenius number `pq - p - q`:

| `(p,q)` | #gaps | `(p-1)(q-1)/2` | largest gap | `pq-p-q` |
|---|---|---|---|---|
| (2,3) | 1 | 1 | 1 | 1 |
| (3,4) | 3 | 3 | 5 | 5 |
| (3,5) | 4 | 4 | 7 | 7 |
| (4,7) | 9 | 9 | 17 | 17 |
| (5,7) | 12 | 12 | 23 | 23 |

Perfect agreement; formalised as `sylvester_gap_ncard` and `frobenius_gap_of_chainRel`.
The gap sequence `1, 3, 4, 9, 12, …` is the classical genus of the numerical semigroup
`⟨p,q⟩` (Sylvester, 1882).

## 3. Synchronous products

Running the single-loop machines of lengths `4` and `6` in lockstep, the common return
times below 30 are `0, 12, 24` — the multiples of `lcm 4 6 = 12`. Formalised as
`degreeMonoid_prodRel` (product = meet) and `degPeriod_prodRel` (period = lcm), with the
concrete corollary `degreeMonoid_prod_cycles`.

## 4. Counterexample hunt: is nondeterminism really needed?

Every machine above that exhibits a gap is nondeterministic (state `0` has several
successors). A search over deterministic machines finds no gaps at all: for a deterministic
relation the successor of a state is unique, the orbit of a returning state is a cycle of
some length `d`, and the return times are exactly the multiples of `d`. This observation
became the theorem `deterministic_no_gaps`, whose contrapositive
`no_deterministic_realises_two_three` shows that `⟨2,3⟩` is *not* realisable
deterministically — so the invariant strictly separates deterministic from nondeterministic
machines, even though nondeterministic finite machines realise every submonoid of `ℕ`
(`exists_finite_machine`).
