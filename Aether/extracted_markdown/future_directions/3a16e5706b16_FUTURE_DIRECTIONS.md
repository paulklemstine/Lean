# Future Directions — Fundamental Quantum Code Bounds

## Synthesis

The new file `Catalog/Physics/QuantumCodeBounds.lean` closes a conceptual gap left open by
the existing `Physics.StabilizerBounds` (`QuantumStabilizer`). There, the quantum Hamming
bound was *postulated* as a structure field (`NondegenerateCode.syndrome_injective`): the
sphere-packing inequality `hammingSum n t ≤ 2^(n-k)` was assumed, not derived. We replace
that assumption with a *proved* pigeonhole argument grounded in an exact enumeration of
Pauli errors.

The technical core is the **exact Pauli weight enumerator**

> `pauli_weight_count : #{e : Fin n → Fin 4 | weight e = i} = 3^i · C(n, i)`,

proved by realizing a weight-`i` error as a disjoint union over `i`-subsets of qubit sites,
each carrying `3^i` non-identity (X/Y/Z) labelings. Summing the shells gives
`pauli_ball_count` (the radius-`t` Pauli ball has exactly `hammingSum n t` elements), and
the binomial identity `pauli_weight_partition_sum` (`∑ 3^i C(n,i) = 4^n`) recovers the total
Pauli count, connecting back to `QuantumStabilizer.pauli_total_count`. From these,
`quantum_hamming_bound_fundamental` derives the Hamming bound from a genuine injective
syndrome map, and `five_qubit_perfect_pigeonhole` certifies that the [[5,1,3]] code exactly
tiles its 16-element syndrome space.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `pauli_weight_count` | weight-`i` errors number `3^i·C(n,i)` | proved (0 sorry) |
| `pauli_ball_count` | radius-`t` ball has `hammingSum n t` errors | proved |
| `quantum_hamming_bound_fundamental` | injective syndromes ⟹ `hammingSum ≤ 2^(n-k)` | proved |
| `pauli_weight_partition_sum` | `∑ 3^i C(n,i) = 4^n` | proved |
| `pauli_ball_le_total` | ball ≤ `4^n` | proved |
| `five_qubit_perfect_pigeonhole` | [[5,1,3]] tiles its syndrome space | proved |

All results depend only on `propext`, `Classical.choice`, `Quot.sound` (plus
`ofReduceBool`/`trustCompiler` for the single `native_decide` computation).

## Research Directions

### 1. Degenerate codes break the naive pigeonhole — quantify the gap.
The fundamental Hamming bound proved here assumes *distinct errors give distinct syndromes*.
Quantum codes can be **degenerate**: distinct low-weight errors may act identically on the
codespace and so need not be separately corrected. Conjecture: there is a family of
stabilizer codes for which the number of *correctable syndrome classes* is strictly smaller
than `hammingSum n t`, so the inequality `hammingSum n t ≤ 2^(n-k)` is *violated* while the
code still corrects all weight-`t` errors. **The key insight is** that degeneracy quotients
the Pauli ball by the stabilizer group, so the correct packing object is `ball / stabilizer`,
not the ball itself. **Why now?** We already have `pauli_ball_count` as the exact size of the
unquotiented ball; the natural next step is to formalize the stabilizer-orbit quotient and
prove the degenerate Hamming bound `#(ball / S) ≤ 2^(n-k)` as the true sphere-packing law.

### 2. A fully proved quantum Singleton bound via subsystem dimension counting.
`QuantumStabilizer` also *assumes* the Singleton bound `2d + k ≤ n + 2`. Conjecture: it can
be derived combinatorially from a no-cloning/erasure-correction counting argument analogous
to `quantum_hamming_bound_fundamental`, replacing the assumed `SingletonValidCode.singleton`
field with a theorem. **The key insight is** that correcting `d-1` erasures means any `n-d+1`
qubits determine the logical state, which is a *surjectivity* statement on restricted Pauli
projections dual to the *injectivity* used for Hamming. **Why now?** The Hamming side is now
fully formalized; mirroring the injection/cardinality template on the dual (erasure) side is
a direct, self-contained target.

### 3. q-ary generalization: qudits and the `(q²-1)^i C(n,i)` enumerator.
`pauli_weight_count` is the `q = 2` (`Fin 4 = Fin (q²)`) special case. Conjecture: for
qudits of local dimension `q`, the weight-`i` Pauli enumerator is `(q²-1)^i · C(n,i)`, and
the ball/total identity becomes `∑ (q²-1)^i C(n,i) = (q²)^n`. **The key insight is** that the
non-identity Heisenberg–Weyl operators on a single qudit number exactly `q²-1`, so the only
change to our induction is the base `3 ↦ q²-1`. **Why now?** Our proof factors cleanly
through the constant `3`; generalizing to a parameter `q` is a low-risk refactor that
immediately yields the full q-ary quantum Hamming bound.

### 4. Asymptotic GV-vs-Hamming separation as a decidable threshold family.
Conjecture: for fixed rate `R = k/n`, the largest `t` allowed by `hammingSum n t ≤ 2^(n-k)`
(Hamming) and the largest guaranteed by Gilbert–Varshamov existence have a *constant-factor
gap* that can be exhibited by an explicit, machine-checkable sequence of `n`. **The key
insight is** that both bounds are entropy expressions in `t/n`, so the crossover is governed
by `H_4(·)`-type functions whose rational over/under-approximations are `decide`-able at each
`n`. **Why now?** With `pauli_ball_count` giving the exact LHS, the inequality is a pure
`Nat` statement at every `n`, so the separation becomes a sequence of finite, falsifiable
computations rather than an analytic estimate.

### 5. BPT bound for the toric family from the proved enumerator.
`QuantumStabilizer.toric_kd2_equals_n` shows `k·d² = n` for toric codes by definition.
Conjecture: combining `quantum_hamming_bound_fundamental` with the geometric locality of the
toric stabilizers yields the Bravyi–Poulin–Terhal ceiling `k·d² ≤ c·n` as a *consequence*
(with explicit `c`) for *every* 2D-local stabilizer code, not just the toric definitional
case. **The key insight is** that 2D locality caps the number of independent low-weight
logical representatives, so the syndrome-injection budget `2^(n-k)` controls `k·d²`. **Why
now?** We now have the syndrome-counting inequality as a reusable lemma; the missing piece is
a formal locality predicate, after which BPT becomes a corollary of the proved Hamming bound.
