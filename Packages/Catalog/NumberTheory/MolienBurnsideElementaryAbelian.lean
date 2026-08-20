import Mathlib
import Catalog.NumberTheory.MolienBurnsideD10

/-!
# D10 fails for every elementary abelian group of rank two

The companion file `Catalog.NumberTheory.MolienBurnsideD10` refutes Conjecture D10 with a
`decide`-checked example over the Klein four group.  Here we upgrade that single example to
an **infinite family**, one for each prime `p`, with a genuine (non-`decide`) proof:

for `E = (ℤ/p)²` put

* `Xlines p = ⊔_{ℓ ∈ ℙ¹(𝔽_p)} E/ℓ`, the disjoint union of the `p+1` transitive `E`-sets of
  size `p` (indexed by the `p+1` lines through the origin, i.e. by the projective line),
* `Xreg p  = E ⊔ (p fixed points)`.

Both have `p(p+1) = p² + p` elements.  We show they have the *same permutation character*
(hence the same Molien invariant at every subgroup), while their Burnside marks at `⊤` are
`0` and `p` respectively; so no scaling relates the two mark vectors.

The heart of the computation is the projective-line count `card_vanishing_lines`: a nonzero
vector of `𝔽_p²` lies on exactly one of the `p+1` lines — an input from the theory of finite
fields (uniqueness of `-a/b`), which is what makes the character values agree.
-/

namespace D10

open Finset

section ElementaryAbelian

variable (p : ℕ) [Fact p.Prime]

/-- The elementary abelian group `(ℤ/p)²`, written multiplicatively. -/
abbrev EA (p : ℕ) := Multiplicative (ZMod p × ZMod p)

/-- The `p+1` characters of `(ℤ/p)²` with distinct kernels, indexed by the projective line
`ℙ¹(𝔽_p) = 𝔽_p ∪ {∞}`. -/
def eaChar (i : Option (ZMod p)) (v : ZMod p × ZMod p) : ZMod p :=
  match i with
  | some c => v.1 + c * v.2
  | none => v.2

@[simp] theorem eaChar_zero (i : Option (ZMod p)) : eaChar p i 0 = 0 := by
  cases i <;> simp [eaChar]

theorem eaChar_add (i : Option (ZMod p)) (u v : ZMod p × ZMod p) :
    eaChar p i (u + v) = eaChar p i u + eaChar p i v := by
  cases i with
  | none => simp [eaChar]
  | some c =>
      simp only [eaChar, Prod.fst_add, Prod.snd_add]
      ring

/-- A nonzero vector of `𝔽_p²` is killed by exactly one of the `p+1` characters:
it lies on exactly one line through the origin. -/
theorem card_vanishing_lines (v : ZMod p × ZMod p) (hv : v ≠ 0) :
    (univ.filter fun i : Option (ZMod p) => eaChar p i v = 0).card = 1 := by
  classical
  rcases eq_or_ne v.2 0 with h2 | h2
  · have h1 : v.1 ≠ 0 := by
      intro h1
      exact hv (Prod.ext h1 h2)
    refine Finset.card_eq_one.mpr ⟨none, ?_⟩
    ext i
    cases i with
    | none => simp [eaChar, h2]
    | some c => simp [eaChar, h2, h1]
  · refine Finset.card_eq_one.mpr ⟨some (-(v.1 / v.2)), ?_⟩
    ext i
    cases i with
    | none => simp [eaChar, h2]
    | some c =>
        simp only [mem_filter, mem_univ, true_and, eaChar, mem_singleton, Option.some.injEq]
        constructor
        · intro hc
          field_simp
          linear_combination hc
        · intro hc
          subst hc
          field_simp
          ring

/-- The `E`-set `⊔_{ℓ} E/ℓ`: for each of the `p+1` lines a copy of `ℤ/p`, acted on through
the corresponding character. -/
abbrev Xlines (p : ℕ) := ZMod p × Option (ZMod p)

/-- The `E`-set `E ⊔ (p fixed points)`. -/
abbrev XregEA (p : ℕ) := (ZMod p × ZMod p) ⊕ ZMod p

instance : SMul (EA p) (Xlines p) :=
  ⟨fun g x => (x.1 + eaChar p x.2 (Multiplicative.toAdd g), x.2)⟩

omit [Fact p.Prime] in
theorem smul_Xlines (g : EA p) (x : Xlines p) :
    g • x = (x.1 + eaChar p x.2 (Multiplicative.toAdd g), x.2) := rfl

instance : MulAction (EA p) (Xlines p) where
  one_smul x := by
    rw [smul_Xlines]
    simp
  mul_smul g h x := by
    simp only [smul_Xlines]
    have : Multiplicative.toAdd (g * h)
        = Multiplicative.toAdd g + Multiplicative.toAdd h := rfl
    rw [this, eaChar_add]
    simp only [Prod.mk.injEq]
    exact ⟨by ring, trivial⟩

instance : SMul (EA p) (XregEA p) :=
  ⟨fun g x => match x with
    | .inl q => .inl (q + Multiplicative.toAdd g)
    | .inr c => .inr c⟩

omit [Fact p.Prime] in
theorem smul_XregEA_inl (g : EA p) (q : ZMod p × ZMod p) :
    g • (Sum.inl q : XregEA p) = Sum.inl (q + Multiplicative.toAdd g) := rfl

omit [Fact p.Prime] in
theorem smul_XregEA_inr (g : EA p) (c : ZMod p) :
    g • (Sum.inr c : XregEA p) = Sum.inr c := rfl

instance : MulAction (EA p) (XregEA p) where
  one_smul x := by
    cases x with
    | inl q => rw [smul_XregEA_inl]; simp
    | inr c => rw [smul_XregEA_inr]
  mul_smul g h x := by
    cases x with
    | inl q =>
        rw [smul_XregEA_inl, smul_XregEA_inl, smul_XregEA_inl]
        have : Multiplicative.toAdd (g * h)
            = Multiplicative.toAdd g + Multiplicative.toAdd h := rfl
        rw [this]
        congr 1
        abel
    | inr c => rw [smul_XregEA_inr, smul_XregEA_inr, smul_XregEA_inr]

theorem fixCount_Xlines (g : EA p) :
    fixCount (Xlines p) g
      = p * (univ.filter fun i : Option (ZMod p) =>
          eaChar p i (Multiplicative.toAdd g) = 0).card := by
  classical
  rw [fixCount, Finset.card_filter, Fintype.sum_prod_type]
  have hterm : ∀ x : ZMod p, ∀ i : Option (ZMod p),
      (if g • ((x, i) : Xlines p) = (x, i) then 1 else 0)
        = (if eaChar p i (Multiplicative.toAdd g) = 0 then 1 else 0) := by
    intro x i
    congr 1
    rw [smul_Xlines]
    simp [Prod.ext_iff]
  simp only [hterm]
  rw [Finset.sum_const, Finset.card_univ, ZMod.card, smul_eq_mul,
    Finset.card_filter]

theorem fixCount_XregEA (g : EA p) :
    fixCount (XregEA p) g
      = (if Multiplicative.toAdd g = 0 then p * p else 0) + p := by
  classical
  rw [fixCount, Finset.card_filter, Fintype.sum_sum_type]
  have hleft : ∀ q : ZMod p × ZMod p,
      (if g • (Sum.inl q : XregEA p) = Sum.inl q then 1 else 0)
        = (if Multiplicative.toAdd g = 0 then 1 else 0) := by
    intro q
    congr 1
    rw [smul_XregEA_inl]
    simp
  have hright : ∀ c : ZMod p,
      (if g • (Sum.inr c : XregEA p) = Sum.inr c then 1 else 0) = 1 := by
    intro c
    rw [smul_XregEA_inr, if_pos rfl]
  simp only [hleft, hright]
  rw [Finset.sum_const, Finset.sum_const, Finset.card_univ, Finset.card_univ, ZMod.card,
    Fintype.card_prod, ZMod.card, smul_eq_mul, smul_eq_mul, mul_one]
  by_cases hg : Multiplicative.toAdd g = 0 <;> simp [hg]

/-- **The two `E`-sets have the same permutation character.**  At the identity both give
`p(p+1) = p² + p`; at every other element both give `p`. -/
theorem ea_fixCount_eq (g : EA p) : fixCount (Xlines p) g = fixCount (XregEA p) g := by
  classical
  rw [fixCount_Xlines, fixCount_XregEA]
  rcases eq_or_ne (Multiplicative.toAdd g) 0 with h0 | h0
  · rw [if_pos h0, h0]
    have hall : (univ.filter fun i : Option (ZMod p) => eaChar p i 0 = 0) = univ := by
      apply Finset.filter_true_of_mem
      intro i _
      simp
    rw [hall, Finset.card_univ]
    simp [Fintype.card_option, ZMod.card]
    ring
  · rw [if_neg h0, card_vanishing_lines p _ h0]
    ring

/-- Hence the Molien invariants agree at every subgroup of `(ℤ/p)²`. -/
theorem ea_molien_eq (H : Subgroup (EA p)) [Fintype H] :
    molien (Xlines p) H = molien (XregEA p) H :=
  molien_eq_of_fixCount_eq (ea_fixCount_eq p) H

instance decMemTopEA : DecidablePred (· ∈ (⊤ : Subgroup (EA p))) :=
  fun x => isTrue (Subgroup.mem_top x)

/-- No point of `⊔_ℓ E/ℓ` is fixed by all of `E`: the mark at `⊤` vanishes. -/
theorem markOn_Xlines_top : markOn (Xlines p) (⊤ : Subgroup (EA p)) = 0 := by
  classical
  rw [markOn, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  rintro ⟨x, i⟩ _ hfix
  have hone : (1 : ZMod p) ≠ 0 := by
    haveI := Fact.out (p := p.Prime)
    exact one_ne_zero
  cases i with
  | none =>
      have h := hfix ⟨Multiplicative.ofAdd ((0 : ZMod p), (1 : ZMod p)), Subgroup.mem_top _⟩
      rw [smul_Xlines] at h
      simp only [Prod.mk.injEq, eaChar, toAdd_ofAdd] at h
      exact hone (by linear_combination h.1)
  | some c =>
      have h := hfix ⟨Multiplicative.ofAdd ((1 : ZMod p), (0 : ZMod p)), Subgroup.mem_top _⟩
      rw [smul_Xlines] at h
      simp only [Prod.mk.injEq, eaChar, toAdd_ofAdd] at h
      exact hone (by linear_combination h.1)

/-- Exactly the `p` added points of `E ⊔ (p points)` are `E`-fixed. -/
theorem markOn_XregEA_top : markOn (XregEA p) (⊤ : Subgroup (EA p)) = p := by
  classical
  rw [markOn, Finset.card_filter, Fintype.sum_sum_type]
  have hone : (1 : ZMod p) ≠ 0 := by
    haveI := Fact.out (p := p.Prime)
    exact one_ne_zero
  have hleft : ∀ q : ZMod p × ZMod p,
      (if ∀ h : (⊤ : Subgroup (EA p)), (h : EA p) • (Sum.inl q : XregEA p) = Sum.inl q
        then 1 else 0) = 0 := by
    intro q
    rw [if_neg]
    intro hfix
    have h := hfix ⟨Multiplicative.ofAdd ((1 : ZMod p), (0 : ZMod p)), Subgroup.mem_top _⟩
    rw [smul_XregEA_inl] at h
    simp only [Sum.inl.injEq] at h
    have h1 := congrArg Prod.fst h
    simp only [Prod.fst_add, toAdd_ofAdd] at h1
    exact hone (by linear_combination h1)
  have hright : ∀ c : ZMod p,
      (if ∀ h : (⊤ : Subgroup (EA p)), (h : EA p) • (Sum.inr c : XregEA p) = Sum.inr c
        then 1 else 0) = 1 := by
    intro c
    rw [if_pos]
    intro h
    exact smul_XregEA_inr p (h : EA p) c
  simp only [hleft, hright]
  simp [ZMod.card]

/-- **D10 fails for every elementary abelian group of rank two.**  For each prime `p` the
`(ℤ/p)²`-sets `Xlines p` and `XregEA p` have equal Molien invariants at every subgroup, but
their mark vectors are not proportional: the mark at `⊥` forces the scalar to be `1` while
the mark at `⊤` forces it to be `0`. -/
theorem D10_false_elementary_abelian :
    (∀ (H : Subgroup (EA p)) [Fintype H], molien (Xlines p) H = molien (XregEA p) H) ∧
      ¬ ∃ c : ℚ, ∀ (H : Subgroup (EA p)) [Fintype H],
        (markOn (Xlines p) H : ℚ) = c * (markOn (XregEA p) H : ℚ) := by
  classical
  refine ⟨fun H _ => ea_molien_eq p H, ?_⟩
  rintro ⟨c, hc⟩
  have hp0 : (0 : ℚ) < p := by
    haveI := Fact.out (p := p.Prime)
    exact_mod_cast Nat.pos_of_ne_zero (Nat.Prime.ne_zero (Fact.out (p := p.Prime)))
  have hbot := hc ⊥
  rw [markOn_bot, markOn_bot] at hbot
  have hcards : (Fintype.card (Xlines p) : ℚ) = (Fintype.card (XregEA p) : ℚ) := by
    simp [Fintype.card_prod, Fintype.card_option, Fintype.card_sum, ZMod.card]
    ring
  rw [hcards] at hbot
  have hcardpos : (0 : ℚ) < (Fintype.card (XregEA p) : ℚ) := by
    have : Fintype.card (XregEA p) = p * p + p := by
      simp [Fintype.card_sum, Fintype.card_prod, ZMod.card]
    rw [this]
    have : (0 : ℚ) < (p : ℚ) * p + p := by positivity
    exact_mod_cast this
  have hc1 : c = 1 := by
    have hne : (Fintype.card (XregEA p) : ℚ) ≠ 0 := ne_of_gt hcardpos
    have h2 : (1 : ℚ) * (Fintype.card (XregEA p) : ℚ)
        = c * (Fintype.card (XregEA p) : ℚ) := by rw [one_mul]; exact hbot
    exact (mul_right_cancel₀ hne h2).symm
  have htop := hc ⊤
  rw [markOn_Xlines_top, markOn_XregEA_top, hc1, one_mul] at htop
  simp only [Nat.cast_zero] at htop
  exact absurd htop.symm (ne_of_gt hp0)

end ElementaryAbelian

end D10