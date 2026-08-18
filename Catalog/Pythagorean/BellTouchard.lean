import Pythagorean.KernelPatternsBell

/-!
# Touchard's congruence for the Bell numbers

`Pythagorean.BellPrimeCongruence` proves `Nat.bell p ≡ 2 [MOD p]` for a prime `p` by letting
the cyclic group act on the equivalence relations of `ZMod p`.  Here we run the same machine
over the *extended* index set `ZMod p ⊕ Fin n`, where the cyclic group only rotates the left
summand, and obtain **Touchard's congruence**

`Nat.bell (p + n) ≡ Nat.bell (n + 1) + Nat.bell n [MOD p]`.

The mathematical content is the classification of the invariant equivalence relations
(`KernelPattern.fixedEquiv`): if the block of `inl 0` is not a singleton then, by translating
and chaining, the whole of `ZMod p` collapses into one block, and what is left is an
equivalence relation on `Fin n` together with that one extra block — that is, an equivalence
relation on `Option (Fin n)`, of which there are `bell (n+1)`.  Otherwise every point of
`ZMod p` is a singleton block and only the `bell n` relations on `Fin n` remain.

Setting `n = 0` recovers `bell p ≡ 2 [MOD p]`.
-/

open Finset MulAction

namespace KernelPattern

/-- Equivalence relations on `ι`, as a type. -/
abbrev KRel (ι : Type*) := {r : ι → ι → Bool // IsKerRel r}

/-- There are `bell (card ι)` equivalence relations on `ι`. -/
theorem nat_card_KRel (ι : Type*) [Fintype ι] [DecidableEq ι] :
    Nat.card (KRel ι) = Nat.bell (Fintype.card ι) := by
  rw [Nat.card_eq_fintype_card]
  have h1 : Fintype.card (KRel ι) = kerCount ι := by
    rw [kerCount, KerRels]
    exact Fintype.card_subtype _
  rw [h1, kerCount_eq_bell]

section Touchard

variable (p n : ℕ) [Fact p.Prime]

/-- The extended index set: a cyclic part of prime size and `n` further points. -/
abbrev Idx (p n : ℕ) := ZMod p ⊕ Fin n

/-- Translation of the cyclic part. -/
def sh (a : ZMod p) : Idx p n → Idx p n :=
  Sum.elim (fun i => Sum.inl (i + a)) Sum.inr

variable {p n}

omit [Fact (Nat.Prime p)] in
@[simp] theorem sh_inl (a i : ZMod p) : sh p n a (Sum.inl i) = Sum.inl (i + a) := rfl

omit [Fact (Nat.Prime p)] in
@[simp] theorem sh_inr (a : ZMod p) (x : Fin n) : sh p n a (Sum.inr x) = Sum.inr x := rfl

theorem sh_injective (a : ZMod p) : Function.Injective (sh p n a) := by
  rintro (i | x) (j | y) h <;> simp only [sh_inl, sh_inr] at h
  · exact congrArg Sum.inl (by simpa using h)
  · exact absurd h (by simp)
  · exact absurd h (by simp)
  · exact h

variable (p n)

/-- The cyclic group acts on the equivalence relations of `Idx p n` by rotating the cyclic
part of the index set. -/
instance touchardSMul : SMul (Multiplicative (ZMod p)) (KRel (Idx p n)) where
  smul g r :=
    ⟨fun x y => r.1 (sh p n (Multiplicative.toAdd g) x) (sh p n (Multiplicative.toAdd g) y), by
      obtain ⟨hrefl, hsymm, htrans⟩ := r.2
      exact ⟨fun a => hrefl _, fun a b h => hsymm _ _ h, fun a b c h₁ h₂ => htrans _ _ _ h₁ h₂⟩⟩

variable {p n}

omit [Fact (Nat.Prime p)] in
theorem touchard_smul_apply (g : Multiplicative (ZMod p)) (r : KRel (Idx p n))
    (x y : Idx p n) :
    (g • r).1 x y
      = r.1 (sh p n (Multiplicative.toAdd g) x) (sh p n (Multiplicative.toAdd g) y) := rfl

variable (p n)

instance touchardAction : MulAction (Multiplicative (ZMod p)) (KRel (Idx p n)) where
  one_smul r := by
    apply Subtype.ext
    funext x y
    rw [touchard_smul_apply]
    have h : ∀ z : Idx p n, sh p n (Multiplicative.toAdd (1 : Multiplicative (ZMod p))) z = z := by
      rintro (i | u) <;> simp
    rw [h, h]
  mul_smul g h r := by
    apply Subtype.ext
    funext x y
    rw [touchard_smul_apply, touchard_smul_apply, touchard_smul_apply]
    have key : ∀ z : Idx p n, sh p n (Multiplicative.toAdd (g * h)) z
        = sh p n (Multiplicative.toAdd h) (sh p n (Multiplicative.toAdd g) z) := by
      rintro (i | u)
      · show Sum.inl (i + (Multiplicative.toAdd g + Multiplicative.toAdd h))
          = Sum.inl (i + Multiplicative.toAdd g + Multiplicative.toAdd h)
        rw [add_assoc]
      · rfl
    rw [key, key]

variable {p n}

theorem touchard_invariant {r : KRel (Idx p n)}
    (hr : r ∈ fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n))) (a : ZMod p)
    (x y : Idx p n) : r.1 (sh p n a x) (sh p n a y) = r.1 x y := by
  have h := hr (Multiplicative.ofAdd a)
  have := congrArg (fun s : KRel (Idx p n) => s.1 x y) h
  simpa [touchard_smul_apply] using this

/-! ## The two shapes of an invariant relation -/

/-- The block of `inl 0` is not a singleton. -/
def Merged (r : Idx p n → Idx p n → Bool) : Prop :=
  ∃ y : Idx p n, y ≠ Sum.inl 0 ∧ r (Sum.inl 0) y = true

instance : DecidablePred (Merged (p := p) (n := n)) := fun _ => by
  unfold Merged; infer_instance

/-- If the block of `inl 0` is not a singleton, then the whole cyclic part collapses into a
single block: this is where primality enters. -/
theorem all_left_of_merged {r : KRel (Idx p n)}
    (hr : r ∈ fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n)))
    (hm : Merged r.1) (a b : ZMod p) : r.1 (Sum.inl a) (Sum.inl b) = true := by
  obtain ⟨hrefl, hsymm, htrans⟩ := r.2
  obtain ⟨y, hy, hry⟩ := hm
  rcases y with j | x
  · -- related to another point of the cyclic part: chain along the subgroup generated by `j`
    have hj : j ≠ 0 := by
      rintro rfl
      exact hy rfl
    have step : ∀ c : ZMod p, r.1 (Sum.inl c) (Sum.inl (c + j)) = true := by
      intro c
      have h := touchard_invariant hr c (Sum.inl 0) (Sum.inl j)
      simp only [sh_inl, zero_add] at h
      rw [add_comm j c] at h
      rw [h]
      exact hry
    have chain : ∀ k : ℕ, ∀ c : ZMod p, r.1 (Sum.inl c) (Sum.inl (c + k * j)) = true := by
      intro k
      induction k with
      | zero => intro c; simpa using hrefl (Sum.inl c)
      | succ m ih =>
          intro c
          have h1 := ih c
          have h2 := step (c + m * j)
          have h3 : c + (m : ZMod p) * j + j = c + ((m : ℕ) + 1 : ℕ) * j := by push_cast; ring
          rw [h3] at h2
          exact htrans _ _ _ h1 h2
    obtain ⟨k, hk⟩ : ∃ k : ℕ, (k : ZMod p) * j = b - a := by
      refine ⟨((b - a) * j⁻¹).val, ?_⟩
      rw [ZMod.natCast_val, ZMod.cast_id]
      field_simp
    have := chain k a
    rw [hk] at this
    simpa using this
  · -- related to a point outside the cyclic part: every translate is too
    have hall : ∀ c : ZMod p, r.1 (Sum.inl c) (Sum.inr x) = true := by
      intro c
      have h := touchard_invariant hr c (Sum.inl 0) (Sum.inr x)
      simp only [sh_inl, sh_inr, zero_add] at h
      rw [h]
      exact hry
    exact htrans _ _ _ (hall a) (hsymm _ _ (hall b))

/-- If the block of `inl 0` is a singleton, then every point of the cyclic part is a
singleton block. -/
theorem singleton_of_not_merged {r : KRel (Idx p n)}
    (hr : r ∈ fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n)))
    (hm : ¬ Merged r.1) (i : ZMod p) (y : Idx p n) (hy : y ≠ Sum.inl i) :
    r.1 (Sum.inl i) y = false := by
  by_contra hcon
  rw [Bool.not_eq_false] at hcon
  refine hm ⟨sh p n (-i) y, ?_, ?_⟩
  · intro h
    have h0 : sh p n (-i) (Sum.inl i) = Sum.inl 0 := by simp
    exact hy (sh_injective (-i) (h.trans h0.symm))
  · have h := touchard_invariant hr (-i) (Sum.inl i) y
    rw [sh_inl, add_neg_cancel] at h
    rw [h]
    exact hcon

/-! ## Encoding the invariant relations -/

/-- The relation induced on `Option (Fin n)`, where `none` stands for the collapsed cyclic
part. -/
def quotRel (r : Idx p n → Idx p n → Bool) : Option (Fin n) → Option (Fin n) → Bool
  | none, none => true
  | none, some x => r (Sum.inl 0) (Sum.inr x)
  | some x, none => r (Sum.inr x) (Sum.inl 0)
  | some x, some y => r (Sum.inr x) (Sum.inr y)

/-- The relation induced on `Fin n` by restriction. -/
def restRel (r : Idx p n → Idx p n → Bool) : Fin n → Fin n → Bool :=
  fun x y => r (Sum.inr x) (Sum.inr y)

/-- Rebuilding a relation on `Idx p n` from one on `Option (Fin n)`: the cyclic part becomes
one block, glued to the block of `none`. -/
def mergeRel (s : Option (Fin n) → Option (Fin n) → Bool) : Idx p n → Idx p n → Bool
  | Sum.inl _, Sum.inl _ => true
  | Sum.inl _, Sum.inr x => s none (some x)
  | Sum.inr x, Sum.inl _ => s (some x) none
  | Sum.inr x, Sum.inr y => s (some x) (some y)

/-- Rebuilding a relation on `Idx p n` from one on `Fin n`: the cyclic part becomes
singletons. -/
def splitRel (s : Fin n → Fin n → Bool) : Idx p n → Idx p n → Bool
  | Sum.inl i, Sum.inl j => decide (i = j)
  | Sum.inl _, Sum.inr _ => false
  | Sum.inr _, Sum.inl _ => false
  | Sum.inr x, Sum.inr y => s x y

omit [Fact (Nat.Prime p)] in
theorem isKerRel_quotRel {r : Idx p n → Idx p n → Bool} (hr : IsKerRel r) :
    IsKerRel (quotRel r) := by
  obtain ⟨hrefl, hsymm, htrans⟩ := hr
  refine ⟨?_, ?_, ?_⟩
  · rintro (_ | x)
    · rfl
    · exact hrefl _
  · rintro (_ | x) (_ | y) h
    · rfl
    · exact hsymm _ _ h
    · exact hsymm _ _ h
    · exact hsymm _ _ h
  · rintro (_ | x) (_ | y) (_ | z) h₁ h₂ <;> first
      | rfl
      | exact h₁
      | exact h₂
      | exact htrans _ _ _ h₁ h₂

omit [Fact (Nat.Prime p)] in
theorem isKerRel_restRel {r : Idx p n → Idx p n → Bool} (hr : IsKerRel r) :
    IsKerRel (restRel r) :=
  ⟨fun _ => hr.1 _, fun _ _ h => hr.2.1 _ _ h, fun _ _ _ h₁ h₂ => hr.2.2 _ _ _ h₁ h₂⟩

omit [Fact (Nat.Prime p)] in
theorem isKerRel_mergeRel {s : Option (Fin n) → Option (Fin n) → Bool} (hs : IsKerRel s) :
    IsKerRel (mergeRel (p := p) s) := by
  obtain ⟨hrefl, hsymm, htrans⟩ := hs
  refine ⟨?_, ?_, ?_⟩
  · rintro (i | x)
    · rfl
    · exact hrefl _
  · rintro (i | x) (j | y) h
    · rfl
    · exact hsymm _ _ h
    · exact hsymm _ _ h
    · exact hsymm _ _ h
  · rintro (i | x) (j | y) (k | z) h₁ h₂ <;> first
      | rfl
      | exact h₁
      | exact h₂
      | exact htrans _ _ _ h₁ h₂

omit [Fact (Nat.Prime p)] in
theorem isKerRel_splitRel {s : Fin n → Fin n → Bool} (hs : IsKerRel s) :
    IsKerRel (splitRel (p := p) s) := by
  obtain ⟨hrefl, hsymm, htrans⟩ := hs
  refine ⟨?_, ?_, ?_⟩
  · rintro (i | x)
    · simp [splitRel]
    · exact hrefl _
  · rintro (i | x) (j | y) h <;> simp only [splitRel] at h ⊢
    · simpa using (by simpa using h : i = j).symm
    · exact h
    · exact h
    · exact hsymm _ _ h
  · rintro (i | x) (j | y) (k | z) h₁ h₂ <;> simp only [splitRel] at h₁ h₂ ⊢ <;>
      first
        | exact (Bool.false_ne_true h₁).elim
        | exact (Bool.false_ne_true h₂).elim
        | (have e₁ : i = j := by simpa using h₁
           have e₂ : j = k := by simpa using h₂
           simp [e₁, e₂])
        | exact htrans _ _ _ h₁ h₂

theorem merged_mergeRel (s : Option (Fin n) → Option (Fin n) → Bool) :
    Merged (mergeRel (p := p) s) := by
  haveI : Fact (1 < p) := ⟨(Fact.out (p := p.Prime)).one_lt⟩
  exact ⟨Sum.inl 1, by simp [Sum.inl.injEq], rfl⟩

omit [Fact (Nat.Prime p)] in
theorem not_merged_splitRel (s : Fin n → Fin n → Bool) :
    ¬ Merged (splitRel (p := p) s) := by
  rintro ⟨y, hy, hry⟩
  rcases y with j | x
  · simp only [splitRel, decide_eq_true_eq] at hry
    exact hy (by rw [hry])
  · exact absurd hry (by simp [splitRel])

theorem mergeRel_mem_fixedPoints (s : KRel (Option (Fin n))) :
    (⟨mergeRel (p := p) s.1, isKerRel_mergeRel s.2⟩ : KRel (Idx p n))
      ∈ fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n)) := by
  intro g
  apply Subtype.ext
  funext x y
  rw [touchard_smul_apply]
  rcases x with i | u <;> rcases y with j | v <;> rfl

theorem splitRel_shift (s : Fin n → Fin n → Bool) (a : ZMod p) (x y : Idx p n) :
    splitRel (p := p) s (sh p n a x) (sh p n a y) = splitRel (p := p) s x y := by
  rcases x with i | u <;> rcases y with j | v <;> simp [splitRel]

theorem splitRel_mem_fixedPoints (s : KRel (Fin n)) :
    (⟨splitRel (p := p) s.1, isKerRel_splitRel s.2⟩ : KRel (Idx p n))
      ∈ fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n)) := by
  intro g
  apply Subtype.ext
  funext x y
  rw [touchard_smul_apply]
  exact splitRel_shift s.1 _ x y

/-! ## The bijection between fixed points and the two families -/

/-- **Classification of the invariant equivalence relations.** -/
def fixedEquiv :
    fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n))
      ≃ (KRel (Option (Fin n)) ⊕ KRel (Fin n)) where
  toFun r :=
    if _ : Merged r.1.1 then
      Sum.inl ⟨quotRel r.1.1, isKerRel_quotRel r.1.2⟩
    else
      Sum.inr ⟨restRel r.1.1, isKerRel_restRel r.1.2⟩
  invFun s :=
    match s with
    | Sum.inl s => ⟨⟨mergeRel s.1, isKerRel_mergeRel s.2⟩, mergeRel_mem_fixedPoints s⟩
    | Sum.inr s => ⟨⟨splitRel s.1, isKerRel_splitRel s.2⟩, splitRel_mem_fixedPoints s⟩
  left_inv := by
    rintro ⟨r, hr⟩
    by_cases hm : Merged r.1
    · simp only [dif_pos hm]
      apply Subtype.ext
      apply Subtype.ext
      funext x y
      rcases x with i | u <;> rcases y with j | v
      · show true = r.1 (Sum.inl i) (Sum.inl j)
        exact (all_left_of_merged hr hm i j).symm
      · show r.1 (Sum.inl 0) (Sum.inr v) = r.1 (Sum.inl i) (Sum.inr v)
        have h := touchard_invariant hr i (Sum.inl 0) (Sum.inr v)
        simp only [sh_inl, sh_inr, zero_add] at h
        exact h.symm
      · show r.1 (Sum.inr u) (Sum.inl 0) = r.1 (Sum.inr u) (Sum.inl j)
        have h := touchard_invariant hr j (Sum.inr u) (Sum.inl 0)
        simp only [sh_inl, sh_inr, zero_add] at h
        exact h.symm
      · rfl
    · simp only [dif_neg hm]
      apply Subtype.ext
      apply Subtype.ext
      funext x y
      rcases x with i | u <;> rcases y with j | v
      · show (decide (i = j) : Bool) = r.1 (Sum.inl i) (Sum.inl j)
        by_cases hij : i = j
        · subst hij
          simpa using (r.2.1 (Sum.inl i)).symm
        · rw [singleton_of_not_merged hr hm i (Sum.inl j) (by simpa using Ne.symm hij)]
          simp [hij]
      · show (false : Bool) = r.1 (Sum.inl i) (Sum.inr v)
        rw [singleton_of_not_merged hr hm i (Sum.inr v) (by simp)]
      · show (false : Bool) = r.1 (Sum.inr u) (Sum.inl j)
        have h0 : r.1 (Sum.inl j) (Sum.inr u) = false :=
          singleton_of_not_merged hr hm j (Sum.inr u) (by simp)
        cases hb : r.1 (Sum.inr u) (Sum.inl j) with
        | false => rfl
        | true =>
            have hsym := r.2.2.1 _ _ hb
            rw [h0] at hsym
            exact absurd hsym (by simp)
      · rfl
  right_inv := by
    rintro (s | s)
    · simp only [dif_pos (merged_mergeRel (p := p) s.1)]
      apply congrArg Sum.inl
      apply Subtype.ext
      funext x y
      rcases x with _ | u <;> rcases y with _ | v
      · exact (s.2.1 none).symm
      · rfl
      · rfl
      · rfl
    · simp only [dif_neg (not_merged_splitRel (p := p) s.1)]
      apply congrArg Sum.inr
      apply Subtype.ext
      funext x y
      rfl

theorem card_fixedPoints_touchard :
    Nat.card (fixedPoints (Multiplicative (ZMod p)) (KRel (Idx p n)))
      = Nat.bell (n + 1) + Nat.bell n := by
  rw [Nat.card_congr (fixedEquiv (p := p) (n := n)), Nat.card_sum, nat_card_KRel,
    nat_card_KRel, Fintype.card_option, Fintype.card_fin]

/-- **Touchard's congruence.**  For every prime `p` and every `n`,
`bell (p + n) ≡ bell (n + 1) + bell n [MOD p]`. -/
theorem bell_touchard : Nat.bell (p + n) ≡ Nat.bell (n + 1) + Nat.bell n [MOD p] := by
  haveI : NeZero p := ⟨(Fact.out (p := p.Prime)).ne_zero⟩
  have hG : IsPGroup p (Multiplicative (ZMod p)) := by
    refine IsPGroup.of_card (n := 1) ?_
    rw [pow_one, Nat.card_eq_fintype_card, Fintype.card_congr (Multiplicative.toAdd)]
    exact ZMod.card p
  have h := hG.card_modEq_card_fixedPoints (KRel (Idx p n))
  rw [card_fixedPoints_touchard, nat_card_KRel, Fintype.card_sum, ZMod.card,
    Fintype.card_fin] at h
  exact h

end Touchard

/-- Setting `n = 0` in Touchard's congruence recovers `bell p ≡ 2 [MOD p]`. -/
theorem bell_prime_modEq' (p : ℕ) [Fact p.Prime] : Nat.bell p ≡ 2 [MOD p] := by
  have h := bell_touchard (p := p) (n := 0)
  rw [Nat.add_zero, zero_add, bell_zero', bell_one'] at h
  exact h

/-- A numerical consequence of Touchard's congruence: `5 ∣ Nat.bell 8` (consistent with the
independently proved value `Nat.bell 8 = 4140 = 5 * 828` in
`Pythagorean.KernelStirlingClosedForms`). -/
theorem five_dvd_bell_eight : 5 ∣ Nat.bell 8 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h := bell_touchard (p := 5) (n := 3)
  norm_num [bell_four', bell_three'] at h
  exact (Nat.modEq_zero_iff_dvd).mp h

end KernelPattern