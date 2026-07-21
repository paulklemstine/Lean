import Mathlib
import Bridges.GraphZetaPrimeCycle

/-!
# Reciprocal-zero harmonics: structural results and a diagnosis

For a finite window of complex spectral parameters, its harmonic is the sum of their
reciprocals.  This is the finite algebraic core of a proposed construction based on
nontrivial zeros of the Riemann zeta function.  The results below isolate three rigorous
features: reciprocal sums obey a counting bound, conjugation-symmetric windows have real
harmonics, and quadratic graph-zeta factors produce an exact rational harmonic whenever
their coefficients are rational.

The concrete assertions that the zeta-zero harmonics at cutoffs `2` and `3` are respectively
`1` and transcendental do not survive the definition: a window containing no zero has
harmonic `0`.  Numerically, both cutoffs lie below the first nontrivial zeta zero.  The file
therefore proves the exact empty-window diagnosis rather than encoding those assertions as
conjectures.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Reciprocal sums should inherit growth bounds from zero counts,
become real under conjugation symmetry, and reduce to coefficient ratios for quadratic
spectral factors.  A bolder hypothesis proposed distinct arithmetic behavior at cutoffs
`2` and `3`.
Experiment (Experimenter): Finite windows were tested against the triangle inequality,
conjugation, and the reciprocal-root identities of a quadratic Ihara factor.  Empty windows
were evaluated before any arithmetic classification was attempted.
Analysis (Analyst): The growth mechanism is structural: separation from zero converts a
cardinality estimate into a harmonic estimate.  Conjugate pairing removes imaginary parts.
The two small-cutoff claims fail at the preceding support question: both windows are empty,
so both harmonics coincide with zero.
Critique (Critic): No numerical approximation to a zeta zero is used as a theorem.  The
empty-window conclusions explicitly require a certified emptiness hypothesis.  The
quadratic bridge imports and uses the catalog's graph-zeta factorization, while its
nonvanishing assumptions prevent division by zero.
Synthesis (Principal Investigator): The viable research program begins with certified zero
windows and counting estimates.  Arithmetic classifications of their reciprocal sums can
only follow after those foundational data are supplied.
-/

open scoped BigOperators

namespace NumberTheoryMusic

/-- The reciprocal-sum harmonic of a finite spectral window. -/
noncomputable def harmonic (zeros : Finset ℂ) : ℂ :=
  ∑ z ∈ zeros, z⁻¹

/-- A finite window is stable under complex conjugation. -/
def ConjugationClosed (zeros : Finset ℂ) : Prop :=
  ∀ z : ℂ, z ∈ zeros ↔ starRingEnd ℂ z ∈ zeros

/-
A separated finite window has harmonic bounded by its cardinality divided by the
separation radius.  This is the basic transfer from zero-counting to harmonic growth.
-/
theorem harmonic_norm_le_card_div (zeros : Finset ℂ) {δ : ℝ} (hδ : 0 < δ)
    (hsep : ∀ z ∈ zeros, δ ≤ ‖z‖) :
    ‖harmonic zeros‖ ≤ (zeros.card : ℝ) / δ := by
  refine' le_trans ( norm_sum_le _ _ ) _;
  simpa [ div_eq_mul_inv ] using Finset.sum_le_sum fun x hx => inv_anti₀ hδ <| hsep x hx

/-
Pointwise zero-count estimates transfer directly to reciprocal-harmonic estimates.
-/
theorem harmonic_growth_transfer (windows : ℕ → Finset ℂ) (bound : ℕ → ℝ) {δ : ℝ}
    (hδ : 0 < δ)
    (hsep : ∀ n z, z ∈ windows n → δ ≤ ‖z‖)
    (hcount : ∀ n, ((windows n).card : ℝ) ≤ bound n) :
    ∀ n, ‖harmonic (windows n)‖ ≤ bound n / δ := by
  intro n; rw [ div_eq_mul_inv ] ; exact le_trans ( harmonic_norm_le_card_div ( windows n ) hδ ( hsep n ) ) ( mul_le_mul_of_nonneg_right ( hcount n ) ( by positivity ) ) ;

/-
In particular, a `C log n / log log n` counting estimate gives the same shape of
bound for the harmonic, up to the separation factor.
-/
theorem log_log_harmonic_bound (windows : ℕ → Finset ℂ) (C δ : ℝ)
    (hδ : 0 < δ)
    (hsep : ∀ n z, z ∈ windows n → δ ≤ ‖z‖)
    (hcount : ∀ n, ((windows n).card : ℝ) ≤ C * Real.log n / Real.log (Real.log n)) :
    ∀ n, ‖harmonic (windows n)‖ ≤
      (C / δ) * Real.log n / Real.log (Real.log n) := by
  convert @harmonic_growth_transfer windows
    (fun n => C * Real.log n / Real.log (Real.log n)) δ hδ hsep (fun n => hcount n) using 1
  ring_nf

/-
Conjugation symmetry forces the finite reciprocal harmonic to be real.
-/
theorem harmonic_im_eq_zero_of_conjugationClosed (zeros : Finset ℂ)
    (hclosed : ConjugationClosed zeros) :
    (harmonic zeros).im = 0 := by
  -- Since the window is closed under conjugation, we can pair each zero with its conjugate.
  have h_pair : ∑ z ∈ zeros, z⁻¹ = ∑ z ∈ zeros, (starRingEnd ℂ z)⁻¹ := by
    apply Finset.sum_bij (fun z _ => starRingEnd ℂ z);
    · exact fun x hx => hclosed x |>.1 hx;
    · exact fun x hx y hy hxy => star_inj.mp hxy;
    · exact fun z hz => ⟨ starRingEnd ℂ z, hclosed z |>.1 hz, by simp +decide ⟩;
    · norm_num;
  unfold harmonic;
  rw [ ← Complex.conj_eq_iff_im ];
  aesop

/-
An empty spectral window has zero harmonic.
-/
theorem harmonic_eq_zero_of_empty (zeros : Finset ℂ) (hempty : zeros = ∅) :
    harmonic zeros = 0 := by
  unfold harmonic; aesop;

/-
The claimed octave value `1` cannot occur when the cutoff-two window is empty.
-/
theorem cutoff_two_not_one_of_empty (windowTwo : Finset ℂ) (hempty : windowTwo = ∅) :
    harmonic windowTwo ≠ 1 := by
  unfold harmonic; aesop;

/-
Empty cutoff-two and cutoff-three windows have the same harmonic, namely zero.
-/
theorem small_cutoffs_coincide_of_empty (windowTwo windowThree : Finset ℂ)
    (hTwo : windowTwo = ∅) (hThree : windowThree = ∅) :
    harmonic windowTwo = harmonic windowThree ∧ harmonic windowThree = 0 := by
  -- The harmonic of an empty set is zero, so we can conclude the proof.
  simp [hTwo, hThree, harmonic]

/-
The claimed transcendence at cutoff three also fails for an empty window: zero is
annihilated by the nonzero polynomial `X` over the rationals.
-/
theorem cutoff_three_not_transcendental_of_empty (windowThree : Finset ℂ)
    (hempty : windowThree = ∅) :
    ¬ Transcendental ℚ (harmonic windowThree) := by
  rw [ hempty, harmonic_eq_zero_of_empty ];
  · exact fun h => h ( isAlgebraic_zero );
  · rfl

/-
The catalog's quadratic graph-zeta factorization converts a reciprocal-root harmonic
into the coefficient ratio `l/q`.  This is a finite exact analogue of a reciprocal-zero
explicit formula.
-/
theorem graphZeta_reciprocal_harmonic (l q α β : ℂ)
    (hs : α + β = l) (hp : α * β = q) (hq : q ≠ 0) (hne : α ≠ β) :
    harmonic {α, β} = l / q := by
  rw [ ← hs, ← hp, harmonic ];
  grind

/-
For rational graph-zeta coefficients, the two-root harmonic is rational.
-/
theorem graphZeta_rational_harmonic (l q : ℚ) (α β : ℂ)
    (hs : α + β = (l : ℂ)) (hp : α * β = (q : ℂ)) (hq : q ≠ 0) (hne : α ≠ β) :
    ∃ r : ℚ, harmonic {α, β} = (r : ℂ) := by
  refine' ⟨ l / q, _ ⟩;
  convert graphZeta_reciprocal_harmonic l q α β hs hp ( mod_cast hq ) hne using 1 ; norm_num [ hs, hp, hq, hne ]

/-- The finite graph-zeta bridge packages both the catalog factorization and the resulting
reciprocal harmonic identity in one statement. -/
theorem graphZeta_factorization_with_harmonic (l q α β : ℂ)
    (hs : α + β = l) (hp : α * β = q) (hq : q ≠ 0) (hne : α ≠ β) :
    (∀ u : ℂ, GraphZetaPrimeCycle.localFactor l q u =
      (1 - α * u) * (1 - β * u)) ∧ harmonic {α, β} = l / q := by
  constructor
  · intro u
    exact GraphZetaPrimeCycle.localFactor_factor l q u α β hs hp
  · exact graphZeta_reciprocal_harmonic l q α β hs hp hq hne

end NumberTheoryMusic