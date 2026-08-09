/-
# Exact point counting and modular invariants for short Weierstrass curves

For a finite field `F` of odd characteristic and parameters `a b : F` we study the
affine locus of the short Weierstrass equation `y^2 = x^3 + a*x + b` together with
one point at infinity.  Everything is done by *elementary counting*: the basic tool
is the quadratic character `quadraticChar F`, which counts square roots.

Main results:

* `EllipticModCount.card_affineLocus` : the affine point count equals `#F + S(a,b)`
  where `S(a,b) = ∑ x, χ(x^3+a*x+b)`.
* `EllipticModCount.frobTrace_eq_neg_charSum` : the trace of Frobenius is `-S(a,b)`.
* `EllipticModCount.two_dvd_cardPoints_iff` : (**2-torsion criterion**) for a
  nonsingular curve the point count is even iff the cubic has a root in `F`.
* `EllipticModCount.rootSet_card_cases` : for a nonsingular curve the cubic has
  exactly `0`, `1` or `3` roots — never `2`.
* `EllipticModCount.cardPoints_eq_of_cube_bijective` : if cubing is a bijection
  (e.g. `p % 3 = 2`) then `y^2 = x^3 + b` has exactly `#F + 1` points.
* `EllipticModCount.cardPoints_eq_of_neg_one_nonsquare` : if `-1` is a nonsquare
  (e.g. `p % 4 = 3`) then `y^2 = x^3 + a*x` has exactly `#F + 1` points.
* `EllipticModCount.frobTrace_twist` : quadratic twisting negates the trace.
* `EllipticModCount.sum_frobTrace_eq_zero` : the trace averages to `0` over the
  family `b ↦ (a,b)`, and over the whole family `(a,b)`.
-/
import Mathlib

namespace EllipticModCount

open Finset

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- The right-hand side `x^3 + a*x + b` of a short Weierstrass equation. -/
def wRHS (a b x : F) : F := x ^ 3 + a * x + b

/-- The affine solution set of `y^2 = x^3 + a*x + b`. -/
def affineLocus (a b : F) : Finset (F × F) :=
  univ.filter fun P => P.2 ^ 2 = wRHS a b P.1

/-- The number of projective points: affine solutions together with the point at infinity. -/
def cardPoints (a b : F) : ℕ := (affineLocus a b).card + 1

/-- The trace of Frobenius `#F + 1 - #E(F)`. -/
def frobTrace (a b : F) : ℤ := (Fintype.card F : ℤ) + 1 - (cardPoints a b : ℤ)

/-- The character sum `∑ x, χ(x^3+a*x+b)`. -/
def charSum (a b : F) : ℤ := ∑ x : F, quadraticChar F (wRHS a b x)

/-- The set of roots of the cubic `x^3 + a*x + b`, i.e. the `x`-coordinates of 2-torsion. -/
def rootSet (a b : F) : Finset F := univ.filter fun x => wRHS a b x = 0

/-- The discriminant (up to sign and a constant) of `x^3 + a*x + b`. -/
def disc (a b : F) : F := 4 * a ^ 3 + 27 * b ^ 2

section Counting

/-- The number of square roots of `c` in `F`, as a `Finset` cardinality. -/
theorem card_sqrt_filter (hF : ringChar F ≠ 2) (c : F) :
    ((univ.filter fun y : F => y ^ 2 = c).card : ℤ) = quadraticChar F c + 1 := by
  have h := quadraticChar_card_sqrts hF c
  rw [← h]
  congr 2
  rw [Set.toFinset_setOf]

/-- The number of square roots of `c` in `F`, as a sum of indicators. -/
theorem sum_ite_sq (hF : ringChar F ≠ 2) (c : F) :
    ∑ y : F, (if y ^ 2 = c then (1 : ℤ) else 0) = quadraticChar F c + 1 := by
  rw [← card_sqrt_filter hF c, Finset.card_filter]
  push_cast
  rfl

/-- **Counting formula.** The number of affine solutions of `y^2 = x^3+a*x+b` is
`#F + ∑ x, χ(x^3+a*x+b)`. -/
theorem card_affineLocus (hF : ringChar F ≠ 2) (a b : F) :
    ((affineLocus a b).card : ℤ) = (Fintype.card F : ℤ) + charSum a b := by
  have key : ∀ x : F,
      ((univ.filter fun y : F => y ^ 2 = wRHS a b x).card : ℤ)
        = quadraticChar F (wRHS a b x) + 1 := fun x => card_sqrt_filter hF _
  have h2 : (affineLocus a b).card
      = ∑ x : F, (univ.filter fun y : F => y ^ 2 = wRHS a b x).card := by
    rw [affineLocus, Finset.card_filter, Fintype.sum_prod_type]
    exact Finset.sum_congr rfl fun x _ => (Finset.card_filter _ _).symm
  rw [h2]
  push_cast
  rw [Finset.sum_congr rfl fun x _ => key x]
  rw [Finset.sum_add_distrib]
  simp [charSum, Finset.card_univ, add_comm]

/-- The point count in terms of the character sum. -/
theorem cardPoints_eq (hF : ringChar F ≠ 2) (a b : F) :
    (cardPoints a b : ℤ) = (Fintype.card F : ℤ) + 1 + charSum a b := by
  rw [cardPoints]
  push_cast
  rw [card_affineLocus hF]
  ring

/-- The trace of Frobenius is minus the character sum. -/
theorem frobTrace_eq_neg_charSum (hF : ringChar F ≠ 2) (a b : F) :
    frobTrace a b = -charSum a b := by
  rw [frobTrace, cardPoints_eq hF]; ring

end Counting

section Parity

/-- Each character value is congruent mod `2` to the indicator of "nonzero". -/
private lemma two_dvd_charSum_sub (a b : F) :
    (2 : ℤ) ∣ charSum a b - ((Fintype.card F : ℤ) - (rootSet a b).card) := by
  have h0 : ((rootSet a b).card : ℤ) = ∑ x : F, (if wRHS a b x = 0 then (1 : ℤ) else 0) := by
    rw [rootSet, Finset.card_filter]
    push_cast
    rfl
  have hq : (Fintype.card F : ℤ) = ∑ _x : F, (1 : ℤ) := by simp [Finset.card_univ]
  have hcount : ((Fintype.card F : ℤ) - (rootSet a b).card)
      = ∑ x : F, (if wRHS a b x = 0 then (0 : ℤ) else 1) := by
    rw [hq, h0, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun x _ => by by_cases h : wRHS a b x = 0 <;> simp [h]
  rw [hcount, charSum, ← Finset.sum_sub_distrib]
  refine Finset.dvd_sum fun x _ => ?_
  by_cases h : wRHS a b x = 0
  · simp [h]
  · have h1 : quadraticChar F (wRHS a b x) = 1 ∨ quadraticChar F (wRHS a b x) = -1 :=
      quadraticChar_dichotomy h
    rcases h1 with h1 | h1 <;> simp [h, h1]

/-- **Parity of the point count.** `#E(F) ≡ 1 + #roots (mod 2)`. -/
theorem two_dvd_cardPoints_sub (hF : ringChar F ≠ 2) (a b : F) :
    (2 : ℤ) ∣ (cardPoints a b : ℤ) - (1 + (rootSet a b).card) := by
  have h := two_dvd_charSum_sub (F := F) a b
  rw [cardPoints_eq hF]
  obtain ⟨k, hk⟩ := h
  exact ⟨k + (Fintype.card F : ℤ) - (rootSet a b).card, by linarith [hk]⟩

end Parity

section RootCount

variable {a b r s : F}

omit [Fintype F] [DecidableEq F] in
/-- If `r ≠ s` are both roots of `x^3+a*x+b`, then the coefficients are determined. -/
theorem coeff_eq_of_two_roots (hr : wRHS a b r = 0) (hs : wRHS a b s = 0) (hrs : r ≠ s) :
    a = -(r ^ 2 + r * s + s ^ 2) ∧ b = r * s * (r + s) := by
  have hd : (r - s) * (r ^ 2 + r * s + s ^ 2 + a) = 0 := by
    have : wRHS a b r - wRHS a b s = 0 := by rw [hr, hs]; ring
    rw [wRHS, wRHS] at this; linear_combination this
  have hrs' : r - s ≠ 0 := sub_ne_zero.mpr hrs
  have ha : a = -(r ^ 2 + r * s + s ^ 2) := by
    rcases mul_eq_zero.mp hd with h | h
    · exact absurd h hrs'
    · linear_combination h
  refine ⟨ha, ?_⟩
  rw [wRHS, ha] at hr
  linear_combination hr

omit [Fintype F] [DecidableEq F] in
/-- With two distinct roots the cubic factors completely. -/
theorem wRHS_factor (hr : wRHS a b r = 0) (hs : wRHS a b s = 0) (hrs : r ≠ s) (u : F) :
    wRHS a b u = (u - r) * (u - s) * (u + r + s) := by
  obtain ⟨ha, hb⟩ := coeff_eq_of_two_roots hr hs hrs
  rw [wRHS, ha, hb]; ring

/-- Two distinct roots of a nonsingular cubic force a third one, distinct from both. -/
theorem rootSet_eq_of_two_roots (hd : disc a b ≠ 0)
    (hr : wRHS a b r = 0) (hs : wRHS a b s = 0) (hrs : r ≠ s) :
    rootSet a b = {r, s, -(r + s)} ∧ (rootSet a b).card = 3 := by
  obtain ⟨ha, hb⟩ := coeff_eq_of_two_roots hr hs hrs
  have hne1 : r ≠ -(r + s) := by
    intro h
    apply hd
    have hsr : s = -(2 * r) := by linear_combination h
    rw [disc, ha, hb, hsr]; ring
  have hne2 : s ≠ -(r + s) := by
    intro h
    apply hd
    have hsr : r = -(2 * s) := by linear_combination h
    rw [disc, ha, hb, hsr]; ring
  have hset : rootSet a b = {r, s, -(r + s)} := by
    ext u
    simp only [rootSet, mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    rw [wRHS_factor hr hs hrs u]
    constructor
    · intro h
      rcases mul_eq_zero.mp h with h | h
      · rcases mul_eq_zero.mp h with h | h
        · exact Or.inl (by linear_combination h)
        · exact Or.inr (Or.inl (by linear_combination h))
      · exact Or.inr (Or.inr (by linear_combination h))
    · rintro (h | h | h) <;> rw [h] <;> ring
  refine ⟨hset, ?_⟩
  have h1 : r ∉ ({s, -(r + s)} : Finset F) := by
    simp only [mem_insert, mem_singleton]
    push_neg
    exact ⟨hrs, hne1⟩
  have h2 : s ∉ ({-(r + s)} : Finset F) := by
    simp only [mem_singleton]
    exact hne2
  rw [hset, card_insert_of_notMem h1, card_insert_of_notMem h2, card_singleton]

/-- **No cubic with exactly two roots.** A nonsingular short Weierstrass cubic has
`0`, `1` or `3` roots. -/
theorem rootSet_card_cases (hd : disc a b ≠ 0) :
    (rootSet a b).card = 0 ∨ (rootSet a b).card = 1 ∨ (rootSet a b).card = 3 := by
  rcases Nat.lt_or_ge (rootSet a b).card 2 with h | h
  · interval_cases hc : (rootSet a b).card
    · exact Or.inl rfl
    · exact Or.inr (Or.inl rfl)
  · obtain ⟨r, hr, s, hs, hrs⟩ := Finset.one_lt_card.mp h
    simp only [rootSet, mem_filter, mem_univ, true_and] at hr hs
    exact Or.inr (Or.inr (rootSet_eq_of_two_roots hd hr hs hrs).2)

/-- **2-torsion criterion.** For a nonsingular curve, the number of points is even iff the
cubic `x^3+a*x+b` has a root in `F` (i.e. the curve has a nontrivial 2-torsion point). -/
theorem two_dvd_cardPoints_iff (hF : ringChar F ≠ 2) (hd : disc a b ≠ 0) :
    2 ∣ cardPoints a b ↔ ∃ x : F, x ^ 3 + a * x + b = 0 := by
  have hpar := two_dvd_cardPoints_sub hF a b
  have hroots : ((∃ x : F, x ^ 3 + a * x + b = 0) ↔ (rootSet a b).card ≠ 0) := by
    rw [Finset.card_ne_zero, Finset.nonempty_iff_ne_empty]
    constructor
    · rintro ⟨x, hx⟩ he
      have : x ∈ rootSet a b := by simp [rootSet, wRHS, hx]
      rw [he] at this; simp at this
    · intro he
      obtain ⟨x, hx⟩ := Finset.nonempty_iff_ne_empty.mpr he
      simp only [rootSet, mem_filter, mem_univ, true_and, wRHS] at hx
      exact ⟨x, hx⟩
  rw [hroots]
  rcases rootSet_card_cases hd with h | h | h <;> rw [h] at hpar ⊢ <;> push_cast at hpar <;> omega

end RootCount

section Reindex

omit [Field F] [DecidableEq F] in
/-- Reindexing a character sum along a bijection. -/
private lemma sum_comp_bijective {e : F → F} (he : Function.Bijective e) (g : F → ℤ) :
    ∑ x : F, g (e x) = ∑ x : F, g x :=
  Fintype.sum_bijective e he _ _ fun _ => rfl

end Reindex

section Supersingular

/-- If cubing is a bijection of `F`, the curve `y^2 = x^3 + b` is *supersingular*:
its character sum vanishes. -/
theorem charSum_eq_zero_of_cube_bijective (hF : ringChar F ≠ 2)
    (hcube : Function.Bijective fun x : F => x ^ 3) (b : F) : charSum 0 b = 0 := by
  have h1 : charSum 0 b = ∑ x : F, quadraticChar F (x ^ 3 + b) := by
    simp [charSum, wRHS]
  have h2 : ∑ x : F, quadraticChar F (x ^ 3 + b) = ∑ t : F, quadraticChar F (t + b) :=
    sum_comp_bijective hcube (fun t => quadraticChar F (t + b))
  have h3 : ∑ t : F, quadraticChar F (t + b) = ∑ u : F, quadraticChar F u :=
    sum_comp_bijective (Equiv.addRight b).bijective (fun u => quadraticChar F u)
  rw [h1, h2, h3, quadraticChar_sum_zero hF]

/-- If `-1` is a nonsquare in `F`, the curve `y^2 = x^3 + a*x` is *supersingular*. -/
theorem charSum_eq_zero_of_neg_one_nonsquare (hneg : quadraticChar F (-1) = -1) (a : F) :
    charSum a 0 = 0 := by
  have hflip : ∑ x : F, quadraticChar F (wRHS a 0 (-x)) = charSum a 0 :=
    sum_comp_bijective (Equiv.neg F).bijective (fun x => quadraticChar F (wRHS a 0 x))
  have hval : ∀ x : F, quadraticChar F (wRHS a 0 (-x)) = -quadraticChar F (wRHS a 0 x) := by
    intro x
    have : wRHS a 0 (-x) = (-1) * wRHS a 0 x := by rw [wRHS, wRHS]; ring
    rw [this, map_mul, hneg]
    ring
  rw [Finset.sum_congr rfl fun x _ => hval x, Finset.sum_neg_distrib,
    show (∑ x : F, quadraticChar F (wRHS a 0 x)) = charSum a 0 from rfl] at hflip
  omega

/-- Cubing is a bijection of `F` as soon as `3` is coprime to `#F - 1`. -/
theorem cube_bijective_of_coprime (h : Nat.Coprime (Fintype.card F - 1) 3) :
    Function.Bijective fun x : F => x ^ 3 := by
  have hinj : Function.Injective fun x : F => x ^ 3 := by
    have hu : Function.Bijective fun u : Fˣ => u ^ 3 := by
      apply Nat.Coprime.pow_left_bijective
      simpa [Nat.card_eq_fintype_card, Fintype.card_units] using h
    intro x y hxy
    simp only at hxy
    by_cases hy : y = 0
    · subst hy
      have h0 : x ^ 3 = 0 := by simpa using hxy
      exact pow_eq_zero_iff (by norm_num) |>.mp h0
    · have hx : x ≠ 0 := by
        intro hx
        apply hy
        rw [hx] at hxy
        have h0 : y ^ 3 = 0 := by simpa using hxy.symm
        exact pow_eq_zero_iff (by norm_num) |>.mp h0
      have : (Units.mk0 x hx) ^ 3 = (Units.mk0 y hy) ^ 3 := by
        ext
        simpa using hxy
      have := hu.injective this
      simpa using congrArg (Units.val) this
  exact Finite.injective_iff_bijective.mp hinj

end Supersingular

section Twist

variable {a b d : F}

/-- **Quadratic twisting negates the character sum.** -/
theorem charSum_twist (hd : quadraticChar F d = -1) (a b : F) :
    charSum (a * d ^ 2) (b * d ^ 3) = -charSum a b := by
  have hd0 : d ≠ 0 := by
    intro h
    rw [h, quadraticChar_zero] at hd
    exact absurd hd (by decide)
  have hbij : Function.Bijective fun u : F => d * u := by
    refine ⟨fun u v huv => by field_simp at huv; exact huv, fun v => ⟨d⁻¹ * v, by field_simp⟩⟩
  have hstep : ∀ u : F, quadraticChar F (d ^ 3 * wRHS a b u)
      = quadraticChar F (wRHS (a * d ^ 2) (b * d ^ 3) (d * u)) := by
    intro u
    congr 1
    rw [wRHS, wRHS]
    ring
  calc charSum (a * d ^ 2) (b * d ^ 3)
      = ∑ u : F, quadraticChar F (wRHS (a * d ^ 2) (b * d ^ 3) (d * u)) :=
        (sum_comp_bijective hbij (fun x => quadraticChar F (wRHS (a * d ^ 2) (b * d ^ 3) x))).symm
    _ = ∑ u : F, quadraticChar F (d ^ 3 * wRHS a b u) :=
        Finset.sum_congr rfl fun u _ => (hstep u).symm
    _ = ∑ u : F, (-1) * quadraticChar F (wRHS a b u) := by
        refine Finset.sum_congr rfl fun u _ => ?_
        rw [map_mul, map_pow, hd]
        norm_num
    _ = -charSum a b := by rw [← Finset.mul_sum, neg_one_mul]; rfl

/-- **Quadratic twisting negates the trace of Frobenius**, hence
`#E(F) + #E^d(F) = 2 * #F + 2`. -/
theorem frobTrace_twist (hF : ringChar F ≠ 2) (hd : quadraticChar F d = -1) (a b : F) :
    frobTrace (a * d ^ 2) (b * d ^ 3) = -frobTrace a b := by
  rw [frobTrace_eq_neg_charSum hF, frobTrace_eq_neg_charSum hF, charSum_twist hd]

/-- The point counts of a curve and of its quadratic twist add up to `2 * #F + 2`. -/
theorem cardPoints_add_twist (hF : ringChar F ≠ 2) (hd : quadraticChar F d = -1) (a b : F) :
    (cardPoints a b : ℤ) + (cardPoints (a * d ^ 2) (b * d ^ 3) : ℤ)
      = 2 * (Fintype.card F : ℤ) + 2 := by
  have h1 := frobTrace_twist hF hd a b
  rw [frobTrace, frobTrace] at h1
  linarith

end Twist

section Averages

/-- **The trace of Frobenius averages to zero along the family `b ↦ (a,b)`.** -/
theorem sum_charSum_over_b (hF : ringChar F ≠ 2) (a : F) : ∑ b : F, charSum a b = 0 := by
  have hswap : ∑ b : F, charSum a b = ∑ x : F, ∑ b : F, quadraticChar F (wRHS a b x) :=
    Finset.sum_comm
  rw [hswap]
  refine Finset.sum_eq_zero fun x _ => ?_
  have : ∀ b : F, quadraticChar F (wRHS a b x) = quadraticChar F ((x ^ 3 + a * x) + b) :=
    fun _ => rfl
  have hb : Function.Bijective (fun b : F => (x ^ 3 + a * x) + b) := by
    constructor
    · intro u v h
      simpa using h
    · intro v
      exact ⟨v - (x ^ 3 + a * x), by ring⟩
  rw [Finset.sum_congr rfl fun b _ => this b]
  exact (sum_comp_bijective hb (fun u => quadraticChar F u)).trans (quadraticChar_sum_zero hF)

theorem sum_frobTrace_over_b (hF : ringChar F ≠ 2) (a : F) : ∑ b : F, frobTrace a b = 0 := by
  rw [Finset.sum_congr rfl fun b _ => frobTrace_eq_neg_charSum hF a b,
    Finset.sum_neg_distrib, sum_charSum_over_b hF, neg_zero]

/-- **Over the whole family of short Weierstrass curves the trace averages to zero.** -/
theorem sum_frobTrace (hF : ringChar F ≠ 2) : ∑ a : F, ∑ b : F, frobTrace a b = 0 :=
  Finset.sum_eq_zero fun a _ => sum_frobTrace_over_b hF a

end Averages

end EllipticModCount