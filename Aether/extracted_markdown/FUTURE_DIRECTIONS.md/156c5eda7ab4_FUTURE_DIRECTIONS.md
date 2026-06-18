# Future Directions — Quantum Entanglement Monogamy (CKW)

## Synthesis

This cycle laid down a *self-contained, eigenvalue-free* formalization of qubit
concurrence and the Coffman–Kundu–Wootters (CKW) monogamy inequality in
`CKWMonogamy.lean`. The architecture is deliberately layered so the next team can
build upward without touching the foundations:

1. **One-qubit layer** (`Qubit`, `Qubit.tangle`): the one-tangle `τ = 4 det ρ` is
   proven to be a genuine entanglement measure valued in `[0,1]`, vanishing exactly
   on pure reductions (`tangle_nonneg`, `tangle_le_one`, `tangle_eq_zero_iff`).
2. **Two-qubit layer** (`Xconc`): a closed form for the Wootters concurrence of an
   X-state, with two evaluation lemmas (`Xconc_eq_zero`, `Xconc_inner`) that sidestep
   the `√(eig(ρρ̃))` spectral calculus entirely.
3. **Three-qubit layer** (`ThreeQubitReal`): a real-amplitude pure state whose
   single-qubit reduction `reducedA` is the *genuine partial trace* (its PSD field is
   literally the 4-term Cauchy–Schwarz inequality), giving the always-valid bound
   `0 ≤ C²(A|BC) ≤ 1` (`onetangle_nonneg`, `onetangle_le_one`).
4. **Flagship theorems**: the two SLOCC classes of genuine 3-qubit entanglement bracket
   the inequality — GHZ realizes a *strict* gap equal to the three-tangle `4a²b²`
   (`ghz_monogamy`, `ghz_threetangle`), while W *saturates* it
   (`w_monogamy_tight`, `8/9 = 4/9 + 4/9`).

## Results Summary

| Theorem | Statement |
|---|---|
| `Qubit.tangle_nonneg` / `tangle_le_one` | `0 ≤ τ(ρ) ≤ 1` |
| `Qubit.tangle_eq_zero_iff` | `τ = 0 ↔ ρ` pure |
| `onetangle_nonneg` / `onetangle_le_one` | `C²(A|BC) ∈ [0,1]` for every real 3-qubit pure state |
| `ghz_monogamy` | `C²(A|B)+C²(A|C) ≤ C²(A|BC)` for GHZ, gap `4a²b²` |
| `ghz_threetangle` | residual `= 4a²b²` (the three-tangle) |
| `w_monogamy_tight` | CKW saturated for W: `4/9 + 4/9 = 8/9` |

The Adversarial-Ground-Truth pass also *killed two hypotheses*: the `0 ≤ a, 0 ≤ b`
assumptions on the GHZ family turned out to be unused (amplitudes enter only squared),
so the stated GHZ results are strictly more general than the textbook version.

---

## Direction 1 — A general three-tangle identity for real amplitudes

**Conjecture.** For *every* `ThreeQubitReal` state, define the three-tangle by Cayley's
hyperdeterminant `τ₃ := 4·|d₁ − 2d₂ + 4d₃|` in the amplitudes. Then
`onetangle s = concAB s ^ 2 + concAC s ^ 2 + τ₃ s`, so CKW holds *universally* (not just
on GHZ/W) with the gap exactly `τ₃ ≥ 0`.

**The key insight is** that the monogamy *gap* is not an inequality slack but an
honest polynomial invariant — the hyperdeterminant — whose nonnegativity is automatic
because it is an absolute value, turning a hard spectral inequality into a `ring`
identity plus `abs_nonneg`.

**Why now?** The partial-trace scaffolding (`reducedA`, `concAB`, `concAC`) and the
X-state evaluation lemmas already exist and were validated on both SLOCC extremes;
the only missing piece is checking the polynomial identity, which `polyrith`/`ring`
can attack directly on the eight real amplitudes. **Falsifiable:** plug in a random
real state (e.g. amplitudes `1,2,3,4,5,6,7,8` normalized) and compare both sides by
`norm_num`; any mismatch refutes the chosen `d₁,d₂,d₃` combination.

## Direction 2 — Failure of monogamy for the linear-entropy "tangle" of qutrits

**Conjecture.** Replacing qubits by qutrits, the naive one-tangle
`τ_d := (d/(d−1))(1 − Tr ρ_A²)` does **not** satisfy
`τ(A|B) + τ(A|C) ≤ τ(A|BC)`; there is an explicit `3×3×3` pure state violating it.

**The key insight is** that monogamy is a *qubit* phenomenon tied to the squared
concurrence specifically; the linear entropy is the "wrong" power and over-counts
pairwise correlations once the local dimension exceeds two.

**Why now?** Our `Qubit`/`tangle` bound proofs are dimension-agnostic in spirit
(AM–GM + Cauchy–Schwarz), so generalizing the *definition* to `d=3` is mechanical, and
the adversarial mandate makes a clean counterexample as valuable as a theorem.
**Falsifiable:** a single concrete qutrit state with `τ(A|B)+τ(A|C) > τ(A|BC)` settles it.

## Direction 3 — Tightness ⇔ W-class characterization

**Conjecture.** Among normalized `ThreeQubitReal` states, `ghz_threetangle = 0`
(i.e. CKW is saturated) holds *iff* the state is in the W SLOCC class (the
hyperdeterminant vanishes but the state is not biseparable).

**The key insight is** that the monogamy inequality is *equality-detecting*: its slack
is a complete invariant separating the GHZ class (slack > 0) from the W class
(slack = 0), so a purely inequality-flavored statement secretly classifies entanglement
type.

**Why now?** With `w_monogamy_tight` and `ghz_threetangle` proven, both directions of
the iff have witnessed endpoints; formalizing the hyperdeterminant (Direction 1) makes
the "iff" statement expressible. **Falsifiable:** exhibit a non-W state with zero gap,
or a W-class state with positive gap.

## Direction 4 — The `n`-qubit CKW chain `Σ_{j≥2} C²(A|j) ≤ C²(A|rest)`

**Conjecture.** Extend `ThreeQubitReal` to `NQubitReal n` with `reducedA : Qubit`
defined by the same partial-trace formula; then `onetangle_nonneg/le_one` generalize
verbatim, and the full Osborne–Verstraete `n`-party monogamy chain holds, with
`reducedA` reused unchanged.

**The key insight is** that the *right-hand side* of CKW (`C²(A|rest) = 4 det ρ_A`)
depends only on the single-qubit reduction, so its `[0,1]` bound is genuinely
`n`-independent — only the left-hand pairwise sum needs new combinatorics.

**Why now?** `reducedA`'s PSD proof is a 4-term Cauchy–Schwarz that scales to a
`2^{n-1}`-term Cauchy–Schwarz with the *same* `nlinarith` skeleton (or `inner_mul_le_norm_mul_norm`);
the abstraction boundary is already in place. **Falsifiable:** the `n=4` GHZ/W analogues
give concrete numeric checks of the chain.

## Direction 5 — Cross-domain bridge: monogamy as a tropical/min-plus inequality

**Conjecture.** Under the substitution `C² ↦ −log`, the CKW inequality
`C²(A|B) + C²(A|C) ≤ C²(A|BC)` becomes a *superadditivity* statement that is an
instance of a min-plus (tropical) triangle inequality on an "entanglement metric"
`d(A,B) := −log C²(A|B)`, linking this file to the catalog's `Tropical.MinPlusAlgebra`
and `Tropical.MutualInformation`.

**The key insight is** that monogamy is a hidden *metric/ultrametric* constraint:
the `max`/`min` structure already visible in `Xconc` (it is literally a tropical
`2·max(0, …)`) suggests the entire theory is a shadow of idempotent-semiring geometry.

**Why now?** This file *was tagged* in the Tropical domain and `Xconc` is already a
`max`-expression; bridging to `Tropical.MinPlusAlgebra` would be the catalog's first
quantum-information ↔ tropical-geometry connector. **Falsifiable:** check whether
`d(A,B)` actually satisfies the (ultra)metric/min-plus triangle inequality on the GHZ
and W families — if the W equality case breaks the tropical inequality, the bridge
fails and the analogy is only formal.
