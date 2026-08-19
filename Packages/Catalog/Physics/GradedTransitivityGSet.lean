import Mathlib
import Physics.GradedTransitivityCore

/-!
# Graded `G`-sets: transitivity degrees and their generating function

For a group `G` and a `G`-set `Y` let

  `t r Y := #{ G-orbits on injective r-tuples of elements of Y }`.

`t r Y = 1` says exactly that `G` acts *`r`-transitively* on `Y`.  For a graded
`G`-set `Y = ⨆ₙ Yₙ` we study the transitivity generating function
`∑ₙ t r Yₙ qⁿ` inside `ℤ⟦q⟧`.

## Main results

* `Physics.GradedTransitivity.tr_eq_one_iff` — `t r Y = 1` iff the action on
  injective `r`-tuples is transitive (and there is at least one such tuple).
* `Physics.GradedTransitivity.denom_of_eventually_transitive` — if the grades are
  eventually `r`-transitive, `∑ₙ t r Yₙ qⁿ` is a rational function with
  denominator dividing `(1 − q)^{r+1}`.
* `Physics.GradedTransitivity.isTransitiveDeg_descent` — `r`-transitive implies
  `k`-transitive for `k ≤ r` (on a finite `G`-set).
* `Physics.GradedTransitivity.denom_of_eventually_transitive_total` — the *total*
  transitivity generating function `∑ₙ (∑_{k ≤ r} t k Yₙ) qⁿ` also has
  denominator dividing `(1 − q)^{r+1}`.
* `Physics.GradedTransitivity.denom_trivialAction_fin` — for the trivial action on
  the graded set `Yₙ = Fin n` one has `t r Yₙ = n^{\underline r}`, a polynomial of
  degree `r` in `n`; the denominator is `(1 − q)^{r+1}` and, by
  `gf_binom_not_poly_of_pow_le`, exponents can genuinely be needed up to `r + 1`.
-/

namespace Physics.GradedTransitivity

open Finset Function PowerSeries MulAction

/-- Injective `r`-tuples of elements of `Y`. -/
def InjTuple (r : ℕ) (Y : Type*) : Type _ := {f : Fin r → Y // Function.Injective f}

namespace InjTuple

variable {G : Type*} [Group G] {Y : Type*} [MulAction G Y] {r : ℕ}

instance : SMul G (InjTuple r Y) where
  smul g a := ⟨fun i => g • (a.1 i), by
    intro i j hij
    exact a.2 (by simpa using congrArg (fun y : Y => g⁻¹ • y) hij)⟩

@[simp] lemma smul_apply (g : G) (a : InjTuple r Y) (i : Fin r) :
    (g • a).1 i = g • (a.1 i) := rfl

@[ext] lemma ext {a b : InjTuple r Y} (h : ∀ i, a.1 i = b.1 i) : a = b :=
  Subtype.ext (funext h)

instance : MulAction G (InjTuple r Y) where
  one_smul a := by ext i; simp
  mul_smul g h a := by ext i; simp [mul_smul]

end InjTuple

variable {G : Type*} [Group G]

/-- The number of `G`-orbits on a `G`-set. -/
noncomputable def orbitNum (G : Type*) [Group G] (Y : Type*) [MulAction G Y] : ℕ :=
  Nat.card (orbitRel.Quotient G Y)

/-- `t r Y`: the number of `G`-orbits on injective `r`-tuples of `Y`; the
"`r`-th transitivity count" of the `G`-set `Y`. -/
noncomputable def transCount (G : Type*) [Group G] (r : ℕ) (Y : Type*) [MulAction G Y] : ℕ :=
  orbitNum G (InjTuple r Y)

/-- `G` acts `r`-transitively on `Y`: some injective `r`-tuple exists and any two are
related by a group element. -/
def IsTransitiveDeg (G : Type*) [Group G] (r : ℕ) (Y : Type*) [MulAction G Y] : Prop :=
  Nonempty (InjTuple r Y) ∧ ∀ a b : InjTuple r Y, ∃ g : G, g • a = b

/-- The transitivity count equals `1` exactly for `r`-transitive actions. -/
theorem transCount_eq_one_iff (r : ℕ) (Y : Type*) [MulAction G Y] :
    transCount G r Y = 1 ↔ IsTransitiveDeg G r Y := by
  rw [transCount, orbitNum, Nat.card_eq_one_iff_unique]
  constructor
  · rintro ⟨hsub, hne⟩
    obtain ⟨q⟩ := hne
    obtain ⟨a⟩ := Quotient.exists_rep q
    refine ⟨⟨a⟩, fun x y => ?_⟩
    have : (Quotient.mk (orbitRel G (InjTuple r Y)) x)
        = Quotient.mk (orbitRel G (InjTuple r Y)) y := Subsingleton.elim _ _
    rw [Quotient.eq] at this
    obtain ⟨g, hg⟩ := this
    exact ⟨g⁻¹, by rw [← hg]; simp⟩
  · rintro ⟨⟨a⟩, htrans⟩
    refine ⟨⟨fun x y => ?_⟩, ⟨Quotient.mk _ a⟩⟩
    induction x using Quotient.inductionOn with
    | _ x =>
      induction y using Quotient.inductionOn with
      | _ y =>
        obtain ⟨g, hg⟩ := htrans x y
        exact Quotient.sound ⟨g⁻¹, by rw [← hg]; simp⟩

/-- **Main theorem.**  If the grades `Yₙ` of a graded `G`-set are eventually
`r`-transitive, then the transitivity generating function `∑ₙ t r Yₙ qⁿ` is a rational
function of `q` whose denominator divides `(1 − q)^{r+1}`. -/
theorem denom_of_eventually_transitive {Y : ℕ → Type*} [∀ n, MulAction G (Y n)] {r N : ℕ}
    (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) :
    IsPoly ((1 - X : PowerSeries ℤ) ^ (r + 1) * gf (fun n => (transCount G r (Y n) : ℤ))) := by
  refine denom_of_eventually_const (N := N) (c := 1) ?_ r
  intro n hn
  have := (transCount_eq_one_iff r (Y n)).mpr (h n hn)
  simp [this]

/-- **Quantitative form.**  Under eventual `r`-transitivity from index `N` on, the
numerator can be taken of degree at most `N + r`. -/
theorem numerator_of_eventually_transitive {Y : ℕ → Type*} [∀ n, MulAction G (Y n)] {r N : ℕ}
    (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) :
    ∃ Q : Polynomial ℤ, Q.natDegree ≤ N + r ∧
      (Q : PowerSeries ℤ)
        = (1 - X : PowerSeries ℤ) ^ (r + 1) * gf (fun n => (transCount G r (Y n) : ℤ)) := by
  refine numerator_natDegree_le_of_eventually_polynomial (P := Polynomial.C 1) (N := N)
    (r := r) (by simp) ?_
  intro n hn
  have := (transCount_eq_one_iff r (Y n)).mpr (h n hn)
  simp [this]

/-- Injective `r`-tuples are exactly the embeddings `Fin r ↪ Y`. -/
def injTupleEquivEmbedding (r : ℕ) (Y : Type*) : InjTuple r Y ≃ (Fin r ↪ Y) :=
  Equiv.subtypeInjectiveEquivEmbedding (Fin r) Y

/-- The number of injective `r`-tuples in a finite set is the descending factorial. -/
lemma card_injTuple (r : ℕ) (Y : Type*) [Fintype Y] :
    Nat.card (InjTuple r Y) = (Fintype.card Y).descFactorial r := by
  classical
  rw [Nat.card_congr (injTupleEquivEmbedding r Y), Nat.card_eq_fintype_card,
    Fintype.card_embedding_eq, Fintype.card_fin]

/-- The number of orbits on injective `r`-tuples never exceeds the number of injective
`r`-tuples themselves. -/
theorem transCount_le_descFactorial {Y : Type*} [Fintype Y] [MulAction G Y] (r : ℕ) :
    transCount G r Y ≤ (Fintype.card Y).descFactorial r := by
  classical
  have hfin : Finite (InjTuple r Y) := inferInstanceAs (Finite {f : Fin r → Y // Injective f})
  have hle : Nat.card (orbitRel.Quotient G (InjTuple r Y)) ≤ Nat.card (InjTuple r Y) :=
    Nat.card_le_card_of_surjective _ Quotient.mk_surjective
  rw [transCount, orbitNum, ← card_injTuple r Y]
  exact hle

/-! ## Descent: `r`-transitivity implies `k`-transitivity for `k ≤ r` -/

section Descent

variable {Y : Type*} [Fintype Y] [DecidableEq Y]

/-- Any injective `k`-tuple in a set with at least `k + m` elements extends to an
injective `(k + m)`-tuple. -/
lemma exists_inj_extension {k m : ℕ} (hr : k + m ≤ Fintype.card Y)
    (a : Fin k → Y) (ha : Function.Injective a) :
    ∃ b : Fin (k + m) → Y, Function.Injective b ∧ ∀ i : Fin k, b (Fin.castAdd m i) = a i := by
  classical
  have hScard : (Finset.image a Finset.univ).card = k := by
    rw [Finset.card_image_of_injective _ ha, Finset.card_univ, Fintype.card_fin]
  have hcompl : m ≤ (Finset.univ \ Finset.image a Finset.univ).card := by
    rw [Finset.card_univ_diff, hScard]
    omega
  obtain ⟨T, hTsub, hTcard⟩ := Finset.exists_subset_card_eq hcompl
  set E := Finset.equivFinOfCardEq hTcard with hE
  refine ⟨Fin.addCases a (fun j => ((E.symm j : Y))), ?_, fun i => by simp⟩
  have he_mem : ∀ j, ((E.symm j : Y)) ∈ T := fun j => (E.symm j).2
  have he_notmem : ∀ j, ((E.symm j : Y)) ∉ Finset.image a Finset.univ := by
    intro j
    have := hTsub (he_mem j)
    exact (Finset.mem_sdiff.mp this).2
  intro i j hij
  induction i using Fin.addCases with
  | left i =>
    induction j using Fin.addCases with
    | left j => simp only [Fin.addCases_left] at hij; simp [ha hij]
    | right j =>
      exfalso
      simp only [Fin.addCases_left, Fin.addCases_right] at hij
      exact he_notmem j (hij ▸ Finset.mem_image_of_mem a (Finset.mem_univ i))
  | right i =>
    induction j using Fin.addCases with
    | left j =>
      exfalso
      simp only [Fin.addCases_left, Fin.addCases_right] at hij
      exact he_notmem i (hij.symm ▸ Finset.mem_image_of_mem a (Finset.mem_univ j))
    | right j =>
      simp only [Fin.addCases_right] at hij
      have : E.symm i = E.symm j := Subtype.ext hij
      simpa using congrArg E this

variable [MulAction G Y]

/-- Restriction of an injective `(k + m)`-tuple to its first `k` entries. -/
def restrictTuple {k m : ℕ} (b : InjTuple (k + m) Y) : InjTuple k Y :=
  ⟨fun i => b.1 (Fin.castAdd m i), fun i j hij => by
    have h := b.2 hij
    exact Fin.ext (by simpa using congrArg Fin.val h)⟩

/-- **Transitivity descent.**  On a finite `G`-set, `(k + m)`-transitivity implies
`k`-transitivity. -/
theorem isTransitiveDeg_descent {k m : ℕ} (h : IsTransitiveDeg G (k + m) Y) :
    IsTransitiveDeg G k Y := by
  obtain ⟨⟨A₀⟩, htrans⟩ := h
  have hcard : k + m ≤ Fintype.card Y := by
    have := Fintype.card_le_of_injective A₀.1 A₀.2
    simpa using this
  refine ⟨⟨restrictTuple A₀⟩, ?_⟩
  intro a b
  obtain ⟨A, hAinj, hA⟩ := exists_inj_extension hcard a.1 a.2
  obtain ⟨B, hBinj, hB⟩ := exists_inj_extension hcard b.1 b.2
  set A' : InjTuple (k + m) Y := ⟨A, hAinj⟩ with hA'
  set B' : InjTuple (k + m) Y := ⟨B, hBinj⟩ with hB'
  obtain ⟨g, hg⟩ := htrans A' B'
  refine ⟨g, ?_⟩
  ext i
  have hgi : (g • A').1 (Fin.castAdd m i) = B'.1 (Fin.castAdd m i) := by rw [hg]
  simpa [hA', hB', hA, hB] using hgi

/-- `r`-transitivity implies `k`-transitivity for all `k ≤ r` (finite `G`-set). -/
theorem isTransitiveDeg_of_le {k r : ℕ} (hkr : k ≤ r) (h : IsTransitiveDeg G r Y) :
    IsTransitiveDeg G k Y := by
  obtain ⟨m, rfl⟩ : ∃ m, r = k + m := ⟨r - k, by omega⟩
  exact isTransitiveDeg_descent h

end Descent

/-- **Total transitivity generating function.**  If the grades are eventually
`r`-transitive then already all counts `t k`, `k ≤ r`, are eventually `1`, so the total
transitivity generating function `∑ₙ (∑_{k ≤ r} t k Yₙ) qⁿ` is rational with denominator
dividing `(1 − q)^{r+1}`. -/
theorem denom_of_eventually_transitive_total {Y : ℕ → Type*} [∀ n, Fintype (Y n)]
    [∀ n, DecidableEq (Y n)] [∀ n, MulAction G (Y n)] {r N : ℕ}
    (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) :
    IsPoly ((1 - X : PowerSeries ℤ) ^ (r + 1)
      * gf (fun n => ∑ k ∈ Finset.range (r + 1), (transCount G k (Y n) : ℤ))) := by
  refine denom_of_eventually_const (N := N) (c := ((r : ℤ) + 1)) ?_ r
  intro n hn
  have hone : ∀ k ∈ Finset.range (r + 1), ((transCount G k (Y n) : ℤ)) = 1 := by
    intro k hk
    have hkr : k ≤ r := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
    have := (transCount_eq_one_iff k (Y n)).mpr (isTransitiveDeg_of_le hkr (h n hn))
    simp [this]
  rw [Finset.sum_congr rfl hone]
  simp

end Physics.GradedTransitivity