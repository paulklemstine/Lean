import Shared.SidonSetsErdosTuran

/-!
# Bonferroni machinery and the marginal selection principle

The *Bonferroni machinery* for a finite family of finite sets `A : ι → Finset α` consists of
two inequalities that are completely insensitive to what the sets actually are:

* `card_sum_le_card_biUnion_add_offDiag` — the second Bonferroni inequality,
  `∑ i, |A i| ≤ |⋃ i, A i| + ∑_{i ≠ j} |A i ∩ A j|`;
* `card_doubleCollision_mul_le` — the points covered at least twice are controlled by the
  same pair-correlation sum, `2 · |{x : mult x ≥ 2}| ≤ ∑_{i ≠ j} |A i ∩ A j|`.

Both follow from one Fubini identity (`sum_sum_eq_sum_mult_mul`) for the multiplicity
function `mult A x = #{i | x ∈ A i}`.  Adding Cauchy–Schwarz to the same identity gives the
quadratic strengthening `sq_sum_card_le_card_support_mul` (Corrádi's lemma), and all three
are *universal*: they hold for every family.

Consequently a concrete extremal bound obtained this way is entirely determined by **which
marginals are fed into the machinery** — the index set, the common size of the sets, and the
pair-intersection bound.  The second half of this file makes that slogan into theorems.
Starting from one and the same Sidon set `A` in a finite abelian group `G`:

* feeding the `|A|` translates `A + a`, `a ∈ A` yields `|A|³ ≤ (2|A| - 1)·|G|`
  (`IsSidon.cube_card_le_of_self_translates`), i.e. `|A| ≲ √(2|G|)`;
* feeding **all** `|G|` translates yields the sharp Erdős–Turán bound
  `|A|(|A| - 1) ≤ |G| - 1` (`IsSidon.card_mul_pred_le_of_all_translates`), i.e. `|A| ≲ √|G|`;
* and `marginal_selection_strict` exhibits explicit parameters at which the first bound is
  strictly weaker than the second, so the gap between the two marginal choices is real and
  not an artefact of the estimates.

## Main results

Machinery (arbitrary finite family):

* `sum_sum_eq_sum_mult_mul` — Fubini through the incidence bipartite graph.
* `sum_card_eq_sum_mult`, `sum_card_inter_eq_sum_mult_sq` — the first two moments of `mult`.
* `card_sum_le_card_biUnion_add_offDiag` — second Bonferroni inequality.
* `sum_eq_iff_pairwiseDisjoint` — Bonferroni is an equality *exactly* for pairwise disjoint
  families; this pins down the boundary of the machinery.
* `card_doubleCollision_mul_le` — double-collision bound.
* `sq_sum_card_le_card_support_mul` — Corrádi/Cauchy–Schwarz strengthening.

Marginals:

* `card_support_mul_le_of_pairwise_inter_le`, `corradi_uniform` — the two shapes of output
  produced by uniform marginals with pairwise intersections `≤ t`.
* `reiman_bound` — the `C₄`-free (Reiman) case `t = 1`.
* `IsSidon.card_inter_translate_le_one`, `IsSidon.translate_family_bound` — the marginal
  supplied by a Sidon set `A ⊆ G` and the master inequality `|S|·|A|² ≤ |G|·(|A| + |S| - 1)`
  for an arbitrary nonempty set `S` of shifts, building on `IsSidon` from
  `Shared/SidonSetsErdosTuran.lean`.
* `IsSidon.card_mul_pred_le_of_all_translates` (`S = G`),
  `IsSidon.cube_card_le_of_self_translates` (`S = A`),
  `all_translate_bound_implies_self_translate_bound` and `marginal_selection_strict` — the two
  extreme marginal choices and a proof that they are *strictly* ordered.
* `c4_free_edge_bound` — a cross-domain instantiation: neighbourhood marginals of a graph
  with no two vertices having two common neighbours give Reiman's `|E| = O(|V|^{3/2})` bound.
* `doubleCollision_bound_sharp`, `bonferroni_can_be_strict` — sharpness data.
* `sum_card_inter3_eq_sum_mult_cube`, `third_moment_identity`,
  `card_tripleCollision_mul_le` — the third-order layer of the same machinery.
-/

open Finset

namespace Bonferroni

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-! ## 1. Multiplicities and the Fubini identity -/

/-- The **multiplicity** of `x` in the family `A`: the number of members containing `x`. -/
def mult (A : ι → Finset α) (x : α) : ℕ := #{i | x ∈ A i}

/-- The support (union) of the family. -/
def support (A : ι → Finset α) : Finset α := univ.biUnion A

variable {A : ι → Finset α}

lemma mem_support_iff {x : α} : x ∈ support A ↔ ∃ i, x ∈ A i := by simp [support]

lemma subset_support (i : ι) : A i ⊆ support A := fun _ hx => mem_support_iff.2 ⟨i, hx⟩

lemma mult_pos_iff {x : α} : 0 < mult A x ↔ x ∈ support A := by
  simp [mult, mem_support_iff, Finset.card_pos, Finset.filter_nonempty_iff]

/-- **Fubini for the incidence bipartite graph**: summing a weight `f` over each member of the
family and then over the family is the same as summing `mult · f` over the support. -/
lemma sum_sum_eq_sum_mult_mul (f : α → ℕ) :
    ∑ i, ∑ x ∈ A i, f x = ∑ x ∈ support A, mult A x * f x := by
  have h1 : ∀ i : ι, ∑ x ∈ A i, f x = ∑ x ∈ support A, (if x ∈ A i then f x else 0) := by
    intro i
    rw [← Finset.sum_filter, Finset.filter_mem_eq_inter,
      Finset.inter_eq_right.2 (subset_support i)]
  simp only [h1]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [← Finset.sum_filter, Finset.sum_const, mult, smul_eq_mul]

/-- **Localised Fubini**: the same identity relativised to an arbitrary ground set `s`.  This
is the form needed for the higher-order (triple-correlation) moments. -/
lemma sum_inter_sum_eq_sum_mult_mul (s : Finset α) (f : α → ℕ) :
    ∑ i, ∑ x ∈ s ∩ A i, f x = ∑ x ∈ s, mult A x * f x := by
  have h1 : ∀ i : ι, ∑ x ∈ s ∩ A i, f x = ∑ x ∈ s, (if x ∈ A i then f x else 0) := by
    intro i
    rw [← Finset.sum_filter, Finset.filter_mem_eq_inter]
  simp only [h1]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [← Finset.sum_filter, Finset.sum_const, mult, smul_eq_mul]

/-- First moment: the total size of the family is the total multiplicity. -/
lemma sum_card_eq_sum_mult : ∑ i, #(A i) = ∑ x ∈ support A, mult A x := by
  simpa using sum_sum_eq_sum_mult_mul (A := A) (fun _ => 1)

/-- Second moment: the full pair-correlation sum is the sum of squared multiplicities. -/
lemma sum_card_inter_eq_sum_mult_sq :
    ∑ i, ∑ j, #(A i ∩ A j) = ∑ x ∈ support A, (mult A x) ^ 2 := by
  have h : ∀ i : ι, ∑ j, #(A i ∩ A j) = ∑ x ∈ A i, mult A x := by
    intro i
    have hb : ∀ j : ι, #(A i ∩ A j) = ∑ x ∈ A i, (if x ∈ A j then 1 else 0) := by
      intro j
      rw [Finset.sum_boole]
      simp [Finset.filter_mem_eq_inter]
    simp only [hb]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => by
      rw [← Finset.sum_filter, Finset.sum_const, mult, smul_eq_mul, mul_one]
  simp only [h]
  rw [sum_sum_eq_sum_mult_mul]
  exact Finset.sum_congr rfl fun x _ => (sq _).symm

variable [DecidableEq ι]

/-- The off-diagonal pair-correlation sum `∑_{i ≠ j} |A i ∩ A j|`. -/
def pairSum (A : ι → Finset α) : ℕ := ∑ p ∈ (univ : Finset ι).offDiag, #(A p.1 ∩ A p.2)

omit [DecidableEq ι] in
lemma card_offDiag_univ : #((univ : Finset ι).offDiag) = Fintype.card ι * (Fintype.card ι - 1) := by
  rw [Finset.offDiag_card, Finset.card_univ]
  cases h : Fintype.card ι with
  | zero => simp
  | succ n => simp [Nat.mul_succ]

/-- Splitting the full pair-correlation sum into diagonal and off-diagonal parts. -/
lemma pairSum_add_sum_card : pairSum A + ∑ i, #(A i) = ∑ x ∈ support A, (mult A x) ^ 2 := by
  rw [← sum_card_inter_eq_sum_mult_sq, ← Finset.sum_product']
  have hdiag : ∑ p ∈ (univ : Finset ι).diag, #(A p.1 ∩ A p.2) = ∑ i, #(A i) := by
    rw [Finset.sum_diag]
    simp
  rw [pairSum, ← hdiag, add_comm,
    ← Finset.sum_union (Finset.disjoint_diag_offDiag _), Finset.diag_union_offDiag]

/-- The off-diagonal pair-correlation sum counts ordered collisions:
`∑_{i ≠ j} |A i ∩ A j| = ∑_x mult x (mult x - 1)`. -/
lemma pairSum_eq_sum_mult_mul_pred :
    pairSum A = ∑ x ∈ support A, mult A x * (mult A x - 1) := by
  have key : (∑ x ∈ support A, mult A x * (mult A x - 1)) + ∑ i, #(A i)
      = ∑ x ∈ support A, (mult A x) ^ 2 := by
    rw [sum_card_eq_sum_mult, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun x hx => ?_
    have h1 : 1 ≤ mult A x := mult_pos_iff.2 hx
    obtain ⟨n, hn⟩ := Nat.exists_eq_add_of_le h1
    have hn1 : 1 + n - 1 = n := by omega
    rw [hn, hn1]
    ring
  have := pairSum_add_sum_card (A := A)
  omega

/-! ## 2. The two Bonferroni inequalities -/

/-- **Second Bonferroni inequality.**  For an arbitrary finite family of finite sets,
`∑ i, |A i| ≤ |⋃ i, A i| + ∑_{i ≠ j} |A i ∩ A j|`. -/
theorem card_sum_le_card_biUnion_add_offDiag :
    ∑ i, #(A i) ≤ #(support A) + pairSum A := by
  have hpt : ∀ x ∈ support A, 2 * mult A x ≤ 1 + (mult A x) ^ 2 := by
    intro x _
    zify
    nlinarith [sq_nonneg ((mult A x : ℤ) - 1)]
  have hsum : ∑ x ∈ support A, 2 * mult A x
      ≤ ∑ x ∈ support A, (1 + (mult A x) ^ 2) := Finset.sum_le_sum hpt
  rw [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_const, smul_eq_mul, mul_one,
    ← sum_card_eq_sum_mult] at hsum
  have h2 := pairSum_add_sum_card (A := A)
  omega

/-- The Bonferroni inequality is an **equality precisely for pairwise disjoint families**.
This locates the exact boundary of the machinery: any slack in `∑ |A i| ≤ |⋃ A i| + pairSum`
comes from a point of multiplicity `≠ 1`. -/
theorem sum_eq_iff_pairwiseDisjoint :
    ∑ i, #(A i) = #(support A) + pairSum A ↔ ∀ i j, i ≠ j → Disjoint (A i) (A j) := by
  constructor
  · intro heq i j hij
    -- equality forces every multiplicity to be `1`
    have hpt : ∀ x ∈ support A, 2 * mult A x ≤ 1 + (mult A x) ^ 2 := by
      intro x _
      zify
      nlinarith [sq_nonneg ((mult A x : ℤ) - 1)]
    have hall : ∀ x ∈ support A, mult A x = 1 := by
      by_contra hcon
      push_neg at hcon
      obtain ⟨x, hx, hx1⟩ := hcon
      have h1 : 1 ≤ mult A x := mult_pos_iff.2 hx
      have h2 : 2 ≤ mult A x := by omega
      have hmm : 2 * mult A x ≤ mult A x * mult A x := Nat.mul_le_mul_right _ h2
      have hstrict : 2 * mult A x < 1 + (mult A x) ^ 2 := by rw [sq]; omega
      have hsum : ∑ x ∈ support A, 2 * mult A x
          < ∑ x ∈ support A, (1 + (mult A x) ^ 2) :=
        Finset.sum_lt_sum hpt ⟨x, hx, hstrict⟩
      rw [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_const, smul_eq_mul, mul_one,
        ← sum_card_eq_sum_mult] at hsum
      have h3 := pairSum_add_sum_card (A := A)
      omega
    rw [Finset.disjoint_left]
    intro x hxi hxj
    have hx : x ∈ support A := subset_support i hxi
    have h2 : 2 ≤ mult A x := by
      have hsub2 : ({i, j} : Finset ι) ⊆ Finset.univ.filter (fun k => x ∈ A k) := by
        intro k hk
        simp only [Finset.mem_insert, Finset.mem_singleton] at hk
        rcases hk with rfl | rfl <;> simp [hxi, hxj]
      have hc := Finset.card_le_card hsub2
      rw [Finset.card_insert_of_notMem (by simpa using hij), Finset.card_singleton] at hc
      simpa [mult] using hc
    rw [hall x hx] at h2
    omega
  · intro hdisj
    have hcard : #(support A) = ∑ i, #(A i) := by
      rw [support]
      exact Finset.card_biUnion (fun i _ j _ hij => hdisj i j hij)
    have hp : pairSum A = 0 := by
      rw [pairSum]
      refine Finset.sum_eq_zero fun p hp => ?_
      rw [Finset.mem_offDiag] at hp
      rw [Finset.card_eq_zero, ← Finset.disjoint_iff_inter_eq_empty]
      exact hdisj p.1 p.2 hp.2.2
    omega

/-- The set of points covered at least twice by the family. -/
def doubleCollision (A : ι → Finset α) : Finset α := {x ∈ support A | 2 ≤ mult A x}

/-- **Double-collision bound.**  Twice the number of points of multiplicity `≥ 2` is at most
the off-diagonal pair-correlation sum. -/
theorem card_doubleCollision_mul_le : 2 * #(doubleCollision A) ≤ pairSum A := by
  rw [pairSum_eq_sum_mult_mul_pred]
  have hsub : doubleCollision A ⊆ support A := Finset.filter_subset _ _
  calc 2 * #(doubleCollision A)
      = ∑ _x ∈ doubleCollision A, 2 := by rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ ≤ ∑ x ∈ doubleCollision A, mult A x * (mult A x - 1) := by
        refine Finset.sum_le_sum fun x hx => ?_
        have h2 : 2 ≤ mult A x := (Finset.mem_filter.1 hx).2
        calc 2 = 2 * (2 - 1) := by norm_num
          _ ≤ mult A x * (mult A x - 1) := Nat.mul_le_mul h2 (by omega)
    _ ≤ ∑ x ∈ support A, mult A x * (mult A x - 1) :=
        Finset.sum_le_sum_of_subset hsub

/-- **Corrádi's lemma / Cauchy–Schwarz form of the machinery.**
`(∑ i, |A i|)² ≤ |⋃ i, A i| · (∑ i, |A i| + ∑_{i ≠ j} |A i ∩ A j|)`. -/
theorem sq_sum_card_le_card_support_mul :
    (∑ i, #(A i)) ^ 2 ≤ #(support A) * (∑ i, #(A i) + pairSum A) := by
  have hcs : (∑ x ∈ support A, mult A x) ^ 2
      ≤ #(support A) * ∑ x ∈ support A, (mult A x) ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := support A) (f := fun x => (mult A x : ℤ))
    push_cast at this
    exact_mod_cast this
  rw [← sum_card_eq_sum_mult] at hcs
  have h2 := pairSum_add_sum_card (A := A)
  calc (∑ i, #(A i)) ^ 2 ≤ #(support A) * ∑ x ∈ support A, (mult A x) ^ 2 := hcs
    _ = #(support A) * (∑ i, #(A i) + pairSum A) := by rw [← h2]; ring

/-! ## 3. Which marginals are fed in -/

variable {m t : ℕ}

/-- Uniform marginals, linear output: if every member has size `≥ m` and distinct members meet
in `≤ t` points, then `k·m ≤ |⋃ A i| + k(k-1)t` where `k` is the number of members. -/
theorem card_support_mul_le_of_pairwise_inter_le
    (hm : ∀ i, m ≤ #(A i)) (ht : ∀ i j, i ≠ j → #(A i ∩ A j) ≤ t) :
    Fintype.card ι * m ≤ #(support A) + Fintype.card ι * (Fintype.card ι - 1) * t := by
  have h1 : Fintype.card ι * m ≤ ∑ i, #(A i) := by
    calc Fintype.card ι * m = ∑ _i : ι, m := by
          rw [Finset.sum_const, smul_eq_mul, Finset.card_univ, mul_comm]
      _ ≤ ∑ i, #(A i) := Finset.sum_le_sum fun i _ => hm i
  have h2 : pairSum A ≤ Fintype.card ι * (Fintype.card ι - 1) * t := by
    rw [pairSum]
    calc ∑ p ∈ (univ : Finset ι).offDiag, #(A p.1 ∩ A p.2)
        ≤ ∑ _p ∈ (univ : Finset ι).offDiag, t := by
          refine Finset.sum_le_sum fun p hp => ht p.1 p.2 (Finset.mem_offDiag.1 hp).2.2
      _ = #((univ : Finset ι).offDiag) * t := by rw [Finset.sum_const, smul_eq_mul]
      _ = Fintype.card ι * (Fintype.card ι - 1) * t := by rw [card_offDiag_univ]
  have h3 := card_sum_le_card_biUnion_add_offDiag (A := A)
  omega

/-- Uniform marginals, quadratic output (**Corrádi**): with `|A i| = m` for all `i`, pairwise
intersections `≤ t` and `k` members, `k·m² ≤ |⋃ A i|·(m + (k-1)t)`. -/
theorem corradi_uniform [Nonempty ι]
    (hm : ∀ i, #(A i) = m) (ht : ∀ i j, i ≠ j → #(A i ∩ A j) ≤ t) :
    Fintype.card ι * m ^ 2 ≤ #(support A) * (m + (Fintype.card ι - 1) * t) := by
  set k := Fintype.card ι with hk
  have hkpos : 0 < k := Fintype.card_pos
  have hsum : ∑ i, #(A i) = k * m := by
    simp [hm, Finset.card_univ, ← hk, mul_comm]
  have h2 : pairSum A ≤ k * (k - 1) * t := by
    rw [pairSum]
    calc ∑ p ∈ (univ : Finset ι).offDiag, #(A p.1 ∩ A p.2)
        ≤ ∑ _p ∈ (univ : Finset ι).offDiag, t :=
          Finset.sum_le_sum fun p hp => ht p.1 p.2 (Finset.mem_offDiag.1 hp).2.2
      _ = #((univ : Finset ι).offDiag) * t := by rw [Finset.sum_const, smul_eq_mul]
      _ = k * (k - 1) * t := by rw [card_offDiag_univ]
  have hcs := sq_sum_card_le_card_support_mul (A := A)
  rw [hsum] at hcs
  have hstep : (k * m) ^ 2 ≤ #(support A) * (k * m + k * (k - 1) * t) :=
    hcs.trans (Nat.mul_le_mul_left _ (by omega))
  have hfac : #(support A) * (k * m + k * (k - 1) * t)
      = k * (#(support A) * (m + (k - 1) * t)) := by ring
  rw [hfac] at hstep
  have : k * (k * m ^ 2) ≤ k * (#(support A) * (m + (k - 1) * t)) := by
    calc k * (k * m ^ 2) = (k * m) ^ 2 := by ring
      _ ≤ _ := hstep
  exact Nat.le_of_mul_le_mul_left this hkpos

/-- **Reiman / Kővári–Sós–Turán case `t = 1`.**  If distinct members of the family meet in at
most one point (a `C₄`-free incidence structure), then `(∑ |A i|)² ≤ |⋃ A i|·(∑ |A i| + k(k-1))`.
-/
theorem reiman_bound (ht : ∀ i j, i ≠ j → #(A i ∩ A j) ≤ 1) :
    (∑ i, #(A i)) ^ 2 ≤ #(support A) * (∑ i, #(A i) + Fintype.card ι * (Fintype.card ι - 1)) := by
  have h2 : pairSum A ≤ Fintype.card ι * (Fintype.card ι - 1) := by
    rw [pairSum]
    calc ∑ p ∈ (univ : Finset ι).offDiag, #(A p.1 ∩ A p.2)
        ≤ ∑ _p ∈ (univ : Finset ι).offDiag, 1 :=
          Finset.sum_le_sum fun p hp => ht p.1 p.2 (Finset.mem_offDiag.1 hp).2.2
      _ = #((univ : Finset ι).offDiag) := by simp
      _ = Fintype.card ι * (Fintype.card ι - 1) := card_offDiag_univ
  exact (sq_sum_card_le_card_support_mul (A := A)).trans
    (Nat.mul_le_mul_left _ (by omega))


/-! ## 4. The marginal selection principle for Sidon sets

We now feed *two different families of marginals* built from one and the same Sidon set
`A ⊆ G` into the machinery of §2–§3 and compare the outputs. -/

section Sidon

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G] {A : Finset G}

/-- The translate family attached to a set `A` and an index set of shifts. -/
def translate (A : Finset G) (g : G) : Finset G := A.image (· + g)

omit [Fintype G] in
@[simp] lemma card_translate (A : Finset G) (g : G) : #(translate A g) = #A :=
  Finset.card_image_of_injective _ (add_left_injective g)

omit [Fintype G] in
lemma mem_translate {A : Finset G} {g x : G} : x ∈ translate A g ↔ ∃ a ∈ A, a + g = x := by
  simp only [translate, Finset.mem_image]

omit [Fintype G] in
/-- **The Sidon marginal.**  Distinct translates of a Sidon set meet in at most one point;
this is exactly the pair-intersection input `t = 1` required by the machinery. -/
theorem IsSidon.card_inter_translate_le_one (hA : IsSidon A) {g h : G} (hgh : g ≠ h) :
    #(translate A g ∩ translate A h) ≤ 1 := by
  rw [Finset.card_le_one]
  intro x hx y hy
  rw [Finset.mem_inter, mem_translate, mem_translate] at hx hy
  obtain ⟨⟨p, hp, hpx⟩, ⟨q, hq, hqx⟩⟩ := hx
  obtain ⟨⟨p', hp', hpy⟩, ⟨q', hq', hqy⟩⟩ := hy
  have hsum : p + q' = q + p' := by
    have h1 : p + g = q + h := by rw [hpx, hqx]
    have h2 : p' + g = q' + h := by rw [hpy, hqy]
    have : (p + q') + (g + h) = (q + p') + (g + h) := by
      calc (p + q') + (g + h) = (p + g) + (q' + h) := by abel
        _ = (q + h) + (p' + g) := by rw [h1, ← h2]
        _ = (q + p') + (g + h) := by abel
    exact add_right_cancel this
  rcases hA p hp q' hq' q hq p' hp' hsum with ⟨h1, -⟩ | ⟨h1, -⟩
  · exfalso
    refine hgh (add_left_cancel (a := p) ?_)
    calc p + g = x := hpx
      _ = q + h := hqx.symm
      _ = p + h := by rw [h1]
  · rw [← hpx, ← hpy, h1]

/-- **The general translate marginal.**  For every nonempty set `S` of shifts, feeding the
`|S|` translates `{A + g : g ∈ S}` of a Sidon set `A ⊆ G` into Corrádi's form of the
Bonferroni machinery yields `|S|·|A|² ≤ |G|·(|A| + |S| - 1)`.

This single inequality is the whole content of the marginal-selection question for Sidon
sets: every choice of shift set produces one instance of it, and the strength of the
resulting bound on `|A|` is governed by `|S|`. -/
theorem IsSidon.translate_family_bound (hA : IsSidon A) {S : Finset G} (hS : S.Nonempty) :
    #S * #A ^ 2 ≤ Fintype.card G * (#A + (#S - 1)) := by
  classical
  obtain ⟨g₀, hg₀⟩ := hS
  have : Nonempty {g // g ∈ S} := ⟨⟨g₀, hg₀⟩⟩
  have hcard : Fintype.card {g // g ∈ S} = #S := Fintype.card_coe S
  have hcor := Bonferroni.corradi_uniform
    (A := fun g : {g // g ∈ S} => translate A g.1) (m := #A) (t := 1)
    (fun g => card_translate A g.1)
    (fun a b hab => IsSidon.card_inter_translate_le_one hA (fun h => hab (Subtype.ext h)))
  rw [hcard] at hcor
  have hsupp : #(Bonferroni.support (fun g : {g // g ∈ S} => translate A g.1))
      ≤ Fintype.card G := by
    simpa using
      Finset.card_le_univ (Bonferroni.support (fun g : {g // g ∈ S} => translate A g.1))
  calc #S * #A ^ 2
      ≤ #(Bonferroni.support (fun g : {g // g ∈ S} => translate A g.1)) *
          (#A + (#S - 1) * 1) := hcor
    _ ≤ Fintype.card G * (#A + (#S - 1) * 1) := Nat.mul_le_mul_right _ hsupp
    _ = Fintype.card G * (#A + (#S - 1)) := by ring_nf

/-- **All-translate marginals.**  Taking `S = G`, i.e. feeding the machinery the family of
*all* `|G|` translates `A + g` of a Sidon set, recovers the sharp Erdős–Turán bound
`|A|(|A| - 1) ≤ |G| - 1`. -/
theorem IsSidon.card_mul_pred_le_of_all_translates (hA : IsSidon A) :
    #A * (#A - 1) ≤ Fintype.card G - 1 := by
  classical
  have hN : 0 < Fintype.card G := Fintype.card_pos
  have hne : (Finset.univ : Finset G).Nonempty := Finset.univ_nonempty
  have hbound := IsSidon.translate_family_bound hA hne
  rw [Finset.card_univ] at hbound
  have hmul : #A ^ 2 ≤ #A + (Fintype.card G - 1) := Nat.le_of_mul_le_mul_left hbound hN
  rcases Nat.eq_zero_or_pos #A with h0 | hpos
  · simp [h0]
  · have hsq : #A ^ 2 = #A * #A := sq _
    have hexp : #A * (#A - 1) + #A = #A * #A := by
      cases hc : #A with
      | zero => simp
      | succ n =>
        have hn1 : n + 1 - 1 = n := rfl
        rw [hn1]
        ring
    omega

/-- **Self-translate marginals.**  Taking `S = A`, i.e. feeding the machinery only the `|A|`
translates `A + a` with `a ∈ A`, yields the weaker cubic bound `|A|³ ≤ (2|A| - 1)·|G|`. -/
theorem IsSidon.cube_card_le_of_self_translates (hA : IsSidon A) :
    #A ^ 3 ≤ (2 * #A - 1) * Fintype.card G := by
  classical
  rcases Finset.eq_empty_or_nonempty A with rfl | hne
  · simp
  · have hbound := IsSidon.translate_family_bound hA hne
    have hcollapse : #A + (#A - 1) = 2 * #A - 1 := by
      have : 1 ≤ #A := Finset.card_pos.2 hne
      omega
    rw [hcollapse] at hbound
    calc #A ^ 3 = #A * #A ^ 2 := by ring
      _ ≤ Fintype.card G * (2 * #A - 1) := hbound
      _ = (2 * #A - 1) * Fintype.card G := by ring

/-- **The marginal choice is not an artefact.**  There are parameters `(N, m)` satisfying the
self-translate output `m³ ≤ (2m - 1)N` but violating the all-translate output
`m(m-1) ≤ N - 1`: the two marginal families give genuinely different strength, so the
conclusion drawn from the universal Bonferroni machinery really is a statement about which
marginals are fed into it. -/
theorem marginal_selection_strict :
    ∃ N m : ℕ, 0 < N ∧ 0 < m ∧ m ^ 3 ≤ (2 * m - 1) * N ∧ ¬ (m * (m - 1) ≤ N - 1) := by
  refine ⟨100, 13, by norm_num, by norm_num, by norm_num, by norm_num⟩


/-- **The all-translate marginal dominates the self-translate marginal.**  Whenever the
sharp output `m(m-1) ≤ N - 1` holds, the cubic output `m³ ≤ (2m-1)N` follows.  Together with
`marginal_selection_strict` (which produces parameters where the cubic bound holds and the
sharp one fails) this proves that the two marginal choices are *strictly* ordered. -/
theorem all_translate_bound_implies_self_translate_bound (m N : ℕ) (hN : 0 < N)
    (h : m * (m - 1) ≤ N - 1) : m ^ 3 ≤ (2 * m - 1) * N := by
  match m with
  | 0 => simp
  | 1 => simpa using hN
  | (k + 2) =>
    have hk : (k + 2) * (k + 1) + 1 ≤ N := by
      have : (k + 2) * (k + 2 - 1) = (k + 2) * (k + 1) := by norm_num
      omega
    have h2 : 2 * (k + 2) - 1 = 2 * k + 3 := by omega
    rw [h2]
    nlinarith [hk, Nat.zero_le k]

end Sidon

/-! ## 5. Cross-domain instantiation: `C₄`-free graphs

The very same machinery, fed with the *neighbourhood marginals* of a graph in which any two
distinct vertices have at most one common neighbour, produces the Reiman /
Kővári–Sós–Turán bound on the number of edges. -/

section Graph

open SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V] (Gr : SimpleGraph V) [DecidableRel Gr.Adj]

/-- **Reiman's inequality for `C₄`-free graphs.**  If any two distinct vertices of a finite
graph have at most one common neighbour, then `(2|E|)² ≤ |V|·(2|E| + |V|(|V|-1))`; in
particular `|E| = O(|V|^{3/2})`.  The marginals fed into the machinery are the neighbourhoods
`N(v)`, whose pairwise intersections are exactly the common-neighbour sets. -/
theorem c4_free_edge_bound
    (h : ∀ u v : V, u ≠ v → #(Gr.neighborFinset u ∩ Gr.neighborFinset v) ≤ 1) :
    (2 * #Gr.edgeFinset) ^ 2
      ≤ Fintype.card V * (2 * #Gr.edgeFinset + Fintype.card V * (Fintype.card V - 1)) := by
  have hsum : ∑ v, #(Gr.neighborFinset v) = 2 * #Gr.edgeFinset :=
    Gr.sum_degrees_eq_twice_card_edges
  have hre := reiman_bound (A := fun v => Gr.neighborFinset v) h
  have hsupp : #(support (fun v => Gr.neighborFinset v)) ≤ Fintype.card V := by
    simpa using Finset.card_le_univ (support (fun v => Gr.neighborFinset v))
  rw [hsum] at hre
  exact hre.trans (Nat.mul_le_mul_right _ hsupp)

end Graph

/-! ## 7. Third-order machinery: triple correlations

The Fubini identity is not tied to the second moment.  Feeding it once more produces the
triple-correlation identity and a third-order collision bound, which is the natural place to
look for improvements that the pair-correlation machinery cannot see. -/

section ThirdOrder

variable {ι α : Type*} [Fintype ι] [DecidableEq α] {A : ι → Finset α}

/-- Third moment: the full triple-correlation sum is the sum of cubed multiplicities. -/
lemma sum_card_inter3_eq_sum_mult_cube :
    ∑ i, ∑ j, ∑ k, #(A i ∩ A j ∩ A k) = ∑ x ∈ support A, (mult A x) ^ 3 := by
  have h3 : ∀ i j : ι, ∑ k, #(A i ∩ A j ∩ A k) = ∑ x ∈ A i ∩ A j, mult A x := by
    intro i j
    simpa using sum_inter_sum_eq_sum_mult_mul (A := A) (A i ∩ A j) (fun _ => 1)
  simp only [h3]
  have h2 : ∀ i : ι, ∑ j, ∑ x ∈ A i ∩ A j, mult A x
      = ∑ x ∈ A i, mult A x * mult A x :=
    fun i => sum_inter_sum_eq_sum_mult_mul (A := A) (A i) (fun x => mult A x)
  simp only [h2]
  have h1 : ∀ i : ι, ∑ x ∈ A i, mult A x * mult A x
      = ∑ x ∈ support A ∩ A i, mult A x * mult A x := by
    intro i
    rw [Finset.inter_eq_right.2 (subset_support i)]
  simp only [h1]
  rw [sum_inter_sum_eq_sum_mult_mul]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- **Third-order Bonferroni identity.**  With no subtraction anywhere:
`∑ₓ m(m-1)(m-2) + 3·∑_{i,j} |Aᵢ ∩ Aⱼ| = ∑_{i,j,k} |Aᵢ ∩ Aⱼ ∩ A_k| + 2·∑ᵢ |Aᵢ|`,
where `m = mult A x`.  It is the inclusion–exclusion expansion of the number of ordered
triples of *distinct* indices covering a point. -/
theorem third_moment_identity :
    (∑ x ∈ support A, mult A x * (mult A x - 1) * (mult A x - 2))
        + 3 * ∑ i, ∑ j, #(A i ∩ A j)
      = (∑ i, ∑ j, ∑ k, #(A i ∩ A j ∩ A k)) + 2 * ∑ i, #(A i) := by
  rw [sum_card_inter_eq_sum_mult_sq, sum_card_inter3_eq_sum_mult_cube, sum_card_eq_sum_mult,
    Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  match hm : mult A x with
  | 0 => simp
  | 1 => simp
  | 2 => simp
  | (k + 3) =>
    have e1 : k + 3 - 1 = k + 2 := rfl
    have e2 : k + 3 - 2 = k + 1 := rfl
    rw [e1, e2]
    ring

/-- Points of multiplicity at least three. -/
def tripleCollision (A : ι → Finset α) : Finset α := {x ∈ support A | 3 ≤ mult A x}

/-- **Third-order collision bound.**  Six times the number of points of multiplicity `≥ 3` is
at most the ordered-distinct-triple count `∑ₓ m(m-1)(m-2)` controlled by
`third_moment_identity`.  This is the exact analogue of `card_doubleCollision_mul_le` one
level up. -/
theorem card_tripleCollision_mul_le :
    6 * #(tripleCollision A)
      ≤ ∑ x ∈ support A, mult A x * (mult A x - 1) * (mult A x - 2) := by
  have hsub : tripleCollision A ⊆ support A := Finset.filter_subset _ _
  calc 6 * #(tripleCollision A)
      = ∑ _x ∈ tripleCollision A, 6 := by rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ ≤ ∑ x ∈ tripleCollision A, mult A x * (mult A x - 1) * (mult A x - 2) := by
        refine Finset.sum_le_sum fun x hx => ?_
        have h3 : 3 ≤ mult A x := (Finset.mem_filter.1 hx).2
        calc (6 : ℕ) = 3 * (3 - 1) * (3 - 2) := by norm_num
          _ ≤ mult A x * (mult A x - 1) * (mult A x - 2) :=
              Nat.mul_le_mul (Nat.mul_le_mul h3 (by omega)) (by omega)
    _ ≤ ∑ x ∈ support A, mult A x * (mult A x - 1) * (mult A x - 2) :=
        Finset.sum_le_sum_of_subset hsub

/-- A point of multiplicity `≥ 3` is in particular a double collision, so the third-order
count is dominated by the pair-correlation sum; the two collision bounds are consistent and
the third-order one is the stronger statement about `tripleCollision`. -/
theorem card_tripleCollision_le_doubleCollision [DecidableEq ι] :
    2 * #(tripleCollision A) ≤ pairSum A := by
  refine le_trans (Nat.mul_le_mul_left 2 (Finset.card_le_card ?_)) card_doubleCollision_mul_le
  intro x hx
  rw [tripleCollision, Finset.mem_filter] at hx
  rw [doubleCollision, Finset.mem_filter]
  exact ⟨hx.1, by omega⟩

end ThirdOrder

/-! ## 6. Lab notes: sharpness data for the machinery -/

section Sharpness

/-- The double-collision bound `2·|{x : mult x ≥ 2}| ≤ pairSum` is **attained**: for the
constant family `A 0 = A 1 = {0}` on two indices both sides equal `2`. -/
theorem doubleCollision_bound_sharp :
    ∃ A : Fin 2 → Finset ℕ, pairSum A = 2 ∧ #(doubleCollision A) = 1 := by
  refine ⟨fun _ => {0}, ?_, ?_⟩ <;> decide

/-- The Bonferroni inequality can be **strict**: for `A 0 = {0}`, `A 1 = {0}` we have
`∑ |A i| = 2 < 1 + 2 = |support| + pairSum`. -/
theorem bonferroni_can_be_strict :
    ∃ A : Fin 2 → Finset ℕ, ∑ i, #(A i) < #(support A) + pairSum A := by
  refine ⟨fun _ => {0}, ?_⟩
  decide

end Sharpness

end Bonferroni