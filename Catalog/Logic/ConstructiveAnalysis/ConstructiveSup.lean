/-
# Bishop's constructive least upper bound principle

Classically every nonempty set of reals that is bounded above has a supremum.  That
proof is not constructive: it decides, for a rational `q`, whether `q` is an upper
bound of the set, which is in general undecidable.  Bishop's replacement assumes
that the set is **located**: it comes equipped with a *decision procedure* `L` such
that for rationals `p < q`, `L p q = true` guarantees that `q` is an upper bound,
and `L p q = false` produces a member of the set above `p`.  (Both alternatives may
hold; only their disjunction is asserted, which is what makes the datum obtainable
in practice.)

From such a datum the supremum is computed by an explicit **trisection search**
(`Bishop.bisect`), producing at every stage a pair of rationals `p n ≤ sup ≤ q n`
whose width is exactly `(2/3)^n (b₀ - a₀)`:

* `Bishop.bisect_width` : the exact geometric rate;
* `Bishop.bisect_invariant` : the enclosure invariant, proved by induction;
* `Bishop.constructive_sup` : the supremum exists, is the least upper bound, and is
  enclosed by the explicitly computed rationals with the stated rate;
* `Bishop.constructive_sup_reg` : the supremum, presented as a Bishop real, i.e. as a
  regular sequence of rationals with the canonical modulus `1/(n+1)`.

The located hypothesis is exactly what the classical proof hides: `Bishop.
locatedData_of_decidable` shows that assuming the classically valid but
constructively unavailable decision "is `q` an upper bound?" one recovers a located
datum, so the principle is classically equivalent to the ordinary completeness
axiom.
-/

import Mathlib
import Logic.ConstructiveAnalysis.BishopReals

namespace Bishop

open Set

/-- One step of the trisection search for the supremum of a located set: query the
locatedness oracle at the two interior trisection points, and keep the half-open
enclosure it certifies.  The width shrinks by the factor `2/3` in both branches. -/
def bisectStep (L : ℚ → ℚ → Bool) (pq : ℚ × ℚ) : ℚ × ℚ :=
  let p := pq.1
  let q := pq.2
  let m₁ := p + (q - p) / 3
  let m₂ := p + 2 * (q - p) / 3
  if L m₁ m₂ then (p, m₂) else (m₁, q)

/-- The trisection sequence of rational enclosures of the supremum. -/
def bisect (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) : ℕ → ℚ × ℚ
  | 0 => (a₀, b₀)
  | n + 1 => bisectStep L (bisect L a₀ b₀ n)

@[simp] lemma bisect_zero (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) : bisect L a₀ b₀ 0 = (a₀, b₀) := rfl

@[simp] lemma bisect_succ (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) (n : ℕ) :
    bisect L a₀ b₀ (n + 1) = bisectStep L (bisect L a₀ b₀ n) := rfl

lemma bisectStep_width (L : ℚ → ℚ → Bool) (pq : ℚ × ℚ) :
    (bisectStep L pq).2 - (bisectStep L pq).1 = 2 / 3 * (pq.2 - pq.1) := by
  simp only [bisectStep]
  split <;> simp <;> ring

/-- **Exact geometric rate.**  The `n`-th enclosure has width `(2/3)^n (b₀ - a₀)`. -/
theorem bisect_width (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) (n : ℕ) :
    (bisect L a₀ b₀ n).2 - (bisect L a₀ b₀ n).1 = (2 / 3) ^ n * (b₀ - a₀) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [bisect_succ, bisectStep_width, ih]
      ring

lemma bisect_lt (L : ℚ → ℚ → Bool) {a₀ b₀ : ℚ} (hab : a₀ < b₀) (n : ℕ) :
    (bisect L a₀ b₀ n).1 < (bisect L a₀ b₀ n).2 := by
  have hw := bisect_width L a₀ b₀ n
  have hpos : (0 : ℚ) < (2 / 3) ^ n * (b₀ - a₀) := by
    have h1 : (0 : ℚ) < (2 / 3 : ℚ) ^ n := by positivity
    have h2 : (0 : ℚ) < b₀ - a₀ := by linarith
    positivity
  linarith

/-- The invariant maintained by the search: the right endpoint is an upper bound of
`S`, and some member of `S` lies strictly above the left endpoint. -/
def Enclosing (S : Set ℝ) (pq : ℚ × ℚ) : Prop :=
  (∀ s ∈ S, s ≤ (pq.2 : ℝ)) ∧ ∃ s ∈ S, (pq.1 : ℝ) < s

/-- **Located set (Bishop).**  A decision procedure which, for rationals `p < q`,
either certifies that `q` is an upper bound of `S`, or exhibits a member of `S`
above `p`. -/
structure LocatedData (S : Set ℝ) where
  /-- the decision procedure. -/
  L : ℚ → ℚ → Bool
  /-- a `true` answer certifies an upper bound. -/
  upper : ∀ p q : ℚ, p < q → L p q = true → ∀ s ∈ S, s ≤ (q : ℝ)
  /-- a `false` answer produces a member of `S` above `p`. -/
  witness : ∀ p q : ℚ, p < q → L p q = false → ∃ s ∈ S, (p : ℝ) < s

lemma enclosing_bisectStep {S : Set ℝ} (D : LocatedData S) {pq : ℚ × ℚ}
    (hlt : pq.1 < pq.2) (h : Enclosing S pq) : Enclosing S (bisectStep D.L pq) := by
  obtain ⟨hup, hlow⟩ := h
  have hm : pq.1 + (pq.2 - pq.1) / 3 < pq.1 + 2 * (pq.2 - pq.1) / 3 := by linarith
  by_cases hL : D.L (pq.1 + (pq.2 - pq.1) / 3) (pq.1 + 2 * (pq.2 - pq.1) / 3) = true
  · have hstep : bisectStep D.L pq = (pq.1, pq.1 + 2 * (pq.2 - pq.1) / 3) := by
      simp [bisectStep, hL]
    rw [hstep]
    exact ⟨D.upper _ _ hm hL, hlow⟩
  · have hLf : D.L (pq.1 + (pq.2 - pq.1) / 3) (pq.1 + 2 * (pq.2 - pq.1) / 3) = false := by
      simpa using hL
    have hstep : bisectStep D.L pq = (pq.1 + (pq.2 - pq.1) / 3, pq.2) := by
      simp [bisectStep, hLf]
    rw [hstep]
    exact ⟨hup, D.witness _ _ hm hLf⟩

/-- **The enclosure invariant.**  Every stage of the search encloses the supremum. -/
theorem bisect_invariant {S : Set ℝ} (D : LocatedData S) {a₀ b₀ : ℚ} (hab : a₀ < b₀)
    (h₀ : Enclosing S (a₀, b₀)) (n : ℕ) : Enclosing S (bisect D.L a₀ b₀ n) := by
  induction n with
  | zero => simpa using h₀
  | succ n ih =>
      rw [bisect_succ]
      exact enclosing_bisectStep D (bisect_lt D.L hab n) ih

/-- **Bishop's constructive least upper bound principle.**

A set of reals that is nonempty, bounded above, and *located* (in the explicit sense
of `LocatedData`) has a least upper bound, and this supremum is enclosed by the
explicitly computed rationals of the trisection search, with the exact geometric
rate `(2/3)^n (b₀ - a₀)`. -/
theorem constructive_sup {S : Set ℝ} (D : LocatedData S) {a₀ b₀ : ℚ} (hab : a₀ < b₀)
    (h₀ : Enclosing S (a₀, b₀)) :
    ∃ u : ℝ, IsLUB S u ∧ ∀ n : ℕ,
      ((bisect D.L a₀ b₀ n).1 : ℝ) ≤ u ∧ u ≤ ((bisect D.L a₀ b₀ n).2 : ℝ) ∧
        ((bisect D.L a₀ b₀ n).2 : ℝ) - ((bisect D.L a₀ b₀ n).1 : ℝ)
          = (2 / 3 : ℝ) ^ n * ((b₀ : ℝ) - (a₀ : ℝ)) := by
  obtain ⟨hup₀, s₀, hs₀S, _⟩ := id h₀
  have hne : S.Nonempty := ⟨s₀, hs₀S⟩
  have hbdd : BddAbove S := ⟨(b₀ : ℝ), fun s hs => hup₀ s hs⟩
  refine ⟨sSup S, isLUB_csSup hne hbdd, fun n => ?_⟩
  obtain ⟨hup, s, hsS, hs⟩ := bisect_invariant D hab h₀ n
  refine ⟨?_, ?_, ?_⟩
  · exact le_of_lt (lt_of_lt_of_le hs (le_csSup hbdd hsS))
  · exact csSup_le hne hup
  · have := bisect_width D.L a₀ b₀ n
    have hR : (((bisect D.L a₀ b₀ n).2 - (bisect D.L a₀ b₀ n).1 : ℚ) : ℝ)
        = (((2 / 3) ^ n * (b₀ - a₀) : ℚ) : ℝ) := by exact_mod_cast this
    push_cast at hR
    linarith

/-- An index at which the trisection width is below the canonical accuracy
`1/(k+1)`. -/
lemma exists_bisect_index (a₀ b₀ : ℚ) (hab : a₀ < b₀) (k : ℕ) :
    ∃ n : ℕ, (2 / 3 : ℝ) ^ n * ((b₀ : ℝ) - (a₀ : ℝ)) ≤ 1 / (k + 1) := by
  have hW : (0 : ℝ) < (b₀ : ℝ) - (a₀ : ℝ) := by
    have : (a₀ : ℝ) < (b₀ : ℝ) := by exact_mod_cast hab
    linarith
  have hk : (0 : ℝ) < 1 / ((k : ℝ) + 1) := by positivity
  have h23 : |(2 / 3 : ℝ)| < 1 := by rw [abs_of_nonneg] <;> norm_num
  have htend : Filter.Tendsto (fun n : ℕ => (2 / 3 : ℝ) ^ n * ((b₀ : ℝ) - (a₀ : ℝ)))
      Filter.atTop (nhds (0 * ((b₀ : ℝ) - (a₀ : ℝ)))) :=
    (tendsto_pow_atTop_nhds_zero_of_abs_lt_one h23).mul_const _
  rw [zero_mul] at htend
  have := (htend.eventually (eventually_le_nhds hk)).exists
  obtain ⟨n, hn⟩ := this
  exact ⟨n, hn⟩

/-- **The supremum of a located set is a Bishop real.**  Its `k`-th rational
approximation is the left endpoint of the first trisection stage whose width is
below `1/(k+1)`, so the whole construction stays inside the rationals. -/
theorem constructive_sup_reg {S : Set ℝ} (D : LocatedData S) {a₀ b₀ : ℚ} (hab : a₀ < b₀)
    (h₀ : Enclosing S (a₀, b₀)) :
    ∃ x : Reg, IsLUB S x.toReal ∧
      ∀ k : ℕ, ∃ n : ℕ, x.approx k = (bisect D.L a₀ b₀ n).1 := by
  obtain ⟨u, hu, henc⟩ := constructive_sup D hab h₀
  have hchoice : ∀ k : ℕ, ∃ n : ℕ, |(((bisect D.L a₀ b₀ n).1 : ℚ) : ℝ) - u| ≤ 1 / (k + 1) := by
    intro k
    obtain ⟨n, hn⟩ := exists_bisect_index a₀ b₀ hab k
    obtain ⟨h1, h2, h3⟩ := henc n
    refine ⟨n, ?_⟩
    rw [abs_le]
    constructor <;> [linarith; linarith]
  choose N hN using hchoice
  set q : ℕ → ℚ := fun k => (bisect D.L a₀ b₀ (N k)).1 with hq
  have hreg : ∀ m n : ℕ, |q m - q n| ≤ 1 / (m + 1) + 1 / (n + 1) := by
    intro m n
    have hR : |((q m : ℚ) : ℝ) - ((q n : ℚ) : ℝ)| ≤ 1 / (m + 1) + 1 / (n + 1) := by
      have h1 : |((q m : ℚ) : ℝ) - ((q n : ℚ) : ℝ)|
          ≤ |((q m : ℚ) : ℝ) - u| + |u - ((q n : ℚ) : ℝ)| := abs_sub_le _ _ _
      have h2 := hN m
      have h3 : |u - ((q n : ℚ) : ℝ)| ≤ 1 / (n + 1) := by
        rw [abs_sub_comm]; exact hN n
      linarith
    have h' : ((|q m - q n| : ℚ) : ℝ) ≤ (((1 : ℚ) / (m + 1) + 1 / (n + 1) : ℚ) : ℝ) := by
      push_cast
      simpa using hR
    exact_mod_cast h'
  have hx : (⟨q, hreg⟩ : Reg).toReal = u := by
    refine Reg.toReal_eq_of_approx_le _ u 1 (fun k => ?_)
    have happ : (⟨q, hreg⟩ : Reg).approx k = q k := rfl
    rw [happ, one_mul]
    exact hN k
  refine ⟨⟨q, hreg⟩, ?_, ?_⟩
  · rw [hx]; exact hu
  · intro k; exact ⟨N k, rfl⟩


/-! ## A worked instance: the hypotheses are satisfiable

To see that `LocatedData` is not a vacuous requirement, here is a completely
explicit instance — a set whose locatedness oracle is a decidable comparison of
rationals — on which the trisection search really runs. -/

/-- The located datum for the half-line `(-∞, c]` with rational endpoint `c`: the
oracle is the decidable rational test `c ≤ q`. -/
def locatedIic (c : ℚ) : LocatedData (Set.Iic (c : ℝ)) where
  L := fun _ q => decide (c ≤ q)
  upper := by
    intro p q _ h s hs
    have hcq : c ≤ q := of_decide_eq_true h
    have : (c : ℝ) ≤ (q : ℝ) := by exact_mod_cast hcq
    exact le_trans hs this
  witness := by
    intro p q hpq h
    have hcq : ¬ c ≤ q := of_decide_eq_false h
    have hqc : q < c := lt_of_not_ge hcq
    refine ⟨(c : ℝ), Set.mem_Iic.mpr (le_refl _), ?_⟩
    have : p < c := lt_trans hpq hqc
    exact_mod_cast this

/-- On this instance the trisection search really encloses the supremum `c` at every
stage, with the width `(2/3)^n (b₀ - a₀)` of `bisect_width`. -/
theorem bisect_Iic_encloses {c a₀ b₀ : ℚ} (h1 : a₀ < c) (h2 : c ≤ b₀) (hab : a₀ < b₀) (n : ℕ) :
    ((bisect (locatedIic c).L a₀ b₀ n).1 : ℝ) < (c : ℝ) ∧
      (c : ℝ) ≤ ((bisect (locatedIic c).L a₀ b₀ n).2 : ℝ) := by
  have h₀ : Enclosing (Set.Iic (c : ℝ)) (a₀, b₀) := by
    constructor
    · intro s hs
      have : (c : ℝ) ≤ (b₀ : ℝ) := by exact_mod_cast h2
      exact le_trans hs this
    · exact ⟨(c : ℝ), Set.mem_Iic.mpr (le_refl _), by exact_mod_cast h1⟩
  obtain ⟨hup, s, hsS, hs⟩ := bisect_invariant (locatedIic c) hab h₀ n
  exact ⟨lt_of_lt_of_le hs (Set.mem_Iic.mp hsS), hup (c : ℝ) (Set.mem_Iic.mpr (le_refl _))⟩

/-! The search is genuinely computable; the following facts about the trisection for
`c = 1/2` on `[0,1]` are checked at compile time. -/

-- the first four enclosures
#guard (List.range 4).map (fun n => bisect (locatedIic (1/2)).L 0 1 n)
    = [(0, 1), (0, 2 / 3), (2 / 9, 2 / 3), (2 / 9, 14 / 27)]

-- after ten steps the width is exactly `(2/3)^10`
#guard (bisect (locatedIic (1/2)).L 0 1 10).2 - (bisect (locatedIic (1/2)).L 0 1 10).1
    = (2 / 3 : ℚ) ^ 10

-- and the enclosure does contain `1/2`
#guard (bisect (locatedIic (1/2)).L 0 1 10).1 < (1 / 2 : ℚ) &&
    (1 / 2 : ℚ) ≤ (bisect (locatedIic (1/2)).L 0 1 10).2

/-- **Comparison with the classical principle.**  Classically the locatedness datum
is free: deciding "is `q` an upper bound of `S`?" (a decision no constructive
procedure can make in general) yields a `LocatedData`.  So the constructive
principle is classically equivalent to ordinary completeness, and the whole content
of the constructive theorem lies in the extra datum. -/
noncomputable def locatedData_of_decidable (S : Set ℝ) : LocatedData S := by
  classical
  refine ⟨fun _ q => decide (∀ s ∈ S, s ≤ (q : ℝ)), ?_, ?_⟩
  · intro p q _ h s hs
    have : ∀ s ∈ S, s ≤ (q : ℝ) := of_decide_eq_true h
    exact this s hs
  · intro p q hpq h
    have hnot : ¬ ∀ s ∈ S, s ≤ (q : ℝ) := of_decide_eq_false h
    push_neg at hnot
    obtain ⟨s, hsS, hs⟩ := hnot
    have hpq' : (p : ℝ) < (q : ℝ) := by exact_mod_cast hpq
    exact ⟨s, hsS, lt_trans hpq' hs⟩

end Bishop