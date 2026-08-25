import Pythagorean.UnionBoundConverse.ExtremalValueFunction

/-!
# Prime-free attainment: the bijection–constant mixture

Fifth cycle.  `ExtremalValueFunction.lean` determines the extremal collision
probability only for a *prime* number of buckets, because the attaining family
was the affine family over `ZMod p`.  Here the arithmetic hypothesis is
removed.

For any `m ≥ 1` consider the family indexed by `Perm (Fin m) ⊕ Fin m`:

* with total probability `1 - 1/m`, a uniformly random **bijection** of the
  buckets — which never collides;
* with total probability `1/m`, a uniformly random **constant** map — which
  always collides.

`mix_exactly2Universal` shows this family is exactly `2`-universal on any key
set (two distinct keys collide precisely on the constant branch, of total mass
`m · 1/m² = 1/m`), and `mix_collisionProb` computes its collision probability
to be exactly `1/m` for any key set of size at least two.

Combining with the converse endpoint gives the **prime-free extremal value
function** `extremal_collision_value_general`:

`min over exactly 2-universal families of P(Coll) = 1/m` for `2 ≤ n ≤ m`,
`= 1` for `n > m`, for *every* number of buckets `m`.
-/

namespace UnionBoundConverse

open Finset

/-- The index set of the mixture family: a bijection branch and a constant
branch. -/
abbrev MixIndex (m : ℕ) : Type := Equiv.Perm (Fin m) ⊕ Fin m

/-- The mixture hash family: bijections on one branch, constants on the
other. -/
def mixHash (m : ℕ) : MixIndex m → Fin m → Fin m
  | Sum.inl σ, x => σ x
  | Sum.inr c, _ => c

/-- The weights of the mixture: total mass `1 - 1/m` spread uniformly over the
`m!` bijections and total mass `1/m` spread uniformly over the `m`
constants. -/
noncomputable def mixWeight (m : ℕ) : MixIndex m → ℝ
  | Sum.inl _ => (1 - 1 / (m : ℝ)) / (Nat.factorial m : ℝ)
  | Sum.inr _ => 1 / ((m : ℝ) * (m : ℝ))

variable {m : ℕ}

theorem mixWeight_nonneg (hm : 1 ≤ m) : ∀ o : MixIndex m, 0 ≤ mixWeight m o := by
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hfac : (0 : ℝ) < (Nat.factorial m : ℝ) := by
    exact_mod_cast Nat.factorial_pos m
  rintro (σ | c)
  · have : 0 ≤ 1 - 1 / (m : ℝ) := by
      have : 1 / (m : ℝ) ≤ 1 := by
        rw [div_le_one (by linarith)]
        linarith
      linarith
    exact div_nonneg this hfac.le
  · exact div_nonneg zero_le_one (mul_self_nonneg _)

theorem mixWeight_total (hm : 1 ≤ m) : ∑ o : MixIndex m, mixWeight m o = 1 := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hfac : (0 : ℝ) < (Nat.factorial m : ℝ) := by exact_mod_cast Nat.factorial_pos m
  rw [Fintype.sum_sum_type]
  have h1 : ∑ _σ : Equiv.Perm (Fin m), (1 - 1 / (m : ℝ)) / (Nat.factorial m : ℝ)
      = 1 - 1 / (m : ℝ) := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_perm, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  have h2 : ∑ _c : Fin m, 1 / ((m : ℝ) * (m : ℝ)) = 1 / (m : ℝ) := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  simp only [mixWeight]
  rw [h1, h2]
  ring

/-- The bijection–constant mixture law. -/
noncomputable def mixLaw (m : ℕ) (hm : 1 ≤ m) : FinLaw (MixIndex m) where
  w := mixWeight m
  w_nonneg := mixWeight_nonneg hm
  w_total := mixWeight_total hm

/-- Any event that fails on every bijection and holds on every constant has
probability exactly `1/m`. -/
theorem mixLaw_prob_constant_branch (hm : 1 ≤ m) {A : MixIndex m → Prop}
    (hl : ∀ σ, ¬ A (Sum.inl σ)) (hr : ∀ c, A (Sum.inr c)) :
    (mixLaw m hm).prob A = 1 / (m : ℝ) := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  simp only [FinLaw.prob, FinLaw.exp, mixLaw]
  rw [Fintype.sum_sum_type]
  have h1 : ∑ σ : Equiv.Perm (Fin m), mixWeight m (Sum.inl σ) * ind (A (Sum.inl σ)) = 0 :=
    Finset.sum_eq_zero fun σ _ => by rw [ind_neg_of (hl σ), mul_zero]
  have h2 : ∑ c : Fin m, mixWeight m (Sum.inr c) * ind (A (Sum.inr c))
      = 1 / (m : ℝ) := by
    have : ∀ c : Fin m, mixWeight m (Sum.inr c) * ind (A (Sum.inr c))
        = 1 / ((m : ℝ) * m) := fun c => by rw [ind_pos_of (hr c), mul_one]; rfl
    rw [Finset.sum_congr rfl fun c _ => this c, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
  rw [h1, h2, zero_add]

theorem mixHash_inl_injective (σ : Equiv.Perm (Fin m)) {x y : Fin m}
    (h : mixHash m (Sum.inl σ) x = mixHash m (Sum.inl σ) y) : x = y :=
  σ.injective h

/-- The mixture family is exactly `2`-universal on every key set: distinct keys
collide precisely on the constant branch, of mass `1/m`. -/
theorem mix_exactly2Universal (hm : 1 ≤ m) (S : Finset (Fin m)) :
    Exactly2Universal (mixLaw m hm) (mixHash m) S := by
  intro x _ y _ hne
  have : (Fintype.card (Fin m) : ℝ) = m := by simp
  rw [this]
  refine mixLaw_prob_constant_branch hm (fun σ hσ => hne (mixHash_inl_injective σ hσ))
    (fun c => rfl)

/-- The mixture family collides with probability exactly `1/m` on any key set of
size at least two, for *every* `m` — no primality needed. -/
theorem mix_collisionProb (hm : 1 ≤ m) {S : Finset (Fin m)} (hS : 2 ≤ S.card) :
    (mixLaw m hm).prob (Collides (mixHash m) S) = 1 / (m : ℝ) := by
  obtain ⟨x, hx, y, hy, hne⟩ := Finset.one_lt_card.mp (by omega : 1 < S.card)
  refine mixLaw_prob_constant_branch hm ?_ ?_
  · rintro σ ⟨u, _, v, _, hnuv, heq⟩
    exact hnuv (mixHash_inl_injective σ heq)
  · exact fun c => ⟨x, hx, y, hy, hne, rfl⟩

/-! ### The prime-free extremal value function -/

/-- The set of collision probabilities realised by exactly `2`-universal
families of hash functions from `n` keys into `m` buckets, for an arbitrary
number of buckets `m`. -/
def achievableGeneral (m n : ℕ) : Set ℝ :=
  {c | ∃ (Ω : Type) (_ : Fintype Ω) (L : FinLaw Ω) (h : Ω → Fin n → Fin m),
      Exactly2Universal L h (Finset.univ : Finset (Fin n)) ∧
        c = L.prob (Collides h (Finset.univ : Finset (Fin n)))}

/-- **Prime-free extremal value function.**  For every number of buckets `m`
and every `n ≥ 2`: if `n ≤ m` the least achievable collision probability of an
exactly `2`-universal family is exactly `1/m`, attained by the
bijection–constant mixture transported along `Fin n ↪ Fin m`; if `n > m` every
exactly `2`-universal family collides with probability `1`. -/
theorem extremal_collision_value_general (m n : ℕ) (hn : 2 ≤ n) :
    (n ≤ m → IsLeast (achievableGeneral m n) (1 / (m : ℝ))) ∧
      (m < n → ∀ c ∈ achievableGeneral m n, c = 1) := by
  have hcard : (Finset.univ : Finset (Fin n)).card = n := by simp
  constructor
  · intro hnm
    have hm : 1 ≤ m := by omega
    set e : Fin n → Fin m := fun i => Fin.castLE hnm i with he
    have heinj : ∀ i j : Fin n, e i = e j → i = j := by
      intro i j hij
      have hv : ((e i : Fin m) : ℕ) = ((e j : Fin m) : ℕ) := congrArg Fin.val hij
      simp only [he, Fin.val_castLE] at hv
      exact Fin.ext hv
    constructor
    · refine ⟨MixIndex m, inferInstance, mixLaw m hm, fun o i => mixHash m o (e i), ?_, ?_⟩
      · intro x _ y _ hne
        have hne' : e x ≠ e y := fun hee => hne (heinj x y hee)
        exact mix_exactly2Universal hm (Finset.univ : Finset (Fin m)) (e x)
          (Finset.mem_univ _) (e y) (Finset.mem_univ _) hne'
      · obtain ⟨x, hx, y, hy, hne⟩ :=
          Finset.one_lt_card.mp (by rw [hcard]; omega : 1 < (Finset.univ : Finset (Fin n)).card)
        have hne' : e x ≠ e y := fun hee => hne (heinj x y hee)
        refine (mixLaw_prob_constant_branch hm ?_ ?_).symm
        · rintro σ ⟨u, _, v, _, hnuv, heq⟩
          exact hnuv (heinj u v (mixHash_inl_injective σ heq))
        · exact fun c => ⟨x, hx, y, hy, hne, rfl⟩
    · rintro c ⟨Ω, instΩ, L, h, hu, rfl⟩
      have := inv_card_le_collisionProb (L := L) (h := h) (by rw [hcard]; exact hn) hu
      rwa [Fintype.card_fin] at this
  · rintro hmn c ⟨Ω, instΩ, L, h, hu, rfl⟩
    refine collisionProb_eq_one_of_card_lt L h ?_
    rw [Fintype.card_fin, hcard]
    exact hmn

end UnionBoundConverse