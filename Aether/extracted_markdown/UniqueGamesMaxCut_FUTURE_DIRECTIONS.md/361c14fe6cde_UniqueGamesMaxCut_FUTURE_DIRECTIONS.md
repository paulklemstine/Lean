# Future Directions — Unique Games, MAX-CUT, and SDP Gaps

The file `Cryptography/UniqueGamesMaxCut.lean` formalizes the combinatorial core of
unique 2-prover label-cover games and pins down the *unconditional* facts that frame the
Unique Games Conjecture (UGC): the per-edge `1/k` random-assignment probability
(`edge_sat_card`), the resulting soundness floor `value ≥ 1/k`
(`exists_assignment_sat_ge`, `exists_value_ge_inv_k`), the MAX-CUT bridge
(`maxCut_sat_iff_cut`, `maxCut_exists_cut_half`), and the completeness side
(`trivialGame_perfect`). These are the rigorous endpoints between which the UGC's hardness
gap lives. The directions below extend this skeleton toward the quantitative theory of
inapproximability. Each is testable, falsifiable, and (with effort) formalizable.

## Direction 1 — Tightness of the `1/k` floor: random games saturate it

The theorem `exists_assignment_sat_ge` proves `value ≥ 1/k` for *every* no-self-loop game.
The natural converse is that this bound is asymptotically *tight*: for random unique games
(each edge an independent uniform permutation of `Fin k`) on `n` vertices with `m = ω(n log k)`
edges, the value concentrates at `(1 + o(1))/k` with high probability. The key insight is
that the `edge_sat_card` double-count already gives the expectation `m/k` exactly, so the
remaining content is purely a *concentration* statement (a Chernoff/Azuma bound over the
independent edge permutations), not a new counting identity. **Why now?** The expectation
half is already a finished theorem in this file; only the deviation half remains, and
Mathlib's growing probability library (`MeasureTheory`, bounded-difference inequalities)
makes the concentration step feasible without building martingale theory from scratch.

## Direction 2 — A formal SDP relaxation and the integrality-gap object

Introduce the basic semidefinite relaxation: replace each label assignment by unit vectors
`x_{v,i} ∈ ℝ^d` and relax `value` to `sdpValue := max Σ_e ⟨vector constraints⟩` over feasible
vector solutions. Define the *integrality gap* `gap(G) := sdpValue G / value G` and prove the
trivial direction `value G ≤ sdpValue G` (every integral solution is an SDP solution). The key
insight is that the gap, not NP-hardness, is the formalizable heart of UGC-based
inapproximability: the conjecture predicts that for MAX-CUT the worst-case gap equals the
Goemans–Williamson constant `α_GW ≈ 0.878`, and `gap ≥ 1` is already provable from the
embedding `value ≤ sdpValue`. **Why now?** The MAX-CUT bridge (`maxCut_sat_iff_cut`) already
expresses cuts as a unique game in this file, so the SDP layer can be bolted directly onto the
existing `satCount` and `maxCutGame` definitions rather than re-deriving the CSP from scratch.

## Direction 3 — Goemans–Williamson rounding lower bound for MAX-CUT

Building on Direction 2, formalize the hyperplane-rounding analysis: a random hyperplane cuts
an SDP edge of inner product `cos θ` with probability `θ/π`, giving the `0.878`-approximation.
The key insight is that the whole argument reduces to the single-variable inequality
`θ/π ≥ α_GW · (1 - cos θ)/2` for all `θ ∈ [0, π]`, which is an elementary calculus fact
(`Real.arccos`, monotonicity, one critical point) entirely inside Mathlib's analysis API.
Combined with `maxCut_exists_cut_half` (the `1/2` floor proved here) this yields a strict
hierarchy `1/2 ≤ 0.878 ≤ sdp` of MAX-CUT guarantees. **Why now?** `maxCut_exists_cut_half`
already certifies the trivial endpoint, and Mathlib now has `Real.arccos`, `Real.pi`, and
integral/derivative machinery sufficient to discharge the rounding inequality, which two years
ago would have required substantial real-analysis scaffolding.

## Direction 4 — Parallel repetition and label-amplification of the gap

Define the `t`-fold tensor product `G^{⊗t}` of a unique game (labels `Fin (k^t)`, edges the
product constraints) and prove the soundness floor scales as expected:
`value(G^{⊗t}) ≥ (value G)^t` is the easy direction, with the conjectured strict decay
`value(G^{⊗t}) ≤ value(G)^{Ω(t)}` (Raz's parallel repetition / Rao's theorem for projection
games) as the deep target. The key insight is that unique games are *projection games*, the
exact regime where parallel repetition is cleanest, and the `edge_sat_card` permutation
structure tensorizes coordinatewise so the per-edge count of the product game factorizes as
`(k^t)`. **Why now?** The product construction is a one-line extension of the `UniqueGame`
structure already defined here, and proving the easy `≥` direction immediately gives a
falsifiable, machine-checked anchor against which the hard decay bound can later be tested.

## Direction 5 — Dictatorship tests and the long-code soundness threshold

Formalize the long-code / dictatorship-test viewpoint: an assignment over the hypercube
`Fin k → Bool`, with "dictator" functions (value `1`) versus functions with no influential
coordinate (value `→ 1/2` under noise). Prove the discrete Fourier identity that the test's
acceptance probability is `Σ_S \hat{f}(S)^2 ρ^{|S|}` and that dictators achieve `(1+ρ)/2`. The
key insight is that this Fourier expansion is the *bridge* connecting the combinatorial
`satCount` of this file to the analytic UGC-hardness reductions: the gap between dictators and
low-influence functions is exactly the completeness/soundness gap `[1-ε, ε]` instantiated on
the long code. **Why now?** Mathlib has Boolean Fourier analysis on `ZMod 2`-cubes and
`Finset`-indexed character sums maturing, so the Parseval/Fourier step is within reach, and the
`trivialGame_perfect` completeness witness in this file already supplies the `value = 1`
endpoint that the dictatorship test must reproduce.
