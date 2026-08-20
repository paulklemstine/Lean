import Physics.QuantumPythagoreanWalk.PrimePower

/-!
# Quantum-Pythagorean-Walk — XV. The Gaussian sign class and the `ω = 3` count

`PrimePower.lean` proves `r(p^k) = 1` and `ExactMultiplicity.lean` proves `r(pq) = 2`.  The
remaining open case of the multiplicity formula `r(N) = 2^{ω(N)-1}` is `ω = 3`.  This file
develops the invariant that controls it.

For a prime `P = x² + y²` and a primitive pair `(A, B)` with `P ∣ A² + B²`, exactly one of

`P ∣ xA - yB`  or  `P ∣ xA + yB`

holds (`gsign_eq_false_iff`); the choice is the *Gaussian sign* `gsign x y P A B` — which of
the two conjugate Gaussian primes above `P` divides `A + iB`.  Two representations of the
same modulus interact through their signs:

* equal signs at `P` force `P ∣ AB' - A'B` (`dvd_sub_cross_of_gsign_eq`);
* different signs at `P` force `P ∣ AB' + A'B` (`dvd_add_cross_of_gsign_ne`).

For `N = pqr` the flip-invariant *class* `(σ_p ≠ σ_q, σ_p ≠ σ_r) ∈ Bool × Bool` therefore
determines the representation: equal classes make the whole of `N` divide one cross term, and
`rep_eq_of_dvd_cross` then identifies the two representations up to order and sign
(`rep_eq_of_gclass_eq`).  Since `Bool × Bool` has four elements, this bounds the resonance
multiplicity: **`r(pqr) ≤ 4`** (`at_most_four_resonant_words`).
-/

namespace QuantumPythagoreanWalk

open Node

/-! ### The Gaussian sign -/

/-- The Gaussian sign of the pair `(A, B)` at a prime `P = x² + y²`: `true` when the
"minus" branch `P ∣ xA - yB` holds. -/
def gsign (x y P A B : ℤ) : Bool := decide (P ∣ x * A - y * B)

theorem gsign_eq_true_iff (x y P A B : ℤ) :
    gsign x y P A B = true ↔ P ∣ x * A - y * B := by
  simp [gsign]

/-- The two branches are exclusive and exhaustive: if the minus branch fails, the plus
branch holds. -/
theorem gsign_eq_false_iff {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) :
    gsign x y (p : ℤ) A B = false ↔ (p : ℤ) ∣ x * A + y * B := by
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hpx : ¬ ((p : ℤ) ∣ x) := prime_not_dvd_coord hp hxy
  have hprod : (p : ℤ) ∣ (x * A - y * B) * (x * A + y * B) := by
    have e : (x * A - y * B) * (x * A + y * B)
        = (x ^ 2 + y ^ 2) * A ^ 2 - y ^ 2 * (A ^ 2 + B ^ 2) := by ring
    rw [e, hxy]
    exact dvd_sub ⟨A ^ 2, by ring⟩ (hdvd.mul_left _)
  have hp2 : ¬ ((p : ℤ) ∣ 2) := by
    intro hd
    have hle : (p : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) hd
    have h2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
    exact hne2 (by omega)
  have hnotboth : ¬ ((p : ℤ) ∣ x * A - y * B ∧ (p : ℤ) ∣ x * A + y * B) := by
    rintro ⟨h₁, h₂⟩
    have h2x : (p : ℤ) ∣ 2 * (x * A) := by
      have e : 2 * (x * A) = (x * A - y * B) + (x * A + y * B) := by ring
      rw [e]; exact dvd_add h₁ h₂
    have hA : (p : ℤ) ∣ A := by
      rcases hpZ.dvd_mul.mp h2x with h | h
      · exact absurd h hp2
      · exact (hpZ.dvd_mul.mp h).resolve_left hpx
    have hB : (p : ℤ) ∣ B := by
      refine hpZ.dvd_of_dvd_pow (n := 2) ?_
      have e : B ^ 2 = (A ^ 2 + B ^ 2) - A ^ 2 := by ring
      rw [e]
      exact dvd_sub hdvd (Dvd.dvd.pow hA two_ne_zero)
    exact hpZ.not_unit (hcop.isUnit_of_dvd' hA hB)
  constructor
  · intro hfalse
    have h₁ : ¬ ((p : ℤ) ∣ x * A - y * B) := by
      rw [← gsign_eq_true_iff x y (p : ℤ) A B, hfalse]
      simp
    exact (hpZ.dvd_mul.mp hprod).resolve_left h₁
  · intro h₂
    by_contra hne
    have h₁ : (p : ℤ) ∣ x * A - y * B := by
      rw [← gsign_eq_true_iff x y (p : ℤ) A B]
      simpa using hne
    exact hnotboth ⟨h₁, h₂⟩

/-! ### How two representations interact through their signs -/

/-- Equal Gaussian signs at `p` force `p` to divide the *difference* cross term. -/
theorem dvd_sub_cross_of_gsign_eq {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B A' B' : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hcop' : IsCoprime A' B')
    (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) (hdvd' : (p : ℤ) ∣ A' ^ 2 + B' ^ 2)
    (heq : gsign x y (p : ℤ) A B = gsign x y (p : ℤ) A' B') :
    (p : ℤ) ∣ A * B' - A' * B := by
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hpx : ¬ ((p : ℤ) ∣ x) := prime_not_dvd_coord hp hxy
  have hkey : (p : ℤ) ∣ x ^ 2 * (A * B' - A' * B) := by
    cases hs : gsign x y (p : ℤ) A B
    · have h₁ : (p : ℤ) ∣ x * A + y * B := (gsign_eq_false_iff hp hne2 hxy hcop hdvd).mp hs
      have h₂ : (p : ℤ) ∣ x * A' + y * B' :=
        (gsign_eq_false_iff hp hne2 hxy hcop' hdvd').mp (by rw [← heq, hs])
      obtain ⟨k, hk⟩ := h₁
      obtain ⟨k', hk'⟩ := h₂
      exact ⟨k * (x * B') - k' * (x * B), by linear_combination (x * B') * hk - (x * B) * hk'⟩
    · have h₁ : (p : ℤ) ∣ x * A - y * B := (gsign_eq_true_iff x y (p : ℤ) A B).mp hs
      have h₂ : (p : ℤ) ∣ x * A' - y * B' :=
        (gsign_eq_true_iff x y (p : ℤ) A' B').mp (by rw [← heq, hs])
      obtain ⟨k, hk⟩ := h₁
      obtain ⟨k', hk'⟩ := h₂
      exact ⟨k * (x * B') - k' * (x * B), by linear_combination (x * B') * hk - (x * B) * hk'⟩
  have hx2 : ¬ ((p : ℤ) ∣ x ^ 2) := fun h => hpx (hpZ.dvd_of_dvd_pow h)
  exact (hpZ.dvd_mul.mp hkey).resolve_left hx2

/-- Different Gaussian signs at `p` force `p` to divide the *sum* cross term. -/
theorem dvd_add_cross_of_gsign_ne {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B A' B' : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hcop' : IsCoprime A' B')
    (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) (hdvd' : (p : ℤ) ∣ A' ^ 2 + B' ^ 2)
    (hne : gsign x y (p : ℤ) A B ≠ gsign x y (p : ℤ) A' B') :
    (p : ℤ) ∣ A * B' + A' * B := by
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hpx : ¬ ((p : ℤ) ∣ x) := prime_not_dvd_coord hp hxy
  have hkey : (p : ℤ) ∣ x ^ 2 * (A * B' + A' * B) := by
    cases hs : gsign x y (p : ℤ) A B
    · have h₁ : (p : ℤ) ∣ x * A + y * B := (gsign_eq_false_iff hp hne2 hxy hcop hdvd).mp hs
      have hs' : gsign x y (p : ℤ) A' B' = true := by
        rw [hs] at hne
        cases hg : gsign x y (p : ℤ) A' B'
        · exact absurd hg (by simpa using hne)
        · rfl
      have h₂ : (p : ℤ) ∣ x * A' - y * B' := (gsign_eq_true_iff x y (p : ℤ) A' B').mp hs'
      obtain ⟨k, hk⟩ := h₁
      obtain ⟨k', hk'⟩ := h₂
      exact ⟨k * (x * B') + k' * (x * B), by linear_combination (x * B') * hk + (x * B) * hk'⟩
    · have h₁ : (p : ℤ) ∣ x * A - y * B := (gsign_eq_true_iff x y (p : ℤ) A B).mp hs
      have hs' : gsign x y (p : ℤ) A' B' = false := by
        rw [hs] at hne
        cases hg : gsign x y (p : ℤ) A' B'
        · rfl
        · exact absurd hg (by simpa using hne)
      have h₂ : (p : ℤ) ∣ x * A' + y * B' := (gsign_eq_false_iff hp hne2 hxy hcop' hdvd').mp hs'
      obtain ⟨k, hk⟩ := h₁
      obtain ⟨k', hk'⟩ := h₂
      exact ⟨k * (x * B') + k' * (x * B), by linear_combination (x * B') * hk + (x * B) * hk'⟩
  have hx2 : ¬ ((p : ℤ) ∣ x ^ 2) := fun h => hpx (hpZ.dvd_of_dvd_pow h)
  exact (hpZ.dvd_mul.mp hkey).resolve_left hx2

/-! ### The sign class of a representation of `pqr` -/

/-- The flip-invariant sign class of a representation at three primes. -/
def gclass (x y u v s t P Q R A B : ℤ) : Bool × Bool :=
  (gsign x y P A B != gsign u v Q A B, gsign x y P A B != gsign s t R A B)

/-- **The sign class determines the representation.**  Two primitive representations of
`N = pqr` with the same class agree up to order and sign. -/
theorem rep_eq_of_gclass_eq {p q r : ℕ} (hp : p.Prime) (hq : q.Prime) (hr : r.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hr2 : r ≠ 2)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r)
    {x y u v s t A B A' B' : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (huv : u ^ 2 + v ^ 2 = (q : ℤ))
    (hst : s ^ 2 + t ^ 2 = (r : ℤ))
    (hsum : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) (hsum' : A' ^ 2 + B' ^ 2 = (p : ℤ) * q * r)
    (hcop : IsCoprime A B) (hcop' : IsCoprime A' B')
    (hcls : gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A B
      = gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A' B') :
    (A ^ 2 = A' ^ 2 ∧ B ^ 2 = B' ^ 2) ∨ (A ^ 2 = B' ^ 2 ∧ B ^ 2 = A' ^ 2) := by
  have hppos : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hqpos : (0 : ℤ) < (q : ℤ) := by exact_mod_cast hq.pos
  have hrpos : (0 : ℤ) < (r : ℤ) := by exact_mod_cast hr.pos
  have hNpos : (0 : ℤ) < (p : ℤ) * q * r := by positivity
  have hdp : (p : ℤ) ∣ A ^ 2 + B ^ 2 := by rw [hsum]; exact ⟨(q : ℤ) * r, by ring⟩
  have hdq : (q : ℤ) ∣ A ^ 2 + B ^ 2 := by rw [hsum]; exact ⟨(p : ℤ) * r, by ring⟩
  have hdr : (r : ℤ) ∣ A ^ 2 + B ^ 2 := by rw [hsum]; exact ⟨(p : ℤ) * q, by ring⟩
  have hdp' : (p : ℤ) ∣ A' ^ 2 + B' ^ 2 := by rw [hsum']; exact ⟨(q : ℤ) * r, by ring⟩
  have hdq' : (q : ℤ) ∣ A' ^ 2 + B' ^ 2 := by rw [hsum']; exact ⟨(p : ℤ) * r, by ring⟩
  have hdr' : (r : ℤ) ∣ A' ^ 2 + B' ^ 2 := by rw [hsum']; exact ⟨(p : ℤ) * q, by ring⟩
  have hcpq : IsCoprime ((p : ℤ)) ((q : ℤ)) := isCoprime_of_ne_primes hp hq hpq
  have hcpr : IsCoprime ((p : ℤ)) ((r : ℤ)) := isCoprime_of_ne_primes hp hr hpr
  have hcqr : IsCoprime ((q : ℤ)) ((r : ℤ)) := isCoprime_of_ne_primes hq hr hqr
  -- the class equation says: the three signs either all agree or all disagree
  simp only [gclass, Prod.mk.injEq] at hcls
  obtain ⟨h1, h2⟩ := hcls
  have hallcases :
      (gsign x y (p : ℤ) A B = gsign x y (p : ℤ) A' B' ∧
        gsign u v (q : ℤ) A B = gsign u v (q : ℤ) A' B' ∧
        gsign s t (r : ℤ) A B = gsign s t (r : ℤ) A' B') ∨
      (gsign x y (p : ℤ) A B ≠ gsign x y (p : ℤ) A' B' ∧
        gsign u v (q : ℤ) A B ≠ gsign u v (q : ℤ) A' B' ∧
        gsign s t (r : ℤ) A B ≠ gsign s t (r : ℤ) A' B') := by
    revert h1 h2
    cases gsign x y (p : ℤ) A B <;> cases gsign u v (q : ℤ) A B <;>
      cases gsign s t (r : ℤ) A B <;> cases gsign x y (p : ℤ) A' B' <;>
      cases gsign u v (q : ℤ) A' B' <;> cases gsign s t (r : ℤ) A' B' <;> simp
  rcases hallcases with ⟨e₁, e₂, e₃⟩ | ⟨n₁, n₂, n₃⟩
  · -- all agree: `N` divides the difference cross term
    have d₁ := dvd_sub_cross_of_gsign_eq hp hp2 hxy hcop hcop' hdp hdp' e₁
    have d₂ := dvd_sub_cross_of_gsign_eq hq hq2 huv hcop hcop' hdq hdq' e₂
    have d₃ := dvd_sub_cross_of_gsign_eq hr hr2 hst hcop hcop' hdr hdr' e₃
    have dpq : ((p : ℤ) * q) ∣ A * B' - A' * B := hcpq.mul_dvd d₁ d₂
    have dN : ((p : ℤ) * q * r) ∣ A * B' - A' * B :=
      (IsCoprime.mul_left hcpr hcqr).mul_dvd dpq d₃
    exact rep_eq_of_dvd_cross hNpos hsum hsum' hcop hcop' dN
  · -- all disagree: `N` divides the sum cross term, i.e. the difference for `(A', -B')`
    have d₁ := dvd_add_cross_of_gsign_ne hp hp2 hxy hcop hcop' hdp hdp' n₁
    have d₂ := dvd_add_cross_of_gsign_ne hq hq2 huv hcop hcop' hdq hdq' n₂
    have d₃ := dvd_add_cross_of_gsign_ne hr hr2 hst hcop hcop' hdr hdr' n₃
    have dpq : ((p : ℤ) * q) ∣ A * B' + A' * B := hcpq.mul_dvd d₁ d₂
    have dN : ((p : ℤ) * q * r) ∣ A * B' + A' * B :=
      (IsCoprime.mul_left hcpr hcqr).mul_dvd dpq d₃
    have dN' : ((p : ℤ) * q * r) ∣ A * (-B') - A' * B := by
      have e : A * (-B') - A' * B = -(A * B' + A' * B) := by ring
      rw [e]; exact dvd_neg.mpr dN
    have hsum'' : A' ^ 2 + (-B') ^ 2 = (p : ℤ) * q * r := by rw [neg_pow]; simpa using hsum'
    rcases rep_eq_of_dvd_cross hNpos hsum hsum'' hcop hcop'.neg_right dN' with
      ⟨f₁, f₂⟩ | ⟨f₁, f₂⟩
    · exact Or.inl ⟨f₁, by rw [f₂]; ring⟩
    · exact Or.inr ⟨by rw [f₁]; ring, f₂⟩

/-! ### At most four resonant words -/

/-- **`r(pqr) ≤ 4`.**  Among any five walk words with hypotenuse `pqr` two coincide. -/
theorem at_most_four_resonant_words {p q r : ℕ} (hp : p.Prime) (hq : q.Prime) (hr : r.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hr4 : r % 4 = 1)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r)
    (w : Fin 5 → List (Fin 3)) (hw : ∀ i, (walk (w i)).c = (p : ℤ) * q * r) :
    ∃ i j : Fin 5, i ≠ j ∧ w i = w j := by
  obtain ⟨x, y, hx, hy, hxy, hcxy⟩ := prime_sq_add_sq_pos hp hp4
  obtain ⟨u, v, hu, hv, huv, hcuv⟩ := prime_sq_add_sq_pos hq hq4
  obtain ⟨s, t, hs, ht, hst, hcst⟩ := prime_sq_add_sq_pos hr hr4
  have H : ∀ i : Fin 5, ∃ m n : ℤ, 0 < n ∧ n < m ∧ IsCoprime m n ∧ walk (w i) = repNode m n :=
    fun i => exists_repNode_of_isPPT (walk_isPPT (w i)) (walk_odd_a (w i))
  choose M Nn hpos hlt hcop hrep using H
  have hsum : ∀ i, (M i) ^ 2 + (Nn i) ^ 2 = (p : ℤ) * q * r := by
    intro i
    have := hw i
    rw [hrep i] at this
    simpa [repNode] using this
  set f : Fin 5 → Bool × Bool :=
    fun i => gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) (M i) (Nn i) with hf
  obtain ⟨i, j, hij, hfij⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt f (by simp)
  refine ⟨i, j, hij, ?_⟩
  have hcls := hfij
  rcases rep_eq_of_gclass_eq hp hq hr (by omega) (by omega) (by omega)
      hpq hpr hqr hxy huv hst (hsum i) (hsum j)
      (hcop i) (hcop j) hcls with ⟨e₁, e₂⟩ | ⟨e₁, e₂⟩
  · have hm : M i = M j := eq_of_sq_eq_of_pos (by have := hpos i; have := hlt i; omega)
      (by have := hpos j; have := hlt j; omega) e₁
    have hn : Nn i = Nn j := eq_of_sq_eq_of_pos (hpos i) (hpos j) e₂
    exact walk_injective (by rw [hrep i, hrep j, hm, hn])
  · exfalso
    have hm : M i = Nn j := eq_of_sq_eq_of_pos (by have := hpos i; have := hlt i; omega)
      (hpos j) e₁
    have hn : Nn i = M j := eq_of_sq_eq_of_pos (hpos i)
      (by have := hpos j; have := hlt j; omega) e₂
    have := hlt i
    have := hlt j
    omega

/-! ### Sign flips -/

private theorem dvd_cancel_coord {P x Z : ℤ} (hP : Prime P) (hPx : ¬ P ∣ x) (h : P ∣ x * Z) :
    P ∣ Z := (hP.dvd_mul.mp h).resolve_left hPx

/-- Negating the first coordinate of the pair flips the Gaussian sign. -/
theorem gsign_neg_left {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) :
    gsign x y (p : ℤ) (-A) B = !gsign x y (p : ℤ) A B := by
  have hdvd' : (p : ℤ) ∣ (-A) ^ 2 + B ^ 2 := by
    have e : (-A) ^ 2 + B ^ 2 = A ^ 2 + B ^ 2 := by ring
    rw [e]; exact hdvd
  cases h : gsign x y (p : ℤ) A B
  · have h1 := (gsign_eq_false_iff hp hne2 hxy hcop hdvd).mp h
    simp only [Bool.not_false]
    rw [gsign_eq_true_iff]
    have e : x * (-A) - y * B = -(x * A + y * B) := by ring
    rw [e]; exact dvd_neg.mpr h1
  · have h1 := (gsign_eq_true_iff x y (p : ℤ) A B).mp h
    simp only [Bool.not_true]
    rw [gsign_eq_false_iff hp hne2 hxy hcop.neg_left hdvd']
    have e : x * (-A) + y * B = -(x * A - y * B) := by ring
    rw [e]; exact dvd_neg.mpr h1

/-- Negating the second coordinate of the pair flips the Gaussian sign. -/
theorem gsign_neg_right {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) :
    gsign x y (p : ℤ) A (-B) = !gsign x y (p : ℤ) A B := by
  have hdvd' : (p : ℤ) ∣ A ^ 2 + (-B) ^ 2 := by
    have e : A ^ 2 + (-B) ^ 2 = A ^ 2 + B ^ 2 := by ring
    rw [e]; exact hdvd
  cases h : gsign x y (p : ℤ) A B
  · have h1 := (gsign_eq_false_iff hp hne2 hxy hcop hdvd).mp h
    simp only [Bool.not_false]
    rw [gsign_eq_true_iff]
    have e : x * A - y * (-B) = x * A + y * B := by ring
    rw [e]; exact h1
  · have h1 := (gsign_eq_true_iff x y (p : ℤ) A B).mp h
    simp only [Bool.not_true]
    rw [gsign_eq_false_iff hp hne2 hxy hcop.neg_right hdvd']
    have e : x * A + y * (-B) = x * A - y * B := by ring
    rw [e]; exact h1

/-- Passing to the conjugate Gaussian prime `x - i y` flips the Gaussian sign. -/
theorem gsign_neg_coord {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) :
    gsign x (-y) (p : ℤ) A B = !gsign x y (p : ℤ) A B := by
  have hxy' : x ^ 2 + (-y) ^ 2 = (p : ℤ) := by linear_combination hxy
  cases h : gsign x y (p : ℤ) A B
  · have h1 := (gsign_eq_false_iff hp hne2 hxy hcop hdvd).mp h
    simp only [Bool.not_false]
    rw [gsign_eq_true_iff]
    have e : x * A - -y * B = x * A + y * B := by ring
    rw [e]; exact h1
  · have h1 := (gsign_eq_true_iff x y (p : ℤ) A B).mp h
    simp only [Bool.not_true]
    rw [gsign_eq_false_iff hp hne2 hxy' hcop hdvd]
    have e : x * A + -y * B = x * A - y * B := by ring
    rw [e]; exact h1

/-- Swapping the two coordinates flips the Gaussian sign: `B + iA = i·conj(A + iB)`. -/
theorem gsign_swap {p : ℕ} (hp : p.Prime) (hne2 : p ≠ 2) {x y A B : ℤ}
    (hxy : x ^ 2 + y ^ 2 = (p : ℤ)) (hcop : IsCoprime A B) (hdvd : (p : ℤ) ∣ A ^ 2 + B ^ 2) :
    gsign x y (p : ℤ) B A = !gsign x y (p : ℤ) A B := by
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hpx : ¬ ((p : ℤ) ∣ x) := prime_not_dvd_coord hp hxy
  have hdvd' : (p : ℤ) ∣ B ^ 2 + A ^ 2 := by
    have e : B ^ 2 + A ^ 2 = A ^ 2 + B ^ 2 := by ring
    rw [e]; exact hdvd
  cases h : gsign x y (p : ℤ) A B
  · have h1 := (gsign_eq_false_iff hp hne2 hxy hcop hdvd).mp h
    simp only [Bool.not_false]
    rw [gsign_eq_true_iff]
    refine dvd_cancel_coord hpZ hpx ?_
    have e : x * (x * B - y * A) = (p : ℤ) * B - y * (x * A + y * B) := by
      linear_combination B * hxy
    rw [e]
    exact dvd_sub (dvd_mul_right _ _) (h1.mul_left y)
  · have h1 := (gsign_eq_true_iff x y (p : ℤ) A B).mp h
    simp only [Bool.not_true]
    rw [gsign_eq_false_iff hp hne2 hxy hcop.symm hdvd']
    refine dvd_cancel_coord hpZ hpx ?_
    have e : x * (x * B + y * A) = (p : ℤ) * B + y * (x * A - y * B) := by
      linear_combination B * hxy
    rw [e]
    exact dvd_add (dvd_mul_right _ _) (h1.mul_left y)

/-- Flipping all three Gaussian signs leaves the class unchanged: the class is an invariant
of the *node*, not of the chosen representative pair. -/
theorem gclass_of_flip {x y u v s t P Q R A B A' B' : ℤ}
    (h1 : gsign x y P A' B' = !gsign x y P A B)
    (h2 : gsign u v Q A' B' = !gsign u v Q A B)
    (h3 : gsign s t R A' B' = !gsign s t R A B) :
    gclass x y u v s t P Q R A' B' = gclass x y u v s t P Q R A B := by
  simp only [gclass, h1, h2, h3]
  cases gsign x y P A B <;> cases gsign u v Q A B <;> cases gsign s t R A B <;> rfl

/-! ### A bundle of three admissible primes together with their Gaussian coordinates -/

/-- The standing data of the `ω = 3` analysis: three distinct odd primes with a chosen
primitive representation of each as a sum of two squares. -/
structure GaussianTriple (p q r : ℕ) (x y u v s t : ℤ) : Prop where
  pprime : p.Prime
  qprime : q.Prime
  rprime : r.Prime
  pne2 : p ≠ 2
  qne2 : q ≠ 2
  rne2 : r ≠ 2
  pq : p ≠ q
  pr : p ≠ r
  qr : q ≠ r
  hxy : x ^ 2 + y ^ 2 = (p : ℤ)
  huv : u ^ 2 + v ^ 2 = (q : ℤ)
  hst : s ^ 2 + t ^ 2 = (r : ℤ)
  cxy : IsCoprime x y
  cuv : IsCoprime u v
  cst : IsCoprime s t

/-- Each prime factor divides the modulus of a representation of `pqr`. -/
theorem dvd_p_of_sum {p q r : ℕ} {A B : ℤ} (h : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) :
    (p : ℤ) ∣ A ^ 2 + B ^ 2 := ⟨(q : ℤ) * r, by rw [h]; ring⟩

theorem dvd_q_of_sum {p q r : ℕ} {A B : ℤ} (h : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) :
    (q : ℤ) ∣ A ^ 2 + B ^ 2 := ⟨(p : ℤ) * r, by rw [h]; ring⟩

theorem dvd_r_of_sum {p q r : ℕ} {A B : ℤ} (h : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) :
    (r : ℤ) ∣ A ^ 2 + B ^ 2 := ⟨(p : ℤ) * q, by rw [h]; ring⟩

namespace GaussianTriple

variable {p q r : ℕ} {x y u v s t : ℤ}

/-- Conjugating the Gaussian prime above `q`. -/
theorem negV (T : GaussianTriple p q r x y u v s t) :
    GaussianTriple p q r x y u (-v) s t :=
  ⟨T.pprime, T.qprime, T.rprime, T.pne2, T.qne2, T.rne2, T.pq, T.pr, T.qr, T.hxy,
    by linear_combination T.huv, T.hst, T.cxy, T.cuv.neg_right, T.cst⟩

/-- Conjugating the Gaussian prime above `r`. -/
theorem negT (T : GaussianTriple p q r x y u v s t) :
    GaussianTriple p q r x y u v s (-t) :=
  ⟨T.pprime, T.qprime, T.rprime, T.pne2, T.qne2, T.rne2, T.pq, T.pr, T.qr, T.hxy, T.huv,
    by linear_combination T.hst, T.cxy, T.cuv, T.cst.neg_right⟩

theorem oddN (T : GaussianTriple p q r x y u v s t) : ((p : ℤ) * q * r) % 2 = 1 := by
  have hodd : Odd ((p : ℤ) * q * r) := by
    refine Odd.mul (Odd.mul ?_ ?_) ?_
    · exact (Int.odd_coe_nat p).mpr (T.pprime.odd_of_ne_two T.pne2)
    · exact (Int.odd_coe_nat q).mpr (T.qprime.odd_of_ne_two T.qne2)
    · exact (Int.odd_coe_nat r).mpr (T.rprime.odd_of_ne_two T.rne2)
  exact Int.odd_iff.mp hodd

theorem one_lt (T : GaussianTriple p q r x y u v s t) : (1 : ℤ) < (p : ℤ) * q * r := by
  have hp : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast T.pprime.two_le
  have hq : (2 : ℤ) ≤ (q : ℤ) := by exact_mod_cast T.qprime.two_le
  have hr : (2 : ℤ) ≤ (r : ℤ) := by exact_mod_cast T.rprime.two_le
  have hpq : (4 : ℤ) ≤ (p : ℤ) * q := by nlinarith
  nlinarith

theorem gclass_neg_left (T : GaussianTriple p q r x y u v s t) {A B : ℤ}
    (h : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) (hcop : IsCoprime A B) :
    gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) (-A) B
      = gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A B :=
  gclass_of_flip (gsign_neg_left T.pprime T.pne2 T.hxy hcop (dvd_p_of_sum h))
    (gsign_neg_left T.qprime T.qne2 T.huv hcop (dvd_q_of_sum h))
    (gsign_neg_left T.rprime T.rne2 T.hst hcop (dvd_r_of_sum h))

theorem gclass_neg_right (T : GaussianTriple p q r x y u v s t) {A B : ℤ}
    (h : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) (hcop : IsCoprime A B) :
    gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A (-B)
      = gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A B :=
  gclass_of_flip (gsign_neg_right T.pprime T.pne2 T.hxy hcop (dvd_p_of_sum h))
    (gsign_neg_right T.qprime T.qne2 T.huv hcop (dvd_q_of_sum h))
    (gsign_neg_right T.rprime T.rne2 T.hst hcop (dvd_r_of_sum h))

theorem gclass_swap (T : GaussianTriple p q r x y u v s t) {A B : ℤ}
    (h : A ^ 2 + B ^ 2 = (p : ℤ) * q * r) (hcop : IsCoprime A B) :
    gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) B A
      = gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A B :=
  gclass_of_flip (gsign_swap T.pprime T.pne2 T.hxy hcop (dvd_p_of_sum h))
    (gsign_swap T.qprime T.qne2 T.huv hcop (dvd_q_of_sum h))
    (gsign_swap T.rprime T.rne2 T.hst hcop (dvd_r_of_sum h))

end GaussianTriple

/-! ### The four Gaussian products -/

/-- The product `(x + iy)(u + iv)(s + it)` is a primitive representation of `pqr` all of
whose Gaussian signs are `false`. -/
theorem exists_rep_all_gsign_false {p q r : ℕ} {x y u v s t : ℤ}
    (T : GaussianTriple p q r x y u v s t) :
    ∃ A B : ℤ, A ^ 2 + B ^ 2 = (p : ℤ) * q * r ∧ IsCoprime A B ∧
      gsign x y (p : ℤ) A B = false ∧ gsign u v (q : ℤ) A B = false ∧
      gsign s t (r : ℤ) A B = false := by
  have hqr' : IsCoprime ((q : ℤ)) ((r : ℤ)) := isCoprime_of_ne_primes T.qprime T.rprime T.qr
  have hpqr' : IsCoprime ((p : ℤ)) ((q : ℤ) * r) :=
    IsCoprime.mul_right (isCoprime_of_ne_primes T.pprime T.qprime T.pq)
      (isCoprime_of_ne_primes T.pprime T.rprime T.pr)
  have hCD : (u * s - v * t) ^ 2 + (u * t + v * s) ^ 2 = (q : ℤ) * r := by
    linear_combination (s ^ 2 + t ^ 2) * T.huv + (q : ℤ) * T.hst
  have hCDcop : IsCoprime (u * s - v * t) (u * t + v * s) := by
    have h := brahmagupta_isCoprime T.huv
      (show s ^ 2 + (-t) ^ 2 = (r : ℤ) by linear_combination T.hst) T.cuv T.cst.neg_right hqr'
    have e1 : u * s - v * t = u * s + v * (-t) := by ring
    have e2 : u * t + v * s = v * s - u * (-t) := by ring
    rw [e1, e2]; exact h
  refine ⟨x * (u * s - v * t) - y * (u * t + v * s), x * (u * t + v * s) + y * (u * s - v * t),
    ?_, ?_, ?_, ?_, ?_⟩
  · linear_combination ((u * s - v * t) ^ 2 + (u * t + v * s) ^ 2) * T.hxy + (p : ℤ) * hCD
  · have h := brahmagupta_isCoprime T.hxy
      (show (u * s - v * t) ^ 2 + (-(u * t + v * s)) ^ 2 = (q : ℤ) * r by linear_combination hCD)
      T.cxy hCDcop.neg_right hpqr'
    have e1 : x * (u * s - v * t) - y * (u * t + v * s)
        = x * (u * s - v * t) + y * (-(u * t + v * s)) := by ring
    have e2 : x * (u * t + v * s) + y * (u * s - v * t)
        = y * (u * s - v * t) - x * (-(u * t + v * s)) := by ring
    rw [e1, e2]; exact h
  all_goals
    have hsum : (x * (u * s - v * t) - y * (u * t + v * s)) ^ 2
        + (x * (u * t + v * s) + y * (u * s - v * t)) ^ 2 = (p : ℤ) * q * r := by
      linear_combination ((u * s - v * t) ^ 2 + (u * t + v * s) ^ 2) * T.hxy + (p : ℤ) * hCD
    have hcop : IsCoprime (x * (u * s - v * t) - y * (u * t + v * s))
        (x * (u * t + v * s) + y * (u * s - v * t)) := by
      have h := brahmagupta_isCoprime T.hxy
        (show (u * s - v * t) ^ 2 + (-(u * t + v * s)) ^ 2 = (q : ℤ) * r by
          linear_combination hCD)
        T.cxy hCDcop.neg_right hpqr'
      have e1 : x * (u * s - v * t) - y * (u * t + v * s)
          = x * (u * s - v * t) + y * (-(u * t + v * s)) := by ring
      have e2 : x * (u * t + v * s) + y * (u * s - v * t)
          = y * (u * s - v * t) - x * (-(u * t + v * s)) := by ring
      rw [e1, e2]; exact h
    first
      | (rw [gsign_eq_false_iff T.pprime T.pne2 T.hxy hcop (dvd_p_of_sum hsum)]
         exact ⟨u * s - v * t, by linear_combination (u * s - v * t) * T.hxy⟩)
      | (rw [gsign_eq_false_iff T.qprime T.qne2 T.huv hcop (dvd_q_of_sum hsum)]
         exact ⟨x * s - y * t, by linear_combination (x * s - y * t) * T.huv⟩)
      | (rw [gsign_eq_false_iff T.rprime T.rne2 T.hst hcop (dvd_r_of_sum hsum)]
         exact ⟨x * u - y * v, by linear_combination (x * u - y * v) * T.hst⟩)

/-- **Every one of the four sign classes is realised.** -/
theorem exists_rep_with_class {p q r : ℕ} {x y u v s t : ℤ}
    (T : GaussianTriple p q r x y u v s t) (bq br : Bool) :
    ∃ A B : ℤ, A ^ 2 + B ^ 2 = (p : ℤ) * q * r ∧ IsCoprime A B ∧
      gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) A B = (bq, br) := by
  cases bq with
  | false =>
    cases br with
    | false =>
      obtain ⟨A, B, hsum, hcop, h1, h2, h3⟩ := exists_rep_all_gsign_false T
      exact ⟨A, B, hsum, hcop, by simp [gclass, h1, h2, h3]⟩
    | true =>
      obtain ⟨A, B, hsum, hcop, h1, h2, h3⟩ := exists_rep_all_gsign_false T.negT
      have h3' : gsign s t (r : ℤ) A B = true := by
        have hh := gsign_neg_coord T.rprime T.rne2 T.hst hcop (dvd_r_of_sum hsum)
        have := hh.symm.trans h3
        simpa using this
      exact ⟨A, B, hsum, hcop, by simp [gclass, h1, h2, h3']⟩
  | true =>
    cases br with
    | false =>
      obtain ⟨A, B, hsum, hcop, h1, h2, h3⟩ := exists_rep_all_gsign_false T.negV
      have h2' : gsign u v (q : ℤ) A B = true := by
        have hh := gsign_neg_coord T.qprime T.qne2 T.huv hcop (dvd_q_of_sum hsum)
        have := hh.symm.trans h2
        simpa using this
      exact ⟨A, B, hsum, hcop, by simp [gclass, h1, h2', h3]⟩
    | true =>
      obtain ⟨A, B, hsum, hcop, h1, h2, h3⟩ := exists_rep_all_gsign_false T.negV.negT
      have h2' : gsign u v (q : ℤ) A B = true := by
        have hh := gsign_neg_coord T.qprime T.qne2 T.huv hcop (dvd_q_of_sum hsum)
        have := hh.symm.trans h2
        simpa using this
      have h3' : gsign s t (r : ℤ) A B = true := by
        have hh := gsign_neg_coord T.rprime T.rne2 T.hst hcop (dvd_r_of_sum hsum)
        have := hh.symm.trans h3
        simpa using this
      exact ⟨A, B, hsum, hcop, by simp [gclass, h1, h2', h3']⟩

/-- Each sign class produces an actual walk word, together with a positive representative
pair recording its class. -/
theorem exists_word_with_class {p q r : ℕ} {x y u v s t : ℤ}
    (T : GaussianTriple p q r x y u v s t) (bq br : Bool) :
    ∃ (w : List (Fin 3)) (X Y : ℤ), 0 < X ∧ 0 < Y ∧ X ^ 2 + Y ^ 2 = (p : ℤ) * q * r ∧
      IsCoprime X Y ∧ (walk w).c = (p : ℤ) * q * r ∧ (walk w).b = 2 * X * Y ∧
      gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) X Y = (bq, br) := by
  obtain ⟨A, B, hsum, hcop, hcls⟩ := exists_rep_with_class T bq br
  have hA0 : A ≠ 0 := by
    rintro rfl
    have hu : IsUnit B := isCoprime_zero_left.mp hcop
    rcases Int.isUnit_iff.mp hu with hB | hB <;> rw [hB] at hsum <;>
      · have := T.one_lt; norm_num at hsum; omega
  have hB0 : B ≠ 0 := by
    rintro rfl
    have hu : IsUnit A := isCoprime_zero_right.mp hcop
    rcases Int.isUnit_iff.mp hu with hA | hA <;> rw [hA] at hsum <;>
      · have := T.one_lt; norm_num at hsum; omega
  -- pass to the positive representative, which has the same class
  obtain ⟨X, Y, hX, hY, hXY, hcXY, hclsXY⟩ :
      ∃ X Y : ℤ, 0 < X ∧ 0 < Y ∧ X ^ 2 + Y ^ 2 = (p : ℤ) * q * r ∧ IsCoprime X Y ∧
        gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) X Y = (bq, br) := by
    rcases lt_or_gt_of_ne hA0 with hA | hA
    · rcases lt_or_gt_of_ne hB0 with hB | hB
      · refine ⟨-A, -B, by omega, by omega, by linear_combination hsum, hcop.neg_left.neg_right, ?_⟩
        rw [T.gclass_neg_right (by linear_combination hsum) hcop.neg_left,
          T.gclass_neg_left hsum hcop, hcls]
      · refine ⟨-A, B, by omega, hB, by linear_combination hsum, hcop.neg_left, ?_⟩
        rw [T.gclass_neg_left hsum hcop, hcls]
    · rcases lt_or_gt_of_ne hB0 with hB | hB
      · refine ⟨A, -B, hA, by omega, by linear_combination hsum, hcop.neg_right, ?_⟩
        rw [T.gclass_neg_right hsum hcop, hcls]
      · exact ⟨A, B, hA, hB, hsum, hcop, hcls⟩
  have hodd : (X ^ 2 + Y ^ 2) % 2 = 1 := by rw [hXY]; exact T.oddN
  obtain ⟨n, hn, hna, hnc, hnb, -⟩ := node_of_primitive_rep hX hY hcXY hodd
  obtain ⟨w, hw⟩ := exists_word_of_isPPT n hn hna
  exact ⟨w, X, Y, hX, hY, hXY, hcXY, by rw [hw, hnc, hXY], by rw [hw, hnb], hclsXY⟩

/-- Two positive primitive representations of `pqr` with the same product of coordinates are
equal up to order, hence carry the same sign class. -/
theorem gclass_eq_of_prod_eq {p q r : ℕ} {x y u v s t : ℤ}
    (T : GaussianTriple p q r x y u v s t) {X₁ Y₁ X₂ Y₂ : ℤ}
    (hX₁ : 0 < X₁) (hY₁ : 0 < Y₁) (hX₂ : 0 < X₂) (hY₂ : 0 < Y₂)
    (hs₁ : X₁ ^ 2 + Y₁ ^ 2 = (p : ℤ) * q * r) (hs₂ : X₂ ^ 2 + Y₂ ^ 2 = (p : ℤ) * q * r)
    (hc₂ : IsCoprime X₂ Y₂) (hb : 2 * X₁ * Y₁ = 2 * X₂ * Y₂) :
    gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) X₁ Y₁
      = gclass x y u v s t (p : ℤ) (q : ℤ) (r : ℤ) X₂ Y₂ := by
  have hb' : X₁ * Y₁ = X₂ * Y₂ := by linarith
  have hsum : X₁ ^ 2 + Y₁ ^ 2 = X₂ ^ 2 + Y₂ ^ 2 := by rw [hs₁, hs₂]
  have key : (X₁ ^ 2 - X₂ ^ 2) * (X₁ ^ 2 - Y₂ ^ 2) = 0 := by
    linear_combination X₁ ^ 2 * hsum - (X₁ * Y₁ + X₂ * Y₂) * hb'
  rcases mul_eq_zero.mp key with h | h
  · have hXX : X₁ = X₂ := eq_of_sq_eq_of_pos hX₁ hX₂ (by linarith)
    have hYY : Y₁ = Y₂ := eq_of_sq_eq_of_pos hY₁ hY₂ (by linarith)
    rw [hXX, hYY]
  · have hXY : X₁ = Y₂ := eq_of_sq_eq_of_pos hX₁ hY₂ (by linarith)
    have hYX : Y₁ = X₂ := eq_of_sq_eq_of_pos hY₁ hX₂ (by linarith)
    rw [hXY, hYX]
    exact T.gclass_swap hs₂ hc₂

/-- **Four distinct resonant words for `N = pqr`.** -/
theorem exists_four_resonant_words {p q r : ℕ} (hp : p.Prime) (hq : q.Prime) (hr : r.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hr4 : r % 4 = 1)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    ∃ w : Bool × Bool → List (Fin 3),
      (∀ c₁ c₂, w c₁ = w c₂ → c₁ = c₂) ∧ ∀ c, (walk (w c)).c = (p : ℤ) * q * r := by
  obtain ⟨x, y, hx, hy, hxy, hcxy⟩ := prime_sq_add_sq_pos hp hp4
  obtain ⟨u, v, hu, hv, huv, hcuv⟩ := prime_sq_add_sq_pos hq hq4
  obtain ⟨s, t, hs, ht, hst, hcst⟩ := prime_sq_add_sq_pos hr hr4
  have T : GaussianTriple p q r x y u v s t :=
    ⟨hp, hq, hr, by omega, by omega, by omega, hpq, hpr, hqr, hxy, huv, hst, hcxy, hcuv, hcst⟩
  choose w X Y hX hY hXY hcXY hwc hwb hcls using
    fun c : Bool × Bool => exists_word_with_class T c.1 c.2
  refine ⟨w, ?_, hwc⟩
  intro c₁ c₂ hww
  have hb : 2 * X c₁ * Y c₁ = 2 * X c₂ * Y c₂ := by
    rw [← hwb c₁, ← hwb c₂, hww]
  have := gclass_eq_of_prod_eq T (hX c₁) (hY c₁) (hX c₂) (hY c₂) (hXY c₁) (hXY c₂)
    (hcXY c₂) hb
  rw [hcls c₁, hcls c₂] at this
  exact Prod.ext (congrArg Prod.fst this) (congrArg Prod.snd this)

/-- **`r(pqr) = 4` exactly.**  For three distinct primes `≡ 1 (mod 4)` the Berggren tree
contains exactly four words of hypotenuse `pqr`: four pairwise distinct ones exist, and every
resonant word is one of them. -/
theorem exactly_four_resonant_words {p q r : ℕ} (hp : p.Prime) (hq : q.Prime) (hr : r.Prime)
    (hp4 : p % 4 = 1) (hq4 : q % 4 = 1) (hr4 : r % 4 = 1)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    ∃ w₀ w₁ w₂ w₃ : List (Fin 3),
      w₀ ≠ w₁ ∧ w₀ ≠ w₂ ∧ w₀ ≠ w₃ ∧ w₁ ≠ w₂ ∧ w₁ ≠ w₃ ∧ w₂ ≠ w₃ ∧
      (walk w₀).c = (p : ℤ) * q * r ∧ (walk w₁).c = (p : ℤ) * q * r ∧
      (walk w₂).c = (p : ℤ) * q * r ∧ (walk w₃).c = (p : ℤ) * q * r ∧
      ∀ w : List (Fin 3), (walk w).c = (p : ℤ) * q * r →
        w = w₀ ∨ w = w₁ ∨ w = w₂ ∨ w = w₃ := by
  obtain ⟨W, hinj, hWc⟩ := exists_four_resonant_words hp hq hr hp4 hq4 hr4 hpq hpr hqr
  refine ⟨W (false, false), W (false, true), W (true, false), W (true, true),
    ?_, ?_, ?_, ?_, ?_, ?_, hWc _, hWc _, hWc _, hWc _, ?_⟩
  · intro h; simpa using hinj _ _ h
  · intro h; simpa using hinj _ _ h
  · intro h; simpa using hinj _ _ h
  · intro h; simpa using hinj _ _ h
  · intro h; simpa using hinj _ _ h
  · intro h; simpa using hinj _ _ h
  · intro w hw
    obtain ⟨i, j, hij, hwij⟩ :=
      at_most_four_resonant_words hp hq hr hp4 hq4 hr4 hpq hpr hqr
        ![w, W (false, false), W (false, true), W (true, false), W (true, true)]
        (by
          intro i
          fin_cases i
          · simpa using hw
          · simpa using hWc (false, false)
          · simpa using hWc (false, true)
          · simpa using hWc (true, false)
          · simpa using hWc (true, true))
    fin_cases i <;> fin_cases j <;> simp_all

end QuantumPythagoreanWalk