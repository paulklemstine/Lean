/-
# The order-3 channel on a non-abelian field: semiprime level

`N = p·q` with `p, q` unramified.  The dial is again the residue `N mod 9`; since
the cubic character is multiplicative (`chi9_mul`), the dial sees only the *sum*
`s = chi9(p) + chi9(q) ∈ ℤ/3` of the two cube classes, which are independent and
uniform (Chebotarev for the `A₄`-field, Dirichlet for the classes).

All the observables of the experiment are computed here **exactly**:

* `A4ForkPinning.info_semiprime_and` — `I(N mod 9 ; both split) = H(1/9) - (1/3)H(1/3)`
  (`= 0.1972…`, measured `0.1997`) — again an instance of the leakage law;
* `A4ForkPinning.info_semiprime_or`  — `I(N mod 9 ; some split) = H(5/9) - H(1/3)`
  (`= 0.0728…`, measured `0.0688`);
* `A4ForkPinning.info_semiprime_xor` — `I(N mod 9 ; exactly one) = H(4/9) - (2/3)H(1/3)`
  (`= 0.3789…`, measured `0.3736`);
* `A4ForkPinning.info_semiprime_split_count` — `I(N mod 9 ; #split) = H(4/9,4/9,1/9) - H(1/3)`
  (`= 0.4739…`, measured `0.4710`), the paper-74 order-3 split-count law, here on a
  **non-abelian** field;
* `A4ForkPinning.info_semiprime_which_factor` — **the which-factor wall**: the dial
  carries *exactly zero* bits about which of the two factors split.

Every conditional rate used below is justified by an exact count of pairs
(`and_rate_eq_count` etc.), not postulated.
-/
import Algebra.A4ForkPinning.Information
import Algebra.A4ForkPinning.Resolvent

namespace A4ForkPinning

open Finset

/-! ## The dial of a semiprime -/

/-- The class of `N = p·q` is the **sum** of the classes of its factors: this is why
the semiprime dial is the additive group `ℤ/3` and why the "which factor" question
is invisible to it. -/
theorem dial_of_semiprime (x y : ZMod 9) (hx : IsUnit x) (hy : IsUnit y) :
    chi9 (x * y) = chi9 x + chi9 y := chi9_mul x y hx hy

/-! ## Counting pairs of cube classes -/

/-- The three possible classes of `N = pq`. -/
def cls : Fin 3 → ZMod 3 := ![0, 1, 2]

/-- Pairs of classes with prescribed sum, and both factors split. -/
def countAnd (t : ZMod 3) : ℕ :=
  (univ.filter (fun ab : ZMod 3 × ZMod 3 => ab.1 + ab.2 = t ∧ ab.1 = 0 ∧ ab.2 = 0)).card

/-- Pairs of classes with prescribed sum, and at least one factor split. -/
def countOr (t : ZMod 3) : ℕ :=
  (univ.filter (fun ab : ZMod 3 × ZMod 3 => ab.1 + ab.2 = t ∧ (ab.1 = 0 ∨ ab.2 = 0))).card

/-- Pairs of classes with prescribed sum, and exactly one factor split. -/
def countXor (t : ZMod 3) : ℕ :=
  (univ.filter (fun ab : ZMod 3 × ZMod 3 =>
    ab.1 + ab.2 = t ∧ ((ab.1 = 0 ∧ ab.2 ≠ 0) ∨ (ab.1 ≠ 0 ∧ ab.2 = 0)))).card

/-- Pairs of classes with prescribed sum, and the *first* factor split. -/
def countFirst (t : ZMod 3) : ℕ :=
  (univ.filter (fun ab : ZMod 3 × ZMod 3 => ab.1 + ab.2 = t ∧ ab.1 = 0)).card

/-- Pairs of classes with prescribed sum. -/
def countAll (t : ZMod 3) : ℕ :=
  (univ.filter (fun ab : ZMod 3 × ZMod 3 => ab.1 + ab.2 = t)).card

/-- Pairs with prescribed sum and prescribed number of split factors. -/
def countSplit (t : ZMod 3) (k : ℕ) : ℕ :=
  (univ.filter (fun ab : ZMod 3 × ZMod 3 => ab.1 + ab.2 = t ∧
    ((if ab.1 = 0 then 1 else 0) + (if ab.2 = 0 then 1 else 0) : ℕ) = k)).card

theorem countAll_eq : ∀ t : ZMod 3, countAll t = 3 := by decide

theorem countAnd_eq : ∀ t : ZMod 3, countAnd t = if t = 0 then 1 else 0 := by decide

theorem countOr_eq : ∀ t : ZMod 3, countOr t = if t = 0 then 1 else 2 := by decide

theorem countXor_eq : ∀ t : ZMod 3, countXor t = if t = 0 then 0 else 2 := by decide

/-- **The which-factor wall, combinatorially**: whatever the class of `N`, exactly one
of the three admissible pairs has its first factor split. -/
theorem countFirst_eq : ∀ t : ZMod 3, countFirst t = 1 := by decide

theorem countSplit_eq : ∀ t : ZMod 3, ∀ k : ℕ, k ≤ 2 → countSplit t k =
    if t = 0 then (if k = 0 then 2 else if k = 1 then 0 else 1)
    else (if k = 0 then 1 else if k = 1 then 2 else 0) := by decide

/-! ## Conditional rates -/

/-- Uniform distribution of the class of `N`. -/
noncomputable def w3 : Fin 3 → ℝ := fun _ => 1 / 3

theorem w3_sum : ∑ i, w3 i = 1 := by simp [w3]

theorem w3_pos (i : Fin 3) : 0 < w3 i := by norm_num [w3]

/-- `P(both factors split | class of N)`. -/
noncomputable def andRate : Fin 3 → ℝ := ![1 / 3, 0, 0]

/-- `P(at least one factor splits | class of N)`. -/
noncomputable def orRate : Fin 3 → ℝ := ![1 / 3, 2 / 3, 2 / 3]

/-- `P(exactly one factor splits | class of N)`. -/
noncomputable def xorRate : Fin 3 → ℝ := ![0, 2 / 3, 2 / 3]

/-- `P(the first factor splits | class of N)`. -/
noncomputable def firstRate : Fin 3 → ℝ := fun _ => 1 / 3

theorem and_rate_eq_count (i : Fin 3) : andRate i = (countAnd (cls i) : ℝ) / 3 := by
  fin_cases i <;> simp [andRate, cls, countAnd_eq]

theorem or_rate_eq_count (i : Fin 3) : orRate i = (countOr (cls i) : ℝ) / 3 := by
  fin_cases i <;> simp +decide [orRate, cls, countOr_eq]

theorem xor_rate_eq_count (i : Fin 3) : xorRate i = (countXor (cls i) : ℝ) / 3 := by
  fin_cases i <;> simp +decide [xorRate, cls, countXor_eq]

theorem first_rate_eq_count (i : Fin 3) : firstRate i = (countFirst (cls i) : ℝ) / 3 := by
  fin_cases i <;> simp [firstRate, cls, countFirst_eq]

/-! ## Exact information laws -/

/-- The `AND` fork is the `1/3`-thinning of the pinned fork `[class N = 0]`. -/
theorem andRate_thinning : ∀ i, andRate i = (1 / 3) * (![1, 0, 0] : Fin 3 → ℝ) i := by
  intro i; fin_cases i <;> norm_num [andRate]

/-- **AND law.**  `I(N mod 9 ; both factors split) = H(1/9) - (1/3)·H(1/3)`. -/
theorem info_semiprime_and : info w3 andRate = hb (1 / 9) - (1 / 3) * hb (1 / 3) := by
  have hg : ∀ i : Fin 3, (![1, 0, 0] : Fin 3 → ℝ) i = 0 ∨ (![1, 0, 0] : Fin 3 → ℝ) i = 1 := by
    intro i; fin_cases i <;> norm_num
  have havg : avg w3 (![1, 0, 0] : Fin 3 → ℝ) = 1 / 3 := by
    simp [avg, w3, Fin.sum_univ_three]
  have h := info_leak w3 (![1, 0, 0] : Fin 3 → ℝ) (1 / 3) hg
  rw [havg, show (1 : ℝ) / 3 * (1 / 3) = 1 / 9 by norm_num] at h
  rw [show andRate = fun i => (1 / 3) * (![1, 0, 0] : Fin 3 → ℝ) i from funext andRate_thinning]
  exact h

/-- **OR law.**  `I(N mod 9 ; at least one factor splits) = H(5/9) - H(1/3)`. -/
theorem info_semiprime_or : info w3 orRate = hb (5 / 9) - hb (1 / 3) := by
  have havg : avg w3 orRate = 5 / 9 := by
    simp [avg, w3, orRate, Fin.sum_univ_three]; norm_num
  have hsymm : hb (2 / 3) = hb (1 / 3) := by
    have := hb_symm (1 / 3 : ℝ)
    rwa [show (1 : ℝ) - 1 / 3 = 2 / 3 by norm_num] at this
  have hcond : condEntropy w3 orRate = hb (1 / 3) := by
    simp only [condEntropy, w3, orRate, Fin.sum_univ_three, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hsymm]
    ring
  rw [info, havg, hcond]

/-- **XOR law.**  `I(N mod 9 ; exactly one factor splits) = H(4/9) - (2/3)·H(1/3)`. -/
theorem info_semiprime_xor : info w3 xorRate = hb (4 / 9) - (2 / 3) * hb (1 / 3) := by
  have havg : avg w3 xorRate = 4 / 9 := by
    simp [avg, w3, xorRate, Fin.sum_univ_three]; norm_num
  have hsymm : hb (2 / 3) = hb (1 / 3) := by
    have := hb_symm (1 / 3 : ℝ)
    rwa [show (1 : ℝ) - 1 / 3 = 2 / 3 by norm_num] at this
  have hcond : condEntropy w3 xorRate = (2 / 3) * hb (1 / 3) := by
    simp only [condEntropy, w3, xorRate, Fin.sum_univ_three, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hsymm, hb_zero]
    ring
  rw [info, havg, hcond]

/-- **The which-factor wall.**  `I(N mod 9 ; the first factor splits) = 0`: the residue
of the product carries *no* information about which factor is the split one. -/
theorem info_semiprime_which_factor : info w3 firstRate = 0 :=
  info_of_flat w3 firstRate (1 / 3) w3_sum (fun _ => rfl)

/-! ## The split-count channel -/

/-- Conditional distribution of the number of split factors, given the class of `N`. -/
noncomputable def splitDist : Fin 3 → Fin 3 → ℝ :=
  ![![2 / 3, 0, 1 / 3], ![1 / 3, 2 / 3, 0], ![1 / 3, 2 / 3, 0]]

theorem splitDist_eq_count (i : Fin 3) (k : Fin 3) :
    splitDist i k = (countSplit (cls i) k.val : ℝ) / 3 := by
  fin_cases i <;> fin_cases k <;> simp +decide [splitDist, cls, countSplit_eq]

/-- The marginal law of the split count is `Bin(2, 1/3) = (4/9, 4/9, 1/9)`. -/
theorem splitDist_marginal :
    (fun k => ∑ i, w3 i * splitDist i k) = ![4 / 9, 4 / 9, 1 / 9] := by
  funext k
  fin_cases k <;>
    simp [w3, splitDist, Fin.sum_univ_three] <;> norm_num

/-- **Split-count law.**  `I(N mod 9 ; #split factors) = H(4/9, 4/9, 1/9) - H(1/3)`:
the order-`3` split-count law of the abelian theory holds verbatim on the
non-abelian `A₄`-field — only the character matters. -/
theorem info_semiprime_split_count :
    infoGen w3 splitDist = entropy (![4 / 9, 4 / 9, 1 / 9] : Fin 3 → ℝ) - hb (1 / 3) := by
  have hsymm : hb (2 / 3) = hb (1 / 3) := by
    have := hb_symm (1 / 3 : ℝ)
    rwa [show (1 : ℝ) - 1 / 3 = 2 / 3 by norm_num] at this
  have hb13 : hb (1 / 3) = nml (1 / 3) + nml (2 / 3) := by
    rw [hb, show (1 : ℝ) - 1 / 3 = 2 / 3 by norm_num]
  have hrow0 : entropy (splitDist 0) = hb (1 / 3) := by
    simp only [splitDist, entropy, Fin.sum_univ_three, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hb13, nml_zero]
    ring
  have hrow1 : entropy (splitDist 1) = hb (1 / 3) := by
    simp only [splitDist, entropy, Fin.sum_univ_three, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hb13, nml_zero]
    ring
  have hrow2 : entropy (splitDist 2) = hb (1 / 3) := by
    simp only [splitDist, entropy, Fin.sum_univ_three, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hb13, nml_zero]
    ring
  rw [infoGen, splitDist_marginal]
  simp only [w3, Fin.sum_univ_three, hrow0, hrow1, hrow2]
  ring

end A4ForkPinning