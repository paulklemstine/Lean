import Cryptography.UniversalPosets.MinSize

/-!
# A linear lower bound and the exact value `U(3) = 5`

This file continues the quantitative study of

`minUniversalSize n = U(n)` : the least number of points of a poset containing
every `n`-element poset as an induced subposet,

by closing two of the questions that the previous cycle could only answer with
machine evidence.

Proved here:

* `two_mul_sub_one_le_minUniversalSize` : `2n - 1 ≤ U(n)` for **every** `n`.
  The argument is a *structural* one, not a counting one: a universal host must
  contain an `n`-chain and an `n`-antichain, and these two `n`-sets can share at
  most one point, because two shared points would be simultaneously comparable
  (inside the chain) and incomparable (inside the antichain).  This is sharp at
  `n = 2` and `n = 3`.
* `minUniversalSize_three` : `U(3) = 5` **exactly**.  The upper bound is the
  explicit five-point host `host3Le` (a diamond `4 < 2, 3 < 1` together with an
  isolated point `0`); its universality for the nineteen partial orders on three
  points is decided by the kernel, and the matching lower bound `5 ≤ U(3)` is
  the case `n = 3` of the linear bound above.  In the previous cycle `U(3) = 5`
  was recorded as unverified computational evidence; it is now a theorem.
* `minUniversalSize_mono` : `U` is monotone, so all lower bounds propagate
  upwards.
* `minUniversalSize_zero`, `minUniversalSize_one` : `U(0) = 0`, `U(1) = 1`.

Together with `two_pow_le_minUniversalSize_sq` (`2^{n/4} ≤ U(n)`) and
`minUniversalSize_le_two_pow` (`U(n) ≤ 2^n`) this gives
`max (2n-1, 2^{n/4}) ≤ U(n) ≤ 2^n`, with equality in the lower bound for
`n ≤ 3`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The counting bound `2^{n/4}` is useless for small
`n` (it gives `2` at `n = 2`), yet the true values `1, 3, 5` grow linearly with
slope `2`.  Conjecture: the *chain versus antichain* obstruction alone forces
slope `2`, i.e. `U(n) ≥ 2n - 1`, and this is tight for `n ≤ 3`.

Experiment (Experimenter).  An exhaustive search over the `4231` partial orders
on five points found `300` hosts universal for the `19` partial orders on three
points, and none on four points; one of the `300` with the fewest relations is
the diamond-plus-isolated-point host formalised here as `host3Le`.  Its
universality is re-verified inside Lean by `decide` (512 Boolean relations, 125
candidate embeddings), so no trust is placed in the external search.

Analysis (Analyst).  The chain/antichain argument explains *why* no four-point
host exists, without any search: a four-point host with a three-chain has at
most two points off that chain, so it cannot contain three pairwise
incomparable points.  The same argument scales to all `n`, which is what
`two_mul_sub_one_le_minUniversalSize` records.  The bound is not tight for large
`n`, where the exponential counting bound takes over; the crossover is around
`n = 20`.

Critique (Critic).  Nothing here is vacuous: `IsUniversalPosetOfSize 5 3` is
witnessed by an explicit relation, the lower bound is proved for an arbitrary
host, and the two bounds meet.  The kernel-checked `decide` calls are on genuine
finite search problems (they are not `native_decide`), and every hypothesis of
the abstract lemmas is discharged for the concrete host.
-/

namespace UniversalPosets

open Function

/-! ## Equality as a partial order -/

/-- Equality is a partial order: the `n`-element antichain. -/
theorem isPartialOrder_eq (α : Type*) : IsPartialOrder α (fun x y => x = y) :=
  haveI : Std.Refl (fun x y : α => x = y) := ⟨fun _ => rfl⟩
  haveI : IsTrans α (fun x y : α => x = y) := ⟨fun _ _ _ h1 h2 => h1.trans h2⟩
  haveI : IsPreorder α (fun x y : α => x = y) := ⟨⟩
  haveI : Std.Antisymm (fun x y : α => x = y) := ⟨fun _ _ h1 _ => h1⟩
  ⟨⟩

/-! ## The chain-versus-antichain lower bound -/

/-! ## Overlap of two induced copies -/

/--
`CommonInducedBound r r' s` : the two `n`-element posets `r` and `r'` have no
common induced subposet on more than `s` points.  Formally, whenever a set `A`
of points of `r` is carried by a map `φ`, injective on `A`, to points of `r'` in
an order-preserving *and* order-reflecting way, then `|A| ≤ s`.
-/
def CommonInducedBound {n : ℕ} (r r' : Fin n → Fin n → Prop) (s : ℕ) : Prop :=
  ∀ (A : Finset (Fin n)) (φ : Fin n → Fin n), Set.InjOn φ ↑A →
    (∀ x ∈ A, ∀ y ∈ A, (r x y ↔ r' (φ x) (φ y))) → A.card ≤ s

/--
**Overlap lower bound.**  If two `n`-element posets share no common induced
subposet on more than `s` points, then a host containing both of them as induced
subposets has at least `2n - s` points: the two induced copies use `n` host
points each and can overlap in at most `s` of them.

This is a *structural* bound, complementary to the counting bound
`2^{n/4} ≤ U(n)`: it does not count posets at all, it uses the incompatibility
of two of them.
-/
theorem injective_of_host_witness {N n : ℕ} {H : Pt N → Pt N → Prop}
    (hH : IsPartialOrder (Pt N) H) {r : Fin n → Fin n → Prop} (hr : IsPartialOrder (Fin n) r)
    {f : Fin n → Pt N} (hf : ∀ x y, H (f x) (f y) ↔ r x y) : Injective f := by
  haveI := hH; haveI := hr
  exact fun x y hxy =>
    antisymm_of r ((hf x y).1 (by rw [hxy]; exact refl_of H _))
      ((hf y x).1 (by rw [hxy]; exact refl_of H _))

/--
**Overlap of two induced copies.**  Inside a fixed host, the images of two
induced copies of posets with no common induced subposet on more than `s` points
meet in at most `s` host points.
-/
theorem card_inter_images_le {N n s : ℕ} {H : Pt N → Pt N → Prop}
    (hH : IsPartialOrder (Pt N) H) {r r' : Fin n → Fin n → Prop}
    (hr : IsPartialOrder (Fin n) r) (hr' : IsPartialOrder (Fin n) r')
    (hs : CommonInducedBound r r' s) {f g : Fin n → Pt N}
    (hf : ∀ x y, H (f x) (f y) ↔ r x y) (hg : ∀ x y, H (g x) (g y) ↔ r' x y) :
    ((Finset.image f Finset.univ) ∩ (Finset.image g Finset.univ)).card ≤ s := by
  classical
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  have hfinj : Injective f := injective_of_host_witness hH hr hf
  have hgφ : ∀ x ∈ Finset.univ.filter (fun x => f x ∈ Finset.image g Finset.univ),
      g (Function.invFun g (f x)) = f x := by
    intro x hx
    rw [Finset.mem_filter] at hx
    obtain ⟨y, -, hy⟩ := Finset.mem_image.1 hx.2
    exact Function.invFun_eq ⟨y, hy⟩
  have hinj : Set.InjOn (fun x => Function.invFun g (f x))
      ↑(Finset.univ.filter (fun x => f x ∈ Finset.image g (Finset.univ : Finset (Fin n)))) := by
    intro x hx y hy hxy
    apply hfinj
    rw [← hgφ x (by simpa using hx), ← hgφ y (by simpa using hy)]
    exact congrArg g hxy
  have hiso : ∀ x ∈ Finset.univ.filter (fun x => f x ∈ Finset.image g Finset.univ),
      ∀ y ∈ Finset.univ.filter (fun x => f x ∈ Finset.image g Finset.univ),
        (r x y ↔ r' (Function.invFun g (f x)) (Function.invFun g (f y))) := by
    intro x hx y hy
    have h1 := hg (Function.invFun g (f x)) (Function.invFun g (f y))
    rw [hgφ x hx, hgφ y hy] at h1
    exact (hf x y).symm.trans h1
  have hcardA₀ :
      (Finset.univ.filter (fun x => f x ∈ Finset.image g (Finset.univ : Finset (Fin n)))).card
        ≤ s := hs _ _ hinj hiso
  have himg :
      Finset.image f
          (Finset.univ.filter (fun x => f x ∈ Finset.image g (Finset.univ : Finset (Fin n))))
        = (Finset.image f Finset.univ) ∩ (Finset.image g Finset.univ) := by
    ext p
    constructor
    · intro hp
      obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hp
      rw [Finset.mem_filter] at hx
      exact Finset.mem_inter.2 ⟨Finset.mem_image_of_mem f (Finset.mem_univ x), hx.2⟩
    · intro hp
      obtain ⟨hp1, hp2⟩ := Finset.mem_inter.1 hp
      obtain ⟨x, -, rfl⟩ := Finset.mem_image.1 hp1
      exact Finset.mem_image.2
        ⟨x, Finset.mem_filter.2 ⟨Finset.mem_univ x, hp2⟩, rfl⟩
  rw [← himg, Finset.card_image_of_injective _ hfinj]
  exact hcardA₀

/--
**Overlap lower bound.**  If two `n`-element posets share no common induced
subposet on more than `s` points, then a host containing both of them as induced
subposets has at least `2n - s` points: the two induced copies use `n` host
points each and can overlap in at most `s` of them.

This is a *structural* bound, complementary to the counting bound
`2^{n/4} ≤ U(n)`: it does not count posets at all, it uses the incompatibility
of two of them.
-/
theorem two_mul_sub_le_of_commonInducedBound {N n s : ℕ} (h : IsUniversalPosetOfSize N n)
    {r r' : Fin n → Fin n → Prop} (hr : IsPartialOrder (Fin n) r)
    (hr' : IsPartialOrder (Fin n) r') (hs : CommonInducedBound r r' s) :
    2 * n - s ≤ N := by
  classical
  obtain ⟨H, hH, hu⟩ := h
  obtain ⟨f, hf⟩ := hu r hr
  obtain ⟨g, hg⟩ := hu r' hr'
  have hfinj : Injective f := injective_of_host_witness hH hr hf
  have hginj : Injective g := injective_of_host_witness hH hr' hg
  have hCcard : (Finset.image f Finset.univ).card = n := by
    rw [Finset.card_image_of_injective _ hfinj]; simp
  have hAcard : (Finset.image g Finset.univ).card = n := by
    rw [Finset.card_image_of_injective _ hginj]; simp
  have hunion :
      ((Finset.image f Finset.univ) ∪ (Finset.image g Finset.univ)).card ≤ N := by
    simpa using Finset.card_le_univ
      ((Finset.image f Finset.univ) ∪ (Finset.image g (Finset.univ : Finset (Fin n))))
  have hsum := Finset.card_union_add_card_inter
    (Finset.image f (Finset.univ : Finset (Fin n))) (Finset.image g Finset.univ)
  have hinter := card_inter_images_le hH hr hr' hs hf hg
  omega

/-- A chain and an antichain have no common induced subposet on two points. -/
theorem commonInducedBound_chain_antichain (n : ℕ) :
    CommonInducedBound (fun x y : Fin n => x ≤ y) (fun x y => x = y) 1 := by
  intro A φ hinj hiso
  by_contra hcon
  push_neg at hcon
  obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.1 hcon
  rcases le_total x y with hle | hle
  · exact hxy (hinj (Finset.mem_coe.2 hx) (Finset.mem_coe.2 hy) ((hiso x hx y hy).1 hle))
  · exact hxy (hinj (Finset.mem_coe.2 hx) (Finset.mem_coe.2 hy)
      ((hiso y hy x hx).1 hle).symm)

/--
**Structural lower bound.**  A poset on `N` points containing every `n`-element
poset as an induced subposet satisfies `2n - 1 ≤ N`: the induced `n`-chain and
the induced `n`-antichain share at most one point.
-/
theorem two_mul_sub_one_le_of_isUniversalPosetOfSize {N n : ℕ}
    (h : IsUniversalPosetOfSize N n) : 2 * n - 1 ≤ N :=
  two_mul_sub_le_of_commonInducedBound h inferInstance (isPartialOrder_eq _)
    (commonInducedBound_chain_antichain n)

/-- **`U(n) ≥ 2n - 1`.**  A linear lower bound, sharp for `n ≤ 3`. -/
theorem two_mul_sub_one_le_minUniversalSize (n : ℕ) : 2 * n - 1 ≤ minUniversalSize n :=
  two_mul_sub_one_le_of_isUniversalPosetOfSize (isUniversalPosetOfSize_minUniversalSize n)

/-! ## Monotonicity of `U` -/

/-- Adding an isolated point to an `n`-element order gives an `(n+1)`-element order. -/
private def extendRel {n : ℕ} (r : Fin n → Fin n → Prop) :
    Fin (n + 1) → Fin (n + 1) → Prop :=
  fun x y => x = y ∨ ∃ hx : (x : ℕ) < n, ∃ hy : (y : ℕ) < n, r ⟨x, hx⟩ ⟨y, hy⟩

private theorem extendRel_isPartialOrder {n : ℕ} (r : Fin n → Fin n → Prop)
    (hr : IsPartialOrder (Fin n) r) : IsPartialOrder (Fin (n + 1)) (extendRel r) :=
  haveI : Std.Refl (extendRel r) := ⟨fun _ => Or.inl rfl⟩
  haveI : IsTrans (Fin (n + 1)) (extendRel r) := by
    refine ⟨?_⟩
    rintro x y z (rfl | ⟨hx, hy, hxy⟩) (h2 | ⟨hy', hz, hyz⟩)
    · exact Or.inl h2
    · exact Or.inr ⟨hy', hz, hyz⟩
    · subst h2; exact Or.inr ⟨hx, hy, hxy⟩
    · exact Or.inr ⟨hx, hz, trans_of r hxy (by simpa using hyz)⟩
  haveI : IsPreorder (Fin (n + 1)) (extendRel r) := ⟨⟩
  haveI : Std.Antisymm (extendRel r) := by
    refine ⟨?_⟩
    rintro x y (rfl | ⟨hx, hy, hxy⟩) (h2 | ⟨hy', hx', hyx⟩)
    · rfl
    · rfl
    · exact h2.symm
    · have : (⟨x, hx⟩ : Fin n) = ⟨y, hy⟩ := antisymm_of r hxy (by simpa using hyx)
      exact Fin.ext (by simpa using congrArg Fin.val this)
  ⟨⟩

/-- A host universal for the `(n+1)`-element posets is universal for the `n`-element ones. -/
theorem isUniversalPosetOfSize_of_succ {N n : ℕ} (h : IsUniversalPosetOfSize N (n + 1)) :
    IsUniversalPosetOfSize N n := by
  obtain ⟨H, hH, hu⟩ := h
  refine ⟨H, hH, fun r hr => ?_⟩
  obtain ⟨F, hF⟩ := hu (extendRel r) (extendRel_isPartialOrder r hr)
  refine ⟨fun x => F x.castSucc, fun x y => ?_⟩
  rw [hF]
  constructor
  · rintro (heq | ⟨hx, hy, hxy⟩)
    · have : x = y := by
        have := congrArg Fin.val heq
        exact Fin.ext (by simpa using this)
      subst this; exact refl_of r x
    · simpa using hxy
  · intro hxy
    exact Or.inr ⟨by simp, by simp, by simpa using hxy⟩

/-- **`U` is monotone**: more points to embed cannot make the host smaller. -/
theorem minUniversalSize_mono : Monotone minUniversalSize := by
  refine monotone_nat_of_le_succ (fun n => ?_)
  exact Nat.sInf_le
    (isUniversalPosetOfSize_of_succ (isUniversalPosetOfSize_minUniversalSize (n + 1)))

/-! ## The exact values `U(0) = 0`, `U(1) = 1` -/

theorem minUniversalSize_zero : minUniversalSize 0 = 0 := by
  refine Nat.le_antisymm (Nat.sInf_le ⟨fun _ _ => True, ?_, fun r _ => ⟨fun x => x.elim0, ?_⟩⟩)
    (Nat.zero_le _)
  · exact
      haveI : Std.Refl (fun _ _ : Pt 0 => True) := ⟨fun _ => trivial⟩
      haveI : IsTrans (Pt 0) (fun _ _ : Pt 0 => True) := ⟨fun _ _ _ _ _ => trivial⟩
      haveI : IsPreorder (Pt 0) (fun _ _ : Pt 0 => True) := ⟨⟩
      haveI : Std.Antisymm (fun _ _ : Pt 0 => True) := ⟨fun a _ _ _ => a.elim0⟩
      ⟨⟩
  · exact fun x => x.elim0

theorem minUniversalSize_one : minUniversalSize 1 = 1 := by
  refine Nat.le_antisymm (Nat.sInf_le ⟨fun _ _ => True, ?_, fun r hr => ⟨fun _ => ⟨0, one_pos⟩, ?_⟩⟩)
    (by simpa using self_le_minUniversalSize 1)
  · exact
      haveI : Std.Refl (fun _ _ : Pt 1 => True) := ⟨fun _ => trivial⟩
      haveI : IsTrans (Pt 1) (fun _ _ : Pt 1 => True) := ⟨fun _ _ _ _ _ => trivial⟩
      haveI : IsPreorder (Pt 1) (fun _ _ : Pt 1 => True) := ⟨⟩
      haveI : Subsingleton (Pt 1) := inferInstanceAs (Subsingleton (Fin 1))
      haveI : Std.Antisymm (fun _ _ : Pt 1 => True) := ⟨fun a b _ _ => Subsingleton.elim a b⟩
      ⟨⟩
  · intro x y
    haveI : Subsingleton (Fin 1) := inferInstance
    have : x = y := Subsingleton.elim x y
    subst this
    exact ⟨fun _ => refl_of r x, fun _ => trivial⟩

/-! ## The five-point host and `U(3) = 5` -/

/--
The five-point host: a diamond `4 < 2, 3 < 1` together with an isolated point
`0`.  It is one of the `300` five-point hosts that contain all nineteen partial
orders on three points; it has the fewest relations.
-/
def host3Le : Fin 5 → Fin 5 → Bool
  | 0, 0 => true
  | 1, 1 => true
  | 2, 2 => true
  | 3, 3 => true
  | 4, 4 => true
  | 2, 1 => true
  | 3, 1 => true
  | 4, 1 => true
  | 4, 2 => true
  | 4, 3 => true
  | _, _ => false

theorem host3Le_refl (x : Fin 5) : host3Le x x = true := by revert x; decide

theorem host3Le_trans (x y z : Fin 5) (h1 : host3Le x y = true) (h2 : host3Le y z = true) :
    host3Le x z = true := by revert x y z; decide

theorem host3Le_antisymm (x y : Fin 5) (h1 : host3Le x y = true) (h2 : host3Le y x = true) :
    x = y := by revert x y; decide

set_option maxRecDepth 10000 in
/--
**Kernel-checked universality of the five-point host.**  Every partial order on
three points (given here in Boolean form) embeds as an induced subposet.
-/
theorem host3Le_universal_bool (R : Fin 3 → Fin 3 → Bool)
    (hrefl : ∀ x, R x x = true)
    (htrans : ∀ x y z, R x y = true → R y z = true → R x z = true)
    (hanti : ∀ x y, R x y = true → R y x = true → x = y) :
    ∃ f : Fin 3 → Fin 5, ∀ x y, host3Le (f x) (f y) = R x y := by
  revert R
  decide

/-- The five-point host realises all three-element posets. -/
theorem isUniversalPosetOfSize_five_three : IsUniversalPosetOfSize 5 3 := by
  classical
  refine ⟨fun a b => host3Le a b = true, ?_, ?_⟩
  · exact
      haveI : Std.Refl (fun a b : Pt 5 => host3Le a b = true) := ⟨host3Le_refl⟩
      haveI : IsTrans (Pt 5) (fun a b : Pt 5 => host3Le a b = true) :=
        ⟨fun a b c => host3Le_trans a b c⟩
      haveI : IsPreorder (Pt 5) (fun a b : Pt 5 => host3Le a b = true) := ⟨⟩
      haveI : Std.Antisymm (fun a b : Pt 5 => host3Le a b = true) :=
        ⟨fun a b => host3Le_antisymm a b⟩
      ⟨⟩
  · intro r hr
    obtain ⟨f, hf⟩ := host3Le_universal_bool (fun x y => decide (r x y))
      (fun x => by simpa using refl_of r x)
      (fun x y z h1 h2 => by
        simp only [decide_eq_true_eq] at *
        exact trans_of r h1 h2)
      (fun x y h1 h2 => by
        simp only [decide_eq_true_eq] at *
        exact antisymm_of r h1 h2)
    refine ⟨f, fun x y => ?_⟩
    show host3Le (f x) (f y) = true ↔ r x y
    rw [hf x y, decide_eq_true_eq]

/-- **Exact value**: `U(3) = 5`.  Upper bound: the explicit five-point host.
Lower bound: the chain-versus-antichain argument. -/
theorem minUniversalSize_three : minUniversalSize 3 = 5 := by
  refine Nat.le_antisymm (Nat.sInf_le isUniversalPosetOfSize_five_three) ?_
  have := two_mul_sub_one_le_minUniversalSize 3
  omega

/-- There is no four-point host for the three-element posets. -/
theorem not_isUniversalPosetOfSize_four_three : ¬ IsUniversalPosetOfSize 4 3 := by
  intro h
  have := two_mul_sub_one_le_of_isUniversalPosetOfSize h
  omega

/--
**Summary of the exactly known values**, together with the general bounds.
-/
theorem minUniversalSize_small_values :
    minUniversalSize 0 = 0 ∧ minUniversalSize 1 = 1 ∧ minUniversalSize 2 = 3 ∧
      minUniversalSize 3 = 5 ∧ ∀ n, 2 * n - 1 ≤ minUniversalSize n ∧
        minUniversalSize n ≤ 2 ^ n :=
  ⟨minUniversalSize_zero, minUniversalSize_one, minUniversalSize_two, minUniversalSize_three,
    fun n => ⟨two_mul_sub_one_le_minUniversalSize n, minUniversalSize_le_two_pow n⟩⟩

end UniversalPosets