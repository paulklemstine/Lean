import Mathlib

/-!
# Arithmetic spectra and component-count saturation

This file isolates two deterministic mechanisms used in limit-law arguments for
component-pruned sparse random structures.

* `EventuallyPeriodic` is the one-dimensional form of semilinearity relevant to
  order spectra.  We prove closure under Boolean operations.
* `CountEquivalent q` records a component multiplicity exactly below `q` and only
  records "at least `q`" above it.  We prove that disjoint union (addition) respects
  this finite-state abstraction.

The final theorem is contrarian: an unrestricted, input-dependent pruning shift
can turn the finite spectrum `{0}` into an arbitrary prescribed tail.  Thus
semilinearity of the unpruned spectrum alone cannot imply a limit law when the
cutoff is allowed to oscillate without regularity assumptions.
-/

namespace ComponentPrunedLimitLaws

/-- A set of natural numbers is eventually periodic if membership is invariant
under a fixed positive translation beyond some threshold. -/
def EventuallyPeriodic (S : Set ℕ) : Prop :=
  ∃ N q : ℕ, 0 < q ∧ ∀ n, N ≤ n → (n ∈ S ↔ n + q ∈ S)

lemma eventuallyPeriodic_empty : EventuallyPeriodic (∅ : Set ℕ) := by
  -- The empty set is eventually periodic with threshold 0 and period 1.
  use 0, 1
  simp

lemma eventuallyPeriodic_univ : EventuallyPeriodic (Set.univ : Set ℕ) := by
  -- For the universal set, we can choose N = 0 and q = 1.
  use 0, 1
  simp

lemma EventuallyPeriodic.compl {S : Set ℕ} (hS : EventuallyPeriodic S) :
    EventuallyPeriodic Sᶜ := by
      obtain ⟨ N, q, hq, h ⟩ := hS; exact ⟨ N, q, hq, fun n hn => by specialize h n hn; aesop ⟩ ;

lemma EventuallyPeriodic.inter {S T : Set ℕ}
    (hS : EventuallyPeriodic S) (hT : EventuallyPeriodic T) :
    EventuallyPeriodic (S ∩ T) := by
      obtain ⟨ N₁, q₁, hq₁, hS ⟩ := hS;
      obtain ⟨ N₂, q₂, hq₂, hT ⟩ := hT;
      refine' ⟨ Max.max N₁ N₂, q₁ * q₂, by positivity, fun n hn => _ ⟩;
      -- By induction on $k$, we can show that $n + kq₁ \in S$ if and only if $n \in S$ for any $k \geq 0$.
      have h_ind_S : ∀ k : ℕ, n + k * q₁ ∈ S ↔ n ∈ S := by
        intro k; induction' k with k ih <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ] ;
        grind;
      -- By induction on $k$, we can show that $n + kq₂ \in T$ if and only if $n \in T$ for any $k \geq 0$.
      have h_ind_T : ∀ k : ℕ, n + k * q₂ ∈ T ↔ n ∈ T := by
        intro k; induction' k with k ih <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ] ;
        grind;
      simp +decide [mul_comm q₁ q₂, h_ind_S];
      exact fun _ => by rw [ mul_comm, h_ind_T ] ;

lemma EventuallyPeriodic.union {S T : Set ℕ}
    (hS : EventuallyPeriodic S) (hT : EventuallyPeriodic T) :
    EventuallyPeriodic (S ∪ T) := by
      convert @EventuallyPeriodic.compl ( Sᶜ ∩ Tᶜ ) _ using 1;
      · grind +revert;
      · convert @EventuallyPeriodic.inter _ _ hS.compl hT.compl using 1

/-
Eventual periodicity depends only on a tail of the set.
-/
lemma EventuallyPeriodic.congr_tail {S T : Set ℕ} (hS : EventuallyPeriodic S)
    (hST : ∃ M, ∀ n, M ≤ n → (n ∈ S ↔ n ∈ T)) : EventuallyPeriodic T := by
      rcases hS with ⟨ N, q, hq, h ⟩;
      exact ⟨ Max.max N hST.choose, q, hq, fun n hn ↦ by have := hST.choose_spec n ( le_trans ( le_max_right _ _ ) hn ) ; have := hST.choose_spec ( n + q ) ( by linarith [ le_max_right N hST.choose ] ) ; aesop ⟩

/-
Any finite Boolean combination of eventually periodic spectra is eventually
periodic.  This is the arithmetic closure step behind finite-state
Feferman--Vaught reductions.
-/
theorem eventuallyPeriodic_biUnion_finset {ι : Type} [DecidableEq ι]
    (A : Finset ι) (S : ι → Set ℕ) (hS : ∀ i ∈ A, EventuallyPeriodic (S i)) :
    EventuallyPeriodic (⋃ i ∈ A, S i) := by
      induction' A using Finset.induction with i A hi ih;
      · convert eventuallyPeriodic_empty using 2 ; aesop;
      · convert EventuallyPeriodic.union ( hS i ( Finset.mem_insert_self i A ) ) ( ih fun j hj => hS j ( Finset.mem_insert_of_mem hj ) ) using 1 ; aesop

/-- Multiplicities are indistinguishable at rank `q` when they agree below `q`,
and all values at least `q` are identified. -/
def CountEquivalent (q a b : ℕ) : Prop := a = b ∨ (q ≤ a ∧ q ≤ b)

lemma countEquivalent_refl (q a : ℕ) : CountEquivalent q a a := by
  exact Or.inl rfl

lemma countEquivalent_symm {q a b : ℕ} (h : CountEquivalent q a b) :
    CountEquivalent q b a := by
      exact h.elim ( fun h => Or.inl h.symm ) fun h => Or.inr ⟨ h.2, h.1 ⟩

lemma countEquivalent_trans {q a b c : ℕ}
    (hab : CountEquivalent q a b) (hbc : CountEquivalent q b c) :
    CountEquivalent q a c := by
      grind +locals

/-
The saturated component-count abstraction is a congruence for disjoint
union: component multiplicities add.
-/
theorem countEquivalent_add {q a b c d : ℕ}
    (hab : CountEquivalent q a b) (hcd : CountEquivalent q c d) :
    CountEquivalent q (a + c) (b + d) := by
      grind +locals

/-
Coordinatewise saturation is likewise preserved when two component profiles
are combined by disjoint union.
-/
theorem countProfile_add {ι : Type} {q : ℕ} {a b c d : ι → ℕ}
    (hab : ∀ i, CountEquivalent q (a i) (b i))
    (hcd : ∀ i, CountEquivalent q (c i) (d i)) :
    ∀ i, CountEquivalent q (a i + c i) (b i + d i) := by
      exact fun i => countEquivalent_add ( hab i ) ( hcd i )

/-- Shifting a spectrum by a varying cutoff.  Natural subtraction models the
residual order after deleting a cutoff-sized initial contribution. -/
def ShiftedSpectrum (S : Set ℕ) (f : ℕ → ℕ) : Set ℕ :=
  {n | n - f n ∈ S}

/-- Given any target set `A`, this cutoff leaves residual order `0` on `A` and
residual order `1` off `A`, away from the unavoidable boundary point `0`. -/
def adversarialCutoff (A : Set ℕ) [DecidablePred (· ∈ A)] (n : ℕ) : ℕ :=
  if n ∈ A then n else n - 1

/-
**Disproof of unrestricted pruning invariance.**  Although `{0}` is a finite,
hence eventually periodic, spectrum, an input-dependent cutoff can encode an
arbitrary set `A` on every positive order.  Consequently no semilinearity theorem
can survive arbitrary oscillating pruning thresholds without extra hypotheses.
-/
theorem adversarial_pruning_encodes_arbitrary_tail (A : Set ℕ)
    [DecidablePred (· ∈ A)] {n : ℕ} (hn : 0 < n) :
    n ∈ ShiftedSpectrum ({0} : Set ℕ) (adversarialCutoff A) ↔ n ∈ A := by
      unfold ShiftedSpectrum adversarialCutoff;
      grind

/-
The base spectrum used in the counterexample is genuinely eventually
periodic.
-/
theorem singleton_zero_eventuallyPeriodic :
    EventuallyPeriodic ({0} : Set ℕ) := by
      use 1;
      exact ⟨ 1, by norm_num, by aesop ⟩

/-- The sparse set of powers of two. -/
def PowersOfTwo : Set ℕ := {n | ∃ k : ℕ, n = 2 ^ k}

/-
Powers of two are not eventually periodic: every proposed positive period
is eventually shorter than the gap between consecutive powers.
-/
theorem powersOfTwo_not_eventuallyPeriodic : ¬ EventuallyPeriodic PowersOfTwo := by
  rintro ⟨ N, q, hq_pos, h ⟩;
  -- Choose $m$ such that $2^m > N$ and $2^m > q$.
  obtain ⟨ m, hm₁, hm₂ ⟩ : ∃ m : ℕ, 2^m > N ∧ 2^m > q := by
    obtain ⟨ m, hm ⟩ := pow_unbounded_of_one_lt ( Max.max N q ) one_lt_two ; use m ; aesop;
  -- By periodicity, $2^m + q$ must also be a power of two.
  obtain ⟨ j, hj ⟩ : ∃ j : ℕ, 2^m + q = 2^j := by
    exact h _ hm₁.le |>.1 ⟨ m, rfl ⟩;
  -- Since $q < 2^m$, we have $2^m < 2^j < 2^{m+1}$.
  have h_bounds : 2^m < 2^j ∧ 2^j < 2^(m+1) := by
    grind +splitImp;
  rw [ pow_lt_pow_iff_right₀, pow_lt_pow_iff_right₀ ] at h_bounds <;> linarith

/-
A concrete oscillating cutoff turns the eventually periodic singleton
spectrum into the non-eventually-periodic powers-of-two spectrum on all positive
indices.
-/
theorem powersOfTwo_pruning_counterexample {n : ℕ} (hn : 0 < n) :
    n ∈ ShiftedSpectrum ({0} : Set ℕ)
      (@adversarialCutoff PowersOfTwo (fun n => Classical.propDecidable (n ∈ PowersOfTwo))) ↔
      n ∈ PowersOfTwo := by
        convert adversarial_pruning_encodes_arbitrary_tail PowersOfTwo hn using 1

/-
**Concrete contrarian conclusion.**  There are an eventually periodic base
spectrum and a cutoff whose shifted spectrum is not eventually periodic.
-/
theorem exists_pruning_destroys_eventualPeriodicity :
    ∃ (S : Set ℕ) (f : ℕ → ℕ), EventuallyPeriodic S ∧
      ¬ EventuallyPeriodic (ShiftedSpectrum S f) := by
        -- Let's choose S = {0} and f as the adversarial cutoff for PowersOfTwo.
        use {0}, @adversarialCutoff PowersOfTwo (fun n => Classical.propDecidable (n ∈ PowersOfTwo));
        refine' ⟨ singleton_zero_eventuallyPeriodic, _ ⟩;
        intro h;
        apply powersOfTwo_not_eventuallyPeriodic;
        convert h.congr_tail _;
        exact ⟨ 1, fun n hn => powersOfTwo_pruning_counterexample hn ⟩

end ComponentPrunedLimitLaws