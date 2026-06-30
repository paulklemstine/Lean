import Mathlib

/-!
# Special Soundness and Soundness Error for Schnorr over Abstract Cyclic Groups

This file formalizes the security-relevant algebraic core of the Schnorr identification
protocol over an **abstract** finite commutative group `G` of prime order, rather than over
`ZMod p`.  The point is that the soundness of Schnorr is a statement about the interplay
between group exponentiation `G → G` and the *field* structure of the exponent ring
`ZMod (Nat.card G)`, and not a mere `ring` identity.

## Setting

* `G` is a finite commutative group with `[Fact (Nat.card G).Prime]`.
* `q := Nat.card G` is prime, so `ZMod q` is a field.
* `gexp x a := x ^ a.val` is exponentiation of `x : G` by a *field scalar* `a : ZMod q`.
  Because every element of `G` satisfies `x ^ q = 1` (Lagrange), this descends to a
  well-defined `ZMod q`-action.
* A Schnorr transcript `(A, c, s)` with commitment `A : G`, challenge `c : ZMod q` and
  response `s : ZMod q` is **accepting** (against public key `Y`) iff `gexp g s = A * gexp Y c`.

## Main results

* `powMap_bijective` / `powAut` — **Theorem 1 (power automorphism).** For any nonzero
  `k : ZMod q`, the map `x ↦ gexp x k` is a group automorphism of `G`.
* `extraction_correct` — **Theorem 2 (extraction correctness).** Two accepting transcripts
  sharing the commitment `A` but with distinct challenges yield the discrete log of `Y`,
  namely `Y = gexp g ((s₁ - s₂) * (c₁ - c₂)⁻¹)`.
* `extraction_eq_dlog`, `accepting_challenges_subsingleton`, `soundness_error_bound` —
  **Theorem 3 (soundness error).** The extracted value is *the* discrete log of `Y`; and a
  prover that never reveals this discrete log can make at most one challenge accept, so over
  a uniformly random challenge it succeeds with probability at most `1 / q`.
-/

namespace SchnorrAbstract

open Function

variable {G : Type*} [CommGroup G] [Fintype G] [hp : Fact (Nat.card G).Prime]

instance : NeZero (Nat.card G) := ⟨hp.out.pos.ne'⟩

/-- Exponentiation of a group element by a *field scalar* `a : ZMod (Nat.card G)`, defined as
`x ^ a.val`.  Since `x ^ (Nat.card G) = 1` for all `x`, this is a genuine action of the
field `ZMod (Nat.card G)` on `G`. -/
noncomputable def gexp (x : G) (a : ZMod (Nat.card G)) : G := x ^ a.val

/-- Lagrange's theorem: every element has order dividing the group cardinality, so raising to
the `Nat.card G`-th power is trivial. -/
omit hp in
lemma pow_card (x : G) : x ^ (Nat.card G) = 1 := by
  rw [Nat.card_eq_fintype_card]; exact pow_card_eq_one

omit [Fintype G] hp in
@[simp] lemma gexp_zero (x : G) : gexp x 0 = 1 := by
  simp [gexp]

/-- `gexp` agrees with ordinary natural-number powers via the canonical cast `ℕ → ZMod q`.
This is the bridge that turns modular identities in the exponent into the relation
`x ^ (n % q) = x ^ n`, valid because `x ^ q = 1`. -/
lemma gexp_natCast (x : G) (n : ℕ) : gexp x (n : ZMod (Nat.card G)) = x ^ n := by
  unfold gexp; simp +decide

@[simp] lemma gexp_one (x : G) : gexp x 1 = x := by
  convert gexp_natCast x 1
  · simp
  · rw [pow_one]

/-- `gexp x` is additive in the exponent: it is a homomorphism from `(ZMod q, +)` to `G`. -/
lemma gexp_add (x : G) (a b : ZMod (Nat.card G)) :
    gexp x (a + b) = gexp x a * gexp x b := by
  convert gexp_natCast x (a.val + b.val) using 1
  · simp +decide [gexp]
  · simp +decide [gexp, pow_add]

/-- `gexp` is multiplicative in the base (since `G` is commutative). -/
omit [Fintype G] hp in
lemma gexp_mul_base (x y : G) (a : ZMod (Nat.card G)) :
    gexp (x * y) a = gexp x a * gexp y a := by
  convert mul_pow x y a.val using 1

/-- The composition law: raising to `a` and then to `b` is raising to `a * b`.  This is the
algebraic heart of extraction. -/
lemma gexp_gexp (x : G) (a b : ZMod (Nat.card G)) :
    gexp (gexp x a) b = gexp x (a * b) := by
  rw [gexp, gexp, ← pow_mul, ← gexp_natCast]
  congr 1
  push_cast [ZMod.natCast_val, ZMod.cast_id]
  ring

/-- `gexp x` turns subtraction of exponents into division in `G`. -/
lemma gexp_sub (x : G) (a b : ZMod (Nat.card G)) :
    gexp x (a - b) = gexp x a * (gexp x b)⁻¹ := by
  rw [eq_mul_inv_iff_mul_eq, ← gexp_add]
  simp +decide

/-- For a nonzero scalar `k`, raising to the `k`-th power is injective on `G`.  This uses that
`G` has prime order: the order of any element is `1` or `q`, and `q ∤ k.val` since
`0 < k.val < q`. -/
lemma gexp_injective_of_ne_zero {k : ZMod (Nat.card G)} (hk : k ≠ 0) :
    Function.Injective (fun x : G => gexp x k) := by
  intro x y hxy
  -- It suffices to show that any `z` with `z ^ k.val = 1` is trivial.
  have hz : ∀ z : G, z ^ k.val = 1 → z = 1 := by
    intro z hz
    -- The order of `z` cannot equal `Nat.card G`, because `0 < k.val < Nat.card G`.
    have h_div : Nat.card G ∣ k.val → False := by
      intro h_div
      have h_contra : k.val = 0 := Nat.eq_zero_of_dvd_of_lt h_div (ZMod.val_lt k)
      exact hk (by rw [← ZMod.natCast_zmod_val k, h_contra]; simp +decide)
    contrapose! h_div
    have := orderOf_dvd_iff_pow_eq_one.mpr hz
    simp_all +decide
    have := orderOf_dvd_iff_pow_eq_one.mpr
      (show z ^ Fintype.card G = 1 from by rw [pow_card_eq_one])
    simp_all +decide [Nat.dvd_prime hp.1]
  specialize hz (x * y⁻¹)
  simp_all +decide [mul_pow]
  simp_all +decide [mul_inv_eq_one, gexp]

/-- **Theorem 1 (power automorphism), bijectivity form.** For nonzero `k`, the power map
`x ↦ gexp x k` is bijective.  (Injective on a finite group is bijective.) -/
theorem powMap_bijective {k : ZMod (Nat.card G)} (hk : k ≠ 0) :
    Function.Bijective (fun x : G => gexp x k) :=
  (Finite.injective_iff_bijective).mp (gexp_injective_of_ne_zero hk)

/-- The power map packaged as a monoid homomorphism `G →* G`. -/
noncomputable def powHom (k : ZMod (Nat.card G)) : G →* G where
  toFun x := gexp x k
  map_one' := by simp [gexp]
  map_mul' x y := gexp_mul_base x y k

/-- **Theorem 1 (power automorphism).** For nonzero `k : ZMod (Nat.card G)`, raising to the
`k`-th power is a group automorphism of `G`. -/
noncomputable def powAut {k : ZMod (Nat.card G)} (hk : k ≠ 0) : G ≃* G :=
  MulEquiv.ofBijective (powHom k) (powMap_bijective hk)

@[simp] lemma powAut_apply {k : ZMod (Nat.card G)} (hk : k ≠ 0) (x : G) :
    powAut hk x = gexp x k := rfl

/-- Acceptance predicate of the Schnorr verifier against public key `Y`:
`(A, c, s)` is accepting iff `gexp g s = A * gexp Y c`. -/
def Accepting (g Y A : G) (c s : ZMod (Nat.card G)) : Prop :=
  gexp g s = A * gexp Y c

/-- **Theorem 2 (extraction correctness).** Given two accepting transcripts `(A, c₁, s₁)` and
`(A, c₂, s₂)` sharing the commitment `A` but with distinct challenges `c₁ ≠ c₂`, the value
`x = (s₁ - s₂) * (c₁ - c₂)⁻¹` is a discrete logarithm of `Y` base `g`: `Y = gexp g x`.

The proof divides the two acceptance equations to obtain `gexp g (s₁ - s₂) = gexp Y (c₁ - c₂)`,
then applies the power map `· ^ (c₁ - c₂)⁻¹` (well-defined by Theorem 1) and uses the
composition law `gexp_gexp` together with `(c₁ - c₂) * (c₁ - c₂)⁻¹ = 1` in the field. -/
theorem extraction_correct (g Y A : G)
    {c₁ s₁ c₂ s₂ : ZMod (Nat.card G)}
    (h₁ : Accepting g Y A c₁ s₁) (h₂ : Accepting g Y A c₂ s₂)
    (hc : c₁ ≠ c₂) :
    Y = gexp g ((s₁ - s₂) * (c₁ - c₂)⁻¹) := by
  -- From the acceptance conditions, dividing gives `gexp g (s₁ - s₂) = gexp Y (c₁ - c₂)`.
  have h_exp : gexp g (s₁ - s₂) = gexp Y (c₁ - c₂) := by
    simp_all +decide [Accepting, gexp_sub]
    simp +decide [mul_assoc, mul_comm A]
  -- Raise both sides to `(c₁ - c₂)⁻¹` and use the composition law.
  convert congr_arg (fun x : G => gexp x ((c₁ - c₂)⁻¹)) h_exp.symm using 1
  · rw [gexp_gexp, mul_inv_cancel₀ (sub_ne_zero_of_ne hc), gexp_one]
  · rw [gexp_gexp]

/-- For a generator `g` (`orderOf g = Nat.card G`), the base exponentiation `gexp g` is
injective on `ZMod (Nat.card G)`: discrete logarithms are unique. -/
omit [Fintype G] in
lemma gexp_base_injective {g : G} (hg : orderOf g = Nat.card G) :
    Function.Injective (gexp g) := by
  intro a b hab
  have h_exp : g ^ a.val = g ^ b.val := hab
  rw [pow_eq_pow_iff_modEq, hg] at h_exp
  exact ZMod.val_injective _
    (Nat.mod_eq_of_lt (ZMod.val_lt a) ▸ Nat.mod_eq_of_lt (ZMod.val_lt b) ▸ h_exp)

/-- **Theorem 3 (soundness error), determinacy form.** If `Y = gexp g x` and two accepting
transcripts with distinct challenges are given, then the extracted value is *exactly* the
discrete log `x`.  Thus a prover who answers two distinct challenges necessarily computes the
secret discrete logarithm of `Y`. -/
theorem extraction_eq_dlog {g : G} (hg : orderOf g = Nat.card G) (Y A : G)
    {c₁ s₁ c₂ s₂ x : ZMod (Nat.card G)}
    (hx : Y = gexp g x)
    (h₁ : Accepting g Y A c₁ s₁) (h₂ : Accepting g Y A c₂ s₂)
    (hc : c₁ ≠ c₂) :
    (s₁ - s₂) * (c₁ - c₂)⁻¹ = x := by
  apply (Function.Injective.eq_iff (gexp_base_injective hg)).1
  rw [← hx, extraction_correct g Y A h₁ h₂ hc]

/-- **Theorem 3 (soundness error), counting form.** Fix a commitment `A` and a response
strategy `resp : ZMod q → ZMod q`.  If the prover never reveals the discrete log of `Y`
through extraction — i.e. for every pair of distinct challenges it would answer acceptingly,
the extracted value fails to be a discrete log of `Y` — then the set of challenges it answers
correctly is a subsingleton (has at most one element). -/
theorem accepting_challenges_subsingleton (g Y A : G)
    (resp : ZMod (Nat.card G) → ZMod (Nat.card G))
    (hno : ∀ c₁ c₂, c₁ ≠ c₂ →
      Accepting g Y A c₁ (resp c₁) → Accepting g Y A c₂ (resp c₂) →
      Y ≠ gexp g ((resp c₁ - resp c₂) * (c₁ - c₂)⁻¹)) :
    {c | Accepting g Y A c (resp c)}.Subsingleton :=
  fun c₁ hc₁ c₂ hc₂ =>
    Classical.not_not.1 fun h => hno c₁ c₂ h hc₁ hc₂ (extraction_correct g Y A hc₁ hc₂ h)

/-- **Theorem 3 (soundness error), probability bound.** Under the same hypothesis, the
accepting challenge set has cardinality at most `1`.  As there are `q = Nat.card G` possible
challenges, a uniformly random challenge is answered with probability at most `1 / q`. -/
theorem soundness_error_bound (g Y A : G)
    (resp : ZMod (Nat.card G) → ZMod (Nat.card G))
    (hno : ∀ c₁ c₂, c₁ ≠ c₂ →
      Accepting g Y A c₁ (resp c₁) → Accepting g Y A c₂ (resp c₂) →
      Y ≠ gexp g ((resp c₁ - resp c₂) * (c₁ - c₂)⁻¹)) :
    {c | Accepting g Y A c (resp c)}.ncard ≤ 1 :=
  Set.ncard_le_one_iff_subsingleton.mpr (accepting_challenges_subsingleton g Y A resp hno)

end SchnorrAbstract