import MachineLearning.QRResidual.MeanDial
import MachineLearning.QRResidual.ResidualLift

/-!
# Capstone: what the footprint dial can and cannot do

This file couples the arithmetic of the QR footprint dial (`FootprintWeight`, `MeanDial`,
`Blindness`) with the exact least-squares theory of a feature lift (`ResidualLift`), and
records machine-checked instances of every identity on concrete data.

Main results.

* `footprint_rsq_strict_lift`, `footprint_rsq_lift_bound` — augmenting any baseline fit by
  the footprint feature strictly raises `R²`, by at least `⟨r,v⟩²/(‖v‖²·TSS)`, exactly when
  the baseline residual correlates with the feature.  This is the formal content of the
  experiment's "H3 refuted: the residual was real structure".
* `footprint_no_lift_iff_orthogonal` — conversely, zero lift forces exact orthogonality.
* `sqNorm_footprintFeature_ne_zero` — a usable nondegeneracy criterion for the design.
* `dial_classifier_blind` — **barrier (5) in final form**: *no* classifier built on the
  dial can separate primes from semiprimes; each dial value is shared by arbitrarily large
  primes and arbitrarily large semiprimes.

The `LabNotes` section at the end contains kernel-checked instances of the dichotomy, of
the mean-footprint identity and of the dial values used in the write-up.
-/

namespace QRResidual

open Finset

/-! ## The footprint feature of a finite design -/

/-- The footprint feature vector of a finite sample of moduli. -/
def footprintFeature (B : ℕ) {ι : Type*} (Nsam : ι → ℤ) : ι → ℝ :=
  fun i => (qrWeight (Nsam i) B : ℝ)

/-- Nondegeneracy criterion: the feature vector is nonzero as soon as one sampled modulus
has at least one quadratic-residue prime in the factor base. -/
theorem sqNorm_footprintFeature_ne_zero {ι : Type*} [Fintype ι] (B : ℕ) (Nsam : ι → ℤ)
    {i : ι} (hi : qrWeight (Nsam i) B ≠ 0) : sqNorm (footprintFeature B Nsam) ≠ 0 := by
  intro h
  have := (sqNorm_eq_zero_iff (footprintFeature B Nsam)).1 h i
  simp only [footprintFeature] at this
  exact hi (by exact_mod_cast this)

/-! ## The lift theorems, instantiated at the footprint feature -/

/-- **Strict `R²` lift.**  If the residual of a baseline dial `g` correlates with the
footprint feature, then the augmented model class strictly beats the baseline. -/
theorem footprint_rsq_strict_lift {ι : Type*} [Fintype ι] (B : ℕ) (Nsam : ι → ℤ)
    (y g : ι → ℝ) (htss : 0 < tss y)
    (hv : sqNorm (footprintFeature B Nsam) ≠ 0)
    (hcorr : dot (y - g) (footprintFeature B Nsam) ≠ 0) :
    rsqOf y g < rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • footprintFeature B Nsam} :=
  rsq_augment_strict (fun t => ⟨t, rfl⟩) hv htss hcorr

/-- **Quantitative `R²` lift.**  The lift is at least the squared residual correlation
divided by `‖v‖² · TSS`. -/
theorem footprint_rsq_lift_bound {ι : Type*} [Fintype ι] (B : ℕ) (Nsam : ι → ℤ)
    (y g : ι → ℝ) (htss : 0 < tss y)
    (hv : sqNorm (footprintFeature B Nsam) ≠ 0) :
    rsqOf y g
        + (dot (y - g) (footprintFeature B Nsam)) ^ 2
            / (sqNorm (footprintFeature B Nsam) * tss y)
      ≤ rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • footprintFeature B Nsam} :=
  rsq_augment_ge (fun t => ⟨t, rfl⟩) hv htss

/-- **The H3 dichotomy for the footprint feature.**  Either the residual correlates with
the feature (and then `R²` strictly increases), or the residual is exactly orthogonal to
it.  There is no third possibility, so an observed lift is a certificate of structure. -/
theorem footprint_no_lift_iff_orthogonal {ι : Type*} [Fintype ι] (B : ℕ) (Nsam : ι → ℤ)
    (y g : ι → ℝ) (htss : 0 < tss y)
    (hv : sqNorm (footprintFeature B Nsam) ≠ 0) :
    rsq y {h : ι → ℝ | ∃ t : ℝ, h = g + t • footprintFeature B Nsam} ≤ rsqOf y g
      ↔ dot (y - g) (footprintFeature B Nsam) = 0 := by
  constructor
  · intro hno
    exact residual_orthogonal_of_no_lift
      (T := {h : ι → ℝ | ∃ t : ℝ, h = g + t • footprintFeature B Nsam})
      (fun t => ⟨t, rfl⟩) hv htss hno
  · intro horth
    -- with an orthogonal residual the optimal step along the feature is `t = 0`
    set v := footprintFeature B Nsam with hvdef
    set T := {h : ι → ℝ | ∃ t : ℝ, h = g + t • v} with hT
    have hne : T.Nonempty := ⟨g, 0, by simp⟩
    have hlow : sqNorm (y - g) ≤ rss y T := by
      refine le_rss hne ?_
      rintro h ⟨t, rfl⟩
      have hrw : y - (g + t • v) = (y - g) - t • v := by
        funext i; simp [Pi.sub_apply, Pi.add_apply]; ring
      rw [hrw, sqNorm_sub_smul, horth]
      nlinarith [sqNorm_nonneg v, sq_nonneg t]
    unfold rsq rsqOf
    have := (div_le_div_iff_of_pos_right htss).2 hlow
    linarith

/-! ## The second feature: the small-prime mechanism dial -/

/-- The *mechanism* feature of the experiment: the expected fraction of sieve values
divisible by a small prime, i.e. the raw footprint weight over the small factor base
`p ≤ B₀`.  By `mean_footprint_eq_sum` this is exactly the mean number of small-prime hits
per sieve location. -/
def mechanismFeature (B₀ : ℕ) {ι : Type*} (Nsam : ι → ℤ) : ι → ℝ :=
  fun i => (footprintWeight (Nsam i) B₀ : ℝ)

/-- **Orthogonal features add their lifts.**  If, in the sample, the QR footprint feature
and the small-prime mechanism feature are orthogonal, then fitting both lifts `R²` by at
least the *sum* of the two individual lifts — the formal counterpart of the experiment's
"the direct mechanism feature adds independently". -/
theorem two_feature_rsq_lift {ι : Type*} [Fintype ι] (B B₀ : ℕ) (Nsam : ι → ℤ)
    (y g : ι → ℝ) (htss : 0 < tss y)
    (hv : sqNorm (footprintFeature B Nsam) ≠ 0)
    (hw : sqNorm (mechanismFeature B₀ Nsam) ≠ 0)
    (horth : dot (footprintFeature B Nsam) (mechanismFeature B₀ Nsam) = 0) :
    rsqOf y g
        + (dot (y - g) (footprintFeature B Nsam)) ^ 2
            / (sqNorm (footprintFeature B Nsam) * tss y)
        + (dot (y - g) (mechanismFeature B₀ Nsam)) ^ 2
            / (sqNorm (mechanismFeature B₀ Nsam) * tss y)
      ≤ rsq y {h : ι → ℝ |
          ∃ t s : ℝ, h = g + t • footprintFeature B Nsam + s • mechanismFeature B₀ Nsam} :=
  rsq_plane_ge hv hw horth htss

/-- **Neither dial determines the other.**  For any prime of the large factor base beyond
the small bound there are two moduli with equal mechanism-scale dial and different QR
dial, so the two features are not functionally dependent and the second one can carry
information the first does not. -/
theorem footprint_and_mechanism_independent {B₀ B p : ℕ} (hB : B₀ ≤ B)
    (hp : p ∈ oddFactorBase B) (hpB₀ : ¬ p ≤ B₀) :
    ∃ N₁ N₂ : ℤ, qrWeight N₁ B₀ = qrWeight N₂ B₀ ∧ qrWeight N₁ B ≠ qrWeight N₂ B :=
  dials_functionally_independent hB hp hpB₀

/-! ## Barrier (5): the dial carries no factor information -/

/-- **No dial-based classifier can see the factorisation.**  For any decision rule `c`
built on the dial value and any modulus `N` coprime to the factor base, there are
arbitrarily large primes and arbitrarily large semiprimes on which `c` returns exactly the
same verdict as on `N`. -/
theorem dial_classifier_blind (B : ℕ) (N : ℤ)
    (hcop : IsCoprime N (basePrimorial B : ℤ)) (c : ℚ → Bool) (n : ℕ) :
    ∃ q r s : ℕ, n < q ∧ q.Prime ∧ r.Prime ∧ s.Prime ∧ r ≠ s ∧ n < r * s ∧
      c (qrWeight (q : ℤ) B) = c (qrWeight N B) ∧
      c (qrWeight ((r * s : ℕ) : ℤ) B) = c (qrWeight N B) := by
  obtain ⟨q, hqn, hqp, hq⟩ := qrWeight_blind_to_primality B N hcop n
  obtain ⟨r, s, hrp, hsp, hrs, hrsn, hrsw⟩ := qrWeight_blind_semiprime B N hcop n
  exact ⟨q, r, s, hqn, hqp, hrp, hsp, hrs, hrsn, by rw [hq], by rw [hrsw]⟩

/-! ## Lab notes: kernel-checked instances

All numbers below were produced by evaluating the definitions of this development and are
re-verified here by the kernel. -/

section LabNotes

/-- The odd factor base up to `20`. -/
example : oddFactorBase 20 = {3, 5, 7, 11, 13, 17, 19} := by decide

/-- `N = 1649` (the textbook quadratic-sieve modulus): `7` is admissible and hits twice
per period. -/
example : hitCount 1649 7 = 2 := by decide

/-- `N = 1649`: `13` is inadmissible and never hits — the `2 / 0` dichotomy in action. -/
example : hitCount 1649 13 = 0 := by decide

/-- The ramified case: `1649 = 17 · 97`, so `17 ∣ N` and there is exactly one hit. -/
example : hitCount 1649 17 = 1 := by decide

/-- The QR primes of `N = 1649` inside the factor base `{3,5,7,11,13,17,19}`. -/
example : (oddFactorBase 20).filter (fun p => IsQR 1649 p) = {5, 7, 17} := by decide

/-- The dial value at `N = 1649` with factor base bound `20`:
`2/5 + 2/7 + 2/17 = 478/595`. -/
example : qrWeight 1649 20 = 478 / 595 := by
  have h : (oddFactorBase 20).filter (fun p => IsQR 1649 p) = {5, 7, 17} := by decide
  rw [qrWeight, h]
  norm_num

/-- The dial is nonconstant, hence a usable regressor: `N = 1` is a residue everywhere,
so its dial is the maximal value `Σ_{3 ≤ p ≤ 19} 2/p`. -/
example : qrWeight 1 20 = 9267838 / 4849845 := by
  have h : (oddFactorBase 20).filter (fun p => IsQR 1 p) = {3, 5, 7, 11, 13, 17, 19} := by
    decide
  rw [qrWeight, h]
  norm_num

/-- Mean-footprint identity on a small case (`S = {3,5}`, `N = 1`, period `15`):
the total number of `(x, p)` hits over one period is `15 · (2/3 + 2/5) = 16`. -/
example :
    (∑ x ∈ range 15,
      (({3, 5} : Finset ℕ).filter (fun p : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - 1))).card) = 16 := by
  decide

/-- The same total, read off the right-hand side of `mean_footprint_eq_sum`. -/
example : (15 : ℚ) * ((hitCount 1 3 : ℚ) / 3 + (hitCount 1 5 : ℚ) / 5) = 16 := by
  have h3 : hitCount 1 3 = 2 := by decide
  have h5 : hitCount 1 5 = 2 := by decide
  rw [h3, h5]
  norm_num

/-- One period of moduli mod `7`: the hit counts sum to `7` (`sum_hitCount_residues`,
i.e. paper 130's exact cancellation). -/
example : ∑ N ∈ range 7, hitCount (N : ℤ) 7 = 7 := by decide

/-- Exactly `(7+1)/2 = 4` of the residues mod `7` are quadratic residues. -/
example : ((range 7).filter (fun N : ℕ => IsQR (N : ℤ) 7)).card = 4 := by decide

end LabNotes

end QRResidual