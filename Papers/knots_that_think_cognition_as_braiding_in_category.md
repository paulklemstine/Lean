# Computational Evidence — Knots That Think

This note records the pre-proof numerics that guided the two Lean files
`QuantumThoughtDimension.lean` and `CognitiveBraiding.lean`.

## 1. Quantum thought dimension `log |V(ζ)|`

Evaluation point: `ζ = e^{iπ/3} = 1/2 + (√3/2)·i`, a primitive **sixth** root of
unity, satisfying `ζ² = ζ − 1`, `ζ³ = −1`, `ζ⁶ = 1`, `ζ⁻¹ = 1 − ζ`.

We use the genuine Jones polynomials (Laurent polynomials in `t`):

| thought        | knot | Jones `V(t)`                    | `V(ζ)`   | `|V(ζ)|` | info `log|V|` |
|----------------|------|---------------------------------|----------|----------|----------------|
| linear/trivial | `0₁` | `1`                             | `1`      | `1`      | `0`            |
| creative       | `3₁` | `-t⁻⁴ + t⁻³ + t⁻¹`              | `-√3·i`  | `√3`     | `½ log 3 ≈ 0.549` |
| confused       | `4₁` | `t⁻² - t⁻¹ + 1 - t + t²`        | `-1`     | `1`      | `0`            |

Hand computations (all reproduced and *proved* in Lean):

* Trefoil: `ζ⁻⁴ = ζ²`, `ζ⁻³ = 1`, `ζ⁻¹ = 1 − ζ`, giving
  `V(ζ) = 1 − 2ζ = −√3·i`, so `|V| = √3`.
* Figure-eight: `ζ⁻² = −ζ`, `ζ² = ζ − 1`, giving `V(ζ) = −1`, so `|V| = 1`.

### Counterexample hunt
The brief conjectured the figure-eight ("confused thinking") is topologically
rich. **Counterexample found:** at `ζ` its information is exactly `0`, identical
to the trivial thought. This is not an artifact of the evaluation point — it is
the Lickorish–Millett phenomenon `|V_K(e^{iπ/3})| = (√3)^{d}`, with `d` the
`Z/3`-rank of `H₁` of the double branched cover:
* trefoil → `L(3,1)`, `H₁ = Z/3`, `d = 1` → `√3`;
* figure-eight → `L(5,2)`, `H₁ = Z/5`, no 3-torsion, `d = 0` → `1`.

The brief's alternate point `e^{2πi/3}` (primitive **cube** root) also collapses
the trefoil to `|V| = 1`; hence the faithful choice `e^{iπ/3}` is used.

## 2. Cognitive braiding — writhe and firing cost

A cognitive process is a braid word (list of signed generators). Writhe = sum of
signs. Small cases:

| process            | writhe | length | note                    |
|--------------------|--------|--------|-------------------------|
| `[]`               | `0`    | `0`    | base case               |
| `[σ₀, σ₀⁻¹]`       | `0`    | `2`    | charge 0, nonzero cost  |
| `[σ₀, σ₀, σ₀]`     | `3`    | `3`    | trefoil, tight          |
| `[σ₀,σ₀]++[σ₀⁻¹]`  | `1`    | `3`    | additivity: `2+(−1)=1`  |

Since each event moves the running sum by `±1`, `|writhe| ≤ length`; hence a
thought of net charge `k` needs `≥ k` firing events. The trefoil word shows the
bound is tight (`k = length = 3`).

## OEIS
No new integer sequence arises; the relevant constants are `√3` and `½ log 3`
(quantum dimension of the `Z/3` sector) and the golden ratio / Fibonacci numbers
appear only in the future directions (Fibonacci-anyon quantum dimension).
