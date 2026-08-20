/-
# Hall's formula: Solomon coefficients of `ℤⁿ` at an arbitrary finite abelian `p`-group

This file proves conjecture **D1** of `FUTURE_DIRECTIONS.md` in the form of a counting theorem:
for a finite abelian `p`-group `X` of exponent dividing `pᵉ` and every rank `n`,

  `#Aut(X) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ X}  =  (∏_{i<d} (pⁿ - p^i)) · #(pX)ⁿ`,   `d = dim_{𝔽_p} X/pX`.

Equivalently: the Möbius sum `Σ_{Y ≤ X} μ(Y, X)·|Y|ⁿ` over the (arbitrarily complicated)
submodule poset of `X` collapses to the two invariants `#pX` and `dim_{𝔽_p} X/pX`.  For
`X = ℤ/pᵉ` this is the chain collapse of `Shared.SolomonZeta.CyclicPPower`; for `X = (ℤ/p)^d`
it is the Gaussian binomial of `Shared.SolomonZeta.SubspaceLattice`.

The engine is a nilpotent-ideal Nakayama lemma (`SolomonZeta.eq_top_of_sup_smul_eq_top`)
which needs no local ring: if `Iᵉ·X = 0` and `Y + I·X = X`, then `Y = X`.  Combined with the
fibrewise counting of `Shared.SolomonZeta.LocalOrder` and the count of spanning tuples of a
finite-dimensional vector space, it gives the formula above.
-/
import Catalog.Shared.SolomonZeta.LocalOrder

namespace SolomonZeta

open Module

/-! ### Nakayama for a nilpotent ideal -/

/-- **Nakayama, nilpotent form.**  If the ideal `I` satisfies `Iᵉ · X = 0` and a submodule `Y`
satisfies `Y + I·X = X`, then `Y = X`.  (No local hypothesis and no finiteness is needed.) -/
theorem eq_top_of_sup_smul_eq_top {R X : Type*} [CommRing R] [AddCommGroup X] [Module R X]
    (I : Ideal R) (e : ℕ) (hnil : (I ^ e) • (⊤ : Submodule R X) = ⊥) (Y : Submodule R X)
    (h : Y ⊔ I • (⊤ : Submodule R X) = ⊤) : Y = ⊤ := by
  have key : ∀ k : ℕ, Y ⊔ (I ^ (k + 1)) • (⊤ : Submodule R X) = ⊤ := by
    intro k
    induction k with
    | zero => simpa using h
    | succ k ih =>
      have hstep : I • (⊤ : Submodule R X) ≤ Y ⊔ (I ^ (k + 2)) • (⊤ : Submodule R X) := by
        conv_lhs => rw [← ih]
        rw [Submodule.smul_sup, ← Submodule.mul_smul, ← pow_succ']
        exact sup_le (le_sup_of_le_left Submodule.smul_le_right) le_sup_right
      refine le_antisymm le_top ?_
      calc (⊤ : Submodule R X) = Y ⊔ I • ⊤ := h.symm
        _ ≤ Y ⊔ (Y ⊔ (I ^ (k + 2)) • (⊤ : Submodule R X)) := sup_le_sup_left hstep _
        _ = Y ⊔ (I ^ (k + 2)) • (⊤ : Submodule R X) := by rw [← sup_assoc, sup_idem]
  rcases Nat.eq_zero_or_pos e with rfl | he
  · rw [pow_zero, Submodule.one_smul] at hnil
    exact le_antisymm le_top (hnil ▸ bot_le)
  · have hk := key (e - 1)
    rwa [show e - 1 + 1 = e by omega, hnil, sup_bot_eq] at hk

/-! ### The radical `pX` of a finite abelian `p`-group -/

variable (p : ℕ) (X : Type*) [AddCommGroup X]

/-- The submodule `pX` of an abelian group. -/
abbrev pRad : Submodule ℤ X := (Ideal.span {(p : ℤ)}) • (⊤ : Submodule ℤ X)

/-- The Frattini quotient `X/pX`. -/
abbrev FrattiniQuot : Type _ := X ⧸ pRad p X

variable {p X}

theorem smul_mem_pRad (x : X) : (p : ℤ) • x ∈ pRad p X :=
  Submodule.smul_mem_smul (Ideal.mem_span_singleton_self _) Submodule.mem_top

theorem nsmul_mkQ_eq_zero (x : X) :
    p • (Submodule.mkQ (pRad p X) x) = 0 := by
  rw [← map_nsmul, Submodule.mkQ_apply, Submodule.Quotient.mk_eq_zero]
  have h : (p • x : X) = (p : ℤ) • x := by simp
  rw [h]
  exact smul_mem_pRad x

variable (p X)

/-- The Frattini quotient of an abelian group is a vector space over `𝔽_p`. -/
noncomputable instance moduleZModFrattiniQuot : Module (ZMod p) (FrattiniQuot p X) :=
  AddCommGroup.zmodModule (fun q => by
    obtain ⟨x, rfl⟩ := Submodule.mkQ_surjective (pRad p X) q
    exact nsmul_mkQ_eq_zero x)

variable {p X}

/-- **Nakayama for generating tuples of a `p`-group.**  If `pᵉ` annihilates `X`, a tuple
generates `X` iff its image generates the Frattini quotient `X/pX` over `𝔽_p`. -/
theorem span_eq_top_iff_span_frattini {e : ℕ} (hpe : ∀ x : X, ((p : ℤ) ^ e) • x = 0) {n : ℕ}
    (v : Fin n → X) :
    Submodule.span ℤ (Set.range v) = ⊤ ↔
      Submodule.span (ZMod p) (Set.range fun i => Submodule.mkQ (pRad p X) (v i)) = ⊤ := by
  have hnil : ((Ideal.span {(p : ℤ)}) ^ e) • (⊤ : Submodule ℤ X) = ⊥ := by
    rw [Ideal.span_singleton_pow]
    refine le_antisymm (Submodule.smul_le.2 fun r hr x _ => ?_) bot_le
    obtain ⟨c, rfl⟩ := Ideal.mem_span_singleton.1 hr
    rw [Submodule.mem_bot, mul_comm, mul_smul, hpe x, smul_zero]
  have hmap : (Submodule.span ℤ (Set.range v)).map (Submodule.mkQ (pRad p X))
      = Submodule.span ℤ (Set.range fun i => Submodule.mkQ (pRad p X) (v i)) := by
    rw [Submodule.map_span, ← Set.range_comp]
    rfl
  rw [← span_int_eq_top_iff_span_zmod p (FrattiniQuot p X), ← hmap]
  constructor
  · intro h
    rw [h, Submodule.map_top, Submodule.range_mkQ]
  · intro h
    refine eq_top_of_sup_smul_eq_top (Ideal.span {(p : ℤ)}) e hnil _ ?_
    have hcomap := congrArg (Submodule.comap (Submodule.mkQ (pRad p X))) h
    rwa [Submodule.comap_map_eq, Submodule.ker_mkQ, Submodule.comap_top] at hcomap

/-! ### Hall's formula -/

variable [Finite X]

/-- **Counting generating tuples of a finite abelian `p`-group.**  If `pᵉ` annihilates `X`, the
number of `n`-tuples generating `X` is `(∏_{i<d}(pⁿ - p^i)) · #(pX)ⁿ`, where
`d = dim_{𝔽_p} X/pX` is the minimal number of generators of `X`. -/
theorem card_generating_tuples_pGroup [Fact p.Prime] {e : ℕ}
    (hpe : ∀ x : X, ((p : ℤ) ^ e) • x = 0) (n : ℕ) :
    Nat.card {v : Fin n → X // Submodule.span ℤ (Set.range v) = ⊤}
      = (∏ i : Fin (finrank (ZMod p) (FrattiniQuot p X)), (p ^ n - p ^ (i : ℕ)))
        * Nat.card (pRad p X) ^ n := by
  haveI : Finite (FrattiniQuot p X) := Finite.of_surjective _ (Submodule.mkQ_surjective _)
  haveI : FiniteDimensional (ZMod p) (FrattiniQuot p X) := Module.Finite.of_finite
  have hcongr : Nat.card {v : Fin n → X // Submodule.span ℤ (Set.range v) = ⊤}
      = Nat.card {v : Fin n → X //
          Submodule.span (ZMod p)
            (Set.range fun i => Submodule.mkQ (pRad p X) (v i)) = ⊤} :=
    Nat.card_congr (Equiv.subtypeEquivRight fun v => span_eq_top_iff_span_frattini hpe v)
  rw [hcongr, card_tuples_pullback (pRad p X) n
      (fun w => Submodule.span (ZMod p) (Set.range w) = ⊤),
    card_spanning_tuples_of_finiteDimensional, ZMod.card]

/-- **Hall's formula for Solomon coefficients.**  For a finite abelian `p`-group `X` of exponent
dividing `pᵉ`,

  `#Aut(X) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i)) · #(pX)ⁿ`,   `d = dim_{𝔽_p} X/pX`.

In particular the coefficient depends on the isomorphism type of `X` only through the two
invariants `#pX` and `dim_{𝔽_p} X/pX`. -/
theorem autCard_mul_quotIsoCount_pGroup [Fact p.Prime] {e : ℕ}
    (hpe : ∀ x : X, ((p : ℤ) ^ e) • x = 0) (n : ℕ) :
    autCard ℤ X * quotIsoCount ℤ (Fin n → ℤ) X
      = (∏ i : Fin (finrank (ZMod p) (FrattiniQuot p X)), (p ^ n - p ^ (i : ℕ)))
        * Nat.card (pRad p X) ^ n := by
  rw [← homEqCount_top_eq_autCard_mul_quotIsoCount, homEqCount_top_free_eq_card_spanning,
    card_generating_tuples_pGroup hpe]

/-- The Möbius weight form of Hall's formula. -/
theorem mobiusWeight_pGroup [Fact p.Prime] {e : ℕ} (hpe : ∀ x : X, ((p : ℤ) ^ e) • x = 0)
    (n : ℕ) :
    mobiusWeight ℤ (Fin n → ℤ) X
      = (((∏ i : Fin (finrank (ZMod p) (FrattiniQuot p X)), (p ^ n - p ^ (i : ℕ)))
          * Nat.card (pRad p X) ^ n : ℕ) : ℤ) := by
  rw [← homEqCount_top_eq_mobiusWeight, homEqCount_top_free_eq_card_spanning,
    card_generating_tuples_pGroup hpe]

end SolomonZeta