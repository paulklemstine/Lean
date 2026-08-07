import Mathlib

/-!
# The Fractal Dimension of Mathematical Truth — Deepening

This file deepens the study of the box-counting (fractal) dimension of the space
of true statements.  In the base development, statements are encoded as finite
binary strings (a length-`n` statement is a function `Fin n → Bool`), a *theory*
`T` assigns to each length the finite set of accepted strings, and the fractal
dimension is

  `boxDim T = limsup_n  log₂ (count T n) / n`,   `count T n = (T n).card`.

There it was shown that an explicit "half-information" theory has dimension
exactly `1/2`.  Here we prove the sharp *generalization*:

## Main results

* `boxDim_densityTheory`: for every modulus `m ≥ 1` and every set of admissible
  residues `R ⊆ {0,…,m-1}`, the **periodic density theory** — which frees a
  coordinate `i` exactly when `i mod m` is admissible — has fractal dimension
  exactly `R.card / m`, the asymptotic density of free coordinates.
* `rational_dimension_realized`: consequently **every rational number in `[0,1]`
  is the fractal dimension of some theory of truth.**  The dimension spectrum of
  truth is the whole rational unit interval, not the single value `1/2`.
* `boxDim_mono`: fractal dimension is **monotone** under inclusion of theories.
* `boxDim_le_one` / `boxDim_nonneg`: every dimension lies in `[0,1]`.

The engine is an exact two-sided count of free coordinates: writing
`freeCount m R n` for the number of admissible indices below `n`, we prove the
counting law `count = 2 ^ freeCount`, the clean sandwiching
`R.card·⌊n/m⌋ ≤ freeCount ≤ R.card·⌊n/m⌋ + R.card`, and squeeze the ratio to the
density.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the value `1/2` obtained for one particular truth set
is not special; the fractal dimension is exactly the asymptotic density of
"information-bearing" coordinates, so by tuning that density every rational in
`[0,1]` should be attained.  Bold form: the dimension spectrum of truth is a
dense subset of `[0,1]`.

Experiment (Experimenter): we introduced the periodic density theory
`densityTheory m R` (coordinate `i` is free iff `i mod m ∈ R`), proved the exact
count `2 ^ freeCount`, established the periodicity `freeCount (n+m) = freeCount n
+ R.card` via a complete-residue-system bijection, derived the sandwich bounds by
monotonicity, and squeezed the finite estimates to `R.card / m`.

Analysis (Analyst): the argument is robust because it never depends on the
*identity* of the admissible residues, only on their count `R.card`; this is why
the whole rational interval is realized.  The `limsup` collapses to a genuine
limit here because the density theory is asymptotically regular; irregular
theories genuinely need the `limsup`.

Critique (Critic): the results are not definitional — `boxDim_densityTheory`
rests on an exact combinatorial count plus an analytic squeeze, and
`rational_dimension_realized` produces a witness for each target value rather
than asserting existence abstractly.  Monotonicity is proved at the level of
`limsup`, guarding against the corner case `count = 0` (where `log₂ 0 = 0`).

Synthesis (PI): measured by covering the Cantor space of statements, the possible
fractal dimensions of truth fill the rational unit interval, each realized by a
concrete periodic theory whose free-coordinate density equals the dimension.
-/

open Filter Topology

namespace TruthFractalDimensionDeepening

/-- A **theory** assigns to each length `n` the finite set of accepted binary
strings (statements) of that length. -/
abbrev Theory := (n : ℕ) → Finset (Fin n → Bool)

/-- The number of statements of length `n` accepted by a theory. -/
def count (T : Theory) (n : ℕ) : ℕ := (T n).card

/-- The finite-scale dimension estimate: `log₂ (count T n) / n`. -/
noncomputable def dimEstimate (T : Theory) (n : ℕ) : ℝ :=
  Real.logb 2 (count T n) / n

/-- The **box-counting (fractal) dimension** of a theory. -/
noncomputable def boxDim (T : Theory) : ℝ := limsup (dimEstimate T) atTop

/-! ### Universal bounds -/

theorem count_le_pow (T : Theory) (n : ℕ) : count T n ≤ 2 ^ n := by
  have h : count T n ≤ Fintype.card (Fin n → Bool) := by
    simpa [count] using Finset.card_le_card (Finset.subset_univ (T n))
  simpa using h

theorem logb_count_le (T : Theory) (n : ℕ) : Real.logb 2 (count T n) ≤ n := by
  rcases Nat.eq_zero_or_pos (count T n) with h | h
  · simp [h]
  · calc Real.logb 2 (count T n) ≤ Real.logb 2 ((2 : ℝ) ^ n) := by
            refine (Real.logb_le_logb (by norm_num) (by exact_mod_cast h) (by positivity)).mpr ?_
            exact_mod_cast count_le_pow T n
      _ = n := by rw [Real.logb_pow]; simp

theorem dimEstimate_nonneg (T : Theory) (n : ℕ) : 0 ≤ dimEstimate T n := by
  unfold dimEstimate
  apply div_nonneg _ (by positivity)
  rcases Nat.eq_zero_or_pos (count T n) with h | h
  · simp [h]
  · exact Real.logb_nonneg (by norm_num) (by exact_mod_cast h)

theorem dimEstimate_le_one (T : Theory) (n : ℕ) (hn : 1 ≤ n) : dimEstimate T n ≤ 1 := by
  unfold dimEstimate
  rw [div_le_one (by positivity)]
  simpa using logb_count_le T n

theorem dimEstimate_isCobounded (T : Theory) :
    IsCoboundedUnder (· ≤ ·) atTop (dimEstimate T) := by
  refine ⟨0, fun a ha => ?_⟩
  obtain ⟨n, hn⟩ := (eventually_map.mp ha).exists
  exact le_trans (dimEstimate_nonneg T n) hn

theorem dimEstimate_isBounded (T : Theory) :
    IsBoundedUnder (· ≤ ·) atTop (dimEstimate T) := by
  refine ⟨1, ?_⟩
  rw [eventually_map]
  filter_upwards [eventually_ge_atTop 1] with n hn using dimEstimate_le_one T n hn

/-- **Every theory has fractal dimension at most `1`.** -/
theorem boxDim_le_one (T : Theory) : boxDim T ≤ 1 := by
  apply limsup_le_of_le (dimEstimate_isCobounded T)
  filter_upwards [eventually_ge_atTop 1] with n hn using dimEstimate_le_one T n hn

/-- **Every theory has nonnegative fractal dimension.** -/
theorem boxDim_nonneg (T : Theory) : 0 ≤ boxDim T := by
  apply le_limsup_of_le (dimEstimate_isBounded T)
  intro b hb
  obtain ⟨n, hn⟩ := hb.exists
  exact le_trans (dimEstimate_nonneg T n) hn

/-! ### Monotonicity of fractal dimension -/

theorem count_mono {T T' : Theory} (h : ∀ n, T n ⊆ T' n) (n : ℕ) :
    count T n ≤ count T' n :=
  Finset.card_le_card (h n)

theorem dimEstimate_mono {T T' : Theory} (h : ∀ n, T n ⊆ T' n) (n : ℕ) :
    dimEstimate T n ≤ dimEstimate T' n := by
  refine' div_le_div_of_nonneg_right ( _ ) ( Nat.cast_nonneg _ );
  by_cases hT : count T n = 0;
  · simp_all +decide [ Real.logb ];
    exact div_nonneg ( Real.log_natCast_nonneg _ ) ( Real.log_nonneg ( by norm_num ) );
  · gcongr <;> norm_cast;
    exact count_mono h n

/-- **Fractal dimension is monotone under inclusion of theories.** -/
theorem boxDim_mono {T T' : Theory} (h : ∀ n, T n ⊆ T' n) : boxDim T ≤ boxDim T' := by
  apply limsup_le_limsup
  · filter_upwards with n using dimEstimate_mono h n
  · exact dimEstimate_isCobounded T
  · exact dimEstimate_isBounded T'

/-! ### Periodic density theories: realizing every rational dimension -/

/-- The **periodic density theory** with modulus `m` and admissible residues `R`:
a coordinate `i` is free (may be `true` or `false`) exactly when `i mod m ∈ R`;
otherwise it is forced to `false`.  The asymptotic density of free coordinates is
`R.card / m`. -/
noncomputable def densityTheory (m : ℕ) (R : Finset ℕ) : Theory := fun n =>
  Fintype.piFinset (fun i : Fin n =>
    if (i : ℕ) % m ∈ R then (Finset.univ : Finset Bool) else {false})

/-- The number of admissible (free) indices below `n`. -/
def freeCount (m : ℕ) (R : Finset ℕ) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun i => i % m ∈ R)).card

/-- Exact counting law: the density theory accepts `2 ^ freeCount` strings. -/
theorem count_densityTheory (m : ℕ) (R : Finset ℕ) (n : ℕ) :
    count (densityTheory m R) n = 2 ^ freeCount m R n := by
  unfold count densityTheory freeCount;
  erw [ Fintype.card_piFinset ];
  rw [ Finset.card_filter ];
  rw [ Finset.prod_fin_eq_prod_range ];
  rw [ ← Finset.prod_pow_eq_pow_sum ] ; exact Finset.prod_congr rfl fun x hx => by aesop;

theorem freeCount_zero (m : ℕ) (R : Finset ℕ) : freeCount m R 0 = 0 := by
  simp [freeCount]

theorem freeCount_mono (m : ℕ) (R : Finset ℕ) : Monotone (freeCount m R) := by
  exact fun n n' hn => Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono hn

/-- Periodicity: shifting the window by one full period adds exactly `R.card`
free coordinates, provided the admissible residues live below `m`. -/
theorem freeCount_add_period (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (n : ℕ) :
    freeCount m R (n + m) = freeCount m R n + R.card := by
  unfold freeCount;
  induction' n with n ih;
  · rcases m with ( _ | _ | m ) <;> simp_all +decide;
    · aesop;
    · congr 1 with i ; simp +decide;
      exact ⟨ fun hi => by simpa [ Nat.mod_eq_of_lt ( show i < m + 1 + 1 from by linarith ) ] using hi.2, fun hi => ⟨ by linarith [ Finset.mem_range.mp ( hR hi ) ], by simpa [ Nat.mod_eq_of_lt ( show i < m + 1 + 1 from by linarith [ Finset.mem_range.mp ( hR hi ) ] ) ] using hi ⟩ ⟩;
  · simp_all +decide [ Nat.succ_add, Finset.filter ];
    by_cases h : ( n + m ) % m ∈ R <;> by_cases h' : n % m ∈ R <;> simp_all +arith +decide

/-- `freeCount` at a multiple of the period is exactly `R.card` per period. -/
theorem freeCount_mul (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (q : ℕ) :
    freeCount m R (m * q) = R.card * q := by
  induction q <;> simp_all +decide [ Nat.mul_succ, mul_comm ]
  · exact freeCount_zero m R
  · rw [ freeCount_add_period m R hR, ‹freeCount m R _ = _› ]

/-- Lower sandwich bound. -/
theorem freeCount_lower (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (n : ℕ) :
    R.card * (n / m) ≤ freeCount m R n := by
  have h_freeCount_mul : freeCount m R (m * (n / m)) ≤ freeCount m R n := by
    exact freeCount_mono m R ( Nat.mul_div_le _ _ );
  rwa [ freeCount_mul m R hR ] at h_freeCount_mul

/-- Upper sandwich bound. -/
theorem freeCount_upper (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (hm : 1 ≤ m) (n : ℕ) :
    freeCount m R n ≤ R.card * (n / m) + R.card := by
  -- By monotonicity, `freeCount m R n ≤ freeCount m R (m * (n/m + 1))`.
  have h_mono : freeCount m R n ≤ freeCount m R (m * (n / m + 1)) := by
    exact freeCount_mono m R ( by nlinarith [ Nat.div_add_mod n m, Nat.mod_lt n hm ] );
  have := freeCount_mul m R hR ( n / m + 1 ) ; simp_all +decide [ Nat.mul_succ ] ;

theorem dimEstimate_densityTheory (m : ℕ) (R : Finset ℕ) (n : ℕ) :
    dimEstimate (densityTheory m R) n = (freeCount m R n : ℝ) / n := by
  unfold dimEstimate
  rw [count_densityTheory]
  have h : Real.logb 2 (((2 : ℕ) ^ (freeCount m R n) : ℕ) : ℝ) = freeCount m R n := by
    push_cast; rw [Real.logb_pow]; simp
  rw [h]

/-- The finite estimates of a periodic density theory converge to the density. -/
theorem tendsto_dimEstimate_densityTheory (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m)
    (hm : 1 ≤ m) :
    Tendsto (dimEstimate (densityTheory m R)) atTop (nhds (R.card / m)) := by
  rw [ Metric.tendsto_nhds ];
  intro ε hε;
  -- By the sandwich bounds, we have:
  have h_squeeze : ∀ n ≥ 1, abs (dimEstimate (densityTheory m R) n - (R.card : ℝ) / m) ≤ (R.card : ℝ) / n := by
    intro n hn
    have h_bound : (R.card : ℝ) * (n / m) - R.card ≤ freeCount m R n ∧ freeCount m R n ≤ (R.card : ℝ) * (n / m) + R.card := by
      have := freeCount_lower m R hR n; have := freeCount_upper m R hR hm n; simp_all +decide;
      rw [ mul_div, div_le_iff₀, le_iff_lt_or_eq ] <;> norm_cast;
      exact ⟨ lt_or_eq_of_le ( by nlinarith [ Nat.div_add_mod n m, Nat.mod_lt n hm ] ), by rw [ div_add', le_div_iff₀ ] <;> norm_cast <;> nlinarith [ Nat.div_mul_le_self n m ] ⟩;
    rw [ dimEstimate_densityTheory, abs_le ];
    field_simp at *;
    grind;
  exact Filter.eventually_atTop.mpr ⟨ ⌈ε⁻¹ * R.card⌉₊ + 1, fun n hn => lt_of_le_of_lt ( h_squeeze n <| by linarith ) <| by rw [ div_lt_iff₀ ] <;> nlinarith [ Nat.le_ceil ( ε⁻¹ * R.card ), mul_inv_cancel₀ hε.ne', show ( n : ℝ ) ≥ ⌈ε⁻¹ * R.card⌉₊ + 1 by exact_mod_cast hn ] ⟩

/-- **The periodic density theory has fractal dimension exactly `R.card / m`.** -/
theorem boxDim_densityTheory (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (hm : 1 ≤ m) :
    boxDim (densityTheory m R) = R.card / m :=
  (tendsto_dimEstimate_densityTheory m R hR hm).limsup_eq

/-! ### The dimension spectrum of truth is the whole rational unit interval -/

/-- **Every rational number in `[0,1]` is the fractal dimension of some theory of
truth.**  Given `p ≤ q` with `q ≥ 1`, the periodic density theory with modulus
`q` and admissible residues `{0,…,p-1}` has dimension exactly `p / q`. -/
theorem rational_dimension_realized (p q : ℕ) (hpq : p ≤ q) (hq : 1 ≤ q) :
    ∃ T : Theory, boxDim T = (p : ℝ) / q := by
  refine ⟨densityTheory q (Finset.range p), ?_⟩
  have hsub : (Finset.range p) ⊆ Finset.range q := by
    intro x hx; exact Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hpq)
  rw [boxDim_densityTheory q (Finset.range p) hsub hq, Finset.card_range]

/-! ### Recovering the extreme and half-information cases as instances

The three landmark values `0`, `1/2`, `1` of the base development are all special
cases of the density law, obtained by tuning `(m, R)`:

* `m = 1`, `R = {0}`  frees every coordinate: dimension `1` (the full space).
* `m = 2`, `R = {0}`  frees the even coordinates: dimension `1/2`.
* `m = 1`, `R = ∅`     frees nothing: dimension `0` (a single string per length).
-/

/-- **The full space of statements has dimension `1`**, as the density theory that
frees every coordinate. -/
theorem boxDim_full : boxDim (densityTheory 1 {0}) = 1 := by
  have h : ({0} : Finset ℕ) ⊆ Finset.range 1 := by decide
  rw [boxDim_densityTheory 1 {0} h (le_refl 1)]; simp

/-- **The half-information theory has dimension `1/2`**, recovering the base
result from the general density law with modulus `2`. -/
theorem boxDim_half : boxDim (densityTheory 2 {0}) = 1 / 2 := by
  have h : ({0} : Finset ℕ) ⊆ Finset.range 2 := by decide
  rw [boxDim_densityTheory 2 {0} h (by norm_num)]; norm_num

/-- **A maximally constrained theory has dimension `0`**, as the density theory
that frees no coordinate. -/
theorem boxDim_empty : boxDim (densityTheory 1 (∅ : Finset ℕ)) = 0 := by
  have h : (∅ : Finset ℕ) ⊆ Finset.range 1 := by simp
  rw [boxDim_densityTheory 1 (∅ : Finset ℕ) h (le_refl 1)]; simp

/-! ### Examples, generalizations, and boundaries (PEGB)

**Examples.**  The concrete instantiations below exhibit the density law at the
three landmark dimensions and check the counting engine on small inputs. -/

-- The free-coordinate count of the "even" theory on the first `6` lengths:
-- `2·⌈n/2⌉`-style growth `0,1,1,2,2,3`.
#eval (List.range 6).map (freeCount 2 {0})   -- [0, 1, 1, 2, 2, 3]

-- Free-coordinate counts of the density-`1/3` theory (modulus `3`, one residue):
-- `0,1,1,1,2,2,2,3,3` — asymptotic slope `1/3`.
#eval (List.range 9).map (freeCount 3 {0})   -- [0, 1, 1, 1, 2, 2, 2, 3, 3]

-- The counting law `count = 2 ^ freeCount` at length `4` for the even theory:
-- `2 ^ freeCount 2 {0} 4 = 2 ^ 2 = 4`.
#eval 2 ^ freeCount 2 {0} 4  -- 4

#check @boxDim_densityTheory
#check @rational_dimension_realized

example : boxDim (densityTheory 3 {0, 1}) = 2 / 3 := by
  have h : ({0, 1} : Finset ℕ) ⊆ Finset.range 3 := by decide
  rw [boxDim_densityTheory 3 {0, 1} h (by norm_num)]
  norm_num

example : ∃ T : Theory, boxDim T = (3 : ℝ) / 7 :=
  rational_dimension_realized 3 7 (by norm_num) (by norm_num)

/-!
**Generalization.**  `boxDim_densityTheory` is the broad statement: it computes
the dimension of *every* periodic density theory as the asymptotic density
`R.card / m` of information-bearing coordinates, and `rational_dimension_realized`
turns this into a surjectivity statement onto `[0,1] ∩ ℚ`.  A natural further
generalization replaces the exactly-periodic pattern by any coordinate set of
Dirichlet density `d`; the same squeeze then yields dimension `d`, extending the
realizable spectrum to all densities that are approximable from finite windows.

**Boundary.**  The construction is tight at both ends: `boxDim_full` (`R` full)
and `boxDim_empty` (`R` empty) show the bounds `0 ≤ boxDim ≤ 1` are attained, so
no strictly sharper universal bound exists.  The boundary case that genuinely
requires the `limsup` (rather than an honest limit) is an *aperiodic* theory
whose free-coordinate density oscillates: there the finite estimates do not
converge, only the `limsup` is stable — which is precisely why `boxDim` is
defined as a `limsup` and not a `lim`.
-/

end TruthFractalDimensionDeepening