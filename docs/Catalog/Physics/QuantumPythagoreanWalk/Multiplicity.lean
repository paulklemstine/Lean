import Physics.QuantumPythagoreanWalk.Semiprime

/-!
# Quantum-Pythagorean-Walk — VIII. Resonance multiplicity detects primality

`Semiprime.lean` shows that a semiprime target `pq` carries **at least two** resonant nodes
and that their interference always collapses onto a factor.  This file proves the exact
complement: a **prime** target `p ≡ 1 (mod 4)` carries **exactly one** resonant node, so no
interference pair exists at all — the mechanism is arithmetically unable to "factor" a prime.

The two ingredients are

* `exists_repNode_of_isPPT` — the converse of `repNode_isPPT`: every node of the Berggren
  tree is `repNode m n` for a unique reduced Gaussian pair `m > n > 0`, obtained from
  Mathlib's classification of coprime Pythagorean triples;
* `prime_sq_add_sq_unique` — Euler's uniqueness theorem: a prime has essentially one
  representation as a sum of two squares.  The proof is the classical descent through
  `(ac+bd)(ac-bd) = p(a²-d²)` and the Brahmagupta identity `(ac±bd)² + (ad∓bc)² = p²`.

Together they give `exists_unique_resonant_word_of_prime` and the punchline
`resonance_multiplicity_detects_primality`: *the number of resonant walk words is `1` for a
prime and `> 1` for a semiprime*, so resonance multiplicity is a primality certificate.
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Every node is a reduced Gaussian pair -/

/-- A prime `p = a² + b²` forces `a` and `b` to be coprime. -/
theorem sq_add_sq_isCoprime_of_prime {p : ℕ} (hp : p.Prime) {a b : ℤ}
    (hab : a ^ 2 + b ^ 2 = (p : ℤ)) : IsCoprime a b := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  by_contra hne
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd hne
  have hrg : (r : ℤ) ∣ ((Int.gcd a b : ℕ) : ℤ) := Int.natCast_dvd_natCast.mpr hrd
  have hra : (r : ℤ) ∣ a := hrg.trans (Int.gcd_dvd_left _ _)
  have hrb : (r : ℤ) ∣ b := hrg.trans (Int.gcd_dvd_right _ _)
  have hr2 : ((r : ℤ)) ^ 2 ∣ (p : ℤ) := by
    have hdd : ((r : ℤ)) ^ 2 ∣ a ^ 2 + b ^ 2 :=
      dvd_add (pow_dvd_pow_of_dvd hra 2) (pow_dvd_pow_of_dvd hrb 2)
    rwa [hab] at hdd
  have hrp : (r : ℤ) ∣ (p : ℤ) := (dvd_pow_self (r : ℤ) two_ne_zero).trans hr2
  have hrpn : r = p := (hp.eq_one_or_self_of_dvd r (by exact_mod_cast hrp)).resolve_left hr.ne_one
  subst hrpn
  have hpos : (0 : ℤ) < (r : ℤ) := by exact_mod_cast hr.pos
  have hle := Int.le_of_dvd hpos hr2
  have h2 : (2 : ℤ) ≤ (r : ℤ) := by exact_mod_cast hr.two_le
  nlinarith

/-- **Converse of `repNode_isPPT`.**  Every node of the Berggren tree is the Gaussian square
`repNode m n` of a reduced coprime pair `m > n > 0`. -/
theorem exists_repNode_of_isPPT {t : Node} (ht : t.IsPPT) (hodd : t.a % 2 = 1) :
    ∃ m n : ℤ, 0 < n ∧ n < m ∧ IsCoprime m n ∧ t = repNode m n := by
  obtain ⟨ta, tb, tc⟩ := t
  simp only at hodd ⊢
  have hpt : PythagoreanTriple ta tb tc := by
    have := ht.pyth
    simp only at this
    unfold PythagoreanTriple
    nlinarith [this]
  have hg : Int.gcd ta tb = 1 := Int.isCoprime_iff_gcd_eq_one.mp ht.cop
  have hposb : 0 < tb := ht.pos_b
  have hposa : 0 < ta := ht.pos_a
  obtain ⟨m, n, ha, hb, hc, hmn, _hpar, hm0⟩ :=
    hpt.coprime_classification' hg hodd ht.pos_c
  have hnpos : 0 < n := by nlinarith [hb ▸ hposb]
  have hmpos : 0 < m := by nlinarith [hb ▸ hposb]
  have hnm : n < m := by nlinarith [ha ▸ hposa]
  exact ⟨m, n, hnpos, hnm, Int.isCoprime_iff_gcd_eq_one.mpr hmn, by
    simp only [repNode, Node.mk.injEq]
    exact ⟨ha, hb, hc⟩⟩

/-! ### Euler's uniqueness theorem -/

/-- **Uniqueness of the Gaussian representation of a prime.**  A prime is a sum of two
positive squares in essentially one way. -/
theorem prime_sq_add_sq_unique {p : ℕ} (hp : p.Prime) {a b c d : ℤ}
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hab : a ^ 2 + b ^ 2 = (p : ℤ)) (hcd : c ^ 2 + d ^ 2 = (p : ℤ)) :
    (a = c ∧ b = d) ∨ (a = d ∧ b = c) := by
  have hcop₁ : IsCoprime a b := sq_add_sq_isCoprime_of_prime hp hab
  have hcop₂ : IsCoprime c d := sq_add_sq_isCoprime_of_prime hp hcd
  have hprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hppos : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  -- `p` divides the product of the two cross terms
  have hsplit : (p : ℤ) ∣ (a * c + b * d) * (a * c - b * d) := by
    refine ⟨a ^ 2 - d ^ 2, ?_⟩
    have e : (a * c + b * d) * (a * c - b * d)
        = a ^ 2 * (c ^ 2 + d ^ 2) - d ^ 2 * (a ^ 2 + b ^ 2) := by ring
    rw [e, hab, hcd]; ring
  -- the two Brahmagupta identities
  have hpsq : ((p : ℤ)) ^ 2 = (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) := by rw [hab, hcd]; ring
  have hid₁ : (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 = (p : ℤ) ^ 2 := by
    rw [hpsq]; ring
  have hid₂ : (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 = (p : ℤ) ^ 2 := by
    rw [hpsq]; ring
  rcases hprime.dvd_mul.mp hsplit with h | h
  · -- `p ∣ ac + bd`, and `0 < ac + bd ≤ p`, so `ac + bd = p` and `ad = bc`
    have hpos : 0 < a * c + b * d := by positivity
    have hsq : (a * c + b * d) ^ 2 ≤ (p : ℤ) ^ 2 := by
      nlinarith [hid₁, sq_nonneg (a * d - b * c)]
    have hle : a * c + b * d ≤ (p : ℤ) := by nlinarith [hsq, hpos, hppos]
    have heq : a * c + b * d = (p : ℤ) := le_antisymm hle (Int.le_of_dvd hpos h)
    have hzero : a * d - b * c = 0 := by
      have : (a * d - b * c) ^ 2 = 0 := by nlinarith [hid₁, heq]
      exact pow_eq_zero_iff (n := 2) two_ne_zero |>.mp this
    obtain ⟨h1, h2⟩ := eq_of_cross_mul ha hc hcop₁ hcop₂ (by linarith)
    exact Or.inl ⟨h1, h2⟩
  · -- `p ∣ ac - bd`, and `|ac - bd| < p`, so `ac = bd`
    have hadbc : 0 < a * d + b * c := by positivity
    have hlt : (a * c - b * d) ^ 2 < (p : ℤ) ^ 2 := by
      nlinarith [hid₂, hadbc]
    obtain ⟨k, hk⟩ := h
    have hkbound : (p : ℤ) ^ 2 * k ^ 2 < (p : ℤ) ^ 2 := by
      have : ((p : ℤ) * k) ^ 2 < (p : ℤ) ^ 2 := by rw [← hk]; exact hlt
      nlinarith [this]
    have hk0 : k = 0 := by
      by_contra hkne
      have : 1 ≤ k ^ 2 := by
        rcases lt_trichotomy k 0 with h1 | h1 | h1
        · nlinarith
        · exact absurd h1 hkne
        · nlinarith
      nlinarith [hkbound, sq_nonneg ((p : ℤ)), hppos]
    have hzero : a * c - b * d = 0 := by rw [hk, hk0, mul_zero]
    obtain ⟨h1, h2⟩ := eq_of_cross_mul ha hd hcop₁ hcop₂.symm (by linarith)
    exact Or.inr ⟨h1, h2⟩

/-! ### One resonance for a prime, several for a semiprime -/

/-- Two nodes of the walk with the same *prime* hypotenuse coincide. -/
theorem node_unique_of_prime_hyp {p : ℕ} (hp : p.Prime) {t₁ t₂ : Node}
    (h₁ : t₁.IsPPT) (o₁ : t₁.a % 2 = 1) (c₁ : t₁.c = (p : ℤ))
    (h₂ : t₂.IsPPT) (o₂ : t₂.a % 2 = 1) (c₂ : t₂.c = (p : ℤ)) : t₁ = t₂ := by
  obtain ⟨m₁, n₁, hn₁, hnm₁, _, he₁⟩ := exists_repNode_of_isPPT h₁ o₁
  obtain ⟨m₂, n₂, hn₂, hnm₂, _, he₂⟩ := exists_repNode_of_isPPT h₂ o₂
  have hr₁ : m₁ ^ 2 + n₁ ^ 2 = (p : ℤ) := by rw [← c₁, he₁]; simp [repNode]
  have hr₂ : m₂ ^ 2 + n₂ ^ 2 = (p : ℤ) := by rw [← c₂, he₂]; simp [repNode]
  rcases prime_sq_add_sq_unique hp (by linarith) hn₁ (by linarith) hn₂ hr₁ hr₂ with
    ⟨e1, e2⟩ | ⟨e1, e2⟩
  · rw [he₁, he₂, e1, e2]
  · exfalso; omega

/-- **A prime target carries exactly one resonance.**  For a prime `p ≡ 1 (mod 4)` there is
a *unique* walk word whose node has hypotenuse exactly `p`; no interference pair exists. -/
theorem exists_unique_resonant_word_of_prime {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1) :
    ∃! w : List (Fin 3), (walk w).c = (p : ℤ) := by
  obtain ⟨x, y, hx, hy, hxy, hcxy⟩ := prime_sq_add_sq_pos hp hp4
  have hoddp : ((x : ℤ) ^ 2 + y ^ 2) % 2 = 1 := by rw [hxy]; omega
  obtain ⟨t, ht, htodd, htc, _, _⟩ :=
    node_of_primitive_rep' hx (ne_of_gt hy) hcxy hoddp
  obtain ⟨w, hw⟩ := exists_word_of_isPPT t ht htodd
  refine ⟨w, ?_, ?_⟩
  · show (walk w).c = (p : ℤ)
    rw [hw, htc, hxy]
  · intro w' hw'
    refine walk_injective ?_
    rw [hw]
    exact node_unique_of_prime_hyp hp (walk_isPPT w') (walk_odd_a w') hw' ht htodd
      (by rw [htc, hxy])

/-- **Resonance multiplicity is a primality certificate.**  For distinct primes
`p, q ≡ 1 (mod 4)`, the target `p` admits exactly one resonant word while the semiprime `pq`
admits more than one — so counting resonances distinguishes primes from semiprimes. -/
theorem resonance_multiplicity_detects_primality {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hpq : p ≠ q) :
    (∃! w : List (Fin 3), (walk w).c = (p : ℤ)) ∧
      ¬ (∃! w : List (Fin 3), (walk w).c = (p : ℤ) * q) := by
  refine ⟨exists_unique_resonant_word_of_prime hp hp4, ?_⟩
  rintro ⟨w, _, huniq⟩
  obtain ⟨w₁, w₂, hne, h₁, h₂⟩ := exists_two_resonant_words_of_semiprime hp hq hp4 hq4 hpq
  exact hne ((huniq w₁ h₁).trans (huniq w₂ h₂).symm)

end QuantumPythagoreanWalk