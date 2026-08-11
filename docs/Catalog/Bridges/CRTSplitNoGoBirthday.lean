import Mathlib

/-!
# The CRT-Split No-Go, Part VI: the birthday law for orbit prefixes

Parts I–V reduce the factor-revealing event of any `N`-explicit iteration to a cycle closure
of the reduced orbit mod `p`.  This file supplies the missing *quantitative* half for the
generic regime (a): an exact count of how many maps of a finite set have a collision-free
orbit prefix.

**Main theorem** (`card_injPrefix`).  Let `α` be a finite type with `n = card α` elements and
let `a : α`.  For `T < n`, the number of maps `f : α → α` whose orbit prefix
`a, f a, …, f^[T] a` is injective is exactly

  `(n - 1).descFactorial T * n ^ (n - T)`.

Equivalently, the fraction of maps with a collision-free prefix of length `T + 1` is
`∏_{i=1}^{T} (1 - i/n)`, the classical birthday product: it drops below `1/2` only once
`T ≍ √n`.  With `n = p ≈ √N` this is the `N^{1/4}` of Pollard rho, and it is exponential in
`log N`.

The proof is a fibration argument: the "reset" operation, which overwrites the value of `f`
at the last prefix point `f^[T] a`, has fibers of size exactly `n` inside the collision-free
set at level `T`, of which exactly `n - (T+1)` survive to level `T + 1`.  The key structural
input is `orb_eq_of_agree`: an orbit prefix depends only on the values of `f` at the earlier
prefix points, which is the finite-set shadow of Fact 2 (locality of iteration).

Small cases are cross-checked by exhaustive enumeration (`card_injPrefix_fin4_two`).
-/

namespace CRTSplitNoGo

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The orbit of the base point `a` under `f`. -/
def orb (f : α → α) (a : α) (i : ℕ) : α := f^[i] a

omit [Fintype α] [DecidableEq α] in
@[simp] lemma orb_zero (f : α → α) (a : α) : orb f a 0 = a := rfl

omit [Fintype α] [DecidableEq α] in
lemma orb_succ (f : α → α) (a : α) (i : ℕ) : orb f a (i + 1) = f (orb f a i) := by
  simp [orb, Function.iterate_succ_apply']

/-- The orbit prefix `a, f a, …, f^[T] a` is collision-free. -/
def InjPrefix (f : α → α) (a : α) (T : ℕ) : Prop :=
  ∀ i ≤ T, ∀ j ≤ T, orb f a i = orb f a j → i = j

instance (f : α → α) (a : α) (T : ℕ) : Decidable (InjPrefix f a T) := by
  unfold InjPrefix; infer_instance

omit [Fintype α] [DecidableEq α] in
lemma InjPrefix.mono {f : α → α} {a : α} {T : ℕ} (h : InjPrefix f a (T + 1)) :
    InjPrefix f a T := fun i hi j hj hij => h i (by omega) j (by omega) hij

omit [Fintype α] [DecidableEq α] in
/-- **Locality of iteration.**  An orbit prefix only sees the values of the map at the earlier
prefix points. -/
lemma orb_eq_of_agree (f g : α → α) (a : α) (k : ℕ)
    (h : ∀ i, i < k → g (orb f a i) = f (orb f a i)) :
    ∀ i, i ≤ k → orb g a i = orb f a i := by
  intro i
  induction i with
  | zero => intro _; simp
  | succ i ih =>
      intro hik
      rw [orb_succ, ih (by omega), h i (by omega), orb_succ]

/-- The set of maps with a collision-free orbit prefix of length `T + 1`. -/
def injPrefixFinset (a : α) (T : ℕ) : Finset (α → α) :=
  Finset.univ.filter (fun f : α → α => InjPrefix f a T)

/-- Overwrite the value of `f` at the last prefix point by the base point. -/
def reset (a : α) (T : ℕ) (f : α → α) : α → α := Function.update f (orb f a T) a

omit [Fintype α] in
lemma orb_reset (a : α) (T : ℕ) {f : α → α} (hf : InjPrefix f a T) :
    ∀ i ≤ T, orb (reset a T f) a i = orb f a i := by
  refine orb_eq_of_agree f (reset a T f) a T (fun i hi => ?_)
  have hne : orb f a i ≠ orb f a T := by
    intro hEq
    have := hf i (by omega) T (by omega) hEq
    omega
  simp [reset, Function.update_of_ne hne]

omit [Fintype α] in
lemma injPrefix_reset (a : α) (T : ℕ) {f : α → α} (hf : InjPrefix f a T) :
    InjPrefix (reset a T f) a T := by
  intro i hi j hj hij
  rw [orb_reset a T hf i hi, orb_reset a T hf j hj] at hij
  exact hf i hi j hj hij

omit [Fintype α] in
lemma reset_apply_last (a : α) (T : ℕ) {f : α → α} (hf : InjPrefix f a T) :
    (reset a T f) (orb (reset a T f) a T) = a := by
  rw [orb_reset a T hf T le_rfl]
  simp [reset]

omit [Fintype α] in
/-- Every element of a fiber of `reset` is an update of the fiber's base point. -/
lemma eq_update_of_reset_eq (a : α) (T : ℕ) {f h : α → α} (hf : InjPrefix f a T)
    (hrf : reset a T f = h) : f = Function.update h (orb h a T) (f (orb h a T)) := by
  have horb : orb h a T = orb f a T := by rw [← hrf]; exact orb_reset a T hf T le_rfl
  funext w
  by_cases hw : w = orb h a T
  · subst hw; simp
  · rw [Function.update_of_ne hw, ← hrf]
    have : w ≠ orb f a T := by rwa [horb] at hw
    simp [reset, Function.update_of_ne this]

omit [Fintype α] in
/-- Conversely, any update of a reset point at the last prefix position lies in the fiber. -/
lemma reset_update (a : α) (T : ℕ) {h : α → α} (hh : InjPrefix h a T)
    (hlast : h (orb h a T) = a) (v : α) :
    reset a T (Function.update h (orb h a T) v) = h ∧
      InjPrefix (Function.update h (orb h a T) v) a T ∧
      ∀ i ≤ T, orb (Function.update h (orb h a T) v) a i = orb h a i := by
  have hagree : ∀ i, i < T → (Function.update h (orb h a T) v) (orb h a i) = h (orb h a i) := by
    intro i hi
    have hne : orb h a i ≠ orb h a T := by
      intro hEq
      have := hh i (by omega) T le_rfl hEq
      omega
    simp [Function.update_of_ne hne]
  have horb : ∀ i ≤ T, orb (Function.update h (orb h a T) v) a i = orb h a i :=
    orb_eq_of_agree h _ a T hagree
  have hinj : InjPrefix (Function.update h (orb h a T) v) a T := by
    intro i hi j hj hij
    rw [horb i hi, horb j hj] at hij
    exact hh i hi j hj hij
  refine ⟨?_, hinj, horb⟩
  unfold reset
  rw [horb T le_rfl]
  funext w
  by_cases hw : w = orb h a T
  · subst hw; simp [hlast]
  · simp [Function.update_of_ne hw]

/-- The fiber of `reset` over `h` inside the level-`T` set is the set of all updates of `h` at
its last prefix point; it has exactly `n` elements. -/
lemma card_fiber (a : α) (T : ℕ) {h : α → α} (hh : InjPrefix h a T)
    (hlast : h (orb h a T) = a) :
    ((injPrefixFinset a T).filter (fun f => reset a T f = h)).card = Fintype.card α := by
  classical
  have hset : (injPrefixFinset a T).filter (fun f => reset a T f = h)
      = Finset.image (fun v : α => Function.update h (orb h a T) v) Finset.univ := by
    ext f
    simp only [Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and,
      injPrefixFinset]
    constructor
    · rintro ⟨hf, hrf⟩
      exact ⟨f (orb h a T), (eq_update_of_reset_eq a T hf hrf).symm⟩
    · rintro ⟨v, rfl⟩
      obtain ⟨h1, h2, -⟩ := reset_update a T hh hlast v
      exact ⟨h2, h1⟩
  rw [hset, Finset.card_image_of_injective _ (fun v w hvw => by
    have := congrFun hvw (orb h a T)
    simpa using this), Finset.card_univ]

/-- Inside the same fiber, exactly `n - (T + 1)` maps survive to level `T + 1`. -/
lemma card_fiber_succ (a : α) (T : ℕ) {h : α → α} (hh : InjPrefix h a T)
    (hlast : h (orb h a T) = a) :
    ((injPrefixFinset a (T + 1)).filter (fun f => reset a T f = h)).card
      = Fintype.card α - (T + 1) := by
  classical
  set S : Finset α := (Finset.range (T + 1)).image (fun i => orb h a i) with hS
  have hScard : S.card = T + 1 := by
    rw [hS, Finset.card_image_of_injOn, Finset.card_range]
    intro i hi j hj hij
    exact hh i (Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)) j
      (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)) hij
  have hset : (injPrefixFinset a (T + 1)).filter (fun f => reset a T f = h)
      = Finset.image (fun v : α => Function.update h (orb h a T) v) (Finset.univ \ S) := by
    ext f
    simp only [Finset.mem_filter, Finset.mem_image, Finset.mem_sdiff, Finset.mem_univ, true_and,
      injPrefixFinset]
    constructor
    · rintro ⟨hf, hrf⟩
      have hfT : InjPrefix f a T := hf.mono
      have hupd := eq_update_of_reset_eq a T hfT hrf
      have horbh : orb h a T = orb f a T := by rw [← hrf]; exact orb_reset a T hfT T le_rfl
      refine ⟨f (orb h a T), ?_, hupd.symm⟩
      intro hmem
      rw [hS, Finset.mem_image] at hmem
      obtain ⟨i, hi, hival⟩ := hmem
      have hiT : i ≤ T := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
      have hfz : f (orb h a T) = orb f a (T + 1) := by rw [orb_succ, ← horbh]
      have horb_i : orb h a i = orb f a i := by
        have := orb_reset a T hfT i hiT
        rw [hrf] at this
        exact this
      have hcoll : orb f a (T + 1) = orb f a i := by rw [← hfz, ← hival, horb_i]
      have := hf (T + 1) le_rfl i (by omega) hcoll
      omega
    · rintro ⟨v, hv, rfl⟩
      obtain ⟨h1, -, horb⟩ := reset_update a T hh hlast v
      refine ⟨?_, h1⟩
      have hlastf : orb (Function.update h (orb h a T) v) a (T + 1) = v := by
        rw [orb_succ, horb T le_rfl]
        simp
      intro i hi j hj hij
      rcases Nat.lt_or_ge i (T + 1) with hi' | hi' <;> rcases Nat.lt_or_ge j (T + 1) with hj' | hj'
      · rw [horb i (by omega), horb j (by omega)] at hij
        exact hh i (by omega) j (by omega) hij
      · exfalso
        have hjT : j = T + 1 := by omega
        subst hjT
        rw [horb i (by omega), hlastf] at hij
        have hmemS : v ∈ S := by
          rw [hS]
          exact Finset.mem_image.mpr ⟨i, Finset.mem_range.mpr (by omega), hij⟩
        exact hv hmemS
      · exfalso
        have hiT : i = T + 1 := by omega
        subst hiT
        rw [horb j (by omega), hlastf] at hij
        have hmemS : v ∈ S := by
          rw [hS]
          exact Finset.mem_image.mpr ⟨j, Finset.mem_range.mpr (by omega), hij.symm⟩
        exact hv hmemS
      · omega
  rw [hset, Finset.card_image_of_injective _ (fun v w hvw => by
    have := congrFun hvw (orb h a T)
    simpa using this), Finset.card_univ_diff, hScard]

/-- The reset map lands in the image of the level-`T` set. -/
lemma reset_mem_image (a : α) (T : ℕ) {f : α → α} (hf : f ∈ injPrefixFinset a T) :
    reset a T f ∈ (injPrefixFinset a T).image (reset a T) := Finset.mem_image_of_mem _ hf

/-- **The birthday law for orbit prefixes.**  For `T < n = card α`, the number of maps
`f : α → α` whose orbit prefix `a, f a, …, f^[T] a` is collision-free equals
`(n - 1).descFactorial T * n ^ (n - T)`.  Dividing by `n ^ n`, the collision-free fraction is
`∏_{i=1}^{T} (1 - i/n)`: collisions become likely only at `T ≍ √n`. -/
theorem card_injPrefix (a : α) (T : ℕ) (hT : T < Fintype.card α) :
    (injPrefixFinset a T).card
      = (Fintype.card α - 1).descFactorial T * (Fintype.card α) ^ (Fintype.card α - T) := by
  classical
  induction T with
  | zero =>
      have : injPrefixFinset a 0 = Finset.univ := by
        ext f
        simp only [injPrefixFinset, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
        intro i hi j hj _
        omega
      rw [this, Finset.card_univ, Nat.descFactorial_zero, one_mul]
      simp
  | succ T ih =>
      have hTlt : T < Fintype.card α := by omega
      have hIH := ih hTlt
      set n := Fintype.card α with hn
      set img := (injPrefixFinset a T).image (reset a T) with himg
      -- every element of the image is a reset point
      have himgprop : ∀ h ∈ img, InjPrefix h a T ∧ h (orb h a T) = a := by
        intro h hh
        rw [himg, Finset.mem_image] at hh
        obtain ⟨f, hf, rfl⟩ := hh
        have hf' : InjPrefix f a T := by
          simpa [injPrefixFinset] using hf
        exact ⟨injPrefix_reset a T hf', reset_apply_last a T hf'⟩
      -- fiberwise counts at level `T` and at level `T+1`
      have hcardT : (injPrefixFinset a T).card = img.card * n := by
        rw [Finset.card_eq_sum_card_fiberwise
          (fun f hf => reset_mem_image a T hf), Finset.sum_congr rfl
          (fun h hh => card_fiber a T (himgprop h hh).1 (himgprop h hh).2),
          Finset.sum_const, smul_eq_mul]
      have hsub : ∀ f ∈ injPrefixFinset a (T + 1), reset a T f ∈ img := by
        intro f hf
        have hf' : InjPrefix f a (T + 1) := by simpa [injPrefixFinset] using hf
        exact reset_mem_image a T (by simpa [injPrefixFinset] using hf'.mono)
      have hcardT1 : (injPrefixFinset a (T + 1)).card = img.card * (n - (T + 1)) := by
        rw [Finset.card_eq_sum_card_fiberwise hsub, Finset.sum_congr rfl
          (fun h hh => card_fiber_succ a T (himgprop h hh).1 (himgprop h hh).2),
          Finset.sum_const, smul_eq_mul]
      -- solve for the size of the image and conclude
      have hnpos : 0 < n := by omega
      have hexp : n - T = (n - (T + 1)) + 1 := by omega
      have himgcard : img.card = (n - 1).descFactorial T * n ^ (n - (T + 1)) := by
        have : img.card * n = ((n - 1).descFactorial T * n ^ (n - (T + 1))) * n := by
          rw [← hcardT, hIH, hexp, pow_succ]
          ring
        exact Nat.eq_of_mul_eq_mul_right hnpos this
      rw [hcardT1, himgcard, Nat.descFactorial_succ]
      have hnT : n - 1 - T = n - (T + 1) := by omega
      rw [hnT]
      ring


/-! ## The birthday bound: most maps are still collision-free at time `√n` -/

/-- Weierstrass' product inequality. -/
lemma one_sub_sum_le_prod_one_sub (T : ℕ) (c : ℕ → ℝ)
    (h0 : ∀ i ∈ Finset.range T, 0 ≤ c i) (h1 : ∀ i ∈ Finset.range T, c i ≤ 1) :
    1 - ∑ i ∈ Finset.range T, c i ≤ ∏ i ∈ Finset.range T, (1 - c i) := by
  induction T with
  | zero => simp
  | succ T ih =>
      have hsub : ∀ i ∈ Finset.range T, i ∈ Finset.range (T + 1) := by
        intro i hi
        exact Finset.mem_range.mpr (Nat.lt_succ_of_lt (Finset.mem_range.mp hi))
      have ih' := ih (fun i hi => h0 i (hsub i hi)) (fun i hi => h1 i (hsub i hi))
      have hmemT : T ∈ Finset.range (T + 1) := Finset.mem_range.mpr (by omega)
      have hS : 0 ≤ ∑ i ∈ Finset.range T, c i :=
        Finset.sum_nonneg (fun i hi => h0 i (hsub i hi))
      have h2 : 0 ≤ 1 - c T := by linarith [h1 T hmemT]
      rw [Finset.sum_range_succ, Finset.prod_range_succ]
      nlinarith [mul_le_mul_of_nonneg_right ih' h2, mul_nonneg hS (h0 T hmemT)]

lemma sum_range_succ_div (T : ℕ) (x : ℝ) :
    ∑ i ∈ Finset.range T, ((i : ℝ) + 1) / x = (T * (T + 1)) / (2 * x) := by
  induction T with
  | zero => simp
  | succ T ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      field_simp
      ring

/-- **The birthday bound.**  At least a `1 - T(T+1)/(2n)` fraction of all `n^n` maps have a
collision-free orbit prefix of length `T + 1`. -/
theorem card_injPrefix_ge (a : α) (T : ℕ) (hT : T < Fintype.card α) :
    (1 - (T * (T + 1) : ℝ) / (2 * Fintype.card α)) * (Fintype.card α : ℝ) ^ (Fintype.card α)
      ≤ ((injPrefixFinset a T).card : ℝ) := by
  set n := Fintype.card α with hn
  have hnpos : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hnpos
  rw [card_injPrefix a T hT]
  push_cast
  have hD : ((n - 1).descFactorial T : ℝ) = ∏ i ∈ Finset.range T, ((n : ℝ) - 1 - i) := by
    rw [Nat.descFactorial_eq_prod_range, Nat.cast_prod]
    refine Finset.prod_congr rfl (fun i hi => ?_)
    have hi' : i < T := Finset.mem_range.mp hi
    have h1 : i ≤ n - 1 := by omega
    have h2 : 1 ≤ n := by omega
    rw [Nat.cast_sub h1, Nat.cast_sub h2]
    push_cast
    ring
  have hfac : ∏ i ∈ Finset.range T, ((n : ℝ) - 1 - i)
      = (n : ℝ) ^ T * ∏ i ∈ Finset.range T, (1 - ((i : ℝ) + 1) / n) := by
    have hterm : ∀ i ∈ Finset.range T,
        ((n : ℝ) - 1 - i) = (n : ℝ) * (1 - ((i : ℝ) + 1) / n) := by
      intro i _
      field_simp
      ring
    rw [Finset.prod_congr rfl hterm, Finset.prod_mul_distrib, Finset.prod_const,
      Finset.card_range]
  have hbound : 1 - (T * (T + 1) : ℝ) / (2 * n)
      ≤ ∏ i ∈ Finset.range T, (1 - ((i : ℝ) + 1) / n) := by
    have := one_sub_sum_le_prod_one_sub T (fun i => ((i : ℝ) + 1) / n)
      (fun i _ => by positivity)
      (fun i hi => by
        have hi' : i < T := Finset.mem_range.mp hi
        rw [div_le_one hnR]
        have : (i : ℝ) + 1 ≤ n := by
          have : i + 1 ≤ n := by omega
          exact_mod_cast this
        linarith)
    rwa [sum_range_succ_div T (n : ℝ)] at this
  have hpow : (n : ℝ) ^ T * (n : ℝ) ^ (n - T) = (n : ℝ) ^ n := by
    rw [← pow_add]
    congr 1
    omega
  have hnn : (0 : ℝ) ≤ (n : ℝ) ^ (n - T) := by positivity
  calc (1 - (T * (T + 1) : ℝ) / (2 * n)) * (n : ℝ) ^ n
      = ((1 - (T * (T + 1) : ℝ) / (2 * n)) * (n : ℝ) ^ T) * (n : ℝ) ^ (n - T) := by
        rw [mul_assoc, hpow]
    _ ≤ ((∏ i ∈ Finset.range T, (1 - ((i : ℝ) + 1) / n)) * (n : ℝ) ^ T) * (n : ℝ) ^ (n - T) := by
        have hT0 : (0 : ℝ) ≤ (n : ℝ) ^ T := by positivity
        exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hbound hT0) hnn
    _ = ((n - 1).descFactorial T : ℝ) * (n : ℝ) ^ (n - T) := by
        rw [hD, hfac]; ring

/-- **Generic maps need `√n` steps.**  Once `T (T+1) ≤ n` — i.e. `T ≲ √n` — at least half of
all maps of an `n`-element set still have a collision-free orbit prefix of length `T + 1`.
With `n = p ≈ √N` this is the `N^{1/4}` birthday barrier of Pollard rho, exponential in
`log N`. -/
theorem majority_collision_free (a : α) (T : ℕ) (hT : T < Fintype.card α)
    (h : T * (T + 1) ≤ Fintype.card α) :
    ((Fintype.card α : ℝ) ^ (Fintype.card α)) / 2 ≤ ((injPrefixFinset a T).card : ℝ) := by
  set n := Fintype.card α with hn
  have hnpos : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hnpos
  have hS : (T * (T + 1) : ℝ) / (2 * n) ≤ 1 / 2 := by
    rw [div_le_iff₀ (by positivity)]
    have : ((T * (T + 1) : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast h
    push_cast at this
    linarith
  have hpow : (0 : ℝ) ≤ (n : ℝ) ^ n := by positivity
  have := card_injPrefix_ge a T hT
  nlinarith [this]

/-- **The birthday barrier for the reduced dynamics.**  Specialised to `α = ZMod p`, the state
space of the mod-`p` reduction of an `N`-explicit iteration: for `T (T+1) ≤ p` at least half of
all maps of `ZMod p` have no cycle closure within `T` steps.  By Part I a factor of `N = p q`
can only appear at such a closure, so a generic reduced map hides the factor until
`T ≈ √p = N^{1/4}`. -/
theorem birthday_barrier_zmod (p : ℕ) [NeZero p] (T : ℕ) (hT : T < p) (h : T * (T + 1) ≤ p) :
    ((p : ℝ) ^ p) / 2 ≤ ((injPrefixFinset (0 : ZMod p) T).card : ℝ) := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have := majority_collision_free (0 : ZMod p) T (by rw [hcard]; exact hT) (by rw [hcard]; exact h)
  rwa [hcard] at this

/-! ## Exhaustive cross-check of the birthday law on a small case

For `α = Fin 4`, `a = 0`, `T = 2` the law predicts `3 · 2 · 4² = 96` collision-free maps out of
`4⁴ = 256`.  The following is verified by kernel enumeration of all `256` maps. -/

set_option maxRecDepth 100000 in
theorem card_injPrefix_fin4_two :
    (injPrefixFinset (0 : Fin 4) 2).card = 96 := by decide

end CRTSplitNoGo