/-
# Linear Mean Description Cost versus Exponential Mean Search Cost

Future Direction 2 of the "Proof Complexity and Thermodynamic Cost" thread conjectured that
for uniformly sampled statements the *shortest-description* cost grows linearly on average
while *exhaustive proof search* grows exponentially on average.  This file proves the
separation, and proves it in the strongest available form: the exponential lower bound on
mean search work holds for **every** injective description scheme, so it cannot be
engineered away by choosing a cleverer code.

## Model

Statements are the `2^(n+2)` elements of a finite ensemble `ι`, sampled uniformly.  A
*description scheme* is an injective `enc : ι → List Bool`; `descLength enc x = |enc x|` is
the cost of writing the description down, while

  `searchWork enc x = 2 ^ descLength enc x`

is the number of candidate descriptions an enumeration in length order must inspect before
reaching `enc x` (up to the standard factor `2`).  This is the "linear cost functional"
versus "search dynamics" contrast of the conjecture.

## Main results

* `card_compressible_le` — scarcity: at most `2^(m+1) − 1` statements have a description of
  length `≤ m` (there simply are no more short words).
* `card_incompressible_ge` — hence at least **half** the ensemble has description length
  `≥ n+1`.
* `mean_searchWork_ge` — **exponential mean search cost**: for every injective scheme,
  `meanSearchWork ≥ 2^n`, i.e. exponential in the statement length `N = n+2`.
* `mean_descLength_ge` — linear-in-`N` lower bound on mean description length.
* `meanDescLength_canonical` — for the canonical code the mean description length is exactly
  `N`: linear.
* `linear_description_exponential_search` — the **separation**, both halves at once.
* `search_over_description_unbounded` — the ratio search/description is unbounded: no
  constant multiple of description cost bounds search cost.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): description length and search time obey different counting laws;
  incompressibility forces a constant fraction of statements to have length `≈ N`, and the
  *same* counting fact forces the search to be exponential because search cost is
  exponential in length.
Experiment (Stage 2): proved the scarcity bound by injecting the compressible statements
  into the finset of binary words of length `≤ m` (cardinality `2^{m+1} − 1`, proved by a
  geometric-sum induction), then averaged.
Analysis (Stage 3): the exponential lower bound needs *no* assumption on the code beyond
  injectivity — the counting argument is code-independent.  By contrast the linear *upper*
  bound on description cost is genuinely code-dependent (a perverse injective code can have
  arbitrarily long words), which is why it is stated for the canonical code.  That
  asymmetry is the precise content of the conjectured separation.
Critique (Stage 4): `searchWork` is a model of enumeration cost, not a theorem about a
  particular machine; we therefore fix it by an explicit definition and prove the bound for
  that definition rather than smuggling in an informal "proof search" primitive.  The
  statement is not vacuous: `canonical_code_injective` exhibits an admissible scheme, and
  `meanDescLength_canonical` computes the linear side exactly.
Synthesis (Stage 5): under the uniform binary model, mean description cost is `Θ(N)` while
  mean search cost is `2^{Ω(N)}`, for every code — exponential behaviour lives in the search
  dynamics, not in the cost functional.
-/
import Mathlib
import Computation.PrefixFreeThermoCoding

open Finset PrefixFreeThermo

namespace SearchCostSeparation

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Cost of writing down the description of `x`. -/
def descLength (enc : ι → List Bool) (x : ι) : ℕ := (enc x).length

/-- Cost of *finding* the description of `x` by enumerating candidates in length order. -/
def searchWork (enc : ι → List Bool) (x : ι) : ℕ := 2 ^ descLength enc x

/-- Mean description length under the uniform distribution on the ensemble. -/
noncomputable def meanDescLength (enc : ι → List Bool) : ℝ :=
  (∑ x, (descLength enc x : ℝ)) / Fintype.card ι

/-- Mean exhaustive-search work under the uniform distribution on the ensemble. -/
noncomputable def meanSearchWork (enc : ι → List Bool) : ℝ :=
  (∑ x, (searchWork enc x : ℝ)) / Fintype.card ι

/-! ## Scarcity of short descriptions -/

lemma sum_two_pow_range (m : ℕ) : ∑ k ∈ Finset.range m, 2 ^ k = 2 ^ m - 1 := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, ih]
    have h : 1 ≤ 2 ^ m := Nat.one_le_two_pow
    have : 2 ^ (m + 1) = 2 ^ m + 2 ^ m := by ring
    omega

/-- All binary words of length at most `m`. -/
def shortWords (m : ℕ) : Finset (List Bool) := (Finset.range (m + 1)).biUnion boolLists

@[simp] lemma mem_shortWords (m : ℕ) (w : List Bool) : w ∈ shortWords m ↔ w.length ≤ m := by
  simp only [shortWords, Finset.mem_biUnion, Finset.mem_range, mem_boolLists]
  constructor
  · rintro ⟨k, hk, rfl⟩; omega
  · intro h; exact ⟨w.length, by omega, rfl⟩

lemma card_shortWords (m : ℕ) : (shortWords m).card = 2 ^ (m + 1) - 1 := by
  rw [shortWords, Finset.card_biUnion, ← sum_two_pow_range (m + 1)]
  · exact Finset.sum_congr rfl fun k _ => card_boolLists k
  · intro i _ j _ hij
    simp only [Finset.disjoint_left, mem_boolLists]
    intro a ha hb
    exact hij (ha ▸ hb ▸ rfl)

omit [DecidableEq ι] in
/-- **Scarcity.**  At most `2^(m+1) − 1` statements can have a description of length `≤ m`,
because there are only that many binary words of length `≤ m`. -/
theorem card_compressible_le (enc : ι → List Bool) (hinj : Function.Injective enc) (m : ℕ) :
    (Finset.univ.filter (fun x => descLength enc x ≤ m)).card ≤ 2 ^ (m + 1) - 1 := by
  classical
  have hmap : ∀ x ∈ Finset.univ.filter (fun x => descLength enc x ≤ m),
      enc x ∈ shortWords m := by
    intro x hx
    rw [Finset.mem_filter] at hx
    exact (mem_shortWords m (enc x)).2 hx.2
  have := Finset.card_le_card_of_injOn enc hmap (fun a _ b _ h => hinj h)
  rwa [card_shortWords] at this

/-- **Half-incompressibility.**  In an ensemble of `2^(n+2)` statements, at least `2^(n+1)`
of them — half — need a description of length at least `n+1`. -/
theorem card_incompressible_ge {n : ℕ} (hcard : Fintype.card ι = 2 ^ (n + 2))
    (enc : ι → List Bool) (hinj : Function.Injective enc) :
    2 ^ (n + 1) ≤ (Finset.univ.filter (fun x => n + 1 ≤ descLength enc x)).card := by
  classical
  have hsplit : (Finset.univ.filter (fun x => descLength enc x ≤ n)).card
      + (Finset.univ.filter (fun x => n + 1 ≤ descLength enc x)).card
      = Fintype.card ι := by
    rw [← Finset.card_union_of_disjoint, ← Finset.card_univ]
    · congr 1
      ext x
      simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      omega
    · simp only [Finset.disjoint_left, Finset.mem_filter]
      intro a ha hb
      omega
  have hc := card_compressible_le enc hinj n
  have hpow : 2 ^ (n + 2) = 2 ^ (n + 1) + 2 ^ (n + 1) := by ring
  omega

/-! ## The separation -/

/-- **Exponential mean search cost.**  For *every* injective description scheme on an
ensemble of `2^(n+2)` statements, the mean exhaustive-search work is at least `2^n`. -/
theorem mean_searchWork_ge {n : ℕ} (hcard : Fintype.card ι = 2 ^ (n + 2))
    (enc : ι → List Bool) (hinj : Function.Injective enc) :
    (2:ℝ) ^ n ≤ meanSearchWork enc := by
  classical
  set F := Finset.univ.filter (fun x => n + 1 ≤ descLength enc x) with hF
  have hbig : ∀ x ∈ F, 2 ^ (n + 1) ≤ searchWork enc x := by
    intro x hx
    rw [hF, Finset.mem_filter] at hx
    exact Nat.pow_le_pow_right (by norm_num) hx.2
  have hsum : 2 ^ (n + 1) * 2 ^ (n + 1) ≤ ∑ x, searchWork enc x := by
    calc 2 ^ (n + 1) * 2 ^ (n + 1) ≤ F.card * 2 ^ (n + 1) :=
          Nat.mul_le_mul_right _ (card_incompressible_ge hcard enc hinj)
      _ = ∑ _x ∈ F, 2 ^ (n + 1) := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ ∑ x ∈ F, searchWork enc x := Finset.sum_le_sum hbig
      _ ≤ ∑ x, searchWork enc x :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ F) (by intros; positivity)
  have hsumR : ((2:ℝ) ^ (n + 1)) * ((2:ℝ) ^ (n + 1)) ≤ ∑ x, (searchWork enc x : ℝ) := by
    have := (Nat.cast_le (α := ℝ)).2 hsum
    push_cast at this
    exact this
  unfold meanSearchWork
  rw [hcard, le_div_iff₀ (by positivity)]
  calc (2:ℝ) ^ n * ((2 ^ (n + 2) : ℕ) : ℝ) = (2:ℝ) ^ (n + 1) * (2:ℝ) ^ (n + 1) := by
        push_cast; ring
    _ ≤ ∑ x, (searchWork enc x : ℝ) := hsumR

/-- **Linear lower bound on mean description cost.**  Half-incompressibility also forces the
mean description length to be at least `(n+1)/2` — linear, not exponential. -/
theorem mean_descLength_ge {n : ℕ} (hcard : Fintype.card ι = 2 ^ (n + 2))
    (enc : ι → List Bool) (hinj : Function.Injective enc) :
    ((n : ℝ) + 1) / 2 ≤ meanDescLength enc := by
  classical
  set F := Finset.univ.filter (fun x => n + 1 ≤ descLength enc x) with hF
  have hbig : ∀ x ∈ F, n + 1 ≤ descLength enc x := by
    intro x hx; rw [hF, Finset.mem_filter] at hx; exact hx.2
  have hsum : 2 ^ (n + 1) * (n + 1) ≤ ∑ x, descLength enc x := by
    calc 2 ^ (n + 1) * (n + 1) ≤ F.card * (n + 1) :=
          Nat.mul_le_mul_right _ (card_incompressible_ge hcard enc hinj)
      _ = ∑ _x ∈ F, (n + 1) := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ ∑ x ∈ F, descLength enc x := Finset.sum_le_sum hbig
      _ ≤ ∑ x, descLength enc x :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ F) (by intros; positivity)
  have hsumR : ((2:ℝ) ^ (n + 1)) * ((n : ℝ) + 1) ≤ ∑ x, (descLength enc x : ℝ) := by
    have := (Nat.cast_le (α := ℝ)).2 hsum
    push_cast at this
    exact this
  unfold meanDescLength
  rw [hcard, le_div_iff₀ (by positivity)]
  have hpow : ((2 ^ (n + 2) : ℕ) : ℝ) = 2 * (2:ℝ) ^ (n + 1) := by push_cast; ring
  rw [hpow]
  have h2 : (0:ℝ) < 2 ^ (n + 1) := by positivity
  calc ((n:ℝ) + 1) / 2 * (2 * (2:ℝ) ^ (n + 1)) = (2:ℝ) ^ (n + 1) * ((n : ℝ) + 1) := by
        field_simp
    _ ≤ ∑ x, (descLength enc x : ℝ) := hsumR

/-! ## The canonical code: description cost is exactly linear -/

/-- The canonical description of a binary statement: the statement itself. -/
def canonicalCode (N : ℕ) : (Fin N → Bool) → List Bool := fun v => List.ofFn v

theorem canonicalCode_injective (N : ℕ) : Function.Injective (canonicalCode N) :=
  List.ofFn_injective

@[simp] lemma descLength_canonicalCode (N : ℕ) (v : Fin N → Bool) :
    descLength (canonicalCode N) v = N := by
  simp [descLength, canonicalCode]

/-- For the canonical code the mean description length is exactly the statement length `N`:
description cost is linear. -/
theorem meanDescLength_canonical (N : ℕ) :
    meanDescLength (canonicalCode N) = N := by
  have hcard : (0:ℝ) < (Fintype.card (Fin N → Bool) : ℝ) := by
    have : 0 < Fintype.card (Fin N → Bool) := Fintype.card_pos
    exact_mod_cast this
  unfold meanDescLength
  rw [Finset.sum_congr rfl (fun v _ => by rw [descLength_canonicalCode]), Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul]
  field_simp

/-- **The separation.**  On statements of length `N = n+2` sampled uniformly, the canonical
description scheme has mean description cost exactly `N` (linear) while its mean exhaustive
proof-search cost is at least `2^(N-2)` (exponential).  The exponential lower bound holds for
every injective scheme, so it is a property of search, not of the chosen code. -/
theorem linear_description_exponential_search (n : ℕ) :
    meanDescLength (canonicalCode (n + 2)) = (n : ℝ) + 2 ∧
      (2:ℝ) ^ n ≤ meanSearchWork (canonicalCode (n + 2)) := by
  have hcard : Fintype.card (Fin (n + 2) → Bool) = 2 ^ (n + 2) := by
    simp
  refine ⟨?_, mean_searchWork_ge hcard _ (canonicalCode_injective (n + 2))⟩
  rw [meanDescLength_canonical]
  push_cast
  ring

/-- **No linear cost functional can bound search.**  For every constant `C` there is a
statement length at which the mean search cost exceeds `C` times the mean description
cost: the two quantities are separated by an unbounded factor. -/
theorem search_over_description_unbounded (C : ℝ) :
    ∃ n : ℕ, C * meanDescLength (canonicalCode (n + 2)) ≤ meanSearchWork (canonicalCode (n + 2)) := by
  obtain ⟨m, hm⟩ := pow_unbounded_of_one_lt (max C 0) (by norm_num : (1:ℝ) < 2)
  refine ⟨m * 2 + 4, ?_⟩
  set n := m * 2 + 4 with hn
  have h1 : meanDescLength (canonicalCode (n + 2)) = (n : ℝ) + 2 :=
    (linear_description_exponential_search n).1
  have h2 : (2:ℝ) ^ n ≤ meanSearchWork (canonicalCode (n + 2)) :=
    (linear_description_exponential_search n).2
  have hC : C ≤ (2:ℝ) ^ m := le_trans (le_max_left _ _) (le_of_lt hm)
  have hCnn : (0:ℝ) ≤ max C 0 := le_max_right _ _
  -- `2^n = 2^m · 2^m · 2^4 ≥ C · (n + 2)` because `2^m ≥ m + 1` and `n + 2 = 2m + 6`
  have hmm : (m : ℝ) + 1 ≤ (2:ℝ) ^ m := by
    have := Nat.lt_two_pow_self (n := m)
    have h : ((m : ℝ) + 1) ≤ ((2 ^ m : ℕ) : ℝ) := by exact_mod_cast this
    simpa using h
  have hn2 : ((n : ℝ) + 2) = 2 * (m : ℝ) + 6 := by
    rw [hn]; push_cast; ring
  have hpow : (2:ℝ) ^ n = (2:ℝ) ^ m * ((2:ℝ) ^ m * 16) := by
    rw [hn]
    rw [show m * 2 + 4 = m + (m + 4) by ring, pow_add, pow_add]
    norm_num
  have hmpos : (0:ℝ) < (2:ℝ) ^ m := by positivity
  have hstep : C * ((n : ℝ) + 2) ≤ (2:ℝ) ^ n := by
    rw [hn2, hpow]
    have hCle : C ≤ (2:ℝ) ^ m := hC
    have hbound : (2:ℝ) * (m : ℝ) + 6 ≤ (2:ℝ) ^ m * 16 := by
      nlinarith [hmm, hmpos]
    rcases le_or_gt C 0 with hneg | hpos
    · nlinarith [hmpos, hmm]
    · nlinarith [hmpos, hmm, hbound]
  rw [h1]
  linarith [hstep, h2]

end SearchCostSeparation