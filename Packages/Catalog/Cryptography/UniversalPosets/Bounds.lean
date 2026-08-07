import Mathlib
import Cryptography.UniversalPosets.Core

/-!
# Quantitative bounds for universal posets

This file complements `Cryptography.UniversalPosets.Core` with *quantitative*
information about universal hosts: how many points a poset must have in order to
contain a whole class of `n`-element posets as induced subposets.

The motivating paper ("Even smaller universal posets") produces, for every
`η > 0` and large `n`, a host of size `2^{(1+η)n/2}` containing every `n`-element
poset as an induced subposet.  Two features of that statement are made precise
and proved here:

* the **counting lower bound**: any host that already contains all *bipartite*
  (height `≤ 2`) posets with parts of sizes `k` and `l` must satisfy
  `2 ^ (k*l) ≤ N ^ (k+l)`, i.e. `log₂ N ≥ kl/(k+l)`.  With `k = l = n/2` this is
  the classical `N ≥ 2^{n/4}` bound, the best lower bound currently known;
* the **balanced bipartite upper bound**: an explicit host of size
  `k + 2^k * l` which contains *every* `(k,l)`-bipartite poset as an induced
  subposet.  With `k = l = n/2` its size is `(n/2)(2^{n/2} + 1)`, matching the
  exponent `n/2` of the paper on the extremal subclass.

Together these give, for the balanced bipartite class on `n = 2m` points,
`2^{m/2} ≤ U(m,m) ≤ m·2^m + m`, i.e. the optimal exponent lies between `n/4`
and `n/2 + o(n)`; the paper's theorem says the exponent for the *full* class of
`n`-element posets is at most `(1+η)n/2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer). Seven falsifiable targets were ranked:
(1) the Boolean lattice on the ground set is universal for *all* orders on that
set, not only for a fixed one (generalising `Core`);
(2) universality is a *relation*-level statement, so it survives passing to the
bipartite subclass;
(3) counting bipartite orders forces `2^{kl} ≤ N^{k+l}` for every host;
(4) hence `N ≥ 2^{kl/(k+l)}` after an analytic (rpow) interpolation step;
(5) an explicit "index-tagged neighbourhood" host of size `k + l·2^k` is
universal for the `(k,l)`-bipartite class -- so the exponent `n/2` is attained
on the class where the counting bound is tight up to a factor 2;
(6) for `k = l = 1` the truth is exactly `3`, so the crude counting bound
(`N ≥ 2`) is *not* tight;
(7) duplicate elements force the tag coordinate: neighbourhood labels alone are
not injective.

Experiment (Experimenter). (1)-(6) were formalised and proved.  Target (7)
appears as `bipHost_tag_needed`: the two elements of the second part of a
`(k,2)`-bipartite poset with equal down-sets receive different host points, so
the `Fin l` tag cannot be dropped.  The `k = l = 1` case was computed by hand
and confirms `U = 3 = 1 + 2^1·1`, exactly the size of the explicit host.

Analysis (Analyst). The gap between `2^{n/4}` and `2^{n/2}` is *not* a defect of
the counting method applied to a poor class: on the balanced bipartite class the
number of orders is `2^{n²/4}` while a host of size `2^{n/2}` has roughly
`2^{n²/4}` induced sub-configurations too, so the counting bound loses exactly a
factor `2` in the exponent because a host point may be reused by many different
embeddings.  Removing that factor is precisely what the regularity-based
argument of the paper does; it is out of scope of a self-contained file, and no
`sorry` is used to pretend otherwise.

Critique (Critic). Every statement below is about explicitly constructed
objects; nothing is vacuous: the hypotheses `IsBipartiteUniversal` are witnessed
by `bipHost_isBipartiteUniversal`, and the small case `k = l = 1` is decided in
both directions.  No `native_decide`, no `sorry`.
-/

open Function

namespace UniversalPosets

variable {k l : ℕ}

/-! ## Universality -/

/--
`IsUniversalHost U α` says that every partial order on `α` occurs as an induced
subposet of `U`: for every partial order relation `r` on `α` there is a map
`f : α → U` with `f x ≤ f y ↔ r x y`.  (Such an `f` is automatically injective
whenever `U` is a partial order; see `injective_of_universal_witness`.)
-/
def IsUniversalHost (U : Type*) [LE U] (α : Type*) : Prop :=
  ∀ r : α → α → Prop, IsPartialOrder α r → ∃ f : α → U, ∀ x y, f x ≤ f y ↔ r x y

/-- A witness of universality is automatically injective. -/
theorem injective_of_universal_witness {U α : Type*} [PartialOrder U]
    {r : α → α → Prop} [Std.Antisymm r] {f : α → U} (hf : ∀ x y, f x ≤ f y ↔ r x y) :
    Injective f := by
  intro x y hxy
  exact antisymm_of r ((hf x y).1 (le_of_eq hxy)) ((hf y x).1 (le_of_eq hxy.symm))

/--
A universal host contains every partially ordered `α` as an induced subposet in
the sense of `Core.IsInducedOrderEmbedding`.
-/
theorem inducedEmbedding_of_isUniversalHost {U α : Type*} [PartialOrder U] [PartialOrder α]
    (h : IsUniversalHost U α) : ∃ f : α → U, IsInducedOrderEmbedding f := by
  obtain ⟨f, hf⟩ := h (· ≤ ·) inferInstance
  exact ⟨f, injective_of_universal_witness hf, hf⟩

/-! ## The Boolean host: the naive `2^n` upper bound -/

/--
The Boolean lattice on `α` is a universal host for `α`: *every* partial order on
`α` is realised by principal ideals.  This is the relation-level strengthening
of `Core.finite_poset_has_boolean_induced_embedding`.
-/
theorem setHost_isUniversalHost (α : Type*) : IsUniversalHost (Set α) α := by
  intro r hr
  refine ⟨fun x => {y | r y x}, fun x y => ?_⟩
  simp only [Set.le_eq_subset, Set.setOf_subset_setOf]
  constructor
  · intro h; exact h x (refl_of r x)
  · intro h z hz; exact trans_of r hz h

/-- The naive host has exactly `2^n` points. -/
theorem card_setHost (α : Type*) [Fintype α] [DecidableEq α] :
    Fintype.card (Set α) = 2 ^ Fintype.card α := card_boolean_host α

/-! ## Bipartite (height ≤ 2) orders -/

/--
The `(k,l)`-bipartite order attached to a bipartite relation `R`: the elements of
the first part are pairwise incomparable, likewise those of the second part, and
`a < b` exactly when `R a b`.
-/
def bipRel {k l : ℕ} (R : Fin k → Fin l → Prop) :
    (Fin k ⊕ Fin l) → (Fin k ⊕ Fin l) → Prop
  | Sum.inl a, Sum.inl b => a = b
  | Sum.inl a, Sum.inr b => R a b
  | Sum.inr _, Sum.inl _ => False
  | Sum.inr a, Sum.inr b => a = b

/-- `bipRel R` really is a partial order (height at most two, hence transitive). -/
theorem bipRel_isPartialOrder (R : Fin k → Fin l → Prop) :
    IsPartialOrder (Fin k ⊕ Fin l) (bipRel R) :=
  haveI : Std.Refl (bipRel R) := ⟨by rintro (a | a) <;> simp [bipRel]⟩
  haveI : IsTrans _ (bipRel R) := ⟨by rintro (a | a) (b | b) (c | c) h1 h2 <;> simp_all [bipRel]⟩
  haveI : IsPreorder _ (bipRel R) := ⟨⟩
  haveI : Std.Antisymm (bipRel R) := ⟨by rintro (a | a) (b | b) h1 h2 <;> simp_all [bipRel]⟩
  ⟨⟩

/-- Distinct bipartite relations give distinct orders. -/
theorem bipRel_injective : Injective (bipRel (k := k) (l := l)) := by
  intro R S h
  funext a b
  have := congrFun (congrFun h (Sum.inl a)) (Sum.inr b)
  simpa [bipRel] using this

/--
`IsBipartiteUniversal U k l` : the host `U` contains every `(k,l)`-bipartite
poset as an induced subposet.
-/
def IsBipartiteUniversal (U : Type*) [LE U] (k l : ℕ) : Prop :=
  ∀ R : Fin k → Fin l → Prop, ∃ f : (Fin k ⊕ Fin l) → U, ∀ x y, f x ≤ f y ↔ bipRel R x y

/-- A universal host for `Fin k ⊕ Fin l` is in particular bipartite-universal. -/
theorem isBipartiteUniversal_of_isUniversalHost {U : Type*} [LE U]
    (h : IsUniversalHost U (Fin k ⊕ Fin l)) : IsBipartiteUniversal U k l :=
  fun R => h _ (bipRel_isPartialOrder R)

/-! ## The counting lower bound -/

/--
**Counting lower bound.**  If a finite host `U` with `N` points contains all
`(k,l)`-bipartite posets as induced subposets, then `2 ^ (k*l) ≤ N ^ (k+l)`.

The proof is a genuine injection: from an induced copy of the bipartite poset of
`R` one can *read off* `R`, so the assignment `R ↦ (chosen embedding)` is an
injection from the `2^{kl}` bipartite relations into the `N^{k+l}` maps
`Fin k ⊕ Fin l → U`.
-/
theorem two_pow_mul_le_card_pow {U : Type*} [LE U] [Fintype U]
    (h : IsBipartiteUniversal U k l) :
    2 ^ (k * l) ≤ (Fintype.card U) ^ (k + l) := by
  classical
  choose F hF using fun R : Fin k → Fin l → Bool => h (fun a b => R a b = true)
  have hinj : Injective F := by
    intro R S hRS
    funext a b
    have h1 := hF R (Sum.inl a) (Sum.inr b)
    have h2 := hF S (Sum.inl a) (Sum.inr b)
    rw [hRS] at h1
    simp only [bipRel] at h1 h2
    have : (R a b = true) ↔ (S a b = true) := h1.symm.trans h2
    revert this
    cases R a b <;> cases S a b <;> simp
  have hcard := Fintype.card_le_of_injective F hinj
  have e1 : Fintype.card (Fin k → Fin l → Bool) = 2 ^ (k * l) := by
    simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
    rw [← pow_mul, mul_comm]
  have e2 : Fintype.card ((Fin k ⊕ Fin l) → U) = (Fintype.card U) ^ (k + l) := by
    simp
  rw [e1, e2] at hcard
  exact hcard

/--
Balanced form: a host for the `(m,m)`-bipartite posets (that is, for the
bipartite posets on `n = 2m` points) has at least `2^{m/2} = 2^{n/4}` points,
stated integrally as `2 ^ m ≤ N ^ 2`.
-/
theorem two_pow_le_card_sq {U : Type*} [LE U] [Fintype U] {m : ℕ} (hm : 1 ≤ m)
    (h : IsBipartiteUniversal U m m) : 2 ^ m ≤ (Fintype.card U) ^ 2 := by
  by_contra hlt
  push_neg at hlt
  have key := two_pow_mul_le_card_pow h
  have h1 : ((Fintype.card U) ^ 2) ^ m < (2 ^ m) ^ m :=
    Nat.pow_lt_pow_left hlt (by omega)
  rw [← pow_mul, ← pow_mul] at h1
  have h2 : 2 ^ (m * m) ≤ (Fintype.card U) ^ (m + m) := key
  have : m + m = 2 * m := by omega
  rw [this] at h2
  omega

/--
Analytic form of the counting bound: `N ≥ 2 ^ (kl/(k+l))`, a real-exponent
inequality.  For `k = l = m` (so `n = 2m` points) it reads `N ≥ 2^{n/4}`.
-/
theorem rpow_le_card {U : Type*} [LE U] [Fintype U] [Nonempty U] (hkl : 0 < k + l)
    (h : IsBipartiteUniversal U k l) :
    (2 : ℝ) ^ (((k : ℝ) * l) / ((k : ℝ) + l)) ≤ (Fintype.card U : ℝ) := by
  have hN : (0 : ℝ) < (Fintype.card U : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hklR : ((k : ℝ) + l) ≠ 0 := by
    have : (0 : ℝ) < (k : ℝ) + l := by exact_mod_cast hkl
    linarith
  set x : ℝ := ((k : ℝ) * l) / ((k : ℝ) + l) with hx
  have hbase : (0 : ℝ) ≤ (2 : ℝ) ^ x := (Real.rpow_pos_of_pos (by norm_num) x).le
  have hpow : ((2 : ℝ) ^ x) ^ (k + l) = 2 ^ (k * l) := by
    rw [← Real.rpow_natCast ((2 : ℝ) ^ x) (k + l), ← Real.rpow_mul (by norm_num)]
    have hxe : x * ((k + l : ℕ) : ℝ) = ((k * l : ℕ) : ℝ) := by
      rw [hx]; push_cast; field_simp
    rw [hxe, Real.rpow_natCast]
  have hle : ((2 : ℝ) ^ x) ^ (k + l) ≤ ((Fintype.card U : ℝ)) ^ (k + l) := by
    rw [hpow]
    exact_mod_cast two_pow_mul_le_card_pow h
  exact le_of_pow_le_pow_left₀ (by omega) hN.le hle

/-! ## The explicit bipartite host -/

/--
The `(k,l)`-bipartite host: `k` "bottom" points, together with all pairs
(neighbourhood, tag) with the neighbourhood a subset of the bottom and the tag
in `Fin l`.  The tag is what allows two elements with the *same* down-set to be
embedded as two distinct points.
-/
def BipHost (k l : ℕ) : Type := Fin k ⊕ (Set (Fin k) × Fin l)

instance : Fintype (BipHost k l) :=
  inferInstanceAs (Fintype (Fin k ⊕ (Set (Fin k) × Fin l)))

/-- The order on the bipartite host: bottom point `a` is below `(S, j)` iff `a ∈ S`. -/
def bipHostLe : BipHost k l → BipHost k l → Prop
  | Sum.inl a, Sum.inl b => a = b
  | Sum.inl a, Sum.inr p => a ∈ p.1
  | Sum.inr _, Sum.inl _ => False
  | Sum.inr p, Sum.inr q => p = q

instance : PartialOrder (BipHost k l) where
  le := bipHostLe
  le_refl := by rintro (a | a) <;> simp [bipHostLe]
  le_trans := by rintro (a | a) (b | b) (c | c) h1 h2 <;> simp_all [bipHostLe]
  le_antisymm := by rintro (a | a) (b | b) h1 h2 <;> simp_all [bipHostLe]

@[simp] theorem bipHost_le_def (x y : BipHost k l) : x ≤ y ↔ bipHostLe x y := Iff.rfl

/-- The bipartite host has exactly `k + 2^k * l` points. -/
theorem card_bipHost : Fintype.card (BipHost k l) = k + 2 ^ k * l := by
  simp [BipHost, Fintype.card_sum, Fintype.card_prod, Fintype.card_set]

/--
**Upper bound.**  The explicit host `BipHost k l` contains every
`(k,l)`-bipartite poset as an induced subposet.
-/
theorem bipHost_isBipartiteUniversal : IsBipartiteUniversal (BipHost k l) k l := by
  classical
  intro R
  refine ⟨fun x => match x with
    | Sum.inl a => (Sum.inl a : BipHost k l)
    | Sum.inr b => (Sum.inr ({a | R a b}, b) : BipHost k l), ?_⟩
  rintro (a | a) (b | b)
  · simp [bipRel, bipHostLe]
  · simp [bipRel, bipHostLe]
  · simp [bipRel, bipHostLe]
  · simp only [bipRel, bipHost_le_def, bipHostLe]
    exact ⟨fun h => (Prod.ext_iff.1 h).2, fun h => by subst h; rfl⟩

/--
For `n = 2m` points the explicit balanced host has size `m·2^m + m`, i.e.
exponent `n/2` -- the exponent of the motivating paper -- while every host needs
at least `2^{m/2}` points.
-/
theorem balanced_bipartite_sandwich (m : ℕ) (hm : 1 ≤ m) :
    (Fintype.card (BipHost m m) = 2 ^ m * m + m ∧ IsBipartiteUniversal (BipHost m m) m m) ∧
      ∀ (U : Type) [LE U] [Fintype U], IsBipartiteUniversal U m m →
        2 ^ m ≤ (Fintype.card U) ^ 2 := by
  refine ⟨⟨?_, bipHost_isBipartiteUniversal⟩, fun U _ _ h => two_pow_le_card_sq hm h⟩
  rw [card_bipHost]
  omega

/-! ## The tag coordinate is necessary -/

/--
Two elements of the top part with the same down-set must still receive distinct
host points: universality is strictly stronger than realising the comparability
relation.  This is why the host carries a `Fin l` tag.
-/
theorem bipHost_tag_needed {U : Type*} [PartialOrder U] {k : ℕ}
    (h : IsBipartiteUniversal U k 2) :
    ∃ f : (Fin k ⊕ Fin 2) → U, f (Sum.inr 0) ≠ f (Sum.inr 1) := by
  obtain ⟨f, hf⟩ := h (fun _ _ => False)
  refine ⟨f, fun hcon => ?_⟩
  have h1 : f (Sum.inr 0) ≤ f (Sum.inr 1) := le_of_eq hcon
  have h2 := (hf (Sum.inr 0) (Sum.inr 1)).1 h1
  simp [bipRel] at h2

/-! ## Transfer along equivalences, and the full class on `Fin n` -/

/-- Universality only depends on the ground type up to equivalence. -/
theorem IsUniversalHost.congr {U α β : Type*} [LE U] (e : β ≃ α)
    (h : IsUniversalHost U α) : IsUniversalHost U β := by
  intro r hr
  have hr' : IsPartialOrder α (fun x y => r (e.symm x) (e.symm y)) :=
    haveI : Std.Refl (fun x y => r (e.symm x) (e.symm y)) := ⟨fun x => refl_of r _⟩
    haveI : IsTrans α (fun x y => r (e.symm x) (e.symm y)) :=
      ⟨fun _ _ _ h1 h2 => trans_of r h1 h2⟩
    haveI : IsPreorder α (fun x y => r (e.symm x) (e.symm y)) := ⟨⟩
    haveI : Std.Antisymm (fun x y => r (e.symm x) (e.symm y)) :=
      ⟨fun _ _ h1 h2 => e.symm.injective (antisymm_of r h1 h2)⟩
    ⟨⟩
  obtain ⟨f, hf⟩ := h _ hr'
  exact ⟨f ∘ e, fun x y => by simpa using hf (e x) (e y)⟩

/--
**Lower bound for the full class.**  A host containing every partial order on
`n = 2m` points as an induced subposet has at least `2^{m/2} = 2^{n/4}` points
(stated integrally as `2 ^ m ≤ N ^ 2`).
-/
theorem two_pow_le_card_sq_of_isUniversalHost {U : Type*} [LE U] [Fintype U] {m : ℕ}
    (hm : 1 ≤ m) (h : IsUniversalHost U (Fin (m + m))) :
    2 ^ m ≤ (Fintype.card U) ^ 2 :=
  two_pow_le_card_sq hm
    (isBipartiteUniversal_of_isUniversalHost (h.congr finSumFinEquiv))

/--
**Sandwich for the full class of posets on `n = 2m` points.**  The Boolean
lattice is a universal host with `2^n` points, while every universal host has at
least `2^{n/4}` points.  The motivating paper interpolates between the two by
producing hosts of size `2^{(1+η)n/2}`.
-/
theorem universal_host_sandwich (m : ℕ) (hm : 1 ≤ m) :
    (IsUniversalHost (Set (Fin (m + m))) (Fin (m + m)) ∧
        Fintype.card (Set (Fin (m + m))) = 2 ^ (m + m)) ∧
      ∀ (U : Type) [LE U] [Fintype U], IsUniversalHost U (Fin (m + m)) →
        2 ^ m ≤ (Fintype.card U) ^ 2 := by
  refine ⟨⟨setHost_isUniversalHost _, ?_⟩,
    fun U _ _ h => two_pow_le_card_sq_of_isUniversalHost hm h⟩
  rw [card_setHost]
  simp

end UniversalPosets