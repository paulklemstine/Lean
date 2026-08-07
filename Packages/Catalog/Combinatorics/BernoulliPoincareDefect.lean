/-
# The exact Poincaré (Efron–Stein) defect on the biased cube

`Catalog/Combinatorics/BernoulliPoincare.lean` proves the variance–influence
inequality `P(1-P) ≤ p(1-p) ∑_v I_v` for increasing events by a hybrid-path
union bound, and `Catalog/Combinatorics/BernoulliFourierParseval.lean` provides
the complete `p`-biased Fourier expansion of functions on the cube.  This file
combines the two and computes the *defect* in that inequality exactly — first
for arbitrary real functions on the cube, then for increasing events.

The mechanism is the one-coordinate decomposition of a function into a part that
does not depend on the coordinate and a multiple of the character of that
coordinate:

* `IndepOf v f` says that `f` does not depend on the coordinate `v`;
* `fun_decomp`: `f = avgAt p v f + ψ_v · derivAt v f`, where
  `derivAt v f η = f(η with v open) - f(η with v closed)`;
* `expP_psi_mul_of_indep`, `expP_psi_sq_mul_of_indep`: the two one-coordinate
  integrals `E[ψ_v h] = 0` and `E[ψ_v² h] = p(1-p) E[h]` for `h` independent of
  the coordinate `v`;
* `fcoeff_erase_of_mem`: consequently the Fourier coefficients of `f` at the sets
  containing `v` are exactly the Fourier coefficients of `derivAt v f` at the
  corresponding sets not containing `v`;
* `siteFourierEnergy_eq`: the Fourier energy of `f` carried by the sets
  containing `v` equals `p(1-p) E[(derivAt v f)²]`.  This is the biased analogue
  of the classical identity `Inf_v(f) = ∑_{S ∋ v} \hat f(S)²`;
* `total_fourierEnergy`: summing over `v` counts each level `S` with
  multiplicity `|S|`;
* `efron_stein_defect_identity` and `efron_stein_poincare`: subtracting the
  Fourier form of the variance gives, for *every* real function on the cube,
  `p(1-p) ∑_v E[(derivAt v f)²] - Var f = ∑_{S ≠ ∅} (|S| - 1) (p(1-p))^{|S|}
  \hat f(S)² ≥ 0`.

Specializing to the `±1`-indicator of an increasing event, whose discrete
derivative takes only the values `0` and `2`, turns `E[(derivAt v f)²]` into
`4 I_v` and yields:

* `siteEnergy_eq_influence`: the energy above a site is `4 p(1-p) I_v`;
* `total_influence_fourier`: `4 p(1-p) ∑_v I_v = ∑_S |S| (p(1-p))^{|S|}
  \hat g(S)²`;
* `poincare_defect_identity`, `bernProb_poincare_of_defect`: the Poincaré
  inequality with an exact remainder;
* `poincare_eq_iff_degree_le_one`: the variance inequality is tight precisely
  when the event has no Fourier weight above level one.

Together with `sum_sq_influence_le` (the `ℓ²` bound, which is the statement that
the level-`≥ 2` energy is nonnegative) this pins down both classical influence
inequalities as one and the same Fourier energy accounting.
-/

import Combinatorics.BernoulliFourierParseval

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Functions that do not depend on one coordinate -/

/-- `f` does not depend on the coordinate `v`. -/
def IndepOf (v : ι) (f : (ι → Bool) → ℝ) : Prop :=
  ∀ (η : ι → Bool) (b : Bool), f (Function.update η v b) = f η

omit [Fintype ι] in
theorem IndepOf.mul {v : ι} {f g : (ι → Bool) → ℝ} (hf : IndepOf v f) (hg : IndepOf v g) :
    IndepOf v (fun η => f η * g η) := fun η b => by
  simp only [hf η b, hg η b]

omit [Fintype ι] in
/-- A character of a set of sites not containing `v` does not depend on the
coordinate `v`. -/
theorem indepOf_psiSet (p : ℝ) {v : ι} {S : Finset ι} (hv : v ∉ S) :
    IndepOf v (psiSet p S) := by
  intro η b
  refine Finset.prod_congr rfl fun u hu => ?_
  have : u ≠ v := fun h => hv (h ▸ hu)
  rw [psi, psi, Function.update_of_ne this]

omit [Fintype ι] in
theorem psiSet_erase (p : ℝ) {v : ι} {S : Finset ι} (hv : v ∈ S) (η : ι → Bool) :
    psiSet p S η = psi p v η * psiSet p (S.erase v) η :=
  (Finset.mul_prod_erase S (fun u => psi p u η) hv).symm

/-! ## The two one-coordinate integrals -/

/-- `E[ψ_v h] = 0` whenever `h` does not depend on the coordinate `v`. -/
theorem expP_psi_mul_of_indep (p : ℝ) {v : ι} {h : (ι → Bool) → ℝ} (hh : IndepOf v h) :
    expP p (fun η => psi p v η * h η) = 0 := by
  rw [expP_split p v]
  refine Finset.sum_eq_zero fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have h1 : psi p v η = 1 - p := by rw [psi, hη]; norm_num
  have h2 : psi p v (Function.update η v false) = -p := by
    rw [psi, Function.update_self]; norm_num
  have h3 : h (Function.update η v false) = h η := hh η false
  rw [h1, h2, h3]
  ring

/-- `E[ψ_v² h] = p(1-p) E[h]` whenever `h` does not depend on the coordinate
`v`. -/
theorem expP_psi_sq_mul_of_indep (p : ℝ) {v : ι} {h : (ι → Bool) → ℝ} (hh : IndepOf v h) :
    expP p (fun η => psi p v η * psi p v η * h η) = (p * (1 - p)) * expP p h := by
  rw [expP_split p v, expP_split p v, Finset.mul_sum]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have h1 : psi p v η = 1 - p := by rw [psi, hη]; norm_num
  have h2 : psi p v (Function.update η v false) = -p := by
    rw [psi, Function.update_self]; norm_num
  have h3 : h (Function.update η v false) = h η := hh η false
  rw [h1, h2, h3]
  ring

/-! ## The one-coordinate decomposition of an arbitrary function -/

/-- The discrete derivative of `f` at the site `v`. -/
def derivAt (v : ι) (f : (ι → Bool) → ℝ) (η : ι → Bool) : ℝ :=
  f (Function.update η v true) - f (Function.update η v false)

/-- The average of `f` over the coordinate `v`. -/
def avgAt (p : ℝ) (v : ι) (f : (ι → Bool) → ℝ) (η : ι → Bool) : ℝ :=
  p * f (Function.update η v true) + (1 - p) * f (Function.update η v false)

omit [Fintype ι] in
theorem indepOf_derivAt (v : ι) (f : (ι → Bool) → ℝ) : IndepOf v (derivAt v f) := by
  intro η b
  simp only [derivAt, Function.update_idem]

omit [Fintype ι] in
theorem indepOf_avgAt (p : ℝ) (v : ι) (f : (ι → Bool) → ℝ) : IndepOf v (avgAt p v f) := by
  intro η b
  simp only [avgAt, Function.update_idem]

omit [Fintype ι] in
/-- **The one-coordinate decomposition.** -/
theorem fun_decomp (p : ℝ) (v : ι) (f : (ι → Bool) → ℝ) (η : ι → Bool) :
    f η = avgAt p v f η + psi p v η * derivAt v f η := by
  rcases Bool.eq_false_or_eq_true (η v) with hv | hv
  · have hupd : Function.update η v true = η := Function.update_eq_self_iff.mpr hv.symm
    have hpsi : psi p v η = 1 - p := by rw [psi, hv]; norm_num
    simp only [avgAt, derivAt, hpsi, hupd]
    ring
  · have hupd : Function.update η v false = η := Function.update_eq_self_iff.mpr hv.symm
    have hpsi : psi p v η = -p := by rw [psi, hv]; norm_num
    simp only [avgAt, derivAt, hpsi, hupd]
    ring

/-! ## Fourier coefficients at sets containing a given site -/

/-- A function independent of the coordinate `v` has vanishing Fourier
coefficients at every set containing `v`. -/
theorem fcoeff_eq_zero_of_indep (p : ℝ) {v : ι} {f : (ι → Bool) → ℝ} (hf : IndepOf v f)
    {S : Finset ι} (hv : v ∈ S) : fcoeff p f S = 0 := by
  have hzero : expP p (fun η => f η * psiSet p S η) = 0 := by
    have hrw : (fun η : ι → Bool => f η * psiSet p S η)
        = fun η : ι → Bool => psi p v η * (f η * psiSet p (S.erase v) η) := by
      funext η
      rw [psiSet_erase p hv]
      ring
    rw [hrw]
    exact expP_psi_mul_of_indep p (hf.mul (indepOf_psiSet p (Finset.notMem_erase v S)))
  rw [fcoeff, hzero, zero_div]

/-- **The Fourier coefficients above a site are those of the discrete
derivative.** -/
theorem fcoeff_erase_of_mem {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ)
    {v : ι} {S : Finset ι} (hv : v ∈ S) :
    fcoeff p f S = fcoeff p (derivAt v f) (S.erase v) := by
  have hq : (0 : ℝ) < p * (1 - p) := mul_pos hp0 (by linarith)
  have hcard : S.card = (S.erase v).card + 1 := by
    rw [Finset.card_erase_of_mem hv]
    have : 1 ≤ S.card := Finset.card_pos.mpr ⟨v, hv⟩
    omega
  have hkey : expP p (fun η => f η * psiSet p S η)
      = (p * (1 - p)) * expP p (fun η => derivAt v f η * psiSet p (S.erase v) η) := by
    have hrw : (fun η : ι → Bool => f η * psiSet p S η)
        = fun η : ι → Bool => psi p v η * (avgAt p v f η * psiSet p (S.erase v) η)
            + psi p v η * psi p v η * (derivAt v f η * psiSet p (S.erase v) η) := by
      funext η
      rw [psiSet_erase p hv]
      nth_rewrite 1 [fun_decomp p v f η]
      ring
    rw [hrw]
    have hsplit : expP p (fun η => psi p v η * (avgAt p v f η * psiSet p (S.erase v) η)
          + psi p v η * psi p v η * (derivAt v f η * psiSet p (S.erase v) η))
        = expP p (fun η => psi p v η * (avgAt p v f η * psiSet p (S.erase v) η))
          + expP p (fun η => psi p v η * psi p v η
              * (derivAt v f η * psiSet p (S.erase v) η)) := by
      unfold expP
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun η _ => by ring
    rw [hsplit,
      expP_psi_mul_of_indep p
        ((indepOf_avgAt p v f).mul (indepOf_psiSet p (Finset.notMem_erase v S))),
      expP_psi_sq_mul_of_indep p
        ((indepOf_derivAt v f).mul (indepOf_psiSet p (Finset.notMem_erase v S))),
      zero_add]
  set q : ℝ := p * (1 - p) with hqdef
  have hqne : q ≠ 0 := ne_of_gt hq
  rw [fcoeff, fcoeff, hkey, hcard, pow_succ, mul_comm (q ^ (S.erase v).card) q]
  exact mul_div_mul_left _ _ hqne

/-! ## The Fourier energy above a single site -/

/-- The Fourier energy of `f` carried by the level `S`. -/
noncomputable def fourierEnergy (p : ℝ) (f : (ι → Bool) → ℝ) (S : Finset ι) : ℝ :=
  (p * (1 - p)) ^ S.card * (fcoeff p f S) ^ 2

/-- The Fourier energy of `f` carried by all levels containing the site `v`. -/
noncomputable def siteFourierEnergy (p : ℝ) (f : (ι → Bool) → ℝ) (v : ι) : ℝ :=
  ∑ S ∈ univ.filter (fun S : Finset ι => v ∈ S), fourierEnergy p f S

theorem fourierEnergy_nonneg {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ)
    (S : Finset ι) : 0 ≤ fourierEnergy p f S := by
  have hq : (0 : ℝ) ≤ p * (1 - p) := le_of_lt (mul_pos hp0 (by linarith))
  rw [fourierEnergy]
  positivity

/-- **The energy above a site is the variance of the discrete derivative.**  This
is the `p`-biased form of the classical identity `Inf_v(f) = ∑_{S ∋ v}
\hat f(S)²`. -/
theorem siteFourierEnergy_eq {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ)
    (v : ι) :
    siteFourierEnergy p f v
      = (p * (1 - p)) * expP p (fun η => derivAt v f η * derivAt v f η) := by
  classical
  have hq : (0 : ℝ) < p * (1 - p) := mul_pos hp0 (by linarith)
  -- reindex the sets containing `v` by the sets avoiding `v`
  have hreindex : siteFourierEnergy p f v
      = ∑ T ∈ univ.filter (fun T : Finset ι => v ∉ T),
          (p * (1 - p)) ^ (T.card + 1) * (fcoeff p (derivAt v f) T) ^ 2 := by
    rw [siteFourierEnergy]
    refine Finset.sum_nbij' (fun S => S.erase v) (fun T => insert v T) ?_ ?_ ?_ ?_ ?_
    · intro S hS
      simp only [mem_filter, mem_univ, true_and] at hS ⊢
      exact Finset.notMem_erase v S
    · intro T hT
      simp only [mem_filter, mem_univ, true_and] at hT ⊢
      exact Finset.mem_insert_self v T
    · intro S hS
      simp only [mem_filter, mem_univ, true_and] at hS
      exact Finset.insert_erase hS
    · intro T hT
      simp only [mem_filter, mem_univ, true_and] at hT
      exact Finset.erase_insert hT
    · intro S hS
      simp only [mem_filter, mem_univ, true_and] at hS
      rw [fourierEnergy, fcoeff_erase_of_mem hp0 hp1 f hS, Finset.card_erase_of_mem hS]
      have h1 : 1 ≤ S.card := Finset.card_pos.mpr ⟨v, hS⟩
      congr 2
      omega
  -- the coefficients of the derivative at sets containing `v` vanish
  have hvanish : ∀ T ∈ univ.filter (fun T : Finset ι => v ∈ T),
      (p * (1 - p)) ^ T.card * (fcoeff p (derivAt v f) T) ^ 2 = 0 := by
    intro T hT
    simp only [mem_filter, mem_univ, true_and] at hT
    rw [fcoeff_eq_zero_of_indep p (indepOf_derivAt v f) hT]
    ring
  have hfull : ∑ T : Finset ι, (p * (1 - p)) ^ T.card * (fcoeff p (derivAt v f) T) ^ 2
      = ∑ T ∈ univ.filter (fun T : Finset ι => v ∉ T),
          (p * (1 - p)) ^ T.card * (fcoeff p (derivAt v f) T) ^ 2 := by
    rw [← Finset.sum_filter_add_sum_filter_not univ (fun T : Finset ι => v ∈ T),
      Finset.sum_eq_zero hvanish, zero_add]
  have hpar := parseval hp0 hp1 (derivAt v f) (derivAt v f)
  rw [hreindex]
  have hpull : ∑ T ∈ univ.filter (fun T : Finset ι => v ∉ T),
        (p * (1 - p)) ^ (T.card + 1) * (fcoeff p (derivAt v f) T) ^ 2
      = (p * (1 - p)) * ∑ T ∈ univ.filter (fun T : Finset ι => v ∉ T),
          (p * (1 - p)) ^ T.card * (fcoeff p (derivAt v f) T) ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun T _ => by rw [pow_succ]; ring
  rw [hpull, ← hfull, hpar]
  refine congrArg _ (Finset.sum_congr rfl fun T _ => by rw [pow_two])

/-- **Counting each level with its cardinality.** -/
theorem total_fourierEnergy (p : ℝ) (f : (ι → Bool) → ℝ) :
    ∑ v : ι, siteFourierEnergy p f v
      = ∑ S : Finset ι, (S.card : ℝ) * fourierEnergy p f S := by
  classical
  have h1 : ∀ v : ι, siteFourierEnergy p f v
      = ∑ S : Finset ι, (if v ∈ S then fourierEnergy p f S else 0) := fun v => by
    rw [siteFourierEnergy, Finset.sum_filter]
  rw [Finset.sum_congr rfl fun v (_ : v ∈ univ) => h1 v, Finset.sum_comm]
  refine Finset.sum_congr rfl fun S _ => ?_
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]

/-! ## The Efron–Stein defect for an arbitrary function -/

/-- **The exact Efron–Stein / Poincaré defect.**  For every real function on the
cube, the gap in the Poincaré inequality is the Fourier energy of the levels
`|S| ≥ 2`, each counted `|S| - 1` times. -/
theorem efron_stein_defect_identity {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    (f : (ι → Bool) → ℝ) :
    (p * (1 - p)) * ∑ v : ι, expP p (fun η => derivAt v f η * derivAt v f η)
        - (expP p (fun η => f η * f η) - (expP p f) ^ 2)
      = ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
          ((S.card : ℝ) - 1) * fourierEnergy p f S := by
  classical
  have hsite : (p * (1 - p)) * ∑ v : ι, expP p (fun η => derivAt v f η * derivAt v f η)
      = ∑ S : Finset ι, (S.card : ℝ) * fourierEnergy p f S := by
    rw [← total_fourierEnergy p f, Finset.mul_sum]
    exact Finset.sum_congr rfl fun v _ => (siteFourierEnergy_eq hp0 hp1 f v).symm
  have hvar : expP p (fun η => f η * f η) - (expP p f) ^ 2
      = ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅), fourierEnergy p f S := by
    rw [expP_sq_sub_sq_expP hp0 hp1 f]
    rfl
  have hcard : ∑ S : Finset ι, (S.card : ℝ) * fourierEnergy p f S
      = ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
          (S.card : ℝ) * fourierEnergy p f S := by
    rw [← Finset.sum_filter_add_sum_filter_not univ (fun S : Finset ι => S = ∅)]
    have hzero : ∑ S ∈ univ.filter (fun S : Finset ι => S = ∅),
        (S.card : ℝ) * fourierEnergy p f S = 0 := by
      rw [Finset.filter_eq' univ (∅ : Finset ι), if_pos (Finset.mem_univ _),
        Finset.sum_singleton]
      simp
    rw [hzero, zero_add]
  rw [hsite, hvar, hcard, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun S _ => by ring

/-- Every term of the defect is nonnegative. -/
theorem defect_nonneg {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ) :
    0 ≤ ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
      ((S.card : ℝ) - 1) * fourierEnergy p f S := by
  refine Finset.sum_nonneg fun S hS => ?_
  simp only [mem_filter, mem_univ, true_and] at hS
  have hcard : 1 ≤ S.card := Finset.card_pos.mpr (Finset.nonempty_iff_ne_empty.mpr hS)
  have h1 : (0 : ℝ) ≤ (S.card : ℝ) - 1 := by
    have : (1 : ℝ) ≤ (S.card : ℝ) := by exact_mod_cast hcard
    linarith
  exact mul_nonneg h1 (fourierEnergy_nonneg hp0 hp1 f S)

/-- **The Poincaré (Efron–Stein) inequality for an arbitrary function on the
biased cube.** -/
theorem efron_stein_poincare {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (f : (ι → Bool) → ℝ) :
    expP p (fun η => f η * f η) - (expP p f) ^ 2
      ≤ (p * (1 - p)) * ∑ v : ι, expP p (fun η => derivAt v f η * derivAt v f η) := by
  have h := efron_stein_defect_identity hp0 hp1 f
  have hnn := defect_nonneg hp0 hp1 f
  linarith

/-! ## Specialization to an increasing event -/

/-- The Fourier energy of the `±1`-indicator of `A` carried by the level `S`. -/
noncomputable def levelEnergy (p : ℝ) (A : Set (ι → Bool)) (S : Finset ι) : ℝ :=
  fourierEnergy p (signInd A) S

/-- The Fourier energy of the `±1`-indicator of `A` carried by all levels
containing the site `v`. -/
noncomputable def siteEnergy (p : ℝ) (A : Set (ι → Bool)) (v : ι) : ℝ :=
  siteFourierEnergy p (signInd A) v

omit [Fintype ι] in
/-- For an increasing event the discrete derivative of the `±1`-indicator takes
only the values `0` and `2`, so it satisfies `D² = 2 D`. -/
theorem signDeriv_sq {A : Set (ι → Bool)} (hA : IsIncreasing A) (v : ι) (η : ι → Bool) :
    derivAt v (signInd A) η * derivAt v (signInd A) η
      = 2 * derivAt v (signInd A) η := by
  classical
  unfold derivAt signInd
  by_cases h1 : Function.update η v true ∈ A
  · by_cases h2 : Function.update η v false ∈ A
    · rw [if_pos h1, if_pos h2]; ring
    · rw [if_pos h1, if_neg h2]; ring
  · have h2 : Function.update η v false ∉ A := by
      intro hc
      refine h1 (hA _ _ (fun u hu => ?_) hc)
      by_cases huv : u = v
      · subst huv; simp
      · rw [Function.update_of_ne huv] at hu
        rwa [Function.update_of_ne huv]
    rw [if_neg h1, if_neg h2]; ring

/-- The mean of the discrete derivative of an increasing event is twice the
influence of the site. -/
theorem expP_signDeriv {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) (v : ι) :
    expP p (derivAt v (signInd A)) = 2 * bernProb p (pivotalSet A v) := by
  have hq : (0 : ℝ) < p * (1 - p) := mul_pos hp0 (by linarith)
  have hdecomp : expP p (fun η => signInd A η * psi p v η)
      = (p * (1 - p)) * expP p (derivAt v (signInd A)) := by
    have hrw : (fun η : ι → Bool => signInd A η * psi p v η)
        = fun η : ι → Bool => psi p v η * avgAt p v (signInd A) η
            + psi p v η * psi p v η * derivAt v (signInd A) η := by
      funext η
      nth_rewrite 1 [fun_decomp p v (signInd A) η]
      ring
    rw [hrw]
    have hsplit : expP p (fun η => psi p v η * avgAt p v (signInd A) η
          + psi p v η * psi p v η * derivAt v (signInd A) η)
        = expP p (fun η => psi p v η * avgAt p v (signInd A) η)
          + expP p (fun η => psi p v η * psi p v η * derivAt v (signInd A) η) := by
      unfold expP
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun η _ => by ring
    rw [hsplit, expP_psi_mul_of_indep p (indepOf_avgAt p v (signInd A)),
      expP_psi_sq_mul_of_indep p (indepOf_derivAt v (signInd A)), zero_add]
  rw [expP_signInd_mul_psi hA p v] at hdecomp
  have hne : (p * (1 - p)) ≠ 0 := ne_of_gt hq
  field_simp at hdecomp
  nlinarith [hdecomp]

/-- **The energy above a site equals the influence of that site.** -/
theorem siteEnergy_eq_influence {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) (v : ι) :
    siteEnergy p A v = 4 * (p * (1 - p)) * bernProb p (pivotalSet A v) := by
  rw [siteEnergy, siteFourierEnergy_eq hp0 hp1 (signInd A) v]
  have hsq : (fun η : ι → Bool => derivAt v (signInd A) η * derivAt v (signInd A) η)
      = fun η : ι → Bool => 2 * derivAt v (signInd A) η :=
    funext fun η => signDeriv_sq hA v η
  rw [hsq, expP_const_mul, expP_signDeriv hp0 hp1 hA v]
  ring

/-- **The Fourier formula for the total influence.**  Each level `S` is counted
with multiplicity `|S|`. -/
theorem total_influence_fourier {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    4 * (p * (1 - p)) * ∑ v : ι, bernProb p (pivotalSet A v)
      = ∑ S : Finset ι, (S.card : ℝ) * levelEnergy p A S := by
  classical
  have hsite : ∑ v : ι, siteEnergy p A v
      = 4 * (p * (1 - p)) * ∑ v : ι, bernProb p (pivotalSet A v) := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun v _ => siteEnergy_eq_influence hp0 hp1 hA v
  rw [← hsite]
  exact total_fourierEnergy p (signInd A)

/-- **The exact Poincaré defect of an increasing event.** -/
theorem poincare_defect_identity {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    4 * (p * (1 - p)) * ∑ v : ι, bernProb p (pivotalSet A v)
        - 4 * (bernProb p A * (1 - bernProb p A))
      = ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
          ((S.card : ℝ) - 1) * levelEnergy p A S := by
  classical
  have hgen := efron_stein_defect_identity hp0 hp1 (signInd A)
  have hsite : (p * (1 - p))
      * ∑ v : ι, expP p (fun η => derivAt v (signInd A) η * derivAt v (signInd A) η)
      = 4 * (p * (1 - p)) * ∑ v : ι, bernProb p (pivotalSet A v) := by
    rw [Finset.mul_sum, Finset.mul_sum]
    refine Finset.sum_congr rfl fun v _ => ?_
    have hsq : (fun η : ι → Bool => derivAt v (signInd A) η * derivAt v (signInd A) η)
        = fun η : ι → Bool => 2 * derivAt v (signInd A) η :=
      funext fun η => signDeriv_sq hA v η
    rw [hsq, expP_const_mul, expP_signDeriv hp0 hp1 hA v]
    ring
  have hvar : expP p (fun η => signInd A η * signInd A η) - (expP p (signInd A)) ^ 2
      = 4 * (bernProb p A * (1 - bernProb p A)) := by
    rw [expP_signInd_sq, expP_signInd]
    ring
  rw [hsite, hvar] at hgen
  exact hgen

/-- **The Poincaré inequality, recovered from the defect identity.** -/
theorem bernProb_poincare_of_defect {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    bernProb p A * (1 - bernProb p A) ≤ (p * (1 - p)) * ∑ v : ι, bernProb p (pivotalSet A v) := by
  have h := poincare_defect_identity hp0 hp1 hA
  have hnn := defect_nonneg hp0 hp1 (signInd A)
  have heq : ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
      ((S.card : ℝ) - 1) * levelEnergy p A S
      = ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
          ((S.card : ℝ) - 1) * fourierEnergy p (signInd A) S := rfl
  rw [heq] at h
  linarith

/-- **The equality case of the Poincaré inequality.**  The variance–influence
inequality is an equality exactly when the `±1`-indicator has no Fourier weight
above level one. -/
theorem poincare_eq_iff_degree_le_one {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    bernProb p A * (1 - bernProb p A)
        = (p * (1 - p)) * ∑ v : ι, bernProb p (pivotalSet A v)
      ↔ ∀ S : Finset ι, 2 ≤ S.card → fcoeff p (signInd A) S = 0 := by
  classical
  have hdef := poincare_defect_identity hp0 hp1 hA
  have hterm : ∀ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
      0 ≤ ((S.card : ℝ) - 1) * levelEnergy p A S := by
    intro S hS
    simp only [mem_filter, mem_univ, true_and] at hS
    have hcard : 1 ≤ S.card := Finset.card_pos.mpr (Finset.nonempty_iff_ne_empty.mpr hS)
    have h1 : (0 : ℝ) ≤ (S.card : ℝ) - 1 := by
      have : (1 : ℝ) ≤ (S.card : ℝ) := by exact_mod_cast hcard
      linarith
    exact mul_nonneg h1 (fourierEnergy_nonneg hp0 hp1 (signInd A) S)
  constructor
  · intro heq S hS
    have hzero : ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
        ((S.card : ℝ) - 1) * levelEnergy p A S = 0 := by linarith
    have hSmem : S ∈ univ.filter (fun S : Finset ι => S ≠ ∅) := by
      refine Finset.mem_filter.mpr ⟨Finset.mem_univ S, ?_⟩
      intro hc
      rw [hc] at hS
      simp at hS
    have hSzero : ((S.card : ℝ) - 1) * levelEnergy p A S = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg hterm).mp hzero S hSmem
    have hcpos : (0 : ℝ) < (S.card : ℝ) - 1 := by
      have : (2 : ℝ) ≤ (S.card : ℝ) := by exact_mod_cast hS
      linarith
    have hE : levelEnergy p A S = 0 := by
      rcases mul_eq_zero.mp hSzero with h | h
      · exact absurd h (ne_of_gt hcpos)
      · exact h
    have hqpow : ((p * (1 - p)) ^ S.card : ℝ) ≠ 0 :=
      pow_ne_zero _ (ne_of_gt (mul_pos hp0 (by linarith)))
    rw [levelEnergy, fourierEnergy] at hE
    rcases mul_eq_zero.mp hE with h | h
    · exact absurd h hqpow
    · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h
  · intro hdeg
    have hzero : ∑ S ∈ univ.filter (fun S : Finset ι => S ≠ ∅),
        ((S.card : ℝ) - 1) * levelEnergy p A S = 0 := by
      refine Finset.sum_eq_zero fun S hS => ?_
      simp only [mem_filter, mem_univ, true_and] at hS
      have hcard : 1 ≤ S.card := Finset.card_pos.mpr (Finset.nonempty_iff_ne_empty.mpr hS)
      rcases Nat.lt_or_ge S.card 2 with hlt | hge
      · have : S.card = 1 := by omega
        rw [this]
        norm_num
      · rw [levelEnergy, fourierEnergy, hdeg S hge]
        ring
    linarith

end BernoulliThresholdCoupling