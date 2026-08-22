/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightsConvolution
import Applications.PTEIdealWitnesses

/-!
# The growth base of invisible vectors: from `6^{K/3}` down to `24^{K/12}`

`Applications/InvisibleWeightsConvolution.lean` established the composition law — windows add
and masses multiply under convolution — and iterated the `K = 3` witness of mass `6` to get
nonzero invisible vectors of mass `≤ 6 ^ n` at window `K = 3n`, i.e. growth base
`6^{1/3} ≈ 1.817` instead of the binomial `2`.

The ideal Prouhet–Tarry–Escott pair of size `12` constructed in
`Applications/PTEIdealWitnesses.lean` is a *much* cheaper seed: mass `24` at window `12`.
Feeding it into the same composition law lowers the base to `24^{1/12} ≈ 1.3034`, and the
improvement is exponential in the window: at window `12n` the catalog's bound was `6^{4n} =
1296^n` and the bound proved here is `24^n`.

## Main results

* `exists_invisible_pow_of_seed` — **the engine, parametrised by a seed.**  Any invisible
  seed of window `K₀` and mass `L` whose first visible moment is nonzero yields, for every
  `n`, a nonzero vector invisible to the window `K₀ n` of mass `≤ L ^ n`.  (The catalog's
  `exists_invisible_l1_le_six_pow` is the case `(K₀, L) = (3, 6)`.)
* `exists_invisible_l1_le_24_pow` — the instantiation at the ideal seed: mass `≤ 24 ^ n` at
  window `12 n`.
* `l1_24_pow_beats_six_pow` — the quantitative comparison `24 ^ n · 54 ^ n = 6 ^ (4n)`: at
  the same window the new bound is smaller by the factor `54 ^ n`.
* `minMass_le_pow_ceil` — for **every** window `K`, `minMass K ≤ 24 ^ ⌈K / 12⌉`; with
  `PTESize.l1_ge_two_mul_window` this brackets the minimal mass between `2K` and
  `24 ^ ⌈K/12⌉`.
* `minMass_pow_twelve_le` — the base statement in integer form:
  `(minMass K) ^ 12 ≤ 24 ^ (K + 11)`, i.e. the growth base is at most `24^{1/12} < 1.31`.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Mass is submultiplicative under convolution while windows are
additive, so the growth base is `inf_K minMass(K)^{1/K}`.  Since `minMass K = 2K` for all
tested `K`, the base should be `inf_K (2K)^{1/K}`, which tends to `1`: **there should be no
exponential lower bound at all.**  Bold form: `minMass K` is polynomial in `K`.

EXPERIMENT (Experimenter).  Every seed we can certify gives an unconditional upper bound.
The best certified seed is `K₀ = 12`, `L = 24`, giving base `24^{1/12} ≈ 1.3034`
(`exists_invisible_l1_le_24_pow`).  Getting below this by the same route needs ideal pairs
of size `> 12`, none of which is known — so the bold hypothesis is *not* refuted, but it is
also out of reach of the convolution engine alone.

ANALYSIS (Analyst).  The engine converts *any* future ideal pair of size `n₀` into base
`(2n₀)^{1/n₀}`, so the polynomial-mass conjecture is equivalent, for this method, to the
existence of ideal pairs of unbounded size — the central open problem of the
Prouhet–Tarry–Escott theory.  The formal engine here is therefore a *reduction*: new
witnesses drop in without touching any proof.

CRITIQUE (Critic).  The bound `minMass K ≤ 24 ^ ⌈K/12⌉` is genuinely nontrivial only for
`K ≥ 13`; below that the exact values of `PTEIdealWitnesses` are stronger, and we say so
rather than dressing the weaker bound as new.  The seed's first visible moment is checked to
be nonzero (`seed_moment_top_ne_zero`), without which the induction would collapse to the
zero vector and the statement would be vacuous.
-/

open Finset

namespace PTEBase

open PowerSumSharpness InvisibleWeights PTESize PTEWitness

/-! ## The convolution engine, parametrised by a seed -/

/-- **The seeded engine.**  From a nonzero invisible seed `w` of window `K₀`, support in
`{0,…,M}` and mass `L`, convolution produces vectors invisible to the window `K₀ n` of mass
at most `L ^ n`, for every `n`. -/
theorem exists_invisible_pow_of_seed {M K₀ : ℕ} {w : ℕ → ℤ} {L : ℤ}
    (hw : Invisible M K₀ w) (htop : moment M w K₀ ≠ 0)
    (hL : ∑ a ∈ range (M + 1), |w a| = L) (n : ℕ) :
    ∃ (N : ℕ) (e : ℕ → ℤ), (∀ j, N < j → e j = 0) ∧ Invisible N (K₀ * n) e ∧
      moment N e (K₀ * n) ≠ 0 ∧ ∑ j ∈ range (N + 1), |e j| ≤ L ^ n := by
  induction n with
  | zero =>
      refine ⟨0, fun j => if j = 0 then 1 else 0, ?_, ?_, ?_, ?_⟩
      · intro j hj
        show (if j = 0 then (1 : ℤ) else 0) = 0
        rw [if_neg (by omega)]
      · intro k hk
        omega
      · simp [moment]
      · simp
  | succ n ih =>
      obtain ⟨N, e, hsupp, hinv, htopn, hl1⟩ := ih
      refine ⟨N + M, kconv M w e, kconv_of_gt hsupp, ?_, ?_, ?_⟩
      · have h := kconv_invisible hsupp hinv hw
        rwa [show K₀ * n + K₀ = K₀ * (n + 1) by ring] at h
      · have h := moment_kconv_top hsupp hinv hw
        rw [show K₀ * (n + 1) = K₀ * n + K₀ by ring, h]
        exact mul_ne_zero (mul_ne_zero
          (by exact_mod_cast (Nat.choose_pos (by omega : K₀ * n ≤ K₀ * n + K₀)).ne') htopn) htop
      · have h := l1_kconv_le (M := M) (w := w) hsupp
        rw [hL] at h
        have hLnonneg : 0 ≤ L := by
          rw [← hL]
          exact Finset.sum_nonneg fun a _ => abs_nonneg _
        calc ∑ j ∈ range (N + M + 1), |kconv M w e j|
            ≤ L * ∑ i ∈ range (N + 1), |e i| := h
          _ ≤ L * L ^ n := by exact mul_le_mul_of_nonneg_left hl1 hLnonneg
          _ = L ^ (n + 1) := by ring

/-! ## The ideal seed of window `12` and mass `24` -/

/-- The nodes of the ideal Prouhet–Tarry–Escott pair of size `12` (a translate of the
symmetric Letac configuration). -/
def seedA : List ℕ := [0, 11, 24, 65, 90, 129, 173, 212, 237, 278, 291, 302]

/-- The complementary nodes of the ideal pair of size `12`. -/
def seedB : List ℕ := [3, 5, 30, 57, 104, 116, 186, 198, 245, 272, 297, 299]

/-- The seed weight vector: `+1` on `seedA`, `-1` on `seedB`. -/
def seed : ℕ → ℤ := listWeight seedA seedB

lemma seedA_le : ∀ a ∈ seedA, a ≤ 302 := by decide
lemma seedB_le : ∀ b ∈ seedB, b ≤ 302 := by decide
lemma seed_disj : ∀ j ∈ seedA, j ∉ seedB := by decide
lemma seedA_ne_nil : seedA ≠ [] := by decide
lemma seed_pte : ∀ k < 12, listPowerSum seedA k = listPowerSum seedB k := by decide

theorem seed_invisible : Invisible 302 12 seed :=
  (pte_pair seedA_le seedB_le seed_disj seedA_ne_nil seed_pte).2.1

theorem seed_mass : ∑ j ∈ range 303, |seed j| = 24 := by
  have h := (pte_pair seedA_le seedB_le seed_disj seedA_ne_nil seed_pte).2.2.2.2
  simpa [seed, seedA, seedB] using h

/-- The seed becomes visible immediately after its window: its `12`-th moment is nonzero.
(The two sides differ already in the twelfth power sum.) -/
theorem seed_moment_top_ne_zero : moment 302 seed 12 ≠ 0 := by
  have h := (pte_pair seedA_le seedB_le seed_disj seedA_ne_nil seed_pte).2.2.2.1 12
  rw [show (moment 302 seed 12) = moment 302 (listWeight seedA seedB) 12 from rfl, h]
  have hne : listPowerSum seedA 12 ≠ listPowerSum seedB 12 := by decide
  intro hzero
  exact hne (by exact_mod_cast sub_eq_zero.mp hzero)

/-! ## The improved growth base -/

/-- **The new record base.**  At every window `K = 12 n` there is a nonzero integral vector
invisible to the window whose mass is at most `24 ^ n`, i.e. `(24^{1/12})^K ≈ 1.3034^K`. -/
theorem exists_invisible_l1_le_24_pow (n : ℕ) :
    ∃ (N : ℕ) (e : ℕ → ℤ), Invisible N (12 * n) e ∧ (∃ j ≤ N, e j ≠ 0) ∧
      ∑ j ∈ range (N + 1), |e j| ≤ 24 ^ n := by
  obtain ⟨N, e, -, hinv, htop, hl1⟩ :=
    exists_invisible_pow_of_seed seed_invisible seed_moment_top_ne_zero seed_mass n
  refine ⟨N, e, hinv, ?_, hl1⟩
  by_contra hcon
  push_neg at hcon
  refine htop (Finset.sum_eq_zero fun j hj => ?_)
  rw [hcon j (Nat.lt_succ_iff.mp (mem_range.mp hj)), zero_mul]

/-- **Strict improvement over the catalog's record.**  At the common window `12n` the old
bound was `6 ^ (4n)` and the new one is `24 ^ n`: the ratio is exactly `54 ^ n`. -/
theorem l1_24_pow_beats_six_pow (n : ℕ) : (24 : ℤ) ^ n * 54 ^ n = 6 ^ (4 * n) := by
  rw [← mul_pow, pow_mul]
  norm_num

/-- … and the improvement is strict for every `n ≥ 1`. -/
theorem l1_24_pow_lt_six_pow {n : ℕ} (hn : 1 ≤ n) : (24 : ℤ) ^ n < 6 ^ (4 * n) := by
  rw [← l1_24_pow_beats_six_pow n]
  have h1 : (0 : ℤ) < 24 ^ n := by positivity
  have h2 : (54 : ℤ) ^ 1 ≤ 54 ^ n := pow_le_pow_right₀ (by norm_num) hn
  nlinarith

/-! ## Consequences for `minMass` -/

/-- Any construction of mass at most `B` bounds `minMass` by `B`. -/
theorem minMass_le_of_bound {K : ℕ} {B : ℕ} {N : ℕ} {e : ℕ → ℤ} (hinv : Invisible N K e)
    (hnz : ∃ j ≤ N, e j ≠ 0) (hb : ∑ j ∈ range (N + 1), |e j| ≤ (B : ℤ)) :
    minMass K ≤ B := by
  set m : ℤ := ∑ j ∈ range (N + 1), |e j| with hm
  have hm0 : 0 ≤ m := Finset.sum_nonneg fun j _ => abs_nonneg _
  have hach : MassAchievable K m.toNat := ⟨N, e, hinv, hnz, by rw [Int.toNat_of_nonneg hm0]⟩
  have h1 : minMass K ≤ m.toNat := minMass_le hach
  have h2 : m.toNat ≤ B := by omega
  omega

/-- **The bracket.**  For every window `K`, `2K ≤ minMass K ≤ 24 ^ ⌈K/12⌉`. -/
theorem minMass_le_pow_ceil (K : ℕ) : minMass K ≤ 24 ^ ((K + 11) / 12) := by
  obtain ⟨N, e, hinv, hnz, hl1⟩ := exists_invisible_l1_le_24_pow ((K + 11) / 12)
  have hwin : K ≤ 12 * ((K + 11) / 12) := by omega
  refine minMass_le_of_bound (invisible_mono hwin hinv) hnz ?_
  simpa using hl1

/-- **The growth base is at most `24^{1/12} < 1.31`.**  Stated without real exponentials:
the twelfth power of the minimal mass is at most `24 ^ (K + 11)`. -/
theorem minMass_pow_twelve_le (K : ℕ) : (minMass K) ^ 12 ≤ 24 ^ (K + 11) := by
  have h := minMass_le_pow_ceil K
  calc (minMass K) ^ 12 ≤ (24 ^ ((K + 11) / 12)) ^ 12 := Nat.pow_le_pow_left h 12
    _ = 24 ^ (12 * ((K + 11) / 12)) := by rw [← pow_mul, Nat.mul_comm]
    _ ≤ 24 ^ (K + 11) := Nat.pow_le_pow_right (by norm_num) (by omega)

/-- The two sides of the bracket, side by side. -/
theorem minMass_bracket (K : ℕ) : 2 * K ≤ minMass K ∧ minMass K ≤ 24 ^ ((K + 11) / 12) :=
  ⟨two_mul_le_minMass K, minMass_le_pow_ceil K⟩

end PTEBase