import Mathlib
import Computation.QSSplitSetForcing

/-!
# Round 42, items 1–2: the smooth yield is governed by `Q`, not by `π(B)` alone

Round 42 measured that, at matched `u = log X / log B`, the sieve's smooth density
is essentially uncorrelated with `ρ(u)` (`+0.029`) and strongly correlated with
`Q/π(B)` (`+0.882`), and that paid sieve work *decreases* as `Q` grows.  This file
proves the unconditional skeleton of both observations.

**Smooth counting over an arbitrary prime set.**  `psiS S X` counts `n ∈ [1, X]`
whose prime support lies in `S` (so `psiS (factorBase B) X = Ψ(X, B)`).

* `psiS_mono` — `psiS` is monotone in the prime set.
* `psiS_insert_ge` — **the multiplicative step**: adjoining a new prime `p`
  gives `Ψ_{S∪{p}}(X) ≥ Ψ_S(X) + Ψ_S(⌊X/p⌋)`.
* `two_pow_card_le_psiS` — **exponential floor**: if `∏ S ≤ X` then
  `2^{|S|} ≤ Ψ_S(X)` (all square-free sub-products).
* `psiS_le_pow_card` — **exponential ceiling**: `Ψ_S(X) ≤ (log₂ X + 1)^{|S|}`.

So at a fixed value size `X` (fixed `u`), the count is squeezed between two
functions that are exponential in `|S|` — the *exponent* is the size of the
prime set, and nothing else about `B` enters.

**Specialisation to the sieve.**

* `qsYield_le_psiS_admissible` / `qsYield_le_pow_Q` — the number of `B`-smooth
  sieve values `x² - N` on a window `[a, b]` (with `a² > N`) is at most
  `Ψ_{A}(b² - N) ≤ (log₂(b² - N) + 1)^{Q(N,B)}`: the ceiling is governed by
  `Q(N,B)`, the split-set size, *not* by `π(B)`.  Two moduli with the same `B` and
  the same window (hence the same `u`) can therefore have yield ceilings differing
  by the factor `(log₂ X + 1)^{π(B)(Q₁/π(B) - Q₂/π(B))}` — this is the formal
  shadow of "Dickman is blind to `Q`".

**The sign-flip criterion.**

* `work_mono_iff` — in the cost model `work(S) = (|S| + 1) / Ψ_S(X)` (positions
  per guaranteed dependence at fixed `X`), adjoining a prime lowers the work iff
  `(|S| + 1)(Ψ_{S∪{p}} - Ψ_S) ≥ Ψ_S`.
* `work_decreases_of_marginal` — the multiplicative step makes this hold as soon
  as `(|S| + 1) · Ψ_S(⌊X/p⌋) ≥ Ψ_S(X)`: one more column is paid for by the
  additive `+1` in the relation target, while it buys a *multiplicative* gain in
  the smooth count.  This is the structural reason why "shrinking `Q` to shrink
  the linear algebra moves the wrong term".
-/

namespace QSSplitYield

open Finset

/-- `Ψ_S(X)`: the number of `n ∈ [1, X]` all of whose prime factors lie in `S`. -/
def psiS (S : Finset ℕ) (X : ℕ) : ℕ :=
  ((Finset.Icc 1 X).filter (fun n => n.primeFactors ⊆ S)).card

theorem psiS_mono {S T : Finset ℕ} (h : S ⊆ T) (X : ℕ) : psiS S X ≤ psiS T X := by
  unfold psiS
  apply Finset.card_le_card
  intro n hn
  simp only [Finset.mem_filter] at hn ⊢
  exact ⟨hn.1, hn.2.trans h⟩

/-- `psiS` over the factor base is the classical `Ψ(X, B)` of the catalog. -/
theorem psiS_factorBase (B X : ℕ) :
    psiS (SmoothSparsity.factorBase B) X = (SmoothSparsity.smoothPool B X).card := by
  unfold psiS SmoothSparsity.smoothPool
  congr 1
  apply Finset.filter_congr
  intro n _
  constructor
  · intro h p hp; exact (SmoothSparsity.mem_factorBase.1 (h hp)).2
  · intro h p hp
    exact SmoothSparsity.mem_factorBase.2 ⟨Nat.prime_of_mem_primeFactors hp, h p hp⟩

/-- **The multiplicative step.**  Adjoining a new prime `p ∉ S` adds at least
`Ψ_S(⌊X/p⌋)` new smooth numbers (namely `p · m`). -/
theorem psiS_insert_ge {S : Finset ℕ} {p : ℕ} (hp : p.Prime) (hpS : p ∉ S) (X : ℕ) :
    psiS S X + psiS S (X / p) ≤ psiS (insert p S) X := by
  classical
  set A := (Finset.Icc 1 X).filter (fun n => n.primeFactors ⊆ S) with hA
  set C := (Finset.Icc 1 (X / p)).filter (fun n => n.primeFactors ⊆ S) with hC
  set D := (Finset.Icc 1 X).filter (fun n => n.primeFactors ⊆ insert p S) with hD
  have hp0 : 0 < p := hp.pos
  have hCimg : C.image (fun m => p * m) ⊆ D := by
    intro n hn
    obtain ⟨m, hm, rfl⟩ := Finset.mem_image.1 hn
    simp only [hC, hD, Finset.mem_filter, Finset.mem_Icc] at hm ⊢
    have hm0 : m ≠ 0 := by omega
    refine ⟨⟨?_, ?_⟩, ?_⟩
    · exact Nat.one_le_iff_ne_zero.2 (Nat.mul_ne_zero hp.ne_zero hm0)
    · have := (Nat.le_div_iff_mul_le hp0).1 hm.1.2
      linarith [mul_comm m p]
    · rw [Nat.primeFactors_mul hp.ne_zero hm0, hp.primeFactors]
      exact Finset.union_subset (by simp) (hm.2.trans (Finset.subset_insert _ _))
  have hAD : A ⊆ D := by
    intro n hn
    simp only [hA, hD, Finset.mem_filter] at hn ⊢
    exact ⟨hn.1, hn.2.trans (Finset.subset_insert _ _)⟩
  have hdisj : Disjoint A (C.image (fun m => p * m)) := by
    rw [Finset.disjoint_left]
    intro n hnA hnC
    obtain ⟨m, hm, rfl⟩ := Finset.mem_image.1 hnC
    simp only [hA, hC, Finset.mem_filter, Finset.mem_Icc] at hnA hm
    have hm0 : m ≠ 0 := by omega
    apply hpS
    apply hnA.2
    rw [Nat.primeFactors_mul hp.ne_zero hm0, hp.primeFactors]
    simp
  have hcardC : (C.image (fun m => p * m)).card = C.card :=
    Finset.card_image_of_injective _ (fun a b h => Nat.eq_of_mul_eq_mul_left hp0 h)
  have := Finset.card_le_card (Finset.union_subset hAD hCimg)
  rw [Finset.card_union_of_disjoint hdisj, hcardC] at this
  exact this

/-- **Exponential floor.**  If every element of `S` is prime and `∏ S ≤ X`, then
`2^{|S|} ≤ Ψ_S(X)`: the `2^{|S|}` square-free sub-products are distinct and
`S`-smooth. -/
theorem two_pow_card_le_psiS {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {X : ℕ}
    (hX : ∏ p ∈ S, p ≤ X) : 2 ^ S.card ≤ psiS S X := by
  classical
  rw [← Finset.card_powerset]
  unfold psiS
  refine Finset.card_le_card_of_injOn (fun T => ∏ p ∈ T, p) ?_ ?_
  · intro T hT
    have hTS : T ⊆ S := Finset.mem_powerset.1 hT
    have hTp : ∀ p ∈ T, p.Prime := fun p hp => hS p (hTS hp)
    dsimp only
    rw [Finset.mem_coe, Finset.mem_filter, Finset.mem_Icc]
    refine ⟨⟨?_, ?_⟩, ?_⟩
    · exact Nat.one_le_iff_ne_zero.2
        (Finset.prod_ne_zero_iff.2 (fun p hp => (hTp p hp).ne_zero))
    · refine le_trans ?_ hX
      exact Finset.prod_le_prod_of_subset_of_one_le' hTS
        (fun i hi _ => (hS i hi).one_lt.le)
    · rw [Nat.primeFactors_prod hTp]; exact hTS
  · intro T hT U hU hTU
    have hTp : ∀ p ∈ T, p.Prime := fun p hp => hS p (Finset.mem_powerset.1 hT hp)
    have hUp : ∀ p ∈ U, p.Prime := fun p hp => hS p (Finset.mem_powerset.1 hU hp)
    have := congrArg Nat.primeFactors hTU
    simp only at this
    rwa [Nat.primeFactors_prod hTp, Nat.primeFactors_prod hUp] at this

/-- **Exponential ceiling.**  `Ψ_S(X) ≤ (log₂ X + 1)^{|S|}`. -/
theorem psiS_le_pow_card (S : Finset ℕ) (X : ℕ) :
    psiS S X ≤ (Nat.log 2 X + 1) ^ S.card := by
  classical
  set k := Nat.log 2 X with hk
  set f : ℕ → (S → Fin (k + 1)) :=
    fun n p => ⟨min (n.factorization p) k, by omega⟩ with hf
  have hinj : Set.InjOn f ((Finset.Icc 1 X).filter (fun n => n.primeFactors ⊆ S)) := by
    intro a ha b hb hab
    simp only [Finset.coe_filter, Finset.mem_Icc, Set.mem_setOf_eq] at ha hb
    have ha0 : a ≠ 0 := by omega
    have hb0 : b ≠ 0 := by omega
    have hfa : ∀ p, a.factorization p = b.factorization p := by
      intro p
      by_cases hp : p ∈ S
      · have := congrFun hab ⟨p, hp⟩
        simp only [hf, Fin.mk.injEq] at this
        have h1 := SmoothSparsity.factorization_le_log_two (p := p) ha0 ha.1.2
        have h2 := SmoothSparsity.factorization_le_log_two (p := p) hb0 hb.1.2
        omega
      · have hA : a.factorization p = 0 := by
          by_contra hcon
          exact hp (ha.2 (by rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hcon))
        have hB : b.factorization p = 0 := by
          by_contra hcon
          exact hp (hb.2 (by rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hcon))
        rw [hA, hB]
    exact Nat.factorization_inj ha0 hb0 (Finsupp.ext hfa)
  unfold psiS
  calc _ ≤ (Finset.univ : Finset (S → Fin (k + 1))).card :=
        Finset.card_le_card_of_injOn f (fun n _ => Finset.mem_univ _) hinj
    _ = (k + 1) ^ S.card := by simp

/-! ## The sieve yield is bounded by a function of `Q(N,B)` -/

/-- The number of sieve positions `x ∈ [a, b]` whose value `x² - N` is
`B`-smooth. -/
def qsYield (N B a b : ℕ) : ℕ :=
  ((Finset.Icc a b).filter (fun x => ∀ p ∈ (x ^ 2 - N).primeFactors, p ≤ B)).card

/-- **Yield ceiling by the split set.**  On a window `[a, b]` with `N < a²`, the
`B`-smooth yield is at most `Ψ_{A(N,B)}(b² - N)`. -/
theorem qsYield_le_psiS_admissible (N B a b : ℕ) (ha : N < a ^ 2) :
    qsYield N B a b ≤ psiS (QSDimension.admissiblePrimes (N : ℤ) B) (b ^ 2 - N) := by
  classical
  unfold qsYield psiS
  refine Finset.card_le_card_of_injOn (fun x => x ^ 2 - N) ?_ ?_
  · intro x hx
    simp only [Finset.coe_filter, Finset.mem_Icc, Set.mem_setOf_eq] at hx
    obtain ⟨⟨hax, hxb⟩, hsm⟩ := hx
    have hxa : a ^ 2 ≤ x ^ 2 := Nat.pow_le_pow_left hax 2
    have hxb2 : x ^ 2 ≤ b ^ 2 := Nat.pow_le_pow_left hxb 2
    dsimp only
    rw [Finset.mem_coe, Finset.mem_filter, Finset.mem_Icc]
    refine ⟨⟨by omega, by omega⟩, ?_⟩
    have hval : ((x ^ 2 - N : ℕ) : ℤ) = (x : ℤ) ^ 2 - (N : ℤ) := by
      push_cast [show N ≤ x ^ 2 by omega]; ring
    exact (QSSplitForcing.qs_smooth_iff_admissible_support hval).1 hsm
  · intro x hx y hy hxy
    simp only [Finset.coe_filter, Finset.mem_Icc, Set.mem_setOf_eq] at hx hy hxy
    have hx2 : a ^ 2 ≤ x ^ 2 := Nat.pow_le_pow_left hx.1.1 2
    have hy2 : a ^ 2 ≤ y ^ 2 := Nat.pow_le_pow_left hy.1.1 2
    have : x ^ 2 = y ^ 2 := by omega
    exact Nat.pow_left_injective (by norm_num) this

/-- **The yield ceiling depends on `Q`, not on `π(B)`.** -/
theorem qsYield_le_pow_Q (N B a b : ℕ) (ha : N < a ^ 2) :
    qsYield N B a b ≤
      (Nat.log 2 (b ^ 2 - N) + 1) ^ (QSDimension.admissiblePrimes (N : ℤ) B).card :=
  (qsYield_le_psiS_admissible N B a b ha).trans (psiS_le_pow_card _ _)

/-! ## The sign-flip criterion -/

/-- Model cost: positions per guaranteed dependence, `(|S| + 1) / Ψ_S(X)`. -/
noncomputable def work (S : Finset ℕ) (X : ℕ) : ℚ := ((S.card : ℚ) + 1) / (psiS S X : ℚ)

/-- **Criterion.**  For `p ∉ S` with `Ψ_S(X) > 0`, adjoining `p` does not raise
the model work iff `(|S| + 1)(Ψ_{S∪{p}} - Ψ_S) ≥ Ψ_S`. -/
theorem work_mono_iff {S : Finset ℕ} {p X : ℕ} (hpS : p ∉ S)
    (hpos : 0 < psiS S X) (hpos' : 0 < psiS (insert p S) X) :
    work (insert p S) X ≤ work S X ↔
      (psiS S X : ℚ) ≤ ((S.card : ℚ) + 1) * ((psiS (insert p S) X : ℚ) - psiS S X) := by
  unfold work
  rw [Finset.card_insert_of_notMem hpS, div_le_div_iff₀ (by exact_mod_cast hpos')
    (by exact_mod_cast hpos)]
  push_cast
  constructor <;> intro h <;> nlinarith

/-- **The sign flip.**  If the marginal prime satisfies
`(|S| + 1) · Ψ_S(⌊X/p⌋) ≥ Ψ_S(X)`, then adjoining it (raising `Q` by one) does not
increase the model work. -/
theorem work_decreases_of_marginal {S : Finset ℕ} {p X : ℕ} (hp : p.Prime) (hpS : p ∉ S)
    (hpos : 0 < psiS S X) (hmarg : psiS S X ≤ (S.card + 1) * psiS S (X / p)) :
    work (insert p S) X ≤ work S X := by
  have hstep := psiS_insert_ge hp hpS X
  have hpos' : 0 < psiS (insert p S) X := by omega
  rw [work_mono_iff hpS hpos hpos']
  have h1 : (psiS S X : ℚ) ≤ ((S.card : ℚ) + 1) * (psiS S (X / p) : ℚ) := by
    exact_mod_cast hmarg
  have h2 : (psiS S (X / p) : ℚ) ≤ (psiS (insert p S) X : ℚ) - psiS S X := by
    have : ((psiS S X + psiS S (X / p) : ℕ) : ℚ) ≤ psiS (insert p S) X := by
      exact_mod_cast hstep
    push_cast at this; linarith
  calc (psiS S X : ℚ) ≤ ((S.card : ℚ) + 1) * (psiS S (X / p) : ℚ) := h1
    _ ≤ _ := by
      apply mul_le_mul_of_nonneg_left h2; positivity

/-! ## Lab notes: an explicit sign flip

`S = {2, 3}`, `X = 100`, `p = 5`.  `Ψ_{2,3}(100) = 20`, `Ψ_{2,3}(20) = 10`, so
the marginal condition `3 · 10 ≥ 20` holds and
`work({2,3,5}) = 4/34 < 3/20 = work({2,3})` (indeed `Ψ_{2,3,5}(100) = 34`). -/

theorem lab_psi23_100 : psiS {2, 3} 100 = 20 := by native_decide
theorem lab_psi23_20 : psiS {2, 3} (100 / 5) = 10 := by native_decide
theorem lab_psi235_100 : psiS {5, 2, 3} 100 = 34 := by native_decide

/-- The marginal criterion certifies the flip without computing `Ψ_{2,3,5}`. -/
example : work (insert 5 {2, 3}) 100 ≤ work {2, 3} 100 :=
  work_decreases_of_marginal (by norm_num) (by decide) (by rw [lab_psi23_100]; norm_num)
    (by rw [lab_psi23_100, lab_psi23_20]; decide)

/-- And the strict inequality from the measured counts. -/
example : work (insert 5 {2, 3}) 100 < work {2, 3} 100 := by
  unfold work
  rw [show (insert 5 {2, 3} : Finset ℕ) = {5, 2, 3} from rfl, lab_psi235_100, lab_psi23_100]
  norm_num

end QSSplitYield