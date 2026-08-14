import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutZolotarevGeneral

/-!
# The affine readout adds nothing (conjecture C1, the invertible-shift half)

The multiplicative permutation `μ_a : x ↦ a·x` of `ZMod N` has now been analysed
completely (`Physics/PermutationReadout{Core,ZolotarevGeneral,EvenModulus}.lean`).
The natural next question — raised as conjecture **C1** in `FUTURE_DIRECTIONS.md`
— is whether the larger *affine* family

  `σ_{a,b} : x ↦ a·x + b`

can carry information that `μ_a` does not.  This file answers it in the regime
where the answer is unconditional: whenever `1 − a` is invertible modulo `N`, the
affine map is *conjugate* to the multiplicative one by a translation, hence has
literally the same cycle structure, so the shift `b` is invisible.  The opposite
extreme `a = 1` is the pure translation, whose cycle count is the free gcd probe
`gcd(N, b)`.  Together: on the two extremes of the affine family the readout is
either the multiplicative readout verbatim or a quantity computable in one gcd.

To state this we need a cycle count for *arbitrary* self-maps of `ZMod N`, not
just for multiplications; `cycleCountOf` provides it (orbits of the iteration
`f^[k]`, which for a permutation of an `N`-element set are exhausted after `N`
steps).  `cycleCountOf_mul` identifies it with the `cycleCount` of the earlier
files, so the two developments are compatible.

## Main results

* `Physics.PermReadout.cycleCountOf_conj` — conjugate maps have equal cycle
  counts.
* `Physics.PermReadout.cycleCountOf_mul` — `cycleCountOf N (a · ·) = cycleCount N a`.
* `Physics.PermReadout.cycleCountOf_affine` — for `1 − a` invertible,
  `cycleCountOf N (fun x => a·x + b) = cycleCount N a`: **the shift is invisible**.
* `Physics.PermReadout.cycleCountOf_affine_indep_shift` — the same statement in
  the form "the affine cycle count does not depend on `b`".
* `Physics.PermReadout.zolotarev_affine` — consequently the sign of an affine
  permutation with invertible `1 − a` at an odd modulus is the Jacobi symbol
  `J(a | N)`, again a factorisation-free quantity.
* `Physics.PermReadout.cycleCountOf_add` — the pure translation `x ↦ x + b` has
  exactly `gcd(N, b)` cycles.
-/

namespace Physics.PermReadout

open Finset

section GeneralCycleCount

variable {N : ℕ} [NeZero N]

/-- The orbit of `x` under iteration of an arbitrary self-map `f` of `ZMod N`.
For a permutation of the `N`-element set `ZMod N` every orbit is already
exhausted after `N` steps, so the window `range N` loses nothing. -/
noncomputable def orbIter (N : ℕ) [NeZero N] (f : ZMod N → ZMod N) (x : ZMod N) :
    Finset (ZMod N) :=
  (Finset.range N).image (fun k => f^[k] x)

/-- The number of distinct orbits of an arbitrary self-map of `ZMod N`. -/
noncomputable def cycleCountOf (N : ℕ) [NeZero N] (f : ZMod N → ZMod N) : ℕ :=
  (Finset.univ.image (orbIter N f)).card

omit [NeZero N] in
/-- Conjugation intertwines the iterates. -/
theorem iterate_conj {f g : ZMod N → ZMod N} (e : ZMod N ≃ ZMod N)
    (h : ∀ x, e (f x) = g (e x)) (k : ℕ) (x : ZMod N) : g^[k] (e x) = e (f^[k] x) := by
  induction k generalizing x with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply, Function.iterate_succ_apply, ← h, ih]

/-- Conjugation carries orbits to orbits. -/
theorem orbIter_conj {f g : ZMod N → ZMod N} (e : ZMod N ≃ ZMod N)
    (h : ∀ x, e (f x) = g (e x)) (x : ZMod N) :
    orbIter N g (e x) = (orbIter N f x).image e := by
  unfold orbIter
  rw [Finset.image_image]
  exact Finset.image_congr (fun k _ => iterate_conj e h k x)

/-- **Conjugation invariance of the cycle count.**  If `e ∘ f = g ∘ e` for a
bijection `e`, then `f` and `g` have the same number of cycles. -/
theorem cycleCountOf_conj {f g : ZMod N → ZMod N} (e : ZMod N ≃ ZMod N)
    (h : ∀ x, e (f x) = g (e x)) : cycleCountOf N g = cycleCountOf N f := by
  have h1 : (Finset.univ.image (orbIter N g)) =
      (Finset.univ.image (orbIter N f)).image (fun s => s.image e) := by
    ext o
    simp only [Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨y, rfl⟩
      exact ⟨orbIter N f (e.symm y), ⟨e.symm y, rfl⟩, by
        rw [← orbIter_conj e h, Equiv.apply_symm_apply]⟩
    · rintro ⟨s, ⟨x, rfl⟩, rfl⟩
      exact ⟨e x, orbIter_conj e h x⟩
  rw [cycleCountOf, h1, Finset.card_image_of_injective _ (Finset.image_injective e.injective),
    cycleCountOf]

end GeneralCycleCount

section Multiplicative

variable {N : ℕ} [NeZero N] {a : ℕ}

omit [NeZero N] in
theorem iterate_mul (c : ZMod N) (k : ℕ) (x : ZMod N) :
    (fun y => c * y)^[k] x = c ^ k * x := by
  induction k generalizing x with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply, ih, pow_succ]; ring

/-- The period of a point never exceeds the modulus. -/
theorem period_le (x : ZMod N) : period N a x.val ≤ N := by
  have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
  set M := N / Nat.gcd N x.val with hM
  have hdvd : M ∣ N := Nat.div_dvd_of_dvd (Nat.gcd_dvd_left N x.val)
  have hM0 : 0 < M := Nat.pos_of_dvd_of_pos hdvd hN
  haveI : NeZero M := ⟨hM0.ne'⟩
  have h1 : orderOf ((a : ZMod M)) ≤ Nat.card (ZMod M) := orderOf_le_card
  have h2 : Nat.card (ZMod M) = M := by
    rw [Nat.card_eq_fintype_card, ZMod.card]
  exact le_trans (by simpa [period, ← hM] using h1) (by
    simpa [h2] using Nat.le_of_dvd hN hdvd)

/-- The iteration orbit of the multiplication map is the orbit `orb` of the
earlier files. -/
theorem orbIter_mul (hcop : Nat.Coprime a N) (x : ZMod N) :
    orbIter N (fun y => (a : ZMod N) * y) x = orb N a x := by
  ext y
  constructor
  · intro hy
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp hy
    rw [iterate_mul]
    exact (mem_orb_iff hcop x _).mpr ⟨k, rfl⟩
  · intro hy
    obtain ⟨k, hk, rfl⟩ := Finset.mem_image.mp hy
    refine Finset.mem_image.mpr ⟨k, ?_, by rw [iterate_mul]⟩
    exact Finset.mem_range.mpr
      (lt_of_lt_of_le (Finset.mem_range.mp hk) (period_le x))

/-- **Compatibility.**  The general cycle count of the multiplication map is the
`cycleCount` of the stratification analysis. -/
theorem cycleCountOf_mul (hcop : Nat.Coprime a N) :
    cycleCountOf N (fun y => (a : ZMod N) * y) = cycleCount N a := by
  rw [cycleCountOf, cycleCount]
  congr 1
  exact Finset.image_congr (fun x _ => orbIter_mul hcop x)

end Multiplicative

section Affine

variable {N : ℕ} [NeZero N] {a b : ℕ}

/-- **The affine readout collapses onto the multiplicative one.**  If `1 − a` is
invertible modulo `N` then the translation `x ↦ x + b·(1−a)⁻¹` conjugates
`x ↦ a·x` into `x ↦ a·x + b`, so the two permutations have the same cycle
structure and the shift `b` carries no information whatsoever. -/
theorem cycleCountOf_affine (hcop : Nat.Coprime a N)
    (hu : IsUnit ((1 : ZMod N) - (a : ZMod N))) :
    cycleCountOf N (fun x => (a : ZMod N) * x + (b : ZMod N)) = cycleCount N a := by
  obtain ⟨v, hv⟩ := isUnit_iff_exists_inv.mp hu
  set c : ZMod N := (b : ZMod N) * v with hc
  have hcb : c * ((1 : ZMod N) - (a : ZMod N)) = (b : ZMod N) := by
    calc c * ((1 : ZMod N) - (a : ZMod N))
        = (b : ZMod N) * (((1 : ZMod N) - (a : ZMod N)) * v) := by rw [hc]; ring
      _ = (b : ZMod N) := by rw [hv, mul_one]
  have hkey : (a : ZMod N) * c + (b : ZMod N) = c := by
    rw [← hcb]; ring
  rw [← cycleCountOf_mul hcop]
  refine cycleCountOf_conj (Equiv.addRight c) (fun x => ?_)
  simp only [Equiv.coe_addRight]
  rw [mul_add, add_assoc, hkey]

/-- The affine cycle count does not depend on the shift, whenever `1 − a` is a
unit: no affine readout in this regime is finer than the multiplicative one. -/
theorem cycleCountOf_affine_indep_shift (hcop : Nat.Coprime a N)
    (hu : IsUnit ((1 : ZMod N) - (a : ZMod N))) (b b' : ℕ) :
    cycleCountOf N (fun x => (a : ZMod N) * x + (b : ZMod N)) =
      cycleCountOf N (fun x => (a : ZMod N) * x + (b' : ZMod N)) := by
  rw [cycleCountOf_affine hcop hu, cycleCountOf_affine hcop hu]

/-- **Zolotarev for affine permutations.**  At an odd modulus, and for every
multiplier with `1 − a` invertible, the parity of the affine permutation
`x ↦ a·x + b` is the Jacobi symbol `J(a | N)` — independently of `b`.  The
affine family therefore has exactly the same (factorisation-free) sign readout
as the multiplicative one. -/
theorem zolotarev_affine (hodd : Odd N) (hcop : Nat.Coprime a N)
    (hu : IsUnit ((1 : ZMod N) - (a : ZMod N))) :
    jacobiSym (a : ℤ) N = 1 ↔
      (N - cycleCountOf N (fun x => (a : ZMod N) * x + (b : ZMod N))) % 2 = 0 := by
  rw [cycleCountOf_affine hcop hu]
  exact zolotarev_general hodd hcop

end Affine

section Translation

variable {N : ℕ} [NeZero N]

/-- The finite subgroup of multiples of `b`: the orbit of `0` under `x ↦ x + b`. -/
noncomputable def transSub (N : ℕ) [NeZero N] (b : ZMod N) : Finset (ZMod N) :=
  (Finset.range (addOrderOf b)).image (fun k => k • b)

omit [NeZero N] in
theorem addOrderOf_dvd_modulus (b : ZMod N) : addOrderOf b ∣ N := by
  rw [addOrderOf_dvd_iff_nsmul_eq_zero, nsmul_eq_mul, ZMod.natCast_self, zero_mul]

theorem mem_transSub {b y : ZMod N} : y ∈ transSub N b ↔ ∃ k : ℕ, k • b = y := by
  constructor
  · intro h
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp h
    exact ⟨k, rfl⟩
  · rintro ⟨k, rfl⟩
    refine Finset.mem_image.mpr ⟨k % addOrderOf b,
      Finset.mem_range.mpr (Nat.mod_lt _ (addOrderOf_pos b)), ?_⟩
    conv_rhs => rw [← Nat.mod_add_div k (addOrderOf b)]
    rw [add_smul, mul_comm, mul_smul, addOrderOf_nsmul_eq_zero, smul_zero, add_zero]

theorem card_transSub (b : ZMod N) : (transSub N b).card = addOrderOf b := by
  rw [transSub, Finset.card_image_of_injOn, Finset.card_range]
  have key : ∀ i j : ℕ, i ≤ j → j < addOrderOf b → i • b = j • b → i = j := by
    intro i j hij hj heq
    have h1 : (j - i) • b + i • b = j • b := by
      rw [← add_smul, Nat.sub_add_cancel hij]
    rw [heq] at h1
    have h0 : (j - i) • b = 0 := add_right_cancel (b := j • b) (by rw [zero_add]; exact h1)
    have hdvd : addOrderOf b ∣ (j - i) := addOrderOf_dvd_of_nsmul_eq_zero h0
    by_contra hne
    have hpos : 0 < j - i := by omega
    have := Nat.le_of_dvd hpos hdvd
    omega
  intro i hi j hj hij
  simp only [Finset.coe_range, Set.mem_Iio] at hi hj
  rcases le_total i j with h | h
  · exact key i j h hj hij
  · exact (key j i h hi hij.symm).symm

omit [NeZero N] in
theorem iterate_translate (b : ZMod N) (k : ℕ) (x : ZMod N) :
    (fun y => y + b)^[k] x = x + k • b := by
  induction k generalizing x with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply, ih]; module

/-- The orbits of a translation are the cosets of the subgroup of multiples. -/
theorem orbIter_add (b x : ZMod N) :
    orbIter N (fun y => y + b) x = (transSub N b).image (fun t => x + t) := by
  ext y
  simp only [orbIter, Finset.mem_image, Finset.mem_range]
  constructor
  · rintro ⟨k, -, rfl⟩
    exact ⟨k • b, mem_transSub.mpr ⟨k, rfl⟩, (iterate_translate b k x).symm⟩
  · rintro ⟨t, ht, rfl⟩
    obtain ⟨k, rfl⟩ := mem_transSub.mp ht
    have hle : addOrderOf b ≤ N :=
      Nat.le_of_dvd (Nat.pos_of_ne_zero (NeZero.ne N)) (addOrderOf_dvd_modulus b)
    refine ⟨k % addOrderOf b, lt_of_lt_of_le (Nat.mod_lt _ (addOrderOf_pos b)) hle, ?_⟩
    rw [iterate_translate]
    congr 1
    conv_rhs => rw [← Nat.mod_add_div k (addOrderOf b)]
    rw [add_smul, mul_comm, mul_smul, addOrderOf_nsmul_eq_zero, smul_zero, add_zero]

theorem self_mem_orbIter_add (b x : ZMod N) : x ∈ orbIter N (fun y => y + b) x := by
  rw [orbIter_add]
  exact Finset.mem_image.mpr ⟨0, mem_transSub.mpr ⟨0, by simp⟩, by simp⟩

theorem orbIter_add_eq_of_mem {b x y : ZMod N} (hy : y ∈ orbIter N (fun z => z + b) x) :
    orbIter N (fun z => z + b) y = orbIter N (fun z => z + b) x := by
  rw [orbIter_add] at hy
  obtain ⟨t, ht, rfl⟩ := Finset.mem_image.mp hy
  obtain ⟨k, rfl⟩ := mem_transSub.mp ht
  rw [orbIter_add, orbIter_add]
  ext z
  simp only [Finset.mem_image]
  constructor
  · rintro ⟨s, hs, rfl⟩
    obtain ⟨j, rfl⟩ := mem_transSub.mp hs
    exact ⟨(k + j) • b, mem_transSub.mpr ⟨k + j, rfl⟩, by rw [add_smul]; abel⟩
  · rintro ⟨s, hs, rfl⟩
    obtain ⟨j, rfl⟩ := mem_transSub.mp hs
    have hm : addOrderOf b * k ≥ k := Nat.le_mul_of_pos_left _ (addOrderOf_pos b)
    have hzero : (addOrderOf b * k) • b = 0 := by
      rw [mul_comm, mul_smul, addOrderOf_nsmul_eq_zero, smul_zero]
    have hcancel : (addOrderOf b * k - k) • b + k • b = 0 := by
      rw [← add_smul, Nat.sub_add_cancel hm, hzero]
    refine ⟨(j + (addOrderOf b * k - k)) • b, mem_transSub.mpr ⟨_, rfl⟩, ?_⟩
    calc x + k • b + (j + (addOrderOf b * k - k)) • b
        = x + j • b + ((addOrderOf b * k - k) • b + k • b) := by rw [add_smul]; abel
      _ = x + j • b := by rw [hcancel, add_zero]

theorem card_orbIter_add (b x : ZMod N) :
    (orbIter N (fun y => y + b) x).card = addOrderOf b := by
  rw [orbIter_add, Finset.card_image_of_injective _ (add_right_injective x), card_transSub]

/-- All translation cycles have the same length, so their number times that
length is the size of the ring. -/
theorem cycleCountOf_add_mul (b : ZMod N) :
    cycleCountOf N (fun y => y + b) * addOrderOf b = N := by
  classical
  set f : ZMod N → ZMod N := fun y => y + b with hf
  have hcard : (Finset.univ : Finset (ZMod N)).card = N := by simp [ZMod.card]
  have h := Finset.card_eq_sum_card_image (orbIter N f) (Finset.univ : Finset (ZMod N))
  rw [hcard] at h
  have hsum : ∑ o ∈ Finset.univ.image (orbIter N f),
      (Finset.univ.filter (fun x => orbIter N f x = o)).card
      = ∑ _o ∈ Finset.univ.image (orbIter N f), addOrderOf b := by
    refine Finset.sum_congr rfl (fun o ho => ?_)
    obtain ⟨x, -, rfl⟩ := Finset.mem_image.mp ho
    have hfib : (Finset.univ.filter (fun y => orbIter N f y = orbIter N f x))
        = orbIter N f x := by
      ext y
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨fun hy => hy ▸ self_mem_orbIter_add b y, fun hy => orbIter_add_eq_of_mem hy⟩
    rw [hfib, card_orbIter_add]
  rw [hsum, Finset.sum_const, smul_eq_mul] at h
  exact h.symm

/-- **The translation readout is a single gcd.**  The permutation `x ↦ x + b` of
`ZMod N` has exactly `gcd(N, b)` cycles — the free probe, no more. -/
theorem cycleCountOf_add (b : ZMod N) :
    cycleCountOf N (fun y => y + b) = Nat.gcd N b.val := by
  have hb : ((b.val : ℕ) : ZMod N) = b := by simp [ZMod.natCast_val, ZMod.cast_id]
  have hord : addOrderOf b = N / Nat.gcd N b.val := by
    conv_lhs => rw [← hb]
    rw [ZMod.addOrderOf_coe _ (NeZero.ne N)]
  have hdvd : Nat.gcd N b.val ∣ N := Nat.gcd_dvd_left _ _
  have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
  have hg : 0 < Nat.gcd N b.val := Nat.gcd_pos_of_pos_left _ hN
  have h := cycleCountOf_add_mul b
  rw [hord] at h
  have hq : N / Nat.gcd N b.val * Nat.gcd N b.val = N := Nat.div_mul_cancel hdvd
  nlinarith [h, hq, Nat.div_pos (Nat.le_of_dvd hN hdvd) hg]

end Translation

end Physics.PermReadout