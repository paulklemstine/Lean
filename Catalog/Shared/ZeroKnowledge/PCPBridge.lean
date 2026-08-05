import Mathlib

/-!
# Bridge to probabilistically checkable proofs: 3-colorability as a 2-query PCP

The zero-knowledge protocol for graph 3-colorability is, stripped of its commitments,
exactly a *probabilistically checkable proof*: the proof string is a colouring
`f : V → Fin 3`, the verifier tosses `log₂ |E|` coins to pick an edge and reads only the
**two** proof symbols at its endpoints. This file makes that verifier and its parameters
precise and proves the completeness/soundness gap together with an exact parallel
repetition theorem.

## Main results

* `card_queries_le_two` — the verifier reads at most two proof symbols per test.
* `accepts_of_agree_on_queries` — *locality*: the verdict depends only on the queried
  symbols, so the verifier really is a 2-query oracle machine.
* `accProb_eq_one_iff` — perfect completeness, and its exact converse.
* `accProb_le_one_sub_inv` — the PCP gap: non-3-colorable instances are accepted with
  probability at most `1 - 1/|E|`.
* `prodAccept_card` — **exact parallel repetition**: the number of accepting `k`-tuples of
  tests is the `k`-th power of the number of accepting tests, hence
  `prodAccProb_eq_pow : (accepting k-tuples)/(all k-tuples) = accProb ^ k`.
* `prod_queries_card_le` and `prod_soundness_exp` — `k` repetitions use at most `2k`
  queries and drive the soundness error down to `exp (-k/|E|)`; taking `k = |E| · t`
  gives error `exp (-t)` (`prod_soundness_scaled`). This is the query-complexity /
  soundness trade-off underlying the PCP view of this verifier.
-/

open Finset

namespace ZKPCPBridge

variable {V : Type*}

/-! ## The two-query verifier -/

/-- `c` is a proper 3-colouring of the edge list `E`. -/
def IsProper (E : Finset (V × V)) (c : V → Fin 3) : Prop := ∀ e ∈ E, c e.1 ≠ c e.2

/-- The instance is a yes-instance of 3-colorability. -/
def ThreeColorable (E : Finset (V × V)) : Prop := ∃ c : V → Fin 3, IsProper E c

/-- The verdict of the verifier on the test `e` given the proof string `f`. -/
def Accepts (f : V → Fin 3) (e : V × V) : Prop := f e.1 ≠ f e.2

instance (f : V → Fin 3) (e : V × V) : Decidable (Accepts f e) := by
  unfold Accepts; infer_instance

/-- The proof positions queried by the test `e`. -/
def queries [DecidableEq V] (e : V × V) : Finset V := {e.1, e.2}

/-- The verifier is a **2-query** verifier. -/
theorem card_queries_le_two [DecidableEq V] (e : V × V) : (queries e).card ≤ 2 :=
  le_trans (card_insert_le _ _) (by simp)

/-- **Locality**: the verdict only depends on the two queried symbols. -/
theorem accepts_of_agree_on_queries [DecidableEq V] {f g : V → Fin 3} {e : V × V}
    (h : ∀ v ∈ queries e, f v = g v) : Accepts f e ↔ Accepts g e := by
  unfold Accepts
  rw [h e.1 (by simp [queries]), h e.2 (by simp [queries])]

/-- The number of tests the verifier accepts. -/
def accCard (E : Finset (V × V)) (f : V → Fin 3) : ℕ := (E.filter (Accepts f)).card

/-- The acceptance probability of the verifier, over a uniformly random test. -/
noncomputable def accProb (E : Finset (V × V)) (f : V → Fin 3) : ℝ :=
  (accCard E f : ℝ) / E.card

theorem accCard_le (E : Finset (V × V)) (f : V → Fin 3) : accCard E f ≤ E.card :=
  card_le_card (filter_subset _ _)

theorem accProb_nonneg (E : Finset (V × V)) (f : V → Fin 3) : 0 ≤ accProb E f := by
  unfold accProb; positivity

theorem accProb_le_one (E : Finset (V × V)) (f : V → Fin 3) : accProb E f ≤ 1 := by
  unfold accProb
  rcases Nat.eq_zero_or_pos E.card with h | h
  · simp [h]
  · rw [div_le_one (by exact_mod_cast h)]
    exact_mod_cast accCard_le E f

/-- The verifier accepts *every* test exactly on proper colourings. -/
theorem accCard_eq_iff (E : Finset (V × V)) (f : V → Fin 3) :
    accCard E f = E.card ↔ IsProper E f := by
  constructor
  · intro h
    have hself : E.filter (Accepts f) = E :=
      eq_of_subset_of_card_le (filter_subset _ _) (le_of_eq h.symm)
    intro e he
    exact (filter_eq_self.mp hself) e he
  · intro h
    have hself : E.filter (Accepts f) = E := filter_true_of_mem fun e he => h e he
    rw [accCard, hself]

/-- **Perfect completeness**, together with its exact converse: the verifier accepts with
probability `1` precisely on proper colourings. -/
theorem accProb_eq_one_iff {E : Finset (V × V)} (hE : E.Nonempty) (f : V → Fin 3) :
    accProb E f = 1 ↔ IsProper E f := by
  have hm : (E.card : ℝ) ≠ 0 := by
    have : 0 < E.card := card_pos.mpr hE
    positivity
  rw [accProb, div_eq_one_iff_eq hm, ← accCard_eq_iff E f]
  exact_mod_cast Iff.rfl

/-- **The PCP gap**: on a non-3-colorable instance every proof string is rejected with
probability at least `1/|E|`. -/
theorem accProb_le_one_sub_inv [DecidableEq V] {E : Finset (V × V)} (hE : E.Nonempty)
    (h : ¬ ThreeColorable E) (f : V → Fin 3) : accProb E f ≤ 1 - 1 / E.card := by
  have hbad : ∃ e ∈ E, ¬ Accepts f e := by
    by_contra hcon
    push_neg at hcon
    exact h ⟨f, fun e he => hcon e he⟩
  obtain ⟨e₀, he₀, hbad⟩ := hbad
  have hsub : E.filter (Accepts f) ⊆ E.erase e₀ := by
    intro e he
    rw [mem_filter] at he
    exact mem_erase.mpr ⟨by rintro rfl; exact hbad he.2, he.1⟩
  have hcard : accCard E f + 1 ≤ E.card := by
    have h1 : accCard E f ≤ (E.erase e₀).card := card_le_card hsub
    have h2 : (E.erase e₀).card = E.card - 1 := card_erase_of_mem he₀
    have h3 : 1 ≤ E.card := card_pos.mpr hE
    omega
  have hm : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  have h1 : (accCard E f : ℝ) ≤ (E.card : ℝ) - 1 := by
    have := (Nat.cast_le (α := ℝ)).mpr hcard
    push_cast at this
    linarith
  rw [accProb, div_le_iff₀ hm]
  have hmul : (1 - 1 / (E.card : ℝ)) * E.card = (E.card : ℝ) - 1 := by field_simp
  rw [hmul]
  exact h1

/-! ## Exact parallel repetition -/

/-- The test space of the `k`-fold parallel repetition: `k` independent edges. -/
def prodTests [DecidableEq V] (E : Finset (V × V)) (k : ℕ) : Finset (Fin k → V × V) :=
  Fintype.piFinset fun _ => E

/-- The `k`-fold repeated verifier accepts iff all `k` tests accept. -/
def ProdAccepts (k : ℕ) (f : V → Fin 3) (v : Fin k → V × V) : Prop := ∀ i, Accepts f (v i)

instance (k : ℕ) (f : V → Fin 3) (v : Fin k → V × V) : Decidable (ProdAccepts k f v) := by
  unfold ProdAccepts; infer_instance

theorem prodTests_card [DecidableEq V] (E : Finset (V × V)) (k : ℕ) :
    (prodTests E k).card = E.card ^ k := by
  rw [prodTests, Fintype.card_piFinset]
  simp

/-- **Exact parallel repetition**: the accepting `k`-tuples are exactly the `k`-tuples of
accepting tests, so their number is `accCard ^ k`. -/
theorem prodAccept_card [DecidableEq V] (E : Finset (V × V)) (f : V → Fin 3) (k : ℕ) :
    ((prodTests E k).filter (ProdAccepts k f)).card = (accCard E f) ^ k := by
  have hset : (prodTests E k).filter (ProdAccepts k f)
      = Fintype.piFinset fun _ : Fin k => E.filter (Accepts f) := by
    ext v
    simp [prodTests, ProdAccepts, Fintype.mem_piFinset, mem_filter, forall_and]
  rw [hset, Fintype.card_piFinset]
  simp [accCard]

/-- The acceptance probability of the `k`-fold repetition is the `k`-th power of the
single-round acceptance probability. -/
theorem prodAccProb_eq_pow [DecidableEq V] (E : Finset (V × V)) (f : V → Fin 3) (k : ℕ) :
    ((((prodTests E k).filter (ProdAccepts k f)).card : ℝ) / (prodTests E k).card)
      = accProb E f ^ k := by
  rw [prodAccept_card, prodTests_card, accProb, div_pow]
  push_cast
  ring

/-- The repeated verifier makes at most `2k` queries. -/
theorem prod_queries_card_le [DecidableEq V] (k : ℕ) (v : Fin k → V × V) :
    (univ.biUnion fun i => queries (v i)).card ≤ 2 * k := by
  refine le_trans (card_biUnion_le) ?_
  calc ∑ i : Fin k, (queries (v i)).card ≤ ∑ _i : Fin k, 2 :=
        Finset.sum_le_sum fun i _ => card_queries_le_two (v i)
    _ = 2 * k := by simp [mul_comm]

/-- **Soundness of the repeated PCP verifier**: on a non-3-colorable instance the
acceptance probability after `k` repetitions is at most `exp (-k/|E|)`, while the query
complexity is only `2k`. -/
theorem prod_soundness_exp [DecidableEq V] {E : Finset (V × V)} (hE : E.Nonempty)
    (h : ¬ ThreeColorable E) (f : V → Fin 3) (k : ℕ) :
    accProb E f ^ k ≤ Real.exp (-(k / E.card)) := by
  have hm : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  have hle : (1 : ℝ) / E.card ≤ 1 := by
    rw [div_le_one hm]
    exact_mod_cast card_pos.mpr hE
  have hgap : accProb E f ≤ 1 - 1 / E.card := accProb_le_one_sub_inv hE h f
  have hnn : (0 : ℝ) ≤ accProb E f := accProb_nonneg E f
  have hstep : 1 - 1 / (E.card : ℝ) ≤ Real.exp (-(1 / E.card)) := by
    have := Real.add_one_le_exp (-(1 / (E.card : ℝ)))
    linarith
  have hchain : accProb E f ≤ Real.exp (-(1 / E.card)) := le_trans hgap hstep
  calc accProb E f ^ k ≤ (Real.exp (-(1 / E.card))) ^ k := by gcongr
    _ = Real.exp (-(k / E.card)) := by
        rw [← Real.exp_nat_mul]
        congr 1
        field_simp

/-- Choosing `k = |E| · t` repetitions yields soundness error `exp (-t)` using `2|E|t`
queries. -/
theorem prod_soundness_scaled [DecidableEq V] {E : Finset (V × V)} (hE : E.Nonempty)
    (h : ¬ ThreeColorable E) (f : V → Fin 3) (t : ℕ) :
    accProb E f ^ (E.card * t) ≤ Real.exp (-(t : ℝ)) := by
  have hm : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  have hk := prod_soundness_exp hE h f (E.card * t)
  have hcast : ((E.card * t : ℕ) : ℝ) / E.card = (t : ℝ) := by
    push_cast
    field_simp
  rwa [hcast] at hk

/-- Conversely, a proof string accepted by the `k`-fold repeated verifier with probability
larger than `exp (-k/|E|)` certifies that the instance is a yes-instance. -/
theorem threeColorable_of_prodAccProb_gt [DecidableEq V] {E : Finset (V × V)}
    (hE : E.Nonempty) (f : V → Fin 3) (k : ℕ)
    (hf : Real.exp (-(k / E.card)) < accProb E f ^ k) : ThreeColorable E := by
  by_contra h
  exact absurd (prod_soundness_exp hE h f k) (not_le.mpr hf)

end ZKPCPBridge