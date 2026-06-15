import Mathlib

lemma unitsMap_surjective_of_squarefree {n p : ℕ} (hsq : Squarefree n) (hd : p ∣ n) :
    Function.Surjective (ZMod.unitsMap hd) := by
  haveI : NeZero n := ⟨hsq.ne_zero⟩
  exact ZMod.unitsMap_surjective hd

lemma exists_orderOf_eq_sub_one_of_prime {p : ℕ} (hp : p.Prime) :
    ∃ g : (ZMod p)ˣ, orderOf g = p - 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := (ZMod p)ˣ)
  refine ⟨g, ?_⟩
  rw [hg]
  simp [ZMod.card_units_eq_totient, Nat.totient_prime hp]

lemma orderOf_dvd_of_surjective_of_forall_pow_eq_one {G H : Type*} [Group G] [Group H]
    (φ : G →* H) (hφ : Function.Surjective φ) {m : ℕ}
    (hpow : ∀ x : G, x ^ m = 1) : ∀ y : H, orderOf y ∣ m := by
  intro y
  obtain ⟨x, rfl⟩ := hφ y
  rw [orderOf_dvd_iff_pow_eq_one, ← map_pow, hpow x, map_one]

theorem prime_sub_one_dvd_of_forall_units_pow_eq_one {n p : ℕ} (hsq : Squarefree n)
    (hp : p.Prime) (hd : p ∣ n) (hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) :
    (p - 1) ∣ (n - 1) := by
  have hsurj := unitsMap_surjective_of_squarefree hsq hd
  have hord := orderOf_dvd_of_surjective_of_forall_pow_eq_one (ZMod.unitsMap hd) hsurj hpow
  obtain ⟨g, hg⟩ := exists_orderOf_eq_sub_one_of_prime hp
  have := hord g
  rwa [hg] at this