import Computation.ReversibleSortingBennett

/-!
# Sorting multisets: the multinomial refinement of the factorial erasure ledger

The catalog's reversible-sorting thread (`Computation.ReversibleSortingBennett`) measures the
information erased by sorting `n` **distinct** items by `log₂ (n!)`: the sorting map collapses
the whole symmetric group to a point, so `n!` inputs become one output.

This file carries out the promised generalisation to **multisets with repeated keys**.  An input
is now a *key word* `w : α → ι` (each of the `n = |α|` slots carries a key), and two inputs are
distinguishable exactly when they are different rearrangements of the same key multiset.  The
number of distinguishable inputs is therefore the size of the orbit of `w` under the symmetric
group `Perm α`, and the main theorem identifies it with the **multinomial coefficient**

  `|orbit| = n! / ∏ᵢ mᵢ!`,  where `mᵢ = |w⁻¹(i)|`.

## Main results

* `card_rearrangements_mul_prod_factorial` : the division-free orbit–stabiliser identity
  `|rearrangements w| · ∏ᵢ mᵢ! = n!`.
* `card_rearrangements` : `|rearrangements w| = Nat.multinomial univ (keyMult w)`.
* `infoErased_multisetSorting` : the erased information of multiset sorting is
  `log₂ (n! / ∏ mᵢ!)`, the logarithm of the multinomial coefficient.
* `infoErased_conservation` : the exact ledger
  `log₂ (n!) = infoErased (multiset sorting) + ∑ᵢ log₂ (mᵢ!)`  —
  the distinct-key baseline splits into the multiset erasure plus the erasure of the
  intra-block orders, which a multiset sorter never has to touch.
* `landauerGap_multisetSorting` / `landauer_conservation` : the same ledger in Landauer work,
  and `landauerGap_multiset_le_baseline` / `landauerGap_multiset_lt_baseline` : the multiset
  task is never more expensive than the distinct-key task, and is *strictly* cheaper as soon
  as one key is repeated.
* `card_rearrangements_of_injective` / `infoErased_multisetSorting_of_injective` : distinct keys
  recover the catalog's factorial baseline exactly.
* `rearrangements_of_constant` / `infoErased_multisetSorting_of_constant` : a single repeated key
  erases nothing at all.
* `MultisetSorter.clog_le_depth`, `exists_multisetSorter_clog_depth`,
  `multisetSorter_work_lower_bound` : the radix-`q` decision-tree bound
  `d ≥ ⌈log_q (n!/∏ mᵢ!)⌉`, its tightness, and the corresponding physical work bound.
* `multiset_history_lower_bound` : every reversible implementation must retain at least
  `n!/∏ mᵢ!` history states.
-/

open Finset Nat

namespace MultisetSorting

variable {α ι : Type*} [Fintype α] [DecidableEq α] [Fintype ι] [DecidableEq ι]

/-! ## The combinatorial model -/

/-- The multiplicity `mᵢ` of the key `i` in the key word `w`. -/
def keyMult (w : α → ι) (i : ι) : ℕ := Fintype.card {a // w a = i}

/-- The set of **distinguishable inputs**: all rearrangements `w ∘ σ` of the key word `w`.
Two labellings of the slots by keys are the same input iff they agree as functions, so this
finset is exactly the orbit of `w` under the natural action of the symmetric group. -/
def rearrangements (w : α → ι) : Finset (α → ι) :=
  Finset.image (fun σ : Equiv.Perm α => w ∘ σ) Finset.univ

/-- The type of distinguishable inputs of the key word `w`. -/
abbrev Input (w : α → ι) := {v : α → ι // v ∈ rearrangements w}

/-- Sorting a multiset collapses every rearrangement to the same sorted output. -/
def multisetSortingFunction (w : α → ι) : Input w → Unit := fun _ => ()

omit [Fintype ι] in
theorem self_mem_rearrangements (w : α → ι) : w ∈ rearrangements w := by
  refine Finset.mem_image.mpr ⟨1, Finset.mem_univ _, ?_⟩
  ext a; rfl

instance (w : α → ι) : Nonempty (Input w) := ⟨⟨w, self_mem_rearrangements w⟩⟩

omit [Fintype ι] in
theorem card_rearrangements_pos (w : α → ι) : 0 < (rearrangements w).card :=
  Finset.card_pos.mpr ⟨w, self_mem_rearrangements w⟩

omit [DecidableEq α] in
/-- The multiplicities of a key word sum to the number of slots. -/
theorem sum_keyMult (w : α → ι) : ∑ i, keyMult w i = Fintype.card α := by
  simp only [keyMult]
  rw [← Fintype.card_sigma]
  exact Fintype.card_congr (Equiv.sigmaFiberEquiv w)

/-! ## Orbit–stabiliser: the multinomial count -/

/-- **Stabiliser count.**  The permutations that fix the key word pointwise form the Young
subgroup `∏ᵢ S_{mᵢ}`, of order `∏ᵢ mᵢ!`. -/
theorem card_stabilizer (w : α → ι) :
    (Finset.univ.filter (fun σ : Equiv.Perm α => w ∘ σ = w)).card = ∏ i, (keyMult w i)! := by
  have h := DomMulAct.stabilizer_card (α := α) (ι := ι) (f := w)
  simp only [keyMult]
  rw [← h, Fintype.card_subtype]

omit [Fintype ι] in
/-- All fibres of `σ ↦ w ∘ σ` are cosets of the stabiliser, hence equinumerous with it. -/
theorem card_fiber_eq_card_stabilizer (w : α → ι) (τ : Equiv.Perm α) :
    (Finset.univ.filter (fun σ : Equiv.Perm α => w ∘ σ = w ∘ τ)).card
      = (Finset.univ.filter (fun σ : Equiv.Perm α => w ∘ σ = w)).card := by
  apply Finset.card_nbij' (fun σ => σ * τ⁻¹) (fun σ => σ * τ)
  · intro σ hσ
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at *
    ext a
    simp only [Function.comp_apply, Equiv.Perm.mul_apply]
    simpa using congrFun hσ (τ⁻¹ a)
  · intro σ hσ
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at *
    ext a
    simp only [Function.comp_apply, Equiv.Perm.mul_apply]
    exact congrFun hσ (τ a)
  · intro σ _; simp
  · intro σ _; simp

/-- **Orbit–stabiliser for key words (division-free form).**  The number of distinguishable
rearrangements times the order `∏ᵢ mᵢ!` of the Young subgroup equals `n!`. -/
theorem card_rearrangements_mul_prod_factorial (w : α → ι) :
    (rearrangements w).card * ∏ i, (keyMult w i)! = (Fintype.card α)! := by
  have hperm : Fintype.card (Equiv.Perm α) = (Fintype.card α)! := by simp [Fintype.card_perm]
  have key := Finset.card_eq_sum_card_image (fun σ : Equiv.Perm α => w ∘ σ) Finset.univ
  rw [Finset.card_univ, hperm] at key
  have hre : Finset.image (fun σ : Equiv.Perm α => w ∘ ⇑σ) Finset.univ = rearrangements w := rfl
  rw [hre] at key
  have hcst : ∀ v ∈ rearrangements w,
      (Finset.univ.filter (fun σ : Equiv.Perm α => w ∘ σ = v)).card = ∏ i, (keyMult w i)! := by
    intro v hv
    simp only [rearrangements, Finset.mem_image, Finset.mem_univ, true_and] at hv
    obtain ⟨τ, rfl⟩ := hv
    rw [card_fiber_eq_card_stabilizer w τ, card_stabilizer]
  rw [key, Finset.sum_congr rfl hcst, Finset.sum_const, smul_eq_mul]

/-- **The expected number of distinguishable inputs is the multinomial coefficient.** -/
theorem card_rearrangements (w : α → ι) :
    (rearrangements w).card = Nat.multinomial Finset.univ (keyMult w) := by
  have hs := Nat.multinomial_spec (Finset.univ : Finset ι) (keyMult w)
  rw [sum_keyMult] at hs
  have hpos : 0 < ∏ i, (keyMult w i)! := Finset.prod_pos fun i _ => Nat.factorial_pos _
  refine Nat.eq_of_mul_eq_mul_right hpos ?_
  rw [card_rearrangements_mul_prod_factorial, mul_comm (Nat.multinomial _ _), hs]

theorem card_input (w : α → ι) :
    Fintype.card (Input w) = Nat.multinomial Finset.univ (keyMult w) := by
  rw [Fintype.card_coe, card_rearrangements]

/-! ## Erased information -/

omit [Fintype ι] in
/-- The image of the multiset sorting map is a single point. -/
theorem image_multisetSortingFunction (w : α → ι) :
    Finset.image (multisetSortingFunction w) Finset.univ = {()} := by
  refine Finset.eq_singleton_iff_unique_mem.mpr ⟨?_, ?_⟩
  · exact Finset.mem_image.mpr
      ⟨⟨w, self_mem_rearrangements w⟩, Finset.mem_univ _, rfl⟩
  · intro x _; rfl

/-- **The erased information of multiset sorting is the logarithm of the multinomial
coefficient.**  This is the promised generalisation of `sorting_info_erased`. -/
theorem infoErased_multisetSorting (w : α → ι) :
    infoErased (multisetSortingFunction w)
      = Real.logb 2 (Nat.multinomial Finset.univ (keyMult w)) := by
  unfold infoErased
  rw [image_multisetSortingFunction, card_input]
  simp

/-- **Conservation of the erasure ledger.**  The distinct-key baseline `log₂ (n!)` splits
exactly into the multiset erasure plus the intra-block erasures `log₂ (mᵢ!)`.  Sorting a
multiset is cheaper than sorting distinct items by precisely the information contained in the
orders *inside* the blocks of equal keys. -/
theorem infoErased_conservation (w : α → ι) :
    Real.logb 2 ((Fintype.card α)!)
      = infoErased (multisetSortingFunction w) + ∑ i, Real.logb 2 ((keyMult w i)!) := by
  have hcast : ((Nat.multinomial Finset.univ (keyMult w) : ℕ) : ℝ) * ∏ i, ((keyMult w i)! : ℝ)
      = ((Fintype.card α)! : ℝ) := by
    have := card_rearrangements_mul_prod_factorial w
    rw [card_rearrangements] at this
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) this
  have hM : (0:ℝ) < (Nat.multinomial Finset.univ (keyMult w) : ℕ) := by
    exact_mod_cast Nat.multinomial_pos _ _
  have hP : (0:ℝ) < ∏ i, ((keyMult w i)! : ℝ) :=
    Finset.prod_pos fun i _ => by exact_mod_cast Nat.factorial_pos _
  rw [infoErased_multisetSorting, ← hcast, Real.logb_mul (ne_of_gt hM) (ne_of_gt hP)]
  congr 1
  rw [Real.logb, Real.log_prod (fun i (_ : i ∈ Finset.univ) => by positivity)]
  simp [Real.logb, Finset.sum_div]

/-! ## Landauer work -/

/-- The Landauer work of multiset sorting is `kT · log (n!/∏ mᵢ!)`. -/
theorem landauerGap_multisetSorting (w : α → ι) (kT : ℝ) :
    landauerGap (multisetSortingFunction w) kT
      = kT * Real.log (Nat.multinomial Finset.univ (keyMult w)) := by
  unfold landauerGap landauerCost
  rw [infoErased_multisetSorting, Real.logb]
  have h2 : Real.log 2 ≠ 0 := by
    simpa using Real.log_ne_zero_of_pos_of_ne_one (by norm_num : (0:ℝ) < 2) (by norm_num)
  field_simp

/-- **Landauer conservation.**  `kT log (n!)` is the multiset work plus the intra-block works. -/
theorem landauer_conservation (w : α → ι) (kT : ℝ) :
    kT * Real.log ((Fintype.card α)!)
      = landauerGap (multisetSortingFunction w) kT + ∑ i, kT * Real.log ((keyMult w i)!) := by
  have hcast : ((Nat.multinomial Finset.univ (keyMult w) : ℕ) : ℝ) * ∏ i, ((keyMult w i)! : ℝ)
      = ((Fintype.card α)! : ℝ) := by
    have := card_rearrangements_mul_prod_factorial w
    rw [card_rearrangements] at this
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) this
  have hM : (0:ℝ) < (Nat.multinomial Finset.univ (keyMult w) : ℕ) := by
    exact_mod_cast Nat.multinomial_pos _ _
  have hP : (0:ℝ) < ∏ i, ((keyMult w i)! : ℝ) :=
    Finset.prod_pos fun i _ => by exact_mod_cast Nat.factorial_pos _
  rw [landauerGap_multisetSorting, ← hcast, Real.log_mul (ne_of_gt hM) (ne_of_gt hP),
    Real.log_prod (fun i (_ : i ∈ Finset.univ) => by positivity), mul_add, Finset.mul_sum]

/-! ## The two degenerate regimes -/

/-- With pairwise distinct keys every permutation is distinguishable: the orbit is all of `Sₙ`. -/
theorem card_rearrangements_of_injective {w : α → ι} (hw : Function.Injective w) :
    (rearrangements w).card = (Fintype.card α)! := by
  have hone : ∀ i, (keyMult w i)! = 1 := by
    intro i
    have : keyMult w i ≤ 1 := by
      simp only [keyMult]
      refine Fintype.card_le_one_iff.mpr ?_
      rintro ⟨a, ha⟩ ⟨b, hb⟩
      exact Subtype.ext (hw (ha.trans hb.symm))
    interval_cases h : keyMult w i <;> simp [Nat.factorial]
  have := card_rearrangements_mul_prod_factorial w
  simpa [hone] using this

/-- Distinct keys recover the catalog's factorial baseline for the erased information. -/
theorem infoErased_multisetSorting_of_injective {w : α → ι} (hw : Function.Injective w) :
    infoErased (multisetSortingFunction w) = Real.logb 2 ((Fintype.card α)!) := by
  rw [infoErased_multisetSorting, ← card_rearrangements, card_rearrangements_of_injective hw]

omit [Fintype ι] in
/-- A key word all of whose entries agree has a single rearrangement. -/
theorem rearrangements_of_constant {w : α → ι} (hw : ∀ a b : α, w a = w b) :
    rearrangements w = {w} := by
  refine Finset.eq_singleton_iff_unique_mem.mpr ⟨self_mem_rearrangements w, ?_⟩
  intro v hv
  simp only [rearrangements, Finset.mem_image, Finset.mem_univ, true_and] at hv
  obtain ⟨τ, rfl⟩ := hv
  ext a
  exact hw (τ a) a

/-- If all keys coincide, sorting erases nothing: the input was never distinguishable. -/
theorem infoErased_multisetSorting_of_constant {w : α → ι} (hw : ∀ a b : α, w a = w b) :
    infoErased (multisetSortingFunction w) = 0 := by
  rw [infoErased_multisetSorting, ← card_rearrangements, rearrangements_of_constant hw]
  simp

/-! ## The repetition discount is strict -/

/-- A repeated key strictly reduces the number of distinguishable inputs. -/
theorem card_rearrangements_lt_factorial {w : α → ι} {i₀ : ι} (h : 2 ≤ keyMult w i₀) :
    (rearrangements w).card < (Fintype.card α)! := by
  have hprod : 2 ≤ ∏ i, (keyMult w i)! := by
    calc (2:ℕ) = 2! := rfl
      _ ≤ (keyMult w i₀)! := Nat.factorial_le h
      _ ≤ ∏ i, (keyMult w i)! :=
          Finset.single_le_prod' (fun i _ => Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero _))
            (Finset.mem_univ i₀)
  have hpos := card_rearrangements_pos w
  have heq := card_rearrangements_mul_prod_factorial w
  nlinarith [heq, hprod, hpos]

/-- **Strict repetition discount.**  If some key occurs at least twice, multiset sorting erases
strictly less information than the distinct-key baseline `log₂ (n!)`. -/
theorem infoErased_multisetSorting_lt_baseline {w : α → ι} {i₀ : ι} (h : 2 ≤ keyMult w i₀) :
    infoErased (multisetSortingFunction w) < Real.logb 2 ((Fintype.card α)!) := by
  rw [infoErased_multisetSorting, ← card_rearrangements]
  have hlt : ((rearrangements w).card : ℝ) < ((Fintype.card α)! : ℝ) := by
    exact_mod_cast card_rearrangements_lt_factorial h
  have hpos : (0:ℝ) < ((rearrangements w).card : ℝ) := by
    exact_mod_cast card_rearrangements_pos w
  exact Real.logb_lt_logb (by norm_num) hpos hlt

/-- The multiset erasure never exceeds the distinct-key baseline. -/
theorem infoErased_multisetSorting_le_baseline (w : α → ι) :
    infoErased (multisetSortingFunction w) ≤ Real.logb 2 ((Fintype.card α)!) := by
  rw [infoErased_multisetSorting, ← card_rearrangements]
  have hle : ((rearrangements w).card : ℝ) ≤ ((Fintype.card α)! : ℝ) := by
    have : (rearrangements w).card ≤ (Fintype.card α)! := by
      have heq := card_rearrangements_mul_prod_factorial w
      have hprod : 1 ≤ ∏ i, (keyMult w i)! :=
        Nat.one_le_iff_ne_zero.mpr
          (Finset.prod_ne_zero_iff.mpr fun i _ => Nat.factorial_ne_zero _)
      nlinarith [heq, hprod]
    exact_mod_cast this
  have hpos : (0:ℝ) < ((rearrangements w).card : ℝ) := by
    exact_mod_cast card_rearrangements_pos w
  exact Real.logb_le_logb_of_le (by norm_num) hpos hle

/-- Landauer form of the discount: multiset sorting is never more expensive. -/
theorem landauerGap_multiset_le_baseline (w : α → ι) {kT : ℝ} (hkT : 0 ≤ kT) :
    landauerGap (multisetSortingFunction w) kT ≤ kT * Real.log ((Fintype.card α)!) := by
  have hcons := landauer_conservation w kT
  have hnn : 0 ≤ ∑ i, kT * Real.log ((keyMult w i)!) := by
    refine Finset.sum_nonneg fun i _ => mul_nonneg hkT (Real.log_nonneg ?_)
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero _)
  linarith

/-- Landauer form of the *strict* discount. -/
theorem landauerGap_multiset_lt_baseline {w : α → ι} {i₀ : ι} (h : 2 ≤ keyMult w i₀)
    {kT : ℝ} (hkT : 0 < kT) :
    landauerGap (multisetSortingFunction w) kT < kT * Real.log ((Fintype.card α)!) := by
  have hcons := landauer_conservation w kT
  have hpos : 0 < kT * Real.log ((keyMult w i₀)!) := by
    refine mul_pos hkT (Real.log_pos ?_)
    have h2 : 2 ≤ (keyMult w i₀)! := le_trans h (Nat.self_le_factorial _)
    have : (1:ℕ) < (keyMult w i₀)! := lt_of_lt_of_le (by norm_num) h2
    exact_mod_cast this
  have hnn : 0 ≤ ∑ i ∈ Finset.univ.erase i₀, kT * Real.log ((keyMult w i)!) := by
    refine Finset.sum_nonneg fun i _ => mul_nonneg hkT.le (Real.log_nonneg ?_)
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero _)
  have hsplit : ∑ i, kT * Real.log ((keyMult w i)!)
      = kT * Real.log ((keyMult w i₀)!) + ∑ i ∈ Finset.univ.erase i₀, kT * Real.log ((keyMult w i)!) :=
    (Finset.add_sum_erase _ _ (Finset.mem_univ i₀)).symm
  rw [hsplit] at hcons
  linarith

/-! ## Decision-tree and reversibility bounds for multiset sorting -/

/-- A **correct radix-`q`, depth-`d` multiset sorter**: it records the transcript of its `d`
queries and the distinguishable input is recoverable from the transcript. -/
structure MultisetSorter (w : α → ι) (q d : ℕ) where
  /-- The transcript produced on a given distinguishable input. -/
  transcript : Input w → (Fin d → Fin q)
  /-- Correctness: the transcript determines the rearrangement. -/
  correct : Function.Injective transcript

/-- **Counting bound.**  A correct radix-`q` multiset sorter of depth `d` forces
`n!/∏ mᵢ! ≤ q ^ d`. -/
theorem MultisetSorter.multinomial_le_pow {w : α → ι} {q d : ℕ} (S : MultisetSorter w q d) :
    Nat.multinomial Finset.univ (keyMult w) ≤ q ^ d := by
  have h := Fintype.card_le_of_injective _ S.correct
  rwa [card_input, Fintype.card_fun, Fintype.card_fin, Fintype.card_fin] at h

/-- **Multiset comparison lower bound.**  Every correct radix-`q ≥ 2` sorter of a multiset with
multiplicities `mᵢ` performs at least `⌈log_q (n!/∏ mᵢ!)⌉` queries. -/
theorem MultisetSorter.clog_le_depth {w : α → ι} {q d : ℕ} (hq : 1 < q)
    (S : MultisetSorter w q d) :
    Nat.clog q (Nat.multinomial Finset.univ (keyMult w)) ≤ d :=
  (Nat.clog_le_iff_le_pow hq).2 S.multinomial_le_pow

/-- **Tightness.**  The multinomial counting bound is achieved by an abstract sorter. -/
theorem exists_multisetSorter_clog_depth (w : α → ι) {q : ℕ} (hq : 1 < q) :
    Nonempty (MultisetSorter w q (Nat.clog q (Nat.multinomial Finset.univ (keyMult w)))) := by
  set d := Nat.clog q (Nat.multinomial Finset.univ (keyMult w)) with hd
  have hcard : Fintype.card (Input w) ≤ Fintype.card (Fin d → Fin q) := by
    rw [card_input, Fintype.card_fun, Fintype.card_fin, Fintype.card_fin]
    exact Nat.le_pow_clog hq _
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard
  exact ⟨⟨e, e.injective⟩⟩

/-- **Physical work bound for multiset sorting.**  Charging `kT log q` per fully erased query
register, a correct sorter's total charge is at least the multiset Landauer work
`kT log (n!/∏ mᵢ!)`. -/
theorem multisetSorter_work_lower_bound {w : α → ι} {q d : ℕ} (S : MultisetSorter w q d)
    {kT : ℝ} (hkT : 0 ≤ kT) :
    landauerGap (multisetSortingFunction w) kT ≤ (d : ℝ) * (kT * Real.log q) := by
  have hcast : ((Nat.multinomial Finset.univ (keyMult w) : ℕ) : ℝ) ≤ (q : ℝ) ^ d := by
    exact_mod_cast S.multinomial_le_pow
  have hpos : (0 : ℝ) < (Nat.multinomial Finset.univ (keyMult w) : ℕ) := by
    exact_mod_cast Nat.multinomial_pos _ _
  have hlog : Real.log (Nat.multinomial Finset.univ (keyMult w)) ≤ (d : ℝ) * Real.log q := by
    calc Real.log (Nat.multinomial Finset.univ (keyMult w))
        ≤ Real.log ((q : ℝ) ^ d) := Real.log_le_log hpos hcast
      _ = (d : ℝ) * Real.log q := Real.log_pow _ _
  rw [landauerGap_multisetSorting]
  nlinarith [hlog, hkT]

/-- **Reversible history bound.**  Any reversible implementation of multiset sorting must retain
at least `n!/∏ mᵢ!` history states — the multinomial refinement of
`sorting_history_lower_bound`. -/
theorem multiset_history_lower_bound (w : α → ι) (Aux : Type*) [Fintype Aux]
    (e : Input w ≃ Unit × Aux) :
    Nat.multinomial Finset.univ (keyMult w) ≤ Fintype.card Aux := by
  have : Fintype.card (Input w) ≤ Fintype.card Aux := by
    refine Fintype.card_le_of_injective (fun v => (e v).2) ?_
    intro v₁ v₂ h
    exact e.injective (Prod.ext rfl h)
  rwa [card_input] at this

end MultisetSorting