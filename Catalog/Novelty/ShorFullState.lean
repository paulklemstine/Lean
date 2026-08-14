import Novelty.ShorMatchRank

/-! # The full Shor state is exponentially entangled: Schmidt rank exactly `r`

The state produced by the modular-exponentiation stage of Shor's algorithm is

`|ψ⟩ = Q^{-1/2} ∑_{x < Q} |x⟩ |a^x mod N⟩`,

with `Q` the size of the exponent register and `r = ord_N(a)`.  This file
computes *exactly* the entanglement data of `|ψ⟩` across the register cut,
under the only structural hypothesis that matters:

`HasExactPeriod r F : F x = F y ↔ x ≡ y (mod r)`,

which holds for `F x = a^x` with `r = orderOf a` (`hasExactPeriod_powFun`).

Main results (for `Q = r * m`, `0 < r`, `0 < m`):

* `schmidtRank_shorState` : the Schmidt rank across the cut is **exactly `r`**;
* `normalized_shorState` : the state is a unit vector;
* `entanglementEntropy_shorState` : `S = log r` — the maximum compatible with
  the rank, i.e. the Schmidt spectrum is *flat* (`flatSchmidtSpectrum_shorState`);
* `mutualInformation_shorState` : `I(A:B) = 2 log r`;
* `bondDim_shorState_ge` / `not_hasBondDim_shorState` : every MPS / tensor-train
  representation across the cut needs bond dimension `≥ r`, so no
  `poly(log N)`-bond-dimension emulation of the state exists unless `r` is
  itself polynomially small.

The last item is the precise obstruction to the "tensor-train QFT emulation"
proposal: its low-rank precondition already fails at the *input* of the QFT.
-/

open Finset Matrix
open scoped ComplexOrder

namespace ShorIrreducible

open IITTensorNetwork

section Periodic

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- `F` has *exact period `r`*: its level sets are precisely the residue classes
modulo `r`.  For `F x = a ^ x` this says `r` is the multiplicative order of `a`. -/
def HasExactPeriod (r : ℕ) {Q : ℕ} (F : Fin Q → β) : Prop :=
  ∀ x y : Fin Q, F x = F y ↔ (x : ℕ) % r = (y : ℕ) % r

/-- The number of elements of `Fin (r * m)` in a fixed residue class mod `r`. -/
lemma card_residue_class {r m j : ℕ} (hr : 0 < r) (hj : j < r) :
    ((univ : Finset (Fin (r * m))).filter fun x : Fin (r * m) => (x : ℕ) % r = j).card = m := by
  classical
  have hbound : ∀ t : Fin m, j + r * (t : ℕ) < r * m := by
    intro t
    have ht : (t : ℕ) + 1 ≤ m := t.2
    calc j + r * (t : ℕ) < r + r * (t : ℕ) := Nat.add_lt_add_right hj _
      _ = r * ((t : ℕ) + 1) := by ring
      _ ≤ r * m := Nat.mul_le_mul_left r ht
  have key : ((univ : Finset (Fin (r * m))).filter fun x : Fin (r * m) => (x : ℕ) % r = j).card
      = (univ : Finset (Fin m)).card := by
    refine Finset.card_nbij'
      (fun x : Fin (r * m) => (⟨(x : ℕ) / r, Nat.div_lt_of_lt_mul x.isLt⟩ : Fin m))
      (fun t : Fin m => (⟨j + r * (t : ℕ), hbound t⟩ : Fin (r * m))) ?_ ?_ ?_ ?_
    · intro x _
      exact Finset.mem_coe.mpr (Finset.mem_univ _)
    · intro t _
      refine Finset.mem_coe.mpr (Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩)
      show (j + r * (t : ℕ)) % r = j
      rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hj]
    · intro x hx
      have hx' : (x : ℕ) % r = j := (Finset.mem_filter.mp (Finset.mem_coe.mp hx)).2
      apply Fin.ext
      show j + r * ((x : ℕ) / r) = (x : ℕ)
      rw [← hx']
      exact Nat.mod_add_div _ _
    · intro t _
      apply Fin.ext
      show (j + r * (t : ℕ)) / r = (t : ℕ)
      rw [Nat.add_mul_div_left _ _ hr, Nat.div_eq_of_lt hj, zero_add]
  rw [key, Finset.card_univ, Fintype.card_fin]

variable {Q r : ℕ} {F : Fin Q → β}

omit [Fintype β] in
/-- The image of an exactly `r`-periodic function on a register of size a
multiple of `r` has exactly `r` elements. -/
lemma card_image_of_hasExactPeriod {m : ℕ} (hr : 0 < r) (hm : 0 < m)
    {F : Fin (r * m) → β} (hF : HasExactPeriod r F) :
    ((univ : Finset (Fin (r * m))).image F).card = r := by
  classical
  have hemb : ∀ j : Fin r, (j : ℕ) < r * m := by
    intro j
    calc (j : ℕ) < r := j.2
      _ = r * 1 := (mul_one r).symm
      _ ≤ r * m := Nat.mul_le_mul_left r hm
  set G : Fin r → β := fun j => F ⟨(j : ℕ), hemb j⟩ with hG
  have himg : (univ : Finset (Fin (r * m))).image F = (univ : Finset (Fin r)).image G := by
    apply Finset.Subset.antisymm
    · intro b hb
      obtain ⟨x, -, rfl⟩ := Finset.mem_image.mp hb
      have hlt : (x : ℕ) % r < r := Nat.mod_lt _ hr
      refine Finset.mem_image.mpr ⟨⟨(x : ℕ) % r, hlt⟩, Finset.mem_univ _, ?_⟩
      rw [hG]
      refine ((hF _ _).mpr ?_).symm
      show (x : ℕ) % r = ((x : ℕ) % r) % r
      rw [Nat.mod_mod_of_dvd _ dvd_rfl]
    · intro b hb
      obtain ⟨j, -, rfl⟩ := Finset.mem_image.mp hb
      exact Finset.mem_image.mpr ⟨⟨(j : ℕ), hemb j⟩, Finset.mem_univ _, rfl⟩
  have hinj : Function.Injective G := by
    intro i j hij
    have := (hF _ _).mp hij
    simp only at this
    rw [Nat.mod_eq_of_lt i.2, Nat.mod_eq_of_lt j.2] at this
    exact Fin.ext this
  rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin]

omit [Fintype β] in
/-- Every fibre of an exactly `r`-periodic function on `Fin (r * m)` has
cardinality `m`: the level sets are the residue classes. -/
lemma fibreCard_of_hasExactPeriod {m : ℕ} (hr : 0 < r) {F : Fin (r * m) → β}
    (hF : HasExactPeriod r F) {b : β} (hb : b ∈ (univ : Finset (Fin (r * m))).image F) :
    fibreCard F b = m := by
  classical
  obtain ⟨x0, -, rfl⟩ := Finset.mem_image.mp hb
  have hfil : (univ.filter fun x : Fin (r * m) => F x = F x0)
      = (univ : Finset (Fin (r * m))).filter fun x : Fin (r * m) =>
          (x : ℕ) % r = (x0 : ℕ) % r := by
    apply Finset.filter_congr
    intro x _
    simpa using hF x x0
  rw [fibreCard, hfil]
  exact card_residue_class hr (Nat.mod_lt _ hr)

end Periodic

/-! ## The Shor register state -/

section ShorState

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- The **Shor register state** `Q^{-1/2} ∑_x |x⟩|F x⟩`, presented as its
coefficient matrix across the cut between the exponent register and the
function register. -/
noncomputable def shorState (Q : ℕ) (F : Fin Q → β) : Matrix (Fin Q) β ℂ :=
  matchMatrix F (id : β → β) (Real.sqrt Q)⁻¹

omit [Fintype β] in
lemma shorState_apply (Q : ℕ) (F : Fin Q → β) (x : Fin Q) (y : β) :
    shorState Q F x y = if F x = y then (((Real.sqrt Q)⁻¹ : ℝ) : ℂ) else 0 := rfl

lemma fibreCard_id (b : β) : fibreCard (id : β → β) b = 1 := by
  classical
  have hs : (univ.filter fun f : β => id f = b) = {b} := by
    ext x; simp
  rw [fibreCard, hs, Finset.card_singleton]

lemma matchSet_id (F : Fin Q → β) :
    matchSet F (id : β → β) = (univ : Finset (Fin Q)).image F := by
  classical
  rw [matchSet, Finset.image_id, Finset.inter_univ]

variable {r m : ℕ} {F : Fin (r * m) → β}

/-- **The Schmidt rank of the full Shor state across the register cut is exactly
the multiplicative order `r`.** -/
theorem schmidtRank_shorState (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F) :
    schmidtRank (shorState (r * m) F) = r := by
  have hQ : (0 : ℝ) < ((r * m : ℕ) : ℝ) := by
    have : 0 < r * m := Nat.mul_pos hr hm
    exact_mod_cast this
  have hc : ((Real.sqrt ((r * m : ℕ) : ℝ))⁻¹ : ℝ) ≠ 0 :=
    inv_ne_zero (by positivity)
  rw [shorState, schmidtRank_matchMatrix hc, matchSet_id,
    card_image_of_hasExactPeriod hr hm hF]

/-- The Shor state is a unit vector. -/
theorem normalized_shorState (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F) :
    Normalized (shorState (r * m) F) := by
  classical
  refine normalized_matchMatrix ?_
  rw [matchSet_id]
  have hstep : ∀ b ∈ (univ : Finset (Fin (r * m))).image F,
      ((Real.sqrt ((r * m : ℕ) : ℝ))⁻¹) ^ 2 *
        ((fibreCard F b : ℝ) * (fibreCard (id : β → β) b : ℝ)) = (r : ℝ)⁻¹ := by
    intro b hb
    rw [fibreCard_of_hasExactPeriod hr hF hb, fibreCard_id]
    have hQ : (0 : ℝ) < ((r * m : ℕ) : ℝ) := by
      have : 0 < r * m := Nat.mul_pos hr hm
      exact_mod_cast this
    rw [inv_pow, Real.sq_sqrt hQ.le]
    push_cast
    field_simp
  rw [Finset.sum_congr rfl hstep, Finset.sum_const, card_image_of_hasExactPeriod hr hm hF,
    nsmul_eq_mul]
  field_simp

/-- **The entanglement entropy of the full Shor state is `log r`** — the Schmidt
spectrum is flat, so the state is maximally entangled for its rank and carries
no decaying tail that a truncated MPS could discard. -/
theorem entanglementEntropy_shorState (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F) :
    entanglementEntropy (shorState (r * m) F) = Real.log r := by
  classical
  have hcard : (matchSet F (id : β → β)).card = r := by
    rw [matchSet_id, card_image_of_hasExactPeriod hr hm hF]
  have hbal : ∀ s ∈ matchSet F (id : β → β),
      ((Real.sqrt ((r * m : ℕ) : ℝ))⁻¹) ^ 2 *
        ((fibreCard F s : ℝ) * (fibreCard (id : β → β) s : ℝ))
      = (((matchSet F (id : β → β)).card : ℝ))⁻¹ := by
    intro s hs
    rw [matchSet_id] at hs
    rw [fibreCard_of_hasExactPeriod hr hF hs, fibreCard_id, hcard]
    have hQ : (0 : ℝ) < ((r * m : ℕ) : ℝ) := by
      have : 0 < r * m := Nat.mul_pos hr hm
      exact_mod_cast this
    rw [inv_pow, Real.sq_sqrt hQ.le]
    push_cast
    field_simp
  have hne : (matchSet F (id : β → β)).Nonempty := by
    rw [← Finset.card_pos, hcard]; exact hr
  rw [shorState, entanglementEntropy_matchMatrix_of_balanced hbal hne, hcard]

/-- The Schmidt spectrum of the full Shor state is flat: all `r` Schmidt
coefficients are equal to `r^{-1/2}`. -/
theorem flatSchmidtSpectrum_shorState (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F) :
    FlatSchmidtSpectrum (shorState (r * m) F) := by
  refine (entanglementEntropy_eq_log_schmidtRank_iff (normalized_shorState hr hm hF)).mp ?_
  rw [schmidtRank_shorState hr hm hF, entanglementEntropy_shorState hr hm hF]

/-- **The mutual information across the register cut is `2 log r`**, saturating
the Schmidt-rank bound. -/
theorem mutualInformation_shorState (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F) :
    mutualInformation (shorState (r * m) F) = 2 * Real.log r := by
  rw [mutualInformation_eq_two_mul_entanglementEntropy_general,
    entanglementEntropy_shorState hr hm hF]

/-- **The tensor-network obstruction for the full Shor state.**  Any matrix
product / tensor-train representation across the register cut has bond
dimension at least `r`. -/
theorem bondDim_shorState_ge (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F) {χ : ℕ}
    (h : HasBondDim (shorState (r * m) F) χ) : r ≤ χ := by
  have := schmidtRank_le_of_hasBondDim h
  rwa [schmidtRank_shorState hr hm hF] at this

/-- Below bond dimension `r` there is no MPS representation of the Shor state at
all: the low-rank precondition of tensor-train emulation fails. -/
theorem not_hasBondDim_shorState (hr : 0 < r) (hm : 0 < m) (hF : HasExactPeriod r F)
    {χ : ℕ} (hχ : χ < r) : ¬ HasBondDim (shorState (r * m) F) χ :=
  fun h => absurd (bondDim_shorState_ge hr hm hF h) (not_le.mpr hχ)

end ShorState

/-! ## The concrete modular-exponentiation state -/

section ModularExponentiation

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The modular exponential `x ↦ a ^ x` on a register of size `Q`. -/
def powFun (a : G) (Q : ℕ) : Fin Q → G := fun x => a ^ (x : ℕ)

omit [Fintype G] [DecidableEq G] in
/-- **The modular exponential has exact period `orderOf a`.**  This is the only
input the entanglement analysis needs. -/
theorem hasExactPeriod_powFun (a : G) (Q : ℕ) :
    HasExactPeriod (orderOf a) (powFun a Q) := by
  intro i j
  simpa [powFun, Nat.ModEq] using
    (pow_eq_pow_iff_modEq (x := a) (n := (i : ℕ)) (m := (j : ℕ)))

/-- **The Shor state of a group element of order `r` has Schmidt rank exactly
`r`.**  For `G = (ZMod N)ˣ` and `a` the base of the modular exponentiation this
is the state of Shor's algorithm just before the QFT. -/
theorem schmidtRank_shorState_pow {a : G} {r m : ℕ} (hr : orderOf a = r) (hrpos : 0 < r)
    (hm : 0 < m) :
    schmidtRank (shorState (r * m) (powFun a (r * m))) = r :=
  schmidtRank_shorState hrpos hm (hr ▸ hasExactPeriod_powFun a (r * m))

/-- **The entanglement entropy of the modular-exponentiation state is `log r`.** -/
theorem entanglementEntropy_shorState_pow {a : G} {r m : ℕ} (hr : orderOf a = r)
    (hrpos : 0 < r) (hm : 0 < m) :
    entanglementEntropy (shorState (r * m) (powFun a (r * m))) = Real.log r :=
  entanglementEntropy_shorState hrpos hm (hr ▸ hasExactPeriod_powFun a (r * m))

/-- **No sub-`r` bond dimension for the modular-exponentiation state.** -/
theorem not_hasBondDim_shorState_pow {a : G} {r m : ℕ} (hr : orderOf a = r) (hrpos : 0 < r)
    (hm : 0 < m) {χ : ℕ} (hχ : χ < r) :
    ¬ HasBondDim (shorState (r * m) (powFun a (r * m))) χ :=
  not_hasBondDim_shorState hrpos hm (hr ▸ hasExactPeriod_powFun a (r * m)) hχ

end ModularExponentiation

end ShorIrreducible