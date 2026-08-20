import Physics.QuantumPythagoreanWalk.Multiplicity

/-!
# Quantum-Pythagorean-Walk — X. A semiprime carries *exactly* two resonances

`Semiprime.lean` produces two resonant words for `N = pq`; `Multiplicity.lean` shows a prime
carries exactly one.  This file closes the count: a semiprime carries **exactly two**.

The engine is a descent (`rep_descent`): every representation `A² + B² = pq` is a
Brahmagupta composition of a representation of `p` with a representation of `q`.  Indeed
`p ∣ (Ay-Bx)(Ay+Bx)` whenever `p = x²+y²`, and dividing through by `p` in the Brahmagupta
identity `(Ay∓Bx)² + (Ax±By)² = p²q` produces `S, T` with `S² + T² = q` and
`A = xT ± yS`, `B = ±(yT ∓ xS)`.

Feeding Euler's uniqueness theorem for `q` into that descent pins the *odd leg* of a
resonant node to one of only two values (`odd_leg_cases_of_semiprime`), and a node of the
tree is determined by its odd leg and its hypotenuse (`node_eq_of_a_of_c`).  Hence there is
no third resonant word (`at_most_two_resonant_words`), which together with
`exists_two_resonant_words_of_semiprime` gives the exact count
(`exactly_two_resonant_words_of_semiprime`).
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Two elementary facts -/

/-- A positive integer whose square is `k²` is `|k|`. -/
private theorem eq_abs_of_pos_of_sq_eq {a k : ℤ} (ha : 0 < a) (h : a ^ 2 = k ^ 2) : a = |k| := by
  have h0 : (a - k) * (a + k) = 0 := by linear_combination h
  rcases mul_eq_zero.mp h0 with h1 | h1
  · rw [abs_of_pos (by omega : (0 : ℤ) < k)]; omega
  · rw [abs_of_neg (by omega : k < (0 : ℤ))]; omega

/-- A prime is not a perfect square. -/
private theorem prime_ne_sq {q : ℕ} (hq : q.Prime) (T : ℤ) : T ^ 2 ≠ (q : ℤ) := by
  intro h
  have hcast : ((T.natAbs : ℤ)) ^ 2 = (q : ℤ) := by
    rw [Int.natCast_natAbs, sq_abs]; exact h
  have hn : T.natAbs ^ 2 = q := by exact_mod_cast hcast
  have hdvd : T.natAbs ∣ q := ⟨T.natAbs, by rw [← hn]; ring⟩
  have h2 := hq.two_le
  rcases hq.eq_one_or_self_of_dvd _ hdvd with h1 | h1 <;> rw [h1] at hn <;> nlinarith

/-- A node of the tree is determined by its odd leg together with its hypotenuse. -/
theorem node_eq_of_a_of_c {t₁ t₂ : Node} (h₁ : t₁.IsPPT) (h₂ : t₂.IsPPT)
    (ha : t₁.a = t₂.a) (hc : t₁.c = t₂.c) : t₁ = t₂ := by
  have hb : t₁.b ^ 2 = t₂.b ^ 2 := by
    have e₁ := h₁.pyth
    have e₂ := h₂.pyth
    rw [ha, hc] at e₁
    linarith
  have hbe : t₁.b = t₂.b := by
    have := eq_abs_of_pos_of_sq_eq h₁.pos_b hb
    rwa [abs_of_pos h₂.pos_b] at this
  obtain ⟨a₁, b₁, c₁⟩ := t₁
  obtain ⟨a₂, b₂, c₂⟩ := t₂
  simp only [Node.mk.injEq]
  exact ⟨ha, hbe, hc⟩

/-! ### The descent: every representation of `pq` splits -/

/-- **Descent through a prime factor.**  If `p = x² + y²` is prime and `A² + B² = pq`, then
`(A, B)` is a Brahmagupta composition of `(x, y)` with some representation `S² + T² = q`. -/
theorem rep_descent {p : ℕ} (hp : p.Prime) {x y A B q : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hAB : A ^ 2 + B ^ 2 = (p : ℤ) * q) :
    ∃ S T : ℤ, S ^ 2 + T ^ 2 = q ∧
      ((A = x * T + y * S ∧ B = y * T - x * S) ∨
        (A = x * T - y * S ∧ B = -(y * T) - x * S)) := by
  have hprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hppos : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hpne : ((p : ℤ)) ≠ 0 := ne_of_gt hppos
  have hpne2 : ((p : ℤ)) ^ 2 ≠ 0 := pow_ne_zero 2 hpne
  have hsplit : (p : ℤ) ∣ (A * y - B * x) * (A * y + B * x) := by
    refine ⟨y ^ 2 * q - B ^ 2, ?_⟩
    have e : (A * y - B * x) * (A * y + B * x)
        = y ^ 2 * (A ^ 2 + B ^ 2) - B ^ 2 * (x ^ 2 + y ^ 2) := by ring
    rw [e, hAB, hxy]; ring
  rcases hprime.dvd_mul.mp hsplit with hd | hd
  · obtain ⟨S, hS⟩ := hd
    have hid : (A * y - B * x) ^ 2 + (A * x + B * y) ^ 2 = (p : ℤ) ^ 2 * q := by
      have e : (A * y - B * x) ^ 2 + (A * x + B * y) ^ 2
          = (A ^ 2 + B ^ 2) * (x ^ 2 + y ^ 2) := by ring
      rw [e, hAB, hxy]; ring
    have hsq : ((p : ℤ)) ^ 2 ∣ (A * x + B * y) ^ 2 :=
      ⟨q - S ^ 2, by linear_combination hid - ((A * y - B * x) + (p : ℤ) * S) * hS⟩
    obtain ⟨T, hT⟩ := (Int.pow_dvd_pow_iff two_ne_zero).mp hsq
    refine ⟨S, T, ?_, Or.inl ⟨?_, ?_⟩⟩
    · refine mul_left_cancel₀ hpne2 ?_
      linear_combination hid - ((A * y - B * x) + (p : ℤ) * S) * hS
        - ((A * x + B * y) + (p : ℤ) * T) * hT
    · refine mul_left_cancel₀ hpne ?_
      linear_combination x * hT + y * hS - A * hxy
    · refine mul_left_cancel₀ hpne ?_
      linear_combination y * hT - x * hS - B * hxy
  · obtain ⟨S', hS'⟩ := hd
    have hid : (A * y + B * x) ^ 2 + (A * x - B * y) ^ 2 = (p : ℤ) ^ 2 * q := by
      have e : (A * y + B * x) ^ 2 + (A * x - B * y) ^ 2
          = (A ^ 2 + B ^ 2) * (x ^ 2 + y ^ 2) := by ring
      rw [e, hAB, hxy]; ring
    have hsq : ((p : ℤ)) ^ 2 ∣ (A * x - B * y) ^ 2 :=
      ⟨q - S' ^ 2, by linear_combination hid - ((A * y + B * x) + (p : ℤ) * S') * hS'⟩
    obtain ⟨T, hT⟩ := (Int.pow_dvd_pow_iff two_ne_zero).mp hsq
    refine ⟨-S', T, ?_, Or.inr ⟨?_, ?_⟩⟩
    · refine mul_left_cancel₀ hpne2 ?_
      linear_combination hid - ((A * y + B * x) + (p : ℤ) * S') * hS'
        - ((A * x - B * y) + (p : ℤ) * T) * hT
    · refine mul_left_cancel₀ hpne ?_
      linear_combination x * hT + y * hS' - A * hxy
    · refine mul_left_cancel₀ hpne ?_
      linear_combination x * hS' - y * hT - B * hxy

/-! ### The odd leg of a resonant node takes only two values -/

/-- **Two-valued odd leg.**  For distinct primes `p = x²+y²` and `q = u²+v²`, the odd leg of
any node with hypotenuse `pq` is one of exactly two numbers, the two Brahmagupta legs. -/
theorem odd_leg_cases_of_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    {x y u v : ℤ} (hu : 0 < u) (hv : 0 < v)
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (huv : u ^ 2 + v ^ 2 = (q : ℤ))
    {t : Node} (ht : t.IsPPT) (hodd : t.a % 2 = 1) (htc : t.c = (p : ℤ) * q) :
    t.a = |(x * u + y * v) ^ 2 - (x * v - y * u) ^ 2| ∨
      t.a = |(x * u - y * v) ^ 2 - (x * v + y * u) ^ 2| := by
  obtain ⟨m, n, hn, hnm, _, hrep⟩ := exists_repNode_of_isPPT ht hodd
  have hta : t.a = m ^ 2 - n ^ 2 := by rw [hrep]; simp [repNode]
  have hmn : m ^ 2 + n ^ 2 = (p : ℤ) * q := by
    rw [← htc, hrep]; simp [repNode]
  obtain ⟨S, T, hST, hcase⟩ := rep_descent hp hxy hmn
  have hSne : S ≠ 0 := by
    rintro rfl
    exact prime_ne_sq hq T (by linarith)
  have hTne : T ≠ 0 := by
    rintro rfl
    exact prime_ne_sq hq S (by linarith)
  have habs : |S| ^ 2 + |T| ^ 2 = (q : ℤ) := by rw [sq_abs, sq_abs]; exact hST
  -- the odd leg as a polynomial in `S`, `T`
  have hexp : t.a = (x ^ 2 - y ^ 2) * (T ^ 2 - S ^ 2) + 4 * x * y * (S * T) ∨
      t.a = (x ^ 2 - y ^ 2) * (T ^ 2 - S ^ 2) - 4 * x * y * (S * T) := by
    rcases hcase with ⟨hA, hB⟩ | ⟨hA, hB⟩
    · exact Or.inl (by rw [hta, hA, hB]; ring)
    · exact Or.inr (by rw [hta, hA, hB]; ring)
  have hapos : 0 < t.a := ht.pos_a
  -- `(|S|, |T|)` is `(u, v)` or `(v, u)` by Euler uniqueness for `q`
  have hsq : S ^ 2 = u ^ 2 ∧ T ^ 2 = v ^ 2 ∨ S ^ 2 = v ^ 2 ∧ T ^ 2 = u ^ 2 := by
    rcases prime_sq_add_sq_unique hq (abs_pos.mpr hSne) (abs_pos.mpr hTne) hu hv habs huv with
      ⟨e1, e2⟩ | ⟨e1, e2⟩
    · exact Or.inl ⟨by rw [← sq_abs S, e1], by rw [← sq_abs T, e2]⟩
    · exact Or.inr ⟨by rw [← sq_abs S, e1], by rw [← sq_abs T, e2]⟩
  have hprod : (S * T) ^ 2 = (u * v) ^ 2 := by
    rcases hsq with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · have e : (S * T) ^ 2 = S ^ 2 * T ^ 2 := by ring
      rw [e, h1, h2]; ring
    · have e : (S * T) ^ 2 = S ^ 2 * T ^ 2 := by ring
      rw [e, h1, h2]; ring
  have hST' : S * T = u * v ∨ S * T = -(u * v) := by
    have h0 : (S * T - u * v) * (S * T + u * v) = 0 := by linear_combination hprod
    rcases mul_eq_zero.mp h0 with h | h
    · exact Or.inl (by omega)
    · exact Or.inr (by omega)
  have hkey : t.a ^ 2 = ((x * u + y * v) ^ 2 - (x * v - y * u) ^ 2) ^ 2 ∨
      t.a ^ 2 = ((x * u - y * v) ^ 2 - (x * v + y * u) ^ 2) ^ 2 := by
    rcases hsq with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rcases hexp with he | he <;>
      rcases hST' with hst | hst <;> rw [he, h1, h2, hst] <;>
      first
        | (left; ring1)
        | (right; ring1)
  rcases hkey with hk | hk
  · exact Or.inl (eq_abs_of_pos_of_sq_eq hapos hk)
  · exact Or.inr (eq_abs_of_pos_of_sq_eq hapos hk)

/-! ### Exactly two resonances -/

/-- **No third resonance.**  For distinct primes `p, q ≡ 1 (mod 4)` any three walk words with
hypotenuse `pq` contain a repetition. -/
theorem at_most_two_resonant_words {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) {w₁ w₂ w₃ : List (Fin 3)}
    (h₁ : (walk w₁).c = (p : ℤ) * q) (h₂ : (walk w₂).c = (p : ℤ) * q)
    (h₃ : (walk w₃).c = (p : ℤ) * q) :
    w₁ = w₂ ∨ w₁ = w₃ ∨ w₂ = w₃ := by
  obtain ⟨x, y, hx, hy, hxy, _⟩ := prime_sq_add_sq_pos hp hp4
  obtain ⟨u, v, hu, hv, huv, _⟩ := prime_sq_add_sq_pos hq hq4
  have key : ∀ w w' : List (Fin 3), (walk w).c = (p : ℤ) * q → (walk w').c = (p : ℤ) * q →
      (walk w).a = (walk w').a → w = w' := fun w w' hc hc' ha =>
    walk_injective (node_eq_of_a_of_c (walk_isPPT w) (walk_isPPT w') ha (by rw [hc, hc']))
  have ha₁ := odd_leg_cases_of_semiprime hp hq hu hv hxy huv (walk_isPPT w₁) (walk_odd_a w₁) h₁
  have ha₂ := odd_leg_cases_of_semiprime hp hq hu hv hxy huv (walk_isPPT w₂) (walk_odd_a w₂) h₂
  have ha₃ := odd_leg_cases_of_semiprime hp hq hu hv hxy huv (walk_isPPT w₃) (walk_odd_a w₃) h₃
  rcases ha₁ with e₁ | e₁ <;> rcases ha₂ with e₂ | e₂ <;> rcases ha₃ with e₃ | e₃ <;>
    first
      | exact Or.inl (key _ _ h₁ h₂ (e₁.trans e₂.symm))
      | exact Or.inr (Or.inl (key _ _ h₁ h₃ (e₁.trans e₃.symm)))
      | exact Or.inr (Or.inr (key _ _ h₂ h₃ (e₂.trans e₃.symm)))

/-- **Exact resonance multiplicity of a semiprime.**  For distinct primes `p, q ≡ 1 (mod 4)`
the Berggren walk contains exactly two words with hypotenuse `pq`. -/
theorem exactly_two_resonant_words_of_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hpq : p ≠ q) :
    ∃ w₁ w₂ : List (Fin 3), w₁ ≠ w₂ ∧
      ∀ w : List (Fin 3), (walk w).c = (p : ℤ) * q ↔ (w = w₁ ∨ w = w₂) := by
  obtain ⟨w₁, w₂, hne, hc₁, hc₂⟩ := exists_two_resonant_words_of_semiprime hp hq hp4 hq4 hpq
  refine ⟨w₁, w₂, hne, fun w => ⟨fun hw => ?_, ?_⟩⟩
  · rcases at_most_two_resonant_words hp hq hp4 hq4 hw hc₁ hc₂ with h | h | h
    · exact Or.inl h
    · exact Or.inr h
    · exact absurd h hne
  · rintro (rfl | rfl)
    · exact hc₁
    · exact hc₂


/-! ### Worked example: the resonance set of `65 = 5 · 13` -/

/-- The node `(33, 56, 65)` is reached by the word `[0, 2]`. -/
theorem walk_res₁ : walk [0, 2] = ⟨33, 56, 65⟩ := by decide

/-- The node `(63, 16, 65)` is reached by the word `[2, 2, 2]`. -/
theorem walk_res₂ : walk [2, 2, 2] = ⟨63, 16, 65⟩ := by decide

/-- **Sharp resonance set of `65`.**  Exactly two words of the Berggren walk have hypotenuse
`65`, namely `[0, 2]` and `[2, 2, 2]`; there is no other, at any depth. -/
theorem resonant_words_65 (w : List (Fin 3)) :
    (walk w).c = 65 ↔ (w = [0, 2] ∨ w = [2, 2, 2]) := by
  have h5 : Nat.Prime 5 := by norm_num
  have h13 : Nat.Prime 13 := by norm_num
  have e₁ : (walk [0, 2]).c = ((5 : ℕ) : ℤ) * ((13 : ℕ) : ℤ) := by rw [walk_res₁]; norm_num
  have e₂ : (walk [2, 2, 2]).c = ((5 : ℕ) : ℤ) * ((13 : ℕ) : ℤ) := by rw [walk_res₂]; norm_num
  constructor
  · intro hw
    have hw' : (walk w).c = ((5 : ℕ) : ℤ) * ((13 : ℕ) : ℤ) := by rw [hw]; norm_num
    rcases at_most_two_resonant_words h5 h13 (by norm_num) (by norm_num) hw' e₁ e₂ with
      h | h | h
    · exact Or.inl h
    · exact Or.inr h
    · exact absurd h (by decide)
  · rintro (rfl | rfl)
    · rw [walk_res₁]
    · rw [walk_res₂]

end QuantumPythagoreanWalk