# FUTURE_DIRECTIONS — Post-Quantum Cryptography: Lattice-Based Key Exchange

## Synthesis

This cycle formalized the *correctness core* of Learning-With-Errors cryptography in
Lean 4 (`Cryptography.LWEKeyExchange`), establishing the exact algebraic backbone that
both Regev public-key encryption and an LWE Diffie–Hellman-style key exchange depend on.
The central structural discovery is that **all of LWE correctness is an exact integer
identity plus one inequality**: when the protocol is run honestly, every modular
reduction in the decryption pipeline cancels, so the decryptor recovers the *exact*
integer `⟨r,e⟩ + msg·(q/2)` (`regev_decryption_identity`). Decoding then succeeds iff a
single sharp inequality `4·m·B < q` holds (`regev_correctness`). The same cancellation
phenomenon reappears in key exchange: with a *symmetric* public matrix `A`, the two
parties' raw session values differ by exactly the planted noise,
`k_A − k_B = ⟨s,e_B⟩ − ⟨t,e_A⟩` (`lwe_keyexchange_identity`), bounded in `ℓ¹` norm by
`(‖s‖₁ + ‖t‖₁)·B` (`lwe_keyexchange_agreement`). This is the LWE analogue of
Diffie–Hellman commutativity `g^{ab} = g^{ba}`: **symmetry of `A` plays the role of
group commutativity, and the error term is the price the lattice charges for hardness.**

What failed / what was deferred: the genuinely *computational* statements — the
worst-case-to-average-case reduction `GapSVP → LWE`, IND-CPA security of Regev, and
probabilistic forward secrecy — cannot be stated faithfully without a model of
computational indistinguishability and (for the reduction) a quantum algorithm. They are
recorded as `conjecture`-level abstract implications (`lwe_hard_of_gapSVP`, with `sorry`)
rather than being faked with trivial predicates that would prove nothing. The honest
move here is to build the missing *infrastructure* (a negligible-function / advantage
calculus) before attempting the security theorems.

The structural insight that ties the directions below together: **correctness is exact
algebra over `ℤ`; security is an inequality over a probability/advantage semiring.** We
have nailed the first half rigorously and identified precisely which semiring-level
infrastructure the second half needs. This connects to the existing catalog lattice
thread (`Cryptography.BerggrenLatticeCryptography`'s `svp_depth1_lower_bound` gives
*geometric* shortest-vector bounds; LWE is the *average-case* problem those bounds are
conjectured to protect).

## Results Summary

- `regev_decryption_identity`: proved — Regev decryption recovers `⟨r,e⟩ + msg·(q/2)` as an exact integer, exposing correctness as pure algebra.
- `regev_correctness`: proved — decoding recovers the message bit under the sharp budget `4·m·B < q` with `q = 2·half`.
- `lwe_keyexchange_identity`: proved — for symmetric `A`, the two session values differ by exactly `⟨s,e_B⟩ − ⟨t,e_A⟩` (LWE analogue of DH commutativity).
- `lwe_keyexchange_agreement`: proved — the session-value gap is `ℓ¹`-bounded by `(‖s‖₁ + ‖t‖₁)·B`, the quantitative agreement guarantee.
- `abs_dot_le_sum`, `abs_dot_indicator_le`: proved — generic integer dot-product bounds (triangle inequality; 0/1-indicator bound) reusable for any LWE error analysis.
- `params128_classical_secure_and_correct`: proved — a concrete set (n=512, q=16384, B=1, m=512) is simultaneously decryption-correct and ≥128-bit hard under classical core-SVP.
- `params128_quantum_secure`: proved — dimension n=484 already clears 128 bits under the conservative quantum core-SVP estimate `2^{0.265·n}`.
- `lwe_hard_of_gapSVP`: conjecture (`sorry`) — the worst-case→average-case reduction, awaiting a computational-hardness model.

## Research Directions

### Direction 1: Probabilistic decryption-failure bound
**Hypothesis**: For discrete-Gaussian errors of width `σ`, the Regev decryption-failure
probability is at most `2·m·exp(−q²/(32·m·σ²))`, i.e. the deterministic budget
`4·m·B < q` can be replaced by a tail bound that fails only negligibly.
**Test**: Replace the worst-case hypothesis `|e j| ≤ B` in `regev_correctness` by a
sub-Gaussian tail hypothesis and prove the failure event `{|⟨r,e⟩| ≥ q/4}` has
exponentially small measure using a Hoeffding/Chernoff bound on `∑ rⱼ eⱼ`.
**Why now**: `regev_correctness` already isolates the *single* bad event `|⟨r,e⟩| ≥ q/4`;
the key insight is that the whole proof now reduces to one concentration inequality on a
0/1-weighted error sum, which Mathlib's `MeasureTheory`/`Probability` library can support.
**If true**: Bridges the deterministic correctness core to real parameter selection,
where decryption failure is tolerated at rate `2^{-128}`.
**If false**: Reveals that the 0/1 randomness `r` correlates with `e` in a way that
defeats independence — a genuine structural warning about Regev's CRT-packed variants.

### Direction 2: Reconciliation closes key-exchange agreement to exact equality
**Hypothesis**: Adding a single-bit "signal/hint" function `σ : ℤ → Bool` to the key
exchange upgrades `lwe_keyexchange_agreement` (a bound `|k_A − k_B| ≤ Δ`) into *exact*
shared-key equality `reconcile(k_A, hint) = reconcile(k_B, hint)` whenever `4·Δ < q`.
**Test**: Define Peikert's rounding `⌊·⌉₂` with a cross-rounding hint and prove the
reconciliation theorem by the same case-split-on-residue argument used in
`regev_correctness`.
**Why now**: The key insight is that `lwe_keyexchange_agreement` already supplies the gap
bound `Δ = (‖s‖₁+‖t‖₁)·B`; only the boundary-disagreement at the decode threshold remains,
exactly the gap we flagged in that theorem's failure-analysis note.
**If true**: Yields the first fully verified end-to-end LWE key-exchange correctness
chain (NewHope/Frodo-style) in this catalog.
**If false**: Pinpoints that a 1-bit hint is information-theoretically insufficient for
the chosen `Δ/q` ratio, forcing multi-bit reconciliation.

### Direction 3: Symmetry of `A` is necessary, not just sufficient
**Hypothesis**: If `A` is *not* symmetric, key agreement provably fails: there exist
`A, s, t` with zero error such that `k_A ≠ k_B`, so `lwe_keyexchange_identity` is sharp.
**Test**: Construct an explicit `2×2` non-symmetric `A` and integer secrets giving
`⟨s, A t⟩ ≠ ⟨t, A s⟩`, and prove the inequality by `decide`/`norm_num`; mark it a
`disproved` boundary for the symmetric hypothesis.
**Why now**: The key insight is that our identity proof used `hA` in exactly one place
(the `sum_comm` rename), so dropping it should break agreement at the smallest dimension;
this is a one-shot counterexample search.
**If true**: Certifies that the public matrix *must* be symmetric (or that a transpose
must be transmitted), a concrete protocol-design constraint.
**If false (agreement survives)**: Would mean a hidden cancellation independent of
symmetry — surprising, and worth tracing to a deeper invariant.

### Direction 4: A negligible-advantage semiring for IND-CPA
**Hypothesis**: IND-CPA security of Regev can be stated and reduced to decision-LWE
*purely algebraically* by working in the semiring of "advantage functions"
`ε : ℕ → ℝ≥0` ordered by eventual domination, where `negligible` is an ideal.
**Test**: Define `Negligible (ε)` (∀ c, eventually `ε n ≤ n^{-c}`), prove it is closed
under addition and multiplication by polynomials, then state the hybrid argument
`Adv_INDCPA ≤ Adv_LWE + negl` as an inequality in this structure (reduction body `sorry`).
**Why now**: The key insight is that our `lwe_hard_of_gapSVP` placeholder showed the
*missing* ingredient is not the math of LWE but an advantage calculus; building that
calculus is a self-contained, Mathlib-friendly task (filters + `ℝ≥0`).
**If true**: Unlocks machine-checkable game-hopping proofs for the whole catalog's
cryptography thread.
**If false**: Shows that eventual-domination ordering is too coarse for tight reductions,
motivating a concrete (non-asymptotic) advantage bound instead.

### Direction 5: Sharpness of the concrete-parameter frontier
**Hypothesis**: The pair (correctness budget `4mB < q`, security `0.292·n ≥ 128`) admits
a *Pareto frontier*: for fixed failure target there is a minimal `q` (hence minimal
ciphertext size `n·log q`) and our `n=512, q=2^14` point is within a factor 2 of it.
**Test**: Parameterize `coreSVPClassical` and the budget over `(n, log q, m)`, and
`decide`/`omega`-search the lattice of integer parameter tuples to minimize `n·log q`
subject to both constraints; prove minimality of the found tuple.
**Why now**: The key insight is that both constraints are already *decidable integer
inequalities* in this file (`params128_classical_secure_and_correct`), so the optimization
is a finite search Lean can certify, not a real-analysis estimate.
**If true**: Produces a verified, optimal 128-bit Regev parameter set — directly useful.
**If false (no clean frontier)**: Indicates the linear core-SVP model is too crude and a
refined BKZ cost model must enter the formalization.
