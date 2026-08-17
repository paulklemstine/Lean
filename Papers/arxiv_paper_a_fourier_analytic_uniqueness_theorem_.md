# Computational evidence and lab notes

Topic: real-parameter lattice-point enumerators `L_P(t) = |tP ∩ ℤ^d|` and the uniqueness
question of *A Fourier-analytic uniqueness theorem for lattice-point enumerators*.

All numerical claims below that are marked **[verified]** are backed by a `sorry`-free Lean
theorem in `Catalog/Cryptography/`; the rest are recorded as informal exploration.

## 1. Small-case calculations (dimension 1)

For `P = [0,1) ⊆ ℝ` one has `tP = [0,t)` and hence

`L_P(t) = |{k ∈ ℤ : 0 ≤ k < t}| = ⌈t⌉`.

| `t`   | `L_P(t)` | `L_P(t)/t` |
|-------|----------|------------|
| 1/3   | 1        | 3.0        |
| 1     | 1        | 1.0        |
| 5/2   | 3        | 1.2        |
| 4     | 4        | 1.0        |
| 10.5  | 11       | 1.0476…    |
| 100.2 | 101      | 1.0080…    |

**[verified]** `LatticeEnumerator.dilCount_unitInterval` proves `L_{[0,1)}(t) = ⌈t⌉` for all
`t > 0`; `LatticeEnumerator.dilCount_unitInterval_examples` verifies the rows `t = 1/3, 5/2, 4`;
`LatticeEnumerator.tendsto_dilCount_unitInterval` proves the asymptotics `⌈t⌉/t → 1 = vol[0,1)`
of the last column, matching the general Gauss–Weyl theorem
`LatticeEnumerator.tendsto_dilCount_div`.

The sequence `L_{[0,1)}(n) = n` for integer `n` (and `⌈t⌉` in general) is the trivial sequence
A000027; no interesting OEIS entry arises here, which is itself informative: *integer* dilation
parameters lose all information (see §3).

## 2. The sparse-grid probe: a worked instance

The mechanism behind the uniqueness proof, instantiated at `d = 1`, `P ⊆ [-1,1]` (so `R = 1`),
target point `x = 1/2 = a/N` with `a = 1`, `N = 2`:

* `M = ⌈2R⌉ + 2 = 4`, `q = N·M + 1 = 9`, `t = N/q = 2/9`, grid spacing `1/t = 4.5`,
  translate `v = M·a = 4`.
* The counted grid is `{k·4.5 - 4 : k ∈ ℤ} = {…, −8.5, −4, 0.5, 5, 9.5, …}`.
* Spacing `4.5 > 2R = 2`, so **at most one** grid point lies in `[-1,1]`; that point is
  exactly `x = 0.5`.
* Hence `L_{P+4}(2/9) = 1` if `1/2 ∈ P` and `= 0` otherwise: the enumerator data literally
  reads off the indicator at `x`.

**[verified]** in general by `LatticeEnumerator.mem_iff_mem_of_gridRepresentation` and
`LatticeEnumerator.mem_iff_mem_of_integerTranslateData`.

## 3. Counterexample hunt (what the data does *not* see)

* **Integer dilation parameters are useless.** If `t = n ∈ ℕ` then
  `t(P + v) ∩ ℤ^d = (nP + nv) ∩ ℤ^d`, and `nv ∈ ℤ^d`, so the count is independent of `v`.
  Consequently the family `{L_{P+v}(n)}_{v∈ℤ^d, n∈ℕ}` cannot distinguish
  `P = [0,1)` from `P = [0,1) + 1/2` when only integer `t` is used, whereas the full real-`t`
  data does (their indicators differ at rational points). *Real* dilation parameters are
  essential — matching the emphasis of the paper.
* **Almost-everywhere is optimal.** Take `B` an open ball and `B' = B \ {√2·e₁}`. Then
  `vol(B Δ B') = 0` and both frontiers are null, so no theorem with an a.e. conclusion can be
  improved to set equality for `d ≥ 2` unless the exceptional point is reachable by a grid
  probe. Our master lemma shows the reachable set is
  `{s·k − v : k, v ∈ ℤ^d, s large}` ⊇ ℚ^d — dense, but of measure zero when `d ≥ 2`, while
  for `d = 1` it is *all* of ℝ, which is why dimension one admits exact equality
  (`eq_of_integerTranslateData_dim_one`).
* **No counterexample to the main theorem was found**, and none exists: the theorem is proved.

## 4. Table: what each data family determines

| data available                                | conclusion                              | Lean name |
|-----------------------------------------------|------------------------------------------|-----------|
| `L_P(t)`, all real `t>0`                        | `vol P = vol Q`                          | `volume_eq_of_dilCount_eq` |
| `L_{P+v}(t)`, all real `t>0`, `v ∈ ℤ^d`         | equal rational points; `1_P = 1_Q` a.e.  | `mem_iff_mem_of_integerTranslateData`, `ae_eq_of_integerTranslateData` |
| `L_{P+v}(t)`, all real `t>0`, `v ∈ ℤ` (`d = 1`) | `P = Q` exactly                          | `eq_of_integerTranslateData_dim_one` |
| `L_{P+y}(t)`, all real `t>0`, `y ∈ ℝ^d`         | `P = Q` exactly                          | `eq_of_shiftCount_eq` |

## 5. Lab notes (chronological)

1. First attempt followed the abstract literally: periodise the counting function, take a
   discrete Fourier transform of its samples on `ℤ^d`. Computation of the aliasing structure:
   for `t = N/q` in lowest terms the sample group is `ℤ^d/(qℤ^d)` and the Fourier coefficients
   recovered are `Σ_{n ∈ ℤ^d} \hat{1_P}(ξ + N n)`, aliases spaced `N` apart. Making the aliasing
   error vanish requires summable decay of `\hat{1_P}`, which fails for generic indicator
   functions in `d ≥ 2` (e.g. `\hat{1_{ball}}(ξ) ≍ |ξ|^{-(d+1)/2}`). **Conclusion: the naive
   DFT route needs extra decay hypotheses.** Recorded as an obstruction, not as a failure of
   the theorem.
2. Reversal: instead of making the grid *fine* (Fourier regime), make it *sparse*. With
   spacing larger than the diameter of `P` the count collapses to a single indicator value.
   The arithmetic identity `x = (M + 1/N)·a − M·a` for `x = a/N` shows every rational point is
   a sparse-grid probe point. This gives the main theorem in three short lemmas.
3. The same idea run on the real-translate data gives exact rigidity with no hypotheses; run
   in dimension one it gives exact rigidity from integer translates.
4. The Fourier picture was retained as an independent theorem
   (`tendsto_weightedSum`, `tendsto_fourierSum`): normalised lattice sums of a bounded
   continuous weight converge to the corresponding integral, so the Fourier transform of `1_P`
   *is* recoverable from the counted lattice points — the analytic device of the paper,
   formalised, even though the final uniqueness proof no longer needs it.
