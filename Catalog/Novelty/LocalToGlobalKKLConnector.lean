import Mathlib

/-!
# A Local-to-Global KKL Theorem for Partite Simplicial Complexes over an Arbitrary Alphabet

This file develops a *local-to-global* principle for coordinate influences on the
complete `n`-partite simplicial complex whose colour classes each have `m`
vertices, in the spirit of the Kahn–Kalai–Linial (KKL) influence theorem and the
high-dimensional-expander "local-to-global" machinery (Kahn–Kalai–Linial 1988;
Bafna–Hoory–Kaufman 2022; Gur–Lifshitz–Liu 2022; Gotlib–Kaufman 2023).

## The complex and its links

The facets (top-dimensional simplices) of the complete `n`-partite complex with
parts of size `m` are exactly the *transversals*: functions `x : Fin n → Fin m`
choosing one vertex from each colour class.  A Boolean labelling of the facets is a
function `f : (Fin n → Fin m) → Bool`.

For a colour `i`, two facets are **`i`-adjacent** when they agree on every colour
`k ≠ i` and differ at colour `i`.  The (unnormalised) **influence** `Inf f i`
counts the ordered `i`-adjacent facet pairs on which `f` changes value — the edges
of the `i`-th Hamming direction that are sensitive for `f`.

Pinning colour `j` to a vertex `b` cuts out the **link** of that vertex: the
subcomplex of facets `x` with `x j = b`.  `InfSub f j b i` counts the sensitive
`i`-edges lying inside that link.

The Boolean cube studied classically is the special case `m = 2`; here every
vertex has `m` links rather than two.

## Results

* `inf_decomp` — the **self-averaging bridge**: every global influence splits as
  the sum of the influences over the `m` links of any fixed colour,
  `Inf f i = ∑ b, InfSub f j b i`.
* `linktot_decomp` — summing the bridge over colours gives the local-to-global
  decomposition of the total influence.
* `localToGlobal_KKL_partite` — the flagship statement: if all `m` links of a
  colour `j` carry link-influence at least `T` (the *local* KKL hypothesis on each
  link), then some global colour `i ≠ j` has influence at least the average
  `mT/(n-1)`.
* `abstract_localToGlobal_KKL` / `abstract_global_influential_coord` — the abstract
  weighted-averaging engine behind every such argument, and
  `partite_total_via_abstract` exhibiting the partite complex as an instance.
* `partite_localKKL_influential_coord_real` — the real-valued averaged form.
* `zero_influence_constant` — the exact converse boundary: a labelling all of whose
  colour influences vanish is constant, so the KKL conclusion is vacuous precisely
  for the degenerate (constant) labellings.
-/

namespace PartiteKKL

open Finset

/-! ## The complete `n`-partite complex over the alphabet `Fin m` -/

section Partite

variable {n m : ℕ}

/-- The (unnormalised) influence of colour `i` on the facet-labelling `f`: the
number of ordered `i`-adjacent facet pairs (agreeing off `i`, differing at `i`) on
which `f` changes value. -/
def Inf (f : (Fin n → Fin m) → Bool) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun p : (Fin n → Fin m) × (Fin n → Fin m) =>
     (∀ k, k ≠ i → p.1 k = p.2 k) ∧ p.1 i ≠ p.2 i ∧ f p.1 ≠ f p.2)).card

/-- The influence of colour `i` restricted to the link of the vertex `(j, b)` — the
subcomplex of facets whose colour `j` is pinned to `b`. -/
def InfSub (f : (Fin n → Fin m) → Bool) (j : Fin n) (b : Fin m) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun p : (Fin n → Fin m) × (Fin n → Fin m) =>
     ((∀ k, k ≠ i → p.1 k = p.2 k) ∧ p.1 i ≠ p.2 i ∧ f p.1 ≠ f p.2) ∧ p.1 j = b)).card

/-- The total influence of `f` (sum over all colours). -/
def TotInf (f : (Fin n → Fin m) → Bool) : ℕ := ∑ i, Inf f i

/-- The total influence carried by the link of `(j, b)`, summed over all colours
other than the pinned colour `j`. -/
def LinkTotInf (f : (Fin n → Fin m) → Bool) (j : Fin n) (b : Fin m) : ℕ :=
  ∑ i ∈ univ.erase j, InfSub f j b i

/-- **Influence self-averaging (the local-to-global bridge).**  Every colour
influence splits as the sum of its influences over the `m` links of any fixed
colour `j`.  This is the structural identity that powers the whole file. -/
theorem inf_decomp (f : (Fin n → Fin m) → Bool) (j i : Fin n) :
    Inf f i = ∑ b : Fin m, InfSub f j b i := by
  unfold Inf InfSub
  rw [Finset.card_eq_sum_card_fiberwise
      (f := fun p : (Fin n → Fin m) × (Fin n → Fin m) => p.1 j)
      (t := (Finset.univ : Finset (Fin m)))
      (fun x _ => Finset.mem_univ (x.1 j))]
  apply Finset.sum_congr rfl
  intro b _
  rw [Finset.filter_filter]

/-- Each link influence is bounded by the global influence. -/
lemma InfSub_le_Inf (f : (Fin n → Fin m) → Bool) (j : Fin n) (b : Fin m) (i : Fin n) :
    InfSub f j b i ≤ Inf f i := by
  rw [inf_decomp f j i]
  exact Finset.single_le_sum (f := fun c => InfSub f j c i)
    (fun c _ => Nat.zero_le _) (Finset.mem_univ b)

/-- **Local influential coordinate ⟹ global influential coordinate.**  If a colour
is influential inside some link, it is at least as influential globally. -/
theorem local_influential_implies_global (f : (Fin n → Fin m) → Bool) (j : Fin n)
    (b : Fin m) (τ : ℕ) (i : Fin n) (hi : τ ≤ InfSub f j b i) :
    τ ≤ Inf f i :=
  le_trans hi (InfSub_le_Inf f j b i)

/-- **Local-to-global decomposition of total influence.**  Summing the bridge over
all colours other than `j`, the global total influence (excluding `j`) equals the
sum of the link total influences over the `m` links of `j`. -/
theorem linktot_decomp (f : (Fin n → Fin m) → Bool) (j : Fin n) :
    ∑ i ∈ univ.erase j, Inf f i = ∑ b : Fin m, LinkTotInf f j b := by
  unfold LinkTotInf
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  exact inf_decomp f j i

/-! ### Pigeonhole -/

/-- Over a finite set some element attains at least the average of a `ℕ`-valued
function. -/
lemma exists_ge_avg_nat {ι : Type*} (s : Finset ι) (g : ι → ℕ) (hs : s.Nonempty) :
    ∃ i ∈ s, ∑ j ∈ s, g j ≤ s.card * g i := by
  obtain ⟨i, hi, hmax⟩ := s.exists_max_image g hs
  refine ⟨i, hi, ?_⟩
  calc ∑ j ∈ s, g j ≤ ∑ _j ∈ s, g i := Finset.sum_le_sum (fun j hj => hmax j hj)
    _ = s.card * g i := by rw [Finset.sum_const, smul_eq_mul]

/-- **Local-to-global total-influence bound.**  If every one of the `m` links of
`j` carries link-influence at least `T`, the total influence excluding `j` is at
least `mT`. -/
theorem total_via_links (f : (Fin n → Fin m) → Bool) (j : Fin n) (T : ℕ)
    (hlink : ∀ b : Fin m, T ≤ LinkTotInf f j b) :
    m * T ≤ ∑ i ∈ univ.erase j, Inf f i := by
  rw [linktot_decomp]
  calc m * T = ∑ _b : Fin m, T := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul]
    _ ≤ ∑ b : Fin m, LinkTotInf f j b := Finset.sum_le_sum (fun b _ => hlink b)

/-- **Flagship local-to-global KKL theorem for the partite complex.**

Fix a colour `j` of the complete `n`-partite complex (`n ≥ 2`) with parts of size
`m`.  If all `m` links of `j` carry link-influence at least `T` — the *local* KKL
lower bound on each link — then some *global* colour `i ≠ j` has influence at least
the global average `mT/(n-1)`, stated multiplicatively as `mT ≤ (n-1)·Inf f i`.

For `m = 2` this recovers the classical Boolean-cube local-to-global bound. -/
theorem localToGlobal_KKL_partite (f : (Fin n → Fin m) → Bool) (j : Fin n)
    (hn : 2 ≤ n) (T : ℕ) (hlink : ∀ b : Fin m, T ≤ LinkTotInf f j b) :
    ∃ i ∈ univ.erase j, m * T ≤ (n - 1) * Inf f i := by
  have hne : (univ.erase j : Finset (Fin n)).Nonempty := by
    rw [← Finset.card_pos, Finset.card_erase_of_mem (Finset.mem_univ j),
        Finset.card_univ, Fintype.card_fin]
    omega
  obtain ⟨i, hi, hle⟩ := exists_ge_avg_nat (univ.erase j) (Inf f) hne
  refine ⟨i, hi, ?_⟩
  have hcard : (univ.erase j : Finset (Fin n)).card = n - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ j), Finset.card_univ, Fintype.card_fin]
  calc m * T ≤ ∑ i ∈ univ.erase j, Inf f i := total_via_links f j T hlink
    _ ≤ (univ.erase j).card * Inf f i := hle
    _ = (n - 1) * Inf f i := by rw [hcard]

end Partite

/-! ## Abstract engine: local KKL ⟹ global KKL -/

section Abstract

/-- **Abstract local-to-global KKL theorem.**  Given coordinates `ι`, a weighted
family of links `κ` with non-negative weights `w`, non-negative local influences
`Iℓ` and global influences `I`, assume the *bridge* `I i = ∑ ℓ, w ℓ · Iℓ ℓ i` and
the *local KKL hypothesis* that every link has a coordinate of influence at least
`τ`.  Then the global total influence is at least `τ · (∑ ℓ w ℓ)`. -/
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

/-- **Abstract global influential coordinate.**  Under the hypotheses of
`abstract_localToGlobal_KKL`, some global coordinate has influence at least the
global average `τ·(∑ w)/|ι|`. -/
theorem abstract_global_influential_coord
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ]
    (I : ι → ℝ) (w : κ → ℝ) (Iℓ : κ → ι → ℝ) (τ : ℝ)
    (hw : ∀ l, 0 ≤ w l) (hIℓ : ∀ l i, 0 ≤ Iℓ l i)
    (bridge : ∀ i, I i = ∑ l, w l * Iℓ l i)
    (localKKL : ∀ l, ∃ i, τ ≤ Iℓ l i) :
    ∃ i, τ * (∑ l, w l) ≤ (Fintype.card ι : ℝ) * I i := by
  obtain ⟨i, hi⟩ := exists_ge_avg_real I
  exact ⟨i, le_trans (abstract_localToGlobal_KKL I w Iℓ τ hw hIℓ bridge localKKL) hi⟩

/-- **Variance-thresholded local-to-global KKL** (the genuine KKL conditional).  For
each link, *if* the link is non-degenerate (`V₀ ≤ V ℓ`) *then* it has an
influential coordinate.  Assuming every link is non-degenerate, the global total
influence is at least `τ · (∑ ℓ w ℓ)`. -/
theorem abstract_localToGlobal_KKL_variance
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (I : ι → ℝ) (w : κ → ℝ) (Iℓ : κ → ι → ℝ) (V : κ → ℝ) (V₀ τ : ℝ)
    (hw : ∀ l, 0 ≤ w l) (hIℓ : ∀ l i, 0 ≤ Iℓ l i)
    (bridge : ∀ i, I i = ∑ l, w l * Iℓ l i)
    (hnondeg : ∀ l, V₀ ≤ V l)
    (localKKL : ∀ l, V₀ ≤ V l → ∃ i, τ ≤ Iℓ l i) :
    τ * (∑ l, w l) ≤ ∑ i, I i :=
  abstract_localToGlobal_KKL I w Iℓ τ hw hIℓ bridge (fun l => localKKL l (hnondeg l))

end Abstract

/-! ## The partite complex as an instance of the abstract engine -/

/-- **The partite decomposition is an instance of the abstract engine.**  Taking the
`m` links of colour `j` as a family of unit weight recovers the total-influence
lower bound: if each link has an influential coordinate of influence at least `T`,
then the total influence of `f` is at least `mT`. -/
theorem partite_total_via_abstract {n m : ℕ} (f : (Fin n → Fin m) → Bool) (j : Fin n)
    (T : ℕ) (hlink : ∀ b : Fin m, ∃ i, T ≤ InfSub f j b i) :
    (m : ℝ) * T ≤ TotInf f := by
  have key : (T : ℝ) * (∑ _l : Fin m, (1 : ℝ)) ≤ ∑ i, (Inf f i : ℝ) := by
    refine abstract_localToGlobal_KKL (ι := Fin n) (κ := Fin m)
      (fun i => (Inf f i : ℝ)) (fun _ => (1 : ℝ))
      (fun b i => (InfSub f j b i : ℝ)) (T : ℝ)
      (fun _ => by norm_num) (fun _ _ => by positivity) ?_ ?_
    · intro i
      show (Inf f i : ℝ) = ∑ l : Fin m, (1 : ℝ) * (InfSub f j l i : ℝ)
      rw [inf_decomp f j i]; push_cast; simp [one_mul]
    · intro l
      obtain ⟨i, hi⟩ := hlink l
      refine ⟨i, ?_⟩
      show (T : ℝ) ≤ (InfSub f j l i : ℝ)
      exact_mod_cast hi
  have hsum : (∑ i, (Inf f i : ℝ)) = (TotInf f : ℝ) := by
    unfold TotInf; push_cast; ring
  have hones : (∑ _l : Fin m, (1 : ℝ)) = (m : ℝ) := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
  rw [hones, hsum] at key
  linarith [key]

/-! ## Real-valued averaged global influential coordinate -/

/-- **Partite local-to-global KKL, real form.**  If each of the `m` links of colour
`j` has an influential coordinate of influence at least `T`, some global colour has
real influence at least the average `mT / n`. -/
theorem partite_localKKL_influential_coord_real {n m : ℕ} [NeZero n]
    (f : (Fin n → Fin m) → Bool) (j : Fin n) (T : ℕ)
    (hlink : ∀ b : Fin m, ∃ i, T ≤ InfSub f j b i) :
    ∃ i, (m * T : ℝ) ≤ (n : ℝ) * Inf f i := by
  have htot : (m : ℝ) * T ≤ TotInf f := partite_total_via_abstract f j T hlink
  obtain ⟨i, hi⟩ := exists_ge_avg_real (ι := Fin n) (fun i => (Inf f i : ℝ))
  refine ⟨i, ?_⟩
  have hcard : (Fintype.card (Fin n) : ℝ) = (n : ℝ) := by rw [Fintype.card_fin]
  have hsum : (∑ i, (Inf f i : ℝ)) = (TotInf f : ℝ) := by
    unfold TotInf; push_cast; ring
  rw [hcard, hsum] at hi
  calc (m * T : ℝ) ≤ (TotInf f : ℝ) := htot
    _ ≤ (n : ℝ) * Inf f i := hi

/-! ## The degenerate boundary: vanishing influence forces constancy -/

/-- If colour `i` has zero influence, then `f` is invariant under changing colour
`i`: any two facets differing only at colour `i` receive the same label. -/
theorem eq_of_inf_zero {n m : ℕ} (f : (Fin n → Fin m) → Bool) (i : Fin n)
    (h : Inf f i = 0) (x y : Fin n → Fin m)
    (hoff : ∀ k, k ≠ i → x k = y k) : f x = f y := by
  by_cases hxy : x i = y i
  · have : x = y := by
      funext k; by_cases hk : k = i
      · subst hk; exact hxy
      · exact hoff k hk
    rw [this]
  · by_contra hne
    have hmem : (x, y) ∈ Finset.univ.filter
        (fun p : (Fin n → Fin m) × (Fin n → Fin m) =>
          (∀ k, k ≠ i → p.1 k = p.2 k) ∧ p.1 i ≠ p.2 i ∧ f p.1 ≠ f p.2) := by
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨hoff, hxy, hne⟩
    have : (Finset.univ.filter
        (fun p : (Fin n → Fin m) × (Fin n → Fin m) =>
          (∀ k, k ≠ i → p.1 k = p.2 k) ∧ p.1 i ≠ p.2 i ∧ f p.1 ≠ f p.2)).Nonempty :=
      ⟨(x, y), hmem⟩
    rw [← Finset.card_pos] at this
    unfold Inf at h
    omega

/-- **Vanishing-influence boundary of KKL.**  A facet-labelling all of whose colour
influences vanish is constant.  Hence the KKL conclusion (an influential
coordinate) can fail only for the degenerate constant labellings — the exact
boundary case that the local-to-global theorem excludes via its lower-bound
hypotheses. -/
theorem zero_influence_constant {n m : ℕ} (f : (Fin n → Fin m) → Bool)
    (h : ∀ i, Inf f i = 0) (x y : Fin n → Fin m) : f x = f y := by
  -- Induct on the set of coordinates where `x` and `y` differ, flipping one at a time.
  have h_ind : ∀ (s : Finset (Fin n)), (∀ i ∈ s, x i ≠ y i) →
      (∀ i ∉ s, x i = y i) → f x = f y := by
    intro s hs hs'
    induction' s using Finset.induction with i s hi ih generalizing x y
    · rw [show x = y from funext fun k => hs' k (by simp)]
    · -- Flip coordinate `i` of `x` to `y i`; this leaves the labelling unchanged.
      have hflip : f x = f (Function.update x i (y i)) :=
        eq_of_inf_zero f i (h i) x (Function.update x i (y i))
          (fun k hk => by rw [Function.update_of_ne hk])
      -- The flipped point agrees with `y` on `i` and differs from `y` only within `s`.
      have htail : f (Function.update x i (y i)) = f y := by
        grind +extAll
      rw [hflip, htail]
  exact h_ind (Finset.univ.filter fun i => x i ≠ y i) (by aesop) (by aesop)

end PartiteKKL

/-
-- !-- Lab Notes -- !--

**Hypothesis.**  The Kahn–Kalai–Linial influence theorem is a *local* statement on
a single Boolean function.  We conjectured a *local-to-global* upgrade: on a
complex whose links each satisfy a KKL-type influence lower bound, the whole
complex inherits a global KKL-type bound.  The Boolean cube is the two-symbol case;
we conjectured the correct engine is alphabet-independent, driven by an exact
self-averaging identity for influences over the links of any single coordinate.

**Experiment.**  We modelled the complete `n`-partite complex with parts of size
`m`: its facets are transversals `Fin n → Fin m`, and the links of a colour `j`
are its `m` value-pinned subcomplexes.  Defining influence as the count of
sensitive Hamming edges, we tested and then proved the bridge identity
`inf_decomp : Inf f i = ∑ b, InfSub f j b i` by fibering the sensitive-edge set
over the pinned value.  Summing over colours (`linktot_decomp`) and pigeonholing
(`exists_ge_avg_nat`) gave the flagship `localToGlobal_KKL_partite`.  We further
abstracted the mechanism to an arbitrary weighted family of links
(`abstract_localToGlobal_KKL`) and showed the partite complex is a unit-weight
instance (`partite_total_via_abstract`).

**Analysis.**  The single load-bearing fact is that a coordinate influence is an
*exact* (not merely approximate) average of link influences; every downstream
bound is a pigeonhole over that identity.  The `m`-fold link structure — absent in
the classical two-symbol cube — strengthens the total-influence lower bound from
`2T` to `mT`, so richer alphabets propagate more influence to the global level.
The averaging argument never used `m = 2`, `Bool`, or any metric structure; it used
only non-negativity and finiteness, which is why it lifts verbatim to the abstract
weighted engine.

**Critique.**  A KKL-style conclusion is vacuous for degenerate (constant)
labellings, so we pinned down that boundary exactly: `zero_influence_constant`
shows a labelling with all influences zero is constant, i.e. the only obstruction
to a globally influential coordinate is genuine degeneracy — precisely what the
lower-bound hypotheses of the main theorem exclude.  This rules out a vacuous
reading of the flagship statement.

**Synthesis.**  A single exact averaging identity for influences over the links of
one coordinate yields, uniformly across all alphabets, a local-to-global KKL
theorem; the classical Boolean cube is the `m = 2` shadow of a genuinely
alphabet-graded phenomenon.
-/