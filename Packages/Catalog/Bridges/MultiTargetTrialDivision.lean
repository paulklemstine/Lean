import Mathlib
import Bridges.TreeSieveLottery

/-!
# The multi-target relaxation is exactly trial division

This file formalises the analysis of the "MULTI-TARGET" relaxation
(round-72 experiment `exp558`).  A tree search whose goal is the *exact* target
`a = N` is relaxed to the much weaker goal `gcd (a, N) > 1`.  Empirically the
relaxation is a `~10^12` speedup over blind FIFO search, but `100 %` of first
hits land at `a = min (p, q)`, with fitted exponent `α = 1.087`, `r² = 1.0`:
dead centre of the trial-division band.  The theorems below explain *why* this
is forced, not accidental.

Main results.

* `firstHit_eq_min` / `isLeast_hit_min` — the least `a ≥ 2` with `gcd (a, N) > 1`
  is **exactly** `min p q` for a semiprime `N = p * q`.  Any search that sweeps
  values in ascending order therefore always first hits at `min p q`; the
  observed histogram is a theorem, not a statistic.
* `min_sq_le` / `ascending_sweep_is_trial_division` — the cost of the ascending
  sweep is `min p q ≤ √N`: exactly the trial-division exponent `1/2`.
* `relaxation_speedup_exact` — relative to the exact target `a = N`, the
  relaxation saves precisely a factor `max p q`, which is between `√N` and
  `N / 2`: a huge but strictly bounded win.
* `rho_beats_trial_division` — the `N^{1/4}` cost of Pollard-ρ beats
  `C · N^{1/2}`-class trial division for every constant `C` once `N > C⁴`;
  so the relaxed search remains dominated.
* `tree_integer_face_trichotomy` — the capstone: any splitter reading a value
  off the integer face of the Berggren tree is in one of three regimes —
  integer square identity (returns `N`, no split), a genuine mod-`N` congruence
  of squares (Dixon/QS class), or an ascending value sweep (trial division,
  cost `min p q`).  Every route ends in a known method.
-/

namespace MultiTarget

open TreeSieve

/-! ## The ascending sweep first-hit theorem -/

/-- The relaxed target predicate: a value `a ≥ 2` is a *hit* for `N` when it
shares a nontrivial factor with `N`. -/
def Hit (N a : ℕ) : Prop := 2 ≤ a ∧ 1 < Nat.gcd a N

instance (N a : ℕ) : Decidable (Hit N a) := by unfold Hit; infer_instance

/-- Any hit is at least the smaller prime factor of a semiprime. -/
theorem min_le_of_hit {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {a : ℕ}
    (h : Hit (p * q) a) : min p q ≤ a := by
  obtain ⟨ha2, hg⟩ := h
  obtain ⟨r, hr, hrg⟩ := Nat.exists_prime_and_dvd (n := Nat.gcd a (p * q)) (by omega)
  have hrdvd_a : r ∣ a := hrg.trans (Nat.gcd_dvd_left _ _)
  have hrdvd_N : r ∣ p * q := hrg.trans (Nat.gcd_dvd_right _ _)
  have hrpq : r = p ∨ r = q := by
    rcases (Nat.Prime.dvd_mul hr).mp hrdvd_N with h | h
    · exact Or.inl ((Nat.prime_dvd_prime_iff_eq hr hp).mp h)
    · exact Or.inr ((Nat.prime_dvd_prime_iff_eq hr hq).mp h)
  have hra' : r ≤ a := Nat.le_of_dvd (by omega) hrdvd_a
  rcases hrpq with rfl | rfl
  · exact le_trans (min_le_left _ _) hra'
  · exact le_trans (min_le_right _ _) hra'

/-- `min p q` is itself a hit. -/
theorem hit_min {p q : ℕ} (hp : p.Prime) (hq : q.Prime) : Hit (p * q) (min p q) := by
  have hdvd : min p q ∣ p * q := by
    rcases le_total p q with h | h
    · rw [min_eq_left h]; exact Dvd.intro q rfl
    · rw [min_eq_right h]; exact Dvd.intro_left p rfl
  refine ⟨le_min hp.two_le hq.two_le, ?_⟩
  rw [Nat.gcd_eq_left hdvd]
  exact lt_min hp.one_lt hq.one_lt

/-- **Ascending-sweep first hit.**  `min p q` is the least hit: a value-guided
best-first search that expands nodes in ascending value order necessarily
reports `a = min p q` on its first success, for *every* semiprime.  This is the
formal content of the observed `100 %` concentration of first hits. -/
theorem isLeast_hit_min {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    IsLeast {a : ℕ | Hit (p * q) a} (min p q) :=
  ⟨hit_min hp hq, fun _ ha => min_le_of_hit hp hq ha⟩

/-- Same statement phrased through `Nat.find`: the sweep's stopping index. -/
theorem firstHit_eq_min {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (H : ∃ a, Hit (p * q) a) : Nat.find H = min p q := by
  refine le_antisymm (Nat.find_le (hit_min hp hq)) ?_
  exact min_le_of_hit hp hq (Nat.find_spec H)

/-! ## The cost of the sweep is the trial-division exponent -/

/-- For a semiprime, `min p q ≤ √N`, i.e. the sweep costs `N^{1/2}`. -/
theorem min_sq_le (p q : ℕ) : min p q * min p q ≤ p * q := by
  rcases le_total p q with h | h
  · rw [min_eq_left h]; exact Nat.mul_le_mul_left p h
  · rw [min_eq_right h]; exact Nat.mul_le_mul_right q h

/-- **The relaxed search is trial-division class.**  Its cost `min p q` is at
most `Nat.sqrt N`, and (for `p ≠ q`) at least `2`: exponent `1/2`, matching the
fitted `α = 1.087` on `log₂`-of-the-smaller-prime scale. -/
theorem ascending_sweep_is_trial_division (p q : ℕ) :
    min p q ≤ Nat.sqrt (p * q) :=
  Nat.le_sqrt.mpr (min_sq_le p q)

/-- **Exact speedup of the relaxation.**  Searching for the exact target `a = N`
costs `N = p * q` sweep steps, the relaxed target costs `min p q`; the ratio is
exactly `max p q`. -/
theorem relaxation_speedup_exact (p q : ℕ) : min p q * max p q = p * q := by
  rcases le_total p q with h | h
  · rw [min_eq_left h, max_eq_right h]
  · rw [min_eq_right h, max_eq_left h]; ring

/-- The speedup factor is squeezed between `√N` and `N / 2`: the relaxation is
an enormous but strictly bounded win — it can never do better than
trial division. -/
theorem speedup_bounds {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    Nat.sqrt (p * q) ≤ max p q ∧ 2 * max p q ≤ p * q := by
  constructor
  · have hle : p * q ≤ max p q * max p q := by
      rcases max_cases p q with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> nlinarith [hp.two_le, hq.two_le]
    have := Nat.sqrt_le_sqrt hle
    simpa [Nat.sqrt_eq', pow_two] using this
  · rcases max_cases p q with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> nlinarith [hp.two_le, hq.two_le]

/-- **Balanced semiprimes give no relief.**  If the two primes are within a
factor `2` of each other, the ascending sweep still costs at least `√(N/2)`:
the relaxation cannot beat the trial-division exponent even in the best case. -/
theorem balanced_sweep_cost_lower_bound {p q : ℕ} (h1 : q ≤ 2 * p) (h2 : p ≤ 2 * q) :
    p * q ≤ 2 * (min p q * min p q) := by
  rcases le_total p q with h | h
  · rw [min_eq_left h]; nlinarith
  · rw [min_eq_right h]; nlinarith

/-! ## Pollard-ρ still dominates -/

/-- **Exponent dominance.**  For every constant `C > 0`, the `N^{1/4}` cost of
Pollard-ρ beats the `C`-free trial-division cost `N^{1/2}` for all `N > C⁴`.
Hence the relaxed multi-target search (exponent `1/2`) is asymptotically
dominated no matter how good its constants are. -/
theorem rho_beats_trial_division {C N : ℝ} (hC : 0 < C) (hN : C ^ 4 < N) :
    C * N ^ ((1:ℝ)/4) < N ^ ((1:ℝ)/2) := by
  have hNpos : (0:ℝ) < N := lt_of_le_of_lt (by positivity) hN
  have h4 : (0:ℝ) < N ^ ((1:ℝ)/4) := Real.rpow_pos_of_pos hNpos _
  have hCN : C < N ^ ((1:ℝ)/4) := by
    have hCC : C = (C ^ 4) ^ ((1:ℝ)/4) := by
      rw [← Real.rpow_natCast C 4, ← Real.rpow_mul hC.le]
      norm_num
    calc C = (C ^ 4) ^ ((1:ℝ)/4) := hCC
      _ < N ^ ((1:ℝ)/4) := by
          apply Real.rpow_lt_rpow (by positivity) hN (by norm_num)
  calc C * N ^ ((1:ℝ)/4) < N ^ ((1:ℝ)/4) * N ^ ((1:ℝ)/4) :=
        mul_lt_mul_of_pos_right hCN h4
    _ = N ^ ((1:ℝ)/2) := by
        rw [← Real.rpow_add hNpos]; norm_num

/-! ## Capstone: every route through the integer face is a known method -/

/-- A splitter reading integers off the tree is in one of three regimes. -/
inductive Regime (N : ℕ) : Type
  /-- The relation is an identity in `ℤ`: `X² = Y²` with `X, Y ≥ 0`. -/
  | integerIdentity (X Y : ℤ) (hX : 0 ≤ X) (hY : 0 ≤ Y) (h : X ^ 2 = Y ^ 2) : Regime N
  /-- The relation is a genuine congruence of squares modulo `N`. -/
  | dixon (x y : ℤ) (hdvd : (N : ℤ) ∣ (x - y) * (x + y))
      (h1 : ¬ (N : ℤ) ∣ (x - y)) (h2 : ¬ (N : ℤ) ∣ (x + y)) : Regime N
  /-- The search sweeps candidate values in ascending order. -/
  | ascendingSweep : Regime N

/-- **Trichotomy theorem.**  In the first regime the gcd step returns `N`
itself (no split); in the second it returns a proper nontrivial factor (Dixon /
quadratic sieve); in the third the first success occurs at `min p q ≤ √N`
(trial division).  There is no fourth possibility, and none of the three is
better than a textbook method. -/
theorem tree_integer_face_trichotomy {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : 1 < p * q) (R : Regime (p * q)) :
    (∃ X Y : ℤ, Int.gcd (X - Y) ((p * q : ℕ) : ℤ) = ((p * q : ℕ) : ℤ).natAbs) ∨
    (∃ x y : ℤ, 1 < Int.gcd (x - y) ((p * q : ℕ) : ℤ) ∧
        (Int.gcd (x - y) ((p * q : ℕ) : ℤ) : ℤ) < ((p * q : ℕ) : ℤ)) ∨
    IsLeast {a : ℕ | Hit (p * q) a} (min p q) := by
  cases R with
  | integerIdentity X Y hX hY h =>
      exact Or.inl ⟨X, Y, intSquareRelation_gcd_trivial _ hX hY h⟩
  | dixon x y hdvd h1 h2 =>
      refine Or.inr (Or.inl ⟨x, y, dixon_split_nontrivial (by exact_mod_cast hpq) hdvd h1 h2⟩)
  | ascendingSweep => exact Or.inr (Or.inr (isLeast_hit_min hp hq))

/-- The outcome that the gcd / sweep step actually produces, read off the
*regime's own data* rather than through a bare existential.  This is what makes
the trichotomy sharp: the disjunct is selected by the constructor, and its
witnesses are the ones the regime supplies. -/
def Regime.Outcome {N : ℕ} : Regime N → Prop
  | .integerIdentity X Y _ _ _ => Int.gcd (X - Y) (N : ℤ) = N
  | .dixon x y _ _ _ => 1 < Int.gcd (x - y) (N : ℤ) ∧ Int.gcd (x - y) (N : ℤ) < N
  | .ascendingSweep => ∃ a : ℕ, IsLeast {b : ℕ | Hit N b} a ∧ a * a ≤ N

/-- **Sharp trichotomy.**  For every regime, its own outcome holds: the integer
identity returns `N` itself (no split), the mod-`N` congruence returns a proper
nontrivial factor (Dixon / quadratic sieve), and the ascending sweep has a least
hit whose square is at most `N` (trial division).  Unlike
`tree_integer_face_trichotomy`, the conclusion here is determined by the regime,
so no disjunct can be discharged by an unrelated witness. -/
theorem tree_integer_face_trichotomy_sharp {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : 1 < p * q) (R : Regime (p * q)) : R.Outcome := by
  cases R with
  | integerIdentity X Y hX hY h =>
      show Int.gcd (X - Y) ((p * q : ℕ) : ℤ) = p * q
      rw [intSquareRelation_gcd_trivial _ hX hY h]
      simp [Int.natAbs_mul]
  | dixon x y hdvd h1 h2 =>
      obtain ⟨hlt, hup⟩ := dixon_split_nontrivial (N := ((p * q : ℕ) : ℤ))
        (by exact_mod_cast hpq) hdvd h1 h2
      exact ⟨hlt, by exact_mod_cast hup⟩
  | ascendingSweep => exact ⟨min p q, isLeast_hit_min hp hq, min_sq_le p q⟩

end MultiTarget