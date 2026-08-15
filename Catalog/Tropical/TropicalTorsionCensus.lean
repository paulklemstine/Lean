import Mathlib

/-!
# The 2-Sylow torsion census is a tropical quadratic (TORCEN, closed)

This file formalises the mathematical content behind the round-4 closure of the
`TORCEN` hypothesis ("the 2-Sylow torsion census of `(ℤ/Nℤ)ˣ` leaks the factors of
a semiprime `N = p·q`"), and re-reads it through the min-plus (tropical) semiring.

For a semiprime `N = p q` with `p ≠ q` odd primes, the *torsion census* is

  `T(k) = #{x ∈ (ℤ/Nℤ)ˣ : x ^ (2 ^ k) = 1}`.

The two facts proved here are:

* **Exact census** (`torsionCensus_eq`): `T(k) = 2 ^ (min k a + min k b)` where
  `a = v₂(p-1)`, `b = v₂(q-1)`.
* **Tropicality** (`trop_censusExponent`): the exponent `min k a + min k b` is
  *exactly* the value at `k` of the tropical quadratic `(X ⊕ a) ⊙ (X ⊕ b)` in the
  min-plus semiring `Tropical (WithTop ℕ)`; its corner locus (tropical root set) is
  `{a, b}` (`isCensusCorner_iff`), and the census determines the unordered pair
  `{a,b}` (`census_determines_pair`).

The structural reason is that the 2-adic valuation is a semiring morphism from
`(ℕ_{≠0}, gcd, ·)` to the tropical semiring (`trop_factorization_two_gcd`,
`trop_factorization_two_mul`): the census is `gcd(p-1, 2^k)·gcd(q-1, 2^k)`, and
tropicalising turns the gcd's into tropical sums and the product into a tropical
product.

Finally we formalise *why the census does not factor `N`* (barrier 4, "sealing"):
the census depends only on the pair `{a,b}`, and two semiprimes with the same
2-adic fingerprint have literally the same census while having different factors
(`census_cannot_locate`). Locating, not counting, is the hard part.
-/

open Tropical

namespace TropicalTorsionCensus

/-! ## 1. Counting torsion in a finite abelian group -/

/-- `torsionCount G d` is the number of `d`-torsion elements of `G`. -/
noncomputable def torsionCount (G : Type*) [Group G] (d : ℕ) : ℕ :=
  Nat.card {x : G // x ^ d = 1}

lemma torsionCount_congr {G H : Type*} [Group G] [Group H] (e : G ≃* H) (d : ℕ) :
    torsionCount G d = torsionCount H d :=
  Nat.card_congr (Equiv.subtypeEquiv e.toEquiv (fun x => by
    show x ^ d = 1 ↔ (e x) ^ d = 1
    rw [← map_pow, ← map_one e, e.injective.eq_iff]))

/-- Torsion counting is multiplicative over direct products. -/
lemma torsionCount_prod (G H : Type*) [Group G] [Group H] (d : ℕ) :
    torsionCount (G × H) d = torsionCount G d * torsionCount H d := by
  simp only [torsionCount]
  rw [← Nat.card_prod]
  refine Nat.card_congr ⟨fun x => (⟨x.1.1, ?_⟩, ⟨x.1.2, ?_⟩), fun p => ⟨(p.1.1, p.2.1), ?_⟩,
    ?_, ?_⟩
  · have := x.2; rw [Prod.ext_iff] at this; exact this.1
  · have := x.2; rw [Prod.ext_iff] at this; exact this.2
  · rw [Prod.ext_iff]; exact ⟨p.1.2, p.2.2⟩
  · intro x; ext <;> rfl
  · intro p; ext <;> rfl

/-- In a finite cyclic group the number of `d`-torsion points is `gcd(|G|, d)`. -/
lemma torsionCount_cyclic (G : Type*) [CommGroup G] [IsCyclic G] [Finite G] (d : ℕ) :
    torsionCount G d = (Nat.card G).gcd d := by
  rw [← IsCyclic.card_powMonoidHom_ker G d]
  exact Nat.card_congr (Equiv.subtypeEquivRight (fun x => by
    simp [MonoidHom.mem_ker, powMonoidHom]))

/-! ## 2. The 2-adic valuation as a tropical (min-plus) semiring morphism -/

/-- `v₂ m`, the 2-adic valuation of a natural number. -/
def v2 (m : ℕ) : ℕ := m.factorization 2

lemma v2_pow_two (k : ℕ) : v2 (2 ^ k) = k := by
  rw [v2, Nat.Prime.factorization_pow Nat.prime_two]; simp

/-- The 2-adic valuation turns `gcd` into `min`: this is tropical addition. -/
lemma v2_gcd {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) : v2 (m.gcd n) = min (v2 m) (v2 n) := by
  have hfg := Nat.factorization_gcd hm hn
  have h := congrArg (fun f : ℕ →₀ ℕ => f 2) hfg
  simpa [v2, Finsupp.inf_apply] using h

/-- The 2-adic valuation turns multiplication into addition: this is tropical
multiplication. -/
lemma v2_mul {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) : v2 (m * n) = v2 m + v2 n := by
  have := Nat.factorization_mul hm hn
  have h := congrArg (fun f : ℕ →₀ ℕ => f 2) this
  simpa [v2] using h

/-- Tropical form of `v2_gcd`: `v₂` sends `gcd` to the tropical sum. -/
theorem trop_factorization_two_gcd {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) :
    trop ((v2 (m.gcd n) : ℕ) : WithTop ℕ)
      = trop ((v2 m : ℕ) : WithTop ℕ) + trop ((v2 n : ℕ) : WithTop ℕ) := by
  rw [← trop_min, v2_gcd hm hn]
  norm_cast

/-- Tropical form of `v2_mul`: `v₂` sends products to tropical products. -/
theorem trop_factorization_two_mul {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) :
    trop ((v2 (m * n) : ℕ) : WithTop ℕ)
      = trop ((v2 m : ℕ) : WithTop ℕ) * trop ((v2 n : ℕ) : WithTop ℕ) := by
  rw [← trop_add, v2_mul hm hn]
  norm_cast

/-- `gcd(m, 2^k) = 2 ^ min (v₂ m) k`: the 2-part of `m` truncated at level `k`. -/
lemma gcd_two_pow_eq (m k : ℕ) (hm : m ≠ 0) : m.gcd (2 ^ k) = 2 ^ min (v2 m) k := by
  have hdvd : m.gcd (2 ^ k) ∣ 2 ^ k := Nat.gcd_dvd_right _ _
  obtain ⟨j, _, hj⟩ := (Nat.dvd_prime_pow Nat.prime_two).mp hdvd
  have h2 : (2:ℕ) ^ k ≠ 0 := by positivity
  have hj2 : j = min (v2 m) k := by
    have := v2_gcd hm h2
    rw [hj, v2_pow_two, v2_pow_two] at this
    exact this
  rw [hj, hj2]

/-- A convenient criterion for computing `v₂`. -/
lemma v2_eq_of (m j : ℕ) (hm : m ≠ 0) (h1 : 2 ^ j ∣ m) (h2 : ¬ (2 ^ (j + 1) ∣ m)) :
    v2 m = j := by
  have hle : j ≤ v2 m := (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hm).mp h1
  have hlt : ¬ (j + 1 ≤ v2 m) := fun h =>
    h2 ((Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hm).mpr h)
  omega

/-! ## 3. The exact torsion census of a semiprime -/

/-- The `d`-torsion count of `(ℤ/pqℤ)ˣ` for distinct primes `p, q`. -/
theorem torsionCount_units_semiprime (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (d : ℕ) :
    torsionCount (ZMod (p * q))ˣ d = (p - 1).gcd d * (q - 1).gcd d := by
  haveI := Fact.mk hp
  haveI := Fact.mk hq
  have hcop : p.Coprime q := (Nat.coprime_primes hp hq).mpr hpq
  have e : (ZMod (p * q))ˣ ≃* (ZMod p)ˣ × (ZMod q)ˣ :=
    (Units.mapEquiv (ZMod.chineseRemainder hcop).toMulEquiv).trans MulEquiv.prodUnits
  rw [torsionCount_congr e d, torsionCount_prod, torsionCount_cyclic, torsionCount_cyclic]
  have hcp : Nat.card (ZMod p)ˣ = p - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hp]
  have hcq : Nat.card (ZMod q)ˣ = q - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hq]
  rw [hcp, hcq]

/-- The 2-Sylow torsion census of `N = p q`. -/
noncomputable def torsionCensus (N : ℕ) (k : ℕ) : ℕ := torsionCount (ZMod N)ˣ (2 ^ k)

/-- The census exponent: `min k a + min k b`. -/
def censusExponent (a b k : ℕ) : ℕ := min k a + min k b

/-- **Exact 2-Sylow torsion census.** For a semiprime `N = pq` with distinct primes,
`#{x : x ^ (2^k) = 1} = 2 ^ (min k a + min k b)` with `a = v₂(p-1)`, `b = v₂(q-1)`. -/
theorem torsionCensus_eq (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (k : ℕ) :
    torsionCensus (p * q) k = 2 ^ censusExponent (v2 (p - 1)) (v2 (q - 1)) k := by
  have hp1 : p - 1 ≠ 0 := by have := hp.two_le; omega
  have hq1 : q - 1 ≠ 0 := by have := hq.two_le; omega
  rw [torsionCensus, torsionCount_units_semiprime p q hp hq hpq,
    gcd_two_pow_eq _ _ hp1, gcd_two_pow_eq _ _ hq1, ← pow_add, censusExponent]
  ring_nf
  rw [Nat.min_comm (v2 (p-1)) k, Nat.min_comm (v2 (q-1)) k]

/-! ## 4. The census exponent is a tropical quadratic -/

/-- **Tropicality of the census.** The census exponent is the value at `k` of the
tropical quadratic `(X ⊕ a) ⊙ (X ⊕ b)` in the min-plus semiring. -/
theorem trop_censusExponent (a b k : ℕ) :
    trop ((censusExponent a b k : ℕ) : WithTop ℕ)
      = (trop ((k : ℕ) : WithTop ℕ) + trop ((a : ℕ) : WithTop ℕ)) *
        (trop ((k : ℕ) : WithTop ℕ) + trop ((b : ℕ) : WithTop ℕ)) := by
  rw [← trop_min, ← trop_min, ← trop_add, censusExponent]
  norm_cast

/-- Expanding the tropical product into monomials: `(X ⊕ a)(X ⊕ b) = X² ⊕ (a⊕b)X ⊕ ab`. -/
theorem censusExponent_expand (a b k : ℕ) :
    censusExponent a b k = min (min (2 * k) (min a b + k)) (a + b) := by
  simp only [censusExponent]; omega

/-- The three tropical monomials of the census quadratic, evaluated at `x`. -/
def censusMonomial (a b x : ℕ) : Fin 3 → ℕ
  | 0 => 2 * x
  | 1 => min a b + x
  | 2 => a + b

/-- `x` is in the corner locus (tropical root set) of the census quadratic when the
minimum over the monomials is attained at least twice. -/
def IsCensusCorner (a b x : ℕ) : Prop :=
  ∃ i j : Fin 3, i ≠ j ∧ censusMonomial a b x i = censusMonomial a b x j ∧
    ∀ l, censusMonomial a b x i ≤ censusMonomial a b x l

/-- **Corner locus of the census quadratic.** The tropical roots of
`(X ⊕ a) ⊙ (X ⊕ b)` are exactly `a` and `b`: the 2-adic fingerprint of the
semiprime is the corner locus of its census. -/
theorem isCensusCorner_iff (a b x : ℕ) : IsCensusCorner a b x ↔ x = a ∨ x = b := by
  constructor
  · rintro ⟨i, j, hij, h1, h2⟩
    have e0 := h2 0
    have e1 := h2 1
    have e2 := h2 2
    fin_cases i <;> fin_cases j <;>
      simp_all [censusMonomial] <;> omega
  · intro hx
    rcases le_total a b with hab | hab
    · rcases hx with rfl | rfl
      · refine ⟨0, 1, by decide, ?_, ?_⟩
        · simp only [censusMonomial]; omega
        · intro l; fin_cases l <;> simp only [censusMonomial] <;> omega
      · refine ⟨1, 2, by decide, ?_, ?_⟩
        · simp only [censusMonomial]; omega
        · intro l; fin_cases l <;> simp only [censusMonomial] <;> omega
    · rcases hx with rfl | rfl
      · refine ⟨1, 2, by decide, ?_, ?_⟩
        · simp only [censusMonomial]; omega
        · intro l; fin_cases l <;> simp only [censusMonomial] <;> omega
      · refine ⟨0, 1, by decide, ?_, ?_⟩
        · simp only [censusMonomial]; omega
        · intro l; fin_cases l <;> simp only [censusMonomial] <;> omega

/-- The census jumps: the discrete derivative of the exponent counts how many of
`a, b` still exceed `k`. This is the piecewise-linear (tropical) slope. -/
theorem censusExponent_jump (a b k : ℕ) :
    censusExponent a b (k + 1) - censusExponent a b k
      = (if k < a then 1 else 0) + (if k < b then 1 else 0) := by
  simp only [censusExponent]
  split_ifs <;> omega

/-- **The census determines the 2-adic fingerprint.** If two semiprimes have the same
census exponent function, their fingerprints agree as unordered pairs. -/
theorem census_determines_pair (a b a' b' : ℕ)
    (h : ∀ k, censusExponent a b k = censusExponent a' b' k) :
    (a = a' ∧ b = b') ∨ (a = b' ∧ b = a') := by
  simp only [censusExponent] at h
  have h1 := h a
  have h2 := h b
  have h3 := h a'
  have h4 := h b'
  have h5 := h (a + b + a' + b')
  omega

/-! ## 5. Sealing: the census counts, it does not locate (barrier 4) -/

lemma v2_two : v2 2 = 1 := v2_eq_of 2 1 (by norm_num) (by norm_num) (by decide)

lemma v2_six : v2 6 = 1 := v2_eq_of 6 1 (by norm_num) (by norm_num) (by decide)

lemma v2_ten : v2 10 = 1 := v2_eq_of 10 1 (by norm_num) (by norm_num) (by decide)

/-- The semiprimes `21 = 3·7` and `77 = 7·11` have *identical* torsion censuses. -/
theorem census_21_eq_census_77 (k : ℕ) : torsionCensus 21 k = torsionCensus 77 k := by
  have h21 : torsionCensus (3 * 7) k = 2 ^ censusExponent (v2 2) (v2 6) k :=
    torsionCensus_eq 3 7 (by norm_num) (by norm_num) (by norm_num) k
  have h77 : torsionCensus (7 * 11) k = 2 ^ censusExponent (v2 6) (v2 10) k :=
    torsionCensus_eq 7 11 (by norm_num) (by norm_num) (by norm_num) k
  norm_num [v2_two, v2_six, v2_ten] at h21 h77
  rw [show (21:ℕ) = 3 * 7 by norm_num, show (77:ℕ) = 7 * 11 by norm_num, h21, h77]

/-- **Sealing theorem (barrier 4).** No function of the torsion census can return the
smaller prime factor of a semiprime: the census of `21 = 3·7` and of `77 = 7·11`
coincide, but their smaller factors differ. The census counts; it cannot locate. -/
theorem census_cannot_locate (f : (ℕ → ℕ) → ℕ) :
    ¬ (∀ p q : ℕ, p.Prime → q.Prime → p < q → f (fun k => torsionCensus (p * q) k) = p) := by
  intro hf
  have h1 : f (fun k => torsionCensus 21 k) = 3 := by
    have := hf 3 7 (by norm_num) (by norm_num) (by norm_num)
    simpa [show (3:ℕ) * 7 = 21 by norm_num] using this
  have h2 : f (fun k => torsionCensus 77 k) = 7 := by
    have := hf 7 11 (by norm_num) (by norm_num) (by norm_num)
    simpa [show (7:ℕ) * 11 = 77 by norm_num] using this
  rw [funext census_21_eq_census_77] at h1
  omega

end TropicalTorsionCensus