import Pythagorean.AggregateDichotomy

/-!
# Fibre structure of the unlabeled Pythagorean product

`Pythagorean.AggregateDichotomy` shows that the unlabeled product `uprod` is not injective.
Here we measure *how badly* it fails, and we see that the failure is uniform: `uprod` is
nowhere injective, its generic fibres contain a free orbit of the Gaussian rotation group
`{±1, ±i}`, and its fibre over the absorbing triple `(0,0,0)` is infinite.

## Main results

* `Pythagorean.instInfinitePTriple` : there are infinitely many Pythagorean triples.
* `Pythagorean.uprod_fiber_zeroT_infinite` : the fibre of the length-two product over the
  degenerate triple `(0,0,0)` is infinite — the absorbing element destroys all information.
* `Pythagorean.uprod_four_to_one` : for any family whose first member is nonzero there are
  four pairwise distinct families with the same product, obtained by twisting by the four
  rotations `±1, ±i`.  Together with `uprod_fiber_one_ncard` (which shows the count `4` is
  attained exactly) this pins down the generic redundancy of the product.
* `Pythagorean.uprod_two_nowhere_injective` : `uprod` is injective at *no* point.
-/

namespace Pythagorean

open PTriple

/-! ## Infinitude of triples -/

/-- The degenerate triple `(0, k, k)`. -/
def degenerate (k : ℕ) : PTriple :=
  ofLegs 0 (k : ℤ) (k : ℤ) (by ring) (by positivity)

lemma degenerate_injective : Function.Injective degenerate := by
  intro k l h
  have : (k : ℤ) = (l : ℤ) := by simpa [degenerate] using congrArg PTriple.b h
  exact_mod_cast this

instance instInfinitePTriple : Infinite PTriple :=
  Infinite.of_injective degenerate degenerate_injective

/-! ## The fibre over the absorbing triple -/

/-- **Total collapse at the absorbing element**: infinitely many length-two families have the
degenerate triple `(0,0,0)` as their product. -/
theorem uprod_fiber_zeroT_infinite :
    {f : Fin 2 → PTriple | uprod f = zeroT}.Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun t : PTriple => (![zeroT, t] : Fin 2 → PTriple)) ?_ ?_
  · intro t s h
    simpa using congrFun h 1
  · intro t
    simp [uprod_two]

/-! ## The rotation orbit inside a generic fibre -/

/-- The four Gaussian rotations `1, -1, i, -i` as Pythagorean triples. -/
def rotVec : Fin 4 → PTriple := ![1, rotNegOne, rotI, rotNegI]

/-- The inverses of the four rotations, in the same order. -/
def rotInvVec : Fin 4 → PTriple := ![1, rotNegOne, rotNegI, rotI]

lemma rot_mul_inv (k : Fin 4) : rotVec k * rotInvVec k = 1 := by
  fin_cases k <;> ext <;> simp [rotVec, rotInvVec, rotI, rotNegI, rotNegOne]

lemma rotVec_injective : Function.Injective rotVec := by
  intro k l h
  have ha : (rotVec k).a = (rotVec l).a := congrArg PTriple.a h
  have hb : (rotVec k).b = (rotVec l).b := congrArg PTriple.b h
  clear h
  fin_cases k <;> fin_cases l <;>
    first
      | rfl
      | (exfalso; revert ha hb; simp [rotVec, rotI, rotNegI, rotNegOne])

/-- **Generic four-fold redundancy.**  If the first member of a length-two family is not the
absorbing triple, then twisting the family by the four Gaussian rotations produces four
pairwise distinct families with the same unlabeled product. -/
theorem uprod_four_to_one (f : Fin 2 → PTriple) (h0 : f 0 ≠ zeroT) :
    ∃ F : Fin 4 → (Fin 2 → PTriple),
      Function.Injective F ∧ (∀ k, uprod (F k) = uprod f) ∧ F 0 = f := by
  refine ⟨fun k => ![rotVec k * f 0, rotInvVec k * f 1], ?_, ?_, ?_⟩
  · intro k l h
    have h0' : rotVec k * f 0 = rotVec l * f 0 := by simpa using congrFun h 0
    exact rotVec_injective (mul_right_cancel_of_ne_zeroT h0 h0')
  · intro k
    have : (rotVec k * f 0) * (rotInvVec k * f 1) = (rotVec k * rotInvVec k) * (f 0 * f 1) :=
      mul_mul_mul_comm _ _ _ _
    rw [uprod_two, uprod_two]
    simpa [rot_mul_inv k] using this
  · funext i
    fin_cases i <;> simp [rotVec, rotInvVec]

/-! ## Nowhere injectivity -/

lemma rotNegOne_ne_one : rotNegOne ≠ 1 := by
  intro h
  have : (-1 : ℤ) = 1 := by simpa [rotNegOne] using congrArg PTriple.a h
  norm_num at this

lemma t345_ne_zeroT : t345 ≠ zeroT := by
  intro h
  have : (3 : ℤ) = 0 := by simpa [t345] using congrArg PTriple.a h
  norm_num at this

/-- **The unlabeled product is injective at no point whatsoever**: every length-two family
shares its product with a different family.  (Compare `uprod_not_injective`, which only
asserts the existence of one collision.) -/
theorem uprod_two_nowhere_injective (f : Fin 2 → PTriple) :
    ∃ g : Fin 2 → PTriple, g ≠ f ∧ uprod g = uprod f := by
  by_cases h0 : f 0 = zeroT
  · -- the product is degenerate; perturb the second slot
    have hzero : uprod f = zeroT := by rw [uprod_two, h0, zeroT_mul]
    by_cases h1 : f 1 = zeroT
    · refine ⟨![zeroT, t345], ?_, ?_⟩
      · intro h
        exact t345_ne_zeroT (by simpa [h1] using congrFun h 1)
      · rw [hzero, uprod_two]
        simp
    · refine ⟨![zeroT, zeroT], ?_, ?_⟩
      · intro h
        exact h1 (by simpa using (congrFun h 1).symm)
      · rw [hzero, uprod_two]
        simp
  · -- generic case: twist by `-1`
    refine ⟨![rotNegOne * f 0, rotNegOne * f 1], ?_, ?_⟩
    · intro h
      have : rotNegOne * f 0 = 1 * f 0 := by simpa using congrFun h 0
      exact rotNegOne_ne_one (mul_right_cancel_of_ne_zeroT h0 this)
    · have hmm : (rotNegOne * f 0) * (rotNegOne * f 1)
          = (rotNegOne * rotNegOne) * (f 0 * f 1) := mul_mul_mul_comm _ _ _ _
      have hone : rotNegOne * rotNegOne = 1 := by
        ext <;> simp [rotNegOne]
      rw [uprod_two, uprod_two]
      simpa [hone] using hmm

/-! ## The unit group is the cyclic rotation group of order four -/

lemma rotI_sq : rotI ^ 2 = rotNegOne := by
  rw [pow_two]; ext <;> simp [rotI, rotNegOne]

lemma rotI_cube : rotI ^ 3 = rotNegI := by
  rw [pow_succ, rotI_sq]; ext <;> simp [rotI, rotNegOne, rotNegI]

lemma rotI_pow_four : rotI ^ 4 = 1 := by
  rw [show (4 : ℕ) = 3 + 1 by rfl, pow_succ, rotI_cube]
  ext <;> simp [rotI, rotNegI]

lemma rotI_sq_ne_one : rotI ^ 2 ≠ 1 := by
  rw [rotI_sq]
  exact rotNegOne_ne_one

lemma isUnit_rotI : IsUnit rotI :=
  (isUnit_iff_c_eq_one rotI).mpr (by simp [rotI])

/-- **The units of the Pythagorean monoid form the cyclic group of order four** generated by
the quarter turn `i = (0,1,1)`: a triple is invertible iff it is a power of `rotI`. -/
theorem isUnit_iff_pow_rotI (t : PTriple) : IsUnit t ↔ ∃ k : ℕ, t = rotI ^ k := by
  constructor
  · intro h
    have hc := (isUnit_iff_c_eq_one t).mp h
    rcases eq_of_c_eq_one t hc with ⟨p, q⟩ | ⟨p, q⟩ | ⟨p, q⟩ | ⟨p, q⟩
    · exact ⟨0, by ext <;> simp [p, q, hc]⟩
    · exact ⟨2, by rw [rotI_sq]; ext <;> simp [p, q, hc, rotNegOne]⟩
    · exact ⟨1, by rw [pow_one]; ext <;> simp [p, q, hc, rotI]⟩
    · exact ⟨3, by rw [rotI_cube]; ext <;> simp [p, q, hc, rotNegI]⟩
  · rintro ⟨k, rfl⟩
    exact isUnit_rotI.pow k

/-- The quarter turn has order exactly four. -/
theorem orderOf_rotI : orderOf rotI = 4 := by
  have h := orderOf_eq_prime_pow (x := rotI) (p := 2) (n := 1)
    (by simpa using rotI_sq_ne_one) (by simpa using rotI_pow_four)
  simpa using h

/-! ## The fibre over the identity in arbitrary length -/

/-- **Every member of a family whose product is the identity is a rotation.**  This is the
general-`n` skeleton behind the exact count `uprod_fiber_one_ncard` for `n = 2`: the fibre of
`uprod` over `1` is contained in the `n`-fold power of the cyclic rotation group. -/
theorem mem_fiber_one_pow_rotI {n : ℕ} (f : Fin n → PTriple) (h : uprod f = 1) (i : Fin n) :
    ∃ k : ℕ, f i = rotI ^ k := by
  have hc : ∏ j, (f j).c = 1 := by rw [← uprod_c, h, one_c]
  have hdvd : (f i).c ∣ 1 := hc ▸ Finset.dvd_prod_of_mem (fun j => (f j).c) (Finset.mem_univ i)
  have hu := Int.isUnit_iff.mp (isUnit_of_dvd_one hdvd)
  have hpos := (f i).hc
  have hci : (f i).c = 1 := by omega
  exact (isUnit_iff_pow_rotI (f i)).mp ((isUnit_iff_c_eq_one (f i)).mpr hci)

/-! ## Four-fold redundancy in arbitrary length -/

/-- The twist family supported on two indices: `rotVec k` at `i`, its inverse at `j`. -/
def twist {n : ℕ} (i j : Fin n) (k : Fin 4) : Fin n → PTriple :=
  fun m => if m = i then rotVec k else if m = j then rotInvVec k else 1

lemma prod_twist {n : ℕ} {i j : Fin n} (hij : i ≠ j) (k : Fin 4) :
    ∏ m, twist i j k m = 1 := by
  rw [Finset.prod_eq_mul_of_mem i j (Finset.mem_univ i) (Finset.mem_univ j) hij ?_]
  · simp [twist, if_neg hij.symm, rot_mul_inv k]
  · intro c _ hc
    simp [twist, if_neg hc.1, if_neg hc.2]

/-- **Generic four-fold redundancy in every length.**  For a family of any length `n ≥ 2`
whose member at some index `i` is not the absorbing triple, twisting by the four Gaussian
rotations at `i` and by their inverses at another index `j` yields four pairwise distinct
families with the same unlabeled product.  The `n = 2` instance is `uprod_four_to_one`. -/
theorem uprod_four_to_one_general {n : ℕ} (i j : Fin n) (hij : i ≠ j) (f : Fin n → PTriple)
    (hf : f i ≠ zeroT) :
    ∃ F : Fin 4 → (Fin n → PTriple),
      Function.Injective F ∧ (∀ k, uprod (F k) = uprod f) ∧ F 0 = f := by
  refine ⟨fun k m => twist i j k m * f m, ?_, ?_, ?_⟩
  · intro k l h
    have hi : rotVec k * f i = rotVec l * f i := by
      have := congrFun h i
      simpa [twist] using this
    exact rotVec_injective (mul_right_cancel_of_ne_zeroT hf hi)
  · intro k
    unfold uprod
    rw [Finset.prod_mul_distrib, prod_twist hij k, one_mul]
  · funext m
    by_cases hm : m = i
    · subst hm; simp [twist, rotVec]
    · by_cases hm' : m = j
      · subst hm'; simp [twist, hm, rotInvVec]
      · simp [twist, hm, hm']

end Pythagorean