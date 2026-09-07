/-
  # Classification of Evolutionary Futures

  Third research cycle.  `Shared.EvolutionaryPathUniversality` showed that the
  decomposition invariant is *injective* on the future of an object as soon as
  the system is separated.  Here we ask when it is *surjective* onto the
  sub-multisets of `decomp x`, i.e. when the future of `x` is classified
  completely by multiset containment.

  * `Saturated Q` — a label available one step later is already available now
    (`Q.step x l y → Q.step y l' z → ∃ w, Q.step x l' w`).
  * `chain_not_saturated` — saturation is **not** a consequence of the quotient
    system axioms: a two-step chain has `b ∈ decomp x` with no `b`-labelled step
    out of `x`.
  * `exists_step_of_mem_decomp` — under saturation every label of `decomp x` is
    available immediately.
  * `exists_reach_decomp_eq` — under saturation every `M ≤ decomp x` is realised
    by a stage reachable from `x`.
  * `classification_of_future` — under saturation *and* separation the future of
    `x` is in bijection with `{M // M ≤ decomp x}`:
    `∀ M ≤ decomp x, ∃! y, Reach Q x y ∧ decomp Q y = M`.

  Instantiated at `natSystem` this is the classical statement that the divisors
  of `n` correspond bijectively to the sub-multisets of the prime factorisation
  of `n` (`nat_divisor_classification`), and at `finsetSystem` that the sets
  reachable from `S` are exactly its subsets (`finset_subset_classification`).
-/
import Shared.EvolutionaryPathUniversality

namespace Shared.EvolutionaryPath

universe u v

variable {α : Type u} {Λ : Type v} {Q : QuotientSystem α Λ}

/-- A quotient system is **saturated** when any label that becomes available
after one step was already available before it. -/
def Saturated (Q : QuotientSystem α Λ) : Prop :=
  ∀ {x l y l' z}, Q.step x l y → Q.step y l' z → ∃ w, Q.step x l' w

/-! ### Saturation is an extra hypothesis, not a theorem -/

/-- The two-step chain `2 --false--> 1 --true--> 0`. -/
def chainStep : Fin 3 → Bool → Fin 3 → Prop := fun x l y =>
  (x = 2 ∧ l = false ∧ y = 1) ∨ (x = 1 ∧ l = true ∧ y = 0)

/-- The chain is a genuine quotient system (all diamonds are vacuous). -/
def chainSystem : QuotientSystem (Fin 3) Bool where
  step := chainStep
  rank := fun x => (x : ℕ)
  rank_lt := by
    rintro x l y (⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩) <;> decide
  label_unique := by
    rintro x l₁ l₂ y (⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩) h2 <;>
      rcases h2 with ⟨h, rfl, -⟩ | ⟨h, rfl, -⟩ <;>
        first
          | rfl
          | exact absurd h (by decide)
  exchange := by
    rintro x l₁ y₁ l₂ y₂ (⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩) h2 hne <;>
      rcases h2 with ⟨h, rfl, rfl⟩ | ⟨h, rfl, rfl⟩ <;>
        first
          | exact absurd rfl hne
          | exact absurd h (by decide)

@[simp] theorem chain_step_iff {x y : Fin 3} {l : Bool} :
    chainSystem.step x l y ↔ chainStep x l y := Iff.rfl

theorem chain_terminal_zero : Terminal chainSystem 0 := by
  intro l y h
  rcases (h : chainStep 0 l y) with ⟨hx, -⟩ | ⟨hx, -⟩ <;> exact absurd hx (by decide)

theorem chain_decomp_two : decomp chainSystem 2 = {false, true} := by
  have s₁ : chainSystem.step 2 false 1 := chain_step_iff.2 (Or.inl ⟨rfl, rfl, rfl⟩)
  have s₂ : chainSystem.step 1 true 0 := chain_step_iff.2 (Or.inr ⟨rfl, rfl, rfl⟩)
  rw [decomp_step s₁, decomp_step s₂,
    (terminal_iff_decomp_zero (Q := chainSystem) 0).1 chain_terminal_zero]
  rfl

/-- **Saturation is independent of the axioms.**  In the chain system the label
`true` belongs to `decomp 2` but no `true`-labelled step leaves `2`; so
availability of labels — and hence surjectivity of `decomp` onto sub-multisets —
really needs the extra hypothesis. -/
theorem chain_not_saturated :
    (true ∈ decomp chainSystem 2) ∧ (¬ ∃ w, chainSystem.step 2 true w) ∧
      ¬ Saturated chainSystem := by
  refine ⟨by rw [chain_decomp_two]; decide, ?_, ?_⟩
  · rintro ⟨w, hw⟩
    rcases (hw : chainStep 2 true w) with ⟨-, h, -⟩ | ⟨h, -, -⟩ <;> exact absurd h (by decide)
  · intro hsat
    obtain ⟨w, hw⟩ := hsat (chain_step_iff.2 (Or.inl ⟨rfl, rfl, rfl⟩))
      (chain_step_iff.2 (Or.inr ⟨rfl, rfl, rfl⟩))
    rcases (hw : chainStep 2 true w) with ⟨-, h, -⟩ | ⟨h, -, -⟩ <;> exact absurd h (by decide)

/-! ### Availability and surjectivity under saturation -/

/-- Under saturation, every label occurring in the label list of a path out of
`x` is available as an immediate step out of `x`. -/
theorem exists_step_of_mem_path (hsat : Saturated Q) {x t : α} {ls : List Λ}
    (h : EvolPath Q x t ls) : ∀ {l : Λ}, l ∈ ls → ∃ w, Q.step x l w := by
  induction h with
  | nil x => intro l hl; simp at hl
  | @cons x l₁ x₁ t ls hs hp ih =>
      intro l hl
      rcases List.mem_cons.1 hl with rfl | hl'
      · exact ⟨x₁, hs⟩
      · obtain ⟨v, hv⟩ := ih hl'
        exact hsat hs hv

/-- Under saturation, every label of the decomposition invariant of `x` is
available immediately. -/
theorem exists_step_of_mem_decomp (hsat : Saturated Q) {x : α} {l : Λ}
    (hl : l ∈ decomp Q x) : ∃ w, Q.step x l w := by
  obtain ⟨ls, hp, hm, -⟩ := path_normalForm Q x
  refine exists_step_of_mem_path hsat hp ?_
  rw [← hm] at hl
  exact Multiset.mem_coe.1 hl

/-- A strict sub-multiset can be reached by erasing one element. -/
theorem exists_mem_le_erase [DecidableEq Λ] {M N : Multiset Λ} (h : M ≤ N) (hne : M ≠ N) :
    ∃ l ∈ N, M ≤ N.erase l := by
  obtain ⟨K, rfl⟩ := Multiset.le_iff_exists_add.1 h
  have hK : K ≠ 0 := by
    rintro rfl
    exact hne (by simp)
  obtain ⟨l, hl⟩ := Multiset.exists_mem_of_ne_zero hK
  obtain ⟨K', rfl⟩ := Multiset.exists_cons_of_mem hl
  have hsplit : M + l ::ₘ K' = l ::ₘ (M + K') := by
    rw [← Multiset.singleton_add, ← Multiset.singleton_add, add_left_comm]
  refine ⟨l, ?_, ?_⟩
  · rw [hsplit]; exact Multiset.mem_cons_self _ _
  · rw [hsplit, Multiset.erase_cons_head]
    exact Multiset.le_add_right M K'

/-- **Surjectivity of the invariant on futures.**  In a saturated system every
sub-multiset of `decomp x` is the invariant of some stage reachable from `x`. -/
theorem exists_reach_decomp_eq (hsat : Saturated Q) :
    ∀ (n : ℕ) (x : α), height (Q := Q) x = n → ∀ M ≤ decomp Q x,
      ∃ y, Reach Q x y ∧ decomp Q y = M := by
  classical
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro x hx M hM
    by_cases hMx : M = decomp Q x
    · exact ⟨x, Reach.refl x, hMx.symm⟩
    · obtain ⟨l, hl, hle⟩ := exists_mem_le_erase hM hMx
      obtain ⟨w, hw⟩ := exists_step_of_mem_decomp hsat hl
      have hdw : decomp Q x = l ::ₘ decomp Q w := decomp_step hw
      have hew : (decomp Q x).erase l = decomp Q w := by
        rw [hdw, Multiset.erase_cons_head]
      have hheight : height (Q := Q) w < n := by
        have := height_step (Q := Q) hw
        omega
      obtain ⟨y, hy, hdy⟩ := ih (height (Q := Q) w) hheight w rfl M (hew ▸ hle)
      exact ⟨y, Reach.trans ⟨[l], EvolPath.cons hw (EvolPath.nil w)⟩ hy, hdy⟩

/-- **Classification of futures.**  In a separated, saturated quotient system
the stages reachable from `x` are in bijection with the sub-multisets of
`decomp x`, the bijection being `decomp` itself. -/
theorem classification_of_future (hsep : Separated Q) (hsat : Saturated Q) (x : α)
    {M : Multiset Λ} (hM : M ≤ decomp Q x) :
    ∃! y, Reach Q x y ∧ decomp Q y = M := by
  obtain ⟨y, hy, hdy⟩ := exists_reach_decomp_eq hsat _ x rfl M hM
  refine ⟨y, ⟨hy, hdy⟩, ?_⟩
  rintro z ⟨hz, hdz⟩
  exact decomp_injOn_reach hsep hz hy (hdz.trans hdy.symm)

/-- **Every ordering of the invariant is realised.**  In a saturated system, for
any list `ls` whose multiset is `decomp x` there is a complete evolutionary path
out of `x` using the labels in exactly that order.  (Combinatorial heart of the
multinomial count of complete paths.) -/
theorem exists_path_of_labels (hsat : Saturated Q) :
    ∀ (n : ℕ) (x : α) (ls : List Λ), height (Q := Q) x = n →
      (ls : Multiset Λ) = decomp Q x → EvolPath Q x (normalForm Q x) ls := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro x ls hx hls
    cases ls with
    | nil =>
        have hterm : Terminal Q x := (terminal_iff_decomp_zero x).2 (by simpa using hls.symm)
        have hnf : normalForm Q x = x := (decomp_eq_of_path (EvolPath.nil x) hterm).2
        rw [hnf]
        exact EvolPath.nil x
    | cons l ls' =>
        have hmem : l ∈ decomp Q x := by
          rw [← hls, ← Multiset.cons_coe]
          exact Multiset.mem_cons_self _ _
        obtain ⟨w, hw⟩ := exists_step_of_mem_decomp hsat hmem
        have hdw : decomp Q x = l ::ₘ decomp Q w := decomp_step hw
        have htail : (ls' : Multiset Λ) = decomp Q w := by
          have : l ::ₘ (ls' : Multiset Λ) = l ::ₘ decomp Q w := by
            rw [← hdw, Multiset.cons_coe, hls]
          exact (Multiset.cons_inj_right l).1 this
        have hheight : height (Q := Q) w < n := by
          have := height_step (Q := Q) hw
          omega
        have hpath := ih (height (Q := Q) w) hheight w ls' rfl htail
        rw [normalForm_step hw]
        exact EvolPath.cons hw hpath

/-- **Complete paths = permutations of the invariant.**  In a saturated system
the label lists of complete evolutionary paths out of `x` are exactly the lists
whose multiset is `decomp x`.  (Counting them therefore gives the multinomial
coefficient of `decomp x`.) -/
theorem complete_path_labels_iff (hsat : Saturated Q) (x : α) (ls : List Λ) :
    EvolPath Q x (normalForm Q x) ls ↔ (ls : Multiset Λ) = decomp Q x := by
  constructor
  · intro h
    exact ((decomp_eq_of_path h (terminal_normalForm Q x)).1).symm
  · intro h
    exact exists_path_of_labels hsat _ x ls rfl h

/-! ### The two classical instances -/

theorem natSystem_saturated : Saturated natSystem := by
  rintro n p m q k ⟨hp, -, rfl⟩ ⟨hq, hk, rfl⟩
  exact ⟨p * k, hq, Nat.mul_pos hp.pos hk, by ring⟩

theorem finsetSystem_saturated {ι : Type*} [DecidableEq ι] :
    Saturated (finsetSystem (ι := ι)) := by
  rintro S a T b U ⟨-, rfl⟩ ⟨hb, -⟩
  exact ⟨S.erase b, Finset.mem_of_mem_erase hb, rfl⟩

/-- **Divisor classification.**  For `n > 0` the divisors of `n` correspond
bijectively to the sub-multisets of the prime factorisation of `n`. -/
theorem nat_divisor_classification {n : ℕ} (hn : 0 < n) {M : Multiset ℕ}
    (hM : M ≤ (n.primeFactorsList : Multiset ℕ)) :
    ∃! m : ℕ, m ∣ n ∧ decomp natSystem m = M := by
  rw [← natDecomp_eq_primeFactorsList hn] at hM
  obtain ⟨y, ⟨hy, hdy⟩, huniq⟩ :=
    classification_of_future natSystem_separated natSystem_saturated n hM
  have hydvd : y ∣ n := natDvd_of_reach hy
  have hypos : 0 < y := Nat.pos_of_dvd_of_pos hydvd hn
  refine ⟨y, ⟨hydvd, hdy⟩, ?_⟩
  rintro m ⟨hmn, hdm⟩
  have hmpos : 0 < m := Nat.pos_of_dvd_of_pos hmn hn
  exact huniq m ⟨(natReach_iff_dvd hn hmpos).2 hmn, hdm⟩

/-- **Subset classification.**  The stages reachable from a finite set `S` are
exactly its subsets, each occurring once. -/
theorem finset_subset_classification {ι : Type*} [DecidableEq ι] (S : Finset ι)
    {M : Multiset ι} (hM : M ≤ S.val) :
    ∃! T : Finset ι, Reach finsetSystem S T ∧ T.val = M := by
  have hM' : M ≤ decomp finsetSystem S := by rwa [finsetDecomp]
  obtain ⟨T, ⟨hT, hdT⟩, huniq⟩ :=
    classification_of_future finsetSystem_separated finsetSystem_saturated S hM'
  rw [finsetDecomp] at hdT
  refine ⟨T, ⟨hT, hdT⟩, ?_⟩
  rintro U ⟨hU, hdU⟩
  exact huniq U ⟨hU, by rwa [finsetDecomp]⟩

/-- Every ordering of the prime factors of `n` is realised by a factorisation
path from `n` down to `1`. -/
theorem nat_every_ordering_realised {n : ℕ} (hn : 0 < n) (L : List ℕ)
    (hL : (L : Multiset ℕ) = (n.primeFactorsList : Multiset ℕ)) :
    EvolPath natSystem n 1 L := by
  have hd : (L : Multiset ℕ) = decomp natSystem n := by
    rw [hL, natDecomp_eq_primeFactorsList hn]
  have hpath := exists_path_of_labels natSystem_saturated _ n L rfl hd
  rwa [natNormalForm hn] at hpath

/-- The complete factorisation chains of `n` are exactly the orderings of its
prime factor list. -/
theorem nat_complete_path_iff {n : ℕ} (hn : 0 < n) (L : List ℕ) :
    EvolPath natSystem n 1 L ↔ (L : Multiset ℕ) = (n.primeFactorsList : Multiset ℕ) := by
  constructor
  · intro h
    rw [← natDecomp_eq_primeFactorsList hn]
    exact ((decomp_eq_of_path h terminal_one).1).symm
  · exact nat_every_ordering_realised hn L

end Shared.EvolutionaryPath