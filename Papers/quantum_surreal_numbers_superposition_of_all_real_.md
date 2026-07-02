# Computational Evidence — Quantum Surreal Numbers

Model under test: a quantum surreal state is a finite superposition `|ψ⟩ = Σ aᵢ |Noᵢ⟩` with
surreal-number kets and **hyperreal** amplitudes `aᵢ ∈ ℝ*`. The Born weight of a branch is
`(ψ s)² / ‖ψ‖²`, and the **observed** probability is its standard part `st(·)`.

## 1. Small-case calculations

### The ε-test `|ψ⟩ = |0⟩ + ε|1⟩` (ε the canonical positive infinitesimal)

- `‖ψ‖² = 1² + ε² = 1 + ε²`.
- Exact Born weight of `|0⟩`: `1 / (1 + ε²)`.
- Exact Born weight of `|1⟩`: `ε² / (1 + ε²)`.
- Standard parts: `st(1/(1+ε²)) = 1/st(1+ε²) = 1/1 = 1`, and
  `st(ε²/(1+ε²)) = st(ε²)·st((1+ε²)⁻¹) = 0·1 = 0`.

So the observed distribution is `(1, 0)`: the infinitesimal branch is **unobservable**, while the
exact hyperreal weights sum to `1/(1+ε²) + ε²/(1+ε²) = 1`. This is the corrected version of the
mission "test", whose informal statement was internally inconsistent (it placed an *appreciable*
amplitude `1/√2` on the branch it then declared unobservable).

### Balanced state `|ψ⟩ = |0⟩ + |1⟩` (real amplitudes)

- `‖ψ‖² = 2`, Born weights `1/2, 1/2`, observed `1/2, 1/2`. Standard quantum statistics are
  recovered whenever all amplitudes are appreciable (the standard part is the identity on reals).

### Discrete lexicographic mirror (companion file)

For the catalog `LexRat` model with `n = 3`:

| event `A`        | `prob 3 A`      | `stdPart (prob 3 A)` |
|------------------|-----------------|----------------------|
| `∅`              | `(0, 0)`        | `0`                  |
| `{some 0}`       | `(0, 1)` = ε    | `0`                  |
| `{none}`         | `(1, -3)`       | `1`                  |
| `univ`           | `(1, 0)` = 1    | `1`                  |

The standard part collapses the infinitesimal measure to the Dirac measure on the reservoir
`none` — the discrete shadow of the quantum collapse.

## 2. Sequence / OEIS

No integer sequence is central to the claims; the content is order-theoretic (behaviour of
`st` on infinitesimals), so an OEIS search is not applicable.

## 3. Counterexample hunt (guard hypotheses)

- Dropping `normSq ψ ≠ 0` in `bornProb_sum_eq_one`: the empty state has `‖ψ‖² = 0` and the sum is
  over the empty support, giving `0 ≠ 1`. Hypothesis is load-bearing.
- Dropping `¬ Infinitesimal (normSq ψ)` in `observedProb_infinitesimal_eq_zero`: take
  `ψ = single s ε²  +  (a second branch making the total ~ ε⁴)`; then an infinitesimal amplitude
  can have observed probability `1`. The appreciability hypothesis is essential and cannot be
  removed. (This is why the theorem keeps it.)

## 4. Conclusion

All computed instances agree with the three formalized theorems. The standard-part functional is
the correct "observation" map: it preserves normalization and additivity while annihilating
infinitesimal probability, in both the continuous (hyperreal) and discrete (lexicographic) models.
