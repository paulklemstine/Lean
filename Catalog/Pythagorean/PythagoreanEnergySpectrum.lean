import Mathlib

/-!
# Pythagorean Energy Spectrum: A Convex Energy Functional Guiding Fermat Descent to a Factor

This file develops, in a fully formal and self-contained way, the mathematics behind
the "Pythagorean-Energy-Spectrum" idea: a strictly convex **energy functional**
`E N s = s² − N` whose associated integer "spectrum" detects and locates a
non-trivial factor of an odd number `N` via Fermat's difference–of–squares method,
together with the **Berggren tree** bridge that ties the underlying quadratic form
to primitive Pythagorean triples.

The three pillars proved here are:

## 1. Fermat factorization (`factor_from_repr`, `composite_iff_diff_squares`)
An odd `N` is composite **iff** the hyperbola `s² = N + t²` carries a
non-trivial integer point (one with `1 < s − t`).  Every such point yields the
explicit non-trivial factor `s − t` of `N`, and conversely every non-trivial
factorization yields such a point.  This is the exact statement that makes the
"gradient descent on the energy spectrum" a *provably correct* factoring procedure.

## 2. The energy functional and its strict convexity (`energy_strictConvexOn`, …)
`E N s = s² − N` is strictly convex on all of `ℝ`, strictly monotone on `[0,∞)`,
and takes the value `t²` at the abscissa `s` of the factor pair.  Consequently the
*most balanced* factorization is exactly the one of least energy, so descending the
energy spectrum from `⌈√N⌉` upward reaches a factor deterministically
(`balanced_minimizes_energy`, `energy_lt_of_more_balanced`).

## 3. The Berggren bridge (`bergA_pyth`, `bergA_hyp_grow`, `leg_sq_factorization`)
The three Berggren matrices preserve the Pythagorean relation and strictly grow the
hypotenuse, and every triple encodes a factorization of a square via
`a² = (c − b)(c + b)`, tying the tree of triples to the difference-of-squares form
used by the energy spectrum.
-/

namespace PythagoreanEnergySpectrum

/-! ## Section 1. Fermat difference-of-squares factorization -/

/-- From a non-trivial integer point `(s, t)` on the hyperbola `s² = N + t²`
(with `0 ≤ t` and `1 < s − t`), the quantity `s − t` is a **proper divisor** of `N`:
it divides `N` and lies strictly between `1` and `N`. -/
theorem factor_from_repr {N s t : ℤ} (h : s ^ 2 = N + t ^ 2)
    (ht : 0 ≤ t) (h1 : 1 < s - t) :
    (s - t) ∣ N ∧ 1 < s - t ∧ s - t < N := by
  have hprod : (s - t) * (s + t) = N := by nlinarith [h]
  exact ⟨⟨s + t, hprod.symm⟩, h1, by nlinarith [hprod, h1, ht]⟩

/-- The complementary factor `s + t` is also a proper divisor of `N`. -/
theorem cofactor_from_repr {N s t : ℤ} (h : s ^ 2 = N + t ^ 2)
    (ht : 0 ≤ t) (h1 : 1 < s - t) :
    (s + t) ∣ N ∧ 1 < s + t ∧ s + t < N := by
  have hprod : (s + t) * (s - t) = N := by nlinarith [h]
  exact ⟨⟨s - t, hprod.symm⟩, by nlinarith, by nlinarith [hprod, h1, ht]⟩

/-- **Helper (forward, ordered case).**  A factorization `N = d * e` of an odd number
into two odd factors with `1 < d ≤ e` produces a non-trivial point on `s² = N + t²`,
namely `s = (d+e)/2`, `t = (e−d)/2`. -/
theorem repr_of_le {N d e : ℤ} (hN : N = d * e) (hd : Odd d) (he : Odd e)
    (h1 : 1 < d) (hde : d ≤ e) :
    ∃ s t : ℤ, 0 ≤ t ∧ 1 < s - t ∧ s ^ 2 = N + t ^ 2 := by
  obtain ⟨k, hk⟩ := hd
  obtain ⟨m, hm⟩ := he
  exact ⟨k + m + 1, m - k, by omega, by omega, by subst hN hk hm; ring⟩

/-- **Fermat's criterion.**  For odd `N`, being composite (having a proper divisor)
is equivalent to the existence of a non-trivial integer point on the hyperbola
`s² = N + t²`.  This is the correctness statement of difference-of-squares factoring. -/
theorem composite_iff_diff_squares {N : ℤ} (hN : Odd N) :
    (∃ d : ℤ, d ∣ N ∧ 1 < d ∧ d < N) ↔
    (∃ s t : ℤ, 0 ≤ t ∧ 1 < s - t ∧ s ^ 2 = N + t ^ 2) := by
  constructor
  · rintro ⟨d, ⟨e, he⟩, hd1, hdN⟩
    have hepos : 0 < e := by nlinarith [he, hd1]
    have he1 : 1 < e := by nlinarith [he, hd1, hdN]
    have hodd : Odd (d * e) := he ▸ hN
    obtain ⟨hdodd, heodd⟩ := Int.odd_mul.mp hodd
    rcases le_total d e with hle | hle
    · exact repr_of_le he hdodd heodd hd1 hle
    · exact repr_of_le (by rw [he, mul_comm]) heodd hdodd he1 hle
  · rintro ⟨s, t, ht, h1, h⟩
    obtain ⟨hdvd, hlo, hhi⟩ := factor_from_repr h ht h1
    exact ⟨s - t, hdvd, hlo, hhi⟩

/-! ## Section 2. The energy functional and its convexity -/

/-- The **energy functional** of the spectrum: `E N s = s² − N` (over the reals). -/
def energy (N : ℝ) (s : ℝ) : ℝ := s ^ 2 - N

/-- Unfolding lemma for the energy functional. -/
theorem energy_eq (N s : ℝ) : energy N s = s ^ 2 - N := rfl

/-- **Strict convexity** of the energy functional on all of `ℝ`. -/
theorem energy_strictConvexOn (N : ℝ) :
    StrictConvexOn ℝ Set.univ (energy N) := by
  have h : StrictConvexOn ℝ Set.univ (fun s : ℝ => s ^ 2) :=
    Even.strictConvexOn_pow (by norm_num) (by norm_num)
  have h2 := h.add_const (-N)
  simpa [energy, sub_eq_add_neg] using h2

/-- The energy is strictly monotone on the search region `[0, ∞)`:
increasing `s` strictly increases the energy, so the abscissa scan is deterministic. -/
theorem energy_strictMonoOn (N : ℝ) :
    StrictMonoOn (energy N) (Set.Ici 0) := by
  intro a ha b hb hab
  simp only [Set.mem_Ici] at ha hb
  simp only [energy]
  nlinarith

/-- **Energy at a factor pair.**  At the abscissa `s = (d+e)/2` of the factorization
`N = d·e`, the energy equals the square of the half-difference `t = (e−d)/2`.
Thus the energy spectrum `{E N s}` over valid `s` consists of perfect squares,
and its value measures the *imbalance* of the factorization. -/
theorem energy_at_factor (d e : ℝ) :
    energy (d * e) ((d + e) / 2) = ((e - d) / 2) ^ 2 := by
  unfold energy; ring

/-- **Balanced factorization minimizes the abscissa.**  Among integer points of the
same `N` with non-negative coordinates, a smaller half-difference `t` forces a smaller
abscissa `s`.  The more balanced the factorization, the closer `s` is to `√N`. -/
theorem balanced_minimizes_energy {N s₁ t₁ s₂ t₂ : ℤ}
    (h₁ : s₁ ^ 2 = N + t₁ ^ 2) (h₂ : s₂ ^ 2 = N + t₂ ^ 2)
    (ht₁ : 0 ≤ t₁) (hs₁ : 0 ≤ s₁) (hs₂ : 0 ≤ s₂)
    (hlt : t₁ < t₂) : s₁ < s₂ := by
  nlinarith [h₁, h₂, ht₁, hs₁, hs₂, hlt, sq_nonneg (s₁ - s₂)]

/-- **Corollary (descent picks the balanced factor).**  A more balanced integer point
has strictly smaller energy.  Hence gradient descent on the strictly convex energy
spectrum reaches the factorization closest to `√N` first. -/
theorem energy_lt_of_more_balanced {N s₁ t₁ s₂ t₂ : ℤ}
    (h₁ : s₁ ^ 2 = N + t₁ ^ 2) (h₂ : s₂ ^ 2 = N + t₂ ^ 2)
    (ht₁ : 0 ≤ t₁) (hs₁ : 0 ≤ s₁) (hs₂ : 0 ≤ s₂)
    (hlt : t₁ < t₂) : energy (N : ℝ) (s₁ : ℝ) < energy (N : ℝ) (s₂ : ℝ) := by
  have hlt' : s₁ < s₂ := balanced_minimizes_energy h₁ h₂ ht₁ hs₁ hs₂ hlt
  refine energy_strictMonoOn (N : ℝ) (Set.mem_Ici.mpr ?_) (Set.mem_Ici.mpr ?_) ?_
  · exact_mod_cast hs₁
  · exact_mod_cast hs₂
  · exact_mod_cast hlt'

/-! ## Section 3. The Berggren tree bridge -/

/-- Berggren forward transform `A` on a triple `(a,b,c)`. -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren forward transform `B`. -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren forward transform `C`. -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Predicate: `(a,b,c)` satisfies the Pythagorean relation. -/
def IsPyth (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren `A` preserves the Pythagorean relation. -/
theorem bergA_pyth {a b c : ℤ} (h : IsPyth a b c) :
    IsPyth (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  simp only [IsPyth, bergA] at h ⊢; nlinarith [h]

/-- Berggren `B` preserves the Pythagorean relation. -/
theorem bergB_pyth {a b c : ℤ} (h : IsPyth a b c) :
    IsPyth (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  simp only [IsPyth, bergB] at h ⊢; nlinarith [h]

/-- Berggren `C` preserves the Pythagorean relation. -/
theorem bergC_pyth {a b c : ℤ} (h : IsPyth a b c) :
    IsPyth (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  simp only [IsPyth, bergC] at h ⊢; nlinarith [h]

/-- Berggren `A` strictly grows the hypotenuse on positive triples. -/
theorem bergA_hyp_grow {a b c : ℤ} (h : IsPyth a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (bergA a b c).2.2 := by
  simp only [IsPyth] at h
  simp only [bergA]
  nlinarith [sq_nonneg (a - b), sq_nonneg (c - b), h]

/-- The root `(3,4,5)` is a Pythagorean triple. -/
theorem root_pyth : IsPyth 3 4 5 := by unfold IsPyth; norm_num

/-- **Leg–square factorization bridge.**  In any Pythagorean triple, the square of a
leg factors as a difference of squares of the hypotenuse and the other leg:
`a² = (c − b)(c + b)`.  For a non-degenerate triple this is a genuine factorization
of `a²`, connecting the Berggren tree of triples to the difference-of-squares form
underlying the energy spectrum. -/
theorem leg_sq_factorization {a b c : ℤ} (h : IsPyth a b c) :
    a ^ 2 = (c - b) * (c + b) := by
  simp only [IsPyth] at h; nlinarith [h]

/-! ## Section 4. A deterministic Fermat factoring algorithm

The existence theorem `composite_iff_diff_squares` is upgraded here to an explicit,
*computable* procedure `fermatSearch : ℕ → Option (ℕ × ℕ)` that scans the energy
spectrum abscissae `t = 0, 1, 2, …` and returns the first difference-of-squares
factor pair it finds.  We prove it is **correct in both directions**:

* `fermatSearch_sound`: whatever pair it returns is a genuine proper factorization
  `d * e = N` with `1 < d < N`;
* `fermatSearch_complete`: for every odd composite `N` it returns `some` pair.

Together these make the "gradient descent on the energy spectrum reaches a factor"
slogan a literal theorem about a terminating algorithm. -/

/-- Deterministic Fermat difference-of-squares search over `ℕ`.  For each candidate
half-difference `t = 0, …, N`, set `m = N + t²` and `s = ⌊√m⌋`; if `m` is a perfect
square and `1 < s - t`, return the factor pair `(s - t, s + t)`.  The scan runs in the
order of increasing `t`, i.e. increasing energy `E = t²`, so it returns the *most
balanced* factorization first. -/
def fermatSearch (N : ℕ) : Option (ℕ × ℕ) :=
  (List.range (N + 1)).findSome? fun t =>
    let m := N + t * t
    let s := Nat.sqrt m
    if s * s = m ∧ t < s ∧ 1 < s - t then some (s - t, s + t) else none

/-- **Soundness of the search.**  Any pair returned by `fermatSearch N` is a genuine
non-trivial factorization of `N`: the two components multiply to `N`, and the smaller
one is a proper divisor strictly between `1` and `N`. -/
theorem fermatSearch_sound {N d e : ℕ} (h : fermatSearch N = some (d, e)) :
    d * e = N ∧ 1 < d ∧ d < N := by
  rw [fermatSearch, List.findSome?_eq_some_iff] at h
  obtain ⟨l₁, t, l₂, _, hf, _⟩ := h
  simp only at hf
  split_ifs at hf with hc
  obtain ⟨hsq, hts, h1⟩ := hc
  rw [Option.some.injEq, Prod.mk.injEq] at hf
  obtain ⟨hd, he⟩ := hf
  subst hd he
  set s := Nat.sqrt (N + t * t) with hs
  have hts' : t ≤ s := le_of_lt hts
  have hprod : (s - t) * (s + t) = N := by
    zify [hts']
    nlinarith [hsq]
  refine ⟨hprod, h1, ?_⟩
  have he2 : 2 ≤ s + t := by omega
  nlinarith [hprod, h1, he2, Nat.sub_le s t]

/-- **Completeness of the search.**  For every odd composite `N`, the search succeeds
(returns a factor pair rather than `none`). -/
theorem fermatSearch_complete {N : ℕ} (hodd : Odd N)
    (hcomp : ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N) :
    ∃ p : ℕ × ℕ, fermatSearch N = some p := by
  obtain ⟨d, hdvd, hd1, hdN⟩ := hcomp
  obtain ⟨e, he⟩ := hdvd
  have hNpos : 0 < N := by omega
  have he1 : 1 < e := by
    rcases Nat.lt_or_ge e 2 with h | h
    · interval_cases e <;> omega
    · omega
  set a := min d e with ha
  set b := max d e with hb
  have hab : a * b = N := by
    rcases le_total d e with hle | hle
    · simp only [ha, hb, min_eq_left hle, max_eq_right hle]; omega
    · simp only [ha, hb, min_eq_right hle, max_eq_left hle]; rw [mul_comm]; omega
  have haodd : Odd a := (Nat.odd_mul.mp (hab ▸ hodd)).1
  have hbodd : Odd b := (Nat.odd_mul.mp (hab ▸ hodd)).2
  have ha1 : 1 < a := by
    rcases le_total d e with hle | hle <;> simp only [ha, min_eq_left, min_eq_right, hle] <;> omega
  obtain ⟨i, hi⟩ := haodd
  obtain ⟨j, hj⟩ := hbodd
  have hij : i ≤ j := by
    have : a ≤ b := min_le_max
    omega
  set t := j - i with ht
  set s := i + j + 1 with hs
  have hst : N + t * t = s * s := by
    rw [ht, hs, ← hab, hi, hj]; zify [hij]; ring
  have hbN : b ≤ N := by
    have : b ≤ a * b := Nat.le_mul_of_pos_left b (by omega)
    omega
  have hne : fermatSearch N ≠ none := by
    rw [fermatSearch, Ne, List.findSome?_eq_none_iff]
    push_neg
    refine ⟨t, ?_, ?_⟩
    · rw [List.mem_range]; omega
    · simp only
      have hsqrt : Nat.sqrt (N + t * t) = s := by rw [hst, ← pow_two]; exact Nat.sqrt_eq' s
      rw [hsqrt, if_pos]
      · exact Option.some_ne_none _
      · exact ⟨hst.symm, by omega, by omega⟩
  exact Option.ne_none_iff_exists'.mp hne

end PythagoreanEnergySpectrum