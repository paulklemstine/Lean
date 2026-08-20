import Physics.QuantumPythagoreanWalk.Completeness
import Physics.QuantumPythagoreanWalk.Collapse

/-!
# Quantum-Pythagorean-Walk — VI. Exactly which targets resonate

`Collapse.lean` showed that a prime `p ≡ 3 (mod 4)` dividing `N` kills all resonances.
Here we prove the *exact* dichotomy, using the completeness of the walk:

> For odd `N > 1`, the walk possesses a resonant word for `N` **iff** `-1` is a square
> modulo `N` (`resonance_exists_iff_isSquare_neg_one`).

The hard direction is a construction: from `s² ≡ -1 (mod N)` with `s` chosen even (possible
because `N` is odd), the triple `(s²-1, 2s, s²+1)` is a primitive Pythagorean triple whose
hypotenuse is divisible by `N`, and by `exists_word_of_isPPT` it *is* a node of the walk.

We also record the classical Euler two-representation mechanism in walk language: two
essentially different primitive representations `N = u₁²+v₁² = u₂²+v₂²` give two nodes of
hypotenuse exactly `N`, and their interference collapses onto a factor of `N`.
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### Primitive representations give nodes -/

/-- The triple attached to a representation `N = u² + v²`. -/
def repNode (u v : ℤ) : Node := ⟨u ^ 2 - v ^ 2, 2 * u * v, u ^ 2 + v ^ 2⟩

@[simp] lemma repNode_a (u v : ℤ) : (repNode u v).a = u ^ 2 - v ^ 2 := rfl
@[simp] lemma repNode_b (u v : ℤ) : (repNode u v).b = 2 * u * v := rfl
@[simp] lemma repNode_c (u v : ℤ) : (repNode u v).c = u ^ 2 + v ^ 2 := rfl

/-- A primitive representation with opposite parities gives a primitive Pythagorean triple
with odd first leg — hence, by completeness, a node of the walk. -/
theorem repNode_isPPT {u v : ℤ} (hv : 0 < v) (huv : v < u) (hcop : IsCoprime u v)
    (hpar : (u + v) % 2 = 1) : (repNode u v).IsPPT ∧ (repNode u v).a % 2 = 1 := by
  have hu : 0 < u := lt_trans hv huv
  have hodd : (u ^ 2 - v ^ 2) % 2 = 1 := by
    have h2 : u % 2 = 0 ∧ v % 2 = 1 ∨ u % 2 = 1 ∧ v % 2 = 0 := by omega
    rcases h2 with ⟨h3, h4⟩ | ⟨h3, h4⟩ <;>
      · obtain ⟨k, hk⟩ : ∃ k, u = 2 * k + u % 2 := ⟨u / 2, by omega⟩
        obtain ⟨l, hl⟩ : ∃ l, v = 2 * l + v % 2 := ⟨v / 2, by omega⟩
        rw [hk, hl, h3, h4]
        ring_nf
        omega
  refine ⟨⟨by simp only [repNode_a, repNode_b, repNode_c]; ring, ?_, ?_, ?_, ?_⟩, hodd⟩
  · simp only [repNode_a]; nlinarith
  · simp only [repNode_b]; positivity
  · simp only [repNode_c]; positivity
  · -- coprimality of `u² - v²` and `2uv`
    simp only [repNode_a, repNode_b]
    rw [Int.isCoprime_iff_gcd_eq_one]
    by_contra hne
    obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd hne
    have hpprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
    have hpg : (p : ℤ) ∣ ((Int.gcd (u ^ 2 - v ^ 2) (2 * u * v) : ℕ) : ℤ) :=
      Int.natCast_dvd_natCast.mpr hpd
    have hpa : (p : ℤ) ∣ u ^ 2 - v ^ 2 := hpg.trans (Int.gcd_dvd_left _ _)
    have hpb : (p : ℤ) ∣ 2 * u * v := hpg.trans (Int.gcd_dvd_right _ _)
    have hp2 : ¬ ((p : ℤ) = 2) := by
      intro h2
      rw [h2] at hpa
      omega
    have hpuv : (p : ℤ) ∣ u ∨ (p : ℤ) ∣ v := by
      rcases hpprime.dvd_mul.mp hpb with h | h
      · rcases hpprime.dvd_mul.mp h with h' | h'
        · exfalso
          have hle : (p : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) h'
          have hge : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
          exact hp2 (by omega)
        · exact Or.inl h'
      · exact Or.inr h
    have hboth : (p : ℤ) ∣ u ∧ (p : ℤ) ∣ v := by
      rcases hpuv with h | h
      · refine ⟨h, ?_⟩
        have : (p : ℤ) ∣ v ^ 2 := by
          have : v ^ 2 = u ^ 2 - (u ^ 2 - v ^ 2) := by ring
          rw [this]
          exact dvd_sub (Dvd.dvd.pow h (by norm_num)) hpa
        exact hpprime.dvd_of_dvd_pow this
      · refine ⟨?_, h⟩
        have : (p : ℤ) ∣ u ^ 2 := by
          have : u ^ 2 = (u ^ 2 - v ^ 2) + v ^ 2 := by ring
          rw [this]
          exact dvd_add hpa (Dvd.dvd.pow h (by norm_num))
        exact hpprime.dvd_of_dvd_pow this
    have hunit := IsCoprime.isUnit_of_dvd' hcop hboth.1 hboth.2
    have hge : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
    rcases Int.isUnit_iff.mp hunit with h | h <;> omega

/-! ### The resonance dichotomy -/

/-- **Resonance existence.**  If `-1` is a square modulo an odd `N > 1`, the walk has a
resonant word for `N`. -/
theorem exists_resonant_word_of_isSquare_neg_one {N : ℤ} (hN : 1 < N) (hodd : N % 2 = 1)
    (hsq : IsSquare (-1 : ZMod N.natAbs)) :
    ∃ w : List (Fin 3), N ∣ (walk w).c ∧ (walk w).c ≤ (N - 1) ^ 2 + 1 := by
  haveI : NeZero N.natAbs := ⟨by omega⟩
  obtain ⟨y, hy⟩ := hsq
  have hmN : ((N.natAbs : ℤ)) = N := Int.natAbs_of_nonneg (by omega)
  have hval : ((y.val : ℤ)) < (N.natAbs : ℤ) := by exact_mod_cast ZMod.val_lt y
  have hval0 : (0 : ℤ) ≤ (y.val : ℤ) := Int.natCast_nonneg _
  have hdvd0 : N ∣ (y.val : ℤ) ^ 2 + 1 := by
    have hcast : ((((y.val : ℤ) ^ 2 + 1 : ℤ)) : ZMod N.natAbs) = 0 := by
      push_cast
      rw [ZMod.natCast_val, ZMod.cast_id, sq, ← hy]
      ring
    have hd := (ZMod.intCast_zmod_eq_zero_iff_dvd _ N.natAbs).mp hcast
    rwa [hmN] at hd
  -- replace the root by an even one, possible because `N` is odd
  obtain ⟨s, hseven, hs2, hsle, hsdvd⟩ :
      ∃ s : ℤ, s % 2 = 0 ∧ 2 ≤ s ∧ s ≤ N - 1 ∧ N ∣ s ^ 2 + 1 := by
    by_cases hpar : (y.val : ℤ) % 2 = 0
    · refine ⟨(y.val : ℤ), hpar, ?_, by omega, hdvd0⟩
      rcases eq_or_lt_of_le hval0 with h0 | h0
      · exfalso
        rw [← h0] at hdvd0
        norm_num at hdvd0
        have := Int.le_of_dvd (by norm_num) hdvd0
        omega
      · omega
    · refine ⟨N - (y.val : ℤ), by omega, by omega, by omega, ?_⟩
      obtain ⟨k, hk⟩ := hdvd0
      exact ⟨N - 2 * (y.val : ℤ) + k, by linear_combination hk⟩
  -- the primitive triple `(s² - 1, 2s, s² + 1)` is a node of the walk
  have hnode := repNode_isPPT (u := s) (v := 1) (by norm_num) (by omega)
    isCoprime_one_right (by omega)
  obtain ⟨w, hw⟩ := exists_word_of_isPPT (repNode s 1) hnode.1 hnode.2
  refine ⟨w, ?_, ?_⟩
  · rw [hw]
    simpa using hsdvd
  · rw [hw]
    simp only [repNode_c, one_pow]
    nlinarith

/-- **Resonance obstruction (converse).**  If some node of the walk is resonant for `N`,
then `-1` is a square modulo `N`. -/
theorem isSquare_neg_one_of_resonant {N : ℤ} {w : List (Fin 3)}
    (h : N ∣ (walk w).c) : IsSquare (-1 : ZMod N.natAbs) := by
  set t := walk w with ht
  have hp := walk_isPPT w
  have hsum : (t.c ^ 2 : ℤ) = t.a ^ 2 + t.b ^ 2 := hp.pyth.symm
  have h1 : IsSquare (-1 : ZMod ((t.c ^ 2 : ℤ)).natAbs) :=
    ZMod.isSquare_neg_one_of_eq_sq_add_sq_of_isCoprime hsum hp.cop
  have hdvd : N.natAbs ∣ ((t.c ^ 2 : ℤ)).natAbs := by
    have : N ∣ t.c ^ 2 := h.trans (dvd_pow_self _ (by norm_num))
    exact Int.natAbs_dvd_natAbs.mpr this
  exact ZMod.isSquare_neg_one_of_dvd hdvd h1

/-- **The resonance dichotomy.**  For odd `N > 1` the quantum Pythagorean walk resonates on
`N` exactly when `-1` is a quadratic residue mod `N`, i.e. exactly when every prime factor
of `N` is `≡ 1 (mod 4)`. -/
theorem resonance_exists_iff_isSquare_neg_one {N : ℤ} (hN : 1 < N) (hodd : N % 2 = 1) :
    (∃ w : List (Fin 3), N ∣ (walk w).c) ↔ IsSquare (-1 : ZMod N.natAbs) :=
  ⟨fun ⟨_, hw⟩ => isSquare_neg_one_of_resonant hw,
   fun hsq => (exists_resonant_word_of_isSquare_neg_one hN hodd hsq).imp fun _ h => h.1⟩

/-- **Resonance depth window.**  Whenever a resonance exists it is reached at a depth that
is *finite and explicitly bounded*: combining the descent bound `8·|w| + 5 ≤ c` with the
construction above, some resonant word has length at most `((N-1)² - 4)/8`.  Together with
`hilbert_dimension_lower_bound` this pins the resonance depth into the window
`log₇(N/5) ≤ n ≤ ((N-1)² - 4)/8`. -/
theorem exists_resonant_word_length_le {N : ℤ} (hN : 1 < N) (hodd : N % 2 = 1)
    (hsq : IsSquare (-1 : ZMod N.natAbs)) :
    ∃ w : List (Fin 3), N ∣ (walk w).c ∧ 8 * (w.length : ℤ) + 5 ≤ (N - 1) ^ 2 + 1 := by
  obtain ⟨w, hdvd, hle⟩ := exists_resonant_word_of_isSquare_neg_one hN hodd hsq
  exact ⟨w, hdvd, le_trans (hyp_walk_ge w) hle⟩

/-! ### Euler's two-representation method as tree interference -/

/-- Two essentially different primitive representations of `N` as a sum of two squares give
two nodes of the walk with hypotenuse exactly `N`, whose interference collapses onto a
proper nontrivial divisor of `N`.  (The non-degeneracy of the interference is the usual
hypothesis of the congruence-of-squares method.) -/
theorem euler_two_representations_collapse {N u₁ v₁ u₂ v₂ : ℤ} (hN : 1 < N)
    (h₁ : 0 < v₁) (h₁' : v₁ < u₁) (hc₁ : IsCoprime u₁ v₁) (hp₁ : (u₁ + v₁) % 2 = 1)
    (h₂ : 0 < v₂) (h₂' : v₂ < u₂) (hc₂ : IsCoprime u₂ v₂) (hp₂ : (u₂ + v₂) % 2 = 1)
    (hrep₁ : u₁ ^ 2 + v₁ ^ 2 = N) (hrep₂ : u₂ ^ 2 + v₂ ^ 2 = N)
    (hnd : ¬ N ∣ (u₁ ^ 2 - v₁ ^ 2) * (u₂ ^ 2 - v₂ ^ 2) - (2 * u₁ * v₁) * (2 * u₂ * v₂))
    (hnd' : ¬ N ∣ (u₁ ^ 2 - v₁ ^ 2) * (u₂ ^ 2 - v₂ ^ 2) + (2 * u₁ * v₁) * (2 * u₂ * v₂)) :
    1 < Int.gcd ((u₁ ^ 2 - v₁ ^ 2) * (u₂ ^ 2 - v₂ ^ 2) - (2 * u₁ * v₁) * (2 * u₂ * v₂)) N ∧
      (Int.gcd ((u₁ ^ 2 - v₁ ^ 2) * (u₂ ^ 2 - v₂ ^ 2)
        - (2 * u₁ * v₁) * (2 * u₂ * v₂)) N : ℤ) < N := by
  have hn₁ := (repNode_isPPT h₁ h₁' hc₁ hp₁).1
  have hn₂ := (repNode_isPPT h₂ h₂' hc₂ hp₂).1
  have hr₁ : N ∣ (repNode u₁ v₁).c := by rw [repNode_c, hrep₁]
  have hr₂ : N ∣ (repNode u₂ v₂).c := by rw [repNode_c, hrep₂]
  have hcol := resonance_collapse hN hn₁ hn₂ hr₁ hr₂ (by simpa using hnd) (by simpa using hnd')
  exact ⟨by simpa using hcol.1, by simpa using hcol.2.1⟩

/-- Euler's two representations `65 = 8² + 1² = 7² + 4²` give the two walk nodes
`(63,16,65)` and `(33,56,65)`, whose interference collapses onto the factor `13`. -/
theorem euler_collapse_65 :
    1 < Int.gcd ((8 ^ 2 - 1 ^ 2) * (7 ^ 2 - 4 ^ 2) - (2 * 8 * 1) * (2 * 7 * 4)) 65 ∧
      (Int.gcd ((8 ^ 2 - 1 ^ 2) * (7 ^ 2 - 4 ^ 2) - (2 * 8 * 1) * (2 * 7 * 4)) 65 : ℤ) < 65 :=
  euler_two_representations_collapse (N := 65) (u₁ := 8) (v₁ := 1) (u₂ := 7) (v₂ := 4)
    (by norm_num) (by norm_num) (by norm_num) isCoprime_one_right (by norm_num)
    (by norm_num) (by norm_num) (by rw [Int.isCoprime_iff_gcd_eq_one]; decide) (by norm_num)
    (by norm_num) (by norm_num) (by decide) (by decide)

/-- The value of that collapse is exactly the prime factor `13` of `65`. -/
theorem euler_collapse_65_value :
    Int.gcd ((8 ^ 2 - 1 ^ 2) * (7 ^ 2 - 4 ^ 2) - (2 * 8 * 1) * (2 * 7 * 4)) 65 = 13 := by
  decide

end QuantumPythagoreanWalk