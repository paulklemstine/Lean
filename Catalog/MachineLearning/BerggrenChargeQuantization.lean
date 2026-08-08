import MachineLearning.BerggrenGeodesicDichotomy

/-!
# Quantization of the star: which spokes can occur

The star observed at a rational boundary point of the hyperbolic plot is a union of
horocyclic curves, one for each value of the conserved Lorentz charge
`d = ⟨v, p⟩` (`= c − a` at the ideal point `(1,0)`).  A natural question — and the one
that decides what the picture actually looks like — is: *which charges occur?*

The answer is a genuine quantization law.  For **primitive** Pythagorean triples the
charge at a rational ideal point is never an arbitrary positive integer: it must be
either twice a perfect square or an odd perfect square, and every such value does occur.
So the spokes of the star are indexed by

  `{2, 8, 18, 32, …} ∪ {1, 9, 25, 49, …}`,

a set of density zero in the integers.  The star is *sparse*, and the two arithmetic
progressions of allowed charges are exactly the two parities of the Euclid
parametrisation.

## Main results

* `charge_quantization` — primitive `⇒` charge `∈ 2·□ ∪ odd □`.
* `charge_even_realized`, `charge_odd_realized` — every allowed charge occurs, with an
  explicit primitive triple.
* `charge_spectrum` — the exact spectrum of star charges (an `iff`).
* `mB_hyp_recurrence` — the hyperbolic generator satisfies the Pell recursion
  `c_{k+2} = 6c_{k+1} − c_k` on hypotenuses (the `(−1)`-eigenvector is invisible to the
  third coordinate), tying the geodesic to the fundamental unit `3 + 2√2 = (1+√2)²` of
  `ℤ[√2]`; `mB_hyp_five_growth` sharpens the growth constant from `3` to `5`.
-/

namespace BerggrenStars

open Filter Topology

/-! ### Parity facts for Pythagorean triples -/

/-- The two legs of a Pythagorean triple cannot both be odd (`c² ≡ 2 (mod 4)` is
impossible). -/
theorem not_both_odd {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : Odd a) (hb : Odd b) :
    False := by
  obtain ⟨k, hk⟩ := ha; obtain ⟨l, hl⟩ := hb; subst hk hl
  rcases Int.even_or_odd c with ⟨t, ht⟩ | ⟨t, ht⟩ <;> subst ht
  · have e : 4 * (k ^ 2 + k + l ^ 2 + l) + 2 = 4 * t ^ 2 := by ring_nf; ring_nf at h; linarith
    generalize k ^ 2 + k + l ^ 2 + l = A at e
    generalize t ^ 2 = B at e
    omega
  · have e : 4 * (k ^ 2 + k + l ^ 2 + l) + 2 = 4 * (t ^ 2 + t) + 1 := by
      ring_nf; ring_nf at h; linarith
    generalize k ^ 2 + k + l ^ 2 + l = A at e
    generalize t ^ 2 + t = B at e
    omega

/-- In a primitive Pythagorean triple the hypotenuse is coprime to each leg. -/
theorem isCoprime_leg_hyp {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (hcop : IsCoprime a b) :
    IsCoprime a c := by
  have h1 : IsCoprime a (b ^ 2) := hcop.pow_right
  have h2 : IsCoprime a (b ^ 2 + a * a) := h1.add_mul_left_right a
  have h3 : IsCoprime a (c ^ 2) := by
    have he : b ^ 2 + a * a = c ^ 2 := by linarith
    rwa [he] at h2
  exact h3.of_isCoprime_of_dvd_right ⟨c, by ring⟩

/-- In a primitive Pythagorean triple the hypotenuse is odd. -/
theorem hyp_odd {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (hcop : IsCoprime a b) : Odd c := by
  rcases Int.even_or_odd c with ⟨t, ht⟩ | hco
  · exfalso
    rcases Int.even_or_odd a with ⟨p, hp⟩ | hao
    · rcases Int.even_or_odd b with ⟨q, hq⟩ | hbo
      · -- both legs even contradicts primitivity
        rw [Int.isCoprime_iff_gcd_eq_one] at hcop
        have h2a : (2 : ℤ) ∣ a := ⟨p, by omega⟩
        have h2b : (2 : ℤ) ∣ b := ⟨q, by omega⟩
        have hd := Int.dvd_gcd h2a h2b
        rw [hcop] at hd
        norm_num at hd
      · obtain ⟨q, hq⟩ := hbo
        subst hp hq ht
        have e : 4 * p ^ 2 + (4 * (q ^ 2 + q) + 1) = 4 * t ^ 2 := by
          ring_nf; ring_nf at h; linarith
        generalize p ^ 2 = A at e
        generalize q ^ 2 + q = B at e
        generalize t ^ 2 = C at e
        omega
    · rcases Int.even_or_odd b with ⟨q, hq⟩ | hbo
      · obtain ⟨p, hp⟩ := hao
        subst hp hq ht
        have e : (4 * (p ^ 2 + p) + 1) + 4 * q ^ 2 = 4 * t ^ 2 := by
          ring_nf; ring_nf at h; linarith
        generalize p ^ 2 + p = A at e
        generalize q ^ 2 = B at e
        generalize t ^ 2 = C at e
        omega
      · exact not_both_odd h hao hbo
  · exact hco

/-! ### The quantization theorem -/

/-- **Charge quantization, even first leg.**  If the first leg is even the charge at the
ideal point `(1,0)` is an *odd square*. -/
theorem charge_quantization_even_leg {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a)
    (hb : 0 < b) (hc : 0 < c) (hcop : IsCoprime a b) (hae : Even a) :
    ∃ n : ℤ, 0 < n ∧ Odd n ∧ c - a = n ^ 2 := by
  have hca : 0 < c - a := by nlinarith
  have hco : Odd c := hyp_odd h hcop
  obtain ⟨x, y, hxy⟩ := isCoprime_leg_hyp h hcop
  -- `c − a` and `c + a` are coprime odd numbers with product `b²`
  obtain ⟨p, hp⟩ := hae
  obtain ⟨t, ht⟩ := hco
  have hprod : (c - a) * (c + a) = b ^ 2 := by nlinarith
  have h2 : (y - x) * (c - a) + (x + y) * (c + a) = 2 := by linear_combination 2 * hxy
  have hodd : c - a = 2 * (t - p) + 1 := by omega
  have hcopuv : IsCoprime (c - a) (c + a) :=
    ⟨1 - (t - p) * (y - x), -((t - p) * (x + y)), by
      linear_combination hodd - (t - p) * h2⟩
  obtain ⟨n, hn⟩ := Int.sq_of_isCoprime hcopuv hprod
  have hsq : c - a = n ^ 2 := by
    rcases hn with hn | hn
    · exact hn
    · nlinarith [sq_nonneg n]
  have hn0 : n ≠ 0 := by
    rintro rfl
    simp at hsq
    omega
  refine ⟨|n|, abs_pos.mpr hn0, ?_, by rw [sq_abs]; exact hsq⟩
  rcases Int.even_or_odd |n| with ⟨u, hu⟩ | ho
  · exfalso
    have habs : c - a = (u + u) ^ 2 := by rw [← sq_abs n] at hsq; rw [hsq, hu]
    have e : 4 * u ^ 2 = 2 * (t - p) + 1 := by rw [habs] at hodd; linarith [hodd]
    generalize u ^ 2 = U at e
    omega
  · exact ho

/-- **Charge quantization, odd first leg.**  If the first leg is odd — which is the case at
every node of the Berggren tree — the charge is exactly *twice a square*.  This is why the
star in the plot has spokes labelled `2, 8, 18, 32, 50, …`. -/
theorem charge_quantization_odd_leg {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a)
    (hb : 0 < b) (hc : 0 < c) (hcop : IsCoprime a b) (hao : Odd a) :
    ∃ n : ℤ, 0 < n ∧ c - a = 2 * n ^ 2 := by
  have hca : 0 < c - a := by nlinarith
  have hco : Odd c := hyp_odd h hcop
  obtain ⟨x, y, hxy⟩ := isCoprime_leg_hyp h hcop
  -- `b` is even and `(c−a)/2`, `(c+a)/2` are coprime with product `(b/2)²`
  have hbe : Even b := by
    rcases Int.even_or_odd b with hbe | hbo
    · exact hbe
    · exact absurd (not_both_odd h hao hbo) (fun hf => hf)
  obtain ⟨b', hb'⟩ := hbe
  obtain ⟨k, hk⟩ := hao
  obtain ⟨t, ht⟩ := hco
  obtain ⟨u, hu⟩ : ∃ u, c - a = 2 * u := ⟨t - k, by omega⟩
  obtain ⟨v, hv⟩ : ∃ v, c + a = 2 * v := ⟨t + k + 1, by omega⟩
  have hprod : u * v = b' ^ 2 := by nlinarith
  have hcuv : c = u + v := by omega
  have hauv : a = v - u := by omega
  have hcopuv : IsCoprime u v := by
    refine ⟨y - x, x + y, ?_⟩
    rw [hcuv, hauv] at hxy
    linear_combination hxy
  obtain ⟨n, hn⟩ := Int.sq_of_isCoprime hcopuv hprod
  have hupos : 0 < u := by omega
  have hsq : u = n ^ 2 := by
    rcases hn with hn | hn
    · exact hn
    · nlinarith [sq_nonneg n]
  have hn0 : n ≠ 0 := by
    rintro rfl
    simp at hsq
    omega
  exact ⟨|n|, abs_pos.mpr hn0, by rw [sq_abs]; omega⟩

/-- **Charge quantization.**  For a primitive Pythagorean triple with positive entries the
Lorentz charge `c − a` at the ideal point `(1,0)` is either twice a square or an odd
square, according to the parity of the first leg.  Hence the spokes of the star are
indexed by a set of density zero. -/
theorem charge_quantization {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hcop : IsCoprime a b) :
    (∃ n : ℤ, 0 < n ∧ c - a = 2 * n ^ 2) ∨ (∃ n : ℤ, 0 < n ∧ Odd n ∧ c - a = n ^ 2) := by
  rcases Int.even_or_odd a with hae | hao
  · exact Or.inr (charge_quantization_even_leg h ha hb hc hcop hae)
  · exact Or.inl (charge_quantization_odd_leg h ha hb hc hcop hao)

/-! ### Every allowed charge really occurs -/

/-- The primitive triple `(2n+1, 2n²+2n, 2n²+2n+1)` realises the even charge `2n²`. -/
theorem charge_even_realized (n : ℤ) (hn : 0 < n) :
    ∃ a b c : ℤ, a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b ∧ IsCoprime a b ∧ c - a = 2 * n ^ 2 := by
  refine ⟨2 * n + 1, 2 * n ^ 2 + 2 * n, 2 * n ^ 2 + 2 * n + 1, by ring, by omega, by nlinarith,
    ⟨2 * n + 1, -2, by ring⟩, by ring⟩

/-- The primitive triple `(4h, 4h²−1, 4h²+1)` realises the odd charge `(2h−1)²`. -/
theorem charge_odd_realized (m : ℤ) (hm : 0 < m) :
    ∃ a b c : ℤ, a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b ∧ IsCoprime a b ∧
      c - a = (2 * m - 1) ^ 2 := by
  refine ⟨4 * m, 4 * m ^ 2 - 1, 4 * m ^ 2 + 1, by ring, by omega, by nlinarith,
    ⟨m, -1, by ring⟩, by ring⟩

/-- **The spectrum of the star.**  A positive integer `d` is the charge of some primitive
Pythagorean triple (i.e. indexes a spoke of the star at the ideal point `(1,0)`) if and
only if `d` is twice a square or an odd square. -/
theorem charge_spectrum (d : ℤ) (hd : 0 < d) :
    (∃ a b c : ℤ, a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b ∧ IsCoprime a b ∧ c - a = d) ↔
      ((∃ n : ℤ, 0 < n ∧ d = 2 * n ^ 2) ∨ (∃ n : ℤ, 0 < n ∧ Odd n ∧ d = n ^ 2)) := by
  constructor
  · rintro ⟨a, b, c, h, ha, hb, hcop, rfl⟩
    rcases charge_quantization h ha hb (by nlinarith) hcop with ⟨n, hn, hval⟩ | ⟨n, hn, hodd, hval⟩
    · exact Or.inl ⟨n, hn, hval⟩
    · exact Or.inr ⟨n, hn, hodd, hval⟩
  · rintro (⟨n, hn, rfl⟩ | ⟨n, hn, hodd, rfl⟩)
    · obtain ⟨a, b, c, h1, h2, h3, h4, h5⟩ := charge_even_realized n hn
      exact ⟨a, b, c, h1, h2, h3, h4, h5⟩
    · obtain ⟨m, hm⟩ := hodd
      have hm0 : 0 < m + 1 := by nlinarith
      obtain ⟨a, b, c, h1, h2, h3, h4, h5⟩ := charge_odd_realized (m + 1) hm0
      refine ⟨a, b, c, h1, h2, h3, h4, ?_⟩
      rw [h5, hm]
      ring

/-- **The spectrum inside the tree.**  Every node of the Berggren tree has odd first leg,
and for odd first leg the charge spectrum is exactly `{2n² : n ≥ 1}`: the spokes of the
star seen in the plot are labelled `2, 8, 18, 32, 50, …`. -/
theorem charge_spectrum_odd_leg (d : ℤ) (hd : 0 < d) :
    (∃ a b c : ℤ, a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b ∧ Odd a ∧ IsCoprime a b ∧ c - a = d) ↔
      ∃ n : ℤ, 0 < n ∧ d = 2 * n ^ 2 := by
  constructor
  · rintro ⟨a, b, c, h, ha, hb, hao, hcop, rfl⟩
    exact charge_quantization_odd_leg h ha hb (by nlinarith) hcop hao
  · rintro ⟨n, hn, rfl⟩
    exact ⟨2 * n + 1, 2 * n ^ 2 + 2 * n, 2 * n ^ 2 + 2 * n + 1, by ring, by omega, by nlinarith,
      ⟨n, by ring⟩, ⟨2 * n + 1, -2, by ring⟩, by ring⟩

/-! ### The hyperbolic generator and the Pell recursion -/

/-- The hypotenuse along the hyperbolic generator satisfies the Pell recursion
`c'' = 6c' − c`, whose characteristic roots are the units `3 ± 2√2 = (1 ± √2)²`.
Remarkably this holds pointwise, for every vector, because the `(−1)`-eigenvector
`(1,−1,0)` of `mB` has vanishing third coordinate. -/
theorem mB_hyp_recurrence (v : Vec) :
    (mB (mB v)).2.2 = 6 * (mB v).2.2 - v.2.2 := by
  obtain ⟨a, b, c⟩ := v; simp only [mB]; ring

/-- One step of the hyperbolic generator multiplies the hypotenuse by at least `5`, since
`a + b ≥ c` on the light cone.  (Compare the crude factor `3` of `mB_hyp_growth`; the true
rate is `3 + 2√2 ≈ 5.828`.) -/
theorem mB_step_five {v : Vec} (h : OnCone v) (h1 : 0 < v.1) (h2 : 0 < v.2.1) :
    5 * v.2.2 ≤ (mB v).2.2 := by
  obtain ⟨a, b, c⟩ := v
  simp only at h1 h2 ⊢
  rw [onCone_iff] at h
  have hab : c ≤ a + b := by nlinarith
  simp only [mB]
  omega

/-- Consequently the hyperbolic branch grows at least like `5^k`. -/
theorem mB_hyp_five_growth {a b c : ℤ} (h : OnCone (a, b, c)) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (k : ℕ) :
    5 * (mB^[k] (a, b, c)).2.2 ≤ (mB^[k + 1] (a, b, c)).2.2 := by
  obtain ⟨_, hp1, hp2⟩ := mB_iterate_growth ha hb hc k
  rw [Function.iterate_succ_apply']
  exact mB_step_five (onCone_mB_iterate h k) hp1 hp2

end BerggrenStars