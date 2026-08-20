import Physics.QuantumPythagoreanWalk.Collapse

/-!
# Quantum-Pythagorean-Walk — IV. The search barrier: why tree resonance is not polynomial

The bold claim attached to this programme is *polynomial-time factorisation by tree
resonance*.  Here we prove the adversarial half of the story, and it is unconditional.

Since every Berggren branch multiplies the hypotenuse by at most `7`, a walk of depth `n`
can only reach hypotenuses `≤ 5·7ⁿ`.  A resonance for `N` requires a hypotenuse divisible
by `N`, hence at least `N`.  Therefore any resonant word has length

`n ≥ log₇(N/5)`,

while the depth-`n` layer of the walk carries `3ⁿ` branches.  Because `9 > 7`, this forces

`N ≤ 5·(3ⁿ)²`,  i.e.  `3ⁿ ≥ √(N/5)`  (`hilbert_dimension_lower_bound`).

So the dimension of the walk's depth-`n` Hilbert space at the first resonant depth is
`Ω(√N)` — exponential in the bit length of `N`.  Even a Grover-type quadratic speed-up over
this layer costs `Ω(N^{1/4})`, still exponential in `log N`.  Combined with the
`3 mod 4`-obstruction of `Collapse.lean`, the "polynomial-time factorisation" reading of the
resonance mechanism is refuted, while the *arithmetic* mechanism itself (Collapse) survives.

Conversely the tree is genuinely *shallow*: the slow branch reaches hypotenuse `2n²+6n+5`
at depth `n`, so resonances exist at depth `Θ(√N)` (`resonance_at_quadratic_depth`), and
every resonance sits in the sandwich `log₇(c/5) ≤ n ≤ (c-5)/8` (`depth_window`).
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Depth lower bound for a resonance -/

/-- A word reaching a hypotenuse divisible by `N` must be long: `N ≤ 5·7^{|w|}`. -/
theorem resonance_depth_lower_bound {N : ℤ} {w : List (Fin 3)}
    (h : N ∣ (walk w).c) : N ≤ 5 * 7 ^ w.length :=
  le_trans (Int.le_of_dvd (hyp_walk_pos w) h) (hyp_walk_le w)

/-- Since `9 > 7`, the depth bound converts into a bound on the *number of branches*:
the depth-`n` layer of the walk must already contain `3ⁿ ≥ √(N/5)` words. -/
theorem search_space_lower_bound {N : ℤ} {w : List (Fin 3)}
    (h : N ∣ (walk w).c) : N ≤ 5 * (3 ^ w.length) ^ 2 := by
  have h1 := resonance_depth_lower_bound h
  have h2 : (7 : ℤ) ^ w.length ≤ (3 ^ w.length) ^ 2 := by
    rw [← pow_mul, mul_comm, pow_mul]
    exact pow_le_pow_left₀ (by norm_num) (by norm_num) _
  omega

/-- Real-analytic form of the barrier: the dimension `3ⁿ` of the depth-`n` walk space is at
least `√(N/5)` whenever a resonance for `N` occurs at depth `n`. -/
theorem hilbert_dimension_lower_bound {N : ℤ} {n : ℕ}
    (h : resonanceSet N n ≠ ∅) : Real.sqrt ((N : ℝ) / 5) ≤ (3 : ℝ) ^ n := by
  obtain ⟨w, hw⟩ := Finset.nonempty_of_ne_empty h
  simp only [resonanceSet, Finset.mem_filter, Finset.mem_univ, true_and] at hw
  have hz : N ≤ 5 * (3 ^ (wordOf w).length) ^ 2 := search_space_lower_bound hw
  rw [length_wordOf] at hz
  have hzR : (N : ℝ) ≤ 5 * ((3 : ℝ) ^ n) ^ 2 := by exact_mod_cast hz
  have hle : (N : ℝ) / 5 ≤ ((3 : ℝ) ^ n) ^ 2 := by linarith
  calc Real.sqrt ((N : ℝ) / 5) ≤ Real.sqrt (((3 : ℝ) ^ n) ^ 2) := Real.sqrt_le_sqrt hle
    _ = (3 : ℝ) ^ n := Real.sqrt_sq (by positivity)

/-- Grover-style reading: even the square root of the depth-`n` layer size is `Ω(N^{1/4})`,
so no amplitude-amplification over a single layer can be polynomial in `log N`. -/
theorem grover_cost_lower_bound {N : ℤ} {n : ℕ} (h : resonanceSet N n ≠ ∅) :
    Real.sqrt (Real.sqrt ((N : ℝ) / 5)) ≤ Real.sqrt ((3 : ℝ) ^ n) :=
  Real.sqrt_le_sqrt (hilbert_dimension_lower_bound h)

/-! ### The tree is shallow: resonances at quadratic depth -/

/-- The all-`A` word of length `n` runs along the slow branch. -/
theorem walk_replicate_zero (n : ℕ) : walk (List.replicate n 0) = Node.stepA^[n] root := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [List.replicate_succ, walk_cons, ih, Function.iterate_succ_apply']
      rfl

theorem wordOf_const_zero (n : ℕ) : wordOf (fun _ : Fin n => (0 : Fin 3)) =
    List.replicate n 0 := by
  simp [wordOf, List.ofFn_const]

/-- **Shallowness.**  For the quadratic targets `N = 2n²+6n+5` the walk has a resonance
already at depth `n = Θ(√N)`; the resonance depth is therefore *not* the obstruction — the
branching factor is. -/
theorem resonance_at_quadratic_depth (n : ℕ) :
    resonanceSet (2 * (n : ℤ) ^ 2 + 6 * n + 5) n ≠ ∅ := by
  intro hempty
  have hmem : (fun _ : Fin n => (0 : Fin 3)) ∈ resonanceSet (2 * (n : ℤ) ^ 2 + 6 * n + 5) n := by
    simp only [resonanceSet, Finset.mem_filter, Finset.mem_univ, true_and]
    rw [wordOf_const_zero, walk_replicate_zero, hyp_iterate_stepA_root]
  rw [hempty] at hmem
  exact absurd hmem (Finset.notMem_empty _)

/-- **Depth window.**  Any node reached at depth `n` has hypotenuse sandwiched between the
quadratic slow branch and the geometric fast branch; equivalently the depth of a node of
hypotenuse `c` satisfies `8n + 5 ≤ c ≤ 5·7ⁿ`. -/
theorem depth_window (w : List (Fin 3)) :
    8 * w.length + 5 ≤ (walk w).c ∧ (walk w).c ≤ 5 * 7 ^ w.length :=
  ⟨hyp_walk_ge w, hyp_walk_le w⟩

/-! ### Summary: no polynomial-size resonance layer -/

/-- **No-go for the polynomial-time reading.**  Fix any target `N > 0`.  If the depth-`n`
layer of the walk is smaller than `√(N/5)`, it contains no resonance at all; hence a
resonance-based factoring walk must manipulate a layer of dimension `≥ √(N/5)`, which is
exponential in the bit length of `N`. -/
theorem no_small_resonant_layer {N : ℤ} {n : ℕ}
    (hsmall : 5 * (3 ^ n : ℤ) ^ 2 < N) : resonanceSet N n = ∅ := by
  by_contra h
  obtain ⟨w, hw⟩ := Finset.nonempty_of_ne_empty h
  simp only [resonanceSet, Finset.mem_filter, Finset.mem_univ, true_and] at hw
  have hz : N ≤ 5 * (3 ^ (wordOf w).length) ^ 2 := search_space_lower_bound hw
  rw [length_wordOf] at hz
  omega

end QuantumPythagoreanWalk