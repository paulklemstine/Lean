import Algebra.EulerTwoSquaresCount
import Algebra.EulerTwoSquaresCost

/-!
# An unconditional quartic barrier for representation search

Euler's method has to *find* two essentially distinct representations `N = a²+b² = c²+d²`.
The natural search walks the smaller part upward, `1, 2, 3, …`, testing whether `N - a²` is a
square.  How far must such a walk go before it has seen **both** representations?

This file answers that with an exact, unconditional inequality.  Write the two
representations in sorted form `a ≤ b`, `c ≤ d`.  If they are different then their large
parts differ, say `d < b`, hence `b ≥ d + 1` and therefore

`c² = b² - d² + a² ≥ 2d + 1`,   while   `2N = 2c² + 2d² ≤ 4d² < (2d+1)²`,

so `2N < c⁴`.  In other words **the larger of the two small parts exceeds `(2N)^{1/4}`**
(`EulerTwoSquares.quartic_barrier`, `EulerTwoSquares.euler_scan_quartic_bound`).  No primality,
no genericity, no averaging: two distinct representations simply cannot both be "shallow".

Combined with `EulerTwoSquares.fermat_halts_immediately_iff` this gives the sharpest form of
the cost comparison (`EulerTwoSquares.euler_loses_on_balanced`): on a balanced eligible
semiprime — where Fermat's difference-of-squares scan succeeds on its *first* trial — any
representation search that collects both representations must reach a bound `t` with
`t⁴ > 2N`, i.e. `t > (2N)^{1/4}`.  The measured constant-factor loss of the representation
route is therefore not an artefact of the sampling distribution on the balanced side: it is
forced.
-/

namespace EulerTwoSquares

/-! ## The barrier -/

/-- **Quartic barrier with a gap.**  If the larger parts of two sorted representations of `N`
are `k` apart, `d + k ≤ b`, then the small part of the shallower-looking representation obeys
`2k²N < c⁴`.  The gap enters quadratically. -/
theorem quartic_barrier_gap {N a b c d k : ℤ} (ha : 0 ≤ a) (hab : a ≤ b) (hc : 0 ≤ c)
    (hcd : c ≤ d) (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) (hk : 0 < k)
    (hgap : d + k ≤ b) : 2 * k ^ 2 * N < c ^ 4 := by
  have hd0 : 0 ≤ d := le_trans hc hcd
  have hc2 : 2 * k * d + k ^ 2 ≤ c ^ 2 := by nlinarith
  have h2kd : 0 ≤ 2 * k * d := by nlinarith
  have hk2 : 0 < k ^ 2 := by positivity
  have hXpos : 0 < 2 * k * d + k ^ 2 := by linarith
  have hsq : (2 * k * d + k ^ 2) ^ 2 ≤ (c ^ 2) ^ 2 := by
    nlinarith [mul_nonneg (sub_nonneg.2 hc2) (by linarith : (0 : ℤ) ≤ c ^ 2 + (2 * k * d + k ^ 2))]
  have hexp : (2 * k * d + k ^ 2) ^ 2 = 4 * k ^ 2 * d ^ 2 + 4 * k ^ 3 * d + k ^ 4 := by ring
  have hc4 : c ^ 4 = (c ^ 2) ^ 2 := by ring
  have hNd : N ≤ 2 * d ^ 2 := by nlinarith
  have hNk : 2 * k ^ 2 * N ≤ 4 * k ^ 2 * d ^ 2 := by
    nlinarith [mul_nonneg hk2.le (sub_nonneg.2 hNd)]
  have hk4 : 0 < k ^ 4 := by positivity
  have hk3d : 0 ≤ 4 * k ^ 3 * d := by positivity
  linarith

/-- **Quartic barrier, sorted form.**  Two representations of the same `N` in sorted form whose
larger parts satisfy `d < b` force `2N < c⁴`, where `c` is the small part of the *second*
representation. -/
theorem quartic_barrier {N a b c d : ℤ} (ha : 0 ≤ a) (hab : a ≤ b) (hc : 0 ≤ c) (hcd : c ≤ d)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) (hlt : d < b) : 2 * N < c ^ 4 := by
  have := quartic_barrier_gap (k := 1) ha hab hc hcd h1 h2 one_pos (by linarith)
  linarith [this]

/-- **Three representations cost twice as much depth.**  If `N` has three representations in
sorted form whose large parts are strictly decreasing, `b₃ < b₂ < b₁`, then the small part of
the shallowest one satisfies `8N < a₃⁴`: the barrier grows quadratically in the number of
representations.  (The middle representation is used only to force a gap of `2`.) -/
theorem quartic_barrier_three {N a₁ b₁ a₃ b₃ b₂ : ℤ} (h1 : 0 ≤ a₁) (hab1 : a₁ ≤ b₁)
    (h3 : 0 ≤ a₃) (hab3 : a₃ ≤ b₃) (e1 : a₁ ^ 2 + b₁ ^ 2 = N) (e3 : a₃ ^ 2 + b₃ ^ 2 = N)
    (hlt1 : b₃ < b₂) (hlt2 : b₂ < b₁) : 8 * N < a₃ ^ 4 := by
  have := quartic_barrier_gap (k := 2) h1 hab1 h3 hab3 e1 e3 two_pos (by linarith)
  linarith [this]

/-- The same statement symmetrised: the *larger* of the two small parts always exceeds
`(2N)^{1/4}`. -/
theorem quartic_barrier_sorted {N a b c d : ℤ} (ha : 0 ≤ a) (hab : a ≤ b) (hc : 0 ≤ c)
    (hcd : c ≤ d) (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) (hne : ¬(a = c ∧ b = d)) :
    2 * N < max a c ^ 4 := by
  have hbd : b ≠ d := by
    intro hbd
    refine hne ⟨?_, hbd⟩
    have hac : a ^ 2 = c ^ 2 := by rw [hbd] at h1; linarith
    nlinarith
  rcases lt_trichotomy d b with hlt | heq | hlt
  · have h := quartic_barrier ha hab hc hcd h1 h2 hlt
    have hle : c ^ 4 ≤ max a c ^ 4 := by
      have : c ≤ max a c := le_max_right _ _
      exact pow_le_pow_left₀ hc this 4
    linarith
  · exact absurd heq.symm hbd
  · have h := quartic_barrier hc hcd ha hab h2 h1 hlt
    have hle : a ^ 4 ≤ max a c ^ 4 := by
      have : a ≤ max a c := le_max_left _ _
      exact pow_le_pow_left₀ ha this 4
    linarith

/-- **The cost of collecting both representations.**  If a search bound `t` is large enough to
have reached the smaller part of each of two essentially distinct representations of `N`, then
`2N < t⁴`.  Equivalently, the search must run past `(2N)^{1/4}`. -/
theorem euler_scan_quartic_bound {N a b c d t : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N)
    (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b))
    (hta : min a b ≤ t) (htc : min c d ≤ t) : 2 * N < t ^ 4 := by
  have hkey : 2 * N < max (min a b) (min c d) ^ 4 := by
    have h2' : b ^ 2 + a ^ 2 = N := by linarith
    have h2'' : d ^ 2 + c ^ 2 = N := by linarith
    rcases le_total a b with hx | hx <;> rcases le_total c d with hy | hy
    · rw [min_eq_left hx, min_eq_left hy]
      exact quartic_barrier_sorted ha.le hx hc.le hy h1 h2
        (fun hh => hne1 ⟨hh.1.symm, hh.2.symm⟩)
    · rw [min_eq_left hx, min_eq_right hy]
      exact quartic_barrier_sorted ha.le hx hd.le hy h1 h2''
        (fun hh => hne2 ⟨hh.1.symm, hh.2.symm⟩)
    · rw [min_eq_right hx, min_eq_left hy]
      exact quartic_barrier_sorted hb.le hx hc.le hy h2' h2
        (fun hh => hne2 ⟨hh.2.symm, hh.1.symm⟩)
    · rw [min_eq_right hx, min_eq_right hy]
      exact quartic_barrier_sorted hb.le hx hd.le hy h2' h2''
        (fun hh => hne1 ⟨hh.2.symm, hh.1.symm⟩)
  have hmax : max (min a b) (min c d) ≤ t := max_le hta htc
  have hmax0 : (0 : ℤ) ≤ max (min a b) (min c d) :=
    le_max_of_le_left (le_min ha.le hb.le)
  have : max (min a b) (min c d) ^ 4 ≤ t ^ 4 := pow_le_pow_left₀ hmax0 hmax 4
  linarith

/-! ## EULER-LOSES on balanced instances -/

variable {p q : ℕ}

/-- **The cost comparison, in its sharpest form.**  Let `p ≠ q` be primes `≡ 1 [MOD 4]` with
mid-point `u = (p+q)/2` and half-gap `v = (q-p)/2`, and suppose the pair is balanced in the
precise sense `v² < 2u`.  Then

* Fermat's difference-of-squares scan succeeds on its **first** trial, `⌊√(pq)⌋ + 1 = u`; while
* the two representations of `pq` exist, are essentially distinct, and **any** search bound `t`
  that reaches the smaller part of both satisfies `2·pq < t⁴`.

So on exactly the instances where the competing method is instantaneous, the representation
route is forced to run past `(2N)^{1/4}` — twice. -/
theorem euler_loses_on_balanced (hp : p.Prime) (hq : q.Prime) (hp4 : p % 4 = 1)
    (hq4 : q % 4 = 1) (hpq : p ≠ q) {u v : ℕ} (hu : p + q = 2 * u) (hv : q = p + 2 * v)
    (hv0 : 0 < v) (hbal : v ^ 2 < 2 * u) :
    Nat.sqrt (p * q) + 1 = u ∧
      ∃ A B C D : ℤ, 0 < A ∧ 0 < B ∧ 0 < C ∧ 0 < D ∧
        A ^ 2 + B ^ 2 = (p : ℤ) * q ∧ C ^ 2 + D ^ 2 = (p : ℤ) * q ∧
        ¬(C = A ∧ D = B) ∧ ¬(D = A ∧ C = B) ∧
        ∀ t : ℤ, min A B ≤ t → min C D ≤ t → 2 * ((p : ℤ) * q) < t ^ 4 := by
  refine ⟨(fermat_halts_immediately_iff hu hv hv0).2 hbal, ?_⟩
  obtain ⟨A, B, C, D, hA, hB, hC, hD, hAB, hCD, hne1, hne2, -⟩ :=
    exactly_two_reps hp hq hp4 hq4 hpq
  exact ⟨A, B, C, D, hA, hB, hC, hD, hAB, hCD, hne1, hne2,
    fun t htA htC => euler_scan_quartic_bound hA hB hC hD hAB hCD hne1 hne2 htA htC⟩

/-- **Non-vacuity.**  `N = 13 · 17 = 221` is a balanced eligible instance: Fermat's scan
succeeds on its first trial (`⌊√221⌋ + 1 = 15`), while both representations
`221 = 5² + 14² = 10² + 11²` can only be collected by a search reaching past `(2·221)^{1/4}`. -/
theorem euler_loses_at_221 :
    Nat.sqrt (13 * 17) + 1 = 15 ∧
      ∃ A B C D : ℤ, 0 < A ∧ 0 < B ∧ 0 < C ∧ 0 < D ∧
        A ^ 2 + B ^ 2 = (13 : ℤ) * 17 ∧ C ^ 2 + D ^ 2 = (13 : ℤ) * 17 ∧
        ¬(C = A ∧ D = B) ∧ ¬(D = A ∧ C = B) ∧
        ∀ t : ℤ, min A B ≤ t → min C D ≤ t → 2 * ((13 : ℤ) * 17) < t ^ 4 := by
  have h := euler_loses_on_balanced (p := 13) (q := 17) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (u := 15) (v := 2) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)
  exact_mod_cast h

end EulerTwoSquares