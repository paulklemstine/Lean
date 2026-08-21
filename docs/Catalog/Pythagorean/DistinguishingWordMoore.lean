import Pythagorean.DistinguishingWordBound

/-!
# The Moore bound: linear-length distinguishing experiments

`DistinguishingWordBound.lean` bounds the length of a distinguishing experiment by the
size of the product state set, `|S| * |T|`.  This file sharpens that to the *linear*
bound `|S| + |T| - 2`, by replacing the product-automaton reachability argument with a
partition-refinement argument on the disjoint union of the two machines.

## The abstract engine

The combinatorial heart is stated independently of machines:

* `exists_stable_index` — a decreasing chain of equivalence relations on a finite type
  `U`, whose level `0` is already non-trivial, stabilises at some index
  `k ≤ |U| - 2`.

The proof counts blocks.  Writing `cls k x` for the `R k`-class of `x`, the map
`C ↦ (R k)-saturation of C` sends the level-`(k+1)` classes *onto* the level-`k`
classes, and fails to be injective exactly at a proper refinement step; hence each
proper refinement strictly increases the number of blocks, which is trapped in
`[2, |U|]`.

## Consequences

* `exists_distinguishing_word_le_card_sub_two` — one machine, `|U| - 2`.
* `exists_distinguishing_word_moore` — two machines, `|S| + |T| - 2`.
* `moore_bound_le_product_bound` / `exists_short_distinguishing_word_of_moore` — the
  Moore bound is never worse than the product bound, so the linear estimate subsumes
  the quadratic one.
-/

namespace Pythagorean.DistinguishingWord

universe u v w x

/-! ### The abstract partition-refinement engine -/

/-- **Refinement stabilisation.**  Let `R : ℕ → U → U → Prop` be a decreasing chain of
equivalence relations on a finite type `U`, and suppose `R 0` is already non-trivial
(some pair is unrelated).  Then the chain stabilises at some index `k ≤ |U| - 2`:
`R k` and `R (k+1)` coincide. -/
theorem exists_stable_index {U : Type w} [Fintype U] (R : ℕ → U → U → Prop)
    (hrefl : ∀ k x, R k x x) (hsymm : ∀ k x y, R k x y → R k y x)
    (htrans : ∀ k x y z, R k x y → R k y z → R k x z)
    (hmono : ∀ k x y, R (k + 1) x y → R k x y)
    (hstart : ∃ x y, ¬ R 0 x y) :
    ∃ k ≤ Fintype.card U - 2, ∀ x y, R k x y → R (k + 1) x y := by
  classical
  set N : ℕ := Fintype.card U with hN
  -- classes and their saturations
  set cls : ℕ → U → Finset U := fun k x => Finset.univ.filter (fun y => R k x y) with hcls
  have hmem : ∀ k x y, y ∈ cls k x ↔ R k x y := by intro k x y; simp [hcls]
  have hcls_eq : ∀ k x y, cls k x = cls k y ↔ R k x y := by
    intro k x y
    constructor
    · intro hxy
      have : y ∈ cls k x := by rw [hxy]; exact (hmem k y y).mpr (hrefl k y)
      exact (hmem k x y).mp this
    · intro hxy
      ext z
      rw [hmem, hmem]
      exact ⟨fun hz => htrans k y x z (hsymm k x y hxy) hz, fun hz => htrans k x y z hxy hz⟩
  set G : ℕ → Finset U → Finset U :=
    fun k C => Finset.univ.filter (fun z => ∃ y ∈ C, R k z y) with hG
  have hG_cls : ∀ k x, G k (cls (k + 1) x) = cls k x := by
    intro k x
    ext z
    simp only [hG, Finset.mem_filter, Finset.mem_univ, true_and]
    rw [hmem]
    constructor
    · rintro ⟨y, hy, hzy⟩
      have hxy : R k x y := hmono k x y ((hmem (k + 1) x y).mp hy)
      exact htrans k x y z hxy (hsymm k z y hzy)
    · intro hxz
      exact ⟨x, (hmem (k + 1) x x).mpr (hrefl (k + 1) x), hsymm k x z hxz⟩
  set img : ℕ → Finset (Finset U) := fun k => Finset.univ.image (cls k) with himg
  set b : ℕ → ℕ := fun k => (img k).card with hb
  have himg_step : ∀ k, img k = (img (k + 1)).image (G k) := by
    intro k
    simp only [himg, Finset.image_image]
    refine Finset.image_congr ?_
    intro x _
    simp only [Function.comp_apply]
    exact (hG_cls k x).symm
  have hmem_img : ∀ (k : ℕ) (x : U), cls k x ∈ img k := by
    intro k x
    simp only [himg]
    exact Finset.mem_image_of_mem _ (Finset.mem_univ _)
  have hstrict : ∀ k, (¬ ∀ x y, R k x y → R (k + 1) x y) → b k < b (k + 1) := by
    intro k hk
    push_neg at hk
    obtain ⟨x, y, hxy, hnxy⟩ := hk
    have hne : cls (k + 1) x ≠ cls (k + 1) y := fun hc => hnxy ((hcls_eq (k + 1) x y).mp hc)
    have hGeq : G k (cls (k + 1) x) = G k (cls (k + 1) y) := by
      rw [hG_cls, hG_cls]
      exact (hcls_eq k x y).mpr hxy
    have hnotinj : ¬ Set.InjOn (G k) (img (k + 1) : Finset (Finset U)) := by
      intro hinj
      exact hne (hinj (Finset.mem_coe.mpr (hmem_img (k + 1) x))
        (Finset.mem_coe.mpr (hmem_img (k + 1) y)) hGeq)
    have hlt : ((img (k + 1)).image (G k)).card < (img (k + 1)).card := by
      rcases lt_or_eq_of_le (Finset.card_image_le (s := img (k + 1)) (f := G k)) with h | h
      · exact h
      · exact absurd (Finset.card_image_iff.mp h) hnotinj
    simp only [hb]
    rw [himg_step k]
    exact hlt
  have hb_le : ∀ k, b k ≤ N := by
    intro k
    have hle : b k ≤ (Finset.univ : Finset U).card := by
      simp only [hb, himg]
      exact Finset.card_image_le
    rw [Finset.card_univ] at hle
    exact hle
  -- the chain starts with at least two blocks
  obtain ⟨x0, y0, h0⟩ := hstart
  have hb0 : 2 ≤ b 0 := by
    have hne : cls 0 x0 ≠ cls 0 y0 := fun hc => h0 ((hcls_eq 0 x0 y0).mp hc)
    simp only [hb]
    exact Finset.one_lt_card.mpr
      ⟨cls 0 x0, hmem_img 0 x0, cls 0 y0, hmem_img 0 y0, hne⟩
  have hN2 : 2 ≤ N := le_trans hb0 (hb_le 0)
  by_contra hc
  push_neg at hc
  have hgrow : ∀ k ≤ N - 1, 2 + k ≤ b k := by
    intro k
    induction k with
    | zero => intro _; simpa using hb0
    | succ k ih =>
        intro hk
        have hk' : k ≤ N - 1 := by omega
        have hkle : k ≤ N - 2 := by omega
        have hns : ¬ ∀ x y, R k x y → R (k + 1) x y := by
          obtain ⟨x1, y1, h1, h2⟩ := hc k hkle
          intro hall
          exact h2 (hall x1 y1 h1)
        have := hstrict k hns
        have := ih hk'
        omega
  have h1 := hgrow (N - 1) le_rfl
  have h2 := hb_le (N - 1)
  omega

namespace Machine

variable {A : Type u} {O : Type v} {U : Type w} {S : Type w} {T : Type x}

/-! ### Bounded agreement is an equivalence relation on a single machine -/

variable {M : Machine A O U}

theorem agreeUpTo_refl (k : ℕ) (x : U) : AgreeUpTo M M k x x := fun _ _ => rfl

theorem agreeUpTo_symm (k : ℕ) (x y : U) (h : AgreeUpTo M M k x y) : AgreeUpTo M M k y x :=
  fun w hw => (h w hw).symm

theorem agreeUpTo_trans (k : ℕ) (x y z : U) (hxy : AgreeUpTo M M k x y)
    (hyz : AgreeUpTo M M k y z) : AgreeUpTo M M k x z :=
  fun w hw => (hxy w hw).trans (hyz w hw)

theorem agreeUpTo_mono {k l : ℕ} (hkl : k ≤ l) {x : U} {y : U}
    (h : AgreeUpTo M M l x y) : AgreeUpTo M M k x y :=
  fun w hw => h w (hw.trans hkl)

/-! ### The single-machine Moore bound -/

/-- **Moore bound, one machine.**  Two inequivalent states of a machine with `|U|` states
are separated by an experiment of length at most `|U| - 2`. -/
theorem exists_distinguishing_word_le_card_sub_two [Fintype U] (M : Machine A O U) (x y : U)
    (h : ¬ Equivalent M M x y) :
    ∃ w : List A, w.length ≤ Fintype.card U - 2 ∧ M.obs x w ≠ M.obs y w := by
  classical
  have hstart : ∃ x0 y0 : U, ¬ AgreeUpTo M M 0 x0 y0 := by
    by_contra hcon
    push_neg at hcon
    refine absurd (fun w => obs_eq_of_out_eq (M := M) (N := M) ?_ w x y) h
    intro s t
    have := hcon s t
    simpa using this [] (le_refl 0)
  obtain ⟨k, hk, hstable⟩ :=
    exists_stable_index (U := U) (fun k x y => AgreeUpTo M M k x y)
      (fun k x => agreeUpTo_refl k x) (fun k x y h => agreeUpTo_symm k x y h)
      (fun k x y z h1 h2 => agreeUpTo_trans k x y z h1 h2)
      (fun k x y h => agreeUpTo_mono (Nat.le_succ k) h) hstart
  -- translate stability into the `DistBy` language and collapse the witness
  have hstable' : ∀ (x' y' : U), DistBy M M (k + 1) x' y' → DistBy M M k x' y' := by
    intro x' y' hd
    by_contra hcon
    rw [not_distBy_iff_agreeUpTo] at hcon
    exact (not_distBy_iff_agreeUpTo (k + 1) x' y').mpr (hstable x' y' hcon) hd
  have hex : ∃ w : List A, M.obs x w ≠ M.obs y w := by
    by_contra hcon
    push_neg at hcon
    exact h hcon
  obtain ⟨w, hw⟩ := hex
  have hlong : DistBy M M (k + w.length) x y :=
    distBy_mono (Nat.le_add_left _ _) ⟨w, le_rfl, hw⟩
  obtain ⟨v, hv, hvne⟩ := distBy_of_stable hstable' w.length x y hlong
  exact ⟨v, hv.trans hk, hvne⟩

/-! ### The disjoint union of two machines -/

/-- The disjoint union of two machines over the same alphabet and observation type. -/
def sumMachine (M : Machine A O S) (N : Machine A O T) : Machine A O (S ⊕ T) where
  step x a := Sum.elim (fun s => Sum.inl (M.step s a)) (fun t => Sum.inr (N.step t a)) x
  out x := Sum.elim M.out N.out x

@[simp] theorem sumMachine_obs_inl (M : Machine A O S) (N : Machine A O T) (s : S)
    (w : List A) : (sumMachine M N).obs (Sum.inl s) w = M.obs s w := by
  induction w generalizing s with
  | nil => rfl
  | cons a v ih =>
      have hstep : (sumMachine M N).step (Sum.inl s) a = Sum.inl (M.step s a) := rfl
      rw [obs_cons, obs_cons, hstep, ih]

@[simp] theorem sumMachine_obs_inr (M : Machine A O S) (N : Machine A O T) (t : T)
    (w : List A) : (sumMachine M N).obs (Sum.inr t) w = N.obs t w := by
  induction w generalizing t with
  | nil => rfl
  | cons a v ih =>
      have hstep : (sumMachine M N).step (Sum.inr t) a = Sum.inr (N.step t a) := rfl
      rw [obs_cons, obs_cons, hstep, ih]

/-- **Moore bound, two machines.**  Inequivalent initial states of Moore machines with
state sets `S` and `T` are separated by an experiment of length at most
`|S| + |T| - 2`. -/
theorem exists_distinguishing_word_moore [Fintype S] [Fintype T] (M : Machine A O S)
    (N : Machine A O T) (s : S) (t : T) (h : ¬ Equivalent M N s t) :
    ∃ w : List A, w.length ≤ Fintype.card S + Fintype.card T - 2 ∧ M.obs s w ≠ N.obs t w := by
  have hne : ¬ Equivalent (sumMachine M N) (sumMachine M N) (Sum.inl s) (Sum.inr t) := by
    intro hEq
    exact h fun w => by
      have := hEq w
      rwa [sumMachine_obs_inl, sumMachine_obs_inr] at this
  obtain ⟨w, hlen, hw⟩ :=
    exists_distinguishing_word_le_card_sub_two (sumMachine M N) (Sum.inl s) (Sum.inr t) hne
  refine ⟨w, ?_, ?_⟩
  · rwa [Fintype.card_sum] at hlen
  · rwa [sumMachine_obs_inl, sumMachine_obs_inr] at hw

/-! ### The linear bound subsumes the quadratic one -/

/-- Arithmetic comparison: for nonempty state sets the Moore bound is strictly inside the
product bound. -/
theorem moore_bound_le_product_bound {n m : ℕ} (hn : 1 ≤ n) (hm : 1 ≤ m) :
    n + m - 2 < n * m := by
  rcases Nat.lt_or_ge n 2 with hn2 | hn2
  · have : n = 1 := by omega
    subst this
    omega
  · rcases Nat.lt_or_ge m 2 with hm2 | hm2
    · have : m = 1 := by omega
      subst this
      omega
    · have h2 : n + m ≤ n * m := by
        have h := Nat.mul_le_mul hn2 (le_refl m)
        nlinarith
      omega

/-- The product bound of `exists_short_distinguishing_word` re-derived from the Moore
bound: the linear estimate is at least as strong. -/
theorem exists_short_distinguishing_word_of_moore [Fintype S] [Fintype T] [Nonempty S]
    [Nonempty T] (M : Machine A O S) (N : Machine A O T) (s : S) (t : T)
    (h : ¬ Equivalent M N s t) :
    ∃ w : List A, w.length < Fintype.card S * Fintype.card T ∧ M.obs s w ≠ N.obs t w := by
  obtain ⟨w, hlen, hw⟩ := exists_distinguishing_word_moore M N s t h
  exact ⟨w, lt_of_le_of_lt hlen
    (moore_bound_le_product_bound Fintype.card_pos Fintype.card_pos), hw⟩

end Machine

end Pythagorean.DistinguishingWord