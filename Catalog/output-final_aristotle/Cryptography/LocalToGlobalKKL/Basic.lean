import Mathlib

/-!
# A Local-to-Global KKL Theorem for Influence Functions

This file develops a *local-to-global* principle for coordinate influences, in the
spirit of the Kahn–Kalai–Linial (KKL) theorem and the high-dimensional-expander
"local-to-global" machinery (Kahn–Kalai–Linial 1988; Bafna–Hoory–Kaufman 2022;
Gur–Lifshitz–Liu 2022; Gotlib–Kaufman 2023).

The KKL theorem is a *local* statement about a single Boolean function: any
non-degenerate low-influence function must have a coordinate of large influence.
The **local-to-global** paradigm asks: if the *links* of a simplicial complex each
satisfy a KKL-type property, does the whole complex satisfy a global KKL-type
property?  The engine that makes this work is that **influences self-average over
links**: the global influence of a coordinate is a (weighted) average of its
influences in the links.

We formalise two layers.

## Concrete model: the Boolean cube and its codimension-one links

For `f : (Fin n → Bool) → Bool` we define the (unnormalised) coordinate influence
`Inf f i` as the number of edges of the hypercube in direction `i` on which `f`
changes value.  Fixing a coordinate `j` and a value `b` cuts the cube into a
subcube — the *link* of the vertex `(j, b)` — and `InfSub f j b i` counts the
sensitive `i`-edges inside that subcube.  The key structural fact
(`inf_decomp`) is that

  `Inf f i = InfSub f j false i + InfSub f j true i`,

i.e. every influence splits as the sum of the influences in the two links.
Summing over coordinates gives the local-to-global decomposition
`linktot_decomp`, and combined with pigeonholing we obtain the flagship
concrete statement `localToGlobal_KKL_cube`: if both links of `j` carry total
influence `≥ T`, then some global coordinate has influence `≥ 2T/(n-1)`.

## Abstract engine: local KKL ⟹ global KKL

`abstract_localToGlobal_KKL` isolates the general averaging argument for an
arbitrary weighted family of links: given the self-averaging *bridge*
`I i = ∑ ℓ, w ℓ * Iℓ ℓ i` and the *local KKL hypothesis* that every link has an
influential coordinate (`∃ i, τ ≤ Iℓ ℓ i`), the global total influence is at
least `τ · (∑ ℓ w ℓ)`, and consequently (`abstract_global_influential_coord`)
some global coordinate has influence at least the average `τ·(∑ w)/|ι|`.

Finally `cube_total_via_abstract` shows the concrete Boolean-cube decomposition is
literally an instance of the abstract engine (two links of weight one).
-/

namespace LocalToGlobalKKL

open Finset

/-! ## Concrete model: the Boolean hypercube -/

section Cube

variable {n : ℕ}

/-- Flip the `i`-th coordinate of a point of the Boolean cube. -/
def flipc (x : Fin n → Bool) (i : Fin n) : Fin n → Bool :=
  Function.update x i (!x i)

@[simp] lemma flipc_involutive (x : Fin n → Bool) (i : Fin n) :
    flipc (flipc x i) i = x := by
  funext k
  by_cases hk : k = i
  · subst hk; simp [flipc]
  · simp [flipc, Function.update_of_ne hk]

/-- Flipping coordinate `i` does not change coordinate `j` when `j ≠ i`.  In
particular a sensitive `i`-edge stays inside a single `j`-link. -/
lemma flipc_apply_ne (x : Fin n → Bool) {i j : Fin n} (h : j ≠ i) :
    flipc x i j = x j := by
  simp [flipc, Function.update_of_ne h]

/-- The (unnormalised) influence of coordinate `i` on `f`: the number of cube
edges in direction `i` whose endpoints receive different `f`-values. -/
def Inf (f : (Fin n → Bool) → Bool) (i : Fin n) : ℕ :=
  (univ.filter (fun x => f x ≠ f (flipc x i))).card

/-- The influence of coordinate `i` on `f` restricted to the link `{x : x j = b}`
(the codimension-one subcube where coordinate `j` is pinned to `b`). -/
def InfSub (f : (Fin n → Bool) → Bool) (j : Fin n) (b : Bool) (i : Fin n) : ℕ :=
  (univ.filter (fun x => x j = b ∧ f x ≠ f (flipc x i))).card

/-- The total influence of `f` (sum of all coordinate influences). -/
def TotInf (f : (Fin n → Bool) → Bool) : ℕ := ∑ i, Inf f i

/-- The total influence of `f` inside the link `{x : x j = b}`, summed over all
coordinates other than the pinned coordinate `j`. -/
def LinkTotInf (f : (Fin n → Bool) → Bool) (j : Fin n) (b : Bool) : ℕ :=
  ∑ i ∈ univ.erase j, InfSub f j b i

/-- **Influence self-averaging (the local-to-global bridge).**
Every coordinate influence splits as the sum of the two link influences.
This is the structural identity that powers the whole file. -/
theorem inf_decomp (f : (Fin n → Bool) → Bool) (j i : Fin n) :
    Inf f i = InfSub f j false i + InfSub f j true i := by
  unfold Inf InfSub
  rw [add_comm, ← Finset.card_filter_add_card_filter_not
      (s := univ.filter (fun x => f x ≠ f (flipc x i))) (p := fun x => x j = true)]
  rw [Finset.filter_filter, Finset.filter_filter]
  congr 1
  · congr 1; apply filter_congr; intro x _; simp [and_comm]
  · congr 1; apply filter_congr; intro x _; simp [and_comm, Bool.not_eq_true]

/-- Each link influence is bounded by the global influence. -/
lemma InfSub_le_Inf (f : (Fin n → Bool) → Bool) (j : Fin n) (b : Bool) (i : Fin n) :
    InfSub f j b i ≤ Inf f i := by
  rw [inf_decomp f j i]; cases b <;> simp

/-- **Local-to-global decomposition of total influence.**  Summing the bridge over
all coordinates other than the pinned coordinate `j`, the global total influence
(excluding `j`) equals the sum of the two links' total influences. -/
theorem linktot_decomp (f : (Fin n → Bool) → Bool) (j : Fin n) :
    ∑ i ∈ univ.erase j, Inf f i = LinkTotInf f j false + LinkTotInf f j true := by
  unfold LinkTotInf
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _; exact inf_decomp f j i

/-! ### Pigeonhole: some coordinate carries at least the average influence -/

/-- Over a finite set some element attains at least the average of a `ℕ`-valued
function. -/
lemma exists_ge_avg_nat {ι : Type*} (s : Finset ι) (g : ι → ℕ) (hs : s.Nonempty) :
    ∃ i ∈ s, ∑ j ∈ s, g j ≤ s.card * g i := by
  obtain ⟨i, hi, hmax⟩ := s.exists_max_image g hs
  refine ⟨i, hi, ?_⟩
  calc ∑ j ∈ s, g j ≤ ∑ _j ∈ s, g i := Finset.sum_le_sum (fun j hj => hmax j hj)
    _ = s.card * g i := by rw [Finset.sum_const, smul_eq_mul]

/-- **Flagship concrete local-to-global KKL theorem (Boolean cube).**

Fix a coordinate `j` of the `n`-cube (with `n ≥ 2`).  If both links of `j` carry
total influence at least `T` — the *local* KKL-type lower bound on each link —
then some *global* coordinate `i ≠ j` has influence at least the global average
`2T/(n-1)`, stated multiplicatively as `(n-1) * Inf f i ≥ 2T`.

Thus a lower bound on the influence content of each link is transferred to the
existence of a globally influential coordinate. -/
theorem localToGlobal_KKL_cube (f : (Fin n → Bool) → Bool) (j : Fin n)
    (hn : 2 ≤ n) (T : ℕ)
    (hfalse : T ≤ LinkTotInf f j false) (htrue : T ≤ LinkTotInf f j true) :
    ∃ i ∈ univ.erase j, 2 * T ≤ (n - 1) * Inf f i := by
  have hne : (univ.erase j : Finset (Fin n)).Nonempty := by
    rw [← Finset.card_pos, Finset.card_erase_of_mem (Finset.mem_univ j),
        Finset.card_univ, Fintype.card_fin]
    omega
  obtain ⟨i, hi, hle⟩ := exists_ge_avg_nat (univ.erase j) (Inf f) hne
  refine ⟨i, hi, ?_⟩
  have hcard : (univ.erase j : Finset (Fin n)).card = n - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ j), Finset.card_univ, Fintype.card_fin]
  have hsum : 2 * T ≤ ∑ i ∈ univ.erase j, Inf f i := by
    rw [linktot_decomp]; omega
  calc 2 * T ≤ ∑ i ∈ univ.erase j, Inf f i := hsum
    _ ≤ (univ.erase j).card * Inf f i := hle
    _ = (n - 1) * Inf f i := by rw [hcard]

/-- **Local influential coordinate ⟹ global influential coordinate.**
If some coordinate is influential inside a link, it is at least as influential
globally.  (A qualitative form of the local-to-global transfer, via monotonicity
of influence under passing to a link.) -/
theorem local_influential_implies_global (f : (Fin n → Bool) → Bool) (j : Fin n)
    (b : Bool) (τ : ℕ) (i : Fin n) (hi : τ ≤ InfSub f j b i) :
    τ ≤ Inf f i :=
  le_trans hi (InfSub_le_Inf f j b i)

end Cube

/-! ## Abstract engine: local KKL ⟹ global KKL -/

section Abstract

/-- **Abstract local-to-global KKL theorem.**

Consider a system of coordinates `ι`, a weighted family of links `κ` with
non-negative weights `w`, non-negative local influences `Iℓ`, and global
influences `I`.  Assume:

* the **bridge** (influence self-averaging):  `I i = ∑ ℓ, w ℓ * Iℓ ℓ i`;
* the **local KKL hypothesis**: every link `ℓ` has an influential coordinate,
  `∃ i, τ ≤ Iℓ ℓ i`  (the KKL conclusion, applied on each link).

Then the **global total influence** is at least `τ · (∑ ℓ w ℓ)`.  This is the
purely combinatorial heart of every local-to-global argument for influences. -/
theorem abstract_localToGlobal_KKL
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (I : ι → ℝ) (w : κ → ℝ) (Iℓ : κ → ι → ℝ) (τ : ℝ)
    (hw : ∀ l, 0 ≤ w l) (hIℓ : ∀ l i, 0 ≤ Iℓ l i)
    (bridge : ∀ i, I i = ∑ l, w l * Iℓ l i)
    (localKKL : ∀ l, ∃ i, τ ≤ Iℓ l i) :
    τ * (∑ l, w l) ≤ ∑ i, I i := by
  have step : ∑ i, I i = ∑ l, w l * (∑ i, Iℓ l i) := by
    simp_rw [bridge]; rw [Finset.sum_comm]; congr 1; ext l; rw [Finset.mul_sum]
  rw [step, Finset.mul_sum]
  apply Finset.sum_le_sum
  intro l _
  obtain ⟨i₀, hi₀⟩ := localKKL l
  have htot : τ ≤ ∑ i, Iℓ l i :=
    le_trans hi₀ (Finset.single_le_sum (fun i _ => hIℓ l i) (Finset.mem_univ i₀))
  rw [mul_comm τ (w l)]
  exact mul_le_mul_of_nonneg_left htot (hw l)

/-- Over a finite index type some element attains at least the average of a
real-valued function. -/
lemma exists_ge_avg_real {ι : Type*} [Fintype ι] [Nonempty ι] (g : ι → ℝ) :
    ∃ i, ∑ j, g j ≤ (Fintype.card ι : ℝ) * g i := by
  obtain ⟨i, _, hmax⟩ := (Finset.univ).exists_max_image g Finset.univ_nonempty
  refine ⟨i, ?_⟩
  calc ∑ j, g j ≤ ∑ _j : ι, g i := Finset.sum_le_sum (fun j _ => hmax j (Finset.mem_univ j))
    _ = (Fintype.card ι : ℝ) * g i := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **Abstract global influential coordinate.**
Under the hypotheses of `abstract_localToGlobal_KKL`, there is a global
coordinate whose influence is at least the global average `τ·(∑ w)/|ι|`
(stated multiplicatively). -/
theorem abstract_global_influential_coord
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ]
    (I : ι → ℝ) (w : κ → ℝ) (Iℓ : κ → ι → ℝ) (τ : ℝ)
    (hw : ∀ l, 0 ≤ w l) (hIℓ : ∀ l i, 0 ≤ Iℓ l i)
    (bridge : ∀ i, I i = ∑ l, w l * Iℓ l i)
    (localKKL : ∀ l, ∃ i, τ ≤ Iℓ l i) :
    ∃ i, τ * (∑ l, w l) ≤ (Fintype.card ι : ℝ) * I i := by
  obtain ⟨i, hi⟩ := exists_ge_avg_real I
  refine ⟨i, ?_⟩
  exact le_trans (abstract_localToGlobal_KKL I w Iℓ τ hw hIℓ bridge localKKL) hi

end Abstract

/-! ## The Boolean cube as an instance of the abstract engine -/

/-- **The concrete cube decomposition is an instance of the abstract engine.**
Taking the two links of `j` as a two-element family of unit weight recovers, via
`abstract_localToGlobal_KKL`, the total-influence lower bound: if each link of `j`
has an influential coordinate with influence `≥ T`, then the total influence of
`f` is at least `2T`. -/
theorem cube_total_via_abstract {n : ℕ} (f : (Fin n → Bool) → Bool) (j : Fin n)
    (T : ℕ)
    (hfalse : ∃ i, T ≤ InfSub f j false i) (htrue : ∃ i, T ≤ InfSub f j true i) :
    2 * T ≤ TotInf f := by
  -- Instantiate the abstract engine with `κ = Bool`, weights `1`, `τ = T`.
  have key : (T : ℝ) * (∑ _l : Bool, (1 : ℝ)) ≤ ∑ i, (Inf f i : ℝ) := by
    refine abstract_localToGlobal_KKL (ι := Fin n) (κ := Bool)
      (fun i => (Inf f i : ℝ)) (fun _ => (1 : ℝ))
      (fun b i => (InfSub f j b i : ℝ)) (T : ℝ)
      (fun _ => by norm_num) (fun _ _ => by positivity) ?_ ?_
    · intro i
      have := inf_decomp f j i
      rw [Fintype.sum_bool]
      push_cast [this]; ring
    · intro l
      cases l with
      | false =>
          obtain ⟨i, hi⟩ := hfalse
          exact ⟨i, by show (T : ℝ) ≤ (InfSub f j false i : ℝ); exact_mod_cast hi⟩
      | true =>
          obtain ⟨i, hi⟩ := htrue
          exact ⟨i, by show (T : ℝ) ≤ (InfSub f j true i : ℝ); exact_mod_cast hi⟩
  have hsum : (∑ i, (Inf f i : ℝ)) = (TotInf f : ℝ) := by
    unfold TotInf; push_cast; ring
  rw [Fintype.sum_bool, hsum] at key
  have h2 : ((2 * T : ℕ) : ℝ) ≤ (TotInf f : ℝ) := by push_cast; linarith
  exact_mod_cast h2

end LocalToGlobalKKL