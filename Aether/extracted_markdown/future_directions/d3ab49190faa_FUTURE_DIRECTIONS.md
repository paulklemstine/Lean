# Future Directions — Unique Games, MAX-CUT, and SDP Gaps

This cycle established the file `Cryptography/UniqueGamesMaxCut.lean`, the unconditional
combinatorial core of unique 2-prover label-cover games. The directions below extend that
skeleton toward the quantitative theory of inapproximability.

## Synthesis

This cycle built, from scratch, the unconditional skeleton of the Unique Games Conjecture
(UGC) as a self-contained Lean development. A *unique game* is modelled as a list of edges
`(u, v, π)` over a finite vertex type `V` with label alphabet `Fin k`, where the constraint
`π ∈ S_k` is a bijection (a *projection* / *unique* constraint). The central discovery is
that the entire **soundness floor `value ≥ 1/k`** collapses to a *single counting bijection*
plus a pigeonhole argument — no probability theory is required, because the relevant
expectation is computed *exactly*. Concretely, `edge_constraint_card` exhibits an explicit
equiv `Fin k × {a // π (a u) = a v} ≃ (V → Fin k)` (freeing the coordinate `v` via
`Function.update`), which shows a no-self-loop constraint is satisfied by *exactly* a `1/k`
fraction of all assignments. Summed over edges (`k_mul_sum_satCount`, by list induction)
this gives `k · Σ_a satCount = |G| · k^{|V|}` exactly, and the floor `|G| ≤ k · satCount a`
for some `a` (`exists_assignment_sat_ge`) is then pure pigeonhole.

The structural insight that *survived* and tied everything together is that **the MAX-CUT
1/2 bound is literally the `1/k` floor at `k = 2`**. Encoding each undirected edge as a
swap-constraint on `Fin 2` (`maxCutGame`), the predicate "edge satisfied" becomes exactly
"edge cut" (`maxCut_sat_iff_cut`, since `Equiv.swap 0 1` is the flip on `Fin 2`), so the
classical greedy/probabilistic MAX-CUT guarantee is recovered as a one-line specialization
(`maxCut_exists_cut_half`). On the completeness side, `trivialGame_perfect` shows an
equality CSP (all-identity permutations) is perfectly satisfied by any constant assignment,
giving the `value = 1` endpoint. Together these pin the two endpoints — completeness `1` and
soundness floor `1/k` — between which the conjectured UGC hardness gap lives.

What was deliberately *not* attempted (and why) shapes the next cycle. We avoided a direct
`k^{|V|-1}` count because ℕ subtraction entangles the exponent arithmetic; the multiplicative
form `k · #sat = k^{|V|}` sidesteps this entirely and is the lesson to carry forward. The
genuinely open content now lives one layer up: (1) *tightness* of the floor (a concentration,
not a counting, statement); (2) the SDP relaxation and its integrality gap; (3) the
Goemans–Williamson rounding constant; (4) parallel repetition; (5) dictatorship tests. Each
is seeded below with a precise, falsifiable target.

## Results Summary

- `edge_sat_card`: proved — exactly `k` of the `k²` label pairs satisfy a permutation
  constraint (the per-edge `1/k` random-assignment probability).
- `edge_constraint_card`: proved — a no-self-loop unique constraint is satisfied by exactly a
  `1/k` fraction of all assignments (`k · #sat = k^{|V|}`), via an explicit coordinate-freeing
  bijection; this is the technical heart of the file.
- `k_mul_sum_satCount`: proved — the exact double-count `k · Σ_a satCount G a = |G| · k^{|V|}`
  for any no-self-loop game, the exact expectation `|G|/k`.
- `exists_assignment_sat_ge`: proved — the soundness floor in integer form: some assignment
  satisfies at least `|G|/k` edges.
- `exists_value_ge_inv_k`: proved — the soundness floor in value form: every no-self-loop game
  has `value ≥ 1/k`.
- `maxCut_sat_iff_cut`: proved — a swap-constraint edge is satisfied iff its endpoints get
  different labels (the MAX-CUT bridge).
- `maxCut_exists_cut_half`: proved — every loopless graph has a cut crossing at least half the
  edges, recovered as the `k = 2` case of the unique-games floor.
- `trivialGame_perfect`: proved — an equality CSP is perfectly satisfiable by any constant
  assignment (the completeness `value = 1` endpoint).
- `tightness_of_floor` (random games saturate `1/k`): conjecture — see Direction 1.
- `value_le_sdpValue` (integral ⊆ SDP feasible): conjecture — see Direction 2.
- `gw_rounding_inequality` (`θ/π ≥ α · (1−cos θ)/2`): conjecture — see Direction 3.
- `value_tensor_ge_pow` (`value(G^{⊗t}) ≥ value(G)^t`): conjecture — see Direction 4.

## Research Directions

### Direction 1: Tightness of the `1/k` floor — random games saturate it
**Hypothesis**: For random unique games on `n` vertices with `m = ω(n log k)` independent
uniform-permutation edges, `value` concentrates at `(1 + o(1))/k` with high probability; in
particular `value < (1 + ε)/k` w.h.p. for any fixed `ε > 0`.
**Test**: Formalize the expectation `E[satCount a] = m/k` (immediate from
`k_mul_sum_satCount`) and add a bounded-difference / Azuma concentration over the independent
edge permutations; refute by exhibiting a family whose value stays bounded away from `1/k`.
**Why now**: The expectation half is *already a finished theorem* (`k_mul_sum_satCount`); only
the deviation half remains, and Mathlib's probability library now has the bounded-difference
machinery. The key insight is that the floor is tight precisely because our double-count is an
*equality*, so the remaining content is pure concentration, not a new counting identity.
**If true**: Confirms `1/k` is the exact soundness threshold and gives a machine-checked
integrality-style gap instance.
**If false**: Would reveal an unexpected structural obstruction forcing random games above the
mean — a genuinely surprising combinatorial phenomenon.

### Direction 2: A formal SDP relaxation and the integrality-gap object
**Hypothesis**: Replacing each label by a unit vector `x_{v,i} ∈ ℝ^d` and relaxing `value` to
`sdpValue` (a sup over feasible vector solutions) yields `value G ≤ sdpValue G` for every
game, hence a well-defined integrality gap `gap G = sdpValue G / value G ≥ 1`.
**Test**: Define `sdpValue` over `EuclideanSpace ℝ (Fin d)`, embed each integral assignment as
standard basis vectors, and prove `value ≤ sdpValue` by exhibiting the embedding as a feasible
SDP point; refute by finding a constraint whose integral optimum exceeds every vector solution.
**Why now**: The MAX-CUT bridge (`maxCut_sat_iff_cut`) already expresses cuts as unique games
over the *existing* `satCount`/`maxCutGame` definitions, so the SDP layer bolts directly onto
this file. The key insight is that the *gap*, not NP-hardness, is the formalizable heart of
UGC inapproximability, and `gap ≥ 1` follows from a pure embedding.
**If true**: Opens the door to the Goemans–Williamson constant (Direction 3) as a *provable*
upper bound on the gap.
**If false**: Means the relaxation was mis-stated (e.g. wrong feasibility constraints), which
would itself sharpen the correct definition of the SDP.

### Direction 3: Goemans–Williamson rounding lower bound for MAX-CUT
**Hypothesis**: A random hyperplane cuts an SDP edge of inner product `cos θ` with probability
`θ/π`, and the inequality `θ/π ≥ α_GW · (1 − cos θ)/2` holds for all `θ ∈ [0, π]` with
`α_GW ≈ 0.878`, yielding the `0.878`-approximation hierarchy `1/2 ≤ α_GW ≤ sdp`.
**Test**: Reduce the whole argument to the single-variable inequality via `Real.arccos`,
monotonicity, and one critical point; discharge it with Mathlib's derivative API. Refute by
finding `θ` violating the bound for the claimed constant.
**Why now**: `maxCut_exists_cut_half` already certifies the trivial `1/2` endpoint of the
hierarchy, and Mathlib now has `Real.arccos`, `Real.pi`, and integral/derivative machinery
sufficient to discharge the rounding inequality. The key insight is that the entire
analytic content compresses into one elementary calculus fact about `θ/π` versus
`(1 − cos θ)/2`.
**If true**: Yields a strict, machine-checked `1/2 ≤ 0.878 ≤ sdp` chain of MAX-CUT guarantees.
**If false**: Would pin down the *exact* worst-case angle, refining the constant itself.

### Direction 4: Parallel repetition and label-amplification of the gap
**Hypothesis**: For the `t`-fold tensor product `G^{⊗t}` (labels `Fin (k^t)`, product
constraints), the easy floor `value(G^{⊗t}) ≥ value(G)^t` holds, while the deep decay
`value(G^{⊗t}) ≤ value(G)^{Ω(t)}` (Raz/Rao for projection games) is the hard target.
**Test**: Define `G^{⊗t}` as a one-line extension of `UEdge` (coordinatewise permutations),
prove the `≥` direction by tensoring an optimal assignment, and stress-test the `≤` direction
numerically before attempting it. Refute the easy direction by a product whose value drops
below `value(G)^t`.
**Why now**: Our `UEdge` structure and `edge_sat_card` permutation count *tensorize
coordinatewise*, so the per-edge count of the product game factorizes as `k^t` for free. The
key insight is that unique games are exactly projection games, the regime where parallel
repetition is cleanest.
**If true**: Provides a machine-checked anchor (`value(G^{⊗t}) ≥ value(G)^t`) against which
the conjectured strict decay can be tested.
**If false**: A failure of even the easy `≥` direction would expose a flaw in the tensor
construction, correcting the definition of product games.

### Direction 5: Dictatorship tests and the long-code soundness threshold
**Hypothesis**: For functions `f : (Fin k → Bool) → ℝ` on the long code, the noise test's
acceptance probability equals `Σ_S f̂(S)² ρ^{|S|}`, dictators achieve `(1 + ρ)/2`, and
low-influence functions tend to `1/2` — instantiating the completeness/soundness gap `[1−ε, ε]`.
**Test**: Formalize the discrete Fourier expansion (`Σ_S f̂(S)² ρ^{|S|}`) via Parseval on the
Boolean cube and evaluate it on a dictator; refute by computing a dictator's acceptance and
finding it `≠ (1+ρ)/2`.
**Why now**: Mathlib's Boolean Fourier / character-sum tools are maturing, and
`trivialGame_perfect` already supplies the `value = 1` completeness endpoint the dictatorship
test must reproduce. The key insight is that the Fourier expansion is the analytic *bridge*
connecting this file's combinatorial `satCount` to UGC-hardness reductions.
**If true**: Connects the combinatorial core here to the analytic side of UGC hardness.
**If false**: Would localize the error in the Fourier/influence formalization, sharpening the
correct test definition.
