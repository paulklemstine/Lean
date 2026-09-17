/-
# The residue dial: why `I(p mod m*; T) = I(T; coset)` exactly

Class field theory says the abelianization coset of `Frob_p` is a function of the residue
`p mod m*`, and that the Artin map from `(ℤ/m*)ˣ` onto the abelian quotient `A` is a
surjective homomorphism — so all its fibres have the same size `m`.  Given only that
structure, the residue is a *strictly finer* observable than the coset, but conditionally
on the coset it is independent of the Frobenius type.

This file formalizes the resulting sufficiency statement.  Starting from a type/coset
table `J`, the **refinement** `J.refineBy proj m` replaces the coset alphabet by a finer one
`ρ` mapping `m`-to-one onto it, spreading each coset's mass uniformly over its residues.
Then:

* `refineBy_Htype`  : the type marginal is unchanged;
* `refineBy_Hcoset` : `H(residue) = H(coset) + log₂ m`;
* `refineBy_Hjoint` : `H(T, residue) = H(T, coset) + log₂ m`;
* `refineBy_mutualInfo` : **`I(T; residue) = I(T; coset)` — the residue dial adds entropy
  but not information.**

Applied to `D₅` at conductor `m* = 20`, where the quadratic character of `ℚ(√−5)` maps
the eight units mod 20 four-to-one onto `C₂`, this gives `I(p mod 20; T) = 1` exactly:
the measured `1.0000` is not an approximation.
-/
import MachineLearning.QuinticTypeChannel.GroupTable
import MachineLearning.QuinticTypeChannel.DihedralD5

open Finset Real

namespace TypeChannel

namespace Joint

variable {ι κ ρ : Type} [Fintype ι] [Fintype κ] [Fintype ρ] [DecidableEq κ]

/-- Summing a function pulled back along an `m`-to-one map multiplies the sum by `m`. -/
lemma sum_over_fibers (proj : ρ → κ) (m : ℕ)
    (hfib : ∀ c, (univ.filter (fun r : ρ => proj r = c)).card = m) (f : κ → ℝ) :
    ∑ r : ρ, f (proj r) = m * ∑ c : κ, f c := by
  rw [← Finset.sum_fiberwise (s := (univ : Finset ρ)) (g := proj) (f := fun r => f (proj r))]
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun c _ => ?_
  have : ∀ r ∈ univ.filter (fun r : ρ => proj r = c), f (proj r) = f c := by
    intro r hr
    rw [(mem_filter.mp hr).2]
  rw [Finset.sum_congr rfl this, Finset.sum_const, hfib c, nsmul_eq_mul]

/-- `negMulLog` under division by a positive integer. -/
lemma negMulLog_div {x : ℝ} (hx : 0 ≤ x) {m : ℝ} (hm : 0 < m) :
    negMulLog (x / m) = negMulLog x / m + (x / m) * Real.log m := by
  rcases eq_or_lt_of_le hx with hx0 | hx0
  · simp [negMulLog, ← hx0]
  · rw [negMulLog, negMulLog, Real.log_div (ne_of_gt hx0) (ne_of_gt hm)]
    field_simp
    ring

/-- The refinement of a type/coset table along an `m`-to-one "residue" map: each coset's
mass is spread uniformly over the residues lying above it. -/
noncomputable def refineBy (J : Joint ι κ) (proj : ρ → κ) (m : ℕ) (hm : 0 < m)
    (hfib : ∀ c, (univ.filter (fun r : ρ => proj r = c)).card = m) : Joint ι ρ where
  p t r := J.p t (proj r) / m
  nonneg t r := by
    have hmR : (0:ℝ) < m := by exact_mod_cast hm
    exact div_nonneg (J.nonneg t (proj r)) (le_of_lt hmR)
  total := by
    have hmR : (0:ℝ) < m := by exact_mod_cast hm
    have : ∀ t : ι, ∑ r : ρ, J.p t (proj r) / m = ∑ c : κ, J.p t c := by
      intro t
      rw [sum_over_fibers proj m hfib (fun c => J.p t c / m), ← Finset.sum_div]
      field_simp
    rw [Finset.sum_congr rfl fun t _ => this t]
    exact J.total

variable (J : Joint ι κ) (proj : ρ → κ) (m : ℕ) (hm : 0 < m)
  (hfib : ∀ c, (univ.filter (fun r : ρ => proj r = c)).card = m)

@[simp] lemma refineBy_p (t : ι) (r : ρ) :
    (J.refineBy proj m hm hfib).p t r = J.p t (proj r) / m := rfl

/-- Refining the coset alphabet does not change the type marginal. -/
lemma refineBy_typeMarg (t : ι) : (J.refineBy proj m hm hfib).typeMarg t = J.typeMarg t := by
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  simp only [typeMarg, refineBy_p]
  rw [sum_over_fibers proj m hfib (fun c => J.p t c / m), ← Finset.sum_div]
  field_simp

lemma refineBy_cosetMarg (r : ρ) :
    (J.refineBy proj m hm hfib).cosetMarg r = J.cosetMarg (proj r) / m := by
  simp only [cosetMarg, refineBy_p]
  rw [← Finset.sum_div]

/-- The type entropy is unchanged by refining the coset alphabet. -/
theorem refineBy_Htype : (J.refineBy proj m hm hfib).Htype = J.Htype := by
  unfold Htype
  congr 1
  exact Finset.sum_congr rfl fun t _ => by rw [refineBy_typeMarg]

/-- Refining multiplies the coset alphabet by `m`, adding exactly `log₂ m` bits of
entropy. -/
theorem refineBy_Hcoset :
    (J.refineBy proj m hm hfib).Hcoset = J.Hcoset + Real.logb 2 m := by
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hterms : ∑ r : ρ, negMulLog ((J.refineBy proj m hm hfib).cosetMarg r)
      = (∑ c : κ, negMulLog (J.cosetMarg c)) + Real.log m := by
    have hstep : ∀ r : ρ, negMulLog ((J.refineBy proj m hm hfib).cosetMarg r)
        = (fun c => negMulLog (J.cosetMarg c) / m + (J.cosetMarg c / m) * Real.log m) (proj r) := by
      intro r
      rw [refineBy_cosetMarg, negMulLog_div (J.cosetMarg_nonneg (proj r)) hmR]
    rw [Finset.sum_congr rfl fun r _ => hstep r,
      sum_over_fibers proj m hfib
        (fun c => negMulLog (J.cosetMarg c) / m + (J.cosetMarg c / m) * Real.log m),
      Finset.sum_add_distrib]
    simp only [← Finset.sum_div, ← Finset.sum_mul, J.sum_cosetMarg]
    field_simp
  unfold Hcoset
  rw [hterms, Real.logb]
  field_simp

/-- The joint entropy also gains exactly `log₂ m`. -/
theorem refineBy_Hjoint :
    (J.refineBy proj m hm hfib).Hjoint = J.Hjoint + Real.logb 2 m := by
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hrow : ∀ t : ι, ∑ r : ρ, negMulLog ((J.refineBy proj m hm hfib).p t r)
      = (∑ c : κ, negMulLog (J.p t c)) + J.typeMarg t * Real.log m := by
    intro t
    have hstep : ∀ r : ρ, negMulLog ((J.refineBy proj m hm hfib).p t r)
        = (fun c => negMulLog (J.p t c) / m + (J.p t c / m) * Real.log m) (proj r) := by
      intro r
      rw [refineBy_p, negMulLog_div (J.nonneg t (proj r)) hmR]
    rw [Finset.sum_congr rfl fun r _ => hstep r,
      sum_over_fibers proj m hfib (fun c => negMulLog (J.p t c) / m + (J.p t c / m) * Real.log m),
      Finset.sum_add_distrib]
    simp only [← Finset.sum_div, ← Finset.sum_mul, show ∑ c : κ, J.p t c = J.typeMarg t from rfl]
    field_simp
  unfold Hjoint
  rw [Finset.sum_congr rfl fun t _ => hrow t, Finset.sum_add_distrib, ← Finset.sum_mul,
    J.sum_typeMarg, one_mul, Real.logb]
  field_simp

/-- **The residue dial carries exactly the coset information.**  Refining the coset
observable into residue classes — which is what the Artin map does in reverse — adds
`log₂ m` bits of entropy to both the coset and the joint distribution, so the mutual
information with the type is unchanged: `I(T; residue) = I(T; coset)`. -/
theorem refineBy_mutualInfo :
    (J.refineBy proj m hm hfib).mutualInfo = J.mutualInfo := by
  unfold mutualInfo
  rw [refineBy_Htype, refineBy_Hcoset, refineBy_Hjoint]
  ring

end Joint

/-! ## The `D₅` residue dial at `m* = 20` -/

namespace DihedralD5

open Joint

/-- The quadratic character of `K = ℚ(√−5)` read on residues mod 20: a prime splits in
`K` (coset `0`) exactly when `p ≡ 1, 3, 7, 9 (mod 20)`, and is inert (coset `1`) when
`p ≡ 11, 13, 17, 19 (mod 20)`.  `−20` is the fundamental discriminant of `K`, so this is
the Kronecker symbol `(−20 | p)`. -/
def residueChar (u : (ZMod 20)ˣ) : Fin 2 :=
  if (u : ZMod 20) = 1 ∨ (u : ZMod 20) = 3 ∨ (u : ZMod 20) = 7 ∨ (u : ZMod 20) = 9
  then 0 else 1

/-- The character is exactly four-to-one: `(ℤ/20)ˣ` has eight elements and the split and
inert classes have four each. -/
theorem residueChar_fibers (c : Fin 2) :
    (univ.filter (fun u : (ZMod 20)ˣ => residueChar u = c)).card = 4 := by
  fin_cases c <;> decide

/-- The residue-dial table of a `D₅` quintic: factorization type against `p mod 20`. -/
noncomputable def residueTable : Joint (Fin 3) ((ZMod 20)ˣ) :=
  (QuinticRow.D5).refineBy residueChar 4 (by norm_num) residueChar_fibers

/-- **The cleanest cell of the program, exactly.**  For a `D₅` quintic with quadratic
resolvent `ℚ(√−5)`, the factorization type of `p` and the residue `p mod 20` share
exactly one bit: `I(p mod 20; T) = 1.0000…`, with no error term. -/
theorem residue_mutualInfo : residueTable.mutualInfo = 1 := by
  rw [residueTable, Joint.refineBy_mutualInfo, QuinticRow.D5_mutualInfo]

/-- The residue observable is strictly more entropic than the coset observable — it has
`log₂ 8 = 3` bits — yet only one of those bits is about the factorization type. -/
theorem residue_Hcoset : residueTable.Hcoset = 3 := by
  have hl : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  have h2 : Real.logb 2 ((4:ℕ) : ℝ) = 2 := by
    rw [show ((4:ℕ) : ℝ) = 2 ^ (2:ℕ) by norm_num, Real.logb, Real.log_pow]
    field_simp
    norm_num
  rw [residueTable, Joint.refineBy_Hcoset, QuinticRow.D5_Hcoset, h2]
  norm_num

/-- The type entropy is untouched by the dial. -/
theorem residue_Htype : residueTable.Htype = 1/5 + Real.logb 2 5 / 2 := by
  rw [residueTable, Joint.refineBy_Htype, QuinticRow.D5_Htype]

end DihedralD5

end TypeChannel