import Mathlib

/-!
# Dyson intelligence growth: counting, compactness, and diagonal limits

This file gives a precise discrete model of theorem discovery.  A schedule assigns
finitely many theorem codes to each time.  The central results separate three
issues that informal discussions often conflate:

* no finite time covers an infinite syntax, even at an enormous finite rate;
* every countable syntax can nevertheless be covered eventually at rate one;
* if possible mathematical objects include all predicates on `ℕ`, Cantor's
  diagonal argument defeats every countable discovery stream.

Thus neither superexponential growth implies a finite deadline for all theorem
codes, nor does merely exponential growth force a permanently missed code.
The final diagonal theorem does establish a genuine expressibility barrier after
moving from countable formal syntax to the uncountable semantic space `ℕ → Prop`.
-/

namespace DysonIntelligence

/-- A discrete civilization records finitely many discoveries at every time. -/
abbrev Schedule (α : Type*) := ℕ → Finset α

/-- The discoveries made no later than time `N`. -/
def discoveredBy [DecidableEq α] (s : Schedule α) (N : ℕ) : Finset α :=
  (Finset.range (N + 1)).biUnion s

/-- A theorem is eventually discovered. -/
def EventuallyDiscovered [DecidableEq α] (s : Schedule α) (a : α) : Prop :=
  ∃ n, a ∈ s n

/-- A pointwise upper bound on discoveries per time step. -/
def RateBound (s : Schedule α) (r : ℕ → ℕ) : Prop :=
  ∀ n, (s n).card ≤ r n

/-- Dyson's illustrative double-exponential rate. -/
def dysonRate (n : ℕ) : ℕ := 2 ^ (2 ^ n)

/-- At any finite deadline, only the sum of the preceding finite batches can
have been discovered. -/
theorem cumulative_card_bound [DecidableEq α] (s : Schedule α) (N : ℕ) :
    (discoveredBy s N).card ≤ ∑ n ∈ Finset.range (N + 1), (s n).card := by
  rw [discoveredBy]
  exact Finset.card_biUnion_le

/-- A uniform physical cap `C` permits at most `(N+1)C` discoveries by time `N`.
This is the exact finite-horizon consequence of a Bekenstein-style cap. -/
theorem physical_cap_finite_horizon [DecidableEq α] (s : Schedule α) (C N : ℕ)
    (hcap : RateBound s (fun _ => C)) :
    (discoveredBy s N).card ≤ (N + 1) * C := by
  have h1 := cumulative_card_bound s N
  have h2 : ∑ n ∈ Finset.range (N + 1), (s n).card ≤
      ∑ n ∈ Finset.range (N + 1), C := by
    exact Finset.sum_le_sum (fun n _ => hcap n)
  simp only [Finset.sum_const, Finset.card_range, smul_eq_mul] at h2
  exact le_trans h1 h2

/-- No finite deadline covers all countably many theorem codes, regardless of
how quickly the finite batches grow. -/
theorem finite_deadline_misses_code (s : Schedule ℕ) (N : ℕ) :
    ∃ code : ℕ, code ∉ discoveredBy s N := by
  use (discoveredBy s N).sum (fun x => x + 1)
  intro h_mem
  have h : ∀ x ∈ discoveredBy s N, x + 1 ≤ ∑ x ∈ discoveredBy s N, (x + 1) := by
    intro x hx
    exact Finset.single_le_sum (fun a _ => Nat.zero_le (a + 1)) hx
  have := h _ h_mem
  omega

/-- Consequently, finite per-stage superexponential discovery does not imply
that all codes have been found at one finite time. -/
theorem no_finite_universal_deadline (s : Schedule ℕ) :
    ¬ ∃ N, ∀ code : ℕ, code ∈ discoveredBy s N := by
  intro ⟨N, hN⟩
  obtain ⟨code, hcode⟩ := finite_deadline_misses_code s N
  exact hcode (hN code)

/-- The schedule that discovers code `n` at time `n`. -/
def enumerationSchedule : Schedule ℕ := fun n => {n}

/-- The enumeration schedule makes exactly one discovery at every stage. -/
theorem enumerationSchedule_card (n : ℕ) :
    (enumerationSchedule n).card = 1 := by
  simp [enumerationSchedule]

/-- Despite its minimal rate, the enumeration schedule eventually discovers
all codes. -/
theorem enumerationSchedule_complete (code : ℕ) :
    EventuallyDiscovered enumerationSchedule code := by
  exact ⟨code, by simp [enumerationSchedule]⟩

/-- In particular, a schedule bounded by the merely exponential rate `2^n` can
still discover every code.  Hence an exponential upper bound alone cannot yield
a Gödel-style permanently missed syntactic theorem. -/
theorem exponential_rate_can_be_complete :
    RateBound enumerationSchedule (fun n => 2 ^ n) ∧
      ∀ code : ℕ, EventuallyDiscovered enumerationSchedule code := by
  constructor
  · intro n
    simp [enumerationSchedule]
    exact Nat.one_le_pow n 2 (by norm_num)
  · exact enumerationSchedule_complete

/-- The same complete schedule also lies below Dyson's double-exponential rate.
Large throughput is therefore neither necessary for eventual enumeration nor
sufficient for a common finite completion time. -/
theorem dyson_rate_can_be_complete :
    RateBound enumerationSchedule dysonRate ∧
      ∀ code : ℕ, EventuallyDiscovered enumerationSchedule code := by
  refine ⟨fun n => ?_, enumerationSchedule_complete⟩
  rw [enumerationSchedule_card]
  exact Nat.one_le_two_pow

/-- A finite-family compactness principle: if every member of a finite corpus is
eventually discovered, then one finite deadline works for the whole corpus. -/
theorem finite_corpus_common_deadline [DecidableEq α] (s : Schedule α)
    (corpus : Finset α)
    (h : ∀ a ∈ corpus, EventuallyDiscovered s a) :
    ∃ N, ∀ a ∈ corpus, a ∈ discoveredBy s N := by
  choose! n hn using h
  use corpus.sup n
  intro a ha
  rw [discoveredBy, Finset.mem_biUnion]
  exact ⟨n a, Finset.mem_range.mpr (Nat.lt_succ_of_le (Finset.le_sup ha)), hn a ha⟩

/-! ## Semantic diagonal barrier -/

/-- Given a stream of predicates, negate the `n`th predicate on its own index. -/
def diagonalPredicate (f : ℕ → (ℕ → Prop)) : ℕ → Prop :=
  fun n => ¬ f n n

/-- Cantor diagonalization: the diagonal predicate differs from every predicate
in the stream.  This is the rigorous sense in which a countable discovery
process cannot exhaust all semantic predicates. -/
theorem diagonalPredicate_not_discovered (f : ℕ → (ℕ → Prop)) (k : ℕ) :
    diagonalPredicate f ≠ f k := by
  intro h
  have := congr_fun h k
  simp [diagonalPredicate] at this

/-- There is no surjection from theorem codes onto all predicates on naturals. -/
theorem no_enumeration_of_all_predicates :
    ¬ ∃ f : ℕ → (ℕ → Prop), Function.Surjective f := by
  intro ⟨f, hf⟩
  obtain ⟨k, hk⟩ := hf (diagonalPredicate f)
  exact diagonalPredicate_not_discovered f k hk.symm

/-- Strong form: every proposed countable semantic catalogue has a predicate
outside its range, supplied explicitly by diagonalization. -/
theorem semantic_expressibility_barrier (f : ℕ → (ℕ → Prop)) :
    ∃ P : ℕ → Prop, ∀ k, P ≠ f k := by
  use diagonalPredicate f
  exact diagonalPredicate_not_discovered f

end DysonIntelligence