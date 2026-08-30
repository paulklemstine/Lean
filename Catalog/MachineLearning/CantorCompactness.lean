import Mathlib
import Shared.GraphTheory.FractalTruthMetric

/-!
# Completeness, total boundedness and compactness of the Cantor truth space

This file continues the development of `Shared.GraphTheory.FractalTruthMetric`, where the
first-disagreement ultrametric `cantorDist` was constructed on the space of binary streams
`Cantor = ℕ → Bool`, and closed balls of radius `2⁻ⁿ` were identified with the prefix
agreement classes `AgreeTo n`.

Here we prove that this metric space is **complete** and **totally bounded**, hence
**compact**, and that the golden-mean subshift (streams with no two consecutive `true`s) is a
closed — hence compact — shift-invariant subset.  Finally we compute the exact covering
combinatorics of the subshift: the set of admissible words of length `n` has cardinality
`fib (n+2)`, so both the covering number and the packing number of the golden-mean subshift
at scale `2⁻ⁿ` equal a Fibonacci number.  This is the finite-scale source of the box dimension
`log φ / log 2`.

## Main results

* `cantor_totallyBounded` — the whole space is totally bounded, with the explicit finite
  `2⁻ⁿ`-net given by the finitely many truncations.
* `instCompleteSpaceCantor` — Cauchy sequences stabilize coordinatewise and converge.
* `instCompactSpaceCantor` — compactness.
* `isClosed_goldenMean`, `isCompact_goldenMean` — the golden-mean subshift is closed and
  compact; `mapsTo_shift_goldenMean` — it is shift invariant.
* `goldenMean_perfect` — the subshift has no isolated points.
* `card_goldenWords` — there are `fib (n+2)` admissible words of length `n`.
* `goldenWords_eq_image_prefixOf` — those words are exactly the length-`n` prefixes of
  subshift points.
* `goldenMean_cover`, `goldenWords_separated` — covering and packing at scale `2⁻ⁿ` are both
  realised by exactly `fib (n+2)` sets/points.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric

/-! ## Basic dictionary between `dist` and `AgreeTo` -/

/-- The metric on `Cantor` is `cantorDist` by construction. -/
theorem dist_eq (x y : Cantor) : dist x y = cantorDist x y := rfl

/-- Closed balls of radius `2⁻ⁿ` are the prefix agreement classes. -/
theorem dist_le_iff_agreeTo (x y : Cantor) (n : ℕ) :
    dist x y ≤ (2 : ℝ) ^ (-(n : ℤ)) ↔ AgreeTo n x y :=
  cantorDist_le_iff_agreeTo x y n

/-- A strict `2⁻ⁿ` bound still forces agreement to depth `n`. -/
theorem agreeTo_of_dist_lt {x y : Cantor} {n : ℕ} (h : dist x y < (2 : ℝ) ^ (-(n : ℤ))) :
    AgreeTo n x y :=
  (dist_le_iff_agreeTo x y n).mp h.le

/-- The space has diameter at most `1`. -/
theorem dist_le_one (x y : Cantor) : dist x y ≤ 1 := by
  have h : AgreeTo 0 x y := fun k hk => absurd hk (Nat.not_lt_zero k)
  have := (dist_le_iff_agreeTo x y 0).mpr h
  simpa using this

/-- Every positive radius contains a dyadic radius `2⁻ⁿ`. -/
theorem exists_two_zpow_lt {ε : ℝ} (hε : 0 < ε) : ∃ n : ℕ, (2 : ℝ) ^ (-(n : ℤ)) < ε := by
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one hε (by norm_num : (1 / 2 : ℝ) < 1)
  refine ⟨n, ?_⟩
  have h : (2 : ℝ) ^ (-(n : ℤ)) = (1 / 2 : ℝ) ^ n := by
    rw [zpow_neg, zpow_natCast, one_div, inv_pow]
  rwa [h]

/-- Positivity of the dyadic radii. -/
theorem two_zpow_pos (n : ℕ) : (0 : ℝ) < (2 : ℝ) ^ (-(n : ℤ)) := by positivity

/-! ## Total boundedness: the finite net of truncations -/

/-- Truncation of a stream at depth `n`: keep the first `n` bits, pad with `false`. -/
def trunc (n : ℕ) (x : Cantor) : Cantor := fun k => if k < n then x k else false

/-- The finite net: streams determined by a word of length `n`, padded with `false`. -/
def netMap (n : ℕ) (s : Fin n → Bool) : Cantor := fun k => if h : k < n then s ⟨k, h⟩ else false

theorem trunc_mem_range (n : ℕ) (x : Cantor) : trunc n x ∈ Set.range (netMap n) := by
  refine ⟨fun i => x i, ?_⟩
  funext k
  by_cases h : k < n <;> simp [netMap, trunc, h]

/-- A stream agrees with its depth-`n` truncation on the first `n` coordinates. -/
theorem agreeTo_trunc (n : ℕ) (x : Cantor) : AgreeTo n x (trunc n x) := by
  intro k hk
  simp [trunc, hk]

/-- **Total boundedness**: for every `n`, the finitely many depth-`n` truncations form a
`2⁻ⁿ`-net for the whole Cantor space. -/
theorem cantor_totallyBounded : TotallyBounded (Set.univ : Set Cantor) := by
  rw [Metric.totallyBounded_iff]
  intro ε hε
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  refine ⟨Set.range (netMap n), Set.finite_range _, ?_⟩
  intro x _
  refine Set.mem_iUnion₂.mpr ⟨trunc n x, trunc_mem_range n x, ?_⟩
  have h := (dist_le_iff_agreeTo x (trunc n x) n).mpr (agreeTo_trunc n x)
  exact lt_of_le_of_lt h hn

/-! ## Completeness: Cauchy sequences stabilize coordinatewise -/

/-- A Cauchy sequence of streams eventually agrees to any prescribed depth. -/
theorem cauchySeq_agreeTo (u : ℕ → Cantor) (hu : CauchySeq u) (n : ℕ) :
    ∃ N, ∀ i, N ≤ i → ∀ j, N ≤ j → AgreeTo n (u i) (u j) := by
  obtain ⟨N, hN⟩ := Metric.cauchySeq_iff.mp hu ((2 : ℝ) ^ (-(n : ℤ))) (two_zpow_pos n)
  exact ⟨N, fun i hi j hj => agreeTo_of_dist_lt (hN i hi j hj)⟩

/-- **Completeness.** The limit is read off coordinatewise from the stabilizing values. -/
instance instCompleteSpaceCantor : CompleteSpace Cantor := by
  apply Metric.complete_of_cauchySeq_tendsto
  intro u hu
  choose N hN using cauchySeq_agreeTo u hu
  refine ⟨(fun k => u (N (k + 1)) k : Cantor), ?_⟩
  -- key: past index `N n`, every term agrees with the candidate limit to depth `n`
  have key : ∀ n i, N n ≤ i → AgreeTo n (u i) (fun k => u (N (k + 1)) k) := by
    intro n i hi k hk
    have h1 : u i k = u (max i (N (k + 1))) k :=
      hN n i hi (max i (N (k + 1))) (le_trans hi (le_max_left _ _)) k hk
    have h2 : u (max i (N (k + 1))) k = u (N (k + 1)) k :=
      hN (k + 1) (max i (N (k + 1))) (le_max_right _ _) (N (k + 1)) le_rfl k (Nat.lt_succ_self k)
    exact h1.trans h2
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  refine ⟨N n, fun i hi => ?_⟩
  have h := (dist_le_iff_agreeTo (u i) (fun k => u (N (k + 1)) k) n).mpr (key n i hi)
  exact lt_of_le_of_lt h hn

/-- **Compactness** of the Cantor truth space: complete plus totally bounded. -/
instance instCompactSpaceCantor : CompactSpace Cantor :=
  ⟨cantor_totallyBounded.isCompact_of_isClosed isClosed_univ⟩

/-! ## The shift map -/

/-- The one-sided shift, deleting the first answer. -/
def shift (x : Cantor) : Cantor := fun k => x (k + 1)

@[simp] theorem shift_apply (x : Cantor) (k : ℕ) : shift x k = x (k + 1) := rfl

/-- Agreement to depth `n+1` splits into the first coordinate plus agreement of the shifts. -/
theorem agreeTo_succ_iff {n : ℕ} {x y : Cantor} :
    AgreeTo (n + 1) x y ↔ x 0 = y 0 ∧ AgreeTo n (shift x) (shift y) := by
  constructor
  · intro h
    refine ⟨h 0 (Nat.succ_pos n), fun k hk => h (k + 1) (Nat.succ_lt_succ hk)⟩
  · rintro ⟨h0, hs⟩ k hk
    cases k with
    | zero => exact h0
    | succ j => exact hs j (Nat.succ_lt_succ_iff.mp hk)

/-- The shift doubles distances at worst: it is `2`-Lipschitz. -/
theorem dist_shift_le (x y : Cantor) : dist (shift x) (shift y) ≤ 2 * dist x y := by
  by_cases hxy : x = y
  · subst hxy; simp
  · have hdxy : dist x y = (2 : ℝ) ^ (-(firstDiff x y : ℤ)) := by
      rw [dist_eq, cantorDist, if_neg hxy]
    rcases Nat.eq_zero_or_pos (firstDiff x y) with h0 | hpos
    · have h1 : dist (shift x) (shift y) ≤ 1 := dist_le_one _ _
      have h2 : dist x y = 1 := by rw [hdxy, h0]; norm_num
      rw [h2]; linarith
    · obtain ⟨m, hm⟩ : ∃ m, firstDiff x y = m + 1 := ⟨firstDiff x y - 1, by omega⟩
      have hA : AgreeTo (m + 1) x y := by
        rw [agreeTo_iff_le_firstDiff hxy, hm]
      have hAs : AgreeTo m (shift x) (shift y) := (agreeTo_succ_iff.mp hA).2
      have h1 : dist (shift x) (shift y) ≤ (2 : ℝ) ^ (-(m : ℤ)) :=
        (dist_le_iff_agreeTo _ _ m).mpr hAs
      have h2 : (2 : ℝ) ^ (-(m : ℤ)) = 2 * (2 : ℝ) ^ (-((m : ℤ) + 1)) := by
        rw [zpow_neg, zpow_neg, zpow_add₀ (by norm_num : (2:ℝ) ≠ 0), zpow_one]
        field_simp
      have h3 : dist x y = (2 : ℝ) ^ (-((m : ℤ) + 1)) := by
        rw [hdxy, hm]; congr 1
      rw [h3, ← h2]
      exact h1

/-- The shift is continuous. -/
theorem continuous_shift : Continuous shift :=
  (LipschitzWith.of_dist_le_mul (K := 2) (by simpa using dist_shift_le)).continuous

/-! ## The golden-mean subshift -/

/-- The golden-mean subshift: no two consecutive `true` answers. -/
def GoldenMean : Set Cantor := {x | ∀ k, ¬(x k = true ∧ x (k + 1) = true)}

theorem mem_goldenMean {x : Cantor} :
    x ∈ GoldenMean ↔ ∀ k, ¬(x k = true ∧ x (k + 1) = true) := Iff.rfl

/-- The all-`false` stream lies in the subshift, which is therefore nonempty. -/
theorem goldenMean_nonempty : GoldenMean.Nonempty :=
  ⟨(fun _ => false : Cantor), fun k h => by simp at h⟩

/-- **The golden-mean subshift is closed**: its complement is open because the defining
condition is decided by finitely many coordinates. -/
theorem isClosed_goldenMean : IsClosed GoldenMean := by
  rw [← isOpen_compl_iff, Metric.isOpen_iff]
  intro x hx
  simp only [GoldenMean, Set.mem_compl_iff, Set.mem_setOf_eq, not_forall, not_not] at hx
  obtain ⟨k, hk⟩ := hx
  refine ⟨(2 : ℝ) ^ (-((k + 2 : ℕ) : ℤ)), two_zpow_pos _, ?_⟩
  intro y hy
  have hd : dist x y < (2 : ℝ) ^ (-((k + 2 : ℕ) : ℤ)) := by
    rw [dist_comm]; exact hy
  have hA : AgreeTo (k + 2) x y := agreeTo_of_dist_lt hd
  have h1 : x k = y k := hA k (by omega)
  have h2 : x (k + 1) = y (k + 1) := hA (k + 1) (by omega)
  intro hy'
  exact hy' k ⟨h1 ▸ hk.1, h2 ▸ hk.2⟩

/-- The subshift is compact, being a closed subset of a compact space. -/
theorem isCompact_goldenMean : IsCompact GoldenMean :=
  isClosed_goldenMean.isCompact

/-- The subshift is shift invariant. -/
theorem mapsTo_shift_goldenMean : Set.MapsTo shift GoldenMean GoldenMean := by
  intro x hx k hk
  exact hx (k + 1) hk

/-! ### The subshift is perfect -/

/-- Truncation of a subshift point stays in the subshift. -/
theorem trunc_mem_goldenMean {x : Cantor} (hx : x ∈ GoldenMean) (n : ℕ) :
    trunc n x ∈ GoldenMean := by
  intro k hk
  by_cases h1 : k < n
  · by_cases h2 : k + 1 < n
    · exact hx k ⟨by simpa [trunc, h1] using hk.1, by simpa [trunc, h2] using hk.2⟩
    · simp [trunc, h2] at hk
  · simp [trunc, h1] at hk

/-- The truncation with a single extra spike at position `n+1`. -/
def truncSpike (n : ℕ) (x : Cantor) : Cantor :=
  fun k => if k < n then x k else decide (k = n + 1)

theorem truncSpike_mem_goldenMean {x : Cantor} (hx : x ∈ GoldenMean) (n : ℕ) :
    truncSpike n x ∈ GoldenMean := by
  intro k hk
  obtain ⟨h1, h2⟩ := hk
  by_cases hkn : k < n
  · by_cases hk1 : k + 1 < n
    · exact hx k ⟨by simpa [truncSpike, hkn] using h1, by simpa [truncSpike, hk1] using h2⟩
    · have hkn1 : k + 1 = n := by omega
      rw [truncSpike] at h2
      simp only [hk1, if_false, decide_eq_true_eq] at h2
      omega
  · rw [truncSpike] at h1
    simp only [hkn, if_false, decide_eq_true_eq] at h1
    subst h1
    rw [truncSpike] at h2
    have : ¬ (n + 1 + 1 < n) := by omega
    simp only [this, if_false, decide_eq_true_eq] at h2
    omega

theorem trunc_ne_truncSpike (n : ℕ) (x : Cantor) : trunc n x ≠ truncSpike n x := by
  intro h
  have := congrFun h (n + 1)
  simp [trunc, truncSpike] at this

theorem agreeTo_truncSpike (n : ℕ) (x : Cantor) : AgreeTo n x (truncSpike n x) := by
  intro k hk
  simp [truncSpike, hk]

/-- **The golden-mean subshift is perfect**: every point is a limit of *other* points of the
subshift, so it has no isolated points. -/
theorem goldenMean_perfect {x : Cantor} (hx : x ∈ GoldenMean) {ε : ℝ} (hε : 0 < ε) :
    ∃ y ∈ GoldenMean, y ≠ x ∧ dist x y < ε := by
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  by_cases h : trunc n x = x
  · refine ⟨truncSpike n x, truncSpike_mem_goldenMean hx n, ?_, ?_⟩
    · intro hEq
      exact trunc_ne_truncSpike n x (h.trans hEq.symm)
    · exact lt_of_le_of_lt ((dist_le_iff_agreeTo _ _ n).mpr (agreeTo_truncSpike n x)) hn
  · refine ⟨trunc n x, trunc_mem_goldenMean hx n, h, ?_⟩
    exact lt_of_le_of_lt ((dist_le_iff_agreeTo _ _ n).mpr (agreeTo_trunc n x)) hn

/-- Consequently the subshift is a nonempty compact set with no isolated points. -/
theorem goldenMean_no_isolated {x : Cantor} (hx : x ∈ GoldenMean) :
    ¬ ∃ ε > 0, GoldenMean ∩ ball x ε = {x} := by
  rintro ⟨ε, hε, h⟩
  obtain ⟨y, hy, hyx, hd⟩ := goldenMean_perfect hx hε
  have : y ∈ GoldenMean ∩ ball x ε := ⟨hy, by rwa [mem_ball, dist_comm]⟩
  rw [h] at this
  exact hyx this

/-! ## Admissible words and the Fibonacci count -/

/-- A finite word is admissible when it has no two consecutive `true`s. -/
def Admissible (l : List Bool) : Prop := l.IsChain (fun a b => ¬(a = true ∧ b = true))

theorem admissible_nil : Admissible [] := List.isChain_nil

theorem admissible_singleton (b : Bool) : Admissible [b] := List.isChain_singleton _

/-- Prefixing an admissible word by `false` keeps it admissible. -/
theorem admissible_false_cons {l : List Bool} (h : Admissible l) : Admissible (false :: l) := by
  cases l with
  | nil => exact admissible_singleton _
  | cons c l' => exact List.isChain_cons_cons.mpr ⟨by simp, h⟩

/-- Prefixing an admissible word by `true false` keeps it admissible. -/
theorem admissible_true_false_cons {l : List Bool} (h : Admissible l) :
    Admissible (true :: false :: l) :=
  List.isChain_cons_cons.mpr ⟨by simp, admissible_false_cons h⟩

/-- Prefixing by a bit that does not clash with the head. -/
theorem admissible_cons_cons {b c : Bool} {l : List Bool} (hbc : ¬(b = true ∧ c = true))
    (h : Admissible (c :: l)) : Admissible (b :: c :: l) :=
  List.isChain_cons_cons.mpr ⟨hbc, h⟩

theorem Admissible.tail {l : List Bool} (h : Admissible l) : Admissible l.tail :=
  List.IsChain.tail h

/-- The Finset of admissible words of length `n`, defined by the golden-mean recursion:
an admissible word either starts with `false`, or starts with `true false`. -/
def goldenWords : ℕ → Finset (List Bool)
  | 0 => {[]}
  | 1 => {[false], [true]}
  | (n + 2) =>
      (goldenWords (n + 1)).image (List.cons false) ∪
        (goldenWords n).image (fun l => true :: false :: l)

theorem goldenWords_zero : goldenWords 0 = {[]} := rfl
theorem goldenWords_one : goldenWords 1 = {[false], [true]} := rfl
theorem goldenWords_succ_succ (n : ℕ) :
    goldenWords (n + 2) =
      (goldenWords (n + 1)).image (List.cons false) ∪
        (goldenWords n).image (fun l => true :: false :: l) := rfl

theorem cons_false_injective : Function.Injective (List.cons false) := by
  intro a b h; exact (List.cons_inj_right false).mp h

theorem cons_true_false_injective : Function.Injective (fun l : List Bool => true :: false :: l) := by
  intro a b h
  simpa using h

/-- **The Fibonacci count**: there are `fib (n+2)` admissible words of length `n`. -/
theorem card_goldenWords : ∀ n : ℕ, (goldenWords n).card = Nat.fib (n + 2)
  | 0 => by decide
  | 1 => by decide
  | (n + 2) => by
      have ih1 := card_goldenWords (n + 1)
      have ih2 := card_goldenWords n
      have hdisj : Disjoint ((goldenWords (n + 1)).image (List.cons false))
          ((goldenWords n).image (fun l => true :: false :: l)) := by
        rw [Finset.disjoint_left]
        rintro a ha hb
        obtain ⟨l, _, rfl⟩ := Finset.mem_image.mp ha
        obtain ⟨m, _, hm⟩ := Finset.mem_image.mp hb
        simp at hm
      rw [goldenWords_succ_succ, Finset.card_union_of_disjoint hdisj,
        Finset.card_image_of_injective _ cons_false_injective,
        Finset.card_image_of_injective _ cons_true_false_injective, ih1, ih2]
      have hfib : Nat.fib (n + 2 + 2) = Nat.fib (n + 2) + Nat.fib (n + 2 + 1) := Nat.fib_add_two
      have e : n + 1 + 2 = n + 2 + 1 := by omega
      rw [e, hfib]
      omega

/-- The recursive description of `goldenWords` really is the set of admissible words of the
given length. -/
theorem mem_goldenWords : ∀ (n : ℕ) (l : List Bool),
    l ∈ goldenWords n ↔ l.length = n ∧ Admissible l
  | 0, l => by
      constructor
      · intro h
        rw [goldenWords_zero, Finset.mem_singleton] at h
        subst h; exact ⟨rfl, admissible_nil⟩
      · rintro ⟨h, -⟩
        rw [goldenWords_zero, Finset.mem_singleton, List.length_eq_zero_iff.mp h]
  | 1, l => by
      constructor
      · intro h
        rw [goldenWords_one, Finset.mem_insert, Finset.mem_singleton] at h
        rcases h with rfl | rfl <;> exact ⟨rfl, admissible_singleton _⟩
      · rintro ⟨h, -⟩
        rw [goldenWords_one, Finset.mem_insert, Finset.mem_singleton]
        match l, h with
        | [b], _ => cases b <;> simp
  | (n + 2), l => by
      have ih1 := mem_goldenWords (n + 1)
      have ih2 := mem_goldenWords n
      rw [goldenWords_succ_succ, Finset.mem_union, Finset.mem_image, Finset.mem_image]
      constructor
      · rintro (⟨w, hw, rfl⟩ | ⟨w, hw, rfl⟩)
        · obtain ⟨hlen, hadm⟩ := (ih1 w).mp hw
          exact ⟨by simp [hlen], admissible_false_cons hadm⟩
        · obtain ⟨hlen, hadm⟩ := (ih2 w).mp hw
          exact ⟨by simp [hlen], admissible_true_false_cons hadm⟩
      · rintro ⟨hlen, hadm⟩
        match l, hlen with
        | (b :: rest), hlen =>
          have hrest : rest.length = n + 1 := by simpa using hlen
          cases b with
          | false =>
              left
              exact ⟨rest, (ih1 rest).mpr ⟨hrest, Admissible.tail hadm⟩, rfl⟩
          | true =>
              right
              match rest, hrest with
              | (c :: rest'), hrest =>
                have hc : c = false := by
                  have hrel := (List.isChain_cons_cons.mp hadm).1
                  cases c
                  · rfl
                  · exact absurd ⟨rfl, rfl⟩ hrel
                subst hc
                have hrest' : rest'.length = n := by simpa using hrest
                exact ⟨rest', (ih2 rest').mpr
                  ⟨hrest', Admissible.tail (List.isChain_cons_cons.mp hadm).2⟩, rfl⟩

/-! ### Prefixes of subshift points -/

/-- The length-`n` prefix of a stream, as a word. -/
def prefixOf : ℕ → Cantor → List Bool
  | 0, _ => []
  | (n + 1), x => x 0 :: prefixOf n (shift x)

@[simp] theorem prefixOf_zero (x : Cantor) : prefixOf 0 x = [] := rfl
@[simp] theorem prefixOf_succ (n : ℕ) (x : Cantor) :
    prefixOf (n + 1) x = x 0 :: prefixOf n (shift x) := rfl

theorem length_prefixOf : ∀ (n : ℕ) (x : Cantor), (prefixOf n x).length = n
  | 0, _ => rfl
  | (n + 1), x => by simp [length_prefixOf n (shift x)]

theorem head?_prefixOf_succ (n : ℕ) (x : Cantor) :
    (prefixOf (n + 1) x).head? = some (x 0) := rfl

/-- **Prefixes separate points at scale `2⁻ⁿ`.** -/
theorem prefixOf_eq_iff_agreeTo : ∀ (n : ℕ) (x y : Cantor),
    prefixOf n x = prefixOf n y ↔ AgreeTo n x y
  | 0, x, y => by
      simp only [prefixOf_zero, true_iff]
      exact fun k hk => absurd hk (Nat.not_lt_zero k)
  | (n + 1), x, y => by
      rw [prefixOf_succ, prefixOf_succ, List.cons_eq_cons, agreeTo_succ_iff,
        prefixOf_eq_iff_agreeTo n (shift x) (shift y)]

theorem dist_le_iff_prefixOf_eq (n : ℕ) (x y : Cantor) :
    dist x y ≤ (2 : ℝ) ^ (-(n : ℤ)) ↔ prefixOf n x = prefixOf n y := by
  rw [dist_le_iff_agreeTo, ← prefixOf_eq_iff_agreeTo]

/-- Prefixes of subshift points are admissible words. -/
theorem prefixOf_mem_goldenWords : ∀ (n : ℕ) {x : Cantor}, x ∈ GoldenMean →
    prefixOf n x ∈ goldenWords n
  | 0, x, _ => by rw [mem_goldenWords]; exact ⟨rfl, admissible_nil⟩
  | (n + 1), x, hx => by
      rw [mem_goldenWords]
      refine ⟨by simp [length_prefixOf], ?_⟩
      have hs : shift x ∈ GoldenMean := mapsTo_shift_goldenMean hx
      have htail : Admissible (prefixOf n (shift x)) :=
        ((mem_goldenWords n _).mp (prefixOf_mem_goldenWords n hs)).2
      cases n with
      | zero => exact admissible_singleton _
      | succ m =>
          rw [prefixOf_succ, prefixOf_succ]
          rw [prefixOf_succ] at htail
          exact admissible_cons_cons (hx 0) htail

/-- Extend a finite word to a stream by padding with `false`. -/
def extend (l : List Bool) : Cantor := fun k => l.getD k false

@[simp] theorem extend_nil : extend [] = (fun _ => false : Cantor) := rfl

@[simp] theorem extend_cons_zero (b : Bool) (l : List Bool) : extend (b :: l) 0 = b := rfl

theorem shift_extend_cons (b : Bool) (l : List Bool) : shift (extend (b :: l)) = extend l := by
  funext k
  simp [shift, extend]

/-- Every admissible word is the prefix of a point of the subshift: pad with `false`. -/
theorem extend_mem_goldenMean : ∀ (l : List Bool), Admissible l → extend l ∈ GoldenMean
  | [], _ => by intro k hk; simp [extend] at hk
  | [b], _ => by
      intro k hk
      have hb : extend [b] (k + 1) = false := by
        simp [extend]
      rw [hb] at hk
      simp at hk
  | (b :: c :: l), h => by
      have hbc : ¬(b = true ∧ c = true) := (List.isChain_cons_cons.mp h).1
      have htail : Admissible (c :: l) := (List.isChain_cons_cons.mp h).2
      have ih := extend_mem_goldenMean (c :: l) htail
      intro k hk
      cases k with
      | zero =>
          have h1 : extend (b :: c :: l) 0 = b := rfl
          have h2 : extend (b :: c :: l) 1 = c := rfl
          rw [h1, h2] at hk
          exact hbc hk
      | succ j =>
          have h1 : extend (b :: c :: l) (j + 1) = extend (c :: l) j := by
            simp [extend]
          have h2 : extend (b :: c :: l) (j + 1 + 1) = extend (c :: l) (j + 1) := by
            simp [extend]
          rw [h1, h2] at hk
          exact ih j hk

theorem prefixOf_extend : ∀ (l : List Bool), prefixOf l.length (extend l) = l
  | [] => rfl
  | (b :: l) => by
      have ih := prefixOf_extend l
      rw [List.length_cons, prefixOf_succ, extend_cons_zero, shift_extend_cons, ih]

/-- **Exact prefix combinatorics of the subshift.** The length-`n` prefixes of points of the
golden-mean subshift are exactly the admissible words of length `n`. -/
theorem goldenWords_eq_image_prefixOf (n : ℕ) :
    (prefixOf n) '' GoldenMean = ↑(goldenWords n) := by
  ext w
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact prefixOf_mem_goldenWords n hx
  · intro hw
    obtain ⟨hlen, hadm⟩ := (mem_goldenWords n w).mp hw
    refine ⟨extend w, extend_mem_goldenMean w hadm, ?_⟩
    rw [← hlen]
    exact prefixOf_extend w

/-- The number of distinct depth-`n` observations of the subshift is `fib (n+2)`. -/
theorem ncard_image_prefixOf (n : ℕ) :
    ((prefixOf n) '' GoldenMean).ncard = Nat.fib (n + 2) := by
  rw [goldenWords_eq_image_prefixOf, Set.ncard_coe_finset, card_goldenWords]

/-! ### Covering and packing at scale `2⁻ⁿ` -/

/-- **Covering.** The subshift is covered by the `fib (n+2)` closed balls of radius `2⁻ⁿ`
centred at the padded admissible words. -/
theorem goldenMean_cover (n : ℕ) :
    GoldenMean ⊆ ⋃ w ∈ goldenWords n, closedBall (extend w) ((2 : ℝ) ^ (-(n : ℤ))) := by
  intro x hx
  refine Set.mem_iUnion₂.mpr ⟨prefixOf n x, prefixOf_mem_goldenWords n hx, ?_⟩
  rw [mem_closedBall, dist_le_iff_prefixOf_eq]
  have h := prefixOf_extend (prefixOf n x)
  rw [length_prefixOf] at h
  exact h.symm

/-- **Packing.** Distinct admissible words of length `n` give subshift points at distance
strictly greater than `2⁻ⁿ`; so the covering above is optimal. -/
theorem goldenWords_separated {n : ℕ} {v w : List Bool} (hv : v ∈ goldenWords n)
    (hw : w ∈ goldenWords n) (hvw : v ≠ w) :
    (2 : ℝ) ^ (-(n : ℤ)) < dist (extend v) (extend w) := by
  by_contra hle
  push_neg at hle
  rw [dist_le_iff_prefixOf_eq] at hle
  obtain ⟨hlv, -⟩ := (mem_goldenWords n v).mp hv
  obtain ⟨hlw, -⟩ := (mem_goldenWords n w).mp hw
  apply hvw
  have h1 : prefixOf n (extend v) = v := by rw [← hlv]; exact prefixOf_extend v
  have h2 : prefixOf n (extend w) = w := by rw [← hlw]; exact prefixOf_extend w
  rw [← h1, ← h2, hle]

/-- The padded admissible words are genuine points of the subshift, so the packing above is a
packing *of the subshift itself*. -/
theorem extend_goldenWords_mem (n : ℕ) {w : List Bool} (hw : w ∈ goldenWords n) :
    extend w ∈ GoldenMean :=
  extend_mem_goldenMean w ((mem_goldenWords n w).mp hw).2

end FractalTruthCompactness