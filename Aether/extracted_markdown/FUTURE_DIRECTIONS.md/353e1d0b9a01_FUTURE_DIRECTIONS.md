# Future Directions — Self-Avoiding Walks and the Connective Constant

## Synthesis

This cycle closed the central *existence* gap left open by the catalog file
`Computation.SelfAvoidingWalk.Basic`. That file had done the genuinely hard
combinatorial work — it proved the SAW count `c_n = sawCount n` on ℤ² is
submultiplicative (`SAW.sawCount_submultiplicative`) and hence that `log c_n` is
subadditive (`SAW.logSawCount_subadditive`) — and it *defined* the connective
constant `μ = SAW.connectiveConstant`, but it never proved that `c_n^{1/n}`
actually converges to that definition. We supplied exactly that: the
Hammersley–Morton theorem `SAW.sawCount_rpow_tendsto`, obtained by feeding the
catalog's subadditivity into Mathlib's Fekete lemma (`Subadditive.tendsto_lim`)
and exponentiating. We also identified the catalog's indexed-infimum definition
with the Fekete limit (`SAW.connectiveConstant_eq_exp_lim`), turning the
definition into a *theorem-bearing* object. The structural insight is that once
submultiplicativity is in hand, the connective constant is not just *defined* but
*characterized* as `μ = inf_n c_n^{1/n} = lim_n c_n^{1/n}`, and — crucially for
computation — every finite count gives a rigorous one-sided bound
(`SAW.connectiveConstant_le_rpow` : `μ ≤ c_n^{1/n}`).

On the bounds side, we proved the clean two-sided trap is half-open: `2 ≤ μ`
(`SAW.two_le_connectiveConstant`) via an explicit injection of the `2^n`
north-east (monotone) walks into self-avoiding walks (`SAW.twoPow_le_sawCount`).
The combinatorial heart was that along a north-east walk the quantity `x+y`
strictly increases, so self-avoidance is automatic; the bits of the step string
are recovered from the per-step x-increments, giving injectivity. The matching
upper bound `μ ≤ 3` resisted a quick proof and is recorded as a conjecture
(`SAW.connectiveConstant_le_three`): it needs an injection of walks into
*non-reversing* step sequences (`c_n ≤ 4·3^{n-1}`), which is delicate because
"no immediate backtrack" is a local constraint that must be tracked along the
whole walk rather than read off a monotone coordinate.

The Critic's main finding: the proposed closed form `μ = (2+√2)/2 ≈ 1.707` in the
research brief is *false* for ℤ². It conflates two different objects. The
Nienhuis (1982) / Duminil-Copin–Smirnov (2012) constant `√(2+√2) ≈ 1.848` is the
*hexagonal*-lattice connective constant (formalized algebraically in the catalog
as `SAW.nienhuis_mu`), while the ℤ² constant treated here has no known closed
form and satisfies `2 ≤ μ_{ℤ²} ≤ 3` with numerical value `≈ 2.638`. We therefore
proved existence + rigorous bounds rather than a spurious exact value, and the
documentation now records this correction.

## Results Summary

- `SAW.zero_le_logSawCount`: proved — `log c_n ≥ 0`, the bounded-below input to Fekete.
- `SAW.logSawCount_bddBelow`: proved — the Fekete quotients `(log c_n)/n` are bounded below by 0.
- `SAW.sawCount_log_div_tendsto`: proved — Fekete's lemma for SAWs: `(log c_n)/n` converges (existence statement).
- `SAW.zero_le_lim`: proved — the Fekete limit is nonnegative.
- `SAW.connectiveConstant_eq_exp_lim`: proved — the catalog definition `μ` equals `exp` of the Fekete limit (definition ⇒ characterization).
- `SAW.sawCount_rpow_tendsto`: proved — **Hammersley–Morton**: `c_n^{1/n} → μ`, the connective constant exists as the limit of root-counts.
- `SAW.connectiveConstant_le_rpow`: proved — `μ ≤ c_n^{1/n}` for every `n ≥ 1`: every finite count is a rigorous upper bound on `μ`.
- `SAW.one_le_connectiveConstant`: proved — `1 ≤ μ`.
- `SAW.twoPow_le_sawCount`: proved — `2^n ≤ c_n`, via injecting the north-east walks.
- `SAW.neWalkPath_start / _step_fst / _step_snd / _coord_sum / _adj / _injective / _inj_in_s`: proved — the supporting facts for the north-east injection.
- `SAW.two_le_connectiveConstant`: proved — **`2 ≤ μ`**, the standard lower bound.
- `SAW.connectiveConstant_le_three`: conjecture (sorry) — `μ ≤ 3`, the matching non-reversal upper bound.

## Research Directions

### Direction 1: Close the upper bound `μ ≤ 3`
**Hypothesis**: `SAW.connectiveConstant_le_three` holds, because `c_n ≤ 4·3^{n-1}`
for all `n ≥ 1` (the first step has 4 choices, every later step has at most 3
since immediate reversal is forbidden by self-avoidance).
**Test**: Build an injection `LatticeWalk n ↪ (Fin 1 → Fin 4) × (Fin (n-1) → Fin 3)`
sending a walk to its first directed step together with, at each later step, the
chosen direction encoded relative to the 3 non-reversing options; then
`c_n ≤ 4·3^{n-1}`, so `(c_n)^{1/n} → μ` forces `μ ≤ 3`. The disproof route is a
single `n` with an explicit walk count exceeding `4·3^{n-1}` (there is none).
**Why now**: This cycle already supplies `SAW.connectiveConstant_le_rpow` and the
exponentiation machinery; only the combinatorial counting bound is missing, and
the north-east injection in `SAW.twoPow_le_sawCount` is a working template for the
"encode a walk as a step string" pattern. The key insight is that the per-step
increment lemmas (`neWalkPath_step_fst/_snd`) generalize to "the last step
determines the forbidden direction," turning a global constraint into a local one.
**If true**: `μ ∈ [2,3]` becomes a fully formal theorem, the first rigorous
two-sided enclosure of the ℤ² connective constant in this library.
**If false**: it would mean a walk can revisit-avoidingly backtrack in a way the
naive count misses — i.e. our model of `Z2Adj`/`LatticeWalk` is subtly wrong,
which would be a far more important discovery than the bound itself.

### Direction 2: The Hammersley–Welsh sub-exponential correction
**Hypothesis**: There is a constant `C` with `c_n ≤ exp(C·√n)·μ^n` for all `n`
(Hammersley–Welsh), strengthening submultiplicativity to a quantitative rate.
**Test**: Formalize the bridge generating function using the catalog's `Bridge`
structure and `bridgeCount`, prove the bridge connective constant equals `μ`, and
combine Hammersley's bridge decomposition with the partition-function bound.
A disproof would be a sequence forcing a `√n·log n` correction.
**Why now**: The catalog already defines `Bridge` and `bridgeCount`, and this
cycle gives the convergence framework those counts plug into. The key insight is
that bridges are *super*multiplicative (`b_{m+n} ≥ b_m·b_n`), so Fekete applies
"from below," yielding a lower approximating sequence `b_n^{1/n} ↑ μ` that
complements our upper sequence `c_n^{1/n} ↓ μ`.
**If true**: it pins `μ` between two monotone computable sequences, enabling
rigorous numerical interval estimates inside Lean.
**If false**: the bridge/partition relationship is more subtle than the classical
argument and the lower approximation must come from elsewhere.

### Direction 3: Lower bridge sequence and two-sided monotone enclosure
**Hypothesis**: `bridgeCount` is supermultiplicative and `bridgeCount n ^ (1/n)`
increases to `μ`, so `bridgeCount n ^ (1/n) ≤ μ ≤ sawCount n ^ (1/n)` for all `n`.
**Test**: Prove `bridgeCount (m+n) ≥ bridgeCount m * bridgeCount n` by
concatenating bridges (the concatenation of two bridges is a bridge), apply the
*super*additive form of Fekete to `log bridgeCount`, and pair it with this
cycle's `SAW.connectiveConstant_le_rpow`.
**Why now**: We now have the exact-`μ` characterization
(`connectiveConstant_eq_exp_lim`) needed to *identify* the bridge limit with `μ`,
not just with "some limit." The key insight is that the same Fekete engine runs in
both directions; only the inequality flips, so the proof of
`sawCount_log_div_tendsto` is a reusable blueprint.
**If true**: the first formal *sandwich* `[bridge_n, c_n]` trapping `μ`, directly
usable for verified numerics.
**If false**: bridge concatenation fails to be self-avoiding at the seam under our
`Z2Adj`, exposing a gap between the textbook picture and the formal model.

### Direction 4: Generating function radius of convergence equals `1/μ`
**Hypothesis**: The SAW generating function `G(x) = Σ c_n x^n` has radius of
convergence exactly `1/μ`.
**Test**: Apply the Cauchy–Hadamard theorem to the sequence `c_n` using this
cycle's `sawCount_rpow_tendsto` (which gives `limsup c_n^{1/n} = μ` for free,
since the limit exists). Falsifiable by exhibiting convergence at some `x > 1/μ`.
**Why now**: Cauchy–Hadamard needs precisely `limsup c_n^{1/n}`, and we just
proved the full limit exists and equals `μ`; Mathlib has the radius-of-convergence
API (`FormalMultilinearSeries.radius` / `ENNReal` limsup formulas). The key
insight is that the connective constant is *defined* to be this growth rate, so
the analytic statement is a corollary of the combinatorial one we proved.
**If true**: it bridges the combinatorial constant to complex analysis, the gateway
to critical-exponent conjectures (`SAW.nienhuis_gamma`, `SAW.flory_nu`).
**If false**: `c_n` would have to oscillate so wildly that `limsup ≠ lim`,
contradicting `sawCount_rpow_tendsto`; such a failure would indicate a bug in the
convergence proof.

### Direction 5: Hexagonal lattice — discharge `duminilCopin_smirnov`
**Hypothesis**: `SAW.hexConnectiveConstant = SAW.nienhuis_mu = √(2+√2)` (the
catalog's currently-`sorry`ed deep theorem).
**Test**: This is the parafermionic-observable proof of Duminil-Copin–Smirnov.
A tractable first milestone is to replicate this cycle's pipeline on the hexagonal
counts: prove `hexSawCount` submultiplicative, derive existence of
`hexConnectiveConstant` via Fekete (mirroring `sawCount_rpow_tendsto`), and then
prove the two-sided bounds `√2 ≤ μ_hex ≤ 2` (each hexagonal vertex has degree 3).
**Why now**: The algebraic identity `μ_hex⁴ − 4μ_hex² + 2 = 0`
(`SAW.nienhuis_algebraic_identity`) is already proved, and this cycle provides a
ready-made existence template. The key insight is that *existence* of `μ_hex` and
its *value* are independent problems: existence is pure Fekete (now routine here),
so the `sorry` can be split into an easy existence lemma plus the hard
value identity.
**If true**: it removes the last `sorry` from the SAW catalog and connects a
formal connective constant to its exact algebraic value.
**If false** (i.e. existence-template port fails): the hexagonal `HexWalk`/`HexAdj`
model does not support the same submultiplicativity argument, flagging an
asymmetry between the ℤ² and hexagonal formalizations that must be repaired first.
