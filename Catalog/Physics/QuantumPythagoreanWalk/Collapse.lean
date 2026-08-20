import Physics.QuantumPythagoreanWalk.Walk

/-!
# Quantum-Pythagorean-Walk — III. Collapse of a resonant pair onto a factor of `N`

This is the arithmetic heart of the programme.  Two *resonant* nodes of the Berggren tree,
i.e. two nodes `(a₁,b₁,c₁)`, `(a₂,b₂,c₂)` with `N ∣ c₁` and `N ∣ c₂`, interfere: because
`aᵢ² ≡ -bᵢ² (mod N)` the products satisfy the congruence of squares

`(a₁a₂)² ≡ (b₁b₂)²  (mod N)`,

which is the identity `a₁²a₂² - b₁²b₂² = a₂²c₁² - b₁²c₂²` (`resonant_pair_congruence`).
Whenever the pair is *non-degenerate* — the two square roots are not congruent up to sign —
`gcd(a₁a₂ - b₁b₂, N)` is a **proper nontrivial divisor of `N`**: the measurement collapses
the walk onto a factor (`resonance_collapse`).

We also record:

* the exact obstruction (`no_resonance_of_prime_three_mod_four`): if any prime `p ≡ 3 (mod 4)`
  divides `N`, *no* node of the tree is resonant, so the mechanism is confined to targets
  built from primes `≡ 1 (mod 4)` — a sharp boundary on the "factor anything" claim;
* a fully verified instance for `N = 65` reached by two explicit walk words, where the
  collapse returns the factor `13`.
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Congruence of squares ⇒ a nontrivial factor -/

/-- **Congruence of squares.**  If `x² ≡ y² (mod N)` while `x ≢ ±y (mod N)`, then
`gcd(x - y, N)` is a proper nontrivial divisor of `N`. -/
theorem sq_congruence_gives_factor {N x y : ℤ} (hN : 1 < N) (hsq : N ∣ x ^ 2 - y ^ 2)
    (hne : ¬ N ∣ x - y) (hne' : ¬ N ∣ x + y) :
    1 < Int.gcd (x - y) N ∧ (Int.gcd (x - y) N : ℤ) < N ∧ (Int.gcd (x - y) N : ℤ) ∣ N := by
  set g : ℕ := Int.gcd (x - y) N with hg
  have hdvdN : (g : ℤ) ∣ N := Int.gcd_dvd_right _ _
  have hgpos : 0 < g := by
    rcases Nat.eq_zero_or_pos g with h0 | h
    · exfalso
      have : N = 0 := by
        have := Int.gcd_eq_zero_iff.mp h0
        exact this.2
      omega
    · exact h
  refine ⟨?_, ?_, hdvdN⟩
  · -- `g = 1` would force `N ∣ x + y`
    by_contra hle
    have hg1 : g = 1 := by omega
    have hcop : IsCoprime (x - y) N := Int.isCoprime_iff_gcd_eq_one.mpr hg1
    have hmul : N ∣ (x - y) * (x + y) := by
      have : (x - y) * (x + y) = x ^ 2 - y ^ 2 := by ring
      rwa [this]
    exact hne' (hcop.symm.dvd_of_dvd_mul_left hmul)
  · -- `g = N` would force `N ∣ x - y`
    rcases lt_trichotomy ((g : ℤ)) N with h | h | h
    · exact h
    · exact absurd (h ▸ (Int.gcd_dvd_left (x - y) N)) hne
    · exfalso
      have hNpos : 0 < N := by omega
      have := Int.le_of_dvd hNpos hdvdN
      omega

/-! ### Interference of two resonances -/

/-- **Resonant interference identity.**  Two nodes whose hypotenuses are divisible by `N`
produce a congruence of squares modulo `N`. -/
theorem resonant_pair_congruence {N : ℤ} {t₁ t₂ : Node}
    (h₁ : t₁.a ^ 2 + t₁.b ^ 2 = t₁.c ^ 2) (h₂ : t₂.a ^ 2 + t₂.b ^ 2 = t₂.c ^ 2)
    (hr₁ : N ∣ t₁.c) (hr₂ : N ∣ t₂.c) :
    N ∣ (t₁.a * t₂.a) ^ 2 - (t₁.b * t₂.b) ^ 2 := by
  obtain ⟨u, hu⟩ := hr₁
  obtain ⟨v, hv⟩ := hr₂
  refine ⟨t₂.a ^ 2 * (N * u ^ 2) - t₁.b ^ 2 * (N * v ^ 2), ?_⟩
  have e₁ : t₁.c ^ 2 = N ^ 2 * u ^ 2 := by rw [hu]; ring
  have e₂ : t₂.c ^ 2 = N ^ 2 * v ^ 2 := by rw [hv]; ring
  have key : (t₁.a * t₂.a) ^ 2 - (t₁.b * t₂.b) ^ 2
      = t₂.a ^ 2 * t₁.c ^ 2 - t₁.b ^ 2 * t₂.c ^ 2 := by
    have : t₁.a ^ 2 = t₁.c ^ 2 - t₁.b ^ 2 := by linarith
    have h2 : t₂.b ^ 2 = t₂.c ^ 2 - t₂.a ^ 2 := by linarith
    rw [mul_pow, mul_pow, this, h2]; ring
  rw [key, e₁, e₂]; ring

/-- **Resonance collapse.**  A non-degenerate pair of resonant nodes yields an explicit
proper nontrivial divisor of the target `N`. -/
theorem resonance_collapse {N : ℤ} {t₁ t₂ : Node} (hN : 1 < N)
    (hp₁ : t₁.IsPPT) (hp₂ : t₂.IsPPT) (hr₁ : N ∣ t₁.c) (hr₂ : N ∣ t₂.c)
    (hne : ¬ N ∣ t₁.a * t₂.a - t₁.b * t₂.b) (hne' : ¬ N ∣ t₁.a * t₂.a + t₁.b * t₂.b) :
    1 < Int.gcd (t₁.a * t₂.a - t₁.b * t₂.b) N ∧
      (Int.gcd (t₁.a * t₂.a - t₁.b * t₂.b) N : ℤ) < N ∧
      (Int.gcd (t₁.a * t₂.a - t₁.b * t₂.b) N : ℤ) ∣ N :=
  sq_congruence_gives_factor hN
    (resonant_pair_congruence hp₁.pyth hp₂.pyth hr₁ hr₂) hne hne'

/-- In particular `N` is composite as soon as a non-degenerate resonant pair exists. -/
theorem not_prime_of_nondegenerate_resonant_pair {N : ℤ} {t₁ t₂ : Node} (hN : 1 < N)
    (hp₁ : t₁.IsPPT) (hp₂ : t₂.IsPPT) (hr₁ : N ∣ t₁.c) (hr₂ : N ∣ t₂.c)
    (hne : ¬ N ∣ t₁.a * t₂.a - t₁.b * t₂.b) (hne' : ¬ N ∣ t₁.a * t₂.a + t₁.b * t₂.b) :
    ¬ Prime N := by
  obtain ⟨h1, h2, h3⟩ := resonance_collapse hN hp₁ hp₂ hr₁ hr₂ hne hne'
  intro hprime
  have hNnat : (N.natAbs).Prime := Int.prime_iff_natAbs_prime.mp hprime
  have hgd : Int.gcd (t₁.a * t₂.a - t₁.b * t₂.b) N ∣ N.natAbs := by
    simpa using Int.natAbs_dvd_natAbs.mpr h3
  rcases (Nat.Prime.eq_one_or_self_of_dvd hNnat _ hgd) with h | h
  · omega
  · have hNabs : (N.natAbs : ℤ) = N := Int.natAbs_of_nonneg (by omega)
    omega

/-! ### The arithmetic obstruction: primes `≡ 3 (mod 4)` are invisible to the walk -/

/-- No hypotenuse of a primitive Pythagorean triple is divisible by a prime `p ≡ 3 (mod 4)`;
consequently no node of the Berggren tree is resonant for such a target. -/
theorem no_resonance_of_prime_three_mod_four {p : ℕ} (hp : p.Prime) (hp3 : p % 4 = 3)
    {t : Node} (ht : t.IsPPT) : ¬ ((p : ℤ) ∣ t.c) := by
  intro hdvd
  haveI : Fact p.Prime := ⟨hp⟩
  -- `-1` is a square modulo `c²`, hence modulo `p`
  have hsum : (t.c ^ 2 : ℤ) = t.a ^ 2 + t.b ^ 2 := ht.pyth.symm
  have h1 : IsSquare (-1 : ZMod ((t.c ^ 2 : ℤ)).natAbs) :=
    ZMod.isSquare_neg_one_of_eq_sq_add_sq_of_isCoprime hsum ht.cop
  have hpd : p ∣ ((t.c ^ 2 : ℤ)).natAbs := by
    have : (p : ℤ) ∣ t.c ^ 2 := Dvd.dvd.pow hdvd (by norm_num)
    have h2 := Int.natAbs_dvd_natAbs.mpr this
    simpa using h2
  have h2 : IsSquare (-1 : ZMod p) := by
    have h3 := h1.map (ZMod.castHom hpd (ZMod p))
    rwa [RingHom.map_neg, RingHom.map_one] at h3
  exact (ZMod.exists_sq_eq_neg_one_iff.mp h2) hp3

/-- Sharper form: if any prime `p ≡ 3 (mod 4)` divides `N`, the resonance set of the walk
is empty at every depth — the tree-resonance mechanism is *structurally blind* to such `N`. -/
theorem resonanceSet_eq_empty_of_prime_three_mod_four {p : ℕ} (hp : p.Prime) (hp3 : p % 4 = 3)
    {N : ℤ} (hpN : (p : ℤ) ∣ N) (n : ℕ) : resonanceSet N n = ∅ := by
  ext w
  simp only [resonanceSet, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.notMem_empty, iff_false]
  intro hdvd
  exact no_resonance_of_prime_three_mod_four hp hp3 (walk_isPPT (wordOf w)) (hpN.trans hdvd)

/-! ### A fully verified collapse: `N = 65 = 5 · 13` -/

/-- The walk word `[1,0,0,0,0]` reaches the node `(253, 204, 325)`, resonant for `65`. -/
theorem walk_word₁ : walk [1, 0, 0, 0, 0] = ⟨253, 204, 325⟩ := by decide

/-- The walk word `[2,2,1,1,0]` reaches the node `(2537, 816, 2665)`, resonant for `65`. -/
theorem walk_word₂ : walk [2, 2, 1, 1, 0] = ⟨2537, 816, 2665⟩ := by decide

/-- Both endpoints are resonant for `N = 65`. -/
theorem resonant_65 : (65 : ℤ) ∣ (walk [1, 0, 0, 0, 0]).c ∧ (65 : ℤ) ∣ (walk [2, 2, 1, 1, 0]).c := by
  rw [walk_word₁, walk_word₂]
  exact ⟨⟨5, by norm_num⟩, ⟨41, by norm_num⟩⟩

/-- **Worked collapse.**  Interfering the two resonant branches above produces the factor
`13` of `65`; the mechanism is therefore not vacuous. -/
theorem collapse_65 :
    Int.gcd ((walk [1, 0, 0, 0, 0]).a * (walk [2, 2, 1, 1, 0]).a
      - (walk [1, 0, 0, 0, 0]).b * (walk [2, 2, 1, 1, 0]).b) 65 = 13 := by
  rw [walk_word₁, walk_word₂]
  decide

/-- …and the general collapse theorem indeed certifies it as a proper nontrivial divisor. -/
theorem collapse_65_nontrivial :
    1 < Int.gcd ((walk [1, 0, 0, 0, 0]).a * (walk [2, 2, 1, 1, 0]).a
        - (walk [1, 0, 0, 0, 0]).b * (walk [2, 2, 1, 1, 0]).b) 65 ∧
      (Int.gcd ((walk [1, 0, 0, 0, 0]).a * (walk [2, 2, 1, 1, 0]).a
        - (walk [1, 0, 0, 0, 0]).b * (walk [2, 2, 1, 1, 0]).b) 65 : ℤ) < 65 := by
  refine resonance_collapse (by norm_num) (walk_isPPT _) (walk_isPPT _)
    resonant_65.1 resonant_65.2 ?_ ?_ |>.imp id (fun h => h.1)
  · rw [walk_word₁, walk_word₂]; decide
  · rw [walk_word₁, walk_word₂]; decide

end QuantumPythagoreanWalk