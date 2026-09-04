# Computational evidence — Bhattacharyya angle sums vs. Fisher–Rao length

All numbers below come from double-precision floating point exploration in Python.
They are *not* machine-checked; the machine-checked statements are the Lean theorems in
`Catalog/Pythagorean/`. The purpose of this note is only to record that the conjecture
was tested numerically before (and while) it was formalised.

## 1. Test curve

On the 3-point simplex take the `C¹` (indeed real-analytic) curve

```
a(t) = (1 + 0.5 sin t,  1 + 0.3 cos 2t,  0.8 + 0.4 sin 3t),   p(t) = a(t)/‖a(t)‖₁ ,  t ∈ [0,2].
```

Its Fisher–Rao speed is `√(∑ᵢ ṗᵢ²/pᵢ)` (analytic derivative used), and the reference
length obtained by composite Simpson with 2·10⁶ panels is

```
L = fisherRaoLength p v 0 2 = 0.98118914652690…
```

## 2. Partition sums `∑ₖ 2 arccos BC(p_{t_k}, p_{t_{k+1}})`

Uniform partitions of `[0,2]` into `N` pieces, mesh `h = 2/N`.  The angle was evaluated in
the numerically stable form `2 arcsin(chord/2)` with `chord = ‖√p_{t_k} − √p_{t_{k+1}}‖₂`
(mathematically equal to `arccos BC`, cf. `FisherRao.chord_eq_two_mul_sin_half_arccos`).

| N | h | ∑ₖ 2·angle | L − sum | (L − sum)/h² |
|---:|---:|---:|---:|---:|
| 4 | 0.5000 | 0.945096631512 | 3.61e−02 | 0.144 |
| 8 | 0.2500 | 0.959344983239 | 2.18e−02 | 0.350 |
| 16 | 0.1250 | 0.970251737811 | 1.09e−02 | 0.700 |
| 32 | 0.0625 | 0.980604529329 | 5.85e−04 | 0.150 |
| 128 | 0.01562 | 0.980991901222 | 1.97e−04 | 0.808 |
| 512 | 0.00391 | 0.981186975512 | 2.17e−06 | 0.142 |
| 2048 | 0.000977 | 0.981188296955 | 8.50e−07 | 0.891 |
| 4096 | 0.000488 | 0.981189124438 | 2.21e−08 | 0.0926 |
| 8192 | 0.000244 | 0.981189140956 | 5.57e−09 | 0.0935 |
| 16384 | 0.000122 | 0.981189145086 | 1.44e−09 | 0.0967 |

Observations, all consistent with the formalised theorems:

* every sum is **below** `L` — this is `sum_two_arccos_bhattacharyya_le_fisherRaoLength`
  (each step obeys the geodesic bound `2 arccos BC ≤ length`);
* the sums increase towards `L` and the deficit tends to `0` — this is
  `riemann_convergence_sum_two_arccos_bhattacharyya`;
* in the asymptotic regime (`N ≥ 4096`) the deficit divided by `h²` is essentially
  constant (`≈ 0.093`), i.e. the deficit is `Θ(h²)`, matching the per-step error
  `O(h³)` predicted by the local expansion `2 arccos BC(p_s,p_t) = ∫ₛᵗ speed + O((t−s)³)`
  for a `C²` curve.  (The pre-asymptotic rows oscillate; no rate is claimed there.)

## 3. Geodesic realisation

For `p = (0.2, 0.3, 0.5)`, `q = (0.5, 0.1, 0.4)`: `BC(p,q) = cos θ`, `2θ = 0.7157320173110`.
The great-circle arc `x(t) = (sin((1−t)θ)√p + sin(tθ)√q)/sin θ`, `P(t) = x(t)²`, has
numerically constant Fisher–Rao speed (`0.71573201726` at the sample point `t = 0.37`) and
Simpson-computed length `0.7157320171` over `[0,1]` — i.e. `2θ`, matching the proved
identity `FisherRao.Geodesic.fisherRaoLength_eq`.

## 4. Counterexample hunt

Random pairs of positive probability vectors on 2–6 points (10⁴ samples, not recorded here)
produced no violation of `chord ≤ 2 arcsin(chord/2) = angle`, of `BC ≤ 1`, or of the
triangle inequality for `arccos BC`. All three are now theorems
(`chord_le_arccos_bhattacharyya`, `bhattacharyya_le_one`, `arccos_bhattacharyya_triangle`),
so the sampling is only a sanity check of the formalisation, not evidence for it.
