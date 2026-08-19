import Algebra.ScanSchemeDecoding.Epsilon

/-!
# The cost spectrum of scan schemes

The exact optimum pins down the *bottom* of the achievable total-cost spectrum.  Here we
pin down the *top*: the triangular number `triangle N` of the whole key set, attained by
the degenerate one-bucket scheme.  The mechanism is the exact opposite of convexity used
for the optimum, namely superadditivity `triangle a + triangle b ≤ triangle (a + b)`.

## Main results

* `ScanSchemeDecoding.triangle_add_le` — superadditivity of the triangular cost.
* `ScanSchemeDecoding.sum_triangle_le` — a scan scheme never costs more than a single
  linear scan of all keys.
* `ScanSchemeDecoding.scan_maximum` — `triangle N` is the greatest achievable cost.
* `ScanSchemeDecoding.scan_cost_spectrum` — every scan scheme on `N` keys with `m > 0`
  buckets has total cost in the closed interval `[triangleOpt N m, triangle N]`, and both
  endpoints are realised.
-/

namespace ScanSchemeDecoding

open Finset

/-- **Superadditivity** of the triangular cost: merging two buckets never helps. -/
theorem triangle_add_le (a b : ℕ) : triangle a + triangle b ≤ triangle (a + b) := by
  have ha := two_mul_triangle a
  have hb := two_mul_triangle b
  have hab := two_mul_triangle (a + b)
  nlinarith [Nat.zero_le (a * b)]

/-- Splitting keys into buckets never costs more than one linear scan of everything. -/
theorem sum_triangle_le {ι : Type*} (s : Finset ι) (f : ι → ℕ) :
    ∑ i ∈ s, triangle (f i) ≤ triangle (∑ i ∈ s, f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
    rw [Finset.sum_insert ha, Finset.sum_insert ha]
    exact le_trans (Nat.add_le_add_left ih _) (triangle_add_le _ _)

namespace ScanScheme

variable {α β : Type*} [Fintype α] [LinearOrder α] [Fintype β] [DecidableEq β]
variable (S : ScanScheme α β)

/-- **Universal upper bound.**  No scan scheme is worse than the trivial linear scan. -/
theorem decodeCost_le_triangle : ∑ x, S.decodeCost x ≤ triangle (Fintype.card α) := by
  rw [S.decodeCost_eq, ← S.sum_fiber_card]
  exact sum_triangle_le _ _

end ScanScheme

/-- The degenerate scheme that puts every key in a single bucket. -/
def constScheme (N : ℕ) {m : ℕ} (b₀ : Fin m) : ScanScheme (Fin N) (Fin m) := ⟨fun _ => b₀⟩

/-- The one-bucket scheme costs exactly `triangle N`. -/
theorem constScheme_decodeCost (N : ℕ) {m : ℕ} (b₀ : Fin m) :
    ∑ x, (constScheme N b₀).decodeCost x = triangle N := by
  classical
  rw [ScanScheme.decodeCost_eq]
  rw [Finset.sum_eq_single b₀]
  · congr 1
    have : (constScheme N b₀).fiber b₀ = Finset.univ := by
      ext x; simp [ScanScheme.fiber, constScheme]
    rw [this]
    simp
  · intro b _ hb
    have hempty : (constScheme N b₀).fiber b = ∅ := by
      ext x
      simp [ScanScheme.fiber, constScheme, Ne.symm hb]
    rw [hempty]
    simp
  · intro h
    exact absurd (Finset.mem_univ b₀) h

/-- **Exact maximum.**  `triangle N` is the greatest total decoding cost of a scan scheme
on `N` keys with `m ≥ 1` buckets, attained by the one-bucket scheme. -/
theorem scan_maximum (N : ℕ) {m : ℕ} (hm : 0 < m) :
    IsGreatest {c : ℕ | ∃ S : ScanScheme (Fin N) (Fin m), ∑ x, S.decodeCost x = c}
      (triangle N) := by
  constructor
  · exact ⟨constScheme N ⟨0, hm⟩, constScheme_decodeCost N _⟩
  · rintro c ⟨S, rfl⟩
    have := S.decodeCost_le_triangle
    simpa using this

/-- **The cost spectrum.**  Every scan scheme costs between the pigeonhole optimum and a
full linear scan, and both extremes occur. -/
theorem scan_cost_spectrum (N : ℕ) {m : ℕ} (hm : 0 < m) (S : ScanScheme (Fin N) (Fin m)) :
    triangleOpt N m ≤ ∑ x, S.decodeCost x ∧ ∑ x, S.decodeCost x ≤ triangle N := by
  refine ⟨?_, ?_⟩
  · have hβ : 0 < Fintype.card (Fin m) := by simpa using hm
    have := S.triangleOpt_le_decodeCost hβ
    simpa using this
  · have := S.decodeCost_le_triangle
    simpa using this

end ScanSchemeDecoding