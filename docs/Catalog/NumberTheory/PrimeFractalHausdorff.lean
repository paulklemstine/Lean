import Mathlib

/-!
# The "prime fractal": Hausdorff dimension and total length

We study the set of primes equipped with the metric

  `d p q = |1 / log p - 1 / log q|`,

as proposed in the research mission.  Concretely, the map
`logInv p = 1 / Real.log p` embeds the primes into `ℝ` and, by `Real.dist_eq`,
the metric induced from `ℝ` is exactly `d`.  We call the image the
*prime fractal* `primeFractal ⊆ ℝ`.

## Main results

* `logInv_injOn_prime` — `logInv` is injective on the primes, so
  `(primes, d)` is isometric to `primeFractal` with the euclidean metric.
* `dimH_primeFractal` — `dimH primeFractal = 0`.  **This refutes the mission
  conjecture `dimH = 1`, and a fortiori the conjecture `dimH = 1 + ε` with
  `ε > 0` measuring twin primes.**  The reason is soft but decisive: the primes
  are countable, and every countable subset of a metric space has Hausdorff
  dimension `0`.
* `dimH_subFractal` — the same holds for *every* subfamily of primes (twin
  primes, Sophie Germain primes, ...): the twin prime conjecture cannot change
  the Hausdorff dimension.
* `primeFractal_length_eq` / `tendsto_primeFractal_length` — the total
  `d`-length of the primes is *finite*, equal to `1 / log 2`.  The mission's
  heuristic ("the length is `∑ 1/(p log p) ∼ log log x`, which diverges") is
  therefore false twice over: the sum telescopes, and `∑ 1/(p log p)`
  converges anyway.
* `isCompact_insert_zero_primeFractal`, `dimH_closure_primeFractal` — the
  closure of the prime fractal is the compact set `{0} ∪ primeFractal`, and it
  still has Hausdorff dimension `0`.

The positive counterpart (the *box-counting* dimension really is `1`) is in
`NumberTheory.PrimeFractalBoxDimension`.
-/

namespace PrimeFractal

open Filter Topology

/-- The logarithmic embedding `p ↦ 1 / log p` of the primes into `ℝ`. -/
noncomputable def logInv (p : ℕ) : ℝ := 1 / Real.log p

/-- The prime fractal: the primes seen through the logarithmic lens. -/
noncomputable def primeFractal : Set ℝ := logInv '' {p : ℕ | p.Prime}

/-- The distance induced on the primes by the embedding `logInv` is exactly the
mission's metric `d p q = |1/log p - 1/log q|`. -/
theorem dist_logInv (p q : ℕ) :
    dist (logInv p) (logInv q) = |1 / Real.log p - 1 / Real.log q| :=
  Real.dist_eq _ _

theorem logInv_pos {p : ℕ} (hp : p.Prime) : 0 < logInv p := by
  have h2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.two_le
  have : 0 < Real.log p := Real.log_pos (by linarith)
  simpa [logInv] using one_div_pos.mpr this

/-- `logInv` is strictly antitone on integers `≥ 2`. -/
theorem logInv_lt_logInv {p q : ℕ} (hp : 2 ≤ p) (hpq : p < q) : logInv q < logInv p := by
  have hp2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hpq' : (p : ℝ) < (q : ℝ) := by exact_mod_cast hpq
  have hlp : 0 < Real.log p := Real.log_pos (by linarith)
  have hlq : Real.log p < Real.log q := Real.log_lt_log (by linarith) hpq'
  exact one_div_lt_one_div_of_lt hlp hlq

/-- `logInv` is injective on the set of primes: the prime fractal faithfully
records the primes. -/
theorem logInv_injOn_prime : Set.InjOn logInv {p : ℕ | p.Prime} := by
  intro p hp q hq hpq
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · have hlt := logInv_lt_logInv hp.two_le h
    rw [hpq] at hlt
    exact lt_irrefl _ hlt
  · have hlt := logInv_lt_logInv hq.two_le h
    rw [hpq] at hlt
    exact lt_irrefl _ hlt

theorem primeFractal_countable : primeFractal.Countable :=
  (Set.to_countable _).image _

/-- **Refutation of the mission conjecture.** The Hausdorff dimension of the prime
fractal is `0`, not `1` (and not `1 + ε`). -/
theorem dimH_primeFractal : dimH primeFractal = 0 :=
  primeFractal_countable.dimH_zero

theorem dimH_primeFractal_ne_one : dimH primeFractal ≠ 1 := by
  rw [dimH_primeFractal]; simp

/-- No `ε`, however small, can appear: `dimH = 1 + ε` is impossible. -/
theorem not_exists_dimH_eq_one_add : ¬ ∃ ε : ENNReal, dimH primeFractal = 1 + ε := by
  rintro ⟨ε, hε⟩
  rw [dimH_primeFractal] at hε
  have : (1 : ENNReal) ≤ 1 + ε := le_self_add
  rw [← hε] at this
  simp at this

/-- **The twin primes cannot help.** Any subfamily of the primes — the twin
primes, the Sophie Germain primes, any set at all — has Hausdorff dimension `0`
in the `d`-metric. -/
theorem dimH_subFractal (T : Set ℕ) : dimH (logInv '' T) = 0 :=
  ((Set.to_countable T).image _).dimH_zero

/-- The twin prime fractal. -/
noncomputable def twinPrimeFractal : Set ℝ := logInv '' {p : ℕ | p.Prime ∧ (p + 2).Prime}

theorem dimH_twinPrimeFractal : dimH twinPrimeFractal = 0 := dimH_subFractal _

/-!
### The total `d`-length of the primes is finite

The mission asserts that `∑_{p ≤ x} d(p, next p) ∼ log log x` diverges.  In fact
the sum telescopes and is bounded by `1 / log 2`.
-/

/-- Telescoping: along any increasing sequence of integers `≥ 2`, the total
`d`-length is a difference of two endpoint values. -/
theorem length_telescope (q : ℕ → ℕ) (hq2 : ∀ i, 2 ≤ q i) (hmono : StrictMono q) (n : ℕ) :
    ∑ i ∈ Finset.range n, dist (logInv (q i)) (logInv (q (i + 1)))
      = logInv (q 0) - logInv (q n) := by
  have hterm : ∀ i, dist (logInv (q i)) (logInv (q (i + 1)))
      = logInv (q i) - logInv (q (i + 1)) := by
    intro i
    have h := logInv_lt_logInv (hq2 i) (hmono (Nat.lt_succ_self i))
    rw [Real.dist_eq, abs_of_pos (by linarith)]
  simp only [hterm]
  exact Finset.sum_range_sub' (fun i => logInv (q i)) n

/-- The `d`-length of any finite increasing chain of primes is at most `1 / log 2`:
the prime fractal is a *rectifiable* set of finite length, not a divergent one. -/
theorem length_le (q : ℕ → ℕ) (hq2 : ∀ i, 2 ≤ q i) (hmono : StrictMono q) (n : ℕ) :
    ∑ i ∈ Finset.range n, dist (logInv (q i)) (logInv (q (i + 1))) ≤ 1 / Real.log 2 := by
  rw [length_telescope q hq2 hmono n]
  have h0 : logInv (q 0) ≤ 1 / Real.log 2 := by
    rcases eq_or_lt_of_le (hq2 0) with h | h
    · simp [logInv, ← h]
    · exact le_of_lt (by simpa [logInv] using logInv_lt_logInv (le_refl 2) h)
  have hn : 0 ≤ logInv (q n) := by
    have h2 : (2 : ℝ) ≤ ((q n : ℕ) : ℝ) := by exact_mod_cast hq2 n
    have hlog : 0 < Real.log (q n) := Real.log_pos (by linarith)
    simp only [logInv]
    positivity
  linarith

/-- The `n`-th prime, as a sequence. -/
noncomputable def primeSeq (n : ℕ) : ℕ := Nat.nth Nat.Prime n

theorem primeSeq_prime (n : ℕ) : (primeSeq n).Prime :=
  Nat.nth_mem_of_infinite Nat.infinite_setOf_prime n

theorem primeSeq_strictMono : StrictMono primeSeq :=
  Nat.nth_strictMono Nat.infinite_setOf_prime

theorem primeSeq_zero : primeSeq 0 = 2 := by
  have h := Nat.nth_count (p := Nat.Prime) (n := 2) (by norm_num)
  have hc : Nat.count Nat.Prime 2 = 0 := by decide
  rwa [hc] at h

theorem tendsto_logInv_primeSeq : Tendsto (fun n => logInv (primeSeq n)) atTop (𝓝 0) := by
  have hle : ∀ n : ℕ, (n : ℝ) ≤ ((primeSeq n : ℕ) : ℝ) := by
    intro n
    exact_mod_cast primeSeq_strictMono.le_apply
  have hcast : Tendsto (fun n : ℕ => ((primeSeq n : ℕ) : ℝ)) atTop atTop :=
    tendsto_atTop_mono hle tendsto_natCast_atTop_atTop
  have hlog : Tendsto (fun n : ℕ => Real.log ((primeSeq n : ℕ) : ℝ)) atTop atTop :=
    Real.tendsto_log_atTop.comp hcast
  simpa [logInv, one_div] using hlog.inv_tendsto_atTop

/-- **The total `d`-length of the primes is exactly `1 / log 2`.**  In particular it
is finite, contradicting the divergence heuristic behind the mission conjecture. -/
theorem tendsto_primeFractal_length :
    Tendsto (fun n => ∑ i ∈ Finset.range n,
        dist (logInv (primeSeq i)) (logInv (primeSeq (i + 1)))) atTop (𝓝 (1 / Real.log 2)) := by
  have hq2 : ∀ i, 2 ≤ primeSeq i := fun i => (primeSeq_prime i).two_le
  have hrw : ∀ n, ∑ i ∈ Finset.range n,
      dist (logInv (primeSeq i)) (logInv (primeSeq (i + 1)))
      = 1 / Real.log 2 - logInv (primeSeq n) := by
    intro n
    rw [length_telescope primeSeq hq2 primeSeq_strictMono n, primeSeq_zero]
    norm_num [logInv]
  simp only [hrw]
  simpa using (tendsto_const_nhds (x := (1 : ℝ) / Real.log 2) (f := atTop)).sub
    tendsto_logInv_primeSeq

/-!
### Topology: the closure of the prime fractal
-/

theorem range_primeSeq : Set.range primeSeq = {p : ℕ | p.Prime} :=
  Nat.range_nth_of_infinite Nat.infinite_setOf_prime

theorem primeFractal_eq_range : primeFractal = Set.range (fun n => logInv (primeSeq n)) := by
  rw [primeFractal, ← range_primeSeq, ← Set.range_comp]
  rfl

/-- Adding the single limit point `0` makes the prime fractal compact. -/
theorem isCompact_insert_zero_primeFractal : IsCompact (insert (0 : ℝ) primeFractal) := by
  rw [primeFractal_eq_range]
  exact tendsto_logInv_primeSeq.isCompact_insert_range

/-- The closure of the prime fractal adds at most the point `0`. -/
theorem closure_primeFractal_subset : closure primeFractal ⊆ insert (0 : ℝ) primeFractal := by
  refine closure_minimal (Set.subset_insert _ _) ?_
  exact isCompact_insert_zero_primeFractal.isClosed

/-- Even the closure — a genuine compact subset of `ℝ` — has Hausdorff dimension `0`. -/
theorem dimH_closure_primeFractal : dimH (closure primeFractal) = 0 := by
  have hcount : (insert (0 : ℝ) primeFractal).Countable :=
    primeFractal_countable.insert 0
  exact (hcount.mono closure_primeFractal_subset).dimH_zero

end PrimeFractal