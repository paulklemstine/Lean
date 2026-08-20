import Catalog.Shared.SidonSetsErdosTuran

/-!
# Sidon sets II: counting characterisations, extremal rigidity, and Reiman double counting

This file is the second cycle of the Sidon-set research thread begun in
`Shared/SidonSetsErdosTuran.lean`.  There we established the Erdős–Turán sandwich
`√(N/8) < maxSidonCard N ≤ √(2N) + 1` and the dictionary
"Sidon set ⟺ `C₄`-free bipartite incidence graph".  Here we push on three
consequences of that dictionary.

## Main results

Counting characterisation (`Sym2`-valued):

* `addSelf_eq_image_sym2` — the sumset `A + A` is the image of the unordered-pair
  finset `A.sym2` under addition.
* `card_add_self_le` — hence `|A + A| ≤ C(|A| + 1, 2)` for *every* finite set.
* `isSidon_iff_card_add_self` — **`A` is a Sidon set precisely when its sumset is
  as large as it can possibly be**, `|A + A| = C(|A| + 1, 2)`.  This converts the
  Sidon property from a `∀`-statement about quadruples into a single cardinality
  equation.

Extremal rigidity (perfect difference sets):

* `IsSidon.card_diffSet` — a Sidon set realises exactly `|A|² - |A|` nonzero
  differences.
* `IsSidon.perfect_iff` — **the Sidon bound `|A|(|A| - 1) ≤ |G| - 1` is attained iff
  the difference set is all of `G ∖ {0}`**, i.e. iff `A` is a perfect difference set.
* `IsSidon.exists_unique_diff` — at the extremum every nonzero group element has a
  *unique* ordered representation `g = a - b` with `a, b ∈ A`.

Reiman / Kővári–Sós–Turán double counting:

* `sum_offDiag_card_le_of_unique_common_neighbour` — a general extremal-graph-theory
  lemma, absent from Mathlib: in any bipartite incidence system where two distinct
  left vertices share at most one common neighbour, `∑_y (d(y)² - d(y)) ≤ |X|² - |X|`.
* `IsSidon.card_bound_via_reiman` — feeding the Sidon incidence graph into that lemma
  gives a **second, purely graph-theoretic proof** of `|A|(|A| - 1) ≤ |G| - 1`,
  logically independent of the difference-injection proof of cycle 1.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Cycle 1 revealed that the Sidon condition is a *rigidity*
  phenomenon (unique representation).  Three refinements were conjectured.
  (R1) Rigidity is equivalent to an extremal *count*: `A` is Sidon iff `|A+A|` hits
       the trivial upper bound `C(|A|+1,2)`.
  (R2) The inequality `|A|(|A|-1) ≤ |G|-1` is *self-improving*: equality forces the
       difference set to be all of `G ∖ {0}` (a perfect difference set), so the
       extremal configurations are completely rigid, not merely maximal.
  (R3) The `C₄`-free dictionary is strong enough to reprove the counting bound from
       pure graph theory, via a Reiman-type cherry count, with no additive input
       beyond the degree computation `d(y) = |A|`.
Experiment (Experimenter): (R1) was proved by exhibiting `A + A` as the image of
  `Finset.sym2 A` under `Sym2.lift (+)`; the Sidon property is *exactly* injectivity
  of that map, so `Finset.card_image_of_injOn` and `Finset.injOn_of_card_image_eq`
  give the two directions.  (R2) was proved with
  `Finset.eq_of_subset_of_card_le`: the difference set is contained in `G ∖ {0}` and
  has the same cardinality at the extremum.  (R3) required a new general lemma; the
  cherry sets `(N y).offDiag` are pairwise disjoint exactly because two left vertices
  have at most one common neighbour, so `Finset.card_biUnion` turns the double count
  into a single cardinality comparison.
Analysis (Analyst): The three results are three faces of one fact — the Sidon
  property is injectivity of a *single* explicitly constructed map.  Choosing the map
  to be `Sym2 A → A + A` gives the counting characterisation; choosing it to be
  `A.offDiag → G ∖ {0}` gives the difference bound and its rigidity; choosing it to be
  the disjointness of cherry sets gives the Reiman bound.  Nothing here needs the
  ambient set to be an interval or a group of any particular shape, so all three
  survive verbatim in `ZMod N`.
Critique (Critic): `sum_offDiag_card_le_of_unique_common_neighbour` is stated for an
  arbitrary neighbourhood family `N : Y → Finset X`, so it is not tailored to make the
  Sidon application easy — the application must supply the degree computation itself.
  `IsSidon.card_bound_via_reiman` genuinely avoids `IsSidon.sub_injOn`: it invokes the
  Sidon hypothesis only through the four-element identity
  `(y - x) + (y' - x') = (y - x') + (y' - x)`.  `IsSidon.exists_unique_diff` is
  conditional on attaining the extremum, which is exactly the guarded boundary: for a
  generic group order no perfect difference set exists, and the theorem says nothing
  in that case.
Synthesis (PI): one injectivity, three cardinality consequences; rigidity at the
  extremum; and an independent graph-theoretic route to the same bound.
-/

open Finset Pointwise

section Sym2
variable {M : Type*} [AddCancelCommMonoid M] [DecidableEq M] {A : Finset M}

/-- Addition as a function on unordered pairs. -/
def sym2Add : Sym2 M → M := Sym2.lift ⟨fun a b => a + b, fun a b => add_comm a b⟩

omit [DecidableEq M] in
@[simp] theorem sym2Add_mk (a b : M) : sym2Add s(a, b) = a + b := rfl

theorem addSelf_eq_image_sym2 (A : Finset M) : A + A = A.sym2.image sym2Add := by
  ext x
  simp only [Finset.mem_add, Finset.mem_image, Finset.mem_sym2_iff]
  constructor
  · rintro ⟨a, ha, b, hb, rfl⟩
    refine ⟨s(a, b), ?_, rfl⟩
    intro z hz
    rcases Sym2.mem_iff.mp hz with rfl | rfl <;> assumption
  · rintro ⟨m, hm, rfl⟩
    induction m with
    | _ a b =>
      exact ⟨a, hm a (Sym2.mem_mk_left a b), b, hm b (Sym2.mem_mk_right a b), rfl⟩

/-- The sumset of any finite set has at most `C(|A|+1, 2)` elements. -/
theorem card_add_self_le (A : Finset M) : #(A + A) ≤ (#A + 1).choose 2 := by
  rw [addSelf_eq_image_sym2, ← Finset.card_sym2 A]
  exact Finset.card_image_le

/-- **Counting characterisation of Sidon sets.**  `A` is a Sidon set precisely when its
sumset attains the maximum possible size `C(|A| + 1, 2)`. -/
theorem isSidon_iff_card_add_self : IsSidon A ↔ #(A + A) = (#A + 1).choose 2 := by
  rw [addSelf_eq_image_sym2, ← Finset.card_sym2 A]
  constructor
  · intro hA
    refine Finset.card_image_of_injOn ?_
    intro m hm m' hm' h
    induction m with
    | _ a b =>
      induction m' with
      | _ c d =>
        simp only [Finset.mem_coe, Finset.mem_sym2_iff] at hm hm'
        have ha : a ∈ A := hm a (Sym2.mem_mk_left a b)
        have hb : b ∈ A := hm b (Sym2.mem_mk_right a b)
        have hc : c ∈ A := hm' c (Sym2.mem_mk_left c d)
        have hd : d ∈ A := hm' d (Sym2.mem_mk_right c d)
        have hsum : a + b = c + d := h
        rcases hA a ha b hb c hc d hd hsum with ⟨h1, h2⟩ | ⟨h1, h2⟩
        · rw [h1, h2]
        · rw [Sym2.eq_iff]; exact Or.inr ⟨h1, h2⟩
  · intro hcard
    have hinj := Finset.injOn_of_card_image_eq hcard
    intro a ha b hb c hc d hd hsum
    have hma : s(a, b) ∈ (A.sym2 : Set (Sym2 M)) := by
      simp only [Finset.mem_coe, Finset.mem_sym2_iff]
      intro z hz; rcases Sym2.mem_iff.mp hz with rfl | rfl <;> assumption
    have hmc : s(c, d) ∈ (A.sym2 : Set (Sym2 M)) := by
      simp only [Finset.mem_coe, Finset.mem_sym2_iff]
      intro z hz; rcases Sym2.mem_iff.mp hz with rfl | rfl <;> assumption
    have := hinj hma hmc (by simpa using hsum)
    exact Sym2.eq_iff.mp this

end Sym2


section Perfect
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G] {A : Finset G}

/-- The finset of nonzero differences realised by `A`. -/
def diffSet (A : Finset G) : Finset G := A.offDiag.image (fun p => p.1 - p.2)

theorem diffSet_subset (A : Finset G) : diffSet A ⊆ Finset.univ.erase 0 := by
  intro g hg
  simp only [diffSet, Finset.mem_image, Finset.mem_offDiag] at hg
  obtain ⟨⟨a, b⟩, ⟨-, -, hab⟩, rfl⟩ := hg
  simp only [Finset.mem_erase, Finset.mem_univ, and_true]
  exact sub_ne_zero_of_ne hab

omit [Fintype G] in
theorem IsSidon.card_diffSet (hA : IsSidon A) : #(diffSet A) = #A * #A - #A := by
  rw [diffSet, Finset.card_image_of_injOn (by simpa using hA.sub_injOn), Finset.offDiag_card]

/-- **Extremal rigidity for Sidon sets.**  A Sidon set in a finite abelian group `G`
attains the bound `|A|(|A| - 1) = |G| - 1` **iff** every nonzero element of `G` is a
difference of two elements of `A`, i.e. iff `A` is a *perfect difference set*. -/
theorem IsSidon.perfect_iff (hA : IsSidon A) :
    diffSet A = Finset.univ.erase 0 ↔ #A * #A - #A = Fintype.card G - 1 := by
  have hcard : #(Finset.univ.erase (0 : G)) = Fintype.card G - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ]
  constructor
  · intro h
    rw [← hA.card_diffSet, h, hcard]
  · intro h
    refine Finset.eq_of_subset_of_card_le (diffSet_subset A) ?_
    rw [hcard, ← h, hA.card_diffSet]

/-- **Perfect difference sets, unique-representation form.**  If a Sidon set attains the
extremal bound then every nonzero group element has *exactly one* representation as an
ordered difference of two elements of `A`. -/
theorem IsSidon.exists_unique_diff (hA : IsSidon A)
    (hext : #A * #A - #A = Fintype.card G - 1) (g : G) (hg : g ≠ 0) :
    ∃! p : G × G, p ∈ A.offDiag ∧ p.1 - p.2 = g := by
  have hsurj : g ∈ diffSet A := by
    rw [hA.perfect_iff.mpr hext]
    simp [hg]
  simp only [diffSet, Finset.mem_image] at hsurj
  obtain ⟨p, hp, hpg⟩ := hsurj
  refine ⟨p, ⟨hp, hpg⟩, ?_⟩
  rintro q ⟨hq, hqg⟩
  exact hA.sub_injOn (by simpa using hq) (by simpa using hp) (by simp only; rw [hqg, hpg])

end Perfect

/-! ## Reiman-type double counting for `K_{2,2}`-free incidence systems -/

/-- **Reiman / Kővári–Sós–Turán double count.**  Let `N y ⊆ X` be the neighbourhood of
`y : Y` in a bipartite incidence system in which any two distinct `x, x' ∈ X` have at most
one common neighbour in `Y`.  Then `∑_y (d(y)² - d(y)) ≤ |X|² - |X|`. -/
theorem sum_offDiag_card_le_of_unique_common_neighbour
    {X Y : Type*} [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
    (N : Y → Finset X)
    (h : ∀ y y' : Y, y ≠ y' → ∀ x ∈ N y, ∀ x' ∈ N y, x ≠ x' → x ∈ N y' → x' ∉ N y') :
    ∑ y : Y, (#(N y) * #(N y) - #(N y)) ≤ Fintype.card X * Fintype.card X - Fintype.card X := by
  classical
  have hdisj : ∀ y ∈ (Finset.univ : Finset Y), ∀ y' ∈ (Finset.univ : Finset Y), y ≠ y' →
      Disjoint (N y).offDiag (N y').offDiag := by
    intro y _ y' _ hyy'
    rw [Finset.disjoint_left]
    rintro ⟨x, x'⟩ hp hq
    simp only [Finset.mem_offDiag] at hp hq
    exact h y y' hyy' x hp.1 x' hp.2.1 hp.2.2 hq.1 hq.2.1
  have hsub : (Finset.univ : Finset Y).biUnion (fun y => (N y).offDiag)
      ⊆ (Finset.univ : Finset X).offDiag := by
    intro p hp
    simp only [Finset.mem_biUnion, Finset.mem_offDiag] at hp ⊢
    obtain ⟨y, -, hy⟩ := hp
    exact ⟨Finset.mem_univ _, Finset.mem_univ _, hy.2.2⟩
  have hcount := Finset.card_biUnion hdisj
  have hle := Finset.card_le_card hsub
  rw [hcount] at hle
  simpa only [Finset.offDiag_card, Finset.card_univ] using hle

section SidonReiman
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G] {A : Finset G}

omit [Fintype G] in
/-- The left-neighbourhood of the right vertex `y` in the Sidon incidence graph. -/
theorem card_sidonNeighborhood (A : Finset G) (y : G) :
    #(A.image (fun a => y - a)) = #A :=
  Finset.card_image_of_injective A (fun a b hab => by
    have : y - a = y - b := hab
    exact sub_right_injective this)

/-- **Second (graph-theoretic) proof of the Sidon bound.**  Applying the Reiman double
count to the Sidon incidence graph — whose right-degrees are all `|A|` and in which two
distinct left vertices have at most one common neighbour — recovers
`|A|(|A| - 1) ≤ |G| - 1` without any reference to the difference-injectivity argument. -/
theorem IsSidon.card_bound_via_reiman (hA : IsSidon A) :
    #A * #A - #A ≤ Fintype.card G - 1 := by
  classical
  set N : G → Finset G := fun y => A.image (fun a => y - a) with hN
  have hmem : ∀ (y x : G), x ∈ N y ↔ y - x ∈ A := by
    intro y x
    simp only [hN, Finset.mem_image]
    constructor
    · rintro ⟨a, ha, rfl⟩; simpa using ha
    · intro hx; exact ⟨y - x, hx, by abel⟩
  have hkey : ∀ y y' : G, y ≠ y' → ∀ x ∈ N y, ∀ x' ∈ N y, x ≠ x' → x ∈ N y' → x' ∉ N y' := by
    intro y y' hyy' x hx x' hx' hxx' hxy' hx'y'
    rw [hmem] at hx hx' hxy' hx'y'
    -- `(y - x) + (y' - x') = (y - x') + (y' - x)`
    have hsum : (y - x) + (y' - x') = (y - x') + (y' - x) := by abel
    rcases hA _ hx _ hx'y' _ hx' _ hxy' hsum with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact hxx' (sub_right_injective h1)
    · exact hyy' (sub_left_injective h1)
  have hsum := sum_offDiag_card_le_of_unique_common_neighbour N hkey
  have hdeg : ∀ y : G, #(N y) = #A := fun y => card_sidonNeighborhood A y
  simp only [hdeg] at hsum
  rw [Finset.sum_const, Finset.card_univ, smul_eq_mul] at hsum
  rcases Nat.eq_zero_or_pos (Fintype.card G) with hG | hG
  · have := Fintype.card_pos (α := G)
    omega
  · have hmul : Fintype.card G * (#A * #A - #A) ≤ Fintype.card G * (Fintype.card G - 1) := by
      calc Fintype.card G * (#A * #A - #A)
          ≤ Fintype.card G * Fintype.card G - Fintype.card G := hsum
        _ = Fintype.card G * (Fintype.card G - 1) := by
            cases hc : Fintype.card G with
            | zero => simp
            | succ m => simp [Nat.mul_succ]
    exact Nat.le_of_mul_le_mul_left hmul hG

end SidonReiman