import Tropical.SmoothSelfHintNoResidueHint

/-!
# Three factors: the dichotomy is not special to semiprimes

Multi-prime RSA moduli `N = p q r` raise the same question.  The fibration argument is
insensitive to the number of factors: a condition on **one designated** factor still has
an `n`-independent count, so it stays invisible, while a symmetric condition does not.

* `SmoothSelfHint.asym_fiber3_card` — `#{(a,b,c) : a b c = n, a ∈ A} = |A| · |G|`, for
  every `n`.
* `SmoothSelfHint.sym_fiber3_card_ne` — the symmetric count over `(ZMod 3)ˣ` is `4` at
  `n = 1` and `3` at `n = -1`: it does depend on `n`.
* `SmoothSelfHint.asym_no_residue_dial_three_factors` — arithmetically: for any base
  `l > 2` and any modulus `M`, no function of `N mod M` decides `l ∣ p - 1` for
  three-factor moduli `N = p q r` with `p < q < r`.
-/

open Finset

namespace SmoothSelfHint

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The fibre of the triple product map over `n`, cut down by a condition on the first
factor. -/
def asymFiber3 (A : Finset G) (n : G) : Finset (G × G × G) :=
  (univ : Finset (G × G × G)).filter (fun t => t.1 * t.2.1 * t.2.2 = n ∧ t.1 ∈ A)

/-- The symmetric analogue: some factor lies in `A`. -/
def symFiber3 (A : Finset G) (n : G) : Finset (G × G × G) :=
  (univ : Finset (G × G × G)).filter
    (fun t => t.1 * t.2.1 * t.2.2 = n ∧ (t.1 ∈ A ∨ t.2.1 ∈ A ∨ t.2.2 ∈ A))

/-- **Asymmetric invisibility for three factors.**  The number of ordered
factorisations `n = a b c` with `a ∈ A` is `|A| · |G|`, independent of `n`. -/
theorem asym_fiber3_card (A : Finset G) (n : G) :
    (asymFiber3 A n).card = A.card * Fintype.card G := by
  have : (asymFiber3 A n).card = (A ×ˢ (univ : Finset G)).card := by
    apply Finset.card_bij (fun t _ => (t.1, t.2.1))
    · intro t ht
      simp only [asymFiber3, Finset.mem_filter] at ht
      simp [ht.2.2]
    · intro s hs t ht hst
      simp only [asymFiber3, Finset.mem_filter] at hs ht
      have h1 : s.1 = t.1 := (Prod.mk.inj hst).1
      have h2 : s.2.1 = t.2.1 := (Prod.mk.inj hst).2
      have h : s.1 * s.2.1 * s.2.2 = t.1 * t.2.1 * t.2.2 := by rw [hs.2.1, ht.2.1]
      rw [h1, h2] at h
      exact Prod.ext h1 (Prod.ext h2 (mul_left_cancel h))
    · intro ab hab
      simp only [Finset.mem_product] at hab
      refine ⟨(ab.1, ab.2, (ab.1 * ab.2)⁻¹ * n), ?_, rfl⟩
      simp only [asymFiber3, Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨by group, hab.1⟩
  rw [this, Finset.card_product, Finset.card_univ]

end Group

/-- **Symmetric visibility for three factors**, on the smallest interesting group: the
count over `(ZMod 3)ˣ` is `4` at `n = 1` and `3` at `n = -1`. -/
theorem sym_fiber3_card_ne :
    (symFiber3 ({1} : Finset (ZMod 3)ˣ) 1).card = 4 ∧
      (symFiber3 ({1} : Finset (ZMod 3)ˣ) (-1)).card = 3 := by
  constructor <;> decide

/-- **No residue hint for three-factor moduli.**  For any base `l > 2` and any modulus
`M ≥ 1`, no function of `N mod M` decides `l ∣ p - 1` for `N = p q r` with `p < q < r`
prime.  (The two witnesses of `asym_indistinguishable_mod`, multiplied by a common large
prime.) -/
theorem asym_no_residue_dial_three_factors (l M : ℕ) (hl2 : 2 < l) (hM : 0 < M) :
    ¬ ∃ f : ℕ → Bool, ∀ p q r : ℕ, p.Prime → q.Prime → r.Prime → p < q → q < r →
        (decide (l ∣ p - 1) = f ((p * q * r) % M)) := by
  rintro ⟨f, hf⟩
  obtain ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hlt₁, hmid, hlt₂, hmod, hd₁, hd₂⟩ :=
    asym_indistinguishable_mod l M hl2 hM
  obtain ⟨s, hsge, hs⟩ := Nat.exists_infinite_primes (max q₁ q₂ + 1)
  have hs₁ : q₁ < s := lt_of_lt_of_le (Nat.lt_succ_of_le (le_max_left q₁ q₂)) hsge
  have hs₂ : q₂ < s := lt_of_lt_of_le (Nat.lt_succ_of_le (le_max_right q₁ q₂)) hsge
  have hmod3 : (p₁ * q₁ * s) % M = (p₂ * q₂ * s) % M := by
    have := Nat.ModEq.mul_right s (hmod : p₁ * q₁ ≡ p₂ * q₂ [MOD M])
    exact this
  have e₁ := hf p₁ q₁ s hp₁ hq₁ hs hlt₁ hs₁
  have e₂ := hf p₂ q₂ s hp₂ hq₂ hs hlt₂ hs₂
  rw [hmod3] at e₁
  rw [← e₂] at e₁
  simp only [decide_eq_decide] at e₁
  exact hd₂ (e₁.mp hd₁)

end SmoothSelfHint