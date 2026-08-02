import Cryptography.LogisticMapChaos

/-!
# Exact cardinality of interior logistic-map fibers

For the full-strength logistic map `x ↦ 4x(1-x)`, every interior target has
exactly `2^n` interior preimages under the `n`-fold iterate.  The proof uses the
two explicit inverse branches and proves that they exhaust every preimage.
-/

namespace LogisticChaos

/-- The lower (`false`) and upper (`true`) inverse branches of the logistic map. -/
noncomputable def inverseBranch (upper : Bool) (y : ℝ) : ℝ :=
  if upper then (1 + Real.sqrt (1 - y)) / 2 else (1 - Real.sqrt (1 - y)) / 2

/-- Decode a string of `n` branch choices into an `n`-step preimage of `y`. -/
noncomputable def decodeSeed : {n : ℕ} → (Fin n → Bool) → ℝ → ℝ
  | 0, _, y => y
  | n + 1, bits, y =>
      inverseBranch (bits 0) (decodeSeed (fun i => bits i.succ) y)

lemma inverseBranch_logistic (upper : Bool) {y : ℝ} (hy0 : 0 ≤ y) (hy1 : y ≤ 1) :
    logistic (inverseBranch upper y) = y := by
  have hnonneg : 0 ≤ 1 - y := by linarith
  have hsqrt : (Real.sqrt (1 - y)) ^ 2 = 1 - y := Real.sq_sqrt hnonneg
  cases upper <;> simp [inverseBranch, logistic] <;> nlinarith [hy0]

lemma inverseBranch_mem_Ioo (upper : Bool) {y : ℝ} (hy0 : 0 < y) (hy1 : y < 1) :
    inverseBranch upper y ∈ Set.Ioo (0 : ℝ) 1 := by
  have hnonneg : 0 ≤ 1 - y := by linarith
  have hsqrt0 : 0 ≤ Real.sqrt (1 - y) := Real.sqrt_nonneg _
  have hsqrt_sq : (Real.sqrt (1 - y)) ^ 2 = 1 - y := Real.sq_sqrt hnonneg
  have hsqrt_lt : Real.sqrt (1 - y) < 1 := by nlinarith
  cases upper <;> simp [inverseBranch] <;> constructor <;> nlinarith

lemma inverseBranch_side (upper : Bool) {y : ℝ} (hy0 : 0 < y) (hy1 : y < 1) :
    if upper then 1 / 2 < inverseBranch upper y else inverseBranch upper y < 1 / 2 := by
  have hpos : 0 < 1 - y := by linarith
  have hsqrt_pos : 0 < Real.sqrt (1 - y) := Real.sqrt_pos.2 hpos
  cases upper <;> simp [inverseBranch] <;> linarith

lemma eq_inverseBranch_of_logistic_eq {x y : ℝ} (hx0 : 0 < x) (hx1 : x < 1)
    (hxy : logistic x = y) : ∃ upper : Bool, x = inverseBranch upper y := by
  have hform : 1 - y = (1 - 2 * x) ^ 2 := by
    rw [← hxy]
    simp [logistic]
    ring
  by_cases hx : x ≤ 1 / 2
  · refine ⟨false, ?_⟩
    simp [inverseBranch, hform, Real.sqrt_sq_eq_abs,
      abs_of_nonneg (by linarith : 0 ≤ 1 - 2 * x)]
  · refine ⟨true, ?_⟩
    simp [inverseBranch, hform, Real.sqrt_sq_eq_abs,
      abs_of_nonpos (by linarith : 1 - 2 * x ≤ 0)]

lemma interior_of_logistic_interior {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1)
    (hlog0 : 0 < logistic x) (hlog1 : logistic x < 1) : x ∈ Set.Ioo (0 : ℝ) 1 := by
  constructor <;> unfold logistic at hlog0 <;> nlinarith

lemma decodeSeed_mem_Ioo {n : ℕ} (bits : Fin n → Bool) {y : ℝ}
    (hy0 : 0 < y) (hy1 : y < 1) : decodeSeed bits y ∈ Set.Ioo (0 : ℝ) 1 := by
  induction n with
  | zero => simpa [decodeSeed] using And.intro hy0 hy1
  | succ n ih =>
    simp only [decodeSeed]
    exact inverseBranch_mem_Ioo _ (ih (fun i => bits i.succ)).1
      (ih (fun i => bits i.succ)).2

lemma decodeSeed_iterate {n : ℕ} (bits : Fin n → Bool) {y : ℝ}
    (hy0 : 0 < y) (hy1 : y < 1) : logistic^[n] (decodeSeed bits y) = y := by
  induction n with
  | zero => simp [decodeSeed]
  | succ n ih =>
    rw [Function.iterate_succ_apply, decodeSeed, inverseBranch_logistic]
    · exact ih (fun i => bits i.succ)
    · exact (decodeSeed_mem_Ioo (fun i => bits i.succ) hy0 hy1).1.le
    · exact (decodeSeed_mem_Ioo (fun i => bits i.succ) hy0 hy1).2.le

lemma decodeSeed_injective {n : ℕ} {y : ℝ} (hy0 : 0 < y) (hy1 : y < 1) :
    Function.Injective (fun bits : Fin n → Bool => decodeSeed bits y) := by
  induction n with
  | zero => intro a b h; funext i; exact Fin.elim0 i
  | succ n ih =>
    intro a b hab
    have htail : decodeSeed (fun i => a i.succ) y =
        decodeSeed (fun i => b i.succ) y := by
      have h := congrArg logistic hab
      simpa [decodeSeed, inverseBranch_logistic,
        (decodeSeed_mem_Ioo (fun i => a i.succ) hy0 hy1).1.le,
        (decodeSeed_mem_Ioo (fun i => a i.succ) hy0 hy1).2.le,
        (decodeSeed_mem_Ioo (fun i => b i.succ) hy0 hy1).1.le,
        (decodeSeed_mem_Ioo (fun i => b i.succ) hy0 hy1).2.le] using h
    have htails := ih htail
    have hhead : a 0 = b 0 := by
      by_contra h
      have hsA := inverseBranch_side (a 0)
        (decodeSeed_mem_Ioo (fun i => a i.succ) hy0 hy1).1
        (decodeSeed_mem_Ioo (fun i => a i.succ) hy0 hy1).2
      have hsB := inverseBranch_side (b 0)
        (decodeSeed_mem_Ioo (fun i => b i.succ) hy0 hy1).1
        (decodeSeed_mem_Ioo (fun i => b i.succ) hy0 hy1).2
      cases ha : a 0 <;> cases hb : b 0 <;>
        simp_all [decodeSeed] <;> nlinarith
    funext i
    refine Fin.cases hhead (fun j => ?_) i
    exact congrFun htails j

lemma interior_of_iterate_interior {n : ℕ} {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1)
    (hiter0 : 0 < logistic^[n] x) (hiter1 : logistic^[n] x < 1) :
    x ∈ Set.Ioo (0 : ℝ) 1 := by
  induction n generalizing x with
  | zero => simpa using And.intro hiter0 hiter1
  | succ n ih =>
    rw [Function.iterate_succ_apply] at hiter0 hiter1
    have hmap := logistic_maps_unitInterval hx0 hx1
    have hinter := ih hmap.1 hmap.2 hiter0 hiter1
    exact interior_of_logistic_interior hx0 hx1 hinter.1 hinter.2

lemma decodeSeed_surjective_on_fiber {n : ℕ} {x y : ℝ}
    (hx0 : 0 < x) (hx1 : x < 1) (hy0 : 0 < y) (hy1 : y < 1)
    (hxy : logistic^[n] x = y) :
    ∃ bits : Fin n → Bool, decodeSeed bits y = x := by
  induction n generalizing x with
  | zero =>
    refine ⟨fun i => Fin.elim0 i, ?_⟩
    simpa [decodeSeed] using hxy.symm
  | succ n ih =>
    rw [Function.iterate_succ_apply] at hxy
    have hmap := logistic_maps_unitInterval hx0.le hx1.le
    have hlogmem : logistic x ∈ Set.Ioo (0 : ℝ) 1 :=
      interior_of_iterate_interior hmap.1 hmap.2 (by rw [hxy]; exact hy0)
        (by rw [hxy]; exact hy1)
    obtain ⟨tail, htail⟩ := ih hlogmem.1 hlogmem.2 hxy
    obtain ⟨upper, hupper⟩ := eq_inverseBranch_of_logistic_eq hx0 hx1
      (by rw [← htail])
    refine ⟨Fin.cases upper tail, ?_⟩
    simpa [decodeSeed] using hupper.symm

/-- The entire interior fiber is exactly the range of recursive branch decoding. -/
theorem interior_fiber_eq_decodeSeed_range (n : ℕ) {y : ℝ} (hy0 : 0 < y) (hy1 : y < 1) :
    {x : ℝ | x ∈ Set.Ioo (0 : ℝ) 1 ∧ logistic^[n] x = y} =
      Set.range (fun bits : Fin n → Bool => decodeSeed bits y) := by
  ext x
  constructor
  · rintro ⟨hx, hiter⟩
    obtain ⟨bits, hbits⟩ := decodeSeed_surjective_on_fiber hx.1 hx.2 hy0 hy1 hiter
    exact ⟨bits, hbits⟩
  · rintro ⟨bits, rfl⟩
    exact ⟨decodeSeed_mem_Ioo bits hy0 hy1, decodeSeed_iterate bits hy0 hy1⟩

/-- Every interior target has exactly `2^n` interior preimages under the `n`-fold
iterate of the full-strength logistic map. -/
theorem interior_fiber_ncard (n : ℕ) {y : ℝ} (hy0 : 0 < y) (hy1 : y < 1) :
    {x : ℝ | x ∈ Set.Ioo (0 : ℝ) 1 ∧ logistic^[n] x = y}.ncard = 2 ^ n := by
  rw [interior_fiber_eq_decodeSeed_range n hy0 hy1,
    Set.ncard_range_of_injective (decodeSeed_injective hy0 hy1),
    Nat.card_eq_fintype_card, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]

end LogisticChaos