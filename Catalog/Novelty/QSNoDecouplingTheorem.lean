import Mathlib
import Shared.QSRelationPoolRandom
import Shared.SmoothCountSparsity
import Shared.QSFactorBaseDimension
/-!
# No-decoupling for quadratic-form sieving: the three channels, as theorems

Round 43 claims that the large-prime, multi-polynomial and adaptive-`B` channels of the
quadratic sieve cannot move the column space off the *split set* of the modulus, and that
the reason is one structural identity: every form whose discriminant is tied to `N` turns a
prime divisor of a value into a square root of that discriminant.

This file proves that claim, building on `QSRelationPool` (the quadratic-character
constraint for `x² − N`) and `QSDimension` (admissible primes and the `𝔽₂` dimension
argument).

* **Discriminant identity.**  `4A·f(x) = (2Ax+B)² − disc f` (`QForm.four_A_mul_eval`).
* **Columns force the split set.**  If `p ∣ f(x)` then `disc f` is a square mod `p`, for
  *every* prime, including `p ∣ A` (`QForm.isSquare_disc_of_dvd_eval`).
* **…and exhaust it.**  For odd `p ∤ A`, `p` divides some value of `f` *iff* `disc f` is a
  square mod `p` (`QForm.exists_dvd_eval_iff`).  So the column set of a form *is* the split
  set of its discriminant (off `2A`).
* **Multi-polynomial (Silverman).**  A family with a common discriminant `D` has the same
  column set for every member, contained in `admissiblePrimes D B`
  (`family_support_subset_admissible`); the conjunction of the identical constraints is one
  constraint (`sharedDisc_conjunction_eq`); and the discriminants `kN` and `4kN` (or any
  `D·s²`, `p ∤ s`) have the same split set (`isSquare_mul_sq_iff`).
* **Large prime.**  The large prime of a partial relation is itself split
  (`largePrime_isSplit`), and an LP-pair combines to a relation whose odd-exponent support
  lies in the *small* split set `admissiblePrimes N B` (`lpPair_oddSupport_subset`);
  raising the bound only enlarges the split set monotonically (`admissiblePrimes_mono`).
* **Row-side lever.**  With any number `T` of forms sharing `D`, `|admissiblePrimes D B| + 1`
  smooth values already produce a square: the column bound does not depend on `T`
  (`multipoly_congruence_of_squares`).
* **Complete-cost rule.**  The elasticity of a total cost `S + L` is the cost-share-weighted
  average of the elasticities (`hasDerivAt_log_total_cost`), so a negative sieve elasticity
  is compatible with a positive total one exactly when `l' > −s'`
  (`total_elasticity_pos_iff`, `sieve_only_sign_inversion`).
* **The gate.**  The minimax of `max(N/A, A·M² − N/A)` over `A` is `M·√(N/2)`
  (`silverman_minimax_lower`, `silverman_minimax_attained`); and at `N < 2⁴²` with
  `B, M ≥ 1000` the gate `B²·M ≤ √(N/2)` fails by a factor `> 600`
  (`gate_fails_at_42_bits`).
-/

namespace QSNoDecoupling

open QSRelationPool QSDimension

/-! ## Quadratic forms and the discriminant identity -/

/-- An integral quadratic polynomial `A x² + B x + C` (a Silverman sieve form). -/
structure QForm where
  A : ℤ
  B : ℤ
  C : ℤ

namespace QForm

/-- The value `A x² + B x + C`. -/
def eval (f : QForm) (x : ℤ) : ℤ := f.A * x ^ 2 + f.B * x + f.C

/-- The discriminant `B² − 4AC`. -/
def disc (f : QForm) : ℤ := f.B ^ 2 - 4 * f.A * f.C

/-- **Discriminant identity**: `4A·f(x) = (2Ax+B)² − disc f`. -/
theorem four_A_mul_eval (f : QForm) (x : ℤ) :
    4 * f.A * f.eval x = qsValue f.disc (2 * f.A * x + f.B) := by
  unfold eval disc qsValue; ring

/-- **Columns force the split set.**  Any prime (no restriction at all) dividing a value of
`f` makes the discriminant a square modulo it. -/
theorem isSquare_disc_of_dvd_eval (f : QForm) {p : ℕ} {x : ℤ}
    (h : (p : ℤ) ∣ f.eval x) : IsSquare (f.disc : ZMod p) := by
  apply isSquare_of_dvd_qsValue (x := 2 * f.A * x + f.B)
  rw [← four_A_mul_eval]
  exact Dvd.dvd.mul_left h _

/-- **The split set is exhausted.**  For an odd prime `p ∤ A`, `p` divides some value of
`f` iff `disc f` is a square mod `p`.  So the column set of a form equals the split set of
its discriminant. -/
theorem exists_dvd_eval_iff (f : QForm) {p : ℕ} [hp : Fact p.Prime] (hp2 : p ≠ 2)
    (hA : ¬ (p : ℤ) ∣ f.A) :
    (∃ x : ℤ, (p : ℤ) ∣ f.eval x) ↔ IsSquare (f.disc : ZMod p) := by
  constructor
  · rintro ⟨x, hx⟩; exact f.isSquare_disc_of_dvd_eval hx
  · rintro ⟨r, hr⟩
    have hA0 : (f.A : ZMod p) ≠ 0 := by
      rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
    have h2 : (2 : ZMod p) ≠ 0 := by
      intro h
      have : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
      rw [ZMod.natCast_eq_zero_iff] at this
      exact hp2 ((Nat.prime_dvd_prime_iff_eq hp.out Nat.prime_two).1 this)
    have h2A : (2 * (f.A : ZMod p)) ≠ 0 := mul_ne_zero h2 hA0
    set y : ZMod p := (r - f.B) * (2 * (f.A : ZMod p))⁻¹ with hy
    refine ⟨(y.val : ℤ), ?_⟩
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    have key : (4 * (f.A : ZMod p)) * ((f.eval (y.val : ℤ) : ℤ) : ZMod p) = 0 := by
      have := congrArg (fun z : ℤ => (z : ZMod p)) (four_A_mul_eval f (y.val : ℤ))
      simp only [qsValue] at this
      push_cast at this
      rw [this, ZMod.natCast_zmod_val]
      have hlin : 2 * (f.A : ZMod p) * y + f.B = r := by
        rw [hy]; field_simp; ring
      rw [hlin, hr]; ring
    have h4A : (4 * (f.A : ZMod p)) ≠ 0 := by
      have : (4 : ZMod p) = 2 * 2 := by norm_num
      rw [this]; exact mul_ne_zero (mul_ne_zero h2 h2) hA0
    exact (mul_eq_zero.1 key).resolve_left h4A

end QForm

/-! ## Multi-polynomial: a shared discriminant is one constraint -/

/-- Square classes are invariant under multiplication by a square: `D` and `D·s²` have the
same split set at every prime not dividing `s` (e.g. `kN` vs `4kN` at odd `p`). -/
theorem isSquare_mul_sq_iff {p : ℕ} [Fact p.Prime] (D s : ℤ) (hs : ¬ (p : ℤ) ∣ s) :
    IsSquare (((D * s ^ 2 : ℤ)) : ZMod p) ↔ IsSquare ((D : ZMod p)) := by
  have hs0 : (s : ZMod p) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  constructor
  · rintro ⟨r, hr⟩
    refine ⟨r * (s : ZMod p)⁻¹, ?_⟩
    have : (D : ZMod p) = (D * s ^ 2) * ((s : ZMod p)⁻¹) ^ 2 := by field_simp
    rw [this, hr]; ring
  · rintro ⟨r, hr⟩
    exact ⟨r * s, by rw [hr]; ring⟩

/-- **Multi-polynomial support theorem.**  For any family of forms sharing the discriminant
`D`, every prime `≤ B` dividing any value of any member is an admissible (split) prime of
`D`.  The union of the column sets over the whole family is inside the single-polynomial
split set. -/
theorem family_support_subset_admissible {τ : Type*} (F : τ → QForm) {D : ℤ}
    (hD : ∀ t, (F t).disc = D) {B : ℕ} (t : τ) (x : ℤ) {p : ℕ} (hp : p.Prime)
    (hpB : p ≤ B) (hdvd : (p : ℤ) ∣ (F t).eval x) :
    p ∈ admissiblePrimes D B := by
  classical
  have := (F t).isSquare_disc_of_dvd_eval hdvd
  rw [hD t] at this
  exact Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hp, hpB⟩, this⟩

/-- **Identical column sets.**  Two forms with the same discriminant have *the same*
columns at every odd prime dividing neither leading coefficient. -/
theorem sharedDisc_same_columns (f g : QForm) (hfg : f.disc = g.disc) {p : ℕ}
    [Fact p.Prime] (hp2 : p ≠ 2) (hf : ¬ (p : ℤ) ∣ f.A) (hg : ¬ (p : ℤ) ∣ g.A) :
    (∃ x, (p : ℤ) ∣ f.eval x) ↔ (∃ x, (p : ℤ) ∣ g.eval x) := by
  rw [f.exists_dvd_eval_iff hp2 hf, g.exists_dvd_eval_iff hp2 hg, hfg]

open Classical in
/-- **A conjunction of identical constraints equals one.**  The primes `≤ B` at which every
discriminant of a nonempty shared-discriminant family is a square are exactly the split
primes of `D` — the intersection does *not* shrink to `≈ 1/4`. -/
theorem sharedDisc_conjunction_eq {τ : Type*} [Nonempty τ] (F : τ → QForm) {D : ℤ}
    (hD : ∀ t, (F t).disc = D) (B : ℕ) :
    (SmoothSparsity.factorBase B).filter (fun p => ∀ t, IsSquare (((F t).disc : ℤ) : ZMod p))
      = admissiblePrimes D B := by
  ext p
  simp only [admissiblePrimes, Finset.mem_filter, hD]
  exact ⟨fun ⟨h1, h2⟩ => ⟨h1, h2 (Classical.arbitrary τ)⟩, fun ⟨h1, h2⟩ => ⟨h1, fun _ => h2⟩⟩

/-- **Silverman's square relation.**  If the leading coefficient is a square `A = a²`,
then `(2a)²·f(x) ≡ (2Ax+B)² (mod disc f)`: each value of the form is, up to a square, a
square modulo the discriminant `kN`. -/
theorem silverman_square_relation (f : QForm) (a : ℤ) (ha : f.A = a ^ 2) (x : ℤ) :
    (2 * a) ^ 2 * f.eval x ≡ (2 * f.A * x + f.B) ^ 2 [ZMOD f.disc] := by
  have h := f.four_A_mul_eval x
  rw [ha] at h
  unfold qsValue at h
  apply Int.ModEq.symm
  rw [Int.modEq_iff_dvd]
  exact ⟨-1, by rw [ha]; linear_combination h⟩

/-! ## Large primes: a monotonicity identity -/

/-- The split set is monotone in the bound. -/
theorem admissiblePrimes_mono (N : ℤ) {B L : ℕ} (hBL : B ≤ L) :
    admissiblePrimes N B ⊆ admissiblePrimes N L := by
  classical
  intro p hp
  simp only [admissiblePrimes, Finset.mem_filter, SmoothSparsity.mem_factorBase] at hp ⊢
  exact ⟨⟨hp.1.1, hp.1.2.trans hBL⟩, hp.2⟩

/-- **The large prime of a partial relation is split.**  If `x² − N = s·r` with `r` prime
(of any size), then `r` lies in the split set at every bound `L ≥ r`. -/
theorem largePrime_isSplit {N x s : ℤ} {r L : ℕ} (hr : r.Prime) (hrL : r ≤ L)
    (hv : qsValue N x = s * r) : r ∈ admissiblePrimes N L := by
  classical
  have hd : (r : ℤ) ∣ qsValue N x := ⟨s, by rw [hv]; ring⟩
  exact Finset.mem_filter.2
    ⟨SmoothSparsity.mem_factorBase.2 ⟨hr, hrL⟩, isSquare_of_dvd_qsValue hd⟩

/-- **LP-pair support theorem.**  Two partial relations `x₁² − N = s₁·r`, `x₂² − N = s₂·r`
sharing the large prime `r`, with `s₁, s₂` `B`-smooth, combine to a relation whose
*odd-exponent* primes all lie in the small split set `admissiblePrimes N B`: the large
prime cancels and no new column appears. -/
theorem lpPair_oddSupport_subset {N x₁ x₂ : ℤ} {s₁ s₂ r B : ℕ} (hr : r.Prime)
    (hs₁ : s₁ ≠ 0) (hs₂ : s₂ ≠ 0)
    (hv₁ : qsValue N x₁ = (s₁ * r : ℕ)) (hv₂ : qsValue N x₂ = (s₂ * r : ℕ))
    (hsm₁ : ∀ p ∈ s₁.primeFactors, p ≤ B) (hsm₂ : ∀ p ∈ s₂.primeFactors, p ≤ B) :
    ∀ p, Odd (((s₁ * r) * (s₂ * r)).factorization p) → p ∈ admissiblePrimes N B := by
  classical
  intro p hodd
  have hr0 : r ≠ 0 := hr.ne_zero
  have hfac : ((s₁ * r) * (s₂ * r)).factorization p
      = s₁.factorization p + s₂.factorization p + 2 * r.factorization p := by
    rw [Nat.factorization_mul (mul_ne_zero hs₁ hr0) (mul_ne_zero hs₂ hr0),
      Nat.factorization_mul hs₁ hr0, Nat.factorization_mul hs₂ hr0]
    simp only [Finsupp.add_apply]; ring
  rw [hfac] at hodd
  have hne : s₁.factorization p ≠ 0 ∨ s₂.factorization p ≠ 0 := by
    by_contra h
    push_neg at h
    rw [h.1, h.2] at hodd
    exact (Nat.not_odd_iff_even.2 ⟨r.factorization p, by ring⟩) hodd
  rcases hne with h | h
  · have hmem : p ∈ s₁.primeFactors := by
      rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 h
    have hpr := Nat.prime_of_mem_primeFactors hmem
    have hd : (p : ℤ) ∣ qsValue N x₁ := by
      rw [hv₁]; exact_mod_cast Dvd.dvd.mul_right (Nat.dvd_of_mem_primeFactors hmem) r
    exact Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hpr, hsm₁ p hmem⟩,
      isSquare_of_dvd_qsValue hd⟩
  · have hmem : p ∈ s₂.primeFactors := by
      rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 h
    have hpr := Nat.prime_of_mem_primeFactors hmem
    have hd : (p : ℤ) ∣ qsValue N x₂ := by
      rw [hv₂]; exact_mod_cast Dvd.dvd.mul_right (Nat.dvd_of_mem_primeFactors hmem) r
    exact Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hpr, hsm₂ p hmem⟩,
      isSquare_of_dvd_qsValue hd⟩

/-! ## The row-side lever: `#polynomials ⊥ #columns` -/

/-- **Multi-polynomial congruence of squares.**  Use any number of forms (indexed by an
arbitrary type `τ`) sharing the discriminant `D`.  As soon as the number of nonzero
`B`-smooth values exceeds `|admissiblePrimes D B|` — a quantity depending on `D` and `B`
only, *not* on how many forms were used — some nonempty sub-product is a perfect square.
Extra forms buy rows at zero marginal column cost. -/
theorem multipoly_congruence_of_squares {τ : Type*} (F : τ → QForm) {D : ℤ}
    (hD : ∀ t, (F t).disc = D) {B n : ℕ} (form : Fin n → τ) (X : Fin n → ℤ)
    (V : Fin n → ℕ) (hV : ∀ i, V i = ((F (form i)).eval (X i)).natAbs)
    (hV0 : ∀ i, V i ≠ 0) (hsm : ∀ i, ∀ p ∈ (V i).primeFactors, p ≤ B)
    (hcard : (admissiblePrimes D B).card < n) :
    ∃ T : Finset (Fin n), T.Nonempty ∧ IsSquare (∏ i ∈ T, V i) := by
  classical
  refine exists_nonempty_subset_prod_isSquare (admissiblePrimes D B) V hV0 ?_ (by simpa)
  intro i p hp
  have hmem : p ∈ (V i).primeFactors := by
    rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hp
  have hpr := Nat.prime_of_mem_primeFactors hmem
  have hdn : p ∣ V i := Nat.dvd_of_mem_primeFactors hmem
  have hd : (p : ℤ) ∣ (F (form i)).eval (X i) := by
    rw [hV i] at hdn
    exact Int.natCast_dvd.2 hdn
  exact family_support_subset_admissible F hD (form i) (X i) hpr (hsm i p hmem) hd

/-! ## The complete-cost rule -/

/-- **Elasticity of a total cost.**  For positive sieve and linear-algebra costs `S, L`
(as functions of `u = log Q`), the log-derivative of `S + L` is the cost-share-weighted
average of the two log-derivatives. -/
theorem hasDerivAt_log_total_cost {S L : ℝ → ℝ} {s' l' t : ℝ}
    (hS : HasDerivAt S s' t) (hL : HasDerivAt L l' t) (hS0 : 0 < S t) (hL0 : 0 < L t) :
    HasDerivAt (fun u => Real.log (S u + L u))
      (S t / (S t + L t) * (s' / S t) + L t / (S t + L t) * (l' / L t)) t := by
  have hpos : 0 < S t + L t := add_pos hS0 hL0
  have h := (hS.add hL).log hpos.ne'
  convert h using 1
  simp only [Pi.add_apply]
  field_simp

/-- The total elasticity lies between the sieve and LA elasticities. -/
theorem total_elasticity_between {S L s' l' : ℝ} (hS0 : 0 < S) (hL0 : 0 < L) :
    min (s' / S) (l' / L) ≤ S / (S + L) * (s' / S) + L / (S + L) * (l' / L) ∧
    S / (S + L) * (s' / S) + L / (S + L) * (l' / L) ≤ max (s' / S) (l' / L) := by
  have hpos : 0 < S + L := add_pos hS0 hL0
  have e : S / (S + L) * (s' / S) + L / (S + L) * (l' / L) = (s' + l') / (S + L) := by
    field_simp
  rw [e]
  constructor
  · rw [le_div_iff₀ hpos]
    rcases min_choice (s' / S) (l' / L) with h | h <;> rw [h]
    · have : s' / S ≤ l' / L := h ▸ min_le_right _ _
      rw [div_le_div_iff₀ hS0 hL0] at this
      have hs : s' / S * S = s' := by field_simp
      nlinarith
    · have : l' / L ≤ s' / S := h ▸ min_le_left _ _
      rw [div_le_div_iff₀ hL0 hS0] at this
      have hl : l' / L * L = l' := by field_simp
      nlinarith
  · rw [div_le_iff₀ hpos]
    rcases max_choice (s' / S) (l' / L) with h | h <;> rw [h]
    · have : l' / L ≤ s' / S := h ▸ le_max_right _ _
      rw [div_le_div_iff₀ hL0 hS0] at this
      have hs : s' / S * S = s' := by field_simp
      nlinarith
    · have : s' / S ≤ l' / L := h ▸ le_max_left _ _
      rw [div_le_div_iff₀ hS0 hL0] at this
      have hl : l' / L * L = l' := by field_simp
      nlinarith

/-- **Sign of the complete-cost elasticity.**  The total elasticity is positive iff the
absolute LA growth `l'` beats the absolute sieve decline `−s'`. -/
theorem total_elasticity_pos_iff {S L s' l' : ℝ} (hS0 : 0 < S) (hL0 : 0 < L) :
    0 < S / (S + L) * (s' / S) + L / (S + L) * (l' / L) ↔ -s' < l' := by
  have hpos : 0 < S + L := add_pos hS0 hL0
  have e : S / (S + L) * (s' / S) + L / (S + L) * (l' / L) = (s' + l') / (S + L) := by
    field_simp
  rw [e, div_pos_iff_of_pos_right hpos]
  constructor <;> intro h <;> linarith

/-- **Sieve-only pricing inverts the sign.**  Whenever the sieve cost decreases in `log Q`
(`s' < 0`) but the GF(2) cost grows faster in absolute terms (`l' > −s'`), the sieve-only
elasticity is negative while the complete-cost elasticity is positive. -/
theorem sieve_only_sign_inversion {S L : ℝ → ℝ} {s' l' t : ℝ}
    (hS : HasDerivAt S s' t) (hL : HasDerivAt L l' t) (hS0 : 0 < S t) (hL0 : 0 < L t)
    (hsieve : s' < 0) (hLA : -s' < l') :
    ∃ e, HasDerivAt (fun u => Real.log (S u + L u)) e t ∧ 0 < e ∧
      HasDerivAt (fun u => Real.log (S u)) (s' / S t) t ∧ s' / S t < 0 := by
  refine ⟨_, hasDerivAt_log_total_cost hS hL hS0 hL0,
    (total_elasticity_pos_iff hS0 hL0).2 hLA, ?_, div_neg_of_neg_of_pos hsieve hS0⟩
  have := hS.log hS0.ne'
  simpa using this

/-! ## The Silverman gate -/

/-- **Minimax lower bound.**  For every leading coefficient `A > 0`, the larger of the two
extremes `N/A` and `A·M² − N/A` of a centred Silverman form on `[−M, M]` is at least
`M·√(N/2)`. -/
theorem silverman_minimax_lower {N M A : ℝ} (hN : 0 < N) (hM : 0 < M) (hA : 0 < A) :
    M * Real.sqrt (N / 2) ≤ max (N / A) (A * M ^ 2 - N / A) := by
  set m := M * Real.sqrt (N / 2) with hm
  have hs : Real.sqrt (N / 2) ^ 2 = N / 2 := Real.sq_sqrt (by positivity)
  have hm0 : 0 < m := by positivity
  have hm2 : m ^ 2 = M ^ 2 * N / 2 := by rw [hm, mul_pow, hs]; ring
  by_cases hy : m ≤ N / A
  · exact hy.trans (le_max_left _ _)
  · push_neg at hy
    refine le_trans ?_ (le_max_right _ _)
    set y := N / A with hydef
    have hy0 : 0 < y := by positivity
    have hAy : A = N / y := by rw [hydef]; field_simp
    have hval : A * M ^ 2 = 2 * m ^ 2 / y := by
      rw [hAy, hm2]; field_simp
    rw [hval]
    rw [le_sub_iff_add_le, le_div_iff₀ hy0]
    nlinarith

/-- **The minimax is attained** at `A = 2√(N/2)/M = √(2N)/M`, where both extremes equal
`M·√(N/2) ≈ 0.707·M·√N`. -/
theorem silverman_minimax_attained {N M : ℝ} (hN : 0 < N) (hM : 0 < M) :
    let A := 2 * Real.sqrt (N / 2) / M
    N / A = M * Real.sqrt (N / 2) ∧ A * M ^ 2 - N / A = M * Real.sqrt (N / 2) := by
  intro A
  have hs : Real.sqrt (N / 2) ^ 2 = N / 2 := Real.sq_sqrt (by positivity)
  have hs0 : 0 < Real.sqrt (N / 2) := Real.sqrt_pos.2 (by positivity)
  have h1 : N / A = M * Real.sqrt (N / 2) := by
    simp only [A]
    rw [div_eq_iff (by positivity)]
    field_simp
    nlinarith
  refine ⟨h1, ?_⟩
  rw [h1]; simp only [A]; field_simp; ring

/-- **The gate fails by `> 600×` at 42 bits.**  For `N < 2⁴²` and `B, M ≥ 1000`,
`B²·M > 600·√(N/2)`: the regime `B²·M ≲ √(N/2) ≈ 0.707·√N` in which extra Silverman forms
keep their ideal leading coefficient is missed by almost three orders of magnitude. -/
theorem gate_fails_at_42_bits {N B M : ℝ} (hN42 : N < 2 ^ 42)
    (hB : 1000 ≤ B) (hM : 1000 ≤ M) :
    600 * Real.sqrt (N / 2) < B ^ 2 * M := by
  have hsq : Real.sqrt (N / 2) < 10 ^ 9 / 600 := by
    rw [Real.sqrt_lt' (by norm_num)]
    nlinarith
  have hB2 : (10 : ℝ) ^ 6 ≤ B ^ 2 := by nlinarith
  have : (10 : ℝ) ^ 9 ≤ B ^ 2 * M := by nlinarith
  linarith

/-! ## The falsifiable boundary: leaving differences of squares -/

/-- **The no-decoupling theorem is specific to differences of squares.**  For the cubic
sieve value `x³ − N` the split-set constraint fails: `5 ∣ 3³ − 2` although `2` is not a
square mod `5`.  Non-split columns appear as soon as the sieved value is not tied to `N`
through a quadratic discriminant (the NFS direction). -/
theorem cubic_breaks_split_constraint :
    ∃ (N x : ℤ) (p : ℕ), p.Prime ∧ (p : ℤ) ∣ x ^ 3 - N ∧ ¬ IsSquare (N : ZMod p) := by
  refine ⟨2, 3, 5, by norm_num, ⟨5, by norm_num⟩, ?_⟩
  rintro ⟨r, hr⟩
  have hr' : (2 : ZMod 5) = r * r := by exact_mod_cast hr
  fin_cases r <;> revert hr' <;> decide

end QSNoDecoupling