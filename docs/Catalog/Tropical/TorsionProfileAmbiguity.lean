import Tropical.TropicalTorsionCensus

/-!
# Tropical root shuffling: the full torsion profile cannot locate the factors

Third cycle of the round-4 research loop, and the strongest closure of the
*free-witness* family `KROOT` (`#{x : x^d = 1 mod N}` for arbitrary exponents `d`,
not merely `d = 2^k`).

`Tropical.TropicalTorsionCensus` showed that the 2-power census of `N = pq` is the
tropical quadratic with roots `v₂(p-1)`, `v₂(q-1)`, and that two semiprimes with the
same 2-adic fingerprint have identical censuses. One might hope that using *all*
exponents `d` restores injectivity. It does not, and the reason is purely tropical:

> for each prime `ℓ`, the profile only sees the **multiset** `{v_ℓ(p-1), v_ℓ(q-1)}`
> of tropical roots; it cannot see *which of the two factors* carries which root.
> Shuffling roots between the two factors, independently at each `ℓ`, produces
> different semiprimes with literally identical torsion profiles.

The main results:

* `gcd_profile_eq_of_valuations` — root shuffling: if at every prime the valuation
  multisets of `(m₁,n₁)` and `(m₂,n₂)` agree, then
  `gcd(m₁,d)·gcd(n₁,d) = gcd(m₂,d)·gcd(n₂,d)` for every `d`;
* `torsionProfile_35_eq_39` — the concrete shuffle `{4,6} ↦ {2,12}`:
  `N = 35 = 5·7` and `N = 39 = 3·13` have *identical* `d`-torsion counts for every `d`;
* `full_profile_cannot_locate` — hence no functional of the entire torsion profile
  returns a prime factor. The whole `KROOT` family is sealed at once.
-/

namespace TropicalTorsionCensus

/-! ## 1. Root shuffling -/

/-- The `ℓ`-adic valuation of a gcd is the tropical (min-plus) sum of valuations. -/
lemma factorization_gcd_apply {m d : ℕ} (hm : m ≠ 0) (hd : d ≠ 0) (l : ℕ) :
    (m.gcd d).factorization l = min (m.factorization l) (d.factorization l) := by
  have h := congrArg (fun f : ℕ →₀ ℕ => f l) (Nat.factorization_gcd hm hd)
  simpa [Finsupp.inf_apply] using h

/-- **Tropical root shuffling.** If, at every prime `ℓ`, the pair `(m₁, n₁)` and the
pair `(m₂, n₂)` carry the same *multiset* of `ℓ`-adic valuations, then the two pairs
have exactly the same gcd profile. The assignment of valuations to the two members of
the pair is invisible to the profile. -/
theorem gcd_profile_eq_of_valuations (m₁ n₁ m₂ n₂ : ℕ)
    (hm₁ : m₁ ≠ 0) (hn₁ : n₁ ≠ 0) (hm₂ : m₂ ≠ 0) (hn₂ : n₂ ≠ 0)
    (h : ∀ l : ℕ, l.Prime →
      (m₁.factorization l = m₂.factorization l ∧ n₁.factorization l = n₂.factorization l) ∨
      (m₁.factorization l = n₂.factorization l ∧ n₁.factorization l = m₂.factorization l))
    (d : ℕ) (hd : d ≠ 0) :
    m₁.gcd d * n₁.gcd d = m₂.gcd d * n₂.gcd d := by
  have hg : ∀ m : ℕ, m ≠ 0 → m.gcd d ≠ 0 := fun m _ =>
    (Nat.gcd_pos_of_pos_right m (Nat.pos_of_ne_zero hd)).ne'
  refine Nat.eq_of_factorization_eq (by positivity) (by positivity) (fun l => ?_)
  by_cases hl : l.Prime
  · rw [Nat.factorization_mul (hg _ hm₁) (hg _ hn₁),
      Nat.factorization_mul (hg _ hm₂) (hg _ hn₂)]
    simp only [Finsupp.add_apply]
    rw [factorization_gcd_apply hm₁ hd, factorization_gcd_apply hn₁ hd,
      factorization_gcd_apply hm₂ hd, factorization_gcd_apply hn₂ hd]
    rcases h l hl with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · rw [h1, h2]
    · rw [h1, h2]; omega
  · rw [Nat.factorization_eq_zero_of_not_prime _ hl,
      Nat.factorization_eq_zero_of_not_prime _ hl]

/-! ## 2. The concrete shuffle `{4, 6} ↦ {2, 12}` -/

lemma factorization_pow_apply (p j l : ℕ) (hp : p.Prime) :
    (p ^ j).factorization l = if l = p then j else 0 := by
  rw [Nat.Prime.factorization_pow hp, Finsupp.single_apply]
  by_cases h : l = p
  · subst h; simp
  · simp [h, Ne.symm h]

lemma factorization_four (l : ℕ) : (4 : ℕ).factorization l = if l = 2 then 2 else 0 := by
  rw [show (4:ℕ) = 2 ^ 2 by norm_num]
  exact factorization_pow_apply 2 2 l Nat.prime_two

lemma factorization_two' (l : ℕ) : (2 : ℕ).factorization l = if l = 2 then 1 else 0 := by
  rw [show (2:ℕ) = 2 ^ 1 by norm_num]
  exact factorization_pow_apply 2 1 l Nat.prime_two

lemma factorization_six (l : ℕ) :
    (6 : ℕ).factorization l = (if l = 2 then 1 else 0) + (if l = 3 then 1 else 0) := by
  rw [show (6:ℕ) = 2 * 3 by norm_num,
    Nat.factorization_mul (by norm_num) (by norm_num), Finsupp.add_apply,
    show (2:ℕ) = 2 ^ 1 by norm_num, show (3:ℕ) = 3 ^ 1 by norm_num,
    factorization_pow_apply 2 1 l Nat.prime_two, factorization_pow_apply 3 1 l Nat.prime_three]
  norm_num

lemma factorization_twelve (l : ℕ) :
    (12 : ℕ).factorization l = (if l = 2 then 2 else 0) + (if l = 3 then 1 else 0) := by
  rw [show (12:ℕ) = 4 * 3 by norm_num,
    Nat.factorization_mul (by norm_num) (by norm_num), Finsupp.add_apply,
    factorization_four l, show (3:ℕ) = 3 ^ 1 by norm_num,
    factorization_pow_apply 3 1 l Nat.prime_three]
  norm_num

/-- The gcd profiles of the pairs `(4,6)` and `(2,12)` coincide: at the prime `2` the
tropical roots `{2,1}` have simply been swapped between the two members. -/
theorem gcd_profile_four_six (d : ℕ) (hd : d ≠ 0) :
    (4 : ℕ).gcd d * (6 : ℕ).gcd d = (2 : ℕ).gcd d * (12 : ℕ).gcd d := by
  refine gcd_profile_eq_of_valuations 4 6 2 12 (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (fun l _ => ?_) d hd
  rw [factorization_four, factorization_six, factorization_two', factorization_twelve]
  by_cases h2 : l = 2
  · subst h2; right; norm_num
  · left; simp [h2]

/-! ## 3. Sealing the whole free-witness family -/

/-- **`N = 35` and `N = 39` have identical torsion profiles.** For every exponent `d`,
the number of `d`-torsion units modulo `35 = 5·7` equals the number modulo
`39 = 3·13`. -/
theorem torsionProfile_35_eq_39 (d : ℕ) (hd : d ≠ 0) :
    torsionCount (ZMod 35)ˣ d = torsionCount (ZMod 39)ˣ d := by
  have h35 : torsionCount (ZMod (5 * 7))ˣ d = (5 - 1).gcd d * (7 - 1).gcd d :=
    torsionCount_units_semiprime 5 7 (by norm_num) (by norm_num) (by norm_num) d
  have h39 : torsionCount (ZMod (3 * 13))ˣ d = (3 - 1).gcd d * (13 - 1).gcd d :=
    torsionCount_units_semiprime 3 13 (by norm_num) (by norm_num) (by norm_num) d
  norm_num at h35 h39
  rw [show (35:ℕ) = 5 * 7 by norm_num, show (39:ℕ) = 3 * 13 by norm_num, h35, h39]
  exact gcd_profile_four_six d hd

/-- **Sealing of the whole `KROOT` free-witness family.** No functional of the entire
torsion profile `d ↦ #{x : x^d = 1 mod N}` (over all exponents `d ≥ 1`) can return a
prime factor of a semiprime: `35 = 5·7` and `39 = 3·13` have the same profile but
different factors. Tropically: the profile determines the multiset of tropical roots
at each prime, and nothing about how those roots are distributed over `p` and `q`. -/
theorem full_profile_cannot_locate (f : (ℕ → ℕ) → ℕ) :
    ¬ (∀ p q : ℕ, p.Prime → q.Prime → p < q →
        f (fun d => torsionCount (ZMod (p * q))ˣ (d + 1)) = p) := by
  intro hf
  have h1 : f (fun d => torsionCount (ZMod 35)ˣ (d + 1)) = 5 := by
    have := hf 5 7 (by norm_num) (by norm_num) (by norm_num)
    simpa [show (5:ℕ) * 7 = 35 by norm_num] using this
  have h2 : f (fun d => torsionCount (ZMod 39)ˣ (d + 1)) = 3 := by
    have := hf 3 13 (by norm_num) (by norm_num) (by norm_num)
    simpa [show (3:ℕ) * 13 = 39 by norm_num] using this
  rw [funext (fun d => torsionProfile_35_eq_39 (d + 1) (Nat.succ_ne_zero d))] at h1
  omega

end TropicalTorsionCensus