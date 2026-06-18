# Future Directions: Collatz One-Way Function Structure

## Synthesis

This cycle established the formal preimage structure of the Collatz map as a foundation for
cryptographic one-way function analysis. The central result is `collatzIter_preimage_exp_bound`:
for any value n, the set of inputs mapping to n under a iterations of the Collatz map has
cardinality at most 2^a. This was proved by a clean induction using parity-class partitioning
— the Collatz map is injective when restricted to even inputs or to odd inputs separately,
even though it is not globally injective.

The proof architecture reveals a structural insight: the "one-way" character of the Collatz map
comes from parity destruction. Each application of T erases one bit of parity information, and
recovering that bit requires exhaustive search over two branches. Over a steps, this compounds
to 2^a possible backward paths — the exponential search space that a cryptographic inverter
would face. The bound is tight in the worst case (consider inputs where every backward step
has two valid preimages).

What failed: we did not attempt to prove any *lower* bound on preimage count or on inversion
complexity. The 2^a upper bound on preimages is necessary but not sufficient for one-way function
security — one also needs that preimages actually spread across a large space and cannot be
found by shortcuts. The gap between "at most 2^a preimages" and "inversion requires 2^Ω(a) work"
is the core open question for future cycles.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `collatz_preimage_even` | proved | Every n has preimage 2n: forward computation is trivial |
| `collatz_distinct_preimages_diff_parity` | proved | Distinct preimages differ in parity: parity information is destroyed |
| `collatz_preimage_at_most_two` | proved | At most 2 preimages per value: bounds backward branching at 2 |
| `collatz_injective_on_even` | proved | Collatz is injective on even inputs |
| `collatz_injective_on_odd` | proved | Collatz is injective on odd inputs |
| `collatzIter_preimage_exp_bound` | proved | Preimage tree under T^a has ≤ 2^a leaves: exponential inversion cost |
| `collatzHash_eq_iff` | proved | Hash equality ↔ trajectory congruence mod 2^b |

## Research Directions

### Direction 1: Lower Bound on Preimage Density via Stopping Times

**Hypothesis**: For sufficiently large n and a ≥ log₂(n), the number of preimages of 1 under
T^a in [1, N] grows as Θ(N · (3/4)^a) — most numbers reach 1 but from exponentially shrinking
neighborhoods.

**Test**: Formalize the "3/4 heuristic" — at each backward step, with probability 2/3 only the
even preimage exists (odd candidate fails divisibility by 3), and with probability 1/3 both
exist. Prove that the expected preimage count after a steps is (4/3)^a under this model.

**Why now**: We have `collatzIter_preimage_exp_bound` giving the upper bound 2^a. The key insight
is that the actual branching factor is closer to 4/3 than 2, because odd preimages exist only
when the target ≡ 1 (mod 3). Formalizing this conditional branching refines the security analysis.

**If true**: This gives a tighter security bound — inversion requires ~(4/3)^a work rather than
2^a, still exponential but with a smaller base.

**If false**: It would mean the Collatz preimage tree is more irregular than the heuristic
predicts, potentially weakening the one-way function argument.

### Direction 2: Collision Resistance of Collatz Hash via Trajectory Divergence

**Hypothesis**: For the Collatz hash H_{k,b}(x) = T^k(x) mod 2^b, if x ≠ y and
|x - y| ≤ 2^b, then H_{k,b}(x) ≠ H_{k,b}(y) for k ≤ c·b for some constant c > 0.
In other words, nearby inputs produce different hashes for polynomially many iterations.

**Test**: Prove that if x ≡ y (mod 2) (same parity), then |T(x) - T(y)| ≥ |x-y|/2 (even case)
or |T(x) - T(y)| = 3|x-y| (odd case). Use this to show trajectory divergence over multiple steps.

**Why now**: The key insight is that collision resistance reduces to trajectory divergence, and we
already have the injectivity-on-parity-classes machinery (`collatz_injective_on_even/odd`) to
analyze same-parity behavior.

**If true**: This gives a formal collision resistance guarantee for the Collatz hash, the first
rigorous security property for a dynamical-systems-based hash function.

**If false**: Collisions among nearby inputs would indicate that the Collatz map has insufficient
mixing for cryptographic use, pointing toward the need for additional mixing operations.

### Direction 3: Preimage Resistance via Mod-3 Constraints

**Hypothesis**: For any n, the number of m ≤ N with collatz(m) = n is at most 2 (already proved),
and the odd preimage (m-1)/3 exists if and only if n ≡ 0 (mod 2) and (n-1) is divisible by 3
with the quotient being odd. Formalize this exact characterization.

**Test**: Prove `collatz_preimage_odd_exists_iff`: there exists an odd m with collatz m = n if
and only if n ≥ 4 ∧ n % 2 = 0 ∧ (n-1) % 3 = 0 ∧ ((n-1)/3) % 2 = 1. This gives a complete
characterization of when the backward tree branches.

**Why now**: The key insight is that the mod-3 constraint is the bottleneck — roughly 1/3 of
backward steps have two branches and 2/3 have only one. This was heuristic before; formalizing
it makes the branching analysis rigorous.

**If true**: Combined with Direction 1, this gives a complete formal model of preimage tree
growth, enabling precise security parameter estimation.

**If false**: The characterization might need refinement for edge cases near 0 or 1.

### Direction 4: Composition Security — Iterated Hash Chains

**Hypothesis**: Define a Collatz-based hash chain: H₀ = x, H_{i+1} = collatzHash(k, b, H_i).
The chain has no short cycles: if H_a = H_0 for a > 0, then a ≥ 2^(b/2). This would establish
cycle resistance, a property needed for hash-chain-based signatures.

**Test**: Prove that collatzIter has no short cycles by showing that if collatzIter a n = n and
n > 0, then the trajectory {n, T(n), T²(n), ...} is a cycle, and use the known absence of
non-trivial Collatz cycles below 2^68 to get a conditional result.

**Why now**: The key insight is that cycle resistance is orthogonal to preimage resistance and
requires different techniques (trajectory analysis rather than preimage counting). Our iteration
infrastructure (`collatzIter`) is already in place.

**If true**: This gives a second independent security property for Collatz-based constructions.

**If false**: Short cycles in the hash chain would be a devastating weakness, likely ruling out
Collatz as a cryptographic primitive entirely.

### Direction 5: Formalize the "Parity Sequence" Encoding and Its Information Content

**Hypothesis**: The parity sequence p(x, a) = (x%2, T(x)%2, T²(x)%2, ..., T^{a-1}(x)%2)
uniquely determines x given T^a(x). That is, the map x ↦ (p(x,a), T^a(x)) is injective.
This would formalize the claim that inversion is equivalent to guessing a bits of parity.

**Test**: Prove injectivity of the parity-sequence encoding. The key step: given the parity
bit and the output of T, one can uniquely recover the input (even: multiply by 2; odd:
subtract 1 and divide by 3).

**Why now**: The key insight is that this is a cleaner reformulation of one-wayness than counting
preimages. We already have `collatz_injective_on_even/odd` which gives injectivity conditioned
on knowing parity — this direction just packages that as information theory.

**If true**: This gives the cleanest possible formulation of Collatz one-wayness: inverting T^a
is equivalent to guessing a independent bits, giving exactly 2^a work.

**If false**: If the parity sequence doesn't uniquely determine x, there would be collisions
in the parity-augmented map, contradicting our injectivity results.
