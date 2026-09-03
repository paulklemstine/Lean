import Catalog.NumberTheory.FootprintRecalibrationCeiling

/-!
# Mid-prime content is invisible to *every* footprint model, linear or not

`Catalog.NumberTheory.FootprintRecalibrationLimit` showed that no *reweighting*
of the small-prime dial features can recover content carried by the mid primes.
The natural objection is that the experiment only searched over linear scores:
maybe a nonlinear model of the same footprint would do better.  This file closes
that gap.

Splitting the residue data along a footprint set `s` of small primes,
`N ↦ (N|ₛ, N|ₛᶜ)`, the two halves are exactly independent.  Consequently, for a
target `G` that is an **arbitrary** function of the mid-prime coordinates and a
predictor `F` that is an **arbitrary** function of the footprint coordinates
(no linearity, no shape constraint at all):

* `avg_split` — exact independence of the two halves of the residue data.
* `mse_nonlinear_split` — the exact loss identity
  `𝔼[(G − F)²] = Var G + Var F + (𝔼F − 𝔼G)²`.
* `mse_const_eq_variance` — the zero-fit dial (the constant predictor `𝔼G`)
  achieves exactly `Var G`.
* `nonlinear_footprint_no_recovery` — **no footprint model of any kind beats the
  zero-fit dial**, and
* `nonlinear_footprint_strict_loss` — every *non-constant* footprint model is
  strictly worse, losing exactly `Var F + (𝔼F − 𝔼G)²`.

This is the sharp form of the round-45 #3 conclusion: the lost content is not
"badly weighted" small-prime information, it is not small-prime information at
all.
-/

namespace ScaleSmoothness

open Finset

section Variance

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- The variance is the mean squared deviation from the mean. -/
theorem variance_eq_avg_sub_sq (F : Ω → ℚ) : variance F = avg (fun ω => (F ω - avg F) ^ 2) := by
  have hexp : (fun ω => (F ω - avg F) ^ 2)
      = fun ω => ((F ω) ^ 2 - (2 * avg F) * F ω) + (avg F) ^ 2 := by
    funext ω; ring
  rw [hexp, avg_add, avg_sub, avg_const_mul, avg_const, variance]
  ring

theorem variance_nonneg (F : Ω → ℚ) : 0 ≤ variance F := by
  rw [variance_eq_avg_sub_sq]
  exact div_nonneg (Finset.sum_nonneg fun ω _ => sq_nonneg _) (by positivity)

/-- A non-constant observable has strictly positive variance. -/
theorem variance_pos_of_ne {F : Ω → ℚ} {ω₀ ω₁ : Ω} (h : F ω₀ ≠ F ω₁) : 0 < variance F := by
  rcases lt_or_eq_of_le (variance_nonneg F) with hlt | heq
  · exact hlt
  · exfalso
    have hsum : ∑ ω, (F ω - avg F) ^ 2 = 0 := by
      have h := (variance_eq_avg_sub_sq F).symm.trans heq.symm
      rw [avg, div_eq_zero_iff] at h
      rcases h with h | h
      · exact h
      · exact absurd h card_ne_zero
    have hall : ∀ ω ∈ (univ : Finset Ω), (F ω - avg F) ^ 2 = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg fun ω _ => sq_nonneg _).1 hsum
    have h0 : F ω₀ = avg F := by
      have := hall ω₀ (mem_univ ω₀)
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
      linarith
    have h1 : F ω₁ = avg F := by
      have := hall ω₁ (mem_univ ω₁)
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
      linarith
    exact h (h0.trans h1.symm)

theorem variance_const (t : ℚ) : variance (fun _ : Ω => t) = 0 := by
  rw [variance, avg_const, avg_const]
  ring

end Variance

section Split

variable {ι : Type*} [Fintype ι] [DecidableEq ι] (a : ι → ℕ) [∀ i, Fact (a i).Prime]
  (s : Finset ι)

/-- The footprint half of the residue data. -/
def restrictIn (N : ∀ k, ZMod (a k)) : ∀ i : {k // k ∈ s}, ZMod (a i.1) := fun i => N i.1

/-- The complementary (mid-prime / non-footprint) half of the residue data. -/
def restrictOut (N : ∀ k, ZMod (a k)) : ∀ i : {k // k ∉ s}, ZMod (a i.1) := fun i => N i.1

/-- **Exact independence of the two halves.**  Sums of products of a footprint
observable and a mid-prime observable factorise. -/
theorem sum_split (F : (∀ i : {k // k ∈ s}, ZMod (a i.1)) → ℚ)
    (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    ∑ N : (∀ k, ZMod (a k)), F (restrictIn a s N) * G (restrictOut a s N)
      = (∑ α, F α) * (∑ β, G β) := by
  have h := Equiv.sum_comp (Equiv.piEquivPiSubtypeProd (fun k => k ∈ s) (fun k => ZMod (a k)))
    (fun q => F q.1 * G q.2)
  have hL : (∑ N : (∀ k, ZMod (a k)), F (restrictIn a s N) * G (restrictOut a s N))
      = ∑ N : (∀ k, ZMod (a k)), (fun q => F q.1 * G q.2)
          (Equiv.piEquivPiSubtypeProd (fun k => k ∈ s) (fun k => ZMod (a k)) N) :=
    Finset.sum_congr rfl fun N _ => rfl
  rw [hL, h, Fintype.sum_prod_type, Finset.sum_mul_sum]

theorem card_split : (Fintype.card (∀ k, ZMod (a k)) : ℚ)
    = (Fintype.card (∀ i : {k // k ∈ s}, ZMod (a i.1)) : ℚ)
      * (Fintype.card (∀ i : {k // k ∉ s}, ZMod (a i.1)) : ℚ) := by
  have e := Equiv.piEquivPiSubtypeProd (fun k => k ∈ s) (fun k => ZMod (a k))
  rw [Fintype.card_congr e, Fintype.card_prod]
  push_cast
  ring

/-- **Independence in mean form.** -/
theorem avg_split (F : (∀ i : {k // k ∈ s}, ZMod (a i.1)) → ℚ)
    (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    avg (fun N => F (restrictIn a s N) * G (restrictOut a s N)) = avg F * avg G := by
  have hA : ((Fintype.card (∀ i : {k // k ∈ s}, ZMod (a i.1)) : ℚ)) ≠ 0 := card_ne_zero
  have hB : ((Fintype.card (∀ i : {k // k ∉ s}, ZMod (a i.1)) : ℚ)) ≠ 0 := card_ne_zero
  rw [avg, sum_split, card_split, avg, avg]
  field_simp

/-- The mean of a footprint observable, computed on the residue data, is its own
mean. -/
theorem avg_restrictIn (F : (∀ i : {k // k ∈ s}, ZMod (a i.1)) → ℚ) :
    avg (fun N => F (restrictIn a s N)) = avg F := by
  have h := avg_split a s F (fun _ => 1)
  simpa [avg_const] using h

/-- The mean of a mid-prime observable, computed on the residue data, is its own
mean. -/
theorem avg_restrictOut (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    avg (fun N => G (restrictOut a s N)) = avg G := by
  have h := avg_split a s (fun _ => 1) G
  simpa [avg_const] using h

theorem variance_restrictOut (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    variance (fun N => G (restrictOut a s N)) = variance G := by
  have hsq : avg (fun N => (G (restrictOut a s N)) ^ 2) = avg (fun β => (G β) ^ 2) := by
    have := avg_restrictOut a s (fun β => (G β) ^ 2)
    simpa using this
  rw [variance, variance, hsq, avg_restrictOut a s G]

/-- **The exact loss identity for an arbitrary footprint model.**  With `G` any
function of the mid primes and `F` any function of the footprint,
`𝔼[(G − F)²] = Var G + Var F + (𝔼F − 𝔼G)²`. -/
theorem mse_nonlinear_split (F : (∀ i : {k // k ∈ s}, ZMod (a i.1)) → ℚ)
    (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    avg (fun N => (G (restrictOut a s N) - F (restrictIn a s N)) ^ 2)
      = variance G + variance F + (avg F - avg G) ^ 2 := by
  have hexp : (fun N => (G (restrictOut a s N) - F (restrictIn a s N)) ^ 2)
      = fun N => (((G (restrictOut a s N)) ^ 2 - 2 * (F (restrictIn a s N)
          * G (restrictOut a s N))) + (F (restrictIn a s N)) ^ 2) := by
    funext N; ring
  have hG2 : avg (fun N => (G (restrictOut a s N)) ^ 2) = avg (fun β => (G β) ^ 2) := by
    have := avg_restrictOut a s (fun β => (G β) ^ 2)
    simpa using this
  have hF2 : avg (fun N => (F (restrictIn a s N)) ^ 2) = avg (fun α => (F α) ^ 2) := by
    have := avg_restrictIn a s (fun α => (F α) ^ 2)
    simpa using this
  have hcross : avg (fun N => 2 * (F (restrictIn a s N) * G (restrictOut a s N)))
      = 2 * (avg F * avg G) := by
    rw [avg_const_mul, avg_split]
  rw [hexp, avg_add, avg_sub, hG2, hF2, hcross, variance, variance]
  ring

/-- The **zero-fit dial** in this setting: the constant predictor `𝔼G` achieves
exactly the variance of the target. -/
theorem mse_const_eq_variance (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    avg (fun N => (G (restrictOut a s N) - (fun _ => avg G) (restrictIn a s N)) ^ 2)
      = variance G := by
  rw [mse_nonlinear_split a s (fun _ => avg G) G, variance_const, avg_const]
  ring

/-- **No footprint model of any kind recovers mid-prime content.**  For every
function `F` of the small-prime footprint — linear, nonlinear, arbitrary — the
loss is at least the zero-fit loss `Var G`. -/
theorem nonlinear_footprint_no_recovery (F : (∀ i : {k // k ∈ s}, ZMod (a i.1)) → ℚ)
    (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) :
    variance G ≤ avg (fun N => (G (restrictOut a s N) - F (restrictIn a s N)) ^ 2) := by
  rw [mse_nonlinear_split]
  have h1 := variance_nonneg F
  have h2 : (0 : ℚ) ≤ (avg F - avg G) ^ 2 := sq_nonneg _
  linarith

/-- **Every non-constant footprint model strictly loses**, by exactly
`Var F + (𝔼F − 𝔼G)²`.  A refit that moves any weight off zero necessarily lands
*below* the unrefit dial — the sign of the measured paired gain is forced. -/
theorem nonlinear_footprint_strict_loss {F : (∀ i : {k // k ∈ s}, ZMod (a i.1)) → ℚ}
    (G : (∀ i : {k // k ∉ s}, ZMod (a i.1)) → ℚ) {α₀ α₁ : ∀ i : {k // k ∈ s}, ZMod (a i.1)}
    (hF : F α₀ ≠ F α₁) :
    variance G < avg (fun N => (G (restrictOut a s N) - F (restrictIn a s N)) ^ 2) := by
  rw [mse_nonlinear_split]
  have h1 := variance_pos_of_ne hF
  have h2 : (0 : ℚ) ≤ (avg F - avg G) ^ 2 := sq_nonneg _
  linarith

end Split

end ScaleSmoothness